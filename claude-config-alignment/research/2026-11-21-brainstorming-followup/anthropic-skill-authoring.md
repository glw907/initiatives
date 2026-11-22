# What Anthropic publishes on writing skills and prompts

Research run on 2026-11-21 by one Sonnet researcher. A second Sonnet agent refetched every
source and gave each finding a verdict. A finding marked anything but `confirmed` is not
evidence until someone reads the page again.

## 1. Anthropic's Claude Code best-practices page lists 'add IMPORTANT or ALL CAPS' as advice to stop following: current models follow plainly worded lines and emphasis makes them over-apply the rule; rules that cannot bend belong in a hook, not louder wording.

- Source: <https://code.claude.com/docs/en/best-practices> (anthropic, undated (page names Opus 5.5 as the default model and Fable 5.2, so late 2026))
- Checker's verdict: `confirmed`. Quote is in the 'stop doing' table row 'Add IMPORTANT or ALL CAPS to instructions Claude keeps missing', word for word. The same row says a rule that can't bend should become a hook or deny rule. Page names current models (auto mode, SPEC flow), not out of date.

> Older models sometimes needed the emphasis. Current ones follow a plainly worded line, and piling on emphasis mostly makes Claude over-apply the rule.

What it would change: Strip capitals, hard-gate tags and red-flag tables from the brainstorming skill and replace each with a plain sentence plus its reason. Over-application is a risk: a loud 'one question' rule can make the model refuse needed follow-ups. Add a case that checks the skill does not over-refuse a legitimate second question.

## 2. Anthropic's own skill-creator skill tells the author to explain the reason behind an instruction instead of using heavy MUSTs, and calls ALWAYS or NEVER in capitals a 'yellow flag'. This is the direct Anthropic replacement for emphatic wording.

- Source: <https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md> (anthropic, 2026-03-06 (date of the latest commit touching this file; the file itself carries no date))
- Checker's verdict: `confirmed`. Verified by raw fetch. Line 139: 'Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs.' Line 302: 'If you find yourself writing ALWAYS or NEVER in all caps, or using super rigid structures, that's a yellow flag'. The 2026-03-06 commit date was not checked.

> Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs.

What it would change: Rewrite each rule in the skill as 'do X because Y goes wrong otherwise', for example 'ask one question per turn because a second question gets skipped or answered half'. The same file also says: 'If you find yourself writing ALWAYS or NEVER in all caps, or using super rigid structures, that's a yellow flag'. That is a usable lint rule for the rewrite.

## 3. The Fable 5.2 prompting guide says the model treats 'never' as absolute and tells authors to rewrite absolute rules with their scope and reason. Stacked cautions make agents ask for approvals they do not need.

- Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2> (anthropic, undated (page cites 2026-08 beta headers, so published after Aug 2026))
- Checker's verdict: `claim-overreaches`. Quote and the claim text are supported (also 'rewrite absolute rules with their scope and reason'). The so_what goes further: that a 'never write code before approval' gate will be obeyed even after the user says 'go'. The page does not say that. It is about approvals and file deletion, and it concerns Fable 5.2 specifically.

> The model treats an instruction that contains “never” as absolute.

The page's text, per the checker:

> The model treats an instruction that contains “never” as absolute. For example, write “ask for approval before deleting files” instead of “never delete files” if you want the model to keep responsibility over an action.

What it would change: A 'never write code before approval' hard gate will be obeyed literally, including when the user has already said 'go'. State the gate with its scope and its exit: 'do not start building until the user approves the design; once they say go, proceed'. Check the skill for 'never' and 'always' lines that lack an exit.

## 4. Sonnet 5 is documented as following prompts literally and not generalizing an instruction from one item to another. Sonnet 5.5's page says Sonnet 5 prompts should perform well unchanged and remain a reasonable starting point, so the literalism carries over. Authors must state scope explicitly.

- Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5> (anthropic, undated (Sonnet 5 page, mid-2026; the Sonnet 5.5 page was fetched and says Sonnet 5 patterns 'remain a reasonable starting point'))
- Checker's verdict: `confirmed`. Quote is word for word in 'More literal instruction following', which says literalism is strongest at lower effort and tells authors to state scope explicitly. The Sonnet 5.5 page says 'the patterns in Prompting Claude Sonnet 5 remain a reasonable starting point'. The 'likely cause of the flake' is the researcher's inference and is labelled as such.

