# The upstream superpowers brainstorming skill since 7.0.2

Research run on 2026-11-21 by one Sonnet researcher. A second Sonnet agent refetched every
source and gave each finding a verdict. A finding marked anything but `confirmed` is not
evidence until someone reads the page again.

## 1. Upstream's current question rule (7.0.2, unchanged on main): ask only when the answer would change what gets built and nothing already answers it; otherwise state a call as a correctable proposal. It no longer has the 7.0.0/7.0.1 'each message ends with one question' rule, only 'Ask one at a time'.

- Source: <https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md> (community, 2026-11-03 (v7.0.2 release commit 22f0b463 is the newest commit on main as of 2026-11-21))
- Checker's verdict: `confirmed`. First sentence of the quote is on the page. 'Ask one at a time.' is present and no end-with-one-question rule exists. The second sentence of the quote (state your call as a proposal) was not echoed by the fetch, and the '7.0.2 / unchanged on main' framing was not checked on this page, so this is confirmed only on the page's current text.

> Ask a question only when the answer would change what gets built and neither the request nor the project answers it. Otherwise, state your call and your reason as a proposal they can correct, and move the work forward.

What it would change: Test the fork against this wording. A 'one question' rule written as a ritual caused the 'ritual closing question' complaints. A rule keyed to whether the answer changes what gets built is the upstream fix. For the compound-question instability, the fix to try is a conditional on an observable predicate plus 'one at a time', not a bare prohibition (see the writing-skills finding).

## 2. Upstream's measured result for the 7.0.1 to 7.0.2 retune: fewer filler questions, the why surfaced before any approach in every conversation, and nothing built before approval. Blind-graded simulated conversations, Opus 5.5 and Sonnet 5.5.

- Source: <https://github.com/obra/superpowers/releases/tag/v7.0.2> (measured, 2026-11-03)
- Checker's verdict: `claim-overreaches`. The numbers match, but the fetch reports the page does not name the models used. The claim's 'Opus 5.5 and Sonnet 5.5' is not supported by this page (it may come from the evals repo). The page does not confirm the 'simulated conversations' wording either.

> In blind-graded test conversations, filler questions dropped from 41 with 7.0.1 to 23, the reason behind the request came out before any approach in 33 of 33 conversations (28 of 33 before), and nothing got built before approval (4 times before).

The page's text, per the checker:

> In blind-graded test conversations, filler questions dropped from 41 with 7.0.1 to 23 ... (rest: 33 of 33 and 4 times before)

What it would change: Gives target behaviours for the follow-up: count filler questions, check that the why comes out before any approach, and check that nothing is built before approval. Each is a factual yes/no, which fits `claude plugin eval` graders.

## 3. The first fix attempt, removing the mandatory question, made things worse because the why never came out. Upstream therefore replaced it with 'ask why first, openly, with no example answers'.

- Source: <https://github.com/obra/superpowers/pull/2644> (measured, 2026-10-29)
- Checker's verdict: `confirmed`. 'Removing the mandatory question alone made things worse.' is on the page, and the 1 of 9 Opus runs vs 7 of 9 on dev figure is confirmed. The rest of the quote (keep-vs-convert options) and the 'ask why first, no examples' replacement were not echoed verbatim by the fetch.

> Removing the mandatory question alone made things worse. That was the first variant tried. It cut the filler, but the agent then offered keep-vs-convert options in its first message, the persona picked one, and the reason behind the request never came out.

What it would change: If the fork trims questions to fix the compound-question case, add a case that checks the why is still asked. Cutting questions without a floor trades one failure for another. Upstream's grader rated the why conversation good in 1 of 9 Opus runs after the cut, against 7 of 9 on dev.

## 4. The maintainer's stated position on the AskUserQuestion tool: upstream deliberately does not use it and asks in plain text, because the structured tool reduces how much people read and engage with the questions.

- Source: <https://github.com/obra/superpowers/issues/1197> (community, 2026-04-17 (maintainer comment; written in the Sonnet 4.6 era; not an Anthropic source))
- Checker's verdict: `confirmed`. Owner comment of April 17, 2026: 'Not a bug. We explicitly reject AskUserQuestion.' followed by the engagement sentence. Closed as not planned.

> Not a bug. We explicitly reject AskUserQuestion. In our experience, it leads to a dramatic reduction in human reading and engaging with the questions being asked.

What it would change: Upstream settles the tool-vs-text question as plain text, for an engagement reason rather than a technical one. The only place the skill text maps 'ask the user' to AskUserQuestion is the Kimi manifest (.kimi-plugin/plugin.json), an explicit opt-in. A fork that uses AskUserQuestion is departing from upstream and should say why.

