# Repo organization design

## Brief

Approving this design starts a pass that gives every initiative a written record in a new initiatives repo, moves past work to the repo where it belongs, and deletes eleven repos you no longer use.

Work that spans repos has no home today, so its specs and plans pile up in `workstation`. Neither you, a session on either machine, nor a future collaborator can look up where new work belongs. The approval queue's project grouping and the shared standards effort both build on these records, so this pass comes first.

### What changes

- A public `glw907/initiatives` repo holds one record per initiative, with its goals, non-goals, repos, and status.
- Every session prints the initiatives its repo serves when it starts.
- ROADMAP.md retires in every repo, and each of its entries becomes a record, a backlog item, or nothing, by your call.
- Cross-repo specs and plans move to their initiative, and another repo's single-repo docs move into that repo.
- The drafter pieces in `workstation` move to `drafter`, and the approval queue moves to a repo of its own, both with their history.
- The pass deletes eleven repos and archives `aksailingclub-legacy`.

### If you approve

1. The session writes the pass plan, and you review it before the pass starts.
2. The pass builds the initiatives repo, the records, and the tooling, and opens a PR in each repo it touches.
3. You make the ROADMAP calls in one triage item per repo.
4. Before the pass removes anything, you confirm one dry-run item that lists every deletion, archive, teardown, and GitHub description.
5. You run `gh auth refresh -s delete_repo` once when the pass reaches the deletions.

### Decide: estimate ceiling

The design estimate is 840 path minutes. A plan or a run that goes past a ceiling you set comes back to you with the reason before it continues.

Source: `pass-core`, "Plan"

- Allow up to twice the estimate, 1,680 minutes (recommended)
- Allow up to one and a half times the estimate, 1,260 minutes

### Worth knowing

The pass deletes the three repos that exist only on pavilion (`healthy-diet`, `pings`, and `personal-styles`) without a backup copy, as you ruled on 2026-10-14. Once you confirm the dry run, nothing can bring them back.

### The rulings behind this design

You made every call in this design in chat on 2026-10-14. Initiatives are the unit of grouping, recorded in a central repo in the shape of a Kubernetes enhancement proposal (KEP). Cross-repo specs and plans live with their initiative, and past work migrates. Shared standards is a separate initiative that comes next. ROADMAP.md retires everywhere. Drafter and the approval queue move out of `workstation`, and `workstation` otherwise stays as it is. The pass deletes the local-only repos outright.

## Scope

This pass builds the initiative records and the tooling that keeps them in use. It migrates past docs, moves two bodies of code out of `workstation`, and retires unused repos. Each repo's `BACKLOG.md` and `STATUS.md` stay as they are. The backlog holds single pieces of work, and STATUS holds a repo's current state.

The pass leaves the following work to later initiatives:

- The approval queue's grouping by initiative and its new sidebar, which follow this pass with prototypes.
- Shared standards, a Claude Code plugin marketplace that carries the skills, registers, and agents an outside developer would need. Until it lands, the `cairn-docs-drafter` agent and the `approval-brief.md` register stay in `workstation`.
- Any move of code beyond the drafter and approval-queue moves.

The pass is class `runner`, because it edits skills, settings, scripts, and tests. It carries the `live-account` flag because it deletes GitHub repos and can tear down Cloudflare resources.

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

An initiative's `initiative.yaml` holds only the fields that tools read. A record's status is one of `proposed`, `active`, `paused`, `done`, or `withdrawn`.

```yaml
id: drafter
title: Drafter
status: active
owner: glw907
created: 2026-10-12
repos: [drafter, workstation]
```

The record's `README.md` takes the KEP sections a small team needs: Summary, Motivation, Goals, Non-goals, Where the work lives, and Records. "Where the work lives" gives one line per repo saying what that repo carries, and "Records" links the initiative's specs, plans, and PRs. A status change adds a dated line to the README, so the history stays with the record. The non-goals carry the most weight, because they're what settles whether a piece of work belongs to the initiative.

The top-level README states the placement rule as the following steps:

1. Work belongs to an initiative when it serves one of the initiative's goals and no non-goal excludes it.
2. When no record fits, the work is ordinary work for that repo's backlog or the start of a new initiative, which gets a `proposed` record.
3. A fix with no larger purpose needs no initiative.

