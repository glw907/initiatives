# Pass S1 plan: three changes to `standards:brainstorming`

Initiative: unattended-rounds
Round: ur-std
Pass: S1

Class `runner`. Repo `glw907/standards`, main checkout `~/Projects/standards`, worktree
`~/Projects/standards/.claude/worktrees/ur-s1` on branch `ur-s1`, cut from `origin/main` at
`896f819`. Path estimate 60 minutes against the build design's 60, so the 120-minute park line is
not reached. The approved design is the build design's section for this pass
(`specs/2026-11-11-unattended-rounds-build-design.md:289-298` in this record).

This file and `ur-s1-prompt.txt` beside it are never committed to the standards repo, and no PR
body, commit, or repo file names this file's path. `scripts/scan.sh` there refuses a tracked file
or a commit that names a home path, a workstation command, or Geoff, and this plan names all
three.

`S` below stands for `plugins/standards/skills/brainstorming`. `R` stands for this record,
`~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds`.

## Pre-flight

No step is Geoff's. The pass needs no secret, sign-in, dialog, setting, or permission rule. The
merge needs push rights on the repo, which the signed-in `gh` account has (Mechanisms, row 19).

Permissions checked: the planner read all 57 rows of `~/.local/state/claude-denials.jsonl`, dated
2026-11-01 to 2026-11-11, against each task's commands. The tasks run the Edit tool on two files
under `S`, `git add`/`commit`/`push` of branch `ur-s1`, `gh pr create|edit|ready|checks|view|list`,
the eight gate commands from `scripts/` and `tests/`, the Agent tool, `claude -p "/usage"`,
`claude agents --json`, `approval-queue land`, `git worktree remove`, `git branch -d`, and at a
stop `approval-queue snapshot` and `packet`. Classes found, with what the pass does about each:
Self-Modification (10 rows, settings edits, `stow`, and two script-driven edits of a loaded
`.claude/skills` file) and the two unexplained refusals of the same skill edit: the pass edits
plugin source with the Edit tool and never by a script, and "Refusals" below names the
alternative. Interfere With Workloads (9 rows, `pkill`, `kill`, `claude stop`): no task runs any
of them. Merge Without Review (3 rows, `gh pr merge` and a checks watch chained to a merge): the
pass merges only through `approval-queue land` and watches checks in a command of its own. One
refused `git push origin HEAD:main`: the pass pushes `ur-s1` alone. Safety Bypass Flag (1 row,
`git commit --no-verify`): never used. Git Destructive (2 rows, a remote branch delete and a
worktree prune): the pass runs `git worktree remove` and `git branch -d` with no force flag, and
a refusal of either leaves the worktree in place with a report line. Auto-Mode Bypass (3 rows, a
workflow dispatch and one `claude --bg` launch): the only launch is the planner's, under planner
rule 10. Classifier unavailable (2 rows): rerun the same command once. The other classes
(Irreversible Local Destruction, Create Public Surface, Unverifiable Deletion Scope,
Sensitive-Source Provenance, Security Weaken, Production Deploy, Secret-Store Writes, DNS, Bot
Check Circumvention, Code from External, Shared Scratch Sweep, Out-of-Place Publication) match no
command in this plan.

Reviewed: one `standards:plan-reviewer` read on 2026-11-11, on Opus at effort medium. Its verdict
was `fix` with 26 findings, and none changes the approved design. All 26 are folded into this
file. One was folded with a correction: the reviewer cited `check-references.mjs:25`, and the
line is 24. After the fold the planner ran checks A1 to A5 in their new form at `896f819`, and
each printed the failing values that task 1 lists.

Evidence: the table under "Mechanisms" (24 rows, each a probe run on 2026-11-11 or a quoted
source line) and the nine searches under "Searches".

## Start

The executor reference's start steps, settled for this pass:

- The repo has no setup command and no STATUS file. Your session's name and id go in the report.
- Don't arm the `/loop` wake-up. No probe shows `/loop` and a `/goal` line running in one
  session, and every wait in this plan is a background command or a subagent whose exit wakes
  you. Put that in the PR's `## Decisions`.
- Take no lid-switch hold. The host is `pavilion`, a desktop with no lid.

## Acceptance

The six items are the build design's, verbatim. Never edit or drop one. Each appears verbatim
under `## Acceptance` in the PR body, followed by its evidence.

1. "The description on line 3 no longer holds "two or three approaches". It names what the body
   does: one question at a time, then a written design for one approval."
   Task 1. Evidence: the output of `sed -n 3p S/SKILL.md` and of check A1.
