# Release plans A and B: data-integrity and failure-risk review

Lens: data integrity and failure risk (standards:spec-plan-review). Targets, read together:

- Plan A: `shared-standards/plans/2026-11-03-release-gate-a-plan.md` (+ prompt)
- Plan B: `shared-standards/plans/2026-11-03-release-process-b-plan.md` (+ prompt)
- Spec `specs/2026-11-03-release-gate-and-process-design.md` at initiatives `ed6fd0c` worktree.
- Code: cairn-cms `main` `bb3c8d3a2`. Pre-flight scripts:
  `~/.local/state/cairn-agent-first/preflight-token-probes.py` (cited `probe.py`) and
  `apply-release-process-grant.sh` (cited `grant.sh`).

Counts: 1 blocker, 7 major, 17 minor. Ranked by consequence within each severity.

## Blocker

### I1. The probe script never tests PS's duplicate-name question, and the one temporary token is spent before anyone notices
- Severity: blocker. Tag: correctness.
- Location: `probe.py:100-114`; plan A `:32`, `:156-161`; plan A prompt ("If any row still reads pending ... wait"); spec `:294`.
- Defect: spec PS says "register it twice under one probe name". The script registers `PS_NAME` once (`probe.py:101-105`). Plan A's reading row "PS, Builds accepts two registrations with one name" (`:32`) cannot be filled, and P1's stale branch is chosen from it (`:157-158`): if duplicates are refused, the CLI must register `cairn-build-<yyyymmdd>`, and getting that wrong makes the stale path fail on a real install. The executor prompt stops at launch on any `pending` row. The script deletes `tmp-token-setup` at its end (`probe.py:136`) whatever happened, so a rerun needs a second dashboard trip from Geoff.
- Fold: before the sitting, add a second `POST .../builds/tokens` with the same `PS_NAME` (same secret and id), record its status and code as the duplicate reading, and capture both uuids for deletion. Dry-run again. Also print the field names of one entry (row `:33`) explicitly rather than leaving it to a JSON dump.

## Major

