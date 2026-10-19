# drafter pass B3 plan: drafting from blueprints

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-19-drafter-b3-drafting-design.md`,
approved by Geoff on 2026-10-19 (glw907/initiatives#38). He ruled both forks as recommended:

- **Split.** cairn's half moves to a later pass, B3c, and is out of scope here: converting cairn's
  stage 2b plans, the whole-read bar from drafter backlog #13, and the cairn pilot drafts.
- **Allow `resume.go` edits.** Each is written test-first, and each commit touching
  `internal/pipeline/resume.go` gets a `diff-reviewer` read at task scope, with its auth-data bar,
  before the next task starts. `internal/pipeline/money.go` stays a hard stop.

Scope comes from the B1 plan's "Build sequence" item 3 and the onboarding design's "The standard
package" table and "B3 additions" (`specs/2026-10-18-drafter-onboarding-design.md`). The
architecture spec's "Scope of a redraft" and "Human edits" sections
(`specs/2026-10-17-blueprint-architecture-design.md`) set the redraft rules.

Code: facts are quoted at drafter `main` `f286162` and cairn-cms `main` `11104274e`. Lines move; the
executor finds each quoted symbol by name. Planning probes ran on 2026-10-19 in
`/tmp/claude-1000/-var-home-glw907-Projects-drafter/98272137-e879-4cd3-b816-037dd2bfda73/scratchpad/plan-probes/`.
The factsheets are `docs-system/research/2026-10-19-drafter-b3-factsheet-pipeline.md` and
`…-factsheet-provenance.md`.

## Findings for the planning session

None of these changes the approved design. Each is decided below so the run can launch, and the
planning session confirms or overrides each before launch.

1. **The spend meter already reads $9.44.** At planning, `drafter spend --since 2026-10-19 --json`
   printed `total 9.4436516`, `open {count: 0, worst: 0}`, from tonight's earlier runs. The plan reads
   the $20 standing answer as this pass's own spend: the meter minus a baseline the executor records
   at its first execution commit, plus `open.worst`. If Geoff meant the meter's absolute reading,
   the pass has $10.56. That covers about one and a half live attempts. To use that reading, change
   the one sentence in "Standing answers" item 2.
2. **The lock has no commit, so the old revision is inferred.** Resolution 3 takes the old outline
   entry and facts from the parent of the commit that introduced the page's current lock entry.
   Here is the case that resolution can't settle. A fact bullet changes, the redraft writes
   byte-identical text, and the lock entry comes out byte-identical too. The next run then sees
   the same fact change and redrafts again. B4's commit field closes this. Until then, the case
   goes in "Later".
3. **A skipped read also skips the consistency read.** When the lock's `accepted` equals the
   current blueprint blob, the blueprint read is skipped, and the consistency read is skipped with
   it, since the one stage-1 batch carries both. A fact bullet changed after that read then drafts
   with no fresh consistency read. The design rules the skip, so the plan keeps it and lists the gap
   in "Later".
4. **Human edits stay B4's.** B3 redrafts the page as committed at HEAD. A hand edit outside the
   changed sections survives, because of the region bound. One inside them may be rewritten. The
   lock then records the new page. The plan adds no detection.

## Outcome

On a synthetic project with no prompts module, `drafter page docs/x.md` (or its blueprint path)
does the following:

1. It drafts the page whole from its blueprint on drafter's stock prompts.
2. The page passes the stock gate, including the new provenance check.
3. drafter writes the page's `drafted.lock` entry.

After a one-item blueprint edit, committed, the next run redrafts only that section. It reads the
whole page once for coherence and updates the lock. A third run spends nothing and says the page is
up to date. Handoff files and `--workflow-run` keep working. `drafter check-prompts` renders every
stock seat against the fixture. It finds no path the fixture lacks and no cairn-only name.

- Risk class `runner`: the stock prompts, the gate tool, and the pipeline. It's `live-account` for
  API spend only, in B3.7's live check. No GitHub, Cloudflare, or npm account is touched. Repo:
  `glw907/drafter` only; cairn-cms is read, never changed.
- `internal/pipeline/money.go` is never edited; a need to edit it stops the line. An edit to
  `internal/pipeline/resume.go` follows the ALLOW ruling above. None is expected: the lock is written
  after `pipeline.Run` returns (resolution 2), and `resume.go` has no switch on step names
  (factsheet "Step machinery").
- Path estimate: 500 minutes, against the design's 360 (1.39x), inside the 720-minute standing
  answer. The chain:
  - B3.0: 50.
  - Pair A: 170. B3.1 (170) runs beside B3.3 (130), and the session runs B3.2 (90) in the pair's
    shadow.
  - Merge: 5.
  - Pair B: 110. B3.4 (110) runs beside B3.5 (50), and the session runs B3.6 (40) in the shadow.
  - Merge: 5.
  - B3.7: 120.
  - Close: 40.

  The sum is 50 + 170 + 5 + 110 + 5 + 120 + 40 = 500. F2 planned 310 and closed early. B3 adds the
  redraft path and six stock prompts to a pass of F2's shape. B3.7 carries batch waits for the
  live rows.
- Clock file: `pass-task-clock` in the session worktree's git dir (`git rev-parse
  --absolute-git-dir` run in `.claude/worktrees/b3-drafting`). During a pair it holds the task the
  session runs in the shadow. When a pair returns, the session checks each pair task against twice
  its estimate.
- Executor session name `drafter-b3-drafting`. Worktree name `b3-drafting`. Each pair subagent's
  `description` is `b3-drafting task <n>`. Pairs run on `sonnet` at `medium`, with these upshifts:
  - B3.1 runs on `sonnet` at `high`. Its region bound and new steps fail closed, and they decide
    correctness.
  - B3.4 runs on `sonnet` at `high`. Its provenance port is deny-by-default.
  - B3.3 runs on `opus` at `medium`. It writes the stock seat prompts and the standard package,
    which a seat reads as rules.

  A new test helper in package `main` or `e2e` carries its task's subject in its name, since a
  pair's two tasks add tests to those packages in parallel.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-19):
  1. A plan within 720 path minutes launches unattended.
  2. Live spend up to $20 for this pass runs without asking. The meter is `drafter spend --since
     2026-10-19 --json`: its `total` minus the baseline recorded at the first execution commit,
     plus `open.worst`. The executor checks it before each live run, and a run that would start at
     or past $20 doesn't start.
  3. `resume.go`, per the ALLOW ruling above; `money.go` stays a stop.
  4. A live check that misses after the executor's fixes, inside the budget, still opens the PR
     with the miss reported.
  5. A finding that changes the design, or spend past $20, stops and asks Geoff: STATUS carries
     one question, and `notify-send -u normal` tells him.
- Depends on, checked at launch:
  - F2 is merged to drafter `main` (`f286162`, PR #52) and its worktree is gone.
  - One executor per worktree: `pgrep -f .claude/worktrees/b3-drafting` finds nothing.
    `claude agents --json` shows no session working in drafter other than the launching
    conductor's own.
  - Clean main checkout: `~/Projects/drafter` prints nothing for `git status --porcelain`, is on
    `main`, and `git rev-list --count HEAD..origin/main` prints 0.
  - Tools: `vale --version` prints 3.x, `go version` runs, and `DRAFTER_API_KEY` is set in the
    executor's environment (check that it's set; never print it). `drafter config` resolves
    `workspace_id`, `page_cap`, and `cycle_ceiling` from the user layer. At planning: `page_cap = 10`
    and `cycle_ceiling = 160`, both from the user layer, with `mode = batch`.

## Design resolutions

These are the method calls the design leaves to the planner. Each is decided here, and the
executor doesn't reopen one without stopping the line.

### 1. How `drafter page` takes blueprints

`runPage` (`cmd/drafter/page.go:79`) gains a blueprint mode. An argument ending in
`.blueprint.yaml` is a blueprint. One ending in `.md` is a page, mapped to its blueprint with
`blueprint.BlueprintPath`. Anything else is a handoff file, as today.

- Arguments that mix modes, or blueprints with `--workflow-run`, are a usage error.
- Handoff mode is unchanged byte for byte, and its tests pass unedited.

Blueprint mode does the following, in order:

1. Find the root with `plan.GitRoot`, as `runRead` does.
2. Run `Validate(ScopeRun)`, then `ValidateSeat("blueprint")` and `ValidateSeat("coherence")`
   (resolution 6).
3. Run `stockGatePreflight`.
4. Take the start commit with `startCommit` (`read.go:194`).
5. Build handoffs with `blueprintHandoffs` (`read.go:355`).
6. On a resume, keep the pages the run holds with `inRun` (`read.go:212`). Otherwise, scope each
   page from the lock (resolution 3).

When no page is left to run, it prints the summary and exits with no key resolved and no API call.
That follows `runRead`'s `len(handoffs) == 0` branch, which fills `Prompts` from `c.Module()`.
Otherwise it calls `pipeline.Run` with the new options below and `ResumeArgs` set to the arguments
as given. On return it writes the lock (resolution 2).

`blueprintHandoffs` is shared with `drafter read` and gains these fields:

- `Inputs.PageType` is the entry's type.
- `Inputs.FactIDs` is the facts the blueprint places or cites, from the blueprint as committed at
  the start commit. Use the same set `Project.Cited` (`internal/blueprint/cited.go:17`) computes.
- `Inputs.ExemplarSources` is each blueprint exemplar's `source`.

The blueprint read never sends `FactIDs`, since `stageBlueprintRead` calls `buildInput` with no
`Facts`. So `drafter read`'s requests stay byte-identical, and a test asserts it on a fixture read's
dry-run request. `entryJSON` (`read.go:406`) gains three fields:

- `brief`: the brief path. B3.4's `blueprint.BriefPath` replaces the inline expression at
  `read.go:393`, and that task makes the swap.
- `standard`: the matching track's `standard`, or `google` when the outline declares no tracks.
- `reader`: the matching track's reader profile, absent with no track.

### 2. The lock write

The lock entry for a drafted page is written in the command layer after `pipeline.Run` returns. It
works the way `recordAccepted` (`read.go:432`) does today: under the worktree lock, a no-op on a dry
run or a stopped run, and written only when an entry changed. It is never written mid-run, so the
lock stays outside `page.files()` (`page.go:57`) and outside `checkTree`.

A new exported writer in `internal/blueprint` builds the entry through `newLockEntry`
(`install.go:126`), the function conversion and seeding use. The entry holds four fields:

- `page`: `FileBlobID` of the page as written, since it is uncommitted at this point.
- `blueprint`: `CommitBlobID(start commit, blueprint)`.
- `sections`: `SectionHashes` of the blueprint at the start commit over the written page.
- `accepted`: the result's `Accepted` when the page's read accepted it on a read that wasn't
  scoped. Otherwise the value the entry already held. That covers a skipped read and a scoped
  accept, matching `scopedAccept`'s rule (`read.go`, "scopedAccept").

Only accepted pages get an entry. An escalated page's entry is untouched. The lock keeps its
format.

A run that stopped writes nothing, and its resume writes the lock when it finishes. The resume
goes through `drafter page --resume <id>` with the same arguments, and `startCommit` reads the
run's start commit from state.

### 3. Scope from the lock

For each blueprint page, at the start commit, in a new function beside `scopePages`
(`read.go:232`), drafter picks one of these cases:

- **Draft whole, no change read.** There is no lock entry, the entry has no `page` id (only
  `accepted`), or the page file is absent at the start commit. The page drafts whole with a
  `ScopeWhole` scope whose `Why` names the case, and its read, when one runs, reads the whole
  blueprint.
- **Compare.** Otherwise `blueprint.Compare(old, cur)` (`internal/blueprint/since.go:61`) runs.
  `cur` is `revisionAt(start commit)` (`read.go:294`). The old revision is built as follows:
  - `Blueprint` is `git cat-file blob <entry.blueprint>`. A blob the store lacks leaves it empty,
    and `Compare` returns whole ("absent or undecodable at the earlier revision").
  - `Entry` and `Facts` come from `revisionAt(<L>^)`. `L` is the commit that introduced the page's
    current lock entry. Walk `git log --format=%H -- <lock path>` newest first, decode the lock
    at each commit with the lock decoder, and keep the last commit whose entry for the page equals
    the current entry. Stop at the first commit where it differs or is absent. Use `L` itself when
    it has no parent. No commit found reads as no entry: draft whole.

  The parent is the conservative choice. A clean tree is required at a run's start
  (`start.go:88`), and `drafter seed` requires the page and blueprint committed, so `L^` holds
  the outline and facts the draft or seed saw. A fact or outline edit committed together with the
  lock then reads as a change and redrafts, rather than hiding. Probed: in a scratch repo, the walk
  over commits `lock A, fact edit, lock B, other` returned `lock B`, and its parent held the edited
  fact. `git log --find-object` was probed too, and rejected, since a seeded page's commit can
  predate the outline. The architecture's own reason holds: "an entry committed with its page
  can't name that commit" (`docs/blueprint-format.md`, "drafted.lock").

What the comparison decides:

| `Compare` result | Run |
|---|---|
| `ScopeUnchanged` | Not run. It reports `unchangedPage(path, "up to date with drafted.lock")` and spends nothing. |
| `ScopeWhole` | Drafts whole. |
| `ScopeScoped`, empty `IDs` | Drafts whole, with a change read. This covers a removed section, an order change, a page-level field, or an outline-entry change (factsheet "Compare"). |
| `ScopeScoped` with `IDs`, a current section heading missing from the page at the start commit | Drafts whole, with a change read. An added section, or a changed heading, lands here. `coverage.Regions` (`internal/coverage/sections.go:97`) reports `found` false for the heading. |
| `ScopeScoped` with `IDs`, every heading found | Redraft of those sections. |

A scoped page carries the change block, as `scopePages` builds it. `changeBlock` (`read.go:257`)
takes its diff endpoints as arguments: two commits with the file, as today, or the two blob ids.
Probed: `git diff --no-color --no-ext-diff --no-textconv <old blob> <new blob>` prints a unified
diff, with exit 0.

### 4. The pipeline options and the blueprint page's path

`Options` (`internal/pipeline/pipeline.go`) gains two fields:

- `Draft bool`: the run drafts its blueprint pages.
- `SkipRead map[string]bool`: pages whose blueprint read is skipped.

`runPage` sets `SkipRead` when the lock's `accepted` equals the blueprint's blob at the start
commit. Both copy into `work` at `addPages` (`start.go:257`), beside `Since`, `Scope`, and `Change`
(`start.go:277`), so a resume reads them from state and never from options.

The page's two `work` fields are bools, `draft` and `skip_read`, both `omitempty`. A state
saved before B3 decodes both as false, which means what it meant then: a read, not a draft.

On a blueprint page:

- `doBlueprintCheck` (`internal/pipeline/blueprint.go:98`) moves to the draft path in place of
  `stBpRead` when the read is skipped.
- `completeBlueprintRead` (`blueprint.go:220`) records `Accepted` as today. With `Draft` set it
  then moves to the draft path in place of `accept()` (`blueprint.go:278`).
- The draft path is `stDraft` for a whole draft, or the section step of resolution 5 for a
  section redraft.
- `planDoc()` (`page.go:188`) returns `blueprintInputs().view`. Every caller then reads the
  projection: `doCoverage`, `completeCoverage`, and any other caller the executor greps.
- `missingSeats` (`page.go:163`) needs the following for a blueprint page with `Draft` set:
  `blueprint` unless the read is skipped, `draft`, and each review seat and `reader` that
  `p.runs` reports. A section redraft also needs `coherence`. Without `Draft`, the page needs
  only `blueprint`, as today.
- `missingSeatsError` drops its stock-module suffix, "carries only the blueprint read until …",
  since the stock module now defines every seat.

What a blueprint page's requests carry:

- The draft, structure, editor, fact, and coherence requests carry the facts the blueprint places
  or cites as a cached part, and the blueprint with its outline entry as `Extra`. Use
  `assemble.FactsBlock` and `assemble.BlueprintBlock`, as `stageBlueprintRead` does.
- The facts block's opening sentence says the blocks are "everything you read", which is false
  for a seat that also reads the page. So the drafting requests use a variant opening, and the
  blueprint read's request stays byte-identical, which a test asserts.
- The reader's requests carry neither block. It reads as a reader.
- A section redraft's draft request appends to `Extra`, after the blueprint block, the scope
  sentence (`scopeSentence`, `blueprint.go`) and the page's change block (`p.w.Change`).

`p.context` (`steps.go:83`) is unchanged. Resolution 5 says where `scope` is set.

### 5. Section redrafts under the edit contract

A page is a section redraft when `Draft` is set, its scope is `ScopeScoped`, and it has `IDs`.
cmd only sends such a page when every heading is on the page (resolution 3).

- **A new step and exchange kind.** The step is `stSection`, with an exchange of kind `exSection`.
  The exchange opens with one blocking finding per changed section:
  - `Seat`: `blueprint`.
  - `Location`: the heading.
  - The text says the section's blueprint entry changed and the section must carry it as it now
    stands. The rewrite says to rewrite this section only.

  The edit contract needs a resolution claiming every edit (`internal/edits/apply.go`, "no
  resolution claims it"), and these findings give the edits their claims. The first turn renders
  the `draft` seat at round 1 with `findings` set and `scope` set to the comma-joined `IDs`. It
  asks for `AnswerEdits`, so the page and brief are inlined, per `inputBlocks`.
- **The step wiring.** The executor wires every function the factsheet's "Step machinery" names:
  - `stepSeats` gives `draft`.
  - `validate` decodes `edits.Answer`.
  - `complete` calls `completeExchange`.
  - `advance` calls `stageExchange`, with a branch for the first turn.
  - `exchangeStage` gives `s2`, `coveragePhase` gives `covInitial`, and `exchangeStep` gives
    `stSection`.

  A red gate spends the `exSection.contract` budget (`redGate`, `check.go:197`), as other
  non-draft kinds do.
- **The region bound.** `edits.Apply` gains a final parameter, `*edits.Bound`. A nil bound means no
  bound, so every existing caller passes nil. A bound holds the blueprint's section headings in
  order and the headings this answer may change. After the edits apply, `Apply` adds problems
  through the existing refusal path:
  - **Page.** It cuts the pre-edit and post-edit page with the same headings. The preamble, every
    section outside the allowed set, and every heading line must be identical line for line. Each
    allowed heading must still be found. The problem names the allowed sections and the first
    line that differs.
  - **Brief.** Take each pre-edit brief sentence whose `coverage.Normalize` text lies in the
    preamble or in a section outside the allowed set, and in no allowed section. It must still be
    in the post-edit brief, with its text and id unchanged. Sentences in allowed sections may be
    edited, added, or removed.

  `internal/coverage` gains one exported function that returns each region's line range from the
  same `split` (`sections.go:27`). `Regions` is refactored onto it, so there is no second copy of
  the rule.
- **Where the bound applies.** Every edit exchange of a section redraft passes a bound: the
  section exchange, its gate fixes, the round-1 redraft (`exRedraft`), and the final redraft
  (`exFinal`). Only the coherence fix (resolution 6) passes nil. `completeExchange`
  (`handle.go:379`) builds the bound from the blueprint at the start commit and the scope's
  `IDs`.
- **Narrowed reviews.** In a section redraft, the following renders set `scope` to the
  comma-joined `IDs`:
  - every `draft` render;
  - round 1 and round 2 of `structure`, `editor`, and `fact` (`stageRound1`, `stageRound2`);
  - the coherence read.

  `stageScoped` keeps setting `scope` to the cited findings at round `final`, as today. The final
  reader isn't narrowed: it reads as a reader, and `reviewSeats` (`steps.go`) names only the three
  review seats. The `where` field stays unused.

### 6. The coherence read

`coherence` is a new seat. It runs on every section redraft, at the point the page would otherwise
accept, after the review has passed. There are two such points: `completeReader`'s `ok` branch
(`handle.go:360`), and `stageReader`'s `!p.runs("reader")` branch (`steps.go:561`). A whole draft
never runs it.

**It always runs on a section redraft.** Like the `blueprint` seat, it isn't governed by `seats`,
since the design makes the read unconditional. So `defaultSeats` (`internal/config/check.go:17`,
`seatNames[:7]`) is unchanged. It is appended to `seatNames` (`check.go:14`) after index 7, and
`[seat.coherence]` joins `internal/config/stock.toml`: `claude-opus-5-5`, `medium`, 32000, as
the other readers. `runPage` validates it in blueprint mode with `ValidateSeat("coherence")`. A
project can't turn it off; an opt-out goes in "Later". `money.go` keys on no seat name: `seatOf`
reads the custom_id's fourth `_` part (`money.go:29-35`), and `coherence` holds no `_`.

The flow runs in two new steps:

- **The read, `stCoherence`.** Its stage token is `s8`. The `coherence` seat renders at round 1
  with `scope` set to the `IDs`, and its request carries the blocks of resolution 4. It answers
  `AnswerRead` (`parseRead`). An `ok` accepts the page.
- **A first `fix` opens the fix, `stCoherenceFix`.** It is an exchange of kind `exCoherence`, with
  the read's findings, on stage `s8`, and no bound. Its edits may touch any section.
  `coveragePhase(exCoherence)` gives a new phase, `covCoherence`. After the gate and coverage, a
  coverage miss escalates with rule `coherence`. A clean coverage sets the retest flag in `work`
  and returns to `stCoherence`.
- **The retest.** A `fix` on the retest escalates with rule `coherence`, seat `coherence`, and the
  findings numbered.

The executor wires every step function the factsheet names. It also adds `coherence` to
`internal/smoke/shapes.go`'s `seatAnswers`, with `AnswerRead` at `medium`, and to
`smoke_test.go`'s `wantSeats`.

### 7. The context the stock seats read

This is the contract B3.3 writes the prompts against. B3.1 and B3.2 produce it.

- **`page`.** The resolved entry `entryJSON` builds: `path`, `slug`, `title`, `pageType`, `job`,
  `covers`, `outOfScope`, `figure`, `anatomy`, and `register` when a track names one. Resolution 1
  adds `brief`, `standard`, and `reader`. A handoff with no context gets `pageJSON`'s fallback,
  `{path, brief, type, job}` (`steps.go`, "pageJSON").
- **`inputs`.** `job`, `pageType`, `registerSections` (empty for a blueprint page),
  `exemplarSources`, `claimInventory` (empty), and `factIds`.
- **`round`, `findings`, `afterFinalRead`, `narrow`, `turn`, and `facts`** mean what they mean today
  (`internal/prompts/context.go:49-60`). Round 2's `narrow` carries `{baseline, own}`. The stock
  module has no seat `inputs` command, so a stock round-2 read verifies its own round-1 findings
  on the page as it stands. It must still contain each `narrow.own` finding, which
  `containment` checks.
- **`scope`.**
  - `blueprint`: the change read's scope, as today.
  - `draft`, `structure`, `editor`, `fact`, and `coherence` at round 1 or 2: the comma-joined ids
    of the sections a section redraft changed, or `""` for a whole draft. The blueprint block maps
    ids to headings.
  - `editor` and `fact` at round `final`: the cited findings, as today.
- **The blocks after the prompt (resolution 4).** The facts block, then the blueprint and its
  outline entry, and for a section draft the change block. A stock prompt names the page and brief
  by path, so `fileBlocks` inlines them. It never names the blueprint's path.
- **The answers.** `draft` returns `{page, brief, friction}` for a whole draft at round 1 with no
  findings. Every other `draft` turn returns edits. The review seats, the coherence read, and the
  reader's turn 2 return a read. The reader's turn 1 returns `{paraphrase, summary, friction}`.

### 8. The stock prompts and the Google standard package

`stock/prompts.js` defines `blueprint` (unchanged from F2), plus `draft`, `structure`, `editor`,
`fact`, `reader`, and `coherence`.

- **The exemplars.** The prompts take their method from the chain module's seat prompts
  (`claude/.claude/workflows/docs-page-chain.js`) and drop every cairn-only name (resolution 10's
  denylist). They read what resolution 7 defines and nothing else.
- **What each seat reads by token.**
  - The draft reads the page's anatomy (F2's `anatomyFor` rule), `drafter:introductions.md`, and
    the standard package's description, tells, and corpus. It also reads the brief schema and the
    provenance rules of resolution 9, written into its prompt so a draft passes the gate.
  - The editor grades the rubric and the tells.
  - The structure seat reads the anatomy.
  - The fact read checks the brief's ids against the facts and their source excerpts.
  - The coherence read checks transitions, repetition, and the argument's flow across the whole
    page. It treats the changed sections as the ones to read against their neighbors, and it may
    raise findings anywhere.
  - Only a track's `register` token, as F2 wrote it, names a register.

The Google package lands as four embedded files, each a reference page a person reads on GitHub.
`stock.Files` serves each by name for the `drafter:` token:

- `stock/google-description.md`: the standard, its audience, and its source. It names the guide
  (<https://developers.google.com/style>) and its license.
- `stock/google-tells.md`: patterns the standard rules out, each with a before-and-after pair
  written fresh for the file.
- `stock/google-rubric.md`: short paraphrased rules, each citing the guide's URL and section. The
  editor seat grades it.
- `stock/google-corpus.md`: a few short excerpts from CC BY 4.0 pages, each with its title, URL,
  license, and retrieval date.

The guide is never copied. Its license was verified at planning: the page footer at
<https://developers.google.com/style> reads "Except as otherwise noted, the content of this page
is licensed under the Creative Commons Attribution 4.0 License", with code samples under Apache
2.0. A page's own footer is checked for each corpus excerpt before it's used.

### 9. Provenance in `drafter gate --page`

The check lives in a new package, `internal/provenance`. It ports the general rules of
`check-provenance.mjs` (factsheet "Cairn-specific vs general").

**What it reads.** `runGate` (`cmd/drafter/gate.go`) runs it after the blueprint checks when the
page has a blueprint. It reads three things:

- the brief at `blueprint.BriefPath(<blueprint root>, page)`, a new exported function holding the
  rule `read.go:393` inlines today;
- the facts store, through `plan.LoadFacts`;
- the blueprint's `fact` items.

A page with a blueprint and no brief prints `no brief for <page>; provenance check skipped` and
goes on, as the gate already does for a page with no blueprint. `TestSetupFromNothing` gates such a
page and must stay green. The pipeline always writes a brief (`writeFiles`, `page.go`).

**The rules.** Every defect is an error, as in cairn, which has no warnings.

- **Shape.** The brief is a JSON object with a `sentences` array. Other fields are ignored, as
  `coverage.Brief` ignores them. The brief decodes its own `id`, since `coverage.IDs` drops
  `no-claim` (`internal/coverage/brief.go:24-51`).
- **Classification, deny by default.**
  - Each sentence has non-empty `text`.
  - `id` is either the bare string `no-claim`, or a fact id or a non-empty list of fact ids.
  - A fact id is a non-empty string with no whitespace or backtick, the token
    `internal/plan/facts.go`'s `factIDRe` accepts. cairn's `f:` plus six base36 characters is
    cairn-only.
  - `no-claim` inside a list is a defect.
- **Resolution.** Each id resolves to exactly one store bullet (`Facts.Get`), and that bullet is
  `Citable()` (`facts.go`). An uncitable tag's message gives cairn's reason for that tag.
- **Containment.** Each token extracted from a cited sentence must be contained in at least one
  cited bullet.
  - Numerals and versions are matched in the bullet's claim text (`Fact.Text`) only.
  - Other tokens are matched in the claim text and the bullet's `Sources` joined. That is stricter
    than cairn's whole-bullet match, since `Sources` drops commentary. It fails closed.
- **The no-claim rule.** A `no-claim` sentence that states an extractable token is a defect: "marked
  no-claim but states the <kind> "<value>"".
- **Two-way coverage.**
  - Page prose is the page with front matter, fenced code, HTML comments, `details` and `summary`
    tags, images, and heading lines removed.
  - Each brief sentence's `coverage.Normalize` text must occur in the page prose's `Normalize`
    text. Sentences are consumed longest first.
  - A miss is `"<preview>" is not on the page`.
  - A leftover fragment holding a letter or digit is `unclassified page text: "<preview>"`.

  Normalizing both sides matches `coverage.Check`'s run-time rule (`coverage/check.go:105-120`) in
  place of cairn's literal match. A seat's emphasis then never decides a gate verdict that the
  run's own coverage check passed.
- **Fact items.** Each blueprint `fact` item's fact is cited by at least one brief sentence. Its
  placement by section stays `coverage.Check`'s job.

**Extraction.** Port `extractFacts`, `codeSpanFacts`, and `bulletContainsFact` for these kinds:
dates, versions, numerals, paths and URLs, commands, flags, and names. Key phrases are cairn's
owner tier, so they're dropped. Go's `regexp` has no lookaround. Probed:
`regexp.Compile("(?<![\\w.-])\\d{4}…")` fails with "invalid named capture", and `\d+(?!\d)` fails
with "invalid or unsupported Perl syntax". So each lookbehind and lookahead becomes an explicit
boundary check on the bytes around a match.

**Command heads.** A small generic set, `git`, `go`, `make`, `npm`, `npx`, `pnpm`, `yarn`, `node`,
`curl`, `docker`, `python`, `pip`, and `cargo`, plus a derived set: the first word of every code
span of two or more words in any store bullet's claim. That way a project's own CLI, like the
fixture's, is read as a command once a fact states it. Drop cairn's `COMMAND_HEADS` contents,
`PATH_EXTENSIONS`' cairn list (keep a generic one), the rebuilt list, the `local` exemption and its
engine-export rule, and the basename convention.

**Output.** `file:line: error: provenance: message (fix)`, in the gate's existing format. Every
line names the page or the brief, so the pipeline's `ForPage` (`internal/gate/run.go:236`) reads
the red as the page's own and opens a fix exchange, never a hold.

- A brief defect cites the brief, at the first line holding that sentence's JSON-encoded text, or
  line 1.
- A page defect cites the page, at the first line whose `Normalize` text holds the fragment's
  first five words, or line 1.

The gate's exit codes are unchanged.

### 10. `drafter check-prompts` on the stock module

The fixture (resolution 11) commits `prompts-matrix.json`. It holds one case per stock seat and
per shape each seat renders:

- `blueprint`: whole and change.
- `draft`: whole round 1, section round 1 with findings and scope, round-2 redraft, and the final
  redraft.
- Each review seat: round 1 whole, round 1 scoped, round 2 narrow, and round `final` scoped for
  `editor` and `fact`.
- `reader`: turns 1 and 2, and the retest.
- `coherence`: the read and the retest.

`drafter check-prompts --matrix prompts-matrix.json`, run in a git copy of the fixture with no
`prompts` set, renders the stock module. `runCheckPrompts` (`checkprompts.go:78`) already takes
`c.Module()`. When the module is the stock module, two checks join `containment`
(`checkprompts.go:219`):

- **`path`.** Each token, split as `assemble`'s `tokens` splits, that is path-shaped must resolve.
  A token is path-shaped when it holds a `/` and no `://`, or begins `drafter:`.
  - A repo path must name a file or directory the project's git tree tracks, with any `#slug` cut.
  - A `drafter:` name must be in `stock.Files`.
  - A token that doesn't resolve fails, naming it.
