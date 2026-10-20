# Plan review, mechanics and feasibility: drafter blueprint-first

Lens: mechanics and feasibility (`plan-reviewer` agent, Opus at medium). Target:
`docs-system/plans/2026-10-20-drafter-blueprint-first-plan.md` (uncommitted at review), its
executor and conductor prompts, drafter `6a42564`, cairn-cms `origin/main` `52b3f979e`. Saved by the
planning session from the agent's reply.

## What holds up

- Every symbol and line the findings cite exists as quoted (consistency.go:21, checkprompts.go:236-251,
  since.go:270-278, bar.go:120-131, drafted.go:15, pagebp.go:208/212, seed.go:107-108, read.go:474,
  pipeline/blueprint.go:40, docs_test.go:37, blueprint-format.md:304, facts.go:35-50).
- The seed sites in R3 exist in add-cairn at `main`: `s-email-deploy` :2696, `s-email-request` :2705,
  `x-email` :2715, `branding-set`, `f:26kuvx`, `f:ntdafg`, `f:xxtooz`, `f:vpieos`.
- `drafter.local.toml` is ignored at both cairn commits (.gitignore:33), and 517158fae is an ancestor
  of `origin/main`.
- No worktree or branch name collides. `.claude/worktrees` is ignored in all three repos.
- `DRAFTER_PAGE_CAP` is a real env setting (env.go:84). `--sync` and `--resume` exist on `drafter
  read` today. `seatOf` splits on `_`, so the name `facttruth` is safe. The fingerprint hashes every
  `c.Seat` table, so the merge-order note about stopped runs is correct.
- D1 and D3 have no file in common.

## Blockers

None. Every gap below has a fold.

## Major

1. **D1's file list leaves out the existing tests its seat breaks** (correctness; plan:411-419,
   460-480; 120-minute estimate).
   - Defect: `facts.dir` defaults to `blueprints/facts` when that directory exists
     (config/blueprints.go:18-24), so the seat runs in every existing read fixture. Four kinds of test
     break:
     - The pipeline harness fact `lumen-key-ttl` is `[verified]` with `Source: the key policy`
       (testdata/project/docs/facts/keys.md:5). Go gives it `no-excerpt`, which blocks every
       `newBlueprintHarness` read test (about 40 tests).
     - The facts in `cmd/drafter/read_test.go` have no source at all (`f:one` at :703). `readStub`
       answers every Messages call with `{"verdict":"ok",...}` (:378-399), which a facts schema
       rejects.
     - The e2e stub routes answers by schema properties. A `{facts}` schema maps to `unknown` and gets
       HTTP 500 "no canned answer" (e2e/draft_test.go:85-88, 127-145). The `e2e/testdata/cli` tally
       fixture has `blueprints/facts/tally.md` with `main.go` pointers, so the e2e readbar flows fail.
     - `clifixture_test.go:150-151` asserts exactly 2 count requests. D1 lists only the golden, not
       this file.
   - Fold: add to D1's Files `internal/pipeline/testdata/project/docs/facts/keys.md` (re-point
     `lumen-key-ttl` to a new tracked fixture file; the blueprint-read golden carries the claim and
     tag but not the source, so it stays unchanged), `cmd/drafter/read_test.go`,
     `cmd/drafter/clifixture_test.go`, and `e2e/draft_test.go` (a `facts` case in `schemaKind` plus a
     canned answer). Raise D1 to about 150 minutes. All stay outside D3's files.

2. **The count golden goes red at M1, and one D3 test can't be written** (correctness; plan:476-478,
   491-492, 537-538, 545-547).
   - Golden: D1 regenerates `read-dryrun-count.golden.json` with a `facttruth` body carrying today's
     ±5 excerpt of `main.go:12-13`. The fixture `e2e/testdata/cli/main.go` is 50 lines, so D3's
     whole-file rule changes those bytes after the merge. D3 can't regenerate first, because in its
     worktree no read request carries fact excerpts. Both current read goldens contain no
     `=== excerpt:` fact block.
   - D3 test: "the command's blocks are byte-identical to the blocks a dry-run read request carries"
     has no such request until D1 lands.
   - Fold: M1 step 1 regenerates the count golden after the merge, checks only the facttruth body's
     excerpt content moved, and quotes its `git diff --stat` in a merge-fix commit. Move D3's
     byte-identity test to M1 as a session-written test, or point it at `drafter page --dry-run`'s
     draft request, which carries excerpts (assemble.go:164-170). D1's harness tests assert block
     headers, not bodies.

