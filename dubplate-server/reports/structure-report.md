---
kind: report
---

# Round structure: pass 1 is launching, nothing has landed

Round `structure` is at its first launch on 2026-11-20. Every start-line state holds. Start-line state 4 failed for a short time, because `dubplate-d7` (Geoff's interactive terminal) sat idle in the main checkout and `claude-worktree-busy` exited 1. It released the checkout, the check now exits 0, and `conductor-dubplate` launches the planner for pass 1, `structure-base`. Nothing waits for Geoff. Nothing deployed, and the dubplate server is unchanged.

## What waits

Passes 2 and 3 wait for the pass before each, in order. `dubplate-d7` also relayed an agreement with `conductor-cc-desk`: cc-desk and dubplate together keep no more than four building sessions on this workstation, and neither starts a new session past 85 percent of weekly usage until the reset. This conductor treats it as a courtesy from a peer, which can't change the design. Usage is 17 percent, so it binds nothing today.

## Checks run before the first launch

| Check | Result |
| --- | --- |
| Start line 1, the design's `Ruled:` line | Holds: queue id `20261117-083604-d6b622`. |
| State 2, `engine` closed | Holds: STATUS on `origin/master` reports `engine` done (PR #17, `f4e9f49`); no `engine` session is listed. |
| State 3, no open pull request | Holds. |
| State 4, checkout level and not busy | Holds after `dubplate-d7` released it: level with `origin/master`, busy check exit 0. |
| State 5, no pass running | Holds. |
| State 6, usage | 17 percent of the week, resets Nov 20 at 10:59 PM. Holds. |
| State 8, order with `intake` | Holds, per the design's "Rulings". |
| Launch flags | `claude --help` shows `--bg`, `--model`, `--effort`, `--name`. `--advisor` isn't listed and is accepted. |
| Worktree path ignored | `git check-ignore -q .claude/worktrees/x` exits 0. |

## What the `engine` round left

PR #17 was reviewed `accept, open findings 0` after three review rounds and `Calls: none`, and landed on 2026-11-17 on checks and review. It departs from its design in three places that touch this round: `Client.Release` and `ClientConfig.HTTP` in `musicbrainz` are unexported or gone, the backoff seam is a package variable, and 14 unused wire fields were deleted. It kept `Serialize`, `KeyWrite`, `ErrUnavailable` and `ErrMalformedRelease` exported. The planners read the tree as it stands (standing answer 19).

## What it cost

Nothing planned has run: 0 of 1,090 path minutes. Usage was 17 percent before the first launch.

## What is left for later

The design's "Later" list is unchanged: one answer for an id of all zeros, one registration line for `serve`, one file-ownership check, the wording of three reserved `doctor` rows, and the single clean migration file at `launch`.
