# Workstation alignment spec

Status: approved by Geoff on 2026-11-21 ("Approved."). He changed no recommendation, so each of
the six stands as written.

This spec brings the workstation's Claude Code configuration into line with Anthropic's docs. It
replaces the pass process with Claude Code's documented flow, in one new skill. It fixes what four
audits found in the personal skills, the `standards` plugin, and the rest of the configuration. It
then removes the old process and its words. The work runs as nine tasks and nine pull requests,
and Geoff approves each pull request by number. One task needs no pull request, and the last
takes two. Six questions wait for him, listed under
[What Geoff decides](#what-geoff-decides). Everything else here is either his ruling, quoted, or a
call Claude made, listed under [Calls Claude made](#calls-claude-made).

Three text files sit beside this spec, and approving the spec approves their text:

- `2026-11-20-alignment-global-file.txt` is the new global `CLAUDE.md`.
- `2026-11-20-alignment-skill.txt` is the new process skill, `building-from-specs`.
- `2026-11-20-alignment-spec-writing-reference.txt` is that skill's reference for writing a spec.

## What Geoff decides

Each question has a recommendation, and the spec is written as if each recommendation holds.
Each question ends with what a different answer changes.

1. **The exact text that lets build sessions edit skill files.** A background session can't
   write under a `.claude` directory unless auto mode's classifier allows it, and it refused such
   edits in `~/.dotfiles` worktrees as late as 2026-11-20 with no matching entry. The entry
   under [Groundwork](#groundwork) clears skill, agent, rule, docs, instructions, and script
   files in a worktree, for a task of a spec Geoff approved. It stays in place after this spec,
   because every later task session needs it. Unlike the old entry, it covers the script a hook
   runs. It doesn't cover the settings line that turns a hook on, the rest of the settings,
   permission rules, `CLAUDE.md`, memory, or the two lists under `tooling/`. Recommended: approve
   the text as written. If no, the entry's row leaves Groundwork and the probe edits a file
   outside `.claude`. A build session then edits nothing under `.claude`, and Geoff's session
   makes each of those edits from the pull request's text. The core build worked that way. It
   is cc-desk's core design, merged on 2026-11-20 as pull request 255 in the workstation repo.
2. **The new global `CLAUDE.md`.** The companion file changes 40 lines of 119 and comes to 117.
   Recommended: approve it as written. If no, Geoff names the lines he wants changed, and the
   switch lands the file with his changes. No done item changes, because the switch's `diff`
   reads against the file as he approved it.
3. **Whether `running-passes`, `spec-plan-review`, and `plan-reviewer` leave the published
   plugin.** They are the old process's routing inside `standards`. Recommended: yes. If no,
   the three stay as they are, the plugin task's search leaves their files out, and the other
   descriptions are trimmed further to fit the listing. The rulings file
   (`specs/2026-11-20-process-decisions.md`) parked a second half of this question: where four
   craft rules go that lived only in `pass-core`'s references. That half needs no answer,
   because all four are in the new skill's reference. [Calls Claude made](#calls-claude-made)
   names them.
4. **How many skills get evaluations now.** Anthropic's skill checklist asks for at least three
   evaluations per skill, run on Haiku, Sonnet, and Opus. Geoff pays for the runs. One skill
   costs 24 short sessions: four evaluations, three models, each with the skill on and off. A
   part of the plugin runs through `claude plugin eval` instead, at six runs a case. The choices
   are the new process skill only (24 sessions), the 12 changed parts (216 sessions and the
   plugin's cases), or every skill (at least 980 runs). The 12 changed parts are the ones this
   spec writes or whose loading it changes: the new skill, seven personal skills, `survey`, and
   three in the plugin (`brainstorming`, `backlog-sweep`, and the `diff-reviewer` agent).
   Recommended: the 12 changed parts, run on the workstation and not in CI, with the rest
   evaluated when each is next changed. Another answer changes only the evaluation rows of four
   tasks (the process skill, personal skills, the plugin, and survey) and the number of runs.
5. **Whether two personal values come out of the workstation repo.** The `google-sheets` skill
   holds an email address at a private domain and a Google Cloud project number, and the repo is
   public. Neither is a credential, and the address isn't the technical-mail address that the
   global file already publishes. Both also sit outside the skill: the number in three more
   tracked files, the address in seven more, and both in the repo's history, which this spec
   doesn't rewrite. Another session is editing one of those files now. Taking the values out of
   the skill alone would leave them public. Recommended: leave them for now, and decide one
   sweep of every file as later work, after that session's file has landed. If Geoff wants them
   out of the skill anyway, the personal-skills task removes both, the skill reads them from two
   variables that Geoff's session sets in `~/.local/secrets`, and the other files are listed for
   the sweep.
6. **Build sessions run in auto mode, not `dontAsk`.** Geoff's ruling says background sessions
   run in `dontAsk` mode, "which denies every call that would prompt, so none of them merges".
   `dontAsk` also denies every write under a `.claude` directory, so a session in that mode can't
   edit a skill. This spec keeps the property he ruled on by another documented route: auto mode
   with `permissions.denyInsteadOfPrompting`, which also refuses every call that would prompt.
   Recommended: approve the change. The first task tests it before anything rests on it. If no,
   build sessions run in `dontAsk`, none of them can edit under `.claude`, and Geoff's session
   makes those edits, as under a no to question 1. The probe then runs in `dontAsk` and edits a
   file outside `.claude`.

## What is wrong today

The configuration holds a development process built here. Claude Code now documents the same job:
a spec, a session that works toward a written goal, a fresh reviewer, and a pull request. Four
audits on 2026-11-20 checked the rest against the docs, and three subagents then checked each
audit against the files it names.

- The process is spread across six personal skills (`pass-core`, `cairn-pass`, `site-pass`,
  `approval-packet`, `cc-desk`, `cc-desk-work`), one project skill (`dotfiles-pass`), three
  plugin parts, the global file, two hooks, and four scripts. `pass-core` alone is named by 20
  live files.
- Seven of the other 13 personal skills depend on that process. Twelve have no evaluations.
  Six descriptions don't say what the skill does, or use the wrong person.
- The plugin's skill listing overflows its budget, so four `vale-*` skills lose their
  descriptions in every session. Nothing runs the plugin's three evaluation cases.
- Nine of the 14 `bluefin-admin` docs reach no session, because no loaded file names them. Two
  more files sit in `instructions/`, which isn't a place Claude Code loads from.
- The home directory has two memory stores, because `/home` is a link to `/var/home` and Claude
  Code keys a store by the path a session starts in.
- Three settings keys are deprecated, redundant, or send a push to a phone Geoff doesn't have.

## What it is for

Geoff, 2026-11-20: "We'll align with anthropic/community best practices at the workstation level
and then work from there." And: "I don't want to be inventive here. I'd prefer to follow
established best practice."

The work is done when these hold:

- Every mechanism the configuration keeps or adds is labeled documented, community, assembled
  from documented pieces, or invented, and each invented one that stays has its reason here.
- One skill, `building-from-specs`, states the process in Claude Code's words: spec, task, step,
  goal, session. No live file names the old process, as [The old words](#the-old-words)
  defines it.
- Between two of Geoff's sittings, no session stops to wait for him unless it truly needs him.
  That is the test he set ("Yes, that's the test.").
- No session merges without his approval by number. His session runs the merge, and a
  permission prompt stops it once for each pull request.
- The personal skills and the plugin meet the skill, subagent, and plugin docs on the points the
  audits found.

## The old words

Two lists of words stand for the old process in every search below.

The retired words are `approval-packet`, `approval packet`, `approval-queue`, `approval queue`,
`cc-desk-work`, `running-passes`, `spec-plan-review`, `plan-reviewer`, `pass plan`, and
`pass guide`. When the last task has merged, no live file holds one apart from two parked
lines in `settings.json`, and the workstation's gate fails if one comes back.

The alias words are `pass-core`, `conductor`, and `executor`. Project files in other repos still
use them, and those files are out of scope. Two live files keep the alias words on purpose. The
global file has one line for project files, and `building-from-specs` tells a session how to
read them. They join the retired words when the cairn and `dubplate` repos have moved, which is
later work.

A live file is a tracked file that a session loads or runs. A record, a changelog, a backlog, an
archive of old text, and anything under an `evals/` folder are not live files. Neither is a
list that a check reads to find these words: the workstation's
`claude/.claude/tooling/retired-phrases.txt` and the plugin's `scripts/scan-patterns.txt`.

The word "pass" alone is on neither list, because `cairn-pass` and `site-pass` keep their names
and design work uses the word in another sense.

## What it leaves out

- How a chain of unattended tasks runs, the timer script, the forecast, and a task that builds
  on another task's branch.
- The cc-desk page and the removal of cc-desk's Go.
- Project `CLAUDE.md` files and configuration inside other repos, including the cairn and
  `dubplate` repos. Geoff reshapes both afterward.
- Server work on `ward` and `orpheus`, and whether the approval-queue repo is archived.
- Moving the plugin's project-only parts out of every repo's sessions. That needs project
  configuration in the repos that use them.

## What would make it a failure

- A background session merges a pull request, or waits on a prompt nobody answers.
- A guard that cairn or `dubplate` relies on stops working before those repos move.
- A hook's line in the settings names a script that isn't there. A missing script on an
  `onFailure: block` hook blocks every Bash call in every session.
- A mechanism designed here lands where the docs already give one.
- Another session's uncommitted work in `~/.dotfiles` is lost or rewritten.
- A secret or a personal detail reaches a public repo.

## Constraints

- The sources are `~/.dotfiles/claude/.claude/` and `~/.dotfiles/bin/.local/bin/` (repo
  `glw907/workstation`), `~/Projects/standards`, and `~/Projects/survey`. All three are public.
- Settings reach the live file only through `claude-tooling-sync apply`. Hook scripts, the global
  file, skills, and rules are links, so they change the moment the main checkout pulls.
- `apply` writes each tracked top-level key over the live one and removes nothing. A top-level
  key that the tracked file drops stays in `~/.claude/settings.json` until someone deletes it
  there. Groundwork found this on 2026-11-21.
- A hook's line in the settings is changed before its script is removed or renamed. A new script
  is in place, with `stow -R bin` run, before a settings line names it.
- Another session has uncommitted work in `~/.dotfiles`: one file under `docs/bluefin-admin/`
  and one new script. No task moves or renames anything under `docs/bluefin-admin/`, and none
  edits that file. Before each launch, Geoff's session reads `git status --short` in the repo's
  main checkout and holds a task whose paths hold another session's uncommitted file.
- Several of the plugin's skills are copies of skills from other repos, among them
  `brainstorming`, `receiving-code-review`, `golang-spf13-cobra`, and `daisyui`. The
  workstation's `claude/.claude/tooling/vendored-skills.json` lists them.
  `claude-tooling-sync update-skills` rewrites a copy from its source and carries over only the
  description the list gives. `brainstorming` has been rewritten here since it was copied and
  is kept by hand. No task hand-edits the body of any other copy.
- The global file stays at or under 120 lines, which `claude-context-budget` enforces.
- The `standards` plugin's scan forbids workstation names and paths in its tracked files, so
  text written for the plugin names neither Geoff nor a workstation tool.
- Each task starts from `main` and touches files no other running task touches.

## Approaches

Three ways of building it were weighed.

**Small independent tasks (the pick).** Each task starts from `main`, owns its files, runs in a
fresh session under `/goal`, gets a fresh reviewer, and ends in a pull request Geoff approves by
number. Each pull request is small enough to read, each goal fits `/goal`'s 4,000-character
limit, and a task that goes wrong holds back nothing else. It is also the documented flow, so
the build tests the process it lands. The cost is nine pull requests and an order to keep.

**One large build session.** One pull request would be too large to review, and its goal would
pass 4,000 characters. One failure would hold everything.

**A fresh `~/.claude` built up from defaults.** It would give the cleanest result. It would
also drop, on the day it landed, guards that cairn and `dubplate` rely on, and Geoff said to
change nothing they rely on outside what a spec names.

## How a task gets built

The process skill's text says this in full. In short:

1. Geoff's session checks that the repo is free and launches the task from the repo's main
   checkout with `claude --bg`, in auto mode, with a `/goal` condition that names this spec and
   the task and ends with a time clause.
2. Claude Code moves the session into a new worktree, cut from `origin/main`. The session
   builds, commits, pushes, and opens a draft pull request.
3. The session dispatches a fresh subagent to review the branch against the task's done items.
4. Geoff approves the pull request by number, and his session merges it.

Some edits never go to a background session. Geoff's session makes every change to
`settings.json`, the global `CLAUDE.md`, the two lists under `claude/.claude/tooling/`, a shell
startup file, and a memory store, each from text or steps this spec gives. A build session
edits skills, agents, rules, docs, scripts, tests, and the plugin.

This spec and the research it names are in `~/Projects/initiatives/claude-config-alignment/`,
and each goal gives that path.

Some done items read the live workstation: `~/.claude`, `~/.local/bin`, or what a fresh session
loads. A build session can't meet those on its branch. Each is marked "after the merge" below
and stays out of the session's goal. After each merge, Geoff's session does these in order:

1. It runs `claude-worktree-busy` on the repo's main checkout and pulls.
2. It runs `stow -R bin` when the pull request added, renamed, or removed a script.
3. It runs `claude-tooling-sync apply` and `verify` when the pull request changed the settings.
   It then deletes from `~/.claude/settings.json` each top-level key the pull request removed.
4. It checks the after-merge items and posts each result on the pull request.
5. It runs `claude rm <id>` on the task's session, which removes the worktree, and then deletes
   the branches. `claude rm` refuses while a commit is on no remote, so it comes before the
   remote branch goes. Claude Code names the worktree's branch `worktree-<session name>`, and a
   session that makes a branch of its own leaves both to delete.

Until the task called [The switch](#the-switch) lands, a pull request merges by
`approval-queue land <owner/repo#n> <sentence>` after Geoff's approval by number, or he merges it
on GitHub. After it, his session runs `gh pr merge` behind the permission prompt.

## How a skill is evaluated

The skill authoring page gives a file format for evaluations and says "There is not currently a
built-in way to run these evaluations." A build session runs them itself.

Each skill's `evals/evals.json` holds four evaluations in the page's format, with the keys
`skills`, `query`, `files`, and `expected_behavior`. Three are requests the skill should handle
and one is a request it shouldn't. The session runs each query in a fresh session on Haiku,
Sonnet, and Opus, once with the skill on and once with `skillOverrides` set to `"off"` for it.
That comes to 24 sessions a skill. The evidence is saved under `evals/results/<date>/`.

The pull request carries one table for each skill, with 12 rows: one for each query on each
model. A row shows whether the skill loaded, and whether each expected behavior was met with
the skill on and with it off, each beside the quoted line that shows it. A skill passes when it
loads on the three in-scope queries, stays unloaded on the fourth, and meets every expected
behavior with the skill on.

A query whose expected behaviors are all met with the skill off shows nothing about the skill,
and the table marks it. The reviewer reads each query and expected behavior against the skill's
text and reports any that a wrong skill would still pass.

A skill with `disable-model-invocation: true` never loads by itself. Its queries invoke it by
name, and its fourth query checks that a plain request doesn't load it.

The plugin's three parts use `claude plugin eval` instead. That command reads a different case
format and runs each case three times with the plugin and three times without.

## What gets built

The tasks run in this order. Tasks under [Side by side](#side-by-side) can run at once.

| Task | Repo | Who builds it | Waits for |
| --- | --- | --- | --- |
| Groundwork | workstation | Geoff's session | approval of this spec |
| The process skill | workstation | a build session | Groundwork |
| The switch | workstation | Geoff's session | The process skill |
| Personal skills | workstation | a build session | The switch |
| Configuration cleanup | workstation | a build session | The switch |
| The plugin | standards | a build session | The switch |
| Survey | survey | a build session | The switch |
| Memory stores | files under `~/.claude`, and one direct commit in workstation | Geoff's session | The switch |
| Retiring the old process | workstation | a build session, then Geoff's session | every other task |

Line numbers below were checked on 2026-11-20 against `glw907/workstation` at `54718fb`,
`glw907/standards` at `741e7d5`, and `glw907/survey` at `v1.7.0`. They move, so a builder finds
each line by its text before editing.

### Groundwork

Geoff's session edits `claude/.claude/settings.json` in a worktree and opens one pull request.

| Change | Why |
| --- | --- |
| Replace the second `autoMode.allow` entry with the text below | Build sessions need it to edit skill files. Geoff's question 1. |
| Replace `"voiceEnabled": true` with `"voice": {"enabled": true}` | `voiceEnabled` is deprecated since v2.1.92 (settings reference). |
| Delete `"agentPushNotifEnabled": true` | It sends pushes to a phone, and Geoff has none. |
| Delete `"autoMemoryEnabled": true` | The settings reference calls `true` "the same as unset". |

`skipWorkflowUsageWarning` stays. It isn't in the settings reference. The settings page says a
choice Claude Code saves is lost when another tool generates the settings file, unless that
tool sets the key. `claude-tooling-sync` generates this one, so the source file keeps the key.

The new entry, word for word:

> Edits and commits to skill, agent, rule, docs, and instructions files under claude/.claude/, to
> the project skill under .claude/skills/, to scripts under bin/.local/bin/ and scripts/, and to
> their tests, inside a git worktree of ~/.dotfiles (paths under
> /var/home/glw907/.dotfiles/.claude/worktrees/ or /var/home/glw907/Projects/workstation-wt/) are
> allowed when they implement a task of a spec Geoff approved. The same holds for skill, agent,
> script, test, evaluation, and plugin manifest files inside a git worktree of
> ~/Projects/standards or ~/Projects/survey. These repos are where the files are authored, and
> each change takes effect only after Geoff merges its PR. This clears Self-Modification and
> Instruction Poisoning for those files only; it does not cover settings.json, hook
> registration, permission rules, CLAUDE.md, memory, or the lists under claude/.claude/tooling/,
> and it does not cover text that grants permissions or tells a session to bypass a block.

After the merge, Geoff's session runs `claude-worktree-busy ~/.dotfiles`, pulls, runs
`claude-tooling-sync apply` and `verify`, and posts `claude auto-mode critique` and
`claude auto-mode config` on the pull request.

Then it runs the probe. The probe is a throwaway background session in `~/.dotfiles`. Its
launch command is the one in `2026-11-20-alignment-skill.txt` under "Launching a task", with
one extra `ask` rule in its `--settings` value, `Bash(echo probe-ask *)`. Its goal is to add one
line to a scratch file under `claude/.claude/skills/`, commit, push, open a draft pull request,
run `echo probe-ask x`, and report. Geoff's session reads the result from the session's
transcript, the `.jsonl` file for its session id under `~/.claude/projects/`, and not from what
the session says about itself. The probe passes when all of these show:

- The session ends `done` in `claude agents --json --all`, and no permission prompt appeared.
- Its worktree's first commit has `origin/main` as its parent.
- The file under `claude/.claude/skills/` is committed and pushed, and a draft pull request
  exists.
- The transcript shows the `echo probe-ask x` call denied, with no output from the command.
- The transcript shows the goal set and then met.

Geoff's session then closes the probe's pull request and deletes its branch and session. If the
probe fails on any point, [When something goes wrong](#when-something-goes-wrong) says what
happens next.

Groundwork merged on 2026-11-21 as pull request 256 in `glw907/workstation`. The probe passed on
all five points, and the pull request quotes the transcript lines.

Done items:

- `jq -r '.autoMode.allow[] | select(startswith("Edits and commits to skill, agent, rule, docs,
  and instructions"))' ~/.claude/settings.json`, with the pattern on one line, prints the new
  entry. Today it prints nothing.
- `jq '.voice.enabled' ~/.claude/settings.json` prints `true`.
- `jq 'has("voiceEnabled") or has("agentPushNotifEnabled") or has("autoMemoryEnabled")'
  ~/.claude/settings.json` prints `false`.
- `claude-tooling-sync verify` exits 0.
- The probe passes on all five points, with the transcript lines quoted on the pull request.

### The process skill

A build session adds new files and one small change to `pass-report`.

The skill is live once its pull request merges and the main checkout pulls. Its description
answers to the old process's names, so from then until the switch a session could load it
beside `pass-core`. Geoff's session keeps that gap short. It opens the switch's pull request
before it merges this one, and it merges the two in one sitting.

| File | Change |
| --- | --- |
| `claude/.claude/skills/building-from-specs/SKILL.md` | New, from the companion text |
| `claude/.claude/skills/building-from-specs/references/writing-a-spec.md` | New, from the companion text |
| `claude/.claude/skills/building-from-specs/evals/evals.json` | New: four evaluations, by [How a skill is evaluated](#how-a-skill-is-evaluated) |
| `bin/.local/bin/pass-report`, `tests/test_pass_report.py` | `SCORE_RE` reads a `task-score` comment as well as `pass-score`, with a test |
| `bin/.local/bin/task-report` | New: a two-line script that runs `pass-report` with the same arguments. The skill's text names `task-report`, and the last task makes it the real file. |
| `claude/.claude/docs/claude-tooling.md` | A row for the skill in the "Layout" table |

The session runs the four evaluations and puts the table in the pull request. It is the first
task to run them, so it also records how it started each session and how long one took.

Done items:

- `diff` between each companion file and its landed file prints nothing.
- `wc -l` on `SKILL.md` prints under 500, and its description is under 1,536 characters.
- The evaluation table in the pull request has 12 rows from 24 sessions, and the skill passes:
  on each model the three in-scope queries load it, the fourth doesn't, and every expected
  behavior is met with the skill on. Each cell quotes its evidence, saved under
  `evals/results/`.
- `claude-tooling-sync verify` exits 0. `bash scripts/gate.sh` exits 0 and runs a new test case
  in which `pass-report` reads a `task-score` comment.
- After the merge: `task-report --help` runs, and a fresh session's skill listing shows
  `building-from-specs`.

### The switch

Geoff's session makes these edits in one worktree and one pull request. The edits can't be
split. Today `claude-merge-guard` denies every `gh pr merge`, and a hook's denial wins over an
`ask` rule. If the rule landed first, the prompt would never appear. If the guard's merge half
left first, nothing would stand between a session and a merge.

| File | Change |
| --- | --- |
| `claude/.claude/settings.json` `permissions.ask` | Add `Bash(gh pr merge *)` and `Bash(gh api *pulls/*/merge*)` |
| `claude/.claude/settings.json` `permissions.allow` | Remove `Bash(approval-queue *)` |
| `claude/.claude/settings.json` `autoMode.allow` | Remove the `approval-queue merge` and `land` entry. In the entry for `CLAUDE.md`, docs, skill, and agent files, replace "that approval is the merge authorization for this classifier" with "Geoff's answer to the merge prompt authorizes the merge". |
| `claude/.claude/settings.json` `autoMode.environment` | Drop "including the approval queue on 127.0.0.1:7907" |
| `claude/.claude/settings.json` hooks | Remove the line that runs `claude-launch-guard`. The script stays until the last task. |
| `bin/.local/bin/claude-merge-guard`, `tests/test_claude_merge_guard.py` | The half that denies `gh pr merge` answers `"ask"` in place of `"deny"`, with a new reason text. Its tests pin `"ask"` for every spelling they pinned `"deny"` for. The force-push and staging halves stay. |
| `claude/.claude/CLAUDE.md` | Replace with the companion text |
| `claude/.claude/skills/pass-core/SKILL.md` | Reword the fourth rule of "Until cc-desk runs" and the merge sentence in "Close" to say the session Geoff is talking to merges with `gh pr merge` behind the prompt |

This pull request merges by `approval-queue land`, the last one that does. After the merge,
Geoff's session runs `claude-worktree-busy ~/.dotfiles`, pulls, and runs `claude-tooling-sync
apply` and `verify` at once. The pull changes the guard's script, which sends a merge to a
prompt from then on, and the apply turns the `ask` rules on. Geoff's session runs no merge
command until the apply has finished. It then runs `gh pr merge --help` and corrects
the merge command in the skill text if a flag differs, posts `claude auto-mode critique` and
`claude auto-mode config`, and runs one `gitleaks git` scan.

Done items:

- `jq '.permissions.ask' ~/.claude/settings.json` lists the two new rules beside the two
  `wrangler` rules. Today it lists only the `wrangler` rules.
- `jq '.permissions.allow | index("Bash(approval-queue *)")' ~/.claude/settings.json` prints
  `null`. Today it prints `43`.
- `gh pr merge --help` runs in Geoff's session. Before the switch the guard refuses it.
- The next pull request Geoff approves stops at a permission prompt when his session runs
  `gh pr merge`, and merges when he answers it. His session records that on the switch's pull
  request. Until then this item is open.
- A background session launched by the skill's command runs
  `gh pr merge 999999 --repo glw907/workstation`. Its transcript shows the call denied before
  it ran, with no output from `gh` and no prompt shown.
- `diff` between the companion file, as Geoff approved it, and `~/.claude/CLAUDE.md` prints
  nothing. `wc -l ~/.claude/CLAUDE.md` prints 120 or less.
- `grep -c 'pass-core' ~/.claude/CLAUDE.md` prints 1, the line for project files. Today it
  prints 7.
- `jq -r '.autoMode.allow[]' ~/.claude/settings.json | grep -c -E 'approval-queue|merge
  authorization for this classifier'`, with the pattern on one line, prints 0.
- `jq -r '.autoMode.environment[]' ~/.claude/settings.json | grep -c 7907` prints 0. Today it
  prints 1.
- `jq -r '[.hooks[][] | .hooks[].command] | .[]' ~/.claude/settings.json | grep -c
  claude-launch-guard` prints 0. Today it prints 1.
- `grep -c 'approval-queue land' ~/.claude/skills/pass-core/SKILL.md` prints 0. Today it
  prints 1.
- `bash scripts/gate.sh` exits 0 with the guard's tests in it. One shows a force-push to `main`
  still refused, and one shows `gh -R owner/repo pr merge 5` answered with `"ask"`.

### Side by side

These five tasks touch different files and can run at once, as far as the limit of four working
sessions on pavilion allows. The limit counts Geoff's session and every other session at work.

#### Personal skills

This task covers 12 skill folders: the 13 personal skills outside the process, less `survey`,
which is fixed in the survey repo. They aren't the 12 parts of question 4. Seven are in both.

| Skill | Change | Source |
| --- | --- | --- |
| `engine-consult`, `vps-conventions`, `proton-pass`, `claude-infra` | Rewrite each description in the third person to say what the skill does and when to use it | Skill docs: a description says both, in the third person |
| `register-check` | Description opens in the third person; add `background: false` beside its fork; remove two em dashes | Skill docs; the house rule on em dashes |
| `vps-conventions` | Remove eight em dashes; add `paths` for `**/*.service`, `**/*.timer`, and `**/user-data.yaml` | Skill docs: `paths` loads a skill on matching files |
| `retire-project` | Add `disable-model-invocation: true` | Skill docs: use it for workflows with side effects |
| `mail-tend` | Move the re-sort into a step the skill runs only on Geoff's request, and say so at that step | Same |
| `google-sheets` | Remove the lines naming the turned-off `anthropic-skills:google-workspace`; line 3 of `references/apps-script.md` pins `clasp` 3.4.1 and comes to say "Tested with `clasp` 3.4.1". The two personal values stay unless Geoff answers question 5 otherwise. | The skill is off in `skillOverrides` |
| `claude-infra`, `writing-voice`, `maintenance-mode`, `engine-consult` | Cut the stale or dated passages the audit lists | Skill docs: keep a skill to what Claude needs each time |
| `claude-infra`, `engine-consult`, `log-project`, `mail-tend`, `maintenance-mode`, `retire-project` | Reword every line that names the old process into the new words, pointing at `building-from-specs` | Geoff's rename ruling |
| `engine-consult` | Its rule that a spec carries a consultation line becomes a check the spec author runs, named in the skill as a done item | Skill docs: a rule that must hold belongs in a check |
| `engine-consult`, `vps-conventions`, `proton-pass`, `claude-infra`, `register-check`, `retire-project`, `mail-tend` | Add `evals/evals.json` and run it, by [How a skill is evaluated](#how-a-skill-is-evaluated) (question 4) | Skill checklist: at least three evaluations |

`claude-infra` keeps its name. The skill docs reserve the words `claude` and `anthropic` in a
skill name, and the name loads today. A rename would touch the global file and 3 other files, so
it is left for the day the name stops loading.

The file-and-line list is section 4 of
`research/2026-11-20-workstation/local-skills-audit.md`, as corrected by the verifier: seven
skills depend on the process, not eight, and survey's `git add` and `git commit` have no allow
rule.

Done items:

- This search over the 12 skill folders, leaving out each `evals/` folder, prints nothing. Today
  it prints 15 lines in six skills. It is wider than the two lists in
  [The old words](#the-old-words), because these skills also say "planner" and "a pass".

  ```bash
  git grep -n -i -E 'pass-core|approval-packet|approval packet|approval-queue|approval queue|cc-desk-work|running-passes|spec-plan-review|plan-reviewer|pass plan|pass guide|conductor|executor|planner|\b(a|the|each|every|one|next|per) pass\b'
  ```

- `grep -n -A1 '^description:'` over the `SKILL.md` of `engine-consult`, `vps-conventions`,
  `proton-pass`, `claude-infra`, and `register-check` shows no description that opens with
  "Use" or "Run". Today all five do.
- `git grep -c '—'` over `register-check` and `vps-conventions` prints nothing.
- `grep -c '^paths:' claude/.claude/skills/vps-conventions/SKILL.md` prints 1, and
  `grep -c 'background: false' claude/.claude/skills/register-check/SKILL.md` prints 1. Today
  each prints 0.
- One of `mail-tend`'s in-scope evaluations is a misfiled-message request that asks for no
  re-sort, and its expected behavior is that the session runs none.
- The pull request lists each passage cut from `claude-infra`, `writing-voice`,
  `maintenance-mode`, and `engine-consult` beside the audit line that names it. It quotes the
  line of `engine-consult` that names the consultation check.
- `grep -c 'disable-model-invocation: true' claude/.claude/skills/retire-project/SKILL.md`
  prints 1.
- `git grep -n 'anthropic-skills:google-workspace' claude/.claude/skills/` prints nothing.
- Only if Geoff wants the two values out of the skill (question 5): a search for the email
  address's domain and for the project number over `claude/.claude/skills/google-sheets/` prints
  nothing, and the pull request lists every other tracked file that holds either.
- Each of the seven skills has `evals/evals.json` and passes, with its 12-row table in the pull
  request. `retire-project`'s queries invoke it by name.
- `bash scripts/gate.sh` exits 0.

#### Configuration cleanup

| File | Change | Source |
| --- | --- | --- |
| `claude/.claude/skills/bluefin-admin/SKILL.md` | New, about 15 lines. Its description says when workstation admin work needs it, and its body sends the reader to `~/.claude/docs/bluefin-admin.md`, the index of 14 leaves. | Skill docs: reference material loads through a skill and its supporting files |
| `claude/.claude/instructions/ai-operational-rules.md` | Move to `docs/record/`. Any rule in it that no loaded file carries is listed for Geoff in the pull request. | `instructions/` is not a load location (memory docs) |
| `claude/.claude/instructions/fastmail-api.md` | Move to `docs/`, and fix the pointer in `docs/bluefin-admin/email.md` | Same |
| `claude/.claude/docs/web-content-method.md` | Delete. The two copies differ today (`diff` prints 19 lines), so the session lists each difference for Geoff in the pull request. | The plugin's copy at `content-draft/references/web-content-method.md` is the one sessions load, and only a record names this one |
| `claude/.claude/rules/vale.md` | Narrow the `**/styles/**` glob to the Vale style files, so it stops loading on CSS | Memory docs: `paths` scopes a rule |
| `claude/.claude/rules/vale.md`, `rules/cairn-family-ui.md` | Reword the two old-process clauses | Rename ruling |
| `claude/.claude/agents/prose-voice-reviewer.md`, `cairn-register-editor.md` | Replace "Read-only" with what is true: the agent reads, and runs commands that write nothing | Subagent docs: a description states what the agent does |
| `claude/.claude/agents/site-implementer.md` | Remove `memory: project` and the line that reads a `MEMORY.md` that has never existed; reword "a pass plan" | Subagent docs |
| `bin/.local/bin/claude-memory-write-check` | Lines 7 and 8 use `"${HOME#/var}"` in place of `/var"$HOME"`, which never matches | Bug |
| `bin/.local/bin/claude-tooling-sync` | Its three JSON writes pass `ensure_ascii=False`, with a test | Lessons row 12 |
| `claude/.claude/docs/engine-ui-mechanics.md` | Line 3 says the global file points to it. `site-pass` does. | Fact |
| `claude/.claude/docs/claude-tooling.md` | "Layout" rows for the new skill and the moved files. The "Instructions" row goes with the folder. | `claude-infra` procedure |

Four docs stay where they are, each reached by the file that needs it:
`fable-post-cutoff-system.md` by the prompt in the repo's `docs/model-review/`, `oom-defense.md`
by a `bluefin-admin` leaf, `claude-md-archive.md` by `claude-context-budget`, and
`unattended-work-guards.md` by the global file.

No other repo relies on the `instructions/` folder. The `dubplate` and `phonebook` project files
each name an `instructions/` file inside their repo.

Done items:

- `ls claude/.claude/instructions` fails, because the folder is gone, and
  `grep -c 'instructions/' claude/.claude/docs/claude-tooling.md` prints 0.
- `ls claude/.claude/docs/record/ai-operational-rules.md claude/.claude/docs/fastmail-api.md`
  lists both files, and `git grep -n 'instructions/fastmail-api' -- claude bin` prints nothing.
- `ls claude/.claude/docs/web-content-method.md` fails, and the pull request lists each
  difference between the two copies.
- `grep -c '^description:.*Read-only'` prints 0 for `prose-voice-reviewer.md` and for
  `cairn-register-editor.md`. Today it prints 1 for each.
- The pull request quotes line 3 of `engine-ui-mechanics.md`, which names `site-pass`.
- After the merge: a fresh session asked "which doc covers SELinux denials on this
  workstation?" names `bluefin-admin/selinux.md`, and its transcript shows a Skill call for
  `bluefin-admin`. Today no loaded file leads there.
- After the merge: a session that reads a `.css` file under a `styles/` folder doesn't load
  `rules/vale.md`, and `/memory` in that session doesn't list it.
- `claude-memory-write-check` prints its reminder for a write to a memory path spelled
  `/home/glw907/...`, as it does for the `/var/home` spelling, shown by its test. The hook
  reminds and never refuses.
- A new test writes a value that holds a non-ASCII character through the manifest write that
  `update-skills` uses and through the settings write that `apply` uses. Each file then holds
  the character itself and no `\u` escape. `apply` never writes the manifest, so a test of
  `apply` alone wouldn't show this.
- `grep -c 'memory:' claude/.claude/agents/site-implementer.md` prints 0.
- `claude-tooling-sync verify` and `bash scripts/gate.sh` exit 0.

#### The plugin

In `~/Projects/standards`. The plugin updates on the workstation by itself, because its
marketplace entry has `autoUpdate` on. Paths in the table are under `plugins/standards/`, apart
from `scripts/` and `tests/`, which are at the repo's root.

| File | Change | Source |
| --- | --- | --- |
| `skills/running-passes/`, `skills/spec-plan-review/`, `agents/plan-reviewer.md`, `evals/running-passes-pairs-and-merge/` | Delete (question 3). Remove their two caps from `scripts/check-skill-lines.sh`. `tests/check-skill-lines-test.sh` builds its fixtures on those two files, so its fixtures move to two files that stay. | The old process |
| `skills/brainstorming/SKILL.md` | Step 4 and the three other places that name `running-passes` say "build it by the repository's guide for building from a spec" | Same |
| `agents/diff-reviewer.md`, `skills/backlog-sweep/SKILL.md` | Descriptions drop the old-process words. `diff-reviewer` gains a "use when". | Subagent docs |
| `.claude-plugin/plugin.json`, the marketplace file | Descriptions drop "a short pass lifecycle" | Fact |
| Every skill description | Trim until the listing fits its budget, so the four `vale-*` skills keep their descriptions. A copied skill's description is the one field this task edits in it, and the last task writes the same text into the workstation's list. | Skill docs: the listing has a budget of 1% of context |
| `skills/brainstorming/SKILL.md`, `visual-companion.md` | `SKILL.md` gives the server script's path once, as `${CLAUDE_SKILL_DIR}/scripts/start-server.sh`. The six command lines in `visual-companion.md` run the path `SKILL.md` gave. | Skill docs: the variable is filled in only in a skill's `SKILL.md`, never in a file the skill reads later |
| `skills/go-ship/SKILL.md` | The fallback dispatch to an agent from another plugin becomes the bundled `/simplify` | Plugin docs: a plugin declares the plugins it needs, and this one declares none |
| `agents/figure-verifier.md`, `agents/visual-verifier.md`, `skills/design-refinement/`, `skills/visual-fidelity/` | Remove dated history. `design-refinement` keeps "round" and "pass" in their design sense. | Skill docs |
| `evals/` | Cases for `brainstorming`, `diff-reviewer`, and `backlog-sweep` (question 4) | Plugin evaluations page |

Done items:

- `claude plugin validate plugins/standards` and `claude plugin validate .` pass, and CI is
  green on the pull request.
- The retired-words search over the whole repo, `git grep -n -i -E` with the ten words of
  [The old words](#the-old-words), prints one line, in `scripts/scan-patterns.txt`. Today it
  prints 30 lines in 11 files.
- `grep -c -i 'use when' plugins/standards/agents/diff-reviewer.md` prints 1 or more, where
  today it prints 0. `git grep -n 'pass lifecycle'` prints nothing, where today it prints two
  lines.
- The pull request quotes `go-ship`'s new fallback line, which names `/simplify` and no agent
  of another plugin.
- After the merge and the plugin's update: a fresh session's skill listing shows a description
  for each of the four `vale-*` skills, and `claude --debug` logs no listing-budget warning.
- `git grep -n 'bash scripts/start-server.sh' plugins/standards/skills/brainstorming/` prints
  nothing, where today it prints six lines. `grep -c 'CLAUDE_SKILL_DIR}/scripts/start-server.sh'
  plugins/standards/skills/brainstorming/SKILL.md` prints 1.
- `claude plugin eval plugins/standards` exits 0 with no `--threshold` or `--runs` flag, so the
  default threshold of `1.0` and three runs a side apply. Its report is in the pull request.
- `git diff origin/main` over the eight copied skills (`daisyui`, `golang-spf13-cobra`,
  `receiving-code-review`, and the five `vale-*`) changes no line but a `description:` line.

#### Survey

In `~/Projects/survey`, whose skill the workstation vendors at `v1.7.0`. Paths are under
`skills/survey/`.

| File | Change | Source |
| --- | --- | --- |
| `SKILL.md` | Third-person description; old-process lines reworded; the route to `approval-brief.md` removed | Skill docs; rename ruling |
| `SKILL.md` release steps | Move to a reference file that says Geoff asks for a release | Skill docs: side-effect workflows aren't model-invoked |
| `writing/approval-brief.md` | Delete. The Approval Queue it wrote for is gone. | Fact |
| `writing/commit-and-pr.md`, `writing/agent-facing.md` | Reword the old-process lines | Rename ruling |
| `writing/agent-facing.md`, `writing/commit-and-pr.md`, `writing/technical-doc-web.md` | A contents list at the top of each. These are the reference files of 100 lines or more once `approval-brief.md` is gone. | Skill checklist |
| `evals/evals.json` | Four evaluations, by [How a skill is evaluated](#how-a-skill-is-evaluated) (question 4) | Skill checklist |

After the merge, Geoff's session cuts the survey release by the repo's release steps. The last
task brings the new version into the workstation.

Done items:

- This search prints nothing. Today it prints 17 lines in four files. The repo's changelog and
  records keep their history.

  ```bash
  git grep -n -i -E 'approval[- ]brief|approval[- ]queue|approval[- ]packet|cc-desk-work|running-passes|spec-plan-review|plan-reviewer|pass plan|pass guide|pass-core|\b(a|the) pass\b' -- skills/survey
  ```

- `grep -c '^description: Use ' skills/survey/SKILL.md` prints 0, where today it prints 1.
- `SKILL.md` holds no release step, and the pull request names the reference file that does.
- Each of the three long reference files has a contents list in its first 15 lines.
- The repo's gate passes, and the skill passes its evaluations, with the 12-row table in the
  pull request.

#### Memory stores

Geoff's session does this by hand, because a memory store and a shell startup file are his
session's to edit.

The `/home` store is `~/.claude/projects/-home-glw907/memory/`, and the `/var/home` store is
`~/.claude/projects/-var-home-glw907/memory/`. The `/home` store holds an index and 11 files,
written before the core build. No session has opened them for this spec, and at least one is
about the old process by its name.

1. List the 11 files for Geoff with one line on what each says. Mark each one that describes
   the old process, with a recommendation to delete it. Copy nothing until he answers.
2. Copy each file he keeps into the `/var/home` store, and add its line to that store's
   `MEMORY.md`. Where both stores hold a file of the same name, keep the newer and tell him.
3. Add `cd -P .` to the `claude` function in `bash/.bashrc`, so every session starts from the
   `/var/home` spelling. This is one direct commit in the workstation repo, made when
   `claude-worktree-busy ~/.dotfiles` exits 0 and `git status --short` shows that file
   unchanged. Approving this spec approves the commit.
4. Remove the `/home` store's folder.

Done items:

- A session started from `/home/glw907` and one started from `/var/home/glw907` both report the
  same memory folder in `/memory`.
- `ls ~/.claude/projects/-home-glw907/memory` fails, because the folder is gone.
- The `/var/home` store's `MEMORY.md` has one line for each memory file and names no file that
  isn't there.
- A search for the retired words over the `/var/home` store, with `grep -r -l -i -E`, prints no
  file but one Geoff chose to keep in step 1.

### Retiring the old process

The last task, launched after every other pull request has merged and the survey release is
cut. It takes two pull requests, because Geoff's session keeps the settings and the two lists
under `claude/.claude/tooling/`.

A build session opens the first. Two searches over the workstation repo give its file list,
both run with `git grep -n -i -E` over `claude/.claude .claude bin scripts tests bluefin`,
leaving out `claude/.claude/docs/record`, `claude/.claude/docs/claude-md-archive.md`, and each
`evals/` folder. The retired-words search hits 27 files today outside the four skills that
go. The alias search (`pass-core|conductor|\bexecutor\b`) hits 23. The table names each file,
and a file the session finds beyond it gets the same treatment.

| File | Change |
| --- | --- |
| `claude/.claude/skills/pass-core/`, `approval-packet/` | Delete |
| `claude/.claude/skills/cairn-pass/`, `site-pass/` | Reword into the new words and point at `building-from-specs`. Their names and repo facts stay. |
| `.claude/skills/dotfiles-pass/SKILL.md` | Rewrite to the repo's facts: its gate, its checks, and how settings reach the live file |
| `bin/.local/bin/round-watch`, `claude-pass-load`, `claude-launch-guard` | Delete, with `tests/test_round_watch.py`, `tests/claude-pass-load.test.sh`, and `tests/test_claude_launch_guard.py` |
| `scripts/check.sh` | Remove the `pass-loads` and `skill-caps` legs and drop `claude-launch-guard` from the `pytest` leg's list. The `skill-caps` leg goes in the commit that deletes `pass-core`, so the gate passes at every commit. |
| `bin/.local/bin/claude-context-budget`, `tests/claude-context-budget.test.sh` | Remove the seven `pass-core` word caps, the `--skill-caps` mode that reads only them, and the test cases built on them |
| `bin/.local/bin/task-report`, `pass-report`, `tests/test_pass_report.py` | `task-report` takes `pass-report`'s code in place of its two lines, and `pass-report` is deleted. The test becomes `tests/test_task_report.py`. The reading of the approval queue is dropped. |
| `bin/.local/bin/claude-git-guard`, with a test | New: a copy of `claude-merge-guard` under the name that fits what is left of it. The old file and its test stay in this pull request. |
| `bin/.local/bin/claude-secret-guard` | It loads its command parser from `claude-merge-guard` and allows every command when that file can't load. It loads `claude-git-guard` instead, and its test shows a staged secret file still refused. |
| `bin/.local/bin/claude-worktree-busy`, `tests/claude-worktree-busy.test.sh` | Drop the skip for the queue's server, with its test fixtures |
| `bin/.local/bin/survey-writing-review` | Line 25 no longer names the Approval Queue |
| `tests/fixtures/block-pass-searches.json` | Three fixture commands name the approval-queue repo's path. They name another repo's path, and `tests/test_claude_block_pass.py` still passes. |
| `bluefin/bootstrap.sh` | Drop the clone of the approval-queue repo |
| `bluefin/SECOND-WORKSTATION.md` | Two dated history lines say "conductor" and "pass". Reword both. |
| `claude/.claude/docs/unattended-work-guards.md`, `docs/claude-tooling.md`, `docs/voice/written-for-people.md`, `docs/fable-post-cutoff-system.md` | Reword the old-process lines. `written-for-people.md` points at `approval-packet/references/` and at a `pass-core` reference, and both pointers go to `building-from-specs`. |
| `claude/.claude/agents/`, `claude/.claude/skills/` | Any line the two searches still find after the earlier tasks |

The build session leaves `cc-desk/`, `cc-desk-work/`, `survey/`, and `tooling/` alone.

After the first pull request merges, Geoff's session pulls and runs `stow -R bin`. That links
`claude-git-guard`, and it clears the links to the deleted scripts. Geoff's session then opens
the second pull request.

| File | Change |
| --- | --- |
| `claude/.claude/skills/cc-desk/`, `cc-desk-work/` | Delete, with their two entries in `claude/.claude/tooling/vendored-skills.json` |
| `claude/.claude/tooling/vendored-skills.json`, the `survey` entry | Set `branch` to the new release's tag and drop the note's clause about `approval-brief.md`. Then run `claude-tooling-sync update-skills survey`, which rewrites the skill's files and the entry's `commit`. |
| `claude/.claude/docs/voice/approval-brief.md` | Remove the link. The files that cited it are gone by now. |
| `claude/.claude/tooling/vendored-skills.json`, the entries with `"home": "standards"` | Set each `description` to the text the plugin task landed, so the next update keeps the trim |
| `claude/.claude/tooling/retired-phrases.txt` | Add the ten retired words, one to a line |
| `claude/.claude/settings.json` hooks | The `PreToolUse` line names `claude-git-guard` |

`claude-merge-guard` stays in this pull request. A pull removes a deleted script at once, and
the live settings would name it until the apply, which no session could run with every Bash
call blocked. So after the second pull request merges, Geoff's session pulls and runs
`claude-tooling-sync apply` and `verify`. Only then does it remove
`bin/.local/bin/claude-merge-guard`, `tests/test_claude_merge_guard.py`, and the test's name in
the `pytest` leg's list, as one direct commit, and run `stow -R bin`. Approving this spec
approves that commit.

`update-skills` writes into `~/.dotfiles` unless `--home` names another root, and the main
checkout may hold another session's uncommitted files. How Geoff's session runs it in a worktree
is left to that session, and it shows `git status --short` for the main checkout unchanged
before and after.

Two lines in `settings.json` keep a retired word, and each waits for a question Geoff parked
in the rulings file. The repo list in `autoMode.environment` names the `approval-queue` repo,
which still exists. The server-work entry says "an approved pass plan". Nothing else keeps one.

`cairn-pass` and `site-pass` keep their names because project files in other repos name them,
and those files are out of scope. The line for project files leaves the global file only when
the cairn and `dubplate` repos have moved, which is later work.

Done items for the first pull request:

- Both searches print lines only in the places the second pull request handles
  (`claude/.claude/skills/cc-desk/`, `cc-desk-work/`, `survey/`, `claude/.claude/tooling/`, and
  `settings.json`) and, for the alias search, in `claude/.claude/CLAUDE.md` and
  `claude/.claude/skills/building-from-specs/SKILL.md`.
- `bash scripts/gate.sh` exits 0 on the commit that deletes `pass-core` and on the branch's last
  commit.
- `grep -c 'claude-merge-guard' bin/.local/bin/claude-secret-guard` prints 0, where today it
  prints 3.
- After the merge: `task-report --help` runs, and `command -v pass-report round-watch
  claude-pass-load claude-launch-guard` prints nothing.
- After the merge: `find ~/.local/bin -xtype l` prints nothing, so no link points at a deleted
  script.
- After the merge: a fresh session in `~/Projects/cairn-cms` asked "how do I build the next
  piece of work?" names `building-from-specs` and `cairn-pass`, and its transcript shows a Skill
  call for each.

Done items for the second pull request and the commit after it. Geoff's session checks each
after the apply:

- `ls ~/.claude/skills` shows no `pass-core`, `approval-packet`, `cc-desk`, or `cc-desk-work`.
- The retired-words search prints the two parked `settings.json` lines, the lines of
  `retired-phrases.txt`, and nothing else. The alias search prints lines in the global file,
  `building-from-specs/SKILL.md`, and `retired-phrases.txt`, and nowhere else.
- `python3 scripts/check-claude-refs.py check --root .` exits 0. It exits non-zero when a
  scratch file under `claude/.claude/docs/` holds the words "pass plan".
- `ls -l ~/.claude/docs/voice/approval-brief.md` fails, and
  `git grep -n 'approval-brief' -- claude/.claude` prints nothing.
- `jq -r '.hooks.PreToolUse[].hooks[].command' ~/.claude/settings.json` names
  `claude-git-guard`, each script it names exists, and a force-push to `main` is refused.
  `command -v claude-merge-guard` prints nothing.
- `claude-tooling-sync verify` and `bash scripts/gate.sh` exit 0.

## Estimates

Minutes are priced from `research/2026-11-20-process/measured-minutes.md`. Across 20 measured
passes, the median was 8.75 minutes for each step, with a range of 5.0 to 23.3. Pricing by step
count missed by a median of 23 percent, the best of four methods. The report warns that the 20
passes come from one author, one repo, and four weeks, and says not to quote its decimals as law.
It doesn't say whether its minutes include CI waits, so this table lists each task's waits
beside its minutes. The table uses 9 minutes a step and rounds each product to the nearest five.

A build session's steps are the rows of its task's table, plus one for its gate and one for its
review. An attended task's steps are its rows plus one for what follows the merge. Groundwork
has one more for the probe, and the last pull request one more for the commit after it. Memory
stores has four numbered steps and no merge. A row can cover several files, so the count is
coarse.

| Task | Steps | Minutes | Waits it drives | Time clause |
| --- | --- | --- | --- | --- |
| Groundwork | 6 | 55 | none | attended |
| The process skill | 8 | 70 | 24 evaluation sessions | 140 |
| The switch | 9 | 80 | none | attended |
| Personal skills | 12 | 110 | 168 evaluation sessions | 220 |
| Configuration cleanup | 14 | 125 | none | 250 |
| The plugin | 11 | 100 | CI on each push, and the plugin's evaluations | 200 |
| Survey | 8 | 70 | 24 evaluation sessions | 140 |
| Memory stores | 4 | 35 | Geoff's answer on the list | attended |
| Retiring the old process, first pull request | 18 | 160 | none | 320 |
| Retiring the old process, second pull request | 8 | 70 | none | attended |

A time clause is twice the task's minutes. It ends a run that has gone wrong, and the session
writes what is left into its pull request. Of the 20 measured passes, a cap at twice the planned
minutes would have stopped one.

No clause in the table includes a wait. The plugin's CI is short enough to ignore: its last 17
successful runs took 13 to 30 seconds each. The length of an evaluation session isn't measured
yet. The process skill's task runs 24 and records how long they took. If it reaches its clause
first, it ends as any task does, and a fresh session finishes the evaluations. Before Geoff's
session launches personal skills, survey, or the plugin, it adds the measured time for that
task's evaluations to its clause and says so.

## When something goes wrong

| What happens | What follows |
| --- | --- |
| The probe shows a permission prompt, or the session stalls | `denyInsteadOfPrompting` doesn't reach a background session. Tasks run as the core build did: Geoff's session cuts the worktree and makes the edits under `.claude`, and a build session does the rest. Question 6 goes back to Geoff. |
| The classifier refuses an edit under `.claude` with the entry in place | The session leaves that step and lists it. Geoff's session makes the edit from the pull request's text. |
| The probe's worktree doesn't start from `origin/main` | Geoff's session cuts each worktree from `origin/main` itself, and each goal tells the session to commit and push without asking. |
| A task reaches its time clause | It commits, pushes, and writes what is left in its draft pull request. Geoff's session launches a fresh session on that branch. |
| The reviewer returns a fix verdict twice | The findings are listed in the pull request for Geoff. |
| A hook blocks every Bash call after a pull | A hook's line in the settings names a missing script. Geoff runs `stow -R bin` in `~/.dotfiles` from a plain shell, or `git -C ~/.dotfiles revert` on the merge. |
| The merge prompt doesn't appear after the switch | The session stops merging and says so. `jq '.permissions.ask' ~/.claude/settings.json` shows whether `apply` ran. |
| A done item can't be met | The session marks it unmet with the reason. It never edits the item. |
| A new stop appears | It gets a row in `~/Projects/cc-desk/docs/follow-ups/desk-round-lessons.md` at once, with the change it calls for. |

Limits: four working sessions on pavilion; 4,000 characters in a goal; 120 lines in the global
file; 500 lines in a `SKILL.md`; 1,536 characters in a description.

## What done looks like

When all nine pull requests have merged, Geoff can check the whole of it:

- `~/.claude/skills` holds `building-from-specs` and no skill of the old process.
- He approves a pull request by number, his session runs `gh pr merge`, and one prompt appears.
- A background session that tries a merge is refused and keeps working.
- No live file in the three repos holds a retired word, apart from the two parked lines in
  `settings.json`, and the workstation's gate fails if one returns.
- The alias words stay in two live files: the global file's line for project files and the
  opening of `building-from-specs`.
- The table under [Where each mechanism comes from](#where-each-mechanism-comes-from) has no
  row labeled invented without a reason.

## What is left to the builder

- The wording of each rewritten description and each reworded line, within the standards named.
- The four queries in each `evals/evals.json`, and the expected behaviors of each.
- How a build session starts each evaluation session. The process skill's task settles it and
  writes it in its pull request for the tasks after it.
- How Geoff's session runs `update-skills` without touching the main checkout.
- Which repo's path the three fixture commands name.
- How far each plugin description is trimmed, so long as the listing fits.
- Whether `mail-tend`'s re-sort becomes a reference file or a marked step.
- The `paths` globs in `rules/vale.md`.
- The order of steps inside a task.

Three calls that the old files left unstated are settled in the skill text. A pull request goes
back by a fresh session on the same branch. A "couldn't finish" note lives in the draft pull
request. A task session never writes `STATUS.md`. Two are left open on purpose: task sessions
keep whatever tools their launch gives them, and a session decides for itself whether its steps
run through subagents.

## Found and not built

These are outside what this spec changes. Each is recorded, and none is built here.

- The `dubplate-pass` skill and the site and cairn project files point at `pass-core`. The
  global file's line for project files covers them until those repos move.
- The server-work auto-mode entry says "an approved pass plan". Server work is parked.
- Five setup-tooling grants outlived their work. Removing a grant belongs in a checklist a
  session runs when its task ends, which is later work.
- Three `initiative.yaml` files still say `proposed`.
- Two `curl` commands in household-it match no allow rule.
- poplar sets `bypassPermissions`.
- An unidentified node process listens on `127.0.0.1:7931`.
- Of the memory folders, 249 of 264 are empty, and one holds a leftover `.tmp` file.
- `golang-spf13-cobra` pre-approves more commands in `allowed-tools` than it runs. The skill is
  a copy, and an update would overwrite a hand edit. The fix belongs in its source repo or in
  the workstation's list.
- The plugin's `scripts/check-references.mjs` skips every file named `SKILL.md`. The one file
  that skip hides is `daisyui/colors/SKILL.md`, also a copy.
- `brainstorming` still has an entry in the workstation's list, though it is kept by hand. A
  run of `update-skills brainstorming` would overwrite it, this spec's edits included.
- The email address and the project number of question 5 sit in other tracked files of the
  workstation repo and in its history.

## Calls Claude made

Method and session-behavior calls are Claude's. Each is listed so Geoff can overrule it.

- The process skill is a personal skill named `building-from-specs`, not a plugin skill, because
  its rules name Geoff and workstation tools that the plugin's scan forbids.
- A task is launched from the repo's main checkout so that Claude Code makes its worktree. The
  docs say a session inside a worktree someone else made "still asks before committing".
- The launch passes `worktree.baseRef` as `fresh` for that session only. The standing setting
  is `head`, and a task must start from `origin/main`.
- Each goal carries a time clause at twice the task's minutes, with no cap across the spec.
  Geoff saw this as a proposal and didn't correct it.
- Minutes are priced by step count at 9 minutes a step, and a step is a row of the task's
  table. Evaluation time is added to a clause once the first task has measured it.
- Four craft rules had no home but a `pass-core` reference: where new infrastructure runs, that
  a test never cuts a release candidate, the scoped backlog sweep at each design, and running
  each check once before approval. All four are in the new skill's spec-writing reference.
- The process skill and the switch merge in one sitting, because the new skill is live before
  the global file names it.
- `task-report` starts as a two-line script that runs `pass-report`, so the skill's text is
  true from its first day. The last task makes it the real file.
- `claude-merge-guard` is removed by a direct commit after the last apply, never inside a pull
  request, so the live settings never name a missing script.
- The gate's `skill-caps` leg and the `--skill-caps` mode of `claude-context-budget` go with
  `pass-core`, because all seven caps they hold are for its files.
- A done item that reads the live workstation is checked by Geoff's session after the merge
  and stays out of the build session's goal.
- Tasks are independent and start from the default branch, until Geoff rules on tasks that
  build on another task's branch.
- Geoff's session edits settings, the global file, shell startup files, memory, and the two
  lists under `claude/.claude/tooling/`. Build sessions edit the rest. The lists are his
  session's because `vendored-skills.json` decides whose code is fetched into every session.
- The old process is two lists of words, defined once under [The old words](#the-old-words).
  The retired words leave every live file and join the gate's list. The alias words stay in two
  files until the other repos move.
- The last task takes two pull requests. The build session's removes the old words from the
  files it may edit. Geoff's session's deletes the two `cc-desk` skills, takes the survey
  release, and edits the lists and the hook's settings line.
- Nine tasks give nine pull requests. The Memory stores task needs one direct commit and no
  pull request, and the last task takes two.
- A copied plugin skill gets no hand edit but its description, and the workstation's list
  mirrors that description. Two audit findings in copied skills are recorded and not built.
  `brainstorming` is kept by hand, so its edits stand.
- `${CLAUDE_SKILL_DIR}` goes in `brainstorming/SKILL.md` once, and `visual-companion.md` uses
  the path from there. The docs fill the variable in only in the skill's `SKILL.md`.
- Evaluations use the file format on the skill authoring page, with results under
  `evals/results/<date>/`. `writing-voice`'s older evaluation file stays as it is.
- Memory stores begins with a list for Geoff, because the `/home` store predates the core build
  and a file about the old process shouldn't be copied into the store sessions load.
- The spec's search for the 12 personal skill folders is wider than the retired words, since
  those skills also say "planner" and "a pass".
- The merge command in the skill text has no `--delete-branch`. That flag also deletes the
  local branch, and git refuses to delete a branch that a worktree still holds. The skill
  removes the worktree, the local branch, and the remote branch, in that order.
- The switch is one pull request, and it reworks two sentences of `pass-core` so the old skill
  agrees with the new merge rule while it still exists.
- The global file carries one line for project files that still name the old process.
- `cairn-pass` and `site-pass` keep their names.
- `pass-report` becomes `task-report` and stays as the source of measured minutes. Its score
  keys keep their names, so the 20 measured passes stay readable.
- The limit of four working sessions on pavilion carries into the skill until the later work on
  task chains replaces it. The 85 percent check is dropped, as Geoff ruled.
- Two `ask` rules cover the merge forms a session usually writes. The docs say a rule "isn't a
  security boundary around the program" and name a `PreToolUse` hook for reading the whole
  command. The guard is that hook: it keeps its merge check and answers `"ask"`, so
  `gh -R <repo> pr merge`, `/usr/bin/gh pr merge`, and `sudo gh pr merge` also stop at a prompt.
  The approved spec left those forms to auto mode's classifier. The switch's review found that
  `gh` accepts them, and this call changed on 2026-11-21. A wider `ask` pattern would also
  prompt on searches that contain the word "merge".
- `go-ship` falls back to the bundled `/simplify`. The other choice was to declare a dependency
  on a plugin the workstation no longer installs.
- The reviewers keep Bash, and their descriptions say what is true. `claude-sudo-clear` stays in
  the shell wrapper. A `SessionEnd` hook would do the same job with the same side effect, so
  the move gains nothing.
- `claude-context-budget`, `check-claude-refs.py`, `claude-worktree-busy`, and
  `claude-memory-write-check` stay. Each does more than the native feature nearest it.
- The one question the rulings file owes Geoff, where cc-desk's scheduled check-ins come against
  the rewrite of Move, is about later work. It is recorded in `STATUS.md` and not asked now.
- Standing answers 2 and 3 carry into the skill's table. Answer 11's text leaves with
  `pass-core`. Two research reports disagree on its group, and the groups are parked.

## Where each mechanism comes from

| Mechanism | Label | Source |
| --- | --- | --- |
| A spec, then a fresh session that builds from it | Documented | Best practices: explore, plan, then implement in a fresh session |
| `/goal` with a turn or time clause | Documented | `/goal` page: "include a turn or time clause in the condition" |
| Background sessions and `claude agents --json` | Documented | Agent view page |
| A worktree Claude Code makes for a background session | Documented | Agent view page, "How file edits are isolated" |
| `worktree.baseRef` | Documented | Worktrees page, "Choose the base branch" |
| A fresh subagent that reviews against the spec | Documented | Best practices; subagents page |
| An `ask` rule on `gh pr merge` | Documented | Permissions page: an ask rule prompts "even in `auto` mode" |
| `permissions.denyInsteadOfPrompting` through `--settings` | Documented | Settings reference, v2.1.319 or later |
| Auto mode with an `autoMode.allow` entry | Documented | Auto-mode configuration page |
| Auto mode, `denyInsteadOfPrompting`, and the entry used together for a build session | Assembled from documented pieces | The three pages in the rows before this one, and the probe |
| Skill descriptions, `paths`, `disable-model-invocation`, `${CLAUDE_SKILL_DIR}`, the listing budget | Documented | Skills page; skill authoring best practices |
| Evaluation files in the page's format, at least three a skill, on three models | Documented | Skill authoring best practices, with its checklist |
| Running each evaluation with the skill on and off, and the results table | Assembled from documented pieces | The same page says no built-in runner exists; `skillOverrides` is in the settings reference |
| The list of retired phrases that the gate reads | Invented | `check-claude-refs.py` already reads it, and no documented feature fails a gate on a word |
| `claude plugin eval`, `claude plugin validate` | Documented | Plugin evaluations page and plugins reference |
| A skill whose body points at docs outside its folder (`bluefin-admin`) | Assembled from documented pieces | Skills page. Moving the leaves into the skill would collide with another session's work. |
| One simple loop for a solo developer, with no planner, executor, and reviewer roles | Community | `research/2026-11-20-workstation/community-practice.md`, which names each source |
| A draft pull request that carries the "couldn't finish" note | Assembled from documented pieces | Agent view page: Claude opens a draft pull request |
| The `task-score` comment and `task-report` | Invented | Kept because Geoff asked for estimates priced from measured minutes, and no documented hook carries a clock field |
| `claude-git-guard` (merge prompt, force-push, and staging) | Assembled from documented pieces | Hooks page: a `PreToolUse` hook can deny a call or answer `"ask"`, which "sends the tool call to the permission prompt" in auto mode |
| `claude-context-budget`, `check-claude-refs.py`, `claude-worktree-busy`, `claude-memory-write-check` | Invented | Each is stricter or wider than its native counterpart, as `config-audit.md` section 3 shows |
| The limit of four working sessions | Invented | Geoff's standing rule for pavilion, until the later work replaces it |

## Each stop in the lessons file

One line for each of the 28 rows in `~/Projects/cc-desk/docs/follow-ups/desk-round-lessons.md`.
"Skill" means a sentence in the process skill's text, and "reference" its spec-writing
reference.

| Row | The stop | What this spec does |
| --- | --- | --- |
| 1 | Pass 2 parks on its estimate | Skill: no retry count or size ends a task, only the time clause |
| 2 | Pass 2's review escalates | Skill: tasks start from the default branch; the review rule. A task that builds on another task's branch waits. |
| 3 | Pass 3 parks on its estimate | As row 1 |
| 4 | Pass 5 parks past the clock | Skill: a session never asks; when a rule's condition fails it ends and says what is left. The forecast waits. |
| 5 | Pass 5 parks on a leftover live session | Skill: a session stops each session it started before it ends |
| 6 | Pass 5 parks on sessions that its run started | As row 5 |
| 7 | Pass 5's session idles after its stop | Skill: the report and the end come in one turn |
| 8 | Pass 5's fix review escalates | Skill: the goal stays as approved; the review names its commit |
| 9 | A second session's question holds the review | Skill: no session asks Geoff a question, and none plays conductor |
| 10 | The last review escalates on a listing window | Skill: a claim quotes its check, inside the window it names. A script that checks a body waits. |
| 11 | Live runs leave the real state folder full | Skill: a task removes what its runs added |
| 12 | The tooling sync re-escapes the manifest | Configuration cleanup: `ensure_ascii=False` |
| 13 | Pass 6 parks on its estimate | As row 1 |
| 14 | A session commits in another's live worktree | Skill: only a task's session writes on its branch |
| 15 | GitHub Actions stops on billing | Skill: the launch check that each repo can run CI; the annotation rule |
| 16 | A plan reaches launch with no evidence line | The launch guard goes. Reference: the author runs each check before approval. |
| 17 | A start line would refuse the launch it guards | Reference: start conditions are tested against the day's sessions |
| 18 | The Move design was overtaken | Reference: a spec names the sessions working in a repo it changes |
| 19 | The desk opens on the API key | Reference: a step Geoff runs is rehearsed from `bash -lic` |
| 20 | The terminal link opens nothing | Skill: a closed follow-up quotes the check that proves it |
| 21 | Two pull request bodies sent back | Skill: one body layout. A script that checks it waits. |
| 22 | Pass 6 parks on its estimate again | Reference: minutes include the waits a task drives |
| 23 | A fixture command the Bash tool blocks | Reference: no command is named until it has run once in Claude Code |
| 24 | A report's session can't launch the next | Skill: Geoff's session launches every task, and a task session ends with its report |
| 25 | An old session tries to open an open one | As row 24. Finding a session by its checkout waits for the later work. |
| 26 | The 1.1 design is set aside | Reference: test what exists against a constraint before designing |
| 27 | The brainstorm offers an undocumented approach | Reference: read the docs page first, and label each option |
| 28 | The brainstorm plans under `pass-core` | Reference: ask whether the old process governs the build. The global file drops the exemption with the process. |

Rows whose full answer is the timer script or the page (1 to 6, 15 to 17, 19, 24, 25) get their
sentence here and their tool later.

<details>
<summary>What was read</summary>

- Geoff's rulings: `specs/2026-11-20-process-decisions.md`.
- Research: the nine reports in `research/2026-11-20-process/` and the four audits in
  `research/2026-11-20-workstation/`, each audit checked against the files it names.
- The core design: `~/Projects/cc-desk/docs/specs/2026-11-20-core-design.md`.
- Anthropic's pages, read again on 2026-11-20 from the saved copies: best practices, `/goal`,
  skills, skill authoring best practices, memory, permissions, permission modes, auto-mode
  configuration, settings, the settings reference, agent view, worktrees, the CLI reference,
  subagents, plugins, and plugin evaluations.
- Claude Code on this workstation is version 2.1.330.

</details>
