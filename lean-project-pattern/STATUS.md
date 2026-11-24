# Status

The spec is `specs/2026-11-23-lean-project-pattern.md`. Geoff approved it on 2026-11-23 ("I approve #183"), and
on the same day he added a watcher rule to task 2 ("Please do", commit `3c906b5`).

## Current state

- Task 1 (dubplate) merged as dubplate pull request 26 (`c8f900a`). Task 3 (`standards:diff-reviewer`) merged as
  standards pull request 29 (`945252a`). Geoff approved both with "I approve 26 and 29". Their sessions are
  stopped, and their worktrees and branches are gone.
- Pull request 29 marks done item 1 unmet: the spec's "prints 1 today" count is 0, because the line wraps on
  `main`. It left the decision-record bullet out, because the unchanged reviewer scored 1.0. Standards backlog
  #3 rebuilds that case in a larger tree (pull request 31, after Geoff's "I approve 31").
- The "After task 1" step is done: dubplate `docs/STATUS.md` names the records and the gate checks (`3fdbfdb`).
- The standards plugin still loads at `5f18621` in running sessions. A restart loads the new reviewer.
- Workstation pull request 271 (task chains) merged at 18:05 on 2026-11-23. Approval now follows its
  "Merging" section: Geoff answers "Merge" or "Send back" to a question that says what each pull request changes.

## Next action

One session drives this record and `claude-config-alignment/STATUS.md` ("Task chains and merge tiers"), since
both wait on the `merge-prompt` session (`7be0f058`, in `~/.dotfiles/.claude/worktrees/merge-prompt`). It builds
the task-chains spec's merge-prompt task, edits `building-from-specs` `SKILL.md` (the launch line, "Chains",
and "Merging"), and stops by 19:30 on 2026-11-23.

1. When `merge-prompt` ends, read its pull request and ask Geoff by the "Merging" section. Its
   `## Before merge` removes the merge `ask` rules from `settings.json`; then `claude-tooling-sync apply` and
   `verify`. After the merge, pull `~/.dotfiles` (on `main`, no uncommitted change in a merged file).
2. Two pieces of work then edit `building-from-specs` `SKILL.md` and `references/writing-a-spec.md`: this
   record's task 2 and the merge-tiers spec's task 2 (`show-tier-rules`). They run one after the other. The
   merge-tiers spec's task 1 (`claude-show-merge`) touches neither and runs beside either. Merge tiers
   launches only on Geoff's word, so ask him the order. Claude recommends this record's task 2 first, beside
   merge-tiers task 1, then merge-tiers task 2 once both merge.
3. Before each launch, run the checks in `building-from-specs` "Launching a task", confirm
   `gh pr list -R glw907/workstation --state open --json number,files` shows no other open pull request
   touching the files the task edits, and read `/usage`: the week must be under 85 percent.
4. Launch this record's task 2 from `~/.dotfiles` with the launch line as the skill then gives it, as
   `lean-pattern-skill` on Opus at medium, with the goal in a here-document with a quoted delimiter. The goal
   names the spec, says to read it with `git -C /var/home/glw907/Projects/initiatives show
   origin/main:lean-project-pattern/specs/2026-11-23-lean-project-pattern.md`, and is met when each of Task
   2's eight done items holds as the spec words it or is marked unmet with its reason, the
   `standards:diff-reviewer` review accepts, and the pull request is ready with planPathMin 52. It ends
   "Or stop after 104 minutes." Leave out "the session has ended".
5. In the same turn as each launch, start a watcher: a background command that exits when
   `claude agents --json` shows that session no longer `working`. Keep the checkout's path out of the
   watcher's command line, or `claude-worktree-busy` reads the watcher as a session in that checkout.
6. When a watcher wakes, read the pull request and ask Geoff by the "Merging" section. After this record's
   task 2 merges, pull `~/.dotfiles` and close this record through `log-project`.

## Launch prompt

Continue the lean-project-pattern and merge-tiers work from
`~/Projects/initiatives/lean-project-pattern/STATUS.md`, "Next action", by building-from-specs.
