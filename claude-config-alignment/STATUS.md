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
  one Opus reader compared the local skill with local practice. The spec is not written yet.
- The plugin's session met a new stop. The `/goal` checker answered "not met" 11 times in about
  two minutes over the item marked unmet, then marked the goal failed, and the session sat
  blocked on a question nobody was reading. Geoff's session stopped it. The row is in cc-desk's
  lessons file, commit `c353960`.
- "Survey" is building in the background session `alignment-survey` in `~/Projects/survey`,
  launched at 15:32 on 2026-11-21 on Opus at high effort, with a time clause of 150 minutes.
  Pull request 13 in `glw907/survey` is marked ready, and the session was still working at
  16:41, so it is not merged.
- "Configuration cleanup" is done. Pull request 262 in `glw907/workstation` merged as `9796bf9`
  on 2026-11-21, reviewed with an accept and no open finding. It took 11 minutes against 125
  planned. Both after-merge checks are posted on the pull request: a `.yml` under `styles/`
  loads the Vale rule and a `.css` file loads none, and a task-shaped request calls the
  `bluefin-admin` skill. A plain question about a doc was answered by search without the skill.
  Commit `1773529` drops the retired instructions folder from one auto-mode allow entry, and
  `claude-tooling-sync verify` passes. The session and its branches are removed.
- "Personal skills" is building in the background session `alignment-personal-skills` in
  `~/.dotfiles`, launched at 16:40 on 2026-11-21 on Opus at high effort, with a time clause of
  270 minutes. Geoff's session launched it before Survey ended and told it to start no
  evaluation session while Survey is working, which keeps pavilion at four.
- "Memory stores" is done. Geoff kept three of the 11 files in the `/home` store, and they are
  in the `/var/home` store, whose index has 20 lines for 20 files. Commit `39f36df` in
  `glw907/workstation` adds `cd -P .` to the `claude` function, and the gate passed before it.
  The `/home` store's folder is gone. A print-mode session started from `/home/glw907` and one
  from `/var/home/glw907` each named `~/.claude/projects/-var-home-glw907/memory/`. The search
  for the retired words over the store prints nothing.
- The `~/.dotfiles` main checkout is level with `origin/main` at `1773529`. Geoff's session
  `dotfiles-17` sits idle in it, so the busy check exits 1 there. Geoff ruled earlier on
  2026-11-21 that the workstation launches may go ahead past that check. Two uncommitted files
  from another session are still there: `google-workspace.md` under
  `claude/.claude/docs/bluefin-admin/` and `bin/.local/bin/sheet-revision`.
- Weekly usage was 15 percent at 16:41 on 2026-11-21.

## Next action

Geoff's session runs the tasks from `plans/2026-11-21-side-by-side-prompt.txt`. When
`alignment-survey` or `alignment-personal-skills` ends, it reads the pull request, tells Geoff
what it found, and merges it. After each merge it runs the spec's after-merge steps, and after
Survey's it cuts the survey release. "Retiring the old process" follows once both pull requests
have merged and the release is cut.

Between those, it writes the follow-up spec for the plugin's evaluations and the brainstorming
skill, by `~/.claude/skills/building-from-specs/references/writing-a-spec.md`. It reads
`research/2026-11-21-brainstorming-followup/README.md` first. Any evaluation run it makes as a
probe counts against pavilion's limit of four working sessions.

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
- Pull request 262 names four habits from the retired operational rules that no loaded file
  carries now, and gives a section for the global `CLAUDE.md`. Geoff hasn't chosen which to
  keep: source `~/.local/secrets` in the same command before reading a secret; give
  `wrangler secret put` a `--name`; put a Node script with CSS selectors in a file; and use
  `gh issue list --search` when `gh issue view` fails. His session recommends the first two.
- "The plugin" added `BACKLOG.md` and `.claude/project-tracking.json` to the public `standards`
  repo, outside its task's table. They stay unless Geoff objects.
