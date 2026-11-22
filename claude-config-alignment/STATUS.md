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
  `approval-queue land` is retired. Two of 259's done items stay open until they can run:
  `gh pr merge --help` in Geoff's session, and the next approved pull request stopping at the
  prompt.
- The build session made one call the spec didn't name. `claude-tooling-sync` caps a skill's
  description at 500 characters and now lets `building-from-specs` alone run to 1,536, because
  the approved text is longer than 500.
- The workstation gate failed on `main` on pavilion after pull request 260 named
  `~/.local/zen`, a path only thinkpad-x1 has. Commit `3a2fe1c` marks the two lines, and the
  gate passes again.
- The companion `specs/2026-11-20-alignment-global-file.txt` is one bullet behind the live
  global file. Pull request 260 reworded the browser bullet while 259 was open, and the merge
  kept 260's wording.
- Another session sits in the `~/.dotfiles` main checkout with uncommitted work. That checkout
  is one backlog commit behind `origin/main`.

## Next action

A fresh session of Geoff's starts the five tasks under "Side by side" in the spec. Its launch
prompt is `plans/2026-11-21-side-by-side-prompt.txt`. Four of the tasks are background sessions
and "Memory stores" is attended. "Retiring the old process" follows once all five have merged.

## Open decisions

- The rulings file owes Geoff one question about where cc-desk's scheduled check-ins come
  against the rewrite of Move. It is about later work and is not asked until that work starts.
- The parked questions are listed in the rulings file under "Parked until the workstation is
  aligned". None is asked until a spec needs its answer.
- Geoff asked on 2026-11-21 for Chromium to be trimmed to what development work needs. It is
  item 109 in the workstation backlog and is no part of this spec.
- The `claude auto-mode critique` of the first settings change said the entry for build
  sessions doesn't say what shows that Geoff approved a spec. Geoff hasn't ruled on it. The
  critique run after the switch returned no feedback, twice.
