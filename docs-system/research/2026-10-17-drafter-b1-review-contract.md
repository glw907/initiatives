# B1 plan review: contract and criteria

Target: `docs-system/plans/2026-10-17-drafter-b1-blueprint-format-plan.md` at `2e44160`. Lens:
whether every promise is testable, whether each criterion names its fixture and failure reason,
whether any criterion can pass vacuously, whether the plan delivers the design sections it claims,
and whether the design resolutions contradict the approved design. Code read at drafter `d3447d9`
and cairn-cms `9754d63`. Plan line numbers are the plan file's own.

Verdict: fix. One blocker, twelve majors, thirteen minors, one over-ceremony note. One OWNER
FORK (M2). No design resolution needs Geoff; resolution 1 is justified but only half applied
(M11), and the `framing` block contradicts the design's format change 4 (M7), which is a method
call to fold.

## Blocker

### B1. The lock write cannot be a per-page "drafter write" with `resume.go` frozen (correctness)

- Location: plan lines 296-298 (B1.4 "records the write in state as a drafter write"), 302, 318;
  `internal/pipeline/page.go:53`, `internal/pipeline/resume.go:154-187`, `resume.go:257-304`.
- Defect: drafter's write model is per page over `p.files()`, which is the page and its brief
  (`page.go:53`), with pre-snapshots named by index (`page.go:98-110`, a third file collides with
  `pre.brief.json`). `drafted.lock` is one file shared by every page in a run. Put in `files()`, an
  escalated page's restore puts the lock back to its pre-run bytes and erases another page's
  accepted entry, and `wantHashes` (`resume.go:223-255`) fails a resume once a second page wrote
  the lock. Left out of `files()`, a run that stops after one page wrote the lock cannot resume:
  `checkTree` refuses any changed file that isn't the run's own (`resume.go:291-293`). Fixing
  either needs `resume.go`, which the plan makes a line stop (line 49-51). The criterion "a stop
  and `--resume` mid-read ends accepted" (line 318) passes vacuously on a one-blueprint run, which
  is the only case where none of this shows.
- Fold: specify that `drafter read` writes the lock once, in `finish` after a loop that did not
  stop, from page state (each accepted page's recorded blueprint hash, see M9), so a stopped run
  never leaves the lock dirty and `resume.go` stays untouched. Say also that `drafter read`
  builds a synthetic `handoff.Handoff` per blueprint (`Plan` = blueprint path) so `rehydrate`
  (`resume.go:154`) runs unchanged. Add a two-blueprint acceptance row against the fake: one
  `accept` and one `fix` leaves exactly one lock entry; a stop after the first page accepts and
  a `--resume` ends with both pages' outcomes and one lock entry.

## Major

### M1. The live milestone has no negative control, so `accepted` can pass vacuously (correctness)

- Location: lines 348-362 (B1.5 step 6), 374.
- Defect: the milestone proves the read passed, not that the read still bites. The executor both
  fixes the blueprint and may edit the seat's prompt (lines 357-359), and the only guard is "keeps
  every read the prompt names", which a softened bar satisfies. That runs straight into the
  design's first anti-goal ("a bad page reaches `main` because the review gate was weaker").
- Fold: before the first live read, and again after any prompt edit, run the read once on a
  known-bad control: the converted blueprint with the gaps drafter#37 recorded (no deploy step
  after `wrangler versions secret put`, recovery routes before diagnosis). The criterion is
  `fix`, with a blocking finding on each seeded gap. Cost is one read (about $1), inside the $10.

### M2. B1.5's acceptance contradicts the miss path (correctness, OWNER FORK)

- Location: lines 360-362 vs 374 and 397.
- Defect: acceptance requires `drafter read` exit 0, but step 6 and Close allow "missed" with a
  classification. The executor can't tell whether a miss fails the pass or closes it.
- Options: (a) B1 closes on a miss: drafter's PR merges the build, the cairn PR stays a draft, and
  B2 waits on Geoff's reading of the classification. (b) B1 stays open until `accepted`, with a
  fresh spend approval past $10. (c) A miss stops the pass before Close, and Geoff rules.
- Recommendation: (a). The build has its own acceptance, and the design treats the milestone as
  evidence for the next pass. Split B1.5's acceptance into "built and measured" (smoke, check,
  timing, rounds recorded) and "milestone result", which is either value.

