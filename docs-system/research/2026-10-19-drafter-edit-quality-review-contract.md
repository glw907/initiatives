# Review: drafter edit-quality plan, contract-and-criteria lens

Target: `plans/2026-10-19-drafter-edit-quality-plan.md` (uncommitted), read against
`specs/2026-10-19-drafter-edit-quality-design.md` and
`research/2026-10-19-drafter-edit-quality-analysis.md`. Code read at drafter `main` `41939c3`;
harness read at `~/.claude/jobs/drafter-skill-rules/ft/`. Reviewer: the contract-and-criteria lens,
2026-10-18.

Question asked: is every promise testable, does each criterion name its fixture and why it fails
today, can any criterion pass vacuously, and does the rerun's acceptance match the design's
measures table.

Verdict: the plan's measures table matches the design's row for row (plan:417-426 against
design:55-64), and most code tasks name a failing-today row. Three criteria can pass without
measuring what they claim (findings 1 to 3), one promise contradicts the prompt it lands in
(finding 4), and the decline and positive-control readings leave grading to the executor or
quietly change the design's bars (findings 5 and 6, both owner forks). Nothing here blocks the
design; all of it folds into the plan's text.

## Findings, ranked by consequence

### 1. Blocker, correctness: an in-session read's `--since` is never checked, so "accepted" and "no read saw" can pass on a read that never judged the change

