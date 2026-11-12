# Rebuild the Approval Queue so every item is one document its session wrote

Today the Approval Queue builds each page from a fact file, a second writer's text, and a form with fixed headings. You called the result sloppy, and the first document you found useful to read was one a session wrote straight through. This design makes that the only way. The session that did the work writes one Markdown document and asks its questions where they come up, and the queue shows that document on one kind of page. The pages follow the mockup you called solid.

The same rebuild fixes the approve you lost on 2026-11-12. The server records your click when you make it, and the page changes only after the decision is on disk.

Approving this packet merges nothing. Together with the workstation design, it starts a round of six passes after the weekly usage reset on 2026-11-13, 11pm Anchorage time. The first five passes build the new queue beside the one you use, and they merge without a packet, because nothing you use changes. The sixth pass prepares the switch and stops with its pull request open. You then read one close packet, in the old queue, and approving that packet makes the switch. That close packet also carries the workstation's skill changes, which are a separate design. The first pass waits for one small fix that the workstation design carries: the check a conductor runs before each launch counts the session that runs it. If you approve only this design, nothing starts until that fix has your approval some other way. If you send this design back, nothing runs, and I revise it from your notes.

You have one question to answer: how long a merged pull request stays on the front page. The recommended answer is seven days. Four more choices were made for you. They are listed under "Decided for you".

## Deep dive

The design describes the document, the pages, how a decision is recorded, the command, and the six passes that build them.

### What a document is

A document is a GitHub Flavored Markdown file with a short header. The header names the kind of document: pull requests to merge, a design to approve, questions only, or a report with nothing to decide. For pull requests, the header lists them in merge order, each with a few plain words that the page shows with the number. Two header lines say in one sentence each what the session does after an approve and after a send-back, and the page prints them on the two buttons.

Below the header come a title, a first paragraph that is the whole page made small, and the rest of the document. The page draws every form in the GitHub Flavored Markdown specification, tables and task lists among them, and the mockup now has one page that shows each form: http://127.0.0.1:7933/d/markdown. Footnotes, alerts, mathematics, and diagrams are features of GitHub's website that the specification leaves out, and the queue shows them as plain text. A question is a marked block under the paragraph that asks it. The block holds two to six options, and at most one is marked as recommended. The page draws the options as buttons where the block sits.

For a design, the design file is the document. There is no separate packet text and no fact file.

### What the queue refuses

The queue refuses a document only for a fault that would break the page or a merge. Examples are a missing title, a question block with one option, and a pull request that is closed or has a failing check. What a document says, and how well it says it, stays with the workstation's skill, so the writing can improve there without a change to the queue.

### The pages

The front page has three sections: Outstanding decisions, Reports, and Recently merged PRs. The last one groups merges under each tool's name, with one sentence for each pull request.

Every page uses one layout. A left rail lists the three sections, the main column holds the front page or a document, and a notes margin sits to the right of every document. The main area has no bottom bar. A page never shows an item id, a round id, or a pull request number without its plain words. Every string a page shows lives in one file, copied from the mockup, and a changed or added string goes through the writing process before it merges.

### How a decision is recorded

On 2026-11-12 the queue held your approve in the browser for five seconds to allow an Undo, hid the item at once, and then failed to post it. Nothing told you. The design changes the order of events:

- The page posts a click when you make it. The page changes only after the server answers that it wrote the decision to disk.
- Undo is a button on the decided document. The queue hands a decision to the waiting session 20 seconds after it records the decision, and Undo works until that hand-off. The page says whether the session has the decision yet.
- When the server cannot be reached or refuses, the document stays open. A message replaces the buttons and says what was not recorded and why, with a "Try again" button. The message does not fade.
- An approve records the commit of each pull request, or the hash of the design, as you read it. The merge command checks every pull request before it merges anything. If one has moved, it merges nothing and says which one.
- When a document has questions, the approve button is disabled until each question has an answer, and the unanswered questions are named beside it.

### Notes and returned documents

A note is a thread beside the passage it is about. You and the session can both add entries, and each entry is signed and timed. A session can answer in a thread or start one, and a thread that a session starts without being asked is labeled as the session's.

When a document comes back after a send-back, the queue compares it with the version you read and marks the difference. Removed words are struck through and added words are underlined, as Word or Google Docs would mark them, and a switch hides the marks. The session writes no change marks.

### The command

