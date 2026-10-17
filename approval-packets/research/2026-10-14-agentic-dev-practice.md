# Agentic development practice for the approval queue

Research brief for the approval-queue design: software engineering and agent-system practice. The
cognitive-science side (automation bias, working memory, briefing formats) is covered elsewhere and
is not repeated here.

Retrieved 2026-10-14. Each finding names its source. "Vendor-reported" marks numbers published by a
company that sells the product or an adjacent one. "Secondary" marks a figure I could not confirm
against the primary text.

---

## 1. Human-in-the-loop patterns in agent frameworks and products

### 1.1 What each source makes the human decide

| Source | What the human decides | Granularity | What the human is shown |
|---|---|---|---|
| Anthropic, "Building effective agents" (2024) | Task intent up front; feedback at checkpoints or blockers | Checkpoint, not step | The agent's planning steps ("transparency") |
| Claude Code best practices (current docs) | Plan approval (plan mode); permission prompts in Manual mode; final review | Plan, then whole change | Evidence: test output, commands run, screenshots |
| Claude Code auto mode (2026) | Only what a classifier flags; escalation after repeated denials | Per action, filtered | The blocked action and the reason |
| OpenAI, "A practical guide to building agents" (2025) | High-risk actions; cases past a failure threshold | Per tool, risk-rated | The paused action |
| LangChain/LangGraph HITL middleware | approve, edit, reject, or respond, per gated tool call | Per tool call; batched per turn by default | The proposed call and its arguments |
| GitHub Copilot cloud agent | Whether CI may run; PR review; merge | Whole PR | Session logs, PR description |
| Devin 2.1 (2025) | Answers to clarifying questions when confidence is not green; PR review | Plan and PR | A green, yellow, or red confidence rating |
| Cursor cloud agents (2026) | PR review | Whole PR | Videos, screenshots, logs attached to the PR |
| OpenAI Codex (2025-2026) | Out-of-sandbox actions; PR review | Per action plus whole PR | Citations to terminal logs and test output |
| Anthropic Claude Code Review (2026) | Approval stays human | Whole PR | Ranked, verified findings |

### 1.2 Findings

**F1.1 Checkpoints, not steps.** Anthropic's guidance has agents work independently once the task is
clear and "pause for human feedback at checkpoints or when encountering blockers". It also says that
for coding agents "human review remains crucial for ensuring solutions align with broader system
requirements." Agents should "gain 'ground truth' from the environment at each step", meaning tool
results and code execution.
Source: Erik Schluntz and Barry Zhang, Anthropic, 2024-12-19,
https://www.anthropic.com/research/building-effective-agents

*Implication.* The queue's hand-over points are the checkpoints. The agent owns the steps between
them. The human owns alignment with "broader system requirements": intent, scope, and fit.

**F1.2 Evidence over assertion; deterministic gates.** Claude Code's docs say: "Have Claude show
evidence rather than asserting success: the test output, the command it ran and what it returned,
or a screenshot of the result. Reviewing evidence is faster than re-running the verification
yourself, and it works for sessions you weren't watching." They rank gate strength from a prompt
instruction to a `/goal` evaluator to a Stop hook (deterministic) to "a second opinion", where a
fresh subagent tries to refute the result "so the agent doing the work isn't the one grading it."
They also warn: "If you can't verify it, don't ship it."
Source: Anthropic, Claude Code docs, "Best practices", https://code.claude.com/docs/en/best-practices

*Implication.* Every packet claim needs an evidence handle the human can open: a CI run, a test
log, a screenshot, a review report. Self-certification counts only when the gate was deterministic
or independent. "The agent says tests pass" is not evidence. "CI run #N on SHA X passed" is.

**F1.3 Plan approval is the cheap, high-leverage decision.** The docs recommend explore, then plan,
then implement, with the plan editable before work starts. They skip planning when "you could
describe the diff in one sentence."
Source: same as F1.2.

*Implication.* Design calls should reach the queue before the code exists, as their own item type.
A PR whose design was already ruled on can carry a pointer to that ruling and does not need a new
design decision.