- **`names`.** The rendering holds none of these case-insensitive strings, taken from the chain
  module's cairn-specific strings: `cairn`, `docs/internal`, `docs-register`, `sveltekit`,
  `cloudflare`, `wrangler`, `glw907`, `npm run check:`, and `option-map`.

A project module, set by `prompts` or `--module`, gets neither check. Its paths are its own.

### 11. The synthetic fixture

The fixture is `e2e/testdata/cli/`, synthetic, with no workstation path, account, key, or cairn
text. It's a small CLI project, `tally`: a Go `main.go` with two or three subcommands and a flag,
and a `README.md`. It also holds:

- `drafter.toml` with no `prompts` and the stock gate;
- `.vale.ini` naming the Google style, with a one-rule synthetic style under `.vale/styles/Google/`,
  as `setupStyle` does (`e2e/setup_test.go`), so Vale resolves offline;
- `blueprints/outline.yaml`, with one track (`standard: google`, `paths: [docs/**]`) and one
  managed task page, `docs/count-items.md`, of type `task guide`;
- `blueprints/facts/tally.md`, whose bullets cite `main.go` lines and state the commands;
- `blueprints/docs/count-items.blueprint.yaml`, with three sections, a `framing.introPlan`, and
  `fact` and `sentence` items citing those facts;
