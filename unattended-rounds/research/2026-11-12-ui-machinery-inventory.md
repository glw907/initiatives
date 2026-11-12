# What this workstation already has for UI design and checking

Collected 2026-11-12 by a read-only subagent, with the rows marked "checked" confirmed by the
designing session against the file. Companion to `2026-11-12-ui-consistency-guidance.md`.

The pieces exist. Each one is wired to the sites or to cairn-cms, and a repo that is neither (the
approval queue, dubplate, phonebook) passes through plan, build, and close with no UI rule in
force.

## The pieces and where they bind

| Piece | Path | Binds today | Sees the rendered page |
| --- | --- | --- | --- |
| Close-step visual read | `pass-core/SKILL.md:109` (checked) | "on rendered UI in a site or the cairn admin" | yes |
| Mockup at the design sitting | `pass-core/references/round.md:45-48` | a round of two or more passes; the form of the mockup is unset, and a text sketch met it | Geoff only |
| Screenshot as acceptance evidence | `round.md:55-57` | every round, as "the command and its output, or a screenshot" | only when the planner picks it |
| `standards:visual-verifier` | plugin agent | sites and cairn admin; needs a reference image | yes |
| `standards:diff-reviewer` | plugin agent | every close; source only; "A different-but-valid approach is not a finding" | no |
| `standards:plan-reviewer` | plugin agent | `runner`, `auth-data`, and rounds of two or more passes; no UI check | no |
| `standards:daisyui-a11y-reviewer` | plugin agent | sites and cairn-cms, by the adapter's glob map; has a "DaisyUI-first check" | no |
| `standards:design-refinement`, `visual-fidelity` | plugin skills | by description; no pass rule names them outside cairn-family work | yes |
| Brainstorming's visual companion | plugin skill | offered, and Geoff can decline; serves mockups from its own frame CSS, never the app's | mockup only |
| `survey` skill and `DESIGN.md` | `~/Projects/survey` | by description only; "say in the change which one you followed", checked by nothing | no |
| `~/.claude/rules/cairn-family-ui.md` | path rule on `**/*.svelte` (checked) | written for cairn-family admins; no shell or reuse rule | no |
| cairn-cms admin design system | `.claude/rules/admin.md` (checked), `cairn-following-admin-design`, a 1,749-line reference | a path rule forces the skill on admin paths; one shell, component recipes, "Mock it first" for a new surface | mockup step |

## What is missing for a repo with no adapter

1. Survey's `DESIGN.md` has no line on a page shell, page layout, or a notes margin (checked: no
   match). Its plain-app recipe is three steps about imports, the theme, and tokens.
2. The approval queue has no `CLAUDE.md`, no `.claude/rules`, no UI rules file, and no prototype
   file (checked). Its README cites "the 2026-11-10 prototype", which isn't in the repo.
3. No plan step asks which existing page, shell, or component a new page follows.
   `planning-samples.md` tells every planner "Don't create helpers, utilities, or abstractions for
   one-time operations", with no UI exception.
4. The Q3 and Q4 plans called their screenshots "an added check", read by the executor that built
   the page, with render tests as the evidence. Q4's plan chose the bare shell by citing
   `+page.svelte:24-25`.
5. The close review loads only the checklists an adapter maps. The approval queue has no adapter,
   so no reviewer read its `.svelte` files for UI, and no fresh reader saw the page.
6. A visual verifier with no reference image has nothing to grade, and nothing compares a new
   page with its sibling pages.

cairn-cms is the one repo where a path rule forces a design-system skill that names one shell and
tells a session to mock a new surface first. Nothing carries that pattern to another repo.

## Candidate changes for the sitting

Reordered after Geoff's correction of 2026-11-12 (see the evidence file): the report page was
sloppy, and a design standard would not have caught it. The first four address that. None is a
ruling.

1. Before a pass that adds or changes a page ends, the executor opens the page in a browser with
   real content and uses it: reads every part, and performs each action the page offers. Anthropic:
   "use browser automation tools and do all testing as a human user would".
2. A fresh reader repeats that at close and answers plain questions. Is anything clipped or
   overflowing? Does text sit in paragraphs? Does each title and description tell a reader what
   the thing is? Does each action work? Anthropic's functionality criterion: "users can understand
   what the interface does, find primary actions, and complete tasks without guessing".
3. Test and prototype content comes from a real item, never a made-up fixture shorter and tidier
   than the real thing.
4. What a page shows is written for its reader. A report or packet title follows the
   approval-brief register, and a session's field block is turned into a page, never printed.
5. A rendered prototype with real content, approved by Geoff, for any new page, in a round of
   any size.
6. A plan line per UI task naming the existing page or component it follows, and "ask before
   inventing" for an interaction the app already has (notes).
7. A short UI rules file per app, forced by a path rule as in cairn-cms, holding the app's shell
   and its interaction patterns. Secondary: it covers the notes fault only.

Anthropic's harness post puts its evaluator loop at "over 20x more expensive" and calls it
"unnecessary overhead" inside what the model does reliably, so items 1, 2, and 5 would apply only
to a pass that adds or changes a page.

## A probe: can a script catch the report page's faults?

Geoff asked on 2026-11-12 whether something more programmatic than his review could catch work
this sloppy. The designing session ran a browser script of about 20 lines on the live report page
(`http://127.0.0.1:7907/item/20261112T083322-3293133`, viewport 1231 px) through the Playwright
tools.

| Fault Geoff named | What the script found | Kind of check |
| --- | --- | --- |
| Table clipped on the right | The `TABLE` ends at 1168 px and the box that holds it at 1088 px, 80 px past | deterministic: an element's right edge past its parent's |
| Text not in paragraphs | One `<p>` of 1,252 characters holding five `Label: ` fields | deterministic with a threshold: paragraph length and field labels in one paragraph |
| No meaningful title | The `h1` reads "Round ur-ws, glw907/workstation, written 2026-11-12 (close packet 1 merged, close packet 2 sent)" | a model's judgment; a script can only flag an id or a date in a title |
| A second notes UI | not probed | deterministic: every reading page renders `NotesMargin` |

The digest fault (a line closing under the reader) needs a browser test that opens a line, waits
past the layout's two-second poll, and types. The script ran on a real item in the live queue's
state. The repo's fixture would have passed it.