- Location: plan:199-201 (the skill's Read section), plan:139-142 (post-checks), plan:396-404
  (how acceptance and "no read saw" are read).
- Defect: the measures grade "the last in-session read" by exit, findings, and head tree. Nothing
  checks what the read compared against. A session that runs round 2 as `drafter read --since
  HEAD~1` (or `--since <round-1 commit>`) gets a change read of the round-2 delta alone; round 1's
  content is then old text and comes back, at most, as non-blocking "Already present:". The
  tree-equality check still passes, because the read's head tree is the final tree. A session that
  passes `--since HEAD` gets `unchanged`, exit 0, and no run directory (`cmd/drafter/read.go:118-129`,
  `exitCodeFor` in `cmd/drafter/page.go:56-66` treats `unchanged` as success). The harness's
  run-directory count catches that last case, but not the partial-diff case, and `state.json` does
  not record the since revision (`internal/run/state.go:21-29`), so the harness cannot recover it
  from the run directory alone. The "Already present: on the change" guard depends on the judge
  noticing, which is exactly what is under test.
- Fold: add to "How each measure is read": "An in-session read counts only when its `--since`
  resolves to `<base''>`: `grade.py` takes the `--since` argument from the read's Bash command in
  the stream, resolves it with `git rev-parse` at that read's head, and compares it with
  `<base''>`; or, equivalently, the saved request's `=== blueprint diff ===` block equals `git diff
  <base''> <read head> -- <BP>`. A read on any other base is a protocol breach." Add the same check
  to the loop probe's acceptance (plan:368-373) so the route is proven before the 21.

### 2. Major, correctness: the reviewer-grade bar has no direct test, so the 19-of-21 bar can pass because the judge got lax

- Location: plan:325-329 (EQ.4 acceptance), plan:376-382 (controls), design:38-43 (outcome 4).
- Defect: EQ.4's acceptance is string presence in the render. The only behavioral checks are the
  two seeded controls, and both seed classes the new rule keeps blocking (control 1 invents
  Wrangler output at `s-interval`; control 2 removes the PEM download from `s-generate`, a missing
  state). Nothing tests either edge of the new boundary: that a looping or dead-end handler (the
  4a and 4c class) still blocks, and that a heading, order, or placement defect (5a's heading, 2b's
  placement) now comes back as "Nit:". A Nit rule the judge over-applies raises the acceptance rate
  and passes every bar; the analysis names this risk ("the read's blocking bar may be set at the
  editor's taste", analysis:545-547) but the plan defers its only check to "Later" (plan:474-475).
- Fold: in EQ.7, a replay row set, outside the 21 and outside the bars, reported: re-apply #49's
  saved `t4c.patch` (handler loops to `rec-push-link`), `t5a.patch` (false claim plus the heading),
  and `t2b.patch` (placement only) to `<base''>`, re-seeding through `control.py` when a patch no
  longer applies, and read each once with `read.sh`. Expected: 4c blocks at the handler; 5a blocks
  on the claim and returns the heading as "Nit:"; 2b returns only "Nit:" findings and accepts.
  Each row fails today on the heading and placement half, since the prompt has no Nit class. Cost
  about $1.40, inside the $40.

### 3. Major, correctness: the live cache proof is conditional on the probe happening to read twice

- Location: plan:284 and plan:371-372 ("When it read twice, the second read's ledger row shows
  `cache_read` above zero").
- Defect: the loop probe uses p6, an add-a-link edit that passed 3 of 3 in #49, so it will likely
  accept on the first read and the cache criterion never runs. Then the first live proof of
  outcome 5 is the rerun, which only reports the cached share and has no bar. A prefix below the
  model's minimum cacheable length is silently not cached, so the unit tests on the wire (plan:271-282)
  cannot prove it either.
- Fold: replace the conditional with a forced pair in EQ.7: on the `ref6` commit, run `read.sh`
  twice within five minutes. The first ledger row shows cache-creation tokens above zero, the
  second shows `cache_read` above zero, and both rows' cost and reserve-to-settle time are recorded
  (this is also design outcome 5's "second read's cost and latency"). A zero on the second read
  stops the line before the 21, since every later "second read" figure would measure nothing.

### 4. Major, correctness: the Nit rule contradicts sentences the change read still carries, and EQ.4's criteria can't see it

- Location: plan:309-321 and plan:325-329 (EQ.4); the prompt at
  `claude/.claude/workflows/docs-page-chain.js:2296-2302, 2332-2335, 2346-2348`; the format page at
  `docs/blueprint-format.md:444-445`.
- Defect: EQ.4 requires "the scoped prompt still starts with the unscoped one", and the unscoped
  prompt says "Return a blocking finding for each `use` that restates the fact's content", lists
  "most logical order" and "the right pace" as checklist items, and ends "A checklist item the
  blueprint fails is a blocking finding". The appended change paragraph would then call the same
  defects Nits. Two instructions in one prompt conflict, and the acceptance (strings present) passes
  either way. The same contradiction lands on the format page: "Check what you add" opens with "a
  change read blocks on a defect in one" (`docs/blueprint-format.md:444-445`) over the heading,
  `use`, and steps-first lines, which EQ.1 keeps.
- Fold: EQ.4's change paragraph states its precedence in terms: "In a change read, this rule
  replaces the blocking rule above for order, pace, heading form, field placement, and a restating
  `use`: return each as a non-blocking finding starting "Nit:". A Nit never makes the verdict
  "fix"." Acceptance adds a `want` for that precedence sentence. EQ.1 rewrites the intro sentence
  of "Check what you add" to say which lines block in a change read and which come back as "Nit:"
  (by a link to the "What `drafter read` does" section, per the skill's link-not-copy rule), and its
  acceptance greps that the old clause is gone.

### 5. Major, correctness, OWNER FORK: what a decline is, and what a decline on another prompt scores, is left to the grader

- Location: plan:407-409, design:62.
- Defect, part a (prompt 4): under the fixed skill, prompt 4's correct output is the catalog's
  "Add a caveat" row, and a caveat is a caution, which is what p4 asks for (`p4.txt`). So "a
  committed edit smaller than the prompt asked" can read as zero declines or three for the same
  three diffs, depending on the grader. The design's row ("a pass when the smaller edit is accepted
  and the report names why") has no mechanical reading yet.
- Fold for part a (correctness, no fork needed): define p4's pass mechanically: the committed diff
  adds no `failure` item, adds a `sentence` with `mode: claim` citing `f:h252kb`, the final report
  names `f:h252kb` or says the case has no handler, and the run is accepted within three reads.
  The decline count for other prompts uses the same shape: the diff omits a part the prompt names,
  and the report names the fact id or section id that conflicts.
- Defect, part b: the decline rule gives every session a route to an easy accept. A session that
  answers p5 ("add a section") with one sentence and a note, or narrows p1, counts as accepted in
  the 19-of-21 and 20-of-21 bars, since plan:400-402 scores acceptance only.
- OWNER FORK (grading of declines on prompts other than 4):
  - (a) A decline on any prompt other than 4 is a miss in the bars, reported with its reason.
  - (b) As planned: a decline that is accepted counts as accepted on every prompt.
  - (c) As (a), except a p5 decline counts when its report names `x-editor` as the section that
    already carries the content (the analysis's 5a finding) and the smaller edit is accepted.
  - Recommendation: (c). Prompts 1 to 3, 6, and 7 keep their premises by EQ.6's grep (plan:347-350),
    so a decline there is a wrong answer; p5 is the one prompt the analysis named as plausibly
    duplicate (analysis:522), and the design narrowed the decline test to p4 without ruling on p5.

### 6. Major, correctness, OWNER FORK: a failing positive control drops its prompt and scales the bars, which the design's measures don't allow

- Location: plan:381-382 ("a reference edit that can't pass drops its prompt ... the bars scale as
  skill-rules resolution 7 scales them"), design:57-59 and 64.
- Defect: the design's bars are fixed (19 of 21, 20 of 21) and its Controls row reads "both
  positive controls accept". The inherited skill-rules rule turns a failed positive control into a
  smaller denominator, so the Controls row can never fail and the bars move. Under a new prompt
  that is the one case the positive controls exist to catch: a judge that now blocks a correct
  link or removal. Departure 7 (plan:86-90) carries three of #49's grading rules but not this one,
  and not #49's "the bar is met only with every run made" (skill-rules plan:330-332), so the
  departure list understates what is inherited.
- OWNER FORK:
  - (a) Design as written: a failed positive control fails the Controls row; its prompt still
    runs; the bars stay at 21.
  - (b) As planned: drop the prompt and scale the bars (`ceil(19 × N / 21)` and `ceil(20 × N / 21)`).
  - Recommendation: (a). Either way, list the choice as a departure and restate the inherited
    rules in full: infra rerun, protocol breach, accept definition, every run made, and how a
    control miss affects the verdict (in #49, control 1's miss failed the bar and control 2's did
    not; the design's "both bite" makes both count).

### 7. Major, correctness: "Nits never block" is the model's say-so, and the rerun doesn't count when it isn't

- Location: plan:396-399; `internal/pipeline/blueprint.go:197-245`.
- Defect: the page verdict comes from the model's `verdict` field (`a.Verdict == "fix"`), not from
  the findings' `blocking` flags. A read can return verdict "fix" with only "Nit:" findings, or a
  "Nit:" finding with `blocking: true`. The plan's accept rule (exit 0 and no blocking finding)
  scores both as misses, so the bars stay honest, but the design's promise "never block" has no
  count, and a rerun miss caused by an incoherent answer would be read as a skill miss.
- Fold: `grade.py` counts, per read, verdict-and-flag disagreements and "Nit:" findings flagged
  blocking, and the report lists them beside the per-shape rate. Optional (a scope addition to a
  file EQ.5 freezes): a change read whose findings hold no blocking item treats "fix" as "ok", with
  a `blueprint_change_test.go` row; that is a method call for the plan author, not a fork.

### 8. Major, correctness: per-run evidence that the session read with this pass's binary and prompt is missing

- Location: plan:126-133 (env-file route), plan:368-373 (probe proves it once).
- Defect: the route is proven on one probe. If any later session's Bash call misses the env file,
  `~/.local/bin/drafter` (main's binary) reads with `prompts = "~/.claude/workflows/docs-page-chain.js"`
  from the copied `drafter.local.toml`, which resolves to the main checkout's chain without the Nit
  rule. That run is graded under the old judge with no sign on its row.
- Fold: per in-session read, the post-check greps the run directory's saved blueprint request for
  the first block's `cache_control` and the "Nit:" rule sentence, and records `drafter_version`
  from `state.json`. A read without them is a protocol breach (infra rerun if it is the harness's
  fault).

### 9. Major, correctness: the false-fire test can pass on a warning that never fires

- Location: plan:246-251 (EQ.2), design:35-37.
- Defect: the false-fire procedure only drops warnings. If `handler` is implemented narrowly (for
  example, `rec-lead` isn't seen as a verbatim sentence), it fires on nothing at `<base'>`, the
  false-fire test is clean, and EQ.6's "no `handler` warning" (plan:351-352) is clean too. The
  analysis's two named hits are the only real-data positive check, and EQ.2 doesn't require them.
  Classification "defect or not" is also left open.
- Fold: EQ.2's acceptance adds: at `<base'>`, `handler` fires on `x-third-verify` and
  `x-check-threw` (the analysis's named defects); a miss on either is a bug in the rule, not a
  clean run. Any other hit is classified true when #49's reads or row 0 named that item, and
  otherwise is quoted with its item id in the commit message with the reason it is or isn't a
  defect. Record the `cited` hit count at `<base'>` there too, since EQ.6 must clear every one in
  30 minutes (finding 14).

### 10. Minor, correctness: judge agreement's sample, match rule, and reading are open

- Location: plan:410-412, design:63, analysis:571-573.
- Defect: "the first three runs whose first in-session read blocked" may find fewer than three
  (the result the pass hopes for). "Blocked at the same location" has no match rule. The design
  says "misses"; the plan reads it as first-read blocks without listing that as a departure. The
  agreement read reproduces the first read only if that read was on `<base''>` (finding 1). And a
  run's commits are dangling after the next reset, so a `git gc` between runs could lose them.
- Fold: fewer than three qualifying runs reports the number found, with no substitute. Same
  location means the same section id and item id. Name the "first-read block" reading in the
  departures. The report states the analysis's falsifier reading (fewer than two of three
  agreeing). `tweak.sh` writes `refs/ft/<run>` at each session's last commit so `agree.sh` can
  reach them.

