# Poplar re-founding

## Summary

Poplar is a bubbletea terminal email client, built as one Go binary. The re-founding rebuilds it from the ground up against a settled architecture: one process, a SQLite store as the source of truth, background sync and rendering engines, and a bubbletea UI that never touches the network or writes the store directly.

## Motivation

The previous client is archived on the `legacy` branch and the `poplar-legacy` tag. It isn't the current state of the repo, so the build needs a charter and a cursor of its own.

## Goals

- Build poplar to the re-founding charter, pass by pass.
- Keep the charter's cursor (phase, next pass, starter prompt) current in `poplar`.

## Non-goals

- Reviving the legacy client.

## Where the work lives

- `poplar`: the code, the charter (`docs/specs/2026-07-19-poplar-refounding-charter.md`), and the cursor (`docs/specs/poplar-refounding-STATUS.md`).

## Records

- The poplar adapter prompts move into `poplar`'s own docs under the migration map.
