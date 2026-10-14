from __future__ import annotations

import os


class Settings:
    app_name = "GridPulse API"
    api_prefix = "/api/v1"
    tick_seconds = float(os.getenv("GRID_TICK_SECONDS", "3"))
    database_url = os.getenv("DATABASE_URL", "")
    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    celery_enabled = os.getenv("CELERY_ENABLED", "false").lower() == "true"
    cors_origins = [
        origin.strip()
        for origin in os.getenv(
            "CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000"
        ).split(",")
        if origin.strip()
    ]


settings = Settings()
