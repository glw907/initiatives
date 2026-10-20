# Plan fold: drafter blueprint-first

Date: 2026-10-20. Target: `plans/2026-10-20-drafter-blueprint-first-plan.md` and its executor and
conductor prompts, revised in place. Reviews folded:
`research/2026-10-20-drafter-blueprint-first-plan-review-{contract,mechanics,integrity}.md`. Every
finding was checked against drafter `6a42564`, cairn-cms `origin/main` `52b3f979e`, and the approved
design before it was acted on.

## Brief

73 findings: 71 folded, 2 refused, 0 owner forks. Convergent findings were folded once, at their
root, and each converged row names the root. The four reviewer-raised forks (contract B1 and M3,
mechanics 7 and 8, integrity 8; mechanics 9 asked for an early question) each have one answer inside
the approved design, so none goes to Geoff; the reason is in each row. The path is now 1080 minutes
(was stated as 955, which summed to 975), at the 1080 standing answer, after the fold verification's
three majors added 20 minutes and K gave back 5 (see "Verification applied").

## Code facts checked before folding

- `drafter spend --since` takes a date only: `cmd/drafter/spend.go:38`, `"first UTC date to count,
  YYYY-MM-DD"`, and `:66`, a usage error otherwise. The JSON rows are `spendRow` totals by repo and seat.
- `recordReads` skips an unchanged accept: `cmd/drafter/bar.go:91` `if e.Accepted == r.Accepted {
  continue }` and `:96` `if e.Accepted == r.Accepted && e.Blocked == nil { continue }`.
- `scopedAccept` (`cmd/drafter/read.go:395-404`) is true for any accepted scoped result with no
  `BarFrom`; `scopeBases` skips a result with `r.Since == ""` (`:530`); `scopedRefusal` then refuses
  with "the blueprint it accepted is not the one at the scoped read's base". A lapse read hits this.
- `applyBar` returns `heldPage` on `ScopeUnchanged` (`bar.go`), so a rerun of a barred, unchanged
  blueprint sends nothing.
- `make check` depends on `chain-test` and `prompts-parity`, which depend on `build`
  (`Makefile:21-31`, `:57`), so it rebuilds the binary in place.
- `start.go:176-179` and `resume.go` both call `plan.LoadFacts(cfg.Facts.Dir)` from the working tree,
  and `checkPosition` accepts any descendant HEAD.
- A page-cap reservation escalates with rule `cap` before any request (`money.go`, `case
  errors.Is(err, ledger.ErrPageCap): return p.escalate("cap", ...)`; `ledger.go` `page+r.Worst >
  c.Page`). `count_tokens` runs first and is free.
- The pipeline fixture `lumen-key-ttl` is `[verified]` with `Source: the key policy`
  (`internal/pipeline/testdata/project/docs/facts/keys.md:5`); `readStub` answers
  `{"verdict":"ok",...}`; `schemaKind` returns `unknown` for a `{facts}` schema; `clifixture_test.go:150`
  expects two count requests; `e2e/testdata/cli/main.go` is 50 lines.
- `check-prompts` takes `--module`, `--matrix`, `--expect` (`checkprompts.go:46-49`);
  `schema/plan.schema.json:82` requires `fact` on a disposition.
- `scripts/drafter-gate.sh:12` runs `cairn-run-gate --fresh "make -C '$dir' check"` itself.
- The skill's `format.md`, `anatomies.md`, and `introductions.md` are relative symlinks.
- `MAX_TIDY_CHARS = 24_000` is at `src/lib/sveltekit/content-routes-tidy.ts:51` on cairn `origin/main`.
- `facts.dir` and `facts.bullet_format` are wired through `internal/config/{config.go:94-97,
  file.go:96, apply.go:151-152, env.go:53-54}`; `seatNames` lives in `internal/config/check.go:16`.
- The intents in `state.json` carry `Mode` from the config (`money.go:131`); the summary JSON has none.
- `DecodeLock` sets `KnownFields(true)` (`internal/blueprint/lock.go:60`).
- cairn's owner brief is 127 lines; cairn's facts README makes a page-sourced bullet `[candidate]`,
  never `[verified]` (README:86-88).

## Contract review