- `prompts-matrix.json` (resolution 10).

It has no page, no brief, and no lock: row 1 drafts from nothing. Tests copy it into a temp
directory and `git init` it, as `newSetupEnv` does.

### 12. The live check

`e2e/live_test.go` carries `//go:build live`, and `make live` runs `go test -tags live -count=1
-timeout 3h -run Live ./e2e/`. It's kept out of `make check`, as `make smoke` is. The `vet` target
gains `go vet -tags live ./...`, so the file compiles under the gate.

The check runs with the user's real `HOME`, for the user layer's `workspace_id`, caps, and
`key_env`, and for the real ledger the meter reads. `DRAFTER_API_KEY` must be set: the test skips
without it, with the reason, and never prints it. The worktree's built `drafter` goes first on
`PATH`, since the stock gate shells out to it (`stockGatePreflight`). The project is a fresh temp
git copy of the fixture, and the runs use batch mode, the default, at half price.

Before each `drafter page` call, the test reads `drafter spend --since 2026-10-19 --json`. It
fails with the reading when the total, minus the baseline passed in `DRAFTER_LIVE_BASELINE`, plus
`open.worst`, is at or past $20.

| Row | Action | Assertions |
|---|---|---|
| 1 | `drafter page docs/count-items.md --json` | Exit 0; the page is accepted, with scope whole. The lock entry's `page` equals `git hash-object` of the page, `blueprint` equals the blueprint's blob at HEAD, `sections` equals `SectionHashes` over the page, and `accepted` is set. Then commit the page, the brief, and the lock. |
| 2 | Change one item's text in one section's blueprint, commit, and run `drafter page` again | Exit 0; the page is accepted, scoped to that one section id. Cut with the blueprint's headings, the page outside that section (preamble, other sections, heading lines) equals row 1's committed page. The run's `record.json` holds a coherence verdict on stage `s8`. The lock entry is updated: new `page`, new `blueprint`, and `accepted` kept. Commit. |
| 3 | `drafter page docs/count-items.md` again | Exit 0; it prints `up to date with drafted.lock`, creates no run directory, and leaves the meter's total unchanged. |

