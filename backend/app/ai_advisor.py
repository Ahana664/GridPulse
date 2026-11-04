from __future__ import annotations

import json
import re
from typing import Any

import httpx

from app.safety import validate_flow_proposal


def _decode_advisory(text: str) -> dict[str, Any]:
    """Decode JSON even if a model surrounds it with prose or Markdown fences."""
    candidate = text.strip()
    candidate = re.sub(r"^```(?:json)?\s*|\s*```$", "", candidate, flags=re.IGNORECASE)
    try:
        value = json.loads(candidate)
        if isinstance(value, dict):
            return value
    except json.JSONDecodeError:
        pass

    start = candidate.find("{")
    if start >= 0:
        decoder = json.JSONDecoder()
        try:
            value, _ = decoder.raw_decode(candidate[start:])
            if isinstance(value, dict):
                return value
        except json.JSONDecodeError:
            pass
    raise ValueError("Gemini returned incomplete or invalid advisory JSON")


async def analyze_grid(
    *,
    api_key: str,
    model: str,
    snapshot: dict[str, Any],
    historical: dict[str, Any],
    mode: str = "simulated",
) -> dict[str, Any]:
    """Ask Gemini for advisory text; validate any proposed virtual flow locally."""
    macro = snapshot.get("nationalData") or {}
    prompt = f"""You are an advisory analyst for GridPulse, an academic grid simulation. This is read-only decision support, never an operating command.

Analysis mode: {mode}. Use only the selected mode's inputs. In real mode, do not refer to simulated nodes, simulation alerts, or modeled line/voltage metrics; analyze only national PGCB readings and actual history. When demand_is_inferred is true, the source did not report demand: discuss and forecast generation instead, and do not claim a measured demand or supply balance. In simulated mode, analyze only the virtual-grid snapshot and clearly label it simulated.
Selected-mode summary: {json.dumps(snapshot.get('summary', {}), separators=(',', ':'))}
Latest national record, if relevant to this mode: {json.dumps(macro, separators=(',', ':'))}
Historical-data summary: {json.dumps({key: value for key, value in historical.items() if key != 'recent_24h'}, separators=(',', ':'))}
Recent records relevant to the selected mode: {json.dumps(historical.get('recent_24h', [])[-24:], separators=(',', ':'))}
Recent selected-mode trend: {json.dumps(snapshot.get('history', [])[-24:], separators=(',', ':'))}
Alerts relevant to the selected mode: {json.dumps(snapshot.get('alerts', [])[:15], separators=(',', ':'))}

Return only one complete JSON object, with no prose or Markdown, using exactly these fields: forecast_3_6h (one short string), anomalies (array with at most 3 short strings), recommendation (one short string), suggested_flow (null unless evidence supports a simulated line proposal). Keep the whole JSON under 180 words. Do not repeat the schema or put JSON inside a field. Do not invent historical facts. The recommendation concerns only this simulated grid; never claim to control real electricity. The backend checks any proposal and never applies it."""
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            endpoint,
            headers={"x-goog-api-key": api_key},
            json={
                "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                "generationConfig": {
                    "temperature": 0.2,
                    "maxOutputTokens": 1400,
                    "responseMimeType": "application/json",
                    "thinkingConfig": {"thinkingLevel": "low"},
                },
            },
        )
        response.raise_for_status()
        payload = response.json()
    try:
        text = payload["candidates"][0]["content"]["parts"][0]["text"].strip()
    except (KeyError, IndexError, TypeError) as exc:
        raise ValueError("Gemini returned no analysis text") from exc

    result = _decode_advisory(text)

    flow = result.get("suggested_flow") if mode == "simulated" else None
    safety: dict[str, Any] = {
        "accepted": None,
        "message": "No line-flow proposal was returned.",
        "gridActionTaken": False,
    }
    if isinstance(flow, dict):
        try:
            safety = validate_flow_proposal(
                snapshot.get("connections", []),
                str(flow["connection_id"]),
                float(flow["proposed_mw"]),
            )
        except (KeyError, TypeError, ValueError):
            safety = {
                "accepted": False,
                "message": "Malformed flow proposal; blocked by the deterministic safety layer.",
                "gridActionTaken": False,
            }

    forecast = str(result.get("forecast_3_6h", "")).strip()
    anomalies = result.get("anomalies", [])
    if not isinstance(anomalies, list):
        anomalies = [str(anomalies)] if anomalies else []
    anomalies = [str(item).strip() for item in anomalies if str(item).strip()][:3]
    recommendation = str(result.get("recommendation", "")).strip()
    parts = [f"3–6h outlook: {forecast}" if forecast else ""]
    if anomalies:
        parts.append(f"Anomalies: {'; '.join(anomalies)}")
    if recommendation:
        parts.append(f"Recommendation: {recommendation}")
    return {
        "analysis": "\n".join(part for part in parts if part) or "No advisory text was returned.",
        "mode": mode,
        "forecast": forecast,
        "anomalies": anomalies,
        "recommendation": recommendation,
        "suggestedFlow": flow if isinstance(flow, dict) else None,
        "safetyValidation": safety,
        "model": model,
        "historicalSamples": historical.get("sample_count", 0),
        "historicalWindowDays": 180,
        "gridActionTaken": False,
        "safetyNotice": "Any flow is a simulated proposal only. The safety result does not execute or apply it.",
    }