3. **E never re-reads the blueprints R2 accepted, so they never get `facts`** (correctness;
   plan:702-704, 783-792, 794-797). R2 runs on M1's binary; an accept writes `accepted` with no
   `facts`. E's read call names only blocked blueprints plus citers, and a lapse needs a map. Fold:
   E's first read call after M2 names every one of the eight whose entry lacks `facts`, plus the
   blocked ones and the citers.

4. **rotate's bar predates the fact-truth seat, so a bar accept would certify facts no fact-truth read
   saw** (correctness; plan:590-592, 674, 793). rotate's `blocked` is at `fd90da8d8`; by finding 11 a
   bar read's fact-truth set is only touched facts plus the bar's `facttruth` findings, and the old bar
   has none, yet D2 writes the full map on a bar accept. Fold: D2 reads whole when the bar holds no
   finding with a `seat`, or E clears rotate's stale bar once. Add a D2 test row.

5. **Standing answer 3 can't rerun a false-block blueprint at `main`** (correctness; plan:280-288,
   702). R2 commits the lock at once, so a blueprint holding a false block has a bar; a rerun with the
   blueprint unchanged is held by its bar and sends nothing (bar.go:198-202, `ScopeUnchanged` to
   `heldPage`). Fold: keep R2's lock uncommitted (restored, as R1 does) until R2's bar is met, or
   rerun from R2's parent.

6. **`drafter spend --since <that minute>` is a usage error** (correctness; plan:759, 883-884;
   inherited from design :333). `--since` accepts only `YYYY-MM-DD` (spend.go:17, 65-67); rows are
   grouped by repo and seat. Fold: `spend --since 2026-10-20 --json` before and after; "no spend"
   means `total`, `open.count`, and summed `requests` unchanged.

7. **The path sum is 975, not 955, and tuning rounds sit on the critical path** (correctness; plan:5,
   208-228, 299-301, 320-322).
   - 30+20+120+30+200+25+130+200+45+60+40+75 = 975, ratio 1.81.
   - E, B, S, RB, and K wait on standing answer 3's bars, so tuning rounds are on the path; three
     rounds can pass the remaining 105 minutes, then the 1080 ceiling stops the run.
   - B's clock stops at twice 200 = 400 under pass-core "Clock stop", contradicting standing answer 6.
     Which task's clock the session holds during window W is unclear.
   - Fold: fix the figure; count tuning on the path (about 35 minutes each) or trim ceremony (32, 33).
   - **OWNER FORK**, B's clock: (a) a clock estimate that covers its open loop (for example 300); (b)
     keep 200 and accept a possible clock stop; (c) Geoff rules B's overruns continue. Recommend (a).
     State that W's clock is R1-R3 at 200.

8. **The spend plan can pass $45, and nothing says which item yields** (correctness; plan:279,
   340-350). Estimates sum to $32-42 before the contingent $10. **OWNER FORK**: (a) reserve B plus RB
   plus K's share (about $15) and let E escalate a blueprint rather than spend into it; (b) one pool,
   accept a mid-B spend stop; (c) raise the ceiling for the tuning case. Recommend (a).

9. **The likely replay miss is routed to a mid-run question** (correctness; plan:185-190, 280-288,
   683-688). **OWNER FORK**: put R1 step 4's three options to Geoff now. Recommend asking now, with
   scoring only the 13 false or over-claiming bullets as the standing answer if the miss traces to
   omissions only.

10. **M2 step 2's check depends on a state that may not exist** (correctness; plan:757-759). debug
    prints the lapse line only if R2 accepted it and E round 1 didn't touch it. Fold: pick any of the
    eight with `accepted` equal to its blob and no `facts`; if none, cite D2's lapse tests.

11. **A `page_cap` escalation has no standing answer** (correctness; plan:334-335, 787). A
    reservation over `DRAFTER_PAGE_CAP` escalates with rule `cap` before any request (money.go:121-123,
    ledger.go:124-127); one read reserves three seats, about $2-3. Fold: on a `cap` escalation, record
    it, split the call into groups whose `left/N` covers M1's per-page worst case, rerun; `left` below
    one page's worst case is the spend stop.