## Tasks

### B3.0: fixture, coherence seat, options, and stock stubs (50 min), by the session

Outcome: what both pairs build on, with no behavior change beyond the new seat's configuration.

1. The fixture of resolution 11, except `prompts-matrix.json`, which B3.5 writes.
2. The `coherence` seat's configuration (resolution 6): `seatNames`, `stock.toml`, the smoke lists,
   and `docs/configuration.md`'s "Seats and prompts" row, which says the seat runs on every section
   redraft and isn't governed by `seats`.
3. `Options.Draft` and `Options.SkipRead`, the matching `work` fields, and their copy in
   `addPages`. Nothing reads them yet.
4. `stock/prompts.js` gains stub builders for `draft`, `structure`, `editor`, `fact`, `reader`, and
   `coherence`. Each returns one line naming `c.page.path`, so pair A's pipeline tests can load the
   stock module. The four empty `stock/google-*.md` files are embedded and served by `stock.Files`.
5. The tests that pin the old stock refusal change. They now assert the missing-seat refusal
   with a test module that lacks a seat: `cmd/drafter/stockmodule_test.go`,
   `internal/pipeline/stockmodule_test.go`, and `e2e/stockmodule_test.go`.

- Files: `e2e/testdata/cli/**`, `internal/config/{check.go,stock.toml}` and their tests,
  `internal/smoke/{shapes.go,smoke_test.go}`, `internal/pipeline/{pipeline.go,work.go,start.go}`,
  `stock/{prompts.js,stock.go,google-*.md}`, the three stockmodule tests, and
  `docs/configuration.md`.
