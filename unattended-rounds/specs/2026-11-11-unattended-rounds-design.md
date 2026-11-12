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
- A round design carries an acceptance list for each pass and the assumptions its passes share, and one fresh reader checks it before it reaches you.
- A round's planner shows a probe or a quoted source for each mechanism, a recorded search behind each file list, and a read of the last 30 days of auto-mode refusals.
- When you return, STATUS opens with a round report: each pass's state, planned against actual minutes, the usage spent, and every stop and planning miss by class.
- The Approval Queue has no notion of a round today. The rounds that build this change run on today's queue, so each of their packet titles and digest lines opens with the round's id, and their conductor prompts hold a rule for each place the queue's commands fit a round badly.
- You said on 2026-11-11 that the freeze can lift for this overhaul and that this month's extra credits go to it. The whole change is built now, and its build design is the next packet you get. Approving this one builds nothing.

### The round as the basic unit

You ruled on 2026-11-11 that the round becomes the basic unit on the whole workstation, unless Anthropic's guidance says that is a bad idea. It doesn't say that. A reader fetched 14 Anthropic pages and quoted them for and against. They support one piece of work per fresh session, state kept in files, a plan held outside the model, and a person approving the result at the end. No built-in Claude Code feature does what a round does: the agent view parks a session that needs you and orders nothing, a workflow script takes no approval mid-run, and the agent teams page advises against teams for sequential work.

The pages carry seven cautions. Four bear on how a round is built, and the round answers each. The other three concern agent teams and the cost of a fresh session, and the evidence file lists them.

| Anthropic's caution | What a round does |
| --- | --- |
| "we recommend finding the simplest solution possible, and only increasing complexity when needed" | A one-pass round has no conductor and no order table. |
| "you find out the next morning that it spent the whole night building on the wrong assumption" | A pass builds on another pass only after that pass's whole-branch review is accepted. A pass with an open finding parks, and so does every pass that depends on it. |
| "Claude declares victory on the entire project too early" | The conductor marks a pass finished from its PR, its checks, and its review verdict, never from the executor's last message. |
| "Running several sessions or subagents at once multiplies token usage" | Passes run one at a time, and the overhaul's first round measures what a pass costs. |

The ruling makes the standing change larger than the version of this design you saw first. It rewrites `pass-core` so that every design is a round design. It also changes the `approval-packet` skill, the three repo adapters, the pass section of `CLAUDE.md`, the Approval Queue, and the `standards:brainstorming` skill. A pass stays what `standards:running-passes` defines: one plan, one executor, one worktree, and one PR.

Source: `unattended-rounds/research/2026-11-11-evidence.md:110`

### The Approval Queue in a round

The queue works a pass at a time, and reading its code against a round found five gaps. The rounds that build the standing change run on today's queue, and their conductor prompts cover each gap with a rule. The standing change then closes each gap in the queue.

| The queue today | Rule until the queue changes | Standing change |
| --- | --- | --- |
| Nothing groups one round's packets or digest lines. | Each packet title and each `land` claim opens with the round id. | A `round` field on packets and digest lines, and pages grouped by round. |
| Nothing reports a round as a whole. | The report leads STATUS, and the round's last packet names its path. | The round report as an item on the queue's pages. |
| Approve on a stop packet reads as "merge what was read", and `merge <id>` accepts a stop packet. | The conductor runs the stop packet's listed steps and never runs `merge` on it. | `merge` refuses a stop packet, the page says Approve resumes the pass, and the skill gains a stop case. |
| `merge` and `land` never read a PR's base branch. A PR based on its parent's branch would merge into that branch and never reach main. | A dependent pass's PR opens against the default branch. Its diff repeats the parent's lines until the parent merges. | `merge` and `land` refuse a PR whose base isn't the default branch. |
| A close packet takes at most three unforced calls. | A round with more sends two or more close packets, split by dependency chain. | The cap stays at three to a packet. Each round report counts the calls its round sent you. |

Close packets go out when the round's last pass ends, since a packet's PR list is fixed once it is sent. Stop packets go out as each pass parks.

