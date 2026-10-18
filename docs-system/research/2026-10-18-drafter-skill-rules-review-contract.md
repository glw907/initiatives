# drafter skill-rules plan review: contract and criteria lens

Plan: `plans/2026-10-18-drafter-skill-rules-plan.md` (uncommitted). Design:
`specs/2026-10-18-drafter-skill-rules-design.md`. Read against drafter `0a7a30b`, cairn `50dc211d9`,
glw907/drafter#48's body, and the change-read plan. The planning session's three settled points are
taken as given. Counts: 1 blocker, 5 major, 6 minor. No owner forks.

## Blocker

### B1. Settled point 2 is missing from the plan, and "Later" defers the pairs it covers

- Severity: blocker. Tag: correctness.
- Location: plan:287-318 (SR.3), plan:112-117 (resolution 3), plan:315 (SR.3 acceptance), plan:378-379 ("Later").
- Defect: the planning session settled that the executor checks every base conflict pair the reads
  have named that one of the seven prompts can touch, f:ejuoh6/f:1pb077 via prompt 7 included. The
  plan has no step for this. SR.3 reads only f:sszb7b/f:vg42j3. Its acceptance requires "one file,
  one line changed". "Later" defers f:86h9o6/f:vg42j3, f:ejuoh6/f:vg42j3, and f:ejuoh6/f:1pb077. The
  risk is real. `Compare` puts every fact of a removed item into `Scope.Facts`
  (`internal/blueprint/since.go`, doc comment at `Compare`). So prompt 7, which removes
  `ver-live-wait` citing f:1pb077, touches f:1pb077. A consistency answer naming f:ejuoh6 against it
  then escalates, and the run exits 1, a miss caused by the base. That can happen on all three runs.
  Any run of prompts 3 to 6 that cites f:1pb077 or f:vg42j3 is exposed the same way. The design's Out
  of scope says the corrected bullet removes backlog #6's second case from this test, and that holds
  only if every pair a prompt can touch is checked.
