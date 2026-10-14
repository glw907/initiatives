# Triage rows the record set changes

Geoff's ROADMAP triage decisions (2026-10-14) fix each row's disposition: now, defer, or drop. The initiative record set of the same day (`2026-10-14-initiative-record-set.md`) overrides which record a row lands in. Each sweep session applies the table below to its repo and leaves every other row as the triage item submitted it.

| Repo | Row | Submitted | Applied |
|---|---|---|---|
| `907-life` | #1 907.life rebuild | now, record `survey-theme` | now, record `907-rebuild` |
| `907-life` | #2 ECXC standalone | drop | drop, with the reason "the standalone site already exists as ecxc-ski" |
| `ecxc-ski` | #1 ECXC standalone site | drop | drop |
| `cairn-themes` | #1 Survey S1 | now, record `survey-theme` | now, but no record: S1 stays the next action in `cairn-themes`' STATUS, and its BACKLOG gains no line |
| `cairn-themes` | #3 Survey S3 and #4 terrain hero | defer | defer, as BACKLOG lines in `cairn-themes` |
| `cairn-themes` | README | none | gains the `personal-styles` collection-shape note: a style sheet, a decision log, and benchmark renders |
| `aksailingclub-org` | #1, #10, #11 | defer | defer, and each BACKLOG line carries `#initiative:asc-cutover` |
| `phonebook` | #1 Household phonebook | now, record `household-phonebook`, repos `phonebook`, `cairn-themes`, `workstation` | now, record `household-phonebook`, repos `phonebook` and `cairn-themes`; its README records that the UI waits on Survey S1 in `cairn-themes` |
| `poplar` | #1 The re-founding | now, repos `poplar` and `workstation` | now, record `poplar-refounding`, repo `poplar` |
| `workstation` | #8 and #9 drafter follow-ups | defer, tagged to the drafter record | defer, tagged `#initiative:docs-system` |

Records the set creates that no `now` row names: `asc-cutover`, `ecxc-rebuild`, and `cairn-pub-rebuild`. Dropped without a record: `personal-design-system`, `survey-theme`, `ecnordic-standalone`, and `aksailingclub-mw-replacement`.
