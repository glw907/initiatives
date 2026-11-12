# ur-ws close 2 of 2: decide whether the last two pull requests of the round merge

`ur-ws` is the id of one round of the unattended-rounds overhaul: `ur` stands for unattended rounds and `ws` for workstation, and it is the round that changes the workstation repo, glw907/workstation (`~/.dotfiles`). Its last two pull requests, #233 and #234, are ready, and two calls wait for you. If you approve, the session merges #233 and then #234 with `approval-queue merge` and pulls `~/.dotfiles`. It then writes the final report of the round and ends the round. If you send the packet back, nothing merges.

Pull request #233 is pass W5. It teaches the `approval-packet` skill and the packet writer's brief two things: the `round` key of a fact file, and what approving a `stop` packet does. It also makes the `cairn-pass` skill agree with your ruling that a pass with nothing for you to decide lands without a packet, and it adds a weekly usage ceiling of 85 percent to `unattended-work-guards.md`. Pull request #234 is pass W3. It changes `claude-launch-guard`, the hook that denies a `claude --bg` launch of a pass whose plan skipped its checks. The guard now also finds a plan named `<slug>-plan.md` beside its prompt, and it requires a third line, `Evidence:`, in the plan's `## Pre-flight` section. W3 also rewrites the list of your touchpoints in the global `CLAUDE.md`.

Both calls are about W5. First, W5 edits the workstation's copy of `approval-brief.md`, a file that belongs to the Survey repo and is copied here at release v1.7.0. The next `claude-tooling-sync update-skills survey` overwrites the two additions, with no warning, unless Survey carries them first. Second, the end-to-end check of W5 had a new Sonnet subagent write the outline of a round design from the changed `pass-core` skill. The outline holds all ten parts that the check asks for, and the closing reviewer found ten faults in it.

One effect of approving is not a call but changes your work from the moment `~/.dotfiles` is pulled. The changed guard is live at once, because `~/.local/bin/claude-launch-guard` links into the main checkout. The planner of W3 ran the old and the new guard over 237 prompt files on 2026-11-12. Seventeen launches that pass today would be denied. A denied launch is fixed by adding the missing lines to its plan.

Each pass got a whole-branch review that ended on `accept`. The repo has no CI that tests a pull request, so the gate run of each pass is the only check.

## Deep dive

What each of the two passes changes, how the end-to-end check ran, what the changed guard denies, and what the session does after you approve.

### How the two pull requests depend on each other

The branch of W3 is cut from the branch of W5, and the branch of W5 is cut from the branch of pass W4. The copy of each diff in this packet still shows the files of passes W1, W2, and W4, which are pull requests #230, #231, and #232 of the first close packet. The diff of #234 also shows the files of W5. The claims under "What changed" cite only the lines that each pass wrote. The session merges #233 before #234 for this reason.

### Pass W5: the packet skill and the writer's brief

The `approval-packet` skill is the procedure a session follows to put work in front of you. Its step 2 now lists `round` among the keys of the fact file. The key is optional. Its value is the round id: lowercase letters, digits, and hyphens, starting with a letter, 12 characters at most. Every fact file of a round of two or more passes carries it.

The step that acts on your decision gains a case for a `stop` packet. An approve on a `stop` packet answers the packet's question and merges nothing. The session runs the packet's listed steps in order, stops at the first failure, and resumes the pass. It never runs `approval-queue merge` on a `stop` packet, because the queue refuses that. The skill also names the command `approval-queue report <initiative> <round> <report.md>`. That command stores a round report in the queue as an item of kind `report`. It sends no packet and waits for nothing.

The packet writer's brief is a section of `approval-brief.md`. It gains a sixth line after its quoted block: approving a stop packet answers its question, the session runs the listed steps and resumes the pass, and the approval merges nothing. The paragraph after the list says that this line states a fact about the queue and adds no style rule. The section "The brief contract" gains a bullet for the `round` key with the same form rule, and it says `approval-queue packet --check` refuses any other value.

### Pass W5: the vendored copy of approval-brief.md

`claude/.claude/skills/survey/writing/approval-brief.md` is a copy of a file from glw907/survey. The plan of W5 records that the copy was identical to Survey's tag `v1.7.0` before the pass. The `survey` skill says to edit the file in the Survey repo only. The design you approved lists the copy among the files of W5, so the pass edited it as listed. The plan records this as a conflict in the design.

`claude-tooling-sync update-skills survey` writes the pinned release over the copy. `claude-tooling-sync verify` does not compare a vendored file with its pin, so no command reports that the copy differs. Backlog #79 records the work: make the same two additions in the Survey repo and release it before that command next runs.

