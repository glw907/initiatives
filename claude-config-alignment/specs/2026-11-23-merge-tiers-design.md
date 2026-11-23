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
fails if a task session can run the script, or if a Show merge never reaches Geoff's report.

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

Each repo is keyed by the `nameWithOwner` that `gh repo view` prints from its main checkout. The 907-life
checkout prints `glw907/907-life-legacy` today, and that is its key. Brace globs are written out, because
`PurePath.full_match` doesn't expand them.

### What `claude-show-merge` checks

`claude-show-merge <owner/repo> <number> --spec <path> --task <name>` runs these checks in order and prints one
line for each: `pass <check>` or `fail <check>: <reason>`. It merges only when all pass. `--dry-run` runs every
check and merges nothing.

1. Task session: `CLAUDE_TASK_SESSION` isn't `1`. A task session can't run it.
2. Repo: the repo has an Ask-only list.
3. Spec: the spec file is tracked in its git repo with no uncommitted change. Its `Status:` line starts with
   `Status: approved`. One section holds `Name: <task>`, and that section holds `Tier: show` and a `Files:` line
   with at least one backticked glob. The spec as last committed at or before the pull request's `createdAt` has
   the same `Status:` start and the same `Tier:` and `Files:` lines for the task, so a change made after the task
   started counts for nothing.
4. Session: the newest entry named `<task>` in `claude agents --json --all` reads `done`.
5. Pull request: `state` is `OPEN`, `isDraft` is `false`, `mergeable` is `MERGEABLE`, and `baseRefName` is the
   repo's default branch from `gh repo view --json defaultBranchRef`. The script records `headRefOid` here.
6. CI: `gh pr checks` exits 0. In `glw907/workstation`, which has no PR CI, `no checks reported` passes too, the
   same exception as task-chains' ready check.
7. Review: the `task-score` comment parses as JSON and reads `"verdict":"accept"`, `"openFindings":0`, and
   `"unmet":0`.
8. Body: the body holds no `## Before merge` heading and no `## For Geoff` heading.
9. Files: every path in `gh api repos/<r>/pulls/<n>/files --paginate`, `filename` and `previous_filename`
   both, matches a `Files:` glob, and none matches an Ask-only glob.
