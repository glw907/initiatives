# Status

## Current state

- Geoff set the scope on 2026-11-20: align the workstation's Claude configuration with
  Anthropic's docs and well-cited community practice, and decide the rest afterward. His words
  are in `specs/2026-11-20-process-decisions.md` under "Alignment comes first".
- The first part is live. The core design
  (`~/Projects/cc-desk/docs/specs/2026-11-20-core-design.md`) rewrote the global `CLAUDE.md`, the
  permission rules, the auto-mode entries, and the hook registrations. It merged as pull request
  255 in `glw907/workstation` on 2026-11-20.
- The process pieces are inventoried in `research/2026-11-20-process/`, nine reports.
- The rest is audited in `research/2026-11-20-workstation/`, four reports: the 13 personal skills
  outside the process, the `standards` plugin, the remaining configuration, and community
  practice. Each was scanned for secrets and personal details. Their findings are subagents'
  reports, and only a handful were checked against the files.
- Geoff approved this record as pull request 180 on 2026-11-20, and it is active.
- The alignment spec is written: `specs/2026-11-20-alignment-spec.md`, with three text files
  beside it that hold the new global `CLAUDE.md`, the new process skill, and its reference. Three
  subagents checked the audits against the files they name before the spec used them. A builder
  check and two readers with no context read the spec, and their findings are in it.
- Geoff approved the spec on 2026-11-21 ("Approved."). He changed no recommendation, so the six
  under "What Geoff decides" stand as written. The spec merged as pull request 181 here.
- The first task, "Groundwork", is done. It merged as pull request 256 in `glw907/workstation`
  on 2026-11-21, and the settings are live. The probe passed on all five points: a background
  session under `/goal` edited a skill file, committed, pushed, and opened a draft pull request
  with no prompt, and a command behind an `ask` rule was refused. The evidence is on pull
  request 256.
- The second task, "The process skill", is done. It merged as pull request 258 in
  `glw907/workstation` on 2026-11-21. The skill `building-from-specs` is live, and a fresh
  session lists it. Its build took 98 minutes against 70 planned, with five fix rounds. Its 24
  evaluation sessions took 398 seconds in all, a median of 15.3 seconds each.
- The third task, "The switch", is done. It merged as pull request 259 on 2026-11-21, and the
  new global `CLAUDE.md` and settings are live. A merge command now stops at a permission
  prompt that only Geoff answers, and a background session is refused one outright.
  `approval-queue land` is retired. `gh pr merge --help` ran in Geoff's session after a
  38-second wait at the prompt. One of 259's done items stays open until it can run: the next
  approved pull request stopping at the prompt.
- The build session made one call the spec didn't name. `claude-tooling-sync` caps a skill's
  description at 500 characters and now lets `building-from-specs` alone run to 1,536, because
  the approved text is longer than 500.
- The workstation gate failed on `main` on pavilion after pull request 260 named
  `~/.local/zen`, a path only thinkpad-x1 has. Commit `3a2fe1c` marks the two lines, and the
  gate passes again.
- The companion `specs/2026-11-20-alignment-global-file.txt` is one bullet behind the live
  global file. Pull request 260 reworded the browser bullet while 259 was open, and the merge
  kept 260's wording.
- Geoff ruled on 2026-11-21: "Pull requests are all pre-approved." His session reads that as
  the pull requests of this spec's tasks, and each merge still stops at his permission prompt.
- "The plugin" is done. Pull request 22 in `glw907/standards` merged as `61f996a` on
  2026-11-21 with seven of its eight done items met. The sixth is unmet: `claude plugin eval
  plugins/standards` exits 1, because the `ts-conventions` case already on `main` fails two runs
  of three and one `brainstorming` run in three asks a compound question. The merge waited
  about 16 seconds at Geoff's prompt, which closes the open item on pull request 259. The
  user-scope plugin is at `61f996aa3eb3`, and a fresh session lists a description for each of
  the four `vale-*` skills with no budget warning in its debug log. The session and its
  branches are removed.
- Geoff asked on 2026-11-21 for the follow-up to be planned: "look at current online and
  anthropic success patterns. Brainstorming is especially critical, so we'll need to know what
  works best with the current models, and aligns will with our local development patterns."
  The research is done and saved in `research/2026-11-21-brainstorming-followup/`. Its
  `README.md` is the short form. Four Sonnet researchers read Anthropic's pages, the upstream
  skill, and other published interview patterns, a second agent refetched every source, and
  one Opus reader compared the local skill with local practice. A second Opus reader then read
  Geoff's typed messages in 41 past brainstorming sessions (`past-sessions.md`), and Geoff's
  session ran five trials of the evaluation command (`evaluation-trials.md`).