> It does not silently generalize an instruction from one item to another, and it does not infer requests you didn’t make.

What it would change: This is the likely cause of the compound-question flake. 'Ask one question at a time' leaves open whether 'A, and if so B?' is one question. Define it in the skill: one question mark, one decision, no 'and also'. Give one compliant and one non-compliant example. Then make the grader check the same definition.

## 5. Anthropic's Claude Code best practices describe the interview pattern: tell Claude to interview you until it can write the spec, it asks multiple-choice questions on the unpinned parts, and the output is a SPEC.md that a fresh session builds from and a reviewer checks against.

- Source: <https://code.claude.com/docs/en/best-practices> (anthropic, undated (page names Opus 5.5 and Fable 5.2, so late 2026))
- Checker's verdict: `confirmed`. Quote is verbatim. The example prompt is 'Interview me until you could write the spec, then write it to SPEC.md.' The page also says 'It keeps asking until the answers add up to a spec' and points the reviewer at SPEC.md.

> Once `SPEC.md` exists, start a fresh session to build from it, so the build begins with a clean context and a written definition of done.

What it would change: The skill's end product should be a written spec file with a definition of done, handed to a fresh session. The same page's example prompt says 'Interview me until you could write the spec, then write it to SPEC.md.' That gives a stopping rule, 'enough to write the spec', which the skill can use instead of a fixed question count. It also says Claude 'keeps asking until the answers add up to a spec'.

## 6. The AskUserQuestion tool is built for batched multiple-choice questions: 1-4 questions per call with 2-4 options each, a free-text 'Other' path, and no availability in subagents. Anthropic's docs do not say 'one question at a time'.

- Source: <https://code.claude.com/docs/en/agent-sdk/user-input> (anthropic, undated (Agent SDK docs; mention SDK v0.3.268 and Claude Code v2.1.207, so 2026))
- Checker's verdict: `claim-overreaches`. The limits, the free-text 'Other' handling and the subagent limitation are confirmed. The 'docs do not say one question at a time' point is an absence claim that this page cannot prove. The 'headless claude -p has no user' point is inference. The page is about SDK handling of the tool.

> each `AskUserQuestion` call supports 1-4 questions with 2-4 options each

The page's text, per the checker:

> Subagents: `AskUserQuestion` is not currently available in subagents spawned via the Agent tool. Question limits: each `AskUserQuestion` call supports 1-4 questions with 2-4 options each

What it would change: 'One at a time' is the developer's own design choice, not Anthropic doctrine, so the skill should justify it itself. If kept, instruct one question per AskUserQuestion call with 2-4 options and a recommended first option. Do not assume an eval run can answer the tool: the docs say it is not available in subagents, and a headless `claude -p` run has no user to answer. Check how `claude plugin eval` handles it before grading 'single question' on tool calls instead of on transcript text.

## 7. Claude Code's auto mode nudges Claude to skip clarifying questions unless the prompt or a skill explicitly relies on asking. A skill that needs an interview must say so.

- Source: <https://code.claude.com/docs/en/permission-modes> (anthropic, undated (page describes auto mode as the default for new sessions, so 2026))
- Checker's verdict: `confirmed`. Quote is verbatim. The page says auto mode is the default for interactive terminal and VS Code sessions, but claude -p and Agent SDK runs start in Manual. That matters for the eval-run advice. Only the first 100,000 of 121,926 characters were read.

> Auto mode also nudges Claude to keep working without stopping for clarifying questions, though Claude still asks when your prompt or a skill explicitly relies on it.

What it would change: Put one plain sentence near the top of the skill: the interview is the point of this skill, so ask the user before building. Run at least one eval case under auto mode, since the default for new sessions may suppress questions and make the no-skill baseline and the with-skill run look alike.

## 8. The Sonnet 5.5 guide supplies a plain-sentence system prompt for ideas-or-plan requests, 'give them that and stop', as the Anthropic-written replacement for a hard gate. It also says to stop to ask only when the model cannot go on without the user.

- Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5> (anthropic, undated (page cites a 2026-08 beta header, so published after Aug 2026))
- Checker's verdict: `claim-overreaches`. Both sentences are on the page, but neither is framed as a replacement for a hard gate. The 'only stop to ask' line is from a prompt meant to stop the model checking in too often on coding tasks at low and medium effort. Using it as a test for interview questions is the researcher's own reuse, not what the page says.

