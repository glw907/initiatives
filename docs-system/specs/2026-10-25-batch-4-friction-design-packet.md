# Batch 4 friction pass design

Batches 4 and 5 of the cairn extend docs filed 27 drafter items (#83 to #109) and six approval-queue items (#40, #44 to #48). Nine extend blueprints are left. A blueprint is a page's plan in markdown that an author agent writes and drafter drafts from, and the Approval Queue is where you review blueprints, pages, and packets. This design clears all of that friction before the last nine start.

It runs two passes side by side, one per repo, and each comes back to you as a separate packet. In drafter, a check of one blueprint fails on an anchorless line pointer in the facts it cites, and the store-wide run keeps warning, as you ruled in chat. New checks catch the procedure slips and the drift the register editor and fact-checker caught by hand. `drafter page --commit` and `drafter brief --sync` remove the hand work after a draft, and the blueprint skill gets its seven fixes. In the queue, page approvals on one PR stop voiding each other, `approval-queue pending` lists approvals whose session ended, and notes can be checked and replaced without a requeue. Approving merges the design and starts planning. Neither pass spends API credit, and neither touches the live drafter or queue while batch 5 is using them. You have nothing to do before launch.

## If you approve
1. [session] Merge the initiatives PR that files this design and its packet.
2. [session] Write both plans under pass-core and hand each pass to its conductor, conductor-drafter and conductor-approval-queue.

## Not checked
The minutes are estimates from recent passes, which finished far under plan. Whether the three procedure warnings fire too often will show on the next blueprints. They are warnings, so a false one blocks nothing.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-25-batch-4-friction-design.md | approve | It covers every item you named in chat ("All of them"), with your ratchet ruling on #84 written in, and a fresh builder check's five questions settled from the code. | Every other call is a method call the design states, and the standing answers keep both passes off API credit and off batch 5's tools. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | Planning runs under the design's standing answers. | The design lists what each run decides without you. |
