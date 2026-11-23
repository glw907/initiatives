# Status

Geoff approved the `dubplate` spec, `specs/2026-11-22-dubplate-reshape.md`, and its build is done. Geoff approved `cairn-cms`'s spec,
`specs/2026-11-22-cairn-cms-reshape.md`. Its build runs from `plans/2026-11-22-cairn-cms-build-prompt.txt`,
in a session Geoff starts from `~/Projects/cairn-cms` on Sonnet at high. All three tasks are merged. The
`cairn-docs-cycle` launcher edit (`workstation` pull request 270) and the dry run remain.

## Current state

- Geoff approved the record as pull request 182 on 2026-11-22, and it is active.
- The `dubplate` spec has three tasks: the `internal/serve` fix, the Claude files and backlog, and
  the Go team's checks. A probe showed a `--bg` task session can edit `.claude/` files.
- The `dubplate` build is done on 2026-11-22. Hand-over 1 landed as `96c4e91` on `master`, and the
  GitHub settings are on. Task 1 (`serve-shutdown`) merged as pull request 20 (`3cc98d3`) after Geoff
  approved it with "PR 20 is approved." Task 2 (`claude-files`) merged as pull request 21
  (`56d95f7`) after "PR 21 approved". Task 3 (`gate-checks`) merged as pull request 22 (`ae23af6`)
  after "22 approved." Hand-over 2 landed as `4fd388d`: `docs/STATUS.md` says the reshape is done,
  names backlog #173 as the `structure-doctor` restart, and the dependabot check prints
  `dependabot.yml`. No `dubplate` session is running, and its worktrees are gone. What is left in
  `dubplate` is its own backlog: #173 and #174, and #132 for the critical `certifi` advisory.
- Geoff asked "Please clean up the worktrees." on 2026-11-22, and both `dubplate` leftovers are
  removed. `agent-a828799e8800f0243` held 23 uncommitted edits, an old copy of the restore-intent
  record work that `master` already carries in its flat shape, at the retired
  `internal/engine/store` path. Its diff is kept in
  `research/2026-11-22-leftover-worktree/agent-a828799e8800f0243-uncommitted.patch`, and the
  removal used `--force`. `~/.claude/jobs/5452379b/tmp/base-tree` was clean and its tip is merged.
- The `cairn-cms` spec has four steps in Geoff's session, then three tasks: `cairn-build`, the docs
  process before the 2026-12-01 docs cycle, and the backlog sweep. Steps 1 to 3 are done on 2026-11-22:
  hand-over 1 landed as `b48f6149a` on `main` (`docs/STATUS.md`, 54 lines), the GitHub settings are
  on (alerts, secret scanning, and push protection read `enabled enabled`), and the settings change
  landed as `672ddac08`. Turning alerts on raised Dependabot alert 1, a medium `minimatch` denial of
  service in `package-lock.json`, which no task covers. Step 4, the `cairn-pass` and `claude-tooling.md`
  edits, merged as `workstation` pull request 269 (`17e6031`) after Geoff approved it with "269 approved."
  on 2026-11-22. The `cairn-docs-cycle` launcher edit waits for task 2. Task 1 (`cairn-build`, Sonnet at high)
  merged as `cairn-cms` pull request 263 (`475435700`) after Geoff approved it with "263 approved" on
  2026-11-22. Its session sat `blocked` after the pull request was ready, so the session Geoff talks to
  stopped it before the merge. Task 2 (`docs-process`, Opus at medium) merged as `cairn-cms` pull request 264 (`8bc81cf64`) and task 3
  (`backlog-sweep`, Sonnet at medium) as pull request 265 (`2254cada6`), both after Geoff typed "PR 264 and 265
  are both approved." on 2026-11-23. Geoff added "Both recomendations accepted.", and pull request 264 took two
  fixes to `evals/cycle-prompt.txt` before the merge: a skipped month leaves `last` alone, and step 1's
  open-pull-request search ignores the run month's own branch. `claude agents --json` listed the four `claude -p`
  eval children as busy, which the spec's call 17 said it would not. Geoff ruled on 2026-11-22 with "You can
  start task 3". Task 3's session sat `blocked` after its pull request was ready, as task 1's had, and
  was stopped before the merge. Geoff asked "please log the process failure", read as those blocked sessions:
  `~/.dotfiles/BACKLOG.md` #118 holds it. The goal checker kept finding the done list's "and the session has
  ended" clause unmet. The `cairn-docs-cycle` launcher edit is `workstation` pull request 270. #308 from the
  sweep is `~/.dotfiles/BACKLOG.md` #119.
- The audit is `research/2026-11-22-audit/README.md`, with the trial outputs in its `trials/` folder.
- The trials adopt `govulncheck` and fuzz tests for `dubplate`'s gate, and `go test -race` for its
  CI once task 1's `internal/serve` fix lands. They decline `golang-security`, `golang-database`,
  `claude-code-setup`, and `claude-md-management`.
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
- "PR 264 and 265 are both approved. And please log the process failure. Both recomendations accepted."
  (2026-11-23). The two recommendations were the `cycle-prompt.txt` fixes above.
- "spec approved" (2026-11-22), approving the `cairn-cms` spec as written, with its calls: the docs
  cycle opens one pull request and never waits, and the December fallback.
- "Approved." (2026-11-22), approving the `dubplate` spec as written, with its calls: the race
  step in CI, `dependabot.yml` watching only GitHub Actions, no weekly fuzz schedule, and the task
  models.

## Leave alone

- `~/.dotfiles/.claude/worktrees/spec-writing-test-2` and its close-out, which belongs to
  `claude-config-alignment/plans/2026-11-22-close-out-prompt.txt`.
- `dubplate`'s paused structure round and its plans in `dubplate-server`.
