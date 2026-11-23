# Status

The `dubplate` spec is written and waits for Geoff's approval:
`specs/2026-11-22-dubplate-reshape.md`. Its Opus fresh reader's findings are folded in. After he
approves it, this session writes the build launch prompt in `plans/` and stops. `cairn-cms`'s spec
session runs on Fable at high from `plans/2026-11-22-cairn-cms-spec-prompt.txt` after that approval.
The facts for both are gathered in `research/2026-11-22-spec-inputs/`.

## Current state

- Geoff approved the record as pull request 182 on 2026-11-22, and it is active.
- The `dubplate` spec has three tasks: the `internal/serve` fix, the Claude files and backlog, and
  the Go team's checks. A probe showed a `--bg` task session can edit `.claude/` files.
- The audit is `research/2026-11-22-audit/README.md`, with the trial outputs in its `trials/`
  folder. It read `dubplate` at `907605c` and `cairn-cms` at `87869e61f`. Neither repo has
  changed.
- The trials adopt `govulncheck` and fuzz tests for `dubplate`'s gate, and `go test -race` for its
  CI after one fix. They decline `golang-security`, `golang-database`, `claude-code-setup`, and
  `claude-md-management`.
- The race run found an ordering bug in `dubplate`'s `internal/serve`. The test
  `TestServeUntilDoneShutsDownWhenOneServeFails` fails a few times in 50 under `-race`. The fix is
  product work, and it lands before `-race` joins CI.
- `govulncheck` 1.10.0 is installed through Homebrew. Its line in the Homebrew list, `brew "govulncheck"`
  beside `brew "gopls"` in `~/.dotfiles/bluefin/Brewfile`, isn't written yet, because another
  session holds `~/.dotfiles`. The next session there adds it and runs `check-drift`.

## Geoff's rulings

- "You can prep for the spec session. I'll spend my remaining fable time on it." (2026-11-22).
  This replaces the planning prompt's rule to start only under 85 percent. Fable read 96 percent
  then, and the week resets on Nov 27 at 11 PM Anchorage time.
- "Perfect. Let's plan for that." (2026-11-22), answering Claude's proposal that Opus at high
  write `dubplate`'s spec with an Opus fresh reader, and Fable write `cairn-cms`'s.
- "You can remove cairn-figure." (2026-11-22).
- "That matches." (2026-11-22), answering Claude's recommendation on the audit's three questions:
  - No automated security review for now. `security-guidance` stays off, because the reviews
    every pull request already gets cover it. `claude-security` runs once on `dubplate` after
    the week resets, before any release that people outside the house sign into. `cairn-cms`
    waits for its next large change to sign-in code.
  - GitHub's secret scanning, push protection, and Dependabot alerts go on for both public
    repos, and `dubplate` gains a `dependabot.yml`. Each repo's spec carries the step, since
    nothing in either repo changes before its spec is approved.
  - The `figure-verifier` agent goes with `cairn-figure`.
- Standards pull request 25 removes the skill and the agent. Its check passes, and it waits for
  Geoff's approval by number. It merges only after the `spec-writing-test-2` session ends, as
  pull request 24 does, because the standards plugin updates itself in every new session.
- The `dubplate` spec carries the `internal/serve` shutdown fix before `-race` joins CI.

## Leave alone

- `~/.dotfiles/.claude/worktrees/spec-writing-test-2` and its close-out, which belongs to
  `claude-config-alignment/plans/2026-11-22-close-out-prompt.txt`.
- `dubplate`'s paused structure round and its plans in `dubplate-server`.
