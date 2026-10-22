# Survey house style rewrite: contract and criteria review

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `ad97b5f`. Line numbers refer to the spec at that commit. Lens: is every promise testable, does each acceptance criterion name its fixture and the reason it would fail, and can any criterion pass vacuously. Rulings 1 to 7 and the 2026-10-21 and 2026-10-22 rulings are settled and not reopened here; every fold below works inside them.

Evidence read: `~/.claude/skills/writing-voice/evals/` (`README.md`, `evals.json`, `results/2026-09-01*/benchmark.json` and `notes.md`, `tellgrader/MEASURES.md`), the `model-review.timer` unit, and the earlier reviews and folds in this directory.

## What the September data says about the thresholds

Four facts from the existing results drive most of the findings.

1. **The September spreads are not run-to-run spreads.** Every `benchmark.json` declares `"runs_per_configuration": 3`, but each holds 24 runs: twelve evals, two arms, `run_number` 1 only. The reported standard deviation (0.159 for iteration 1's skill arm, 0.0754 to 0.0858 in iteration 3) is the spread across *different tasks*, not the noise of re-drafting one task. Line 220 says "The thresholds are judgment calls set from the September benchmark's spreads". No measurement of per-task repeat noise exists on this workstation.
2. **Deleting the whole writing system passes the assertion band.** Iteration 1 compared the skill arm with a bare arm that read no skill or register. The skill arm's pass rate was 0.903 with an across-eval standard deviation of 0.159, so its "mean minus one standard deviation" band floor is 0.744. The bare arm scored 0.778, inside the band. Its rubric mean was 3.77 against 4.35, a 0.58-point drop that any rubric standard deviation above 0.58 also admits. Only the blind preference (8 to 4, 67%) separated them.
3. **Rubric means drift with the judge cohort.** Iteration 3's notes: "Rubric means are not comparable across judge cohorts ... free rubric means drift with the judge cohort and should be read only within a run." Their judges scored the old arm higher (4.44 against 4.23) while preferring the new arm 7 to 5. The spec compares a stored Pass D rubric mean against rubric means judged in later passes and later months.
4. **Assertions sit at the ceiling and some never discriminate.** Iteration 3 passed 69 of 72 and 67 of 72. The explainer lead-with-diagnosis assertion "failed both arms for the third straight run". Many surfaces will have a baseline assertion pass rate of 1.0 with a standard deviation of 0.

Binomial arithmetic on the blind preference, with three tasks times three runs, gives nine pairs per surface. "No more than 60%" means the baseline may win at most five of nine.

| Case | Probability |
|---|---|
| An unchanged candidate fails match on preference alone (baseline wins 6 or more of 9 at p = 0.5) | 25.4% per surface |
| All fourteen surfaces pass preference when nothing changed | 1.7% |
| An unchanged candidate "beats" on preference alone (wins 6 or more of 9) | 25.4% per attempt |
| A regression the judge sees 67% of the time (the size of deleting the system) fails match | 65.8% |
| A regression the judge sees 60% of the time fails match | 48.3% |

So the criterion is loose where it should be strict and strict where it should be loose: the rubric and assertion bands let a whole-system deletion through, while the preference test fails an unchanged system about one surface in four.

## Findings, ranked by consequence

### 1. "Match the baseline" cannot fail a real regression on the rubric or assertions. Blocker, correctness

Location: spec lines 218, 220, 432.

Defect: The match band compares a candidate's *mean over nine drafts* with the baseline's mean minus one *draft-level* standard deviation. The standard error of a nine-draft mean is a third of that deviation. The band is therefore about three standard errors wide, and a regression of up to one full draft-level deviation passes. The band also widens as the baseline gets noisier. Noise makes regressions easier to pass, not harder. The September data shows the size of the hole: the bare arm, with no writing system at all, sits inside the assertion band (0.778 against a floor of 0.744). The stop answer at line 432 makes it worse in two ways. A rubric standard deviation over one point on a 1-to-5 scale whose means run 3.77 to 4.67 will almost never occur. The low-confidence flag almost never fires, yet a deviation of 0.9 admits a 0.9-point drop. Adding up to two runs per task estimates the draft-level deviation better but does not shrink it, so the remedy does not narrow the band. Ruling 4's "a context passes only if it matches its baseline" is enforced only by the preference test, which catches a whole-system deletion about two times in three.

Proposed fold: Replace the band with a paired non-inferiority test on the difference of means. Pair each candidate draft with the baseline draft of the same task and run, compute the mean difference per measure and a 90% bootstrap interval over the nine pairs, and require the interval's lower bound to sit above a fixed margin: rubric no worse than 0.3, assertion pass rate no worse than one assertion per surface (about 0.1), tells per draft and Vale errors per draft no higher by more than 1. Fixed margins don't widen with noise, and more runs genuinely narrow the interval, so line 432's remedy (add runs when the interval straddles the margin) starts to work. Retire "one rubric point" as the low-confidence trigger; a surface is low-confidence when its interval still straddles the margin after five runs. Name `evals/README.md` as the home of the margins and the reason for each.

### 2. The preference test fails an unchanged system often enough to stall Pass E, Pass G, and every `core` change. Blocker, correctness

Location: spec lines 218, 219, 362, 429, 337.

Defect: With nine pairs, an unchanged candidate fails the 60% preference rule with probability 0.254 per surface (table above). Pass G's release "must match the baseline on all fourteen surfaces" (line 362), and so must any change to `core` or a shared Vale rule (line 219); with no real change, all fourteen pass preference only 1.7% of the time. Pass E switches a repo "only when every surface it writes matched" (line 337). Several repos will stay unswitched on noise. Each false miss triggers line 429's answer, "traces the cause, makes one structural fix". That answer hunts a cause that does not exist and then escalates. The assertion measure adds more false misses: a surface whose baseline passed every assertion has a standard deviation of 0, so its floor is 1.0 and one stochastic slip in 27 to 36 checks fails it. Iteration 3 called single-draft fabrication "variance to be priced with multiple runs, not a systematic register defect".

Proposed fold: Treat preference as non-inferiority too: the candidate matches when the upper bound of a 90% interval on the baseline's win share sits at or below 0.65, with ties counted as half a win each. When an all-fourteen run is required, also report the pooled preference across all surfaces (126 pairs), which has real power, and fail on a single surface only when its own interval clears the margin outright. Under fold 1, a baseline at the ceiling no longer gives a zero-width band. Add one stop answer: an indeterminate surface (its interval straddles the margin) gets two more runs before any structural fix is attempted.

### 3. No fixture shows the match rule can fail. Major, correctness

Location: spec lines 326, 431.

Defect: The only discrimination check is "a planted draft full of known tells must score outside every band it should". That exercises `tellgrader` and Vale, which are deterministic and already have their own fixtures (`MEASURES.md`). It says nothing about whether the judge, rubric, assertions, and preference can see a subtle regression. That is the failure ruling 4 guards against. "Every band it should" is also not enumerated, so the check can pass by declaring the inconvenient bands out of scope. skill-creator's analyst warns about "assertions that always pass regardless of skill", and September's explainer assertion is such a case.

Proposed fold: Add a knockout arm to Pass D's baseline run, the eval equivalent of a mutation test. For each surface, run one arm with no output style and no pack (September's bare arm) and one arm with the surface's register file removed but the output style kept. Acceptance: the match rule rejects the bare arm on every surface, and the register-removed arm on every surface whose register carries rules the base model does not follow by default. A surface where a knockout matches is reported as non-discriminating in the PR, and its tasks or assertions are rewritten once before its baseline counts. Name the planted-draft bands explicitly (tells per draft and Vale errors). Cost: about 84 more drafts plus judging in Pass D, roughly 30 minutes.

