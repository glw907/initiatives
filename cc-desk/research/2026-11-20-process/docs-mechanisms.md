# What the Claude Code docs say about the 12 mechanisms

Read on 2026-11-20. Claude Code version named in the decisions record: 2.1.329.

Sources are saved copies of the docs pages. Line numbers refer to those copies.

- Set A (`A:`): `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/<page>.md`
- Set B (`B:`): `/tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/da508574-e602-4efb-b951-0907e708b455/scratchpad/fetch/<page>.md`

The process under test is in `/var/home/glw907/Projects/cc-desk/docs/specs/2026-11-20-process-decisions.md` (lines 54-64 shape, 98-108 controls, 116-126 proposals).

Labels used here: **documented** (a page states it), **partly documented** (a page states part), **not found** (no page read states it). The process doc's own labels (documented, assembled, invented) are applied in the last section.

## 1. Background sessions: `claude --bg`, list, read, stop, attach

Label: **documented**. Pages: Agent view (B: agent-view.md).

- Start: "`claude --bg "investigate the flaky SettingsChangeDetector test"`" (line 514). "Claude Code rejects `--bg` combined with `-p` or `--print` before any session is created" (517).
- Start prints the commands (551-554): `claude agents` lists, `claude attach <id>` opens, `claude logs <id>` shows recent output, `claude stop <id>` stops.
- Shell table (lines ~780-796): `claude agents --json` "Print sessions as a JSON array and exit"; `claude attach <id|name>`; `claude logs <id|name>` "Print the session's recent output"; `claude stop <id>` (also `kill`); `claude respawn <id>`; `claude rm <id>`.
- Reading state from a script: "`claude agents --json` is the supported way to read session state from outside Claude Code, for example from a status bar, a scheduler, or another Claude session that supervises background work. Poll `claude agents --json --all`" (agent-view.md:821). `state` is one of `working`, `blocked`, `done`, `failed`, `stopped`.
- `done`: "The last turn finished what you asked for and the session is ready for your next prompt". `blocked`: "The session is waiting on you ... `blocked` always means the session needs something from you before it can continue."
- Files under `~/.claude/jobs/<id>/` "are not a stable interface." A session that wants to report in its own words should "write a file of its own, for example under `$CLAUDE_JOB_DIR/tmp`".
- Worktree: "When you dispatch a background session ... or start one with `claude --bg`, the session starts in your working directory. Before editing files, Claude moves the session into an isolated git worktree under `.claude/worktrees/`" (585). Skipped when the session is already inside a linked worktree (588-589).
- Finish: a bg session commits, pushes and opens a draft pull request, and "Never: pushing to main or master, force-pushing, and merging" (about 600-622). It ends with a report.
- Permission mode for `claude --bg`: "the new session starts the way a new `claude` session in that directory would" (713). So the mode comes from user settings or flags.
- `--model` is passed to `claude --bg` (681). `claude agents` takes `--permission-mode`, `--model`, `--effort` (731).
- Limits (1033-1039): research preview. "running ten agents in parallel uses quota roughly ten times as fast as running one." "stop if the machine shuts down."

Assumptions the process makes that the page does not state:
- That a bg session can be started by a script with no terminal. The page shows `claude --bg` from a shell; a systemd unit is not mentioned. Workspace trust dialog appears first in an untrusted directory (519).
- That a session in `dontAsk` ends `done` after a refused command. The page defines `done` as "finished what you asked for"; nothing ties a refusal to the end state. This rests on the probe in the decisions doc (line 62).
- A way for a script to tell "ended with work left" from "finished". `state` has only `done` or `failed`. Not stated.
- A per-session turn or spend cap (see 9).

## 2. `/goal`

Label: **documented** for scope, checker, limit, verdicts. **Not found** for bg sessions by name. Page: Goal (A: goal.md).

