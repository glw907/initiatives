#!/usr/bin/env bash
# Renames the glw907/servers repo to glw907/household-it and moves its folder.
#
# With no flag it prints each command and changes nothing. --run executes.
# --remove-scratch also removes merged worktrees that hold untracked files.
# Design: self-hosting/specs/2026-11-13-household-it-runbook-design.md
set -euo pipefail

run=0
scratch=0
for arg in "$@"; do
  case "$arg" in
    --run) run=1 ;;
    --remove-scratch) scratch=1 ;;
    *) echo "usage: $0 [--run] [--remove-scratch]" >&2; exit 2 ;;
  esac
done

old="$HOME/Projects/servers"
new="$HOME/Projects/household-it"
keep_branch="worktree-servers-review-2026-11"
records="$(cd "$(dirname "$0")/../.." && pwd)"

step() {
  printf '+ %s\n' "$*"
  if [ "$run" = 1 ]; then "$@"; fi
}

fail() { echo "stop: $*" >&2; exit 1; }

# 1. Preconditions. These only read.
[ -d "$old/.git" ] || fail "$old is not a checkout"
[ ! -e "$new" ] || fail "$new already exists"
if ! claude-worktree-busy "$old" >/dev/null 2>&1; then
  if [ "$run" = 1 ]; then fail "claude-worktree-busy reports $old as busy"; fi
  echo "note: claude-worktree-busy reports $old as busy; --run would stop here"
fi
git -C "$old" fetch --quiet
[ "$(git -C "$old" rev-parse --abbrev-ref HEAD)" = main ] || fail "main checkout is not on main"
[ "$(git -C "$old" rev-list --count HEAD..origin/main)" = 0 ] || fail "main is behind origin/main"
[ "$(git -C "$old" rev-list --count origin/main..HEAD)" = 0 ] || fail "main has unpushed commits"
[ -z "$(git -C "$old" status --porcelain --untracked-files=no)" ] || fail "main checkout has uncommitted changes"

# 2. Leftover worktrees whose work is merged into origin/main.
removed=0
kept=0
keep_path=""
while IFS=$'\t' read -r path branch; do
  [ "$path" = "$old" ] && continue
  if [ "$branch" = "$keep_branch" ]; then keep_path="$path"; continue; fi
  if ! git -C "$old" merge-base --is-ancestor "$(git -C "$path" rev-parse HEAD)" origin/main; then
    echo "keep (not merged): $path"; kept=$((kept + 1)); continue
  fi
  if [ -n "$(git -C "$path" status --porcelain --untracked-files=no)" ]; then
    echo "keep (tracked changes): $path"; kept=$((kept + 1)); continue
  fi
  if [ -n "$(git -C "$path" status --porcelain)" ]; then
    if [ "$scratch" = 0 ]; then
      echo "keep (untracked files): $path"; kept=$((kept + 1)); continue
    fi
    step git -C "$old" worktree remove --force "$path"
  else
    step git -C "$old" worktree remove "$path"
  fi
  removed=$((removed + 1))
done < <(git -C "$old" worktree list --porcelain |
  awk '/^worktree /{p=substr($0,10)} /^branch /{b=substr($0,19)} /^detached/{b=""} /^$/{print p "\t" b; b=""}')

# Merged branches. -d refuses an unmerged branch and one still checked out.
while read -r branch; do
  [ "$branch" = main ] && continue
  [ "$branch" = "$keep_branch" ] && continue
  if [ "$run" = 0 ] && [ "$scratch" = 0 ] &&
    git -C "$old" worktree list --porcelain | grep -qx "branch refs/heads/$branch" &&
    [ -n "$(git -C "$(git -C "$old" worktree list --porcelain | grep -B2 -x "branch refs/heads/$branch" | sed -n 's/^worktree //p')" status --porcelain)" ]; then
    continue
  fi
  step git -C "$old" branch -d "$branch" || echo "kept branch: $branch"
done < <(git -C "$old" branch --merged origin/main --format='%(refname:short)')
echo "worktrees: $removed to remove, $kept kept, plus the November review"

# 3. The rename.
step gh repo rename household-it --repo glw907/servers --yes
step git -C "$old" remote set-url origin https://github.com/glw907/household-it.git
step mv "$old" "$new"
step ln -s household-it "$old"
if [ -n "$keep_path" ]; then
  step git -C "$new" worktree repair "${keep_path/#$old/$new}"
else
  step git -C "$new" worktree repair
fi

# 4. Claude's memory for the repo. Session history stays under the old key.
mem_old="$HOME/.claude/projects/-var-home-glw907-Projects-servers/memory"
mem_new="$HOME/.claude/projects/-var-home-glw907-Projects-household-it"
if [ -d "$mem_old" ]; then
  step mkdir -p "$mem_new"
  step cp -r "$mem_old" "$mem_new/"
fi

# 5. The initiative records' repo lists. Only the repos: line changes.
for id in 907-rebuild credential-hygiene survey-house-style self-hosting household-phonebook; do
  step sed -i -E '/^repos:/s/\bservers\b/household-it/' "$records/$id/initiative.yaml"
done

# 6. Checks.
step gh repo view glw907/household-it --json name,isPrivate
step git ls-remote --heads https://github.com/glw907/servers.git main
step gh api repos/glw907/household-it/collaborators --jq length
step gh pr list --repo glw907/household-it --state open
step git -C "$new" worktree list
if [ "$run" = 0 ]; then echo "dry run: nothing changed"; fi
