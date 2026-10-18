# Drafter ergonomics pass: the change read

Status: designed 2026-10-18, awaiting Geoff's approval. Initiative: `docs-system`. The pass the
B2 plan's standing answer 2 names after a missed format test. B3 waits on it. Pass slug
`change-read`.

## Brief

Approving this changes the scoped read so it judges the change itself, as a code reviewer judges a
pull request. A defect that was already in the blueprint gets reported but no longer blocks a small,
correct edit. Then the B2 format test runs again with the same five prompts and the same bar.

B2's format test went 0 of 5. Every tweak passed `drafter check`, and every scoped read answered fix.
34 of the 37 findings sat on content the tweak never touched. The scope was a whole section, so a
small edit inherited every old gap in that section (glw907/drafter#47, drafter#43). A pre-existing
consistency conflict also came back on four of the five reads.

## Why this rule

Google's code review standard asks a reviewer to look at the change in its whole context ("Sometimes
you have to look at the whole file to be sure that the change actually makes sense") and to "favor
approving a CL once it is in a state where it definitely improves the overall code health." It
rules out a change that degrades the code, and sends existing problems to a bug ("encourage the
author to file a bug"). Sources: <https://google.github.io/eng-practices/review/reviewer/standard.html>,
<https://google.github.io/eng-practices/review/reviewer/looking-for.html>.

The backlog weighed two rules: scope the read by item, or drop findings already present at the
base. Matching findings across two reads is unreliable, since B2's reads gave the same defect
different severities. So the read gets the diff and judges it, and no second read runs.

## Outcome

1. **The change read.** With `--since <rev>`, drafter sends the whole blueprint for context, plus
   the change since `<rev>`: the blueprint's diff, the diff of each fact bullet it places or cites,
   and the outline entry's diff. A finding blocks only when it is a defect in what the change adds or
   alters, or a defect the change causes elsewhere. A finding caused elsewhere is located at the
   changed item that causes it. Every other defect the reader sees is reported as non-blocking and
   marked as already present. A page-level change no longer makes the read whole, since the diff
   shows it. The read is whole only when the blueprint is absent or undecodable at `<rev>`. An
   unchanged page still makes no API call.
2. **The consistency read under `--since`.** A conflict blocks only when it involves a fact the
   change placed, cited, or edited. Any other conflict is reported as already present.
3. **Two skill fixes from the format test.** Before an agent corrects a fact, the skill sends it to
   `drafter refs` (backlog #3). A caution about something that can go wrong is a `failure` item with
   a handler, not a `sentence` (backlog #4). Both link to the format page and copy no rule.
4. **The format test, run again.** Same base (cairn `main`), same harness (B2's, including its grant
   of the skill directory), the same five prompts word for word, and the seeded control. The bar is
   still four of five on the first try, by the raw count. The control must still draw a blocking
   finding at the seeded step.

Backlog #2 (a headless agent can't read the skill's format page) closes with no change. A probe on
2026-10-18 showed a headless session in accept-edits mode is denied a read even of a real file
inside a user-scope skill's own directory. That denial comes from the harness, and live agents run
interactively. The format test's harness already grants the directory.

## Out of scope

Writing the lock on a change-read accept stays B3's. drafter won't recompute the verdict from the
findings' locations. If the format test shows a blocking finding on an untouched item, that goes to
"Later" with the evidence. Backlog #5 (the hook reading `blueprints.root`) is also out.

## End-to-end check

The rerun of the format test, as Outcome 4 describes. The PR records each read's blocking findings
and whether each sits on the change.

## Shape

- Risk class `runner`: the read's workflow prompt and the skill. `money.go` and `resume.go` stay
  untouched, and a change to either stops the line.
- `live-account`: yes, for API credit. Budget $10. B2 spent $4.46.
- Repos: `glw907/drafter`, plus a throwaway cairn-cms worktree for the test.
- Estimate: 120 path minutes. B2 planned 530 and ran in about 60; B1 planned 780 and ran in about
  240.

## Standing answers

The planner applies these in place of stopping.

- A plan up to 360 path minutes proceeds.
- A format test below four of five closes the pass with the result. The PR's packet then asks
  Geoff what comes next, and no further pass starts on its own.
- A read that blocks on an untouched item is recorded and doesn't stop the test.
