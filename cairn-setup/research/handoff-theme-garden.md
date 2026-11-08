# Hand-off: the theme garden brainstorm

Geoff starts this brainstorm in a fresh session, in parallel with the `cairn new` build. It designs
the theme catalog ("theme garden") and the standard content every theme renders.

## Launch prompt

> Brainstorm cairn's theme garden with `standards:brainstorming`. Start from
> `~/Projects/initiatives/cairn-setup/research/handoff-theme-garden.md` and the notes it names.
> Backlog #361 needs a `cairn-judging-scope` verdict before the design builds on it.

## Already decided (Geoff, 2026-11-08)

- One content model for every theme: the same collections (posts, pages, fragments, authors), the
  same front-matter fields, and the same page paths. A theme may not require content of its own.
  An owner can switch themes without breaking the site, and compare themes on identical pages.
- Two sets of content, as WordPress keeps them:
  1. A friendly starter set that every new site gets, identical across themes, in the house
     register. `cairn new` writes it. Its contents are in the `cairn new` design's "Starter
     content" section.
  2. A separate conformance set for theme authors and CI, never shown to owners, holding the
     hostile cases.
- Some conformance pages show all possible markdown, one page per layer: CommonMark blocks,
  CommonMark inlines, GFM (tables, task lists, strikethrough, extended autolinks, footnotes), cairn's
  directives, and the raw HTML the sanitizer keeps and one tag it strips.
- A naive builder never builds a theme. A theme comes from the catalog, or from a design pass with
  the visual-fidelity process and Geoff's eye.
- Waymark's catalog entry says it's an intentionally neutral, easy-to-edit default.

## Proposed, not yet decided

- A machine check of a theme's markup contract, on the model of Ghost's gscan.
- A theme comparison on cairn.pub that renders each catalog theme on the starter set, linked from
  setup's theme question.
- Each catalog entry describes the theme's design, features, and options, and a theme may declare
  options that setup asks for.
- Survey as the second catalog theme (it lives in `glw907/survey`, `cairn-theme/`).

## The boundary with `cairn new`

`cairn new` ships offering Waymark only, with the starter set written against today's content
model. Its theme question appears when the catalog holds more than one theme, and lists whatever
the catalog holds. Theme options wait for the catalog. Starter images ship with the site, never
hot-linked (Waymark's posts load Unsplash today).

## Inputs

- `design-summary.md`, section "Starter content", with the prior-art findings: WordPress's Theme
  Unit Test and starter-content API, Ghost's gscan, Hugo's theme rules, Astro's markdown style
  guide, and the `commonmark-spec` npm package's examples.
- The coverage checklist from the research agent is folded into that section.
- Waymark today: `templates/waymark/` in cairn-cms. Home is archive page one, `archive/[page]` the
  rest at 13 per page, and ten directives (alert, banner, cta, faq, figure, icon, include, points,
  pull-quote, video).
- The 907-rebuild record's friction files A and B (theme-packaging doc gaps) and planning miss 16.
