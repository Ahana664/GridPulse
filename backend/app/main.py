from __future__ import annotations

import asyncio
import logging
import time
from contextlib import asynccontextmanager, suppress
from datetime import datetime, timezone
from typing import Any, Literal
from zoneinfo import ZoneInfo

import httpx
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from app.ai_advisor import analyze_grid
from app.database import close_database, get_forecast_training_data, get_grid_hierarchy, get_historical_context, get_national_history, save_national_reading, save_national_readings, save_snapshot, start_database
from app.forecasting import forecast_demand, get_forecast_model_name, set_historical_demand
from app.grid_hierarchy import ALL_GRID_NODES, NATIONAL_NODE
from app.live_data import fetch_grid_reading, fetch_supabase_history
from app.safety import validate_flow_proposal
from app.settings import settings
from app.simulator import GridSimulator

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
grid = GridSimulator()
database_connected = False
live_source_last_success: str | None = None
live_source_error: str | None = None
last_snapshot_persisted = 0.0
supabase_history_cache: list[dict[str, Any]] = []


def _safe_source_error(exc: Exception) -> str:
    """Return actionable source errors without exposing request URLs or credentials."""
    if isinstance(exc, ValueError):
        return str(exc)
    response = getattr(exc, "response", None)
    if response is not None:
        return f"The configured live source returned HTTP {response.status_code}; check its table, API key, and read permissions."
    if isinstance(exc, httpx.TimeoutException):
        return "The configured live source timed out; check network access and try again."
    return "Unable to fetch or parse the configured source; check backend logs and source format."


class ScenarioRequest(BaseModel):
    scenario: Literal["heatwave", "demand_spike", "solar_failure", "node_failure"]


class ReportRequest(BaseModel):
    report_type: str = Field(default="performance", pattern="^(performance|analytics|alerts)$")


class SafetyProposal(BaseModel):
    connection_id: str = Field(min_length=1)
    proposed_mw: float = Field(ge=0)


class WebSocketHub:
    def __init__(self) -> None:
        self.clients: set[WebSocket] = set()

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        self.clients.add(websocket)

    def disconnect(self, websocket: WebSocket) -> None:
        self.clients.discard(websocket)

    async def broadcast(self, message: dict[str, Any]) -> None:
        disconnected: list[WebSocket] = []
        for client in self.clients.copy():
            try:
                await client.send_json(message)
            except Exception:
                disconnected.append(client)
        for client in disconnected:
            self.disconnect(client)


hub = WebSocketHub()


async def telemetry_loop() -> None:
    global last_snapshot_persisted
    while True:
        snapshot = grid.tick()
        now = time.monotonic()
        if now - last_snapshot_persisted >= settings.grid_persist_interval_seconds:
            await save_snapshot(snapshot)
            last_snapshot_persisted = now
        await hub.broadcast({"type": "snapshot", "data": snapshot})
        await asyncio.sleep(max(1.0, settings.tick_seconds))


async def live_source_loop() -> None:
    global live_source_last_success, live_source_error, supabase_history_cache
    while True:
        try:
            reading = await fetch_grid_reading(settings.grid_source_url)
            try:
                parsed_time = datetime.fromisoformat(str(reading["observed_at"]).replace("Z", "+00:00"))
                if parsed_time.tzinfo is None:
                    reading["observed_at"] = parsed_time.replace(tzinfo=ZoneInfo(settings.grid_source_timezone)).isoformat()
            except (TypeError, ValueError):
                reading["source_timestamp"] = reading.get("observed_at")
                reading["observed_at"] = datetime.now(timezone.utc).isoformat()
            grid.set_national_reading(reading)
            await save_national_reading(reading)
            training_data = await get_forecast_training_data()
            if not training_data:
                supabase_history_cache = await fetch_supabase_history()
                training_data = supabase_history_cache
            if training_data:
                await asyncio.to_thread(set_historical_demand, training_data)
            live_source_last_success = datetime.now(timezone.utc).isoformat()
            live_source_error = None
            logger.info("Refreshed national grid source data")
        except Exception as exc:
            live_source_error = _safe_source_error(exc)
            logger.error("National grid source polling failed (%s)", type(exc).__name__)
        await asyncio.sleep(settings.grid_source_poll_seconds)