- What it is: "sets a completion condition and Claude keeps working toward it without you prompting each step. After each turn, a model checks whether the condition holds." (line 9). "`/goal` is a wrapper around a session-scoped prompt-based Stop hook." (about 120).
- Scope: "it's active for the current session only" (about 27).
- Checker: "sends the condition and the conversation so far to your configured small fast model. The model returns one of three verdicts": not yet met (keep working), met (goal clears, achieved entry), impossible (goal clears, failed entry with reason).
- Limit: "The condition can be up to 4,000 characters." (64).
- Turn cap: "To bound how long a goal runs, include a turn or time clause in the condition, such as `or stop after 20 turns`. Claude reports progress against that clause each turn and the evaluator judges it from the conversation." (66). So the cap is a sentence the checker judges, not a hard counter.
- No progress: "If Claude keeps answering the evaluator without making progress (no tool use for several turns in a row), Claude Code stops the loop, prints a warning, and returns control to you with the goal still set." Evaluation resumes after the next prompt.
- Errors that clear the goal: auth failure, full disk, "An exhausted credit balance", context overflow, model unavailable (132-147). Rate limit, usage limit, or a hook that ended the turn pause it. "After three automatic retries, the goal pauses".
- Where it runs: "`/goal` works in non-interactive mode, in the desktop app, and through Remote Control." (108). Example: `claude -p "/goal CHANGELOG.md has an entry for every PR merged this week"`.
- Check-ins (151-164): after 30 minutes of background work a check-in is due. "In a non-interactive session, such as one started with `-p`, this is the only way Claude Code delivers check-ins." Idle check-ins are interactive only.
- Stop hook interplay: the Stop hook has "an 8-consecutive-continuation cap" that resets when Claude calls a tool (hooks.md, Stop input).
- Best practices (B/A: best-practices.md:~232): "It matters for long background runs, where Claude sometimes ends a turn with a progress summary while items are still open, and the goal sends it back."

Assumptions the process makes that the page does not state:
- `/goal` inside a `claude --bg` session. The goal page names `-p`, desktop and Remote Control, not bg. Only the probe backs it.
- A goal that "ends and says what is left" when a cap is reached. The page says the turn clause is judged by the evaluator; what the session prints at the cap is not stated.
- What state a bg session shows after a goal is met or impossible. Not stated.
- That a goal survives a session restart (`claude respawn`). The page says the condition carries over on resume but "resets the turn count, timer, and token-spend baseline" (about 100).

## 3. Git worktrees for parallel sessions

Label: **documented**. Pages: Worktrees (B: worktrees.md), Agent view, Subagents.

- `--worktree`: "Pass `--worktree` or `-w` with a name to create a worktree ... on a new branch named `worktree-<name>`" under `.claude/worktrees/<name>/` (worktrees.md:24). Bg: "Start it with `claude --bg --worktree`" (63).
- Isolation is enforced: "While a session is isolated in a worktree, Claude Code blocks the tool calls the checks below define." (104). For bg sessions "Claude Code enforces worktree isolation for the session and for any subagents it spawns" (agent-view.md:585).
- Subagents: `isolation: worktree` in the definition runs the subagent in "a temporary git worktree ... branched by default from your default branch rather than the parent session's `HEAD`. The worktree is automatically cleaned up if the subagent makes no changes" (sub-agents.md:314).
- Base branch (worktrees.md:172-177): `worktree.baseRef` is `"fresh"` (default branch on the remote) or `"head"` (current local HEAD). "You can't set `worktree.baseRef` to a branch name. To start a worktree from a specific existing branch, create it with git directly." (177).
- From a pull request: `claude --worktree "#1234"` fetches the PR head from `origin` into `.claude/worktrees/pr-<number>` (195-200).
- By hand: `git worktree add ../project-bugfix fix-issue-456` (282-285).
- `.worktreeinclude` copies gitignored files such as `.env` into new worktrees (213-227). It does not run when a `WorktreeCreate` hook replaces creation (311).
- Cleanup: sweep removes subagent and bg worktrees older than `cleanupPeriodDays` that hold no work (146-154). A worktree you made with `git worktree add` is left alone (154).
- Shared state: all worktrees share `.git`, and "choosing 'Yes, and don't ask again' ... saves the rule to the main checkout's `.claude/settings.local.json`" (about 259-262).
- `claude rm` keeps a session with uncommitted changes (agent-view.md:631).

