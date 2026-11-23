# Spec: merge a Show pull request without Geoff's word

Status: draft, not approved.

Today every pull request waits for Geoff. A one-line skill fix reaches him the same way as a change to sign-in
code. This spec gives each task of a spec one of two tiers, set by Geoff when he approves the spec. An Ask task
merges on his word, as task 1 of the task-chains spec leaves it. A Show task merges with no word from him once
a new script, `claude-show-merge`, finds every condition met. His next sitting report lists that merge and its
undo. One condition missed turns the pull request into an ask. Two tasks build this in `glw907/workstation`
after task-chains task 1 merges. A third step, in Geoff's session, proves it on two stub tasks in
`glw907/cc-desk-scratch`.

## Intent

Geoff, on 2026-11-23: "I'm getting a lot of smaller PRs with very obvious approval. And that definitaly causes
approval fatigue." And: "small approvials that are mere formality are presenting in the same way as much more
consiquntial decisions." Asked for the accepted fix, he chose tiers set in each spec, "assuming that represents
best practice." He asked for the change to be "baked thoughtfully into out broader claude infastructure."

Asked which changes may merge without him once checks and the review pass, he chose "Skills too": anything
outside sign-in, data, settings, hooks, permission rules, the git guard, and `building-from-specs` itself, with
the risk that a bad skill edit runs in unattended sessions until he reads the report and reverts it. He read the
design played back and answered "This looks good."

Goals:

- Each task of a spec carries a tier, and Geoff approves it with the spec. Ask is the default.
- A Show pull request merges from the open session's chain tick, or at the start of Geoff's next sitting, with no
  word from him, when every check of `claude-show-merge` passes. The script makes the call, never a model's
  judgment.
- Any missed check turns that pull request into an ask, by task-chains task 1's rule, with the failed check named.
- Each Show merge reaches Geoff in his next sitting report in plain words, with its undo. His "Revert" undoes it.

Non-goals: Dependabot and maintenance pull requests (no spec covers them), survey releases (they stay Ask), a
Show tier in a repo the script has no map for, and PR CI for the three sites that lack it.

The work fails if a pull request merges without Geoff's word while it touches a path the repo lists as Ask-only,
changes a file its task's `Files:` line doesn't name, or comes from a task the approved spec marks Ask. It also
fails if a task session can merge through the script, or if a Show merge never reaches Geoff's report.

## How the tiers work

### A task's tier

The heading of each task's section is followed by these lines, which Geoff approves with the spec:

```text
Name: <the task's launch name>
Tier: show
Files: `<glob>`, `<glob>`
```

`Tier:` reads `show` or `ask`, and a task with no `Tier: show` line is Ask. A Show task needs a `Files:` line
whose backticked globs cover every path it will change. A task can be Show only when its repo has an Ask-only
list and none of its `Files:` globs reaches into it. `claude-show-merge --ask-only <owner/repo>` prints that
list, one glob per line, and exits 1 for a repo with no list. A task's section runs from the heading above its
`Name:` line to the next heading of the same or higher level.

The Ask-only lists live in the script. They follow one rule: a Show task never touches sign-in or data, settings,
hooks or their scripts, permission rules, the files that load into every session, the git guard,
`building-from-specs`, the script itself, or the gate and CI that let a Show merge through. Tests stay Show,
since the gate runs them and a reviewer reads them.

| Repo | Ask-only globs |
| --- | --- |
| `glw907/workstation` | `claude/.claude/settings.json`, `claude/.claude/CLAUDE.md`, `claude/.claude/rules/**`, `claude/.claude/tooling/**`, `claude/.claude/skills/building-from-specs/**`, `claude/.claude/skills/cairn-pass/**`, `claude/.claude/skills/site-pass/**`, `.claude/skills/dotfiles-pass/**`, `.github/**`, `scripts/**`, `secrets/**`, `bash/.bashrc`, `bluefin/**`, and in `bin/.local/bin/`: each hook script `settings.json` runs (`claude-awake-touch`, `claude-block-pass`, `claude-context-budget`, `claude-denied-log`, `claude-git-guard`, `claude-memory-write-check`, `claude-notify`, `claude-secret-guard`, `claude-tail-guard`, `claude-tierguard`), each secrets script in `dotfiles-pass` "Paths", `claude-show-merge`, `cairn-run-gate`, `ci-green`, and `ci-green-lib.mjs` |
| `glw907/cairn-cms` | the `auth-data` and `runner` globs of `cairn-build` "Risk classes" (`.claude/skills/cairn-build/SKILL.md` in cairn-cms), plus `.claude/**`, `CLAUDE.md`, and `**/CLAUDE.md` |
| each site repo (ecxc-ski, 907-life, aksailingclub-org, cairn-pub) | that site's `auth-data` and `runner` globs in `site-pass` "Risk-class path map", plus `.claude/**`, `CLAUDE.md`, and `**/CLAUDE.md` |
| `glw907/cc-desk-scratch` | `.github/**`, `scripts/**`, `.claude/**`, `CLAUDE.md` |

