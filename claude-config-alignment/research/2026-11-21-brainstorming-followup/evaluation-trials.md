# Trials of the evaluation command

Geoff's session ran these on pavilion on 2026-11-21 with Claude Code 2.1.330, against a scratch
copy of `plugins/standards` at `61f996a`. Each ran one session at a time. The scratch copy held
its trial cases in a folder named `probe-evals`, and nothing in the `standards` repo changed.

## Trial 1: the first message, one fact to a grader

The case uses the prompt of `evals/brainstorming-one-question` unchanged. Its one rubric is
split into four graders, and the `tool_used` grader for the skill stays.

| Grader | Type | Passes when |
| --- | --- | --- |
| `question-marks` | `regex`, `pattern: '\?'`, `match: "count:1"` | The reply holds exactly one question mark |
| `one-ask` | `llm` | The reply asks the user to answer one thing, with nothing joined by "and" or commas |
| `open-why` | `llm` | The question is open and offers no set of answers to pick from |
| `no-building` | `llm` | The reply holds no code, data model, screen layout, or implementation steps |
| `skill-fired` | `tool_used` | The `Skill` tool was called |

```bash
claude plugin eval <copy> --eval-dir probe-evals --case 'one-question' --runs 8 \
  --ablation none --judge-model sonnet --trust-plugin --no-publish -j 1 \
  --json out1.json --output-dir out1 --max-cost-usd 3
```

It exited 1 after 132 seconds and $1.11. The case's mean score was 0.825, and 2 of 8 runs
passed every grader.

| Grader | Runs passed of 8 |
| --- | --- |
| `question-marks` | 8 |
| `skill-fired` | 8 |
| `no-building` | 8 |
| `one-ask` | 4 |
| `open-why` | 5 |

What it shows:

- A count of question marks misses the compound question. All four replies that failed
  `one-ask` hold one question mark, as in "What happens with it today, and what goes wrong that
  made you want to move it online?"