## 5. Upstream re-checked the AskUserQuestion behaviour on Claude 5 models: in real TTY sessions (not `claude -p`, which gives a false negative) Sonnet 5 never called the tool and rendered multiple choice as numbered lists in prose. Open issue #2576 reports the opposite want: Claude Code's own prompt favours AskUserQuestion with a recommended option, and the skill's no-menu wording rules it out.

- Source: <https://github.com/obra/superpowers/issues/1773> (community, 2026-09-03 (triage by an Opus/Sonnet subagent team, approved by the maintainer); counter-request #2576 opened 2026-10-21 and still open)
- Checker's verdict: `claim-overreaches`. The quote and the claude -p false-negative note are on the page. Issue #2576 does not appear on this page, so the counter-request part of the claim is unverified here. 'prose, one at a time, numbered lists' was not echoed. The 'v6.0.0 wording caused the tool' so_what was not checked.

> three fresh interactive Sonnet 5 sessions started from 'Let's make a react todo list' in an empty repo made zero AskUserQuestion calls across nine clarifying exchanges — all prose, one question at a time, with multiple-choice questions rendered as numbered lists in the message.

The page's text, per the checker:

> three fresh interactive Sonnet 5 sessions started from 'Let's make a react todo list' in an empty repo ... made zero AskUserQuestion calls across nine clarifying exchanges

What it would change: Evals that run `claude -p` cannot see whether the model reaches for AskUserQuestion, because the tool is unavailable there. If the fork's rule is 'plain text only', the grader should check for tool calls in an interactive-style run. The skill text, not the model, controls this: v6.0.0's tool-agnostic bootstrap wording caused the tool to appear, and removing that wording fixed it.

## 6. The 'skipped the design doc without asking' failure had a specific cause in the skill text, which upstream fixed and measured. The agent was told to pick a size and the human could override it, and the agent read silence as consent.

- Source: <https://github.com/obra/superpowers/issues/2530> (measured, 2026-10-20 (maintainer comment); numbers in the v7.0.1 release notes: skipped the doc 24 of 24 before, 3 of 24 after)
- Checker's verdict: `quote-differs`. The quote was not found. The 24 of 24 and 3 of 24 numbers are confirmed on the v7.0.1 release page, but the stated cause is not supported by any page fetched.

> The cause is in the skill: it tells the agent to pick a size and lets you override it, so the agent treats silence as consent.

The page's text, per the checker:

> Searched twice: neither 'The cause is in the skill' nor 'pick a size' appears on the issue page. The v7.0.1 release notes say only: 'it skipped the doc without asking in 24 of 24 runs before this change and 3 of 24 after' and state no root cause.

What it would change: A skill whose text delegates a judgment call with an 'override' clause invites a skip. Fix it with an explicit ordered checklist before implementing, and with a Red Flags row 'I've answered their questions, so I'll write the doc'. This is the pattern for the skill's gate case. Write the grader as 'agent skipped a step without explicit consent', which is a yes/no.

## 7. How the upstream author tests a behavioural skill: a simulated human (an isolated `claude -p` with a persona holding hidden facts) talks to a real Claude Code session with the plugin loaded. Arms are interleaved, transcripts are shuffled and graded blind by Opus reader agents against fixed rubrics, and the author reports that quality judgments are noisy and only factual yes/no lines are reliable.

- Source: <https://github.com/obra/superpowers/pull/2644> (measured, 2026-10-29 (about 900 sessions, about $627 measured, 57 runs per arm, 9 scenarios))
- Checker's verdict: `claim-overreaches`. The grader-noise quote is confirmed. The method details in the claim (simulated human as isolated claude -p with hidden-fact persona, interleaved arms, shuffled transcripts, Opus readers, 900 sessions, $627, 57 runs per arm) were not checked on the page.

> **Grader noise:** re-grading the same runs in a second pool, the good-vs-thin call on the why conversation matched about two times in three. So the table leans on the factual yes/no line.

The page's text, per the checker:

> the good-vs-thin call on the why conversation matched about two times in three ... the table leans on the factual yes/no line.

What it would change: For `claude plugin eval`, write graders as observable yes/no checks (one question mark in the final message, a numbered list present, a design doc written before building). Avoid 'was the question good'. Use personas that hide a fact so the skill must draw it out, since a grader that demands a detail the skill never teaches scores the same with and without the skill. The same grader needs a persona that actually withholds the detail.

