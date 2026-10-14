#!/usr/bin/env bash
# Tests for extract: a pure git mv rename verifies only when both names are listed.
# extract does not read scope.tsv, so it has no scope-harness run.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tool="$here/../../extract"
fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }

if ! git filter-repo --version > /dev/null 2>&1; then
  echo "SKIP git filter-repo is not installed; the extract tests did not run"
  exit 0
fi

src="$tmp/src"
git init -q -b main "$src"
mkdir -p "$src/bin" "$src/other"
printf 'line one\nline two\nline three\nline four\n' > "$src/bin/review-desk"
printf 'unrelated\n' > "$src/other/keep.txt"
git -C "$src" add -A && git -C "$src" commit -q -m "add review-desk and other"
printf 'second\n' >> "$src/bin/review-desk"
git -C "$src" commit -q -am "edit review-desk"
git -C "$src" mv bin/review-desk bin/approval-queue
git -C "$src" commit -q -m "rename to approval-queue"
printf 'third\n' >> "$src/bin/approval-queue"
git -C "$src" commit -q -am "edit approval-queue"

out=$("$tool" --source "$src" --state-dir "$tmp/both" --name both --path bin/approval-queue --path bin/review-desk); rc=$?
v="$tmp/both/extracts/both/verify.txt"
[[ $rc -eq 0 ]] && ok "both names listed: exit 0" || bad "both names listed: exit $rc"
[[ $(tail -1 "$v") == verified ]] && ok "both names listed: verify.txt ends verified" || bad "verify.txt does not end verified"
grep -q "^pin $(git -C "$src" rev-parse HEAD)$" "$v" && ok "verify.txt records the pin" || bad "pin missing"
grep -qE '^tool [0-9a-f]{40}$' "$v" && ok "verify.txt records the tool sha" || bad "tool sha missing"
first=$(git -C "$src" log --follow --diff-filter=A --format=%H -- bin/approval-queue | tail -1)
rename=$(git -C "$src" log --diff-filter=R --format=%H | head -1)
[[ $(git -C "$src" log -1 --format=%ct "$first") -le $(git -C "$src" log -1 --format=%ct "$rename") && $first != "$rename" ]] \
  && ok "the source-side first commit predates the rename" || bad "first commit does not predate the rename"
[[ -z $(git -C "$tmp/both/extracts/both/repo" ls-files other) ]] && ok "unlisted paths are gone from the extract" || bad "other/ survived"

out=$("$tool" --source "$src" --state-dir "$tmp/new" --name newonly --path bin/approval-queue); rc=$?
v="$tmp/new/extracts/newonly/verify.txt"
[[ $rc -ne 0 ]] && ok "new name only: exit nonzero" || bad "new name only: exit 0"
[[ $(tail -1 "$v") != verified ]] && ok "new name only: verify.txt does not end verified" || bad "new name only: ends verified"
grep -q 'first-commit bin/approval-queue.*MISMATCH' "$v" && ok "new name only: the first-commit mismatch is reported" || bad "mismatch not reported"
grep -q '^tip-tree: ok$' "$v" && ok "new name only: the tip tree still matches (the gap the first-commit check closes)" || bad "tip tree unexpectedly differs"

"$tool" --source "$src" --state-dir "$tmp/both" --name both --path bin/approval-queue > /dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] && ok "an existing extract is never overwritten" || bad "re-run overwrote an extract"

exit $fail
