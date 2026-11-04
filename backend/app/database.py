from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone
from typing import Any

from sqlalchemy import text
from sqlalchemy.engine import make_url
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from app.settings import settings
from app.grid_hierarchy import ALL_GRID_NODES, DIVISION_NODES, GRID_TIERS, NATIONAL_NODE

logger = logging.getLogger(__name__)
engine: AsyncEngine | None = None


async def start_database() -> bool:
    global engine
    if not settings.database_url:
        logger.info("DATABASE_URL is not configured; telemetry persistence is disabled")
        return False
    database_url = make_url(settings.database_url)
    connect_args: dict[str, Any] = {}
    if database_url.get_backend_name() == "postgresql":
        database_url = database_url.set(drivername="postgresql+asyncpg")
    query = dict(database_url.query)
    sslmode = query.pop("sslmode", None)
    if sslmode in {"require", "verify-ca", "verify-full"}:
        connect_args["ssl"] = "require" if sslmode == "require" else True
    database_url = database_url.set(query=query)
    engine = create_async_engine(database_url, pool_pre_ping=True, connect_args=connect_args)
    try:
        async with engine.begin() as connection:
            await connection.execute(
                text(
                    """CREATE TABLE IF NOT EXISTS telemetry (
                        observed_at TIMESTAMPTZ NOT NULL,
                        node_id TEXT NOT NULL,
                        load_mw DOUBLE PRECISION NOT NULL,
                        voltage_kv DOUBLE PRECISION NOT NULL,
                        load_percent DOUBLE PRECISION NOT NULL,
                        status TEXT NOT NULL,
                        source TEXT NOT NULL DEFAULT 'simulator',
                        PRIMARY KEY (observed_at, node_id)
                    )"""
                )
            )
            await connection.execute(
                text("ALTER TABLE telemetry ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'simulator'")
            )
            await connection.execute(
                text(
                    """CREATE TABLE IF NOT EXISTS national_grid_readings (
                        observed_at TIMESTAMPTZ NOT NULL,
                        source TEXT NOT NULL,
                        generation_mw DOUBLE PRECISION,
                        demand_mw DOUBLE PRECISION,
                        demand_is_inferred BOOLEAN NOT NULL DEFAULT FALSE,
                        gas_mw DOUBLE PRECISION,
                        coal_mw DOUBLE PRECISION,
                        solar_mw DOUBLE PRECISION,
                        hydro_mw DOUBLE PRECISION,
                        wind_mw DOUBLE PRECISION,
                        imports_mw DOUBLE PRECISION,
                        PRIMARY KEY (observed_at, source)
                    )"""
                )
            )
            await connection.execute(
                text("ALTER TABLE national_grid_readings ADD COLUMN IF NOT EXISTS demand_is_inferred BOOLEAN NOT NULL DEFAULT FALSE")
            )
            # Earlier importer versions copied generation into demand when no demand column existed.
            await connection.execute(
                text("UPDATE national_grid_readings SET demand_is_inferred=TRUE WHERE source='pgcb' AND demand_is_inferred=FALSE AND demand_mw IS NOT NULL AND demand_mw=generation_mw")
            )
            await connection.execute(
                text(
                    """CREATE TABLE IF NOT EXISTS grid_nodes (
                        node_id TEXT PRIMARY KEY,
                        name TEXT NOT NULL,
                        tier TEXT NOT NULL CHECK (tier IN ('national', 'division', 'district', 'feeder')),
                        parent_node_id TEXT REFERENCES grid_nodes(node_id) ON DELETE RESTRICT,
                        division_code TEXT,
                        distribution_weight DOUBLE PRECISION CHECK (distribution_weight IS NULL OR (distribution_weight >= 0 AND distribution_weight <= 1)),
                        created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
                        CHECK ((tier = 'national' AND parent_node_id IS NULL)
                            OR (tier <> 'national' AND parent_node_id IS NOT NULL))
                    )"""
                )
            )
            await connection.execute(
                text("ALTER TABLE grid_nodes ADD COLUMN IF NOT EXISTS distribution_weight DOUBLE PRECISION")
            )
            await connection.execute(
                text(
                    """CREATE TABLE IF NOT EXISTS grid_node_readings (
                        observed_at TIMESTAMPTZ NOT NULL,
                        node_id TEXT NOT NULL REFERENCES grid_nodes(node_id) ON DELETE RESTRICT,
                        source TEXT NOT NULL,
                        generation_mw DOUBLE PRECISION,
                        demand_mw DOUBLE PRECISION,
                        gas_mw DOUBLE PRECISION,
                        coal_mw DOUBLE PRECISION,
                        solar_mw DOUBLE PRECISION,
                        hydro_mw DOUBLE PRECISION,
                        wind_mw DOUBLE PRECISION,
                        imports_mw DOUBLE PRECISION,
                        voltage_kv DOUBLE PRECISION,
                        load_percent DOUBLE PRECISION,
                        capacity_mw DOUBLE PRECISION,
                        status TEXT,
                        PRIMARY KEY (observed_at, node_id, source)
                    )"""
                )
            )
        try:
            async with engine.begin() as connection:
                await connection.execute(text("CREATE EXTENSION IF NOT EXISTS timescaledb"))
                await connection.execute(
                    text("SELECT create_hypertable('telemetry', 'observed_at', if_not_exists => TRUE)")
                )
                await connection.execute(
                    text("SELECT create_hypertable('national_grid_readings', 'observed_at', if_not_exists => TRUE)")
                )
                await connection.execute(
                    text("SELECT create_hypertable('grid_node_readings', 'observed_at', if_not_exists => TRUE)")
                )
        except Exception as exc:
            logger.info(
                "TimescaleDB extension unavailable (%s); using standard PostgreSQL time-series tables",
                type(exc).__name__,
            )
        await seed_grid_topology()
        logger.info("PostgreSQL telemetry persistence connected")
        return True
    except Exception:
        logger.exception("PostgreSQL unavailable; continuing with in-memory telemetry")
        await engine.dispose()
        engine = None
        return False


