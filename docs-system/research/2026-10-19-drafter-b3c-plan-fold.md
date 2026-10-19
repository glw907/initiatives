# drafter B3c plan: fold record

Fold agent: `claude-opus-5-5`, 2026-10-19, per `spec-plan-review` "The fold", after loading
`superpowers:receiving-code-review`. Inputs: the plan at initiatives `55f580a`
(`docs-system/plans/2026-10-19-drafter-b3c-cairn-pilot-plan.md`), the three reviews
(`…-plan-review-mechanics.md`, `…-plan-review-contract.md`, `…-plan-review-integrity.md`), the
factsheet, and the approved design. Code read at drafter `3c2c5cb` (the B3 worktree, read-only) and
cairn-cms `main` `11104274e` (read-only). The plan is revised in place; this record names where
each revision lives. Nothing is committed, and no API money was spent.

## Totals

60 findings: 24 mechanics, 16 contract, 20 integrity.

- Folded: 46. Of these, 14 are convergent duplicates folded once at one of eight roots (A to H,
  below).
- Settled by the planning session: 5 findings across its three rulings.
- Refused: 1 (mechanics 10). Three folds take part of a finding and refuse the rest, each noted on
  its line.
- Dropped as `optional`: 8.
- Owner forks left for Geoff: none. No finding changes the approved design.

## Settled by the planning session

