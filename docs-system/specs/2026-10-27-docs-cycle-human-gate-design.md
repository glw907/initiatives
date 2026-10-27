# Docs cycle human gate

Status: drafted 2026-10-27 for Geoff's approval; the direction was approved in chat that day.
Initiative: `docs-system`. Repo: cairn-cms. Runs after the docs eval trust pass
(`specs/2026-10-26-docs-eval-trust-design.md`), which edits the same runner, cases, and rule.
Inputs: run `20261027-153843-9c98`, Anthropic's
[Demystifying evals for AI agents](https://anthropic.com/engineering/demystifying-evals-for-ai-agents)
and [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices),
and Husain and Shankar's [evals FAQ](https://hamel.dev/blog/posts/evals-faq/).

## Brief

The docs cycle will stop merging skill fixes: you approve each one, its eval table informs your
call, and the judge that grades the evals is checked against your labels.

On 2026-10-27, two arms with identical rule sets scored 9 of 11 and 6 of 12 on the capability suite.
At three trials a case, the change rule's "the target case improves" can pass or fail by chance. The
published guidance agrees on the fix. Anthropic's eval post says LLM judges "should be closely
calibrated with human experts" and that it does not take scores "at face value until someone digs
into the details". The evals FAQ says to favor deterministic checks in automated gates and to "use
LLMs to scale what you've learned, not to avoid looking at data".

### What changes

- The change rule reports instead of gating. A docs-process PR still carries both suites' table and a line per failing transcript, and you decide. A regression drop is flagged in the PR, not used to block it.
- The cycle's fix PRs reach you in one packet. glw907/cairn-cms#153 already makes this change, so this pass only aligns the rule and the README with it.
- The judge gets calibrated once. You label about 40 judged verdicts from past runs, pass or fail, without seeing the judge's call. The runner then reports how often the judge agrees with you for each assertion.
- An assertion that disagrees with you too often is reworded, or replaced by a deterministic check.
- The suite grows from real failures. Each cycle's "now" row already adds a capability case. A capability case graduates to regression after it holds pass^3 on `main` in two runs in a row, toward the 20 to 50 cases the guidance names.

### If you approve

1. After the eval trust pass merges, a planning session writes the plan from this design.
2. Before the executor starts, you label the calibration set in one sitting of about 30 minutes.
3. The pass ends with one packet holding a cairn-cms PR.

### Decide: Where you label the calibration set

Labeling happens once now, and again whenever an assertion is reworded. Each item shows the assertion, the transcript excerpt the judge saw, and the diff, and asks pass or fail.

- A private page published for you, which shows each excerpt and diff formatted and saves each label as you go (recommended)
- A Markdown file in the repo that you edit by hand

### Standing answers

- An assertion disagrees with you on more than 1 of its 5 labeled verdicts. It is reworded and relabeled once, and if it still misses, it becomes a deterministic check or is cut.
- Fewer than 40 judged verdicts are balanced between pass and fail. The set takes what exists, at least 30 in all, and says so in the PR.
- An estimate overrun. Go on up to twice the path. Past that, the clock stop.

## Scope

- `.claude/rules/evals-docs-process.md`: the merge condition becomes what the PR reports.
- `.claude/skills/cairn-docs/evals/`: a `labels.json` of your verdicts, a `--calibrate` report in `run.mjs` that prints agreement per assertion, the graduation rule in `README.md`, and reworded assertions in `evals.json`.
- The labeling page, if you choose it.

## Out of scope

- More trials per case. Detecting small effects needs far more sessions than a monthly cycle should spend. The table stays information.
- Automated rewriting of the skill. The FAQ notes automated optimization "cannot discover new" failures. The cycle keeps proposing and you keep deciding.
- A different judge model, and any change to `SKILL.md` or `docs-fact-checker`.

## End-to-end check

`run.mjs --calibrate` prints agreement for every judged assertion against `labels.json`, and every
remaining assertion clears the standing answer's bar. A seeded dry cycle opens a fix PR, sends a
packet, and merges nothing before the decision.

## Class and estimate

Risk class `runner`. No `live-account` step. One pre-flight item, your labeling sitting. Path
estimate 180 minutes: about 90 of work, 50 of eval runs to recheck reworded assertions, and 40 for
close.
