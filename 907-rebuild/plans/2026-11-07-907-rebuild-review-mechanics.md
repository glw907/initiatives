# 907.life rebuild: mechanics and feasibility review

**Target:** initiatives `ca45e41`, worktree `907-rebuild-design`. Plan `907-rebuild/plans/2026-11-07-907-rebuild-plan.md` (P), spec `.../specs/2026-11-07-907-rebuild-spec.md` (S), design `.../specs/2026-11-07-907-rebuild-design.md` (D).

**Verdict:** not ready to approve. The departure itself is fine. The clean room, as specified, can't carry the work it's given: a headless builder in the Bash sandbox under auto mode runs into setup's terminal-only steps, the sandbox's network and filesystem limits, and auto mode's default block list. Five blockers and twelve major findings follow, ranked by consequence.

**Evidence:**
- Setup source and README in `cairn-cms/packages/create-cairn-site` at `b172d789a`.
- code.claude.com docs pages: sandboxing, permission-modes, permissions, mcp, memory, env-vars.
- GitHub's rename docs and Cloudflare's R2 docs.
- Local probes: `wrangler` 4.107 and 4.158 help output, the T3 grep run on the current tree, `command -v secret-get`, and `sync.sh` and `registry.md` in `~/.dotfiles`.
- `claude --version` is 2.1.319.

## Blockers

### B1. A headless builder can't drive setup's terminal-only steps
- **Severity:** blocker. **Tag:** correctness. **OWNER FORK** (part of it).
- **Where:** S:12, S:134; P:112, P:137-138.
- **Defect.** A builder's Bash call has no TTY, and setup gates several steps on one:
  - `CAIRN_CF_API_TOKEN` is read only under `--yes` (`prefill.mjs:312-331`). Without `--yes`, setup opens a browser and prompts for a paste with `@clack/prompts`, which has no terminal to read from.
  - Under `--yes`, the Builds config commit never runs: "`--yes` never opens a browser, so an unattended run parks there" (README, Builds chapter). The same applies to the domain and email commits once Builds is connected ("A run with `--yes` cannot open the sign-in page, so it stops before committing").
  - Under `--yes`, email is declined unless `--email` is passed, so T10's "A sign-in mail reaches Geoff" can't happen on the spec's flag list.
  - On non-TTY stdout, the owner sign-in link is withheld from the log (`github/open.mjs:62-70`: "is not printed to this non-interactive output ... re-run ... with --sign-in"). P4's "you open the owner sign-in link" then depends on `xdg-open` working (see B3 and M12).
- **Result.** T6 and T10 would file harness limits as cairn gaps, and T10 can't reach its own acceptance.
- **Options:**
  - (a) The builder hands each interactive setup run to Geoff as an exact command to run in Ptyxis, the newcomer's own terminal. This becomes a P4 or T10 set point.
  - (b) `cleanroom-run` gives the builder a pty, for example `script -qfc` or a tmux pane Geoff can watch. T1 has to prove that `@clack/prompts` and the hold console work there.
  - (c) The builder uses only the flag path, and every TTY-only step is recorded as "agent-driven setup can't finish" rather than counted as a cairn defect.
- **Recommendation:** (a). It's what a real newcomer does, and it moves the unproven pty mechanics off the critical path. Name each `--yes` or interactive run and its flags at T6 and T10.

### B2. `secret-get` doesn't exist, and P2's token lacks the Builds permission
- **Severity:** blocker. **Tag:** correctness.
- **Where:** P:17, P:27, P:137; S:134, S:145.
- **Defect 1.** `command -v secret-get` finds nothing, and no file in `~/.dotfiles` or `~/.claude` names it. `secret-receive` writes to the age store and `~/.local/secrets`, so any read is a sourced-secret read, which auto mode refuses (pass-core "Pre-flight and owner-only steps").
- **Defect 2.** P2 lists five permission rows. The Builds chapter and `--connect` ask for six: `CHAPTER3_PERMISSION_KEYS = [...PREFILL_PERMISSION_KEYS, workers_ci]` (`prefill.mjs:83,91`). A domain chapter run on a Builds-connected site asks for six as well (`chapter2.mjs:676`). So the P2 token fails at `--connect`.
- **Defect 3.** The fallback `cleanroom-run --resume <id> --env-from-store` is not a pre-flight `[you]` item with an exact command. The `<id>` can't be known before the run, and T1's outcome doesn't list `--env-from-store` as a feature.
- **Fold:**
  - P2 creates the six-key token from the `CHAPTER3_PERMISSION_KEYS` prefill URL and checks six rows.
  - The token reaches the builder only through a Geoff-run launch: a pre-flight `[you]` item with the full command, `cleanroom-run --builder B --resume-file ~/Projects/cleanroom/logs/B.session --env-from-store CAIRN_CF_API_TOKEN`, where the session id is read from the file T1 writes.
  - Alternatively, prove a harness that sources its own secrets.
  - T1 builds `--env-from-store` and its store read for real.

