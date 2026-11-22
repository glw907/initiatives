# Other published interview patterns

Research run on 2026-11-21 by one Sonnet researcher. A second Sonnet agent refetched every
source and gave each finding a verdict. A finding marked anything but `confirmed` is not
evidence until someone reads the page again.

## 1. Matt Pocock's grilling skill (the engine under /grill-me and /grill-with-docs) moved from one question at a time to numbered rounds. Each round asks the whole frontier of decisions whose prerequisites are settled, with a recommended answer per question worded so 'yes' accepts it. One-at-a-time survives only as an opt-in CLAUDE.md line.

- Source: <https://aihero.dev/skills-grilling> (community, 2026-08-24)
- Checker's verdict: `confirmed`. Quote present. Page says one-at-a-time via CLAUDE.md is 'a supported setting, not a workaround', and admits a round can miss follow-ups (rounds group independent questions; frontier chosen by judgement, so dependencies can be misjudged). The 'worded so yes accepts' detail was not directly confirmed; the page says the recommendation sometimes argues against the question as worded.

> typically land in about three rounds rather than thirteen

The page's text, per the checker:

> Thirteen questions typically land in about three rounds rather than thirteen.

What it would change: The strongest recurring community pattern no longer treats strict one-at-a-time as the default. The page admits a cost: a round can miss follow-ups an earlier answer would have raised. The brainstorming skill's one-question rule is a design choice that can be argued either way, so the follow-up should decide it on purpose. For the eval, a compound-question grader would penalise a pattern that Pocock now ships as the default. Decide whether the grader checks 'one decision per question' or 'one question per turn'.

## 2. Pocock refuses a question cap on purpose and gives the reason. He tells users to say 'wrap up' in plain language instead. A sibling page says a session that runs long usually means the scope is too big and should be split.

- Source: <https://aihero.dev/skills-grilling> (community, 2026-08-24)
- Checker's verdict: `confirmed`. FAQ says tell the agent to wrap up; if a session runs very long the scope was probably too big, split and grill pieces separately. The 'sibling page' is wayfinder, and the scope advice is in this page's FAQ. Spec-kit contrast in so_what is the researcher's inference.

> either truncates the hard case or feels arbitrary on the easy one

The page's text, per the checker:

> a cap is out of scope on purpose ... a fixed ceiling either truncates the hard case or feels arbitrary on the easy one

What it would change: Disagrees with spec-kit's hard cap of 5 and with the measured 1-3 budgets (findings 3 and 5). A cap is simple to write and to grade, but Pocock argues it fails at both ends of the difficulty range. A middle option is a soft cap, where the skill asks only about decisions that would change the build and offers a split-the-scope exit.

## 3. GitHub spec-kit's clarify step is the strictest published pattern. It asks at most 5 questions per session, exactly one at a time. Each is multiple choice (2-5 mutually exclusive options) or a short answer of 5 words or fewer. The recommended option is shown first. The user can reply 'yes' or 'recommended'. It stops on 'done' or at 5 questions. Each answer is written back into the spec under a Clarifications section and saved after every integration.

- Source: <https://github.com/github/spec-kit/blob/main/templates/commands/clarify.md> (community, undated)
- Checker's verdict: `confirmed`. All points found. Short answer limit is five words or fewer; multiple choice 2 to 5 options; stops on 'done' or when no critical ambiguities remain; Clarifications section under a dated session heading. Page is undated.

> Maximum of 5 total questions across the whole session.

What it would change: This is a ready-made template for 'ask only high-impact things, offer a default, stop at a known point'. It writes the answer into the existing document rather than a new one. For evals, a clear numeric ceiling is easy to grade ('at most N questions', 'recommended answer present'), which a vaguer rule like 'ask only when the answer changes the build' is not.

## 4. Every's compound-engineering brainstorm asks one question per turn, preferring a blocking single-select tool with free text always available. It asks only decisions and looks facts up in the repo first. It runs a lookup in the background without stalling other questions, and it probes premises only when a rigor gap is present. It scales output by tier (lightweight ends in chat). It writes a requirements file only when a downstream consumer needs one.

