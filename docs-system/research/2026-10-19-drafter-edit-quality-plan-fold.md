# Fold record: drafter edit-quality plan

Target: `plans/2026-10-19-drafter-edit-quality-plan.md`, revised in place, against
`specs/2026-10-19-drafter-edit-quality-design.md`. Reviews: `research/2026-10-19-drafter-edit-quality-review-mechanics.md`
(M), `-review-contract.md` (C), `-review-integrity.md` (I). Code read at drafter `41939c3`, cairn
`50dc211d9`; probes in a scratch directory. Fold agent, 2026-10-18.

The planning session ruled every fork the reviewers raised as a method call; those rulings are
applied below and recorded as departures 9 to 13 in the plan. No owner fork remains, and nothing
here changes the approved design beyond what the design pre-authorizes or the planning session
ruled.

## Checks before the fold

Each finding was checked against source before acting. The load-bearing checks:

- `blueprintPrompt` ends its change paragraph with `These sections changed: ${scope}.`
  (`docs-page-chain.js:2351`); `Build` joins note, prompt, inlined files, then `Extra`
  (`assemble.go:80-100`); `BlueprintBlock` lists `placedFacts(view)` (`assemble/blueprint.go:23`).
- `completeBlueprintRead` escalates only on `a.Verdict == "fix"`, so "ok" with a blocking finding
  accepts (`pipeline/blueprint.go:236-245`).
- `checkPosition` requires `HEAD` to be the recorded head or a descendant (`resume.go:95-110`).
- `saveRequest` marshals `batch.Request`, not the wire (`money.go:169-181`); `batch.Message` has
  `Role` and `Text` only (`types.go:40-43`).
- `Worst` prices `InputTokens` only (`price.go:49-52`); stock Opus 5.5 `input = 4.0`,
  `cache_write_5m = 5.0`, `cache_write_1h = 8.0`.
- `DRAFTER_CYCLE_CEILING` and `DRAFTER_PAGE_CAP` are env keys (`config/env.go`, `envName`);
  `Reserve` refuses past the cycle ceiling with `ErrCycleCap` (`ledger.go:129`).
- `~/.local/secrets` exports both `ANTHROPIC_API_KEY` and `DRAFTER_API_KEY` (names only); #49's
  22 streams each carry `"apiKeySource":"none"` (corrected by the verification read); `config.toml` sets `key_env`, no `key_command`.
- At cairn `50dc211d9`, `bb-lead` and `push-lead` are `mode: claim` with no `facts`;
  `x-logs-empty` is handled by `rec-logs-observability`, a `fact` item.
- `slugOf` and the slugger are unexported (`plan/slug.go`); a section's `anchor` field exists.
- drafter's lock is `syscall.Flock` on `<gitdir>/drafter.lock` (`run/lock.go:26`, `start.go:109`).
- `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=remote.origin.pushurl GIT_CONFIG_VALUE_0=/dev/null/no-push`
  makes `git push` exit 128 on git 2.56 (scratch-repo probe); a plain push succeeds.
- Cache mechanics quoted from the Claude API skill's `shared/prompt-caching.md`: "The cache key is
  derived from the exact bytes of the rendered prompt up to each `cache_control` breakpoint"; "Max
  **4** `cache_control` breakpoints per request"; 512-token minimum on Opus 5.5; "Cache writes cost
  **1.25× for 5-minute TTL, 2× for 1-hour TTL**".
- `t2b.patch`, `t4c.patch`, `t5a.patch` exist in skill-rules' harness.

## Dispositions

### Mechanics

