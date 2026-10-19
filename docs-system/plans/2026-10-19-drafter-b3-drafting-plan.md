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
`…-factsheet-provenance.md`. The plan was reviewed through three lenses
(`docs-system/research/2026-10-19-drafter-b3-plan-review-{mechanics,contract,integrity}.md`) and
revised by the fold recorded in `docs-system/research/2026-10-19-drafter-b3-plan-fold.md`; fold
probes ran in the session scratchpad's `fold-probes/`.

## Findings for the planning session

None of these changes the approved design. The planning session ruled each one that needed a
ruling (fold record, "Settled by the planning session"); the rest are decided below.

1. **The $20 is this pass's own spend.** At planning, `drafter spend --since 2026-10-19 --json`
   printed `total 9.4436516`, `open {count: 0, worst: 0}`, from edit-quality's earlier runs, which
   the design's meter date happened to include. Geoff's approved packet said "budget $20 of your
   $200 monthly credit", so the planning session ruled the $20 is this pass's own spend, measured
   from a baseline the executor records at launch, and a hard ceiling: each live `drafter page`
   call sets `DRAFTER_PAGE_CAP` to the budget left (resolution 12). The ledger is per machine, so
   spend by another session on this machine during the pass counts against the $20.
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
4. **Human edits stay B4's.** B3 redrafts the page as committed at the start commit. The region
   bound keeps a hand edit outside the changed sections through the section and review exchanges,
   but the coherence fix is unbounded and may rewrite one anywhere, and a gate fix may too. Git
   still holds the committed page. The lock then records the new page. The plan adds no detection.
5. **A commit between a run's start and its lock commit can hide a fact edit.** The walk in
   resolution 3 reads `L^` as what the draft saw. A commit made between a stop and its resume, or
   a fact edit committed on its own before the page, brief, and lock, breaks that. The planning
   session ruled a warning now: at lock-write time, when HEAD isn't the start commit and `git diff
   --name-only <start> HEAD -- <facts dir> <outline>` prints anything, drafter warns and names the
   files, and `docs/blueprint-format.md` states the rule (commit the page, brief, and lock with
   nothing between them and the run's start). The lock's start-commit field lands in B4.
6. **A stopped pre-B3 run can't resume after the upgrade.** `fingerprint` hashes every configured
   seat (`internal/pipeline/fingerprint.go:37-43`), and `changedSettings` counts a key the old
   fingerprint lacks as changed (`fingerprint.go:47-61`), so the new `seat.coherence.*` keys make
   `checkConfig` refuse (`resume.go:213-214`). `fingerprint.go` is never edited in this pass. The
   planning session ruled it a known limit: before `make install` (Merge order), the executor checks
   that no drafter run is stopped and resumable, and B3.1 asserts the documented refusal.

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
  (factsheet "Step machinery"). `internal/pipeline/fingerprint.go` is never edited (finding 6).
- Path estimate: 665 minutes, against the design's 360 (1.85x), inside the 720-minute standing
  answer. The path is the longest chain of tasks run in sequence, a pair counting once at its
  larger estimate (pass-core, "Plan"). The chain:
  - B3.0: 60.
  - Pair A: 215. B3.1 (215) runs beside B3.3 (130), and the session runs B3.2 (170) in the
    pair's shadow, so the segment is max(215, 130, 170) = 215.
  - Merge and named-test check: 10.
  - Pair B: 125. B3.4 (125) runs beside B3.5 (50): max(125, 50) = 125. The session has no
    shadow task; B3.6 is folded into B3.7.
  - Merge and named-test check: 10.
  - B3.7: 205 (the live harness 50, the offline end-to-end test 50, the live rows 105).
  - Close: 40.

  The sum is 60 + 215 + 10 + 125 + 10 + 205 + 40 = 665. The fold added 165 minutes to the first
  draft's 500: B3.1's section decision, gate-fix and decline rules, and per-exchange bound rows
  (+45); B3.2's brief widening, walk fixes, warning, and resume tests, inside pair A's shadow (+0
  on the path); the request goldens (+10); the named-test checks (+10); B3.4's states and clean
  count (+15); and B3.7's offline end-to-end test and folded harness (+85). F2 planned 310 and
  closed early. B3.7 carries batch waits for the live rows.
- Clock file: `pass-task-clock` in the session worktree's git dir (`git rev-parse
  --absolute-git-dir` run in `.claude/worktrees/b3-drafting`). During a pair it holds the task the
  session runs in the shadow. When a pair returns, the session checks each pair task against twice
  its estimate, then runs `go test -run '<the task's named tests>' -v` on the task's packages and
  confirms each named test shows `PASS` and none shows `SKIP`. Each task's acceptance names its
  tests; a row marked "regression" is expected to pass on `f286162`, and every other row is
  expected to fail there.
- Executor session name `drafter-b3-drafting`. Worktree name `b3-drafting`. Each pair subagent's
  `description` is `b3-drafting task <n>`. Pairs run on `sonnet` at `medium`, with these upshifts:
  - B3.1 runs on `opus` at `high`. It is the critical path, its region bound and new steps fail
    closed and decide correctness, and it may touch `resume.go`.
  - B3.4 runs on `sonnet` at `high`. Its provenance port is deny-by-default.
  - B3.3 runs on `opus` at `medium`. It writes the stock seat prompts and the standard package,
    which a seat reads as rules.

  A new test helper in package `main` or `e2e` carries its task's subject in its name, since a
  pair's two tasks add tests to those packages in parallel.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-19):
  1. A plan within 720 path minutes launches unattended.
  2. Live spend up to $20 for this pass runs without asking, as a hard ceiling (finding 1). The
     meter is `drafter spend --since 2026-10-19 --json`: its `total` minus the baseline the
     executor records at launch, plus `open.worst`. The baseline JSON goes into STATUS and the
     B3.0 commit message body, and B3.7 reads it from there. Before each live `drafter page`, the
     live test computes the budget left, refuses to start at or below $0, and sets
     `DRAFTER_PAGE_CAP` to it, so a run that would cross the line escalates with rule `cap`
     instead of overspending. Caps resolve to the lowest layer (`putCap`,
     `internal/config/apply.go:90-98`), and the environment layer reads `DRAFTER_PAGE_CAP`
     (`internal/config/env.go:12-14`, `:78-90`). The ledger is per machine.
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
3. Take the start commit with `startCommit` (`read.go:194`).
4. Build handoffs with `blueprintHandoffs` (`read.go:355`).
5. On a resume, keep the pages the run holds with `inRun` (`read.go:212`). Otherwise, scope each
   page from the lock (resolution 3).
