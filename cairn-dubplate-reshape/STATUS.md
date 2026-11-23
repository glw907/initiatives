# Status

The audit of both repos is done, and three questions wait on Geoff. When he has answered them, a
session on Fable writes the two specs, `dubplate`'s first, by steps 5 to 7 of
`plans/2026-11-22-planning-prompt.txt`. It starts only when Fable reads under 85 percent of the
week. On 2026-11-22 Fable read 89 percent, and the week resets on Nov 27 at 11 PM Anchorage time.

## Current state

- Geoff approved the record as pull request 182 on 2026-11-22, and it is active.
- The audit is `research/2026-11-22-audit/README.md`, with the trial outputs in its `trials/`
  folder. It read `dubplate` at `907605c` and `cairn-cms` at `87869e61f`. Neither repo has
  changed.
- The trials adopt `govulncheck` and fuzz tests for `dubplate`'s gate, and `go test -race` for its
  CI after one fix. They decline `golang-security`, `golang-database`, `claude-code-setup`, and
  `claude-md-management`.
- The race run found an ordering bug in `dubplate`'s `internal/serve`. The test
  `TestServeUntilDoneShutsDownWhenOneServeFails` fails a few times in 50 under `-race`. The fix is
  product work, and it lands before `-race` joins CI. It isn't filed in `dubplate`'s backlog yet.
- `govulncheck` 1.10.0 is installed through Homebrew. Its line in the Homebrew list, `brew "govulncheck"`
  beside `brew "gopls"` in `~/.dotfiles/bluefin/Brewfile`, isn't written yet, because another
  session holds `~/.dotfiles`. The next session there adds it and runs `check-drift`.

## Waiting on Geoff

1. Should an automated security review spend usage: the `security-guidance` review at the end of
   each turn, or a `claude-security` scan as a Workflow?
2. Should GitHub's secret scanning, push protection, and Dependabot alerts go on for both public
   repos?
3. Should the `figure-verifier` agent go with `cairn-figure`?

## Geoff's rulings

- "You can remove cairn-figure." (2026-11-22). Standards pull request 25 removes the skill. Its
  check passes, and it waits for Geoff's approval by number. It merges only after the
  `spec-writing-test-2` session ends, as pull request 24 does, because the standards plugin
  updates itself in every new session.

## Leave alone

- `~/.dotfiles/.claude/worktrees/spec-writing-test-2` and its close-out, which belongs to
  `claude-config-alignment/plans/2026-11-22-close-out-prompt.txt`.
- `dubplate`'s paused structure round and its plans in `dubplate-server`.
