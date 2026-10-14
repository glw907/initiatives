#!/usr/bin/env bash
# Tests for thinkpad-cleanup: expect comparison, dry run versus --apply, the doc hash check, and the scope harness.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tool="$here/../../thinkpad-cleanup"
harness="$here/../scope-harness"
fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
check() { # description command...
  local d=$1; shift
  if "$@"; then ok "$d"; else bad "$d"; fi
}

git_expect() { # dir: the HEAD and branch-tip facts
  printf 'HEAD=%s %s' "$(git -C "$1" rev-parse HEAD)" \
    "$(git -C "$1" for-each-ref --format='%(refname)=%(objectname)' refs/heads | tr '\n' ' ')"
}
dir_expect() { # dir: newest mtime and file count
  printf 'mtime=%s files=%s' "$(find "$1" -type f -printf '%T@\n' | cut -d. -f1 | sort -n | tail -1)" \
    "$(find "$1" -type f | wc -l)"
}

root="$tmp/Projects"
printf 'repo\trole\tpath\nkeeper\tedit\t~/Projects/keeper\nold-same\tretire\t~/Projects/old-same\nold-extra\tretire\t~/Projects/old-extra\nold-plain\tretire\t~/Projects/old-plain\n' > "$tmp/scope.tsv"
for n in keeper old-same old-extra; do
  git init -q -b main "$root/$n"; printf 'a\n' > "$root/$n/a"
  git -C "$root/$n" add a && git -C "$root/$n" commit -q -m one
done
mkdir -p "$root/old-plain"; printf 'p\n' > "$root/old-plain/p"

{
  printf 'stage\tkind\tid\taction\texpect\n'
  printf 'R1\tlocal-dir\told-same\tremove\t%s\n' "$(git_expect "$root/old-same")"
  printf 'R1\tlocal-tar\told-extra\tremove\t%s\n' "$(git_expect "$root/old-extra")"
  printf 'R1\tlocal-dir\told-plain\tremove\t%s\n' "$(dir_expect "$root/old-plain")"
  printf 'R1\tlocal-dir\tkeeper\tremove\t%s\n' "$(git_expect "$root/keeper")"
} > "$tmp/manifest.tsv"
# One commit beyond the manifest's facts for old-extra.
printf 'b\n' > "$root/old-extra/b"; git -C "$root/old-extra" add b; git -C "$root/old-extra" commit -q -m two

run() { PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope.tsv" "$@"; }

out=$(run --manifest "$tmp/manifest.tsv"); rc=$?
check "dry run exits 0" test "$rc" -eq 0
check "output starts with the tool sha line" bash -c '[[ $(head -1 <<< "$1") =~ ^thinkpad-cleanup\ [0-9a-f]{40}$ ]]' _ "$out"
check "an identical remote-less repo is removable" grep -q $'^old-same\tno remote\tremovable' <<< "$out"
check "a repo one commit beyond expect is refused" grep -q $'^old-extra\tno remote\trefused' <<< "$out"
check "a differing tar target prints the tar instruction" grep -q 'join the thinkpad tar' <<< "$out"
check "the refused target is listed for Geoff" grep -q '^for Geoff: old-extra' <<< "$out"
check "an identical plain directory is removable" grep -q $'^old-plain\tno remote\tremovable' <<< "$out"
check "a non-retire manifest row is not covered" bash -c '! grep -q keeper <<< "$1"' _ "$out"
check "a dry run removes nothing" test -d "$root/old-same" -a -d "$root/old-plain"

run --manifest "$tmp/manifest.tsv" --apply > "$tmp/apply.out"; rc=$?
check "--apply exits 1 while a target is refused" test "$rc" -eq 1
check "--apply removes the identical repo" test ! -e "$root/old-same"
check "--apply removes the identical plain directory" test ! -e "$root/old-plain"
check "--apply leaves the refused repo" test -d "$root/old-extra"
check "--apply never touches an edit row" test -d "$root/keeper"

# A stash lives only in the checkout, so a repo holding one is never removable.
git init -q -b main "$root/old-stash"; printf 'a\n' > "$root/old-stash/a"
git -C "$root/old-stash" add a && git -C "$root/old-stash" commit -q -m one
printf 'changed\n' > "$root/old-stash/a"; git -C "$root/old-stash" stash -q
printf 'repo\trole\tpath\nold-stash\tretire\t~/Projects/old-stash\n' > "$tmp/scope3.tsv"
printf 'stage\tkind\tid\taction\texpect\nR1\tlocal-dir\told-stash\tremove\t%s\n' "$(git_expect "$root/old-stash")" > "$tmp/m3.tsv"
out=$(PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope3.tsv" --manifest "$tmp/m3.tsv" --apply)
check "a repo holding a stash is refused" grep -q $'^old-stash\tno remote\trefused\tstash present' <<< "$out"
check "a repo holding a stash survives --apply" test -d "$root/old-stash"

# The doc form: the manifest is a fenced block, and a wrong hash stops everything.
mkdir -p "$root/old-doc"; printf 'x\n' > "$root/old-doc/x"
printf 'repo\trole\tpath\nold-doc\tretire\t~/Projects/old-doc\n' > "$tmp/scope2.tsv"
{
  printf '# Dry run\n\nProse.\n\n```\nnot a manifest\n```\n\n```tsv\n'
  printf 'stage\tkind\tid\taction\texpect\nR1\tlocal-dir\told-doc\tremove\t%s\n' "$(dir_expect "$root/old-doc")"
  printf '```\n'
} > "$tmp/doc.md"
sha=$(sha256sum "$tmp/doc.md" | cut -d' ' -f1)
PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope2.tsv" --doc "$tmp/doc.md" --doc-sha256 "$(printf '0%.0s' {1..64})" --apply > "$tmp/bad.out" 2> "$tmp/bad.err"; rc=$?
check "a doc sha256 mismatch exits nonzero" test "$rc" -ne 0
check "a mismatch names the problem on stderr" grep -q 'sha256 mismatch' "$tmp/bad.err"
check "a mismatch removes nothing" test -d "$root/old-doc"
PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope2.tsv" --doc "$tmp/doc.md" --doc-sha256 "$sha" --apply > "$tmp/good.out"; rc=$?
check "a matching doc hash lets --apply run" test "$rc" -eq 0 -a ! -e "$root/old-doc"

hook=$(mktemp)
cat > "$hook" <<'EOF'
#!/usr/bin/env bash
export GIT_AUTHOR_NAME=h GIT_AUTHOR_EMAIL=h@example.invalid GIT_COMMITTER_NAME=h GIT_COMMITTER_EMAIL=h@example.invalid
printf 'stage\tkind\tid\taction\texpect\n' > "$1/manifest.tsv"
while IFS=$'\t' read -r repo role path; do
  [[ $role == retire ]] || continue
  d="${path/#\~\/Projects\//$1/Projects/}"
  git -C "$d" branch "$SCOPE_CANARY_IN"
  printf 'R1\tlocal-dir\t%s\tremove\tHEAD=%s %s\n' "$repo" "$(git -C "$d" rev-parse HEAD)" \
    "$(git -C "$d" for-each-ref --format='%(refname)=%(objectname)' refs/heads | tr '\n' ' ')" >> "$1/manifest.tsv"
done < "$SCOPE_FILE"
EOF
chmod +x "$hook"
SCOPE_FILE="$here/../../../scope.tsv" SCOPE_FIXTURE_HOOK="$hook" "$harness" bash -c '"$0" --manifest "$HOME/manifest.tsv"' "$tool" || fail=1
rm -f "$hook"

exit $fail
