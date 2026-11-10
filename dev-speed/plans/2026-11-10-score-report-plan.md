# Pass score report: plan

Initiative: dev-speed
Design: `dev-speed/specs/2026-11-10-score-report-design.md`, approved by Geoff in packet `20261110T092946-1899803` (2026-11-10). His one ask: count the wait on him as a separate row.
Repo: `glw907/workstation` (`~/.dotfiles`), adapter `dotfiles-pass`. Research files land in `glw907/initiatives`, which is public.
Class: `runner` (T1 adds `tests/**`, T3 edits `claude/.claude/skills/pass-core/SKILL.md`). T2 and T4 are `ordinary`.
Executor: `dotfiles-score-report`, Sonnet at `medium`, under `conductor-dotfiles`. No advisor: the model review's advisor trial covers one pass only (conductor-dotfiles, 2026-11-10).
Path estimate: 155 minutes. T1 (90, a pair subagent) runs while the session runs T2 (45) and then T3 (15). T4 (25) and the close (40) follow. Each task's clock stop sits at twice its estimate.

## Pre-flight

1. Geoff's ruling on what the public initiatives repo may hold from private repos (the ask in this plan's pre-launch packet). The plan assumes option (b) below until he rules. No task before T2's commit depends on the answer, so the launch doesn't wait for it. The executor checks STATUS for the ruling before T2's commit and before T4's, and waits there if none has come.

Permissions checked: each task's writes were read against auto mode. T1 writes `bin/.local/bin/pass-report`, `tests/test_pass_report.py`, and `tests/fixtures/pass-report/**` in the dotfiles worktree. T2 writes scratch files and `dev-speed/research/score-backfill.json` in an initiatives worktree. T3 writes `claude/.claude/skills/pass-core/SKILL.md` and `BACKLOG.md` in the dotfiles worktree. The skill file goes live only after the merge, and earlier executors have edited it in worktrees (workstation #205, #215). T4 writes `dev-speed/research/2026-11-10-score-report.md` and `dev-speed/README.md`. Nothing touches `settings.json`, a credential, or `~/.claude` directly. `gh` reads every `glw907` repo (all 19 in `gh repo list`, checked 2026-11-10). Pushes go to `glw907/workstation` (branch `score-report`) and `glw907/initiatives` (see the standing answers). Under the ruling's option (b), no quoted private-repo prose is pushed, so a content refusal is not expected.
Reviewed: `standards:plan-reviewer` (Opus, medium), 2026-11-10. Its findings F1 to F21 are folded below. F10 became the pre-flight ask.

## Publication rule (pending Geoff)

Ten repos are private: survey-notes, servers, aksailingclub-legacy, fishwright, phonebook, cairn-rc2-install, ecxc-ski, sportsyou-notify, cairn-themes, cairn-pub. The options:

- (a) Publish everything, quoted notes included.
- (b) Recommended. Publish figures and failing step names for every repo. A private repo's backfill rows carry `note: null`, and the full notes stay in a scratch copy for the Sonnet check. The baseline already publishes private-repo figures.
- (c) Keep the backfill and the report out of the public repo, under `~/.local/state/pass-report/`.

Under (c), T2's and T4's output paths move to `~/.local/state/pass-report/`, nothing is pushed to initiatives but the README line, and `--backfill`'s default follows.

## Shared contracts

The score line, written by every pass PR from now on and read by T1:

```
<!-- pass-score {"planPathMin": 170, "actualPathMin": 140, "fixRounds": 1, "reds": 0, "attended": 2, "escapes": 0} -->
```

Each value is an integer or `null`. It sits on a separate line below the score table.

The backfill file, written by T2 and read by T1 through `--backfill`:

```
{"version": 1, "rows": [{"repo": "cairn-cms", "pr": 210, "planPathMin": 955, "actualPathMin": 115, "fixRounds": 3, "reds": 1, "attended": 0, "escapes": 0, "note": "actual is 'about 115 minutes'"}]}
```

A PR body's score line wins over its backfill row. The default `--backfill` path is `$PASS_REPORT_HOME/Projects/initiatives/dev-speed/research/score-backfill.json`.

## Tasks

### T1. The `pass-report` command (runner, 90 min, the pair subagent)

Dispatched as a worktree-isolated Agent subagent with the description `score-report task 1`. Its prompt quotes this task in full and tells it to run git as plain, separate calls from its worktree path, per pass-core "Pairs".

