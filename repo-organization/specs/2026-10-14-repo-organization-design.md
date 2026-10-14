# Repo organization design

## Brief

Approving this design starts a pass that gives every initiative a written record in a new initiatives repo, moves past work to the repo where it belongs, and deletes eleven repos and folders you no longer use.

Work that spans repos has no home today, so its specs and plans pile up in `workstation`. Neither you, a session on either machine, nor a future collaborator can look up where new work belongs. The approval queue's project grouping and the shared standards effort both build on these records, so this pass comes first.

### What changes

- A public `glw907/initiatives` repo holds one record per initiative, with its goals, non-goals, repos, and status.
- Every session prints the initiatives its repo serves when it starts.
- ROADMAP.md retires in every repo, and each of its entries becomes a record, a backlog item, or nothing, by your call. `cairn-cms`'s 284-entry file gets a follow-on pass of its own, as you ruled on 2026-10-14.
- Cross-repo specs and plans move to their initiative, and another repo's single-repo docs move into that repo.
- The drafter pieces in `workstation` move to `drafter`, and the approval queue moves to a public repo of its own, both with their history.
- The pass deletes eleven repos and folders, and tears down only the Cloudflare resources that nothing else uses. `aksailingclub-legacy` still serves the live club site, so it leaves this pass and archives with the cutover, as you ruled on 2026-10-14.

### If you approve

1. The session writes the pass plan, and you review it before the pass starts.
2. Before the pass starts, you read and merge a small `auth-data` PR in `workstation` that commits the uncommitted `secrets/values.age` change with its `DRAFTER_API_KEY` entry in `secrets/registry.md`.
3. Before the pass sends any design item, you read and merge `workstation`#71, which makes a design's `### Decide:` picks reach the session, and the session rebuilds and restarts the queue so the fix is live.
4. The pass builds the initiatives repo, the records, and the tooling, and opens a PR in each repo it touches.
5. You make the ROADMAP calls in one triage item per repo.
6. Before the pass removes anything, you confirm one dry-run item that lists every deletion, teardown, shared resource left in place, and GitHub description.
7. You run `gh auth refresh -s delete_repo` once when the pass reaches the deletions, and you revoke the account-owned scratch-site token in the dashboard, which the pass's token can't do.

### Decide: estimate ceiling

The design estimate is 840 path minutes. A plan or a run that goes past a ceiling you set comes back to you with the reason before it continues.

Source: `pass-core`, "Plan"

- Allow up to twice the estimate, 1,680 minutes (recommended)
- Allow up to one and a half times the estimate, 1,260 minutes

### Worth knowing

Six of the retiring directories have no remote. The pass deletes `healthy-diet`, `pings`, and `personal-styles` without a backup copy, as you ruled on 2026-10-14. It saves `cairn-scratch`, `ecxc-ski-agent-memory`, and `aksailingclub-sveltekit` to one tar archive first, because cairn-cms records cite `cairn-scratch` as evidence, as you ruled on 2026-10-14. The 2026-10-12 handoff bundle on R2 also holds older copies of all six, and the pass leaves it as it is.

### The rulings behind this design

You made every call in this design in chat on 2026-10-14. Initiatives are the unit of grouping, recorded in a central repo in the shape of a Kubernetes enhancement proposal (KEP). Cross-repo specs and plans live with their initiative, and past work migrates. Shared standards is a separate initiative that comes next. ROADMAP.md retires everywhere. Drafter and the approval queue move out of `workstation`, and `workstation` otherwise stays as it is. The pass deletes the local-only repos outright. On the same day you ruled on the three questions the review opened: `aksailingclub-legacy` leaves this pass, the three unruled folders go to one tar archive, and `cairn-cms`'s ROADMAP retires in its own pass.

## Scope

This pass builds the initiative records and the tooling that keeps them in use. It migrates past docs, moves two bodies of code out of `workstation`, and retires unused repos. Each repo's `BACKLOG.md` and `STATUS.md` stay as they are. The backlog holds single pieces of work, and STATUS holds a repo's current state.

The pass leaves the following work to later initiatives:

- The approval queue's grouping by initiative and its new sidebar, which follow this pass with prototypes.
- Shared standards, a Claude Code plugin marketplace that carries the skills, registers, and agents an outside developer would need. Until it lands, the `cairn-docs-drafter` and `cairn-register-editor` agents and the `approval-brief.md` register stay in `workstation`.
- Any move of code beyond the drafter and approval-queue moves.
- The retirement of `cairn-cms`'s ROADMAP, a follow-on pass under the `repo-organization` record, and the archive of `aksailingclub-legacy`, which the club's cutover pass closes with (Geoff, 2026-10-14).

