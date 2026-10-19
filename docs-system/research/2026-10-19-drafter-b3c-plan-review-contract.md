# Review: drafter B3c plan, contract and criteria lens

Target: `docs-system/plans/2026-10-19-drafter-b3c-cairn-pilot-plan.md` at `68ae25d`, against the
approved design (`specs/2026-10-19-drafter-b3c-cairn-pilot-design.md`), its factsheet, drafter
`3c2c5cb`, and cairn-cms `11104274e`. Read only; no API call. The lens asks four things: can each
promise be tested, does each criterion name its fixture and why it would fail, can any criterion
pass vacuously, and does the plan deliver the design's "What it builds" and "Check" at the scope
the design sets, under Geoff's rulings ($80, all eight behind the rotate probe).

Count: 0 blocker, 7 major, 9 minor. One finding is an OWNER FORK (finding 13).

Coverage verdict: every "What it builds" item (1 to 6) and every "Check" row (1 to 3) has a home in
the plan, at the design's scope, and both rulings appear as written (plan:12-14, :167-173). The
gaps are about whether the checks prove what they say, not about missing scope.

## Major

### 1. Check 3's confirming command can spend money, and it doesn't confirm `sections`

- Severity major, tag `correctness`. Location: plan:536-542 (Check 3), plan:767 (B3c.8).
- Defect: Check 3 confirms each accepted page with `$B3C_DRAFTER page --json <page>`, and expects
  "up to date with drafted.lock" with no spend. There are two problems:
  - The command has no `--dry-run`. If an entry doesn't match (the case the check exists to
    catch), `scopeFromLock` returns a scope and `runPageBlueprints` starts a live batch draft
    (`cmd/drafter/pagebp.go:55-88` at `3c2c5cb`). A failing check spends up to the page cap.
  - "Up to date" comes from `pageScopeFor`, which compares only the blueprint, the outline entry,
    and the facts against the entry (`draftscope.go:110-157`). It never hashes the page or its
    sections. So the row "`sections` equals the section hashes of that page, which ... confirms"
    is vacuous: a wrong `sections` map still prints "up to date".
  - "`<commit>`" in `git rev-parse <commit>:<blueprint>` is never defined.
- Fold: Run the confirmation as `$B3C_DRAFTER page --dry-run --json <page>`. Dry run takes the
  same `scopeFromLock` path and returns before `pipeline.Run` when nothing is left
  (`pagebp.go:61-71`). Name `<commit>` as the close head. Then do one of two things:
  - Drop the `sections` row. `recordDrafted` writes `sections` from the same bytes that `page`
    hashes, so `page == git hash-object` is the real check.
  - Or name a real check, such as a test helper that recomputes the hashes.

  Either way, the check costs nothing on a mismatch.

### 2. Fix subagents and the session's blueprint fixes would run the installed B3 binary, which refuses the cairn branch

- Severity major, tag `correctness`. Location: plan:465-480 (the probe's read loop and round-1
  fix subagents), :496-498 (B3c.7 rounds), :719 (B3c.5 commits `brief_path`), :825-827 (Merge
  order states the refusal).
