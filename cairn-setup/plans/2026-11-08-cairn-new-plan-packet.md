# The cairn new build plan

The cairn-setup initiative replaces the create-cairn-site wizard with `cairn new`, the Go setup command whose design you approved today. The planner has now written the build plan and a spec, and three reviewers read both. Planning found five places where the design described existing code wrongly, most of them in the sign-in and deploy steps. You also asked for the passes to run without a break. Both need your rulings before the build starts.

The plan builds `cairn new` in seven passes: the setup engine and provider writes, the agent lane, the terminal screens, the starter content, the docs and Claude Code plugin, the switch from the old wizard, and markdown copies on cairn.pub. The longest chain is 3,465 minutes against a 3,685-minute estimate. You rule on eleven points in three questions below, and the session recommends yes to all of them. Two change what an owner sees: one Sign in click at the end of setup, and setup sending the sign-in email itself. One lets the run go through every pass without waiting on you, with the conductor merging each pass once its gates pass and sending you a record packet.

Approving launches the build under `conductor-cairn-cms`. Before that, you create the Cloudflare OAuth client and run one settings script. During P1 you hold a 30-minute recording session when the conductor calls you; the run goes on while it waits. Nothing publishes in this initiative, so your read of each merged pass still comes before any owner runs the code. The plan also adds one checklist line to the plan reviewer (PR 11).

## If you approve
1. [session] Write your eleven rulings into the plan's `Ruled:` lines, commit, and push the initiatives repo.
2. [you: create the Cloudflare OAuth client] In the Cloudflare dashboard on your account, open Manage account > OAuth clients and create a client named `cairn`. Make it a public client (no secret) with grant type authorization code and PKCE, and redirect URI `http://127.0.0.1:49152/cloudflare/callback`. Leave it private. Tick these scopes (the dashboard says "Edit" where these names say "write"): `user-details.read`, `account-settings.read`, `zone.read`, `zone.write`, `dns.write`, `workers-scripts.edit`, `workers-routes.write`, `d1.write`, `workers-r2.write`, `email-sending.write`, `workers-ci.write`, `user-api-tokens.write`, `offline_access`. Paste only the client id into `~/Projects/initiatives/cairn-setup/research/cloudflare-oauth-client-id.txt`. The session checks that it is 32 hex characters.
3. [you: add the settings grant] Read and run `python3 -I ~/Projects/initiatives/cairn-setup/research/add-cairn-setup-grant.py`. It adds two `autoMode.allow` lines: the executors' writes to the plan's skill and plugin files, and the conductor's merges of P1, P2, P5, and P6. Add `--no-merge` if you answer no on running unbroken. Then run `git -C ~/.dotfiles commit -m "Allow the cairn-setup passes their writes and merges" -- claude/.claude/settings.json`. The session tried to write these lines itself, and auto mode refused it as self-modification.
4. [session] Open a dotfiles PR with your grant commit and the unpushed test-accounts commit. It rides in a record packet and holds nothing.
5. [session] Land the backlog and ROADMAP edits on cairn-cms `main` as one direct change.
6. [session] Run the auto-mode probe from the plan's pre-flight item 8. Any refusal comes back to you as a new grant before launch.
7. [session] Merge glw907/standards#11.
8. [session] Commit the conductor prompt and hand the plan to `conductor-cairn-cms`, which launches P1.
9. [you: accept workspace trust if asked] Only if a launch prints "Workspace not trusted": run `claude` once in `~/Projects/cairn-cms` and accept the prompt.
10. [you: hold recording session S1] When the conductor's notification arrives, about four hours into P1, run the `record.sh` command it names in your terminal. It takes about 30 minutes. You click one Cloudflare Allow and tick API Tokens: Write, and it drives GitHub as `glw907-test` by itself. Read the cleanup lines in its results file. If a revoke line failed, remove that grant in the dashboard. After a crash, run the `--cleanup <run id>` command it prints. The test-account secrets it needs are already in place.

## Not checked
The loopback port 49152 has not been tried with Cloudflare; the spike used 8765, and S1 proves the new port. Cloudflare's revoke endpoint answered 403 in the spike, and S1 probes it again. The 3,685-minute estimate comes from five past PRs' actual-to-planned ratio, not a probe.

## Ask: How should the owner's first sign-in work?
Rule: owner-call
Part: none
Recommended: 1
Reason: Both changes keep the engine's sign-in code unchanged and give the owner a link that works whenever they read their mail.
Summary: The design assumed setup's tab could sign the owner in directly and the site's ordinary email would follow. In fact the confirm page needs one Sign in click, and an email the site sends on setup's behalf is tied to setup's browser, so it fails when the owner opens it later.

Background: The site signs people in with an emailed link. The engine ties each link to the browser that asked for it, so a link setup requests works only in setup's browser tab. The owner's own browser can use it only by asking for a link there within 60 seconds. The confirm page also waits for a Sign in click before it uses the link, as a guard against mail scanners that open links. This covers Decides 1 and 2 in the plan.

Facts: The confirm page uses nothing until a click, and links are bound to the requesting browser.
- The confirm GET "consumes nothing; only the POST" signs in (`cairn-cms:src/lib/sveltekit/auth-routes.ts:341`)
- A link is bound to the requesting browser's nonce and rebinds only on a same-browser request (`cairn-cms:src/lib/sveltekit/auth-routes.ts:271-297`)
- The rebind window is 60 seconds (`cairn-cms:src/lib/auth/crypto.ts:74`)
- An unbound link, as the bootstrap writes, works in any browser (`cairn-cms:src/lib/sveltekit/auth-routes.ts:380`)

