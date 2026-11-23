# Worktrees and denials on 2026-11-22

- `dubplate`: 3 worktrees listed, 1 of them `.claude/worktrees/agent-*`. `claude-worktree-busy` exits 0.
- `cairn-cms`: 120 worktrees listed, 119 of them `.claude/worktrees/agent-*`. `claude-worktree-busy` exits 0.
- `cairn-cms` agent worktrees with uncommitted changes: 1
- `cairn-cms` agent worktrees whose branch tip is not on `origin/main`: 49

## Denials, last 30 days

Source: `~/.local/state/claude-denials.jsonl`, grouped by reason and the first two words of the command.

| Reason | Command | Count | Example |
| --- | --- | --- | --- |
| Classifier unavailable | `cd ~/Projects/ecxc-ski/docs/coach-tools/team-sheet` | 7 | `cd ~/Projects/ecxc-ski/docs/coach-tools/team-sheet
clasp push --force 2>&1 \| tail -2
clasp create-version "Fla` |
| Classifier unavailable | `~/Projects/ecxc-ski/docs/coach-tools/team-sheet.md` | 7 | `~/Projects/ecxc-ski/docs/coach-tools/team-sheet.md` |
| [Destructive or Unwanted Actions] | `cd ~/Projects/cc-desk-scratch` | 7 | `cd ~/Projects/cc-desk-scratch && git stash drop stash@{0}` |
| Classifier unavailable | `T=~/.claude/jobs/fcce294b/tmp; cd` | 4 | `T=~/.claude/jobs/fcce294b/tmp; cd web && head -30 $T/pixdiff.ts; ls $T/hack2a \| head; ls $T/hack2a \| wc -l` |
| [Interfere With Workloads] | `pkill -f` | 3 | `pkill -f "node --test" ; cd ~/Projects/cairn-cms/.claude/worktrees/agent-a2af82fd09acee2a8/packages/create-cai` |
| Classifier unavailable | `grep -n` | 3 | `grep -n 'command -v' scripts/check.sh Makefile scripts/vale-comments.sh; sed -n 360,440p scripts/check.sh` |
| Classifier unavailable | `cd /tmp/claude-1000/-var-home-glw907-Projects-ecxc-ski/a71986e4-5f36-4963-8794-5fec284905d6/scratchpad` | 3 | `cd /tmp/claude-1000/-var-home-glw907-Projects-ecxc-ski/a71986e4-5f36-4963-8794-5fec284905d6/scratchpad
python3` |
| [Auto-Mode Bypass] | `gh workflow` | 2 | `gh workflow run e2e.yml --repo glw907/cairn-cms --ref worktree-tool-fixes-run` |
| [Self-Modification] | `~/.dotfiles/.claude/worktrees/credential-hygiene-a/claude/.claude/settings.json` | 2 | `~/.dotfiles/.claude/worktrees/credential-hygiene-a/claude/.claude/settings.json` |
| [Interfere With Workloads] | `kill 1653019;` | 2 | `kill 1653019; cd ~/Projects/cairn-cms/.claude/worktrees/cairn-new-2/tool && timeout 120 go test -count=1 -time` |
| [Merge Without Review] | `gh pr` | 2 | `gh pr merge 175 --repo glw907/initiatives --merge --match-head-commit "$(git -C /tmp/claude-1000/-var-home-glw` |
| Classifier unavailable | `` | 2 | `` |
| Classifier unavailable | `S=1h0WS2YLYca9YbYB_T0zNDci_JgGNQdutKDORURHUrkU; cd` | 2 | `S=1h0WS2YLYca9YbYB_T0zNDci_JgGNQdutKDORURHUrkU; cd /tmp/claude-1000/-var-home-glw907-Projects-ecxc-ski/a71986e` |
| Classifier unavailable | `ls -d` | 2 | `ls -d ~/.claude/debug ~/.claude/logs ~/.cache/claude* 2>/dev/null; grep -rl "typescript-lsp" ~/.claude/debug 2` |
| [Destructive or Unwanted Actions] | `git stash` | 2 | `git stash drop stash@{0}` |
| Classifier unavailable | `cd ~/Projects/cc-desk` | 2 | `cd ~/Projects/cc-desk && S=/tmp/claude-1000/-var-home-glw907-Projects-cc-desk/f3f7d2db-cc8f-404e-ad72-bec3c8a2` |
| [Irreversible Local Destruction] | `git -C` | 1 | `git -C ~/Projects/standards reset --hard e89334b` |
| [Self-Modification] | `stow -d` | 1 | `stow -d ~/.dotfiles -R claude` |
| [Irreversible Local Destruction] | `S=/tmp/claude-1000/-var-home-glw907-Projects-phonebook/27c181dc-ebb0-45ee-9ca0-7805d1d091d4/scratchpad #` | 1 | `S=/tmp/claude-1000/-var-home-glw907-Projects-phonebook/27c181dc-ebb0-45ee-9ca0-7805d1d091d4/scratchpad
# surve` |
| [Merge Without Review] | `S=/tmp/claude-1000/-var-home-glw907-Projects-phonebook/27c181dc-ebb0-45ee-9ca0-7805d1d091d4/scratchpad timeout` | 1 | `S=/tmp/claude-1000/-var-home-glw907-Projects-phonebook/27c181dc-ebb0-45ee-9ca0-7805d1d091d4/scratchpad
timeout` |
| The server-side auto mode classifier judged this action dang | `source ~/.local/secrets;` | 1 | `source ~/.local/secrets; U="$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"; T=https://api.twilio.com/2010-04-01/Accou` |
| The server-side auto mode classifier judged this action dang | `~/Projects/workstation-wt/agent-first-pass-4-grants/claude/.claude/settings.json` | 1 | `~/Projects/workstation-wt/agent-first-pass-4-grants/claude/.claude/settings.json` |
| [Production Deploy] | `cd ~/Projects/phonebook/.claude/worktrees/silent-test-ring;` | 1 | `cd ~/Projects/phonebook/.claude/worktrees/silent-test-ring; sed -n 25,40p src/lib/server/normalize.ts \| cut -c` |
| The server-side auto mode classifier judged this action dang | `bash ~/Projects/servers/.claude/worktrees/servers-review-2026-11/scripts/dry-run.sh` | 1 | `bash ~/Projects/servers/.claude/worktrees/servers-review-2026-11/scripts/dry-run.sh` |
| The server-side auto mode classifier judged this action dang | `grep -n` | 1 | `grep -n -i -E 'list.*tokens\|tokens.*read\|API Tokens Read\|rule 6\|temporary token' ~/.claude/docs/cloudflare-est` |
| [Interfere With Workloads] | `node ~/.claude/jobs/7f3f2c5a/tmp/runin.mjs` | 1 | `node ~/.claude/jobs/7f3f2c5a/tmp/runin.mjs ~/Projects/cairn-cms/.claude/worktrees/agent-first-3/examples/showc` |
| [Secret-Store Writes] | `cd ~/.dotfiles;` | 1 | `cd ~/.dotfiles; bash scripts/secrets/secret-set.sh CAIRN_E2E_GH_TOKEN --delete 2>&1 \| cut -c1-120; bash script` |
| [Git Destructive] | `cd ~/Projects/cairn-cms;` | 1 | `cd ~/Projects/cairn-cms; git push origin --delete rc-0.98.1-rc.2 2>&1 \| sed -n 1,3p; git worktree prune; git w` |
| [Self-Modification] | `cd ~/.dotfiles/.claude/worktrees/automode-branch-delete` | 1 | `cd ~/.dotfiles/.claude/worktrees/automode-branch-delete && python3 -I - <<'E'
p='claude/.claude/settings.json'` |
| [Create Public Surface] | `cd ~/Projects/cairn-cms;` | 1 | `cd ~/Projects/cairn-cms; git pull --ff-only -q origin main; [ "$(jq -r .version package.json)" = 0.99.0-rc.1 ]` |
| [Self-Modification] | `cd ~/Projects/workstation-wt/cairn-gate-allow` | 1 | `cd ~/Projects/workstation-wt/cairn-gate-allow && python3 -I - claude/.claude/settings.json <<'EOF'
import sys
` |
| [Interfere With Workloads] | `cd ~/Projects/cairn-cms/.claude/worktrees/agent-a370821eb5f055abb/packages/create-cairn-site` | 1 | `cd ~/Projects/cairn-cms/.claude/worktrees/agent-a370821eb5f055abb/packages/create-cairn-site && pkill -f "crea` |
| [Unverifiable Deletion Scope] | `bash ~/.claude/jobs/582c5897/tmp/vault-finish.sh` | 1 | `bash ~/.claude/jobs/582c5897/tmp/vault-finish.sh` |
| [Unverifiable Deletion Scope] | `` | 1 | `` |
| [Sensitive-Source Provenance] | `~/Projects/initiatives/credential-hygiene/plans/STATUS.md` | 1 | `~/Projects/initiatives/credential-hygiene/plans/STATUS.md` |
| [Sensitive-Source Provenance] | `sed -i` | 1 | `sed -i 's\|^    spot = None$\|    spot = None\n    tok = ALIAS.get(tok, tok)\|; s\|^added, unmatched = 0, \[\]$\|AL` |
| The server-side auto mode classifier judged this action dang | `~/.dotfiles/.claude/worktrees/credential-hygiene-a/claude/.claude/settings.json` | 1 | `~/.dotfiles/.claude/worktrees/credential-hygiene-a/claude/.claude/settings.json` |
| [Self-Modification] | `python3 -I` | 1 | `python3 -I ~/.claude/jobs/12a84a8c/tmp/t9-settings.py` |
| The server-side auto mode classifier judged this action dang | `gh pr` | 1 | `gh pr close 157 --repo glw907/aksailingclub-legacy --comment "Superseded by #159, which carries these two comm` |
| [Security Weaken] | `jq '.env` | 1 | `jq '.env = {"NODE_USE_ENV_PROXY":"1"} \| .sandbox.network.allowedDomains += ["cdn.playwright.dev","playwright.d` |
| [Security Weaken] | `jq '.permissions.allow` | 1 | `jq '.permissions.allow += ([ "cd","rm","sed","chmod","bash","sh","tail","head","curl","sleep","timeout","kill"` |
| [DNS / Domain / Cert Changes] | `cd ~/Projects/servers/.claude/worktrees/apex-placeholder` | 1 | `cd ~/Projects/servers/.claude/worktrees/apex-placeholder && git fetch -q origin && git rebase -q origin/main &` |
| [Self-Modification] | `cd ~/.dotfiles/.claude/worktrees/automode-cleanroom-dns` | 1 | `cd ~/.dotfiles/.claude/worktrees/automode-cleanroom-dns && f=claude/.claude/settings.json && python3 -I - "$f"` |
| [Create Public Surface] | `cd /tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/3d778db3-3ae2-4251-b022-407d8b8c784f/scratchpad/spike-github2;` | 1 | `cd /tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/3d778db3-3ae2-4251-b022-407d8b8c784f/scratchpad/spike-` |
| [Bot Check Circumvention] | `cd /tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/3d778db3-3ae2-4251-b022-407d8b8c784f/scratchpad/spike-cfsignup` | 1 | `cd /tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/3d778db3-3ae2-4251-b022-407d8b8c784f/scratchpad/spike-` |
| [Self-Modification] | `cd ~/.dotfiles/.claude/worktrees/cairn-setup-grant` | 1 | `cd ~/.dotfiles/.claude/worktrees/cairn-setup-grant && python3 -I - <<'EOF'
import json
p='claude/.claude/setti` |
| [Git Destructive] | `cd ~/Projects/initiatives` | 1 | `cd ~/Projects/initiatives && sed -i 's/the plan stands as approved and the build launches/the plan is approved` |
| [Code from External] | `cd ~/.claude/jobs/f589c826/tmp` | 1 | `cd ~/.claude/jobs/f589c826/tmp && go run github.com/rhysd/actionlint/cmd/actionlint@latest ~/Projects/cairn-cm` |
| [Interfere With Workloads] | `kill -INT` | 1 | `kill -INT 4055939; sleep 2; ps -p 4055939 >/dev/null && kill -TERM 4055939; ps -p 4055939 >/dev/null && echo s` |
| The server-side auto mode classifier judged this action dang | `sed -i` | 1 | `sed -i 's\|gh repo create glw907-test/cleanroom-probe --public$\|gh repo create glw907-test/cleanroom-probe --pu` |
| [Self-Modification] | `cd ~/Projects/cairn-cms;` | 1 | `cd ~/Projects/cairn-cms; w=~/Projects/cairn-cms/.claude/worktrees/releasing-invocable; git worktree add -q -b ` |
| The server-side auto mode classifier judged this action dang | `cd ~/Projects/cairn-cms/.claude/worktrees/releasing-invocable` | 1 | `cd ~/Projects/cairn-cms/.claude/worktrees/releasing-invocable && python3 -I - <<'EOF'
p='.claude/skills/cairn-` |
| [Shared Scratch Sweep] | `for d` | 1 | `for d in /tmp/tmp.*; do [ -f $d/package-lock.json ] && [ -d $d/packages/create-cairn-site ] && rm -rf $d; done` |
| The server-side auto mode classifier judged this action dang | `claude stop` | 1 | `claude stop 6e3d2da4 2>&1; git -C ~/Projects/cairn-cms fetch -q origin && git -C ~/Projects/cairn-cms rev-pars` |
| [Auto-Mode Bypass] | `P=~/Projects/initiatives/monthly-model-review/plans; T=~/.claude/jobs/95c83688/tmp/standards-prompt.txt;` | 1 | `P=~/Projects/initiatives/monthly-model-review/plans; T=~/.claude/jobs/95c83688/tmp/standards-prompt.txt; W=~/P` |
| The server-side auto mode classifier judged this action dang | `cd ~/Projects/initiatives/.claude/worktrees/score-report` | 1 | `cd ~/Projects/initiatives/.claude/worktrees/score-report && git push origin HEAD:main` |
| [Interfere With Workloads] | `claude stop` | 1 | `claude stop 5d4b75f3 2>&1 \| tail -1; claude stop c1bd5c06 2>&1 \| tail -1` |
| Classifier unavailable | `cd ~/Projects/cairn-cms/.claude/worktrees/setup-tooling-r12` | 1 | `cd ~/Projects/cairn-cms/.claude/worktrees/setup-tooling-r12 && git status --short` |
| [Self-Modification] | `~/.dotfiles/.claude/worktrees/probe-refinement-1-perms/claude/.claude/settings.json` | 1 | `~/.dotfiles/.claude/worktrees/probe-refinement-1-perms/claude/.claude/settings.json` |
| [Safety Bypass Flag] | `git commit` | 1 | `git commit --no-verify -q -m "Retire the ratchet: plain checks print each violation and exit 1

The baseline h` |
| [Out-of-Place Publication] | `cd ~/Projects/initiatives` | 1 | `cd ~/Projects/initiatives && git pull -q --ff-only && sed -i 's/^  merged; pass 3, the polish loop, is next.$/` |
| Classifier unavailable | `git diff` | 1 | `git diff --name-only origin/main...HEAD \| grep -E '^(secrets/\|scripts/secrets/\|bash/\.bashrc$\|bin/\.local/bin/` |
| [PII Data Handling] | `cd ~/.claude/projects` | 1 | `cd ~/.claude/projects 2>/dev/null && grep -l --include='agent-*.jsonl' -r "Your final message is your first re` |
| Classifier unavailable | `npm run` | 1 | `npm run check --prefix approval-queue 2>&1` |
| Classifier unavailable | `bash tests/merge.test.sh` | 1 | `bash tests/merge.test.sh 2>&1 \| tail -3; bash tests/packet.test.sh 2>&1 \| tail -3` |
| Classifier unavailable | `TMPDIR=~/.claude/jobs/4957d346/tmp npx` | 1 | `TMPDIR=~/.claude/jobs/4957d346/tmp npx vitest run 2>&1 \| grep -E "×\|Tests \|Test Files" \| head` |
| [Destructive or Unwanted Actions] | `cd ~/Projects/approval-queue` | 1 | `cd ~/Projects/approval-queue && claude stop 4957d346; echo stop=$?; claude-worktree-busy ~/Projects/approval-q` |
| [Undermining Oversight] | `claude stop` | 1 | `claude stop 4957d346; echo a5=$?; cd ~/Projects/approval-queue; git worktree list \| grep aq-a6; git status -sb` |
| [Destructive or Unwanted Actions] | `(npm ci` | 1 | `(npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync)) 2>&1 \| tail -5;` |
| [Destructive or Unwanted Actions] | `bash ~/Projects/cairn-cms/.claude/worktrees/setup-tooling-r12/scripts/gate/README.md` | 1 | `bash ~/Projects/cairn-cms/.claude/worktrees/setup-tooling-r12/scripts/gate/README.md 2>/dev/null; TMPDIR=~/.cl` |
| Classifier unavailable | `cd ~/Projects/cairn-cms/.claude/worktrees/tui-language-2` | 1 | `cd ~/Projects/cairn-cms/.claude/worktrees/tui-language-2 && CAIRN_GATE_LANE=light cairn-run-gate 'make -C tool` |
| [Undermining Oversight] | `set -e;` | 1 | `set -e; cd ~/Projects/initiatives
python3 -I - <<'EOF'
import pathlib
p=pathlib.Path('theme-garden/specs/2026-` |
| [Destructive or Unwanted Actions] | `kill 1838163` | 1 | `kill 1838163 1845716 2>/dev/null; for i in $(seq 1 250); do busy=0; for p in $(pgrep -x cairn.test; pgrep -x c` |
| [Destructive or Unwanted Actions] | `pkill -f` | 1 | `pkill -f 'lane:fast' ; pkill -f lane-fast; sleep 2; pgrep -fa 'lane' \| head` |
| Classifier unavailable | `make -C` | 1 | `make -C tool copy-list >/dev/null; echo copy-list=$?; git diff --stat -- tool/testdata \| tail -2; grep -rn '"n` |
| Classifier unavailable | `git add` | 1 | `git add BACKLOG.md CHANGELOG.md MIGRATION-NOTES.md schema/cairn-health.schema.json && git commit -q -m "Drop p` |
| [Modify Shared Resources] | `git commit` | 1 | `git commit -q -m "Backlog: stamp the 23 items the site-basics design keeps

Co-Authored-By: Claude Fable 5.2 <` |
| [Destructive or Unwanted Actions] | `sed -n` | 1 | `sed -n 115,140p ~/.claude/docs/unattended-work-guards.md; Q=~/Projects/approval-queue; claude stop 0e8f4650; g` |
| [Unauthorized Access] | `d=$(mktemp -d);` | 1 | `d=$(mktemp -d); cd "$d" && curl -fsSL -o l.tar.xz https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15` |
| Classifier unavailable | `ROUND_WATCH_POLLS=30 round-watch` | 1 | `ROUND_WATCH_POLLS=30 round-watch cairn-cms-pennant glw907/cairn-cms pennant; echo "exit $?"` |
| Classifier unavailable | `cat /tmp/claude-1000/-var-home-glw907-Projects-dubplate/fcce294b-a0e6-4eca-8274-1e79b56d4d58/tasks/b4bryeydb.output;` | 1 | `cat /tmp/claude-1000/-var-home-glw907-Projects-dubplate/fcce294b-a0e6-4eca-8274-1e79b56d4d58/tasks/b4bryeydb.o` |
| Classifier unavailable | `git show` | 1 | `git show master:docs/archive/plans/2026-11-15-cleanup-ci.md \| head -150` |
| Classifier unavailable | `ls -la` | 1 | `ls -la ~/.claude/jobs/fcce294b/tmp/; wc -l ~/.claude/jobs/fcce294b/tmp/cells-current.log 2>&1; tail -5 ~/.clau` |
| Classifier unavailable | `~/Projects/ecxc-ski/docs/coach-tools/team-sheet/Code.js` | 1 | `~/Projects/ecxc-ski/docs/coach-tools/team-sheet/Code.js` |
| Classifier unavailable | `typescript-language-server --version` | 1 | `typescript-language-server --version 2>&1 \| head -5; echo "exit ${PIPESTATUS[0]}"; pwd; ls ~/Projects/tsconfig` |
| Classifier unavailable | `cd ~/Projects/dubplate/.claude/worktrees/cleanup-gate;` | 1 | `cd ~/Projects/dubplate/.claude/worktrees/cleanup-gate; grep -n -E '^\s+--[a-z-]+\)' scripts/check.sh \| head; s` |
| [Unauthorized Access] | `W=~/Projects/dubplate/.claude/worktrees/agent-a828799e8800f0243; C=$W/cmd/dubplate-server` | 1 | `W=~/Projects/dubplate/.claude/worktrees/agent-a828799e8800f0243; C=$W/cmd/dubplate-server
sed -i 's\|"discard_c` |
| [Destructive or Unwanted Actions] | `W=~/Projects/dubplate/.claude/worktrees/agent-a828799e8800f0243/internal/engine/store sed` | 1 | `W=~/Projects/dubplate/.claude/worktrees/agent-a828799e8800f0243/internal/engine/store
sed -i -e 's#&libraryOwe` |
| [Unauthorized Access] | `grep -l` | 1 | `grep -l 'exportFormat=xlsx' ~/.claude/projects/-var-home-glw907-Projects-ecxc-ski/*.jsonl 2>/dev/null; f=$(gre` |
| Classifier unavailable | `cd ~/Projects/cairn-cms` | 1 | `cd ~/Projects/cairn-cms && claude --bg --model sonnet --effort medium --name conductor-foundation "$(cat ~/Pro` |
| [Destructive or Unwanted Actions] | `~/Projects/dubplate/.claude/worktrees/cleanup-ops/cmd/dubplate-server/apimount_test.go` | 1 | `~/Projects/dubplate/.claude/worktrees/cleanup-ops/cmd/dubplate-server/apimount_test.go` |
| Classifier unavailable | `cd ~/Projects` | 1 | `cd ~/Projects && grep -n -E '^#{2,3} ' dubplate/BACKLOG.md \| cut -c1-150 \| head -70; echo ---- ; sed -n '/roun` |
| Classifier unavailable | `cd ~/.claude/jobs/818e389e/tmp/cairn-read` | 1 | `cd ~/.claude/jobs/818e389e/tmp/cairn-read && grep -c -E '^#{2,3} ' BACKLOG.md; grep -n -E '^#{2,3} ' BACKLOG.m` |
| [Unauthorized Access] | `cd ~/.claude/jobs/10277ab8/tmp/dubplate-read/internal/engine/musicbrainz` | 1 | `cd ~/.claude/jobs/10277ab8/tmp/dubplate-read/internal/engine/musicbrainz && dens(){ awk '{l=$0; sub(/^[ \t]+/,` |
| [Destructive or Unwanted Actions] | `cd "$CLAUDE_JOB_DIR/tmp/dubplate-read"` | 1 | `cd "$CLAUDE_JOB_DIR/tmp/dubplate-read" && git remote -v \| sed 's#~/Projects/dubplate#<MAIN>#g'` |
| [Destructive or Unwanted Actions] | `claude agents` | 1 | `claude agents --json 2>/dev/null \| python3 -I -c "
import json,sys
for a in json.load(sys.stdin):
    print(a.` |
