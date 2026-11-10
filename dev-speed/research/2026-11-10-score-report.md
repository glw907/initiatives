# Pass score report, 2026-11-10

This is the first report from `pass-report`, run on pavilion on 2026-11-10 as `pass-report --since 2026-10-10 --backfill dev-speed/research/score-backfill.json`. It covers merged pull requests from 2026-10-10 to 2026-11-10 in every `glw907` repo. Gate records come from pavilion only: thinkpad-x1 did not resolve over ssh, so its `runs.jsonl` was not read, and gate figures for work done there are missing. Scores come from the backfill file, since no PR body carries a `pass-score` line yet. Times are in minutes.

Window: 2026-10-10 to 2026-11-10

### 907-life-legacy

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 4 | 119.0 | 489.0 | 737.3 |
| CI on the default branch | 7 | 0.8 | 0.9 | 5.5 |
| Reds | 7 | - | - | 0 failed (0.0%) |
| Planned path (min) | 1 | 55.0 | 55.0 | 55.0 |
| Actual path (min) | 1 | 45.0 | 45.0 | 45.0 |
| Actual / planned | 1 | 0.8 | 0.8 | - |
| Fix rounds | 2 | 0.5 | 1.0 | 1.0 |
| Escapes | 1 | 0.0 | 0.0 | 0.0 |

### aksailingclub-legacy

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 2 | 289.0 | 491.0 | 578.0 |
| CI wait on the PR | 2 | 1.2 | 1.4 | 2.5 |
| CI on the default branch | 4 | 1.4 | 1.8 | 5.5 |
| Reds | 73 | - | - | 0 failed (0.0%) |
| Waiting on Geoff | 2 | 1.1 | 1.2 | 2.3 |

### aksailingclub-org

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 5 | 86.1 | 484.0 | 722.9 |
| Local gates | 1 | 0.2 | 0.2 | 0.2 |
| CI wait on the PR | 5 | 14.2 | 36.8 | 86.7 |
| CI on the default branch | 10 | 7.0 | 13.5 | 71.3 |
| Reds | 18 | - | - | 13 failed (72.2%) |
| Waiting on Geoff | 2 | 1.1 | 1.2 | 2.3 |
| Fix rounds | 2 | 1.0 | 1.0 | 2.0 |
| Attended events | 1 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 0.0 min across 1 PRs.

Top failing steps: `Run the visual-fidelity suite` (13).

### approval-queue

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 11 | 21.6 | 482.3 | 1561.2 |
| Local gates | 3 | 15.3 | 32.6 | 51.0 |
| CI waits a session sat through | 1 | 0.0 | 0.0 | 0.0 |
| Waiting on Geoff | 7 | 17.5 | 476.3 | 753.2 |
| Planned path (min) | 8 | 387.5 | 540.0 | 2850.0 |
| Actual path (min) | 8 | 105.0 | 153.0 | 820.0 |
| Actual / planned | 8 | 0.3 | 0.4 | - |
| Fix rounds | 5 | 1.0 | 3.0 | 7.0 |
| Attended events | 5 | 0.0 | 0.0 | 0.0 |
| Escapes | 3 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 1.4 min across 3 PRs.

### cairn-cms

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 109 | 68.1 | 568.7 | 29692.3 |
| Local gates | 58 | 6.8 | 31.4 | 722.3 |
| CI wait on the PR | 107 | 27.3 | 107.5 | 5585.6 |
| CI waits a session sat through | 79 | 26.9 | 82.5 | 2988.9 |
| CI on the default branch | 1035 | 5.6 | 11.7 | 6961.5 |
| Reds | 4154 | - | - | 222 failed (5.3%) |
| Waiting on Geoff | 53 | 29.2 | 510.1 | 7632.0 |
| Planned path (min) | 31 | 420.0 | 1015.0 | 15204.0 |
| Actual path (min) | 31 | 167.0 | 250.0 | 5107.0 |
| Actual / planned | 31 | 0.3 | 0.7 | - |
| Fix rounds | 27 | 1.0 | 3.0 | 50.0 |
| Attended events | 26 | 0.0 | 0.0 | 1.0 |
| Escapes | 26 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 130.6 min across 58 PRs.

Top failing steps: `Run make -C tool check` (77), `Run the node test projects` (37), `Run the e2e suite` (36), `Install, typecheck, and build the scaffolded site` (18), `Run ./.github/actions/bounded-install` (11).

