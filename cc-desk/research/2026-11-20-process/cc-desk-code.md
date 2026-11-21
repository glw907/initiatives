# What cc-desk does today, and what the new process keeps

Read-only research. Repo: `/var/home/glw907/Projects/cc-desk` (call it CCD). Dated 2026-11-20.
Labels: "documented" (Anthropic docs describe it), "assembled" (documented pieces put together), "invented" (ours).
Where a gap exists the report says "not stated". Items I did not read are marked "not read".

## 0. Size of the Go

| Count | Lines | Source |
| --- | --- | --- |
| Non-test Go in `cmd`, `internal`, `systemd` | 11,654 | Matches `/var/home/glw907/Projects/cc-desk/docs/specs/2026-11-20-process-decisions.md` (the decisions doc). Without `systemd/units.go` (15 lines) my own count was 11,639. |
| Test Go, including e2e | 18,293 | my count |
| All Go | 29,947 | my count |

The page is TypeScript and Svelte, not Go: `web/` holds 23 test files of 2,414 lines (`web/tests/*`).

## 1. Every command, one line each

The root command adds these groups (`/var/home/glw907/Projects/cc-desk/cmd/cc-desk/root.go:109-136`).
With no arguments on a terminal, the root opens the desk (`root.go:113-117`).

| Command | What it does | Source |
| --- | --- | --- |
| `cc-desk` (no args) | Opens the "desk": an interactive session that reads Geoff's waiting questions. | `root.go:113-117`; `cmd/cc-desk/desk.go` |
| `check` | The timed job. Ten steps: read evidence, decide per session, carry out (launch, relaunch, merge, clean up, ask), write snapshot. | `cmd/cc-desk/check.go` (evidence at 181-228, pull-request read at 233-254) |
| `timer install` / `timer status` | Install and report the systemd check timer. Wraps `systemctl`. | `cmd/cc-desk/timer.go`; README lines 3-86 |
| `release` (`release done`, add, etc.) | Records a release: a conductor, rounds, passes. `release done` closes one. | `cmd/cc-desk/release.go`; README |
| `round` | Adds and changes rounds in a release. | `cmd/cc-desk/round.go` |
| `pass` (`pass ready --verdict --calls`) | Records a pass's pull request as ready, with the review verdict and calls and misses. | `cmd/cc-desk/pass.go`; README |
| `session` (`session end`) | Ends a session cc-desk launched (`claude stop`), so the next check counts a relaunch. | `cmd/cc-desk/session.go`; `docs/research/2026-11-20-kill-probe.md` |
| `snapshot` | Renders `snapshot.json` from the state folder. | `cmd/cc-desk/snapshot.go`; `internal/snapshot/` |
| `usage` | Reads weekly usage and caches it in `usage.json`. | `cmd/cc-desk/usage.go`; `internal/usage/usage.go` |
| `free` | Prints which passes are free to start. | `cmd/cc-desk/free.go`; `internal/state/rules.go:118-233` |
| `ruling` | Records Geoff's rulings in his words (`rulings.jsonl`, 21 lines). | `cmd/cc-desk/ruling.go` |
| `prompt` | Prints the launch prompt for a pass, conductor, or design writer. | `cmd/cc-desk/prompt.go`; `internal/launch/templates/pass.txt`, `conductor.txt` |
| `refusal hook` | The PermissionDenied hook. Records each refusal on the session's record. | `cmd/cc-desk/refusal.go:30-45` |
| `followup` | Files a follow-up from a session. | `cmd/cc-desk/followup.go` |
| `rules` | Prints the state rules (breaks, usage stop, limits). | `cmd/cc-desk/rules.go` |
| `question` | Writes a question for Geoff. | `cmd/cc-desk/question.go` |
| `brief` | Builds the desk's brief of what waits. Not read in detail. | `cmd/cc-desk/brief.go` |
| `report` (`report read`) | Records a round's report; `report read` marks it read. The page's one write. | `cmd/cc-desk/report.go`; `web/src/lib/server/command.ts` |
| Helper files, not root subcommands in the list above | `answer.go`, `kick.go`, `open.go` (desk open), `merge.go` (calls `gh pr merge --merge --match-head-commit`, three failures then asks), `carryout.go`, `launcher.go` | `cmd/cc-desk/merge.go:70-110`; others not read in detail |

Hidden flags: `--state-dir`, `--now`, `--usage-command`, `--systemctl-command`, `--claude-command` (`root.go:121-134`).
`main.go:160-168` unsets `ANTHROPIC_API_KEY` before starting `claude`.

## 2. Which jobs the new process still needs

