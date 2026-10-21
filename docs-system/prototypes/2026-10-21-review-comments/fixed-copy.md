# Fixed copy on the comments prototype (comments.html)

Screen 1 (first review), lede: "A troubleshooting page for people who run a cairn site and write no code. The fact check read its 46 facts against the code, and the author fixed the six lines it found too broad. Nothing needs your call."
Screen 2 (round after send-back), headline: "The author answered your four comments on the plan for Troubleshoot your site."
Screen 2 lede: "You sent this plan back with four comments. The author made two changes, answered your question, and kept one passage, with a reason. Resolve each reply you accept, or reply to it; a reply goes back with your decision."
"How to change it" disclosure, new paragraph: "To ask the author for a change instead of making it, select the text and choose Comment. Your comments go to the author with your decision."
Editor bar button: "Comment Ctrl Alt M" (title: "Select text to comment on it")
Floating button at a selection: "Comment"
Comment draft card head: "Your comment." ; textarea placeholder "Ask the author for a change, or ask a question" ; buttons "Comment", "Cancel" ; hint "Ctrl Enter to save"
Saved comment card head: "Your comment." then muted "Goes to the author with your decision" ; actions "Edit", "Delete"
Comment whose text was deleted: "The text you commented on is gone from the plan."
Toasts: "Finish the comment you have open first" ; "Save or cancel the comment you have open first" ; "Comment deleted" [Undo] ; "Select the text you want to comment on first"
Approve toast with comments: "Approved. The author applies your two comments, then drafter writes the page. You'll see the replies on the page review."
Send-back panel sub-line: "Your two comments, edits, and decisions go with this note. A note is optional when you've commented."
Send-back toast: "Sent back. The author answers your two comments and queues the plan again."
Thread card heads: "Done. The author made the change." / "Kept. The author left it as it was, and says why." / "Answered. The author answered your question."
Thread body labels: "You commented on: <quote>" ; "You: <comment>" ; "The author: <reply>" ; "What changed" ; your reply "(goes to the author with your decision)" ; buttons "Resolve", "Reply", "Edit", "Delete" ; resolved card "Resolved. <comment>" [Reopen]
Reply textarea placeholder: "Reply to the author"
Review pane headings: "Replies to your comments" ; "Your comments" ; empty state "Select text in the plan, then choose Comment." ; item sublines "Done", "Kept", "Answered", "Resolved", "You replied", "On “<quote>”"
Decision bar status line examples: "One comment, no edits yet" ; "Four replies to read, no edits yet" ; "Three replies to read, you replied to one, no edits yet" ; "Every reply read"
Keyboard sheet: "Comment on the selected text" ; "Next or previous comment" ; "Save the comment you're writing, or approve the plan"
Sample author replies (sample data, voice of a Claude author session):
- "The line now walks from the dashboard to the Worker's Logs tab."
- "I cut the line and kept the link to Log events under it."
- "I kept them as two rows. They share a symptom but not a fix: the first needs nothing, and the second needs the editor to leave the entry. A merged row would need two fixes, and the outline standard gives each row one."
- "No. A hold matches on the check's id alone, so no hold covers a single site. I added that to the fix."

## Review fold (prose-voice-reviewer, round 1)

Taken: the approve toast drops "drafter writes" for "the page is drafted" and moves to present tense; the draft's save button reads "Save"; the hint reads "Ctrl Enter saves"; the screen 2 lede splits into "Resolve each reply you accept, and reply to any you don't. Your replies go back with your decision."; "Kept. The author left it as it was and gave a reason."; the send-back sub-line reads "This note goes back with your two comments and your edits and decisions."; the status segment reads "one reply from you"; both open-draft toasts read "Save or cancel the comment you have open first".

Declined: plus signs between keys, since the approved round-8 frame renders each key as its own `kbd` with no plus; quotation marks around the page title in the headline, since the approved round-8 headline runs the title in unmarked. "Six lines" is the real count from cairn commit `804180084`.

## Round 2 additions (the Docs and Word margin)

Review pane tabs: "Comments <count>" ; "Outline and notes"
Margin empty state: "Select text in the plan, then choose Comment. Your comments appear here, beside the text they’re about."
Saved comment card head: unchanged from round 1 ("Goes to the author with your decision")

Review fold: "Sends with your decision" reverted to the round-1 subline, which names the author and matches the reply label; "show here" became "appear here"; the "Outline and notes" tab carries an amber count when calls are open. The curly apostrophe stays, per the round-8 ledger.