### B3. The Bash sandbox blocks what setup needs, and running setup outside it reads Geoff's real state
- **Severity:** blocker. **Tag:** correctness.
- **Where:** S:22-24; P:65, P:117.
- **Defect.** The sandboxing docs, quoted:
  - "Linux and WSL2: a sandboxed command's `localhost` is private to that command ... A direct connection to `localhost` ... doesn't reach servers on the host." That breaks the GitHub manifest and install callbacks (`github/loopback.mjs`) and `wrangler login`'s callback.
  - "Anything that isn't TCP: UDP ... can't leave the sandbox." Setup's DNS checks query authoritative servers directly (`dns.mjs:14,31-32`, `Resolver.setServers`).
  - "Chromium exits with `No usable sandbox!`" That breaks any browser that `xdg-open` starts from inside the sandbox.
  - Default write scope is "the current working directory, the per-user temp directory". Setup writes its record to `homedir()/.config/cairn/sites` (`state.mjs:27`, which ignores `XDG_CONFIG_HOME`), npm writes `~/.npm`, and the sandbox's `denyRead` covers `~/.config/**`. T7's local `create-cairn-site --yes` also writes that record.
- **Second defect.** Once setup runs unsandboxed through `excludedCommands` ("no filesystem restrictions"), it reads and writes Geoff's real `~/.config/cairn/sites`, which today holds `cairn-rc2-install-91f0d5.json`.
- **Fold:**
  - Make the exclusion the stated configuration, not a fallback: `excludedCommands` for `npx create-cairn-site *` and `npx wrangler *`.
  - Give the builder a clean `HOME` (or at minimum `CAIRN_STATE_DIR`, though that's a test seam the docs don't publish). A clean HOME makes setup state, wrangler, gh, and npm start clean. Rewrite every deny rule with absolute `//var/home/glw907/...` paths, since `~` would follow the new HOME.
  - Add `sandbox.filesystem.allowWrite` for the npm cache.
  - T1 proves each piece: a matched exclusion on the compound command forms a builder writes (`cd x && npx create-cairn-site ...`), a loopback callback reached from the host browser, and `node -e "fetch('https://api.github.com')"` inside the sandbox. Node's built-in fetch ignores the proxy variables unless `NODE_USE_ENV_PROXY` is set; I haven't probed that.
  - Record every unsandboxed command in the PR.

### B4. Auto mode's default block list covers setup's whole job, and drops `Bash(npx *)`
- **Severity:** blocker. **Tag:** correctness.
- **Where:** S:29; P:65.
- **Defect.** The permission-modes docs list these as blocked by default: "Production deploys and migrations", "Granting IAM or repo permissions" (the App setup creates asks for Administration), "Modifying shared infrastructure" (the Workers Builds registration), and "changing DNS records". They also say: "On entering auto mode, broad allow rules that grant arbitrary code execution are dropped: ... Package-manager run commands." In `-p` mode, "When repeated blocks reach a threshold, the action doesn't run and Claude keeps working". So a blocked builder improvises instead of stopping.
- **Fold:** make `dontAsk` plus narrow allow rules the primary mode. It's deterministic, and the spec's list already exists at S:29. Add `Bash(npx create-cairn-site *)` and `Bash(npx wrangler *)` explicitly. Keep auto mode only if T1 runs `npx create-cairn-site --dry-run --github --deploy --domain 907.life --yes` in a real builder session and the classifier passes it. Record the choice in `## Decisions`.

