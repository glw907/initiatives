# The cc-desk command now forecasts the next session, and the third pass is starting

Two of the round's four passes have landed. The `cc-desk` command keeps the state files, and its
snapshot now carries each release's pace and the time of the next session with Geoff. Each pass
event also appends a forecast line. A planner session is writing the plan for the third pass,
which adds the rules that start, hold, or refuse a pass and the usage read. Weekly usage read 89
percent, under the 100 percent stop. Nothing waits for Geoff.

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

The passes still to land, in order:

| Pass | What it builds | Planned minutes | State |
| --- | --- | --- | --- |
| 3 | A start is started, held, or refused by the rules, and the command reads usage | 90 | Planning |
| 4 | A ruling is recorded only from a desk session, and it frees what waited | 60 | Waiting on pass 3 |

## What went wrong

No pass has stopped, and no command was refused.

Geoff took one call, from the second pass's plan. A round that needs him, with no design and no
work left, fit none of the design's four session states. The pass read it as "Ready now" with no
time. Geoff answered "Those both work," so the built reading stands. He added that a call about
how a state or label reads should be settled from Survey's writing standard, not brought to him.
The conductor passed that to the second pass and passes it to the later planners.

The passes made eight `[advisor]` choices: one in the first pass, and seven new ones in the
second. All but the one Geoff ruled on are method choices.

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

## What it cost

| Pass | Planned minutes | Minutes taken |
| --- | --- | --- |
| 1 | 90 | 40 |
| 2 | 75 | 44 |

Minutes run from the planner's launch to the merge. The chain is planned at 315 minutes, and the
round starts nothing new past 630. Weekly usage read 88 percent before the first launch and 89
percent after the second pass.

## What is left for later

The passes filed four follow-ups under `docs/follow-ups/` in cc-desk:

- The reader should refuse a key in the wrong case or a key given twice (`strict-reader-key-case.md`).
- The snapshot should show a pass's stop times (`snapshot-stop-times.md`).
- The command should parse its input before it takes the lock (`input-before-lock.md`).
- A written question that no pass rests on gets a forecast line with no time, while the snapshot
  shows one (`orphan-question-forecast.md`). Its two fixes differ in what "Ready now" means, so it
  needs Geoff's choice when it is taken up. It holds no pass in this round.

One rule waits for a home. Geoff's guidance to settle wording calls from Survey's writing standard
belongs in `pass-core`'s advisor reference, which sorts the calls that reach him. Changing it takes a
separate pass.
