# Unattended rounds

Initiative: unattended-rounds

## Brief

Approving this makes the round the unit you approve on every repo: one design covering one to six passes that run back to back while you are away. You return to a report and at most a few questions.

Today a session with nothing approved to start next sits idle, and one stop holds everything queued behind it. Sessions sat idle after a reply for 1,087 hours and waited on an approval for 232. Planning misses cause many of the stops, so this also tightens what a round's planner must show before anything launches.

### What changes

- A design covers a round: one to six passes in one repo, up to about 600 planned minutes on the longest chain. You approve it once, at one sitting.
- A round of one pass is today's pass. It has no conductor and runs as it does now.
- In a larger round, a conductor launches each pass when the one before it reaches a finished PR. A pass with nothing for you to decide merges itself, as it does today.
- A pass that hits a stop is parked. Its question reaches you in the queue, and the next pass that doesn't depend on it starts.
- Before each launch the conductor reads the weekly usage. At 85 percent or more it starts nothing new.
- A round's planner shows a probe or a quoted source for each mechanism, a recorded search behind each file list, and a read of the last 30 days of auto-mode refusals.
- When you return, STATUS opens with a round report: each pass's state, planned against actual minutes, the usage spent, and every stop and planning miss by class.
- The Approval Queue has no notion of a round today. Until it does, every packet title and digest line opens with the round's id, and the kit holds a rule for each place the queue's commands fit a round badly.
- No skill, hook, permission rule, setting, or queue code changes before 2026-12-11, unless your first answer below says otherwise. Until then the round rules live in one kit file, which a designing session reads when you name it.

### The round as the basic unit

You ruled on 2026-11-11 that the round becomes the basic unit on the whole workstation, unless Anthropic's guidance says that is a bad idea. It doesn't say that. A reader fetched 14 Anthropic pages and quoted them for and against. They support one piece of work per fresh session, state kept in files, a plan held outside the model, and a person approving the result at the end. No built-in Claude Code feature does what a round does: the agent view parks a session that needs you and orders nothing, a workflow script takes no approval mid-run, and the agent teams page advises against teams for sequential work.

The pages carry four cautions, and the round answers each.

| Anthropic's caution | What a round does |
| --- | --- |
| "we recommend finding the simplest solution possible, and only increasing complexity when needed" | A one-pass round has no conductor and no order table. |
| "you find out the next morning that it spent the whole night building on the wrong assumption" | A pass builds on another pass only after that pass's whole-branch review is accepted. A pass with an open finding parks, and so does every pass that depends on it. |
| "Claude declares victory on the entire project too early" | The conductor marks a pass finished from its PR, its checks, and its review verdict, never from the executor's last message. |
| "Running several sessions or subagents at once multiplies token usage" | Passes run one at a time, and the first pilot round measures what a pass costs. |

The ruling makes the standing change larger than the version of this design you saw first. It rewrites `pass-core` so that every design is a round design. It also changes the `approval-packet` skill, the three repo adapters, the pass section of `CLAUDE.md`, and the Approval Queue. A pass stays what `standards:running-passes` defines: one plan, one executor, one worktree, and one PR.

Source: `unattended-rounds/research/2026-11-11-evidence.md:110`

### The Approval Queue in a round

The queue works a pass at a time, and reading its code against a round found five gaps. The pilot covers each with a kit rule. The standing change closes each in the queue.