### Pass W5: cairn-pass and the usage ceiling

The "Packet" paragraph of the `cairn-pass` skill now states your ruling D1. A pass with no call for you, no path that touches authentication or data, and no `## Before merge` step lands its pull request with `approval-queue land`, once its checks are green and its whole-branch review is accepted with no open finding. Any other pass sends a packet.

`unattended-work-guards.md` gains a section, "The weekly usage ceiling". The conductor of a round reads the weekly usage before each launch with `claude -p "/usage" --model haiku < /dev/null`, and notes the figure on the line "Current week (all models)". The ceiling is 85 percent of the weekly allowance unless you set another. A figure that cannot be read counts as over the ceiling. At or over the ceiling, the conductor lets the pass in flight finish, starts nothing new, writes the report, and waits for the reset. The same file now tells the December review of `/goal` to read the `Trials:` line of each round report.

W5 files three backlog items: #79 on the Survey release, #81 on four rules in `round.md`, and #80 on a heading in the `site-pass` skill that uses "round" to mean one pass.

### Pass W5: the end-to-end check

The check tests whether a reader with no context can design a round from the changed `pass-core` skill alone. The executor gave a new Sonnet subagent the path of the skill and backlog items #63, #69, and #70. The subagent wrote the outline of a round design, and no one answered its questions. The outline is committed as `docs/plans/2026-11-11-ur-w5-outline.md`, 173 lines. The plan forbids any edit to it, so that the file stays the evidence of what the reader wrote.

The acceptance item asks for ten parts: the order table, the round id, an acceptance list for each pass, the shared assumptions, a mechanism table, recorded searches, the denial-log read, a standing answer for each stop, the merge order, and the default branch as the base of each pull request. The fact file says the outline holds all ten. The closing reviewer then read the outline against `round.md` and found ten rule breaks, named B1 to B10.

Backlog #81 sorts the ten. Four trace to the wording of `round.md`, and a later designer who reads the same text can repeat them:

- The list of what a design adds leaves out the order table, so the reader described the table and drew none.
- The rule about passes that share a file says nothing about `BACKLOG.md` and `docs/STATUS.md`, which nearly every pass edits. The reader counted source files only.
- The rule that a pass waiting for a close packet holds every later landing is only in `round-run.md`, a file that `round.md` sends a designer away from.
- The rule on the denial log asks for "each class found", and the reader named 6 of 19 classes.

Backlog #81 calls the other six the reader's own misreadings, which need no change unless a second reader repeats them. The list of the ten findings is not in this packet's copy of the diff. Backlog #81 is the only record of it here.

During the check, the executor stopped once and you answered on the queue. Your answer narrowed the search that runs on the outline before any commit to two things: a full home path, and text copied from the initiative's record.

### Pass W3: the launch guard

`claude-launch-guard` is a PreToolUse hook. It finds the plan that a `claude --bg` launch runs and denies the launch when the plan's `## Pre-flight` section lacks a required line. Before W3 it required two lines, `Permissions checked:` and `Reviewed:`. It found a plan in two ways: a `docs/plans/*.md` path named in the prompt file, or the file beside the prompt with `-prompt.txt` swapped for `.md`.

W3 makes two changes. The guard now also tries the file beside the prompt with `-prompt.txt` swapped for `-plan.md`, after the `.md` form. That is how a plan kept in an initiative record is named, and until now the guard never read such a plan. The guard also requires a third line, `Evidence:`, which names the plan's mechanism table and its recorded searches. The denial message names each missing line and says what to write on the `Evidence:` line. The guard checks that the label is in the section. It does not read what follows the label.

A planner launch, a launch that names no plan, and a prompt that names only a design still pass. The test file gains ten tests for these cases.

The planner did not build a wider match for any `plans/` directory, which backlog #72 had asked for. Every executor prompt of this overhaul names another file under `plans/` before its plan, and a wider match would read that file as the plan and deny the launch. W3 closes backlog #72 with that note and files backlog #82 for a guard that can tell a plan from the other files a prompt names.

### Pass W3: what the changed guard denies

The planner ran the old and the new guard over the 237 `*-prompt.txt` files in `~/Projects` and `~/.dotfiles` on 2026-11-12:

- 182 pass under both, and 38 are denied under both.
- 17 pass today and would be denied. Nine of those plans lack only the `Evidence:` line. The other eight are plans kept in initiative records as `<slug>-plan.md`, dated 2026-10-19 to 2026-10-26. They lack all three lines.
- All 21 prompts of this overhaul pass under both.

