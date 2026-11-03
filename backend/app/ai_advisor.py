from __future__ import annotations

import json
from typing import Any

import httpx

from app.safety import validate_flow_proposal


async def analyze_grid(
    *,
    api_key: str,
    model: str,
    snapshot: dict[str, Any],
    historical: dict[str, Any],
) -> dict[str, Any]:
    """Ask Gemini for advisory text; validate any proposed virtual flow locally."""
    macro = snapshot.get("nationalData") or {}
    prompt = f"""You are an advisory analyst for GridPulse, an academic grid simulation. This is read-only decision support, never an operating command.

Analyze these verified inputs:
Current simulated 20-node snapshot summary: {json.dumps(snapshot.get('summary', {}), separators=(',', ':'))}
Latest national source record (may be absent/stale): {json.dumps(macro, separators=(',', ':'))}
Six-month hourly history summary: {json.dumps({key: value for key, value in historical.items() if key != 'recent_24h'}, separators=(',', ':'))}
Last 24 hourly national records: {json.dumps(historical.get('recent_24h', []), separators=(',', ':'))}
Recent simulated trend: {json.dumps(snapshot.get('history', [])[-24:], separators=(',', ':'))}
Current alerts: {json.dumps(snapshot.get('alerts', [])[:15], separators=(',', ':'))}

Return JSON with keys: forecast_3_6h (string), anomalies (array of strings), recommendation (string), and suggested_flow (null or object with connection_id string and proposed_mw number). Make a specific flow proposal only if supported by the inputs. Do not invent historical facts. The recommendation must concern only the simulated grid. Never claim to control or route real electricity. The backend will independently enforce line capacity; your proposal is not applied."""
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            endpoint,
            headers={"x-goog-api-key": api_key},
            json={
                "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                "generationConfig": {
                    "temperature": 0.2,
                    "maxOutputTokens": 700,
                    "responseMimeType": "application/json",
                },
            },
        )
        response.raise_for_status()
        payload = response.json()
    try:
        text = payload["candidates"][0]["content"]["parts"][0]["text"].strip()
    except (KeyError, IndexError, TypeError) as exc:
        raise ValueError("Gemini returned no analysis text") from exc

    try:
        result = json.loads(text)
    except json.JSONDecodeError:
        result = {"forecast_3_6h": "", "anomalies": [], "recommendation": text, "suggested_flow": None}
    if not isinstance(result, dict):
        raise ValueError("Gemini returned an invalid analysis object")

    flow = result.get("suggested_flow")
    safety: dict[str, Any] = {
        "accepted": None,
        "message": "No line-flow proposal was returned.",
        "gridActionTaken": False,
    }
    if isinstance(flow, dict):
        try:
            safety = validate_flow_proposal(
                snapshot.get("connections", []),
                str(flow["connection_id"]),
                float(flow["proposed_mw"]),
            )
        except (KeyError, TypeError, ValueError):
            safety = {
                "accepted": False,
                "message": "Malformed flow proposal; blocked by the deterministic safety layer.",
                "gridActionTaken": False,
            }

    parts = []
    for label, key in (("3–6h outlook", "forecast_3_6h"), ("Anomalies", "anomalies"), ("Recommendation", "recommendation")):
        value = result.get(key)
        if isinstance(value, list):
            value = "; ".join(str(item) for item in value)
        if value:
            parts.append(f"{label}: {value}")
    return {
        "analysis": "\n".join(parts) or "No advisory text was returned.",
        "suggestedFlow": flow if isinstance(flow, dict) else None,
        "safetyValidation": safety,
        "model": model,
        "historicalSamples": historical.get("sample_count", 0),
        "historicalWindowDays": 180,
        "gridActionTaken": False,
        "safetyNotice": "Any flow is a simulated proposal only. The safety result does not execute or apply it.",
    }
