# Development speed

## Summary

This initiative cuts the time a change takes from approved design to merged, on every project on
this workstation. Every quality gate keeps running. Success is a score report that shows where pass
time goes across repos, and a falling figure in each row a pass attacks.

## Motivation

Geoff spends a lot of time waiting on CI runs in cairn-cms. A survey on 2026-11-10 found the `test`
workflow there takes 17 to 28 minutes, and that most recent PRs changed under 200 lines and still
waited a full cycle. In other repos CI is short, but poplar, aksailingclub-org, and cairn-pub fail
40% to 70% of their runs, and each red costs a fix and a second cycle.

CI history can't show the rest of the time: local gates and their shared lanes, review and fix
rounds, packets waiting, and agent work. Every pass PR records these in its score table, and nobody
has added the tables up across repos.

## Goals

- One report sums the pass scores across repos by row, and it reruns on demand. Each later pass in
  this initiative cites the row it attacks.
- A failure that a local gate could catch reaches CI in under 10% of runs in each repo.
- No repo's PR waits more than 10 minutes on CI.
- The shared process (`pass-core`, the adapters, the gate lanes) loses each step the report shows
  costing time without catching defects.

## Non-goals

- Dropping or weakening a check, a review, or Geoff's approval of a `runner` or `auth-data` pass.
- Paid runners or a new vendor.
- Model or effort changes, which belong to `monthly-model-review`.

## Where the work lives

- `workstation`: the score report, `pass-core`, the adapters, and the gate lanes.
- `cairn-cms`: its workflows, the fast lane, and the classifier (`scripts/checks/gate-tier.mjs`).
  The proving loop's PR cadence is in its `cairn-proving-setup` skill.
- `aksailingclub-org`, `poplar`, `cairn-pub`: the red rates, once the report ranks them.

## Records

- Research: `research/2026-11-10-baseline.md` holds the survey, the cairn-cms step timings, and the
  inputs for the first two pass designs.
- Research: `research/2026-11-10-score-report.md` is the first `pass-report` run, and
  `research/score-backfill.json` holds the scores backfilled from 133 merged PR bodies that it reads.
- First passes, in order.
  1. The score report, in workstation. It is read-only and ranks everything after it. Design:
     `specs/2026-11-10-score-report-design.md`.
  2. The cairn-cms CI split and fast-lane legs. Its numbers are in the baseline, so it doesn't wait
     on the report. It is a `runner` pass.
  3. Whatever the report ranks next.
- The fourth goal puts `pass-core` in play. A change to it comes to Geoff as a design before any
  pass builds it.
- 2026-11-10: proposed, from a cairn-cms session that measured CI and the fast lane.
- 2026-11-10: active. The score report's design went to Geoff for approval.
