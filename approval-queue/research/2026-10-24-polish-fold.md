# Polish plan fold record

The planning session folded `research/2026-10-24-polish-review-mechanics.md` (the `plan-reviewer`
read of `plans/2026-10-24-polish.md` at `bfbbf24`) into the plan. There are no owner forks, and no
finding changes the approved design. Every mechanism the fold added was probed against
approval-queue `dbe553b` or the installed tool, and each probe is cited below.

## Dispositions

| # | Severity, tag | Disposition | Where the plan carries it |
| --- | --- | --- | --- |
| 1 | major, correctness | Folded | Call 3: the EXIT trap keeps both guards, ends `\|\| true`, and runs cleanup unconditionally; `retire_item` sits beside `proc_running`. |
| 2 | major, correctness | Folded | Call 3: after TERM, `withdraw` waits for the waiter's exit, then decides by the files. R1 names the window. |
| 3 | major, correctness | Folded | R1 runs `npm ci` after both merges; CT step 1 reruns it if T3 touched the lockfile. |
| 4 | major, correctness | Folded | Call 19's fixture block and amend chain; T3 and CT name it; "T4 commands". |
| 5 | major, correctness | Folded | Call 13: `PartFiles`' since block stays, `DesignView` gets an embedded form, and a packet's `FilesDiff` skips the `focus-filter` registration. |
| 6 | major, correctness | Folded | Call 4: the guard checks only the live log, and T1 records a proof run's FAIL line. |
| 7 | minor, correctness | Folded | Call 3: `decide` and `decideOnce` take a `packet` flag (the form has `fingerprint`) and return `fail(410, ...)`. |
| 8 | minor, correctness | Folded in part | Call 3 labels the TERM case a regression guard. The proposed failing test "a `withdraw` on a deferred item with a `decision.json` exits 1" is refused: `withdraw` refuses a decided item with exit 2 before any removal (`approval-queue:47`), so the test could never reach `retire_item`. |
| 9 | minor, correctness | Folded | Call 3: a dead-pid collect case, both waits bounded. |
| 10 | minor, correctness | Folded | T2 adds `Margin.svelte` and the send-back `fieldset`; T3 may touch T2's files. |
| 11 | minor, correctness | Folded | Call 9 names `src/lib/server/packet-facts.ts`, owned by T2. |
| 12 | minor, correctness | Folded | Call 18 moves to T2, typed from the layout load's return. |
| 13 | minor, correctness | Folded | Call 21: `--directory`, `run_in_background`, `pkill` after the shots, 7931 in pre-flight, standing answer 17. |
| 14 | minor, correctness | Folded | Standing answer 14 and CT step 6: restart only after a pull, the conductor exception stated, a `run_in_background` until-loop, deferred items excluded. |
| 15 | minor, correctness | Folded | Standing answers 6 and 8: call 8's cookie behavior and end-to-end step 6 cannot escalate. |
| 16 | minor, correctness | Folded | T3 is dispatched with `run_in_background: true`. |
| 17 | minor, correctness | Folded | End-to-end steps 5 and 7; the CT collect line. |
| 18 | minor, correctness | Folded | Call 22: an utterance group, the Wayland focus cause, `dconf dump` before and a reset and load after. |
| 19 | minor, correctness | Folded | "T4 commands". |
| 20 | minor, correctness | Folded | End-to-end step 1: 16 pairs. |
| 21 | minor, correctness | Folded | Call 18 reworded. |
| 22 | minor, correctness | Folded | Both research files and the prompt are committed in the plan PR. |
| 23 | minor, correctness | Folded | Calls 6 and 20 name `character-entities`. |
| 24 | minor, optional | Folded | T0 25, R1 25, CT 100, path 415. The clock stop reads each task's estimate, and the added fixture, `npm ci`, and amend work would trip it at the old figures. |
| 25 | minor, optional | Folded | Call 9's cache can escalate, on #4's own words ("fine at today's scale"); the shared function and the layout fields stay required. |
| 26 | minor, optional | Folded | Call 5: one deterministic proof, then five timed runs in place of eight. This cuts run time. |
| 27 | minor, optional | Refused | pass-core "Lifecycle" step 1 says the run stops on an escalation the plan doesn't allow; the plan keeps that. |
| 28 | minor, optional | Folded | Standing answer 10. pass-core says every stop the plan writes carries a standing answer, so this one counts as correctness. |

## Probes for the mechanisms the fold added

- `gone()` answers `fail(410, { message: 'This item was withdrawn by its session; nothing was recorded', board: '/' })`
  only when the form has `fingerprint`, else `error(404)` (`src/routes/item/[id=id]/+page.server.ts:66-69`).
- The description check runs as `node "$app/src/check-brief.ts" description "$description" "$title"`
  (`approval-queue:243`).
- `dconf reset [-f] PATH` needs `-f` for a directory, and `dconf load DIR` reads stdin (`dconf help`).
- Notes anchor by heading slug and paragraph, as in `read-the-build-log.p1` and
  `find-the-slow-step.p2.cause` (`src/lib/fixtures/sample-notes.json`).
- The amend view folds with `collapseUnchanged: { margin: 3, minSize: 4 }` (`src/lib/editor/setup.ts:362`).
  The sample is 46 lines, with headings at lines 7, 15, 22, 37, and 45, so an edit at line 45
  folds a run that holds line 17.