> When the user asks for ideas, options, or a plan, give them that and stop. Don't start building or changing anything until they say to go ahead.

The page's text, per the checker:

> When the user asks for ideas, options, or a plan, give them that and stop. Don't start building or changing anything until they say to go ahead. // Keep working until everything the user asked for is done, and only stop to ask when you can't go on without the user or before a risky step.

What it would change: Use this shape for the build gate in place of a <HARD-GATE> block. The same page's wording for when to ask is 'only stop to ask when you can't go on without the user or before a risky step'. That gives a test for each interview question: could the model answer it from the repo? If yes, it should not ask. This matches the skill's 'read the project first' step.

## 9. Anthropic notes that spreading an underspecified task across many user turns costs tokens and sometimes quality, and recommends putting task, intent and constraints in the first human turn. This is a cost of long, one-question-per-turn interviews.

- Source: <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5> (anthropic, undated (Sonnet 5 page, mid-2026))
- Checker's verdict: `confirmed`. Quote is verbatim, in 'Interactive coding products', which advises specifying task, intent and constraints upfront. It is about reducing user interactions in coding products, so applying it to interview skills is the researcher's inference, which the so_what flags as a tension.

> In contrast, ambiguous or underspecified prompts conveyed progressively over multiple user turns tend to relatively reduce token efficiency and sometimes performance.

What it would change: Tension with the one-question-at-a-time rule. Cap the interview: skip questions the project files already answer, ask first about the questions that change the design most, and stop at 'enough to write the spec'. Consider opening with a short up-front summary of what the model already read so the user corrects it in one turn.

## 10. Anthropic's skill-creator says Claude under-triggers skills and tells authors to write descriptions that are 'a little bit pushy', with explicit contexts including cases where the user does not name the domain.

- Source: <https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md> (anthropic, 2026-03-06 (date of the latest commit touching this file))
- Checker's verdict: `confirmed`. Verified by raw fetch at line 67, quote verbatim, including the 'even if they don't explicitly ask for a dashboard' example and the 'All "when to use" info goes here, not in the body' line. The Opus 4.5/4.6 over-trigger counter-risk in the so_what, and the commit date, were not checked.

> Note: currently Claude has a tendency to "undertrigger" skills -- to not use them when they'd be useful. To combat this, please make the skill descriptions a little bit "pushy".