@asynccontextmanager
async def lifespan(_: FastAPI):
    global database_connected, supabase_history_cache
    database_connected = await start_database()
    supabase_history_cache = await fetch_supabase_history()
    if database_connected and supabase_history_cache:
        await save_national_readings(supabase_history_cache)
    training_data = await get_forecast_training_data()
    if not training_data:
        training_data = supabase_history_cache
    if training_data:
        await asyncio.to_thread(set_historical_demand, training_data)
    task = asyncio.create_task(telemetry_loop(), name="grid-telemetry-simulator")
    source_task = (
        asyncio.create_task(live_source_loop(), name="national-grid-source-poller")
        if (settings.grid_source_url or settings.supabase_url)
        else None
    )
    try:
        yield
    finally:
        task.cancel()
        with suppress(asyncio.CancelledError):
            await task
        if source_task is not None:
            source_task.cancel()
            with suppress(asyncio.CancelledError):
                await source_task
        await close_database()


app = FastAPI(
    title=settings.app_name,
    description="Simulated smart-grid telemetry, forecasting, safety validation, and scenario analysis.",
    version="1.0.0",
    lifespan=lifespan,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


@app.get("/api/v1/health")
async def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "service": "gridpulse-api",
        "nodes": len(grid.nodes),
        "database": "connected" if database_connected else "in-memory",
        "nationalSource": "configured" if settings.grid_source_url or settings.supabase_url else "not-configured",
        "nationalSourceType": "supabase" if settings.supabase_url else "http" if settings.grid_source_url else "none",
        "geminiConfigured": bool(settings.gemini_api_key),
        "nationalSourceLastSuccess": live_source_last_success,
        "websocketClients": len(hub.clients),
    }


@app.get("/api/v1/state")
async def get_state() -> dict[str, Any]:
    return grid.snapshot()


@app.get("/api/v1/live-data")
async def get_live_data_status() -> dict[str, Any]:
    snapshot = grid.snapshot()
    reading = snapshot.get("nationalData")
    last_success = datetime.fromisoformat(live_source_last_success) if live_source_last_success else None
    stale_after = settings.grid_source_poll_seconds * 2
    source_is_fresh = bool(last_success and (datetime.now(timezone.utc) - last_success).total_seconds() <= stale_after)
    if reading and reading.get("observed_at"):
        try:
            reading_time = datetime.fromisoformat(str(reading["observed_at"]).replace("Z", "+00:00"))
            source_is_fresh = source_is_fresh and (datetime.now(timezone.utc) - reading_time).total_seconds() <= stale_after
        except ValueError:
            source_is_fresh = False
    is_configured = bool(settings.grid_source_url or settings.supabase_url)
    return {
        "configured": is_configured,
        "sourceType": "supabase" if settings.supabase_url else "http" if settings.grid_source_url else "none",
        "status": "live" if source_is_fresh else "stale" if live_source_last_success else "waiting" if is_configured else "not-configured",
        "lastSuccess": live_source_last_success,
        "lastError": live_source_error,
        "reading": reading,
        "provenance": snapshot.get("dataProvenance"),
        "demandScale": snapshot.get("nationalDemandScale"),
        "generationScale": snapshot.get("nationalGenerationScale"),
        "pollIntervalSeconds": settings.grid_source_poll_seconds,
    }


@app.get("/api/v1/real-data/dashboard")
async def get_real_dashboard_data() -> dict[str, Any]:
    """Return PGCB national observations and forecasts trained only on PGCB history."""
    history = await get_national_history(limit=500)
    if not history:
        history = list(supabase_history_cache)[-500:]
    latest = grid.snapshot().get("nationalData")
    if latest is None and history:
        latest = history[-1]
    if latest is not None:
        latest = dict(latest)
        if latest.get("demand_is_inferred"):
            latest["demand_mw"] = None

    forecast: list[dict[str, Any]] = []
    model_name = get_forecast_model_name()
    forecast_target = "generation" if (latest or {}).get("demand_is_inferred") else "demand"
    current_demand = (latest or {}).get("generation_mw") if forecast_target == "generation" else (latest or {}).get("demand_mw")
    forecast_available = bool(
        current_demand
        and model_name.endswith("-historical")
        and len(history) >= 168
    )
    if forecast_available:
        forecast = forecast_demand(
            float(current_demand),
            datetime.now(timezone.utc).hour,
            horizon=24,
            national_current_demand_mw=float(current_demand),
        )

    return {
        "mode": "real",
        "source": "pgcb_supabase" if settings.supabase_url else "pgcb",
        "databaseConnected": database_connected,
        "latest": latest,
        "history": history,
        "historyCount": len(history),
        "historyStorage": "postgresql" if database_connected and history else "supabase-rest" if history else "none",
        "forecast": forecast,
        "forecastTarget": forecast_target,
        "forecastAvailable": forecast_available,
        "forecastModel": model_name if forecast_available else "unavailable-insufficient-real-history",
        "forecastNotice": None if forecast_available else "A real-data forecast requires at least 168 usable hourly source records.",
    }


