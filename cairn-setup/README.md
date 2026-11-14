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
  Packets A and B approved 2026-11-09; passes 1 (glw907/workstation#215) and 2 (cairn-cms #210)
  merged. Pass 3's naive leg passed on dev.8 (run 10 of 15) on 2026-11-11. Its close (T3.5 and the
  end packet, with Geoff's 907.life live setup as the `[you]` step) went to session
  `cairn-cms-setup-tooling-close` on 2026-11-13, from `plans/2026-11-13-setup-tooling-close-prompt.txt`.
- Screen redesign brainstorm (2026-11-11): `research/handoff-installer-redesign.md`, with mockups in
  `research/installer-mockups/`. Unapproved. It resumes in a fresh session after pass 3 and
  theme-garden G3.
- Terminal design language, round `tui-language` (2026-11-13): design at
  `specs/2026-11-13-tui-language-design.md`, four passes over every print-and-exit command, with the
  debt read at `research/tool-debt-read-2026-11-13.md` and mockups in `research/command-mockups/`.
  Approved by Geoff on 2026-11-13 (packet `20261113-224909-04cfc7`), his rulings written into the
  design. Handed to `conductor-cairn-cms` the same day; it runs beside theme-garden G3 and starts once
  setup-tooling pass 3 has closed. The conductor prompt, four planner prompts, and the round's process
  log (`research/tui-language-round-log.md`) sit beside it. The installer's screens are the round after, once
  theme-garden G3 has merged.
- 2026-11-08: proposed, from the setup brainstorm.
