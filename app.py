"""
Pipeline Doctor demo app.

This is a deliberately tiny Flask app whose sole purpose is to fail in
controlled, specific ways so Pipeline Doctor has something real to diagnose.

Set BREAK_MODE to one of the values below (in the CI workflow, or locally)
to trigger a specific failure. Leave it unset / set to "none" for a clean,
passing build.

    none              -> everything passes
    missing_dep       -> ImportError / ModuleNotFoundError at import time
    failing_test      -> unit test assertion fails
    bad_config        -> app crashes on startup reading a missing env var
    slow_deploy       -> health check times out (simulated)
"""

import os

BREAK_MODE = os.environ.get("BREAK_MODE", "none")

if BREAK_MODE == "missing_dep":
    # boto3 is intentionally NOT in requirements.txt when this mode is on
    # (see requirements.txt / requirements.broken.txt)
    import boto3  # noqa: F401

if BREAK_MODE == "bad_config":
    # Simulates a deploy that reads a required env var no one set
    DATABASE_URL = os.environ["DATABASE_URL"]  # raises KeyError if unset


def add(a, b):
    """Simple function the test suite exercises."""
    return a + b


def get_status():
    return {"status": "ok", "break_mode": BREAK_MODE}


if __name__ == "__main__":
    print(get_status())
