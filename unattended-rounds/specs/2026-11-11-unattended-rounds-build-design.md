# Unattended rounds: the build

Initiative: unattended-rounds

## Brief

Approving this starts three rounds that build the round into your tools: one on the Approval Queue, one on the workstation's skills and checks, and one on the brainstorming skill. Ten passes run. Three decisions are yours, and with the recommended answers nine passes merge themselves.

You approved the round as the unit of work on 2026-11-11. That approval built nothing. This design names every file the build changes, gives each pass a list of what you would see when it is done, and shows each queue page that changes. The fix for the approve button that refused you is the first pass.

### What changes

- The queue's approve check reads a design from the path its packet recorded. Today it reads from wherever the running server was told to look, which is why your approve was refused.
- A packet, a landed PR, and a digest line carry a round id, and the queue's pages group by round.
- A round's report is an item on the queue's pages, with one button, "Mark read".
- A stop packet's button reads "Answer and resume". Answering merges nothing, and `merge` refuses a stop packet.
- `merge`, `land`, and `packet` refuse a PR whose base isn't the repo's default branch.
- `pass-core` says every design is a round design of one to six passes. The round rules you approved go into two new reference files.
- A plan must show its evidence before it launches: a mechanism table, recorded searches, and a read of the auto-mode refusals.
- The busy check stops reading a finished session, the Claude daemon, and the queue's server as a running pass.
- The brainstorming skill states what done looks like, reads before it asks, and stops promising two or three approaches.
- No setting, hook registration, permission rule, or auto-mode entry changes.

### If you approve

1. The session launches all three rounds at once, from prompts it wrote into this record while the packet waited.
2. `ur-queue` runs its four passes in order. Each merges itself, and the conductor rebuilds and restarts the queue's app.
3. `ur-ws` runs its first two passes while the queue round runs. Its next two write the round rules, and they wait until every queue pass has merged.
4. The last workstation pass changes the launch guard and the pass section of `CLAUDE.md`. With the recommended answer, that PR waits for you in a close packet.
5. `ur-std` runs its one pass on the brainstorming skill, which merges itself.
6. The rounds run until they finish or the weekly limit halts them. If the limit comes first, you apply your weekly reset and tell a session to resume the overhaul.
7. You return to a round report for each round, the one close packet, and a stop packet for any pass that parked.

### Decide: What a one-pass round takes from the design rules

The design you approved left this to the build. A round of two or more passes follows four design rules: an acceptance list for each pass, the shared assumptions with their proof, one fresh reader, and evidence for each acceptance item in the PR. Most of your designs will stay one pass. An acceptance list adds a few lines to the sitting, and it gives the closing review something to check the diff against. The shared assumptions have no meaning for one pass. The fresh reader is the costly rule, and a one-pass design gets its read today only when its class calls for one.

Source: `unattended-rounds/specs/2026-11-11-unattended-rounds-design.md:65-74` and `:219`

- The acceptance list and its evidence in the PR (recommended)
- All four rules, with the fresh reader on every design
- None of them: a one-pass round runs exactly as a pass does today

### Decide: Who writes the launch guard change in W3

Standing answer 3 of the design you approved says a hook change is never an executor task: the planner writes it as a command for you. Pass W3 changes the launch guard, which is a hook script, and the pass section of `CLAUDE.md`. Both of your auto-mode entries for edits in a worktree say they do not cover hooks.

The recommended answer departs from standing answer 3 for this one pass. An executor writes and tests the change in a worktree, and its PR waits for your approve. Nothing reaches the live guard before that, because `~/.local/bin` links into the main checkout. Auto mode may refuse the edit all the same, and no entry is added to clear it. The pass then parks with the change as a patch in its PR body, which is where the second answer starts.

Source: `unattended-rounds/specs/2026-11-11-unattended-rounds-design.md:140`, `claude/.claude/settings.json:422-424`, and `.claude/skills/dotfiles-pass/SKILL.md:13`

- An executor writes and tests it in a worktree, and the PR waits for your approve (recommended)
- No session edits either file: the change comes to you as a patch with the commands to apply it
- Leave the launch guard and `CLAUDE.md` as they are

### Decide: Whether the queue's approve and merge code merges itself

Q1 changes where the approve check reads a design. Q2 adds refusals to `merge`, `land`, and `packet`. This is the code that carries your approval. Your ruling D1 lets a pass with no call, no `auth-data` path, and no `## Before merge` step land itself in every class. The queue's repo has no class map, so `runner` is Claude's reading of these passes.

Each queue pass waits for the one before it, and W4, W5, and W3 run after the last. If Q1 waits for you, seven of the ten passes wait with it. Before a queue pass lands, a Fable 5.2 reader reads its whole branch and the repo's gate runs the approve and merge tests. The round report links every landed PR, and one revert undoes a pass.

Source: `claude/.claude/skills/pass-core/SKILL.md:128-129` and the table "What each pass waits for" below

