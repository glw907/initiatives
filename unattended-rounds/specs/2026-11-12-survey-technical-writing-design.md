# Add GitHub-flavored technical writing to Survey

Initiative: unattended-rounds

## Brief

Survey gains one section that says how a technical document is written in GitHub Flavored Markdown and how a page sets one for reading. Today the reading styles exist only in the queue mockup, and the rules for writing in each Markdown form are a few lines in the workstation design. After this round both live in Survey, where every house tool and every session can use them, and a change to either is made in one place.

Approving this merges nothing. One pass runs after the queue switch and ends with a Survey release for you to approve in the new queue. This design has no question for you. It relies on your answer to the freeze question in the workstation design.

### What changes

- Survey has a writing file, `github-flavored-technical-writing.md`, that says which Markdown form fits which content and how to use it.
- Survey has a stylesheet for a document, taken from the queue as built, with a section in `DESIGN.md` that gives each value and the published guidance behind it.
- The specimen page that shows every Markdown form moves into Survey as the example to imitate.
- The workstation's writing-process file keeps its four steps and points to Survey for the format.

### If you approve

1. Nothing starts until you approve the queue switch.
2. One pass then writes the two files in Survey and opens the release: a Survey pull request and the workstation pull request that copies the new skill files in.
3. You get one document in the new queue. Approving it merges both and publishes Survey 1.8.0.
4. A later change swaps the queue's copy of the document styles for Survey's file. The queue round files that as a backlog item.

If you send this back, the styles stay in the queue alone and the format rules stay in the workstation's file.

### Worth knowing

The workstation is frozen to removals until 2026-12-11, and this release adds a file to its copy of the Survey skill. The workstation design asks whether its round is part of the overhaul the freeze was lifted for. If you answer no there, this pass waits until 2026-12-11.

### The writing file

`skills/survey/writing/github-flavored-technical-writing.md`, about 600 words. It applies to any document a person reads that a repo's rules don't already cover. It says nothing about voice, which stays with the file for each audience.

The format is the published specification, version 0.29-gfm at github.github.com/gfm. The file then gives one short rule for each form:

| Form | Rule |
| --- | --- |
| Title | One `#` line, first in the file. It names what changed or what is asked |
| Headings | `##` for a section and `###` inside it. `####` is the deepest. A heading names what is under it, in sentence case, and no level is skipped |
| Paragraphs | The default. One idea in each |
| Bulleted lists | A true set of parallel items, introduced by a sentence. Prose that happens to have three points stays prose |
| Numbered lists | Steps that happen in order, and nothing else |
| Task lists | What is done and what is left |
| Tables | Values a reader compares across rows. A column of numbers is aligned right with `---:` |
| Code | Code marks for a command, a path, or a name a reader would type. A block of commands goes in a fence that names its language |
| Quotations | Someone's words, quoted exactly |
| Folded sections | Reference material that a reader doesn't need in order to decide goes in `<details>` with its heading inside `<summary>`. A design folds its technical notes this way |
| Raw HTML | `<details>` and `<kbd>` only |
| Outside the specification | No footnotes, alerts, mathematics, or diagrams |

Each rule names its source. The heading, list, and table rules come from Google's developer documentation style guide, which the house registers already use.

### The stylesheet

`theme/document.css` holds the styles the queue ships at the switch: reading text, six heading levels, lists, tables, code, quotations, rules, and the fold. `tokens.json` gains the two values a tool might change, the text size and the column width. `DESIGN.md` gains a section, "Documents", with this table and one sentence of use for each row.

| Style | Value | Source |
| --- | --- | --- |
| Reading text | 16 px sans at a line height of 1.5 | GitHub's Markdown stylesheet |
| Column | At most 80 characters | WCAG 2.2, success criterion 1.4.8, level AAA |
| Space between blocks | One em | US Web Design System, "Typography" |
| Space between list items | Half an em | US Web Design System, "Typography" |
| Space around a heading | At least one and a half times as much above as below | US Web Design System, "Typography" |
| Heading sizes | The smallest visible step between levels | Butterick, Practical Typography, "Headings" |
| List of a page's headings | Levels two and three, the current one marked | US Web Design System, "In-page navigation" |
| Numbers in a table | Aligned right | GOV.UK Design System, "Table" |

Serif headings over sans text is Survey's choice and has no outside source. The "Plain app" recipe gains one line that points to the section.

### The round

Round `survey-docs`, in `glw907/survey`, with one pass, class `runner`. A one-pass round has no conductor, and its executor closes the pass.

**Pass S1. The writing file, the stylesheet, and release 1.8.0.** 90 minutes. Waits for the queue switch.

