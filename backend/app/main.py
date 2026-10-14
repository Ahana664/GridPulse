from __future__ import annotations

import asyncio
import logging
from contextlib import asynccontextmanager, suppress
from typing import Any, Literal

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from app.database import close_database, save_snapshot, start_database
from app.settings import settings
from app.simulator import GridSimulator

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
grid = GridSimulator()
database_connected = False


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
    while True:
        snapshot = grid.tick()
        await save_snapshot(snapshot)
        await hub.broadcast({"type": "snapshot", "data": snapshot})
        await asyncio.sleep(max(1.0, settings.tick_seconds))


@asynccontextmanager
async def lifespan(_: FastAPI):
    global database_connected
    database_connected = await start_database()
    task = asyncio.create_task(telemetry_loop(), name="grid-telemetry-simulator")
    try:
        yield
    finally:
        task.cancel()
        with suppress(asyncio.CancelledError):
            await task
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
        "websocketClients": len(hub.clients),
    }


@app.get("/api/v1/state")
async def get_state() -> dict[str, Any]:
    return grid.snapshot()


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
    connection = next(
        (line for line in grid.connections if line["id"] == request.connection_id),
        None,
    )
    if connection is None:
        raise HTTPException(status_code=404, detail="Unknown grid connection")
    within_limit = request.proposed_mw <= connection["capacity"]
    return {
        "connectionId": connection["id"],
        "proposedMw": request.proposed_mw,
        "capacityMw": connection["capacity"],
        "accepted": within_limit,
        "message": "Recommendation is within the engineering limit" if within_limit else "Recommendation exceeds the line capacity and must not be applied",
        "gridActionTaken": False,
    }


@app.post("/api/v1/simulations")
async def run_simulation(request: ScenarioRequest) -> dict[str, Any]:
    snapshot = grid.run_scenario(request.scenario)
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
