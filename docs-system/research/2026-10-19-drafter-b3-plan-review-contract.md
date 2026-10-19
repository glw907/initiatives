# drafter B3 plan review: contract and criteria lens

Target: `docs-system/plans/2026-10-19-drafter-b3-drafting-plan.md` at 46a83da. Design:
`docs-system/specs/2026-10-19-drafter-b3-drafting-design.md`. Code read at drafter `main` f286162.
Every claim below was checked against source on 2026-10-19; file:line refs are at f286162.

## Coverage map

Every design item maps to a task: builds 1-3 to B3.2, 4-5 to B3.1, 6 to B3.3, 7 to B3.4, 8 to B3.5,
Check 1-3 to B3.7's live rows, and the offline Check sentence to B3.1, B3.2, and B3.5. No design item
is orphaned. The gaps are in how the criteria are written: one would fail on correct code, three
can pass vacuously, and the only test that runs the whole path end to end is the live run.

## Findings, ranked by consequence

### 1. blocker, correctness: the `path` check fails the stock module on the fixture itself

- Location: plan 530-534 (resolution 10, `path`), 557 (fixture has no page and no brief), 769
  (B3.5 "exits 0"), 798 (B3.7 offline).
- Defect: resolution 7 (plan 392) has every stock prompt name the page and brief by path, and B3.0's
  stubs (plan 594-595) name `c.page.path`. The `path` check requires each slash token to be a
  file or directory git tracks. The fixture has no page, no brief, and no `docs/` directory, so
  `docs/count-items.md` and `blueprints/docs/count-items.brief.json` fail in every draft, review,
  reader, and coherence case. B3.5's positive row and B3.7's offline row cannot pass as written.
  `assemble` handles the same case by skipping an untracked token (`internal/assemble/files.go:30-55`,
  `resolve`), so the run is fine, but the check is not.
- Fold: exempt the case context's `page.path` and `page.brief` from `path`, since they are the
  run's own outputs. Keep the existing containment rule that the `blueprint` seat never names them.
  Add a B3.5 row: the stock module on the fixture with no page passes `path`.

### 2. major, correctness: B3.5's test seam contradicts `Module()`, so its negative rows fail and its positive row is vacuous

