from __future__ import annotations

from typing import Any


def validate_flow_proposal(
    connections: list[dict[str, Any]], connection_id: str, proposed_mw: float
) -> dict[str, Any]:
    """Deterministically validate a suggested virtual flow; never applies it."""
    connection = next((line for line in connections if line["id"] == connection_id), None)
    if connection is None:
        return {
            "connectionId": connection_id,
            "proposedMw": proposed_mw,
            "capacityMw": None,
            "accepted": False,
            "message": "Unknown simulated connection; proposal is blocked",
            "gridActionTaken": False,
        }
    within_limit = proposed_mw >= 0 and proposed_mw <= float(connection["capacity"])
    return {
        "connectionId": connection["id"],
        "proposedMw": proposed_mw,
        "capacityMw": connection["capacity"],
        "accepted": within_limit,
        "message": "Recommendation is within the simulated line limit" if within_limit else "Recommendation exceeds the simulated line limit and is blocked",
        "gridActionTaken": False,
    }
