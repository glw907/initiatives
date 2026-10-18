# This packet approves the reviewed drafter onboarding design, and approving moves work into the foundations pass and B3 so a new project reaches a drafted page through one documented path.

You asked that setting up drafter be highly ergonomic for a new developer on a new project, and four reviews found the first design promised more than drafter's code could deliver.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. Today drafter still borrows its prompts, agents, gate, and fact checks from cairn and this workstation. A new project builds three pieces with Claude: a facts store, reader tracks on a published style standard, and an outline, driven by an onboarding skill after the developer reads a system overview. The reviews (human and agent ergonomics, contract, mechanics) held 88 findings: 73 are folded, 6 refused with reasons, and the 3 forks you ruled in chat on 2026-10-18. The order stays change-read, F, B3, O, B4, B5, but F grows (tracks, a working `init`, fact verification, a per-page gate, lock seeding, a price table), B3 writes the stock prompts, and O must reach a drafted page in a clean environment.

## If you approve
1. [session] Merge glw907/initiatives#18, which files the design, its four reviews, and the fold record.
2. [session] Add one line to drafter's CLAUDE.md: setting up drafter on a new project must stay ergonomic for a new developer, and nothing a project needs may live only on this workstation.
3. [session] File the owed errata: a status line in the architecture spec pointing at the design's changes table, and F and O added to the B1 plan's build sequence.
4. [session] Finish the change-read plan's review, hand it to conductor-drafter, and add a status line naming the order.
5. [you: read each pass's packet] Read the change-read pass's packet, then the foundations design when it comes.

## Not checked
The foundations pass's size and which outside pages make up the Google corpus are left to the passes that build them. The staged audit (an inventory of the code's surfaces first, each page's behavior facts filed as it's planned) is the design's most contestable call; it's recorded with its reason. The cairn release moves at least one pass later.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-18-drafter-onboarding-design.md | approve | Every product call is one you made in chat on 2026-10-18, including the three forks; its eleven method calls are listed with reasons, and each pass names a fixture and why it fails today. | It amends the architecture spec at the lines its changes table names; each built change (the outline schema, page-type anatomies, required settings, the install and hook) lands in F, B3, or O under its own packet. |
| glw907/initiatives#18 | approve | The PR files the design, the reviews, and the fold record. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The line states your request where every drafter session reads it. | A rule lives where it executes. |
| step:3 | session | The errata are pointers to this design, not rewrites. | Ratified documents stay as they were approved. |
| step:4 | session | The change-read pass adds no setup step and was approved before this design. | It fixes the read under any setup design. |
| step:5 | you | Each pass comes back to you as one packet. | Nothing merges unread. |
