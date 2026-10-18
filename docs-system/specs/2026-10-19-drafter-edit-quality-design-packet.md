# This packet approves the edit-quality pass, which has the blueprint skill read its own edit and fix what the read blocks, then reruns the format test against your new two-part goal.

It carries out your rulings on the Fable analysis and runs after F1.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. The skill-rules pass (glw907/drafter#49) scored 12 of 21 on first-try acceptance. The Fable analysis found the format sound and the misses in editorial judgment, plus two skill defects and some judge noise. You ruled that the goal splits into an offline check that passes first try and a read that accepts the edit in the same session; that the read loop is the default; that the change read blocks only at reviewer grade; and that register rules stay out of blueprint reads.

## If you approve
1. [session] Merge glw907/initiatives#28, which files this design, the analysis, and the goal erratum.
2. [session] Plan the pass (three lenses, the fold, and a verification read), and hand it to conductor-drafter to launch after F1 merges.
3. [you: read the pass's packet] Read its packet with the rerun's result.

## Not checked
Whether the loop reaches 19 of 21 is what the rerun measures. The two `drafter check` warnings are dropped if they fire falsely on cairn's blueprints, which the plan probes.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-19-drafter-edit-quality-design.md | approve | It builds the analysis's recommendation as you ruled it, with the read prompt change made in the chain now and carried into the stock prompt by F2. | The rerun measures it without waiting for F2. |
| glw907/initiatives#28 | approve | The PR files the design, the analysis, this packet, and the goal erratum. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The pass spends API credit, budget $40 of your $200 monthly credit. | Live-account passes take the full review depth. |
| step:3 | you | The pass comes back to you as one packet. | Nothing merges unread. |