2. ""Offer recon" becomes a rule to go and look: the skill reads the code, your files, and the web
   without asking, and says what it read. It still asks before a spike."
   Task 1. Evidence: the new paragraph quoted from the file, the spike paragraph quoted, and the
   output of check A2.
3. "The written design's list gains what done looks like: what you would see or run, each item
   able to fail."
   Task 1. Evidence: the cover list quoted from the file and the output of check A3.
4. "The builder check's prompt asks whether any of those items could pass on a wrong result."
   Task 1. Evidence: the prompt block quoted from `S/builder-check-prompt.md` and the output of
   check A4.
5. "A fresh Sonnet subagent, given the changed skill and a one-line request in the standards repo,
   reads the repo before its first question and never asks whether it may look. Its transcript
   shows a file read before the first question mark."
   Task 2. Evidence: the dispatch prompt, the commit each run read, and the output of the
   transcript command for each run.
6. "The repo's CI passes: the plugin check, the path scan, and the 500-line cap."
   Task 3. Evidence: the output of `gh pr checks <n> --repo glw907/standards` showing `validate`
   passed on the head commit, and the local output and exit code of each gate command.

### Added checks

These add to the list and replace nothing.

- Item 5 as written passes on the unchanged skill, because the subagent's read of the skill file
  is itself "a file read before the first question mark" (Mechanisms, row 3). Task 2 therefore
  counts only a read of a repo file outside `S`, requires the reply to say what was read, and runs
  two requests that both fail on the unchanged skill.
- The description keeps its trigger sentence word for word, since the description is what loads
  the skill: "Use when new work's design is not settled yet, or when the user asks to brainstorm
  or think something through."
- The diff against `origin/main` touches exactly the two files the build design names, so the
  entry in `THIRD-PARTY-NOTICES` stays true (check A5).

## Tasks

Run them in order. There is no pair. The path is 20 + 15 + 25 = 60 minutes.

The gate is these eight commands, run bare from the worktree root after each task. Together they
take under five seconds, so there is no separate fast lane.

```bash
claude plugin validate plugins/standards
claude plugin validate .
node scripts/validate-warnings.mjs
scripts/scan.sh
tests/scan-test.sh
scripts/check-skill-lines.sh
tests/check-skill-lines-test.sh
node scripts/check-references.mjs
```

Each must exit 0. Run `scripts/scan.sh` again immediately before every push. The scan reads every
ref, remote branches and the shared stash included, so a hit may come from a commit that isn't
yours. To tell, run
`git log origin/main..ur-s1 -p --format='commit %h' | grep -E '^\+' | grep -vE '^\+\+\+' | grep -nE -f scripts/scan-patterns.txt`:
no output means this pass's commits are clean.

Every push is `git push -u origin ur-s1`. Always name the branch: `ur-s1` tracks `origin/main`
(Mechanisms, row 15). Commit files by path, never `git add -A`.

The PR body lives in one file outside every repo, `"$CLAUDE_JOB_DIR/tmp/ur-s1-body.md"`. Write it
with the Write tool. `gh` prompts for a title and body unless both are passed, and a prompt
stalls an unattended run (Mechanisms, row 20). So open the draft PR on the first push with
`gh pr create --draft --repo glw907/standards --base main --head ur-s1 --title "<imperative title>" --body-file "$CLAUDE_JOB_DIR/tmp/ur-s1-body.md"`,
its first body holding the `Round: ur-std` and `Pass: S1` lines. Update it afterwards with
`gh pr edit <n> --repo glw907/standards --body-file "$CLAUDE_JOB_DIR/tmp/ur-s1-body.md"`.

An Agent dispatch returns at once and its report arrives in a later turn (Mechanisms, row 21).
After every dispatch in this plan, end the turn and act only when the completion notice arrives.
A transcript read before then is partial.

### Task 1: the skill text (20 minutes, `runner`)

Outcome: `S/SKILL.md` and `S/builder-check-prompt.md` carry the three changes and the prompt's new
question. Files: those two and no other. One commit, then the gate, the scan, the push, and the
draft PR.

The wording is yours, inside these limits.

- Keep the skill's voice: second person, "your human partner", never a name, lines wrapped as the
  file wraps them now. Nothing you write may match a line of `scripts/scan-patterns.txt`. Read
  that file first.
- **The description.** Line 3 stays one line that opens `description: "`. Replace the promise
  "two or three approaches with a recommendation, then the design for one approval" with what the
  body does: one question at a time, then a written design for one approval. Keep the trigger
  sentence.
