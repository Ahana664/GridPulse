from __future__ import annotations

from functools import lru_cache

import numpy as np
import pandas as pd
from sklearn.ensemble import HistGradientBoostingRegressor

try:
    from xgboost import XGBRegressor
except ImportError:  # Keep local development usable when the optional native wheel is unavailable.
    XGBRegressor = None  # type: ignore[assignment,misc]


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


def forecast_demand(current_load_mw: float, hour: int, horizon: int = 24) -> list[dict[str, float | str]]:
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
