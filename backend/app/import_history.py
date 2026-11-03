from __future__ import annotations

import asyncio
import sys
from pathlib import Path

from app.database import close_database, save_national_readings, start_database
from app.live_data import parse_grid_history_csv


async def import_csv(csv_path: Path) -> int:
    if not await start_database():
        raise RuntimeError("DATABASE_URL is not configured or the database is unavailable")
    try:
        readings = parse_grid_history_csv(csv_path.read_text(encoding="utf-8-sig"))
        await save_national_readings(readings)
        return len(readings)
    finally:
        await close_database()


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python -m app.import_history <hourly-history.csv>")
    count = asyncio.run(import_csv(Path(sys.argv[1])))
    print(f"Imported or updated {count} hourly national readings.")


if __name__ == "__main__":
    main()
