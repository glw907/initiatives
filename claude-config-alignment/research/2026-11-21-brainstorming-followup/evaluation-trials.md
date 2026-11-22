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