- Fold: add an SR.3 step after step 3. List the pairs the reads have named (resolution 2's run
  records and row 0's answer). For each pair whose fact a prompt's correct edit, or a plausible
  citation, would touch (at least f:ejuoh6/f:1pb077, f:86h9o6/f:vg42j3, f:ejuoh6/f:vg42j3), read the
  code each bullet cites. Correct on `format-test` only a bullet cairn's code proves wrong, one commit
  per bullet. Record a scope difference as "no defect" with the reason. Then:
  - SR.3's acceptance becomes "one line changed per corrected bullet, each bullet named".
  - Resolution 3 and the `<base'>` note say how many bullets moved.
  - "Later" keeps only the pairs no prompt can touch, plus any pair recorded as a scope difference.
  - The PR's "For cairn's backlog" section lists each corrected bullet.

## Major

### M1. Whether a consistency escalation is a miss is stated two ways

- Severity: major. Tag: correctness.
- Location: plan:215-222 (grade), plan:39-40 (standing answer 3).
- Defect: an escalated page exits 1 (`cmd/drafter/read.go:59`: "1 when any was set aside"), so
  "the read exits 0" makes every escalation a miss. The next sentences classify each escalated
  conflict and say "An introduced one is a miss", which reads as if a conflict present at base were
  not. Standing answer 3 says such a read "still counts in the raw count", which can mean counted as
  a miss or counted in the denominator. Two executors could score the same run differently.
- Fold: state it once in the grade rule. "Every escalation, on any seat, is a miss, because the read
  exits 1. The classification of each escalated conflict as present at base or introduced is
  recorded for the PR and never changes the count." In standing answer 3, replace "It still counts
  in the raw count" with "It is a miss in the raw count".

### M2. An "Unplaced:" warning about a conflict the change introduced passes the run

- Severity: major. Tag: correctness.
- Location: plan:218-222.
- Defect: the grade fails a run on an "Already present:" finding that sits on the change. An
  "Unplaced:" warning "never fails a run" and goes unclassified. The new rule demotes every conflict
  with empty `facts` and `with`, whatever caused it. So when the agent's own new claim contradicts a
  fact and the consistency read can't place it, the run now passes, while the same defect placed on
  a fact is a miss. The rate then gives credit to Outcome 3's leniency, not to the skill. The design
  says the warning "never blocks" (the read's behavior). It doesn't say the grader ignores it.
- Fold: "Each 'Unplaced:' warning is classified against `git show <base'>:<blueprint>` like an
  escalated conflict: present at base (quote the base lines it describes) or introduced. An
  introduced one is a miss." Add the classification to SR.4's row fields (plan:336).

### M3. Runs are not shown to be independent

- Severity: major. Tag: correctness.
- Location: plan:199-214 (session flags, before and after each run), plan:205-207.
- Defect: the design measures a rate, which needs independent runs. Two shared surfaces are left
  open:
  - The sessions run with `--permission-mode acceptEdits --add-dir <drafter wt>/docs --add-dir
    ~/.claude/skills/blueprint`, and the skill link points at the drafter worktree. A session can
    therefore edit `docs/blueprint-format.md` (the skill's `format.md` is a symlink to it) or
    `SKILL.md` in the drafter worktree. Every later run would read the edited rules. The after-run
    check covers the cairn worktree and both main checkouts, not the drafter worktree.
  - `autoMemoryEnabled` is true in `~/.claude/settings.json`, and all 21 sessions share one cwd, so
    one run can write memory that a later run loads.
- Fold: add to the after-run checks "`git -C <drafter wt> status --porcelain` is empty and its HEAD
  is unchanged". A dirty drafter worktree is a protocol breach and a miss, reset before the next run.
  Snapshot the session cwd's auto-memory directory under `~/.claude/projects/` before each run. Any
  new or changed file after a run is recorded and removed before the next run. If the harness can
  turn auto memory off without changing #48's flags, do that instead and note it as a difference.

### M4. Nothing shows a correct edit for prompt 6 or 7 can pass the read

- Severity: major. Tag: correctness.
- Location: plan:168-195 (resolution 6), plan:324-329 (SR.4 pre-flight).
- Defect: each new prompt's "correct edit" is probed only with `drafter check`, which is the gate,
  not the grade. The grade is the change read. That read applies the register's anatomy section and
  the consistency read, and neither was run on the reference edits. If the read blocks a bare `link`
  item, or prompt 7's removal touches f:1pb077 into a base conflict (B1), a perfect agent scores 0
  of 3 on that prompt. The rate would then measure the read and the base, not the skill. As written,
  the "correct edit" paragraphs feed nothing in the grade.
- Fold: in SR.4's pre-flight, after `<base'>` is final, commit each reference edit from resolution 6
  by hand (no session), run the graded read on it, and record it as row "ref6" or "ref7" (about
  $0.70). If a reference edit fails, stop and either fix the base under B1's rule or report the
  prompt as unable to pass. Don't run a prompt whose reference fails.

### M5. "First try" is not defined for a run that fails for an infrastructure reason

- Severity: major. Tag: correctness.
- Location: plan:223 ("raw first-try count"), plan:205-207, plan:48-49 (standing answer 4).
- Defect: #48 had a "misfired first tweak" that was rerun. The plan doesn't say whether a session
  that dies on an API or harness error before the skill fires, or a read that exits 2, is a miss or
  gets rerun. It also doesn't say whether a read resumed under standing answer 4 is still a first
  try. The 17 of 21 count could move by executor judgment.
- Fold: one sentence in resolution 7. "A run's first dispatched session is its try. A session or
  read that fails before any model judgment (an API or harness error, with no `Skill` call or no
  read answer) is rerun once from a fresh reset and marked 'rerun'. A read resumed under standing
  answer 4 keeps its first-try status. Anything else that fails is a miss."

## Minor

### m1. SR.1's new rows can pass without proving what they claim

- Severity: minor. Tag: correctness.
- Location: plan:248-261.
- Defect: the existing `conflict` builder gives every conflict the text "they disagree". "The
  escalation detail names both conflicts" then passes on a `Contains` check that matches either one.
  `conflict(nil, "")` also encodes `facts` as `null`, while #48's evidence answer carried `[]`.
- Fold: the two-conflict builder takes a distinct conflict text per conflict, and the assertions
  look for each text. One unplaced row sends `"facts":[]` literally, matching run
  `20261018T210143Z-593b4ba9`.

### m2. The row "an unplaced conflict with a blueprint fix escalates on `blueprint`" also fails today, but the plan doesn't say so

- Severity: minor. Tag: optional.
- Location: plan:261.
- Defect: today that row escalates on `consistency`, so it fails before the change. The plan lists
  it with no "fails today" note, while it says that explicitly for the other new rows.
- Fold: add "Fails today: escalates on `consistency`."

### m3. The bar is undefined for a test stopped partway

- Severity: minor. Tag: correctness.
- Location: plan:205-207, plan:38.
- Defect: rounds run so that "a stop partway leaves an even sample". The plan doesn't say how a
  partial sample is scored against 17 of 21.
- Fold: "A run not dispatched is reported as not run. The bar is met only with 21 runs and 17
  passes, and a partial sample reports its count of runs made."

### m4. A pass can happen without the new section being read, and that wouldn't show

- Severity: minor. Tag: correctness.
- Location: plan:336, plan:339-341.
- Defect: whether each session read "Check what you add" is recorded per row but not totaled.
  Seventeen passes from sessions that never opened the section would credit the section with
  nothing. The new prompts' own line also needs prompts 1 to 5's line beside it to show the
  contrast the design wants.
- Fold: add two tally lines, "sessions that read the section, of 21" and "prompts 1 to 5 together,
  of 15". Define "read the section" as a Read of `format.md` or `blueprint-format.md` whose range
  takes in the heading's line.

### m5. Prompt 7 can't fail on the skill's merits

- Severity: minor. Tag: optional.
- Location: plan:187-195.
- Defect: "right after that ... Remove it" points at a single item, and the catalog's "Remove a
  claim" row is exercised only in its easy branch. The item goes, the fact stays placed, and no
  dispositions entry is needed. Short of base noise (B1), the prompt adds about three passes. That
  makes the bar about 14 of the other 18 runs, and the new prompts' line can't show a skill that
  learned only the five prompts. The prompt doesn't lead the agent to a hidden answer, but it tests
  almost nothing.
- Fold: pick a removal whose fact the removed item alone places or cites, so the agent has to choose
  between `dispositions` `cut` and leaving the fact unplaced (`drafter check` decides). Keep the
  developer-words constraint. Or keep prompt 7 and state in the PR that the bar is effectively 14 of
  18 on the rest.

### m6. The task-section line says "the checks", which only fits the rotation page

- Severity: minor. Tag: optional.
- Location: plan:122 (copies design:38).
- Defect: "In a task section, the checks come before the explanation" uses the rotation page's word
  for its steps. On a general format page, an agent editing a different task page has no "checks" to
  apply it to.
- Fold: on the format page, word it as "the steps (the actions the reader takes) come before the
  explanation". The meaning is the design's, and the source stays Red Hat's.

## Over-ceremony

None material beyond M4's point: resolution 6's "correct edit" paragraphs earn their place only as
positive controls. The rest of the protocol detail is load-bearing for a rate that two executors
should score the same way.

## Inside the design?

Yes, with one tension that B1 resolves. The design's Outcome 4 and "the base moved by that one
bullet" assume a single corrected bullet. Settled point 2 allows more than one, so the rows and the
PR must say how many bullets moved. The other changes stay inside the design: the caution line's
rewording, the consistency prompt cited as a source (settled point 1), and Geoff's F1 ruling
replacing standing answer 2's tail.