6. Run `stockGatePreflight`, only when a page is left to run, so an all-unchanged run needs
   neither Vale nor `drafter` on `PATH`.

When no page is left to run, it prints the summary and exits with no key resolved and no API call.
That follows `runRead`'s `len(handoffs) == 0` branch, which fills `Prompts` from `c.Module()`.
Otherwise it calls `pipeline.Run` with the new options below and `ResumeArgs` set to the arguments
as given. On return it writes the lock (resolution 2).

On the stock module, a page whose outline declares tracks but none matching the page, or whose
track names a `standard` other than `google`, is refused before any request, naming the page and
the standard; the stock module carries only the Google package. A project module is not checked.

`blueprintHandoffs` is shared with `drafter read` and gains these fields:

- `Inputs.PageType` is the entry's type.
- `Inputs.FactIDs` is the facts the blueprint places or cites, from the blueprint and outline as
  committed at the start commit. `Project.Cited` (`internal/blueprint/cited.go:17`) reads the
  working tree (`os.ReadFile`, `cited.go:18-25`), so its body moves onto a bytes-in function that
  takes the blueprint and outline bytes, `Cited` calls it, and `blueprintHandoffs` passes the
  start commit's bytes. One rule, two callers.
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
run's start commit from state. A resumed run's `summary()` covers every page, so pages accepted
before the stop get their entries too.

A lock write that fails after `pipeline.Run` returned (the worktree lock is busy, since `TryLock`
is non-blocking, `internal/run/lock.go:21-36`, or the write errors) prints the run summary first,
then the error with the command that recovers it, `drafter page --resume <id> …`, built by
`pipeline.ResumeCommand` (`pipeline.go:256`). Resuming a finished run finds nothing to run and
returns the full summary, so the lock gets written with no request submitted. B3.2 proves that
path with a test; if the resume refuses a finished run, the failing test comes first and the fix
follows the ALLOW ruling.

