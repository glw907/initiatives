#!/usr/bin/env bash
# Tests for inventory against a known-ties fixture. Stubs only: a local Cloudflare API server
# (INVENTORY_CF_API) and a gh stub (INVENTORY_GH); nothing touches the live account.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../../inventory"
harness="$here/../scope-harness"
fail=0
tmp=$(mktemp -d)
srv_pid=""
trap '[[ -n $srv_pid ]] && kill "$srv_pid" 2>/dev/null; rm -rf "$tmp"' EXIT
ok()  { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
expect() { # label haystack needle
  if grep -qF -- "$3" <<< "$2"; then ok "$1"; else bad "$1: missing '$3'"; fi
}
refute() { # label haystack needle
  if grep -qF -- "$3" <<< "$2"; then bad "$1: found '$3'"; else ok "$1"; fi
}

fx="$tmp/fx"
mkdir -p "$fx/Projects"
bash "$here/build-fixture.sh" "$fx" || { echo "FAIL fixture build"; exit 1; }
bearer=stub-fixture

start_api() { # fixture.json -> sets INVENTORY_CF_API
  [[ -n $srv_pid ]] && kill "$srv_pid" 2>/dev/null
  rm -f "$tmp/port"
  python3 "$here/stub-api.py" "$1" "$tmp/port" "$bearer" &
  srv_pid=$!
  for _ in $(seq 50); do [[ -s $tmp/port ]] && break; sleep 0.1; done
  export INVENTORY_CF_API="http://127.0.0.1:$(cat "$tmp/port")"
}
variant() { # name python-expression-on-d -> writes $tmp/<name>.json
  python3 "$here/gen-api.py" > "$tmp/base.json"
  python3 - "$tmp/base.json" "$tmp/$1.json" "$2" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
exec(sys.argv[3])
json.dump(d, open(sys.argv[2], "w"))
EOF
}

cat > "$tmp/gh.json" <<'EOF'
{
  "repo view glw907/pings --json isFork,parent,defaultBranchRef": {"isFork": false, "parent": null, "defaultBranchRef": {"name": "main"}},
  "pr list -R glw907/pings --state open --json number,title": [{"number": 1, "title": "open pr"}],
  "issue list -R glw907/pings --state open --json number,title": [],
  "release list -R glw907/pings --json tagName": [{"tagName": "v1"}],
  "api repos/glw907/pings/branches --paginate --jq .[].name": "main\nfeat\n",
  "api repos/glw907/pings/compare/main...feat --jq .ahead_by": "2\n",
  "repo view glw907/kit --json isFork,parent,defaultBranchRef": {"isFork": true, "parent": {"owner": {"login": "example-org"}, "name": "kit"}, "defaultBranchRef": {"name": "main"}},
  "pr list -R glw907/kit --state open --json number,title": [],
  "issue list -R glw907/kit --state open --json number,title": [],
  "release list -R glw907/kit --json tagName": [],
  "api repos/example-org/kit --jq .default_branch": "trunk\n",
  "pr list -R example-org/kit --state open --author glw907 --json number,title": [{"number": 9, "title": "carried"}],
  "api repos/glw907/kit/branches --paginate --jq .[].name": "main\nwork\n",
  "api repos/example-org/kit/compare/trunk...glw907:main --jq .ahead_by": "0\n",
  "api repos/example-org/kit/compare/trunk...glw907:work --jq .ahead_by": "3\n"
}
EOF
export INVENTORY_GH="$here/stub-gh.py" INVENTORY_GH_FIXTURE="$tmp/gh.json"
export PROJECTS_ROOT="$fx/Projects" HOME="$fx"

variant base ''
start_api "$tmp/base.json"
out=$("$tool" --out "$tmp/inv.json" --host pavilion 2>"$tmp/err"); rc=$?
[[ $rc -eq 0 ]] && ok "full run exits 0" || bad "full run exited $rc: $(cat "$tmp/err")"
[[ $(head -1 <<< "$out") =~ ^inventory\ [0-9a-f]+ ]] && ok "first line is the tool sha" || bad "first line: $(head -1 <<< "$out")"
status() { # kind id -> status of the first matching tie, from the JSON
  python3 - "$tmp/inv.json" "$1" "$2" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
for t in d["cloudflare"].values():
    for x in t["cloudflare"]:
        if x["kind"] == sys.argv[2] and x["id"] == sys.argv[3]:
            print(x["status"]); raise SystemExit
print("none")
EOF
}
kv() { printf '%032x' "$1"; }
chk() { # label kind id want
  got=$(status "$2" "$3"); [[ $got == "$4" ]] && ok "$1: $4" || bad "$1: got '$got', want '$4'"
}

# known ties
chk "pings Worker" worker pings sole-owner
chk "pings KV" kv "$(kv 1)" sole-owner
chk "pings cron" cron "pings:*/5 * * * *" sole-owner
chk "pings custom domain" route pings.example.invalid sole-owner
chk "pings email rule" email-routing er1 sole-owner
expect "PINGS_ADMIN_TOKEN tie reported" "$out" "secret PINGS_ADMIN_TOKEN"
refute "unrelated secret not reported" "$out" "OTHER_NAME"
chk "asc-handbook" worker asc-handbook "shared-with aksailingclub-legacy"
chk "asc-uptime (--name on a continued line)" worker asc-uptime "shared-with aksailingclub-legacy"
chk "asc-event-images" r2 asc-event-images "shared-with aksailingclub-legacy"
chk "bound only by a target (D1)" d1 00000000-0000-0000-0000-00000000d001 sole-owner
chk "bound only by a target (KV)" kv "$(kv 3)" sole-owner
chk "KV only under [env.staging] of the target" kv "$(kv 2)" sole-owner
# outside binder
chk "outside Worker binds the id" kv "$(kv 4)" shared-out-of-scope
refute "outside Worker name stays out of stdout" "$out" zz-outside-w
refute "outside Worker name stays out of JSON" "$(cat "$tmp/inv.json")" zz-outside-w
refute "account id stays out of output" "$out$(cat "$tmp/inv.json")" acct-fixture

# Review Focus 4: one fixture per hiding place
chk "id only under a surviving [env.<name>]" kv "$(kv 11)" "shared-with ecxc-ski"
chk "id only in a surviving wrangler.jsonc" kv "$(kv 12)" "shared-with 907-life"
chk "Worker only in a surviving deploy --name" worker scratch-w3 "shared-with aksailingclub-org"
chk "target-only host" route scratch.example.invalid sole-owner
chk "DNS record on a target-only host" dns dns-scratch sole-owner
chk "host covered by a surviving wildcard (route)" route app.wild.example.invalid "shared-with 907-life"
chk "host covered by a surviving wildcard (DNS)" dns dns-wild "shared-with 907-life"
chk "Access app on target hosts only" access-app app-sole sole-owner
chk "Access app listing a surviving hostname" access-app app-mixed "shared-with 907-life"

# local leg
loc() { python3 - "$tmp/inv.json" "$1" "$2" <<'EOF'
import json, sys
t = json.load(open(sys.argv[1]))["local"][sys.argv[2]]
v = t
for k in sys.argv[3].split("."):
    v = v[k] if isinstance(v, dict) else v[int(k)]
print(json.dumps(v) if not isinstance(v, str) else v)
EOF
}
[[ $(loc kit kind) == git ]] && ok "kit is git" || bad "kit kind"
[[ $(loc kit unpushed_branches.0) == feature-x || $(loc kit unpushed_branches) == *feature-x* ]] && ok "git target lists its unpushed branch" || bad "unpushed: $(loc kit unpushed_branches)"
[[ $(loc kit stashes) == *s1* ]] && ok "git target lists its stash" || bad "stashes"
[[ $(loc kit uncommitted) -ge 1 ]] && ok "git target counts uncommitted files" || bad "uncommitted"
[[ $(loc kit expect.head) == "$(git -C "$fx/Projects/kit" rev-parse HEAD)" ]] && ok "git expect carries HEAD" || bad "expect head"
[[ $(loc jrnl-md kind) == orphaned-worktree ]] && ok "orphaned worktree kind" || bad "jrnl-md kind"
[[ $(loc cairn-scratch-b kind) == plain-dir ]] && ok "plain dir kind" || bad "plain kind"
[[ $(loc cairn-scratch-b recoverable) == false ]] && ok "plain dir marked unrecoverable" || bad "recoverable"
[[ $(loc cairn-scratch-b expect.file_count) == 2 ]] && ok "plain dir expect file count" || bad "file_count"
[[ $(loc cairn-scratch-b expect.newest_mtime) == "$(date -d '2026-01-02 03:04:05 UTC' +%s)" ]] && ok "plain dir expect newest mtime" || bad "newest_mtime"
expect "plain dir lists files with mtimes" "$out" "sub/b.txt"
expect "reference from another repo" "$out" "dubplate:docs/notes.md:1"
expect "Brewfile manifest line" "$out" 'manifest workstation:bluefin/Brewfile:1  tap "glw907/kit"'

# GitHub leg
[[ $(python3 -c "import json;print(len(json.load(open('$tmp/inv.json'))['github']['pings']['open_prs']))") == 1 ]] && ok "GitHub open PRs" || bad "github prs"
expect "unpushed GitHub branch listed" "$(cat "$tmp/inv.json")" '"branch": "feat"'
gk=$(python3 -c "import json;t=json.load(open('$tmp/inv.json'))['github']['kit'];print(len(t['parent_open_prs']), [b['branch'] for b in t['branches_not_in_upstream']])")
[[ $gk == "1 ['work']" ]] && ok "fork lists parent PRs and branches ahead of its parent" || bad "fork: $gk"
expect "repo with no GitHub remote" "$out" "github  healthy-diet  no-github-repo"

# failures exit nonzero
variant empty "d['/accounts/acct-fixture/workers/scripts']['body'] = []"
start_api "$tmp/empty.json"
"$tool" --network >/dev/null 2>"$tmp/err"; rc=$?
[[ $rc -ne 0 ]] && grep -q pings "$tmp/err" && ok "empty Worker list exits nonzero" || bad "empty list rc=$rc"
variant nopings "d['/accounts/acct-fixture/workers/scripts']['body'] = [{'id': 'scratch-a'}]"
start_api "$tmp/nopings.json"
"$tool" --network >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] && ok "Worker list lacking pings exits nonzero" || bad "no pings rc=$rc"
variant e500 "d['/accounts/acct-fixture/d1/database'] = {'status': 500, 'body': None}"
start_api "$tmp/e500.json"
"$tool" --network >/dev/null 2>"$tmp/err"; rc=$?
[[ $rc -ne 0 ]] && ok "API 500 exits nonzero" || bad "500 rc=$rc"
refute "error text carries no account id" "$(cat "$tmp/err")" acct-fixture
variant e403 "d['/zones'] = {'status': 403, 'body': None}"
start_api "$tmp/e403.json"
"$tool" --network >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] && ok "API 403 exits nonzero" || bad "403 rc=$rc"
variant bad "d['/zones'] = {'raw': 'not json'}"
start_api "$tmp/bad.json"
"$tool" --network >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] && ok "malformed JSON exits nonzero" || bad "malformed rc=$rc"
start_api "$tmp/base.json"
cp "$fx/.local/secrets" "$tmp/secrets.keep"
printf 'export CLOUDFLARE_API_%s=%s\nexport CLOUDFLARE_ACCOUNT_ID=acct-fixture\n' TOKEN wrong > "$fx/.local/secrets"
"$tool" --network >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] && ok "401 exits nonzero" || bad "401 rc=$rc"
cp "$tmp/secrets.keep" "$fx/.local/secrets"
INVENTORY_GH=/nonexistent/gh "$tool" --network >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 ]] && ok "unusable gh exits nonzero" || bad "gh rc=$rc"