| # | Disposition | Where |
|---|---|---|
| M1 | Folded. Scope sentence leaves the prompt (EQ.4) and opens the change block (EQ.5); two breakpoints, after the register and after the facts. | Departure 3, EQ.4, EQ.5 |
| M2 | Folded, at the root with C3 and I16. Forced back-to-back read pair on `ref6`; ledger `cache_write_5m` then `cache_read` above 0; a zero stops the line. Cached parts are an exported field, so the saved request carries them. | EQ.7 step 4, EQ.5 files |
| M3 | Folded. Outcome table in the skill's Read section; the harness grades by the same exits. | EQ.1 |
| M4 | Folded with C9 and C15. Fix list adds every kept `handler` hit (`x-logs-empty` named); `cited` drops per the planning session's ruling, confirmed in EQ.0. | Departure 9, EQ.0, EQ.2, EQ.6 |
| M5 | Folded with I5: test rows named, `docs/setup.md:90-91` added, `Worst`'s doc comment scoped to 5-minute writes, a batch test pins no `ttl`, packet disclosure. Refused in part: "highest of input and both write rates" would double the input reservation for a TTL drafter never emits; the no-`ttl` test guards it, and Later records the 1-hour case. `docs/configuration.md:309` and `README.md:149` refused: neither states the input price, so neither goes stale. | Departure 3, EQ.5, Later |
| M6 | Folded per ruling: departures are method calls. | Departures header |
| M7 | Folded. Anchor is the `anchor` field, else the heading slug; `internal/plan/slug.go` gains an exported function. | EQ.2 |
| M8 | Folded. `cmd/drafter/check.go`'s `Long` gains the `handler` clause. | EQ.2 files |
| M9 | Folded with C10. Minutes waiting and judge agreement defined. | EQ.8 |
| M10 | Folded with I4. Fresh env file per session; `drafter config` key-source check at launch. | Harness, Depends on |
| M11 | Dropped, optional. The mechanisms this fold added are quoted above. | |
| M12 | Dropped, optional; the line-count criterion is replaced anyway by C4's grep. | |

### Contract and criteria

