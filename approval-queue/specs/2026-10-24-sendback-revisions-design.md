# Approval queue: send-back revisions and the blueprint header

## Brief

A packet you sent back will come back marked as a revision and open with what the session changed in answer to you, and a blueprint will open with its author's background and summary the way a packet does.

Today a resent packet looks like a new one, so you have to remember what you asked for and hunt for what changed. A blueprint opens with a fixed sentence and a few counts, with nothing on why the page exists. The send-back box also scrolls the blueprint on every key you type, and it sits beside a second send-back button that only opens the box.

### What changes

- A send-back from a packet returns your verdicts and ask picks to the session with your note, so it knows exactly which parts you objected to.
- A packet that resends a part you sent back is marked "Revision 2" (or 3, and so on) and opens with a "What changed" section that answers your note, ahead of the plan.
- Each resent PR shows the diff since you sent it back, ahead of its full file list.
- A blueprint or a drafted page opens with the author's title, a background paragraph, and one or two summary paragraphs. The counts it shows today move to a status line under them.
- Typing in the send-back note no longer scrolls the document, and only one send-back button shows at a time.
- A send-back no longer goes out while your last edit failed to save, and it no longer marks a question you answered as "Still open".
- Queuing a blueprint or page prints its link, so the author can tell it is queued.

### If you approve

1. The session plans the pass from this design and hands it to `conductor-approval-queue`, with no step for you before it launches.
2. The executor builds it in three PRs (approval-queue, dotfiles, drafter), and the conductor sends them to you as one packet.
3. Once they merge, every packet resend and every blueprint or page queue has to carry the new sections, and the command refuses one that does not.

### Decide: How the send-back control behaves while the note is open

The bar's "Send back with note" button opens the note, and the note has its own "Send back" button that sends it. Both show while the note is open, which is the confusion you hit.

- While the note is open, the bar's opener hides, so the note's Cancel and Send back are the only controls (recommended)
- Keep both buttons, rename the opener "Write a note", and dim it while the note is open

### Worth knowing

The drafter blueprint skill is being edited right now by `drafter-batch-friction`. This pass edits the same two files, so its drafter PR is cut only after that pass merges. Until the three PRs merge, the skills still describe the old command.

### Standing answers

The run decides these without you. A plan up to 420 path minutes, twice the estimate, goes ahead without a stop. The drafter task starts once `conductor-drafter` has merged the batch-friction PR; if that has not happened when the other tasks are done, the conductor holds the drafter task and sends the other two PRs, and the drafter PR follows in a second packet. When the scroll bug's cause turns out to be in CodeMirror itself, the pass works around it in this repo and files the upstream issue in the backlog.

## Design

