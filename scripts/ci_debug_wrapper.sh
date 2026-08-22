#!/usr/bin/env bash
# ci_debug_wrapper.sh — wraps any CI command and ensures failure details are always logged
set -euo pipefail

log_failure() {
  local exit_code=$?
  echo "======================================" >&2
  echo "CI FAILURE DIAGNOSTICS" >&2
  echo "Exit code : ${exit_code}" >&2
  echo "Stage     : ${CI_JOB_NAME:-unknown}" >&2
  echo "Pipeline  : ${CI_PIPELINE_ID:-unknown}" >&2
  echo "Commit    : ${CI_COMMIT_SHA:-unknown}" >&2
  echo "Branch    : ${CI_COMMIT_REF_NAME:-unknown}" >&2
  echo "Changed files (last commit):" >&2
  git diff --name-only HEAD~1 HEAD 2>/dev/null || echo '  (unable to determine)' >&2
  echo "Last 50 lines of stdout/stderr captured above." >&2
  echo "======================================" >&2
  exit "${exit_code}"
}

trap log_failure ERR

# Execute the command passed as arguments
"$@"
