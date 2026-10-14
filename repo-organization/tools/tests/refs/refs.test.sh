#!/usr/bin/env bash
# Tests for refs: classes, scope exclusions, and the apply mode over a fixture.
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
build_fixture
only=$(mktemp -d)
trap 'rm -rf "$T" "$only"' EXIT
R="$tool"
P="$T/Projects"
tab=$'\t'

out=$("$R" check "${RARGS[@]}" 2>&1); rc=$?
[[ $(head -1 <<<"$out") == refs\ * ]]; expect "first line records the tool sha" $?
grep -q "^broken${tab}repo-a${tab}notes.md${tab}initiatives/ghost/specs/none.md" <<<"$out"; expect "a missing initiatives/<id>/ path is broken" $?
grep -q "^retired-target${tab}repo-a${tab}docs/superpowers/plans/hist.md${tab}" <<<"$out"; expect "a history file's retired reference is listed as retired-target" $?
grep -q "^live-tie${tab}repo-a${tab}live.md${tab}" <<<"$out"; expect "a live file's retired reference is a live-tie" $?
[[ $rc -ne 0 ]]; expect "check exits nonzero on broken and live-tie" $?
grep -q "^broken${tab}repo-a${tab}notes.md${tab}code/missing.txt" <<<"$out"; expect "a reference broken before the move is broken, not a rewrite" $?
grep -q "^rewrite${tab}repo-a${tab}notes.md${tab}docs/superpowers/plans/old-x.md${tab}~/Projects/initiatives/widget/plans/old-x.md" <<<"$out"
expect "a destination that exists only in the map resolves" $?
grep -q "^rewrite${tab}repo-a${tab}notes.md${tab}code/real.txt${tab}~/Projects/repo-b/lib/real.txt" <<<"$out"; expect "a moved code path resolves through gh" $?
! grep -q "${tab}repo-b${tab}notes.md" <<<"$out"; expect "a bare path resolves against its own repo, not the other repo's map row" $?
! grep -q 'n.md\|package-lock\|pr-107' <<<"$out"; expect "excluded locations produce no hits" $?
grep -q "^rewrite${tab}memory${tab}" <<<"$out"; expect "memory .md files are scanned" $?
! grep -q 'm.md.tmp' <<<"$out"; expect "memory .tmp files are not scanned" $?

# A retired-target reference alone leaves the exit status at 0.
printf 'repo\trole\tpath\nrepo-a\tedit\t~/Projects/repo-a\nrepo-gone\tretire\t~/Projects/repo-gone\n' > "$only/scope.tsv"
mkdir -p "$only/Projects/repo-a/docs/superpowers"
printf '~/Projects/repo-gone/a.md\n' > "$only/Projects/repo-a/docs/superpowers/h.md"
gitrepo "$only/Projects/repo-a"
PROJECTS_ROOT="$only/Projects" "$R" check --scope "$only/scope.tsv" --map "$T/map.tsv" --host h1 --state-dir "$only/s" >/dev/null 2>&1
expect "a retired-target reference alone exits 0" $?

# A missing read row fails by name, except on the thinkpad.
mv "$P/repo-leg" "$T/leg-away"
"$R" check "${RARGS[@]}" >/dev/null 2>"$T/err"; rc=$?
[[ $rc -eq 2 ]] && grep -q repo-leg "$T/err"; expect "a missing read row exits 2 and names the row" $?
tp=$("$R" check "${RARGS[@]}" --host thinkpad-x1 2>&1)
grep -q "^absent${tab}repo-leg" <<<"$tp"; expect "on thinkpad-x1 a missing read row is reported absent" $?
mv "$T/leg-away" "$P/repo-leg"

# Apply.
for f in package-lock.json _salvage/n.md tests/fixtures/ci-green/pr-107-files.txt .claude/worktrees/w/n.md; do
  cp "$P/repo-a/$f" "$T/keep-$(echo "$f" | tr / _)"
done
cp "$MEM/m.md" "$T/m.md.pre"
a1=$("$R" apply "${RARGS[@]}" --root "$T" --tar-dir "$T/tars" 2>&1)
n1=$(grep -c "^rewrote${tab}" <<<"$a1")
[[ $n1 -ge 1 ]]; expect "first apply rewrites at least one file ($n1)" $?
tar=$(find "$T/tars" -name '*.tar' | head -1)
[[ -n $tar ]] && [[ $(tar -xOf "$tar" --wildcards '*/memory/m.md') == "$(cat "$T/m.md.pre")" ]]; expect "the memory tar holds the pre-edit bytes" $?
tl=$(grep -n "^tar${tab}" <<<"$a1" | head -1 | cut -d: -f1)
rl=$(grep -n "^rewrote${tab}" <<<"$a1" | head -1 | cut -d: -f1)
[[ -n $tl && $tl -lt $rl ]]; expect "the tar is reported before the first rewrite" $?
grep -q '~/Projects/initiatives/widget/plans/old-x.md' "$P/repo-a/notes.md"; expect "notes.md carries the new path" $?
grep -q 'code/missing.txt' "$P/repo-a/notes.md"; expect "a reference broken before the move is left alone" $?
grep -q 'initiatives/widget/plans/old-x.md' "$MEM/m.md"; expect "the memory file is rewritten" $?
grep -q 'docs/superpowers/plans/old-x.md' "$MEM/m.md.tmp"; expect "the memory .tmp file is untouched" $?
grep -q 'docs/superpowers/plans/old-x.md' "$P/repo-b/notes.md"; expect "the other repo's identical relative path is untouched" $?
same=0
for f in package-lock.json _salvage/n.md tests/fixtures/ci-green/pr-107-files.txt .claude/worktrees/w/n.md; do
  cmp -s "$P/repo-a/$f" "$T/keep-$(echo "$f" | tr / _)" || same=1
done
[[ $same -eq 0 ]]; expect "a lockfile, _salvage, the named fixture, and .claude/worktrees stay byte-identical" $?
a2=$("$R" apply "${RARGS[@]}" --root "$T" --tar-dir "$T/tars2" 2>&1)
[[ $(grep -c "^rewrote${tab}" <<<"$a2") -eq 0 ]]; expect "a second apply rewrites nothing" $?
exit $fail
