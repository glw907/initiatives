# The start rules have landed, and the last pass is in planning

Three of the round's four passes have landed. The `cc-desk` command keeps the state files,
forecasts the next session with Geoff, and starts, holds, or refuses a pass by the rules, naming
each broken rule. Geoff answered the third pass's one question: a stopped pass that resumes skips
the limit of two passes building at once, as built. The fourth pass, which records rulings, is
in planning. Weekly usage read 90 percent, under the 100 percent stop.

## What landed

[Add the state files, the strict reader, and the first six verbs](https://github.com/glw907/cc-desk/pull/3)
landed with its review at `accept` and no open finding. Its evidence for each acceptance item:

| Item | Evidence |
| --- | --- |
| A broken file stops every verb with an error that names it | `TestBrokenFile` passed: nine broken files, each run against six verbs |
| The gate passes, and fails on a skipped test | `bash scripts/gate.sh` ended `gate: ok`, and the pull request's `gate` check passed |
| Events change a pass's state and record the test clock's time | `TestEvents` passed |
| Bad requests are refused and leave the state folder unchanged | `TestBadRequests` passed, with ten cases |
| A second command waits 10 seconds on a held lock, then exits | `TestLock` passed in 10.03 seconds |
| The gate fails on a skipped test in a scratch copy | `TestGateFailsOnSkip` passed, with five cases |

[Add the estimate to the snapshot](https://github.com/glw907/cc-desk/pull/4) landed with its
review at `accept` and no open finding. Its evidence:

| Item | Evidence |
| --- | --- |
| The next session matches every row of the design's worked table, with the rough mark, the variant, and the round not designed yet | `TestEstimate` passed, with six cases and literal times |
| The gate passes | `bash scripts/gate.sh` ended `gate: ok`, and the `gate` check passed on the last commit |

[Add the start rules and the usage read](https://github.com/glw907/cc-desk/pull/5) landed with its
review at `accept`, no open finding, and the `gate` check passing. Its evidence:

| Item | Evidence |
| --- | --- |
| Waiting order | `TestWaitingOrder` passed, with five cases |
| Limits | `TestLimits` passed, with six cases, the 99 and 100 percent readings among them |
| The usage reader | `TestParse` and `TestUsageReader` passed, and the live check below |
| The gate | `bash scripts/gate.sh` ended `gate: ok`, and the `gate` check passed on the last commit |

The live usage check ran on the workstation, outside CI, in an empty state folder. `cc-desk usage`
printed `90% used, resets Nov 20, 10:59pm (America/Anchorage)`. The saved raw result read 90
percent, a cost of `0`, and `0` model turns.

The pass still to land:

| Pass | What it builds | Planned minutes | State |
| --- | --- | --- | --- |
| 4 | A ruling is recorded only from a desk session, and it frees what waited | 60 | Planning |

## What went wrong

No pass has stopped, and no command was refused.

Geoff ruled on one question from the third pass. The design says "Passes already building carry
on," and the pass read that as letting a stopped pass resume past both limits. Only building
passes count toward the limit of two, so a resume can leave three building. A stopped pass still
holds its worktree and its session, so making it wait costs more than one extra session. Geoff
answered "Yes as built," and pull request 5 landed after the ruling was recorded in its plan. The
design's wording is an `[owner-call]` miss: it should have said whether a stopped pass counts as
building.

Geoff took one call, from the second pass's plan. A round that needs him, with no design and no
work left, fit none of the design's four session states. The pass read it as "Ready now" with no
time. Geoff answered "Those both work," so the built reading stands. He added that a call about
how a state or label reads should be settled from Survey's writing standard, not brought to him.
The conductor passed that to the second pass and passes it to the later planners.

The passes made fifteen `[advisor]` choices: one in the first pass, seven in the second, and
seven in the third. Geoff ruled on two. The rest are method choices.

The first pass had three planning misses:

- `[mechanism]` The gate's `go test ./...` could replay a cached pass for the end-to-end tests
  after the command's code changed. Those tests build the command in a separate process, which
  the test cache doesn't track. The planner found this after launching the executor, and the
  conductor passed the fix on. The gate now runs `go test -count=1`.
- `[stale-fact]` The round plan said the repo had no dependency. That stopped being true once the
  pass added cobra.
- `[missing-check]` The plan had no case for a clock that runs backward or for a bad subcommand.
  The closing review found both, and the pass fixed them with tests. This tag isn't one of the ten
  that `round-run.md` defines. The nearest is `[design-gap]`.

The second pass had three planning misses, written with no tag. By their content they are a
`[file-list]` miss (its tests sit in other files than the plan named), a `[mechanism]` miss (the
plan's ruling line went in before Vale read it, which turned one commit's check red), and a
`[design-gap]` miss (a question that no pass rests on, below).

The third pass had two planning misses. `[file-list]`: three files the plan's list didn't name.
`[mechanism]`: the plan's CI watch listed runs by commit, which returns nothing, so it should list
them by branch. Its pull request body first named each acceptance item by its label only, and the
conductor had the executor copy each item in full.

## What it cost

| Pass | Planned minutes | Minutes taken |
| --- | --- | --- |
| 1 | 90 | 40 |
| 2 | 75 | 44 |
| 3 | 90 | 54 to a ready pull request, landed after Geoff's ruling |

Minutes run from the planner's launch to the merge. The chain is planned at 315 minutes, and the
round starts nothing new past 630. Weekly usage read 88 percent before the first launch and 89
percent after the second pass, and 90 percent after the third.

## What is left for later

The passes filed six follow-ups under `docs/follow-ups/` in cc-desk:

- The reader should refuse a key in the wrong case or a key given twice (`strict-reader-key-case.md`).
- The snapshot should show a pass's stop times (`snapshot-stop-times.md`).
- The command should parse its input before it takes the lock (`input-before-lock.md`).
- A written question that no pass rests on gets a forecast line with no time, while the snapshot
  shows one (`orphan-question-forecast.md`). Its two fixes differ in what "Ready now" means, so it
  needs Geoff's choice when it is taken up. It holds no pass in this round.
- A resumed stopped pass can leave three passes building (`resume-skips-the-limits.md`). Geoff kept the rule as built,
  so the file is a record, not open work.
- A failed usage reading, once cached, holds every start for up to five minutes, and a guess
  given on a resume is dropped without a word (`reading-errors-and-guess-on-resume.md`). The first
  trades retry cost against waiting time, so it needs Geoff's choice when it is taken up.

One rule waits for a home. Geoff's guidance to settle wording calls from Survey's writing standard
belongs in `pass-core`'s advisor reference, which sorts the calls that reach him. Changing it takes a
separate pass.
