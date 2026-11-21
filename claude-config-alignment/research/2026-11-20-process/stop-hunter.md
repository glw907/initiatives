# Stop hunter: where the new process can still stop

This report tries to break the new process against Geoff's test. It is input for the process
spec, and it changes nothing. Every mechanism is labeled:

- **documented**: a Claude Code docs page says it works this way.
- **assembled**: built from documented pieces, with the joining done by us.
- **invented**: nothing in the docs describes it.

## The test, and the process under test

The test (`cc-desk/docs/specs/2026-11-20-process-decisions.md:87-90`): between two sittings,
work never stops to wait for Geoff unless it truly needs him. At his sitting, everything
finished is reviewed and ready to merge, with a report. A run fails in two ways. A session sat
idle over something it could have decided. Or one stopped task held up work that didn't depend
on it.

The process as written:

- Each task is a fresh `claude --bg` session in a worktree, under `/goal`, ending in a pull
  request (`process-decisions.md:54-55`).
- A Bash script on a systemd timer starts the next task. Hooks record failures. The page only
  reads files (`process-decisions.md:56-57`).
- All Go is deleted (`process-decisions.md:58`). No session merges. Geoff approves at his
  sitting, and the session he is talking to runs the merges (`process-decisions.md:59-60`).
- The five stops become controls (`process-decisions.md:100-108`). A cap ends the session. A
  refused step is listed, and the session finishes the rest. Secrets are gathered before the
  run. Out-of-scope work ends the session with a reason. A sign-in or data call is made, reviewed
  by a second session, and flagged.
- Two probes passed on 2.1.329. `/goal` works in `--bg`. A `dontAsk` session that meets a
  refused command carries on and ends `done` (`process-decisions.md:62-64`).
- Proposed, not ruled on (`process-decisions.md:116-124`): the budget caps (twice the planned
  minutes, 85 percent of weekly usage) and the four sitting groups.

The task text adds two things that the decisions file doesn't state. A child task branches from
its parent's branch, and a fresh subagent or second session reviews the result. The core design
already has a build session run two fresh subagent reviews before its PR opens
(`cc-desk/docs/specs/2026-11-20-core-design.md:367-371`). Whether every task works this way is
not stated in the decisions file.

A note on the docs citations: Claude Code docs pages have no line numbers. They are cited by URL
and section heading, read on 2026-11-20. One page, permissions, was saved locally, and its lines
are cited from that copy.

## Ranked findings

Ranked by unattended work lost if the gap is left open. "Record" is the evidence it can happen.

| Rank | Scenario | Record | Handled today? | Sitting group it lands in |
| --- | --- | --- | --- | --- |
| 1 | Task built on an unmerged parent | Row 12, about 131 min | Partly | Couldn't finish, or never started |
| 2 | Weekly usage or rate limit mid-task | Three rounds at 88 to 99 percent | No | Couldn't finish |
| 3 | A failure outside Claude Code stops every task | Row 25, about 7 h 43 min | No | All tasks in Read before merging |
| 4 | Timer script can't tell free from blocked | Four follow-ups, one "wait forever" | No, the script is unwritten | Nowhere: work silently not started |
| 5 | `/goal` never says done, or says done early | Rows 15, 17, 18, 20 | Partly | Couldn't finish, or Ready by mistake |
| 6 | Machine reboot | `cold-boot.md`, untested | Partly | Couldn't finish |
| 7 | A timer-launched session can't run commands | `sessions-report.md:104-107` | No | Couldn't finish |
| 8 | Session ends at its cap with nothing pushed | Not seen; follows from 1 and 5 | No | Couldn't finish, work only on disk |
| 9 | A refused step the rest depends on | `desk-report.md:102`, core design `:374-377` | Partly | Held for you |
| 10 | Review fault found after the builder ended | Rows 18 and 20 | Partly | Read before merging |
| 11 | Geoff's merge makes other PRs conflict | Not in the record | No | Appears at the sitting |
| 12 | Branch or worktree left behind | Row 34, from 13:32 | Partly | Couldn't finish, at the next start |
| 13 | Two tasks touch the same file | Row 24 | No | Read before merging |
| 14 | A secret found missing mid-run | Row 29 | Partly | Couldn't finish |