- All four queue passes land themselves after the whole-branch review (recommended)
- Q1 and Q2 each wait for your approve, and Q3, Q4, W4, W5, and W3 wait behind them

### What you said after the last packet

Four things you said in chat on 2026-11-11 change what you approved. Each is written in as decided, and your approve confirms it.

Your resets replace usage credits. You said you have a weekly reset and two Fable resets, "so there is no need for usage credit." The step that asked you to turn credits on is gone, and the overhaul spends nothing past the Max plan.

The overhaul spends the week before you reset it. You said you'd "like to get it as close to 100% as possible before I use the reset." The overhaul's rounds have no 85 percent stop. They launch until the weekly limit halts them. The 85 percent rule you approved for later rounds is unchanged.

The three rounds start together. You said you want the allowance spent quickly, since the week resets on Friday evening. The design you approved started each round when the one before it had merged. Three repos share no file, so the rounds run at once. The workstation's last three passes wait for the queue: two write rules for its new commands, and the launch guard pass runs last.

Fable 5.2 runs where a miss would cost most. You said quality is critical because the method touches all later work, and to use Fable "liberally where it will make a real difference." It plans every pass, executes the three passes that write rules text, and reads every pass's whole branch before it merges. The design you approved put it on planning alone.

Source: `unattended-rounds/research/2026-11-11-evidence.md:328-372`

### Worth knowing

The week stood at 63 percent used on 2026-11-11, with the Fable meter at 6, and it resets on 2026-11-13 at 11pm Anchorage time. What one pass spends has never been measured. The design you approved had the first round measure it, with passes one at a time. With three rounds at once, a pass's before and after figures include what the other rounds spent. The reports give the spend of the ten passes together, and a later round run alone measures one pass.

A weekly limit halts every session on the account at once, the conductors included. Nothing can write a report after that. Each conductor refreshes its round report before every launch, so the report you find is at most one pass old.

Whether a halted session picks itself up after a reset has never been tested, and the `/goal` page says a goal resumes at the reset. The resume rests on neither. It stops every overhaul session, commits what each left, and relaunches from the reports. A pass commits after each task, so a halt costs one task at most.

The three rounds plan about 880 minutes of work, and the longest chain is 715. At the usual ratio of actual to planned that chain is 260 to 285 minutes, and about 600 at the ninth decile. CI, reviews, and waits come on top.

The queue's app restarts four times during the queue round. A page you have open stays up and reloads on your next click. A packet waiting for your decision survives a restart: the approved design's packet waited through one on 2026-11-11.

Both trials you approved run in all three rounds: Fable 5.2 on planning, and a `/goal` line at the head of each conductor and executor prompt.

### The three rounds

Each round is one repo, and its passes run one at a time.

| Round | Repo | Passes | Planned minutes | Starts |
| --- | --- | --- | --- | --- |
| `ur-queue` | approval-queue | Q1 to Q4 | 390 | When you approve. |
| `ur-ws` | workstation | W1 to W5 | 430 | When you approve. W4, W5, and W3 run after every queue pass has merged. |
| `ur-std` | standards | S1 | 60 | When you approve. |

What each pass waits for:

| Pass | Waits for | Why |
| --- | --- | --- |
| Q2, Q3, Q4 | The queue pass before it | Each changes `bin/.local/bin/approval-queue` and `README.md`. |
| W1, W2 | Nothing outside their round | Each changes one script and its tests. |
| W4 | Q3 and Q4 merged | Its rules name the queue's `round` field and its `land --round` and `report` commands. |
| W5 | W4 merged | Its skills cite the files W4 writes, and its closing check reads them. |
| W3 | W5 merged | Its PR waits for your approve. Running last, it holds no pass behind it, and the guard's new line lands after `planner.md` names it. |
| S1 | Nothing | It shares no file with any other pass. |

A parked pass never holds another repo's round, except that a parked queue pass holds W4, W5, and W3. Inside one repo it does hold the passes after it. Every pass there edits `docs/STATUS.md`, and the design you approved counts a shared file as a dependency: the next pass starts from the parked pass's branch and merges behind it.

### Round `ur-queue`: the Approval Queue

**Pass Q1. Approve reads the design where the packet found it.** 60 minutes, class `runner`.

The `packet` command records the design's full path in the item's `design.json`, and the approve check reads that path. A new `approval-queue restart` command rebuilds the app and restarts its server.

- A design packet queued with `APPROVAL_QUEUE_PROJECTS` set to another tree is approved by a server started without that variable.
- Editing the design after queuing still gets "Out of date: the design changed since this packet was queued".
- Removing the design file gets "Could not read the design at `<path>`; nothing was recorded", and no decision is written.
- An item queued before this change has no recorded path. It approves when the design under the server's projects tree matches the queued hash, and gets the "Out of date" refusal when it doesn't.
- `approval-queue restart` builds beside the running build and swaps the new one in under `start.lock`. The old server serves every page until the swap.
- `restart` exits 0 with a new server process, under a different process id, serving an item page from the same state directory. When the build fails it exits 1, and the old process still serves an item page.
- The new server's command line still begins `node <path>/approval-queue/build`, which W1's busy check matches.
- A packet command that was waiting before a restart prints its decision after it.

