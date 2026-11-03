from __future__ import annotations

from collections import deque
from datetime import datetime, timezone
from math import sin, pi
from typing import Any
import random

import numpy as np
import pandas as pd

from app.forecasting import forecast_demand
from app.settings import settings

NODE_DEFINITIONS = [
    ("GEN-N1", "North Solar Array", "generation", "North Zone", 120, 80, 230, 1_250, 80),
    ("SUB-N1", "North Substation", "substation", "North Zone", 390, 80, 230, 1_500, 62),
    ("LOAD-N1", "North City Load", "load", "North Zone", 650, 80, 132, 620, 79),
    ("LOAD-N2", "North Industrial Park", "load", "North Zone", 790, 80, 132, 480, 71),
    ("GEN-E1", "East Wind Farm", "generation", "East Zone", 120, 205, 230, 1_100, 77),
    ("SUB-E1", "East Substation", "substation", "East Zone", 390, 205, 230, 1_400, 65),
    ("LOAD-E1", "East Metro Load", "load", "East Zone", 650, 205, 132, 570, 82),
    ("LOAD-E2", "East Residential Load", "load", "East Zone", 790, 205, 132, 450, 68),
    ("GEN-C1", "Central Hydro Plant", "generation", "Central Zone", 120, 330, 230, 1_350, 84),
    ("SUB-C1", "Central Switching Hub", "substation", "Central Zone", 390, 330, 230, 1_750, 72),
    ("LOAD-C1", "Central Business District", "load", "Central Zone", 650, 330, 132, 760, 88),
    ("LOAD-C2", "Central Hospital District", "load", "Central Zone", 790, 330, 132, 390, 74),
    ("GEN-W1", "West Solar Farm", "generation", "West Zone", 120, 455, 230, 900, 74),
    ("SUB-W1", "West Substation", "substation", "West Zone", 390, 455, 230, 1_250, 67),
    ("LOAD-W1", "West Residential Load", "load", "West Zone", 650, 455, 132, 540, 76),
    ("LOAD-W2", "West Data Center", "load", "West Zone", 790, 455, 132, 520, 83),
    ("GEN-S1", "South Thermal Plant", "generation", "South Zone", 120, 580, 230, 1_500, 81),
    ("SUB-S1", "South Substation", "substation", "South Zone", 390, 580, 230, 1_600, 70),
    ("LOAD-S1", "South Port Load", "load", "South Zone", 650, 580, 132, 610, 80),
    ("LOAD-S2", "South Residential Load", "load", "South Zone", 790, 580, 132, 470, 72),
]

ZONE_CONNECTIONS = [
    ("GEN-N1", "SUB-N1", 1_180), ("SUB-N1", "LOAD-N1", 680), ("SUB-N1", "LOAD-N2", 540),
    ("GEN-E1", "SUB-E1", 1_020), ("SUB-E1", "LOAD-E1", 630), ("SUB-E1", "LOAD-E2", 500),
    ("GEN-C1", "SUB-C1", 1_240), ("SUB-C1", "LOAD-C1", 820), ("SUB-C1", "LOAD-C2", 460),
    ("GEN-W1", "SUB-W1", 820), ("SUB-W1", "LOAD-W1", 600), ("SUB-W1", "LOAD-W2", 580),
    ("GEN-S1", "SUB-S1", 1_420), ("SUB-S1", "LOAD-S1", 680), ("SUB-S1", "LOAD-S2", 520),
    ("SUB-N1", "SUB-C1", 1_000), ("SUB-E1", "SUB-C1", 850),
    ("SUB-C1", "SUB-W1", 900), ("SUB-C1", "SUB-S1", 1_050),
    ("SUB-N1", "SUB-E1", 700),
]


def _status(load_percent: float) -> str:
    if load_percent >= 95:
        return "critical"
    if load_percent >= 85:
        return "warning"
    return "normal"


def _grid_frequency(total_generation: float, total_load: float) -> float:
    reserve_ratio = (total_generation - total_load) / max(total_load, 1)
    deviation = max(-0.25, min(0.25, (reserve_ratio - 0.125) * 0.5))
    return round(50 + deviation, 3)