Source: `unattended-rounds/research/2026-11-11-evidence.md:93`

### A design that holds for a whole round

A round raises the price of a wrong design. In one pass it costs a stop or a PR. In a round, later passes build on it while you are away.

Today's design step was sized for one pass. The design is a page or less, and a pass in a round would get one line of outcome. The plan review reads mechanics and feasibility, and an `ordinary` plan gets no read. The closing review reads the diff against the design, so a wrong design passes it.

Your merged PRs show the exposure. 39 of about 220 planning misses were at the design level: 20 were a design or plan missing a part or prior art, 15 an owner decision left open, and 4 an ambiguous instruction.

A round design of two or more passes follows four rules, each drawn from Anthropic's guidance.

| What can go wrong | The rule |
| --- | --- |
| The design misreads what you want. | Each pass carries an acceptance list: what you would see or run when the pass is done, each item able to fail. The designing session plays every list back to you at the sitting, with a mockup for anything you will look at. Your approval fixes the lists. A planner or executor may add a check and never edits or drops one. |
| The design rests on a wrong assumption. | The design lists each assumption that more than one pass depends on, with a probe run or a quoted source. Where the dependencies allow, the pass resting on the least-proven assumption runs first. |
| The design is missing a part. | One fresh reader checks the round design before it reaches you, whatever its class. It asks whether a builder could plan every pass from it, and whether any acceptance item could pass on a wrong result. |
| The run drifts from the design. | Each PR shows evidence for every acceptance item: the command and its output, or a screenshot. The closing reviewer checks each item against that evidence. An item that can't be met as written parks the pass. |

These rules lengthen the design sitting, since you confirm an acceptance list for every pass. This design takes that trade for you. Send it back if the sitting should stay as short as it is today.

The `standards:brainstorming` skill runs the conversation that produces a design. A read of it against Anthropic's guidance on 2026-11-11 found four gaps, and the standing change closes three. The written design gains a statement of what done looks like. The skill reads the code, your files, and the web without asking first, where today it waits for a yes. Its description stops promising two or three approaches, which the body shows only when they help you decide. The fourth gap is an eval for the skill, which is filed as a backlog item.

Source: `unattended-rounds/research/2026-11-11-evidence.md:167` and `:226`

### If you approve

Approving builds nothing. It confirms the round rules and your two rulings of 2026-11-11, and it starts the build design.

1. The session records both rulings in this record and in the `workstation-refinement` record, and files the brainstorming skill's eval as a backlog item.
2. The session designs the standing change: the queue's passes first, then `pass-core` and the skills, then the brainstorming skill. That design carries an acceptance list for each pass and a mockup of each queue page that changes.
3. The build design comes to you as the next packet, with its pre-flight steps. No skill, hook, setting, permission rule, or queue code changes before you approve it.
4. Once you approve it, the build runs as rounds under the rules in this design.

### Your two rulings of 2026-11-11

You said in chat that the freeze can lift for this overhaul, and that you have extra credits this month and want them spent on it. An approval normally reaches a session through the queue, so this design records both as decided for you. Approving it confirms them, and sending it back undoes them.

The freeze you accepted on 2026-11-10 as D6 allows removals only until 2026-12-11. It lifts for the standing change alone, in the files this design names in the workstation, approval-queue, and standards repos, and it holds for all other work. The refinement's plan reruns its measuring scripts thirty days after its pass 3 merged, which falls on 2026-12-11. The exception costs that run its clean reading, since it will now read a system that changed mid-freeze. Each of the overhaul's PRs carries a `Round:` line so that read can count them apart.

The earlier version of this design recommended two pilot rounds first. They would have supplied three figures that only a real round gives: what a pass costs of the weekly allowance, how many calls a round sends you, and which queue rule chafes. The overhaul's first round now supplies them, and its report carries all three.

Usage credits let the overhaul's sessions keep working past the weekly limit. You cap them with a monthly spend limit under Settings > Usage on claude.ai, which `/usage-credits` opens. A session can't set that limit. `/usage` printed no usage-credits row on 2026-11-11. Anthropic's cost page says the row shows while credits are on, so they looked off at that read.