| The queue today | Pilot rule in the kit | Standing change |
| --- | --- | --- |
| Nothing groups one round's packets or digest lines. | Each packet title and each `land` claim opens with the round id. | A `round` field on packets and digest lines, and pages grouped by round. |
| Nothing reports a round as a whole. | The report leads STATUS, and the round's last packet names its path. | The round report as an item on the queue's pages. |
| Approve on a stop packet reads as "merge what was read", and `merge <id>` accepts a stop packet. | The conductor runs the stop packet's listed steps and never runs `merge` on it. | `merge` refuses a stop packet, the page says Approve resumes the pass, and the skill gains a stop case. |
| `merge` and `land` never read a PR's base branch. A PR based on its parent's branch would merge into that branch and never reach main. | A dependent pass's PR opens against the default branch. Its diff repeats the parent's lines until the parent merges. | `merge` and `land` refuse a PR whose base isn't the default branch. |
| A close packet takes at most three unforced calls. | A round with more sends two or more close packets, split by dependency chain. | The second design settles whether the cap counts per packet or per round, from the pilot's call counts. |

Close packets go out when the round's last pass ends, since a packet's PR list is fixed once it is sent. Stop packets go out as each pass parks.

Source: `unattended-rounds/research/2026-11-11-evidence.md:93`

### If you approve

1. The session writes the round kit and checks it with a reader that has seen nothing else.
2. The session files four backlog items: two in the workstation repo for the false hits in the worktree busy check, and two in the approval-queue repo for the stop-packet merge and the base-branch check.
3. Nothing launches. A round starts when you ask a session to design one and name the kit.
4. That round's design comes to you as its own packet, with its pre-flight steps.
5. The standing change comes to you as a second design, at the time your first answer sets. It is itself a round: the queue's passes first, then `pass-core` and the skills.

### Decide: When the standing change is built

The freeze you set on 2026-11-10 allows removals only until 2026-12-11. The refinement it protects changed the queue's code too, so this design treats the queue as frozen with the skills. The pilot edits no standing file, but it does add rules: each round's design carries them, and you approve each design. That follows the freeze's wording and works against its purpose, a clean measure on 2026-12-11. Pilot PRs carry a `Round:` line so that read can count them apart.

The recommendation is to pilot first. The second design needs three figures only a real round gives: what a pass costs of the weekly allowance, how many calls a round sends you, and which kit rule for the queue chafes.

Source: `workstation-refinement/README.md:167` on the local `workstation-refinement` branch

- Pilot rounds now on today's queue, the whole standing change after 2026-12-11 (recommended)
- Pilot rounds now, and the queue's round support now as a freeze exception
- The whole standing change now, as a freeze exception
- Nothing until the freeze ends on 2026-12-11

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

A round of two or more passes is one design, one conductor, and passes that run one at a time in one repo. The design names a round id, which every PR body, packet title, and `land` claim carries. The design lists each pass with its outcome, files, class, estimate, what it depends on, and which other passes share a file with it. Your approval of the design also approves unattended planning for every pass in it, which `pass-core` already allows. The designing session commits a planner prompt for each pass and one conductor prompt that holds the order table. The conductor decides nothing: it follows the table.

Each pass is planned just before it runs, so its plan reads the code as the earlier passes left it. The conductor launches the pass's planner. The planner writes the plan under the repo's `docs/plans/`, where the launch guard reads it, gets its one review, and launches the executor, as `planner.md` describes for unattended planning.

A pass ends in one of three states. It lands when it holds no call for you, touches no `auth-data` path, and has no `## Before merge` step: the conductor runs `approval-queue land`, since an executor under a conductor never runs the queue command. It waits for a close packet when it holds a call. It parks when it stops. The conductor reads the state from the PR, its checks, and the whole-branch review's verdict.

A pass that depends on an unmerged pass starts from that pass's branch, and only after that pass's review is accepted. Its PR opens against the default branch. If the parent lands, the dependent can land after it. If the parent waits for a close packet, the dependent joins that packet behind it in merge order, whether or not it holds a call of its own.

### Standing answers

Each stop a round can foresee has an answer, so the conductor never waits on you to keep going.

