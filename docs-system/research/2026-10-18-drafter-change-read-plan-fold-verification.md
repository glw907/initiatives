# Fold verification: drafter change-read plan

Plan: `plans/2026-10-18-drafter-change-read-plan.md` at `c0d56a8` (branch
`docs-system-change-read-plan`). Read against the approved design, the fold record, the three
reviews, and drafter `main` at `da3e1c7` (code unchanged since `f7d9034`; `da3e1c7` touches only
`CLAUDE.md`). Read-only, by a reader who had no part in the fold.

Verdict: **fix, small.** Every blocker and major in the three reviews closed at the location the
fold cites. The fold added one new mechanism that the code doesn't support as written (the
page-`with` match), and a handful of minor gaps. No order that can't build. The 260 path minutes
match the task list. Counts: 0 blockers, 1 major, 8 minors, 0 owner forks.

## Review findings: did each blocker and major close?

| Finding | Closed at | Check |
|---|---|---|
| M1 / C4 / I1 (blocker): scoped with empty ids renders unscoped | Res. 1 (plan:52-60), res. 3 (:77-87), CR.1 rows (:153-158, :164-165) | Closed. Matches `blueprint.go:130-131`, `docs-page-chain.js:2344,2355`, `since.go:101-103`, `page.go:193-197`. |
| M2 / I6: no source for old facts and entry; resume pinning | Res. 2 (:67-76), CR.1 Files (:144-151), row :159-163 | Closed. `scopePages` holds both revisions (`read.go:208-221`); `work` persists whole as JSON (`work.go:123-127`, `resume.go:171-173`), so an additive field needs no `resume.go` edit. |
| M3 / I5: CR.3 deletes the installed skill | Res. 8 (:117-119), launch (:47-48), CR.3 (:208-209) | Closed. `readlink -f` probed: main checkout's skill dir. |
| M4 / C13: refs sentence already exists; #3, #4 close on presence | Res. 7 (:105-110), CR.3 fields (:200-204), Close (:216-220) | Closed. `SKILL.md:16` is under case 1 only, as stated. |
| M5: no failure heading | Res. 7, CR.2 (:188-191) | Closed. `## The edit catalog` at `blueprint-format.md:333`, row at :343; `format.md` is a symlink to it. |
| M6 / C7: proofs pass on an empty fixture | CR.1 rows (:159-171) | Closed in substance; fixtures unnamed (minor 2). |
| M7 / C5: control patch gone | Res. 8 (:127-131) | Closed. Transcript path exists (14.6 MB). |
| C1 (fork, ruling 1): mislabel passes the bar | Res. 8 pass rule (:122-126), CR.3 column (:205) | Closed. |
| C2 (fork, ruling 2): control covers only kind 1 | Control 2 (:132-134) | Closed; miss disposition unstated (minor 3). |
| C3: consistency intersection fails open | Res. 4 (:88-99), CR.1 rows (:166-171) | (b) closed, fails closed. (a) ruled as "demote", but the stated page match cannot fire (major 1). |
| C6 / I3: accept drops findings | Res. 5 (:100-102), row :172-173 | Closed. `blueprint.go:162-164` is the one line. |
| C8 / I2: resume loses `Scope.Facts`; B2-era state demotes all | Res. 1 (:61-62), res. 4 (:95-97), rows :163, :171 | Closed. Go leaves a slice nil for an absent key or `null` and non-nil for `[]`, so nil means only "older state". |
| I4: touched set and match fail open | Res. 1 (:62-66), res. 4 | Closed for facts; page side as major 1. |

## Gaps, ranked by consequence

### 1. major, correctness: the page form of `with` the rule demotes is a form the model is never asked to write

- Location: plan:88-99 (resolution 4), :166-171 (CR.1 consistency rows); code
  `internal/assemble/schema.go:108`, `internal/assemble/consistency.go:42-66`.
