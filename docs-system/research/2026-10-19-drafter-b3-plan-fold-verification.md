# drafter B3 plan: fold verification

Verifier: `claude-opus-5-5`, 2026-10-19, per `spec-plan-review` "The verification read". I had no
part in the fold. Inputs: the revised plan and the fold record at initiatives `78a3294`, the three
reviews, and the approved design. Code read at drafter `main` `f286162`, read-only.

Verdict: 0 blockers, 4 majors, 9 minors. Every reviewer blocker and major closed at the location
the fold record cites. The fold introduced two contradictions (findings 1 and 2), and one pair-A
ordering defect comes from the fold's added rows (finding 3). One pair file overlap predates the
fold (finding 4). No task edits `money.go` or `fingerprint.go`.

## Closure of reviewer blockers and majors

| Review finding | Closed at (plan line) | Verified |
|---|---|---|
| Mechanics B1, contract B1 and M3 (`path` check) | 666-677, 531-533, 884, 892-893, 1019-1027 | Yes. `containment` requires `page.path` (`checkprompts.go:219-237`); `#slug` emitted at `stock/prompts.js:28`; `tokens` splits as quoted (`assemble/files.go:104-110`). |
| Mechanics B2, integrity M7 (missing heading) | 355-363, 824-827 | Yes, but see finding 1. |
| Mechanics M3, integrity M4 (fingerprint) | 62-67, 864-867, 1109-1114 | Yes. `fingerprint.go:38-44`, `changedSettings` `:47-61`, refusal `resume.go:213-215`. |
| Mechanics M4, integrity M5 (fact cited outside scope) | 289-296, 407-427, 842-848 | Yes, but see finding 2. |
| Mechanics M5, integrity M11 (row 2) | 461-463, 749, 755-759 | Partly. See finding 2. |
| Mechanics M6, contract M11, integrity M8 and M12 (budget) | 33-39, 128-136, 741-744 | Yes. `putCap` lowers only (`config/apply.go:90-98`), env name rule (`env.go:12-14`), `Reserve` checks per run and page (`ledger/ledger.go:124-127`). |
| Mechanics M7 (wiring) | 376-383, 470-482 | Yes. `afterCoverage` default sends to `stScoped` and `coverageStage` default is `s3` (`steps.go:278-328`); `validate` lists only `stGateFix`, `stRedraft`, `stFinalRedraft` for edits (`handle.go:192-234`). Gap: finding 6. |
| Mechanics M8, contract M6 (goldens) | 767-772 | Yes. Capture route: finding 9. |
| Mechanics M9, contract M4 (offline end to end) | 1047-1058 | Yes in shape. Stub content: finding 5. |
| Mechanics M10 | 814-816 | Yes. |
| Contract M2 (seam) | 1021-1029 | Yes. `Module()` returns the `stock.Prompts` variable at call time (`config/module.go:26-29`); no `cmd/drafter` test calls `t.Parallel`, so the swap doesn't race. |
| Contract M5 (provenance shown) | 579-581, 748-749 | Yes. |
| Contract M7, integrity M10 (opt-in) | 710-722, 1042-1044 | Yes. `key.Resolve` honors `key_command` and `key_env` (`key/key.go:26-35`). |
| Contract M8 (`SkipRead`) | 943-944, 1055-1056 | Row added, but see finding 3. |
| Contract M9 (per-exchange bound) | 842-845 | Yes. |
| Contract M10 (package rows) | 900-903 | Yes. |
| Contract M12 (named tests) | 109-115 | Yes. |
| Contract M13 (changed bullet) | 699-702, 938-940 | Yes. |
| Integrity B1 (walk ignores `accepted`) | 259-267, 935-937 | Yes. |
| Integrity M2 (commit between start and lock) | 55-61, 241-244 | Yes; ruling 4. |
| Integrity M3 (lock-write failure) | 233-239, 959-965 | Yes in text; the rows hit finding 3. |
| Integrity M6 (no brief) | 285, 941-942 | Yes. |
| Integrity M9 (stopped live run) | 734-739 | Yes. |

## The new mechanisms

- `work.section` and `exchange.gate_fix`: `exchange` is nested in `work` (`work.go:88`), and a
  resume decodes `work` with plain `json.Unmarshal` (`resume.go:173`), so a pre-B3 state decodes
  both as false, which is right: a pre-B3 page has no bound. Quoted, sound.
- `redGate` keeps the exchange and sets the step from its kind (`check.go:196-220`), so the flag is
  needed. Quoted, sound.