The new process, from the decisions doc (`docs/specs/2026-11-20-process-decisions.md:52-64, 98-126`): a spec lists tasks, each task is a fresh `claude --bg` session under `/goal` in its own worktree and ends in a PR, a fresh reviewer checks it, a Bash script on a timer starts every free task, hooks record failures, a page only reads files, no session merges without Geoff.

| Job | Still needed? | Where it lives today |
| --- | --- | --- |
| Start each free task | Yes | `internal/launch/run.go:58-66`, `worktree.go:52`, `internal/state/rules.go:118-233` |
| Know which tasks are free | Yes | `internal/state/rules.go` (Breaks, Free, UsageStop, Limits) |
| Record a failed session | Yes | `internal/sessions/decide.go`, `refusal.go`, check decisions in `check.json` |
| Show the four groups | Yes (new view) | Today the page shows "Needs you now", "Ready now", "Scheduled", "Nothing waiting" (`internal/snapshot/snapshot.go`, `fillSession`) |
| Forecast of when the next thing needs Geoff | Yes, Geoff wants it kept | decisions doc line 47; `internal/snapshot/estimate.go`; `docs/specs/2026-11-17-cc-desk-design.md:150-181` |
| Weekly usage, stop new tasks at 85 percent | Yes | `internal/usage/usage.go`; today's stop is at 100 percent (`docs/STATUS.md:13`); 85 percent is only proposed (decisions doc 116-126; `docs/STATUS.md:55-57`) |
| Questions to Geoff, desk session, rulings, round reports, conductor | No. The new process has no waiting sessions (decisions doc 98-108). | `desk.go`, `question.go`, `answer.go`, `ruling.go`, `brief.go` |
| Merge from cc-desk, merge questions | No. "No session merges without Geoff." | `merge.go`, `carryout.go` |
| Idle and relaunch rules | Open. Today IdleLimit is 15 min, RelaunchLimit 2 (`internal/sessions/read.go`). Not stated whether the new process keeps them. | |

## 3. The smallest way to do each kept job

| Job | Fact source and command | Label | Bash under 150 lines? |
| --- | --- | --- | --- |
| Start a free task | `claude --bg --name N --model M --effort E --permission-mode auto --settings F "<prompt>"` in a worktree made by `git worktree add -b <branch> <dir> origin/<default>`. `/goal` runs inside `claude --bg` per the decisions doc probes (lines 52-64). Today wrapped in `systemd-run --user --scope -q` (`run.go:58-66`). | `claude --bg` and flags: documented. `/goal` in `--bg`: assembled (decisions doc calls it a probe, not read further). Wrapping in `systemd-run`: invented. | Yes. About 30 lines. |
| Branch from an unmerged task | `git worktree add -b task-b <dir> task-a-branch`. Today there is no such code: `worktree.go:52` always branches from `origin/<default>`. The release file has an `after` field per pass (shape captured from `releases/cc-desk.json`) but `after` waits for the merge, not for the branch. | Invented. Not stated in any doc. | Yes, a few lines, but the dependency data (which task builds on which) has no source. See section 8. |
| Which tasks are free | A task is free when its spec dependencies are done or have an open PR branch, no live session has its name, it has no PR open, and it is not held. Facts: `claude agents --json --all` (live sessions), `gh pr list --json number,state,headRefOid,mergedAt,mergeCommit,statusCheckRollup` (PRs), `git branch`. | `claude agents --json`: documented command, but the row shape is not in the docs (the code says Claude Code adds keys without notice; `internal/sessions/list.go`). `gh pr list`: documented. The free rule: assembled from `rules.go:118-233`. | Yes, if the spec holds tasks in one parseable file (for example one task per line). `jq` does the JSON. About 40 lines. |
| Record a failed session | A `PermissionDenied` hook and a `Stop` or failure hook append one JSON line to a file. Today `refusal hook` reads stdin (`session_id`, `tool_name`, `tool_input`, `reason`) and writes the record (`refusal.go:52-100`). A script can `jq` the same stdin and append to a JSONL file. | Hooks: documented. The `refusal` fields: read from the code, not stated in a doc I read. | Yes. About 15 lines for the hook; the launcher reads the file. |
| Detect a session that died or stalled | `claude agents --json --all` rows (`status`, `state`: `working`, `blocked`, etc., see `spikes/1-wake/out/list.json`); `claude logs <id>`; `claude stop <id>`. The labels "lost connection", "sign-in", "usage limit" rest on an undocumented `~/.claude/jobs` state file and screen text (`docs/research/2026-11-17-prove-findings.md`, proofs 1 and 6). | The commands: documented. The state file and screen text: undocumented. | Yes for working/idle/gone. The three failure labels: not without reading undocumented text. |
| Show the four groups | Derived from task, PR, review, and session facts: "Ready to merge" (PR open, CI green, review clean), "Read before merging" (PR open, review has findings or calls), "Couldn't finish" (session ended without a PR, or failure record), "Held for you" (spec says hold, or a refusal waits). Sources: `gh pr list`, the failure JSONL, the review result. | Invented. No doc defines these groups; the decisions doc proposes them (lines 116-126). | The script writes one file (JSON) per group. About 60 lines. |
| Forecast | Today: sum of planned minutes of unfinished predecessors times pace. Pace is actual over planned for the last 10 finished passes, "rough" under 3 (`internal/snapshot/estimate.go`; design doc 150-181). Stored in `forecasts.jsonl` (97 lines; shape `{format,made,time}`). A script needs planned minutes per task (from the spec) and finish times (PR `createdAt` or `mergedAt` from `gh`, session `startedAt` from `claude agents`). | Invented. The decisions doc line 47 says "Claude Code produces it", but I found no Claude Code feature that produces it. Not stated which. | Yes, about 40 lines, once planned minutes sit in the spec. |
| Weekly usage and the 85 percent stop | `claude -p "/usage" --model haiku --output-format json`, then a regex. See section 5. | Assembled. The command is documented; the wording is not. | Yes. About 20 lines. |

