#!/usr/bin/env bash
# Tests for e2e-check: a passing and a planted-violation fixture per check, the empty-list failures, --only, and the scope harness.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tool="$here/../../e2e-check"
harness="$here/../scope-harness"
fail=0
T=$(mktemp -d)
bgpids=()
cleanup() {
  for p in "${bgpids[@]}"; do kill "$p" 2>/dev/null; done
  [[ -f $T/aq/listener.pid ]] && kill "$(cat "$T/aq/listener.pid")" 2>/dev/null
  rm -rf "$T"
}
trap cleanup EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
passes() { # description: the last run exited 0
  if [[ $rc -eq 0 ]]; then ok "$1"; else bad "$1 (rc $rc: $out)"; fi
}
fails() { # description [text]: the last run exited 1 and its output holds text
  if [[ $rc -eq 1 && $out == *"${2:-FAIL}"* ]]; then ok "$1"; else bad "$1 (rc $rc: $out)"; fi
}

# Machine fixture: HOME, PROJECTS_ROOT, scope, records, manifest, and the stubs.
export HOME="$T/home" PROJECTS_ROOT="$T/home/Projects" E2E_HOME="$T/home"
P=$PROJECTS_ROOT
roadmap=(907-life aksailingclub-org cairn-pub cairn-themes dubplate ecxc-ski phonebook poplar workstation xcathletes-org)
mkdir -p "$P"
{
  printf 'repo\trole\tpath\ninitiatives\tedit\t~/Projects/initiatives\ndrafter\tedit\t~/Projects/drafter\n'
  for r in "${roadmap[@]}"; do
    if [[ $r == workstation ]]; then printf 'workstation\tedit\t~/.dotfiles\n'; else printf '%s\tedit\t~/Projects/%s\n' "$r" "$r"; fi
  done
  printf 'kit\tretire\t~/Projects/kit\npings\tretire\t~/Projects/pings\n'
} > "$T/scope.tsv"
mkgit() { mkdir -p "$1" && printf 'x\n' > "$1/f" && git -C "$1" init -q -b main && git -C "$1" add f && git -C "$1" commit -q -m seed; }
mkgit "$P/initiatives"; mkgit "$P/drafter"; mkgit "$HOME/.dotfiles"
for r in "${roadmap[@]}"; do [[ $r == workstation ]] || mkgit "$P/$r"; done
mkdir -p "$HOME/.claude/workflows" "$HOME/.local/bin"
printf 'js\n' > "$P/drafter/chain.js"; printf 'sh\n' > "$P/drafter/outline"
ln -s "$P/drafter/chain.js" "$HOME/.claude/workflows/docs-page-chain.js"
ln -s "$P/drafter/outline" "$HOME/.local/bin/cairn-docs-outline"

mkdir -p "$T/records/drafter" "$T/records/workstation-secrets" "$T/records/repo-organization" "$T/records/old"
printf 'id: drafter\nstatus: active\nrepos: [drafter, workstation]\n' > "$T/records/drafter/initiative.yaml"
printf 'id: workstation-secrets\nstatus: proposed\nrepos: [workstation]\n' > "$T/records/workstation-secrets/initiative.yaml"
printf 'id: repo-organization\nstatus: active\nrepos: [initiatives, workstation, drafter]\n' > "$T/records/repo-organization/initiative.yaml"
printf 'id: old\nstatus: done\nrepos: [drafter]\n' > "$T/records/old/initiative.yaml"

manifest="$T/manifest.tsv"
{
  printf 'stage\tkind\tid\taction\texpect\n'
  printf 'cloudflare\tworker\tid-gone-1\tdelete\tsole-owner\ncloudflare\td1\tid-gone-2\tdelete\tsole-owner\n'
  printf 'repo\trepo\tkit\tdelete\tabc\nrepo\trepo\tpings\tdelete\tdef\n'
  for r in "${roadmap[@]}"; do printf 'github\tdescription\t%s\tDescription of %s\t\n' "$r" "$r"; done
} > "$manifest"

