# cairn site setup

## Summary

This initiative replaces `npm create cairn-site`'s JavaScript wizard with `cairn new`, a command in
cairn's Go tool. An owner answers a few questions, clicks four approvals in one browser tab, and
presses Enter once. Setup then builds and deploys the site and signs the owner in. An agent runs
the same steps through flags, a plan file, and an event stream.

## Motivation

The 0.99.0-rc.4 setup of 907.life failed. Geoff called the wizard "way too manual, user-hostile,
and fragile", and the clean-room builders couldn't finish it or find what they needed before a site
existed.

## Goals

- Ship `cairn new` with the lowest friction a new owner can have, at the admin's UI and UX bar.
- Make setup easy for Claude Code to drive, with a setup skill and plugin.
- Rebuild the setup docs, with the cairn repo's markdown as the single source of truth.
- Replace the trail demo with a small standard starter set.

## Non-goals

- Content migration. It may come later as its own feature.
- The theme catalog, its conformance corpus, and the theme comparison. Those are a parallel
  project, started from this record's notes.
- The release gates that prove setup. A separate tooling brainstorm designs those.

## Where the work lives

- `cairn-cms`: the Go tool under `tool/`, the npm launcher, the scaffold, the docs, and the plugin.
- `cairn-pub`: markdown copies of the docs pages.
- `workstation` (`~/.dotfiles`): the `cleanroom` tool the tooling plan's pass 1 builds.

## Records

- Design: `specs/2026-11-08-cairn-new-design.md`.
- Tooling design (the release legs that prove setup): `specs/2026-11-09-setup-tooling-design.md`.
- Research, the prototype, and the screen review: `research/`.
- Tooling plan: `plans/2026-11-09-setup-tooling-plan.md`, three passes (the clean room in workstation,
  the gate rewrite and token option in cairn-cms, then the polish loop), with its prompts, its owner
  scripts, and its review records beside it. Handed to `conductor-cairn-cms` on 2026-11-09 for packet A.
- 2026-11-08: proposed, from the setup brainstorm.
