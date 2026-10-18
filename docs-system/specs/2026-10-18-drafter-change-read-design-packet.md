# This packet approves the drafter change-read design, and approving lets the pass be planned and built without you until its PR.

B2's format test went 0 of 5 because the scoped read blocked on old defects in every section a tweak touched, so this pass makes the read judge the change itself and runs the test again.

## Background
The docs-system initiative makes a page's blueprint the only place an agent changes documentation. B2 merged the blueprint skill, the reminder hook, and a read scoped to changed sections (glw907/drafter#47). Its format test missed the bar: 34 of 37 findings sat on content the tweak never touched. A change read works the way a code reviewer reads a pull request. It sees the whole blueprint for context but blocks only on what the change gets wrong.

## If you approve
1. [session] Merge glw907/initiatives#17, which files the design.
2. [session] Write the plan, review it, and hand it to conductor-drafter, applying the design's standing answers in place of stopping.
3. [you: read the pass's PR packet] Read the pass's PR packet when the conductor sends it.

## Not checked
The read's prompt wording and how drafter builds the diff are left to the plan. A probe settled the one open mechanism: a headless session can't read a skill's own files, so backlog #2 closes with no change.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-18-drafter-change-read-design.md | approve | In B2's format test, 34 of 37 findings sat on content the tweak never touched, and Google's code review standard approves a change that improves the code without requiring old problems fixed first. | The bar stays four of five, and a miss comes back to you before anything else starts. |
| glw907/initiatives#17 | approve | The PR only files the design. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The pass is `runner` class, so its PR comes back to you. | Nothing merges unread. |
| step:3 | you | The conductor sends one packet for the pass. | Your read is the merge. |