Source: `unattended-rounds/research/2026-11-11-evidence.md:267`, and `workstation-refinement/README.md:167` and `workstation-refinement/plans/2026-11-10-workstation-refinement-plan.md:5`, `:275`, and `:283` on the local `workstation-refinement` branch

### Decide: What a later round does when the weekly allowance runs low

The overhaul's rounds keep going on this month's credits, by your ruling. This decision covers every round after them. The week stood at 82 percent used on 2026-11-11, and three sessions waited about 64 hours each on the limit the week before. A later round can wait for the reset, or keep going on credits up to the monthly spend limit you have set.

Source: `unattended-rounds/research/2026-11-11-evidence.md:23` and `:267`

- Finish the pass in flight, start nothing new, and wait for the reset (recommended)
- Keep going on usage credits, up to your monthly spend limit

### Decide: Which trials the overhaul runs ahead of the December model review

Two changes would help a round and both belong to the monthly model review. One is Fable 5.2 at `high` designing and planning a round, where `pass-core` sets Opus. The other is `/goal` at the head of each executor and conductor prompt, which the guards doc holds back until that review. The overhaul's rounds can run both as trials and report them to the review.

Source: `claude/.claude/docs/unattended-work-guards.md:133` and `claude/.claude/skills/pass-core/SKILL.md:23` in the workstation repo

- Run both trials in the overhaul's rounds and report them to the December review (recommended)
- Run the `/goal` trial only, with Opus planning
- Run neither: Opus plans, and sessions keep the `/loop` wake-up alone

### Worth knowing

The weekly allowance resets on 2026-11-13 at 11pm Anchorage time. Until usage credits are on, the build design and the first round run on what is left of the week and stop at the limit. `/usage` also suggests giving general-purpose subagents a cheaper model, which it ties to 87 percent of the last day's requests. That suggestion goes to the model review as evidence.

### How a round runs

A round of two or more passes is one design, one conductor, and passes that run one at a time in one repo. The design names a round id, which every PR body, packet title, and `land` claim carries. The design lists each pass with its outcome, acceptance list, files, class, estimate, what it depends on, and which other passes share a file with it. A pass that shares a file with an unmerged pass counts as depending on it. Your approval of the design also approves unattended planning for every pass in it, which `pass-core` already allows. The designing session commits a planner prompt for each pass and one conductor prompt that holds the order table. The conductor decides nothing: it follows the table.

Each pass is planned just before it runs, so its plan reads the code as the earlier passes left it. The conductor launches the pass's planner. The planner writes the plan under the repo's `docs/plans/`, where the launch guard reads it, gets its one review, and launches the executor, as `planner.md` describes for unattended planning.

A pass ends in one of three states. It lands when it holds no call for you, touches no `auth-data` path, and has no `## Before merge` step: the conductor runs `approval-queue land`, since an executor under a conductor never runs the queue command. It waits for a close packet when it holds a call. It parks when it stops. The conductor reads the state from the PR, its checks, and the whole-branch review's verdict.

A pass that depends on an unmerged pass starts from that pass's branch, and only after that pass's review is accepted. Its PR opens against the default branch. If the parent lands, the dependent can land after it. If the parent waits for a close packet, the dependent joins that packet behind it in merge order, whether or not it holds a call of its own.

### Standing answers

Each stop a round can foresee has an answer, so the conductor never waits on you to keep going.

