# cairn theme garden

## Summary

This initiative gives cairn one standard shape for a public theme and a catalog of house themes that
`cairn new` installs from. A theme is look-only, with its metadata in a manifest and its values in
W3C Design Tokens files. A viewer renders any theme on the standard content, and a check proves a
theme fits the contract. Success is Geoff building a test site with Waymark, taking it down, and
building another with Survey.

## Motivation

Setup assumes the starter theme, and no published path takes another theme into a site (BACKLOG
#361). In the 907.life rebuild, a naive builder was handed Survey to turn into a theme, and the
result failed (907-rebuild planning miss 16). Each future rebuild needs its theme finished before
the site is built.

## Goals

- A theme has one documented, versioned contract, and a check proves a theme meets it.
- `cairn new` installs any catalog theme by id and applies the owner's options.
- Every catalog theme renders the starter and conformance sets unchanged.
- A theme's metadata ships inside the theme, on published standards, with JSON Schemas.
- Theme work is easy for agents: headless viewer screenshots and a JSON check report.

## Non-goals

- The cairn.pub theme browsing page, which comes later and reads this catalog.
- Switching a live site's theme, updating a site's theme copy, or changing options after setup.
- Themes from outside the house, and an admin screen for theme options.
- The starter content set, which the cairn-setup initiative owns.

## Where the work lives

- `cairn-cms`: the contract, `themes/`, the catalog, the viewer, the check, and the conformance set.
  Its `BACKLOG.md` holds #361.
- `survey`: the design system and `tokens.json` that Survey's cairn theme is built from.
- `cairn-pub`: publishes the theme schemas at a stable URL, and later the theme browsing page.

## Records

- Design: `specs/2026-11-08-theme-garden-design.md`. Its "Alignment with cairn-setup" section is
  the record the cairn-setup conductor reads.
- Research: `research/prior-art-theme-packaging.md`, `research/prior-art-theme-switching.md`.
- Planner launch prompt: `plans/2026-11-08-theme-garden-planner-prompt.txt`.
- Plan: `plans/2026-11-08-theme-garden-plan.md`, two engine passes (G1 the contract and Waymark's
  port, G2 the conformance set, viewer, check, and CI), reviewed in three lenses and folded
  (`plans/2026-11-08-theme-garden-review-*.md`, `-review-fold.md`, `-fold-verification.md`).
  Launch files beside it: the conductor prompt, the G1 and G2 executor prompts, and
  `add-theme-garden-grant.py`.
- Owed erratum on the design, which is not edited: the generated daisyUI blocks and `@theme` scale
  live in an imported `tokens/tokens.css`, and `theme.css` keeps the hand-written rules (fold record,
  "Owed erratum"). The design's status line still reads "proposed"; Geoff approved it in PR #174.
- Later, outside cairn-cms: the cairn.pub rebuild publishes the theme schemas at their `$schema` URLs.
- 2026-11-08: proposed, from the theme-garden brainstorm.
- Status: plan approved with Decide G-1 ruled yes (Geoff, 2026-11-09, Approval Queue item
  `20261109T022112-3127080`). `conductor-cairn-cms` orchestrates this initiative and cairn-setup
  together (Geoff, 2026-11-08). G1 is in flight (`cairn-cms-theme-garden-1`, session `b467d134`,
  launched 2026-11-09); G2 launches stacked once G1 is PR-ready with an accepted review.
