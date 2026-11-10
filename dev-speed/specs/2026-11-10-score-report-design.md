# Pass score report

Initiative: dev-speed. First pass of the record's "First passes" list.

## Brief

A new command, `pass-report`, will show where pass time goes in every repo, and pass scores will gain one line a script can read.

The dev-speed initiative can't rank its next passes until something adds up the time. Today the score tables are free prose, about 130 of them across 13 repos, and nothing sums them.

### What changes

- You can run `pass-report` at any time. It prints one table per repo, with a row for each part of a pass's time: local gates, CI waits, reds, waiting on you, and planned against actual.
- The first report goes into the initiative record. Each later dev-speed pass cites the row it attacks.
- Every pass PR's score gains one hidden line holding its numbers. The table you read stays as it is.

### If you approve

1. A planning session writes the plan and hands it to the workstation conductor, because changing `pass-core` makes this a `runner` pass.
2. An executor builds the command, backfills the old scores, and runs the first report.
3. Its PR comes back to you in a packet with the report attached.

### Worth knowing

The report counts the time a PR waits on your decision, from when it is queued to when you decide. That wait is part of design-to-merged, and the record's baseline found PRs that sat for days. A row about your wait may read as pressure. The design keeps it because it's a real share of the time, and because a slow packet is often a hard-to-read packet, which a later pass can fix.

### Where the numbers come from

Most rows come from records machines already write, so the report doesn't depend on what a session chose to type.

| Row | Source |
|---|---|
| CI waits and reds | `gh run list` per repo, joined to its PR by branch. Failed runs add their failing job and step from `gh run view`. |
| Local gates and lock wait | `~/.local/state/cairn-run-gate/runs.jsonl`, 3,940 runs since 2026-10-13, joined by toplevel and branch. Worktree paths fold into their repo. |
| CI waits a session sat through | The same file's `ci` records, which `ci-green` writes. |
| Waiting on you | `~/.local/state/approval-queue/decisions.jsonl`. The packet id holds the queued time, and each line holds the decision time. |
| PR open to merge | `gh pr list`. |
| Planned against actual, fix rounds, attended events | The score line in the PR body, or the backfill file for older PRs. |

Records sit on each host. The report reads pavilion's files, plus any copy passed with `--records`, so a copy of the thinkpad's records can join it. The thinkpad gets the same command through stow and reports on the records it holds.

### The score line

`pass-core` "Score" gains one rule: below the table, the PR body carries an HTML comment `<!-- pass-score {...} -->` with `planPathMin`, `actualPathMin`, `fixRounds`, `reds`, `attended`, and `escapes`. GitHub hides the comment, so the brief reads the same. Only the numbers no machine records go in it.

The 130 older tables get a one-time backfill. A Haiku dispatch at low effort copies each table's figures into `dev-speed/research/score-backfill.json` and writes null where the prose gives no figure. A Sonnet read then checks ten rows against their PRs. The command never calls a model.

### Build

The command is one stdlib Python file, `bin/.local/bin/pass-report`, run as `python3 -I`, per the tool-language rule for a helper that parses data. Its tests run in `scripts/check.sh`. The output is Markdown on stdout, and `--since`, `--repo`, and `--records` narrow it. It caches `gh` reads under `~/.cache/pass-report` so a rerun takes seconds.

The report shows medians and the 90th percentile. A share of total time doesn't work, because the sources overlap: a gate can run while CI runs.

### Publication

The initiatives repo is public, and 10 of the 19 repos the report reads are private. The plan review found that the backfill's quoted notes would publish text from private PR bodies, which the design didn't weigh. Geoff rules on what the public repo may hold (plan, "Publication rule"). The recommendation is figures and failing step names for every repo, and no quoted prose from a private one.

Out of scope: sorting reds into those a local gate could have caught and those it couldn't. That sort needs each repo's fast-lane map. The report lists reds by failing step, which is enough to rank. Telling the two kinds apart is the job of the pass that attacks reds.

### Estimate

The estimate is 180 path minutes. Recent plans ran 3 to 8 times longer than the actual work: cairn-cms #210 planned 955 path minutes and took about 115, and workstation #215 planned 635 and took about 145. This figure is set from those actuals, so the stop at twice the estimate sits at 360. The report's planned-against-actual row will show whether the gap holds across repos.

### Standing answers

- The plan runs over 360 path minutes but stays under 540: go on and record it in `## Decisions`. Over 540: stop and write the cause in STATUS.
- A backfill table with no figure for a field: write null, and count the PR as unscored in that row.
- A repo with no runs or no PRs in the window gets a row that says none.
- `gh` rate limits: back off, and use the cache.
- A gate record whose toplevel maps to no repo, such as an eval fixture under `~/.cache`, is dropped from the report and counted in a footer line.

### Pre-flight

None foreseen. `gh` already reads every private repo, and the pass writes no settings, credentials, or new public surface. The edit to `pass-core` is a skill file, which earlier executors have edited in worktrees. The plan's `Permissions checked:` line confirms this. The conductor runs `stow -R bin` after the merge.

### Hosts

Pavilion gets the command and the first report. The thinkpad gets the command on its next pull and stow. It needs nothing else.

### Backlog sweep

The scoped sweep read `~/.dotfiles/BACKLOG.md` for gate, CI, score, and timing items.

- #10, per-leg timing in gate records: reword and keep. Its other half, `--records` printing epoch values, is already fixed (it printed `gate 155s` today). Tag it `#initiative:dev-speed`: per-leg timing is what the reds pass will need.
- #8, PR test CI for dotfiles: keep. It doesn't belong to this pass.
- #40, the gate from an isolated worktree: keep. No overlap.

## Approach considered

Parsing the prose tables with patterns at report time was set aside. The 130 samples use at least four layouts ("204 s (2 runs)", "about 6 minutes each", a paragraph with no table), so a parser would miss more than it read. A one-time model backfill plus a structured line from now on reads them once and keeps the command deterministic.