Each repo is keyed by the `nameWithOwner` of its main checkout's `origin`: `glw907/workstation` for
`~/.dotfiles`, `glw907/cairn-cms`, `glw907/ecxc-ski`, `glw907/907-life-legacy` for the 907-life checkout,
`glw907/aksailingclub-org`, `glw907/cairn-pub`, and `glw907/cc-desk-scratch`. Brace globs are written out, because
`PurePath.full_match` doesn't expand them.

### What `claude-show-merge` checks

`claude-show-merge <owner/repo> <number> --spec <path> --task <name>` runs every check below, even after one
fails, and prints one line for each: `pass <check>`, `fail <check>: <reason>`, or `wait <check>: <reason>`. It
merges only when all pass. `--dry-run` runs every check, merges nothing, and writes no record.

1. Task session: `CLAUDE_TASK_SESSION` isn't `1`. A task session can't merge with it.
2. Repo: the repo has an Ask-only list.
3. Earlier result: the record holds no `ask` row for this pull request. Once a pull request falls to an ask, it
   stays one.
4. Spec: the spec file is tracked in its git repo with no uncommitted change. Its `Status:` line starts with
   `Status: approved`. One section holds `Name: <task>`, and that section holds `Tier: show` and a `Files:` line
   with at least one backticked glob. The spec as last committed at or before the pull request's `createdAt` has
   the same `Status:` start and the same `Tier:` and `Files:` lines for the task. A change made after the task
   started counts for nothing.
5. Session: the newest entry named `<task>` in `claude agents --json --all` reads `done`. An entry still at work,
   or no entry because the task ran on the other host, is a wait.
6. Pull request: `state` is `OPEN`, `isDraft` is `false`, `mergeable` is `MERGEABLE`, and `baseRefName` is the
   repo's default branch from `gh repo view --json defaultBranchRef`. The script keeps the `headRefOid` it read
   here.
7. CI: `gh pr checks` exits 0. Exit 8, checks still running, is a wait. A retargeted child reruns its CI, so it
   waits a tick or two. In `glw907/workstation`, which has no PR CI, `no checks reported` passes too, the same
   exception as task-chains' ready check.
8. Review: the `task-score` comment parses as JSON and reads `"verdict":"accept"`, `"openFindings":0`, and
   `"unmet":0`.
9. Body: the body holds no `## Before merge` heading and no `## For Geoff` heading, and it holds the line
   `From spec <path>, task <name>.` with the same path and name the script was given.
10. Files: every path in `gh api repos/<r>/pulls/<n>/files --paginate`, `filename` and `previous_filename`
    both, matches a `Files:` glob, and none matches an Ask-only glob.
