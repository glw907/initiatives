# The cc-desk command now keeps the state files, and the second pass is starting

The first of the round's four passes has landed. The `cc-desk` command now reads, checks, and
writes every state file, records when a pass starts, finishes, or stops, and prints a snapshot.
The gate also fails on a skipped test. A planner session is writing the plan for the second pass,
which adds the time forecast to the snapshot. Weekly usage read 89 percent, under the 100 percent
stop. Nothing waits for Geoff.

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

The passes still to land, in order:

| Pass | What it builds | Planned minutes | State |
| --- | --- | --- | --- |
| 2 | The snapshot carries the next session's time and range, and each event appends a forecast | 75 | Planning |
| 3 | A start is started, held, or refused by the rules, and the command reads usage | 90 | Waiting on pass 2 |
| 4 | A ruling is recorded only from a desk session, and it frees what waited | 60 | Waiting on pass 3 |

## What went wrong

The first pass had three planning misses and no stop.

- `[mechanism]` The gate's `go test ./...` could replay a cached pass for the end-to-end tests
  after the command's code changed. Those tests build the command in a separate process, which
  the test cache doesn't track. The planner found this after launching the executor, and I passed
  the fix to the executor. The gate now runs `go test -count=1`.
- `[stale-fact]` The round plan said the repo had no dependency. That stopped being true once the
  pass added cobra.
- `[missing-check]` The plan had no case for a clock that runs backward or for a bad subcommand.
  The closing review found both, and the pass fixed them with tests. This tag isn't one of the ten
  that `round-run.md` defines. The nearest is `[design-gap]`.

The pass took one `[advisor]` call, a method choice that avoids an import loop between two
packages. No call needs Geoff.

## What it cost

| Pass | Planned minutes | Minutes taken |
| --- | --- | --- |
| 1 | 90 | 40, from the planner's launch to the merge |

The chain is planned at 315 minutes, and the round starts nothing new past 630. Weekly usage read
88 percent before the first launch and 89 percent after the first pass.

## What is left for later

The first pass filed three follow-ups under `docs/follow-ups/` in cc-desk:

- The reader should refuse a key in the wrong case or a key given twice (`strict-reader-key-case.md`).
- The snapshot should show a pass's stop times (`snapshot-stop-times.md`).
- The command should parse its input before it takes the lock (`input-before-lock.md`).
