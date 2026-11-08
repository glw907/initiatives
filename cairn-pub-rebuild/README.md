# Cairn.pub rebuild

## Summary

This proposed initiative would rebuild cairn.pub on the current cairn and make it the site that the `docs-system` pipeline publishes to. It would also write down the resulting workflow for ongoing cairn docs improvements. It starts once `cairn-docs-standard` completes.

## Motivation

cairn.pub is where cairn's published docs live. The docs system needs one concrete publishing target, and the site should run on the current engine.

## Goals

- Rebuild cairn.pub on the current cairn.
- Make it the publishing target for the `docs-system` pipeline.
- Write down the workflow for ongoing cairn docs improvements.

## Non-goals

- The docs standard itself. `cairn-docs-standard` owns it.
- The pipeline's internals. `docs-system` owns them.
- Starting before `cairn-docs-standard` completes.

## Where the work lives

- `cairn-pub`: the site.

## Records

- None yet. The rebuild's spec starts when the initiative does.

## Inputs from cairn-setup (2026-11-08)

- Geoff ruled that cairn.pub is rebuilt from scratch, so cairn-setup dropped its P7 pass (its plan,
  P7 section). The rebuild takes over what P7 would have built: a prerendered `.md` copy of each docs
  page whose first line names the engine version, and the `/start`, `/docs`, and `/deploys` short
  links. The engine's docs now live in `docs/admin/` and `docs/editors/`.
- `@glw907/cairn-cms@0.99.0-rc.4` peers `@sveltejs/kit ^3`, `svelte ^5.57.1`, and
  `@cloudflare/workers-types ^5`, needs Node 24, `@sveltejs/adapter-cloudflare` 8, and `wrangler`
  4.118 or later. Today's cairn.pub (Kit 2, adapter 7) fails `npm install` against it with ERESOLVE,
  per P7's probe before it stopped.