- Risk class `runner`.
- Acceptance: `make check` green. `drafter check` on a git copy of the fixture reports 0 errors.
  The session commits before pair A starts.

### B3.1: the pipeline's drafting path (170 min), paired with B3.3, `sonnet` at `high`

Outcome: resolutions 4, 5, and 6, and the pipeline half of 7.

- Files:
  - `internal/pipeline/{work.go,page.go,blueprint.go,handle.go,steps.go,check.go,start.go,record.go}`
    as needed, and new pipeline test files.
  - `internal/edits/{apply.go,types.go}` and `apply_test.go`.
  - `internal/coverage/sections.go` and its test.
  - `internal/assemble/blueprint.go` (the facts block's drafting variant).
  - `docs/prompts-module.md` ("The context object": the `scope` values and the blocks).
- Never `money.go`. `resume.go` only per the ALLOW ruling: test-first, then a task-scope
  `diff-reviewer` read with the auth-data bar before B3.1 is reported done.
- Risk class `runner`.
- Tests, table-driven, on the scripted `fakeAPI` (`internal/pipeline/fake_test.go`) and the
  blueprint harness (`newBlueprintHarness`):
  - A `Draft` blueprint page reads, then drafts whole, gates, covers, reviews, and accepts.
    `Accepted` is in its result. Without `Draft`, the same page accepts at the read, as today.
  - `SkipRead` goes straight from the check to `stDraft`, with no stage-1 request.
  - `planDoc()` returns the view for a blueprint page.
  - The draft, review, and coherence requests carry the two blocks, and the reader's carry none.
    The blueprint read's request is byte-identical to today's.
  - A section redraft opens with one finding per changed section. Its draft render has `scope`
    and `findings` set, and its review renders have `scope` set. `stageScoped` still sets the
    cited findings.
  - `edits.Apply` with a bound:
    - accepts an edit inside an allowed section;
    - refuses an edit in another section, in the preamble, or on a heading line, naming the line;
    - refuses an answer that deletes an allowed heading;
    - refuses a brief edit to an out-of-scope sentence;
    - allows a brief edit, addition, or removal for an in-scope sentence.

    With a nil bound, every existing row passes unchanged.
  - The refusal reaches the model through `refused`, and the contract budget escalates as today.
  - Coherence:
    - `ok` accepts;
    - a first `fix` runs an unbounded exchange that may edit any section, then the gate and
      coverage, then the retest;
    - a retest `fix` escalates with rule `coherence`;
    - a coverage miss after the fix escalates with rule `coherence`;
    - a whole draft never runs coherence.
  - `missingSeats` lists `coherence` only for a section redraft.
  - A resume across each new step: a run stopped with an open intent at `stSection`, at
    `stCoherence`, and at `stCoherenceFix`, and one stopped after a section write with
    `PendingGate` set. Each resumes, finishes, and spends no request twice. These follow
    `resume_test.go`'s pattern. If a resume fails because `checkTree` or `wantHashes` can't account
    for a new step, that's the ALLOW case: the failing test first, then the fix.
  - A state saved before B3, with no `Draft` field, resumes as a read.
- Acceptance: `make check` green in the pair worktree. The commit message lists every step
  function wired for each new step.

### B3.3: the stock seat prompts and the Google standard package (130 min), paired with B3.1, `opus` at `medium`

Outcome: resolutions 7 and 8, the prompt half.

- Files: `stock/prompts.js`, `stock/google-{description,tells,rubric,corpus}.md`,
  `stock/stock_test.go`, `stock/testdata/` (the matrix and its expected renderings), and
  `docs/prompts-module.md` ("The stock module": the seats and the package files). Coordinate on
  `docs/prompts-module.md` by section: B3.1 owns "The context object", B3.3 owns "The stock module".
  The merge keeps both.
- Risk class `runner`.
- Load `writing-voice` first for the four reference pages, which follow Google developer
  documentation style. The prompts are written to resolution 7's context and nothing beyond it.
- Tests in `stock`:
  - The module loads under `prompts.Load` and defines exactly the seven seats.
  - A golden rendering for every case of `stock/testdata/matrix.json`, which mirrors resolution
    10's case list. F2's three blueprint goldens are unchanged.
  - No rendering holds a denylisted string (resolution 10).
  - No rendering without a `register` holds "register".
  - Every `drafter:` token in a rendering is a `stock.Files` name.
  - The draft rendering for a whole draft states the brief schema and the provenance rules of
    resolution 9.
  - The section draft says to change only the sections in `scope`.
  - The coherence rendering names the changed sections and says findings may lie anywhere.
  - Each rubric rule in `google-rubric.md` carries a `developers.google.com/style` URL.
  - Each corpus entry carries a URL, a license, and a retrieval date.
- Acceptance: `make check` green. The PR body lists each corpus excerpt's URL and license, and
  states that each was checked against that page's footer.

### B3.2: `drafter page` from blueprints, the lock scope, and the lock write (90 min), by the session in pair A's shadow

Outcome: resolutions 1, 2, and 3.

- Files:
  - `cmd/drafter/page.go`.
  - `cmd/drafter/read.go`: `blueprintHandoffs`, `entryJSON`, `changeBlock`'s endpoints, and a
    shared lock helper with `recordAccepted`.
  - A new `cmd/drafter/draftscope.go` if the scope function outgrows `page.go`.
  - `internal/blueprint/install.go` (the exported entry writer) and the lock walk's helper, if it
    lives in `internal/blueprint`.
  - `docs/blueprint-format.md`: "drafted.lock" says `drafter page` writes an entry on accept, and
    "What `drafter read` does with a blueprint" gains a sibling section, "What `drafter page` does
    with a blueprint".
  - `docs/handoff.md`: one paragraph saying `drafter page` also takes blueprints, with handoffs
    unchanged.
  - Tests beside each.
- Risk class `runner`.
- Tests:
  - Argument modes: a blueprint path, a page path, and a handoff file each route as resolution 1
    says. A mix, and blueprints with `--workflow-run`, are usage errors. Existing handoff tests
    pass unedited.
  - Scope, one row per case of resolution 3's table, plus the four whole-draft cases (no entry,
    entry with only `accepted`, page absent, no commit holds the entry). The walk finds the
    introducing commit across an unrelated lock change to another page's entry. It reads the
    old facts from that commit's parent.
  - An all-unchanged run prints `up to date with drafted.lock`, exits 0, and resolves no key: the
    test runs with no key source configured.
  - The lock write, unit-tested on a synthetic `pipeline.Summary` in a temp repo:
    - an accepted page's entry has the four fields of resolution 2;
    - a scoped accept keeps `accepted`;
    - a skipped read keeps `accepted`;
    - an escalated page's entry is untouched;
    - a dry run and a stopped run write nothing;
    - a write that changes nothing leaves the bytes alone.
  - `entryJSON` carries `brief`, `standard`, and `reader`, and the standard is `google` with no
    tracks.
  - `drafter read`'s dry-run request on the fixture blueprint is byte-identical before and after
    the `Inputs` additions.
