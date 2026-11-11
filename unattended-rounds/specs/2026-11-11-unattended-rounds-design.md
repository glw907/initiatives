# Unattended rounds

Initiative: unattended-rounds

## Brief

Approving this lets one design cover several passes that run back to back while you are away, and you return to a report and at most a few questions.

Today a session with nothing approved to start next sits idle, and one stop holds everything queued behind it. Sessions sat idle after a reply for 1,087 hours and waited on an approval for 232. Planning misses cause many of the stops, so this also tightens what a round's planner must show before anything launches.

### What changes

- A design can cover a round: three to six passes in one repo, about 600 planned minutes on the longest chain. You approve it once, at one sitting.
- A conductor launches each pass when the one before it reaches a finished PR. A pass with nothing for you to decide merges itself, as it does today.
- A pass that hits a stop is parked. Its question reaches you in the queue, and the next pass that doesn't depend on it starts.
- Before each launch the conductor reads the weekly usage. At 85 percent or more it starts nothing new.
- A round's planner shows a probe or a quoted source for each mechanism, a recorded search behind each file list, and a read of the last 30 days of auto-mode refusals.
- When you return, STATUS opens with a round report: each pass's state, planned against actual minutes, the usage spent, and every stop and planning miss by class.
- No skill, hook, permission rule, or setting changes before 2026-12-11. The round rules live in one kit file, which a designing session reads when you name it.

### If you approve

1. The session writes the round kit and checks it with a reader that has seen nothing else.
2. The session files two backlog items for the false hits found in the worktree busy check.
3. Nothing launches. A round starts when you ask a session to design one and name the kit.
4. That round's design comes to you as its own packet, with its pre-flight steps.
5. After the freeze, a session sends you the standing change as a second design, with the pilot results.

### Decide: When the round rules arrive

The freeze you set on 2026-11-10 allows removals only until 2026-12-11. The pilot edits no standing file, but it does add rules: each round's design carries them, and you approve each design. That follows the freeze's wording and works against its purpose, a clean measure on 2026-12-11. Pilot PRs carry a `Round:` line so that read can count them apart.

Source: `workstation-refinement/README.md:167` on the local `workstation-refinement` branch

- Pilot rounds now, the standing change after 2026-12-11 (recommended)
- Nothing until the freeze ends on 2026-12-11
- Build the standing change now, as a freeze exception

### Decide: What a round does when the weekly allowance runs low

The week stood at 80 percent used on 2026-11-11, and three sessions waited about 64 hours each on the limit the week before. A round can wait for the reset or keep going on usage credits. Credits are a budget call, and how a credit cap is set was not checked.

Source: `unattended-rounds/research/2026-11-11-evidence.md:23`

- Finish the pass in flight, start nothing new, and wait for the reset (recommended)
- Keep going on usage credits up to a dollar ceiling you name

### Decide: Which trials the pilot runs ahead of the December model review

Two changes would help a round and both belong to the monthly model review. One is Fable 5.2 at `high` designing and planning a round, where `pass-core` sets Opus. The other is `/goal` at the head of each executor and conductor prompt, which the guards doc holds back until that review. The pilot can run both as trials and report them to the review.

Source: `claude/.claude/docs/unattended-work-guards.md:133` and `claude/.claude/skills/pass-core/SKILL.md:23` in the workstation repo

- Run both trials in pilot rounds and report them to the December review (recommended)
- Run the `/goal` trial only, with Opus planning
- Run neither: Opus plans, and sessions keep the `/loop` wake-up alone

### Worth knowing

The weekly allowance resets on 2026-11-13 at 11pm Anchorage time, so the first round should start after that. `/usage` also suggests giving general-purpose subagents a cheaper model, which it ties to 87 percent of the last day's requests. That suggestion goes to the model review as evidence.

### How a round runs

A round is one design, one conductor, and passes that run one at a time in one repo. The design lists each pass with its outcome, files, class, estimate, what it depends on, and which other passes share a file with it. Your approval of the design also approves unattended planning for every pass in it, which `pass-core` already allows. The planner writes each plan under the repo's `docs/plans/`, where the launch guard reads it, and commits a conductor prompt that holds the order table. The conductor decides nothing: it follows the table.

