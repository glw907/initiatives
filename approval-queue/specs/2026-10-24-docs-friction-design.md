# Approval queue: the docs friction pass

## Brief

The approval-queue friction the docs work has logged will be gone before the next cairn docs round: a session can withdraw, defer, or collect an item, an agent's browser can no longer take your tab, note anchors survive edits, and a small fix to an approved blueprint comes back as a short amend review.

The extend-blueprints pilots and batch 2 logged each of these as friction, and the backlog holds them as #1, #2, #9, #15 to #17, #19, #22, #23, #25, and #26. This is the second of three passes that clear the backlog. The send-back revisions pass comes first, and a polish pass (#3 to #8, #10 to #12, #20) follows with no deadline.

### What changes

- A session can withdraw its own queued item with `approval-queue withdraw <id>`, and the item leaves the board.
- You can defer an item. The session hears "defer" and is free to end, and the item waits under "Deferred" on the board until you decide it.
- A decision on an item with no session waiting (a deferred one, or one whose session died) is kept, and a later session picks it up and logs it with `approval-queue collect <id>`. The board marks an item whose session is gone.
- A new item opens in your browser only. An agent's browser that polls the queue no longer counts as your tab.
- A note can anchor on its own text, the way a comment does, so splitting a bullet no longer moves later notes, and a line in a reader block can carry a note. `approval-queue anchors <file>` prints a blueprint's heading anchors.
- When an author changes a blueprint or page you already approved, it comes back as an amend review: the diff since your approval, with the unchanged text folded away.
- Four bugs are fixed: a held decision's blocked Undo (#19), "Next call for you" missing on a long blueprint at phone width (#9), a damaged packet file answering an error page (#2), and a packet fingerprint that misses a rebound ask (#1).

### If you approve

1. The session plans the pass once the send-back revisions pass has merged, and hands it to `conductor-approval-queue`.
2. The executor builds it in up to three PRs (approval-queue, dotfiles, drafter), and the conductor sends them to you as one packet.
3. That packet's plan carries one step for you: opening a claim link once in your browser, so the app knows which browser is yours.

### Worth knowing

`drafter-9a` plans a drafter pass that edits `docs/blueprint-format.md`, which documents the note anchors this pass changes. This pass's drafter edits go in after that pass merges, and the conductor checks before it cuts the branch.

### Standing answers

The run decides these without you. A plan up to 600 path minutes, twice the estimate, goes ahead without a stop. The pass launches only after the send-back revisions pass has merged, since both edit `ItemPanel.svelte` and the command. The drafter task waits for any open drafter PR that edits `docs/blueprint-format.md` or the `blueprint` skill to merge; if one is still open when the other tasks are done, the conductor sends the approval-queue and dotfiles PRs, and the drafter PR follows in a second packet. If the slug rule chosen for #26 would change a heading anchor some existing notes file uses, the command accepts both spellings for those notes.

## Design

Initiative: `approval-queue`, with the docs-system initiative as the reader of the outcome. Risk class: `runner`, because the pass edits the `approval-packet` and `blueprint` skills. No task touches an `auth-data` path or a live account. Estimate: 300 path minutes, set from the send-back revisions estimate of 210 for a smaller scope and from recent passes finishing at about a third of plan.

### 1. The decision lifecycle (#25, #16, #15, #17)

`item.json` records the waiting command's pid when the command queues. `approval-queue withdraw <id>` sends that pid TERM, so its exit trap withdraws the item as it does today, and it removes the item itself when the pid is gone. Only an undecided item can be withdrawn.

The board marks an item whose recorded pid is no longer running: "No session is waiting for this." Geoff can still decide it. `approval-queue collect <id>` waits for the item's `decision.json`, then logs and prints it exactly as the queuing command would have. It takes everything it needs from the item directory, so any session can run it. A second `collect` of one decision prints it again and logs nothing.

Defer is a third outcome beside approve and send-back, on every kind but triage. The waiting command prints `{"decision":"defer","id":"<id>"}`, exits 0, and leaves the item queued. The board shows it under "Deferred". When Geoff decides it later, the decision waits for `collect`. The `approval-packet` and `blueprint` skills say a session that gets "defer" records the id in its STATUS and ends.