The plan says the eight older plans are left as they are, because their passes already ran.

### Pass W3: CLAUDE.md and the other files

The section "The pass process lives in `pass-core`" of the global `CLAUDE.md` now lists your touchpoints as the round design, its pre-flight sitting, a close packet where a call remains, a stop packet for a parked pass, and the round report. The old list was the design packet, its pre-flight sitting, and one packet per hand-over. The row for the guard in `README.md` now names the evidence line, and the `dotfiles-pass` skill adds `claude-launch-guard` to a list of scripts in its path map.

### After you approve

The session merges #233 and then #234 with `approval-queue merge` and pulls `~/.dotfiles` with `git pull --ff-only`. It runs no `stow` and no tooling apply. It then writes the final report at `~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds/reports/ur-ws-report.md`, with a row for each of the five passes, and ends the round.

### Reviews

W5 got a whole-branch review that ended on `accept`. The ten findings on the outline stay open as the second call. W3 got a whole-branch review that ended on `accept` with no open finding and no call. By the rule in `cairn-pass`, such a pass lands without a packet. The fact file says W3 waits for your approve because you chose that for the launch guard and the `CLAUDE.md` change.

## Your calls

There are two calls, both about W5. No failing check and no review verdict forces either. The session recommends the first option in each.

### Approve the edit to the workstation's copy of approval-brief.md before Survey has it?

Context: `approval-brief.md` belongs to the Survey repo, and the workstation holds a copy pinned to release v1.7.0. The `survey` skill says to edit the file in the Survey repo only. The design you approved lists the copy among the files of W5, so W5 added a line on stop packets and a bullet on the `round` key to the copy. `claude-tooling-sync verify` does not compare a vendored file with its pin.

Risk: If you approve as written, both additions are live now. The next `claude-tooling-sync update-skills survey` overwrites them with the v1.7.0 text and gives no warning, until a Survey release carries them. If you send back, W5 is held and its acceptance item for the brief stays unmet until that Survey release exists. W3 waits behind W5, so neither pull request merges.

Recommendation: Approve as written, and carry the two additions into Survey before its next release. Backlog #79 records that work.

### Accept the outline as evidence, with its ten faults?

Context: The end-to-end check had a new Sonnet subagent write the outline of a round design from the changed `pass-core` skill. The outline holds all ten parts that the acceptance item asks for. The closing reviewer found ten rule breaks in it. The plan forbids an edit to the outline. Backlog #81 names the four rules in `round.md` that the reader misread because of their wording.

Risk: If you accept, W5 merges as it stands. The four rules in `round.md` keep wording that a later designer can misread, until backlog #81 runs. If you send back, W5 is held and its executor is launched again. It edits `round.md`, a file of pass W4 that the design of W5 leaves alone, and it runs the end-to-end check again.

Recommendation: Accept the outline as evidence, and fix the four rules in `round.md` through backlog #81.

## Not checked

No CI ran on either pull request. The repo has no CI that tests a pull request, so the gate run of each pass is the only check.

The guard in #234 is live as soon as `~/.dotfiles` is pulled, because `~/.local/bin/claude-launch-guard` links into the main checkout.

## What changed

W5 changes four files of skills and docs, adds three backlog items, and adds its plan, its prompt, and the outline. W3 changes the guard and its test, three docs, and the backlog, and adds its plan and prompt. Because the branches are cut from each other, each diff also shows the files of earlier passes. The claims below cite only the lines of W5 in #233 and of W3 in #234.

