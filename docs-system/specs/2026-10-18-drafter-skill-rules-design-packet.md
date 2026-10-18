# This packet approves the skill-rules pass, which teaches the blueprint skill what the read checks in new content, and asks whether F1 waits on its result.

You chose "Teach the skill first" on the change-read packet, so this small pass runs before F1.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. The change-read pass (glw907/drafter#48) fixed the read: no edit was blocked for an old defect. Its format test still scored 1 of 5, because four agent edits added content the read rightly blocked, such as invented example output and a caution with no next step. This pass adds a short "Check what you add" section to drafter's format page, each rule cited from a published source, has the skill walk it before committing, and reruns the test. F1's plan is written and in review, waiting behind this pass.

## If you approve
1. [session] Merge glw907/initiatives#22, which files this design.
2. [session] Plan the pass (mechanics lens, fold, and verification read), and hand it to conductor-drafter.
3. [you: read the pass's packet] Read its packet with the rerun's result.

## Not checked
Whether the rules alone lift the score is what the rerun measures. Backlog #6 (an unplaceable consistency answer blocks) still escalates the base conflict on two tweaks; the test records it.

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
| glw907/initiatives:docs-system/specs/2026-10-18-drafter-skill-rules-design.md | approve | It carries out your "Teach the skill first" ruling with the same base, prompts, and bar as the last two runs. | The rules land in drafter's base, as the onboarding design requires. |
| glw907/initiatives#22 | approve | The PR files the design and this packet. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The pass is live-account, so it takes the full review depth. | The rerun spends API credit. |
| step:3 | you | The pass comes back to you as one packet. | Nothing merges unread. |