Assumptions not stated:
- A bg session started inside a worktree that the script made itself, on a chosen task branch. The skip rule says it works ("already inside a linked git worktree", agent-view.md:588), but a documented recipe for "branch from an unmerged task branch" is only the manual `git worktree add`. A bg session in such a worktree is not documented as given its own isolation or cleanup; the sweep leaves hand-made worktrees (worktrees.md:154).
- Stacked pull requests (a task branch whose base is another task branch). Not stated.
- Parallel session count on one machine. Only "ten times as fast" quota use (agent-view.md:1037).

## 4. Review by a fresh subagent or second session

Label: **documented**. Page: Best practices (A: best-practices.md).

- "By someone who didn't write the code: in the terminal, `/code-review` reviews the diff in a fresh subagent that never saw your conversation. It isn't swayed by the reasoning that produced the code." (250).
- Spec review prompt (258-266): "use a subagent to review the rate limiter diff against SPEC.md, check every requirement is implemented and the listed edge cases have tests, report gaps that affect correctness and skip style".
- "Don't drop the `skip style` part of that prompt. A reviewer that's asked to find problems will always find *something*. If you fix every finding, you end up with extra abstraction layers and tests for cases that can't happen." (268).
- Written spec as definition of done: "start a fresh session to build from it, so the build begins with a clean context and a written definition of done. It's also the file you'll point the reviewer at later" (131).
- Reviewer as a read-only subagent (470-486): `tools: Read, Grep, Glob`; "that limit is enforced by Claude Code rather than requested in a prompt."
- Second session: "A second session is also the easiest independent reviewer you can get. One session writes the rate limiter, another reviews ... without having watched it being written, and you paste the findings back into the first." (608).
- Cost: "A fresh reviewer does help, because it hasn't seen your reasoning" (619). "What they cost you is mostly tokens" (462).
- Evidence: "For a session you weren't watching, it's also the only evidence you have." (about 254).

Assumptions not stated:
- The second session running unattended and writing its verdict where a script can read it. The page has a person carrying the findings back ("you paste the findings back"). A rule that the pull request is flagged for Geoff is the process's own step.
- `/code-review` runs "in the terminal" (250); whether it runs inside a bg session is not stated.
- A bg session spawning a subagent reviewer works (subagents are said to be enforced into the worktree, agent-view.md:585), but a review verdict feeding the next step is not described.

## 5. Hooks that record session end or failure

Label: **documented** for each event; **mismatch** for use as an unattended recorder in two cases. Page: Hooks (A: hooks.md).

Common input on every event (749-770): `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`, `agent_id`/`agent_type` inside a subagent. `scratchpad_dir` needs v2.1.257.

