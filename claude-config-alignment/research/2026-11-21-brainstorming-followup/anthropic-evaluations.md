# What Anthropic publishes on evaluating skills and agents

Research run on 2026-11-21 by one Sonnet researcher. A second Sonnet agent refetched every
source and gave each finding a verdict. A finding marked anything but `confirmed` is not
evidence until someone reads the page again.

## 1. plugin eval scores a run as the fraction of graders passed, a case as the mean over its runs, and passes a case only at or above --threshold, default 1.0, with 3 runs per case by default.

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21; cites Claude Code v2.1.299))
- Checker's verdict: `confirmed`. Quote is on the page; default of three runs per case also stated (--runs: case runs, else 3).

> A run's score is the fraction of its graders that passed, weighted if you set weights, and the case's score is the mean across its runs. A case passes when its score meets the [`--threshold`](#command-options), `1.0` by default.

What it would change: At the default threshold of 1.0 a single miss in three runs fails the case, which is exactly how a behaviour that goes wrong about one run in three shows up as flaky. Set an explicit --threshold for the suite (for example 0.66 so one miss in three passes) and give each case two or more graders so scores are not only 0, 0.33, 0.67 or 1.0. Say in the follow-up spec that the threshold is the tolerance for run-to-run variation and decide it per behaviour.

## 2. Anthropic gives the pass^k arithmetic: a behaviour that succeeds 75% of the time passes three trials in a row only about 42% of the time, and says to choose pass^k where consistency is essential and pass@k where one success is enough.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. Page also says: pass@k for tools where one success matters, pass^k for agents where consistency is essential. Dated Jan 9, 2026. The 90% -> 73% figure in so_what is the author's own correct arithmetic.

> If your agent has a 75% per-trial success rate and you run 3 trials, the probability of passing all three is (0.75)³ ≈ 42%.

The page's text, per the checker:

> If your agent has a 75% per-trial success rate and you run 3 trials, the probability of passing all three is (0.75)³ ≈ 42%.

What it would change: The default (3 runs, threshold 1.0) is a pass^3 test. A skill rule the model follows 90% of the time passes it only about 73% of the time, so a rule that fires wrong about one run in three is simply a rule at roughly 67% reliability, not bad luck. Decide per case whether the rule must be reliable (keep 1.0, fix the skill text) or only usually followed (lower the threshold). Anthropic gives no recommended run count beyond 3; the plugin allows 1 to 50 runs, so raise --runs to 5 or more on an unstable case to see its real rate before tuning.

## 3. Anthropic's guidance for stable LLM graders in plugin eval: use llm graders only on short output, write rubrics as concrete PASS and FAIL conditions, use deterministic regex graders for long output, and pair one grader on the result with one on the steps.

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21))
- Checker's verdict: `confirmed`. All four parts are on the page.

> Keep `llm` graders for short outputs, with rubrics written as concrete PASS and FAIL conditions.

The page's text, per the checker:

> For long output such as a generated file, grade it with a `regex` grader ... Keep `llm` graders for short outputs, with rubrics written as concrete PASS and FAIL conditions.

What it would change: Rewrite each brainstorming rubric as an explicit PASS if / FAIL if pair for one observable fact in the final message, and grade only the reply to the first turn, which is short. Keep every rubric to one claim, so a verdict cannot hinge on how the judge reads a long transcript.

## 4. plugin eval has a free deterministic regex grader that can require exactly N matches or none at all, which can test 'one question' without a judge.

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21))
- Checker's verdict: `confirmed`. Table row: Set `match: not_contains` to require absence or `match: "count:N"` to require exactly N matches. The sentence-counting remark is the author's inference, labelled as such. Regex graders are deterministic/judge-free per page.

> Set `match: not_contains` to require absence or `match: "count:N"` to require exactly N matches.

What it would change: The compound-question case can add a regex grader on last_message with match "count:1" over question marks. It is deterministic and costs nothing, so it removes judge noise from the one-question check. Its limit: a compound question can use one question mark ('which X, and what about Y?'), so keep one narrow llm grader for 'asks a single question' and let the regex catch the multi-mark cases. Docs do not mention counting sentences; that is an inference.