1. A pass stops on a question only you can answer. The executor commits, pushes, opens its draft PR if none exists, and writes the stop to STATUS. The conductor waits for the PR's checks and sends one `stop` packet. The packet carries a forced `gate-failed` call if a check is red or the review's verdict is `fix` or `escalate`, and a forced call if the PR body has a `## Before merge` section. The conductor then ends that session with `claude stop` and launches the next pass that doesn't depend on the parked one.
2. Auto mode refuses a command. The executor uses the alternative its plan names, once. A second refusal is a stop under answer 1. No session edits a setting to get past a refusal.
3. A task needs a setting, hook, auto-mode entry, or permission rule changed. That is never an executor task. The planner writes it as a command for you in a close packet, and a pass that can't finish without it parks.
4. The weekly usage reads 85 percent or more before a launch. The conductor follows your answer on a low weekly allowance. The overhaul's rounds are the exception: they keep launching while `/usage` shows a usage-credits row under its spend limit.
5. A pass's parent is parked. The pass parks too and never launches.
6. The busy check exits 1. If its line names the `claude daemon run` process or the Approval Queue server, the conductor checks the session rows and recent uncommitted edits by hand, and launches when both are clean. Any other hit ends launches in that repo, and the report says so.
7. The round passes twice its planned minutes. The pass in flight finishes, nothing new starts, and the conductor writes the report.
8. A plan comes out over twice the design's estimate for its pass, its review finds something that changes the design, or the planner finds an acceptance item it can't plan for as written. The pass parks before any code is written. The planner commits the plan on the pass's branch, pushes it, and opens a draft PR that holds the plan alone, so the conductor's stop packet has a PR to name.
9. You answer a stop packet while the round is still running. The conductor records your ruling as `conductor.md` says, runs the packet's listed steps, and relaunches the parked pass once the pass in flight finishes. It never runs `approval-queue merge` on a stop packet. Passes that depended on the parked pass follow in order. A stop packet you send back is fixed forward and resent with `--replies`, and each of your notes gets an `approval-queue reply`. A pass that resumes after the round's close packets have gone out lands if it qualifies, or gets a close packet to itself.
10. The conductor's session dies or the machine restarts. Nothing recovers on its own. STATUS names the conductor prompt and each open packet, and you or any session can relaunch the conductor.
11. An executor goes idle with its pass unfinished and no stop in STATUS. The conductor relaunches it from its prompt, twice at most. A third idle parks the pass under answer 1.
12. An executor finds an acceptance item it can't meet as written, or an assumption the design lists proves false. The pass parks under answer 1. No session rewrites the item or builds around it.

The conductor stays up while a stop packet or a close packet waits for you, and ends as `conductor.md` says, when no pass it owns is open.

### Pre-flight

One step is yours, and the work can start without it.

`[you: turn usage credits on and set a monthly spend limit]` Under Settings > Usage on claude.ai, set the limit to the most this overhaul may spend. Anthropic's advice for an unattended run is "Give it a cap on turns or spend". The session reads `/usage` before each launch. With no usage-credits row there, it stays inside the weekly allowance and stops at the limit.

Each round's design carries its own `[you: ...]` steps, and the session checks the sign-in before a launch: `claude -p "say ok" --model haiku` printed no sign-in warning on 2026-11-11.

Permissions checked: the work this design approves writes record files in this local record, one line in the local `workstation-refinement` record, one backlog item, and the build design. It edits no skill, hook, setting, permission rule, guard script, or queue code. The denial log held 57 rows from 2026-11-01 to 2026-11-11. The round rules route around its three largest classes: settings edits are never an executor task (10 rows), a session stops its own background command with `TaskStop` in place of `pkill` (9 rows), and a merge goes only through `approval-queue land` or an approved packet (3 rows).

### Estimate

The build design comes to about 150 path minutes, which is this session's guess with no scored pass behind it.

A round of 600 planned path minutes should take about 220 to 240 actual minutes at the median ratio of 0.36 to 0.40, and about 500 to 510 at the ninth decile of 0.83 to 0.85. CI, reviews, and waits come on top. How much of the weekly allowance one pass spends was not measured. The overhaul's first round measures it, and that figure sets the size of later rounds.

### Models

Conductors and executors stay on Sonnet at `medium`, as the conductor and planner references set. Design and planning follow your answer on the trials. Each plan gets one `standards:plan-reviewer` read. Anthropic's Fable 5.2 prompting page says "Early testers had good results with Claude Fable 5.2 as the planner and orchestrator for other models." The Fable allowance has its own weekly meter, which read 44 percent against 82 for all models.

### What the planner must show

