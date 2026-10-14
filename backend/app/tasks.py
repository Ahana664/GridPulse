from __future__ import annotations

from datetime import datetime, timezone
from uuid import uuid4

import pandas as pd

from app.celery_app import celery_app


@celery_app.task(name="gridpulse.generate_report")
def generate_report(report_type: str, telemetry: list[dict[str, object]]) -> dict[str, object]:
    frame = pd.DataFrame(telemetry)
    if frame.empty:
        summary: dict[str, float] = {"sample_count": 0.0}
    else:
        summary = {
            "sample_count": float(len(frame)),
            "average_load_mw": round(float(frame["load"].mean()), 1),
            "peak_load_mw": round(float(frame["load"].max()), 1),
            "minimum_load_mw": round(float(frame["load"].min()), 1),
        }
    return {
        "id": str(uuid4()),
        "type": report_type,
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "summary": summary,
    }
