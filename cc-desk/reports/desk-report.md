# The desk round has landed all six passes, and Geoff's sitting is next

The Desk and skills round builds the desk session that `cc-desk` opens, the two skills, the
page's report pages, and the check's repairs, then rehearses one run with nobody tending it.
All six passes have landed: the records (pull request 17), the skills (18), the page (19), the
desk (20), the check's repairs (21), and the rehearsal with the real run's setup (22). In the
scratch repo, one typed answer led to a merged pull request and a report with nothing else
typed, and the recovery checks passed on the live page. The real release is set up, and the
page shows one question waiting for cc-desk. Geoff's sitting finishes the round.

## What waits for Geoff

1. Your sitting: five steps at the terminal, listed under "Open decisions" in cc-desk's
   `docs/STATUS.md`. Type `cc-desk` and answer the question about stuck sessions in your words.
   Confirm the ruling on the page, then walk away while the build merges. Read the report and
   mark it read, and click the terminal link once in Chromium. If anything else asks for you
   while you are away, the run has failed its test.
2. The Move design, `docs/specs/2026-11-19-move-design.md`, needs a rewrite before you approve
   it. dubplate's `structure` round and cairn's `checks` round run under their own conductors
   this week, so Move's first act and its Questions 1 and 4 must match what those rounds leave
   behind.
3. The 1.1 design session, after the sitting
   (`docs/plans/2026-11-19-1.1-design-prompt.txt`).

## What behaves differently now