async def save_snapshot(snapshot: dict[str, Any]) -> None:
    if engine is None:
        return
    observed_at = datetime.fromisoformat(snapshot["timestamp"].replace("Z", "+00:00"))
    rows = [
        {
            "observed_at": observed_at,
            "node_id": node["id"],
            "load_mw": node["power"],
            "voltage_kv": node["voltage"],
            "load_percent": node["load"],
            "status": node["status"],
            "source": "simulator",
        }
        for node in snapshot["nodes"]
    ]
    try:
        async with engine.begin() as connection:
            await connection.execute(
                text(
                    """INSERT INTO telemetry
                    (observed_at, node_id, load_mw, voltage_kv, load_percent, status, source)
                    VALUES (:observed_at, :node_id, :load_mw, :voltage_kv, :load_percent, :status, :source)
                    ON CONFLICT (observed_at, node_id) DO NOTHING"""
                ),
                rows,
            )
    except Exception:
        logger.exception("Could not persist telemetry snapshot")


async def save_national_reading(reading: dict[str, Any]) -> None:
    await save_national_readings([reading])


async def save_national_readings(readings: list[dict[str, Any]]) -> None:
    if engine is None:
        return
    values = []
    for reading in readings:
        values.append({
            "observed_at": datetime.fromisoformat(
                str(reading["observed_at"]).replace("Z", "+00:00")
            ),
            "source": reading.get("source", "pgcb"),
            "demand_is_inferred": bool(reading.get("demand_is_inferred", False)),
            **{
                key: reading.get(key)
                for key in (
                    "generation_mw", "demand_mw", "gas_mw", "coal_mw",
                    "solar_mw", "hydro_mw", "wind_mw", "imports_mw",
                )
            },
        })
    if not values:
        return
    try:
        async with engine.begin() as connection:
            await connection.execute(
                text(
                    """INSERT INTO national_grid_readings
                    (observed_at, source, generation_mw, demand_mw, demand_is_inferred, gas_mw, coal_mw,
                     solar_mw, hydro_mw, wind_mw, imports_mw)
                        VALUES (:observed_at, :source, :generation_mw, :demand_mw, :demand_is_inferred, :gas_mw,
                                :coal_mw, :solar_mw, :hydro_mw, :wind_mw, :imports_mw)
                    ON CONFLICT (observed_at, source) DO UPDATE SET
                        generation_mw = EXCLUDED.generation_mw,
                        demand_mw = EXCLUDED.demand_mw,
                            demand_is_inferred = EXCLUDED.demand_is_inferred,
                        gas_mw = EXCLUDED.gas_mw,
                        coal_mw = EXCLUDED.coal_mw,
                        solar_mw = EXCLUDED.solar_mw,
                        hydro_mw = EXCLUDED.hydro_mw,
                        wind_mw = EXCLUDED.wind_mw,
                        imports_mw = EXCLUDED.imports_mw"""
                ),
                values,
            )
        await save_hierarchical_readings([
            {
                **reading,
                "node_id": NATIONAL_NODE["node_id"],
                "node_name": NATIONAL_NODE["name"],
                "tier": "national",
                "parent_node_id": None,
            }
            for reading in readings
        ])
    except Exception:
        logger.exception("Could not persist national grid reading")


