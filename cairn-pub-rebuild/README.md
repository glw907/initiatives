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