### 4. The verbatim-move candidate run cannot see the one thing the move changes. Major, correctness

Location: spec lines 216, 330, 331, 399.

Defect: Pass D proves with `cmp` that each pack is byte-identical to its source (line 327). The candidate arm then runs with `--disable-slash-commands`, and "the prompt then names the exact files the arm reads" (line 216). It therefore draws from the same distribution as the baseline arm, and its result is noise: it passes without testing anything, or fails at the rates in finding 2. What the move actually changes is routing: whether a real session, with skills enabled and a natural prompt, follows the `writing-voice` router row or the conventions pointer into `packs/<pack>/pack.md`. No criterion tests that, so a broken pointer, a vendored path that doesn't resolve on one host, or a skill that no longer triggers would pass every Pass D and Pass E check.

Proposed fold: Keep the statistical candidate run for ruling 4, but make the candidate arm natural: Skill tool enabled, the task prompt without file names, run with `--output-format stream-json`. Add a trace assertion per draft: the transcript holds a Read of the surface's pack path (or of its symlinked register path) before the first draft text. Acceptance fails on any surface where fewer than all nine drafts read their pack. The baseline arm runs the same way against the snapshot so the two differ only in the pointer. This also gives Pass E a fixture for "the router and conventions pointers" (line 339), which today has only a byte check.