Files: `bin/.local/bin/approval-queue` (`queue_packet`, the stale poll near line 824, the new command), `approval-queue/src/lib/server/heads.ts`, `approval-queue/src/lib/server/items.ts`, `approval-queue/src/lib/server/seed-facts.ts`, `approval-queue/src/routes/item/[id=id]/+page.server.ts`, `approval-queue/src/routes/item/[id=id]/facts.server.test.ts`, `tests/packet.test.sh` (line 468 asserts the old shape of `design.json`), `tests/lifecycle.test.sh`, `README.md`.

**Pass Q2. A stop packet is answered, and a PR merges into the default branch.** 90 minutes, class `runner`. Waits for Q1.

- `approval-queue merge <id>` on an approved stop packet exits 2, says a stop packet is answered and never merged, and runs no `gh pr merge`.
- `merge` on a close packet holding a PR based on another branch exits 2 before it merges anything, and names the PR, its base, and the default branch.
- `land` refuses the same PR the same way.
- `packet --check` refuses a fact file that names such a PR.
- The stop fixture's page shows "Pass parked until you answer." and a button labelled "Answer and resume", as in the mockup below. The close and design fixtures' pages still show "Approve".

Files: `bin/.local/bin/approval-queue`, `approval-queue/src/check-brief.ts`, `approval-queue/src/lib/packet-view.ts`, `approval-queue/src/lib/components/PacketPage.svelte`, their tests, `tests/merge.test.sh` and `tests/packet.test.sh` with their `gh` stubs, the `gh` fixtures under `tests/fixtures/ct/`, `README.md`.

```text
ur-queue · Pass paused · glw907/approval-queue#52

Pass parked until you answer.

  1. Should a report replace the one already waiting?        [your choices]

  [ Answer and resume ]   [ Send back ]

  Answering merges nothing. The session runs the steps below,
  then relaunches the pass.
```

**Pass Q3. The round on packets, landings, and pages.** 120 minutes, class `runner`. Waits for Q2.

- A fact file with `"round": "ur-queue"` passes the check. An id over 12 characters, or one that isn't lowercase letters, digits, and hyphens starting with a letter, is refused with the rule named.
- The queued item's `item.json` holds the round.
- `approval-queue land --round ur-queue <owner/repo#n> <claim>` appends a digest line that holds the round.
- The board and the sidebar show a round's waiting items under one round heading, inside their initiative's group. An item with no round sits where it does today.
- The digest page groups a round's lines under its id. A line with no round shows as it does today.
- Every item and digest line written before this change still loads, on the board, the digest page, and the history page.

Files: `bin/.local/bin/approval-queue`, `approval-queue/src/lib/facts.ts`, `approval-queue/src/lib/server/items.ts`, `approval-queue/src/lib/server/digest.ts`, `approval-queue/src/lib/server/history.ts`, `approval-queue/src/lib/board.ts`, `approval-queue/src/lib/packet-view.ts`, `approval-queue/src/routes/+page.server.ts`, `approval-queue/src/routes/+layout.server.ts`, `approval-queue/src/routes/+layout.svelte`, the board, digest, and history pages, the fixtures under `approval-queue/src/lib/fixtures/`, their tests, `README.md`.

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

**Pass Q4. The round report as an item.** 120 minutes, class `runner`. Waits for Q3.

- `approval-queue report <initiative> <round> <report.md>` prints an item id and exits 0 without waiting. The item records no process id, so the board never shows it as abandoned.
- The board shows the report as the first row of its round, labelled "Round report".
- Opening it shows the report's Markdown with its tables, and beneath it the round's waiting packets and landed PRs as links.
- "Mark read" moves it to history. It writes the item's `decision.json` and no line in `decisions.jsonl`, and nothing merges.
- A second `report` for a round whose report still waits replaces that report. The board keeps one row.
- `approval-queue merge <id>` on a report exits 2 and says a report is never merged. `approval-queue collect <id>` exits 2 and says a report holds no decision to collect.
- A state directory holding all four kinds of item loads on the board and the history page. `pending` exits 0 there and still prints the decided packet it holds.
- `docs/STATUS.md` adds the rebuild to the steps thinkpad-x1 runs before its first hand-over.

Files: `bin/.local/bin/approval-queue` (the new command, the messages in `merge` and `collect`, the kind list in `pending`), `approval-queue/src/lib/server/items.ts` (`KINDS`, the `ItemMeta` kind), `approval-queue/src/lib/server/history.ts`, `approval-queue/src/lib/board.ts`, `approval-queue/src/routes/+page.server.ts`, `approval-queue/src/routes/history/+page.svelte`, a new report page under `approval-queue/src/routes/`, their tests, `tests/approval-queue.test.sh`, `README.md`, `docs/STATUS.md`.

