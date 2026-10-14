#!/usr/bin/env bash
# scripts/test.sh: validate the real records, then run every *.test.sh by glob.
# A new tool adds its tests as <anything>.test.sh under tests/ or a tests/ dir;
# nothing here lists them.
set -uo pipefail
cd "$(dirname "$0")/.."
status=0

echo "== scripts/check"
scripts/check || status=1

while IFS= read -r t; do
  echo "== $t"
  bash "$t" || status=1
done < <(find . -name '*.test.sh' -not -path './.claude/*' -not -path './node_modules/*' -not -path './tests/fixtures/*' | sort)

[[ $status -eq 0 ]] && echo "all tests passed" || echo "FAILED"
exit $status
