# Round `tui-language`: process log

Geoff asked on 2026-11-13 for the round to run as the first full test of the round-shaped pattern,
with data kept for refining the process. This file is that data, written as it happens by each seat.
Each entry names the seat, what the process said, what happened, and what it cost.

## Start seat (session cairn-cms-a4, interactive, Opus 5.5)

The start prompt was written for a `claude --bg` session; Geoff instead asked an interactive session
in cairn-cms to run the round, so this session took the start seat from the prompt file.

1. **Stale tooling gate.** Start prompt step 1 checks that `approval-queue --help` lists `snapshot`
   and `packet` and that `approval-packet` describes a `round` field. The ws-documents round
   (reported 2026-11-13) retired both commands: the queue now has `check` and `send`, kind `design`
   exists, and no `round` field or `land --round` exists. The prompt and conductor prompt were
   written the same day against the tool design before the switch. Read as: the check's intent
   (the queue can carry a design packet) holds; its letter fails. The start seat carried on with
   `check` and `send` and records the mismatch. Fix: a launch prompt names a capability, never a
   subcommand list, or the round design probes the tool at write time and the prompt cites the probe.
2. **Ground not clear, two ways.** The design's standing answer 7 and the conductor's check 2 need
   setup-tooling pass 3 merged. Its PRs (#235 to #239) are merged, but T3.4's close, T3.5 (dependency
   sweep, final candidate, scripted leg), and the end packet are not done, no session is running them,
   and STATUS still names pass 3 in flight. Separately, theme-garden G3 (approved, 940 path minutes)
   is queued in cairn-cms behind T3.5, and the conductor's check 4 holds this round behind any queued
   theme-garden pass. The design said only "after pass 3 merges" and did not place itself against G3.
   This is an order call, so it goes to Geoff as a Decide in the design packet. Fix: a round design
   carries a "queue position" line, checked against every other initiative's queued round in the repo.
3. **Tool code unmoved.** `git diff b3d0c2062..main` touches only `BACKLOG.md`, so step 3's line
   re-check had nothing to correct. The prompt assumed pass 3 would have moved code by now.
4. **Backlog id collision.** Two open items carried `#465` (filed the same day by two sessions).
   Renumbered the temp-dir item to `#467` in `3890d8c50`, a direct ledger change pushed without the
   adapter's gate run (a slip; the change was one Markdown file). Fix: `log-issue` reads the highest
   id from `origin/<default>` at write time, or the backlog gets a duplicate-id check in the fast lane.
5. **High backlog item in the round's own files.** `#467` (tests leave a 23M binary in `/tmp` per run)
   sits in `tool/cmd/cairn`, which passes 1 and 3 open, and each pass runs `make -C tool check` many
   times. Left in, the round would refill `/tmp`. The start seat fixes it as a separate small PR
   before the round. A scan of `/tmp` found three engine tests leaking the same way.
6. **Backlog debt outruns the scoped sweep.** The design's scoped sweep read 14 items in the round's
   files. The whole backlog held 137 open items, 103 with no sweep stamp since 2026-08-15, and an
   undecided 36-row triage from 2026-11-03 that no session had acted on. Geoff asked mid-start for
   the backlog left clean, so the start seat ran a full sweep of every open item outside the design's
   14: seven read-only Opus agents of about 20 items each, the 11-03 rows handed in as prior readings.
   Fix: a sweep's verdicts land in the same session that reads them, or they expire; a triage file
   that waits for a decision is a second backlog.
7. **Conductor prompt names a retired flag.** The conductor prompt lands passes with
   `approval-queue land --round tui-language ...`; the live `land` takes only `<owner/repo#n>
   <sentence>`. Same cause as entry 1. The start seat corrects the prompt before the hand-over.
8. **The docs review runs on forms the queue retired.** `cairn-writing-docs`'s `references/review.md`
   queues `approval-queue docs` with notes JSON and merges with a bare `gh pr merge`; the monthly
   cycle queues `approval-queue triage`. None exists since the ws-documents round, and the merge
   guard denies the bare merge. Passes 2 and 3 edit `docs/admin/is-it-working.md`, so they would have
   stopped at the docs step. Filed as #465 (raised to High in the sweep) and fixed as a side PR
   before the round, with an eval capability case. Same cause as entries 1 and 7: a tool retired a
   form, and only its own repo's docs moved. Fix: a queue change greps every skill and prompt under
   `~/.claude` and each repo's `.claude/` for the retired form, in the same pass.
9. **A cleanup after `testharness.Main` never runs.** `Main` calls `os.Exit`, so code after it in
   `TestMain` is dead. That is why #467 leaked. The fix builds into the directory `Main` already
   removes (PR #241). It belongs in the durable-gotchas index.
10. **The backlog lags the work by weeks.** The sweep found 28 open items already done, six of them
    High, and four duplicates (#425 of #368, #458 of #435, #466 of #465, #354 of #461). The High
    list looked urgent and was mostly closed work. Fix: a pass's close moves every item its PRs
    finish, checked by a grep of the PR bodies for `#NNN` against the open list; `log-issue` greps
    the open list for the item's file:line before it files.
11. **The builder check earned its cost.** A fresh read of the design as its first builder found 11
    open questions and 9 weak acceptance items, including a "fixture registry" that does not exist,
    two pass-1 items that contradict each other, a `new_*.go` command placed in a pass that
    excludes `new_*.go`, greps that false-fail on Go's time layout, and a byte check (`< 128`) that
    passes an escape byte. Each became a Claude's call or a fixed acceptance line before Geoff
    read it. Keep the step; run it before the mockups are final, since two findings changed what
    a mockup shows.
12. **The ground check named the wrong gate.** The design said "after pass 3 merges"; every pass 3
    PR had merged, but the pass had not closed (T3.5 and the end packet). The gate now reads
    "closed: end packet answered and STATUS no longer names it". Fix: a round design's start gate
    names a STATUS state, never a merge.
13. **The cold reader found what the linters can't.** Vale and tellgrader were clean, and the
    Sonnet reader still found a count that didn't add up (137 open, 106 left, 32 moved; one split
    item made up the difference), an undefined "Survey", and a budget line ("a hard stop at twice
    that") with two readings. Its list of unexplained terms was long (`conductor-cairn-cms`, pass
    names, backlog item subjects). A design packet leans on context Geoff carries, so the start seat
    fixed only the misreadings and the terms he lacks. Fix: the reader's prompt names the reader's
    known context (the initiatives, the round names) so its term list is short and every entry counts.
14. **Bold option names trip a whole-page check.** tellgrader's `bold-lead-bullets` fires when half
    or more of a page's bullets open in bold, and the packet form invites bold option names. Eight
    questions of two or three options were enough. The start seat dropped the bold from the four
    backlog questions. Fix: the approval-packet skill says bold names are optional, or tellgrader
    skips `:::question` blocks.