Four rules aim at the largest planning-miss classes, and each one leaves something a reviewer can check. The counts come from about 220 misses in 89 of the 668 PRs merged since 2026-10-10.

| Miss class | Misses | Rule | What the plan reviewer checks |
| --- | --- | --- | --- |
| A mechanism assumed and never probed | 55 | The plan carries a mechanism table. Each row names a probe run and its output, or a quoted source with its line or URL. | No row says "expected" or cites nothing. |
| An incomplete file or consumer list | 40 | The file list is built from searches. The plan records each search and its hit count. | Each listed file traces to a search, and each hit is listed or dismissed with a reason. |
| A permission, auto-mode, or isolation block | 40 | `Permissions checked:` cites a read of the last 30 days of the denial log against each task's commands. | The line names the log's date range and each class it found. |
| A stop with no standing answer | 8 | Every stop the plan writes has a standing answer or parks the pass. | No stop says "ask Geoff". |

Each planning miss in a round's PR also carries one class from the ten in the evidence file, so the next count needs no sorting.

### Backlog sweep

One open item and four new findings fold into the standing change. This sweep read the open items against the round rules alone, and the build design reruns it against every file the standing change writes. It read 37 open workstation items at commit `7a62abe` and 3 open approval-queue items at commit `0bd4828`.

| Item | Verdict | What the pass does |
| --- | --- | --- |
| #72 Launch guard finds plans only under `docs/plans/` | fold | The standing change fixes it. Until then a round's plans go under `docs/plans/`. |
| #50 An Approval Queue decision reaching the auto-mode classifier | keep | Nothing. It waits on the first merge after the queue cutover. |
| #63 A no-argument `gate.sh` wrapper for two adapters | keep | Nothing. |
| #73, #71, #70, #69, #68, #10, #14 | keep | Nothing here. The build design's sweep reads each against its files. |
| New: the busy check reads the daemon and the queue server as a running pass | fold | A pass of the standing change, with the three probe results. |
| New: the busy check counts a finished session's row | fold | A pass of the standing change. Until it lands, the conductor ends each finished executor with `claude stop`. |
| approval-queue #49, #41, #38 | keep | Nothing. None touches a stop packet, a base branch, or a round. |
| New, approval-queue: `merge <id>` accepts a stop packet, and the skill's approve step has no stop case | fold | A pass of the standing change. Until it lands, standing answer 9 holds. |
| New, approval-queue: `merge` and `land` never read a PR's base branch | fold | A pass of the standing change. Until it lands, a dependent PR opens against the default branch. |
| New, standards: the brainstorming skill has no eval | file | Filed on approval through `standards:log-issue`. |

### The end-to-end check

A reader that has seen only the changed `pass-core` must produce a complete round outline. After the standing change lands, a fresh Sonnet subagent gets the skill's path and three sample backlog items, and writes a round design outline. The check fails if the outline lacks the order table, the round id, an acceptance list for each pass, the shared assumptions, a mechanism table, recorded searches, the denial-log read, a standing answer for each stop, the merge order, or the default branch as each PR's base.

The overhaul's first round is the larger check. It passes when every pass is merged, waiting in a close packet, or parked with a stop packet, the report leads STATUS, and the report shows a usage reading before each launch.

### Out of scope

The standing change leaves every guard, review, and approval where it is. It also leaves out:

- Two passes running at once in one repo, and a round that spans repos.
- Any change to who approves a design, an `auth-data` change, or a `## Before merge` step.
- Faster gates and CI, which belong to `dev-speed`.
- A standing model or effort change, which belongs to `monthly-model-review`.
- Running rounds on Orpheus or in the cloud.
- Any build under this approval. Every file change comes to you in the build design.
- The four design rules on a round of one pass. The build design settles whether a single pass takes them.
- An eval for the brainstorming skill, which is filed as a backlog item.
- A change to `standards:running-passes`. The round is a layer over the pass it defines.

## Technical notes

### Passes and order

