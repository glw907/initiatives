# Agent-first plan, pre-launch

You approved the agent-first design, then added acceptance bars, two sittings, and a review of the editors and admin drafts. The plan now carries all of that. It took three review lenses, a fold, and a verification read, which found 12 blockers in all; every one is folded or settled.

The plan is 41 tasks and 3,005 path minutes over four passes, with 339 eval sessions on your subscription and a ceiling of 678. Passes 1 to 3 stay within twice the design's figures. Pass 4 does not, because of what you added. Three things hold pass 1: your rulings below, your dotfiles checkout, and a token. Approving starts pass 1 once your steps are done. One finding matters beyond this work: `create-cairn-site` is not on npm, so `npx create-cairn-site` fails today. Publishing it becomes a prerequisite of the release.

Two errata change a proof. The walker keeps the name `check-options.mjs`, and the eval stops an arm early once a failure decides it, with a five-of-five case passing at seven of eight on rerun. You can veto eight review forks the session closed; the plan's `## Rulings owed` lists them, first the Lean target (22 pages and half the words) and no reviewed-SHA pin on the plugin.

## If you approve
1. [session] Merge the plan PR.
2. [you: Bring dotfiles to main] `~/.dotfiles` is on `google-sheets-tooling` with `secrets/values.age` modified, and that branch has no PR. Merge or park it, or say "open the Sheets PR" in your note and the session will. Check: `git -C ~/.dotfiles status -sb` shows `main`, clean and level with `origin/main`.
3. [you: Create the container token] Run `claude setup-token` and paste the value into the dialog the session opens with `secret-receive CAIRN_E2E_OAUTH_TOKEN`. Skip this if you answer no to the first ask. Check: the session reports that the store name exists and a fresh `claude -p` answers.
4. [session] Open and merge a workstation PR adding nine exact `permissions.allow` rules: `gh repo create` for `glw907/standards` and `glw907/cairn-cms-e2e`, ruleset POSTs on `glw907/cairn-cms` and `glw907/standards`, `gh release create v* --prerelease`, `podman build -t cairn-e2e`, `podman run` with the e2e env file, and `gh repo delete` for the two throwaway names. Your approval is the yes these rules need.
5. [you: Apply the rules] Run `claude-tooling-sync apply`. Check: the rules appear in `~/.claude/settings.json`.
6. [session] Hold this month's `cairn-docs-cycle` with a drop-in on `model-review.service`, and send pass 1 to its conductor.

## Not checked
No quote says a plain allow rule clears auto mode for these calls, so the first real run of each rule is the proof; a refusal stops at a written answer. One measured session sized the eval, and pass 3 stays under its ceiling only up to about 8.4 minutes per site trial at four concurrent.

## Ask: Mint a dedicated token for the test containers?
Rule: owner-call
Part: none
Recommended: 1
Reason: A token named for this work is removed cleanly when the work ends, and the old one's record limits it to other agents.
Summary: The containers that prove a clean clone need a subscription credential. A new token costs you one mint and leaves the store when the plan closes.

Background: End-to-end checks run in containers with nothing from your workstation, so they cannot use your login. An older token exists for retired docs reader agents.

Facts: The old token has no live user.
- Its registry row reads "the cairn-cms docs-reset reader agents only" (`~/.dotfiles/secrets/registry.md`)
- The runner that row names is gone (`a8c57b4a1`)

Choices:
- Mint a new one: step 3 runs, and task 4.13 removes the token
- Reuse the old one: you skip the mint, its registry row widens, and it stays in the store

## Ask: Accept one install line if the marketplace does not auto-load?
Rule: owner-call
Part: none
Recommended: 1
Reason: Anthropic's docs support the settings route, so this should not fire, and one line beats stopping the pass.
Summary: The design promises a second developer installs nothing by hand. Pass 1's first task tests that live. If it fails, one `claude plugin install` line in `CONTRIBUTING.md` keeps the pass moving.

Background: The plugin is meant to load from a committed `.claude/settings.json` after the folder trust dialog. A probe showed a fresh config lists the plugin from those settings, but the full flow is unproved.

Facts: The fallback departs from one design line.
- "A second developer clones `cairn-cms`, accepts the folder trust dialog in a local session, and has the tooling without installing anything by hand" (`shared-standards/specs/2026-10-31-agent-first-pattern-design.md`)

Choices:
- Accept the line: pass 1 goes on, and its PR states the departure
- Keep it a stop: pass 1 waits for you to rule a design change

## Ask: Set pass 4's path ceiling at 900 minutes?
Rule: owner-call
Part: none
Recommended: 1
Reason: Each added item carries an acceptance bar or a request of yours, and splitting the pass delays nothing the release needs.
Summary: Pass 4 plans 840 minutes against the design's line of 720, and 270 of those came from items added after approval. A ceiling of 900 leaves 60 minutes of margin.

Background: `pass-core` sends any plan over twice its design estimate back to you. Past the ceiling, the run finishes the task in hand, stops, and sends a packet.

Facts: The overrun comes from your additions.
- Plan 840, line 720, added items 270 (`shared-standards/plans/2026-10-31-agent-first-plan.md`)

Choices:
- Set 900: pass 4 runs as written
- Split it: pass 4 closes at stage A's merge (255 minutes), and stage B (585 minutes) becomes a fifth pass with its own design line and every remaining bar; the release waits on it either way

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives#166 | approve | The plan and fold record are files only. | The review is complete. |
| step:1 | session | The PR changes only records, and its review is in the fold record. | Merging a plan can be reverted. |
| step:4 | session | Merging an approved rule PR is a session step per `approval-packet`. | The rules name exact targets. |
| step:6 | session | The hold is one reversible drop-in, and task 4.13 removes it. | It keeps a second session out of the repo. |