At lock-write time, when HEAD isn't the start commit, drafter runs `git diff --name-only <start>
HEAD -- <facts dir> <outline>` and, when it prints anything, warns on stderr that those files
changed after the run started and the next run may not see the change (finding 5). Probed: the
command lists only the changed paths under the pathspec and exits 0.

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
    the current entry in `page`, `blueprint`, and `sections`, the fields a draft or seed writes.
    `accepted` is ignored: `recordAccepted` rewrites only it (`cmd/drafter/read.go:448-462`), so a
    read-accepted lock commit after a fact edit must not move `L` past that edit. Stop at the first
    commit where those fields differ, the entry is absent, or the lock doesn't decode (an older
    format; `ReadLock` decodes with `KnownFields`). Use `L` itself when it has no parent. No commit
    found reads as no entry: draft whole.

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
| `ScopeScoped` with `IDs`, no brief at the start commit (a seeded or converted page) | Drafts whole: cmd sets `ScopeWhole` with a `Why` naming the missing brief, since a section redraft can't pass two-way coverage on sections the brief doesn't cover. |
| `ScopeScoped` with `IDs`, a changed bullet cited by a preamble sentence of the brief | Drafts whole: cmd sets `ScopeWhole` with a `Why` naming the fact. The bound never lets a section redraft change the preamble. |
| `ScopeScoped` with `IDs`, otherwise | Sent scoped, with `IDs` widened (below). The pipeline decides between a section redraft and a whole draft (resolution 5). |

**Widening `IDs` by the brief.** `Compare` scopes a changed bullet to the sections whose blueprint
items cite the fact (`internal/blueprint/since.go`, `sectionCites`), but the brief may cite it from
another section, and a bounded exchange couldn't then repair that sentence. So cmd reads the page
and brief at the start commit, cuts the page with the blueprint's headings through
`coverage.Regions` (`internal/coverage/sections.go:97`), and adds to `IDs`, in blueprint order,
every section holding a brief sentence (located by its `coverage.Normalize` text) whose id cites a
fact in `Scope.Bullets`. A sentence found in no region is ignored here; two-way coverage reports
it.

A scoped page carries the change block, as `scopePages` builds it. `changeBlock` (`read.go:257`)
takes its diff endpoints as arguments: two commits with the file, as today, or the two blob ids.
Probed: `git diff --no-color --no-ext-diff --no-textconv <old blob> <new blob>` prints a unified
diff, with exit 0. A blob-to-blob diff labels its hunks with blob ids, so the block opens with a
line naming the blueprint's path.

### 4. The pipeline options and the blueprint page's path

`Options` (`internal/pipeline/pipeline.go`) gains two fields:

- `Draft bool`: the run drafts its blueprint pages.
- `SkipRead map[string]bool`: pages whose blueprint read is skipped.

`runPage` sets `SkipRead` when the lock's `accepted` equals the blueprint's blob at the start
commit. Both copy into `work` at `addPages` (`start.go:257`), beside `Since`, `Scope`, and `Change`
(`start.go:277`), so a resume reads them from state and never from options. `SkipRead` trusts the
lock's `accepted`, and these are every channel that sets it: `recordAccepted` after an unscoped
accepted read, the new page writer (resolution 2), `seedEntry`, which keeps the old value
(`internal/blueprint/seed.go:107`), and a hand edit of the lock. `addPages` is the only place
`work.draft` and `work.skip_read` are set.

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

**The pipeline decides, in one place.** When a blueprint page with `Draft` set reaches the draft
path (after the read, or from the check when the read is skipped), the pipeline makes it a section
redraft when its scope is `ScopeScoped`, it has `IDs`, and `coverage.Regions` over the page as it
stands, with the headings of the start commit's blueprint, finds every heading `IDs` names. The
run hasn't written the page yet, and the tree was clean at the start (`start.go:88`), so that page
is the start commit's. Otherwise it drafts whole, and a scoped page's read has already been a
change read. An added section or a renamed heading lands in the whole case. The decision is saved
as a `work` bool, `section` (`omitempty`), the moment it's made, since the page changes after the
first write and a resume must not decide again.

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
  - `validate` decodes `edits.Answer` (its default, `parseRead`, would reject an edits answer;
    `handle.go:192-234` lists only `stGateFix`, `stRedraft`, and `stFinalRedraft`).
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
  - **Page.** It cuts the pre-edit and post-edit page with the same headings. Every heading found
    before the edit must still be found after it, in the same order, so an edit that opens an
    unbalanced fence or adds a heading duplicating a later one's text is refused (`split` toggles
    on fence lines and matches the first heading with the same normalized text at or after the
    previous match, `sections.go:27-61`). The preamble, every section outside the allowed set, and
    every heading line must be identical line for line. The problem names the allowed sections
    and the first line that differs.
  - **Brief.** Brief sentences are matched as a multiset of (normalized text, id). Take each
    pre-edit sentence whose `coverage.Normalize` text lies in the preamble or in a section outside
    the allowed set, and in no allowed section. It must still be in the post-edit brief, with its
    text and id unchanged. An added sentence whose text lies only outside the allowed sections is
    refused. Sentences in allowed sections may be edited, added, or removed.

  `internal/coverage` gains one exported function that returns each region's line range from the
  same `split` (`sections.go:27`). `Regions` is refactored onto it, so there is no second copy of
  the rule.
- **Where the bound applies.** In a section redraft, the model-review exchanges are bounded: the
  section exchange's turns (`exSection`), the round-1 redraft (`exRedraft`), and the final redraft
  (`exFinal`). Gate-fix turns are unbounded in every exchange, since a red can name a line
  anywhere (a Vale rule added since the last accept, or provenance's unclassified page text), and
  the coherence fix (resolution 6) is unbounded. `redGate` (`check.go:197-221`) keeps the exchange
  and sets `p.ps.Step = exchangeStep(kind)`, so the step can't tell a gate-fix turn from a
  redraft turn; the `exchange` struct gains a bool, `gate_fix` (`omitempty`), which `redGate` sets
  and which stays set for the rest of that exchange, since every later turn of it answers gate
  findings or a refusal of them. `completeExchange` (`handle.go:379`) builds the bound from the
  blueprint at the start commit and the scope's `IDs` when the page is a section redraft, the
  exchange kind is `exSection`, `exRedraft`, or `exFinal`, and `gate_fix` is false; otherwise it
  passes nil.
- **Declining an out-of-scope finding.** A reader or review finding located outside the allowed
  sections can't be fixed under the bound. The contract tells the model to "Decline a blocking
  finding only when it is factually wrong about the page" (`internal/edits/render.go:15`), so a
  bounded turn appends one sentence after `edits.Instructions()`: a finding located outside the
  sections this redraft may change is resolved `declined`, with the reason that it lies outside
  them. `Apply` already accepts a declined blocking finding (`apply.go:82` checks only an `edited`
  resolution with no edits), and a declined blocking finding reaches the next read through
  `declinedFor` (`steps.go:525`). The coherence read, which reads the whole page, can still raise
  it.
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
  the read's findings, on stage `s8`, and no bound, gate-fix turns included. Its edits may touch
  any section. A red gate inside it spends the `exCoherence.contract` budget, as other non-draft
  kinds do (`redGate`). As the fix opens, the pipeline writes the page as it stands to
  `coherence.page.md` in the page's run directory, the way `snapshotRound1` writes
  `round1.page.md` (`steps.go:387-403`), so live row 2 can show the bound held up to that point.
  `coveragePhase(exCoherence)` gives a new phase, `covCoherence`. After the gate and coverage, a
  coverage miss escalates with rule `coherence`. A clean coverage sets the retest flag in `work`
  and returns to `stCoherence`.
- **The retest.** A `fix` on the retest escalates with rule `coherence`, seat `coherence`, and the
  findings numbered.

The executor wires every step function the factsheet names, plus these two the factsheet's list
misses:

- `afterCoverage` (`steps.go:303-328`) gains a `covCoherence` case: a miss escalates with rule
  `coherence`; a clean pass sets the retest flag and goes to `stCoherence`. Its `default` would
  otherwise send the page to `stScoped`.
- `coverageStage` (`steps.go:278-286`) maps `covCoherence` to `s8`; its default is `s3`.

`validate` decodes `edits.Answer` at `stCoherenceFix` and a read at `stCoherence`. `noRetry`
(`handle.go:98-104`) leaves `stCoherence` retryable, as a round-1 read is: a malformed answer is a
fault, and the design's escalation rule is about the verdict. The executor also adds `coherence` to
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
- **Text the checks require.** A stock prompt carries no prose slash ("and/or"), since resolution
  10's `path` check reads any slash token as a path, and never links drafter's own repository,
  since `glw907` is on the `names` denylist.

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

The edge states, each named:

- `facts.dir` unset: each cited id is a defect, `<id> resolves to no fact: the project sets no
  facts.dir`.
- `plan.LoadFacts` fails: the gate can't run, exit 2, as `gateBlueprint`'s read errors already are
  (`cmd/drafter/gate.go`, `exitCannotRun`).
- No `sentences` key: a shape defect.
- `"sentences": []` on a page with prose: no shape defect, and the prose is reported as
  unclassified page text.

A clean check prints one line, `provenance: <page>: N sentences (cited X, no-claim Y)`, as cairn's
clean output does per brief (factsheet "Output"), so a reader of the gate's output can see the check
ran rather than skipped.

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
  line 1. The text is encoded with `SetEscapeHTML(false)`; probed: `json.Marshal("a<b>&c")` gives
  `"a<b>&c"`, and an encoder with `SetEscapeHTML(false)` gives `"a<b>&c"`.
- A page defect cites the page, at the first line whose `Normalize` text holds the fragment's
  first five words, or line 1.

The gate's exit codes are unchanged.

### 10. `drafter check-prompts` on the stock module

The fixture (resolution 11) commits `prompts-matrix.json`, the one case list for the new seats.
B3.3 writes it, since it writes the prompts; the stock package's test and B3.5's check both read
it. It has the shape `stock/testdata/matrix.json` already has (`host` and `cases` of `name`,
`seat`, `context`; `stock/stock_test.go:20-32`, `checkprompts.go:51-55`), which keeps F2's
blueprint cases and their six goldens. It holds one case per stock seat and per shape each seat
renders:

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

- **`path`.** Each token, split as `assemble`'s `tokens` splits (`internal/assemble/files.go:104`,
  which doesn't split on `.` or `:`), with trailing `.`, `,`, `;`, and `:` trimmed, that is
  path-shaped must resolve. A token is path-shaped when it holds a `/` and no `://`, or begins
  `drafter:`. Any `#slug` is cut first, from a repo path and a `drafter:` name alike: F2's
  blueprint seat already emits `drafter:anatomies.md#task-guide` (`stock/prompts.js:28`), and
  slugs are `assemble`'s concern.
  - The case context's `page.path` and `page.brief` are exempt: they are the run's own outputs,
    which the fixture doesn't hold, and `containment` already requires every seat but `blueprint`
    to name `page.path` (`checkprompts.go:219-237`).
  - Any other repo path must name a file or directory the project's git tree tracks.
  - A `drafter:` name must be in `stock.Files`.
  - A token that doesn't resolve fails, naming it.