Outcome: `pass-report [--since YYYY-MM-DD] [--repo NAME]... [--records FILE]... [--backfill FILE] [--no-cache]` prints a Markdown report on stdout. The default window is the last 30 days. Files: `bin/.local/bin/pass-report` (stdlib Python, `#!/usr/bin/env -S python3 -I`), `tests/test_pass_report.py`, and `tests/fixtures/pass-report/`.

Test seams, all from the environment: `PASS_REPORT_GH` names the `gh` binary (default `gh`), as `INITIATIVES_GH` does in `~/Projects/initiatives/scripts/check`. `PASS_REPORT_HOME` sets the home root for the toplevel mapping and the default state paths (default `$HOME`). The cache root is `${XDG_CACHE_HOME:-$HOME/.cache}/pass-report`. The tests feed canned JSON through a fake `gh` script and never call live `gh`.

Sources and joins:

- Repos: `gh repo list glw907 --json name --limit 200`, narrowed by `--repo`.
- PRs: `gh pr list -R glw907/<repo> --state merged --search "merged:>=<since>" --json number,headRefName,createdAt,mergedAt,body --limit 300`.
- CI runs: `gh run list -R glw907/<repo> --created "<a>..<b>" --json databaseId,workflowName,headBranch,headSha,event,conclusion,status,startedAt,updatedAt --limit 1000`. The list caps at 1,000 results per query, so a range that returns exactly 1,000 is split in half and each half refetched, recursively. Only runs with `status == completed` count, and runs with `event == dynamic` (such as `pages-build-deployment`) are skipped. A run's interval is `startedAt` to `updatedAt`. A PR's CI wait is the length of the union of the intervals of every run on its branch between `createdAt` and `mergedAt`, so overlapping runs count once. Runs on the default branch with `event == push` form the "CI on the default branch" row, one figure per run.
- Failing steps: `gh run view <id> -R glw907/<repo> --json jobs` for each run whose conclusion is `failure`, taking the first failed step of each failed job.
- Gate records: `$PASS_REPORT_HOME/.local/state/cairn-run-gate/runs.jsonl` plus each `--records FILE`. A toplevel maps to a repo name by its path: `~/Projects/<name>` and anything under it, and `~/.dotfiles`, `~/.dotfiles-*`, `~/Projects/workstation-wt/*`, and anything under them map to `workstation`. A mapped name counts only if it appears in `gh repo list`. A record with no counted name joins by branch when exactly one merged PR in the window, across all repos, has that `headRefName`. Any other record is dropped and counted in the footer. A record joins a PR only between the PR's `createdAt` minus 7 days and its `mergedAt`, since some branch names repeat. Gate seconds are `end - start - lockWaitSeconds` for `kind: gate` records with `outcome: exit`, as `cairn-run-gate --records` computes them (`cairn-run-gate:118-122`). A `kind: ci` record joins by repo and its `pr` field.
- Decisions: `$PASS_REPORT_HOME/.local/state/approval-queue/decisions.jsonl`, lines whose `kind` is `pr` or `design`. A `pr` ref is `glw907/<repo>#<n>`, and a `design` ref is `glw907/<repo>:<path>`; each wait lands in the table of its ref's repo. The queued time is the packet id's leading `YYYYMMDDTHHMMSS`, read as `zoneinfo.ZoneInfo("America/Anchorage")` local time (DST-aware). The decided time is the line's `time`, in UTC. A negative wait is dropped and counted in the footer.
- Scores: the `pass-score` line in each PR body, else the backfill row.

Each repo with any data gets one table with a row per measure, and columns `n`, median, 90th percentile, and total where a total means something:

| Row | Measure |
|---|---|
| PR open to merge | minutes per merged PR |
| Local gates | gate minutes per PR, plus lock wait |
| CI wait on the PR | minutes per PR, as above |
| CI waits a session sat through | `ci` record minutes per PR |
| CI on the default branch | minutes per push run |
| Reds | failed runs over all completed runs, as a rate, and the top five failing steps with counts under the table |
| Waiting on Geoff | minutes per decided part |
| Planned against actual | path minutes, both columns, and the ratio's median |
| Fix rounds, attended events, escapes | per scored PR |

A repo with no data in the window prints one line saying so. The footer states the window, the records files read, the counts of dropped gate records, negative waits, malformed lines, and PRs with no score, and each repo whose data is partial (see the rate-limit standing answer).

Input states:

| Input | Result |
|---|---|
| `runs.jsonl`, `decisions.jsonl`, or the backfill file absent | a footer line names it as not found, and the run goes on |
| A malformed JSONL line, backfill row, or `pass-score` JSON | skipped and counted in the footer as malformed |
| A `--records FILE` that doesn't exist | exit 2 with a message naming the file |
| A `gh` call that fails for another reason | exit 1 with `gh`'s message |