Choices:
- One click and an email from setup: the done tab shows the confirm page with one Sign in click, and setup sends the owner an unbound link by Cloudflare Email Sending, valid 10 minutes, with a line on requesting a fresh one
- One click and no email: the done tab still takes one click, setup sends no email, and an owner who closes the tab asks for a link on the sign-in page
- Change the engine: a one-click confirm GET, which the design ruled out and which reopens the mail-scanner risk

## Ask: May the conductor merge each pass itself so the run never waits on you?
Rule: owner-call
Part: none
Recommended: 1
Reason: You asked for an unbroken run, every merge still passes CI and the reviews, and nothing reaches an owner before you have read it.
Summary: As planned, the run stops five times for you: the recording session, and a packet after each of P1, P2, P5, and P6 that holds the next pass. The session proposes the conductor merges once every gate passes and sends you each packet as a record, as the 1 November cairn run sheet did.

Background: P1 and P6 touch sign-in and secrets (`auth-data`), and P2 and P5 change skills and gates (`runner`). Under the pass process each goes to you before it merges, and the next pass starts from the merged code. This is Decide 11 in the plan. The gates the conductor needs on the PR's head are: CI green, the whole-branch review folded with no open finding, the docs gate green, and for P1 and P6 the security review folded and the live admin smoke passed. A record packet you send back becomes a fix-forward PR, never a revert. The run still stops for a finding that would change the design, an `escalate` verdict, a cause it can't trace, or a chain past 7,370 minutes, twice the estimate.

Facts: No code from this run reaches an owner before a release, and no release can be cut until the tooling gates exist.
- No pass bumps a version or publishes (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)
- `cairn new` stays a hidden command until P6, so a mid-run release ships no setup surface (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)
- The same merge grant ran the agent-first cairn run (`~/.dotfiles/claude/.claude/settings.json`)
- S1 no longer holds the run: P1 builds on documented API bodies and swaps in the recordings when they land (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)

Choices:
- Run unbroken: the conductor merges each pass behind its gates, you read record packets as they come, and the run waits on you only for a design change
- Keep the per-pass packets: each of P1, P2, P5, and P6 waits for your approval before the next pass starts

## Ask: Approve the plan with its other eight rulings?
Rule: owner-call
Part: glw907/initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md
Recommended: 1
Reason: Each ruling follows from code the planner read, and the plan stays inside its estimate with all eight.
Summary: Eight smaller rulings remain: let the deploy App read its runs, widen the cairn.pub pass, keep main releasable mid-build, raise three setup tasks to auth-data, show Waymark's description, handle a taken App name, let an owner start a second site, and fix `cairn health` for Actions deploys. The session recommends yes to each.

Background: The plan proposes a call on each of Decides 3 to 10. Decide 3: add `actions: read` to the per-site GitHub App, so setup can read the first deploy's result; the owner's consent page lists one more read permission (yes). Decide 4: widen P7 to port cairn.pub's docs loader and move its pin to 0.99.0-rc.4 (yes). Decide 5: keep `main` releasable between P1 and P6 by holding back setup's docs until P5 (yes). Decide 6: raise three setup tasks to `auth-data` (yes). Decide 7: show Waymark's one-line description on the summary (yes). Decide 8: on a taken App name, the owner edits it on GitHub's Create page (yes). Decide 9: always offer "Start a new site" over a resume, and list what a stuck run holds (yes). Decide 10: fix `cairn health` for Actions-deployed sites in P2 (yes).

Facts: Each ruling answers a gap the planner found in code.
- Decide 3: the design's App has no Actions permission, and a private repository's runs need `actions: read`, so without it every first-deploy failure reads as one generic timeout (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-spec.md`)
- Decide 4: cairn.pub pins 0.94.0-rc.1 and reads a docs layout the engine removed, so P7 grows from 195 to 375 minutes (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-spec.md`)
- Decide 5: without the hold, a release mid-build ships setup docs for a hidden command (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)
- Decide 6: only `tool/internal/secrets/**` is `auth-data` in the tool, so the loopback, approval chain, and sign-in rows get no failing-test-first rule; only you can raise a class (`cairn-cms:.claude/skills/cairn-running-passes/SKILL.md`)
- Decide 7: the design names the description and the copy deck omits it (`initiatives:cairn-setup/research/copy-deck-final.md`)
- Decide 8: App names are unique across GitHub and capped at 34 characters (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-spec.md`)
- Decide 9: with one unfinished run, the design always resumes it, so a second site needs a hand-deleted record (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-design.md`)
- Decide 10: the health check reads only Workers Builds triggers, so every new site reads UNKNOWN (`cairn-cms:tool/internal/health/check_deploy.go:189-193`)

Choices:
- Approve all eight: the plan builds each recommendation and launches after your steps [approve]
- Send back: name in your note each ruling to change, and the session revises the plan and resends [send-back]

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/standards#11 | approve | Adds one plan-reviewer line asking for the source line behind each asserted mechanism; its check passes. | It is this plan's planning-miss fix. |
| step:1 | session | A commit can be reverted. | It records your rulings. |
| step:5 | session | The edits are the sweep's verdicts, which approving the plan approves. | A direct change on `main`. |
| step:8 | session | The conductor launches only after every pre-flight check passes. | The plan's launch order. |