The pass is class `runner`, because it edits skills, settings, scripts, and tests. It carries the `live-account` flag because it deletes GitHub repos and tears down Cloudflare resources. The only Cloudflare data it destroys is scratch and staging data, listed by id in the dry-run item Geoff confirms, so no task rises to `auth-data`.

Drafter pass 5 is in flight. This pass starts its drafter moves, and moves the docs pass 5 reads by path, only after pass 5's PRs merge.

## The initiatives repo

The repo is public, like `workstation`, which already publishes every spec and plan these records summarize. Both machines clone it at `~/Projects/initiatives`. The following tree shows its layout.

```
initiatives/
├── README.md            what an initiative is, how to place work, the index
├── REGISTER.md          the voice ruling for this repo
├── scripts/check        validates every record and the index; runs in CI
└── <id>/
    ├── initiative.yaml
    ├── README.md
    └── specs/  plans/  research/    cross-repo docs only
```

An initiative's `initiative.yaml` holds only the fields that tools read. A record's status is one of `proposed`, `active`, `paused`, `done`, or `withdrawn`. The `repos` list holds GitHub repo names only. Surfaces that aren't repos, such as Google Docs, go in the README's "Where the work lives".

```yaml
id: drafter
title: Drafter
summary: Generates cairn docs pages from page plans through a gated pipeline.
status: active
owner: glw907
created: 2026-10-12
repos: [drafter, workstation]
```

The record's `README.md` takes the KEP sections a small team needs: Summary, Motivation, Goals, Non-goals, Where the work lives, and Records. "Where the work lives" gives one line per repo or surface saying what it carries, and "Records" links the initiative's specs, plans, and PRs. A status change adds a dated line to the README, so the history stays with the record. The non-goals carry the most weight, because they're what settles whether a piece of work belongs to the initiative.

The top-level README states the placement rule as the following steps:

1. Work belongs to an initiative when it serves one of the initiative's goals and no non-goal excludes it.
2. When no record fits, the work is ordinary work for that repo's backlog or the start of a new initiative, which gets a `proposed` record.
3. A fix with no larger purpose needs no initiative.

The same README also notes that `~/Projects/workstation` is a symlink to `~/.dotfiles`, so both names refer to the same repo. A script generates the README's index table from the YAML files.

`scripts/check` fails, naming the file, on each of these states: no records at all, a directory without `initiative.yaml`, YAML that doesn't parse, an `id` that differs from its directory name, a duplicate `id`, an unknown `status`, a missing required field, a `repos` entry that isn't a `glw907` repo, and an index that disagrees with the YAML. Its tests carry one bad fixture per state. Several listed repos are private, so CI checks every state but the `repos` one. `scripts/check --repos` runs that one locally against `gh repo list glw907` under Geoff's login, which sees private repos. The pass creates `glw907/approval-queue` empty before the initiatives repo merges, so the records name a repo that exists.

`REGISTER.md` records Geoff's ruling of 2026-10-14 that the repo's prose follows the cairn developer-docs brief in `cairn-cms/docs/internal/docs-register.md`, on the Google developer documentation style guide. Until now the brief has governed only cairn's surfaces, and the file records that extension with its provenance, as the voice system requires of any overlay.

The pass writes these records first:

| Record | Status | Repos |
|---|---|---|
| `repo-organization` (this effort) | `active` | `initiatives`, `workstation`, `drafter`, `approval-queue`, and each repo whose ROADMAP or docs it changes |
| `drafter` | `active` | `drafter`, `workstation` |
| `approval-queue` | `active` | `approval-queue`, `workstation` |
| `cairn-docs-standard` | `active` | `cairn-cms`, `workstation`, `ecxc-ski`, `907-life`, `aksailingclub-org`, `xcathletes-org`, `cairn-pub` |
| `monthly-model-review` | `active` | `workstation` |
| `personal-design-system` | `proposed` | `907-life`, `cairn-themes`, `approval-queue` |
| `shared-standards` | `proposed` | `workstation` |

The ROADMAP triage adds further records. The personal design system's record links Survey in `cairn-themes`, the 907-life theme, the approval queue, and Docs letterhead as the pieces it would unify. It also records that the deleted `personal-styles` repo defined a collection shape (a style sheet, a decision log, and benchmark renders) worth reusing.

