# Approval queue

## Summary

The approval queue is a local app, "Design & PR Approvals", plus the `approval-queue` command that sessions call. A session hands over a PR, a design, or a triage list. The app shows it, and Geoff's decision comes back to the session as JSON.

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

1. Send-back revisions: merged 2026-10-24 (glw907/approval-queue#7 `86d142d`, glw907/workstation#148 `31db050`, glw907/drafter#64). A packet send-back now returns per-part verdicts and ask picks as `calls`. A resent packet shows its revision with `## What changed` and a since-send-back diff. Blueprints and pages need `--description`. The live queue on pavilion runs the new build. Thinkpad-x1 still needs its pulls and rebuild. Drafter's installed skill picks up the new lines at its next `make install`. Open follow-ups: approval-queue backlog #27, #28, #29.
2. Docs friction: design approved (`specs/2026-10-24-docs-friction-design.md`, #120). **Next step:** plan it from that spec.
3. Polish: design approved (`specs/2026-10-24-polish-design.md`, #122). Plan it once pass 2 merges; it is `ordinary` class and merges itself.

## Where the work lives

- `approval-queue`: the app, the command, the reminder hook script, and their tests, from the repo-organization pass on.
- `workstation`: the brief register `approval-brief.md` and the hook's entry in `settings.json`.

## Records

- Design: the 2026-10-12 approval queue design, with its predecessors the 2026-10-11 review-desk designs. They move here from `workstation` as the migration map says.