### M3. The blueprint read's request content is unspecified and untested (correctness)

- Location: lines 278-279; `internal/assemble/assemble.go:120-140`, `internal/assemble/excerpt.go:29-41`.
- Defect: "its request inlines the blueprint, the outline entry, and the bullets" names no
  mechanism. The `AnswerRead` path inlines every repo file the prompt text names
  (`fileBlocks`, `assemble.go:131-132`) and, for `FactIDs`, source excerpts from the code, not
  bullets (`excerpt.go:36-38`). A blueprint rendered into the prompt names dozens of repo paths in
  link targets and fact sources, so the request can silently grow by whole source files or the
  1015-bullet `extend.md`. None of the three fake runs (lines 309-315) checks request content, so a
  read that sees no facts passes every row.
- Fold: state who inlines what (the module renders the blueprint and entry, drafter adds one
  bullet block per placed or cited fact, no `fileBlocks` on blueprint text). Add a golden-request
  test: the blueprint fixture's request holds the blueprint bytes, its outline entry, the bullet of
  each placed and cited fact, and no bullet for an unplaced fact. In B1.5, record the dry-run
  token estimate before the first live read.

### M4. Hash definitions are missing, so two criteria are self-graded (correctness)

- Location: lines 147-151, 247-249, 261, 374.
- Defect: the plan never defines the page, blueprint, or section hash: algorithm, encoding, or for
  a section, which bytes (heading line included? to the next heading of which level? trailing
  blank lines?). "Section hashes match a hand-computed fixture" (line 261) is computed with the
  code under test, and "the lock's accepted hash equals the committed blueprint's hash" (line 374)
  has no command a reviewer can run. B3's change detection inherits whatever B1 picks.
- Fold: file hash is `sha256:` plus hex over the file's bytes, as `handoff.Checksum` does
  (`internal/handoff/handoff.go:181-197`), so `sha256sum` reproduces it. Define a section's span in
  `docs/blueprint-format.md`. The fixture's expected section hashes come from `sha256sum` over
  byte ranges written into the test, and B1.5's criterion becomes
  `git show HEAD:<blueprint> | sha256sum` equals the lock's accepted hash.

### M5. The edit-catalog test can pass with no edit at all (correctness)

- Location: lines 182-184, 219.
- Defect: each "after" fixture need only decode (and, in B1.2, pass `check`). A copy of the base
  fixture passes. The design's claim is "one obvious place for each change"; nothing tests that the
  edit landed in the kind and section the catalog row names. "Record changed behavior" and
  "Correct a claim" change a fact bullet, which a blueprint-only decode can't see.
- Fold: per row, assert the decoded diff from base is non-empty, touches only the item kinds the
  row names, and stays inside one section (except "Add or move a section"). The "Record changed
  behavior" row also runs `refs` on the changed fact and asserts the placements it lists.

### M6. The adapted v1 checks have no blueprint fixtures (correctness)

- Location: lines 191-193, 218, 225.
- Defect: "each new check has a failing fixture and a passing twin" covers only the new checks.
  Reader-state, recovery, links, crossLinks, and facts on blueprints are covered only by
  "`check-plan`'s tests are unchanged", which proves the old path. A `drafter check` that never
  calls the facts check passes every listed row.
- Fold: one failing blueprint fixture per adapted check, asserting its check name, including a
  fact cited from an `example` item and from `framing` (see M8).

### M7. The `framing` block carries planning history the design bans from durable fields (correctness)

- Location: lines 132-134, 241-242; design "Fitting the format to its jobs" change 4;
  `cairn-cms/docs/internal/briefs/extend/rotate-the-github-app-key.framing.md:230-264`.
- Defect: B1.1 gives `framing` a field per record heading, including "Departures from the plan's
  introduction". The rotate record's section narrates moves against the old plan ("The plan's item
  1 opens on the mechanism ...") and a friction note. Change 4: durable fields describe the page as
  it is now, and history belongs in the commit message. The record's prose also names sections by
  heading ("Recover from a failed key"), which change 2 forbids.
- Fold: `framing` holds the four descriptive sections. The converter prints "Departures" to stderr
  with the friction lines, and lists heading references in `framing` among the judgment items.
  Add both to the blueprint read's list (a durable field that narrates history).

### M8. Facts cited in `framing` are invisible to `refs`, the facts check, and the read (correctness)