10. Current: `gh api repos/<r>/compare/<head>...<default>` lists the files changed on the default branch since
    the merge base, and none of them is a file the pull request changes. A list of 300 files, the API's most,
    fails. For a child (the body's first line reads `Built on #<p> at <sha>`), pull request `<p>` has merged and
    its `headRefOid` is `<sha>`.

Then it runs `gh pr merge <n> --repo <r> --merge --match-head-commit <headRefOid>`, with the head read at check 5,
so a push after the checks stops the merge. It prints `merged <r>#<n> <merge sha>` and
`undo: git revert -m 1 <merge sha>`.

| Exit | Meaning | What follows |
| --- | --- | --- |
| 0 | Merged, or every check passed under `--dry-run` | The tick runs the cleanup steps. |
| 1 | A check failed | The pull request is an ask, with the failed check named. |
| 2 | A read failed: a `gh` or `claude` error, or a moved head at the merge | It is tried once more at the next tick, and a second exit 2 counts as exit 1. |

### Where it runs

The chain tick of task-chains runs it. After step 3 finds a task ready, a task whose section reads `Tier: show`,
and whose parent has merged or that has none, goes to `claude-show-merge`. On exit 0 the tick runs "Merging"
steps 4 and 5 (pull, retarget children, clean up) and the repo pass skill's "After a merge". On exit 1 the task
waits for Geoff with the printed reason, and its children still launch, as for any ready task. The tick's
sitting note gains two lists: each Show merge, in plain words, with its merge commit and the `git revert -m 1`
line, and each Show task that fell to an ask, with its failed check.

With no tick, Geoff's session runs the script at the start of his next sitting, before it asks about anything
else, and reports each Show merge the same way.

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
Settings stay Ask, so `autoMode.allow[2]` keeps its clause. `claude-git-guard` denies `claude-show-merge` when
`CLAUDE_TASK_SESSION` is `1`, as task-chains' follow-up does for merges.

## Limits

- Show applies only in the seven repos the table lists. Three of them, ecxc-ski, 907-life, and cairn-pub, have no
  PR CI, so check 6 fails there and their tasks stay Ask until they have it.
- The compare and pull request files lists stop at 300 and 3,000 files, and a list at the cap fails.
- A read failure is retried once, at the next tick, 15 minutes later and up to 7.5 minutes late.
- The tick merges every passing Show pull request it finds, in chain order, with no cap per tick.
- A revert has no time limit. One that conflicts goes to Geoff as an ask.

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
| `git revert`, `gh pr create`, `gh pr diff`, `git worktree remove`, `claude-show-merge` | 0 | |

## Task 1: build `claude-show-merge`

Name: show-merge-script
Tier: ask
Files: `bin/.local/bin/claude-show-merge`, `tests/test_claude_show_merge.py`, `scripts/check.sh`, `bin/.local/bin/claude-git-guard`, `tests/test_claude_git_guard.py`

The task builds in `glw907/workstation`, launched from `~/.dotfiles`. The script is stdlib Python run as
`python3 -I`, one file, per the workstation's tool rule. It does what "How the tiers work" says: the ten checks,
the merge, the exits, `--dry-run`, and `--ask-only`, with the table's lists. Its tests put fake `gh` and `claude`
on `PATH`. `claude-git-guard` denies a command that runs `claude-show-merge` when `CLAUDE_TASK_SESSION` is `1`,
and its reason names the task-session rule.

Goal:

```text
Build task show-merge-script of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md by building-from-specs, with dotfiles-pass for the gate and checks. Below, $M is bin/.local/bin/claude-show-merge. Done when: 1. `$M --help | grep -c -e --spec -e --task -e --dry-run -e --ask-only` prints 4 or more. 2. `$M --ask-only glw907/workstation | grep -c -x -F -e claude/.claude/settings.json -e bin/.local/bin/claude-git-guard -e bin/.local/bin/claude-show-merge -e 'claude/.claude/skills/building-from-specs/**'` prints 4, and `$M --ask-only glw907/standards` exits 1. 3. `uv run --with pytest --no-project python -m pytest tests/test_claude_show_merge.py -q` passes, with one test for each of the spec's ten checks whose fixture misses only that check and expects exit 1 and that check's fail line, one test where a read fails and expects exit 2, and one where every check passes and the fake gh records `pr merge <n> --repo <r> --merge --match-head-commit <sha>`. A test also finds every backticked glob of site-pass "Risk-class path map", braces expanded, in that site's list. 4. `$M glw907/workstation 271 --spec /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md --task task-chains --dry-run` exits 1, and its output holds a fail line for the spec check. 5. Fed `{"tool_name":"Bash","tool_input":{"command":"claude-show-merge glw907/cc-desk-scratch 7 --spec /x.md --task t"}}` on stdin, bin/.local/bin/claude-git-guard prints a deny decision with CLAUDE_TASK_SESSION=1, and prints nothing and exits 0 without it; tests/test_claude_git_guard.py covers both. 6. `grep -c 'show-merge' scripts/check.sh` prints 1 or more. 7. `bash scripts/gate.sh` exits 0 from the worktree root, and `claude-tooling-sync verify` passes. 8. A fresh standards:diff-reviewer accepts the branch against the spec's "How the tiers work" and Task 1 with 0 open findings, and the pull request is ready. Or stop after 180 minutes.
```

Today, items 1 to 4 fail because `bin/.local/bin/claude-show-merge` doesn't exist (`test -x` exits 1, and
`ls tests | grep -c show_merge` prints 0). Item 5 prints nothing and exits 0 in both cases. Item 6 prints 0.