### 11. Minor, correctness: protocol breaches under the new loop aren't listed

- Location: plan:86-90 (departure 7), plan:139-142.
- Defect: "a protocol breach is a miss" is carried over, but the new loop's breaches aren't named:
  more than three reads, a read without `--sync`, a read on the wrong base (finding 1), a stop
  with blocking findings open before the third read and before an accept, a whole read that writes
  `drafted.lock` into the tree, an amend that changes the tree, more than three commits. Each is a
  grader's call today.
- Fold: list them in "How each measure is read", each as a breach and a miss.

### 12. Minor, correctness: the open-findings commit message, outcome 1's last promise, has no check

- Location: plan:203-206, design:28-30.
- Defect: no row checks that a run ending unaccepted after three reads has the open findings in
  its last commit message.
- Fold: per run, when the third read didn't accept, `git log -1 --format=%B` names each blocking
  finding's location; a missing one is a breach.

### 13. Minor, correctness: the register half of outcome 4 has no measure

- Location: plan:316-319 and plan:391-392; design:41-43.
- Defect: "neither blueprint read returns a finding under a house register rule" is checked only
  by a sentence in the render. The rerun records "the rule each falls under" but sets no reading.
- Fold: the report counts findings across row 0 and the 21 whose rule is a register rule (heading
  form, the transcript rule); the expected count is 0, reported.

