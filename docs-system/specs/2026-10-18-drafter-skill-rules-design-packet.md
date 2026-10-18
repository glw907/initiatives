# This packet approves the skill-rules pass, which teaches the blueprint skill what the read checks in new content, and asks whether F1 waits on its result.

You chose "Teach the skill first" on the change-read packet, so this small pass runs before F1.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. The change-read pass (glw907/drafter#48) fixed the read, but its format test scored 1 of 5: four agent edits added content the read rightly blocked, and two of them also hit a fact conflict already in the test base. You sent the first version of this packet back because it couldn't reach its bar. This version teaches the skill the read's rules for new content, stops an empty consistency answer from blocking, corrects the conflicting fact on the test branch, and runs seven prompts three times each, two of them new, against a bar of 17 of 21.

## If you approve
1. [session] Merge glw907/initiatives#22, which files this design.
2. [session] Plan the pass (mechanics lens, fold, and verification read), and hand it to conductor-drafter.
3. [you: read the pass's packet] Read its packet with the rerun's result.

## Not checked
Whether the rules alone lift the score is what the rerun measures. Which fact of the conflicting pair is right is settled by the executor against cairn's code, on the test branch only.

## Ask: Does F1 wait for this pass's score?
Rule: owner-call
Part: none
Recommended: 1
Reason: F1 builds setup and checks in Go and touches none of the skill or the read, so the score can't change it.
Summary: F1's plan will be ready when this pass merges. Choose whether F1 launches then whatever the rerun scores, or waits for your call on a miss.

Background: You ruled earlier today that F1 launches after change-read whatever its test scored, then put this pass ahead of F. The two rulings leave open whether a miss here holds F1.

Facts: F1 and this pass share no code.
- F1's plan touches config, `drafter check`'s fact verification, `drafter init`, `drafter gate`, and lock seeding, and its plan is in review (`docs-system/specs/2026-10-18-drafter-f-foundations-design.md`)
- This pass touches the skill and one section of the format page (`docs-system/specs/2026-10-18-drafter-skill-rules-design.md`)

Choices:
- F1 launches when this pass merges, whatever it scores: setup work keeps moving, and a miss comes to you as its own question
- F1 waits for your call if this pass misses the bar: nothing starts after a miss until you rule

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-18-drafter-skill-rules-design.md | approve | It carries out your "Teach the skill first" ruling on the last run's base and prompts, plus two new prompts, three runs each, and a $20 budget. | The rules land in drafter's base, as the onboarding design requires. |
| glw907/initiatives#22 | approve | The PR files the design and this packet. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The pass is live-account, so it takes the full review depth. | The rerun spends API credit. |
| step:3 | you | The pass comes back to you as one packet. | Nothing merges unread. |