async def seed_grid_topology() -> None:
    """Create national, division, district, and feeder hierarchy records."""
    if engine is None:
        return
    async with engine.begin() as connection:
        await connection.execute(
            text(
                """INSERT INTO grid_nodes (node_id, name, tier, parent_node_id, division_code, distribution_weight)
                   VALUES (:node_id, :name, :tier, :parent_node_id, :division_code, :distribution_weight)
                   ON CONFLICT (node_id) DO UPDATE SET
                       name = EXCLUDED.name, tier = EXCLUDED.tier,
                       parent_node_id = EXCLUDED.parent_node_id,
                       division_code = EXCLUDED.division_code,
                       distribution_weight = COALESCE(EXCLUDED.distribution_weight, grid_nodes.distribution_weight)"""
            ),
            ALL_GRID_NODES,
        )


async def save_hierarchical_readings(readings: list[dict[str, Any]]) -> int:
    """Upsert actual source hierarchy metadata/readings from the user's future ETL script.

    Expected row keys: node_id, node_name, tier, parent_node_id, observed_at, source;
                                        demand_is_inferred = EXCLUDED.demand_is_inferred,
    optional: division_code and generation/demand/fuel/voltage/capacity/status fields.
    This function performs no scaling, interpolation, or fabricated data generation.
    """
    if engine is None or not readings:
        return 0
    normalized: list[dict[str, Any]] = []
    for row in readings:
        tier = str(row.get("tier", ""))
        node_id = str(row.get("node_id", "")).strip()
        node_name = str(row.get("node_name", row.get("name", ""))).strip()
        parent = row.get("parent_node_id")
        if tier not in GRID_TIERS or not node_id or not node_name:
            raise ValueError("Each row needs node_id, node_name, and tier in national/division/district/feeder")
        if (tier == "national") != (parent is None):
            raise ValueError("National root must have no parent; all other tiers require parent_node_id")
        observed_at = datetime.fromisoformat(str(row["observed_at"]).replace("Z", "+00:00"))
        if observed_at.tzinfo is None:
            observed_at = observed_at.replace(tzinfo=timezone.utc)
        normalized.append({
            "node_id": node_id,
            "name": node_name,
            "tier": tier,
            "parent_node_id": parent,
            "division_code": row.get("division_code"),
            "distribution_weight": row.get("distribution_weight"),
            "observed_at": observed_at,
            "source": str(row.get("source", "external")).strip() or "external",
            **{
                key: row.get(key)
                for key in (
                    "generation_mw", "demand_mw", "gas_mw", "coal_mw", "solar_mw",
                    "hydro_mw", "wind_mw", "imports_mw", "voltage_kv", "load_percent",
                    "capacity_mw", "status",
                )
            },
        })

    depth = {"national": 0, "division": 1, "district": 2, "feeder": 3}
    nodes: dict[str, dict[str, Any]] = {}
    for row in normalized:
        existing = nodes.get(row["node_id"])
        if existing and (existing["tier"] != row["tier"] or existing["parent_node_id"] != row["parent_node_id"]):
            raise ValueError(f"Conflicting hierarchy definitions for node {row['node_id']}")
        nodes[row["node_id"]] = row
    ordered_nodes = sorted(nodes.values(), key=lambda row: depth[row["tier"]])
    async with engine.begin() as connection:
        for node in ordered_nodes:
            await connection.execute(
                text(
                    """INSERT INTO grid_nodes (node_id, name, tier, parent_node_id, division_code, distribution_weight)
                       VALUES (:node_id, :name, :tier, :parent_node_id, :division_code, :distribution_weight)
                       ON CONFLICT (node_id) DO UPDATE SET
                           name = EXCLUDED.name,
                           division_code = COALESCE(EXCLUDED.division_code, grid_nodes.division_code),
                           distribution_weight = COALESCE(EXCLUDED.distribution_weight, grid_nodes.distribution_weight)"""
                ),
                node,
            )
        await connection.execute(
            text(
                """INSERT INTO grid_node_readings
                   (observed_at, node_id, source, generation_mw, demand_mw, gas_mw, coal_mw,
                    solar_mw, hydro_mw, wind_mw, imports_mw, voltage_kv, load_percent, capacity_mw, status)
                   VALUES (:observed_at, :node_id, :source, :generation_mw, :demand_mw, :gas_mw, :coal_mw,
                           :solar_mw, :hydro_mw, :wind_mw, :imports_mw, :voltage_kv, :load_percent,
                           :capacity_mw, :status)
                   ON CONFLICT (observed_at, node_id, source) DO UPDATE SET
                     generation_mw=EXCLUDED.generation_mw, demand_mw=EXCLUDED.demand_mw,
                     gas_mw=EXCLUDED.gas_mw, coal_mw=EXCLUDED.coal_mw, solar_mw=EXCLUDED.solar_mw,
                     hydro_mw=EXCLUDED.hydro_mw, wind_mw=EXCLUDED.wind_mw, imports_mw=EXCLUDED.imports_mw,
                     voltage_kv=EXCLUDED.voltage_kv, load_percent=EXCLUDED.load_percent,
                     capacity_mw=EXCLUDED.capacity_mw, status=EXCLUDED.status"""
            ),
            normalized,
        )
        national_rows = [row for row in normalized if row["tier"] == "national"]
        if national_rows:
            await connection.execute(
                text(
                    """INSERT INTO national_grid_readings
                       (observed_at, source, generation_mw, demand_mw, gas_mw, coal_mw,
                        solar_mw, hydro_mw, wind_mw, imports_mw)
                       VALUES (:observed_at, :source, :generation_mw, :demand_mw, :gas_mw, :coal_mw,
                               :solar_mw, :hydro_mw, :wind_mw, :imports_mw)
                       ON CONFLICT (observed_at, source) DO UPDATE SET
                         generation_mw=EXCLUDED.generation_mw, demand_mw=EXCLUDED.demand_mw,
                         gas_mw=EXCLUDED.gas_mw, coal_mw=EXCLUDED.coal_mw,
                         solar_mw=EXCLUDED.solar_mw, hydro_mw=EXCLUDED.hydro_mw,
                         wind_mw=EXCLUDED.wind_mw, imports_mw=EXCLUDED.imports_mw"""
                ),
                national_rows,
            )
    return len(normalized)


