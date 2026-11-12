---
kind: design
repo: glw907/approval-queue
sent: 2026-11-12T12:40
approve: I plan the rewrite and bring you nothing more until a pass stops or the work is done.
sendback: Nothing is planned. I answer each note and send the design back to you.
mock: I wrote this short draft to show how a design looks on the new page. Approving it starts nothing. The real design reaches you as a separate document after you have seen the mockup.
---
# Rebuild the Approval Queue around one kind of page, a document?

Approving this design starts a rewrite of the Approval Queue. Today the queue has a separate page, with separate rules, for each of packets, designs, triage lists, reports, and digest lines. After the rewrite it has one page, and that page shows a document. A session writes the document as one Markdown file and marks the questions in it. The queue shows it with the notes margin beside it. The design leaves you one question, about the workstation's freeze, and I recommend its first option.

**The workstation's skills are frozen to removals until 2026-12-11, except for the overhaul of the pass process. Is this rewrite part of that overhaul?** The rewrite replaces the `approval-packet` skill and shortens `pass-core`, so it adds text as well as removing it. If it isn't part of the overhaul, the freeze forbids those additions. The skills have to change when the queue does. A session that follows the old skill would send a packet the new queue can't read.

:::question The removals-only freeze
- **Count the skill changes as part of the overhaul**, so they land with the rewrite. {recommended}
- **Hold everything until 2026-12-11.** The queue stays as it is until then, with the lost-approve bug (backlog #71) still in it.
:::

:::decide

## What you would see when it is done

- Every page has the same layout: the list on the left, the document in the middle, and the notes margin on the right.
- A question sits in the text where it is asked, with its options under it.
- An approve is recorded the moment you click it, and the page says so. Undo is a button on the page for as long as the session hasn't acted.
- A document you sent back returns with its changed passages marked and a reply under each of your notes.
- A report and the list of pull requests merged without you take notes the same way a packet does.

## What goes away

The fact file, the separate writer, the fixed outline, and the checks that enforce the outline all go. So do the five-second hold on a decision and the pages for retired kinds of item. The 437 items in the queue's state directory move to an archive folder on disk, and no page shows them.

## Calls I made

You didn't ask for any of these. Leave a note on one to change it.

- The queue checks a document before it sends it, and refuses it only for a fault that would break the page or a merge.
- An approve stays tied to the commits you read. If a pull request changes after the document is sent, the page says so and the approve is refused.
- The 1,124-line shell command becomes a handful of commands: check a document, send it and wait, merge, record a merge made without you, and reply to notes.
- The queue changes to the new form in one step. At no time does it accept both the old packets and the new documents.
