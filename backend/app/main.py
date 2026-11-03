from __future__ import annotations

import asyncio
import logging
import time
from contextlib import asynccontextmanager, suppress
from datetime import datetime, timezone
from typing import Any, Literal
from zoneinfo import ZoneInfo

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from app.ai_advisor import analyze_grid
from app.database import close_database, get_forecast_training_data, get_grid_hierarchy, get_historical_context, save_national_reading, save_snapshot, start_database
from app.forecasting import set_historical_demand
from app.live_data import fetch_grid_reading
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
    global live_source_last_success, live_source_error
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
            if training_data:
                await asyncio.to_thread(set_historical_demand, training_data)
            live_source_last_success = datetime.now(timezone.utc).isoformat()
            live_source_error = None
            logger.info("Refreshed national grid source data")
        except Exception as exc:
            live_source_error = "Unable to fetch or parse the configured source; check backend logs and source format."
            logger.error("National grid source polling failed (%s)", type(exc).__name__)
        await asyncio.sleep(settings.grid_source_poll_seconds)


@asynccontextmanager
async def lifespan(_: FastAPI):
    global database_connected
    database_connected = await start_database()
    training_data = await get_forecast_training_data()
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
        "nationalSource": "configured" if settings.grid_source_url else "not-configured",
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


@app.post("/api/v1/live-data/sync")
async def trigger_live_data_sync() -> dict[str, Any]:
    """Force an immediate pull from the live Supabase / PGCB source."""
    global live_source_last_success, live_source_error
    try:
        from app.live_data import fetch_grid_reading
        reading = await fetch_grid_reading()
        grid.set_national_reading(reading)
        await save_national_reading(reading)
        live_source_last_success = datetime.now(timezone.utc).isoformat()
        live_source_error = None
        return {"status": "ok", "reading": reading}
    except Exception as exc:
        live_source_error = str(exc)
        raise HTTPException(status_code=502, detail=f"Failed to sync live data: {exc}")


@app.get("/api/v1/grid/hierarchy")
async def get_grid_hierarchy_view(parent_node_id: str = "BD-NATIONAL") -> dict[str, Any]:
    """Return direct children and latest source records at one hierarchy level."""
    return await get_grid_hierarchy(parent_node_id)


@app.get("/api/v1/history/summary")
async def get_history_summary() -> dict[str, Any]:
    return await get_historical_context()


@app.post("/api/v1/ai/analyze")
async def run_ai_analysis() -> dict[str, Any]:
    if not settings.gemini_api_key:
        raise HTTPException(status_code=503, detail="Gemini is not configured. Set GEMINI_API_KEY on the backend.")
    try:
        return await analyze_grid(
            api_key=settings.gemini_api_key,
            model=settings.gemini_model,
            snapshot=grid.snapshot(),
            historical=await get_historical_context(),
        )
    except Exception as exc:
        logger.error("Gemini advisory analysis failed (%s)", type(exc).__name__)
        raise HTTPException(status_code=502, detail="The AI advisory service could not complete the request.") from exc


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