1. **claude-code's partial gate coverage: option (a)** (mechanics 6, contract 3, integrity 5). The
   page drafts as planned; the cairn PR's acceptance table names each gate component that skips
   `docs/claude-code`; the "if the gate refuses ... escalates" premise is gone. Verified:
   `check-leaks.mjs:473-492` `SCAN_ROOTS`, `check-snippets.mjs:60`, `check-symbols.mjs:68`,
   `check-visuals.mjs:37`, `check-arm-indexes.mjs:41`, and `arm-state.mjs:28` `ARM_DIRS` all leave
   it out. Plan: finding 3, resolution 9 Check 2, Close 6 (the table's gate-coverage column).
2. **The floor of three accepted pages is reported, not a stop** (contract 13). Plan: resolution 9
   Check 2, Close 6.
3. **The wave-1 cap of `left/7` is refused** (integrity 12). Each call's cap is already the lesser
   of $10 and the budget left, so no page passes $10 and the pass can't pass $80; a fixed per-wave
   share adds a rule with no measured defect. No plan change.

## Convergent roots

- **A. The bare installed `drafter check` after B3c.5** (mechanics 1, contract 2, integrity 1).
  Resolution 6 gains "Every `drafter` call in the cairn worktree after B3c.5 uses `$B3C_DRAFTER`":
  fix prompts name `$B3C_DRAFTER check <its blueprint path>` by absolute path, forbid the installed
  binary and any file but the blueprint, and the session checks `git diff --name-only` before each
  merge or commit. Resolution 8's probe loop and round-1 fix agents use it; B3c.6 and B3c.7
  acceptance carry the file check.
- **B. The stall rule** (mechanics 3, contract 12, integrity 2). Resolution 8 "The stall rule":
  cancel, cancel the resubmit, confirm the halt with `pgrep`, record the abandoned run and its
  `open.worst`, dry-run then restore the tree, rerun `--sync` on a fresh meter. Close 6 lists the
  abandoned ids; Merge order 1 reads the `"stopped"` grep against them. Integrity 2's `--sync` hang
  rule is refused: each streamed call is bounded by the client's stream timeout
  (`batch/calls.go:177`), and a timeout stops the run, resumable.
- **C. Check 2's `blocked` wording** (mechanics 7, integrity 10). Resolution 9 Check 2: the PR
  carries the last read's findings from its summary; `blocked` holds the first blocked whole read's.
- **D. Check 1's read-1 scope** (mechanics 8, contract 11). Resolution 9 Check 1: "no `scope` and
  `whole_blocked: true`".
- **E. Check 1 with no live row** (contract 8, mechanics 14's third state). Finding 5, resolution 9
  Check 1, Close 7: "mechanism proven offline", and #13 stays open with that note.
- **F. A lock that fails to decode** (integrity 8, mechanics 14's second state). Resolution 1's last
  paragraph: the bar lookup and `scopeFromLock` refuse, naming the file; B3c.2 row.
- **G. The bar-only entry** (contract 10, integrity 11, mechanics 14's fifth state). Resolution 1
  "Recording" last bullet; B3c.2 files (`internal/blueprint/check.go`) and row.
- **H. Check 3's confirmation** (contract 1, integrity 6). Resolution 9 Check 3 runs `page
  --dry-run`, after the commit, against `HEAD`; the `sections` row is dropped because
  `DraftedEntry` hashes `page` and `sections` from the same bytes (`drafted.go:15-39`). Resolution 8
  commits first, then runs Check 3.

## Mechanics

1. Blocker, folded at root A.
2. Blocker, folded. Resolution 5: each reshape agent runs `drafter check <its blueprint path>`, with
   the reviewer's probe counts (524 unscoped, 42 for debug-your-site). My probe confirmed a scoped
   check on rotate prints `0 errors, 5 warnings`.
3. Major, folded at root B.
4. Major, folded. Resolution 1 "The prompt" gains the bullet that an unfixed listed finding blocks
   whatever its class, overriding the Nit rule (`stock/prompts.js:164-169`, chain `:2365-2370`,
   both read). B3c.2 stock row and B3c.3 blueprint-seat row assert the sentence.
5. Major, folded. Resolution 4 gains the agent-override sentence for the `draft` and `editor`
   renders (`cairn-cms.local.toml` sets both `agent` keys; `assemble.go` `Build`/`systemPrompt` sends
   each body as the system prompt; the drafter agent's `:76-95`, `:141` and the editor's `:66` read).
   B3c.3 has a row for it; B3c.5 step 4 greps the real request with the system prompt in it.
6. Settled by the planning session (ruling 1).
7. Major, folded at root C.
8. Minor, folded at root D.
9. Minor, folded. Resolution 1 "Clearing": `PageResult` gains `ReadScope`, and `scopedAccept`
   reads it (`read.go:360-362` and `pipeline.go:237` read). B3c.2 row.
10. Minor, refused. The reviewer counts 0 of about 150 past cairn read findings naming a repo path,
    and a fix needs a new exemption from path inlining for one prompt field; the cost outruns the
    risk.
11. Minor, folded. B3c.3 files list `tests/docs-page-chain-handoff.test.mjs` (`:337-339` read).
12. Minor, folded. B3c.3 acceptance: the new test prints `PASS <name>` per check and the session
    greps `make chain-test`; the clock-file paragraph points there.
13. Minor, folded. Resolution 6 "The tree" and Close 4: a drafted page is never hand-edited; a CI
    red on one is reported or rerun `--whole`.
14. Minor, folded in part: the empty bar (resolution 1 "Recording"), the malformed lock (root F),
    no live Check 1 row (root E), and the bar-only `drafter check` entry (root G). The `seedEntry`
    state is refused: `seed.go:74-92` requires `accepted` equal to the blueprint blob, and an accept
    clears the bar, so a seed never meets one.
15. Minor, folded. Resolution 1: the unchanged-since-bar line gets status `held`, since
    `exitCodeFor` maps `statusUnchanged` to 0 (`page.go:60-72` read). B3c.2 row.
16. Minor, folded. B3c.5 step 3: `git status --porcelain` prints nothing after the gate run
    (`start.go` `requireClean` counts untracked files, read).
17. Optional, folded at no cost: `scripts/drafter-gate.sh:3-4` records the refusal, so a prescribed
    command could fail. Resolution 6 "The gate" names the no-argument wrapper fallback.
18. Optional, folded: removes a needless file from B3c.3's list (`drafter-render-prompts.mjs:18`
    already takes `argv[2]`).
19. Optional, folded: removes the inert "every other row is expected to fail" sentence.
20. Optional, dropped.
21. Optional, dropped.
22. Optional, folded at no cost: the path paragraph now says one 60-minute stall would pass 800 and
    the score names it. The fold's own arithmetic replaced the 25-minute slack line anyway.
23. Optional, folded with contract 9 at no cost: the same regression row names
    `TestRealModuleRendersTheBlueprintSeat`.
24. Optional, dropped.

## Contract

1. Major, folded at root H.
2. Major, folded at root A.
3. Major, settled by the planning session (ruling 1).
4. Major, folded. Finding 10 states the worst-case cap check (`ledger.go:125` read: `page +
   r.Worst > c.Page`). Resolution 8: a real-key dry run records the probe's and add-cairn's
   first-stage worst case first (a dry run writes no ledger line, `dry.go`); a probe that escalates
   on `cap` reruns once as a fresh batch run. Of the reviewer's two rules I took the second; the
   first needs a projection of later stages that no command prints.
5. Major, folded with mechanics 5. B3c.5 step 4, the real-context render check (probed, below), and
   the probe loop's stub check on rotate's bar read ("Still open" in the body).
6. Major, folded. Resolution 8 "The waves": a wave-1 mechanical cause is fixed before wave 2.
7. Major, folded. Resolution 5's id comparison (probed, below); B3c.4 acceptance.
8. Minor, folded at root E.
9. Minor, folded. B3c.0 step 5 renders the unedited chain's blueprint seat for a whole and a change
   read (`read_test.go:190-235` context, read); B3c.3's regression row compares with both. B3c.0
   goes 25 to 30.
10. Minor, folded at root G.
11. Minor, folded at root D.
12. Minor, folded at root B.
13. Minor, settled by the planning session (ruling 2).
14. Optional, dropped.
15. Minor, folded. Resolution 9 Check 2 reruns the gate on the close head; Close 3.
16. Optional, folded: it removes ceremony. One `npm run package`, then `--prebuilt` per page
    (`docs-gate.mjs:7,14` read). Since drafter's run already runs the same gate command
    (`drafter.toml` `gate.command`), the per-wave Check 2 reruns are dropped too, and only the close
    rerun remains.

## Integrity

1. Blocker, folded at root A.
2. Major, folded at root B; its `--sync` hang rule is refused there.
3. Major, folded. Resolution 6 "Recovery".
4. Major, folded. Resolution 1 "Recording": `whole_blocked` lives in `work` and `summary()` copies
   it; `drafter read` prints its summary before a lock-write error, as `pagebp.go:96-107` does
   (`read.go:154-156` read). B3c.2 row, modeled on `TestDraftFailedLockWriteIsWrittenByTheResume`
   (`e2e/draft_rows_test.go:237`).
5. Major, settled by the planning session (ruling 1).
6. Major, folded at root H.
7. Major, folded. Merge order 2: a merge commit, no squash or rebase, no rebase of the branch.
   Resolution 1 prints a line when a bar's commit is gone; B3c.2 row.
8. Minor, folded at root F.
9. Optional, folded at no cost as a correction: finding 4 and Merge order 2 claimed a pre-B3c
   binary refuses a lock with `blocked`, which is false on the page path (`draftscope.go:69-75`).
   They now name the config refusal as the working guard. The backlog note against B5 is dropped.
10. Minor, folded at root C.
11. Minor, folded at root G.
12. Settled by the planning session (ruling 3, refused).
13. Optional, dropped.
14. Optional, dropped.
15. Minor, folded. Close 2: the fix chain leaves the lock schema alone. Close 3: the final binary's
    `check` and `page --dry-run` over all eight pages.
16. Optional, folded with 17: round-1 fix worktrees are removed in B3c.6's acceptance.
17. Optional, folded: it removes ceremony. Rounds after the probe edit in the pass worktree, with
    one `git status` check and one commit per round (resolution 8, B3c.7 acceptance).
18. Optional, dropped: Check 2's close rerun runs the link walk over the close head.
19. Optional, dropped.
20. Optional, folded at no cost, reclassified as correctness: cairn is public, drafter's CLAUDE.md
    bars private paths, and `check-leaks`' `SCAN_ROOTS` leaves out `blueprints`
    (`check-leaks.mjs:473-492`, read). Close 3 greps the cairn diff; Close 7 files the cairn backlog
    item.

## Probes

All under the session scratchpad's `b3c-fold-probes/`, on a `git clone --shared` of the planning
clone (`b3c-probes/cairn`), with B3's installed binary. No API call; the stub stood in for the API.

1. With `[blueprints] brief_path = "docs/internal/briefs/{dir}/{name}.json"` appended to
   `drafter.toml`, `drafter check <rotate's blueprint>` printed `drafter.toml:74: unknown key
   blueprints.brief_path`, exit 2. Restored, the same scoped check printed `0 errors, 5 warnings`,
   exit 0. This backs root A and mechanics 2.
2. A Python stub (`stub/stub.py`) answering `GET /v1/models` with the configured
   `anthropic-workspace-id` header and `POST /v1/messages/count_tokens` with `{"input_tokens":
   1000}`, recording each body. `DRAFTER_API_KEY=dummy DRAFTER_API_BASE_URL=http://127.0.0.1:18765
   drafter read --dry-run --json <rotate>` exited 0, priced two seats, and recorded 187,270 bytes of
   request bodies, the full prompt included. `DRAFTER_API_BASE_URL` is the env layer's
   `api_base_url` (`config/env.go:13`, `:42`); the workspace check is `batch/client.go:81-106`.
3. A committed lock edit giving rotate an entry of only `accepted: <its blob>`, then `drafter page
   --dry-run --json` on rotate against the stub: `SkipRead` held, the first stage was the draft,
   and the run exited 2 with `render docs-page-chain.js seat draft: Error: unknown track
   "undefined"`, finding 1's throw from the real context, before any request. This backs B3c.5
   step 4.
4. `diff <(ids <commit>) <(ids <commit>)`, with `ids` the `yq '[.. | select(has("id")) | .id] |
   sort | .[]'` read of debug-your-site's blueprint (147 ids), exited 0; with one item id renamed,
   it printed the removed and the added id and exited 1. This backs resolution 5's comparison.

Source read for the folds, beyond the probes: `pagebp.go:50-110` and `:185-230`,
`draftscope.go:60-157`, `page.go:40-72`, `drafted.go:1-45`, `read.go:120-170`, `:355-362`,
`:480-500`, `pipeline.go:90-102` and `:225-255`, `handle.go:135-160`, `batch/classify.go:1-30`,
`batch/calls.go:28-177`, `start.go:80-120`, `money.go:105-135` and `:520-540`, `ledger.go:16-20` and
`:115-127`, `dry.go:1-60`, `resume.go:28-80`, `seed.go:30-100`, `internal/blueprint/check.go:360-385`,
`stock/prompts.js:150-171`, `tests/docs-page-chain-handoff.test.mjs:20-40,330-342`,
`tests/drafter-render-prompts.mjs:15-22`, `scripts/drafter-gate.sh:1-8`, `Makefile:5-29`,
`cmd/drafter/read_test.go:222-236`; cairn `scripts/checks/docs-gate.mjs:1-30,43-66`,
`check-leaks.mjs:470-492`, and the arm lists above; `~/.config/drafter/cairn-cms.local.toml`; the two
agent definitions.

No validator, registry, or marker scheme is added. The new state is one `omitempty` work field
(`whole_blocked`), one summary field (`ReadScope`), and one page status (`held`), each answering a
measured defect (integrity 4, mechanics 9, mechanics 15). The stub and the id comparison are
throwaway session checks, not product code.

## Path after the fold

Same rule as before: tasks in sequence, a pair counting once at its larger estimate.

| Segment | Before | After | Why |
|---|---|---|---|
| B3c.0 | 25 | 30 | the blueprint-seat goldens (contract 9) |
| B3c.1 | 40 | 40 | |
| Pair A | max(200, 165, 120) = 200 | max(215, 175, 125) = 215 | B3c.2 +15: the bar rows (`whole_blocked` in `work`, summary-first lock error, bar-only entry, malformed lock, `ReadScope`, `held`, the gone-commit line, the Nit sentence). B3c.3 +10: the override and Nit sentences, the handoff test. B3c.4 +5: the id comparison, still in the shadow |
| B3c.5 | 30 | 50 | the real-context render check and the git-status check |
| B3c.6 | 120 | 115 | no per-page gate rerun (contract 16) |
| B3c.7 | 100 | 90 | no worktrees or merges after round 1 (integrity 17) |
| B3c.8 | 100 | 90 | no per-page gate rerun |
| B3c.9 | 110 | 100 | no per-page gate rerun |
| Close | 50 | 65 | Check 2's single gate rerun, the final binary's check and dry run, the leak grep |

30 + 40 + 215 + 50 + 115 + 90 + 90 + 100 + 65 = **795**, within 800 by 5. A stall, a cap rerun,
and a fault rerun stay contingent and off the path; one 60-minute stall would pass 800, and the
plan says the PR's score names it.