- Location: plan 771-775 (B3.5), 539 ("A project module, set by `prompts` or `--module`, gets
  neither check").
- Defect: `Config.Module` returns the stock module only when `Prompts == ""`
  (`internal/config/module.go:26-35`). A copy of the stock module passed as the configured
  `prompts` is a project module, so by resolution 10 neither check runs. Then the rows "fails
  `path`" and "fails `names`" fail. The row "a project module with the same rendering passes both
  checks" passes because nothing ran. The plan names the seam only as a fallback ("If that needs a
  seam").
- Fold: make the seam the primary route. Use an unexported `package main` variable holding the stock
  module bytes, swapped in the cmd test (`cmd/drafter/checkprompts_test.go`). The e2e test keeps
  only the positive stock row. Drop "passed as the configured `prompts`".

### 3. major, correctness: a `drafter:` token with a `#slug` fails both stock-token checks on F2's existing seat

- Location: plan 532-533 (`#slug` is cut only for repo paths), 678 (B3.3 "Every `drafter:` token
  in a rendering is a `stock.Files` name").
- Defect: F2's blueprint seat already emits `drafter:anatomies.md#task-guide` (`stock/prompts.js:28`,
  present in `stock/testdata/whole-anatomy.txt`). `stock.Files("anatomies.md#task-guide")` returns
  false (`stock/stock.go:34-44`). Both checks fail on unchanged F2 output.
- Fold: cut `#slug` before the `stock.Files` lookup in both resolution 10 and the B3.3 test, and
  add a row asserting that an unknown slug still passes (slugs are `assemble`'s concern).

### 4. major, correctness: no offline test runs `drafter page` end to end, so the live run is the only join of B3.1, B3.2, B3.3, and B3.4

- Location: plan 794-799 (B3.7 offline: pipeline package, scripted `fakeAPI`), 716 (lock write
  tested on a synthetic `Summary`). Design 95-97 promises the lock write is covered "with the fake
  API".
- Defect: the B3.7 offline test runs inside `internal/pipeline`, on harness handoffs, with the
  harness gate `sh gate.sh` (`internal/pipeline/harness_test.go:180`). Nothing offline exercises
  these: `blueprintHandoffs`' new `Inputs` fields reaching the context the prompts read; scope from
  the lock; `SkipRead` routing; the lock write after a real `pipeline.Run`; the real stock gate
  with provenance on a pipeline-written brief; and row 3's no-op. A seam mismatch between pairs
  shows up first as a failed live row, and each live attempt costs money. The pieces for a
  cmd-level stub already exist: `readStub` (`cmd/drafter/read_test.go:344-390`, a sync-mode
  httptest server) and `apiStub` (`e2e/page_test.go:28-147`, with `api_base_url`).
- Fold: replace B3.7's offline item 1 with an e2e (or cmd) test that runs the built `drafter page` in
  sync mode against a scripted stub on a git copy of `e2e/testdata/cli`, with the real `drafter
  gate`. Run live rows 1 to 3 with the same assertions. Keep the pipeline test only for the
  coherence fix and retest. Estimate about +30 minutes on B3.7. That is cheaper than one failed
  live attempt.

### 5. major, correctness: the live rows never show the provenance check ran

- Location: plan 56-57 (Outcome 2: "passes the stock gate, including the new provenance check"),
  578 (row 1 assertions), 448-450 (no brief: prints a skip and exits 0).
- Defect: row 1 infers the gate from "accepted". The gate's skip path exits 0, so a `BriefPath`
  that disagrees with where the pipeline writes the brief would pass every row silently. The
  offline pipeline tests use a fake gate (finding 4), so nothing in the plan observes provenance on
  a drafted page.
- Fold: after row 1's commit, and again after row 2's, run `drafter gate --page docs/count-items.md`.
  Assert exit 0, no `provenance check skipped` line, and a line or JSON field showing the
  provenance rule count. Do the same in finding 4's offline test.

### 6. major, correctness: the "byte-identical to today's" rows have no pre-change golden

- Location: plan 630 (B3.1: "The blueprint read's request is byte-identical to today's"), 725-726
  (B3.2: `drafter read`'s dry-run request "byte-identical before and after"), 273-274.
- Defect: the only existing golden is the blueprint prompt rendered through the chain module
  (`cmd/drafter/read_test.go:190-235`, `testdata/blueprint-prompt.golden.txt`). It does not cover
  the assembled request: the facts block opening at `internal/assemble/blueprint.go:19`, the
  `Inputs`, or the fact list. A "before and after" test written after the change compares new code
  with itself and passes vacuously.
- Fold: in B3.0, on the f286162 code, capture and commit two request goldens: the fixture's
  `drafter read --dry-run` request body, and the pipeline blueprint-read request from
  `newBlueprintHarness`. Both B3.1 and B3.2 assert against those files.

### 7. major, correctness: `make live` passes green when the live test skips

- Location: plan 567-568 (skip without `DRAFTER_API_KEY`), 786-787, 813.
- Defect: `go test` reports `ok` for a skipped test. Three ways it skips while the user can
  actually run live:
  - The executor's key may not reach `make`'s environment.
  - The user layer sets `key_env` (present in `~/.config/drafter/config.toml`), so the run's key may
    come from a variable other than `DRAFTER_API_KEY` (`internal/key/key.go:26-34`).
  - A `key_command` bypasses the environment entirely.

  Nothing says what an unset `DRAFTER_LIVE_BASELINE` means. The PR body's run ids catch this only
  by omission.
- Fold:
  - The guard resolves the key through `config.Load` and `key.Resolve`, not a fixed variable name.
  - When `DRAFTER_LIVE_BASELINE` is set, a missing key is `t.Fatal`, not a skip. An unset or
    unparseable baseline is `t.Fatal`.
  - `make live` runs `-v` and fails if the output holds `--- SKIP`.
  - B3.6's acceptance keeps the skip row for the no-baseline case only.

### 8. major, correctness: `SkipRead` is never set by a tested cmd path and never exercised live

- Location: plan 243-245 (`runPage` sets `SkipRead`), 706-726 (B3.2 tests: no row), 576-580 (live
  rows 1 and 2 both run the read). Design build item 1 ("skipped when the lock's `accepted` matches
  the blueprint").
- Defect: B3.1 tests the pipeline branch with `SkipRead` injected. No row checks that cmd sets it
  from the lock, or leaves it unset when `accepted` differs. A wrong comparison (for example,
  comparing against the HEAD blob instead of the start commit's) passes every listed test.
- Fold: add a B3.2 table:
  - `accepted` equals the blueprint blob at the start commit, plus a fact-only change: `SkipRead`
    is true and no stage-1 request is sent.
  - `accepted` is stale: `SkipRead` is false.

  Finding 4's offline test should include a fourth case: a fact-bullet edit run with `SkipRead`.

### 9. major, correctness: the region bound is tested only on `edits.Apply` and one exchange kind

- Location: plan 323-327 (the bound applies at `exSection`, gate fixes, `exRedraft`, and `exFinal`),
  634-642 (B3.1 bound rows on `Apply`; "The refusal reaches the model through `refused`").
- Defect: no row proves `completeExchange` passes a non-nil bound at each of the four exchanges.
  An implementation that bounds only `exSection` passes every listed test. Live row 2 then catches
  it only if the model happens to stray in round 1 or the final redraft.
- Fold: add one pipeline table row per exchange kind (`exSection`, a gate fix, `exRedraft`,
  `exFinal`). The scripted answer edits an out-of-scope section, and the run records a contract
  refusal naming that line. Keep the coherence-fix row asserting nil.

### 10. major, correctness: B3.3's package tests pass on the empty files B3.0 commits

- Location: plan 596 (B3.0 embeds four empty `google-*.md`), 683-684 ("Each rubric rule carries a
  URL", "Each corpus entry carries a URL, a license, and a retrieval date").
- Defect: every per-rule and per-entry test passes vacuously on zero rules or entries. No row
  checks that the tells file holds before-and-after pairs (design build item 6). No row checks that
  the editor rendering actually points at the rubric ("The editor seat grades the rubric"), or that
  the draft rendering points at the description, tells, and corpus.
- Fold:
  - Assert each file is non-empty, the rubric has at least 10 rules, the corpus has at least 3
    entries, and the tells file has at least 5 pairs.
  - The editor rendering contains `drafter:google-rubric.md` and `drafter:google-tells.md`.
  - The draft rendering contains the description, tells, and corpus tokens.

### 11. major, correctness, OWNER FORK: the $20 meter is read as a delta, but the design reads it as absolute

- Location: plan 30-35 (finding 1), 102-105, 572-574. Design 115-116: "Live spend up to $20 runs
  without asking. The meter is `drafter spend --since 2026-10-19 --json`, its `total` plus
  `open.worst`."
- Defect: the design's sentence gives the absolute meter reading. The plan subtracts a baseline,
  $9.44 at planning, so the pass can spend up to about $29.44 against the meter. That is a money
  call, and the plan defaults it for the planning session.
- Options:
  - (a) Absolute, as written: $10.56 of headroom, about one and a half live attempts.
  - (b) Delta, as planned: $20 of fresh spend.
  - (c) Absolute, with Geoff raising the cap.
- Recommendation: (a). It is the literal standing answer, and finding 4's offline end-to-end test
  makes the first live attempt far likelier to land. Either way, record the reading in the packet.

### 12. major, correctness: task acceptance is "`make check` green", which a task meets without its listed tests

- Location: plan 606, 657, 685, 727, 757, 777, 786.
- Defect: no acceptance row names its tests or the reason each fails today. A pair that writes half
  the listed rows still turns `make check` green, and the session checks only the gate and twice
  the estimate when a pair returns (plan 88-89). The design says each row fails today. The plan
  never restates that per task, or marks the regression rows (handoff tests unedited,
  byte-identical requests) as rows expected to pass today.
- Fold: each task's acceptance lists its test names. When a pair returns, the session runs `go test
  -run '<names>' -v` and confirms each shows PASS and none shows SKIP. Rows marked as regressions
  are expected to pass on f286162; every other row is expected to fail there. This costs about 2
  minutes per task.

### 13. major, correctness: no row for "a changed fact bullet counts for every section that cites it"

- Location: design 62; plan 710-713 (B3.2's scope rows are by `Compare` result, plus "reads the old
  facts from that commit's parent").
- Defect: the design promise depends on resolution 3's inferred old facts from `L^`, the most
  fragile new mechanism (plan finding 2). No row commits a bullet edit after the lock and asserts
  that the scoped `IDs` equal exactly the sections citing that fact.
- Fold: add the B3.2 row. Use a fixture fact cited in two of the three sections, edit its bullet,
  and assert `IDs` equals those two section ids.

### 14. minor, correctness: no row for the lock write after a resumed blueprint-mode run

- Location: plan 189-191.
- Defect: the resume path writes the lock with the start commit from state. No test covers it, and
  that is the path that produces a wrong `blueprint` blob id if `startCommit` is misread.
- Fold: add a B3.2 row: a run stopped in sync mode (`readStub`'s `failFrom`), then `--resume` with
  the same arguments, writes the entry with the start commit's blueprint blob.

### 15. minor, correctness: no row pins the `Inputs` fields B3.3's prompts read

- Location: plan 153-158; B3.2 tests 723-724 (cover `entryJSON` only).
- Defect: B3.2 produces `PageType`, `FactIDs`, and `ExemplarSources`, and B3.3 consumes them from
  synthetic matrix contexts. Nothing joins the two except live.
- Fold: add a `TestBlueprintHandoffs` row on the fixture asserting all three. Finding 4 also closes
  this gap.

### 16. minor, correctness: live row assertions that are weaker than they read

- Location: plan 578-579.
- Defects and folds:
  - Row 1, "`accepted` is set": assert that it equals the blueprint blob at HEAD.
  - Row 1, "scope whole": `PageResult.Scope` is nil for a whole read with no comparison
    (`internal/pipeline/pipeline.go:90-92`). Say which form is expected (`kind: whole` with a `Why`,
    per plan 199).
  - Row 2 has no `--json`, yet it asserts the scope ids. Add the flag.
  - Row 2's coherence check: assert seat `coherence` as well as stage `s8`.
  - Row 2's edited item: name it in the fixture (a `sentence` item in the second section), so
    `IDs` is deterministic and finding 13's shared fact isn't touched.
  - Rows 2 and 3 run only after the previous row passes (`t.Fatal` on a miss), so a row 2 miss
    doesn't report a row 3 failure.

### 17. minor, correctness: row 3's "no run directory" and "meter unchanged" observations are ambiguous

- Location: plan 580.
- Defect:
  - Runs and the ledger file live under `runs/<repo>`, where `<repo>` is the main checkout's
    basename (`internal/run/id.go:42-50`). A `t.TempDir()` copy is named `001`, so reruns from fresh
    copies, and other tests, share one directory.
  - The meter's `total` covers every repo, so concurrent spend elsewhere false-fails "unchanged".
- Fold:
  - Copy the fixture into a uniquely named directory (`tally-<unix time>`).
  - Assert row 3 by the set of run ids before and after, and by the summary's empty `run_id` and
    zero cost.
  - Read the meter's row for that repo (`spendRow.Repo`) rather than `total`.

### 18. minor, correctness: the baseline reading has no named artifact

- Location: plan 32-33, 800-801.
- Defect: "recorded at the first execution commit" doesn't say where, and B3.7 must pass it to
  `DRAFTER_LIVE_BASELINE` hours later.
- Fold: write the `drafter spend` JSON into STATUS and the B3.0 commit message body. B3.7 reads it
  from there, and the PR's spend section quotes it.

### 19. minor, optional: "passes the stock gate" runs Vale on a one-rule synthetic style

- Location: plan 548-549.
- Defect: offline, this is right. Live, though, the Vale half of the gate is near-vacuous, and the
  packet would read "passes the stock gate" as the real Google style.
- Fold: the PR's acceptance table says that Vale ran the fixture's one-rule style. A real Google
  package run goes in "Later".

### 20. minor, optional (over-ceremony): two hand-mirrored matrices plus a golden per case

- Location: plan 673-674 (`stock/testdata/matrix.json` with about 20 goldens "mirrors resolution
  10's case list"), 514-523 (`e2e/testdata/cli/prompts-matrix.json`).
- Cost: about 20 opus-written goldens. Every live-miss prompt fix in B3.7 regenerates them, and two
  case lists can drift apart.
- Fold: keep one matrix (the fixture's) and have the stock test read it. Keep goldens only for the
  three F2 blueprint cases and one case per new seat. The targeted `Contains` rows (plan 679-682)
  carry the content. This saves about 15 minutes of B3.3 and the churn in B3.7.

### 21. minor, optional: small rows the provenance and check-prompts tables miss

- Location: plan 740-751, 535-537.
- Folds:
  - Add a provenance row for `{"sentences": []}` on a page with prose: it fails with unclassified
    page text, not a pass.
  - Add a row for a red gate inside the coherence fix: which budget it spends is unstated in
    resolution 6.
  - The `names` denylist's `glw907` also matches drafter's own public repo URL, already in
    `stock/introductions.md:98`. Either exempt `github.com/glw907/drafter` or note that a stock
    prompt never links drafter's docs.
  - Cover every denylist string in the `names` table, not just `cairn`.
