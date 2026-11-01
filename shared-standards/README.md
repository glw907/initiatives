# Shared standards

## Summary

This initiative publishes a Claude Code plugin marketplace, `glw907/standards`, that carries the skills, registers, and agents an outside developer needs to work the way Geoff's repos do. The agent-first pattern for cairn-cms ran through it: the developer docs became doc comments and four packaged skills, the evaluator set replaced the technical pages, and the portable pass lifecycle moved into the plugin.

## Motivation

Those skills, registers, and agents lived in `workstation` and in each user's `~/.claude`. A collaborator would have had to copy them by hand.

## Goals

- Decide which skills, registers, and agents belong in a public marketplace. Done: the plugin's inventory moved at pass 1 of the agent-first plan.
- Package them so an outside developer installs them without cloning `workstation`. Done: `standards` loads from the repository's `.claude/settings.json`.

## Non-goals

- Moving the `cairn-docs-drafter` and `cairn-register-editor` agents and the `approval-brief.md` register out of `workstation`. They stay.
- Changing what the standards say. The initiatives that own each standard do that.

## Where the work lives

- `standards`: the plugin marketplace.
- `workstation`: the source of the pieces that stay, and the cutover to the plugin.
- `cairn-cms`: the repository the pattern was built in.

## Records

- `specs/2026-10-31-agent-first-pattern-design.md`: the agent-first pattern for cairn, approved in the Approval Queue on 2026-10-31.
- The plan and its fold record are deleted: git holds them, and `STATUS` in cairn-cms names what runs next, the release and then each site's migration.