- **Go and look.** The paragraph that opens `**Offer recon.**` (lines 85 to 88) becomes a rule:
  read the code or project, the person's files and data, and the web without asking, and say what
  you read. Use the phrases "without asking" and "what you read", which check A2 looks for. The
  trap is placement. The old rule sat mid-conversation behind "once you have a bit of grounding",
  and acceptance item 5 tests the first reply. "Your First Message" ends "That's the whole
  message", which as written forbids saying what was read. So the read must come before the first
  question whenever the request touches something that exists, and the first message must have
  room to say what was read. Edits to "First: What Do You Actually Know?" and "Your First
  Message" that do this are inside the change. A request with nothing to read (a new idea, no
  repository) still opens with the question alone.
- **The spike.** Leave "Spike to feel things out" asking first: the sentence "Offer one when it
  would help." stays.
- **What done looks like.** The cover list under "The Written Design" gains one bullet: what done
  looks like, as what your human partner would see or run, each item able to fail. Use the
  phrases "done looks like" and "able to fail".
- **The builder check.** The fenced prompt block in `S/builder-check-prompt.md` gains a question
  inside the fence: could any of the design's done items pass on a wrong result? Use the phrase
  "wrong result". Keep the `[DOMAIN` and `[DOCUMENT_PATH]` placeholders and the closing "nothing
  important left" line. If the three piles in `SKILL.md` need a clause to say where such a
  finding goes, add it there.
- Change nothing else: no other section, no other file under `S`, no file outside it.

Acceptance check. Run it after the commit. Each line joins wrapped lines before it searches, so a
phrase split across two lines still counts. On the unchanged files A1 prints 1, 0, 1; A2 prints
1, 1, 1, 0, 0; A3 prints 6, 0, 0; A4 prints 0, 1, 1, 1; and A5 prints nothing (Mechanisms,
row 22).

```bash
S=plugins/standards/skills/brainstorming
# A1: prints 0, 1, 1
sed -n 3p $S/SKILL.md | grep -c 'two or three approaches'
sed -n 3p $S/SKILL.md | grep -cE '^description: ".*one question at a time.*written design.*one approval'
sed -n 3p $S/SKILL.md | grep -c "Use when new work's design is not settled yet, or when the user asks to brainstorm or think something through."
# A2: prints 0, 0, 1, 1, 1
grep -c 'Offer recon' $S/SKILL.md
tr '\n' ' ' < $S/SKILL.md | grep -c 'They decide whether you go'
tr '\n' ' ' < $S/SKILL.md | grep -c 'Offer one when it would help'
tr '\n' ' ' < $S/SKILL.md | grep -ci 'without asking'
tr '\n' ' ' < $S/SKILL.md | grep -ci 'what you read'
# A3: prints 7, 1, 1
sed -n '/^## The Written Design/,/^\*\*Where it goes/p' $S/SKILL.md | grep -c '^- '
sed -n '/^## The Written Design/,/^\*\*Where it goes/p' $S/SKILL.md | tr '\n' ' ' | grep -ci 'done looks like'
sed -n '/^## The Written Design/,/^\*\*Where it goes/p' $S/SKILL.md | tr '\n' ' ' | grep -ci 'able to fail'
# A4: prints 1, 1, 1, 1
sed -n '/^```$/,/^```$/p' $S/builder-check-prompt.md | tr '\n' ' ' | grep -ci 'wrong result'
grep -c 'nothing important left' $S/builder-check-prompt.md
grep -c '\[DOMAIN' $S/builder-check-prompt.md
grep -c '\[DOCUMENT_PATH\]' $S/builder-check-prompt.md
# A5: the first prints exactly two lines, both starting M, for the two files; the second prints nothing
git diff --name-status origin/main...HEAD
git status --short
```

Test: the gate. `scripts/check-skill-lines.sh` holds the 500-line cap, and `SKILL.md` has 228
lines today.

### Task 2: the fresh subagent check (15 minutes, `runner`)

Outcome: two fresh Sonnet subagents, each given the committed skill and a one-line request, read
the repo before their first question, never ask leave to look, and say what they read. Files:
none, unless a failed run sends you back to `S/SKILL.md`.

Dispatch each run with the Agent tool: `subagent_type: "general-purpose"`, `model: "sonnet"`, no
other option, and this prompt with `<W>` as the worktree's absolute path. Send nothing else, and
never hint that it should read anything. Before each dispatch, note `git rev-parse --short HEAD`:
the evidence names the commit each run read, and `git status --short` must print nothing.

```text
You are starting a conversation with a user who is working in the git repository at <W>. Follow
the skill at <W>/plugins/standards/skills/brainstorming/SKILL.md. The user's request: "<request>"
Your final message is your first reply to the user. Write that reply and stop there. Change no
file.
```

Run 1's request: `I want a check that catches a skill whose description promises something its
body doesn't do.` Run 2's request: `I want a way to tell which skills nobody uses any more.`