async def configure_division_distribution_weights(weights: dict[str, float]) -> None:
    """Configure named administrative allocation weights; never apply undocumented defaults."""
    expected = {node["node_id"] for node in DIVISION_NODES}
    if set(weights) != expected:
        missing = sorted(expected - set(weights))
        extra = sorted(set(weights) - expected)
        raise ValueError(f"Weights must name all eight divisions exactly (missing={missing}, extra={extra})")
    clean = {key: float(value) for key, value in weights.items()}
    if any(value < 0 or value > 1 for value in clean.values()):
        raise ValueError("Every division weight must be between 0 and 1")
    if abs(sum(clean.values()) - 1.0) > 1e-6:
        raise ValueError("Division weights must sum to 1.0 (100%)")
    if engine is None:
        raise RuntimeError("DATABASE_URL is not connected")
    async with engine.begin() as connection:
        await connection.execute(
            text("UPDATE grid_nodes SET distribution_weight=:weight WHERE node_id=:node_id AND tier='division'"),
            [{"node_id": node_id, "weight": weight} for node_id, weight in clean.items()],
        )


async def get_grid_hierarchy(parent_node_id: str = "BD-NATIONAL") -> dict[str, Any]:
    if engine is None:
        return {"database": "disconnected", "parent": None, "nodes": []}
    try:
        async with engine.connect() as connection:
            parent_result = await connection.execute(
                text(
                    """SELECT n.node_id, n.name, n.tier, n.parent_node_id, n.division_code, n.distribution_weight,
                              COALESCE(reading.observed_at, nat.observed_at) AS observed_at,
                              COALESCE(reading.source, nat.source) AS source,
                              COALESCE(reading.generation_mw, nat.generation_mw) AS generation_mw,
                            CASE WHEN n.tier = 'national' AND nat.demand_is_inferred
                                THEN NULL ELSE COALESCE(reading.demand_mw, nat.demand_mw) END AS demand_mw,
                              COALESCE(reading.gas_mw, nat.gas_mw) AS gas_mw,
                              COALESCE(reading.coal_mw, nat.coal_mw) AS coal_mw,
                              COALESCE(reading.solar_mw, nat.solar_mw) AS solar_mw,
                              COALESCE(reading.hydro_mw, nat.hydro_mw) AS hydro_mw,
                              COALESCE(reading.wind_mw, nat.wind_mw) AS wind_mw,
                              COALESCE(reading.imports_mw, nat.imports_mw) AS imports_mw,
                              reading.voltage_kv,
                              reading.load_percent, reading.capacity_mw, reading.status
                       FROM grid_nodes n
                       LEFT JOIN LATERAL (
                           SELECT r.* FROM grid_node_readings r WHERE r.node_id=n.node_id
                           ORDER BY r.observed_at DESC LIMIT 1
                       ) reading ON TRUE
                       LEFT JOIN LATERAL (
                           SELECT * FROM national_grid_readings ORDER BY observed_at DESC LIMIT 1
                       ) nat ON (n.tier = 'national')
                       WHERE n.node_id=:node_id"""
                ),
                {"node_id": parent_node_id},
            )
            parent = parent_result.mappings().one_or_none()
            if parent is None:
                return {"database": "connected", "parent": None, "nodes": []}
            parent = dict(parent)
            parent["measured"] = parent["observed_at"] is not None
            parent["estimated"] = False
            parent["estimated_generation_mw"] = None
            parent["estimated_demand_mw"] = None
            if parent["observed_at"] is not None:
                parent["observed_at"] = parent["observed_at"].isoformat()

            # If parent is a division or district with no direct measurements, estimate from national
            if not parent["measured"] and parent.get("distribution_weight") is not None:
                nat_res = await connection.execute(
                    text("SELECT generation_mw, demand_mw, demand_is_inferred, observed_at, source FROM national_grid_readings ORDER BY observed_at DESC LIMIT 1")
                )
                nat_row = nat_res.mappings().one_or_none()
                if nat_row and (nat_row["generation_mw"] is not None or nat_row["demand_mw"] is not None):
                    p_weight = float(parent["distribution_weight"])
                    parent["estimated"] = True
                    generation = nat_row["generation_mw"] if nat_row["generation_mw"] is not None else nat_row["demand_mw"]
                    parent["estimated_generation_mw"] = round(float(generation) * p_weight, 1)
                    if nat_row["demand_mw"] is not None and not nat_row["demand_is_inferred"]:
                        parent["estimated_demand_mw"] = round(float(nat_row["demand_mw"]) * p_weight, 1)

            children_result = await connection.execute(
                text(
                    """SELECT n.node_id, n.name, n.tier, n.parent_node_id, n.division_code, n.distribution_weight,
                              child.child_count,
                              reading.observed_at, reading.source, reading.generation_mw, reading.demand_mw,
                              reading.gas_mw, reading.coal_mw, reading.solar_mw, reading.hydro_mw,
                              reading.wind_mw, reading.imports_mw, reading.voltage_kv,
                              reading.load_percent, reading.capacity_mw, reading.status
                       FROM grid_nodes n
                       LEFT JOIN LATERAL (
                           SELECT count(*)::integer AS child_count FROM grid_nodes c WHERE c.parent_node_id=n.node_id
                       ) child ON TRUE
                       LEFT JOIN LATERAL (
                           SELECT r.* FROM grid_node_readings r WHERE r.node_id=n.node_id
                           ORDER BY r.observed_at DESC LIMIT 1
                       ) reading ON TRUE
                       WHERE n.parent_node_id=:parent_node_id
                       ORDER BY CASE n.tier WHEN 'division' THEN 0 WHEN 'district' THEN 1 ELSE 2 END, n.name"""
                ),
                {"parent_node_id": parent_node_id},
            )
            nodes = []
            for raw in children_result.mappings().all():
                node = dict(raw)
                node["measured"] = node["observed_at"] is not None
                node["estimated"] = False
                node["estimated_generation_mw"] = None
                node["estimated_demand_mw"] = None
                if node["observed_at"] is not None:
                    node["observed_at"] = node["observed_at"].isoformat()
                nodes.append(node)

        total_child_weight = sum(
            float(node["distribution_weight"])
            for node in nodes
            if node["distribution_weight"] is not None
        )
        allocation: dict[str, Any] = {
            "ready": False,
            "method": "proportional-hierarchical-weights",
            "weight_sum": round(total_child_weight, 6),
            "message": "Tier estimates use proportional distribution weights from the parent aggregate.",
        }
        parent_power_available = parent.get("measured") or parent.get("estimated")
        weights_complete = (
            len(nodes) > 0
            and all(node["distribution_weight"] is not None for node in nodes)
            and abs(allocation["weight_sum"] - 1.0) <= 0.01
        )
        if weights_complete and parent_power_available:
            allocation["ready"] = True
            allocation["message"] = (
                "Estimated tier totals use calibrated proportional distribution shares of the parent aggregate."
            )
            parent_gen = (
                parent.get("generation_mw")
                if parent.get("generation_mw") is not None
                else parent.get("estimated_generation_mw")
            )
            parent_dem = (
                parent.get("demand_mw")
                if parent.get("demand_mw") is not None
                else parent.get("estimated_demand_mw")
            )
            for node in nodes:
                weight = float(node["distribution_weight"])
                if node["measured"]:
                    continue
                node["estimated"] = True
                node["estimated_generation_mw"] = round(float(parent_gen) * weight, 1) if parent_gen is not None else None
                node["estimated_demand_mw"] = round(float(parent_dem) * weight, 1) if parent_dem is not None else None
        elif weights_complete:
            allocation["message"] = "Weights total 100%, but no parent reading is available to estimate child totals."

        return {"database": "connected", "parent": parent, "nodes": nodes, "allocation": allocation}
    except Exception:
        logger.exception("Could not read hierarchical grid data")
        return {"database": "error", "parent": None, "nodes": []}


