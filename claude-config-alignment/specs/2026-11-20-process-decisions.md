# What Geoff decided about the process on 2026-11-20

This is a record, and nothing is built from it. Geoff and a design session spent 2026-11-20
working out what cc-desk should become. The work split into three specs, and the first one
(`~/Projects/cc-desk/docs/specs/2026-11-20-core-design.md`) leaves the development process as it
is. Everything below was decided for the second spec, which replaces the process. The session
that designs it starts here and doesn't ask these questions again.

One ruling came after the core design was approved. Geoff asked whether work that replaces the
pass process should be planned under it, then asked for the smallest change that unhooks it.
Pull request 253 in the dotfiles repo adds one sentence to the global `CLAUDE.md`: cc-desk's
spec work is exempt from the pass process, and every other repo keeps it. All three specs are built by
Claude Code's documented flow, a fresh session working from the spec with a written definition
of done.

A line marked "decided" is Geoff's and holds unless he reopens it. A line marked "proposed" is
one he has seen and hasn't ruled on. A line marked "Claude's pick" is a call the design session
made.

This record moved from the `cc-desk` initiative to `claude-config-alignment` on 2026-11-20, after
Geoff set the scope under "Alignment comes first". Where a section names the process spec or the
third spec, the alignment spec takes the workstation's part and a later cc-desk spec takes the
rest.

## The three specs

Geoff agreed to this order, one spec at a time.

1. **The core.** The global `CLAUDE.md`, the settings, the hooks, and the path rules. It changes
   their shape and what enforces them, and it leaves the process rules meaning what they mean
   today, because cairn and dubplate are running under the old process.
2. **The process.** New process skills written to Anthropic's standard with evaluations, a timer
   script, the hooks, a page that only reads, the removal of cc-desk's Go, the sidebar, and the
   rename.
3. **The other skills.** About 40 skills, the agents, the docs, and the project `CLAUDE.md`
   files, each checked against Anthropic's checklist with evaluations. Geoff: "So this should be
   deeper than just a renaming."

Geoff replaced this order later the same day. "Alignment comes first" has the order that holds.

## The workstation comes first

Decided on 2026-11-20, in four messages to the session that designs the process spec:

- "Also, since we're fully changing how development works here, should this effort live in
  initatives? It'll cross every repo." The decisions record and the research moved to the
  initiatives repo that day.
- "And probably the first thing we need to do is to fully update the workstation claude
  infastructure before we change anything else."
- "The cc-desk web UI is fully secondary to getting the workstation set up with the new
  standard."
- "The first goal is workstation-wide correct claude infastructure. Once that's complete we can
  work on the web status interface."

So the whole workstation configuration reaches the new standard before the page is touched.
What follows inside that goal is Claude's pick, played back to him and open to his
correction. The process pieces land first
(process skills, hooks, per-launch settings, the timer script, the merge rule). The rest of the
workstation's skills, agents, and docs follow, built under the new process as its longer
trial, and the standards plugin counts as workstation configuration because every session on
the machine loads it. cc-desk's page, the removal of its Go, the sidebar, the project
`CLAUDE.md` files, and cairn's and dubplate's move come after that. Until the page is rebuilt,
agent view is where his sitting opens. The next section replaces that pick.

## Alignment comes first

Decided on 2026-11-20, in four more messages:

- "What's the anthopic standard? Our first effort is to get general worksation infastructure
  aligned." He asked it when the session offered two ways to handle a task built on a parent whose
  review found faults. The docs have no standard for that case, and both options were the
  session's inventions.
- "Again, the first tast is setting up the worksation infra. We can worry about everthing else
  after that."
- "We'll align with anthropic/community best practices at the workstation level and then work
  from there."
- "Should we restart this effort from the initatives repo since it touches all projects?" The
  effort got a record of its own, `claude-config-alignment`, and a fresh session in
  `~/Projects/initiatives` carries it on.

So the first spec is the alignment spec. It brings the workstation's Claude configuration into
line with Anthropic's docs, and with well-cited community practice where the docs are silent.
Community practice carries a label of its own and its source. How cc-desk works is decided
afterward, from what the aligned workstation provides.

Claude's reading, which he hasn't ruled on:

- The alignment covers the global `CLAUDE.md`, the settings, the hooks and their scripts, the
  skills, the agents, the rules, the docs, the MCP servers, the memory, and the standards plugin.
- The process skills are workstation configuration, so the alignment replaces them with the
  documented flow. The timer script that starts the next task is not part of it. His pick of
  option 1 under "The shape he picked" stands and is taken up afterward.
- The session stops bringing him questions about later work. It looks up the standard before it
  frames a choice, and where a docs page makes a question go away it says so and doesn't ask.

## Parked until the workstation is aligned

Each of these was on the list to ask Geoff. None is dropped. One comes back when a spec needs its
answer.

