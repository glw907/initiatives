# Research for the brainstorming and evaluation follow-up

The published guidance points one way on wording and on testing, and it is split on how many
questions to ask at once. Anthropic says current models follow a plain sentence with its reason
and over-apply loud rules. The plugin's evaluation gate fails mostly because of how the suite
is built. No source measures an interview skill on a Claude 5 model, so the follow-up
has to measure its own wording.

Geoff asked for this on 2026-11-21, after pull request 22 in `glw907/standards` merged with its
evaluation suite red: "look at current online and anthropic success patterns. Brainstorming is
especially critical, so we'll need to know what works best with the current models, and aligns
will with our local development patterns."

## How it was run

Four Sonnet researchers each took one topic and returned findings with a URL and a quoted
passage. A second Sonnet agent refetched every source and gave each finding a verdict. One Opus
reader at high effort compared the local skill with local practice and changed nothing.

| File | Findings | Confirmed | Claim goes past its source | Quote not found |
| --- | --- | --- | --- | --- |
| `anthropic-skill-authoring.md` | 15 | 10 | 5 | 0 |
| `anthropic-evaluations.md` | 16 | 15 | 1 | 0 |
| `superpowers-upstream.md` | 14 | 7 | 6 | 1 |
| `community-elicitation-patterns.md` | 14 | 9 | 5 | 0 |
| `local-read.md` | one report | not checked | | |

A finding with any verdict but `confirmed` is not evidence until someone reads the page again.
In most of those the quote is real and the researcher's conclusion reaches past it. The local
read was not checked against the files, so a spec that uses one of its line numbers reads the
line first.

## What holds up

Each point below rests on a confirmed finding. The number is the finding's place in its file.

### Wording

- Anthropic's best-practices page lists adding IMPORTANT or capitals as advice to stop
  following. Current models follow a plainly worded line, and emphasis makes them over-apply
  the rule. A rule that can't bend belongs in a hook (skill authoring 1).
- Anthropic's `skill-creator` tells an author to give the reason behind an instruction and
  calls ALWAYS or NEVER in capitals a yellow flag (skill authoring 2).
- Sonnet 5 follows a prompt literally and does not carry an instruction from one item to
  another. A rule such as "one question at a time" has to say what counts as one question
  (skill authoring 4).
- The Fable 5 guide says skills written for earlier models are often too prescriptive and can
  lower quality, and it advises removing instructions where the default is better (community 9).
- A description is written in the third person, says what the skill does and when to use it,
  and leans a little pushy, because Claude under-triggers skills. The listing caps description
  and `when_to_use` together at 1,536 characters (skill authoring 10 to 12).

### The interview

- Anthropic's published pattern is an interview until Claude could write the spec, then a
  written spec, then a fresh session that builds from it (skill authoring 5, community 10).
- Auto mode nudges Claude past clarifying questions unless the prompt or a skill relies on
  asking. A skill that needs an interview has to say so (skill authoring 7).
- Upstream's rule since 7.0.2 is to ask only when the answer would change what gets built and
  nothing already answers it, and otherwise to state a call the user can correct. It replaced
  a rule that every message ends with a question, which users called a ritual (upstream 1, 14).
- Upstream first tried removing the required question, and the reason for the work stopped
  coming out. It then told the model to ask why first, openly, with no example answers
  (upstream 3).
- Upstream asks in plain text and does not use the question tool, because the maintainer found
  people read and engage less with it (upstream 4).
- An explicit test for "you understand what they want when..." made upstream's conversations
  worse and raised the question count, and upstream reverted it (upstream 13).
- Anthropic notes that spreading an underspecified task over many user turns costs tokens and
  sometimes quality (skill authoring 9).

### Evaluations

- `claude plugin eval` scores a case as the mean of its runs and passes it only at the
  threshold, which defaults to 1.0 over three runs. A behavior that holds nine times in ten
  passes that about 73 percent of the time (evaluations 1, 2).
- The judge defaults to a small model. The docs warn that it can fail a correct answer over
  formatting and tell authors to rerun with a stronger judge and tighten the rubric
  (evaluations 5).
- A rubric is one concrete pass condition and one fail condition for one observable fact, with
  one grader file for each thing judged. A regex grader can count matches with no judge
  (evaluations 3, 4, 6).
- A case that scores the same with and without the plugin shows nothing about the plugin. An
  assertion that fails in both arms is broken or checks the wrong thing (evaluations 7 to 9).
- Uneven results across runs come from the evaluation or from ambiguous skill text, and the
  first fix is an example or a more specific line in the skill (evaluations 10).
- A later turn is tested by loading a recorded transcript and making the prompt the next user
  turn. The command has no simulated user (evaluations 12, 13).
- A suite starts small, from real failures, and includes cases where the behavior should not
  happen (evaluations 15).
- Upstream tests wording against a control with no guidance, five or more runs for each
  variant, and treats the spread across runs as a result. A third party's first ablation showed
  no effect only because part of the sentence was still in the file (upstream 8, 10).

## Where the sources disagree

- On how many questions to ask at once, upstream, GitHub's spec-kit, and Every's skill ask
  one in each turn. Matt Pocock's skill moved to numbered rounds that ask every decision whose
  prerequisites are settled. Anthropic's question tool takes one to four questions in a call.
  Anthropic's docs take no side that the researchers could find (community 1, 3, 4).
- On a cap, spec-kit stops at five questions. Pocock refuses a cap and tells the
  user to say "wrap up" (community 2, 3).
- On which failure is more likely, practitioners complain about too many questions. Two
  studies on Claude Sonnet 4.5 found the model asks too few on underspecified coding work, and
  that deciding when to ask beats always asking (community 6, 7).

## What no source answers

- No source measures a question-asking design on Fable 5.2, Opus 5.5, Sonnet 5.5, or Haiku 5.5.
- No source compares one question in a turn with a batch, or open questions with choices, for
  a coding agent.
- Anthropic publishes nothing for or against a hard-gate tag or a red-flags table in a skill,
  beyond its general advice on emphasis.
- Anthropic gives no number of runs or pass threshold for a behavior that varies between runs.
- Upstream has not changed its brainstorming skill since 7.0.2.

## What the local read found

The full report is `local-read.md`. Its main points:

- The skill calls its product a design doc and sends the build to a plan. The local process has
  a spec and tasks, and no plan step. Neither file says the brainstorm's design is the spec.
- A design that meets the skill's list lacks most of what `writing-a-spec.md` requires, such as
  labels on mechanisms, file lists from searches, and tasks with goals.
- Every path through the skill's first message invites two or more asks, and the skill never
  says what counts as one question. The failing run's three clauses match three bullets of the
  skill's list of ground to cover.
- The grader for that case is looser than the skill in one place and stricter in another.
- The `ts-conventions` skill steers away from the detail its grader demands.
- One case tests the skill, on its first message only. Nothing tests that the model waits for
  approval before it builds.
- The visual companion carries upstream's brand, loads a logo from an outside host on every
  screen, and opens the default browser.