```text
Round ur-queue · approval-queue · written 2026-11-12 06:14

| Pass | State   | PR  | Planned | Actual | Usage before | Usage after |
| Q1   | merged  | #51 | 60      | 31     | 63%          | 66%         |
| Q2   | merged  | #52 | 90      | 44     | 66%          | 71%         |
| Q3   | merged  | #53 | 120     | 70     | 71%          | 79%         |
| Q4   | parked  | #54 | 120     | 38     | 79%          | 84%         |

Stops 1 · Refusals 0 · Calls sent to you 1
Planning misses 2: mechanism 1, file-list 1
Trials: Fable 5.2 planned 4 passes · /goal held 8 sessions, cleared early 0

Waiting for you: Pass paused, the round report as an item
Landed: #51 #52 #53
Resume from: unattended-rounds/plans/ur-queue-conductor-prompt.txt

[ Mark read ]
```

The figures in the mockups are made up. Each page keeps the look it has today.

### Round `ur-ws`: the workstation

**Pass W1. The busy check reads only a running pass.** 45 minutes, class `runner`.

- A session row whose `state` is `done` is not a hit.
- A `claude daemon run` process and the queue's server (`node <path>/approval-queue/build`) are not hits.
- A running `--bg` session in the path and an uncommitted file edited in the last hour are hits, as today. So is any other process with the path in its command line, a `node` process that isn't the queue's server among them.
- With a fixture holding the queue's server process and one finished session row, the check exits 0 for the approval-queue path.

Files: `bin/.local/bin/claude-worktree-busy`, `tests/claude-worktree-busy.test.sh`.

**Pass W2. The pass report counts planning misses by class.** 60 minutes, class `ordinary`.

- Given a PR body whose `## Planning misses` lines open with a tag, `pass-report` prints a table of misses by class for its window. The ten tags are `[mechanism]`, `[file-list]`, `[permission]`, `[design-gap]`, `[stale-fact]`, `[owner-call]`, `[no-answer]`, `[conflict]`, `[estimate]`, and `[ambiguous]`.
- A miss line with no tag counts as `untagged`.
- A PR with no such section adds nothing, and the report's other tables don't change.

Files: `bin/.local/bin/pass-report`, `tests/test_pass_report.py`.

**Pass W3. The launch guard and the pass section of `CLAUDE.md`.** 75 minutes, class `runner`. Waits for W5, and runs last. Its PR waits for you in a close packet. Your answer above sets who writes the two files.

- The launch guard finds a plan kept in an initiative record: `<slug>-plan.md` beside `<slug>-prompt.txt`. This closes backlog #72.
- A plan's `## Pre-flight` section needs a third line, `Evidence:`, naming its mechanism table and its recorded searches. A launch without it is denied with a message that names the line.
- A launch whose prompt name ends `-planning-prompt.txt`, and a launch that names no plan, exit 0 with no denial.
- The pass section of `CLAUDE.md` names your touchpoints as the round design, its pre-flight sitting, a close packet where a call remains, a stop packet for a parked pass, and the round report. The file stays at 120 lines.
- `dotfiles-pass` lists `claude-launch-guard` under `runner`.

Files: `bin/.local/bin/claude-launch-guard`, `tests/test_claude_launch_guard.py`, `claude/.claude/CLAUDE.md`, `.claude/skills/dotfiles-pass/SKILL.md`, `BACKLOG.md`.

**Pass W4. The round rules in `pass-core`.** 150 minutes, class `runner`. Waits for Q3 and Q4.

Two of the four capped files have no room for the rules. `references/planner.md` has 15 words free and needs about 130. The rules go into two new reference files, each capped separately, and the caps on the four existing files hold.

- `references/round.md` is new, capped at 1,500 words, and loaded by every planner. It holds what a round design adds, the four planner rules, and the design rules with your answer on a one-pass round.
- `references/round-run.md` is new, capped at 1,500 words, and loaded by every conductor and executor. It holds the twelve standing answers, the conductor's order table and queue rules, the stop procedure, the evidence rule for each acceptance item, the ten miss tags, and the report's fields. It uses the queue's `round` field, `land --round`, and `report` in place of the title prefix.
- Standing answer 6 of the design you approved loses its check by hand, since W1 made the busy check exact.
- `pass-core/SKILL.md` "Lifecycle" says a design is a round design of one to six passes in one repo, and names both files. "Conductor" says a round of two or more passes has one. "Clock stop" leaves the file, freeing 47 words, since `standards:running-passes` "Clock" holds the same rule.
- `references/planner.md` points to `round.md`, and its pre-flight names `Evidence:` as the third line a plan needs. Its copy of the polish-loop sentence goes, freeing 19 words, and the copy in `conductor.md` stays.
- `references/conductor.md` sends a stop as a `stop` packet and launches the next pass that doesn't wait for the parked one. Today it asks and waits. The new rule replaces the 49 words at lines 38 to 41 in no more words.
- `references/executor.md` gains the `Round:` line, the default branch as the PR's base, and a pointer to `round-run.md`, inside its 107 free words.
- The four capped files stay inside 1,500, 940, 560, and 900 words. `claude-context-budget` holds a cap row for each new file, and `claude-pass-load` counts each in the roles that load it. The gate's `skill-caps` and `pass-loads` legs pass.
- `round.md` holds the four planner rules and the four design rules. `round-run.md` holds twelve numbered standing answers and all ten tags. A test counts each.
- With `round-run.md` at its cap, the executor's load is about 8,870 of the 9,000 words `claude-pass-load` allows.
- "Round" alone means the unit. "A backlog round" becomes "a backlog pass", and "a polish loop's rounds" becomes "a polish loop's iterations". The score line keeps "Fix rounds".