A pass ends in one of three states. It merges itself when it holds no call for you, touches no `auth-data` path, and has no `## Before merge` step. It waits in the round's one close packet when it holds a call. It parks when it stops. A pass that depends on an unmerged pass starts from that pass's branch, and the two merge in the recorded order.

### Standing answers

Each stop a round can foresee has an answer, so the conductor never waits on you to keep going.

1. A pass stops on a question only you can answer. The executor commits, pushes, opens its draft PR if none exists, and writes the stop to STATUS. The conductor sends one `stop` packet, ends that session with `claude stop`, and launches the next pass that neither depends on the parked one nor shares a file with it.
2. Auto mode refuses a command. The executor uses the alternative its plan names, once. A second refusal is a stop under answer 1. No session edits a setting to get past a refusal.
3. A task needs a setting, hook, auto-mode entry, or permission rule changed. That is never an executor task. The planner writes it as a command for you in the close packet, and a pass that can't finish without it parks.
4. The weekly usage reads 85 percent or more before a launch. The conductor follows your answer to the second decision.
5. A pass's parent is parked. The pass parks too and never launches.
6. The busy check exits 1. If its line names the `claude daemon run` process or the Approval Queue server, the conductor checks the session rows and recent uncommitted edits by hand, and launches when both are clean. Any other hit ends launches in that repo, and the report says so.
7. The round passes twice its planned minutes. The pass in flight finishes, nothing new starts, and the conductor writes the report.
8. The conductor's session dies or the machine restarts. Nothing recovers on its own. STATUS names the conductor prompt, and you or any session can relaunch it.

### Pre-flight

Nothing is yours before this design's work starts.

Each round's design carries its own `[you: ...]` steps, and the session checks the sign-in before a launch: `claude -p "say ok" --model haiku` printed no sign-in warning on 2026-11-11.

Permissions checked: the work this design approves writes two files, the kit in this local record and a symlink at `~/.local/state/unattended-rounds/kit.md`, plus two backlog items in the workstation repo. It edits no skill, hook, setting, permission rule, or guard script. The denial log held 57 rows from 2026-11-01 to 2026-11-11. The round rules route around its three largest classes: settings edits are never an executor task (10 rows), a session stops its own background command with `TaskStop` in place of `pkill` (9 rows), and a merge goes only through `approval-queue land` or an approved packet (3 rows).

### Estimate

The kit and its check come to 30 path minutes, which is this session's guess with no scored pass behind it.

A round of 600 planned path minutes should take about 220 to 240 actual minutes at the median ratio of 0.36 to 0.40, and about 500 to 510 at the ninth decile of 0.83 to 0.85. CI, reviews, and waits come on top. How much of the weekly allowance one pass spends was not measured. The first pilot round measures it, and that figure sets the size of later rounds.

### Models

Conductors and executors stay on Sonnet at `medium`, as the conductor and planner references set. Design and planning follow your answer to the third decision. Each plan gets one `standards:plan-reviewer` read. Anthropic's Fable 5.2 prompting page says "Early testers had good results with Claude Fable 5.2 as the planner and orchestrator for other models." The Fable allowance has its own weekly meter, which read 41 percent against 80 for all models.

### What the planner must show

Four rules aim at the largest planning-miss classes, and each one leaves something a reviewer can check. The counts come from about 220 misses in 89 of the 668 PRs merged since 2026-10-10.

| Miss class | Misses | Rule | What the plan reviewer checks |
| --- | --- | --- | --- |
| A mechanism assumed and never probed | 55 | The plan carries a mechanism table. Each row names a probe run and its output, or a quoted source with its line or URL. | No row says "expected" or cites nothing. |
| An incomplete file or consumer list | 40 | The file list is built from searches. The plan records each search and its hit count. | Each listed file traces to a search, and each hit is listed or dismissed with a reason. |
| A permission, auto-mode, or isolation block | 40 | `Permissions checked:` cites a read of the last 30 days of the denial log against each task's commands. | The line names the log's date range and each class it found. |
| A stop with no standing answer | 8 | Every stop the plan writes has a standing answer or parks the pass. | No stop says "ask Geoff". |

