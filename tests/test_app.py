import os
import pytest
from app import add, get_status

BREAK_MODE = os.environ.get("BREAK_MODE", "none")


def test_add():
    if BREAK_MODE == "failing_test":
        # Deliberately wrong expected value to produce a real AssertionError
        assert add(2, 2) == 5, "expected 5 (intentionally wrong) to trigger BREAK_MODE=failing_test"
    else:
        assert add(2, 2) == 4


def test_get_status():
    result = get_status()
    assert result["status"] == "ok"


@pytest.mark.skipif(BREAK_MODE == "slow_deploy", reason="simulated timeout handled in CI step, not here")
def test_placeholder_for_slow_deploy():
    # slow_deploy is simulated at the CI/deploy-step level (see workflow),
    # not as a unit test failure -- this test just documents that.
    assert True
