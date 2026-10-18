# Review: drafter change-read plan, contract and criteria lens

Target: `docs-system/plans/2026-10-18-drafter-change-read-plan.md` at `cc15fc7` (branch
`docs-system-change-read-plan`). Read against the approved design
(`specs/2026-10-18-drafter-change-read-design.md`), B2's plan task B2.4 and resolution 2/9, the PR
#47 body, and drafter `main` (`f7d9034`): `internal/blueprint/since.go`,
`internal/pipeline/blueprint.go`, `internal/pipeline/steps.go`, `internal/pipeline/handle.go`,
`internal/assemble/consistency.go`, `claude/.claude/workflows/docs-page-chain.js`.

Verdict: **fix**. The plan is lean and its resolutions are sound, but the format test's criteria
cannot tell a correct change read from a lenient one, and the consistency rule has two paths by
which a conflict the change caused becomes a warning. Two findings are OWNER FORKs.

## Findings, ranked by consequence

### 1. The "Already present:" label can pass a defective tweak, and nothing measures it (major, correctness) - OWNER FORK

- Location: plan lines 13-16, 81-84, 125-128.
- Defect: the pass rule (B2.4: check green, read exits 0, zero blocking findings) counts a tweak as
  passing whenever the read labels everything it finds "Already present:". The label is the
  model's own claim; drafter does not check it (the escalation is driven by `a.Verdict` alone,
  `internal/pipeline/blueprint.go:162-185`). A read that mislabels a real defect in the tweak as
  already present raises the raw count. The table's two new columns count only *blocking*
  findings (on the change, on untouched items). No column counts the non-blocking findings that
  sit on the change, the one signal that shows the new label hiding a defect. So the bar can pass
  vacuously, by the exact leniency the change introduces.
- Fold (zero API cost): CR.3's row adds a third column, "Already present: findings on the change".
  The executor classifies every "Already present:" finding from `responses/*.json` as present at
  base, by quoting the base blueprint lines (`git show <base>:<blueprint>`) that hold the defect,
  or as introduced, when it sits on a diff line or on a defect the diff causes.
- **OWNER FORK**: how does a mislabel count against the bar?
  - (a) A tweak whose read labels an introduced defect "Already present:" is a miss in the raw
    count. **Recommended**: the bar measures whether a correct edit is accepted, and a defective
    edit accepted by mislabel is a read failure, not a pass.
  - (b) The raw count stays verdict-only, and mislabels are reported beside it for diagnosis, as
    B2's diagnostic count was.

### 2. The control proves bite only on a defect inside the added item (major, correctness) - OWNER FORK

- Location: plan lines 81, 127; design line 49.
- Defect: B2's control seeds a step that relies on state no earlier step produces, in a clean
  section (B2 plan, resolution 9). Under the change read, that step *is* the change, so it tests
  only the first blocking kind (a defect in what the change adds). The two places the new rules can
  go lenient have no live control:
  - the second kind, a defect the change causes elsewhere, which the prompt must locate at the
    changed item (resolution 3);
  - the consistency intersection (resolution 4), where a conflict the change caused must still
    escalate.

  A read that blocks only on the added item's own text, and a consistency rule that warns on
  everything, both pass every check in CR.3.
- Fold: one or two more seeded controls, outside the bar, at about $0.35 each, inside the $10
  budget:
  - (i) A commit that rewrites an earlier step's `text` so a later, untouched step's prose-only
    dependency now has no source. The expected result is a blocking finding located at the
    rewritten step.
  - (ii) A commit that edits a placed fact's bullet so it contradicts another placed fact. The
    expected result is a consistency escalation.

  CR.1's pipeline tests cover (ii) offline, so (i) is the one only a live run can prove.
- **OWNER FORK**, because the approved design says the test runs "again unchanged" with "the
  seeded control":
  - (a) Add control (i), and optionally (ii), outside the bar. **Recommended**: the test is the
    only end-to-end evidence that the second kind blocks.
  - (b) Keep the single control and record in the PR that kind 2 and the intersection have no live
    proof.

### 3. The consistency intersection lets a conflict the change caused through (major, correctness)

- Location: plan lines 64-68 (resolution 4), 103-104.
- Defect: there are two paths.
  - (a) A change that adds a `link` item brings a new page into the consistency read
    (`internal/assemble/consistency.go:42-66` lists every non-URL `link` target). A conflict
    between an untouched placed fact and that newly linked page comes back as `facts: [Y]`,
    `with: <page path>`. Y is untouched and `with` is not a fact id, so the intersection is empty
    and the change's conflict becomes an "Already present:" warning.
  - (b) The rule matches `with` only "when `with` is a fact id". A model that writes
    `with: "fact X (the ...)"` or `with: "X and Z"` for a touched X fails the exact match, and the
    conflict becomes a warning. The failure is open: a format slip downgrades a real conflict.
