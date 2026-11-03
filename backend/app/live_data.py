from __future__ import annotations

import csv
import io
import json
import logging
import re
from datetime import datetime, timezone
from html.parser import HTMLParser
from typing import Any
from zoneinfo import ZoneInfo

import httpx
from app.settings import settings

logger = logging.getLogger(__name__)

FIELD_ALIASES = {
    "generation_mw": {"generation", "totalgeneration", "totalgenerationmw", "generationmw", "totalmw", "supply"},
    "demand_mw": {"demand", "totaldemand", "totaldemandmw", "demandmw", "load", "loadmw"},
    "gas_mw": {"gas", "gasmw"},
    "liquid_fuel_mw": {"liquidfuel", "liquidfuelmw", "fuel", "hfo", "hsd"},
    "coal_mw": {"coal", "coalmw"},
    "solar_mw": {"solar", "solarmw"},
    "hydro_mw": {"hydro", "hydromw"},
    "wind_mw": {"wind", "windmw"},
    "india_mw": {"india", "indiamw"},
    "nepal_mw": {"nepal", "nepalmw"},
    "adani_mw": {"adani", "adanimw"},
    "imports_mw": {"imports", "import", "importsmw", "importmw"},
}


def _key(value: Any) -> str:
    return re.sub(r"[^a-z0-9]", "", str(value).lower())


def _number(value: Any) -> float | None:
    if isinstance(value, (int, float)):
        return float(value)
    if value is None:
        return None
    match = re.search(r"-?\d[\d,]*(?:\.\d+)?", str(value))
    if not match:
        return None
    try:
        return float(match.group().replace(",", ""))
    except ValueError:
        return None


class _TableParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.tables: list[list[list[str]]] = []
        self._row: list[str] | None = None
        self._cell: list[str] | None = None
        self._in_table = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag == "table":
            self._in_table = True
            self.tables.append([])
        elif self._in_table and tag == "tr":
            self._row = []
        elif self._in_table and tag in {"td", "th"}:
            self._cell = []

    def handle_data(self, data: str) -> None:
        if self._cell is not None:
            self._cell.append(data.strip())

    def handle_endtag(self, tag: str) -> None:
        if tag in {"td", "th"} and self._cell is not None:
            if self._row is not None:
                self._row.append(" ".join(part for part in self._cell if part))
            self._cell = None
        elif tag == "tr" and self._row is not None:
            if self._row and self._in_table:
                self.tables[-1].append(self._row)
            self._row = None
        elif tag == "table":
            self._in_table = False


def _extract_mapping(mapping: dict[str, Any]) -> dict[str, Any] | None:
    normalized = {_key(key): value for key, value in mapping.items()}
    result: dict[str, Any] = {}
    for field, aliases in FIELD_ALIASES.items():
        for alias in aliases:
            if alias in normalized:
                number = _number(normalized[alias])
                if number is not None:
                    result[field] = number
                    break
    timestamp = next((value for key, value in normalized.items() if key in {"timestamp", "observedat", "datetime", "date", "time"}), None)
    if timestamp:
        result["observed_at"] = str(timestamp)
    if "generation_mw" in result or "demand_mw" in result:
        return result
    return None


def _find_json_record(value: Any) -> dict[str, Any] | None:
    if isinstance(value, dict):
        found = _extract_mapping(value)
        if found:
            return found
        for nested in value.values():
            found = _find_json_record(nested)
            if found:
                return found
    elif isinstance(value, list):
        for nested in reversed(value):
            found = _find_json_record(nested)
            if found:
                return found
    return None


def _parse_table_rows(rows: list[list[str]]) -> dict[str, Any] | None:
    if len(rows) < 2:
        return None
    headers = [_key(cell) for cell in rows[0]]
    if any(any(alias in header for alias in aliases) for header in headers for aliases in FIELD_ALIASES.values()):
        for row in reversed(rows[1:]):
            found = _extract_mapping(dict(zip(headers, row)))
            if found:
                return found
    for row in reversed(rows):
        if len(row) >= 2:
            label = _key(row[0])
            for field, aliases in FIELD_ALIASES.items():
                if label in aliases:
                    number = _number(row[-1])
                    if number is not None:
                        return {field: number}
    return None


