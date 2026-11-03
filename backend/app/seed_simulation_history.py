from __future__ import annotations

import argparse
import asyncio
from datetime import datetime, timedelta, timezone
from typing import Any

from sqlalchemy import text

from app import database
from app.simulator import GridSimulator


async def seed_history(hours: int, seed: int) -> dict[str, Any]:
    if hours < 2 or hours > 4320:
        raise ValueError("hours must be between 2 and 4320")
    if not await database.start_database():
        raise RuntimeError("DATABASE_URL is unset or PostgreSQL is unavailable")

    try:
        grid = GridSimulator(seed=seed)
        last_hour = datetime.now(timezone.utc).replace(minute=0, second=0, microsecond=0)
        first_hour = last_hour - timedelta(hours=hours - 1)
        for offset in range(hours):
            snapshot = grid.tick()
            snapshot["timestamp"] = (first_hour + timedelta(hours=offset)).isoformat()
            await database.save_snapshot(snapshot)

        if database.engine is None:
            raise RuntimeError("Database engine closed before verification")
        async with database.engine.connect() as connection:
            result = await connection.execute(
                text(
                    """SELECT COUNT(*) AS row_count,
                              COUNT(DISTINCT date_trunc('hour', observed_at)) AS hour_count,
                              COUNT(DISTINCT node_id) AS node_count,
                              MIN(observed_at) AS first_observed_at,
                              MAX(observed_at) AS last_observed_at
                       FROM telemetry
                       WHERE observed_at >= :start_at AND observed_at <= :end_at
                         AND source = 'simulator'"""
                ),
                {"start_at": first_hour, "end_at": last_hour},
            )
            verified = dict(result.mappings().one())
        return {
            "data_type": "simulated_telemetry_dry_run",
            "disclaimer": "Generated GridPulse simulator history. Not PGCB data and not real-world measurements.",
            "requested_hours": hours,
            "verified_hourly_samples": int(verified["hour_count"]),
            "verified_node_readings": int(verified["row_count"]),
            "verified_unique_nodes": int(verified["node_count"]),
            "first_observed_at": verified["first_observed_at"].isoformat() if verified["first_observed_at"] else None,
            "last_observed_at": verified["last_observed_at"].isoformat() if verified["last_observed_at"] else None,
            "seed": seed,
        }
    finally:
        await database.close_database()


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed clearly labeled simulated GridPulse history for a DB dry run.")
    parser.add_argument("--hours", type=int, default=48, help="Hourly samples to generate (2-4320, default 48).")
    parser.add_argument("--seed", type=int, default=3208, help="Deterministic simulator seed.")
    args = parser.parse_args()
    result = asyncio.run(seed_history(args.hours, args.seed))
    for key, value in result.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()
