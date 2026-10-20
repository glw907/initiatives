# drafter blueprint-first plan: a dependable blueprint before any draft

Initiative: docs-system

Path estimate: 1080 minutes against the design's 540 (2.0x), at the 1080-minute standing
answer. The arithmetic is under "Outcome"; it counts one tuning round and B's whole loop on the
path. The plan reviews and their fold are in
`docs-system/research/2026-10-20-drafter-blueprint-first-plan-review-{contract,mechanics,integrity}.md`,
`…-plan-fold.md`, and `…-plan-fold-verification.md`.

Design: `~/Projects/initiatives/docs-system/specs/2026-10-20-drafter-blueprint-first-design.md`,
approved by Geoff on 2026-10-20 (glw907/initiatives#67, merge `b709a77`). He raised
`cycle_ceiling` to 200 (done: `~/.config/drafter/config.toml:3`) and ruled the four owner calls:
the gate's four checks; judging on the API through drafter and every other step on session tokens,
so long as the loop on API credit does the hand check's job; the eight existing blueprints plus a
blueprint built from scratch for `docs/extend/turn-on-tidy.md` as the proving ground; and the
acceptance machinery left to the next pass. The format may change where the build meets friction
(latitude, not a directive). The blueprint skill must come out well-tuned. A perfectly crafted
blueprint is built once, so the tidy build takes the rounds it needs.

The B3 rulings carry over: `internal/pipeline/money.go`, `internal/pipeline/fingerprint.go`, and
`internal/pipeline/resume.go` are never edited. No task needs any of them (factsheet-pipeline
section 8).

Factsheets, read-only, written by the planning session at drafter `6a42564` and cairn-cms
`52b3f979e` (read each by the section a task names, not whole at launch):
`docs-system/research/2026-10-20-drafter-blueprint-first-factsheet-pipeline.md`
(drafter's lock, cited sets, read seats, excerpts, read mode, covers, untouchables, tests, costs),
`…-factsheet-prompts.md` (the prompts modules, `cairn-docs-outline`, the skill), and
`…-factsheet-cairn.md` (the eight blueprints and their lock entries, the 25 bullets and their old
excerpts, cairn backlog #21, #23, #25, the facts format, the tidy page, the controls' seed sites).
Lines move; the executor finds each quoted symbol by name. Evidence the replay reproduces:
`docs-system/research/2026-10-19-drafter-b3c-draft-review.md`, "The findings, page by page".

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch; every one held at planning
(2026-10-20 19:40 UTC):

- `cycle_ceiling` in `~/.config/drafter/config.toml` reads 200 (it does, line 3), or the date is past
  November 1.
- The SessionStart hook's `## Host` line reads `pavilion`. The ledger is per machine.
- `DRAFTER_API_KEY` is set in the launching environment, checked by name only, never printed.
  `~/.local/secrets` names it.
- `~/.config/drafter/cairn-cms.local.toml` exists and its `prompts` line names
  `~/.claude/workflows/docs-page-chain.js`.
- `/var/home/glw907/.local/bin/drafter spend --json` shows `total` plus `open.worst` at or under 155,
  so the $200 ceiling leaves the pass its $45. At planning: 140.01 plus 0.997.
- `go`, `node`, `vale`, `yq`, `cairn-run-gate`, `ci-green`, `cairn-docs-outline`, and `tellgrader`
  resolve.
- cairn-cms commit `517158fae` is reachable from `origin/main`
  (`git -C ~/Projects/cairn-cms merge-base --is-ancestor 517158fae origin/main` exits 0).
- No live session works drafter, cairn-cms, or the initiatives worktree this pass creates, other than
  the conductor and this planning session (`claude agents --json`).
- The plan, its two prompts, the factsheets, the three reviews, the fold record, and the fold
  verification are committed on initiatives `main`, so the conductor's clean-status check passes.

## Findings for the planning session

None changes the approved design's outcome, gate, proof, or bars; the fold record says why for each
point a reviewer raised as an owner fork (findings 7, 8, 19, and 23, the meter's reserve, and the
replay question's timing). Each is decided here; the ones marked
"contestable" are method calls a reviewer may want to argue, and every one goes in the drafter PR's
`## Decisions`.

1. **The fact-truth seat is built in Go, as the consistency seat is** (contestable). The design names
   `stock/prompts.js` and the chain's prompts module for the seat, on the reading that `consistency`
   lives there. It doesn't: Go builds the consistency prompt (`assemble.ConsistencyPrompt`,
   `internal/assemble/consistency.go:21`), and `docs/prompts-module.md:91-92` says a module never
   defines it. A module-rendered `facttruth` seat would need a `check-prompts` containment exemption
   (`cmd/drafter/checkprompts.go:236-251` requires every seat but `blueprint` to name `page.path`),
   and it would break the seat pins in `stock/stock_test.go:64`, the chain's seven-seat test
   (`tests/docs-page-chain-blueprint.test.mjs:268-276`), and the e2e read module
   (`e2e/blueprint_test.go:149`). The seat is the same judgment for every project, as consistency
   is, so it lives in `internal/assemble/` with a `[seat.facttruth]` table for its model, effort,
   and `max_tokens`. Neither prompts module changes. The outcome the design states (a third seat in
   the `drafter read` batch, Opus at medium, one request per blueprint) is unchanged.
2. **Covers ids reach every module as strings, so neither "string reader" changes** (contestable).
   `cairn-docs-outline` never reads `blueprints/outline.yaml`; it reads the chain's JSON outlines
   (`docs/internal/outlines/<arm>.json`, factsheet-prompts section 3). The drafter path's readers are
   Go: `Page.Covers []string` (`internal/blueprint/blueprint.go:160`), the strict reflect decoder
   (`internal/plan/decode.go:208-254`), `entryJSON` (`cmd/drafter/read.go:474-490`), and `EntryJSON`
   (`internal/pipeline/blueprint.go:40-57`). Go decodes a covers element as a string or an `{id,
   text}` mapping, and both JSON writers emit each element as one string (`<text>` for a string
   entry, `<id>: <text>` for a mapping), so the stock module, the chain, and the JSON outlines see
   the shape they see today. That meets the design's intent: the tidy entry's conversion breaks
   nothing the drafting pass will run.
3. **The lock's `facts` field is a map of per-fact hashes** (contestable). The design asks for "a
   hash over those bullets' text" and for `drafter page` to name the changed fact ids. One hash can't
   name them, and the lock records no commit to diff against (`blueprint-format.md:304-305`;
   factsheet-pipeline section 3). So `facts` maps each fact id in the read set to the first 12 hex
   digits of the SHA-256 of that bullet's verbatim text (pointer, anchor span, and tag qualifier
   included). The changed ids are the ids whose hash differs, the ids now cited that the map lacks,
   and the ids the map holds that are no longer cited. A moved pointer lapses the accept, as the
   design says. The design's single hash is the map's whole content, so every lapse the design
   defines still happens. An id that more than one bullet holds hashes all of them, joined in file
   order. The change read's "was:" text is not built in this pass: the changed-facts block prints
   each changed fact's current bullet and marks it "changed since the accepted read". The old text is
   recoverable (a walk of the lock's history, as `blueprint.LockIntroducedAt` walks it, finds the
   commit that wrote the map), which the drafting pass may want.
4. **The read set is every fact the blueprint places, cites, or disposes, from one exported
   function.** `Project.Cited` leaves dispositions out on purpose (`cited.go:12-13`); only the
   unexported `citedFacts` (`internal/blueprint/since.go:270-278`) covers all five sources the design
   names. T1 exports it as `blueprint.CitedFacts`, sorted and compacted, and the fact-truth read, the
   hash, and the `no-excerpt` warning all take their set from it. `Project.Cited` and its callers
   (`drafter gate`, the drafting seats' excerpts) are unchanged. The cost the design accepts: an edit
   to a fact five blueprints dispose (`f:hwffph`) lapses all five accepts.
5. **The verbatim bullet is kept on `plan.Fact`.** `ParseFacts` discards the raw bullet, and `Tag`
   drops a qualifier, `Sources` drops the anchor span (`internal/plan/facts.go:35-50`, `:187-214`,
   `:312-338`). T1 adds `Raw`, the bullet as `extractBullets` joins it, whitespace runs collapsed to
   one space. The hash, the fact-truth request, and `drafter excerpt` read it. `FactChanged` is left
   alone (backlog #27 wants it narrower, not wider).
6. **What the fact-truth seat sees is wider than today's excerpt, for every seat** (contestable).
   The cairn factsheet (section 2b) scored the 25 bullets' old pointers: in 12 the code that settled
   the finding sits outside every excerpt window, in 3 the old excerpt shows code or a comment that
   supports the wrong bullet, and 1 (`f:21by9u`) has only a dotted pointer. A prompt round cannot add
   code the excerpt lacks. Three excerpt changes raise what any read can see, and D3 lands them before
   the replay: a dotted anchor resolves to the inner declaration (#28); a `path#name` excerpt runs
   from the declaration's doc comment to its end, capped at 200 lines, in place of 5 before and 40
   after; and a pointer into a file of 150 lines or fewer shows the whole file. They change the
   drafting seats' excerpts too, by design: `drafter excerpt` must print what every read sees. The
   replay's tuning rounds may widen the view further (standing answer 3).
7. **A `wider` verdict reads against the excerpt, and a true claim the excerpt doesn't show is a
   pointer defect, not a false block** (contestable). The design defines `wider` as "the fact claims
   more than the excerpt shows" and counts a `no-excerpt` block on a verified fact as correct, fixed
   by re-pointing. A `wider` verdict on a claim the code bears out but no excerpt shows is the same
   defect, so the proof scores it in the pointer column beside `no-excerpt`, fixed by re-pointing. A
   false block is a `wider` or `contradicts` verdict whose stated reason the excerpt it quotes does
   not bear out (the excerpt does show the claim, or the code does not contradict it). This follows
   the design's own verdict text: `wider` is defined against the excerpt, and the design already
   scores the same defect under `no-excerpt` as a correct block. Because the reading could hide a seat
   that answers `wider` whenever an excerpt is thin, the proof guards it: the false-block table
   reports three counts (finding 7's false blocks; the design-literal count, a `wider` on a claim the
   code bears out; and the pointer column), and a fresh-context reader checks every pointer-column
   row before the bar is judged (R2 step 2). If the design-literal count is above zero while finding
   7's is zero, the run gave cause to revisit, and the conductor puts this finding to Geoff as an ask
   row in the packet, not a routine row.
8. **A line-addressed pointer into a listed prose source yields an excerpt** (contestable). Twelve
   verified facts cite only cairn's owner brief, `docs/internal/what-cairn-is-and-is-not.md`, a prose
   file (factsheet-cairn section 3), and three are placed by the eight (`f:nguseg` in second,
   `f:wvediq` and `f:y3ljm0` in security). Their source is the owner's statement, so they can't be
   re-pointed to code, and under "no-excerpt blocks a verified fact" those blueprints could never
   accept. A new project setting, `facts.prose_sources`, lists the prose files that may stand as a
   source; a `path.md:N` or `path.md:A-B` pointer into a listed file yields its window. Every other
   prose pointer, a live docs page above all, stays `no excerpt: prose`, so the design's rule that a
   live page is never a source holds by construction: a verified fact sourced only to a page still
   blocks. cairn lists the owner brief alone, in its committed `drafter.toml` (E's first fix round),
   and E re-points the owner-tier facts to line ranges. The fact-truth prompt tells the seat that a
   prose excerpt shows what a document says, never what code does.
9. **The replay reads at 517158fae on D3's binary, before the lapse rule lands.** Today `drafter read`
   reads every accepted page whole and never skips (factsheet-pipeline section 3), which is what the
   replay needs. So the replay runs on M1's build (the seat and the excerpt work) while D2 and D4 build
   the lock, the lapse, the sync default, and covers ids in their own worktrees. M1's binary still
   defaults to batch, so its live reads pass `--sync`.
10. **An entry with no `facts` field reads whole, once.** The design treats it as lapsed once. With no
    recorded state there is no change to read, so the read is whole: all three seats over the full
    read set, and an accept writes `facts`. That sends the eight existing accepts through the new gate,
    as the design intends.
11. **Which facts the fact-truth seat reads, by read kind.** A whole read: the full read set. A
    `--since` read: `Scope.Facts` plus `Scope.Joined` (the touched facts, `since.go:143-166`). A bar
    read: those, plus every cited id whose `Raw` differs between the bar's commit and the start
    commit (`FactChanged` misses tag-qualifier and parenthesized-pointer edits, and a bar accept
    writes the full map), plus every fact a `facttruth` finding in the bar names, which reach the
    pipeline as `Options.BarFacts` (D1). A lapse read: the changed ids
    still in the current read set (an id no longer cited appears only in the changed-facts block,
    since the blueprint can't place it). An empty set sends no fact-truth request. A fact none of whose
    pointers yields an excerpt gets `no-excerpt` from Go without a request, so the seat sees only facts
    with something to read.
12. **Only a `drafter read` accept that judged the facts writes `facts`.** The invariant: an entry's
    `facts` map is present only when a fact-truth read judged every bullet in it. So the map is
    written by a whole accept, by a lapse accept (the unchanged bullets were judged at the accept that
    wrote the old map), and by a bar accept whose bar a seat-aware read wrote (finding 20). Every
    other accept leaves `facts` as it was: a scoped accept (`--since`), a bar accept on a bar that
    predates the seat, and any accept inside `drafter page`, whose read stage never sends the seat.
    Leaving the map is safe because the lapse check compares the whole current read set: a fact the
    accept's read never judged is either new to the set or changed, and either lapses the entry on the
    next run. This drops the at-base third clause the first draft gave `scopedRefusal` (it needed a
    second map at the base and missed tag-qualifier edits that `FactChanged` ignores), and
    `scopedRefusal` keeps its two clauses.
13. **Three lock writers carry `facts`, and the accept short-circuits compare it.** `DraftedEntry`
    (`internal/blueprint/drafted.go:15-39`), `recordDrafted`'s equality check (`cmd/drafter/pagebp.go:208`,
    `:212`), and `seedEntry` (`internal/blueprint/seed.go:107-108`) copy only `accepted` today, so each
    would drop `facts`. D2 carries it in all three. `recordReads` skips an accept whose `accepted`
    already matches (`bar.go:91`, `if e.Accepted == r.Accepted { continue }`, and `:96`, `if
    e.Accepted == r.Accepted && e.Blocked == nil { continue }`). After R2, five entries hold `accepted`
    equal to their blob and no `facts`, so a whole accept on M2's binary would write nothing and the
    entry would lapse forever. Both skips also require the `facts` the write would set to equal the
    entry's.
14. **The controls run on add-cairn, in two seeded commits, against the replay's read at `main`.** The
    design wants each defect in a blueprint that otherwise holds the gate, but the controls run before
    E brings any blueprint to the new accept. add-cairn is the cleanest of the eight
    (factsheet-cairn section 7), and rotate, the design's site for the deploy step, carries a bar, a
    stale accept, and 12 open backlog items. So a control bites when the seeded read returns a
    blocking finding at the seed site, or `drafter check` reports an error there, that R2's unseeded
    read of add-cairn at `main` did not. A `drafter check` warning alone is reported and does not
    count as a bite, since the gate passes a warning. Two seeded commits, each read once, keep the
    controls under $4: commit A carries control 1 (the deploy step), 4 (a widened bullet), and 5 (a
    live-page claim), and commit B carries control 2 (a self-handler) and 3 (a fact pair). Control 6
    (a dead anchor) is offline: `drafter check` with no argument. Each finding is attributed by its
    location.
15. **The tidy author never runs a live command; the session runs each read and hands the author its
    findings.** The design's loop has the author run the reads. Here the author is an Agent dispatch,
    and the meter, the background rule, and the one-live-call-at-a-time rule belong to the session.
    So the session runs every `drafter read` and continues the same author with `SendMessage`, which
    keeps its context. What the author does between reads is the skill's loop, and the skill text
    still tells a normal session to run the read itself.
16. **The tidy outline entry's stale covers line is corrected from the code.** Line 8 of the entry
    names `editor.nav.configPath` and a `src/lib` fallback; the engine reads `editor.siteConfigPath`,
    defaulting to `src/theme/site.config.yaml`, with no fallback (`src/lib/content/compose.ts:20`,
    `:60`; `f:b9x4lc`). The design leaves the entry's product content to Geoff, and that is unchanged:
    the job, type, and every covered topic stay as he set them. The author fixes the one line's wrong
    name under the code-first rule and lists it in the cairn PR's `## Decisions`.
17. **The #25 counts are not the store's state.** Backlog #25's "19 directory, 18 dependency, 35
    prose" doesn't reproduce: at `main` the store holds 35, 51, and 167 such pointers, and the eight
    reference 22, 7, and 37 among verified facts (factsheet-cairn section 3). Seven verified facts the
    eight place or cite have no excerptable pointer. E re-points those, and the close updates #25's
    text with the counts that remain.
18. **The replay's 20-of-25 bar is at risk, and the plan says so up front.** Twelve of the 25 are
    omissions (true as far as they go) and the verdict set has no "omits"; a bullet that lists cases
    as complete when the excerpt shows more reads as `contradicts` only when the prompt says so, and
    D1's prompt does. With finding 6's wider view, the factsheet's per-bullet table puts the reachable
    count near the bar, not safely over it. Standing answer 3 governs a miss, and STATUS carries the
    ask it would put to Geoff, researched in advance (see R1). A reviewer proposed asking Geoff now;
    the design already says three tuning rounds and then ask, so the plan keeps that order.
19. **`drafter page` refuses every lapsed page; drafting only from gated blueprints is the drafting
    pass's entry condition.** The design's item 2 compares the map "at every read and page run", so
    `drafter page` refuses before any request whenever an entry holds a `facts` map that differs from
    the current read set, whatever `accepted` holds, and when `accepted` equals the blob and the map is
    missing. A missing map matches when the current read set is empty, as it is in a project with no
    `facts.dir` or for a blueprint that cites no fact, so neither the refusal nor the lapse check fires
    there (otherwise such a page could never be drafted, since no read can write an empty map past
    `omitempty`). The residual: an entry with no map whose `accepted` is stale still reads inside
    `drafter page` and, on an accept there, drafts in the same run without the fact-truth seat.
    Finding 12 keeps that run from writing a map, so the next `drafter page` refuses it. The design's
    "Later" names "drafting from gated blueprints only" as the drafting pass's work, and this pass
    drafts nothing, so the plan leaves that case there. The record and the drafter PR's
    `## Decisions` name it as an entry condition of the drafting pass.
20. **A bar that predates the seat is not a basis for a map.** rotate's bar (`fd90da8d8`) was written
    before the fact-truth seat existed, so a bar read judges only the facts changed since it, and no
    fact-truth read ever judged rotate's unchanged facts. D1 sets `seat` on every read finding (the
    blueprint and consistency seats included), and a bar none of whose findings carries a `seat`
    predates the seat. A bar accept on such a bar writes `accepted` and clears the bar but writes no
    `facts`, so the next read is whole (finding 10).
21. **A lapse accept has its own case in `recordReads`.** A lapse read's scope is a change with no
    `Since` and no `BarFrom`, so `scopedAccept` (`read.go:395-404`) returns true for it, `scopeBases`
    skips it (`read.go:530`, `r.Since == ""`), and `scopedRefusal` refuses it with "the blueprint it
    accepted is not the one at the scoped read's base". `PageResult` gains a `Lapse` flag, set where
    D2 builds the lapse scope, and `recordReads` takes a lapse accept in its own case before
    `scopedAccept`: it writes `facts` and keeps `accepted`, valid only while `accepted` still equals
    the blob at the run's start. A lapse read that blocks writes nothing to the entry, as a change read
    that blocks does today, so the next read lapses again and reads the same change.
22. **The design's no-spend proof is taken from the meter's totals.** The design's Check step 2 names
    `drafter spend --since <that minute>`, but `--since` takes a date only (`cmd/drafter/spend.go:38`,
    "first UTC date to count, YYYY-MM-DD", and `:66`, a usage error otherwise), and the JSON rows are
    totals by repo and seat (`spendRow`), not one row per call. So "spends nothing" is measured as
    `/var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter spend --since
    2026-10-20 --json` read just before and just after the call, with `total`, `open.count`,
    `open.worst`, and every row's `requests` unchanged.
23. **B's clock covers its loop, and a clock overrun on B is reported, not a stop.** The design's
    standing answer says the tidy build's reads count toward the $45 "and nothing else stops them".
    B's estimate (240) covers an initial build and about six read rounds. Past twice that, the session
    writes the minutes to STATUS and keeps going, as it does past the fifth read. Every other task's
    clock stop stands. The 1080-minute figure is the design's launch criterion for the plan's path;
    it is not a separate runtime stop.

## Outcome

drafter's `drafter read` carries a fact-truth seat; its lock records a per-fact hash beside each
accept and refuses a lapsed page in `drafter page` before any request; `drafter excerpt` prints what a
read sees; `drafter check` warns `no-excerpt` and checks covers ids; `drafter read` runs synchronously
by default. The replay and the controls show whether the gate does the hand check's job. cairn's eight
blueprints hold the new gate's accept, or the record names each one's open findings. The tidy page has
a blueprint built from the code that holds the accept. The blueprint skill has a code-first new-page
path, a read loop with no cap, and an exemplar, measured by a fresh rebuild. A research record carries
the proof.

- Risk class `runner`: drafter's pipeline, the skill. `live-account` for API spend only; no GitHub,
  Cloudflare, or npm account is touched beyond pushing three branches and opening three PRs.
- Repos: `glw907/drafter` (T1, D1 to D4, S), `glw907/cairn-cms` (the proof's live work, E, B),
  `glw907/initiatives` (the research record, K). Merge order: drafter first, then cairn with a merge
  commit, then the record (see "Merge order").
- Path, the longest chain run in sequence, a pair counting once at its larger estimate:
  - T0, launch, baseline, worktrees: 30.
  - T1, the shared exports: 30.
  - Pair A: D1 (160) beside D3 (120): 160.
  - M1, merge, the count golden's merge fix, gate, build, offline checks, dry-run pricing: 35.
  - Window W: R1 to R3 and E's first fix round (about 200), plus one tuning round (35): 235, beside
    D2 (135) then D4 (80) in subagent worktrees (215).
  - M2, merge, gate, build, offline checks: 25.
  - E, the eight blueprints to the new accept: 130.
  - B, the tidy build, its whole loop: 240.
  - S, the skill tuning and the exemplar: 40.
  - RB, the fresh rebuild: 60.
  - K, the end-to-end check and the research record: 30.
  - Close: 65.

  The sum is 30 + 30 + 160 + 35 + 235 + 25 + 130 + 240 + 40 + 60 + 30 + 65 = 1080, at the ceiling. One
  tuning round is counted, since finding 18 puts the replay near its bar; the second and third rounds
  standing answer 3 allows are contingent and run inside W's clock (twice 235). B's figure covers an
  initial build and about six read rounds (finding 23). The trims that pay for both came from the
  reviews: factsheets read by section, no prose review at S (Close holds the one), K citing B's
  accepting read, and Close's cairn review scoped to the hand-written files.
- Clock file: `pass-task-clock` in the drafter worktree's git dir,
  `/var/home/glw907/Projects/drafter/.git/worktrees/blueprint-first`. In a pair it holds the longer
  task's clock; when a pair or a lone subagent returns, the session checks it against twice its
  estimate. During window W the clock is W's (235). B's overrun is reported, not a stop (finding 23).
- Executor: session `drafter-blueprint-first` on `claude-opus-5-5` at `medium`, as the last two live
  passes ran: it judges live findings against the code, traces causes, and spends live money.
  Worktree name `blueprint-first` (branch `worktree-blueprint-first`). Models:
  - T1 by the session.
  - D1 to D4: `general-purpose` on `sonnet` at `medium`, per Geoff's ruling for drafter code, each
    loading `go-conventions` first. Pair `description`: `blueprint-first task <id>`.
  - Every fact or blueprint writer in E, the tidy author in B, and the rebuild author in RB:
    `general-purpose` on `opus` at `high`, `description` `blueprint-first <task> <page or "facts">`.
    A headless agent cannot read the user-scope skill directory (drafter backlog #2), so each prompt
    names the skill's files by their repo paths in the drafter worktree:
    `/var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/claude/.claude/skills/blueprint/SKILL.md`,
    `…/new-page.md`, `…/format.md` (a symlink to `docs/blueprint-format.md`), `…/anatomies.md`,
    `…/introductions.md`, and from S on `…/exemplar.md`. The session itself reads the skill from
    those same worktree paths once M1 lands, never through the user-scope link, which points at the
    main checkout's pre-D3 text.
- STATUS is the file `blueprint-first-status.md` in the drafter worktree's git dir, beside the clock
  file. It is never committed. It holds the meter baseline, the host, `BIN`'s path and commit,
  `BASE`, one row per live call (command, N, cap, meter before and after, output files, run id,
  result), the replay table, the controls table, the eight's table, the build's round table, and the
  friction log's path.
- Names, written out literally in every command and subagent prompt, never as shell variables:
  - the drafter worktree: `/var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first`;
  - the binary, built there by `make build`:
    `/var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter`, written `BIN` in
    this plan only;
  - the cairn worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-pages`,
    branch `blueprint-first-pages`, cut from `origin/main`; its start commit is `BASE` (52b3f979e at
    planning; T0 records the real one);
  - the replay worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-replay`,
    detached at `517158fae`, never committed to;
  - the main rerun worktree, made only if a tuning round must rerun a blueprint at `main`:
    `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-mainrerun`, detached at
    R2's start commit (`BASE`), never committed to;
  - the controls worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-controls`,
    branches `blueprint-first-controls`, `blueprint-first-controls-b`, and `blueprint-first-controls-c`,
    never pushed;
  - the rebuild worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-rebuild`,
    branch `blueprint-first-rebuild`, never pushed;
  - the record worktree: `/var/home/glw907/Projects/initiatives/.claude/worktrees/blueprint-first-proof`,
    branch `blueprint-first-proof`;
  - the friction log: `/var/home/glw907/Projects/drafter/.git/worktrees/blueprint-first/tidy-friction.md`;
  - the rebuild's skill copy, in the rebuild worktree's own git dir (no STATUS or friction log there):
    `/var/home/glw907/Projects/cairn-cms/.git/worktrees/blueprint-first-rebuild/rebuild-skill/`;
  - the eight blueprints, smallest first, written `THE EIGHT` in this plan only and in full in every
    command: `blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml
    blueprints/docs/extend/debug-your-site.blueprint.yaml
    blueprints/docs/extend/restrict-admin-access.blueprint.yaml
    blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml
    blueprints/docs/extend/scaffolded-site-files.blueprint.yaml
    blueprints/docs/extend/security-model.blueprint.yaml
    blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml
    blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml`.

### Standing answers

From the design, with the plan's specifics, applied in place of stopping:

1. A plan within 1080 path minutes launches unattended.
2. Live spend up to $45 over the T0 baseline runs without asking, as a hard ceiling, metered as below.
3. The replay and the controls run first, and E, B, S, RB, and K wait on their bars. A replay under
   20 of 25, a false block at `main`, or a control that does not bite is a traced cause: the session
   tunes the fact-truth seat (its prompt text in `internal/assemble/`, and, where the replay table
   shows the settling code outside the excerpt, the excerpt view, such as the whole file under a
   larger size limit, or the seat's `max_tokens` in `internal/config/stock.toml` when an answer was
   cut off), up to three rounds inside $10 of the $45. Each round is a drafter commit with a test,
   `make check`, and a rebuild, made between live calls, never during one. Its files are
   `internal/assemble/facttruth.go` and its test, `internal/assemble/excerpt.go` when the view widens,
   `internal/config/stock.toml` for `max_tokens`, `cmd/drafter/testdata/read-dryrun-count.golden.json`,
   whose fact-truth body moves with the prompt, and every golden whose bytes move only by excerpt
   content when the view widens (each regenerated, its `git diff --stat` in the commit; none is a D2
   or D4 file). The
   reruns:
   - A replay miss: every blueprint R1 read (the seven that place any of the 25) when M1's pricing
     says the seven fit in what is left of the $10; otherwise the blueprints that place a missed
     bullet. The replay worktree's lock is restored after each run, as in R1 step 2.
   - A false block at `main`: the blueprint holding it, in the main rerun worktree (detached at R2's
     start commit, whose lock predates R2's bars, so the read is not held by its own bar,
     `bar.go:198-202`), its lock restored after the run.
   - A control that did not bite: that control's commit.

   The score counts only verdicts from the final prompt where every placing blueprint was reread;
   where the money forced a partial rerun, the record states the count on the latest read of each
   placing blueprint and names which prompt version each verdict came from, beside the union of all
   rounds. The union is never reported alone. A bar still unmet after three rounds stops: STATUS
   carries the one question R1 prepares, and the executor waits for the conductor. That question is
   Geoff's condition on the API line, so no standing answer replaces it.
4. A fact-truth finding on today's store is fixed at its source on session tokens when the session
   can show the code line that settles it, and otherwise filed in cairn's backlog with the fact id and
   the excerpt. Either way it is counted in the proof's table.
5. A blueprint of the eight that does not reach the new gate's accept is reported with its open
   findings, and the run goes on. Loop guards: three reads of one blueprint in E without an accept is
   a guard, past which the run goes on while each round fixes a cause the session has traced and spend
   stays inside $45, each fix a reversible change in the cairn PR's `## Decisions`. A cause that
   returns after its fix gets one structural fix (the whole item, step, or bullet replaced); if it
   returns again, the blueprint is escalated in `## Decisions` and E goes on. Any of the eight may
   escalate, rotate included.
6. The tidy blueprint takes the rounds it needs. Its reads count toward the $45 and nothing else stops
   them; past the fifth read the session writes the count to STATUS and keeps going, and past twice
   B's clock estimate it writes the minutes there and keeps going (finding 23). B may not escalate:
   only the spend ceiling, a cause the session cannot trace, or a design-changing finding stops it. B
   draws on the reserve the meter holds for it, and E yields to that reserve.
7. The format may change where the build meets friction. A change beyond the three this pass builds
   (the `facts` field, dotted anchors, covers ids) is made only when the friction log shows the point,
   documented in `docs/blueprint-format.md`, kept decodable for the eight existing blueprints, and
   listed in the drafter PR's `## Decisions` with the log entry that caused it. It is a drafter task
   the session specifies and dispatches like D4, with a test and `make check`.
8. A fact edit after R1 lapses every accepted citer. Before committing a fact edit, the session runs
   `BIN refs f:<id>` from the cairn worktree and records the citers among the eight and tidy in
   STATUS. Each accepted citer joins the next read call, where the lapse rule reads its change; each
   such edit is listed in the cairn PR's `## Decisions` with its citers.
9. A cairn gate or CI red on a live page or live brief that cites a fact this pass edited is expected.
   At close, the session makes the minimal hand edit of that page's sentence and its brief entry to the
   fixed fact, and lists each in the cairn PR's `## Decisions`, so CI stays green. This pass drafts no
   page; these edits align live text with corrected facts and are what the skill's "the gate demands"
   exception allows.
10. A red baseline or a red the session traces to this branch's own commits is fixed forward on the
    branch. Only a red from `origin/main` that the branch can't fix stops the line. A gate that exits
    75 is re-issued.
11. An edit to `money.go`, `fingerprint.go`, or `resume.go`, spend past $45, a cause the session
    cannot trace, a clock stop on any task but B, or a finding that changes the design stops and asks:
    STATUS carries one question, and the executor waits for the conductor.

### The meter

At T0 the session records `/var/home/glw907/.local/bin/drafter spend --since 2026-10-20 --json`
(the installed binary; `BIN` doesn't exist yet) in STATUS and in T0's empty commit. Before every live
call, from the cairn worktree the call runs in:

- run `/var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter spend --since
  2026-10-20 --json`, fresh;
- `used = total − baseline.total + open.worst`, and `left = 45 − used`;
- at `left <= 0` the call doesn't start, and the run stops and asks (standing answer 11);
- otherwise the call runs with `DRAFTER_PAGE_CAP` set to `min(10, left / N)` rounded down to the cent,
  where N is the number of blueprints the call takes. When `left / N` is below the largest per-page
  worst case M1 step 4 recorded, the call is split into groups small enough that it isn't.

A reservation over the page cap escalates the page with rule `cap` before any request
(`internal/pipeline/money.go`, `case errors.Is(err, ledger.ErrPageCap): return p.escalate("cap", ...)`).
That is a budget limit, never a finding: the session records it, splits the call as above, and
reruns; a `left` below one page's worst case is the spend stop.

The reserve. `reserve` is what B, RB, and K's lapse read are priced at from M1 step 4's figures
(M1 step 4's figure; $7 to $12 at planning, the table's reserve rows at
the low end). An E read call starts only while `left − reserve > 0`; otherwise E's open
blueprints go to standing answer 5 with their findings. The tuning rounds' $10 comes from the pool,
before E; a tuning rerun after M2 also starts only while `left − reserve > 0`, or it goes to standing
answer 3's stop question. At each subagent's return the session takes a meter reading; a rise in `total` plus
`open.worst` with no session row behind it stops the run (standing answer 11).

The baseline's `open.worst` (B3's cancelled batch, $0.997) counts against this pass and errs safe.
Another session's spend on `pavilion` counts against the $45.

| Item | Estimate |
|---|---|
| R1 replay at 517158fae, seven blueprints (rotate places none of the 25), sync, all three seats | $7 to $9 |
| R2 read at `main`, eight blueprints | $8 to $10 |
| R3 controls, two reads of add-cairn | $3 to $4 |
| E's first read on M2's binary: the eight again, whole where no `facts`, bar reads where barred | $6 to $9 |
| E's later rounds (lapse, bar, and whole reads) | $3 to $5 |
| B tidy reads, five to seven rounds (reserve) | $5 to $8 |
| RB first read, K's lapse read (reserve) | $2 |
| Tuning rounds (standing answer 3), contingent | up to $10 |

The high ends pass $45, which is why the reserve exists: E yields before B, RB, and K, the order
the design ranks them in. M1's dry-run pricing (M1 step 4) replaces the estimates with counted
tokens before R1.

## Tasks

### T0: launch, baseline, and worktrees (30 min), by the session

1. The one-executor checks: `pgrep -af '[w]orktrees/blueprint-first'` prints nothing; `claude agents
   --json` shows no session working drafter or cairn-cms but the conductor and this one;
   `git -C ~/Projects/cairn-cms worktree list` shows no `blueprint-first` worktree. Both main
   checkouts print nothing for `git status --porcelain`, sit on `main`, and print 0 for
   `git rev-list --count HEAD..origin/main` after `git fetch origin`. Repeat the pre-flight's host and
   cycle-headroom lines.
2. `EnterWorktree` named `blueprint-first` in drafter. Arm the API-drop wake-up (`/loop` with no
   interval) and the guards `~/.claude/docs/unattended-work-guards.md` names. Run the drafter gate once:
   `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` through `cairn-run-gate`, re-issued on exit 75. A
   red baseline goes to standing answer 10.
3. Record the meter baseline and the host in STATUS. Commit it as `git commit --allow-empty` titled
   "Record the blueprint-first pass's spend baseline", whose body holds only the baseline's `total`,
   `open.worst`, and the date: no path and no host name, since drafter is public.
4. Create the cairn worktree: `git -C ~/Projects/cairn-cms worktree add -b blueprint-first-pages
   .claude/worktrees/blueprint-first-pages origin/main`. Record its `HEAD` as `BASE`. Run the
   cairn-pass setup there: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase &&
   npx svelte-kit sync)`.
5. Create the replay worktree: `git -C ~/Projects/cairn-cms worktree add --detach
   .claude/worktrees/blueprint-first-replay 517158fae`. No setup: `drafter read` needs no npm tree.
6. Into each of the two cairn worktrees, copy `~/.config/drafter/cairn-cms.local.toml` unchanged as
   `drafter.local.toml` (this pass never edits the chain, so its `prompts` line stays). `.gitignore:33`
   ignores the file at both commits. Run `/var/home/glw907/.local/bin/drafter config` in each:
   `prompts` shows the local layer, `page_cap = 10`, `cycle_ceiling = 200`. `git status --porcelain`
   prints nothing in either.
7. Baseline cairn in the cairn worktree: `/var/home/glw907/.local/bin/drafter check` reports 0 errors,
   and `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:facts'` exits 0. Record in STATUS each of
   the eight's lock entry at `BASE` (`accepted`, whether it equals `git rev-parse
   BASE:<blueprint>`, `blocked`), which should match factsheet-cairn section 1 (five accepts matching,
   restrict and scaffolded stale, rotate stale with a bar). A difference is recorded, not a stop.

- Files: one empty commit in drafter. Risk class `runner`.
- Acceptance: each step's output recorded in STATUS.

### T1: the shared exports (30 min), by the session

Outcome: findings 4 and 5, and the one excerpt entry D1 and D3 share, committed before the pairs
branch, so D1, D2, and D3 build on one base and neither pair task writes its own "has a real
excerpt" test.

- Files: `internal/blueprint/since.go` (or a new `cited_all.go` beside it) and its test;
  `internal/plan/facts.go` and `facts_test.go`; `internal/assemble/excerpt.go` (the exported entry
  only) and `excerpt_test.go`.
- Build: `blueprint.CitedFacts(b *Blueprint, facts *plan.Facts) []string`, the sorted, compacted ids
  of `citedFacts`. `plan.Fact` gains `Raw string`, the joined bullet text with whitespace runs
  collapsed, set in `ParseFacts`. In `internal/assemble/`, one exported entry over today's
  `excerptBlocks` path returns a fact's excerpt blocks and whether any of them is a real excerpt (a
  block whose body does not start `no excerpt:`). D1's Go-side `no-excerpt`, D3's command and
  warning, and `inputBlocks` all take it, so what a read sees and what `drafter excerpt` prints agree
  by construction. D3 changes what the blocks hold, never the entry's shape.
- Tests: `CitedFacts` on a fixture blueprint holding a fact item, an item's `facts` list, an
  introduction fact, a disposition, and a framing citation returns all five ids once, sorted;
  `ParseFacts` on a two-line bullet with a `[verified: 2026-10-01]` qualifier and a pointer with an
  anchor span sets `Raw` to the one-line text with both kept. `FactChanged`'s tests pass unchanged.
  The entry reports false for a fact whose only pointer is a directory and true for one with a
  `path:N` pointer into a tracked code file.
- Acceptance: `make check` green; one commit, "Export the full cited set, each fact's bullet, and
  the excerpt entry".
- Risk class `runner`.

### D1: the fact-truth seat (160 min), paired with D3, `sonnet` at `medium`

Outcome: findings 1, 7, 11, and 20's `seat` field; the design's "What it builds" item 1.

- Files: `internal/assemble/` (a new `facttruth.go` and test; `schema.go` and `schema_test.go`;
  `assemble.go`'s `inputBlocks` case only), `internal/config/{check.go,stock.toml,stock_test.go,validate_test.go}`,
  `internal/pipeline/{blueprint.go,handle.go,record.go,pipeline.go,page.go,start.go}` and their tests,
  `cmd/drafter/bar.go` (`barOf`, `renderBar`, `applyBar`, `barMaps`), `cmd/drafter/read.go` (the
  `pipeline.Options` literal and its `barMaps` construction only), `cmd/drafter/draftscope.go` (its
  `barMaps` construction only), `internal/blueprint/since.go` (the comparison's `Raw` set only),
  `internal/blueprint/blueprint.go` (`BlockedFinding` only),
  `internal/smoke/{shapes.go,smoke_test.go}`, `cmd/drafter/testdata/read-dryrun-count.golden.json`
  (regenerated), `docs/configuration.md` (the seats section), `docs/prompts-module.md` (one sentence
  beside consistency's). The existing tests the seat breaks, because `facts.dir` defaults to
  `blueprints/facts` when that directory exists (`internal/config/blueprints.go:18-24`), so the seat
  runs in every read fixture that has one:
  - `internal/pipeline/testdata/project/docs/facts/keys.md`: `lumen-key-ttl` is `[verified]` with
    `Source: the key policy` (:5), which Go would answer `no-excerpt` and block every
    `newBlueprintHarness` read. Re-point it to a new tracked fixture file beside it; the
    blueprint-read golden carries the claim and tag, not the source, so it stays unchanged.
  - `cmd/drafter/read_test.go`: its facts have no source, and `readStub` answers every Messages call
    with `{"verdict":"ok",...}` (:378-399), which the facts schema rejects; it gains a facts answer.
  - `cmd/drafter/clifixture_test.go`: `len(f.stub.counts) != 2` (:150) becomes three.
  - `e2e/draft_test.go`: `schemaKind` maps a `{facts}` schema to `unknown` and the stub answers HTTP
    500 "no canned answer" (:85-88, :127-145); it gains a `facts` case and a canned answer, which the
    `e2e/testdata/cli` tally fixture's `main.go` pointers need.
  Not `internal/assemble/excerpt.go` or `files.go`,
  `internal/config/{config.go,file.go,apply.go,sources.go}`, `cmd/drafter/check.go`, `excerpt.go`,
  `root.go`, `docs/blueprint-format.md`, `README.md`, or the skill, which D3 owns. D2 edits `read.go`,
  `draftscope.go`, and `bar.go` only after M1. The pair shares one file, `docs/configuration.md`, in
  separate sections (D1 the seats, D3 the facts table), which M1 merges.
- Never `money.go`, `fingerprint.go`, `resume.go`, `stock/prompts.js`, or the chain.
- Build:
  - Config. `facttruth` joins `seatNames` after index 6, so `defaultSeats` is unchanged.
    `stock.toml` gets `[seat.facttruth]`: model `claude-opus-5-5`, effort `medium`, `max_tokens`
    32000. The seat runs in `drafter read` whenever `facts.dir` is set, whatever `cfg.Seats` holds, as
    the blueprint seat always runs; its config table is validated with `ValidateSeat("facttruth")`
    where the read's run starts (in the pipeline, not `cmd/drafter/read.go`).
  - The set (finding 11), from `blueprint.CitedFacts` for a whole read, and from the read scope's
    `Facts` plus `Joined` otherwise. A bar read adds the scope's new `RawChanged` (cited ids whose
    `Raw` differs between the two commits, computed in `since.go` beside `bulletChanged` from the two
    fact sets it already loads; `FactChanged` itself is unchanged) and the bar's `facttruth` fact ids.
    The bar reaches the pipeline only as rendered text (`Options.Bars map[string]string`,
    `internal/pipeline/pipeline.go:78`, filled by `applyBar` with `renderBar(b)` and passed at
    `cmd/drafter/read.go:158`), so `applyBar` also records the bar's `facttruth` fact ids in a new
    `Options.BarFacts map[string][]string`, which the pipeline adds to the read set. D2 supplies a lapse
    read's set through the same read scope, so D1 reads the scope and never the lock.
  - Go's own verdict. A fact with no source, or for which T1's excerpt entry reports no real excerpt,
    gets `no-excerpt` without a request and is left out of it.
  - The request. A new `AnswerFactTruth`, built by `assemble.FactTruthPrompt`, with excerpts through
    `inputBlocks` from `Facts` and `FactIDs` as the drafting seats get them
    (`assemble.go:164-170`). The prompt carries: each fact's `Raw` bullet and its tag; the four
    verdicts with their definitions; that `wider` means some part of the claim, such as a count, a
    list, "only", "every", "always", or a scope, is not shown by any excerpt; that a bullet presenting
    a list or set of cases as complete is `contradicts` when an excerpt shows a case it leaves out;
    that a code line outranks a comment when they disagree; that a prose excerpt shows what a document
    says, never what code does; that `no-excerpt` means no excerpt bears on the claim; that the answer
    quotes the excerpt lines a non-`holds` verdict rests on and states the fix as the claim the code
    supports. It never asks for an edit.
  - The schema: `{facts: [{id, verdict, excerpt, fix}]}`, `verdict` an enum of the four, every field a
    required string (empty for `holds`), `additionalProperties: false`, with one contract sentence.
    Every fact in the request must come back once; a missing id becomes a blocking finding "the
    fact-truth read returned no verdict for f:<id>". An id answered twice takes its worst verdict; an
    id the request did not carry is dropped with a warning on stderr.
  - Findings. A non-`holds` verdict becomes a finding with seat `facttruth`, kind `fact`, location
    `fact f:<id>`, and text `<verdict>: <fix> (excerpt: <quote>)`. `wider` and `contradicts` block;
    `no-excerpt` blocks when the fact's tag is `verified` and is a warning for `external` or `vendor`.
  - Plumbing (factsheet-pipeline section 4's list): `stepSeats` at `stBpRead` returns `facttruth`
    when the run is a read (`!p.w.Draft`) and the set is non-empty; `stageBlueprintRead`'s seat switch;
    `validate`; `isRead`; `completeBlueprintRead` escalates with rule `facttruth` when the seat blocks,
    and sets `WholeBlocked` when the blueprint seat or the fact-truth seat blocks on a whole read;
    `blueprintFindings` and `alreadyPresent` take `facttruth` findings too; `FindingResult` and
    `BlockedFinding` gain `seat` and `kind` (`json`/`yaml` `omitempty`), and every finding of the
    three read seats sets `seat` (`blueprint`, `consistency`, or `facttruth`), so a bar with no
    `seat` anywhere is known to predate the seat (finding 20); `barOf` keeps both;
    `renderBar` skips findings whose `seat` is `facttruth` and renders seatless and `consistency`
    findings as today (`barOf` keeps every blocking finding, `bar.go:147-150`), so the blueprint
    request's bar block drops `facttruth` findings only and its bytes don't change for today's bars. `record.json` keeps every verdict of the seat, `holds`
    included, per page (the replay is scored from it).
  - `drafter page` never sends the seat: its read stage gates on `!p.w.Draft`.
  - Smoke: a `facttruth` row in `seatAnswers`; `smoke_test.go`'s count of distinct custom ids follows.
- Tests (pipeline harness, `newBlueprintHarness`; copy the consistency seat's tests):
  - A whole read of a fixture blueprint citing four facts sends one `facttruth` request carrying the
    four `Raw` bullets and their excerpt blocks; answers `holds` for all: accepted, and the bar is
    unchanged.
  - One `wider` and one `contradicts`: escalated with rule `facttruth`, two blocking findings with
    seat `facttruth` and kind `fact` in the summary JSON, each finding's text carrying the quoted
    excerpt and the fix, and a whole read writes a bar holding both with their seat. A blueprint-seat
    finding in the same run carries seat `blueprint`.
  - An answer naming one id twice takes the worse verdict; an answer naming an id the request didn't
    carry drops it with a warning.
  - A verified fact whose only pointer is a directory: `no-excerpt` from Go, blocking, and the request
    leaves it out; the same fact tagged `external`: a non-blocking warning.
  - A fact the answer omits: a blocking "returned no verdict" finding.
  - A `--since` read whose change touches one fact and joins one: the request carries exactly those
    two. A blueprint-only change touching no fact: no `facttruth` request.
  - A bar read where the bar holds a `facttruth` finding on f:a and the change touches f:b: the request
    carries f:a and f:b; the blueprint request's bar block holds no `facttruth` finding and still holds
    the bar's consistency finding and a seatless finding, rendered as today. A bar read where f:c's
    tag qualifier alone changed since the bar's commit: the request carries f:c.
  - `drafter page` on a page whose read isn't skipped stages no `facttruth` request.
  - `record.json` holds each verdict, `holds` included.
  - `TestBlueprintReadRequestGolden` passes with `blueprint-read-request.golden.json` unchanged and
    never regenerated. `TestReadDryRunRequestGolden`'s count golden is regenerated for three requests;
    the commit message quotes its `git diff --stat`. D3's excerpt view moves the excerpt bytes in that
    golden (`e2e/testdata/cli/main.go` is 50 lines, so it shows whole), and M1 regenerates it once
    more after the merge.
  - `TestSchemasKeepToStructuredOutputLimits` covers `AnswerFactTruth`. `stock_test.go` and
    `validate_test.go` cover the new seat name.
- Acceptance: `make check` green in the pair worktree; each row above, by test name, shows `PASS`
  under `go test -run '<names>' -v` at M1. The commit message names every switch the seat joined.
- Risk class `runner`.

### D3: excerpts, `drafter excerpt`, the `no-excerpt` warning, and the skill's first edit (120 min), paired with D1, `sonnet` at `medium`

Outcome: findings 6 and 8; the design's "What it builds" item 3 and the first half of item 6
(drafter #28).

- Files: `internal/assemble/excerpt.go`, `excerpt_test.go`, `files.go`,
  `internal/config/{config.go,file.go,apply.go,sources.go}` and their tests (the `facts.prose_sources`
  key, beside `facts.bullet_format` at `apply.go:152` and `file.go:96`, and in `settingKeys` after it
  at `sources.go:17`),
  `cmd/drafter/{excerpt.go,excerpt_test.go,root.go,check.go,check_test.go}`, any golden whose bytes
  move only by excerpt content (regenerated, each named with its `git diff --stat` in the commit
  message), `docs/blueprint-format.md` ("What `drafter check` checks" and a new short "See what a read
  sees" subsection after it), `docs/configuration.md` (the facts table and its paragraph only; D1
  edits the seats section of the same file, so M1 merges the two hunks), `README.md` (the command
  list), and `claude/.claude/skills/blueprint/{SKILL.md,new-page.md}`. Not D1's files.
- Build:
  - Dotted anchors: `path#outer.inner` finds `outer`'s declaration, then `inner` within its span: a
    member, property, method, or a `const`, `let`, `var`, or `function` declared inside. A deeper
    chain resolves link by link.
  - The `path#name` window runs from the declaration's leading doc comment through its last line (the
    first line after it at the declaration's indentation or less that closes or starts a declaration),
    capped at 200 lines with a closing `… (N more lines)` line.
  - A pointer into a tracked code file of 150 lines or fewer shows the whole file, once per fact.
    Prose files keep the line windows.
  - `facts.prose_sources`, a list of project-relative prose files, project or local layer, unset by
    default. A `path:N` or `path:A-B` pointer into a listed file yields its window. Every other prose
    pointer, and a bare path into a listed file, stays `no excerpt: prose`. The excerpt code's own
    tracked-and-inside-the-root checks (`excerpt.go`, `within(real, r.real)` and `r.tracked[rel]`)
    already bound the paths, so the key needs no check of its own.
  - T1's excerpt entry is what the command and the warning call, so they and `inputBlocks` agree by
    construction.
  - `drafter excerpt <fact-id | pointer>`, registered in `newRootCmd`, modeled on `newRefsCmd`:
    `--root`, `--json`. For a fact id it prints the `Raw` bullet, then each block exactly as a read's
    request carries it. For a pointer it prints that pointer's block. Exit 0 when at least one block is
    an excerpt, 1 when none is, 2 on a usage or project error.
  - `drafter check` warns, check name `no-excerpt`, on each `verified` fact in a checked blueprint's
    `blueprint.CitedFacts` set none of whose pointers yields an excerpt, at the bullet's file and line,
    with the fix "point it at the code that shows the claim; `drafter excerpt f:<id>` shows what a
    read sees". A run over the whole project reports each fact once.
  - The skill, first edit. `new-page.md` step 2 becomes the code-first fact rule: set the pointer and
    anchor first, run `drafter excerpt <pointer>`, write the claim with the excerpt in view; a live
    page is a map, never a source, and a claim found only on a page is retraced to code, config, or a
    vendor document or not filed. Step 5 becomes the loop with no cap: `drafter check`, fix, commit,
    `drafter read <blueprint>`, fix every blocking finding from every seat on session tokens, commit,
    read again, until a read accepts; polish before a read, never after the accept; report the round
    count. `SKILL.md`'s Read step names the fact-truth findings (what each verdict means and its fix:
    correct the bullet to what the code shows, or re-point it so the excerpt shows the claim; never
    widen the claim) and the lapse line `drafter page` prints (run `drafter read <blueprint>`), and
    drops `--sync` from its commands, since D2 makes sync the default. The edit path's three-read cap
    stays.
- Tests:
  - `excerpt_test.go`: `outer.inner` for a TS method, an object property, and a nested `function`;
    `a.b.c`; a dotted name whose inner member is absent ("declaration not found"); a declaration with
    a doc comment and a 60-line body yields the whole span; a 250-line declaration is capped at 200 with
    the closing line; a 120-line code file shows whole for a `path:N` pointer; a 400-line file keeps
    today's `±10` window; with `notes.md` listed in `facts.prose_sources`, `notes.md:3-5` yields lines
    (not the whole 20-line file) and a bare `notes.md` stays `no excerpt: prose`; a
    `docs/guide/page.md:4` pointer into an unlisted prose file stays `no excerpt: prose`.
  - `internal/config`: `facts.prose_sources` loads from the project and local layers and prints in
    `drafter config`.
  - `cmd/drafter`: `drafter excerpt f:<id>` prints the bullet and its blocks and exits 0; a fact whose
    only pointer is a directory exits 1; a raw pointer prints one block; `drafter check` on a fixture
    whose blueprint cites a verified fact with only a directory pointer warns `no-excerpt` once and
    still exits 0; the same fact tagged `external` draws no warning; the command's blocks are
    byte-identical to the excerpt blocks `drafter page --dry-run`'s draft request carries for the same
    fact (`assemble.go:164-170`), since no read request carries fact excerpts until D1 lands.
- Acceptance: `make check` green in the pair worktree (the install test's skill-link check included);
  each test above, by name, `PASS` at M1.
- Risk class `runner`.

### M1: merge, build, offline checks, and pricing (35 min), by the session

1. Merge D1 and D3. Regenerate `cmd/drafter/testdata/read-dryrun-count.golden.json` once more, check
   that only the fact-truth body's excerpt content moved, and commit it as a merge fix whose message
   quotes its `git diff --stat`. Run the named-test check for both, `TestBlueprintReadRequestGolden`
   with its golden unchanged, then `make check`, then `make build`. Record `BIN`'s commit in STATUS.
   `make check` rebuilds `BIN` in place (`chain-test` and `prompts-parity` both depend on `build`,
   Makefile:21-31), so neither `make check` nor `make build` runs while a live call runs. `BIN` is
   rebuilt after any later drafter commit, and every STATUS row names the commit its call ran.
2. In the cairn worktree: `BIN config` shows `[seat.facttruth]` from the stock layer; `BIN check`
   reports 0 errors and lists every `no-excerpt` warning, which the session records in STATUS against
   factsheet-cairn section 3's seven (f:nguseg, f:ogz5eu, f:hnvweu, f:t2t5lx, f:2w1yrc, f:wvediq,
   f:y3ljm0, with the owner-tier three excerptable only after E lists the owner brief in
   `facts.prose_sources` and re-points them).
3. In the replay worktree, `BIN excerpt` on each of the 25 bullets (factsheet-cairn section 2a's list)
   and on `f:21by9u`'s dotted pointer; record in STATUS, per bullet, whether the settling code
   factsheet-cairn section 2b names now falls inside a block. That is the replay's predicted ceiling.
4. Pricing, no spend: in the replay worktree, `BIN read --dry-run --sync --json` followed by THE EIGHT
   written out in full, and the same in the cairn worktree. A dry run sends only `count_tokens` and
   writes no ledger line. Record each blueprint's input tokens per seat, its expected cost, and its
   worst case in STATUS, and the largest per-page worst case (the meter's split rule). Replace the
   meter table's estimates with these figures, set `reserve` (B at seven reads of a blueprint the
   size of the largest of the eight, RB's one read, K's lapse read), and write the projected total:
   R1 + R2 + R3 + E's first read + the $10 of tuning + `reserve`. When it passes $45, R1 step 4's
   prepared question names that before R1 starts; the meter still governs.

- Risk class `runner`. Acceptance: each step's output recorded in STATUS.

### Window W: D2 and D4 in worktrees, beside R1 to R3 (235 min)

The session dispatches D2 at M1's end and D4 when D2 returns (both edit `blueprint.go`, `read.go`, and
`docs/blueprint-format.md`, so they can't pair), each a lone `general-purpose` subagent on `sonnet` at
`medium` with `isolation: "worktree"` from the head it is dispatched at. D2 is not merged into the
session's branch mid-window, because a merge there means `make check`, which rebuilds `BIN` under the
live proof. Instead D4's first step merges D2's branch into its own worktree and runs D2's named tests
there, so D4 builds on D2 and M2 merges D4's branch, which carries both. The session runs R1 to R3
meanwhile, on M1's `BIN`. Prompt tuning under standing answer 3 commits on the session's branch and
touches only the files standing answer 3 lists, none of which D2 or D4 edit.

#### D2: the lock's `facts`, the lapse rule, and sync by default (135 min), `sonnet` at `medium`

Outcome: findings 3, 10, 12, 13, 20, and 21; the design's "What it builds" items 2 and 5; drafter #20.

- Files: `internal/blueprint/{blueprint.go (LockEntry only),lock.go,drafted.go,seed.go}` and a new
  `factshash.go`, their tests; `cmd/drafter/{read.go (not entryJSON),bar.go,pagebp.go,draftscope.go,page.go}`
  and their tests; `internal/config/{config.go,load.go}` (a `Batch` flag) and tests;
  `internal/pipeline/pipeline.go` (`PageResult.Facts`, `ResumeCommand`) and tests;
  `internal/blueprint/docs_test.go:37`; `e2e/readbar_test.go` and any e2e test the flags move; the
  skip-read tests the refusal changes (`cmd/drafter/draftscope_test.go:324-344`,
  `cmd/drafter/bar_test.go:526-626`), each given a matching `facts` map where its fixture has a facts
  directory;
  `docs/blueprint-format.md` ("drafted.lock", "What `drafter read` does with a blueprint", "The read
  bar", "What `drafter page` does with a blueprint"), `docs/configuration.md` (the `mode` lines),
  `README.md` (the read line). Never `money.go`, `fingerprint.go`, `resume.go`.
- Build:
  - `LockEntry.Facts map[string]string yaml:"facts,omitempty"`, written after `accepted`. One
    `FactsHashes(ids, facts)` function returns the map over `blueprint.CitedFacts` from each fact's
    `Raw` (every bullet of a duplicated id, joined in file order), and it is the only place the map is
    computed: the writer, `drafter read`'s lapse check, and `drafter page`'s refusal all call it on
    the facts the run loaded at its start. `PageResult` gains `Facts` (JSON `facts`, omitempty) and
    `Lapse` (finding 21). `Facts` is set only in `drafter read`, only on a result whose read judged
    every fact in the map (finding 12), where `Summary` builds each result.
  - Writes, in `recordReads`: a whole accept writes `accepted` and `facts`; a bar accept writes both
    when any of the bar's findings carries a `seat`, and `accepted` alone (clearing the bar) when none
    does (finding 20); a lapse accept, in its own case before `scopedAccept`, writes `facts` and keeps
    `accepted`; a scoped accept and every accept inside `drafter page` leave `facts` as it was; a lapse
    read that blocks writes nothing. Both short-circuits (`bar.go:91` and `:96`) skip only when
    `facts` also equals what the write would set (finding 13). `DraftedEntry`, `recordDrafted`'s write
    and its equality check, and `seedEntry` carry `facts`. `scopedRefusal` is unchanged.
  - Lapse in `drafter read` with no `--since` and no `--resume`, for an entry with no `blocked` whose
    `accepted` equals the blueprint's blob at the start commit: no `facts` field reads whole (finding
    10); a map that differs makes a lapse read. A lapse read sets that page's read scope as a change:
    `Facts` the changed ids still in the read set, `IDs` the sections citing them (`sectionCites`), an
    empty blueprint diff, and a changed-facts block listing each changed id's current `Raw` bullet
    marked "changed since the accepted read" (removed ids listed as "no longer cited", and never sent
    to the fact-truth seat). It sets `Lapse`. Everything else reads as today.
  - `drafter page`: in `scopeFromLock`, before the up-to-date and `skipRead` decisions, the call
    refuses before any request when an entry holds a `facts` map that differs from the current read
    set, whatever `accepted` holds, or when `accepted` equals the blob and the map is missing (finding
    19). A missing map matches an empty read set (no `facts.dir`, or a blueprint citing nothing), in
    this check and in `drafter read`'s lapse check alike. The refusal goes through `cannot` (`exitCannotRun`), printing one line per lapsed page:
    `<page>: the accepted read lapsed; facts changed since it: f:a, f:b. Run drafter read <blueprint>.`
    (or "no facts recorded" for a missing field). One lapsed page refuses the whole call. This closes
    drafter #20.
  - Sync by default. `drafter read` gains `--batch`; `config.Flags` gains `Batch`, which the flag layer
    turns into `mode = "batch"`; `read` passes `Sync: !batch`. `--sync` stays accepted. Both flags
    together is a usage error. `drafter page` is unchanged. `ResumeCommand` writes `--batch` for a
    batch read's resume and `--sync` as today for a sync one. `read`'s help text and the docs say read
    is sync unless `--batch`, and `mode` governs `drafter page`.
  - Docs: the `facts` field, its hash rule, and which accepts write it; the lapse rule in read and
    page; the fact-truth seat and its verdicts in "What `drafter read` does" (D1 left that section to
    D2); the bar's `seat` and `kind`.
- Tests:
  - `TestLockRoundTrip` and `TestLockBlocked` with a `facts` map; `docs_test.go:37` lists `facts`.
  - `recordReads`: a whole accept writes both fields; an entry with `accepted` equal to the blob and
    no `facts` gains `facts` on a whole accept, and a second `drafter read` is not a lapse read; a bar
    accept on a bar whose findings carry `seat` writes both; a bar accept on a bar with no `seat`
    writes `accepted`, clears the bar, writes no `facts`, and the next read is whole; a lapse accept
    writes `facts` and keeps `accepted`, and the next `drafter read` is a whole read and `drafter page
    --dry-run` prints no lapse line; a lapse read that blocks leaves the entry byte-identical; a scoped
    accept advances `accepted` under today's two clauses and leaves `facts`.
  - A `drafter page` run whose read stage accepts a changed blueprint writes `accepted` and no new
    `facts`, and a second `drafter page` on an entry that had none refuses with "no facts recorded"
    before any request.
  - `drafter read` on an accepted entry with no `facts`: a whole read. With a map that differs by one
    bullet's anchor span only: a lapse read whose `facttruth` request carries exactly that fact and
    whose blueprint request carries the changed-facts block, and whose consistency request is sent. A
    map that names an id the blueprint no longer cites: the id is in the changed-facts block and not in
    the `facttruth` request. With a map that matches: a whole read, as today.
  - `drafter page` on a lapsed page: refuses with the line above, exit 2, and the stub API server saw
    no request; with two pages, one lapsed: the call refuses and names only that page; an entry whose
    map matches drafts as before; an entry with a stale `accepted` and a differing map refuses before
    any request; an accepted entry with no map in a project with no facts directory, and one whose
    blueprint cites no fact, draft as before, and `drafter read` on each reads no lapse.
  - `recordDrafted`, `DraftedEntry`, and `seedEntry` keep `facts`.
  - `drafter read` with no mode flag runs sync (the stub sees `/v1/messages`, not batches); `--batch`
    runs a batch; `--sync --batch` is a usage error; `DRAFTER_MODE=batch` with no flag still runs sync;
    a stopped batch read prints a resume line carrying `--batch`, and that line resumes.
    `TestResumeCommand`'s rows follow; `TestStoppedSyncReadPrintsAResumeCommandDrafterAccepts` passes.
- Acceptance: `make check` green in its worktree; each row by test name `PASS` at M2.
- Risk class `runner`.

#### D4: covers ids (80 min), `sonnet` at `medium`, dispatched when D2 returns

Outcome: finding 2; the design's "What it builds" item 4.

- Base: the subagent's first step merges D2's branch into its worktree and runs D2's named tests,
  which pass before it writes anything (Window W).
- Files: `internal/blueprint/{blueprint.go (Page, Section, a new Cover type),decode.go,check.go}` and
  tests; `internal/plan/{plan.go (Disposition),decode.go}` and tests; `schema/blueprint.schema.json`,
  `schema/outline.schema.json`, `schema/plan.schema.json` (its disposition requires `fact` at :82,
  checked by `internal/plan/schema_test.go:89`); `cmd/drafter/read.go` (`entryJSON` only);
  `internal/pipeline/blueprint.go` (`EntryJSON` only); `docs/blueprint-format.md` ("outline.yaml",
  "sections", the `dispositions` row, and a `covers` row in the check table).
- Build:
  - A covers element decodes from a string or an `{id, text}` mapping (`id` matching the item-id
    form, `text` prose), through a union element in the strict decoder; an unknown key in the mapping
    is a decode finding.
  - `Section` gains optional `covers: [<id>, ...]`. `plan.Disposition` gains optional `covers: <id>`;
    a disposition names exactly one of `fact` or `covers` (the validation runs where `fact`'s required
    check runs today, for blueprints and plans alike).
  - `drafter check` adds check `covers`, error severity: every id in the outline entry's mapping
    elements is claimed by a section's `covers` or a disposition's `covers`; every id a section or
    disposition names exists in the entry; ids are unique in the entry. String elements are left to the
    whole read.
  - `entryJSON` and `EntryJSON` emit each element as one string: `<text>` for a string, `<id>: <text>`
    for a mapping.
  - The three schemas follow, so `TestSchemasMatchGoTypes` and `TestReferenceNamesEverySchemaField`
    pass.
- Tests: decode of a mixed list; an unknown mapping key; the `covers` check's three errors and a clean
  pass; a disposition with both `fact` and `covers`, and with neither; the JSON writers' output for a
  mixed list; a pipeline-harness dry-run read whose outline entry holds one mapping element carries
  `<id>: <text>` and no `[object Object]` in the blueprint request (both modules see the same string,
  which `prompts-parity` already holds them to; `check-prompts` takes `--module`, `--matrix`, and
  `--expect`, not an outline, so it is not the vehicle); every existing blueprint test passes
  unchanged.
- Acceptance: `make check` green in its worktree; each test by name `PASS` at M2.
- Risk class `runner`.

#### R1: the replay at 517158fae (live), by the session

Outcome: the design's replay, part one.

1. A fresh meter reading, then, in the replay worktree, in the background (Run rules):

   ```
   DRAFTER_PAGE_CAP=<min(10, left/7)> /var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter read --sync --json blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml blueprints/docs/extend/debug-your-site.blueprint.yaml blueprints/docs/extend/restrict-admin-access.blueprint.yaml blueprints/docs/extend/scaffolded-site-files.blueprint.yaml blueprints/docs/extend/security-model.blueprint.yaml blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml
   ```

   rotate is left out: it places none of the 25, and at `517158fae` it would read as a bar read
   against its pre-seat bar, which scores nothing.
2. Copy the run's `record.json` and the summary JSON into the drafter worktree's git dir, then restore
   the replay worktree with `git -C /var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-replay checkout -- blueprints/drafted.lock`
   and confirm `git status --porcelain` prints nothing, so a tuning rerun starts from the same state.
3. Score: a 25-row table in STATUS, one row per bullet of factsheet-cairn section 2a, with each
   placing blueprint's verdict, quoted excerpt, the prompt version that produced it, and a match
   column comparing the verdict's fix with the hand check's finding for that bullet (match, partial,
   or other). A bullet is flagged when a read of a blueprint that places it returns `wider` or
   `contradicts`; a `no-excerpt` alone is not flagged and is counted in its own column. Every verdict
   on the 25 is reported, so a split between two blueprints shows. Bar: 20 of 25, on the raw count
   the design names; the match count is reported beside it, never instead of it. After a tuning round
   the score follows standing answer 3's rule on prompt versions.
4. Before any tuning, STATUS gets the stop question standing answer 3 would send, researched now: the
   count, which bullets missed and why (settling code outside the view, an excerpt that supports the
   wrong claim, or the seat's judgment), what each tuning round changed, and three options with a
   recommendation: count only the 13 false or over-claiming bullets against a proportional bar; widen
   the seat's view again at a measured cost; or give the seat repository access (an agentic read),
   which is new machinery for the next pass. It also carries M1 step 4's projected total when that
   passed $45.

- Live, sync, in the background. Risk class `runner`.

#### R2: the read at `main`, also E's first read (live), by the session

Outcome: the design's replay, part two, and E's round 1.

1. A fresh meter reading, then, in the cairn worktree, in the background:

   ```
   DRAFTER_PAGE_CAP=<min(10, left/8)> /var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter read --sync --json blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml blueprints/docs/extend/debug-your-site.blueprint.yaml blueprints/docs/extend/restrict-admin-access.blueprint.yaml blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml blueprints/docs/extend/scaffolded-site-files.blueprint.yaml blueprints/docs/extend/security-model.blueprint.yaml blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml
   ```

   Commit the lock at once ("Read the eight blueprints with the fact-truth seat"). A whole read that
   blocks writes a bar; one that accepts writes `accepted` with no `facts` (M1's binary), which M2's
   binary reads whole once (finding 10).
2. The session reads every `facttruth` finding against the code and classes it (finding 7): a new
   catch (the code bears the verdict out), a pointer block (`no-excerpt`, or `wider` on a claim the
   code bears out that no excerpt shows), or a false block. Before the bar is judged, one fresh-context
   `general-purpose` reader on `sonnet` at `medium`, on session tokens, gets each pointer-column `wider`
   row (the fact, the quoted excerpt, the code line the session found) and answers per row whether the
   excerpt really lacks the claim; a row where the excerpt shows it is a false block. The table
   reports three counts: finding 7's false blocks, the design-literal count (a `wider` on a claim the
   code bears out), and the pointer column. Bar: zero false blocks. The table, with every finding's
   class, fact, blueprint, and the code line that settles it, goes in STATUS.
3. Every finding of every seat at `main` is E's work list.
4. The bar is judged again on E's first read after M2, which is the first read of every one of the
   eight at `main` under the final prompt: its `facttruth` findings are classed the same way, with
   the same fresh-context check, and a false block there is a traced cause under standing answer 3,
   counted against the same three rounds.

- Live, sync, in the background. Risk class `runner`.

#### R3: the controls (live), by the session

Outcome: the design's controls.

1. Create the controls worktree from the cairn worktree's head after R2's commit:
   `git -C ~/Projects/cairn-cms worktree add -b blueprint-first-controls .claude/worktrees/blueprint-first-controls blueprint-first-pages`,
   and copy `drafter.local.toml` in as T0 step 6 did.
2. Commit A, three seeds in add-cairn (factsheet-cairn section 7, its lines at `main`; the session
   finds each item by id): control 1, delete `s-email-deploy` and set `s-email-request`'s `requires`
   to `branding-set`; control 4, widen `f:26kuvx` to "every other peer is optional, `@anthropic-ai/sdk`,
   `daisyui`, and `tailwindcss` among them"; control 5, set `f:ntdafg`'s claim to its 517 wording, "A
   missing `AUTH_DB` throws `config.bindings-missing`, the condition behind the branded 500 page", and
   add the live page's line, `docs/extend/add-cairn-to-a-sveltekit-app.md:873`, as a further pointer,
   the way a harvested fact cites its page. The page pointer is unlisted prose, so it shows nothing,
   and the seat sees only the code that contradicts the claim.
   Run `BIN check` (0 errors), then a fresh meter reading and:

   ```
   DRAFTER_PAGE_CAP=<min(10, left)> /var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter read --sync --json blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml
   ```

   Then restore the lock with `git checkout -- blueprints/drafted.lock`.
3. Commit B on commit A's parent (`git checkout -b blueprint-first-controls-b HEAD~1` in the
   controls worktree): control 2, set `x-email`'s `handledBy` to a new handoff item `ve-retry`
   reading "Return to [[verify-the-sign-in-email]] and request the sign-in again."; control 3, change
   `f:xxtooz` to "The package ships its six migrations under `migrations/`". `BIN check`, the same
   read command, and the lock restore.
4. Control 6 offline, on a third commit off commit A's parent: in the controls worktree,
   `git checkout -b blueprint-first-controls-c blueprint-first-controls~1`, move `f:vpieos`'s pointer
   `src/lib/github/signing.ts:44,86,217` to `src/lib/github/signing.ts:150`, commit, then `BIN check`
   with no argument: an error on that pointer bites; record its check name.
5. The table: per control, whether it bit, every check or seat that fired at the seed site
   (consistency, fact-truth, blueprint, or `drafter check` with its check name), not only the first,
   the findings verbatim, and any extra catch (the `handler` warning on control 2). Bar: all six bite.
   Remove the controls worktree and its three branches after the table is in STATUS.

- Live, sync, in the background. Risk class `runner`.

#### E's first fix round, in the window, by the session with fix subagents

Once R1's and R3's bars are met (or tuning has met them), and while D2 or D4 is still building, the
session starts E's fix round 1 on R2's work list on session tokens (E's "fix" steps). The round also
adds `prose_sources = ["docs/internal/what-cairn-is-and-is-not.md"]` under `[facts]` in cairn's
committed `drafter.toml` (finding 8). Its reads wait for M2.

### M2: merge, build, and offline checks (25 min), by the session

1. Merge D4's branch, which carries D2 (and any tuning commit is already on the branch). Run the
   named-test check for both, then `make check`, then `make build`, and record `BIN`'s commit.
2. In the cairn worktree: `BIN check` 0 errors (the `covers` check passes over 26 string-only
   entries). Then pick one of the eight whose entry holds `accepted` equal to its blob and no `facts`,
   read the meter (finding 22), run `BIN page --dry-run --json <its page path>`: it refuses with the
   lapse line "no facts recorded", exit 2, and the meter's totals are unchanged. If no entry meets the
   condition, STATUS says so and D2's refusal tests stand for the check.

- Risk class `runner`.

### E: the eight blueprints to the new gate's accept (130 min on the path), by the session with fix subagents

Outcome: each of the eight holds the new accept (`accepted` equal to its blob and a `facts` map
matching the read set), or the record names its open findings. cairn #21's two conflicts, #23's three
items, and every R2 fact-truth finding are fixed or filed. The owner-tier facts (finding 8) and the
rest of the pointer blocks are re-pointed.

- The work list: R2's findings of every seat, then each read's. Fact-truth findings follow standing
  answer 4; pointer blocks are re-pointed (a line range into the owner brief for the owner tier) or, for
  `f:ogz5eu`'s absence claim, rewritten to a claim a pointer can show or cut from the blueprint with a
  disposition; #21's conflicts are settled from the code (`access.ts:177-179` and `guard.ts:476-479`
  for f:p1xmp5; the `create-cairn-site` migrations list for f:rn62i1 and f:gepykz); #23's items are
  fixed in security's disposition, f:q07rd5, and rotate's three `#devvarsexample` links. A verified
  fact whose only pointers are a live page (f:q07rd5 is sourced to
  `docs/extend/add-cairn-to-a-sveltekit-app.md:283-294,...`) now blocks as `no-excerpt` wherever it is
  placed; it is retraced to the code or retagged, as cairn's facts README requires of a page-sourced
  bullet (README:86-88).
- A fix round: one `general-purpose` subagent on `opus` at `high` for all fact edits in the round
  (they share the facts files), then one per blueprint with blueprint edits, each prompt carrying its
  findings verbatim, the skill's file paths, the code lines the session found, and the rule that it
  edits only its named files, runs `BIN check <its blueprint>` (or `BIN check` with no argument and
  `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:facts'` for fact edits) to 0 errors, and never
  commits or runs a read. The session checks `git status --porcelain` names only those files, runs
  standing answer 8's citer listing, and commits the round.
- The read call, after a fresh meter reading and only while `left − reserve > 0` (the meter's
  reserve): every blueprint still blocked, every one of the eight whose entry lacks `facts` (all eight
  on the first call after M2, since R2 ran on M1's binary), and every citer standing answer 8 added,
  by name, smallest first, split as the meter's rule says:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter read --json <each blueprint path, written out>
  ```

  `drafter read` picks the read itself: a bar read for a blocked entry, a whole read for an entry with
  no `facts`, a lapse read for a changed map. The session commits the lock at once ("Record E round
  <n>'s reads"). The first call's `facttruth` findings re-judge the false-block bar (R2 step 4).
- Loop guards and escalation: standing answer 5.
- Check after: for each of the eight, its latest read's status is `accepted` and its lock entry's
  `accepted` equals `git rev-parse HEAD:<blueprint>` and its `facts` matches; or it is escalated with
  its open findings listed in STATUS. `BIN page --dry-run --json` over the eight's page paths prints no
  lapse line for an accepted one.
- Files (cairn): the eight blueprints, the facts files, `blueprints/drafted.lock`, `BACKLOG.md` (filed
  findings). Risk class `runner`.

### B: the tidy blueprint built from the code (240 min), by the session with one author subagent

Outcome: the design's "What it builds" item 8 and "The build"; `blueprints/docs/extend/turn-on-tidy.blueprint.yaml`
holds the new accept.

1. Start: record `git rev-parse HEAD` in the cairn worktree as `TIDY_BASE` in STATUS (the rebuild
   starts here) and create the friction log with one header line.
2. Dispatch the author: `general-purpose` on `opus` at `high`, description `blueprint-first tidy
   author`. Its prompt carries: the skill's file paths (D3's new-page path, not yet tuned); the outline
   entry at `blueprints/outline.yaml` (the `docs/extend/turn-on-tidy.md` entry) and finding 16's line
   correction; the code paths of factsheet-cairn section 5 (the `tidy-*` files and the files the globs
   miss); the existing tidy facts (62 bullets mention tidy; the old brief's 44 ids) as candidates to
   re-verify from code, never to trust; the live page `docs/extend/turn-on-tidy.md` as a map only; the
   path `BIN` for `check` and `excerpt` (never `read`, `page`, or `spend`); the friction log's path and
   its entry form (the skill step or format field met, what happened: a guess, a back-out, a re-read of
   the format page, or a workaround); the covers conversion (the entry's nine lines become `{id, text}`
   mappings, every id claimed by a section or a disposition); and the rule that it edits only the
   outline entry, the new blueprint, and facts bullets, never commits, and ends each turn with
   `BIN check` at 0 errors and a list of what it changed.
3. The loop, by the session: on the author's return, `git status --porcelain` names only those files;
   a meter reading (no rise, per the meter's subagent rule); standing answer 8's citer listing for
   every fact the author edited; commit ("Build the turn-on-tidy blueprint, round <n>"); a fresh meter
   reading; then the read, with N counting tidy and every accepted citer of the eight the round's fact
   edits lapsed, each written out:

   ```
   DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter read --json blueprints/docs/extend/turn-on-tidy.blueprint.yaml <each lapsed citer's blueprint path>
   ```

   commit the lock, and record the round in STATUS: blocking findings by seat, spend, minutes. On a
   block, continue the same author with `SendMessage`, carrying every finding verbatim; polish goes in
   that turn, before the next read. Stop at the first accept. A citer of the eight that blocks on a
   tidy fact edit goes back to E's rules (standing answer 5).
4. The first read's blocking findings, by seat and class, are the skill's misses; they go to STATUS
   for S.
5. At the accept, two offline checks, recorded in STATUS and the round table. `BIN check
   blueprints/docs/extend/turn-on-tidy.blueprint.yaml` prints no `no-excerpt` warning, so no verified
   fact rests on a live page alone (finding 8 makes such a fact block, so the accept already implies
   it; the check records it). And the covers check bites: drop one section's covers id in the working
   tree, `BIN check` reports a `covers` error, then `git checkout --` the file and confirm `git status
   --porcelain` prints nothing.

- No cap on rounds (standing answer 6). Risk class `runner`. Files (cairn): `blueprints/outline.yaml`
  (the tidy entry), the new blueprint, the facts files, the lock.

### S: the skill tuned and the exemplar (40 min), by the session

Outcome: the design's "The skill" steps 2, 3, and 5 (step 5's `prose-voice-reviewer` read runs once,
at Close step 3, over the skill and drafter's docs together).

- Each class of B's first-read misses folds into `new-page.md` as a step or an exemplar passage, never
  as a rule appended to a list. A passage written into `new-page.md` draws its example from one of the
  eight blueprints or from synthetic text, never from the tidy blueprint or its facts, because RB
  measures the skill on the tidy page with the exemplar withheld. A friction-log point in the format
  itself goes to standing answer 7.
- The friction log closes: STATUS gets a table of every entry with its disposition (folded into a
  step, folded into a passage, a format change under standing answer 7, or no action with the
  reason). The record carries it.
- `claude/.claude/skills/blueprint/exemplar.md`: the accepted tidy blueprint and its fact bullets,
  section by section, each with one sentence saying what it shows. `new-page.md` links it once; it links
  nothing further. Reference depth stays `SKILL.md` to `new-page.md` to `format.md` or `exemplar.md`.
- Acceptance: `make check` green (the install test's link check covers `exemplar.md`); one commit,
  "Tune the blueprint skill from the tidy build". Risk class `runner`.

### RB: the fresh rebuild (60 min), by the session with one author subagent

Outcome: the design's "The skill" step 4.

1. `git -C ~/Projects/cairn-cms worktree add -b blueprint-first-rebuild .claude/worktrees/blueprint-first-rebuild <TIDY_BASE>`;
   copy `drafter.local.toml` in. Copy the tuned skill's files except `exemplar.md` with `cp -L` (the
   skill's `format.md`, `anatomies.md`, and `introductions.md` are relative symlinks) into
   the rebuild worktree's own git dir, at the path `git -C
   /var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-rebuild rev-parse
   --absolute-git-dir` prints plus `/rebuild-skill/` (expected
   `/var/home/glw907/Projects/cairn-cms/.git/worktrees/blueprint-first-rebuild/rebuild-skill/`), after
   `rm -rf` on that path so no stale file survives. It is the one place the author is told to read
   the skill; it holds no STATUS or friction log, and `git worktree remove` deletes it. Then `grep -rn -e turn-on-tidy -e tidy` over the copy, and over the tidy
   blueprint's item ids; any hit is rewritten on the drafter branch from the eight or synthetic text
   (S's rule), committed, and copied again before dispatch.
2. Dispatch a fresh author, `opus` at `high`, with B step 2's prompt, the rebuild worktree's paths,
   the copied skill path, and no friction log, finding list, or pointer to the first build. The
   prompt says that `exemplar.md` is absent on purpose, and that it reads nothing outside the rebuild
   worktree, the skill copy, and the code: no other branch (`git log`, `git show`, or a checkout of
   one), no other worktree, and no drafter git dir.
3. On its return, commit, a fresh meter reading, and one read:

   ```
   DRAFTER_PAGE_CAP=<min(10, left)> /var/home/glw907/Projects/drafter/.claude/worktrees/blueprint-first/drafter read --json blueprints/docs/extend/turn-on-tidy.blueprint.yaml
   ```

4. The comparison in STATUS: the rebuild's first-read blocking findings by seat against B's first
   read. Bar: fewer, on the total of blocking findings across the three seats; the counts by seat
   are reported either way, beside both builds' item counts and placed-fact counts, so a smaller
   rebuild's lower count shows as such. Remove the rebuild worktree (which takes the skill copy) and
   its branch.

- Risk class `runner`.

### K: the end-to-end check and the research record (30 min), by the session

1. The design's "Check", in the cairn worktree:
   1. B's final read is step 1 when no drafter commit changing Go code and no cairn commit touching
      the tidy blueprint or a fact it cites has landed since it: that read ran `BIN read --json
      blueprints/docs/extend/turn-on-tidy.blueprint.yaml` with no mode flag on M2's binary. Cite it:
      its `state.json` intents record `mode` `sync` (`run.Intent.Mode`, set from the config at
      `internal/pipeline/money.go:131`; the summary JSON carries no mode), it returned `accepted` with
      no blocking finding from any seat, and the lock entry for `docs/extend/turn-on-tidy.md` holds
      `accepted` and `facts`. If such a commit has landed, run the read again, with a fresh meter
      reading and `DRAFTER_PAGE_CAP=<min(10, left)>`, and check the same three things.
   2. Pick a fact a `fact` item of the tidy blueprint places that only tidy cites (`BIN refs f:<id>`
      lists tidy alone), and edit its bullet to a claim the code contradicts (a number or name its
      excerpt shows, such as `MAX_TIDY_CHARS = 24_000` at `src/lib/sveltekit/content-routes-tidy.ts:51`
      stated as 12,000). Commit. Run `BIN page --dry-run --json docs/extend/turn-on-tidy.md` first: it
      refuses with the lapse line naming that fact id, exit 2. Only then, with a meter reading before
      and after (finding 22), run `DRAFTER_PAGE_CAP=0.01 BIN page --json docs/extend/turn-on-tidy.md`
      (written out in full): it refuses the same way, exit 2, and the meter's totals are unchanged. The
      lapse check sits before any pricing, so a working refusal prints its line first; a broken one
      escalates on the cap before any request goes out, and the check fails, as it should.
   3. A fresh meter reading, then `DRAFTER_PAGE_CAP=<min(10, left)> BIN read --json
      blueprints/docs/extend/turn-on-tidy.blueprint.yaml` (written out in full): a lapse read that
      blocks on that fact with verdict `contradicts`, quoting the excerpt. `git status --porcelain`
      then prints nothing, since a blocking lapse read writes nothing to the lock (finding 21). Then
      `git revert` the edit, and `BIN page --dry-run --json docs/extend/turn-on-tidy.md` no longer
      prints the lapse line.
2. The research record, in the record worktree
   (`git -C ~/Projects/initiatives worktree add -b blueprint-first-proof .claude/worktrees/blueprint-first-proof origin/main`):
   `docs-system/research/<date>-drafter-blueprint-first-proof.md`, written to the developer register
   the record's siblings use, opening with `## Brief`. It carries the replay's 25-row table and its
   count, its match column, and the prompt version behind each verdict, R2's and E's first read's
   classed findings with the three false-block counts, the controls table, the eight's table (status,
   reads, rounds, open findings), the build's round table (rounds, reads, blocking findings by seat
   per round, spend, session minutes), the rebuild comparison, the friction log whole with its
   disposition table, every tuning round, the spend by item, the residual of finding 19, and the
   figures the next design's estimate takes. The record carries every table STATUS holds, since STATUS
   lives in a git dir that `git worktree remove` deletes; the drafter worktree stays until the packet
   is decided. Commit, push
   `blueprint-first-proof` to `glw907/initiatives`, and open its PR. The executor never merges it.

- Risk class `runner`.

### Run rules for every live call

- The tree. A read needs a clean tree at its start. The session commits before each live call (or
  restores the lock in the replay and controls worktrees) and never edits a worktree while a call
  runs in it. One live call runs at a time, pass-wide.
- Background. Every live `BIN read` runs with `run_in_background: true`, its stdout to
  `/var/home/glw907/Projects/drafter/.git/worktrees/blueprint-first/live-<row>.json` and its stderr to
  `…/live-<row>.log`, both named in the call's STATUS row, written before the call starts. The row
  gets the run id from the log as soon as it prints.
- A sync read that stops (exit 3) resumes once, on a fresh meter reading, with
  `DRAFTER_PAGE_CAP=<min(10, left/N)> BIN read --resume <id> --json <the run's blueprint paths, as the
  call gave them>` (written out in full, plus `--sync` for a run started on M1's binary, whose default
  was batch). `--resume` never takes `--since`. Nothing in that worktree changes, committed or not, between
  the stop and the resume, and no fix subagent works in it meanwhile: a resume reloads the facts from the working tree (`internal/pipeline/resume.go`,
  `plan.LoadFacts(cfg.Facts.Dir)`) and accepts any descendant HEAD, so a fact edit in between would
  put bullets no request judged into the map. A second stop of the same run abandons it: its
  `open.worst` goes to STATUS, the session waits on the `/loop` wake-up, and its blueprints read
  fresh. A third stop is standing answer 11. A run started on a binary other than the current `BIN`
  is abandoned, never resumed (backlog #29): its `open.worst` goes to STATUS and the next drafter
  commit's body, and its blueprints read fresh.
- No live command runs under `make check`, and neither `make check` nor `make build` runs while a live
  call runs, since both rebuild `BIN` in place. `make smoke` never runs.

## Checks

Each row maps to the design's "Check" and "The proof".

- The replay: 20 or more of 25 flagged `wider` or `contradicts` at `517158fae` (R1), scored by
  standing answer 3's rule on prompt versions, and zero false blocks at `main` (R2, and again on E's
  first read under the final prompt), after at most three tuning rounds.
- The controls: six of six bite (R3).
- The eight: each accepted under the new gate, or escalated with its open findings (E).
- The build: the tidy blueprint accepted (B), with its rounds, reads, findings by seat, spend, and
  minutes.
- The skill: the rebuild's first read blocks on fewer findings than B's first read (RB).
- The design's end-to-end check, steps 1 to 3 (K step 1).

## Close (65 min)

1. drafter: the gate on the close head from the worktree, `DRAFTER_DIR="$PWD" bash
   scripts/drafter-gate.sh` through `cairn-run-gate`, re-issued on exit 75. drafter has no CI, so this
   is its full-suite home.
2. cairn, with `BIN` rebuilt from the drafter close head: `BIN check` 0 errors; standing answer 9's
   hand edits, committed as "Align live pages with the corrected facts"; the cairn fast lane's line 1,
   `node scripts/checks/gate-tier.mjs --fast --range <BASE>..HEAD`, through `cairn-run-gate`, and its
   component line with `RUN_GATE_IF_BUSY=defer`, since cairn CI is the full-suite home.
3. One whole-branch `diff-reviewer` read of drafter's branch against this plan and the design, and one
   of cairn's hand-written files only: the outline entry, `drafter.toml`, the live-page hand edits,
   and `BACKLOG.md`. The facts, the blueprints, and the lock are what the gate's own reads judged, so
   the review leaves them out. `prose-voice-reviewer` reads drafter's changed `docs/` pages and the
   skill's `SKILL.md`, `new-page.md`, and `exemplar.md` (the design's "The skill" step 5). One batched
   fix chain follows, each dispatch quoting the reviewer's finding verbatim as its acceptance, then
   the gates again; a second review only on a blocker. A fix that changes a blueprint or fact an
   accepted entry cites lapses it, and that blueprint reads again inside the budget.
4. The accepts at the close head, before any push: `BIN page --dry-run --json` over the eight's and
   tidy's page paths, written out. Every page the eight's table reports as accepted prints no lapse
   line. A lapsed page reads again inside the budget, or the table reports it as open.
5. The leak check, over both code branches and every PR body: the added lines of `git diff
   origin/main...HEAD` (`grep '^+'`) and each PR body file before `gh pr create`, grepped for `/home/`,
   `/var/home/`, `thinkpad-x1`, `pavilion`, `.claude/worktrees`, and `cairn-cms.local.toml`, print
   nothing. drafter's `exemplar.md` names cairn repository paths, which are public.
6. cairn: push `blueprint-first-pages` to `glw907/cairn-cms` and open a draft PR; run `ci-green <sha>
   --pr <n> --wait` in the background. A red from this branch's files is fixed on the branch (standing
   answer 9 for a live page or brief). A red elsewhere is reported.
7. drafter: push `worktree-blueprint-first` to `glw907/drafter` and open its PR.
8. Each PR body opens with `## Brief`, per `~/.claude/docs/voice/approval-brief.md`, links the others,
   and states the merge order.
   - The drafter PR: what landed; the offline acceptance rows; the live spend and every meter reading;
     any abandoned run with its `open.worst`; `## Decisions` (findings 1 to 23, finding 19's residual
     named as an entry condition of the drafting pass, every tuning round, every format change under
     standing answer 7); the score per pass-core "Score", with Work and review naming 1080 path
     minutes beside the actual.
   - The cairn PR: the replay count and table, the three false-block counts, the controls table, the
     eight's table, the build's round table, the rebuild comparison, K's check rows, every fact fixed
     and every finding filed with its backlog number, and `## Decisions` (finding 16's line, the
     `prose_sources` line, standing answer 8's citers, standing answer 9's hand edits).
   - The record PR: the record's brief, linking both code PRs.
9. Backlogs through `log-issue`, tagged `#initiative:docs-system`, each listed in its PR body: drafter,
   close #20 and #28, and file what the run found; cairn, close #21 and #23, update #25's text with the
   counts that remain, and file each fact-truth finding left open under standing answer 4.
10. Remove the replay worktree (`git -C ~/Projects/cairn-cms worktree remove
    .claude/worktrees/blueprint-first-replay`) and the main rerun worktree if one was made. The
    controls and rebuild worktrees were removed at R3 and RB. The drafter worktree stays.
11. Stop at PR-ready for all three PRs. The executor never runs `approval-queue` and never merges;
    `conductor-drafter` hands the packet to Geoff.

## Merge order

1. glw907/drafter's PR first, with `--match-head-commit` from the decision. Pull `~/Projects/drafter`.
   Check for unfinished runs (every `~/.local/state/drafter/runs/*/*/state.json` with a `stopped` key
   or a page whose status is `running`, `pending`, or `held`), minus the abandoned runs the PR lists:
   the new `[seat.facttruth]` changes every run's fingerprint, so a run stopped on the old binary can't
   resume after the merge. On a hit, hold `make install` and name the run. Otherwise `make install`.
   The other workstation checks for its own stopped runs the same way, then pulls and runs `make
   install` before it runs drafter on cairn, since an older drafter refuses a lock carrying `facts`,
   or a bar finding carrying `seat` or `kind` (`KnownFields(true)`, `internal/blueprint/lock.go:60`), or
   a `drafter.toml` carrying `facts.prose_sources` (config files decode strictly, `internal/config/file.go`
   `decode`), which fails every command, not only the lock.
2. glw907/cairn-cms's PR second, with a merge commit, never squash or rebase. A conflict in
   `blueprints/drafted.lock` stops the merge and is reported. Pull `~/Projects/cairn-cms`, then run
   `drafter page --dry-run --json` over the eight's and tidy's page paths on `main`: an accepted page
   prints no lapse line, or the merge report names the mismatch.
3. glw907/initiatives's record PR, merged by the conductor with its hand-over.

## Later

Kept out of this pass and never built here:

- The acceptance machinery (the second fix verdict, the reader loop #18, the per-page cap), drafting
  any page, and batch latency (design, "Out of scope"). drafter #24 stays filed.
- Covers ids for the other 25 outline entries; a store-wide consistency sweep (design, "Later").
- An agentic fact-truth read with repository access, unless the replay's stop puts it to Geoff.
- `verify.go`'s skip of dotted names in the store check; the no-excerpt warning covers what the read
  sees.
- Finding 19's residual: `drafter page` refusing a page with no `facts` map whose `accepted` is
  stale, which the design's "Later" gives the drafting pass ("drafting from gated blueprints only").
- Computing the facts map at a commit through git rather than from the working tree, and a
  `--resume` that refuses when the facts moved since the stop. The run rule (no commit between a stop
  and its resume) covers this pass, whose session is the only writer, and `resume.go` is off limits.
- The change read's "was:" text, recoverable from the lock's history (finding 3).
- `facts.prose_sources` joining the run fingerprint; `fingerprint.go` is off limits here, and the run
  rule (nothing changes between a stop and its resume) covers this pass.