## 5. The plugin-eval docs warn that a small judge model can fail a correct answer because of formatting, and tell authors to re-run with a stronger judge and tighten the rubric; each llm grader needs 2 of 3 judge votes, and the judge defaults to a small background-task model (haiku per local --help).

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21); default judge from `claude plugin eval --help` on Claude Code 2.1.330)
- Checker's verdict: `confirmed`. Quote on page (in a tip about a passing tool_used: Skill grader with negative Δ). 'at least two of three votes' confirmed. Page says default judge is 'the model Claude Code uses for background tasks'; 'haiku' comes from local --help, not the page (an example command uses claude-haiku-4-5).

> A small judge model can mark a correct answer wrong because it's formatted differently from what the rubric describes. Re-run with `--judge-model sonnet`, and tighten the rubric so formatting doesn't decide the verdict.

What it would change: Before editing the skill to fix a flaky score, re-run the unstable case with --judge-model set to a Sonnet 5.5 id and read the judge's votes in the report. If the score steadies, the flake was the judge, not the skill. Pin --judge-model in the suite's run command so scores stay comparable over time.

## 6. Anthropic recommends one isolated LLM judge per dimension, not one judge for everything, plus an 'Unknown' escape and calibration against human reading.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. Page also says to give the judge a way out ('Unknown') and that LLM judges should be closely calibrated with human experts. The plugin-eval one-grader-per-file and weighted-partial-credit remarks are about the plugin docs (weights are documented there).

> It can also help to create clear, structured rubrics to grade each dimension of a task, and then grade each dimension with an isolated LLM-as-judge rather than using one to grade all dimensions.

The page's text, per the checker:

> grade each dimension with an isolated LLM-as-judge rather than using one to grade all dimensions

What it would change: Split a multi-part rubric (for example 'asks one question, offers choices, does not start building') into separate grader files, one dimension each, with weights. plugin eval takes one grader per file and scores the weighted fraction, so a partial failure gives partial credit and the report shows which dimension failed instead of one opaque fail.

## 7. A case that scores the same with and without the plugin shows that the plugin did not cause the result.

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21))
- Checker's verdict: `confirmed`. Page says 1.0 both ways; the claim's 'same score' is a slight generalisation but so_what keeps to Δ near 0. tool_used: Skill graders are excluded from score in two-arm runs: confirmed. 'Fix or remove it' advice is not literally on this page; minor.

> If a case scores 1.0 both with and without the plugin, the plugin isn't what made it pass.

The page's text, per the checker:

> If a case scores 1.0 both with and without the plugin, the plugin isn't what made it pass.

What it would change: A case with Δ near 0 tests nothing about the skill; Anthropic's advice is to fix or remove it, not keep it as a pass. Note that tool_used: Skill graders are excluded from the score in the two-arm run, so Δ must come from the content graders. Use Δ as the case's keep-or-drop test in the follow-up.

## 8. The Agent Skills evaluation guide says to remove assertions that pass in both arms and to fix assertions that fail in both arms, because the assertion may be broken or may check the wrong thing; Anthropic's skill-creator grader agent also names 'trivially satisfied' and unchecked outcomes as eval flaws.

- Source: <https://agentskills.io/skill-creation/evaluating-skills> (anthropic, undated (guide linked from the Claude Code skills docs; companion grader.md in github.com/anthropics/skills last changed 2026-03-06))
- Checker's verdict: `confirmed`. Page also has 'Remove or replace assertions that always pass in both configurations.' The grader.md / 'trivially satisfied' part is on a different source (GitHub), not checked here. Also: the page says the assertion may be broken, the case too hard, or checking the wrong thing, which is slightly wider than the claim.

> Investigate assertions that always fail in both configurations. Either the assertion is broken (asking for something the model can’t do), the test case is too hard, or the assertion is checking for the wrong thing.

The page's text, per the checker:

