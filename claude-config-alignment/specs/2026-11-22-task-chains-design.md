# Spec: let a task build on another task's unmerged work

Status: approved by Geoff on 2026-11-23 ("Approve and launch"). Step 1, the stub chain, runs first.

Today a task that needs another task's work waits until Geoff merges that work, so every approval he
isn't there to give stops the build. This spec lets a task start from its parent task's branch once the
parent's pull request is ready, so a chain of dependent tasks runs overnight. The session Geoff leaves open
runs a `/loop` tick every 15 minutes that launches each next task. Geoff still approves every pull request
by number, and his session merges them in chain order. GitHub moves each child's pull request onto the
default branch when its parent's branch is deleted. One step in Geoff's session proves the chain on two
stub tasks in `glw907/cc-desk-scratch`. One task then writes the rules into `building-from-specs`.

## Intent

Geoff, on 2026-11-22: "note that I'm not sitting at my computer all the time, so any manual PR approval
effectively stops development. So you'll need to come up with a plan that solves that issue."

The test he set on 2026-11-20 (`specs/2026-11-20-process-decisions.md`, "The test") still holds: between
two of his sittings, work stops to wait for him only when it truly needs him. A run fails when a session
sits idle over something it could have decided, or when one stopped task holds up work that didn't depend
on it.

Goals:

- A task whose spec says it builds on another task launches with no word from Geoff once that task's pull
  request is ready, and its branch starts from the parent's branch.
- Independent tasks of one spec run side by side, and dependent ones run in series, overnight.
- The approval rule is unchanged: only Geoff's typed words approve a merge, naming the pull request by
  number, and only the session he talks to merges.
- The merge guard, `claude-git-guard`, and the `ask` rules on `gh pr merge` are unchanged.

