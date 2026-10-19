# drafter B3c plan: fold verification

Verifier: `claude-opus-5-5`, 2026-10-19, for `spec-plan-review`'s verification step on a
live-account pass. I had no part in the fold. Inputs: the plan at initiatives `5244925` (pre-fold
`68ae25d`), the fold record, the three reviews, the design, and the factsheet. Code was read at
drafter `3c2c5cb` and cairn-cms `11104274e`, both read-only. My probes are under the session
scratchpad's `b3c-verify-probes/`, run on a `git clone --shared` of the fold's probe clone with
B3's installed binary. No API call was made and nothing was committed.

Verdict: no blocker remains. Every blocker and major closed at the location the fold record cites.
The fold added no order that can't build and no contradiction that changes an outcome. It left six
minor correctness gaps and seven optional ones, listed below by consequence.

Count: 0 blocker, 0 major, 13 minor (6 `correctness`, 7 `optional`).

## 1. Blockers and majors, closed where cited

| Finding | Severity | Closed at (plan line) | Holds |
|---|---|---|---|
| Mechanics 1, contract 2, integrity 1 (root A) | blocker | Resolution 6 :485-494; probe loop :557-558; round 1 :572-575; B3c.7 rounds :598-601; B3c.6 acceptance :937-938; B3c.7 acceptance :947-948 | yes |
| Mechanics 2 | blocker | Resolution 5 :451-456 | yes |
| Mechanics 3, integrity 2 (root B) | major | Stall rule :607-622; Close 6 :1001; Merge order 1 :1028-1029 | yes |
| Mechanics 4 | major | Bar paragraph :316-320; B3c.2 row :783-784; B3c.3 row :850-852 | yes |
| Mechanics 5, contract 5 | major | Resolution 4 :395-404; B3c.3 row :842-844; B3c.5 step 4 :897-920 | yes |
| Mechanics 7 (root C) | major | Check 2 :657-659 | yes |
| Contract 1, integrity 6 (root H) | major | Check 3 :667-676; commit first :578-580, :636-637 | yes |
| Contract 4 | major | Finding 10 :119-122; probe dry run :568-570; cap rerun :583-584; wave-2 dry run :630-633 | yes |
| Contract 6 | major | Waves :639-640 | yes |
| Contract 7 | major | Resolution 5 :458-468; B3c.4 acceptance :873-874 | yes |
| Integrity 3 | major | Recovery :514-519 | yes, with gap 5 |
| Integrity 4 | major | Recording :228-241; B3c.2 rows :753-759 | yes |
| Integrity 7 | major | Merge order 2 :1037-1039; gone-commit line :277-280; B3c.2 row :774-775 | yes |
| Mechanics 6, contract 3, integrity 5 | major | Settled, ruling 1 (section 5) | yes |

The record's totals reconcile: 46 folded, 5 settled, 1 refused, and 8 dropped make 60.

## 2. New mechanisms: quoted or proven

| Mechanism | Evidence | Verdict |
|---|---|---|
| Local token-count stub with `DRAFTER_API_BASE_URL` | `config/env.go:13`, `:42` map the variable to `api_base_url`; `batch/client.go:81-106` is the workspace check; `batch/request.go:67-71` sends `System` in the count-tokens body, so the stub sees the agent's system prompt; `pipeline/dry.go` writes "no ledger line, run directory, or state". Fold probe 2's `read.json` is in the scratchpad. Its recorded bodies file isn't kept, so the 187 KB figure can't be rechecked. | proven for `read`. The `page` dry run is proven only up to the render throw (probe 3), which is what B3c.5 tests |
| Page status `held` | `page.go:63-72` `exitCodeFor` maps anything but accepted or unchanged to 1, and `pageExit` covers `drafter page`'s early return (`page.go:145-162`) | quoted. `drafter read`'s early return skips it (gap 7) |
| `ReadScope` | `pipeline.go:237` (`Scope: p.w.Scope`), `read.go:360-362` (`scopedAccept`), `pagebp.go:211-214` | quoted |
| The bar paragraph overriding the Nit rule | `stock/prompts.js:163-171` and the chain at `:2364-2372`, word for word | quoted |
| Cap-stop rerun at batch price | `ledger.go:125` checks `page + r.Worst > c.Page`. `pageTotal` is keyed by run and page (`ledger/store.go:77-91`), so a fresh run starts at zero; the fold didn't cite this, but it backs "a new run". `money.go` escalates `ErrPageCap` as `cap`; `dry.go` prices worst case by `batchMode()` | quoted |
| `$B3C_DRAFTER` everywhere after B3c.5 | Fold probe 1, reproduced: with `brief_path` appended, installed `drafter check <rotate>` prints `drafter.toml:74: unknown key blueprints.brief_path`, exit 2; restored, `0 errors, 5 warnings`, exit 0. `drafter check` still works in a worktree without `drafter.local.toml` (probed), so fix and reshape worktrees need no local layer. `drafter check` takes no worktree lock (`git grep TryLock`), so concurrent round fixes don't collide. cairn's gate and index-link commands never call `drafter`. | proven. Gaps 3 and 4 cover two leftover forms |
| Merge-commit rule | `gh api repos/glw907/cairn-cms` shows `allow_merge_commit`, `allow_squash_merge`, and `allow_rebase_merge` all true; `main` has no branch protection (404), so no linear-history rule blocks a merge commit | proven |
| Stall rule's double cancel | `batch/classify.go:11` (`ActionResubmitThenStop`) and `pipeline/handle.go:147-150` (a second cancel halts with `StopInfrastructure`) | quoted |
| Id comparison | Fold probe 4. `yq` v4.54.1 is installed | proven |