> Investigate assertions that always fail in both configurations. Either the assertion is broken (asking for something the model can't do), the test case is too hard, or the assertion is checking for the wrong thing.

What it would change: For the case whose grader demands a detail the skill never teaches, there are two valid fixes: teach that detail in the skill, or delete the grader; keeping it fails both arms and adds nothing. The same guide says 'Remove or replace assertions that always pass in both configurations', so both equal-score patterns have a rule. The page is hosted on the open Agent Skills site, which the Claude Code docs link as the format reference; it is not on an anthropic.com domain.

## 9. Anthropic says a 0% pass rate across many trials usually signals a broken task or grader, and that everything a grader checks must be clear from the task text.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. Quote 'Everything the grader checks should be clear from the task description; agents shouldn't fail due to ambiguous specs.' is on the page, as is the reference-solution advice. Page says 'most often', claim says 'usually': fine.

> Everything the grader checks should be clear from the task description; agents shouldn’t fail due to ambiguous specs.

The page's text, per the checker:

> a 0% pass rate across many trials (i.e. 0% pass@100) is most often a signal of a broken task, not an incapable agent.

What it would change: Apply a pre-flight test to every case: could a correct agent satisfy each grader from the prompt text alone? If a grader needs a detail only the skill could supply, the prompt does not ask for it, so a failure in the without arm is expected and the grader is the defect. The post also recommends a reference solution that passes all graders to prove the case is solvable.

## 10. Inconsistent pass and fail across runs is attributed either to a flaky eval or to ambiguous skill instructions, and the remedy is to add examples or more specific guidance to the skill.

- Source: <https://agentskills.io/skill-creation/evaluating-skills> (anthropic, undated (Agent Skills site; skill-creator's analyzer.md also flags 'high-variance evals (possibly flaky)'))
- Checker's verdict: `confirmed`. Quote on page; remedy 'Add examples or more specific guidance to reduce ambiguity' and 'Generalize from feedback' (avoid narrow patches) are both there. The analyzer.md remark is another source, not checked.

> If the same eval passes sometimes and fails others (reflected as high stddev in the benchmark), the eval may be flaky (sensitive to model randomness), or the skill’s instructions may be ambiguous enough that the model interprets them differently each time.

What it would change: For the compound-question flake, the first move is to tighten the skill text where it says 'one question at a time' (add a short good and bad example, say what counts as one question), then re-run; only change the grader if the judge-model check shows the judge is the noisy part. Also generalize the fix, since the guide warns against narrow patches for one test prompt.

## 11. Anthropic's skill-creator announcement says evals show when the base model has absorbed a skill's technique, so the skill is no longer necessary.

- Source: <https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills> (anthropic, 2026-03-03)
- Checker's verdict: `claim-overreaches`. Quote is there (dated Mar 3, 2026), but it says only 'a signal ... may have been', not that evals show absorption or that the skill is unnecessary. The preference-skill sentence says value depends on fidelity to workflow, which supports the so_what only loosely.

> If the base model starts passing your evals without the skill loaded, that's a signal the skill's techniques may have been incorporated into the model's default behavior.

The page's text, per the checker:

> If the base model starts passing your evals without the skill loaded, that's a signal the skill's techniques may have been incorporated into the model's default behavior. (also: 'Encoded preference skills are more durable, but only as valuable as their fidelity to your actual workflow.')

What it would change: With Claude 5 models, a case that passes equally without the skill may mean the model already asks one question at a time by default, not that the case is badly written. Keep cases for the parts of brainstorming that are the user's own preferences (read the project first, two or three approaches with a recommendation, a written design for approval), since the post says preference-encoding skills stay valuable only while faithful to the workflow. Rerun the baseline on each new model release and treat a case's Δ falling to zero as information.

## 12. Anthropic says conversational agents are evaluated on end-state outcomes plus rubrics for interaction quality, and often need a second model playing the user; multi-dimensional success mixes a state check, a transcript constraint and an LLM rubric.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. Quote 'Unlike most other evals, they often require a second LLM to simulate the user.' is verbatim. The state check / transcript constraint / rubric mix was not separately verified in this fetch; the plugin-eval 'no simulated user' remark is the author's inference (the docs describe type: agent mocks as MCP server answers, consistent with it).

> Unlike most other evals, they often require a second LLM to simulate the user.

What it would change: The brainstorming skill is conversational, so Anthropic's model is a simulated user. plugin eval has no simulated-user option; its mock type: agent answers as an MCP server, not as a person. So grade the first reply in isolation for the per-turn behaviours (one question, no building), and use history_file for turn two and later. Do not expect a full design conversation to be graded end to end under this command.

## 13. plugin eval can continue an earlier conversation: a recorded .jsonl transcript is loaded and the case prompt becomes the next user turn; such cases run with one arm by default when the target is a path.

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21))
- Checker's verdict: `confirmed`. Quote verbatim; page also says such a case runs without a baseline arm by default for a path target and that --ablation with-without adds the comparison.

