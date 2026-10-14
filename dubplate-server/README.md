# Dubplate server

## Summary

This initiative builds the greenfield dubplate server. The product's essence is a group of family or friends building a well-organized library for a shared music server. The server launches complete, with the Go matcher included. A TUI and a local binary follow, and packaging comes after that.

## Motivation

The group's system is not live until the server launches. Geoff's 2026-09-02 ruling made the greenfield server the one active effort for dubplate.

## Goals

- Land the greenfield ladder to 0.8, in the order the dubplate ROADMAP's "Path to 0.8" gives.
- Launch the server complete, with the matcher.

## Non-goals

- The TUI, the local binary, and packaging before launch. They follow it.

## Where the work lives

- `dubplate`: the code, its specs and plans, and its BACKLOG. The ROADMAP's "Path to 0.8" order moves to the repo's backlog and STATUS with this pass.

## Records

- The dubplate Go rewrite, uploader, and music VPS docs move into `dubplate`'s own `docs/superpowers/` under the migration map.
