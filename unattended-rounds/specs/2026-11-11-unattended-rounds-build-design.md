# Unattended rounds: the build

Initiative: unattended-rounds

## Brief

Approving this starts three rounds that build the round into your tools: the Approval Queue first, then the workstation's skills and checks, then the brainstorming skill. Ten passes run back to back, and nine of them merge themselves.

You approved the round as the unit of work on 2026-11-11. That approval built nothing. This design names every file the build changes, gives each pass a list of what you would see when it is done, and shows each queue page that changes. The fix for the approve button that refused you is the first pass.

### What changes

- The queue's approve check reads a design from the path its packet recorded. Today it reads from wherever the running server was told to look, which is why your approve was refused.
- A packet, a landed PR, and a digest line carry a round id, and the queue's pages group by round.
- A round's report is an item on the queue's pages, with one button, "Mark read".
- A stop packet's button reads "Answer and resume". Answering merges nothing, and `merge` refuses a stop packet.
- `merge`, `land`, and `packet` refuse a PR whose base isn't the repo's default branch.
- `pass-core` says every design is a round design of one to six passes. The round rules you approved go into a new `references/round.md`.
- A plan must show its evidence before it launches: a mechanism table, recorded searches, and a read of the auto-mode refusals.
- The busy check stops reading a finished session, the Claude daemon, and the queue's server as a running pass.
- The brainstorming skill states what done looks like, reads before it asks, and stops promising two or three approaches.
- No setting, hook registration, permission rule, or auto-mode entry changes.

### If you approve

1. The session writes the conductor and planner prompts into this record and launches the queue round, `ur-queue`.
2. Each queue pass that finishes merges itself, and the conductor rebuilds and restarts the queue's app.
3. When all four queue passes have merged, the workstation round, `ur-ws`, starts. Four of its passes merge themselves.
4. Its fifth pass changes the launch guard and the pass section of `CLAUDE.md`. That PR waits for you in a close packet.
5. When the first four workstation passes have merged, the standards round, `ur-std`, starts: one pass on the brainstorming skill, which merges itself.
6. You return to a round report for each round, the one close packet, and a stop packet for any pass that parked.

### Decide: What a one-pass round takes from the design rules

The design you approved left this to the build. A round of two or more passes follows four design rules: an acceptance list for each pass, the shared assumptions with their proof, one fresh reader, and evidence for each acceptance item in the PR. Most of your designs will stay one pass. An acceptance list adds a few lines to the sitting, and it gives the closing review something to check the diff against. The shared assumptions have no meaning for one pass. The fresh reader is the costly rule, and a one-pass design gets its read today only when its class calls for one.

Source: `unattended-rounds/specs/2026-11-11-unattended-rounds-design.md:65-74` and `:219`

- The acceptance list and its evidence in the PR (recommended)
- All four rules, with the fresh reader on every design
- None of them: a one-pass round runs exactly as a pass does today

### Worth knowing

The week stood at 60 percent used on 2026-11-11, with the Fable meter at 0, and it resets on 2026-11-13 at 11pm Anchorage time. `/usage` showed no usage-credits row at that read. Until it shows one, the rounds stop launching at 85 percent and wait for the reset.

The three rounds plan about 880 path minutes. At the usual ratio of actual to planned that is 320 to 350 minutes of work, and about 740 at the ninth decile. CI, reviews, and waits come on top.

The queue's app restarts four times during the first round. A page you have open stays up and reloads on your next click. A packet waiting for your decision survives a restart: the approved design's packet waited through one on 2026-11-11.

Both trials you approved run in all three rounds. Planner prompts name Fable 5.2 at `high`, and each conductor and executor prompt opens with a `/goal` line.

### The three rounds

Each round is one repo, and its passes run one at a time. Every pass in a round shares a file with the pass before it, so each starts from the one before, once that one's review is accepted.

| Round | Repo | Passes | Planned path minutes | Starts when |
| --- | --- | --- | --- | --- |
| `ur-queue` | approval-queue | 4 | 390 | You approve this design. |
| `ur-ws` | workstation | 5 | 430 | Every `ur-queue` pass has merged. |
| `ur-std` | standards | 1 | 60 | The first four `ur-ws` passes have merged. |

A round whose predecessor holds a parked pass doesn't start. Its report says so, and it starts when you answer the stop and the pass merges.

### Round `ur-queue`: the Approval Queue

**Pass Q1. Approve reads the design where the packet found it.** 60 minutes, class `runner`.

