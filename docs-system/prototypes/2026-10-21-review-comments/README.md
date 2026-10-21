# Review comments prototype (2026-10-21)

Editor-style comments on approval-queue's document reviews, built on the approved round-8 frame in `../2026-10-20-review-screens/`. Geoff reviews it round by round; nothing is built before he approves the set.

- `comments.html`: the blueprint review screen with comments. Screen 1 is the first review: select text, then choose **Comment** in the margin or the editor bar, or press Ctrl+Alt+M. Screen 2 (`comments.html?round=2`) is the same plan queued again after a send-back, with the author's reply on each comment's card. The rail links both screens. It loads CodeMirror 6 from jsdelivr, as the round-8 file does.
- `troubleshooting.blueprint.md`: real data, cairn's admin troubleshooting blueprint at `5c35c0686`. Screen 1's two fact-check notes come from that blueprint's real fact-check fixes (`804180084`). Screen 2's four comments, replies, and edits are sample data.
- `prior-art.md`: the patterns and pitfalls the design takes from Google Docs, Word, GitHub review, Gerrit, Phabricator, Hypothesis, and the W3C Web Annotation model.
- `fixed-copy.md`: the screen's fixed copy, as read by `prose-voice-reviewer` against the developer-docs register before each round.

Serve the folder and open it in Chromium: `python3 -m http.server 7931 --bind 127.0.0.1` from `prototypes/`, then `http://127.0.0.1:7931/2026-10-21-review-comments/comments.html`.

The design as of round 3, after Geoff's rulings ("We're following the Google Docs model"; "There should only be one placement"; "The system should feel like it was designed for the comments from the start"):

- The plan is a page, and its comment margin sits directly beside it. The page and margin are centered together as one unit between the queue rail and the window edge, the way a Docs page and its comment column are. The round-8 right pane is gone.
- Every annotation is a card in that margin, level with its text: the fact-check notes, any calls, your comments, and the author's replies. The text carries only highlights. Selecting highlighted text brings its card forward, and selecting a card darkens its text.
- A selection shows a **Comment** button in the margin, level with the selection. The editor bar has one too, and Ctrl+Alt+M works.
- One sticky place bar spans the unit. It shows the current section, the next call, and **Contents**, the outline menu. One decision bar spans the unit, because the comments go with the decision.
- Below 1260px the margin becomes a drawer that lists the same cards, opened from the place bar's **Comments** button or by tapping a highlight.
- Comments use the primary hue, the color the changed-lines marker already uses for your own marks. Amber stays reserved for calls and teal for the fact check's corrections.
- A comment is a pending draft until the decision, the way a GitHub review batches its comments. The author answers each one with Done, Kept, or Answered, and only you resolve a thread.