- **Stop** (2843): "Runs when the main Claude Code agent has finished responding. Does not run if the stoppage occurred due to a user interrupt. API errors fire StopFailure instead." Input adds `stop_hook_active`, `last_assistant_message`, `background_tasks`, `session_crons`. "8-consecutive-continuation cap".
- **SubagentStop** (2695): adds `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, `last_assistant_message`; same decision format as Stop. Fires for Claude Code's own internal agents too.
- **StopFailure** (2947): "Runs instead of Stop when the turn ends due to an API error." Input adds `error` (`rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, and others), `error_details`, `last_assistant_message` (the error string). "Claude Code ignores the hook's output and exit code ... StopFailure hooks have no decision control. They run for notification and logging purposes only."
- **SessionEnd** (3669): input adds `reason`: `clear`, `resume`, `logout`, `prompt_input_exit`, `other`. "can't block session termination." Default timeout "1.5 seconds", raised per hook up to 60 seconds or with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`. The reason list has no value for a bg session that ended normally or by `claude stop`. Not stated.
- **PostToolUseFailure** (2391): "Runs when a tool that started executing fails." Input includes `is_interrupt`. "This event doesn't fire for ... a permission denial."
- **PermissionDenied** (2510): "Runs when auto mode denies a tool call ... This hook only fires in auto mode: it doesn't run when you manually deny a permission dialog". Input: `tool_name`, `tool_input`, `tool_use_id`, `reason`. By the page, it does not fire in `dontAsk`.
- **Notification** (2564): types include `agent_needs_input` ("A background session starts waiting on your input while agent view is open in a terminal") and `agent_completed` ("A background session finishes or fails. Fires only while agent view is open in a terminal"). Also `quota_auto_resume_*` types.
- Hook types: `command`, `http`, `prompt`, `agent` (hooks-guide.md:510-512, 870).
- `--bare` skips hooks; hooks passed with `--settings` do not run under `--bare` (best-practices.md:~560).

Assumptions not stated, or contradicted:
- `agent_completed` and `agent_needs_input` fire only while agent view is open, so they cannot record a failure in a timer-started run with nobody watching. The documented reader for that is `claude agents --json --all` (agent-view.md:821).
- No documented hook fires when a refused step is refused under `dontAsk`. PostToolUseFailure and PermissionDenied both exclude it. A refused step would have to be found by the session writing it down itself, or by a PreToolUse hook (permission denials "fire PreToolUse", hooks.md:2399) or by reading the transcript.
- Which of Stop, StopFailure, SessionEnd fires when a bg session is stopped with `claude stop` or when the machine shuts down. Not stated.
- Whether hooks configured in user settings run in `claude --bg` sessions. Not stated on the pages read; agent-view says the session starts "the way a new `claude` session in that directory would".

## 6. Permission modes for unattended work

Label: **documented**. Pages: Permission modes (A: permission-modes.md), Permissions (A: permissions.md), Best practices.

- Best practice: "Before a run goes unattended, make sure it knows what done looks like, can check its own work, and can only touch what it should. Give it a cap on turns or spend, and have a person approve the result at the end." (best-practices.md:~520). The five questions, including "What's it allowed to touch? Permission rules, `dontAsk`, the sandbox, a worktree, the one branch it may push to." and "What stops it? `--max-turns`, `--max-budget-usd`, a spend limit."
- Deterministic versus model: "Deny rules ... Claude Code applies this every time, no matter what the model decided" (best-practices.md:41-52). Deny rule enforcement is by Claude Code, not the model.
- **dontAsk** (permission-modes.md:653-664): "These calls are denied where you'd otherwise see a prompt": your `ask` rules, `AskUserQuestion`, org-`ask` connector tools, MCP tools needing user interaction. "An allow rule or `PreToolUse` hook can't approve these: Recognized `rm` and `rmdir` critical-path removals ... Reads from a network path". In `-p`: `--permission-mode dontAsk` "refuses anything else that would have prompted" (best-practices.md:~565).
- **auto**: a classifier checks actions. "if the classifier blocks an action 3 times in a row or 20 times total, auto mode pauses and Claude Code resumes prompting." Not configurable (568-570). "A non-interactive `-p` run without a `--permission-prompt-tool` has no prompt to fall back to. When repeated blocks reach a threshold, the action doesn't run and Claude keeps working. Claude Code doesn't stop the run." (572). Cloud routines: "Once blocks reach auto mode's repeated-block thresholds, a permission prompt appears in the run's session and waits until someone answers it" (routines.md:402).
- **bypassPermissions**: "approves everything your deny and ask rules don't cover, which only makes sense in a disposable container." A bg session in this mode "needs your acceptance of the bypass disclaimer on record" (agent-view.md:742).
- **acceptEdits**: auto-approves file edits; other prompts remain (permission-modes.md, mode table; not re-read here in full).
- A step that a deny rule refuses: denied, and "the turn continues" (settings-reference.md:1172 for the prompt case; permission-modes.md:653 "denied where you'd otherwise see a prompt"). The model gets the refusal and may try something else.
- Conversation boundary is weak: "`don't push until I've reviewed` ... It's still a model reading the transcript ... anything that matters belongs in a deny rule." (best-practices.md:~406).
- Bg: "Dispatched from `claude agents` started in a shell, or with `claude --bg`: the new session starts the way a new `claude` session in that directory would" (agent-view.md:713).

Assumptions not stated:
- That "finish the rest and list the step" happens. The pages say the refused call is denied and the turn continues. They do not say the session writes a list of refused steps. That is a prompt or goal instruction.
- That a bg session in `dontAsk` ends `done` (probe only, decisions doc line 62).
- What a bg session does at the auto-mode fallback threshold. The `-p` rule is documented; for bg it is not. It may show `blocked` (agent-view.md:821).
- A way to start a `--bg` session in `dontAsk` from the command line. `claude agents --permission-mode` is documented (731). A `--permission-mode` flag on `claude --bg` itself is not stated on the pages read; the cli-reference lists it as a general flag. Project settings cannot set auto or bypass defaults (permission-modes "which mode a session starts in").

## 7. `permissions.denyInsteadOfPrompting`

Label: **documented**. Page: Settings reference (B: settings-reference.md:1170-1204; A: settings.md:313 cites it).

- "Set this to `true` to keep a session running when nobody is there to answer a permission prompt. Claude Code denies a tool call that would otherwise wait on a prompt, and the turn continues. Requires Claude Code v2.1.319 or later."
- "A call goes ahead if an allow rule, your permission mode, or auto mode's classifier approves it. To allow most calls that would otherwise prompt, answer from a `PermissionRequest` hook."
- Scope: "User or managed, and `--settings`. A repository can't set it for you."
- "The key applies in `-p` runs, interactive terminal sessions, the VS Code extension, local sessions in the Desktop app, subagents, and agent teams." Background sessions are not in that list.
- Print-mode flag for one run: "`--permission-prompts none` with `-p`".
- Also removes `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode`; cancels MCP elicitation unless a hook answers; does not ask a `canUseTool` callback or `--permission-prompt-tool`.
- "A session can still wait on the workspace trust dialog and on project MCP server approval. Answer both before you leave the session running."
- Example config: `defaultMode: "auto"` with `denyInsteadOfPrompting: true`.

Assumptions not stated:
- That it applies to `claude --bg` sessions. Not in the list of where it applies. Verify by the same kind of probe as the `dontAsk` one.
- That it is better than `dontAsk` for a bg session. The docs do not compare them for bg.
- The workspace-trust warning matters for a systemd-started bg session in a fresh worktree: trust is per directory (agent-view.md:519), so a new worktree path may raise the dialog. Not stated either way for `.claude/worktrees/` children.

## 8. Scheduled tasks and routines

Label: **documented** for what exists; **not found** for the timer-script pattern. Pages: Scheduled tasks (A: scheduled-tasks.md), Routines (B: routines.md), Desktop scheduled tasks (B: desktop-scheduled-tasks.md), Best practices.

- Best practices: "Once a run is going, Claude can handle the rest by itself. The one thing it can't do is decide to *start*, so something has to: you, a timer, or an event like a failed CI check or a new PR." (best-practices.md:~574). So a timer is named as a starter. A systemd timer is not named.
- Options table (desktop-scheduled-tasks.md:26-36): cloud (no machine needed, fresh clone, no local files, auto mode by default, minimum interval 1 hour); Desktop (local files, only while app open and computer awake, 1 minute minimum when Claude sets it); `/loop` (session-bound, 1 minute).
- `/loop`: "Each run is another turn in the same session, so don't leave one going in a long conversation." (best-practices.md:~582).
- Cloud: "Claude creates `claude/`-prefixed branches"; "protect `main` with a GitHub branch rule the task can't bypass" (best-practices warning; routines.md:364-376). Hourly limits: 100 scheduled runs per hour per account (routines.md:468). Research preview (routines.md:11).
- `/schedule` "sets up a cloud scheduled task that runs on a timer. It needs a claude.ai login rather than an API key." (best-practices.md:~584).
- Scripts: "`claude -p` ... is how Claude Code ends up in CI jobs, git hooks, and shell loops." (best-practices.md:~548). Shell loop example with `--allowedTools`, `--permission-mode dontAsk`, `--max-turns 20`.
- Session-scoped scheduled tasks (`/loop`, `CronCreate`) have limits listed under "limitations" (scheduled-tasks.md:213, 240, 248-252).

Assumptions not stated:
- A systemd timer that launches `claude --bg` per free task. The docs describe shell loops with `claude -p` and cloud or desktop schedules. A timer plus `--bg` is assembled from documented parts.
- Starting the next task because the last merged or finished. No page suggests chaining that way; the docs' trigger types are time, GitHub event and API call. A timer that reads `claude agents --json --all` is assembled.
- A documented way for a script to read weekly usage so it can stop at "85 percent of weekly usage" (decisions doc line 121). Not found on the pages read. Usage-limit pause and auto-resume exist as interactive behavior (goal.md pause rule; hooks.md `quota_auto_resume_*`).

## 9. Headless `claude -p`: turn and budget limits

Label: **documented**. Pages: Headless (B: headless.md), CLI reference (B: cli-reference.md), Best practices.

- `-p` runs once and exits (best-practices.md:~548).
- "`--max-turns` ... Limit the number of agentic turns (print mode only). No limit by default." (cli-reference.md:107).
- "`--max-budget-usd` ... Stop the run once estimated spend on API calls reaches this amount (print mode only) ... which can differ from your bill. Spend from subagents counts toward the cap. Spend can pass the cap" (106).
- "a run that hits the turn limit exits with an error instead." (best-practices.md:~566).
- Exit: "exits with code 0 on success and a non-zero code when the run fails" (headless.md:33).
- "`claude -p` can exit with code 0 before the command finishes" when a subagent's long command moves to the background (headless.md:96). Background wait cap: "10 minutes of continuous idle waiting by default" (79).
- "Claude Code rejects `--bg`" with `-p` (headless.md:21; agent-view.md:517).
- `--bare` skips hooks, skills, plugins, MCP servers and CLAUDE.md; auth comes from `ANTHROPIC_API_KEY` or `apiKeyHelper` (best-practices.md:~552).
- `/goal` works with `-p` and runs "to completion in a single invocation" (goal.md:108).

Assumptions not stated, important:
- **No documented hard cap for a bg session.** `--max-turns` and `--max-budget-usd` are print mode only, and `--bg` cannot be used with `-p`. The only documented bound is a turn or time clause in the goal condition. "A cap ends the session and asks nothing" (decisions doc line 104) is assembled or invented for bg.
- A time cap (the decisions doc proposes "twice its planned minutes"). The goal page allows a time clause judged by the evaluator (goal.md:66). No hard timer. A script could call `claude stop <id>` after a deadline (agent-view.md:551-554); that use is assembled.
- Estimated spend in a bg session is not exposed on the pages read.

## 10. Skills

Label: **documented**. Pages: Skills (A: cc-skills.md), Skill authoring best practices (A: agent-skills-best-practices.md).

- Frontmatter table (cc-skills.md:403-422): `name` (optional, defaults to the directory), `description` ("Recommended"), `when_to_use`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `compatibility`.
- Description cap: "the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing to reduce context usage. Put the key use case first" (404).
- `disable-model-invocation: true`: "prevent Claude from automatically loading this skill. Use for workflows you want to trigger manually with `/name`. Also prevents the skill from being preloaded into subagents and from running when a session-scoped scheduled task ..." (408). "Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`" (565). Table (593): with it, "Description not in context, full skill loads when invoked".
- `user-invocable: false`: "background knowledge that isn't actionable as a command" (567).
- Length: "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files." (cc-skills.md:559; agent-skills-best-practices.md:257, 1140, 1150).
- Split: progressive disclosure; "Keep references one level deep from `SKILL.md`" (382); "For reference files longer than 100 lines, include a table of contents at the top." (410). "No context penalty for large files ... until actually read" (1051).
- Name: "Maximum 64 characters, lowercase letters/numbers/hyphens only, no XML tags, no reserved words" (1133). Description: "Always write in third person" (206).
- Checklist: "`SKILL.md` body is under 500 lines" and "File references are one level deep" (1150-1155).
- Model and effort per skill: `model` and `effort` apply for the rest of the current turn; "With `context: fork`, the value sets the forked subagent's effort level" (412-413).
- Evaluations: the authoring guide covers building evaluations first (agent-skills-best-practices.md; the decisions doc line 27 relies on it; not re-quoted here).

