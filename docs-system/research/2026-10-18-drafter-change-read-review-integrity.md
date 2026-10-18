# drafter change-read plan review: data integrity and failure risk

Target: `plans/2026-10-18-drafter-change-read-plan.md` at `cc15fc7` (branch
`docs-system-change-read-plan`). Read against the approved design
(`specs/2026-10-18-drafter-change-read-design.md`), B2's plan, and drafter `main` at `f7d9034`
(`internal/blueprint/since.go`, `internal/pipeline/blueprint.go`, `internal/pipeline/work.go`,
`internal/pipeline/resume.go`, `cmd/drafter/read.go`, `cmd/drafter/page.go`,
`claude/.claude/workflows/docs-page-chain.js`). cairn-cms `origin/main` is still `50dc211d9`
(no commits since), so the pinned base matches B2's.

Lens: crash, concurrency, partial write, upgrade, restore; silent loss or corruption.

## Verdict

No path lets a blueprint reach `drafted.lock` without a whole read: `scopedAccept`
(`cmd/drafter/read.go:274`) keys on `Kind == ScopeScoped`, and `ScopeWhole` now means only that
there is no earlier blueprint, so every newly scoped case still skips the lock. The real risks are
elsewhere. One is a blocker: a scoped page whose change touches no section id renders the
unscoped prompt. Four are majors, where a conflict or a finding is lost or demoted silently.

## Findings, ranked by consequence

### 1. blocker, correctness: a scoped page with no changed section id reads as unscoped

- Location: plan `:43-50` (resolution 1) and `:57-63` (resolution 3), against
  `internal/pipeline/blueprint.go:130-131` and `docs-page-chain.js:2355`.
- Defect: the prompt learns the scope only from `c.Scope = strings.Join(p.w.Scope.IDs, ",")`, and
  the JS adapter passes `c.scope || undefined`. Every case this plan moves from whole to scoped
  (a removed section, an order or level change, a page-level field, an outline-entry change) can
  leave `Scope.IDs` empty. Such a page then gets B2's unscoped prompt, which blocks on everything,
  plus the change block, plus the scoped consistency rule, and no lock. The read is half scoped.
  It contradicts the design's "a page-level change no longer makes the read whole" (design `:38`).
  The golden test (`:105`) still passes, so nothing catches it. `scopeText` (`page.go:193-197`) also
  prints `scoped: ` with nothing after it.
- Fold: key the prompt on `Kind == ScopeScoped`, not on the ids. The new paragraph names the change
  block, not ids, so `c.Scope` can carry a fixed non-empty value for any scoped page, or the ids
  when there are any. Add one acceptance row: a page-level-only change (empty `IDs`) renders the
  scoped prompt and sends the change block. Have `scopeText` print `scoped: page` (or the changed
  field) when `IDs` is empty.

### 2. major, correctness: a resumed B2-era state demotes every consistency conflict

- Location: plan `:48` (`Scope` gains `Facts`) and `:64-67` (resolution 4), against
  `internal/pipeline/work.go:123-127` and `internal/run/state.go:15` (`StateSchema = 2`).
- Defect: `work.Scope` is persisted and read back on `--resume`. A state written by the B2 binary
  has `kind: scoped` and no `facts`. The CR binary decodes `Facts` as nil, so the intersection is
  empty and every conflict becomes an "Already present:" warning. That path accepts the page with
  exit 0, though B2 would have escalated. The schema doesn't change, so the resume isn't refused.
  The same happens to a run directory restored from backup. A B2 state's `whole` pages are safe:
  they escalate on any conflict.
- Fold, with no change to `resume.go` or the schema: tag the field `json:"facts"` without
  `omitempty`, have `Compare` always return a non-nil slice (`[]string{}` when empty), and make
  resolution 4 fail closed when a scoped page's `Facts` is nil (`null` or absent, from a state that
  predates the field), so it escalates on any conflict as a whole read does. Go decodes `[]` to a
  non-nil empty slice, so nil means only "older state". Add a pipeline test row: a scoped state
  with no `facts` key escalates on an untouched-fact conflict.

### 3. major, correctness: non-blocking and "Already present" findings are dropped on accept

- Location: plan `:57-63` and `:64-67`, against `internal/pipeline/blueprint.go:161-164`; design
  `:9-10` ("A defect that was already in the blueprint gets reported").