| # | Disposition | Where |
|---|---|---|
| C1 | Folded. A read counts only when `--since` resolves to `<base''>`; checked from the stream; probe asserts it; skill pins every read to the noted base. | Harness `tweak.sh`, EQ.1, EQ.7 step 2, EQ.8 |
| C2 | Folded. Replays of `t4c`, `t5a`, `t2b` on `<base''>`, outside the bars, reported (about $1.40). | EQ.7 step 5, Depends on |
| C3 | Folded at M2's root. | EQ.7 step 4 |
| C4 | Folded. Precedence sentence in the change paragraph, with a `want`; "Check what you add"'s intro rewritten, old clause grepped gone. | EQ.4, EQ.1 |
| C5 | Folded. Part a: p4 graded mechanically, decline shape defined. Part b ruled (c): other declines are misses except a p5 decline naming `x-editor`. | Departure 11, EQ.8 |
| C6 | Folded per ruling (a): a failed positive control fails the Controls row; bars fixed; inherited rules restated in full. | Departures 7 and 12, EQ.7 |
| C7 | Folded in part: `grade.py` counts verdict-and-flag disagreements and Nits flagged blocking. Refused in part: the code change treating "fix" as "ok" was tagged optional and would widen `pipeline/blueprint.go` past EQ.5's scope; the count makes any such miss visible. | Harness `grade.py`, EQ.8 |
| C8 | Folded with I9. Per-read evidence: saved request carries the cached parts and the Nit sentence, `drafter_version` recorded; binary and chain pinned as copies. | Harness |
| C9 | Folded at M4's root: `handler` must fire on `x-third-verify` and `x-check-threw`; other hits classified. | EQ.2 |
| C10 | Folded with M9 and I12: fewer than three reports the count; same location is section id and item id; falsifier reading stated; `refs/ft/<NAME>` keeps commits reachable. | EQ.8, Harness, departure 13 |
| C11 | Folded. Loop breaches listed. | EQ.8 |
| C12 | Folded into the breach list (the trailing empty commit's message). | EQ.8 |
| C13 | Folded. Register-rule finding count, expected 0, reported. | EQ.8 |
| C14 | Folded with I11. Reads attributed by `state.json` project, branch, and head. | Harness |
| C15 | Folded in part: premise greps in `<job>/premises.sh`. The `cited` half is moot, since `cited` drops. | EQ.6 |
| C16 | Dropped, optional. (The no-key row's grep and EQ.2's message assertion landed anyway as part of M10 and the EQ.2 rows.) | |
| C17 | Dropped, optional; superseded by C4's grep. | |

### Data integrity and failure risk

| # | Disposition | Where |
|---|---|---|
| I1 | Folded. Empty commit replaces the amend; exit 3 resumes once as the same read. | Departure 1, EQ.1 |
| I2 | Folded. `flock` wait after the session; timeout marks infra; orphans resumed at their head; dispatch gated on `open.count` 0. | Harness, standing answer 4 |
| I3 | Folded per ruling. `DRAFTER_CYCLE_CEILING=<B+40>` and `DRAFTER_PAGE_CAP=2` through the wrapper replace the hand arithmetic. `--max-budget-usd` not used: sessions run on the subscription. | Standing answer 4, Harness |
| I4 | Folded; fork ruled (b). API spend only; `env -u ANTHROPIC_API_KEY`; `apiKeySource` asserted per stream; key set by `eval` of the one line, never stored. | Standing answer 4, Harness |
| I5 | Folded at M5's root; packet discloses the pricing change; risk class unchanged per ruling. | Departure 3 |
| I6 | Folded. Round halts when any main checkout's status changes. | Harness |
| I7 | Folded per ruling (b). The skill reports open findings to the user; no nightly claim until B4. | Departure 10, EQ.1, Later |
| I8 | Folded. The wrapper carries prompt and caps in either route. | Harness |
| I9 | Folded with C8. Copies in `<job>/bin`, sha256 recorded. | Harness, EQ.7, EQ.8 |
| I10 | Folded. `restore.sh` written before the first swap, named in STATUS; agents check before each round. | Harness |
| I11 | Folded at C14's root. | Harness |
| I12 | Folded. Per-run format-patches, recorded read heads, `agree.sh` resets by recorded head, reruns under `<NAME>-r`. | Harness, departure 7 |
| I13 | Folded. Record before any reset; reset by recorded SHA. | Harness |
| I14 | Folded. Launch gate on `HEAD` and a clean tree. | Harness |
| I15 | Folded. Push blocked by `GIT_CONFIG_*` in the env file (probed); main-checkout changes halt via I6. | Harness |
| I16 | Folded at M2's root. | EQ.7 step 4 |
| I17 | Dropped, optional. | |
| I18 | Folded. EQ.8 stops its clock before removing the worktree. | Shape, EQ.8 |
| I19 | Folded, reclassified as correctness: merge row 2 would write a workstation path into cairn's backlog. The patch goes to the initiatives repo's `docs-system/research/` and the backlog points there by repo path. | Close, merge row 2 |

## Counts

48 findings (12 mechanics, 17 contract, 19 integrity).

| Disposition | Count |
|---|---|
| Folded in full | 40 (C3, I16, I5, I11, and C9 at another finding's root; I19 reclassified from optional) |
| Folded in part, part refused | 3 (M5, C7, C15) |
| Refused outright | 0 |
| Dropped, optional | 5 (M11, M12, C16, C17, I17) |
| Owner forks | 0 (four forks ruled by the planning session as method calls) |

## Path and spend

- After the verification fold (below): path 355 minutes, task sum 515, 5 minutes of slack.
- Before it: path 350 minutes (was 295), inside the standing 360 with 10 minutes of slack. EQ.0 +15 (harness
  hardening), pair A's leg +10 (EQ.5's second breakpoint and scope move; EQ.2 −5 with `cited`
  dropped), pair B's leg +5 (EQ.4's precedence and scope edits; EQ.6 +10 for the added handler
  hits), EQ.7 +15 (cache pair, replays), EQ.8 +10 (orphan handling and the added grading). Task sum
  505.
