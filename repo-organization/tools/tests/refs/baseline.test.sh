#!/usr/bin/env bash
# Tests for refs check baselines: a main checkout's baseline against a worktree of it.
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
build_fixture
trap 'rm -rf "$T"' EXIT
R="$tool"
P="$T/Projects"
tab=$'\t'

"$R" check "${RARGS[@]}" --record >/dev/null 2>&1; rc=$?
[[ $rc -eq 0 && -s "$T/state/refs-baseline-h1.tsv" ]]; expect "--record writes refs-baseline-<host>.tsv and exits 0" $?
grep -q "^h1${tab}repo-a${tab}live.md${tab}" "$T/state/refs-baseline-h1.tsv"; expect "the baseline is keyed by host, repo name, file, and path" $?

git -C "$P/repo-a" worktree add -q "$T/wt" -b side
out=$("$R" check "${RARGS[@]}" --checkout "repo-a=$T/wt" 2>&1); rc=$?
[[ $rc -eq 0 ]] && ! grep -q "^broken\|^live-tie\|^rewrite\|^retired" <<<"$out"; expect "a worktree of the same repo reports nothing new" $?

printf 'planted: %s/planted/specs/gone.md\n' initiatives > "$T/wt/planted.md"
git -C "$T/wt" add planted.md && git -C "$T/wt" commit -q -m plant
out=$("$R" check "${RARGS[@]}" --checkout "repo-a=$T/wt" 2>&1); rc=$?
[[ $rc -ne 0 && $(grep -c "^broken${tab}" <<<"$out") -eq 1 ]] && grep -q "^broken${tab}repo-a${tab}planted.md" <<<"$out"
expect "a break planted only in the worktree is the one new hit" $?
exit $fail