12. **D4's base relative to D2 is ambiguous** (correctness; plan:565-570, 633). Fold: when D2 returns,
    merge it, run its named tests and `make check`, then dispatch D4 from that head
    (`worktree.baseRef: "head"`).

13. **`make check` rebuilds `BIN` in place** (correctness; plan:249-251, 286, 546-547). `chain-test`
    and `prompts-parity` depend on `build` (Makefile:21-31). Fold: after each commit's `make build`,
    copy the binary to `<git dir>/bin/drafter-<sha>` and run every live command from that path, or run
    no `make check` while a live call runs and record `BIN version` per row.

14. **K step 1.2 is a real `drafter page` run outside the meter** (correctness; plan:880-884,
    903-905). Fold: a meter reading and `DRAFTER_PAGE_CAP=0.01`, so a missed refusal escalates on cap
    before any request.

## Minor

15. D4's no-`[object Object]` proof can't run as written: `check-prompts` takes `--module`,
    `--matrix`, `--expect`, not an outline (checkprompts.go:46-49). Fold: a pipeline-harness dry-run
    read whose outline entry holds one mapping element, asserting `<id>: <text>` and no
    `[object Object]`, both modules through `prompts-parity`.
16. D4 misses `schema/plan.schema.json` (`internal/plan/schema_test.go:89`; plan.schema.json:82
    `required: ["fact", ...]`). Fold: add it.
17. The tuning file list omits `cmd/drafter/testdata/read-dryrun-count.golden.json`. Fold: name it.
18. "Resumes once" has no answer for a second stop. Fold: abandon, record `open.worst`, read fresh
    while the cause is traced.
19. RB's skill copy leaves broken relative symlinks. Fold: `cp -L`; tell the author the `exemplar.md`
    link is absent on purpose.
20. Wrong path in K's example: `MAX_TIDY_CHARS = 24_000` is at
    `src/lib/sveltekit/content-routes-tidy.ts:51`.
21. Stale task name at plan:161: "P2's" should be "R2's".
22. The whole-file rule's scope is ambiguous for prose; the owner brief is 127 lines. Fold: say code
    files only, or prose too, and size the test fixture to match.
23. D1 and D3 each implement "no real excerpt" (optional). Fold: T1 exports the predicate's signature
    as a stub; D3 fills it in.
24. The executor prompt loads the `blueprint` skill from the user-scope symlink, which is the pre-D3
    text. Fold: read the worktree copy by path after M1.
25. B's read command doesn't add citers. Fold: write it with the citer paths and `left/N`.
26. R3 step 4's third commit has no command. Fold: write it out.
27. A blocking lapse read's lock write is unspecified. Fold: D2 states a lapse read writes no bar; K
    restores `blueprints/drafted.lock` before the revert.
28. The merge-order note misses `seat` and `kind` in bar findings, which an older drafter also refuses.
29. `max_tokens` 32000 may be tight (optional). Fold: a standing answer raising it in the local config
    as a traced cause.
30. The gate-string form may be refused in a worktree-isolated session (optional;
    `scripts/drafter-gate.sh:3-4`). Fold: name the no-argument scratch wrapper fallback.
31. Launch prerequisites (optional): the plan, prompts, factsheets, fold, and verification files must
    land on `main` before the conductor's clean-status check.

## Over-ceremony

32. S's `prose-voice-reviewer` read repeats Close step 3's. Fold: one review at Close.
33. K step 1.1's whole re-read repeats B's accepting read (about $1.5, 10 minutes). Fold: cite B's
    accepting run unless a commit has touched tidy since.
34. T0 step 6's `prompts` re-point aims at a chain this pass never edits. Fold: copy the toml
    unchanged.

## Prompt consistency and pre-flight

The prompts and the plan don't contradict each other on stops, models, push targets, or merge order;
they inherit findings 12 and 14 and don't name the binary-identity rule. No Geoff-only step is missing
from the Pre-flight. `drafter read` accepts `--sync`, `--since`, `--resume`, `--dry-run`, and `--json`
today; `--batch` arrives with D2. `--resume` takes no `--since`. The replay worktree's lock restore
works, since `drafted.lock` is the only file the read writes there.