async def get_historical_context() -> dict[str, Any]:
    if engine is None:
        return {"sample_count": 0, "recent_24h": []}
    cutoff = datetime.now(timezone.utc) - timedelta(days=180)
    try:
        async with engine.connect() as connection:
            result = await connection.execute(
                text(
                    """SELECT observed_at, generation_mw, demand_mw, demand_is_inferred, gas_mw, coal_mw,
                              solar_mw, hydro_mw, wind_mw, imports_mw
                       FROM national_grid_readings
                       WHERE observed_at >= :cutoff AND source = 'pgcb'
                       ORDER BY observed_at DESC LIMIT 4320"""
                ),
                {"cutoff": cutoff},
            )
            rows = [dict(row) for row in result.mappings().all()]
    except Exception:
        logger.exception("Could not load national grid history")
        return {"sample_count": 0, "recent_24h": []}

    rows.reverse()
    demands = [
        float(row["demand_mw"])
        for row in rows
        if row["demand_mw"] is not None and not row["demand_is_inferred"]
    ]
    generations = [float(row["generation_mw"]) for row in rows if row["generation_mw"] is not None]
    night = [float(row["demand_mw"]) for row in rows if row["demand_mw"] is not None and not row["demand_is_inferred"] and row["observed_at"].hour < 6]
    evening = [float(row["demand_mw"]) for row in rows if row["demand_mw"] is not None and not row["demand_is_inferred"] and 18 <= row["observed_at"].hour <= 21]
    renewable = [
        (float(row["solar_mw"] or 0) + float(row["wind_mw"] or 0)) / float(row["generation_mw"])
        for row in rows if row["generation_mw"] and float(row["generation_mw"]) > 0
    ]
    recent = rows[-24:]
    return {
        "sample_count": len(rows),
        "demand_available": bool(demands),
        "avg_demand_mw": round(sum(demands) / len(demands), 1) if demands else None,
        "max_demand_mw": round(max(demands), 1) if demands else None,
        "night_trough_mw": round(sum(night) / len(night), 1) if night else None,
        "evening_peak_mw": round(sum(evening) / len(evening), 1) if evening else None,
        "renewable_share_percent": round(sum(renewable) / len(renewable) * 100, 2) if renewable else None,
        "avg_generation_mw": round(sum(generations) / len(generations), 1) if generations else None,
        "max_generation_mw": round(max(generations), 1) if generations else None,
        "recent_24h": [
            {
                "observed_at": row["observed_at"].isoformat(),
                "generation_mw": row["generation_mw"],
                "demand_mw": None if row["demand_is_inferred"] else row["demand_mw"],
                "demand_is_inferred": row["demand_is_inferred"],
                "solar_mw": row["solar_mw"],
                "wind_mw": row["wind_mw"],
            }
            for row in recent
        ],
    }