What it would change: The current description ('Use when new work's design is not settled yet, or when the user asks to brainstorm') is reactive. List the trigger phrasings a user would actually type ('I want to add X but haven't thought it through', 'how should we build', 'what's the best approach'), including ones that never say 'brainstorm'. Same file: 'All "when to use" info goes here, not in the body.' Note the counter-risk with current models: Opus 4.5/4.6 guidance warns pushy skill language can now over-trigger (see dropped).

## 11. The skill-authoring page says the description is injected into the system prompt and must be third person; it must say what the skill does and when to use it.

- Source: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> (anthropic, undated (page lists Haiku, Sonnet, Opus; no date shown))
- Checker's verdict: `confirmed`. Page says 'Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems.' and 'should include both what the Skill does and when to use it'. The PDF example from the so_what matches the page, with the ellipsis eliding 'fill forms, merge documents'.

> The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems.

What it would change: Rewrite the description in third person with both parts: what it does ('Runs a design conversation before building: reads the project, asks one question at a time, proposes two or three approaches, writes a design for approval') and when ('Use when...'). Avoid 'I' or 'you'. The page's own good examples are 'Extract text and tables from PDF files... Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.'

## 12. The Claude Code skills docs cap the combined description and when_to_use text at 1,536 characters in the skill listing and say to put the key use case first.

- Source: <https://code.claude.com/docs/en/skills> (anthropic, undated (mentions Claude Code version numbers; current 2026 docs))
- Checker's verdict: `confirmed`. Quote verbatim in the frontmatter reference. The 1,024-character platform limit for description alone is confirmed on the other skill page. Only the first 100,000 of 119,731 characters were read.

> Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing to reduce context usage.

What it would change: Trigger phrases can move to the `when_to_use` field, which counts toward the same cap. Lead with the main trigger ('design not settled'). The platform page still lists a 1,024-character limit for the description field alone, so stay under 1,024 to satisfy both.

## 13. Anthropic's skill-authoring page and the Claude Code docs both set 500 lines as the SKILL.md ceiling and say to move detail into reference files linked directly from SKILL.md, one level deep.

- Source: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> (anthropic, undated (no date shown on the page))
- Checker's verdict: `claim-overreaches`. The 500-line ceiling is on both pages, and the Claude Code page also has 'every line is a recurring token cost'. The 'one level deep' rule was seen only on the platform page. The Claude Code page says only to move detailed reference material to separate files.

> Keep the `SKILL.md` body under 500 lines for optimal performance.

The page's text, per the checker:

> Keep the `SKILL.md` body under 500 lines for optimal performance. // Keep references one level deep from `SKILL.md`.

What it would change: 500 is a ceiling, not a target; the Claude Code docs add that once loaded, a skill body 'stays in context across turns, so every line is a recurring token cost'. For an interview skill that runs many turns, keep SKILL.md to the process and the stopping rule, and move the spec template, example questions and approach-comparison format into files read only at the step that needs them. Keep references one level deep from SKILL.md; the page warns Claude may only partly read nested files.

## 14. Anthropic's March 2026 skill-creator post says that if the base model starts passing your evals without the skill loaded, the skill's technique may now be part of default behaviour, so the skill is no longer needed for that behaviour. This is the logic for pairing every case with a no-skill baseline.

- Source: <https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills> (anthropic, 2026-03-03)
- Checker's verdict: `claim-overreaches`. Quote verbatim, published 2026-03-03, and '5 out of 6 public skills' is confirmed. The post says this applies mainly to capability uplift skills and does not recommend a baseline for every case. The claim omits that limit. The so_what does mention it.

> If the base model starts passing your evals without the skill loaded, that's a signal the skill's techniques may have been incorporated into the model's default behavior.

The page's text, per the checker:

> This applies mainly to capability uplift skills. If the base model starts passing your evals without the skill loaded, that's a signal the skill's techniques may have been incorporated into the model's default behavior. The skill isn't broken; it's just no longer necessary.

What it would change: The case that scores the same with and without the skill is, by this logic, either a grader testing something the model does anyway or a detail the skill does not teach. Either teach the detail in the skill or change the grader to check behaviour the skill adds (for example, that the model asked before building). The post applies this to 'capability uplift' skills, and a process skill like brainstorming may differ, but the baseline check still holds. Also from the post: 'We ran it across our document-creation skills and saw improved triggering on 5 out of 6 public skills.'

## 15. Anthropic's January 2026 evals post says to grade what the agent produced, not the path it took, because rigid path checks are brittle and agents find valid approaches the designer did not anticipate. It also says a good task is one where two experts would reach the same verdict.

- Source: <https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents> (anthropic, 2026-01-09)
- Checker's verdict: `confirmed`. Page dated 2026-01-09. All three quotes are on it: the grade-output quote in the graders step, and the two-experts and 'Ambiguity in task specifications becomes noise in metrics' quotes in the unambiguous-tasks step. The 'read transcripts of many trials' line was not checked.

> So as not to unnecessarily punish creativity, it’s often better to grade what the agent produced, not the path it took.

What it would change: Both unstable cases fit. The compound-question grader judges a path detail, so define a countable rule (number of question marks or decisions per turn) that two reviewers would score the same. The grader that demands a detail the skill never teaches fails the post's test: 'A good task is one where two domain experts would independently reach the same pass/fail verdict.' The post also says 'Ambiguity in task specifications becomes noise in metrics', which describes the 1-in-3 flake. It recommends reading transcripts of many trials to check graders.

## Left out by the researcher

- Prompting best practices page (platform.claude.com .../claude-prompting-best-practices): 'Where you might have said "CRITICAL: You MUST use this tool when...," you can use more normal prompting such as "Use this tool when..." instead.' Dropped as a separate finding because it is about Opus 4.5/4.6 and tool triggering, and the Claude Code best-practices quote (finding 1) says the same for current models. It is also the source for the over-triggering caution mentioned in finding 10.
- Same page: 'Providing context or motivation behind your instructions, such as explaining to Claude why such behavior is important, can give Claude more information about your goals' and 'Tell Claude what to do instead of what not to do'. Dropped as duplicates of the skill-creator 'explain why' finding, though they confirm it from the main prompting page.
- Skill-authoring page 'Set appropriate degrees of freedom': match specificity to fragility; interviews are a high-freedom task. The same page still shows 'ALWAYS use this exact template structure' for strict formats and suggests 'MUST filter' as a possible fix. Dropped for the 15 cap; it shows Anthropic still allows strong wording for fragile, low-freedom steps, but an interview is not one.
- Skill-authoring page 'Implement feedback loops' and 'Create verifiable intermediate outputs' (plan-validate-execute). Dropped: relevant to the design-document step but not to the interview or the two flaky cases.
- agentskills.io 'Optimizing skill descriptions' (community-run open standard): imperative phrasing ('Use this skill when...'), focus on user intent, about 20 trigger queries with 3 runs each and a 0.5 trigger-rate threshold, train/validation split. Dropped for the cap and because its 'imperative phrasing' advice conflicts with Anthropic's third-person rule; worth reading when the description is rewritten.
- agentskills.io 'Evaluating skill output quality': 'Remove or replace assertions that always pass in both configurations' and 'Investigate assertions that always fail in both configurations'. Dropped as it restates finding 14 for the same-with-and-without case; it would be the practical checklist for fixing that case.
- Anthropic engineering 'Demystifying evals' on pass@k vs pass^k and 'a 0% pass rate ... is most often a signal of a broken task'. Dropped for the cap; pass^k ('all k trials succeed') matches a 3-run suite where 2 of 3 passing is a flake.
- Anthropic engineering 'Harness design for long-running application development' (2026-03-24): planner expands a 1-4 sentence prompt into a spec kept to 'product context and high level technical design rather than detailed technical implementation'; and 're-examine a harness, stripping away pieces that are no longer load-bearing'. Dropped for the cap; supports keeping the design document high-level and trimming skill scaffolding as models improve.
- Fable 5.2 guide: style rules followed closely can make prose choppy; 'Finish the whole task' prompt text that welcomes 'clarifying with the user on open decisions'. Dropped as marginal.
- Sonnet 5 guide: 'Before building, propose 4 distinct visual directions ... Ask the user to pick one, then implement only that direction.' Anthropic's own options-before-build example; dropped as the skill already proposes two or three approaches.
- Skill-authoring page: 'Claude models handle the Skill format and structure natively. You don't need special system prompts or a "writing skills" skill' and its Claude A/B iteration method. Dropped; process advice, not a design decision.
- Skill-authoring page example in 'Develop Skills iteratively' suggesting 'using stronger language such as "MUST filter" instead of "always filter"'. Dropped; it contradicts the 2026 guidance above and appears to be an older passage, but it shows the skill-authoring page itself is not fully updated for current models.
- Anthropic engineering 'Effective context engineering' (2025-09-17) and 'Equipping agents for the real world with Agent Skills' (2025-09-29): both older than 2026 and not read in full. The engineering index shows no 2026 post on skills or context engineering.

## Questions with no source found

- Any Anthropic statement on hard-gate tags (for example <HARD-GATE>) or red-flag tables in a skill, for or against. Only the general emphasis guidance in findings 1-3 applies.
- Anthropic guidance on asking clarifying questions one at a time versus batched. The AskUserQuestion docs show batches of 1-4 multiple-choice questions, the best-practices page shows an interview producing multiple-choice questions, and Sonnet 5 says multi-turn progressive specification costs efficiency. None recommends one question per turn.
- Anthropic guidance on open versus option-based questions beyond the tool's schema (2-4 options plus free-text 'Other').
- An Anthropic page that says when AskUserQuestion is the recommended way to ask versus plain chat text. The Agent SDK docs say it is how Claude asks clarifying questions and is common in plan mode, and the mirrored tool prompt (not read, third-party copy) says to use ExitPlanMode for plan approval. The official Claude Code docs I fetched do not state a rule.
- The Claude Code documentation page on plan mode did not mention clarifying questions in the part I read (first 100,000 of about 122,000 characters of permission-modes).
- A 2026 Anthropic engineering post on skills or context engineering; none exists in the engineering index (latest relevant posts are 2025-09).
- Dates on the platform.claude.com docs pages (best practices, Sonnet 5, Sonnet 5.5, Fable 5.2 and the Claude Code docs); none display a last-updated date.
