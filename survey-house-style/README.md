# Survey house style

## Summary

Survey becomes the house style for every house tool, in both how things look and how they read. One public repo holds the visual theme, the writing files, a short skill, and a changelog, and every repo pins it by git tag. Geoff's corrections go to a private log, and the monthly model review proposes Survey changes from them.

## Motivation

Geoff ruled on 2026-10-21 that Survey is the house style for every house tool, and on 2026-10-22 that it carries the house writing register and its copy-editing rules too. Survey's visual side lives in three versions that have drifted apart. The writing voice works well today but is spread across an output style, several registers, the conventions skills, cairn's register, and five hand-copied Vale styles. Bulwark webmail and the phonebook's UI both wait on Survey.

## Goals

- One visual house style with tokens in light and dark, per-context recipes, and a ladder of levers for apps with few theming hooks.
- One home for the writing files, moved word for word so nothing breaks.
- Corrections from chat, reviewed monthly into approved Survey changes.
- Versioned releases that every repo and the workstation can follow.
- A design kept as simple as it can be, so it stays easy to maintain, use, and improve.

## Non-goals

- Restyling the cairn admin.
- An npm package, a statistical eval harness, or a Claude Code plugin. Each is a later item if a real need appears.
- Each app's visual convergence. That is the app's own pass, and 907.life's is its later rebuild.

## Where the work lives

- `survey`, a new public repo: tokens, the theme, the writing files, the skill, and releases.
- `survey-notes`, a new private repo: the corrections log.
- `workstation`: the `survey` skill, the hook, the agent lines, the output style, the registers, and the charter.
- `cairn-themes`: gives up `survey-theme/`, the Survey spec, and backlog items #1 and #2.
- `cairn-cms`, `drafter`, `poplar`, `dubplate`, `phonebook`, `approval-queue`, and `servers`: the repos that adopt Survey.

## Records

- Design: `specs/2026-10-21-survey-house-style-design.md`.
- Reviews and folds: `research/`.
- 2026-10-21: proposed.
- 2026-10-22: an eight-pass design rejected as over-engineered; a three-pass design approved in shape.
- 2026-10-22: the three-pass design approved; active.
