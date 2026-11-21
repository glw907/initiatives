# Claude configuration alignment

Status: proposed (2026-11-20). Geoff set the scope in the terminal. The goals and non-goals below
are Claude's reading of his words.

Status: active (2026-11-20). Geoff approved the record as pull request 180.

## Summary

This initiative brings the workstation's Claude Code configuration into line with Anthropic's
documented practice, and with well-cited community practice where the docs are silent. The
configuration is the global `CLAUDE.md`, the settings, the hooks and their scripts, the skills, the
agents, the rules, the docs, the MCP servers, the memory, and the `standards` plugin. Success is a
configuration in which a docs page or a cited source describes each mechanism, and each exception
is written down with its reason.

## Motivation

The configuration grew by invention. It holds a development process of its own (`pass-core`, three
adapters, an approval queue, a desk), 19 personal skills, a plugin with 28 skills and 9 agents, and
19 `claude-*` helper scripts. Claude Code now documents `/goal`, background sessions, agent view,
and auto mode, and the research of 2026-11-20 found workstation mechanisms that repeat them.

Geoff on 2026-11-20: "I don't want to be inventive here. I'd prefer to follow established best
practice." Later that day: "We'll align with anthropic/community best practices at the workstation
level and then work from there."

The work began under `cc-desk`, whose core design aligned the global file, the permission rules,
and the hooks. It outgrew that record. cc-desk lists a change to the process as a non-goal, and
this work reaches every repo's sessions.

## Goals

- Every part of the user-level configuration has a written audit against the Anthropic page that
  covers it, and each finding rests on a sentence quoted from that page.
- One approved spec lists each change. It labels each mechanism it keeps or adds as documented,
  community (with its source), assembled from documented pieces, or invented.
- No invented mechanism stays where a documented one or a cited community one does the same job.
  An invented one that stays has its reason in the spec.
- The process skills (`pass-core`, its adapters, `approval-packet`, `standards:running-passes`)
  give way to Claude Code's documented flow: a spec, a fresh session under `/goal`, a review by a
  fresh subagent, and a pull request that Geoff approves by number.
- The `standards` plugin's skills and agents meet the skill, subagent, and plugin docs.

## Non-goals

- How a chain of unattended tasks runs: the timer script, a task that builds on another task, and
  the forecast. Those are decided after this lands, from what the aligned workstation provides.
- The cc-desk page and the removal of cc-desk's Go. Both stay in `cc-desk`.
- Project `CLAUDE.md` files and the configuration inside other repos.
- Moving cairn and dubplate to the new flow. Geoff reshapes both afterward.
- A mechanism of our own design where the docs or a cited source already give one.

## Where the work lives

The `workstation` repo holds the configuration under `claude/.claude/` and the helper scripts under
`bin/.local/bin/`. The `standards` repo holds the plugin. The spec, the rulings, and the research
live here, and `STATUS.md` in this folder says where the work stands.

`cc-desk` is the predecessor. Its core design
(`~/Projects/cc-desk/docs/specs/2026-11-20-core-design.md`) landed the first part on 2026-11-20,
and its page work resumes after this initiative.

## Records

- State: `STATUS.md`.
- Rulings (2026-11-20): `specs/2026-11-20-process-decisions.md`. Geoff's words, with each call
  Claude made marked as Claude's.
- Research on the process pieces (2026-11-20): `research/2026-11-20-process/`, nine reports.
- Research on the rest of the configuration (2026-11-20): `research/2026-11-20-workstation/`,
  four reports.
- Launch prompt for the session that writes the spec: `plans/2026-11-20-alignment-spec-prompt.txt`.
- The alignment spec is written in `specs/`, beside the rulings.