One TypeScript file replaces the bash command, which is 1,124 lines. The new command has nine verbs: `check`, `send`, `collect`, `withdraw`, `notes`, `reply`, `merge`, `land`, and `restart`. It uses the same document library as the pages, so one parser decides what a document is.

### What goes away

The old queue's code, its fact files, and its decided items go. The decided items are kept in one archive file, and no page shows them.

### The six passes

The round runs in the `glw907/approval-queue` repo. The new code is built in a directory named `next/`, and the old app and the old command keep running until the switch.

1. The document library, the store, and `check`. Planned at 120 minutes. This pass runs first because it carries the least-proven assumption: that the five real documents from the mockup parse as written, and that the queue can mark changes without the session's help.
2. The command. Planned at 120 minutes.
3. The layout, the front page, and the document page, read-only. Planned at 120 minutes. A fresh grader compares screenshots of each page with screenshots of the mockup at 1440 px and 390 px, in light and dark. This pass also blocks remote images in a document and renders straight quotes as curly ones, two leftovers from the workstation's backlog.
4. Decisions and `merge`. Planned at 120 minutes. The tests include an approve with the server stopped.
5. Notes threads and returned documents. Planned at 100 minutes.
6. The switch. Planned at 75 minutes. It deletes the old app and the bash command, moves the new code into their place, and closes thirteen backlog items.

The second and third passes run at the same time and share no file. The longest chain of passes is planned at 535 minutes.

If weekly usage reaches 85 percent, the pass in flight finishes and nothing new starts. If a pass finds that the mockup and the design disagree, the mockup wins for anything seen on a page and the design wins for anything else.

### What the design leaves out

The design changes nothing on the workstation. The skill, `pass-core`, the hooks, and the settings belong to the other design. It also leaves out a page for old decided items, phone layouts beyond not breaking at 390 px, and search, filters, and keyboard shortcuts beyond ordinary tab order.

### What was checked

One fresh Opus reader read this design and the workstation design against the queue's code and the workstation's skills. It returned fifteen findings. The session settled each one itself, and none needed your answer. The round needs no new permission rule, no sign-in, and no secret.

## Your calls

The one call sets how the Recently merged PRs section of the front page behaves.

### How long does a merged pull request stay on the front page?

Context: The front page lists each merged pull request under its tool's name. The mockup listed merges "since yesterday". The design says a fixed window is simpler to reason about than one that depends on when you last looked.

Risk: With seven days, a line drops off the page after seven days whether or not you read it, and the store keeps it. With "until you mark the section as read", lines pile up until you clear them, and the page needs one more button. With "since the previous day only", a merge is never listed if you did not open the queue within a day of it.

Recommendation: Seven days.

## Decided for you

### Where is the new queue built while you keep using the old one?

Context: The round builds the new queue in a directory beside the old app. The first five passes merge without a packet. Each one lands after its gate run passes and a whole-branch review accepts it, and you see one sentence per merge.

Why: Nothing you use changes until the sixth pass. Building in place would change the queue you approve with five times, and each pass would need a packet.

### How does an approve reach the session, given the one that was lost?

Context: The server records the decision first and hands it to the session 20 seconds later. Undo works for those 20 seconds, and the page says when the session has the decision.

Why: The other option keeps the decision in the browser for the Undo window, as today. That behavior lost your approve on 2026-11-12. With the new order, the decision is on disk for the whole wait, so the wait cannot lose it.

### What happens to the old queue's decided items?

Context: They go into one archive file, `~/.local/state/approval-queue/archive-2026-11.tar.gz`, and the new queue starts empty. The `restart` command writes the archive only after the new server answers.

Why: You said you don't need to look at old decided packets. To show them read-only, the new code would carry a reader for every old item shape.

### What is the command written in?

Context: The command is written in TypeScript and shares the document library with the pages. The bash command is retired at the switch.

Why: One parser decides what a document is, for the command and for the page. With a bash command, the command and the pages would each parse a document, and they could disagree.

## Not checked

- No pass has parsed the five real documents with the planned library. The mockup's parser did parse them, and the first pass parks if the library cannot.
- Vale has not read this design, because the house configuration excludes the folder that holds this record. `tellgrader` under the docs register reports nothing.
- The queue's repo runs no CI, so each pass's gate run is the only automated check.
- Edits were made to the design after the fresh reader's check. No second fresh reader read those edits.
