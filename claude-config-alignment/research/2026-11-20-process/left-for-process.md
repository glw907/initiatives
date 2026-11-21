# What the core spec left for the process spec, with a fate for each

This report covers the list under "Left for the process spec" in
`~/Projects/cc-desk/docs/specs/2026-11-20-core-design.md:495-529`, all 41 rows marked "yes" in
`2026-11-20-core-fates.tsv`, the cc-desk exemption sentence, and the four review notes. Line
numbers in "fates N" are lines of that TSV. "Global file N" means a line of
`docs/specs/2026-11-20-core-claude-md.txt`. "Settings N" means a line of
`claude/.claude/settings.json` at dotfiles commit `8a24900`, the core spec's settings commit.

Everything was read, nothing was changed. Each fate carries one label: **documented**,
**assembled** (built from documented pieces), or **invented**. **[Geoff]** marks a fate that
needs his ruling.

## Two facts that set the timing

- **Old names stay until cairn and dubplate finish.** The rename is the process spec's last
  task, and it runs after their current work finishes under the old names
  (`process-decisions.md:80-81`). cairn and dubplate move over only after the trial passes
  (`process-decisions.md:95-96`). So every "delete" below means delete in the rename task, or
  later, never before. The cairn-cms conductor round is live today: cairn-cms `docs/STATUS.md`,
  commit `e5c1fb0a9`, "round checks waits on the merge of checks-2".
- **Settings `8a24900` is not on `main`.** It is the only commit on `origin/cc-desk-core`
  (`git log origin/main..origin/cc-desk-core`). The live `settings.json` on `main` still has the
  older line numbers (for example `Bash(approval-queue *)` at line 61 there and line 56 in
  `8a24900`).
- **PR 253 is still open.** `gh pr view 253` returns `OPEN Exempt cc-desk's spec work from the
  pass process`. The exemption text in global file 16-18 isn't live yet.

## The three questions asked

### 1. The merge path when Geoff says "merge 31, 32, 34"

**What happens today.** The session he is talking to runs `approval-queue land` for each PR
(`pass-core/SKILL.md:29-32`, `:135-137`; core design step 3 at `core-design.md:395-397`).
`land` refuses a PR in four cases: a check fault (`approval-queue/cli/land.ts:82-83`), a base
other than the default branch (`:84-86`), and a `## Before merge` section (`:87`). Then it runs
`gh pr merge <n> --repo <r> --merge --match-head-commit <oid>` (`:89`).

**Where that breaks under the new process.**

1. **Stacked tasks are refused.** A dependent task branches from its parent's branch, so its PR
   is based on that branch. Say 32 depends on 31. Once 31 merges, 32 is still based on 31's
   branch, and `land.ts:84-86` refuses it. The files don't say whether GitHub retargets 32 to
   `main` when 31's branch is deleted, and `land` doesn't delete the branch (`:89` has no
   `--delete-branch`). This needs a probe or a first-hand read of GitHub's docs.
2. **It can merge before checks exist.** `land` merged a PR three seconds before its `gate`
   check started (`cc-desk/docs/research/2026-11-17-prove-findings.md:119-121`).
3. **The tool is going away.** The queue's role ends with the old process (fates 299), and
   cc-desk's Go, which denied `land` to launched sessions (`cc-desk internal/launch/settings.go:14`),
   is deleted (`process-decisions.md:58`).

**Proposed fate: replace `land` with one short merge script, `task-merge`.** The label is
**assembled**: it uses `gh pr view`, `gh pr checks`, `gh pr edit --base`, and `gh pr merge
--merge --match-head-commit`. For "merge 31, 32, 34" in Geoff's session, it does this:

1. It takes the PRs in his order. A PR whose parent task is in the list goes after its parent.
   A PR whose parent isn't merged and isn't in the list is refused with "name 31 first".
2. Each PR must pass every check `land` makes today, minus the base check. It also needs at
   least one check reported, and every check passed, on the head commit. That closes the race in
   item 2. On GitHub's side, the documented control is a required status check in branch
   protection on `main`, and it gives the same guarantee.