## 8. Upstream's rule for deciding that a skill edit is an improvement: micro-test the wording with a no-guidance control, 5 or more reps per variant, and treat variance across reps as a metric. If the control does not show the failure, write nothing.

- Source: <https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md> (community, undated (on main as of 2026-11-21; the 7.0.1 release trimmed and restructured this skill))
- Checker's verdict: `confirmed`. 'Always include a no-guidance control.', '5+ reps per variant.' and 'Variance is a metric.' are present. The fetch did not echo the remainder ('If the control doesn't exhibit the failure ... stop'), so that part is unconfirmed verbatim, but the claim fits the headings.

> **Always include a no-guidance control.** If the control doesn't exhibit the failure, there is nothing to fix — stop, don't author the guidance.

What it would change: Maps directly onto the two unstable cases. The case that scores the same with and without the skill fails this control test, so the grader or the skill must change. The case that fails about 1 run in 3 is below the stated 5-rep minimum. The same section says '5+ reps per variant. Single samples lie' and 'Variance is a metric': five different interpretations across five reps means the wording is not binding. Use at least 5 reps per arm in the follow-up.

## 9. Upstream measured that prohibition wording can backfire on output-shaping problems (it produced more of the unwanted content than no guidance), while discrete-directive prohibitions and recognition tables held. Its rule is to match the form of the guidance to the failure type. These micro-tests ran on Opus 4.8 with n=5, before the Claude 5 family.

- Source: <https://github.com/obra/superpowers/blob/main/docs/superpowers/specs/2026-06-10-positive-instruction-redesign-design.md> (measured, 2026-06-10 (older models; the same doctrine is now in writing-skills 'Match the Form to the Failure'))
- Checker's verdict: `claim-overreaches`. The table row is confirmed and n=5 is confirmed. The page says only 'opus' and does not specify a version, so 'Opus 4.8' is unsupported here. Claims about discrete-directive prohibitions and recognition tables holding were not checked.

> | Dispatch composition ("don't restate the brief") | prohibition | **4.4** spec values re-typed — *worse than no guidance* (3.6) |

The page's text, per the checker:

> Dispatch composition ("don't restate the brief") | prohibition | 4.4 spec values re-typed — worse than no guidance (3.6)

What it would change: A compound question is an output-shape failure. Prefer a positive recipe ('your message ends with exactly one question, about one thing') over 'never ask two questions', and do not add nuance clauses ('unless it matters'). Re-measure on Claude 5, since the numbers come from an older model.

## 10. A third party measured a brainstorming gate rule with `claude plugin eval` and got a misleading ablation. The first ablation runs showed no effect because a line-based tool left a fragment of the sentence in place. With the whole sentence removed the effect was 0 of 3 versus 7 of 8. Upstream closed the request because 7.0.2 deliberately ends the gate when the user opts out of questions.

- Source: <https://github.com/obra/superpowers/issues/2655> (measured, 2026-11-03)
- Checker's verdict: `confirmed`. Quote verbatim. Counts 0 of 3 and 7 of 8 confirmed. Closed as not planned because in 7.0.2 opting out of questions ends the approval gate. The claim's mention of claude plugin eval and PR #2263 was not checked.

> Our first two mutation runs removed only part of the proposed sentence (a line-based tool left a fragment), which is why they showed no effect.

What it would change: Check that the 'without the skill' or 'sentence removed' arm really lacks the text, for example by grepping the staged skill file before each batch. Upstream's evals do the same ('Arms were separate plugin roots, verified before each batch by grepping the installed SKILL.md', PR #2263). Also expect run-to-run variance larger than small effects at n=5. Upstream's 7.0.2 SKILL.md says an opt-out ends the gate, which a fork may want to decide on explicitly.

## 11. Upstream's model-specific note: Opus 5.5 and other frontier models were overzealous, doing unrequested work such as implementing the whole project during planning. The maintainer says elsewhere that new models 'develop new quirks' and are 'insanely proactive'. The tuning on current models has therefore been about holding gates and steps, not about getting the model to ask more.

- Source: <https://github.com/obra/superpowers/releases/tag/v6.4.2> (community, 2026-09-25 (blog post on 6.4 dated 2026-09-21: 'As the frontier models get more capable, they also develop new quirks.'))
- Checker's verdict: `claim-overreaches`. The quote is confirmed. The inferences (the maintainer's 'insanely proactive', blog on 6.4, 'tuning is about holding gates not asking more') are not on this page. The note says 'with certain prompting', which is narrower than 'dominant failure on Claude 5'.

