#!/usr/bin/env bash
# Tests for roadmap-count against the fixtures beside this file.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../../roadmap-count"
fail=0

expect() { # fixture want
  local got
  got=$("$tool" "$here/$1" 2>&1)
  if [[ $got == "$2" ]]; then echo "ok   $1 counts $2"; else echo "FAIL $1: want $2, got $got"; fail=1; fi
}

expect bullets.md 3
expect headings.md 3
expect mixed.md 4

"$tool" >/dev/null 2>&1
if [[ $? -eq 2 ]]; then echo "ok   no argument exits 2"; else echo "FAIL no argument should exit 2"; fail=1; fi

exit $fail
