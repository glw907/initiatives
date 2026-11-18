# The Sessions round has landed all five pull requests

All five pull requests landed on 2026-11-18, after Geoff approved every call as recommended. Pull requests 8 and 14 each gained a page type at landing to match the Go snapshot, and their bodies say so under "Fixed at landing". The rest of this report is as written before the approval.

The Sessions round teaches the `cc-desk` command to run background sessions without Geoff
watching them. Its core is the check, a command that reads every session's state and acts on it. All five of its passes are finished, and none has landed yet.
[Pull request 8](https://github.com/glw907/cc-desk/pull/8) records each session and decides
what it needs next. [Pull request 10](https://github.com/glw907/cc-desk/pull/10) starts, ends,
and restarts sessions. [Pull request 12](https://github.com/glw907/cc-desk/pull/12) records a
session's permission prompts so Geoff can answer them from a desk session.
[Pull request 14](https://github.com/glw907/cc-desk/pull/14) merges a clean pull request and
sends a failed one back to its session. [Pull request 16](https://github.com/glw907/cc-desk/pull/16)
runs the check every five minutes on a timer, and its live run took two test passes in a
scratch repo through to their merges. Every pass passed its review and its automated checks.
Pull request 8 asks question 1 below, and pull request 16 asks questions 2 and 3. Pull requests
10, 12, and 14 ask nothing, so they need no separate approval. Each pull request carries the
ones before it, so all five land in order once Geoff approves 8 and 16. To accept every
recommendation, Geoff replies in this terminal session with "approve 8 and 16 as recommended".
To change an answer, he names the question and the choice number, as in "approve 8 and 16, but
3: choice 2".

## What waits for Geoff

### 1. When should a session that hit a one-model limit start again?

Pull request 8 holds this question. Each Claude model has a separate weekly limit, beside the
account's limit for all models. Say a session stops on "You've hit your Fable limit". As
built, the check starts it again as soon as the whole account's weekly usage reads under 90
percent. That restart doesn't count toward the session's limit of two restarts. The account
figure can be low while Fable is still at its limit. So the session can stop and start over and
over until Fable's limit resets. The design asked for this behavior, and the pass built it.

1. Leave it as built, and accept the repeated restarts until the reset.
2. Wait until the reset time printed in the stop message. This is the recommendation, because
   the check already saves that message. A message with no reset time would fall back to
   choice 3.
3. Count every restart after the first, so the limit of two restarts ends the loop.

Pull request 10 restarts these sessions through the same rule, so Geoff's choice covers it too.
Pull request 16's live run started at 99 percent, under the stop line, so it never tested this
restart.

### 2. Can the permission-prompt check stand without its hook test?

The design numbers the items that say when the round is done. Pull request 16's acceptance item
6 asks for a third session, launched with one permission rule left
out, to record its prompt. That can't happen. `cc-desk` launches every session in auto mode, and
in auto mode a command with no rule runs with no prompt, so the prompt hook never fires. Three
test sessions showed it, and the evidence is in
`docs/research/2026-11-18-auto-mode-hook-probe/` on the pass's branch. A count of zero prompts
now shows only that no session stopped on a prompt. It doesn't show the rules are complete.

1. Accept the check without that part for this round. A later pass then uses Claude Code's
   `PermissionDenied` hook, which fires when auto mode refuses a command, to record each refusal
   the way a prompt is recorded now. This is the recommendation.
2. Drop that part of the check for good.
3. Launch sessions in a mode other than auto, which brings back the prompts auto mode removed.

### 3. Can the check stand without showing the sessions gone?

The same acceptance item asks that, within 10 minutes of a merge, the session, the worktree, and
the branch are gone. The worktrees and branches went at each merge. Both sessions were still
listed afterward, one 5 minutes 48 seconds after its merge and one 16 seconds after. The
executor stopped both by hand, so the run never showed whether they would have ended in time.

1. Accept the item without that part for this round. The next pass merges a test pass with the
   timer on, lists the sessions every minute for 10 minutes, and adds a stop step to the check's
   cleanup if they stay. This is the recommendation.
2. Hold pull request 16 until that test runs.

## What each pass built, and its evidence

The design numbers the items that say when the round is done. Each pull request quotes its
items word for word, with the command that proves each one and what it printed before the change.

### Pull requests 8, 10, 12, and 14

When a session needs Geoff, the check names it under "Needs you now" on the status page, with
the reason. It records five new reasons, such as an expired sign-in or a permission prompt. With
pull request 10, a session that vanishes is started again in the same worktree, at most twice,
before it shows under "Needs you now". With pull request 12, a yes or no to a permission prompt
ends the session, adds the rule on a yes, and restarts it. With pull request 14, a pull request
whose check passes and whose review accepts it merges, and its worktree and branch are removed
with no force flag. A failed one goes back to its session at most twice, and a third failure
becomes a question. These four passes test against stand-ins, so none of them starts a real
session.

### Pull request 16, the live run

It answers acceptance items 6, 7, and 8. `cc-desk timer install` copies the binary to
`~/.local/share/cc-desk/bin/cc-desk` and turns on a systemd timer that runs the check every
five minutes. Starting a pass, reporting one ready, or answering a question also starts the
check right away. The new command `cc-desk desk register` registers an interactive terminal
session as a desk and refuses every other caller. It is the command pull request 12 found
missing.

The live run added two test passes to a release for the scratch repo, `cc-desk-scratch`, and
the timer's check launched them. Each pass edited a file, ran the gate, opened a pull request,
and reported ready. The check merged both, pull requests 3 and 4 in the scratch repo, and its
merge records name it. No session's log holds a merge command. The second pass was stopped
mid-run with `claude stop`, and the check relaunched it 5 minutes 31 seconds later, inside the
10 minutes the item allows.

The run wasn't clean from the start. The service's `PATH` lacked `~/.local/bin`, where the
workstation's launch guard lives, so the first two sessions failed every shell command and went
idle. The check recorded both as stopped. The executor fixed the unit, reinstalled it, and
resumed both passes by hand. That is why each pass shows one extra relaunch at 15:13 UTC.

Item 7 passed: both unit files verify, `cc-desk timer status` named a run that minute, and a
long-running stand-in launched through the service outlived the service. The gate passes with
no skipped test.

At the end, the timer is installed but turned off, because the binary it runs is the pass's
branch build. After pull request 16 lands, the conductor runs `cc-desk timer install` from main
to turn it back on. The conductor is the Claude session that runs these rounds in Geoff's
terminal, so Geoff doesn't run it himself.

## The permission-prompt count

The live run recorded zero permission prompts. Both passes' release records show 0, the denials
log holds no row for the scratch worktrees, and no prompt reached the conductor to answer. One
rule, `Bash(sleep 240)`, was left out on purpose, and the second pass ran `sleep 240` with no
prompt. Under auto mode that zero says only that no session stopped on a prompt, as the second
question explains.

## What landed

Nothing yet. All five pull requests are ready, and they land once Geoff approves 8 and 16.

## What went wrong

Every pass recorded where its plan fell short. None of these misses needed a question to Geoff
while the pass ran.

- The first pass's plan file failed the repo's spelling check on five words. The pass added them
  to the word list and noted that the plan should have run the gate on itself.
- The third pass changed one acceptance check. It asked for a hook input recorded from a real
  session, and no session could record one safely, so the test used the example in Claude Code's
  hooks reference. The fifth pass then recorded a real one and added it to the tests.
- The fourth pass's first review sent it back once. A session sent back to fix its pull request
  ignored the usage hold, so it could restart while weekly usage was over the line. The executor
  fixed that, and a second review accepted the fix. The plan also left three tests without the
  session rows they need.
- The fifth pass's plan left `~/.local/bin` out of the service's `PATH`. Its pre-flight should
  have checked that every hook command in the workstation settings resolves under that `PATH`.
  The plan also said the check relaunches a session that is gone. It doesn't relaunch one it
  recorded as stopped itself, so the passes needed a hand resume.

## What it cost

These figures show how close the plans' estimates came, for planning the next rounds.

| Pass | Planned minutes | Taken minutes | Times, Alaska |
| --- | --- | --- | --- |
| 1, record sessions | 90 | about 70 | 00:23 to 01:32 |
| 2, launch | 90 | about 70 | 01:35 to 02:44 |
| 3, prompts | 60 | about 60 | 02:46 to 03:48 |
| 4, merge | 60 | about 65 | 03:49 to 04:52 |
| 5, the timer | 75 | about 110 | 04:54 to 06:44 |

Each time runs from the planner's start to a ready pull request. The round planned 375 minutes
and took about 375. The round plan gave the fifth pass 75 minutes. Its planner then set the
pass's own plan at 150, because of the live run. Of the 110 minutes it took, about 70 were the
executor's, from its first commit to ready.

Weekly usage for all models went from 92 percent before the round to 99 percent after it. The
stop line is 100 percent.

## Advisor calls

The advisor is a second model a session consults on a judgment call. The Sessions passes followed
its advice 48 times: 7 in pull request 8, 14 in pull request 12, 10 in pull request 14, and 17
in pull request 16. Pull request 10 records none. Each pull request lists them under
`## Decisions`. Pull request 16 marks one as a call for Geoff, the hook question earlier in this report, and
the rest as the pass's method calls.

## What is left for later

Each pass filed its follow-ups on its branch under `docs/follow-ups/`.

- `how-a-stop-clears.md` asks how four kinds of stop clear once Geoff acts.
- `live-sample-of-limit-texts.md` asks for a live capture of the sign-in and limit messages.
- `ended-record-stop-in-needs-you-now.md` fixes a finished session that still shows under
  "Needs you now".
- `building-pass-without-checkout-needs-entry.md` asks that a pass with no recorded checkout
  show under "Needs you now".
- `launch-review-notes.md` holds the second pass's review notes that weren't folded.
- `cleanup-of-a-release-marked-done.md`, `merge-call-fails-for-good.md`,
  `merge-question-answer.md`, and `pull-request-closed-without-merge.md` come from the fourth
  pass.
- `auto-mode-prompt-clause.md` holds the hook question and the `PermissionDenied` plan.
- `merged-pass-session-still-listed.md` holds the 10-minute test for the sessions.
- `blocked-session-reads-as-unreadable-stop.md` asks that a session blocked by a failing hook
  not be stopped for good.
- `cold-boot.md` asks for a check of the timer after a cold boot.
- `live-check-cleanup-gaps.md` closes gaps in the live script's cleanup.

The fifth pass closed four: `desk-registration-gap.md`, `followup-rule-under-auto-mode.md`,
`hook-input-from-a-real-session.md`, and `ready-verb-service-start.md`.

## The live script's output

This is the evidence phase of `scripts/live-check.sh`, run at 15:24:41 UTC on 2026-11-18, as
pull request 16 records it.

```text
== evidence 2026-11-18T15:24:41Z ==
$ cc timer status
last_run: 2026-11-18T15:24:24Z (0 minutes ago)
ActiveState: active
LastTriggerUSec: Wed 2026-11-18 15:24:24 UTC
NextElapseUSecRealtime: 
Result: success
ExecMainStatus: 0

item 7: the units verify
$ systemd-analyze --user verify ~/.config/systemd/user/cc-desk-check.service ~/.config/systemd/user/cc-desk-check.timer
item 7: the scope probe's output is in the scope phase's log above

item 6: each pass's record
timer-live-a:
{
  "state": "done",
  "started": "2026-11-18T14:51:21.670670962Z",
  "finished": "2026-11-18T15:18:58.40317894Z",
  "actual_minutes": 12,
  "pull_request": {
    "number": 3,
    "commit": "f5746cae0babd96009c3ecc25959d3eefd5cf019",
    "verdict": "accept",
    "ready": "2026-11-18T15:13:21.030598602Z",
    "merged": "2026-11-18T15:18:58.40317894Z",
    "inside_design": true,
    "merge_called": "2026-11-18T15:18:58.40317894Z",
    "cleaned": "2026-11-18T15:18:58.40317894Z"
  },
  "session": {
    "name": "cc-desk-scratch-timer-live-a",
    "launched": "2026-11-18T15:13:08.05084977Z",
    "launch_tries": 1,
    "relaunches": [
      {
        "time": "2026-11-18T15:13:08.05084977Z",
        "cause": "missing",
        "counted": true
      }
    ],
    "prompts": null,
    "last_seen": "2026-11-18T15:13:21.057978073Z",
    "finished": null,
    "ended": "2026-11-18T15:18:58.40317894Z"
  }
}
timer-live-b:
{
  "state": "done",
  "started": "2026-11-18T14:51:21.688518814Z",
  "finished": "2026-11-18T15:24:30.631885705Z",
  "actual_minutes": 17,
  "pull_request": {
    "number": 4,
    "commit": "2bb936aa905d2d9a3deb763384390592b3979544",
    "verdict": "accept",
    "ready": "2026-11-18T15:19:23.144826856Z",
    "merged": "2026-11-18T15:24:30.631885705Z",
    "inside_design": true,
    "merge_called": "2026-11-18T15:24:30.631885705Z",
    "cleaned": "2026-11-18T15:24:30.631885705Z"
  },
  "session": {
    "name": "cc-desk-scratch-timer-live-b",
    "launched": "2026-11-18T15:18:58.40317894Z",
    "launch_tries": 1,
    "relaunches": [
      {
        "time": "2026-11-18T15:13:08.05084977Z",
        "cause": "missing",
        "counted": true
      },
      {
        "time": "2026-11-18T15:18:58.40317894Z",
        "cause": "missing",
        "counted": true
      }
    ],
    "prompts": null,
    "last_seen": "2026-11-18T15:19:23.171137153Z",
    "finished": null,
    "ended": "2026-11-18T15:24:30.631885705Z"
  }
}

item 6: merge by the check, and zero prompts
timer-live-a merge record: merge_called 2026-11-18T15:18:58.40317894Z, merged_outside false
timer-live-a prompts recorded: 0
timer-live-b merge record: merge_called 2026-11-18T15:24:30.631885705Z, merged_outside false
timer-live-b prompts recorded: 0

item 6: no merge command in the sessions' logs (Bash tool_use calls only)
  transcript ~/.claude/projects/-var-home-glw907-Projects-cc-desk-scratch--claude-worktrees-timer-live-a/70cdede6-109b-495b-bf53-d61e4775ccaf.jsonl: 0 merge call(s)
  timer-live-a: 0 Bash call(s) holding gh pr merge
  transcript ~/.claude/projects/-var-home-glw907-Projects-cc-desk-scratch--claude-worktrees-timer-live-b/08981bd0-c271-4ccc-a573-e1bf14faaf80.jsonl: 0 merge call(s)
  transcript ~/.claude/projects/-var-home-glw907-Projects-cc-desk-scratch--claude-worktrees-timer-live-b/ba577031-41c0-4e53-90b3-2924a0b907e5.jsonl: 0 merge call(s)
  timer-live-b: 0 Bash call(s) holding gh pr merge

item 6: the denials log
  rows under cc-desk-scratch/.claude/worktrees/ after 2026-11-18T14:51:21Z: 0

item 6: relaunch of timer-live-b
[
  {
    "time": "2026-11-18T15:13:08.05084977Z",
    "cause": "missing",
    "counted": true
  },
  {
    "time": "2026-11-18T15:18:58.40317894Z",
    "cause": "missing",
    "counted": true
  }
]

item 6: gone, one command per item
timer-live-a: rows named cc-desk-scratch-timer-live-a in claude agents: 2
$ test ! -e ~/Projects/cc-desk-scratch/.claude/worktrees/timer-live-a
$ git -C ~/Projects/cc-desk-scratch show-ref --verify refs/heads/timer-live-a
fatal: 'refs/heads/timer-live-a' - not a valid ref
(exit 128)
timer-live-b: rows named cc-desk-scratch-timer-live-b in claude agents: 3
$ test ! -e ~/Projects/cc-desk-scratch/.claude/worktrees/timer-live-b
$ git -C ~/Projects/cc-desk-scratch show-ref --verify refs/heads/timer-live-b
fatal: 'refs/heads/timer-live-b' - not a valid ref
(exit 128)
(the worktree and branch are gone when the first two read no rows and exit 0, and show-ref exits 128)

$ git -C ~/Projects/cc-desk-scratch switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
$ systemctl --user disable --now cc-desk-check.timer
Removed '~/.config/systemd/user/timers.target.wants/cc-desk-check.timer'.
$ systemctl --user is-enabled cc-desk-check.timer
disabled
(exit 1)
```