- Acceptance: `go test ./cmd/drafter/... ./internal/blueprint/...` green, then `make check` after
  pair A merges.

### B3.4: provenance in the stock gate (110 min), paired with B3.5 after pair A merges, `sonnet` at `high`

Outcome: resolution 9.

- Files: `internal/provenance/{provenance.go,extract.go}` and tests,
  `internal/provenance/testdata/`, `cmd/drafter/gate.go` and `gate_test.go`, the new
  `internal/blueprint/brief.go` (`BriefPath`), and `cmd/drafter/read.go`'s line 393 swap to
  `BriefPath`. `docs/blueprint-format.md` gains a section, "The brief", covering the brief's shape
  and what the gate checks. `drafter gate --help`'s `Long` gains step 4, provenance, and renumbers.
- Risk class `runner`.
- Tests, table-driven, with one row per rule and message:
  - each shape defect;
  - each classification defect: empty text, a non-string id, `no-claim` in a list, an empty list,
    and an id with a space;
  - an unresolved id, and each uncitable tag;
  - each extracted kind contained and not contained, including a numeral matched only in the
    claim text;
  - a command head derived from the store;
  - the no-claim rule;
  - a sentence not on the page, and unclassified page text;
  - an uncited fact item;
  - a page with a blueprint and no brief, skipped with the message.

  Each extraction regex the port rewrites without lookaround gets the boundary rows its JS source
  implies: a date inside a longer token, a version followed by `.digit`, and a numeral with a
  thousands comma. The gate's output lines name the page or brief, and `gate.Result.ForPage` reads
  each as the page's own. `TestSetupFromNothing` stays green.