def _static_hierarchy(parent_node_id: str, national_reading: dict[str, Any] | None) -> dict[str, Any]:
    """Return known topology labels only; never invent child measurements."""
    nodes_by_id = {node["node_id"]: node for node in ALL_GRID_NODES}
    raw_parent = nodes_by_id.get(parent_node_id)
    if raw_parent is None:
        return {"database": "disconnected", "parent": None, "nodes": [], "topologySource": "static-metadata"}

    def as_node(raw: dict[str, Any], reading: dict[str, Any] | None = None) -> dict[str, Any]:
        reading = reading or {}
        child_count = sum(node.get("parent_node_id") == raw["node_id"] for node in ALL_GRID_NODES)
        return {
            **raw,
            "child_count": child_count,
            "observed_at": reading.get("observed_at"),
            "source": reading.get("source"),
            **{
                key: reading.get(key)
                for key in (
                    "generation_mw", "demand_mw", "gas_mw", "liquid_fuel_mw", "coal_mw",
                    "solar_mw", "hydro_mw", "wind_mw", "imports_mw", "adani_mw",
                )
            },
            "voltage_kv": None,
            "load_percent": None,
            "capacity_mw": None,
            "status": None,
            "measured": bool(reading.get("observed_at")),
            "estimated": False,
            "estimated_generation_mw": None,
            "estimated_demand_mw": None,
        }

    parent_data = national_reading if parent_node_id == NATIONAL_NODE["node_id"] else None
    parent = as_node(raw_parent, parent_data)
    children = [
        as_node(node)
        for node in ALL_GRID_NODES
        if node.get("parent_node_id") == parent_node_id
    ]
    return {
        "database": "disconnected",
        "parent": parent,
        "nodes": children,
        "allocation": {
            "ready": False,
            "method": "topology-only-no-estimates",
            "weight_sum": sum(float(node.get("distribution_weight") or 0) for node in children),
            "message": "PostgreSQL is offline. Showing topology metadata only; child readings are not estimated.",
        },
        "topologySource": "static-metadata",
    }


def _summarize_supabase_history(records: list[dict[str, Any]]) -> dict[str, Any]:
    """Build a transient source summary when PostgreSQL persistence is unavailable."""
    cutoff = datetime.now(timezone.utc).timestamp() - 180 * 24 * 60 * 60
    rows: list[dict[str, Any]] = []
    for row in records:
        try:
            observed = datetime.fromisoformat(str(row["observed_at"]).replace("Z", "+00:00"))
            if observed.tzinfo is None:
                observed = observed.replace(tzinfo=timezone.utc)
            if observed.timestamp() >= cutoff:
                rows.append({**row, "_observed": observed})
        except (KeyError, TypeError, ValueError):
            continue
    demands = [
        float(row["demand_mw"])
        for row in rows
        if row.get("demand_mw") is not None and not row.get("demand_is_inferred", False)
    ]
    generations = [float(row["generation_mw"]) for row in rows if row.get("generation_mw") is not None]
    renewables = [
        (float(row.get("solar_mw") or 0) + float(row.get("wind_mw") or 0)) / float(row["generation_mw"])
        for row in rows if row.get("generation_mw") and float(row["generation_mw"]) > 0
    ]
    ordered = sorted(rows, key=lambda row: row["_observed"])
    night = [float(row["demand_mw"]) for row in rows if row.get("demand_mw") is not None and not row.get("demand_is_inferred", False) and row["_observed"].hour < 6]
    evening = [float(row["demand_mw"]) for row in rows if row.get("demand_mw") is not None and not row.get("demand_is_inferred", False) and 18 <= row["_observed"].hour <= 21]
    return {
        "sample_count": len(rows),
        "demand_available": bool(demands),
        "avg_demand_mw": round(sum(demands) / len(demands), 1) if demands else None,
        "max_demand_mw": round(max(demands), 1) if demands else None,
        "night_trough_mw": round(sum(night) / len(night), 1) if night else None,
        "evening_peak_mw": round(sum(evening) / len(evening), 1) if evening else None,
        "renewable_share_percent": round(sum(renewables) / len(renewables) * 100, 2) if renewables else None,
        "avg_generation_mw": round(sum(generations) / len(generations), 1) if generations else None,
        "max_generation_mw": max(generations) if generations else None,
        "recent_24h": [
            {
                **{key: value for key, value in row.items() if key != "_observed"},
                "actual_mw": row.get("generation_mw") if row.get("demand_is_inferred") else row.get("demand_mw"),
                "demand_mw": None if row.get("demand_is_inferred") else row.get("demand_mw"),
            }
            for row in ordered[-24:]
        ],
        "history_source": "supabase",
        "persistence_available": False,
    }


