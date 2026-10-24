# Approval queue polish pass

The approval-queue initiative is clearing its backlog in three passes. The first two clear the send-back work and the docs friction before the next cairn docs round. This is the third: the ten review and visual-grade suggestions the earlier passes filed and left, none of which slows the docs work. DaisyUI is the component library the app's screens use.

The board and packet screens will match the approved prototype in the details the build missed. The home-grown parts move to stock DaisyUI where the look allows. A packet part shows its full diff and rendered design, and the review suggestions are applied. Orca, GNOME's screen reader, checks that the notes' buttons are read as buttons, the option you chose in chat. It runs muted on your desktop for a few minutes. Approving merges the design. Planning starts once the docs friction pass merges. The pass is ordinary class, so it merges itself and sends you no packet.

## If you approve
1. [session] Merge the initiatives PR that files this design and its packet.
2. [session] Write the plan under pass-core once the docs friction pass has merged, and launch it from the approval-queue checkout.

## Not checked
The Orca debug log was not tried yet, so whether it shows each announcement is unconfirmed; the design falls back to the accessibility tree if it does not. The 240-minute estimate comes from recent passes, which finished well under plan.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:approval-queue/specs/2026-10-24-polish-design.md | approve | It covers backlog #3 to #8, #10 to #12, and #20, with the Orca check you chose. | Every call in it follows the prototype, the DaisyUI-first rule, or a review finding, and the pass touches no skill. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | Planning waits for the docs friction pass and runs under the design's standing answers. | The design lists what the run decides without you. |