G="$T/gh"
mkdir -p "$G/desc"
printf 'initiatives\n' > "$G/repos"; : > "$G/roadmap"
for r in "${roadmap[@]}"; do echo "$r" >> "$G/repos"; printf 'Description of %s\n' "$r" > "$G/desc/$r"; done
export STUB_GH_DIR="$G" E2E_GH="$here/stub-gh.sh"

mkdir -p "$T/cf"
python3 "$here/stub-cf.py" "$T/cf" & bgpids+=($!)
for _ in $(seq 50); do [[ -s $T/cf/port ]] && break; sleep 0.1; done
export E2E_CF_API="http://127.0.0.1:$(cat "$T/cf/port")" CLOUDFLARE_API_TOKEN=stub CLOUDFLARE_ACCOUNT_ID=acct0
cf() { printf '%s' "$1" > "$T/cf/gone"; printf '%s' "${2:-200}" > "$T/cf/code"; } # gone-ids [default-status]
cf "id-gone-1,id-gone-2"

mkdir -p "$T/state" "$T/aq/items" "$P/approval-queue/tests/fixtures"
touch "$T/state/refs-baseline-hostx.tsv"
printf '# brief\n' > "$P/approval-queue/tests/fixtures/e2e-brief.md"
export E2E_REFS="$here/stub-refs.sh" E2E_APPROVAL_QUEUE="$here/stub-aq.sh" E2E_TIMEOUT=4
export STUB_AQ_STATE="$T/aq" E2E_QUEUE_STATE="$T/aq" STUB_AQ_BUILD="$P/approval-queue/approval-queue/build"
E2E_QUEUE_PORT=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1])')
export E2E_QUEUE_PORT

run() { # n [extra args]: run one check against the fixture
  local n=$1; shift
  out=$("$tool" --host hostx --only "$n" --scope "$T/scope.tsv" --state-dir "$T/state" \
    --records "$T/records" --gather "$here/stub-gather.sh" --manifest "$manifest" "$@" 2>&1); rc=$?
}

# Check 1: refs
run 1; passes "1 refs: no new broken path passes"
head -1 <<< "$out" | grep -q '^e2e-check ' && ok "first line names the tool sha" || bad "first line: $out"
STUB_REFS_OUT='retired-target\ta\tb\tc\n' run 1; passes "1 refs: retired-target alone passes"
STUB_REFS_OUT='broken\ta\tb\tc\n' STUB_REFS_RC=1 run 1; fails "1 refs: a new broken path fails"
STUB_REFS_OUT='live-tie\ta\tb\tc\n' run 1; fails "1 refs: a live-tie fails even on exit 0"
mv "$T/state/refs-baseline-hostx.tsv" "$T/state/x"; run 1; fails "1 refs: a missing baseline fails" "baseline"
mv "$T/state/x" "$T/state/refs-baseline-hostx.tsv"

# Check 2: SessionStart lines
run 2; passes "2 session: drafter, dotfiles, and worktree records match"
STUB_GATHER_DROP=repo-organization run 2; fails "2 session: a missing record fails" "lacks repo-organization"
printf 'id: drafter\nstatus: done\nrepos: [drafter]\n' > "$T/records/drafter/initiative.yaml"
rm -rf "$T/records/repo-organization"; run 2; fails "2 session: no expected record at all fails" "no active or proposed record"
printf 'id: drafter\nstatus: active\nrepos: [drafter, workstation]\n' > "$T/records/drafter/initiative.yaml"
mkdir -p "$T/records/repo-organization"
printf 'id: repo-organization\nstatus: active\nrepos: [initiatives, workstation, drafter]\n' > "$T/records/repo-organization/initiative.yaml"
[[ -z $(git -C "$P/initiatives" worktree list | sed 1d) ]] && ok "2 session: the temporary worktree is removed" || bad "worktree left behind"