The Agent call's result names an `output_file`. It is a link to the run's transcript, a JSONL
file. Never open it with Read: it overflows your context. When the run's completion notice has
arrived, print its events in order with this command:

```bash
jq -r 'select(.type=="assistant") | .message.model as $m | .message.content[]? |
  if .type=="tool_use" and .name=="SubagentHandback" then "TEXT \(.input.message // (.input | tostring) | gsub("\n";" ")) [qmark=\(.input.message // (.input | tostring) | test("\\?"))]"
  elif .type=="tool_use" then "TOOL \(.name) \(.input | tostring | .[0:300]) [\($m)]"
  elif .type=="text" then "TEXT \(.text | gsub("\n";" ")) [qmark=\(.text | test("\\?"))]"
  else empty end' <output_file> | sed -e "s|/var/home/$USER|~|g" -e "s|/home/$USER|~|g"
```

Every event prints on one line. A run passes when all five hold. Judge them from the command's
output, which is the evidence for item 5.

1. At least one `TEXT` line is marked `qmark=true`. A reply with no question never reached a
   first question, and fails.
2. Above the first such line, a `TOOL` line reads a file of the repo outside
   `plugins/standards/skills/brainstorming/`: a `Read`, a `Grep` whose input holds
   `"output_mode":"content"`, or a `Bash` command that prints file contents (`cat`, `head`,
   `tail`, `sed -n`, `awk`, or `grep` or `rg` without `-l`). A listing doesn't count: `ls`,
   `find`, `Glob`, `grep -l`, a `Grep` in any other mode. The read of `SKILL.md` doesn't count.
3. No `TEXT` line asks whether it may read, look, check, or search.
4. The first `qmark=true` line names at least one file or directory that a `TOOL` line above it
   read.
5. Every `TOOL` line ends `[claude-sonnet-5-5]`.

A run whose output holds a `TOOL Skill` line is void, since it loaded the installed copy of the
skill and not the file at `<W>`. Dispatch it again. A void run is not a failure.

The control: on the unchanged skill at `896f819`, both requests produced a read of `SKILL.md`
alone before the question, and a reply that named nothing it read (Mechanisms, rows 3 and 23).
Each fails conditions 2 and 4.

When a run fails, read from its output what the subagent did in place of looking, and write one
line for `## Decisions`: the cause and the wording change that closes it. Change `S/SKILL.md`,
rerun checks A1 to A5 and the gate, commit, scan, and push. Then dispatch fresh subagents for
both requests, because item 5's evidence must come from the text that merges. Never continue a
subagent that has already run. Never change the dispatch prompt or the requests to get a pass.

No count of reruns stops the pass. A cause that comes back after its fix gets one structural fix:
rewrite "Your First Message" so its first two steps are the read and the line that says what was
read. Item 5 can't be met as written, and the pass parks, in two cases only: a failure whose cause
you can't name from the output, or the same cause back again after the structural fix.

Test: both runs' printed events from the final commit, pasted into the PR body under item 5.

### Task 3: close (25 minutes, `runner`)

Outcome: the PR is merged, the main checkout is pulled, and the round report is written. Files:
`R/reports/ur-std-report.md` and nothing in the repo.

1. Run checks A1 to A5, the gate, and the scan, then push. Write the PR body (see "The PR body")
   with its `Review:` line reading `Review: pending`, and send it with `gh pr edit`. The PR stays
   a draft.
2. Read usage (rule 6 of "Every session"). Dispatch the whole-branch `standards:diff-reviewer`
   with `model: "fable"` and effort `high`, or `model: "opus"` when the Fable line reads 95
   percent or more or can't be read. Give it the worktree path, the base `origin/main`, the build
   design's path and lines 289 to 298 as the acceptance list, this plan's path, and the PR
   number. Tell it to read the PR body with
   `gh pr view <n> --repo glw907/standards --json body`, to check each acceptance item against
   the evidence there, and that a third changed file or an edited acceptance item is a finding.
   End the turn and wait for its notice. Act on its verdict as executor rule 5 says. A fix that
   changes `S/SKILL.md` reruns task 2 on the new commit. A second read goes to a fresh reviewer
   with the same model and effort and the first read's findings quoted in full.
3. Put the verdict in the `Review:` line and under `## Review`, fill the score, send the body, and
   mark the PR ready with `gh pr ready <n> --repo glw907/standards`. The clock ends here.
4. Wait for the PR's checks with a background command of its own:
   `sleep 30; gh pr checks <n> --repo glw907/standards --watch --interval 20`. End the turn while
   it runs. The sleep gives the workflow time to register. If it exits saying no checks were
   reported, start it again: that is not a red. A red check stops the line: fix forward, rerun
   the gate, push, and wait again. A red `validate` whose scan hit is in a commit outside
   `origin/main..ur-s1` is one this pass can't fix: park, with the command from "Tasks" and its
   empty output as the evidence.