Total for a launcher plus facts plus groups plus forecast plus usage: roughly 150 lines if written tight. It is tight to hold in one file. Two files (launcher, status writer) fit more safely. This is my estimate, not measured.

## 4. What the page reads and what serves it

What it reads today:
- `web/src/lib/server/state.ts` reads only `snapshot.json` and `snapshot-error.json` from the state folder. `snapshot.json` is 41 KB.
- `snapshot.json` is built by the Go `internal/snapshot` package from the state files. So the page depends on Go output. A file-only server must either read the raw files or have the Bash script write a page-shaped file.
- `web/src/lib/server/design.ts` renders a round's design document from the release's checkout. Not needed in the new process (no rounds).
- `web/src/routes/api/state/+server.ts` returns the state JSON.
- `web/src/hooks.server.ts` returns 405 for writes except `/reports/rep-NNNN?/read`, which calls `cc-desk report read` (`web/src/lib/server/command.ts`). The new page "only reads files", so this write goes.
- I did not read the page's polling interval or its Svelte views in detail.

What serves it:
- SvelteKit 3.3.1, Svelte 5.57.3, adapter-node, daisyui, survey v1.7.0, Playwright 1.65.1 for tests (`web/package.json`). Build is `vite build`.
- Runs as `~/.config/systemd/user/cc-desk-page.service`: node on `~/.local/share/cc-desk/page`, bound to 127.0.0.1:7908, hardened, with `ReadWritePaths` for the state dir (`web/systemd/cc-desk-page.service`).
- Installed by `web/scripts/install-page.sh`.
- Tests: 23 files, 2,414 lines under `web/tests/`. The gate runs gofmt, vet, test, vale, skills, page (`scripts/gate.sh`, `.github/workflows/gate.yml`).

What a file-only server needs:
- A static file server on 127.0.0.1 over one folder that holds the four-group data and a small HTML page. No Node build is strictly needed. Candidates are `python3 -m http.server --bind 127.0.0.1 --directory <dir>` (stdlib, documented in Python docs) run by a systemd user unit, or the existing node service. Which one Geoff prefers is a taste call.
- Read-only means no `ReadWritePaths`, `ProtectSystem=strict`, and no POST route.
- The page needs to re-read the file on an interval. The existing page's polling is not read.
- The user's rule: house tools use Survey for UI (`survey` skill). Not checked whether the new page must.

## 5. How weekly usage is read today

Code: `/var/home/glw907/Projects/cc-desk/internal/usage/usage.go`.
- `Read` runs `claude -p "/usage" --model haiku --output-format json` with a 60 s timeout, stdin the null device (lines 65-83).
- `Parse` takes the JSON `result` text and matches the regex on line 34: `Current week \(all models\): (\d+)% used · resets (.+)`. The percent and the reset text come from the first match.
- It caches to `usage.json` (shape `{format,percent,reset_text,read_at}`). `MaxAge` is 5 minutes. `Cached` reads the file; `Take` reads fresh or falls back to the cache.
- The run takes no model turn: `num_turns` 0, cost 0, `local_command: usage` (`docs/research/2026-11-17-prove-findings.md`, proof 7, about lines 299-318).
- Today the stop is at 100 percent (`docs/STATUS.md:13`), via `UsageStop` in `internal/state/rules.go`.