- Source: <https://every.to/compound-engineering/guides/ce-brainstorm/> (community, undated)
- Checker's verdict: `confirmed`. Quote and every listed behaviour found. No explicit stop rule, as the claim says (only a keep-asking menu option and a confirmation gate).

> Stacking several questions in one message dilutes the answers.

What it would change: Gives a second written reason for one question per turn, and for 'ask only decisions' (the same gate Pocock states). The size tiers and 'write a file only when needed' address the over-process failure for small work. A case in the eval suite for a tiny task, where the right behaviour is a short exchange and no design document, would test that. The page has no explicit stop rule.

## 5. A measured study across 8 LLMs (GPT, Grok and Llama families, no Claude) found that capping an agent at 1-3 questions cuts user-attention cost 36-73% while keeping 86-94% of the reward. Questions past a 3-question budget earn about half the average reward per question. A 'ask sparingly' prompt saved only 16% of cost. The authors say unworthy questions, not long ones, make conversations tiring.

- Source: <https://arxiv.org/abs/2610.24411> (measured, 2026-10-17)
- Checker's verdict: `claim-overreaches`. Quote, 86-94%, eight LLMs and customer-service domains confirmed. Not found on the abstract page: the 'about half the reward past budget' figure, the 'ask sparingly saved 16%' figure (page shows 13% from reviewing questions against earlier answers, a different intervention), model families (not named), and the 'unworthy not long' wording (page says 'hard to read or not worth asking'). These may be in the full paper but are unverified; the 'no Claude' claim is unverified.

> limiting agents to one to three questions reduces user-attention cost by 36-73%

The page's text, per the checker:

> limiting agents to one to three questions reduces user-attention cost by 36-73%

What it would change: The best numeric evidence for a small question budget and for judging questions by value, not count. It was tested on customer-service-style tasks and not on Claude or on coding. The evals could add a 'question value' grader, since a count limit alone would miss the point. 'Ask sparingly' wording alone is a weak lever, so the skill needs a concrete gate.

## 6. An arXiv study on an underspecified SWE-bench Verified (Claude Sonnet 4.5 as agent) found a scaffold that decides whether to ask reached a 69.40% resolve rate against 61.20% for a single agent. An always-ask interactive baseline reached 70.40% but over-clarified. On the 156 tasks where the Claude scaffold chose not to ask it still resolved 76.92%.

- Source: <https://arxiv.org/html/2603.26233v2> (measured, 2026-06-03)
- Checker's verdict: `confirmed`. Numbers match (UA-Multi 69.40, UA-Single 61.20, Interactive Baseline 70.40, 156 tasks at 76.92). Page text was read to 100000 of 100321 characters. Caveat: with Kimi K2.6 the scaffold queried 83-100% of tasks, so the 'conserve on simple tasks' behaviour holds clearly for Sonnet 4.5 only. Claude 4.5 era, as the claim notes.

> conserving queries on simple tasks while proactively seeking information on more complex issues

What it would change: Evidence that asking helps with underspecified coding tasks and that a policy of when to ask beats asking always. Model is Claude 4.5 era, so treat the direction as useful and the numbers as dated. A fair eval needs both an ambiguous prompt, where asking is correct, and a clear prompt, where asking is a failure.

## 7. ClarifyCodeBench (6 models including Claude Sonnet 4.5, with and without thinking) found models under-ask. Claude Sonnet 4.5 averaged 0.29 clarification turns against about 1.65 required, and thinking did not increase depth. The protocol forced exactly one question per turn.

- Source: <https://arxiv.org/html/2607.00711v2> (measured, 2026-08-31)
- Checker's verdict: `confirmed`. Quote verbatim (Section 5.4). 0.29 is in Table 4; 1.65 is derived (0.29 + 1.36 diff, and from the dataset annotation average), not stated directly. Thinking variant asked 0.24 turns. Protocol requires exactly one critical question per turn by system prompt. Claude 4.5 era.

> They usually ask fewer clarification questions than necessary and often stop the interaction too early.

What it would change: The common worry is over-asking, but this benchmark shows the opposite failure, stopping too early. A stop condition should not be 'when the model feels done'. It should be tied to something checkable, such as unresolved decisions. The eval suite should include a case with several hidden ambiguities, since pass-or-fail on one question hides under-asking. Models are Claude 4.5 era, not Claude 5.