- **`names`.** The rendering holds none of these case-insensitive strings, taken from the chain
  module's cairn-specific strings: `cairn`, `docs/internal`, `docs-register`, `sveltekit`,
  `cloudflare`, `wrangler`, `glw907`, `npm run check:`, and `option-map`.

A project module, set by `prompts` or `--module`, gets neither check. Its paths are its own.
"The stock module" is what `Config.Module` returns when `prompts` is unset: the exported
`stock.Prompts` bytes (`internal/config/module.go:26-29`, `stock/stock.go:15`).

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
  `fact` and `sentence` items citing those facts. One fact is cited by items in two of the three
  sections, for B3.2's changed-bullet row. The second section holds a `sentence` item citing no
  fact, which live row 2 edits, so row 2's `IDs` are that one section and the shared fact is never
  touched;
- `prompts-matrix.json` (resolution 10).

It has no page, no brief, and no lock: row 1 drafts from nothing. Tests copy it into a temp
directory and `git init` it, as `newSetupEnv` does.

### 12. The live check

`e2e/live_test.go` carries `//go:build live`, and `make live` runs `DRAFTER_LIVE=1 go test -tags
live -count=1 -v -timeout 3h -run Live ./e2e/` and fails when the output holds `--- SKIP` (probed:
a skipped test prints `--- SKIP` under `-v` while `go test` still prints `ok`). It's kept out of
`make check`, as `make smoke` is; the `test` target runs `go test ./...` with no tag
(`Makefile:10-11`). The `vet` target gains `go vet -tags live ./...`, so the file compiles under the
gate.

**The opt-in and the key.** The test skips unless `DRAFTER_LIVE=1`, which only `make live` sets, so
a plain `go test -tags live` in the executor's shell, where the key is set, spends nothing. With
`DRAFTER_LIVE=1`, it is `t.Fatal`, never a skip, when `DRAFTER_LIVE_BASELINE` is unset or doesn't
parse, or when the key doesn't resolve. The key resolves through `config.Load` and `key.Resolve`
(`internal/key/key.go:26-35`), as a run does, since the user layer may set `key_env` or
`key_command`. The key is never printed.

**The runner.** The e2e helpers strip every `DRAFTER_` variable and set a temporary `HOME`
(`e2e/e2e_test.go:47-72`), so the live test has its own runner. It keeps the user's real `HOME`,
for the user layer's `workspace_id`, caps, and key, and for the real ledger the meter reads. It
puts the directory of `TestMain`'s freshly built `binary` (`e2e/e2e_test.go:17-33`) first on
`PATH`, never the repo root's stale `./drafter`, since the stock gate shells out to it, and it runs
`drafter spend` from the same binary. It starts each command with `exec.CommandContext` and a
deadline taken from `t.Deadline()` minus a margin, so a timeout ends the child rather than orphaning
it. Exit 3 (a stop) is resumed with the printed `--resume` command, in the same budget. The runs use
batch mode, the default, at half price.

**The project.** A fresh git copy of the fixture in a directory made by `os.MkdirTemp` and named
`tally-<unix time>`, since runs and the ledger file live under `runs/<repo>`, `<repo>` being the
main checkout's base name (`internal/run/id.go:38-48`). The test removes it only when every row
passes. On a failure it logs the run id, the project path, and the resume command, and the PR body
carries them, since a run left stopped in a removed directory can never be resumed and its open
intent counts at worst case in the ledger for good (`internal/ledger/store.go`, `cycleTotal`).

