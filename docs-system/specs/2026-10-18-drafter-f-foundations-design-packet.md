# This packet approves drafter's foundations design, and approving builds the setup pieces a new project needs as two passes that run without you until each packet.

The onboarding design you approved today put a foundations pass before B3, and its scope is too large for one pass.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. The onboarding design (glw907/initiatives#18) listed F's pieces and its acceptance table. This design splits them: F1 is setup and checks in plain Go (`drafter init`, config defaults and a dated price table, `drafter gate --page`, fact verification ported from cairn, lock seeding for existing pages), and F2 is the prompt mechanism and reader tracks. It records your two rulings from chat: F1 launches after change-read merges whatever its format test scores, and each plan launches unattended within twice its estimate.

## If you approve
1. [session] Merge glw907/initiatives#20, which files this design.
2. [session] Plan F1 when the change-read pass merges, review it (mechanics lens and fold), and hand it to conductor-drafter.
3. [session] Plan F2 when F1 merges, and hand it over the same way.
4. [you: read each pass's packet] Read F1's packet, then F2's.

## Not checked
The estimates (240 and 200 path minutes) come from B1 and B2 running well under plan; each plan sets its own figure. F2's prompt module is placeholder text until B3 writes the stock prompts.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-18-drafter-f-foundations-design.md | approve | Its scope and acceptance are the onboarding design's F, split in two with nothing added. | The split keeps the prompt-contract work apart from plain Go, so each pass is reviewable. |
| glw907/initiatives#20 | approve | The PR files the design and this packet. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | You ruled F1 runs either way and plans launch within twice the estimate. | Standing answers replace a stop. |
| step:3 | session | F2 builds on F1's config defaults. | It can't start sooner. |
| step:4 | you | Each pass comes back to you as one packet. | Nothing merges unread. |
