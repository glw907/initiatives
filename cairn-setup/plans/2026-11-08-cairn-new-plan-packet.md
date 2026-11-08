# The cairn new build plan

The cairn-setup initiative replaces the create-cairn-site wizard with `cairn new`, the Go setup command whose design you approved today. The planner has now written the build plan and a spec, and three reviewers read both. Planning found five places where the design described existing code wrongly, most of them in the sign-in and deploy steps. Each one became a ruling that needs you before the build starts.

The plan builds `cairn new` in seven passes: the setup engine and provider writes, the agent lane, the terminal screens, the starter content, the docs and Claude Code plugin, the switch from the old wizard, and markdown copies on cairn.pub. The longest chain is 3,465 minutes against a 3,685-minute estimate. You rule on ten points in three questions below, and the session recommends yes to all ten. Two are design changes an owner will see: one extra Sign in click at the end of setup, and setup sending the sign-in email itself.

Approving launches the build under `conductor-cairn-cms`. Before that, you do three things: you create the Cloudflare OAuth client, add one settings line, and later hold a 30-minute recording sitting when the conductor calls you. Packets come back to you after P1, P2, P5, and P6. The plan also adds one checklist line to the plan reviewer (PR 11).

## If you approve
1. [session] Write your ten rulings into the plan's `Ruled:` lines, commit, and push the initiatives repo.
2. [you: create the Cloudflare OAuth client] In the Cloudflare dashboard on your account, open Manage account > OAuth clients and create a client named `cairn`. Make it a public client (no secret) with grant type authorization code and PKCE, and redirect URI `http://127.0.0.1:49152/cloudflare/callback`. Leave it private. Tick these scopes (the dashboard says "Edit" where these names say "write"): `user-details.read`, `account-settings.read`, `zone.read`, `zone.write`, `dns.write`, `workers-scripts.edit`, `workers-routes.write`, `d1.write`, `workers-r2.write`, `email-sending.write`, `workers-ci.write`, `user-api-tokens.write`, `offline_access`. Paste only the client id into `~/Projects/initiatives/cairn-setup/research/cloudflare-oauth-client-id.txt`. The session checks that it is 32 hex characters.
3. [you: add the settings grant] Read and run `python3 -I /tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/3d778db3-3ae2-4251-b022-407d8b8c784f/scratchpad/add-cairn-setup-grant.py`. It adds the `cairn-setup-passes` line to `autoMode.allow` and prints "added cairn-setup-passes". Then run `git -C ~/.dotfiles commit -m "Allow the cairn-setup passes their .claude writes" -- claude/.claude/settings.json`. The session asked to write this line itself, and auto mode refused it as self-modification.
4. [session] Open a dotfiles PR with your grant commit and the unpushed test-accounts commit, for your next packet.
5. [session] Land the backlog and ROADMAP edits on cairn-cms `main` as one direct change.
6. [session] Run the auto-mode probe from the plan's pre-flight item 8. Any refusal comes back to you as a new grant before launch.
7. [session] Merge glw907/standards#11.
8. [session] Commit the conductor prompt and hand the plan to `conductor-cairn-cms`, which launches P1.
9. [you: accept workspace trust if asked] Only if a launch prints "Workspace not trusted": run `claude` once in `~/Projects/cairn-cms` and accept the prompt.
10. [you: hold recording sitting S1] When the conductor's notification arrives after P1's first task, run the `record.sh` command it names in your terminal. It takes about 30 minutes. You click one Cloudflare Allow and tick API Tokens: Write, and it drives GitHub as `glw907-test` by itself. Read the cleanup lines in its results file. If a revoke line failed, remove that grant in the dashboard. After a crash, run the `--cleanup <run id>` command it prints. The test-account secrets it needs are already in place.

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

## Ask: May the deploy App read its repository's Actions runs?
Rule: owner-call
Part: none
Recommended: 1
Reason: Without it setup cannot tell a failed first deploy from a slow one, and it would guess at the cause.
Summary: The design gave the per-site GitHub App no Actions permission. A private repository's deploy runs can't be read without `actions: read`, so setup would only see whether the Worker appears before a timeout.

Background: Each site gets a GitHub App of its own, which the owner approves on GitHub's consent page. Its permissions show there. The first deploy runs in GitHub Actions, and setup watches for it in step 6. This is Decide 3 in the plan. The admin still shows no deploy status either way.

Facts: Setup can read a run's result only with `actions: read`.
- The design's App asks for no Actions permission (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-design.md`)
- A private repository's runs need `actions: read` to list (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-spec.md`)

Choices:
- Add read access to runs: the consent page lists one more read permission, and a failed first deploy shows its real cause and a link to the run
- Keep the App as designed: setup waits for the Worker up to a timeout, and every failure reads as one generic first-deploy message

## Ask: Approve the plan with its other seven rulings?
Rule: owner-call
Part: glw907/initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md
Recommended: 1
Reason: Each ruling follows from code the planner read, and the plan stays inside its estimate with all seven.
Summary: Seven smaller rulings remain: widen the cairn.pub pass, keep main releasable mid-build, raise three setup tasks to auth-data, show Waymark's description, handle a taken App name, let an owner start a second site, and fix `cairn health` for Actions deploys. The session recommends yes to each.

Background: The plan proposes a call on each of Decides 4 to 10. Decide 4: widen P7 to port cairn.pub's docs loader and move its pin to 0.99.0-rc.4 (yes). Decide 5: keep `main` releasable between P1 and P6 by holding back setup's docs until P5 (yes). Decide 6: raise three setup tasks to `auth-data` (yes). Decide 7: show Waymark's one-line description on the summary (yes). Decide 8: on a taken App name, the owner edits it on GitHub's Create page (yes). Decide 9: always offer "Start a new site" over a resume, and list what a stuck run holds (yes). Decide 10: fix `cairn health` for Actions-deployed sites in P2 (yes).

Facts: Each ruling answers a gap the planner found in code.
- Decide 4: cairn.pub pins 0.94.0-rc.1 and reads a docs layout the engine removed, so P7 grows from 195 to 375 minutes (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-spec.md`)
- Decide 5: without the hold, a release mid-build ships setup docs for a hidden command (`initiatives:cairn-setup/plans/2026-11-08-cairn-new-plan.md`)
- Decide 6: only `tool/internal/secrets/**` is `auth-data` in the tool, so the loopback, approval chain, and sign-in rows get no failing-test-first rule; only you can raise a class (`cairn-cms:.claude/skills/cairn-running-passes/SKILL.md`)
- Decide 7: the design names the description and the copy deck omits it (`initiatives:cairn-setup/research/copy-deck-final.md`)
- Decide 8: App names are unique across GitHub and capped at 34 characters (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-spec.md`)
- Decide 9: with one unfinished run, the design always resumes it, so a second site needs a hand-deleted record (`initiatives:cairn-setup/specs/2026-11-08-cairn-new-design.md`)
- Decide 10: the health check reads only Workers Builds triggers, so every new site reads UNKNOWN (`cairn-cms:tool/internal/health/check_deploy.go:189-193`)

Choices:
- Approve all seven: the plan builds each recommendation and launches after your steps [approve]
- Send back: name in your note each ruling to change, and the session revises the plan and resends [send-back]

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/standards#11 | approve | Adds one plan-reviewer line asking for the source line behind each asserted mechanism; its check passes. | It is this plan's planning-miss fix. |
| step:1 | session | A commit can be reverted. | It records your rulings. |
| step:5 | session | The edits are the sweep's verdicts, which approving the plan approves. | A direct change on `main`. |
| step:8 | session | The conductor launches only after every pre-flight check passes. | The plan's launch order. |
