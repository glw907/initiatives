# Shared fixture builder for the refs tests; sourced, never run on its own.
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tool="$here/../../refs"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
expect() { # description exit-status
  if [[ $2 -eq 0 ]]; then ok "$1"; else bad "$1"; fi
}

encode() { printf '%s' "$1" | sed 's#[/.]#-#g'; }

gitrepo() { # dir: init and commit everything under it
  git -C "$1" init -q 2>/dev/null
  git -C "$1" add -f -A && git -C "$1" commit -q -m seed
}

# build_fixture: a root $T with scope, map, a gh stub, and two repos that carry the same
# relative docs path. With the argument "noleg" the read-row repo is left absent.
build_fixture() {
  T=$(mktemp -d)
  P="$T/Projects"
  export HOME="$T/home" PROJECTS_ROOT="$P"
  mkdir -p "$HOME" "$P"
  printf 'repo\trole\tpath\ninitiatives\tedit\t~/Projects/initiatives\nrepo-a\tedit\t~/Projects/repo-a\nrepo-b\tedit\t~/Projects/repo-b\nrepo-leg\tread\t~/Projects/repo-leg\nrepo-gone\tretire\t~/Projects/repo-gone\n' > "$T/scope.tsv"
  {
    printf 'source_repo\told_path\tnew_repo\tnew_path\tinitiative\tstate\tpin\n'
    printf 'repo-a\tdocs/superpowers/plans/old-x.md\tinitiatives\twidget/plans/old-x.md\twidget\tmoved\tdeadbeef\n'
    printf 'repo-a\tcode/\trepo-b\tlib/\t\tmoved\tdeadbeef\n'
    printf 'repo-a\tdocs/superpowers/plans/kept.md\trepo-a\tdocs/superpowers/plans/kept.md\t\tstays\tdeadbeef\n'
  } > "$T/map.tsv"
  # gh stub: succeeds only for repo-relative content paths listed in $T/gh-ok.
  cat > "$T/gh" <<'GH'
#!/usr/bin/env bash
url="$2"; url="${url%%\?*}"; url="${url#repos/glw907/}"
grep -qxF "$url" "$(dirname "$0")/gh-ok"
GH
  chmod +x "$T/gh"
  printf 'repo-b/contents/lib/real.txt\n' > "$T/gh-ok"
  export REFS_GH="$T/gh"

  local old='docs/superpowers/plans/old-x.md'
  mkdir -p "$P/initiatives" "$P/repo-a/docs/superpowers/plans" "$P/repo-a/code" "$P/repo-b/docs/superpowers/plans"
  echo '# initiatives' > "$P/initiatives/README.md"
  echo x > "$P/repo-a/$old"
  echo x > "$P/repo-a/code/real.txt"
  echo y > "$P/repo-b/$old"
  # The ghost path is assembled so this file never carries a literal planted reference.
  printf 'moved plan: %s\ncode: code/real.txt\nnever existed: code/missing.txt\nghost: %s/ghost/specs/none.md\n' "$old" initiatives > "$P/repo-a/notes.md"
  printf 'own plan: %s\n' "$old" > "$P/repo-b/notes.md"
  printf 'old hist ref: ~/Projects/repo-gone/z.md\n' > "$P/repo-a/docs/superpowers/plans/hist.md"
  printf 'live ref: ~/Projects/repo-gone/y.md\n' > "$P/repo-a/live.md"
  mkdir -p "$P/repo-a/.claude/worktrees/w" "$P/repo-a/_salvage" "$P/repo-a/tests/fixtures/ci-green"
  local f
  for f in .claude/worktrees/w/n.md package-lock.json _salvage/n.md tests/fixtures/ci-green/pr-107-files.txt; do
    printf 'excluded: %s\n' "$old" > "$P/repo-a/$f"
  done
  [[ ${1:-} == noleg ]] || { mkdir -p "$P/repo-leg"; echo x > "$P/repo-leg/f"; }
  local r
  for r in initiatives repo-a repo-b repo-leg; do [[ -d $P/$r ]] && gitrepo "$P/$r"; done
  MEM="$HOME/.claude/projects/$(encode "$P/repo-a")/memory"
  mkdir -p "$MEM"
  printf 'remember %s\n' "$old" > "$MEM/m.md"
  printf 'remember %s\n' "$old" > "$MEM/m.md.tmp"
  RARGS=(--scope "$T/scope.tsv" --map "$T/map.tsv" --host h1 --state-dir "$T/state")
}
