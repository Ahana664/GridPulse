from fastapi.testclient import TestClient

from app.main import app


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
