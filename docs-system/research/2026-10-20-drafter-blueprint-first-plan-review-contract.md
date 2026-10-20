# Plan review, contract and criteria lens: drafter blueprint-first

Date: 2026-10-20. Target: `plans/2026-10-20-drafter-blueprint-first-plan.md` (uncommitted) and its
executor and conductor prompts, against the approved design
`specs/2026-10-20-drafter-blueprint-first-design.md`. Code read at drafter `6a42564` and cairn-cms
`52b3f979e`. Lens: is every promise testable, does every criterion name its fixture and failure
reason, can any bar pass vacuously, and does every design outcome map to a check that measures it.

Counts: 1 blocker, 9 major, 12 minor.

## Do findings 1 to 18 change the design's outcome, gate, proof, or bars?

The plan says none does (plan:56). Two do, and one more narrows the gate's input:

- **Finding 7 changes the replay's bar** (see M3). The design defines a false block as "a `wider`
  or `contradicts` verdict the code does not bear out" (design:249). Finding 7 judges it against the
  quoted excerpt and moves every `wider` on a true claim into a pointer column. That makes "zero false
  blocks at `main`" easier to meet than the design's text, so it should go to Geoff as an ask, not a
  routine row.
- **Finding 8 changes the gate's `no-excerpt` rule** (see M1). It makes every `path.md:N` pointer
  excerptable, which lets a verified fact sourced to a live docs page reach the seat as if it had
  evidence. The design's rule would block that fact. The design names the owner-tier problem
  nowhere, so a fix limited to the owner tier is a method call. A fix covering all prose is a gate
  change.
- Finding 3 drops the design's "with the fact diff" from the change read (design:126-127). The
  blueprint seat sees each changed fact's current text but not its old text. That is a small gate
  departure, and it is already recorded as a decision (m11).
- Findings 1, 2, 4, 5, 6, 9 to 13, and 15 to 18 are method calls that keep the design's outcome.
  Finding 14 moves the controls' sites and replaces "a blueprint that otherwise holds the gate" with
  a comparison against R2's read. That is a fair way to measure the same bar.

## Blocker

### B1. A `drafter page` read stage writes the new gate's accept without the fact-truth read

