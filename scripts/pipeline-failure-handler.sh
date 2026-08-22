#!/usr/bin/env bash
# pipeline-failure-handler.sh
# Emits structured diagnostic information on pipeline failure.
# Usage: source this script or call it as an after_script / post-step hook.

set -euo pipefail

echo "===== PIPELINE FAILURE DIAGNOSTICS ====="
echo "Timestamp   : $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "Pipeline ID : ${CI_PIPELINE_ID:-${GITHUB_RUN_ID:-unknown}}"
echo "Stage       : ${CI_JOB_STAGE:-${GITHUB_JOB:-unknown}}"
echo "Job         : ${CI_JOB_NAME:-${GITHUB_WORKFLOW:-unknown}}"
echo "Branch      : ${CI_COMMIT_REF_NAME:-${GITHUB_REF_NAME:-unknown}}"
echo "Commit SHA  : ${CI_COMMIT_SHA:-${GITHUB_SHA:-unknown}}"
echo "Actor       : ${GITLAB_USER_LOGIN:-${GITHUB_ACTOR:-unknown}}"
echo ""
echo "--- Changed Files (last commit) ---"
git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "(unable to determine changed files)"
echo ""
echo "--- Last 50 lines of job log (stderr) ---"
# Consumers should redirect their step output to a log file and tail it here.
if [ -f "/tmp/job.log" ]; then
  tail -n 50 /tmp/job.log
else
  echo "(no /tmp/job.log found — ensure steps redirect output for post-mortem capture)"
fi
echo "========================================"
