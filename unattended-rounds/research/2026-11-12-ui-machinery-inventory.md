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

These are the designing session's reading of the two research files. None is a ruling.

1. A UI rules file in each app's repo, forced by a path rule as in cairn-cms: the page shell, the
   components in use, each interaction pattern (notes among them), and "ask before inventing".
   Anthropic's skills page supports path-scoped loading.
2. A page-layout section in Survey's plain-app recipe, so a new app starts from a shell.
3. A rendered prototype built from the app's real CSS and components, approved by Geoff, in a
   round of any size. Its screenshot becomes the reference image.
4. A plan line per UI task naming the existing page or component it follows, as Anthropic's
   "follow the pattern in HotDogWidget.php" does.
5. The screenshot beside the prototype as required evidence, never an added check.
6. A fresh-context visual read at close in every repo with rendered UI, graded against the
   prototype and one sibling page, with a criterion Anthropic's grader lacks: the page matches
   the app's existing patterns.
7. One deterministic test per app that every route renders inside the shared shell. No published
   lint does this.

Anthropic's harness post puts its evaluator loop at "over 20x more expensive" and calls it
"unnecessary overhead" inside what the model does reliably, so items 3, 5, and 6 would apply only
to a pass that adds or changes a page.
