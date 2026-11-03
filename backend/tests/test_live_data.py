from datetime import datetime, timedelta, timezone
from math import pi, sin

import app.forecasting as forecasting
from app.live_data import parse_grid_history_csv, parse_grid_payload
from app.settings import settings
from app.simulator import GridSimulator


def test_parse_json_payload_with_live_grid_fields() -> None:
    reading = parse_grid_payload(
        '{"timestamp":"2026-10-31T12:00:00Z","total_generation_mw":"14,200","demand_mw":13250,"solar_mw":120}',
        "application/json",
    )
    assert reading["generation_mw"] == 14200
    assert reading["demand_mw"] == 13250
    assert reading["solar_mw"] == 120
    assert reading["source"] == "pgcb"


def test_parse_csv_payload() -> None:
    reading = parse_grid_payload(
        "Timestamp,Generation MW,Demand MW,Gas MW\n2026-10-31T12:00:00Z,14000,13000,9000",
        "text/csv",
    )
    assert reading["generation_mw"] == 14000
    assert reading["demand_mw"] == 13000
    assert reading["gas_mw"] == 9000


def test_parse_html_table_payload() -> None:
    reading = parse_grid_payload(
        "<table><tr><th>Generation (MW)</th><th>Demand (MW)</th></tr><tr><td>14100</td><td>12800</td></tr></table>",
        "text/html",
    )
    assert reading["generation_mw"] == 14100
    assert reading["demand_mw"] == 12800


def test_parse_historical_csv_rows_and_timestamps() -> None:
    readings = parse_grid_history_csv(
        "timestamp,generation_mw,demand_mw,solar_mw\n"
        "2026-10-30T12:00:00Z,14000,13000,100\n"
        "2026-10-30T13:00:00Z,14100,13100,110\n"
    )
    assert len(readings) == 2
    assert readings[0]["observed_at"] == "2026-10-30T12:00:00+00:00"
    assert readings[1]["demand_mw"] == 13100


def test_live_national_reading_scales_virtual_grid_within_bounds() -> None:
    grid = GridSimulator(seed=10)
    grid.set_national_reading({
        "observed_at": "2026-10-31T12:00:00+00:00",
        "generation_mw": settings.grid_national_baseline_demand_mw * 2,
        "demand_mw": settings.grid_national_baseline_demand_mw * 2,
        "source": "pgcb",
    })
    snapshot = grid.tick()
    assert snapshot["dataProvenance"] == "live-national-trend-scaled-simulation"
    assert snapshot["nationalDemandScale"] == 1.25
    assert snapshot["nationalGenerationScale"] == 1.25
    assert snapshot["nationalData"]["source"] == "pgcb"


def test_historical_demand_trains_live_forecast_model(monkeypatch) -> None:
    monkeypatch.setattr(forecasting, "_historical_model", None)
    start = datetime(2026, 10, 1, tzinfo=timezone.utc)
    records = [
        {
            "observed_at": (start + timedelta(hours=index)).isoformat(),
            "demand_mw": 13_000 + 900 * sin(index * 2 * pi / 24),
        }
        for index in range(168)
    ]
    assert forecasting.set_historical_demand(records) is True
    assert forecasting.get_forecast_model_name().endswith("historical")
    forecast = forecasting.forecast_demand(4_000, 12, national_current_demand_mw=13_000)
    assert len(forecast) == 24
    assert all(point["load"] >= 0 for point in forecast)


def test_parse_supabase_pgcb_payload_with_adani_and_imports() -> None:
    # Simulates row directly as stored in Supabase hourly_generation table
    supabase_row = (
        '{"datetime":"2026-11-03T16:00:00+06:00",'
        '"Generation(MW)":14250.0,"Gas":6500.0,"Liquid Fuel":1200.0,'
        '"Coal":4300.0,"Hydro":180.0,"Solar":310.0,"Wind":12.0,'
        '"India":980.0,"Nepal":40.0,"Adani":1050.0,"Remarks":null}'
    )
    reading = parse_grid_payload(supabase_row, "application/json")
    assert reading["generation_mw"] == 14250.0
    assert reading["demand_mw"] == 14250.0
    assert reading["gas_mw"] == 6500.0
    assert reading["liquid_fuel_mw"] == 1200.0
    assert reading["coal_mw"] == 4300.0
    # Imports should automatically aggregate India (980) + Nepal (40) + Adani (1050) = 2070
    assert reading["imports_mw"] == 2070.0
    assert reading["adani_mw"] == 1050.0
