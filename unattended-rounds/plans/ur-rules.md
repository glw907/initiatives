# Overhaul run rules

Every session in rounds `ur-queue`, `ur-ws`, and `ur-std` reads this file. The skills don't hold
the round rules yet, because these rounds are what writes them there. Until a round ends, this
file and the two designs are the rules.

Order of authority: `ur-rulings.md` (Geoff's answers), then this file, then `pass-core` and its
references, then the repo's adapter. Where two disagree, the earlier one wins.

## Paths

`R` stands for `~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds`.

| What | Path |
| --- | --- |
| Geoff's answers | `R/plans/ur-rulings.md` |
| Approved round design | `R/specs/2026-11-11-unattended-rounds-design.md` |
| Build design | `R/specs/2026-11-11-unattended-rounds-build-design.md` |
| Change-site leads (unverified) | `R/plans/ur-change-sites.md` |
| Round reports | `R/reports/<round>-report.md` |
| Packet files | `R/packets/<round>-<pass>-<kind>/` |

| Round | Repo | Checkout | Conductor |
| --- | --- | --- | --- |
| `ur-queue` | `glw907/approval-queue` | `~/Projects/approval-queue` | `conductor-approval-queue` |
| `ur-ws` | `glw907/workstation` | `~/.dotfiles` | `conductor-dotfiles` |
| `ur-std` | `glw907/standards` | `~/Projects/standards` | none |

Every default branch is `main`. Pass `<p>` (`q1` to `q4`, `w1` to `w5`, `s1`) uses the worktree
`<checkout>/.claude/worktrees/ur-<p>` on branch `ur-<p>`. Its plan is
`docs/plans/2026-11-11-ur-<p>-plan.md` and its executor prompt
`docs/plans/2026-11-11-ur-<p>-prompt.txt`, both on that branch. Its executor is named
`<project>-ur-<p>` and its planner `<project>-ur-<p>-plan`, where `<project>` is
`approval-queue`, `dotfiles`, or `standards`.

S1 is the exception. The standards repo's CI scan (`scripts/scan.sh`) fails any tracked file,
and any commit in history, that names a home path, the queue's commands, or Geoff. S1's plan is
`R/plans/ur-s1.md` and its executor prompt `R/plans/ur-s1-prompt.txt`, and neither is ever
committed to the standards repo.

## Every session

1. Read `R/plans/ur-rulings.md` before anything else. It exists only after Geoff approved the
   build design in the Approval Queue. If it is missing, launch nothing, edit nothing, and end
   with the one line your seat ends on (`ROUND END:`, `PASS END:`, or `PLAN END:`) followed by
   `ur-rulings.md is missing`.
2. Never ask Geoff a question in chat and never run `notify-send`. A question only he can answer
   is a stop (see "Stops").
3. Never edit a setting, a hook registration, a permission rule, or an auto-mode entry, and never
   run `stow`, `pkill`, or `kill`. Stop a background command you started with `TaskStop`.
4. When auto mode refuses a command, use the alternative your plan or run sheet names, once. A
   second refusal is a stop. Record each refusal: the command, the reason shown, what you did.
   Two refusals have a rule of their own and don't count here: a `claude stop` ("Stopping a
   session") and the report's push to `main` ("Report").
5. To wait, start a background command (`run_in_background`) and end your turn. Never end a turn
   to wait with nothing running. The `/goal` check is skipped only while a background command or
   a subagent runs, and several turns with no tool use stop the goal loop. If a turn starts
   while your wait still runs, read the state once, start no second wait, and end the turn.
6. Read usage with `claude -p "/usage" --model haiku < /dev/null`. It prints "Current week (all
   models)" and "Current week (Fable)". The overhaul has no 85 percent stop. When the Fable line
   reads 95 percent or more, or can't be read, a seat due to run on Fable 5.2 runs on
   `claude-opus-5-5` at `high`, and the PR's `## Decisions` and the report name it. A subagent
   dispatch for that seat takes `model: "opus"`.
