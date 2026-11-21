# What a task really costs: measured minutes from 20 past passes

Scope: read-only research for the process spec. Nothing outside this file was changed. Words: spec, task, step, goal, session. In the old files a "task" is one numbered unit in a pass plan, so I call it a step here.

## Short answer

- Data is thin but usable: 20 passes with a plan estimate, a plan path, a step count, a report time and git times. One more (desk-run, pass 6) has no finished figure. Per-step measured minutes do not exist anywhere (not stated). Everything below is per pass.
- Round estimate P (the minutes a round plan gave a pass) is right on average: median measured/P is 0.83, mean 1.10. It is a weak guide to which pass runs long (correlation 0.36).
- Plan path (the pass planner's own sum) runs high: median path/P is 1.75, and measured/path has median 0.52 (range 0.31 to 1.35). Scaled by 0.5 it ranks passes best (correlation 0.82).
- Step count predicts almost as well and needs no planning: median 8.75 minutes per step (range 5.0 to 23.3). Leave-one-out median error is 23% for steps, 26% for plan path, 46% for P, 70% for diff size.
- Diff size predicts worst (correlation 0.41, slope about 7 minutes per 1,000 changed lines on 19 passes, intercept about 55).
- Geoff's cap, "no new task past twice its planned minutes", would have stopped 1 of 20 passes on measured minutes (desk-check). The old plan-path rule parked 4 of 21 traceable passes, and every one was later built.
- The cheapest recording is a SessionStart plus Stop hook that appends a timestamp line. Both are documented. Hook input carries no clock field, so the script stamps the time itself.

## How each number was made

| Column | Source |
|---|---|
| Round estimate P | the pass's line in its round plan, `/var/home/glw907/Projects/cc-desk/docs/plans/*-round.md` (state-rules line 14, page line 13, sessions line 13, desk-skills line 14; desk raises at answers 28, 31, 35, 36, 38, lines 256-331; Prove 530 in `route.md`) |
| Plan path, Steps | header of each `docs/plans/*-plan.md` in the same folder |
| Report minutes M | "What it cost" tables in `/var/home/glw907/Projects/initiatives/cc-desk/reports/`: state-rules-report.md lines 109-121, page-report.md 150-167, sessions-report.md 149-167, desk-report.md 152-163 (stops 106-116, 140-146). Stuck-sessions: `/home/glw907/.local/state/cc-desk/releases/cc-desk.json` lines 57 and 64 (60 planned, 33 actual) |
| Commit to PR ready, to merge | GitHub PR timeline through `gh`: first commit time to the `ready_for_review` event, and to `mergedAt`. The PR `createdAt` is the draft plan commit, so I did not use it as "PR open". Raw files: `.../scratchpad/mm/pr*.json` and `tl*.json` |
| Diff lines | `gh pr` additions + deletions, `mm/size.json` |
| M/P, M/path | computed |

Data limits, in plain words:
- The report minutes are written by each round's conductor. The definitions differ. desk-skills (140) includes a 58 minute park, desk-open does not appear to (desk-report.md 152-163). Adjusting desk-skills to 82 barely moves the results.
- Commit-to-ready begins at the first plan commit, so it can start before the executor session. PR 21 (desk-check) was marked ready before its last fix commits, so its git figure (1,118) is wrong in both directions. Use the report figure (425 working minutes).
- Merge time is mostly Geoff's waiting. The "to merge" column is not work.
- The Fable review claims 1,405 plan-path minutes against 355 measured for nine PRs (desk-report.md line 90 area; the review is `desk-failure-review.md`). I could not reproduce either total. My 20 passes sum to P 1,580 and M 1,753. Treat Fable's ratio as not confirmed.
- `/home/glw907/.local/state/cc-desk/check-log.jsonl` and `forecasts.jsonl` hold no estimate data. `releases/done/*.json` hold scratch runs only.

## Per-pass table

| Pass | PR | Round estimate P | Plan path | Steps | Report minutes M | Commit to PR ready (git) | Commit to merge (git) | Diff lines (add+del) | M/P | M/path |
|---|---|---|---|---|---|---|---|---|---|---|
| state-files | 3 | 90 | 123 | 8 | 40 | 18 | 20 | 4562 | 0.44 | 0.33 |
| state-estimate | 4 | 75 | 115 | 5 | 44 | 18 | 19 | 2073 | 0.59 | 0.38 |
| state-order | 5 | 90 | 175 | 8 | 54 | 31 | 41 | 3087 | 0.60 | 0.31 |
| state-rulings | 6 | 60 | 115 | 8 | 46 | 32 | 33 | 2295 | 0.77 | 0.40 |
| page-front | 7 | 90 | 125 | 6 | 70 | 57 | 504 | 4750 | 0.78 | 0.56 |
| page-items | 9 | 75 | 85 | 5 | 40 | 27 | 436 | 1359 | 0.53 | 0.47 |
| page-surface | 11 | 60 | 105 | 5 | 60 | 50 | 394 | 1453 | 1.00 | 0.57 |
| page-link | 13 | 30 | 52 | 4 | 55 | 27 | 321 | 981 | 1.83 | 1.06 |
| page-polish | 15 | 90 | 80 | 5 | 30 | 19 | 284 | 635 | 0.33 | 0.38 |
| sess-check | 8 | 90 | 158 | 8 | 70 | 39 | 527 | 4269 | 0.78 | 0.44 |
| sess-launch | 10 | 90 | 175 | 8 | 70 | 46 | 479 | 3935 | 0.78 | 0.40 |
| sess-prompts | 12 | 60 | 110 | 7 | 60 | 27 | 401 | 2443 | 1.00 | 0.55 |
| sess-merge | 14 | 60 | 100 | 8 | 65 | 41 | 367 | 3192 | 1.08 | 0.65 |
| sess-timer | 16 | 75 | 150 | 10 | 110 | 84 | 304 | 2302 | 1.47 | 0.73 |
| desk-records | 17 | 120 | 209 | 12 | 107 | 57 | 67 | 5494 | 0.89 | 0.51 |
| desk-skills | 18 | 75 | 170 | 6 | 140 | 109 | 240 | 1650 | 1.87 | 0.82 |
| desk-page | 19 | 90 | 170 | 10 | 90 | 49 | 51 | 2060 | 1.00 | 0.53 |
| desk-open | 20 | 100 | 255 | 9 | 144 | 260 | 262 | 3695 | 1.44 | 0.56 |
| desk-check | 21 | 100 | 315 | 11 | 425 | 1118 | 1362 | 4849 | 4.25 | 1.35 |
| stuck | 24 | 60 | 70 | 4 | 33 | 30 | 30 | 796 | 0.55 | 0.47 |

Per round (sum of P, sum of M, sum of path): state 315, 184, 528; page 345, 255, 447; sessions 375, 375, 693; desk (five passes) 485, 906, 1119; stuck-sessions 60, 33, 70.

## Spread

| Ratio | Median | Mean | Smallest | Largest |
|---|---|---|---|---|
| measured / P | 0.83 | 1.10 | 0.33 (page-polish) | 4.25 (desk-check) |
| measured / path | 0.52 | 0.57 | 0.31 | 1.35 (desk-check) |
| path / P | 1.75 | 1.78 | 0.89 | 3.15 |

- Without desk-check: measured/P median 0.78, mean 0.93, worst 1.87 (desk-skills as reported; 1.09 if its park is removed).
- Measured minutes per pass: median 62.5, shortest 30, longest 425.
- Worst ratio: desk-check at 4.25 times P. Next: desk-skills 1.87, page-front 1.83, desk-open 1.44, sess-timer 1.47.
- Rounds differ. State passes ran at 0.44 to 0.77 of P. Desk passes ran at 0.89 to 4.25. The later the round, the worse the plan, and the desk round was the first to price live proving of each item (round-estimates-priced-from-evidence.md lines 12-17).

## Does anything predict minutes better than the plan did?

All 20 passes, minutes are report minutes. Correlation first, then leave-one-out: guess each pass from the median ratio of the other 19, report the median absolute error.

| Predictor | Pearson | Spearman | Leave-one-out median error | Worst |
|---|---|---|---|---|
| Steps (count) | 0.54 | 0.69 | 23% | 77% |
| Plan path | 0.82 | 0.76 | 26% | 72% |
| Files changed | 0.63 | 0.67 | 31% | 155% |
| Round estimate P | 0.36 | 0.44 | 46% | 168% |
| Diff lines, minus plan files | 0.41 | 0.50 | 70% | 372% |

Reading:
- Plan path ranks passes well but is about twice too high. Scaled by 0.52 it is as good as step count.
- Step count needs no planning and gives about 9 minutes a step. The range per pass is wide (5.0 to 23.3), and the high end is desk-check and desk-skills.
- Diff size is the worst guide. Doc-heavy passes (page-polish, 621 lines, 30 minutes) and code-heavy passes both break it.
- Raw P, used as the guess itself, is off by a median 31% and worst 200%. Raw path is off by 92%.
- n is 20 and the passes are from one author, one repo and four weeks. The ranking of steps against path is within noise. Do not quote the decimals as law.

## Geoff's cap, "no new task past twice its planned minutes"

Status: proposed, not ruled on (`/var/home/glw907/Projects/cc-desk/docs/specs/2026-11-20-process-decisions.md` lines 116-126; "estimates priced from measured minutes" is owed, about line 133).

Per-step cap: cannot be tested. Per-step planned and measured minutes are not recorded anywhere (not stated). Only pass totals exist.

Per-pass reading (stop starting new work once a pass's measured minutes pass 2 times P):
- Stopped: 1 of 20, desk-check (425 against 200). It was stopped, in fact, by the old stop at 350 and Geoff allowed it past (desk-report.md 106-116, "Fix it now, go past 350").
- Near misses: desk-skills 0.93 of 2P (0.55 if its park is removed), page-link 0.92, sess-timer 0.73, desk-open 0.72. Pass 6 (desk-run) stopped for billing at about 85 minutes with a 675 minute raised estimate (desk-report.md 144, 160), so it is no test.
- Cap on P is correct on the median but kills no ordinary pass: the next highest measured/2P is 0.93.

What the old rule did (stop at plan path above 2 times P, `round.md` "Parking at planning", standing answer 14):
- Parked: desk-skills (170 vs 75), desk-open (255 vs 100), desk-check (315 vs 100), desk-run (675 vs 90). desk-records (209 vs 120) and desk-page (170 vs 90) came close (round-estimates-priced-from-evidence.md lines 7-12, desk-report.md 90, 110, 144). That is 4 of the 21 passes I can trace.
- What happened: all four were raised, launched and built. desk-check waited about 10.5 hours for Geoff (desk-report.md 110). desk-open, desk-skills, desk-check took 0.72, 0.93 and 2.12 of 2P in measured time. desk-run stopped on billing, not on the rule.
- So a stop on plan path stopped passes that mostly ran under the line. A cap on measured working minutes would have fired once. It costs no wait, because it is checked while the session works, not at planning.

Questions the files cannot settle are in the last section.

## What the new process can record cheaply

Everything here is a start and end time per session plus the plan's step count. Labels: documented = named in hooks.md with the cited lines; assembled = built from documented parts, behavior not directly described; invented = my proposal, nothing documents it.

hooks.md is `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/hooks.md`.

| Record | Mechanism | Label |
|---|---|---|
| Session start time | A `SessionStart` command hook (lines 1309 and following; fires on `startup`, `resume`, `clear`, `compact`, `fork`) appends one JSON line: session_id, cwd, source, and a time the script reads from the clock. Input has `session_id`, `cwd`, `transcript_path`, `source` (lines 749-770, 1309-1330) | documented hook, assembled clock stamp |
| Session end | `SessionEnd` hook (line 3685) with `reason`; default timeout 1.5 seconds, enough for one append (lines 3705-3714). It does not fire for a killed process (not stated either way) | documented |
| Last working moment | A `Stop` hook (line 2853) fires each time the main agent finishes a response and not on a user interrupt (2845-2850). Appending a line each time makes the last line the end of work. Fields: `last_assistant_message`, `background_tasks`, `session_crons` | documented |
| A stuck or failed turn | `StopFailure` (line 2951), with `error`. Logs, no decision control | documented |
| Waiting versus working | The `Stop` input lists `background_tasks` and `session_crons` so a script can tell "done" from "paused for background work" (2853-2900) | documented |
| Per-agent run time | A foreground subagent's `PostToolUse` carries `totalDurationMs` and `totalToolUseCount` (lines 1960-1980). Not given for a background subagent (1982) | documented |
| Worktree created | `WorktreeCreate` (line 3259) fires for a background session's worktree. A configured hook replaces the default git behavior (3275), so use `WorktreeRemove` and `SessionStart` for logging instead, or take care to still create the worktree | documented, with a caution |
| PR open and merge times | GitHub timeline through `gh` (`ready_for_review`, `mergedAt`), as used above | documented in GitHub, assembled here |
| Steps and plan path | Count from the spec; a field in its header | assembled |
| Minutes per step price | Median 8.75 minutes per step from the table, kept as a number the spec edits when more passes arrive | invented |
| A single ledger file, one JSON line per session, joined to the spec by a spec id in the first prompt | | invented |
| "No new step past 2 times planned minutes" as a `/goal` or Stop hook that blocks stopping or ends new work | `/goal` is a session-scoped prompt-based Stop hook (about line 2859); a Stop hook can return `decision: block` and has an 8-in-a-row continuation cap (2862-2905). Using it as a minute counter needs the ledger above | assembled |
| Desktop alert when a background session ends | `Notification` matcher `agent_completed`, but it fires only while agent view is open in a terminal (line 2581). Not reliable for recording | documented, with a caution |

Not usable for recording: the debug log's hook durations (line 4359) time the hook, not the session. Nothing in hooks.md gives a total session minutes field, and no common field is a timestamp (lines 749-770). The "fires" times therefore come from the script's own clock.

## What I did not find (not stated)

- Per-step planned or measured minutes.
- A start time for each executor session. Report minutes are the conductor's own counts.
- Whether the report's "minutes" include idle waits on CI. desk-report.md 106-116 lists stops of 20 to 100 minutes inside a pass, so waits are in some figures.
- Whether TaskCompleted (lifecycle table, lines 17-66) fires per plan step. I did not read its section.

## For Geoff

- Does the cap count per step or per spec? Only per-pass numbers exist, so a per-step cap has no evidence.
- Should the cap count working minutes only, or the clock including waits for him and CI? On the clock, desk-check ran 1,118 to 1,362 minutes.
- Price new specs from step count (about 9 minutes each, 23% typical error), or from plan path times 0.5?
