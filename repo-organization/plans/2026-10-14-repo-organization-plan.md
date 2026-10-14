# Repo organization pass plan

Initiative: repo-organization
Design: `~/Projects/initiatives/repo-organization/specs/2026-10-14-repo-organization-design.md` (commit `750ad14`, approved by Geoff 2026-10-14)
Fold record: `~/Projects/initiatives/repo-organization/research/2026-10-14-repo-organization-fold.md` (the mechanisms each task uses, probed, with sources)
Class: `auth-data` by the dotfiles path map, for task W8 only (`secrets/**`, `scripts/secrets/**`, `bash/.bashrc`); every other task is `runner` or `ordinary` as stated, matching the design's `runner`. Flag: `live-account`.
Adapters: `pass-core`; `dotfiles-pass` (workstation); `cairn-pass` (cairn-cms); `site-pass` (907-life, aksailingclub-org, cairn-pub, ecxc-ski, xcathletes-org). The initiatives, drafter, approval-queue, dubplate, poplar, cairn-themes, and phonebook repos have no adapter; their gate, path class, and close steps are stated here, with `pass-core`'s `runner` definition as the path map.
Engine consultation: no engine asks. Facts consulted: none, since no task touches a cairn engine surface.
Design estimate: 840 path minutes. Standing approval (Geoff, 2026-10-14): a plan or a run up to 1,680 path minutes proceeds without stopping.
Plan path minutes: 875. Task sum: 2,460.

## Outcome

The design's six end-to-end checks pass on the thinkpad, and pavilion passes the same checks first. Concretely, the pass delivers the following:

- `glw907/initiatives` is public, with eight records and a CI-checked index.
- Every session prints its repo's initiatives.
- ROADMAP.md is gone from ten repos, each entry handled by Geoff's call.
- Past docs live where the placement rule puts them.
- Drafter's pieces live in `drafter`, and the queue lives in `glw907/approval-queue`, both with history.
- Eleven repos and folders are retired, and only sole-owner Cloudflare resources are torn down.

## How the work splits

A worktree-isolated session's guard refuses any git command aimed outside its own worktree, and it refuses writes by path outside it (drafter passes 3 to 5; drafter#11 and #30 record the clock file refused). So each executor below works one repo from a worktree of that repo, and every step that needs git across repos or writes machine state belongs to an unisolated session: the conductor on pavilion, or the thinkpad session.

| Session | Launched from | Repo it commits to | Tasks |
|---|---|---|---|
| `conductor-initiatives` (Opus, medium) | `~/Projects/initiatives` | none (merges and pulls only) | C0 to C8 |
| `initiatives-repo-organization` | `~/Projects/initiatives` | `glw907/initiatives` (PR 1) | I1 to I9 |
| `initiatives-repo-organization-retire` | `~/Projects/initiatives` | `glw907/initiatives` (PR 2) | R1, R2 |
| `workstation-repo-organization` | `~/.dotfiles` | `glw907/workstation` | W2 to W8 |
| `drafter-repo-organization` | `~/Projects/drafter` | `glw907/drafter` | D1 |
| `approval-queue-repo-organization` | `~/Projects/approval-queue` | `glw907/approval-queue` | A1 |
| `<repo>-repo-organization`, one per sweep repo | that repo's main checkout | that repo | S-`<repo>` |
| `initiatives-repo-organization-thinkpad` | `~/Projects/initiatives` on thinkpad-x1, launched by Geoff | `glw907/initiatives` (PR 3) | T1 |

The sweep repos are `dubplate`, `poplar`, `cairn-cms`, `907-life`, `aksailingclub-org`, `cairn-pub`, `cairn-themes`, `ecxc-ski`, `phonebook`, and `xcathletes-org`.

Why the conductor is `conductor-initiatives`. The conductor runs from `~/Projects/initiatives` and launches each executor with `(cd <checkout> && claude --bg ...)`. There are three reasons:

- The initiatives repo holds this plan, every prompt, the tools, and the research records, and it is the home of the first and last executors.
- It is the cross-repo work's home under the design's own placement rule.
- A name tied to one code repo would collide: `conductor-drafter` is live today, and a later workstation planner that finds a live `conductor-workstation` hands it an unrelated pass.

