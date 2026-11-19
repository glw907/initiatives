# Why the desk round stopped for you, and what cc-desk should change

The desk round lost about five hours to three stops. None of them asked you something that was yours to decide, and you answered all three with the recommended option. Two stops came from a rule that compares two forecasts and ignores what passes really take. The third came from a landing test that reads a reviewer's word and not whether a call for you exists. cc-desk as designed today would repeat all three, and in two cases it would handle them worse. The fixes are small. Most of the saving comes from two edits to `pass-core` that can land today and three changes to cc-desk that belong in the Move round's design.

Where a claim below is my inference and not in the files, I say so.

## What the clock shows

Times are Alaska time on 2026-11-18, from commit and pull request times.

| Stop | From | To | Minutes |
| --- | --- | --- | --- |
| The skills pass parks on its estimate | 2:07 PM, the draft opens | 3:05 PM, the first build commit | 58 |
| The skills pass waits to land | 3:56 PM, the conductor asks | 6:07 PM, the merge | 131 |
| The desk pass parks on its estimate | 6:50 PM, the draft opens | 8:50 PM, your ruling is committed | 120 |

The report says you answered the two estimate questions within about 18 and 15 minutes. The rest of those two waits was the trip from your answer back to a running session: about 36 minutes the first time, and about 105 the second if the report's 7:05 PM is right. That gap is an inference from commit times.

## 1. Root causes

**The two estimate stops.** `round.md` "Parking at planning" says: "The plan's path comes out over twice the design's estimate for the pass." The round plan's standing answer 14 repeats it: "It parks." Three things are wrong with that rule.

First, it compares a forecast with a forecast. The plan's path is not what a pass takes. Nine pull requests in this repo record both figures. Their plan paths add up to 1,405 minutes and their measured time to 355, about a quarter. Some of those measured figures leave out planning time, so the true share is higher, but nowhere near the whole. The skills pass planned 170 and built in 50. The records pass planned 209 and took 107 against an estimate of 120. The page pass planned 170 and took about 90 against an estimate of 90. The design's estimates were close to the truth. The plan paths were the wrong number, and the rule trusted them.

Second, the warning was already on file. In the two rounds before this one, twelve passes have both an estimate and a plan path. The paths ran 1.5 times the estimates on average, and three passes came within a hair of parking: 175 against 90, 115 against 60, and 150 against 75. The design for this round didn't read those figures. `planner.md` "Design" asks for it: "The estimate is in path minutes, set from the actual-against-planned path in recent scores."

Third, the process already asks for the answer you gave later. `planner.md` "Stops" says: "The design's approval asks how to answer each stop the run can foresee, including an estimate overrun up to a named ceiling." The round plan named no ceiling. Standing answer 28 is that ceiling, written after two stops.

The stop also protected nothing. Weekly usage went from 5 to 8 percent over three passes.

**The landing wait.** Two texts produced it. The design ordered the skills ahead of the desk they describe: "The desk follows the skills, since the session it opens loads one." The builder check caught the same fault once, for the verbs ("the first order had the skills written before the verbs they name"), and missed it for the desk's behavior. Then `round-run.md` "Reading a pass" lands a pull request only when "`Review:` reads `accept, open findings 0`". The skills pass read "escalate, open findings 0" and "Calls: none". Nothing was open and nothing was yours, but the test reads the word.

That wait held up the desk pass because of one more line. `round-run.md` says "A pass that builds on another starts once that pass's PR is ready, whatever its verdict." The round plan replaced it with "Pass 3 starts when pass 2 has landed", and the plan wins over the reference.

**The two bodies sent back.** The landing test is a session reading prose. The rules for that prose sit in four places: `round-run.md` "Evidence", the miss tags, the round plan's gate item, and the voice guide. The page pass even used a tag, `[check]`, that isn't one of the ten. Nothing checks a body before the conductor reads it.