3. The head commit must be the one the fresh reviewer passed, read from the reviewer's recorded
   verdict. A pushed commit after the review is refused and goes to "Read before merging".
4. For a child whose parent just merged, it runs `gh pr edit <n> --base main` first, waits for
   the checks, then merges. It deletes the parent's branch only after every child is retargeted.
5. It always uses `--merge`, never squash. A squash would leave the child holding commits that
   `main` no longer has.
6. A `## Before merge` section works as `pass-core/SKILL.md:30-32` says today. The session runs
   the steps and their check, takes the section out of the body, then runs the script. The PR
   sits in "Read before merging" until then.
7. After each merge, the session pulls the primary checkout and removes the worktree, as
   `pass-core/SKILL.md:143-151` says. Question 2 covers that pull.

**Who may run it.**

- `claude-merge-guard` sees only the Bash command line, so the script's own `gh` calls get
  past it, the same way `land` does today.
- The timer gives every launched session a `--settings` file. That file denies
  `Bash(task-merge *)`, so no launched session merges. Per-launch `--settings` is proven in
  `cc-desk/docs/specs/2026-11-17-sessions-design.md:101`, and a deny rule outranks an allow rule
  (permissions docs). The label is **documented**.
- Geoff's session runs in auto mode (settings 173). The auto-mode entry in fates 249 is
  reworded to cover the script (see "In auto mode").
- **The other option** is to keep `approval-queue land`, lift its base check for retargeted
  children, and add the check-present wait. That keeps a Node app and its repo alive for one
  command. The core design itself says Geoff may merge on GitHub (`core-design.md:397`), and
  that is still a fallback.

### 2. Whether `claude-worktree-busy` is still needed once the timer owns launches

**What it does.** It exits 1 when a process command line, a live `claude agents --json` row, or
an uncommitted edit from the last 60 minutes touches the path (`claude-worktree-busy:1-10`). It
skips the queue's server process (`:7-8`, `:42`).

**It's no longer needed as a launch check.** The timer gives each task a new worktree through
`--worktree` (`sessions-round.md:108` lists the flag), so no other session can be in the new
path. A dependent task branches from the parent's pushed branch, not from the parent's worktree.
What the timer needs instead is a state check: has the parent session ended and pushed? It can
read that from `claude agents --json`.

**It's still needed in three places.**

1. Before the merging session pulls a primary checkout. Core design step 4 runs it there
   (`core-design.md:398-399`), and `pass-core/SKILL.md:143-146` needs "no live session". A
   primary checkout can hold another session's files (`core-design.md:226-229`).
2. Before a worktree is removed after a merge (`pass-core/SKILL.md:148-151`).
3. Before an interactive session enters a primary checkout.

**Proposed fate: keep it, under its current name.** It uses none of the old words.

- Drop the queue skip at `:7-8` and `:42`, along with its fixture at
  `tests/claude-worktree-busy.test.sh:70-75`.
- Reword the global line (see global file 26-30 below).
- Update its callers when those files are renamed: `pass-core/references/round-run.md:55`,
  `desk.md:121`, `~/.claude/agents/site-implementer.md:72`, `engine-consult` at line 111,
  `dotfiles-pass` at line 44, and `dubplate-pass` at line 19.

If it went, nothing would stop a pull over a live session's uncommitted files, and the gate leg
`worktree-busy` (`scripts/check.sh` at the `run worktree-busy` line) would lose its target. The
label is **assembled**.

### 3. What replaces `claude-launch-guard`'s checks when there are no plans

**What it checks.** It finds the plan behind a `claude --bg` launch
(`claude-launch-guard:4-6`). It needs three lines in that plan's `## Pre-flight`:
`Permissions checked:`, `Reviewed:`, and `Evidence:` (`:36`). It also needs
`standards:plan-reviewer` in the session's transcript (`:12`). Its refusal text is at `:172-177`.

**Once plans are gone, it does nothing.** "A launch with no plan ... go[es] through" (`:10-11`).
Under specs it stops refusing anything, so it's dead code.

