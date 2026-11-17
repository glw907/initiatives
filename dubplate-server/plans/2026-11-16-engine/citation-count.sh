#!/usr/bin/env bash
# Print comment-text citation hits for non-test Go files under cmd and
# internal of the repo in the current directory. $1 is narrow, wide (the
# planner's probe pattern), or gate (the pattern in wide-gate-pattern.txt).
set -euo pipefail
narrow='ruled, conductor|Resolution R|rung [0-9]|Task [0-9]|\(C[0-9]|plans/.*\.md:[0-9]|_salvage/.*:[0-9]|Ruled, |\bR-[0-9]+[a-z]+[0-9]*'
wide="$narrow"'|\b[Cc]ontract [0-9]|\b[Rr]ungs?\b|\b[0-9]{1,2}[a-d]\b|\b[Pp]ass [0-9]|\b[Tt]his (pass|task)\b|\b[Ll]ater pass\b|\bRuling [A-Z]\b|\bfold [A-Z]|\bR-?[0-9]+[a-z0-9]*\b|\bR-[A-Z]\b|\bC[0-9]+[a-z]?\b|\([Mm][0-9]+\)|\(review [a-z0-9]+\)|spec:[0-9]|spec, :[0-9]|\bconductor\b|\bHISTORY\b|\bResolution\b|mechanics study'
here=$(cd "$(dirname "$0")" && pwd)
pat="$narrow"; [ "${1:-narrow}" = wide ] && pat="$wide"
[ "${1:-narrow}" = gate ] && pat="$(cat "$here/wide-gate-pattern.txt")"
git ls-files -- cmd internal | grep -E '\.go$' | grep -v '_test\.go$' | sort -u |
  xargs -r grep -Hn '//' |
  awk 'match($0, /^[^:]+:[0-9]+:/) { head = substr($0, RSTART, RLENGTH); rest = substr($0, RLENGTH + 1); i = index(rest, "//"); if (i) print head substr(rest, i) }' |
  grep -E "$pat" || true