class GridSimulator:
    """Deterministic, testable simulator for a 20-node distribution grid."""

    def __init__(self, seed: int = 3208) -> None:
        self.rng = random.Random(seed)
        self.numpy_rng = np.random.default_rng(seed)
        self.nodes: list[dict[str, Any]] = [
            {
                "id": node_id,
                "name": name,
                "type": node_type,
                "zone": zone,
                "x": x,
                "y": y,
                "voltage": float(voltage),
                "power": 0.0,
                "load": float(load),
                "capacity": float(capacity),
                "status": "normal",
                "baseLoad": float(load),
                "baseVoltage": float(voltage),
            }
            for node_id, name, node_type, zone, x, y, voltage, capacity, load in NODE_DEFINITIONS
        ]
        self.connections = [
            {
                "id": f"LINE-{index:02d}",
                "source": source,
                "target": target,
                "power": 0.0,
                "loadPercentage": 0.0,
                "capacity": float(capacity),
                "status": "normal",
            }
            for index, (source, target, capacity) in enumerate(ZONE_CONNECTIONS, start=1)
        ]
        self.history: deque[dict[str, Any]] = deque(maxlen=96)
        self.scenario: str | None = None
        self.scenario_ticks = 0
        self.scenario_result: dict[str, Any] | None = None
        self.national_reading: dict[str, Any] | None = None
        self.demand_scale = 1.0
        self.generation_scale = 1.0
        self.tick_count = 0
        for offset in range(23, -1, -1):
            hour = (datetime.now(timezone.utc).hour - offset) % 24
            base = 4_100 + 420 * sin(2 * pi * (hour - 8) / 24)
            self.history.append({
                "time": datetime.now(timezone.utc).replace(minute=0, second=0, microsecond=0).isoformat(),
                "actual": round(base, 1),
                "forecast": None,
                "capacity": 6_000,
                "voltage": 230.0,
                "frequency": 50.0,
            })
        self.tick()

    def activate_scenario(self, scenario: str) -> None:
        allowed = {"heatwave", "demand_spike", "solar_failure", "node_failure"}
        if scenario not in allowed:
            raise ValueError(f"Unsupported scenario: {scenario}")
        self.scenario = scenario
        self.scenario_ticks = 12

    def set_national_reading(self, reading: dict[str, Any]) -> None:
        self.national_reading = dict(reading)
        baseline = max(settings.grid_national_baseline_demand_mw, 1.0)
        demand = reading.get("demand_mw")
        generation = reading.get("generation_mw")
        self.demand_scale = min(1.25, max(0.75, float(demand) / baseline)) if demand is not None else 1.0
        self.generation_scale = min(1.25, max(0.75, float(generation) / baseline)) if generation is not None else 1.0

    def reset_scenario(self) -> dict[str, Any]:
        self.scenario = None
        self.scenario_ticks = 0
        self.scenario_result = None
        return self.tick()

    def _scenario_adjustments(self, node: dict[str, Any]) -> tuple[float, float]:
        load_delta = 0.0
        generation_multiplier = 1.0
        if self.scenario == "heatwave" and node["type"] == "load":
            load_delta = 11.0
        elif self.scenario == "demand_spike" and node["type"] == "load":
            load_delta = 18.0
        elif self.scenario == "solar_failure" and node["id"] in {"GEN-N1", "GEN-W1"}:
            generation_multiplier = 0.28
        elif self.scenario == "node_failure" and node["id"] == "SUB-C1":
            generation_multiplier = 0.0
            load_delta = 17.0
        return load_delta, generation_multiplier

    def tick(self) -> dict[str, Any]:
        self.tick_count += 1
        for node in self.nodes:
            load_delta, generation_multiplier = self._scenario_adjustments(node)
            jitter = self.rng.uniform(-1.8, 1.8)
            if node["type"] == "generation":
                output_factor = (0.78 + self.rng.uniform(-0.025, 0.025)) * generation_multiplier * self.generation_scale
                node["power"] = round(node["capacity"] * output_factor, 1)
                node["load"] = round(min(100.0, max(0.0, 80 + jitter)), 1)
            elif node["type"] == "load":
                node["load"] = round(min(100.0, max(20.0, node["baseLoad"] * self.demand_scale + load_delta + jitter)), 1)
                node["power"] = round(node["capacity"] * node["load"] / 100, 1)
            else:
                node["load"] = round(min(100.0, max(20.0, node["baseLoad"] + jitter)), 1)
                node["power"] = round(sum(
                    candidate["power"]
                    for candidate in self.nodes
                    if candidate["type"] == "load" and candidate["zone"] == node["zone"]
                ), 1)
            nominal_voltage = node["baseVoltage"]
            voltage_drop = max(0.0, node["load"] - 80) * 0.11
            node["voltage"] = round(max(0.0, nominal_voltage - voltage_drop + self.rng.uniform(-0.7, 0.7)), 2)
            node["status"] = _status(node["load"])
            if node["id"] == "SUB-C1" and self.scenario == "node_failure":
                node["status"] = "critical"
                node["power"] = 0.0

        node_by_id = {node["id"]: node for node in self.nodes}
        for line in self.connections:
            source = node_by_id[line["source"]]
            target = node_by_id[line["target"]]
            line["power"] = round(min(source["capacity"], target["capacity"], target["power"]), 1)
            line["loadPercentage"] = round(line["power"] / line["capacity"] * 100, 1)
            line["status"] = _status(line["loadPercentage"])

        if self.scenario_ticks > 0:
            self.scenario_ticks -= 1
            if self.scenario_ticks == 0:
                self.scenario = None

        snapshot = self.snapshot()
        self.history.append({
            "time": snapshot["timestamp"],
            "actual": snapshot["summary"]["totalLoad"],
            "forecast": None,
            "capacity": 6_000,
            "voltage": snapshot["summary"]["averageVoltage"],
            "frequency": snapshot["summary"]["frequency"],
        })
        return self.snapshot()

    def _alerts(self) -> list[dict[str, Any]]:
        alerts: list[dict[str, Any]] = []
        now = datetime.now(timezone.utc).isoformat()
        for node in self.nodes:
            if node["status"] == "normal":
                continue
            severity = "critical" if node["status"] == "critical" else "warning"
            alerts.append({
                "id": f"load-{node['id']}",
                "type": severity,
                "title": f"{node['status'].title()} load — {node['name']}",
                "message": f"{node['name']} is operating at {node['load']:.0f}% of rated capacity.",
                "time": now,
                "nodeId": node["id"],
                "active": True,
            })
            if node["voltage"] < node["baseVoltage"] * 0.95:
                alerts.append({
                    "id": f"voltage-{node['id']}",
                    "type": "warning",
                    "title": f"Voltage deviation — {node['name']}",
                    "message": f"Voltage is {node['voltage']:.1f} kV; nominal is {node['baseVoltage']:.0f} kV.",
                    "time": now,
                    "nodeId": node["id"],
                    "active": True,
                })
        total_load = sum(node["power"] for node in self.nodes if node["type"] == "load")
        total_generation = sum(node["power"] for node in self.nodes if node["type"] == "generation")
        frequency = _grid_frequency(total_generation, total_load)
        if abs(frequency - 50) >= 0.08:
            alerts.append({
                "id": "frequency-deviation",
                "type": "critical" if abs(frequency - 50) >= 0.15 else "warning",
                "title": "Grid frequency deviation",
                "message": f"System frequency is {frequency:.3f} Hz against a 50 Hz nominal target.",
                "time": now,
                "active": True,
            })
        if self.scenario == "solar_failure":
            alerts.append({
                "id": "renewable-generation-loss",
                "type": "warning",
                "title": "Renewable generation loss",
                "message": "A simulated solar plant trip reduced available generation.",
                "time": now,
                "active": True,
            })
        return alerts

    def _safety_checks(self) -> list[dict[str, Any]]:
        checks = []
        for node in self.nodes:
            state = "critical" if node["load"] > 95 else "warning" if node["load"] >= 85 else "pass"
            checks.append({
                "id": f"NODE-{node['id']}",
                "subject": node["name"],
                "measured": node["load"],
                "limit": 95.0,
                "unit": "%",
                "status": state,
                "message": "Within node loading limit" if state == "pass" else "Node loading limit requires operator review",
            })
        for line in self.connections:
            state = "critical" if line["loadPercentage"] > 100 else "warning" if line["loadPercentage"] >= 85 else "pass"
            checks.append({
                "id": line["id"],
                "subject": f"{line['source']} → {line['target']}",
                "measured": line["power"],
                "limit": line["capacity"],
                "unit": "MW",
                "status": state,
                "message": "Within line capacity" if state == "pass" else "Capacity limit requires operator review",
            })
        return checks

    def snapshot(self) -> dict[str, Any]:
        loads = [node for node in self.nodes if node["type"] == "load"]
        generators = [node for node in self.nodes if node["type"] == "generation"]
        total_load = round(sum(node["power"] for node in loads), 1)
        total_generation = round(sum(node["power"] for node in generators), 1)
        avg_voltage = round(float(np.mean([node["voltage"] for node in self.nodes])), 2)
        max_load = max(node["load"] for node in self.nodes)
        frequency = _grid_frequency(total_generation, total_load)
        health = round(max(0, 100 - sum(node["status"] != "normal" for node in self.nodes) * 1.2 - max(0, max_load - 85) * 0.5), 1)
        risk = "critical" if max_load >= 98 or abs(frequency - 50) >= 0.15 else "high" if max_load >= 92 else "moderate" if max_load >= 85 else "low"
        hour = datetime.now(timezone.utc).hour
        national_demand = self.national_reading.get("demand_mw") if self.national_reading else None
        forecast = forecast_demand(total_load, hour, national_current_demand_mw=national_demand)
        series = list(self.history)
        if series:
            series[-1] = {**series[-1], "forecast": forecast[0]["load"]}
        safety = self._safety_checks()
        return {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "summary": {
                "totalGeneration": total_generation,
                "totalLoad": total_load,
                "frequency": frequency,
                "averageVoltage": avg_voltage,
                "systemHealth": health,
                "risk": risk,
                "nodeCount": len(self.nodes),
                "generationReserve": round(total_generation - total_load, 1),
            },
            "nodes": self.nodes,
            "connections": self.connections,
            "history": series,
            "forecast": forecast,
            "alerts": self._alerts(),
            "safetyChecks": safety,
            "scenario": self.scenario,
            "scenarioResult": self.scenario_result,
            "mlModel": _get_model_name(),
            "nationalData": self.national_reading,
            "dataProvenance": "live-national-trend-scaled-simulation" if self.national_reading else "simulator-only",
            "nationalDemandScale": round(self.demand_scale, 3),
            "nationalGenerationScale": round(self.generation_scale, 3),
        }

    def run_scenario(self, scenario: str) -> dict[str, Any]:
        baseline = self.snapshot()
        self.activate_scenario(scenario)
        result = self.tick()
        baseline_load = max(float(baseline["summary"]["totalLoad"]), 1)
        baseline_generation = max(float(baseline["summary"]["totalGeneration"]), 1)
        load_change = (result["summary"]["totalLoad"] / baseline_load - 1) * 100
        generation_change = (result["summary"]["totalGeneration"] / baseline_generation - 1) * 100
        self.scenario_result = {
            "name": scenario,
            "loadImpact": f"{load_change:+.1f}%",
            "frequency": f"{result['summary']['frequency']:.3f} Hz",
            "generationImpact": f"{generation_change:+.1f}%",
            "risk": result["summary"]["risk"].title(),
            "description": f"{scenario.replace('_', ' ').title()} applied to the simulated 20-node grid for 12 telemetry cycles.",
        }
        return self.snapshot()

    def report(self, report_type: str) -> dict[str, Any]:
        frame = pd.DataFrame(list(self.history))
        return {
            "id": f"report-{self.tick_count}",
            "type": report_type,
            "generatedAt": datetime.now(timezone.utc).isoformat(),
            "summary": {
                "sampleCount": int(len(frame)),
                "averageLoad": round(float(frame["actual"].mean()), 1) if not frame.empty else 0,
                "peakLoad": round(float(frame["actual"].max()), 1) if not frame.empty else 0,
                "minimumLoad": round(float(frame["actual"].min()), 1) if not frame.empty else 0,
            },
        }


def _get_model_name() -> str:
    from app.forecasting import get_forecast_model_name

    return get_forecast_model_name()