**Proposed fate: delete the hook and move its checks into the timer script.** A launch the
timer refuses is a plain script exit, so no hook is needed. Each old check maps to a new home.

| Old check | Its new home | Label |
| --- | --- | --- |
| `Permissions checked:` (credentials and writes read against auto mode) | Launched sessions run in `dontAsk` with deny rules. A step the rules refuse is noted, and the session carries on, so a missed permission costs one held step, not a stall. The probe passed (`process-decisions.md:62-64`). | documented |
| `Reviewed:` and `plan-reviewer` ran | The spec carries Geoff's approval and its review record. The timer launches no task of a spec without both. | assembled |
| `Evidence:` (mechanism table, searches) | It moves into the spec's mechanism labels (documented, assembled, invented), which Geoff approves (`process-decisions.md:43-44`). The timer doesn't check it. | assembled |
| (new) a secret is missing | The timer checks by name that each secret the task names is in the stores, and never reads a value (`process-decisions.md:106`). | assembled |
| (new) caps | The timer starts no task past the caps. These are proposed only (`process-decisions.md:121-122`). **[Geoff]** | assembled |
| (new) a task launching tasks | The per-launch settings deny `Bash(claude --bg *)`. | documented |

**What else changes when it goes:**

- Its registration (settings 226-228, with `onFailure: block`).
- `tests/test_claude_launch_guard.py`.
- The `claude-launch-guard` term in the `scripts/check.sh:144` pytest pattern.
- The `README.md:66` row.
- The path list in `dotfiles-pass/SKILL.md:44`.

**Trap.** The hook is registered with `onFailure: block` (settings 226-228). If the script is
removed before its registration, the hook fails on every Bash call, so every Bash call in every
session is blocked. Remove the registration first, or in the same commit.

## In the global file (14 statements and two path rules)