Files: `claude/.claude/skills/pass-core/SKILL.md`, `references/round.md` (new), `references/round-run.md` (new), `references/planner.md`, `references/conductor.md`, `references/executor.md`, `references/planning-samples.md`, `bin/.local/bin/claude-context-budget`, `tests/claude-context-budget.test.sh`, `bin/.local/bin/claude-pass-load`, `tests/claude-pass-load.test.sh`.

**Pass W5. The packet skill, the adapters, and the guards doc.** 100 minutes, class `runner`. Waits for W4.

- The `approval-packet` skill lists `round` among the fact keys and names the `report` command. Its step 8 gains a stop case: an approved stop packet runs its listed steps and resumes the pass, and never `merge`.
- The packet writer's brief says what approving a stop packet does. The contract beneath it lists the `round` key.
- `cairn-pass` "Packet" matches your ruling D1: a pass with no call, no `auth-data` path, and no `## Before merge` step lands in any class. Today it says a `runner` pass always sends a packet.
- `unattended-work-guards.md` gains a usage section: the read before each launch, the 85 percent ceiling, an unreadable figure counted as over it, and the wait for the reset. Its `/goal` section points the December review at the trial lines in the round reports.
- The end-to-end check passes. A fresh Sonnet subagent gets the path of the changed `pass-core` and workstation backlog items #63, #69, and #70, and writes a round design outline. The outline holds the order table, the round id, an acceptance list for each pass, the shared assumptions, a mechanism table, recorded searches, the denial-log read, a standing answer for each stop, the merge order, and the default branch as each PR's base. The closing reviewer reads the outline against `round.md`, and a rule the outline broke is a finding.
- The gate's `pass-loads` leg still passes.

Files: `claude/.claude/skills/approval-packet/SKILL.md`, `claude/.claude/skills/survey/writing/approval-brief.md`, `claude/.claude/skills/cairn-pass/SKILL.md`, `claude/.claude/docs/unattended-work-guards.md`.

### Round `ur-std`: the brainstorming skill

**Pass S1. Three changes to `standards:brainstorming`.** 60 minutes, class `runner`. One pass, so no conductor.

- The description on line 3 no longer holds "two or three approaches". It names what the body does: one question at a time, then a written design for one approval.
- "Offer recon" becomes a rule to go and look: the skill reads the code, your files, and the web without asking, and says what it read. It still asks before a spike.
- The written design's list gains what done looks like: what you would see or run, each item able to fail.
- The builder check's prompt asks whether any of those items could pass on a wrong result.
- A fresh Sonnet subagent, given the changed skill and a one-line request in the standards repo, reads the repo before its first question and never asks whether it may look. Its transcript shows a file read before the first question mark.
- The repo's CI passes: the plugin check, the path scan, and the 500-line cap.

Files: `plugins/standards/skills/brainstorming/SKILL.md`, `plugins/standards/skills/brainstorming/builder-check-prompt.md`.

### What the passes share

Each row is an assumption that more than one pass rests on.

| Assumption | Proof |
| --- | --- |
| A waiting packet survives a restart of the queue's server. | This session restarted the server on 2026-11-11 while packet `20261111T161236-2074074` waited, and the command printed your approve afterwards. |
| The queue's command changes for every new call as soon as its checkout is pulled. | `~/.local/bin/approval-queue` is a link into `~/Projects/approval-queue`. A command already waiting keeps the code it started with. |
| An old server and a new command can run side by side. | `parseFacts` ignores a key it doesn't know (`approval-queue/src/lib/facts.ts:215-312`), and an item of a kind the server doesn't know is not listed. Read in the code, not run. |
| The app can show a Markdown file. | `marked` 18.1 is a dependency (`approval-queue/package.json:33`), and a design packet shows `design.md` today. |
| `gh` can name a repo's default branch. | `gh repo view` printed `main` for all three repos on 2026-11-11. |
| A session row says when it is finished. | `claude agents --json` printed rows with a `state` of `busy` or `done` on 2026-11-11. |
| A new file under `pass-core/references/` reaches every session with the pull. | `~/.claude/skills/pass-core` is a link to the directory in the main checkout. |
| A changed standards skill reaches the workstation. | `claude-tooling.md:21` says the plugin "auto-updates from `main`". Not probed. |
| A session can edit a skill in a workstation worktree. | Your auto-mode entry allows it for "a task of a pass plan Geoff approved", where each change "takes effect only after Geoff merges its PR" (`claude/.claude/settings.json:422`). W4 and W5 follow from this design and land themselves under ruling D1, and no probe shows the classifier reads that as covered. A refusal parks the pass under approved standing answer 2. The entry names hooks and `CLAUDE.md` as not covered, which is why W3 comes to you. |
| The busy check knows the queue's server by its command line. | Today's start line is `node "$app/build"` (`bin/.local/bin/approval-queue:729`). Q1 keeps that shape for `restart`, and W1 matches it. |
| The ten miss tags are the same in W2's parser and W4's rules. | Both take the list in W2 above. |