`gh` output is cached under the cache root by repo, command, and window. A finished run's `jobs` never changes, so those entries never expire; the rest expire after one hour. `--no-cache` skips the cache.

Acceptance: `pytest tests/test_pass_report.py` passes against fixtures, one for each of these:

1. A PR whose branch ran on three head SHAs with overlapping runs: the wait is the union, not the sum.
2. A run range the fake `gh` answers with exactly 1,000 runs: the command splits it and counts the runs from both halves.
3. A gate record from a worktree toplevel folds into its repo.
4. A record under `~/.claude/jobs/x/tmp/dot-wt` with a branch unique to one merged PR joins that PR. A record under `~/.cache/wt-x` with an unknown branch is dropped and counted.
5. Packet `20261110T093000-1` decided at `2026-11-10T19:00:00Z` waits 30 minutes. The real line `20261017T104118-428179` decided at `2026-10-17T18:42:18Z` waits 1 minute; a fixed UTC-9 offset fails this case.
6. A PR body's score line beats its backfill row.
7. A malformed JSONL line is skipped and counted.
8. A repo with no data prints its one line.

The subagent breaks each of the eight behaviors by hand once, sees its test fail, and restores it. `ruff` (the gate's docstring leg) is clean, and `bash scripts/gate.sh` passes.

Two live checks run by full worktree path, since the script isn't on PATH before the merge and `stow -R bin`: `/var/home/glw907/.dotfiles/.claude/worktrees/score-report/bin/.local/bin/pass-report --repo workstation --since 2026-11-01`.

- Its "PR open to merge" `n` equals `gh pr list -R glw907/workstation --state merged --search "merged:>=2026-11-01" --json number --jq length`.
- For one workstation PR in the window whose gate records all sit under one toplevel, the gate seconds the command computes for that PR equal the sum `cairn-run-gate --records <toplevel> <branch>` prints. The session reads the command's figure by loading the script as a module, as `tests/test_phone_check.py` does, and calling its join for that PR.

On a mismatch, run both commands once more, since live data moves. A second mismatch is a bug to fix.

### T2. Backfill the old scores (ordinary, 45 min, the session, while T1 runs)

The session runs this itself, in the initiatives worktree by absolute path, with plain `cd <worktree> && git ...` calls. It doesn't go to a pair subagent.

Outcome: `dev-speed/research/score-backfill.json` holds one row per merged PR whose body has a `Score` heading, in every `glw907` repo, in the shared shape and under the publication rule.

Steps:

1. For each repo in `gh repo list glw907 --json name --limit 200`, the executor pipes `gh pr list -R glw907/<repo> --state merged --limit 300 --json number,body` to `jq -r --arg r <repo>`. It captures each section with the regex `(?ms)^#+ *Score[^\n]*\n(?<s>.*?)(?=^#+ |\z)` into one scratch file, under one `=== <repo> #<n>` header per section. `gh --jq` rejects `--arg`, so the capture runs in `jq`. The review counted 133 sections across 15 repos, about 30k tokens.
2. One Haiku dispatch, naming effort `low` explicitly (an unnamed effort runs at `medium` under `CLAUDE_CODE_SUBAGENT_EFFORT`), copies each section into a row. It writes `null` for any figure the prose doesn't state, and a `note` quoting the phrase it read for each non-null minutes figure. It decides nothing: a range or "about" takes the stated number, and a figure for the whole pass in a task PR is `null`.
3. One Sonnet dispatch at `medium` checks ten rows the executor picks (two from each of the five repos with the most rows) against their PR bodies.
4. Under rule (b), the executor sets `note` to `null` on every private-repo row of the committed file, and keeps the full file in scratch.

Acceptance: the row count equals the section count in the scratch file. Each row's `repo` and `pr` name a merged PR. The Sonnet check finds no wrong non-null figure in its ten rows. A wrong one sends Haiku's output back once with the finding quoted, and the ten are rechecked. A row still wrong after that is fixed by hand from its PR body and listed in `## Decisions`. Under rule (b), `jq '[.rows[] | select(.repo == "<each private repo>") | .note] | map(select(. != null)) | length'` prints 0 for the committed file.

### T3. The score line in `pass-core`, and backlog #10 (runner, 15 min, the session, after T2)

Before editing, the session runs `git fetch origin && git merge origin/main` in the dotfiles worktree, so the edit sits on whatever of PR #223 has merged.

Outcome: `pass-core` "Score" gains one paragraph after its first sentence. The paragraph says the PR body carries the `pass-score` comment below the table, names the six fields and their meaning, and says only figures no machine records go in it. `BACKLOG.md` #10 drops its fixed half (the sentence "Also fix `cairn-run-gate --records`, which prints epoch-sized values instead of durations.") and gains the tag `#initiative:dev-speed`.

Acceptance: `grep -c 'pass-score' claude/.claude/skills/pass-core/SKILL.md` prints at least 1. Today it prints 0. `grep -n 'epoch' BACKLOG.md` prints nothing. Today it prints line 119. The gate and `claude-tooling-sync verify` pass.

### T4. The first report (ordinary, 25 min, after T1, T2, T3)

The session merges T1's branch into the session's branch and runs the gate. Then it runs `/var/home/glw907/.dotfiles/.claude/worktrees/score-report/bin/.local/bin/pass-report --since 2026-10-10 --backfill /var/home/glw907/Projects/initiatives/.claude/worktrees/score-report/dev-speed/research/score-backfill.json`. It commits the output as `dev-speed/research/2026-11-10-score-report.md`, with a short opening paragraph naming the command, the window, and the host. The dev-speed README "Records" list gains a line for both research files.

Acceptance:

- The file has a table for each of cairn-cms, workstation, aksailingclub-org, poplar, and cairn-pub.
- The cairn-cms "CI wait on the PR" `n` is at least 90% of its "PR open to merge" `n`. The review's full-data probe gave 108 of 109, and a 1,000-run cap gives 31.
- The cairn-cms "CI wait on the PR" median falls between 15 and 60 minutes. The review's probe gave 33.9.
- Under rule (b), the file quotes no PR body text from a private repo. Its private-repo tables hold figures and failing step names only.
- `scripts/index` and `scripts/check` pass in the initiatives worktree.

A check that fails is a T1 bug to fix in T1's files, not a finding.

### Close (40 min)

The `dotfiles-pass` close checklist runs:

1. The gate on the head.
2. `gitleaks git`.
3. `claude-tooling-sync verify`.
4. One whole-branch `standards:diff-reviewer` read with `standards:python-conventions` loaded.

The PR body opens with `## Brief`. It carries `## Decisions` and `## Planning misses`, then the score table with a `pass-score` line for this pass. It attaches the first report by path and names the initiatives CI verdict on each pushed commit. The executor marks the PR ready, reports to `conductor-dotfiles`, and ends. The conductor sends the packet. After the merge, the conductor runs `stow -R bin` in the main checkout, since the pass adds a script.

## Standing answers

- A task's clock passes twice its estimate while each retry fixes a cause the session traced: go on. The session rewrites `start=` in `.pass-task-clock` (the pass-core "Clock stop" resume rule), so the hook stops firing, and records the overrun in `## Decisions`. The pass-level path clock lives in STATUS. The pass may run to 310 path minutes (twice the estimate) and on to 465. Past 465, it stops and writes the cause in STATUS.
- A backfill section with no figure for a field: `null`, and the PR counts as unscored in that row.
- A repo with no PRs or runs in the window: its one line says so.
- `gh` returns a rate-limit error: wait for the reset time it names, at most 15 minutes. Then go on from the cache, and mark each repo whose data is partial in the footer.
- A gate toplevel that maps to no repo and no unique branch: drop it and count it in the footer.
- The push to `glw907/initiatives` `main` is rejected as non-fast-forward, because another session pushed first: run `git pull --rebase origin main` in the initiatives worktree and push once more. A rebase conflict, or a push auto mode refuses, falls back to a branch `dev-speed-score-report` and a PR there, named in the dotfiles PR body so the conductor's packet carries both.
- After each push to initiatives, run `gh run list -R glw907/initiatives --commit <sha> --json status,conclusion`. A red is fixed forward in the same worktree before the next task.
- T4's checks fail: treat it as a T1 bug, fix it in T1's files, and rerun T4. If the cause can't be traced, ship the report with the row marked unverified and raise it in `## Decisions`.
- The thinkpad's records: `ssh -o BatchMode=yes -o ConnectTimeout=10 thinkpad-x1 true`. If it succeeds, copy its `runs.jsonl` with `scp -o BatchMode=yes -o ConnectTimeout=10` to scratch and pass it with `--records`. If it fails, skip, and the report's footer says the thinkpad's records weren't read. On 2026-11-10 the host didn't resolve from pavilion.
- No publication ruling in STATUS when T2's commit is due: commit nothing to initiatives, go on to T3, and wait at T4 for the ruling. The conductor relays it.

## Escalation

T3 may be escalated without breaking the outcome: the report works without the score line, which only affects passes that close after it. T1, T2, and T4 can't be.