- `coherence.page.md`: `snapshotRound1` writes into `p.dir` (`steps.go:385-403`), which lives under
  the run directory (`page.go:46`), outside the repo. `checkTree` walks only `page.files()` and
  `git status` of the worktree (`resume.go:257-304`), so the snapshot needs no `resume.go` change.
- The per-call `DRAFTER_PAGE_CAP`: quoted and sound. A resume double-counts the run's own earlier
  spend (finding 11), which fails safe.
- The offline end to end: the request carries its schema (`batch/request.go:44-49`), and the sync
  stub pattern is `readStub` (`read_test.go:342-392`). Content sufficiency isn't shown: finding 5.
- The pipeline's own section decision: `blueprintInputs` reads the blueprint at the run's start
  commit (`blueprint.go:63-93`), and `Regions` returns `found` per heading (`coverage/sections.go:93-109`).
  Quoted, sound. It conflicts with `missingSeats`: finding 1.
- Resume: no new field or snapshot needs `resume.go`. The plan routes any `resume.go` edit through
  ALLOW (lines 86-89, 810-812, 859-863).

## Path

pass-core "Plan": the longest sequential chain, a pair once at its larger estimate. 60 + max(215,
130, 170) + 10 + max(125, 50) + 10 + 205 + 40 = 665. The arithmetic is right and within 720.
Finding 3's fix adds about 15 minutes to B3.7, which makes the path about 680.

## Findings

### 1. major, correctness: `missingSeats` can't know a section redraft at the time it runs

- Location: plan 332-335 and 858, against 355-363. Source: `internal/pipeline/start.go:290-321`.
- Defect: `loadModules` calls `missingSeats` for every page before the first stage spends. After
  the fold, the section decision is made later, at the draft path, after the read. So at check
  time no page is known to be a section redraft. The B3.1 row "`missingSeats` lists `coherence`
  only for a section redraft" can't be written as stated. Under a literal implementation, a project
  module that lacks `coherence` passes the check, then fails mid-run after the spend. The fold
  introduced this: the pre-fold plan (f3de09f, lines 276-277) knew a section redraft from the scope
  at start.
- Proposed fix: `missingSeats` needs `coherence` for every blueprint page with `Draft` set whose
  scope is `ScopeScoped` with non-empty `IDs`, because any such page may become a section redraft.
  Reword the B3.1 row: "lists `coherence` for a scoped `Draft` page with `IDs`, and not for a
  whole draft."

### 2. major, correctness: live row 2 fails a correct run when a gate fix edits out of scope

- Location: plan 749 and 755-759, against 407-418 (ruling 6). Source: `internal/run/state.go:98-107`.
- Defect: ruling 6 makes gate-fix turns unbounded in every exchange, so a correct section redraft
  may change an out-of-scope region during a gate fix before coherence runs. Row 2 compares the
  out-of-scope regions with row 1's page, in `coherence.page.md` or the final page. The
  clarification excuses only the coherence exchange. A `run.Write` doesn't record which step or
  kind wrote it, so the test can't attribute the difference. The fold introduced this by combining
  ruling 2 with ruling 6 without reconciling them.
- Proposed fix: B3.1 appends to `record.json` (`record.go`, already in its files, outside resume)
  one entry per write: the write number, step, exchange kind, and `gate_fix`. Row 2 then fails only
  on an out-of-scope difference that a bounded write introduced, and it reports every
  out-of-scope difference from a gate-fix or coherence write. Extend "The clarification of Check
  row 2" to name gate fixes beside the coherence exchange. That stays within ruling 2's departure,
  so it is not a new fork.

### 3. major, correctness: B3.2's rows depend on B3.1, which runs in parallel

- Location: plan 943-944 (`SkipRead` "sends no stage-1 request") and 959-965 (the `readStub` lock
  rows). Source: `cmd/drafter/read_test.go:363-371` (the stub answers every Messages request with
  `{"verdict":"ok",…}`).
- Defect: B3.2 runs in the session worktree while B3.1 builds the pipeline elsewhere.
  - Before the merge, the pipeline ignores `SkipRead`, so the "no stage-1 request" assertion fails
    in B3.2's own acceptance (970-971).
  - The `readStub` rows run a `Draft` page through `pipeline.Run`. Before the merge, `Draft` is
    ignored and the page accepts at the read, so the rows pass vacuously. After the merge, the page
    drafts, and `readStub`'s read answer fails `validate` at `stDraft` (`handle.go:206-215`), so
    the page escalates, no entry is written, and the rows fail.

  Neither version of the rows passes on both sides of the merge.
