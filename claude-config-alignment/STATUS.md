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
- "The plugin" is built and waits on Geoff. Pull request 22 in `glw907/standards` is ready with
  CI green. Seven of its eight done items are met. The sixth is unmet: `claude plugin eval
  plugins/standards` exits 1, because the `ts-conventions` case already on `main` fails two runs
  of three and one `brainstorming` run in three asks a compound question. Its review returned
  escalate on that item. Its session, `alignment-plugin`, is stopped and its worktree is kept.
- That session met a new stop. The `/goal` checker answered "not met" 11 times in about two
  minutes over the item marked unmet, then marked the goal failed, and the session sat blocked
  on a question nobody was reading. Geoff's session stopped it. The row is in cc-desk's lessons
  file, commit `c353960`.
- "Survey" is building in the background session `alignment-survey` in `~/Projects/survey`,
  launched at 15:32 on 2026-11-21 on Opus at high effort, with a time clause of 150 minutes. Its
  draft is pull request 13 in `glw907/survey`.
- "Configuration cleanup" is building in the background session `alignment-config-cleanup` in
  `~/.dotfiles`, launched at 16:11 on 2026-11-21 on Opus at high effort, with a time clause of
  250 minutes. Its goal carries one sentence the plugin's lacked, a call Geoff's session made
  after the stop above: the goal is also met when the pull request is ready and marks an item
  unmet with its reason.
- "Personal skills" (clause 270) waits for a slot. It and Survey each run evaluation sessions
  one at a time, and each of those counts against the limit of four, so it launches when Survey
  ends. Its goal text is written.
- "Memory stores" is done. Geoff kept three of the 11 files in the `/home` store, and they are
  in the `/var/home` store, whose index has 20 lines for 20 files. Commit `39f36df` in
  `glw907/workstation` adds `cd -P .` to the `claude` function, and the gate passed before it.
  The `/home` store's folder is gone. A print-mode session started from `/home/glw907` and one
  from `/var/home/glw907` each named `~/.claude/projects/-var-home-glw907/memory/`. The search
  for the retired words over the store prints nothing.
- The `~/.dotfiles` main checkout is level with `origin/main`. The session `dotfiles-1c` has
  ended, and its two uncommitted files are still there: `google-workspace.md` under
  `claude/.claude/docs/bluefin-admin/` and `bin/.local/bin/sheet-revision`.
- Weekly usage was 13 percent at 16:10 on 2026-11-21.

## Next action

Geoff's session runs the tasks from `plans/2026-11-21-side-by-side-prompt.txt`. It puts pull
request 22 to Geoff by number with the question under "Open decisions". When `alignment-survey`
or `alignment-config-cleanup` ends, it reads the pull request and puts it to Geoff by number.
It launches "Personal skills" when Survey ends. After each merge it runs the spec's after-merge
steps, and after Survey's it cuts the survey release. "Retiring the old process" follows once
all four pull requests have merged and the release is cut.

## Open decisions

- Pull request 22 waits on Geoff's answer about its unmet done item. The `ts-conventions`
  evaluation case requires the doc comment to say the exponent stops growing at attempt 30. It
  scores 0.33 with the plugin and 0.33 without, and it failed on `main` before this branch.
  Geoff's session recommends merging 22 as it stands and fixing the two cases in a follow-up.
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
