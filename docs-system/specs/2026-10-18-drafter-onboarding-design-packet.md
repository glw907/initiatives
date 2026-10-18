# This packet approves the drafter onboarding design, and approving changes the build order so a new project can set drafter up through one documented path.

You asked that setting up drafter be highly ergonomic for a new developer on a new project, and today a new project can't start without pieces that exist only on your workstation.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. The architecture spec left setup to sub-project 5, so drafter still borrows its prompts, agents, gate, and fact checks from cairn and this workstation. This design records your rulings from chat on 2026-10-18. A new project builds three pieces with Claude: a facts store, reader tracks with Diátaxis modes, and an outline. A Claude Code onboarding skill drives that, after the developer reads a system overview. Every track writes to a standard package drafter ships for Google and Microsoft, the house register is an optional overlay, introductions become part of drafter's base, and foundations come before B3.

## If you approve
1. [session] Merge glw907/initiatives#18, which files the design.
2. [session] Add one line to drafter's CLAUDE.md: setting up drafter on a new project must stay ergonomic for a new developer, and nothing a project needs may live only on this workstation.
3. [session] Finish the change-read plan's review, hand it to conductor-drafter, and add a status line naming the new order.
4. [you: read each pass's packet] Read the change-read pass's packet, then the foundations design when it comes.

## Not checked
The foundations pass's size, the stock gate's exact contents, and which outside pages make up each stock corpus are left to the passes that build them. The cairn release moves about one pass later, which you accepted in choosing foundations first.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-18-drafter-onboarding-design.md | approve | Every product call in it is one you made in chat on 2026-10-18, including the optional register, the standard package, and the stock corpus, and its four method calls are listed at its end. | It amends the architecture spec without changing anything that has been built. |
| glw907/initiatives#18 | approve | The PR only files the design. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The line states your request where every drafter session reads it. | A rule lives where it executes. |
| step:3 | session | The change-read pass adds no setup step and was approved before this design. | It fixes the read under any setup design. |
| step:4 | you | Each pass comes back to you as one packet. | Nothing merges unread. |