## Rules and tooling

The pass gives each rule a home where it runs, so that sessions find the records and keep them current.

ROADMAP.md retires in every repo but `cairn-cms` and `aksailingclub-legacy`. Those repos hold about 80 entries, 22 of them in `workstation`. An entry is a top-level bullet, or a `###` heading in a repo that uses headings, and the triage item states each repo's count. The session drafts a disposition for each entry, which is to become a record, to move to the repo's `BACKLOG.md`, or to be dropped. Geoff makes the calls in one approval-queue triage item per repo, and the pass applies them and deletes each ROADMAP.md. The applied dispositions must equal each repo's count.

ROADMAP is read and written beyond the skills named below. The plan's file list takes the whole set: `log-issue` and its `roadmap_path` and `#project:<slug>` tag, the 32 `#project:` tags in `dubplate` and `xcathletes-org` backlogs, every `.claude/project-tracking.json`, the `cairn-pass`, `site-pass`, `cairn-release`, `dependency-upgrade`, `pass-core`, `claude-infra`, and `cairn-figure` skills, and `claude-memory-write-check`. A `#project:<slug>` tag becomes `#initiative:<id>` or goes, by its entry's disposition. Under the follow-on ruling, references to `cairn-cms`'s ROADMAP stay until its own pass.

The SessionStart hook, which already prints `## Host`, also prints the `active` and `proposed` initiatives whose `repos` include the session's repo, each with its `summary`. The hook names the repo from the `origin` remote's basename, resolved through `git rev-parse --git-common-dir` so a worktree session gets its parent repo. The `~/.dotfiles` checkout therefore resolves to `workstation`. It reads the YAML with `yq`. A missing clone prints `initiatives: no clone at ~/Projects/initiatives`, a record that fails to parse prints `initiatives: unreadable <file>`, and no match prints nothing. The hook always exits 0.

The hook's tests cover each of these states against a fixture initiatives tree.

No CLAUDE.md lists initiatives by name, which keeps a hand-kept list from drifting. The global CLAUDE.md sits one line under its 200-line cap, so the placement rule enters as one line that points at the initiatives README, and an equal count of lines moves to `claude-md-archive.md` if the line doesn't fit an existing section.

Three skills change in their own right:

- `log-project` creates and updates records in the initiatives repo, and never creates a ROADMAP.md.
- `pass-core`'s design step names the initiative or says none applies. A session writes a cross-repo spec or plan in `initiatives/<id>/`, and the plan header carries an `Initiative: <id>` line.
- `dotfiles-pass` and the other adapters point at the new location for cross-repo docs.

Each rule and tooling change in this section carries its own acceptance check in the plan, with a failing fixture wherever the check could pass on nothing.

`bluefin/bootstrap.sh` clones the initiatives repo and runs the `drafter` and `approval-queue` install steps. `check-drift` warns when the clone is missing, and checks whether it's behind its remote with `git ls-remote` under a short timeout, reporting an unreachable remote as its own non-failing line. The one machine-local memory about an initiative, `batched-docs-tool-initiative.md`, isn't on pavilion, where only its `MEMORY.md` index line remains. The pass takes the file from the thinkpad if it's there, folds it into the drafter record, then deletes it and its index line on both machines. If it's on neither machine, the pass records it as lost and removes the index line.

## Migration of past work

`workstation`'s `docs/superpowers/` holds 173 entries: 25 specs, 60 plans, and 88 research files and folders. About 41 distinct paths in other repos point into it. Each entry goes where the new rule would have put it:

- Cross-repo work, such as drafter's specs and the docs standard's infrastructure plan, moves to `initiatives/<id>/`.
- Another repo's single-repo work moves into that repo's `docs/superpowers/`. The dubplate Go rewrite, the uploader, the music VPS, and the poplar adapter are the known cases.
- Work that concerns only `workstation`, such as the pass process, the infrastructure sweeps, and the Thunderbird theme, stays.
- The pings plans leave the tree with the pings repo and remain in `workstation`'s history.

