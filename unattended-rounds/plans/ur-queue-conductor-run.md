# Run sheet: round `ur-queue`

The conductor `conductor-approval-queue` follows this sheet with `ur-rules.md`, sections "Every
session", "Conductor", "Stops", and "Report". It decides nothing. A case neither file covers
parks the pass in flight and goes in the report.

Repo `glw907/approval-queue`, main checkout `~/Projects/approval-queue`, default branch `main`.
The repo has no CI and no adapter. Its gate is `bash scripts/gate.sh`, which the executors run.

## Order

| Pass | Title | Planned minutes | Waits for | Planner prompt | Executor seat |
| --- | --- | --- | --- | --- | --- |
| Q1 | Approve reads the design where the packet found it | 60 | nothing | `ur-q1-planning-prompt.txt` | Sonnet, `medium` |
| Q2 | A stop packet is answered, and a PR merges into the default branch | 90 | Q1 | `ur-q2-planning-prompt.txt` | Sonnet, `medium` |
| Q3 | The round on packets, landings, and pages | 120 | Q2 | `ur-q3-planning-prompt.txt` | Sonnet, `medium` |
| Q4 | The round report as an item | 120 | Q3 | `ur-q4-planning-prompt.txt` | Sonnet, `medium` |

The prompts sit beside this file. Planned minutes total 390, so the clock stop is 780.

Session names: planner `approval-queue-ur-<p>-plan`, executor `approval-queue-ur-<p>`.

## Which way the passes merge

Read the third answer in `ur-rulings.md`.

**"All four queue passes land themselves after the whole-branch review."** Each pass lands when
the land test in `ur-rules.md` passes. A worktree is cut from `origin/main`, and the next pass
launches only after the one before it has merged, been pulled, and been restarted. The one
exception is a pass that waits for a close packet: `ur-rules.md` cuts the next pass from its
branch, and no later pass lands.

**"Q1 and Q2 each wait for your approve, and Q3, Q4, W4, W5, and W3 wait behind them."** Q1 and
Q2 are marked as waiting for Geoff and never land. When Q1 ends ready with its review accepted,
send one close packet that names its PR at once, and launch nothing while it waits. On an
approve, run `approval-queue merge <id>`, pull, and run the after-landing steps. Then run Q2 the
same way. Q3 and Q4 land by the land test. Every worktree is cut from `origin/main`.

## After a queue pass lands

1. `git -C ~/Projects/approval-queue pull --ff-only`.
2. From Q1 on, run `approval-queue restart`. Before Q1 has landed the command doesn't exist,
   and no restart is needed.
3. On exit 0, set the report's line to `Queue live through: <Qn>`.
4. On any other exit, the old server keeps answering. Launch no further pass, leave the line as
   it was, and say in the report that the restart failed, with its output. Don't run `pkill`,
   `npm run build`, or the README's cutover steps by hand.

Once the line reads `Q3`, pass `--round ur-queue` to `land` and put `"round": "ur-queue"` in
fact files. Once it reads `Q4`, send each report with `approval-queue report unattended-rounds
ur-queue <report file>`. If `ur-std-report.md` sits in the reports folder at that point and the
round `ur-std` has ended, send it the same way with `ur-std` as the round.

## Each pass, in order

1. The steps under "Before each launch" in `ur-rules.md`, then launch the planner.
2. Wait for the planner, then the executor, as `ur-rules.md` says.
3. Land, wait for a close packet, park, or relaunch, by the test in `ur-rules.md`.
4. After a landing, the steps above. Then the next pass.

A parked queue pass holds every later queue pass, so nothing launches until Geoff answers its
stop packet. The round `ur-ws` reads your report to learn that.

## Ending

Set `Round state: waiting for Geoff` while a packet of this round waits, and keep the session up
on the packet's background command. Set `Round state: ended` and write the final report when one
of these holds, then end with a line that starts `ROUND END:`.

- Every pass is merged, pulled, and restarted.
- Launches ended on a failed restart, a busy check, a third idle planner, or the clock stop, no
  pass is in flight, and no packet of this round waits.
- Every pass is merged or left unmerged by Geoff's answer, or by a step in this sheet or in
  `ur-rules.md` that says to launch or merge nothing more. No pass is in flight, and no packet
  of this round waits.

The final report's `Resume from:` line names `ur-queue-conductor-prompt.txt` by its full path.