11. Current: `gh api repos/<r>/compare/<head>...<default>` lists the files changed on the default branch since
    the merge base, and none of them is a file the pull request changes. A list of 300 files, the API's most,
    fails. For a child (the body's first line reads `Built on #<p> at <sha>`), pull request `<p>` has merged and
    its `headRefOid` is `<sha>`.

When all pass, it runs `gh pr merge <n> --repo <r> --merge --match-head-commit <sha>`, with the sha check 6 kept,
so a push after the checks stops the merge. It prints `merged <r>#<n> <merge sha>` and
`undo: git revert -m 1 <merge sha>`.

| Exit | Meaning | What follows |
| --- | --- | --- |
| 0 | Merged, or every check passed under `--dry-run` | The caller runs the cleanup steps. |
| 1 | A check failed | The pull request is an ask, with the failed check named. |
| 2 | A read failed: a `gh` or `claude` error, or a moved head at the merge | The next tick tries once more. A second exit 2 for the same pull request becomes exit 1. |
| 3 | A check waits | The next tick tries again. Nothing counts against the pull request. |

When results differ, the first of 1, 2, 3 in that order sets the exit. A failed check outranks a failed read,
because a known failure is already an ask.

### The record

Each run that isn't `--dry-run` and doesn't exit 3 appends one JSON row to `~/.local/state/claude-show-merge.jsonl`.
The row holds the time, repo, number, spec, task, result (`merged`, `ask`, or `retry`), the failed checks with
their reasons, and the merge commit. Exit 2 writes `retry`, and the second exit 2 writes `ask`. On `merged` and
`ask` the script also comments on the pull request with the same line it printed, so the reason shows on GitHub.

`claude-show-merge --report` prints, in plain words, each `merged` and `ask` row written since the last
`--report`, the merged ones with their undo line. It then writes the time it ran to
`~/.local/state/claude-show-merge.reported`. A merge that no session reported stays in the next report, so a
loop that dies early loses nothing.

### Where it runs

The chain tick of task-chains runs it. After step 3 finds a task ready, a task whose section reads `Tier: show`,
and whose parent has merged or that has none, goes to `claude-show-merge`, with `--spec` and `--task` read from
the body's `From spec` line. On exit 0 the tick runs "Merging" steps 4 and 5 (pull, retarget children, clean up)
and the repo pass skill's "After a merge". On exit 1 the task waits for Geoff, and its children still launch, as
for any ready task. Step 6 doesn't end the chain while a Show pull request exited 2 or 3 on this tick. The tick's
sitting note carries the output of `claude-show-merge --report`.

With no tick, Geoff's session starts each sitting the same way, before it asks about anything else. It lists
open pull requests with `gh search prs --owner glw907 --state open --json repository,number,body`, runs the
script on each whose body holds a `From spec` line and whose task section reads `Tier: show`, and shows him the
`--report` output.

### Undo

Geoff says "Revert" for a Show merge in his terminal. His session branches from the default branch, runs
`git revert -m 1 <sha>`, runs the gate, opens a pull request, and merges it with `--merge`, his word approving
both. Then it cleans up as "Merging" says. A revert that conflicts becomes an ask.

### Settings

`permissions.allow` gains `Bash(claude-show-merge *)`. With that rule, the script's checks judge the merge and
auto mode's classifier never sees it. `autoMode.allow[1]` allows skill and script changes in a dotfiles worktree
because "each change takes effect only after Geoff merges its PR". Show makes that untrue. Its clause becomes: "each
change takes effect only after its pull request merges, on Geoff's word or, for a task his approved spec marks
Show, through `claude-show-merge`, which refuses every settings, hook, permission, and guard path."
Settings stay Ask, so `autoMode.allow[2]` keeps its clause.

Task-chains' follow-up sets `CLAUDE_TASK_SESSION=1` on each task session's launch line. With it set,
`claude-git-guard` denies any command that runs `claude-show-merge` without `--ask-only`, `--help`, or
`--dry-run`. The guard reads the variable from its own environment, so an inline `CLAUDE_TASK_SESSION=0` doesn't
help. It finds the script as the command word of any part of a command line: after `cd ... &&`, after `env` or
variable assignments, as a path ending in `/claude-show-merge`, after `python3` and its flags, or inside a
`bash -c` or `sh -c` string. A command that only names it as an argument, such as `grep claude-show-merge`, passes.

## Limits

- Show applies only in the seven repos the table lists. Three of them, ecxc-ski, 907-life, and cairn-pub, have no
  PR CI, so check 7 fails there and their tasks stay Ask until they have it.
- The compare and pull request files lists stop at 300 and 3,000 files, and a list at the cap fails.
- A read failure is retried once, at the next tick, 15 minutes later and up to 7.5 minutes late.
- The tick merges every passing Show pull request it finds, in chain order, with no cap per tick.
- A revert has no time limit. One that conflicts goes to Geoff as an ask.
- A task's session entry lives on the host that launched it. On the other host, check 5 waits, so a Show pull
  request merges only from a session on the host that launched its task.
- A wait has no limit of its own. The chain stays open while one lasts, and the task-chains limits on the loop
  still end it.

## Approaches

How a Show pull request merges with no one there:

| Option | Label | Trade-off |
| --- | --- | --- |
| A checking script behind an exact allow rule | Assembled | Every condition is code with tests. The script is new code, Ask-only itself. |
| An `autoMode.allow` line in prose | Documented | No new code. The classifier judges each merge, and "Merging a pull request no human has approved" is on its default block list. AWS says to "use deterministic logic (policy engines, rule-based classifiers) as the authoritative signal". |
| GitHub auto-merge, `gh pr merge --auto` | Documented | It waits only on required checks under branch protection. It can't read the review's `task-score` or the spec, and the workstation and three sites have no PR CI. |
| Show pull requests wait for the sitting and merge on one word for the batch | Assembled | No allow rule. Each sitting still needs a word, so this stays the fallback. |

The pick is the script. It is the pattern `vps-conventions` sets for a step auto mode won't clear, "a reviewed
repo script with an exact allow rule".

Who picks the tier:

| Option | Label | Trade-off |
| --- | --- | --- |
| Geoff, when he approves the spec | Assembled from Ship/Show/Ask | His review moves to the design. Anthropic's trustworthy-agents post describes it as a shift of "the user's level of oversight from the individual step to the overall strategy." |
| The task session, as Ship/Show/Ask has it | Community | The article lets the author choose. An unattended session would choose the tier that skips Geoff's check. |

Geoff chose the spec.

## Mechanisms and their sources

- Ship/Show/Ask is community practice (Rouan Wilsenach,
  <https://www.martinfowler.com/articles/ship-show-ask.html>): Show is "open a pull request for review, but merge
  into mainline immediately". `building-from-specs` "Direct changes" is Ship already.
- Risk-tiered approval is documented in AWS AGENTSEC04-BP02
  (<https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec04-bp02.html>): "Risk-tiered
  approval pauses agents only for the decisions where human judgment actually changes the outcome." Its
  anti-pattern is routing every action through review, "creating reviewer fatigue and rubber-stamp approvals".
  Anthropic's auto mode post (<https://www.anthropic.com/engineering/claude-code-auto-mode>) says of permission
  prompts, "users accept 93% of them anyway".
- Allow rules come before the classifier, which is documented on the auto mode page
  (<https://code.claude.com/docs/en/auto-mode-config.md>): "The classifier is a second gate that runs after the
  permissions system." `autoMode.classifyAllShell` would "suspend your Bash and PowerShell allow rules while auto
  mode is active", and it is unset here. Backlog #50 is the precedent: `Bash(approval-queue merge *)` took
  merges past the classifier.
- `gh pr merge --match-head-commit SHA` is documented in `gh pr merge --help` today: "Commit SHA that the pull
  request head must match to allow merge".
- The compare API returns the merge base and the files changed since it. Today
  `gh api repos/glw907/workstation/compare/e030621f...main` printed status `diverged`, `ahead_by` 1, 1 file, and
  merge base `0b2589bb`. The pull request files API returned `status`, `filename`, and `previous_filename` for
  pull request 271.
- `PurePath.full_match` matches `**` across folders on the host's Python 3.15.2:
  `claude/.claude/skills/x/SKILL.md` matched `claude/.claude/skills/**`, and both `a/b/hooks.server.ts` and
  `hooks.server.ts` matched `**/hooks.server.ts`.

## Assumptions

- The exact allow rule runs the script from a loop turn with no refusal. The docs and #50 support it, but no
  loop turn has run a merge this way. Step 3 tests it. It can't go first, because it needs the script and the
  rule live. If it fails, the batch fallback in the approaches table replaces the tick's Show merge, as a wording
  change to "Chains" and "Merging" approved with this spec.
- The git guard lets the script through today. Fed
  `claude-show-merge glw907/cc-desk-scratch 7 --spec /x.md --task t`, it printed nothing and exited 0, with
  `CLAUDE_TASK_SESSION` unset and set to `1`. Task 1 adds the deny.
- Task-chains' follow-up sets `CLAUDE_TASK_SESSION=1` on every task session's launch line. Its spec says so
  (task 1, "The merge prompt"), but `git grep CLAUDE_TASK_SESSION` on `origin/worktree-task-chains` finds nothing
  yet. This spec's tasks wait for that follow-up to merge.
- The tick's ready check and the script read the same fields. Task-chains task 1's step 3 reads the session
  state, the draft flag, `gh pr checks`, and the `task-score` JSON. The script reads them again, so a stale tick
  read can't merge.

## Files

Searches on `main` across `~/.dotfiles/claude`, `bin`, `.claude`, and `scripts`, with `--exclude-dir=worktrees`,
leaving out evaluation results and archived plans:

- `grep -rIl -F 'approves the pull request'`: 1, `claude/.claude/CLAUDE.md`, which changes (task 2).
- `grep -rIl -F 'merges its PR'`: 1, `claude/.claude/settings.json`, entries `autoMode.allow[1]` (changes) and
  `[2]` (stays).
- `grep -rIl -F 'gh pr merge'`: 5. `building-from-specs/SKILL.md` "Merging" step 3 stays for Ask, and "Chains"
  and "Merging" gain the Show path (task 2). The `ask` rules in `settings.json` leave in task-chains' follow-up.
  `survey/releasing.md` stays Ask. `evals/evals.json` gains a Show case (task 2). `claude-git-guard` gains the
  deny (task 1).
- `grep -rIl -F 'by number'`: 4, all rewritten by task-chains task 1. Nothing here.
- `grep -rIl -e 'Geoff merges' -e 'merge prompt'`: 2, `settings.json` (above) and `SKILL.md` (task-chains'
  follow-up removes the prompt text).
- `grep -rIl -F 'Tier:'` and `grep -rIl -F 'show-merge'`: 0 each.
- `grep -n 'pytest' scripts/check.sh`: line 149, whose path filter gains `claude-show-merge` (task 1).

The repo pass skills `cairn-pass`, `site-pass`, and `dotfiles-pass` gain a pointer to `--ask-only` (task 2).
`cairn-build` in cairn-cms is read, not edited.

## Commands against the denials log

`~/.local/state/claude-denials.jsonl` holds 152 rows, 2026-11-01 to 2026-11-23.

| Command | Refusals | Reading |
| --- | --- | --- |
| `gh pr merge` | 1 | 2026-11-10, `[Merge Without Review]`. A Show merge runs inside the script, under the allow rule. |
| `gh pr view`, `gh pr checks` | 2 each | All rode with a merge. They run inside the script. |
| `claude agents` | 3 | Each rode with `claude stop`. |
| `git push origin --delete` | 1 | 2026-11-02, `[Git Destructive]`. `autoMode.allow[7]` now covers cleanup after "a merged pull request". |
| `stow` | 1 | 2026-11-01, `[Self-Modification]`. A refusal after a Show merge goes in the sitting note, and Geoff's session reruns it. |
| `claude-tooling-sync` | 2 | `apply` never follows a Show merge, because `claude/.claude/tooling/**` is Ask-only. |
| `claude --bg` | 2 | Launches are task-chains' and unchanged here. |
| `git revert`, `gh pr create`, `gh pr diff`, `gh search prs`, `env -u`, `git worktree remove`, `claude-show-merge` | 0 | |

## Task 1: build `claude-show-merge`

Name: show-merge-script
Tier: ask
Files: `bin/.local/bin/claude-show-merge`, `tests/test_claude_show_merge.py`, `scripts/check.sh`, `bin/.local/bin/claude-git-guard`, `tests/test_claude_git_guard.py`

The task builds in `glw907/workstation`, launched from `~/.dotfiles`. The script is stdlib Python run as
`python3 -I`, one file, per the workstation's tool rule. It does what "How the tiers work" says: the eleven checks,
the merge, the four exits, the record, `--dry-run`, `--report`, and `--ask-only`, with the table's lists. The
record and the report marker go under `$XDG_STATE_HOME`, falling back to `~/.local/state`, so the tests can point
them at a temporary folder. The tests put fake `gh` and `claude` on `PATH`. `claude-git-guard` gains the deny that
"Settings" describes, and its reason names the task-session rule.

Goal:

```text
Build task show-merge-script of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md by building-from-specs, with dotfiles-pass for the gate and checks. Below, $M is bin/.local/bin/claude-show-merge and $G is bin/.local/bin/claude-git-guard. Done when: 1. Each of `$M --help | grep -c -F -- --spec`, the same for `--task`, `--dry-run`, `--report`, and `--ask-only`, prints 1 or more. 2. `$M --ask-only <key>` exits 0 for each of glw907/workstation, glw907/cairn-cms, glw907/ecxc-ski, glw907/907-life-legacy, glw907/aksailingclub-org, glw907/cairn-pub, and glw907/cc-desk-scratch; it exits 1 for glw907/standards and glw907/907-life; and for glw907/workstation its output holds, as whole lines, every glob and script path the spec's table lists for that repo, checked by a test that carries that list. 3. `uv run --with pytest --no-project python -m pytest tests/test_claude_show_merge.py -q` passes, and the file holds at least these tests: for each of the eleven checks, a fixture that misses only that check, expecting exit 1 and that check's fail line, and for check 4 a second fixture whose working spec reads `Tier: show` while the copy committed at `createdAt` reads `Tier: ask`; for check 11, a child whose parent merged at another sha, a child whose parent merged at the named sha (pass), and a compare list of 300 files; waits, with checks pending (gh exit 8) and with no session entry, each expecting exit 3 and no record row; a failed read expecting exit 2 and a `retry` row, then a second run expecting exit 1 and an `ask` row; a head that moves between check 6 and the merge, expecting exit 2; one fixture with a failed check and a failed read, expecting exit 1; a full pass where the fake gh records `pr merge <n> --repo <r> --merge --match-head-commit <sha>` with the sha the fixture's check 6 returned, and a `merged` row; and `--report` printing that row once and nothing on a second run. A test also reads site-pass "Risk-class path map" and finds, in each site's list, the globs it names for every site plus those it names for that site, braces expanded, and none it names only for another site. 4. `env -u CLAUDE_TASK_SESSION $M glw907/workstation 271 --spec /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md --task task-chains --dry-run` exits 1, its output holds `pass task-session` and `pass repo`, and its `fail spec` line names the missing `Name: task-chains` section. 5. tests/test_claude_git_guard.py passes, and with CLAUDE_TASK_SESSION=1 it expects $G to deny each of `claude-show-merge glw907/x 7 --spec /x.md --task t`, `bin/.local/bin/claude-show-merge glw907/x 7 --spec /x.md --task t`, `python3 -I ~/.local/bin/claude-show-merge glw907/x 7 --spec /x.md --task t`, `bash -c 'claude-show-merge glw907/x 7 --spec /x.md --task t'`, `CLAUDE_TASK_SESSION=0 claude-show-merge glw907/x 7 --spec /x.md --task t`, and `cd /tmp && claude-show-merge glw907/x 7 --spec /x.md --task t`; to pass `grep -c claude-show-merge f.md`, `claude-show-merge --ask-only glw907/workstation`, `claude-show-merge --help`, and `claude-show-merge glw907/x 7 --spec /x.md --task t --dry-run`; and with the variable unset, to pass every one of them. 6. `grep -c -E 'claude-\(.*show-merge' scripts/check.sh` prints 1, the pytest leg's path filter. 7. `bash scripts/gate.sh` exits 0 from the worktree root, and `claude-tooling-sync verify` passes. 8. A fresh standards:diff-reviewer accepts the branch against the spec's "How the tiers work" and Task 1 with 0 open findings, and the pull request is ready. Or stop after 180 minutes.
```

Today, items 1 to 4 fail because `bin/.local/bin/claude-show-merge` doesn't exist (`test -x` exits 1, and
`ls tests | grep -c show_merge` prints 0). For item 5, the guard prints nothing and exits 0 on the plain spelling,
with the variable set and unset. Item 6 prints 0.

Reviewers: `standards:diff-reviewer`. Minutes: 90 (the measured median actual path for `workstation` is 45, plus
a gate's p90 of 13, plus 30 for a new script and its tests), so the clause is 180. Model: Opus at high. Waits for:
task-chains task 1 (pull request 271) and its follow-up, merged.

## Task 2: write the tiers into the skills

Name: show-tier-rules
Tier: ask
Files: `claude/.claude/skills/building-from-specs/SKILL.md`, `claude/.claude/skills/building-from-specs/references/writing-a-spec.md`, `claude/.claude/skills/building-from-specs/evals/evals.json`, `claude/.claude/CLAUDE.md`, `.claude/skills/dotfiles-pass/SKILL.md`, `claude/.claude/skills/cairn-pass/SKILL.md`, `claude/.claude/skills/site-pass/SKILL.md`

The task builds in `glw907/workstation`, launched from `~/.dotfiles`, in the agent-facing register
(`~/.claude/docs/voice/agent-facing.md`). It writes:

- `SKILL.md`: "Chains" gains the Show step from "Where it runs": the script's four exits, cleanup only on exit 0,
  the chain held open on exit 2 or 3, and `--report` in the sitting note. "Merging" gains the Show paragraph, the
  sitting run with no tick, and "Undo", citing the Ship/Show/Ask URL. "The pull request" gains the
  `From spec <path>, task <name>.` line, and its item 5 and the step list at the top say `## For Geoff` is left
  out when nothing waits.
- `writing-a-spec.md`: a task carries the `Name:`, `Tier:`, and `Files:` lines, and Show is allowed only by "A
  task's tier".
- `CLAUDE.md` "Work is built from specs": "Only the session Geoff is talking to merges, and only after he approves
  the pull request in his terminal, or, for a task his approved spec marks Show, when `claude-show-merge` passes."
- `dotfiles-pass` "Paths": `claude-show-merge` joins the unattended scripts, plus one line naming
  `claude-show-merge --ask-only glw907/workstation`. `cairn-pass` and `site-pass` each gain that line for their
  repos.
- `evals.json`: one case. The tick finds a ready pull request whose spec task reads `Tier: show`. The expected
  behavior is that it runs `claude-show-merge` with `--spec` and `--task`, runs no bare `gh pr merge`, asks
  Geoff nothing, and puts the `--report` output, with its `git revert -m 1` line, in the sitting note.

A task session leaves settings alone, so the pull request's `## Before merge` carries the "Settings" edits as
exact JSON, with this check: `python3 -I -c 'import json; s=json.load(open("claude/.claude/settings.json"));
print(s["permissions"]["allow"].count("Bash(claude-show-merge *)"), sum("after Geoff merges its PR" in a for a in
s["autoMode"]["allow"]))'` prints `1 1`. Today it prints `0 2`. Geoff's session applies them on the branch as a
commit, after his "Merge" and after the task's session has ended, then merges.

Goal:

```text
Build task show-tier-rules of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md by building-from-specs, with dotfiles-pass for the gate and checks. Below, $S is claude/.claude/skills/building-from-specs/SKILL.md, $W is claude/.claude/skills/building-from-specs/references/writing-a-spec.md, and "in Chains" or "in Merging" means piping `sed -n '/^## Chains$/,/^## /p' $S` or `sed -n '/^## Merging$/,/^## /p' $S` to the grep. Done when: 1. `grep -c -F 'Tier: show' $S` prints 1 or more, and `grep -c -F 'From spec' $S` prints 1 or more. 2. In Chains, `grep -c -F 'claude-show-merge'` prints 1 or more and `grep -c -F -- '--report'` prints 1 or more. 3. In Merging, `grep -c -F 'claude-show-merge'` prints 1 or more, `grep -c -F 'Revert'` prints 1 or more, and `grep -c -F 'git revert -m 1'` prints 1 or more. 4. `grep -c -F 'ship-show-ask' $S` prints 1. 5. `wc -l < $S` prints 270 or fewer. 6. Each of `grep -c -F 'Name:' $W`, `grep -c -F 'Tier:' $W`, `grep -c -F 'Files:' $W`, and `grep -c -F -- '--ask-only' $W` prints 1 or more. 7. `grep -c -F 'claude-show-merge' claude/.claude/CLAUDE.md` prints 1, and `grep -c -F 'only after he approves the pull request in his terminal.' claude/.claude/CLAUDE.md` prints 0. 8. `grep -c -F 'claude-show-merge --ask-only glw907/workstation' .claude/skills/dotfiles-pass/SKILL.md` and `grep -c -F 'claude-show-merge --ask-only glw907/cairn-cms' claude/.claude/skills/cairn-pass/SKILL.md` each print 1 or more, and claude/.claude/skills/site-pass/SKILL.md names each of glw907/ecxc-ski, glw907/907-life-legacy, glw907/aksailingclub-org, and glw907/cairn-pub on a line holding `claude-show-merge --ask-only`. 9. `python3 -I -c 'import json,sys; c=[x for x in json.load(open(sys.argv[1])) if "Tier: show" in json.dumps(x) and all(s in x["expected_behavior"] for s in ("claude-show-merge","--spec","--task","gh pr merge","git revert -m 1","--report"))]; print(len(c))' claude/.claude/skills/building-from-specs/evals/evals.json` prints 1. 10. The pull request's `## Before merge` carries the "Settings" edits as exact JSON and the spec's check: its body, read with `gh pr view <n> --repo glw907/workstation --json body --jq .body`, holds `Bash(claude-show-merge *)`, the new `autoMode.allow[1]` clause word for word, and the check command, and it shows the check printing `1 1` on a copy of settings.json outside the repo with the edits applied. 11. `bash scripts/gate.sh` exits 0 from the worktree root, and `claude-tooling-sync verify` passes. 12. A fresh standards:diff-reviewer accepts the branch against the spec's "How the tiers work" and Task 2 with 0 open findings, and the pull request is ready. The reviewer confirms in the text that the tick runs the script itself and never `--dry-run` followed by `gh pr merge`, that cleanup runs only on exit 0, that exit 1 is an ask, exit 2 is tried once more, and exit 3 is tried at the next tick, and that Geoff's session runs Show merges and `--report` before its other asks. Or stop after 120 minutes.
```

Today, on task-chains' branch (`origin/worktree-task-chains`), every count in items 1 to 4 and 6 prints 0, and
item 5 prints 250. Item 7's first count prints 0 and its second prints 1. Item 8 finds no line, and item 9 prints
0. Item 10 has no pull request yet.

Reviewers: `standards:diff-reviewer`. Minutes: 60 (the median of 45 plus a gate's p90 of 13), so the clause is
120. Model: Sonnet at high. Waits for: task-chains task 1 and its follow-up, merged, since both rewrite "Chains"
and "Merging". It runs beside task 1 of this spec.

## Step 3: prove it on two stub tasks, in Geoff's session

After both tasks merge and the settings edits are live, Geoff starts a session in `~/Projects/cc-desk-scratch`
(public, CI `gate` on `pull_request`, default branch `main`, `claude-worktree-busy` exited 0 today) on Sonnet at
medium. It arms:

```text
/loop 15m Run one chain tick for /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, by building-from-specs "Chains", for the tasks show-proof-a and show-proof-b in glw907/cc-desk-scratch.
```

Both stubs run on Sonnet at low, with 20 minutes each and a clause of 40. No like task is measured.

### Stub A

Name: show-proof-a
Tier: show
Files: `show/a.txt`

```text
Build task show-proof-a of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, section "Stub A", by building-from-specs. Create the directory show/, write show/a.txt holding the one line `a`, and commit it. Done when: 1. `cat show/a.txt` prints the one line `a`. 2. `bash scripts/gate.sh` exits 0. 3. `gh pr checks <n> --repo glw907/cc-desk-scratch` lists `gate` as pass. 4. A fresh standards:diff-reviewer accepts the diff with 0 open findings, and the pull request is ready with the body building-from-specs "The pull request" names, with no `## For Geoff`, no `## Before merge`, and the line `From spec /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, task show-proof-a.` Or stop after 40 minutes.
```

### Stub B

Name: show-proof-b
Tier: show
Files: `show/b.txt`

```text
Build task show-proof-b of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, section "Stub B", by building-from-specs. Create the directory show/, write show/b.txt holding the one line `b` and show/extra.txt holding the one line `extra`, and commit both. Done when: 1. `cat show/b.txt show/extra.txt` prints `b` then `extra`. 2. `bash scripts/gate.sh` exits 0. 3. `gh pr checks <n> --repo glw907/cc-desk-scratch` lists `gate` as pass. 4. A fresh standards:diff-reviewer accepts the diff with 0 open findings, and the pull request is ready with the body building-from-specs "The pull request" names, with no `## For Geoff`, no `## Before merge`, and the line `From spec /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, task show-proof-b.` Or stop after 40 minutes.
```

Stub B writes a file its `Files:` line leaves out, so it must come to Geoff as an ask.

Done when:

Below, the transcript is the session's file under `~/.claude/projects/-var-home-glw907-Projects-cc-desk-scratch/`,
and the record is `~/.local/state/claude-show-merge.jsonl`.

1. Stub A merged through the script, in a loop turn, with no word from Geoff.
   - `gh pr view <a> --repo glw907/cc-desk-scratch --json state,mergeCommit --jq '.state+" "+.mergeCommit.oid'`
     prints `MERGED` and a sha.
   - That sha equals the one in the script's `merged` line in the transcript and in the record's `merged` row for
     `show-proof-a`.
   - The transcript holds no refusal of that call, no Bash call holding `gh pr merge` outside the script, and no
     message from Geoff between the `/loop` line and the pull request's `mergedAt`.
   - Today `git -C ~/Projects/cc-desk-scratch ls-remote origin 'refs/heads/*show-proof*'` prints nothing.
2. Stub B fell to an ask from the tick.
   - Its pull request reads `OPEN`.
   - The record holds an `ask` row for `show-proof-b` whose failed checks include `files` naming
     `show/extra.txt`.
   - The pull request carries the script's comment with that line.
3. The sitting note holds the `--report` output: stub A's merge with the sha from item 1 and
   `git revert -m 1 <that sha>`, and stub B as an ask with its reason.
4. Geoff's "Revert" undoes stub A through a merged pull request.
   - After he says "Revert" for stub A, a pull request whose head commit's subject starts with `Revert "Merge pull
     request #<a>` reads `MERGED`.
   - After `git -C ~/Projects/cc-desk-scratch fetch origin`, `git -C ~/Projects/cc-desk-scratch show
     origin/main:show/a.txt` exits 128.

Stub B's pull request then closes on Geoff's word. The session records the results with each command's output in
`research/2026-11-23-merge-tiers/step-3.md` and commits it directly to `~/Projects/initiatives`. If item 1 fails
on a refusal, the record quotes it, and the batch fallback lands as a follow-up task.

## Merge order

Task-chains task 1 (pull request 271) and its follow-up merge first. Then this spec's task 1, then task 2 with its
`## Before merge`, each followed by `dotfiles-pass` "After a merge", whose `stow -R bin` links the new script.
Step 3 runs last.

## Backlog sweep

Scoped to merging, against `~/.dotfiles/BACKLOG.md` (68 open items):

- #50, an Approval Queue decision reaching the classifier: keep. Show rests on the same allow-rule mechanism, and
  step 3's record is new evidence for it. Its close condition names `approval-queue merge`, so reword it at its
  next sweep.
- #86, a `## Before merge` step between the pull requests of one merge document: done, as the task-chains sweep
  found. Mark it closed.
- #102, merge spellings the guard misses: keep. A Show merge runs no spelling of `gh pr merge`, and the guard's
  merge deny still guards task sessions.
- New: the three sites with no PR CI never pass the ready check of "Chains" or check 7 of the script, so their
  tasks never reach the tick's launch of a child or a Show merge. File it with `standards:log-issue`.

## Found, not in scope

- Pull request 271 read `mergeable` `CONFLICTING` today at head `e030621f`. That is task-chains task 1's to
  settle before it merges.

## Questions for Geoff

1. Answered on 2026-11-23: a Show task may change anything outside sign-in, data, settings, hooks, permission
   rules, the git guard, and `building-from-specs`. Geoff chose "Skills too (Recommended)".
2. Answered on 2026-11-23: the design as played back. Geoff: "This looks good."

## Calls Claude made

- This spec is written on Opus at high, and a fresh Opus session at high reads it, because Fable is capped until
  2026-11-27.
- The script decides a Show merge, not an `autoMode` line, because the classifier blocks unreviewed merges by
  default and AWS names deterministic logic as the authority.
- The Ask-only lists live in the script, so the authority sits in Ask-only code. A test keeps the site lists in
  step with `site-pass`.
- The gate and CI files are Ask-only too, since a Show merge rests on them. Tests stay Show.
- `cairn-pass`, `site-pass`, and `dotfiles-pass` are Ask-only, since they name each repo's gate.
- The current check compares changed files, not commit counts, because direct commits to `main` are common in the
  workstation, and a commit count would turn most Show tasks into asks.
- `## For Geoff` and `## Before merge` must be absent, rather than empty, so the script reads headings and not
  prose.
- The spec is read as committed when the pull request opened, so an edit made during the task can't make it Show.
- A repo with no list, such as standards or survey, stays Ask until a later change adds one.
- The task-score gains no field. The body's `From spec` line tells any session which spec and task a pull request
  came from, and the script checks it against `--spec` and `--task`.
- The script runs every check after a failure, so its output names each failure at once.
- A read failure exits 2 and gets one retry, so a passing `gh` hiccup doesn't send a Show task to Geoff. A wait
  exits 3 and counts for nothing, so a child's rerun CI or a session still at work doesn't either.
- An ask sticks. The record keeps it, so a later tick can't merge a pull request Geoff was told waits for him.
- The record is a local file plus a pull request comment. The file survives a dead loop, and `--report` shows
  each row once.
- The guard lets `--ask-only`, `--help`, and `--dry-run` through in task sessions, because spec writers and task 1's
  own goal items run them and none of them merges.
- The settings edits land in task 2's `## Before merge`, because a task session leaves settings alone.
- Task 1 runs on Opus, because the script is the merge's only gate. Task 2 runs on Sonnet.
- The proof step comes last, because it needs the script and the rule live. Its fallback is approved with this
  spec.
- A revert merges on Geoff's one word, because it undoes a change he never saw before it merged.