A script classifies every entry and writes `migration-map.tsv`, which lists the old path, the new path, the initiative, and a collision state for each entry. The map has exactly one row per entry at the pass's start commit, and every row has a new path or says `stays`, `leaves-with-pings`, `deferred:<pass>`, or `flagged`. The script marks an entry the rule can't place `flagged`, a fixture entry must come out that way, and no copy runs while a row is `flagged`. Geoff's call replaces the state. A destination that already holds a file of the same name, `archive/` included, is a collision: an identical file means the source is deleted and its references point at the existing file, and a differing one goes to Geoff, with the destination kept by default. Three of dubplate's five cases differ. The pass commits the map so the move stays auditable.

Docs move by copy and delete. Each destination repo receives its files in one commit whose body names the source `workstation` commit, and `workstation` then deletes them while its history keeps the originals. The pass doesn't graft docs history across repos with `git filter-repo`, since the source commit is one `git show` away. The `workstation` deletion PR stays a draft until a check confirms two facts: every destination path exists on its repo's `origin/main`, and `git diff <source commit> origin/main` over every moved path is empty. A non-empty diff means a session edited a moved file after the copy, and the pass re-copies it.

One reference tool, with a check mode and an apply mode, rewrites and checks paths over one shared scope. The map is keyed on the source repo and the path. A bare `docs/superpowers/` path resolves against the repo that contains it, since a dozen repos carry their own tree, and a `~/`, `/var/home/`, or `~/Projects/<repo>/` path resolves literally. It matches the old paths, the new `initiatives/<id>/` paths, the moved code paths, paths into retired repos, and links to a retired ROADMAP.md, and gives each class a disposition:

- A reference to a moved docs entry or code path is rewritten. Moved code paths get map rows like the docs entries, and the tool edits only references that resolved to a moved entry before the move.
- A reference to a retired repo or ROADMAP from a history file (`docs/superpowers/`, `docs/internal/record/`, `docs/internal/history/`, or `HISTORY.md`) stays as written. The check mode lists it in a `retired-target` class and never fails on it, since a retired target has no new path. About 230 files mention a ROADMAP, most of them history, and `cairn-cms` cites `~/Projects/cairn-scratch/` in about 16 docs.
- A reference from a live file, such as `secrets/registry.md`, `bash/.bashrc`, or a skill, is a tie the inventory lists, and the pass edits it by hand.

Its tests plant a reference to a missing `initiatives/<id>/` path, which the check mode must report.

The scope is git-tracked text files. Apply mode reads each repo's pass worktree, never its main checkout and never through the `~/.claude` symlinks. Check mode on the thinkpad reads its main checkouts, since it has no pass worktrees. It excludes `.claude/worktrees/`, lockfiles, `_salvage/`, and a named list of fixtures that record past PRs or runs, such as `tests/fixtures/ci-green/pr-107-files.txt`. Memory files join the scope as `~/.claude/projects/*/memory/*.md` only, without `*.tmp` files. The tool tars those directories before its first write, and writes each file through a temp file and a rename. Transcripts, `history.jsonl`, `file-history/`, `plugins/`, and `sessions/` stay outside the scope. Paths are deduplicated by `realpath`, and a second apply run must change nothing.

The check mode runs once before the migration to record the references already broken, keyed by machine, file, and path, and once after, when it must find nothing new. The pass regenerates only the test goldens whose embedded path the map changes, after the drafter extract, so each passes in the repo that now holds it. The rewrite reaches `docs/HISTORY.md` despite its freeze under ruling 8, since a path fix leaves its content unchanged (Geoff, 2026-10-14).

The PRs merge in an order that leaves no file or command without a home:

1. `glw907/approval-queue` exists empty, then the initiatives repo merges, then `dubplate`, then `poplar`, so every destination holds its files.
2. The `drafter` and `approval-queue` extracts merge.
3. The reference fixes merge in `cairn-cms` and the other repos.
4. `workstation`'s deletions merge last.
5. On each machine, the pass pulls, runs `stow -R bin claude`, and then runs both install steps.

Before it moves any plan, the pass runs the one-executor-per-worktree checks. A plan with an open pass stays where it is, marked `deferred:<pass>` in the map with a `workstation` backlog item, until that pass closes and a short follow-up moves it.

## Code leaving workstation

