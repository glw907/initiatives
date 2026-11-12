# Add GitHub-flavored technical writing to Survey

You are asked to approve a design for Survey. It adds the section you asked for on 2026-11-12: one file that says how a technical document is written in GitHub Flavored Markdown, and one stylesheet that sets such a document for reading. Today the reading styles exist only in the queue mockup, and the rules for each Markdown form are a few lines in the workstation design.

Approving this packet merges nothing. One pass runs after the queue switch. It ends with a Survey release, which reaches you as one document in the new queue, and approving that document publishes Survey 1.8.0. If you send this design back, the styles stay in the queue alone and the format rules stay in the workstation's file.

The design asks you no question. Three choices were made for you, and they are listed under "Decided for you". The pass does depend on one answer you give elsewhere. The workstation is frozen to removals until 2026-12-11, and this release adds a file to it. The workstation design, which is also in your queue, asks whether its round is part of the overhaul you lifted the freeze for. If you answer no there, this pass waits until 2026-12-11.

## Deep dive

The design describes the writing file, the stylesheet, and the one pass that adds them.

### The writing file

The file is about 600 words and is named `github-flavored-technical-writing.md`. It applies to any document a person reads, unless a repo's rules already cover that document. It says nothing about voice, which stays with the file for each audience.

The format is the published GitHub Flavored Markdown specification. The file then gives one short rule for each form. A few of them:

- A heading names what is under it. A document has a title and at most three levels of heading below it.
- A bulleted list is a true set of parallel items. Prose that happens to have three points stays prose.
- A numbered list is for steps in order.
- A table is for values that a reader compares across rows.
- Reference material that a reader doesn't need in order to decide goes in a folded section.

Those are five of twelve rules, and the design has the full table. Claude wrote the wording of each rule, and each rule names the published source it comes from.

### The stylesheet

The stylesheet holds the document styles as the queue ships them at the switch. Survey's design file gains a section that gives each value and the published guidance behind it:

| Style | Value | Source |
| --- | --- | --- |
| Reading text | 16 px sans at a line height of 1.5 | GitHub's Markdown stylesheet |
| Column | At most 80 characters | WCAG 2.2, criterion 1.4.8 |
| Space between blocks | One em | US Web Design System |
| Space between list items | Half an em | US Web Design System |
| Numbers in a table | Aligned right | GOV.UK Design System |

Serif headings over sans text is Survey's choice and has no outside source.

### The pass

One pass in Survey's repo, planned at 90 minutes, writes both files and moves the mockup's page of Markdown forms into Survey as the example to imitate. A fresh grader compares that page drawn with Survey's stylesheet against the same page drawn with the queue's. A fresh reader, given only the writing file, turns a plain-text section into Markdown, and the queue's `check` command must accept the result.

The release also changes the workstation. Its copy of the Survey skill gains the new file, and `written-for-people.md` keeps its four steps and points to Survey for the format.

### What the design leaves out

The files for each audience, such as the approval brief, stay as they are. The queue keeps its copy of the styles until a later dependency update swaps in Survey's file. Syntax coloring in code is also left out.

## Decided for you

### When does the Survey pass run?

Context: After the queue switch. The queue ships its copy of the document styles, and a later update swaps in Survey's file.

Why: If the pass ran first, the queue's third pass would wait for you to approve a Survey release in the middle of an unattended round.

### Does a design fold its technical notes?

Context: Yes, once the new queue is the one you read in. A design's reference sections take one line each until you open them, and their headings stay in the "On this page" list. The old queue shows raw HTML as text, so this design and the two others in your queue are not folded.

Why: You said "Excellent, continue" to the suggestion on 2026-11-12. Reading that as a yes to folding is Claude's. With every section open, the long test page is about two screens longer.

### How deep do headings go in a document?

Context: A title and three levels of heading below it. The page still draws all six levels that Markdown has, for a document that arrives with them.

Why: Butterick advises three levels of heading at most. A writer who needs a fifth level splits the section.

## Not checked

- No fresh reader has checked this design against Survey's code.
- Google's rules for headings, lists, and tables were not read again for this design. The pass reads them before it writes a rule that cites them.
- Vale has not read this design. `tellgrader` under the docs register reports nothing.
- Whether Survey's repo can draw the page of Markdown forms for the comparison with what it has installed. The design leaves the method to the pass.
