# Survey house style

## Summary

Survey becomes the house style for every house tool, beyond its role as a cairn theme. One written source holds its principles, tokens, and per-context recipes. It ships as a versioned package with a changelog, so each app can follow it as it improves.

## Motivation

Geoff ruled on 2026-10-21 that Survey is the house style for every house tool. Survey now lives in three versions that have drifted: the approval queue's vendored copy, the 2026-10-07 spec in `cairn-themes`, and its approved specimen. Bulwark webmail and the phonebook's UI both wait on it.

## Goals

- One house style with principles, light and dark tokens, and a recipe for each context: a cairn site, a SvelteKit and daisyUI tool, and a token-only third-party app.
- A ladder of levers, so an app with few theming levers still reads as Survey.
- Versioned releases with a changelog that names each consumer's action.
- An agent-facing entry point that follows a published format.

## Non-goals

- Restyling the cairn admin.
- Packaging Survey as a selectable cairn theme, which is cairn's work.
- Building a consumer's convergence inside this initiative's own passes. Each app converges in a pass of its own.

## Where the work lives

- `survey`, a new repo: tokens, outputs, shared CSS, specimen, releases.
- `workstation`: the `survey` skill and the CLAUDE.md rule.
- `cairn-themes`: gives up `survey-theme/`, the Survey spec, and backlog items #1 and #2.
- `approval-queue`, `phonebook`, `servers` (Bulwark), and `907-life`: the consumers.

## Records

- Design: `specs/2026-10-21-survey-house-style-design.md`.
- 2026-10-21: proposed.