- Acceptance: `make check` green. The commit message lists each cairn rule dropped, and why it's
  cairn-only.

### B3.5: `check-prompts` on the stock module (50 min), paired with B3.4

Outcome: resolution 10.

- Files: `cmd/drafter/checkprompts.go` and its test, `e2e/checkprompts_test.go` (a new
  `stockCheckPrompts…` test), `e2e/testdata/cli/prompts-matrix.json`, and
  `docs/prompts-module.md` ("Check a module").
- Risk class `runner`.
- Tests:
  - On a git copy of the fixture, `drafter check-prompts --matrix prompts-matrix.json` exits 0.
  - A rendering that names a path the fixture lacks fails `path`, naming it.
  - A rendering holding `cairn` fails `names`. Both use a test copy of the stock module edited
    in the temp repo, passed as the configured `prompts`, so the stock-only checks are proven by
    a module F2's `Module()` reports as stock. If that needs a seam, the seam is an unexported
    variable in `package main` holding the module bytes, never a flag.
  - A project module with the same rendering passes both checks.
  - The matrix holds a case for every seat `stock` defines, checked by the test.
- Acceptance: `make check` green.

### B3.6: the live harness (40 min), by the session in pair B's shadow

Outcome: resolution 12's file and target, not yet run against the API.

- Files: `e2e/live_test.go` (`//go:build live`) and the `Makefile` (`live` target, the `vet` line,
  and `.PHONY`).
