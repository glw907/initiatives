# Survey house style

## Summary

Survey becomes the house style for every house tool, in both how things look and how they read. One public repo holds the visual tokens, the shared CSS, and the conformance check, plus one writing pack per audience. Each pack puts its published base standard first and adds the house flavor on top. Survey ships as a versioned package with a changelog, and every repo follows it. Geoff's corrections feed a private ledger, and a monthly review distills them into measured improvements.

## Motivation

Geoff ruled on 2026-10-21 that Survey is the house style for every house tool, and on 2026-10-22 that it carries the house writing register and its copy-editing rules too. Survey's visual side lives in three versions that have drifted apart. The writing voice works well today but is spread across an output style, several registers, the conventions skills, cairn's register, and five hand-copied Vale styles. Bulwark webmail and the phonebook's UI both wait on Survey.

## Goals

- One visual house style with tokens in light and dark, per-context recipes, and a ladder of levers for apps with few theming hooks.
- One writing system in which every context is first a good instance of its base standard, with a context pack Claude Code can work from.
- A migration that breaks nothing: a baseline first, a word-for-word move that has to match it, and improvements only when they beat it.
- Corrections from chat, the approval queue, notes, and the cairn editor, distilled monthly, with a graded trend per context.
- Versioned releases that every repo and the workstation can follow.
- A design kept as simple as it can be, so it stays easy to maintain, use, and improve.

## Non-goals

- Restyling the cairn admin.
- A Claude Code plugin. A Survey plugin is a later item for the shared-standards initiative.
- Each app's visual convergence. That is the app's own pass, and 907.life's is its later rebuild.

## Where the work lives

- `survey`, a new public repo: tokens, outputs, shared CSS, the conformance check, the writing packs, and releases.
- `survey-ledger`, a new private repo: the corrections ledger and the monthly scorecards.
- `workstation`: the `survey` skill, the hook, the agent lines, the output style, the registers, and the charter.
- `cairn-themes`: gives up `survey-theme/`, the Survey spec, and backlog items #1 and #2.
- `cairn-cms`, `drafter`, `poplar`, `dubplate`, `phonebook`, `approval-queue`, and `servers`: the repos that adopt Survey.

## Records

- Design: `specs/2026-10-21-survey-house-style-design.md`.
- Reviews and folds: `research/`.
- 2026-10-21: proposed.
