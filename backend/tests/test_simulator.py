from app.simulator import GridSimulator


def test_simulator_has_twenty_nodes_and_twenty_connections() -> None:
    grid = GridSimulator(seed=1)
    snapshot = grid.snapshot()
    assert len(snapshot["nodes"]) == 20
    assert len(snapshot["connections"]) == 20
    assert snapshot["summary"]["nodeCount"] == 20


def test_ticks_update_live_telemetry_history() -> None:
    grid = GridSimulator(seed=2)
    before = len(grid.history)
    snapshot = grid.tick()
    assert len(grid.history) == before + 1
    assert snapshot["summary"]["totalLoad"] > 0
    assert all(node["power"] >= 0 for node in snapshot["nodes"])


def test_heatwave_scenario_changes_load_and_expires() -> None:
    grid = GridSimulator(seed=3)
    result = grid.run_scenario("heatwave")
    assert result["scenario"] == "heatwave"
    assert result["scenarioResult"]["name"] == "heatwave"
    assert len(result["forecast"]) == 24
    assert result["summary"]["frequency"] < 50.0
    for _ in range(12):
        grid.tick()
    assert grid.scenario is None


def test_safety_checks_report_capacity_status() -> None:
    grid = GridSimulator(seed=4)
    checks = grid.snapshot()["safetyChecks"]
    assert len(checks) == 40
    assert all(check["status"] in {"pass", "warning", "critical"} for check in checks)
