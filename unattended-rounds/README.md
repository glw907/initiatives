# Unattended rounds

## Summary

This initiative makes the round the workstation's basic unit of work: one design, approved at one
sitting with Geoff, covering one to six passes that run back to back without him. It also cuts the
planning misses that stop a run.
Success is a round where every pass is merged, waiting on a call in a close packet, or parked with
one question when Geoff returns 12 to 24 hours later.

## Motivation

On 2026-11-11 Geoff asked to do detailed design work and come back 12 to 24 hours later to a
finished round. The job timelines show why that does not happen today. The median job's longest
working block is 1.1 hours. Sessions sat idle after a reply for 1,087 hours, waited on an approval
for 232, and waited on the weekly usage limit for 194. A session with nothing approved to start
next has nothing to do, and one stop holds everything behind it.

Planning misses cause many of the stops. 89 of the 668 pull requests merged since 2026-10-10
recorded about 220 misses. The three largest classes are a mechanism assumed and never probed, an
incomplete file list, and a permission block.

## Goals

- A round design approved at one sitting launches every pass in it with no further word from Geoff.
- A stop in one pass parks that pass. Every pass that shares no file with it still runs.
- A round reaches Geoff as a round report with the usage it spent and each planned-against-actual
  figure, plus a close packet where a call remains and one stop packet for each parked pass.
- The Approval Queue groups a round's packets and digest lines, and shows the round report.
- The three largest planning-miss classes each fall by half, counted per 100 merged pull requests.

## Non-goals

- Removing or weakening the Approval Queue, a review, a guard, or Geoff's approval of a design or
  an `auth-data` change.
- A standing model or effort change, which belongs to `monthly-model-review`.
- Faster gates and CI, which belong to `dev-speed`.
- Spending past the Max plan's weekly allowance, unless Geoff rules otherwise in the design.
- A file change during the `workstation-refinement` freeze that Geoff has not approved as an
  exception.

## Where the work lives

- `workstation`: `pass-core` and its references, the `approval-packet` skill, the repo adapters,
  the pass section of `CLAUDE.md`, `claude-launch-guard`, `unattended-work-guards.md`, and
  `claude/.claude/settings.json`.
- `approval-queue`: the fact file's fields, the `merge` and `land` commands, and the pages.
- The record stays on the local branch `unattended-rounds` and is not pushed, because it cites the
  unpublished `workstation-refinement` record. Queue commands for it run with
  `APPROVAL_QUEUE_PROJECTS=~/.local/state/unattended-rounds/projects`.
- The round kit will live at `kit/round-kit.md` in this record, with a symlink at
  `~/.local/state/unattended-rounds/kit.md` that a designing session can be pointed at.

## Records

- Research: `research/2026-11-11-evidence.md` holds the timeline figures, the denial log, the
  planning-miss counts, the probes, and the Anthropic pages the design draws on.
- Design: `specs/2026-11-11-unattended-rounds-design.md`.
- 2026-11-11: proposed. The design went to Geoff's queue and was withdrawn the same day, after he
  asked whether the Approval Queue should work in rounds.
- 2026-11-11: Geoff ruled the round the workstation's basic unit, of one to six passes, unless
  Anthropic's guidance argued against it. The guidance check found no argument against it. The
  amended design went back to his queue.
