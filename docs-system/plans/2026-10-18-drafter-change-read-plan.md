# drafter change-read pass plan: judge the change, then rerun the format test

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-change-read-design.md`, approved
by Geoff on 2026-10-18 (glw907/initiatives#17, merge `56b2c9c`). It reworks B2's scoped read
(glw907/drafter#47) and reruns B2's format test. Facts below are quoted at drafter `main` after
#47 (`f7d9034`) and cairn-cms `50dc211d9`. Review: three lenses, folded in
`plans/2026-10-18-drafter-change-read-plan-fold.md`.

## Outcome

`drafter read --since <rev>` judges the change against its diff, as a code reviewer reads a pull
request. It blocks only on what the change adds, alters, or breaks, and reports older defects as
non-blocking. The consistency read under `--since` blocks only on a conflict that touches a fact
the change touched. The skill carries backlog #3 and #4. B2's format test reruns with its five
prompts and its bar, four of five by the raw first-try count.

The pass adds no setting, file, or install step a new project needs (Geoff, 2026-10-18: setting up
drafter on a new project must be highly ergonomic for a new developer).

- Risk class `runner` (the read's workflow prompt and the skill). `live-account`: API credit,
  budget $10.
- Path estimate: 260 minutes. CR.1 (150), with CR.2 (15) run by the session in CR.1's shadow; then
  CR.3 (80, using `--sync`, so no batch waits); then Close (30). The design's estimate is 120, and
  260 is 2.2x, inside the standing answer's 360.
- Clock file: the drafter worktree's git dir, except CR.3, which writes it in the cairn worktree's
  git dir with the session's cwd there.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-18):
  1. A plan up to 360 path minutes proceeds.
  2. A format test below four of five closes the pass with the result. The PR's packet then asks
     Geoff what comes next, and no further pass starts on its own.
  3. A read that blocks on an untouched item is recorded and doesn't stop the test.
  4. Live spend: as B2's plan standing answer 4 (`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md`).
     The baseline is `drafter spend --since 2026-10-18 --json`'s `total` read at launch (it read
     $3.18 at planning, not B2's $2.28). This pass's spend is the meter minus that baseline, plus
     each headless session's `total_cost_usd` from its stream's `result` event, and that sum is
     checked against $10 before each dispatch. A resume uses the worktree binary and
     `DRAFTER_PROMPTS`, as B2's did.
- Depends on, checked at launch:
  - One executor per worktree: `pgrep -f` on the two worktree paths this pass creates finds
    nothing, `claude agents --json` shows no session in drafter or cairn-cms, both main checkouts
    are clean and on `main`, and no worktree named `change-read` or `format-test` exists in either
    repo.
  - drafter `origin/main` holds #47 (`internal/blueprint/since.go` exists).
  - `DRAFTER_API_KEY` in `~/.local/secrets` (by name); `drafter spend --json` shows `open.count` 0.
  - `readlink -f ~/.claude/skills/blueprint` is `~/Projects/drafter/claude/.claude/skills/blueprint`,
    recorded as the link to restore.

## Design resolutions

1. **What `Compare` returns.** `internal/blueprint/since.go`'s `Compare` keeps its three kinds.
   `ScopeUnchanged` means nothing a read sees differs: the entry, the fields outside `sections`,
   the sections' ids, order, and levels, their content, and the bullets of facts the page places or
   cites. `ScopeWhole` means only that there is no earlier blueprint to diff against: the
   blueprint absent or undecodable at `<rev>`, as the design says. Two more whole cases are
   departures, kept because no diff can be built: a current blueprint that won't decode (its fault
   is the check's), and a page missing from the outline at `<rev>` or at head. Every other change
   is `ScopeScoped`, including a removed section, an order or level change with no content change,
   a field outside `sections`, and an outline-entry change. `Scope.IDs` keeps the changed section
   ids (possibly empty), for the record. `Scope` gains `Facts`, tagged `json:"facts"` without
   `omitempty` and never nil on a scoped page. It is the union, over the old and new versions of
   every new, removed, or differing item (matched by id; ids are unique across sections and items,
   `decode.go:52`) and every differing page-level field, of the facts each places or cites, plus
   every fact the page places or cites at either revision whose bullet changed. A fact the page
   never cites is not in it, and its bullet change leaves the page unchanged.
2. **The change block.** `scopePages` (`cmd/drafter/read.go`) already holds both commit-pinned
   revisions. For each scoped page it builds one block there: `git diff --no-color --no-ext-diff
   --no-textconv <since> <head> -- <blueprint path>`, then each changed fact bullet in `Scope.Facts`
   with its old and new text by id, then the outline entry's old and new JSON when it changed. The
   block reaches the pipeline through `Options` beside `Scopes` and is persisted in the page's
   `work` (an additive field set in `start.go`, off `Scope` so it stays out of `--json`). A resume
   reads it from state, so the resumed request sends the same bytes and needs no `<rev>`. The
   blueprint read's request carries it as data after `assemble.BlueprintBlock`, never as prompt
   text. It states its own delimiters, none a `=== file:` line, and `BlueprintBlock`'s "They are
   everything you read." is not left contradicting it. A whole read sends no change block.
3. **The prompt.** The change-read paragraph keys on `Scope.Kind == ScopeScoped`, never on
   non-empty ids: drafter sets the seat context's `scope` for every scoped page (the ids, or `page`
   when there are none), so an outline-only or order-only change renders the change read.
   `blueprintPrompt(scope)` replaces B2's scope paragraph with one that names the change block. It
   says to read the whole blueprint for context and judge the change as a code reviewer judges a
   pull request. A finding blocks only for a defect in what the change adds or alters, or one the
   change causes elsewhere, and that second kind is located at the changed item that causes it.
   Every other defect is non-blocking, with its finding starting "Already present:". The design's
   Google sources are quoted in the paragraph as the other blocks quote theirs. The unscoped render
   still equals B2's golden. `scopeText` (`cmd/drafter/page.go`) prints `scoped: page` when `IDs` is
   empty.
4. **The consistency rule.** In `completeBlueprintRead` (`internal/pipeline/blueprint.go`), a
   scoped page demotes a conflict only when its `facts` is non-empty, every id in it is a store id
   outside `Scope.Facts`, and `with` is exactly a store id outside `Scope.Facts` or exactly a page
   the plan links (as `ConsistencyPrompt` lists them). Every other conflict is touched, including
   an empty `facts`, an unknown id, and a `with` that matches neither form, so the rule fails
   closed. When any conflict is touched the page escalates on `consistency` listing every conflict,
   as today. When none is, each goes to the record as a warning starting "Already present:", and
   the page goes on to the blueprint verdict. A whole read escalates on any conflict, as today. A
   scoped page from a state that predates `Scope.Facts` (nil after decode) reads as whole for the
   prompt and this rule, and still writes no lock. The consistency prompt doesn't change. A conflict
   a new or changed `link` item causes, with untouched facts and a linked page in `with`, is
   demoted in this pass (planning ruling 3; none of the five tweaks adds a link; see "Later").
5. **What a read reports.** The record keeps the blueprint read's findings on every verdict, so an
   `ok` change read keeps its "Already present:" findings. The run summary, text and `--json`,
   prints per page a count of demoted conflicts and of "Already present:" findings.
6. **The lock.** A scoped accept still writes no lock (B2's rule, now covering every `--since` read
   that isn't whole).
7. **The skill.** `claude/.claude/skills/blueprint/SKILL.md` already says to run `drafter refs`
   before correcting a fact, but only under case 1 (a code change), and B2's fact-correction agent
   grepped instead. CR.2 puts that step where a fact correction found while reading happens (case 2),
   and adds one sentence: a caution about something that can go wrong is a `failure` item with a
   handler, linking [the edit catalog](format.md#the-edit-catalog) and naming its "Add a failure
   case" row, as `SKILL.md:17` links rows. No rule is copied.
8. **The format test.** B2.4's protocol (`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md`,
   resolution 9 and task B2.4), with these differences:
   - The cairn worktree is `format-test`, cut at `50dc211d9` so the base is identical to B2's.
   - The config copy, the probe session, and the harness flags are B2's, with B2's `--add-dir` grant
     pointed at this pass's drafter worktree. One known difference: `drafter-page-hook` is now live in
     `~/.claude/settings.json` and runs in every tweak session.
   - The skill link is never removed (planning ruling 5): it points at `<drafter
     wt>/claude/.claude/skills/blueprint`, confirmed with `readlink -f`, for the test, and is restored
     to `~/Projects/drafter/claude/.claude/skills/blueprint` at CR.3's end and on any stop path.
   - The five prompts are the ones drafter#47's body records, verbatim, each sent as "Use the
     blueprint skill." plus the prompt plus "Commit the change.", as B2's sessions were.
   - The pass rule: `drafter check` green, the read exits 0, no finding with `blocking: true`, and no
     "Already present:" finding that sits on the change. The executor classifies each "Already
     present:" finding, and each escalated conflict, against `git show <base>:<blueprint>`: present
     at base (quote the base lines) or introduced (on a diff line, or caused by the diff). An
     introduced one counts as a miss (planning ruling 1). The bar is four of five by this raw count.
   - Control 1 is B2's: a commit to a clean section whose step relies on state no earlier step
     produces, `requires` silent. Its source is B2's executor transcript
     (`~/.claude/projects/-var-home-glw907-Projects-drafter--claude-worktrees-b2-blueprint-skill/69b40c50-ef79-4971-9804-17db5aacf17b.jsonl`,
     the `s-interval` step); if the patch can't be recovered from it, it is re-seeded to that
     description and its row marked "re-seeded". Expected: a blocking finding at the seeded step.
   - Control 2 (planning ruling 2), outside the bar, about $0.35: a commit that changes one item so
     an untouched section's `requires` now has no source. Expected: a blocking finding located at
     the changed item.
   - Patches and rows are kept outside the public repo and outside any worktree's git dir (the
     session's scratchpad), so they survive the worktree's removal.

## Tasks

### CR.1: the change read (150 min)

- Risk class: `runner`.
- Outcome: resolutions 1 to 6.
- Files: `internal/blueprint/since.go` and its test; `cmd/drafter/read.go` (`scopePages`, the
  `--since` help text, `scopedAccept`'s comment) and `read_test.go`; `cmd/drafter/page.go`
  (`scopeText`, the summary counts); `internal/pipeline/pipeline.go` (`Options`, `PageResult`),
  `start.go`, `work.go`, `blueprint.go` and its test; `internal/assemble` (the change block beside
  `BlueprintBlock`); `claude/.claude/workflows/docs-page-chain.js` (`blueprintPrompt`);
  `internal/pipeline/testdata/module.js` (if its blueprint seat must echo the change);
  `tests/fixtures/drafter/matrix.json`; `docs/blueprint-format.md` (the "What `drafter read` does
  with a blueprint" section's `--since` sentences).
- Acceptance:
  - `Compare` table: a removed section, an order change, a level change, a page-level field, an
    outline-entry change, and a changed fact cited only from framing, the introduction, or the
    dispositions are scoped, each with its `Scope.Facts`; the removal and reorder with no content
    change and the entry change have empty `IDs`. An item edited from fact A to fact B has both in
    `Scope.Facts` and no others. An uncited fact's bullet change leaves the page unchanged. Absent
    and undecodable at `<rev>` stay whole.
  - Change block, with a since commit earlier than head that edits one item, one cited bullet, and
    the outline entry: the request holds the item's hunk, the fact id with both texts, and the
    entry's old and new JSON, after `BlueprintBlock` in the data and not in the prompt. With the
    entry unchanged, no entry JSON. A whole read sends no block. A resumed scoped page sends the
    same block bytes as the first attempt, and its `Scope.Facts` survives the round trip.
  - An outline-only change (empty `IDs`) yields a request carrying the change-read paragraph and
    the change block, and a summary line `scoped: page`.
  - Consistency table, each with a blueprint answer of `ok`: an untouched fact conflict accepts
    and records the "Already present:" warning and the consistency verdict; a touched fact in
    `facts` escalates naming `consistency`; a touched fact only in `with` escalates; an empty
    `facts`, an unknown id, and an unmatched `with` each escalate; a whole read escalates on an
    untouched conflict; an untouched conflict with a blueprint `fix` escalates on `blueprint`; a
    scoped state with no `facts` key escalates on an untouched conflict.
  - A scoped `ok` read with one non-blocking "Already present:" finding accepts, the record keeps
    the finding, and the summary counts it.
  - The unscoped blueprint render equals B2's golden. The scoped render contains the change block's
    name, the "Already present:" instruction, "Verdict \"fix\" if any blocking finding exists", and
    the Google sources (the assertion at `read_test.go:242`, revised).
  - "A whole accept under --since writes the lock" (`read_test.go:562`) uses a blueprint absent at
    `<rev>`; a removed-section accept writes no lock.
  - `tests/drafter-prompts-parity.sh` passes, with its scoped matrix case updated.
- Gate: `make check`. `money.go` and `resume.go` are untouched; a need to edit either stops the
  line.

### CR.2: the skill's `refs` step and failure sentence (15 min), run by the session in CR.1's shadow

- Risk class: `runner`.
- Outcome: resolution 7.
- Files: `claude/.claude/skills/blueprint/SKILL.md`.
- Acceptance: case 2 carries the `drafter refs` step for a fact correction, the failure sentence is
  present, its link is `format.md#the-edit-catalog` (an anchor `docs/blueprint-format.md` holds)
  naming the "Add a failure case" row, and Vale with `--config ~/Projects/cairn-cms/.vale.ini`
  reports no error "in 1 file".