7. Run every `approval-queue` command with
   `APPROVAL_QUEUE_PROJECTS=$HOME/.local/state/unattended-rounds/projects` set. The initiative
   argument is `unattended-rounds`.
8. The three repos are public and the record `R` is local. Write nothing into `R` except the
   report and packet files named above and S1's plan and prompt, and never commit or push in it.
   Copy nothing from `~/Projects/initiatives/.claude/worktrees/workstation-refinement` into a
   repo, a plan, a PR, or a packet. In a repo file, a PR body, and a report, write a home path
   with `~`, inside a quoted command or its output too.
9. A test never touches the live queue: its state directory is a temporary one, never
   `~/.local/state/approval-queue`, and its server port is never 7907.
10. The twelve standing answers are in the approved design, lines 134 to 151. The nine the build
    adds are in the build design, lines 318 to 337. Read both lists in full. Build answer 6
    replaces approved answer 4 for these rounds.

## Planner

A planner plans one pass, starting at `pass-core` "Lifecycle" step 4. The build design's section
for the pass is the approved design: its acceptance list is fixed. You may add a check. You never
edit or drop an item.

1. Work in the pass's worktree by path. Never call `EnterWorktree`. If the worktree is missing
   and your prompt doesn't tell you to cut it, end with one line saying so.
2. Verify each change site against the code as the earlier passes left it. `ur-change-sites.md`
   holds leads from 2026-11-11, and line numbers there have moved.
3. Write the plan to the plan path above, with an `Initiative: unattended-rounds` line, a
   `Round:` line, and a `Pass:` line. If the plan is already on the branch, a planner ran before
   you: revise it to follow each entry under its `## Rulings`, and get a fresh review. Each task
   follows `standards:running-passes` "Plan". Every
   acceptance item from the build design appears verbatim under `## Acceptance`, each mapped to
   the task that meets it and the command or screenshot that will show it.
4. The plan carries a mechanism table. Each row names a probe you ran with its output, or a
   quoted source with its line or URL. No row says "expected".
5. The plan's file list comes from searches. Record each search and its hit count, and list or
   dismiss every hit with a reason.
6. `## Pre-flight` carries three lines. `Permissions checked:` cites your read of the last 30
   days of `~/.local/state/claude-denials.jsonl` against each task's commands, with the log's
   date range and each class found. `Reviewed:` names the plan review. `Evidence:` names the
   mechanism table and the recorded searches.
7. Every stop the plan writes has a standing answer or parks the pass. No stop says "ask Geoff".
   The plan names an alternative for each command the denial log shows refused.
8. Get one `standards:plan-reviewer` read, whatever the class. Fold its findings.
9. Park before any code is written when the plan's path comes out over twice the build design's
   estimate, when the review finds something that changes the design, or when an acceptance item
   can't be planned for as written. To park: commit the plan on the pass's branch, push it, open a
   draft PR that holds the plan alone with the stop in its body, and end.
10. Otherwise commit the plan and the executor prompt on the pass's branch and push. Write the
    prompt in the form under "Executor prompt form". Run the planner reference's launch checks,
    read usage for the seat (rule 6 above), and launch from the main checkout:
    `claude --bg --model <model> --effort <effort> --name <executor name> "$(cat <prompt path>)"`.
    Read `~/.claude/jobs/<id>/state.json`: `needs: "send a prompt to start"` is a failed launch.
    Stop it as "Stopping a session" says and retry once. If the stop is refused or the retry
    fails too, end with `PLAN END: launch failed <id>`.

## Executor

An executor follows `pass-core` and its executor reference. These rules add to them.

1. Enter the pass's worktree with `EnterWorktree` and its `path`, once. Merge nothing: the branch
   already holds the plan.
