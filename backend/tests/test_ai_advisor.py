from app.ai_advisor import _decode_advisory


def test_decode_advisory_accepts_json_with_preamble() -> None:
    result = _decode_advisory('Recommendation follows: {"forecast_3_6h":"steady","anomalies":[],"recommendation":"Monitor"}')
    assert result["forecast_3_6h"] == "steady"
    assert result["recommendation"] == "Monitor"


def test_decode_advisory_rejects_truncated_json() -> None:
    try:
        _decode_advisory('Recommendation: {"forecast_3_6h":"Load is')
    except ValueError as exc:
        assert "incomplete" in str(exc)
    else:
        raise AssertionError("Truncated advisory JSON should be rejected")