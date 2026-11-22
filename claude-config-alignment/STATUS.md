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
- The follow-up's build task, "The brainstorming skill and its tests", is done. Pull request 23
  in `glw907/standards` merged as `b6dbe0d` on 2026-11-22 with all 14 goal items met and a green
  `validate` check. Its review returned accept with three optional notes, which the pull
  request lists under `## For Geoff`. The session took 70 minutes against 164 planned, and the
  suite passed twice in a row, 17 of 17 cases each time, for about 27 dollars a run. The
  session, its worktree, and its branches are removed.
- The brainstorming spec's four workstation edits are commit `de25be6` in `glw907/workstation`.
  Their done items are posted on pull request 23. The user-scope plugin is at `b6dbe0db3b70`, a
  fresh session lists the new description for `standards:brainstorming`, and the mock-up
  server's screen shows "Connected" in its header and no logo.
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
- The `~/.dotfiles` main checkout is level with `origin/main` at `ac87235`, and the gate
  passes on that commit. The busy check exits 0 there. Two uncommitted files from another
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
- "Retiring the old process" is done, and with it every task of the alignment spec. Its first
  pull request, 264 in `glw907/workstation`, merged as `4fa6f48` on 2026-11-22. The build
  session ran on Opus at high effort and took 38 minutes against 160 planned. The reviewer
  returned fix on `1f00abe` and accept on `33f7c79`. The three after-merge items are posted on
  the pull request: `task-report --help` runs, no link in `~/.local/bin` dangles, and a fresh
  session in `~/Projects/cairn-cms` called `cairn-pass` and `building-from-specs`.
- Pull request 264 leaves two notes for Geoff. `cairn-pass` doesn't name the cairn-cms process
  skill, because that skill's name holds a retired word. The weekly usage check sits only in
  `unattended-work-guards.md` and not in `building-from-specs` "Launching a task". It also
  filed workstation backlog item 113, a Vale config line that names a deleted skill.
- The second pull request is 265 in `glw907/workstation`, merged as `edae735` on 2026-11-22.
  Geoff's session built it as six commits. A fresh `standards:diff-reviewer` returned accept
  with no blocking finding, and the gate exited 0 on its last commit, `ae19668`. The `cc-desk`
  and `cc-desk-work` skills are gone, the survey skill is at 2.0.0, the gate fails on any of
  the ten retired words, and the `PreToolUse` hooks name `claude-git-guard`.
- The settings are applied. `claude-tooling-sync apply` changed one line of the live
  `settings.json`, the hook's command, and `verify` exits 0. Commit `ac87235` then removes
  `claude-merge-guard` and its test. It also drops the script's name from the gate's `pytest`
  path pattern and from the `dotfiles-pass` skill, and three open backlog items now name
  `claude-git-guard`. All six done items hold on `ac87235`, and the evidence is posted on pull
  request 265. The worktree and the branches are removed.
- One change in pull request 265 is outside the spec's table. Survey 2.0.0's description is
  515 characters, over the lint's 500, and `claude-tooling-sync` now lets it run to 1,536,
  because that text is what the survey evaluations tested. The reviewer read it as correct.
- The workstation repo runs no CI on pull requests, so a pull request there shows no checks.
  The gate on the branch's last commit is the only full run.
- Geoff ruled late on 2026-11-21: "Unless there are major issues, you can do all the merges."
  The three merges of 2026-11-22 ran under it, and each stopped at his permission prompt.
- Weekly usage was 40 percent for all models and 56 percent for Fable at 10:11 on 2026-11-22.

## Next action

Every task of the alignment spec and of the brainstorming spec has merged. The launch prompt
`plans/2026-11-21-side-by-side-prompt.txt` is finished, and no task session is running.

The spec for the spec-writing test is written and waits for Geoff's approval:
`specs/2026-11-22-spec-writing-test-spec.md`. Nothing is built. It asks him one question:
whether the spend is all right (about 110 dollars planned, 170 at most). Its trial runs are in
`research/2026-11-22-spec-writing-test/`. Geoff ruled on length on 2026-11-22: "I'll go with
Anthropic's guidance on the subject." Anthropic's pages and four community sources give no
number and size a spec by its change. The spec is revised to match: the guide's length rule
states no number, and the test keeps 1,200 words as its pass mark. The sources are in the
spec under "How long a spec may be". The launch prompt
`plans/2026-11-22-spec-writing-evaluation-prompt.txt` is finished. A fresh session takes his
approval and launches the tasks from `plans/2026-11-22-spec-writing-test-build-prompt.txt`.

Once he approves, his session launches the spec's first task in `~/.dotfiles` after the checks
under the spec's "Before launch". On 2026-11-22 `claude-worktree-busy ~/.dotfiles` exits 1.
The session `dotfiles-5e` sits idle there with three uncommitted files, and no task launches
until that clears. The
spec's second task waits for the first to merge. Approval also covers two backlog edits in the
workstation repo, which his session lands when the checkout is free: item 113 gains a stamp and
item 94 moves to Done.

He also has the notes the last three pull requests left, listed under "Open decisions".

## Open decisions

- The rulings file owes Geoff one question about where cc-desk's scheduled check-ins come
  against the rewrite of Move. It is about later work and is not asked until that work starts.
- The parked questions are listed in the rulings file under "Parked until the workstation is
  aligned". None is asked until a spec needs its answer.
- Geoff ruled on 2026-11-21 that spec writing is tested after the workstation is aligned:
  "Let's follow best practices and test once we have the environment fully set up." The
  environment is now set up, and on 2026-11-22 he said to go ahead. The spec for that test
  waits for his approval, with its one question, the spend.
- Geoff ruled on 2026-11-22, while the spec was designed: the test covers the written spec
  and leaves out the design conversation; specs are written on Fable at `high` ("Let's go with
  the Anthropic recomendation."); no run compares against a session with no guide; and a long
  spec for a small change is a failure ("Yes, that's too long for a small change").
- Pull request 23 left three optional review notes. `.gitignore:4` matches session files only
  at the top of a case folder, `scripts/run-evals.sh` works only from the repo root, and
  `BACKLOG.md` lost its `## Low` heading.
- Pull request 264's two notes and pull request 265's description limit for the survey skill
  are under "Current state". Each stands unless Geoff objects.
- Geoff asked on 2026-11-21 for Chromium to be trimmed to what development work needs. It is
  item 109 in the workstation backlog and is no part of this spec.
- The `claude auto-mode critique` of the first settings change said the entry for build
  sessions doesn't say what shows that Geoff approved a spec. Geoff hasn't ruled on it. The
  critique run after the switch returned no feedback, twice.
- Pull request 13 left two things for a later look: `DESIGN.md` in `glw907/survey` still says
  "the approval queue" in four places (its backlog item 10), and the survey skill's description
  ends on a clause that addresses Claude.
- "The plugin" added `BACKLOG.md` and `.claude/project-tracking.json` to the public `standards`
  repo, outside its task's table. They stay unless Geoff objects.