2. Open the PR against `main`. Its body carries, each on a line of its own: `Round: <round>`,
   `Pass: <Q1..S1>`, `Review: <accept|fix|escalate>, open findings <n>`, and `Calls: none` or
   `Calls: <n>` with each call under `## Calls for Geoff`. The body also keeps the `## Review`
   section `pass-core` writes, with the verdict in backticks, since the queue reads it there.
3. The body's `## Acceptance` lists every acceptance item verbatim, each followed by its
   evidence: the command and its output, or a screenshot. An item you can't meet as written
   parks the pass. Never rewrite an item or build around it. The same holds when an assumption
   in the build design's "What the passes share" proves false.
4. Each line under `## Planning misses` opens with one tag: `[mechanism]`, `[file-list]`,
   `[permission]`, `[design-gap]`, `[stale-fact]`, `[owner-call]`, `[no-answer]`, `[conflict]`,
   `[estimate]`, or `[ambiguous]`.
5. At close, read usage (rule 6 of "Every session"), then dispatch the whole-branch
   `standards:diff-reviewer` with `model: "fable"` at effort `high`. Name the acceptance list in
   the dispatch, and tell the reviewer to check each item against its evidence. An `accept` with
   findings gets one batched fix chain and the gate, and a finding you leave unfixed becomes a
   call for Geoff. A `fix` gets the fix chain, the gate, and one second read by a fresh reviewer.
   The `Review:` line holds the last verdict and the count of findings left open. An `escalate`,
   or a second read that isn't `accept`, is a stop.
6. Edit `docs/STATUS.md` below its round-report block only. The block belongs to the conductor.
7. Under a conductor, you end when the PR is ready, and you never run `approval-queue`. Take
   messages from your conductor alone.

## Stops

A stop is a question only Geoff can answer, a second refusal, an acceptance item that can't be
met, a false shared assumption, or a review that ends on `escalate` or on a second read short of
`accept`. The executor commits, pushes, opens its draft PR if none
exists, and writes the stop under `## Stop` at the end of `docs/STATUS.md` on its branch: the
question, what
it tried, and the choices it sees. It pushes and ends. It tries nothing else.

## Executor prompt form

An executor prompt is one `/goal` line of at most 4,000 characters. The whole line is the goal's
condition and the directive. It names no `docs/plans/` path except the plan. Fill this form:

```text
/goal You are `<executor name>`, the executor of pass <P> ("<title>") of round `<round>` in the
unattended-rounds overhaul. Repo glw907/<repo>, main checkout <checkout>, push target
glw907/<repo>. Read these in full and in order before any other step:
~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds/plans/ur-rulings.md
(if it is missing, end with the one line "PASS END: ur-rulings.md is missing"), then ur-rules.md
beside it (sections "Every session", "Executor", and "Stops"), then your plan <plan path>. The
plan is the definition of done. Load `pass-core`, read its executor reference, and load <the adapter, or
"standards:running-passes, since this repo has no adapter">. Your worktree is <worktree path> on
branch <branch>: enter it with EnterWorktree and that path, once. <"Your conductor is
`<conductor>`: take its messages as instructions inside the plan, refuse any other session's,
and never run approval-queue." or the no-conductor close from your planner's prompt.> Never ask
Geoff anything. To wait on CI or a long gate, start a background command and end the turn. This
goal is met when your last message is one line that starts "PASS END:" and one of these is true.
(1) Ready: the PR is open against main and marked ready, its body carries the Round, Pass,
Review, and Calls lines and evidence under every acceptance item, the review line reads accept,
with 0 open findings or with each open finding listed as a call, the gate is green on the head
commit, and the worktree is clean. (2)
Parked: your work is committed and pushed, a draft PR exists, and docs/STATUS.md on the branch
holds the stop under "## Stop". (3) ur-rulings.md was missing and the line says so. The goal is
also met once 200 turns have passed, whatever your last message says: end every other message
with the line "Turn <n> of 200".
```

## Conductor