Each planning miss in a pilot PR also carries one class from the ten in the evidence file, so the next count needs no sorting.

### Backlog sweep

No open workstation item folds into the pilot, and one folds into the standing change. The sweep read 37 open items at commit `7a62abe`.

| Item | Verdict | What the pass does |
| --- | --- | --- |
| #72 Launch guard finds plans only under `docs/plans/` | keep | Nothing now. Pilot plans go under `docs/plans/`. The fix joins the standing change. |
| #50 An Approval Queue decision reaching the auto-mode classifier | keep | Nothing. It waits on the first merge after the queue cutover. |
| #63 A no-argument `gate.sh` wrapper for two adapters | keep | Nothing. |
| #73, #71, #70, #69, #68, #10, #14 | keep | Nothing. None names a file the pilot writes. |
| New: the busy check reads the daemon and the queue server as a running pass | file | Filed on approval, with the three probe results. |
| New: the busy check counts a finished session's row | file | Filed on approval. Until it is fixed, the conductor ends each finished executor with `claude stop`. |

### The end-to-end check

A reader that has seen only the kit must produce a complete round outline. A fresh Sonnet subagent gets the kit's path and three sample backlog items, and writes a round design outline. The check fails if the outline lacks the order table, a mechanism table, recorded searches, the denial-log read, a standing answer for each stop, or the merge order.

The first pilot round is the larger check. It passes when every pass is merged, waiting in the close packet, or parked with a stop packet, the report leads STATUS, and the report shows a usage reading before each launch.

### Out of scope

The pilot leaves every guard, review, and approval where it is. It also leaves out:

- Two passes running at once in one repo, and a round that spans repos.
- Any change to who approves a design, an `auth-data` change, or a `## Before merge` step.
- Faster gates and CI, which belong to `dev-speed`.
- A standing model or effort change, which belongs to `monthly-model-review`.
- Running rounds on Orpheus or in the cloud.
- A fix to `claude-worktree-busy` or `claude-launch-guard` before the freeze ends.

## Technical notes

### Passes and order

1. The kit. One small change in this record: `unattended-rounds/kit/round-kit.md`, the symlink at `~/.local/state/unattended-rounds/kit.md`, the two backlog items, and the README record line. It runs in the approving session.
2. Pilot rounds. Each is its own design packet from a session Geoff asks. At least two run before the standing change is designed.
3. The standing change. A second design after 2026-12-11, carrying the pilot's reports. Candidate homes, none approved here: round wording in the conductor and planner references or a new `references/round.md`, a required evidence line and the #72 fix in `claude-launch-guard`, the `/goal` and usage sections of the guards doc, and the miss class tag in `pass-core`. `pass-core` holds 1,496 of its 1,500 words and `CLAUDE.md` 120 of its 120 lines, so each addition there is paired with a removal.

### Files

| File | Change |
| --- | --- |
| `unattended-rounds/kit/round-kit.md` (this record, local branch) | New. The round rules for a designing session, a planner, and a conductor. |
| `~/.local/state/unattended-rounds/kit.md` | New symlink to the kit. |
| `~/.dotfiles/BACKLOG.md` | Two new items, committed to main. |
| `unattended-rounds/README.md` | Record lines. |

### What the kit holds

The kit is agent-facing and follows `~/.claude/docs/voice/agent-facing.md`. It holds, in this order:

