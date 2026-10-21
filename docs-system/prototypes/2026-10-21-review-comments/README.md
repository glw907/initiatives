# Review comments prototype (2026-10-21)

Editor-style comments on approval-queue's document reviews, built on the approved round-8 frame in `../2026-10-20-review-screens/`. Geoff reviews it round by round; nothing is built before he approves the set.

- `comments.html`: the blueprint review screen with comments. Screen 1 is the first review: select text, then choose **Comment** in the floating button or the editor bar, or press Ctrl+Alt+M. Screen 2 (`comments.html?round=2`) is the same plan queued again after a send-back, with the author's reply under each comment. The rail links both screens. It loads CodeMirror 6 from jsdelivr, as the round-8 file does.
- `troubleshooting.blueprint.md`: real data, cairn's admin troubleshooting blueprint at `5c35c0686`. Screen 1's two fact-check notes come from that blueprint's real fact-check fixes (`804180084`). Screen 2's four comments, replies, and edits are sample data.
- `prior-art.md`: the patterns and pitfalls the design takes from Google Docs, Word, GitHub review, Gerrit, Phabricator, Hypothesis, and the W3C Web Annotation model.
- `fixed-copy.md`: the screen's fixed copy, as read by `prose-voice-reviewer` against the developer-docs register before each round.

Serve the folder and open it in Chromium: `python3 -m http.server 7931 --bind 127.0.0.1` from `prototypes/`, then `http://127.0.0.1:7931/2026-10-21-review-comments/comments.html`.

The design calls in round 1: a comment shows inline under its line, as the fact-check notes and GitHub's review threads do, because the three-pane frame leaves no margin for Docs-style balloons. Comments take the primary hue, the color the changed-lines marker already uses for your own marks; amber stays reserved for calls. A comment is a pending draft until the decision, the way a GitHub review batches its comments. The author answers each one with Done, Kept, or Answered, and only you resolve a thread.
