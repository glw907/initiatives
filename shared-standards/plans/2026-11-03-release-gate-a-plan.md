# Pass A: gate and product (release gate round, 0.99.0)

Initiative: shared-standards
Spec: /var/home/glw907/Projects/initiatives/shared-standards/specs/2026-11-03-release-gate-and-process-design.md@d880b9e
Class: auth-data
Branch: release-gate-a
Executor: cairn-cms-release-gate-a (sonnet, medium)
Conductor: conductor-cairn-cms
Push target: glw907/cairn-cms

Source cites are at cairn-cms `main` bb3c8d3a2. The spec's section names are cited as "spec, <section>". Pass A has no workstation PR: the inventory and registry rows land at pre-flight (spec, Your steps 3).

## Pre-flight

Pass A depends on spec "Your steps" 2 and 3, plus two session reads. Steps 1 (npm sitting), 4 (environment and rulesets), and 5 (settings grant) serve pass B and `rc.4`; pass A does not wait on them.

| # | Item | Who | Check |
|---|---|---|---|
| PF1 | Spec, Your steps 2: `tmp-token-setup` and `ci-cairn-build`, each received through `secret-receive` as the spec states. | you | `/user/tokens/verify` with `CF_CI_CAIRN_BUILD_TOKEN` answers `active`; `grep -c '^export CF_CI_CAIRN_BUILD_TOKEN=' ~/.local/secrets` prints `1` (name only, never the value); the `grep -c '^export '` count taken before the temporary paste is unchanged by it. |
| PF2 | Spec, Your steps 3: the probe script (PS, P1, the D1 and R2 write probes with `CF_CI_CAIRN_BUILD_TOKEN`, deletions, the Proton Pass item, the inventory and registry rows on workstation `main`). | you, or the planning session if auto mode allows | Every "Done when" clause of spec step 3 holds, and the PS and P1 rows of "Probe readings" below are filled. |
| PF3 | P-SOA (spec, A12 last bullet; Risks P-SOA), moved here because it needs nothing pass A builds: read `GET /zones/<carin-test.org zone id>/dns_settings` with `$CLOUDFLARE_API_TOKEN` (`ws-admin`), then `PATCH` the same route with the read-back `soa` object and `min_ttl: 60`. | planning session, else you (paste the printed `curl`) | The reread shows `soa.min_ttl` 60, or the refusal's code and message are in "Probe readings". A refusal does not hold the launch: A11 covers the setup tool. |
| PF4 | Gate account name for A7: `GET /accounts/120c269ad6d3dfbe6d63a0bb53758ca0` with `$CLOUDFLARE_API_TOKEN`, `.result.name`. | planning session | The name is in "Probe readings". |
| PF5 | Gate stores and rules present, by name: `CF_WS_CAIRN_GATE_TOKEN`, `GITHUB_TEST_LOGIN`, `GITHUB_TEST_PASSWORD`, `GITHUB_TEST_TOKEN`, `GITHUB_TEST_TOTP_SECRET`, `STALWART_PASSWORD_CAIRN_GATE` in `~/.local/secrets`; the allow rule `Bash(bash scripts/gate/run-gate.sh *)` in `~/.claude/settings.json` (line 35 on 2026-11-03); `~/.local/state/cairn-gate/github-session.json` exists. | planning session | `grep -c` per name prints 1; `grep -c 'run-gate.sh' ~/.claude/settings.json` is at least 1; `test -f` on the session file. |
| PF6 | No `cairn-build` registration and no live gate run before launch (spec, A14 step 2, checked early). | planning session | The PF2 probe's final `GET /accounts/<id>/builds/tokens` read lists no name `cairn-build` and no `cairn-e2e-gate-probe-*`; `pgrep -f scripts/gate/gate.mjs` prints nothing. |

### Probe readings (filled at pre-flight; the executor reads them, never re-probes)

- Gate account name (PF4): `<pending>`
- P1, Builds registers a token holding only Workers Scripts, D1, and R2: `<pending: pass | fail + code>`
- D1 and R2 write probes with `CF_CI_CAIRN_BUILD_TOKEN`: `<pending>`
- PS, how a registration shows once its token is deleted (field name and value, or "no signal"): `<pending>`
- PS, Builds accepts two registrations with one name: `<pending: yes | no + code>`
- PS, the registration's fields (names only), and which one orders "newest": `<pending>`
- P-SOA (PF3): `<pending: min_ttl before -> after | refused + code>`

Permissions checked: Read each task's writes and credentials against `~/.claude/settings.json` allow rules and the 22 entries of `~/.local/state/claude-denials.jsonl` (to 2026-11-03). T1 to T7, P1 to P3, S1, and R2 write only inside their own worktree under `.claude/worktrees/`, touch no `.claude/` config, and hold no credential. T5's `gh release view v0.99.0-rc.3` is a read under the maintainer's `gh` login. R1's gate runs go only through `bash scripts/gate/run-gate.sh *` (user allow rule, settings.json:35); the script sources `~/.local/secrets` itself, so the session never reads a value. The two `source ~/.local/secrets; curl` forms (PF3, PF4) run at pre-flight with Geoff present, since a sourced-secret `curl` was refused once (2026-11-01, Twilio). Two contingencies keep that risk mid-run: the uuid delete (standing answer S9) and the out-of-harness mailbox query (S7). On a refusal the executor writes the exact command to STATUS and the conductor carries it as a `[you]` step. Pushes go to `glw907/cairn-cms`, named in the launch prompt. The close's admin smoke uses local `wrangler dev` and a local D1, with no credential.

Reviewed: pending (three-lens plan review)

## Rules for every task