The same README also notes that `~/Projects/workstation` is a symlink to `~/.dotfiles`, so both names refer to the same repo. A script generates the README's index table from the YAML files, and `scripts/check` fails when the two disagree.

`REGISTER.md` records Geoff's ruling of 2026-10-14 that the repo's prose follows the cairn developer-docs brief in `cairn-cms/docs/internal/docs-register.md`, on the Google developer documentation style guide. Until now the brief has governed only cairn's surfaces, and the file records that extension with its provenance, as the voice system requires of any overlay.

The pass writes these records first:

| Record | Status | Repos |
|---|---|---|
| `repo-organization` (this effort) | `active` | `initiatives`, every repo it touches |
| `drafter` | `active` | `drafter`, `workstation` |
| `approval-queue` | `active` | `approval-queue`, `workstation` |
| `cairn-docs-standard` | `active` | `cairn-cms`, `workstation`, the sites |
| `monthly-model-review` | `active` | `workstation` |
| `personal-design-system` | `proposed` | `907-life`, `cairn-themes`, `approval-queue`, Google Docs |
| `shared-standards` | `proposed` | a new marketplace repo, `workstation` |

The ROADMAP triage adds further records. The personal design system's record links Survey in `cairn-themes`, the 907-life theme, the approval queue, and Docs letterhead as the pieces it would unify. It also records that the deleted `personal-styles` repo defined a collection shape (a style sheet, a decision log, and benchmark renders) worth reusing.

## Rules and tooling

The pass gives each rule a home where it runs, so that sessions find the records and keep them current.

ROADMAP.md retires in every repo. The repos hold about 80 entries, 22 of them in `workstation`. The session drafts a disposition for each entry, which is to become a record, to move to the repo's `BACKLOG.md`, or to be dropped. Geoff makes the calls in one approval-queue triage item per repo, and the pass applies them and deletes each ROADMAP.md.

The SessionStart hook, which already prints `## Host`, also prints the `active` and `proposed` initiatives whose `repos` include the session's repo, each with its summary line. No CLAUDE.md lists initiatives by name, which keeps a hand-kept list from drifting. The global CLAUDE.md gains a short "Initiatives" section that names the repo and the placement rule.

Three skills change:

- `log-project` creates and updates records in the initiatives repo. `log-issue` doesn't change.
- `pass-core`'s design step names the initiative or says none applies. A session writes a cross-repo spec or plan in `initiatives/<id>/`, and the plan header carries an `Initiative: <id>` line.
- `dotfiles-pass` and the other adapters point at the new location for cross-repo docs.

`bluefin/bootstrap.sh` clones the initiatives repo, and `check-drift` warns when the clone is missing or behind its remote. The one machine-local memory about an initiative, `batched-docs-tool-initiative.md`, folds into the drafter record, and the pass then deletes it.

## Migration of past work

`workstation`'s `docs/superpowers/` holds 173 entries: 25 specs, 60 plans, and 88 research files and folders. About 41 distinct paths in other repos point into it. Each entry goes where the new rule would have put it:

- Cross-repo work, such as drafter's specs and the docs standard's infrastructure plan, moves to `initiatives/<id>/`.
- Another repo's single-repo work moves into that repo's `docs/superpowers/`. The dubplate Go rewrite, the uploader, the music VPS, and the poplar adapter are the known cases.
- Work that concerns only `workstation`, such as the pass process, the infrastructure sweeps, and the Thunderbird theme, stays.
- The pings plans leave the tree with the pings repo and remain in `workstation`'s history.

A script classifies every entry and writes `migration-map.tsv`, which lists the old path, the new path, and the initiative for each entry. The script flags an entry the rule can't place, and Geoff makes that call. The pass commits the map so the move stays auditable.

Docs move by copy and delete. Each destination repo receives its files in one commit whose body names the source `workstation` commit, and `workstation` then deletes them while its history keeps the originals. The pass doesn't graft docs history across repos with `git filter-repo`, since the source commit is one `git show` away.

A rewrite script applies the map across every repo, `~/.claude`, and the auto-memory files. A new reference checker scans the same places for `docs/superpowers/` paths and fails on a path that doesn't resolve. It runs once before the migration to record the references already broken, and once after, when it must find nothing new. The pass regenerates the test goldens in `workstation` that embed these paths, and the gate must pass after it does. The rewrite reaches `docs/HISTORY.md` despite its freeze under ruling 8, since a path fix leaves its content unchanged (Geoff, 2026-10-14). The rewrite skips stale worktrees, which the pass removes instead.

