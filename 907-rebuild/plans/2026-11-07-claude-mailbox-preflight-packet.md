# Claude's send mailbox: plan and its settings patch

You approved the design for Claude's send mailbox on ward earlier today, with ward refusing any recipient off the list. The plan is now written and reviewed. The review found no blockers, its twelve findings are folded, and the Stalwart facts it depends on were checked against the v0.16.27 source. Planning turned up one step the design didn't foresee: Claude's settings need allow rules before the executor can run its probe script and the new helper. That's a planning miss at the design stage, recorded in the plan.

Approving accepts the plan and has you apply one settings patch before launch. The patch adds five allow rules and one auto-mode line, which says the mailbox's app password is sensitive, sends go only through the helper, and its mail is untrusted. Then `conductor-servers` checks the rules with a stub and launches `servers-claude-mailbox`. The path is 300 minutes against a 480 ceiling. The servers PR and a workstation docs PR come back to you in one packet, and after they merge you run the setup script once, as you did for pass B.

## If you approve
1. [you: apply the settings patch] In Ptyxis, run `cd ~/.dotfiles && git apply ~/.local/state/claude-mailbox/settings.patch && bash scripts/gate.sh && git add claude/.claude/settings.json && git commit -m "Allow the claude-mailbox probe and helper, and name Claude's send mailbox in auto mode" && git push && claude-tooling-sync apply`. The check: the session finds the five rules and the new line in `~/.claude/settings.json`.
2. [session] Run the stub proof: the pinned probe path is allowed, a `..` path to it is denied, and the stub tree is removed.
3. [session] Check that the servers checkout is on `main` and level with `origin`, then launch `servers-claude-mailbox` and watch it.

## Not checked
Whether the Sieve reject text reaches the sender as the SMTP reply comes from source only, and T2 proves it live. The thinkpad gets the patch on its next pull and `claude-tooling-sync apply`, and the pass doesn't need it there.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:907-rebuild/plans/2026-11-07-claude-mailbox-plan.md | approve | Reviewed "ready after folds", twelve findings folded, P2 to P4 checked | It builds the approved design, and its errata only correct details, such as the list living on the account in `accounts.json` |
