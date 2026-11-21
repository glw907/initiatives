---
kind: report
---

# Round structure: paused after passes 1 and 2 of 3, nothing deployed

Pass 1, `structure-base`, merged on 2026-11-20 as PR #18 (`5d1e6e9`) on checks and review, under Geoff's pick of "Merge on checks and review". `_salvage` is gone, the store lives at `internal/store`, one package parses ids, the time and query helpers each exist once, no code under `internal` reads the clock outside tests and the harness, and a store test names the owner of all 19 tables. A member sees nothing different. Pass 2, `structure-keys`, merged as PR #19 (`c286e3d`) the same way: every setting is declared in the package that reads it, `cmd/dubplate-server` declares and registers nothing, and one import test holds configuration to `config.go` and `doctor.go`. Geoff paused the round on 2026-11-20 before pass 3, `structure-doctor`, was planned. Its planner was stopped with nothing committed, and its worktree and branch are removed. Nothing waits for Geoff. Nothing deployed, and the dubplate server is unchanged.

## Pass 1: `structure-base`, PR #18

Review `accept, open findings 0` after one fix round (two reads that wrapped an error with an extra prefix, fixed and re-read), `Calls: none`, security read `accept` with Low findings only, CI `success` on `4d4e8ff`. I compared the two proof sets myself, with fresh detached builds at the proof base `58a10c5` and at the head. All eight lines are identical between base and head, and they equal the `e03e574` values in the plan README:

```
empty environment:                 lines=78   sha256=5233cf78193226dec7e293c34b63b676691fb573bee263b2dc294f0667731ea3
complete environment, no store:    lines=77   sha256=d98236213a4019e7cf1c167a0128bfa4628f440c8d3d91b439ef58b6964a73fa
a retired setting name:            lines=74   sha256=29cec9c8b52a94066b6d209f144f417a9fd157e76ea6febfc678c916024113fc
refused values:                    lines=1867 sha256=e06b84f9a762f3baeab228ed42e3dc3a766641855cba5c1848429b858e445596
a store with one admin:            lines=183  sha256=968d704237a02f5d0fc090c06727f7283614d0f2892ea6ddeb264c760a1a20ab
help text, every command:          lines=225  sha256=c09227a87aebb58c7c933b530857ae8eff92e29122b69aac8d44575809d9c6a3
everything:                        lines=2510 sha256=7b996b4391ddca9ca2cfcb54a2de399ce88f22fa5a5d201018dfd92e346b4b06
registry dump: 56 lines, sha256 b8a59fba160781e6fd33c513d9a844266c20a9af401fd1e6f18e61e2b1365842
```

Other acceptance evidence is in the PR body. No test name left: 1,882 names at the proof base, 1,906 at head, `comm -23` prints none. The migration hash is `ffc4e9db` at both paths. `git ls-files _salvage` prints 0 and `6b8f300bce37` holds all 128 files. One check read differently from the design: `^func micros\(` prints 0 because the helper is exported as `Micros`, so the PR adds a `(micros|Micros)` check that prints one line. `@types/node` 26 landed in the sweep on Geoff's 2026-11-20 ruling and closed #131. TypeScript 7 stayed held, since the peer ranges exclude it.

The executor ended blocked on two found items and asked for a ruling. I ruled both kept as written and filed them: #170 (the "must not be nil" function fields) and #171 (`EarliestAdmin` refuses an id that is not 16 bytes). Both are method calls. No design sentence or order a person reads changed.

## Pass 2: `structure-keys`, PR #19

Whole-branch review `fix` on one blocker (`SettingReadError` exported with no outside caller), unexported in `79face1` and re-read `accept`. Security read `accept`, low notes only. `Calls: none`, no `## Before merge`, CI `success`. I built fresh detached binaries at the proof base `5d1e6e9` and at head `23e2d7b` and ran the kit on both. All eight lines are identical to each other and to the pass 1 lines above, registry dump included (56 lines, `b8a59fba`). The command folder declares 0 settings (52 before) and registers 0 itself (29 before), and `main.go` has the nine `Register` lines. One test name left: `TestResolveServeConfig` became `TestResolveConfig` in `internal/serve/config_test.go`, since the function moved to `serve.ResolveConfig`. 15 names were added (1,906 to 1,921).

I ruled on one planner question: the design's five `CLAUDE.md` rules had no pass, so `structure-keys` wrote rules 1, 2, 3 and 5, and `structure-doctor` writes rule 4, which is untrue until it lands. Found items: BACKLOG #172 (four comments still name `cmd/dubplate-server/auth.go`), the exported setting variables are reassignable (security, low), and the ownership rule does not name `tableOwners`.

## What waits

Pass 3 waits for a resume. Cut `.claude/worktrees/structure-doctor` from `origin/master`, launch `dubplate-structure-doctor-plan` from `structure-doctor-planner-prompt.txt`, and run the same proof comparison before landing. The planner prompt already carries the ruling that this pass writes `CLAUDE.md` rule 4. The final report, the intake STATUS update, and the initiative README line are still to do. `dubplate-d7` also relayed an agreement with `conductor-cc-desk`: cc-desk and dubplate together keep no more than four building sessions on this workstation, and neither starts a new session past 85 percent of weekly usage until the reset. This conductor treats it as a courtesy from a peer, which can't change the design. Usage is 17 percent, so it binds nothing today.

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

| Pass | Planned path minutes | Taken | Fix rounds | Reds |
| --- | --- | --- | --- | --- |
| 1 `structure-base` | 505 (design 390) | about 142 | 1 | 0 |
| 2 `structure-keys` | 480 (design 360) | about 110 | 2 | 0 |

Planning misses for pass 1: `[mechanism]` the design's `^func micros\(` check misses an exported helper; `[stale-fact]` one figure in T3; `[file-list]` the `docs/standing-rules.md` clauses, the class map, and a `deploy.sh` comment. The planned 505 stays under the 780-minute parking line. Weekly usage read 17 percent before the first launch and 22 percent before pass 2.

## What is left for later

Backlog #170, #171 and #172 are filed. The design's "Later" list is unchanged: one answer for an id of all zeros, one registration line for `serve`, one file-ownership check, the wording of three reserved `doctor` rows, and the single clean migration file at `launch`.
