# Survey's cairn theme, design pass G3

The theme garden gives cairn a catalog of house themes. G1 and G2 built the theme contract, Waymark's port, the viewer, and the theme check, and packet B ruled that Survey's design pass, G3, is planned now. Today's sitting covered the pages Survey's 2026-10-07 references never showed: the post page, the nine directives, the archive and 404 pages, and the phone width. You approved all five mockup screens, two options (map detail and ink), a two-part collar, and leaving out the index rail.

Approving starts the plan. The design session closes the naive builder's Survey PR and writes the plan. It then hands G3 to `conductor-cairn-cms`, which launches it after setup-tooling pass 3's dependency sweep. One executor builds `themes/survey/`, fixes backlog #412 (an option value losing when no light/dark cookie is set, which Survey's map-detail option would hit), and adds a weekly check for changes to Survey's tokens. A fresh grader compares every page at five widths, light and dark, and all four option combinations until it passes. You read once, at the end, with the renders beside the mockups. The estimate is 800 path minutes, and no step needs you before then.

One call changed after the builder check. Survey stays out of the setup catalog until design step 4, because a second catalog entry makes agent-mode `cairn new` demand `--site-theme` and breaks the scaffold test in the middle of the setup-tooling run. Step 4 already owns that change.

## If you approve
1. [session] Close glw907/survey#10 with a comment pointing to this design.
2. [session] Write the G3 plan with its pre-flight list and standing answers, and have it reviewed. Its first task lands the backlog verdicts.
3. [session] Hand the plan to `conductor-cairn-cms`, which launches G3 once setup-tooling pass 3's T3.5 sweep has merged.

## Not checked
The #412 fix is described, not probed. The plan's review probes it on the fixture theme before launch. Revision purple's contrast was measured on the page grounds and its button, not yet as a focus ring on every ground. The grader checks it.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:theme-garden/specs/2026-11-09-theme-garden-3-survey-design.md | approve | Every question in it is your ruling from today or a call settled from the code, and the builder check's four questions are folded in | Its sweep, estimate, and pre-flight are all present |
| step:1 | session | survey#10 is the naive build the theme-garden design says doesn't carry forward | A closed PR can be reopened |
| step:2 | session | The plan follows the G1 and G2 plan's shape | Its review runs before the hand-off |
| step:3 | session | Theme-garden launches hold during the T3.5 sweep | The conductor runs both initiatives |