def parse_grid_payload(content: str, content_type: str = "") -> dict[str, Any]:
    """Normalize common public JSON, CSV, or HTML-table grid data into MW fields."""
    media_type = content_type.lower()
    parsed: dict[str, Any] | None = None
    if "json" in media_type or content.lstrip().startswith(("{", "[")):
        try:
            parsed = _find_json_record(json.loads(content))
        except (json.JSONDecodeError, TypeError):
            parsed = None
    if parsed is None and ("csv" in media_type or "," in content.splitlines()[0] if content.splitlines() else False):
        try:
            rows = list(csv.reader(io.StringIO(content)))
            parsed = _parse_table_rows(rows)
        except csv.Error:
            parsed = None
    if parsed is None and ("html" in media_type or "<table" in content.lower()):
        parser = _TableParser()
        parser.feed(content)
        for table in reversed(parser.tables):
            parsed = _parse_table_rows(table)
            if parsed:
                break
    if not parsed:
        raise ValueError("Could not find generation or demand fields in the source response")
    # Calculate imports if components (India, Nepal, Adani) are provided separately
    import_subtotal = sum(
        val
        for val in (parsed.get("india_mw"), parsed.get("nepal_mw"), parsed.get("adani_mw"))
        if val is not None
    )
    if import_subtotal > 0 and not parsed.get("imports_mw"):
        parsed["imports_mw"] = import_subtotal

    if "generation_mw" not in parsed:
        fuels = [
            parsed.get(f"{fuel}_mw")
            for fuel in ("gas", "liquid_fuel", "coal", "solar", "hydro", "wind", "imports")
        ]
        if any(value is not None for value in fuels):
            parsed["generation_mw"] = sum(value or 0 for value in fuels)
    if "generation_mw" not in parsed and "demand_mw" not in parsed:
        raise ValueError("The source response contains no usable MW readings")

    # In national grid telemetry, generation matches active demand load
    if "demand_mw" not in parsed and "generation_mw" in parsed:
        parsed["demand_mw"] = parsed["generation_mw"]

    parsed.setdefault("observed_at", datetime.now(timezone.utc).isoformat())
    parsed["source"] = "pgcb"
    return parsed


def parse_grid_history_csv(content: str) -> list[dict[str, Any]]:
    """Parse an exported time-series CSV containing timestamped MW columns."""
    records: list[dict[str, Any]] = []
    for row in csv.DictReader(io.StringIO(content)):
        normalized = {_key(key): value for key, value in row.items() if key}
        reading = _extract_mapping(normalized)
        if not reading:
            continue
        observed_at = reading.get("observed_at")
        if not observed_at:
            raise ValueError("Every historical CSV row must include a timestamp/date column")
        try:
            parsed_at = datetime.fromisoformat(str(observed_at).replace("Z", "+00:00"))
        except ValueError as exc:
            raise ValueError(f"Invalid historical timestamp: {observed_at}") from exc
        if parsed_at.tzinfo is None:
            parsed_at = parsed_at.replace(tzinfo=ZoneInfo(settings.grid_source_timezone))
        reading["observed_at"] = parsed_at.isoformat()
        reading["source"] = "pgcb"
        records.append(reading)
    if not records:
        raise ValueError("No timestamped generation or demand rows found in CSV")
    return records


async def fetch_grid_reading(url: str = "", timeout_seconds: float = 20) -> dict[str, Any]:
    target_url = url or settings.grid_source_url

    # Automatic Supabase integration
    if not target_url and settings.supabase_url:
        target_url = (
            f"{settings.supabase_url.rstrip('/')}/rest/v1/{settings.supabase_table}"
            "?select=*&order=datetime.desc&limit=1"
        )

    if not target_url:
        raise ValueError("Neither GRID_SOURCE_URL nor SUPABASE_URL is configured")

    headers = {"User-Agent": "GridPulse-Research-Dashboard/1.0"}
    if ("supabase.co" in target_url or settings.supabase_url in target_url) and settings.supabase_key:
        headers["apikey"] = settings.supabase_key
        headers["Authorization"] = f"Bearer {settings.supabase_key}"

    async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=True) as client:
        response = await client.get(target_url, headers=headers)
        response.raise_for_status()

    parsed = parse_grid_payload(response.text, response.headers.get("content-type", ""))
    if "supabase.co" in target_url:
        parsed["source"] = "pgcb_supabase"
    return parsed


async def fetch_supabase_history(limit: int = 500, timeout_seconds: float = 30) -> list[dict[str, Any]]:
    """Fetch recent historical demand records from Supabase for model training."""
    if not settings.supabase_url:
        return []
    target_url = (
        f"{settings.supabase_url.rstrip('/')}/rest/v1/{settings.supabase_table}"
        f"?select=*&order=datetime.desc&limit={limit}"
    )
    headers = {"User-Agent": "GridPulse-Research-Dashboard/1.0"}
    if settings.supabase_key:
        headers["apikey"] = settings.supabase_key
        headers["Authorization"] = f"Bearer {settings.supabase_key}"

    try:
        async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=True) as client:
            response = await client.get(target_url, headers=headers)
            if response.status_code != 200:
                return []
            data = response.json()
            if not isinstance(data, list):
                return []
    except Exception as exc:
        logger.warning("Could not fetch historical records from Supabase: %s", exc)
        return []

    records = []
    for item in reversed(data):
        try:
            norm = parse_grid_payload(json.dumps(item), "application/json")
            records.append({
                "observed_at": norm["observed_at"],
                "demand_mw": norm.get("demand_mw") or norm.get("generation_mw"),
                "generation_mw": norm.get("generation_mw"),
            })
        except Exception:
            continue
    return records
