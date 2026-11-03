from fastapi.testclient import TestClient

from app.main import app
from app.settings import settings


def test_state_endpoint_returns_complete_grid_snapshot() -> None:
    with TestClient(app) as client:
        response = client.get("/api/v1/state")
        assert response.status_code == 200
        payload = response.json()
        assert payload["summary"]["nodeCount"] == 20
        assert len(payload["nodes"]) == 20
        assert len(payload["forecast"]) == 24
        assert len(payload["safetyChecks"]) == 40


def test_scenario_endpoint_returns_impact_and_updates_grid() -> None:
    with TestClient(app) as client:
        response = client.post("/api/v1/simulations", json={"scenario": "solar_failure"})
        assert response.status_code == 200
        payload = response.json()
        assert payload["scenarioResult"]["name"] == "solar_failure"
        assert payload["scenarioResult"]["generationImpact"].startswith("-")
        assert payload["summary"]["frequency"] < 49.95


def test_unknown_scenario_is_rejected() -> None:
    with TestClient(app) as client:
        response = client.post("/api/v1/simulations", json={"scenario": "storm"})
        assert response.status_code == 422


def test_safety_endpoint_rejects_flow_over_line_capacity() -> None:
    with TestClient(app) as client:
        response = client.post(
            "/api/v1/safety/validate",
            json={"connection_id": "LINE-01", "proposed_mw": 1_500},
        )
        assert response.status_code == 200
        assert response.json()["accepted"] is False
        assert response.json()["gridActionTaken"] is False


def test_report_endpoint_summarizes_telemetry() -> None:
    with TestClient(app) as client:
        response = client.post("/api/v1/reports/generate", json={"report_type": "performance"})
        assert response.status_code == 200
        payload = response.json()
        assert payload["status"] == "ready"
        assert payload["report"]["summary"]["sampleCount"] > 0


def test_live_data_endpoint_reports_unconfigured_source() -> None:
    with TestClient(app) as client:
        response = client.get("/api/v1/live-data")
        assert response.status_code == 200
        payload = response.json()
        assert payload["configured"] is False
        assert payload["status"] == "not-configured"
        assert payload["provenance"] == "simulator-only"


def test_hierarchy_endpoint_is_database_sourced_and_never_uses_simulator() -> None:
    with TestClient(app) as client:
        response = client.get("/api/v1/grid/hierarchy")
        assert response.status_code == 200
        payload = response.json()
        assert payload["database"] in {"connected", "disconnected"}
        if payload["database"] == "disconnected":
            assert payload["nodes"] == []
            return
        assert payload["parent"]["node_id"] == "BD-NATIONAL"
        assert len(payload["nodes"]) == 8
        assert {node["tier"] for node in payload["nodes"]} == {"division"}
        assert all(node["measured"] is False for node in payload["nodes"])
        assert all(node["demand_mw"] is None and node["generation_mw"] is None for node in payload["nodes"])


def test_hierarchy_database_offline_does_not_return_simulator_nodes(monkeypatch) -> None:
    from app import database
    from app import main as main_module

    async def no_database() -> bool:
        return False

    monkeypatch.setattr(database, "engine", None)
    monkeypatch.setattr(main_module, "start_database", no_database)
    with TestClient(app) as client:
        response = client.get("/api/v1/grid/hierarchy")
        assert response.status_code == 200
        payload = response.json()
        assert payload == {"database": "disconnected", "parent": None, "nodes": []}


def test_ai_analysis_requires_backend_api_key(monkeypatch) -> None:
    monkeypatch.setattr(settings, "gemini_api_key", "")
    with TestClient(app) as client:
        response = client.post("/api/v1/ai/analyze")
        assert response.status_code == 503
        assert "GEMINI_API_KEY" in response.json()["detail"]
