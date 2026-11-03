from __future__ import annotations

import argparse
import asyncio
import json
from typing import Any

import httpx
import websockets
from sqlalchemy import text

from app import database


async def run_dry_run(api_base: str) -> list[str]:
    api_base = api_base.rstrip("/")
    ws_url = api_base.replace("https://", "wss://").replace("http://", "ws://") + "/ws/live"
    checks: list[str] = []

    async with httpx.AsyncClient(timeout=20) as client:
        health_response = await client.get(f"{api_base}/health")
        health_response.raise_for_status()
        health = health_response.json()
        assert health["database"] == "connected", f"Database reports {health['database']}"
        assert health["nodes"] == 20, f"Expected 20 nodes, got {health['nodes']}"
        checks.append("FastAPI health and PostgreSQL connection")

        state_response = await client.get(f"{api_base}/state")
        state_response.raise_for_status()
        state = state_response.json()
        assert len(state["nodes"]) == 20
        assert len(state["forecast"]) == 24
        assert len(state["safetyChecks"]) == 40
        checks.append("20-node snapshot, 24-hour forecast, and 40 safety checks")

        alerts_response = await client.get(f"{api_base}/alerts")
        alerts_response.raise_for_status()
        assert isinstance(alerts_response.json().get("items"), list)
        safety_response = await client.get(f"{api_base}/safety")
        safety_response.raise_for_status()
        assert safety_response.json()["passed"] + safety_response.json()["warnings"] + safety_response.json()["violations"] == 40
        telemetry_response = await client.get(f"{api_base}/telemetry?limit=48")
        telemetry_response.raise_for_status()
        assert len(telemetry_response.json()["items"]) > 0
        checks.append("Alerts, safety-summary, and recent telemetry read APIs")

        for scenario in ("heatwave", "demand_spike", "solar_failure", "node_failure"):
            response = await client.post(f"{api_base}/simulations", json={"scenario": scenario})
            response.raise_for_status()
            snapshot = response.json()
            assert snapshot["scenarioResult"]["name"] == scenario
        reset = await client.post(f"{api_base}/simulations/reset")
        reset.raise_for_status()
        assert reset.json()["scenario"] is None
        checks.append("Four scenario transitions and reset")

        connection = state["connections"][0]
        capacity = float(connection["capacity"])
        accepted = await client.post(
            f"{api_base}/safety/validate",
            json={"connection_id": connection["id"], "proposed_mw": capacity / 2},
        )
        accepted.raise_for_status()
        assert accepted.json()["accepted"] is True
        blocked = await client.post(
            f"{api_base}/safety/validate",
            json={"connection_id": connection["id"], "proposed_mw": capacity + 1},
        )
        blocked.raise_for_status()
        assert blocked.json()["accepted"] is False
        assert blocked.json()["gridActionTaken"] is False
        checks.append("Safety validator accepts within-limit and blocks over-limit flow")

        report_response = await client.post(
            f"{api_base}/reports/generate", json={"report_type": "performance"}
        )
        report_response.raise_for_status()
        report = report_response.json()
        if report["status"] == "queued":
            task_id = report["taskId"]
            for _ in range(10):
                task_response = await client.get(f"{api_base}/reports/tasks/{task_id}")
                task_response.raise_for_status()
                task = task_response.json()
                if task["status"] in {"success", "failure"}:
                    assert task["status"] == "success", task
                    break
                await asyncio.sleep(0.5)
            else:
                raise AssertionError("Celery report task did not finish in time")
        else:
            assert report["status"] == "ready"
        checks.append("Report generation workflow")

        live_data = await client.get(f"{api_base}/live-data")
        live_data.raise_for_status()
        historical = await client.get(f"{api_base}/history/summary")
        historical.raise_for_status()
        national_samples = historical.json().get("sample_count", 0)
        hierarchy_response = await client.get(
            f"{api_base}/grid/hierarchy",
            params={"parent_node_id": "BD-NATIONAL"},
        )
        hierarchy_response.raise_for_status()
        hierarchy = hierarchy_response.json()
        assert hierarchy["database"] == "connected"
        assert hierarchy["parent"]["tier"] == "national"
        assert len(hierarchy["nodes"]) == 8
        assert all(node["tier"] == "division" for node in hierarchy["nodes"])
        checks.append(
            "National-to-division hierarchy responds "
            f"({sum(node['measured'] for node in hierarchy['nodes'])}/8 actual readings, "
            f"{sum(node['estimated'] for node in hierarchy['nodes'])}/8 weighted estimates, "
            f"{national_samples} national-history samples)"
        )

    async with websockets.connect(ws_url, open_timeout=10, close_timeout=5) as socket:
        message = json.loads(await asyncio.wait_for(socket.recv(), timeout=10))
        assert message.get("type") == "snapshot"
        assert len(message["data"]["nodes"]) == 20
    checks.append("WebSocket initial snapshot delivery")

    if not await database.start_database():
        raise AssertionError("Could not connect to PostgreSQL for persisted-history check")
    try:
        if database.engine is None:
            raise AssertionError("Database engine was not initialized")
        async with database.engine.connect() as connection:
            result = await connection.execute(
                text(
                    """SELECT COUNT(*) AS rows,
                              COUNT(DISTINCT date_trunc('hour', observed_at)) AS hours,
                              COUNT(DISTINCT node_id) AS nodes
                       FROM telemetry
                       WHERE source = 'simulator'
                                                 AND observed_at >= now() - interval '72 hours'"""
                )
            )
            persisted = dict(result.mappings().one())
        assert int(persisted["hours"]) >= 48, f"Only {persisted['hours']} distinct hours persisted"
        assert int(persisted["nodes"]) == 20, f"Only {persisted['nodes']} unique nodes persisted"
        checks.append(
            f"PostgreSQL persisted 48h: {persisted['hours']} hourly buckets, "
            f"{persisted['rows']} node rows, {persisted['nodes']} nodes"
        )
    finally:
        await database.close_database()

    return checks


def main() -> None:
    parser = argparse.ArgumentParser(description="Exercise the GridPulse API, WebSocket, safety layer, reports, and PostgreSQL history.")
    parser.add_argument("--api-base", default="http://127.0.0.1:8000/api/v1")
    args = parser.parse_args()
    checks = asyncio.run(run_dry_run(args.api_base))
    print("GridPulse architecture dry run: PASS")
    for check in checks:
        print(f"PASS  {check}")
    print("NOTE  National source/Gemini calls are not asserted without authorized PGCB feed and API key.")


if __name__ == "__main__":
    main()