Already handled by the process as described: see the last section.

---

## 1. A task built on an unmerged parent

**Record.** Row 12 of `cc-desk/docs/follow-ups/desk-round-lessons.md:12`: pass 2's review
escalated, and the round plan held pass 3 behind the merge, about 131 minutes. The failure review
says the plan replaced "starts once that pass's PR is ready, whatever its verdict" with "starts
when pass 2 has landed" (`initiatives/cc-desk/reports/desk-failure-review.md:33`). Its fix is
"Don't hold the chain behind a merge question" (`desk-failure-review.md:51`). This is the
largest single loss of the five reports that came from ordering alone.

**What the process does.** Branching a child from the parent's branch removes the merge wait.
Three gaps remain, and none is stated:

- **The parent has nothing pushed.** A background session in a worktree pushes and opens a
  draft PR "when it finishes" (agent view docs, v2.1.198 note,
  https://code.claude.com/docs/en/agent-view). A parent that is still running, or that ended at
  a cap or an error, may have no remote branch. The child has nothing to branch from.
- **The parent's base moves.** The parent's review asks for fixes, and the parent's branch gets
  new commits after the child started. Who rebases the child is not stated.
- **The parent is rejected.** Geoff refuses the parent at his sitting. The child is built on
  work that won't land. What happens to the child is not stated.

**How to branch from a branch.** `worktree.baseRef` takes only "fresh" or "head". It can't
name a branch, and the docs say "To start a worktree from a specific existing branch, create it
with git directly" (worktrees docs, https://code.claude.com/docs/en/worktrees). `--worktree
"#1234"` branches from a PR's head (same page). So the child needs either `git worktree add` by
the timer script (assembled) or the parent's PR number (documented).

**Smallest control.**

- The timer script starts a child only from a parent's pushed PR head, with `--worktree "#N"`
  (documented flag, assembled use). A parent with no PR yet means the child is not free.
- A child PR names its parent PR in its body, and is opened against the parent's branch, so a
  merge of the parent retargets it (GitHub behavior; not in the files read, so not verified
  here).
- A rejected parent moves each child to "Couldn't finish" with the reason "parent rejected".
  This is invented; nothing in the docs or files describes it.

## 2. A weekly usage or rate limit mid-task

**Record.** Three rounds ran at the edge of the weekly limit: 92 to 99 percent
(`initiatives/cc-desk/reports/sessions-report.md:166`), 92 to 98 percent
(`page-report.md:166`), and 88 to 91 percent (`state-rules-report.md:7`). The per-model limit
question was never settled: the account figure can read low while one model is still at its
limit, so a session can stop and start over (`sessions-report.md:24-30`). The limit texts were
never captured live (`cc-desk/docs/follow-ups/live-sample-of-limit-texts.md:3-11`). Parallel
sessions spend quota "roughly ten times as fast" for ten agents (agent view docs, Limitations).

**What the process does.** A limit hits every running task at once, so this is a whole-run
stop, not a single-task stop.

- `/goal` pauses on an API rate limit or a usage limit ("Goal paused"). It resumes only if the
  session is waiting to continue automatically at the reset (`/goal` docs,
  https://code.claude.com/docs/en/goal). Documented.
- Waiting for a usage limit to reset is on by default "in interactive sessions signed in with a
  claude.ai subscription", and stops after three continuations, including for a `/goal` across
  several reset windows (interactive mode docs, "Wait for a usage limit to reset",
  https://code.claude.com/docs/en/interactive-mode). Whether a `--bg` session counts as
  interactive here is **not stated**.
- The 85 percent cap is proposed, not ruled on (`process-decisions.md:121-122`). Without it,
  the timer script keeps starting tasks into a limit.
- With the Go deleted, the old check that relaunched under the stop line
  (`cc-desk/docs/specs/2026-11-17-sessions-design.md:151`) is gone. Nothing replaces it.

**Smallest control.**

- A `StopFailure` hook with the `rate_limit` matcher records which session stopped and when
  (hooks docs, https://code.claude.com/docs/en/hooks). Documented.
- The `Notification` types `quota_auto_resume_fired`, `quota_auto_resume_stale`, and
  `quota_auto_resume_disabled` tell whether auto-continue took over (hooks docs). Documented.
- The timer script respawns a session that a limit stopped, once the reset time passes, with
  `claude respawn <id>`, which resumes a saved conversation (agent view docs). Assembled.
- One probe is owed before the run: does a `--bg` session wait for a usage reset by itself? The
  probe settles whether the respawn is needed.

## 3. A failure outside Claude Code stops every task

**Record.** Row 25 (`desk-round-lessons.md:25`): GitHub Actions stopped on the account's
billing from 09:12 UTC to about 16:55, because the two private repos drew paid minutes. Every
run ended in seconds with "The job was not started because recent account payments have
failed" (`initiatives/cc-desk/reports/desk-report.md:14-18`). Pass 6 did every task that needed
no CI, wrote its stop, and ended (`desk-report.md:146`).

**What the process does.** Nothing in the process checks CI health before or during a run. Each
session would finish its steps and open a PR with no green checks. The sitting would show every
task under "Read before merging", or under "Couldn't finish" if the goal names green checks.
The work is done, but none of it is ready to merge, which fails the second half of the test.

**Smallest control.** A pre-flight in the timer script, before the first task starts: one
`gh run list` or a trivial workflow run on each target repo, and a stop of new starts with one
report line if Actions won't run (assembled). The record shows one cause, so the check stays one
line.

## 4. A timer script that can't tell a free task from a blocked one

**Record.** Four follow-ups:

- A building pass with no checkout "would wait forever"
  (`cc-desk/docs/follow-ups/building-pass-without-checkout-needs-entry.md:3-11`).
- A hook failing on `PATH` left sessions blocked, recorded as `unreadable_stop`. "Nothing told
  Geoff, and no later check would have resumed them"
  (`blocked-session-reads-as-unreadable-stop.md:3-8`).
- A stop never clears itself (`how-a-stop-clears.md:9-11`).
- Pass start keeps a stuck session (`pass-start-keeps-a-stuck-session.md:3-9`).

These were bugs in a much larger Go check. A Bash script must get the same reads right with far
less code.

**What the process does.** The decisions file says the script "starts the next task"
(`process-decisions.md:56`) and nothing more. Not stated:

- where a task's dependency on another task is written,
- what signal means a task is done, blocked, or failed,
- what the script does with a task it can't read.

**Documented signals that exist.**

- `claude agents --json --all` prints each background session's `state` (`working`, `blocked`,
  `done`, `failed`, `stopped`), its `status` while alive, and `waitingFor` when waiting (agent
  view docs, "List sessions as JSON"). Documented.
- The PR's state, from `gh pr view`. Documented by GitHub, assembled here.
- The `Notification` types `agent_completed` and `agent_needs_input` (agent view docs).
  Documented.

**Smallest control.**

- The spec lists each task with one field, `after:`, naming the task it builds on. A task is
  free when every task it names has an open PR (assembled from the spec file and `gh`).
- The script maps each `claude agents --json` state to one of the four sitting groups, and any
  state it can't map goes to "Couldn't finish" with the raw row. The rule: an unreadable state
  is never silent (assembled).
- The script keeps one log line per decision, so the report can say why a task didn't start
  (assembled). The old check did this (`cc-desk/docs/research/2026-11-20-kill-probe.md:17-18`).

## 5. A `/goal` checker that never says done, or says done early

**Record.**

- Row 17 (`desk-round-lessons.md:17`): an executor wrote its stop and then waited on CI instead
  of ending, about 35 minutes. Its state stayed `working`.
- Row 15 (`desk-round-lessons.md:15`): a leftover live session sat about 85 minutes unseen.
- Row 18 (`desk-round-lessons.md:18`): a live run disproved a plan line, and a fix touched only
  the one path the run tripped.
- Row 20 (`desk-round-lessons.md:20`): an acceptance row cited a late, truncated read.

**What `/goal` does** (`/goal` docs, https://code.claude.com/docs/en/goal). All documented:

- The evaluator is a small fast model. It reads only the transcript and "doesn't run commands
  or read files independently". A claimed check that never ran can pass. That is "done early".
- With "no tool use for several turns in a row" it stops the loop and returns control with the
  goal still set. In a `--bg` session nobody answers. That is the idle failure the test names.
- Background work defers evaluation. Check-ins come at 30 minutes, then back off, with at most
  three idle check-ins per goal. A goal waiting on CI waits on this schedule.
- A goal can carry its own bound, a turn or time clause such as "or stop after 20 turns".
- An idle, unattached background session's process is stopped after about an hour (agent view
  docs). The old 15-minute idle rule (`sessions-design.md:147`) goes with the Go.

**Smallest control.**

- Every goal carries a time or turn clause (documented). This is also how the cap ends a
  session cleanly, so it serves scenario 8.
- Every goal names evidence the transcript must show: a command and its output, not a claim
  (documented use of the evaluator's transcript-only reading).
- The fresh review reads the worktree, not the transcript, before the PR opens
  (`core-design.md:367-371`; assembled).
- The timer script treats `done` with no PR, or an idle row past a set time, as "Couldn't
  finish", and respawns it once (assembled).

## 6. A machine reboot

**Record.** `cc-desk/docs/follow-ups/cold-boot.md:3-19`: on a cold boot the timer's first
`claude --bg` may start the supervisor, and `gh` and the keyring over D-Bus may not be unlocked.
It is untested.

**What the process does.** All documented (agent view docs):

- "Shutting down or restarting your machine stops running background sessions."
- Within 48 hours a stopped session shows `failed`, and `claude respawn` restarts it from its
  saved conversation. Past 48 hours it shows `stopped`, "ended while the background service was
  off".
- Resume restores an active goal and resets its counts (`/goal` docs).
- Whether `claude respawn` keeps the goal is **not stated** on the agent view page. The `/goal`
  page says resume restores it, and respawn resumes a saved conversation, so it likely does.
  This is a reading, not a stated fact.

The sessions design found that a session started straight from a timer service dies when the
service exits. Every launch must go through `systemd-run --user --scope`
(`sessions-design.md:130-133`). The new timer script inherits this need. It is not in the
decisions file.

**Smallest control.**

- The timer script launches through `systemd-run --user --scope` (assembled, proven).
- On each run, it respawns any session that the spec names and that reads `failed` (assembled).
- One reboot probe before the unattended run, which also settles `cold-boot.md`.

## 7. A timer-launched session that can't run commands

**Record.** The service's `PATH` lacked `~/.local/bin`, where the launch guard lives. The first
two sessions failed every shell command and went idle, and were resumed by hand
(`sessions-report.md:104-107`). Row 29: the `ANTHROPIC_API_KEY` in one environment gave "Credit
balance too low" (`desk-round-lessons.md:29`).

**What the process does.** Not stated. A timer has a minimal environment. A session with a
broken hook fails every tool call, and if the evaluator sees no tool use, the goal stops and
the session sits idle (scenario 5).

Two documented facts apply:

- An exhausted credit balance or an auth failure clears the goal ("Goal cleared after an
  unrecoverable error") (`/goal` docs).
- `--bg` checks workspace trust, and fails with "Workspace not trusted" from a script (agent
  view docs). Trust is keyed on the repository root, and a worktree uses the main checkout's
  root (permissions docs, saved copy line 803). So a trusted repo's worktrees are trusted. A
  repo that was never opened interactively is not.

**Smallest control.** The unit file sets `PATH`, and unsets `ANTHROPIC_API_KEY`. The timer
script's first act each run is one `claude -p` call that runs one shell command and checks the
result. A failure stops new starts and writes one report line (assembled).

## 8. A session that ends at its cap with nothing pushed

**Record.** Not seen directly. It follows from how the cap works.

**What the process does.** "A cap ends the session and asks nothing" (`process-decisions.md:104`).
How the cap ends it is **not stated**. Two readings:

- The cap is a clause in the goal. The evaluator reports the goal met, and the session ends
  normally. The v2.1.198 behavior then pushes and opens a draft PR (agent view docs). The work
  reaches the sitting.
- The cap is the timer script stopping the session with `claude stop`. Nothing is pushed. The
  periodic sweep keeps worktrees with changes or unpushed commits (worktrees docs), so the work
  stays on disk, but nobody can review it.

**Smallest control.** The cap lives in the goal text (documented). A `Stop` hook commits and
pushes work in progress on the task branch before the session ends (assembled from the
documented `Stop` event). Only a branch that exists on the remote reaches "Couldn't finish" with
something to read.

## 9. A refused step that the rest of the task depends on

**Record.**

- Auto mode refused one `rm`, and the file was left alone (`desk-report.md:102`).
- The classifier refused `.claude` edits in dotfiles worktrees between 2026-11-01 and
  2026-11-20 (`core-design.md:374-377`). For three weeks, a task whose deliverable was a
  `.claude` file could not finish at all.
- 523 commands in the session records contain `gh pr merge` although the hook refuses it
  (`core-design.md:526-527`). Sessions keep trying refused steps.

**What the process does.** The probe proved that a `dontAsk` session carries on after a refusal
and ends `done` (`process-decisions.md:63-64`). It didn't test a refusal that later steps need.
Those steps then fail, or the session works around them. A list of refused steps held for Geoff
"would be new", and the process spec "labels it invented" if it wants one
(`core-design.md:523-525`).

`permissions.denyInsteadOfPrompting` denies calls that would wait on a prompt, so an unattended
session keeps working, and it works with any permission mode (permissions docs, saved copy line
89). Documented. `dontAsk` auto-denies every call that would prompt (saved copy line 80).
Documented.

**Smallest control.**

- A `PermissionDenied` hook writes each refusal to the task's report file (hooks docs,
  documented event; the report file is assembled). The hooks docs say it fires when auto mode
  denies a call. Whether it fires for a `dontAsk` or `denyInsteadOfPrompting` denial is **not
  stated** in what was read. One probe settles it.
- The goal says: a refused step goes to "Held for you", with the steps it blocks named, and the
  session doesn't fake the outcome (assembled).
- The spec lists, per task, any step it knows will be refused, and the plan puts it last
  (invented).

## 10. A review fault found after the builder session ended

**Record.** Row 18 (`desk-round-lessons.md:18`): a fix review escalated past the stop line, and
the review cited a stale commit. Row 20 (`desk-round-lessons.md:20`): the last review escalated
on a truncated listing.

**What the process does.** The core design runs the review inside the build session, before the
PR opens. "The build session fixes what they find or lists it in the pull request"
(`core-design.md:367-371`). If every task works this way, the builder is still alive when the
review lands, and this scenario mostly goes away. If the review is a second session after the
PR, who fixes the fault is **not stated**.

**Smallest control.** The review runs as a subagent inside the builder session, before the PR
opens, as the core design already does (documented subagents, assembled flow). A fault the
builder can't fix goes to "Read before merging" with the finding.

## 11. A merge by Geoff that makes other open PRs conflict

**Record.** Not in the record read.

**What the process does.** The session Geoff talks to runs the merges
(`process-decisions.md:59-60`). Merge order and rebasing after each merge are **not stated**.
This happens at the sitting, so it costs sitting time, not unattended time. A conflicting child
left until the next sitting would cost a whole gap.

**Smallest control.** The sitting session merges in dependency order and rebases each open
child after each merge. It moves any that won't rebase cleanly into a fresh task for the next
run (assembled).

## 12. A branch or worktree left behind

**Record.** Row 34 (`desk-round-lessons.md:34`): a leftover `conductor` branch made the next
launch refuse, from 13:32 on 2026-11-20. Three failed tries used both relaunches. Also
`closed-pass-leaves-its-worktree.md:3-5` and `conductor-worktree-removal-gaps.md:6-16`, which
say a skipped pull leaves the branch and nothing retries a failed removal.

**What the process does.** All documented (worktrees docs):

- A periodic sweep removes background-session worktrees older than `cleanupPeriodDays`, and
  keeps any with changes or unpushed commits.
- `claude rm <id>` removes a session and its worktree when safe (agent view docs).
- `-p` runs don't clean up their worktrees.

The task-branch names are **not stated**. A fixed name per task repeats row 34 on any second
attempt.

**Smallest control.** Each attempt gets a unique branch name, such as the task name plus a
timestamp (assembled). The sitting session runs `claude rm` on merged tasks (documented).

## 13. Two tasks that touch the same file

**Record.** Row 24 (`desk-round-lessons.md:24`): the conductor committed in a planner's live
worktree while the planner was still editing the same file. The tree was clean that time.

**What the process does.** Separate worktrees stop live collisions, so no session overwrites
another (worktrees docs). The collision moves to merge time and becomes scenario 11. Nothing
states how overlapping tasks are found.

**Smallest control.** The spec lists the files each task expects to touch. The timer script
won't start two tasks that share a file. It runs them in order, with `after:` (invented; the
docs have no file-overlap check).

## 14. A secret found missing mid-run

**Record.** Row 29 (`desk-round-lessons.md:29`), the API key gave "Credit balance too low".
`2026-11-17-rerun-prove-proofs.md` says the sign-in expiry warning is untested.

**What the process does.** "Secrets are gathered before the run starts"
(`process-decisions.md:106`). How a task names the secrets it needs is **not stated**. An auth
failure or an exhausted credit balance clears the goal (`/goal` docs). A worktree doesn't get
gitignored files such as `.env` unless `.worktreeinclude` lists them (worktrees docs,
documented).

**Smallest control.** Each task in the spec names its secrets by store name. The timer script's
pre-flight checks each name exists, never its value, before the task starts (assembled). Each
repo with a gitignored env file lists it in `.worktreeinclude` (documented).

---

## What the process already handles

- **Estimate parks** (rows 11, 13, 14, 23, 32; `desk-round-lessons.md:11-14,23,32`). The cap
  ends the session and asks nothing (`process-decisions.md:104`). The worst was 10.5 hours.
  Handled, provided scenario 8's push is in place.
- **Blocking questions** (row 19, about 100 minutes; `desk-round-lessons.md:19`). No session
  waits on a question (`process-decisions.md:100`). Handled.
- **The landing test reading the review's word** (`desk-failure-review.md:31-33`). Nothing
  merges unattended, and the review's findings go in the PR. Handled.
- **The conductor's own failures** (rows 15, 16, 19, 34, 35). The conductor role goes away
  (`process-decisions.md:78`). Handled, with row 34's branch problem moved to scenario 12.
- **A killed process.** The supervisor revives it within 11 seconds
  (`cc-desk/docs/research/2026-11-20-kill-probe.md:3-5`). Handled by Claude Code itself.

## Things not stated anywhere read

- How the cap is enforced (scenario 8).
- Whether `--bg` sessions wait for a usage reset (scenario 2).
- Whether `PermissionDenied` fires for `dontAsk` denials (scenario 9).
- Whether `claude respawn` keeps an active goal (scenario 6).
- Where a task's dependencies and secrets are written in the spec (scenarios 4 and 14).
- What happens to a child when its parent is rejected (scenario 1).
- Merge order at the sitting (scenario 11).

Four probes before the unattended run would settle the first four: a `--bg` usage-reset wait, a
`PermissionDenied` firing under `dontAsk`, a respawn with an active goal, and a cold boot.

## Questions only Geoff can answer

1. **Build on a faulted parent?** Should a child task start from a parent whose review found
   faults, or wait for the parent to be clean? Building on it keeps work moving. It risks
   rework if he rejects the parent. This is a risk and budget call.
2. **The two budget caps.** They are proposed, not ruled on (`process-decisions.md:121-122`).
   Scenario 2 depends on the 85 percent line most.
3. **Outside failure policy.** When CI is down for the whole account (row 25), should tasks keep
   building with no checks and land in "Read before merging", or should no new task start?
   This is a priority call.