The `packet` command records the design's full path in the item's `design.json`, and the approve check reads that path. A new `approval-queue restart` command rebuilds the app and restarts its server.

- A design packet queued with `APPROVAL_QUEUE_PROJECTS` set to another tree is approved by a server started without that variable.
- Editing the design after queuing still gets "Out of date: the design changed since this packet was queued".
- Removing the design file gets "Could not read the design at `<path>`; nothing was recorded", and no decision is written.
- An item queued before this change has no recorded path and is checked as it is today.
- `approval-queue restart` exits 0 with the new build serving the same state directory. When the build fails it exits 1 and the old server keeps answering.
- A packet command that was waiting before a restart prints its decision after it.

Files: `bin/.local/bin/approval-queue`, `approval-queue/src/lib/server/heads.ts`, `approval-queue/src/lib/server/items.ts`, their tests, `tests/lifecycle.test.sh`, `README.md`.

**Pass Q2. A stop packet is answered, and a PR merges into the default branch.** 90 minutes, class `runner`. Depends on Q1.

- `approval-queue merge <id>` on an approved stop packet exits 2, says a stop packet is answered and never merged, and runs no `gh pr merge`.
- `merge` on a close packet holding a PR based on another branch exits 2 before it merges anything, and names the PR, its base, and the default branch.
- `land` refuses the same PR the same way.
- `packet --check` refuses a fact file that names such a PR.
- The stop page reads as the mockup below. A close page and a design page read as they do today.

Files: `bin/.local/bin/approval-queue`, `approval-queue/src/lib/packet-view.ts`, `approval-queue/src/lib/components/PacketPage.svelte`, their tests, `tests/merge.test.sh`, `tests/packet.test.sh`, `README.md`.

```text
ur-queue · Pass paused · glw907/approval-queue#52

Pass parked until you answer.

  1. Should a report replace the one already waiting?        [your choices]

  [ Answer and resume ]   [ Send back ]

  Answering merges nothing. The session runs the steps below,
  then relaunches the pass.
```

**Pass Q3. The round on packets, landings, and pages.** 120 minutes, class `runner`. Depends on Q2.

- A fact file with `"round": "ur-queue"` passes the check. An id over 12 characters, or one that isn't lowercase letters, digits, and hyphens starting with a letter, is refused with the rule named.
- The queued item's `item.json` holds the round.
- `approval-queue land --round ur-queue <owner/repo#n> <claim>` appends a digest line that holds the round.
- The board shows a round's waiting items under one round heading, inside their initiative's group. An item with no round sits where it does today.
- The digest page groups a round's lines under its id. A line with no round shows as it does today.
- Every item and digest line written before this change still loads.

Files: `bin/.local/bin/approval-queue`, `approval-queue/src/lib/facts.ts`, `approval-queue/src/lib/server/items.ts`, `approval-queue/src/lib/server/digest.ts`, `approval-queue/src/lib/board.ts`, `approval-queue/src/lib/packet-view.ts`, `approval-queue/src/routes/+page.server.ts`, the board, digest, and history pages, the fixtures under `approval-queue/src/lib/fixtures/`, their tests, `README.md`.

```text
Waiting

Unattended rounds
  Round ur-queue · approval-queue
    Round report     3 of 4 passes merged, 1 parked
    Pass paused      The round report as an item
  Round ur-ws · workstation
    Pass finished    The launch guard and the pass section of CLAUDE.md

Singles
    Design           A calmer sign-in page for cairn
```

```text
Digest

approval-queue
  Round ur-queue
    #51  Approve reads the design where the packet found it
    #52  A stop packet is answered, and a PR merges into the default branch
  No round
    #49  The withdraw message for a decided item
```

**Pass Q4. The round report as an item.** 120 minutes, class `runner`. Depends on Q3.

- `approval-queue report <initiative> <round> <report.md>` prints an item id and exits 0 without waiting.
- The board shows the report as the first row of its round, labelled "Round report".
- Opening it shows the report's Markdown with its tables, and beneath it the round's waiting packets and landed PRs as links.
- "Mark read" moves it to history. Nothing merges, and no line is written to `decisions.jsonl`.
- A second `report` for a round whose report still waits replaces that report. The board keeps one row.
- `approval-queue merge <id>` on a report exits 2.
- `docs/STATUS.md` adds the rebuild to the steps thinkpad-x1 runs before its first hand-over.