## 3. Path arithmetic

From the task headings: B3c.0 30 (:680), B3c.1 40 (:706), pair A max(215 :730, 175 :808, 125
:858) = 215, B3c.5 50 (:877), B3c.6 115 (:925), B3c.7 90 (:940), B3c.8 90 (:951), B3c.9 100 (:962),
Close 65 (:970).

30 + 40 + 215 + 50 + 115 + 90 + 90 + 100 + 65 = **795**, against the 800 ceiling. That's 1.99x the
design's 400. The header (:5), Outcome (:147, :161), and the fold record (:233) agree. B3c.4 is
the session's shadow work inside pair A, and 125 is under 215, so it stays off the path. Gap 9
covers whether the B3c.6 figure holds.

## 4. The three planning-session rulings

1. **claude-code's partial gate coverage, reported.** Finding 3 (:63-70), Check 2 (:664-665),
   Close 6's table column (:1007-1008), and Close 6's note (:1014) agree. The "if the gate refuses
   ... escalates" premise is gone everywhere. I checked cairn's arm lists at `11104274e`: none of
   `check-leaks.mjs:473`, `check-snippets.mjs:60`, `check-symbols.mjs:66-68`,
   `check-visuals.mjs:35-37`, `check-arm-indexes.mjs:39-41`, or `arm-state.mjs:28` names
   `docs/claude-code`. Consistent.
2. **The three-page floor, reported.** Check 2 (:665-666) and Close 6 (:1009) report it, and no
   line makes it a stop. Consistent.
3. **The `left/7` cap, refused.** Finding 8 (:104-106) and resolution 7 (:529) keep `min(10, left /
   N)`, and no line brings in a per-wave share. Consistent.

## 5. Gaps, ranked by consequence