async def get_forecast_training_data() -> list[dict[str, Any]]:
    if engine is None:
        return []
    cutoff = datetime.now(timezone.utc) - timedelta(days=180)
    try:
        async with engine.connect() as connection:
            result = await connection.execute(
                text(
                                        """SELECT observed_at,
                                                            CASE WHEN demand_is_inferred THEN generation_mw ELSE demand_mw END AS demand_mw
                       FROM national_grid_readings
                                             WHERE observed_at >= :cutoff AND source = 'pgcb'
                                                 AND CASE WHEN demand_is_inferred THEN generation_mw ELSE demand_mw END IS NOT NULL
                       ORDER BY observed_at DESC LIMIT 4320"""
                ),
                {"cutoff": cutoff},
            )
            rows = [dict(row) for row in result.mappings().all()]
        rows.reverse()
        return [{"observed_at": row["observed_at"].isoformat(), "demand_mw": row["demand_mw"]} for row in rows]
    except Exception:
        logger.exception("Could not load national forecast training data")
        return []


async def get_national_history(limit: int = 500) -> list[dict[str, Any]]:
    """Return recent real national source readings in chronological order."""
    if engine is None:
        return []
    bounded_limit = min(max(int(limit), 1), 4320)
    try:
        async with engine.connect() as connection:
            result = await connection.execute(
                text(
                    """SELECT observed_at, generation_mw, demand_mw, demand_is_inferred, gas_mw, coal_mw,
                              solar_mw, hydro_mw, wind_mw, imports_mw
                       FROM national_grid_readings
                       WHERE source = 'pgcb' AND demand_mw IS NOT NULL
                       ORDER BY observed_at DESC LIMIT :limit"""
                ),
                {"limit": bounded_limit},
            )
            rows = [dict(row) for row in result.mappings().all()]
        rows.reverse()
        return [
            {
                **row,
                "actual_mw": row["generation_mw"] if row["demand_is_inferred"] else row["demand_mw"],
                "observed_at": row["observed_at"].isoformat(),
            }
            for row in rows
        ]
    except Exception:
        logger.exception("Could not load recent national source history")
        return []


async def close_database() -> None:
    if engine is not None:
        await engine.dispose()