- Defect: resolution 4 demotes a conflict whose `with` is "exactly a page the plan links (as
  `ConsistencyPrompt` lists them)". `ConsistencyPrompt` lists each linked page as its bare path
  (`path.Join(dir, file)`, consistency.go:50,62), but the answer schema tells the model to write
  `with` as "The fact id, or page#heading, they conflict with" (schema.go:108). A page conflict
  therefore arrives as `docs/x.md#Some heading`, which never equals the listed path. Every page
  conflict escalates. The rule fails closed, so nothing unsafe gets through. But resolution 4's last
  sentence, the fold's I4 and M12 dispositions (planning ruling 3: a link-caused conflict "is
  demoted in this pass"), and design Outcome 2 ("Any other conflict is reported as already
  present") all describe behavior the mechanism can't produce. No CR.1 row demotes a page `with`,
  so `make check` can't catch it. B2's recurring conflict was fact against fact (`f:sszb7b` against
  `f:vg42j3`, from B2's executor transcript), so the format test is unaffected. The first
  pre-existing page conflict under `--since` would block a correct edit, which is the defect this
  pass exists to remove.
- Fold: in resolution 4, match a page `with` by its part before `#` against the paths
  `ConsistencyPrompt` lists. Add two rows to CR.1's consistency table, each with a blueprint `ok`:
  untouched facts with `with: <listed page>#<heading>` accepts with the "Already present:" warning,
  and `with: <unlisted page>#<heading>` escalates on `consistency`.

### 2. minor, correctness: the change-block and outline-only rows name no fixture, and the obvious one lacks a facts store

- Location: plan:159-165; `cmd/drafter/read_test.go:404-430` (`newSinceProject`),
  `internal/pipeline/blueprint_test.go:357`, `internal/pipeline/testdata/module.js:18`.
- Defect: the change block is built in `scopePages`, so a test of its content (the hunk, a fact's
  old and new text, the entry JSON) has to run through `runRead` with real commits.
  `newSinceProject` is that fixture, but it writes no facts directory and no `[facts]` setting, so
  "one cited bullet" can't change in it as it stands. Both fixtures use stub prompt modules
  (`"Read the blueprint." + "\nScope: " + c.scope`), so "a request carrying the change-read
  paragraph" (:164) can only show up as `Scope: page` in the stub's output. The real paragraph is
  checked only by the render test at `read_test.go:242`. Left unnamed, an implementer could prove
  the block in the pipeline harness by handing it a block through `Options`. That proves the
  plumbing and not the build, which is M6's empty-fixture failure again.
- Fold: name the fixtures. The change-block, resume-bytes, and outline-only rows use
  `newSinceProject`, extended with a facts directory and its `[facts]` setting. The outline-only
  row asserts `Scope: page` from the stub. The consistency table uses `newBlueprintHarness` with
  `Options.Scopes` carrying `Facts`.

### 3. minor, correctness: a control that misses has no stated outcome

- Location: plan:127-134, :206-207; design:48-49.
- Defect: the design says control 1 "must still draw a blocking finding at the seeded step", and
  the fold put control 2 "outside the bar". CR.3's acceptance lists both controls' expected
  findings as acceptance, but neither the pass rule nor Close says what a miss does. A control-1
  miss with four of five tweaks passing could read as a met bar, since #1 and drafter#43 close on
  "the bar is met". A control-2 miss could read as a failed task, though it sits outside the bar.
- Fold: one sentence in resolution 8. A control-1 miss means the bar is not met, whatever the raw
  count, because the design requires the control to bite. A control-2 miss is recorded in its row
  and in the packet, and the bar ignores it.

### 4. minor, correctness: closing drafter#43 conflicts with the onboarding design

- Location: plan:221; `specs/2026-10-18-drafter-onboarding-design.md:253-254`; drafter#43's body.
- Defect: drafter#43 is about the whole read not converging on cairn's blueprint in six rounds,
  "before B3 and B4 run the read nightly". This pass leaves the whole read unchanged. The onboarding
  design approved today cites drafter#43 as the open condition O's design waits on: "O's design
  starts once a whole blueprint read has accepted a cairn blueprint in B3 ... The whole read failed
  six rounds on cairn's first blueprint (drafter#43)." Closing #43 on a passing `--since` test
  would drop that tracking. The design itself never says #43 closes. This is the only conflict
  with the onboarding design. The order (change-read, F, B3, O) and everything else in the plan
  agree with it.
- Fold: the comment on drafter#43 carries the rerun's table, and the issue stays open for B3's
  whole-read accept. Backlog #1 still closes on the bar.

### 5. minor, correctness: CR.1's dispatch names no model, effort, or isolation

- Location: plan:22-26, :140-143, :183.
- Defect: "CR.2 ... run by the session in CR.1's shadow" assumes CR.1 runs as a subagent. The plan
  never says so. It names no model, effort, worktree isolation, or `description`, which global
  CLAUDE.md ("Every dispatch names a model and an effort") and pass-core "Pairs" require. B2's plan
  named them (`sonnet` at `medium`, `b2-blueprint-skill task <n>`). CR.1 holds the pass's novel
  correctness logic (`Compare`'s fact set, the fail-closed rule), which the implementer agents' own
  descriptions say is the case to upshift. If CR.1 runs in the session, CR.2 isn't in its shadow
  and the path becomes 275, still inside 360.
- Fold: one line in Outcome. CR.1 goes to a subagent with `isolation: "worktree"` and
  `description` `change-read task CR.1`, with a model and effort named (Opus at high fits the
  novel logic). The session merges it before CR.3.

### 6. minor, correctness: the demoted-conflict count that CR.3 reads is asserted nowhere

- Location: plan:100-102 (resolution 5), :166-168 (row), :206 (CR.3 column).
- Defect: CR.3's row reads "the summary's demoted-conflict count", but CR.1's untouched-conflict
  row asserts only the record's warning and "the consistency verdict". It doesn't assert the
  summary count, and it doesn't name the verdict's value. Today the value is `conflicts`
  (`blueprint.go:171`), so a demoted conflict recorded as `conflicts` on an accepted page reads
  ambiguously.
- Fold: in that row, name the recorded verdict (for example `demoted`) and assert the summary's
  demoted count of 1, in both the text summary and `--json`.

### 7. minor, correctness: the launch session check can't pass as worded

- Location: plan:41-43.
- Defect: `claude agents --json` lists interactive sessions as well as background ones (probed:
  it lists this planning session, `drafter-3e`, cwd `~/Projects/drafter`). "Shows no session in
  drafter" therefore matches the launching session itself, or `conductor-drafter` if it runs
  there. An executor that reads the check literally stops at launch. M13's premise that it lists
  background sessions only was wrong, and the fold kept the wording.
- Fold: "shows no session in drafter or cairn-cms other than the executor and its conductor".

### 8. minor, optional: resolution 4's fail-closed cases depart from design Outcome 2 without saying so

- Location: plan:88-93; design:41-42.
- Defect: the design says any conflict that doesn't touch a changed fact "is reported as already
  present". Resolution 4 escalates an empty `facts`, an unknown id, and an unmatched `with` even
  when nothing touched is named. That is a sound strengthening, but resolution 1 marks its own
  departures from the design and resolution 4 doesn't.
- Fold: one clause: "a departure, failing closed where the conflict can't be placed".

### 9. minor, optional: the fold record's path is wrong in the plan header

- Location: plan:9.
- Defect: the plan cites `plans/2026-10-18-drafter-change-read-plan-fold.md`. The record is at
  `research/2026-10-18-drafter-change-read-plan-fold.md`.
- Fold: fix the path.

## Fold mechanisms: quoted or probed?

Every probe in the fold record was re-checked against the code and holds:

- `blueprint.go:130-131` and `:162-164`
- `handle.go:177-183`
- `decode.go:52`, the shared namespace
- `read.go:212-214`
- `work.go:123-127` and `start.go:273-274`
- `since.go:101-103`
- `SKILL.md:16`
- `blueprint-format.md:333` and `:343`
- `settings.json:93`
- the `spend` JSON fields (`total`, `open.count`)
- `--sync`
- `DRAFTER_PROMPTS`
- cairn `origin/main` at `50dc211d9`

Two of the fold's new mechanisms weren't probed. One is the page-`with` match (major 1, which fails
against `schema.go:108`). The other is the facts store the change-block row's fixture needs
(minor 2). The `git diff` flags were probed. The persisted change block needs no `resume.go` edit,
because `work` round-trips as JSON.

## Scope against the design

The plan stays inside the design's outcome. The additions all trace to a planning ruling (1 to 5)
or a review: the summary counts, findings recorded on every verdict, control 2, the base
classification, and the link swap and restore. The design's departures are marked: the two extra
whole cases, and `Compare` keeping three kinds. The exceptions are the unmarked fail-closed cases
(minor 8) and closing drafter#43, which the design doesn't ask for (minor 4). The "no setting, file,
or install step" line agrees with the onboarding design's anti-goal.

## Acceptance checks

The checks aren't vacuous, with two exceptions: the unnamed fixtures (minor 2) and the summary
count (minor 6). The `Compare` table names each case and its expected `IDs` and `Facts`. The A-to-B
item row and the uncited-bullet row pin the fact set. The consistency rows all use a blueprint `ok`
and name the escalating seat. The resume row asserts identical bytes. The B2 golden and the
`read_test.go:242` assertion pin the prompt. The lock row moves to a blueprint absent at `<rev>`.

## Path minutes

Consistent. CR.1 (150) runs with CR.2 (15) in its shadow, which counts once at 150. Then CR.3 (80),
then Close (30): 260. The fold record's estimate section gives the same sum. 260 is 2.17 times the
design's 120, which passes pass-core's two-times line only through standing answer 1 (up to 360), as
the plan says. If CR.1 isn't delegated (minor 5), the path is 275, still inside 360.