### cairn-pub

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 3 | 147.5 | 484.3 | 642.1 |
| Local gates | 1 | 0.1 | 0.1 | 0.1 |
| CI on the default branch | 4 | 1.4 | 1.5 | 5.5 |
| Reds | 4 | - | - | 0 failed (0.0%) |
| Waiting on Geoff | 1 | 1.2 | 1.2 | 1.2 |
| Fix rounds | 2 | 0.5 | 1.0 | 1.0 |
| Attended events | 1 | 0.0 | 0.0 | 0.0 |
| Escapes | 1 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 0.0 min across 1 PRs.

### cairn-rc2-install

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| CI on the default branch | 2 | 1.0 | 1.1 | 2.0 |
| Reds | 5 | - | - | 0 failed (0.0%) |

### cairn-themes

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 5 | 122.4 | 491.1 | 851.7 |
| Waiting on Geoff | 3 | 1.2 | 52.7 | 55.0 |
| Planned path (min) | 1 | 50.0 | 50.0 | 50.0 |
| Actual path (min) | 1 | 30.0 | 30.0 | 30.0 |
| Actual / planned | 1 | 0.6 | 0.6 | - |
| Fix rounds | 1 | 0.0 | 0.0 | 0.0 |
| Attended events | 1 | 0.0 | 0.0 | 0.0 |
| Escapes | 1 | 0.0 | 0.0 | 0.0 |

### dubplate

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 11 | 23.5 | 167.3 | 849.8 |
| Local gates | 4 | 6.0 | 20.7 | 38.1 |
| Waiting on Geoff | 5 | 1.2 | 52.7 | 64.9 |
| Planned path (min) | 3 | 695.0 | 725.0 | 1510.0 |
| Actual path (min) | 3 | 475.0 | 570.0 | 1115.0 |
| Actual / planned | 3 | 0.8 | 0.8 | - |
| Fix rounds | 3 | 1.0 | 1.0 | 2.0 |
| Attended events | 2 | 0.5 | 1.0 | 1.0 |
| Escapes | 3 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 0.1 min across 4 PRs.

### ecxc-ski

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 5 | 10.3 | 488.9 | 619.2 |
| Local gates | 2 | 0.1 | 0.1 | 0.2 |
| CI on the default branch | 35 | 0.9 | 1.1 | 38.5 |
| Reds | 35 | - | - | 0 failed (0.0%) |
| Waiting on Geoff | 1 | 1.2 | 1.2 | 1.2 |
| Fix rounds | 2 | 0.5 | 1.0 | 1.0 |

Lock wait behind other gates: 0.0 min across 2 PRs.

### fishwright

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 7 | 0.1 | 84.0 | 85.5 |
| Waiting on Geoff | 1 | 1.1 | 1.1 | 1.1 |

### initiatives

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 172 | 0.2 | 21.9 | 4366.8 |
| Local gates | 59 | 0.6 | 1.6 | 43.1 |
| CI wait on the PR | 150 | 0.7 | 1.5 | 105.6 |
| CI waits a session sat through | 2 | 0.0 | 0.0 | 0.0 |
| CI on the default branch | 518 | 0.8 | 0.9 | 436.5 |
| Reds | 754 | - | - | 1 failed (0.1%) |
| Waiting on Geoff | 90 | 2.9 | 48.2 | 2495.2 |
| Planned path (min) | 3 | 130.0 | 665.0 | 825.0 |
| Actual path (min) | 3 | 80.0 | 103.0 | 208.0 |
| Actual / planned | 3 | 0.6 | 0.8 | - |
| Fix rounds | 2 | 0.5 | 1.0 | 1.0 |
| Attended events | 1 | 0.0 | 0.0 | 0.0 |
| Escapes | 1 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 38.3 min across 59 PRs.

Top failing steps: `Records and tests` (1).

### phonebook

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 33 | 27.1 | 810.3 | 6618.3 |
| Local gates | 18 | 2.7 | 20.6 | 120.6 |
| CI wait on the PR | 16 | 3.6 | 32.6 | 171.9 |
| CI on the default branch | 40 | 4.5 | 5.2 | 174.8 |
| Reds | 95 | - | - | 4 failed (4.2%) |
| Waiting on Geoff | 32 | 1.2 | 50.2 | 792.6 |
| Planned path (min) | 6 | 295.0 | 820.0 | 2065.0 |
| Actual path (min) | 6 | 150.5 | 540.0 | 1137.0 |
| Actual / planned | 6 | 0.5 | 1.2 | - |
| Fix rounds | 2 | 2.5 | 5.0 | 5.0 |
| Attended events | 1 | 0.0 | 0.0 | 0.0 |
| Escapes | 4 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 68.9 min across 18 PRs.

