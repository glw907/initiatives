# Docs friction plan: fold record

The planning session (claude-opus-5-5) folded `2026-10-24-docs-friction-review-mechanics.md` into
`plans/2026-10-24-docs-friction.md`. Each finding was checked against the source or a probe
before it was folded. No finding changes the approved design.

| # | Finding | Disposition |
| --- | --- | --- |
| 1 | The cmdline liveness test lets a reused pid read as another queue command | Folded: call 1 records `pidStart` (field 22 of `/proc/$$/stat`) and tests start time and state. The fold added the state test (not `Z`): a killed, unreaped process keeps its `stat` and start time. A probe showed bash reaps its own background children at once, so the zombie case needs another parent, such as a Node test runner. |
| 2 | `collect` on a change has no `pr` to give `head_unmoved` | Folded: call 4 sets `pr="$repo#$number"` and `pr_repo=$repo` for a change; T1 tests `collect` on a change. |
| 3 | `collect` cannot dispatch early, since the decision functions are defined after the queue code | Folded: call 4 says how it is wired (parse, skip the queue, server, and tab blocks, its own EXIT trap, the shared wait loop and `case`). |
| 4 | `tests/page-change.test.sh` carries a third live-log check | Folded: call 16, T1's files, standing answer 10. |
| 5 | The pair prompts lack standing answer 10 | Folded: the pair preamble quotes its first bullet and bars editing the other task's tests. |
| 6 | The slug alias covers `.heading` only | Folded: call 8 aliases every key derived from the old section slug; T2's test adds `.p0`. |
| 7 | The `anchors` dispatch has no owner | Folded: R1 adds the dispatch and usage line. The fold placed it after `app=` is set, since the `approved` branch runs before `app` exists (command line 91). |
| 8 | CT cannot read a `setsid -f` command's exit code | Folded: a foreground variant through `run_in_background: true` in "Commands" and "CT commands". |
| 9 | The #28 test can pass on an unmoved head | Folded: the stub moves both heads, and the test asserts the approve-marked head moved. |
| 10 | Bash `=~` has no `\d` | Folded: call 2 spells the regex `^[0-9]{8}T[0-9]{6}-[0-9]+$`. |
| 11 | Log-once on an absent log | Folded: call 4 says an absent log means not logged; T1 tests a first decision. |
| 12 | `withdraw` on a just-deferred item takes the TERM path and exits 1 | Folded: call 2 checks `deferred.json` first and names the decided-meanwhile exit. |
| 13 | The withdraw, collect, and anchors line omits `APPROVAL_QUEUE_PROJECTS` | Folded: added. `ct-bin` is moot once finding 23 drops the stub. |
| 14 | CT commands are templates | Folded: "CT commands" writes each in full for `ct` and 7993. |
| 15 | CT steps share a file, and step 5 never shows the split took effect | Folded: one fixture per step; step 5 asserts the `p<n>` card moved. |
| 16 | `uncollapseUnchanged` needs the range's exact start | Folded: call 9 names the two ways T3 finds it. |
| 17 | The slugger seed is left to the executor | Folded: call 8 states it (blueprint seeds `page`, page none) and how `anchors` picks the kind. |
| 18 | Subagents lose `cd` between Bash calls | Folded: call 17 has subagents use absolute paths and `bash <wt>/scripts/gate.sh`. |
| 19 | T0's long-blueprint note must suit T2's old worktree | Folded: call 18 makes it a string anchor under a heading both rules spell alike. |
| 20 | #19's browser fallback names no wait | Folded: T2's #19 bullet uses the hold's pause on the toast. |
| 21 | The other host skips the waiting-item check | Folded: the Close step waits until no item waits there. |
| 22 | The prompt files are untracked | Folded: committed with the plan in the planning PR. |
| 23 | The CT `gh` stub is unneeded | Folded: every CT step queues a blueprint, and the stub is gone. |
| 24 | The #29 self-test moves the register path with `HOME` | Folded: dropped; call 16's assertion is direct. |
| 25 | Owner fork on #28's reading | Sent to Geoff through `conductor-approval-queue` as one question, recommending that only parts set to send back make a revision, with a note-only send-back counting every part as today. The ruling is folded into call 15 below. |

## Ruling on finding 25

Pending at the time of writing; the plan's call 15 records the answer and its source.