### I2. The probe script has no failure path: an exception orphans a live token-minting credential, a copy of the production build token, and probe resources
- Severity: major. Tag: correctness.
- Location: `probe.py:33-53` (`call`), `:80-140` (`main`).
- Defect: `call` catches only `HTTPError`. A `URLError`, `TimeoutError`, connection reset, or a 200 with a non-JSON body (`json.load` raising `ValueError`) raises out of `main` with no cleanup. What is left depends on the point: the PS token (account Workers Scripts Read), the PS registration, the P1 registration holding `ci-cairn-build`'s secret under a probe name, an empty D1 database and R2 bucket, and `tmp-token-setup` (permission "Create Additional Tokens", so it can mint any token on the main account) still live until its TTL. The value of the last one also stays in `/dev/shm/tmp-setup-<uid>.age` and `$XDG_RUNTIME_DIR/self-hosting/secrets-tmp-setup` until reboot, and nothing in the plan removes those files. A server-side create whose response times out also leaves a registration whose uuid the script never learned. The end check only reports leftovers (`:131-135`); it never deletes them.
- Fold: catch `urllib.error.URLError`, `OSError`, and `ValueError` in `call` and return a failure tuple. Wrap the body in `try/finally`: the `finally` deletes every id the run created (a list appended on each successful create), then lists registrations and deletes by uuid any whose name ends `-{STAMP}` (this run's exact names, never `cairn-build` and never a prefix shared with real state), then deletes `tmp-token-setup`. Add to PF2's check: both tmp-token store files are removed (`rm -f` on the two paths), `GET /user/tokens` no longer lists the PS token (the spec's done-when, which the script never reads), and `d1/database?name=` and the R2 bucket read for `WRITE_NAME` answer empty.

### I3. A group rerun can leave earlier `pass` rows in the rehearsal record, so `verdict.mjs --file` passes on code the rerun was meant to prove
- Severity: major. Tag: correctness.
- Location: plan A T4 `:99`, `:107-108`; T6 `:125`, `:131`; R1 step 4-5 `:218-220`; S5 `:267`.
- Defect: only `--all` writes the fresh `pending` section. A `--leg A1 --leg A2` rerun (R1 step 4, S5) merges rows over the earlier ones by leg. If that rerun dies before its `finally` (SIGKILL, a lost session, a teardown hang), or its record write fails (T4 makes a failed write "logged, and the leg's own error stands"), the file keeps the previous run's A1 and A2 `pass` rows. They carry one run id, so the per-group rule in `--file` mode is met and R1 step 5 passes on evidence from before the fix.
- Fold: a `--leg` run also first writes `pending` rows, carrying its run id, for exactly the legs it names, through the same writer, and aborts if that write fails. T4 acceptance gains: a `--leg A1 --leg A2` run whose A1 throws before its row leaves A1 `pending` (not the earlier `pass`), and `verdict --file` then exits 1.

### I4. A re-packed tarball keeps the same path and version, so `npx file:<tgz>` may run the cached earlier build on every rerun
- Severity: major. Tag: correctness.
- Location: plan A R1 step 1 and 4 `:215`, `:218`; T6 `:125`, `:130`; spec A15 `:135`.
- Defect: every re-pack writes `create-cairn-site-0.99.0-rc.3.tgz` (the package version on main) to the same directory, and the leg runs `npx --yes file:<that path>`. npx keys its install directory under `~/.npm/_npx/` by the spec string and reuses an existing install when the tree looks satisfied. The plan does not show that a changed tarball at an unchanged path and version is reinstalled. If it is not, every rerun after a product fix runs the previous product code, and the rehearsal's pass proves code that does not merge. The repo already hit an npx cache staleness on the registry path (#342, `fc91768c5`). This is unprobed, so I state it as a risk to settle, not a fact.
- Fold: R1 step 1 renames each pack to a content-unique path (`create-cairn-site-<short head sha>-<n>.tgz`), and `--cli` takes that path, so the npx key changes per build. Record the tarball's `sha256sum` in the run dir. T6 acceptance gains one probe the implementer runs: two different tarballs packed to the same path in turn, each run through `npx --yes file:`, print different marker strings. If the probe shows npx reinstalls, keep the rename anyway; it costs one `mv`.

### I5. A killed run orphans its installs, and the rerun path skips stale teardown, so the test domain stays bound to a dead Worker
- Severity: major. Tag: correctness.
- Location: plan A R1 step 4 `:218`; `gate.mjs:378` (`teardownStale` only under `--all`); `run-gate.sh:50-57`.
- Defect: on SIGKILL, or a second TERM during the EXIT trap's teardown, the run tears nothing down and prints no `teardown left:` line. R1 step 4 runs `--teardown-stale` only "when the previous run printed a `teardown left:` line", and a `--leg` rerun never calls `teardownStale`. The orphan keeps `carin-test.org` attached as a custom domain, plus its Builds trigger, D1, R2, GitHub repo, and App. The next group A run then fails on the domain or DNS step, a failure the rehearsal's rules would read as a product or harness gap.
- Fold: R1 step 4 runs `bash scripts/gate/run-gate.sh --teardown-stale` before every rerun, unconditionally; it is idempotent and finds nothing on a clean tree. Better: T6 makes `--leg` call `teardownStale` as `--all` does, under the lock. Either way, add a T6 test: a leftover state record in another run dir is torn down before a `--leg` run starts.

### I6. The lock can outlive its run, and the only standing answer is to wait forever
- Severity: major. Tag: correctness.
- Location: plan A T6 `:125`, `:132`; S14 `:276`; R1 step 3 `:217`.
- Defect: `flock -n` on an fd that `run-gate.sh` opens is inherited by `node gate.mjs` and every grandchild (npx, the CLI, wrangler, Chromium). After a SIGKILL of the script, a surviving grandchild holds the lock. S14 says "Wait for it to exit. Never start a second run", which never resolves. The lock also does not name a holder: `flock` exposes no pid, so the "naming the holder's pid" acceptance needs a pid file, which goes stale on a crash. R1's Monitor waits on `<run dir>/exit`, which a SIGKILL never writes, so the Monitor never ends either. An EXIT-trap teardown that hangs (browser App deletion has no budget) also never writes `exit`.
- Fold: (a) T6 writes `pid run_dir` to `lock.holder` after acquiring, and the refusal prints it with `kill -0` liveness. (b) S14 gains: if the named pid is dead and the run dir has no `exit`, list the processes holding the lock (`fuser ~/.local/state/cairn-gate/lock`), stop those whose command line names that run dir, run `--teardown-stale`, and go on; otherwise wait. (c) R1's Monitor condition becomes `until [ -f <run dir>/exit ] || flock -n ~/.local/state/cairn-gate/lock true; do sleep 60; done`. (d) Bound the EXIT trap's teardown with `timeout 20m`, so `exit` is always written.

### I7. The stable-cut hook fails open on any internal error
- Severity: major. Tag: correctness.
- Location: plan B B5 `:273-281`, acceptance `:298-305`.
- Defect: a PreToolUse hook that throws, or exits with a code other than 0 or 2 and no JSON, is a non-blocking error, and the command runs. The hook runs `node scripts/checks/check-stable-source.mjs` in the input's `cwd`. A session whose `cwd` lacks that file, a spawn failure, a timeout, or a malformed stdin then lets `gh release create v0.99.0 --target <sha>` through. That creates a permanent tag under the new ruleset and publishes a permanent stable. No acceptance case covers the error path.
- Fold: the hook wraps its whole body in `try/catch`. For any command matching `gh\s+release\s+create`, any internal error or a missing check script yields `permissionDecision: "deny"` with the error as the reason. Acceptance gains three cases: the check script absent in `cwd`, the check script crashing, and malformed stdin JSON, each denied for a stable tag. Match `gh` and `release create` with `\s+`, so a doubled space cannot slip past the substring test.

### I8. The first live run of the rewritten `publish.yml` happens on a permanent `rc.4` tag
- Severity: major. Tag: correctness. **OWNER FORK.**
- Location: plan B B3 `:172-228`, Close step 1 `:459-462` ("B3's tests are its proof until `rc.4`"); spec rc.4 sequence step 5 `:264`, pre-flight step 4 rulesets `:102-104`.
- Defect: B3 rewrites the workflow: new `ci-green` polling, SHA-pinned actions, a cross-job artifact, a sparse-checkout `verdict`, and environment-bound jobs. Its only proof before `rc.4` is a YAML-shape unit test. The `release-tags` ruleset forbids moving or deleting `v0.99.0-rc.4`, and `build` requires `GITHUB_REF_NAME` to match the manifests. So a workflow defect found at step 6 (a wrong check-run name, an artifact path, a SHA pin that does not resolve, a `checks: read` scope) cannot be fixed under that tag. `rc.4` becomes unpublishable, and the round goes to `rc.5` with one more cut (about 200 minutes). `gh run rerun` reruns the tag's own broken file.
- Options: (A) add a `dry_run` dispatch input that runs only `ci-green` and `build` (no `id-token` job runs, no publish), and have the conductor dispatch it once on `main` after both merges and before rc.4 step 3, behind a matching allow rule; it costs about 15 minutes and one more input in the workflow. (B) add `actionlint` (pinned) to B3's test and accept the residual. (C) accept the risk as written; a failure costs `rc.5`.
- Recommendation: (A), plus `actionlint` in (B). The burned tag is the one failure in this round that costs a whole cut, and the dry run exercises every new mechanism except the OIDC publish itself.

## Minor

### I9. T7 sends the registration probe with a bearer that cannot register
- Severity: minor (a fast live failure, but it costs a rehearsal start). Tag: correctness.
- Location: plan A T7 `:144`; spec A12 `:180`; `probe.py:9-10`.
- Defect: T7's acceptance asserts "the D1, R2, and registration-probe calls with the build token's bearer". `ci-cairn-build` holds Workers Scripts, D1, and R2 only. Registering through `/builds/tokens` needs Workers CI, which `CF_WS_CAIRN_GATE_TOKEN` holds (the probe script makes that call with the gate token). Built to this acceptance, R1 step 2's smoke FAILs live.
- Fold: the registration probe's POST and DELETE go with the gate token, carrying the build token as `build_token_secret` and its verify id as `cloudflare_token_id`; only `/user/tokens/verify`, D1, and R2 use the build token's bearer. Fix the acceptance line to say so.

### I10. The smoke's registration probe leaves a copy of the production build token behind on any interruption, and nothing sweeps it
- Severity: minor. Tag: correctness.
- Location: plan A T7 `:139`; `gate.mjs:245-253`; PF6 `:24`.
- Defect: from T7 on, each smoke registers `ci-cairn-build`'s secret under `cairn-e2e-gate-probe-<ms>` and deletes it by uuid. A kill or a failed DELETE between those calls leaves the registration, and teardown never touches registrations. Only PF6 looks for leftovers, and only once, before launch.
- Fold: the T7 info line also counts `cairn-e2e-gate-probe-*` registrations, and R1 step 5 and rc.4 step 7 require that count to be 0. A leftover is deleted by its listed uuid (a gate-owned prefix, never `cairn-build`).

### I11. PF6 reads for a probe-name prefix the probe script does not use, and for a `cairn-build` line it does not print
- Severity: minor. Tag: correctness.
- Location: plan A PF6 `:24`; `probe.py:25-28`, `:131-135`.
- Defect: the script names its probes `cairn-gate-probe-*`; PF6 checks for `cairn-e2e-gate-probe-*`. The script's final read prints only its own prefix and never whether `cairn-build` exists. When the list call fails, `registrations()` returns `[]` and the script prints "ok no probe registration left", which is false.
- Fold: the script's last read prints the `cairn-build` count and any name starting `cairn-gate-probe-` or `cairn-e2e-gate-probe-`, and prints "unknown" when the list fails. PF6 cites those lines.

### I12. The S9 "trigger read" names no method, and triggers are per Worker
- Severity: minor this round (no real site holds `cairn-build` yet), but the same read guards the Later deletion of the old wide registration, which real sites do hold. Tag: correctness.
- Location: plan A S9 `:271`; spec `:65`, `:360`; `api.mjs:583-584` (`/builds/workers/<tag>/triggers`).
- Defect: no account-wide trigger list exists in the client. "A trigger read shows no trigger holds it" needs every Worker's triggers on the account, real sites included, compared by `build_token_uuid`. Read only over the gate's Workers, it proves nothing.
- Fold: S9 spells out the read: list the account's Workers, then for each Worker list `listBuildTriggers` and collect `build_token_uuid`, and delete only when the uuid is absent from all of them. Log the full collected set in the run dir. Make this one small script under `scripts/gate/`, so the Later cleanup reuses it.

### I13. Commands for refused steps go to `docs/STATUS.md`, which is pushed to a public repo
- Severity: minor. Tag: correctness.
- Location: plan A `:36`, S7 `:269`, S9 `:271`, S15 `:277`.
- Defect: the executor writes "the exact command" for a refused sourced-secret `curl` (mailbox query, uuid delete) to STATUS on its pushed branch. Nothing says the command must reference the secret by `$NAME` and never by value. A command written after an `echo` or a sourced expansion would publish the Stalwart password or a Cloudflare token.
- Fold: one rule line in "Rules for every task": a command written to STATUS or a report names each secret only as `$NAME` inside a `bash -c '. ~/.local/secrets; ...'` form, and the executor greps the diff for the known secret names' values through `run-gate.sh`'s sourcing before each push. The simpler form is to send the command to the conductor by message rather than STATUS.

### I14. The gate account's name becomes a committed constant, and Cloudflare's default name holds the owner's email
- Severity: minor. Tag: optional.
- Location: plan A T3 `:85`, `:93`; PF4 `:22`.
- Defect: a default Cloudflare account name is `<email>'s Account`. T3 commits it to public source as `GATE_ACCOUNT_NAME`.
- Fold: if PF4's reading holds an email, the label is read at run start through `GET /accounts/<id>` with the gate token and passed into `promptTable`, with no committed constant. Otherwise keep the constant.

### I15. Failure text from GitHub and admin pages lands in the public `rc.4` release body
- Severity: minor. Tag: correctness.
- Location: plan A T1 `:62` (throws "with the page text" and "with the alert text"); T4 `:99` (`fail:` joins every reason); `record.mjs:38-44` (refuses only `token=`); spec Later M12 `:357`.
- Defect: under rc.4 (no `--cli`) the row goes to a public release body. Page text from a GitHub page can carry the machine account's login and email. The A5 change now joins every failure, not just the first.
- Fold: T1's thrown messages carry the URL's host and path plus at most 200 characters of text. The record writer runs the same scrub R2 uses (login, emails) over each cell before writing a release body.

### I16. R2's subagent reads raw run dirs that hold sign-in URLs and unscrubbed captures
- Severity: minor. Tag: correctness.
- Location: plan A R2 `:232`; T3 `:84` (captures kept in failed dirs).
- Defect: a failed run dir now keeps `urls.log` (magic-link `token=` and OAuth `code=` URLs) and `capture-*.bin` indefinitely. R2's dispatch says the run-dir paths are "read by path" with no file list, so the transcript can take them in. Failed dirs also accumulate forever with no retention rule.
- Fold: R2's dispatch names only `*.controls.txt` files and the teardown log lines, by full path, and forbids `urls.log` and `capture-*`. Add one Later line for a retention rule on `failed` run dirs.

### I17. The rehearsal's run dirs and the resumed-session case are not defined
- Severity: minor. Tag: correctness.
- Location: plan A R1 step 2 `:216`, step 5 `:221-224`.
- Defect: step 5 counts prompt answers "across the `driver.log` of every rehearsal run dir", but nothing records which dirs those are (the runs directory also holds smoke runs and the four `rc.3` runs). A resumed executor rerunning step 2 finds count 1 and has no answer.
- Fold: each R1 gate invocation appends its `run dir:` line to `~/.local/state/cairn-gate/rehearsal/runs.txt`, and step 5 reads that list. Step 2 reads: count 0 on the first run; on a resume, count 1 with a token-id match, and the prompt count spans `runs.txt`.

### I18. A rerun typo without `--cli` writes `pending` rows to `rc.3`'s public release body
- Severity: minor. Tag: correctness.
- Location: plan A T6 `:125`; T4 `:99`; spec A15 `:135`.
- Defect: `--all --version 0.99.0-rc.3` without `--cli` runs the published `rc.3` setup tool and writes a fresh `## Gate` of `pending` rows into `rc.3`'s body. The spec's A15 says that body must never claim a gate.
- Fold: `gate.mjs` refuses a release-body record when `--version` names a release whose tag is older than the newest `v*` tag on origin, or simply when `--version 0.99.0-rc.3` lacks `--cli`. A one-line guard with one test.

### I19. Main's unlocked harness stays callable by any session during pass A
- Severity: minor. Tag: correctness.
- Location: plan A PF6 `:24`; `gate.mjs:378`; user allow rule `Bash(bash scripts/gate/run-gate.sh *)`.
- Defect: the lock exists only on pass A's branch. Until pass A merges, `bash scripts/gate/run-gate.sh --all` from the main checkout (another session, or the conductor testing) takes no lock and tears down the rehearsal's live installs through `teardownStale`. The rehearsal's `--all` likewise tears down another run's installs.
- Fold: the conductor's launch prompt states that no gate run starts from any checkout but pass A's worktree until pass A merges. R1 checks `pgrep -f scripts/gate/gate.mjs` before each run.

### I20. The grant script is not rerunnable and leaves state behind on failure
- Severity: minor. Tag: correctness.
- Location: `grant.sh:181-206`.
- Defect: under `set -e`, a failed gate, push, or merge leaves the worktree `~/.cache/wt-release-process-grant` and branch `release-process-grant`, and a rerun fails at `worktree add -b`. If the merge succeeded but `pull --ff-only` fails (the main checkout has diverged, for example after PF2's direct inventory commit was not pushed), `claude-tooling-sync apply` never runs. A rerun then trips the "already present" assert, because `origin/main` now holds the line. The grant is merged but not applied, and the script cannot finish.
- Fold: add an EXIT trap that removes the worktree. Before the `worktree add`, if `git show origin/main:claude/.claude/settings.json` already holds the marker, skip to pull and apply. PF2 pushes its inventory commit and checks `git rev-list --count origin/main..main` is 0 before the grant runs.

### I21. Two allow rules reach further than their stated purpose
- Severity: minor. Tag: optional.
- Location: plan B B5 `:283-285`.
- Defect: `Bash(node scripts/release/*)` also matches `node scripts/release/../../<any>.mjs`, a prompt-free run of any node script. `Bash(gh workflow run publish.yml --ref v* -f promote=*)` also allows `--ref v0.99.0-rc.3 -f promote=0.99.0-rc.3`, which runs the old tag's `publish.yml`: no `verdict`, no environment. The spec accepts that residual as "a deliberate act no script performs" (`:296`), but the rule makes it prompt-free.
- Fold: list the seven script rules by name (`Bash(node scripts/release/preflight.mjs *)` and so on). The release-cut-guard hook also denies `gh workflow run publish.yml` unless the `--ref` is the literal `v<promote value>`, and denies an empty `promote=`. That is three lines in a hook that already parses `gh` commands.

### I22. `bump` writes the manifests before `emit:template` runs, which contradicts "computes every file in memory and checks before writing"
- Severity: minor. Tag: correctness.
- Location: plan B B2 `:129-138`, `:156-157`; the real-tree check `:162-164`.
- Defect: the template pins and `VERSION` come from a subprocess that runs after the manifests are on disk, so a failed emit leaves a half-bumped tree. The dirty-tree refusal and `git restore` recover it, but the message must name all eight files. The real-tree check restores "those eight files" only, so a bug that writes a ninth file survives into the worktree and can be committed.
- Fold: on an emit failure, `bump` restores the files it wrote and exits 1. The real-tree check ends with `git status --porcelain` empty after the restore, and pastes it.

### I23. `ci-green` must pick the latest check run per name, since the cut's `test` may be rerun once
- Severity: minor. Tag: correctness.
- Location: plan B B3 `:178-182`; spec "CI on the cut commit" `:66`.
- Defect: after the standing-answer rerun, the sha carries two `test` check runs, one failed. A poll that takes any or the first by name blocks a green cut, or (taking any success) passes a stale one.
- Fold: query with `filter=latest` explicitly and take the newest run per name by `id`. Add a test fixture with a failed run followed by a successful rerun.

### I24. A failed `rc.4` gate must rerun `--all`, not a group, and no plan says so
- Severity: minor. Tag: correctness.
- Location: plan B B6 `:316-333`; spec rc.4 step 7-8 `:266-267`.
- Defect: `verdict.mjs` without `--file` needs one run id across all four rows. A group rerun on the candidate can never pass it. A session that copies the rehearsal's group-rerun habit spends a gate run, about 110 minutes, for a guaranteed refusal.
- Fold: B6's "Gate the candidate" text states that a candidate failure reruns `--all`.

### I25. The probe prints whole registration entries to the transcript
- Severity: minor. Tag: optional.
- Location: `probe.py:73-77`.
- Defect: `reading` prints `json.dumps(entry)` on the claim that the fields carry no secret. That claim is unprobed, and the entry holds a registration of a live token.
- Fold: print the keys, plus `build_token_uuid`, `build_token_name`, `cloudflare_token_id`, and any timestamp field. Also redact any value equal to a loaded token.

## Checked and found sound

- Teardown deletes only recorded names with the `cairn-e2e-gate-` guard (`teardown.mjs:66-71`) and never a registration. No shared-name deletion path exists in either plan; P1's stale path never deletes.
- A wrong merge order fails closed: with B alone, `preflight` refuses an empty `## Unreleased` and `verdict` finds no `verdict.mjs`. The passes' file lists are disjoint, and `BACKLOG.md`, `CHANGELOG.md`, and `STATUS.md` are handled by the conductor's shared-file rule.
- A half-published `rc.4` is covered: the publish jobs keep their already-published guards, `gh run rerun --failed` is safe, and `withdraw` prints the split.
- The post-merge hook probe targets a missing repo, so a hook that did not load creates nothing.
- `--cli` rows go to a mode-0700 local file, never `rc.3`'s body (but see I18).

## Over-ceremony

None found that costs real time. The R1 triple wake-up (background exit, Monitor, `/loop`) is cheap and covers different losses; I6 only repairs its exit condition.