### B5. Geoff's `~/.claude/CLAUDE.md` may load as an ancestor project file
- **Severity:** blocker. It voids the test premise if true. **Tag:** correctness.
- **Where:** S:11; P:68.
- **Defect.** The memory docs say Claude Code reads "a `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` in your working directory or any directory above it, other than your `~/.claude/CLAUDE.md`". `/var/home/glw907` is an ancestor of `~/Projects/cleanroom`, and `/var/home/glw907/.claude/CLAUDE.md` exists. Once `CLAUDE_CONFIG_DIR` moves the user file, whether that exclusion still matches the literal `~/.claude/CLAUDE.md` is undocumented. The Read deny rule doesn't stop the memory loader, and T1 checks only the skill list.
- **Fold:**
  - Add `"claudeMdExcludes": ["/var/home/glw907/.claude/**"]` to the clean settings. The docs show it matches absolute globs at any settings layer.
  - T1 adds a canary: the probe is asked whether its context contains "Geoff has no smartphone" (from the global CLAUDE.md), and the check fails on yes.
  - T1 also checks the init event for ancestor `.claude/rules` and skills.

## Major

### M1. The design and the spec disagree on `_dmarc`
- **Severity:** major. **Tag:** correctness. **OWNER FORK** (the design packet is pending).
- **Where:** D:37 versus S:137 and P:138.
- **Defect.** The design's approved Decide says setup sets `p=reject`, and the servers PR declares it. The spec and plan require `_dmarc` to stay unchanged at `p=none`, and on a change they restore it by API. That reverts the write the owner approved. Setup's own message claims the write unconditionally (`chapter2.mjs:1064`: "Onboarding also wrote a p=reject DMARC policy"), while Cloudflare's docs say an existing record is kept.
- **Fold:** T10 handles both outcomes.
  - **Unchanged:** pass, and file a backlog item that setup's message is false for a domain that already has a DMARC record.
  - **Changed to `p=reject`:** accept it per the Decide, and T11 declares it.
- **Fork:** Geoff picks either "keep `p=none`, restore" or "accept `p=reject` per the Decide". Recommendation: the Decide as approved, with no restore.

### M2. The retirement inventory misses live credential channels and a secret-name collision
- **Severity:** major. **Tag:** correctness.
- **Where:** P:96-103; S:118-127.
- **Defect 1: secret collision.** `~/.dotfiles/scripts/secrets/sync.sh:45` has `WORKER_SECRETS["907-life"]="CLOUDFLARE_API_TOKEN RESEND_API_KEY GITHUB_APP_ID GITHUB_APP_INSTALLATION_ID GITHUB_APP_PRIVATE_KEY_B64"`. The new Worker has the same name, and setup uploads its own App key as `GITHUB_APP_PRIVATE_KEY_B64`. The next routine `sync.sh` run would overwrite the new site's App key with the shared App's key, breaking commits, and would put the broad all-zones token into the new site's Worker.
- **Defect 2: Actions secret.** The old repo's Actions secret `CLOUDFLARE_API_TOKEN` is the broad `ws-admin` token. The estate inventory lists 907-life among the rotation targets, and archiving the repo leaves the secret in place.
- **Defect 3: build token.** The `registry.md` note says the "xcathletes build token ... backs both `907-life` triggers". That registration is not `cairn-build`, and the inventory doesn't name it.
- **Fold:** T4's inventory adds:
  - the `sync.sh` and `registry.md` rows, removed through a dotfiles PR before T6;
  - deletion of the Actions secret before the archive;
  - the estate-inventory edit;
  - a verdict on the 907-life build-token registration.
- Run every renamed name through a grep of `~/.dotfiles`, `servers`, and `cairn-cms`. My grep found these two plus a design review doc in `cairn-cms/tool`.