- Base: `<base>` is `git merge-base HEAD origin/main`, taken right after setup. Fast lane after each task or pair merge: the legs `node scripts/checks/gate-tier.mjs --fast --range <base>..HEAD` prints, each through `CAIRN_GATE_LANE=<lane> cairn-run-gate '<leg>'` (cairn-pass "Fast lane"). Implementer subagents run `npm run lane:fast -- --range <base>..HEAD` in their own worktree.
- Pairs go to two `cairn-implementer` subagents with `isolation: "worktree"`, `description: "release-gate-a task <id>"`. Each dispatch carries the task's block below, verbatim, since the implementer never reads this plan. P1 and P2 pass `model: "opus"` (spec, Pass A: "A10 and A11 carry novel correctness logic").
- auth-data tasks (P1, P2, and any product fix in R1 or the close) write the failing test first and commit it with the fix. After the push, `standards:diff-reviewer` (task scope) reads that commit while CI runs; `fix` or `escalate` stops the line like a red.
- The clock file `.pass-task-clock` goes at the pass worktree root at each task or pair start, with the larger estimate for a pair (pass-core "Clock stop").
- No live run of the setup tool's trigger hop outside the gate (spec, Pass A Files). Tests use `packages/create-cairn-site/test/fake-cloudflare*.mjs` and the gate tests' fakes only.
- One literal is the contract between P1 and T7: the build-token prompt text is exactly `Paste your Workers Builds deploy token`. The `--yes` park row is `build-token-missing`, shared by P1 and P3.

## Tasks

### T1. Browser half: publish, URL tail, loopback, headless, failPage (A1, A2, A3, A8)

