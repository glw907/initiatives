# drafter B3 plan: fold record

Fold agent: `claude-opus-5-5`, 2026-10-19, per `spec-plan-review` "The fold", after loading
`superpowers:receiving-code-review`. Inputs: the plan at initiatives `f3de09f`
(`docs-system/plans/2026-10-19-drafter-b3-drafting-plan.md`), the three reviews
(`…-plan-review-mechanics.md`, `…-plan-review-contract.md`, `…-plan-review-integrity.md`), the two
factsheets, and the approved design. Code read at drafter `main` `f286162`, read-only. The plan is
revised in place; this record names where each revision lives. Nothing is committed.

## Totals

72 findings: 27 mechanics, 21 contract, 24 integrity.

- Folded: 66. Of these, 13 are convergent duplicates folded once at their root, and 11 carry a
  ruling the planning session made on a reviewer's owner fork (listed below).
- Dropped as `optional`: 6.
- Refused outright: 0. Three folds take the finding's defect but refuse the fix it proposed
  (contract 2, integrity 4, integrity 5), each noted on its line.
- Owner forks: 0.

## Probes

Every mechanism the revision introduces was quoted from source at `f286162` or probed in the
session scratchpad's `fold-probes/`:

- `git diff --name-only <start> HEAD -- facts outline.yaml` in a scratch repo printed only
  `facts/x.md` (a changed page outside the pathspec was left out), exit 0. This backs finding 5's
  warning.
- Go: `json.Marshal("a<b>&c")` gives `"a<b>&c"`, and an encoder with
  `SetEscapeHTML(false)` gives `"a<b>&c"` (mechanics 15).