**The budget.** Before each `drafter page` call, the test reads `drafter spend --since 2026-10-19
--json` and computes the budget left: $20 minus (the total, minus `DRAFTER_LIVE_BASELINE`, plus
`open.worst`). At or below $0 it fails with the reading. Otherwise it sets `DRAFTER_PAGE_CAP` to the
budget left for that call (standing answer 2).

| Row | Action | Assertions |
|---|---|---|
| 1 | `drafter page docs/count-items.md --json` | Exit 0; the page is accepted. Its scope is `kind: whole` with a `Why` naming the missing lock entry. The lock entry's `page` equals `git hash-object` of the page, `blueprint` equals the blueprint's blob at HEAD, `sections` equals `SectionHashes` over the page, and `accepted` equals the blueprint's blob at HEAD. `drafter gate --page docs/count-items.md` exits 0, prints no `provenance check skipped` line, and prints the `provenance:` count line. Then commit the page, the brief, and the lock. |
| 2 | Change the second section's `sentence` item text (resolution 11), commit, and run `drafter page docs/count-items.md --json` again | Exit 0; the page is accepted, scoped to exactly that section's id. The run's `record.json` holds a `coherence` seat verdict on stage `s8`. Cut with the blueprint's headings, the page outside that section (preamble, other sections, heading lines) equals row 1's committed page in the final page when the coherence fix didn't run, and in the run's `coherence.page.md` when it did; any later out-of-scope difference is then the coherence exchange's, and the PR reports it (the clarification of the design's Check row 2, below). The lock entry is updated: new `page`, new `blueprint`, and `accepted` kept. The gate check of row 1 passes again. Commit. |
| 3 | `drafter page docs/count-items.md --json` again | Exit 0; it prints `up to date with drafted.lock`. The summary's `run_id` is empty and its cost zero, the set of run ids under the repo's runs directory is the same before and after, and the meter's row for this repo (`spendRow.Repo`) is unchanged. |

Each row runs only after the one before passes (`t.Fatal` on a miss), so a row 2 miss doesn't also
report a row 3 failure.

**The clarification of Check row 2.** The design's row 2 says "the page diff outside it is empty",
and its build item 5 lets the coherence fix touch any section. The planning session ruled that
out-of-scope regions are compared against the page before the coherence fix, and every
out-of-scope change must come from the coherence exchange. The PR body names this as a departure
from the design's wording.

## Tasks

### B3.0: baseline, request goldens, fixture, coherence seat, options, and stock stubs (60 min), by the session

Outcome: what both pairs build on, with no behavior change beyond the new seat's configuration.

0. At launch, before any edit: record `drafter spend --since 2026-10-19 --json` into STATUS (the
   baseline, standing answer 2). Then, on the `f286162` code, capture and commit two request
   goldens, so B3.1's and B3.2's "byte-identical" rows compare with the old code rather than with
   themselves: the fixture blueprint's `drafter read --dry-run` request body (written once the
   fixture of item 1 exists, still before any pipeline or cmd edit), and the stage-1 blueprint-read
   request from `newBlueprintHarness`. The B3.0 commit message body quotes the baseline JSON.
1. The fixture of resolution 11, except `prompts-matrix.json`, which B3.3 writes.
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
   `internal/pipeline/stockmodule_test.go`, and `e2e/stockmodule_test.go`. `TestStockModuleSeats`
   (`stock/stock_test.go:52-57`) asserts `[blueprint]` and now asserts the seven seats.

- Files: `e2e/testdata/cli/**`, `internal/config/{check.go,stock.toml}` and their tests,
  `internal/smoke/{shapes.go,smoke_test.go}`, `internal/pipeline/{pipeline.go,work.go,start.go}`,
  `stock/{prompts.js,stock.go,stock_test.go,google-*.md}`, the three stockmodule tests, the two
  request goldens under `cmd/drafter/testdata/` and `internal/pipeline/testdata/`, and
  `docs/configuration.md`.
- Risk class `runner`.
- Acceptance: `make check` green. `drafter check` on a git copy of the fixture reports 0 errors.
  The two goldens land in their own commit, made before any pipeline or cmd edit. Named
  tests: `TestStockModuleSeats` and the three stockmodule tests. The session commits before pair
  A starts.

### B3.1: the pipeline's drafting path (215 min), paired with B3.3, `opus` at `high`

Outcome: resolutions 4, 5, and 6, and the pipeline half of 7.