Could a script read it the same way? Yes:
```
claude -p "/usage" --model haiku --output-format json | jq -r .result | grep -oP 'Current week \(all models\): \K[0-9]+'
```
Caveat: the wording "Current week (all models)" is not documented. If Anthropic changes it, the match fails. The Go code treats a parse failure as an error (not read in detail what the caller does). The script must decide: on failure, stop new tasks or carry on. Not stated in the decisions doc.

## 6. Systemd units

| Unit | Today | Source |
| --- | --- | --- |
| `cc-desk-check.service` | oneshot, `ExecStart=... cc-desk --state-dir %h/.local/state/cc-desk check` | `systemd/cc-desk-check.service` |
| `cc-desk-check.timer` | `OnStartupSec=1min`, `OnUnitActiveSec=5min`, `AccuracySec=1s` | `systemd/cc-desk-check.timer` |
| `cc-desk-page.service` | node on `~/.local/share/cc-desk/page`, hardened | `web/systemd/cc-desk-page.service` |

All three are installed in `~/.config/systemd/user/`; the timer and the page service are active. `systemd/units.go` (15 lines of Go) embeds the check units for `timer install`.

What changes:
- The check service's `ExecStart` points at the new Bash script instead of the Go binary. Timer values can stay (5 minutes). The new process says "a timer starts every free task"; the interval is not stated.
- The page service either keeps node (if the page is kept) or becomes a static server. Drop `ReadWritePaths` if it only reads.
- The timer must not overlap itself. Today the Go takes a lock (`check.lock`, `lock` in the state folder). A script needs `flock` or the oneshot service's own single-instance behavior. systemd does not start a oneshot service that is already activating, so overlap is already prevented by the unit. I did not verify this against the systemd docs.
- Launches go through `systemd-run --user --scope -q`. The reason is not stated in the code I read. Keep or drop is a call.

## 7. Cleanup when the Go goes

| Item | Where | Note |
| --- | --- | --- |
| Binary | `~/.local/share/cc-desk/bin/cc-desk` (15 MB), symlink `~/.local/bin/cc-desk` | |
| Check units | `~/.config/systemd/user/cc-desk-check.service`, `.timer` | Stop and disable the timer first (`systemctl --user disable --now`). |
| Page service and files | `~/.config/systemd/user/cc-desk-page.service`, `~/.local/share/cc-desk/page/` | Only if the page is replaced. |
| URL handler | `~/.local/share/applications/cc-desk.desktop`, `~/.local/share/cc-desk/link/cc-desk-open`. It runs `ptyxis` for `cc-desk://`. No cc-desk entry in `mimeapps.list`. | Sources `web/desktop/cc-desk.desktop`, `web/scripts/install-link.sh`, `check-link.sh`. Run `update-desktop-database` after. |
| State folder | `~/.local/state/cc-desk/`: `check.json`, `check.lock`, `lock`, `check-log.jsonl` (179 lines), `desks.json`, `desk/words/*.txt`, `forecasts.jsonl` (97), `hook-unmatched/`, `launch/` (about 50 settings files), `releases/cc-desk.json`, `releases/done/` (8), `reports.json`, `rulings.jsonl` (21), `snapshot.json`, `usage.json` | `forecasts.jsonl` and `rulings.jsonl` hold history. Whether to keep them is a call. The new forecast could seed from `forecasts.jsonl`. |
| Skills | Sources: `/var/home/glw907/Projects/cc-desk/skills/cc-desk` (159 lines) and `skills/cc-desk-work` (127 lines). Installed copies in the dotfiles at `claude/.claude/skills/{cc-desk,cc-desk-work}`, linked from `~/.claude/skills/`. Manifest entries in `claude/.claude/tooling/vendored-skills.json:109-125` (vendored from `glw907/cc-desk`). | Remove with `claude-tooling-sync`, which I may not run. |
| Settings entries | `claude/.claude/settings.json:417` and `428-431` hold the cc-desk auto-mode grants (prove-owned, sessions-page, desk-round, core-spec). The core design says each grant names a step of Geoff's that removes it (`docs/specs/2026-11-20-core-design.md:495-531`). | |
| Global file and skill text | `claude/.claude/CLAUDE.md:12` ("Until cc-desk runs"); `claude/.claude/skills/pass-core/SKILL.md:18-36` ("Until cc-desk runs") | The core design leaves these to the process spec (core design 495-531). |
| Release records | `~/Projects/initiatives/cc-desk/` (`initiative.yaml`, `README.md`, `reports/` with five reports) and `releases/done/` | Whether to archive or delete is a call. The `retire-project` skill is the house practice for a project, but I did not read it as instructions. |
| Repo | `/var/home/glw907/Projects/cc-desk`, with CCD's own worktrees under `.claude/worktrees/`. Also `/var/home/glw907/Projects/cc-desk-scratch`. | The GitHub repos `glw907/cc-desk` and `glw907/cc-desk-scratch` were made public on 2026-11-20 (`docs/follow-ups/desk-round-lessons.md`). |
| Other repos | A `git grep` of cc-desk hits only the dotfiles repo (`workstation`) among the repos I checked. `household-it` has none; `cairn-cms` hits only a dictionary file. | |