**The refused stop.** The stray job wasn't one the round launched. The round's auto mode entry says no session "acts on a session cc-desk did not launch". The refusal was right. No rule said what to do with a session nobody owns.

## 2. Changes to cc-desk

**Keep the estimate and the plan's path as two figures, and stop on neither.** A pass has one figure today, `planned_minutes` in `internal/state/types.go`. Add `plan_path_minutes`, written by a new `pass planned` verb when the plan is committed. The estimate keeps driving the forecast, since the pace already corrects it from real minutes. The page shows both figures in the report's folded part. Cost: one field, one verb, one line on the page. Risk: you lose the early sign that a plan grew. The next change covers that.

**Ask about scope, not size.** `pass planned` takes `--scope same|grew`. A plan that adds an outcome the design doesn't name, or drops one, reports `grew` and becomes a question. This is the same honest report `pass ready --design inside|outside` already takes. Cost: one flag and one branch. Risk: a session reports `same` wrongly, and the closing review is the backstop, as it is for `inside`.

**Ask the budget once, as a release field.** How far a round may run past its plan is your call. Ask it one time at the design's approval, with a recommendation, and store it on the release. The check enforces it from measured minutes: past the limit it starts nothing new and says so. Cost: one field and one rule in `internal/state/rules.go`. Risk: a pass that really runs away is caught later than at planning. The idle limit, the relaunch limit, and the usage stop still bound it.

**Give standing answers a record.** You closed all three stops by giving a standing answer: 26, 27, and 28. cc-desk has nowhere to put one. A ruling answers a question, and launch prompts are fixed text. Add a list on the release: each entry is your words, the date, and the ruling it came from. The desk records one when you say "from now on". Every launch prompt for that release prints the list, and the release's page shows it. Cost: one field, one block in the templates, one paragraph in the desk skill. Risk: an answer outlives the round it was meant for, so each one names a round or the whole release.

**Teach `pass ready` the third verdict.** The reviewer returns accept, fix, or escalate. `internal/state/merge.go` refuses anything but accept or fix, and the working skill offers only those two. A session holding an escalate has no honest line to run. Add a count of calls for you to the ready report. The check then merges when the change is inside the design, every check passed, no finding is open, and no call is yours. An escalated point the advisor settled is filed as a follow-up and named in the report. This is standing answer 26, built in. Cost: one flag, one branch in `internal/sessions/merge.go`, a few lines in `skills/cc-desk-work/SKILL.md`. Risk: a session files a real call of yours as a follow-up. The report lists every such landing, so you see each one after the fact.

**Don't hold the chain behind a merge question.** In cc-desk a pass that comes after an unmerged pass waits. A merge question therefore stops everything behind it until you answer, which is the 131-minute wait again. The main design already has the cure: build on the recommended answer, within your cap of 300 minutes and one pass deep. The state code holds those caps, but this round's design chose "The check doesn't start a pass on a guess." Turn it on for one case: the parent's checks are green and the question's recommendation is to merge. The next pass starts from the parent's branch. Cost: the largest item here, about one medium pass, since a launch must take a branch as its base and merge `main` in later. Risk: you answer "close" and one pass is redone, which is the miss you already said you accept.

**Count working minutes only.** Only `pass stop` opens a stop interval (`internal/state/events.go:352`). From my reading, time spent waiting on a merge question counts as work. That would push the pace up and every forecast late. Subtract it. Cost: small.

**Take misses and calls as data.** The merge no longer reads the body, which removes the send-backs. The conductor still has to scrape each body for the report. Let `pass ready` take a small file of calls and tagged misses. Cost: small.

**Show sessions nobody owns.** The check lists a session in a project's checkout that no record names, and the page says so in words. Only the desk ends one, on your word. Cost: small.

## 3. Changes to pass-core

These are workstation edits, separate from section 2.

