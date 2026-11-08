# cairn new: layout grid (2026-11-08)

One spacing system for every screen. Columns count from 0. Audit of the round-3 shots found these
breaks: value column 18 on most screens but 21 on done; list text at 4 on watch but 6 on the
browser list (mark, number, two spaces); the failed mark followed by two spaces; the current
step's sentence under the item on watch but as a separate paragraph on browser; two welcome
paragraphs run together; footers that are sometimes key hints and sometimes a muted sentence.

## Horizontal

- Margin: all content starts at column 2.
- Text column for lists: column 4. A mark list (approvals, watch steps) puts a one-cell mark at
  column 2, one space, text at 4. A select puts the `>` cursor at column 2 and every option at 4. A
  text input puts `>` at 2 and the typed text at 4. No numbers in terminal lists.
- Item detail: the one-sentence explanation of the current item sits on the lines directly under
  it, at column 4, muted. The same on browser and watch.
- Label grid: labels at column 2, values at column 20 (the longest label, "Invite an editor", is
  16, plus a 2-column gap; the column derives from the longest label in use). Every label-value block uses it: answered-question receipts, the summary,
  the four failure parts, the domain check, and the done screen's next steps. A wrapped value, and
  any secondary line under a value, continues at column 18.
- Reasons on the summary: when every reason in a group fits beside its value, they share one
  column, two spaces after the group's longest value; otherwise every reason in the group goes on
  the line under its value at column 18. Never a mix within a group.
- Measure: paragraphs wrap at the window width minus 4, capped at 76, and wrap balanced: the
  narrowest width that keeps the same line count, so no line holds one lone word.
- Right edge: only the watch screen's elapsed time, right-aligned on the title line.

## Vertical

- One blank line, then the title. Titles carry no mark.
- Blocks follow the title, separated by exactly one blank line. A block is one paragraph, one list,
  one label grid, or one form field (label, description, control). Two paragraphs never run
  together, and there is never more than one blank line.
- An interactive screen ends with the footer, after one blank line. The footer holds key hints only:
  bold key, muted verb, ` · ` between. Explanations never go in the footer.
- A final frame (done, failure, the domain check, the SSH stop, Ctrl+C) has no footer. It ends on
  its last block.

## Glyphs

- Every mark is one cell wide and is followed by exactly one space. Check the failed mark: it
  rendered with two spaces after it.