1. A pass stops on a question only you can answer. The executor commits, pushes, opens its draft PR if none exists, and writes the stop to STATUS. The conductor waits for the PR's checks, sends one `stop` packet (with a forced `gate-failed` call if a check is red), ends that session with `claude stop`, and launches the next pass that neither depends on the parked one nor shares a file with it.
2. Auto mode refuses a command. The executor uses the alternative its plan names, once. A second refusal is a stop under answer 1. No session edits a setting to get past a refusal.
3. A task needs a setting, hook, auto-mode entry, or permission rule changed. That is never an executor task. The planner writes it as a command for you in a close packet, and a pass that can't finish without it parks.
4. The weekly usage reads 85 percent or more before a launch. The conductor follows your answer to the second decision.
5. A pass's parent is parked. The pass parks too and never launches.
6. The busy check exits 1. If its line names the `claude daemon run` process or the Approval Queue server, the conductor checks the session rows and recent uncommitted edits by hand, and launches when both are clean. Any other hit ends launches in that repo, and the report says so.
7. The round passes twice its planned minutes. The pass in flight finishes, nothing new starts, and the conductor writes the report.
8. A plan comes out over twice the design's estimate for its pass, or its review finds something that changes the design. The pass parks under answer 1 before any code is written.
9. You answer a stop packet while the round is still running. The conductor records your ruling as `conductor.md` says, runs the packet's listed steps, and relaunches the parked pass once the pass in flight finishes. It never runs `approval-queue merge` on a stop packet. Passes that depended on the parked pass follow in order.
10. The conductor's session dies or the machine restarts. Nothing recovers on its own. STATUS names the conductor prompt and each open packet, and you or any session can relaunch the conductor.
11. An executor goes idle with its pass unfinished and no stop in STATUS. The conductor relaunches it from its prompt, twice at most. A third idle parks the pass under answer 1.

The conductor stays up while a stop packet or a close packet waits for you, and ends as `conductor.md` says, when no pass it owns is open.

### Pre-flight

Nothing is yours before this design's work starts.

Each round's design carries its own `[you: ...]` steps, and the session checks the sign-in before a launch: `claude -p "say ok" --model haiku` printed no sign-in warning on 2026-11-11.

Permissions checked: the work this design approves writes two files, the kit in this local record and a symlink at `~/.local/state/unattended-rounds/kit.md`, plus two backlog items in the workstation repo and two in the approval-queue repo. It edits no skill, hook, setting, permission rule, guard script, or queue code. The denial log held 57 rows from 2026-11-01 to 2026-11-11. The round rules route around its three largest classes: settings edits are never an executor task (10 rows), a session stops its own background command with `TaskStop` in place of `pkill` (9 rows), and a merge goes only through `approval-queue land` or an approved packet (3 rows).

### Estimate

The kit and its check come to 40 path minutes, which is this session's guess with no scored pass behind it.

A round of 600 planned path minutes should take about 220 to 240 actual minutes at the median ratio of 0.36 to 0.40, and about 500 to 510 at the ninth decile of 0.83 to 0.85. CI, reviews, and waits come on top. How much of the weekly allowance one pass spends was not measured. The first pilot round measures it, and that figure sets the size of later rounds.

### Models

Conductors and executors stay on Sonnet at `medium`, as the conductor and planner references set. Design and planning follow your answer to the third decision. Each plan gets one `standards:plan-reviewer` read. Anthropic's Fable 5.2 prompting page says "Early testers had good results with Claude Fable 5.2 as the planner and orchestrator for other models." The Fable allowance has its own weekly meter, which read 40 percent against 80 for all models.

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

No open item folds into the pilot, and one folds into the standing change. The sweep read 37 open workstation items at commit `7a62abe` and 3 open approval-queue items at commit `0bd4828`.

