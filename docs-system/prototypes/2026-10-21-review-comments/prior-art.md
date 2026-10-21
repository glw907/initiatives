# Prior art for review comments (2026-10-21)

A survey of how editors and code review tools handle anchored comments, run before the first prototype round. Each line names its source.

## Patterns the design takes

1. Comments are pending drafts that publish together with the decision. GitHub's "Start a review" holds comments until "Submit review" (<https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/commenting-on-a-pull-request>), and Gerrit publishes drafts with the reply (<https://gerrit-review.googlesource.com/Documentation/user-review-ui.html>).
2. The anchor stores several selectors: the quote with about 32 characters of prefix and suffix, the offsets, and the commit. The W3C Web Annotation model calls offsets alone "very brittle" and recommends several selectors for one target (<https://www.w3.org/TR/annotation-model/>).
3. Across rounds, the anchor is found again through ordered fallbacks: the offsets checked against the quote, then the quote with its context, then a fuzzy match. This is Hypothesis's order (<https://web.hypothes.is/blog/fuzzy-anchoring/>).
4. Within one sitting, CodeMirror maps each range through every edit (<https://codemirror.net/docs/ref/#state.ChangeDesc.mapPos>).
5. A comment that can't be placed shows with its quote struck through, in a place the reviewer sees. Hypothesis once hid such comments and users thought them lost (<https://web.hypothes.is/blog/showing-orphaned-annotations>).
6. Threads render as cards in a margin beside the text, level with their anchors, as Google Docs and Word place comments. Round 1 tried GitHub's inline threads under the line, and Geoff found them awkward.
7. The author's reply is typed, after Gerrit's Done and Ack: Done (changed it), Kept (no change, with a reason), or Answered (a question).
8. Only the reviewer resolves a thread. GitHub teams wait for the reviewer to confirm an author's resolve (<https://graphite.dev/guides/resolving-comments-conversations-github>), and Gerrit users asked that an author's Done leave the thread open (<https://groups.google.com/d/msgid/repo-discuss/9d89b24d-2120-462b-aeb0-b865a8c6ebd8%40googlegroups.com>).
9. Ctrl+Alt+M or a button at the selection opens one draft at a time, Ctrl+Enter saves it, and an empty draft closes without saving. Word allows one open draft and posts with Ctrl+Enter (<https://support.microsoft.com/en-US/Word/using-modern-comments-in-word>); Docs and Word both use Ctrl+Alt+M (<https://support.google.com/docs/answer/179738>).
10. The highlight is a mark with `aria-details` pointing at its comment, the comment takes `role="comment"`, and keys move between comments, since screen readers announce "has details" without always letting users reach them (<https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/Comment_role>, <https://lists.w3.org/Archives/Public/public-aria/2023Oct/0028.html>).

## Pitfalls the design avoids

- Dropping or auto-resolving a comment because its text changed. Confluence resolves an inline comment when its text is deleted, and a reported bug does it with the text still there (<https://jira.atlassian.com/browse/CONFCLOUD-79573>).
- Treating a moved anchor as a settled concern. GitHub's "outdated" means the hunk moved, not that the point was addressed.
- Old resolved threads cluttering the next round. Phabricator users asked for this after its carried-forward "ghost" comments (<https://secure.phabricator.com/T1460>).
- Letting the author close a thread before the reviewer reads the reply.
- Deep nesting. Gerrit keeps threads flat and judges each by its last comment (<https://gerrit.googlesource.com/gerrit/+/6b6bee7cb1b803f2c2974833251de8cad2c6c975>).

Two points the survey could not confirm from first-party sources: what Google Docs does with a comment whose text is deleted, and how Word's comment pane behaves at narrow widths.
