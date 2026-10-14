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

## Where the work lives

- `approval-queue`: the app, the command, the reminder hook script, and their tests, from the repo-organization pass on.
- `workstation`: the brief register `approval-brief.md` and the hook's entry in `settings.json`.

## Records

- Design: the 2026-10-12 approval queue design, with its predecessors the 2026-10-11 review-desk designs. They move here from `workstation` as the migration map says.