| [Destructive or Unwanted Actions] | `cd ~/Projects/cairn-cms;` | 1 | `cd ~/Projects/cairn-cms; pgrep -fa 'node.*fast-lane\|lane:fast' \| grep -v pgrep \| head -3; git commit -qam "Run` |
| [Interfere With Workloads] | `kill 2088698` | 1 | `kill 2088698` |
| [Interfere With Workloads] | `ps -o` | 1 | `ps -o pid,etime -p 2088698,2088724; claude-worktree-busy ~/Projects/cairn-cms/.claude/worktrees/tool-delete; e` |
| [Undermining Oversight] | `cd ~/Projects/dubplate/.claude/worktrees/agent-aa21fa8a71575ca4c/internal/engine/tagio` | 1 | `cd ~/Projects/dubplate/.claude/worktrees/agent-aa21fa8a71575ca4c/internal/engine/tagio && python3 -I - <<'EOF'` |
| [Undermining Oversight] | `cat >` | 1 | `cat > /tmp/td-edit.mjs <<'EOF'
import fs from 'node:fs';
function rep(f, a, b){ let t=fs.readFileSync(f,'utf8'` |
| [Destructive or Unwanted Actions] | `sleep 90` | 1 | `sleep 90 && echo step1 >> progress.txt` |
| [Self-Modification] | `~/Projects/cc-desk/.claude/worktrees/cc-desk-prove-run2/spikes/4-permissions/settings.json` | 1 | `~/Projects/cc-desk/.claude/worktrees/cc-desk-prove-run2/spikes/4-permissions/settings.json` |
| [Undermining Oversight] | `echo "-` | 1 | `echo "- [Requested config change lands directly](requested-config-change-lands-directly.md) — a one-line recor` |
| Classifier unavailable | `cd ~/Projects/cc-desk/.claude/worktrees/desk-records` | 1 | `cd ~/Projects/cc-desk/.claude/worktrees/desk-records && sed -n 1,80p e2e/main_test.go; cat e2e/testdata/README` |
| [Destructive or Unwanted Actions] | `claude stop` | 1 | `claude stop d5647ebf` |
| Classifier unavailable | `cd ~/Projects/cc-desk/.claude/worktrees/desk-page` | 1 | `cd ~/Projects/cc-desk/.claude/worktrees/desk-page && bash web/scripts/check-link.sh` |
| [Destructive or Unwanted Actions] | `git -C` | 1 | `git -C ~/Projects/cc-desk-scratch switch main >/dev/null 2>&1; mv ~/.local/state/cc-desk/releases/cc-desk-scra` |
| The server-side auto mode classifier judged this action dang | `cd ~/Projects/cc-desk-scratch` | 1 | `cd ~/Projects/cc-desk-scratch && git stash drop stash@{0}` |
| [Undermining Oversight] | `approval-queue answer` | 1 | `approval-queue answer 20261117-230223-743a55 approve --words "Both, #260 first (Recommended)" 2>&1 \| tail -10` |
| [Undermining Oversight] | `cd ~/.dotfiles/.claude/worktrees/cc-desk-unhook` | 1 | `cd ~/.dotfiles/.claude/worktrees/cc-desk-unhook && git add claude/.claude/CLAUDE.md && git commit -q -m "Exemp` |
| Classifier unavailable | `sed -n` | 1 | `sed -n 255,330p bin/.local/bin/claude-tooling-sync` |
| [Destructive or Unwanted Actions] | `cd ~/Projects/standards` | 1 | `cd ~/Projects/standards && grep -c '\.brand\\|BRANDING' plugins/standards/skills/brainstorming/scripts/server.c` |

## Rows that bear on these specs

- `[Self-Modification]` refused a `cairn-cms` session that made a worktree and edited a file under
  `.claude/skills/` (`releasing-invocable`), and a neighbouring classifier refusal hit the same
  edit. A task that rewrites a repo's skills, agents, rules, or hooks can meet this refusal. Probe
  it once from a `claude --bg` task session before the spec names that step.
- `[Git Destructive]` refused `git push origin --delete` on a `cairn-cms` rc branch. Worktree and
  branch cleanup is the merging session's work, per `building-from-specs` "Merging".
- `[Merge Without Review]` refused `gh pr merge` twice. Only Geoff's session merges.
- `[Auto-Mode Bypass]` refused `gh workflow run` on `cairn-cms`. A task that needs a manual CI run
  can't start one itself.
- The "Classifier unavailable" rows are outages, not rules.