> An earlier conversation to continue**: save the transcript as a `.jsonl` file and name it in `context.history_file`, and the case's prompt becomes the next user turn.

What it would change: This is the supported way to test a later turn: save a transcript up to the point where the skill has asked its first question, set the prompt to a realistic user answer, and grade the reply (for example that it asks the next single question, or moves to approaches). Pass --ablation with-without or the case gets no Δ, so decide whether a with-and-without comparison is wanted for these cases. The docs do not say how to record a transcript or give a multi-user-turn recipe.

## 14. How plugin eval reports and bounds runs: no flaky flag or variance column is documented; the report shows per-case mean score, the judge's votes, and a 'Perfect runs' share, and the run options are runs per arm 1 to 50, max_turns default 10 (cap 200), timeout_seconds default 300 (cap 3600), plus -j concurrency, --threshold, --max-cost-usd.

- Source: <https://code.claude.com/docs/en/plugin-evals> (anthropic, undated live docs page (fetched 2026-11-21); options also confirmed from `claude plugin eval --help`, Claude Code 2.1.330)
- Checker's verdict: `confirmed`. Runs 1 to 50, defaults and caps, --max-cost-usd, 'Perfect runs' tile, and 'A single run is noisy...' all on the page. -j and per-case judge votes display were not individually checked; the absence of a stddev column is a negative claim I did not exhaustively verify.

> Turn cap, up to 200. Hitting it is recorded as a run error and usually lowers the score, so set it generously

The page's text, per the checker:

> Turn cap, up to 200. Hitting it is recorded as a run error and usually lowers the score, so set it generously

What it would change: A flaky case is spotted by a case score strictly between 0 and 1 and by reading each run's grader chips in the report or cases[].arms.with[] in --json; there is no built-in stddev. Set max_turns above 10 for any case where the skill reads the project first, since hitting the cap silently lowers the score and can look like a flake. For debugging use --case <name> --runs 1 --ablation none, but the docs say 'A single run is noisy, so confirm any change at the default three runs before you trust it.' Pin --model and --judge-model.

## 15. Anthropic's advice on suite size and shape: start small from real failures, and include cases where the behaviour should not occur, not only where it should.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. '20-50 simple tasks drawn from real failures is a great start' is on the page; 'Start with 2-3 test cases' is on the agentskills page. The 'genuinely tricky' negatives phrase attributed to skill-creator was NOT found on the claude.com blog; it must come from another source (unchecked).

> Test both the cases where a behavior should occur and where it shouldn't. One-sided evals create one-sided optimization.

The page's text, per the checker:

> Test both the cases where a behavior should occur and where it shouldn't. One-sided evals create one-sided optimization.

What it would change: Anthropic's own numbers differ by audience: the engineering post says '20-50 simple tasks drawn from real failures is a great start', and the skill-evaluation guide says 'Start with 2-3 test cases'; a plugin suite at the small end fits the second. A behaviour earns a case when it is the skill's value, has a real observed failure, and can be graded from one reply. Add at least one should-not-trigger case with a near-miss prompt (a small, fully specified change that should not start a design conversation), since skill-creator says negatives should be 'genuinely tricky'. Both plugin-eval init and skill-creator generate both positive and negative prompts.

## 16. Anthropic warns that grading the exact sequence of tool calls makes tests brittle and recommends grading what the agent produced instead of the path it took.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. Quote is on the page; the 'brittle' framing is the page's discussion of punishing creativity. The suggestion to keep one tool_used grader loose is the author's recommendation, consistent with the plugin-eval pairing advice.