Why the conductor runs the machine steps. The conductor is the only unisolated session on pavilion, it already merges, pulls, and runs install steps (the drafter conductor's precedent), and it receives Geoff's dry-run approval from the queue directly. Each machine step runs a tool an executor wrote and tested, so the conductor writes no feature code.

Model and effort: executors `sonnet` at `medium`, pair subagents the same with `description` `<session> task <id>`. The conductor runs at `claude-opus-5-5` `medium`.

## Shared interfaces

- **Scope list**: `repo-organization/scope.tsv` in initiatives, with columns `repo`, `role`, and `path`. `role` is `edit` (the pass may rewrite it), `read` (it is read for ties and sharing, never edited: `aksailingclub-legacy`), or `retire` (one row per retirement target). Every repo-wide step reads this list and never globs `~/Projects`, including the reference tool, the inventory, the worktree listing, the thinkpad script, the post-checks, and "pulls every repo". No committed file names a repo outside the list.
- **Pass state directory**: `~/.local/state/repo-organization/` on each machine, written by the conductor (or the thinkpad session) and read by executors. It holds `items.tsv` (queue title, then item id), `inventory-local.json`, `worktrees.tsv`, `refs-baseline-<host>.tsv`, and `extracts/<name>/` with a `verify.txt` beside each extract.
- **Geoff's decisions**: the app writes them to `~/.local/state/approval-queue/items/<id>/decision.json`. An executor that applies a decision reads that file, with the id taken from `items.tsv`, and never takes a decision from a session's message.
- **ROADMAP triage files**: `repo-organization/research/roadmap-triage/<repo>.json`, in the queue's triage shape. The queue accepts only `now`, `defer`, and `drop`, so the lede states the mapping: `now` becomes an initiative record, `defer` moves to the repo's `BACKLOG.md`, and `drop` drops the entry. Each `action` starts with the entry's number (`#7 ...`), so a decision row maps back to one entry.
- **Migration map**: `repo-organization/research/migration-map.tsv`, with columns `source_repo`, `old_path`, `new_repo`, `new_path`, `initiative`, and `state`. Its header line records the pinned `workstation` commit (the start commit). `state` is a new path, or one of `stays`, `leaves-with-pings`, `deferred:<pass>`, `flagged`, `collision-identical`, or `collision-differs`. Moved code paths get rows too.
- **Pass 5 check (G-p5)**: `gh pr list -R glw907/drafter --head worktree-p5-pipeline --state merged --json number` and `gh pr list -R glw907/cairn-cms --head drafter-pipeline --state merged --json number` each return one PR, and `claude agents --json` lists no row whose `name` starts with `drafter-` or equals `conductor-drafter`. No task that moves drafter docs or code, or touches `~/Projects/drafter` or the cairn-cms worktrees `drafter-pipeline` and `p5-scratch`, starts before G-p5 passes. Those tasks are D1, C4a, I9's drafter rows, W6's drafter half, W7's drafter rows, and C5's worktree removals there.

## Gates per repo

| Repo | Gate (fast lane) | Full-suite home | Setup |
|---|---|---|---|
| initiatives | `bash scripts/gate.sh` (I1 adds it; light lane; it runs `scripts/check` and every test) | CI on the PR (`.github/workflows/check.yml`), watched with `gh pr checks <n> --watch --fail-fast` in the background | none |
| workstation | `bash scripts/gate.sh` | the same, once on the close head | none |
| drafter | `DRAFTER_DIR="$PWD" bash ~/.dotfiles/scripts/drafter-gate.sh` until D1 moves it, then `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` | that gate on the close head | none |
| approval-queue | `bash scripts/gate.sh` (A1 adds it: the app's `check` and `test`, plus the two moved shell tests) | that gate on the close head | `npm ci --prefix approval-queue` |
| dubplate, poplar | `bash scripts/gate.sh` | local on the close head; poplar's CI also runs on the PR | per their CLAUDE.md |
| cairn-cms | `cairn-pass` fast lane | CI on the draft PR, `ci-green` watch | `cairn-pass` setup |
| sites | `site-pass` table | `site-pass` table | `site-pass` table |
| cairn-themes, phonebook | none exists; the task's own checks are the gate | none | none |

Clock file: each executor writes `pass-task-clock` per `pass-core`. If the guard refuses the write, as on drafter#11 and #30, the session watches the 2x line by hand and says so in the score. A wait on Geoff or on another session removes the clock file first and writes a new `start=` after.

## Tasks

Estimates are minutes of work. A wait on Geoff or on another session is not counted.

### Conductor

**C0. Launch gate and the initiatives remote (20, ordinary, live-account).**

- Outcome: the pass may start.
  - `gh pr view 69 -R glw907/workstation --json state` reads `MERGED`.
  - `~/.dotfiles` has been pulled, and `git -C ~/.dotfiles status --porcelain secrets/` is empty.
  - The one-executor checks pass for `~/Projects/initiatives` and `~/.dotfiles`.
  - `glw907/initiatives` exists, public, from the local `main` (`gh repo create glw907/initiatives --public --source ~/Projects/initiatives --remote origin --push`).
  - `.claude/worktrees/` is excluded in each launch checkout (`pass-core` "Execute").
- Files: none committed.
- Acceptance: `gh repo view glw907/initiatives --json visibility` reads `PUBLIC`, and `git -C ~/Projects/initiatives rev-list --count HEAD..origin/main` prints 0.
- Test: none, since this task runs commands and writes no code.
- Then: launch the initiatives executor and the workstation executor.

**C1. Local legs (20, ordinary).**

- Outcome: once I4, I5, and I6 are pushed, the conductor runs their local legs from the initiatives executor's worktree path against the main checkouts in `scope.tsv`. It runs the reference tool's baseline check, the inventory's `--local` legs, and the worktree listing, and writes the outputs to the state directory.
- Files: state directory only.
- Acceptance: the outputs exist and are non-empty, and the baseline names this host.
- Test: the tools' own tests (I4, I5, I6).

**C2. Items for Geoff and the empty queue repo (20, ordinary, live-account).**

- Outcome: Geoff sees every decision item, and the queue's repo exists before initiatives PR 1 merges.
  - As each triage file lands, it goes to Geoff as `approval-queue triage glw907/<repo> "Retire ROADMAP.md in <repo>" <file>`. The map-calls brief from I3 goes as `approval-queue design initiatives "Migration map calls" <file>`, and the dry-run brief from I8 as `approval-queue design initiatives "Repo retirement dry run" <file>`. Each command runs in the background, and its id goes into `items.tsv`.
  - The conductor creates `glw907/approval-queue` (public, with one README commit so an extract can arrive by PR: `gh repo create glw907/approval-queue --public --add-readme`), clones it to `~/Projects/approval-queue`, and excludes `.claude/worktrees/` there.
- Acceptance: one item per triage file, plus the two design items, sits in `items.tsv`, and `gh repo view glw907/approval-queue` succeeds.
- Test: none.

**C4a and C4b. History extracts (20 each, runner, live-account).**

- Outcome: the conductor runs I6's `extract` tool, on a fresh `git clone --revision=<sha>` of `glw907/workstation` from GitHub, into `extracts/drafter/` (after G-p5) and `extracts/approval-queue/` (after Geoff approves the dry run). The `verify.txt` beside each shows two things: the tip tree equals the source tree at the pinned commit over the extract's paths, and each moved file's first `workstation` commit maps to its first extract commit through `.git/filter-repo/commit-map`.
- Acceptance: `verify.txt` ends `verified`, and the pinned commit is recorded in the map header's extract row.
- Test: I6's extract tests.

**C5. Local retirement stage (35, ordinary, live-account).**

- Outcome: after R2's GitHub stage is logged, the conductor works through the local stage.
  - It writes the one tar archive of `cairn-scratch`, `ecxc-ski-agent-memory`, and `aksailingclub-sveltekit` to the path the approved dry run names, outside `~/Projects`, and lists it with `tar -tf`.
  - It removes each retired local directory in the approved list.
  - It removes each worktree the approved list marks removable, once the worktree tool rechecks the rules at removal time.
  - It stops the 7907 server only at C6, not here.
- Acceptance: `tar -tf` lists all three directories. No approved retired directory remains, and the tool's removable check passes on every worktree it removes.
- Test: I6's worktree-rule tests.

**C6. Merges, pulls, and installs (45, runner).**

- Outcome: the conductor merges every PR in "Merge order" on Geoff's approve, then follows step 5 of that order on pavilion. After the workstation merge it pulls, runs `stow -R bin claude`, then `make -C ~/Projects/drafter install` and the approval-queue install step. It then stops the old 7907 server and removes the untracked `node_modules/` and `build/` under `~/.dotfiles/approval-queue/`. It runs the reference tool's apply mode over pavilion's memory files (the tool tars them first) and removes the `batched-docs-tool-initiative.md` index line from `MEMORY.md` on pavilion.
- Acceptance: `git -C ~/.dotfiles status --porcelain` is empty, and `realpath ~/.claude/workflows/docs-page-chain.js` lies under `~/Projects/drafter`. `realpath ~/.local/bin/approval-queue` lies under `~/Projects/approval-queue`, and no process listens on 7907 before the C7 check starts one.
- Test: D1's and A1's install tests.

**C7. Pavilion end checks and the thinkpad hand-off (30, ordinary).**

- Outcome: the conductor runs the design's checks 1 to 6 on pavilion, with check 1 against pavilion's baseline, before Geoff touches the thinkpad. It then sends Geoff, with `notify-send -u normal`, the two thinkpad commands from "Geoff's touchpoints".
- Acceptance: every check passes on pavilion, and the results go into STATUS's hand-over.
- Test: the checks themselves.

**C8. Close (25).**

- Outcome: PR 3 from the thinkpad is read and merged. The `repo-organization` record's README gets a dated status line, and the STATUS hand-over lands in `workstation` and initiatives per `pass-core` "Ledgers". Then the conductor stops itself.

### initiatives-repo-organization (PR 1)

**I1. Repo scaffold and record check (75, runner).**

- Outcome: the repo matches the design's layout.
  - `README.md` explains what an initiative is, with the three-step placement rule, the symlink note, and a generated index table.
  - `REGISTER.md` records Geoff's 2026-10-14 voice ruling with its provenance.
  - `scripts/check` fails, naming the file, on each of the nine states the design lists. `scripts/check --repos` checks `repos` against `gh repo list glw907`.
  - `scripts/index` writes the README's index from the YAML.
  - `scripts/test.sh` and `scripts/gate.sh` run the gate, and `.github/workflows/check.yml` runs every state but `repos`, plus the tests.
- Files: `README.md`, `REGISTER.md`, `scripts/{check,index,test.sh,gate.sh}`, `tests/check/` with fixtures `tests/fixtures/check/<state>/`, `.github/workflows/check.yml`.
- Acceptance: each of the nine bad fixtures fails with its file named, and the good fixture passes. A run in CI mode skips `repos`, and `--repos` fails on a fixture naming `glw907/no-such-repo`.
- Test: one bad fixture per state, plus an empty tree, plus a good tree.

**Pair A, run after I1.**

**I3. Scope list, classifier, and migration map (100, ordinary).**

- Outcome: `scope.tsv` lists every repo in the pass's scope with its role.
  - `repo-organization/tools/classify-docs` reads a scratch clone of `glw907/workstation` at the pinned commit. The pinned commit is `origin/main` at task start, taken with `gh api`.
  - The tool also reads scratch clones of the destination repos, and writes `migration-map.tsv` with one row per `docs/superpowers/` entry and per moved code path.
  - It runs the one-executor checks (`claude agents --json` and each repo's STATUS, read by path) and marks a plan with an open pass `deferred:<pass>`.
  - It writes `repo-organization/research/migration-calls.md`, an approval-brief design doc with one `### Decide:` block per `flagged` row and per `collision-differs` row. For a collision, "Keep the destination" is recommended.
- Files: `repo-organization/scope.tsv`, `repo-organization/tools/classify-docs`, `repo-organization/tools/tests/classify/`, `repo-organization/research/migration-map.tsv`, `repo-organization/research/migration-calls.md`.
- Acceptance: the map's rows equal the entry count at the pinned commit (173 expected, plus code rows), and every row holds a placed state. A fixture entry the rule can't place comes out `flagged`. An identical file of the same name in `archive/` comes out `collision-identical`, and a differing one comes out `collision-differs`. `migration-calls.md` passes `approval-queue`'s brief check.
- Test:
  - Fixture trees for each state, including the unplaceable entry and both `archive/` collisions.
  - A scope test: a fixture repo outside the scope list, with its directory set to mode `000`, sits beside the in-scope fixtures, and the tool must run clean without reading it. Any read of that directory errors.

**I7. ROADMAP triage drafts (75, ordinary).**

- Outcome: there is one triage file for each `edit`-role repo with a ROADMAP.md, except `cairn-cms`. The ten are 907-life, aksailingclub-org, cairn-pub, cairn-themes, dubplate, ecxc-ski, phonebook, poplar, workstation, and xcathletes-org.
  - Each file drafts a disposition and a one-line reason per entry.
  - Its lede states the repo's entry count and the disposition mapping.
  - Each "become a record" row's `detail` names the proposed record id and repos.
  - Entries are counted by the design's rule: top-level bullets, or `###` headings in a repo that uses headings.
- Files: `repo-organization/research/roadmap-triage/<repo>.json`, `repo-organization/tools/roadmap-count`, and its test.
- Acceptance: each file passes the queue's brief check, and its row count equals `roadmap-count`'s count for that repo.
- Test: `roadmap-count` fixtures for a bullets-only file, a headings file, and a mixed file, the way aksailingclub-org (19 headings and 2 bullets) and poplar mix them. The expected count is fixed per fixture.

**Pair B, run after Pair A.**

**I4. Reference tool (130, ordinary).**

- Outcome: `repo-organization/tools/refs`, with `check` and `apply` modes, reads the map and `scope.tsv`.
  - It resolves bare `docs/superpowers/` paths against the containing repo, and `~/`, `/var/home/`, and `~/Projects/<repo>/` paths literally.
  - It classes each hit as `rewrite`, `retired-target` (from history files, never a failure), `live-tie`, or `broken`.
  - Its scope is git-tracked text files, minus `.claude/worktrees/`, lockfiles, `_salvage/`, and the named fixture list.
  - Memory files are `~/.claude/projects/*/memory/*.md`. Apply mode tars them first, writes through a temp file and a rename, and deduplicates by `realpath`.
  - Apply mode takes one root and edits only files whose `realpath` lies under it. Check mode records a baseline keyed by machine, file, and path, and diffs against it.
- Files: `repo-organization/tools/refs`, `repo-organization/tools/tests/refs/`.
- Acceptance:
  - A planted reference to a missing `initiatives/<id>/` path is reported `broken`.
  - A retired-target reference in a history file is listed and exits 0.
  - A second apply run changes nothing.
  - A bare path resolves against its own repo when two fixture repos carry the same relative path.
- Test: those four cases, the outside-scope fixture at mode `000` (as in I3), and Review Focus 3.

**I5. Inventory (130, ordinary, live-account).**

- Outcome: `repo-organization/tools/inventory` takes `--network` and `--local` legs over the `retire` rows of `scope.tsv`. The `--local` legs run git in the targets, so only the conductor runs them.
  - It reports each target's kind and ties as the design's step 1 lists them.
  - It derives Cloudflare ties from each target's own files and resolves each by id against every `edit` or `read` repo's wrangler configs.
  - It marks a resource `sole-owner` only when no in-scope config names it and no deployed Worker outside the targets binds it, read from the account's Worker settings through the API. Sharing is resolved only across the scope list, so the account read covers resources a repo outside the list may use.
  - It sources `~/.local/secrets` itself and exits nonzero on any API or auth error.
- Files: `repo-organization/tools/inventory`, `repo-organization/tools/tests/inventory/` with a known-ties fixture.
- Acceptance: on the fixture it reports the `pings` Worker and `PINGS_ADMIN_TOKEN` ties, and the `asc-handbook`, `asc-uptime`, and `asc-event-images` resources come out `shared-with aksailingclub-legacy`. A stubbed API error exits nonzero. It never reads the outside-scope fixture.
- Test: those cases and Review Focus 4.

**Pair C, run after Pair B.**

**I2. Initial records (70, ordinary).**

- Outcome: there are eight records with `initiative.yaml` and a KEP README (Summary, Motivation, Goals, Non-goals, Where the work lives, and Records). They are the seven the design lists, plus `workstation-secrets`.
  - `workstation-secrets` is `proposed`, with repos `[workstation]`. Its README states Geoff's 2026-10-14 goal, "a better way of tracking the age secrets across workstations", and names the evidence. `DRAFTER_API_KEY` was stored on pavilion through `secret-receive` on 2026-10-13, and it sat uncommitted with no registry entry until workstation#69. Nothing told the thinkpad.
  - `personal-design-system` carries the design's notes on its pieces and on the `personal-styles` collection shape.
  - `repo-organization` links the spec, the fold record, and this plan. The index is regenerated.
- Files: `<id>/initiative.yaml` and `<id>/README.md` for each record, plus `README.md` (index).
- Acceptance: `scripts/check` passes, and `scripts/check --repos` passes once C2 has created `glw907/approval-queue`.
- Test: the I1 check.

**I6. Worktree, thinkpad, and extract tools (70, ordinary, live-account).**

- Outcome: three tools, each over `scope.tsv`.
  - `repo-organization/tools/worktrees` lists every worktree in scope with its branch, merged state, lock, dirty and ignored files, process, and mtime. It marks a worktree removable only under the design's five rules.
  - `repo-organization/tools/thinkpad-cleanup` runs the inventory's local legs, prints its dry run with the remote-less directories it finds, and refuses a target with unpushed or uncommitted work.
  - `repo-organization/tools/extract` runs `git filter-repo --path ...` without `--force` on a fresh clone that never moves HEAD, listing every historical path (including `review-desk` for the queue). It then writes `verify.txt`.
- Files: those three tools and their tests under `repo-organization/tools/tests/`.
- Acceptance:
  - A worktree whose branch equals its base is not removable, and a locked or dirty one is not.
  - The thinkpad script refuses a fixture with an unpushed branch.
  - An extract of a fixture repo with a rename verifies when both names are listed.
- Test: those cases, the outside-scope fixture, and Review Focus 5.

**I8. Dry-run brief and teardown list (60, ordinary).**

- Outcome: once C1's outputs exist, the session writes `repo-organization/research/2026-10-14-retirement-dry-run.md`, an approval-brief design doc. It lists every target and its action, every resource to tear down, every shared resource left in place, every manifest line to remove, the worktree calls, the tar path, and the GitHub descriptions in this repo's register. The descriptions cover cairn-cms, poplar, 907-life, cairn-pub, phonebook, workstation, and approval-queue.
  - Its "Geoff does by hand" list starts with revoking `CAIRN_SCRATCH_CF_TOKEN`, then `gh auth refresh -s delete_repo`. It also asks Geoff to confirm on the thinkpad that `git -C ~/.dotfiles status --porcelain secrets/values.age` prints nothing after a pull. No session runs on the thinkpad at this point, and the design's step 4 needs that machine's store clean.
  - Its Worth knowing states that sharing was resolved across the scope list and the account's Worker bindings.
  - `teardown.tsv` lists the kind and id of each sole-owner resource.
  - Before the brief goes out, the session checks two facts: workstation#69 has merged, and `values.age` is clean and at `origin/main` on pavilion.
- Files: the dry-run doc, `repo-organization/research/teardown.tsv`.
- Acceptance: the brief passes the queue's brief check. `teardown.tsv` is non-empty and holds the `pings` and `cairn-scratch-b` Workers, and every id in it is `sole-owner` in the inventory output.
- Test: the check above. A test that fails on an empty `teardown.tsv` goes into the R1 post-query.

**I9. Docs into initiatives, triage records, and PR 1 (60, ordinary).**

- Outcome: this task waits on the map-calls decision and on all ten triage decisions, and its drafter rows wait on G-p5.
  - The session applies Geoff's calls to the map, which leaves no `flagged` row.
  - It copies every row whose `new_repo` is initiatives from the scratch clone at the pinned commit, in one commit whose body names that commit.
  - It writes a `proposed` or `active` record for each `now` row in the ten decisions.
  - It runs `refs apply` over its own worktree and regenerates the index.
- Files: `<id>/{specs,plans,research}/...` per the map, new record directories, `README.md`.
- Acceptance: every initiatives row's `new_path` exists in the worktree. `scripts/check` passes, and the count of new records equals the count of `now` rows in the decisions. `refs check` over the worktree finds nothing `broken` beyond the baseline.
- Test: the I1 check and the I4 tool.

Close for I (40): the gate, the whole-branch review (with `python-conventions` or `ts-conventions` by the tools' language), and PR 1 at PR-ready.

### initiatives-repo-organization-retire (PR 2)

This session launches after Geoff approves the dry run. It acts only on the approved doc and the decision, both read from the queue's item directory.

**R1. Cloudflare teardown (45, ordinary, live-account).**

- Outcome: every resource in the approved list is torn down through the API, with each stage row appended to `repo-organization/research/2026-10-14-retirement-log.tsv` (stage, item, result, time) and pushed after the stage. A rerun skips a row already logged `done`.
- Acceptance: a Cloudflare API query for each id in the approved list resolves none of them. The post-query fails on an empty list, and the log's `cloudflare` stage reads `done`.
- Test: the post-query is the test, together with its empty-list failure.

**R2. GitHub deletions and descriptions (30, ordinary, live-account).**

- Outcome: this task waits on two things: W8's store commit pushed on the workstation branch (seen through `gh api`), and the `delete_repo` scope (`gh auth status`). It notifies Geoff once if the scope is missing. Then it runs each approved `gh repo delete`, sets each approved description with `gh repo edit`, and logs the `github` stage.
- Acceptance: `gh repo view` fails for each deleted repo, and each description reads as approved.
- Close: PR 2 holds the log. Its body lists the hand-done items and whether each is still owed.

### workstation-repo-organization

**W4. filter-repo, bootstrap, and check-drift (60, runner).** This is the first task, because C4a needs `git-filter-repo`.

- Outcome:
  - `brew install git-filter-repo` runs, with its line in `bluefin/Brewfile`.
  - `bluefin/bootstrap.sh` clones initiatives and runs the drafter and approval-queue install steps.
  - `check-drift` warns when the clone is missing, checks behind-ness with `git ls-remote` under a short timeout, and reports an unreachable remote as its own non-failing line.
- Files: `bluefin/Brewfile`, `bluefin/bootstrap.sh`, `bin/.local/bin/check-drift`, a new `tests/check-drift-initiatives.test.sh`, `scripts/check.sh` (one leg).
- Acceptance: `git filter-repo --version` prints 2.47 or later.
- Test: fixtures for a missing clone, a behind clone, and an unreachable remote (a `file://` path that doesn't exist), each with its expected line and exit 0.

**Pair, run after W4.**

**W2. SessionStart initiatives lines (60, runner).**

- Outcome: `claude/.claude/gather-dotfiles.sh` prints the `active` and `proposed` records whose `repos` include the session's repo, as the design specifies. The repo name comes from the `origin` basename through `--git-common-dir`. The script reads YAML with `yq`, prints the two failure lines, prints nothing on no match, and always exits 0. `INITIATIVES_DIR` overrides `~/Projects/initiatives` for tests.
- Files: `claude/.claude/gather-dotfiles.sh`, `tests/gather-dotfiles-initiatives.test.sh`, `tests/fixtures/initiatives/`, `scripts/check.sh` (one leg).
- Acceptance: each state prints its expected text, and a worktree of a fixture repo prints its parent's records.
- Test: one case per state: match, no clone, unreadable record, no match, worktree, and a checkout named `.dotfiles` whose origin is `workstation`.

**W3. Skills and rule text (100, runner).**

- Outcome: each changed file gets its own acceptance check.
  - `log-project` writes records in initiatives and never creates a ROADMAP.md.
  - `log-issue` drops `roadmap_path` and moves `#project:<slug>` to `#initiative:<id>`.
  - `pass-core`'s design step names the initiative or says none applies, and it puts cross-repo docs in `initiatives/<id>/` with an `Initiative:` plan-header line.
  - `dotfiles-pass`, `cairn-pass`, and `site-pass` point at the new home for cross-repo docs.
  - `cairn-release`, `dependency-upgrade`, `claude-infra`, and `cairn-figure` lose their non-cairn-cms ROADMAP references. References to cairn-cms's ROADMAP stay.
  - `claude-memory-write-check` drops its ROADMAP references.
  - `claude/.claude/CLAUDE.md` gains one placement line that points at the initiatives README, and lines move to `claude-md-archive.md` if the cap needs it.
  - `.claude/project-tracking.json` moves off ROADMAP, if the file exists in workstation.
- Files: those skill files under `claude/.claude/skills/` and `.claude/skills/dotfiles-pass/`, `bin/.local/bin/claude-memory-write-check`, `claude/.claude/CLAUDE.md`, `claude/.claude/docs/claude-md-archive.md`.
- Acceptance: a grep over the changed files finds no `ROADMAP` outside cairn-cms references, and finds `initiatives` in each. `CLAUDE.md` is at or under 200 lines. `log-project` names `initiative.yaml`, and `pass-core` names `Initiative:`.
- Test: `scripts/check-claude-refs.py` passes, and the existing `claude-memory-write-check` test gains a case for a memory write naming ROADMAP.

**W5. Workstation ROADMAP (30, ordinary).**

- Outcome: the session applies Geoff's workstation decision. `defer` rows go to `BACKLOG.md` with `#initiative:<id>` tags, and `ROADMAP.md` is deleted. The applied count equals the triage file's count.
- Files: `BACKLOG.md`, `ROADMAP.md` (deleted).
- Acceptance: the decision's row count equals the count of `now` rows plus `defer` rows applied plus `drop` rows, and `test ! -e ROADMAP.md`.
- Test: `roadmap-count` from I7 against the deleted file's last committed version.

**W6. Code leaves workstation (50, runner).**

- Outcome: the drafter half waits on G-p5 and C4a. It removes `docs-page-chain.js`, `cairn-docs-outline`, `scripts/drafter-gate.sh`, the five tests, and their fixtures, along with the four `check.sh` legs. The `cairn-run-gate` test drops its moved path. `claude-tooling.md` records the workflow's new source repo.
- The approval-queue half waits on the dry-run approval and C4b. It removes `approval-queue/`, the command, the reminder script, their tests, and their legs. The hook's `settings.json` entry stays.
- Files: those paths, `scripts/check.sh`, `tests/cairn-run-gate.test.sh`, `claude/.claude/docs/claude-tooling.md`.
- Acceptance: the gate passes with no leg naming a removed path, and `git ls-files` lists none of the removed paths.
- Test: the gate.

**W8. Retired secrets and live ties (60, auth-data, test-first).**

- Outcome: this task waits on the dry-run approval and on R1's `cloudflare` stage.
  - `scripts/secrets/secret-set.sh` gains a store-path override (an environment variable defaulting to today's `$HOME/.dotfiles/secrets/values.age`), since the script hard-codes the main checkout's path and the design's step 5 commits from the pass worktree. That change is its own commit, with its test first.
  - Then one commit removes each retired secret in the approved list from the worktree's `values.age` (`secret-set.sh NAME --delete` with the override) and from `secrets/registry.md`. It also edits any `bash/.bashrc` line the inventory names.
  - `diff-reviewer` reads each commit at task scope, and `RUN_GATE_IF_BUSY` is never set.
  - If the age key's tmpfs cache is gone and 1Password must unlock, the session notifies Geoff and waits.
- Files: `scripts/secrets/secret-set.sh`, `tests/secret-set-store-path.test.sh`, `secrets/values.age`, `secrets/registry.md`, `bash/.bashrc` if the inventory names it.
- Acceptance: no retired name appears in `registry.md` or in the decrypted store's name list (checked by name only), and every remaining registry row has a store entry. The main checkout's `values.age` is unchanged, and `git -C ~/.dotfiles status --porcelain secrets/` stays empty from the pass worktree's side.
- Test, written first: the override test against a temporary store and recipient, plus Review Focus 2.

**W7. Workstation docs, references, and the draft check (60, runner).**

- Outcome: this task waits on initiatives PR 1's merge and a pull, so the final map and tool are on `main`.
  - It deletes each moved docs entry in the map, and the drafter rows only after G-p5.
  - It runs `refs apply` over the worktree, edits `live-tie` hits by hand, and adds a backlog item per `deferred:<pass>` row.
  - It regenerates only the goldens whose embedded path the map changes.
  - It runs the draft check: every destination path exists on its repo's `origin/main` (seen through `gh api`), and `git diff <pinned commit> origin/main` over every moved path is empty, with any hit re-copied by its destination's session.
- Files: `docs/superpowers/**` deletions, files `refs` rewrites, `BACKLOG.md`.
- Acceptance: the draft check passes, `refs check` finds nothing new against the baseline, and the PR leaves draft only after the check passes.
- Test: the draft check gets a fixture with an edited moved file, which must fail.

Close for W (45): run the gate, `gitleaks git` over the branch history, `claude-tooling-sync verify`, and the whole-branch review with the dotfiles checklist globs. The PR body carries `## Before merge`.

### drafter-repo-organization

**D1. Drafter receives its pieces (100, runner).** This task waits on G-p5 and C4a.

- Outcome: the session fetches `extracts/drafter/` and merges it into the branch as unrelated history.
  - Two tests find the agent files through `WORKSTATION_DIR`, defaulting to `~/Projects/workstation`.
  - The four legs join `make check`.
  - `make install` creates `~/.claude/workflows` as a directory, then links `docs-page-chain.js` and `cairn-docs-outline` with `ln -sfn`.
  - The goldens the map changes are regenerated.
  - The README's install section is updated.
- Files: the extract's paths, `Makefile`, the two tests, `README.md`.
- Acceptance: `git log --follow` on `docs-page-chain.js` reaches its first commit, and `make check` passes with the four legs. An install against a temp `HOME` sets both `realpath`s under the checkout.
- Test: the install test with a temp `HOME`, plus Review Focus 1.

Close for D (30): after initiatives PR 1 merges, run `refs apply` over the worktree, then the gate on the close head and the whole-branch review (`go-conventions` and `ts-conventions` globs).

### approval-queue-repo-organization

**A1. The queue's own repo (75, runner).** This task waits on C4b.

- Outcome: the session merges `extracts/approval-queue/` into the branch as unrelated history, keeping `bin/.local/bin/approval-queue` and `approval-queue/` at the root.
  - The brief-register test reads `REGISTER`, defaulting to `~/.claude/docs/voice/approval-brief.md`.
  - `scripts/gate.sh` runs the app's checks and the two shell tests.
  - The install step links both commands into `~/.local/bin`.
  - A committed fixture brief, `tests/fixtures/e2e-brief.md`, serves end-to-end check 3, and the README covers install and the gate.
- Files: the extract's paths, `scripts/gate.sh`, `scripts/install.sh`, `tests/approval-queue.test.sh`, `tests/fixtures/e2e-brief.md`, `README.md`.
- Acceptance: `git log --follow` on `approval-queue/src/lib/brief.ts` reaches a `review-desk`-era commit, and the gate passes. An install against a temp `HOME` sets both `realpath`s under the checkout.
- Test: the install test, and the existing tests under the new paths.

Close for A (30): `refs apply` after PR 1 merges, the gate, and the review with `ts-conventions`.

### Sweep executors, one per repo (each launched after initiatives PR 1 merges and is pulled)

Each S task applies its repo's triage decision.

- Outcome:
  - `defer` rows go to `BACKLOG.md`, created if absent, with `#initiative:<id>` tags, and `ROADMAP.md` is deleted.
  - `#project:<slug>` tags become `#initiative:<id>` or go, by the entry's disposition.
  - `.claude/project-tracking.json` drops its ROADMAP path.
  - The session runs `refs apply` over its worktree and edits `live-tie` hits by hand.
  - It runs its gate and opens the PR.
- Acceptance: the applied count equals the decision's row count, and `test ! -e ROADMAP.md` (cairn-cms excepted). `refs check` over the worktree finds nothing new against the baseline.
- Test: the gate, plus `roadmap-count` against the deleted file.

Class is `ordinary`, unless a rewrite lands in `.github/workflows/**`, `scripts/**`, or `scripts/checks/**`, which makes the task `runner`.

| Task | Minutes | Repo-specific work |
|---|---|---|
| S-dubplate | 80 | Receives its docs rows from the scratch clone at the pinned commit, in one commit naming it. Destination kept on `collision-differs`, as Geoff ruled in the map calls. 31 `#project:` tags. Heavy gate. |
| S-poplar | 65 | Receives its docs rows (the adapter work), as dubplate does. CI watch. |
| S-cairn-cms | 60 | References only. Its ROADMAP and every reference to it stay. `cairn-pass` fast lane, CI. |
| S-aksailingclub-org | 70 | 21 entries. CI watch. |
| S-ecxc-ski | 55 | Also folds the facts that still hold from `~/Projects/ecxc-ski-agent-memory` (read by path) into ecxc-ski's docs. |
| S-xcathletes-org | 50 | One `#project:` tag. |
| S-907-life | 45 | |
| S-cairn-pub | 40 | |
| S-cairn-themes | 40 | No gate exists. |
| S-phonebook | 35 | No gate exists. |

### initiatives-repo-organization-thinkpad (PR 3)

**T1. The thinkpad leg (100, ordinary, live-account).**

- Outcome: Geoff launches this session on the thinkpad. It is unisolated and makes its own initiatives worktree for its one commit. It works in this order:
  1. It records `refs-baseline-thinkpad-x1` against the thinkpad's main checkouts before any pull.
  2. It runs `thinkpad-cleanup` as a dry run, then for real.
  3. It takes `batched-docs-tool-initiative.md` if it exists, folds it into the drafter record, deletes it, and removes its index line. If it's absent, it records the file as lost and removes the line.
  4. It pulls every repo in `scope.tsv` in merge order, runs `stow -R bin claude`, and runs both install steps.
  5. It runs `refs apply` over the thinkpad's memory files.
  6. It runs the design's checks 1 to 6.
- Files: `drafter/README.md` (the fold) and `repo-organization/research/2026-10-14-thinkpad-checks.md`.
- Acceptance: all six checks pass, and check 1 is diffed against the thinkpad's own baseline.
- Test: the checks.

## Path

Here is the longest chain:

| Step | Minutes |
|---|---|
| C0 | 20 |
| I1 | 75 |
| Pair A | 100 |
| Pair B | 130 |
| Pair C | 70 |
| C1 | 20 |
| I8 | 60 |
| Geoff's dry-run approval | not counted |
| R1 | 45 |
| W8 | 60 |
| W7 | 60 |
| W close | 45 |
| Merge | 5 |
| C6 | 30 |
| C7 | 30 |
| T1 | 100 |
| C8 | 25 |
| **Total** | **875** |

The chain works because the side branches finish ahead of the steps that need them:

- The workstation executor's earlier tasks (W4, the W2 and W3 pair, W5, and W6) finish ahead of W8.
- I9 and PR 1 finish before W7 needs the merged map.
- The retire, drafter, queue, and sweep PRs finish before W close's draft check needs their merges.

The figure assumes G-p5 passes before I9. If it doesn't, I9's drafter rows, D1, and W7 wait, and that wait isn't counted.

The task sum is 2,460: the conductor 235, initiatives 810 (its close 40 included), retire 75, workstation 465 (its close 45 included), drafter 130 (close 30), queue 105 (close 30), sweeps 540 (each close included), and thinkpad 100.

At 875 minutes, the path is 1.04 times the design estimate and under the 1,680 ceiling.

The estimates come from these Score sections:

| PR | Planned path (minutes) | Actual (minutes) |
|---|---|---|
| drafter#30 | 285 | about 70 |
| drafter#31 | 150 | about 10 |
| drafter#16 | 355 | about 30 |
| drafter#6 | 175 | about 35 |
| workstation#61 (its half) | about 180 | about 20 |

drafter#11 recorded no actual. Actuals ran 7 to 25 percent of the planned path. The figures here stay at planning scale anyway, for two reasons: most of this pass is live-account and cross-repo work with no measured precedent, and the clock stop fires at twice a figure, so a figure cut to past actuals would stop on the first API retry or gate queue. Expect the actual well under 875.

## Merge order

1. `glw907/approval-queue` exists (C2). Then initiatives PR 1, then dubplate, then poplar.
2. drafter, then approval-queue.
3. Initiatives PR 2 (retire), cairn-cms, aksailingclub-org, 907-life, cairn-pub, cairn-themes, ecxc-ski, phonebook, and xcathletes-org, in any order.
4. workstation, last.
5. On pavilion (C6), then on the thinkpad (T1): pull, run `stow -R bin claude`, then `make -C ~/Projects/drafter install` and `bash ~/Projects/approval-queue/scripts/install.sh`. Neither install runs before the workstation merge and restow, because until then `~/.claude/workflows` is a folded link into `~/.dotfiles` and `~/.local/bin/approval-queue` is a stow link.
6. Initiatives PR 3 (thinkpad), after T1.

Before-merge steps known now:

- Initiatives PR 1, `## Before merge`: run `gh repo view glw907/approval-queue`, then `scripts/check --repos` from the PR's worktree under Geoff's `gh` login. The check: both exit 0.
- Workstation PR, `## Before merge`, with three steps:
  1. Confirm the drafter and approval-queue PRs merged and both checkouts are pulled.
  2. Rerun W7's draft check.
  3. Confirm no other queue command is waiting, with `pgrep -f 'bin/approval-queue'` showing only this merge's own hand-over, now finished. The merge removes the command from under any command still waiting.
  - The check: the draft check exits 0.
- drafter and approval-queue PRs: no before-merge step. Their install waits for step 5.
- Every other PR: none known.

## Geoff's touchpoints

These come in order:

1. Merge workstation#69.
2. The ten ROADMAP triage items and the migration-calls item. The design's text implies the migration-calls item ("Geoff's call replaces the state", and three dubplate collisions differ), though the brief's list doesn't name it.
3. The dry-run item, with its by-hand list: revoke the scratch-site token, run `gh auth refresh -s delete_repo` on pavilion, and confirm the thinkpad's `values.age` is clean.
4. A 1Password unlock at W8, only if the age key's cache has expired.
5. Every PR read, sixteen in all.
6. On the thinkpad, two commands:
   - `gh repo clone glw907/initiatives ~/Projects/initiatives`, or `git -C ~/Projects/initiatives pull` if the clone exists.
   - `cd ~/Projects/initiatives && claude --bg --model sonnet --effort medium --name initiatives-repo-organization-thinkpad "$(cat repo-organization/plans/2026-10-14-repo-organization-thinkpad-prompt.txt)"`.

## Review Focus

These are five failure modes the design implies that no task's acceptance test above exercises. Each test is added to the owning task.

1. **The drafter install writes through the folded link.** If `make install` runs while `~/.claude/workflows` is still stow's folded link, `ln -sfn` lands inside `~/.dotfiles/claude/.claude/workflows/` and dirties workstation. Test (D1): with a temp `HOME` whose `.claude/workflows` is a symlink into a fixture "dotfiles" tree, install exits nonzero and writes nothing there.
2. **The store edit lands in the main checkout.** `secret-set.sh` hard-codes `$HOME/.dotfiles/secrets/values.age`, so a run from the pass worktree edits the main checkout and regenerates `~/.local/secrets` from it. Test (W8): with the override pointing at a temp store, a `--delete` run leaves a fixture "main checkout" store byte-identical.
3. **Apply mode follows a symlink out of its root.** `~/.claude/skills` resolves into `~/.dotfiles`, so an apply over a root that reaches a symlinked directory would edit the main checkout. Test (I4): a fixture root containing a symlink to a directory outside it; apply edits nothing whose `realpath` lies outside the root and lists the skip.
4. **A shared resource reads as sole-owner because its binding hides in a wrangler environment block.** A surviving repo may bind the id only under `[env.<name>]`, or in `wrangler.jsonc`. Test (I5): fixtures with the id only in an env block, and only in a `.jsonc` file; each must come out `shared-with`.
5. **An extract that misses a historical path still passes the tip-tree check.** The tip tree matches even when the `review-desk` history is lost. Test (I6): extract a fixture repo with a rename while listing only the new name; `verify.txt` must report the first-commit mismatch and not end `verified`.

## Later (not built)

- Self-merge for sweep PRs whose highest class is `ordinary`, which would cut Geoff's reads from sixteen to about seven (a product call for Geoff).
- Letting isolated executors write the pass clock file (the guard refuses it today).
- Making `scope.tsv` a standing file the next cross-repo initiative reuses.
- A check-drift leg for a dangling stow link, and a drafter GitHub CI (both refused in the fold, and still not built).