Files: `bin/.local/bin/approval-queue`, `approval-queue/src/lib/server/items.ts`, `approval-queue/src/lib/board.ts`, a new report page under `approval-queue/src/routes/`, their tests, `tests/approval-queue.test.sh`, `README.md`, `docs/STATUS.md`.

```text
Round ur-queue · approval-queue · written 2026-11-12 06:14

| Pass | State   | PR  | Planned | Actual | Usage before | Usage after |
| Q1   | merged  | #51 | 60      | 31     | 60%          | 62%         |
| Q2   | merged  | #52 | 90      | 44     | 62%          | 65%         |
| Q3   | merged  | #53 | 120     | 70     | 65%          | 69%         |
| Q4   | parked  | #54 | 120     | 38     | 69%          | 71%         |

Stops 1 · Refusals 0 · Calls sent to you 1
Planning misses 2: mechanism 1, file-list 1
Trials: Fable 5.2 planned 4 passes · /goal held 8 sessions, cleared early 0

Waiting for you: Pass paused, the round report as an item
Landed: #51 #52 #53

[ Mark read ]
```

The figures in the mockups are made up. Each page keeps the look it has today.

### Round `ur-ws`: the workstation

**Pass W1. The busy check reads only a running pass.** 45 minutes, class `runner`.

- A session row whose `state` is `done` is not a hit.
- A `claude daemon run` process and the queue's server (`node <path>/approval-queue/build`) are not hits.
- A running `--bg` session in the path, another process with the path in its command line, and an uncommitted file edited in the last hour are hits, as today.
- `claude-worktree-busy ~/Projects/approval-queue` exits 0 with the queue's server up and no pass running.

Files: `bin/.local/bin/claude-worktree-busy`, `tests/claude-worktree-busy.test.sh`.

**Pass W2. The pass report counts planning misses by class.** 60 minutes, class `ordinary`. Depends on W1.

- A miss line in a PR's `## Planning misses` section opens with one of ten tags: `[mechanism]`, `[file-list]`, `[permission]`, `[design-gap]`, `[stale-fact]`, `[owner-call]`, `[no-answer]`, `[conflict]`, `[estimate]`, `[ambiguous]`.
- `pass-report` prints a table of misses by class for its window, and counts a line with no tag as `untagged`.
- A PR with no such section adds nothing, and the report's other tables don't change.

Files: `bin/.local/bin/pass-report`, its test under `tests/`.

**Pass W3. The round rules in `pass-core`.** 150 minutes, class `runner`. Depends on W2.

- `pass-core/SKILL.md` "Lifecycle" says a design is a round design of one to six passes in one repo, and points to `references/round.md`. "Conductor" says a round of two or more passes has one.
- `references/round.md` holds what a round design adds, the twelve standing answers, the conductor's order table and queue rules, and the report's fields, as the approved design lists them. It uses the queue's `round` field, `land --round`, and `report` in place of the title prefix.
- `references/planner.md` holds the four planner rules and, under "Design", the design rules, with your answer on a one-pass round.
- `references/conductor.md` sends a stop as a `stop` packet and launches the next pass that doesn't depend on the parked one. Today it asks and waits.
- `references/executor.md` holds the `Round:` line, the default branch as the PR's base, the stop procedure, the evidence for each acceptance item, and the class tag on each planning miss.
- The four capped files stay inside their caps: 1,500, 940, 560, and 900 words. `references/round.md` gets a cap of 1,500 in `claude-context-budget`, and the gate's `skill-caps` leg passes.
- "Clock stop" leaves `SKILL.md`, since `standards:running-passes` "Clock" holds the same rule. One of the two copies of the polish-loop sentence goes.
- "Round" alone means the unit. "A backlog round" becomes "a backlog pass", and "a polish loop's rounds" becomes "a polish loop's iterations". The score line keeps "Fix rounds".

Files: `claude/.claude/skills/pass-core/SKILL.md`, `references/round.md` (new), `references/planner.md`, `references/conductor.md`, `references/executor.md`, `references/planning-samples.md`, `bin/.local/bin/claude-context-budget`, its test.

**Pass W4. The packet skill, the adapters, and the guards doc.** 100 minutes, class `runner`. Depends on W3.

