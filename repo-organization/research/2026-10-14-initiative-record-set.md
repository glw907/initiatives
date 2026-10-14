# Initiative record set

## Brief

Approving this sets the initiatives the new repo starts with: 15 records, replacing the design's list and the triage drafts wherever they disagree.

You made these calls in chat on 2026-10-14 after an adversarial review. The initiatives session applies this list as written, so the records match what you ruled, and the triage items you already submitted stay as they are.

### What changes

- `docs-system` replaces the `drafter` record. It covers the drafter pipeline, the page outline standard, and the Claude infrastructure the pipeline runs on, and it changes how every project's docs are handled.
- Four new records: `asc-cutover` for the club's move off the legacy site, and three rebuilds (907.life, ecxc.ski, and cairn.pub) that wait on the cairn docs standard.
- No records for `personal-design-system`, Survey, `cairn`, or `ecnordic-standalone`. Survey S1 stays the next action in cairn-themes.
- `xcathletes-data-contract` starts paused.
- The initiatives README gains a products table: cairn, the docs system, the club site, and the workstation, each with its repos and the initiatives that serve it.

### If you approve

1. The initiatives session writes the 15 records and the products table into PR 1.
2. Drafter's past docs move under `docs-system/` instead of `drafter/`.
3. Where a triage row you submitted named a record this list drops or renames, the session applies the record shown here and lists each such row in the PR body.

### Worth knowing

Products never end and initiatives do, so a product goes in the README table and only a bounded effort gets a record. That is why cairn and the workstation have no umbrella record.

### The records

The table below lists every record with its status and repos; the next section gives each new record's scope.

| Record | Status | Repos |
| --- | --- | --- |
| `repo-organization` | active | initiatives, workstation, drafter, approval-queue, and each repo whose ROADMAP or docs it changes |
| `docs-system` | active | drafter, workstation |
| `approval-queue` | active | approval-queue, workstation |
| `cairn-docs-standard` | active | cairn-cms, workstation, ecxc-ski, 907-life, aksailingclub-org, xcathletes-org, cairn-pub |
| `monthly-model-review` | active | workstation |
| `asc-cutover` | active | aksailingclub-org, aksailingclub-legacy |
| `dubplate-server` | active | dubplate |
| `household-phonebook` | active | phonebook, cairn-themes |
| `poplar-refounding` | active | poplar |
| `shared-standards` | proposed | workstation |
| `workstation-secrets` | proposed | workstation |
| `907-rebuild` | proposed | 907-life |
| `ecxc-rebuild` | proposed | ecxc-ski |
| `cairn-pub-rebuild` | proposed | cairn-pub |
| `xcathletes-data-contract` | paused | xcathletes-org |

### Scope of the new and changed records

Each new or changed record's goals and non-goals are fixed here so its README can be written from them.

- `docs-system`: the record the design called `drafter`, widened. Goals: the generation pipeline in drafter, the page outline standard, the Claude infrastructure the pipeline runs on (its agents, registers, and gates), and a documented way to handle docs for any project. Non-goals: packaging the standards for outside developers, which is `shared-standards`, and any one project's docs content. Done when the system is built and the projects use it. Its README says drafter is the pipeline's home and that drafter passes 1 to 5 are its history.
- `asc-cutover`: goals are go-live of aksailingclub-org in place of the legacy site. The record is done when the apex cutover is made, MW is retired, and `aksailingclub-legacy` is archived. Named blockers: the CSRF and Referrer-Policy defect, and the payments hardening and live smoke. Non-goals: member waivers, the member directory, QuickBooks, club notifications, season rollover, and class management. MW goes in "Where the work lives", since it isn't a repo. The aksailingclub-org rows #1, #10, and #11 stay deferred as you submitted them, and their BACKLOG.md lines carry `#initiative:asc-cutover`.
- `907-rebuild`: rebuild 907.life on the current cairn, re-skinned on Survey, including Survey's cairn layer (S2). The Survey core (S1) is a non-goal. It starts once `cairn-docs-standard` completes.
- `ecxc-rebuild`: rebuild ecxc.ski on the current cairn. It starts once `cairn-docs-standard` completes. The site's current pre-announce gate in its STATUS is not part of it.
- `cairn-pub-rebuild`: rebuild cairn.pub on the current cairn and make it the site `docs-system`'s pipeline publishes to, with the resulting workflow for ongoing cairn docs improvements written down. Non-goals: the docs standard itself (`cairn-docs-standard`) and the pipeline's internals (`docs-system`). It starts once `cairn-docs-standard` completes.
- `cairn-docs-standard`: its README names `docs-system` as what it builds on.
- `xcathletes-data-contract`: paused, because its Pass 4 is parked.
- `household-phonebook` and `poplar-refounding` drop `workstation` from their repos. The phonebook README records that its UI waits on Survey S1 in cairn-themes.

### What this replaces

These records from the design or the drafts are not created; each is handled as shown.

- `drafter` becomes `docs-system`. Every migration-map row whose initiative is `drafter` moves to `docs-system`, with its `new_path` under `docs-system/`. The drafter follow-up (I11) copies to that path. The thinkpad leg folds `batched-docs-tool-initiative.md` into `docs-system/README.md`.
- `personal-design-system` is dropped. The `personal-styles` collection-shape note (a style sheet, a decision log, and benchmark renders) goes into cairn-themes' README, so the idea survives the repo's deletion.
- `survey-theme` and `survey` are not created. 907-life #1 becomes `907-rebuild`. cairn-themes #1 (Survey S1) stays the next action in cairn-themes' STATUS, and S2 belongs to `907-rebuild`. S3 and the terrain hero become cairn-themes BACKLOG.md lines.
- `ecnordic-standalone` is dropped. That standalone site was built long ago, and the project's name is ecxc. ecxc-ski #1 is applied as drop, and 907-life #2's reason reads "the standalone site already exists as ecxc-ski".
- `aksailingclub-mw-replacement` becomes `asc-cutover`, as above.
- `cairn` and a workstation umbrella are not created. They are products, listed in the README table.

### The products table

The initiatives README carries this hand-written table beside the generated index; no tool reads it.

| Product | Repos | Initiatives serving it |
| --- | --- | --- |
| cairn | cairn-cms, cairn-pub, cairn-themes | cairn-docs-standard, cairn-pub-rebuild |
| Docs system | drafter, workstation | docs-system, cairn-docs-standard |
| Club site | aksailingclub-org, aksailingclub-legacy | asc-cutover |
| Workstation | workstation, initiatives | repo-organization, approval-queue, monthly-model-review, workstation-secrets, shared-standards |

A `product:` field in `initiative.yaml` goes in the plan's "Later", for the approval-queue grouping work that would first read it.

## Technical notes

Rulings by Geoff, 2026-10-14, in the conductor-initiatives session, after a fresh-context adversarial review of the drafted record set. This item overrides plan task I2's list of eight records, and each triage row whose proposed record id this list drops or renames. A triage decision still governs the row's disposition (now, defer, or drop). This item governs which record a `now` row lands in, and which record a `defer` row's `#initiative:` tag names. Where a `now` row's record is not created here, the row's work stays in its repo's STATUS or BACKLOG as the sections above say, and the PR body lists it. The initiatives executor commits this file to `repo-organization/research/2026-10-14-initiative-record-set.md` in PR 1.