## 8. Anthropic's own chat system prompt for Sonnet 5 (9 Nov 2026) sets the default for ambiguity: choose a reasonable interpretation, state the assumption, and proceed. It asks one clarifying question only when proceeding would clearly waste effort, and still attempts what it can. The Opus 5 prompt says Claude avoids more than one question per response.

- Source: <https://platform.claude.com/docs/en/release-notes/system-prompts/claude-sonnet-5> (anthropic, 2026-11-09)
- Checker's verdict: `claim-overreaches`. Sonnet 5 quote and the 9 Nov 2026 heading confirmed. The Opus 5 claim is on a different page (claude-opus-5, also dated 9 Nov 2026); I searched a saved copy of it for 'one question' and 'clarifying question' and found no match, so the Opus 5 sentence is unverified. Cite the Opus page separately if it exists.

> Claude asks a clarifying question only when proceeding would clearly waste effort or go in an entirely wrong direction — and even then, at most one question while still attempting what it can.

The page's text, per the checker:

> Claude asks a clarifying question only when proceeding would clearly waste effort or go in an entirely wrong direction — and even then, at most one question while still attempting what it can.

What it would change: Current models lean toward not asking and toward one question when they do. This is the consumer app prompt, not Claude Code, so it shows trained tendency and not Claude Code behaviour. A skill that wants an interview has to override that lean explicitly, and a compound question in 1 of 3 runs is the model drifting from its default. The grader's single-question rule matches Anthropic's stated default.

## 9. Anthropic's Claude Fable 5 prompting guide says skills written for earlier models are often too prescriptive for the new model and can lower output quality. It advises reviewing them and removing older instructions where default behaviour is better.

- Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5> (anthropic, undated)
- Checker's verdict: `confirmed`. Quote verbatim, followed by 'Review and consider removing older instructions if default performance is better.' The 'recommendation, not an exhaustive survey' line is in a suggested anti-overplanning prompt snippet, not a general rule. The page is about Fable 5 (a Claude 5 family model), so not out of date.

> Skills developed for prior models are often too prescriptive for Claude Fable 5 and can degrade output quality.

What it would change: The brainstorming skill descends from a version-7.0.2 skill written for earlier models. This supports trimming step-by-step ritual and keeping only the rules that change behaviour. The evals are the way to test each removal, since a rule with no measurable effect with versus without the skill is a candidate to cut. The same guide says to 'give a recommendation, not an exhaustive survey' when weighing a choice, which supports the recommended-answer habit.

## 10. Claude Code's best-practices page tells users to ask Claude to interview them until it could write the spec, saying Claude returns multiple-choice questions on the parts not yet pinned down, writes SPEC.md, and then to start a fresh session to build from it.

- Source: <https://code.claude.com/docs/en/best-practices> (anthropic, undated)
- Checker's verdict: `confirmed`. The prompt reads 'Interview me until you could write the spec, then write it to SPEC.md', and the page says to start a fresh session once SPEC.md exists.

> Claude comes back with multiple-choice questions about the parts you haven't pinned down

The page's text, per the checker:

> Claude comes back with multiple-choice questions about the parts you haven't pinned down: per-user versus per-key limits, what happens to requests over the limit, what's out of scope. It keeps asking until the answers add up to a spec.

What it would change: Anthropic's own recommended shape is interview, then a written spec, then a fresh session. That matches the skill's design-document output, and 'fresh session to build' fits its hand-off. It also shows Anthropic describing the questions as multiple choice, the one point where the skill and the published pattern can be compared directly.

## 11. Pocock says weaker and faster models still skip the confirmation gate. Lower-effort or non-frontier models collapse 'interview until shared understanding' into a couple of questions and an outline. His fix is a line in AGENTS.md or CLAUDE.md saying not to implement without permission. The skill is finished when the user says the understanding is shared, not when the frontier empties.

- Source: <https://aihero.dev/skills-grilling> (community, 2026-08-24)
- Checker's verdict: `confirmed`. Sentence found in the FAQ 'It ran out of questions and started building'. Page says lower-effort or non-frontier models collapse the interview into a couple of questions and an outline; fix is a line telling the agent not to implement without permission; finished when you say understanding is shared. Suggesting Haiku 5.5 is the researcher's idea.

