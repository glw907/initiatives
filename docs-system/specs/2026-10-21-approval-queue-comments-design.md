# Comments on approval-queue's document reviews

Status: designed with Geoff on 2026-10-21 over eight prototype rounds, and he approved the prototype
("Design complete"). Initiative: `docs-system`. The prototype is
`prototypes/2026-10-21-review-comments/`, and `round-6-spec.md` there holds the weight and motion
rules. The pass builds on glw907/approval-queue#4 as merged. The troubleshooting blueprint review and
drafter's reviewed-pages pass wait on it.

## Brief

Approving this adds editor-style comments to the blueprint, page, and change reviews, built to
the Google Docs model you shaped in the prototype, and gives every decision five seconds to undo
while the next item opens.

You asked to be able to leave notes the way an editor does in Docs or Word, not only change the
text. The troubleshooting blueprint is the first review that needs them.

### What changes

- Selecting text with the mouse opens a comment box in a margin beside the page. Ctrl+Alt+M or a Comment button works for a keyboard selection, and Escape keeps the selection so you can edit it instead.
- Every annotation is a card in that margin, level with its text: fact-check notes, the choices waiting on you, your comments, and the author's replies. The blueprint, page, and change screens drop the right-hand review pane, and the outline moves into the rail under the open item.
- Your comments go to the author with either decision. On a send-back, the author answers each one as Done, Kept, or Answered and queues the item again. On an approve, the author applies them before the next step: drafting a blueprint's page, or merging a page or change. A blueprint's replies show on its page review.
- Only you resolve a thread. A comment whose text was rewritten or removed stays visible with its original quote.
- Every decision opens the next item at once, and Undo stays in a toast for five seconds while the decision posts.
- The screens take the prototype's visual weights and motion, and the rail widens on wide screens.

### If you approve

1. The session plans the pass unattended, hands it to the approval-queue conductor once PR #4 has merged, and tells conductor-drafter the pass name and plan path.
2. The pass builds the prototype in approval-queue, checked against its renders with `visual-fidelity`, and hands you one packet.
3. Once you approve that packet, conductor-drafter resumes the reviewed-pages pass, and the troubleshooting blueprint reaches you with comments on.

### Standing answers

The run settles these five on its own, without stopping for you:

- A plan up to 600 path minutes, twice this design's estimate, goes ahead. Past that it stops.
- If PR #4 merges with changes, the pass builds on `main` as it stands. It stops only if the change alters an outcome here.
- Where the prototype and the app's data model disagree, the data model wins, and the PR's `## Decisions` names the difference. Everywhere else the prototype wins.
- When the decision path's diff-reviewer returns `fix`, the run fixes it and asks for a fresh read. A cause that returns after one structural fix is escalated in the PR, and the run goes on.
- A render that fails `visual-verifier` loops through a fix and a fresh verifier until it passes.

## Scope

Interfaces, in glw907/approval-queue:

- A comment is `{id, text, anchor}`. The anchor is `{quote, prefix, suffix, from, to, commit}`, the W3C Web Annotation model's text quote selector plus offsets, with 32 characters of context on each side as Hypothesis uses. A new `editor/comments.ts` maps ranges through edits within a sitting. On a re-queued item, it re-places each anchor by these fallbacks in order: the offsets if the quote still matches, then the quote with its context, then the quote alone nearest its old offset, then unplaced.
- A comment writes to `comments.json` in the item's state directory when it is saved, through a new `comment` form action. A reload keeps it, and nothing reaches the author before the decision.
- The approve and reject JSON for the `blueprint`, `page`, and `change` kinds gains `comments` (the new ones) and `threads` (`{id, reply}` for each reply Geoff wrote). A thread with no reply from him is resolved at the decision. The command's jq program prints both, and `decisions.jsonl` records the count.
- The three queue forms take `--replies <file>`, a JSON list of `{id, status, text, quote, anchor}` with `status` one of `done`, `kept`, or `answered`. The README documents this contract for the author's side.
- New `Margin.svelte` and `CommentCard.svelte`. `NoteCard.svelte` renders in the margin. `ReviewPane.svelte` stays on the packet, PR, design, and triage screens only. The rail outline goes in `+layout.svelte`. Below 1260px the margin becomes a drawer.
- `ItemPanel.svelte` and `hold.ts` keep the hold in a layout-level store, so it outlives the change to the next item. Closing the tab within the five seconds still undoes the decision.
- `frame.css` takes the weight levels and motion tokens, which stay local until cairn-themes #1 moves them into Survey.

Out of scope, for "Later": comments on packets, PRs, designs, and triage lists; fuzzy re-anchoring; the `blueprint` skill's handling of comments, which the reviewed-pages pass writes against the README contract; the Survey motion tokens (cairn-themes #1).

## Check, class, and cost

End-to-end check: a test over a fixture blueprint posts a comment through the UI and sends the item back. The command prints the comment with its anchor. The item comes back with `--replies` after an edit that moves the text, and each reply shows on its re-placed card, with a removed passage shown as gone. An approve prints the answered threads, and an Undo within five seconds sends nothing.

Risk class: `runner`, as the reviewed-pages plan classes the approval tool. The decision path (the jq program, `items.ts`, `server/blueprint.ts`, the item route's form actions, `hooks.server.ts`) gets a task-scope `diff-reviewer` read beside the gate. Not `live-account`, since there's no API spend.

Estimate: 300 path minutes. Recent approval-queue passes ran at a fifth to a third of their plans (#2: 105 actual against 540; #4's lane: 181 against 610), and this pass is about half the size of #4's approval-queue lane.

Pre-flight: none for you. The launch waits on PR #4's merge, which you decide in its own packet.
