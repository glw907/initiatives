# Run sheet: round `ur-ws`

The conductor `conductor-dotfiles` follows this sheet with `ur-rules.md`, sections "Every
session", "Conductor", "Stops", and "Report". It decides nothing. A case neither file covers
parks the pass in flight and goes in the report.

Repo `glw907/workstation`, main checkout `~/.dotfiles`, default branch `main`. The adapter is
`dotfiles-pass`, and the gate is `bash scripts/gate.sh`, which the executors run. The repo has no
PR test CI. A merge is live on the machine as soon as the main checkout is pulled.

## Order

| Pass | Title | Planned minutes | Waits for | Planner prompt | Executor seat |
| --- | --- | --- | --- | --- | --- |
| W1 | The busy check reads only a running pass | 45 | nothing | `ur-w1-planning-prompt.txt` | Sonnet, `medium` |
| W2 | The pass report counts planning misses by class | 60 | W1 | `ur-w2-planning-prompt.txt` | Sonnet, `medium` |
| W4 | The round rules in `pass-core` | 150 | W2, and the queue live through Q4 | `ur-w4-planning-prompt.txt` | Fable 5.2, `medium` |
| W5 | The packet skill, the adapters, and the guards doc | 100 | W4 | `ur-w5-planning-prompt.txt` | Fable 5.2, `medium` |
| W3 | The launch guard and the pass section of `CLAUDE.md` | 75 | W5 | `ur-w3-planning-prompt.txt` | Sonnet, `medium` |

The passes run in the table's order, one at a time: W1, W2, W4, W5, W3. The prompts sit beside
this file. Planned minutes total 430, so the clock stop is 860. Time spent waiting for the queue
round doesn't count.

Session names: planner `dotfiles-ur-<p>-plan`, executor `dotfiles-ur-<p>`.

## The wait for the queue round

W4, W5, and W3 launch only when both of these hold.

1. The file `../reports/ur-queue-report.md` holds the line `Queue live through: Q4`.
2. The Q4 PR is merged and pulled. Find it with `gh pr list --repo glw907/approval-queue --state
   merged --json number,body,mergeCommit` and the body line `Pass: Q4`. Its merge commit must be
   an ancestor of `HEAD` in `~/Projects/approval-queue`
   (`git -C ~/Projects/approval-queue merge-base --is-ancestor <oid> HEAD`).

After W2 ends, if the first doesn't hold yet, refresh the report with `Round state: running` and
a line saying the round waits for the queue. Then wait in the background and end the turn:

```bash
timeout 1500 bash -c 'f=$HOME/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds/reports/ur-queue-report.md;
until grep -Eq "^Queue live through: Q4|^Round state: ended" "$f" 2>/dev/null; do sleep 60; done; echo changed'
```

Exit 124 means nothing changed. Before you start the wait again, find the latest row named
`conductor-approval-queue` in `claude agents --json --all`. The queue round has ended first
when the report reads `Round state: ended` without `Queue live through: Q4`. It has also ended
first when that row isn't live, or is missing, and the report lacks the `Q4` line or doesn't
exist. In either case launch nothing more: W4, W5, and W3 stay `not started`, and the report
says the queue round ended first.

## W3, by Geoff's second answer

Read the second answer in `ur-rulings.md`.

**"An executor writes and tests it in a worktree, and the PR waits for your approve."** W3 is
marked as waiting for Geoff and never lands. When it ends ready, send one close packet naming
its PR. On an approve, run `approval-queue merge <id>` and pull `~/.dotfiles`. If auto mode
refused the executor's edit of the guard or of `CLAUDE.md`, the pass parks with the change as a
patch in its PR body, and you send a stop packet (build standing answer 4). Its one step is
Geoff's: applying the patch. On his answer relaunch nothing, since the executor would meet the
same refusal. W3's row reads `waiting`, and the report says the patch is his to apply.

**"No session edits either file: the change comes to you as a patch with the commands to apply
it."** W3 is marked as waiting for Geoff and never lands. Its PR carries a `## Before merge`
section, so the close packet holds that section's forced call with the skill's two choices, and
recommends "I'll run it myself". If Geoff answers that, merge nothing: W3's row reads `waiting`,
and the report lists the section's commands as his. If he answers "The session runs it, then
merges", run the section's commands as written, then `approval-queue merge --premerge-done
glw907/workstation#<n> <id>`, and pull `~/.dotfiles`. If auto mode refuses one of the section's
commands, stop there, merge nothing, and say so in the report.

**"Leave the launch guard and `CLAUDE.md` as they are."** Never launch W3. Its row reads
`skipped`, and the report says Geoff chose that.

## After a workstation pass lands

Run `git -C ~/.dotfiles pull --ff-only`. Run no `stow` and no `claude-tooling-sync apply`: no
pass adds a script or changes a setting. If a landed PR did either, say so in the report and
launch nothing more.

Read `../reports/ur-queue-report.md` before each `land` and each packet. Once it reads `Queue
live through: Q3` or `Q4`, pass `--round ur-ws` to `land` and put `"round": "ur-ws"` in fact
files. Once it reads `Q4`, send each report with `approval-queue report unattended-rounds ur-ws
<report file>`.

## Each pass, in order

1. The steps under "Before each launch" in `ur-rules.md`. Before W4, W5, and W3, also check the
   two conditions above. Then launch the planner.
2. Wait for the planner, then the executor, as `ur-rules.md` says.
3. Land, wait for a close packet, park, or relaunch, by the test in `ur-rules.md`.
4. After a landing, the step above. Then the next pass.

A parked pass holds every later pass in this repo, so nothing launches until Geoff answers its
stop packet.

## Ending

Set `Round state: waiting for Geoff` while a packet of this round waits, and keep the session up
on the packet's background command. Set `Round state: ended` and write the final report when one
of these holds, then end with a line that starts `ROUND END:`.

- Every pass is merged and pulled, or skipped by Geoff's answer.
- Launches ended on the queue round ending first, a busy check, a third idle planner, or the
  clock stop, no pass is in flight, and no packet of this round waits.
- Every pass is merged, skipped, or left unmerged by Geoff's answer, or by a step in this sheet
  or in `ur-rules.md` that says to launch or merge nothing more. No pass is in flight, and no
  packet of this round waits.

The final report's `Resume from:` line names `ur-ws-conductor-prompt.txt` by its full path.