5. Read the PR with
   `gh pr list --repo glw907/standards --head ur-s1 --state all --json number,isDraft,state,body,statusCheckRollup`
   and apply the conditions of the land test in `ur-rules.md` "Reading a pass". Apply the
   conditions only. Stop no session: the planner has ended and you are the executor. S1 has no
   run sheet and no earlier pass, so those two conditions hold.
6. When the test passes, read line 3 of `R/reports/ur-queue-report.md`. It read
   `Queue live through: none` at planning. While it reads `none`, `Q1`, or `Q2`, land with
   `APPROVAL_QUEUE_PROJECTS=$HOME/.local/state/unattended-rounds/projects approval-queue land glw907/standards#<n> "ur-std S1: <claim>"`.
   Once it reads `Q3` or `Q4`, run `approval-queue` with no argument first and place
   `--round ur-std` where its usage line for `land` shows it. Keep the claim within 80
   characters. When the land test fails only on a call, send one close packet through
   `approval-packet`, its files in `R/packets/ur-std-s1-close/`, and act on the decision.
7. Pull the main checkout with `git -C ~/Projects/standards pull --ff-only` when three things
   hold: `git -C ~/Projects/standards branch --show-current` prints `main`,
   `git -C ~/Projects/standards status --short` prints nothing, and `claude agents --json` shows
   no live row whose `cwd` is the checkout. A row is live when its `state` isn't `done`,
   `stopped`, or `failed`. Your own row and the row named `standards-ur-s1-plan` don't count: the
   planner ended when it launched you, and its row can read `working` after that. When the three
   don't hold, force nothing. Write the report with the checkout named stale and what holds it,
   start `sleep 300; echo recheck` in the background, end the turn, and test again when it
   exits. The prompt's first end needs the pull, so the wait repeats until the pull runs.
8. Leave the worktree with `ExitWorktree` and `action: "keep"`, which returns you to the main
   checkout and removes nothing (Mechanisms, row 24). Then run
   `git -C ~/Projects/standards worktree remove .claude/worktrees/ur-s1` and
   `git -C ~/Projects/standards branch -d ur-s1`, with no force flag. If either fails or is
   refused, leave it and say so in the report. That is not a stop.
9. Read usage again and write `R/reports/ur-std-report.md` in the form under "Report" in
   `ur-rules.md`, with these facts. Planned path minutes are 60. The actual is the minutes from
   the planner's launch, 2026-11-12T03:52Z, to the PR marked ready. Usage before the pass, read at
   your launch, was 71 percent for all models and 20 percent for Fable. The trials line counts one pass planned by
   Fable 5.2 and one session under a `/goal` line. Name your session's name and id, the model
   your seat and the review ran on, and each refusal. `Resume from:` names
   `~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds/plans/ur-s1-prompt.txt`,
   since no conductor exists. For build standing answer 5, run
   `ls -t ~/.claude/plugins/cache/glw907-standards/standards/ | head -3` and say which commit
   directories the cache holds and whether one matches the merge commit. Nothing waits on it.
   Once the queue report reads `Queue live through: Q4`, also run
   `approval-queue report unattended-rounds ur-std <report file>` with the variable from step 6.

Acceptance check: `gh pr view <n> --repo glw907/standards --json state,mergeCommit` prints
`MERGED`, `git -C ~/Projects/standards rev-list --count HEAD..origin/main` prints 0 after a fetch,
and the report file exists with its second line reading `Round state: ended`.

Test: the gate on the head commit and the `validate` check on the PR.

## The PR body

Write it for a public repo. Use `~` for every home path, inside quoted commands and output too.
Never name this plan's path. In order:

- `## Brief`, per `~/.claude/docs/voice/approval-brief.md`: what merging changes for someone who
  uses the skill.
- Four lines, each on a line of its own: `Round: ur-std`, `Pass: S1`,
  `Review: <accept|fix|escalate>, open findings <n>`, and `Calls: none` or `Calls: <n>` with each
  call under `## Calls`.
- `## Acceptance`: the six items verbatim, each followed by its evidence, then the added checks
  with theirs.
- `## Review`, with the verdict in backticks.
- `## Decisions`, opening with the entries under "Decisions to carry" below.
- `## Planning misses`, opening with the entries under "Planning misses" below. Every line opens
  with one tag.
- `## Found, not done`, when there is anything. The repo has no backlog file and this pass adds
  none, so each item also goes in the report.