| Item | Verdict | What the pass does |
| --- | --- | --- |
| #72 Launch guard finds plans only under `docs/plans/` | keep | Nothing now. Pilot plans go under `docs/plans/`. The fix joins the standing change. |
| #50 An Approval Queue decision reaching the auto-mode classifier | keep | Nothing. It waits on the first merge after the queue cutover. |
| #63 A no-argument `gate.sh` wrapper for two adapters | keep | Nothing. |
| #73, #71, #70, #69, #68, #10, #14 | keep | Nothing. None names a file the pilot writes. |
| New: the busy check reads the daemon and the queue server as a running pass | file | Filed on approval, with the three probe results. |
| New: the busy check counts a finished session's row | file | Filed on approval. Until it is fixed, the conductor ends each finished executor with `claude stop`. |
| approval-queue #49, #41, #38 | keep | Nothing. None touches a stop packet, a base branch, or a round. |
| New, approval-queue: `merge <id>` accepts a stop packet, and the skill's approve step has no stop case | file | Filed on approval. Until it is fixed, standing answer 9 holds. |
| New, approval-queue: `merge` and `land` never read a PR's base branch | file | Filed on approval. Until it is fixed, a dependent PR opens against the default branch. |

### The end-to-end check

A reader that has seen only the kit must produce a complete round outline. A fresh Sonnet subagent gets the kit's path and three sample backlog items, and writes a round design outline. The check fails if the outline lacks the order table, the round id, a mechanism table, recorded searches, the denial-log read, a standing answer for each stop, the merge order, or the default branch as each PR's base.

The first pilot round is the larger check. It passes when every pass is merged, waiting in a close packet, or parked with a stop packet, the report leads STATUS, and the report shows a usage reading before each launch.

### Out of scope

The pilot leaves every guard, review, and approval where it is. It also leaves out:

- Two passes running at once in one repo, and a round that spans repos.
- Any change to who approves a design, an `auth-data` change, or a `## Before merge` step.
- Faster gates and CI, which belong to `dev-speed`.
- A standing model or effort change, which belongs to `monthly-model-review`.
- Running rounds on Orpheus or in the cloud.
- A fix to `claude-worktree-busy`, `claude-launch-guard`, or the queue's code ahead of the second design.
- A change to `standards:running-passes`. The round is a layer over the pass it defines.

## Technical notes

### Passes and order

1. The kit. One small change in this record: `unattended-rounds/kit/round-kit.md`, the symlink at `~/.local/state/unattended-rounds/kit.md`, the four backlog items, and the README record line. It runs in the approving session.
2. Pilot rounds. Each is its own design packet from a session Geoff asks, and each has two or more passes. A single pass runs as it does today. At least two rounds run before the standing change is designed.
3. The standing change. A second design carrying the pilot's reports, run as a round. Its homes, none approved here:
   - The approval-queue repo: a `round` field in `approval-queue/src/lib/facts.ts` and on `land`, pages grouped by round, the round report as an item, `merge` refusing a stop packet, and the base-branch check in `merge` and `land`.
   - `pass-core`: the lifecycle's design step becomes a round design, "Conductor" says a round of two or more has one, and the round rules go to the conductor and planner references or a new `references/round.md`.
   - The `approval-packet` skill: the round id, the stop case in its approve step, and the report. The packet writer's brief in `survey/writing/approval-brief.md` follows it.
   - The adapters `cairn-pass`, `site-pass`, and `dotfiles-pass`, and the pass section of `CLAUDE.md`, where each names what Geoff approves.
   - A required evidence line and the #72 fix in `claude-launch-guard`, the `/goal` and usage sections of the guards doc, and the miss class tag.

   `pass-core` holds 1,496 of its 1,500 words and `CLAUDE.md` 120 of its 120 lines, so each addition there is paired with a removal. Session names stay `<project>-<pass>` and `conductor-<project>`.

### Files

| File | Change |
| --- | --- |
| `unattended-rounds/kit/round-kit.md` (this record, local branch) | New. The round rules for a designing session, a planner, and a conductor. |
| `~/.local/state/unattended-rounds/kit.md` | New symlink to the kit. |
| `~/.dotfiles/BACKLOG.md` | Two new items, committed to main. |
| `~/Projects/approval-queue/BACKLOG.md` | Two new items, committed to main. |
| `unattended-rounds/README.md` | Record lines. |