- Go: a skipped test prints `--- SKIP` under `-v` while `go test` prints `ok` (contract 7).
- Source quotes, each cited in the plan where used: `fingerprint.go:37-61` and `resume.go:213`
  (the refusal); `apply.go:90-98` `putCap` and `env.go:12-14` `envName` (the env cap lowers only);
  `checkprompts.go:219-237` (containment); `stock/prompts.js:28` (the `#slug` token);
  `assemble/files.go:104` (`tokens`); `config/module.go:26-29` and `stock/stock.go:15` (the
  exported `stock.Prompts`); `steps.go:278-328` (`coverageStage`, `afterCoverage`);
  `handle.go:98-104,192-234` (`noRetry`, `validate`); `check.go:197-221` (`redGate` keeps the
  exchange and sets the step from its kind, so a new `gate_fix` flag is needed to tell a gate-fix
  turn apart); `edits/render.go:15` and `apply.go:82` (declining a blocking finding);
  `steps.go:387-403` (`snapshotRound1`, the model for `coherence.page.md`); `blueprint/cited.go:18-25`
  (`Cited` reads the working tree); `cmd/drafter/read.go:448-462` (`recordAccepted` rewrites only
  `Accepted`); `blueprint/since.go:56-60` (`Scope.Bullets` lists every changed bullet);
  `e2e/e2e_test.go:17-72` (TestMain's binary, the env-stripping runner); `run/id.go:38-48`;
  `key/key.go:26-35`; `run/state.go:28` (`stopped` marks a resumable run); `batch/request.go:44-49`
  (each request carries its output schema, which the scripted stub keys on);
  `cmd/drafter/read_test.go:342-392` (`readStub`); `cmd/drafter/main.go:15` (exit 3 is a stop);
  `docs/blueprint-format.md:150-162` (a `sentence` item's `facts` is optional).

The new state the revision adds, two `omitempty` bools (`work.section`, `exchange.gate_fix`) and one
run-directory snapshot file, answers measured defects (mechanics 2, contract 9 with ruling 6,
mechanics 5 with ruling 2) and follows existing patterns (`work`'s non-strict decode, which the
integrity review checked; `snapshotRound1`). No validator, registry, or marker scheme was added.

## Settled by the planning session

The planning session ruled these owner forks before the fold; the fold applied them and records
each with its reason.

1. **The $20 is this pass's own spend, a hard ceiling** (mechanics 6, contract 11, integrity 8 and
   12). Reason: Geoff's approved packet said "budget $20 of your $200 monthly credit", and the
   design's meter date happened to include edit-quality's earlier $9.44. Baseline recorded at
   launch; each live `drafter page` sets `DRAFTER_PAGE_CAP` to the budget left; the ledger is per
   machine. Plan: finding 1, standing answer 2, resolution 12 "The budget", B3.0 item 0, B3.7
   item 1.
2. **Live row 2 compares out-of-scope regions against the page before the coherence fix**
   (mechanics 5, integrity 11). Reason: the design lets the coherence fix touch any section, so the
   literal "page diff outside it is empty" fails a correct run. Recorded as a clarification of the
   design's Check row 2 that the PR body names as a departure. Plan: resolution 12 row 2 and "The
   clarification of Check row 2", resolution 6 (`coherence.page.md`), B3.7 acceptance.
3. **The fingerprint upgrade break is a known limit; `fingerprint.go` is not edited** (mechanics 3,
   integrity 4). Reason: `fingerprint.go` was never inside the ALLOW ruling. Before `make install`
   the executor checks no run is stopped and resumable; B3.1's pre-B3 resume row asserts the
   documented refusal. Plan: finding 6, Merge order 1, B3.1 last test row, Later.
4. **Commits between a run's start and its lock commit get a warning now** (integrity 2). Reason:
   the lock's start-commit field changes the lock format, which the design keeps for B3. Plan:
   finding 5, resolution 2 last paragraph, B3.2 docs and lock-write row, Later.
5. **The pipeline decides section redraft itself** (mechanics 2, integrity 7), by running
   `coverage.Regions` over the page at the start commit. Reason: one rule in one place, and no new
   `Options` channel. Plan: resolution 5 "The pipeline decides, in one place", resolution 3 table,
   B3.1 section-decision row.
6. **Widen `IDs` by the brief; bound only model-review exchanges; out-of-scope reader findings are
   declinable; a page with no brief drafts whole** (mechanics 4; integrity 5, 6, 16; contract 9).
   Reason: the reviewers' recommendation; a bounded gate fix or final redraft otherwise escalates a
   correct redraft. Plan: resolution 3 table and "Widening `IDs` by the brief", resolution 5 "Where
   the bound applies" and "Declining an out-of-scope finding", B3.1 and B3.2 rows.
7. **An offline end-to-end test through the command layer runs before any live run; B3.6 folds
   into B3.7; path recomputed** (mechanics 9 and 24, contract 4). Plan: B3.7 items 1 and 2, the
   path estimate. Arithmetic below.
8. **B3.1 runs on `opus` at `high`** (mechanics 26). Reason: it is the critical path and may touch
   `resume.go`. Plan: the executor bullet, B3.1's heading.

## Path

Pass-core "Plan": the path is the longest chain of tasks run in sequence, a pair once at its
larger estimate. B3.0 60, then pair A max(B3.1 215, B3.3 130, B3.2 170 in the shadow) = 215, merge
and named-test check 10, pair B max(B3.4 125, B3.5 50) = 125, merge and check 10, B3.7 205 (harness
50, offline end-to-end 50, live 105), close 40. 60 + 215 + 10 + 125 + 10 + 205 + 40 = **665**,
within the 720 standing answer (1.85x the design's 360). The fold added 165 to the first draft's 500:
+10 B3.0, +45 B3.1, +10 checks, +15 B3.4, +85 B3.7, and B3.2's +80 sits in pair A's shadow.

## Mechanics review

1. Folded (root of contract 1 and 3). Resolution 10 `path`: `page.path` and `page.brief` exempt,
   `#slug` cut from `drafter:` names too, trailing `.,;:` trimmed; resolution 8 "Text the checks
   require" carries the no-prose-slash rule to B3.3; B3.3 and B3.5 rows.
2. Folded, settled (ruling 5). Resolution 5; B3.1 row.
3. Folded, settled (ruling 3). Finding 6; B3.1 row; Merge order.
4. Folded, settled (ruling 6). Resolution 3 widening; resolution 5 bound and decline.
5. Folded, settled (ruling 2). Resolution 12 row 2.
6. Folded, settled (ruling 1). Standing answer 2; resolution 12.
7. Folded. Resolution 6 names `afterCoverage` (`covCoherence`), `coverageStage` (`s8`),
   `validate` at both new steps, and `noRetry` (the coherence read stays retryable, with the
   reason); resolution 5 notes `validate` at `stSection`.
8. Folded (root of contract 6). B3.0 item 0 commits two request goldens from `f286162` before any
   pipeline or cmd edit; B3.1 and B3.2 regression rows assert against them.
9. Folded, settled (ruling 7). B3.7 item 2.
10. Folded (optional, cheap). B3.1's tests use a test module or assert request structure only.
11. Folded. B3.0 item 5 and Files name `stock/stock_test.go`'s `TestStockModuleSeats`.
12. Folded (root of contract 2). B3.5's negative rows are `cmd/drafter` unit tests that swap the
    exported `stock.Prompts` with `t.Cleanup`; the seam sentence is gone.
13. Folded (optional, cheap). B3.3 says six F2 goldens, named.
14. Folded. Resolution 9 "The edge states"; B3.4 row.
15. Folded (optional, cheap, probed). Resolution 9 output; B3.4 row.
16. Folded. Resolution 1: `Cited`'s body moves onto a bytes-in function; B3.2 `TestBlueprintHandoffs`
    row.
17. Folded (optional, cheap). Resolution 3: the blob-to-blob change block opens with the
    blueprint's path.
18. Dropped (optional). Whether the drafting blocks repeat on later exchange turns is a cost
    question; the fold didn't verify how `build` re-sends cached parts, so it changes nothing.
19. Folded (convergent with integrity 9 and 22). Resolution 12 "The runner": its own runner,
    `exec.CommandContext` with `t.Deadline()`, exit 3 resumed; B3.7 is re-estimated.
20. Folded. Resolution 1: on the stock module, a tracks mismatch or a non-`google` standard is
    refused before any request; B3.2 row.
21. Folded. Resolution 4 names every channel that sets `accepted` and the one place `work.draft`
    and `work.skip_read` are set.
22. Folded. Resolution 1 moves `stockGatePreflight` after scoping; B3.2's unchanged-run row runs
    with neither Vale nor `drafter` on `PATH`.
23. Folded. B3.4 updates the draft prompt's rule paragraph and golden if it settles a rule
    differently.
24. Folded, settled (ruling 7). B3.6 is B3.7 item 1.
25. Folded (optional, root of contract 20). One case list: the fixture's `prompts-matrix.json`,
    written by B3.3, read by the stock test and B3.5.
26. Folded, settled (ruling 8).
27. Dropped (optional). Validating the `coherence` seat on a whole-draft run costs a config check,
    and a stock config always defines it.

## Contract review

1. Folded at root, mechanics 1. Its extra row (the stock module on the page-less fixture passes
   `path`) is B3.5's e2e row.
2. Folded at root, mechanics 12. The fix it proposed is refused: an unexported `package main`
   variable is a new seam, and the exported `stock.Prompts` already lets a test swap the bytes
   while `Config.Module` still reports the stock module.
3. Folded at root, mechanics 1 (the `#slug` cut and the unknown-slug row in B3.3).
4. Folded at root, mechanics 9 (ruling 7). Its stub pieces are used: the e2e `api_base_url`
   pattern and a stub that keys on each request's output schema.
5. Folded. Resolution 9 adds a clean `provenance:` count line; live rows 1 and 2 and the offline
   end-to-end test run `drafter gate --page` and assert no skip line and the count line.
6. Folded at root, mechanics 8.
7. Folded (root of integrity 10). Resolution 12 "The opt-in and the key": `DRAFTER_LIVE=1` only
   from `make live`; the key resolves through `config.Load` and `key.Resolve`; a missing key or
   baseline under the opt-in is `t.Fatal`; `make live` runs `-v` and fails on `--- SKIP`.
8. Folded. B3.2 `SkipRead` row; the offline end-to-end test's fourth case.
9. Folded, with ruling 6: B3.1 has one row per bounded exchange (`exSection`, `exRedraft`,
   `exFinal`) and rows showing gate-fix turns and the coherence fix apply the same edit unbounded.
10. Folded. B3.3's package rows: non-empty files, at least 10 rubric rules, 5 tell pairs, and 3
    corpus entries; the editor and draft renderings name their package tokens.
11. Folded, settled (ruling 1).
12. Folded. Every task's acceptance names its tests; the session runs them by name with `-v` and
    checks `PASS` and no `SKIP`; regression rows are marked. Executor bullet; each task.
13. Folded. Fixture: one fact cited in two sections; B3.2 changed-bullet row.
14. Folded (with integrity 3). B3.2's `readStub` row: a stopped run's resume writes A's entry with
    the start commit's blueprint blob.
15. Folded. B3.2 `TestBlueprintHandoffs` row.
16. Folded. Resolution 12 rows: `accepted` equals the blob at HEAD; scope `kind: whole` with a
    `Why`; row 2 has `--json`; seat `coherence` and stage `s8`; the edited item is named in the
    fixture; each row runs only after the one before passes.
17. Folded. Resolution 12 "The project" (`tally-<unix time>`), row 3 by run-id set, empty
    `run_id`, zero cost, and the repo's meter row.
18. Folded. Standing answer 2 and B3.0 item 0: the baseline JSON goes into STATUS and the B3.0
    commit body; B3.7 reads it.
19. Folded (optional, cheap). B3.7's PR body notes the one-rule Vale style; Later lists the real
    package.
20. Folded at root, mechanics 25; goldens cut to one per new seat plus F2's six.
21. Folded (optional, cheap), all four items: `"sentences": []` (resolution 9, B3.4); a red gate in
    the coherence fix spends `exCoherence.contract` (resolution 6, B3.1); no stock prompt links
    drafter's repo, so `glw907` stays on the denylist (resolution 8); every denylisted string gets a
    row (B3.3, B3.5).

## Integrity review

1. Folded. Resolution 3: the walk compares `page`, `blueprint`, and `sections` and ignores
   `accepted`; B3.2 row.
2. Folded, settled (ruling 4). Finding 5; resolution 2; Later.
3. Folded. Resolution 2: a failed lock write prints the summary, then the error with the resume
   command; resuming a finished run writes the lock. B3.2's two `readStub` rows. The reviewer's
   claim that `resume()` accepts a finished run isn't covered by an existing test, so the row
   proves it; a refusal is a `resume.go` fix under ALLOW.
4. Folded at root, mechanics 3 (ruling 3). Its proposed `changedSettings` change is refused:
   `fingerprint.go` is outside the ALLOW ruling.
5. Folded through ruling 6: gate-fix turns are unbounded, so a red outside scope is fixable, and a
   reader finding outside scope is declinable, with a test. Its proposed routes (send reader
   findings to the coherence read; escalate an all-out-of-scope red at once with an `out-of-scope`
   rule) are refused as unneeded once those two hold.
6. Folded, settled (ruling 6). Resolution 3 table: no brief at the start commit drafts whole;
   B3.2 seeded-page row.
7. Folded at root, mechanics 2 (ruling 5). Its suggestion (cmd clears `IDs`) is not taken: it
   would send the change read the false "No section's own content changed" sentence
   (`internal/pipeline/blueprint.go:170`), as mechanics 2 notes.
8. Folded at root, mechanics 6 (ruling 1).
9. Folded. Resolution 12 "The project": `os.MkdirTemp`, kept on failure, and the run id, path, and
   resume command logged and carried in the PR body.
10. Folded at root, contract 7. B3.7 item 1's acceptance uses `env -u DRAFTER_LIVE`.
11. Folded at root, mechanics 5 (ruling 2).
12. Folded at root, mechanics 6 (ruling 1).
13. Folded. Finding 4 is reworded: the coherence fix and gate fixes may rewrite a hand edit
    anywhere; git holds the committed page.
14. Folded. Resolution 5 bound: every heading found before the edit is still found, in order;
    B3.1 fence and duplicate-heading rows.
15. Folded. Resolution 5 bound: brief sentences matched as a multiset; an added sentence lying
    only outside scope is refused; B3.1 row.
16. Folded at root, ruling 6: every gate-fix turn and the whole coherence exchange pass nil.
17. Folded. Resolution 3: an undecodable historical lock stops the walk; B3.2 row.
18. Dropped (optional). Its own recommendation for B3 is option (a), which the plan already takes;
    it isn't a fork, and B3c revisits it with real cairn pages.
19. Dropped (optional). Detecting a page that differs from its lock entry is B4's.
20. Dropped (optional). A needless whole draft when the outline entry lands with the lock costs one
    draft, once.
21. Dropped (optional). Recording `accepted` for an escalated draft is a cost call, as the reviewer
    says.
22. Folded. Resolution 12 "The runner": `TestMain`'s `binary` directory goes first on `PATH`, and
    `drafter spend` runs from it.
23. Folded (optional, cheap). B3.2's `docs/blueprint-format.md` change states the recovery for a
    stopped run's accepted pages.
24. Folded (optional; it saves time). B3.7 has no pipeline coherence test; B3.1's rows cover it.

## Owner forks

None. Every reviewer owner fork was settled by the planning session (above). No other finding
changes the approved design. The clarification of Check row 2 is ruling 2's, and the PR body names
it as a departure.

## Owed errata

None to a ratified document. The design's Check row 2 wording is clarified by ruling 2 inside the
plan and the PR body, and the design itself is not edited.