- The score table and the `pass-score` comment from the executor reference, with `planPathMin`
  60. `actualPathMin` there runs from your first commit to the PR marked ready, as the executor
  reference sets it. The report's actual runs from the planner's launch. The gate runs bare, so
  time it by the clock.

## Stops

A stop is what `ur-rules.md` "Stops" lists. Each one below has its answer, and none asks Geoff in
chat.

| Stop | Standing answer |
| --- | --- |
| A task 2 failure with no cause you can name, or one cause back after the structural fix. | Approved answer 12: item 5 can't be met as written, so the pass parks. |
| Meeting an item needs a change outside the two files. | Approved answer 12. Never build around the item. |
| `validate` is red on a scan hit in a commit outside this branch. | Approved answer 12: item 6 can't be met by this pass, so it parks. |
| A second refusal of one command. | Approved answer 2. The pass parks. |
| The review ends on `escalate`, or its second read isn't `accept`. | Executor rule 5. The pass parks. |
| The land test fails on a call. | Not a stop. One close packet goes out (task 3, step 6). |
| The main checkout can't be pulled. | Not a stop. The session waits and tests again (task 3, step 7), and `## Planning misses` gets a `[no-answer]` line. |
| The worktree or branch can't be removed. | Not a stop. The report says so. |
| The plugin cache still holds the old skill after the merge. | Build answer 5. The report names the commit, and nothing waits. |
| The Fable meter reads 95 percent or more, or can't be read. | Build answer 9. The review runs on Opus, and the PR and report say so. |

To park, follow "A pass with no conductor" in `ur-rules.md`: commit, push, write the stop under
`## Stop` in the draft PR's body (the question, what you tried, the choices you see), wait for the
PR's checks, and send one `stop` packet through `approval-packet` yourself. Its files go in
`R/packets/ur-std-s1-stop/`, its title and text headline open with `ur-std`, and its `steps` say
what you run after the answer. It carries a forced `gate-failed` call when a check is red or the
review's verdict is `fix` or `escalate`. Run `approval-queue packet` in the background with no
`timeout`, with the variable from task 3, and never stop it. When the answer comes, append the
ruling under `## Rulings` below (this file is not committed, so there is nothing to push), put
the question in the PR's `## Planning misses` and the ruling in its `## Decisions`, run the
packet's steps, and go on from this plan. Never run `approval-queue merge` on a stop packet.

### Refusals

Each command with a refused class in the denial log has one alternative. Use it once. A second
refusal is a stop. Record every refusal: the command, the reason shown, and what you did.

| Command | Alternative |
| --- | --- |
| An Edit to a file under `S` | Write the whole file once with the Write tool. On a second refusal, put the change in the PR body as a patch and park. |
| `git push -u origin ur-s1` | `git push origin ur-s1:ur-s1`. |
| `gh pr checks <n> --watch` in the background | A background loop of its own that prints `gh pr view <n> --repo glw907/standards --json statusCheckRollup` every 20 seconds until no check is pending. |
| `approval-queue land ...` with the variable in front | The same command as `env APPROVAL_QUEUE_PROJECTS=... approval-queue land ...`. Never `gh pr merge`. |
| `git worktree remove` or `git branch -d` | None. Leave the worktree and say so in the report. This refusal is not a stop. |
| Any command refused as "Classifier unavailable" | The same command once more after a minute. |
| A background command you started that must end | `TaskStop`. Never `kill` or `pkill`. |

## Mechanisms

Every row is a probe the planner ran on 2026-11-11 or a quoted source.