> Weaker and faster models still skip the gate.

The page's text, per the checker:

> Weaker and faster models still skip the gate.

What it would change: A named, practitioner-reported failure that fits 'ignoring the skill'. It suggests an eval case where the model is tempted to start building before approval, graded on whether it waited. It also suggests running the suite on a smaller model (Haiku 5.5) to see which rules survive.

## 12. Pocock reports typical grill sessions of about 16 questions for a feature and 30-50 questions, nearly half an hour, on complex ones. In a separate page he says sessions often last about 45 minutes. His to-spec step is separate and does not interview.

- Source: <https://www.aihero.dev/5-agent-skills-i-use-every-day> (community, 2026-03-16)
- Checker's verdict: `claim-overreaches`. Quote verbatim. The page says Claude asked 16 questions in a relatively short session (not described as a typical feature count). The to-spec point is confirmed. The 45-minute figure is from another page and was not checked. The 2026-03-16 date was not checked.

> I've had sessions lasting nearly half an hour with 30, 40, or even 50 questions on really complex features.

The page's text, per the checker:

> I've had sessions lasting nearly half an hour with 30, 40, or even 50 questions on really complex features.

What it would change: The only counts from a well-regarded practitioner are far above spec-kit's 5 and the measured 1-3. The disagreement tracks purpose: Pocock grills a plan or design he will live with for a long run, while spec-kit and the measured studies tune for low interruption. The follow-up has to say which one the brainstorming skill is. Splitting the interview from the document step is another recurring design: the skill could keep both but gate them separately.

## 13. A blind-reviewed vendor benchmark ran Claude Sonnet 5 on 50 Python tickets across Spec Kit, Kiro, BMAD, OpenSpec and a no-spec control. Merged rates were 80%, 82%, 82%, 84% and 72%, with cost per merged ticket from $2.35 to $4.23. The authors state a plus-or-minus 10 point noise band, so the spec workflows are not separable from each other, and barely from the control. It did not count clarifying questions or isolate the clarify step.

- Source: <https://uvik.net/blog/spec-driven-development-benchmark/> (measured, 2026-11-02)
- Checker's verdict: `claim-overreaches`. Quote, model (claude-sonnet-5), rates, cost range, blind review and vendor status confirmed. The article does not say clarifying questions were excluded; it counts corrections or edits as interventions. It also names OpenSpec the top merger despite its own noise-band rule. So 'did not count clarifying questions' is unsupported. The claim's 'barely separable from control' is the researcher's reading (control 72% against 80-84% within a 10-point band).

> The noise band on merge rate is plus or minus 10 percentage points.

The page's text, per the checker:

> The noise band on merge rate is plus or minus 10 percentage points.

What it would change: The only number found on a current Claude model, and it is weak. It does not show that any front-end workflow helps, and it is a vendor run. It is a reminder that a 3-run eval has a similar noise problem: one case that flips in 1 of 3 runs is within noise. The evals need more runs, or graders that check behaviour (one question, waited for approval) and not outcome.

## 14. Kiro's optional requirements analysis surfaces each finding (ambiguity, conflict, completeness and so on) as a simple two-option question, where one answer keeps the requirement and the other changes it with a specific proposal. The user can let an LLM critic pick. The docs say small or well-understood specs can skip the step.

- Source: <https://kiro.dev/blog/deep-spec-analysis/> (community, 2026-05-12)
- Checker's verdict: `claim-overreaches`. Quote verbatim, dated May 12, 2026; keep-or-change-with-proposal and LLM critic choice confirmed. The page calls requirements analysis optional but does not say small or well-understood specs can skip it, so the 'skip for small work' point is not supported by this page. Kiro's main requirements step asking no questions was not checked.

> Each type of finding gets surfaced as a simple two-option question.

The page's text, per the checker:

> Each type of finding gets surfaced as a simple two-option question.

What it would change: A third published form of recommended-default questioning: every question carries a concrete proposal, so the user only decides. Kiro's main requirements step itself asks no questions and uses a confirm gate before design, with EARS-format requirements. The idea that matters is 'skip for small work', which matches the other patterns that scale effort to size.