- Spend, API only: EQ.7 about $7 (row 0's whole reads, two probes, the cache pair, three replays,
  three controls); EQ.8 about $15 expected at the planned per-read figure near $0.45 (at most
  about $31 if all 21 runs read three times, plus agreement and control 2). About $22 expected
  against $40; drafter's cycle ceiling refuses anything past it.

## Owed

- The design's outcome 1 says "the nightly read is the backstop". The plan departs from that
  sentence (departure 10) by the planning session's ruling; the design isn't edited. The packet
  names it.

## Verification read and its fold

The verification read (`research/2026-10-19-drafter-edit-quality-plan-fold-verification.md`, a
fresh agent with no part in the fold) found 0 blockers, 3 majors, and 12 minors. The fold agent
applied the majors as proposed and the correctness minors 4 to 11. The optional minors 12 to 15
are owed.

| # | Disposition | Where |
|---|---|---|
| V1 | Folded. The resume command is `drafter read --sync --resume <run-id> <blueprint>` in the skill's table and `<job>/bin/drafter read --sync --json --resume <run-id> <BP>` in standing answer 4 and the orphan step (`read.go:62-63` needs a blueprint; `resume.go:213-214` refuses a changed `mode`). EQ.3 fixes `ResumeLine` in `pipeline.go` (outside the frozen files) with a `cmd` row; EQ.1's acceptance checks the row. | Standing answer 4, Harness, EQ.1, EQ.3 |
| V2 | Folded. The scope sentence opens the change block, after `=== end outline entry ===`; EQ.5's outcome and pipeline acceptance now say so. | EQ.5 |
| V3 | Folded. EQ.4 asserts the `page` and `intro,steps` renders are byte-identical and flips the `pageOnly` check; EQ.5 adds `internal/pipeline/testdata/module.js`, moves the two tests' scope-line checks to the change block, and says its byte-identity row proves the assembler only. | EQ.4, EQ.5 |
| V4 | Folded. The cache pair reads the `blueprint` seat's settle line; first read passes on `cache_write_5m + cache_read > 0`, second on `cache_read > 0`. | EQ.7 step 4 |
| V5 | Folded. A non-literal `--since` is checked by the saved request's diff block against `git diff <base''> <head>`. | Harness |
| V6 | Folded, the stop option: the fallback route is removed; a failed re-probe stops for Geoff. EQ.0 drops 5 minutes with it. | Harness, EQ.7 step 2 |
| V7 | Folded. Orphan runs come from the ledger's unsettled reserve lines by `run_id`. | Harness |
| V8 | Folded. The prompts module's `inputs` hash replaces `drafter_version`. | Harness |
| V9 | Folded. Each premise grep is shown to bite before the first fix. | EQ.6 |
| V10 | Folded. Case 2 names the handler as a step or handoff that gives a next action and cites the fact, by link to the `handler` row; the "with a `link`" clause is dropped from the skill. | EQ.1 |
| V11 | Folded. 22 streams; `x-editor` is "the item". | Standing answer 4, departure 11, this record |
| V12 | Owed, optional: the cycle-cap row's "commit" wording (the tree is already committed). | |
| V13 | Owed, optional: `page_cap` 2 against a resume after both seats' sends were lost; such a resume escalates on `cap`, a Geoff stop. Accepted as is. | |
| V14 | Owed, optional: the push guard misses a push to a direct URL; the post-check `ls-remote` covers it. The packet notes the gap. | |
| V15 | Folded in effect by the `CLAUDE_ENV_FILE` citation added under Harness (read once per session). | Harness |

Path after these folds: EQ.0 30 (−5, no fallback), pair A 65 (EQ.5 +5 for the module and the
moved checks), pair B 45 (EQ.3 +5 for `ResumeLine`, EQ.6 +5 for the bite checks), EQ.7 65, EQ.8
120, Close 30: 355 minutes, task sum 515. Spend projection unchanged: about $22 of API spend
expected against $40.