> So as not to unnecessarily punish creativity, it’s often better to grade what the agent produced, not the path it took.

The page's text, per the checker:

> it's often better to grade what the agent produced, not the path it took.

What it would change: Use tool_order and tool_used graders sparingly. Reading the project first is a real process requirement of the brainstorming skill, so one tool_used grader on Read or Glob is justified, but do not grade the order of reads or the exact tool. The docs pair one result grader with one steps grader per case; keep the steps grader loose.

## Left out by the researcher

- Anthropic Bloom post (anthropic.com/research/bloom, 2025-12-19): multi-turn simulated-user behavioural evals and a judge-model calibration (Opus 4.1 Spearman 0.86 vs Sonnet 4.5 0.75, repeats three times). It is an alignment tool for generating large suites, not a plugin-eval fit, and the models are older.
- Anthropic engineering post 'Quantifying infrastructure noise in agentic coding evals' (2026-02-05): infrastructure settings moved scores by up to 6 points and pass rates vary with time of day; leaderboard gaps under 3 points deserve skepticism. Measured, but about coding benchmarks at scale, not a 3-run plugin suite; the one transferable point (pin the model and judge) is already in the options finding.
- Anthropic 'A statistical approach to model evaluations' (2024): error bars and resampling several answers per question. Predates the current models and concerns large Q&A benchmarks.
- Platform docs 'Define success criteria and build evaluations' (platform.claude.com/docs/en/test-and-evaluate/develop-tests): SMART criteria, 'Have detailed, clear rubrics', 'Be empirical or specific' (output only correct or incorrect), 'Encourage reasoning' with a thinking-enabled grader, and 'Prioritize volume over quality'. Undated and written for single-prompt API apps; consistent with the kept findings but adds nothing specific to a plugin suite. The 'volume over quality' advice conflicts with the plugin guidance to start with 2-3 cases and was dropped for that reason.
- Skill-creator SKILL.md in github.com/anthropics/skills (file last committed 2026-03-06): description-trigger evals run each query 3 times, with a 60/40 train and held-out split to avoid overfitting, and 8 to 10 should-trigger and should-not-trigger queries; it also tells the analyst pass to flag assertions that always pass and high-variance evals. Folded into the kept findings; the trigger-eval loop is for description tuning, not for this follow-up.
- Third-party and academic sources on simulated users (Talk, Evaluate, Diagnose, 2026; AWS Strands Evals ActorSimulator; a dev.to pass^k post): outside this topic, which is Anthropic publications; the search found no consensus trial count.
- Claude Code docs skills page: its 'Evaluate and iterate on a skill' section only points to plugin eval and skill-creator and repeats that `tool_used: Skill` can measure trigger rate; no new guidance.

## Questions with no source found

- Any Anthropic recommendation for a specific number of runs per case beyond the plugin-eval default of 3 (allowed range 1 to 50); the 2026 engineering post gives pass@k and pass^k arithmetic but no run count.
- Any Anthropic guidance on setting a pass threshold for a behaviour that varies run to run; the docs show --threshold 0.8 in a CI example and explain the scoring arithmetic but do not say how to choose a value.
- Any documented 'flaky case' flag, variance statistic or retry option in `claude plugin eval`; flakiness is visible only as a case score between 0 and 1 and per-run grader results in the report and --json.
- A simulated-user or multiple-scripted-user-turn option in `claude plugin eval`; only context.history_file (resume a transcript, the prompt is the next user turn) and max_turns (agent turns) exist, and the docs give no recipe for recording a transcript.
- An Anthropic 2026 successor to 'Demystifying evals for AI agents' specifically about evaluating skills or plugins; the nearest are the 2026-03-03 skill-creator announcement and the Agent Skills evaluation guide.
- Anthropic guidance written specifically for the Claude 5 family on grader or eval design; every relevant source is either undated or written for Claude 4-era models, so check each against a real run.
- Publication date of the plugin-evals docs page and the agentskills.io evaluation guide; both are live pages with no date, so only the version references (Claude Code v2.1.269 and later, v2.1.299) and the local 2.1.330 help bound them.
