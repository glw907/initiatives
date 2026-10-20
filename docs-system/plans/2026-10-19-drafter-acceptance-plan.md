# drafter acceptance plan: cairn's seven pages

Initiative: docs-system

Path estimate: 635 minutes against the design's 400 (1.59x), inside the 800-minute standing answer.
The arithmetic is under "Outcome". The three plan reviews and their fold are in
`docs-system/research/2026-10-19-drafter-acceptance-plan-review-{contract,integrity,mechanics}.md`
and `…-plan-fold.md`.

Design: `~/Projects/initiatives/docs-system/specs/2026-10-19-drafter-acceptance-design.md`, approved
by Geoff on 2026-10-19 (glw907/initiatives#59). He ruled both asks as recommended:

- The bar and the budget: five of seven pages accepted, at a $50 live-spend ceiling, with the
  existing $10 page cap.
- The fact-check findings: every finding in the evidence record is fixed at its source before the
  rerun.

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
- The SessionStart hook's `## Host` line reads `pavilion`. The ledger is per machine, and C1's probe
  reads B3c's gate logs from pavilion's drafter state directory.
- `/var/home/glw907/.local/bin/drafter spend --json` (the billing cycle) shows `total` plus
  `open.worst` at or under 110, so the cycle's `cycle_ceiling = 160` leaves the pass its $50. At
  planning it read 100.71 plus 0.997.
- `~/.config/drafter/cairn-cms.local.toml` and `~/.local/share/cairn/exemplars` exist.
- `DRAFTER_API_KEY` is set in the launching environment (checked by name, never printed).
- `go`, `node`, `vale`, `yq`, `cairn-run-gate`, `ci-green`, `cairn-docs-outline`, and `tellgrader`
  resolve. `drafter config` in `~/Projects/cairn-cms` prints `page_cap = 10` and
  `cycle_ceiling = 160` from the user layer.

All of these held at planning time.

## Findings for the planning session

None changes the approved design. Each is decided here; the ones marked "contestable" are method
calls a reviewer may want to argue.

1. #25 lands before the scoped reads. The design orders the work "items 1 and 2, then 4, then 3, 5,
   and 6, then 7", but item 4's reads rely on item 6's #25: "`drafter read --since <pre-fix
   commit>`, which advances the lock on an accept (#25)". Today a scoped accept writes nothing
   (`recordReads`, `cmd/drafter/bar.go:74-100`, falls to `default`), so a read run on today's
   binary would leave every lock entry stale. The drafter work therefore runs first, beside the
   cairn edits, and the reads run on the built binary. The outcome and every item are unchanged;
   only the sequence moves, and the drafter work leaves the critical path's cairn chain alone.
2. The small-finding rule follows the design's text, as ruled at planning on 2026-10-19. After the
   one small fix exchange, the gate and the coverage check run again with no review seat and no
   reader, and the page reaches `accepted` when both pass. The page ends through `reviewed`
   (`handle.go:384-391`), which accepts a whole-page run; a section-scoped run would still take its
   coherence read, and every run in this pass is `--whole`. A coverage miss after the small
   exchange escalates with rule `second fix verdict`, whatever the miss's kind. A page gets at most
   one small exchange per run: after it, the only outcomes are `accepted`, a `contract` escalation
   from its gate, or the coverage escalation above, so a second small-eligible stop never opens a
   second exchange.
   The cost, which the cairn PR's `## Decisions` and the packet both state: at the coverage origin
   (`afterCoverage` at `covRedraft`), round 2 never runs, so no seat reads the redraft before the
   page accepts; at the round-2 origin, the final reader never reads the fixed page. At either
   origin the gate and the coverage check are the only guards on what the small exchange wrote.
3. The kind travels in the answer schema, not in the prompts modules (contestable). Every read seat
   of both modules gets one Go-side schema and one contract sentence per answer
   (`internal/assemble/schema.go:19-20,80-95`), sent as structured output with
   `additionalProperties: false` (`internal/batch/request.go:44-50`). A required `kind` enum on a
   finding in `readSchema`, with its definitions in the contract sentence, makes every review seat
   of `stock/prompts.js` and of the chain label its findings, and neither module's rendered prompt
   changes. `readSchema` serves `AnswerRead` and `AnswerReader2` (`schema.go:19`), so the
   coherence seat and the reader's second turn label their findings too; the label is recorded and
   used only at the two small-finding points. That keeps the chain's handoff mode byte-identical
   with no work, keeps the stock module's "register" and slash bans out of play
   (`stock/stock_test.go:315,328`), and keeps the chain's own Workflow path untouched (its `FINDING`
   schema, `docs-page-chain.js:515-524`, is a separate object). The blueprint read shares
   `AnswerRead` today (`blueprint.go:160`) and its request bytes are pinned by two goldens meant
   never to move (`internal/pipeline/testdata/blueprint-read-request.golden.json`,
   `cmd/drafter/testdata/read-dryrun-count.golden.json`), so the blueprint read moves to an answer
   value of its own that renders today's schema and contract exactly. That value joins every switch
   keyed on the answer: `answerSchema`; `commandBlocks`, which runs seat `inputs` only for
   `AnswerDraft` and `AnswerRead` (`internal/assemble/commands.go:27`) and must run them for the new
   value; `inputBlocks` (`assemble.go:124-147`); the answer list of
   `TestSchemasKeepToStructuredOutputLimits` (`schema_test.go:65`); and the blueprint seat's row in
   `internal/smoke/shapes.go:49`. Kinds are compared with `strings.EqualFold`, since structured
   outputs don't guarantee an enum value's capitalization (Claude API docs, "Enum value casing").
   The alternative, a kind-list sentence in each module's review prompts, touches two modules,
   about ten goldens, and the stock bans, for the same label.
4. The kind vocabulary is closed. Review findings take one of `link`, `handoff`, `heading`,
   `citation` (the small kinds, the design's "a link, a handoff, a heading, or a brief citation"),
   or `fact`, `claim`, `code`, `voice`, `step`, `placement`, `other` (the design's "a fact, a claim,
   a code sample, a register or voice finding, a missing step, misplaced content", and a catch-all
   that escalates). `voice` stands for register so the word stays out of request text. A finding
   with an empty or unknown kind, such as one in a state saved before this pass, is not small.
   Coverage misses carry their own kind (`internal/coverage/check.go:14-19`), today only inside the
   finding's text (`missFinding`, `steps.go:370-380`); `missFinding` now also sets the finding's
   `Kind` to the mapped value below, so `record.json` carries it. The mapping:
   - small: `link` ("no link to <target> in this section") maps to `link`; `handoff` from the
     coverage read maps to `handoff`; `brief` ("brief sentence not found on the page") and `fact`
     ("no brief sentence in this section cites fact <id>") map to `citation`;
   - not small: any miss whose reason is "heading not found" (the section itself is missing) maps
     to `placement`; `verbatim` to `code`; `reason` and `claim` to `claim`.

   The `fact` coverage miss as a citation is contestable: it is security-model's B3c ending, and the
   gate's provenance check and the coverage recheck still guard the brief after the fix.
5. The rule weighs every round-2 seat. `afterRound2` escalates on the first seat that answers fix
   and never looks at the rest (`steps.go:581-599`). The small path needs every blocking finding of
   every round-2 seat that answered fix to be small, so the new code reads all of them before it
   decides. Non-blocking findings ("Nit:", "Already present:") never count. A seat that answers fix
   with no blocking finding at all escalates as today (`steps.go:587-593`): it contradicts its own
   verdict rule, and "all small" must never hold for an empty set.
6. #23's cause is traced, and its fix is cairn's pattern. In B3c's wave 2 (run
   `20261019T233356Z-01abf04b`), gate run 4 of security-model and of add-a-second-sign-in-group
   failed only `check:symbols`, on the line `docs/extend/add-cairn-to-a-sveltekit-app.md:297
   [file-path]  lib/cairn.config.js` (add-cairn is a sibling in that run). No line in either log
   matches cairn's `failure_pattern` (`drafter.toml:14`; probed with Go's `regexp` over each saved
   `gate-*.log`, 0 matches in both gate-4 logs), so `parse` marks the log unparsed
   (`internal/gate/run.go:223-226`), and an unparsed red is always the page's own
   (`run.go:240-241`, `TestUnparsedIsOwn`). Each page spent a fix round on a sibling's line. A
   drafter rule on the unparsed tail can't fire on this case: the tail is the last 60 lines
   (`tailLines`, `run.go:22`), both logs run 217 lines, and the sibling's line is line 50; and the
   whole log names this page in `check:snippets`' listings, so a whole-log rule would call it own
   too. So the fix is cairn's `failure_pattern`, which gains the `check-symbols` defect line's shape
   (cairn task C1). Once that line parses, the existing `ForPage` (`run.go:236-251`) finds no
   failing line naming this page and holds it (`check.go:106-108`). drafter's deliverable for #23 is
   a pipeline regression test on a full-length synthetic log with cairn's new pattern, and no
   change to `gate/run.go`. #15's fix also removes that particular line.
