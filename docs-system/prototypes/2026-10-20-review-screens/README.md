# Review screen prototypes (2026-10-20 sitting)

Geoff approved this frame and its polish in the prototype sitting on 2026-10-20. The build pass builds approval-queue's screens from these files.

- `blueprint-review.html`: the blueprint review screen, round 8. It is self-contained and loads CodeMirror 6 from jsdelivr through an import map. Open it in a browser.
- `packet.html`: the existing packet screen restyled on the same frame. It shares the blueprint screen's stylesheet.
- `debug-your-site.blueprint.md`: the markdown blueprint format the screen edits, with YAML front matter and cairn's remark directives (`:fact[id]`, `:::row`, `:::reader`). It holds real data from cairn's debug-your-site blueprint.
- `blueprint-notes.json`: the notes the screen anchors to lines (info for an author fix, decide for a dispute, question for an author question).
- `ledger.md`: the felt-refinement audit ledger. Do not reopen its already-right verdicts.
- PNG files: renders at 1440 and 500.

The frame: the queue rail pinned left, the work centered at reading width with notes inline, and a review pane pinned right (calls for you, parts or corrections, outline). The Survey tool-page header, then the decision in the sticky bottom bar ("Send back with note" and "Approve ..."). Below 1260px the pane becomes a drawer, and below 1024px the rail does too. See the design's "What changes" for the rulings.
