# Community practice for a solo developer's user-level Claude Code setup

Research date: 2026-11-20. Claude Code is at v2.1.330. Every source below was opened in this session. Docs quotes come from the pages at `https://code.claude.com/docs/en/<page>.md`, which were fetched on 2026-11-20.

Docs pages read: best-practices, memory, skills, sub-agents, hooks-guide, plugins, plugin-marketplaces, permission-modes, mcp, settings, goal, agent-view, features-overview.

Note: the April 2025 engineering post at `anthropic.com/engineering/claude-code-best-practices` now returns a 308 redirect to `code.claude.com/docs/en/best-practices`. The old post has been absorbed into the docs, so community write-ups that quote it may quote text that no longer exists.

## 1. Short answer: the ten recommendations with the strongest agreement

1. Keep the user-level CLAUDE.md short (under about 200 lines) and limit it to what Claude cannot find by reading the repo. Add a line only after Claude gets something wrong more than once. **Matches Anthropic's docs.**
2. Move multi-step procedures into skills and area-specific guidance into path-scoped rules. `@imports` organize a file but do not cut its context cost. **Matches Anthropic's docs.**
3. Write a skill when you keep pasting the same playbook. Write the description as a trigger, put the gotchas in it, and leave out what Claude already knows. **Matches Anthropic's docs** (the gotchas emphasis goes beyond the docs).
4. Keep the set of skills, plugins, and MCP servers small, because each one costs context every session. Measure what you have before adding more. **Matches Anthropic's docs.**
5. Give Claude a check it can run, and get review from a fresh context (`/code-review`, a second session, or a review subagent) rather than from the session that wrote the code. **Matches Anthropic's docs.**
6. Use the simple loop: plan or interview into a spec, build in a fresh session, review, then open a PR. Use worktrees for parallel sessions. Heavy multi-stage frameworks are widely reported as overkill for small and medium work. **Matches Anthropic's docs**, and the critique of frameworks goes beyond them.
7. Use hooks only for rules with zero exceptions, and keep few of them. The common ones are a formatter, blocks on dangerous commands, and a notification. Hooks are guardrails, not a security boundary. **Matches Anthropic's docs.**
8. Run auto mode for unattended interactive work, and put every "never" rule in a deny rule or a hook. Use dontAsk for scripts and CI, and bypassPermissions only in a container. **Matches Anthropic's docs.**
9. Prefer a CLI to an MCP server when the system has one, and turn off servers you do not use. **Matches Anthropic's docs**, although tool search has weakened the context-cost argument.
10. Prune on a schedule. Delete stale CLAUDE.md lines, and drop habits written for older models such as ALL CAPS, "think hard", "keep going", and architecture descriptions. **Matches Anthropic's docs.**

No source with standing recommends a custom multi-stage process (planner, executor, and reviewer roles with their own documents and gates) over the simple loop for a solo developer's everyday work. The closest is Anthropic's own planner, generator, and evaluator harness. Its author reports removing pieces of it as models improved (topic 7).

## 2. By topic

### Topic 1. User-level CLAUDE.md: contents, length, and splitting

**Recommendation.** Keep it short and limited to personal preferences and facts Claude cannot discover for itself. Grow it from mistakes: add a line after a correction, and do not write it up front. Move procedures to skills, area-specific guidance to path-scoped rules, and per-language rules to `~/.claude/rules/`. Use pointers, not copied content. Do not describe architecture or file layout.

**Sources.**
- Boris Cherny (creator of Claude Code), "How I use Claude Code" thread, 2026-01-02, https://threadreaderapp.com/thread/2007179832300581177. He calls his setup "surprisingly vanilla" and adds a line to CLAUDE.md after each mistake.
- Sergio De Simone, "Inside the Development Workflow of Claude Code's Creator", InfoQ, 2026-01-10, https://www.infoq.com/news/2026/01/claude-code-creator-workflow. It reports Cherny's CLAUDE.md at about 2.5k tokens.
- Boris Cherny, team tips thread, 2026-01-31, https://threadreaderapp.com/thread/2017742741636321619: "After every correction, ask Claude to update CLAUDE.md". One engineer keeps a notes directory per task, and CLAUDE.md points at it.
- Michael Segner (Anthropic), "Steering Claude Code: when to use CLAUDE.md, skills, hooks, and subagents", 2026-06-18, https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more: "Keep CLAUDE.md under 200 lines, give it an owner, and review changes to it like code". It warns that "every team appends its own instructions and nothing gets deleted" and that "An unscoped rule is mechanically identical to putting the content in CLAUDE.md". It also notes "All file-based methods have a user-level counterpart".
- Kyle (HumanLayer), "Writing a good CLAUDE.md", 2025-11-25, https://www.humanlayer.dev/blog/writing-a-good-claude-md. It recommends under 300 lines; their root file is under 60. It says models follow roughly 150 to 200 instructions and the system prompt already uses about 50. It advises "Prefer pointers to copies" and not using the model as a linter.
- Trail of Bits, `claude-code-config` README, repo last pushed 2026-08-24, 2,148 stars, https://github.com/trailofbits/claude-code-config. It describes a global CLAUDE.md of about 100 lines plus per-language path-scoped rules in `~/.claude/rules/`, and notes that `@path` imports "don't reduce context".
- ykdojo, "45+ Claude Code Tips" README, repo last pushed 2026-09-25, 10,363 stars, https://github.com/ykdojo/claude-code-tips. Tip 28: "You can just start with no CLAUDE.md at all", and review it periodically "because they can get outdated over time".
- Shrivu Shankar, "How I Use Every Claude Code Feature", 2025-11-02, https://blog.sshh.io/p/how-i-use-every-claude-code-feature. This is an outlier: a 13KB CLAUDE.md for a team monorepo, not a personal file.