Assumptions not stated:
- That a skill loads inside a bg session started by a script. Skills are session features; a bg session "starts the way a new `claude` session in that directory would" (agent-view.md:713), so user and project skills should load. Not stated outright.
- `disable-model-invocation` also blocks the skill in "a session-scoped scheduled task" (408), which matters if a skill is meant to start from a scheduled prompt.

## 11. CLAUDE.md

Label: **documented**. Page: Memory (A: memory.md), Best practices.

- Size: "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence. Move instructions that matter for only part of the codebase into path-scoped rules" (memory.md:90). Imports "help you organize a long file but don't reduce" context (90).
- What belongs: "Keep it to facts Claude should hold in every session: build commands, conventions, project layout, 'always do X' rules. If an entry is a multi-step procedure or only matters for one part of the codebase, move it to a skill or a path-scoped rule instead." (51).
- "Claude treats CLAUDE.md files and auto memory as context. They aren't enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook instead." (36).
- Best practices ("Keep CLAUDE.md short"): "every line in it takes a little of Claude's attention on *every* task ... works best when it only holds what Claude couldn't work out from the code itself"; "the single most useful line in your CLAUDE.md is the command that runs [the check]." (best-practices.md:~137-139).
- Rules: `.claude/rules/*.md`; with `paths` frontmatter they load only when Claude reads a matching file (memory.md:194-211). "Rules load into context every session or when matching files are opened. For task-specific instructions that don't need to be in context all the time, use skills instead" (174). Rules without `paths` load at launch (190).
- Conflicts: "if two instructions contradict each other, Claude may pick one arbitrarily" (92). `/doctor prompt-audit` audits CLAUDE.md, rules, skills, subagents (98).
- Path rules in worktrees: "To have path-scoped rules load for files in a sibling git worktree, start Claude Code in that worktree" (218). A bg session starts in the main directory and then moves to a worktree (agent-view.md:585).
- Auto memory: first 200 lines or 25KB of `MEMORY.md` (memory.md:31).
- Decision table (best-practices.md:40-52): prompt, CLAUDE.md, and skills are non-deterministic; hooks, deny rules, managed settings are deterministic.