### What the kit holds

The kit is agent-facing and follows `~/.claude/docs/voice/agent-facing.md`. It holds, in this order:

1. What a round design adds to a pass design: the round id, the pass table (outcome, files, class, path minutes, depends on, shares files with), the merge order, the usage ceiling, and the standing answers above. A design with one pass uses none of the kit.
2. The four planner rules and the class list.
3. The conductor prompt's additions: the order table; one planner launch per pass from its committed prompt; `approval-queue land` for a pass that qualifies; a usage read before each launch with `claude -p "/usage" --model haiku < /dev/null`; `claude stop <id>` on each finished or parked executor before the next busy check; a dependent pass's worktree cut with `git -C <repo> worktree add .claude/worktrees/<pass> -b <branch> origin/<parent branch>` and entered by the executor with `EnterWorktree` `path`; each `approval-queue packet` run as a background command; long commands under `timeout`. The queue rules follow: the round id opens every packet title and `land` claim; every PR's base is the default branch; a pass counts as finished only on its PR, green checks, and an accepted review; a stop packet waits for the PR's checks and carries a forced `gate-failed` call on a red one; an approved stop packet runs its listed steps and never `merge`; close packets go out after the last pass ends, three unforced calls to a packet at most, split by dependency chain, the last one naming the report's path. The kit names the two places a round differs from `conductor.md`: a stop goes to you as a `stop` packet while the next independent pass runs (`conductor.md:38-41` has the conductor ask and wait), and standing answer 6 is the settled result of the investigation that `conductor.md:47-48` calls for.
4. The executor prompt's additions: the `Round: <id>` line in the PR body, the default branch as the PR's base, the stop procedure of standing answer 1, and `TaskStop` for a background command it started.
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
| A dependent pass's PR merges into main | `merge` and `land` run `gh pr merge` and read no base branch (`bin/.local/bin/approval-queue:152-155` in the approval-queue repo) | The PR was opened against its parent's branch | The conductor reads `baseRefName` with `gh pr view` before `land` or a close packet, and a wrong base parks the pass. |
| An approved stop packet resumes its pass | `merge <id>` refuses only an undecided item, a non-approve, a stale item, or a design (the approval-queue repo's `README.md:105`) | A session follows the `approval-packet` skill's approve step and runs `merge` on the stop packet | `gh` refuses to merge a draft PR. Standing answer 9 names the steps to run in its place. |
| A stop packet is accepted with a red check | The queue refuses it without a forced `gate-failed` call (`bin/.local/bin/approval-queue:635-637`) | Checks stay pending past the command's 15-minute wait | The conductor waits for the checks before it sends. A second refusal leaves the stop in STATUS and the report. |
| A round's calls fit its close packets | `UNFORCED_CAP = 3` (`approval-queue/src/lib/facts.ts:112`) | One dependency chain holds more than three unforced calls | The chain splits at a pass boundary into two packets, and the conductor merges the second only after the first. |
| An idle executor is relaunched | Anthropic's Opus 5.5 page: "stop after two or three automatic continuations on the same task" | The relaunch idles again | Standing answer 11 parks the pass after two relaunches. |
| The usage read | `claude -p "/usage" --model haiku < /dev/null` printed the weekly line, 2026-11-11 | The output changes shape or prints no weekly line | An unreadable figure counts as over the ceiling. |
| Waiting for the reset | Not probed. The `/goal` page says a goal pauses on a usage limit and resumes at the reset | The session never resumes | The report is written before the wait. STATUS names the conductor prompt for a relaunch. |
| `/goal` holds a `--bg` session to its condition | Probe `94a50d24`: "Goal achieved" after three held turns | The condition names no end the session can reach | The condition lists every end. A cleared goal doesn't show in `state.json`, so the conductor reads STATUS. |
| The machine stays up | `uupd` stages updates without applying them, and `sleep-inactive-ac-type` is `nothing` on pavilion | A power loss or a manual restart | Standing answer 10. |

### What each decision changes

| Decision | Answer | Effect on the kit |
| --- | --- | --- |
| When the standing change is built | Pilot now, standing change after 2026-12-11 | The kit is written as this design describes. |
| | Pilot now, queue support now | The kit is written. The session also designs the queue's round support and the skill's stop case as a round, and that design returns to Geoff first. The kit's queue rules are dropped as each fix lands. |
| | Whole standing change now | No kit. The session designs the standing change as a round across the approval-queue and workstation repos, and that design returns to Geoff first. |
| | Nothing until 2026-12-11 | No kit. The record waits, and this design returns after the freeze. |
| Low weekly allowance | Wait for the reset | Standing answer 4 reads: finish the pass in flight, start nothing new, write the report, wait for the reset. |
| | Usage credits | Standing answer 4 reads: keep launching until the credit ceiling Geoff names, then wait. The session checks how a credit cap is set before the first round and reports it in that round's design. |
| Trials | Both | Planner prompts name Fable 5.2 at `high`. Kit section 6 exists. Each round report carries a line for each trial. |
| | `/goal` only | Planner prompts name Opus 5.5 at `high`. Kit section 6 exists. |
| | Neither | Planner prompts name Opus 5.5 at `high`. Kit section 6 is left out. |

The kit is written only after the decision arrives, from the answers given.

### Measures

The baseline per 100 merged PRs is 33 misses in all, 8.2 for an unprobed mechanism, 6.0 for a file list, and 6.0 for a permission block. The goal of half is counted over the first 100 PRs merged after the standing change lands. Pilot rounds report the same four figures for their own PRs, which will be too few to conclude from.

### Claude's calls

- A round holds at most about 600 planned path minutes. The pilot's usage figure may change that. The count of one to six passes is Geoff's.
- `standards:running-passes` stays as it is. The round is a layer in `pass-core` over the pass it defines.
- The queue is treated as frozen with the skills, since the refinement's pass 2a changed it.
- A dependent pass's PR opens against the default branch.
- An idle executor is relaunched twice at most, then parked.
- Close packets go out after the round's last pass ends, split by dependency chain.
- The usage ceiling is 85 percent of the weekly allowance.
- Passes run one at a time, in one repo.
- The kit lives in this record with a symlink under `~/.local/state`, since the record is unpushed and a session can't find it otherwise.
- The conductor ends a parked executor's session. A parked pass resumes in a fresh session that the conductor launches from STATUS after Geoff's answer.
- Each pass is planned just before it runs, by a planner the conductor launches.
- The conductor runs `approval-queue land`. A dependent pass joins its parent's close packet, and starts only after its parent's review is accepted.
- The symlink points into this record's worktree at `.claude/worktrees/unattended-rounds`, which stays in place until the initiative closes. A removed worktree breaks the link where a designing session will report it.
- An unreadable usage figure counts as over the ceiling.

A builder check by a fresh Opus reader raised five questions on 2026-11-11. The calls above settle four of them, and the fifth is Geoff's three answers, which the kit waits for. That check read the first version, before the queue section and the ruling on the basic unit.

### Left to the builder

The kit's wording, the round id's format, the sample backlog items for its check, and the report's layout. The first round's repo and passes are Geoff's to pick when he asks for one.

### Sources

- `unattended-rounds/research/2026-11-11-evidence.md`: the timeline figures, the denial log, the miss counts, the probes, and the Anthropic pages.
- `claude/.claude/skills/pass-core/SKILL.md` and its `references/` in the workstation repo, read at `main` on 2026-11-11.
- The `workstation-refinement` record on its local branch, for the freeze and its measure read.
- The approval-queue repo at commit `0bd4828`: its `README.md`, `bin/.local/bin/approval-queue`, and `approval-queue/src/lib/facts.ts`.
