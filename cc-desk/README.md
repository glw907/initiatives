# cc-desk

Status: active (2026-11-17), design approved.

## Summary

cc-desk shows what Claude Code is building, forecasts when the work will next need Geoff, and
takes each decision as a conversation in a terminal. It replaces the approval queue and the desk,
which served as its prototype.

## Motivation

The prototype asked Geoff more than he needed to answer, in more detail than he needed to read.
It couldn't tell him when the next question was coming, and its sessions needed tending. The
approved design lists each loss and what answers it.

## Goals

- Geoff sees what is waiting, what is running, and when the next decision session is due, on one page.
- A decision is a conversation in a terminal, recorded as one line with his words.
- Questions from every project are gathered into as few decision sessions as possible.
- Background sessions start, recover, and end with no action from him.
- The cairn and dubplate efforts run as releases under cc-desk.
- The approval queue, the desk, and their workstation files are removed.

## Non-goals

- Changing how a single pass is planned, built, gated, and reviewed. That stays in `pass-core`.
- Notices away from the page, or a model of Geoff's working hours.
- Sync between hosts.

## Where the work lives

The `cc-desk` repo holds the tool, its design, and its plans. The `workstation` repo takes the
skills at a pinned tag and loses the files cc-desk replaces. The `approval-queue` repo is archived
when the work is done. The `approval-queue` initiative is this one's predecessor.

## Records

- Design: `~/Projects/cc-desk/docs/specs/2026-11-17-cc-desk-design.md`
- Plans: `~/Projects/cc-desk/docs/plans/`
- Process decisions (2026-11-20): `specs/2026-11-20-process-decisions.md`. Geoff's rulings for
  the spec that replaces the pass process. The spec is written beside it.
- Process research (2026-11-20): `research/2026-11-20-process/`, nine reports.
