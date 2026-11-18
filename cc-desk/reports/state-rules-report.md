# The State and rules round is starting its first pass

The round has four passes that teach the `cc-desk` command to hold the state of every release and
enforce every scheduling rule. A planner session is writing the plan for the first pass, which builds
the state files and the snapshot. The other three passes wait on it in order. Weekly usage read 88 percent before
the launch, under the 100 percent stop. Nothing waits for Geoff.

## What landed

Nothing yet. The passes land in this order:

| Pass | What it builds | Planned minutes | State |
| --- | --- | --- | --- |
| 1 | The command reads, checks, and writes every state file, records pass events, and prints a snapshot | 90 | Planning |
| 2 | The snapshot carries the next session's time and range, and each event appends a forecast | 75 | Waiting on pass 1 |
| 3 | A start is started, held, or refused by the rules, and the command reads usage | 90 | Waiting on pass 2 |
| 4 | A ruling is recorded only from a desk session, and it frees what waited | 60 | Waiting on pass 3 |

## What went wrong

Nothing so far.

## What it cost

The chain is planned at 315 minutes, and the round starts nothing new past 630. Weekly usage read
88 percent on 2026-11-17, before the first launch.

## What is left for later

Nothing filed yet.
