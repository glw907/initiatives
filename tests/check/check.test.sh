#!/usr/bin/env bash
# Tests for scripts/check and scripts/index against tests/fixtures/check/<state>.
set -uo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd)"
fx="$here/tests/fixtures/check"
fail=0

expect_fail() { # fixture needle [args...]
  local name=$1 needle=$2 out rc
  shift 2
  out=$("$here/scripts/check" "$@" "$fx/$name" 2>&1); rc=$?
  if [[ $rc -ne 0 && $out == *"$needle"* ]]; then
    echo "ok   $name fails naming $needle"
  else
    echo "FAIL $name: rc=$rc, want a failure naming $needle; got: $out"; fail=1
  fi
}
expect_pass() { # fixture [args...]
  local name=$1 out rc
  shift
  out=$("$here/scripts/check" "$@" "$fx/$name" 2>&1); rc=$?
  if [[ $rc -eq 0 ]]; then echo "ok   $name passes ${*:-}"; else echo "FAIL $name: rc=$rc: $out"; fail=1; fi
}

expect_pass good
expect_fail empty "no initiative records"
expect_fail no-yaml "gamma/"
expect_fail bad-yaml "gamma/initiative.yaml"
expect_fail id-mismatch "gamma/initiative.yaml: id 'delta'"
expect_fail duplicate-id "duplicate id alpha"
expect_fail bad-status "unknown status"
expect_fail missing-field "missing required field owner"
expect_fail stale-index "README.md: index disagrees"

export INITIATIVES_GH="$fx/gh-stub"
expect_pass good --repos
expect_fail bad-repo "no-such-repo" --repos
expect_pass bad-repo # CI mode skips the repos state

# scripts/index is idempotent and repairs a stale index.
tmp=$(mktemp -d)
cp -r "$fx/stale-index/." "$tmp"
"$here/scripts/index" "$tmp" && "$here/scripts/check" "$tmp" >/dev/null && echo "ok   index repairs stale-index" \
  || { echo "FAIL index did not repair stale-index"; fail=1; }
before=$(cat "$tmp/README.md")
"$here/scripts/index" "$tmp"
[[ $before == "$(cat "$tmp/README.md")" ]] && echo "ok   index is idempotent" || { echo "FAIL index is not idempotent"; fail=1; }
rm -rf "$tmp"

exit $fail
