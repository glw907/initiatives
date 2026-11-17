---
kind: report
---

# Round cleanup: four pull requests merged, nothing deployed

Round `cleanup` is done. In this report, a member is one person in the group that shares a library, with a sign-in to the dubplate server, and an admin is a member who may change the roster and the settings. Geoff approved the close packet `20261117-064744-b8dd9b` on 2026-11-17 with every recommended pick, and the queue merged pull requests #13, #14, #15 and #16 in that order. The round added no feature. The box is unchanged, nothing deployed, and no session connected to it. Round `engine` is next and has no design yet.

## What behaves differently now

Every pull request to dubplate runs `scripts/check.sh` as a check on GitHub (pass 1, `73bae3b`). The gate prints each leg's time and the full run takes 188 s where it took 223 s. The rendered leg went from 196 s to 149 s by opening 38 browser contexts for the same 190 captures, and Geoff accepted that reading in place of the design's 130 s target. A scoped run for one Go comment takes 14 s, or 54 s once `deadcode` joined.

A restore from a file makes the stage durable before the intent is recorded. The admin pages share one shell, one write notice and one fetch call, every button is `btn` at 45 px, and the settings key labels are 12 px. A network failure shows as an `alert-warning`. An admin operation checks privilege before it reads the body, roster audits name the actor, and the web API serves twelve operations: `catalog`, `start_backup`, `job_status` and `cancel_job` are gone. The web app's HTTP code lives in `internal/webapp`, and `cmd/dubplate-server/web.go` went from 860 lines to 249.

## Pull requests

| PR | Pass | Acceptance evidence |
| --- | --- | --- |
| #13 | `cleanup-gate` | Whole-branch review accept with nine non-blocking notes. Security read of `rendered_test.go` accept. One item unmet by design: the Vale leg's Go grammar is not installed (#135). |
| #14 | `cleanup-store` | Branch review accept, security read accept at `9821b6c`. A later deploy must first check that the box store holds no restore-intent record (#148). |
| #15 | `cleanup-web` | Four reviewers accept, no open finding. 210 captures in 105 files, with each difference from the base explained in the close packet. |
| #16 | `cleanup-ops` | Delta read accept at `bfd534a` after a whole-branch `fix` at `44eabdf`. Security read accept with seven Low findings. |

Each pull request had a green check on its head and a local `gate.sh --merge` at exit 0.

## What went wrong

Pass 2 planning misses: `[design-gap]` the design classed the pass `runner` while the path map makes `rendered_test.go` `auth-data`; `[design-gap]` item 3's 130 s is out of reach because 78 s of the leg runs before the captures; `[mechanism]` "190 captures" are 190 cells in 95 files; `[mechanism]` the plan named a `x/tools` version that module resolution rejects as a downgrade; `[mechanism]` the Vale plant assumed the Go grammar; `[mechanism]` BACKLOG #134 cited the wrong lines. Pass 3: `[design-gap]` the plan left #78's normalizer copies out, refiled as #147. Pass 1: one `[stale-fact]`, BACKLOG #26. Pass 4: `[mechanism]` mutation proofs aborted the run instead of failing the named rows (#152); `[stale-fact]` BACKLOG #19's line numbers; `[file-list]` `web_test.go`; `[mechanism]` svelte-check needs `make web-build`.

A machine restart on 2026-11-16 ended the conductor and the pass 4 executor, which died with three unpushed commits. The desk relaunched the conductor at 03:00Z on 2026-11-17 and the executor ran once more and finished.

## What it cost

| Pass | Planned path minutes | Actual | Fix rounds | Reds |
| --- | --- | --- | --- | --- |
| 1 `cleanup-ci` | 182 | 80 | 1 | 6 |
| 2 `cleanup-gate` | not recorded | 108 | 1 | 1 |
| 3 `cleanup-store` | see PR #14 | see PR #14 | | |
| 4 `cleanup-web` | 180 | about 290 | | |
| 5 `cleanup-ops` | 274 | 150 | | |

The round planned 600 path minutes in its chain. Weekly usage was 50 percent before the first launch, 64 percent before pass 5, and 77 percent at the close.

## Desk ruling

On 2026-11-17 the desk recorded Geoff's words "For this week, we'll want to get as close as we can to 100% before the reset." (queue document `20261117-055811-900560`), which lifted the 85 percent stop until the 2026-11-20 reset. Geoff also asked the desk to resume both the cairn and dubplate rounds after the restart.

## Backlog

Filed by the round: #129 to #134 (pass 1), #138 to #149 (pass 3), #150 to #155 (pass 4), #156 and #157 (pass 5), and #158 at the close: whether `doctor` should refuse an over-broad trusted-proxy range. Closed: #122, with #121, #123, #124 and #125 reworded. The close added the eight allow rules from finding G18 to `.claude/settings.json` (`7151edb`).

## Next

Round `engine` has no design yet. STATUS names it as the next action, and nothing was launched for it.
