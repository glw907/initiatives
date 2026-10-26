# Docs improvement loop design

The docs-as-code system (cairn's `cairn-docs` skill, its fact-checker agent, and its path rules) shipped with one round of evals and no way to keep improving. An eval is a scripted test of how Claude sessions behave. On 2026-10-26 the first evals' scores misled twice, because their queries described changes that don't exist in the repo. Today's fix to the skill's wording (glw907/cairn-cms#148) was proved only with a hand-built test.

The design adds a monthly loop built on Anthropic's evals guidance and Hamel Husain's error-analysis method. A session reads up to 30 real cairn sessions, finds where the docs process first went wrong in each, and sends you one triage list, which takes you about ten minutes. Each failure you confirm becomes a failing eval case first, then a fix, and a fix merges only when the before-and-after numbers show it helps without breaking anything else. Approving merges the design and starts planning the pass. Everything runs on the subscription with no API credit. One question is open: how many eval sessions a single run may use. The session recommends a cap of 120.

## If you approve
1. [session] Merge the initiatives PR that files this design and its packet.
2. [session] Write the plan under pass-core and run the pass in cairn-cms and the workstation.

## Not checked
The session counts are estimates. The first full suite run will measure them.

## Ask: Cap each eval run at 120 sessions?
Rule: owner-call
Part: glw907/initiatives:docs-system/specs/2026-10-26-docs-improvement-loop-design.md
Recommended: 1
Reason: Three trials per case per arm is the fewest that shows consistency, and 120 leaves room for a rerun of a noisy case.
Summary: A change to the skill runs about 90 short Sonnet sessions and a monthly cycle about 45, all counted against your subscription's usage limits. A cap of 120 covers both with room for one rerun.

Background: Each eval case runs three times per version, because one run can't tell a real change from noise. The runs use headless Claude sessions on your subscription, so they share your usage limits with your own work, and no API credit is spent. The runner refuses a run over the cap unless it is told to go past it.

Facts: The counts follow from the seed cases and the trial count.
- About 15 seed cases, run 3 times for each of 2 versions (`docs-system/specs/2026-10-26-docs-improvement-loop-design.md`)
- Today's rename test took 10 sessions of about 25 turns each, with no API key (`glw907/cairn-cms#148`)

Choices:
- Cap at 120: a change PR fits with room for one rerun, and a monthly cycle fits easily [approve]
- Cap at 60: halves the usage, so a change PR runs with two trials or fewer cases and noise shows more often
- Send back: you name a different budget

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | Planning follows pass-core, and the design names what the builder decides. | A fresh builder check's five questions are settled in the design text. |