Top failing steps: `Gate` (4).

### poplar

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 5 | 167.6 | 487.5 | 924.7 |
| Local gates | 3 | 0.9 | 2.9 | 4.2 |
| CI wait on the PR | 5 | 3.5 | 4.9 | 18.5 |
| CI waits a session sat through | 1 | 0.0 | 0.0 | 0.0 |
| CI on the default branch | 5 | 3.0 | 3.2 | 13.3 |
| Reds | 52 | - | - | 25 failed (48.1%) |
| Waiting on Geoff | 4 | 1.2 | 8.9 | 12.2 |
| Planned path (min) | 1 | 75.0 | 75.0 | 75.0 |
| Actual path (min) | 1 | 15.0 | 15.0 | 15.0 |
| Actual / planned | 1 | 0.2 | 0.2 | - |
| Fix rounds | 2 | 0.0 | 0.0 | 0.0 |
| Attended events | 2 | 0.0 | 0.0 | 0.0 |
| Escapes | 1 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 0.8 min across 3 PRs.

Top failing steps: `govulncheck` (13), `Run go test ./...` (11), `Run go test -race ./...` (2).

### servers

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 33 | 101.0 | 974.1 | 11640.0 |
| Local gates | 4 | 7.5 | 11.8 | 27.3 |
| CI wait on the PR | 30 | 12.9 | 40.4 | 578.9 |
| CI waits a session sat through | 7 | 8.6 | 50.4 | 138.5 |
| CI on the default branch | 63 | 6.6 | 7.5 | 365.7 |
| Reds | 219 | - | - | 18 failed (8.2%) |
| Waiting on Geoff | 28 | 3.8 | 223.2 | 1089.7 |
| Planned path (min) | 8 | 497.5 | 715.0 | 3395.0 |
| Actual path (min) | 8 | 275.0 | 660.0 | 2285.0 |
| Actual / planned | 8 | 0.8 | 1.2 | - |
| Fix rounds | 6 | 2.0 | 7.0 | 15.0 |
| Attended events | 7 | 0.0 | 0.0 | 0.0 |
| Escapes | 8 | 0.0 | 1.0 | 1.0 |

Lock wait behind other gates: 1.2 min across 4 PRs.

Top failing steps: `Gate` (18).

### sportsyou-notify

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 2 | 0.1 | 0.1 | 0.3 |

### standards

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 15 | 23.0 | 70.9 | 626.0 |
| CI wait on the PR | 15 | 0.3 | 0.3 | 4.9 |
| CI on the default branch | 16 | 0.3 | 0.4 | 4.8 |
| Reds | 35 | - | - | 1 failed (2.9%) |
| Waiting on Geoff | 13 | 5.2 | 497.8 | 1093.4 |

Top failing steps: `Scan for secrets and personal paths` (1).

### survey

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 9 | 15.6 | 604.5 | 861.5 |
| Local gates | 1 | 9.0 | 9.0 | 9.0 |
| Waiting on Geoff | 7 | 1.9 | 482.2 | 501.3 |
| Fix rounds | 1 | 1.0 | 1.0 | 1.0 |

Lock wait behind other gates: 0.0 min across 1 PRs.

### survey-notes

No data in the window.

### workstation

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 212 | 5.7 | 449.1 | 55820.8 |
| Local gates | 133 | 3.0 | 7.7 | 501.7 |
| CI waits a session sat through | 3 | 0.0 | 0.0 | 0.0 |
| Waiting on Geoff | 105 | 1.8 | 47.0 | 2678.4 |
| Planned path (min) | 13 | 365.0 | 625.0 | 4360.0 |
| Actual path (min) | 13 | 75.0 | 160.0 | 1146.0 |
| Actual / planned | 13 | 0.3 | 0.7 | - |
| Fix rounds | 26 | 1.0 | 2.0 | 27.0 |
| Attended events | 9 | 0.0 | 1.0 | 1.0 |
| Escapes | 18 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 81.5 min across 133 PRs.

## Notes

- Gate records read: /var/home/glw907/.local/state/cairn-run-gate/runs.jsonl
- Dropped gate records: 858
- Negative waits dropped: 0
- Malformed lines or rows skipped: 0
- PRs with no score: 510
