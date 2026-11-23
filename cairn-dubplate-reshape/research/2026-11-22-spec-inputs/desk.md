# The cc-desk timer on 2026-11-22

`cc-desk-check.timer` fires every 5 minutes. Its service is described as "cc-desk check: read the
sessions, launch or relaunch work, merge ready pull requests" and runs
`~/.local/share/cc-desk/bin/cc-desk --state-dir ~/.local/state/cc-desk check`. The planning
prompt puts the timer and its release records on the leave-alone list.

- `~/.local/state/cc-desk/check-log.jsonl` holds 179 rows. `grep -c -E 'dubplate|cairn-cms'`
  finds 0. Every row names project `cc-desk`, and the last is 2026-11-20T22:47:31Z, when the
  desk stopped its own conductor at its relaunch limit.
- `~/.local/state/cc-desk/launch/` holds launch records for `cc-desk` and `cc-desk-scratch` only.
- `cairn-cms`'s `docs/STATUS.md` still says the desk launches round `surface` from
  `~/Projects/initiatives/theme-garden/plans/2026-11-17-route-surface-conductor-prompt.txt`
  "once its start line holds". The desk holds no record for that launch.

For the `cairn-cms` spec: the desk has never launched or merged in either repo, but `cairn-cms`'s
STATUS says it will. The spec's start conditions need that STATUS line gone, or a probe that the
desk can't act on the repo, before the first task launches.