- Severity: blocker. Tag: `correctness`.
- Location: plan:585-589 (D2, "`PageResult` gains `Facts` ... set where `Summary` builds each
  result"), plan:458 and :474 (D1, "`drafter page` never sends the seat"); code
  `cmd/drafter/pagebp.go:195-200` (`recordDrafted` calls `recordReads`) and
  `cmd/drafter/draftscope.go:93-112` (a page not `skipRead` runs its blueprint read stage).
- Defect: `drafter page` on a page whose blueprint changed since its accept runs its own blueprint
  read stage, and D1 keeps the fact-truth seat out of that stage. `recordDrafted` then calls
  `recordReads`. D2 writes `facts` from `PageResult.Facts` for every run, so a page run writes
  `accepted` plus a `facts` map that no fact-truth read produced. That falsely meets the design's
  outcome ("drafter refuses to draft a page whose blueprint is not [dependable]", design:96-97). It
  also falsely meets the next pass's entry condition ("drafts only from blueprints that hold the new
  gate's accept", design:42-43). The pass drafts nothing, so this run hides the hole.
- Fold, the minimum: `PageResult.Facts` is set only on a run in which the fact-truth seat ran, which
  means `drafter read`. A page-run accept writes `accepted` with no `facts`, so the next `drafter
  page` refuses that page as lapsed ("no facts recorded"). Add a D2 test: a `drafter page` run whose
  read stage accepts a changed blueprint writes no `facts`, and a second `drafter page` refuses it
  before any request.
- **OWNER FORK**, the residual: even with the fold, the page run that accepts still drafts in that
  same run, from a blueprint the fact-truth seat never read. The options:
  - (a) `drafter page` refuses before any request any page without a current accept carrying
    `facts`. This meets the outcome literally and removes the page run's own blueprint read.
  - (b) The page run's read stage also sends the fact-truth seat. This contradicts design item 1,
    "runs in `drafter read` only".
  - (c) Land the minimum fold only, and file the in-run case for the drafting pass.

  Recommendation: (c) for this pass, because the pass drafts nothing and the drafting pass is
  designed from this record. The record should then state that the outcome sentence holds for
  lapsed pages only.

## Major

### M1. Finding 8 reopens the stale-page path that the design exists to close

- Tag: `correctness`. Location: plan:123-130 (finding 8), :504-505 (D3), :720-724 (control 5).
- Defect: finding 8 makes any `path.md:N` pointer yield an excerpt, not only the owner brief.
  cairn's store holds 142 verified bullets with prose pointers (factsheet-cairn section 3), and some
  are sourced to live docs pages. f:q07rd5 is sourced to `docs/extend/add-cairn-to-a-sveltekit-app.md:283-294,...`
  and placed by second, restrict, and scaffolded. f:dqnblw (`extend.md:507`, in the old tidy brief) is
  sourced to `...add-cairn...md:525,530`. Under the design's rule each of these blocks as
  `no-excerpt`. Under finding 8 the seat sees the page agreeing with the bullet. Whether it returns
  `holds` depends only on one prompt sentence, which no test or control exercises. All three of B3c's
  stale-page claims came in this way (design:153-154). Control 5 seeds a wrong claim on a fact whose
  pointers are code, so it never tests the page-sourced path.
- Fold:
  1. Limit the prose excerpt to owner-tier bullets: a bullet whose source is
     `docs/internal/what-cairn-is-and-is-not.md` and that carries `Key phrase:`, or simply that one
     configured path. Every other prose pointer stays `no excerpt: prose`.
  2. Add a D3 test that a `docs/...md:N` pointer outside the owner brief stays `no excerpt: prose`.
  3. Change control 5 in commit A so `f:ntdafg`'s only pointer is the live page line
     `docs/extend/add-cairn-to-a-sveltekit-app.md:873`. The control bites when the result is
     `no-excerpt`, `wider`, or `contradicts`. This adds no reads.

### M2. The replay's score can pass on verdicts from three different prompts

- Tag: `correctness`. Location: plan:678-682 (R1 step 3, "flagged when any read ... returns"),
  plan:280-288 (standing answer 3, "reruns only what the miss touches").
- Defect: after a tuning round, only the blueprints that place a missed bullet are read again. A
  bullet flagged in round 0 keeps its flag even when the final prompt would not flag it, so the 20 can
  be a union of verdicts from different prompt versions. Tuning against the 25 known answers is also
  tuning on the test set. The guard against that is R2's zero false blocks, but a tuning round reruns
  only "the blueprint holding a false block", so a prompt that over-flags after round 1 is never read
  at `main` again.
- Fold: score each bullet from the read run under the final prompt. After a tuning round, read every
  blueprint that places any of the 25 again (seven of the eight; rotate places none). Also read R2's
  eight at `main` again under the final prompt before the false-block bar is judged. If that cannot fit
  the $10 tuning budget, state that the bar is judged on the last prompt's verdicts over the
  blueprints it read, and report the union count alongside it. Never report the union alone.

### M3. Finding 7 loosens the zero-false-blocks bar, and the session grades its own seat

- Tag: `correctness`. Location: plan:115-122 (finding 7), :705-708 (R2 step 2); design:240-249.
- Defect: under finding 7, a `wider` verdict on a claim that the code bears out but no excerpt shows
  is a pointer defect, not a false block. A seat that answers `wider` whenever an excerpt is
  incomplete can therefore score zero false blocks while blocking many true facts. The design's
  definition measures the verdict against the code, which is stricter. The executor that tunes the
  prompt also classifies each finding, so the class that hides false blocks is self-graded.
- Fold, either way: R2's table reports three counts: design-literal false blocks (the claim is true
  in the code), finding 7's false blocks, and the pointer column. A fresh-context `general-purpose`
  reader on session tokens checks every pointer-column row against its code line before the bar is
  judged.