Initiative: `approval-queue`. Risk class: `runner`, because the pass edits the `approval-packet` and `blueprint` skills and the approval-brief register. No task touches an `auth-data` path, and nothing in the pass touches a live account. Estimate: 210 path minutes, set from the last two approval-queue passes, which finished at about a third of their planned minutes (PR #5: 153 of 450).

### 1. Packet send-back calls (backlog #13, the packet half)

A packet's reject decision today is `{decision: "reject", note}` (`bin/.local/bin/approval-queue`, `decision_program`). It gains `calls`: one entry per part with the verdict the screen held at send-back, and one per ask with its picked label, or none. The page's send-back already posts the verdict fields, so the server reads them from the post the way `buildApprove` does and stores them in `decision.json`; the command's jq shape check and printed output take the new key. The `approval-packet` skill's step 7 says to fix forward from the calls and the note.

### 2. Revisions (backlog #14, for packets)

When `approval-queue packet` queues a file, it looks in `decisions.jsonl` for the latest `reject` line naming each PR or design ref in the file. The match is by ref, so a resend needs no new id. If one or more refs match, the item records `revises`: the earlier item's id, the head or hash each part had at send-back, and the revision number (one more than the count of earlier send-backs of any of its refs). The earlier item's `decision.json` is still on disk and supplies the note and calls.

A revising packet must carry a `## What changed` section between the description and `## If you approve`. It is a bulleted list that answers the send-back, one bullet per call or point of the note. The command refuses a revising packet without the section, and a non-revising packet with it, exit 2 with a message naming the earlier send-back. The register's packet contract and exemplars gain the section.

On the page, the crumb carries a "Revision N" badge, and the header shows the description, then a "What changed" block: your note from the earlier send-back, closed, then the session's bullets, open. A PR part whose head moved since the send-back shows "Changes since you sent it back" ahead of its file list, from `gh api repos/<repo>/compare/<old>...<new>`, fetched when the packet is queued. When the old head is gone (a force-push), the part says so and shows the full diff. A blueprint or page resend gets the same badge by the same lookup; its replies already answer each comment, so it needs no new section.

### 3. The blueprint and page header

`approval-queue blueprint` and `approval-queue page` take a required `--description <file>`: a Markdown file of two or three paragraphs, a background paragraph and one or two summary paragraphs, checked by the rule `packet.ts` already applies to a packet's description (that check moves into a function both use). The existing `<title>` argument becomes the headline and takes the packet title rule: sentence case, no closing punctuation, at most 80 characters. The fixed headline in `ItemPanel.svelte` goes, and `docLede` becomes the status line under the description. The `blueprint` skill tells the author what the paragraphs cover: the page's reader and job, what came before, and what this blueprint proposes.

### 4. The send-back box

The scroll on each keystroke in `#note` has no direct cause in the code: nothing reads `noteText` but the box. The executor reproduces it in a browser on a long blueprint at 1440px and 500px, traces the cause (most likely scroll anchoring or CodeMirror's height map reacting to the box growing), and fixes it there. The opener follows the `### Decide:` above.

### 5. Riders

- **#18.** `decide` in `ItemPanel.svelte` checks `review.saveFailed` after its flush and refuses with the same announcement `approveDoc` makes.
- **#24.** `prefill()` lists only calls with no answer. The executor finds why an answered question still counts in `openCalls` and fixes the count, which also fixes the bar's "Make N calls" line.
- **#21.** Every kind prints `approval-queue: queued <id> at http://127.0.0.1:<port>/item/<id>` to stderr once queued. Stdout stays the decision JSON alone.

### Files

`approval-queue`: `bin/.local/bin/approval-queue`, `src/lib/packet.ts`, `src/lib/server/items.ts`, `src/lib/server/packet-decision.ts`, `src/lib/components/ItemPanel.svelte`, `src/lib/components/PrView.svelte` (or the packet part detail), the route's server actions, the tests beside each, `tests/`, and `README.md`. Dotfiles: `claude/.claude/skills/approval-packet/SKILL.md` and `claude/.claude/skills/survey/writing/approval-brief.md`. Drafter: `claude/.claude/skills/blueprint/SKILL.md` and `new-page.md`.

### Out of scope

The single `pr`, `design`, and `triage` kinds get no revision handling (two single PRs in the log, against 137 packet PR rows). The `change` kind keeps its fixed headline. The decision lifecycle items (#15, #16, #17, #25) are the next pass, and the anchor items (#23, #26) stay with the docs-system pilots.

### End-to-end check

In a temp state root with `gh` stubbed, as `tests/` already does:

1. Queue a two-PR packet, and send it back with a note and one routine row set to reject. The printed JSON carries the note and both parts' calls.
2. Move one PR's stubbed head and resend without `## What changed`. The command exits 2, naming the earlier send-back.
3. Resend with the section. The page shows "Revision 2", your note, the bullets ahead of the plan, and the moved PR's since-send-back diff.
4. Queue a blueprint with `--description`. The header shows the title, then the three paragraphs, then the status line, and stderr has printed the link.
5. On a long blueprint, open the note and type twenty characters. `window.scrollY` does not change, and only one send-back button shows.

### Pre-flight

None foreseen. The pass needs no sign-in, secret, or browser action from you.