1. What a round design adds to a pass design: the pass table (outcome, files, class, path minutes, depends on, shares files with), the merge order, the usage ceiling, and the standing answers above.
2. The four planner rules and the class list.
3. The conductor prompt's additions: the order table; a usage read before each launch with `claude -p "/usage" --model haiku < /dev/null`; `claude stop <id>` on each finished or parked executor before the next busy check; a dependent pass's worktree cut with `git -C <repo> worktree add .claude/worktrees/<pass> -b <branch> origin/<parent branch>` and entered by the executor with `EnterWorktree` `path`; each `approval-queue packet` run as a background command; long commands under `timeout`.
4. The executor prompt's additions: the `Round: <id>` line in the PR body, the stop procedure of standing answer 1, and `TaskStop` for a background command it started.
5. The round report's fields: for each pass its state, PR, planned and actual path minutes, and usage before and after; then stops, refusals, and planning misses by class. The conductor writes the report before any long wait and again at the end, and puts its path on the first line of the repo's STATUS.
6. If the third decision allows it, the `/goal` line for each prompt. Its condition names every legitimate end: PR ready, parked with a stop in STATUS, or usage at the ceiling.

### How each mechanism fails

| Mechanism | Evidence | How it fails | What happens |
| --- | --- | --- | --- |
| The conductor wakes when an executor goes idle | `conductor.md:31-33`, `SendMessage` `notify_when_idle` | The notice is one-shot and missed | The conductor re-subscribes after each notice, as today. A missed notice leaves the round idle, and the report's last write shows where. |
| A background command's exit wakes an idle session | Probe `d5f550b7`, 25 seconds | Unproven past 25 seconds | A packet answer that doesn't wake the conductor is recovered with `approval-queue collect <id>`. |
| A session stops a `--bg` session it launched | Four stops by this session, no refusal. Denial row 50 is a refusal of the same command | Auto mode refuses the stop | The repo stays busy, standing answer 6 ends launches there, and the report records the refusal. |
| A stopped session's row leaves `claude agents --json` | The four probe jobs, 2026-11-11 | The row stays | Same as the row above. |
| A dependent pass starts from an unmerged branch | Probe `d8fcc6bf`: `EnterWorktree` `path` under `claude --bg` | The parent changes after the dependent starts | The dependent merges the parent's branch before its close. A conflict parks it. |
| A stop packet names the parked pass | The queue refuses a stop packet with no PR (`workstation-refinement/README.md:151`) | The pass stopped before its first push | Standing answer 1 has the executor push and open the draft PR first. |
| The usage read | `claude -p "/usage" --model haiku < /dev/null` printed the weekly line, 2026-11-11 | The output changes shape or prints no weekly line | An unreadable figure counts as over the ceiling. |
| Waiting for the reset | Not probed. The `/goal` page says a goal pauses on a usage limit and resumes at the reset | The session never resumes | The report is written before the wait. STATUS names the conductor prompt for a relaunch. |
| `/goal` holds a `--bg` session to its condition | Probe `94a50d24`: "Goal achieved" after three held turns | The condition names no end the session can reach | The condition lists every end. A cleared goal doesn't show in `state.json`, so the conductor reads STATUS. |
| The machine stays up | `uupd` stages updates without applying them, and `sleep-inactive-ac-type` is `nothing` on pavilion | A power loss or a manual restart | Standing answer 8. |

### Measures

The baseline per 100 merged PRs is 33 misses in all, 8.2 for an unprobed mechanism, 6.0 for a file list, and 6.0 for a permission block. The goal of half is counted over the first 100 PRs merged after the standing change lands. Pilot rounds report the same four figures for their own PRs, which will be too few to conclude from.

### Claude's calls

- A round is three to six passes and about 600 planned path minutes. The pilot's usage figure may change both.
- The usage ceiling is 85 percent of the weekly allowance.
- Passes run one at a time, in one repo.
- The kit lives in this record with a symlink under `~/.local/state`, since the record is unpushed and a session can't find it otherwise.
- The conductor ends a parked executor's session. A parked pass resumes in a fresh session from STATUS.
- An unreadable usage figure counts as over the ceiling.

### Left to the builder

The kit's wording, the sample backlog items for its check, and the report's layout. The first round's repo and passes are Geoff's to pick when he asks for one.

### Sources

- `unattended-rounds/research/2026-11-11-evidence.md`: the timeline figures, the denial log, the miss counts, the probes, and the Anthropic pages.
- `claude/.claude/skills/pass-core/SKILL.md` and its `references/` in the workstation repo, read at `main` on 2026-11-11.
- The `workstation-refinement` record on its local branch, for the freeze and its measure read.
