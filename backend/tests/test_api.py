from datetime import datetime, timedelta, timezone

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
            assert payload["topologySource"] == "static-metadata"
            assert len(payload["nodes"]) == 8
            assert all(node["measured"] is False for node in payload["nodes"])
            return
        assert payload["parent"]["node_id"] == "BD-NATIONAL"
        assert len(payload["nodes"]) == 8
        assert {node["tier"] for node in payload["nodes"]} == {"division"}
        assert all(node["measured"] is False for node in payload["nodes"])
        assert all(node["demand_mw"] is None and node["generation_mw"] is None for node in payload["nodes"])


def test_hierarchy_database_offline_returns_topology_without_fake_readings(monkeypatch) -> None:
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
        assert payload["database"] == "disconnected"
        assert payload["topologySource"] == "static-metadata"
        assert payload["parent"]["node_id"] == "BD-NATIONAL"
        assert len(payload["nodes"]) == 8
        assert all(node["measured"] is False for node in payload["nodes"])
        assert all(node["demand_mw"] is None and node["generation_mw"] is None for node in payload["nodes"])


def test_history_summary_uses_supabase_source_cache_without_database(monkeypatch) -> None:
    from app import main as main_module

    async def no_database() -> bool:
        return False

    async def source_history(limit: int = 500) -> list[dict[str, object]]:
        return [
            {"observed_at": "2026-11-03T10:00:00+00:00", "demand_mw": 12500.0, "demand_is_inferred": True, "generation_mw": 12500.0, "solar_mw": 100.0, "wind_mw": 25.0},
            {"observed_at": "2026-11-03T11:00:00+00:00", "demand_mw": 13500.0, "demand_is_inferred": True, "generation_mw": 13500.0, "solar_mw": 150.0, "wind_mw": 30.0},
        ]

    monkeypatch.setattr(main_module, "start_database", no_database)
    monkeypatch.setattr(main_module, "fetch_supabase_history", source_history)
    with TestClient(app) as client:
        response = client.get("/api/v1/history/summary")
        assert response.status_code == 200
        payload = response.json()
        assert payload["sample_count"] == 2
        assert payload["history_source"] == "supabase"
        assert payload["persistence_available"] is False
        assert payload["demand_available"] is False
        assert payload["avg_demand_mw"] is None
        assert payload["avg_generation_mw"] == 13000.0


def test_real_dashboard_uses_source_history_and_historical_forecast(monkeypatch) -> None:
    from app import main as main_module

    start = datetime(2026, 10, 25, tzinfo=timezone.utc)
    history = [
        {"observed_at": (start + timedelta(hours=hour)).isoformat(), "demand_mw": 12500.0 + hour, "generation_mw": 12500.0 + hour, "demand_is_inferred": True}
        for hour in range(200)
    ]
    forecast_args: dict[str, object] = {}

    def fake_forecast(*args, **kwargs):
        forecast_args.update(kwargs)
        return [{"time": "13:00", "load": 12345.0}]

    monkeypatch.setattr(main_module, "get_national_history", lambda limit=500: _async_value(history))
    monkeypatch.setattr(main_module, "get_forecast_model_name", lambda: "xgboost-historical")
    monkeypatch.setattr(main_module, "forecast_demand", fake_forecast)
    with TestClient(app) as client:
        response = client.get("/api/v1/real-data/dashboard")
        assert response.status_code == 200
        payload = response.json()
        assert payload["mode"] == "real"
        assert payload["latest"]["demand_mw"] is None
        assert payload["latest"]["demand_is_inferred"] is True
        assert payload["forecastTarget"] == "generation"
        assert payload["historyCount"] == 200
        assert payload["forecastAvailable"] is True
        assert payload["forecast"][0]["load"] == 12345.0
    assert forecast_args["national_current_demand_mw"] == history[-1]["generation_mw"]


async def _async_value(value):
    return value


def test_real_mode_ai_uses_national_only_snapshot(monkeypatch) -> None:
    from app import main as main_module

    captured: dict[str, object] = {}

    async def real_dashboard() -> dict[str, object]:
        return {
            "latest": {"observed_at": "2026-11-04T10:00:00+00:00", "demand_mw": 12500.0, "generation_mw": 12700.0, "source": "pgcb_supabase"},
            "history": [],
            "historyCount": 0,
        }

    async def historical_context() -> dict[str, object]:
        return {"sample_count": 0, "recent_24h": []}

    async def fake_analyze_grid(**kwargs) -> dict[str, object]:
        captured.update(kwargs)
        return {"analysis": "real mode", "mode": kwargs["mode"]}

    monkeypatch.setattr(settings, "gemini_api_key", "test-key")
    monkeypatch.setattr(main_module, "get_real_dashboard_data", real_dashboard)
    monkeypatch.setattr(main_module, "get_historical_context", historical_context)
    monkeypatch.setattr(main_module, "analyze_grid", fake_analyze_grid)
    with TestClient(app) as client:
        response = client.post("/api/v1/ai/analyze?mode=real")
        assert response.status_code == 200
        assert response.json()["mode"] == "real"
    assert captured["mode"] == "real"
    snapshot = captured["snapshot"]
    assert snapshot["mode"] == "real national PGCB data"
    assert snapshot["summary"]["demand_mw"] == 12500.0
    assert "nodes" not in snapshot


def test_simulated_mode_ai_uses_virtual_snapshot_only(monkeypatch) -> None:
    from app import main as main_module

    captured: dict[str, object] = {}

    async def fake_analyze_grid(**kwargs) -> dict[str, object]:
        captured.update(kwargs)
        return {"analysis": "simulation mode", "mode": kwargs["mode"]}

    monkeypatch.setattr(settings, "gemini_api_key", "test-key")
    monkeypatch.setattr(main_module, "analyze_grid", fake_analyze_grid)
    with TestClient(app) as client:
        response = client.post("/api/v1/ai/analyze?mode=simulated")
        assert response.status_code == 200
        assert response.json()["mode"] == "simulated"
    snapshot = captured["snapshot"]
    assert snapshot["mode"] == "simulated 20-node grid"
    assert len(snapshot["nodes"]) == 20
    assert snapshot["nationalData"] is None
    assert captured["historical"]["sample_count"] == 0


def test_ai_analysis_requires_backend_api_key(monkeypatch) -> None:
    monkeypatch.setattr(settings, "gemini_api_key", "")
    with TestClient(app) as client:
        response = client.post("/api/v1/ai/analyze")
        assert response.status_code == 503
        assert "GEMINI_API_KEY" in response.json()["detail"]