[Pull request 17](https://github.com/glw907/cc-desk/pull/17) gives questions, rulings, reports, rounds, and stops the fields the desk and the page show. The check keeps a log, and the new `brief` verb prints what waits, ordered by the planned minutes each question holds up. The new verbs are `brief`, `report add`, `report read`, `question add`, and `ruling record --replaces`.

[Pull request 19](https://github.com/glw907/cc-desk/pull/19) makes the status page show reports to read, each with one "Mark as read" form, and a waiting round's design. It also shows what each check chose and each pass's permission prompts and refused commands. The page's unit can write to the state folder and nothing else. The binary installed from main after pass 5 has the `report` verb that "Mark as read" calls.

[Pull request 18](https://github.com/glw907/cc-desk/pull/18) adds the two skills, `cc-desk` for the desk session and `cc-desk-work` for every session cc-desk launches, and `docs/guide.md`. The three launch prompts now name `cc-desk-work` in place of the Approval Queue rules. Live sessions given the desk skill opened correctly on all three test cases. The skills describe the desk that pass 3 builds, so the guide carries a caveat line until pass 3 proves each claim.

[Pull request 20](https://github.com/glw907/cc-desk/pull/20) makes `cc-desk` open the desk: an Opus session at high effort, on the brief, with no permission prompt. A typed answer there becomes a ruling, a replacement before a pass starts takes effect, and a merge answer is carried out by the check. A replaced pass whose session had already finished now relaunches; the live run found that gap. It was proven live in the scratch repo.

[Pull request 21](https://github.com/glw907/cc-desk/pull/21) makes the check's five repairs.
A session cc-desk launches now records each command auto mode refuses, with the reason. A usage
stop waits for the reset time it names. After a merge the check stops the pass's session and
logs the stop. The merge call, the fetch, and the pull each give up at 60 seconds, and three
failed merge calls in a row become a question. When a report falls due and no conductor runs,
the check starts one. `pass ready` also takes a third verdict, escalate, with a count of calls
for Geoff, and the check merges only when that count is 0. Its fifth live run, on the last
change to the code, passed all 70 checks, and a listing each minute for 10 minutes showed the
merged session gone.

The fresh conductor, `conductor-cc-desk`, did the steps after pass 5. Its read of both skills
against the design found no line to fix, so no fix landed under standing answer 32. It tagged
`main` as `v0.1.0` at `013f7ef` and pushed the tag. [Workstation pull request
251](https://github.com/glw907/workstation/pull/251) adds the two skills to the vendored-skills
manifest at that tag and nothing else, as answer 34 asks. A whole-branch review accepted it
with no finding, and it landed with `approval-queue land`. The conductor then installed the
binary, the timer, the page, and the link handler from `main`. `claude-tooling-sync verify`
exits 0 and lists both skills, both read under `~/.claude/skills/`, and the page answers at
<http://127.0.0.1:7908/>. Auto mode refused none of these steps.

Pass 6 (`desk-run`, [pull request 22](https://github.com/glw907/cc-desk/pull/22)) adds
`cc-desk release done <project>`, which ends a release, and `cc-desk session end`, which stops a
record's open session through the binary. Each report now carries its release's name. The pass
also adds the shared allow rules, the real release's setup script with its check, and two live
scripts for the scratch repo. Its kill probe (`docs/research/2026-11-20-kill-probe.md`) found
that a lone `kill` doesn't end a pass. Claude Code's supervisor brings the session back within
11 seconds, so every pass death in the live checks goes through `session end`. The conductor
still dies by a lone `kill`.

All three scripts passed live, and each one's whole output is a comment on the pull request. In
the rehearsal, one typed answer started the pass, and the timed check merged its pull request.
The session, worktree, and branch were gone at the first read after the merge. The conductor
then started by itself and recorded one report. The run saw 0 permission prompts and 0 refused
commands, and 4 transcripts held no merge command. The recovery checks saw the conductor back
6 seconds after its kill. A pass that died three times stopped at its relaunch limit after two
relaunches, and the page read "Needs you now" with the round's name. In 99 saved lists, no list
showed two live rows for that pass. The `ask` rule's prompt reached the record 8 seconds after
its launch, and the page named the command. The setup check, run on a copy of the state folder,
showed one question waiting for cc-desk.

Two points in pass 6 were Geoff's calls, and he approved both on 2026-11-20. Item 8's "killed"
reads as `session end` for the pass deaths, and the two outputs from `d454634` stand under
answer 82, since no file those scripts run changed after that commit. The conductor's
whole-branch review of the last commit, `3c29181`, accepted the pass with six Low findings,
filed in `docs/follow-ups/desk-run-review-notes.md`. The pass landed with `approval-queue land`
at 21:00 UTC as `0720001`.

After the merge the conductor installed `main`'s binary, timer, and page, and ran
`scripts/setup-release.sh` on the real state folder. It added the release
`cc-desk-stuck-sessions`, whose one round, `stuck-sessions`, is planned at 60 minutes and asks one
question: "Should cc-desk notice by itself that you fixed the problem?" The snapshot shows that
question waiting for cc-desk, no session running, nothing under "Needs you now", and the next
session ready now. No skill changed in pass 6, so the skills stay at `v0.1.0`.

The Move design session, launched beside pass 6 under standing answer 39, pushed its design,
round plan, five planner prompts, and conductor prompt to cc-desk's `main` at `aa2b88f`. It
copies cairn's route into cairn-cms and `dubplate`'s designs and kept drafts into `dubplate`, so
each round's design sits in its own repo. It writes the two release files with a test, and
builds design writers that start on the timer. Five passes are planned at 535 minutes, 310 on
the longest line. The conductor's read found one gap: the start line's busy check on cairn-cms
would always name the blocked `cairn-cms-tool-delete` session and refuse. The line now expects
that hit (`6ca3420`).

## What went wrong

One judgment at the start: `claude-worktree-busy` on the main checkout exited 1
on the interactive session that launched this conductor. That session ran only a watch for the
first planner, so the conductor didn't count it as a stop.

A stray job named `close-desk-records-round` appeared in the cc-desk checkout at 11:46 as a
failed launch with no prompt. Auto mode refused the conductor's `claude stop` on it. Geoff then
told the conductor to stop it, and the second `claude stop` ran: `stopped d5647ebf`.

Pass 1 made nine method calls through the advisor, none of them for Geoff, and had one planning miss: `[mechanism]` the plan said every refusal exits 1, and the code exits 2. Its first body read `Calls: 9 under Decisions` and held no test output, so the conductor sent it back for a body fix before landing.

Pass 2 parked at planning: its plan priced 170 minutes against 75, past twice the estimate. The planner found work the round hadn't priced: the `question add` and `report add` command lines pass 1 left to it, three new fixture folders, and a live script that checks three fresh sessions. The conductor asked at about 14:25, and Geoff's answer came just before the ruling's commit at 15:01: "Raise to 105 (Recommended)". The ruling is under `## Rulings` in the pass's plan, and the executor launched as planned. This is an `[estimate]` planning miss.

Pass 4 had two planning misses: `[mechanism]` the plan named an old shape for Kit's route matchers, and `[check]` its bundle check matched comment text. Its first body left out the gate check's exact wording and the gate's output, and its misses had no tags. The conductor sent it back once for a body fix, as it had with pass 1. The pass made no calls for Geoff and had no red CI run.

Pass 2's closing review escalated one point: the skills and the guide state behaviors that only pass 3 builds. The executor kept them, with a caveat line and `docs/follow-ups/desk-skills-review-notes.md` listing each claim for pass 3. A review short of accept can't land without a call, so the conductor asked Geoff at 15:56. He answered "Land it (Recommended)", and the pass landed at 18:07. The two hours of waiting held up pass 3. Pass 3 parked at planning: its plan priced 255 minutes against 100. The planner priced every clause of done items 3 to 5, and a plan review found six places where the code doesn't work as the plan first said, which raised the count from 210. The conductor asked at about 19:05, and Geoff's answer came just before the ruling's commit at 20:50: "Raise to 140 (Recommended)". The ruling is under `## Rulings` in the pass's plan. This is an `[estimate]` planning miss.

After PR 18, Geoff gave two standing answers, rulings given ahead of time and numbered in the round plan, so later stops don't wait on him: 26 lets a review that escalates land when the advisor settled each point, and 27 approves ahead of time the tag, the `~/.dotfiles` PR, the install, and the real release. Both are in the round plan at `81afc1d`.

Both estimate stops were preventable, as Geoff pointed out. The three stops cost about 58, 131, and 120 minutes of the round's clock. The round plan priced each pass from its outline, and every planner that priced the evidence clause by clause came out about twice as high (pass 1: 120 against 209; pass 2: 75 against 170; pass 4: 90 against 170; pass 3: 100 against 255). Pass 1's path showed the pattern before passes 2 and 3 were planned, and the conductor didn't ask for a standing answer then. Pass 2's review escalation was foreseeable too, since the design orders the skills before the desk they describe. Geoff then gave standing answer 28: the conductor raises an estimate itself when the plan parks only over its estimate and its scope matches the design. `docs/follow-ups/round-estimates-priced-from-evidence.md` (at `af5ea47`) proposes the fix in cc-desk itself, an estimate rule on the release and a miss signal in the brief after a round's first pass, and in `pass-core`'s round and planner references.

A Fable review of the failures (kept with the round's records) disagrees with the conductor on the first cause. In nine PRs with both figures, plan paths added to 1,405 minutes and measured time to 355, so the round's estimates were near the truth and the plan paths were the wrong number to stop on. It traces the stops to `round.md` "Parking at planning", to the landing test reading the review's word in place of open findings and calls, and to the round plan replacing "starts once that pass's PR is ready, whatever its verdict". It also finds that cc-desk as built would repeat them: `pass ready` has no line for an `escalate` verdict, a merge question holds every pass behind it, and standing answers have no record.

Pass 3 had five planning misses besides its estimate: three `[mechanism]` (the start tests' file, a finished session's relaunch, and the branch the merge fixture pushes), one `[stale-fact]` (the link handler refuses when `cc-desk` is not on `PATH`), and one `[ambiguous]`. Auto mode refused one `rm` of a file in the real state folder during cleanup, and the file was left alone. Its first review read `fix`, and a fresh read accepted the folded branch.

Pass 2 also had two `[file-list]` misses: the CI workflow wasn't in task 3's file list, and the review-notes follow-up was new at close.

Pass 5 stopped for Geoff or for the conductor seven times:

| Stop | Waited | What happened |
| --- | --- | --- |
| Its estimate, past the clock | about 10.5 hours | The plan priced 315 minutes against 100 and parked at about 00:00. Standing answer 28 lets the conductor raise an estimate itself, but only when the raised estimate still fits the round's clock, and this one didn't. Earlier the conductor had asked Geoff whether pass 6 could start past the clock, which became answer 31, and didn't check whether answer 28 would hold for pass 5. Geoff answered at 10:39: "Raise to 175, go (Recommended)". |
| A leftover live session | about 85 minutes unseen | A blocked scratch session from the pass's earlier probe kept its live script from starting. The conductor watched only for a ready pull request and didn't see the blocked executor until Geoff asked how the round was going. Geoff chose "Yes, and from now on", which became standing answer 33. |
| Idle waits between its four live runs | about 20 and 35 minutes | The live script left the sessions it launched running after a failed check, which held the next run for about 20 minutes. Later an executor wrote its stop and then waited on CI instead of ending, and nobody read the stop for about 35 minutes. |
| The escalated review | about 45 minutes and a question | Live run 4 showed that a finished session stays listed as done after `claude stop`. The executor changed one of the three stop paths and its test, and left the plan and the other two paths on the old rule. The pass had reached its stop, twice its 175 minutes. Geoff ruled "Fix it now, go past 350 (Recommended)", and the fix put one rule in one helper for all three. |
| A question from the conductor | about 100 minutes | The second conductor asked Geoff about pass 6's estimate with a question that held its turn. The fix executor finished 2 minutes later, and its review waited for his answer. He chose "Raise to the plan's path (Recommended)", now standing answer 35. |
| The live rerun | about 55 minutes | The next review found that the fix changed code on the paths the live run tests, after run 4. The executor ran the whole script again (run 5), and it passed. |
| The last review | about 40 minutes | The read of the final commit escalated one point. The 10-minute listing ran 16 to 25 minutes after the merge, because the script restarted its reader and erased the reads taken from the merge. The design asks for a listing each minute for 10 minutes and doesn't fix its start, so a Fable read chose to land. Pull request 21 landed under standing answer 26 at 07:40 UTC, with the fix handed to pass 6, whose own check reads from the merge. |

Six standing answers came during pass 5. Answer 31 lets pass 6 start past the conductor's clock.
Answer 32 fixes a skill line the design doesn't back before the tag. Answer 33 lets the
conductor stop leftover scratch sessions. Answer 34 puts a 1.1 round, which answers the lessons
ledger, before Move, and keeps the `pass-core` edits out of the PR that installs the skills.
Answer 35 raises pass 6's estimate to its plan's figure when the plan stops only over its
estimate. Answer 36 stops this round after pass 5 and leaves pass 6 to a fresh conductor.

Two misses came in the steps after pass 5. `claude-tooling-sync update-skills` rewrote the
manifest's one em dash as an escape, and the conductor reverted that line by hand. And the real
state folder still held everything pass 5's live runs left there: 14 scratch rounds, 15 stopped
sessions under "needs you now", and 6 unread reports, all on the page. Both are ledger rows, and
pass 6's launch prompt tells its planner to clear the scratch state.

Geoff gave standing answer 37 during the steps after pass 5: "I'd like to start the work on both
cairn and dubplate once we hit the cc-desk version 1.0. We can work on cc-desk 1.1 concurrently
with those efforts." The conductor reads 1.0 as this round finished, with Geoff's sitting
passing done item 10, and rewrote both design prompts to run side by side.

The round changed conductors after pull request 20: Geoff asked for a fresh session because the
first had grown long and missed stalls, and the second took over at about 19:05 with a written
hand-over.

Pass 6 stopped three times, each a ledger row:

| Stop | Waited | What happened |
| --- | --- | --- |
| Its estimate | none | The plan priced 675 minutes against 90 and parked over its 180-minute line. Its scope matched the design and nothing was trimmed, so the conductor raised it under standing answer 35. |
| The launch check | a few minutes | The hook refused the executor's launch because the plan's Pre-flight list had no `Evidence:` line. The conductor added one and relaunched. It had also committed the raise in the planner's worktree while the planner was still editing, which touched only the conductor's lines. |
| GitHub billing | about 8 hours | Actions stopped starting jobs at 09:12 UTC, because the account's billing failed and both cc-desk repos were private. The executor did every task that needs no CI, then wrote its stop at 10:49 and ended. Geoff had the conductor make both repos public at about 16:55, and the pass resumed at its rehearsal at 17:01. |

Geoff gave two standing answers in the steps after pass 5. Answer 38 lets pass 6 run overnight,
relaunching once past twice its path and landing calls inside its design. Answer 39 moved the
Move design ahead of the sitting: "Do we even need to wait for the rehearsal?"

After the resume, pass 6's live runs found four faults in its own scripts, and each fix was run
again. The page draws in the browser, so its HTML holds no reports and the checks read
`/api/state`. A jq precedence slip blanked the conductor's page check. The scratch conductor
finishes 11 to 26 seconds after its launch, so one recovery run missed its return between two
minute reads and another lost the race with the kill. The fast reads every few seconds in the
first minute fixed both. The pass's planning misses are two `[mechanism]` (a kill guard that
could never pass, and the page's HTML), one `[stale-fact]` (the billing stop), and one
`[estimate]` (the conductor's run time).

dubplate and cairn-cms ran rounds under their own conductors on 2026-11-20 while pass 6
finished. The three conductors agreed on one rule: at most four planners or executors on
pavilion between them, no new session past 85 percent weekly usage, and a message to the others
before each launch. Geoff ruled that both projects run on their own for now: "We'll bring both
other [initiatives] under the cc-desk regime once cc-desk is ready." The Move design, written
overnight while both projects were idle, was overtaken before its approval, and that is a row in
the lessons ledger.

## What it cost

| Pass | Planned minutes | Taken minutes |
| --- | --- | --- |
| 1, the records | 120 | 107 |
| 2, the skills | 75, raised to 105 by Geoff | about 140 to ready, planning included, then about 130 waiting for Geoff |
| 3, the desk | 100, raised to 140 by Geoff (plan path 255) | about 144 to ready, then landed at once |
| 4, the page | 90 (plan path 170) | about 90, planning included |
| 5, the check's repairs | 100, raised to 175 by Geoff (plan path 315), then allowed past its 350-minute stop | about 425 working: 50 planning and 375 over six executor runs, across about 12 hours of clock after Geoff's answer to the park |
| 6, the run nobody tends | 90, raised to 675 under answer 35 | about 310: 79 before the billing stop and about 230 after the resume, with 5 fix rounds, 4 red CI runs (all during the billing block), 1 attended event, and no escape |

Weekly usage before the round: 5 percent, 8 percent after three passes, 10 percent after four, 13 percent after five, and 16 percent at pass 6's stop, and 22 percent after it landed, with the reset on Nov 20 at 11 PM Alaska time.

## What is left for later

- `designed-round-with-no-questions-reads-nothing.md`, from pass 1.
- `desk-fixture-connection-dropped.md`, new from pass 4, and `blocked-session-reads-as-unreadable-stop.md`, reworded by pass 4.
- `desk-skills-review-notes.md`, new from pass 2, for pass 3 to clear.
- From pass 3: `desk-open-review-notes.md`, `closed-pass-leaves-its-worktree.md`, `close-answer-failed-stop-can-be-replaced.md`, and `exec-failure-after-register-leaves-entry.md`.
- `round-estimates-priced-from-evidence.md`, from the conductor, now for the 1.1 design.
- From pass 5: `conductor-worktree-removal-gaps.md`, `live-scripts-start-a-conductor.md`, and
  `live-abort-waits-on-stopped-sessions.md`.
- `desk-run-review-notes.md`, from pass 6's closing review: six Low findings and the
  executor's one.
- The lessons ledger, `docs/follow-ups/desk-round-lessons.md`, which the 1.1 design answers row
  by row.