- Fold: `Scope` also records the link targets of new or differing `link` items (or `Scope.Facts`
  becomes a touched set of fact ids plus link paths). The rule escalates when `with` resolves to
  one of those paths. The rule fails closed: a conflict escalates unless every entry of `facts` is
  a known fact id and `with` resolves exactly to a fact id or a linked path, and none of them is
  touched. CR.1's acceptance adds both cases: a conflict with a newly linked page escalates, and an
  unparseable `with` escalates.

### 4. A scoped page with no changed section ids renders the unscoped prompt (major, correctness)

- Location: plan lines 43-51, 57-62; code `internal/pipeline/blueprint.go:130-131`,
  `docs-page-chain.js:2355`.
- Defect: resolution 1 makes an outline-entry change, a page-level field change, a removed
  section, or a changed fact cited only from framing or the introduction `ScopeScoped`, with
  possibly empty `Scope.IDs`. Today the prompt's scope argument is `strings.Join(Scope.IDs, ",")`,
  and `DRAFTER_SEATS.blueprint` passes `c.scope || undefined`. An empty string selects the
  *unscoped* prompt: a whole-read checklist that blocks on everything, sent with a change block
  that nothing names. Two more points:
  - `Compare` today returns `ScopeUnchanged` when `changed` is empty (`since.go:101-103`). An
    unrevised tail would send an outline-only change to "no API call".
  - The acceptance at lines 99-101 says such cases are "now scoped", but no criterion checks the
    request they produce.
- Fold: the prompt's scope switch keys on `Scope.Kind == ScopeScoped`, not on non-empty IDs, so a
  flag or a sentinel reaches `blueprintPrompt`. CR.1's acceptance adds a pipeline test: an
  outline-only change yields a scoped request carrying the change-read paragraph and a change
  block with the entry's old and new JSON. The `Compare` table asserts `Kind == ScopeScoped` with
  empty `IDs` for that case.

### 5. "The seeded control is B2's" names no artifact that still exists (major, correctness)

- Location: plan lines 81, 127.
- Defect: B2.4 recorded the control's patch in `<drafter wt git dir>/b2-format-test.md`. The B2
  worktree is gone, and no file of that name exists on disk (searched 2026-10-18). PR #47
  deliberately left the patches out. The control was executor-run, so no surviving
  format-test session transcript holds it either. "B2's" control therefore cannot be replayed
  byte for byte, and a re-seeded control in a different section or with a different dependency
  breaks the comparison the plan relies on.
- Fold: CR.3 states the control's source. Either recover the patch from the B2 executor's session
  transcript and cite it, or re-seed it to B2's specification (a step in the verification section
  that relies on state no earlier step produces, `requires` silent) and record the new patch
  beside the row. The table marks it "re-seeded" if so.

### 6. On an accept, the record drops the non-blocking findings the design promises to report (major, correctness)

- Location: plan lines 13-14 (Outcome: "reports older defects as non-blocking"), 57-62; code
  `internal/pipeline/blueprint.go:161-163`.
- Defect: `completeBlueprintRead` writes findings to the record only when the verdict is `fix`.
  On a change read that accepts, every "Already present:" finding exists only in
  `responses/*.json`, invisible in `record.json` and stdout. No criterion tests the "reported"
  half of the Outcome. Google's rule, which the design quotes, is to surface existing problems so
  the author files them, and the current code discards them on exactly the path the change makes
  common.
- Fold: on a scoped read, record the findings whatever the verdict. CR.1's acceptance adds a
  pipeline test: a scoped read answering `ok` with one non-blocking "Already present:" finding
  accepts, and the record carries the finding.

### 7. The change-block test checks presence, not content (major, correctness)

- Location: plan line 102.
- Defect: "shows the change block in a scoped request and none in a whole one" passes with an
  empty or mislabeled block. Resolution 2's three parts go unchecked, and so does the "data,
  never prompt text" rule:
  - the diff for `<rev>..<head>` of the blueprint path;
  - each changed fact bullet's old and new text by id;
  - the entry JSON only when the entry changed.

  The change read is only as good as this block.
- Fold: the test scripts one edit of each part (an item edit, a fact bullet edit, an entry edit).
  It asserts that the block holds the edit's hunk, the fact id with both texts, and the entry's old
  and new JSON. It asserts no entry JSON when the entry is unchanged, and that the block sits in
  the request's data blocks after `BlueprintBlock`, not in the rendered prompt.

### 8. A resumed run can lose `Scope.Facts` and warn on every conflict (major, correctness)

- Location: plan lines 47-50, 107-108; B2 plan resolution 3.
- Defect: B2's scope survives a resume by riding in each page's `work` struct, which `rehydrate`
  decodes. `Scope.Facts` is a new field. If it lacks a JSON tag or doesn't round-trip, a resumed
  scoped read sees an empty touched set, and every conflict becomes an "Already present:" warning.
  The failure is silent and lenient. `resume.go` must stay untouched, so the only guard is a test,
  and none is listed.