| # | Mechanism | Probe or source |
| --- | --- | --- |
| 1 | A subagent's transcript is a file the session can read. | Probe: each Agent dispatch returned an `output_file` under `/tmp/claude-1000/<project>/<session>/tasks/`, and `ls -la` showed it as a link to `~/.claude/projects/<project>/<session>/subagents/agent-<id>.jsonl`. |
| 2 | The `jq` command in task 2 prints tool calls and text in order, one event to a line. | Probe on the run 1 baseline transcript: it printed a `TOOL Read` line whose input names `.../skills/brainstorming/SKILL.md`, a `TOOL Bash` line whose command is `ls && ls scripts .github/workflows 2>/dev/null; ls plugins/standards/skills \| head -50`, each ending `[claude-sonnet-5-5]`, then the reply as a `TEXT ... [qmark=true]` line and the hand-back's copy of it as a second. The same command ran clean on the other three baseline transcripts. |
| 3 | Task 2's check fails on the unchanged skill for run 1. | The same probe, skill at `896f819`. The only read was `SKILL.md`, the Bash call was a listing, and the reply was "I can build a check for that. If you'd rather skip the questions and have me just start, say so and I will. Tell me about the last time you found a skill whose description said one thing while its body did another. What was the skill, and how did you notice?" It fails conditions 2 and 4. It would pass item 5's last sentence read alone. |
| 4 | `model: "fable"` on an Agent dispatch runs Fable 5.2, though the job's `providerEnv` sets `CLAUDE_CODE_SUBAGENT_MODEL=sonnet`. | Probe: a dispatch with `model: "fable"` wrote a transcript whose one assistant message reads `claude-fable-5-2`, and its `meta.json` reads `"model":"fable"`. |
| 5 | `model: "sonnet"` runs Sonnet. | Probe: every assistant message of the four baseline transcripts reads `claude-sonnet-5-5`. |
| 6 | Every CI step runs locally. | Probe in the worktree at `896f819`: the eight gate commands each exited 0, the slowest in 1 second. `scan-test: ok` and `check-skill-lines-test: ok` printed. Local `claude` is 2.1.322, and CI installs 2.1.316 (`.github/workflows/validate.yml:32`), so the PR's check is the authority. |
| 7 | The scan reads tracked files and the added lines of every commit on every ref, never a commit message or a PR body. | `scripts/scan.sh:17` (`git grep -nIE -f "$patterns"`) and `:22` (`git log --all -p --no-color --format='commit %h'`). `git branch -r` listed 15 remote branches, and `git stash list` printed nothing. The diagnostic command under "Tasks" printed nothing on the empty branch. |
| 8 | The line cap is 500 for each `SKILL.md`, and the brainstorming skill has no word cap. | `scripts/check-skill-lines.sh:15` opens `WORD_CAPS`, which names three other files, and `:24` holds the 500 cap. `wc -l` printed 228 for `S/SKILL.md`. |
| 9 | The reference check leaves a short reference alone. | `scripts/check-references.mjs:24`: only a file over 100 lines needs a contents list. `S/builder-check-prompt.md` has 23 lines. |
| 10 | The patterns the scan refuses. | `scripts/scan-patterns.txt`, seven lines: home paths, `Geoff`, four host and domain names, and eleven workstation commands. |
| 11 | The launch guard reads `ur-s1-prompt.txt` with this file. | `~/.local/bin/claude-launch-guard`, `plan_for`: a prompt naming no `docs/plans/` path resolves to `prompt.with_name(prompt.name.replace("-prompt.txt", ".md"))`, and `REQUIRED = ("Permissions checked:", "Reviewed:")`. |
| 12 | `land` merges one PR and writes a digest line. | `approval-queue` with no argument printed `approval-queue land <owner/repo#n> <claim>`. The queue's `README.md:111`: "`land` refuses a pull request that sits in a waiting item, is closed, has a `## Before merge` section, or has a failing check." |
| 13 | Whether `land` takes `--round` yet. | `R/reports/ur-queue-report.md:3` read `Queue live through: none` at planning. The executor reads it again before landing. |
| 14 | The plugin cache holds one directory per commit. | Probe: `ls ~/.claude/plugins/cache/glw907-standards/standards/` printed 14 directories, `896f819516e3` among them. |
| 15 | Branch `ur-s1` tracks `origin/main`. | `git worktree add` printed "branch 'ur-s1' set up to track 'origin/main'". A bare `git push` would not target `ur-s1`. |
| 16 | The worktree path is ignored. | Probe: `git -C ~/Projects/standards check-ignore -q .claude/worktrees/x` exited 0. |
| 17 | Usage can be read. | Probe: `claude -p "/usage" --model haiku < /dev/null` printed "Current week (all models): 68% used" and "Current week (Fable): 15% used". |
| 18 | The repo has no STATUS file, backlog file, or pass guide. | Probe: `ls` at the root printed `LICENSE plugins README.md scripts tests THIRD-PARTY-NOTICES`. `README.md:39`: "Changes land by pull request." |
| 19 | The signed-in account can merge, by merge commit, into an unprotected `main`. | Probe: a `gh api repos/glw907/standards` read printed `admin` and `push` as `true` under `permissions` and `allow_merge_commit` as `true`. The branch-protection read of `main` answered "Branch not protected". |
| 20 | `gh pr create` prompts unless a title and body are passed. | `gh pr create --help`, gh 2.103.3: "A prompt will also ask for the title and the body of the pull request. Use `--title` and `--body` to skip this". `gh pr checks --help` lists `--watch` and `-i, --interval int`. `ls -d $CLAUDE_JOB_DIR/tmp` printed `~/.claude/jobs/38cef942/tmp` in the planner's background session. |
| 21 | An Agent dispatch runs in the background. | Probe: each of the planner's dispatches returned at once with a launch notice, and its report came in a later turn as a completion notice. |
| 22 | Checks A1 to A5 fail on the unchanged files. | Probe at `896f819`, the checks as task 1 writes them: A1 printed 1, 0, 1; A2 printed 1, 1, 1, 0, 0; A3 printed 6, 0, 0; A4 printed 0, 1, 1, 1; A5 printed nothing. The fence in `S/builder-check-prompt.md` opens on line 6 and closes on line 23, and the A3 range runs from line 147 to line 159. |
| 23 | Run 2's request fails on the unchanged skill, and the first candidate did not. | Probes at `896f819`. `I want a way to tell which skills nobody uses any more.` printed one `TOOL Read` of `SKILL.md` and then the reply, which named no file: it fails conditions 2 and 4. `I'd like the skill length check to be easier to understand when it fails.` printed a `TOOL Bash` holding `cat scripts/check-skill-lines.sh` before a reply that named that file, so it passes on the old skill and was dropped. A spare, `I want every new skill to get a second pair of eyes before it lands.`, failed the same way as run 2's. |
| 24 | `ExitWorktree` with `keep` leaves a worktree entered by path. | The `EnterWorktree` tool's description: "ExitWorktree will not remove a worktree entered this way; use `action: "keep"` to return to the original directory." |

## Searches

Each ran as `git grep -nIiE '<pattern>'` in the worktree at `896f819`.

| Pattern | Hits | Listed or dismissed |
| --- | --- | --- |
| `two or three approaches` | 1 | `S/SKILL.md:3`. Listed. |
| `recon` | 19 | `S/SKILL.md:85` is listed. 17 hits are "reconnect" in `S/scripts/helper.js`, `server.cjs`, and `start-server.sh`, and 1 is "reconnects" in `S/visual-companion.md:124`: the visual companion's socket, not this rule. |
| `They decide whether you go` | 1 | `S/SKILL.md:87`. Listed. |
| `builder-check-prompt` | 1 | `S/SKILL.md:163`, the pointer to the prompt file. Listed; the file keeps its name. |
| `builder check` | 2 | `S/SKILL.md:162` and `S/builder-check-prompt.md:1`. Both listed. |
| `brainstorming` | 6 | `S/SKILL.md:2` and `:6` are the name and title, unchanged. `THIRD-PARTY-NOTICES:126` is the notice, kept true by check A5. `S/scripts/frame-template.html:5`, `S/scripts/server.cjs:106`, and `S/visual-companion.md:18` are the visual companion. No README, agent, or other skill quotes the description. |
| `done looks like` | 0 | Nothing holds the phrase yet. |
| `one question at a time` | 2 | `S/SKILL.md:3` is listed. `plugins/standards/skills/running-passes/SKILL.md:18` is that skill's sentence, which the build design puts out of scope. |
| `Offer one when it would help` | 1 | `S/SKILL.md:108`, the spike sentence that stays. |

The file list is `S/SKILL.md` and `S/builder-check-prompt.md`, as the build design names.

## Decisions to carry

Put these in the PR's `## Decisions`, reworded for a public reader and without this file's path.

