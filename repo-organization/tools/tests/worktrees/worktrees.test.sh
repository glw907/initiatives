#!/usr/bin/env bash
# Tests for the worktrees tool: the six removable rules, the read-row and thinkpad cases, and the scope harness.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tool="$here/../../worktrees"
harness="$here/../scope-harness"
fail=0
tmp=$(mktemp -d)
sleeper=""
trap '[[ -n $sleeper ]] && kill "$sleeper" 2>/dev/null; rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid
export WORKTREES_GH=false

ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
expect() { # description actual wanted
  if [[ $2 == "$3" ]]; then ok "$1"; else bad "$1 (got '$2', wanted '$3')"; fi
}

root="$tmp/Projects"
mkdir -p "$root"
printf 'repo\trole\tpath\nalpha\tedit\t~/Projects/alpha\nbeta\tread\t~/Projects/beta\n' > "$tmp/scope.tsv"

mkrepo() { # dir: two commits on main, with a branch point c1
  git init -q -b main "$1"
  printf '*.log\n' > "$1/.gitignore"
  git -C "$1" add .gitignore && git -C "$1" commit -q -m c1
  git -C "$1" branch old
  printf 'x\n' > "$1/f" && git -C "$1" add f && git -C "$1" commit -q -m c2
}
mkrepo "$root/alpha"
mkrepo "$root/beta"
age() { touch -d '2 days ago' "$1"; }
mkwt() { git -C "$root/alpha" worktree add -q -b "$1" "$root/alpha/wt/$1" old; }

for n in good locked dirty ign proc fresh; do mkwt $n; done
git -C "$root/alpha" worktree add -q -b equal "$root/alpha/wt/equal" main
git -C "$root/beta" worktree add -q -b gone "$root/beta/wt/gone" old
printf 'u\n' > "$root/alpha/wt/dirty/u.txt"; age "$root/alpha/wt/dirty/u.txt"
printf 'l\n' > "$root/alpha/wt/ign/x.log"; age "$root/alpha/wt/ign/x.log"
git -C "$root/alpha" worktree lock "$root/alpha/wt/locked"
bash -c 'sleep 30; : "$0"' "$root/alpha/wt/proc" &
sleeper=$!
for n in good locked dirty ign proc equal; do age "$root/alpha/wt/$n"; done
age "$root/beta/wt/gone"

run() { PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope.tsv" --origin main --no-fetch "$@"; }
out=$(run --out "$tmp/out.tsv"); rc=$?
expect "tool exits 0" "$rc" 0
col() { awk -F'\t' -v p="/wt/$1\$" '$3 ~ p {print $17}' <<< "$out"; }
expect "first line names the tool sha" "$(head -1 <<< "$out" | cut -d' ' -f1)" worktrees
expect "--out writes the same table" "$(cat "$tmp/out.tsv")" "$out"
expect "merged, clean, unlocked, idle, old edit worktree is removable" "$(col good)" removable
expect "a branch equal to its base is not removable" "$(col equal)" "not removable"
expect "a locked worktree is not removable" "$(col locked)" "not removable"
expect "a dirty worktree is not removable" "$(col dirty)" "not removable"
expect "an ignored file alone makes it not removable" "$(col ign)" "not removable"
expect "a process holding the path makes it not removable" "$(col proc)" "not removable"
expect "a fresh worktree is not removable" "$(col fresh)" "not removable"
expect "a read-row worktree is left for the cutover" "$(col gone)" "left for the cutover"
expect "the six rule values are printed" "$(awk -F'\t' '$3 ~ /wt\/good$/ {print $11,$12,$13,$14,$15,$16}' <<< "$out")" "yes yes yes yes yes yes"
expect "the equal branch shows merged no" "$(awk -F'\t' '$3 ~ /wt\/equal$/ {print $5}' <<< "$out")" no

rm -rf "$root/beta"
PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope.tsv" --no-fetch > "$tmp/o1" 2> "$tmp/e1"; rc=$?
if [[ $rc -ne 0 ]] && grep -q beta "$tmp/e1"; then ok "a missing read row exits nonzero naming it"; else bad "missing read row (rc $rc)"; fi
th=$(PROJECTS_ROOT="$root" HOME="$tmp" "$tool" --scope "$tmp/scope.tsv" --no-fetch --host thinkpad-x1); rc=$?
expect "thinkpad: a missing read row exits 0" "$rc" 0
expect "thinkpad: the missing read row reads absent" "$(awk -F'\t' '$1=="beta" {print $17}' <<< "$th")" absent

hook=$(mktemp)
cat > "$hook" <<'EOF'
#!/usr/bin/env bash
export GIT_AUTHOR_NAME=h GIT_AUTHOR_EMAIL=h@example.invalid GIT_COMMITTER_NAME=h GIT_COMMITTER_EMAIL=h@example.invalid
git -C "$1/Projects/initiatives" worktree add -q -b "$SCOPE_CANARY_IN" "$1/Projects/initiatives/.claude/worktrees/$SCOPE_CANARY_IN"
EOF
chmod +x "$hook"
SCOPE_FIXTURE_HOOK="$hook" "$harness" "$tool" --no-fetch || fail=1
rm -f "$hook"

exit $fail