1. This approval. Record lines in this record and in the `workstation-refinement` record, one backlog item, and the build design. It runs in the approving session.
2. The standing change. It has more than six passes in three repos, so the build design splits it into rounds of one repo each: the queue's first, then the workstation's, then the standards repo's. Geoff approves all of them at one sitting, and a later round starts when the one before it has merged. Its homes, none approved here:
   - The approval-queue repo: a `round` field in `approval-queue/src/lib/facts.ts` and on `land`, pages grouped by round, the round report as an item, `merge` refusing a stop packet, and the base-branch check in `merge` and `land`.
   - `pass-core`: the lifecycle's design step becomes a round design, "Conductor" says a round of two or more has one, and the round rules go to the conductor and planner references or a new `references/round.md`. The four design rules go to `planner.md` "Design".
   - The `approval-packet` skill: the round id, the stop case in its approve step, and the report. The packet writer's brief in `survey/writing/approval-brief.md` follows it.
   - The adapters `cairn-pass`, `site-pass`, and `dotfiles-pass`, and the pass section of `CLAUDE.md`, where each names what Geoff approves.
   - A required evidence line and the #72 fix in `claude-launch-guard`, the `/goal` and usage sections of the guards doc, and the miss class tag.
   - `claude-worktree-busy`: the two false hits, a daemon or queue-server process read as a running pass and a finished session's row.
   - `standards:brainstorming` in the standards repo: a statement of what done looks like in the written design's list, recon with no yes first, and a description that matches the body.

   `pass-core` holds 1,496 of its 1,500 words and `CLAUDE.md` 120 of its 120 lines, so each addition there is paired with a removal. Session names stay `<project>-<pass>` and `conductor-<project>`.

### Files

The table covers this approval alone. The build design lists the standing change's files.

| File | Change |
| --- | --- |
| `unattended-rounds/README.md` (this record, local branch) | Record lines. |
| `unattended-rounds/specs/` (this record) | New. The build design. |
| `workstation-refinement/README.md` (local `workstation-refinement` branch) | One line under "Next" recording the freeze exception. |
| A backlog file, chosen by `standards:log-issue` | One new item for the brainstorming skill's eval. |

### What the round rules hold

The rules are agent-facing and follow `~/.claude/docs/voice/agent-facing.md`. The standing change puts them in `pass-core` and its references. The rounds that build it carry them in their committed prompts, since the skills don't hold them yet. They hold, in this order:

