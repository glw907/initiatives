# ur-ws close 1 of 2: the busy check, the miss count, and the round rules

Three pull requests of round `ur-ws` in glw907/workstation are ready to merge, and three calls wait for you. If you approve, the session merges #230, #231, and #232 in that order and pulls `~/.dotfiles`. It then sends the second close packet of the round. The session recommends the first option in each call, and each first option lets the merge go ahead.

Pull request #230 is pass W1. It makes `claude-worktree-busy` skip a finished session row, the `claude daemon run` process, and the server of the Approval Queue. Pull request #231 is pass W2. It adds a count of planning misses by class to the output of `pass-report`. Pull request #232 is pass W4. It adds two reference files to the `pass-core` skill that hold the rules for a round, and it changes four files of the skill to agree with them.

The three calls are about these facts. The test for `claude-worktree-busy` leaves `sleep` processes that run for up to 30 seconds after the test ends. The new rules tell a session to stop its launches when `claude-worktree-busy` exits 1, but the script still exits 1 for a session that checks the directory it works in. The new file `round-run.md` holds 1,499 words against a cap of 1,500, and three details did not fit.

Each of the three passes got a whole-branch review that ended on `accept`. The repo has no CI that tests a pull request, so the run of `scripts/gate.sh` by each pass is the only check. Passes W5 (#233) and W3 (#234) are cut from these branches. They go in the second close packet after this one is merged.

## Deep dive

How the three pull requests depend on each other, what each pass changes, and what the session does after you approve.

### How the pull requests depend on each other

The branch of W2 is cut from the branch of W1, and the branch of W4 is cut from the branch of W2. Each plan names `main` as the base of its pull request. Until #230 merges, the diff of #231 also shows the five files of W1. Until #230 and #231 merge, the diff of #232 shows the files of both. The merge order is therefore #230, #231, #232.

### Pass W1: the busy check

`claude-worktree-busy <directory>` exits 1 when a directory is in use and exits 0 when it is free. It runs three checks in order. The first looks for a process whose command line holds the path. The second looks for a row of `claude agents --json` whose working directory is in the path. The third looks for an uncommitted file edited in the last 60 minutes.

W1 narrows the first two checks. The process check now skips the `claude daemon run` process and the server of the Approval Queue, which runs as `node <path>/approval-queue/build`. The session check now skips a row whose state is `done`, `stopped`, or `failed`.

Every other hit stays a hit. A running session in the path still counts, and so does a session row with no state, which is the form of an interactive session's row. A `node` process that is not the queue's server still counts, and so does a `claude` process that is not `daemon run`. The row of the session that runs the check also still counts. W1 files that as backlog #75, and the second call is about it.

### Pass W2: the count of planning misses

`pass-report` gains one section, `## Planning misses`. It prints once for the whole window, after the last repo section and before `## Notes`. The section reads the `## Planning misses` section of each merged pull request's body and counts each miss line by the tag that opens it. The table has a row for each of ten tags, a row for `untagged`, and a `Total` row. Each row shows the count and the count per 100 merged pull requests. When the window holds no miss line, the section prints one sentence and no table.

W2 files backlog #76. `pass-report` lists at most 300 merged pull requests for a repo and prints no notice when a listing is full.

### Pass W4: the round rules

A round is one approved design that covers one to six passes in one repo. W4 writes the rules for a round into two new reference files of the `pass-core` skill. A planner reads `references/round.md`. It holds what a round design adds to a pass design, four design rules, four planner rules, the ten miss tags, and the steps to park a pass at planning. A conductor and an executor read `references/round-run.md`. A conductor is the session that launches the passes of a round in order. This file holds twelve standing answers, which are the fixed rules for the cases that stop a round. It also holds the order of steps before each launch, the rules for the Approval Queue, the stop procedure, the evidence that a pull request body carries, and the fields of the round report.

Four files of the skill change to agree with the two new files. `SKILL.md` says that every design is a round design and names both files. Its `## Clock stop` section leaves. `conductor.md` now sends a `stop` packet on a stop and launches the next pass that does not wait for the parked one. `planner.md` names three lines for a plan's pre-flight list: `Permissions checked:`, `Reviewed:`, and `Evidence:`. `executor.md` says that the base of a pull request is the default branch.

`claude-context-budget` gains a cap of 1,500 words for each new file. `claude-pass-load` counts `round.md` for the planner and `round-run.md` for the executor and the conductor. W4 files backlog #77 and backlog #78. Backlog #77 is about a `notify-send` step in `conductor.md` that disagrees with the new rules. Backlog #78 is the subject of the third call.

### After you approve

The session merges the three pull requests in order with `approval-queue merge` and pulls `~/.dotfiles` with `git pull --ff-only`. It runs no `stow` and no tooling apply, because no pass adds a script or changes a setting. It then sends the second close packet, for W5 and W3.

### Reviews

W1 got a whole-branch review that ended on `accept` with one finding left open, the `sleep` processes of the first call. W2 got a whole-branch review that ended on `accept` with no open finding. W4 got a whole-branch review that ended on `accept` with one finding left open, the three details of the third call.

## Your calls

There are three calls. No failing check and no review verdict forces any of them. The session recommends the first option in each.

### Land W1 while its test leaves sleep processes running, or send a follow-up?

Context: The test for `claude-worktree-busy` starts each fixture as a `bash` process that runs `sleep` for 6 or 30 seconds. The test ends a fixture with `kill` on the `bash` process. The `sleep` child of that process keeps running until its time ends, which is up to 30 seconds. The test still passes and exits 0. The command line of a leftover `sleep` holds no path, so `claude-worktree-busy` does not count it. This is the one finding that the review of W1 left open. The known fix is to run `pkill -P` on the fixture process before the `kill`.

Risk: If W1 lands as is, a command that reads the test's output through a pipe waits for the leftover `sleep` processes, for up to 30 seconds. If you ask for a follow-up, W1 is held and a follow-up pass writes the cleanup. That pass must end the child processes another way, because the round rules bar a session from running `pkill`. The branches of #231 and #232 hold the commits of W1, and the fact file does not say what happens to them while W1 is held.

Recommendation: Land W1 as is and file the cleanup in the backlog. The test passes, and the leftover processes end without help within 30 seconds.

### Approve W4 while claude-worktree-busy still counts the session that runs it?

Context: Before each launch, a conductor runs `claude-worktree-busy` on the main checkout of the repo. Standing answer 6 in `round-run.md` now reads: "The busy check exits 1. Launches end in that repo, and the report says so." The earlier form of that answer let the conductor check a hit by hand. The design that you approved removes the hand check, on the ground that W1 made the busy check exact. One gap is left. `claude-worktree-busy` counts the row of the session that runs it, so a conductor whose working directory is the main checkout gets exit 1 each time it checks that checkout. Backlog #75 holds the fix: skip a row whose process is the check's own process or one of its ancestors. The conductor of round `ur-ws` keeps the hand check from its prompt until the round ends.

Risk: If you approve as written, the next conductor that checks the main checkout ends its launches at the first run of `claude-worktree-busy`, until backlog #75 lands. Backlog #75 must therefore run before the next round that has a conductor. If you send W4 back, W4 is held. Its executor is relaunched with your note and keeps a clause for the conductor's row until #75 lands, and the packet is sent again.

Recommendation: Approve W4 as written and run backlog #75 before the next round that has a conductor. Standing answer 6 reads as your approved design asks. The gap is in the script, and backlog #75 already records the fix.

### Take the three details left out of round-run.md later, or add them now?

Context: The design that you approved caps `round-run.md` at 1,500 words, and the file holds 1,499. Three details for a conductor did not fit. The first is what the clock of a round counts for standing answer 7, which stops new launches when a round passes twice its planned minutes. The second is where the report file lives. The third is how a relaunched conductor resumes. Backlog #78 records the three details. This is the one finding that the review of W4 left open.

Risk: If you approve, the three details stay out of `round-run.md` for now. The conductor prompt of each round has to carry them, and a conductor whose prompt leaves one out has to guess. If you send W4 back, W4 is held and the cap of 1,500 words changes, and your approved design fixed that cap.

Recommendation: Approve W4 and take backlog #78 later. The cap stays as your approved design set it, and a conductor prompt can carry the three details until #78 lands.

## Not checked

No CI ran on any of the three pull requests. The repo has no CI that tests a pull request, so the run of `scripts/gate.sh` by each pass is the only check.

## What changed

The three pull requests change 23 files in total and add about 1,950 lines. About 1,220 of those lines are the plans and prompts of the three passes. W1 changes 5 files, W2 adds 5 more, and W4 adds 13 more. Because the branches are cut from each other, the diff of #232 shows all 23 files. Each bullet cites the pull request of the pass that made the change.

- The session check of `claude-worktree-busy` skips a row whose state is `done`, `stopped`, or `failed`. [glw907/workstation#230 bin/.local/bin/claude-worktree-busy:78-79]
- A new function reports whether a command line is `claude daemon run` or `node <path>/approval-queue/build`. [glw907/workstation#230 bin/.local/bin/claude-worktree-busy:35-41]
- The process check skips a command line that the new function matches. [glw907/workstation#230 bin/.local/bin/claude-worktree-busy:58-58]
- The test covers a daemon process, the queue's server, and the queue's server with a finished session row, and each case expects exit 0. [glw907/workstation#230 tests/claude-worktree-busy.test.sh:93-106]
- The test expects exit 1 for a `node` process that is not the queue's server and for a `claude` process that is not `daemon run`. [glw907/workstation#230 tests/claude-worktree-busy.test.sh:108-124]
- The test expects exit 0 for a row whose state is `done`, `stopped`, or `failed`, and exit 1 for a row with no state. [glw907/workstation#230 tests/claude-worktree-busy.test.sh:130-133]
- The test ends a fixture with `kill` on the process that it started, and not on the children of that process. [glw907/workstation#230 tests/claude-worktree-busy.test.sh:61-62]
- Backlog #75 asks that `claude-worktree-busy` skip the row of the session that runs it. [glw907/workstation#230 BACKLOG.md:12-13]
- `pass-report` holds the ten miss tags and the patterns that find the `## Planning misses` section and its list items. [glw907/workstation#231 bin/.local/bin/pass-report:30-37]
- A new function returns the class of each miss line in a pull request body, and a line with no tag is `untagged`. [glw907/workstation#231 bin/.local/bin/pass-report:271-289]
- A new function builds the `## Planning misses` section, and it prints one sentence and no table when the window holds no miss line. [glw907/workstation#231 bin/.local/bin/pass-report:292-309]
- The report prints the new section before `## Notes`. [glw907/workstation#231 bin/.local/bin/pass-report:566-566]
- The test holds the table that the report must print for a fixture of seven merged pull requests. [glw907/workstation#231 tests/test_pass_report.py:208-226]
- Backlog #76 asks that `pass-report` note a repo whose listing reaches the cap of 300 pull requests. [glw907/workstation#231 BACKLOG.md:90-91]
- `round.md` defines a round as one approved design that covers one to six passes in one repo. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round.md:6-10]
- `round.md` holds four design rules and says what a one-pass round takes from them. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round.md:40-61]
- `round.md` holds four planner rules. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round.md:63-78]
- `round.md` says how a planner parks a pass before any code is written. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round.md:118-130]
- `round-run.md` holds twelve standing answers. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round-run.md:13-41]
- Standing answer 6 holds no check by hand. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round-run.md:25-25]
- `round-run.md` tells the conductor to run `claude-worktree-busy <checkout>` before each launch. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round-run.md:55-55]
- `round-run.md` allows a close packet three unforced calls at most. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round-run.md:92-94]
- `round-run.md` tells a session to stop its background commands with `TaskStop`, never with `kill` or `pkill`. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round-run.md:112-112]
- `round-run.md` holds the fields of the round report. [glw907/workstation#232 claude/.claude/skills/pass-core/references/round-run.md:133-154]
- `SKILL.md` says that every design is a round design of one to six passes in one repo, and it names both new files. [glw907/workstation#232 claude/.claude/skills/pass-core/SKILL.md:21-23]
- `SKILL.md` loses its `## Clock stop` section and says that a round of two or more passes has a conductor. [glw907/workstation#232 claude/.claude/skills/pass-core/SKILL.md:99-108]
- `conductor.md` sends one `stop` packet on a stop and launches the next pass that does not wait for the parked one. [glw907/workstation#232 claude/.claude/skills/pass-core/references/conductor.md:38-40]
- `conductor.md` says that a non-zero exit of `claude-worktree-busy` ends launches in that repo. [glw907/workstation#232 claude/.claude/skills/pass-core/references/conductor.md:47-47]
- `executor.md` says that the base of a pull request is the default branch, and it names the four lines that the body carries in a round of two or more passes. [glw907/workstation#232 claude/.claude/skills/pass-core/references/executor.md:22-25]
- `planner.md` names three lines for the pre-flight list, with `Evidence:` as the third. [glw907/workstation#232 claude/.claude/skills/pass-core/references/planner.md:49-50]
- `planner.md` says that a planner that cannot launch parks as `round.md` says. [glw907/workstation#232 claude/.claude/skills/pass-core/references/planner.md:72-73]
- `claude-context-budget` caps each new file at 1,500 words. [glw907/workstation#232 bin/.local/bin/claude-context-budget:33-34]
- `claude-pass-load` counts `round-run.md` in the load of the executor. [glw907/workstation#232 bin/.local/bin/claude-pass-load:30-30]
- `claude-pass-load` counts `round.md` in the load of the planner. [glw907/workstation#232 bin/.local/bin/claude-pass-load:40-40]
- A test counts four planner rules, four design rules, twelve standing answers numbered 1 to 12, and the ten miss tags in the two new files. [glw907/workstation#232 tests/claude-context-budget.test.sh:124-137]
- The plan of W4 records that `claude-worktree-busy` still counts the calling session's row, and it sets out the two choices of the second call. [glw907/workstation#232 docs/plans/2026-11-11-ur-w4-plan.md:262-267]
- The plan of W4 records that the conductor of this round keeps the hand check from its prompt until the round ends. [glw907/workstation#232 docs/plans/2026-11-11-ur-w4-plan.md:353-357]
- Backlog #78 records the three details that `round-run.md` leaves out. [glw907/workstation#232 BACKLOG.md:90-91]
- Backlog #77 records a `notify-send` step in `conductor.md` that disagrees with `round.md`. [glw907/workstation#232 BACKLOG.md:92-93]
- `docs/STATUS.md` gains a section that says an executing session now loads about 8,800 words. [glw907/workstation#232 docs/STATUS.md:91-95]
