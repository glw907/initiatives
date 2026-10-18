# Docs system

## Summary

The docs system is one documented way to handle docs for any project. It has three parts: a pipeline that drafts a page from its page plan, a page outline standard, and the Claude infrastructure the pipeline runs on (its agents, registers, and gates). The `drafter` repo is the pipeline's home. Drafter passes 1 to 5 are this record's history.

## Motivation

Hand-drafted pages drift from the register and from the facts they cite. A system that carries the register, the fact list, and the gate in one place makes a page's quality repeatable and checkable, for every project that has docs.

## Goals

- Run the generation pipeline in `drafter`: a page plan in, a gated draft out.
- Keep the page outline standard that every page plan follows.
- Own the Claude infrastructure the pipeline runs on: the drafting and register-editing agents, the registers they read, and the gates they pass.
- Document how any project handles its docs with the system.

## Non-goals

- Packaging the standards for outside developers. `shared-standards` does that.
- Any one project's docs content. Each project owns its pages.

## Where the work lives

- `drafter`: the pipeline's code, tests, gate, and from the repo-organization pass the docs page chain workflow and its `cairn-docs-outline` helper.
- `workstation`: the `cairn-docs-drafter` and `cairn-register-editor` agents, the registers, and until the move the workflow itself.

## Records

- The specs and plans of drafter passes 0 to 5 move to `docs-system/` from `workstation` once drafter pass 5's PRs have merged. The migration map marks them `deferred:p5` until then.
- Done when the system is built and the projects use it.
- Status
  - 2026-10-14: active. This record replaces the draft `drafter` record (Geoff, 2026-10-14).
  - 2026-10-17: the blueprint architecture is designed (`specs/2026-10-17-blueprint-architecture-design.md`, branch `docs-system-blueprint-design`), builder-checked, with Geoff's answers folded. It awaits Geoff's read of the written text. Next: on Geoff's approval, a planning session writes the pass plans under `pass-core`, starting from the spec's "The pilot" and "Calls made in this design". Launch prompt: "Read `docs-system/specs/2026-10-17-blueprint-architecture-design.md` whole and the 2026-10-12 pipeline spec it amends, apply Geoff's review notes, then plan the build under pass-core."
  - 2026-10-17: Geoff approved the blueprint design on `pavilion`, with two review fixes folded into the spec: a page and its blueprint changed in one first-parent commit is a coordinated change, not a conflict, and `origin: human` clears ahead of the lock entry. The planning session under `pass-core` is under way.
  - 2026-10-17: the build runs as five passes, B1 to B5 (`plans/2026-10-17-drafter-b1-blueprint-format-plan.md`, "Build sequence"). B1, the format, `check`, `refs`, `convert`, the blueprint read, and cairn's first blueprint accepted by hand, is planned, reviewed (three lenses, fold, verification; `research/2026-10-17-drafter-b1-*`), and handed to `conductor-drafter`. `runner` and `live-account`, $10 live budget, 780 path minutes against a 300 estimate. Executor: `drafter-b1-blueprint-format`.
  - 2026-10-17: B1 landed (glw907/drafter#46, glw907/cairn-cms#128). drafter now checks, lists, converts, and reads blueprints, and the pipeline spec carries the blueprint check as built. **The first milestone was missed**: cairn's rotate-the-github-app-key blueprint passes `drafter check`, but all six blueprint reads answered fix (blocking findings 7, 5, 5, 2, 3, 4), so it landed marked not accepted, per the plan's standing answer. drafter#43 asks whether B3 and B4 need a convergence rule. Spend $1.53 of $10. Next: B2's planning session. Launch prompt: "Read the blueprint design and B1's PR record, then plan pass B2 (the blueprint skill, the hook, and the format test) under pass-core." Open: cairn-cms's main checkout sits detached at `170298b` (the executor checked out the PR branch there), so it needs `git -C ~/Projects/cairn-cms checkout main && git -C ~/Projects/cairn-cms pull --ff-only`.
  - 2026-10-18: Geoff approved the B2 design (`specs/2026-10-18-drafter-b2-design.md`, glw907/initiatives#13), with the scoped read (`drafter read --since`) moved forward from B3 by his ruling. The B2 plan (`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md`) took three lenses, the fold, and a verification read (`research/2026-10-18-drafter-b2-*`): 530 path minutes against a 300 estimate, inside the 780 standing answer. Handed to `conductor-drafter`; executor `drafter-b2-blueprint-skill`. `runner` and `live-account`, $10 live budget. cairn-cms's main checkout is back on `main` at `50dc211d9`.