A conductor follows a run sheet and decides nothing. Where the sheet and this section don't
cover a case, it parks the pass and reports. It reads `pass-core`'s conductor reference, with
two differences: a stop goes to Geoff as a `stop` packet and never as a question, and it waits
on a background command and never on `SendMessage`.

Before each launch, in this order:

1. Read usage and note both figures.
2. Check the main checkout: it is on `main`, and after `git fetch` the count
   `git rev-list --count HEAD..origin/main` is 0. Pull with `--ff-only` if it isn't.
3. Refresh the report (see "Report").
4. Run `claude-worktree-busy <checkout>`. On exit 1 it has printed its first hit alone, so run
   its three checks by hand, and launch only when each clears.
   - Processes: `pgrep -af <the checkout's real path>`. Each process listed is your own command,
     the queue's server (`node <path>/approval-queue/build`), or `claude daemon run`.
   - Sessions: in `claude agents --json`, every row whose `cwd` is the checkout or under it is
     you, is not live, or is a session of your round whose pass the report lists as ended. A row
     is live when its `state` isn't `done`, `stopped`, or `failed`.
   - Files: `git -C <checkout> status --short` prints nothing.

   Anything else ends launches in the repo, and the report says so.
5. Cut the worktree: `git -C <checkout> worktree add .claude/worktrees/ur-<p> -b ur-<p>
   origin/<base>`. The base is `main`. It is the parent's branch when the parent waits for a
   close packet with its review accepted.
6. Launch the planner from the main checkout:
   `claude --bg --model claude-fable-5-2 --effort high --name <planner name> "$(cat <prompt>)"`.
   Read its `state.json` as the planner rule 10 says.

To wait on a session, take its `id` from `claude agents --json --all`: where several rows share
the name, the one with the latest `startedAt`. Run this in the background, then end the turn:

```bash
timeout 1500 bash -c 'f=$HOME/.claude/jobs/<id>/state.json; n=0; while [ $n -lt 3 ]; do
if jq -e "(.state==\"done\") or (.tempo==\"idle\" and ((.inFlight.tasks // 0)==0))" "$f" >/dev/null 2>&1;
then n=$((n+1)); else n=0; fi; sleep 20; done; echo idle'
```

Exit 124 means the session is still working: start the wait again. `state` alone is not the
signal, since it can stay `working` after a session has finished.

### Stopping a session

Run `claude stop <id>` as a command of its own. If auto mode refuses it, note the refusal in
the report and don't try again. That refusal doesn't count under rule 4 of "Every session":
build design line 366 leaves it to a later design. A seat whose stop was refused is never
launched again under the same name, so a pass that needs that relaunch parks.

### Reading a pass

When the planner is idle, look for the executor by name in `claude agents --json --all`. If it
is listed, wait on it. If it isn't, a draft PR holding the plan alone means the pass parked.
With neither, relaunch the planner, twice at most. After a third idle planner with no plan, no
pass of the round launches again, and the report says so: a stop packet needs a PR to name.

When the executor is idle, read the PR with `gh pr list --repo glw907/<repo> --head ur-<p>
--state all --json number,isDraft,state,body,statusCheckRollup`. Then:

- **Land** when the PR is open and not a draft, `Review:` reads `accept, open findings 0`,
  `Calls:` reads `none`, the body has no `## Before merge` section, no check fails, the plan's
  class isn't `auth-data`, every acceptance item in the build design's list for the pass appears
  under `## Acceptance`, the run sheet doesn't mark the pass as waiting for Geoff, and no earlier
  pass of the round waits for a close packet. Stop the planner and the executor. Then run
  `approval-queue land glw907/<repo>#<n> "<round> <P>: <claim>"`, with `--round <round>` where
  the run sheet says so. The claim stays within 80 characters. Then pull the main checkout and
  run the sheet's after-landing steps.