- Whether a task may build on another task's branch, and what happens when the parent's review
  finds faults. Claude's call until he rules: tasks are independent and start from the default
  branch. The best-practices page describes only that: "When you have separate pieces of work
  going at once, give each its own checkout so the edits can't collide." The settings reference
  says `worktree.baseRef` branches a worktree "from the remote default branch or your local HEAD".
  No page describes a pull request stacked on another. The call removes stacked pull requests, the
  dependency logic in the timer script, the rebase after each merge, and the state of a task whose
  parent was rejected.
- What happens when CI is down for the whole account, and whether the sites and the dotfiles repo
  get pull request CI or a local gate run counts.
- Standing answer 12 against the "Work beyond the scope" row below.
- What the forecast means and what the page keeps.
- Whether a background session may do server work on ward and orpheus.
- Whether the approval-queue repo is archived.
- Whether `standards:running-passes` leaves the published plugin, and where four craft rules go
  that live only in process files. The alignment spec may need both.
- Whether dubplate-pass's taste sections wait for a later spec.
- The three-group sort of his standing rules and the three lists, both still proposed under "His
  standing rules".
- Four probes the research asked for: whether a `--bg` session waits for the usage reset, whether
  `PermissionDenied` fires under `dontAsk`, a respawn with an active goal, and a cold boot.
- Whether spec writing gets a test of its own. On 2026-11-21 Geoff asked whether the skills
  for writing a good spec are in place, since a wrong or ambiguous spec costs more on a long
  run. He was shown what the community does and ruled: "Let's follow best practices and test
  once we have the environment fully set up." Claude's reading: the alignment spec gains no
  spec-writing evaluation, and the test comes after "Retiring the old process" has merged. The
  community practices are the interview into a spec, a separate pass for ambiguity, a fixed
  testable form for each requirement, checks that fail at the start, and a second reader. No
  source found evaluates a spec-writing skill, so such an evaluation is assembled.

## What cc-desk is

All decided.

- cc-desk is a current snapshot of Anthropic's best practice, adapted to how Geoff works. It is
  built to change as Claude Code changes.
- The hard logic lives in the Claude Code configuration: skills, hooks, settings, and prompts.
  Custom code stays as small as possible: a few Bash or Python scripts, systemd timers, and a
  display layer.
- "I don't want to be inventive here. I'd prefer to follow established best practice." Every
  mechanism in a design is labeled documented, assembled from documented pieces, or invented.
- The page is a display on top of the process. It shows progress, reports, and anything that
  might need him. It only reads.
- He uses the forecast and wants it kept. Claude Code produces it.
- Worktrees stay.

## The shape he picked

Decided: "Let's go with option 1."

- Each task runs as a fresh background session in a worktree, under `/goal`, and ends in a pull
  request.
- A Bash script on a systemd timer starts the next task. Hooks record failures. The page's
  server reads files.
- All of cc-desk's Go is deleted (11,654 lines outside tests on 2026-11-20).
- No session merges unattended. Geoff approves green, reviewed pull requests at his sitting,
  and the session he is talking to runs the merges.

Two probes passed on Claude Code 2.1.329. `/goal` works in a `claude --bg` session. A
background session in `dontAsk` mode that meets a refused command carries on and ends `done`
without stalling.

## The words

Decided: Geoff wants Claude Code's words used as much as possible. Asked whether the rename
reaches the names of skills and scripts, he said: "Yes, everything."

| Old word | New word | Source |
| --- | --- | --- |
| round, design | spec | Claude Code docs |
| pass | task | Claude Code docs |
| a pass's tasks | steps | Claude's pick |
| acceptance list | goal | Claude Code docs (`/goal`) |
| executor | session | Claude Code docs |
| conductor | none; the role goes away | decided |

The rename runs as the last task of the process spec, after cairn's and dubplate's current
work has finished under the old names.

## The test

Decided: "Yes, that's the test."

Between two of Geoff's sittings, however far apart, work never stops to wait for him unless it
truly needs him. When he sits down, everything finished is reviewed and ready to merge, with a
report. A run fails in two ways: a session sat idle over something it could have decided, or
one stopped task held up work that didn't depend on it.

Geoff withdrew the eight-hour figure from earlier in the day as a number he had picked
arbitrarily. How long a gap the work can fill belongs with scheduled check-ins, the 1.2 work.

The process spec is judged on one unattended run under the new process. The third spec is a longer, wider
trial. cairn and dubplate move over once that passes too.

## The five stops become documented controls

Decided: "Adopt it in full." No session ever waits on a question.

| Today's stop | What replaces it |
| --- | --- |
| Spending past the plan | A cap ends the session and asks nothing. |
| A step that can't be undone | Permission rules refuse it. The session finishes the rest and lists the step for his sitting. |
| A missing secret | Secrets are gathered before the run starts. |
| Work beyond the scope | The session builds what the goal covers, or ends and says why. |
| A sign-in or data question | The session decides, a second session reviews, and the pull request is flagged for him. |

## His standing rules

Decided: "My standing rules are up for review." and "They also need to be considered in light
of this change." On 2026-11-20 there were 87 dated rulings in the configuration and 12 numbered
standing answers in `pass-core`.