1. What a round design adds to a pass design: the round id, at most 12 characters; the pass table (outcome, acceptance list, files, class, path minutes, depends on, shares files with); the assumptions more than one pass depends on, each with a probe or a quoted source; the merge order; the usage ceiling; and the standing answers above. The order puts the least-proven assumption first where dependencies allow, and counts a shared file as a dependency. The designing session plays each acceptance list back to Geoff, shows a mockup for anything he will look at, and runs the `standards:brainstorming` builder check with one fresh Opus reader before the packet. A design with one pass uses none of these.
2. The four planner rules and the class list.
3. The conductor prompt's additions: the order table; one planner launch per pass from its committed prompt; `approval-queue land` for a pass that qualifies; a usage read before each launch with `claude -p "/usage" --model haiku < /dev/null`; `claude stop <id>` on each finished or parked executor before the next busy check; a dependent pass's worktree cut with `git -C <repo> worktree add .claude/worktrees/<pass> -b <branch> origin/<parent branch>` and entered by the executor with `EnterWorktree` `path`; each `approval-queue packet` run as a background command; long commands under `timeout`. The queue rules follow: the round id opens every packet's title, its text headline, and every `land` claim, inside the queue's 80-character limit; every PR's base is the default branch; a pass counts as finished only on its PR, green checks, and an accepted review; a stop packet waits for the PR's checks, carries a forced `gate-failed` call on a red check or a `fix` or `escalate` verdict, and carries a forced call on a `## Before merge` section; an approved stop packet runs its listed steps and never `merge`; a sent-back packet is fixed forward and resent with `--replies`, and every note gets a `reply`; close packets go out after the last pass ends, three unforced calls to a packet at most, split by dependency chain, the last one naming the report's path; when a chain splits, the second packet merges only after the first, and is resent if the first was sent back. Two of these differ from `conductor.md` as it stands, and the standing change rewrites both: a stop goes to you as a `stop` packet while the next independent pass runs (`conductor.md:38-41` has the conductor ask and wait), and standing answer 6 is the settled result of the investigation that `conductor.md:47-48` calls for.
4. The executor prompt's additions: the `Round: <id>` line in the PR body, the default branch as the PR's base, the stop procedure of standing answers 1 and 12, and `TaskStop` for a background command it started. The PR body lists each acceptance item with its evidence, and the whole-branch review's dispatch names the acceptance list. The planner prompt carries standing answer 8.
5. The round report's fields: for each pass its state, PR, planned and actual path minutes, and usage before and after; then stops, refusals, and planning misses by class. The conductor writes the report before any long wait and again at the end, and puts its path on the first line of the repo's STATUS.
6. If the trials decision allows it, the `/goal` line for each prompt. Its condition names every legitimate end: PR ready, parked with a stop in STATUS, or usage at the ceiling.

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
| A stop packet is accepted | The queue refuses a red check or a `fix` or `escalate` verdict without a forced `gate-failed` call, and a `## Before merge` section without a forced call (`bin/.local/bin/approval-queue:635-640`) | Checks stay pending past the command's 15-minute wait | The conductor waits for the checks before it sends. A second refusal leaves the stop in STATUS and the report. |
| A pass parked at planning has a PR | A stop packet names at least one PR (`approval-queue/src/lib/facts.ts:252`) | The planner stopped with nothing pushed | Standing answer 8 has the planner push its plan and open a draft PR first. |
| A pass sharing a file with an unmerged pass merges clean | `merge` stops at the first failure (`bin/.local/bin/approval-queue:327`) | The pass was cut from the default branch and conflicts | The order table counts a shared file as a dependency, so the pass starts from the other pass's branch. |
| An acceptance list holds through a run | Anthropic's harness article fixes its feature list and lets an agent change only a `passes` field | A session rewrites an item to fit what it built | The closing reviewer reads the PR's list against the design's. A changed item is a `fix` verdict. |
| A round's calls fit its close packets | `UNFORCED_CAP = 3` (`approval-queue/src/lib/facts.ts:112`) | One dependency chain holds more than three unforced calls | The chain splits at a pass boundary into two packets, and the conductor merges the second only after the first. A send-back of the first moves the heads under the second, which the queue then refuses as out of date (`bin/.local/bin/approval-queue:302`), so the conductor resends the second. |
| An idle executor is relaunched | Anthropic's Opus 5.5 page: "stop after two or three automatic continuations on the same task" | The relaunch idles again | Standing answer 11 parks the pass after two relaunches. |
| The usage read | `claude -p "/usage" --model haiku < /dev/null` printed the weekly line, 2026-11-11 | The output changes shape or prints no weekly line | An unreadable figure counts as over the ceiling. |
| Waiting for the reset | Not probed. The `/goal` page says a goal pauses on a usage limit and resumes at the reset | The session never resumes | The report is written before the wait. STATUS names the conductor prompt for a relaunch. |
| `/goal` holds a `--bg` session to its condition | Probe `94a50d24`: "Goal achieved" after three held turns | The condition names no end the session can reach | The condition lists every end. A cleared goal doesn't show in `state.json`, so the conductor reads STATUS. |
| The machine stays up | `uupd` stages updates without applying them, and `sleep-inactive-ac-type` is `nothing` on pavilion | A power loss or a manual restart | Standing answer 10. |

### What each decision changes

| Decision | Answer | Effect on the round rules |
| --- | --- | --- |
| A later round on a low weekly allowance | Wait for the reset | Standing answer 4 reads: finish the pass in flight, start nothing new, write the report, wait for the reset. |
| | Usage credits | Standing answer 4 reads: keep launching while `/usage` shows a usage-credits row under its spend limit. Once the limit is reached or the row is gone, write the report and wait for the reset. |
| Trials | Both | Planner prompts name Fable 5.2 at `high`. Each conductor and executor prompt opens with a `/goal` line. Each round report carries a line for each trial. |
| | `/goal` only | Planner prompts name Opus 5.5 at `high`. Each conductor and executor prompt opens with a `/goal` line. |
| | Neither | Planner prompts name Opus 5.5 at `high`, and no prompt carries a `/goal` line. |