### Standing answers for the build

The twelve standing answers you approved hold in all three rounds, except that the overhaul has no 85 percent stop. The build adds nine.

1. A queue pass lands. The conductor pulls the main checkout and runs `approval-queue restart`. Until Q1 lands, no restart is needed.
2. A restart fails. The old server keeps answering. The conductor starts no new pass, and the report says so.
3. A workstation pass lands. The conductor pulls `~/.dotfiles`, which puts the change live. A session already running keeps the rules in its prompt until its round ends.
4. Auto mode refuses the edit of the launch guard or of `CLAUDE.md` in W3. The executor tries nothing else. It puts the change in the PR body as a patch, and the pass parks with a stop packet.
5. The plugin cache still holds the old brainstorming skill after S1 merges. The report names the commit the cache holds, and nothing else waits on it.
6. The week reads 85 percent or more before a launch, or the figure can't be read. The conductor launches all the same, where a later round would stop.
7. The weekly limit halts the sessions. Nothing runs until you apply your weekly reset and tell a session to resume the overhaul. That session works in a fixed order:
   1. It runs `approval-queue collect <id>` for each open packet the reports and STATUS name, and acts on any decision you made during the halt.
   2. It stops every overhaul session with `claude stop`, conductors first, and reads `claude agents --json` until no row is left. A session that resumed by itself is stopped with the rest.
   3. It pulls the queue's checkout and runs `approval-queue restart` if a landed queue PR was never pulled.
   4. It commits any uncommitted edit in a pass's worktree on that pass's branch, so nothing is lost and the busy check reads clean.
   5. It relaunches each conductor from the prompt its report names. S1 has no conductor: it relaunches from its executor prompt, or from its planner prompt if no plan was committed.
8. Auto mode refuses a `claude stop` during the resume. The session prints the commands for you, since you are at the keyboard, and relaunches nothing in that round until its rows are gone.
9. The Fable meter reads 95 percent or more. A session due to run on Fable 5.2 runs on Opus at `high`, and the report names each pass that did.

A round report goes to the head of its repo's `docs/STATUS.md`. Once Q4 has merged it also goes to the queue with `approval-queue report`. The standards repo has no STATUS file, so S1's report waits in this record until then.

### Pre-flight

No step is yours before the work starts. Two may come later: the weekly reset once the limit halts the rounds, and a Fable reset if a report shows that meter near its end. No session can apply either.

The session checks the sign-in before the first launch with `claude -p "say ok" --model haiku`.

Permissions checked: the passes run `git`, `gh pr create`, `npm`, `pytest`, the repos' gates, `claude --bg`, `claude stop`, `claude -p "/usage"`, and `approval-queue` with `packet`, `land`, `report`, and `restart`. The denial log's 57 rows from 2026-11-01 to 2026-11-11 were read against them. No pass edits `settings.json` or runs `stow` (10 rows, "Self-Modification"): W4's new files arrive through a directory link, and no pass adds a script. No pass runs `pkill` (9 rows, "Interfere With Workloads"): the queue's server restarts through `approval-queue restart`, which the allow rule `Bash(approval-queue *)` covers. Every merge goes through `approval-queue land` or your approved packet (3 rows, "Merge Without Review"). Whether auto mode lets a conductor stop an executor it launched rests on four stops by this session and one earlier refusal, as the approved design says.

Reviewed: one fresh Opus reader ran the `standards:brainstorming` builder check on the first draft and returned three blocking findings and a list of missed files. Each is folded: the word caps in W4, the workstation passes' real dependencies, and the changed round order. A second fresh reader, on Fable 5.2 at `high`, read the rewrite against the three repos and returned four blocking findings and six minor ones. Each is folded: W3 runs last, the resume has a fixed order, reports refresh before every launch, and nine acceptance items name what a test observes.

### Backlog sweep

The sweep read 38 open workstation items at commit `64063f0`, 3 open approval-queue items at `0bd4828`, and the one standards item filed on 2026-11-11, against the files above.