### 14. Minor, correctness: in-session reads are identified by new run directories under a shared path

- Location: plan:135-138.
- Defect: any other read of cairn-cms in that window (a nightly, the executor's own) lands in the
  same `runs/cairn-cms/` directory and counts as the session's. A resumed read (`--resume`) is
  counted as a second read.
- Fold: keep only run directories whose `state.json` `branch` is `format-test` and whose `head`
  is one of the session's commits; count a resume as part of the read it resumes.

### 15. Minor, correctness: EQ.6's "no `cited` warning" may force a rewrite larger than the recurring list

- Location: plan:351-352.
- Defect: if `cited` fires many times on the base, EQ.6 must cite or cut every uncited claim and
  example in 30 minutes, and each fix risks a prompt premise. The premise greps aren't named
  (plan:353-354), and "no worked example of the no-key answer" doesn't reduce to one grep.
- Fold: take the hit count from finding 9; above about ten, EQ.6 clears `handler` hits and the
  recurring list only, and records the `cited` count as base noise the measures ignore. Name each
  premise grep in `<job>`.

### 16. Minor, optional: two criteria are softer than the rest

- Location: plan:374-375 (no-key probe), plan:244 and plan:240 (EQ.2 rows).
- Defect: "says it skipped the reads" is a judgment; EQ.2's rows check severity and exit but not
  that each message carries its fix (design:36).
- Fold: the no-key row greps the final `result` text for the key's variable name and "skip"; each
  EQ.2 row asserts the message names the fix (for `handler`, the item to hand off to).

### 17. Minor, optional (over-ceremony): a line count stands in for a content check

- Location: plan:222 ("'Check what you add' holds six lines").
- Defect: the count is brittle (wrapping changes it) and adds nothing past the grep at plan:219.
- Fold: drop it; the grep that the caution line is gone, plus finding 4's grep, carries the
  criterion.

## The rerun's acceptance against the design's table

The table itself matches the design exactly, row for row. The readings beneath it (plan:396-412)
depart in four places, three of them unlisted:

| Design row | Plan's reading | Departure |
|---|---|---|
| Accepted within two and three reads | Adds final-tree equality and a read count | Stricter; fine, but blind to the read's base (finding 1) |
| Declines on prompt 4 | Counted on every prompt; no mechanical definition | Finding 5 |
| Judge agreement: three misses | First three first-read blocks | Unlisted (finding 10) |
| Controls: both positive controls accept | A failed positive control drops its prompt and scales the bars | Unlisted, and contradicts the fixed bars (finding 6) |

## Owner forks

1. Declines on prompts other than 4 (finding 5b): recommend (c), a miss except a p5 decline that
   names `x-editor`.
2. A failed positive control (finding 6): recommend (a), the design as written.