- Defect: B3c.5 commits `blueprints.brief_path` to cairn's `drafter.toml`, and P1 commits
  `blocked` entries to the lock. After that, the installed `drafter` (B3's) fails on both:
  - The config decode is strict (`internal/config/file.go:98-106`).
  - The lock decodes with `KnownFields` (`lock.go:58-69`).
  - `drafter check` loads both (`cmd/drafter/check.go:60`, `internal/blueprint/check.go:360`).

  Every fix subagent is told to get "0 errors from `drafter check`". The blueprint skill also
  says `drafter check`, and the plan names `$B3C_DRAFTER` only for live calls (plan:408-412).
  A fresh-context subagent will run the installed binary. That binary fails on config load, so
  the agent either reports blocked or "fixes" the error by editing `drafter.toml` or the lock.
  The session's own rotate fix loop (plan:465-467) has the same trap.
- Fold: Every fix-subagent prompt names `$B3C_DRAFTER` by absolute path for `drafter check`. It
  forbids edits to `drafter.toml`, `drafted.lock`, and any file but its own blueprint, and says
  why: "the installed binary is pre-B3c". Add an acceptance row to B3c.6 and B3c.7: each fix
  branch's diff touches only its blueprint, with `git diff --name-only` as the check. B3c.4's
  reshape runs before B3c.5, so it is unaffected (plan:705 is right).

### 3. Check 2's gate passes claude-code mostly vacuously

- Severity major, tag `correctness`. Location: plan:55-66 (finding 3), :531-535 (Check 2), :762
  (B3c.8).
- Defect: Finding 3 expects cairn's gate might refuse a `docs/claude-code/` page, and it plans an
  escalation if so. The code says the opposite risk is the real one: the gate passes it while
  checking almost nothing.
  - `check-leaks` scans a fixed `SCAN_ROOTS` list without `docs/claude-code` (`check-leaks.mjs:473-490`).
  - The same holds for `check-snippets` (`:60-61`), `check-symbols` (`:66-68`), `check-visuals`
    (`:35-37`), `transcript-blocks` (`SCAN_DIRS`, `:30`), `check-arm-indexes` (`:39-41`), and
    `ARM_DIRS` (`arm-state.mjs:28`).
  - Only Vale and tellgrader on `--page`, provenance on `--brief`, and the link walk read the
    page.

  So "each accepted page passes `check:docs-gate`, exit 0" is true for claude-code while the
  leaks, snippets, and symbols checks never saw it. The cairn PR would report a green gate that
  means less than it does for the other seven. The page also ships nowhere in B3c, but Geoff
  reads it as "passed cairn's docs gate" (design, "Outcome").
- Fold: Rewrite finding 3 and Check 2 for claude-code. Its gate result is reported as "partial:
  Vale, tellgrader, provenance, and links only; leaks, snippets, symbols, visuals, transcripts,
  and the arm index don't scan `docs/claude-code/`", with the arm registration named as the
  reason (Later, plan:836-837). The cairn PR's eight-page table gets a gate-coverage column, or
  a footnote on that row. No scope change and no added time.

### 4. The sync probe's $10 cap is likely to trip on worst-case reservations, and a cap escalation stops the line

- Severity major, tag `correctness`. Location: plan:102-105 (finding 10), :451 (probe draft $6 to
  $9), :475-494 (probe stop rules list "the cap").
- Defect: The ledger checks the page cap against reservations at worst case (`max_tokens` priced),
  not actuals: `page + r.Worst > c.Page` (`internal/ledger/ledger.go`, `Reserve`). The probe runs
  `--sync` at full price with an actual estimate of $6 to $9 against a $10 cap. Its worst-case
  reservations, especially the reader's 32000-token ceiling (factsheet, "Money"), can cross $10
  before actual spend does. A cap escalation isn't a fault or a mechanical cause, so it "stops
  the line" (plan:492-493). The pass would then halt Geoff's "all eight" ruling on a price
  artifact the plan chose (sync over batch). The estimate gives no headroom number, so this risk
  can't be tested before money is spent.
- Fold: Before the probe draft, run `$B3C_DRAFTER page --whole --dry-run --sync --json
  <rotate>`. The dry run prints the first stage's worst-case cost (`page.go` `--dry-run`
  help). Record the worst-case reservation, and price the later stages from the stage list. Then
  add one of two rules:
  - If the projected worst crosses $10 at sync, the probe runs batch. This adds wait time but no
    cap risk.
  - Or a probe that escalates on the cap at sync reruns once in batch as a fresh run, since the
    mode is in the fingerprint and a resume can't switch. That fits inside the "fault" rerun.

  Apply the same dry-run worst-case reading to wave 2's largest page (add-cairn, 2871 blueprint
  lines). A predicted cap escalation is then reported as predicted, consistent with the ruled
  $10 cap, rather than discovered.

