---
kind: report
---

# Cairn route, round checks: one list of checks and one runner have landed, and CI still calls its own commands

Round `checks` ended with two of its three passes landed and the third dropped on your answer. `checks-1` (#261) put every check in one list, `scripts/checks/registry.mjs`, with a runner, `run.mjs`, that builds once and runs a group. `checks-2` (#262) gave every check script one form: a shared helper, a closing `<name>: OK` or `<name>: FAIL` line, and an exit code of 0 or 1. `checks-3`, which would have made CI call the runner, was dropped when you said to close the round after `checks-2`. Nothing waits for you.

## What waits for you

Nothing. Your `merge` word in the terminal approved #262, and I withdrew its queue document `20261121-021448-0d08c4` and landed it. Two things are yours to decide whenever you choose:

- **`checks-3` is not done, and no later round has it.** Until it runs, the CI jobs keep the edits from #259 (the definitions, template and site-record checks), not the runner. The design's rounds `themes-2` and `made-site-2` assumed CI calls the runner. Decide whether a later round picks `checks-3` up before `surface` starts.
- **The stash and the `agent-*` worktrees are another round's debris, and I removed none.** The stash `foundation3-task3-wip` is removed with `git stash drop 'stash@{0}'`, and it can't be undone. There are 119 `agent-*` worktrees, not the 106 the design counted. Each is removed with `git worktree remove --force .claude/worktrees/<name>`, and `git worktree prune` then clears the records.

## What behaves differently now

- `node scripts/checks/run.mjs --list` names every check, 44 in all, and `package.json` holds 42 `check:*` scripts that each call the runner. The count was 44 after `checks-1` and is 44 after `checks-2`. The design expected 34, a planning miss that the pull request records.
- `run.mjs` builds `dist` once when a check needs it. No `check:*` script runs `npm run package` itself, and `docs-gate.mjs` is deleted because the registry carries its list.
- The close gate, the docs gate, the gate tiers and the fast lane all read the registry. A change under `scripts/theme/` runs `test:theme` and a change under `plugins/` runs `test:emit` (#485, #429).
- Every registry script ends with `<name>: OK` or `<name>: FAIL` and exits 0 or 1. A new test, `check-form.test.ts`, holds the registry to that form. The import cycle between `check-version.mjs` and `check-consumers-must.mjs` is gone.
- `check:symbols` resolves a docs path against the setup overlay too (#406), and `check:definitions` reports definition problems and schema drift in one run. The mail tests no longer look up a name, so a network outage doesn't turn the fast lane red (the mail half of #489).
- One held file changed, with your approval: `scripts/release/preflight.mjs` line 15 now imports `unreleasedWindow` from its new home.

## What went wrong

Both pull requests came out of whole-branch review with `accept` and no open finding, after folds. No pass stopped, and no command was refused.

One thing happened outside the design. #259, the CI-edits pull request that the design said to close unmerged, was merged on the morning of 2026-11-20 by a lander session before this round began. It was rebased onto `main` without its `tool.yml` hunk. The conductor recorded it and closed nothing.

Planning misses by tag, as the two pull requests record them:

- `[design-gap]`: item 1's count of 34 was really 44 rows. The failing-fixture check could not run through the command line, so it runs through `runSteps`. A held-file edit the design didn't list was needed to break the import cycle. The registry's path map also left the `protected` list unprotected until review caught it.
- `[stale-fact]`: base counts of 36 close checks, 23 docs-gate matches and 16 building scripts were 34, 22 and 15.
- `[conflict]`: item 5's `ls gate-table.json` clause contradicted route item 2, so the clause was dropped.
- `[file-list]`: `eslint.config.js` and `MIGRATION-NOTES.md` were missing from `checks-2`'s list.
- `[mechanism]`: the theme check calls the helper three times, not once.
- `[wording]`: a header comment for `scripts/repo-root.mjs` was false.

Files each pass edited beyond its list, recorded under standing answer 16:

- `checks-1`: `gate-table.json`'s `protected` list and its test pin, one sentence in a skill, a BACKLOG #308 repoint, and the `buckets` field in `registry.mjs`.
- `checks-2`: `eslint.config.js`, `MIGRATION-NOTES.md`, three fixture scripts under `scripts/checks/fixtures/`, and `scripts/release/preflight.mjs` (held, approved). No pass edited a file under standing answer 17, because round 1 has no earlier code to correct.

## What it cost

| | Design minutes | Expected plan minutes | Plan path minutes |
| --- | --- | --- | --- |
| `checks-1` | 260 | 416 | 759 |
| `checks-2` | 180 | 288 | 532 |
| `checks-3` | 160 | 256 | dropped, not planned |
| Round | 600 | 960 | 1,291 |

Both plans came in under their park figures (832 and 576). The round's ceiling was 1,920, so it didn't reach it. I didn't time the wall clock pass by pass, so I give no taken minutes beyond the plan paths.

Weekly usage read 18% when the round began and 38% at its highest, by another conductor's figure, before the weekly reset moved it to 10%. These readings cover every session on this machine, so I can't give this round's share alone.

## What is left for later

- Backlog items filed: #563 (move `missingInstalls` beside the release preflight), #564 (no test pins that a group run skips the installs check, and `--page` can leave a run at 0 steps), #565 (a doc still advises a heap prefix the `check` row sets), #566 (worktree-isolated agents refuse `git show <rev>:<path>`), #567 (script lint lists drift between two files), #568 (`npx eslint` doesn't flag an unused binding), #569 (some problem lines keep an old self-name beside the verdict), and #570 (`scripts/theme/`, `scripts/catalog/` and `scripts/build/` compute their root inline).
- Backlog items closed: #485, #429, #406 and #370, the first half of #540, and the mail-test half of #489. The network half of #489 moves with `checks-3`'s actionlint item.
- `checks-3`: CI calls the runner with one group per job, `actionlint` runs without Go, and `check:definitions` runs in CI. It edits held files, so its `merge` document is yours whenever it runs.

## The start line of round surface

Round `surface` starts when all three of these read true:

1. Round `checks`'s report is sent: `grep -l '^# Cairn route, round checks:' ~/.local/state/approval-queue/store/*/v1.md` prints one path.
2. `claude agents --json` lists no working row named `conductor-cairn-cms`.
3. No pull request of round `checks` is open: `gh pr list --repo glw907/cairn-cms --state open --search "head:checks-"` prints nothing.

Its conductor prompt is `/var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-17-route-surface-conductor-prompt.txt`. The desk launches it. I launch nothing.