- Risk class `runner`.
- Acceptance: `make check` green, with the vet line compiling the file. `go test -tags live -run
  Live ./e2e/` with `DRAFTER_API_KEY` unset skips with its reason and spends nothing. The meter
  helper's arithmetic has a table-driven unit test, with no API call.

### B3.7: acceptance, offline then live (120 min), by the session after pair B merges

Outcome: the design's "Check", run end to end.

1. **Offline.**
   - A new pipeline test drafts the fixture page end to end on the stock module, with the scripted
     `fakeAPI` answering each seat. This proves every real stock prompt renders inside a run.
   - The same test, scripted, runs a section redraft with a coherence `fix` and its retest.
   - `drafter check-prompts` passes on the fixture (B3.5's e2e test).
   - `make check` green.
2. **Baseline.** Record the meter's total at the pass's first execution commit (taken at B3.0's
   start), and pass it as `DRAFTER_LIVE_BASELINE`.
3. **Live.** Run `make live` from the worktree with the built binary. Before each `drafter page`,
   check the meter (standing answer 2).
   - If a row misses, the executor reads the run's `record.json` and fixes the cause in code or a
     stock prompt, with a test where the fault is mechanical. It reruns from a fresh fixture copy,
     inside the budget.
   - A miss that remains when the budget would be exceeded ends the live work. The PR opens with
     the miss, the record excerpt, and the spend (standing answer 4).
- Files: the new pipeline test, plus whatever a live miss's fix touches, each named in the PR body.
- Risk class `runner`, with `live-account` (API spend).
- Acceptance:
  - Offline: green.
  - Live: rows 1 to 3 pass, or a miss is reported with standing answer 4.
  - The PR body carries each row's result, the run ids, the cost per row from the summaries, and
    the meter readings before and after.

## Close (40 min)

1. The drafter gate on the close head, from the worktree: `DRAFTER_DIR="$PWD" bash
   scripts/drafter-gate.sh`, through `cairn-run-gate`, re-issued on exit 75. drafter has no CI, so
   this is the full-suite home, and it runs once on the close head.
2. One whole-branch `diff-reviewer` read against this plan and the design. If any commit touched
   `resume.go`, the read confirms it had its task-scope read. `prose-voice-reviewer` reads the four
   `stock/google-*.md` pages and the changed `docs/` pages: `prompts-module.md`, `handoff.md`,
   `blueprint-format.md`, and `configuration.md`. One batched fix chain follows, then the gate
   again; a second review runs only on a blocker. A fix dispatch quotes each finding verbatim as
   its acceptance.
3. The PR body opens with `## Brief`, per `~/.claude/docs/voice/approval-brief.md`. Below it go:
   - what landed;
   - the acceptance table, one row per design "Check" row and each offline check, with its result;
   - the live spend and readings;
   - the corpus licenses;
   - every departure from this plan, with its reason;
   - any `resume.go` verdicts;
   - the score, per pass-core "Score", with the Work and review row naming 500 path minutes beside
     the actual.
4. Each "Found, not done" item worth doing goes to drafter's `BACKLOG.md` through `log-issue`,
   tagged `#initiative:docs-system`, and is listed in the PR body with its number. The four
   "Findings for the planning session" items go in as well, unless the planning session filed them.
5. Stop at PR-ready. The conductor hands the packet to Geoff.

## Merge order

1. glw907/drafter's B3 PR, with `--match-head-commit` from the decision. Then pull
   `~/Projects/drafter` and run `make install` from it, as after F2, so the installed `drafter` has
   the stock seats and the provenance gate.
2. No cairn-cms PR: cairn's half is B3c. The hand-over's Status line names B3c's design, after
   Geoff's ruling on drafter backlog #1, #8, and #13, as next.

## Later

Kept out of B3 and never built here:

- B3c: converting cairn's stage 2b plans, the whole-read bar (drafter backlog #13, drafter#43),
  and the cairn pilot drafts.
- The lock's commit field, the write-back seat, clearing `origin: human`, commits, and pull
  requests (B4). The commit field also closes the case in finding 2.
- Human-edit detection before a redraft (B4).
- A fresh consistency read when the read is skipped and a cited fact bullet changed since it
  (finding 3).
- A setting to turn off the coherence read.
- Stock seat `inputs` that give a round-2 read the redraft's diff from the baseline.
- Sending the draft seat only the changed sections' blueprint entries, in place of the whole
  blueprint with the changed ids named.
- The Microsoft standard package.
- The plugin and onboarding (O).
