# Spec-writing test spec

Status: waiting for Geoff's approval. Nothing is built.

This spec adds a test for the guide that says how a spec is written,
`building-from-specs/references/writing-a-spec.md`. Nothing tests that guide today. The test is
16 cases, each built on a mistake that a past spec made. Six cases give a session a settled
design with one trap in it and check the spec the session writes. Ten give a fresh reader a
finished spec with one planted mistake and check that the reader names it. Every test session
runs on Fable at `high` effort, the setting Geoff picked for spec writing.

The work is two tasks in the workstation repo, each ending in one pull request. The first builds
the test and records how today's guide does. The second changes the guide only where a check
fails, in three rounds at most, then runs the whole test twice. It is done when every case
passes both times, and it reports what still fails when it doesn't. One thing is already known
from the trial runs: today's guide produces a spec of about 3,000 words for a change of twenty
lines, which Geoff ruled too long.

One question waits for Geoff, under [What Geoff decides](#what-geoff-decides). The rest is his
ruling, quoted, or a call Claude made, listed under [Calls Claude made](#calls-claude-made).

To approve, Geoff answers the question and says the spec is approved, in his terminal.
Nothing launches before that. If he wants something changed, he says what, and the spec is
revised first.

The trial runs behind this spec are in `research/2026-11-22-spec-writing-test/`, and its
`README.md` is the short form.

## What Geoff decides

The spec is written as if the recommendation holds.

**Is the spend all right?** One full run of the 16 cases costs about 29 dollars of usage, as
Claude Code prices it. The two tasks are planned at about 110 dollars and capped at 170. A full
run of the `standards` plugin's suite cost $27.30 and moved the week's usage from 23 to 26
percent. By that measure the plan is about 12 percent of a week's usage and the cap about 19.
The two sessions that build the tasks use more on top, and no figure for them is measured. The
recommendation is yes. A lower cap means fewer cases or a final check that passes once in place
of twice, and either one makes the result weaker.

## How long a spec may be

Geoff ruled on 2026-11-22 that a long spec for a small change is a failure: "Yes, that's too
long for a small change." Asked for a limit in words, he said: "I'll go with Anthropic's
guidance on the subject." He then asked what community practice says.

Anthropic gives no number for a spec. Its rule for a document a model writes to disk is on its
page for Opus 5: "Match the length of written documents to what the task needs: cover the
substance, but do not pad with filler sections, redundant summaries, or boilerplate." Its page
for Fable 5.2 warns about fixed limits on prose. The model follows style rules closely, "so a
hard limit such as 'one instruction per sentence, in 20 words or fewer' can make its prose
choppy."

The community sources give no number either. Each one sizes the spec by the change.

| Source | What it says |
| --- | --- |
| [The `superpowers` brainstorming skill](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md) | "For a small change, the short design covers the same points in a line or two each" |
| [How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/) | "A good rule of thumb: adjust spec detail to task complexity." |
| [The right amount of spec for agentic development](https://www.oreilly.com/radar/the-right-amount-of-spec-for-agentic-development/) | "there is no single right amount of specification. The answer depends on the kind of work you're doing." |
| [A review of three spec-writing tools](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) | One tool turned a small bug into "4 'user stories' with a total of 16 acceptance criteria", and another's files were "repetitive, both with each other, and with the code that already existed" |

So the guide's length rule states no number. It tells the writer to match the spec to the work
and to cover each point of a one-task spec in a line or two, except the task and its goal. The
text is under [The guide changes](#the-guide-changes).

The test still checks a number. A check has to pass or fail the same way on every run, and a
word count does. The mark is 1,200 words, and it is Claude's. Two sessions with no guide wrote
1,056 and 1,090 words for a small change, and three sessions with the guide wrote 2,759, 2,803,
and 3,550. The mark lives in the test and nowhere in the guide.

A judge that reads each spec for padding was weighed and passed over. The `superpowers`
project measured that kind of grading. A quality call on the same runs "matched about two times
in three", so its table "leans on the factual yes/no line".

## What is wrong today

On 2026-11-21 Geoff asked whether the skills for writing a good spec are in place, since a wrong
or ambiguous spec costs more on a long unattended run. He ruled: "Let's follow best practices
and test once we have the environment fully set up." On 2026-11-22 he said: "Yup, let's do it."

The guide is 80 lines and has no test. `building-from-specs` has four test cases. Three cover
launching, building, and merging from an approved spec, and the fourth checks that the skill
stays out of unrelated work.

Past specs did go wrong. `task-report --since 2026-11-01` counts 56 planning mistakes in the
workstation and `standards` repos, 49 for every 100 merged pull requests.

| Kind of mistake | Count |
| --- | --- |
| The design never covered a case the builder met | 13 |
| A stated fact about the code or a tool was out of date | 10 |
| A mechanism didn't work as the spec said | 5 |
| The file list left out a file or named a wrong one | 4 |
| Two documents disagreed | 2 |
| A requirement read two ways | 2 |
| The report couldn't sort it | 20 |

Nearly all of these came before the guide was written on 2026-11-21. It last changed on
2026-11-22. No record says how today's guide does.

The trial runs found one thing that is wrong now. A session that follows the guide writes a
spec of 2,759 to 3,550 words for a one-task change.

The skill also names the wrong model. Its Models section says "Spec writing and review run on
Opus at high." On 2026-11-22 Geoff ruled for Anthropic's recommendation, which is Fable at
`high`.

## What it is for

- A standing test that shows whether a change to the guide makes spec writing better or worse.
- A first result for today's guide on Fable at `high`.
- A guide that passes that test, changed only where a case shows a need.
- The right model named in the skill.

## What it leaves out

- The design conversation that comes before a spec. Geoff picked the written spec as the test's
  reach, and the `standards` plugin already tests the conversation.
- A comparison against a session with no guide. Geoff said: "I'm not sure the pricing run helps
  with anything, since I need the skill one way or the other."
- Whether a spec's minutes turn out right.
- Building from each written spec and running hidden tests on the result. That would double the
  cost. It waits until the narrow checks here prove too loose.
- The open notes in `STATUS.md`.

## What would make it a failure

- A case that passes or fails for a reason other than its trap.
- A guide that grows a rule no failing check asked for.
- A pull request marked ready with a done item unmet and unsaid. Pull request 22 in `standards`
  did that.
- A spec for a one-task change that runs past 1,200 words after the work.

## Constraints

- At most four sessions work at once on pavilion, counting Geoff's.
- No session starts past 85 percent of weekly usage.
- A task session never edits `settings.json`, the global `CLAUDE.md`, the two lists under
  `claude/.claude/tooling/`, a shell startup file, or a memory store. This spec needs no such
  edit.
- A change to `building-from-specs` goes through the `claude-infra` skill. Each commit and pull
  request cites
  <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>.
- The guide stays at 1,000 words or fewer. It is 796 today.
- The four existing cases keep running as they do today.
- The workstation repo runs no CI on pull requests, so the gate on a branch's last commit is its
  only full run.

## Approaches

Anthropic's page on writing skills says to test first: "Create evaluations BEFORE writing
extensive documentation. This ensures your Skill solves real problems rather than documenting
imagined ones." Its steps are to find the gaps, build cases, record a baseline, then "Write
minimal instructions: Create just enough content to address the gaps and pass evaluations."
This spec follows that order. The same page says: "There is not currently a built-in way to run
these evaluations."

Three ways to run the cases were weighed.

1. **Extend the skill's runner, `run_evals.py`.** It already starts one `claude -p` session for
   each case in a scratch project. It gains Fable, an effort flag, the shell sandbox, and
   graders. This is the pick. Every piece was tried on 2026-11-22.
2. **Use `claude plugin eval`.** It is the documented command, and the `standards` plugin uses
   it. It has no effort flag and no grader that runs code. A trial on 2026-11-22 also showed
   that its sandbox lacks git and a writable temp folder.
3. **Have a person read each written spec.** Anthropic's testing page says of human grading:
   "Avoid if possible."

No published source tests a skill that writes specs. This test is assembled from documented
pieces, and [Where each mechanism comes from](#where-each-mechanism-comes-from) labels each one.

## How the test works

Every case runs in a small git repo that a script builds fresh. The repo is a one-file notes
tool with a test script, a gate, and a remote. `research/2026-11-22-spec-writing-test/` holds
the trial version.

### Writing cases

A session gets a settled design, `brief.md`, and is told to write the spec to `spec.md` by the
guide, to build nothing, and to ask nothing. Each brief holds one trap.

| Case | The past mistake | The trap | Passes when the spec |
| --- | --- | --- | --- |
| `write-missing-file` | A file list left out a file | The brief names two files, and a test forces a change to `completions/notes.bash` | Names `completions/notes.bash` |
| `write-gate-red` | A check nothing could meet (pull request 243 in the workstation) | The brief says done is a passing gate, and the gate fails today on `test_export_csv` | Names `test_export_csv` |
| `write-unlanded-work` | A spec leaned on work that hadn't merged | The brief says to print in the format `notes export` uses, and no such command exists | Says `notes export` doesn't exist |
| `write-check-passes-today` | A check that passed on unchanged code (pull request 20 in `standards`) | The brief's check for the README already passes | Says that check passes today |
| `write-uncovered-edge` | A design that never covered a case | The brief is silent on a missing notes file, and `notes list` has a tested rule for one | Says what the search does with no notes file |
| `write-two-sources` | Two documents that disagreed | The brief's exit code for no match breaks a rule in the README | Says the two disagree |

The last column is the trap check. A case fails it when the spec carries the trap forward, and
the column gives the usual sign that it didn't. A spec that avoids the trap in another sound
way passes too. For `write-check-passes-today`, that is a spec that swaps the brief's check for
one that fails today. A spec that names the thing and keeps the trap fails. For
`write-gate-red`, that is a spec that names `test_export_csv` and still lists a passing gate as
a done item, with nothing done about the test.

A writing case has three more checks:

- **Length.** `wc -w spec.md` prints 1,200 or less.
- **Nothing built.** `git status --porcelain` shows `spec.md` as the only change, and `HEAD` is
  still the fixture's commit.
- **The guide was read.** The session's record shows that it read the copy of the guide.

### Reader cases

A fresh reader gets a finished spec of about 400 words and the prompt a real spec's reader
gets. That prompt is `builder-check-prompt.md` from the `standards` plugin. Each spec holds one
planted mistake. A case passes when the reader's report names it.

| Case | The planted mistake |
| --- | --- |
| `read-false-fact` | The spec says the gate passed today, and it fails |
| `read-check-passes-today` | A done item's check already passes with nothing built |
| `read-wrong-path` | A done item's command names a file that doesn't exist |
| `read-prints-nothing` | A done item's command can never print the value it waits for |
| `read-missing-file` | The file list leaves out a file a test forces the work to change |
| `read-vendored-file` | The file list names a file the repo says is copied in and never edited |
| `read-false-count` | The spec says a search found one hit, and it finds three |
| `read-two-parts` | Two sections give different exit codes for the same case |
| `read-unlanded-work` | The spec builds on a command that isn't in the repo |
| `read-uncovered-edge` | The spec never says what happens with no notes file |

No case holds a clean spec. A trial reader asked four questions about a spec with no planted
mistake, and every reader listed a dozen ways a done item could pass on a wrong result. A
reader's report is never empty, so the test checks that a report names the mistake. The summary
prints each report's word count, which nothing grades.

### How a case is graded

A check is a text pattern when the answer is a file name or a command. Otherwise a judge
answers one yes-or-no question about the text, such as "Does the spec say that `notes export`
does not exist in the repo?" The judge is one session on Sonnet at `low` with no tools. It must
quote the words that support a yes, and the runner fails the check when the quote isn't in the
text.

Every trap check ships with three samples: one that must pass, one that must fail, and a near
miss that names the thing, keeps the trap, and must fail. A writing case's samples are whole
specs, since a pattern that is right on two lines can be wrong on two thousand words. The
length check and the nothing-built check have a passing and a failing sample each.

`--check-graders` proves every check on its samples before any Fable session starts. It runs
each judge sample twice, and both answers must be right. It also builds every fixture and runs
that fixture's proof that the trap is in place, such as a gate that fails on `test_export_csv`.
Anthropic's guide to testing agents asks for this: "Each task should be passable by an agent
that follows instructions correctly." A judge call costs about 5 cents, so one pass over the
samples costs about 4 dollars.

### The commands

`E` stands for `claude/.claude/skills/building-from-specs/evals`.

```bash
python3 -I $E/run_evals.py --suite spec-writing --list
python3 -I $E/run_evals.py --suite spec-writing --check-graders
python3 -I $E/run_evals.py --suite spec-writing --run --out <folder> \
  [--only <case>] [--jobs 2] [--max-total-usd <dollars>]
python3 -I $E/run_evals.py --summary <folder> [--require-pass]
```

`--run` runs every case once, or the named ones. It starts with one cheap session that tries
to write outside its folder, and it stops unless the sandbox refuses that write.

`--summary` takes one or more run folders and prints one row for each session:

- the case, and pass or fail for each check
- how the session ended: `finished`, `cost cap`, `time limit`, or `error`
- the models the session's output names, and the effort and sandbox settings the runner passed
- the hash of the guide the session was given, and for a reader case the hash of its prompt
- one hash over the runner, the cases, and the fixtures as they were at the run
- the word count and the cost

It exits 1 when a case has no row, when a session ended any way but `finished`, when the main
model wasn't Fable, or when the last hash differs from the files in the tree now. With
`--require-pass` it also exits 1 when any check failed.

A reader case gets `references/reader-brief.md` from the copy of the skill under test when that
file exists. Otherwise it gets the `standards` plugin's `builder-check-prompt.md`, a copy of
which sits with the fixtures. No such brief exists today, so the baseline uses the plugin's
prompt.

Each test session runs with the flags that the trial runs used:

```bash
claude -p "<the case's prompt>" --model claude-fable-5-2 --effort high \
  --permission-mode dontAsk --allowedTools "<the case's tools>" \
  --max-budget-usd <cap> --strict-mcp-config --setting-sources project,local \
  --no-session-persistence --settings '<json>' --output-format json
```

| Setting | Writing case | Reader case |
| --- | --- | --- |
| Tools | `Read,Glob,Grep,Skill,Bash,Edit(./**),Agent` | `Bash,Read,Glob,Grep` |
| Cost cap for one session | $6.00 | $2.00 |
| Time limit | 1,800 seconds | 900 seconds |

The `--settings` value carries what the runner passes today, plus the sandbox:
`"enabled": true`, `"failIfUnavailable": true`, `"allowUnsandboxedCommands": false`, and a
`filesystem.denyRead` list that hides the installed copy of the skill and the real denials log.
The session reads the guide from a copy of the branch under test, as the runner does today.

Three files in each writing case stand in for the workstation, and the prompt names them: what
`task-report` prints, a denials log, and the repo's remote. The real `task-report` can't reach
GitHub from the sandbox, and the real log changes every day.

## What gets built

Both tasks are in `~/.dotfiles`, the `glw907/workstation` repo. Each runs on Opus at `high`, and
`standards:diff-reviewer` reviews it. Neither touches sign-in, data, or a screen.

### Task 1: build the test and record today's result

Files:

- `$E/run_evals.py` gains the four commands above, with everything that section says they do.
  Its old flags keep working.
- `$E/evals.json` gains the 16 cases after its four. The inventory row at
  `claude/.claude/docs/claude-tooling.md:13` names this file and stays true.
- `$E/files/spec-writing/` is new and holds each case's fixture script, brief or spec, prompt,
  and samples, and the copy of the plugin's reader prompt.
- `$E/results/<date>/spec-writing-baseline/` is new and holds one full run and a `README.md`
  with the summary.
- `claude/.claude/skills/building-from-specs/SKILL.md` line 176 changes as below.

The Models sentence changes from this:

> Spec writing and review run on Opus at high.

to this:

> Spec writing and its fresh reader run on Fable at high. Review runs on Opus at high.

The task doesn't touch the guide. Its pull request lists each failing check under
`## For Geoff` with the evidence file.

Done when each of these holds on the branch's last commit:

1. `python3 -I $E/run_evals.py --suite spec-writing --list` prints 16 names, six that start
   `write-` and ten that start `read-`. Today it exits 2 with `error: the following arguments
   are required: --case, --model, --state, --scratch, --out`.
2. `python3 -I $E/run_evals.py --suite spec-writing --check-graders` exits 0 and prints one
   line for each of the 16 cases. Each line reads `ok`, counts three or more samples for the
   trap check, and says the fixture's trap is in place. Today it exits 2 with the same error.
3. `python3 -I $E/run_evals.py --summary $E/results/*/spec-writing-baseline` prints 16 rows,
   each ended `finished`, and exits 0. One folder matches the path. A failed check doesn't
   change the exit code. A run made before the runner, a case, or a fixture last changed does,
   through the hash. Today the command exits 2 with the same error.
4. In the skill's folder,
   `grep -cF 'Spec writing and its fresh reader run on Fable at high. Review runs on Opus at high.' SKILL.md`
   prints 1, and `grep -c 'Spec writing and review run on Opus' SKILL.md` prints 0. Today they
   print 0 and 1.

Three checks pass today and must still pass:

- `bash scripts/gate.sh` exits 0. On 2026-11-22, at commit `ac87235`, 41 of its 42 parts passed
  in a copy under `/tmp`. The other part skips `/tmp` paths by design and passed in a copy
  outside it.
- `claude-tooling-sync verify` exits 0. It did on 2026-11-22.
- Each of the four old cases still runs. For case 1, 2, 3, and 4,
  `python3 -I $E/run_evals.py --case <n> --model sonnet --state on --scratch <folder> --out <folder>`
  writes an evidence file whose `exitCode` is 0. Its `loaded` is true for cases 1 to 3 and
  false for case 4. All four did that on 2026-11-22.

### Task 2: change the guide where a check fails

Task 2 waits for task 1 to merge. If no check failed, task 2 never launches. Geoff's session
then records in `STATUS.md` that the test stands and the guide is unchanged.

Files:

- `claude/.claude/skills/building-from-specs/references/writing-a-spec.md`.
- `claude/.claude/skills/building-from-specs/references/reader-brief.md`, new, and only if a
  reader case failed.
- `$E/results/<date>/spec-writing-final/run-1/` and `run-2/`, new, with a `README.md` beside
  them.

The task changes nothing else. It leaves the runner, the cases, the fixtures, and the checks as
task 1 merged them. A check it believes is wrong goes under `## For Geoff` with its evidence.

The steps, in order:

1. For each check that failed in the baseline, make the change that
   [The guide changes](#the-guide-changes) gives for it. Each change is one commit, and the
   commit message names the check.
2. Rerun the cases that had a failing check. That is one round. A check that still fails gets
   a reworded change and one more round. Three rounds is the limit for the whole task.
3. Run every case twice, once into `run-1` and once into `run-2`. The guide doesn't change
   after the first of these sessions starts, and the pair runs once.

Done when each of these holds on the branch's last commit. `F` stands for the final folder.

1. `python3 -I $E/run_evals.py --summary $F/run-1 $F/run-2 --require-pass` prints 32 rows, two
   for each case, and exits 0. Every row's guide hash matches `git hash-object` of the guide on
   that commit. If `reader-brief.md` exists, every reader row's prompt hash matches its
   `git hash-object` too. After task 1 merges and before task 2 runs, the command exits 1,
   since the folders aren't there.
2. `git diff --name-only origin/main` prints the guide, files under `$F`, and `reader-brief.md`
   if a reader case failed. It prints nothing else. Today it prints nothing.
3. Every line that `git diff origin/main` adds to the guide or to `reader-brief.md` is one of
   the four texts below, word for word, or is listed under `## For Geoff` with the check that
   called for it. The reviewer compares them. Today the diff is empty.

Three checks pass today and must still pass: the gate, `claude-tooling-sync verify`, and the
guide's limit of 1,000 words, which `wc -w` on the guide shows.

## The guide changes

Each change is made only when its check fails. Approving this spec approves these texts. The
trial runs say the length rule will be needed.

| Change | Made when | Where |
| --- | --- | --- |
| The length rule | A length check fails | Opens "What a spec carries" |
| A fixed form for a done item | The trap check of `write-check-passes-today` or `write-gate-red` fails | "A task's goal", after its first paragraph |
| An example of a bad and a good item | Either of those trap checks still fails after the fixed form | After the fixed form |
| A reader's brief | Any reader case fails | A new file, named in "Before approval" |

A failing check with no row here gets the smallest change of wording that answers it. The
builder writes it and shows it under `## For Geoff`. No change puts a word count in the guide,
since Geoff ruled for Anthropic's guidance and it gives none.

<details>
<summary>The four texts</summary>

The length rule:

> Match a spec's length to what its work needs. Cover the substance, and leave out filler
> sections, a summary that repeats another section, and boilerplate. A spec for a change that
> is one task covers each point of this list in a line or two, except the task and its goal. A
> point with nothing to say gets one line. A probe's output is quoted only where a done item or
> a label rests on it.

The fixed form:

> Write each item in one form: what is true when the task is done, the command that shows it,
> what that command prints today, and what it prints when the item holds.

The example:

> A bad item: "The README names the tool: `grep -c notes README.md` prints 1 or more." It
> prints 3 today, so it passes with nothing built. A good item: "The README documents the
> search: `grep -c 'notes search' README.md` prints 1. Today it prints 0."

The reader's brief, as `references/reader-brief.md`:

> You are about to build from the spec at `<path>`, in this repo, and nobody will be there to
> answer a question. Read the spec, then check it against the repo: run its commands and open
> the files it names. Change nothing.
>
> Report each thing that would stop you or send you the wrong way, most important first:
>
> 1. A question you would need answered before you could plan the work.
> 2. A done item that passes on a wrong result, or that already passes on today's code.
> 3. A done item nothing can meet, with the command you ran and what it printed.
> 4. A statement about the repo that is false today: a path, a count, a command's output, or
>    work the spec says has landed.
> 5. Two parts of the spec that disagree.
> 6. A file the work must change that the file list leaves out.
>
> For each, quote the spec's words and say what you found. Leave out anything a sensible
> builder would settle alone without changing what gets built.

With the brief, the first sentence of the guide's reader paragraph becomes:

> One fresh reader with no context checks the spec before Geoff sees it, briefed with
> `reader-brief.md`.

</details>

## What the work rests on

Each line was run on 2026-11-22 in Claude Code on pavilion.

- **A headless session can run shell commands and stay inside its folder.** A `claude -p`
  session with the sandbox settings above ran `git log`, `mktemp -d`, the fixture's gate, and a
  commit. A write to the home folder failed with "Read-only file system", and `curl` failed
  with "deny network-outbound". It refused no call it needed.
- **The Write tool stays inside the folder.** With `Edit(./**)` allowed, a write inside the
  folder worked. A write one folder up was denied.
- **The sandbox hides a path.** With `filesystem.denyRead`, `head` on the real denials log
  printed "Permission denied", and the installed guide read as missing.
- **A writing case works.** One session on Fable at `high` caught the trap in
  `write-missing-file`. It cost $3.61, took 502 seconds, and refused nothing. Its spec was
  3,550 words.
- **A reader case works.** Three readers cost $0.62, $0.63, and $0.66 and took 71 to 81
  seconds. Both planted mistakes were named.
- **The old cases still run.** All four ran on Sonnet in 3.5 to 12.2 seconds. Cases 1 to 3
  loaded the skill, and case 4 didn't, which is what it checks.
- **A small session is cheap.** Two Sonnet sessions at `low` cost $0.053 and $0.056, the basis
  for a judge call at about 5 cents.
- **The task's commands meet no standing refusal.** The denials log holds 149 rows since
  2026-11-01. None refuses `claude -p`. The 13 rows that mention `python3` and the 12 that
  mention `git add`, `git commit`, or `git push` were compound commands, a hook bypass, or a
  time when the classifier was down.

Searches in `~/.dotfiles` at `ac87235`:

| Search | Hits | What happens to them |
| --- | --- | --- |
| `Spec writing and review` | 1 | `SKILL.md:176` changes |
| `run_evals` | 2 | Both are stored results of 2026-11-21 and stay. The survey skill has a runner with the same file name, adapted from this one, and it stays as it is |
| `evals\.json` | 33 in 25 files | Three are in the runner, which changes. One is the inventory row, which stays true. The other 29 are stored results, other skills, and old plans, and they stay |
| `writing-a-spec` | 11 in 8 files | `SKILL.md:10` points at the guide and stays. Ten are other skills' stored results |
| `reader-brief` | 0 | The name is free |
| `spec-writing` | 4 | All four are another skill's stored results |

## The backlog sweep

The scoped sweep read `~/.dotfiles/BACKLOG.md` at `ac87235`. The backlog holds 63 open items,
and 31 were checked in the last 90 days.

| Item | Verdict | Reason |
| --- | --- | --- |
| 113, drop the deleted `approval-packet` skill from Vale's config | Keep | It still holds at `vale/.config/vale/.vale.ini:13`, and this work changes nothing under `vale/` |
| 94, give a one-pass design the fresh reader's launch question | Done | Commit `fd12321` deleted the process it names, and `writing-a-spec.md:76` gives every spec a fresh reader |

Nothing folds into the work. Approving this spec approves the two edits. Geoff's session stamps
item 113 and moves item 94 to Done once the checkout is free. The sweep also found 32 open items
with no recent check. That is past the 15 that make a full sweep due, and it waits for Geoff to
ask.

## Estimates

Minutes come from like tasks in `task-report` and the waits each task drives.

| Task | Like tasks, measured | Waits | Planned | Time limit |
| --- | --- | --- | --- | --- |
| 1 | 70, 98, and 155 minutes: three pull requests that built a test suite (23 in `standards`, 258 and 263 in the workstation). The middle one is 98 | One full run, 32 minutes at two sessions at once | 130 | 260 |
| 2 | 11 and 12 minutes: two pull requests that edited skill text (262 in the workstation, 22 in `standards`) | Three rounds of the six writing cases at 25 minutes each, and two full runs at 32 | 150 | 300 |

A full run takes 63 minutes one session at a time: 8.4 minutes for each writing case and 1.25
for each reader case. Both time limits still cover that.

| Cost | Dollars |
| --- | --- |
| One writing case | 3.61 |
| One reader case | 0.64 |
| One judge call | About 0.05 |
| One pass over the checks' samples | About 4 |
| One full run, with the judges | About 29 |
| Task 1: one pass over the samples and one full run, with room for reruns | Capped at 40 |
| Task 2: up to three rounds at 22, and two full runs | Planned at 80, capped at 130 |

## When something goes wrong

- **A session ends at its cost or time limit, or with an error.** The runner records how it
  ended, and the task reruns that case once. A second such end is listed under `## For Geoff`,
  and the done item that needs the row is marked unmet. It never counts against the guide.
- **A task's cost cap is hit.** The runner starts no further session. The task commits what it
  has, lists what didn't run, and ends.
- **A check fails its samples.** No Fable session starts until it passes. A judge that gives
  two different answers on one sample gets a narrower question, or a pattern takes its place.
- **The sandbox can't start.** The session exits at once, since `failIfUnavailable` is set, and
  the runner reports it. No session runs without the sandbox.
- **A check still fails after three rounds.** Task 2 runs the final pair anyway, marks its
  first done item unmet, and gives the evidence. It never changes a case to pass.
- **A check fails in the final pair.** The pair runs once, since the cap holds no money for a
  second. Task 2 marks its first done item unmet, and the pull request goes to Geoff that way.
- **A command is refused.** The session tries one other way, then leaves the step and lists it,
  as `building-from-specs` says.

## Before launch

Geoff's session checks these on the day, for each task.

- `claude-worktree-busy ~/.dotfiles` exits 0. On 2026-11-22 it exits 1, since another session
  has an uncommitted edit to `bluefin/git-excludes`. Neither task launches until that clears.
- `claude agents --json` shows no working session but Geoff's. Then the task runs two test
  sessions at once. With Geoff's session and the task's, that makes four. If another session
  is working, the task runs one test session at a time.
- Geoff reads the week's figure for Fable from `/usage`, since no command prints it. Task 1
  launches at 80 percent or less and task 2 at 70 or less, which leaves room for each cap.
- The task needs no secret and no CI.

## What is left to the builder

- How each fixture plants its trap, inside the trap its row names.
- The words of each brief, planted spec, prompt, judge question, and sample.
- How the runner is laid out inside, and the shape of an evidence file beyond the fields the
  summary prints.
- The wording of a guide change that has no row in the table.

## Found and not built

- The global `CLAUDE.md` says a dispatch uses "Opus for judgment". The skill's new sentence
  puts a spec's fresh reader on Fable. The skill is the closer rule for spec work, so this spec
  proposes no edit to the global file.
- `claude-infra` asks for an audit with `/skill-doctor` after a change to a skill. A task
  session can't run that command. Geoff's session can run it after task 2 merges.
- The reader's prompt lives in the `standards` plugin. If the reader's brief is built, the
  plugin's prompt stays as it is, and the two can be brought together later.
- A full backlog sweep is due in the workstation repo.

## Calls Claude made

1. The test has two kinds of case, since the guide has two parts a mistake can pass through: the
   writing and the fresh reader.
2. There are 16 cases. Anthropic's skill page asks for at least three, and its guide to testing
   agents says "20-50 simple tasks drawn from real failures is a great start." Writing cases
   cost six times what a reader case does, so more of the cases are reader cases.
3. Each case checks one narrow thing. A trial with five broad checks failed a good spec for
   using the word "expected" in a harmless place.
4. No case holds a clean spec, for the reason under [Reader cases](#reader-cases).
5. Today's result is one full run, and the final check is two. A case that fails once has shown
   a real failure. A case that passes once might be luck, and the two final runs catch that.
6. The work is two tasks, so the session that changes the guide didn't write the cases, and
   Geoff sees today's result before any change.
7. The four guide changes are written now and made only on a failure.
8. The reader's brief, if needed, lives in `building-from-specs`, which keeps the work in one
   repo.
9. The new Models sentence names the fresh reader with spec writing and leaves review on Opus.
   Geoff's ruling was about spec writing, and the reader's prompt already asks for the strongest
   model.
10. The cases go in the existing `evals.json`, so the inventory row stays true.
11. Stand-in files replace `task-report`, the denials log, and the remote in a writing case.
12. Both tasks run on Opus at `high`. Fable is the tighter weekly limit, and the test sessions
    need it.
13. The guide's limit is 1,000 words. The three changes that land in the guide add about 150
    to its 796, and the reader's brief is a separate file.
14. A trap check has a near-miss sample. The fresh reader of this spec showed that a name alone
    is weak evidence: `test_export_csv` appears twice in a trial report on a spec with no
    planted mistake.
15. A session that dies is rerun once and never counts against the guide.
16. The final pair of runs happens once, and a failure there is reported as unmet.
17. The length check's mark is 1,200 words, kept in the test and out of the guide. The reasons
    are under [How long a spec may be](#how-long-a-spec-may-be).

## Where each mechanism comes from

| Mechanism | Label | Source |
| --- | --- | --- |
| Test before changing a skill, then write the least that passes | Documented | The skill page, quoted under [Approaches](#approaches) |
| Cases drawn from real failures | Documented | "20-50 simple tasks drawn from real failures is a great start" (<https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents>) |
| A sample that must pass each check | Documented | The same page: "For each task, it's useful to create a reference solution: a known working output that passes all graders." |
| Checks by code first, a model where code can't judge | Documented | "Structure questions to allow for automated grading (for example, multiple-choice, string match, code-graded, LLM-graded)." (<https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>) |
| Fable at `high` for spec writing | Documented | Anthropic's guidance for Fable 5.2, which Geoff ruled for on 2026-11-22 |
| A headless session | Documented | "Add the `-p` (or `--print`) flag to any `claude` command to run it non-interactively." (<https://code.claude.com/docs/en/headless>) |
| The shell sandbox | Documented | "The sandbox covers shell commands only. Claude's file tools, MCP servers, and hooks run outside it." (<https://code.claude.com/docs/en/sandboxing>) |
| No retry outside the sandbox | Documented | With `"allowUnsandboxedCommands": false`: "With the retry disabled, Claude Code ignores the `dangerouslyDisableSandbox` parameter." (the same page) |
| Refusing what would prompt | Documented | `dontAsk`: "anything that would prompt is denied" (<https://code.claude.com/docs/en/permission-modes>) |
| Settings for one session | Documented | "Settings precedence, highest first: managed settings, command line, project local, shared project, user." (<https://code.claude.com/docs/en/settings>) |
| A spec-writing test run by `run_evals.py` with these pieces | Assembled | The trial runs under [What the work rests on](#what-the-work-rests-on) |
| A planted mistake for a fresh reader to find | Assembled | The same trial runs. The second reader is community practice, and no source found tests one |
| A spec's length matched to its work, with no number given to the writer | Documented | "Match the length of written documents to what the task needs" (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>), and the caution on hard limits (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2>) |
| A line or two for each point of a small change's spec | Community | The `superpowers` brainstorming skill, quoted under [How long a spec may be](#how-long-a-spec-may-be) |
| Detail that grows with the task | Community | The three articles quoted in the same section |
| A yes-or-no check in place of a quality call | Community | The grader-noise note in <https://github.com/obra/superpowers/pull/2644> |
| The test's mark of 1,200 words | Invented | Geoff's ruling that a long spec for a small change fails, and the five measured lengths |