- The `approval-packet` skill lists `round` among the fact keys and names the `report` command. Its step 8 gains a stop case: an approved stop packet runs its listed steps and resumes the pass, and never `merge`.
- The packet writer's brief says what approving a stop packet does. The contract beneath it lists the `round` key.
- `cairn-pass` "Packet" matches your ruling D1: a pass with no call, no `auth-data` path, and no `## Before merge` step lands in any class. Today it says a `runner` pass always sends a packet.
- `unattended-work-guards.md` gains a usage section: the read before each launch, the 85 percent ceiling, an unreadable figure counted as over it, and the wait for the reset. Its `/goal` section points the December review at the trial lines in the round reports.
- The end-to-end check passes. A fresh Sonnet subagent gets the path of the changed `pass-core` and workstation backlog items #63, #69, and #70, and writes a round design outline. The outline holds the order table, the round id, an acceptance list for each pass, the shared assumptions, a mechanism table, recorded searches, the denial-log read, a standing answer for each stop, the merge order, and the default branch as each PR's base.

Files: `claude/.claude/skills/approval-packet/SKILL.md`, `claude/.claude/skills/survey/writing/approval-brief.md`, `claude/.claude/skills/cairn-pass/SKILL.md`, `claude/.claude/docs/unattended-work-guards.md`.

**Pass W5. The launch guard and the pass section of `CLAUDE.md`.** 75 minutes, class `runner`. Depends on W4. Its PR waits for you in a close packet.

- The launch guard finds a plan kept in an initiative record: `<slug>-plan.md` beside `<slug>-prompt.txt`. This closes backlog #72.
- A plan's `## Pre-flight` section needs a third line, `Evidence:`, naming its mechanism table and its recorded searches. A launch without it is denied with a message that names the line.
- A planner launch and a launch with no plan go through, as today.
- The pass section of `CLAUDE.md` names your touchpoints as the round design, its pre-flight sitting, a close packet where a call remains, a stop packet for a parked pass, and the round report. The file stays at 120 lines.
- `dotfiles-pass` lists `claude-launch-guard` under `runner`.

Files: `bin/.local/bin/claude-launch-guard`, `tests/test_claude_launch_guard.py`, `claude/.claude/CLAUDE.md`, `.claude/skills/dotfiles-pass/SKILL.md`, `BACKLOG.md`.

### Round `ur-std`: the brainstorming skill

**Pass S1. Three changes to `standards:brainstorming`.** 60 minutes, class `runner`. One pass, so no conductor.

- The description on line 3 says what the body does. It no longer promises two or three approaches.
- "Offer recon" becomes a rule to go and look: the skill reads the code, your files, and the web without asking, and says what it read. It still asks before a spike.
- The written design's list gains what done looks like: what you would see or run, each item able to fail.
- The builder check's prompt asks whether any of those items could pass on a wrong result.
- A fresh Sonnet subagent, given the changed skill and a one-line request in the standards repo, reads the repo before its first question and never asks whether it may look.
- The repo's CI passes: the plugin check, the path scan, and the 500-line cap.

Files: `plugins/standards/skills/brainstorming/SKILL.md`, `plugins/standards/skills/brainstorming/builder-check-prompt.md`.

### What the passes share

Each row is an assumption that more than one pass rests on.

| Assumption | Proof |
| --- | --- |
| A waiting packet survives a restart of the queue's server. | This session restarted the server on 2026-11-11 while packet `20261111T161236-2074074` waited, and the command printed your approve afterwards. |
| The queue's command changes for every session as soon as its checkout is pulled. | `~/.local/bin/approval-queue` is a link into `~/Projects/approval-queue`. The repo's `README.md` says the command "must be a link to this checkout, not a copy". |
| The app can show a Markdown file. | `marked` 18.1 is a dependency (`approval-queue/package.json:33`), and a design packet shows `design.md` today. |
| `gh` can name a repo's default branch. | `gh repo view` printed `main` for all three repos on 2026-11-11. |
| A session row says when it is finished. | `claude agents --json` printed rows with a `state` of `busy` or `done` on 2026-11-11. |
| A new file under `pass-core/references/` reaches every session with the pull. | `~/.claude/skills/pass-core` is a link to the directory in the main checkout. |
| A changed standards skill reaches the workstation. | `claude-tooling.md:21` says the plugin "auto-updates from `main`". Not probed. |
| A session can edit a skill in a workstation worktree. | Your auto-mode entry allows it for a task of a plan you approved. It names `CLAUDE.md` and hooks as not covered, which is why W5 comes to you. |

Q1 runs first because every later design packet rests on the approve check. No other order was open: each pass shares a file with the one before it.