The build design is written from the answers given.

### Measures

The baseline per 100 merged PRs is 33 misses in all, 8.2 for an unprobed mechanism, 6.0 for a file list, and 6.0 for a permission block. The goal of half is counted over the first 100 PRs merged after the standing change lands. The overhaul's rounds report the same four figures for their own PRs, which will be too few to conclude from. They also count the three design-level classes, 5.8 per 100 merged PRs at the baseline, and each pass parked on an acceptance item or a false assumption.

### Claude's calls

- A round holds at most about 600 planned path minutes. The overhaul's usage figure may change that. The count of one to six passes is Geoff's.
- `standards:running-passes` stays as it is. The round is a layer in `pass-core` over the pass it defines.
- The freeze covered the queue as well as the skills, since the refinement's pass 2a changed it. Geoff's exception is read as covering both.
- A dependent pass's PR opens against the default branch.
- An idle executor is relaunched twice at most, then parked.
- Close packets go out after the round's last pass ends, split by dependency chain.
- The four design rules apply to a round of two or more passes. They lengthen Geoff's sitting, which is his trade to reverse.
- The fresh read of a round design is the `standards:brainstorming` builder check, one Opus reader, in any class.
- A pass parked at planning pushes its plan and opens a draft PR, so the stop goes out as a `stop` packet.
- A pass that shares a file with an unmerged pass counts as depending on it.
- A round id is at most 12 characters.
- The usage ceiling is 85 percent of the weekly allowance.
- Passes run one at a time, in one repo.
- The standing change is split into rounds of one repo each, the queue's first, all approved at one sitting. A later round starts when the one before it has merged.
- The cap of three unforced calls stays per packet.
- The four new findings on the busy check and the queue fold into the standing change in place of backlog items.
- The brainstorming skill takes three changes, and its eval is filed as a backlog item.
- The overhaul's sessions read the usage-credits row from `/usage`. With no row, they stay inside the weekly allowance.
- The conductor ends a parked executor's session. A parked pass resumes in a fresh session that the conductor launches from STATUS after Geoff's answer.
- Each pass is planned just before it runs, by a planner the conductor launches.
- The conductor runs `approval-queue land`. A dependent pass joins its parent's close packet, and starts only after its parent's review is accepted.
- An unreadable usage figure counts as over the ceiling.

A builder check by a fresh Opus reader raised five questions on 2026-11-11. The calls above settle four of them, and the fifth was Geoff's answers to the decisions. That check read the first version, before the queue section and the ruling on the basic unit. A second check the same day read the amended version against the queue's code and raised six findings: a stop at planning with no PR to name, two more triggers for a forced call, a shared file between unmerged passes, a sent-back first packet of a split chain, a stop packet sent back or answered late, and lines that assumed the recommended first answer. Each is folded above as Claude's call, and it found nothing more for Geoff. Geoff's rulings of 2026-11-11 came after both checks, and no fresh reader has read the edits they caused.

### Left to the builder

The round id's format, the sample backlog items for the end-to-end check, and the report's layout. The build design settles the wording of each rule in its home file.

### Sources

- `unattended-rounds/research/2026-11-11-evidence.md`: the timeline figures, the denial log, the miss counts, the probes, and the Anthropic pages.
- `claude/.claude/skills/pass-core/SKILL.md` and its `references/` in the workstation repo, read at `main` on 2026-11-11.
- The `workstation-refinement` record on its local branch, for the freeze and its measure read.
- The approval-queue repo at commit `0bd4828`: its `README.md`, `bin/.local/bin/approval-queue`, and `approval-queue/src/lib/facts.ts`.
- Anthropic's cost page, <https://code.claude.com/docs/en/costs>, for how usage credits are turned on, capped, and read.
- `plugins/standards/skills/brainstorming/SKILL.md` in the standards repo at commit `304038c`.