- Location: lines 206-208 (`refs` list), 278-279; framing record lines 238-252 cite `f:s90j7l`,
  `f:vg42j3`, `f:kldwss`, `f:cjonmm`, and others.
- Defect: `refs` scans fact items, `facts` lists, the introduction, and dispositions. The framing
  block cites facts in prose. An agent correcting `f:vg42j3` misses that placement, the design's
  `refs` purpose (design "drafter check": "find each placement whose `use` it must re-read").
- Fold: give each `framing` field a `facts` list the converter fills from the `f:` ids in its
  prose. `refs`, the facts check, and the read's bullet set then include it. `refs`' three-line
  fixture gains a framing citation.

### M9. A blueprint changed between a stop and `--resume` can be recorded as accepted (correctness)

- Location: lines 293-298, 318; `internal/handoff/handoff.go:160-171`, `resume.go:156-160`.
- Defect: `rehydrate` trusts the handoff checksum, which for `drafter page` the planner wrote. A
  synthetic handoff built from the blueprint at resume time recomputes its checksum from disk, so
  a committed blueprint edit (HEAD may advance, `resume.go:96-111`) passes, and the lock records
  the new hash for a read of the old one.
- Fold: record the blueprint's hash in the page's state when stage 1 starts; the lock takes that
  hash; a resume refuses a blueprint whose hash differs. Acceptance: edit and commit the blueprint
  after a stop, resume, and expect a refusal naming the file.

### M10. "The consistency read, unchanged" can't take a blueprint (correctness)

- Location: line 269-270; `internal/assemble/consistency.go:20`, `internal/pipeline/steps.go:173-187`.
- Defect: `ConsistencyPrompt` takes a `*plan.Plan`, and `stageConsistency` gets it from
  `planDoc`, which decodes `h.Plan` as a v1 plan. The plan leaves open whether `blueprint` types
  embed `plan.Plan`, convert to it, or replace it ("reuse where the types allow", line 192-193).
  That choice decides whether checks, the consistency prompt, and `placedFacts` are reused or
  copied.
- Fold: name the relationship in B1.1 (recommended: the blueprint converts to a `plan.Plan` view
  for the shared checks and the consistency prompt, with `example` and `framing` facts mapped in).
  Acceptance: the consistency prompt for a blueprint fixture lists every placed and cited fact.

### M11. Resolution 1's one-home rule is half applied, and the converter's sources are unnamed (correctness)

- Location: lines 88-93, 135, 141, 239, 243; `docs/configuration.md:274`;
  `cairn-cms/docs/internal/outlines/extend.json` (each page's `exemplars` is a list of
  `{source, slice, manifestType, take}` objects).
- Defect: job and type move to the outline, but `page.path` and `page.title` stay in the
  blueprint while the outline also holds `path` and `title`, and the path rule already fixes the
  path. A renamed title goes stale in one home, which is the exact failure resolution 1 cites.
  `registerSections` duplicates the existing `register.<track>` setting, and the converter has no
  stated source for it. The `exemplars` field's shape is unstated though cairn's are objects.
- Fold: drop `page` from the blueprint (path from the path rule, title from the outline), or make
  `check` report a mismatch. Name `registerSections`' source (recommended: `register.<track>` in
  config, with the blueprint field only as an override) and the `exemplars` shape.

### M12. Adding `blueprint` to the seat names makes it required for every run (correctness)

- Location: lines 271-272; `internal/config/apply.go:29`, `internal/config/validate.go:43-47`,
  `docs/configuration.md:235`.
- Defect: `seats` defaults to every seat name, and validation requires model, effort,
  `max_tokens`, and a price for each running seat. With `blueprint` in `seatNames`, cairn's
  current `drafter.toml` (no `seats` list) fails to load for `drafter page` until B1.5 step 4, and
  the plan doesn't say whether `drafter page` runs the blueprint read on handoff pages. The e2e
  config sets `seats = ["draft"]` (`e2e/testdata/config/drafter.toml:2`), so no current test sees
  the break.
- Fold: rule that the blueprint seat runs only under `drafter read` and is validated only there.
  Acceptance: a config with no `seats` and no `[seat.blueprint]` still loads for `drafter page`,
  and a page run's request sequence is unchanged.

## Minor