| Item | Verdict | What the build does |
| --- | --- | --- |
| workstation #72, the launch guard finds plans only under `docs/plans/` | fold | W3 fixes and closes it. |
| workstation #74, an eval for the brainstorming skill | keep | Nothing. S1 changes the skill, and the eval stays filed. |
| workstation #50, a queue decision reaching the auto-mode classifier | keep | Nothing. |
| workstation #63, #69, #70 | keep | W5 reads them as sample items and changes none. |
| workstation #73, #71, #68, #38, #23, #1, #8, #10, #11, #14, #29 | keep | Nothing. None names a file above. |
| approval-queue #49, #41, #38 | keep | Nothing. None touches a stop packet, a base branch, a round, or a report. |

### Out of scope

- Every setting, hook registration, permission rule, auto-mode entry, and secret guard. The build changes none.
- Usage credits. The overhaul spends nothing past the Max plan.
- An auto-mode entry for a conductor stopping its executors. If the rounds meet a refusal there, the report says so and a later design proposes the entry.
- A stop packet with no pull request. The standing answers have the pass push and open a draft first.
- A standing model or effort change. `pass-core` keeps Opus for design, and the Fable seats below hold for these three rounds alone.
- `standards:running-passes`, the `site-pass` adapter, and every repo other than the three above.
- An eval for the brainstorming skill.
- The thinkpad's cutover, beyond the line Q4 adds to the queue's STATUS.

## Technical notes

### Prompts and where they live

The session writes one conductor prompt for `ur-queue`, one for `ur-ws`, and a planner prompt for each of the ten passes, under `unattended-rounds/plans/` in this record. It writes them while this packet waits, and launches none before your approve. Each planner prompt's name ends `-planning-prompt.txt`, which the launch guard passes as a planner launch. Sessions read them by full path, since the record is local and unpushed.

Each planner writes its plan and executor prompt under the pass's repo, in `docs/plans/`, where the launch guard reads them today. Every plan carries the `Evidence:` line from the start, so W3's merge denies none of them. All three repos are public. A plan or PR body cites the round id and this design's pass name, and copies nothing from the `workstation-refinement` record.

The `ur-ws` conductor runs W1 and W2, then waits for the fourth queue PR to merge before it launches W4, W5, and W3 in that order. It checks with `gh pr view` and `claude-worktree-busy ~/.dotfiles`. S1 has no conductor, so its executor lands its PR and writes its report itself.

Three rounds mean at most three executors and two conductors at once, each executor in a worktree of a different repo.

### Models

| Seat | Model and effort | Why |
| --- | --- | --- |
| Planner, all ten passes | Fable 5.2, `high` | The first trial you approved. A plan's misses are what stop a run. |
| Executor on W4, W5, and S1 | Fable 5.2, `medium` | These write rules text every later session reads, inside tight word caps. |
| Whole-branch review at each pass's close | Fable 5.2, `high` | Nine passes merge themselves. This read is the last one before the merge. |
| Executor on Q1 to Q4 and W1 to W3 | Sonnet, `medium` | Code with tests and an acceptance list, under a Fable plan and a Fable review. |
| Conductor | Sonnet, `medium` | It follows a table and decides nothing. |
| Plan review, one per plan | The `standards:plan-reviewer` agent as defined | Unchanged. |
| End-to-end check in W5 and the check in S1 | Sonnet | The test is whether an ordinary session can follow the changed rules. |

Each conductor and executor prompt opens with `/goal`, and the whole prompt is the goal's condition. The `/goal` page makes the condition the directive and caps it at 4,000 characters. The line therefore names every end, PR ready or parked with a stop in STATUS, and points at a run sheet or a plan for the rest. That is the second trial. A session under a goal waits on a background command, never on an idle turn: the page says the goal's check is skipped while a background command runs, and two probes on 2026-11-11 saw no extra turn during such a wait. The page also says a goal pauses on a usage limit and resumes at the reset, and each report's trial line records whether its sessions did.

### How each mechanism fails

The approved design's table holds for the build. These rows are new.