- Gate: `make check`.

### CR.3: the format test, rerun (80 min)

- Risk class: `runner` (live spend).
- Outcome: resolution 8, run live from the worktree binary by path with `DRAFTER_PROMPTS` set.
- Before it: B2.4's pre-flight, with the skill link swapped to the worktree and confirmed
  (resolution 8), and the control 1 patch recovered or re-seeded.
- Acceptance: the result table, five rows and two control rows. Each row holds B2.4's fields (the
  verbatim prompt, whether the skill fired, whether `refs` ran before the edit for tweak 2, files
  read outside the worktree and the skill, files the commit touched, `drafter check`'s result, the
  scope, the read's verdict, blocking count, and cost, and every finding classified, non-blocking
  included), plus: blocking findings on the change, blocking findings on untouched items, "Already
  present:" findings on the change, the consistency outcome with each escalated conflict
  classified against base, and the summary's demoted-conflict count. Each control row shows its
  expected blocking finding at its expected location. The raw count against the bar, and the
  session plus meter spend. Afterwards `readlink -f ~/.claude/skills/blueprint` is the main
  checkout's skill directory again, and the format-test worktree and branch are removed.

### Close (30 min)

- The drafter gate (`DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh`, re-issued on exit 75) on the
  close head is the full-suite home.
- Whole-branch `diff-reviewer`; one fix chain; the gate again.
- `BACKLOG.md`: #2 closed, citing the design's 2026-10-18 probe, which showed a headless session is
  denied a read of a real file inside a user-scope skill directory. #3 closed only if tweak 2's
  transcript shows `drafter refs` before the edit, and #4 only if tweak 4's commit adds a `failure`
  item with `handledBy`; otherwise each stays open with its row. #1 closed if the bar is met, or
  left open with the result. New follow-ups go through `log-issue`.
- A comment on drafter#43 with the rerun's table. The issue closes if the bar is met.
- The PR body opens with `## Brief` and carries the table, the classified findings, and the score.
  The executor stops at PR-ready, and `conductor-drafter` sends the packet.

## Merge order

1. glw907/drafter, then pull `~/Projects/drafter` and `make -C ~/Projects/drafter install`.

## Later

- Drafter recomputing the verdict from findings' locations, if the test shows a blocking finding
  on an untouched item.
- A conflict caused by a new or changed `link` item blocks (planning ruling 3).
- Writing the lock on a change-read accept (B3). Before a scoped accept may write the lock, B3
  persists demoted conflicts and "Already present:" findings durably, beyond a pruned run directory
  (planning ruling 4).