Non-goals: restarting a task session that stops on an API error (backlog #95), the systemd timer of the
2026-11-20 pick, a chain that crosses specs, and the forecast the 2026-11-20 record parked.

The work fails if a child merges before its parent, if a merge lands on a branch other than the default
branch, if a child merges built on a parent head other than the one that merged, if a merge runs without
Geoff's words, or if the stub chain needs a word from Geoff between its two tasks.

## How a chain runs

A spec names, for each task, the task it builds on, and only when the task needs that work. The tasks
linked this way form a chain. A task that builds on nothing launches at the first tick, within the
four-session limit. Two children of one parent run side by side.

### The tick

Geoff starts the chain in an interactive session he talks to, on Sonnet at medium, from the repo's main checkout,
with the STATUS launch prompt. The session runs in auto mode without `denyInsteadOfPrompting`, because his
merge prompt depends on prompting. He leaves it open or puts it in the background. The prompt arms
`/loop 15m Run one chain tick for <spec path>, by building-from-specs "Chains".` Each tick does this, then
ends its turn. In it, `<r>` is the spec's repo as `owner/name`.

1. Read the spec's `Status:` line. Unless it reads `approved`, launch nothing and end the tick.
2. For each chain task, find its session in `claude agents --json --all`: the entry with that `name` and
   the newest `startedAt` whose `cwd` is under the repo's checkout, since names repeat across runs. Read its
   branch with `git -C <cwd> branch --show-current`. Find its pull request number `<n>` with
   `gh pr list --repo <r> --head <branch> --state all --json number`, then read it with
   `gh pr view <n> --repo <r> --json number,isDraft,state,headRefName,headRefOid,baseRefName,body`.
3. A task's pull request is ready when all of these hold:
   - Its session reads `done`.
   - `isDraft` is `false` and `state` is `OPEN`.
   - The body's `task-score` comment carries `"verdict":"accept","openFindings":0,"unmet":0`.
   - `gh pr checks <n> --repo <r>` exits 0. In `glw907/workstation`, which has no PR CI, the output
     `no checks reported` also passes. In any other repo it means CI is pending.
4. For each task whose parent is ready, or that builds on nothing, and that has no session yet, run the
   four checks of "Launching a task". Then read the week's usage with
   `claude -p "/usage" --model haiku < /dev/null`. The `Current week (all models)` figure, and the
   `Current week (Fable)` figure for a Fable task, must be under 85 percent, and an unreadable figure counts
   as over. If every check passes, launch the task with the launch line from "Launching a task",
   unchanged. Fill in its goal's three parent values from the parent's `number`, `headRefName`, and
   `headRefOid`.
5. A task whose session reads `failed`, `blocked`, or `stopped`, or that ended with a draft or a
   `task-score` short of the ready values, stops. Nothing that builds on it launches, and every other task
   keeps going.
6. A launch that is refused, or whose task has no entry in `claude agents --json --all` by the next tick,
   is retried once at that tick. A second failure stops that task's branch of the chain.
7. When no chain task is working and none is left to launch, cancel the loop and write the sitting note:
   each pull request in merge order with its state, each stopped task and why, and each usage figure read.

### A child's start

A child launches from the repo's main checkout with `worktree.baseRef` set to `fresh`, as every task does.
Its goal opens with these lines:

```text
It builds on pull request #<parent> (branch <parent-branch>, head <parent-sha>). Before any edit, run
`git fetch origin <parent-branch>` and `git merge --no-edit origin/<parent-branch>`. On a conflict, run
`git merge --abort` and end, listing the conflicting files. Stop unless
`git merge-base --is-ancestor <parent-sha> HEAD` exits 0. Open the draft pull request with
`gh pr create --draft --base <parent-branch>`, and make the body's first line
`Built on #<parent> at <parent-sha>.` The review reads `<parent-sha>..HEAD`.
```

The merge fast-forwards when the default branch hasn't moved since the parent launched, and makes a merge
commit when it has (probe below).

### Merging a chain

Geoff can approve a chain's pull requests in one message. The session merges them in chain order and runs
the four merge steps of "Merging" for each before the next, so the parent's remote branch is deleted before
its child merges. Between the parent's merge and the delete of its remote branch, each open child gets
`gh pr edit <child> --repo <r> --base <default>`. A plain `git push origin --delete` of a child's base
closes the child; it doesn't retarget it (step 1 record, 2026-11-23). In these checks, `<n>` is the pull request being merged and `<r>` its repo. Three checks
come before each `gh pr merge`.

- Its base is the default branch. `gh pr view <n> --repo <r> --json baseRefName --jq .baseRefName` prints
  `main` (or `master` in `dubplate`). A child whose base still names its parent's branch after the parent
  merged gets `gh pr edit <n> --repo <r> --base <default>`. A pull request whose parent hasn't merged
  doesn't merge, even when Geoff names it, and the session says which parent goes first.
- A child is current. Its `Built on` SHA equals the merged parent's `headRefOid`, and after
  `git fetch origin`, `git rev-list --count --no-merges origin/<child-branch>..origin/<default>` prints `0`.
  A child that isn't current gets a refresh task on the child's branch. The refresh merges
  `origin/<default>`, reruns the gate, CI, and review, and rewrites the `Built on` line. A refresh that is
  only a clean merge, with CI passing and a fresh review accepting it, keeps Geoff's earlier approval
  (question 3). A refresh with a conflict, a red check, or a review that doesn't accept goes back to him.
  Of two siblings, the one that
  merges second always needs a refresh, because the first one's commits are then on the default branch.
- CI passed. `gh pr checks <n> --repo <r>` exits 0 on the parent and on the child, with the same
  `workstation` exception as the ready check.

`--merge` stays the only merge form, since a squash gives the parent's commits new hashes.

### A parent sent back or rejected

When Geoff sends a parent back, the existing rule launches a fresh session on the parent's branch with his
words. The tick launches no new child of it until it is ready again. A child already built on it goes stale,
and the current check catches it at the merge.

A parent Geoff rejects never merges. His session closes each child's pull request once the child's
session has ended, with `gh pr close <n> --repo <r> --comment "Built on #<parent>, which Geoff
rejected."`. It deletes their branches only with his go-ahead, since the cleanup rule in the settings
covers merged branches alone. A child relaunches from the parent's replacement when that is ready. A
replacement that changes the design is a new spec.

### A restart, a dead session, or a pause

A restart stops the tick's session and every task session. The agent view docs say: "Shutting down or
restarting your machine stops running background sessions." At the next sitting, `claude --resume` on the
chain's session restores the 15-minute loop. Or a new session runs the same launch prompt, because each
tick rebuilds the chain's state from GitHub and `claude agents`. A task killed mid-run reads `stopped` and
may have lost uncommitted work. The sitting note lists it, and relaunching it is Geoff's call.

Auto mode pauses after 3 blocks in a row, or 20 in total over the session's life. A pause halts the chain,
because the tick then waits on a prompt, and the next sitting note says so.

## Limits

- A chain runs one task session at a time on each line of descent. The four-session limit on pavilion counts
  every session working: chains, independent tasks, and the tick's session while a tick runs, so at most
  three task sessions launch beside it.
- The usage ceiling is 85 percent, read before every launch. Over it, the tick launches nothing and the
  sitting note says so.
- The tick runs every 15 minutes and up to 7.5 minutes late ("a recurring task starts each run late by up
  to half the gap to the next run"), so a child launches at most about 23 minutes after its parent is ready.
- A fixed-interval loop expires after 7 days. A goal holds at most 4,000 characters (backlog #96), and the
  child's opening lines add about 500.
- Two failed launches of one task stop its branch of the chain, which keeps the tick under auto mode's 3 in
  a row.
- Each task keeps its time clause at twice its minutes.

## Approaches

What starts the next task:

| Option | Label | Trade-off |
| --- | --- | --- |
| A `/loop 15m` tick in the session Geoff leaves open | Assembled | One session holds the chain. A restart stops it until the next sitting. Each tick costs a Sonnet turn. |
| A systemd timer and a Bash script (Geoff's 2026-11-20 pick) | Assembled | Survives a restart. It needs dependency logic and the ready check in a script, a login environment, and a way to handle a refused launch. A restart stops the task sessions anyway. |
| The task session launches its child as it ends | Assembled | No extra session. A `claude --bg` from a non-interactive session was refused today as `[Unsanctioned Communication]`, and "A session that starts other sessions stops each one before it ends" forbids it. |
| A Monitor watch | Documented | It times out at 30 minutes and sends one notice, so a long task outlasts it. |
| A cloud or Desktop scheduled task | Documented | A cloud task gets "a fresh clone" with no local files. Claude Desktop isn't installed here. |

The pick is the `/loop` tick. A timer buys a restart that the task sessions don't survive, at the cost of a
new script.

How a child's branch starts from its parent:

| Option | Label | Trade-off |
| --- | --- | --- |
| Launch as today with `baseRef` `fresh`, then merge `origin/<parent-branch>` | Assembled | No change to the launch line. A merge loses nothing, so no classifier rule is needed. |
| `claude --worktree "#<parent PR>"` | Documented | The probe made branch `worktree-pr-27`, so two children of one parent would share a name, and reusing a name reopens the worktree. |
| `git reset --keep origin/<parent-branch>` in the fresh worktree | Assembled | A clean start, but a reset was refused as `[Irreversible Local Destruction]` on 2026-11-01. |
| A worktree made by hand on the parent's branch | Documented | "A session that starts inside a worktree someone else made asks before it commits." |
| GitHub's stacked pull requests, `gh stack` | Documented | It keeps a stack by rebasing: "The commit history is linear. If it isn't, run `gh stack rebase` first." (<https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-stacked-pull-requests>). A rebase rewrites history, the kind of step the reset row shows refused. |

The pick is the merge.

## Mechanisms and their sources

- The base change is documented on GitHub's "Merging a pull request" page
  (<https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/merging-a-pull-request>):
  "If a head branch is deleted after its pull request is merged, GitHub checks for any open pull requests
  in the same repository that specify the deleted branch as their base branch. GitHub automatically
  updates any such pull requests, changing their base branch to the merged pull request's base branch."
  The changelog (<https://github.blog/changelog/2020-05-19-pull-request-retargeting>) says the same.
  `workstation` and `cairn-cms` delete a branch on merge, and `dubplate` and `cc-desk-scratch` don't, so
  there the deletion is step 4's `git push origin --delete`.
- The base change reruns no CI, which is documented. GitHub's events page
  (<https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows>) says:
  "By default, a workflow only runs when a `pull_request` event's activity type is `opened`,
  `synchronize`, or `reopened`." The current check is what makes the old run stand, and step 1 records
  what `gh pr checks` shows after the base change.
- `/loop` is documented (<https://code.claude.com/docs/en/scheduled-tasks>). "Tasks only fire while Claude
  Code is running and idle." "Backgrounding the session carries `/loop` tasks over to a background
  session, which keeps running without a terminal." On `--resume`, "Claude Code restores tasks scheduled
  with `CronCreate`", and a self-paced loop isn't restored, so the tick uses a fixed interval. A fixed
  loop is stopped by asking Claude to cancel it, through `CronDelete`.
- `worktree.baseRef` takes only `fresh` or `head`, documented on the worktrees page: "You can't set
  `worktree.baseRef` to a branch name. To start a worktree from a specific existing branch, create it with
  git directly."
- The agent view states `working`, `blocked`, `done`, `failed`, and `stopped` are documented, and
  `claude agents --help` today says `--all` "With --json: also include completed". Each entry today
  carries `cwd`, `id`, `kind`, `name`, `sessionId`, `startedAt`, and `state`, with no branch, and a task
  session's `cwd` is its worktree.
- Auto mode is documented on the permission modes page: "if the classifier blocks an action 3 times in a
  row or 20 times total, auto mode pauses and Claude Code resumes prompting."

## Assumptions

- The tick's `claude --bg` is not refused when Geoff isn't typing. This is the least proven, so step 1
  tests it first. Today a `claude --bg` from this non-interactive subagent was refused as
  `[Unsanctioned Communication]`. The 2026-11-17 refusal in `dubplate` read "Classifier unavailable". If
  step 1's launch is refused, task 1 puts the auto mode line in "Questions for Geoff" under its
  `## Before merge`.
- The child's merge start works. A probe in a scratch repo, with a branch made from the default branch,
  then `git merge --no-edit origin/parent`:

  ```text
  same: Updating a1eb9b2..c3406da | parents of HEAD: 1
  moved: Merge made by the 'ort' strategy. | parents of HEAD: 2
  ```

- `/usage` reads cheaply. `claude -p "/usage" --model haiku < /dev/null` printed, today:

  ```text
  Current week (all models): 67% used · resets Nov 27, 11pm (America/Anchorage)
  Current week (Fable): 100% used · resets Nov 27, 10:59pm (America/Anchorage)
  ```

- The new `task-score` fields leave `task-report` working. Its `_score_values` reads only its six keys
  and ignores the rest.
- `gh pr checks` in a repo with no PR CI: `gh pr checks 269 -R glw907/workstation` printed
  `no checks reported on the 'cairn-pass-reshape' branch` and exited 1 today.
- `claude-git-guard` passes `gh pr edit --base` through. Fed
  `gh pr edit 31 --repo glw907/cc-desk-scratch --base main`, it printed nothing and exited 0. Fed
  `gh pr merge 31 ... --merge`, it answered `ask` as before.

## Files

Searches, run across `~/.dotfiles/claude` and `~/.dotfiles/bin` with `--exclude-dir=worktrees`:

- `grep -rIl "another task's branch"`: 2 files. `building-from-specs/SKILL.md:34` changes. The other is an
  evaluation result record, dismissed.
- `grep -rIl "waits until that work has merged"`: 4 files. `SKILL.md:35` changes. The other three are evaluation
  results, dismissed.
- `grep -rIl "baseRef"`: 30 files. `SKILL.md:42` and `:47` stay. The launch line is unchanged.
  `settings.json:8` (`head`, the global default), `docs/claude-tooling.md:55`, and
  `bin/.local/bin/model-review-notify:49` stay. `evals/evals.json:12` stays, since it asserts `fresh`. The
  other 25 are evaluation results, dismissed.
- `grep -rIl "gh pr merge"`: 49 files. `SKILL.md:146` gains the three checks before it.
  `settings.json:176` and `bin/.local/bin/claude-git-guard` stay. `survey/releasing.md:22,31`,
  `evals/evals.json:40`, and the evaluation results are dismissed.
- `grep -n "task-score" SKILL.md`: 1 hit, line 131, which gains the three ready fields.
- `grep -n "the task it waits for" references/writing-a-spec.md`: 1 hit, line 44, which changes to "the
  task it builds on" and gains the chain's merge order.

Task 1 edits `claude/.claude/skills/building-from-specs/SKILL.md`: lines 34 and 35, a new section
"Chains" after "A session at work", "The pull request", and "Merging". It also edits
`claude/.claude/skills/building-from-specs/references/writing-a-spec.md` at line 44.

## Commands against the denials log

`~/.local/state/claude-denials.jsonl` holds 152 rows, all from the last 30 days.

| Command | Refusals | Reading |
| --- | --- | --- |
| `claude --bg` | 2 | 2026-11-17 "Classifier unavailable"; 2026-11-22, the probe for this spec, run from a subagent, `[Unsanctioned Communication]`. Step 1 tests the tick. |
| `claude agents` | 3 | Each one rode with `claude stop` in a compound command. The tick runs `claude agents --json --all` alone. |
| `gh pr view`, `gh pr checks` | 2 each | Both rode with a merge (`[Merge Without Review]`). The tick never runs them beside a merge. |
| `gh pr close` | 1 | 2026-11-07, server classifier, no reason. It runs only on Geoff's rejection, at his sitting. |
| `git fetch`, `git merge`, `gh pr create`, `gh pr edit`, `gh pr list`, `/usage` | 0 or 1 | The one `git fetch` rode with a push to `main`. |

## Step 1: the stub chain, in Geoff's session

This step comes before task 1, because it tests the least-proven assumption. It runs in
`~/Projects/cc-desk-scratch` (public, CI `gate` on `pull_request`, `claude-worktree-busy` exited 0 today).
Geoff starts a session there on Sonnet at medium with the step's launch prompt. "The tick" in this spec
stands in for the skill section until task 1 lands. The session first launches `chain-proof-a`:

```bash
claude --bg --name chain-proof-a --model sonnet --effort low --permission-mode auto \
  --settings '{"permissions":{"denyInsteadOfPrompting":true},"worktree":{"baseRef":"fresh"}}' \
  '/goal <the chain-proof-a goal below>'
```

The goal sits in single quotes because it holds backticks and double quotes and no apostrophe. The tick
passes `chain-proof-b`'s goal, which has an apostrophe, through a here-document with a quoted delimiter, so the shell runs none of
its backticks.

Then it arms the tick:

```text
/loop 15m Run one chain tick for /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md, by its section "The tick", for the chain chain-proof-a then chain-proof-b in glw907/cc-desk-scratch.
```

Both stub tasks run on Sonnet at low. Their minutes are 20 each and their clause 40. No like task is
measured. In both goals, `<n>` is the number of the pull request the task opened.

`chain-proof-a` goal:

```text
Build task chain-proof-a of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md, section "Step 1", by building-from-specs. Create the directory chain/, write chain/a.txt holding the one line `a`, and commit it. Done when: 1. `cat chain/a.txt` prints the one line `a`. 2. `bash scripts/gate.sh` exits 0. 3. `gh pr checks <n> --repo glw907/cc-desk-scratch` lists `gate` as pass. 4. A fresh standards:diff-reviewer accepts the diff with 0 open findings, and the pull request is ready with the body building-from-specs "The pull request" names, its task-score comment also carrying `"verdict":"accept","openFindings":0,"unmet":0`. Or stop after 40 minutes.
```

`chain-proof-b` goal, its parent values filled in by the tick:

```text
Build task chain-proof-b of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md, section "Step 1", by building-from-specs. It builds on pull request #<parent> (branch <parent-branch>, head <parent-sha>). Before any edit, run `git fetch origin <parent-branch>` and `git merge --no-edit origin/<parent-branch>`. On a conflict, run `git merge --abort` and end, listing the conflicting files. Stop unless `git merge-base --is-ancestor <parent-sha> HEAD` exits 0. Open the draft pull request with `gh pr create --draft --base <parent-branch>`, and make the body's first line `Built on #<parent> at <parent-sha>.` The review reads `<parent-sha>..HEAD`. Write chain/b.txt as the line `a` from chain/a.txt plus the line `b`, and commit it. Done when: 1. `cat chain/b.txt` prints `a` then `b`. 2. `bash scripts/gate.sh` exits 0. 3. `gh pr view <n> --repo glw907/cc-desk-scratch --json baseRefName --jq .baseRefName` prints <parent-branch>. 4. `gh pr checks <n> --repo glw907/cc-desk-scratch` lists `gate` as pass. 5. A fresh standards:diff-reviewer accepts `<parent-sha>..HEAD` with 0 open findings, and the pull request is ready with the body building-from-specs "The pull request" names, its task-score comment also carrying `"verdict":"accept","openFindings":0,"unmet":0`. Or stop after 40 minutes.
```

The stub pull requests merge only at Geoff's sitting, on his typed approval by number, by "Merging" and
this spec's "Merging a chain".

Done when:

1. A tick launched `chain-proof-b` with no message from Geoff after `chain-proof-a`'s pull request went
   ready. The session's transcript shows the launch inside a loop turn, and
   `claude agents --json --all` lists `chain-proof-b`. Today
   `claude agents --json --all | grep -c chain-proof` prints `0`.
2. `chain-proof-b`'s branch holds `chain-proof-a`'s head.
   `git -C ~/Projects/cc-desk-scratch merge-base --is-ancestor <a-sha> origin/<b-branch>` exits 0. Today
   `git ls-remote origin 'refs/heads/*chain-proof*'` prints nothing.
3. After Geoff approves `chain-proof-a` by number and the session merges it and runs
   `git push origin --delete <a-branch>`, the session reads
   `gh pr view <b> --repo glw907/cc-desk-scratch --json baseRefName --jq .baseRefName` every 5 seconds for
   up to 60 seconds, with a Monitor until-loop, and it prints `main`. The record shows each read, all before
   any `gh pr edit`.
4. `git rev-list --count --no-merges origin/<b-branch>..origin/main` prints `0`. The session records what
   `gh pr checks <b>` lists after the base change.
5. After Geoff approves `chain-proof-b` by number and the session merges it,
   `git -C ~/Projects/cc-desk-scratch show origin/main:chain/b.txt` prints `a` then `b`.
6. The tick cancelled the loop and wrote the sitting note.

The session records the results in `research/2026-11-22-task-chains/step-1.md` in this initiative, with
each command's output, and commits that file directly to `~/Projects/initiatives`. If done item 1 fails
because the classifier refused the launch, the record quotes the refusal, and task 1 carries the auto mode
line.

## Task 1: write chains into `building-from-specs`

The task builds in `glw907/workstation`. It launches from `~/.dotfiles` with `--name task-chains`, on the
branch Claude Code makes for that session. It waits for step 1 and copies this spec's "How a chain runs"
and "Limits" into the skill in the agent-facing register (`~/.claude/docs/voice/agent-facing.md`), with
step 1's results in place of this spec's assumptions. Lines 34 and 35 become: "A task starts from the
default branch, or from its parent's branch when the spec says it builds on that task ("Chains")." In the
goal, `$S` stands for `claude/.claude/skills/building-from-specs/SKILL.md` and `chains` for
`sed -n '/^## Chains$/,/^## /p' $S`.

The task also replaces approval by number (Geoff, 2026-11-23: "the approval-by-number ceremony is fairly
useless, since the number tells me little and makes it hard to know what I'm approving"; he chose to fold
the change into this task). "Merging" then says this: Geoff approves a merge in his terminal, in the session
he is talking to. That session asks about each ready pull request by what merging it changes, in plain
words, with its CI and review results. The number appears only as a link. His answer of "Merge" for that
pull request approves it. "Send back" launches a fresh session on its branch with his words, by the
existing rule. Another session's message approves nothing, and the `ask` prompt on `gh pr merge` stays.
The same change reaches every place that states the old rule: `$S` lines 3 (the description), 13, and 142,
`claude/.claude/CLAUDE.md:14`, `claude/.claude/skills/survey/releasing.md:21` and `:30`, and
`MERGE_REASON` in `bin/.local/bin/claude-git-guard:57-61`. No test asserts the guard's text. The six
archived plans under `docs/plans/archive` that say "by number" are records and stay.

Goal:

```text
Build task task-chains of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md by building-from-specs, with dotfiles-pass for the gate and checks. Read the spec's step 1 record in /var/home/glw907/Projects/initiatives/claude-config-alignment/research/2026-11-22-task-chains/step-1.md first; if it is missing, stop before any edit and report that. Below, $S is claude/.claude/skills/building-from-specs/SKILL.md, and "in Chains" means piping `sed -n '/^## Chains$/,/^## /p' $S` to the grep. Done when: 1. `grep -c "never from another task's branch" $S` prints 0. 2. `grep -c '^## Chains$' $S` prints 1. 3. In Chains, each of these prints 1 or more: `grep -c -F '/loop 15m'` (the tick), `grep -c -F 'merge-base --is-ancestor'` (the child's start), `grep -c -F '"openFindings":0'` (the ready check), `grep -c -F 'gh pr close'` (a rejected parent), `grep -c -F 'sends a parent back'` (a parent sent back), `grep -c -F 'claude --resume'` (a restart), and `grep -c -F '/usage'` (the limits). 4. `sed -n '/^## Merging$/,/^## /p' $S | grep -c -e baseRefName -e 'rev-list --count --no-merges'` prints 2 or more. 5. `grep -c '"openFindings"' $S` prints 2 or more, the second in "The pull request". 6. `grep -c "the task it builds on" claude/.claude/skills/building-from-specs/references/writing-a-spec.md` prints 1. 7. `wc -l < $S` prints 250 or fewer. 8. `bash scripts/gate.sh` exits 0 from the worktree root, and `claude-tooling-sync verify` passes. 9. If the step 1 record shows a refused launch, the pull request's `## Before merge` carries the spec's auto mode line for Geoff's session to apply. 10. `grep -c -i 'by number'` prints 0 for each of $S, claude/.claude/CLAUDE.md, claude/.claude/skills/survey/releasing.md, and bin/.local/bin/claude-git-guard. 11. `sed -n '/^## Merging$/,/^## /p' $S | grep -c -e 'Send back' -e 'what merging it changes'` prints 2 or more. 12. A fresh standards:diff-reviewer accepts the branch against the spec with 0 open findings, and the pull request is ready. Or stop after 150 minutes.
```

Today, items 1 to 6 print `1`, `0`, `0` for each grep, `0`, `0`, and `0`, and item 7 prints `178`. Item 10 prints `3`, `1`, `2`, and `1`, and item 11 prints `0`. The
gate on a clean clone of `main` at `17e6031d` ran 42 legs and failed one, `tellgrader`, with four
`internal/posthook` tests. That is backlog #29: those tests fail in a checkout under `/tmp`, where the
clone sat. A task worktree sits under `~/.dotfiles/.claude/worktrees`.

Reviewers: `standards:diff-reviewer`. The skill is an unattended path (`dotfiles-pass` "Paths"), so it takes
a pull request. Minutes: 75 (the measured median actual path for `workstation` is 45, plus a gate's p90 of
13, plus 15 for the approval change), so the clause is 150. Model: Sonnet at high. Waits for: step 1.

The auto mode line, used only if step 1 shows a refused launch. Geoff allowed it on 2026-11-23 (question 2).

```text
Launching the next task of an approved spec from that spec's chain tick is routine (Geoff, 2026-11-23). In the session that holds a `/loop` chain tick, this covers `claude --bg` from the main checkout of a repo under /var/home/glw907/Projects or /var/home/glw907/.dotfiles, with the launch line building-from-specs "Launching a task" gives, for a task the tick's spec names. It clears Unsanctioned Communication for that launch only. It does not cover a task the spec doesn't name, a stop, or a merge.
```

## Merge order

Step 1's two stub pull requests merge first, in chain order, during step 1. Task 1's pull request
merges after. Then `dotfiles-pass` "After a merge" runs, and, if the auto mode line landed,
`claude-tooling-sync apply` and `verify`.

## Backlog sweep

Scoped to chains, against `~/.dotfiles/BACKLOG.md` (65 open items):

- #86, a `## Before merge` step between the pull requests of one merge document: done. The process of
  2026-11-20 merges one pull request at a time, and "Merging" step 1 runs that pull request's commands
  first.
- #95, restart a background session that stops on an API error: keep. The tick stops a `failed` or
  `blocked` task's branch of the chain and names it, and the restart stays #95's.
- #96, the 4,000-character goal cap and refused launches: keep. This spec cites the cap. Its fix names
  `pass-core` files that are gone, so reword it at its next sweep.
- #102, merge spellings the guard misses: keep. Nothing here changes the guard.

## Found, not in scope

- `~/Projects/cc-desk-scratch` holds 25 leftover worktrees from the 2026-11-19 and 2026-11-20 desk runs,
  plus open pull requests 5 and 6.
- `claude stop` was refused 8 times in 30 days, which leaves a session that starts others unable to stop
  them.

## Questions for Geoff

1. Answered on 2026-11-22: the open session starts the next task on its 15-minute tick, in place of the
   systemd timer of 2026-11-20. Geoff chose "Open session (Recommended)".
2. Answered on 2026-11-23: yes. If the stub chain shows the overnight launch refused, task 1 adds one auto mode
   line that lets the open session launch the next task of an approved spec, covering only a task the spec
   names and never a stop or a merge. Geoff chose "Yes, add the line (Recommended)".
3. Answered on 2026-11-23: yes. A refresh that is only a clean merge of the main branch, with CI passing and a
   fresh review accepting it, keeps Geoff's earlier approval. Geoff chose "Keep my approval (Recommended)".
4. Answered on 2026-11-23: the chain stops launching at 85 percent of the week's usage. Geoff chose
   "85 percent (Recommended)".
5. Answered on 2026-11-23, after step 1: task 1 also replaces approval by number with an ask that names
   each pull request by what merging it changes. Geoff chose "Fold it into task 1 (Recommended)".

## Calls Claude made

- This spec is written on Opus at high, because Fable read 100 percent of its week. The process says specs
  are written on Fable.
- The tick runs in a Sonnet session, so overnight ticks don't spend Fable.
- The stubs run on Sonnet at low, because the skill says Haiku "reads and never decides".
- The tick interval is 15 minutes, which keeps a child's start within about 23 minutes of its parent's ready.
- The child starts by merging its parent's branch, not by a reset, a PR-number worktree, or `gh stack`.
- A child builds on a parent only when it needs the parent's work, so a rejected parent's children wait
  for its replacement rather than restart from the default branch.
- The base, current, and CI checks live in the skill's "Merging" steps, not in `claude-git-guard`, because
  the guard parses only the command by design and the `ask` prompt already puts each merge before Geoff.
- The ready check reads fields in the `task-score` comment, not the body's prose.
- A refreshed child that is only a clean merge, with green CI and an accepting review, keeps Geoff's
  approval. Any other refresh goes back to him (question 3).
- No chain state file: the pull requests and `claude agents` hold it, so a new session rebuilds it.
- The proof uses `glw907/cc-desk-scratch`, which has PR CI and no branch delete on merge, the same as
  `dubplate`.
- No evaluation case is added. The existing cases assert `fresh` and `--merge`, which stay, and step 1 is the
  measure.
- Restarting a failed or stopped task session stays with backlog #95 and Geoff.