**Agreement.** Strong. Every source says keep it short and grow it from mistakes. The length targets vary (60, 100, 200, 300 lines), but 200 is the most common ceiling, and both Anthropic staff and the docs use it.

**Against the docs.** Matches.
- memory.md: "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." It also says imports "help you organize a long file but don't reduce its context cost."
- memory.md: "If an entry is a multi-step procedure or only matters for one part of the codebase, move it to a skill or a path-scoped rule".
- memory.md, on scope: `~/.claude/CLAUDE.md` holds "Personal preferences for all projects", and "Personal rules in `~/.claude/rules/` apply to every project on your machine." On user against project rules: "Neither set overrides the other... keep the two consistent."
- best-practices: "Only write down what Claude can't find by reading the repo, or what it would otherwise spend time rediscovering every session."
- features-overview: "Claude gets a convention or command wrong twice → CLAUDE.md". It also says "You don't need to configure everything up front."

**One conflict.** HumanLayer advises against generating the file with `/init`. The docs suggest running `/init` and then cutting what is not needed. This is a small, contested point.

**One gap the docs do not mention.** Trail of Bits says "path-scoped rules are not automatically re-injected after auto-compaction". I did not find this stated or refuted in memory.md, so it is unverified.

### Topic 2. Skills

**Recommendation.** Write a skill when you have repeated the same playbook a few times, or when a CLAUDE.md section has grown into a procedure. A skill is a folder, not just a markdown file, and progressive disclosure moves reference material into side files. Write the description as a trigger ("use when..."), not a summary. Treat the Gotchas section as the most valuable content. Do not restate what Claude already knows, and do not railroad it with step lists. Keep few skills, because each listed skill costs context on every turn. A skill you always invoke by hand can have model invocation turned off. Test a skill in a fresh session with and without it. Verification skills give the biggest measured gain.

**Sources.**
- Thariq Shihipar (Anthropic, Claude Code), "Lessons from building Claude Code: How we use skills", 2026-06-03, https://claude.dev/blog/lessons-from-building-claude-code-how-we-use-skills/ (the claude.com URL redirects here). Quotes:
  - "the description field is not a summary, it's a description of when to trigger this skill"
  - "The highest-signal content in any skill is the Gotchas section."
  - "A skill that restates what Claude would do by default adds context without adding value."
  - "Give Claude the information it needs, but give it the flexibility to adapt to the situation."
  - "Most of our best skills began as a few lines and a single gotcha"
  - "Verification skills have had the most measurable impact on Claude's output quality internally."
  - Anthropic uses a PreToolUse hook to log skill usage and find skills that are "undertriggering". It also notes "every skill that is checked in also adds a little bit to the context of the model."
- Waldek Mastykarz (Microsoft), "Stop skillmaxxing, save your tokens", 2026-06-10, https://developer.microsoft.com/blog/stop-skillmaxxing-save-your-tokens/. Quotes: "The best skill setup is the smallest one that produces lift" and "Three well-scoped skills that the agent invokes correctly will outperform 50 that fight for context." It gives an illustrative estimate of 50 skills at about 10,000 tokens, which is not a measurement. It recommends `disable-model-invocation: true` for skills you only call by hand.
- Boris Cherny, team tips thread, 2026-01-31 (cited above): if you do something more than once a day, make it a skill or command and commit it.
- Trail of Bits README (cited above): keep SKILL.md under 2,000 words and move detail to `references/`.
- Shrivu Shankar (cited above): a "long list of complex, custom slash commands" is an "anti-pattern".

