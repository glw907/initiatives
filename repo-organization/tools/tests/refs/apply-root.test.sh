#!/usr/bin/env bash
# Tests for refs apply: a tracked symlink and a memory directory pointing outside --root.
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
build_fixture
trap 'rm -rf "$T"' EXIT
R="$tool"
P="$T/Projects"
tab=$'\t'
old='docs/superpowers/plans/old-x.md'

# Everything the fixture built lives under $T/root; the targets live beside it.
mkdir -p "$T/root" "$T/outside/mem"
oldenc=$(encode "$P/repo-a")
mv "$P" "$T/root/Projects"; mv "$HOME" "$T/root/home"
# The encoded memory directory name follows the checkout path, which just moved.
mv "$T/root/home/.claude/projects/$oldenc" "$T/root/home/.claude/projects/$(encode "$T/root/Projects/repo-a")"
export HOME="$T/root/home" PROJECTS_ROOT="$T/root/Projects"
P="$T/root/Projects"
printf 'outside file: %s\n' "$old" > "$T/outside/target.md"
ln -s "$T/outside/target.md" "$P/repo-a/link.md"
git -C "$P/repo-a" add link.md && git -C "$P/repo-a" commit -q -m link
# The memory directory itself becomes a symlink out of the root.
memdir="$HOME/.claude/projects/$(encode "$P/repo-a")/memory"
mv "$memdir"/m.md "$T/outside/mem/m.md"
rm -rf "$memdir"; ln -s "$T/outside/mem" "$memdir"

before=$(md5sum "$T/outside/target.md" "$T/outside/mem/m.md")
out=$("$R" apply "${RARGS[@]}" --root "$T/root" --tar-dir "$T/tars" 2>&1); rc=$?
[[ $rc -eq 0 ]]; expect "apply exits 0" $?
[[ $(md5sum "$T/outside/target.md" "$T/outside/mem/m.md") == "$before" ]]; expect "both outside targets stay byte-identical" $?
grep -q "^skip${tab}repo-a${tab}link.md${tab}" <<<"$out"; expect "the tracked symlink out of the root is in the skip list" $?
grep -q "^skip${tab}memory${tab}.*memory" <<<"$out"; expect "the memory directory symlinked out of the root is in the skip list" $?
grep -q 'initiatives/widget' "$P/repo-a/notes.md"; expect "files inside the root are still rewritten" $?
exit $fail
