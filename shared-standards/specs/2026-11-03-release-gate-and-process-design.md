# Release gate and release process for 0.99.0

## Brief

The `0.99.0` release is stuck at its gate: four live runs on `rc.3` never passed, each found one more harness gap, and you stopped live trial and error on 2026-11-03 until a plan found the rest from source. The gate is the harness in `scripts/gate/` that installs real sites with the published setup tool, publishes an edit through each site's admin, and passes only when the edit shows at the live address. A candidate (`rc`) waits on a hidden npm tag until the gate passes, and promotion then moves it to `next`. You asked for a clean, documented, streamlined, idiomatic release process and the Claude infra to support it. A read-only walkthrough of all four legs against the source found why the runs failed: the harness clicked Save instead of Publish, held an auto-approved GitHub sign-in page, ignored the setup tool's exit code, and waited out a 30-minute DNS cache.

Two passes run in parallel, then one candidate. Pass A fixes the gate harness, makes it run without a browser window, narrows the Workers Builds token (#341), and fixes the DNS stall in the setup tool. It ends with one rehearsal run against `rc.3`, whose expected failures this spec names in advance. Pass B turns the mechanical release steps into `scripts/release/` commands, hardens the publish workflow, makes a breaking change take a minor version, adds the stable-cut hook, and rewrites `cairn-releasing` around the scripts. After both merge, the conductor cuts `rc.4` with the new scripts, gates it once, promotes it, and hands you your real install.

Approving starts one pre-flight sitting for you: an npm terminal session, a temporary Cloudflare token, and a settings grant. The one act that cannot be undone is publishing `rc.4`, since a version number is permanent; a deprecation can be lifted. The plan path is about 620 minutes, and the ceiling is 1,240.

### What changes

- The gate runs headless and never waits for you. An unknown page fails its leg and saves a screenshot and the page's button and link names.
- A new site's Workers Builds deploys use a narrow token (Workers Scripts, D1, R2), made once per Cloudflare account and reused by later sites. Your setup token is no longer handed to Builds.
- The setup tool's domain check stops waiting out this machine's DNS cache once Cloudflare's own nameservers answer.
- A release is a short run of `node scripts/release/*` commands, and the skill keeps only the judgment calls.
- Promotion refuses a candidate unless its gate table shows four passes. The publish credential reaches only the publish steps, and `v*` tags and `main` cannot be rewritten or deleted.
- A breaking change can no longer ship as a patch.
- `rc.1` and `rc.2` are deprecated on all three packages, and the stale `rc` tag goes.

### If you approve

1. You run the pre-flight sitting under "Your steps".
2. The planning session finishes both plans, has them reviewed, and hands them to `conductor-cairn-cms`, which launches both passes.
3. Each pass ends in a PR, and the conductor sends you one packet for both.
4. After both merge, the conductor cuts `rc.4`, gates it once, and promotes it on four passes.
5. You run your real install on `rc.4` (run sheet step 12). The stable still waits on your "install passed".

### Worth knowing

Two consequences come from rulings, not new choices. The changelog date goes on a separate line under each version heading, not in the heading, because the installed `cairn` tool (`tool/v1.1.0`) reads headings with a pattern that allows nothing after the version (`tool/internal/health/check_engine.go:29`). A date in the heading would break its engine check. Also, the gate's Cloudflare account is your account (`scripts/gate/gate.mjs:25` and the estate inventory name the same id). The build-token registration the gate makes is therefore the one every later cairn site on that account reuses, including your install at step 12, which will not ask for a token. So the token is named for that job, `ci-cairn-build`.

### Rulings

All fourteen rulings below are settled, and the spec builds on each one. Source: you, in chat, 2026-11-03, unless a line says otherwise.

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

### Standing answers

The run applies these without stopping. Anything past them stops, writes STATUS, and runs `notify-send -u normal`.

- **Spend.** Inside 1,240 path minutes, a failure with a traced cause gets a fix and the run goes on, each fix listed in the PR's `## Decisions`. A cause that returns after its fix gets one structural fix, then escalation in the PR.
- **Items the run may escalate without breaking the outcome.** Stale-registration handling (#341 part 3), the showcase end-to-end test of the admin publish, and the per-route 7003 allowlist (#336 residue).
- **The `rc.3` rehearsal.** A failure on the expected list is recorded, not fixed in the harness. A failure off the list is a harness gap: fix it in pass A, then rerun only the affected legs.
- **A1's email failure.** If its captured error shows a product defect, fix it in pass A (`chapter2.mjs` or `email.mjs`). If it shows the environment, fix that before `rc.4` and record it.
- **Narrow token too narrow at `rc.4`.** If a Builds deploy fails on a missing permission, add the named key to the narrow set and fix forward to `rc.5`.
- **Promotion.** If the trusted publisher refuses a dist-tag change from the environment, you run `npm dist-tag add <pkg>@0.99.0-rc.4 next` for each of the three packages, then `npm dist-tag add create-cairn-site@0.99.0-rc.4 latest` (`cairn-releasing` lines 237-240).
- **A Workers Builds outage.** One rerun after 15 minutes (`cairn-releasing` line 215).
- **A refused settings write despite the grant.** The executor skips that write, and the conductor's packet carries it as a `[you]` step with the exact command.
- **A headless GitHub challenge in the rehearsal.** Rerun that leg with `--headed`. If headed passes, `rc.4` gates headed, and the gap goes to `BACKLOG.md`.

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
   In each package's npmjs.com settings, set the trusted publisher's environment to `npm-publish`. Keep "Allow npm dist-tag" ticked, and set publishing access to "Require two-factor authentication and disallow tokens". The planning session reads `npm help trust` before the packet. If the CLI can set the environment, the packet carries that exact command instead. End with `npm logout`. Done when `npm view <pkg>@0.99.0-rc.1 deprecated` prints the message for all six versions, `npm view @glw907/cairn-cms dist-tags --json` has no `rc` key, and each package's settings page shows the environment, the dist-tag box, and the access setting. Until `rc.4` is promoted, `npx create-cairn-site` and `@next` print the deprecation warning.
2. **[you] Temporary Cloudflare token.** In the dashboard, go to My Profile > API Tokens > Create Token and pick "Create Additional Tokens" at the foot of the list. Add nothing, and set a TTL ending tomorrow (estate inventory, rule 6). Paste it into the dialog the session opens with `VALUES=/dev/shm/tmp-setup-$(id -u).age LOCAL_SECRETS=$XDG_RUNTIME_DIR/self-hosting/secrets-tmp-setup secret-receive CF_TMP_TOKEN_SETUP`. Done when `GET /user/tokens/verify` with it answers `active`.
3. **[session] Mint and probe**, then delete the temporary token. If auto mode refuses, you run the tested script the planning session supplies (`pass-core`, "Pre-flight and owner-only steps").
   - Mint `ci-cairn-build`, a user token with Workers Scripts, D1, and Workers R2 Storage at edit on account `120c269ad6d3dfbe6d63a0bb53758ca0`. Store it with `secret-set.sh CF_CI_CAIRN_BUILD_TOKEN`, and commit its registry and inventory rows straight to workstation `main`, as the ledger records for `ws-cairn-gate`.
   - Run probe PS (stale registration) and probe P1 (Builds accepts the narrow token), both under Risks.
   - Delete the probe token and `tmp-token-setup` through the API.
   Done when the store lists `CF_CI_CAIRN_BUILD_TOKEN` by name, `/user/tokens/verify` with it answers `active`, and PS's two readings are in the plan.
4. **[session, else you] GitHub environment and rulesets.** If auto mode refuses, you paste the same commands.
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
   Done when `gh api repos/glw907/cairn-cms/environments/npm-publish/deployment-branch-policies --jq '.branch_policies[]|[.name,.type]'` prints `["v*","tag"]` and `gh api repos/glw907/cairn-cms/rulesets --jq '.[].name'` lists `pre-agent-first`, `release-tags`, and `main`.
5. **[you] Settings grant.** Run the grant script the planning session writes and dry-runs, as `apply-agent-first-grants.sh` was. It adds one `autoMode` line to `~/.dotfiles/claude/.claude/settings.json` and runs `claude-tooling-sync apply`. The line allows pass B's worktree to write `.claude/settings.json` holding only one PreToolUse hook entry for `gh release create` and the two allow rules in pass B's interfaces. Done when `grep -c 'release-gate-and-process' ~/.claude/settings.json` prints `1`. Pass B's close packet carries the line's removal as a `[you]` step.

## Outcome

`0.99.0-rc.4` is on `next` for all three packages and on `create-cairn-site@latest`. Its release body carries a `## Gate` table where A1, A2, B1, and B2 all read `pass`, as judged by `evaluateLeg` (`scripts/gate/legs.mjs:73-105`). It was promoted by the hardened `promote`, whose `verdict` job read that table. Your real install runs on it next. Every mechanical release step is a `scripts/release/` command, and `cairn-releasing` keeps four judgment calls: whether a release is warranted, its size, the notes prose, and failure triage. Initiative: `shared-standards`.

## Pass A: gate and product

Class `auth-data`: `packages/create-cairn-site/src/{github,cloudflare}/**` is `auth-data` (`cairn-running-passes` SKILL.md, risk classes). Executors run on Sonnet at medium in `cairn-implementer`. Items A10 and A11 carry novel correctness logic and upshift to Opus.

**Files.** `scripts/gate/{browser,driver,legs,gate,teardown}.mjs`, `scripts/gate/run-gate.sh`, and `scripts/gate/README.md`. `src/tests/unit/gate-*.test.ts` and new fixtures under `src/tests/unit/fixtures/gate-pages/`. Under `packages/create-cairn-site/`: `src/cloudflare/{prefill,chapter3,hostname,catalogue,api}.mjs`, `chapter2.mjs` and `email.mjs` only per A1's standing answer, their tests, and `test/fake-cloudflare*.mjs`. `examples/showcase/e2e/` for A9's optional spec. Docs: `docs/admin/{own-your-domain,before-you-start,setup-recovery}.md`, `packages/create-cairn-site/README.md`, `MIGRATION-NOTES.md`, and `CHANGELOG.md` (`## Unreleased` only).

### Harness items

| # | Finding | Mechanism at main | Change |
|---|---|---|---|
| A1 | M1, F5, B-14 | `publishViaAdmin` clicks Save if enabled, then Publish, then waits on `.alert` with `hasText: 'Published'` (`browser.mjs:371-378`). The Save flash "...the published version..." matches that string. Publish is enabled while the editor is dirty (`EditPage.svelte:301`). A publish redirects 303 to `?published=1` (`content-routes-entry-write.ts:456`). | Drop the Save click. Wait until `input[name="body"]` holds the marker, then run `Promise.all([page.waitForURL(/[?&]published=1/), publish.click()])` and read `.cairn-feedback`. On a URL timeout, return the visible `.alert` text instead of throwing. `evaluateLeg` keeps its exact comparison (`legs.mjs:87`). |
| A2 | M2 | `tailUrlLog` starts at `offset = 0` (`browser.mjs:245`). Every `runCli` of a leg tails the one shared `urls.log` (`legs.mjs:351,362`). | `tailUrlLog(file, onUrl, { from })`. Each `runCli` passes the file's current size. |
| A3 | B-1, B-2, F6, M3, B-8, B-10 | Authorize waits for a button, then holds (`browser.mjs:226-233`). The setup tool's three loopback success bodies end "Return to the terminal." (`github/oauth.mjs:116`, `github/install.mjs:251`, `github/manifest.mjs:183`). Its error bodies are `Forbidden` (`loopback-core.mjs:68`) and `Not found` (`loopback-core.mjs:91`, `github/loopback.mjs:67`). `signedIn` is set after the click whatever happened (`legs.mjs:374`). `requestSignInLink` reads no result (`browser.mjs:390-400`). | Add `onLoopback(page)`: the page is `http:` on `127.0.0.1`, the path is `/callback` or `/manifest`, and the trimmed body ends "Return to the terminal.". Every GitHub kind is done when it holds. Authorize clicks only when GitHub shows consent, then waits for the loopback. Any other loopback page fails the leg. After the confirm click, require the path `/admin`, or fail with the page text. After the send, require the heading "Check your email", or fail with the alert text. Never log a URL carrying `code=`. |
| A4 | F1, M4, B-5, F14 | A non-zero exit is checked only when the record has no origin (`legs.mjs:397-405`). A clean teardown deletes `capture.bin` (`gate.mjs:328`, `teardown.mjs:220`). | When `cli.code !== 0`, fail the leg with `cliFailureMessage` before reading the record. Keep `capture.bin` when any leg failed. |
| A5 | M5 | Early returns skip `recordLeg` (`legs.mjs:397,404,409`). A throw in group A skips group B (`gate.mjs:425-429` with `legs.mjs:115-121`). The verdict cell keeps `failures[0]` (`legs.mjs:478`). | `runLeg` writes its row in a `finally`, with `fail: <reasons joined by "; ">`. `main` catches per group, so B runs after A throws. A leg not run gets `skipped: needs <leg>`. The table always has four rows. |
| A6 | M6, F8 | Any stdout chunk re-arms the idle timer (`driver.mjs:194-199`). A chunk holding `Watch progress at` sets a sticky `holding` flag, which allows 45 minutes until the next answer (`driver.mjs:20-23,172,188,198`). | Progress means a change in `stripVolatile(screen())`, which removes spinner glyphs and elapsed counters, compared on the settle timer. The hold limit (`HOLD_IDLE_MS`) applies only while the last non-blank screen line holds the marker. Each `runCli` gets one wall clock (90 minutes) that fails with "the run exceeded its budget". |
| A7 | M13, B-7, F10 | `readRecord` returns the first `*.json` in the shared state dir (`legs.mjs:310-317`). The account select uses `label: ''`, which matches any option (`legs.mjs:264`). | Pick the record whose `dir === install.dir`, and skip `.retired-` files. Set `label` to the gate account's name (a constant beside `GATE_ACCOUNT_ID`, read once from `GET /accounts/<id>`). |
| A8 | M7 | `launchBrowser` defaults `headless = false` (`browser.mjs:309`). `makeSession` passes nothing (`gate.mjs:294`). An unknown page is held for 10 minutes and sends a notification (`browser.mjs:155-175,233`). | Default `headless = true`. `makeSession(env, { headed })` reads `--headed` from argv, which `run-gate.sh` passes on (`run-gate.sh:44`). `failPage` replaces `holdPage`: it writes `<leg>-<ts>.png`, except on a sign-in page or a URL carrying `token=` or `code=`. It also writes `<leg>-<ts>.controls.txt` with one `role<TAB>name` line per button and link, from `page.evaluate`, with no input values, no query string, and no `ariaSnapshot`. Then it throws `UnrecognisedPageError`. Remove `holdPage`, `HoldTimeoutError`, `STEP_MS`, `notifyDesktop`, and their plumbing. Every handled GitHub page also writes its controls file into the run dir, which feeds #348. Update `USAGE` (`gate.mjs:261-262`) and `README.md`. |
| A9 | #336 (reworded), #348 | The fixtures are hand-built (`gate-browser.test.ts:38-86`). The invented admin editor has no `busy`, no reload, and no Saved flash. `runLeg` and `main` have no test. | Tests: a 302 from `github.com/login/oauth/authorize` to a loopback serving the `oauth.mjs:116` body, which must pass with no failure. A fake CLI that prints spinner frames with a ticking counter forever must fail with "no progress". A second `tailUrlLog` on one file must not re-handle earlier lines. Tests of `runLeg` through an injected-dependency parameter cover exit 1 with an origin, a throw in the publish, and the replay, and each must yield a row naming the cause. After the rehearsal, the GitHub fixtures are rebuilt from the captured controls files. Delete the invented admin-editor fixture. If cheap (the showcase's `/test/last-commit`, `examples/showcase/e2e/golden-path.spec.ts:202,223`, needs no new server code), add one showcase spec that drives `publishViaAdmin` and asserts the commit is on `main`. |

**Where the walkthrough files disagreed, settled from source.**

- F5 keeps an alert regex. M1 waits for `?published=1`, which is right, since the redirect is the success signal (`content-routes-entry-write.ts:456`).
- F6 accepts any `127.0.0.1` page. B-1 requires the path and the success text, which is right, since the loopback also serves `Not found` and `Forbidden`.
- `common.md` lists A1's missing not-connected sentence as unknown. F3 settles it: the setup tool exited 1 before the Builds prompt (`run4/driver.log` 03:47:09). The sentence is in `publishLine` (`bin.mjs:106-114`).
- `sweep.md` calls B1 and B2 `--yes` legs. The driver never passes `--yes` to the setup tool (`driver.mjs:2`, and `legs.mjs:382`, where `--yes` is npx's flag), and the TTY build watch is held, so the gate does not meet #339.

### Product items

**A10. #341, the narrow build token.** At main, the trigger hop registers the setup token itself (`chapter3.mjs:1377-1389`, `BUILD_TOKEN_NAME` at `:97`). The hop is skipped when a trigger exists (`:1369-1375`).

- `prefill.mjs` adds `BUILD_TOKEN_PERMISSION_KEYS = [{workers_scripts, edit}, {d1, edit}, {workers_r2, edit}]` and a prefill URL with the token name `cairn-build`. All three keys are proven to fill rows (`prefill.mjs:52-57`). `CHAPTER3_PERMISSION_KEYS` becomes the six keys of `CHAPTER2_BUILDS_PERMISSION_KEYS` (`prefill.mjs:87`). The setup tool's source makes no D1 or R2 API call (no `/d1` or `/r2/` route in `packages/create-cairn-site/src`, tests excluded), and chapter 3 runs no wrangler with the token: its only wrangler string is the trigger's deploy command (`chapter3.mjs:94`).
- Trigger hop: `getBuildTokens()` (`api.mjs:609-611`). Reuse the entry whose `build_token_name === 'cairn-build'`, with no prompt. Otherwise collect the build token: open the second prefilled URL, prompt "Paste your Workers Builds deploy token", or under `--yes` read `CAIRN_CF_BUILD_TOKEN` with the same argv guard as `CAIRN_CF_API_TOKEN` (`prefill.mjs:255-282`). Verify it with `GET /user/tokens/verify` through a `makeApi` built on the build token, never `listZones`, since a narrow token has no zone read (`prefill.mjs:156-168`). Then register `{ name: 'cairn-build', secret, cloudflareTokenId }` through the setup-token api (`api.mjs:616-624`). The build token is never written to state. A `--yes` run with no registration and no env var parks with a new catalogue row.
- The new prompt text must not contain "Paste your Cloudflare API token". The driver takes the first table entry the line includes (`driver.mjs:180`).
- Stale registration: the signal comes from probe PS. If the list shows it, the hop deletes the stale registration (the route the smoke already uses, `gate.mjs:249`) and collects a new token. If the list does not, the signal is the first build's failure inside the existing watch. The re-point is then settled by probe P6, and with no route the item escalates per the standing answer.
- Rewrite `ADMISSION_DETAIL` (`chapter3.mjs:950`) and the module header's token lifecycle. Leave a `// WATCH:` at the hop: switch to an account-owned token once Builds accepts one ("Account-scoped tokens are not supported", Builds API reference, cited in the estate inventory row for `ws-cairn-gate`).
- Existing connected sites keep their wide token, since the hop is skipped. `MIGRATION-NOTES.md` gives the manual re-point: create the narrow token, select it under Worker > Settings > Builds > API token, then delete the old one.

**A11. DNS pinned check.** `confirmWithDiagnosis` probes through global `fetch` (`hostname.mjs:200-212`). When both probes are unreachable, `diagnoseUnreachable` reads AAAA authoritatively and reports `hostname-resolver-lagging` (`hostname.mjs:147-163`). The recursive half is pinned to `1.1.1.1` and `8.8.8.8` (`dns.mjs:21`), not to the host resolver `fetch` uses.

- When the authoritative read has the record, read A authoritatively too (`readAuthoritativeAndRecursive` with `method: 'resolve4'`, `dns.mjs:145`). Rerun the marker probe once through `node:https.request`, with a `lookup` that returns that address. SNI and Host stay the domain, and no dependency is added.
- A match reports `live`, plus one line saying this machine's resolver may take up to 30 minutes to see the domain. The marker stays the authority.

**A12. The gate's second token and zone.**

- Add `CF_CI_CAIRN_BUILD_TOKEN` to the allowlist regex (`run-gate.sh:26`) and to the smoke's redaction list (`gate.mjs:96`).
- Add a `promptTable` row, `{ match: 'Paste your Workers Builds deploy token', kind: 'password', value: () => buildToken }`.
- The smoke's registration probe registers the build token, verified through `/user/tokens/verify` with the build token (`gate.mjs:245-253`).
- Teardown still never touches build-token registrations (`scripts/gate/README.md:95`).
- With `$CLOUDFLARE_API_TOKEN` (`ws-admin`), read `GET /zones/<carin-test.org>/dns_settings`, then lower the SOA negative-cache minimum to 60 seconds if the API accepts it (probe P-SOA).

**A13. Docs.** Edit `own-your-domain.md`, `before-you-start.md`, and `setup-recovery.md` for the second token, its once-per-account reuse, the new refusal row, and the DNS line. Edit the create-cairn-site README: lines 326-357 ("No second dashboard trip", "The coupling") reverse, and the at-rest paragraph changes. Add the `MIGRATION-NOTES.md` entry and `CHANGELOG.md` `## Unreleased` lines through the `cairn-writing-docs` skill. Update `scripts/gate/README.md` for headless, `--headed`, `failPage`, and the second token.

**A14. The `rc.3` rehearsal (ruling 9), last.**

1. From the pass worktree, run `bash scripts/gate/run-gate.sh --smoke`, then `bash scripts/gate/run-gate.sh --all --version 0.99.0-rc.3`. The user allow rule `Bash(bash scripts/gate/run-gate.sh *)` covers both.
2. Judge each failure against the expected list below.
3. Copy the captured controls files into the fixtures (A9).
4. Read the teardown log's 404 codes per route to set the 7003 allowlist (`teardown.mjs:125-128`).
5. Confirm `build_trigger_uuid` from a captured build record (`chapter3.mjs:911`, #336 residue).

**Leaves out.** M11 (`record.mjs` `--repo` and a non-fatal record write), M12 (scrubbing `token=` from failure text), B-9, B-11, B-15, B-16, and B-17. All are in `## Later`.

## Pass B: release process and infra

Class `runner` (`cairn-running-passes`: `scripts/checks/**`, `.github/workflows/**`, plus skills and agents per `pass-core`). This pass adds `scripts/release/**` to the `runner` path map. Executors run on Sonnet at medium.

**Files.** `scripts/release/{preflight,bump,wait,status,notes,verify,withdraw,gate-verdict}.mjs`, with tests in `src/tests/unit/release-*.test.ts`. `scripts/checks/{check-version,check-stable-source,close-prebuilt}.mjs` and their tests. `.github/workflows/publish.yml`. `.claude/settings.json`, `.claude/hooks/release-cut-guard.mjs`, `.claude/skills/{cairn-releasing,cairn-running-passes}/**`, `.claude/agents/cairn-implementer.md`, and `ROADMAP.md:176`. A second PR in `~/.dotfiles` holds only what the guard probe places there. Pass B writes no `CHANGELOG.md` line. The conductor adds pass B's consumer-visible lines when it folds the window at the cut, which keeps the two passes' files disjoint.

**Release scripts.** Each is `node scripts/release/<name>.mjs <version> [flags]`, exits 0 or 1, and ends with one `Next:` line. The core of each is a pure function over a command runner, the pattern `check-stable-source.mjs:31,95` already uses.

| Script | Does | Source |
|---|---|---|
| `preflight` | Clean tree. `HEAD == origin/main`. Version absent from `npm view <pkg> versions` on all three. Both installs present: root `node_modules/.bin/svelte-package` and `examples/showcase/node_modules` (#346). A non-empty `## Unreleased`, which `--stable` skips. | #346, research row 11 |
| `bump` | Writes the eight files `check-stable-source.mjs:43-67` allows: four manifest versions, the lockfile version lines, the template pins and `VERSION` through `npm run emit:template`, the CHANGELOG heading plus a `Released YYYY-MM-DD.` line under it, and the MIGRATION-NOTES heading plus its `(./CHANGELOG.md#<slug>)` anchors. It refuses while `## Unreleased` sits above a heading on the same numeric core, because folding that window is the cut's judgment call (the `rc.3` cut did it by hand, `4644cd35b`). | #345 |
| `wait` | Polls `https://registry.npmjs.org/<pkg>` with no cache until `dist-tags[<tag>]` equals the version on all three, for up to 10 minutes. | #347 |
| `status` | Prints a JSON checklist: the tag on origin, the release and its prerelease flag, `gate-verdict`, dist-tags by stage, `dist.attestations.provenance` on all three, and the CHANGELOG heading. Exits non-zero until complete. | research row 4 |
| `notes` | Writes the notes file: the version's CHANGELOG section plus every `Consumers must:` line other than `nothing.` (`LINE`, `check-consumers-must.mjs:22`). The session writes the summary paragraph. | research row 15 |
| `verify` | Checks dist-tags and provenance on all three. For a stable, it fetches each package's tarballs for the final candidate and the stable and allows only lines that become equal once the candidate version is replaced with the stable version, plus the date line. | research rows 5, 14 |
| `withdraw` | Prints the `npm deprecate` and `npm dist-tag` commands for a failed candidate (ruling 8). If probe P-DEP shows OIDC can deprecate, it dispatches a `withdraw` input that runs them in the environment instead. | research row 1 |
| `gate-verdict` | Reads `gh release view v<V> --json body` and parses the `## Gate` table by `GATE_COLUMNS` (`scripts/gate/record.mjs:13`; pass A owns that file, and this script imports only the constant). Exits 0 only when the rows for A1, A2, B1, and B2 each read exactly `pass`. | research row 2 |

**`publish.yml`.** Today `id-token: write` is workflow-wide (`publish.yml:25-27`), each publish job runs `npm ci`, which runs `prepare` and `npm run package` (`package.json` scripts), actions are on tags (`:35-36`), npm floats (`npm@^11.21.0`, `:46`), and `promote` checks only that the version exists (`:245-250`). The new shape:

- Top-level `permissions: contents: read`. No job holds `id-token` except those that publish or tag.
- `ci-green` runs wherever the publish jobs run (the condition at `publish.yml:31`). It polls `GET /repos/{repo}/commits/{sha}/check-runs` until `test` completes, plus `e2e` for a stable, and fails unless each concluded `success`, within 45 minutes (`e2e.yml:20` caps its job at 25). It needs `checks: read`, which the pass confirms against GitHub's REST reference. Both check names exist on `4644cd35b` (read with `gh api` on 2026-11-03).
- `build` has no `id-token` and needs `ci-green`. It runs bounded `npm ci`, then `npm run check:package`, then `npm pack --ignore-scripts` at the root and in `packages/cairn-cms-dev`. It runs the create-cairn-site bake and pack exactly as `:209-210`, then uploads the three tarballs as one artifact.
- `publish`, `publish-dev`, and `publish-create-site` each set `environment: npm-publish` and `id-token: write`, and each needs `build`. They download the artifact and run `npm publish <tgz> --ignore-scripts --access public --tag "$TAG" --provenance`. They keep the already-published guards and the `create-cairn-site` version guard (`:179-205`).
- `verdict` has no `id-token`. It runs on dispatch, with a sparse checkout of `scripts/release/gate-verdict.mjs` and `scripts/gate/record.mjs`, which imports only Node built-ins (`record.mjs:5-8`), and no install. It checks `GITHUB_REF_NAME == v$PROMOTE_VERSION`, then runs `gate-verdict`.
- `promote` needs `verdict`, sets `environment: npm-publish` and `id-token: write`, and keeps its body (`:234-254`). It is dispatched on the tag ref: `gh workflow run publish.yml --ref v<V> -f promote=<V>`. The environment admits only `v*` refs, and the trusted publisher binding then refuses OIDC from every older workflow copy, including the unhardened `promote` at `v0.99.0-rc.1` through `rc.3`.
- Every `uses:` is pinned by commit sha, resolved with `gh api repos/<action>/git/ref/tags/<tag>`. npm is pinned to `npm@11.21.1`, the newest 11.x (`npm view`, 2026-11-03). The npm 12 WATCH stays (#205 fold).

**Checks.**

- `check-version.mjs`: in the `bump === 'patch'` branch (`:204-211`), fail when the entry body has a `Consumers must:` line other than `nothing.`. The `## Unreleased` simulation calls `checkVersion` (`:129-130`), so a breaking line without a minor marker fails on the pass that writes it.
- Rewrite `RULE` (`:13`), which points at a README "Status" section that does not exist.
- `cairn-releasing` step 4 and `ROADMAP.md:176` carry the new rule.
- `check-stable-source.mjs`: the CHANGELOG predicate (`:50`) also accepts `^Released \d{4}-\d{2}-\d{2}\.$`.
- `close-prebuilt.mjs`: before building, check the two install paths and exit with the exact `npm ci` commands (#346). `preflight` imports the same check.

**Claude infra**, through `claude-infra`, each change citing its page:

- **Hook** (`.claude/hooks/release-cut-guard.mjs`, a project-scope PreToolUse entry on `Bash`). The hooks reference is <https://code.claude.com/docs/en/hooks>; research row 10 cites its `permissionDecision: deny`. For a command holding `gh release create`, take the tag:
  - `^v\d+\.\d+\.\d+-` without `--prerelease` is denied.
  - `^v\d+\.\d+\.\d+$` runs `node scripts/checks/check-stable-source.mjs` and denies unless it exits 0 and `--target` equals its `sha:` line (`check-stable-source.mjs:158`).
  - Any other tag gets no decision.
  - Project scope, because the rule is repo-specific (`claude-infra`, "User scope for stack-wide, project scope only for repo-specific").
- **Allow rules** in the project's `permissions.allow`: `Bash(node scripts/release/*)` and `Bash(gh workflow run publish.yml --ref v* -f promote=*)`. Auto mode refused a `gh workflow run` with no rule (`~/.local/state/claude-denials.jsonl`, 2026-11-02 08:43). A stable stays gated by the hook. The user-scope `gh release create` rules already exist (`~/.dotfiles/claude/.claude/settings.json:36-40`).
- **`cairn-running-passes`**: the ruling 10 carve-out, `scripts/release/**` in `runner`, and `references/launch-prompts.md` with the executor and conductor prompt fields `pass-core` "Launch prompt" lists, restating no rule.
- **Worktree guard.** PR #193's `## Tooling` reports the guard refusing compound, `cd`-prefixed, `$()`, and heredoc-with-git-word forms, and `git -C <other worktree>`. None of those refusals is in `claude-denials.jsonl`, so the logged auto-mode path is not the source. Probe P-WT names the source. The command-form rule then lands in `.claude/agents/cairn-implementer.md`, plus `pass-core` if the source is workstation-wide, in the `~/.dotfiles` PR.
- **`cairn-releasing`**, rewritten around the scripts. It keeps the four judgment calls, the #349 standing rule (a pass that changes `scripts/gate/` ends with one run against the current `gate` candidate), a pointer to the carve-out, and the topical changelog grouping recorded as a house departure from Keep a Changelog's six types (you, 2026-11-03). It adds a fixed retrospective paragraph for the stable's release commit: candidate count, friction filed, fixed before the stable, and the backlog numbers of the rest (research row 18). The "Gate the candidate" text describes pass A's headless, no-hold behavior from this spec.

**Leaves out.** Changes to `scripts/gate/**` and to the setup tool, since both belong to pass A. A required status check, a release branch, and a canary (rulings 3 and 5). The SKILL.md `` !`status` `` injection.

## The rc.4 sequence

The conductor runs it from the pulled main checkout, after both PRs merge.

1. Run `node scripts/release/preflight.mjs 0.99.0-rc.4`.
2. Fold `## Unreleased` into the `## 0.99.0-rc.3` section of `CHANGELOG.md` and `MIGRATION-NOTES.md`, as the `rc.3` cut did, adding pass B's lines.
3. Run `node scripts/release/bump.mjs 0.99.0-rc.4`, `node scripts/build/build-guidance-hashes.mjs`, and `npm run check:close`. Commit the cut and push `main` by fast-forward.
4. Run `node scripts/release/notes.mjs 0.99.0-rc.4` and write the summary. Then run `gh release create v0.99.0-rc.4 --prerelease --target main --title "..." --notes-file <file>`, which the hook checks.
5. Run `gh run watch <id> --exit-status`, then `node scripts/release/wait.mjs 0.99.0-rc.4 gate`, then `node scripts/release/verify.mjs 0.99.0-rc.4`.
6. Run `bash scripts/gate/run-gate.sh --smoke`, then `bash scripts/gate/run-gate.sh --all --version 0.99.0-rc.4`.
7. On four `pass` rows, run `gh workflow run publish.yml --ref v0.99.0-rc.4 -f promote=0.99.0-rc.4`, watch it, run `wait.mjs 0.99.0-rc.4 next`, and require `status.mjs 0.99.0-rc.4` to exit 0.
8. You run your real install (run sheet step 12). The STATUS hand-over also corrects the stale line that the 2026-11-02 triage "landed nothing" (`sweep.md`, "Full-sweep check").

## End-to-end check

The round is done when both of these hold:

- **The gate.** The `rc.4` gate's four legs pass by `evaluateLeg` alone, with no hand step. The A2 or B1 leg, whichever connects Builds first, meets the new deploy-token prompt. The later leg reuses `cairn-build` with no prompt. A Builds deploy with the narrow token serves the marker on `carin-test.org`, which settles probe P3.
- **The promotion.** It runs through the hardened `promote`: `verdict` read four `pass` rows, `promote` ran in `npm-publish` on ref `v0.99.0-rc.4`, and `status.mjs` exits 0. A unit test of `gate-verdict` covers the refusal: three passes and a `fail`, a missing row, and a `skipped` row each exit 1.

## Out of scope

- A release branch, a canary, and a required check on `main` (rulings 3 and 5).
- #338, #339, and #340, which come after the release.
- The stable, its tool tag, the site audits, and the retrospective (run sheet steps 12-20).
- Vault and secrets-store work, which belongs to the security session (`docs/STATUS.md`).
- The due full backlog sweep, which goes to you as its own triage list.

## Risks and unknowns

| Id | Unknown | What settles it |
|---|---|---|
| F2 | Why A1's setup tool exited 1 0.8 s after the email "yes" (`run4/driver.log`). The throw is in `ensureSendingDomain` or `sendTestMessage` (`chapter2.mjs:990-1007`). | The rehearsal, with A4's capture kept and the CLI's own error in the row. |
| P-SOA | Whether the zone's SOA minimum can drop to 60 s, and with which token. | Pass A reads `GET /zones/<id>/dns_settings` with `ws-admin`, then sends the write. A refusal leaves the A11 product fix to cover the setup tool. |
| P1 | Whether Builds registers a token with only Workers Scripts, D1, and R2. | At pre-flight, register `ci-cairn-build` under a probe name, then delete the registration. The smoke repeats it each run. |
| P3 | Whether a Builds deploy on a domain-attached Worker needs zone rights. Cloudflare: "you can deploy new Worker versions with only Editor access, as long as the deployment does not add, update, or remove that connection" (<https://developers.cloudflare.com/workers/authorization/>), and the scaffold's `wrangler.jsonc` sets no route. | The `rc.4` gate's A2. If it fails, the standing answer applies. |
| PS | How a registration whose token was deleted shows up. | At pre-flight: mint a throwaway token, register it, read `GET /accounts/<id>/builds/tokens`, delete the token, and read again, recording the fields. Then delete the registration. |
| P6 | Whether a trigger's build token can be re-pointed. | Read the Builds API reference for a trigger update route. Needed only if PS shows no list signal. |
| P-ENV | The npm environment binding: the CLI syntax, and whether a dist-tag change over OIDC honours it. | `npm help trust` before the packet. The `rc.4` publish and promotion test the binding, with the standing answer as the fallback. |
| P-PROV | Provenance for a tarball packed in a different job. The same-job tarball publish has it (`npm view create-cairn-site@0.99.0-rc.3 dist.attestations`). | The `rc.4` publish, checked by `verify.mjs`. If it fails, pack in the publish job and fix forward. |
| P-DEP | Whether OIDC trusted publishing can run `npm deprecate`. | Pass B reads <https://docs.npmjs.com/trusted-publishers>. `withdraw` prints the commands unless the page says yes. |
| P-WT | The source of the worktree-guard refusals. | Pass B, in a worktree-isolated subagent, runs each refused form once and records the refusal text. |
| B-13 | Whether ward's Stalwart accepts mail from a `p=reject` domain signed by Cloudflare. | The rehearsal's B2. A miss is classed as environment. |
| M7 | Whether GitHub challenges headless Chromium. | The rehearsal, under its standing answer. |
| Token reach | The gate's `cairn-build` registration is account-wide on your account (see the Brief). | No probe needed. It is a consequence of ruling 6-7, recorded in the inventory row. |

## The rc.3 rehearsal's expected failures

The rehearsal runs `rc.3`'s setup tool under pass A's harness. `rc.3`'s code is main's: `git diff 4644cd35b..bb3c8d3a2 -- packages/create-cairn-site` is empty (`legs-a.md`).

**Expected.** A failure on this list is recorded, not fixed in the harness.

- **E1. A1 exits 1 at the email hop** (F2). The row reads "the CLI run failed: exit code 1" with the setup tool's error lines, and A2 gets `skipped: needs A1`. Classify the error by the standing answer. If A1 passes the email hop, it ends `builds-connect-declined` with the not-connected sentence (F3), and A2 runs.
- **E2. B2 repeats E1** on the same zone and mailbox (B-4).
- **E3. A domain hold of up to 40 minutes** (`hold-loop.mjs:35`). It can end `hostname-resolver-lagging` with exit 0, which fails A1 or B2 on the closing-block sentences. This is expected only if P-SOA failed, because `rc.3` has no pinned check.
- **E4. `rc.3` registers the setup token as the build token** (`chapter3.mjs:1377-1389`), reusing the existing `cairn create-cairn-site build token` registration. This is the defect #341 fixes. `evaluateLeg` never sees it.
- **E5. B2 mail does not arrive** (B-13). It is logged as `mail:` with "no mail-borne sign-in ran" or a missing fetch, and classed as environment.

**Not expected.** Each of these is a harness gap, fixed before `rc.4`:

- the Saved alert, or any held or unrecognised GitHub, loopback, or sign-in page
- an idle or wall-clock failure while the screen shows "Watch progress at"
- a leg with no row, or B not running after an A failure
- a wrong install's record, or a prompt with no table entry
- a `token=` refusal in a row (M12)
- any A2 or B1 failure other than E1's skip

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

Path minutes come from ruling 13. Each pass runs two pair lanes, and its path is the longer lane plus its serial tail.

| Unit | Lane 1 | Lane 2 | Serial tail | Path |
|---|---|---|---|---|
| Pass A | Harness A1-A9: 270 | Product A10-A13: 210 | Rehearsal A14: 110. Close: 50. Fix rounds: 70. | 500 |
| Pass B | Scripts: 225 | Workflow, checks, hook: 170, then skills and infra: 135 | Close: 50. Fix rounds: 95. | 450, run beside A |
| rc.4 | | | Cut: 25. Publish and wait: 15. Smoke and gate: 60. Promote and status: 20. | 120 |
| **Round** | | | | **620** |

The ceiling is 1,240 path minutes. A plan whose path is over 1,240 goes back to you before the packet.

## Later

- M11: `record.mjs` passes `--repo glw907/cairn-cms`, and a failed record write logs instead of throwing.
- M12: scrub `token=` from `cliFailureMessage`.
- B-15: cancel an in-flight build before teardown. B-16: gate B1 on A's teardown leaving nothing.
- B-17: the email completion copy on a Builds site, and "Confirm sign-in". B-9: narrow the sign-in regex. B-11: B2's unused `builds` field.
- Delete the old wide `cairn create-cairn-site build token` registration once `rc.4` passes. Drop D1 and R2 from `ws-cairn-gate`.
- Re-point existing Builds sites automatically (P6).
- Move npm to 12.x once one publishes cleanly (the `publish.yml` WATCH).
- A lock so `npm test` and `check:close` cannot run concurrently (research row 10).