- **Wait for a close packet** when the PR is ready and the land test fails only on a call, a
  `## Before merge` section, an `accept` with a finding left open, the sheet's mark, or an
  earlier pass that waits. Stop both sessions. The next pass is cut from this pass's branch
  (step 5 above), and it and every later pass of the round join the close packet in place of
  landing. Close packets go out after the round's last pass ends, unless the run sheet sends one
  sooner, with three unforced calls to a packet at most.
- **Park** when `docs/STATUS.md` on the branch holds a `## Stop`, or the PR is a plan-only
  draft. If the branch has no PR, open a draft one from the pushed branch first, with the stop
  in its body: the queue refuses a stop packet that names no PR. Wait for the PR's checks, send
  one `stop` packet through `approval-packet`, stop both sessions, and launch the next pass that
  doesn't depend on the parked one. In one repo every later pass depends on it, so none
  launches.
- **Relaunch** when the executor is idle with none of the above. Stop it and launch it again
  from its prompt, twice at most. A third idle parks the pass. So does a relaunch the launch
  guard denies, and so does a stop auto mode refuses. With no `## Stop` on the branch, the stop
  packet's `reason` says which it was.

Packets follow the `approval-packet` skill. The title, the text headline, and every `land` claim
open with the round id. Every PR's base is `main`. A stop packet carries a forced `gate-failed`
call on a red check or a `fix` or `escalate` verdict, and a forced call on a `## Before merge`
section. Its `steps` list what the session runs after an answer. Run `approval-queue packet` in
the background with no `timeout`, and never kill it. An approved stop packet runs its steps and
relaunches the pass, and never `approval-queue merge`. A sent-back packet is fixed forward and
resent with `--replies`, and every note gets a reply. When a note asks for a change to a PR,
append it under `## Rulings` in that pass's plan, relaunch its executor as after a stop
packet's answer, and resend when the PR is ready again. On an approved close packet, run
`approval-queue merge <id>` as the skill says, pull the main checkout, and run the sheet's
after-landing steps once, for the last pass merged. A PR that Geoff's answer leaves unmerged
stays open, and its row reads `waiting`. The last close packet of a round names
the report's path in a `session` step.

When Geoff answers a stop packet, append his ruling under `## Rulings` in the pass's plan, commit
it on the pass's branch by path, push, and relaunch the executor from its prompt. A plan-only
draft has no executor prompt: relaunch the planner from its prompt instead, and it revises the
plan (planner rule 3). Record the question in the PR's `## Planning misses` and the ruling in
its `## Decisions`.

### Resuming

A conductor that finds its report already written goes down the run sheet's table and enters
each pass at the first of these that matches. Relaunch counts start again at zero.

1. The PR is merged. Run the after-landing steps if the report doesn't show them done.
2. A packet for the pass is open. Run `approval-queue collect <id>` in the background and wait
   on it, since it blocks until Geoff decides.
3. The planner's latest row is live. Wait on it.
4. The executor's prompt is on the branch. If the executor's latest row is live, wait on it.
   Otherwise go to the idle-executor test.
5. The branch exists with no executor prompt. Launch the planner without cutting the worktree
   again. If `git worktree list` doesn't show the worktree, add it with
   `git -C <checkout> worktree add .claude/worktrees/ur-<p> ur-<p>`.
6. Nothing exists. Run the steps under "Before each launch".

The round's clock is the sum of each pass's minutes from its planner's launch to its PR being
ready. Waits on another round or on Geoff don't count. When the clock passes twice the round's
planned minutes, the pass in flight finishes and nothing new starts.

## Report

The report is `R/reports/<round>-report.md`. Write it before every launch, before every wait on
a packet, and at the end. Follow the mockup in the build design, lines 207 to 225:

- A heading line with the round, the repo, and the time written.
- One table row per pass: state (`not started`, `planning`, `running`, `merged`, `waiting`,
  `parked`, `skipped`), PR, planned and actual path minutes, usage before and after.