Assumptions not stated:
- Whether a path-scoped rule loads in a bg session that moved itself into a worktree after start. Not stated; the rule matches on files Claude reads, and the base path is "the directory that contains the rule's `.claude` folder" (memory.md:215), which for a worktree is the worktree's own copy only if the file is tracked in git.
- The process's own claim that a global CLAUDE.md sentence exempts cc-desk work (decisions doc lines 9-14). Docs say conflicting instructions are resolved arbitrarily (92).

## 12. Subagent definitions: model and effort

Label: **documented**. Page: Subagents (B: sub-agents.md).

- Fields (225, 301-316): `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt`, `autoCompactWindow`, `omitClaudeMd`.
- `model`: "`sonnet`, `opus`, `haiku`, `fable`, a full model ID such as `claude-opus-5-5`, or `inherit`. When you omit it, Claude Code picks the model in the subagent model order." (303).
- Order (348-362): per-invocation `model` parameter; the `model` field; `CLAUDE_CODE_SUBAGENT_MODEL`; the main conversation's model.
- `effort`: "Effort level when this subagent is active. Overrides the session effort level, but not the `CLAUDE_CODE_EFFORT_LEVEL` environment variable. Options: `low`, `medium`, `high`, `xhigh`, `max`; available levels depend on the model." (313). With no field: env var, then the spawner's effort, then `CLAUDE_CODE_SUBAGENT_EFFORT`, then the session level (436-440).
- `maxTurns`: "Maximum number of agentic turns before the subagent stops. When the subagent reaches the limit, Claude Code returns its output marked as partial, and Claude can resume it" (305; marking needs v2.1.246). This is a hard cap for a subagent, unlike a bg session.
- `permissionMode`: `dontAsk` is allowed (304); ignored for plugin subagents.
- `isolation: worktree` (314).
- Cost guidance: "Set `model: haiku` in a subagent's definition if its work is simple" (best-practices.md:468). "by default it's the same model (or a smaller one) on the same task. You get parallelism or a fresh pair of eyes out of it, but not a smarter answer." (464).
- A bg session can be dispatched with a subagent as its agent: "the default agent for a dispatched background session" is `claude` (sub-agents.md:77); a subagent with `model` frontmatter can be started by name or `@name` in the dispatch (agent-view.md:681).
- Hook input includes `effort.level` for Stop and SubagentStop (hooks.md:757).

