# drafter blueprint-first factsheet: the pipeline, the lock, and the read

Read at drafter `main` 6a42564 (Merge pull request #56), clean tree, 2026-10-20. Paths are relative to
`/var/home/glw907/Projects/drafter`. Line numbers are at that commit; symbols are named so a moved
line can be found again.

## 1. The lock

**Types** (`internal/blueprint/blueprint.go`):

- `Lock` (:180-183): `Version int yaml:"version"`, `Pages map[string]LockEntry yaml:"pages,omitempty"`.
- `LockEntry` (:195-201), YAML tags only, no JSON tags:
  `Page string yaml:"page,omitempty"`, `Blueprint string yaml:"blueprint,omitempty"`,
  `Accepted string yaml:"accepted,omitempty"`, `Sections map[string]string yaml:"sections,omitempty"`,
  `Blocked *Blocked yaml:"blocked,omitempty"`.
- `Blocked` (:205-208) is `Commit string yaml:"commit"` and `Findings []BlockedFinding yaml:"findings"`.
  `BlockedFinding` (:211-214) is `Location`, `Text`. It has no kind and no seat.
- `Version = 1` (:14) is shared by the blueprint, the outline, and the lock.
- `LockFile = "drafted.lock"` (`install.go:17`). It sits beside the outline (`cmd/drafter/bar.go:24-26` `lockRel`).

**Decode** (`internal/blueprint/lock.go`): the decoder is strict. `DecodeLock` (:58-69) calls
`dec.KnownFields(true)` (:60), so an unknown field is an error, and a `Version != Version` is
`unsupported version`. `ReadLock` (:46-55) reads a missing file as `&Lock{Version: Version}`.
`committedLock` (`cmd/drafter/bar.go:31-42`) decodes the lock as committed at a revision. A commit
with no lock gives an empty lock. A lock that fails to decode is an error: "a drafter that knows its
format must read it".

**Write**: `WriteLock` (`lock.go:73-80`) uses `yaml.Marshal`, prepends
`# Written by drafter; do not edit by hand.\n`, and writes through `atomicfile.WriteFile` (atomic
rename). Map keys come out sorted, and struct fields come out in struct order (page, blueprint,
accepted, sections, blocked). `updateLock` (`bar.go:46-66`) takes the worktree lock
`<gitdir>/drafter.lock` (`runstate.TryLock`), reads the lock, runs `edit`, and writes only when
`edit` reports a change.

**Every writer of an entry**:

| Writer | Where | What it writes |
|---|---|---|
| `recordReads` | `cmd/drafter/bar.go:79-116` | Scoped accept (:83-94): `e.Accepted = r.Accepted` only if `scopedRefusal(e, bases[path]) == ""` (:120-131). Whole or bar accept (:95-99): `e.Accepted, e.Blocked = r.Accepted, nil`. Whole read that blocked (:100-105): `e.Blocked = barOf(start, r.Findings)`. A blocked change read leaves the entry alone. |
| `recordAccepted` | `cmd/drafter/read.go:507-517` | `drafter read`'s lock write. Wraps `recordReads` in `updateLock`. Skips a dry run and a stopped run. |
| `recordDrafted` | `cmd/drafter/pagebp.go:186-226` | `drafter page`. Runs `recordReads` first with `bases[p] = e.Blueprint` (:195-198), then for each accepted page calls `blueprint.DraftedEntry(root, start, bp, r.Path, prior.Accepted)` (:208). It skips the write when `e.Page == prior.Page && e.Blueprint == prior.Blueprint && e.Accepted == prior.Accepted && maps.Equal(e.Sections, prior.Sections) && prior.Blocked == nil` (:212). |
| `DraftedEntry` | `internal/blueprint/drafted.go:15-39` | `newLockEntry(b, pageBlob, pageBytes, bpBlob)`, then sets `e.Accepted = accepted`. Nothing else carries over. |
| `newLockEntry` | `internal/blueprint/install.go:126-128` | `LockEntry{Page, Blueprint, Sections: SectionHashes(...)}`. |
| Convert install | `install.go:102-108` | A new entry via `newLockEntry`. Refuses a page that already has an entry (:83-85). |
| `Seed` / `seedEntry` | `internal/blueprint/seed.go:36-58`, `:62-110` | Requires `old.Accepted == HEAD blob` (:92). Builds `newLockEntry(...)`, then `entry.Accepted = old.Accepted` (:107-108). |

**Readers of an entry**: `skipRead` (`cmd/drafter/draftscope.go:112-114`), `pageScopeFor` (:123),
`readBars` (`read.go:189-204`), `scopeFromLock` (`draftscope.go:74-108`), `lockEntries` check
(`internal/blueprint/check.go:360-390`), and `LockIntroducedAt` (`drafted.go:48-70`). The last one
compares only `Page`, `Blueprint`, and `Sections` (:64), so a new field is ignored there with no change.

**Fixtures**: no `drafted.lock` file sits on disk under testdata. Every lock fixture is inline Go:

- `internal/blueprint/lock_test.go`: `TestLockRoundTrip` :39-71, and `TestLockBlocked` :75-119. The
  latter pins the exact bytes of a no-bar entry (:76-85).
- `internal/blueprint/check_test.go`: :89-103 and :139 (YAML strings).
- `cmd/drafter/read_test.go`: :46 and :310 (YAML).
- `cmd/drafter/bar_test.go`: 8 hits. `cmd/drafter/pagebp_test.go`: 4. `draftscope_test.go`: 2.
  `convert_test.go`: 3. `seed_test.go`.
- `internal/blueprint/{seed,convert,drafted}_test.go`.
- `e2e/blueprint_test.go:14`. `e2e/readbar_test.go:92-211` compares `Blocked`, `Accepted`, and `Page` field by field.
- `e2e/draft_rows_test.go`, `e2e/draft_test.go:24`, `e2e/live_test.go:34`.

`internal/blueprint/docs_test.go:37` hard-codes the documented lock fields
`[]string{"page", "blueprint", "accepted", "sections"}`.

**Touches** (adding `facts`): `LockEntry`; `recordReads`'s two accept cases; `recordDrafted` (:208 and
the :212 equality); `DraftedEntry` (its signature carries only `accepted`); `seedEntry` (:107-108
drops any field it does not copy); `docs_test.go:37`; `lock_test.go`; `blueprint-format.md` §drafted.lock
(:273-342). Under `KnownFields(true)` an older drafter rejects a lock that carries `facts`; the version stays 1.

## 2. The cited set

There are three different "cited set" functions, and none matches the design's full set.

