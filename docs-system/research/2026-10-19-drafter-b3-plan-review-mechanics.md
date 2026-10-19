# Mechanics and feasibility review: drafter B3 plan

Reviewer: `plan-reviewer` agent, 2026-10-19. Target: `docs-system/plans/2026-10-19-drafter-b3-drafting-plan.md`
at initiatives `46a83da`, against the approved design and drafter `main` `f286162`. Saved by the
planning session from the agent's reply (the agent is read-only); wording condensed, findings, locations,
and folds kept whole.

Probes (scratchpad `rev/`): Go `regexp` rejects lookbehind and lookahead (error strings as the plan
quotes); `git diff` between two blob ids exits 0 and a missing blob exits 128; the Google style guide
footer license line confirmed verbatim. Every file:line anchor the plan cites matches the code.

Verdict: 2 blockers, 8 majors (2 marked OWNER FORK), 17 minors.

## Blockers

### 1. The `path` check fails on the fixture as specified (blocker, correctness)
Where: plan lines 527-537 (resolution 10), 557, 769 (B3.5's first test).
Defect: `containment` requires every non-blueprint rendering to contain `page.path`
(`cmd/drafter/checkprompts.go:219-237`). Resolution 7 has the stock prompts name the page and brief by
path (line 392). The fixture has no page, no brief, no lock (line 557), so neither path nor `docs/` is
tracked; every draft, review, reader, and coherence case fails `path`, and B3.5's "exits 0" can't pass.
Related: the rule cuts `#slug` only for repo paths, but the stock module already emits
`drafter:anatomies.md#task-guide` (`stock/prompts.js:28`, `stock/stock_test.go:97`), not a `stock.Files`
name; B3.3's "every `drafter:` token is a `stock.Files` name" (line 679) hits the same. `assemble`'s
`tokens` (`internal/assemble/files.go:104`) doesn't split on `.` or `:`, so a path ending a sentence
fails. Any prose slash ("and/or") is path-shaped and fails; B3.3 is never told the rule.
Fold: exempt the case context's `page.path` and `page.brief`; cut `#slug` from `drafter:` tokens too;
trim trailing `.,;:`; copy the path-shape rule into B3.3's brief (line 670) so prompts carry no prose slash.

### 2. The missing-heading case has no channel between B3.2 and B3.1 (blocker, correctness)
Where: plan line 228 (resolution 3's table) against lines 283-284 (resolution 5).
Defect: resolution 3 says a `ScopeScoped` page with `IDs` whose current heading is missing from the page
(added section, renamed heading) "drafts whole, with a change read". Resolution 5 defines a section
redraft as "`Draft` set, scope `ScopeScoped`, has `IDs`" and says cmd "only sends such a page when every
heading is on the page." cmd does send that page with that scope, so the pipeline treats it as a section
redraft, the bound refuses the new heading (lines 311-313), and the page escalates on `contract`. No
`Options` or `work` field carries "whole draft, but a change read"; clearing `IDs` sends "No section's own
content changed" (`internal/pipeline/blueprint.go:168`), false for an added section. B3.2 and B3.1 run in
parallel and will each pick a reading. Live row 2 never exercises it.
Fold: one rule in one place. Either the pipeline decides "section redraft" itself by running
`coverage.Regions` over the page at the start commit (recommended), or add `Options.Whole map[string]bool`
with a `work` field copied in `addPages`. Add a B3.1 row: a scoped page whose heading is missing drafts
whole with a change read.

## Major

### 3. Adding `[seat.coherence]` stops every pre-B3 run from resuming; the pre-B3 proof is vacuous (major, correctness)
Where: plan lines 345-351, 589-590 (B3.0 item 2), 656 (B3.1 "A state saved before B3 ... resumes"), 844-846.
Defect: `fingerprint` hashes every configured seat (`internal/pipeline/fingerprint.go:38-44`);
`changedSettings` counts a key absent from the old fingerprint as changed (`fingerprint.go:48-55`);
`resume.go:213` refuses on any changed key. A run stopped under the old binary refuses with
"seat.coherence.model ... changed". The B3.1 row passes only with a new-config fingerprint, missing the case.
Fold: the row's fixture state is a `fingerprint.json` with no `seat.coherence.*` keys; then either make
`changedSettings` ignore `seat.<name>.*` keys the old fingerprint lacks, or record the break as a known
limit and check for stopped runs before `make install`. `fingerprint.go` deserves the bar the ALLOW
ruling gives `resume.go`.

### 4. A bounded fix can't repair a changed fact cited outside the scope (major, correctness)
Where: plan lines 307-327, 227-229.
Defect: `Compare` scopes a bullet change to sections whose blueprint items cite the fact
(`internal/blueprint/since.go:143`, `sectionCites`), but the brief may cite it from another section.
After the redraft, provenance containment and `coverage.Check` fail on that sentence; gate fix and
`exRedraft` are bounded, so the page escalates on `contract`. The final reader reads the whole page but
its `exFinal` fix is bounded too.
Fold: in resolution 3, add to `IDs` every section whose brief sentences at the start commit cite a changed
bullet (located with `coverage.Regions`). Also either leave gate-fix turns unbounded and bound only
model-review exchanges, or state a reader finding outside scope is declinable and test it.

### 5. Live row 2's "page outside the section is unchanged" contradicts the unbounded coherence fix (major, correctness, OWNER FORK)
Where: plan line 579; design Check row 2 against resolution 6 (lines 358-362).
Options: (a) compare out-of-scope regions against the page before the coherence fix (last
`write<N>.page.md` before `stCoherenceFix`) and assert every out-of-scope change came from the coherence
exchange; (b) keep the literal check and accept that a coherence `fix` fails the row; (c) bound the
coherence fix (changes the design). Recommendation: (a).

### 6. The budget meter is reinterpreted, and one run can overshoot by `page_cap` (major, correctness, OWNER FORK on the reading)
Where: plan lines 30-35, 102-105, 572-574, 800-803.
Fork: literal meter ($10.56 left) vs baseline reading ($20 net). Mechanical: the guard checks only before
each `drafter page`; a run reserves against `page_cap` (`internal/ledger/ledger.go:125`, $10 user
layer), so a run starting at $19.99 can end near $29.99.
Fold: the live test sets `DRAFTER_PAGE_CAP` to the remaining budget per call (caps resolve to the lowest
source; env counts: `internal/config/apply.go:91-98`, `internal/config/env.go:84`,
`docs/configuration.md:57-60`). The ledger is per machine, so another session's spend counts.

### 7. The coherence-fix wiring list omits `afterCoverage` and `coverageStage` (major, correctness)
Where: plan lines 358-366; factsheet "Step machinery".
Defect: `afterCoverage`'s default sends a page to `stScoped`; `coverageStage`'s default is `s3`; a
`covCoherence` phase not added to both runs the scoped reads against `p.w.Cited`. `validate`'s default
(`parseRead`) rejects an edits answer at `stSection` and `stCoherenceFix`.
Fold: name `afterCoverage` (`covCoherence`: a miss escalates `coherence`, a clean pass sets retest and goes
to `stCoherence`) and `coverageStage` (`covCoherence` -> `s8`); add `validate` and `noRetry` for
`stCoherence`, deciding whether the coherence read retries.

### 8. The byte-identical proofs have no "before" (major, correctness)
Where: plan lines 161-162, 273-274, 630, 725-726.
Defect: both "byte-identical" rows need bytes from `f286162`; nothing captures them, so each compares new
code with itself.
Fold: in B3.0, before any pipeline or cmd edit, commit request goldens from `main` (the fixture
blueprint's dry-run read request; the stage-1 read request from `newBlueprintHarness`).

### 9. Nothing runs the cmd, pipeline, and lock path offline before live money (major, correctness)
Where: plan lines 716-722, 794-799, 576-580.
Defect: `runPage` -> lock scope -> `pipeline.Run` -> lock write -> scoped run -> no-op run is proven only
live; B3.7's offline test is a pipeline test whose gate needs the binary and Vale (`stockGatePreflight`).
Fold: one offline test of rows 1-3 through the command layer with a scripted API (a `newClient` package
variable plus an exported scripted fake, or an e2e batch stub), running the real stock gate with a built
binary on `PATH`. About 40 minutes, added to B3.7.

### 10. B3.1's tests may pin the stub prompts B3.3 replaces (major, optional)
Where: plan lines 594-596, 623-633.
Fold: B3.1 tests use a test module or assert only request structure.

## Minor

11. B3.0's file list misses `stock/stock_test.go` (`TestStockModuleSeats` asserts `[blueprint]`,
    `stock/stock_test.go:51-56`). Add at line 601. (correctness)
12. B3.5's seam is self-contradictory (lines 771-774): `Module()` reports stock only when `prompts` is
    unset (`internal/config/module.go:26-29`); an e2e test can't set an unexported var in `package main`.
    Run the negative rows as `cmd/drafter` unit tests swapping exported `stock.Prompts` with `t.Cleanup`;
    delete the seam sentence. (correctness)
13. Line 675 says "three blueprint goldens"; there are six (`stock/testdata/{whole,change}-{anatomy,neither,register}.txt`). (optional)
14. Provenance states with no named report (lines 448-450): `facts.dir` unset; `plan.LoadFacts` failing
    (exit 2 or defect?); `sentences: []`; no `sentences` key. (correctness)
15. Brief line lookup by JSON-encoded text (line 505) misses `<`, `>`, `&`; encode with
    `SetEscapeHTML(false)`. (optional)
16. `FactIDs` "from the blueprint as committed at the start commit, the same set `Project.Cited`
    computes" (lines 156-157), but `Cited` reads the working tree (`internal/blueprint/cited.go:18-25`);
    name a bytes-in variant. (correctness)
17. The blob-to-blob diff `changeBlock` gains (line 232) labels hunks `a/<blob id>`; prepend a line naming
    the file. (optional)
18. Resolution 4 adds facts and blueprint blocks to drafting requests; later exchange turns carry
    `History`, so add them on the first turn only. (optional)
19. Live harness mechanics (lines 566-569): e2e helpers strip `DRAFTER_*` and set a temp `HOME`
    (`e2e/e2e_test.go:47-72`), so the live test needs its own runner; use `exec.CommandContext` with
    `t.Deadline()`; treat exit 3 as resume-and-continue; B3.7's 120 minutes is tight. (correctness)
20. Tracks declared but none matching the page, and a `standard` other than `google` on the stock module:
    name the report or refuse in preflight. (correctness)
21. `SkipRead` trusts the lock's `accepted` and skips the blueprint and consistency reads; name every
    channel that sets it (`recordAccepted`, the new page writer, `seedEntry`, a hand edit); `work.draft`
    and `skip_read` are set only in `addPages`. (correctness)
22. `stockGatePreflight` (step 3) runs before scoping (step 6), so the "all-unchanged run resolves no key"
    test (line 714) needs Vale and drafter on `PATH`; scope before the preflight or name the test's
    `PATH`. (correctness)
23. B3.3's prompts state resolution 9's provenance rules (line 680), which B3.4 settles after pair A; add
    to B3.4: update the draft prompt's rule paragraph and golden if a rule changes. (correctness)
24. B3.6 is a single deliverable; fold it into B3.7. (optional, over-ceremony)
25. Two copies of the case list (`stock/testdata/matrix.json`, `e2e/testdata/cli/prompts-matrix.json`);
    generate one from the other or assert they match. (optional, over-ceremony)
26. Consider `opus`/`high` for B3.1 (critical path, correctness, may touch `resume.go`). (optional)
27. Resolution 1 step 2 runs `ValidateSeat("coherence")` on every blueprint run, including whole drafts.
    (optional)

## Checklist
- Risk class `runner` fits; any commit touching `resume.go` or `fingerprint.go` takes the auth-data bar.
- Library behavior quoted from source except findings 16 and 3.
- States named: gaps in 14 and 20. Privileged fields: gap in 21.
- Proofs name fixture state: vacuous risks in 3 and 8.
- Clock estimates on every task; B3.6 should fold (24); B3.7 is tight (9, 19).
