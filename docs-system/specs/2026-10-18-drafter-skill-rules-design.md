# drafter skill-rules pass: teach the skill what the read checks in new content

Status: designed 2026-10-18, awaiting Geoff's approval. Initiative: `docs-system`. Pass slug
`skill-rules`. It follows Geoff's ruling on the change-read packet ("Teach the skill first",
2026-10-18) and runs before F1.

## Brief

Approving this teaches the blueprint skill the checks the read applies to content an agent adds,
then reruns the format test a third time. The change-read pass (glw907/drafter#48) scored 1 of 5. No
read blocked on old content any more; all four misses were defects in what the agent itself wrote:
example output with no recorded source, a recovery placed before its diagnosis, a caution with no
next step, a teaser heading, `use` lines that restate their fact, and a claim that contradicts its
own section's fact. The read was right each time, and control 1 still caught its seeded defect.

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
3. **The format test, run again.** Same base (cairn `50dc211d9`), same harness, the same five
   prompts word for word, both controls. The bar is still four of five by the raw count, and
   control 1 must still draw its blocking finding.

## Out of scope

Changing the read, its prompt, or the bar. Backlog #6 (an unplaceable consistency answer blocks),
which escalated tweak 4 and 5's base conflict: the format test records it as it did in #48. Moving
cairn's register rules into the base wholesale, which is F2 and B5.

## End-to-end check

The rerun, recorded as #48 recorded it: each read's blocking findings, and whether each sits on the
change and which new rule it falls under.

## Shape

- Risk class `runner` (the skill and the format page). `live-account`: API credit, budget $10.
  The last run spent $4.52.
- Repos: `glw907/drafter`, plus a throwaway cairn-cms worktree for the test.
- Estimate: 90 path minutes. The change-read pass planned 275 and ran in 26.

## Standing answers

- A plan up to 180 path minutes proceeds.
- A format test below four of five closes the pass with the result; F1 then starts as the packet's
  ask decides.
- A read that blocks on an untouched item, or an escalation from backlog #6, is recorded and
  doesn't stop the test.