Proposed, and not yet ruled on:

- The rules sort into three groups. Rules about the old process go away. Rules about what he
  wants become a documented control. Rules of taste and rules about the machine are checked in
  the third spec.
- He gets three lists he can overrule line by line: the lessons, his standing rules, and the
  infrastructure.

## The four groups

Decided on 2026-11-20: "yes, take the four names as they are." His sitting opens on agent
view's groups, in its order: `Ready for review`, `Needs input`, `Working`, and `Completed`. The
names are documented, and the mapping below is assembled.

- `Ready for review` holds every task with an open pull request. A row is marked `Important`,
  Code Review's word, only when the reviewer found a bug that should be fixed before merging. A
  pull request that carries a sign-in or data decision gets a plain "decision" note.
- `Needs input` holds finished work with a refused step listed for him. No session waits there.
- `Working` holds what is still running.
- `Completed` holds merged, failed, and stopped tasks together, as agent view does. A failed
  task carries agent view's state word `Failed` and sorts to the top of the group.

These replace the earlier proposal ("Ready to merge", "Read before merging", "Couldn't finish",
"Held for you").

## How a pull request merges

Decided on 2026-11-20: "yes, take the ask rule, so long as it follows anthropic standards,
since our first goal is to get the workstation claude infastructure in order."

- The session Geoff is talking to runs `gh pr merge` for the pull requests he names, and an
  `ask` rule stops it at a permission prompt each time. He confirms once per pull request.
  Documented: the permissions page says an `ask` rule prompts "even in `auto` mode and without
  a time limit", and the probe of 2026-11-18 in cc-desk's `docs/research/` saw it.
- Background sessions run in `dontAsk` mode, which denies every call that would prompt, so none
  of them merges. Documented.
- The docs say a rule matches the command text and "isn't a security boundary around the
  program", so the REST form of a merge gets a rule of its own.
- This retires `approval-queue land`, its allow rule, its auto-mode entry, and the merge half
  of `claude-merge-guard`.
- His condition stands for every part: a piece that no Anthropic page describes is labeled
  assembled or invented in the spec, and he sees the label before he approves.

## The budget caps

Decided on 2026-11-20: "yes, drop the 85 percent check". He was asked whether his words of
2026-11-18, that usage isn't a limit for him, still held well enough to drop it.

- The new process reads no usage figure before a launch. A session that reaches the usage
  limit pauses and resumes at the reset. That is documented for an interactive session.
  Whether a `--bg` session waits the same way is a probe the spec owes, and the check comes
  back if it doesn't.
- The cost he accepted: if the week runs out, the session at his sitting pauses with the
  background ones until the reset, or until he resets usage himself.
- The rule that today's sessions on pavilion share (four working sessions, none past 85
  percent) is separate. It holds until the new process replaces it.

Claude's proposal for the time cap, shown to him in the same message and not corrected:

- Each task's goal carries a time clause at twice its planned minutes. The goal page documents
  "a turn or time clause in the condition". The checker model judges the clause, so it is not
  a hard timer.
- At the cap the session ends, writes what is left into its pull request, and asks nothing.
- The timer script does not call `claude stop` on a deadline (assembled) unless the trial run
  shows a session running past its clause.
- No spec has a cap. The old round cap stopped tasks that had nothing to do with the one
  running long.

## What the process spec owes

- A table with one line for every row in
  `~/Projects/cc-desk/docs/follow-ups/desk-round-lessons.md`, with an answer on both sides
  (cc-desk and the process text).
- The process-skill text, landed through a pull request in the dotfiles repo.
- Estimates priced from measured minutes.
- The sidebar is candidate A (`~/Projects/cc-desk/docs/design-benchmark/sidebar-headings/`). Decided.
- On pavilion, cc-desk goes first when four sessions are working. Decided.
- The process spec is the bar cairn and dubplate join cc-desk at. The Move design
  (`~/Projects/cc-desk/docs/specs/2026-11-19-move-design.md`) is rewritten after it.

The core spec hands over one more list: every item it left alone because the old process still
relies on it, with what the process spec should do about each. That list is in the core design
under "Left for the process spec".

The alignment spec takes the first three items above and the core spec's list. The sidebar and
the Move design wait with cc-desk.

## Still to ask Geoff

One question, asked once at the end of the design work: where the 1.2 work (scheduled
check-ins) comes against the rewrite of Move. The answer goes in `STATUS.md`.

## What was read

The design session read these Claude Code documentation pages first-hand on 2026-11-20: best
practices, `/goal`, skills, the skill-authoring checklist, memory and `CLAUDE.md`, permission
modes, permissions, and auto-mode configuration. A session that leans on one of them reads it
again, because the pages change.

The earlier draft (`2026-11-20-1.1-design.md` and
`2026-11-20-1.1-pass-core-edits.md`, both in `~/Projects/cc-desk/docs/specs/`) is set aside. Nothing
in it was built.