- Step 2 of the `approval-packet` skill lists `round` among the keys of the fact file and gives the form of its value. [glw907/workstation#233 claude/.claude/skills/approval-packet/SKILL.md:24-30]
- The skill says an approve on a `stop` packet merges nothing, and the session runs the listed steps and never `approval-queue merge`. [glw907/workstation#233 claude/.claude/skills/approval-packet/SKILL.md:75-78]
- The skill says `approval-queue report` stores a round report, sends no packet, and waits for nothing. [glw907/workstation#233 claude/.claude/skills/approval-packet/SKILL.md:86-89]
- The packet writer's brief gains a sixth line on what approving a stop packet does. [glw907/workstation#233 claude/.claude/skills/survey/writing/approval-brief.md:129-129]
- "The brief contract" gains a bullet for the `round` key. [glw907/workstation#233 claude/.claude/skills/survey/writing/approval-brief.md:169-171]
- The "Packet" paragraph of `cairn-pass` says a pass with no call, no `auth-data` path, and no `## Before merge` step lands with `approval-queue land`. [glw907/workstation#233 claude/.claude/skills/cairn-pass/SKILL.md:51-54]
- `unattended-work-guards.md` tells the December review to read the `Trials:` line of each round report. [glw907/workstation#233 claude/.claude/docs/unattended-work-guards.md:134-136]
- `unattended-work-guards.md` gains the weekly usage ceiling: the command, the 85 percent figure, and what the conductor does at or over it. [glw907/workstation#233 claude/.claude/docs/unattended-work-guards.md:140-148]
- Backlog #79 asks for the two additions in the Survey repo before `update-skills` next runs. [glw907/workstation#233 BACKLOG.md:12-13]
- Backlog #81 names the four rules in `round.md` and says the other six findings are the reader's misreadings. [glw907/workstation#233 BACKLOG.md:14-15]
- Backlog #80 asks for a new heading in `site-pass` where "round" means one pass. [glw907/workstation#233 BACKLOG.md:94-95]
- The outline names its round id, `ws-hygiene`. [glw907/workstation#233 docs/plans/2026-11-11-ur-w5-outline.md:32-32]
- The outline holds a pass table of three passes. [glw907/workstation#233 docs/plans/2026-11-11-ur-w5-outline.md:40-46]
- The plan of W5 lists the ten parts and says the outline is committed as written and never edited. [glw907/workstation#233 docs/plans/2026-11-11-ur-w5-plan.md:243-247]
- The plan of W5 says a finding on the outline stays open, becomes a call for you, and gets a backlog item. [glw907/workstation#233 docs/plans/2026-11-11-ur-w5-plan.md:293-295]
- The plan of W5 sets out the call on the vendored copy and its two choices. [glw907/workstation#233 docs/plans/2026-11-11-ur-w5-plan.md:297-306]
- The plan of W5 records your answer on the queue that narrowed the search on the outline. [glw907/workstation#233 docs/plans/2026-11-11-ur-w5-plan.md:574-578]
- `docs/STATUS.md` records W5 and its two calls. [glw907/workstation#233 docs/STATUS.md:97-104]
- The docstring of `claude-launch-guard` names the `-plan.md` sibling and the `Evidence:` line. [glw907/workstation#234 bin/.local/bin/claude-launch-guard:5-9]
- The guard requires three lines: `Permissions checked:`, `Reviewed:`, and `Evidence:`. [glw907/workstation#234 bin/.local/bin/claude-launch-guard:36-36]
- The guard tries the `.md` sibling of the prompt and then the `-plan.md` sibling. [glw907/workstation#234 bin/.local/bin/claude-launch-guard:127-131]
- The guard names each missing line in the denial. [glw907/workstation#234 bin/.local/bin/claude-launch-guard:138-141]
- The denial message says what to name on the `Evidence:` line. [glw907/workstation#234 bin/.local/bin/claude-launch-guard:175-176]
- A test expects a denial that names all three lines for a `-plan.md` plan beside its prompt. [glw907/workstation#234 tests/test_claude_launch_guard.py:176-183]
- A test expects a denial that names only the `Evidence:` line for a plan that has the two older lines. [glw907/workstation#234 tests/test_claude_launch_guard.py:192-197]
- A test expects the `.md` sibling to be read before the `-plan.md` sibling. [glw907/workstation#234 tests/test_claude_launch_guard.py:213-221]
- A test expects a planner prompt to pass with no sibling read. [glw907/workstation#234 tests/test_claude_launch_guard.py:238-243]
- The global `CLAUDE.md` lists five touchpoints. [glw907/workstation#234 claude/.claude/CLAUDE.md:11-14]
- `README.md` says the guard refuses a launch until the plan records its permission check, its review, and its evidence. [glw907/workstation#234 README.md:66-66]
- The `dotfiles-pass` skill adds `claude-launch-guard` to a list of scripts in its path map. [glw907/workstation#234 .claude/skills/dotfiles-pass/SKILL.md:44-44]
- Backlog #82 asks for a guard that can tell a plan from the other files a prompt names. [glw907/workstation#234 BACKLOG.md:12-13]
- Backlog #72 is closed, with a note that the wider `plans/` match was not built. [glw907/workstation#234 BACKLOG.md:168-170]
- The plan of W3 records the run of both guards over 237 prompt files and its counts. [glw907/workstation#234 docs/plans/2026-11-11-ur-w3-plan.md:120-132]
- `docs/STATUS.md` says the guard change is not live until you approve #234 and `~/.dotfiles` is pulled. [glw907/workstation#234 docs/STATUS.md:106-109]