- Fold: CR.1's acceptance adds one assertion. A scoped `work` marshalled and rehydrated keeps
  `Scope.Facts`, and a touched conflict after the round trip still escalates. The assertion goes
  in `blueprint_test.go` or the existing resume tests, without touching `resume.go`.

### 9. The consistency-rule tests omit the cases resolution 4 names (minor, correctness)

- Location: plan lines 103-104.
- Defect: the two scripted cases put the touched fact in `facts`. Several cases go untested:
  - `with` naming a touched fact while `facts` holds only untouched ones, which resolution 4 names
    explicitly;
  - a whole read escalating on an untouched conflict ("as today");
  - an untouched conflict plus a blueprint `fix`, which must escalate on the blueprint seat, not
    accept;
  - the consistency verdict string recorded for the warning case.

  An implementation that checks only `facts` passes as written.
- Fold: add those four rows to the same table test.

### 10. Gaps in the `Compare` acceptance and in what `Scope.Facts` means (minor, correctness)

- Location: plan lines 43-51, 99-101.
- Defect: three gaps.
  - The revised cases list omits a level change and a changed fact cited from framing, the
    introduction, or dispositions, which were whole in B2 (`since.go:84-86, 93-94`).
  - "Every fact whose bullet changed" is ambiguous: it could mean every changed bullet in the
    store, or only those this page places or cites. Read globally, an unrelated fact edit makes
    every page scoped (an API call per page) and marks a fact the page never places as touched.
  - The plan adds two whole cases the design does not have: the current blueprint undecodable, and
    the page missing from the outline at `<rev>`. The design says whole "only when the blueprint
    is absent or undecodable at `<rev>`". The cases are sensible but not flagged as departures, and
    the head-side missing entry is unstated.
- Fold: name the omitted cases in the table. Define `Scope.Facts` as changed bullets this page
  places or cites, plus the facts of new or differing items and page-level fields. Add a case:
  an uncited fact's bullet changes and the page stays unchanged. Mark the two extra whole cases
  as departures in the resolutions.

### 11. The scoped prompt's content is asserted nowhere (minor, correctness)

- Location: plan lines 57-63, 105-106.
- Defect: the unscoped render has a golden, but the scoped render is checked only by the parity
  test, which proves Node and goja agree, not what they render. Nothing checks that the paragraph
  names the change block, carries the "Already present:" instruction, keeps "Verdict fix if any
  blocking finding exists", or quotes the Google sources. An edit that dropped the "Already
  present:" instruction would pass `make check`.
- Fold: a golden of the scoped render (as B2 did for the unscoped one), or contains-assertions
  for those four strings.

### 12. The pass rule does not settle a verdict that disagrees with its flags (minor, correctness)

- Location: plan lines 81-84; B2 plan line 165-166.
- Defect: escalation follows `verdict`, while B2's pass rule also requires zero findings with
  `blocking: true`. Under the new prompt, two new disagreements are likely:
  - `fix` with only "Already present:" non-blocking findings, which exits non-zero with nothing
    blocking;
  - `ok` with a `blocking: true` finding labeled "Already present:".

  Standing answer 3 says a block on an untouched item "doesn't stop the test" but not whether it
  is a miss.
- Fold: state it in CR.3. A tweak passes when the check is green, the read exits 0, and no finding
  carries `blocking: true`. Any disagreement is a miss and a column of its own (read defect).

### 13. Backlog #3 and #4 close on the sentences' presence, not on their effect (minor, correctness)

- Location: plan lines 115-117, 136-138.
- Defect: CR.2's acceptance is that two sentences exist and a link resolves, which passes
  vacuously against the backlog items' purpose. The design frames them as "skill fixes from the
  format test". B2's row already records whether `refs` ran before the edit for tweak 2, and
  tweak 4's commit shows the caveat's item kind.
- Fold: close #3 only if tweak 2's row shows `drafter refs` before the edit. Close #4 only if
  tweak 4's commit adds a `failure` item with a `handledBy`. Otherwise leave each open with the
  row. CR.3's row names both.

### 14. A conflict that existed at base escalates when a tweak re-cites its fact (minor, optional)

- Location: plan lines 47-50, 64-66.
- Defect: as designed, a new item citing fact Y makes Y touched, so B2's recurring pre-existing
  conflict escalates again if a tweak cites its fact. That is plausible for tweak 4 ("The docs
  already record when that happens") and tweak 2. The result conforms to the design, but the
  table's "consistency outcome" column would read as a change-caused conflict.
- Fold: the column records, for an escalating conflict, whether the same conflict came back at
  base in B2's reads (from PR #47's rows), so the classification separates the two.

### 15. Over-ceremony (minor, optional)

Nothing material. The plan is proportionate: 180 path minutes, one live task, one review chain.
The clock-file split (lines 23-24) and the five-part launch check add a few minutes at most. The
two additions above (control (i), about $0.35 and 10 minutes; the mislabel column, executor time
only) cost less than a second rerun after a vacuous pass would.