1. `round.md` "Parking at planning": drop the twice-the-estimate bullet. Park for a scope change or for "What always stops". Change the matching lines in `planner.md` "Design" and "Launch".
2. `planner.md` "Stops": a design that answers an overrun with "it parks" isn't ready. Add that to the builder check's questions in `round.md`.
3. `round.md` "What a round design adds": the pass table shows each estimate beside the last ten passes' estimate, plan path, and measured minutes, so the unit is visible.
4. `round-run.md` "Reading a pass": land on no open finding, no call, and green checks, whatever the verdict's word. That makes answer 26 the default.
5. `round.md` ordering rules: a pass that describes behavior comes after the pass that builds it. Where it can't, its acceptance says the reviewer reads those claims against the design.
6. `round.md`: a round plan may not replace "starts once that pass's PR is ready, whatever its verdict".
7. `executor.md`: one body template and one script that checks the four lines, the acceptance items, and the miss tags before the executor reports. Add `[check]` to the tags or refuse it.

## 4. What to do when

Ranked by time saved in this round against the work to make the change.

| Change | Where | Work | Would have saved |
| --- | --- | --- | --- |
| Drop the estimate stop | `pass-core`, now | Minutes | 178 minutes |
| Land on findings and calls | `pass-core`, now | Minutes | 131 minutes |
| No plan may undo run-ahead | `pass-core`, now | Minutes | Most of the 131, by another route |
| The third verdict in `pass ready` | cc-desk, before the Move design | A small pass | The same 131, under cc-desk |
| Body template and check | `pass-core`, now | Under an hour | Two send-backs |
| Standing answers as a record | Move design | A small pass | Every repeat of a stop |
| Two figures, the scope flag, the budget field | Move design | A small pass | The estimate stops, under cc-desk |
| Working minutes only | Move design | Small | Forecast accuracy |
| Build past a merge question | Move design | A medium pass | The wait when a call really is yours |
| Sessions nobody owns | Move design | Small | One refusal |

The third verdict should not wait for Move. The real run at the end of this round goes through `pass ready`.

## 5. What will repeat next round

- cairn's 45 passes carry estimates in the old unit. Two of four plans in this round came out past twice their estimate, and three of twelve in the rounds before came within 10 percent. If the rule survives into Move, expect a stop every few passes. That rate is my inference from those counts.
- A parked plan has no shape under cc-desk. The launch prompt says "Plan the pass first, then build it" and loads `pass-core`, whose planner reference says to park with a draft pull request and end. The working skill gives five stop reasons and none is an estimate. My inference: the session ends, the check sees an idle session with an unfinished pass, relaunches it twice, and shows "Needs you now" with a last line and no choices.
- `pass ready` has no line for an escalate, as section 2 says.
- A merge question stops the chain, as section 2 says.
- The skills are pinned at a tag. A fix to what sessions are told needs a tag, a pull request on the workstation repo, and an install. Mid-round answers such as 26 to 28 can't reach a running release without the standing-answer record.
- Nothing measures the failure test the main design sets. The main design calls it a failure when "a page asks him something a competent architect would decide alone". All three stops did that. The report's folded part should count questions you answered as recommended with no discussion, and the next design writer should read that count and propose a standing answer for each.

## Where I differ from the conductor's read

I agree that both estimate stops were foreseeable, that the escalation followed from the pass order, and that the fix belongs in cc-desk as well as the process. I agree with its estimate rule on the release.

I disagree with its first cause. It says the round plan priced too low and should price "from its done items' evidence", as the planners do. The measurements say the reverse. The round's estimates landed near the real minutes, and the planners' clause-by-clause paths ran two to four times over. Raising estimates to match plan paths would make cc-desk's forecast about twice too late until the pace corrected it. The fault is the rule that treats the gap as a reason to stop.

I would not build its second part, a signal after the first pass that asks you once for the whole round. With the stop gone there is nothing to ask. The pace already carries the first pass's ratio into the forecast.

I go further in four places it doesn't reach: the third verdict missing from `pass ready`, the chain held behind a merge question, standing answers having no record, and waiting time counted as work.