## 8. Things the new process needs that have no documented source of truth

1. **Task dependencies.** "A task that builds on an unmerged task branches from that task's branch." No code does this today (`internal/launch/worktree.go:52`). The spec format that carries "builds on" is not stated.
2. **Claude Code agent row shape.** `claude agents --json --all` has no documented schema. The code treats added keys as possible without notice (`internal/sessions/list.go`). Fields seen: `pid, id, cwd, kind, startedAt, sessionId, name, status, state` (`spikes/1-wake/out/list.json`).
3. **Failure labels** (lost connection, sign-in, usage limit) rest on an undocumented `~/.claude/jobs` state file and screen text (`docs/research/2026-11-17-prove-findings.md`, proofs 1 and 6).
4. **Usage wording.** The `/usage` text wording is undocumented (`internal/usage/usage.go:34`).
5. **A session killed alone comes back.** Claude Code's supervisor revives a lone `kill` within 11 seconds. Only `claude stop` (in `session end`) ends it. The new script must use `claude stop` (`docs/research/2026-11-20-kill-probe.md`).
6. **Wake and resume do not work** (prove findings, proofs 1 and 6). A stopped or dead session cannot be resumed. The check restarts it from files. The new process needs a rule for a task that dies mid-way. Not stated in the decisions doc.
7. **Planned minutes and the 2x cap.** The proposed cap of twice the planned minutes (decisions doc 116-126) needs planned minutes per task and a start time. The spec's field for planned minutes is not stated.
8. **Forecast meaning once no session asks Geoff questions.** Today `fillSession` has states needs_you_now, ready_now, scheduled, nothing_waiting (`internal/snapshot/snapshot.go`). With no questions, "the next thing that needs Geoff" is the next PR or the next held task. Not stated.
9. **`/goal` under `claude --bg`.** The decisions doc (lines 52-64) lists it as probed; I did not find a documented statement that a `dontAsk` session carries on past a refusal beyond that probe. Core design line 545 on lists "Calls Claude made"; not read in full.
10. **PR-ready check.** "Ready to merge" needs a rule for CI green and a clean review. Today it comes from `pass ready --verdict --calls` written by the session. A fresh reviewer's verdict must land in a file. Where is not stated.
11. **523 commands containing `gh pr merge`** appear in session records although a hook refuses it (`docs/specs/2026-11-20-core-design.md`, near line 520). Nobody has checked why. Relevant, since "no session merges without Geoff" depends on that hook.

## 9. Mechanism labels

| Mechanism | Label |
| --- | --- |
| `claude --bg`, `--name`, `--model`, `--effort`, `--permission-mode`, `--settings` | Documented |
| `claude agents --json --all`, `claude logs`, `claude stop` | Documented commands, undocumented row shape |
| `claude auth status --json` | Documented. Used for the sign-in check; not read in detail. |
| `claude -p "/usage" --output-format json` and the regex | Assembled |
| PermissionRequest and PermissionDenied hooks recording to a file | Documented hook, assembled recording |
| `/goal` in `claude --bg` | Assembled (probed) |
| Fresh subagent or second session as reviewer | Documented (core design table: best-practices and `/goal` pages) |
| Branch from an unmerged task branch | Invented |
| Four groups | Invented |
| 85 percent stop | Invented |
| Forecast from planned minutes times pace | Invented |
| `systemd-run --user --scope` around launches | Invented |
| Systemd user timer running a Bash script | Documented |
| Static file page over files | Assembled |

## 10. Files I did not read in detail

`cmd/cc-desk/brief.go`, `answer.go`, `kick.go`, `carryout.go`, `launcher.go` bodies; `systemd/units.go`; the page's Svelte views and polling; `scripts/live/*.sh` purpose; `internal/sessions/decide.go` rules beyond the constants. All are for jobs the new process drops, except `decide.go`, which holds the relaunch and idle rules that may matter to the script.