### Standing answers for the build

The twelve standing answers you approved hold in all three rounds. The build adds five.

1. A queue pass lands. The conductor pulls the main checkout and runs `approval-queue restart`. The first restart, after Q1, is the first use of that command.
2. A restart fails. The old server keeps answering. The conductor starts no new pass, and the report says so.
3. A workstation pass lands. The conductor pulls `~/.dotfiles`, which puts the change live. A session already running keeps the rules in its prompt until its round ends.
4. Auto mode refuses the edit of the launch guard or of `CLAUDE.md` in W5. The executor puts the change in the PR body as a patch, and the pass parks.
5. The plugin cache still holds the old brainstorming skill after S1 merges. The report names the commit the cache holds, and nothing else waits on it.

### Pre-flight

One step is yours, and the work starts without it.

`[you: turn usage credits on and set a monthly spend limit]` This is the step from the design you approved. `/usage` showed no usage-credits row at the last read, so the rounds stop launching at 85 percent of the week until it does.

The session checks the sign-in before the first launch with `claude -p "say ok" --model haiku`.

Permissions checked: the passes run `git`, `gh pr create`, `npm`, `pytest`, the repos' gates, `claude --bg`, `claude stop`, `claude -p "/usage"`, and `approval-queue` with `packet`, `land`, `report`, and `restart`. The denial log's 57 rows from 2026-11-01 to 2026-11-11 were read against them. No pass edits `settings.json` or runs `stow` (10 rows, "Self-Modification"): W3's new file arrives through a directory link, and no pass adds a script. No pass runs `pkill` (9 rows, "Interfere With Workloads"): the queue's server restarts through `approval-queue restart`, which the allow rule `Bash(approval-queue *)` covers. Every merge goes through `approval-queue land` or your approved packet (3 rows, "Merge Without Review"). Whether auto mode lets a conductor stop an executor it launched rests on four stops by this session and one earlier refusal, as the approved design says.

Reviewed: one fresh Opus reader ran the `standards:brainstorming` builder check on this design before it reached you.

### Backlog sweep

The sweep read 38 open workstation items at commit `64063f0`, 3 open approval-queue items at `0bd4828`, and the one standards item filed on 2026-11-11, against the files above.

| Item | Verdict | What the build does |
| --- | --- | --- |
| workstation #72, the launch guard finds plans only under `docs/plans/` | fold | W5 fixes and closes it. |
| workstation #74, an eval for the brainstorming skill | keep | Nothing. S1 changes the skill, and the eval stays filed. |
| workstation #50, a queue decision reaching the auto-mode classifier | keep | Nothing. |
| workstation #63, #69, #70 | keep | W4 reads them as sample items and changes none. |
| workstation #73, #71, #68, #38, #23, #1, #8, #10, #11, #14, #29 | keep | Nothing. None names a file above. |
| approval-queue #49, #41, #38 | keep | Nothing. None touches a stop packet, a base branch, a round, or a report. |

### Out of scope

- Every setting, hook registration, permission rule, auto-mode entry, and secret guard. The build changes none.
- An auto-mode entry for a conductor stopping its executors. If the rounds meet a refusal there, the report says so and a later design proposes the entry.
- A stop packet with no pull request. The standing answers have the pass push and open a draft first.
- A standing model or effort change. `pass-core` keeps Opus for design, and the trials report to the December review.
- `standards:running-passes`, the `site-pass` adapter, and every repo other than the three above.
- An eval for the brainstorming skill.
- The thinkpad's cutover, beyond the line Q4 adds to the queue's STATUS.

## Technical notes

### Prompts and where they live

The session writes one conductor prompt for `ur-queue`, one for `ur-ws`, and a planner prompt for each of the ten passes, under `unattended-rounds/plans/` in this record. Each planner prompt's name ends `-planning-prompt.txt`, which the launch guard passes as a planner launch. Sessions read them by full path, since the record is local and unpushed.

Each planner writes its plan and executor prompt under the pass's repo, in `docs/plans/`, where the launch guard reads them until W5 lands. All three repos are public. A plan or PR body cites the round id and this design's pass name, and copies nothing from the `workstation-refinement` record.

The `ur-queue` conductor's last step launches the `ur-ws` conductor when all four queue passes have merged and `claude-worktree-busy ~/.dotfiles` exits 0. The `ur-ws` conductor launches the S1 planner the same way once W4 has merged. S1 has no conductor, so its executor lands its PR and sends the report itself.