Code moves with its history, unlike docs. For each move, `git filter-repo --path` extracts the history on a fresh clone of `glw907/workstation` from GitHub, never with `--force`. filter-repo aborts on a clone whose HEAD reflog holds more than one entry, so the clone never moves HEAD after it's made. It pins its commit at clone time with `git clone --revision=<sha>`, or clones `main` and records `git rev-parse HEAD`, and the map records that commit. The filter-repo manual warns, "renames are NOT followed so you may need to specify multiple paths", so each extract lists every path its files ever held, such as the `review-desk` names the approval queue carried before 2026-10-12. Before the push, the extract's tip tree must equal the source tree at the pinned commit, and each moved file's first commit in `workstation` must map to its first commit in the extract through `.git/filter-repo/commit-map`, which filter-repo writes on every run. filter-repo rewrites the hash of every commit whose tree it prunes, so a direct hash comparison would fail on a correct extract. The pass installs `git-filter-repo` through Homebrew and records it in the Brewfile.

The drafter pieces move to `drafter`: the docs page chain workflow (`claude/.claude/workflows/docs-page-chain.js`), its `cairn-docs-outline` helper (`bin/.local/bin/cairn-docs-outline`), `scripts/drafter-gate.sh`, five tests, and their fixtures under `tests/fixtures/docs-page-chain/` and `tests/fixtures/drafter/`. The extract keeps its paths and merges into `drafter` as unrelated history. `git log` on a moved file then still reaches its first commit. Two tests read agent files that stay in `workstation`, and they find them through a `WORKSTATION_DIR` that defaults to `~/Projects/workstation`. The four gate legs leave `workstation`'s `scripts/check.sh` and join `drafter`'s `make check`, which stays a local gate as it is today. The `cairn-run-gate` test drops its moved path, and its assertion travels with the workflow.

`~/.claude/workflows` is a folded stow link today, and `docs-page-chain.js` is the only file under it. A scratch probe showed that once `workstation` deletes the file, `stow -R claude` removes the dangling link, and that a real directory in its place holds both an outside link and any later stowed file without touching the `workstation` tree. So `drafter`'s install step runs after that restow, creates `~/.claude/workflows` as a directory, and links the workflow and the helper with `ln -sfn`. The `claude-tooling` manifest records the workflow's new source repo.

The approval queue moves to a new public `glw907/approval-queue` repo built from its extract. Its history is already public in `workstation`. The move carries the app's 60 tracked files, the `approval-queue` command, the `claude-approval-queue-reminder` hook script, and the tests for both. The extract keeps `bin/.local/bin/approval-queue` and `approval-queue/` at its root, since the command finds the app by that relative layout. The test that reads the brief register finds it through a `REGISTER` variable that defaults to `~/.claude/docs/voice/approval-brief.md`, the path `src/lib/brief.ts` already names. The repo's install step links the two commands into `~/.local/bin` on both machines. The hook's entry in `settings.json` stays in `workstation` and calls the command by name. The app's gate leg becomes the new repo's local gate.

The pass relies on the queue for its triage and dry-run items, so the queue moves after Geoff confirms the dry run. The move then stops the server on port 7907 and removes the untracked `node_modules/` and `build/` left under `~/.dotfiles/approval-queue/` on both machines.

`workstation` otherwise stays as it is, and the `~/Projects/workstation` symlink stays with it.

## Repo retirement

The pass retires the following repos and folders:

- Delete: `cairn-scratch-b`, `displaywidth`, `kit`, `jrnl-md`, `hugo-blog-template`, `personal-styles`, `aksailingclub-sveltekit`, `cairn-scratch`, `healthy-diet`, and `pings`.
- Fold, then delete: `ecxc-ski-agent-memory`, whose facts that still hold move into `ecxc-ski`.
- Out of this pass: `aksailingclub-legacy`, which deploys the live site, runs the club's daily Workspace sync, and holds the ASC secret store. The cutover pass archives it (Geoff, 2026-10-14).

Before deletion, the pass saves `cairn-scratch`, `ecxc-ski-agent-memory`, and `aksailingclub-sveltekit` to one tar archive outside `~/Projects` (Geoff, 2026-10-14).

Every retirement follows the same steps:

