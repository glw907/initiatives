# Send-back revisions and the blueprint header

The approval-queue initiative puts each hand-over in front of you in Design & PR Approvals. You asked for four refinements in chat: a resent PR that is plainly a revision and leads with its response, a fix for the send-back note that scrolls a blueprint as you type, one send-back button in place of two, and a blueprint that opens the way a packet does. You agreed to add backlog items #13, #14, #18, #21, and #24 because they touch the same code.

A packet send-back will return your verdicts with your note. A resend is then marked "Revision 2", opens with a "What changed" section that answers you, and shows each PR's diff since you sent it back. A blueprint or page opens with its author's title, background, and summary, and its counts move to a status line under them. One call is yours: the session recommends hiding the bar's opener while the note is open, so the note's own Send back is the only one showing. Approving merges the design and starts planning. The pass then runs unattended and comes back as one packet, with nothing for you to do before it launches.

## If you approve
1. [session] Merge the initiatives PR that files this design and its packet.
2. [session] Write the plan under pass-core and hand the pass to conductor-approval-queue.

## Not checked
The cause of the scroll bug is not yet found; the executor reproduces it in a browser first. The 210-minute estimate comes from two recent passes that finished well under plan.

## Ask: Hide the bar's send-back opener while the note is open?
Rule: owner-call
Part: none
Recommended: 1
Reason: Only one control then sends the item back, and the note's Cancel already closes it.
Summary: With the note open, the bar's "Send back with note" sits beside the note's "Send back". Hiding the opener leaves one send-back button on the screen.

Background: The bar's button only opens the note. The note's own button sends the item back, so two buttons with nearly the same label show at once.

Facts: Both buttons render while the note is open.
- The note's Send back button sits in the note's actions (`approval-queue/src/lib/components/ItemPanel.svelte:1029`)
- The bar's opener renders whether or not the note is open (`approval-queue/src/lib/components/ItemPanel.svelte:1036`)

Choices:
- Hide the opener: while the note is open, its Cancel and Send back are the only controls
- Keep both: the opener is renamed "Write a note" and dimmed while the note is open

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:approval-queue/specs/2026-10-24-sendback-revisions-design.md | approve | It covers your four refinements and backlog #13, #14, #18, #21, and #24, and the drafter edit waits for the batch-friction pass to merge. | The scope is the one you agreed in chat, and the standing answers cover every stop the run can foresee. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | Planning runs under the design's standing answers. | The design lists what the run decides without you. |