### 5. Replies, the always-on output style's main use, have no surface. Major, correctness

Location: spec lines 194, 196, 219, 239, 244.

Defect: `core` covers "every context, and replies", but the fourteen surfaces give `core` none of its own. Every reply Claude writes in chat is shaped by the `writing-voice` output style, and no eval task drafts a reply, though `evals.json` already has one (eval 7, register `reply`). A change to `core` "runs all fourteen" (line 219), none of which is a reply, and the monthly grade (line 239) never grades one. Ruling 5 lets an example taken from a correction ship as a minor without asking (line 244), so an example added to `packs/core/` can change every reply on the workstation with no measurement of replies at all. Ruling 4's protection does not reach the most-used surface.

Proposed fold: Add a `reply` surface under `core`, with three fixed tasks (September's eval 7 carries over), making fifteen surfaces and 45 tasks. Every all-surface run includes it, and the monthly scorecard has a row for it. Real reply samples are not in commits, so the real-writing step skips this surface and says so.

### 6. Stored rubric baselines and the monthly rubric trend compare across judge cohorts. Major, correctness

Location: spec lines 217, 220, 241, 242.

Defect: The September notes say rubric means "should be read only within a run". The spec fixes the judge model and rubric (line 220) but compares a candidate's rubric mean against a baseline mean judged in an earlier pass, and the monthly scorecard sets this month's fixed-task rubric mean beside the three before it (line 241), and opens a backlog item on that comparison (line 242). A fixed model does not fix the cohort effect the notes measured: the same judge scored the same old drafts 4.13 in iteration 2 and 4.44 in iteration 3 under a changed prompt, and stochastic judging moves means between runs.

Proposed fold: Keep the baseline *drafts*, not only their scores. Every judging run, in a pass or a month, re-judges the stored baseline drafts in the same batch as the new drafts, and every comparison uses the paired difference within that batch. The scorecard reports each surface's difference from its anchor, with the raw means beside it for reference. Cost is judging only, no redrafting.

### 7. The monthly trend can't tell a Survey change from a model change. Major, correctness

Location: spec lines 216, 220, 239, 241.

Defect: The arms run as `claude -p` with no stated drafting model, so the drafting model follows whatever Claude Code's default is that month. September drafted on Sonnet; a default change moves every fixed-task score, and the scorecard records only the Survey version. The "fixed yardstick" (line 220) covers the judge and rubric but not the drafter or the Claude Code version, and judge models also retire.

Proposed fold: Pin the drafting model with `--model` in the runner, and record in each scorecard the drafting model, the judge model, the Claude Code version, and the Survey version. A change to any of these marks a break, the same way a judge change does, and the run after a break re-judges the anchor set (finding 6) so the trend continues as a difference.

### 8. "Judge agreement with Geoff" is undefined and has too few verdicts to read. Major, correctness

Location: spec lines 221, 241, 243, 247.

Defect: Geoff marks ship, edit, or reject; the judge produces a 1-to-5 rubric and a preference. No mapping between them is stated, so "agreement" can't be computed. Six verdicts a month spread over fourteen surfaces gives fewer than one per surface; a monthly 5 of 6 has a 95% interval of roughly 36% to 100%. Line 247's claim that "Geoff's six verdicts each month show whether the judge still agrees with him" isn't supportable, and Pass D's fourteen (one per surface) only "sets the bar" in a sense no criterion uses.

Proposed fold: Have the judge emit the same ship, edit, or reject verdict for each blind-sample piece, from a stated rubric cut (for example, ship at 4.5 or higher with every assertion passing). Report agreement pooled over a rolling six months (36 or more items) with its count, never per surface, and seed the pool with Pass D's fourteen. State what "sets the bar" means or drop the phrase.

### 9. The corrections loop has no end-to-end acceptance, and its examples can't measurably beat a baseline. Major, correctness

Location: spec lines 219, 244, 357, 400, 447.

Defect: Acceptance stops at intake: each channel's planted item "reach[es] the ledger once" and the dry-run review "writes a scorecard, a viewer page, and a log line". Nothing shows a correction becoming a proposal, being evaluated, and shipping as a pack change. Rulings 5 and 6 promise exactly that. The beat rule then measures an example against the fixed tasks, which say nothing about the corrected wording. One house example rarely moves a nine-draft rubric mean past a band, so distill proposals either fail forever (line 447: "drop it, and keep its corrections for the next run") or pass on the 25% false-beat rate. Either way Geoff's corrections don't demonstrably reach the packs.

Proposed fold: Give each correction a probe: a short task built from its context that would reproduce the wording he corrected, with one assertion that the draft avoids the corrected form. Probes live in `evals/<pack>/corrections/` in the private ledger's sanitized form, outside the fixed tasks, so the yardstick in line 220 is untouched. An example beats when it raises the probe pass rate (paired, as in fold 1) and still matches the fixed tasks. Add a Pass F acceptance on a scratch ledger: a planted correction yields a distill proposal naming its id, the proposal runs against the probe and the fixed tasks, the verdict lands in the log, and a passing example opens a scratch PR. Contestable point: this reads "beat its context's baseline" (ruling 5) as "beat on the corrected behavior while matching the fixed tasks"; it is a method call, not a reopening.

### 10. The beat rule plus a ratcheting baseline lets accepted noise drift the system down. Major, correctness

Location: spec lines 219, 220.

Defect: Beat passes on *either* a rubric rise past one standard deviation *or* 60% preference, so false beats arrive at about 25% per attempt or more, and the monthly distill makes many attempts. "An accepted improvement becomes its surface's new baseline", and the other measures need only match a loose band (finding 1). A sequence of noise-accepted changes, each allowed to lose up to one standard deviation on the other measures, moves the baseline down with nothing that compares against the original.

Proposed fold: Require beat on one named measure (an interval wholly above zero) and non-inferiority on the rest, per fold 1. Keep the Pass D baseline drafts as a permanent anchor beside the moving baseline, and have every monthly scorecard report each surface's difference from that anchor; a surface below its anchor's non-inferiority margin opens a backlog item even if it matched each step.

### 11. The real-writing sample is unselected, often empty, and grades Geoff's edits. Major, correctness

Location: spec lines 89, 240, 242.

Defect: "Up to five Claude-written pieces per surface" names no selection rule, so the session can pick its best five. Several surfaces (Svelte and Python comments, help dialogs, interface text, approval briefs on a quiet month) will often have zero pieces, and "real-sample mean fell two months running" is undefined at zero and pure noise at one or two. The pieces are read as shipped: a post Geoff corrected in the cairn editor, or a doc he edited in review, is partly his writing, which line 89 puts out of scope and which inflates the trend exactly when his corrections are working.

Proposed fold: Sample with a seed recorded in the scorecard, uniformly among eligible pieces. Grade the blob at Claude's own commit, not the file at head. Report a real-sample mean only when a surface has at least three pieces, pool by quarter otherwise, and fire the two-months rule only on reported means.

### 12. The private-ledger rule never escalates but has no test. Major, correctness

Location: spec lines 231, 444, 463.

Defect: "An example ships only from a correction whose source repo is public" is listed among the rules that "never escalate", but no gate or fixture checks it. The distill session decides it by reading a record field.

Proposed fold: Each house example in `examples/house.md` carries its ledger record id and source repo. The survey gate checks every source repo against a public-repo list resolved with `gh repo view --json visibility` at release time, and fails on a private or unknown one. Pass F's scratch-ledger dry run plants a private-source correction and asserts it appears in no proposed example.

### 13. Both hosts can grade the same month. Minor, correctness

Location: spec lines 235, 238, 443.

Defect: `model-review.timer` runs on both hosts with `OnCalendar=monthly`, `Persistent=true`, and `RandomizedDelaySec=1h`. Step 2 checks origin for this month's scorecard before grading, but grading takes far longer than an hour, so the second host also finds no scorecard and grades 126 drafts again. Both then write `scorecards/<YYYY-MM>.md`, and line 443's "Records never share a file" does not hold for scorecards.

Proposed fold: Before step 3, push a claim file `scorecards/<YYYY-MM>.claim` naming the host; a host whose push of the claim is rejected, or that finds one already, harvests and stops. Add the race to Pass F's dry-run acceptance with two scratch clones.

### 14. The drop trigger misses slow decline and partial months. Minor, correctness

Location: spec lines 242, 446.

Defect: The backlog item fires only against last month, so a decline smaller than one step each month never fires. A month graded once per task (line 446) is compared as if it were a three-run month.

Proposed fold: Compare against the anchor (finding 10) as well as last month, and skip the trigger on a scorecard marked partial.

### 15. Three measures are ambiguous or unstable on short surfaces. Minor, correctness

Location: spec line 218.

Defect: "no higher than the baseline mean plus one" doesn't say plus one what; the brief and the restructure record read it as one standard deviation, the sentence reads as one unit. Tells per 1,000 words on a 40-word commit message turns one tell into 25, so the measure's spread is dominated by length. Vale errors on a baseline with none give a band of zero under the deviation reading.

Proposed fold: Measure tells and Vale errors per draft, compared under fold 1's fixed margin, and keep tells per 1,000 words only as a pooled trend figure.

### 16. Pair formation, position, and ties in the blind judge are unstated. Minor, correctness

Location: spec line 217.

Defect: September alternated which arm was A by eval to cancel position bias (iteration 1 notes) and had no tie option. The spec says only "blind".

Proposed fold: Pair drafts by task and run number, alternate positions within each surface, allow a tie, and record all three in `benchmark.json`.

### 17. Harvester acceptance has positive fixtures only. Minor, correctness

Location: spec lines 229, 230, 357.

Defect: The harvester must find a planted comment, note, edit, and draft-and-save pair, but nothing checks what it must skip. The session keeps "only those about wording", an untested judgment. The probe skipped a volunteer's save, but acceptance doesn't keep that case.

Proposed fold: Add negative fixtures: a comment about scope or code, a send-back note about a missing test, a volunteer's cairn save, and a cairn save on a page with no `Survey-Draft` trailer. Each must produce no wording record.

### 18. Pass F's dry run doesn't exercise the drop trigger or the distill order. Minor, correctness

Location: spec lines 242, 244, 357.

Defect: Ruling 7's "a context that drops opens a backlog item, and the distill step works on the lowest-scoring contexts first" has no fixture.

Proposed fold: Seed the scratch ledger with a prior scorecard that puts one surface well above this run's result. The dry run must print the `log-issue` item it would open, carrying numbers and no quoted text, and its distill log must take the lowest-scoring surface first.

### 19. "Keep the old files until the new path has run cleanly" has no exit test, and Pass E contradicts itself. Minor, correctness

Location: spec lines 62, 269, 339.

Defect: No line says what "run cleanly" means or when old files may go. Line 339 says the workstation PR "deletes nothing", while line 269 moves the conventions skills' comment sections out to the packs, which removes them from the skills.

Proposed fold: State that the snapshot under `evals/baseline/<commit>/` is the kept copy and the skills' sections are replaced by pointers, and define "run cleanly" as one monthly review with no surface below its anchor, after which a cleanup line in a later minor may retire anything left.

### 20. The chat route's real-world recall is unmeasured. Minor, optional

Location: spec lines 228, 357.

Defect: Trigger tests show the route fires on five crafted prompts. Nothing shows how many of Geoff's real corrections in chat get recorded.

Proposed fold: The monthly log line carries the count of chat records per host, so a month of zero is visible. A transcript sweep is possible but not worth its cost now.

## Over-ceremony, ranked by cost

### 21. Re-grading 126 fixed-task drafts every month when nothing changed. Major, optional. OWNER FORK

Location: spec lines 239, 247.

The fixed tasks are rerun at three runs each, every month, on both hosts' schedule, about 126 drafts plus judging. When the Survey version, drafting model, judge, and Claude Code version are all unchanged since the last scorecard, the rerun measures only noise. Ruling 7 asks for "the minimum that gives a trend Geoff can trust".

- Option A (recommended): grade the fixed tasks only in a month when any of the four recorded versions changed, re-judge the anchor set every month (judging only), and grade real samples monthly. The scorecard carries the last fixed-task result forward with its date.
- Option B: grade the fixed tasks monthly at one run per task and quarterly at three.
- Option C: keep the spec as written.

### 22. Fourteen blind drafts in Pass D's packet, one per surface. Minor, optional

Location: spec lines 221, 333.

A single draft per surface tells Geoff little about that surface and gives the judge-agreement figure one item each (finding 8). The read is cheap, so it is worth keeping only if its verdicts feed the pooled agreement and Pass H's order, which fold 8 provides. No change beyond that fold.

## Verdict

Not ready to approve as a contract. Findings 1 and 2 mean ruling 4's "match the baseline" neither catches a real regression on the rubric and assertions (the September bare arm, with no writing system, sits inside the assertion band) nor lets an unchanged system pass all fourteen surfaces more than about 2% of the time. Folds 1 to 3 replace the band with paired non-inferiority at fixed margins and add a knockout fixture that proves the rule can fail. Findings 4 and 5 close the two places an always-on regression goes unmeasured: routing into the packs, and replies. Findings 6 to 11 make the monthly trend and the corrections loop measurable. Finding 21 is the one owner fork.