- The Sonnet judge agreed with itself. Its three votes matched in 23 of 24 gradings.
- `open-why` is not yet a usable rubric. Every one of the eight replies followed its question
  with possible answers ("If the problem is that members can't sign up unless they're at the
  clubhouse..."). The judge failed the three that word them as guesses ("Maybe duty slots go
  unfilled...") and passed the five that word them only as consequences.
- The skill produces the compound question in half its first messages, so the wording of the
  skill is what has to change. A better grader only makes that visible.
- `--runs 8` overrides the case's own count, and `--judge-model sonnet` is accepted.

## Trial 2: a case that starts from a history

The docs say `context.history_file` takes "a `.jsonl` transcript in the case directory to
resume", and say nothing about its format. Two cases asked for a fact that only the history
holds. Each has this `case.yaml`:

```yaml
schema_version: "1.1"
name: hist-min
context:
  history_file: history.jsonl
```

`hist-raw` used the session file that `claude -p --session-id <uuid>` left under
`~/.claude/projects/`. `hist-min` used two hand-written rows:

```json
{"type":"user","uuid":"2222...","parentUuid":null,"sessionId":"1111...","timestamp":"2026-11-21T00:00:00.000Z","isSidechain":false,"message":{"role":"user","content":"Remember this for later: ..."}}
{"type":"assistant","uuid":"3333...","parentUuid":"2222...","sessionId":"1111...","timestamp":"2026-11-21T00:00:05.000Z","isSidechain":false,"message":{"role":"assistant","content":[{"type":"text","text":"noted."}]}}
```

Both cases passed both `regex` graders in one run each, for $0.16 in all.

What it shows:

- A history can be written by hand as one row for each message, linked by `uuid` and
  `parentUuid`.
- A recorded session file is not fit to commit. The one-turn recording is 316 KB in 51 rows.
  It holds the account and organization ids, the global instructions, the skill listing, and
  the host line, and 31 of its rows name the user or the host.
- A recording session runs with the workstation's hooks and memory. This one wrote a memory
  file for the scratch folder, which was removed.

## Trial 3: the second message

The history is the first exchange, hand-written: the sailing-club request, then a reply that
asks "What's going wrong with the paper sheet today that you want this to fix?" The case's
prompt is the answer: "Mostly that slots go unfilled, and the duty officer ends up phoning
people the night before a race." The graders are four of the five from trial 1.

It ran 4 times with the Sonnet judge, exited 1 after 52 seconds, and cost $0.53.

| Grader | Runs passed of 4 |
| --- | --- |
| `skill-fired` | 4 |
| `no-building` | 4 |
| `one-ask` | 3 |
| `question-marks` | 0 |

What it shows:

- The skill loads on the second turn of a hand-written history, in 4 runs of 4.
- Every second message asked the user to guess at a cause: "Why do you think the slots stay
  empty now?" Three then listed possible causes as further questions. That is the kind of
  question Geoff turned down most often in past sessions (`past-sessions.md`, kind 1).
- Three of the four opened with "So the real goal is..." or "So the real goal isn't...", a
  frame the workstation's writing standard bans.
- The two graders disagree here in the other direction. The judge passed three replies as one
  ask, and each holds two question marks.

## Trial 4: eleven cases on the current skill and on a draft rewrite

Eleven brainstorming cases were written from the corrections in `past-sessions.md`, each with
one grader for each fact. The same cases ran on the current skill and on a first draft of the
rewrite, six runs a case, with the Sonnet judge and no model named for the runs.

A run with no model named uses `claude-opus-5-5`, whatever the workstation's settings say. One
case run later with `--keep-temp` showed it: the trace of the run records that model, while
`~/.claude/settings.json` names `fable`. So trials 1 to 4 measured the skill on Opus 5.5.

| | Current skill | Draft |
| --- | --- | --- |
| Time | 907 seconds | 873 seconds |
| Cost | $8.05 | $7.12 |
| A run | about 14 seconds and $0.12 | about 13 seconds and $0.11 |

Passes of 6 for each grader whose rubric did not change afterward:

| Case | Grader | Current skill | Draft |
| --- | --- | --- | --- |
| `cannot-describe` | `shows-options` | 0 | 5 |
| `second-question` | `answerable` | 1 | 5 |
| `second-question` | `plain-restatement` | 0 | 5 |
| `rough-number` | `answerable` | 3 | 6 |
| `rough-number` | `treats-the-number-as-rough` | 6 | 6 |
| `already-answered` | `carries-forward` | 6 | 6 |
| `how-is-the-models-call` | `asks-what-is-theirs` | 6 | 6 |
| `best-practice` | `answers-with-the-practice` | 6 | 4 |
| `right-size` | `stays-small` | 6 | 6 |
| `approach-picked` | `no-building` | 4 | 6 |

What it shows:

- The current skill never showed options to someone who said they couldn't describe what they
  wanted. All six replies asked the baker to describe the bakery in other words: "if a regular
  walked in and described your bakery to a friend, what would they say it's like?"
- On a second message the current skill asked for a guess at other people's reasons in five
  runs of six ("Why do you think they stay empty?"), and all six opened with "So the real goal"
  or "So the real problem".
- Three of the current skill's six `rough-number` replies asked "What made you want this now?"
  and offered guesses at the answer. One added "Did something happen", the question that asks
  him to recall one incident.
- Two of the current skill's six replies showed a full draft design the moment an approach was
  picked.
- The current skill already holds three of the behaviors: it uses an answer already given, it
  makes the method call itself, and it keeps a small tool small.
- Four graders were wrong and were rewritten before trial 5. `skill-not-fired` passed 0 of 12
  because `tool_used` defaults `min` to 1, so "never called" needs `min: 0` and `max: 0`.
  `one-ask` counted the offer to skip the questions as a second ask. `stays-in-scope` failed a
  "why rebuild" question, and `checks-before-writing` failed a reply that asked one more
  question. `no-offered-answers` failed remarks that were not answers to the question.
- The draft had two real gaps, and its wording changed before trial 5. After "what's best
  practice here?" it answered and then asked "Does that sound right?" beside a new question.
  After a numbered list of choices it asked a second, separate question.

## Trial 5: thirteen cases on Fable 5.2, against the current skill and no plugin

The cases grew to thirteen, and every run from here names its models: `claude-fable-5-2` for
the run and `claude-sonnet-5-5` for the judge. The scores for each case are in the spec,
`specs/2026-11-21-brainstorming-spec.md`, under "What the cases found".

| Run | What ran | Result | Time | Cost |
| --- | --- | --- | --- | --- |
| First | The rewrite, six runs a case, with a $15 cost cap | Stopped at the cap after 10 of 17 cases | 1,099 seconds | $15.24 |
| Second | The rewrite, the full suite from a fresh clone | Exit 0, 17 of 17 cases at 0.8 or more | 1,998 seconds | $27.30 |
| Third | The same, after two rubric fixes | Exit 0, 17 of 17 cases at 0.8 or more | 1,966 seconds | $27.36 |
| Fourth | The current skill and no plugin, the 13 cases, three runs each | 4 of 13 cases at 0.8 or more in each | 1,615 seconds | $18.01 |

A run on Fable costs about $0.27, against $0.11 on Opus 5.5 in trial 4. The suite's cost cap
went from $15 to $35.

The first run found one wrong grader and one gap in the draft.

- `no-building` passed 0 of 6 in `approach-picked`. After a pick the skill plays the design
  back, and the grader failed each reply for describing what a page shows. It now fails only
  on code, a schema, file names, or build steps.
- `shows-options` passed 2 of 6 in `cannot-describe`. Four replies asked what the site is for
  and promised to show looks later. The draft now says to show two or three options in that
  same message, before the why question.

The second run found two wrong rubrics outside brainstorming. `wraps-with-context` in
`go-conventions` passed 2 of 6 and `backoff-is-done` in `backlog-sweep` passed 4 of 6. Each
demanded one exact detail and failed replies that were right, and each was corrected before
the third run.

Passes for each brainstorming grader. The rewrite's column adds the second and third runs. The
fourth run named no `--threshold`, so the command exited 1 on its default of 1.0.

| Grader | Rewrite | Current skill | No plugin |
| --- | --- | --- | --- |
| `answerable` | 67 of 72 | 5 of 18 | 17 of 18 |
| `one-ask` | 132 of 132 | 21 of 33 | 6 of 33 |
| `no-offered-answers` | 12 of 12 | 0 of 3 | 0 of 3 |
| `says-where-each-comes-from` | 12 of 12 | 0 of 3 | 0 of 3 |
| `shows-options` | 12 of 12 | 0 of 3 | 3 of 3 |
| `plain-restatement` | 12 of 12 | 2 of 3 | 0 of 3 |
| `answers-with-the-practice` | 12 of 12 | 2 of 3 | 3 of 3 |
| `asks-what-is-theirs` | 12 of 12 | 3 of 3 | 1 of 3 |
| `stays-in-scope` | 12 of 12 | 3 of 3 | 0 of 3 |
| `stays-small` | 12 of 12 | 3 of 3 | 0 of 3 |
| `no-building` | 36 of 36 | 9 of 9 | 7 of 9 |
| `skill-fired` | 72 of 72 | 18 of 18 | Left out |
| `skill-not-fired` | 12 of 12 | 3 of 3 | Left out |

Nine other graders passed every run in all three columns: `asks-nothing-the-files-answer`,
`carries-forward`, `checks-before-writing`, `does-the-rename`, `names-what-it-read`,
`no-question`, `numbers-the-approaches`, `recommends-one`, and `treats-the-number-as-rough`.

What it shows:

- The current skill makes its questions harder to answer than no skill does. Two of its three
  first replies asked the user to "walk me through a season with the paper sheet".
- With no plugin a reply asks several things at once. Two of its three first replies were five
  numbered questions. It also grew a small tool and asked about the build when the user was
  gathering requirements.
- The rewrite's five misses are all `answerable`, each on a question about why now, such as
  "What's prompting you to add an events calendar now?" The judge's votes split on it.
- Neither the current skill nor a bare session says where an approach comes from. That
  behavior is new with the rewrite.
- The raw result files hold local paths and stay out of the repo.

## Trial 6: the final text, run by a background session

One sentence of the skill's text changed after trial 5, to remove a contradiction a reader of
the spec found. This trial ran the thirteen brainstorming cases once more on the final text. It
also tested how a task session will run the suite. A session started with `claude --bg`,
`--permission-mode auto`, and the task's `--settings` ran `bash scripts/run-evals.sh --case
'brainstorming-*'` in the scratch clone.

| Measure | Result |
| --- | --- |
| Exit code | 0 |
| Cases that pass | 13 of 13 |
| Grader checks passed | 263 of 264 |
| Run records with an error | 0 of 78 |
| Time | 21 minutes |
| Cost as the command prices it | $20.30 |

What it shows:

- The one miss is `answerable` in `rough-number`, which scored 0.94. Every other case scored
  1.00.
- No call the session made was refused. It started the script with the Bash tool's
  `run_in_background`, waited for the exit notice, and read exit 0.
- Weekly usage rose from 31 to 34 percent for all models and from 41 to 45 percent for Fable
  across the run. Geoff's session and one reviewing subagent worked beside it.
