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
- The second task, "The process skill", is running as the background session
  `alignment-process-skill` in `~/.dotfiles`, launched on 2026-11-21 with a time clause of 140
  minutes.
- The third task, "The switch", is built on the branch `alignment-switch` and open as draft pull
  request 259 in `glw907/workstation`. The workstation gate passes on it. Its first review found
  merge spellings the `ask` rules miss, such as `gh -R owner/repo pr merge 5`. The guard now
  sends those to a permission prompt, the spec says so, and a second review is running.

## Next action

The process skill's session is building draft pull request 258 in `glw907/workstation`. On
2026-11-21 Geoff approved pull requests 258 and 259 ahead of time: "I'm pre-approving both." His
session merges each one only after its review accepts with no open finding and its done items
hold. It merges 258 first and 259 second, and runs each one's after-merge steps. A finding that
changes what either pull request does goes back to Geoff first.

## Open decisions

- The rulings file owes Geoff one question about where cc-desk's scheduled check-ins come
  against the rewrite of Move. It is about later work and is not asked until that work starts.
- The parked questions are listed in the rulings file under "Parked until the workstation is
  aligned". None is asked until a spec needs its answer.