- Files:
  - `internal/pipeline/{work.go,page.go,blueprint.go,handle.go,steps.go,check.go,start.go,record.go}`
    as needed, and new pipeline test files.
  - `internal/edits/{apply.go,types.go,render.go}` and their tests (the decline sentence lives
    beside `Instructions`).
  - `internal/coverage/sections.go` and its test.
  - `internal/assemble/blueprint.go` (the facts block's drafting variant).
  - `docs/prompts-module.md` ("The context object": the `scope` values and the blocks).
- Never `money.go` or `fingerprint.go`. `resume.go` only per the ALLOW ruling: test-first, then a
  task-scope `diff-reviewer` read with the auth-data bar on each commit touching it, before the
  next task.
- Risk class `runner`.
- Tests, table-driven, on the scripted `fakeAPI` (`internal/pipeline/fake_test.go`) and the
  blueprint harness (`newBlueprintHarness`). They render through a test module or assert request
  structure only, never B3.0's stub prompt text, which B3.3 replaces in parallel.
  - A `Draft` blueprint page reads, then drafts whole, gates, covers, reviews, and accepts.
    `Accepted` is in its result. Without `Draft`, the same page accepts at the read, as today
    (regression).
  - `SkipRead` goes straight from the check to `stDraft`, with no stage-1 request.
  - `planDoc()` returns the view for a blueprint page.
  - The draft, review, and coherence requests carry the two blocks, and the reader's carry none.
    The blueprint read's request equals B3.0's committed golden (regression).
  - The section decision (resolution 5): a scoped page whose `IDs` headings are all found is a
    section redraft; a scoped page with a missing heading (an added section) drafts whole with no
    bound and keeps its change read; a page with empty `IDs` drafts whole; the decision is saved in
    `work.section` and a resume after the first write doesn't decide again.
  - A section redraft opens with one finding per changed section. Its draft render has `scope`
    and `findings` set, and its review renders have `scope` set. `stageScoped` still sets the
    cited findings.
  - `edits.Apply` with a bound:
    - accepts an edit inside an allowed section;
    - refuses an edit in another section, in the preamble, or on a heading line, naming the line;
    - refuses an answer that deletes an allowed heading;
    - refuses an edit that opens an unbalanced fence, and one that adds a heading duplicating a
      later heading's text;
    - refuses a brief edit to an out-of-scope sentence, and an added sentence whose text lies only
      outside the allowed sections;
    - allows a brief edit, addition, or removal for an in-scope sentence.

    With a nil bound, every existing row passes unchanged (regression).
  - Where the bound applies, one row per exchange: in a section redraft, a scripted answer at
    `exSection`, `exRedraft`, and `exFinal` that edits an out-of-scope section is refused naming
    that line; the same edit in a gate-fix turn of each, and in the coherence fix and its gate-fix
    turns, applies.
  - A reader finding located outside the allowed sections, resolved `declined` at `exFinal` with
    the out-of-scope reason, is accepted, and the page goes on to the scoped reads; the bounded
    turn's prompt carries the decline sentence.
  - The refusal reaches the model through `refused`, and the contract budget escalates as today.
  - Coherence:
    - `ok` accepts;
    - a first `fix` writes `coherence.page.md`, runs an unbounded exchange that may edit any
      section, then the gate and coverage (`covCoherence`, stage `s8`), then the retest;
    - a red gate inside the fix spends `exCoherence.contract`;
    - a retest `fix` escalates with rule `coherence`;
    - a coverage miss after the fix escalates with rule `coherence`;
    - a whole draft never runs coherence.
  - `missingSeats` lists `coherence` only for a section redraft.
  - A resume across each new step: a run stopped with an open intent at `stSection`, at
    `stCoherence`, and at `stCoherenceFix`, and one stopped after a section write with
    `PendingGate` set. Each resumes, finishes, and spends no request twice. These follow
    `resume_test.go`'s pattern. If a resume fails because `checkTree` or `wantHashes` can't account
    for a new step, that's the ALLOW case: the failing test first, then the fix.
  - A pre-B3 state: its `work` JSON with no `draft` field decodes as a read; and a stopped run
    whose `fingerprint.json` is frozen from `f286162` (no `seat.coherence.*` keys) refuses to
    resume with "the configuration changed since the run started (seat.coherence.…)", the
    documented known limit (finding 6).
- Acceptance: `make check` green in the pair worktree, and each row above, by test name, shows
  `PASS` under `go test -run '<names>' -v`. The commit message lists every step function wired for
  each new step and names the tests.

### B3.3: the stock seat prompts and the Google standard package (130 min), paired with B3.1, `opus` at `medium`

Outcome: resolutions 7 and 8, the prompt half.

- Files: `stock/prompts.js`, `stock/google-{description,tells,rubric,corpus}.md`,
  `stock/stock_test.go`, `stock/testdata/` (one golden per new seat), the fixture's
  `e2e/testdata/cli/prompts-matrix.json` (resolution 10), and `docs/prompts-module.md` ("The stock
  module": the seats and the package files). Coordinate on `docs/prompts-module.md` by section:
  B3.1 owns "The context object", B3.3 owns "The stock module". The merge keeps both.
- Risk class `runner`.
- Load `writing-voice` first for the four reference pages, which follow Google developer
  documentation style. The prompts are written to resolution 7's context and nothing beyond it,
  and to resolution 8's "Text the checks require": no prose slash, no link to drafter's repo.
- Tests in `stock`:
  - The module loads under `prompts.Load` and defines exactly the seven seats.
  - Every case of the fixture's `prompts-matrix.json` renders. One golden per new seat, from its
    first case; the targeted rows below carry the content. F2's six blueprint goldens
    (`stock/testdata/{whole,change}-{anatomy,neither,register}.txt`) are unchanged (regression).
  - No rendering holds any denylisted string (resolution 10), one row per string.
  - No rendering without a `register` holds "register".
  - Every `drafter:` token in a rendering, with any `#slug` cut, is a `stock.Files` name; an
    unknown slug on a known file still passes.
  - The draft rendering for a whole draft states the brief schema and the provenance rules of
    resolution 9, and contains the description, tells, and corpus tokens
    (`drafter:google-description.md`, `drafter:google-tells.md`, `drafter:google-corpus.md`).
  - The editor rendering contains `drafter:google-rubric.md` and `drafter:google-tells.md`.
  - The section draft says to change only the sections in `scope`.
  - The coherence rendering names the changed sections and says findings may lie anywhere.
  - Each package file is non-empty; `google-rubric.md` has at least 10 rules, each carrying a
    `developers.google.com/style` URL; `google-tells.md` has at least 5 before-and-after pairs;
    `google-corpus.md` has at least 3 entries, each carrying a URL, a license, and a retrieval
    date.
- Acceptance: `make check` green, and each row above, by test name, shows `PASS`. The PR body lists
  each corpus excerpt's URL and license, and states that each was checked against that page's
  footer.

### B3.2: `drafter page` from blueprints, the lock scope, and the lock write (170 min), by the session in pair A's shadow

Outcome: resolutions 1, 2, and 3.

- Files:
  - `cmd/drafter/page.go`.
  - `cmd/drafter/read.go`: `blueprintHandoffs`, `entryJSON`, `changeBlock`'s endpoints, and a
    shared lock helper with `recordAccepted`.
  - A new `cmd/drafter/draftscope.go` if the scope function outgrows `page.go`.
  - `internal/blueprint/install.go` (the exported entry writer), `internal/blueprint/cited.go`
    (the bytes-in function), and the lock walk's helper, if it lives in `internal/blueprint`.
  - `docs/blueprint-format.md`: "drafted.lock" says `drafter page` writes an entry on accept, and
    "What `drafter read` does with a blueprint" gains a sibling section, "What `drafter page` does
    with a blueprint". It states the commit rule of finding 5, and that a stopped run's accepted
    pages get no entry until it's resumed: resume the run, or discard its pages and run again.
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
  - The walk ignores `accepted`: draft at D, then a fact edit and a blueprint edit in one commit,
    then a read-accepted lock commit that changes only `accepted`. The changed fact's citing
    sections are in scope. A historical lock that doesn't decode stops the walk there.
  - A changed bullet: on the fixture, edit the bullet of the fact cited in two sections, commit;
    the scoped `IDs` equal exactly those two section ids. A brief sentence in a third section
    citing that fact widens `IDs` to it. A preamble sentence citing it makes the scope whole.
  - A seeded page (lock entry with a `page` id, no brief at the start commit) with a one-item
    edit drafts whole.
  - `SkipRead`: `accepted` equal to the blueprint blob at the start commit, with a fact-only
    change, sets `SkipRead` and sends no stage-1 request; a stale `accepted` leaves it unset.
  - `TestBlueprintHandoffs` on the fixture asserts `Inputs.PageType`, `Inputs.FactIDs` (taken from
    the start commit's bytes, not the working tree), and `Inputs.ExemplarSources`.
  - An all-unchanged run prints `up to date with drafted.lock`, exits 0, and resolves no key: the
    test runs with no key source configured and with neither Vale nor `drafter` on `PATH`.
  - A tracks mismatch, and a `standard` other than `google`, on the stock module are refused
    before any request.
  - The lock write, unit-tested on a synthetic `pipeline.Summary` in a temp repo:
    - an accepted page's entry has the four fields of resolution 2;
    - a scoped accept keeps `accepted`;
    - a skipped read keeps `accepted`;
    - an escalated page's entry is untouched;
    - a dry run and a stopped run write nothing;
    - a write that changes nothing leaves the bytes alone;
    - with HEAD moved past the start commit by a fact edit, the write warns and names the file.
  - The lock write through a real run, on `readStub` (`cmd/drafter/read_test.go:342-392`) in sync
    mode:
    - a run stopped by `failFrom` after page A was accepted, then `--resume` with the same
      arguments, writes A's entry with the start commit's blueprint blob;
    - a finished run whose lock write failed (the worktree lock held by the test) prints the
      summary and the resume command, and that `--resume` writes the lock and submits no Messages
      request.
  - `entryJSON` carries `brief`, `standard`, and `reader`, and the standard is `google` with no
    tracks.
  - `drafter read`'s dry-run request on the fixture blueprint equals B3.0's committed golden
    (regression).
- Acceptance: `go test ./cmd/drafter/... ./internal/blueprint/...` green, and each row above, by
  test name, shows `PASS`; then `make check` after pair A merges.

### B3.4: provenance in the stock gate (125 min), paired with B3.5 after pair A merges, `sonnet` at `high`

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
  - a page with a blueprint and no brief, skipped with the message;
  - each edge state of resolution 9: `facts.dir` unset, `plan.LoadFacts` failing (exit 2), no
    `sentences` key, and `"sentences": []` on a page with prose;
  - a brief sentence holding `<`, `>`, or `&` is cited at its own line;
  - a clean page prints the `provenance:` count line.

  Each extraction regex the port rewrites without lookaround gets the boundary rows its JS source
  implies: a date inside a longer token, a version followed by `.digit`, and a numeral with a
  thousands comma. The gate's output lines name the page or brief, and `gate.Result.ForPage` reads
  each as the page's own. `TestSetupFromNothing` stays green (regression).
- B3.3's draft prompt states resolution 9's rules, and B3.3 ran first. If this task settles a rule
  differently, it updates the draft prompt's rule paragraph and that seat's golden in the same
  commit.
- Acceptance: `make check` green, and each row above, by test name, shows `PASS`. The commit
  message lists each cairn rule dropped, and why it's cairn-only.

### B3.5: `check-prompts` on the stock module (50 min), paired with B3.4

Outcome: resolution 10.

- Files: `cmd/drafter/checkprompts.go` and its test, `e2e/checkprompts_test.go` (a new
  `stockCheckPrompts…` test), and `docs/prompts-module.md` ("Check a module"). It reads the
  fixture's `prompts-matrix.json`, which B3.3 wrote.
- Risk class `runner`.
- Tests:
  - e2e: on a git copy of the fixture, with no page and no brief, `drafter check-prompts --matrix
    prompts-matrix.json` exits 0, so `path` passes on the exempt `page.path` and `page.brief`.
  - `cmd/drafter` unit tests swap the exported `stock.Prompts` for an edited copy, restored with
    `t.Cleanup`, so `Config.Module` still reports the stock module (`internal/config/module.go:26-29`)
    and no new seam is needed:
    - a rendering that names a path the fixture lacks fails `path`, naming it;
    - a token ending a sentence (`docs/x.md.`) resolves after the trim;
    - `drafter:anatomies.md#task-guide` passes;
    - a rendering holding each denylisted string fails `names`, one row per string.
  - The same edited module set as the configured `prompts` is a project module and passes both
    checks.
  - The matrix holds a case for every seat `stock` defines, checked by the test.
- Acceptance: `make check` green, and each row above, by test name, shows `PASS`.

### B3.7: the live harness, then acceptance offline and live (205 min), by the session after pair B merges

Outcome: the design's "Check", run end to end. B3.6, the live harness, is folded in here, since it
was a single deliverable (pass-core, "Plan").

1. **The live harness (50 min).** Resolution 12's `e2e/live_test.go` (`//go:build live`) and the
   `Makefile` (`live` target with `DRAFTER_LIVE=1`, `-v`, and the `--- SKIP` check; the `vet`
   line; `.PHONY`). Tests, with no API call:
   - `make check` green, with the vet line compiling the file.
   - `env -u DRAFTER_LIVE go test -tags live -run Live ./e2e/` skips with its reason and spends
     nothing, though the executor's shell holds the key.
   - With `DRAFTER_LIVE=1`, an unset or unparseable `DRAFTER_LIVE_BASELINE` fails, not skips.
   - The meter helper's arithmetic and the `DRAFTER_PAGE_CAP` value it sets have a table-driven
     unit test, including the at-or-below-$0 refusal.
2. **The offline end-to-end test (50 min), before any live run.** A new e2e test,
   `e2e/draft_test.go`, runs the built `drafter page` in sync mode on a git copy of the fixture,
   against a scripted stub with `api_base_url`, as `e2e/page_test.go` points the binary at
   `apiStub`. The stub answers `/v1/messages` by the request's output schema
   (`output_config.format.schema`, set from `Request.Schema` in `internal/batch/request.go:44-49`):
   a draft answer, edits, a read, a reader turn, coverage, or consistency, so each seat gets a
   well-formed answer without the stub parsing prompts. The real `drafter gate` runs, with the
   built binary's directory on `PATH` and Vale resolving the fixture's offline style. It runs
   live rows 1 to 3 with the same assertions, plus a fourth case: a fact-bullet edit run with
   `SkipRead`, which sends no stage-1 request. This joins B3.1, B3.2, B3.3, and B3.4 through the
   command layer before money is spent. B3.1's coherence rows already cover the coherence fix and
   retest on the fake API, so no separate pipeline test repeats them.
3. **Live (105 min).** Read the baseline from STATUS and pass it as `DRAFTER_LIVE_BASELINE`. Run
   `make live` from the worktree. The test computes the budget and sets `DRAFTER_PAGE_CAP` before
   each `drafter page` (standing answer 2).
   - If a row misses, the executor reads the run's `record.json` and fixes the cause in code or a
     stock prompt, with a test where the fault is mechanical, and adds the case to the offline
     end-to-end test when it can be scripted. It reruns from a fresh fixture copy, inside the
     budget.
   - A miss that remains when the budget would be exceeded ends the live work. The PR opens with
     the miss, the record excerpt, the spend, and any kept project path and resume command
     (standing answer 4).
- Files: `e2e/live_test.go`, `e2e/draft_test.go`, the `Makefile`, plus whatever a live miss's fix
  touches, each named in the PR body.
- Risk class `runner`, with `live-account` (API spend).
- Acceptance:
  - Offline: `make check` green; the harness rows and the end-to-end test, by name, show `PASS`;
    B3.5's e2e check-prompts test passes.
  - Live: rows 1 to 3 pass, or a miss is reported with standing answer 4. `make live`'s output holds
    no `--- SKIP`.
  - The PR body carries each row's result, the run ids, the cost per row from the summaries, the
    baseline and the meter readings before and after, the clarification of Check row 2 as a
    departure, and a note that Vale ran the fixture's one-rule synthetic style, so "passes the stock
    gate" doesn't mean the real Google Vale package ran.

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
   - the score, per pass-core "Score", with the Work and review row naming 665 path minutes beside
     the actual.
4. Each "Found, not done" item worth doing goes to drafter's `BACKLOG.md` through `log-issue`,
   tagged `#initiative:docs-system`, and is listed in the PR body with its number. The six
   "Findings for the planning session" items go in as well, unless the planning session filed them.
5. Stop at PR-ready. The conductor hands the packet to Geoff.

## Merge order

1. glw907/drafter's B3 PR, with `--match-head-commit` from the decision. Then pull
   `~/Projects/drafter`. Before `make install`, check that no drafter run is stopped and
   resumable (finding 6): `grep -l '"stopped"' <state_dir>/runs/*/*/state.json` prints nothing,
   `state_dir` taken from `drafter config` (a resumable run's state carries `stopped`,
   `internal/run/state.go:28`). If one is, resume it with the old binary first. Then run `make
   install`, as after F2, so the installed `drafter` has the stock seats and the provenance gate.
2. No cairn-cms PR: cairn's half is B3c. The hand-over's Status line names B3c's design, after
   Geoff's ruling on drafter backlog #1, #8, and #13, as next.

## Later

Kept out of B3 and never built here:

- B3c: converting cairn's stage 2b plans, the whole-read bar (drafter backlog #13, drafter#43),
  and the cairn pilot drafts.
- The lock's commit field, the write-back seat, clearing `origin: human`, commits, and pull
  requests (B4). The commit field also closes the case in finding 2.
- The lock entry's start-commit field (B4), which replaces finding 5's warning: with the start
  commit recorded, the walk no longer infers what the draft saw.
- Letting a stopped pre-B3 run resume across a new stock seat (finding 6), which needs a
  `fingerprint.go` change under the auth-data bar.
- A real Google Vale package in the live check, in place of the fixture's one-rule style.
- Human-edit detection before a redraft (B4).
- A fresh consistency read when the read is skipped and a cited fact bullet changed since it
  (finding 3).
- A setting to turn off the coherence read.
- Stock seat `inputs` that give a round-2 read the redraft's diff from the baseline.
- Sending the draft seat only the changed sections' blueprint entries, in place of the whole
  blueprint with the changed ids named.
- The Microsoft standard package.
- The plugin and onboarding (O).