## Left out by the researcher

- Superpowers (excluded by brief; the search tool did return its brainstorming skill and a pull request on 'asks fewer questions', which I did not read).
- BMAD: the skills.sh product-brief page showed only 'Coach, do not quiz.' with the elicitation rules collapsed; docs.bmad-method.org forge-idea page says it 'argues with you one question at a time' but gives no count, stop rule or date. No citable BMAD question rules found.
- Kiro requirements-first page: does not describe clarifying questions; only EARS format and a confirm-before-design gate (folded into the Kiro finding).
- Practitioner interview write-ups (velvetshark.com, kondasamy.com, neonwatty.com, dev.to, January 2026): typical 20-40+ question interviews, e.g. 32 questions giving a 157-line spec, 'When there's no ambiguity, it's overkill', start a fresh session to build. None name a model above Opus 4.5 era or report problems with over-asking; they are enthusiasm posts, so I left them out in favour of Pocock's counts.
- arXiv 2605.20149 'Less Back-and-Forth' (v2 Oct 2026): checklist-improved prompts scored 7.50/8 against 6.67 for clarifying-question prompts and 5.67 for raw. Measured, but on small open-ended non-coding tasks with ChatGPT, Claude and Grok; I only saw the abstract. Worth a look as the 'propose, don't ask' alternative.
- arXiv 2603.00187 ClarEval: the abstract names metrics (Average Turns to Clarify, Key Question Coverage) but the fetched page had no scores. A blog's 8.94% vs 89.02% figures were not verified against the paper.
- arXiv 2607.26611 CAPA: same-user history cuts turns to completion; Claude Opus 4.8 first-turn success 24.3% to 60.3%. About personalization across sessions, not about question design.
- Skill-activation tests (scottspence.com): forced-eval hook 84% against 20% for a simple instruction, but run on Haiku 4.5, small samples, synthetic API calls; not about user-invoked skills.
- AskUserQuestion limits (Agent SDK docs): 1-4 questions per call with 2-4 options each, and not available in subagents. A useful constraint for a multiple-choice or batched design but a platform fact and not a pattern.
- Fable 5 guide checkpoint line ('Pause for the user only when the work genuinely requires them...') and the 'asking Want me to... will block the work' autonomous-pipeline reminder: relevant to when to stop asking but redundant with the system-prompt finding.
- claudemarketplaces.com (2026-11-15): says grill-me has 'no cap on the number of questions on purpose' and that a long session means the scope is too big. Duplicated by the aihero pages.
- smartscope.blog AskUserQuestion guide: claims of '50-80%' less rework are unsourced.
- Search-snippet-only claims not backed by a fetched page: a search summary said the Uvik benchmark showed 90% against 60% merge rate; the fetched page shows 84% against 72%, so I used the page. Hermes agent docs variant of grill-me (whole frontier in one numbered message) not fetched.

## Questions with no source found

- A measured comparison of one question at a time against a batch of questions for a coding agent. The nearest were the 1-3 question budget paper (not a batch test) and Pocock's observation that rounds save turns.
- A measured comparison of open questions against multiple choice questions for clarification in a coding or design conversation.
- Any 2026 write-up that tests a question-asking design on Claude 5 family models (Fable 5.2, Opus 5.5, Sonnet 5.5, Haiku 5.5). The papers found use Claude Sonnet 4.5 or Opus 4.8 or non-Claude models; the only Claude 5 number is the vendor benchmark, which does not isolate asking.
- Practitioner reports of the context or token cost of a long interview skill. Nothing in the sources I fetched reports it.
- The question rules inside BMAD's analyst or product-brief skill (collapsed on the page I could reach; repo step files not fetched).
- Direct practitioner complaints about spec-kit's clarify step (over-asking or being skipped). Searches found only mirrors of the template.
- A primary source (changelog or commit) dating the switch of Pocock's grilling skill from one question at a time to rounds; the aihero page is dated 2026-08-24 but gives no history.
- Anthropic guidance written specifically for skills that interview the user on Claude 5 models, beyond the Fable 5 guide's 'too prescriptive' line and the chat system prompts.