| Finding | Disposition | Where the revision carries it |
|---|---|---|
| B1, a page-run accept writes `facts` | Folded, root of integrity 8. Fork refused as a fork | Finding 12 (only a `drafter read` accept that judged the facts writes the map; a page-run accept leaves it), finding 19, D2 build and test row. The residual (in-run drafting of a stale-accept page) has one answer inside the design: its "Later" gives "drafting from gated blueprints only" to the drafting pass, and this pass drafts nothing. Plan "Later", drafter PR Decisions, conductor prompt routine row. The review's "writes accepted with no facts" became "leaves facts as it was": the lapse check compares the whole current read set, so any bullet the page run did not judge lapses the entry either way, and an entry with no map still refuses |
| M1, finding 8 reopens the stale-page path | Folded, root of mechanics 22 and contract M7. Not a fork | Finding 8 rewritten: a new `facts.prose_sources` setting lists the prose files that may stand as a source; every other prose pointer, a live page above all, stays `no excerpt: prose`, so the design's "a live page is never a source" holds by construction. D3 files, build, and tests (an unlisted `docs/...md:N` stays `no excerpt`); cairn lists the owner brief in its committed `drafter.toml` in E's first fix round; E's work list retraces f:q07rd5. Control 5 keeps its code pointer and adds the live page's line as a further pointer, so the seat sees only the contradicting code and the page pointer is shown to add nothing |
| M2, the replay can pass on a union of prompts | Folded | Standing answer 3 (reruns all seven placing blueprints when M1's pricing fits, otherwise the missed ones; score on final-prompt verdicts, union never reported alone), R1 step 3 (prompt version column), R2 step 4 (the false-block bar judged again on E's first read, the first read of all eight at `main` under the final prompt, at no added spend) |
| M3, finding 7 loosens the false-block bar | Folded; fork refused | Finding 7 and R2 step 2: three counts reported, and a fresh-context `general-purpose` reader checks every pointer-column `wider` row against its excerpt before the bar is judged. Not a fork: the design defines `wider` against the excerpt ("the fact claims more than the excerpt shows") and already counts the same defect under `no-excerpt` as a correct block, so finding 7 is the design's reading. If the design-literal count is above zero while finding 7's is zero, the conductor puts finding 7 to Geoff as an ask row (conductor prompt) |
| M4, the no-spend check cannot run | Folded, root of mechanics 6 and integrity 5 | Finding 22 (spend.go quoted), M2 step 2, K step 1.2 |
| M5, a blocking lapse read's lock write | Folded, root of mechanics 27 | Finding 21 (a blocking lapse read writes nothing, as a change read that blocks does today), D2 test row, K step 1.3 checks `git status --porcelain` is empty rather than restoring the lock blindly |
| M6, the rebuild can see the tidy blueprint | Folded | S (passages from the eight or synthetic text), RB step 1 (`cp -L` into the rebuild worktree's own git dir, moved there from `/tmp` by verification minor 1; grep for tidy and its item ids), RB step 2 (no other branch, worktree, or drafter git dir) |
| M7, "built from the code" has no check | Folded at root M1 | Under finding 8 a verified fact resting on a live page alone blocks, so the accept implies it; B step 5 records `BIN check`'s `no-excerpt` count for tidy |
| M8, the budget can pass $45 | Folded, root of mechanics 8 and integrity 10 | The meter: a reserve for B, RB, and K priced at M1 step 4; E's read calls start only while `left − reserve > 0`; M1 step 4 projects the total and R1 step 4's question names an overrun. Inside the design: the design ranks the tidy build and the skill above the eight and lets an unaccepted blueprint of the eight be reported |
| M9, flags not checked against the hand check | Folded | R1 step 3 match column (match, partial, other); the bar stays the raw count |
| m1, M2's probe assumes debug's state | Folded, root of mechanics 10 | M2 step 2 picks any of the eight with `accepted` equal to its blob and no `facts`, else cites D2's tests |
| m2, K's `drafter page` can spend | Folded, root of mechanics 14 and integrity 4 | K step 1.2: dry run first, then `DRAFTER_PAGE_CAP=0.01` with meter readings |
| m3, K's edited fact may lapse the eight | Folded | K step 1.2: a fact `BIN refs` lists for tidy alone |
| m4, K step 1.1 repeats B's read | Folded, root of mechanics 33 | K step 1.1 cites B's final read unless a Go or tidy-fact commit landed since; mode from `state.json` intents |
| m5, RB's "fewer" is ambiguous | Folded | RB step 4: total across three seats, by seat, with item and placed-fact counts |
| m6, the covers trial can pass vacuously | Folded | B step 5 offline negative probe |
| m7, D1's tests miss parts of the contract | Folded | D1 build (an id answered twice takes the worse verdict; an unrequested id is dropped with a warning) and tests; D2 lapse-read test asserts the consistency request |
| m8, the friction log has no closure | Folded (cheap) | S: disposition table; K's record carries it |
| m9, finding 14 cites a missing task | Folded, root of mechanics 21 and 26 | Finding 14 says R2; R3 step 4 names `blueprint-first-controls-c` and its command |
| m10, control 5 may bite on consistency | Folded (cheap) | R3 step 5 lists every seat that fired |
| m11, "was:" text claim too strong | Folded (cheap) | Finding 3 reworded "not built in this pass", with the recovery route; plan "Later" |
| m12, launch reading and cairn review ceremony | Folded | Factsheets read by section (plan header, executor prompt); Close step 3 reviews only cairn's hand-written files |

## Mechanics review

| Finding | Disposition | Where the revision carries it |
|---|---|---|
| 1, D1 misses the tests its seat breaks | Folded | D1 files list names the four, with the fixture re-point; D1 at 150 |
| 2, count golden red at M1; D3 test unwritable | Folded | M1 step 1 regenerates the golden in a merge-fix commit; D3's byte-identity test compares against `drafter page --dry-run`'s draft request |
| 3, E never re-reads R2's accepts | Folded | E's read call names every entry lacking `facts` (all eight on the first call) |
| 4, rotate's pre-seat bar | Folded at root integrity 3 | Finding 20 |
| 5, the R2 rerun is held by its own bar | Folded, root of integrity 6 | Standing answer 3: rerun in the main rerun worktree detached at R2's start commit, lock restored; plan "Names" |
| 6, `spend --since <minute>` | Converged on contract M4 | Finding 22 |
| 7, path is 975; tuning on the path; B's clock | Folded; fork refused as a fork | Outcome path recomputed (1075 at the fold, 1080 after verification) with one tuning round and B at 240; finding 23 and standing answer 6: the design says nothing but spend stops the tidy build, so B's clock overrun is reported, not a stop; W's clock is 235. The plan's runtime "1080-minute path ceiling" stop is removed: the design states 1080 as the launch criterion only |
| 8, spend can pass $45 | Converged on contract M8 | The meter's reserve |
| 9, ask the replay question now | Refused | The design already says three tuning rounds, then stop and ask; asking now would change the design's order without need. R1 step 4 prepares the question |
| 10, M2 probe state | Converged on contract m1 | M2 step 2 |
| 11, a `cap` escalation has no answer | Folded | The meter: record, split, rerun; `left` below one page's worst case is the spend stop; reported as a budget limit, never a finding |
| 12, D4's base relative to D2 | Folded, differently | Window W and D4: D4's first step merges D2's branch into its own worktree. The review's session-side merge would run `make check` and rebuild `BIN` under the live proof |
| 13, `make check` rebuilds `BIN` | Folded in part | M1 step 1 and run rules: no `make check` or `make build` during a live call; each row names its commit. The per-sha binary copies are refused as more machinery than the one-call-at-a-time rule needs |
| 14, K's `drafter page` outside the meter | Converged on contract m2 | K step 1.2 |
| 15, `check-prompts` can't take an outline | Folded | D4 tests: a pipeline-harness dry-run read with a mapping element |
| 16, D4 misses `plan.schema.json` | Folded | D4 files |
| 17, tuning omits the count golden | Folded | Standing answer 3's tuning file list |
| 18, a second stop | Folded, root of integrity 14 | Run rules: abandon, wait on the wake-up, read fresh; a third stop is standing answer 11 |
| 19, RB's symlinks | Folded | RB steps 1 and 2 |
| 20, K's wrong path | Folded | K step 1.2 |
| 21, "P2's" | Converged on contract m9 | Finding 14 |
| 22, whole-file rule's scope for prose | Folded at root contract M1 | D3: whole file for code files only; listed prose keeps line windows; test sized to match |
| 23, two "no real excerpt" predicates | Folded | T1 exports one excerpt entry over today's path (T1 at 30); D1 and D3 call it |
| 24, the skill read through the pre-D3 link | Folded | Plan "Executor" and executor prompt: read the worktree copy by path |
| 25, B's read omits citers | Folded | B step 3 command and N |
| 26, R3 step 4 has no command | Converged on contract m9 | R3 step 4 |
| 27, blocking lapse read's write | Converged on contract M5 | Finding 21 |
| 28, merge note misses `seat` and `kind` | Folded | Merge order 1 |
| 29, `max_tokens` may be tight | Folded (cheap) | Standing answer 3 lets a tuning round raise it in `stock.toml` as a traced cause |
| 30, the gate-string form in an isolated session | Refused | The plan already runs `scripts/drafter-gate.sh`, which is the no-argument wrapper (`:12` calls `cairn-run-gate` itself) |
| 31, planning files must be on `main` first | Folded | Pre-flight line; conductor prompt pre-launch check |
| 32, S's prose review repeats Close's | Folded | S outcome; Close step 3 holds the one review; S at 40 |
| 33, K step 1.1 repeats B | Converged on contract m4 | K step 1.1 |
| 34, T0's `prompts` re-point is pointless | Folded | T0 step 6 copies the toml unchanged |

## Integrity review

| Finding | Disposition | Where the revision carries it |
|---|---|---|
| 1, accept short-circuits never write `facts` | Folded | Finding 13, D2 build and test row |
| 2, a lapse accept is refused as scoped | Folded | Finding 21 (`PageResult.Lapse`, own case before `scopedAccept`), D2 build and test row |
| 3, rotate's pre-seat bar | Folded, root of mechanics 4 | Finding 20; D1 sets `seat` on every read finding. Variant: a bar accept on a seatless bar writes `accepted`, clears the bar, and writes no `facts`, so the next read is whole, rather than changing `applyBar` |
| 4, K's uncapped `drafter page` | Converged on contract m2 | K step 1.2 |
| 5, `spend --since <minute>` | Converged on contract M4 | Finding 22 |
| 6, the R2 rerun is held | Converged on mechanics 5 | Standing answer 3 |
| 7, the map reloads from disk on resume | Folded in part | D2: one `FactsHashes` for writer, lapse check, and refusal; run rules: no commit between a stop and its resume. The git-path map and the `--resume` guard are refused as costing more than the risk in a pass whose session is the only writer, with `resume.go` off limits; plan "Later" |
| 8, a page run writes an unjudged map | Converged on contract B1 | Finding 12 and 19 |
| 9, no re-verify at close | Folded | Close step 4 |
| 10, no reserve for B; caps bind early | Converged on contract M8 and mechanics 11 | The meter |
| 11, `FactChanged` misses edits; third clause costs | Folded | Finding 12: the scoped third clause is dropped; a scoped accept leaves `facts`, so any change lapses on the next read |
| 12, lapse set includes uncited ids | Folded | Finding 11, D2 build and test |
| 13, a duplicate id hashes one bullet | Folded (cheap) | Finding 3, D2 build |
| 14, a second stop | Converged on mechanics 18 | Run rules |
| 15, no check that a subagent never spent | Folded (cheap) | The meter: a reading at each subagent return; B step 3 |
| 16, other workstation's runs; evidence lifetime | Folded | Merge order 1 and conductor prompt; K's record carries every STATUS table; Close keeps the drafter worktree |
| 17, R1 reads rotate | Folded | R1 command (N = 7) and the meter table |

## Convergences

- B1 and integrity 8 (root B1). M1, mechanics 22, and M7 (root M1). M4, mechanics 6, integrity 5
  (root M4). M5 and mechanics 27 (root M5). M8, mechanics 8, integrity 10, with mechanics 11 for the
  cap (root M8). m1 and mechanics 10. m2, mechanics 14, integrity 4. m4 and mechanics 33. m9,
  mechanics 21 and 26. Mechanics 4 and integrity 3 (root integrity 3). Mechanics 5 and integrity 6
  (root mechanics 5). Mechanics 18 and integrity 14 (root mechanics 18).

## Path

| Item | Before | After | Why |
|---|---|---|---|
| T0 | 30 | 30 | toml copied unchanged |
| T1 | 20 | 30 | the shared excerpt entry |
| Pair A | 120 | 160 | D1's broken tests and its bar plumbing (D3 120) |
| M1 | 30 | 35 | the count golden's merge fix |
| W | 200 | 235 | one tuning round counted; D2 135 + D4 80 = 215 beside it |
| M2 | 25 | 25 | |
| E | 130 | 130 | |
| B | 200 | 240 | its whole loop |
| S | 45 | 40 | prose review moved to Close |
| RB | 60 | 60 | |
| K | 40 | 30 | cites B's read, so no read of its own in step 1 |
| Close | 75 | 65 | scoped cairn review |
| Sum | 955 stated, 975 actual | 1080 | |

## Verification applied

From `research/2026-10-20-drafter-blueprint-first-plan-fold-verification.md` (0 blockers, 3 majors,
8 minors). Each was checked against the code before folding.

| Finding | Disposition | Where the revision carries it |
|---|---|---|
| Major 1, D1's bar plumbing is outside its files | Folded. Checked: the bar reaches the pipeline only as rendered text (`Options.Bars map[string]string`, `internal/pipeline/pipeline.go:78`), passed at `cmd/drafter/read.go:158`; `barOf` keeps every blocking finding, consistency's included | D1 files (`bar.go`'s `barOf`, `renderBar`, `applyBar`, `barMaps`; `read.go`'s `Options` literal and `barMaps` construction; `draftscope.go`'s `barMaps` construction; "which D3 owns" dropped for `read.go`); D1 build (`Options.BarFacts map[string][]string`; `renderBar` drops `facttruth` findings only, seatless and consistency render as today); finding 11; D1 bar-read test. D1 at 160 |
| Major 2, `drafter page` checks the map only when `accepted` matches | Folded | Finding 19 rewritten: refusal whenever a map is present and differs, whatever `accepted` holds, plus the missing-map case at a matching accept; D2 build and a stale-accept test; the residual shrinks to a stale accept with no map (plan "Later", conductor's routine row) |
| Major 3, an empty read set is refused forever | Folded. Checked: `read.go:363` (`if c.Facts.Dir == ""`) supports a project with no facts directory | Finding 19 and D2 build: a missing map matches an empty read set, in the refusal and the lapse check; two D2 tests (no facts directory; a blueprint citing nothing); the skip-read tests (`draftscope_test.go:324-344`, `bar_test.go:526-626`) join D2's files with matching maps. D2 at 135 |
| Minor 1, the skill copy in shared `/tmp` | Folded | Names list and RB step 1: the rebuild worktree's own git dir (`rev-parse --absolute-git-dir` plus `/rebuild-skill/`), `rm -rf` before `cp -L`; `git worktree remove` deletes it at RB step 4 |
| Minor 2, merge note misses `prose_sources` | Folded | Merge order 1 and the conductor's note to Geoff |
| Minor 3, `prose_sources` outside `settingKeys` and the fingerprint | Folded | D3 files gain `internal/config/sources.go` (after `facts.bullet_format`, `:17`); D3 at 120; the fingerprint item goes to plan "Later" (`fingerprint.go` is off limits) |
| Minor 4, tuning omits excerpt goldens | Folded | Standing answer 3's file list |
| Minor 5, reserve figure disagrees with the table | Folded | The meter: "M1 step 4's figure; $7 to $12 at planning", and a post-M2 tuning rerun is bound by `left − reserve` |
| Minor 6, W's line ambiguous | Folded | Outcome path line reworded |
| Minor 7, a bar accept's map rests on `FactChanged` | Folded. Checked: `since.go`'s comparison already loads both commits' facts (`bulletChanged` over `old.Facts` and `cur.Facts`), so a `Raw` comparison there is cheap | Finding 11 and D1: the scope gains `RawChanged`, which a bar read adds to its fact-truth set; `FactChanged` is unchanged; one D1 test (a tag-qualifier-only change since the bar) |
| Minor 8, resume reads the working tree | Folded | Run rules: nothing changes in the worktree, committed or not, and no fix subagent works there between a stop and its resume |

Nothing is owed: all eleven are folded. File lists after the change: D1 and D3 share only
`docs/configuration.md`, in separate sections; D1 now holds `read.go`, `draftscope.go`, `bar.go`, and
`since.go` hunks that D2 (and D4 for `read.go`'s `entryJSON`) edit only after M1, in sequence.

## Rulings for Geoff

None. Every finding a reviewer raised as an owner fork has one answer inside the approved design,
named in its row above: contract B1 and integrity 8 (the design's "Later" holds the drafting-pass
condition), contract M1 (an allowlist keeps the live-page rule), contract M3 (the design's own
`wider` definition, with a conditional ask row if the run shows the design-literal count above
zero), mechanics 7 (the design's "nothing else stops" the tidy build), mechanics 8 (the design's
ranking of deliverables), and mechanics 9 (the design's three-rounds-then-ask order). The plan runs
as revised.