The PRs merge in an order that leaves no file without a home:

1. The initiatives repo merges, then `dubplate`, then `poplar`, so every destination holds its files.
2. The reference fixes merge in `cairn-cms` and the other repos.
3. `workstation`'s deletions merge last.

Before it moves any plan, the pass runs the one-executor-per-worktree checks. A plan with an open pass stays where it is until that pass closes, and a short follow-up then moves it.

## Code leaving workstation

Code moves with its history, unlike docs. For each move, `git filter-repo --path` extracts the history on a throwaway clone of `workstation`, so the real repo's history stays as it was.

The drafter pieces move to `drafter`: the docs page chain workflow (`claude/.claude/workflows/docs-page-chain.js`), `scripts/drafter-gate.sh`, five tests, and their fixtures under `tests/fixtures/docs-page-chain/` and `tests/fixtures/drafter/`. The extract merges into `drafter` as unrelated history, so `git log` on a moved file still reaches its first commit. The four gate legs leave `workstation`'s `scripts/check.sh` and join `drafter`'s CI. The workflow reaches `~/.claude/workflows/` through a stow symlink today. After the move, an install target in `drafter` links it, and the `claude-tooling` manifest records the new source, so `claude-tooling-sync verify` still tracks it.

The approval queue moves to a new `glw907/approval-queue` repo built from its extract. The move carries the app's 60 tracked files, the `approval-queue` command, the `claude-approval-queue-reminder` hook script, and the tests for both. The repo's install step links the two commands into `~/.local/bin` on both machines. The hook's entry in `settings.json` stays in `workstation` and calls the command by name. The app's gate leg moves to the new repo's CI.

`workstation` otherwise stays as it is, and the `~/Projects/workstation` symlink stays with it.

## Repo retirement

The pass retires the following repos:

- Delete: `cairn-scratch-b`, `displaywidth`, `kit`, `jrnl-md`, `hugo-blog-template`, `personal-styles`, `aksailingclub-sveltekit`, `cairn-scratch`, `healthy-diet`, and `pings`.
- Fold, then delete: `ecxc-ski-agent-memory`, whose facts that still hold move into `ecxc-ski`.
- Archive: `aksailingclub-legacy`, on GitHub, with its local clone removed.

Every retirement follows the same steps:

1. An inventory script lists each repo's ties: unpushed branches and stashes, open PRs and issues, references from other repos and `~/.claude`, and Cloudflare Workers, D1, KV, R2, DNS records, and age-registry secrets bound to it. It also lists manifest entries such as Brewfile lines and anything `check-drift` tracks. The pass moves or tears down each tie before its repo goes, so no deployed resource outlives its source.
2. One approval-queue item shows the dry run: every repo with its action, every resource to tear down, every manifest line to remove, and the GitHub descriptions from the next section.
3. After Geoff confirms, the pass deletes and archives through `gh` and removes the local directories. A short script performs the same local cleanup on the thinkpad, which may hold clones of its own.

## Worktrees and descriptions

The pass lists every worktree in every repo with its branch, whether that branch is merged, and whether it has uncommitted changes. It removes merged, clean worktrees, such as `p5-scratch` and `drafter-pipeline` under `cairn-cms/.claude/worktrees/` if they pass. Any other worktree goes in the dry-run item for Geoff's call.

`cairn-cms`, `poplar`, `907-life`, `cairn-pub`, and `phonebook` have no GitHub description, and `workstation`'s still describes an Ubuntu setup. The pass drafts a one-line description for each, and for the new `approval-queue` repo, in this repo's register. The descriptions ride in the dry-run item and are set after Geoff confirms it.

## End-to-end check

On the thinkpad, after it pulls every repo and runs the install steps, the pass runs the following checks in order:

1. The reference checker reports no broken path that the pre-migration run didn't already record.
2. A session opened in `drafter` prints the drafter record at startup.
3. `approval-queue design` from the new repo's install opens an item in Design & PR Approvals.
4. `claude-tooling-sync verify` passes with the docs page chain installed from `drafter`.