### M3. Owner-only steps hidden in tasks
- **Severity:** major. **Tag:** correctness.
- **Where:** S:30, S:153; P:113, P:117, P:137-138, P:41, P:27.
- **The steps:**
  - `gh auth login` in the clean room, for both builders: builder A's PR on Survey and builder B's pushes. The spec says it "joins Geoff's setup sitting", but no P item carries it.
  - Authorizing Cloudflare's "Workers and Pages" GitHub App for the new repo. Its repo id differs from the renamed old repo's.
  - The Builds sign-in click.
  - Reading the sign-in mail in Geoff's mailbox (T10).
  - "Geoff confirms" `/admin` (T6).
  - The end-to-end admin edit and publish (S:153). No task or P item runs it.
  - The `teardown.sh` and `--env-from-store` fallbacks, which sit in tasks, not in pre-flight.
  - Revoking the setup token at close. Setup deletes only its own copy (README, Status), and the broad token has no API-token management ("API-token management ✗"), so it's a dashboard step.
- **Fold:** list each one in Pre-flight with its check. Move `gh auth login` into P1. Put the mail read and the end-to-end edit in P5, read on the live URL.

### M4. Observer writes that auto mode may refuse
- **Severity:** major. **Tag:** correctness.
- **Where:** P:24, P:41; S:42, S:137; P:153.
- **The writes:**
  - T1's clean `settings.json`, and event 2's mid-run rule widening. These edit another agent's permissions, and the classifier routes protected paths to itself.
  - T5's R2 deletes ("Mass deletion on cloud storage"), plus the rename and archive. `teardown.sh` covers only "a delete".
  - The DNS restore ("changing DNS records" is on the default block list).
  - Survey's `scripts/release`.
- **Fold:**
  - Make T5 a `[you]` run of a reviewed `teardown.sh` from the start, carried in the P3 packet. It's cheaper than probing.
  - Prepare any DNS restore as a `[you]` script built from `dns-before.json`.
  - T1 proves that the observer's settings writes pass in the observer's own session type. If they don't, rule widening becomes `[you]`.

### M5. R2 mechanics: no list command, and the bucket must be empty before delete
- **Severity:** major. **Tag:** correctness.
- **Where:** P:87, P:99, P:107.
- **Defect.** `wrangler r2 object --help`, at both 4.107.0 and 4.158.0, offers only get, put, and delete. There is no listing, so T2's count check can't run as written. Cloudflare's R2 docs say "To delete a bucket, you must first empty it and then delete it."
- **Fold:** T2 counts and copies objects through a named, probed method, such as the R2 S3 API with rclone or the API's list-objects endpoint. T5 empties the bucket before deleting it and verifies an empty listing.

### M6. T5's repo check probably fails on a correct teardown
- **Severity:** major. **Tag:** correctness.
- **Where:** P:108.
- **Defect.** GitHub's docs: after a rename "all existing information ... is automatically redirected to the new name", and git operations on the old name keep working. So `gh repo view glw907/907-life` may resolve to `907-life-legacy` instead of failing. I didn't do a live rename.
- **Fold:** check `gh api repos/glw907/907-life-legacy --jq '.name,.archived'` for the new name and `true`, and accept a redirect on the old name. Or probe once on a throwaway repo. Note that setup creating `glw907/907-life` ends the redirect.

### M7. The zone is shared, so "any change fails" plus an auto-restore can revert another session's work
- **Severity:** major. **Tag:** correctness.
- **Where:** S:137; P:138, P:143.
- **Defect.** Other sessions write 907.life (conductor-servers, `dns.sh --apply`, phonebook, mta-sts). T5 also removes the apex record, through the old Worker's `custom_domain` route in `wrangler.toml`. That happens before the snapshot, which is fine, but the plan doesn't name it.
- **Fold:** T10 opens a zone-write freeze with conductor-servers for its window. A changed record is checked against servers' git log before anyone acts. The rerun rule is to re-snapshot and re-diff once. Use `dns.sh` declarations, not a raw restore.

### M8. A `--yes` run at T6 runs the Builds chapter too
- **Severity:** major. **Tag:** correctness.
- **Where:** P:112-113.
- **Defect.** The README says "`--yes` alone consents to this one". At T6 no setup token exists, so `ensureApiToken` throws "set CAIRN_CF_API_TOKEN" (`prefill.mjs:325-329`). "Setup exits 0" may then be false. If Builds does connect at T6, T10's domain and email chapters take the post-Builds commit path (B1).
- **Fold:** trace or probe T6's exit under `--yes --github --deploy --owner-email` with no token. State the expected exit and park in T6's acceptance. Then fix T10's order to match the outcome.