### 5. No real-context render check stands before live spend; the chain's blueprint mode is tested only on a synthetic matrix

- Severity major, tag `correctness`. Location: plan:662-693 (B3c.3 matrix and tests), :723-724
  (B3c.5 `check-prompts` on the same synthetic matrix), :461-463 (P1 goes live next).
- Defect: Every B3c.3 row ("no `undefined`", "names each exemplar file", "names the register
  sections of its track") runs on `blueprint-matrix.json`, a hand-built context. The live context
  is `entryJSON` plus `draftInputs` from cairn's real blueprints and outline:
  - capture-directory exemplar sources (`operators/cloudflare-create-token/`);
  - no `track`;
  - `registerSections` sent empty (`docs/prompts-module.md:125`);
  - a `docs/claude-code/` path.

  A matrix that guesses one field differently passes every row. The first real render is then
  the paid probe, and the probe's stop rules turn a render fault into a line stop or a mechanical
  fix cycle (plan:487-490).
- Fold: Add a step to B3c.5 that costs nothing and takes minutes:
  1. Run `$B3C_DRAFTER read --dry-run --json` over all eight blueprints.
  2. For each of the eight, run `$B3C_DRAFTER page --whole --dry-run --json` (the first stage is
     the draft seat, since `SkipRead` won't apply yet, or the read when it does).
  3. Assert each run exits without a render error.
  4. Grep the assembled requests for `undefined`, `.plan.yaml`, `.framing.md`, and `worktree`.
  5. Confirm every exemplar file the draft names exists under `~/.local/share/cairn/exemplars`.
     A missing file is the "prompt names a missing file" mechanical cause, found here for free.

  Also run `read --dry-run` for rotate's read 2 after the fix commit, and grep for "Still open".
  That proves the bar reached the chain's prompt before the paid read.

### 6. A mechanical cause found in wave 1 is fixed only after wave 2 has spent on it

- Severity major, tag `correctness` (budget). Location: plan:513-519, :770-776.
- Defect: The reruns are ordered "after wave 2, each page that escalated on a fault, or on a
  mechanical cause the session fixed with a test, reruns once". Nothing says the mechanical fix
  lands before wave 2 starts. If wave 1's four pages escalate on one mechanical cause (a step
  error, a brief schema miss on every turn), wave 2 spends its $15 to $25 hitting the same cause.
  Then the reruns pay again, on an $80 hard ceiling. The probe guards the first such cause but
  not one that only larger pages hit.
- Fold: Add one rule before B3c.9. When any wave-1 page escalated on a mechanical cause, fix it
  (test, `make check`, rebuild) before wave 2 starts, and record the commit. If two or more wave-1
  pages escalate on the same non-mechanical cause, wave 2 still runs, per standing answer 3. No
  path cost unless the cause occurs.

### 7. The reshape's acceptance can pass by deleting content

- Severity major, tag `correctness`. Location: plan:379-396 (resolution 5), :705-712 (B3c.4
  acceptance).
- Defect: The only content gate on each reshape is "`drafter check` reports 0 errors". The 524
  errors are 345 `use` and 173 `why` faults (plan:45-47). A subagent can clear them all in a few
  ways: delete items, delete sections, or write a generic `why` or a vacuous "Only ..." use. The
  later paid read judges blueprint quality, not fidelity to the converted plan. A dropped claim
  is never flagged, and the drafted page silently loses it. Rotate's reshape had a human eye on
  it; these seven don't.
- Fold: Add an acceptance row per page, a mechanical one. The section ids and the item ids
  (or counts) in the reshaped blueprint equal those in the converted blueprint at the conversion
  commit, and any removal is listed in the reshape commit message with its reason. The check is
  a `yq` or `git diff` comparison, minutes in the shadow, with no path cost.

## Minor

### 8. Check 1 has no outcome when no page yields its row, yet #13 closes on "the evidence from Check 1"

- Severity minor, tag `correctness`. Location: plan:74-78 (finding 5), :525-530 (Check 1), :811
  (close #13).
- Defect: Finding 5 moves Check 1 to "the first of the other seven whose first read blocks and
  then accepts". Two outcomes leave the row with nothing in it: no page blocks, or every page
  that blocks also blocks at read 4. The plan doesn't say what happens then, and the close step
  closes #13 regardless. The offline e2e test proves the mechanism, but the design's Check 1 is
  a live row ("reaching accept").
- Fold: State it. When no page yields the row, the PR reports Check 1 as "mechanism proven
  offline (`e2e` test name), not observed live", and #13 stays open with that note, or Geoff
  rules at the packet.

### 9. B3c.3's "blueprint seat equals its render before the change" has no captured change-read baseline in blueprint mode

- Severity minor, tag `correctness`. Location: plan:276-277, :555-558 (B3c.0 step 4), :691-692.
- Defect: B3c.0 captures only `tests/fixtures/drafter/matrix.json`, the handoff mode. The chain's
  blueprint seat has one existing golden, the whole read
  (`cmd/drafter/testdata/blueprint-prompt.golden.txt`, `read_test.go:225`). No golden covers the
  change read. So "with empty `findings` equals its render before the change, in both modes" has
  nothing to compare for the change-read case. The live bar reads are exactly that case. An
  unintended edit to the chain's change-read paragraph passes.
- Fold: B3c.0 step 4 also renders the unedited chain's `blueprint` seat for the whole read and the
  change read, using the blueprint matrix's two non-bar cases built from the existing context
  shape. It commits them beside the handoff golden. This costs 5 minutes on B3c.0.

### 10. A bar on a page with no lock entry (claude-code) has no test row, and the entry's contract comment goes stale

- Severity minor, tag `correctness`. Location: plan:206-215, :609-617; `blueprint.go:185-195`
  (`LockEntry` comment, "An entry with only Accepted set is a page not drafted yet").
- Defect: claude-code has no lock entry (plan:372). If its P1 read blocks, the helper writes an
  entry holding only `blocked`. No test covers that shape. Three behaviors depend on it:
  - Whether `recordAccepted`, which builds `e := lock.Pages[r.Path]` (`read.go:487`), later
    leaves an entry with only `accepted`.
  - Whether `pageScopeFor` still drafts whole (`e.Page == ""`).
  - Whether `drafter check`'s `lockEntries` (`check.go:360-385`) ignores a bar-only entry for a
    page the outline doesn't list.
- Fold: Add one recording row, "a page with no entry gets an entry with only `blocked`; a later
  accept leaves only `accepted`", and one `drafter check` row for a bar-only entry. Update the
  `LockEntry` comment.

### 11. Check 1's read-1 assertion names a field the summary doesn't print

- Severity minor, tag `correctness`. Location: plan:525.
- Defect: "Rotate's read 1 summary shows its scope as a whole read". `PageResult.Scope` is nil and
  omitted for a whole read with no comparison (`pipeline.go`, the `Scope` comment), so there is
  no "whole" in the summary to see. An executor will either improvise or count the absence as
  proof.
- Fold: Write it as "`scope` absent and `whole_blocked: true`".

### 12. A cancelled batch leaves a stopped run that blocks the merge-order check

- Severity minor, tag `correctness`. Location: plan:504-505, :513-514 (cancel and rerun `--sync`);
  :818-820 (Merge order: `grep -l '"stopped"' <state_dir>/runs/*/*/state.json` must print
  nothing).
- Defect: The stalled-batch rule cancels a batch and reruns the pages as a new `--sync` run. The
  fingerprint forbids switching modes on resume (plan:102-103), so the cancelled run's state
  stays "stopped". The merge-order check then fails at install, and the plan doesn't say how
  the executor clears or records it.
- Fold: The stalled-batch rule records the abandoned run id in STATUS and the PR. Merge order
  step 1 names those ids as expected, or the close step resolves them by whatever B3 did with
  its cancelled batch.

### 13. Check 2 passes when every page escalates (OWNER FORK)

- Severity minor, tag `optional`. Location: plan:109-111, :531-535; design "Check" 2.
- Defect: "Each of the eight pages ends `accepted`, or `escalated` with its rule" holds for any
  outcome, including zero accepted pages. That is the design's own wording, so the plan isn't
  wrong. But nothing in the pass reports against the pilot's real bar, the architecture spec's
  three pages Geoff accepts (design, "Decide: Draft all eight"). The pass could close "green"
  with no usable page.
- OWNER FORK. Options:
  - (a) Keep it as is. The PR table shows the counts, and Geoff judges at the packet.
  - (b) Add a reported floor. The cairn PR states whether at least three pages reached
    `accepted` and whether the pilot criterion can be judged. No new stop.
  - (c) Add a stop. Zero accepted after wave 1 stops and asks before wave 2's spend.

  Recommendation: (b). It costs one table line, and the standing answers already cover stops.
  (c) overlaps finding 6.

### 14. Wave batching and the P1 read of the seven read loosely against "smallest first, behind the probe"

- Severity minor, tag `optional`. Location: plan:79-90 (findings 6 and 7), :509-513.
- Defect: The ruling is "all eight, smallest first, behind the probe". The plan departs in two
  ways:
  - It reads the seven before the probe drafts, putting about $1.5 to $3 and seven fix
    subagents at risk if the probe stops.
  - It batches four, then three pages concurrently, so "smallest first" orders only the waves,
    not the pages.

  Both are defensible method calls, and the plan flags finding 6 as contestable. But the PR
  table won't show that the order is per wave, and a reader of the ruling may expect a page at a
  time.
- Fold: The drafter and cairn PR "departures" lines name both, with the dollar figure at risk
  before the probe passed. No plan change.

### 15. Check 2 runs per wave, but cairn's gate runs whole-tree checks, so a later wave can break an earlier page's green

- Severity minor, tag `correctness`. Location: plan:515-516, :531-535, :789-791.
- Defect: Most gate components run unscoped over the whole tree (`docs-gate.mjs`, `buildSteps`).
  Wave 2's pages, index edits, or briefs can turn red a check that wave 1's pages passed. Check 2
  is recorded per wave, and cairn CI on the draft PR catches it only after the PR opens.
- Fold: Close step 3, before the push, reruns `check:docs-gate` once with no `--page`, or once per
  accepted page with `--prebuilt` (finding 16), on the close head. The PR reports that result
  as Check 2.

### 16. Over-ceremony: Check 2 rebuilds cairn's package for every page

- Severity minor, tag `optional`. Location: plan:422-424, :531-535, :767.
- Defect: Each `check:docs-gate` run starts with `npm run package` (`docs-gate.mjs` `main`). Check
  2 runs it once per accepted page, up to eight builds across B3c.6 to B3c.9. drafter's own gate
  already ran it inside each run. That is minutes per build on a path with 25 minutes of slack.
- Fold: For each wave, build once with `npm run package`, then run each page with `npm run
  check:docs-gate -- --prebuilt --page <page> --brief <brief>`. The flag exists
  (`docs-gate.mjs:7,14`). That keeps the design's command and drops the repeat builds.

## Checked and sound

These are recorded so the next reviewer needn't redo them:

- Each B3c.2 test row names its fixture (the scripted `fakeAPI`, the blueprint harness, the e2e
  `tally` copy) and a reason it fails at `3c2c5cb`: fields absent, no bar, no `--whole`.
- The "regression" rows are marked.
- Resolution 1's bar rules close the convergence loop. A defect added by fix 1 stays in the diff
  since the fixed bar commit.
- `scopedAccept` excluding `BarFrom` makes both record paths write `accepted`.
- The budget formula is never looser than the design's meter.
- The waves always `SkipRead`, so the page-mode bar path is proven offline only (e2e step 4).
  That is acceptable, since the design's item 1 names it and the live passes never exercise it.
  The PR's acceptance table should say "offline" on that row.
