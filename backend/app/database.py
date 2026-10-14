from __future__ import annotations

import logging
from datetime import datetime
from typing import Any

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from app.settings import settings

logger = logging.getLogger(__name__)
engine: AsyncEngine | None = None


async def start_database() -> bool:
    global engine
    if not settings.database_url:
        logger.info("DATABASE_URL is not configured; telemetry persistence is disabled")
        return False
    engine = create_async_engine(settings.database_url, pool_pre_ping=True)
    try:
        async with engine.begin() as connection:
            await connection.execute(text("CREATE EXTENSION IF NOT EXISTS timescaledb"))
            await connection.execute(
                text(
                    """CREATE TABLE IF NOT EXISTS telemetry (
                        observed_at TIMESTAMPTZ NOT NULL,
                        node_id TEXT NOT NULL,
                        load_mw DOUBLE PRECISION NOT NULL,
                        voltage_kv DOUBLE PRECISION NOT NULL,
                        load_percent DOUBLE PRECISION NOT NULL,
                        status TEXT NOT NULL,
                        PRIMARY KEY (observed_at, node_id)
                    )"""
                )
            )
            await connection.execute(
                text("SELECT create_hypertable('telemetry', 'observed_at', if_not_exists => TRUE)")
            )
        logger.info("TimescaleDB telemetry persistence connected")
        return True
    except Exception:
        logger.exception("TimescaleDB unavailable; continuing with in-memory telemetry")
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
        }
        for node in snapshot["nodes"]
    ]
    try:
        async with engine.begin() as connection:
            await connection.execute(
                text(
                    """INSERT INTO telemetry
                    (observed_at, node_id, load_mw, voltage_kv, load_percent, status)
                    VALUES (:observed_at, :node_id, :load_mw, :voltage_kv, :load_percent, :status)
                    ON CONFLICT (observed_at, node_id) DO NOTHING"""
                ),
                rows,
            )
    except Exception:
        logger.exception("Could not persist telemetry snapshot")


async def close_database() -> None:
    if engine is not None:
        await engine.dispose()
