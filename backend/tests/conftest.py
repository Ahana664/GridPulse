from __future__ import annotations

import pytest

from app.settings import settings


@pytest.fixture(autouse=True)
def isolate_external_services(monkeypatch: pytest.MonkeyPatch) -> None:
    """Keep the test suite offline and independent of developer credentials."""
    for name in (
        "database_url",
        "supabase_url",
        "supabase_key",
        "grid_source_url",
        "gemini_api_key",
    ):
        monkeypatch.setattr(settings, name, "")