### M9. No bound on the outage, and no rule for which tasks run once the ceiling or bar is lost
- **Severity:** major. **Tag:** correctness. **OWNER FORK.**
- **Where:** P:33, P:40; S:143; D:15.
- **Defect.** After T5, a blocking engine defect leaves 907.life dark "with no time limit". The ceiling stop doesn't say which cleanup still runs: T11 must run if T10 wrote DNS, and the token revocation must run regardless.
- **Fold:** after the ceiling or an unreachable bar, T11 and the revocation still run, then the run closes and reports the bar unmet.
- **Fork:**
  - (a) Accept an unbounded outage.
  - (b) Set a bound, such as 48 hours dark, after which the observer brings it to Geoff.
  - Recommendation: (b).

### M10. The `claude -p` probe items are missing
- **Severity:** major. **Tag:** correctness.
- **Where:** P:63-75; S:34-35, S:44.
- **Defect.** T1 doesn't record:
  - how a denied compound command is classified;
  - background subagents (anthropics/claude-code#73453 is closed, CLI 2.1.319 installed, but nothing is stated);
  - Bash timeouts. `BASH_MAX_TIMEOUT_MS` defaults to 600000, the same as setup's ten-minute loopback wait (`github/loopback.mjs:17`). A setup run longer than ten minutes gets killed mid-chapter.
  - one session's measured length, which the estimates should be derived from.
- Event 4 also treats any final result as "Done". A `-p` builder that stops with a question or half-finished needs its own event and answer.
- **Fold:**
  - T1 records each of these items.
  - Set `BASH_DEFAULT_TIMEOUT_MS` and `BASH_MAX_TIMEOUT_MS` in the clean settings' `env`, for example 1800000.
  - Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` only if the probe shows a background exit.
  - Add event 5: a non-final result gets a follow-up from the design.

### M11. Claude.ai connectors have a documented switch
- **Severity:** major. **Tag:** correctness.
- **Where:** S:15.
- **Defect.** The mcp docs give `"disableClaudeAiConnectors": true` ("any-source-true semantics") and `ENABLE_CLAUDEAI_MCP_SERVERS=false`. Geoff's connectors include a Cloudflare MCP with account read access, which breaks isolation.
- **Fold:** set the switch in the clean settings now. T1 checks that `mcp_servers` in `system/init` is empty, and fails otherwise.

### M12. The browser path is undefined, and builder screenshots need a working browser
- **Severity:** major. **Tag:** correctness.
- **Where:** P:19, P:117; S:41.
- **Defect.** `openBrowser` runs `xdg-open` (`github/open.mjs:27`). With `XDG_CONFIG_HOME` or HOME overridden, GNOME's default-browser lookup and Chromium's profile directory both move, so a tab may open in a fresh, signed-out profile or another browser. From inside the sandbox it fails outright. T7's light and dark screenshots need a headless browser started with `--no-sandbox`, plus its download hosts on the allow list.
- **Fold:** T1 runs `xdg-open https://example.com` under the builder's environment and records which browser opens. P4 says Geoff opens each printed URL in his own Chromium, and the sign-in link comes through `--sign-in` from a terminal (B1). T1 also takes one headless screenshot from the sandbox.

## Minor

1. **The Read exemption can't work as written.** S:22, minor, correctness. The permissions docs: "Rules are evaluated in order: deny, then ask, then allow." The docs do support a gitignore negation inside `deny`, `Read(!...)` listed after the broad rule (permissions page, "gitignore negation"). Fold: use `Read(//var/home/glw907/Projects/*/**)` followed by `Read(!//var/home/glw907/Projects/cleanroom/**)`, and drop the fallback.
2. **T3's grep fails on the current content.** P:94, minor, correctness. `src/content/posts/2026-04-06-understanding-epoll.md:62` contains "internal", and the grep covers `handoff/content`. Fold: grep only the two briefs, or drop `internal`.
3. **T7's grep passes vacuously when the folder is missing.** P:118, minor, correctness. On a missing folder, `grep -rn '!important' cairn-theme/` prints nothing to stdout. Fold: assert the folder exists and has files, and require grep's exit code 1.
4. **T8's warnings bar has no baseline.** P:124, minor, correctness. "0 warnings" may fail on the bare scaffold. Fold: record the scaffold's `npm run check` result at T6 as the baseline.
5. **The audit may need a build step first.** P:118, P:133, minor, correctness. The template runs `npm run build:admin-css && cairn-audit` (`templates/waymark/package.json:21`). Fold: run `npm run check:cairn`, or name the build step.
6. **No branch model.** P:147, minor, correctness. The plan doesn't say whether builder B works on `main` or a branch, or who merges. Accepted-task reports name only local checks, not the CI verdict on that head. Fold: state both.
7. **T13's move breaks worktrees.** P:156, minor, correctness. `~/Projects/907-life` holds three worktrees under `.claude/worktrees`, all clean and level with `main`, and the observer's own session may have that directory as its working directory. Fold: remove the worktrees first and check `pgrep` for sessions there.
8. **No host named.** P:16, minor, optional. The run's host isn't stated; S:13 implies pavilion. Fold: name pavilion, and say thinkpad gets nothing.
9. **P2's wording is wrong.** P:17, minor, correctness. "Setup deletes the token" means setup deletes its own copy; the token stays live in Cloudflare and the store. Fold: per M3.
10. **The token can reach the logs.** S:34, minor, correctness. A builder that echoes the environment writes the all-zones token into a plain-text `.jsonl`. Fold: grep the logs for the token's prefix at close, and delete the logs after the archive.
11. **No answer for usage limits.** P:40, minor, correctness. Two builders and the observer share one subscription, and there's no standing answer for hitting the usage limit. Fold: wait for the reset and resume by session id.
12. **No closing docs gate.** P:150-157, minor, correctness. T13 writes STATUS, BACKLOG, and architecture docs, but no docs gate reruns after the last edit. Fold: add the gate.
13. **The command deny rules aren't a boundary.** S:25, minor, optional. The permissions docs say a deny rule "isn't a security boundary around the program". Fold: describe them as tripwires, not isolation.
14. **The D1 delete doesn't free a name.** S:122, minor, optional. Setup names the database `907-life-auth` (`config.mjs:109`), so deleting `cairn-907-auth` is retirement. Only the Worker and `907-life-media` clash.
15. **P5 runs a check before its task.** P:20, minor, correctness. P5 runs `dns.sh --check` at T12, but T11 runs after T10, which waits on the T12 packet. Fold: move that check to T11's acceptance.
16. **The live publish check has no wait.** S:153, minor, correctness. The edit-and-publish check names no wait for the Builds deploy. Fold: poll the live URL for up to 5 minutes.

## Over-ceremony

- **T12's whole-repo review.** P:147, minor, optional. Reviewing the whole repo "from setup's first commit" puts the stock scaffold through `standards:diff-reviewer`. That costs tokens for code no builder wrote. Fold: review from the commit after setup's first.

## Checklist items that pass

- The risk class fits.
- Each task has a minute estimate.
- The ceiling has a standing answer.
- The workspace trust prompt is P1.
- The Survey tag `v1.5.2`, `scripts/release`, specimen `c19e7ac`, and the `cairn-audit` rule ids all exist.

## Relevant paths

- /var/home/glw907/Projects/initiatives/.claude/worktrees/907-rebuild-design/907-rebuild/plans/2026-11-07-907-rebuild-plan.md
- /var/home/glw907/Projects/initiatives/.claude/worktrees/907-rebuild-design/907-rebuild/specs/2026-11-07-907-rebuild-spec.md
- /var/home/glw907/Projects/initiatives/.claude/worktrees/907-rebuild-design/907-rebuild/specs/2026-11-07-907-rebuild-design.md
- /var/home/glw907/Projects/cairn-cms/packages/create-cairn-site/src/state.mjs
- /var/home/glw907/Projects/cairn-cms/packages/create-cairn-site/src/cloudflare/prefill.mjs
- /var/home/glw907/Projects/cairn-cms/packages/create-cairn-site/src/github/open.mjs
- /var/home/glw907/Projects/cairn-cms/packages/create-cairn-site/src/cloudflare/dns.mjs
- /var/home/glw907/.dotfiles/scripts/secrets/sync.sh
- /var/home/glw907/.dotfiles/secrets/registry.md
- /var/home/glw907/Projects/907-life/wrangler.toml

