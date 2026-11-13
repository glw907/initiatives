# The new Approval Queue is built, and its switch waits for the workstation round's close packet

Round aq-rewrite, glw907/approval-queue, written 2026-11-13

Round state: ended, A6 held for the workstation round's close packet

The new queue is built. Its document library, commands, front page, document page, decisions, `merge`, and note threads landed as passes A1 to A5, and each is merged and pulled. A6, the switch, is open as approval-queue#24, ready, with its review accepted and no open finding. Nothing merges until you approve the one close packet that the workstation round's conductor sends, which carries A6 with the workstation's skill changes. Until then both machines run the old queue on port 7907. Nothing waits for you from this round.

## What behaves differently now

**The old queue is still the live one.** Pull request #24 deletes the old app, the bash command, and their tests, moves `next/` to `approval-queue/`, and turns `bin/.local/bin/approval-queue` into a short launcher. The first `approval-queue restart` after the merge builds the new app, swaps it in on port 7907, and archives the old state into `archive-2026-11.tar.gz`.

**`restart` guards the switch.** It refuses while an old item is undecided and names the item. It archives only after the new server answers, and a failed start leaves the old state where it was. The pull request's description lists the commands that undo the switch. The executor ran the switch and the undo once against a copy of the real state directory (102 entries, 449 items).

**The seven retired subcommands answer with one line.** Each prints a line naming the `approval-packet` skill and exits 1, even in a clone with no `node_modules`.

**The README and backlog are rewritten.** The README describes the document, the nine commands, and the store. The thirteen swept backlog items are closed, and seven new ones are filed.

## What went wrong

**A4 stopped once, and A6 inherits its leftovers.** The accessibility reader kept finding problems on the page's refused-answer path. You chose one more rework, a second read still found four small points, and the conductor landed A4 under your ruling without one acceptance item. Those four points are filed as backlog #74.

**A3's reading column is 82 characters on three lines where the design says 80.** It is the mockup's 36.5rem, and the design says the mockup wins for anything seen on a page. The call went into A3's decisions. Narrowing the column to about 35.5rem would meet the design.

**A3 waited about 70 minutes for its launch.** The busy check named A2's planner, then this conductor's own wait script, so A2 and A3 did not run together. The wait scripts no longer pass the checkout path.

**The first conductor ended on a false busy check.** A leftover language server from A5's deleted worktree made `claude-worktree-busy` exit 1. After the workstation round's D0 fix, the check exits 0, and this conductor resumed and launched A6.

**Auto mode refused `claude stop` on the finished A5 session (4957d346) twice, and it was not retried.** The session is idle and holds no work. It is listed under "What is left".

Planning misses: A1 and A2 none. A3 four ([file-list], [mechanism], [count], [ambiguous]). A4 four ([file-list] 2, [mechanism], [owner-call]). A5 four ([file-list] 2, [mechanism] 2). A6 three ([estimate], [conflict], [mechanism]).

Stops: 1 (A4, answered). Refusals: 2, both `claude stop` on the A5 session. Calls sent to Geoff: 1 packet. `[advisor]` answers: none.

## What it cost

| Pass | State | PR | Planned min | Actual min | Usage before | Usage after |
| --- | --- | --- | --- | --- | --- | --- |
| A1 | merged | glw907/approval-queue#19 | 120 | about 80 | 63% | 64% |
| A2 | merged | glw907/approval-queue#20 | 120 | about 120 | 64% | 65% |
| A3 | merged | glw907/approval-queue#21 | 120 | about 120 | 65% | 66% |
| A4 | merged | glw907/approval-queue#22 | 120 | about 240, with one stop | 66% | 67% |
| A5 | merged | glw907/approval-queue#23 | 100 | not measured | 67% | 69% |
| A6 | waiting | glw907/approval-queue#24 | 75 | about 30 on the path | 70% | 71% |

Weekly usage went from 63% to 71%, and resets Nov 13, 11pm (Anchorage). Fable usage is 4%.

## What is left for later

**To switch:** approve the workstation round's close packet. Its steps merge the workstation pull requests, then #24, pull `~/.dotfiles` and `~/Projects/approval-queue`, and run `approval-queue restart`. thinkpad-x1 switches the same way when its next session starts.

**For after the switch,** from the merged PRs' "Found, not done":

- Backlog #73: `merge` has no answer for a pull request body's `## Before merge` section.
- Backlog #74: four accessibility points on the answer-refusal path (a radio showing a pick `answers.json` never stored, no busy state on an answer post, three focus branches the check does not drive, failure blocks that may be read twice).
- Backlog #76: a note loses its start position across a return, so a note on the second of two identical phrases anchors on the first.
- Backlog #75: look changes that start in the mockup and need your approval (Undo, Send back, and Try again show no edge, and disabled Approve is about 1.5:1 contrast).
- Backlog #72: swap the queue's copy of the document styles for Survey's file once that release exists.
- `send` writes `heads.json` after `createDocument`, so a failed write leaves a document that cannot be approved. It fails safe.
- The workstation's `/tmp` tmpfs fills from other sessions' leftovers, so gates ran with `TMPDIR` set to the job's scratch directory.
- The finished A5 executor session (4957d346) is still listed. Ending it needs a person.
- The worktree `~/Projects/approval-queue/.claude/worktrees/aq-a6` stays until #24 merges, and whoever merges removes it.

Resume from: ~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds/plans/aq-rewrite-conductor-prompt.txt

Round state: ended, A6 held for the workstation round's close packet