| Item | Where | What it does in the old process | Fate | New words | Label |
| --- | --- | --- | --- | --- | --- |
| Keep working until done (fates 2) | global file 5 | Stops a session from handing work back early. | Reword | "Keep working until the task's goal is met and every gate passes." | documented (`/goal`) |
| The five stops (fates 3) | global file 5-8 | Names the five stops that may wait on Geoff. | Replace | "An interactive session asks Geoff only for what only he can give. A background session never waits on a question. When the permission rules refuse a step, it notes the step under `## Held for you` and finishes the rest. At its cap it ends. It decides a sign-in or data call itself and flags the PR. Never hand Geoff a command to paste that Claude could run: ask for the go-ahead, then run it." This is the mapping in `process-decisions.md:102-108`. | documented controls; the held list is invented (see the notes) |
| Pointer to `pass-core` and the adapters (fates 5) | global file 12-13 | Routes a session to the pass skill. | Reword at the rename | "Writing a spec, running its tasks, and merging them is the `<task skill>` skill, with per-repo adapters." | documented (skills) |
| "Geoff no longer reads the Approval Queue ..." (fates 6) | global file 13-15 | Overrides every skill line that sends him a queue document. | Delete | Delete it once no skill sends a queue document. That happens when `approval-packet` and `pass-core` retire. | n/a |
| "One session runs each pass or hand-over, its state in the repo's STATUS" (fates 7) | global file 15 | One owner per pass, with state kept in STATUS. | Reword | "One background session runs each task in its own worktree. A task's state is its PR and its session record. STATUS holds the repo's current state for people." This is a method call. | assembled |
| cc-desk exemption (PR 253, open) | global file 16-18 | Keeps cc-desk's spec work out of the pass process. | Keep until all repos move, then delete | When cairn and dubplate move over, every repo runs one process and the sentence is moot. | n/a |
| "Before any executor enters ... `claude-worktree-busy` ... ask rather than race" (fates 11) | global file 28-29 | Stops two sessions from racing in one checkout. | Reword | "Before a session enters a primary checkout, pulls one, or removes a worktree, it runs `claude-worktree-busy <path>`. It reports a busy path and leaves it alone. It never waits." | assembled |
| "Two sessions never both close, merge, or release one branch" (fates 12) | global file 29 | Gives each branch one owner. | Reword | "Only the session Geoff is talking to merges, and only the PRs he names, through `task-merge`." The per-launch deny enforces it (question 1). | documented deny plus assembled script |
| Minute estimates (fates 59) | global file 95 | Plans carry minutes, which the forecast uses. | Reword | "No human-scale time estimates in chat. Each task in a spec carries a minute estimate priced from measured minutes." Supported by `process-decisions.md:47` and `:134`. | assembled |
| Unattended guards (fates 64) | global file 101 | Points to the runaway guard, the `/loop` wake-up, the `/goal` trial, and the 85% ceiling (`unattended-work-guards.md:7`, `:94-113`, `:115-140`, `:142-154`). | Replace | "A background session runs under `/goal` and ends at its cap." The timer owns the weekly ceiling. The `/loop` wake-up and `round-watch` sections go with the conductor. **[Geoff]** on the cap figures. | documented (`/goal`); caps assembled |
| Compact: preserve (fates 65) | global file 105-106 | Says what survives compaction. | Reword at the rename | "Preserve the spec path, the task list (done, running, next), open decisions, and the last CI and review verdicts." Keep it in `CLAUDE.md`. The PreCompact hook in fates 65 is an option, not a need. | documented |
| Compact: drop (fates 66) | global file 106 | Pairs with the line above. | Keep | Unchanged. | documented |
| Front-loaded interaction (fates 67) | global file 110-111 | Puts every question before approval. | Reword | "Interaction is batched and front-loaded: before Geoff approves a spec, probe until it carries no open readings, one question at a time." | documented |
| Calls go in `## Decisions` (fates 68) | global file 111 | Records judgment calls for Geoff. | Reword | "After approval, no session waits on a question. Each session records its calls in its PR's `## Decisions`, and a PR that has any is in 'Read before merging'." | assembled |
| Direct changes (fates 70) | global file 113 | Lets a one-sentence change land with no process. | Reword at the rename | Point it at the new skill's "Direct changes" section, with the same rule. | n/a |
| `cairn-family-ui.md` backlog clause (fates 76) | `~/.claude/rules/cairn-family-ui.md:17-18` | Sends cairn UI work to the pass adapters. | Reword at the rename | "Cairn backlog items and engine-level UI mechanics follow the cairn and site task adapters." | n/a |
| `vale.md` branch clause (fates 78) | `~/.claude/rules/vale.md:16-17` | Keeps Vale fixes in the current PR. | Reword | "A fix lands on the current task's branch, in the task's PR, and never gets a separate branch or PR per file." | n/a |

## In the permission rules (14)

| Item | Where | What it does now | Fate | Label |
| --- | --- | --- | --- | --- |
| `ask Bash(wrangler r2 bucket delete *)` and the `npx` form (fates 94-95) | settings 174-176 | Asks before an irreversible bucket delete. | Keep as `ask` for Geoff's own session. Deny both in the per-launch settings, so a background session's attempt is refused and held. This follows `process-decisions.md:105`. | documented |
| `gh release create v* --prerelease *` (fates 117) | settings 31 | Lets a pass cut a prerelease. | Keep. A prerelease is a dev snapshot, not a final. | documented |
| `gh release create v* --target main *` and `v* --target * --title *` (fates 118, 121) | settings 32, 34 | Can publish a final npm version. | Replace both with one allow rule that requires `--prerelease`, and deny the rest in the per-launch settings. A final npm publish can't be undone, so the decided rule applies: refused and held for his sitting (`process-decisions.md:105`). It also fits cairn-cms `CLAUDE.md` "Publishing is a separate act". | documented |
| The four `cairn-run-gate` rules (fates 142-145) | settings 52-55 | The gate wrapper that every adapter runs. | Keep, unchanged and exact. Under `dontAsk` these allow rules are the only reason the gate runs at all. Fates 144 explains why the env-prefixed forms must stay exact. | documented |
| `Bash(approval-queue *)` (fates 146) | settings 56 | The queue's commands. | Delete with the queue. Add `Bash(task-merge *)` in its place, and deny it per launch. | documented |
| The four `ssh` rules for ward and orpheus (fates 197-200) | settings 104-107 | Any remote command on the two servers, because of the trailing `*`. | Replace with exact rules for the reviewed household-it scripts, as `vps-conventions` advises (fates 197). **[Geoff]** decides whether a background session may run server work at all, or whether it is held for his sitting. | documented |