**Agreement.** Strong on keeping skills few and focused, on the description as trigger, and on progressive disclosure. Medium on the exact size cap. The docs say under 500 lines and Trail of Bits says under 2,000 words, which are roughly compatible.

**Against the docs.** Matches, with the gotchas emphasis going beyond them.
- skills.md: "Keep SKILL.md under 500 lines. Move detailed reference material to separate files."
- skills.md: description plus `when_to_use` is "truncated at 1,536 characters". The listing "budget scales at 1% of the model's context window. When the listing overflows, Claude Code drops descriptions starting with the skills you invoke least".
- skills.md: "Every skill in the skill listing adds to your context on every turn... Run `/skill-doctor`" (v2.1.252 or later).
- skills.md, on testing: "run each one in a fresh session with the skill available and again with it turned off... A fresh session matters because leftover context from authoring the skill will mask gaps". `claude plugin eval` covers plugin skills, and the skill-creator plugin covers single skills.
- features-overview: "paste the same playbook... for the third time → skill".
- On personal against plugin skills: skills.md puts personal skills at `~/.claude/skills/<skill-name>/SKILL.md`, covering "All your projects on this machine, but not Cowork or cloud sessions". A personal skill overrides a project skill of the same name, and plugin skills are namespaced.

**Stale.** "Custom slash commands" as a separate feature. skills.md: "Custom commands have been merged into skills." Advice that treats `.claude/commands` as distinct, including Cherny's January 2026 thread, predates the merge.

### Topic 3. Subagents

**Recommendation.** Use few custom subagents. Use them for side tasks that would flood the main session with output, for tool-restricted work, and for independent review. Do not delegate just to get a better answer. Anthropic staff use a small number: Cherny names code-simplifier and verify-app. Shankar finds custom subagents brittle and prefers letting the main agent clone itself with full context.

**Sources.**
- Boris Cherny, 2026-01-02 thread (cited above): code-simplifier and verify-app subagents. The 2026-01-31 thread: "use subagents" for more compute on hard problems.
- Thariq Shihipar, "Using Claude Code: session management and 1M context", 2026-04-15, https://claude.com/blog/using-claude-code-session-management-and-1m-context. Use a subagent when the work produces lots of intermediate output, with the test "will I need this tool output again, or just the conclusion?"
- Shrivu Shankar (cited above): "Custom subagents are a brittle solution". He prefers the Master-Clone pattern.

**Agreement.** Medium. Everyone agrees on subagents for noisy output and review. Practitioners disagree on whether to define many custom agents.

**Against the docs.** Matches.
- sub-agents.md, "Choose between subagents and main conversation": use the main conversation for back-and-forth, shared context, quick changes, and when "Latency matters". Use subagents for verbose output, tool restrictions, and self-contained work. It adds "Consider Skills instead when you want reusable prompts or workflows that run in the main conversation context".
- best-practices, "What you can stop doing": "Delegate to a subagent for a better answer: Handing the same task to a subagent doesn't make the answer any better. A fresh reviewer does help, because it hasn't seen your reasoning". Also "Use subagents to protect your context window: Running out of context is rarely the problem anymore."
- features-overview: "A side task floods your conversation → subagent".
- User scope lives in `~/.claude/agents/`. Plugin subagents ignore `hooks`, `mcpServers`, and `permissionMode`.

**Stale.** "Use subagents to save context" is listed by the docs as advice to stop. Shihipar's April 2026 test (do I need the output or only the conclusion?) is the current framing.

### Topic 4. Hooks

**Recommendation.** Keep a handful. The ones practitioners keep are:
- a PostToolUse formatter
- PreToolUse blocks on `rm -rf`, force push, push to main, and edits to protected paths
- a Stop hook or check that enforces done for long runs
- a notification hook
- on-demand hooks that a skill turns on for one session

Blocking at commit or submit time beats blocking at each write. Hooks are guardrails, not a security boundary.

**Sources.**
- Boris Cherny, 2026-01-02 thread (cited above): a PostToolUse formatter hook, and an agent Stop hook for long runs. The 2026-01-31 thread: a permission hook routed to Opus.
- Trail of Bits README (cited above): hooks block `rm -rf` and push to main. "Hooks are not a security boundary... Guardrails, not walls."
- Shrivu Shankar (cited above): block-at-submit hooks rather than block-at-write.
- Thariq Shihipar, skills post (cited above): "Skills can include hooks that are only activated when the skill is called". Examples are `/careful` (blocks `rm -rf`, `DROP TABLE`, force-push) and `/freeze` (blocks edits outside one directory).
- Michael Segner (cited above): "Use hooks for anything that should happen deterministically".