1. An inventory script lists each target's kind (`git`, `orphaned-worktree`, or `plain-dir`) and its ties. A git target lists its unpushed branches and stashes. The other two kinds list their files and modification times, and are marked unrecoverable once removed. Each GitHub repo lists its open PRs, issues, releases, and branches that aren't in its upstream, and a fork also lists the open PRs it carries on its parent. The script also finds references from other repos and `~/.claude`, manifest entries such as Brewfile lines, the bootstrap and `.bashrc` lines that name a target, and age-registry secrets whose "Used by" points into it.
2. The script derives Cloudflare ties from each target's own files, never from names: every `wrangler.*` name and binding, and every workflow's deploy targets. It covers Workers, routes and custom domains, cron triggers, D1, KV, R2, DNS records, Access applications, Email Routing, and API tokens. It resolves each resource by id across every surviving repo's wrangler configs and marks it `sole-owner` or `shared-with <repo>`. Only `sole-owner` resources are torn down, and the pass commits each one's kind and id as a `cloudflare` row of `retire-manifest.tsv` in this initiative's `research/`. `aksailingclub-sveltekit`, for instance, binds the `asc-handbook` and `asc-uptime` Workers and the `asc-event-images` bucket that `aksailingclub-legacy` also binds, so they stay.
3. The script sources `~/.local/secrets` itself and exits nonzero on any API or auth error, so an empty answer never reads as "no ties". Its tests run it against a fixture of known ties, such as the `pings` Worker and `PINGS_ADMIN_TOKEN`, and it must report each one.
4. One approval-queue item shows the dry run: every target with its action, every resource to tear down, every shared resource left in place, every manifest line to remove, the GitHub descriptions from the next section, and a "Geoff does by hand" list that starts with revoking the account-owned scratch-site token. Before it asks for the confirmation, the pass checks that the `auth-data` PR from the brief has merged and that `secrets/values.age` is clean and at `origin/main` on both machines.
5. After Geoff confirms, the pass works in stages across every target: every Cloudflare teardown, then one commit of the age-store and `registry.md` edits from the pass worktree, then every `gh` delete, then every local removal. A rerun skips a finished stage. The store commit waits on the `auth-data` PR that commits the earlier `values.age` change and its `DRAFTER_API_KEY` entry, which Geoff reads before the pass starts.
6. A short script performs the same local cleanup on the thinkpad. It first runs the inventory's local legs against the thinkpad's own clones, prints its dry run with the remote-less directories it holds, and refuses a target with unpushed or uncommitted work.

## Worktrees and descriptions

The pass lists every worktree in every repo with its branch, whether it's merged, whether it's locked, and whether it has uncommitted or ignored files. A worktree is merged when its branch's PR is merged or its tip is an ancestor of `origin/main` after a fetch. The pass removes a worktree only when it's merged, clean under `git status --ignored`, unlocked, unused by any process (`pgrep -f <path>`), and untouched for a day. A worktree whose branch still equals its base is new, not merged. The drafter `agent-*` worktrees from passes 1 to 4 qualify once pass 5's PRs merge, and `p5-scratch` and `drafter-pipeline` under `cairn-cms/.claude/worktrees/` qualify if they pass. Any other worktree goes in the dry-run item for Geoff's call.

`cairn-cms`, `poplar`, `907-life`, `cairn-pub`, and `phonebook` have no GitHub description, and `workstation`'s still describes an Ubuntu setup. The pass drafts a one-line description for each, and for the new `approval-queue` repo, in this repo's register. The descriptions ride in the dry-run item and are set after Geoff confirms it.

## End-to-end check

On the thinkpad, after it pulls every repo and runs the install steps in the merge order, the pass runs the following checks in order:

1. The reference tool's check mode reports no broken path beyond the thinkpad's own baseline and the `retired-target` class, which the thinkpad script records before it pulls, and finds no broken path in the thinkpad's memory files after its local rewrite.
2. A session opened in `drafter` prints the drafter record at startup, a session in `~/.dotfiles` prints the `workstation` records, and a session in a worktree prints its parent repo's records.
3. With no process on port 7907 and no `~/.dotfiles/approval-queue/` left, `approval-queue design` on a committed fixture brief from the new install starts a server whose `/proc/<pid>/cmdline` names the build under `~/Projects/approval-queue`, and the item appears in Design & PR Approvals. The pass then withdraws the item.
4. `~/.claude/workflows/docs-page-chain.js` exists and its `realpath` is under `~/Projects/drafter`, and `git -C ~/.dotfiles status --porcelain` is empty after the drafter install.
5. `gh repo view` fails for each deleted repo, no retired directory remains under `~/Projects` on either machine, and a Cloudflare API query for each `cloudflare` row in `retire-manifest.tsv` resolves none of them. The check fails on a manifest with no `cloudflare` rows, since the `pings` and `cairn-scratch-b` Workers are deployed today.
6. No ROADMAP.md remains in a repo whose ROADMAP this pass retires, and each repo's GitHub description matches the text Geoff confirmed.