## In auto mode (3)

Auto mode serves Geoff's own session (settings 173 sets `defaultMode: auto`). A launched
session in `dontAsk` gets only its allow and deny rules. Whether it reads `autoMode` entries
isn't stated in the files, and the process spec should confirm it on the permission-modes page.

| Item | Where | Fate | New words | Label |
| --- | --- | --- | --- | --- |
| Skill edits under an approved pass plan (fates 244) | settings 386 | Reword | Replace "a task of a pass plan Geoff approved" with "a task of a spec Geoff approved". Keep both worktree paths. A launched session needs `Edit` allow rules scoped to its own worktree in its per-launch settings, since `dontAsk` refuses an edit with no rule. | documented |
| `approval-queue merge` and `land` (fates 249) | settings 390 | Replace | "Running `task-merge <owner/repo#n>...` in a terminal session is routine when Geoff named those PRs by number in that session. The script merges each one at its reviewed head commit, in his order." Retire the ruling-D1 and queue-approve clauses. | assembled |
| Trusted domains with the queue's port (fates 271) | settings 378 | Reword when the queue retires | Drop ", including the approval queue on 127.0.0.1:7907". The page's server is on localhost, which the entry already covers. | documented |

## In the hooks and scripts (8)

| Script | Who calls it | What breaks if it goes | Fate | Label |
| --- | --- | --- | --- | --- |
| `claude-merge-guard` (fates 282) | Settings 220-222 (`onFailure: block`); `pass-core/SKILL.md:136`; `tests/test_claude_merge_guard.py`; `scripts/check.sh:144` | Sessions could run `gh pr merge` themselves. | Keep it, and rename it `claude-git-guard`, since it now also checks force pushes and whole-tree staging (`core-design.md:515`). Change REASON (`claude-merge-guard:26-30`) to: "Blocked: a session never runs `gh pr merge`. Geoff names the PRs to merge in his terminal session, and that session runs `task-merge`." Update the test's copy of the text (`core-design.md:231-234`). **Trap:** `~/.local/bin` holds one link per file, so a new name needs `stow -R bin` before the registration changes. Under `onFailure: block`, a registration that points at a missing file blocks every Bash call, including the `stow` that would fix it. Land the new file first and switch the registration second, or keep the old name as a link for one release. | documented hook |
| `claude-launch-guard` (fates 283) | See question 3 | Nothing, once there are no plans. | Delete it, with its checks moving into the timer. | assembled |
| `claude-context-budget` skill caps (fates 291) | `scripts/check.sh:207-208` (`--skill-caps`); hook at settings 301 | When the `pass-core` files are renamed, `--skill-caps` prints "absent" and exits 1 (`claude-context-budget:45-48`). That fails the dotfiles gate. | Re-key `SKILL_CAPS` (`:28-36`) in the same PR as the rename. Replace the word caps with Anthropic's documented SKILL.md size guidance for every skill. The files here don't quote that page, so the process spec reads it again (`process-decisions.md:151-154`). Rename the leg's label "pass-core word caps". The rest of the hook stays. | documented |
| `round-watch` (fates 295) | `pass-core/references/conductor.md:27`; `desk.md:45`, `:47`; `unattended-work-guards.md:103`; `scripts/check.sh:144`; `tests/test_round_watch.py`; `dotfiles-pass/SKILL.md:44` | Today's cairn and dubplate conductors lose their wake-up. It isn't on any timer: none of the user units are named for it. | Delete it with the conductor, after cairn and dubplate finish. The timer reads session and PR state instead. | n/a |
| `claude-approval-queue-reminder` (fates 296) | Linked by `approval-queue/scripts/install.sh:9`; registered nowhere; named in the `approval-packet` description (`approval-packet/SKILL.md:7`) and `survey/writing/approval-brief.md:279` | Nothing, since it never runs. | Delete it with the queue repo. Fix the `approval-packet` description in the third spec, or delete that skill. | n/a |
| `pass-report` (fates 298) | Reads the `pass-score` comment (`pass-core/references/executor.md:76`) and miss tags (`round.md:110`); `approval-packet/references/model-report.md:17`; `scripts/check.sh:144`; `tests/test_pass_report.py`; the dev-speed record. It reads queue state (`pass-report:601`). No user timer runs it. | The measured minutes that price the estimates and feed the forecast would have no source. The forecast is decided as kept (`process-decisions.md:47`), and the pricing is owed (`:134`). | Rename it `task-report`. It reads timing from session records and `cairn-run-gate --records`, and drops the queue reading. The comment contract (`SCORE_KEYS`, `pass-report:31-32`) moves into the task skill as a `task-score` comment. This is a method call, not one for Geoff. | assembled |
| `approval-queue` (fates 299) | `pass-core/SKILL.md:25`, `:30`, `:135`; `approval-packet` throughout; `survey/SKILL.md:86-88`; `bluefin/bootstrap.sh:306-316`; `claude-worktree-busy:42`; `pass-report:601`; settings 56, 390 | Today's merges and packets stop, so it must outlive the old process. | Stop using it once `task-merge` exists. Remove the link, the allow rule, the auto-mode entry, the guard text, the busy-check skip, and the bootstrap clone. Archiving or deleting its repo is a teardown under `retire-project`. **[Geoff]** | n/a |
| `claude-worktree-busy` (fates 300) | See question 2 | See question 2. | Keep it, and drop the queue skip. | assembled |