**Agreement.** Strong on a small set and on the formatter and dangerous-command blocks. No source gives a count beyond "a few".

**Against the docs.** Matches.
- best-practices: "a hook is for a rule with *zero* exceptions". Also: "keep the enforced set small... If you ever find yourself at forty of them, most are probably preferences that Claude could have weighed on its own."
- hooks-guide: hooks "give you deterministic control: certain actions always happen rather than relying on the LLM to choose to run them". Its examples are notify, auto-format, block protected files, re-inject context after compaction, audit config changes, and auto-approve.
- best-practices on auto mode: "your 'never' rules belong in deny rules or hooks."

**Goes beyond the docs.** The on-demand, skill-scoped hook pattern (Shihipar), and Trail of Bits' explicit "not a security boundary" framing.

### Topic 5. Permissions and modes for unattended work

**Recommendation.**
- Interactive and unattended local work: run auto mode, with deny rules for credentials and anything that must never happen, and the sandbox for OS-level limits.
- `-p` scripts and CI: use dontAsk with an explicit allowlist.
- bypassPermissions or `--dangerously-skip-permissions`: only in a container or VM.
- Tune auto mode with `autoMode.environment` and `allow`, in user settings.

**Sources.**
- John Hughes (Anthropic), "How we built Claude Code auto mode: a safer way to skip permissions", 2026-03-25, https://anthropic.com/engineering/claude-code-auto-mode. Quotes: "Sandboxing is safe but high-maintenance". On the classifier: "The 17% false-negative rate on real overeager actions is the honest number." Auto mode "is not a drop-in replacement for careful human review on high-stakes infrastructure." When auto mode starts, broad allow rules that permit arbitrary code execution (blanket shell, wildcarded interpreters, package-manager run commands) are dropped, and narrow rules carry over.
- Boris Cherny, 2026-01-02 thread (cited above): he does not use `--dangerously-skip-permissions`. He pre-allows safe commands through `/permissions`, and uses dontAsk or skip only in a sandbox for long runs.
- Trail of Bits README (cited above): bypassPermissions plus `/sandbox` plus deny rules on credentials, with devcontainers or droplets for isolation.
- ykdojo README, Tip 19 (cited above): isolated environments, such as a container, for `--dangerously-skip-permissions` sessions.
- shanraisshan/claude-code-best-practice README (aggregator, 69,276 stars, pushed 2026-11-21, https://github.com/shanraisshan/claude-code-best-practice) attributes to Cherny (2026-04-16) the tip to use auto mode instead of dangerously-skip-permissions. I did not open Cherny's original post, so this is second-hand.

**Agreement.** Strong that skip-permissions belongs only in isolation. Medium on auto mode, which is newer, and Trail of Bits still runs bypass inside a sandbox.

**Against the docs.** Matches.
- best-practices: "`bypassPermissions`: approves everything your deny and ask rules don't cover, which only makes sense in a disposable container."
- best-practices: "Auto mode is a classifier model judging each action rather than a hard rule... your 'never' rules belong in deny rules or hooks." Also: "`deny` rules hold in every permission mode, including auto and `bypassPermissions`".
- best-practices: "The `autoMode` block also has to live in `~/.claude/settings.json` rather than the project, because the classifier ignores `autoMode` in project settings."
- permission-modes.md: dontAsk is for "Locked-down CI and scripts". Claude Code "auto-denies every tool call that would otherwise prompt you". Cloud sessions ignore `defaultMode: "dontAsk"`.
- best-practices on unattended runs: answer five questions first (when is it done, what checks it, what may it touch, when should it stop, who signs off). It names `--bare`, `--permission-mode dontAsk`, and `--max-turns`.

**Partly stale.** Trail of Bits' pattern of bypassPermissions plus sandbox predates auto mode becoming the default for interactive sessions. The docs now say "Interactive terminal and VS Code sessions start in auto mode."

### Topic 6. Plugins, marketplaces, and `~/.claude` in dotfiles

**Recommendation.**
- For one person on one machine, plain files in `~/.claude` (skills, agents, hooks, rules) are enough.
- Package as a plugin when a second machine, repo, or person needs the same setup, or when you want versioned releases.
- Install third-party plugins sparingly, since each one enabled adds to every session.
- Version the reusable parts of `~/.claude` in a dotfiles repo, through symlinks or Stow: `CLAUDE.md`, `settings.json`, `skills/`, `agents/`, `rules/`, and hook scripts.
- Never track credentials, history, per-project state, caches, or session data.

**Sources.**
- Thariq Shihipar, skills post (cited above): "For smaller teams working across relatively few repos, checking your skills into repos works well... As you scale, an internal plugin marketplace allows you to distribute skills and let your team decide which ones to install".
- Trail of Bits README (cited above): recommends the Superpowers and Compound Engineering plugins.
- jinyeow/dotfiles wiki, "Claude Code", last edited 2026-08-26, https://github.com/jinyeow/dotfiles/wiki/Claude-Code.
  - Tracked through symlinks: `settings.json`, `CLAUDE.md`, `AGENTS.md`, hook scripts, `skills/<name>/`, `agents/`, and `output-styles/`.
  - Excluded: `.credentials.json`, `history.jsonl`, `mcp-needs-auth-cache.json`, `stats-cache.json`, `projects/`, and session data.
  - Caveat: because live files are links, Claude Code writing `settings.json` or appending to `CLAUDE.md` changes the repo file directly. It suggests an untracked `settings.local.json` for machine-specific pins.

**Agreement.** Strong on the track-and-exclude split, across several personal dotfiles repos from the search, though I opened only one. Weak on plugin packaging for a solo user: it is mostly recommended for sharing, not for one machine.

**Against the docs.** Matches.
- plugins.md: "Skills, subagents, hooks, and MCP servers all work on their own, without a plugin. A skill you save in `~/.claude/skills/`... is available in every project". Also: "Use a plugin when you want several skills, subagents, hooks, or MCP servers packaged as one unit... Make one to give your own setup to teammates, install it in many projects, or publish versioned releases."
- plugins.md: "An enabled plugin is part of every session". Install scopes are user, project, and local, and cloud sessions do not load local plugins.
- features-overview: "A second repository needs the same setup → Package it as a plugin".
- memory.md: Cowork sessions skip "a `~/.claude/CLAUDE.md` that is itself a symlink or hard link". This matters for a Stow-managed setup only if Cowork is used.

**Not found.** No Anthropic doc page gives guidance on putting `~/.claude` in a dotfiles repo.

### Topic 7. The dev loop, and whether a custom multi-stage process beats it

**Recommendation (simple loop).**
1. Plan mode, or ask Claude to interview you into a spec.
2. Start a fresh session to build from that spec.
3. Give it a check it can run: tests, a Stop hook, or `/goal` for unattended runs.
4. Review from a fresh context: `/code-review`, a second session, or a review subagent told to skip style.
5. Ship small PRs.

Run parallel work in worktrees (`claude -w`), and use agent view (`claude agents`) to watch background sessions.

**Sources for the simple loop.**
- Boris Cherny, 2026-01-02 thread (cited above): plan mode first ("A good plan is really important"). His most important tip is "give Claude a way to verify its work", which he says gives 2 to 3 times better quality. He runs 5 local sessions plus 5 to 10 web sessions.
- InfoQ, 2026-01-10 (cited above): separate git checkouts per session.
- Boris Cherny, 2026-01-31 thread (cited above): 3 to 5 worktrees is the "biggest productivity gain". He has a second Claude review the plan "as a staff engineer", re-plans when things go off track, and says "there is no single right way".
- Thariq Shihipar, session management post, 2026-04-15 (cited above): "when you start a new task, you should also start a new session". Also: "Rewind is often the better approach to correction."
- Trail of Bits README (cited above): interview, then spec, then a fresh session. Cut losses after two corrections.
- shanraisshan/claude-code-best-practice README (aggregator, cited above): all major workflows converge on "Research → Plan → Execute → Review → Ship".

**Against the docs.** Matches.
- best-practices: "Once `SPEC.md` exists, start a fresh session to build from it".
- best-practices: "`/code-review`... reviews the diff in a fresh subagent that never saw your conversation". Also: "A second session is also the easiest independent reviewer you can get."
- best-practices: "A reviewer that's asked to find problems will always find *something*." This is why the docs prompt says to skip style.
- goal.md: `/goal` "adds a separate evaluator that checks your condition after every turn, so completion is decided by a fresh model rather than the one doing the work". Also: "A goal doesn't change your permission mode. To let goal turns run unattended, run `/goal` in auto mode."
- best-practices: `/goal` is something "You rarely need... in the session yourself. It matters for long background runs".
- best-practices: worktrees through `claude -w`. `.worktreeinclude` copies gitignored files. `claude agents` is "(still a research preview)".
- agent-view.md: "Use agent view when you have several independent tasks Claude can work on without you watching every step."

**Custom multi-stage processes: who recommends them and what people report.**
- **Anthropic's own harness.** Prithvi Rajasekaran (Anthropic Labs), "Harness design for long-running application development", 2026-03-24, https://anthropic.com/engineering/harness-design-long-running-apps.
  - It uses planner, generator, and evaluator agents for multi-hour autonomous builds, because agents "reliably skew positive when grading their own work".
  - The author removed parts as models improved: "Opus 4.5 largely removed that behavior on its own, so I was able to drop context resets from this harness entirely". With Opus 4.6 he "started by removing the sprint construct entirely". Evaluation moved from per-sprint to a single pass at the end.
  - The evaluator is worth its cost "when the task sits beyond what the current model does reliably solo".
  - The key line: "every component in a harness encodes an assumption about what the model can't do on its own", and these assumptions "can quickly go stale as models improve."
  - This is the strongest source for a multi-role process, and it argues for keeping it minimal and stress-testing each piece.
- **Superpowers** (obra/superpowers, 323,004 stars, pushed 2026-11-03, https://github.com/obra/superpowers).
  - It is the most popular multi-stage process: brainstorming, then a design document, then writing-plans (2 to 5 minute tasks), then subagent-driven development with review after each task. Its README says: "Mandatory workflows, not suggestions."
  - Its own "Superpowers 6" release post, 2026-06-15, https://blog.fsck.com/2026/06/15/Superpowers-6.md, admits "tokens are expensive and Superpowers uses a ton of them" and "Slow isn't fun."
  - v6 cut wall-clock time about 50% and tokens about 60%, largely by "combining the spec compliance and code quality review agents". It warns that reviewers given only a diff package "produced confident spec verdicts that missed the missing brief".
  - The process steps were optimized, not removed.
- **Spec-driven tools.** Birgitta Böckeler, "Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl", martinfowler.com, 2025-10-15, https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html.
  - For a small bug, "the workflow was like using a sledgehammer to crack a nut". Also: "I'd rather review code than all these markdown files."
  - Agents still ignored specs, and "the best way for us to stay in control of what we're building are small, iterative steps."
- **Spec-kit discussion.** github/spec-kit Discussion #1784, "SpecKit creates the illusion of work, generating a bunch of text", opened 2025-09-08, 27 comments, https://github.com/github/spec-kit/discussions/1784.
  - The original poster reports that cutting their CLAUDE.md improved stability, and that Plan Mode beat SpecKit for their work.
  - Several replies say it is overkill for small changes but useful for large ones with a tuned constitution.
- **Head-to-head test.** Itzhak Eretz Kdosha, "I Tested Three Spec-Driven AI Tools. Here's My Honest Take.", Ran the Builder, 2026-04-13, https://ranthebuilder.cloud/blog/i-tested-three-spec-driven-ai-tools-here-s-my-honest-take/.
  - He tested BMAD full, BMAD Quick, Spec-Kit, and OpenSpec on a medium feature (Cursor with Sonnet 4.5).
  - OpenSpec scored best and Spec-Kit worst. His conclusion: "for work that small, Plan Mode is enough. Spec-driven workflow adds overhead simple features don't justify."
  - None was ready for enterprise use unmodified.

**Agreement on the multi-stage question.** Strong and consistent:
- Heavy multi-stage processes add ceremony, tokens, and review burden that small and medium work does not repay.
- Their reported value is on large, risky, or long unattended work: a written spec, a separate skeptical evaluator, and a record.
- The pieces worth keeping from them are already in the simple loop the docs describe: a written spec, a fresh session, a fresh-context reviewer, and an external check.

No source with standing recommends a custom planner, executor, and reviewer process with its own documents and gates over the simple loop for a solo developer's everyday work. The source closest to doing so (Anthropic's harness post) reports pruning its own harness as models improved.

**Contested.** The aggregator attributes to Cherny a preference for prototypes over PRDs ("build 20-30 versions instead of writing specs"). This sits against the docs' interview-into-SPEC.md flow. I did not open the original post, so treat it as unverified.

### Topic 8. Memory: auto memory, CLAUDE.md, and notes files

**Recommendation.** Use CLAUDE.md for rules you write and want in every session. Let auto memory hold what Claude learns, such as your feedback and project facts. Keep task notes in files the session reads on demand, such as a notes directory per task or a spec file, pointed to from CLAUDE.md. Review auto memory now and then, since it is per repo and can grow stale.

**Sources.**
- Boris Cherny, 2026-01-31 thread (cited above): one engineer keeps a notes directory per task, updated after every PR, with CLAUDE.md pointing at it.
- Michael Segner (cited above): CLAUDE.md as "an index pointing to other files".
- I found no dated first-hand practitioner report on living with auto memory. The search returned only re-statements of the docs and AI-generated explainers, which I did not cite.

**Agreement.** Weak, because there is little practitioner material on auto memory.

**Against the docs.** The CLAUDE.md-as-index and notes-file patterns go beyond the docs. They do not conflict with them.
- memory.md: auto memory has four types (user, feedback, project, reference). "Claude skips anything it can derive from the codebase". It loads "the first 200 lines or 25KB of MEMORY.md", is stored at `~/.claude/projects/<project>/memory/`, is shared across a repo's worktrees, and is on by default.
- memory.md, line 552: when MEMORY.md nears a limit, "Claude Code reminds Claude to shorten it: keep one line per entry, move detail into topic files, and merge or drop stale entries."
- memory.md: "Review your CLAUDE.md files... periodically to remove outdated or conflicting instructions".

**Stale.** GitHub issue reports from early 2026 that auto memory "can't be disabled" are outdated. Current controls are `/memory`, `autoMemoryEnabled: false`, and `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`. I saw this in search snippets and in memory.md, but did not open the issues.

### Topic 9. MCP

**Recommendation.** Prefer a CLI when the system has one (`gh`, `bq`, cloud CLIs). Keep MCP for things without a good CLI, such as browser automation through Playwright, documentation lookup, or Slack. Keep the count low and disable servers you do not use. Practitioners name 2 to 4 global servers.

**Sources.**
- Boris Cherny, 2026-01-02 thread (cited above): Slack MCP, the `bq` CLI, and Sentry. The 2026-01-31 thread names "bq CLI or MCP".
- Shrivu Shankar (cited above): he moved stateless tools to CLIs and keeps Playwright as MCP.
- Trail of Bits README (cited above): Context7 and Exa globally.
- ykdojo README, Tip 9 (cited above): Playwright MCP works better than the native browser integration for most non-visual tasks, but "does use a lot of context".
- Mario Zechner, "MCP vs CLI: Benchmarking Tools for Coding Agents", 2025-08-15, https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/. He calls the result "a wash": "it doesn't matter as much as you'd think", and "A well-designed, token-efficient tool can beat standard tools." This is the main practitioner nuance: tool design matters more than the protocol.

**Agreement.** Strong on CLI first and few servers. The context-cost argument is weaker now, per the docs on tool search below.

**Against the docs.** Matches.
- best-practices: "If that system has a CLI, that's usually the easiest way in." Also: "Connected servers add their tool names and instructions to the context even when you're not using them, so it's worth turning off the ones you don't need".
- mcp.md: "Tool search keeps MCP context usage low by deferring tool definitions... adding more MCP servers has minimal impact on your context window". Tool search is on by default.
- mcp.md scopes: local and user scope live in `~/.claude.json`, and project scope in `.mcp.json`.

**Conflict.** Trail of Bits places global servers in `~/.mcp.json`. That path is not in the docs' scope table, which puts user scope in `~/.claude.json`. Treat it as unverified.

**Partly stale.** Claims that MCP servers "eat the context window" with many tool schemas (common in 2025 posts) predate tool search becoming the default. The docs still say server instructions and tool names load, so the advice to turn off unused servers stands.

### Topic 10. Keeping a config current

**Recommendation.** Treat the config like code: review it on a schedule and delete as readily as you add. Use the built-in audits to find stale or contradicting lines and unused skills. Drop habits that worked around older models. Re-check harness pieces after model upgrades, since some stop being load-bearing. Read the changelog.

**Sources.**
- Michael Segner (cited above): "give it an owner, and review changes to it like code". He warns "nothing gets deleted".
- ykdojo README, Tip 28 (cited above): review CLAUDE.md "periodically", and use a `review-claudemd` skill that reads recent sessions.
- Trail of Bits README (cited above): run `/insights` weekly for continuous improvement. They audit the allowlist, as Shankar does.
- Prithvi Rajasekaran, harness post (cited above): assumptions "can quickly go stale as models improve". Stress-test components and remove those that are no longer load-bearing.
- Thariq Shihipar, skills post (cited above): log skill usage with a PreToolUse hook to find skills that undertrigger.
- shanraisshan aggregator (cited above): "update Claude Code daily" and "read the changelog", attributed to Anthropic staff. I did not open the originals.

**Agreement.** Strong on periodic review. Weak on a fixed cadence: weekly `/insights` is the only concrete cadence found.

**Against the docs.** Matches.
- best-practices: "`/doctor prompt-audit` flags instructions that were written for older models, point at files that no longer exist, or contradict each other". memory.md says it requires v2.1.283 or later.
- skills.md: "Run `/skill-doctor`" to see what each listed skill costs.
- best-practices: "If any other advice on this page ever starts to feel like busywork, that's probably a sign it belongs in this table too."

**What goes stale, per the docs' "What you can stop doing" table:**
- context-window rationing
- IMPORTANT or ALL CAPS emphasis
- subagents to protect context
- delegating for a better answer
- "think hard"
- "keep going"
- describing architecture in CLAUDE.md

## 3. Popular advice that is stale or contested

- **"The context window is finite and irreplaceable; manage it aggressively"** (Trail of Bits; ykdojo Tip 5 "AI context is like milk"; Tip 8 "Proactively compact"). This is stale. The docs say: "Most current models have a 1M-token window and compaction happens on its own, so running out is rare. `/clear` between tasks is still worth doing". The "new task, new session" part survives (Shihipar, 2026-04-15). The rationing does not.
- **"Use subagents to protect your context window."** This is stale per the docs table quoted in topic 3.
- **"Add IMPORTANT or ALL CAPS to rules Claude misses."** This is stale. The docs say: "piling on emphasis mostly makes Claude over-apply the rule. If it's a rule that can't bend, turn it into a hook or a deny rule."
- **"Tell Claude to keep going / don't be lazy."** This is stale. The docs replace it with "`/goal` or a `Stop` hook".
- **Custom slash commands as a separate system** (Cherny, 2026-01-02; Shankar, 2025-11). This is stale. The docs say "Custom commands have been merged into skills."
- **Mandatory multi-stage frameworks for all work** (Superpowers: "Mandatory workflows, not suggestions"). This is contested. Böckeler, the spec-kit discussion, and Kdosha all report overkill on small work. Superpowers' own v6 post cut its ceremony cost. Anthropic's harness post removed pieces as models improved.
- **bypassPermissions plus sandbox as the default local mode** (Trail of Bits). This is partly superseded by auto mode as the interactive default. It is still valid inside a container.
- **"MCP servers bloat context, so avoid them"** (2025 posts). This is weakened by default tool search. The CLI-first advice survives on simplicity grounds (Zechner: tool design matters more than protocol).
- **Prototypes over specs** (aggregator's attribution to Cherny). This is contested against the docs' interview-into-SPEC.md flow, and unverified, since I did not open the original.
- **Avoid `/init`** (HumanLayer). This is contested. The docs suggest `/init` and then cutting what is not needed.
- **`~/.mcp.json` for global servers** (Trail of Bits). This conflicts with the docs' scope table (`~/.claude.json`) and is unverified.

## 4. What I could not find or verify

**Not found.**
- A dated, first-hand practitioner report on living with auto memory over weeks: not found.
- A dated, first-hand account of a long unattended `/goal` run: not found. The results were docs restatements and blog explainers, and several looked AI-generated.
- Community reports on agent view (`claude agents`) in daily use: not found. Docs only.
- An Anthropic doc page on managing `~/.claude` in a dotfiles repo: not found.
- A practitioner count of "how many hooks" beyond "a few": not found.
- A source with standing that recommends a custom planner, executor, and reviewer process over the simple loop for solo everyday work: not found.
- Independent benchmarks of Superpowers' cost or quality: not found. Only self-run small tests and the project's own evals.
- Confirmation that path-scoped rules are not re-injected after auto-compaction (Trail of Bits claim): not found in memory.md.

**Second-hand only.** Seen in the shanraisshan aggregator, original not opened:
- Cherny's 2026-04-16 auto-mode tip
- the "/sandbox gave an 84% reduction in prompts" figure
- "context rot around 300k to 400k tokens"
- "prototype over PRD"
- "update Claude Code daily"

**Could not open.**
- https://kumestra.github.io/posts/202604/0403-claude-code-config-sync-design (HTTP 404).
- Not opened, for lack of time: Mario Zechner, "What if you don't need MCP at all?", 2025-11-02, https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/. Anthropic, "Effective harnesses for long-running agents", https://anthropic.com/engineering/effective-harnesses-for-long-running-agents. "Auto mode is now the default in Claude Code for Pro, Max, and Team plans", https://claude.com/blog/auto-mode-default-in-claude-code. dev.to "skill hoarding tax" post. Thoughtworks podcast on spec-driven development. BMAD and OpenSpec write-ups beyond the Kdosha test.
- GitHub issues on disabling auto memory (anthropics/claude-code #23544, #23750): seen in search results, not opened.

**Repo star counts** (from `gh api`, 2026-11-20): obra/superpowers 323,004; affaan-m/everything-claude-code 307,984; github/spec-kit 150,857; shanraisshan/claude-code-best-practice 69,276; gsd-build/get-shit-done 64,123; hesreallyhim/awesome-claude-code 58,484; bmad-code-org/BMAD-METHOD 55,584; anthropics/claude-plugins-official 47,857; ykdojo/claude-code-tips 10,363; trailofbits/claude-code-config 2,148. Stars measure popularity, not standing. I read only the Superpowers, Trail of Bits, ykdojo, and shanraisshan READMEs.
