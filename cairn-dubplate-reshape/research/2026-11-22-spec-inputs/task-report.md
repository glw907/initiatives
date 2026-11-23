# Task score report

Window: 2026-10-23 to 2026-11-23

### cairn-cms

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 120 | 71.1 | 910.2 | 45146.9 |
| Local gates | 77 | 8.8 | 31.4 | 1005.9 |
| CI wait on the PR | 118 | 39.8 | 156.2 | 8620.5 |
| CI waits a session sat through | 105 | 34.7 | 105.1 | 5260.2 |
| CI on the default branch | 1036 | 6.1 | 12.8 | 7729.3 |
| Reds | 4346 | - | - | 200 failed (4.6%) |
| Planned path (min) | 41 | 350.0 | 955.0 | 18445.0 |
| Actual path (min) | 41 | 175.0 | 250.0 | 7083.0 |
| Actual / planned | 41 | 0.4 | 1.0 | - |
| Fix rounds | 49 | 1.0 | 3.0 | 91.0 |
| Attended events | 49 | 0.0 | 1.0 | 11.0 |
| Escapes | 45 | 0.0 | 0.0 | 2.0 |

Lock wait behind other gates: 191.8 min across 77 PRs.

Top failing steps: `Run make -C tool check` (43), `Run the e2e suite` (37), `Run the node test projects` (25), `Run npm run test:theme` (17), `Run ./.github/actions/bounded-install` (10).

### dubplate

| Row | n | Median | p90 | Total |
|---|---|---|---|---|
| PR open to merge | 10 | 156.7 | 699.8 | 3481.8 |
| Local gates | 9 | 34.0 | 65.1 | 336.8 |
| CI wait on the PR | 8 | 61.2 | 82.7 | 487.4 |
| Reds | 80 | - | - | 8 failed (10.0%) |
| Planned path (min) | 6 | 377.0 | 610.0 | 2231.0 |
| Actual path (min) | 6 | 146.0 | 290.0 | 1017.0 |
| Actual / planned | 6 | 0.4 | 1.6 | - |
| Fix rounds | 7 | 1.0 | 3.0 | 10.0 |
| Attended events | 7 | 0.0 | 1.0 | 2.0 |
| Escapes | 6 | 0.0 | 0.0 | 0.0 |

Lock wait behind other gates: 80.6 min across 9 PRs.

Top failing steps: `Run the gate` (7), `Confirm the pinned tools` (1).

## Planning misses

Miss lines: 218, in 63 of 130 merged PRs.

| Class | Misses | Per 100 merged PRs |
|---|---|---|
| mechanism | 30 | 23.1 |
| file-list | 21 | 16.2 |
| permission | 0 | 0.0 |
| design-gap | 12 | 9.2 |
| stale-fact | 11 | 8.5 |
| owner-call | 0 | 0.0 |
| no-answer | 0 | 0.0 |
| conflict | 5 | 3.8 |
| estimate | 3 | 2.3 |
| ambiguous | 3 | 2.3 |
| untagged | 133 | 102.3 |
| Total | 218 | 167.7 |

## Notes

- Gate records read: ~/.local/state/cairn-run-gate/runs.jsonl
- Dropped gate records: 1015
- Malformed lines or rows skipped: 1
- PRs with no score: 59
