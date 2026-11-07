# 907.life rebuild

## Summary

This initiative rebuilds 907.life on cairn 0.99.0-rc.4, the way a newcomer would, using only cairn's and Survey's published tools. It has two goals, set by Geoff on 2026-11-07: a useful personal blog that also shows four of his projects, and a real test of the engine and its new tooling. Survey gains a cairn theme on the way.

## Motivation

907.life runs on an earlier cairn, and its identity layer breaks cairn's current theme contract. A rebuild by a session with no workstation knowledge also finds the gaps a real newcomer would hit, in the engine, the scaffolder, the packaged skills, the docs, and Survey.

## Goals

- Build Survey as a clean, idiomatic cairn theme, kept in `glw907/survey`.
- Rebuild 907.life from `npx create-cairn-site` with the Survey theme, all eight posts, the About page, and a Projects section for cairn-cms, dubplate, phonebook, and approval-queue.
- Record every gap the builders hit, with the owner who fixes it.
- Move the 907.life domain to the new site and retire the old one.

## Non-goals

- Shipping Survey as a theme `create-cairn-site` can offer. That is cairn's work, after the stable.
- Publishing the phonebook's source. That is `phonebook-public`.

## Where the work lives

- `907-life`: the site. A new repo replaces it at cutover, and the old one becomes `907-life-legacy`.
- `survey`: the cairn theme, in `cairn-theme/`.
- `cairn-cms`: receives the findings through `conductor-cairn-cms`.

## Records

- Design: `specs/2026-11-07-907-rebuild-design.md`.
- The 907-life ROADMAP entry that proposed this rebuild (#1) is the entry this record replaces, by Geoff's call of 2026-10-14.
- 2026-11-07: Geoff started the rebuild ahead of `cairn-docs-standard`, on cairn rc.4, and approved variant A of the home page prototype in chat.