Reviewers: `standards:diff-reviewer`. Minutes: 90 (the measured median actual path for `workstation` is 45, plus
a gate's p90 of 13, plus 30 for a new script and its tests), so the clause is 180. Model: Opus at high. Waits for:
task-chains task 1 (pull request 271) and its follow-up, merged.

## Task 2: write the tiers into the skills

Name: show-tier-rules
Tier: ask
Files: `claude/.claude/skills/building-from-specs/SKILL.md`, `claude/.claude/skills/building-from-specs/references/writing-a-spec.md`, `claude/.claude/skills/building-from-specs/evals/evals.json`, `claude/.claude/CLAUDE.md`, `.claude/skills/dotfiles-pass/SKILL.md`, `claude/.claude/skills/cairn-pass/SKILL.md`, `claude/.claude/skills/site-pass/SKILL.md`

The task builds in `glw907/workstation`, launched from `~/.dotfiles`, in the agent-facing register
(`~/.claude/docs/voice/agent-facing.md`). It writes:

- `SKILL.md`: "Chains" gains the Show step and the two sitting-note lists from "Where it runs". "Merging" gains the
  Show paragraph, the sitting run with no tick, and "Undo", citing the Ship/Show/Ask URL. The step list at the
  top and "The pull request" item 5 say `## For Geoff` is left out when nothing waits.
- `writing-a-spec.md`: a task carries the `Name:`, `Tier:`, and `Files:` lines, and Show is allowed only by "A
  task's tier".
- `CLAUDE.md` "Work is built from specs": "Only the session Geoff is talking to merges, and only after he approves
  the pull request in his terminal, or, for a task his approved spec marks Show, when `claude-show-merge` passes."
- `dotfiles-pass` "Paths": `claude-show-merge` joins the unattended scripts, plus one line naming
  `claude-show-merge --ask-only glw907/workstation`. `cairn-pass` and `site-pass` each gain that line for their
  repos.
- `evals.json`: one case. The tick finds a ready pull request whose spec task reads `Tier: show`. The expected
  behavior is that it runs `claude-show-merge` with `--spec` and `--task`, runs no bare `gh pr merge`, asks
  Geoff nothing, and puts the `git revert -m 1` line in the sitting note.

A task session leaves settings alone, so the pull request's `## Before merge` carries the "Settings" edits as
exact JSON, with this check: `python3 -I -c 'import json; s=json.load(open("claude/.claude/settings.json"));
print(s["permissions"]["allow"].count("Bash(claude-show-merge *)"), sum("after Geoff merges its PR" in a for a in
s["autoMode"]["allow"]))'` prints `1 1`. Today it prints `0 2`. Geoff's session applies them on the branch as a
commit, after his "Merge" and after the task's session has ended, then merges.

Goal:

```text
Build task show-tier-rules of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md by building-from-specs, with dotfiles-pass for the gate and checks. Below, $S is claude/.claude/skills/building-from-specs/SKILL.md, and "in Chains" or "in Merging" means piping `sed -n '/^## Chains$/,/^## /p' $S` or `sed -n '/^## Merging$/,/^## /p' $S` to the grep. Done when: 1. `grep -c -F 'Tier: show' $S` prints 1 or more. 2. In Chains, `grep -c -F 'claude-show-merge'` prints 1 or more and `grep -c -F 'git revert -m 1'` prints 1 or more. 3. In Merging, `grep -c -F 'claude-show-merge'` prints 1 or more and `grep -c -F 'Revert'` prints 1 or more. 4. `grep -c -F 'ship-show-ask' $S` prints 1. 5. `wc -l < $S` prints 270 or fewer. 6. For claude/.claude/skills/building-from-specs/references/writing-a-spec.md, `grep -c -F -e 'Name:' -e 'Tier:' -e 'Files:'` prints 3 or more. 7. `grep -c -F 'claude-show-merge' claude/.claude/CLAUDE.md` prints 1. 8. `grep -c -F 'claude-show-merge --ask-only'` prints 1 or more in each of .claude/skills/dotfiles-pass/SKILL.md, claude/.claude/skills/cairn-pass/SKILL.md, and claude/.claude/skills/site-pass/SKILL.md. 9. `grep -c -F 'claude-show-merge' claude/.claude/skills/building-from-specs/evals/evals.json` prints 1 or more. 10. The pull request's `## Before merge` carries the spec's "Settings" edits as exact JSON and the spec's check, read with `gh pr view <n> --repo glw907/workstation --json body --jq .body | grep -c -F 'Bash(claude-show-merge *)'` printing 1 or more. 11. `bash scripts/gate.sh` exits 0 from the worktree root, and `claude-tooling-sync verify` passes. 12. A fresh standards:diff-reviewer accepts the branch against the spec's "How the tiers work" and Task 2 with 0 open findings, and the pull request is ready. Or stop after 120 minutes.
```

Today, on task-chains' branch (`origin/worktree-task-chains`), items 1 to 4 print 0, item 5 prints 250, item 6
prints 0, and items 7 to 9 print 0 for each file. Item 10 has no pull request yet.

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
Build task show-proof-a of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, section "Stub A", by building-from-specs. Create the directory show/, write show/a.txt holding the one line `a`, and commit it. Done when: 1. `cat show/a.txt` prints the one line `a`. 2. `bash scripts/gate.sh` exits 0. 3. `gh pr checks <n> --repo glw907/cc-desk-scratch` lists `gate` as pass. 4. A fresh standards:diff-reviewer accepts the diff with 0 open findings, and the pull request is ready with the body building-from-specs "The pull request" names, with no `## For Geoff` and no `## Before merge`. Or stop after 40 minutes.
```

### Stub B

Name: show-proof-b
Tier: show
Files: `show/b.txt`

```text
Build task show-proof-b of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-23-merge-tiers-design.md, section "Stub B", by building-from-specs. Create the directory show/, write show/b.txt holding the one line `b` and show/extra.txt holding the one line `extra`, and commit both. Done when: 1. `cat show/b.txt show/extra.txt` prints `b` then `extra`. 2. `bash scripts/gate.sh` exits 0. 3. `gh pr checks <n> --repo glw907/cc-desk-scratch` lists `gate` as pass. 4. A fresh standards:diff-reviewer accepts the diff with 0 open findings, and the pull request is ready with the body building-from-specs "The pull request" names, with no `## For Geoff` and no `## Before merge`. Or stop after 40 minutes.
```

Stub B writes a file its `Files:` line leaves out, so it must come to Geoff as an ask.

Done when:

1. Stub A's pull request merged with no message from Geoff: `gh pr view <a> --repo glw907/cc-desk-scratch --json
   state --jq .state` prints `MERGED`, and the transcript shows `claude-show-merge` exiting 0 inside a loop turn
   with no refusal. Today `git -C ~/Projects/cc-desk-scratch ls-remote origin 'refs/heads/*show-proof*'` prints
   nothing.
2. Stub B's pull request reads `OPEN`, and the script's output in the transcript holds a `fail files` line naming
   `show/extra.txt`.
3. The sitting note lists stub A's merge with its merge commit and `git revert -m 1 <sha>`, and stub B as an ask
   with that reason.
4. After Geoff says "Revert" for stub A, the revert pull request merges, and
   `git -C ~/Projects/cc-desk-scratch show origin/main:show/a.txt` exits 128.

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
- New: the three sites with no PR CI never pass the ready check of "Chains" or check 6 of the script, so their
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
- The task-score gains no field. The caller passes `--spec` and `--task`.
- A read failure exits 2 and gets one retry, so a passing `gh` hiccup doesn't send a Show task to Geoff.
- The settings edits land in task 2's `## Before merge`, because a task session leaves settings alone.
- Task 1 runs on Opus, because the script is the merge's only gate. Task 2 runs on Sonnet.
- The proof step comes last, because it needs the script and the rule live. Its fallback is approved with this
  spec.
- A revert merges on Geoff's one word, because it undoes a change he never saw before it merged.