- Outcome: `publishViaAdmin` publishes without Save and returns the success strip's text. Each URL tail starts at the log's current end. The setup tool's loopback pages count as done, and any other page fails the leg at once with a screenshot and a controls file. The browser runs headless unless `--headed` is passed.
- Files: `scripts/gate/browser.mjs`; `scripts/gate/legs.mjs` (runCli's tail and handleUrl call, :362-378, and the `signedIn` set, :374); `scripts/gate/gate.mjs` (the `notifyDesktop` import, :14 and :414; `makeSession`, :283-321; `USAGE`, :261-262; `--headed` in `main`); `src/tests/unit/gate-browser.test.ts`.
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, Harness items rows A1, A2, A3, A8, as written. Main's code: `browser.mjs:367-378` (Save, then `.alert` `hasText: 'Published'`), `:244-245` (`offset = 0`), `:226-233` and `:155-175` (hold), `:309` (`headless = false`), `:461-465` (`notifyDesktop`). Loopback success bodies: `packages/create-cairn-site/src/github/oauth.mjs:116`, `install.mjs:251`, `manifest.mjs:183`. The admin's sent-link heading is `Check your email` (`src/lib/admin/LoginPage.svelte:116`), and the success strip is `.cairn-feedback` (`EditPage.svelte:1887`).
- Acceptance (each fails on main):
  - Editor fixture: dirty editor; Save posts and reloads to a page showing `Saved. Your site keeps showing the published version until you publish.`; Publish answers 303 to `?published=1`, whose page shows `.cairn-feedback` with `PUBLISHED_ALERT`. `publishViaAdmin` returns `PUBLISHED_ALERT` and the fixture logs no Save request. Main clicks Save and resolves on the Saved alert, whose text contains "published".
  - The same fixture with Publish answering an error alert: `publishViaAdmin` returns that alert's text instead of throwing.
  - Two `tailUrlLog` calls on one file: the second, given the file's size as `from`, handles none of the first's lines. A tail on a deleted file starts at 0. Main replays from offset 0.
  - `github.com/login/oauth/authorize` answering 302 to `http://127.0.0.1:<port>/callback` with the `oauth.mjs:116` body: `handleUrl` resolves within `controlWaitMs` with no failure. Main holds the page for 10 minutes. The loopback bodies come from the setup tool's own strings, imported or copied verbatim.
  - A loopback answering `Not found` or `Forbidden` throws. A confirm that lands on `/admin/login` throws with the page text. A send whose page lacks the heading `Check your email` throws with the alert text.
  - An unrecognised page throws `UnrecognisedPageError` and writes `<leg>-<ts>.png` and `<leg>-<ts>.controls.txt` (one `role<TAB>name` line per button and link, `host + pathname` only). No PNG is written for kind `signin` or for a URL carrying `token=` or `code=`. The controls file holds no input value and no query string. Every handled GitHub page also writes its controls file into the run dir.
  - `launchBrowser` with no `headless` launches headless. `holdPage`, `HoldTimeoutError`, `STEP_MS`, and `notifyDesktop` are gone from the exports, and the test file no longer imports them.
- Test: `src/tests/unit/gate-browser.test.ts` (headless Chromium against route fixtures; heavy lane).
- Estimate: 120 min. Pair partner: P1.

### T2. Driver progress rule and wall clock (A6)

- Outcome: the idle limit re-arms only when the rendered screen changes after stripping spinner glyphs and counters. The hold limit applies only while the last non-blank screen line holds `Watch progress at`. Each driver run has a 90-minute wall clock.
- Files: `scripts/gate/driver.mjs`; `src/tests/unit/gate-driver.test.ts`.
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, Harness items row A6. Main's code: `driver.mjs:170-174` (`armIdle`), `:188` (`holding = false` on answer), `:194-202` (re-arm on every chunk, sticky `holding`), `:20-23` (`HOLD_MARKER`, `HOLD_IDLE_MS`). The wall clock is a driver option with a 90-minute default, so no caller changes.
- Acceptance (each fails on main):
  - A fake CLI printing spinner frames with a ticking counter forever, with a small `idleMs`: the run fails naming "no progress". Main re-arms on every frame and never fails.
  - Spinner frames plus a line that changes every few seconds: no failure inside a window several times `idleMs`.
  - `Watch progress at` printed, then other lines that scroll it off the last line: the next silence fails at `idleMs`, not `holdIdleMs`. Main keeps `holding` until the next answer.
  - A run past a small `wallMs` fails with "the run exceeded its budget".
- Test: `src/tests/unit/gate-driver.test.ts` (node project, light lane).
- Estimate: 60 min. Pair partner: T4.

### T3. Exit codes, captures, the right record, account label, runLeg seam (A4, A7, #336 tests part 1)

- Outcome: a non-zero CLI exit fails the leg with `cliFailureMessage` before the record is read. Each CLI run writes `capture-<leg>-<n>.bin`, and a failed leg marks its run dir so no cleanup deletes its captures. The record is the one whose `dir` is the install's. The account select names the gate account. `runLeg` takes its collaborators through an injected-dependency parameter.
- Files: `scripts/gate/legs.mjs` (`readRecord`, :310-317; `promptTable`, :264; `runLeg`, :346-410); `scripts/gate/gate.mjs` (`GATE_ACCOUNT_NAME` beside `GATE_ACCOUNT_ID`, :25, passed into `promptTable` as an input, since `gate.mjs` imports `legs.mjs`; `teardownRun`'s cleanup list, :324-329; `teardownStale`, :340-349); `src/tests/unit/gate-legs.test.ts`.
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, Harness items rows A4 and A7. Main's code: `legs.mjs:397-405` (exit checked only without an origin), `:387,396` (one `capture.bin`), `gate.mjs:328` (cleanup deletes it). The account name comes from "Probe readings".
- Acceptance (each fails on main):
  - `runLeg` with an injected driver that exits 1 after writing a record with an origin: the verdict fails with `cliFailureMessage` text, and no publish runs. Main publishes and fails on a derived symptom.
  - Two CLI runs in one leg write `capture-<leg>-1.bin` and `capture-<leg>-2.bin`. After a failed leg, the run dir holds `failed`, and `teardownRun` and `teardownStale` delete no capture in it.
  - The replay: an injected driver that appends a URL to `urls.log` on each of two runs. Each URL reaches the injected `handleUrl` once. This needs T1's `from`.
  - A state dir holding another install's record first, plus a `.retired-` file: `readRecord` returns the record whose `dir` equals `install.dir`. Main returns the first `*.json`.
  - `promptTable(...).find(e => e.match === 'Which Cloudflare account')` has `label` equal to the account name, not `''`.
- Test: `src/tests/unit/gate-legs.test.ts`.
- Estimate: 75 min. Pair partner: P2. Depends on T1.

### T4. A row for every leg, run ids, group continuation (A5)

- Outcome: the `## Gate` table gains a `Run` column (the run dir's name). An `--all` run first writes four `pending` rows carrying its run id, and aborts if that write fails. `runLeg` writes its row in a `finally`, with every failure joined by `"; "`. A failed record write is logged, and the leg's own error stands. `main` catches per group, so B runs after A throws, and a leg not run gets `skipped: needs <leg>`.
- Files: `scripts/gate/record.mjs` (`GATE_COLUMNS`, :13; `renderGateSection`, :56-64; `parseRows`, :90-104; a pending-section writer beside `recordLeg`); `scripts/gate/legs.mjs` (`runLeg`'s early returns, :397,404,409, and its row, :468-480); `scripts/gate/gate.mjs` (`main`, :358-436, given a deps parameter for the test); `src/tests/unit/gate-record.test.ts`; `src/tests/unit/gate-legs.test.ts`; `src/tests/unit/gate-main.test.ts` (new).
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, Harness items row A5. Main's code: `gate.mjs:425-429` with `legs.mjs:115-121` (a throw in A skips B), `legs.mjs:478` (`failures[0]` only), `record.mjs:113-119` (earlier rows kept).
- Acceptance (each fails on main):
  - `main` with injected deps whose A1 throws: B1 and B2 run, A1's row reads `fail: <the error>`, and A2's reads `skipped: needs A1`.
  - The three early returns (CLI failure, no origin, no admin session) each write a row. Main writes none.
  - A row with two failures carries both, joined by `"; "`.
  - An injected `recordLeg` that throws inside the `finally`: the leg's verdict and error are unchanged, and the throw is logged.
  - `--all` writes four `pending` rows carrying the run id before A1 starts. An injected failed write makes `main` return non-zero before any leg runs.
  - `renderGateSection` and the parser round-trip eight columns, `Run` included.
- Test: the three files above.
- Estimate: 75 min. Pair partner: T2. Depends on T3.

### T5. The gate table's reader (A17)

- Outcome: `node scripts/gate/verdict.mjs <V> [--file <path>]` exits 0 only on exactly one `pass` row each for A1, A2, B1, and B2, all with one `Run` id. Under `--file`, the one-id rule holds per group (A1 with A2, B1 with B2). `record.mjs` exports its parser as `parseGateRows`, and `verdict.mjs` imports only Node built-ins and `record.mjs`, since pass B's `verdict` job runs it from a sparse checkout with no install (spec, `publish.yml`).
- Files: `scripts/gate/verdict.mjs` (new); `scripts/gate/record.mjs` (export `parseGateRows`); `src/tests/unit/gate-verdict.test.ts` (new); `src/tests/unit/fixtures/gate-pages/release-body-v0.99.0-rc.3.md` (new, captured with `gh release view v0.99.0-rc.3 --json body --jq .body` before R1).
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, Harness items row A17 and "Pass A tests" A17 bullet. Main has no reader, and `parseRows` is private (`record.mjs:90`).
- Acceptance: fixtures built with `renderGateSection`. Each of these exits 1: three passes and a `fail`; a missing row; a `skipped` row; a `pending` row; mixed run ids; a duplicate leg; a row with the wrong cell count; a body with no `## Gate`; a failed `gh` read (injected); and the captured `rc.3` body. Four passes with one run id exit 0. Under `--file`, a record whose groups carry two run ids exits 0, and one whose A1 and A2 differ exits 1. Main fails every case, since no `verdict.mjs` exists.
- Test: `src/tests/unit/gate-verdict.test.ts`.
- Estimate: 60 min. Pair partner: S1. Depends on T4.

### T6. Rehearsal mode, lock, run-dir exit file (A15, A16)

- Outcome: `--cli <absolute .tgz>` runs `npx --yes file:<tgz>` in place of `create-cairn-site@<version>`, and requires `--record-file <path>`. Under `--cli`, `recordLeg` merges each row into that file through `mergeGateSection` and never touches a release body. `run-gate.sh` takes `flock -n` on `~/.local/state/cairn-gate/lock` and refuses while another run holds it, naming the holder's pid. It prints `run dir: <path>` first, and its EXIT trap writes the final status to `<run dir>/exit` after teardown.
- Files: `scripts/gate/run-gate.sh`; `scripts/gate/gate.mjs` (argv parsing and `USAGE`); `scripts/gate/legs.mjs` (`runCli`'s command, :380-383); `scripts/gate/record.mjs` (the file target); `src/tests/unit/gate-env.test.ts`; `src/tests/unit/gate-legs.test.ts`; `src/tests/unit/gate-record.test.ts`.
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, Harness items rows A15 and A16. The `exit` file and the `run dir:` line are this plan's addition, so R1's Monitor has a condition to wait on (see `## Decisions` seed D3). The lock path sits under `$HOME`, so the test sets `HOME` to a temp dir and needs no new setting.
- Acceptance (each fails on main):
  - `--cli /abs/x.tgz --record-file /abs/r.md --version 0.99.0-rc.3`: the injected driver receives `['--yes', 'file:/abs/x.tgz', '--dir', ...]`. `--cli` with a relative path, or with no `--record-file`, returns 2 with `USAGE`.
  - Under `--cli`, a leg's row lands in the record file, and an injected `gh` sees no call. A second run on the same file replaces only its own legs' rows.
  - With the lock held by a test process, `run-gate.sh --smoke` exits non-zero naming that pid, and starts no `gate.mjs`.
  - After a run, `<run dir>/exit` holds the exit status, and stdout's first line is `run dir: <path>`.
- Test: the three test files above.
- Estimate: 75 min. Pair partner: P3. Depends on T5.

### T7. The gate's second token, the registration readout, the gate README (A12 harness half, A13 gate README)

- Outcome: the gate carries `CF_CI_CAIRN_BUILD_TOKEN` and answers the build-token prompt with it. The smoke's D1, R2, and registration probes run with it, and the registration probe uses a `cairn-e2e-gate-probe-*` name, never `cairn-build`. The smoke prints one info line: the count of registrations named `cairn-build`, each one's `build_token_uuid`, and whether its `cloudflare_token_id` equals the build token's verify id. Each Builds leg (A2, B1) logs its trigger's build-token uuid from `listBuildTriggers` before teardown. Teardown still never touches a registration.
- Files: `scripts/gate/run-gate.sh` (allowlist, :26); `scripts/gate/gate.mjs` (redaction, :96; probes, :234-253; the info line); `scripts/gate/legs.mjs` (`promptTable` row and its `buildToken` input; the trigger log in `runLeg`); `scripts/gate/README.md` (headless, `--headed`, `--cli` and `--record-file`, the lock, `failPage`, the second token, the `exit` file; replaces :86's hold paragraph); `src/tests/unit/gate-env.test.ts`; `src/tests/unit/gate-legs.test.ts`.
- Class: runner. Model: sonnet, medium.
- Mechanism: spec, A12 bullets 1-5. The info line is this plan's addition, so R1 can make A14 steps 2 and 5's registration reads through the allowed `run-gate.sh --smoke` instead of a sourced-secret `curl` (seed D4). The smoke FAILs when `CF_CI_CAIRN_BUILD_TOKEN` is absent, since every Builds leg needs it.
- Acceptance (each fails on main):
  - The smoke against the fake server sends the D1, R2, and registration-probe calls with the build token's bearer, and the gate token's calls with the gate token. The probe name starts `cairn-e2e-gate-probe-`. Neither token appears in any printed line.
  - With the fake holding one `cairn-build` entry whose `cloudflare_token_id` matches the build token's verify id, the info line reads count 1, prints the uuid, and reports a match. With none, it reads count 0.
  - A prompt line `Paste your Workers Builds deploy token` selects the build-token entry, and its value is the build token.
  - `run-gate.sh` passes `CF_CI_CAIRN_BUILD_TOKEN` through and nothing else new (the existing allowlist test, extended).
- Test: `src/tests/unit/gate-env.test.ts`, `src/tests/unit/gate-legs.test.ts`.
- Estimate: 65 min. Pair partner: none. Depends on T6.

### P1. The narrow build token (A10, #341)

- Outcome: chapter 3's trigger hop reuses the newest live `cairn-build` registration with no prompt. Otherwise it collects a narrow build token: it opens a second prefilled URL (`workers_scripts`, `d1`, `workers_r2` at edit, token name `cairn-build`) and prompts `Paste your Workers Builds deploy token`, or under `--yes` reads `CAIRN_CF_BUILD_TOKEN`. It verifies the token through `/user/tokens/verify` on a `makeApi` built on it, and registers it as `cairn-build` through the setup-token api. The build token is never written to state. A `--yes` run with no registration and no env var parks on `build-token-missing`. The setup token's chapter-3 key set drops to the six keys of `CHAPTER2_BUILDS_PERMISSION_KEYS`. The CLI never deletes a registration.
- Files: `packages/create-cairn-site/src/cloudflare/prefill.mjs` (:52-87, the new key set and URL, and the env read beside :240-285); `packages/create-cairn-site/src/cloudflare/chapter3.mjs` (header token lifecycle, :17-30; `BUILD_TOKEN_NAME`, :97; `ADMISSION_DETAIL`, :950; the hop, :1368-1390; the `// WATCH:` with the spec's two notes); `packages/create-cairn-site/src/cloudflare/catalogue.mjs` (row `build-token-missing`); `packages/create-cairn-site/src/cloudflare/api.mjs` only if a call the hop needs is missing (`getBuildTokens`, :609; `createBuildToken`, :616; `verifyToken`, :557 exist); their co-located tests `prefill.test.mjs`, `chapter3.test.mjs`, `catalogue.test.mjs`; `packages/create-cairn-site/test/fake-cloudflare.mjs`; `packages/create-cairn-site/test/no-d1-r2-routes.test.mjs` (new source scan).
- Class: auth-data. Model: opus (cairn-implementer, `model: "opus"`). Failing tests first.
- Mechanism: spec, Product items A10, every bullet. The stale-registration branch follows "Probe readings":
  - If PS shows a list signal and duplicates are accepted, a stale entry counts as absent, and the new token registers as `cairn-build`.
  - If PS shows a list signal and duplicates are refused, the new token registers as `cairn-build-<yyyymmdd>`, and reuse takes the newest live entry named `cairn-build` or starting `cairn-build-`.
  - Either way, it prints the one re-point line the spec gives.
  - If PS shows no list signal, no stale detection ships, and the item escalates (standing answer S12).
  - "Newest" orders by the field PS names.
- Acceptance (each fails on main; fake: `test/fake-cloudflare.mjs` and its `requests` log):
  - A `cairn-build` entry exists: no prompt, no `POST .../builds/tokens`. Main matches by token id, not name.
  - Only a wide registration carrying the setup token's id exists: the run still prompts. Main reuses it.
  - The build token is verified through `GET /user/tokens/verify` with the build token's bearer, and `listZones` is never called with it.
  - `--yes` with `CAIRN_CF_BUILD_TOKEN` registers. Without it, the run parks on `build-token-missing`.
  - A token-shaped argv is refused before any call.
  - The state file never holds the build token's value.
  - The prompt text excludes `Paste your Cloudflare API token`.
  - A stale entry leads to a new registration and no `DELETE` in `requests`.
  - `CHAPTER3_PERMISSION_KEYS` deep-equals `CHAPTER2_BUILDS_PERMISSION_KEYS`.
  - The source scan finds no `/d1` or `/r2/` route string under `packages/create-cairn-site/src` outside `*.test.mjs`.
- Test: `npm test -w packages/create-cairn-site` (node, light lane).
- Estimate: 140 min. Pair partner: T1.

### P2. The pinned live check (A11)

- Outcome: when both fetch probes are unreachable and the authoritative AAAA read has the record, the check reads A authoritatively and reruns the marker probe once through `node:https.request`, pinned to that address with SNI and `Host` kept as the domain. A match reports `live`, plus one line saying this machine's resolver may take up to 30 minutes to see the domain.
- Files: `packages/create-cairn-site/src/cloudflare/hostname.mjs` (`diagnoseUnreachable`, :147-163; `confirmWithDiagnosis`, :200-212; the `dns.pinnedProbe` seam); `packages/create-cairn-site/src/cloudflare/hostname.test.mjs`.
- Class: auth-data. Model: opus (cairn-implementer, `model: "opus"`). Failing tests first.
- Mechanism: spec, Product items A11, every bullet. That includes the two-form `lookup` (`opts.all` answers an array), `readAuthoritativeAndRecursive` with `method: 'resolve4'` (`dns.mjs:145`), and no new dependency.
- Acceptance (each fails on main):
  - Both fetch probes unreachable, authoritative AAAA and A present, the injected pinned probe matching: `live`. Main gives `hostname-resolver-lagging`.
  - A pinned mismatch: not `live`.
  - Against a local HTTPS server under a made-up hostname, the real pinned request carries `servername` and `Host` equal to that hostname, and connects to the pinned address with `autoSelectFamily` on.
- Test: `npm test -w packages/create-cairn-site`.
- Estimate: 60 min. Pair partner: T3.

### P3. Setup docs for the second token and the DNS line (A13 product docs)

- Outcome: the four admin pages and the package README describe the second token, its once-per-account reuse, the `build-token-missing` refusal row, and the DNS line. `setup-recovery.md` gains the row for a Builds deploy that fails on a missing permission: edit the token registered as `cairn-build`, since running setup again does not prompt. `MIGRATION-NOTES.md` carries the manual re-point. `CHANGELOG.md` gains `## Unreleased` with the A10 and A11 lines and one `Consumers must:` line in the shape `CONTRIBUTING.md:155` sets. This plan reads it as `nothing.`, since an existing site keeps deploying unchanged and the re-point is optional hardening.
- Files: `docs/admin/own-your-domain.md` (:7, :105-118); `docs/admin/before-you-start.md` (:48-54); `docs/admin/setup-recovery.md` (:61 table); `docs/admin/create-your-site.md` (:117-119 only; never the marked transcript block, #185); `packages/create-cairn-site/README.md` (:326-357 reverse, and the at-rest paragraph); `MIGRATION-NOTES.md`; `CHANGELOG.md`.
- Class: ordinary. Model: sonnet, medium. Load `cairn-writing-docs` and draft from the admin brief in its `references/docs-register.md`.
- Mechanism: spec, Product items A13.
- Acceptance: `npm run check:docs-gate` and Vale pass. `grep -rn 'cairn create-cairn-site build token\|second, wider token\|No second dashboard trip' docs/ packages/create-cairn-site/README.md` returns nothing; main returns README:326,350 and own-your-domain.md:7,105. `MIGRATION-NOTES.md` may name the old registration as the thing to delete. `docs-fact-checker` on the changed lines returns no finding.
- Test: the docs gate (light lane).
- Estimate: 60 min. Pair partner: T6. Depends on P1, P2.

### S1. Showcase spec for the admin publish (A9, optional)

- Outcome: if cheap, one showcase e2e spec drives `publishViaAdmin` from `scripts/gate/browser.mjs` against the real editor and asserts `/test/last-commit` is on `main` and the returned text equals `PUBLISHED_ALERT`. "Cheap" means two things hold: a showcase entry the editor can publish is reachable through `adminPath`, and the showcase Playwright config can import the module with no new server code (`examples/showcase/e2e/golden-path.spec.ts:202,223` shows the commit read). Otherwise S1 writes nothing, and the minimal editor fixture in T1 stays (standing answer S13).
- Files: `examples/showcase/e2e/gate-publish.spec.ts` (new).
- Class: ordinary. Model: sonnet, medium.
- Acceptance: the spec passes on T1's code. Pointed at main's `publishViaAdmin`, it fails, because the commit lands on `cairn/<concept>/<id>`, not `main` (mechanics M1 probe).
- Test: that spec alone, heavy lane.
- Estimate: 30 min. Pair partner: T5. Depends on T1.

### R1. The rehearsal (A14 steps 1-5, rulings 9 and 15)

- Who: the executor session itself, never a subagent. Gate runs need its permissions and its background-task wake-up.
- Outcome: the four legs pass on pass A's packed setup tool against the `rc.3` engine on npm, by spec A14 step 5.
- Files: none committed. Outputs outside the worktree, mode 0700: `~/.local/state/cairn-gate/rehearsal/` holds the tarball and `rehearsal-gate.md`.
- Class: auth-data (the live check of P1 and P2). Model: the executor (sonnet, medium).
- Steps:
  1. In the worktree's `packages/create-cairn-site`, run `node scripts/bake-template.mjs --to template --engine-spec 0.99.0-rc.3 --dev-spec 0.99.0-rc.3`, then `npm pack --ignore-scripts --pack-destination ~/.local/state/cairn-gate/rehearsal` (fold V8).
  2. `bash scripts/gate/run-gate.sh --smoke`. Every check reads `ok`, and the T7 info line reads count 0.
  3. `bash scripts/gate/run-gate.sh --all --version 0.99.0-rc.3 --cli <absolute tgz> --record-file ~/.local/state/cairn-gate/rehearsal/rehearsal-gate.md`, run with `run_in_background: true`. Take the run dir from the output's first line, then arm a Monitor whose command is `until [ -f <run dir>/exit ]; do sleep 60; done`. The background task's exit notification is the primary signal, and the Monitor is the backstop for a lost notification after an API drop. Arm the `/loop` wake-up before the first run if it is not armed.
  4. Judge each failure by spec "The rehearsal's rules" and the standing answers below. Fix in the right files: harness in `scripts/gate/`, product in pass A's product files (test first). After each fix, run the fast lane, commit, push, and re-pack (step 1). Rerun the affected group with `bash scripts/gate/run-gate.sh --leg A1 --leg A2 ...` (or B1 and B2), with the same `--cli` and `--record-file`, in the background as in step 3. Run `bash scripts/gate/run-gate.sh --teardown-stale` first when the previous run printed a `teardown left:` line.
  5. Pass check, all five must hold:
     - `node scripts/gate/verdict.mjs 0.99.0-rc.3 --file ~/.local/state/cairn-gate/rehearsal/rehearsal-gate.md` exits 0.
     - A fresh `--smoke` info line reads count 1 with a token-id match.
     - Every trigger uuid logged in the rehearsal's run dirs equals that entry's uuid.
     - `answered "Paste your Workers Builds deploy token"` appears exactly once across the `driver.log` of every rehearsal run dir, counted from the last uuid delete if S9 took one.
     - The run dirs are listed in the PR body's rehearsal record.
- Acceptance: the step 5 checks. Main fails it, since main has no `--cli`, `--record-file`, `verdict.mjs`, or build-token prompt.
- Estimate: 120 min. Pair partner: none. Depends on every task above except P3 (merged and pushed).

### R2. Captured fixtures, the 7003 allowlist, the trigger field (A14 steps 6-8, A9, #348, #336 residue)

- Outcome: the GitHub fixtures in `gate-browser.test.ts` serve the rehearsal's captured controls files, scrubbed. A test asserts that no `github-*` fixture holds the test login. Teardown allows the 404 codes R1's teardown logs show per route. R1 confirms `build_trigger_uuid` from a captured build record and records it in the PR. Main's code is `chapter3.mjs:911`, and teardown's 7003 rule is `teardown.mjs:126-128`.
- Files: `src/tests/unit/fixtures/gate-pages/github-*.txt` (new); `src/tests/unit/gate-browser.test.ts`; `scripts/gate/teardown.mjs`; `src/tests/unit/gate-teardown.test.ts`.
- Class: runner. Model: sonnet, medium (one cairn-implementer). The dispatch names the absolute run-dir paths from R1, read by path.
- Mechanism: spec, A9 last two sentences, A14 steps 6-8. The scrub replaces the test login, `cairn-e2e-gate-*` names, and any email with placeholders. The allowlist takes only codes the rehearsal logged for a route, each with its logged body in the test.
- Acceptance: on main, the GitHub pages are hand-built (`gate-browser.test.ts:38-86`) and teardown treats every 7003 as a failure. The rebuilt `handleUrl` tests pass against the captured controls. The scrub test fails when a fixture holds the login. A 7003 from a route not on the allowlist still throws.
- Test: `gate-browser.test.ts` (heavy), `gate-teardown.test.ts`.
- Estimate: 40 min. Pair partner: none. Depends on R1. It changes no product file, so no group rerun follows (seed D5).

### C1. Close

See `## Close`. Estimate: 50 min, plus fix rounds of 70 min.

## Path

| Step | Slot 1 | Slot 2 | Counted |
|---|---|---|---|
| Pair 1 | T1 120 | P1 140 (opus) | 140 |
| Pair 2 | T3 75 | P2 60 (opus) | 75 |
| Pair 3 | T4 75 | T2 60 | 75 |
| Pair 4 | T5 60 | S1 30 | 60 |
| Pair 5 | T6 75 | P3 60 | 75 |
| Solo | T7 65 | | 65 |
| Serial tail | R1 120, R2 40, C1 50, fix rounds 70 | | 280 |
| **Path** | | | **770** |

The spec's pass A path is 700 (lane 1 385, lane 2 245, tail 75 + 120 + 50 + 70). This plan's 770 is 10 percent over: A12's harness half and the gate README moved from the product lane into the harness chain, since they edit `run-gate.sh`, `gate.mjs`, and `legs.mjs`, and A14 steps 6-8 are priced as their own task (R2). The sum over every task is 1,030 plus fix rounds, and it sets nothing. The round's ceiling is 1,240 path minutes (ruling 13), and `rc.4` takes 200 of them after both passes, so pass A's own line is 1,040.

## Stops and standing answers

The executor never asks Geoff and never notifies him. It writes a stop to `docs/STATUS.md` on its branch, reaches `conductor-cairn-cms`, and waits. Each stop entry is removed once the stop clears, so the branch ends with no net STATUS change (Close step 7). The conductor applies these answers and brings Geoff only what none covers.

| # | Stop | Standing answer (source) |
|---|---|---|
| S1 | A clock stop: a task or pair passes twice its estimate. | The conductor applies the spend answer (spec, Standing answers "Spend"). With a traced cause inside the line, it names a new `estimate=` and the executor resumes. With no traced cause, it stops for Geoff. |
| S2 | A red fast lane or CI, or `fix` or `escalate` from a task-scope diff-reviewer on an auth-data commit. | Fix forward on a traced cause, and quote each reviewer finding verbatim as the fix's criteria. A cause that returns after its fix gets one structural fix, then escalation in the PR if the item is in S12's list; otherwise it stops. A CI `test` red with no code cause reruns once. |
| S3 | Pass A's path passes 1,040, or the round's 1,240 (ruling 13). | Stop, write STATUS, reach the conductor. No standing answer. |
| S4 | A rehearsal failure (spec, "The rehearsal's rules"). | Expected: none. A harness gap is fixed in the harness, a product defect in pass A's product files (test first), and an environment cause before `rc.4`, recorded. Then rerun the affected group (spec, Standing answers "The rehearsal"). Reruns come out of the fix-round minutes. |
| S5 | A product change after the rehearsal passed, a close-review fix included. | Rerun the group that reaches the changed code before the PR is ready: group A for A11 and the email path, and the group whose Builds leg runs first for A10 (spec, "The rehearsal"). A rerun that must reach A10's collect path takes S9 first. |
| S6 | F2, the email throw on A1 or B2. | If the captured CLI error shows a product defect, fix it in `chapter2.mjs` or `email.mjs` with a failing test first (both join the files for this fix only). If it shows the environment, fix the environment and record it (spec, Standing answers "The email throw"). |
| S7 | B2's mail does not arrive. | Query the gate mailbox outside the harness for mail from `no-reply@carin-test.org` since the request, and read Stalwart's DMARC verdict (spec, "B2 mail does not arrive"). No message means the environment (B-13): fix the gate zone's records, or stop with the traced cause if the fix is on ward. A message found means a harness gap. If auto mode refuses the sourced-secret query, the executor writes the exact command to STATUS, and the conductor runs it or carries it as a `[you]` step. |
| S8 | The narrow token is too narrow at the rehearsal: the Builds log names a missing permission. | Add the key to `BUILD_TOKEN_PERMISSION_KEYS` (P1's files). Geoff adds it to `ci-cairn-build` at a set point that the conductor notifies (spec, "Narrow token too narrow"). |
| S9 | A second live run of the deploy-token prompt is needed. | Read the triggers. If none holds the rehearsal's `cairn-build` registration, delete it by its uuid with `CF_WS_CAIRN_GATE_TOKEN`, never by name, then rerun (spec, "A second live run"). On an auto-mode refusal, the conductor carries the exact command as a `[you]` step. |
| S10 | A Workers Builds outage. | One rerun after 15 minutes (spec). |
| S11 | A headless GitHub challenge (a `failPage` screenshot shows one). | Rerun that group with `--headed`. If headed passes, `rc.4` gates headed, and the gap is listed in the PR body's `## Backlog edits for the cut`, which the conductor files in `BACKLOG.md` at the cut (spec; shared-file rule, Close step 6). |
| S12 | Items the run may escalate without breaking the outcome. | Only three: stale-registration handling (#341 part 3), which ships as "reuse, and the first build fails inside the watch", never as a delete; S1's showcase spec; and the per-route 7003 allowlist (spec, "Items the run may escalate"). Anything else that fails after its structural fix stops. |
| S13 | S1 is not cheap. | Skip it, keep T1's minimal editor fixture, record it in `## Decisions`, and leave it on #336. |
| S14 | Another gate run holds the lock. | Wait for it to exit. Never start a second run (spec). |
| S15 | A write or call auto mode refuses despite the plan's reading. | Skip that step. The conductor's packet carries it as a `[you]` step with the exact command (spec, "A refused settings write", applied to any refusal). |
| S16 | A merge conflict between a pair's two commits. | Pairs are file-disjoint, so a conflict means a task wrote outside its list. Keep each task's own files and revert the stray change. Record it, then run the fast lane. A conflict inside a task's own files stops. |

## Close

1. **Full suite.** CI green on the head commit (`ci-green <sha> --pr <n> --wait`, background, from the pass worktree). List every retried test in the PR body.
2. **Whole-branch review**, in parallel:
   - `standards:diff-reviewer` at whole-branch scope, against the spec at d880b9e and this plan.
   - `standards:web-auth-security-reviewer` on the auth-data paths: `packages/create-cairn-site/src/cloudflare/**`, plus `chapter2.mjs` and `email.mjs` if S6 touched them.
   - The checklist map adds no other reviewer: no `.svelte`, load, action, or hook code; no Worker, D1, or `wrangler.*` code; no markup; no `tool/**`.
   - One batched fix chain follows, each finding quoted verbatim, then the fast lane. A product change reruns its group (S5).
3. **Live admin smoke** per `cairn-running-passes` `references/admin-smoke-test.md`, against the showcase under `wrangler dev`: a D1 session row, then the magic-link round trip read from wrangler's local `send_email` output. The rehearsal's B2 is the deployed counterpart.
4. **Docs dimension.** P3's pages pass the docs gate, Vale, and `docs-fact-checker`. Grep `cairn create-cairn-site build token` across `docs/`, `skills/`, `claude/`, `README.md`, and `packages/`, and repoint every hit except MIGRATION-NOTES' deletion step. `scripts/gate/README.md` is current (T7, plus any R1 fix).
5. **CHANGELOG and MIGRATION-NOTES.** `## Unreleased` and the re-point entry come from P3, with no version bump. Run `npm run check:consumers-must`.
6. **Backlog edits, made by the conductor at the `rc.4` cut, never on this branch.** `BACKLOG.md` items #341 to #349 sit on adjacent lines, so a branch edit here would conflict with pass B. Pass B follows the same rule (the conductor's shared-file rule, 2026-11-03). The PR body carries a `## Backlog edits for the cut` section listing each edit with its proof, and the executor writes no `BACKLOG.md` change and never runs `/standards:log-issue` on the branch. The section holds:
   - The spec's pass A folds ("Backlog verdicts"). #341 moves to `## Done`, naming the PR; if S12 escalated the stale path, the residue is a new item with its text drafted. #348 moves to `## Done`. #336 is reworded per the sweep (drop "run its first live leg"), then cut to what remains: the gone-install-dir case, plus S1 or the 7003 allowlist if either escalated. #349 gets one line saying the `rc.3` rehearsal ran in this PR; pass B's rule closes it.
   - Every "found, not done" item, each drafted in `/standards:log-issue` shape with a `Placement` line, S11's gap among them if it occurred.
   - The sweep's other edits (#330 done, the `swept` stamps, #205's line) belong to pass B's list or the conductor, never this one.
7. **STATUS: no net change on the branch.** Before PR-ready, `git diff origin/main -- docs/STATUS.md` prints nothing: each stop entry was removed when it cleared. The state that STATUS would carry (the PR, the rehearsal's run dirs and verdict, the next action) goes into the PR-ready report to the conductor, which folds it into its hand-over. No release.
8. **PR body.**
   - It opens with `## Brief` per `~/.claude/docs/voice/approval-brief.md`: a headline and lede; `### What changes` (bullets); `### If you approve` (numbered); and `### Worth knowing` (the `cairn-build` registration is account-wide and production-critical; the trigger hop met the collect path live once).
   - Then the technical notes: what landed, task by task; each auth-data verdict (the per-commit diff-reviewer reads, the web-auth read, the admin smoke); and the rehearsal record (the verdict output, the info line, the prompt count, the 7003 codes, the confirmed trigger field).
   - Then `## Decisions`, seeded with D1 to D6 below; `## Planning misses`; and `## Tooling`: each skill, agent, gate, or hook that failed, misled, or was missing, with its fix or backlog number.
   - Then the score: Gates on the critical path, Work and review (plan path 770 beside the actual), CI waits on the path, Fix rounds and reds, Close, and Total, with gate and lock time from `cairn-run-gate --records <toplevel> release-gate-a`.
   - It ends with the attribution line.
9. **Hand-over.** Report PR-ready to `conductor-cairn-cms`. Never run `approval-queue`, never merge, and pass over the approval-queue reminder hook.

### Decisions seeded by this plan

- D1. P-SOA moved to pre-flight (PF3), since it needs nothing pass A builds and its sourced-secret `curl` risks a mid-run refusal. The alternative was to keep it in A12, mid-run.
- D2. The rehearsal's tarball and record live in `~/.local/state/cairn-gate/rehearsal/` (fold V8), outside the worktree and beside the run dirs. The alternative was the session scratchpad, which a restart loses.
- D3. `run-gate.sh` prints `run dir:` and writes `<run dir>/exit`, so R1's Monitor until-loop has a durable condition. The alternative was polling `pgrep`, which cannot tell a clean exit from a crash.
- D4. The smoke prints the `cairn-build` count, uuid, and token-id match, so A14 steps 2 and 5 read through the allowed `run-gate.sh --smoke`. The alternative was a sourced-secret `curl`.
- D5. R2's teardown allowlist lands with unit tests over the logged bodies and no group rerun. The rerun rule covers product files, and the allowlist is an escalatable item (S12).
- D6. `BACKLOG.md` and `docs/STATUS.md` end with no net change on the branch; the conductor makes the backlog edits at the cut from the PR's list. The alternative, editing them here, would conflict with pass B on adjacent lines (the conductor's shared-file rule, 2026-11-03).