## The four notes from the review

1. **`permissions.denyInsteadOfPrompting`** (`core-design.md:523`). If launched sessions run
   `dontAsk`, the setting adds nothing, because `dontAsk` already refuses what would prompt. Put
   it only in the per-launch settings of a session that runs in auto mode, if the process spec
   chooses one. Never set it globally, because Geoff's own session should still ask him. This is
   a method call, and the label is **documented**.
2. **The list of steps refused and held for Geoff** (`core-design.md:524-525`). It becomes the
   "Held for you" group, which Geoff has now confirmed (the relayed message: "those four groups
   look correct"). Each refused step goes in a `## Held for you` section of the PR body, with the
   exact command. The page reads that section. The refusal and the PR body are documented, but
   nothing in the docs describes such a list, so the label is **invented**. A documented hook
   event could record the refusal ("Hooks record failures", `process-decisions.md:56`). The
   process spec names that event from the hooks page, and the files don't name one.
3. **523 `gh pr merge` attempts** (`core-design.md:526-527`). Nobody has checked why sessions
   keep trying. The file `~/.local/state/claude-denials.jsonl` has 147 rows and only 1 holds
   `gh pr merge`, so hook refusals aren't recorded there. Have the guard append each refusal to a
   log, and read a sample before writing the new REASON text. The label is **assembled**. The
   cause isn't stated.
4. **Six setup-tooling grants, five that outlived their work** (`core-design.md:528-529`). Each
   grant names the task that removes it, and removing it is a step in that task's goal. The fresh
   reviewer checks the grant is gone before the PR is ready to merge. The label is
   **assembled**.

## Fates that need Geoff

- **[Geoff] ssh to ward and orpheus.** May a background session run server work through exact
  script rules, or is all server work held for his sitting?
- **[Geoff] Budget caps.** Twice the planned minutes and 85% of weekly usage are proposed, not
  ruled on (`process-decisions.md:121-122`). The timer's checks and the global file 101
  replacement depend on them.
- **[Geoff] The approval-queue repo.** Stopping its use is a method call. Archiving or deleting
  the repo is a teardown, and a teardown needs his approval.

Final releases, bucket deletes, and the `pass-report` successor don't need his ruling. Each one
already follows from a decided line (`process-decisions.md:47`, `:105`, `:134`).