1. **Minor, `correctness`.** Plan :918-920 (and :559-560).
   - Defect: rotate's later bar check is to run "the same way" as B3c.5 step 4. The executor can
     read that phrase to include that step's lock edit, which sets every entry to `accepted: <its
     blob>`. On rotate that edit drops `blocked`, so the dry run isn't a bar read. "Still open"
     then never appears, and the session would diagnose a mechanical fault ("a prompt missing the
     findings", :564-566) and spend a drafter fix cycle on a bug that doesn't exist.
   - Fold: "make a fresh shared clone of the head, with no lock edit, copy in the local layer, and
     point it at the stub."
2. **Minor, `correctness`.** Plan :693-701 (B3c.0 step 5) and :848-850 (B3c.3's regression row).
   - Defect: B3c.0 must render the blueprint seat through the Node script, which takes a matrix.
     But the context comes from `readProject`'s Go handoff (`read_test.go:191-213`), and B3c.0's
     file list commits no input matrix. B3c.3's agent, which starts with no context, then builds
     its own `blueprint-matrix.json` and has to match contexts it can't see. The regression row
     either fails on the input, or the agent regenerates the golden, which makes the check
     vacuous.
   - Fold: B3c.0 also commits the matrix it rendered from
     (`tests/fixtures/drafter/blueprint-seat-baseline.matrix.json`). B3c.3's row renders that same
     file against the edited chain and compares the output with the golden.
3. **Minor, `correctness`.** Plan :880 ("Set `$B3C_DRAFTER`") against :481 and :490.
   - Defect: shell state doesn't persist between the session's Bash calls, and a subagent starts
     with an empty environment. A literal `$B3C_DRAFTER check` in a command or a prompt expands to
     `check`.
   - Fold: B3c.5 records the absolute path in STATUS, and every command and fix prompt writes it
     out literally. `$B3C_DRAFTER` stays a name in the plan, not a variable.
4. **Minor, `correctness`.** Plan :523-527 (resolution 7).
   - Defect: the meter is "read fresh from the same command", meaning B3c.0's `drafter spend`.
     `drafter spend` loads the project config (`spend.go:82`). I probed it with `brief_path`
     appended in a cairn clone: the installed binary prints the unknown-key error and exits
     nonzero. Every drafter command for cairn runs from the cairn worktree (:503), so the first
     meter read after B3c.5 fails. It fails loudly, so the money stays safe.
   - Fold: "`$B3C_DRAFTER spend --since 2026-10-19 --json`" in the bullet. Both binaries read the
     same user-layer state directory.
5. **Minor, `correctness`.** Plan :514-519 (Recovery) against :615-616 (stall step 2).
   - Defect: Recovery resumes any STATUS row with no "after" cell. The stall rule marks a run
     "abandoned" but never fills its "after" cell. After a compaction, a fresh session would resume
     the abandoned run, which spends again beside its own `--sync` rerun.
   - Fold: stall step 2 writes the "after" cell as "abandoned (stall rule)", and Recovery skips
     those rows.
6. **Minor, `correctness`.** Plan :667-668.
   - Defect: Check 3 says "Run after each accepted page's commit" and then "Each accepted page's
     entry at the close head matches". After a wave commit, `HEAD` isn't the close head.
   - Fold: "at `HEAD`, after each accepted page's commit and again at close (Close 3)".
7. **Minor, `optional`.** Plan :274-276 and B3c.2's row at :772-773.
   - Defect: `drafter read`'s early return when no page is left to read (`read.go:131-142`)
     prints the summary and returns nil without calling `exitCodeFor`. A read whose only page is
     `held` therefore exits 0. The row catches this, but the resolution reads as though
     `exitCodeFor` already covers it.
   - Fold: name the early return in resolution 1.
8. **Minor, `optional`.** Plan :937-938 against :595-596.
   - Defect: merging and removing the round-1 branches appears both in B3c.6's acceptance and as
     B3c.7's first step.
   - Fold: keep it in one place, B3c.7's step, and have B3c.6's acceptance say "every round-1
     branch committed and left unmerged".
9. **Minor, `optional`.** Fold record :227 and plan :156.
   - Defect: B3c.6 drops from 120 to 115 for "no per-page gate rerun", but the fold also added
     two steps to it: the real-key probe dry run (:568-570) and the clone-and-stub bar check on
     rotate (:918-920). With 5 minutes of slack, the path sits at the ceiling in practice.
   - Fold: no plan change. The PR's score already names any overrun (:166-167).
10. **Minor, `optional`.** Plan :609-614.
    - Defect: the stall rule says to cancel "through the API", but it doesn't say where the batch
      id lives. It's the `batch_id` on the run state's intents (`internal/run/state.go:77`).
    - Fold: name that field and the batch cancel endpoint, called with the key from the
      environment and never printed.
11. **Minor, `optional`.** Plan :583-584 against :619.
    - Defect: a stalled cap rerun (batch) falls under the stall rule's `--sync` rerun, which
      brings back the full-price worst case that made the cap trip.
    - Fold: "a stalled cap rerun stops the line".
12. **Minor, `optional`.** Plan :206.
    - Defect: the tools check leaves out `yq`, which resolution 5's id comparison needs.
    - Fold: add `yq --version` (4.x).
13. **Minor, `optional`.** Plan :83 and :938.
    - Defect: two lines the fold edited run past the wrap width.
    - Fold: rewrap them.

## Probes

All under `b3c-verify-probes/`, on a shared clone of `b3c-fold-probes/cairn`, with B3's installed
binary:

- With `[blueprints] brief_path` appended, `drafter check <rotate>` printed `drafter.toml:74:
  unknown key blueprints.brief_path`, exit 2. Restored, it printed `0 errors, 5 warnings`, exit 0.
- `drafter spend --since 2026-10-19 --json` exited 0 on the clean config and failed with the same
  unknown-key error once `brief_path` was appended.
- With `drafter.local.toml` removed, `drafter check <rotate>` still printed `0 errors, 5
  warnings`, exit 0.
- `gh api repos/glw907/cairn-cms` showed merge commits allowed, and `main` reported no branch
  protection.
