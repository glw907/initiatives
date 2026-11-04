# Release gate and release process for 0.99.0

## Brief

The `0.99.0` release is stuck at its gate: four live runs on `rc.3` never passed, each found one more harness gap, and you stopped live trial and error on 2026-11-03 until a plan found the rest from source. The gate is the harness in `scripts/gate/` that installs real sites with the published setup tool, publishes an edit through each site's admin, and passes only when the edit shows at the live address. A candidate (`rc`) waits on a hidden npm tag until the gate passes, and promotion then moves it to `next`. You asked for a clean, documented, streamlined, idiomatic release process and the Claude infra to support it. A read-only walkthrough of all four legs against the source found why the runs failed: the harness clicked Save instead of Publish, held an auto-approved GitHub sign-in page, ignored the setup tool's exit code, and waited out a 30-minute DNS cache.

Two passes run in parallel, then one candidate. Pass A fixes the gate harness, makes it run without a browser window, narrows the Workers Builds token (#341), and fixes the DNS stall in the setup tool. It ends with one rehearsal: the gate runs pass A's packed setup tool against the `rc.3` engine already on npm, so the harness and the new product code are proven together before anything publishes. Pass B turns the mechanical release steps into `scripts/release/` commands, hardens the publish workflow, makes a breaking change take a minor version, adds the stable-cut hook, and rewrites `cairn-releasing` around the scripts. After both merge, the conductor cuts `rc.4` with the new scripts, gates it once, promotes it, and hands you your real install.

Approving starts one pre-flight sitting for you: an npm terminal session, two Cloudflare tokens made in the dashboard, and a settings grant. The one act that cannot be undone is publishing `rc.4`, since a version number is permanent; a deprecation can be lifted. The review fold raised the plan path from about 620 to about 875 minutes, mostly for the rehearsal's new install mode and the reviewers' safety fixes. The ceiling stays at the 1,240 you approved.

### What changes

- The gate runs headless and never waits for you. An unknown page fails its leg and saves a screenshot and the page's button and link names. Only one gate run can hold the account at a time.
- A new site's Workers Builds deploys use a narrow token (Workers Scripts, D1, R2), registered once per Cloudflare account as `cairn-build` and reused by later sites. Your setup token is no longer handed to Builds. No code ever deletes that registration by name.
- The setup tool's domain check stops waiting out this machine's DNS cache once Cloudflare's own nameservers answer.
- A release is a short run of `node scripts/release/*` commands, and the skill keeps only the judgment calls.
- Publishing runs only from a GitHub release. Promotion refuses a candidate unless its gate table shows four passes from one run. The publish credential reaches only the publish steps, and `v*` tags and `main` cannot be rewritten or deleted.
- A breaking change can no longer ship as a patch.
- A harness-only fix after the final candidate no longer forces a new candidate.
- `rc.1` and `rc.2` are deprecated on all three packages, and the stale `rc` tag goes.

### If you approve

1. You run the pre-flight sitting under "Your steps".
2. The planning session finishes both plans, has them reviewed, and hands them to `conductor-cairn-cms`, which launches both passes.
3. Each pass ends in a PR, and the conductor sends you one packet for both.
4. After both merge, the conductor cuts `rc.4`, gates it once, and promotes it on four passes.
5. You run your real install on `rc.4` (run sheet step 12). The stable still waits on your "install passed".

### Worth knowing

Two consequences come from rulings, not new choices. The changelog date goes on a separate line under each version heading, not in the heading, because the installed `cairn` tool (`tool/v1.1.0`) reads headings with a pattern that allows nothing after the version (`tool/internal/health/check_engine.go:29`). A date in the heading would break its engine check. Also, the gate runs on your main Cloudflare account (ruling 16). The `cairn-build` registration the rehearsal makes is the one every later cairn site on that account reuses, including your install at step 12, which will not ask for a token. So the token is named for that job, `ci-cairn-build`, and the estate inventory marks it production-critical. The deploy-token prompt runs live once, in the rehearsal; after that, unit tests carry it.

### Rulings

All seventeen rulings below are settled, and the spec builds on each one. Source: you, in chat, 2026-11-03, unless a line says otherwise.

1. Two passes in parallel, then one `rc.4` cut with the new release CLI, gated once. Pass A is gate and product (`auth-data`), and pass B is release process and infra (`runner`). Their files are disjoint. Every workflow and release-script change lands before `rc.4`, because `check-stable-source.mjs` allows only version fields between the final candidate and the stable. "You can chose whatever will produce the strongest end result."
2. Stable sign-off is a GitHub environment with no required reviewer, limited to `v*` tags and bound into each package's npm trusted publisher. A PreToolUse hook on `gh release create` refuses a stable unless `check-stable-source.mjs` passes and its sha is the `--target`, and it refuses an `-rc` tag without `--prerelease`. Your 2026-11-02 ruling "Grant the rule" stands, so the session cuts the stable on your word "install passed". "The second is perfect."
3. Rulesets: `v*` tags block update and deletion, and `main` blocks force push and deletion. There is no required status check. "agreed"
4. A breaking change takes a minor version, from these candidates on. "Hopefully we'll release a 1.0 release soon..."
5. No release branch and no canary. "yes"
6. and 7. #341: a narrow build token from a second prefilled link, registered with Builds once per account under a fixed name, and reused with no prompt. The setup token drops D1 and R2 if the setup tool makes no D1 or R2 call with it. A stale registration is detected, and the setup tool asks for a new token. The gate gets one narrow token, minted once at pre-flight. "That works."
8. One npm terminal sitting: deprecate `rc.1` and `rc.2`, remove the `rc` tag (#337), bind the environment, and require 2FA with tokens disallowed. `scripts/release/withdraw` covers a future failed candidate. "That works."
9. #349: after pass A's harness fixes, run the gate once against `rc.3` with the expected failures named in advance. An unexpected failure is a harness gap, fixed before `rc.4`. The run captures GitHub's real labels into the test fixtures (#348). Any later pass that changes `scripts/gate/` ends with such a run. "yes"
10. `scripts/gate/` stays `runner`, with a carve-out: a change that only follows a third-party page lands as a direct change after the fast lane and a dry run, provided `evaluateLeg`, the prompt answers, and teardown are untouched. "yes"
11. Fix the DNS stall in this release. The setup tool reruns its live check pinned to the address the zone's nameservers give, and the gate zone's negative-cache time drops to about 60 seconds if Cloudflare allows it. "agreed."
12. One packet carries the design, both plans, the pre-flight sitting, and the standing answers. "Yes"
13. Ceiling: twice the path, about 1,240 minutes. Inside it, the run fixes forward on any traced cause. Past it, or on a cause it cannot trace, the run stops. "That works."
14. The scope list below is confirmed, with no cuts or additions. "Give the spec the normal review."
15. The rehearsal installs pass A's packed `create-cairn-site` from the worktree, baked against the `rc.3` engine and dev packages already on npm with exact pins, through a new `--cli <tarball>` harness mode, instead of `rc.3`'s published setup tool. One rehearsal proves harness and new product code together before anything publishes, and the expected-failure list shrinks to what remains genuinely expected. "agreed."
16. The gate stays on your main Cloudflare account permanently, with no second account: "I don't _think_ I want a 2nd cloudflare account, only because (presumable) I'd have to pay for a 2nd paid workers plan." `ci-cairn-build` is recorded in the estate inventory as production-critical, since your real sites' Builds deploys will reuse its `cairn-build` registration. Unit tests and one live run in the rehearsal cover the second-token prompt, and a `// WATCH:` at the hop records that the gate cannot re-exercise it. No code ever deletes a registration by its shared name. The stale path registers anew and never deletes, and the Later cleanup of the old wide registration goes by uuid after a read shows no trigger references it.
17. `check-stable-source.mjs` ignores paths that ship in no package, so a harness-only fix after the final candidate does not force a new candidate. `verify` still compares the stable's tarballs with the final candidate's. "Yes"

### Standing answers

The run applies these without stopping. Anything past them stops, writes STATUS, and runs `notify-send -u normal`.

- **Spend.** Inside 1,240 path minutes, a failure with a traced cause gets a fix and the run goes on, each fix listed in the PR's `## Decisions`. A cause that returns after its fix gets one structural fix, then escalation in the PR.
- **Items the run may escalate without breaking the outcome.** Stale-registration handling (#341 part 3), the showcase end-to-end test of the admin publish, and the per-route 7003 allowlist (#336 residue). An escalated stale path ships as "reuse, and the first build fails inside the watch", never as a delete.
- **The rehearsal.** No failure is expected. A harness gap is fixed in the harness, a product defect in pass A's product files, and an environment cause before `rc.4`. Then rerun the affected group, since A2 needs A1 and B2 needs B1 in the same run (`gate.mjs:394`).
- **The email throw (F2) on A1 or B2.** If its captured error shows a product defect, fix it in pass A (`chapter2.mjs` or `email.mjs`). If it shows the environment, fix that before `rc.4` and record it.
- **B2 mail does not arrive.** B2 cannot pass without mail (`legs.mjs:96-101`), so this is never recorded and left. Query the gate mailbox outside the harness for mail from `no-reply@carin-test.org` since the request, and read Stalwart's DMARC verdict for it. If no message arrived, the cause is the environment (B-13): fix it on the gate zone's records before `rc.4`, or stop for you with the traced cause if the fix is on ward. If a message arrived, the miss is a harness gap.
- **Narrow token too narrow.** At pre-flight, when P1 or a write probe fails: you add the key Cloudflare names to `ci-cairn-build` in the same sitting, and the probe repeats. With no key named, stop before launch. At the rehearsal or later: add the key to `BUILD_TOKEN_PERMISSION_KEYS`, and you add it to `ci-cairn-build` at a set point (notify-send). Pasting again cannot fix it, because the registration reuses that token with no prompt. After `rc.4`, the same pair of edits fixes forward to `rc.5`.
- **A second live run of the deploy-token prompt.** If a fix to the collect path needs one, delete the rehearsal's `cairn-build` registration by its uuid, after a trigger read shows no trigger holds it, then rerun. Never delete by name.
- **CI on the cut commit.** If `test` fails, rerun it once. A real red is fixed on `main` before any tag exists.
- **Promotion.** If the trusted publisher refuses a dist-tag change from the environment, `node scripts/gate/verdict.mjs 0.99.0-rc.4` must exit 0 first. Then you run `npm dist-tag add <pkg>@0.99.0-rc.4 next` for each of the three packages, then `npm dist-tag add create-cairn-site@0.99.0-rc.4 latest`.
- **A Workers Builds outage.** One rerun after 15 minutes.
- **A refused settings write despite the grant.** The executor skips that write, and the conductor's packet carries it as a `[you]` step with the exact command.
- **A headless GitHub challenge in the rehearsal.** Rerun that group with `--headed`. If headed passes, `rc.4` gates headed, and the gap goes to `BACKLOG.md`.
- **The old-copy promote check shows the hole** (pre-flight step 4). Record it under P-ENV in the PR's `## Decisions` and go on.
- **Another gate run holds the lock.** Wait for it to exit. Never start a second run.

### Your steps

One sitting before launch. The session runs every step it can while you are present and prints the command for any step auto mode refuses.

1. **[you] npm terminal.** Run `npm login`, then `npm whoami` (expect `glw907`). Then deprecate both older candidates on all three packages:
   ```bash
   for p in @glw907/cairn-cms @glw907/cairn-cms-dev create-cairn-site; do
     for v in 0.99.0-rc.1 0.99.0-rc.2; do
       npm deprecate "$p@$v" "Superseded: this candidate failed its release gate. Install $p@next."
     done
   done
   npm dist-tag rm @glw907/cairn-cms rc
   ```
   In each package's npmjs.com settings, set the trusted publisher's environment to `npm-publish`, tick "Allow npm dist-tag", and set publishing access to "Require two-factor authentication and disallow tokens". This is a web step only: `npm trust github` takes `--env` but has no dist-tag option, and the registry keeps one configuration per package, so recreating one from the CLI drops the dist-tag permission (`npm help trust`, npm 11.20.0). End with `npm logout`. Done when `npm view <pkg>@0.99.0-rc.1 deprecated` prints the message for all six versions, `npm view @glw907/cairn-cms dist-tags --json` has no `rc` key, and each package's settings page shows the environment, the dist-tag box, and the access setting. Until `rc.4` is promoted, `npx create-cairn-site` and `@next` print the deprecation warning.
2. **[you] Two Cloudflare tokens, in the dashboard.**
   - Temporary token. Go to My Profile > API Tokens > Create Token and pick "Create Additional Tokens" at the foot of the list. Add nothing, and set a TTL ending tomorrow (estate inventory, rule 6). Note `grep -c '^export ' ~/.local/secrets`, then paste the token into the dialog the session opens with `secret-receive CF_TMP_TOKEN_SETUP --values /dev/shm/tmp-setup-$(id -u).age --local "$XDG_RUNTIME_DIR/self-hosting/secrets-tmp-setup"`. Pass the flags, never the `VALUES=` and `LOCAL_SECRETS=` variables: `secret-receive` resets `LOCAL_SECRETS` (`~/.local/bin/secret-receive:26`), and `secret-set.sh` would then rebuild `~/.local/secrets` from the scratch store alone. Done when `GET /user/tokens/verify` answers `active` and the `grep -c` count is unchanged.
   - `ci-cairn-build`. Open the narrow prefilled link the session prints from `prefillUrl` (`packages/create-cairn-site/src/cloudflare/prefill.mjs`) over `workers_scripts`, `d1`, and `workers_r2`. Confirm that exactly three rows fill (Workers Scripts, D1, and Workers R2 Storage, each at Edit), since no one has rendered this set before. Rename the token `ci-cairn-build`, set its account to `120c269ad6d3dfbe6d63a0bb53758ca0`, create it, and paste it into `secret-receive CF_CI_CAIRN_BUILD_TOKEN`. Done when `/user/tokens/verify` with it answers `active`.
3. **[you] Probe script**, which the planning session writes and dry-runs. The session runs it instead if auto mode allows (workstation lens: a credential made with your login is a `[you]` item).
   - Probe PS and probe P1 (under Risks). Mint and delete with `CF_TMP_TOKEN_SETUP`, and register and list with `CF_WS_CAIRN_GATE_TOKEN`, which holds Workers CI.
   - Create and delete a D1 database and an R2 bucket with `CF_CI_CAIRN_BUILD_TOKEN`, using the calls in `gate.mjs:229-238`.
   - Delete the PS token and `tmp-token-setup` through the API.
   - Commit the registry and inventory rows straight to workstation `main`, as the ledger records for `ws-cairn-gate`. The `ci-cairn-build` row reads: production-critical, shared by the gate and every cairn site's Builds deploys on the account, never rolled or deleted without re-pointing every trigger that holds its registration. The same commit corrects rule 6's `VALUES=`/`LOCAL_SECRETS=` form to the flag form.
   Done when PS's readings are in the plan, P1 and both write probes pass, and the store lists `CF_CI_CAIRN_BUILD_TOKEN` by name.
4. **[session, else you] GitHub environment, rulesets, and the old-copy check.** If auto mode refuses, you paste the same commands.
   ```bash
   gh api -X PUT repos/glw907/cairn-cms/environments/npm-publish \
     -F 'deployment_branch_policy[protected_branches]=false' -F 'deployment_branch_policy[custom_branch_policies]=true'
   gh api -X POST repos/glw907/cairn-cms/environments/npm-publish/deployment-branch-policies -f name='v*' -f type=tag
   gh api -X POST repos/glw907/cairn-cms/rulesets --input - <<'EOF'
   {"name":"release-tags","target":"tag","enforcement":"active","conditions":{"ref_name":{"include":["refs/tags/v*"],"exclude":[]}},"rules":[{"type":"update"},{"type":"deletion"}]}
   EOF
   gh api -X POST repos/glw907/cairn-cms/rulesets --input - <<'EOF'
   {"name":"main","target":"branch","enforcement":"active","conditions":{"ref_name":{"include":["refs/heads/main"],"exclude":[]}},"rules":[{"type":"non_fast_forward"},{"type":"deletion"}]}
   EOF
   ```
   Then, if `next` on all three packages and `create-cairn-site@latest` name one version `V`, run `gh workflow run publish.yml --ref v0.99.0-rc.3 -f promote=V`. That copy's `promote` sets no `environment:`, so a refusal proves the binding, and a success moves nothing. Skip the check if the tags differ. Done when `gh api repos/glw907/cairn-cms/environments/npm-publish/deployment-branch-policies --jq '.branch_policies[]|[.name,.type]'` prints `["v*","tag"]`, `gh api repos/glw907/cairn-cms/rulesets --jq '.[].name'` lists `pre-agent-first`, `release-tags`, and `main`, and the check's result is in the plan.
5. **[you] Settings grant.** Run the grant script the planning session writes and dry-runs, as `apply-agent-first-grants.sh` was. It adds one `autoMode` line to `~/.dotfiles/claude/.claude/settings.json` and runs `claude-tooling-sync apply`. The line allows pass B's worktree to write the `.claude/` files in pass B's file list: `.claude/settings.json` holding only one PreToolUse hook entry for `gh release create` and the two allow rules in pass B's interfaces, `.claude/hooks/release-cut-guard.mjs`, `.claude/agents/cairn-implementer.md`, and the two skills. Auto mode refused `.claude` writes as self-modification on 2026-11-02 and 2026-11-03 (`claude-denials.jsonl`). Done when `grep -c 'release-gate-and-process' ~/.claude/settings.json` prints `1`. Pass B's close packet carries the line's removal as a `[you]` step.

## Outcome

`0.99.0-rc.4` is on `next` for all three packages and on `create-cairn-site@latest`. Its release body carries a `## Gate` table where A1, A2, B1, and B2 all read `pass` from one run, as judged by `evaluateLeg` (`scripts/gate/legs.mjs:73-105`). It was promoted by the hardened `promote`, whose `verdict` job read that table. Your real install runs on it next. Every mechanical release step is a `scripts/release/` command, and `cairn-releasing` keeps four judgment calls: whether a release is warranted, its size, the notes prose, and failure triage. Initiative: `shared-standards`.

## Pass A: gate and product

Class `auth-data`: `packages/create-cairn-site/src/{github,cloudflare}/**` is `auth-data` (`cairn-running-passes` SKILL.md, risk classes). Executors run on Sonnet at medium in `cairn-implementer`. Items A10 and A11 carry novel correctness logic and upshift to Opus.

**Files.** `scripts/gate/{browser,driver,legs,gate,teardown,record,verdict}.mjs`, `scripts/gate/run-gate.sh`, and `scripts/gate/README.md`. `src/tests/unit/gate-*.test.ts` and new fixtures under `src/tests/unit/fixtures/gate-pages/`. Under `packages/create-cairn-site/`: `src/cloudflare/{prefill,chapter3,hostname,catalogue,api}.mjs`, `chapter2.mjs` and `email.mjs` only per the F2 standing answer, their tests, and `test/fake-cloudflare*.mjs`. `examples/showcase/e2e/` for A9's optional spec. Docs: `docs/admin/{own-your-domain,before-you-start,setup-recovery,create-your-site}.md`, `packages/create-cairn-site/README.md`, `MIGRATION-NOTES.md`, and `CHANGELOG.md` (`## Unreleased` only). Pass A's plan forbids live runs of the new trigger hop outside the gate.

### Harness items

| # | Finding | Mechanism at main | Change |
|---|---|---|---|
| A1 | M1, F5, B-14 | `publishViaAdmin` clicks Save if enabled, then Publish, then waits on `.alert` with `hasText: 'Published'` (`browser.mjs:371-378`). The Save flash "...the published version..." matches that string. Publish is enabled while the editor is dirty (`EditPage.svelte:301`). A publish redirects 303 to `?published=1` (`content-routes-entry-write.ts:456`). | Drop the Save click. Wait until `input[name="body"]` holds the marker, then run `Promise.all([page.waitForURL(/[?&]published=1/), publish.click()])` and read `.cairn-feedback`. On a URL timeout, return the visible `.alert` text instead of throwing. `evaluateLeg` keeps its exact comparison (`legs.mjs:87`). |
| A2 | M2 | `tailUrlLog` starts at `offset = 0` (`browser.mjs:245`). Every `runCli` of a leg tails the one shared `urls.log` (`legs.mjs:351,362`). Group A's clean teardown deletes `urls.log` (`gate.mjs:328`). | `tailUrlLog(file, onUrl, { from })`. Each `runCli` passes the file's current size, or 0 when the file is absent. |
| A3 | B-1, B-2, F6, M3, B-8, B-10 | Authorize waits for a button, then holds (`browser.mjs:226-233`). The setup tool's three loopback success bodies end "Return to the terminal." (`github/oauth.mjs:116`, `github/install.mjs:251`, `github/manifest.mjs:183`). Its error bodies are `Forbidden` (`loopback-core.mjs:68`) and `Not found` (`loopback-core.mjs:91`, `github/loopback.mjs:67`). `signedIn` is set after the click whatever happened (`legs.mjs:374`). `requestSignInLink` reads no result (`browser.mjs:390-400`). | Add `onLoopback(page)`: the page is `http:` on `127.0.0.1`, the path is `/callback` or `/manifest`, and the trimmed body ends "Return to the terminal.". Every GitHub kind is done when it holds. Authorize clicks only when GitHub shows consent, then waits for the loopback. Any other loopback page fails the leg. After the confirm click, require the path `/admin`, or fail with the page text. After the send, require the heading "Check your email", or fail with the alert text. Never log a URL carrying `code=`. |
| A4 | F1, M4, B-5, F14 | A non-zero exit is checked only when the record has no origin (`legs.mjs:397-405`). One `capture.bin` collects every CLI run of the run, and a clean teardown deletes it whatever the legs did (`gate.mjs:328`, `teardown.mjs:220`); the next `--all` deletes it again through `teardownStale`. | When `cli.code !== 0`, fail the leg with `cliFailureMessage` before reading the record. Each CLI run writes `capture-<leg>-<n>.bin`. A failed leg writes a `failed` marker in the run dir, and neither cleanup nor `teardownStale` deletes captures in a marked dir. |
| A5 | M5, integrity 5 | Early returns skip `recordLeg` (`legs.mjs:397,404,409`). A throw in group A skips group B (`gate.mjs:425-429` with `legs.mjs:115-121`). The verdict cell keeps `failures[0]` (`legs.mjs:478`). `mergeGateSection` keeps every earlier leg's row (`record.mjs:113-119`), so a stale `pass` can survive a failed rerun. | `GATE_COLUMNS` gains `Run`, the run dir's name. An `--all` run first writes a fresh `## Gate` section of four `pending` rows with its run id, and aborts if that write fails. `runLeg` writes its row in a `finally`, with `fail: <reasons joined by "; ">`; a `recordLeg` throw there is caught and logged, and the leg's own error stands. `main` catches per group, so B runs after A throws. A leg not run gets `skipped: needs <leg>`. |
| A6 | M6, F8 | Any stdout chunk re-arms the idle timer (`driver.mjs:194-199`). A chunk holding `Watch progress at` sets a sticky `holding` flag, which allows 45 minutes until the next answer (`driver.mjs:20-23,172,188,198`). The settle timer resets on every chunk (`driver.mjs:200-201`), and clack's spinner writes faster than it settles. | Progress means a change in `stripVolatile(screen())`, which removes spinner glyphs and elapsed counters, compared on a fixed 1-second interval independent of the settle timer. The hold limit (`HOLD_IDLE_MS`) applies only while the last non-blank screen line holds the marker. Each `runCli` gets one wall clock (90 minutes) that fails with "the run exceeded its budget". |
| A7 | M13, B-7, F10 | `readRecord` returns the first `*.json` in the shared state dir (`legs.mjs:310-317`). The account select uses `label: ''`, which matches any option (`legs.mjs:264`). | Pick the record whose `dir === install.dir`, and skip `.retired-` files. Set `label` to the gate account's name (a constant beside `GATE_ACCOUNT_ID`, read once from `GET /accounts/<id>`). |
| A8 | M7 | `launchBrowser` defaults `headless = false` (`browser.mjs:309`). `makeSession` passes nothing (`gate.mjs:294`). An unknown page is held for 10 minutes and sends a notification (`browser.mjs:155-175,233`). | Default `headless = true`. `makeSession(env, { headed })` reads `--headed` from argv, which `run-gate.sh` passes on (`run-gate.sh:44`). `failPage` replaces `holdPage`: it writes `<leg>-<ts>.png`, except on a sign-in page or a URL carrying `token=` or `code=`. It also writes `<leg>-<ts>.controls.txt` with one `role<TAB>name` line per button and link, from `page.evaluate`, with no input values, no query string, and no `ariaSnapshot`. Then it throws `UnrecognisedPageError`. Remove `holdPage`, `HoldTimeoutError`, `STEP_MS`, `notifyDesktop`, and their plumbing. Every handled GitHub page also writes its controls file into the run dir, which feeds #348. Update `USAGE` (`gate.mjs:261-262`) and `README.md`. |
| A9 | #336 (reworded), #348 | The fixtures are hand-built (`gate-browser.test.ts:38-86`). The invented admin editor has no `busy`, no reload, and no Saved flash. `runLeg` and `main` have no test. | Tests, each failing on main's code: see "Pass A tests" below. After the rehearsal, the GitHub fixtures are rebuilt from the captured controls files, after a scrub that replaces the test login, `cairn-e2e-gate-*` names, and any email with placeholders; a test asserts no fixture holds the login. Keep a minimal admin-editor fixture (a dirty editor, Publish answering 303 to `?published=1`, `.cairn-feedback` holding `PUBLISHED_ALERT`) until a showcase spec replaces it. If cheap (the showcase's `/test/last-commit`, `examples/showcase/e2e/golden-path.spec.ts:202,223`, needs no new server code), add one showcase spec that drives `publishViaAdmin` and asserts the commit is on `main`. |
| A15 | ruling 15 | `runCli` runs `npx --yes --prefer-online create-cairn-site@<version>` (`legs.mjs:357`). | `--cli <absolute tgz>` runs `npx --yes file:<tgz>` instead. A bare path fails, since npx runs it as a command; the `file:` form and `--package <tgz> -- create-cairn-site` both run the bin (local probe, npm 11.20.0). `--version` still names the release whose body takes the rows, and the marker. `run-gate.sh` passes the flag on. |
| A16 | integrity 6 | Nothing stops two runs. `--all` tears down every other run dir (`gate.mjs:340-349,378`), including a live run's installs. | `run-gate.sh` takes `flock -n` on `~/.local/state/cairn-gate/lock` and refuses, naming the holder's pid. |
| A17 | contract 8, integrity 5 | No reader of the table exists; `parseRows` is private (`record.mjs:88-106`). | `scripts/gate/verdict.mjs <V>` reads `gh release view v<V> --json body` and parses with `record.mjs`'s parser, exported as `parseGateRows`. It exits 0 only when exactly one row each for A1, A2, B1, and B2 reads `pass`, and all four carry one `Run` id. Pass B's `verdict` job and `status` run it. Owning the writer and the reader in one pass keeps one parser. |

**Pass A tests.** Each names the fixture and fails on main's code.

- A1: the editor fixture above passes with Publish alone and fails on a Saved flash.
- A2: a second tail on one file re-handles no earlier line; a tail after the file is deleted starts at 0.
- A3: a 302 from `github.com/login/oauth/authorize` to a loopback serving the `oauth.mjs:116` body passes. Loopback bodies come from the setup tool's own strings. `Not found` or `Forbidden` fails the leg. A confirm landing on `/admin/login` fails. A send without "Check your email" fails.
- A5: `main` runs group B after A throws; a leg not run gets its `skipped` row; a failed record write keeps the leg's error.
- A6: spinner frames with a ticking counter forever fail with "no progress". Spinner frames plus a line that changes every few seconds do not. The hold limit drops once the marker line scrolls off.
- A7: the record is chosen by `dir`, and a `.retired-` file is skipped.
- A8: no screenshot on a `token=` or `code=` URL or a sign-in page; no input value or query string in `controls.txt`.
- `runLeg`, through an injected-dependency parameter: exit 1 with an origin, a throw in the publish, and the replay each yield a row naming the cause.
- A17: fixtures come from `renderGateSection`. Each of these exits 1: three passes and a `fail`, a missing row, a `skipped` row, a `pending` row, mixed run ids, a duplicate leg, a row with the wrong cell count, a body with no `## Gate`, and a failed `gh` read. The rehearsal's real `rc.3` body must exit 1 too.

**Where the walkthrough files disagreed, settled from source.**

- F5 keeps an alert regex. M1 waits for `?published=1`, which is right, since the redirect is the success signal (`content-routes-entry-write.ts:456`).
- F6 accepts any `127.0.0.1` page. B-1 requires the path and the success text, which is right, since the loopback also serves `Not found` and `Forbidden`.
- `common.md` lists A1's missing not-connected sentence as unknown. F3 settles it: the setup tool exited 1 before the Builds prompt (`run4/driver.log` 03:47:09). The sentence is in `publishLine` (`bin.mjs:106-114`).
- `sweep.md` calls B1 and B2 `--yes` legs. The driver never passes `--yes` to the setup tool (`driver.mjs:2`, and `legs.mjs:382`, where `--yes` is npx's flag), and the TTY build watch is held, so the gate does not meet #339.

### Product items

**A10. #341, the narrow build token.** At main, the trigger hop registers the setup token itself, and reuses any registration whose `cloudflare_token_id` matches the setup token (`chapter3.mjs:1377-1389`, `BUILD_TOKEN_NAME` at `:97`). The hop is skipped when a trigger exists (`:1369-1375`).

- `prefill.mjs` adds `BUILD_TOKEN_PERMISSION_KEYS = [{workers_scripts, edit}, {d1, edit}, {workers_r2, edit}]` and a prefill URL with the token name `cairn-build`. Each key has filled its row before (`workers_scripts` in `PREFILL_PERMISSION_KEYS`, `prefill.mjs:44-50`; `d1` and `workers_r2` at `:52-57`). This three-key set without zone keys first renders at pre-flight step 2. `CHAPTER3_PERMISSION_KEYS` becomes the six keys of `CHAPTER2_BUILDS_PERMISSION_KEYS` (`prefill.mjs:87`). The setup tool's source makes no D1 or R2 API call (no `/d1` or `/r2/` route in `packages/create-cairn-site/src`, tests excluded), and chapter 3 runs no wrangler with the token: its only wrangler string is the trigger's deploy command (`chapter3.mjs:94`).
- Trigger hop: `getBuildTokens()` (`api.mjs:609-611`). Reuse by name only: the newest live entry named `cairn-build`, with no prompt. The match by token id goes. Otherwise collect the build token: open the second prefilled URL, prompt "Paste your Workers Builds deploy token", or under `--yes` read `CAIRN_CF_BUILD_TOKEN` with the same argv guard as `CAIRN_CF_API_TOKEN` (`prefill.mjs:255-282`). Verify it with `GET /user/tokens/verify` through a `makeApi` built on the build token, never `listZones`, since a narrow token has no zone read (`prefill.mjs:156-168`). Then register `{ name: 'cairn-build', secret, cloudflareTokenId }` through the setup-token api (`api.mjs:616-624`). The build token is never written to state. A `--yes` run with no registration and no env var parks with a new catalogue row.
- The new prompt text must not contain "Paste your Cloudflare API token". The driver takes the first table entry the line includes (`driver.mjs:180`).
- Stale registration (ruling 16): the CLI never deletes a registration. If probe PS shows a list signal, the hop treats a stale entry as absent, collects a new token, and registers it as `cairn-build`. If PS shows Builds refuses a duplicate name, it registers `cairn-build-<yyyymmdd>`, and reuse takes the newest live entry whose name is `cairn-build` or starts with `cairn-build-`. It prints one line: other sites on the account still point at the dead token, with the manual re-point from `MIGRATION-NOTES.md`. If PS shows no list signal, the first build fails inside the existing watch, and the item may escalate.
- Rewrite `ADMISSION_DETAIL` (`chapter3.mjs:950`) and the module header's token lifecycle. Leave a `// WATCH:` at the hop with two notes. First, switch to an account-owned token once Builds accepts one ("Account-scoped tokens are not supported", Builds API reference, cited in the estate inventory row for `ws-cairn-gate`). Second, the gate meets the collect path live only once, in the `rc.4` rehearsal, so unit tests carry it from then on.
- Existing connected sites keep their wide token, since the hop is skipped. `MIGRATION-NOTES.md` gives the manual re-point: create the narrow token, select it under Worker > Settings > Builds > API token, then delete the old one.
- Tests against `test/fake-cloudflare*.mjs`, each failing on main's code. A `cairn-build` entry exists: no prompt and no create call. Only a wide registration with the setup token's id exists: the run still prompts. The build token is verified through `/user/tokens/verify`, never `listZones`. `--yes` with `CAIRN_CF_BUILD_TOKEN` registers, and without it parks on the new row. A token-shaped argv is refused. The state file never holds the secret. The prompt text excludes "Paste your Cloudflare API token". A stale entry leads to a new registration and no delete call. A source-scan test finds no `/d1` or `/r2/` route under `src` outside tests, which guards the six-key setup token.

**A11. DNS pinned check.** `confirmWithDiagnosis` probes through global `fetch` (`hostname.mjs:200-212`). When both probes are unreachable, `diagnoseUnreachable` reads AAAA authoritatively and reports `hostname-resolver-lagging` (`hostname.mjs:147-163`). The recursive half is pinned to `1.1.1.1` and `8.8.8.8` (`dns.mjs:21`), not to the host resolver `fetch` uses.

- When the authoritative read has the record, read A authoritatively too (`readAuthoritativeAndRecursive` with `method: 'resolve4'`, `dns.mjs:145`). Rerun the marker probe once through `node:https.request`, with a `lookup` that answers both call forms: `opts.all ? cb(null, [{ address, family: 4 }]) : cb(null, address, 4)`. Node sets `all: true` when `autoSelectFamily` is on, and a plain answer then fails with `ERR_INVALID_IP_ADDRESS` (local probe, Node v26.13.0). SNI and Host stay the domain, and no dependency is added. The pinned request is an injected seam (`dns.pinnedProbe`), since `node:https` bypasses the `fetchImpl` seam.
- A match reports `live`, plus one line saying this machine's resolver may take up to 30 minutes to see the domain. The marker stays the authority.
- Tests: both fetch probes unreachable, authoritative AAAA and A present, and the pinned probe matching gives `live` (main gives `hostname-resolver-lagging`). A mismatch gives not `live`. Against a local server under a made-up hostname, the request carries `servername` and `Host` equal to the domain.

**A12. The gate's second token and zone.**

- Add `CF_CI_CAIRN_BUILD_TOKEN` to the allowlist regex (`run-gate.sh:26`) and to the smoke's redaction list (`gate.mjs:96`).
- Add a `promptTable` row, `{ match: 'Paste your Workers Builds deploy token', kind: 'password', value: () => buildToken }`.
- The smoke's registration probe registers the build token under its `cairn-e2e-gate-probe-*` name, never `cairn-build`, verified through `/user/tokens/verify` with the build token (`gate.mjs:245-253`). The smoke's D1 and R2 write probes (`gate.mjs:229-238`) also run with the build token.
- Before teardown, each Builds leg logs its trigger's build token uuid from `listBuildTriggers` (`api.mjs:583`); the rehearsal confirms the field name.
- Teardown still never touches build-token registrations (`scripts/gate/README.md:95`).
- With `$CLOUDFLARE_API_TOKEN` (`ws-admin`), read `GET /zones/<carin-test.org>/dns_settings`, then lower the SOA negative-cache minimum to 60 seconds if the API accepts it (probe P-SOA).

**A13. Docs.** Edit `own-your-domain.md`, `before-you-start.md`, `setup-recovery.md`, and `create-your-site.md` (lines 117-119 describe the Builds offer) for the second token, its once-per-account reuse, the new refusal row, and the DNS line. `setup-recovery.md` gains a row: a Builds deploy that fails on a missing permission is fixed by editing the token registered as `cairn-build`, since running setup again does not prompt. Edit the create-cairn-site README: lines 326-357 ("No second dashboard trip", "The coupling") reverse, and the at-rest paragraph changes. Add the `MIGRATION-NOTES.md` entry and `CHANGELOG.md` `## Unreleased` lines through the `cairn-writing-docs` skill. Update `scripts/gate/README.md` for headless, `--headed`, `--cli`, the lock, `failPage`, and the second token.

**A14. The rehearsal (rulings 9 and 15), last.** The session runs each gate run with `run_in_background`, which re-invokes it when the command exits, since a four-leg run takes 60-110 minutes or more and a foreground call caps at 10. It arms the unattended-work guards.

1. In the worktree's `packages/create-cairn-site`, run `node scripts/bake-template.mjs --to template --engine-spec 0.99.0-rc.3 --dev-spec 0.99.0-rc.3`, then `npm pack --ignore-scripts`, the two commands `publish.yml:209-210` runs. The pins are exact because `^0.99.0-rc.3` also matches a later candidate (semver probe: `satisfies('0.99.0-rc.4', '^0.99.0-rc.3')` is true).
2. Read `GET /accounts/<id>/builds/tokens` and require no entry named `cairn-build`.
3. Run `bash scripts/gate/run-gate.sh --smoke`, then `bash scripts/gate/run-gate.sh --all --version 0.99.0-rc.3 --cli <absolute tgz>`. The user allow rule `Bash(bash scripts/gate/run-gate.sh *)` covers both.
4. Judge each failure by "The rehearsal's rules" below.
5. After the passing run, assert all four. Exactly one `cairn-build` entry exists. Its `cloudflare_token_id` equals the verify id of `CF_CI_CAIRN_BUILD_TOKEN`. Every logged trigger used its uuid. `driver.log` shows `answered "Paste your Workers Builds deploy token"` exactly once across the run.
6. Copy the scrubbed controls files into the fixtures (A9).
7. Read the teardown log's 404 codes per route to set the 7003 allowlist (`teardown.mjs:125-128`).
8. Confirm `build_trigger_uuid` from a captured build record (`chapter3.mjs:911`, #336 residue).

**Leaves out.** M11 (`record.mjs` `--repo` and a non-fatal record write), M12 (scrubbing `token=` from failure text), B-9, B-11, B-15, B-16, and B-17. All are in `## Later`.

## Pass B: release process and infra

Class `runner` (`cairn-running-passes`: `scripts/checks/**`, `.github/workflows/**`, plus skills and agents per `pass-core`). This pass adds `scripts/release/**` to the `runner` path map. Executors run on Sonnet at medium.

**Files.** `scripts/release/{preflight,bump,wait,status,notes,verify,withdraw}.mjs`, with tests in `src/tests/unit/release-*.test.ts`. `scripts/checks/{check-version,check-stable-source,close-prebuilt}.mjs` and their tests. `.github/workflows/publish.yml` and `src/tests/unit/workflow-yaml.test.ts`, which asserts the npm pin, the bare-dispatch `if`, and promote's shape (`:229-262`). `.claude/settings.json`, `.claude/hooks/release-cut-guard.mjs` and its test, `.claude/skills/{cairn-releasing,cairn-running-passes}/**`, `.claude/agents/cairn-implementer.md`, and `ROADMAP.md:176`. A second PR in `~/.dotfiles` holds only what the guard probe places there. Pass B writes no `CHANGELOG.md` line. The conductor adds pass B's consumer-visible lines when it folds the window at the cut, which keeps the two passes' files disjoint.

**Release scripts.** Each is `node scripts/release/<name>.mjs <version> [flags]`, exits 0 or 1, and ends with one `Next:` line. The core of each is a pure function over a command runner, the pattern `check-stable-source.mjs:31,95` already uses.

| Script | Does | Source |
|---|---|---|
| `preflight` | Clean tree. `HEAD == origin/main`, and prints that sha. Version absent from `npm view <pkg> versions` on all three. Both installs present: root `node_modules/.bin/svelte-package` and `examples/showcase/node_modules` (#346). A non-empty `## Unreleased`, which `--stable` skips. | #346, research row 11 |
| `bump` | Writes the eight files `check-stable-source.mjs:43-67` allows: three manifest versions, the lockfile version lines, the template pins and `VERSION` through `npm run emit:template`, the CHANGELOG heading renamed in place with a `Released YYYY-MM-DD.` line under it, and the MIGRATION-NOTES heading plus its `(./CHANGELOG.md#<slug>)` anchors. Renaming follows the `rc.3` cut (`4644cd35b`). It computes every file in memory and checks the results before writing, refuses a dirty tree (naming `git restore`), and is a no-op on a tree already at the version. It refuses while `## Unreleased` sits above a heading on the same numeric core, because folding that window is the cut's judgment call. A test bumps a fixture repo at `rc.4` to `0.99.0`, and `checkStableSource` with a fake runner returns `ok`. | #345 |
| `wait` | Polls `https://registry.npmjs.org/<pkg>` with no cache until `dist-tags[<tag>]` equals the version on all three, for up to 10 minutes. On timeout it names each package and what its tag holds. | #347 |
| `status` | Prints a JSON checklist: the tag on origin, the release and its prerelease flag, dist-tags by stage, `dist.attestations.provenance` on all three, and the CHANGELOG heading. For a prerelease it adds `node scripts/gate/verdict.mjs`; for a stable it checks `latest` instead. Exits non-zero until complete. | research row 4, contract 12 |
| `notes` | Writes the notes file: the version's CHANGELOG section plus every `Consumers must:` line other than `nothing.` (`LINE`, `check-consumers-must.mjs:22`). The session writes the summary paragraph. | research row 15 |
| `verify` | Checks dist-tags and provenance on all three. For a stable, it fetches each package's tarballs for the final candidate and the stable, diffs each file, and applies `check-stable-source`'s exported line rules by file kind: manifest and lockfile `version` lines, template pins and `VERSION`, the CHANGELOG heading and `Released` line, the MIGRATION-NOTES heading and anchor rule, and `guidance-hashes.json` through `build-guidance-hashes --check` on the stable tree. Any other differing line fails. Tests: the real `rc.2` and `rc.3` tarballs fail, and a synthetic pair passes. | research rows 5, 14 |
| `withdraw` | Prints the `npm deprecate` and `npm dist-tag` commands for a failed candidate (ruling 8). For a promoted candidate it also prints the dist-tag moves back to the values `promote` logged before moving. For a half-published candidate it deprecates the published half. If probe P-DEP shows OIDC can deprecate, it dispatches a `withdraw` input that runs them in the environment instead. | research row 1 |

**`publish.yml`.** Today `id-token: write` is workflow-wide (`publish.yml:25-27`), the publish jobs also run on a bare dispatch (`:31`), each publish job runs `npm ci`, which runs `prepare` and `npm run package` (`package.json` scripts), a tag on a commit whose `package.json` holds an already-published version skips green (`:78-86`), actions are on tags (`:35-36`), npm floats (`npm@^11.21.0`, `:46`), and `promote` checks only that the version exists (`:245-250`). The new shape:

- Top-level `permissions: contents: read`. No job holds `id-token` except those that publish or tag.
- The publish jobs run only on `release: published`. The bare-dispatch path and its test go, which closes publishing a stable with a pushed tag and a dispatch, around the hook. Recovery is `gh run rerun <id> --failed`, as the 0.95.0 split recovered (`:72-75`).
- `ci-green` runs before the publish jobs. It polls `GET /repos/{repo}/commits/{sha}/check-runs` until `test` completes, plus `e2e` for a stable, and fails unless each concluded `success`, within 45 minutes (`e2e.yml:20` caps its job at 25). It needs `checks: read`, which the pass confirms against GitHub's REST reference. Both check names exist on `4644cd35b` (read with `gh api` on 2026-11-03).
- `build` has no `id-token` and needs `ci-green`. It fails unless `GITHUB_REF_NAME` is `v` plus the version in each of the three manifests. It runs bounded `npm ci`, then `npm run check:package`, then `npm pack --ignore-scripts` at the root and in `packages/cairn-cms-dev`. It runs the create-cairn-site bake and pack exactly as `:209-210`, then uploads the three tarballs as one artifact.
- `publish`, `publish-dev`, and `publish-create-site` each set `environment: npm-publish` and `id-token: write`, and each needs `build`. They download the artifact and run `npm publish <tgz> --ignore-scripts --access public --tag "$TAG" --provenance`. They keep the already-published guards and the `create-cairn-site` version guard (`:179-205`).
- `verdict` has no `id-token`. It runs on dispatch, with `GH_TOKEN: ${{ github.token }}`, a sparse checkout of `scripts/gate/verdict.mjs` and `scripts/gate/record.mjs` (both import only Node built-ins, `record.mjs:5-8`), and no install. It checks `GITHUB_REF_NAME == v$PROMOTE_VERSION`, then runs `verdict.mjs`.
- `promote` needs `verdict`, sets `environment: npm-publish` and `id-token: write`, prints each package's dist-tags before moving them, and keeps its body (`:234-254`). It is dispatched on the tag ref: `gh workflow run publish.yml --ref v<V> -f promote=<V>`.
- The environment admits every `v*` ref, `v0.99.0-rc.1` through `rc.3` included. Those copies' `promote` sets no `environment:` (`:225-230`), so their OIDC token carries no environment claim, and the trusted publisher refuses them only if npm checks that claim on a dist-tag change (P-ENV, tested at pre-flight step 4). The environment does not guard a new tag, which runs the `publish.yml` its own commit holds. Release-only publishing and the hook cover that.
- Every `uses:` is pinned by commit sha, resolved with `gh api repos/<action>/git/ref/tags/<tag>`. npm is pinned to `npm@11.21.1`, the newest 11.x (`npm view`, 2026-11-03). The npm 12 WATCH stays (#205 fold).

**Checks.**

- `check-version.mjs`: in the `bump === 'patch'` branch (`:204-211`), fail when the entry body has a `Consumers must:` line other than `nothing.`. The `## Unreleased` simulation calls `checkVersion` (`:129-130`), but with a prerelease on top it compares the core, a minor over `0.98.0` (`:113-120`), so the rule bites only once a stable heads the CHANGELOG. Its test puts a stable on top, so main's code returns `ok`, and adds an rc row, `0.99.1-rc.1` over `0.99.0` with a breaking line, which must fail.
- Rewrite `RULE` (`:13`), which points at a README "Status" section that does not exist.
- `cairn-releasing` step 4 and `ROADMAP.md:176` carry the new rule.
- `check-stable-source.mjs`: export `RULES`. The CHANGELOG predicate (`:50`) also accepts `^Released \d{4}-\d{2}-\d{2}\.$`. Under ruling 17, a changed path in the ignore set skips every check, status included. The set is `scripts/gate/**`, `src/tests/**`, `packages/*/test/**`, and `examples/showcase/e2e/**`. The `files` field alone cannot define it: the root lists `dist`, not `src/lib` (`package.json` `files`), and create-cairn-site bakes `examples/showcase`, `skills/`, and `claude/` at pack time (`bake-template.mjs`). So a test derives the shipped inputs: each package's `files`, `src/lib/**` and `packages/cairn-cms-dev/src/**` behind `dist`, and the bake's inputs less `.cairn-template.json`'s exclusions. It fails if any ignored path falls inside them.
- `close-prebuilt.mjs`: before building, check the two install paths and exit with the exact `npm ci` commands (#346). `preflight` imports the same check.

**Claude infra**, through `claude-infra`, each change citing its page:

- **Hook** (`.claude/hooks/release-cut-guard.mjs`, a project-scope PreToolUse entry on `Bash`). The hooks reference is <https://code.claude.com/docs/en/hooks>: a deny is `hookSpecificOutput.permissionDecision: "deny"` with a reason. For a command holding `gh release create`:
  - A tag that is not a literal argument, such as `"$TAG"`, is denied.
  - `^v\d+\.\d+\.\d+-` without `--prerelease` is denied.
  - `^v\d+\.\d+\.\d+$` with no `--target` is denied. Otherwise the hook runs `node scripts/checks/check-stable-source.mjs` in the hook input's `cwd` and denies unless it exits 0 and `--target` equals its `sha:` line (`check-stable-source.mjs:158`). The hooks page: `cwd` "is the worktree root after Claude enters a worktree", while `${CLAUDE_PROJECT_DIR}` "stays put".
  - Any other literal tag gets no decision.
  - Tests feed hook JSON on stdin: an rc tag without `--prerelease` is denied, and with it gets no decision; a stable whose check exits 1 is denied; a stable with a different `--target` is denied; a stable with no `--target` is denied; a passing stable is allowed; a quoted variable tag is denied.
  - After merge, one live probe: `gh release create v9.9.9-hookprobe --repo glw907/hookprobe-absent --target main --title x --notes x`, with no `--prerelease`, must return the hook's deny text. If the hook did not load, gh fails on the missing repo and creates nothing.
  - Channels the hook does not see: `gh api .../releases` and the web UI. Each is a deliberate act outside the session's allowed commands.
  - Project scope, because the rule is repo-specific (`claude-infra`, "User scope for stack-wide, project scope only for repo-specific").
- **Allow rules** in the project's `permissions.allow`: `Bash(node scripts/release/*)` and `Bash(gh workflow run publish.yml --ref v* -f promote=*)`. Auto mode refused a `gh workflow run` with no rule (`~/.local/state/claude-denials.jsonl`, 2026-11-02 08:43). An empty `promote` now runs nothing, since publishing needs a release. A stable stays gated by the hook. The user-scope `gh release create` rules already exist (`~/.dotfiles/claude/.claude/settings.json:36-40`).
- **`cairn-running-passes`**: the ruling 10 carve-out, `scripts/release/**` in `runner`, and `references/launch-prompts.md` with the executor and conductor prompt fields `pass-core` "Launch prompt" lists, restating no rule.
- **Worktree guard.** PR #193's `## Tooling` reports the guard refusing compound, `cd`-prefixed, `$()`, and heredoc-with-git-word forms, and `git -C <other worktree>`. None of those refusals is in `claude-denials.jsonl`, so the logged auto-mode path is not the source. Probe P-WT names the source. The command-form rule then lands in `.claude/agents/cairn-implementer.md`, plus `pass-core` if the source is workstation-wide, in the `~/.dotfiles` PR.
- **`cairn-releasing`**, rewritten around the scripts. It keeps the four judgment calls, the #349 standing rule (a pass that changes `scripts/gate/` ends with one run against the current `gate` candidate, through `--cli` when it also changes the setup tool), a pointer to the carve-out, and the topical changelog grouping recorded as a house departure from Keep a Changelog's six types (you, 2026-11-03). It adds a fixed retrospective paragraph for the stable's release commit: candidate count, friction filed, fixed before the stable, and the backlog numbers of the rest (research row 18). The "Gate the candidate" text describes pass A's headless, no-hold, locked behavior from this spec.

**Leaves out.** Changes to `scripts/gate/**` and to the setup tool, since both belong to pass A. A required status check, a release branch, and a canary (rulings 3 and 5). The SKILL.md `` !`status` `` injection.

## The rc.4 sequence

The conductor runs it from the pulled main checkout, after both PRs merge. Gate runs go through `run_in_background`, as in A14.

1. Run `node scripts/release/preflight.mjs 0.99.0-rc.4`.
2. Fold `## Unreleased` into the `## 0.99.0-rc.3` section of `CHANGELOG.md` and `MIGRATION-NOTES.md`, as the `rc.3` cut did, adding pass B's lines. Commit the fold on its own.
3. Run `node scripts/release/bump.mjs 0.99.0-rc.4`, `node scripts/build/build-guidance-hashes.mjs`, and `npm run check:close`. Commit the cut and push `main` by fast-forward. Set `SHA=$(git rev-parse HEAD)`.
4. Wait for `test` on the cut commit: `gh run watch "$(gh run list --workflow test.yml --commit "$SHA" --json databaseId --jq '.[0].databaseId')" --exit-status`, listing again until the run appears. The tag waits on green, because the tag ruleset makes a tag on a red commit permanent.
5. Run `node scripts/release/notes.mjs 0.99.0-rc.4` and write the summary. Then run `gh release create v0.99.0-rc.4 --prerelease --target "$SHA" --title "..." --notes-file <file>`, which the hook checks.
6. Run `gh run watch "$(gh run list --workflow publish.yml --event release --limit 1 --json databaseId --jq '.[0].databaseId')" --exit-status`, then `node scripts/release/wait.mjs 0.99.0-rc.4 gate`, then `node scripts/release/verify.mjs 0.99.0-rc.4`.
7. Read `GET /accounts/<id>/builds/tokens` and require exactly one `cairn-build` entry, the rehearsal's. Run `bash scripts/gate/run-gate.sh --smoke`, then `bash scripts/gate/run-gate.sh --all --version 0.99.0-rc.4`.
8. When `node scripts/gate/verdict.mjs 0.99.0-rc.4` exits 0, run `gh workflow run publish.yml --ref v0.99.0-rc.4 -f promote=0.99.0-rc.4`. Watch it with `gh run watch "$(gh run list --workflow publish.yml --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId')" --exit-status`, then run `node scripts/release/wait.mjs 0.99.0-rc.4 next`, and require `node scripts/release/status.mjs 0.99.0-rc.4` to exit 0.
9. You run your real install (run sheet step 12). The STATUS hand-over also corrects the stale line that the 2026-11-02 triage "landed nothing" (`sweep.md`, "Full-sweep check").

## End-to-end check

The round is done when all three of these hold:

- **The rehearsal**, before pass A merges. Its four legs pass on pass A's packed setup tool, and A14 step 5's four assertions hold. That run is where the narrow token's Builds deploy serves the marker on `carin-test.org`, which settles probe P3 before anything publishes.
- **The gate.** The `rc.4` gate's four legs pass by `evaluateLeg` alone, with no hand step, and all four rows carry one `Run` id. `driver.log` shows no answer to the deploy-token prompt, every logged trigger used the rehearsal's `cairn-build` uuid, and exactly one `cairn-build` entry exists afterward.
- **The promotion.** It runs through the hardened `promote`: `verdict` read four `pass` rows from one run, `promote` ran in `npm-publish` on ref `v0.99.0-rc.4`, and `status.mjs` exits 0. If P-ENV forced the hand fallback, the promotion counts only after `verdict` passed in that dispatch's run, and the check records "promoted by hand under P-ENV" with the run id. A17's tests cover the refusals.

## Out of scope

- A release branch, a canary, and a required check on `main` (rulings 3 and 5).
- #338, #339, and #340, which come after the release.
- The stable, its tool tag, the site audits, and the retrospective (run sheet steps 12-20).
- Vault and secrets-store work, which belongs to the security session (`docs/STATUS.md`).
- The due full backlog sweep, which goes to you as its own triage list.

## Risks and unknowns

| Id | Unknown | What settles it |
|---|---|---|
| F2 | Why A1's setup tool exited 1 0.8 s after the email "yes" (`run4/driver.log`). The throw is in `ensureSendingDomain` or `sendTestMessage` (`chapter2.mjs:990-1007`). | The rehearsal, with A4's capture kept and the CLI's own error in the row. A product fix lands in pass A and reruns there. |
| P-SOA | Whether the zone's SOA minimum can drop to 60 s, and with which token. | Pass A reads `GET /zones/<id>/dns_settings` with `ws-admin`, then sends the write. A refusal leaves the A11 product fix to cover the setup tool. If the minimum drops, the gate may never reach A11's pinned path, which its unit tests then carry. |
| P1 | Whether Builds registers a token with only Workers Scripts, D1, and R2. | Pre-flight step 3 registers `ci-cairn-build` under a probe name, then deletes the registration by uuid. The smoke repeats it each run. |
| P3 | Whether a Builds deploy on a domain-attached Worker needs zone rights. Cloudflare: "you can deploy new Worker versions with only Editor access, as long as the deployment does not add, update, or remove that connection" (<https://developers.cloudflare.com/workers/authorization/>), and the scaffold's `wrangler.jsonc` sets no route. | The rehearsal's A2, on pass A's setup tool. If it fails, the narrow-token standing answer applies. |
| PS | How a registration whose token was deleted shows up, and whether Builds accepts two registrations with one name. | Pre-flight step 3: mint a throwaway token, register it twice under one probe name, read `GET /accounts/<id>/builds/tokens`, delete the token, and read again, recording the fields. Then delete both registrations by uuid. |
| P6 | Whether a trigger's build token can be re-pointed. | Read the Builds API reference for a trigger update route. Needed only for the Later automatic re-point. |
| P-ENV | Whether a dist-tag change over OIDC honours the environment binding. | Pre-flight step 4's old-copy check, then the `rc.4` promotion, with the standing answer as the fallback. |
| P-PROV | Provenance for a tarball packed in a different job. The same-job tarball publish has it (`npm view create-cairn-site@0.99.0-rc.3 dist.attestations`). | The `rc.4` publish, checked by `verify.mjs`. If one package fails, `rc.4` is half-published under a tag that cannot move: `wait` names the split, `withdraw` deprecates the published half, and the fix (pack in the publish job) goes forward to `rc.5`. |
| P-DEP | Whether OIDC trusted publishing can run `npm deprecate`. | Pass B reads <https://docs.npmjs.com/trusted-publishers>. `withdraw` prints the commands unless the page says yes. |
| P-WT | The source of the worktree-guard refusals. | Pass B, in a worktree-isolated subagent, runs each refused form once and records the refusal text. |
| B-13 | Whether ward's Stalwart accepts mail from a `p=reject` domain signed by Cloudflare. | The rehearsal's B2, under the mail standing answer. |
| M7 | Whether GitHub challenges headless Chromium. | The rehearsal, under its standing answer. |
| Six-key setup token | The gate hands the setup tool the wide `ws-cairn-gate` (`gate.mjs:38-40`), so a key missing from the six-key set first shows on a real install. | A10's source-scan test only. A miss is a fix forward. |
| Token reach | The `cairn-build` registration is account-wide on your account, and your sites will reuse it (ruling 16). | No probe needed. The inventory row marks `ci-cairn-build` production-critical. |

## The rehearsal's rules

The rehearsal runs pass A's packed setup tool against the `rc.3` engine on npm (ruling 15). `rc.3`'s product code is main's (`git diff 4644cd35b..bb3c8d3a2 -- packages/create-cairn-site` is empty, `legs-a.md`), so pass A's diff is the only product change under test.

**Expected: none.** Every failure is fixed before pass A's PR, by the standing answers. The setup token's wide registration (old E4) no longer occurs, and the domain hold (old E3) meets A11's pinned check.

**Anticipated, each told apart by its evidence:**

- **F2, the email throw on A1 or B2.** The row's CLI text holds an `ensureSendingDomain` or `sendTestMessage` error line. Without that line, the exit is a harness gap.
- **B-13, B2 mail not arriving.** The gate mailbox, queried outside the harness, holds no message from `no-reply@carin-test.org` since the request. A found message whose marker was not fetched is a harness gap.
- **M7, a GitHub challenge.** A `failPage` screenshot shows a challenge page.
- **A domain hold.** The row's CLI text holds the `hostname-resolver-lagging` line after the pinned check ran. That is an A11 defect, fixed in pass A.
- **A narrow token too narrow.** The Builds log names the missing permission.

**Harness gaps**, fixed in pass A:

- the Saved alert, or any held or unrecognised GitHub, loopback, or sign-in page
- an idle or wall-clock failure while the screen shows "Watch progress at"
- a leg with no row, a `pending` row after the run, or B not running after an A failure
- a wrong install's record, or a prompt with no table entry
- a `token=` refusal in a row (M12)

## Backlog verdicts

From the scoped sweep at `bb3c8d3a2` (`sweep.md`). Approving the design approves these edits.

| Verdict | Items |
|---|---|
| Fold, pass A | #341; #336, reworded to drop "run its first live leg" and keep the tests, the 7003 allowlist, the trigger field, and the gone-dir case; #348; #349 (the run) |
| Fold, pass B | #345, #346, #347; #205, with its line corrected to `publish.yml:25-27`; #349 (the standing rule) |
| Fold, pre-flight | #337, closed by the npm sitting |
| Done | #330: `CHANGELOG.md:145,159` name the options only as removals |
| Keep, stamped `swept 2026-11-03` | #340, #339, #274, #246, #245, #211, #191, #249, #204, #185, #168 |

A full sweep is due: 47 of 67 open items carry no stamp. It goes to you as its own triage list.

## Estimate

Path minutes come from ruling 13. Each pass runs two pair lanes, and its path is the longer lane plus its serial tail. The review fold added the `--cli` mode (ruling 15), the lock, the run-id table and its reader, the named tests, release-only publishing, the stable-source ignore set, and the hook's extra denials. It also put the CI wait before the tag and set the `rc.4` gate run to the rehearsal's measured length.

| Unit | Lane 1 | Lane 2 | Serial tail | Path |
|---|---|---|---|---|
| Pass A | Harness A1-A9, A16, A17: 360 | Product A10-A13: 245 | `--cli` mode and pack: 75. Rehearsal A14: 120. Close: 50. Fix rounds: 70. | 675 |
| Pass B | Scripts: 245 | Workflow, checks, hook: 240, then skills and infra: 135 | Close: 50. Fix rounds: 95. | 520, run beside A |
| rc.4 | | | Cut: 25. CI wait: 25. Publish and wait: 15. Smoke and gate: 115. Promote and status: 20. | 200 |
| **Round** | | | | **875** |

The ceiling stays at the 1,240 path minutes you approved, now about 1.4 times the path. A plan whose path is over 1,240 goes back to you before the packet.

## Later

- M11: `record.mjs` passes `--repo glw907/cairn-cms`, and a failed record write logs instead of throwing.
- M12: scrub `token=` from `cliFailureMessage`.
- B-15: cancel an in-flight build before teardown. B-16: gate B1 on A's teardown leaving nothing.
- B-17: the email completion copy on a Builds site, and "Confirm sign-in". B-9: narrow the sign-in regex. B-11: B2's unused `builds` field.
- Delete the old wide `cairn create-cairn-site build token` registration once `rc.4` passes: by the uuid whose `cloudflare_token_id` is `ws-cairn-gate`'s id, only after a trigger read shows no trigger holds it. Then drop D1 and R2 from `ws-cairn-gate`.
- Re-point existing Builds sites automatically (P6).
- Move npm to 12.x once one publishes cleanly (the `publish.yml` WATCH).
- A lock so `npm test` and `check:close` cannot run concurrently (research row 10).
