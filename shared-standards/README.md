# Shared standards

## Summary

This proposed initiative would publish a Claude Code plugin marketplace. It would carry the skills, registers, and agents that an outside developer needs to work the way Geoff's repos do.

## Motivation

Those skills, registers, and agents live in `workstation` and in each user's `~/.claude`. A collaborator would have to copy them by hand.

## Goals

- Decide which skills, registers, and agents belong in a public marketplace.
- Package them so an outside developer installs them without cloning `workstation`.

## Non-goals

- Moving anything before the repo-organization pass has finished. Until then the `cairn-docs-drafter` and `cairn-register-editor` agents and the `approval-brief.md` register stay in `workstation`.
- Changing what the standards say. The initiatives that own each standard do that.

## Where the work lives

- `workstation`: the source of every piece the marketplace would carry.

## Records

- `specs/2026-10-31-agent-first-pattern-design.md`: the agent-first pattern for cairn, approved in the Approval Queue on 2026-10-31.
