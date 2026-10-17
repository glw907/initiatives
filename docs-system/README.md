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