# scope rows
mv "$fx/Projects/drafter" "$tmp/drafter.away"
msg=$("$tool" --local 2>&1 >/dev/null); rc=$?
[[ $rc -ne 0 ]] && grep -q "drafter (edit)" <<< "$msg" && ok "missing edit row exits nonzero naming it" || bad "edit row rc=$rc msg=$msg"
mv "$tmp/drafter.away" "$fx/Projects/drafter"
mv "$fx/Projects/aksailingclub-legacy" "$tmp/legacy.away"
msg=$("$tool" --local 2>&1 >/dev/null); rc=$?
[[ $rc -ne 0 ]] && grep -q "aksailingclub-legacy (read)" <<< "$msg" && ok "missing read row exits nonzero off the thinkpad" || bad "read row rc=$rc"
out2=$("$tool" --local --host thinkpad-x1 2>&1); rc=$?
[[ $rc -eq 0 ]] && ok "thinkpad: missing read row exits 0" || bad "thinkpad read row rc=$rc"
mv "$tmp/legacy.away" "$fx/Projects/aksailingclub-legacy"
mv "$fx/Projects/pings" "$tmp/pings.away"
out3=$("$tool" --local 2>&1); rc=$?
[[ $rc -eq 0 ]] && grep -q "local   pings  absent" <<< "$out3" && ok "missing retire path reported absent" || bad "retire absent rc=$rc"
mv "$tmp/pings.away" "$fx/Projects/pings"

# the shared scope harness over the --local leg
cat > "$tmp/run-inventory.sh" <<EOF
#!/usr/bin/env bash
exec "$tool" --local --out "\$SCOPE_OUT_DIR/inventory.json"
EOF
chmod +x "$tmp/run-inventory.sh"
SCOPE_FIXTURE_HOOK="$here/build-fixture.sh" bash "$harness" "$tmp/run-inventory.sh" || fail=1

exit $fail