- The follow-up spec is written at `specs/2026-11-21-brainstorming-spec.md`, with three files
  beside it: the new skill text, the script that writes the test cases, and a check for the
  mock-up page. On Fable 5.2 the rewrite passed all 17 cases in two full runs. The current
  skill passed 4 of the 13 brainstorming cases, and so did a session with no plugin. Three
  fresh readers checked the spec in two rounds, and their findings are in it. A background
  session in auto mode then ran the 13 brainstorming cases on the final text, and all 13
  passed.
- Geoff approved the follow-up spec on 2026-11-21 ("Approved."). He changed no recommendation,
  so the three under "What Geoff decides" stand: the skill and tests aim at his four
  corrections, a brainstorm does a few outside lookups before the approaches, and the task may
  start four full suite runs.
- The follow-up's build task, "The brainstorming skill and its tests", is built and waits for
  its merge. Its session `brainstorming-skill-and-tests` (`c6a1f289`) ended `done` at 23:50 on
  2026-11-21, 70 minutes against 164 planned. Pull request 23 in `glw907/standards` is ready on
  `b9588de` with a green `validate` check and all 14 goal items met. The suite passed twice in
  a row, 17 of 17 cases each time, for about 27 dollars a run. `standards:diff-reviewer`
  returned accept with no blocking finding and three optional notes, which the pull request
  lists under `## For Geoff`. Geoff's session checked that the branch's `SKILL.md` and
  `scripts/check-mockup-page.sh` match their companion files. The worktree is
  `.claude/worktrees/brainstorming-skill-tests` in `~/Projects/standards`, and it stays until
  the merge.
- The plugin's session met a new stop. The `/goal` checker answered "not met" 11 times in about
  two minutes over the item marked unmet, then marked the goal failed, and the session sat
  blocked on a question nobody was reading. Geoff's session stopped it. The row is in cc-desk's
  lessons file, commit `c353960`.
- "Survey" is done. Pull request 13 in `glw907/survey` merged as `30cd337` on 2026-11-21 with
  all six done items met, reviewed with an accept and no blocking finding. It took 71 minutes
  against 70 planned. The session and its branches are removed.
- Survey 2.0.0 is released, tagged at `885adb1`. Geoff's session chose the version by the
  changelog's rule that a removed rule is a major, because the release removes
  `writing/approval-brief.md`. The workstation still vendors `v1.7.0` until the last task.
- "Configuration cleanup" is done. Pull request 262 in `glw907/workstation` merged as `9796bf9`
  on 2026-11-21, reviewed with an accept and no open finding. It took 11 minutes against 125
  planned. Both after-merge checks are posted on the pull request: a `.yml` under `styles/`
  loads the Vale rule and a `.css` file loads none, and a task-shaped request calls the
  `bluefin-admin` skill. A plain question about a doc was answered by search without the skill.
  Commit `1773529` drops the retired instructions folder from one auto-mode allow entry, and
  `claude-tooling-sync verify` passes. The session and its branches are removed.
- "Personal skills" is done. Pull request 263 in `glw907/workstation` merged as `7c1022a` on
  2026-11-21 under Geoff's ruling that pull requests are pre-approved. Its review returned
  escalate with one blocking finding and nine others, and Geoff has the blocking one as a
  question: the `paths:` key on `vps-conventions` keeps that skill out of the list until a
  session opens a matching file. The checkout is pulled and restowed, `claude-tooling-sync
  verify` passes, and the after-merge checks are posted on the pull request. The worktree and
  both branches are removed.
- That task's session is removed. `claude rm 1ba4a94a` failed while the background service
  was down and worked once the next background launch had started it. The row is in cc-desk's
  lessons file, commit `8d29338`.
- Commit `f37b3b9` in `glw907/workstation` fixes the one line of the old process that pull
  request 263 left in `claude-infra`: work beyond the request goes to the backlog through
  `standards:log-issue`.
- "Memory stores" is done. Geoff kept three of the 11 files in the `/home` store, and they are
  in the `/var/home` store, whose index has 20 lines for 20 files. Commit `39f36df` in
  `glw907/workstation` adds `cd -P .` to the `claude` function, and the gate passed before it.
  The `/home` store's folder is gone. A print-mode session started from `/home/glw907` and one
  from `/var/home/glw907` each named `~/.claude/projects/-var-home-glw907/memory/`. The search
  for the retired words over the store prints nothing.
