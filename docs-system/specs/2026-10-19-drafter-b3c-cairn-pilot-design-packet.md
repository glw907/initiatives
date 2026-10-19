# This packet approves drafter's B3c design, and approving drafts cairn's eight stage 2b pages without figures and brings them to you in a cairn PR.

It carries out your ruling on whole reads, and it launches once you merge B3 in the morning. Two calls are yours: the budget and how many pages.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. B3 builds drafting tonight on a synthetic page; B3c is the cairn half you split off. cairn's release waits on its docs. A whole read reviews an entire blueprint, and until now each round found something new, so no cairn blueprint was ever accepted. Your ruling makes each later round judge only the earlier findings and the fixes.

## If you approve
1. [session] Merge glw907/initiatives#39, which files this design.
2. [session] Plan B3c tonight (three lenses, the fold, and a verification read), and hand it to conductor-drafter to launch after B3 merges.
3. [you: read the pass's packet] Read B3c's packet with the drafted pages.

## Not checked
How well the chain's prompts draft through drafter's back half on these pages is what the run measures. No cairn page has been drafted this way yet.

## Ask: How much may B3c spend?
Rule: owner-call
Part: none
Recommended: 1
Reason: Eight whole pages at the spike's $3 to $4.50, more for the four long pages, plus read rounds, fit inside $80 with room for one retry each.
Summary: B3c reads and drafts eight cairn pages through the API. $80 covers all eight with a retry each; this month's spend is $24, plus up to $20 for B3.

Background: Each page takes several blueprint reads at about $0.22 each, then one whole draft and its reviews. Four of the pages run 500 to 1,225 lines. Every page also stays under the existing $10 page cap.

Facts: The month has room inside your $200 credit.
- This month's drafter spend is $24.13 (`drafter spend --since 2026-10-01`)
- 97 cairn blueprint reads cost $21.54, about $0.22 each (`drafter spend --since 2026-10-01`)
- A whole page cost $3 to $4.50 in the spike (`docs-system/specs/2026-10-17-blueprint-architecture-design.md`)

Choices:
- $80: drafts all eight with room for a retry each
- $40: likely drafts about half the pages before it stops
- $120: leaves room for a second whole draft of the longest pages

## Ask: Draft all eight pages, or three first?
Rule: owner-call
Part: none
Recommended: 1
Reason: All eight plans are finished, and the probe page stops the line early if the drafting itself is broken.
Summary: The run drafts the smallest page first as a probe, and a probe that escalates stops everything. Behind it, all eight can draft in one night, or three can draft and wait for you.

Background: The pilot criteria turn on unread merges after you accept three pages. Drafting all eight gives you more to read in one sitting; three first lets you judge the prose before more is spent.

Facts: Eight pages qualify.
- Eight of the eleven stage 2b pages carry no figure, and three do (`cairn-cms blueprints/outline.yaml`)
- Rotate the GitHub App key is the smallest, at 158 lines (`cairn-cms docs/extend/rotate-the-github-app-key.md`)

Choices:
- All eight: smallest first, behind the probe
- Three first: a new packet asks before the other five

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-19-drafter-b3c-cairn-pilot-design.md | approve | It builds your whole-read ruling and drafts the pages B3 left out, with cairn staying on its own prompts module until B5. | Moving cairn onto drafter's stock prompts waits for the register split. |
| glw907/initiatives#39 | approve | The PR files the design and this packet. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | B3c builds on B3's code, so it can't launch before B3 merges. | The plan is ready when B3 lands. |
| step:3 | you | The drafted pages come back to you in one cairn PR. | Nothing merges unread. |