> Some frontier models, including Opus 5.5, could get overzealous during plan writing and, with certain prompting, would sometimes try to implement the entire project while designing the plan.

The page's text, per the checker:

> Some frontier models, including Opus 5.5, could get overzealous during plan writing and, with certain prompting, would sometimes try to implement the entire project while designing the plan.

What it would change: On Claude 5 the dominant failure is acting too early, so the design-approval gate and the 'nothing built before approval' check deserve a case of their own. Upstream tests Opus 5.5 and Sonnet 5.5 together and reports no arm differences between them on most scenarios. No upstream source says anything specific about Fable 5.2 or Haiku 5.5 for brainstorming (see could_not_find).

## 12. A measurement on Haiku 5.5 found a wording trap inside upstream's brainstorming text. Haiku put the design in the same reply as 'one sensible way', which the skill says to defer. The 7.0.2 text contradicts itself: lines 34-36 fold steps 1 to 3 into one message when nothing is open, and lines 164-166 say the design comes in the next message.

- Source: <https://github.com/obra/superpowers/issues/2665> (measured, 2026-11-05 (dokimi probes on Haiku 5.5 and Sonnet 5.5; 478 facts across 15 skills; 0 degraded facts))
- Checker's verdict: `claim-overreaches`. The quote is in the Harmful spots table for Haiku 5.5 on skills/brainstorming/SKILL.md:164-166. But the issue author notes both the with-skill and without-skill answers were wrong, so it is not skill-caused harm, and the author recommends only clarifying the wording. The claimed self-contradiction is the researcher's reading: SKILL.md does contain both sentences, but this page does not call it a contradiction. '0 degraded facts' not checked.

> Says to say so and explain, then gives the design in the same reply and asks for approval (wrong, the design should come in the next message)

The page's text, per the checker:

> Says to say so and explain, then gives the design in the same reply and asks for approval

What it would change: If the fork adapted the 'Your First Message' and 'Lay out the approaches' sections from 7.0.2, resolve this contradiction in its own text. Reread the line 'If nothing is open when you write your first message and there's one sensible way, steps 1 to 3 happen in that message' against 'the design comes in the next one'. Add an eval case on Haiku 5.5 as well, since upstream's evals ran Opus and Sonnet only.

## 13. A negative result from the upstream experiment log: stating an explicit goal with an understanding test ('you understand what they want when...') made the intent dialogue worse and produced more questions, and was reverted. Several other wording variants were null at 5 to 8 runs.

- Source: <https://github.com/prime-radiant-inc/superpowers-evals/blob/brainstorming-approaches-evals/docs/experiments/2026-10-20-brainstorming-approaches-and-consent.md> (measured, 2026-10-20 (Opus 5.5 and Sonnet 5.5, 8 runs per arm, blind-graded))
- Checker's verdict: `confirmed`. Passage matches: Offsite truths 25/28 vs 28/28, book club 9/16 vs 11/16, core why 4/8 vs 7/8, more questions (6.75 vs 5.1). Reverted. It refers to the explicit goal plus understanding test variant. The 'other variants null' and 8 runs per arm detail was not checked.

> worse. Offsite truths 25/28 vs 28/28, book club
>   9/16 vs 11/16, core why 4/8 vs 7/8, more questions (6.75 vs 5.1). Reverted.

What it would change: Adding a definition of 'done questioning' raised the question count, so a stop-condition clause may not reduce questions. Most single-sentence variants (red-flag rows, skip-offer wording, recalibration rules) were within noise at 5 to 8 runs. Plan for 8 or more runs per arm, and expect that a small wording change cannot be told apart from noise below that.

## 14. What held and what did not after the 7.0.2 retune, per users. One user found 7.0.2 'seems better'. Others on 7.0.2 still hit the ritual closing question, and the full pipeline (design doc, then plan) on a trivial change. Some of the reports came from 7.0.0 because the official marketplace lagged.

- Source: <https://github.com/obra/superpowers/issues/2530> (community, 2026-11-16 (issue #2530 is still open; the comment is on 7.0.2))
- Checker's verdict: `confirmed`. The comment is quoted verbatim, dated Nov 16 2026, about 7.0.2. The issue is open. obra said 7.0.2 should be 'much better' but not yet in the official marketplace. The 'one user found it seems better' and PR 6847 details were not checked.

> Every brainstorm now becomes design doc → plan → execute, which is how a one-line CSS change ends up with a spec and a plan.

