from __future__ import annotations

from datetime import datetime, timedelta, timezone
from functools import lru_cache

import numpy as np
import pandas as pd
from sklearn.ensemble import HistGradientBoostingRegressor

try:
    from xgboost import XGBRegressor
except ImportError:  # Keep local development usable when the optional native wheel is unavailable.
    XGBRegressor = None  # type: ignore[assignment,misc]

_historical_model = None


def _features(hours: np.ndarray, day_numbers: np.ndarray) -> np.ndarray:
    return np.column_stack(
        (
            np.sin(2 * np.pi * hours / 24),
            np.cos(2 * np.pi * hours / 24),
            np.sin(2 * np.pi * day_numbers / 7),
            np.cos(2 * np.pi * day_numbers / 7),
            26 + 8 * np.sin(2 * np.pi * (hours - 8) / 24),
        )
    )


def _historical_features(timestamps: list[datetime], origin: datetime) -> np.ndarray:
    elapsed_days = np.array([(stamp - origin).total_seconds() / 86_400 for stamp in timestamps])
    hours = np.array([stamp.hour + stamp.minute / 60 for stamp in timestamps])
    weekdays = np.array([stamp.weekday() for stamp in timestamps])
    year_days = np.array([stamp.timetuple().tm_yday for stamp in timestamps])
    return np.column_stack((
        np.sin(2 * np.pi * hours / 24),
        np.cos(2 * np.pi * hours / 24),
        np.sin(2 * np.pi * weekdays / 7),
        np.cos(2 * np.pi * weekdays / 7),
        np.sin(2 * np.pi * year_days / 365.25),
        np.cos(2 * np.pi * year_days / 365.25),
        elapsed_days,
    ))


def set_historical_demand(records: list[dict[str, object]]) -> bool:
    """Fit the real-demand forecaster when at least one week of hourly samples exists."""
    global _historical_model
    usable: list[tuple[datetime, float]] = []
    for record in records:
        demand = record.get("demand_mw")
        observed_at = record.get("observed_at")
        if demand is None or observed_at is None:
            continue
        try:
            stamp = datetime.fromisoformat(str(observed_at).replace("Z", "+00:00"))
            if stamp.tzinfo is None:
                stamp = stamp.replace(tzinfo=timezone.utc)
            usable.append((stamp.astimezone(timezone.utc), float(demand)))
        except (TypeError, ValueError):
            continue
    usable.sort(key=lambda item: item[0])
    if len(usable) < 168:
        _historical_model = None
        return False

    timestamps = [item[0] for item in usable]
    origin = timestamps[0]
    features = _historical_features(timestamps, origin)
    targets = np.asarray([item[1] for item in usable], dtype=float)
    model = XGBRegressor(
        n_estimators=90,
        max_depth=3,
        learning_rate=0.05,
        subsample=0.9,
        colsample_bytree=1.0,
        n_jobs=1,
        objective="reg:squarederror",
        verbosity=0,
    ) if XGBRegressor is not None else HistGradientBoostingRegressor(
        max_iter=100, max_leaf_nodes=16, random_state=7
    )
    model.fit(features, targets)
    _historical_model = (model, origin)
    return True


def get_forecast_model_name() -> str:
    if _historical_model is not None:
        return "xgboost-historical" if XGBRegressor is not None else "sklearn-historical"
    return "xgboost-synthetic-fallback" if XGBRegressor is not None else "sklearn-synthetic-fallback"


@lru_cache(maxsize=1)
def _trained_model():
    days = np.repeat(np.arange(70), 24)
    hours = np.tile(np.arange(24), 70)
    features = _features(hours, days)
    daily = 570 * np.sin(2 * np.pi * (hours - 8) / 24)
    afternoon = 280 * np.maximum(0, np.sin(2 * np.pi * (hours - 11) / 24))
    weekend = np.isin(days % 7, (5, 6)).astype(float) * -110
    weather = 9 * (features[:, 4] - 26)
    target = 4_100 + daily + afternoon + weekend + weather
    training = pd.DataFrame(features, columns=["hour_sin", "hour_cos", "day_sin", "day_cos", "temperature"])
    if XGBRegressor is not None:
        model = XGBRegressor(
            n_estimators=45,
            max_depth=3,
            learning_rate=0.08,
            subsample=0.9,
            colsample_bytree=1.0,
            n_jobs=1,
            objective="reg:squarederror",
            verbosity=0,
        )
    else:
        model = HistGradientBoostingRegressor(max_iter=60, max_leaf_nodes=12, random_state=7)
    model.fit(training.to_numpy(), target)
    return model


def forecast_demand(
    current_load_mw: float,
    hour: int,
    horizon: int = 24,
    national_current_demand_mw: float | None = None,
) -> list[dict[str, float | str]]:
    if _historical_model is not None and national_current_demand_mw and national_current_demand_mw > 0:
        model, origin = _historical_model
        start = datetime.now(timezone.utc).replace(minute=0, second=0, microsecond=0)
        future = [start + timedelta(hours=offset) for offset in range(1, horizon + 1)]
        predictions = np.maximum(0, np.asarray(model.predict(_historical_features(future, origin)), dtype=float))
        local_ratio = current_load_mw / national_current_demand_mw
        return [
            {"time": stamp.strftime("%H:00"), "load": round(float(prediction * local_ratio), 1)}
            for stamp, prediction in zip(future, predictions, strict=True)
        ]

    model = _trained_model()
    future_hours = np.array([(hour + offset) % 24 for offset in range(1, horizon + 1)])
    day_numbers = np.arange(horizon) // 24
    features = pd.DataFrame(
        _features(future_hours, day_numbers),
        columns=["hour_sin", "hour_cos", "day_sin", "day_cos", "temperature"],
    )
    predictions = np.asarray(model.predict(features), dtype=float)
    current_baseline = float(model.predict(_features(np.array([hour]), np.array([0])))[0])
    adjustment = current_load_mw - current_baseline
    predictions = np.maximum(0, predictions + adjustment * 0.35)
    return [
        {
            "time": f"{int(future_hour):02d}:00",
            "load": round(float(load), 1),
        }
        for future_hour, load in zip(future_hours, predictions, strict=True)
    ]
