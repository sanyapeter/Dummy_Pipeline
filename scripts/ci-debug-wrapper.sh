#!/usr/bin/env bash
# Temporary diagnostic wrapper — remove after root cause is identified
# Usage: source this file at the top of any failing CI script
set -euxo pipefail

echo "=== CI DIAGNOSTIC HEADER ==="
echo "Date        : $(date -u)"
echo "Hostname    : $(hostname)"
echo "User        : $(id)"
echo "Shell       : $SHELL"
echo "PWD         : $(pwd)"
echo "Disk usage  : $(df -h . | tail -1)"
echo "Memory      : $(free -m 2>/dev/null || vm_stat 2>/dev/null || echo 'unavailable')"
echo "CI vars     : $(env | grep -E '^(CI|GITHUB|GITLAB|BUILD|PIPELINE)' | sort || true)"
echo "Git ref     : $(git rev-parse --short HEAD 2>/dev/null || echo 'not a git repo')"
echo "Git status  : $(git status --short 2>/dev/null || echo 'unavailable')"
echo "=== END DIAGNOSTIC HEADER ==="

# Trap to print context on any error
trap 'echo "ERROR: command [${BASH_COMMAND}] failed with exit code $? at line ${LINENO}" >&2' ERR
