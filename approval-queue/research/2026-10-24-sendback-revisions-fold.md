# Send-back revisions plan: fold record

Review: `2026-10-24-sendback-revisions-review-mechanics.md` (one `plan-reviewer` read, the depth
`spec-plan-review` sets for a `runner` plan whose design is a page: no spec, the mechanics lens, and
the fold). The planning session (claude-opus-5-5) folded it into
`plans/2026-10-24-sendback-revisions.md`, checking each finding against the source first. No
finding changes the approved design, so nothing returns to Geoff.

| # | Severity | Disposition | Where the revision carries it |
| --- | --- | --- | --- |
| 1 | major | Folded. Verified: the waiting command assigns `decision_program` before its wait loop, so a pulled file never reaches it, and line 660 accepts only `[decision, note]`. | Merge order step 1 holds the merge while a `packet` item waits, and the hand-over names any still waiting after 60 minutes. Conductor prompt names the reason. |
| 2 | major | Folded. Verified: `port="${APPROVAL_QUEUE_PORT:-7907}"` at line 80. | New "Commands" section with the full queue, build, seed, curl, and stop lines; call 12 points at it; "Names" gives the CT `gh` stub's path and CT step 2 writes it. Executor prompt names both variables. |
| 3 | major | Folded. Verified: `answeredCalls` reads `call.id` after narrowing only on `decision.decision`. | Call 1 gives T1 the one narrowing edit; file ownership names the exception; new standing answer 9 for a pair merge conflict. |
| 4 | major | Folded. | Call 15: the command does the doc-kind lookup and writes `revises`; T1 adds a `tests/blueprint.test.sh` case and a route seed. |
| 5 | major | Folded. Verified: `prefill()` maps `openCalls`, and the undo effect reopens the note with its restored text. | Call 11: the #24 test reproduces T2's traced sequence and fails on `c8018fd` first, with the red run in STATUS. |
| 6 | major | Folded. Verified: `gh pr list -R glw907/drafter --head worktree-batch-friction --state all` printed `[]` on 2026-10-24. | Standing answer 2 gains the never-merged case (ask `conductor-drafter` once, then start T5 from `origin/main`); conductor prompt carries it. |
| 7 | major | Folded. Verified: `scripts/drafter-gate.sh` wraps `make -C <dir> check` in `cairn-run-gate --fresh`. | Risk class and repos, T5's acceptance, and the executor prompt use the script. |
| 8 | minor | Folded. | Call 4: status read only on exit 0, 404 told by stderr, 406 writes no since file, and the README notes that merges from main show in the since diff. T1's tests cover 406. |
| 9 | minor | Folded. | Call 2 (no `decisions.jsonl`), call 15 (missing earlier `decision.json`), call 5 (a `--description` path that isn't a file); each has a T1 test. |
| 10 | minor | Folded. | T1 owns and extends `seed-packet.ts` and `seed-blueprint.ts` for T3's states. |
| 11 | minor | Folded. Verified: the initiatives main checkout sat at `34510ae` with no plan. | Pre-flight pulls the checkout and runs `test -f` on the three files; the parent session merges the planning PR. |
| 12 | minor, optional | Folded as a note. Prior unattended drafter passes edited these files (`8ed0a39`, `37c879f`), so no pre-flight rule is added. | T5 names the precedent and makes a block a stop (answer 8). |
| 13 | minor | Folded. | Close's `[you: other workstation]` step writes out every command and skips a repo the host lacks. |
| 14 | minor, optional | Folded: one extra message line. | Merge order step 5 also messages a live extend-blueprints batch session. |
| 15 | minor, optional | Folded. | End-to-end step 1 sets B to `send-back`. |
| 16 | minor, optional | Folded. | "Names" holds the anchored `pgrep` pattern, used in T0 and Merge order step 6. |
| 17 | minor, optional | Folded, all three: they save time. | T3 makes one light render per screen and CT the full set; T0 drops the dotfiles baseline gate; one `diff-reviewer` reads the dotfiles and drafter branches together. |
| 18 | minor, optional | Folded. | "Path": STATUS records T0's start and the session checks elapsed minutes against 420 at each task start. |
| 19 | minor, optional | Folded. | New task R1 (10 minutes) between the pairs carries the merge and T1's read; path 315, sum 450. |
| 20 | minor, optional | Folded. | T2 owns `frame/` except `FrameHeader.svelte`. |
| 21 | minor, optional | Folded. | Call 2 counts only rejects after each ref's latest approve. |

No owner forks, and no owed errata: the design's "latest reject line" is narrowed in call 2 and
the reason is stated there, inside the design's outcome.