7. The snippet inputs are a Go change, for the draft seat only, as the design says (ruled at
   planning). A `code` item's `source` is relative to the page (`../../claude/snippets/check.yml`),
   travels only inside the blueprint block in `Extra`, which is never scanned for paths
   (`assemble.go:52-58`), and neither module's draft prompt names it (`stock/prompts.js:273`, chain
   `:2572`). So drafter resolves each `code` item's `source` against the page's directory, as
   `plan/check.go:264-269` does, drops a `#Symbol` suffix, and inlines the file through a new
   exported helper in `internal/assemble/files.go`. The helper resolves through `repo.resolve`
   (tracked files only, symlinks kept inside the root, `files.go:127-145`), since `fileBlock`
   itself checks nothing about tracking (`files.go:221-236`); it returns `fileBlock`'s block (256
   KiB limit) for a tracked file, a "not inlined: untracked" block and never the contents for an
   untracked one, and nothing for a directory source (scaffolded-site-files has two,
   `../../templates/waymark` and `…/src/routes`) or an `http(s)` source. The blocks join the draft
   seat's `Extra` in `draftingBlocks` (`internal/pipeline/blueprint.go:402-423`) only when the seat
   is `draft`; that function's seat switch also serves structure, editor, fact, and coherence, which
   don't get them. Every draft-seat conversation's first turn carries the blocks, the redraft
   exchanges included, since `build` attaches `draftingBlocks` to a conversation's first turn
   (`steps.go:109-120`) and the redraft exchange starts with no history (`steps.go:520`). The
   claude-code page's five `code` sources are the fixture's shape: four under `claude/snippets/`
   and `templates/waymark/.github/workflows/check.yml`.
8. #16's class is wider than three facts. `wrap` is a function expression returned at
   `section-action.ts:180`, and drafter's excerpt resolver matches only a line-start declaration of
   the name after the last dot (`internal/assemble/excerpt.go:86-92,127-128`), so the excerpt
   reads "declaration not found" and the fact seat blocks. 158 dotted anchors in cairn's facts
   store fail the same rule, among them facts the seven cite (`f:ubuj1w`, `f:keuj8l`, `f:t976f1`,
   `f:cvv6to`, `f:21by9u`). The plan re-anchors the three #16 facts to line ranges, as the design
   says, and also any other fact a page of the seven cites whose excerpt the real-context render
   check (task A3) shows as any "no excerpt:" form (`excerpt.go:50-82`: missing, untracked,
   directory, prose, declaration not found). The same failure ended debug-your-site, and the fix
   changes a pointer, never a claim. The widening beyond #16's three is a scope addition, listed in
   the cairn PR's `## Decisions`. The other anchors and drafter's resolver go to the backlogs
   (Close).
9. No `resume.go` edit. `resume.go` has no switch on step names or exchange kinds; it replays a
   pending gate through `coveragePhase` (`resume.go:349-358`). Under finding 2 the small exchange
   needs no record of its origin: both origins end the same way. One exchange kind, `small`, with
   step `stSmall` (`"small"`), coverage phase `covSmall` (`"small"`), and stage token `s6b`, joins
   `coveragePhase`, `exchangeStep`, `exchangeStage`, `coverageStage`, `bound`, `advance`,
   `stepSeats`, `validate`, and `complete`, each of whose `default` silently falls to the draft
   gate-fix path (factsheet-pipeline, section 5), so a missed switch shows only in a test. The
   resumed pending gate, the gate, and the sibling hold (`held.OnGreen`, `check.go:107`) all take
   the phase from the kind, so `covSmall` is reached on every route.
10. #26 changes a fingerprinted value. `fingerprint.go:40` hashes `seat.<name>.max_tokens`, so a
    run started under the stock 64000 refuses to resume after the default moves. cairn sets its own
    128000 (`drafter.toml:24`), so cairn's runs are unaffected; the merge order checks for stopped
    runs. `gate.failure_pattern` is fingerprinted too (`fingerprint.go:27`), so C1's pattern lands
    before any live call.
11. 31 findings, not 30. The record's list holds 31 (scaffolded-site-files lists five imprecise
    against its table's four). All 31 are fixed. Seven of the record's code-line citations are off
    by a few lines; factsheet-cairn section 5 gives the right lines, and each fix cites the line the
    code holds.
12. Wrong claims outside the seven are filed. `docs/reference/log-events.md:74` carries debug #1's
    lapse claim word for word, and `docs/extend/upgrade-cairn.md:101` and
    `docs/reference/sveltekit.md:2100` assume `.dev.vars.example` ships. The rerun doesn't redraft
    them, and they are hand-written pages outside the design, so they go to cairn's backlog with the
    `admin-action.ts:155-157` doc comment, as the design's "Later" does for that comment.
13. The local layer points at the worktree's chain. The copied `drafter.local.toml` keeps every key
    of `~/.config/drafter/cairn-cms.local.toml` and sets `prompts` to the drafter worktree's
    `claude/.claude/workflows/docs-page-chain.js` by absolute path, as B3c did. The pass doesn't
    plan to edit the chain (finding 3), but the runs then use the branch's chain whatever lands, and
    a mid-run change to the main checkout can't reach them.
14. The run order by blueprint length. Smallest first, from current line counts:
    using-claude-code-with-cairn 829, debug-your-site 1277, restrict-admin-access 1387,
    scaffolded-site-files 1485, security-model 1567, add-a-second-sign-in-group 2395,
    add-cairn-to-a-sveltekit-app 2952. The probe is claude-code alone (the smallest, and the
    snippet fixture), wave 1 is the next three, wave 2 the last three. Check 1's page,
    restrict-admin-access, is in wave 1.
15. #25 advances the lock only when the read covered the change since the last accept. A `--since`
    read never consults a bar (`read.go:122-127` skips `readBars`), so an unconditional scoped
    accept would clear a bar whose findings the read never saw, and when the entry's prior
    `accepted` isn't the blueprint at the scope's base, it would certify changes no read judged
    (`skipRead` then trusts it, `draftscope.go:111-114`). So a scoped accept writes `accepted` only
    when the entry holds no `blocked` and its prior `accepted` equals the blueprint's blob at the
    commit the scoped read diffed from; otherwise the entry stays and the stderr line says why. Each
    blueprint's reads before its first accept meet the condition, since A0 step 6 checks that every
    entry holds `BASE`'s blob. A later reread passes `--since` the commit whose blob the entry's
    `accepted` records (STATUS keeps that commit per page as each accept is committed), so the
    condition still holds, and the read sees every blueprint and fact change since that accept.
16. Shared facts tie the seven's reads together. The seven share facts (factsheet-cairn section 6:
    `f:qlgggh` and `f:hwffph` in six, `f:7cv105` in all seven, `f:cvv6to`, `f:nls26c`, `f:qca0t0`
    across pages), and `skipRead` compares only the blueprint blob (`draftscope.go:93,111-114`). A
    fact edited after one citer's read accepted would leave that citer drafting on a fact no read
    judged, and a fact edited after a page drafted moves that page off "up to date"
    (`pageScopeFor`, `draftscope.go:121-142`). Standing answer 8 governs every fact edit after C4.

## Outcome

Five or more of cairn's seven non-figure stage 2b pages hold a draft that drafter accepted, that
passed cairn's docs gate inside its run, and whose lock entry matches, in one cairn PR for Geoff's
read. drafter gains:

- the small-finding rule at the round-2 verdict and at the coverage check's second miss (findings
  2 to 5);
- a `kind` on every review finding (finding 3);
- the snippet inputs (finding 7);
- #23's regression test (finding 6), #25's scoped accept (finding 15), and #26's stock draft ceiling
  of 128000.

cairn gains #14, #15, #16 (with finding 8's widening), #20, the `failure_pattern` fix, and the 31
fact and blueprint fixes.

- Risk class `runner`: drafter's pipeline and gate handling, and cairn's `scripts/checks`.
  `live-account` for API spend only; no GitHub, Cloudflare, or npm account is touched beyond pushing
  two branches and opening two PRs.