@app.post("/api/v1/live-data/sync")
async def trigger_live_data_sync() -> dict[str, Any]:
    """Force an immediate pull from the live Supabase / PGCB source."""
    global live_source_last_success, live_source_error, supabase_history_cache
    try:
        from app.live_data import fetch_grid_reading
        reading = await fetch_grid_reading()
        grid.set_national_reading(reading)
        await save_national_reading(reading)
        if reading.get("source") == "pgcb_supabase":
            supabase_history_cache = [
                row for row in supabase_history_cache
                if row.get("observed_at") != reading.get("observed_at")
            ]
            supabase_history_cache.append({
                **reading,
                "demand_mw": reading.get("demand_mw") or reading.get("generation_mw"),
                "source": "pgcb",
            })
            supabase_history_cache = sorted(
                supabase_history_cache,
                key=lambda row: str(row.get("observed_at", "")),
            )[-500:]
        live_source_last_success = datetime.now(timezone.utc).isoformat()
        live_source_error = None
        return {"status": "ok", "reading": reading}
    except Exception as exc:
        live_source_error = _safe_source_error(exc)
        raise HTTPException(status_code=502, detail=live_source_error)


@app.get("/api/v1/grid/hierarchy")
async def get_grid_hierarchy_view(parent_node_id: str = "BD-NATIONAL") -> dict[str, Any]:
    """Return direct children and latest source records at one hierarchy level."""
    if not database_connected:
        return _static_hierarchy(parent_node_id, grid.snapshot().get("nationalData"))
    return await get_grid_hierarchy(parent_node_id)


@app.get("/api/v1/history/summary")
async def get_history_summary() -> dict[str, Any]:
    summary = await get_historical_context()
    if summary.get("sample_count", 0):
        summary["history_source"] = "postgresql"
        summary["persistence_available"] = True
        return summary
    if supabase_history_cache:
        return _summarize_supabase_history(supabase_history_cache)
    return {**summary, "history_source": "none", "persistence_available": database_connected}


@app.post("/api/v1/ai/analyze")
async def run_ai_analysis(mode: Literal["real", "simulated"] = "simulated") -> dict[str, Any]:
    if not settings.gemini_api_key:
        raise HTTPException(status_code=503, detail="Gemini is not configured. Set GEMINI_API_KEY on the backend.")
    try:
        if mode == "real":
            real = await get_real_dashboard_data()
            if not real.get("latest"):
                raise HTTPException(status_code=503, detail="No real PGCB/Supabase reading is available for analysis.")
            latest = real["latest"]
            analysis_snapshot = {
                "mode": "real national PGCB data",
                "summary": {
                    "generation_mw": latest.get("generation_mw"),
                    "demand_mw": latest.get("demand_mw"),
                    "supply_balance_mw": (
                        float(latest["generation_mw"]) - float(latest["demand_mw"])
                        if latest.get("generation_mw") is not None and latest.get("demand_mw") is not None
                        else None
                    ),
                },
                "nationalData": latest,
                "history": real["history"][-24:],
                "alerts": [],
                "connections": [],
            }
            historical = await get_historical_context()
            if historical.get("sample_count", 0) == 0:
                historical = {
                    **historical,
                    "sample_count": real["historyCount"],
                    "recent_24h": real["history"][-24:],
                }
        else:
            analysis_snapshot = {
                **grid.snapshot(),
                "mode": "simulated 20-node grid",
                "nationalData": None,
            }
            historical = {"sample_count": 0, "recent_24h": []}
        result = await analyze_grid(
            api_key=settings.gemini_api_key,
            model=settings.gemini_model,
            snapshot=analysis_snapshot,
            historical=historical,
            mode=mode,
        )
        return result
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("Gemini advisory analysis failed (%s)", type(exc).__name__)
        if isinstance(exc, httpx.HTTPStatusError):
            if exc.response.status_code in {401, 403}:
                detail = "Gemini rejected the backend API key; verify GEMINI_API_KEY and that the key has Gemini API access."
            elif exc.response.status_code == 404:
                detail = "The configured Gemini model is unavailable; verify GEMINI_MODEL for this API key."
            elif exc.response.status_code == 429:
                detail = "Gemini rate limit or quota reached; check the key's quota and try again later."
            else:
                detail = f"Gemini returned HTTP {exc.response.status_code}; check backend logs and model configuration."
        else:
            detail = "The AI advisory service could not complete the request; check backend connectivity and logs."
        raise HTTPException(status_code=502, detail=detail) from exc