Assumptions not stated:
- Dispatch names a model and an effort per session. For `claude --bg` the flag `--model` is documented (agent-view.md:681); `--effort` is documented for `claude agents` (731). Effort on `claude --bg` itself is not stated on the pages read.
- A way to run the review as a separate subagent with its own `maxTurns` inside a bg session is documented as parts, not as one recipe.

## What the new process assumes that the pages do not say

Ranked by how much the process leans on it.

1. **A cap that ends a bg session.** Not documented. `--max-turns` and `--max-budget-usd` are print mode only, and `--bg` cannot be combined with `-p`. Only a clause in the goal text, judged by the checker, or a script calling `claude stop`. The no-progress stop (goal.md:~122) and the 8-continuation Stop cap (hooks.md Stop input) are unrelated safeguards.
2. **Hooks that record failure in an unattended bg run.** `agent_completed` and `agent_needs_input` fire only while agent view is open. The supported reader is `claude agents --json --all`. PostToolUseFailure and PermissionDenied do not see a `dontAsk` refusal. StopFailure sees API errors only.
3. **A bg session in `dontAsk` ending `done` after a refusal.** Pages say the call is denied and the turn continues. The end state is covered only by the probe in the decisions doc.
4. **`/goal` in `--bg`.** Pages name `-p`, desktop and Remote Control. Only the probe covers bg.
5. **`denyInsteadOfPrompting` in bg.** Not in the list of surfaces. It cannot be set by a repository, so the timer script's user settings or `--settings` carry it.
6. **A systemd timer that starts the next task.** Documented starters are cloud schedules, desktop schedules, `/loop`, shell loops with `-p`, and GitHub events. A timer on `claude --bg` is assembled.
7. **A task branching from an unmerged task branch.** `worktree.baseRef` cannot name a branch. The documented route is `git worktree add <path> <existing-branch>` by hand, or `--worktree "#<PR>"` from an open pull request (worktrees.md:177, 195-200, 282-285). Cleanup of a hand-made worktree is left to the user.
8. **Reading usage for an 85 percent weekly cut-off.** Not found on the pages read.
9. **A written list of what a session could not finish.** Docs give a report at the end of a bg session; the "Couldn't finish" and "Held for you" groups would need the session to write them, or a script to build them from `claude agents --json`, `claude logs`, and the pull request state.
10. **Second-session review as a hands-off step.** Docs show a person carrying findings; a subagent or `/code-review` returns findings into the main session.
11. **Per-session model and effort on `claude --bg`.** `--model` documented; effort documented for `claude agents`.

## Where the process matches the docs

- Fresh session, written spec as definition of done, fresh reviewer against that spec: best-practices.md:131, 250, 258-268.
- Fresh worktree per bg session, commit, push, draft PR, no merge: agent-view.md:585-622.
- A person approves the merge: "a person approving the merge, the deploy, or anything else you can't take back" (best-practices.md:~530); "Branch protection, a person who approves the merge" (table, line 52).
- Deny rules as the real control: best-practices.md:~406 and the decision table.
- A timer starts the run, Claude carries it through, a person signs off: best-practices.md:~574.
- Reading state through `claude agents --json`: agent-view.md:821.