- Defect: `completeBlueprintRead` writes findings to the record only `if a.Verdict == "fix"`.
  Under the change read, the common case is `ok` carrying "Already present:" findings, and
  `completeBlueprintRead` drops them. They survive only in the raw `responses/*.json` until
  `run.Prune` deletes the run directory. The summary (`page.go:168-184`) prints neither those
  findings nor the demoted-conflict warnings, so the agent that ran the read sees only
  `accepted [scoped: ...]`. The design's "reported" holds only in the raw response, and CR.3's
  table reads the raw responses, so the format test won't expose the gap.
- Fold: record `fs` regardless of verdict (one line). Add a count to the summary line, such as
  `accepted [scoped: x] (2 already present, 1 warning)`, and the warnings and findings to
  `--json`. Add both to CR.1's acceptance: an `ok` read with an "Already present:" finding leaves
  that finding in the record.

### 4. major, correctness: the touched-fact set and the conflict match fail open

- Location: plan `:48-50` (the `Scope.Facts` definition) and `:64-67` (the intersection rule).
- Defect: the demotion trusts the model's `facts` and `with` fields and a set that misses some
  causes. Five ways it fails open:
  - A conflict whose `facts` is empty, or holds an id the store doesn't hold (a typo or an
    invented id), never intersects, so it is demoted.
  - A conflict with a linked page (`with` is a page path, which `ConsistencyPrompt` invites at
    `internal/assemble/consistency.go:23`) is demoted even when the change added the link.
  - "An item that ... differs" is ambiguous on the old side. An item edited from fact A to fact B
    should put both A and B in the set. A removed item or section un-places its facts, and the plan
    counts only items present at head.
- Fold: define `Scope.Facts` as the union over the old and new versions of every changed, new, or
  removed item and page-level field, plus every changed bullet. Demote a conflict only when every
  id in `facts`, and `with` when it is a fact id, is a known fact id outside `Scope.Facts`. A
  conflict with an empty `facts`, an unknown id, or a page in `with` escalates. This keeps B2's
  recurring older conflict demotable if it was fact against fact. If that conflict was against a
  page, it keeps blocking. The executor should check which kind it was in #47's
  `responses/*.json` before choosing. Add the unknown-id and page-`with` rows to CR.1's test.

### 5. major, correctness: the CR.3 protocol deletes the installed skill

- Location: plan `:123-124` ("the skill exposed for the test only, as B2's was, then removed") and
  B2 plan `:143-145`, `:266-267`.