1. **`Project.Cited` / `Project.CitedIn`** (`internal/blueprint/cited.go:17-27`, `:31-54`), exported.
   It returns the introduction's facts, each fact item, each item's `facts` list, and framing
   citations, which `View` turns into `_framing-<part>` example items (`view.go:50-65`). The comment
   says it plainly: "A disposition names a fact the page leaves out, so it does not count" (:12-13). The
   result is sorted and compacted. It returns empty when the blueprint fails to decode or the page is
   not managed. `CitedIn` reads the facts store and the lock from the **working tree** (:29-30).
   Callers: `cmd/drafter/gate.go:139` (`gateBlueprint`, which passes the ids to `VerifyFacts`) and
   `draftscope.go:39` (`draftInputs` sets `Inputs.FactIDs`, the ids the drafting seats' excerpts come from).
2. **`citedFacts`** (`internal/blueprint/since.go:270-278`), unexported. It is
   `pageFacts` (introduction, `dispositionFacts`, and `framingFacts`; :265-267) plus `itemFacts` for
   every item. **This is the only function that covers all five sources the design names.** It
   returns unsorted ids with duplicates possible, and it takes `(*Blueprint, *plan.Facts)`. `Compare`
   uses it (:144, :159-161).
3. **`placedFacts`** (`internal/assemble/consistency.go:81-102`), unexported, over a `*plan.Plan`
   view. It covers the introduction, fact items, and every `facts` list, framing included through
   `View`, but **no dispositions**. `ConsistencyPrompt` (:26) and `FactsBlock` (`assemble/blueprint.go:32`) use it.

`Project.Refs` (`refs.go:31-56`, `refsIn` :58-79) lists dispositions as well; that is `drafter refs`.

**`drafter check`'s `facts` check**: `plan.Check` → `(*checker).facts` (`internal/plan/check.go:393-460`)
runs over `View(b, entry, c.l.facts)` (`blueprint/check.go:138`).

- It loads the store itself with `LoadFacts(c.opts.FactsDir)` (:414).
- Citability (verified, external, or vendor) is checked on the introduction's facts and every
  `facts` list through `eachFactsList` (:124-133, which includes the framing items) and on fact items (:452-456).
- **A disposition is only resolved, never checked for citability**: `resolve(c.p.Dispositions[i].Lines["fact"], ...)` (:457-459).
- `ids` (per the docs table, `blueprint-format.md:386`): "no fact is both placed and disposed".

**Loading facts**: `plan.LoadFacts(dir)` (`internal/plan/facts.go:140-154`) →
`ParseFacts(files, root)` (:158-176). A bullet is held in `plan.Fact` (:35-50):

```go
type Fact struct {
	ID   string
	File string // base name within the facts directory
	Line int
	Tag string      // status tag name, empty when Problem is set
	Problem string
	Text string     // the claim: what follows the id up to its Source: part or its status tag
	Sources []string // backticked Source: spans outside parentheses and brackets that name a repo path
}
```

**The raw bullet text is not kept.** `extractBullets` (:187-214) joins continuation lines with single
spaces into `bullet.text`, and `ParseFacts` discards it after parsing. What survives is:

- `Tag`, the tag **name** only. `checkTag` returns `masked[m[2]:m[3]]` (:239), so a qualifier such as `[verified: 2026-10-01]` is lost.
- `Text`.
- `Sources`, filtered by `isSource` (:312-338). It drops spans inside `(...)`/`[...]`, which is
  where the anchor code span sits. It also drops a slashless name that does not exist at the root,
  and URLs.

The whole bullet does survive in one place: `storeBullet.text` in `plan/verify.go:73-81`, which is unexported.

`FactChanged` (`since.go:205-218`) compares
`o.Tag != c.Tag || o.Problem != c.Problem || o.Text != c.Text || !slices.Equal(o.Sources, c.Sources)`.
So a change to a tag qualifier or a pointer's anchor is invisible to it today.

**Touches**: a hash "over the bullet's text, pointer and tag included" needs either a new raw or
verbatim field on `plan.Fact` (set in `ParseFacts`) or a canonical form built from
`Tag`/`Text`/`Sources`. The latter leaves anchors and qualifiers out. Taking the full set needs either an
exported wrapper over `citedFacts` or a change to `CitedIn` that adds dispositions. The second
shifts `drafter gate`'s `VerifyFacts` ids and `draftInputs` `FactIDs`, which feed the excerpts of
every drafting seat.

## 3. Change scoping, the bar, and where "lapsed" plugs in

**`Compare`** (`internal/blueprint/since.go:61-186`) returns a `Scope{Kind, IDs, Facts, Bullets, Joined, Why}` (:31-38).

- `ScopeWhole` when the blueprint is absent or fails to decode at either revision, or the outline lacks the entry at either (:62-73).
- Otherwise `ScopeScoped` when anything differs: the outline entry (`sameYAML`), the non-section
  fields, a section's content, a removed or reordered section, or **any cited fact whose bullet
  changed** (:143-151). Else `ScopeUnchanged` (:176-178).
- `Facts` is the set of touched facts. `Bullets` lists every changed bullet in either store (:153-158).
  `Joined` lists facts newly cited (:159-166).
- `IDs` holds the changed sections, including a section that cites a changed bullet (`sectionCites`, :171).

`Revision` (:42-46) is `{Blueprint []byte; Entry *Page; Facts *plan.Facts}`.

**`revisionAt`** (`cmd/drafter/read.go:348-389`) builds a `Revision` at a commit: `git show` for the
blueprint and the outline, then `git ls-tree` plus `ParseFacts` for the store. A store git cannot
list returns an empty `Revision`, which reads whole (:372-378).

**`--since`**: `runRead` (`read.go:125-129`) resolves the rev, then `scopePages` (:255-269) →
`comparePage` (:274-285) → `Compare` plus `changeBlock`. An unchanged page is skipped as `unchanged`
with "nothing changed since <rev>".

**`drafter read` with no `--since` and no `--resume`** (`read.go:130-133`) → `readBars` (:189-204).
It touches only entries with `Blocked != nil`, through `applyBar` (`bar.go:191-208`):

- The bar commit is missing → read whole with a warning (:193-197).
- `comparePage(c, root, b.Commit, head, h)`, then:
  - `ScopeUnchanged` → `heldPage`. Status `held`, the bar's findings, no request (:200-202, :212-223).
  - `ScopeScoped` → a bar read: `m.changes[p], m.bars[p], m.barFrom[p] = change, renderBar(b), b.Commit` (:203-205).
  - `ScopeWhole` → whole.

**Every other page reads whole on every run.** `drafter read` has no skip for an accepted,
unchanged blueprint. Only `drafter page` skips: `skipRead(e, blob)` is
`e.Accepted != "" && e.Accepted == blob` (`draftscope.go:112-114`), applied at :93-94. That skip is
backlog #20: a fact-only edit drafts with no fresh read.

**`pageScopeFor`** (`draftscope.go:123-170`) is `drafter page`'s draft scope.

- It is whole when there is no `Page` in the entry or no committed page.
- Otherwise it finds `introduced := blueprint.LockIntroducedAt(...)` and compares
  `revisionAt(ParentCommit(introduced))` (with `old.Blueprint = BlobBytes(e.Blueprint)`) against head.
- Unchanged → `upToDate` ("up to date with drafted.lock", :19).
- `widenIDs` (:177-213) sends a preamble that cites a changed fact to whole.
- The change block uses blob ends: `diffEnds{from: e.Blueprint, to: blob, blobs: true}` (:165).

**`LockIntroducedAt`** (`internal/blueprint/drafted.go:48-70`) walks `git log -- drafted.lock` newest
first. It keeps the oldest commit of the unbroken run whose entry has the same
`Page`/`Blueprint`/`Sections`, and it ignores `Accepted` (backlog #30: no `--first-parent`). **The lock
records no commit for an accept.** `blueprint-format.md:304-305` says "The lock has no commit field"
(backlog #21).

**The change block** comes from `changeBlock` (`read.go:299-338`), which takes `diffEnds` (two commits,
or two blob ids), `Scope`, and the old and current `Revision`. It builds `[]assemble.FactChange{ID, Old, New *plan.Fact}`
for each `sc.Facts` id where `FactChanged` holds (:311-324). Then
`assemble.ChangeBlock(diff, facts, oldEntry, newEntry)` (`internal/assemble/blueprint.go:78-96`) emits
three parts:

- `=== blueprint diff ===`, left out when the diff is empty.
- `=== changed facts ===`, with `- id\n  was: [tag] text\n  now: [tag] text` per fact. `factLine` (:98-103) prints the tag and text only, **with no pointers**, so a moved pointer shows identical was and now lines.
- `=== outline entry change ===`.

**A fact-only diff can be passed today.** A fact-only change makes `Compare` scoped with
`Facts`/`Bullets` set, and `ChangeBlock` carries the changed facts with an empty blueprint diff. That
needs an old `Revision`, which means a commit for the old facts store.

**Where "lapsed" plugs in**:

- `drafter read`: the `default:` branch of the switch in `runRead` (`read.go:130-133`), inside or
  beside `readBars`, before `pipeline.Run` (:156). The per-page change state goes in through
  `pipeline.Options.Scopes/Changes` (global `Since`) or `ReadScopes/ReadChanges` plus `Bars/BarFrom`.
  `internal/pipeline/start.go:276-284` sets `p.w.Since` only from `r.o.Since` (global) or `BarFrom`.
- **Lock write after a lapse read**: `recordReads` treats an accepted scoped read as a scoped accept.
  It advances the entry only if `e.Accepted == bases[path]`, and `scopeBases` (`read.go:522-538`) builds
  `bases` from `r.Since` (`PageResult.Since`). A per-page lapse read with no global `Since` and no
  `BarFrom` has an empty `Since`. Today it would hit `scopedRefusal` and leave the entry unwritten,
  so it needs a new path in `recordReads`/`scopeBases`.
- `drafter page`: in `runPageBlueprints` (`cmd/drafter/pagebp.go:23-108`), after `scopeFromLock`
  (:56, which reads `committedLock` at head) and before `checkStockTracks`/`key.Resolve`/`pipeline.Run`
  (:71-87). Inside `scopeFromLock`, the lapse test must come before the `upToDate` skip (:89-92) and
  the `skipRead` decision (:93).
- **Naming the changed fact ids** on refusal: the lock holds a hash only, so the old bullets must come
  from git. That means finding the commit that wrote the accept (no helper exists; `LockIntroducedAt`
  ignores `Accepted`), or storing per-fact hashes.

**Touches**: `read.go` (`runRead`, `readBars`, `scopeBases`), `bar.go` (`recordReads`,
`scopedRefusal`), `draftscope.go` (`scopeFromLock`), `pagebp.go` (`runPageBlueprints`), `since.go`
(the hash and changed-id computation), and possibly `pipeline.Options` for a per-page base.

## 4. The read seats

**Stage 1 for a blueprint** (`internal/pipeline/blueprint.go`):

- `doBlueprintCheck` (:101-123) escalates on check errors. If `Draft && SkipRead` it goes to `toDraft`; otherwise `Step = stBpRead`.
- `stageBlueprintRead` (:127-170) loops `p.pending(p.stepSeats())` and switches on the seat:
  - `case "consistency"` (:136-144): `assemble.ConsistencyPrompt(in.view, p.r.facts, p.r.root)` → `p.build(ctx, s1, seat, assemble.AnswerConsistency, prompt, nil, nil)`.
  - `default` (the blueprint seat, :145-165): `c := p.context(prompts.Round1)`; `extra := assemble.BlueprintBlock(in.raw, in.entryJSON)`. On a change read (`changeRead()`, :61-64: read scope scoped and `Facts != nil`), `c.Scope` is `"page"` or the joined ids, `c.Findings = p.w.Bar`, and `extra += scopeSentence + p.w.readChange()`. Then `p.render(seat, c)` (the prompts module) → `p.buildInput(ctx, s1, seat, assemble.Input{Answer: assemble.AnswerBlueprint, Prompt, Cached: []string{assemble.FactsBlock(in.view, p.r.facts)}, Extra: extra})`.
- `stepSeats` (`internal/pipeline/handle.go:44-81`), `case stBpRead`: `if p.runs("consistency") { return []string{"consistency", "blueprint"} }; return []string{"blueprint"}` (:46-50).
- `runs` (`page.go:156-161`) is false for consistency with no `facts.dir`, else `slices.Contains(cfg.Seats, seat)`. The blueprint seat is not in `cfg.Seats`; it is always run by the default branch.

**Sending**: `submit` (`internal/pipeline/money.go:59-73`) sends one batch in batch mode
(`submitUnit` with every request; the ledger reserve row's seat is `"consistency+blueprint"`, :107)
and **one request at a time, in order**, in sync mode. `send` (:320) handles the sync calls.

**Parsing**: `validate` (`handle.go:194-236`), `case stBpRead`, decodes a consistency answer strictly,
and any other seat goes through `parseRead`. `decodeAnswer` (`steps.go:513-523`) uses
`DisallowUnknownFields`. `parseRead` (`steps.go:501-510`) requires verdict `ok` or `fix`.

**Completing**: `completeBlueprintRead` (`blueprint.go:227-292`):

- Parses the blueprint answer, records the verdict and friction, and turns findings into `edits.Finding`
  (`readAnswer.findings`, `steps.go:525-532`), which go to `Rec.findings(s1, fs)`.
- `p.w.WholeBlocked = a.Verdict == "fix" && !p.changeRead()` (:238).
- Consistency conflicts:
  - On a change read, `untouched` (:193-217) demotes a conflict to an `Already present:` warning, and a conflict with no fact and no page becomes `Unplaced:`.
  - Otherwise `escalate("plan", "consistency", nil, joined)`. A consistency conflict becomes an **escalation detail string, not findings**.
- A blueprint `fix` → `escalate("plan", "blueprint", ns, ...)`.
- Otherwise `p.w.Accepted = rev-parse head:<blueprint>`, then `toDraft` or `accept`.

**Into the summary and the lock**:

- `summary` (`pipeline.go:257-278`) sets `res.Findings = p.w.Rec.blueprintFindings()`.
  `blueprintFindings` (`record.go:131-139`) keeps only findings with **`f.Seat == "blueprint"`**, and
  `alreadyPresent` (:120-128) has the same filter.
- `FindingResult` (`pipeline.go:141-145`) is `{Location, Text, Blocking}`, **with no kind and no seat**.
- `barOf` (`bar.go:145-156`) builds the bar from `r.Findings`, so a finding from another seat never reaches a bar unless `blueprintFindings` is widened.
- `PageResult` (`pipeline.go:104-138`) statuses: `accepted`, `escalated`, `held` (`bar.go:21`), and
  `unchanged` (`read.go:28`). It also carries `rule`, `detail`, `warnings`, `whole_blocked`, `bar_from`,
  `read_scope`, `since`, and `accepted`.
- `findingRecord` in `record.json` (`record.go:68-76`) has `Kind string json:"kind,omitempty"`.

**Answers and schemas** (`internal/assemble/schema.go`, `assemble.go:23-33`). The answers are
`AnswerDraft`, `AnswerEdits`, `AnswerRead`, `AnswerReader1`, `AnswerReader2`, `AnswerCoverage`,
`AnswerConsistency`, and `AnswerBlueprint` ("a read whose findings carry no kind").

- `answerSchema` (:15-33) is the switch.
- `AnswerBlueprint` → `readSchema(false)`, with the contract "Answer with a verdict, each finding with its location, the finding, a rewrite, and whether it blocks, a summary, and any friction you met in friction." (:22).
- `AnswerConsistency` → `consistencySchema()` (:132-141: `conflicts[{facts[], with, conflict}]`), with the contract "Answer with each conflict you find, or an empty list." (:30).
- `AnswerRead` → `readSchema(true)` plus `reviewContract` (:88-99).
- `readSchema(withKind)` (:103-122). The comment reads: "The blueprint read's findings carry no kind, so its request bytes stay as they were before kinds existed."

**Kind**: `kinds` (:84) is `{"link","handoff","heading","citation","fact","claim","code","voice","step","placement","other"}`.
It appears only in the review seats' schema (`withKind`). `fact` is defined as "a fact the page states
wrongly or leaves out" (:93). `smallKinds` (`pipeline/small.go:11`) is `{"link","handoff","heading","citation"}`.
The kind flows from the answer through `readAnswer.Findings[].Kind` (`steps.go:495`), then
`edits.Finding.Kind`, then `findingRecord.Kind`. It never reaches `FindingResult` or `BlockedFinding`.

**Blocks per request** (`assemble.Build`, `assemble.go:72-122`):

- **Blueprint seat**, in order:
  1. The `note` (:65).
  2. The rendered prompt.
  3. `inputBlocks`: `fileBlocks` for repo paths the prompt names, and `commandBlocks` for `seat.blueprint.inputs`. **No excerpts**, because the Input has no `Facts`/`FactIDs`, so the excerpt branch at `assemble.go:164-170` is skipped.
  4. All of that joined becomes cached part 1. `FactsBlock` is cached part 2 (`=== facts placed or cited ===`, `- id [tag]: text`, with **no pointers**; `assemble/blueprint.go:17-49`).
  5. Uncached: `Extra`, which is `BlueprintBlock` (`=== blueprint ===`… `=== outline entry ===`, :54-57) plus the scope sentence and change block on a change read.
  6. The contract.
- **Consistency seat**: no note (:88), then `ConsistencyPrompt` (`consistency.go:21-58`: placed facts as `- id: text` with no tag and no pointers, then linked pages with their headings). `inputBlocks` returns nil for `AnswerConsistency` (:127-128). Then the contract.
- **The analogue for a fact-truth seat's excerpts** is the drafting path: `p.build` sets
  `Facts: p.r.facts, FactIDs: p.h.Inputs.FactIDs` (`steps.go:110-112`), and `inputBlocks` then calls
  `r.excerptBlocks(in.Facts, in.FactIDs)` (`assemble.go:164-170`). The draft, structure, editor,
  fact, and coherence seats get excerpts this way.

**What a third `facttruth` seat touches**:

- **Config**:
  - `internal/config/check.go:16` `seatNames` (nine names). `defaultSeats = seatNames[:7]` (:19) is positional, so a new name goes after index 6.
  - `internal/config/stock.toml` gets a `[seat.facttruth]` table.
  - `validate.go:46-51` validates `c.Seats` only, so read must call `c.ValidateSeat("facttruth")` as `read.go:108` does for blueprint.
  - `docs/configuration.md:313-329` names "The nine seats".
  - `internal/config/stock_test.go:60` and `validate_test.go:15` loop over `seatNames`.
- **Pipeline**:
  - `stepSeats` `case stBpRead` (`handle.go:46-50`).
  - `stageBlueprintRead`'s seat switch (`blueprint.go:135`).
  - `validate` `case stBpRead` (`handle.go:196-202`), which today parses anything that is not consistency as a read.
  - `isRead` (`handle.go:109-111`).
  - `completeBlueprintRead` (`blueprint.go:227-292`).
  - `blueprintFindings`/`alreadyPresent` (`record.go:120-139`).
  - `missingSeats` (`page.go:169-194`), only if the module renders the seat.
  - `seatsNotRun` list (`page.go:134`).
  - `runs` (`page.go:156-161`).
- **Draft gating**: `drafter page` also passes through `stBpRead` when its read isn't skipped. The design keeps fact-truth out of `drafter page`, so `stepSeats` must gate on `!p.w.Draft`.
- **Assemble**: a new `Answer` constant, a case in `answerSchema`, and an `inputBlocks` case (`assemble.go:126-129`, `:141-146`).
- **Module**: if the module renders the prompt (the design names `stock/prompts.js` and the chain module), then:
  - The `return {...}` seat map (`stock/prompts.js:652-664`).
  - `DRAFTER_SEATS` in the chain (`claude/.claude/workflows/docs-page-chain.js:2966-2986`). cairn runs on this module (`~/.config/drafter/cairn-cms.local.toml`: `prompts = "~/.claude/workflows/docs-page-chain.js"`).
  - `tests/docs-page-chain-blueprint.test.mjs:268-276` (`SEVEN` seats).
  - `stock/stock_test.go:64` (`want := []string{"blueprint", "coherence", "draft", "editor", "fact", "reader", "structure"}`).
  - The consistency seat is the precedent for **not** rendering: Go builds its prompt.
- **Goldens**:
  - `internal/pipeline/testdata/blueprint-read-request.golden.json` pins only the blueprint request (`requestsFor(h, "s1", "blueprint")`; `readgolden_test.go:16-43`, `draftpath_test.go:270-291`). It is unchanged unless the blueprint request's bytes change.
  - `cmd/drafter/testdata/read-dryrun-count.golden.json` **breaks**: `TestReadDryRunRequestGolden` (`cmd/drafter/clifixture_test.go:134-170`) asserts `len(f.stub.counts) != 2` (:150) and concatenates every count body (:153-156).
  - `internal/pipeline/testdata/record.golden.json` (`flow2_test.go:601`) is a drafting run, unaffected if gated.
  - The e2e read dry-run project module defines only `draft` and `blueprint` (`e2e/blueprint_test.go:149`), so a module-rendered seat that is always required fails there.
- **check-prompts**: `cmd/drafter/checkprompts.go` checks containment per seat (:236-270, a blueprint-seat exception at :243). `tests/fixtures/drafter/blueprint-matrix.json` has 24 cases (draft 6, editor 4, fact 4, blueprint 3, structure 3, reader 2, coherence 2). Parity runs through `tests/drafter-prompts-parity.sh:18`.
- **Smoke**: `internal/smoke/shapes.go:37-51` `seatAnswers` (nine rows), and `smoke_test.go:480` ("nine distinct custom ids").
- **custom_id**: `seatOf` (`money.go:29-35`) takes `strings.Split(customID, "_")[3]`, so a seat name must hold no `_`. `facttruth` is fine.
- **Money**: `money.go` is seat-agnostic. Each request reserves its worst case from the seat's `max_tokens` (:97), and `modelOf` reads `cfg.Seat[seat]` (:372).

## 5. Excerpts

`internal/assemble/excerpt.go`:

- **Windows** (:17-21): `path:N` takes 10 lines before and 10 after (21 lines). `path:A-B` takes 5 before and 5 after. `path#name` takes 5 before and 40 after, from the declaration line: `window(label, lines, at+1-declBefore, at+1+declAfter)` (:93), 46 lines. A bare `path` inlines the whole file through `fileBlock` (`files.go:222-237`). Over `sizeLimit = 256 << 10` (`files.go:19`) the result is a `file` block reading `not inlined: N bytes`.
- **Lists**: a line list `path:1,5-7` gives one block per range (:96-106). `window` clamps to the file, and only `lo > hi` after clamping gives a "range beyond" result (:111-117).
- **Labels**: `source + " (fact " + id + ")"`, with `" lines lo-hi"` added for a window.
- **Entry point**: `excerptBlocks(facts, ids)` (:29-41) is a method on the unexported `*repo`. It returns an error when an id is not held by exactly one bullet, and it walks only `f.Sources`.
- **Every `no excerpt:` form**:
  - `missing` (:57, :64, :82)
  - `untracked` (:59 outside the root; :68 not in `git ls-files`)
  - `directory` (:66)
  - `prose` (:70, `.md .mdx .markdown .txt .rst .adoc`)
  - `not a regular file` (:76)
  - `declaration not found` (:91)
  - `range beyond the end of the file` (:114)
- **The dotted-anchor failure**: lines 86-92 are

  ```go
  name := suffix[1:]
  name = name[strings.LastIndex(name, ".")+1:]
  at := declaration(lines, filepath.Ext(rel), name)
  ```

  So `outer.inner` searches for `inner` at file scope.
- **`declaration`** (:125-160) has column-0 patterns only.
  - Go: `^func\s+(\([^)]*\)\s*)?name\b`, `^type`, `^(var|const)`, and a tab-indented member of a grouped block.
  - TS/JS/Svelte (`tsExt`, :25): `^(export\s+(default\s+)?)?(declare\s+)?(abstract\s+)?(async\s+)?(function\s*\*?|class|interface|type|enum|const|let)\s+name\b` (:136-137).
  - It has no indented fallback, so a nested member fails. Any other extension (`.json`, `.toml`, `.yaml`, `.css`) has no patterns and always gives `declaration not found` for `#name`.
- **No silent-drop note**: a slashless pointer that does not exist at the root never reaches `Sources` (`isSource`, `facts.go:333-337`), so it yields **no block at all**, not even a `no excerpt:` line.
- **Reading**: excerpts read the working-tree file (`os.ReadFile(real)`), with tracked status from `git ls-files` (`files.go:30-…`).

`internal/plan/verify.go` (`drafter check`'s `store` check, `checkStore = "store"`, :26):

- `VerifyFacts(dir, root, ids)` (:106-209) walks `sourcePointers(b.rest)` itself (:228-272), not `Fact.Sources`, and keeps the anchor in parentheses (:264-267).
- A **bare** path that is missing is a warning (:331-336).
- `path:lines` checks existence, uses a basename fallback for a slashless path (:340-355), checks range and direction, and checks anchor words within ±10 lines (:370-386).
- `path#name` uses `declarationSpan` (:504-566). It differs from the assembler's: TS adds `var|namespace|module` and **an indented `const|let|var|function` fallback** (:524). The comment at :502-503 says "This is the assembler's rule extended; the assembler's own copy stays in internal/assemble."
- **A dotted name is skipped, not checked**: `!identifierRe.MatchString(p.name)` → `skipped++` (:192-196). A non-Go/TS extension is skipped too.
- `drafter check` runs the store check only when no blueprint is named (`cmd/drafter/check.go:106-113`, which prints `facts store: N pointers checked, M skipped`). `drafter gate` runs it over `Cited` ids (`gate.go:139-150`).
- So today a pointer can pass `drafter check` and still give `no excerpt` in a request. The cases are an indented TS declaration, a dotted name (skipped), a basename-resolved pointer (dropped from `Sources`), and a prose file (verify passes it; the excerpt refuses it).

**Warning mechanism**: a finding is `plan.Finding{File, Line, Severity, Check, Message, Fix}`, with
`SeverityWarning = "warning"` (`plan/plan.go:110-113`). `projectCheck.add(file, line, severity, check, msg, fix)`
(`blueprint/check.go:83-85`) records one. The model is the `handler` warning (`check.go:181-222`, `checkHandler`, :217-219):

```go
c.add(file, cmp.Or(it.Lines["handledBy"], it.Line), plan.SeverityWarning, checkHandler, fmt.Sprintf(...), "make the handler a step, ...")
```

**No `cited` warning or check exists.** The only "cited" text is the facts error "cannot be cited"
(`plan/check.go:444`). `runCheck` prints `file:line: severity: check: message (fix)`
(`cmd/drafter/check.go:122`) and exits 1 only on errors (:128-135).

**Import constraint**: `assemble` imports `plan`, so `plan` cannot import `assemble`. `blueprint` does
not import `assemble`, and `assemble` does not import `blueprint`, so `blueprint` → `assemble` is
legal. The excerpt logic is unexported and needs `*config.Config` and `git ls-files` (`openRepo`, `files.go:30`).

**Commands**: no `cmd/drafter/excerpt.go` exists. Commands are cobra and register in `newRootCmd`
(`cmd/drafter/root.go:5-15`):
`cmd.AddCommand(newCheckPlanCmd(), newAnchorsCmd(), newConfigCmd(), newSpendCmd(), newCheckPromptsCmd(), newPageCmd(), newCheckCmd(), newRefsCmd(), newConvertCmd(), newReadCmd(), newSeedCmd(), newGateCmd(), newInitCmd())`.
The nearest model is `newRefsCmd` (`cmd/drafter/refs.go:13-35`): one fact-id argument, `--root` and
`--json`, `projectFor` for the project, and exit 0, 1, or 2.

**Touches**: `excerpt.go` (dotted resolution, plus an exported entry for the command and the check),
the `declaration` versus `declarationSpan` divergence, a new `cmd/drafter/excerpt.go` and its root
registration, and a `no-excerpt` check in `blueprint/check.go` or `cmd/drafter/check.go`. The check
sits in `blueprint` or `cmd` because of the import rule. `blueprint-format.md` §"What `drafter check` checks" (:363-410).

## 6. Sync and batch

**Flags on `drafter read`** (`cmd/drafter/read.go:30-33`, `:83-87`):

- `--resume` (string)
- `--since` (string)
- `--dry-run`
- `--sync` ("send ordinary Messages calls instead of a batch")
- `--json`

There is no `--batch`. The rule: `if f.since != "" && f.resume != ""` → usage error "--since and
--resume cannot be used together; the run recorded its scope" (:76-78).

**Choosing the mode**:

- `config.Load(root, config.Flags{Sync: f.sync, JSON: f.json})` (:101). `config.Flags` is `{Sync bool; JSON bool}` (`internal/config/config.go:111-115`), and `flagLayer` (`load.go:143-154`) sets `mode = "sync"` only when `Sync` is true.
- The key is `mode`, `batch` or `sync` (`check.go:30`). The default is `Mode: "batch"` (`apply.go:22`), and the environment variable is `DRAFTER_MODE` (`env.go:43`).
- The flag layer outranks user, project, local, and environment, so a read-only default that `--batch` overrides would also override `DRAFTER_MODE=batch` and a configured `mode = "batch"`.
- `drafter page` shares `config.Flags` (`pagebp.go:29`; `page.go:57` has its own `--sync`).
- `batchMode()` is `r.cfg.Mode != "sync"` (`money.go:56`). It also sets the price: a dry run's worst case uses `ledger.Worst(..., r.batchMode())` (:97), so under a sync default `read --dry-run` estimates double.

**Resume**:

- `ResumeCommand(command, sync, runID, args)` (`internal/pipeline/pipeline.go:288-299`) writes ` --sync` only when sync. It is used at `pipeline.go:282` and `read.go:164`/`:179`.
- `fingerprint` includes `mode` (`fingerprint.go:18`), so a resume in a different mode refuses ("the configuration changed since the run started (mode)").
- Under a sync default, a batch read's resume line must carry `--batch`.

**Docs**:

- `docs/configuration.md:46`: "Only two settings have flags. `--sync` sets `mode` to `sync`, and `--json` sets `output` to `json`."
- `:209`: the `mode | all | batch | DRAFTER_MODE` row.
- `:215-217`: "`mode` is `batch` or `sync`. In `batch` mode drafter sends each stage as a Message Batch ... The flag is `--sync`."
- `README.md:100` (`drafter read [--resume <run-id>] [--dry-run] [--sync] [--json] <blueprint>...`) and `:103` ("one batch").
- `blueprint-format.md:543-545` ("sends one batch holding the consistency read ... and the blueprint read").
- The `read.go` Long text at :40-41 ("one batch").
- The skill, `claude/.claude/skills/blueprint/SKILL.md:41`, `:51` (`drafter read --sync ...`).

**Tests that pin `--sync` or the resume line**:

- `cmd/drafter/page_test.go:114-135` (`TestStoppedSyncReadPrintsAResumeCommandDrafterAccepts` asserts `fields[2] != "--sync"`).
- `internal/pipeline/summary_test.go:97` (`"drafter read --sync --resume ..."`) and `:102-121` (`TestResumeCommand` rows: `"drafter read --resume r1 ..."` for sync=false).
- These add `--sync` explicitly, so they keep passing: `cmd/drafter/clifixture_test.go:119`, `cmd/drafter/read_test.go:521`, `e2e/readbar_test.go:52,258,271`.
- `e2e/e2e_test.go:492-499` covers mode precedence.

**Touches**: `read.go` (the flag and the Flags passed), `config.Flags`/`flagLayer` (or a read-only
override), `ResumeCommand` (it emits only `--sync`), the docs lines above, `README.md`, `SKILL.md`, and the tests above.

## 7. Covers

**Decode**: `DecodeOutline` (`internal/blueprint/decode.go:138-145`) → `plan.DecodeDocument`
(`internal/plan/decode.go:86-125`). This is a reflect walk over `yaml.Node`, and it is **strict**:

- An unknown key is a finding: `unknown field %q` (:180-188).
- Required fields come from the `plan:"required"` tags (:192-196).
- `value` (:208-235) handles only `String`, `Int`, `Bool`, `Struct`, and `Slice`.
- A list element is decoded by the element kind (`list`, :256-269).

So `Page.Covers []string yaml:"covers" plan:"prose"` (`blueprint.go:160`) accepts **strings only**. A
mapping element is reported "must be a string" (`str`, :237-254). There is no `yaml.Unmarshaler` or
union path, so a string-or-`{id, text}` element needs decoder support or a new element type.
`validateOutline` (`decode.go:147-199`) has no covers rule.

**Sections**: `Section` (`blueprint.go:64-76`) has no `covers` field. Decode of an extra key
would be an error.

**Dispositions**: `Blueprint.Dispositions []plan.Disposition` (:29). `plan.Disposition`
(`internal/plan/plan.go:99-107`) is `Fact string yaml:"fact" plan:"required"`,
`Disposition string plan:"required"`, `Reference string`, and `Reason string plan:"required,prose"`.
`validateBlueprint` (`decode.go:89-101`) allows `cut` or `subordinated`, and `subordinated` needs a
`reference`. **`fact` is required, and the type is shared with the plan format**: a disposition that
names only a covers id needs `fact` made optional or a blueprint-own type.

**Schema lockstep**: `TestSchemasMatchGoTypes` (`internal/blueprint/schema_test.go:84-…`) requires
`schema/blueprint.schema.json` and `schema/outline.schema.json` to list the same fields and required
sets as the Go types. That covers `section`, `disposition` (as `plan.Disposition`), and `page`.
`TestReferenceNamesEverySchemaField` (`docs_test.go:28-53`) requires `docs/blueprint-format.md` to
name every schema field in a code span.

**`drafter check`'s checks** (constant names):

- From `plan` (`plan/check.go:15-19`): `ids`, `reader-state`, `recovery`, `links`, `facts`.
- `decode` (`plan/decode.go:20`).
- `store` (`plan/verify.go:26`).
- From `blueprint` (`blueprint/check.go:20-28`): `blueprints`, `refs`, `why`, `use`, `handler`, `types`, `lock`, `convention`, `framing`.
- `tracks` (`blueprint/tracks.go:18`).

The per-blueprint order is `blueprintData` (`check.go:117-145`): decode, `plan.Check`, `references`,
`sections`, `framing`, `handlers`, `pageType`. Then the project runs `outlineChecks`, `pairing`,
`convention`, and `lockEntries` (:62-73). There is no `covers` check.

**Where covers flows into requests** (all as `[]string`):

1. `entryJSON` (`cmd/drafter/read.go:474-490`): `"covers": nonNil(p.Covers)`, put in
   `Handoff.Context` as `{"resolved":{"pages":[entry]}}` (:449). From there `page.pageJSON()`
   (`steps.go:52-71`) carries it to `prompts.Context.Page` and the module. The stock blueprint seat
   looks it up through `PAGES.find(...)` (`stock/prompts.js:653-657`), and the prompt text names
   `covers` at `stock/prompts.js:109`, `:115`, and `:480`.
2. `pipeline.EntryJSON` (`internal/pipeline/blueprint.go:40-57`): `outlineEntry.Covers []string json:"covers,omitempty"` goes into `BlueprintBlock`'s `=== outline entry ===` and into `ChangeBlock`'s `=== outline entry change ===`.
3. `Compare` compares the entry with `sameYAML` (`since.go:83`).

Outside Go:

- The chain module's page-inputs schema `covers: {type: "array", items: {type: "string"}}` (`docs-page-chain.js:536`, required at :544), `covers: list(e.covers)` (:715), and the inventory text `covers.map((c) => \`- ${c}\`)` (:1086-1093).
- `bin/.local/bin/cairn-docs-outline:60` `covers: list(e.covers)`.

**`docs/blueprint-format.md` sections**:

| Lines | Section |
|---|---|
| :63 | `## Top-level fields`. The `dispositions` row is at :75; :85-89 describe the introduction's `covers` (a different, prose field) and dispositions. |
| :123 | `### sections` |
| :200 | `## outline.yaml`. The pages table is :255-267 (`covers` row :264: "What the page covers."). |
| :273-361 | `## drafted.lock`. The fields table is :293-299, the hash rules :301-310, and `blocked` :315-342. |
| :363-410 | `## What \`drafter check\` checks`, with the check table at :383-401. |
| :412 | `### Find where a fact is used` |
| :541 | `## What \`drafter read\` does with a blueprint` |
| :585 | `### The read bar` |
| :613 | `## What \`drafter page\` does with a blueprint` |

`claude/.claude/skills/blueprint/format.md` is a symlink to this file.

**Touches**: `blueprint.go` (`Page.Covers` type, `Section` field), `plan/decode.go` (a union element),
`plan.Disposition` (or a blueprint-own type), both schemas, `blueprint/check.go` (a new `covers`
constant and check), `EntryJSON`/`entryJSON`, the chain module, `cairn-docs-outline`, and the format doc.

## 8. Untouchables

**`fingerprint.go`** (`internal/pipeline/fingerprint.go:16-45`) hashes:

```go
f := map[string]string{
	"mode": c.Mode, "seats": strings.Join(c.Seats, ","),
	"retries.gate_fix": ..., "retries.edit_contract": ..., "gate.command": ..., "gate.index_link": ...,
	"gate.protocol": ..., "gate.lane": ..., "gate.section_pattern": ..., "gate.failure_pattern": ...,
	"facts.dir": c.Facts.Dir, "facts.bullet_format": ..., "inline_files": ...,
}
f["prices"] = string(prices)
for name, s := range c.Seat {
	k := "seat." + name + "."
	f[k+"model"], f[k+"effort"] = s.Model, s.Effort
	f[k+"max_tokens"] = ...; f[k+"inputs"] = ...; f[k+"agent"] = strconv.FormatBool(s.Agent != "")
}
```

`checkConfig` (`resume.go:195-217`) refuses when `changedSettings(was, fingerprint(now))` is non-empty.
`changedSettings` (`fingerprint.go:48-62`) counts a key present now and absent then.

- **A new seat changes a run's fingerprint without any edit to `fingerprint.go`.** A `[seat.facttruth]` in `stock.toml` adds `seat.facttruth.*` keys. Every stopped run started on the old binary then refuses to resume. Backlog #22 records the same thing for `coherence` and says "Fixing it edits `fingerprint.go`, which needs the auth-data bar".
- **The sync default changes `mode`** for a read started without a flag. That matters only across a resume.
- **The lock's `facts` field is not in the fingerprint.**

**`money.go`**: no seat-specific code. `seatOf` parses the custom_id (:29-35), and `modelOf` reads
`cfg.Seat` (:372). Each request reserves its own worst case. A third seat needs no edit here.
`submit` already sends sync requests one by one (:59-73).

**`resume.go`**: no seat-specific logic. `useCopies` copies `cfg.Seat` and the per-seat agent
copies (:114-150), and `checkConfig` uses the fingerprint. A third seat needs no edit here.

None of (1)–(7) requires editing these three files. Through `fingerprint`'s data, (1) and (5) change
behavior on resume.

## 9. Tests and the gate

**`make check`** (`Makefile`) runs `check: vet lint test chain-test prompts-parity install-test hook-test`:

| Target | What it runs |
|---|---|
| `vet` | `go vet ./...`, plus `-tags smoke` and `-tags live` |
| `lint` | `golangci-lint run ./...` |
| `test` | `go test ./...` |
| `chain-test` | Builds, then runs four `node tests/docs-page-chain-*.test.mjs`. The last one runs with `DRAFTER_BIN=./drafter`. |
| `prompts-parity` | `bash tests/drafter-prompts-parity.sh` over `tests/fixtures/drafter/matrix.json` (51 cases) and `blueprint-matrix.json` (24 cases) |
| `install-test` | `tests/install.test.sh` |
| `hook-test` | `tests/page-hook.test.sh` |

`smoke` and `live` spend money and stay out of `check`.

**Timing**: the main checkout was clean and no other process held it, so `make check` ran once. It
passed (rc=0) in **25 s wall**. 11 of 22 Go packages were cached. Uncached:
`internal/pipeline` 12.0 s, `cmd/drafter` 6.1 s, `e2e` 5.0 s, and the rest under 1 s.

**Pipeline harness**:

- `newHarness(t, opts...)` (`internal/pipeline/harness_test.go:139-198`) copies `testdata/project`, runs `git init`, and uses the module `testdata/module.js`.
- Its config has `Mode: "batch"` and `Seats` = the default seven, seats `model-a` at 4000 tokens, a facts dir `docs/facts`, and `api: newFakeAPI(t)` (`fake_test.go`).
- Options: `withoutFacts`, `withMode`, `withSeats`, `withPages`, `withMaxTokens`, and others (:55-100).
- `newBlueprintHarness` (`blueprint_test.go:24-35`) adds `Blueprints` and copies the structure seat as `Seat["blueprint"]`.
- `requestsFor(h, stage, seat)` (`flow_test.go:24`).

Blueprint-read suites: `blueprint_test.go`, `blueprint_change_test.go`, `readbar_test.go`, `readgolden_test.go`, `draftpath_test.go`.

**CLI and e2e for `drafter read`**:

- `cmd/drafter/read_test.go` (`newReadCmd` with `--sync`, :516-521).
- `cmd/drafter/bar_test.go`.
- `cmd/drafter/clifixture_test.go` (a stub server, `TestReadDryRunRequestGolden`).
- `cmd/drafter/page_test.go:114` (`newSinceProject`).
- `e2e/readbar_test.go` (sync, JSON, bar and scoped-accept flows).
- `e2e/blueprint_test.go:136-160` (the read dry run and a missing seat).
- `e2e/setup_test.go:248-271` (the dry run and the `require_prompts` refusal).

**Gate script**: `scripts/drafter-gate.sh` runs `cairn-run-gate --fresh "make -C '$dir' check"` with
`CAIRN_GATE_LANE=light` and `DRAFTER_DIR` defaulting to the checkout. It repeats the `gate exit:`
line, and an exit of 75 means re-issue.

## 10. Costs (cairn-cms, from `~/.local/state/drafter/ledger.jsonl`, read-only)

**Method**: I took ledger `settle` rows with repo `cairn-cms` and seat `blueprint` or `consistency`
(302 rows, 2026-10-17T23:45Z to 2026-10-20T06:52Z). Each row was joined to its run's `state.json`
`work` for that page to classify the read:

- `bar`: `bar_from` set.
- `change`: `read_scope` or `scope` has `kind` `scoped`.
- `whole`: anything else.

The ledger itself does not record whole versus change. The batch `bar` rows for seven blueprints came
from `drafter page` bar reads. Costs are US dollars per request.

**Per blueprint**: median cost (n). Sync costs about 2× batch, since batch takes the 0.5 discount.
In the change column, "s" marks sync and "b" marks batch.

| Blueprint | blueprint sync whole | blueprint sync change | blueprint batch whole or bar | consistency sync whole | consistency sync change | consistency batch | Sync whole tokens in/out (blueprint; consistency) |
|---|---|---|---|---|---|---|---|
| add-a-second-sign-in-group | 0.429 (1) | 0.293 (2) | bar 0.260 (2) | 0.055 (1) | 0.057 (2) | 0.027 (2) | 35107/11881; 12251/310 |
| add-cairn-to-a-sveltekit-app | 0.465 (1) | 0.365 (3) | bar 0.267 (1) | 0.083 (1) | 0.085 (3) | 0.040 (1) | 43751/10843; 18403/472 |
| debug-your-site | 0.256 (1) | 0.239 (4) | bar 0.182 (2) | 0.038 (1) | 0.039 (4) | 0.018 (2) | 19852/7247; 7418/416 |
| restrict-admin-access | 0.308 (1) | 0.256 (2) | bar 0.237 (3) | 0.057 (1) | 0.055 (2) | 0.027 (3) | 20032/9017; 11783/476 |
| rotate-the-github-app-key | 0.437 (8; range 0.258–0.513) | 0.171 s (85); bar s 0.203 (9) | whole 0.206 (8) | 0.026 (8) | 0.026 (85) | 0.013 (8) | 22693/7785; 6800/320 |
| scaffolded-site-files | 0.296 (1) | 0.349 (3) | bar 0.223 (2) | 0.073 (1) | 0.080 (3) | 0.036 (2) | 28194/5824; 16189/395 |
| security-model | 0.321 (1) | 0.263 (2) | bar 0.224 (1) | 0.077 (1) | 0.077 (2) | 0.037 (1) | 25900/7097; 16567/524 |
| using-claude-code-with-cairn | 0.200 (1) | 0.337 (4) | bar 0.182 (3) | 0.018 (1) | 0.020 (4) | 0.009 (3) | 13119/6395; 4438/12 |

**Totals by class**:

| Class | n | Median | Sum |
|---|---|---|---|
| Blueprint sync whole | 15 | 0.321 | 5.40 |
| Blueprint sync change | 105 | 0.253 | 24.11 |
| Blueprint sync bar | 9 | 0.203 | 2.50 |
| Blueprint batch whole | 8 | 0.206 | 1.69 |
| Blueprint batch bar | 14 | 0.222 | 3.07 |
| Consistency sync whole | 15 | 0.029 | 0.62 |
| Consistency sync change | 105 | 0.026 | 3.48 |
| Consistency sync bar | 9 | 0.033 | 0.29 |
| Consistency batch whole | 8 | 0.013 | 0.10 |
| Consistency batch bar | 14 | 0.027 | 0.35 |

**One sync whole read of all eight**, using each blueprint's latest sync whole costs: blueprint seat
about $2.71, consistency about $0.43, so **about $3.14 before any fact-truth seat**. A change read runs
about $0.15–0.37 for the blueprint seat and $0.02–0.09 for consistency, per blueprint.

**No data exists for a fact-truth request.** The nearest analogue that carries excerpts is the
draft-stage `fact` seat on cairn pages: $0.29–0.71 a request in batch (in about 97k–270k tokens,
which includes the page and inlined files), and $0.52–0.56 in sync. That is an upper bound, since a
fact-truth request carries no page.

**`drafter spend --json`** (window: current billing cycle, from 2026-10-01): **`total` 140.01154829999996**,
**`open` `{count: 1, worst: 0.99695}`**. Of that, cairn-cms `blueprint` is $36.76 over 151 requests and
`consistency` $4.85 over 151.

---

Write-up only. Commands run: `make check` (once, clean checkout), `drafter spend --json`, and read-only
Python over the ledger and run state, scratch in `/tmp/drafter-factsheet/`. No repo file was edited.
