# drafter skill-rules pass: teach the skill what the read checks in new content

Status: designed 2026-10-18; amended the same day after Geoff sent the first packet back to make
the test able to reach its bar and measure a rate; awaiting his approval. Initiative: `docs-system`. Pass slug
`skill-rules`. It follows Geoff's ruling on the change-read packet ("Teach the skill first",
2026-10-18) and runs before F1.

## Brief

Approving this teaches the blueprint skill the checks the read applies to content an agent adds,
then reruns the format test a third time. The change-read pass (glw907/drafter#48) scored 1 of 5. No
read blocked on old content any more; all four misses were defects in what the agent itself wrote:
example output with no recorded source, a recovery placed before its diagnosis, a caution with no
next step, a teaser heading, `use` lines that restate their fact, and a claim that contradicts its
own section's fact. The read was right each time, and control 1 still caught its seeded defect.

Two blocks came from outside the skill, so the first version of this design capped the score at 3
of 5. Tweaks 4 and 5 also escalated on the consistency read over one pair of facts that conflict in
the test base. Tweak 4's answer listed that conflict with empty `facts` and `with`, which the
fail-closed rule blocks (backlog #6), and tweak 5 cited one of the pair. This pass clears both, and
it runs each prompt three times, because one run per prompt can't tell a skill that usually works
from one that got lucky.

The rules go into drafter's format page, cited from their published sources, never copied from
cairn's register. The approved onboarding design keeps every rule the stock prompts rely on in
drafter's base, and a new project has no cairn register to read.

## Outcome

1. **A self-check in the format page.** A new section, "Check what you add", lists what the
   blueprint read checks in an added or changed item, one rule per line, each linked to its source:
   - An `example` shows only output a fact records; it cites that fact, and never invents output.
   - A `failure` item comes after the diagnosis that tells the reader which failure they have, its
     handler gives the reader's next action, and its symptom differs from every existing row.
   - A caution is a `failure` item with a handler, never a `sentence`.
   - A `heading` names what the section delivers, never a teaser.
   - A `use` scopes its fact and never restates it.
   - In a task section, the checks come before the explanation.
   - A new item agrees with every fact its section already cites.
   Sources: the read's own checklist (`blueprintPrompt`), the Red Hat peer review guide's structure
   checklist, and Google's developer documentation style guide on headings.
2. **The skill walks it.** `SKILL.md`'s "Check" step says to walk that section for each item the
   edit adds or changes, before `drafter check` and the commit. The skill links the section and
   copies no rule.
3. **An empty conflict no longer blocks.** In a change read, a consistency conflict whose `facts`
   and `with` are both empty names nothing to place. It goes to the record as a warning starting
   "Unplaced:" and never blocks; any conflict that names a fact or page keeps today's rule. This
   closes backlog #6's first case.
4. **The base conflict, settled on the test branch.** The executor reads cairn's code for the two
   facts that conflict in the test base, corrects the wrong bullet on the `format-test` branch only,
   and names the defect in the PR body for `conductor-drafter` to file in cairn's backlog (cairn's
   main checkout is never touched by the executor). The rows record that the base moved by that one bullet.
5. **The format test, measured as a rate.** Same base otherwise (cairn `50dc211d9`), same harness,
   the five prompts word for word, plus two new prompts for edit-catalog rows the five don't
   exercise, written by the planner before the skill changes. Each of the seven prompts runs three
   times, each run in a fresh session; the controls run once. The bar is 17 of 21 runs accepted on
   the first try, by the raw count, and control 1 must still draw its blocking finding. The two new
   prompts' rate is reported on its own line, so a skill that only learned the five shows.

## Out of scope

Changing the blueprint read or its prompt. Backlog #6's second case, a re-cited fact in a base
conflict, which the corrected bullet removes from this test and which stays open. Moving
cairn's register rules into the base wholesale, which is F2 and B5.

## End-to-end check

The rerun, recorded as #48 recorded it: each read's blocking findings, and whether each sits on the
change and which new rule it falls under.

## Shape

- Risk class `runner` (the skill, the format page, and the consistency rule in
  `internal/pipeline/blueprint.go`). `live-account`: API credit, budget $20. The last run spent
  $4.52 for seven reads and their sessions; this one runs 23.
- Repos: `glw907/drafter`, plus a throwaway cairn-cms worktree for the test.
- Estimate: 150 path minutes. The change-read pass planned 275 and ran in 26.

## Standing answers

- A plan up to 300 path minutes proceeds.
- A format test below 17 of 21 closes the pass with the result; F1 then starts as the packet's
  ask decides.
- A read that blocks on an untouched item, or an escalation from backlog #6, is recorded and
  doesn't stop the test.