- **OWNER FORK**: which count the bar uses.
  - (a) The design's text: a `wider` on a true claim counts as a false block.
  - (b) Finding 7's reading, with the pointer column reported and each row re-pointed.

  Recommendation: (b), because the design already counts `no-excerpt` on a true but unshown claim as
  a correct block, and `wider` on a true but unshown claim is the same defect. Put it to Geoff as an
  ask row in the packet, not a routine row, since it sets what the bar measures.

### M4. The no-spend checks cannot run as written

- Tag: `correctness`. Location: plan:759 (M2 step 2) and :884 (K step 1.2), "`BIN spend --since
  <that minute> --json` shows no new row"; also design:333-334; code `cmd/drafter/spend.go:38,66`.
- Defect: `--since` takes a `YYYY-MM-DD` date only, so a minute is a usage error (exit 2). The JSON
  `rows` are totals per repo and seat (`spendRow`), not one row per call, so "no new row" measures
  nothing even with a date.
- Fold: record `drafter spend --json` before and after the call. The check holds when `total`,
  `open.count`, and every row's `requests` are unchanged.

### M5. A lapse read that blocks has no specified lock write, and K's revert sequence depends on it

- Tag: `correctness`. Location: plan:590-598 and :613-621 (D2 writes and tests),
  plan:885-888 (K step 1.3).
- Defect: D2 specifies what a lapse accept writes but not what a blocking lapse read writes: a bar,
  `accepted` kept or not, `facts` kept or not. No test covers that case. K step 1.3 runs exactly that
  read, then `git revert`, then expects the lapse line gone. Three things are unsaid: whether the
  lock is committed or restored first, whether a written bar then holds the page, and whether the
  tree is clean for `drafter page`.
- Fold: D2 states the case and tests it. A blocking lapse read writes a bar with its findings and
  keeps `accepted` and the old `facts`, or whatever D2 chooses. Either way, a later read after the
  fact is reverted takes the page back to accepted. In K step 1.3, run `git checkout --
  blueprints/drafted.lock` before the revert, so the lapse line's disappearance tests the hash and
  not a leftover bar.

### M6. The skill's tuning can leak the tidy blueprint into the rebuild that measures it

- Tag: `correctness`. Location: plan:841-842 (S, "folds into `new-page.md` as a step or an exemplar
  passage"), plan:855-860 (RB copies "the tuned skill's files except `exemplar.md`").
- Defect: the design withholds the exemplar from the rebuild "because it is this page"
  (design:224-225). S may write exemplar passages into `new-page.md`. If those passages quote the tidy
  blueprint or its facts, RB's author reads the answer, and the "fewer" bar passes for the wrong
  reason. The rebuild author can also reach the first build through `git show
  blueprint-first-pages:...`, because it is the same repository, or through STATUS and the friction
  log, which sit in the drafter git dir next to `rebuild-skill/`.
- Fold:
  - S draws `new-page.md` passages from the eight blueprints or from synthetic text, never from tidy.
  - Before dispatch, RB step 1 greps the copied skill for `turn-on-tidy`, `tidy`, and the tidy
    blueprint's item ids. Any hit is fixed before the author starts.
  - RB's prompt forbids reading other branches and the drafter git dir beyond `rebuild-skill/`.
  - The rebuild skill is copied to a separate scratch directory, not the git dir.

### M7. "Built from the code" has no check

- Tag: `correctness`. Location: plan:801-835 (B); design:97-98 and :150-154.
- Defect: B's outcome is only "holds the new accept". Nothing checks that the tidy facts are sourced
  to code, config, or vendor documents rather than to the live page. The old brief's f:dqnblw is
  sourced to a live page and tagged verified, and B's prompt hands the author the old brief's ids as
  candidates. Under finding 8 such a fact can pass.
- Fold: at B's end, run `BIN refs` on the tidy blueprint, then `BIN excerpt` on each cited fact. The
  check holds when no verified fact's excerptable pointers all sit under `docs/` outside the owner
  brief. Record the result in STATUS and the round table. The check is offline and free.

### M8. The budget table can exceed $45, and nothing allocates between items

- Tag: `correctness`. Location: plan:340-350 (the meter table), :556-558 (M1 step 4, "record it;
  the meter still governs"), :299-302 (standing answer 6).
- Defect: the table's upper bounds sum to $42, or $52 with the $10 of tuning. B is uncapped and
  "may not escalate", and RB and K, the design's skill measure and its Check, run after it. If E's
  rounds and the tuning spend most of the budget, B or RB/K stops at the ceiling. The design Check
  then never runs without Geoff.
- Fold:
  - E yields first. E's read calls stop at `left` ≤ the reserve of B, RB, and K: about $10, from
    M1's priced figures. Any blueprint still open is escalated under standing answer 5, which already
    allows that.
  - M1 step 4 writes the projected total with M1's figures. When R1 + R2 + R3 + the reserve exceeds
    $45, R1 step 4's prepared question names that before R1 starts.

### M9. The replay counts flags without checking that each matches the hand check's finding

- Tag: `correctness`. Location: plan:678-682 (R1 step 3); design:99-100 ("the gate catches what the
  acceptance pass's hand check caught").
- Defect: a bullet counts as flagged on any `wider` or `contradicts`, whatever its reason. A seat
  can reach 20 by flagging the 25 for reasons unrelated to R's findings, and the bar would read as
  "does the hand check's job".
- Fold: R1's table gains a column comparing the verdict's fix against R's finding for that bullet
  (match, partial, or other). The bar stays at the design's raw count, so this is a report, not a new
  bar. The record states both counts. This is session work, with no added spend.

## Minor

### m1. M2's lapse probe assumes debug-your-site's state

- Tag: `correctness`. Location: plan:758-759.
- Defect: the probe expects debug-your-site's entry to be accepted, equal to its blob, and unbarred.
  That holds only if R2 accepted it and E's window round left it untouched. R2's new seat may block
  it, writing a bar, or E may edit it.
- Fold: probe whichever of the eight's entries meets the condition at M2, or say so in STATUS and
  rely on D2's test if none does.

### m2. K's real `drafter page` call can spend if the refusal is broken

- Tag: `correctness`. Location: plan:883-884.
- Defect: K step 1.2 runs `BIN page --json` with no `--dry-run`. If the lapse refusal fails, the
  call drafts the page, and the design rules out any spending `drafter page` call (design:313-314).
- Fold: run it with `DRAFTER_PAGE_CAP=0.01`. A working refusal still prints the lapse line first,
  because the lapse check sits before pricing. A broken one is then stopped by the cap with no spend,
  and the check fails, as it should.

### m3. K's edited fact may also lapse the eight

- Tag: `correctness`. Location: plan:880-884.
- Fold: choose a fact cited by tidy alone. `BIN refs f:<id>` lists tidy only.

### m4. K step 1.1 repeats B's last read

- Tag: `optional`. Location: plan:875-879.
- Defect: B's final read already ran with no mode flag on M2's binary and accepted. A second whole
  read spends about $1 to $2, and a nondeterministic block would reopen B.
- Fold: K step 1.1 cites B's final run (its `state.json` `mode: sync`, `accepted`, and the lock
  entry) unless a drafter or cairn commit has landed since. Also, the summary JSON has no mode field
  (`internal/pipeline/pipeline.go:157-175`), so name `state.json` alone.

### m5. RB's "fewer" bar is ambiguous and blind to blueprint size

- Tag: `correctness`. Location: plan:867-868.
- Fold: define the bar as the total of blocking findings across the three seats, and report the
  count by seat. Report both builds' item and placed-fact counts, so that a smaller rebuild's lower
  count is visible.

### m6. The covers check's trial can pass vacuously

- Tag: `correctness`. Location: plan:757 ("passes over 26 string-only entries") and B.
- Fold: at B's end, run an offline negative probe. Drop one section's covers id in the working tree,
  confirm `BIN check` reports a `covers` error, then restore it.

### m7. D1's tests miss parts of the finding contract

- Tag: `correctness`. Location: plan:460-480.
- Fold: assert that a finding's text carries the quoted excerpt and the fix (design:133-135), and
  that a duplicate or unrequested id in the answer is handled, by taking the worst verdict or as a
  finding. In D2's lapse-read test, assert that the consistency request is sent (design:126).

### m8. The friction log has no closure check

- Tag: `optional`. Location: plan:837-849 (S).
- Fold: S writes a table with each friction entry and its disposition (folded into a step, folded
  into an exemplar passage, a format change under standing answer 7, or no action with the reason).
  The record carries it.

### m9. Finding 14 cites a task that does not exist

- Tag: `correctness`. Location: plan:161 and plan:737.
- Defect: "P2's unseeded read" names a task that does not exist. Control 6's "third commit" has no
  branch named.
- Fold: write "R2's unseeded read", and name control 6's branch (`blueprint-first-controls-c`,
  removed with the others).

### m10. Control 5's seed also opens a blueprint-against-fact conflict

- Tag: `optional`. Location: plan:723-724.
- Defect: r-env's `use` restates the corrected claim (factsheet-cairn section 7, control 5's
  caveat), so the bite may come from consistency, not fact-truth. The bar allows that, but the
  table should say so.
- Fold: the controls table lists every seat that fired at each seed site, not only the first.

### m11. Finding 3's claim that "was:" text cannot be recovered is too strong

- Tag: `optional`. Location: plan:89-92.
- Defect: the lock records no commit, but a walk of the lock's history like
  `blueprint.LockIntroducedAt` (`internal/blueprint/drafted.go:41-70`) finds the commit that wrote
  the current `facts` map, and from that the old bullets.
- Fold: no build needed. Reword the decision as "not built in this pass", so the drafting pass knows
  the old text can be recovered.

### m12. Over-ceremony: launch reading and the cairn branch review

- Tag: `optional`. Location: executor prompt line 5; plan:940-942 (Close step 3).
- Defect: the executor must read about 1,700 lines of factsheets up front, and the plan is
  re-read on every turn of an unattended session. Close step 3 also runs a whole-branch
  `diff-reviewer` over cairn's facts, blueprints, and lock. Those are thousands of YAML lines that
  the gate's own reads have already judged, so the review costs many tokens and finds little.
- Fold: read the factsheets by section when a task names them. Scope cairn's diff review to the
  outline entry, the live-page hand edits, and `BACKLOG.md`.

## Design outcomes and the plan's checks

| Design outcome or bar | Plan check | Measures the bar? |
|---|---|---|
| Fact-truth seat with four verdicts; `wider` and `contradicts` block; `no-excerpt` blocks verified only | D1 tests, R1, R2, R3 | Yes, with M1 (prose scope) and m7 |
| Lock `facts`; an edit lapses every citer; `drafter page` refuses before any request | D2 tests, M2 step 2, K steps 1.2 and 1.3 | Lapse case only; B1. No-spend proof broken as written: M4 |
| `drafter read` on a lapsed page reads the change | D2 test | Yes; the blocking case is missing: M5 |
| `drafter excerpt`, dotted anchors, `no-excerpt` warning | D3 tests, M1 steps 2 and 3 | Yes |
| Covers ids checked by `drafter check` | D4 tests, B | Yes; the trial is vacuous without m6 |
| Sync by default | D2 tests, K step 1.1 | Yes |
| Replay: 20 of 25 at 517; zero false blocks at main | R1, R2 | At risk of vacuous pass: M2, M3, M9 |
| Controls: six bite, the check named | R3 | Yes; class 5 tests the wrong path: M1 |
| Eight blueprints accepted, or open findings named | E check | Yes; budget starvation: M8 |
| Tidy blueprint built from the code, accepted | B, K | "From the code" unchecked: M7 |
| Skill tuned; fresh rebuild has fewer first-read blocks | S, RB | Contamination: M6; metric: m5 |
| `drafter refuses to draft a page whose blueprint is not` dependable | none beyond the lapse | B1 |