- Proposed fix: in the shadow, B3.2 tests the options it builds (the `SkipRead` map and the
  scopes) at the `pipeline.Options` boundary, through a pure function. The "no stage-1 request"
  assertion and the two real-run lock rows (stopped then resumed, and failed lock write then
  resumed) move into B3.7 item 2, whose scripted stub drafts. That adds about 15 minutes to B3.7,
  for a path near 680.

### 4. major, correctness: pair A's two tasks share `docs/prompts-module.md`

- Location: plan 809 (B3.1) and 878-880 (B3.3: "Coordinate … by section"). pass-core "Pairs":
  "Two tasks whose files are disjoint … A merge conflict stops the line."
- Defect: the two tasks in the pair aren't disjoint. This predates the fold, and no review caught
  it.
- Proposed fix: B3.3 owns the whole file. It writes "The context object" from resolution 7, the
  contract it already writes against, and B3.1 drops the file. Alternatively, the session writes
  B3.1's section at the pair-A merge.

### 5. minor, correctness: the offline stub's answers are well-formed but not shown to pass rows 1-3

- Location: plan 1047-1058.
- Defect: keying on the schema yields an answer of the right shape. Rows 1-3 need more:
  - a page and brief that pass the real stock gate, provenance included;
  - coverage quotes that sit on the page;
  - for row 2, an edits answer whose old span is in the page and that resolves the section finding
    `edited`.

  A declined section finding leaves the edited sentence item uncovered, so the run escalates on
  coverage. The fold record calls every new mechanism quoted or probed, but this part isn't.
- Proposed fix: specify canned fixture answers: a page and brief written to pass the gate, a
  row-2 edits answer that replaces the canned second-section sentence, `ok` for every read, and
  stub state set per row. The fourth case's fact edit keeps the canned sentence's tokens contained.

### 6. minor, correctness: `exchangeStep(exCoherence)` isn't named

- Location: plan 458-466 and 470-482. Source: `check.go:125-133` (the default is `stGateFix`).
- Defect: the coherence fix's gate-fix turns land on `stGateFix`, not `stCoherenceFix`, unless the
  mapping is added. B3.1's resume row "stopped at `stCoherenceFix`" then tests a step the gate-fix
  turns never reach.
- Proposed fix: name `exchangeStep(exCoherence)` → `stCoherenceFix` and `exchangeStage(exCoherence)`
  → `s8`.

### 7. minor, correctness: the coherence retest flag is a third new `work` field, and it has no name

- Location: plan 465-466. The fold record lists only two new bools.
- Proposed fix: name it (`coherence_retest`, `omitempty`), and cover it in the `stCoherence`
  resume row.

### 8. minor, correctness: the fixture matrix could carry F2's register case

- Location: plan 646-651. Source: `stock/testdata/matrix.json:27` (register `docs/house-style.md`).
- Defect: "keeps F2's blueprint cases and their six goldens" reads as if the fixture matrix
  includes the register cases. The fixture doesn't track `docs/house-style.md`, so B3.5's e2e
  `path` check would fail.
- Proposed fix: `stock/testdata/matrix.json` stays as F2's six-case list. The fixture matrix names
  only paths the fixture tracks, and it has no register case.

### 9. minor, correctness: the B3.0 golden has no capture route

- Location: plan 767-772. Source: `internal/pipeline/dry.go:15-45` (a dry run counts tokens and
  prints no body).
- Proposed fix: capture the `count_tokens` request body at an httptest stub, as `apiStub` does, or
  name the in-package function that builds the request.

### 10. minor, correctness: the meter helper's test may sit behind the `live` tag

- Location: plan 1045-1046.
- Defect: a test in the tagged `e2e/live_test.go` never runs under `make check`.
- Proposed fix: put the helper and its table test in an untagged file.

### 11. minor, optional: a resumed live run counts its earlier spend twice

- Location: plan 731 and 741-744. Source: `ledger/ledger.go:124` (`pageTotal(RunID, Page)` spans
  the run).
- Defect: the cap is already net of the run's prior spend, and the ledger counts that spend
  against it again. This fails safe.
- Proposed fix: on a resume, set the cap to the budget left plus the run's own page total, or note
  the conservative count.

### 12. minor, correctness: a kept project's resume command needs the branch binary

- Location: plan 734-739. Source: `e2e/e2e_test.go:22-27` (TestMain removes its binary). Finding 6
  (the old binary refuses).
- Proposed fix: the PR body says to resume with a binary built from the branch head.

### 13. minor, correctness: B3.4's file list omits files it may edit

- Location: plan 977-981, against 1004-1006.
- Defect: B3.4 may edit `stock/prompts.js` and its golden, and its file list doesn't name them.
  Pair B stays disjoint, since B3.5 touches neither.
- Proposed fix: add them to the list.
