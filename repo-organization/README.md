# Repo organization

## Summary

This initiative gives every initiative a record in this repo, moves past specs and plans to the repo that owns them, and retires repos and folders nobody uses. It also moves the drafter pieces and the approval queue out of `workstation` into repos of their own, with their history.

## Motivation

Work that spans repos had no home, so its specs and plans piled up in `workstation`. Neither Geoff, a session on either machine, nor a future collaborator could look up where new work belongs. The approval queue's project grouping and the shared-standards effort both build on these records, so this pass comes first.

## Goals

- Hold one record per initiative here, with a check that CI runs.
- Print each repo's initiatives at the start of every session.
- Retire ROADMAP.md in every repo except `cairn-cms`, with each entry handled by Geoff's call.
- Move past docs to the place the placement rule gives them, with one map of every move.
- Move the drafter pieces to `drafter` and the approval queue to `approval-queue`, both with history.
- Delete eleven repos and folders, and tear down only the Cloudflare resources that nothing else uses.

## Non-goals

- Retiring `cairn-cms`'s ROADMAP. A follow-on pass under this record does that (Geoff, 2026-10-14).
- Archiving `aksailingclub-legacy`, which still serves the live club site. The club's cutover pass closes with that archive (Geoff, 2026-10-14).
- The approval queue's grouping by initiative, and the shared-standards effort. Both follow this pass.
- Moving any code beyond the drafter and approval-queue moves.

## Where the work lives

- `initiatives`: the records, the tools in `repo-organization/tools/`, the migration map, the triage drafts, and the retirement manifest.
- `workstation`: skill and rule changes, the SessionStart lines, the secrets store edits, and the deletions of moved files.
- `drafter` and `approval-queue`: the extracted code.
- Each other repo named in `initiative.yaml`: its ROADMAP retirement and the docs it receives.

## Records

- Design: [specs/2026-10-14-repo-organization-design.md](specs/2026-10-14-repo-organization-design.md)
- Plan: [plans/2026-10-14-repo-organization-plan.md](plans/2026-10-14-repo-organization-plan.md)
- Fold records: [research/2026-10-14-repo-organization-fold.md](research/2026-10-14-repo-organization-fold.md) and [research/2026-10-14-repo-organization-plan-fold.md](research/2026-10-14-repo-organization-plan-fold.md)
- Migration map: [research/migration-map.tsv](research/migration-map.tsv)
- Docs layout design: [specs/2026-10-19-docs-layout-design.md](specs/2026-10-19-docs-layout-design.md), launched from [plans/2026-10-19-docs-layout-prompt.txt](plans/2026-10-19-docs-layout-prompt.txt)
- Status
  - 2026-10-14: active. The initiatives repo and its tools are built, and the pass is in review.