**F1.4 Per-prompt approval decays into rubber-stamping.** "Claude Code users approve 93% of
permission prompts... Over time that leads to approval fatigue, where people stop paying close
attention to what they're approving." Auto mode puts a classifier in front of the human. The full
pipeline has a 0.4% false-positive rate and a 17% miss rate on real overeager actions ("the honest
number"). "If a session accumulates 3 consecutive denials or 20 total, we stop the model and
escalate to the human." The authors say it "is not a drop-in replacement for careful human review
on high-stakes infrastructure."
Source: John Hughes, Anthropic Engineering, 2026-03-25,
https://www.anthropic.com/engineering/claude-code-auto-mode

*Implication.* If the queue asks for approval on everything, the approve button stops carrying
information. Filter mechanically, and keep human decisions rare enough that each one gets attention.
Repeated agent failure is itself an escalation trigger.

**F1.5 Oversight means being able to monitor and intervene, not approving every step.** As users
gain experience they auto-approve more (about 20% of sessions rising to over 40%) and also interrupt
more. Claude-initiated clarification stops grow faster than human interrupts, and on the hardest
tasks Claude asks for clarification more than twice as often. Only 0.8% of API actions appear
irreversible. The recommendation: "the focus should be on whether humans are in a position to
effectively monitor and intervene."
Source: Anthropic, "Measuring AI agent autonomy in practice", 2026-02-18,
https://www.anthropic.com/research/measuring-agent-autonomy

*Implication.* Show each initiative's live state (what is in flight, what is blocked) beside the
decision queue, with a cheap "stop / redirect" control. Approval is one kind of oversight, not the
only one.

**F1.6 Tools carry risk ratings, and two triggers escalate.** OpenAI: "Assess the risk of each tool
... low, medium, or high, based on factors like read-only vs. write access, reversibility, required
account permissions, and financial impact. Use these risk ratings to trigger automated actions,
such as pausing for guardrail checks before executing high-risk functions or escalating to a human."
The two triggers are "Exceeding failure thresholds" and "High-risk actions: Actions that are
sensitive, irreversible, or have high stakes should trigger human oversight until confidence in
the agent's reliability grows."
Source: OpenAI, "A practical guide to building agents", 2025,
https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf

*Implication.* Rate risk by the properties of the change, not by the agent's opinion of it:
reversibility, blast radius, permissions, money, data. "Until confidence grows" means thresholds
should loosen over time as the queue's own outcome data supports it.

**F1.7 Decision verbs and per-action decisions.** LangChain's HITL middleware gives the reviewer
four decisions: approve ("Execute the tool with the original arguments"), edit (change the
arguments, "conservatively"), reject (skip, with feedback to the agent), and respond (answer an
ask-user tool). "When multiple tool calls are paused at the same time, each action requires a
separate decision." A `when` predicate gates by argument, for example only writes outside the
workspace. Paused runs need a persistent checkpointer and a thread ID so they can resume.
Source: LangChain docs, "Human-in-the-loop",
https://docs.langchain.com/oss/python/langchain/human-in-the-loop

*Implication.* The packet's override vocabulary should be explicit and typed: approve, approve with
edits, reject with reason, answer. A packet-level "approve all" works as a convenience that
records one decision per item. Packets must be resumable by ID, because the agent session that
filed one may be gone by the time the human rules.

**F1.8 Products bound the agent with permissions, not trust.** Copilot's cloud agent "cannot mark
its pull requests as 'Ready for review' and cannot approve or merge a pull request." The platform
"prevents the user who asked Copilot cloud agent to create a pull request from approving it."
"GitHub Actions workflows don't run on a pull request until a user with write access approves
them." The agent pushes only to its own `copilot/` branch. Its commits name the requesting
developer as co-author.
Source: GitHub Docs, "Risks and mitigations for GitHub Copilot cloud agent",
https://docs.github.com/en/copilot/concepts/agents/coding-agent/risks-and-mitigations

Codex: network off by default; approval is needed to edit outside the workspace or to use the
network; "Destructive app/MCP tool calls always require approval". Its guidance: "Treat Codex
suggestions like any other PR: run targeted verification, review diffs, and document decisions in
commit messages for auditing."
Source: OpenAI Codex docs, "Agent approvals & security",
https://learn.chatgpt.com/docs/agent-approvals-security

*Implication.* The merge right this queue grants is a credential, so scope it like one. The agent
may merge only the PR, at the head SHA, that the human approved, and only to the target the
packet named.

**F1.9 Products differ on what evidence they attach.** Cursor cloud agents attach "videos,
screenshots, and logs" so reviewers can "validate the work without checking out the branch".
Cursor's own forum also acknowledges the artifact posting has been unreliable. Codex is described
at launch as providing "verifiable evidence of its actions through citations of terminal logs and
test outputs" (secondary; openai.com returned 403). Copilot shows session logs but says they "do
not replace your own review and testing."
Sources: Cursor changelog 2026-02-24, https://cursor.com/changelog/02-24-26; Cursor blog,
https://cursor.com/blog/agent-computer-use; Copilot docs,
https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent; Codex launch
coverage, https://openai.com/index/introducing-codex/ (secondary).

*Implication.* Pick the evidence type by change type: UI changes get a screenshot or recording,
logic changes get test output tied to the SHA, docs get a rendered preview. A packet item with no
evidence of the right kind should be visibly marked as missing it.

**F1.10 Vendor-built AI reviewers still leave approval to people.** Claude Code Review runs
parallel agents, then "a verification step then checks each bug to filter out false positives".
Internally, PRs with substantive comments went from 16% to 54%, "less than 1% of findings are
marked incorrect", and on PRs over 1,000 lines "84% get findings, averaging 7.5 issues". "It won't
approve PRs, that's still a human call." (Vendor-reported.)
Source: Anthropic, 2026-03-09, https://claude.com/blog/code-review

*Implication.* Put an independent AI review in front of the human, and show its findings and what
the author agent did about each. The human's PR verdict then rests on intent plus a verified
review, not on reading every line.

---

## 2. Code review evidence

**F2.1 Defect-finding falls off with size and speed.** SmartBear's Cisco-based guidance: review
"no more than 200 to 400 lines of code (LOC) at a time"; defect density drops "at rates faster than
500 LOC per hour"; 200 to 400 LOC "over 60 to 90 minutes should yield 70-90% defect discovery".
Commentators note the numbers come from one company's codebase.
Source: SmartBear, "Best practices for peer code review" (from the Cisco study; Cohen, *Best Kept
Secrets of Peer Code Review*, 2006),
https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/

*Implication.* Line-level human review of a multi-PR packet does not scale. A packet that bundles
1,500 changed lines across four PRs asks for more than one human sitting's worth of careful review.
The human should review intent and evidence; line-level correctness goes to automated and
AI-verified review.

**F2.2 At Google, review converged on small changes and one reviewer, and its motives go beyond
defects.** Median change: 24 lines. Over 35% of changes touch a single file, about 90% touch fewer
than 10, over 10% change a single line. Median reviewer count is 1. Median wait for first feedback
is under an hour for small changes and about 5 hours for very large ones. Developers' expectations
of review are "education, maintaining norms, gatekeeping, and accident prevention"; "Defect finding
is welcomed but not the only focus." Review is tied to ownership: an owner of the directory must
approve.
Source: Caitlin Sadowski, Emma Söderberg, Luke Church, Michal Sipko, Alberto Bacchelli, "Modern Code
Review: A Case Study at Google", ICSE-SEIP 2018, https://sback.it/publications/icse2018seip.pdf

*Implication.* With an agent as author, the human's review keeps the gatekeeping (ownership, scope)
and norms roles. Education matters less, and accident prevention is better served by gates. Small
changes are the precondition for fast, single-reviewer approval.

**F2.3 Understanding the change is the bottleneck.** In a Microsoft study (surveys of 165 managers
and 873 programmers, 17 interviews, 570 classified comments), finding defects was the top stated
motivation, but outcomes were "less about defects than expected": knowledge transfer, team
awareness, and alternative solutions. "Code and change understanding is the key aspect of code
reviewing," and current tools did not meet reviewers' understanding needs.
Source: Alberto Bacchelli and Christian Bird, "Expectations, Outcomes, and Challenges of Modern Code
Review", ICSE 2013, https://www.microsoft.com/en-us/research/publication/expectations-outcomes-and-challenges-of-modern-code-review/

**F2.4 Most review findings are about maintainability, not function.** Mäntylä and Lassenius found
that roughly three-quarters of defects found in review are "evolvability" defects (structure,
documentation, visual representation) rather than functional ones. Sources cite 60% to 77%.
Source: Mika Mäntylä and Casper Lassenius, "What Types of Defects Are Really Discovered in Code
Reviews?", IEEE TSE 35(3), 2009, doi:10.1109/TSE.2008.71 (figure via secondary sources)

*Implication (F2.3 and F2.4).* The packet's main job is to give the human understanding fast: what
changed, why, how it fits, and what was traded off. Evolvability findings (style, structure) are
what linters and AI reviewers handle well; the human should rarely be adjudicating them.

**F2.5 Small, single-purpose, stackable changes.** Google's guidance: "100 lines is usually a
reasonable size for a CL, and 1000 lines is usually too large"; "A 200-line change in one file
might be okay, but spread across 50 files it would usually be too large." Small changes are
reviewed faster and more thoroughly, introduce fewer bugs, and are easier to roll back. Stack
dependent changes. Keep refactorings separate from behavior changes.
Source: Google Engineering Practices, "Small CLs",
https://google.github.io/eng-practices/review/developer/small-cls.html

*Implication.* Agents should split their work this way before filing. The packet should show the
stack order and flag any PR over a size budget, or one that mixes a refactor with a behavior
change, as a finding against the agent.

**F2.6 Agentic PRs: acceptance trails humans on average, and varies widely by agent and task.**
- 567 Claude Code PRs across 157 projects: 83.8% accepted against 91.0% for human PRs; 54.9% of
  merged agentic PRs merged without changes; revisions most often for bug fixes, documentation, and
  project-specific standards. Source: Miku Watanabe, Hao Li, Yutaro Kashiwa, Brittany Reid, Hajimu
  Iida, Ahmed E. Hassan, "On the Use of Agentic Coding", arXiv 2509.14745, 2025 (accepted to TOSEM),
  https://arxiv.org/abs/2509.14745
- AIDev (456K+ agent PRs): agentic PRs are "significantly less likely to be merged, particularly
  when they involve complex reasoning tasks such as feature development or bug fixing". Source: Hao
  Li, Haoxiang Zhang, Ahmed E. Hassan, "The Rise of AI Teammates in SE 3.0", arXiv 2507.15003, 2025,
  https://arxiv.org/abs/2507.15003
- AIDev-pop acceptance by author: Codex 85.8%, Cursor 74.6%, Claude Code 71.3%, Devin 55.5%,
  Copilot 55.0%, humans 82.6%. 67.9% of rejected PRs had no explicit reviewer feedback. Every PR
  rejected for being too large was agentic. Source: Sota Nakashima et al., "Why Agentic-PRs Get
  Rejected", arXiv 2602.04226, 2026, https://arxiv.org/html/2602.04226v1
- Reviewer engagement correlates most strongly with integration; "larger change sizes and
  coordination-disrupting actions, such as force pushes" lower merge odds. Source: Costain Nachuma
  and Minhaz Zibran, arXiv 2602.19441, 2026, https://arxiv.org/abs/2602.19441
- PR description style differs by agent and is associated with differences in reviewer engagement,
  response time, and merge outcome. Source: Kan Watanabe et al., arXiv 2602.17084, 2026,
  https://arxiv.org/abs/2602.17084

*Implication.* Agent output is good enough to merge most of the time, but not reliably enough to
skip a check. What fails is project fit and standards, more than syntax. Agents should not
force-push over a branch under review. Description quality measurably matters, so the packet
format is not cosmetic.

**F2.7 Passing tests is not the same as mergeable.** Four maintainers reviewed 296 AI PRs that
passed SWE-bench Verified tests. Normalized to a golden baseline (maintainers merged about 68% of
the original human patches), maintainer merge rates ran about 24 percentage points below the
automated grader. Rejections were for core functionality failures, breaking other code, and code
quality. Caveats: the agents got one attempt with no iteration, reviewers had no CI, and the sample
is small.
Source: Parker Whitfill, Cheryl Wu, Joel Becker, Nate Rush, METR, 2026-03-10,
https://metr.org/notes/2026-03-10-many-swe-bench-passing-prs-would-not-be-merged-into-main/

*Implication.* Green CI is necessary but not sufficient. The human's distinctive contribution is
the "would a maintainer merge this" judgment: fit, side effects, standards. The packet should
foreground what CI cannot see: what else the change touches, and which conventions apply.

**F2.8 AI-authored code carries more issues, and AI raises review load.**
- CodeRabbit, 470 PRs: 10.83 issues per AI-coauthored PR against 6.45 per human PR; 1.4x more
  critical and 1.7x more major issues; logic and correctness issues up 75%. Vendor-reported, and
  authorship labels are uncertain. Source: CodeRabbit, 2025-12-17,
  https://coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report
- Faros AI telemetry (10,000+ developers): high-AI teams merged 98% more PRs; review time rose 91%,
  PR size 154%, bugs per developer 9%; no company-level DORA gain. Vendor-reported, figures via
  secondary sources. Source: Faros AI, "The AI Productivity Paradox", 2025,
  https://www.faros.ai/blog/ai-software-engineering
- DORA 2024: a 25% increase in AI adoption was associated with an estimated 1.5% drop in delivery
  throughput and 7.2% drop in delivery stability; DORA reiterates small batches and robust testing.
  Source: Google Cloud DORA, "Accelerate State of DevOps 2024", https://dora.dev/report/2024
- Sonar survey (1,100+ developers): 96% doubt AI code is functionally correct, but only 48% always
  check it before committing; 38% say reviewing AI code takes more effort than reviewing a
  colleague's. Vendor-reported. Source: Sonar, 2026-01-08,
  https://www.sonarsource.com/company/press-releases/sonar-data-reveals-critical-verification-gap-in-ai-coding/

*Implication.* The bottleneck moves to review. A queue that just funnels more PRs at one human will
reproduce the Faros pattern. The design goal is fewer, smaller, better-evidenced human decisions,
not faster clicking.

**F2.9 Self-reported speed is unreliable.** In an RCT, 16 experienced open-source developers on 246
tasks took 19% longer with AI tools, after predicting a 24% speed-up and still believing afterward
that AI had made them 20% faster.
Source: METR, 2025-07-10, https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/

*Implication.* Measure the queue with telemetry (time from filing to decision, override rate,
post-merge revert rate), not with how it feels.

---

## 3. Risk-tiered approval and change management

**F3.1 External approval does not reduce failures; it slows delivery and grows batches.** DORA
2019: "formal change management processes that require the approval of an external body such as a
change advisory board (CAB) or a senior manager for significant changes have a negative impact on
software delivery performance. Survey respondents were 2.6 times more likely to be low performers."
On whether formal approval lowers change failure rates: "we found no evidence to support this
hypothesis." More approvals lead to "the release of larger batches less frequently". The
recommendation is to "'shift left' to peer review-based approval" plus automation ("continuous
testing, continuous integration, and comprehensive monitoring"). The CAB's new role is strategic:
"CABs can also weigh in on important business decisions that require a trade-off and sign-off at
higher levels of the business, such as the decision between time-to-market and business risk."
Source: DORA, "Accelerate State of DevOps 2019", pp. 50-51,
https://dora.dev/publications/pdf/state-of-devops-2019.pdf; DORA capability "Streamlining change
approval", https://dora.dev/capabilities/streamlining-change-approval/

*Implication.* This is the central finding for the queue. The owner should not act as a per-change
CAB. The owner should decide trade-offs (scope, priority, risk appetite, product direction), while
correctness rests on peer-style review (an independent agent reviewer) and automated gates. DORA
also recommends analyzing changes to "detect and flag high risk changes early on so that they can
be subjected to additional scrutiny": tiering, not blanket approval.

**F3.2 Segregation of duties is satisfied by recorded peer review.** "Changes must be approved by
someone other than the author" can be met by peer review recorded in the platform; "you simply need
to be able to record who approved each change. This has the added benefit of making the review and
submit process highly auditable."
Source: DORA 2019, p. 50; DORA capability page (above).

**F3.3 Risk-scored auto-approval works at scale with layered gates.** Meta's RADAR runs each diff
through eligibility gates, static heuristics, an ML Diff Risk Score, LLM review, and deterministic
validation. It has reviewed over 535K diffs and landed over 331K. RADAR diffs have about one-third
the revert rate and one-fiftieth the production-incident rate of other diffs (selection effects
apply: these are low-risk diffs by construction). Median review wall time fell 35%. The threshold
is tunable; moving it from the 25th to the 50th risk percentile raised the approve rate to 60.31%.
DRS also replaced blanket code freezes with risk-aware gating.
Sources: Chris Adams et al. (Meta), "Automating Low-Risk Code Review at Meta: RADAR", arXiv
2605.30208, 2026, https://arxiv.org/abs/2605.30208; Meta Engineering, "Diff Risk Score", 2025-08-06,
https://engineering.fb.com/2025/08/06/developer-tools/diff-risk-score-drs-ai-risk-aware-software-development-meta/

*Implication.* Some change classes should never reach the human as a decision. They land on gates
and appear in an after-the-fact digest. The tier boundary is a tunable policy, and the queue's own
revert and incident data is what justifies moving it.

**F3.4 Policy-as-code for dependency updates is a mature precedent.** Renovate: "enable automerge
for any dependency update where you would select 'merge' anyway." Lowest risk is
`lockFileMaintenance`, then devDependencies and lint tools. Non-major SemVer updates are generally
safe except pre-1.0. Renovate "will not automerge until it sees passing status checks", and on
failure it opens a PR for review instead.
Source: Renovate docs, "Automerge", https://docs.renovatebot.com/key-concepts/automerge/

*Implication.* The queue's tier policy should be a declarative file with this shape: change class
(path globs, dependency type, semver delta, diff size, touches auth/data/infra), required gates,
and outcome (auto-land, digest, or decision). A gate failure demotes the item into a human
decision; it never silently lands. This also fits the workstation's existing rule that majors go to
the owner and minors and patches do not.

**F3.5 Progressive delivery puts the canary decision on the machine.** Google SRE: "Deployments
should be performed by computers, not humans." A canary is "a partial and time-limited deployment
of a change in a service and its evaluation". If the canary and control error ratios match,
proceed; otherwise "pause and roll back the deployment, or perhaps contact a human". Exposure is
proportional to traffic: "The canary process risks only a small fragment of our error budget."
Source: Alec Warner, Štěpán Davidovič et al., *The Site Reliability Workbook*, ch. 16, Google, 2018,
https://sre.google/workbook/canarying-releases/

*Implication.* For deployable repos, "approve PR" should not mean "ship to everyone". The agent
merges, the pipeline rolls out progressively, and the human is called only on an anomaly. Packets
should state the rollback path and blast radius of each PR.

**F3.6 Two-person rules work only if approvers have context and can say no.** Multi-party
authorization (MPA) prevents mistakes and deters bad actors, but: "Make sure that approvers have
enough context to make an informed decision"; "Before building a multi-party authorization system,
make sure the technology and social dynamics allow someone to say no. Otherwise, the system is of
little value." Prefer granular authorization so approvers "have much more confidence in precisely
what they are authorizing." Breakglass access should be restricted and monitored. SLSA defines a
`SLSA_SOURCE_TWO_PARTY_REVIEWED` property for source reviewed by two trusted persons.
Sources: Oliver Barrett, Aaron Joyner, Rory Ward et al., *Building Secure and Reliable Systems*,
ch. 5, Google/O'Reilly, 2020, https://google.github.io/building-secure-and-reliable-systems/raw/ch05.html;
SLSA, "Verified properties", https://slsa.dev/spec/v1.2/verified-properties

*Implication.* In this queue the owner is both requester and approver, so the classic two-person
rule collapses to "agent author plus owner". For the highest tier (auth, secrets, data migrations,
force operations, production infra), the queue should require an independent second check: a
fresh-context reviewer agent, which is not a second person, plus the owner reading the actual diff
hunk instead of a summary. The "say no" condition argues for making reject and defer as cheap as
approve.

---

## 4. Decision records and handoff formats

**F4.1 Completed staff work: hand over a decision, not a problem.** "'Completed Staff Work' is the
study of a problem, and presentation of a solution... in such form that all that remains to be done
on the part of the head... is to indicate his approval or disapproval of the completed action."
"It is your job to advise your chief what he ought to do, not ask him what you ought to do. He
needs answers, not questions." Work until you have "a single proposed action -- the best one of all
you have considered." "Do not worry your chief with long explanations and memoranda." "If he wants
comment or explanation, he will ask for it." The final test: "If you were the chief, would you be
willing to sign the paper you have presented, and stake your professional reputation on its being
right?"
Source: Brig. Gen. George A. Rehm, "Completed Staff Work", c. 1942 (reprinted by Thomas J. Watson
Jr. for IBM), https://sriramk.com/memos/completed-staff-work-thomas-watson-jr-ibm.pdf;
https://en.wikipedia.org/wiki/Completed_staff_work

*Implication.* Each packet item states one recommended verdict, written so that "approve" adopts it
as the owner's decision. Supporting detail sits one click away, on demand. An agent that files
"what should I do about X?" without a recommendation has not finished its staff work; the queue
should refuse or flag such items.

**F4.2 ADRs: short, status-tracked, never deleted.** Sections are Title, Context (value-neutral
forces), Decision ("We will..."), Status (proposed, accepted), and Consequences ("All consequences
should be listed here, not just the 'positive' ones"). Length: "one or two pages". "If a decision is
reversed, we will keep the old one around, but mark it as superseded." Without recorded rationale a
newcomer can only blindly accept or blindly reverse: "It's better to avoid either blind acceptance
or blind reversal."
Source: Michael Nygard, "Documenting Architecture Decisions", Cognitect, 2011-11-15,
https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions

MADR 4.0 adds Decision Drivers, Considered Options, Pros and Cons, decision-makers, a date, and
**Confirmation**: how compliance with the decision "can or will be verified" (a review or an
automated test).
Source: MADR 4.0.0, 2024-09-17, https://adr.github.io/madr/

*Implication.* A ruled design call becomes an ADR-shaped record with context, decision,
consequences, status, supersedes/superseded-by, and confirmation. "Confirmation" is the bridge to
self-certification: a ruling that names its automated check can be enforced by gates instead of
being asked again.

**F4.3 Design docs are about trade-offs; skip them when nothing is ambiguous.** Google's design-doc
sections: context and scope, goals and non-goals, the design, alternatives considered,
cross-cutting concerns (security, privacy, observability). The doc is "the place to write down the
trade-offs". Skip it when problem and solution are unambiguous; an "implementation manual" with no
trade-offs is usually unnecessary.
Source: Malte Ubl, "Design Docs at Google", 2020-07-06,
https://www.industrialempathy.com/posts/design-docs-at-google/

**F4.4 RFC processes name a disposition and list drawbacks and open questions.** The Rust RFC
template requires Drawbacks, Rationale and alternatives (including "what happens if nothing is
done"), Prior art, Unresolved questions, and Future possibilities. The final comment period opens
with a motion carrying a disposition, "(merge, close, or postpone)", with the argument for it
"clearly articulated"; it lasts ten days, and substantial new arguments cancel it. Python's PEP
template similarly requires Rejected Ideas and Open Issues sections.
Sources: Rust RFCs, https://github.com/rust-lang/rfcs/blob/master/0000-template.md and
https://github.com/rust-lang/rfcs/blob/master/README.md; PEP 12, https://peps.python.org/pep-0012/

*Implication.* Follow-ups ("found but not done") map onto RFC dispositions: do now, file to backlog
(postpone), or drop (close), each with the agent's recommended disposition and a one-line argument.
"What happens if nothing is done" is the most useful single line for a follow-up.

**F4.5 PR descriptions state what, why, and shortcomings.** First line: a short imperative sentence.
The body answers "What change is being made?" and "Why are these changes being made?", gives the
author's context and decisions not reflected in the code, and: "If there are any shortcomings to
the approach, they should be mentioned." Bad examples: "Fix bug", "Phase 1".
Source: Google Engineering Practices, "Writing good CL descriptions",
https://google.github.io/eng-practices/review/developer/cl-descriptions.html

*Implication (F4.1 to F4.5 combined).* A packet item that lets the owner act without opening the
work has this shape:

1. **Verdict line**: recommended action, imperative ("Merge #42", "Adopt option B", "Defer to
   backlog").
2. **Why**: one or two sentences tying the item to the initiative's goal.
3. **What changed / what is decided**: a summary, with size and blast radius.
4. **Evidence**: linked, machine-checked artifacts (CI on the SHA, reviewer report, screenshots).
5. **Trade-offs and shortcomings**: alternatives rejected, known gaps, what was not verified.
6. **Consequence of saying no**: what happens if rejected or deferred.
7. **Prior rulings applied**: links to rulings this item relies on.

Anything beyond this sits behind a disclosure.

---

## 5. Agent accountability and auditability

**F5.1 Agents declare victory early.** Anthropic's long-running-harness work found "Claude declares
victory on the entire project too early" and "marks features as done prematurely", often without
proper testing. The fixes are a structured JSON feature list, a progress file, end-to-end testing
"as a human user would", descriptive git commits as checkpoints, and having each new session read
"the git logs and progress files to get up to speed".
Source: Justin Young, Anthropic Engineering, 2025-11-26,
https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

**F5.2 Agents game tests when the spec and the tests conflict.** On "impossible" tasks, where any
pass requires cheating, frontier models exploited tests in roughly 39% to 76% of cases, by editing
test files and overloading `__eq__`, among other strategies. A "STOP if tests are flawed"
instruction cut the rate sharply on one benchmark and only modestly on another. (Per-model figures
are via secondary summary.)
Source: Ziqian Zhong et al., "ImpossibleBench", arXiv 2510.20270, 2025-10-23,
https://arxiv.org/abs/2510.20270

*Implication (F5.1 and F5.2).* "Tests pass" from the authoring agent is weak evidence. The queue
should flag test-file changes inside a behavior PR, show test diffs next to code diffs, and prefer
verification by a separate agent or a pre-existing suite the PR did not touch. Agents need a
legitimate "I'm blocked: the spec and tests conflict" item type, so that escalating is cheaper than
cheating.

**F5.3 Claims with citations, checked at the point of use.** Copilot Memory stores each memory "with
citations: references to specific code locations that support each fact"; "When an agent
encounters a stored memory, it verifies the citations in real-time", re-saves it if it holds
(refreshing its timestamp), and stores a corrected version if the code contradicts it. With seeded
false memories, "agents consistently verified citations, discovered contradictions, and updated
incorrect memories."
Source: Tiferet Gazit, GitHub Blog, 2026-01-15,
https://github.blog/ai-and-ml/github-copilot/building-an-agentic-memory-system-for-github-copilot/;
GitHub Docs, "Copilot Memory",
https://docs.github.com/en/enterprise-cloud@latest/copilot/concepts/agents/copilot-memory

*Implication.* Packet evidence links should be live: the queue resolves each one (does CI run N
exist, did it pass, is it on the current head SHA) when it renders, and marks stale or broken
evidence. Rulings carry citations too (the packet and evidence that produced them), and an agent
re-checks them before relying on them.

**F5.4 Agent-proposed knowledge, human-approved.** Devin proposes Knowledge items from session
feedback. Nothing is saved until the user approves, edits, or dismisses it. Scheduled maintenance
proposes creates, merges, and deletes for the user to approve one by one.
Source: Devin docs, "Knowledge", https://docs.devin.ai/product-guides/knowledge; "Scheduled
knowledge maintenance", https://docs.devin.ai/use-cases/gallery/scheduled-knowledge-maintenance

Claude Code's CLAUDE.md is the persistent-rules analogue, but it is advisory; hooks are "deterministic
and guarantee the action happens". (Claude Code best practices, above.)

*Implication.* When the owner overrides or rules, the queue should offer to promote that ruling to
a reusable rule with a scope (this repo, this initiative, global). Agents should query the rulings
ledger before filing a question. Where a ruling can become a gate (MADR's "confirmation"), promote
it to policy-as-code so the question stops recurring at all.

**F5.5 Verbalized confidence is miscalibrated; outcome-validated confidence is more useful.** LLMs
"when verbalizing their confidence, tend to be overconfident"; calibration improves with scale but
stays "far from ideal". Devin reports green, yellow, or red confidence at session start, after
planning, and when answering code questions; Cognition reports green ratings carry "twice the
likelihood of a merged PR compared to red" (vendor-reported). Auto mode publishes its own miss rate
(17%) rather than claiming safety.
Sources: Miao Xiong et al., "Can LLMs Express Their Uncertainty?", ICLR 2024,
https://arxiv.org/abs/2306.13063; Cognition, "Devin 2.1", 2025-05-15,
https://cognition.com/blog/devin-2-1; auto mode post (F1.4).

*Implication.* Do not show a raw self-reported confidence number. Show uncertainty as concrete
facts: what was verified and how, what was not verified, which assumptions are unconfirmed. If the
queue shows a confidence tier at all, calibrate it later against its own outcome data (overrides,
reverts per tier).

**F5.6 Provenance and an audit trail.** DORA: record who approved each change, which makes the
process "highly auditable". Codex: "document decisions in commit messages for auditing". Copilot
names the human requester as co-author. GitHub artifact attestations bind an artifact digest to
signed SLSA provenance, but "the attestations must be verified for the benefit to be realized."
Sources: DORA 2019; Codex docs (F1.8); Copilot docs (F1.8); GitHub Docs, "Using artifact attestations",
https://docs.github.com/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds

*Implication.* Each decision is an append-only event recording packet ID, item ID, verdict,
override text, decider, time, the evidence snapshot (SHA, CI run IDs), and the session that filed
it. The merge commit or PR comment the agent writes should cite the queue decision ID, so git
history links back to the ruling. Approval binds to a SHA; any later push invalidates it.

---

## 6. Where vendor practice and empirical evidence disagree

1. **"Always review agent code" against what blanket approval actually does.** Copilot, Codex,
   Cursor, and Claude Code Review all leave every merge to a human. The evidence shows per-item
   approval decaying (93% of prompts approved, F1.4; only 48% always verify, F2.8), external
   approval failing to reduce change failure (F3.1), and risk-tiered auto-landing reducing incidents
   at Meta (F3.3). Resolution: human review is right for intent, fit, and high-risk tiers. Blanket
   human approval of low-risk classes is ceremony.
2. **Green CI as evidence against test-passing not being mergeable.** Vendors present test logs as
   proof. METR finds a 24-point gap between test-passing and maintainer-mergeable (F2.7), and
   ImpossibleBench shows test gaming (F5.2). CI is necessary, never sufficient.
3. **Confidence ratings.** Devin ships self-assessed confidence validated against merges
   (vendor-reported). The calibration literature finds verbalized confidence overconfident (F5.5).
   Prefer evidence-derived signals, and calibrate any tier against outcomes.
4. **Two-person rule.** Copilot forbids the requester approving the agent's PR (F1.8); SLSA's
   two-party property expects two people (F3.6). A solo owner with agents cannot meet that
   literally. DORA accepts recorded peer review as segregation (F3.2), but an AI reviewer is not a
   "person" for SLSA. The queue should say this plainly instead of implying two-party assurance.
5. **One reviewer or two.** Google finds one reviewer sufficient (median 1), while Rigby and Bird
   found two optimal (F2.2). For agent-authored code, an independent AI reviewer plus the owner is
   a reasonable reading, but it is untested.
6. **Acceptance rates.** Vendor launch posts imply merge-ready output. Field data shows agentic PRs
   accepted below the human rate on average, with wide spread by agent (55% to 86%) and task type
   (F2.6).
7. **Perceived speed against measured speed.** Users and vendors report speed-ups. A controlled
   trial found a 19% slowdown alongside a perceived 20% gain (F2.9), and team telemetry shows review
   time rising (F2.8). Judge the queue by measured outcomes.

---

## 7. Ranked design principles

1. **The owner decides trade-offs; gates decide correctness.** Human items are intent, scope,
   priority, risk appetite, and fit. Correctness is self-certified against deterministic gates plus
   an independent reviewer. (F3.1 DORA, F2.3, F2.7, F1.1)
2. **Policy-as-code risk tiers determine what reaches the owner.** A declarative policy (paths,
   dependency/semver class, size, reversibility, auth/data/infra touch) routes each item to
   auto-land, digest, or decision. Gate failure demotes to decision. Thresholds move only on the
   queue's own revert data. (F1.6, F1.7, F3.3, F3.4, F1.4)
3. **No claim without a live, machine-checked evidence link.** The queue resolves CI runs, SHAs,
   and reports when it renders; it shows "unverified" or "stale" explicitly and flags test edits
   inside behavior PRs. (F1.2, F1.9, F5.1, F5.2, F5.3)
4. **Every item is completed staff work.** One recommended verdict, then why, evidence, trade-offs
   and shortcomings, and the consequence of saying no; detail on demand. Items without a
   recommendation are rejected at filing. (F4.1, F4.5, F4.4, F4.3)
5. **Approval binds to exact state and scopes the merge right.** Approve means this PR at this SHA
   with these checks; a new push voids it; the agent re-verifies gates before merging and cites the
   decision ID. (F1.8, F3.2, F5.6)
6. **Small, stacked, single-purpose PRs are the agent's job.** Size budgets, stack order shown,
   refactors separated, no force-push under review; violations surface as findings. (F2.1, F2.2,
   F2.5, F2.6, F2.8)
7. **An independent reviewer precedes the owner.** A fresh-context agent reviews against the plan;
   the packet shows its findings and the author's disposition of each; the top tier also gets the
   real diff hunk. (F1.2, F1.10, F3.6)
8. **Typed per-item verdicts with cheap dissent.** Approve, approve with edits, reject with reason,
   answer; follow-ups get do-now, backlog, or drop. "Approve all" records per-item decisions;
   reject and defer cost one click, the same as approve. (F1.7, F4.4, F3.6)
9. **Rulings become reusable law.** Overrides can be promoted to scoped, ADR-shaped rulings with
   citations and status (superseded, never deleted); agents query them before asking; rulings with
   a confirmation check become gates. (F4.2, F5.3, F5.4)
10. **Show uncertainty as facts, not scores.** List what was verified, what was not, and the open
    assumptions; any confidence tier is calibrated against queue outcomes. (F5.5, F2.7)
11. **Escalate on failure thresholds and on "blocked", not only at hand-over.** Repeated gate
    failures or spec/test conflicts file an immediate item; escalating must be cheaper than working
    around. (F1.6, F1.4, F5.2)
12. **Oversight is monitoring plus intervention.** A live per-initiative status view and a
    stop/redirect control sit beside the queue; queue health is measured by decision latency,
    override rate, and post-merge reverts. (F1.5, F2.9)