A tab counts as Geoff's only when it carries the claim cookie. A `/claim` page sets that cookie, a long-lived and `HttpOnly` cookie on `127.0.0.1`, and only polls that carry it touch `tab.seen`. While no tab is claimed, the command opens a tab for each new item, as it does when no tab is live. The close packet gives Geoff the claim link as a `[you]` step.

### 2. Note anchors (#23, #26)

A note's `anchor` may be the comment anchor's shape, `{quote, prefix?, suffix?}`, placed by the same steps the README gives for comments. The quote can sit on any line, a reader-block line included. The `<slug>.heading` and `<slug>.p<n>` strings stay accepted, so notes files written before the change still load. The `blueprint` skill moves authors to the quote form for every note below a heading.

`approval-queue anchors <file>` prints one line per heading: its anchor, then its text. The slug rule takes the rule cairn uses for a published heading's id, so a note's anchor and the page's link agree. The executor reads that rule from cairn's source and records it in the README with an apostrophe example.

### 3. The amend review (#22)

When `approval-queue blueprint` or `page` queues a file whose ref already has an `approve` line in `decisions.jsonl`, the item is an amend review. The header says what changed since the approval, written by the author in the `--description` the send-back revisions pass adds. The editor folds every unchanged run of lines and opens on the diff since the approved blob, with each changed line marked. The approve and send-back JSON keep their shapes and add `amends: <approved blob>`. Notes and comments work as they do on a full review.

### 4. The bugs (#19, #9, #2, #1)

- **#19.** When the open-box guard cancels a held decision's Undo, the toast says why the reader stayed put, and the restore completes once the box closes. A typed-URL decision on an item already held is refused, with an announcement.
- **#9.** "Next call for you" measures the call's line (CodeMirror's `requestMeasure`) before it scrolls, so the call lands in view on a long document at 500px.
- **#2.** An item whose `packet.json` does not parse answers 404 with the withdrawn message, and the board names it as unreadable. A post to `reject` or `submit` that is not a form answers 400.
- **#1.** `packetFingerprint` adds each part's lane and each ask's rule and bound part.

### Files

`approval-queue`: `bin/.local/bin/approval-queue` (`withdraw`, `collect`, `anchors`, the pid, defer, the claim check), the server under `src/lib/server/` (`items.ts`, `packet-decision.ts`, the board's listing), `src/routes/` (a `claim` route, the item actions), `src/lib/editor/notes.ts` and `setup.ts`, `ItemPanel.svelte`, the board page, the tests beside each, `tests/`, and `README.md`. Dotfiles: `claude/.claude/skills/approval-packet/SKILL.md`. Drafter: `claude/.claude/skills/blueprint/SKILL.md`, `new-page.md`, `docs/blueprint-format.md`, and `claude/.claude/workflows/docs-page-chain.js` where it writes notes.

### Out of scope

Carrying a ruling across items automatically (Geoff chose the amend review on 2026-10-24). The polish items, which are the third pass. Any change to how a packet is resent, which is the send-back revisions pass.

### End-to-end check

In a temp state root with `gh` stubbed, as `tests/` already does:

1. Queue a blueprint, then `withdraw` it. The command exits, and the item is gone from the board.
2. Queue a blueprint and defer it. The command prints the defer line and exits 0. Approve it on the board, then `collect` it: the approve prints, and one line lands in `decisions.jsonl`. A second `collect` prints it again and logs nothing.
3. Queue an item, kill its command with KILL, and load the board. The item shows "No session is waiting for this."
4. With the claim cookie in one browser context and a second context polling without it, queue an item. The command treats the claimed tab as the live one, and the unclaimed poll does not touch `tab.seen`.
5. Queue a blueprint whose notes use a quote anchor on a reader-block line and a `p<n>` anchor. Split a bullet above the second and requeue: the quote-anchored note stays on its line.
6. Approve a blueprint, change one clause, and requeue it. The page opens as an amend review on the changed line, with the rest folded.

### Pre-flight

None. The claim step comes after the merge, in the close packet.