- Stops, refusals, and calls sent to Geoff, each with its count and one line apiece.
- Planning misses by tag, read from the PR bodies.
- A trials line: how many passes Fable 5.2 planned, how many sessions ran under a `/goal` line,
  and how many of those went idle before a `PASS END:` or `ROUND END:` line.
- Each seat that ran on Opus under rule 6.
- What waits for Geoff, with the queue item id of each open packet, what landed, and
  `Resume from:` with the conductor prompt's path.

After writing the file, copy it into the main checkout's `docs/STATUS.md` as a block directly
under the title line, between `<!-- round-report <round> -->` and `<!-- /round-report -->`, the
block's first line naming the report's path. Do this only while the checkout is level with
`origin/main`. Commit that one file by path and push in a single command:
`git -C <checkout> commit -q -m "<message>" docs/STATUS.md && git -C <checkout> push -q origin
main`. If auto mode refuses it, nothing ran: restore the file with `git -C <checkout> checkout
-- docs/STATUS.md`. If the commit ran and the push failed, undo the commit with `git -C
<checkout> reset --soft HEAD~1` and then `git -C <checkout> checkout HEAD -- docs/STATUS.md`.
Either way make no further STATUS copy in this round, keep the report in `R` alone, and say so
in it. The refusal doesn't count under rule 4 of "Every session". If the undo is refused too,
launch nothing more in the repo, and put the two commands in the report for Geoff.

The report's second line is `Round state: running`, `Round state: waiting for Geoff`, or
`Round state: ended`. The `ur-queue` report also holds a line `Queue live through: <Qn>` or
`Queue live through: none`, naming the last queue pass that is merged, pulled, and restarted.
The other rounds read that line and never write it.

Once the `ur-queue` report reads `Queue live through: Q3` or `Q4`, pass `--round <round>` to
every `land` and put `"round": "<round>"` in every fact file. Once it reads `Q4`, also run
`approval-queue report unattended-rounds <round> <report file>` after each write of a report.

## A pass with no conductor

S1 is the one pass with no conductor. Its planner cuts the worktree itself, after the conductor's
launch steps 1 and 2. Its plan and prompt sit in `R/plans/` (see "Paths"), so four rules change:

- No file the pass commits names a home path, a workstation command, or Geoff. Run
  `scripts/scan.sh` in the worktree before every push. A PR body and a commit message aren't
  scanned.
- A stop goes under `## Stop` in the draft PR's body, since the repo has no `docs/STATUS.md`.
- The PR's heading for calls is `## Calls`, and the PR never names the plan's path. The path
  goes in a packet's fact file alone.
- A planner that parks has no plan to commit. It makes one empty commit on `ur-s1`
  (`git commit --allow-empty`), pushes, opens the draft PR with the stop in its body, and sends
  the `stop` packet itself.

The executor does the conductor's part for its pass once the PR is ready:

1. It waits for the PR's checks with a background command.
2. When the conductor's land test passes, it runs
   `approval-queue land glw907/standards#<n> "ur-std S1: <claim>"` and pulls the main checkout.
   When the test fails on a call or a `## Before merge` section, it sends one close packet
   through `approval-packet` and acts on the decision.
3. On a stop it sends the `stop` packet itself, waits for the answer, records the ruling as the
   conductor would, and goes on from its plan.
4. It writes `R/reports/ur-std-report.md` in the form under "Report", with build standing answer
   5's line: the commit `~/.claude/plugins/cache/glw907-standards/standards/` holds. The
   standards repo has no STATUS file, so the report stays in `R`.

In its prompt, the conductor sentence becomes "You have no conductor: follow ur-rules.md, section
'A pass with no conductor', once the PR is ready." End (1) becomes: the PR is merged, the main
checkout is pulled, and the report is written. End (2) becomes: a close or stop packet you sent
came back with an answer that leaves the PR unmerged, or as a send-back you can't fix forward,
and the report says what waits.
