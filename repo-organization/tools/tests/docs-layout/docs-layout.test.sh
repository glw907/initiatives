#!/usr/bin/env bash
# Tests for docs-layout: the moves, each rewrite rule, pins, records, collisions, --check, and --links.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tool="$here/../../docs-layout"
fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
has() { # description file wanted-text
  if grep -qF -- "$3" "$2"; then ok "$1"; else bad "$1 (no '$3' in $2)"; fi
}

r="$tmp/repo"
git init -q -b main "$r"
git -C "$r" remote add origin https://github.com/glw907/fixture.git
mkdir -p "$r/docs/superpowers/specs" "$r/docs/superpowers/plans" "$r/docs/internal" "$r/src" "$r/tests" "$r/.claude/worktrees/w"
cd "$r" || exit 1
printf 'spec y\n' > docs/superpowers/specs/y.md
printf 'internal x\n' > docs/internal/x.md
cat > docs/superpowers/plans/p.md <<'EOF'
[out](../../internal/x.md) and [sibling](../specs/y.md#top) and [titled](../../internal/x.md "t")
[ref]: ../../internal/x.md
<a href="../../internal/x.md#a">x</a>
[broken](../../internal/gone.md)
See `docs/superpowers/specs/y.md`. Specs live in `docs/superpowers/`.
`docs/internal` and `docs/superpowers` are history.
EOF
printf 'loose brief\n' > docs/superpowers/brief.md
printf '[plan](../superpowers/plans/p.md) and `../superpowers/specs/y.md`\n' > docs/internal/in.md
printf 'Plans sit in superpowers/plans/p.md under docs.\n' > README.md
printf '// see docs/superpowers/specs/y.md\nconst glob = "docs/superpowers/**";\n' > src/app.ts
printf 'keeps .superpowers/brainstorm/ alone\n' > notes.md
cat > docs/superpowers/plans/pinned.md <<'EOF'
Target: docs/superpowers/specs/y.md at `a0fa4b6`
Read docs/superpowers/specs/y.md at HEAD 27b254ac.
Also docs/superpowers/specs/y.md (main, 4365ac34) and `git diff bd7525d d3ffc29 -- docs/superpowers/plans/`.
Unpinned: docs/superpowers/specs/y.md.
EOF
printf 'whole: docs/superpowers/specs/y.md\n' > docs/superpowers/plans/whole.md
printf 'snapshot docs/superpowers/specs/y.md id 0123456789abcdef\n' > tests/snap.txt
ln -s docs/superpowers/specs/y.md link.md
mkdir notes && printf 'target\n' > notes/target.md && ln -s target.md notes/alias.md
printf '[a](alias.md)\n' > notes/index.md
printf '[l](../link.md)\n' > notes/dangling.md
printf 'docs/superpowers/specs/y.md\n' > .claude/worktrees/w/skip.md
git add -A && git commit -q -m fixture
base=$(git rev-parse HEAD)
printf 'repo\tpath\treason\nfixture\tdocs/superpowers/plans/whole.md\trecord\nfixture\ttests/snap.txt\tfollow: a snapshot\nfixture\tdocs/superpowers/plans/pinned.md\tpin: documents only\nother\tsrc/app.ts\tnot this repo\n' > "$tmp/excluded.tsv"
T() { "$tool" --excluded "$tmp/excluded.tsv" "$@"; }

out=$(T --dry-run "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "dry run exits 0" || bad "dry run exits 0 (rc=$rc)"
[[ -e docs/superpowers/specs/y.md ]] && git diff --quiet && ok "dry run changes nothing" || bad "dry run changes nothing"
grep -q '^hand src/app.ts:2:' <<<"$out" && ok "a glob in code is a hand line" || bad "a glob in code is a hand line: $out"
grep -q ', 3 pinned lines$' <<<"$out" && ok "the dry run counts each pinned line" || bad "the dry run counts each pinned line: $(tail -1 <<<"$out")"

out=$(T --check "$r"); [[ $? -eq 1 ]] && ok "--check exits 1 before the move" || bad "--check exits 1 before the move"

printf 'dirt\n' >> notes.md
T "$r" >/dev/null 2>&1; [[ $? -ne 0 && -e docs/superpowers ]] && ok "apply refuses a dirty tree" || bad "apply refuses a dirty tree"
git checkout -q notes.md

T "$r" >/dev/null || bad "apply exits 0"
[[ ! -e docs/superpowers ]] && ok "the old folder is gone" || bad "the old folder is gone"
for f in docs/specs/y.md docs/plans/p.md docs/brief.md docs/plans/pinned.md docs/plans/whole.md; do
  [[ -e $f ]] && ok "moved: $f" || bad "moved: $f"
done
has "the rename commit holds the files unchanged" docs/plans/p.md '[out](../../internal/x.md)'
git commit -q -m renames
[[ -z $(git diff --name-only --diff-filter=AMD -M100% HEAD~1 HEAD) ]] && ok "the rename commit is pure renames" || bad "the rename commit is pure renames"
T --finish "$r" || bad "--finish exits 0"

has "an upward link loses one ../" docs/plans/p.md '[out](../internal/x.md)'
has "a sibling link keeps its anchor" docs/plans/p.md '[sibling](../specs/y.md#top)'
has "a titled link is relocated" docs/plans/p.md '[titled](../internal/x.md "t")'
has "a reference definition is relocated" docs/plans/p.md '[ref]: ../internal/x.md'
has "an href keeps its anchor" docs/plans/p.md 'href="../internal/x.md#a"'
has "a broken link is left as written" docs/plans/p.md '[broken](../../internal/gone.md)'
has "the prefix becomes docs/" docs/plans/p.md 'See `docs/specs/y.md`. Specs live in `docs/`.'
has "the bare folder in prose becomes its folder list" docs/plans/p.md '`docs/internal` and `docs/{plans,specs}` are history.'
has "a link into the old folder drops the segment" docs/internal/in.md '[plan](../plans/p.md)'
has "a relative path token is relocated" docs/internal/in.md '`../specs/y.md`'
has "a docs-relative mention drops the segment" README.md 'Plans sit in plans/p.md under docs.'
has "a code citation is rewritten" src/app.ts '// see docs/specs/y.md'
has "a code glob is left for a hand edit" src/app.ts '"docs/superpowers/**"'
has "a dot folder is left alone" notes.md '.superpowers/brainstorm/'
has "a short pin keeps its line" docs/plans/pinned.md 'Target: docs/superpowers/specs/y.md at'
has "a pin after HEAD keeps its line" docs/plans/pinned.md 'docs/superpowers/specs/y.md at HEAD 27b254ac'
has "a parenthesized pin and a replayable diff keep their line" docs/plans/pinned.md 'git diff bd7525d d3ffc29 -- docs/superpowers/plans/'
has "an unpinned line in a pinned file is rewritten" docs/plans/pinned.md 'Unpinned: docs/specs/y.md.'
has "a whole-file record keeps its content and still moves" docs/plans/whole.md 'whole: docs/superpowers/specs/y.md'
has "a follow row rewrites a line whose hex is not a commit" tests/snap.txt 'snapshot docs/specs/y.md id 0123456789abcdef'
[[ $(readlink link.md) == docs/superpowers/specs/y.md ]] && ok "a symlink is never rewritten" || bad "a symlink is never rewritten"
has "a worktree file is skipped" .claude/worktrees/w/skip.md 'docs/superpowers/specs/y.md'

out=$(T --check "$r"); rc=$?
[[ $rc -eq 1 && $out == "src/app.ts" ]] && ok "--check names only the unexcluded file" || bad "--check names only the unexcluded file (rc=$rc: $out)"
sed -i 's|docs/superpowers/\*\*|docs/{plans,specs}/**|' src/app.ts
out=$(T --check "$r"); rc=$?
[[ $rc -eq 0 && -z $out ]] && ok "--check exits 0 once only records and pins remain" || bad "--check exits 0 once only records and pins remain (rc=$rc: $out)"
out=$(T --links "$base" "$r"); rc=$?
[[ $rc -eq 1 && $out == "broken notes/dangling.md:1: link.md" ]] && ok "--links names only a link to a symlink the move left dangling" || bad "--links names only a link to a symlink the move left dangling (rc=$rc: $out)"

git add -A && git commit -q -m rewrite
T "$r" >/dev/null && git diff --quiet && ok "a second apply changes nothing" || bad "a second apply changes nothing"

sed -i 's|\[out\](../internal/x.md)|[out](../../internal/x.md)|' docs/plans/p.md
out=$(T --links "$base" "$r"); rc=$?
[[ $rc -eq 1 && $out == $'broken docs/plans/p.md:1: internal/x.md\nbroken notes/dangling.md:1: link.md' ]] && ok "--links names a link the move broke" || bad "--links names a link the move broke (rc=$rc: $out)"
git checkout -q docs/plans/p.md
printf 'stray docs/superpowers/specs/y.md\n' >> docs/plans/pinned.md
out=$(T --check "$r"); rc=$?
[[ $rc -eq 1 && $out == "docs/plans/pinned.md" ]] && ok "--check names an unpinned old path in a pinned file" || bad "--check names an unpinned old path in a pinned file (rc=$rc: $out)"
git checkout -q docs/plans/pinned.md
mkdir -p docs/superpowers/specs && printf 'back\n' > docs/superpowers/specs/z.md && git add -A
out=$(T --check "$r")
grep -q '^docs/superpowers exists$' <<<"$out" && ok "--check names a recreated folder" || bad "--check names a recreated folder"
git reset -q --hard

c="$tmp/collide"
git init -q -b main "$c"
git -C "$c" remote add origin https://github.com/glw907/fixture.git
mkdir -p "$c/docs/superpowers/plans" "$c/docs/plans"
printf 'a\n' > "$c/docs/superpowers/plans/a.md"; printf 'b\n' > "$c/docs/plans/b.md"
git -C "$c" add -A && git -C "$c" commit -q -m c
T "$c" >/dev/null 2>&1; rc=$?
[[ $rc -eq 2 && -e $c/docs/superpowers/plans/a.md ]] && ok "a collision refuses before any move" || bad "a collision refuses before any move (rc=$rc)"

exit $fail
