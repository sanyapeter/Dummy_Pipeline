"""
Simulated deploy health check for the Pipeline Doctor demo.

The CI workflow runs this as the DEPLOY stage. It succeeds for a normal build
and only fails for the `slow_deploy` break mode (a simulated health-check
timeout), matching the break modes documented in app.py.
"""
import os
import sys
import time

BREAK_MODE = os.environ.get("BREAK_MODE", "none")


def main() -> int:
    if BREAK_MODE == "slow_deploy":
        print("Deploy: waiting for service to become healthy...")
        time.sleep(2)  # stand-in for a real readiness poll
        print("ERROR: health check timed out — service did not become ready in time.")
        return 1

    # Import the app so a genuinely broken build also fails the deploy stage.
    try:
        import app  # noqa: F401
    except Exception as exc:  # pragma: no cover - exercised via break modes
        print(f"ERROR: app failed to import during deploy check: {exc}")
        return 1

    print(f"Deploy health check passed (break_mode={BREAK_MODE}). Service is up.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