- m1 (correctness), lines 143, 202, 335-336; `docs-register.md:762-818`. `anatomy`'s shape is
  unstated and the check is only "non-empty", which any string passes. The register's anatomies
  are bold list items, not headings, named "Concept page" and "Task guide" against the outline's
  `concept` and `task guide`. Fold: `anatomy` is a register reference (file, anchor, entry name)
  that `check` resolves.
- m2 (correctness), line 337; `extend.json` has no `migration-notes.md` entry (25 pages, none
  of `migration-notes`, `upgrade-cairn`, `choose-an-ai-posture`, `README`). "Mark it
  `managed: false`" requires adding an entry by hand. Fold: say so, and let an unmanaged entry omit
  `job`, `type`, and `covers` in the schema.
- m3 (correctness), line 363, absent from 371-375. Timing one blueprint is a vacuous test of
  "a few seconds over a whole project". Fold: convert all 11 plans into a scratch root (free),
  time `check` there, and add the timing to acceptance.
- m4 (correctness), design "Layout", line 167. "`drafter check` warns when a project departs from
  the convention" has no task. Fold: one warning row in B1.2 for a non-default root or facts dir.
- m5 (correctness), line 240. Section ids from heading slugs can collide (two "Verify"
  subsections), and the id pattern is unstated. Fold: converter suffixes or refuses, with a
  fixture.
- m6 (optional), lines 247-249, 342-347. The lock seeds the pre-reshape blueprint hash, so the
  reshape counts as a blueprint change and the page redrafts on its first B3/B4 run. That is
  consistent with design call 15 and wanted for cairn's 2b pages, but say it in the format doc and
  the cairn PR. The converter should refuse a page with uncommitted changes, since the seed records
  HEAD.
- m7 (correctness), line 303-307; `docs/configuration.md:245`, `docs/prompts-module.md:31`. B1.4's
  file list omits the "seven seats" sentences, and no task records the pipeline spec's stage 1
  and stop-table amendment the plan header claims (line 10-11).
- m8 (optional), line 321. "Eight seats" passes with any eighth row. Assert the `blueprint` row's
  answer is `read` at `medium`.
- m9 (correctness), lines 293-301. No row covers `drafter read` exits 2 and 3, or that
  `--dry-run` writes no lock. `finish` prints `drafter page --resume` (`pipeline.go:271`), the
  wrong hint for a read.
- m10 (optional), line 180. The docs test covers blueprint fields only, not `outline.yaml` or the
  lock.
- m11 (correctness), lines 136, 201. The `example` kind's fields are unstated, and whether `use`
  stays optional on a `fact` item (a placement of the whole fact) is unsaid.
- m12 (optional), line 314. The escalation's seat for a local check error (`check-plan` today,
  `internal/pipeline/check.go:74`) isn't named.
- m13 (optional), line 269-270. Consistency then blueprint runs as two sequential batch
  round-trips per read round. One step with both seats, as round 1 does, halves the wait across
  six rounds.

## Over-ceremony

- o1 (optional, low cost). B1.5 step 1 runs the full eight-seat live smoke when only the
  blueprint shape is new; if the smoke can run one shape, run that. The 600-minute path is 2x the
  design estimate against pass 4's 70 actual for 285 planned; nothing in the task list justifies
  the doubling beyond B1.4, so expect the clock to come in well under.

## Design coverage

- "Blueprints" and "Layout": covered, except the convention-departure warning (m4).
- "Managed pages": covered; m2 for cairn's missing entry.
- "Bootstrapping" item 1: covered; m6.
- "`drafter check`": covered; M6 and m3 on testability. `drafter status` is correctly B4.
- "Fitting the format to its jobs": changes 1, 2, 3, 5, 6 covered. Change 4 is contradicted by
  the `framing` block (M7) and has no check or read item for narration or copied register rules.
- "The edit catalog": present but vacuously tested (M5).
- "The pilot" first milestone: present; M1 and M2.

## Design resolutions against the design

1. Job and type in the outline: contradicts the design's field list, justified by one home and
   inside "Left to the builder" (field names and mapping). Not a fork; M11 finishes it.
2. `check-plan` stays: the design says it "becomes" `drafter check` and leaves an alias to the
   builder; keeping it for figure pages is justified.
3. to 7.: consistent with the design. Resolution 6's "never edits a blueprint" and 7's clean tree
   are sound, but 7 meets B1's shared-lock problem.