- Geoff ruled on 2026-11-21 to drop the `paths:` key from `vps-conventions` ("you can drop the
  vps-conventions"). Commit `7f5cbdf` in `glw907/workstation` removes its four lines, and the
  skill is back in a session's list. That closes the blocking finding on pull request 263.
- The `~/.dotfiles` main checkout is level with `origin/main` at `7f5cbdf`, and the gate
  passed on that commit. The busy check exits 0 there. Two uncommitted files from another
  session are still there: `google-workspace.md` under `claude/.claude/docs/bluefin-admin/` and
  `bin/.local/bin/sheet-revision`.
- Geoff kept two of the four habits pull request 262 listed ("The first two.", 2026-11-21):
  source `~/.local/secrets` in the same command, and give `wrangler secret put` a `--name`.
  Commit `ea609c0` in `glw907/workstation` adds them to the global file's "Secrets" section,
  because a section of their own put the file over its 120-line cap. The companion
  `specs/2026-11-20-alignment-global-file.txt` is a record of the switch and lacks them.
- The workstation gate failed once on `tests/test_cleanroom_live.py`, in
  `test_a_run_past_cap_min_ends_as_stopped_time`, and passed on the next run with no change to
  the test. Two evaluation runs were going at the time. It is item 112 in the workstation
  backlog, commit `0c1cf61`.
- The first pull request of "Retiring the old process" is being built. Geoff's session
  launched it at 23:43 on 2026-11-21 from `~/.dotfiles` at `7f5cbdf` as the background session
  `retiring-old-process-first` (`a0c893ad`), on Opus at high effort, with the goal in
  `plans/2026-11-21-retiring-first-goal.txt`. Its time clause is 320 minutes, twice the planned
  160, with nothing added for evaluations because the task runs none. Before the launch the
  busy check on `~/.dotfiles` exited 0, the repo read as public, and the brainstorming session
  was sent a notice. It runs beside the brainstorming task, since neither touches the other's
  repo. Pavilion has four working sessions while a suite run is going, which is the limit.
- Geoff ruled late on 2026-11-21, before leaving for the night: "Unless there are major issues,
  you can do all the merges." His session reads that as the three pull requests still to merge:
  23 in `glw907/standards` and the two of "Retiring the old process". A pull request that stays
  a draft, or a review with a blocking finding, is a major issue and waits for him. Each merge
  still stops at his permission prompt, so no merge runs while he is away. His session runs the
  first merge command only after both task sessions have ended, because a session held at a
  prompt can't act on another session's notice.
- Weekly usage was 38 percent for all models and 54 percent for Fable at 23:43 on 2026-11-21.

## Next action

Geoff's session runs the tasks from `plans/2026-11-21-side-by-side-prompt.txt`. Every "Side by
side" task has merged. Two task sessions are running, and each ends in a pull request that
Geoff's session merges. Neither merge waits on the other. No watcher outlives a clear of
Geoff's session, so a fresh session reads both from `claude agents --json` before anything
else, and starts no third session while both work.

1. Pull request 23 in `glw907/standards` is ready to merge, under Geoff's ruling on the
   overnight merges. Geoff's session runs `gh pr merge 23 --repo glw907/standards --merge` once
   the other task session has ended, and the command stops at his permission prompt. The
   after-merge steps follow, with `claude rm c6a1f289`, then the four workstation edits in the
   follow-up spec as one direct commit, with their done items posted on the merged pull
   request. The lines those edits change were found on `7f5cbdf` and match the spec.
2. The first pull request of "Retiring the old process", session `a0c893ad` in
   `glw907/workstation`. When it is ready, Geoff's session merges it the same way, pulls, runs
   `stow -R bin`, and checks the three after-merge items. It then builds the second pull
   request itself from the second table in the spec, runs `claude-tooling-sync apply` and
   `verify` after that merge, and only then makes the direct commit that removes
   `claude-merge-guard`. The brainstorming spec's workstation edits take the `brainstorming`
   entry out of `vendored-skills.json`, so they land before the second pull request sets that
   file's descriptions.

After "Retiring the old process" merges, Geoff's session raises the spec-writing evaluation
with him.

## Open decisions

- The rulings file owes Geoff one question about where cc-desk's scheduled check-ins come
  against the rewrite of Move. It is about later work and is not asked until that work starts.
- The parked questions are listed in the rulings file under "Parked until the workstation is
  aligned". None is asked until a spec needs its answer.
- Geoff ruled on 2026-11-21 that spec writing is tested after the workstation is aligned:
  "Let's follow best practices and test once we have the environment fully set up." The
  rulings file holds it under "Parked until the workstation is aligned". No task in the spec
  gains a spec-writing evaluation.
- Geoff asked on 2026-11-21 for Chromium to be trimmed to what development work needs. It is
  item 109 in the workstation backlog and is no part of this spec.
- The `claude auto-mode critique` of the first settings change said the entry for build
  sessions doesn't say what shows that Geoff approved a spec. Geoff hasn't ruled on it. The
  critique run after the switch returned no feedback, twice.
- Pull request 13 left three things for a later look: `DESIGN.md` in `glw907/survey` still
  says "the approval queue" in four places (its backlog item 10), the workstation still holds
  `~/.claude/docs/voice/approval-brief.md`, and the survey skill's description ends on a clause
  that addresses Claude.
- "The plugin" added `BACKLOG.md` and `.claude/project-tracking.json` to the public `standards`
  repo, outside its task's table. They stay unless Geoff objects.