@app.get("/api/v1/telemetry")
async def get_telemetry(limit: int = 48) -> dict[str, Any]:
    bounded_limit = min(max(limit, 1), 96)
    return {"items": list(grid.history)[-bounded_limit:]}


@app.get("/api/v1/alerts")
async def get_alerts() -> dict[str, Any]:
    alerts = grid.snapshot()["alerts"]
    return {"items": alerts, "total": len(alerts)}


@app.get("/api/v1/safety")
async def get_safety() -> dict[str, Any]:
    checks = grid.snapshot()["safetyChecks"]
    return {
        "checks": checks,
        "passed": sum(check["status"] == "pass" for check in checks),
        "warnings": sum(check["status"] == "warning" for check in checks),
        "violations": sum(check["status"] == "critical" for check in checks),
    }


@app.post("/api/v1/safety/validate")
async def validate_safety_proposal(request: SafetyProposal) -> dict[str, Any]:
    result = validate_flow_proposal(grid.connections, request.connection_id, request.proposed_mw)
    if result["capacityMw"] is None:
        raise HTTPException(status_code=404, detail="Unknown grid connection")
    return result


@app.post("/api/v1/simulations")
async def run_simulation(request: ScenarioRequest) -> dict[str, Any]:
    snapshot = grid.run_scenario(request.scenario)
    await save_snapshot(snapshot)
    await hub.broadcast({"type": "snapshot", "data": snapshot})
    return snapshot


@app.post("/api/v1/simulations/reset")
async def reset_simulation() -> dict[str, Any]:
    snapshot = grid.reset_scenario()
    await save_snapshot(snapshot)
    await hub.broadcast({"type": "snapshot", "data": snapshot})
    return snapshot


@app.post("/api/v1/reports/generate")
async def generate_report(request: ReportRequest) -> dict[str, Any]:
    history = [{"time": item["time"], "load": item["actual"]} for item in grid.history]
    if settings.celery_enabled:
        try:
            from app.tasks import generate_report as generate_report_task

            task = generate_report_task.delay(request.report_type, history)
            return {"taskId": task.id, "status": "queued", "type": request.report_type}
        except Exception:
            logger.exception("Celery unavailable; generating report inline")
    return {"status": "ready", "report": grid.report(request.report_type)}


@app.get("/api/v1/reports/tasks/{task_id}")
async def get_report_task(task_id: str) -> dict[str, Any]:
    if not settings.celery_enabled:
        raise HTTPException(status_code=404, detail="Background reports are not enabled")
    from app.celery_app import celery_app

    result = celery_app.AsyncResult(task_id)
    response: dict[str, Any] = {"taskId": task_id, "status": result.status.lower()}
    if result.successful():
        response["report"] = result.result
    elif result.failed():
        response["error"] = "Report generation failed"
    return response


@app.websocket("/api/v1/ws/live")
async def live_updates(websocket: WebSocket) -> None:
    await hub.connect(websocket)
    try:
        await websocket.send_json({"type": "snapshot", "data": grid.snapshot()})
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        hub.disconnect(websocket)
    except Exception:
        hub.disconnect(websocket)
        logger.exception("WebSocket disconnected unexpectedly")
