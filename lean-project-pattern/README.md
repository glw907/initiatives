# Lean project pattern

Status: done (2026-11-23). All three tasks merged on Geoff's word: dubplate pull request 26, standards
pull request 29, and workstation pull request 273. The merge-tiers work goes on in
`claude-config-alignment/STATUS.md`, and the dubplate cleanup in dubplate's own `docs/specs/`.

Status: active (2026-11-23). Geoff set the aim in the terminal and asked for the spec ("yes, write
the spec"). The goals and non-goals below are Claude's reading of his words.

## Summary

This initiative settles one pattern for every project on the workstation: what a repo's `CLAUDE.md`
holds, where a binding decision is recorded, which rules become gate checks, how a spec orders its
tasks, and how review catches code that is more general than it needs to be. Each piece is
documented practice from Anthropic or the wider community. The pattern is piloted on dubplate, then
written into the `building-from-specs` skill and the `standards:diff-reviewer` agent. Success is a
dubplate task that builds under the new files and checks, and a reviewer that blocks an unneeded
abstraction in its eval.

## Motivation

On 2026-11-23 Geoff asked how a large project should hold its architecture and build plan under the
spec-based process. He set the terms over several messages:

- "It doesn't matter how I currently do it. What matters is how I should do it."
- "Note that our principle audience for this system is local agents. So we need a system that's
  battle-tested for agentative development."
- "It should be lean, and effective at producing clean, streamlined, and well-architected code that
  doesn't leave a bunch of technical debt."
- "I want to avoid a system that layers patches and workarounds."
- "My expecience is that agentive development to sometime lead to bloated and overengineered code,
  and tends not to have good judgement about when to refector."
- "I don't want to testing out novel ideas. I just want the best practices that produces
  clean/well-architected code."

## Goals

- dubplate's `CLAUDE.md` holds only what an agent can't learn from the code, under 200 lines.
- dubplate's binding decisions live in `docs/decisions/`, one record each, with a status.
- dubplate's gate fails on duplicated code, a new over-complex function, a banned call, and an
  export no code or test uses.
- `building-from-specs` says how a spec orders its tasks, when a refactor happens, and which files
  every repo carries.
- `standards:diff-reviewer` blocks code more general than it needs to be and code that breaks an
  accepted decision record.

## Non-goals

- Moving cairn-cms, phonebook, or any other repo onto the pattern. Each moves in a later spec.
- A product document, a feature list, or any file Anthropic or the community doesn't document.
- Refactoring dubplate's existing over-complex functions or its unused exports.

## Where the work lives

- The spec: `specs/2026-11-23-lean-project-pattern.md`.
- The pilot: `glw907/dubplate`.
- The process: `glw907/workstation`, in `claude/.claude/skills/building-from-specs/`.
- The reviewer: `glw907/standards`, in `plugins/standards/agents/diff-reviewer.md`.

## Records

- 2026-11-23: Geoff approved the spec (initiatives PR #183).