- Repos: `glw907/drafter` (tasks A1, A2) and `glw907/cairn-cms` (tasks C1 to C4 and the run; C1 on
  its own branch merged into the run's branch before A3). Merge order: drafter first, then cairn
  with a merge commit.
- Path: the longest chain of tasks run in sequence, a pair counting once at its larger estimate.
  - A0, launch: 30.
  - Build segment: 150. A1 (150) and A2 (85) run as a pair, and the cairn tasks C1 (100) beside
    C2 (60) then C3 (60) run in the same window, so the segment is max(150, 85, 100, 120) = 150.
  - A3, merge, build, and the offline checks: 50.
  - C4, the re-anchors finding 8 calls for: 20.
  - R1, the scoped reads with the citer rereads: 55.
  - R2, the inbound-anchor sweep and the probe: 45.
  - R3, wave 1: 75.
  - R4, wave 2: 90.
  - R5, the reruns: 45.
  - Close: 75.

  The sum is 30 + 150 + 50 + 20 + 55 + 45 + 75 + 90 + 45 + 75 = 635. B3c's waves set R2 to R4; R5
  is on the path because B3c's every page needed one. A batch stall is contingent and off the path.
- Clock file: `pass-task-clock` in the drafter worktree's git dir,
  `/var/home/glw907/Projects/drafter/.git/worktrees/acceptance` (`git rev-parse
  --absolute-git-dir`, run in `.claude/worktrees/acceptance`). During the build segment it holds
  A1's clock. When a pair returns, the session checks each pair task against twice its estimate.
  The named-test check runs once, at A3 step 1: `go test -run '<the task's named tests>' -v` on
  each task's packages, each named test showing `PASS` and none `SKIP`.
- Executor: session `drafter-acceptance`, launched on `claude-opus-5-5` at `medium`, not
  pass-core's Sonnet default, as B3c was: the session judges each live escalation against the stop
  rules, traces causes, and spends live money. Worktree name `acceptance` (branch
  `worktree-acceptance`). Pair subagents' `description` is `acceptance task <id>`; cairn
  subagents' is `acceptance <task id> <page slug or "facts">`. Models:
  - A1 on `opus` at `medium`, per pass-core "Models": it changes the pipeline's stop rules, and the
    plan specifies each rule and test.
  - A2 on `opus` at `medium`: it changes what the lock records.
  - C1 on `sonnet` at `medium` (`cairn-implementer` agent type): three check scripts with unit
    tests, specified below.
  - C2, C3, C3's verifier, C4, and every fix subagent of R1 to R5 run `general-purpose` on `opus`
    at `medium`, each fact or blueprint writer loading the `blueprint` skill first: each writes fact
    or blueprint judgment that a paid read then grades.
- STATUS is the file `acceptance-status.md` in the drafter worktree's git dir, beside the clock
  file. It is never committed. It holds the meter baseline, the host, the binary's path and commit,
  `BASE`, one row per live call (command, N, cap, readings before and after, log file, run id,
  after cell), and the page table.
- Names, written out literally in every command and subagent prompt, never as shell variables:
  - the drafter worktree: `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance`;
  - the binary, built there by `make build`:
    `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter`, written `ACC` in this
    plan only;
  - the cairn worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/acceptance-pages`,
    branch `acceptance-pages`;
  - C1's cairn worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/acceptance-gate`,
    branch `acceptance-gate`, never pushed;
  - `BASE`: the cairn worktree's start commit, recorded in STATUS at A0. Every lock entry of the
    seven equals its blueprint's blob at `517158fae` with no `blocked` (factsheet-cairn section 7),
    so one base serves every scoped read; A0 step 6 checks it again at `BASE`.

### Standing answers

From the design, applied in place of stopping:

1. A plan within 800 path minutes launches unattended once the sweep merges (it has).
2. Live spend up to $50 for the pass runs without asking, as a hard ceiling, metered as below.
3. An escalated page is reported with its finding and stop rule, and the run continues.
4. Loop guards. Every count cap below (reads, reruns, fix rounds) is a loop guard under pass-core
   "Lifecycle" step 1. Past a cap, the run goes on while each retry fixes a cause the session has
   traced and spend stays inside $50, and each fix is a reversible change listed in the cairn PR's
   `## Decisions`. A cause that returns after its fix gets one structural fix: the session replaces
   the unit the patches kept missing (a whole blueprint item, step, or fact bullet) instead of
   patching it again. If it returns after that, the session escalates the item in `## Decisions`
   and goes on.
5. What may escalate. Any single page, while at least five pages can still reach `accepted`. Also
   any page after the bar becomes unreachable (answer 6). It may not escalate drafter's code
   deliverables (the kind and the small-finding rule, the snippet inputs, #23, #25, #26), cairn's
   gate fixes (#14, #15, #16, #20, the `failure_pattern`), or a fact-check fix. A fact-check fix
   that the code shows to be wrong is made to what the code says and recorded in `## Decisions`
   with the file and line. An edit to `money.go` or `fingerprint.go`, the $50 ceiling, the 800-minute
   path ceiling, or a cause the session cannot trace still stops the line.
6. The bar becomes unreachable when three pages are out: escalated with no traced cause left to
   fix, or escalated after their cause returned past its structural fix, or not draftable within the
   budget left. The run then drafts every page that can still accept (an undrafted page, and a rerun
   with a traced cause, inside the budget), skips the rest, closes, and reports the count against
   the bar. That is not a stop.
7. A finding that changes the design, or spend that would pass $50, stops and asks: STATUS carries
   one question, and the executor waits for the conductor (pass-core "Judgment calls").
8. A fact edit after C4 (finding 16). Before the edit, the session runs `ACC refs f:<id>` from the
   cairn worktree for each fact it changes and records the citers among the seven in STATUS. When a
   citer's read has accepted or its page has drafted, the session prefers a fix in the blocked
   blueprint instead. Otherwise the fact is edited, every citer among the seven whose page hasn't
   drafted joins the next read call (R1's reread command, `--since <S>` as R1 defines it, which sees
   the fact change), and a citer whose page already accepted reruns inside the budget under R5 or is
   reported as stale in `## Decisions`. Each such edit is listed in `## Decisions` with its citers.
9. Before the reruns, a tree-mode docs-gate red (cairn's fast lane on a facts or `blueprints/` diff,
   which runs the whole-tree `check:provenance` and `check:docs-gate`) confined to the seven pages'
   live briefs, where they cite a fact C2 or C3 edited, is expected: the session records the lines
   in STATUS and goes on. It is not a stop. A red line on any other file is handled as its task says.
10. A red baseline or whole-tree red that the session traces to this branch's own commits (C1's
    check changes, or `blueprints/` now scanned by `check:leaks`) is fixed forward on the branch
    under answer 4. Only a red that comes from `origin/main` and that the branch can't fix stops the
    line. A gate that exits 75 is re-issued, as Close step 1 says.
11. A page still escalated at close keeps its live page and brief, which cite facts this pass
    changed, and cairn CI's whole-tree docs gate (`test.yml:144`) would go red on them. The session
    makes a minimal hand edit of that page's live sentence and its brief entry to the fixed fact,
    and lists each edit in the cairn PR's `## Decisions`, so CI stays green. A page that drafter
    accepted is never edited by hand.
12. A fact-seat block traced to a snippet the fact seat can't see (finding 7 sends snippets to the
    draft seat only) is a traced mechanical cause: the session fixes it in drafter with a test,
    `make check`, and a rebuild, and the page reruns under answer 4.
13. Geoff's ruling, 2026-10-20 07:40 AKDT, in place of answer 6. The bar is out of reach: six of the
    seven pages escalated, and live spend stands near $37 of $50. security-model's run
    (`20261020T095228Z-57da5ce4`) finishes its round under the run rules. After it, the session
    starts no further live call: R5 is skipped, so claude-code and debug-your-site are not rerun.
    The session goes to Close with what landed, reports the count against the bar, and lists each
    escalation's rule and finding as the evidence record for the next attempt's design.

### The meter

At A0 the session records `/var/home/glw907/.local/bin/drafter spend --since 2026-10-19
--json` (the installed binary; `ACC` doesn't exist yet) in STATUS and in A0's empty commit, and the
drafter PR quotes it. At planning it read `total 86.0216`, `open.worst 0.99695`. Before every live
call, from the cairn worktree:

- run `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter spend --since
  2026-10-19 --json`, fresh;
- `used = total − baseline.total + open.worst`, and `left = 50 − used`;
- at `left <= 0` the call doesn't start, and the run stops and asks (answer 7);
- otherwise the call runs with `DRAFTER_PAGE_CAP` set to `min(10, left / N)` rounded down to the
  cent, where N is the number of blueprints or pages the call takes (for a resume, the run's
  unfinished ones).

The formula is B3c's. B3's cancelled batch holds `open.worst` 0.99695, so that dollar counts against
this pass too and errs safe. The ledger is per machine: another session's spend on `pavilion`
counts against the $50. A resume reads the cap fresh (`fingerprint.go:14-15`), so a resume with no
`DRAFTER_PAGE_CAP` would run at the user layer's 10; every resume below carries it.

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

1. The conductor ran the "Pre-flight" checks just before launch; the session repeats only the
   host line and the cycle headroom, then runs the one-executor checks:
   `pgrep -af '[w]orktrees/acceptance(-pages|-gate)?([ /]|$)'` prints nothing (the bracket keeps
   the pattern from matching its own shell; the planning worktree `acceptance-plan` doesn't
   match); `claude agents --json` shows no session working in drafter or cairn-cms other than the
   conductor, the planning session `drafter-acceptance-plan`, and this session; `git -C ~/Projects/cairn-cms worktree list` shows no `acceptance` worktree. Both main
   checkouts print nothing for `git status --porcelain`, sit on `main`, and print 0 for
   `git rev-list --count HEAD..origin/main` after `git fetch origin`.
2. `EnterWorktree` named `acceptance` in drafter. Arm the API-drop wake-up and the guards
   `~/.claude/docs/unattended-work-guards.md` names. Run the drafter gate once on the fresh tree
   (`DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` through `cairn-run-gate`, re-issued on exit
   75); a red baseline is handled by standing answer 10.
3. Record the meter baseline and the host in STATUS. Commit the baseline on `worktree-acceptance`
   as `git commit --allow-empty` titled "Record the acceptance pass's spend baseline", whose body
   holds only the baseline's `total` and `open.worst` and the date: no path and no host name, since
   drafter is public. The commit keeps the baseline if the git dir's STATUS is lost. A later STATUS
   row that abandons a run is mirrored, run id and `open.worst` only, in the next drafter commit's
   body.
4. Create the cairn worktree: `git -C ~/Projects/cairn-cms worktree add -b acceptance-pages
   .claude/worktrees/acceptance-pages origin/main`. Record its `HEAD` as `BASE` in STATUS. Run the
   cairn-pass setup there: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase &&
   npx svelte-kit sync)`. Create C1's worktree from the same commit:
   `git -C ~/Projects/cairn-cms worktree add -b acceptance-gate .claude/worktrees/acceptance-gate
   <BASE>`; C1's implementer runs its own setup there.
5. Copy `~/.config/drafter/cairn-cms.local.toml` into the cairn worktree as `drafter.local.toml`,
   with `prompts` set to
   `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/claude/.claude/workflows/docs-page-chain.js`
   and every other key as it is (finding 13). Run `drafter config` there: `prompts` shows the local
   layer at that path, `page_cap = 10`, `inline_files` and `gate.index_link_command` from the local
   layer. `git status --porcelain` in the cairn worktree prints nothing (`drafter.local.toml` is
   ignored, `.gitignore:33`).
6. Baseline cairn: `drafter check` reports 0 errors, and `CAIRN_GATE_LANE=light cairn-run-gate 'npm
   run check:facts'` exits 0, both in the cairn worktree. For each of the seven, the lock's entry at
   `BASE` (`git show <BASE>:blueprints/drafted.lock`, read with `yq`) holds `accepted` equal to
   `git rev-parse <BASE>:<blueprint>` and no `blocked`; a mismatch stops the line, since finding 15's
   condition and every scoped read rest on it.

- Files: one empty commit in drafter; the cairn worktree holds no commit yet.
- Risk class `runner`.
- Acceptance: each step's output recorded in STATUS.

### A1: the kind, the small-finding rule, #23's test, and the snippet inputs (150 min), paired with A2, `opus` at `medium`

Outcome: findings 2 to 7 and 9.

- Files: `internal/pipeline/{steps.go,handle.go,check.go,work.go,blueprint.go,record.go}` and new
  files beside them, `internal/assemble/{schema.go,schema_test.go,assemble.go,commands.go,files.go}`
  as needed, `internal/smoke/shapes.go`, `internal/edits/types.go`, their tests, and
  `internal/pipeline/testdata/record.golden.json` (regenerated with `UPDATE_GOLDEN=1`, since the
  record gains `kind`). Not `internal/gate/`, `cmd/`, `internal/config/`, `docs/`, `stock/`, or the
  chain, which A2 owns or nobody touches, so the pair's files are disjoint.
- Never `money.go` or `fingerprint.go`; `resume.go` only per the B3 ruling (finding 9).
- Risk class `runner`.
- Build:
  - The kind (findings 3 and 4). `readAnswer`'s finding, `edits.Finding`, and `findingRecord`
    (`record.go:66-73`) gain `Kind` (`json:"kind,omitempty"` on the record); `readSchema`'s finding
    gains a required `kind` enum of the eleven values, and its contract sentence names each value
    with a one-clause definition. The blueprint read moves to a new answer value that sends today's
    schema and contract bytes and joins every switch finding 3 names. `missFinding` sets `Kind` by
    finding 4's mapping. Kinds compare with `strings.EqualFold`.
  - The small exchange (findings 2 and 9). Exchange kind `small`, step `stSmall`, stage token `s6b`,
    scoped to the open small findings and nothing else, bounded as the redraft is, with its own
    `kind+".contract"` budget row (shared with `refused`, `handle.go:464`). It holds its findings in
    `p.w.Ex` as other exchanges do. After it, the gate, then the coverage check in phase
    `covSmall`. No misses: `p.reviewed()`. A miss: the page escalates with rule `second fix
    verdict` and a detail that opens "after the small-finding fix:". No path after `covSmall`
    leads to another small exchange.
  - The two points. `afterRound2` collects the blocking findings of every seat that answered fix
    (finding 5); at least one blocking finding, every one small, opens the small exchange; anything
    else escalates as today. `afterCoverage` at `covRedraft` maps each miss by finding 4; all small
    opens the small exchange, otherwise it escalates as today. The reader, scoped, and coherence
    rules are unchanged.
  - #23 (finding 6): a test only, no code change.
  - The snippet inputs (finding 7): the exported helper in `files.go` and the draft seat's blocks in
    `draftingBlocks`.
- Tests, table-driven, on the pipeline harness (`newHarness`, the scripted fake API; copy
  `TestSecondRoundFixEscalates`, `flow2_test.go:274`, and `TestCoverageMisses`' "a miss after the
  redraft", `:197`):
  - Round 2 answers fix with only `link` and `handoff` findings: the small exchange runs, the gate
    is green, coverage passes, the page accepts. The small exchange's request carries exactly the
    open small findings, by count, and none of round 1's or the redraft's; the stages after `s6b`
    hold no structure, editor, fact, or reader request.
  - Round 2 with one `voice` finding beside a `link` one: `second fix verdict`, as today.
  - Round 2: structure answers fix with a small finding and fact answers fix with a `claim`: it
    escalates (every seat is weighed).
  - Round 2: a fix whose findings are all non-blocking plus one blocking `heading`: small.
  - Round 2: a fix with zero blocking findings: `second fix verdict`, as today.
  - A finding with an empty kind, and one with an unknown kind: not small. A finding whose kind is
    `Link`: small.
  - `covRedraft` misses of kinds `link` and `brief`: the small exchange runs, the gate and
    `covSmall` pass, and the page accepts with no round-2 request staged.
  - `covRedraft` miss with reason "heading not found": escalates as today.
  - `covRedraft` miss of kind `fact` with the "cites fact" reason: small.
  - The small exchange's coverage still misses, even on small kinds: escalates, rule `second fix
    verdict`, detail opening "after the small-finding fix:".
  - The small exchange's gate stays red past `retries.edit_contract`: `contract`, as other edit
    exchanges do.
  - A run stopped with the small exchange's gate pending resumes into `covSmall` and sends the same
    bytes, from each origin (a regression for finding 9's `coveragePhase` path).
  - A small exchange whose gate red names only a sibling is held, and `regate` releases it into
    `covSmall`, from each origin; the page's next step after `covSmall` is acceptance, never
    `stReader1` or `stRound2`.
  - A state saved before this pass (findings with no `Kind`) decodes and resumes as before.
  - Record: after the small path, `record.json` holds each finding's `kind` (coverage findings
    included), a `writes` entry with kind `small`, and stage `s6b` in `stages`. The regenerated
    `record.golden.json`'s diff adds only `kind` fields and these entries; the commit message
    quotes its `git diff --stat`.
  - Schema: the review answer's finding requires `kind` with exactly the eleven values;
    `TestSchemasKeepToStructuredOutputLimits` covers the new answer value and passes;
    `TestSchemaShapes` gains rows for `AnswerRead`, `AnswerReader2`, and the new blueprint value;
    a blueprint seat with an `inputs` command still carries its command block;
    `TestBlueprintReadRequestGolden` and `TestReadDryRunRequestGolden` pass with both goldens
    unchanged and never regenerated (A1 runs both; A3 runs them again on the merged tree).
  - #23: a full-length synthetic gate log, 200 or more lines, with a `check:symbols` defect line
    naming only a sibling page near its top and `check:snippets` listing lines naming this page,
    parsed with cairn's new `failure_pattern` (the C1 shape, copied as a literal into the test):
    the page is held and spends no fix turn. `TestUnparsedIsOwn`, `TestHeldPageSpendsNoFixTurn`,
    and `TestForeignRedThatPersistsStopsTheRun` pass unchanged. A page held on a sibling's red
    whose sibling then escalates and is restored re-gates green and goes on (`page.go:317-319`).
    A hold that persists beside an accepted sibling stops the run as `tree red`, and the resume
    records the sibling's accepted entry.
  - Snippets: a `code` item whose `source` is a page-relative tracked file puts that file's
    contents in the draft request's `Extra`; the redraft exchange's first request carries it too;
    the structure, editor, and fact requests don't; a `#Symbol` source inlines the whole file; an
    `https://` source and a directory source add nothing; an untracked file gets a "not inlined:
    untracked" block and its contents appear in no request body; an oversize file gets
    `fileBlock`'s size line.
- Acceptance: `make check` green in the pair worktree. Each row above, by test name, shows `PASS`
  under `go test -run '<names>' -v` at A3. The commit message names the tests, every switch the new
  exchange kind joined, and every switch the new answer value joined.

### A2: the scoped accept, the stock ceiling, and the docs (85 min), paired with A1, `opus` at `medium`

Outcome: #25 (finding 15), #26, and the docs for every drafter change in this pass.

- Files: `cmd/drafter/{bar.go,read.go,pagebp.go}` and their tests, `e2e/readbar_test.go`,
  `internal/pipeline/pipeline.go` (the `PageResult` field only; A1's list doesn't name it, so the
  pair stays disjoint),
  `internal/config/{stock.toml,stock_test.go}`, `docs/blueprint-format.md`, `docs/configuration.md`.
- Risk class `runner`.
- Build:
  - #25: a scoped accept writes `accepted` (the blueprint blob at the run's start) and drops
    `blocked` only under finding 15's condition, in `drafter read` and in `drafter page`'s
    `recordDrafted`, so a drafted entry after such an accept carries the new blob (`pagebp.go:192-200`
    reads `prior.Accepted` after `recordReads`; the comment at `:179-182` follows). The stderr line
    "accepted on a scoped read; drafted.lock keeps its earlier entry" stays for the refused case,
    reworded to give the reason (a bar, or a prior accept that isn't the blueprint at the scope's
    base). `read --help` (`read.go:51-57`) says what the accept writes and when.
  - The condition's base. `PageResult` gains a `Since` string field (JSON key `since`, omitempty), set from
    `p.w.Since` where `Summary` builds each result (`pipeline.go:268`), so a resumed read carries
    its base. `drafter read` compares the prior `accepted` with `git rev-parse
    <r.Since>:<blueprint>`. In `drafter page`, the read's base is the entry's own `blueprint`
    (`draftscope.go:136`), so the condition there is a prior `accepted` equal to the prior
    `blueprint`.
  - #26: `[seat.draft] max_tokens = 128000` in `stock.toml`, and `docs/configuration.md:292` and
    `:417` follow.
  - Docs: `docs/blueprint-format.md` ("What `drafter page` does with a blueprint" and `:557`) states
    the scoped accept and its condition, the small-finding rule (from findings 2 to 5 of this plan:
    which kinds are small, where the rule applies, and that the page then accepts on the gate and
    the coverage check), the snippet inputs, and the sibling hold, in the docs' existing register.
    These are the behavior-sync edits the `blueprint` skill's "code changes documented behavior"
    rule requires, not the drafter-docs pass the design defers.
- Tests:
  - `TestRecordReads`' row "a scoped accept with no bar keeps the old accepted" becomes two rows:
    "advances accepted and drops blocked" when the prior accept is the blob at the scope's base,
    and "keeps the entry" when it isn't; a third row, "an entry with a bar keeps its bar", for a
    scoped accept against an entry that holds `blocked`. `TestScopedAccept`, the `read_test.go`
    subtest at `:577-597`, and `e2e/readbar_test.go:81,105` follow.
  - `drafter page` with a scoped accept at s1: the lock entry's `accepted` equals the blueprint's
    blob at the run's start commit.
  - A read stopped after a scoped accept and resumed with its paths advances `accepted` when the
    condition holds (the `read_test.go` resume subtest at `:720-748` gains a committed prior
    entry), and keeps the entry when it doesn't.
  - A bar accept and an unscoped accept behave as today (regression).
  - `stock_test.go:33` reads 128000.
- Acceptance: `make check` green in the pair worktree; each row by test name shows `PASS` at A3.
  The golden checks bind at A3, on the merged tree.

### C1: cairn's gate fixes (100 min), in the build window, `cairn-implementer` on `sonnet` at `medium`

Outcome: cairn backlog #14, #15, #20, and finding 6's `failure_pattern` half.

- Works in C1's own worktree, `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/acceptance-gate`,
  where it runs its setup, its fast lane, and its commit as its agent definition says, so no
  `npm ci` of its runs under C2's or C3's checks. It never pushes. The session merges
  `acceptance-gate` into `acceptance-pages` with `git merge --no-ff` at A3 step 2.
- Files: `scripts/checks/check-provenance.mjs`, `scripts/checks/check-symbols.mjs`,
  `scripts/checks/check-leaks.mjs`, `src/tests/unit/check-{provenance,symbols,leaks}.test.ts`,
  `drafter.toml` (`failure_pattern` only), `BACKLOG.md` (closing #14, #15, #20).
- Risk class `runner` (`scripts/checks`).
- Build (factsheet-cairn sections 1 to 3):
  - #14: a code span inside a Markdown link's text is navigation, not a claim, so a no-claim
    sentence may name `[`createAuthGuard`](...)` or `[The `site-facts.json` contract](...)`.
    `PROSE_COMMAND_RE` (`:151`) no longer reads `npm <word>` as a command unless the word is an npm
    subcommand; `npx`, `pnpm`, and `yarn` keep today's rule.
  - #15: `extractFilePaths` skips a token whose source character just before `m.index` is `#`,
    since the tokenizer `/[\w./@-]+/g` (`check-symbols.mjs:314`) never includes `#` in a token:
    `#lib/...` is a package import specifier, not a repository path.
  - #20: `blueprints` joins `SCAN_ROOTS`, and `profileFor` maps `blueprints/` to the tier of
    `docs/internal/briefs`, outlines, and facts (T3, classes C1, C2, C4), which finds 0 today.
  - `failure_pattern` also matches the `check-symbols` defect line shape (two spaces, a path, a
    line number, two spaces, a bracketed class), for example `^  \S+:[0-9]+  \[[a-z-]+\]  `, so a
    `check:symbols` red parses.
- Tests:
  - `extractFacts` on "See [`createAuthGuard`](../reference/x.md)." in a no-claim sentence: no fact.
    B3c's scaffolded-site-files sentences 152 and 225, copied from gate-1's lines into the fixture
    (synthetic paths only): no linked-name fact.
  - A code span outside a link in a no-claim sentence still fails (regression).
  - "Install the npm package first." extracts no command; "Run `npm run build`" and "npm install"
    in prose still do.
  - `extractFilePaths` on `#lib/cairn.config.js`: no path; `src/lib/x.ts` still resolves
    (regression).
  - `profileFor('blueprints/docs/extend/x.blueprint.yaml')` returns the T3 profile, and
    `runLeakCheck` over a temporary root whose `blueprints/x.blueprint.yaml` holds a T3-class leak
    (a home-directory path) flags it; the test fails without the `SCAN_ROOTS` change.
  - The session runs the new `failure_pattern` through Go's `regexp` (a scratch
    `regexp.MatchString` program in the scratchpad, since drafter compiles it with Go,
    `internal/gate/run.go:183`) over B3c's saved
    `20261019T233356Z-01abf04b/docs--extend--security-model/gate-4.log` and
    `…/docs--extend--add-a-second-sign-in-group/gate-4.log` (in drafter's state directory). The
    matches are exactly line 50 in each, and no `check:snippets` listing line
    (`  docs/…md:NN  <reason>`) matches.
- The replay, by the session once C1 commits (10 min, in the build window): in a scratch shared
  clone of `acceptance-gate`'s head, copy B3c's `final.page.md` and `final.brief.json` of
  scaffolded-site-files (run `20261020T023009Z-7a23e89e`), add-cairn-to-a-sveltekit-app, and
  add-a-second-sign-in-group (run `20261019T233356Z-01abf04b`) to their tree paths
  (`docs/extend/<name>.md`, `docs/internal/briefs/extend/<name>.json`), run `node
  scripts/checks/check-provenance.mjs <the three brief paths>`, and record in STATUS the hits left,
  counted by class ("marked no-claim but states the name", "the path", "is in no cited fact",
  command). That turns the Outcome's "cairn's gate passes the prose it flagged" into a number, and
  predicts which pages still need gate-fix rounds. Delete the clone.
- Acceptance: `npx vitest related --run --passWithNoTests --project unit <the six files>` green
  through `cairn-run-gate`; the cairn fast lane's line 1 green in C1's worktree after its commit
  (`node scripts/checks/gate-tier.mjs --fast --range <BASE>..HEAD`, a non-empty range there); its
  component line 2 run with `RUN_GATE_IF_BUSY=defer`, since cairn CI is the full-suite home and no
  task touches `src/lib` or a component. Standing answer 10 covers a red from `blueprints/` now
  being scanned.

### C2: the facts store edits (60 min), in the build window, `general-purpose` on `opus` at `medium`

Outcome: every fact-side fix among the 31, and #16's three re-anchors.

- One agent for the whole store, because the fixes share `docs/internal/facts/extend.md`,
  `reference.md`, and `admin.md`. It works in the cairn worktree by absolute path, loads the
  `blueprint` skill, edits only `docs/internal/facts/*.md`, and never commits.
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
  its finding number. The session then commits C2 alone, with `git commit` on the facts pathspec
  ("Fix the fact-check findings in the facts store"), whose body maps each fact-side finding to its
  fact, before C3 dispatches.

### C3: the blueprint edits and their verification (60 min), after C2, seven `general-purpose` subagents on `opus` at `medium`, then one verifier

Outcome: every blueprint-side fix among the 31, one subagent per page, and an independent check of
all 31 against the code.

- Each subagent loads the `blueprint` skill and edits only its page's blueprint under
  `blueprints/docs/`, in the cairn worktree by absolute path. Its prompt carries its page's findings
  verbatim from the evidence record, its rows of factsheet-cairn section 5 with the item ids, C2's
  fact list, and, for every fact C2 changed that its blueprint cites, that fact's row of
  factsheet-cairn section 6 with "reconcile each citing item's text with the fact as C2 left it".
  It places the unplaced facts its page needs (`f:147zhc` for debug #3, `f:yio35u` for add-cairn
  #2, `f:xothz1` for security #3), and for debug #1 also names public admin paths
  (`isPublicAdminPath`, `guard.ts:297`, `:359`).
- Every subagent runs `/var/home/glw907/.local/bin/drafter check <its blueprint>` and gets 0
  errors before it returns. It never runs `drafter read` or `drafter page`, and never edits
  `drafter.toml`, `drafted.lock`, facts, outlines, or pages. The seven edit disjoint files and run
  only read-only checks, so they share the cairn worktree safely.
- The verifier (15 min), once the seven return: one fresh-context `general-purpose` subagent on
  `opus` at `medium`, read-only, no API spend. Its prompt carries the 31 entries of the evidence
  record, factsheet-cairn section 5's "Code on main" column, and the output of these absence
  greps, run by the session in the cairn worktree:
  - `grep -n 'separate \`--connect\`' blueprints/docs/extend/scaffolded-site-files.blueprint.yaml`
  - `grep -n 're-includes' docs/internal/facts/extend.md`
  - `grep -n 'lapsed between the guard' docs/internal/facts/reference.md`
  - the `f:qlgggh` bullet, grepped for `LICENSE` and `.dev.vars.example`
  - the `f:cvv6to` bullet, grepped for `except the two`

  For each of the 31 it returns fixed or not fixed, with the edited fact or item line and the code
  line, and it explains each grep hit. A not-fixed result, or a grep hit that restates a wrong
  claim, goes back to the page's subagent (or, for a fact, to a C2-style fix of that bullet) before
  the commit.
- The session commits C3 ("Fix the fact-check findings in the blueprints"), whose body maps each
  blueprint-side finding to its item and names C2's commit for the rest, so the two bodies cover
  all 31, after `git status --porcelain` names only the seven blueprints (and any fact bullet the
  verifier sent back, listed in the body).
- Risk class `runner`.
- Acceptance: `drafter check` 0 errors over the tree; the verifier's 31 rows all read fixed; the
  cairn fast lane's line 1 run in the cairn worktree with `--range <BASE>..HEAD`, its red handled
  by standing answer 9 and its line 2 deferred as in C1; the two commit bodies' maps cover 31
  findings.

### A3: merge, build, and the offline checks (50 min), by the session

1. Merge A1 and A2. Run the named-test check (see "Clock file"), including
   `TestBlueprintReadRequestGolden` and `TestReadDryRunRequestGolden` with both goldens unchanged,
   then `make check`, then `make build`. Record `ACC`'s commit in STATUS. `ACC` is rebuilt after
   any later drafter fix, and every STATUS row names the commit its call ran.
2. In the cairn worktree, `git merge --no-ff acceptance-gate` (C1's commit), then:
   - `ACC config` shows `prompts` at the worktree chain and `blueprints.brief_path`;
   - `ACC check` reports 0 errors;
   - `ACC check-prompts --matrix
     /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/tests/fixtures/drafter/blueprint-matrix.json`
     exits 0 (it renders with cairn's local layer, which `make check`'s parity run doesn't);
   - the docs gate offline on one page:
     `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:docs-gate -- --page
     docs/extend/restrict-admin-access.md --brief docs/internal/briefs/extend/restrict-admin-access.json'`
     is green, or red only on that page's own live-page defects the rerun will replace or on the
     live briefs standing answer 9 names. A whole-tree component red goes to standing answer 10;
     one it can't fix stops the line, since no draft could pass;
   - `git status --porcelain` prints nothing.
3. The real-context render check, which spends nothing, as B3c.5 step 4 ran it: a shared clone of
   the cairn worktree's head in the scratchpad (`git clone --shared`) with the local layer copied
   in; one lock edit there, committed in the clone, setting each of the seven entries' `accepted`
   to its blueprint blob (the dry run reads the committed lock, `draftscope.go:80`, and refuses a
   dirty tree, `start.go:128`); a local stub that records each request body and answers
   `/v1/messages/count_tokens` with `{"input_tokens": 1000}` and the models list with the
   configured `anthropic-workspace-id` header (`batch/client.go:81-106`); `DRAFTER_API_BASE_URL`
   pointed at it with a dummy `DRAFTER_API_KEY`; and `ACC page --whole --dry-run --json` over the
   seven pages. Each exits 0. Then grep the recorded bodies:
   - claude-code's draft body holds `=== file: claude/snippets/claude-md-import.txt ===`,
     `=== file: claude/snippets/settings-hook.json ===`, `=== file: claude/snippets/check-cairn.json ===`,
     `=== file: claude/snippets/check.yml ===`, and
     `=== file: templates/waymark/.github/workflows/check.yml ===`, and no structure, editor, or
     fact body holds any of them;
   - no body holds `undefined`, `.plan.yaml`, `.plan.md`, `.framing.md`, or `worktree`;
   - list every excerpt block reading `no excerpt:` (any form) and the fact id it belongs to, into
     STATUS, for C4.
   Delete the clone and stop the stub.

- Risk class `runner`.
- Acceptance: each step's output as stated, recorded in STATUS.

### C4: the excerpt re-anchors (20 min), by one `general-purpose` subagent on `opus` at `medium`

Outcome: finding 8. Each fact A3 listed has a source pointer drafter's excerpt resolves, with its
claim unchanged.

- Files: `docs/internal/facts/*.md` only. When A3 listed none, the task is skipped and STATUS says
  so.
- Acceptance: a rerun of A3 step 3's grep lists none; `ACC check` (no argument, so the facts store's
  pointers are checked too) 0 errors; `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:facts'`
  exits 0; one commit, "Re-anchor the facts drafter can't excerpt", whose `git show --name-only`
  names only facts files.

### R1: the scoped reads (55 min), by the session with fix subagents

Outcome: design item 4. Each of the seven blueprints has a read whose summary status is `accepted`
and a lock `accepted` equal to its current blob, or is escalated and out of the waves.

- Live, `--sync`, under the meter, in the background (Run rules). From the cairn worktree, after a
  fresh meter reading, the first call is:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/7)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter read --since <BASE> --sync --json blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml blueprints/docs/extend/debug-your-site.blueprint.yaml blueprints/docs/extend/restrict-admin-access.blueprint.yaml blueprints/docs/extend/scaffolded-site-files.blueprint.yaml blueprints/docs/extend/security-model.blueprint.yaml blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml
  ```

  The session commits the lock at once ("Record the scoped reads"). Each scoped accept now writes
  `accepted` (finding 15), so the waves' `--whole` runs skip the read (`skipRead`,
  `draftscope.go:89-114`).
- A blocked read: a fix subagent edits that one blueprint (or, for a fact the read names, the fact,
  under standing answer 8), runs `ACC check <its blueprint>` for a blueprint edit, or `ACC check`
  with no argument and `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:facts'` for a fact
  edit, gets 0 errors and exit 0, and returns without committing. The session checks
  `git status --porcelain`, commits the round, and reads again every still-blocked blueprint plus
  every citer standing answer 8 adds, after a fresh meter reading:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter read --since <S> --sync --json <each blueprint path to read, written out>
  ```

  with N the number of paths. Every new read passes `--since <S>`, where `S` is `BASE` for an
  entry still at `BASE`'s blob, and otherwise the commit STATUS records for that entry's last
  accept; a call mixing the two runs as two calls. A read without `--since` reads the whole
  blueprint (B3c's stop 3). A resume can't take `--since` (`read.go:72-74`), so a stopped read
  resumes on the run's recorded scope with:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter read --resume <id> --sync --json <the run's blueprint paths, written out as the call that started the run gave them>
  ```

  with N the run's unfinished blueprints. A resume takes the run's own paths, copied from the
  STATUS row of the call that started it. They match the resume line drafter prints. `read`
  refuses a resume with no blueprint, and `page` with no path reads its arguments as handoff
  files.
- Three reads per blueprint is the loop guard (standing answer 4). A read that escalates on a
  consistency conflict between two facts is a traced cause when C2's edit made the conflict, and is
  fixed in the fact; otherwise the page escalates.
- Check after: for each page in the waves, its latest read's summary status is `accepted`, and the
  lock's `accepted` equals `git rev-parse HEAD:<blueprint>`; for each fact changed since the first
  read, every citer among the seven has an accepted read in STATUS after the change. A blueprint
  whose latest read blocked is out of the waves, even when its lock entry already matches (a
  blocked change read writes nothing, `bar.go:85-90`).
- Risk class `runner`. Files (cairn): the seven blueprints, facts files a read names, the lock.

### R2: the inbound-anchor sweep and the probe (45 min), by the session

Outcome: every inbound link into the seven names an anchor its blueprint produces; claude-code
drafted, accepted or escalated; a mechanical fault found on the smallest page.

1. The inbound-anchor sweep, B3c's pre-run fix, once for all seven before any page drafts: every
   link in `docs/` outside the seven pages into `<page>.md#<anchor>` must name an anchor the
   page's blueprint section headings produce. A link that doesn't is retargeted to the nearest
   section and committed before the run. A link inside one of the seven is left alone, since that
   page's own draft rewrites it, so no sweep ever edits a drafted page.
2. A fresh meter reading, then, for claude-code if its R1 read accepted:

   ```
   DRAFTER_PAGE_CAP=<min(10, left)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/claude-code/using-claude-code-with-cairn.md
   ```

3. Accepted: commit the page, its brief, any index file the index-link command changed, and the
   lock in one commit; then run Check 3 on it. Escalated: report it in STATUS with its rule,
   finding, kinds, and run id. A mechanical cause in drafter (a step errors, a prompt names a
   missing file, the snippet block is absent) is fixed in the drafter worktree with a test,
   `make check`, and a rebuild before R3, and the page reruns in R5.

- Live, batch, in the background. Only a page whose R1 read accepted is drafted. Risk class
  `runner`.

### R3: wave 1 (75 min), by the session

Outcome: debug-your-site, restrict-admin-access, and scaffolded-site-files drafted. Check 1 on
restrict-admin-access.

1. A fresh meter reading, then:

   ```
   DRAFTER_PAGE_CAP=<min(10, left/3)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/extend/debug-your-site.md docs/extend/restrict-admin-access.md docs/extend/scaffolded-site-files.md
   ```

   (fewer paths, and N to match, when a page's R1 read didn't accept).
2. Before the commit, the session greps each escalated page's `record.json` for `index-link:`
   friction and confirms the index diff names only accepted pages. The accepted pages, their
   briefs, their index edits, and the lock go in one commit, then Check 3. Each escalated page is in
   STATUS with its rule, finding, kinds, run id, and whether the small path ran (its
   `record.json`). A mechanical cause is fixed before R4, as R2 says.

- Live, batch, in the background. Only pages whose R1 read accepted are in the call. Risk class
  `runner`.

### R4: wave 2 (90 min), by the session

Outcome: security-model, add-a-second-sign-in-group, and add-cairn-to-a-sveltekit-app drafted.

1. With the real key, `/var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page
   --whole --dry-run --json docs/extend/add-cairn-to-a-sveltekit-app.md` (a dry run sends only
   `count_tokens` and writes no ledger line); record the first stage's worst case against the cap
   in STATUS, so a predicted `cap` escalation is reported as predicted.
2. A fresh meter reading, then:

   ```
   DRAFTER_PAGE_CAP=<min(10, left/3)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/extend/security-model.md docs/extend/add-a-second-sign-in-group.md docs/extend/add-cairn-to-a-sveltekit-app.md
   ```

   (fewer paths, and N to match, when a page's R1 read didn't accept).
3. Commit and Check 3 as R3.

- Live, batch, in the background. Only pages whose R1 read accepted are in the call. Risk class
  `runner`.

### R5: the reruns (45 min), by the session

Outcome: each escalated page whose cause the session traced and fixed takes one more run, inside
the budget.

- Which pages rerun:
  - a fault (a seat answer cut at `max_tokens`, an answer that doesn't parse, an API failure): once,
    alone;
  - `cap`: once, alone, as a fresh batch run at the cap the meter allows;
  - a mechanical cause fixed with a test in drafter (standing answer 12 included), or a blueprint or
    fact cause fixed in cairn and read again with R1's reread command (its own path, plus every
    citer standing answer 8 adds, `--since <S>`), or an inbound link retargeted after "tree red
    outside drafter's pages": once more, under standing answer 4;
  - a verdict escalation whose finding is the draft's own writing and traces to no blueprint, fact,
    or drafter cause: not rerun; the page is out.
- Each rerun, after a fresh meter reading, of a page whose latest read accepted:

  ```
  DRAFTER_PAGE_CAP=<min(10, left)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --json docs/<arm>/<page>.md
  ```

- Every first draft of the seven runs before any rerun spends.
- Commit and Check 3 as R3. Live, batch, in the background. Risk class `runner`.

### Run rules for R1 to R5

- The tree. A run needs a clean tree at its start (`start.go:88`). The session commits before each
  live call and never edits the cairn worktree while a run is live. A drafted page or brief is
  never edited by hand afterward (Check 3).
- Background. drafter has no signal handling, and the Bash tool's foreground call ends at 10
  minutes, so a killed run stays `running` with its batch live and its reservations open (B3c's
  stall rule). Every live `ACC read` and `ACC page` call, resumes included, runs with
  `run_in_background: true`, its stdout to
  `/var/home/glw907/Projects/drafter/.git/worktrees/acceptance/live-<row>.json` and its stderr to
  `…/live-<row>.log`, both named in the call's STATUS row. The row gets the run id from the log
  as soon as it prints. Before any resume, `pgrep -af '[a]cceptance/drafter (page|read)'` shows the
  original process has exited; the run lock (`run.TryLock`, `resume.go:51`) refuses a second
  process anyway.
- Recovery, the binary, and the stall rule are B3c's resolutions 6 and 8, with `ACC` in place of
  `$B3C_DRAFTER` and this pass's worktrees. Each resume runs on a fresh meter reading and never in
  another mode. A stopped batch page run resumes with:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --resume <id> --json <the run's page paths, written out as the call that started the run gave them>
  ```

  and a stopped read with R1's resume command, N the run's unfinished pages or blueprints. Before a
  stall-rule restore, STATUS lists each page the run's `state.json` marks accepted, and the stall
  rule's `--sync` rerun includes them:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --whole --sync --json <each page path, written out>
  ```

- A resume uses the binary the run started on. `state.json`'s `drafter_version` ends in the
  commit's first 12 hex digits (`start.go:136`, `run/state.go:22`); when it differs from the `ACC`
  commit in STATUS (a rebuild came between), the run is abandoned, its `open.worst` recorded in
  STATUS and in the next drafter commit's body, and its pages rerun fresh. Nothing reads that field
  on resume today; a drafter backlog item is filed (Close).
- While any run in STATUS is stopped and not abandoned, nothing is committed in the cairn worktree
  but that run's own outputs, since a resume loads facts from the working tree
  (`plan.LoadFacts`, `resume.go:73-77`) and accepts any descendant HEAD (`resume.go:104-108`).
- A run that stops as `tree red` (`pipeline.go:452-453`) writes no lock (`pagebp.go:186-188`) and
  restores nothing. The session traces the red. When it lies outside the run's pages (an inbound
  link in another doc), the session fixes that file, resumes the run with the page resume command
  so the accepted pages record their entries, and only then commits the fix, a planned exception
  to the rule above since the fix touches no fact or outline. When it lies in a held page's own
  draft, the session abandons the run, records in STATUS which pages `state.json` marks accepted,
  restores the tree to HEAD after printing `git status --porcelain` and `git clean -n`, and reruns
  those pages.
- The rule a page ended on comes from its run's summary and `record.json`: the rule, the seat, the
  finding, the kinds, and whether a small exchange ran. STATUS keeps it per page, and for every
  finding a small exchange answered, its text verbatim, its kind, and its seat.

## Checks

Each row maps to the design's "Check".

- Check 1. restrict-admin-access's R3 run summary shows `accepted`, which is the design's "ending on
  no link or handoff finding". Its lock entry holds `accepted` equal to
  `git rev-parse HEAD:blueprints/docs/extend/restrict-admin-access.blueprint.yaml`. It spent no
  round on a provenance hit the fixed check no longer raises: no `gate-<n>.log` in its run
  directory that precedes a `gate_fix: true` entry of `record.json`'s `writes` contains `marked
  no-claim but states the` for a name or path inside link text, or `"npm package"`. When it
  escalates, the row reports the rule and finding, and the PR says Check 1 is unmet.
- Check 2. Each of the seven ends `accepted`, or `escalated` with its rule, finding, and run id; the
  count meets five, or the PR reports the bar unmet. At close, on the close head, the session runs
  `npm run package` once, then for each accepted page `CAIRN_GATE_LANE=light cairn-run-gate 'npm
  run check:docs-gate -- --prebuilt --page <page> --brief docs/internal/briefs/<arm>/<name>.json'`,
  exit 0. claude-code's row names the gate components that skip `docs/claude-code` (B3c finding 3).
  Then, for each accepted page, `grep -n` for each of the six wrong claims' phrases:
  `.dev.vars.example`, `LICENSE`, `!.dev.vars.example`, ``separate `--connect` ``, `lapsed`, and
  `tidy` or `dictionary` within a sentence of "outside". The session reads each hit against the
  fixed fact; a hit that restates a wrong claim fails the row and is reported, never hand-fixed.
- Check 3. Run at `HEAD` after each accepted page's commit, at close, and again after every commit
  made after Close step 3, the PR body quoting the last run. Each accepted page's entry: `page`
  equals `git hash-object <page>`; `blueprint` equals `git rev-parse HEAD:<blueprint>`; `accepted`
  equals `blueprint`; no `blocked`; and `ACC page --dry-run --json <page>` prints "up to date with
  drafted.lock".

## Close (75 min)

1. drafter: the gate on the close head from the worktree, `DRAFTER_DIR="$PWD" bash
   scripts/drafter-gate.sh` through `cairn-run-gate`, re-issued on exit 75. drafter has no CI, so
   this is its full-suite home.
2. One whole-branch `diff-reviewer` read of each branch against this plan and the design: drafter's,
   and cairn's (scripts/checks, `drafter.toml`, the facts, the blueprints). If any commit touched
   `resume.go`, the drafter read confirms its task-scope read happened. `prose-voice-reviewer` reads
   drafter's changed `docs/` pages. One batched fix chain follows, then the gates again; a second
   review only on a blocker. A fix dispatch quotes each finding verbatim as its acceptance. A fix
   to a drafted page or brief is never made by hand: the page reruns inside the budget or the
   finding is reported. A fix to the facts, an outline entry, or the blueprint an accepted page
   uses is likewise reported and filed, not made, unless that page reruns inside the budget.
3. cairn, before the push, with `ACC` rebuilt from the drafter close head: `ACC check` 0 errors;
   standing answer 11's hand edits for each page still escalated, committed as "Align the escalated
   pages' live text with the fixed facts"; then Check 2's close rerun and Check 3, once each.
4. The leak check, over both branches and both PR bodies: the added lines of `git diff
   origin/main...HEAD` in each repo (`grep '^+'`), and each PR body file before `gh pr create`,
   grepped for `/home/`, `/var/home/`, `thinkpad-x1`, `pavilion`, `.claude/worktrees`,
   `~/.local/share/cairn`, and `cairn-cms.local.toml`, print nothing. The bare `~/.config` and
   `~/.local` prefixes stay out of the pattern: drafter's `docs/configuration.md:13,118` and cairn's
   scaffolded-site-files page (`:514`) document `~/.config/drafter/config.toml`,
   `~/.local/state/drafter`, and `~/.config/cairn/sites/<id>.json` as product paths.
5. cairn: push `acceptance-pages` to `glw907/cairn-cms` and open a draft PR. Run `ci-green <sha> --pr
   <n> --wait` in the background. A red from this branch's files is fixed on the branch, except a
   red on a drafted page or brief, which is reported or rerun with `--whole` inside the budget, and
   a fix to an accepted page's inputs, which Close step 2's rule governs. A red elsewhere is
   reported. Check 3 reruns after each fix commit.
6. drafter: push `worktree-acceptance` to `glw907/drafter` and open its PR.
7. Each PR body opens with `## Brief`, per `~/.claude/docs/voice/approval-brief.md`.
   - The drafter PR: what landed; the acceptance table, one row per offline check; the live spend
     and meter readings; any abandoned run id with its `open.worst`; every departure from this plan;
     any `resume.go` verdicts; `## Decisions`, which states finding 2's cost; the score per
     pass-core "Score", with Work and review naming 635 path minutes beside the actual.
   - The cairn PR: the seven-page table (status, rule, finding and its kinds, whether the small path
     ran, run id, cost, read count, gate coverage); the accepted count against five; Check 1's row;
     Check 2's rerun, its wrong-claim greps, and Check 3; C1's replay counts; the drafter commit each
     live call ran; the 31-finding map with each fix's commit; every finding that took the small
     path, verbatim, with its kind and seat, from STATUS; `## Decisions`, which states finding 2's
     cost, finding 8's widening, standing answer 8's fact edits, and standing answer 11's hand
     edits.
   - Each PR links the other and states the merge order below.
8. Backlogs, through `log-issue`, tagged `#initiative:docs-system`, each listed in its PR body:
   - drafter: close #23, #25, #26; file "resolve a dotted excerpt anchor to a nested declaration"
     (finding 8, `internal/assemble/excerpt.go:86-92`); file "refuse a resume on a binary other than
     the run's `drafter_version`"; file "`LockIntroducedAt` across merge commits (`--first-parent`)"
     (`blueprint/drafted.go:41-60`).
   - cairn: close #14, #15, #16, #20; file the wrong claims outside the seven (finding 12:
     `docs/reference/log-events.md:74`, `docs/extend/upgrade-cairn.md:101`,
     `docs/reference/sveltekit.md:2100`) and the `admin-action.ts:155-157` doc comment; file the
     remaining dotted anchors drafter can't excerpt; file a gate-table bucket for `blueprints/`
     (factsheet-cairn section 10: today a blueprint edit selects every static check and the
     component suite).
9. Remove C1's worktree and branch: `git -C ~/Projects/cairn-cms worktree remove
   .claude/worktrees/acceptance-gate`, then `git -C
   /var/home/glw907/Projects/cairn-cms/.claude/worktrees/acceptance-pages branch -d acceptance-gate`
   (that worktree's HEAD holds the merge, so `-d` succeeds).
10. Stop at PR-ready for both PRs. The executor never runs `approval-queue`; `conductor-drafter`
    hands the packet to Geoff.

## Merge order

1. glw907/drafter's PR first, with `--match-head-commit` from the decision. Then pull
   `~/Projects/drafter`. Check for unfinished runs: every `~/.local/state/drafter/runs/*/*/state.json`
   with a `stopped` key, or with a page whose status is `running`, `pending`, or `held`, minus the
   abandoned run ids the PR lists and minus runs older than this pass that the PR names as known
   (finding 10: a run started under the stock 64000 can't resume after the merge). On a hit, hold
   `make install` and name the run in the merge report. Otherwise `make install` from the main
   checkout. The other workstation pulls and runs `make install` before it runs drafter on cairn.
2. glw907/cairn-cms's PR second, after Geoff reads the pages, with a merge commit, never squash or
   rebase; the session never rebases `acceptance-pages`. A conflict in `blueprints/drafted.lock`
   stops the merge and is reported, never resolved by hand. Then pull `~/Projects/cairn-cms` and run
   `drafter page --dry-run --json` on main over the accepted pages: each prints "up to date with
   drafted.lock", or the merge report files the mismatch.

## Later

Kept out of this pass and never built here:

- Rotate, the three figure pages, drafter's own docs, O, B4, and B5 (design, "Shape").
- A code-grounded fact check (design, "Later").
- drafter backlog #24 (keep a heading another page links to); the inbound-anchor sweep stands in.
- drafter backlog #27 (a moved `Source:` path counts as a changed fact); every draft here is whole.
- The chain's own Workflow path labeling findings by kind; drafter's runs get the label from the
  schema (finding 3).
