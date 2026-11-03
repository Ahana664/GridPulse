from __future__ import annotations

import os


class Settings:
    app_name = "GridPulse API"
    api_prefix = "/api/v1"
    tick_seconds = float(os.getenv("GRID_TICK_SECONDS", "3"))
    database_url = os.getenv("DATABASE_URL", "")
    supabase_url = os.getenv("SUPABASE_URL", "")
    supabase_key = (
        os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
        or os.getenv("SUPABASE_ANON_KEY", "")
        or os.getenv("SUPABASE_KEY", "")
    )
    supabase_table = os.getenv("SUPABASE_TABLE", "hourly_generation")
    grid_source_url = os.getenv("GRID_SOURCE_URL", "")
    grid_source_poll_seconds = max(60, int(os.getenv("GRID_SOURCE_POLL_SECONDS", "3600")))
    grid_source_timezone = os.getenv("GRID_SOURCE_TIMEZONE", "Asia/Dhaka")
    grid_national_baseline_demand_mw = float(os.getenv("GRID_NATIONAL_BASELINE_DEMAND_MW", "15000"))
    grid_persist_interval_seconds = max(30, int(os.getenv("GRID_PERSIST_INTERVAL_SECONDS", "300")))
    gemini_api_key = os.getenv("GEMINI_API_KEY", "")
    gemini_model = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
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