# Check 3: queue
run 3; passes "3 queue: item served by the build, then withdrawn"
[[ -z $(ls "$T/aq/items") ]] && ok "3 queue: item.json is gone afterwards" || bad "3 queue: items left"
kill "$(cat "$T/aq/listener.pid")" 2>/dev/null; sleep 0.3
STUB_AQ_MODE=wrongbuild run 3; fails "3 queue: a serving process outside the build fails" "does not name"
kill "$(cat "$T/aq/listener.pid")" 2>/dev/null; sleep 0.3
STUB_AQ_MODE=noclean run 3; fails "3 queue: an item that outlives the command fails" "outlived"
kill "$(cat "$T/aq/listener.pid")" 2>/dev/null; rm -rf "$T/aq/items"/*; sleep 0.3
STUB_AQ_MODE=noitem run 3; fails "3 queue: no item fails" "no new item.json"
mkdir "$HOME/.dotfiles/approval-queue"; run 3; fails "3 queue: a leftover ~/.dotfiles/approval-queue fails" "still exists"
rmdir "$HOME/.dotfiles/approval-queue"
python3 -c 'import os,socket,time
s=socket.socket(); s.bind(("127.0.0.1", int(os.environ["E2E_QUEUE_PORT"]))); s.listen(); time.sleep(20)' & bgpids+=($!)
sleep 0.4; run 3; fails "3 queue: a process already on the port fails" "already listens"
kill "${bgpids[-1]}"

# Check 4: realpaths
run 4; passes "4 realpaths: both under drafter and dotfiles clean"
printf 'u\n' > "$HOME/.dotfiles/dirty"; run 4; fails "4 realpaths: a dirty ~/.dotfiles fails" "dirty"
rm "$HOME/.dotfiles/dirty"
rm "$HOME/.local/bin/cairn-docs-outline"; ln -s "$HOME/.dotfiles/f" "$HOME/.local/bin/cairn-docs-outline"
run 4; fails "4 realpaths: a link resolving outside drafter fails" "does not resolve under drafter"
rm "$HOME/.local/bin/cairn-docs-outline"; ln -s "$P/drafter/outline" "$HOME/.local/bin/cairn-docs-outline"

# Check 5: retirement
run 5; passes "5 retirement: ids and repos gone, no retired directory"
cf "id-gone-1"; run 5; fails "5 retirement: a still-resolving id fails" "still resolves"
cf "id-gone-1" 403; run 5; fails "5 retirement: a 403 is never gone" "HTTP 403"
cf "id-gone-1" 500; run 5; fails "5 retirement: a 5xx is never gone" "HTTP 500"
cf "id-gone-1,id-gone-2"
CLOUDFLARE_API_TOKEN= run 5; fails "5 retirement: no token fails" "no API token"
echo kit >> "$G/repos"; run 5; fails "5 retirement: a deleted repo that resolves fails" "kit is not reported gone"
sed -i '/^kit$/d' "$G/repos"
mkdir "$P/pings"; run 5; fails "5 retirement: a retired directory fails" "retired directory pings"
rmdir "$P/pings"
mv "$G/repos" "$G/repos.x"; printf 'x\n' > "$G/repos"; run 5; fails "5 retirement: a failed same-run positive is inconclusive" "inconclusive"
mv "$G/repos.x" "$G/repos"
{ cat "$manifest"; printf 'cloudflare\tdns\tzone1/rec-gone\tdelete\tsole-owner\ncloudflare\taccess-app\tapp-gone\tdelete\tsole-owner\ncloudflare\troute\tpings.example\tdelete\tsole-owner\n'; } > "$T/m4"
cf "id-gone-1,id-gone-2,rec-gone,app-gone"
manifest="$T/m4" run 5; passes "5 retirement: dns, access-app, and route rows resolve as gone"
cf "id-gone-1,id-gone-2,app-gone"; manifest="$T/m4" run 5; fails "5 retirement: a dns record that still resolves fails" "still resolves"
cf "id-gone-1,id-gone-2,rec-gone,app-gone"; echo "pings.example" > "$T/cf/domains"
manifest="$T/m4" run 5; fails "5 retirement: a route still in the domain list fails" "route pings.example still resolves"
: > "$T/cf/domains"; manifest="$T/m4" run 5; passes "5 retirement: a route absent from a non-empty list is gone"
rm -f "$T/cf/domains"; cf "id-gone-1,id-gone-2"
grep -v '^cloudflare' "$manifest" > "$T/m1"; manifest="$T/m1" run 5; fails "5 retirement: no cloudflare rows fails" "no cloudflare rows"
grep -v '^repo' "$manifest" > "$T/m2"; manifest="$T/m2" run 5; fails "5 retirement: no deleted repos fails" "no deleted-repo rows"

# Check 6: ROADMAP and descriptions
run 6; passes "6 roadmap: no ROADMAP and matching descriptions"
echo poplar > "$G/roadmap"; run 6; fails "6 roadmap: a ROADMAP.md on origin/main fails" "poplar: ROADMAP.md on origin/main"
: > "$G/roadmap"
printf 'r\n' > "$P/poplar/ROADMAP.md"; run 6; fails "6 roadmap: a local ROADMAP.md fails" "poplar: local ROADMAP.md"
rm "$P/poplar/ROADMAP.md"
printf 'Changed\n' > "$G/desc/dubplate"; run 6; fails "6 roadmap: a differing description fails" "dubplate: description differs"
printf 'Description of dubplate\n' > "$G/desc/dubplate"
grep -v 'description' "$manifest" > "$T/m3"; manifest="$T/m3" run 6; fails "6 roadmap: no description rows fails" "no description rows"
E2E_ROADMAP_REPOS="poplar,dubplate" run 6; fails "6 roadmap: a list that is not ten fails" "not 10"
E2E_ROADMAP_REPOS="" run 6; fails "6 roadmap: an empty list fails" "not 10"

# --only and the full run
out=$("$tool" --host hostx --only 4 --scope "$T/scope.tsv" 2>&1); rc=$?
[[ $(grep -c -E '^(ok  |FAIL) [0-9]' <<< "$out") -eq 1 ]] && ok "--only runs one check" || bad "--only: $out"
out=$("$tool" --host hostx --only 7 2>&1); rc=$?
[[ $rc -ne 0 ]] && ok "--only rejects an unknown check" || bad "--only 7 accepted"
kill "$(cat "$T/aq/listener.pid")" 2>/dev/null; sleep 0.3
export STUB_REFS_OUT='broken\ta\tb\tc\n' STUB_REFS_RC=1
out=$("$tool" --host hostx --scope "$T/scope.tsv" --state-dir "$T/state" --records "$T/records" \
  --gather "$here/stub-gather.sh" --manifest "$manifest" 2>&1); rc=$?
unset STUB_REFS_OUT STUB_REFS_RC
[[ $rc -eq 1 && $(grep -c -E '^(ok  |FAIL) [0-9]' <<< "$out") -eq 6 ]] && ok "a full run prints six lines and exits 1 when one fails" || bad "full run: rc $rc: $out"
manifest="$T/manifest.tsv"
kill "$(cat "$T/aq/listener.pid")" 2>/dev/null; sleep 0.3
out=$("$tool" --host hostx --scope "$T/scope.tsv" --state-dir "$T/state" --records "$T/records" \
  --gather "$here/stub-gather.sh" --manifest "$manifest" 2>&1); rc=$?
passes "a full run over a good fixture exits 0"

# The scope harness over check 4: the hook links the drafter files under names carrying the canary.
hook=$(mktemp)
cat > "$hook" <<'EOF'
#!/usr/bin/env bash
mkdir -p "$1/.claude/workflows" "$1/.local/bin"
printf 'js\n' > "$1/Projects/drafter/$SCOPE_CANARY_IN.js"
ln -s "$1/Projects/drafter/$SCOPE_CANARY_IN.js" "$1/.claude/workflows/docs-page-chain.js"
ln -s "$1/Projects/drafter/$SCOPE_CANARY_IN.js" "$1/.local/bin/cairn-docs-outline"
git -C "$1/Projects/drafter" add -A
git -C "$1/Projects/drafter" -c user.name=h -c user.email=h@example.invalid commit -q -m link
EOF
chmod +x "$hook"
unset E2E_HOME PROJECTS_ROOT
SCOPE_FIXTURE_HOOK="$hook" "$harness" "$tool" --host hostx --only 4 || fail=1
rm -f "$hook"
exit $fail
