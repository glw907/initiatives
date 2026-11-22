# Brainstorming skill and plugin test spec

Status: waiting for Geoff's approval.

This spec rewrites the brainstorming skill in the `standards` plugin around the four corrections
Geoff made most often in 41 past brainstorming sessions. The new skill asks questions he can
answer from what he knows, looks things up before it asks, makes the calls that are the model's,
and keeps the work the size he asked for. The spec replaces the skill's one test with thirteen.
It regrades the plugin's four other tests with one fact to a grader, and it adds one command
that runs the whole suite and passes. The work is one task and one pull request in
`glw907/standards`, then four small edits in the workstation by Geoff's session. Three
questions wait for him, listed under [What Geoff decides](#what-geoff-decides). Everything else
here is his ruling, quoted, or a call Claude made, listed under
[Calls Claude made](#calls-claude-made).

To approve, Geoff answers the three questions and says the spec is approved, in his terminal.
Nothing launches before that. A different answer to question 1 or 2 changes the skill's text
or the cases. His session then revises the companions and runs the changed cases again, with
`bash scripts/run-evals.sh --case '<case>'` at about $1.60 a case, before the task launches. A
different answer to question 3 changes one number.

Three files sit beside this spec, and approving the spec approves their text:

- `2026-11-21-brainstorming-skill.txt` is the new `SKILL.md`.
- `2026-11-21-brainstorming-cases.py` writes the 13 brainstorming cases into the plugin's
  `evals` folder and regrades the four other cases.
- `2026-11-21-brainstorming-mockup-check.sh` checks the page the mock-up server shows.

The research behind it is in `research/2026-11-21-brainstorming-followup/`, and its `README.md`
is the short form.

## What Geoff decides

Each question has a recommendation, and the spec is written as if each recommendation holds.
Each question ends with what a different answer changes.

1. **What the rewrite aims at.** The skill's one test today checks that a first message asks a
   single question. In 41 sessions Geoff never complained about two questions in a message. He
   corrected the brainstorm in 35 of them, and most often for four things: a question he could
   not answer, a question it could have looked up, a call that was the model's to make, and
   work grown past what he asked for. Recommended: aim the skill and its tests at those four,
   and keep "one thing in a message" as a rule with a definition and a test. If he wants several
   questions allowed in one message, the rule comes out of the skill's text, and its grader,
   `one-ask`, comes out of the eleven cases that carry it.
2. **Whether a brainstorm does outside research.** Geoff asked this on 2026-11-21: "does it make
   sense for the brainstorming skill to try to do related outside research?" Recommended: yes,
   at one point and in a small amount. After it knows why he wants the thing, and before it lays
   out the approaches, it reads the vendor's docs and well-cited community practice for the
   choice in front of him, in a few lookups, and says where each approach comes from. His first
   reply comes from reading the project only, so it comes back fast. Research that needs more
   than a few lookups belongs to spec writing, which already requires it. If he wants none, one
   paragraph comes out of the skill's text, and the grader `says-where-each-comes-from` comes
   out of the case `lays-out-approaches`. If he wants a deeper search, the skill sends a
   subagent to do it, and each brainstorm then waits on that agent before the approaches
   message.
3. **How much the task may spend on suite runs.** One full run of the suite took 33 minutes.
   The command priced it at $27.30, and it used about 3 points of the week's usage on his
   subscription. The task needs two full runs in a row to show the suite is stable.
   Recommended: a ceiling of four full runs, about $110 as the command prices them and about
   12 points of the week. The two spare runs cover a run lost to an API error, or one restart
   of the pair after a late fix. With a ceiling of two, a single lost run ends the task with
   that done item unmet. A higher ceiling changes one number in the task's goal.

## What is wrong today

- **The skill asks questions Geoff can't answer.** In past sessions he turned down or
  sidestepped the opening question in 14 of 41 first replies. "I have no idea. I'm not a
  designer." "You can draft the design, unless you have any non-scripted questions." The second
  came after "think of the last round, what was the moment...". The new tests show it still
  does. A judge found the current skill's question answerable from what the user knows in 5 of
  18 replies, and in 17 of 18 with no plugin loaded.
- **It asks what it could look up, and asks him to make the model's calls.** Each kind drew a
  correction in 7 or 8 sessions. In one he replied "What's best practice here?" to a technical
  either-or, which is a question the model should have answered before it asked.
- **Its one test checks the thing he never complained about.** The case
  `brainstorming-one-question` grades a first message for a single question. Nothing tests the
  second message, a question the files could answer, the size of the design, or the wait for
  approval before building.
- **The plugin's suite fails.** `claude plugin eval plugins/standards` exited 1 on pull request
  22 in `glw907/standards`. The `ts-conventions` case scored 0.33 with the plugin and 0.33
  without it, because its one rubric demands a detail the skill steers away from. The
  brainstorming case scored 0.67. By default the command runs a case three times and passes it
  only when every grader passes every time. A behavior that holds nine times in ten fails that
  mark about one time in four.
- **Each of the five cases has one rubric, and each rubric checks several facts at once.** The
  judge passes or fails all of them together, so a failed case doesn't say which fact failed.
- **The skill ends in a "design doc" and sends the build to a plan.** The local process has a
  spec and tasks. Neither the skill nor `writing-a-spec.md` says that a brainstorm's written
  design is the spec, so a session can write the same design twice.
- **The mock-up page carries another project's brand.** The header of every screen shows a Prime
  Radiant logo loaded from `primeradiant.com` beside the word "Superpowers", and it links to
  `github.com/obra/superpowers`. The browser tab is titled "Superpowers Brainstorming". The
  skill came from that project, called upstream below. The logo is how upstream counts use: the
  server leaves it out when a telemetry variable is set.
- **The workstation can overwrite the skill.** The `brainstorming` entry in
  `claude/.claude/tooling/vendored-skills.json` points at `obra/superpowers`, so
  `claude-tooling-sync update-skills` would replace the rewritten skill with upstream's.

## What it is for

Geoff, on 2026-11-21: "look at current online and anthropic success patterns. Brainstorming is
especially critical, so we'll need to know what works best with the current models, and aligns
will with our local development patterns."

The goals:

- A brainstorm asks only what Geoff alone can answer, in words he can answer from what he knows
  today.
- It reads the project before it asks, and it makes method calls itself, with the reason and
  the published practice behind each.
- Its written design is the spec, written once by `writing-a-spec.md` and approved once.
- Every behavior above has a test, and the tests tell the rewrite from the current skill. The
  current skill passes 4 of the 13.
- The plugin's suite passes on one command, twice in a row, at a cost low enough to run before
  each change to a skill.

## What it leaves out

- No change to `building-from-specs` beyond two lines in `writing-a-spec.md`.
- No evaluation in CI. Geoff approved running evaluations on the workstation in the fourth
  question of the alignment spec, `specs/2026-11-20-alignment-spec.md`, and CI has no Claude
  sign-in.
- No test of a whole conversation. `claude plugin eval` has no simulated user, so each case
  tests one reply from a written history.
- No test that a web search was done well. A run has no web access unless the whole run grants
  it, so the cases check that the reply says where its approaches come from.
- No change to the `receiving-code-review` skill, which also came from upstream.
- No change to how the mock-up server stores or serves screens, and none to the browser it
  opens.
- No evaluation of spec writing. Geoff ruled on 2026-11-21 that it waits until the workstation
  is aligned.

## What would make it a failure

- Geoff's next brainstorm opens with a question that asks him to picture a scene, recall one
  incident, or guess why other people act as they do.
- The suite passes on one run and fails on the next with no file changed.
- The tests pass because their graders were loosened until the old skill passes them too.
- A full run costs or takes so much that no session runs it before changing a skill.
- A later `update-skills` run puts upstream's text back.

## Constraints

- At most four sessions work at once on pavilion, and each evaluation run is a session. A build
  session that runs the suite takes two of the four.
- `glw907/standards` is public. Every case uses a made-up club or shop, and the scan in
  `scripts/scan.sh` runs before each push.
- A skill file stays under 500 lines (`scripts/check-skill-lines.sh`). A description and its
  `when_to_use` share 1,536 characters in the listing.
- The skill came from `obra/superpowers` under the MIT license. The entry in
  `THIRD-PARTY-NOTICES` stays, and the mock-up server's files keep upstream's code.
- Only Geoff's session edits the two lists under `claude/.claude/tooling/` in the workstation.
- The plugin reaches the workstation by itself after a merge, because its marketplace entry has
  `autoUpdate` on.

## Approaches

Four were weighed. The second is the pick.

1. **Patch the current skill.** Keep upstream's 339 lines and add rules for the four
   corrections. It is the smallest diff, and a later upstream release could still be merged by
   hand. It keeps the parts that drew the corrections: a hard-gate tag, a table of red flags,
   and a "design doc" that hands off to a plan. The current skill passed 4 of the 13 new cases.
   Anthropic's Fable 5 guide says of this shape: "Skills developed for prior models are often
   too prescriptive for Claude Fable 5 and can degrade output quality." Source: Anthropic's
   prompting guide for Claude Fable 5.
2. **Rewrite the skill around the corrections (the pick).** A 206-line skill that keeps
   upstream's three measured ideas and states each of Geoff's four corrections as a rule with
   its reason and an example. The ideas kept are asking why first, asking only what would change
   the build, and plain-text questions. It costs the link to upstream: a later upstream
   improvement arrives only if someone reads it and carries it over. Source: upstream's skill
   and its pull request 2644 for the kept ideas, Anthropic's guides for the wording style, and
   `past-sessions.md` for the four corrections. In two full runs it passed all 13 brainstorming
   cases and 523 of 528 grader checks.
3. **Drop the skill and let the model interview.** Anthropic's best-practices page gives a
   one-line prompt for this: "Interview me until you could write the spec, then write it to
   SPEC.md." It costs nothing to maintain. With no plugin loaded, Fable passed 4 of the 13 cases
   and 64 of 111 grader checks. It asked five questions in a first reply, sized a small tool up,
   and asked about the build when the user was only gathering requirements. Source: Anthropic's
   best-practices page.
4. **Take another published brainstorming skill.** The research found none that is measured on a
   Claude 5 model. The current skill is already upstream's newest, version 7.0.2 at commit
   `22f0b463`, and upstream is the only source that publishes test results for its skill. Source:
   `research/2026-11-21-brainstorming-followup/README.md`.

## How the tests work

`claude plugin eval` runs each case as a fresh session with the plugin loaded, gives it the
case's prompt, and grades the one reply. A case can start from a written history, so a test of
the second or fourth message is a history file plus a prompt. Each case has several graders,
and each grader checks one fact. A grader is a pattern match, a count of tool calls, or a short
rubric that a judge model votes on three times.

The docs give the scoring: "A run's score is the fraction of its graders that passed, weighted
if you set weights, and the case's score is the mean across its runs. A case passes when its
score meets the `--threshold`, `1.0` by default."

### The cases

Thirteen cases test the brainstorming skill. Each row gives the history the case starts from,
counted in messages, and what its graders check.

| Case | Starts from | What it checks |
| --- | --- | --- |
| `first-question` | Nothing | The skill loads. The reply asks one thing Geoff could answer, offers no ready-made answers to it, and builds nothing. |
| `second-question` | 2 messages | One answerable ask, a plain restatement of what he said, and nothing built. |
| `cannot-describe` | Nothing | When he says he can't describe what he wants, the reply shows options. |
| `already-answered` | 2 messages | The reply uses an answer he already gave and doesn't ask for it again. |
| `how-is-the-models-call` | Nothing | The reply asks about what is his to decide and makes the method call itself. |
| `best-practice` | 2 messages | Asked "what's best practice here?", the reply answers with the practice and goes on. |
| `right-size` | Nothing | A small tool for a few people gets a small design. |
| `requirements-only` | Nothing | When he is gathering requirements, the reply asks nothing about the build. |
| `rough-number` | 2 messages | A number he called a guess is treated as rough. |
| `lays-out-approaches` | 4 messages | The approaches come numbered, with a recommendation, and each says where it comes from. |
| `approach-picked` | 6 messages | After he picks, the reply goes on with the conversation and writes no design yet. |
| `looks-it-up` | Nothing, with files | The reply names what it read and asks nothing the files answer. |
| `clear-task` | Nothing | A fully specified rename is done with no question, and the skill doesn't load. |

The four other cases keep their prompts. Each one's single rubric is split into one grader for
each fact: five for `ts-conventions`, three for `go-conventions`, three for `diff-reviewer`,
and four for `backlog-sweep`.

### What the cases found

Every run used Fable 5.2 with Sonnet 5.5 as the judge, on 2026-11-21. The rewrite ran the
full suite twice, at six runs a case. The current skill ran the 13 brainstorming cases once, at
three runs a case, and so did a session with no plugin loaded. A score of 0.8 or more passes.

One sentence of the skill's text changed after those two runs, to remove a contradiction a
reader found. The 13 brainstorming cases then ran once more on the final text, at six runs a
case. All 13 passed, with 263 of 264 grader checks. The one miss is `answerable` in
`rough-number`, which scored 0.94.

| Case | Rewrite, run 1 | Rewrite, run 2 | Current skill | No plugin |
| --- | --- | --- | --- | --- |
| `first-question` | 1.00 | 1.00 | 0.60 | 0.33 |
| `second-question` | 1.00 | 1.00 | 0.58 | 0.50 |
| `cannot-describe` | 1.00 | 1.00 | 0.50 | 1.00 |
| `already-answered` | 1.00 | 1.00 | 0.89 | 1.00 |
| `how-is-the-models-call` | 1.00 | 1.00 | 0.89 | 0.17 |
| `best-practice` | 1.00 | 1.00 | 0.50 | 0.50 |
| `right-size` | 1.00 | 1.00 | 1.00 | 0.00 |
| `requirements-only` | 1.00 | 1.00 | 0.75 | 0.22 |
| `rough-number` | 0.94 | 0.94 | 0.78 | 0.67 |
| `lays-out-approaches` | 1.00 | 1.00 | 0.58 | 0.50 |
| `approach-picked` | 1.00 | 1.00 | 0.78 | 1.00 |
| `looks-it-up` | 0.97 | 0.93 | 0.67 | 0.75 |
| `clear-task` | 1.00 | 1.00 | 1.00 | 1.00 |
| Cases that pass | 13 of 13 | 13 of 13 | 4 of 13 | 4 of 13 |
| Grader checks passed | 262 of 264 | 261 of 264 | 96 of 132 | 64 of 111 |

Seven cases have a grader for whether the skill loaded. A run with no plugin has no skill to
load. The command leaves that grader out of such a run, and the no-plugin column has 21 fewer
checks for it. The current skill's column and the rewrite's columns count every grader. The
command's printed report for the current skill's run left that grader out of each case's
score. It shows a lower score than this table in five cases.

The four other cases passed both runs. `ts-conventions` and `diff-reviewer` scored 1.00 each
time. `go-conventions` scored 0.83 and then 1.00, and `backlog-sweep` 0.93 and then 1.00. Run 1
showed that one rubric in `go-conventions` and one in `backlog-sweep` failed replies that were
right. Both rubrics were corrected before run 2, so those two cases ran once on their final
text. The other 15 cases were the same files in both runs.

Three things stand out in the grader counts.

- **The current skill makes its questions harder to answer than no skill does.** A judge found
  the question answerable from what the user knows in 5 of 18 replies with the current skill, in
  17 of 18 with no plugin, and in 67 of 72 with the rewrite. Two of the current skill's three
  first replies asked the user to "walk me through a season with the paper sheet".
- **With no plugin, a reply asks several things at once.** It kept to one ask in 6 of 33
  replies, and two of its three first replies were five numbered questions. The current skill
  kept to one in 21 of 33, and the rewrite in 132 of 132.
- **The rewrite's five misses are one grader on one kind of question.** Each is `answerable`
  failing on a question about why now, such as "What's prompting you to add an events calendar
  now?" The judge's three votes split on whether a user can answer that from what they know. The
  rubric stays as it is, and both cases still pass.

The current skill and the rewrite both score 1.00 on `right-size` and `clear-task`. Those two
cases are there to catch a rewrite that loses something the current skill does well.
`right-size` fails with no plugin. `clear-task` fails when the skill loads for a task that
needs no question.

### The command

`scripts/run-evals.sh` runs this from the repo's root and passes any further arguments through:

```bash
claude plugin eval ./plugins/standards \
  --runs 6 --ablation none --threshold 0.8 \
  --model claude-fable-5-2 --judge-model claude-sonnet-5-5 \
  --scaffold --trust-plugin --no-publish -j 1 --max-cost-usd 35 \
  --output-dir plugins/standards/evals/results \
  --json plugins/standards/evals/results/latest.json "$@"
```

Each flag was read against `claude plugin eval --help` in Claude Code 2.1.330 on 2026-11-21,
and the script ran from a fresh clone that day. A background session in auto mode, launched
with the task's `--settings`, ran it too. It started the script with `run_in_background`,
waited 21 minutes for the exit notice, and read exit 0.

- `--runs 6` is the count Geoff approved in the alignment spec's fourth question.
  `--ablation none` runs each case with the plugin loaded and skips the run without it.
- `--threshold 0.8` is the pass mark, the figure in the docs' CI example. A case with three
  graders has eighteen checks over its six runs, and it passes with up to three of them missed.
- `--model claude-fable-5-2` is the model Geoff's sessions run, and a brainstorm happens in his
  session. A run that names no model uses Opus 5.5, whatever the workstation's settings say.
- `--judge-model claude-sonnet-5-5` votes on each rubric three times.
- `--scaffold` lets `looks-it-up` build the small site it reads. `--trust-plugin` answers the
  trust prompt, which a background session can't. `--no-publish` keeps the report on the
  workstation.
- `-j 1` runs one session at a time, because each run counts against the four-session limit.
- `--max-cost-usd 35` stops a run that has gone wrong. The command exits 2 when it stops there.
- The results go to `plugins/standards/evals/results/`, which git ignores.

A full run is 102 sessions. It took 33 minutes and the command priced it at $27.30. On Geoff's
subscription the week's usage rose from 23 to 26 percent across that run, with one other task
working beside it.

A change to one skill needs only that skill's cases. `bash scripts/run-evals.sh --case
'brainstorming-*'` runs the thirteen, which took 22 minutes of the full run and $20.85 of its
cost. One case is about two minutes and $1.60.

## What gets built

One task, in `glw907/standards`, ending in one pull request. Geoff's session then makes four
edits in the workstation repo.

| Task | Repo | Built by | Waits for |
| --- | --- | --- | --- |
| The brainstorming skill and its tests | `glw907/standards` | A background session on Opus at high effort | Geoff's approval of this spec, and a free pair of sessions on pavilion |
| The workstation edits | `glw907/workstation` | Geoff's session, as one direct commit | The task's merge |

### The brainstorming skill and its tests

Paths are under `plugins/standards/` unless the row starts at the repo's root. Two reviewers
read the work: `standards:diff-reviewer` reads the whole branch, and
`standards:visual-verifier` reads the mock-up page's header. No sign-in or data path is touched.

| File | Change | Source |
| --- | --- | --- |
| `skills/brainstorming/SKILL.md` | Replaced with the companion `2026-11-21-brainstorming-skill.txt`, byte for byte. | Companion text |
| `evals/` | `python3 -I <companion cases script> plugins/standards/evals` is run once. It removes `brainstorming-one-question`, writes the 13 brainstorming cases, and replaces each of the other four cases' `criteria.md` with a `graders/` folder. The script itself is not committed. | Companion script |
| `skills/brainstorming/scripts/server.cjs` | The brand and telemetry code comes out: the four constants at lines 105 to 112, `readSuperpowersVersion()`, `isTruthyEnv()`, `brandMarkup()`, `renderBranding()` and its two calls, the four `.brand` style rules, and the `<!-- BRANDING -->` marker in the waiting page. A helper left with no caller comes out too. | `grep -c -i superpowers` prints 12 today |
| `skills/brainstorming/scripts/frame-template.html` | The title becomes `Brainstorm Companion`, the title the waiting page already has. The six `.brand` style rules and the `<!-- BRANDING -->` marker come out, with any rule left empty. | `grep -c -i superpowers` prints 1 today, and `grep -c '\.brand'` prints 6 |
| `skills/brainstorming/visual-companion.md` | The three sections for Codex, Gemini CLI, and Copilot CLI come out (lines 87 to 108 today). | `grep -c -i 'codex\|gemini\|copilot'` prints 5 today |
| `scripts/check-mockup-page.sh` (root) | New, from the companion `2026-11-21-brainstorming-mockup-check.sh`, byte for byte. | Companion script |
| `scripts/run-evals.sh` (root) | New. It holds the command under [The command](#the-command), with those flags and those two result paths, and it is run from the repo's root. | This spec |
| `.gitignore` (root) | New. It leaves out `plugins/standards/evals/results/` and the session files a run leaves in a case folder, and it keeps each `history.jsonl`. | A run leaves both today |
| `THIRD-PARTY-NOTICES` (root) | The `brainstorming` entry gains a last line, after its copyright line (line 130 today): `Modified: SKILL.md is rewritten here, visual-companion.md has three sections removed, and the files under scripts/ have upstream's brand and telemetry code removed.` | The MIT license's notice |
| `README.md` (root) | "What is here" gains one line for `plugins/standards/evals/` and `scripts/run-evals.sh`, saying the suite runs on a workstation and what a full run costs. The line names no person and no host, which `scripts/scan.sh` checks. | This spec |
| `agents/visual-verifier.md`, `agents/figure-verifier.md`, `BACKLOG.md` (root) | Item 1 of the repo's backlog: line 3 of the first and line 17 of the second name the old process ("any visual-fidelity pass", "a pass worktree"). Each is reworded so a reader who never used that process can place it, and the item is closed. | Backlog sweep |

The folder name `.superpowers/` stays. The server's scripts write a project's mock-ups under it,
and a project that already has that folder keeps working.

The steps run in this order.

1. Before it edits the server's files, the session takes the first screenshot. It starts the
   server with `start-server.sh --project-dir` on a folder from `mktemp -d`. It reads `url` and
   `screen_dir` from the `server-info` file, as `check-mockup-page.sh` does. It writes one
   screen with two options into `screen_dir`, runs `chromium-shot "$url" -o` with a file in
   that folder, and stops the server with `stop-server.sh`. Nothing is written inside the
   worktree.
2. It builds every row of the table. Before each push it runs each command in
   `.github/workflows/validate.yml`.
3. It takes the second screenshot the same way, with the same screen file, from a server
   started after the edits. The server reads its page template once, at start.
   `standards:visual-verifier` gets the two images and one question: is the layout the same,
   and does the new header hold only the connection status?
4. It pushes, opens the draft pull request, and sends the branch to `standards:diff-reviewer`.
5. The two suite runs come last, on the pull request's last commit, after the reviewer's
   final read of that commit. A commit made after a suite run starts the pair again.
6. It marks the pull request ready when every done item is met. With one unmet, the pull
   request stays a draft, and `## For Geoff` says what is left.

The session starts `scripts/run-evals.sh` at most four times, each a full run with no `--case`.
A full run takes about 33 minutes, and a foreground command is stopped after ten. Each run
starts with the Bash tool's `run_in_background`, and the session waits for its exit notice. A
run cut off partway counts as a start.

After each run the session copies `latest.json` to `run-1.json`, `run-2.json`, and so on in
the same ignored folder, because the next run overwrites it. A run that exits 0 is a pass. A
run is lost when it exits non-zero and either wrote no result file or holds a run record whose
`error` isn't null. A lost run counts as a start and is left out of the pair, so a pass, a
lost run, and a pass are two passes in a row. Any other run that exits non-zero is a failed
run. A failed run is read from its result file and is never run again to see if it passes.

At 22:25 on 2026-11-21 no session was working in `~/Projects/standards` or in `~/.dotfiles`
(`claude agents --json`). Geoff's session launches the task only when
`claude-worktree-busy ~/Projects/standards` exits 0 and
`git -C ~/Projects/standards status --porcelain` prints nothing. The `standards` repo has no
status file. `~/.dotfiles/docs/STATUS.md`, read that day, lists no open step that touches a
file named in this spec.

Done items:

- `bash scripts/run-evals.sh` exits 0 twice in a row on the pull request's last commit, with
  no lost run counted. `git rev-parse HEAD` prints that commit before the first run and after
  the second. Today the
  script doesn't exist, so the command prints `bash: scripts/run-evals.sh: No such file or
  directory`, and `claude plugin eval plugins/standards` exited 1 on pull request 22.
- `git status --porcelain` prints nothing after those two runs. Today a run leaves a `results`
  folder and a session file in each case that starts from a history.
- `bash scripts/check-mockup-page.sh` exits 0 and prints `brand words: 0` and `outside
  addresses: none`. Today it exits 1 and prints `brand words: 13` and two addresses, at
  `github.com/obra/superpowers` and `primeradiant.com`.
- `diff plugins/standards/skills/brainstorming/SKILL.md <companion skill text>` prints nothing.
  Today it prints a diff of every section.
- `find plugins/standards/evals -name prompt.md | wc -l` prints 17, where today it prints 5.
  `find plugins/standards/evals -name criteria.md | wc -l` prints 0, where today it prints 5.
- `git ls-files 'plugins/standards/evals/*/history.jsonl' | wc -l` prints 6, where today it
  prints 0.
- `grep -c -i 'codex\|gemini\|copilot'
  plugins/standards/skills/brainstorming/visual-companion.md` prints 0, where today it prints 5.
- In `plugins/standards/skills/brainstorming/scripts/server.cjs`, `grep -c -i superpowers`
  prints 0 where today it prints 12, and `grep -c '\.brand\|BRANDING'` prints 0 where today it
  prints 6.
- In `plugins/standards/skills/brainstorming/scripts/frame-template.html`, `grep -c -i
  superpowers` prints 0 where today it prints 1, and `grep -c '\.brand'` prints 0 where today
  it prints 6.
- `standards:visual-verifier` reports the same layout in the two screenshots and a new header
  that holds only the connection status. Today the header shows the logo and the word
  "Superpowers".
- `grep -c 'Modified:' THIRD-PARTY-NOTICES` prints 1, where today it prints 0.
- `grep -c 'visual-fidelity pass' plugins/standards/agents/visual-verifier.md` prints 0, and so
  does `grep -c 'pass worktree' plugins/standards/agents/figure-verifier.md`. Today each
  prints 1.
- Two guards pass today and must still pass. `node --check
  plugins/standards/skills/brainstorming/scripts/server.cjs` exits 0, and the `validate` check
  is green on the pull request's last commit.

### The workstation edits

Geoff's session makes these after the task's pull request has merged, as one commit on `main`
in `~/.dotfiles`. His session loads the `claude-infra` skill for the change, because
`writing-a-spec.md` is part of the process skill. The commit is direct under Geoff's ruling of
2026-11-08: "PRs are for large efforts, not small fixes." His approval of this spec approves
the exact words of each edit.

Before the first edit the session runs `claude-worktree-busy ~/.dotfiles` and goes on only when
it exits 0. It stages the four files by name. Two files in that checkout belong to another
session and stay untouched: `claude/.claude/docs/bluefin-admin/google-workspace.md` and
`bin/.local/bin/sheet-revision`.

| File | Change | Source |
| --- | --- | --- |
| `claude/.claude/tooling/vendored-skills.json` | The `brainstorming` entry comes out (lines 88 to 98 today). `receiving-code-review` stays. | `update-skills` with no name would otherwise open a pull request that puts upstream's text back |
| `claude/.claude/docs/claude-tooling.md` | The "Superpowers" bullet at lines 159 and 160 becomes: "**Superpowers:** gone as a plugin (2026-11-10). `standards:receiving-code-review` stays vendored from it (MIT). `standards:brainstorming` began as its skill and is now written and tested in `glw907/standards`." | The bullet names both as vendored today |
| `claude/.claude/skills/building-from-specs/references/writing-a-spec.md` | Two additions, given below. | The local read |
| `BACKLOG.md` | Item 74, which asks for a test suite for the `brainstorming` skill, is closed with the pull request's number. | Backlog sweep |

The two additions to `writing-a-spec.md`:

- Under "Before the design", a new paragraph: "When a brainstorm ends in a written design, that
  design is the spec. Write it once, by this guide, and bring it to Geoff once."
- In the list under "What a spec carries", after the approaches: "What happens when it goes
  wrong, and the number for each limit."

Done items, each checked by Geoff's session and posted as a comment on the task's merged pull
request:

- `grep -c brainstorming claude/.claude/tooling/vendored-skills.json` prints 0, where today it
  prints 2, and `claude-tooling-sync verify` passes.
- `grep -c -i 'brainstorm ends'
  claude/.claude/skills/building-from-specs/references/writing-a-spec.md` prints 1, where today
  it prints 0. `grep -c -i 'goes wrong'` on the same file prints 1, where today it prints 0.
- `bash scripts/gate.sh` passes in `~/.dotfiles`.
- `claude plugin list` shows the user-scope `standards@glw907-standards` at the merged commit,
  and a fresh session lists the new description for `standards:brainstorming`.
- Geoff's session starts the mock-up server from the installed plugin, takes one screenshot of a
  screen with `chromium-shot`, and reads it. The header shows the connection status and no logo.
  A trimmed scratch copy rendered that way on 2026-11-21.

## What the work rests on

Each row is something the task assumes, with the probe that was run on 2026-11-21 and what it
printed. The least-proven one is that the suite passes twice in a row, which is why the task
ends on two full runs.

| Assumption | Probe | Result |
| --- | --- | --- |
| The suite passes twice in a row | A fresh clone at `61f996a` with the first eight rows of the task's table applied, then `bash scripts/run-evals.sh` twice | Exit 0 both times, with 17 of 17 cases passing. The lowest case scored 0.83 in the first run and 0.93 in the second. Between the runs one rubric changed in `go-conventions` and one in `backlog-sweep`. The other 15 cases were the same files in both runs. |
| The command takes a full model name for the run and for the judge | One case, one run, with `--model claude-fable-5-2 --judge-model claude-sonnet-5-5` | Exit 0. The result file records `"modelOverride": "claude-fable-5-2", "judgeModel": "claude-sonnet-5-5"`. |
| A case can start from a history written by hand | Trial 2 in the research folder's `evaluation-trials.md`, then every case above that starts from messages | The reply answers the last message of the history in each one. |
| A grader can require that the skill was never called | `clear-task` with `min: 0` and `max: 0` | `skill-not-fired` passed 12 of 12 with the rewrite and 3 of 3 with the current skill. In the same result files `skill-fired` passed in the six cases where the skill loads, so the tool sees the call. |
| The repo's CI checks pass with the change | The same clone, then each command in `.github/workflows/validate.yml` | All eight exit 0. The last three rows of the task's table change words in five text files and were not in the clone. Both `claude plugin validate` runs print "Validation passed with warnings", as they do on `main`. |
| The trimmed server shows the same screens with no brand | `check-mockup-page.sh` on that clone, and one screenshot before and after | Exit 0, `brand words: 0`, `outside addresses: none`. The two-option screen lays out the same, and the header holds only "Connected". |
| The screenshot step works as written | Step 1's commands on that clone, with a `mktemp -d` project folder | Each exits 0. `chromium-shot` given the `url` from `server-info` writes a picture of the screen. Every file the commands wrote is in that folder. |
| A run leaves nothing for git to see | `git status --porcelain -uall --ignored` in that clone after each full run | Git shows nine ignored paths. Three are files under `plugins/standards/evals/results/`. Six are session files named `11111111-1111-4111-8111-111111111111.jsonl`, one in each case that starts from a history. Every other path it shows is part of the change. |
| Taking the entry out of `vendored-skills.json` breaks neither workstation check | Two scratch copies of the tracked `claude/` tree, one with the entry removed, each run through `claude-tooling-sync lint` and `verify` | `lint` exits 0 on both. The two `verify` outputs differ by one line, `+ brainstorming (in the standards plugin)`. |
| The merged plugin reaches the workstation with no step | `claude plugin list` after pull request 22 merged as `61f996a` | `standards@glw907-standards`, user scope, `Version: 61f996aa3eb3` |
| The update command works when the plugin hasn't updated itself | `claude plugin update standards@glw907-standards` | Exit 0, and it prints `standards is already at the latest version (61f996aa3eb3).` |
| A background session can run the suite | A session launched from `~/Projects/standards` with `claude --bg`, `--permission-mode auto`, and the task's `--settings`, told to run `bash scripts/run-evals.sh --case 'brainstorming-*'` in the clone | No call was refused. The session started the script with `run_in_background`, waited 21 minutes, and read exit 0. All 13 cases passed for $20.30, and no run record held an error. |
| A task session can read a companion file in this repo | "The process skill", workstation pull request 258, whose session ran `diff` between each companion text here and the file it built | Both `diff` runs printed nothing and exited 0, from a worktree of another repo. |

The workstation logs each command a permission rule refuses, in
`~/.local/state/claude-denials.jsonl`. No command the task runs is in its 148 rows, which run
from 2026-11-01 to 2026-11-21. A search of them for `plugin eval`, `start-server`,
`stop-server`, `chromium-shot`, `gh pr create`, `gh pr ready`, and the two new scripts' names
finds none. `git push` was refused 4 times: three pushes to `HEAD:main` and one that deleted a
remote ref. `curl` was refused twice, each for an address outside the workstation. The task
pushes the branch it made, and its one `curl` reads `localhost`.

## The backlog sweep

The sweep covered the open items that name the `standards` repo, its evaluations, or a
vendored skill.

| Item | Verdict | Why |
| --- | --- | --- |
| `standards` 1, reword the old "pass" sense in the two verifier agents | Fold | Two lines in a repo the task already has open. It is the last row of the task's table. |
| Workstation 74, add a test suite for the `brainstorming` skill | Done by this spec | The thirteen cases are that suite. The workstation edits close it. |
| Workstation 38, catch an edit made only in a vendored skill's copy | Keep | Still true: `claude-tooling-sync lint` checks no content. This spec avoids the bug for one skill by taking its entry out. |
| Workstation 39, the rule that a read-only agent stops only the processes it started | Keep | Still true: no agent file in the plugin names `pkill`. It is no part of brainstorming or the tests. |
| Workstation 60, tighten `visual-verifier` to 4.5:1 | Keep | Still true at line 30 of the agent. It changes what a reviewer flags, which this spec doesn't test. |
| Workstation 93, move the due full sweep out of `standards:backlog-sweep` | Keep | Still true at line 22 of that skill. The alignment spec's last task removes the override this item pairs with. |

<details>
<summary>The file searches behind the two tables of files</summary>

`grep -rl -i 'brainstorm' . --exclude-dir=.git --exclude-dir=worktrees` in
`~/Projects/standards` finds 11 files. The second exclusion skips the old worktrees under
`.claude/worktrees/`.

- In the task: `skills/brainstorming/SKILL.md`, `visual-companion.md`, `scripts/server.cjs`,
  `scripts/frame-template.html`, and `THIRD-PARTY-NOTICES`.
- Removed by the cases script: `evals/brainstorming-one-question/prompt.md` and its
  `graders/skill-fired.md`.
- Left alone: `scripts/helper.js`, `scripts/start-server.sh`, and `scripts/stop-server.sh`. Each
  hit is a variable, a function, or the `.superpowers/brainstorm/` folder, which keeps its name.
- Left alone: `tests/check-skill-lines-test.sh`, which uses the path in a tree it builds itself.

The same command with `'superpowers\|human partner'` and `--exclude-dir=brainstorming` finds
two files: `THIRD-PARTY-NOTICES`, in the task, and `skills/receiving-code-review/SKILL.md`,
listed under [Found and not built](#found-and-not-built).

`grep -rl 'brainstorming' ~/.dotfiles --exclude-dir=.git --exclude-dir=worktrees` finds 12
files.

- In the workstation edits: `BACKLOG.md`, `claude/.claude/docs/claude-tooling.md`, and
  `claude/.claude/tooling/vendored-skills.json`.
- Removed by the alignment spec's last task: `bin/.local/bin/claude-pass-load`,
  `tests/claude-pass-load.test.sh`, `claude/.claude/skills/pass-core/SKILL.md`, and
  `pass-core/references/round.md`.
- Left alone: three dated records under `docs/model-review/` and two under `docs/plans/`.

</details>

## Estimates

A task's minutes come from the measured minutes of a like task, plus the waits the task
drives. The nearest like task is the workstation's pull request 258, which built a skill with
its evaluation cases. It took 98 measured minutes. This task writes less, because the skill's
text and the cases arrive finished. The `standards` repo's last four tasks took a median of 16
minutes, and 40 at the ninetieth percentile (`task-report --repo standards`, 2026-10-23 to
2026-11-22). The estimate uses the larger figure.

| Task | Work | Waits it drives | Minutes | Time clause |
| --- | --- | --- | --- | --- |
| The brainstorming skill and its tests | 98 minutes | Two full suite runs at 33 minutes each | 164 | 328 minutes |

The time clause is twice the minutes. It leaves room for all four suite runs the ceiling
allows, which with the work come to 230 minutes. The CI wait in this repo has a median of 0.3
minutes and is left out. `planPathMin` in the pull request's score comment is 164.

The workstation edits take Geoff's session one sitting and carry no estimate.

The task and its suite run are two sessions, and the limit on pavilion is four. The task
launches when two or fewer sessions are working. At 22:25 on 2026-11-21 only Geoff's session
was working. A second task can run beside this one if it starts no further session.

## When something goes wrong

| What happens | What follows |
| --- | --- |
| The suite fails one of its two runs | The session reads the failing case's replies and the judge's reasons in the result file. It quotes them under `## For Geoff` and marks the done item unmet. It changes no word of the skill, a case, or a rubric, because those are the companions and they change only in this spec. Geoff's session then revises the companion and launches a fresh session on the branch. |
| A run is lost to an error | The run exits non-zero, and it wrote no result file or a run record's `error` isn't null. The session quotes the error in the pull request and starts the run again if that stays within four starts. |
| The session has started the suite four times | It starts no fifth run. It reports what the four showed and marks the done item unmet. |
| A run stops at the cost cap | The command's `--max-cost-usd` is 35 dollars, and a full run costs about 27. The session reports the partial result and marks the done item unmet. |
| A permission rule refuses a suite run | The session tries one other way. After a second refusal it finishes everything else and lists the two runs under `## For Geoff`. Geoff's session then runs them on the branch's last commit and posts the result on the pull request before the merge. |
| `chromium-shot` is refused or fails | The session lists the visual review as a step left. The screenshot Geoff's session takes after the merge covers it. |
| Fewer than two sessions are free on pavilion | Geoff's session doesn't launch the task. A suite run is one session beside the build session. |
| `check-mockup-page.sh` exits 2 | The server didn't start. The session reads the script's output, which carries the server's message. |
| The task reaches its time clause | It commits, pushes, and writes what is left in its draft pull request. Geoff's session launches a fresh session on that branch. |
| The reviewer returns a fix verdict twice | The findings are listed in the pull request for Geoff. |
| A done item can't be met | The session marks it unmet with the reason. It never edits the item, a case, or a rubric to match what it built. |
| The plugin doesn't update itself after the merge | Geoff's session runs `claude plugin update standards@glw907-standards` and reads the version. |

Limits: four working sessions on pavilion, of which this task takes two; four suite runs in
the task; six runs a case; a pass mark of 0.8; 35 dollars a suite run; 500 lines in a
`SKILL.md`, where the new one has 206; 1,536 characters for a description in the listing,
where the new one has 341; about 150 words in the skill's first message.

## What done looks like

When the pull request has merged and the workstation edits have landed, Geoff can check the
whole of it:

- He asks a fresh session to brainstorm something. Its first reply names what it read, asks one
  question he can answer from what he knows, and offers to skip the questions.
- When he asks "what's best practice here?", it answers and goes on.
- The approaches come as a numbered list with a recommendation, and each says where it comes
  from.
- The design it writes is the spec, in `specs/`, written once.
- The pull request shows two suite runs in a row that exit 0 on its last commit.
- A mock-up page shows no logo and loads nothing from another site.
- `claude-tooling-sync update-skills` no longer names `brainstorming`.

## What is left to the builder

- The wording of the two reworded agent lines, the README line, and the comments in the two new
  scripts.
- The patterns in `.gitignore`, so long as `git status --porcelain` prints nothing after a run
  and each `history.jsonl` stays tracked.
- Whether `escapeHtmlText()` or another helper in `server.cjs` is left with no caller, and so
  comes out.
- The screen used for the two screenshots, so long as both show the same one.

The skill's text, the cases, and the rubrics are not left to the builder. They are the
companions, and the suite's scores in this spec were measured on them. The order of the
reviews and the suite runs is fixed above.

## Found and not built

- The `receiving-code-review` skill says "human partner" in 9 places. It also came from
  upstream, and the alignment spec left it alone.
- The `standards` checkout has ten worktrees from past tasks, eight under
  `~/Projects/standards-wt/` and two under `.claude/worktrees/`.
- The mock-up server opens the default browser. On pavilion that is Chromium, as the browser
  rules want. On thinkpad-x1 it is Zen.
- `check-mockup-page.sh` is not added to the `validate` check. It needs a server started on the
  CI runner, which nothing has tried.
- `claude plugin list` shows eleven project-scope installs of the `standards` plugin beside the
  user-scope one, each at an older version. Ten belong to `~/Projects/cairn-cms` and its
  worktrees, and one to a past job's copy of that repo. A brainstorm in that repo may load the
  older skill until its install is updated. Cairn is outside this spec.
- The suite runs on Fable 5.2 only. Trials 1 to 4 in `evaluation-trials.md` named no model and
  so ran on Opus 5.5, on an earlier draft of the skill. The final text was not run on Opus 5.5
  or Sonnet 5.5. A task session on Opus that brainstorms is untested.
- Whether the rewrite changed Geoff's real brainstorms is answered only by reading his next
  ones, as `past-sessions.md` read the last 41. No task here does that.

## Calls Claude made

Method calls are Claude's. Each is listed so Geoff can overrule it.

- The skill asks in plain text and never calls the question tool. Upstream's maintainer:
  "We explicitly reject AskUserQuestion. In our experience, it leads to a dramatic reduction in
  human reading and engaging with the questions being asked." The numbered picks that worked in
  past sessions were plain text too.
- "One thing in a message" is defined as one answer needed from the user, with four examples of
  a second ask. Anthropic's Sonnet 5 guide says the model "does not silently generalize an
  instruction from one item to another", so a rule that names no cases covers none.
- The why question comes first and carries no example answers. Upstream measured that cutting
  the question lost the reason for the work, and that example answers steer it.
- Every first message offers to skip the questions. Geoff used that offer in past sessions.
- The skill has no hard-gate tag and no table of red flags. Each rule is a plain sentence with
  its reason. Anthropic's best-practices page: "Current ones follow a plainly worded line, and
  piling on emphasis mostly makes Claude over-apply the rule."
- The skill says "the user" where upstream says "your human partner".
- The written design is the spec. Where a repo has a guide for specs, the skill follows it and
  writes one document.
- The fresh reader of a written design runs on the strongest model the session can name.
- The skill's examples use a hall booking. No case uses one, so a case can't pass by copying
  the skill's example.
- Each grader checks one fact, and a regex stands beside a judge where a pattern can decide.
- The judge is pinned to Sonnet 5.5. The default judge is a small model, and the docs tell an
  author to rerun with a stronger one. In trial 1 of `evaluation-trials.md` Sonnet's three
  votes agreed on 23 of 24 checks.
- The suite runs each case six times, the count Geoff approved in the alignment spec's fourth
  question, with a pass mark of 0.8 in place of the default 1.0.
- The run model is pinned by its full name, so a new model can't be mistaken for a broken skill.
- The suite is a workstation command and no CI check, as the alignment spec's fourth question
  ruled.
- The with-and-without comparison was run once for this spec and is not part of the task.
- The mock-up server stays, trimmed. Geoff's corrections asked to be shown options when he
  couldn't describe what he wanted, and the server is how the skill shows a layout.
- `.superpowers/` stays as the folder name for a project's mock-ups.
- `builder-check-prompt.md` is unchanged. Its "plan" is the ordinary word.
- One task holds the skill, the cases, and the server trim. The cases can't pass without the
  new skill, and the trim touches three files.
- The four workstation edits land as one direct commit by Geoff's session. One of them is to a
  list only his session edits, and each of the others is a sentence. Four sentences are more
  than the process skill's bar of one for a direct change. The call rests on Geoff's ruling of
  2026-11-08, quoted under [The workstation edits](#the-workstation-edits).
- A failing suite run is reported and never fixed inside the task. The skill's text, the cases,
  and the rubrics change only in this spec.
- The task's minutes use the 98 measured minutes of the workstation's pull request 258, the
  larger of the two measured figures.
- The suite runs come after the review, so a fix the reviewer asks for doesn't cost a second
  pair of runs.
- The cases script checks no argument. The spec gives its one command.

## Where each mechanism comes from

Each source's address is in the research folder, in `anthropic-skill-authoring.md`,
`anthropic-evaluations.md`, `community-elicitation-patterns.md`, and `superpowers-upstream.md`.

| Mechanism | Label | Source |
| --- | --- | --- |
| An interview, then a written spec, then a fresh session that builds from it | Documented | Best practices: "Once `SPEC.md` exists, start a fresh session to build from it" |
| A skill that says it relies on asking, so auto mode doesn't skip the questions | Documented | Permission modes: "Claude still asks when your prompt or a skill explicitly relies on it" |
| Plain wording with the reason, and no capitals or hard-gate tag | Documented | Best practices, the "stop doing" table; `skill-creator`: "Try to explain to the model why things are important" |
| A rule that names the cases it covers | Documented | Sonnet 5 prompting guide, "More literal instruction following" |
| A shorter skill for a current model | Documented | Fable 5 prompting guide: "Skills developed for prior models are often too prescriptive" |
| Ask only when the answer would change what gets built and nothing already answers it | Community | `obra/superpowers`, `skills/brainstorming/SKILL.md` at 7.0.2 |
| Ask why first, with no example answers | Community | `obra/superpowers` pull request 2644: "Removing the mandatory question alone made things worse" |
| Plain-text questions in place of the question tool | Community | `obra/superpowers` issue 1197, the maintainer's comment of 2026-04-17 |
| Questions answerable from what the user knows; no scene, incident, or guess at others' reasons | Invented | No source names it. It is the correction Geoff made most often, the first row of the corrections table in `past-sessions.md`. The cases measure it with the `answerable` grader. |
| "One thing" defined as one answer needed | Invented | No source defines it. The cases measure it. |
| A few lookups of published practice before the approaches, with each approach's source named | Assembled from documented pieces | `writing-a-spec.md` already requires a label on each mechanism; Geoff's question of 2026-11-21 |
| `claude plugin eval` cases, `regex`, `llm`, and `tool_used` graders | Documented | Plugin evaluations page |
| One grader for each fact, with concrete PASS and FAIL conditions | Documented | Same page: "Keep `llm` graders for short outputs, with rubrics written as concrete PASS and FAIL conditions" |
| A case that starts from a hand-written history | Assembled from documented pieces | The page documents `context.history_file` and not its format. Trial 2 in `evaluation-trials.md` shows two hand-written rows load. |
| A pinned run model and a stronger judge | Documented | Same page: "Pin it in CI so a model rollout isn't mistaken for a plugin regression"; `--judge-model` |
| A case where the skill should not fire | Documented | Same page: "To assert a tool was never called, set both `min: 0` and `max: 0`" |
| A pass mark under 1.0 | Documented | Same page's CI example uses `--threshold 0.8`. The number here comes from this spec's runs. |
| Six runs a case | Invented | Anthropic gives no number for a behavior that varies. Upstream uses "5+ reps per variant". Geoff approved six in the alignment spec. |
| `scripts/run-evals.sh` and `scripts/check-mockup-page.sh` | Invented | Each wraps documented commands so one line runs them the same way each time |
