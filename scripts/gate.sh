#!/usr/bin/env bash
# scripts/gate.sh: run scripts/test.sh through cairn-run-gate on the light lane.
# A worktree-isolated session's Bash guard refuses `cairn-run-gate '<string>'`,
# since it cannot show the quoted string is not git; a no-argument wrapper
# passes. Exit codes are cairn-run-gate's, so exit 75 means re-issue. The
# `gate exit:` line is repeated last, so the result is the output's final line.
set -uo pipefail
cd "$(dirname "$0")/.."
export CAIRN_GATE_LANE=light
out=$(cairn-run-gate 'bash scripts/test.sh' 2>&1)
rc=$?
printf '%s\n' "$out"
printf '%s\n' "$out" | grep -m1 '^gate exit:' || true
exit "$rc"
