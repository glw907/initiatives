# drafter acceptance plan: cairn's seven pages

Initiative: docs-system

Path estimate: 605 minutes against the design's 400 (1.51x), inside the 800-minute standing answer.
The arithmetic is under "Outcome".

Design: `~/Projects/initiatives/docs-system/specs/2026-10-19-drafter-acceptance-design.md`, approved
by Geoff on 2026-10-19 (glw907/initiatives#59). He ruled both asks as recommended:

- **The bar and the budget.** Five of seven pages accepted, at a $50 live-spend ceiling, with the
  existing $10 page cap.
- **The fact-check findings.** Every finding in the evidence record is fixed at its source before
  the rerun.

The B3 rulings carry over: `internal/pipeline/money.go` and `internal/pipeline/fingerprint.go` are
never edited, and an edit to `internal/pipeline/resume.go` is written test-first, with a task-scope
`diff-reviewer` read, auth-data bar included, on each commit touching it before the next task
starts. No `resume.go` edit is expected (finding 9).

Evidence: `docs-system/research/2026-10-19-drafter-b3c-draft-review.md` (the read and the
fact-check; "The findings, page by page" is the edit list). Factsheets, read-only, written by the
planning session at drafter `6b110ad` and cairn-cms `517158fae`:
`docs-system/research/2026-10-19-drafter-acceptance-factsheet-pipeline.md` (drafter's pipeline),
`…-factsheet-prompts.md` (the two prompts modules and the answer schema), and
`…-factsheet-cairn.md` (cairn's checks, the 31 findings mapped to their sources, the lock, the
config, the gate). Lines move; the executor finds each quoted symbol by name.

B3c's record is the run's shape: glw907/drafter#55, glw907/cairn-cms#132, and its plan
`docs-system/plans/2026-10-19-drafter-b3c-cairn-pilot-plan.md` (resolutions 6 to 9 hold here where
this plan doesn't restate them: the binary rule, the tree rule, the recovery rule, and the stall
rule).

## Pre-flight

Nothing for Geoff. The conductor checks each item before launch:

- The docs-layout sweep's PRs are merged: `gh pr view 54 -R glw907/drafter --json state` and
  `gh pr view 131 -R glw907/cairn-cms --json state` both print `MERGED` (true at planning,
  2026-10-20 04:40 UTC).
- `~/.config/drafter/cairn-cms.local.toml` and `~/.local/share/cairn/exemplars` exist.
- `DRAFTER_API_KEY` is set in the launching environment (checked by name, never printed).
- `go`, `node`, `vale`, `yq`, `cairn-run-gate`, `ci-green`, `cairn-docs-outline`, and `tellgrader`
  resolve. `drafter config` in `~/Projects/cairn-cms` prints `page_cap = 10` and
  `cycle_ceiling = 160` from the user layer.

All of these held at planning time.

## Findings for the planning session

None changes the approved design. Each is decided here; the ones marked "contestable" are method
calls a reviewer may want to argue.

1. **#25 lands before the scoped reads.** The design orders the work "items 1 and 2, then 4, then
   3, 5, and 6, then 7", but item 4's reads rely on item 6's #25: "`drafter read --since <pre-fix
   commit>`, which advances the lock on an accept (#25)". Today a scoped accept writes nothing
   (`recordReads`, `cmd/drafter/bar.go:74-100`, falls to `default`), so a read run on today's
   binary would leave every lock entry stale. The drafter work therefore runs first, beside the
   cairn edits, and the reads run on the built binary. The outcome and every item are unchanged;
   only the sequence moves, and the drafter work leaves the critical path's cairn chain alone.
2. **"It accepts if they pass" means the stop clears (contestable).** The design: after the small
   fix, "the deterministic checks run again (the gate and the coverage check, no review seat), and
   it accepts if they pass". Read as "the page reaches `accepted`" at the round-2 point, the page
   would skip the final reader, so a page with small findings would get less review than a clean
   page, whose round-2 ok goes to the reader (`steps.go:597`). The plan reads it as the escalation
   point passing: the page then goes where an ok verdict at that point goes. At the round-2 verdict
   that is the final reader (`stReader1`); at the coverage check's second miss it is round 2
   (`stRound2`, `steps.go:351-352`). No seat re-reads the small fix itself.
3. **The kind travels in the answer schema, not in the prompts modules (contestable).** Every read
   seat of both modules gets one Go-side schema and one contract sentence per answer
   (`internal/assemble/schema.go:19-20,80-95`), sent as structured output with
   `additionalProperties: false` (`internal/batch/request.go:44-50`). A required `kind` enum on a
   review finding, with its definitions in the contract sentence, makes every review seat of
   `stock/prompts.js` and of the chain label its findings, and neither module's rendered prompt
   changes. That keeps the chain's handoff mode byte-identical with no work, keeps the stock
   module's "register" and slash bans out of play (`stock/stock_test.go:315,328`), and keeps the
   chain's own Workflow path untouched (its `FINDING` schema, `docs-page-chain.js:515-524`, is a
   separate object). The blueprint read shares `AnswerRead` today (`blueprint.go:160`) and its
   request bytes are pinned by two goldens meant never to move
   (`internal/pipeline/testdata/blueprint-read-request.golden.json`,
   `cmd/drafter/testdata/read-dryrun-count.golden.json`), so the blueprint read moves to an answer
   value of its own that renders today's schema and contract exactly. The alternative, a
   kind-list sentence in each module's review prompts, touches two modules, about ten goldens, and
   the stock bans, for the same label.
4. **The kind vocabulary is closed.** Review findings take one of `link`, `handoff`, `heading`,
   `citation` (the small kinds, the design's "a link, a handoff, a heading, or a brief citation"),
   or `fact`, `claim`, `code`, `voice`, `step`, `placement`, `other` (the design's "a fact, a claim,
   a code sample, a register or voice finding, a missing step, misplaced content", and a catch-all
   that escalates). `voice` stands for register so the word stays out of request text. A finding
   with an empty or unknown kind, such as one in a state saved before this pass, is not small.
   Coverage misses carry their own kind (`internal/coverage/check.go:14-19`) and map this way:
   - small: `link` ("no link to <target> in this section"); `handoff` from the coverage read; `brief`
     ("brief sentence not found on the page") and `fact` ("no brief sentence in this section cites
     fact <id>"), which are both brief citations;
   - not small: any miss whose reason is "heading not found" (the section itself is missing),
     `verbatim`, `reason`, and `claim`.

   The `fact` coverage miss as a citation is contestable: it is security-model's B3c ending, and the
   gate's provenance check and the coverage recheck still guard the brief after the fix.
5. **The rule weighs every round-2 seat.** `afterRound2` escalates on the first seat that answers
   fix and never looks at the rest (`steps.go:581-599`). The small path needs every blocking finding
   of every round-2 seat that answered fix to be small, so the new code reads all of them before it
   decides. Non-blocking findings ("Nit:", "Already present:") never count.
6. **#23's cause is traced, and it has two halves.** In B3c's wave 2 (run
   `20261019T233356Z-01abf04b`), gate run 4 of security-model and of add-a-second-sign-in-group
   failed only `check:symbols`, on the line `docs/extend/add-cairn-to-a-sveltekit-app.md:297
   [file-path]  lib/cairn.config.js` (add-cairn is a sibling in that run). No line in either log
   matches cairn's `failure_pattern` (`drafter.toml`; probed with the pattern over each saved
   `gate-*.log`, 0 matches in both gate-4 logs), so `parse` marks the log unparsed
   (`internal/gate/run.go:223-226`), and an unparsed red is always the page's own
   (`run.go:240-241`, `TestUnparsedIsOwn`). Each page spent a fix round on a sibling's line. The
   fixes: cairn's `failure_pattern` gains the `check-symbols` defect line's shape (cairn task C1),
   and drafter holds a page whose unparsed red names a sibling page of the run and neither this
   page nor its brief (task A1). #15's fix also removes that particular line.
7. **The snippet inputs are a Go change.** A `code` item's `source` is relative to the page
   (`../../claude/snippets/check.yml`), travels only inside the blueprint block in `Extra`, which is
   never scanned for paths (`assemble.go:52-58`), and neither module's draft prompt names it
   (`stock/prompts.js:273`, chain `:2572`). So drafter resolves each `code` item's `source` against
   the page's directory, as `plan/check.go:264-269` does, drops a `#Symbol` suffix, and adds the
   file through the existing `fileBlock` (tracked files only, 256 KiB limit,
   `internal/assemble/files.go:18,221-236`) to the draft seat's `Extra` in `draftingBlocks`
   (`internal/pipeline/blueprint.go:402-423`). An `http(s)` source is skipped. Every draft-seat
   conversation's first turn carries the blocks, the redraft exchanges included, since `build`
   attaches `draftingBlocks` to a conversation's first turn (`steps.go:109-120`) and the redraft
   exchange starts with no history (`steps.go:520`). The claude-code page's `c-script` and
   `c-ci-workflow` are the fixture's shape.
8. **#16's class is wider than three facts.** `wrap` is a function expression returned at
   `section-action.ts:180`, and drafter's excerpt resolver matches only a line-start declaration of
   the name after the last dot (`internal/assemble/excerpt.go:86-92,127-128`), so the excerpt
   reads "declaration not found" and the fact seat blocks. 158 dotted anchors in cairn's facts
   store fail the same rule, among them facts the seven cite (`f:ubuj1w`, `f:keuj8l`, `f:t976f1`,
   `f:cvv6to`, `f:21by9u`). The plan re-anchors the three #16 facts to line ranges, as the design
   says, and also any other fact a page of the seven cites whose excerpt the real-context render
   check (task A3) shows as "declaration not found". The same failure ended debug-your-site, and the
   fix changes a pointer, never a claim. The other anchors and drafter's resolver go to the
   backlogs (Close).
9. **No `resume.go` edit.** `resume.go` has no switch on step names or exchange kinds; it replays a
   pending gate through `coveragePhase` (`resume.go:349-358`). The new exchange kind joins
   `coveragePhase`, `exchangeStep`, `exchangeStage`, `coverageStage`, `bound`, `advance`,
   `stepSeats`, `validate`, and `complete`, each of whose `default` silently falls to the draft
   gate-fix path (factsheet-pipeline, section 5), so a missed switch shows only in a test.
10. **#26 changes a fingerprinted value.** `fingerprint.go:40` hashes `seat.<name>.max_tokens`, so a
    run started under the stock 64000 refuses to resume after the default moves. cairn sets its own
    128000 (`drafter.toml`), so cairn's runs are unaffected; the merge order checks for stopped runs.
11. **31 findings, not 30.** The record's list holds 31 (scaffolded-site-files lists five imprecise
    against its table's four). All 31 are fixed. Seven of the record's code-line citations are off
    by a few lines; factsheet-cairn section 5 gives the right lines, and each fix cites the line the
    code holds.
12. **Wrong claims outside the seven are filed.** `docs/reference/log-events.md:74` carries debug
    #1's lapse claim word for word, and `docs/extend/upgrade-cairn.md:101` and
    `docs/reference/sveltekit.md:2100` assume `.dev.vars.example` ships. The rerun doesn't redraft
    them, and they are hand-written pages outside the design, so they go to cairn's backlog with the
    `admin-action.ts:155-157` doc comment, as the design's "Later" does for that comment.
13. **The local layer points at the worktree's chain.** The copied `drafter.local.toml` keeps every
    key of `~/.config/drafter/cairn-cms.local.toml` and sets `prompts` to the drafter worktree's
    `claude/.claude/workflows/docs-page-chain.js` by absolute path, as B3c did. The pass doesn't
    plan to edit the chain (finding 3), but the runs then use the branch's chain whatever lands, and
    a mid-run change to the main checkout can't reach them.
14. **The run order by blueprint length.** Smallest first, from current line counts:
    using-claude-code-with-cairn 829, debug-your-site 1277, restrict-admin-access 1387,
    scaffolded-site-files 1485, security-model 1567, add-a-second-sign-in-group 2395,
    add-cairn-to-a-sveltekit-app 2952. The probe is claude-code alone (the smallest, and the
    snippet fixture), wave 1 is the next three, wave 2 the last three. Check 1's page,
    restrict-admin-access, is in wave 1.

## Outcome

Five or more of cairn's seven non-figure stage 2b pages hold a draft that drafter accepted, that
passed cairn's docs gate inside its run, and whose lock entry matches, in one cairn PR for Geoff's
read. drafter gains:

- the small-finding rule at the round-2 verdict and at the coverage check's second miss (findings
  2 to 5);
- a `kind` on every review finding (finding 3);
- the snippet inputs (finding 7);
- #23's hold (finding 6), #25's scoped accept, and #26's stock draft ceiling of 128000.

cairn gains #14, #15, #16 (with finding 8's widening), #20, the `failure_pattern` fix, and the 31
fact and blueprint fixes.

- Risk class `runner`: drafter's pipeline and gate handling, and cairn's `scripts/checks`.
  `live-account` for API spend only; no GitHub, Cloudflare, or npm account is touched beyond pushing
  two branches and opening two PRs.
- Repos: `glw907/drafter` (tasks A1, A2) and `glw907/cairn-cms` (tasks C1 to C4 and the run, on one
  branch). Merge order: drafter first, then cairn with a merge commit.
- Path: the longest chain of tasks run in sequence, a pair counting once at its larger estimate.
  - A0, launch: 30.
  - Build segment: 150. A1 (150) and A2 (75) run as a pair, and the cairn tasks C1 (90) beside
    C2 (60) then C3 (45) run in the same window, so the segment is max(150, 75, 90, 105) = 150.
  - A3, merge, build, and the offline checks: 45.
  - C4, the re-anchors finding 8 calls for: 20.
  - R1, the scoped reads: 45.
  - R2, the probe: 45.
  - R3, wave 1: 75.
  - R4, wave 2: 90.
  - R5, the reruns: 45.
  - Close: 60.

  The sum is 30 + 150 + 45 + 20 + 45 + 45 + 75 + 90 + 45 + 60 = 605. B3c's waves set R2 to R4; R5
  is on the path because B3c's every page needed one. A batch stall is contingent and off the path.
- Clock file: `pass-task-clock` in the drafter worktree's git dir (`git rev-parse
  --absolute-git-dir`, run in `.claude/worktrees/acceptance`). During the build segment it holds
  A1's clock. When a pair returns, the session checks each pair task against twice its estimate,
  then runs `go test -run '<the task's named tests>' -v` on the task's packages and confirms each
  named test shows `PASS` and none `SKIP`.
- Executor: session `drafter-acceptance`, launched on `claude-opus-5-5` at `medium`, not
  pass-core's Sonnet default, as B3c was: the session judges each live escalation against the stop
  rules, traces causes, and spends live money. Worktree name `acceptance` (branch
  `worktree-acceptance`). Pair subagents' `description` is `acceptance task <id>`; cairn
  subagents' is `acceptance <task id> <page slug or "facts">`. Models:
  - A1 on `opus` at `high`: it changes the pipeline's stop rules and its gate classification.
  - A2 on `opus` at `medium`: it changes what the lock records.
  - C1 on `sonnet` at `medium` (`cairn-implementer` agent type): three check scripts with unit
    tests, specified below.
  - C2, C3, C4, and every fix subagent of R1 to R5 run `general-purpose` on `opus` at `medium`,
    each loading the `blueprint` skill first: each writes fact or blueprint judgment that a paid
    read then grades.
- STATUS is the file `acceptance-status.md` in the drafter worktree's git dir, beside the clock
  file. It is never committed. It holds the meter baseline, the binary's path and commit, `BASE`,
  one row per live call (command, N, cap, readings before and after, run id, after cell), and the
  page table.
- Names, written out literally in every command and subagent prompt, never as shell variables:
  - the drafter worktree: `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance`;
  - the binary, built there by `make build`:
    `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter`, written `ACC` in this
    plan only;
  - the cairn worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/acceptance-pages`,
    branch `acceptance-pages`;
  - `BASE`: the cairn worktree's start commit, recorded in STATUS at A0. Every lock entry of the
    seven equals its blueprint's blob at `517158fae` with no `blocked` (factsheet-cairn section 7),
    so one base serves every scoped read.

### Standing answers

From the design, applied in place of stopping:

1. A plan within 800 path minutes launches unattended once the sweep merges (it has).
2. Live spend up to $50 for the pass runs without asking, as a hard ceiling, metered as below.
3. An escalated page is reported with its finding and stop rule, and the run continues.
4. **Loop guards.** Every count cap below (reads, reruns, fix rounds) is a loop guard under
   pass-core "Lifecycle" step 1. Past a cap, the run goes on while each retry fixes a cause the
   session has traced and spend stays inside $50, and each fix is a reversible change listed in the
   cairn PR's `## Decisions`. A cause that returns after its fix gets one structural fix: the
   session replaces the unit the patches kept missing (a whole blueprint item, step, or fact
   bullet) instead of patching it again. If it returns after that, the session escalates the item
   in `## Decisions` and goes on.
5. **What may escalate.** Any single page, while at least five pages can still reach `accepted`.
   Also any page after the bar becomes unreachable (answer 6). It may not escalate drafter's code
   deliverables (the kind and the small-finding rule, the snippet inputs, #23, #25, #26), cairn's
   gate fixes (#14, #15, #16, #20, the `failure_pattern`), or a fact-check fix. A fact-check fix
   that the code shows to be wrong is made to what the code says and recorded in `## Decisions`
   with the file and line. An edit to `money.go` or `fingerprint.go`, the $50 ceiling, the 800-minute
   path ceiling, or a cause the session cannot trace still stops the line.
6. **The bar becomes unreachable** when three pages are out: escalated with no traced cause left to
   fix, or escalated after their cause returned past its structural fix, or not draftable within the
   budget left. The run then drafts every page that can still accept (an undrafted page, and a rerun
   with a traced cause, inside the budget), skips the rest, closes, and reports the count against
   the bar. That is not a stop.
7. A finding that changes the design, or spend that would pass $50, stops and asks: STATUS
   carries one question, and the executor waits for the conductor (pass-core "Judgment calls").

### The meter

At A0 the session records `/var/home/glw907/.local/bin/drafter spend --since 2026-10-19
--json` (the installed binary; `ACC` doesn't exist yet) in STATUS, and the drafter PR quotes it. At
planning it read `total 86.0216`, `open.worst 0.99695`. Before every live call, from the cairn
worktree:

- run `ACC spend --since 2026-10-19 --json`, fresh;
- `used = total − baseline.total + open.worst`, and `left = 50 − used`;
- at `left <= 0` the call doesn't start, and the run stops and asks (answer 7);
- otherwise the call runs with `DRAFTER_PAGE_CAP` set to `min(10, left / N)`, where N is the number
  of blueprints or pages the call takes.

The formula is B3c's. B3's cancelled batch holds `open.worst` 0.99695, so that dollar counts against
this pass too and errs safe. The ledger is per machine: another session's spend on `pavilion`
counts against the $50.

| Item | Estimate |
|---|---|
| R1 scoped reads, `--sync`, seven blueprints, about $0.45 each, plus one fix round | $5 |
| R2 probe, batch, claude-code | $3 to $5 |
| R3 wave 1, batch, three pages | $7 to $12 |
| R4 wave 2, batch, three pages including the two largest | $15 to $22 |
| R5 reruns | the rest |

B3c's draft costs per page are in cairn-cms#132's table.

## Tasks

### A0: launch, baseline, and worktrees (30 min), by the session

1. Run the "Pre-flight" checks again, then the one-executor checks: `pgrep -f
   worktrees/acceptance` finds nothing; `claude agents --json` shows no session working in drafter
   or cairn-cms other than the conductor; `git -C ~/Projects/cairn-cms worktree list` shows no
   `acceptance` worktree. Both main checkouts print nothing for `git status --porcelain`, sit on
   `main`, and print 0 for `git rev-list --count HEAD..origin/main` after `git fetch origin`.
2. `EnterWorktree` named `acceptance` in drafter. Arm the API-drop wake-up and the guards
   `~/.claude/docs/unattended-work-guards.md` names. Run the drafter gate once on the fresh tree
   (`DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh`); a red baseline stops the line.
3. Record the meter baseline in STATUS.
4. Create the cairn worktree: `git -C ~/Projects/cairn-cms worktree add -b acceptance-pages
   .claude/worktrees/acceptance-pages origin/main`. Record its `HEAD` as `BASE` in STATUS. Run the
   cairn-pass setup there: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase &&
   npx svelte-kit sync)`.
5. Copy `~/.config/drafter/cairn-cms.local.toml` into the cairn worktree as `drafter.local.toml`,
   with `prompts` set to
   `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/claude/.claude/workflows/docs-page-chain.js`
   and every other key as it is (finding 13). Run `drafter config` there: `prompts` shows the local
   layer at that path, `page_cap = 10`, `inline_files` and `gate.index_link_command` from the local
   layer. `git status --porcelain` in the cairn worktree prints nothing (`drafter.local.toml` is
   ignored, `.gitignore:33`).
6. Baseline cairn: `drafter check` reports 0 errors, and `CAIRN_GATE_LANE=light cairn-run-gate 'npm
   run check:facts'` exits 0, both in the cairn worktree.

- Files: none committed in drafter; the cairn worktree holds no commit yet.
- Risk class `runner`.
- Acceptance: each step's output recorded in STATUS.

### A1: the kind, the small-finding rule, the hold, and the snippet inputs (150 min), paired with A2, `opus` at `high`

Outcome: findings 2 to 7.

- Files: `internal/pipeline/{steps.go,handle.go,check.go,work.go,blueprint.go,record.go}` and new
  files beside them, `internal/assemble/{schema.go,assemble.go}` as needed,
  `internal/edits/types.go`, `internal/gate/run.go`, their tests, and
  `internal/pipeline/testdata/record.golden.json` (regenerated with `UPDATE_GOLDEN=1`, since the
  record gains `kind`). Not `cmd/`, `internal/config/`, `docs/`, `stock/`, or the chain, which A2
  owns or nobody touches, so the pair's files are disjoint.
- Never `money.go` or `fingerprint.go`; `resume.go` only per the B3 ruling (finding 9).
- Risk class `runner`.
- Build:
  - The kind (findings 3 and 4). `readAnswer`'s finding and `edits.Finding` gain `Kind`; the review
    seats' answer schema gains a required `kind` enum of the eleven values, and its contract
    sentence names each value with a one-clause definition. The blueprint read sends today's
    schema and contract bytes.
  - The small exchange. A new exchange kind and step, scoped to the small findings, bounded as the
    redraft is, its own stage token, and its own `kind+".contract"` budget row (shared with
    `refused`, `handle.go:464`). After it, the gate, then a coverage check in a new phase that
    remembers its origin. No misses: the page goes to `stReader1` (origin round 2) or `stRound2`
    (origin coverage). A miss: the page escalates with rule `second fix verdict` and a detail that
    opens "after the small-finding fix:". Each origin is reached at most once per run, so a page
    takes at most two small exchanges.
  - The two points. `afterRound2` collects the blocking findings of every seat that answered fix
    (finding 5); all small opens the small exchange, otherwise it escalates as today. `afterCoverage`
    at `covRedraft` maps each miss by finding 4; all small opens the small exchange, otherwise it
    escalates as today. The reader, scoped, and coherence rules are unchanged.
  - #23 (finding 6). `ForPage`, or its caller in `runGate`, treats an unparsed red as foreign when
    its tail names a page or brief of another page in the run (`p.r.o.Handoffs`) and names neither
    this page nor its brief. An unparsed red that names this page, or no page, stays own
    (`TestUnparsedIsOwn` unchanged).
  - The snippet inputs (finding 7), in `draftingBlocks` for the draft seat.
- Tests, table-driven, on the pipeline harness (`newHarness`, the scripted fake API; copy
  `TestSecondRoundFixEscalates`, `flow2_test.go:274`, and `TestCoverageMisses`' "a miss after the
  redraft", `:197`):
  - Round 2 answers fix with only `link` and `handoff` findings: the small exchange runs, the gate
    is green, coverage passes, the reader reads, the page accepts.
  - Round 2 with one `voice` finding beside a `link` one: `second fix verdict`, as today.
  - Round 2: structure answers fix with a small finding and fact answers fix with a `claim`: it
    escalates (every seat is weighed).
  - Round 2: a fix whose findings are all non-blocking plus one blocking `heading`: small.
  - A finding with an empty kind, and one with an unknown kind: not small.
  - `covRedraft` misses of kinds `link` and `brief`: the small exchange runs, then round 2 reads.
  - `covRedraft` miss with reason "heading not found": escalates as today.
  - `covRedraft` miss of kind `fact` with the "cites fact" reason: small.
  - The small exchange's coverage still misses: escalates, rule `second fix verdict`, detail opening
    "after the small-finding fix:".
  - The small exchange's gate stays red past `retries.edit_contract`: `contract`, as other edit
    exchanges do.
  - A run stopped with the small exchange's gate pending resumes into the new coverage phase and
    sends the same bytes (a regression for finding 9's `coveragePhase` path).
  - A state saved before this pass (findings with no `Kind`) decodes and resumes as before.
  - Schema: the review answer's finding requires `kind` with exactly the eleven values;
    `TestSchemasKeepToStructuredOutputLimits` passes; `blueprint-read-request.golden.json` and
    `read-dryrun-count.golden.json` are unchanged and never regenerated (A2 runs the second; A1
    confirms the first).
  - #23: an unparsed red whose tail names only a sibling's page holds the page with no fix turn; the
    tail copied in shape from B3c's gate-4 log (a synthetic fixture, no workstation path); an
    unparsed red naming this page stays own; `TestHeldPageSpendsNoFixTurn` and
    `TestForeignRedThatPersistsStopsTheRun` pass unchanged.
  - Snippets: a `code` item whose `source` is a page-relative tracked file puts that file's
    contents in the draft request's `Extra`; the redraft exchange's first request carries it too;
    a `#Symbol` source inlines the whole file; an `https://` source adds nothing; an untracked or
    oversize file gets `fileBlock`'s "not inlined" line.
- Acceptance: `make check` green in the pair worktree. Each row above, by test name, shows `PASS`
  under `go test -run '<names>' -v`. The commit message names the tests and every switch the new
  kind joined.

### A2: the scoped accept, the stock ceiling, and the docs (75 min), paired with A1, `opus` at `medium`

Outcome: #25, #26, and the docs for every drafter change in this pass.

- Files: `cmd/drafter/{bar.go,read.go,pagebp.go}` and their tests, `e2e/readbar_test.go`,
  `internal/config/{stock.toml,stock_test.go}`, `docs/blueprint-format.md`, `docs/configuration.md`.
- Risk class `runner`.
- Build:
  - #25: a scoped accept with no bar writes `accepted` (the blueprint blob at the run's start) and
    drops `blocked`, in `drafter read` and in `drafter page`'s `recordDrafted`, so a drafted entry
    after a scoped accept carries the new blob. The stderr line "accepted on a scoped read;
    drafted.lock keeps its earlier entry" goes, and `read --help` (`read.go:51-57`) says what the
    accept writes.
  - #26: `[seat.draft] max_tokens = 128000` in `stock.toml`, and `docs/configuration.md:292` and
    `:417` follow.
  - Docs: `docs/blueprint-format.md` ("What `drafter page` does with a blueprint" and `:557`) states
    the scoped accept, the small-finding rule (from findings 2 to 5 of this plan: which kinds are
    small, where the rule applies, and where the page goes after it), the snippet inputs, and the
    sibling hold, in the docs' existing register.
- Tests:
  - `TestRecordReads`' row "a scoped accept with no bar keeps the old accepted" becomes "advances
    accepted and drops blocked"; `TestScopedAccept`, the `read_test.go` subtest at `:577-597`, and
    `e2e/readbar_test.go:81,105` follow.
  - `drafter page` with a scoped accept at s1: the lock entry's `accepted` equals the blueprint's
    blob at the run's start commit.
  - A bar accept and an unscoped accept behave as today (regression).
  - `stock_test.go:33` reads 128000.
  - `TestReadDryRunRequestGolden` passes with the golden unchanged.
- Acceptance: `make check` green in the pair worktree; each row by test name shows `PASS`.

### C1: cairn's gate fixes (90 min), in the build window, `cairn-implementer` on `sonnet` at `medium`

Outcome: cairn backlog #14, #15, #20, and finding 6's `failure_pattern` half.

- Works in the cairn worktree by absolute path. It edits only the files below and never commits;
  the session commits once `git status --porcelain` names only them.
- Files: `scripts/checks/check-provenance.mjs`, `scripts/checks/check-symbols.mjs`,
  `scripts/checks/check-leaks.mjs`, `src/tests/unit/check-{provenance,symbols,leaks}.test.ts`,
  `drafter.toml` (`failure_pattern` only), `BACKLOG.md` (closing #14, #15, #20).
- Risk class `runner` (`scripts/checks`).
- Build (factsheet-cairn sections 1 to 3):
  - #14: a code span that is the whole text of a Markdown link is navigation, not a claim, so a
    no-claim sentence may name `[`createAuthGuard`](...)`. `PROSE_COMMAND_RE` (`:151`) no longer
    reads `npm <word>` as a command unless the word is an npm subcommand; `npx`, `pnpm`, and `yarn`
    keep today's rule.
  - #15: a token that opens with `#` is a package import specifier, not a repository path, and
    `extractFilePaths` skips it.
  - #20: `blueprints` joins `SCAN_ROOTS`, and `profileFor` maps `blueprints/` to the tier of
    `docs/internal/briefs`, outlines, and facts (T3, classes C1, C2, C4), which finds 0 today.
  - `failure_pattern` also matches the `check-symbols` defect line shape (two spaces, a path, a
    line number, a bracketed class), so a `check:symbols` red parses.
- Tests:
  - `extractFacts` on "See [`createAuthGuard`](../reference/x.md)." in a no-claim sentence: no fact.
  - A code span outside a link in a no-claim sentence still fails (regression).
  - "Install the npm package first." extracts no command; "Run `npm run build`" and "npm install"
    in prose still do.
  - `extractFilePaths` on `#lib/cairn.config.js`: no path; `src/lib/x.ts` still resolves
    (regression).
  - `profileFor('blueprints/docs/extend/x.blueprint.yaml')` returns the T3 profile; the leak check
    over today's `blueprints/` reports 0.
  - The session runs the new `failure_pattern` over B3c's saved
    `20261019T233356Z-01abf04b/docs--extend--security-model/gate-4.log` (in drafter's state
    directory) and gets at least one match where there were 0.
- Acceptance: `npx vitest related --run --passWithNoTests --project unit <the six files>` green
  through `cairn-run-gate`; the cairn fast lane's line 1 green (`node scripts/checks/gate-tier.mjs
  --fast --range BASE..HEAD`); its component line 2 run with `RUN_GATE_IF_BUSY=defer`, since cairn
  CI is the full-suite home and no task touches `src/lib` or a component.

### C2: the facts store edits (60 min), in the build window, `general-purpose` on `opus` at `medium`

Outcome: every fact-side fix among the 31, and #16's three re-anchors.

- One agent for the whole store, because the fixes share `docs/internal/facts/extend.md`,
  `reference.md`, and `admin.md`. It loads the `blueprint` skill, edits only
  `docs/internal/facts/*.md`, and never commits.
- Its prompt carries, verbatim, the evidence record's "The findings, page by page" and
  factsheet-cairn section 5's table, and names each fact to edit: `f:1kwkl0`, `f:vhxkab`,
  `f:4ax489`, `f:v1jj2k` (with its stale source pointer, `admin-action.ts:214-216`), `f:1b3ye3`,
  `f:07efts`, `f:cvv6to`, `f:iewhzh`, `f:3z48zf`, `f:qlgggh`, `f:nls26c`, `f:666eg6`, `f:qca0t0`,
  `f:n7t4bn`, `f:qnf469`, `f:n2skkz` (pointer `:2-34`), `f:keuj8l`, `f:21by9u`, `f:zzbzo8`,
  `f:ubuj1w`, `f:t976f1`, `f:hwffph`, `f:7cv105`, `f:ntdafg`, `f:f2vudv`. It re-anchors `f:i1dayf`,
  `f:nup3og`, and `f:gy2h7p`'s `createSectionAction.wrap` pointer to line ranges
  (`section-action.ts:221-282` and `:286-289,303-304`, factsheet-cairn section 4).
- Each edit states what the code says at the line factsheet-cairn gives, with the source pointer
  updated to it. A fact whose code reading disagrees with the record is written to the code, and the
  agent reports it for `## Decisions`. Facts other blueprints cite (`f:cvv6to` in security-model,
  `f:nls26c` in add-a-second-sign-in-group and rotate, `f:qca0t0` in restrict-admin-access,
  factsheet-cairn section 6) are edited once, for every citer.
- Risk class `runner`, the pass's class. No API spend.
- Acceptance: `drafter check` 0 errors in the cairn worktree (the installed binary; the facts store
  needs no new drafter feature); `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:facts'`
  exits 0; `git diff --name-only` names only facts files; the agent's report lists each fact with
  its finding number.

### C3: the blueprint edits (45 min), after C2, seven `general-purpose` subagents on `opus` at `medium`

Outcome: every blueprint-side fix among the 31, one subagent per page.

- Each subagent loads the `blueprint` skill and edits only its page's blueprint under
  `blueprints/docs/`. Its prompt carries its page's findings verbatim from the evidence record, its
  rows of factsheet-cairn section 5 with the item ids, and C2's fact list. It places the unplaced
  facts its page needs (`f:147zhc` for debug #3, `f:yio35u` for add-cairn #2, `f:xothz1` for
  security #3), and for debug #1 also names public admin paths (`isPublicAdminPath`,
  `guard.ts:297`, `:359`).
- Every subagent runs `/var/home/glw907/.local/bin/drafter check <its blueprint>` and gets 0
  errors before it returns. It never runs `drafter read` or `drafter page`, and never edits
  `drafter.toml`, `drafted.lock`, facts, outlines, or pages.
- The session commits C2 and C3 as one commit ("Fix the fact-check findings at their source"),
  whose body maps each of the 31 to its fact or item, after `git status --porcelain` names only
  facts files and the seven blueprints.
- Risk class `runner`.
- Acceptance: `drafter check` 0 errors over the tree; the cairn fast lane's line 1 green, its line 2
  deferred as in C1; the commit body's map covers 31 findings.

### A3: merge, build, and the offline checks (45 min), by the session

1. Merge A1 and A2. Run the named-test check (see "Clock file"), then `make check`, then `make
   build`. Record `ACC`'s commit in STATUS. `ACC` is rebuilt after any later drafter fix, and every
   STATUS row names the commit its call ran.
2. In the cairn worktree, after C1's and C3's commits:
   - `ACC config` shows `prompts` at the worktree chain and `blueprints.brief_path`;
   - `ACC check` reports 0 errors;
   - `ACC check-prompts --matrix
     /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/tests/fixtures/drafter/blueprint-matrix.json`
     exits 0;
   - the docs gate offline on one page:
     `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:docs-gate -- --page
     docs/extend/restrict-admin-access.md --brief docs/internal/briefs/extend/restrict-admin-access.json'`
     is green, or red only on that page's own live-page defects the rerun will replace (a
     whole-tree component red stops the line: no draft could pass);
   - `git status --porcelain` prints nothing.
3. The real-context render check, which spends nothing, as B3c.5 step 4 ran it: a shared clone of
   the cairn worktree's head in the scratchpad with the local layer copied in, one lock edit there
   setting each of the seven entries' `accepted` to its blueprint blob, a local stub that records
   each request body and answers `count_tokens` and the models list (`batch/client.go:81-106`),
   `DRAFTER_API_BASE_URL` pointed at it with a dummy `DRAFTER_API_KEY`, and
   `ACC page --whole --dry-run --json` over the seven pages. Each exits 0. Then grep the recorded
   bodies:
   - claude-code's draft body holds `=== file: claude/snippets/check-cairn.json ===` and
     `=== file: claude/snippets/check.yml ===`;
   - no body holds `undefined`, `.plan.yaml`, `.plan.md`, `.framing.md`, or `worktree`;
   - list every fact excerpt reading "declaration not found" and the fact id it belongs to, into
     STATUS, for C4.
   Delete the clone and stop the stub.

- Risk class `runner`.
- Acceptance: each step's output as stated, recorded in STATUS.

### C4: the excerpt re-anchors (20 min), by one `general-purpose` subagent on `opus` at `medium`

Outcome: finding 8. Each fact A3 listed has a source pointer drafter's excerpt resolves, with its
claim unchanged.

- Files: `docs/internal/facts/*.md` only. When A3 listed none, the task is skipped and STATUS says
  so.
- Acceptance: a rerun of A3 step 3's grep lists none; `drafter check` 0 errors; `npm run
  check:facts` exits 0 through `cairn-run-gate`; one commit, "Re-anchor the facts drafter can't
  excerpt", whose `git show --name-only` names only facts files.

### R1: the scoped reads (45 min), by the session with fix subagents

Outcome: design item 4. Each of the seven blueprints holds an `accepted` equal to its current blob,
or is escalated and out of the waves.

- Live, `--sync`, under the meter. From the cairn worktree, after a fresh meter reading, the one
  call is:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/7)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter read --since <BASE> --sync --json blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml blueprints/docs/extend/debug-your-site.blueprint.yaml blueprints/docs/extend/restrict-admin-access.blueprint.yaml blueprints/docs/extend/scaffolded-site-files.blueprint.yaml blueprints/docs/extend/security-model.blueprint.yaml blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml
  ```

  The session commits the lock at once ("Record the scoped reads"). Each scoped accept now writes
  `accepted`, so the waves' `--whole` runs skip the read (`skipRead`, `draftscope.go:89-114`).
- A blocked read: a fix subagent edits that one blueprint (or, for a fact the read names, the fact),
  gets 0 errors from `ACC check <its blueprint>`, and returns without committing. The session
  checks `git status --porcelain`, commits the round, and reads every still-blocked blueprint again
  with the same command, the same `--since <BASE>`, and only those blueprints' paths. Every read in
  this pass passes `--since <BASE>`; a read without it reads the whole blueprint (B3c's stop 3).
- Three reads per blueprint is the loop guard (standing answer 4). A read that escalates on a
  consistency conflict between two facts is a traced cause when C2's edit made the conflict, and is
  fixed in the fact; otherwise the page escalates.
- Check after: for each page in the waves, the lock's `accepted` equals `git rev-parse
  HEAD:<blueprint>`.
- Risk class `runner`. Files (cairn): the seven blueprints, facts files a read names, the lock.

### R2: the probe (45 min), by the session

Outcome: claude-code drafted, accepted or escalated; a mechanical fault found on the smallest page.

1. The inbound-anchor sweep, B3c's pre-run fix, for each page in the call: every link elsewhere in
   `docs/` into `<page>.md#<anchor>` must name an anchor the blueprint's section headings produce.
   A link that doesn't is retargeted to the nearest section and committed before the run.
2. A fresh meter reading, then:

   ```
   DRAFTER_PAGE_CAP=<min(10, left)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/claude-code/using-claude-code-with-cairn.md
   ```

3. Accepted: commit the page, its brief, any index file the index-link command changed, and the
   lock in one commit; then run Check 3 on it. Escalated: report it in STATUS with its rule,
   finding, and run id. A mechanical cause in drafter (a step errors, a prompt names a missing file,
   the snippet block is absent) is fixed in the drafter worktree with a test, `make check`, and a
   rebuild before R3, and the page reruns in R5.

- Live, batch. Risk class `runner`.

### R3: wave 1 (75 min), by the session

Outcome: debug-your-site, restrict-admin-access, and scaffolded-site-files drafted. Check 1 on
restrict-admin-access.

1. The inbound-anchor sweep for the three.
2. A fresh meter reading, then:

   ```
   DRAFTER_PAGE_CAP=<min(10, left/3)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/extend/debug-your-site.md docs/extend/restrict-admin-access.md docs/extend/scaffolded-site-files.md
   ```

3. The accepted pages, their briefs, their index edits, and the lock go in one commit, then Check 3.
   Each escalated page is in STATUS with its rule, finding, run id, and whether the small path ran
   (its `record.json`). A mechanical cause is fixed before R4, as R2 says.

- Live, batch. Only pages whose blueprint accepted in R1 are in the call. Risk class `runner`.

### R4: wave 2 (90 min), by the session

Outcome: security-model, add-a-second-sign-in-group, and add-cairn-to-a-sveltekit-app drafted.

1. The inbound-anchor sweep for the three.
2. With the real key, `ACC page --whole --dry-run --json docs/extend/add-cairn-to-a-sveltekit-app.md`
   (a dry run sends only `count_tokens` and writes no ledger line); record the first stage's worst
   case against the cap in STATUS, so a predicted `cap` escalation is reported as predicted.
3. A fresh meter reading, then:

   ```
   DRAFTER_PAGE_CAP=<min(10, left/3)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/extend/security-model.md docs/extend/add-a-second-sign-in-group.md docs/extend/add-cairn-to-a-sveltekit-app.md
   ```

4. Commit and Check 3 as R3.

- Live, batch. Risk class `runner`.

### R5: the reruns (45 min), by the session

Outcome: each escalated page whose cause the session traced and fixed takes one more run, inside
the budget.

- Which pages rerun:
  - a fault (a seat answer cut at `max_tokens`, an answer that doesn't parse, an API failure): once,
    alone;
  - `cap`: once, alone, as a fresh batch run at the cap the meter allows;
  - a mechanical cause fixed with a test in drafter, or a blueprint or fact cause fixed in cairn and
    read again with R1's command (its own path only, `--since <BASE>`), or an inbound link
    retargeted after "tree red outside drafter's pages": once more, under standing answer 4;
  - a verdict escalation whose finding is the draft's own writing and traces to no blueprint, fact,
    or drafter cause: not rerun; the page is out.
- Each rerun, after a fresh meter reading:

  ```
  DRAFTER_PAGE_CAP=<min(10, left)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/<arm>/<page>.md
  ```

- Every first draft of the seven runs before any rerun spends.
- Commit and Check 3 as R3. Live, batch. Risk class `runner`.

### Run rules for R1 to R5

- **The tree.** A run needs a clean tree at its start (`start.go:88`). The session commits before
  each live call and never edits the cairn worktree while a run is live. A drafted page or brief is
  never edited by hand afterward (Check 3).
- **Recovery, the binary, and the stall rule** are B3c's resolutions 6 and 8, with `ACC` in place
  of `$B3C_DRAFTER` and this pass's worktrees. A stopped batch page run resumes with `ACC page
  --resume <id> --json`, a stopped sync read with `ACC read --resume <id> --sync --json`, each on a
  fresh meter reading and never in another mode.
- **The rule a page ended on** comes from its run's summary and `record.json`: the rule, the seat,
  the finding, the kinds, and whether a small exchange ran. STATUS keeps it per page.

## Checks

Each row maps to the design's "Check".

- **Check 1.** restrict-admin-access's R3 run summary shows `accepted`, its lock entry holds
  `accepted` equal to `git rev-parse HEAD:blueprints/docs/extend/restrict-admin-access.blueprint.yaml`,
  its `record.json` holds no gate-fix exchange whose findings are `check-provenance` lines on a
  linked name or "npm package", and its last open findings, if a small exchange ran, were `link` or
  `handoff` only. When it escalates, the row reports the rule and finding, and the PR says Check 1
  is unmet.
- **Check 2.** Each of the seven ends `accepted`, or `escalated` with its rule, finding, and run id;
  the count meets five, or the PR reports the bar unmet. At close, on the close head, the session
  runs `npm run package` once, then for each accepted page `CAIRN_GATE_LANE=light cairn-run-gate
  'npm run check:docs-gate -- --prebuilt --page <page> --brief
  docs/internal/briefs/<arm>/<name>.json'`, exit 0. claude-code's row names the gate components
  that skip `docs/claude-code` (B3c finding 3).
- **Check 3.** Run at `HEAD` after each accepted page's commit and again at close. Each accepted
  page's entry: `page` equals `git hash-object <page>`; `blueprint` equals `git rev-parse
  HEAD:<blueprint>`; `accepted` equals `blueprint`; no `blocked`; and `ACC page --dry-run --json
  <page>` prints "up to date with drafted.lock".

## Close (60 min)

1. drafter: the gate on the close head from the worktree, `DRAFTER_DIR="$PWD" bash
   scripts/drafter-gate.sh` through `cairn-run-gate`, re-issued on exit 75. drafter has no CI, so
   this is its full-suite home.
2. One whole-branch `diff-reviewer` read of each branch against this plan and the design: drafter's,
   and cairn's (scripts/checks, `drafter.toml`, the facts, the blueprints). If any commit touched
   `resume.go`, the drafter read confirms its task-scope read happened. `prose-voice-reviewer` reads
   drafter's changed `docs/` pages. One batched fix chain follows, then the gates again; a second
   review only on a blocker. A fix dispatch quotes each finding verbatim as its acceptance. A fix
   to a drafted page or brief is never made by hand: the page reruns inside the budget or the
   finding is reported.
3. cairn, before the push, with `ACC` rebuilt from the drafter close head: `ACC check` 0 errors;
   `ACC page --dry-run --json` over the seven pages prints "up to date with drafted.lock" for each
   accepted page; Check 2's gate rerun; and `git diff origin/main...HEAD` grepped for `/home/`,
   `/var/home/`, `thinkpad-x1`, and `pavilion` prints nothing (the leak check now scans
   `blueprints/`, but not every pattern).
4. cairn: push `acceptance-pages` to `glw907/cairn-cms` and open a draft PR. Run `ci-green <sha> --pr
   <n> --wait` in the background. A red from this branch's files is fixed on the branch, except a
   red on a drafted page or brief, which is reported or rerun with `--whole` inside the budget. A red
   elsewhere is reported.
5. drafter: push `worktree-acceptance` to `glw907/drafter` and open its PR.
6. Each PR body opens with `## Brief`, per `~/.claude/docs/voice/approval-brief.md`.
   - The drafter PR: what landed; the acceptance table, one row per offline check; the live spend
     and meter readings; any abandoned run id with its `open.worst`; every departure from this plan;
     any `resume.go` verdicts; `## Decisions`; the score per pass-core "Score", with Work and review
     naming 605 path minutes beside the actual.
   - The cairn PR: the seven-page table (status, rule, finding and its kinds, whether the small path
     ran, run id, cost, read count, gate coverage); the accepted count against five; Check 1's row;
     Check 2's rerun and Check 3; the drafter commit each live call ran; the 31-finding map with
     each fix's commit; `## Decisions`.
   - Each PR links the other and states the merge order below.
7. Backlogs, through `log-issue`, tagged `#initiative:docs-system`, each listed in its PR body:
   - drafter: close #23, #25, #26; file "resolve a dotted excerpt anchor to a nested declaration"
     (finding 8, `internal/assemble/excerpt.go:86-92`).
   - cairn: close #14, #15, #16, #20; file the wrong claims outside the seven (finding 12:
     `docs/reference/log-events.md:74`, `docs/extend/upgrade-cairn.md:101`,
     `docs/reference/sveltekit.md:2100`) and the `admin-action.ts:155-157` doc comment; file the
     remaining dotted anchors drafter can't excerpt; file a gate-table bucket for `blueprints/`
     (factsheet-cairn section 10: today a blueprint edit selects every static check and the
     component suite).
8. Stop at PR-ready for both PRs. The executor never runs `approval-queue`; `conductor-drafter`
   hands the packet to Geoff.

## Merge order

1. glw907/drafter's PR first, with `--match-head-commit` from the decision. Then pull
   `~/Projects/drafter`. Check that no drafter run is stopped and resumable: `grep -l '"stopped"'
   ~/.local/state/drafter/runs/*/*/state.json` prints nothing beyond the abandoned run ids the PR
   lists (finding 10: a run started under the stock 64000 can't resume after it). Then `make
   install` from the main checkout. The other workstation pulls and runs `make install` before it
   runs drafter on cairn.
2. glw907/cairn-cms's PR second, after Geoff reads the pages, with a merge commit, never squash or
   rebase; the session never rebases `acceptance-pages`. Then pull `~/Projects/cairn-cms`.

## Later

Kept out of this pass and never built here:

- Rotate, the three figure pages, drafter's own docs, O, B4, and B5 (design, "Shape").
- A code-grounded fact check (design, "Later").
- drafter backlog #24 (keep a heading another page links to); the inbound-anchor sweep stands in.
- drafter backlog #27 (a moved `Source:` path counts as a changed fact); every draft here is whole.
- The chain's own Workflow path labeling findings by kind; drafter's runs get the label from the
  schema (finding 3).
