# Brief: merge tiers across the Claude infrastructure

A clean session brainstorms this with Geoff and writes the spec. The session that wrote this brief stays
out of the design.

## What Geoff asked

Geoff, 2026-11-23:

- "I'm getting a lot of smaller PRs with very obvious approval. And that definitaly causes approval
  fatigue."
- "small approvials that are mere formality are presenting in the same way as much more consiquntial
  decisions."
- Asked for the accepted fix, he chose tiers set in each spec, "assuming that represents best practice."
- "we'll need to make sure that change is baked thoughtfully into out broader claude infastructure. That
  might be worth a clean session and formal brainstorm/spec."

## Already ruled, not reopened here

- Approval by number is gone. Geoff answers "Merge" or "Send back" to each pull request, asked about by
  what merging it changes. Task 1 of `specs/2026-11-22-task-chains-design.md` builds this (session
  `task-chains` in `~/.dotfiles`, building as this brief was written).
- The `gh pr merge` permission prompt goes, also in task 1. A deny for task sessions takes its place:
  the launch line sets `CLAUDE_TASK_SESSION=1`, and `claude-git-guard` denies a merge when it's set.
  That spec's "Task 1" section has the detail.

## The sources the choice rested on

- Ship / Show / Ask: <https://www.martinfowler.com/articles/ship-show-ask.html>. `building-from-specs`
  "Direct changes" is Ship already.
- GitHub's Dependabot auto-merge, a merge gated on checks:
  <https://docs.github.com/en/code-security/tutorials/secure-your-dependencies/automate-dependabot-with-actions>.
- AWS Agentic AI Lens AGENTSEC04-BP02, on risk-gated review and reviewer fatigue:
  <https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec04-bp02.html>.
- Anthropic on approval fatigue ("users accept 93% of them anyway"):
  <https://www.anthropic.com/engineering/claude-code-auto-mode>. On moving oversight to the plan:
  <https://www.anthropic.com/research/trustworthy-agents>.

## Where the merge rule lives today

Found by a grep for approval and merge wording on 2026-11-23. Archived plans are records and stay.

- `~/.dotfiles/claude/.claude/skills/building-from-specs/SKILL.md` and `references/writing-a-spec.md`
- `~/.dotfiles/claude/.claude/skills/building-from-specs/evals/evals.json`, which tests the rule
- `~/.dotfiles/claude/.claude/CLAUDE.md`, "Work is built from specs"
- `~/.dotfiles/claude/.claude/settings.json`, the `ask` rules on merges, which task 1 removes
- `~/.dotfiles/bin/.local/bin/claude-git-guard`, `MERGE_REASON` and the merge detection
- `~/.dotfiles/claude/.claude/skills/survey/releasing.md`
- Not found by the grep but in reach: the repo pass skills (`cairn-pass`, `site-pass`,
  `dotfiles-pass`) and their path and risk-class maps; `maintenance-mode` and
  `standards:dependency-upgrade`, where Dependabot pull requests merge; the sitting note and STATUS
  hand-overs, where a merge made without Geoff would be reported; `task-report`, which reads task-score.

## A starting draft, not a decision

Written in the task-chains spec before Geoff asked for this brainstorm, and moved here unchanged:

### The draft

Geoff, 2026-11-23: "I'm getting a lot of smaller PRs with very obvious approval. And that definitaly
causes approval fatigue." And: "small approvials that are mere formality are presenting in the same way as
much more consiquntial decisions." He chose tiers set in each spec, "assuming that represents best
practice."

The tiers follow Ship / Show / Ask (Rouan Wilsenach,
<https://www.martinfowler.com/articles/ship-show-ask.html>). Ship is `building-from-specs` "Direct
changes" already. This task adds Show and Ask. One departure from that article: there the author picks
each change's tier, and here Geoff picks it when he approves the spec, so his approval moves to the
point where he sees the design. A change that drifts from its spec drops to Ask by itself. GitHub's
Dependabot auto-merge
(<https://docs.github.com/en/code-security/tutorials/secure-your-dependencies/automate-dependabot-with-actions>)
is the precedent for a merge gated on checks with no per-change approval.

The task writes these rules into `$S`:

- Each task in a spec carries `Tier: show` or `Tier: ask`, and Geoff approves it with the spec. A task is
  Ask unless all of these hold: it touches no sign-in or data path, no settings, hook, or permission
  file, and in a path that runs unattended work it changes wording only. The repo's pass skill holds the
  path map that answers each one.
- A Show pull request says `Tier: show` in its body. The session Geoff talks to merges it, by the merge
  steps, when every one of these holds: the task's session has ended, the pull request is ready, `gh pr
  checks` exits 0, the task-score reads `verdict` `accept`, `openFindings` 0, and `unmet` 0, the body has
  no `## Before merge` and nothing under `## For Geoff`, and `git diff --name-only` lists only paths the
  spec names for that task. A miss on any of them makes the pull request Ask, and it comes to Geoff by
  task 1's rule.
- After a Show merge, Geoff's next sitting note names it in plain words, with its merge commit and
  `git revert -m 1 <sha>` to undo it.
- Ask is task 1's "Merging", unchanged.

`writing-a-spec.md` gains the `Tier:` line in what a task carries. Tasks 1 and 2 are Ask: both change
paths that run unattended work.

Goal:

```text
Build task tiers of /var/home/glw907/Projects/initiatives/claude-config-alignment/specs/2026-11-22-task-chains-design.md by building-from-specs, with dotfiles-pass for the gate and checks. Below, $S is claude/.claude/skills/building-from-specs/SKILL.md. Done when: 1. `grep -c -F 'Tier: show' $S` prints 1 or more, and `grep -c -F 'Tier: ask' $S` prints 1 or more. 2. `sed -n '/^## Merging$/,/^## /p' $S | grep -c -e 'git diff --name-only' -e 'git revert -m 1'` prints 2 or more. 3. `grep -c -F 'Tier:' claude/.claude/skills/building-from-specs/references/writing-a-spec.md` prints 1 or more. 4. `grep -c -F 'ship-show-ask' $S` prints 1. 5. `wc -l < $S` prints 270 or fewer. 6. `bash scripts/gate.sh` exits 0 from the worktree root, and `claude-tooling-sync verify` passes. 7. A fresh standards:diff-reviewer accepts the branch against the spec's Task 2 with 0 open findings, and the pull request is ready. Or stop after 90 minutes.
```

Reviewers: `standards:diff-reviewer`. Minutes: 45, so the clause is 90. Model: Sonnet at high. Tier: ask.
Waits for: task 1 merged, since both rewrite "Merging".