- The writing file exists with a rule for each form in the table above, and each rule names a source. `tellgrader --register docs` prints no finding and no warning for it.
- `theme/document.css` matches the queue's document styles. The pass renders the specimen once with each stylesheet, and a fresh `standards:visual-verifier` compares the two at 1440 px and 390 px, light and dark, and returns no difference in face, size, or spacing.
- On that render a Playwright check finds reading text at 16 px with a 24 px line height and no full line of a paragraph longer than 80 characters.
- The specimen is in Survey beside the writing file, and every form in the writing file's table appears in it.
- A fresh `sonnet` reader, given the writing file and the plain text of one section of this design, writes that section as Markdown. `approval-queue check` accepts the result, and it uses a table only where values are compared across rows.
- `scripts/gate` prints `gate: ok`.
- The release follows the sequence in the `survey` skill. In the workstation pull request, `written-for-people.md` loses its list of forms and rules of use and gains one line that names the Survey file, and `diff -r` between Survey's skill folder and the workstation's copy prints nothing.

Files: `skills/survey/writing/`, `skills/survey/SKILL.md`, `theme/document.css`, `tokens.json`, `DESIGN.md`, `CHANGELOG.md`, `package.json`, and in the workstation `claude/.claude/skills/survey/`, `claude/.claude/docs/voice/written-for-people.md`, and `claude/.claude/tooling/vendored-skills.json`.

### Standing answers

| Stop | Answer |
| --- | --- |
| The queue's styles changed after the switch | The pass takes the queue's file as it stands on `main` |
| A rule in the writing file contradicts a file for one audience | The audience's file wins, and the pass names the conflict in `## Decisions` |

### Pre-flight

- Permissions checked: no new rule. The release commands are the ones the `survey` skill already names.
- Reviewed: one `standards:plan-reviewer` read of the plan.
- [you: nothing] before the pass.

### Backlog sweep

Survey has five open items: a selection color, a button inside an alert, a repeated destructive action, an audio player, and touch guidance. None concerns a document, and all five stay.

### Out of scope

- Any change to the files for one audience, such as the approval brief or the developer-docs registers.
- Replacing the queue's copy of the styles. That is a dependency update in the queue's repo.
- Syntax coloring in code, a copy button on a code block, and a table header that stays in view.

## Technical notes

The queue you read this in shows raw HTML as text, so these notes are not folded. In the new queue they would be.

### Prompts

The pass has a planner prompt in `plans/sv-s1-planning-prompt.txt`, committed with this design.

### Models

| Role | Model and effort |
| --- | --- |
| Planner | `claude-opus-5-5` at `high` |
| Executor | `claude-opus-5-5` at `medium`; writing a standard is judgment |
| Reviewers | From agent frontmatter |

### How each mechanism fails

| Mechanism | Failure | What happens |
| --- | --- | --- |
| The visual comparison | A difference in face, size, or spacing | The pass fixes Survey's file and compares again; the queue's page is the reference |
| The fresh reader's Markdown | `check` refuses it | The pass rewrites the rule the reader misread and runs a new reader once |
| `scripts/release` | The clone is not clean or not at `origin/main` | It refuses, and the pass releases from a new clone |
| The freeze answer | You answered no | The pass ends before its first commit and says so in STATUS |

### Claude's calls

These are mine. No fresh reader has checked this design against Survey's code.

- One pass, run after the switch, so that the queue round never waits on a Survey release.
- The rule for each form. You asked for the section and for good technical writing; the wording of each rule is mine.
- `####` as the deepest heading, where the page styles six levels.
- Folding a design's technical notes by default. You said "Excellent, continue" to that suggestion, and this is my reading of it.
- Raw HTML limited to `<details>` and `<kbd>`.
- Leaving the files for each audience unchanged.

### Left to the builder

- The class name the stylesheet uses.
- How the pass renders the specimen for the comparison.
- Whether the specimen is a reference file of the skill or sits under `theme/`.

### Sources

Each rule was checked against the words on its page on 2026-11-12.

| Rule | Page |
| --- | --- |
| The format | GitHub Flavored Markdown Spec, github.github.com/gfm |
| Text size and line height | `github-markdown-css` 5.8.1 |
| Column width | w3.org/TR/WCAG22, success criterion 1.4.8 |
| Spacing, heading space | designsystem.digital.gov/components/typography |
| List of headings | designsystem.digital.gov/components/in-page-navigation |
| Heading steps | practicaltypography.com/headings.html |
| Numbers in tables | design-system.service.gov.uk/components/table |

Google's rules for headings, lists, and tables were not read again for this design. The pass reads them before it writes a rule that cites them.
