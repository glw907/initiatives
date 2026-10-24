# Approval queue

## Summary

The approval queue is a local app, the Approval Queue, plus the `approval-queue` command that sessions call. A session hands over a PR, a design, or a triage list. The app shows it, and Geoff's decision comes back to the session as JSON.

## Motivation

Sessions ran unattended and stopped at decisions only Geoff can make. A single queue with a fixed brief format lets him decide from a phone without opening the diff.

## Goals

- Show every item as a brief, with decisions named as decisions.
- Return a decision to the waiting session as a file the session reads.
- Live in a public repo of its own, installable on both workstations, with its history intact.

## Non-goals

- Grouping items by initiative, and the new sidebar that goes with it. A follow-on initiative with prototypes does that.
- Deciding anything for Geoff. The queue records his choice and nothing else.

## Status

Three passes clear the approval-queue backlog, in order. Each launches only after the one before it merges, since they edit the same files.

1. Send-back revisions: merged 2026-10-24 (glw907/approval-queue#7 `86d142d`, glw907/workstation#148 `31db050`, glw907/drafter#64). A packet send-back now returns per-part verdicts and ask picks as `calls`. A resent packet shows its revision with `## What changed` and a since-send-back diff. Blueprints and pages need `--description`. Its follow-ups #27, #28, and #29 landed in pass 2.
2. Docs friction: merged 2026-10-24 (glw907/approval-queue#8 `7441cc8`, glw907/workstation#149 `27d9882`, glw907/drafter#66 `7627944`). It adds `withdraw`, a defer outcome with `collect`, quote-anchored notes, `approval-queue anchors`, a claimed browser tab, and an amend review for a re-queued approved blueprint or page. It fixes #1, #2, #9, #19, #27, #28 (only parts Geoff set to send back count as revised), and #29. Its follow-ups are approval-queue backlog #30 to #36.
3. Polish: design approved (`specs/2026-10-24-polish-design.md`, #122). **Next step:** plan it from that spec. It is `ordinary` class and merges itself. It also takes the docs friction follow-ups #30 to #36 (Geoff, 2026-10-24, choosing "Fold all seven"). If #31's command changes would raise its class, the planner asks Geoff.

The app is named the Approval Queue, to match the command (Geoff, 2026-10-24; approval-queue `dbe553b`, workstation `5296043`). Pavilion's live queue runs the new build. Thinkpad-x1 still needs its pulls and rebuild, and on each host Geoff opens `http://127.0.0.1:7907/claim` once.

## Where the work lives

- `approval-queue`: the app, the command, the reminder hook script, and their tests, from the repo-organization pass on.
- `workstation`: the brief register `approval-brief.md` and the hook's entry in `settings.json`.

## Records

- Design: the 2026-10-12 approval queue design, with its predecessors the 2026-10-11 review-desk designs. They move here from `workstation` as the migration map says.