### Models

Conductors and executors run Sonnet at `medium`. Planners run Fable 5.2 at `high`, the first trial. Each plan gets one `standards:plan-reviewer` read. Each conductor and executor prompt opens with a `/goal` line whose condition names every end: PR ready, parked with a stop in STATUS, or usage at the ceiling. That is the second trial.

### How each mechanism fails

The approved design's table holds for the build. These rows are new.

| Mechanism | Evidence | How it fails | What happens |
| --- | --- | --- | --- |
| `approval-queue restart` replaces the server | The README's cutover does it by hand with `npm run build` and `pkill` | The build fails, or auto mode refuses the command | Build standing answer 2. |
| The old server reads an item the new command wrote | Not probed | The old build refuses an unknown fact key such as `round` | The conductor restarts after every landed queue pass, before the next packet is queued. |
| A pass edits a skill that running sessions loaded | Skills load when a session starts | A later session reads a rule that differs from its prompt | The prompt wins until the round ends. W3's text and the prompts hold the same rules. |
| The launch guard's new line | `REQUIRED` at `bin/.local/bin/claude-launch-guard:34` | A plan written before W5 merged lacks the line | The launch is denied with a message naming the line, and the planner adds it. |
| The report item | `KINDS` in `approval-queue/src/lib/server/items.ts` holds three kinds | A reader of items meets a kind it doesn't know | Q4's tests load a state directory holding all four kinds through every page and through `pending`. |
| The base-branch check | `merge` reads `state,headRefOid,body` (`bin/.local/bin/approval-queue:283-338`) | `gh` can't name the default branch | The command exits 1 and merges nothing. |
| `pass-report` reads the tags | It reads merged PRs through `gh` | A PR written before W3 has no tags | The line counts as `untagged`. |

### Claude's calls

- The queue's code that checks an approve and runs a merge lands itself with the rest of `ur-queue`. Each change there adds a refusal and removes none.
- W5 waits for you. The approved design keeps a hook change out of an executor's hands, and your auto-mode entry names `CLAUDE.md` as not covered. The pass builds and tests the change, and your approve merges it.
- The build changes no setting. A conductor stopping its executors stays on the evidence it has.
- `approval-queue restart` is new. Four restarts in one round by hand would each run `pkill`, the command class auto mode refused nine times.
- `packet` refuses a wrong base as well as `merge` and `land`, so you never approve a packet that can't merge.
- A round id is lowercase letters, digits, and hyphens, starting with a letter, 12 characters at most.
- The report is an item kind of its own with one action, and writes no decision line.
- A second report for a waiting round replaces the first.
- The round rules go in one new reference file with a cap of 1,500 words. The caps on the four existing files hold.
- The miss classes are ten short tags, counted by `pass-report`.
- The launch guard's third line is `Evidence:`. The guard checks that the line is there, and the plan reviewer checks what it claims.
- The busy-check pass runs first in `ur-ws`, since the conductor leans on it before every launch.
- The sample items for the end-to-end check are workstation #63, #69, and #70: a wrapper for two adapters, a session-start change, and a fix on an `auth-data` path.
- `site-pass` and `dotfiles-pass` hold no line naming what you approve, so only `cairn-pass` changes there.
- The overhaul's packets keep the round id at the head of their titles through all three rounds.

### Left to the builder

Each rule's wording in its home file, which sentences move to `references/round.md` to hold the caps, the report page's route, and each page's markup.

### Sources

- `unattended-rounds/specs/2026-11-11-unattended-rounds-design.md`, approved in packet `20261111T161236-2074074`.
- `unattended-rounds/research/2026-11-11-evidence.md`: the denial log at `:26`, the miss classes at `:43`, the probes at `:65`, the queue in a round at `:93`, and the approve refusal at `:299`.
- The approval-queue repo at commit `0bd4828`: `README.md`, `bin/.local/bin/approval-queue`, `approval-queue/src/lib/facts.ts`, and `approval-queue/src/lib/server/heads.ts:52-60`.
- The workstation repo at commit `64063f0`: `pass-core` and its references, `bin/.local/bin/claude-launch-guard`, `bin/.local/bin/claude-worktree-busy`, `bin/.local/bin/claude-context-budget:28-33`, `.claude/skills/dotfiles-pass/SKILL.md`, and `claude/.claude/settings.json:61`.
- The standards repo at commit `896f819`: `plugins/standards/skills/brainstorming/SKILL.md`.