- The plan and the launch prompt are kept outside the repository. The build design placed them
  under the repo's plans directory, and the scan refuses what they name.
- `THIRD-PARTY-NOTICES` is unchanged. Its entry names the upstream source, commit, license, and
  copyright, and the pass changes none of them. The alternative was a line saying the skill is
  modified, which the file says of no other entry.
- The subagent check counts only a read outside the skill's directory and runs two requests. Read
  alone, the item's last sentence passes on the unchanged skill.
- The second request was swapped during planning. The first candidate named a script, and the
  unchanged skill already read it.
- The description keeps its trigger sentence.
- The gate runs bare, with no gate wrapper. The repo has none, and the eight commands finish in
  seconds.
- The session armed no scheduled wake-up (see "Start").
- Found, not done items are listed in the PR and the round report. The repo has no backlog file.

## Planning misses

Put these in the PR's `## Planning misses`, again without this file's path.

- `[mechanism]` The build design put each pass's plan and launch prompt in its repo. This repo's
  scan refuses a tracked file or a commit naming a home path, a workstation command, or the
  owner, so both files stayed out of the repo.
- `[design-gap]` Acceptance item 5 ends "Its transcript shows a file read before the first
  question mark." The subagent's read of the skill file meets that sentence on the unchanged
  skill. The plan added conditions and left the item as written.
- `[no-answer]` The round's rules end a landed pass on a pulled main checkout and say nothing of
  a checkout that another session holds. Add this line only if task 3, step 7 had to wait: the
  session waited and tested again.

## Rulings

None yet.