- Defect: in B2 there was no skill before the test, so removing the link was a clean-up. Now
  `~/.claude/skills/blueprint` is the production install (it links to
  `~/Projects/drafter/claude/.claude/skills/blueprint`, from `make install`). B2's `ln -sfn
  <drafter wt>/...` overwrites it, and "then removed" deletes it. Every live session then runs
  without the blueprint skill until the conductor runs `make install` after merge, and the merge
  waits on Geoff's packet. While the link points at the worktree, every other session on the host
  gets the unmerged skill. The launch check (no live session in drafter or cairn-cms) narrows this,
  but it doesn't cover sessions in other repos, which the hook can still steer to the skill.
- Fold: replace "then removed" with "then restored": `ln -sfn
  ~/Projects/drafter/claude/.claude/skills/blueprint ~/.claude/skills/blueprint`, confirmed with
  `readlink -f`. Do it at CR.3's end and in any stop path. Record the link's target before the
  swap.

### 6. major, correctness: the change block isn't pinned across a resume

- Location: plan `:52-56` (resolution 2) and `:92-97` (CR.1's files), against
  `internal/pipeline/start.go:177`, `resume.go:44-46`, `:65-78`, and `cmd/drafter/read.go:228-271`.
- Defect: the block needs the old fact text from `<rev>`, but `revisionAt` lives in `package
  main`, which the pipeline can't import, and `Scope` carries only ids. The plan doesn't say where
  the old text comes from at stage time, or on a resume. The obvious source for the new text is
  `p.r.facts`, which `LoadFacts` reads from the working tree. A resume allows HEAD to be any
  descendant of the run's start commit, so a resumed re-ask could pair an old bullet from `<rev>`
  with a newer working-tree bullet that the run's commit doesn't hold. That is a diff of a change
  that never happened. Rebuilding with `git diff` on a resume also depends on `<rev>` still
  existing. A `--since` of an amended or rebased commit is reachable only through the reflog, and
  gc can prune it.
- Fold: build the whole change block once, in `scopePages`, from the two commit-pinned
  `revisionAt` results and `git diff`. Persist it in the page's `work` beside `Since` and `Scope`
  (a new `work` field set in `start.go`, so it stays out of the `--json` scope), and read it from
  there on a resume. CR.1's files then add `internal/pipeline/work.go`, `start.go`, and
  `pipeline.go` (`Options`), and `resume.go` stays untouched. Add one acceptance row: a resumed
  scoped page sends the same change block bytes as the first attempt.

### 7. minor, correctness: the `git diff` call is shaped by user config

- Location: plan `:53`.
- Defect: `git diff` honours the user's and repo's config: `diff.external`, textconv drivers,
  `color.ui=always`, `diff.noprefix`, `diff.algorithm`, and `core.quotepath`. Any of these can
  change the bytes the model sees or run an external program, and on this workstation the diff
  isn't guaranteed to be plain unified text.
- Fold: `git -c color.ui=never -c core.quotepath=off diff --no-ext-diff --no-textconv --no-color
  <rev> <head> -- <path>`.

### 8. minor, optional: `<rev>` not an ancestor of the run's commit

- Location: plan `:12`, `:52-56`.
- Defect: `Compare` and `git diff` both compare tree to tree, so a `<rev>` on a side branch makes
  "the change" include the reversal of that branch's own edits. The read then blocks on content the
  author never touched. This fails closed (more blocking, never a silent accept), so it is safe,
  but a confused agent may chase phantom edits. A moved blueprint path is already safe: it is
  absent at `<rev>`, so the read is whole and sends no block.
- Fold: when `git merge-base --is-ancestor <rev> <head>` fails, print one stderr line naming it.
  Nothing more.

### 9. minor, optional: a demoted conflict has no durable sink for B3

- Location: plan `:64-67`, `:149-151` ("Later"); B2 plan `:305`.
- Defect: B3 plans scoped lock acceptance with `--since` defaulting to the lock's blob. Once that
  lands, a demoted conflict on an untouched fact never meets a whole read again. The nightly run
  drafts from a blueprint with a known fact conflict whose only trace is a warning in a pruned
  run directory. Google's rule, which the design quotes, sends existing problems to a filed bug,
  and this plan files nothing. **OWNER FORK**:
  - (a) Leave it to B3: add a "Later" line saying B3's scoped lock acceptance must not accept
    over a demoted conflict, or must carry it into the lock entry.
  - (b) Have `drafter read` print each demoted conflict to stderr now, and leave filing to the
    agent's skill.
  - (c) Have the skill tell the agent to log each "Already present" conflict through `log-issue`.
  - Recommendation: (a) plus finding 3's summary count. It costs one plan line now and leaves the
    policy to the pass that writes the lock.

### 10. minor, optional: headless test spend sits outside the cap

- Location: plan `:30-33` (standing answer 4).
- Defect: the meter and `DRAFTER_PAGE_CAP` see only drafter's API spend. B2's headless sessions
  cost $2.18, which the meter never saw. A rerun with retries could pass $10 while the cap reads
  under it. The likely total (about $2 of sessions and $2 to $3 of reads) is well inside $10, so
  this is bookkeeping, not a risk.
- Fold: add the session costs from the stream-json `result` events to the running total in the
  table, and check that sum against $10 before each dispatch.

## Checked and clean

- The lock: every non-whole `--since` accept skips `recordAccepted` (`read.go:379`), and a stopped
  or dry run writes nothing (`read.go:360`). A B2 state's `whole` page resumed under the CR binary
  keeps B2's escalate-on-any-conflict rule and writes the lock only after a genuine whole read. An
  optional row in CR.1's `runRead` test: a removed-section accept writes no lock.
- A downgrade (a CR state resumed by the B2 binary) ignores `facts` and escalates on any conflict.
  A scoped page with empty ids gets the unscoped prompt and no lock. That is conservative, and
  standing answer 4 already pins the resume to the worktree binary.
- The pinned base: cairn `origin/main` is `50dc211d9`, and `git reset --hard <base>` per tweak
  runs inside the worktree, with B2's main-checkout status checks.
- The clock file in the cairn worktree's git dir goes when the worktree goes, but pass-core
  removes it at task end anyway.

## Over-ceremony

None material. The plan is short and reuses B2's protocol by reference. The one cost worth
naming: CR.3 repeats B2's probe session and config-copy checks, about $0.01 and a few minutes.
That is cheap insurance on a changed skill, so keep it.