| Mechanism | Evidence | How it fails | What happens |
| --- | --- | --- | --- |
| `approval-queue restart` replaces the server | The README's cutover does it by hand with `npm run build` and `pkill` | The build fails, or auto mode refuses the command | Build standing answer 2. |
| A build while the old server runs | The server loads its chunks from `approval-queue/build` as pages are opened | Building in place breaks a page the old server has not loaded yet | `restart` builds beside the running build and swaps under `start.lock`. |
| A new command beside an old server | `parseFacts` ignores unknown keys, and an unknown kind is not listed | A report queued before the restart doesn't show | The conductor restarts after every landed queue pass, before it uses a new command. |
| A pass edits a skill that running sessions loaded | Skills load when a session starts | A later session reads a rule that differs from its prompt | The prompt wins until the round ends. W4's text and the prompts hold the same rules. |
| The launch guard's new line | `REQUIRED` at `bin/.local/bin/claude-launch-guard:34` | A plan written before W3 merged lacks the line | Every overhaul plan carries it from the start. Any other is denied with a message naming the line. |
| The report item | `KINDS` in `approval-queue/src/lib/server/items.ts` holds three kinds | A reader of items meets a kind it doesn't know | Q4's test loads a state directory holding all four kinds through every page and through `pending`. |
| `report` returns without waiting | The command's exit trap retires an item that has no decision | The trap retires the report as it exits | `report` leaves before the trap is set and records no process id. |
| The base-branch check | `merge` reads `state,headRefOid,body` (`bin/.local/bin/approval-queue:283-338`) | `gh` can't name the default branch | The command exits 1 and merges nothing. |
| `pass-report` reads the tags | It reads merged PRs through `gh` | A PR written before W4 has no tags | The line counts as `untagged`. |
| The weekly limit halts the sessions | Three sessions waited about 64 hours on the limit from 2026-11-04. Resume after a reset is not probed | A halted session never resumes, or resumes while a relaunch is under way | Build standing answers 7 and 8. The resuming session stops every overhaul session before it relaunches any. |
| The Fable meter | `/usage` prints "Current week (Fable)". What happens at 100 percent is not probed | A Fable session halts while the week still has room | Build standing answer 9 moves the seat to Opus at 95 percent. |
| A `/goal` line on a session that waits | The `/goal` page skips the check while "a subagent or a background shell command is still running". Probe jobs `6735aed9` and `7cefc958` waited 75 and 40 seconds on one with no extra turn | A session that waits any other way is prompted again at each turn's end, and the loop stops after several turns with no tool use | A conductor waits on a background command that reads its executor's job state, and an executor watches CI the same way. |

### Claude's calls

- The three rounds start together. W4, W5, and W3 wait for the queue.
- The queue passes are classed `runner`. Q1 moves where the approve check reads, Q2 adds refusals, and neither removes a check. Whether they land themselves is your decision above.
- W3's PR waits for you whoever writes it, since it changes a hook script and `CLAUDE.md`.
- W3 runs last in its round. Every workstation pass edits `docs/STATUS.md`, so an unmerged W3 ahead of W4 and W5 would hold both behind your approve.
- W4 drops the check by hand from standing answer 6 of the design you approved. W1 makes the busy check exact, so the hand check repeats it.
- A resume after the limit stops every overhaul session before it relaunches any, whether or not a session resumed by itself.
- The build changes no setting. A conductor stopping its executors stays on the evidence it has.
- `approval-queue restart` is new. Four restarts in one round by hand would each run `pkill`, the command class auto mode refused nine times.
- `packet` refuses a wrong base as well as `merge` and `land`, so you never approve a packet that can't merge.
- A round id is lowercase letters, digits, and hyphens, starting with a letter, 12 characters at most.
- The report is a fourth item kind with one action, and writes no line in `decisions.jsonl`.
- A second report for a waiting round replaces the first.
- The round rules go in two new reference files, one for planners and one for conductors and executors, each capped at 1,500 words. The caps on the four existing files hold.
- The miss classes are ten short tags, counted by `pass-report`.
- The launch guard's third line is `Evidence:`. The guard checks that the line is there, and the plan reviewer checks what it claims.
- Fable 5.2 takes the planner seat, the executor seat on the three rules-text passes, and every closing review. It falls back to Opus at 95 percent of its meter.
- The overhaul refreshes each report before every launch and launches until the limit.
- The sample items for the end-to-end check are workstation #63, #69, and #70: a wrapper for two adapters, a session-start change, and a fix on an `auth-data` path.
- `site-pass` and `dotfiles-pass` hold no line naming what you approve, so only `cairn-pass` changes there.
- The overhaul's packets keep the round id at the head of their titles through all three rounds.

### Left to the builder

Each rule's wording in its home file, which sentences sit in which of the two new files within their caps, how `restart` builds beside the running build, the report page's route, and each page's markup.

### Sources

- `unattended-rounds/specs/2026-11-11-unattended-rounds-design.md`, approved in packet `20261111T161236-2074074`.
- `unattended-rounds/research/2026-11-11-evidence.md`: the denial log at `:26`, the miss classes at `:43`, the probes at `:65`, the queue in a round at `:93`, the approve refusal at `:299`, and what you said about resets and Fable at `:328`.
- The approval-queue repo at commit `0bd4828`: `README.md`, `bin/.local/bin/approval-queue`, `approval-queue/src/lib/facts.ts`, and `approval-queue/src/lib/server/heads.ts:52-60`.
- The workstation repo at commit `64063f0`: `pass-core` and its references, `bin/.local/bin/claude-launch-guard`, `bin/.local/bin/claude-worktree-busy`, `bin/.local/bin/claude-context-budget:28-33`, `bin/.local/bin/claude-pass-load`, `.claude/skills/dotfiles-pass/SKILL.md`, and `claude/.claude/settings.json:61`.
- The standards repo at commit `896f819`: `plugins/standards/skills/brainstorming/SKILL.md`.