What it would change: Residual failure modes to add as cases, after the filler-question fix: (1) a tiny change should not get a spec and a plan; (2) a fully specified request should end with zero questions; (3) a user with a design already in mind wants the 2 to 3 approaches with trade-offs. Upstream restored the approaches in 7.0.1. A maintainer said of 7.0.2, 'should be *much* better', and that the official marketplace was behind (anthropics/claude-plugins-official PR 6847), so check which version a complaint refers to.

## Left out by the researcher

- Releases after 7.0.2: none exist. v7.0.2 (2026-11-03) is the newest release and the release commit 22f0b463 is the newest commit on main and on the brainstorming skill path. There is no post-7.0.2 changelog to report.
- Issue #2576 (bug reports get a restate-and-confirm turn; wants AskUserQuestion): used only as the counter-request in the AskUserQuestion finding. It has no repro and was filed against 7.0.0.
- Issue #2377 (pressure-language bootstrap degrades current models; a 315-session comparison showed Sonnet 5 and Fable 5.1 often skip the matching skill without the bootstrap, and a calibrated rule routes the same as the shouting one) and the closed duplicate #2423: about the using-superpowers bootstrap, not brainstorming. They quote Anthropic prompting guidance second-hand; the Anthropic docs are another worker's topic.
- PR #2258 (6.4.1 intent and stage-gate fix) and PR #2263 (hold the open question): evaluated on Codex with gpt-6 models, so not about Claude 5 behaviour. #2263 said its bullet changed nothing on Claude Code/Opus 5 (4/5 in both arms).
- Issue #2240 (one-question rule is a proxy for a quality property; batching independent questions with recommendations): the 2026-10-21 closing comment is used as a source for the one-question-rule decision, but I left the finding out for lack of space. Its supporting evidence (7 sessions) is observational with no no-skill control, which the reporter admits.
- Issue #1642 (adaptive batched questioning): maintainer answer was a brief 'we will not be switching brainstorming to handing you a wall of text with a bunch of questions'. Folded into the 7.0.2 rule discussion rather than reported separately.
- Issues #1989, #2507, #2555, #2720, #2653, #2434: open or closed feature requests with no eval evidence or no bearing on question behaviour.
- docs/superpowers/specs/2026-10-05-brainstorming-rebuild-design.md: the design rationale for 7.0.0 ('Interrogation: a checklist of questions read at the human'). Background only; 7.0.2 supersedes the 'offer a menu only when stuck' and 'offer recon' rules.
- Blog posts on blog.fsck.com (What a year, 2026-10-09; Superpowers 6.4, 2026-09-21; The Therapist Pattern; Some new agentic patterns): the author's only brainstorming statements are marketing-level ('completely rebuilt brainstorming experience') and say nothing on how questions are asked or how skills are tested. I used the 6.4 post line on model quirks only as supporting context in a finding.
- The writing-skills reference testing-skills-with-subagents.md (RED/GREEN/REFACTOR pressure scenarios): aimed at discipline-enforcing skills; its 'IMPORTANT: This is a real scenario. Choose and act' prompts fit rule-compliance skills better than a questioning skill. Upstream moved such prompts out of installed skill folders in 7.0.2 (#2277).

## Questions with no source found

- Any change to the brainstorming skill after 7.0.2: none exists as of 2026-11-21.
- How upstream says the skill behaves on Fable 5.2, Opus 5.5, Sonnet 5.5 or Haiku 5.5 specifically: upstream's evals ran Opus 5.5 and Sonnet 5.5 (earlier iterations also ran Haiku 5.5 and Codex models), but I found no per-model statement about brainstorming. The only model-named notes are the 6.4.2 Opus 5.5 overzealous-planning note and the #2665 Haiku 5.5 probe. No source mentions Fable 5.2.
- Any upstream measurement of compound or multi-part questions (more than one question in a turn). The only mention is that the simulated persona bundled questions after the skip offer (experiment log), and the 7.0.2 text keeps only 'Ask one at a time'.
- A blog.fsck.com post from 2026 about tuning brainstorming, evals, or the AskUserQuestion decision. The Oct 9 and Sep 21 posts are the only relevant ones and are thin.
- The upstream eval harness's own pages (superpowers-evals brainstorming-questions-evals branch, referenced as 'not yet pushed' in PR #2644, commit 7f374ce6): the rubrics for 'filler question' and 'intuitive question' are not published, so how filler is defined for grading is unknown.
- Note on method: pages were read as raw text through `gh api`, `curl` and the GitHub API rather than the WebFetch summariser, so that quotes are exact. Quotes with line breaks in the source have been joined on one line except where noted.
