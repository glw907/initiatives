# Repo organization pass plan

Initiative: repo-organization
Design: `~/Projects/initiatives/repo-organization/specs/2026-10-14-repo-organization-design.md` (commit `750ad14`, approved by Geoff 2026-10-14)
Fold records: `~/Projects/initiatives/repo-organization/research/2026-10-14-repo-organization-fold.md` (the design's mechanisms, probed) and `~/Projects/initiatives/repo-organization/research/2026-10-14-repo-organization-plan-fold.md` (this plan's review fold, its deviations from the design, and Geoff's rulings on it)
Class: `auth-data` by the dotfiles path map, for task W8 only (`secrets/**`, `scripts/secrets/**`, `bash/.bashrc`); every other task is `runner` or `ordinary` as stated, matching the design's `runner`. Flag: `live-account`.
Adapters: `pass-core`; `dotfiles-pass` (workstation); `cairn-pass` (cairn-cms); `site-pass` (907-life, aksailingclub-org, cairn-pub, ecxc-ski, xcathletes-org). The initiatives, drafter, approval-queue, dubplate, poplar, cairn-themes, and phonebook repos have no adapter; their gate, path class, and close steps are stated here, with `pass-core`'s `runner` definition as the path map.
Engine consultation: no engine asks. Facts consulted: none, since no task touches a cairn engine surface.
Design estimate: 840 path minutes. Standing approval (Geoff, 2026-10-14): a plan or a run up to 1,680 path minutes proceeds without stopping.
Plan path minutes: 1,150. Task sum: 3,070.

## Outcome

The design's six end-to-end checks pass on the thinkpad, and pavilion passes the same checks first. Concretely, the pass delivers the following:

- `glw907/initiatives` is public, with eight records and a CI-checked index.
- Every session prints its repo's initiatives.
- ROADMAP.md is gone from ten repos, each entry handled by Geoff's call.
- Past docs live where the placement rule puts them.
- Drafter's pieces live in `drafter`, and the queue lives in `glw907/approval-queue`, both with history.
- Eleven repos and folders are retired, and only sole-owner Cloudflare resources are torn down.

## How the work splits

Worktree isolation guards only the launch repo's main checkout. The worktrees page ("How Claude Code enforces isolation") says the checks "apply to the repository you launched Claude Code from", and that "None of them tracks which files a shell command writes". A probe of a real isolated session on Claude Code 2.1.299 confirmed it. `git -C` into another repo, a clone into the scratchpad, a `Write` outside both repos, and a Bash redirect into the session's own git dir all ran. `git -C` into the session's own main checkout and a `Write` into it were refused. So an executor may run git in any other repo and write machine state by shell, and the one thing it can't do is touch its own launch repo's main checkout. The conductor keeps only the steps that need Geoff's approve or a merge: launches, queue hand-overs, merges, pulls, installs, and the end checks.

| Session | Launched from | Repo it commits to | Tasks |
|---|---|---|---|
| `conductor-initiatives` (Opus, medium) | `~/Projects/initiatives` | STATUS and record hand-overs only, per `pass-core` "Ledgers" | C0, C2, C6 to C9 |
| `initiatives-repo-organization` | `~/Projects/initiatives` | `glw907/initiatives` (PR 1) | I1 to I10 |
| `initiatives-repo-organization-retire` | `~/Projects/initiatives` | `glw907/initiatives` (PR 2) | R0 to R3 |
| `workstation-repo-organization` | `~/.dotfiles` | `glw907/workstation` | W2 to W8 |
| `approval-queue-repo-organization` | `~/Projects/approval-queue` | `glw907/approval-queue` | A1 |
| `<repo>-repo-organization`, one per sweep repo | that repo's main checkout | that repo | S-`<repo>` |
| `drafter-repo-organization` (follow-up) | `~/Projects/drafter` | `glw907/drafter` | D1 |
| `initiatives-repo-organization-drafter` (follow-up) | `~/Projects/initiatives` | `glw907/initiatives` (PR 4) | I11 |
| `workstation-repo-organization-drafter` (follow-up) | `~/.dotfiles` | `glw907/workstation` (follow-up PR) | W9 |
| `initiatives-repo-organization-thinkpad` | `~/Projects/initiatives` on thinkpad-x1, launched by Geoff | `glw907/initiatives` (PR 3) | T1 |

The sweep repos are `dubplate`, `poplar`, `cairn-cms`, `907-life`, `aksailingclub-org`, `cairn-pub`, `cairn-themes`, `ecxc-ski`, `phonebook`, and `xcathletes-org`.

The drafter follow-up. Every piece that waits on drafter pass 5 (G-p5) moves to a follow-up set: the drafter rows of the map, marked `deferred:p5`, D1, the drafter half of the workstation code move, and the removal of the cairn-cms drafter worktrees. The follow-up runs once G-p5 passes, so no main-set PR waits on pass 5 (Geoff, 2026-10-14). Pass 5 merged before this pass launched (drafter#37, head `worktree-p5-pipeline`, and cairn-cms#124, both merged 2026-10-14), so G-p5 is expected to pass at C0 and the follow-up starts at once. Its structure stays: the edit is smallest that way, and the drafter set still never holds a main-set PR. The thinkpad leg runs after the follow-up merges, so end-to-end check 4 runs once, on both machines.

Why the conductor is `conductor-initiatives`. The conductor runs from `~/Projects/initiatives` and launches each executor with `(cd <checkout> && claude --bg ...)`. There are three reasons:

- The initiatives repo holds this plan, every prompt, the tools, and the research records, and it is the home of the first and last executors.
- It is the cross-repo work's home under the design's own placement rule.
- A name tied to one code repo would collide: `conductor-drafter` is live today, and a later workstation planner that finds a live `conductor-workstation` hands it an unrelated pass.

Model and effort: executors `sonnet` at `medium`, pair subagents the same with `description` `<session> task <id>`. The conductor runs at `claude-opus-5-5` `medium`.

## Shared interfaces

- **Scope list**: `repo-organization/scope.tsv` in initiatives, with columns `repo`, `role`, and `path`. It holds exactly 26 rows: 14 `edit` rows (initiatives, workstation, drafter, approval-queue, and the ten sweep repos), 1 `read` row (`aksailingclub-legacy`), and 11 `retire` rows. Every repo-wide step reads this list and never globs `~/Projects`, including the reference tool, the inventory, the worktree listing, the thinkpad script, the end-to-end checks, and "pulls every repo". An `edit` or `read` row whose path is missing makes a tool exit nonzero and name the row, except that under `--host thinkpad-x1` a missing `read` row is reported `absent` with exit 0. A missing `retire` path is reported `absent`. Every scope-reading tool's tests carry the thinkpad `read`-row case.
- **Memory directories**: built from `scope.tsv`, as each `edit` or `read` row's encoded project path (`-var-home-glw907-Projects-<repo>`, plus the `.dotfiles` encoding for workstation) and its `.claude/worktrees` variants, never a `*` glob.
- **Out-of-scope names**: no committed or handed-over file names a repo outside the list. The inventory reports a binder outside the list as `shared-out-of-scope`, with no name. Every PR's close runs the **name check**, and so does C0 before its push. The check first builds the outside names into a temp file, in a step of its own: `gh repo list glw907 --limit 200` (whose exit status it checks) plus the `~/Projects` entry names, minus `scope.tsv`, with blank lines dropped. The file must hold at least `gh repo list glw907 --limit 200 --json name --jq length` minus the in-scope names on GitHub, so a failed or partial `gh` can't empty it. Then it runs `command grep`, so GNU grep runs in sessions too, where `grep` is a shell function. A PR's form is `git log -p origin/main..HEAD | command grep -wF -f <names file>`, which also reads commit messages and lines a later commit removed. C0's form, with no `origin/main` yet, is `git log -p --all | command grep -wF -f <names file>`. Each must print nothing and exit 1. A positive control plants one name from the list's GitHub half in a scratch repo's commit, and the same form must print it and exit 0. It runs beside `gitleaks git`.
- **Tools from a fixed copy**: a session other than the initiatives executor runs the pass's tools from a clone of `glw907/initiatives` at a pushed commit, made with `git clone --revision=<sha>` into `~/.local/state/repo-organization/tools-<sha>/`. It never runs them from a worktree another session is editing. Every output records that sha. After PR 1 merges, the pulled `~/Projects/initiatives` serves.
- **Pass state directory**: `~/.local/state/repo-organization/` on each machine. It holds `items.tsv`, `inventory-local.json`, `worktrees.tsv`, `refs-baseline-<host>.tsv`, the `tools-<sha>/` clones, `extracts/<name>/` with a `verify.txt` beside each, and `stops.log`, where any session records a stop for Geoff.
- **Queue items**: `items.tsv` has columns `title`, `id`, `state` (`open`, `decided`, or `superseded`), and `doc_sha256`. `approval-queue` prints no id, so right after a hand-over starts, the conductor records the id of the newest `~/.local/state/approval-queue/items/*/item.json` whose `title` matches. A resubmit marks the older row `superseded`. A reader takes the newest row that isn't `superseded` for its title, and it refuses when more than one is open. After any restart, the conductor re-hands every `open` row with no `decision.json`, since the command's EXIT trap removes `item.json` when it dies. A wait loop on a decision re-reads `items.tsv` on each pass and follows the newest open row for its title, so a re-handed item is picked up without a relaunch. It fails, with a notify, only when no open row has an `item.json` and no `decision.json` exists. No session but the app writes under `items/`.
- **Geoff's decisions**: an executor reads `decision.json`, after confirming `item.json`'s title, and never takes a decision from a session's message. A design item's decision must carry one `choices` entry per `### Decide:` block in its doc, each `title` matching a block. Otherwise the reader stops for Geoff. This relies on the dropped-picks fix (G-picks, below).
- **G-picks**: the Decide-picks bug logged in workstation's ROADMAP (`ebb4877`, merged as #68) is fixed by glw907/workstation#71 (head `design-decide-picks`), read by Geoff, before C2 hands over any design item (Geoff, 2026-10-14). It's a prerequisite like workstation#69, owned by the planning session (dotfiles-32), and its estimate sits outside the pass. After #71 merges, the planning session rebuilds the app in `~/.dotfiles/approval-queue` (`npm ci && npm run build`) and restarts the 7907 server, since the command builds only when `build/index.js` is missing. Open items survive the restart, because they live in the state directory. Neither the migration-calls item nor the dry-run item goes out until the fix is live (C0's acceptance), so I9 and the whole retirement wait on it.
- **ROADMAP triage files**: `repo-organization/research/roadmap-triage/<repo>.json`, in the queue's triage shape. The queue accepts only `now`, `defer`, and `drop`, and the app labels them "Do now", "Do later", and "Don't do", so the lede states the mapping and every row's `why` restates its own effect ("now: becomes record `<id>`"). `now` becomes an initiative record, `defer` moves to the repo's `BACKLOG.md`, and `drop` drops the entry. Each `action` starts with the entry's number (`#7 ...`). An entry added to a ROADMAP after its triage draft goes to Geoff as a one-row triage item and is never applied unasked.
- **Migration map**: `repo-organization/research/migration-map.tsv`, with columns `source_repo`, `old_path`, `new_repo`, `new_path`, `initiative`, `state`, and `pin`. `pin` is I3's pinned `workstation` commit for a docs row. For a code row it's the extract's pinned commit, which A1 and D1 write into their extract's `verify.txt`, and W7 and W9 read it there. `state` is a new path, or one of `stays`, `leaves-with-pings`, `deferred:<pass>`, `flagged`, `collision-identical`, or `collision-differs`. The drafter rows carry `deferred:p5`.
- **Retirement manifest**: `repo-organization/research/retire-manifest.tsv`, with columns `stage`, `kind`, `id`, `action`, and `expect`. It covers every Cloudflare id, repo delete, description, secret name, manifest line, local directory, D1 export, and worktree. `expect` holds the fact the act-time recheck compares: HEAD and branch tips for a git target, newest mtime and file count for a plain directory, and `sole-owner` for a resource. The dry-run doc embeds the manifest verbatim in a fenced block, so the approved snapshot carries it. At the approve, the conductor writes the sha256 of the item's `doc.md` into `items.tsv`. R0 copies it into the committed retirement log as its own row, `archive<TAB>doc_sha256<TAB><hex><TAB><time>`, beside a row `archive<TAB>doc_commit<TAB><sha><TAB><time>` naming the commit of the approved dry-run file. R0 to R3 and W8 extract the manifest from `doc.md`, check the hash, and act only on its rows. On the thinkpad, which has no `doc.md`, T1 hashes `git show <doc_commit>:repo-organization/research/2026-10-14-retirement-dry-run.md`, reading both values with `awk` on the second column, and extracts the manifest from that same blob, so a later commit to the file can't trip it. A mismatch stops for Geoff. I8 leaves out of the manifest the worktrees C9 reserves: cairn-cms's `drafter-pipeline` and `p5-scratch`, and drafter's `agent-*` worktrees.
- **Retirement log**: `repo-organization/research/2026-10-14-retirement-log.tsv` on PR 2's branch, with columns `stage`, `item`, `result`, and `time`. Each item is pushed after it's appended.
- **Pass 5 check (G-p5)**: `gh pr list -R glw907/drafter --head worktree-p5-pipeline --state merged --json number` (drafter#37) and `gh pr list -R glw907/cairn-cms --head drafter-pipeline --state merged --json number` (cairn-cms#124) each return one PR; both merged on 2026-10-14. `claude agents --json` exits 0, lists the conductor's own `conductor-initiatives` row under `name` as a positive control, and lists no live row, meaning one whose `state` isn't `done`, whose `name` equals `conductor-drafter` or starts with `drafter-p` followed by a digit. The pass's own `*-repo-organization*` names never match. If either half still fails 72 hours after C0, the conductor logs a line in `stops.log` and notifies Geoff. Only the follow-up set waits on G-p5.
- **Clock file**: each executor writes `pass-task-clock` per `pass-core` with a Bash redirect to `<git rev-parse --absolute-git-dir, run in its worktree>/pass-task-clock`. The `Write` tool is refused there, and the redirect isn't. A wait on Geoff or on another session removes the file first and writes a new `start=` after.
- **Stops**: a session that stops for Geoff appends one line to `stops.log` and runs `notify-send -u normal`. No session writes `~/.dotfiles/docs/STATUS.md` before C8.
- **Stow**: every restow is `stow -d ~/.dotfiles -t ~ -R bin claude`, since no `.stowrc` exists.
- **Secret store rule**: a dirty `secrets/values.age` is never discarded or overwritten. The session that finds one stops, re-applies it with `secret-set.sh` only on Geoff's word, and notifies him.

## Gates per repo

| Repo | Gate (fast lane) | Full-suite home | Setup |
|---|---|---|---|
| initiatives | `bash scripts/gate.sh` (I1 adds it; light lane; it runs `scripts/check` and every test, found by glob) | CI on the PR (`.github/workflows/check.yml`), watched with `gh pr checks <n> --watch --fail-fast` in the background | none |
| workstation | `bash scripts/gate.sh` | the same, once on the close head | none |
| drafter | `DRAFTER_DIR="$PWD" bash ~/.dotfiles/scripts/drafter-gate.sh` until D1 moves it, then `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` | that gate on the close head | none |
| approval-queue | `bash scripts/gate.sh` (A1 adds it: the app's `check` and `test`, plus the two moved shell tests) | that gate on the close head | `npm ci --prefix approval-queue`, after the extract merges |
| dubplate, poplar | `bash scripts/gate.sh` | local on the close head; poplar's CI also runs on the PR | per their CLAUDE.md |
| cairn-cms | `cairn-pass` fast lane | CI on the draft PR, `ci-green` watch | `cairn-pass` setup |
| sites | `site-pass` table | `site-pass` table | `site-pass` table |
| cairn-themes, phonebook | none exists; the task's own checks are the gate | none | none |

## Tasks

Estimates are minutes of work. A wait on Geoff or on another session is not counted.

### Conductor

**C0. Launch gate and the initiatives remote (30, ordinary, live-account).**

- Outcome: the pass may start.
  - `gh pr view 71 -R glw907/workstation --json state` reads `MERGED` (Geoff, 2026-10-14), and the fix is live. `grep -rlq decideCards ~/.dotfiles/approval-queue/build/server` succeeds, and the 7907 listener's `/proc/<pid>/cmdline` names that build. Its real start time, `date -d "$(ps -o lstart= -p <pid>)" +%s`, is at or after the mtime of `build/server/chunks/cards.js`. The `/proc/<pid>` directory's own mtime isn't a start time and is never used. This check needs no browser and no Host header. It's met on pavilion today: #71 merged as `2d52695`, and the planning session rebuilt and restarted the app at 11:38.
  - `~/.dotfiles` has been pulled, and `git -C ~/.dotfiles status --porcelain secrets/` is empty.
  - The one-executor checks pass for `~/Projects/initiatives` and `~/.dotfiles`.
  - `gitleaks git` and the name check's history form pass over the local initiatives history, and then `glw907/initiatives` is created public from the local `main` (`gh repo create glw907/initiatives --public --source ~/Projects/initiatives --remote origin --push`).
  - `.claude/worktrees/` is excluded in each launch checkout (`pass-core` "Execute").
- Files: none committed.
- Acceptance: `gh repo view glw907/initiatives --json visibility` reads `PUBLIC`. `git rev-list --count` is 0 both ways between `HEAD` and `origin/main`, the `secrets/` porcelain line is empty, and `git check-ignore -q .claude/worktrees/x` succeeds in each launch checkout.
- Test: none, since this task runs commands and writes no code.
- Then: launch the initiatives executor and the workstation executor.

**C2. Queue hand-overs and the empty queue repo (30, ordinary, live-account).**

- Outcome: the queue's repo exists right after C0, before I8's local legs need its row, and Geoff sees every decision item. The two design items go out only once C0 has confirmed the G-picks fix is live.
  - As each triage file is pushed, it goes to Geoff as `approval-queue triage glw907/<repo> "Retire ROADMAP.md in <repo>" <file>`. The map-calls brief from I3 goes as `approval-queue design initiatives "Migration map calls" <file>`, and the dry-run brief from I8 as `approval-queue design initiatives "Repo retirement dry run" <file>`. Each runs in the background, and its row goes into `items.tsv` as "Shared interfaces" states.
  - On a reject of a design item, the drafting session revises from the note, and the conductor re-hands the item and marks the old row `superseded`.
  - First, the conductor creates `glw907/approval-queue` (public, with one README commit so an extract can arrive by PR: `gh repo create glw907/approval-queue --public --add-readme`). It clones it to `~/Projects/approval-queue` and excludes `.claude/worktrees/` there.
- Acceptance: first, `gh repo view glw907/approval-queue` succeeds and `~/Projects/approval-queue` exists. Then, per item, its row's `item.json` exists with the matching title right after the hand-over.
- Test: none.

**C6. Merges, pulls, and installs (50, runner).**

- Outcome: the conductor merges every main-set PR in "Merge order" on Geoff's approve, or as the self-merge rule allows (Geoff, 2026-10-14). It then follows step 5 of that order on pavilion. After the workstation merge it pulls, restows, then runs `make -C ~/Projects/drafter install` (once the follow-up has merged) and the approval-queue install step. It runs `secret-set.sh --sync` from the main checkout, stops the old 7907 server, and removes `~/.dotfiles/approval-queue/`. It runs the reference tool's apply mode over pavilion's scope memory directories (the tool tars them first), and removes the `batched-docs-tool-initiative.md` index line from `MEMORY.md`. The conductor's own checkout is exempt from the "no live session" pull rule.
- Acceptance: `git -C ~/.dotfiles status --porcelain` is empty, and `test ! -e ~/.dotfiles/approval-queue` succeeds. `realpath` of `approval-queue` and `claude-approval-queue-reminder` in `~/.local/bin` lies under `~/Projects/approval-queue`. `grep -c batched-docs-tool-initiative` in pavilion's `MEMORY.md` is 0, and no process listens on 7907 before the C7 check starts one.
- Test: A1's install test.

**C7. Pavilion end checks and the thinkpad hand-off (20, ordinary).**

- Outcome: the conductor runs `repo-organization/tools/e2e-check --host pavilion` (I10). Check 5's thinkpad half waits for its machine, and check 4 waits for C9. It sends Geoff the two thinkpad commands from "Geoff's touchpoints" with `notify-send -u normal` once the follow-up set has merged.
- Acceptance: the tool exits 0, and its output goes into the C8 hand-over.
- Test: the tool's own tests.

**C8. Close (25).**

- Outcome: PR 3 from the thinkpad is read and merged. The `repo-organization` record's README gets a dated status line, and the STATUS hand-over lands in `workstation` and initiatives per `pass-core` "Ledgers", carrying every `stops.log` line. Then the conductor stops itself.

**C9. The drafter follow-up (20, runner, live-account).** This task waits on G-p5, checked at C0. It launches D1 once W4's `git-filter-repo` is installed and I6's extract tool is pushed, I11 once I3's map is pushed, and W9 after the main workstation PR, the drafter PR, and PR 4 merge.

- Outcome: the conductor launches the three follow-up sessions, merges drafter, then initiatives PR 4, then the workstation follow-up PR, on Geoff's approve. After the workstation merge it restows and runs `make -C ~/Projects/drafter install`. It removes the cairn-cms `drafter-pipeline` and `p5-scratch` worktrees and the drafter `agent-*` worktrees from passes 1 to 4 if the worktree tool marks them removable, logging each verdict first.
- Acceptance: `realpath` of `~/.claude/workflows/docs-page-chain.js` and of `~/.local/bin/cairn-docs-outline` lies under `~/Projects/drafter`, `git -C ~/.dotfiles status --porcelain` is empty, and `e2e-check --host pavilion --only 4` exits 0.
- Test: D1's install test.

### initiatives-repo-organization (PR 1)

**I1. Repo scaffold and record check (85, runner).**

- Outcome: the repo matches the design's layout.
  - `README.md` explains what an initiative is, with the three-step placement rule, the symlink note, and a generated index table.
  - `REGISTER.md` records Geoff's 2026-10-14 voice ruling with its provenance.
  - `scripts/check` fails, naming the file, on each of the nine states the design lists. `scripts/check --repos` checks `repos` against `gh repo list glw907 --limit 200`.
  - `scripts/index` writes the README's index from the YAML.
  - `scripts/test.sh` finds tests by glob, and `scripts/gate.sh` runs the gate. `.github/workflows/check.yml` runs every state but `repos`, plus the tests.
- Files: `README.md`, `REGISTER.md`, `scripts/{check,index,test.sh,gate.sh}`, `tests/check/` with fixtures `tests/fixtures/check/<state>/`, `.github/workflows/check.yml`.
- Acceptance: each of the nine bad fixtures fails with its file named, and the good fixture passes. `--repos` passes on a good fixture and fails on one naming `glw907/no-such-repo`, and CI mode passes on that second fixture.
- Test: one bad fixture per state, plus an empty tree, plus a good tree, plus the two `--repos` fixtures.

**Pair A, run after I1.**

**I3. Scope list, classifier, migration map, and the scope harness (115, ordinary).**

- Outcome: `scope.tsv` holds the 26 rows "Shared interfaces" names.
  - `repo-organization/tools/classify-docs` reads a scratch clone of `glw907/workstation` at the pinned commit. The pinned commit is `origin/main` at task start, taken with `gh api`.
  - The tool also reads scratch clones of the destination repos, and writes `migration-map.tsv` with one row per `docs/` entry and per moved code path, including the `review-desk` names as history rows that aren't rewritten. It prints the row count per `new_repo`.
  - It runs the one-executor checks, with `claude agents --json` rows filtered to `cwd`s under in-scope checkouts, and each in-scope repo's STATUS read by path. It marks a plan with an open pass `deferred:<pass>`, and every drafter row `deferred:p5`.
  - It writes `repo-organization/research/migration-calls.md`, an approval-brief design doc with one `### Decide:` block per `flagged` row and per `collision-differs` row. For a collision, "Keep the destination" is recommended.
  - `repo-organization/tools/tests/scope-harness` is the shared outside-scope test every scope-reading tool calls. It builds a fixture root with in-scope repos and one readable outside repo, `.git` included, whose name and contents carry a unique canary. It runs the tool with `PROJECTS_ROOT` and `HOME` pointed at the fixture root, and asserts that the canary appears in no stdout, stderr, or file the tool writes, while an in-scope canary does appear.
- Files: `repo-organization/scope.tsv`, `repo-organization/tools/classify-docs`, `repo-organization/tools/tests/classify/`, `repo-organization/tools/tests/scope-harness`, `repo-organization/research/migration-map.tsv`, `repo-organization/research/migration-calls.md`.
- Acceptance:
  - `scope.tsv` holds the 26 named rows.
  - The docs rows equal `ls docs/{specs,plans,research} | wc -l` at the pinned commit (173 expected), counted apart from the classifier, and every row holds a placed state. The code rows equal the design's two lists, checked by exact path.
  - A fixture entry the rule can't place comes out `flagged`. An identical file of the same name in `archive/` comes out `collision-identical`, and a differing one comes out `collision-differs`.
  - `migration-calls.md` passes `approval-queue`'s brief check, and its block count equals the `flagged` plus `collision-differs` row count (3 or more).
- Test: fixture trees for each state, a stubbed agents list and STATUS for `deferred:<pass>`, and the scope harness.

**I7. ROADMAP triage drafts (80, ordinary).**

- Outcome: there is one triage file for each `edit`-role repo with a ROADMAP.md, except `cairn-cms`. The ten are 907-life, aksailingclub-org, cairn-pub, cairn-themes, dubplate, ecxc-ski, phonebook, poplar, workstation, and xcathletes-org.
  - Each file drafts a disposition and a one-line reason per entry, and each row's `why` restates its effect.
  - Its lede states the repo's entry count and the disposition mapping.
  - Each "become a record" row's `detail` names the proposed record id and repos.
  - Entries are counted by the design's rule: top-level bullets, or `###` headings in a repo that uses headings.
- Files: `repo-organization/research/roadmap-triage/<repo>.json`, `repo-organization/tools/roadmap-count`, and its test.
- Acceptance: each file passes the queue's brief check, and its row count equals `roadmap-count`'s count for that repo. The counts match the design's known figures: workstation 22, aksailingclub-org 21, and about 80 in all.
- Test: `roadmap-count` fixtures for a bullets-only file, a headings file, and a mixed file, the way aksailingclub-org (19 headings and 2 bullets) and poplar mix them. The expected count is fixed per fixture.

**Pair B, run after Pair A.**

**I4. Reference tool (160, ordinary).**

- Outcome: `repo-organization/tools/refs`, with `check` and `apply` modes, reads the map and `scope.tsv`.
  - It resolves bare `docs/` paths against the containing repo, and `~/`, `/var/home/`, and `~/Projects/<repo>/` paths literally.
  - It classes each hit as `rewrite`, `retired-target` (from history files, never a failure), `live-tie`, or `broken`. A rewritten path resolves against its map row's destination on that repo's `origin/main` through `gh api`, or against the map itself while the destination is unmerged.
  - Its scope is git-tracked text files, minus `.claude/worktrees/`, lockfiles, `_salvage/`, and the named fixture list. Memory files are the scope memory directories ("Shared interfaces").
  - Apply mode takes one root and edits only files whose `realpath` lies under it, listing every skip. It tars the memory directories first, writes through a temp file and a rename, and deduplicates by `realpath`.
  - Check mode records a baseline keyed by host, repo name, repo-relative file, and referenced path, and diffs against it.
- Files: `repo-organization/tools/refs`, `repo-organization/tools/tests/refs/`.
- Acceptance:
  - A planted reference to a missing `initiatives/<id>/` path is reported `broken`.
  - A retired-target reference in a history file is listed and exits 0, and a live-file reference to a retired target comes out `live-tie` and exits nonzero.
  - A first apply run rewrites at least one fixture file, and a second rewrites none.
  - A bare path resolves against its own repo when two fixture repos carry the same relative path.
  - A baseline recorded on a fixture main checkout, then a check over a worktree of the same repo, reports nothing new, and a break planted only in the worktree reports exactly one.
  - A rewritten path whose destination exists only in the map resolves.
  - A rewritable path planted under each excluded location stays untouched, the memory tar exists before the first write and holds the pre-edit bytes, and a reference broken before the move isn't rewritten.
- Test: those cases, the scope harness, and Review Focus 3.

**I5. Inventory (160, ordinary, live-account).**

- Outcome: `repo-organization/tools/inventory` takes `--network` and `--local` legs over the `retire` rows of `scope.tsv`.
  - It reports each target's kind and ties as the design's step 1 lists them, and writes each target's `expect` facts.
  - It derives Cloudflare ties from each target's own files, including a deploy workflow's `wrangler deploy --name`, and resolves each by id against every `edit` or `read` repo's wrangler configs and deploy workflows.
  - A resource is `sole-owner` only when no in-scope config names it and no deployed Worker outside the targets binds it, read from the account's Worker settings through the API. An outside binder is reported `shared-out-of-scope`, with no name.
  - An Access app, DNS record, route, or custom domain is `sole-owner` only when every hostname it covers resolves to target Workers alone, by exact match, with no wildcard that covers a surviving host.
  - It sources `~/.local/secrets` itself and exits nonzero on any API or auth error, and on an account Worker list that lacks the `pings` Worker, since a 200 with an empty list would otherwise read as "no ties".
- Files: `repo-organization/tools/inventory`, `repo-organization/tools/tests/inventory/` with a known-ties fixture.
- Acceptance: on the fixture it reports the `pings` Worker and `PINGS_ADMIN_TOKEN` ties, and the `asc-handbook`, `asc-uptime`, and `asc-event-images` resources come out `shared-with aksailingclub-legacy`. A resource bound only by a target comes out `sole-owner`. A stubbed outside Worker binding a fixture id makes it `shared-out-of-scope`, and a stubbed empty Worker list or API error exits nonzero.
- Test: those cases, the scope harness, and Review Focus 4.

**Pair C, run after Pair B.**

**I2. Initial records (75, ordinary).**

- Outcome: there are eight records with `initiative.yaml` and a KEP README (Summary, Motivation, Goals, Non-goals, Where the work lives, and Records). They are the seven the design lists, plus `workstation-secrets`.
  - `workstation-secrets` is `proposed`, with repos `[workstation]`. Its README states Geoff's 2026-10-14 goal, "a better way of tracking the age secrets across workstations", and names the evidence. `DRAFTER_API_KEY` was stored on pavilion through `secret-receive` on 2026-10-13, and it sat uncommitted with no registry entry until workstation#69. Nothing told the thinkpad.
  - `personal-design-system` carries the design's notes on its pieces and on the `personal-styles` collection shape.
  - `repo-organization` links the spec, both fold records, and this plan. The index is regenerated.
- Files: `<id>/initiative.yaml` and `<id>/README.md` for each record, plus `README.md` (index).
- Acceptance: eight record directories exist with the eight named ids, and each README holds the six section headings. `scripts/check` passes, and `scripts/check --repos` passes once C2 has created `glw907/approval-queue`.
- Test: the I1 check.

**I6. Worktree, thinkpad, and extract tools (100, ordinary, live-account).**

- Outcome: three tools, each over `scope.tsv`.
  - `repo-organization/tools/worktrees` lists every worktree in scope with its branch, merged state, lock, dirty and ignored files, process, and mtime. It marks a worktree removable only under the design's five rules plus a sixth: the worktree belongs to an `edit` row. A `read`-row worktree is listed as "left for the cutover".
  - `repo-organization/tools/thinkpad-cleanup` reads the approved manifest from the dry-run doc and covers its `retire` rows only. For each target it reports whether it has a remote, and compares a remote-less target with the manifest's `expect` facts. An identical target is removable. A differing one is refused and listed for Geoff, and a differing tar target first joins a thinkpad tar under R0's rules.
  - `repo-organization/tools/extract` runs `git filter-repo --path ...` without `--force` on a fresh clone that never moves HEAD, listing every historical path (including `review-desk` for the queue). It then writes `verify.txt`, computing each moved file's first `workstation` commit with `git log --follow --diff-filter=A`.
- Files: those three tools and their tests under `repo-organization/tools/tests/`.
- Acceptance:
  - A fixture worktree that is merged, clean under `--ignored`, unlocked, unused by any process, and two days old (`touch -d`) comes out removable. A branch equal to its base, a lock, a dirty file, an ignored file alone, a `sleep` process holding the path, a fresh mtime, and a `read`-row worktree each make it not removable.
  - The thinkpad script refuses a remote-less fixture repo with one commit beyond its `expect` facts.
  - An extract of a fixture repo with a pure `git mv` rename verifies when both names are listed, and the source-side first commit predates the rename.
- Test: those cases, the scope harness, and Review Focus 5.

**Pair D, run after Pair C.**

**I8. Local legs, dry-run brief, and manifest (90, ordinary, live-account).**

- Outcome:
  - The session runs the local legs from its own worktree against the main checkouts in `scope.tsv`: the reference tool's baseline check, the inventory's `--local` and `--network` legs, and the worktree listing. Its own repo's row reads its worktree, since its own main checkout is the one the guard refuses. The outputs go to the state directory with the tool sha.
  - It writes `repo-organization/research/2026-10-14-retirement-dry-run.md`, an approval-brief design doc. The doc lists every target and its action, every resource to tear down with each R2 bucket's object count, every shared resource left in place, every manifest line to remove, the worktree calls, the archive path, the D1 exports, and the GitHub descriptions in this repo's register. The descriptions cover cairn-cms, poplar, 907-life, cairn-pub, phonebook, workstation, and approval-queue.
  - The archive path lies under `/var/home`, outside `~/Projects` and the state directory, and never under `/tmp` or `/dev/shm`, which are tmpfs here.
  - The doc embeds `retire-manifest.tsv` verbatim. Its "Geoff does by hand" list starts with revoking `CAIRN_SCRATCH_CF_TOKEN`, then `gh auth refresh -s delete_repo`. A `### Decide:` block asks Geoff to confirm that `git -C ~/.dotfiles status --porcelain secrets/values.age` prints nothing on the thinkpad after a pull.
  - Its Worth knowing states that sharing was resolved across the scope list and the account's Worker bindings.
  - Before the brief goes out, the session checks two facts and records them in the doc: workstation#69 has merged (`gh pr view`), and `values.age` on pavilion is clean and matches `origin/main`.
- Files: the dry-run doc and `repo-organization/research/retire-manifest.tsv`.
- Acceptance: the brief passes the queue's brief check. The manifest's `cloudflare` rows are non-empty, they hold the `pings` and `cairn-scratch-b` Workers, and every id in them is `sole-owner` in an inventory output whose sha is an ancestor of the session's head.
- Test: the checks above.

**I10. End-to-end check tool (60, ordinary).**

- Outcome: `repo-organization/tools/e2e-check --host <host> [--only <n>]` runs the design's six checks over `scope.tsv`, so pavilion and the thinkpad run the same commands.
  - Check 1 runs `refs check` against that host's baseline, excluding `retired-target`.
  - Check 2 runs `gather-dotfiles.sh` from `~/Projects/drafter`, `~/.dotfiles`, and a worktree, and matches the expected records.
  - Check 3 hands over the committed fixture brief, finds the item under `items/`, and checks that the serving process's `/proc/<pid>/cmdline` names `~/Projects/approval-queue/approval-queue/build`. It then sends TERM to the waiting command, whose EXIT trap removes the item.
  - Check 4 checks the two `realpath`s and a clean `~/.dotfiles`.
  - Check 5 queries each manifest id for the API's not-found code, after a same-run positive (`gh repo view glw907/initiatives` succeeds). It checks each deleted repo for `Could not resolve to a Repository` and that the host holds no retired directory.
  - Check 6 checks ROADMAP absence in the ten repos on `origin/main` through `gh api` as well as locally, and each description.
- Files: `repo-organization/tools/e2e-check` and its tests.
- Acceptance: each check fails on a planted violation and on an empty input list (teardown ids, deleted repos, or ROADMAP repos, which must number exactly ten).
- Test: one fixture per check, plus the scope harness.

**I9. Docs into initiatives, triage records, and PR 1 (70, ordinary).**

- Outcome: this task waits on the map-calls decision and on all ten triage decisions.
  - The session applies Geoff's calls to the map, which leaves no `flagged` row.
  - It copies every initiatives row not marked `deferred:<pass>` from the scratch clone at the pinned commit, in one commit whose body names that commit.
  - It writes a `proposed` or `active` record for each distinct record id the `now` rows propose that doesn't already exist. A `now` row with no record id in its `detail` takes an id derived from its entry, and the PR body lists it.
  - It runs `refs apply` over its own worktree and regenerates the index.
- Files: `<id>/{specs,plans,research}/...` per the map, new record directories, `README.md`.
- Acceptance: `grep -c flagged` over the map is 0. Every initiatives row's `new_path` exists in the worktree, and every `now` row's record id exists. The set of new record ids equals the distinct proposed ids not already present. `scripts/check` passes, and `refs check` over the worktree finds nothing `broken` beyond the baseline.
- Test: the I1 check and the I4 tool.

Close for I (45): the gate, the name check, the whole-branch review (with `python-conventions` or `ts-conventions` by the tools' language), and PR 1 at PR-ready.

### initiatives-repo-organization-retire (PR 2)

This session launches after Geoff approves the dry run. It acts only on the approved doc's embedded manifest, with its hash checked against `items.tsv`, and on the decision. It runs the tools from a fixed copy at the dry-run sha.

**R0. The archive (40, ordinary, live-account).**

- Outcome: one archive at the manifest's path holds `cairn-scratch`, `ecxc-ski-agent-memory`, `aksailingclub-sveltekit`, and a D1 export of each D1 database in the teardown rows (Geoff, 2026-10-14). Each export runs as `npx --yes wrangler@4 d1 export <name> --remote --output <tmp>/<id>.sql`, with `CLOUDFLARE_API_TOKEN` sourced in the same command. Cloudflare documents that "A running export will block other database requests" and that export "is not supported for virtual tables", so a failed or empty export, the virtual-table case included, stops for Geoff before R1. The session writes the archive with no-clobber, refusing if the file exists, and requires `tar -c` to exit 0, then `tar -df` against the sources to exit 0, then `sync`. Its sha256 goes into the log's `archive` row, and the approved `doc_sha256` and `doc_commit` go into their own rows. A rerun that finds a logged, verified archive skips this task and never rewrites it.
- Acceptance: for each archived directory, the tar's member count equals `find <dir> | wc -l` taken just before. `tar -t` lists one non-empty `.sql` per D1 manifest row. The log's `archive` row reads `done` with both hashes.
- Test: the acceptance itself, run before any destructive stage.

**R1. Cloudflare teardown (70, ordinary, live-account).**

- Outcome: every resource in the manifest's `cloudflare` rows is torn down through the API.
  - A pre-flight call per resource kind confirms the token can read and delete that kind; KV and Email Routing aren't in the token's verified scopes. A pre-query must resolve every id.
  - Right before each delete, the session reruns the inventory's network leg for that id, and stops for Geoff on any id no longer `sole-owner`.
  - The order inside the stage is routes and custom domains, then Workers, then D1, KV, and R2, then DNS records, then Access apps last.
  - A `sole-owner` R2 bucket that still holds objects stops the stage for Geoff. The dry run lists each bucket's object count, so he sees it in advance.
  - A delete that returns 404, when a GET also returns 404, is logged `already-absent`.
  - `CAIRN_SCRATCH_CF_TOKEN` is excluded, since it's Geoff's by hand, and PR 2 records it as owed.
- Acceptance: each id returns the API's not-found code, with 403 and auth errors counted as failures. The check fails on empty `cloudflare` rows, and the log's `cloudflare` stage reads `done`.
- Test: the post-query with its empty-list and auth-error failures.

**R2. GitHub deletions and descriptions (35, ordinary, live-account).**

- Outcome: this task waits on two things. `gh api repos/glw907/workstation/compare/main...worktree-repo-organization --jq '.commits[].commit.message'` holds a message starting `W8 retire secrets from the store`, which the compare endpoint's 300-file cap on `files` can't hide, and the `delete_repo` scope shows in `gh auth status`. The session notifies Geoff once if the scope is missing. Then it runs each approved `gh repo delete glw907/<r> --yes`, sets each approved description with `gh repo edit`, and logs the `github` stage.
- Acceptance: each deleted repo returns `Could not resolve to a Repository`, after a same-run positive, and each description reads as approved.

**R3. Local retirement stage (45, ordinary, live-account).**

- Outcome: after R2's stage is logged, the session works through the local rows.
  - It reruns the inventory's local leg per target and compares it with the manifest's `expect` column, refusing and listing any changed target.
  - It removes `ecxc-ski-agent-memory` only after a commit with the subject `S-ecxc-ski fold ecxc-ski-agent-memory` is on the ecxc-ski PR's branch, matched through `gh api`.
  - It removes each approved retired directory, appending a `local` row per item.
  - It refuses by name the worktrees C9 reserves, even if the tool marks them removable.
  - It logs each worktree's removable verdict, with its six rule values, before it removes that worktree, and removes only those the tool marks removable at that moment.
- Acceptance: the log holds a `done` row for every local manifest row and a verdict row for every removed worktree, and no approved retired directory remains.
- Test: I6's worktree-rule tests.

Close for R (15): the name check, then PR 2 at PR-ready. Its body holds the log and lists the hand-done items, with whether each is still owed.

### workstation-repo-organization

**W4. filter-repo, bootstrap, and check-drift (65, runner).** This is the first task, because A1 and D1 need `git-filter-repo`.

- Outcome:
  - `brew install git-filter-repo` runs, with its line in `bluefin/Brewfile`.
  - `bluefin/bootstrap.sh` clones initiatives and runs the drafter and approval-queue install steps.
  - `check-drift` warns when the clone is missing, checks behind-ness with `git ls-remote` under a short timeout, and reports an unreachable remote as its own non-failing line.
- Files: `bluefin/Brewfile`, `bluefin/bootstrap.sh`, `bin/.local/bin/check-drift`, a new `tests/check-drift-initiatives.test.sh`, `scripts/check.sh` (one leg).
- Acceptance: `brew list --versions git-filter-repo` prints `git-filter-repo 2.47.0` or later, `grep -x 'brew "git-filter-repo"' bluefin/Brewfile` matches, and `bash -n bluefin/bootstrap.sh` passes. The filter-repo `--version` flag prints a script hash, not a version.
- Test: fixtures for a missing clone, a behind clone, and an unreachable remote (a `file://` path that doesn't exist), each with its expected line and exit 0.

**Pair, run after W4.**

**W2. SessionStart initiatives lines (65, runner).**

- Outcome: `claude/.claude/gather-dotfiles.sh` prints the `active` and `proposed` records whose `repos` include the session's repo, as the design specifies. The repo name comes from the `origin` basename through `--git-common-dir`. The script reads YAML with `yq`, prints the two failure lines, prints nothing on no match, and always exits 0. `INITIATIVES_DIR` overrides `~/Projects/initiatives` for tests.
- Files: `claude/.claude/gather-dotfiles.sh`, `tests/gather-dotfiles-initiatives.test.sh`, `tests/fixtures/initiatives/`, `scripts/check.sh` (one leg).
- Acceptance: each state prints its expected text and exits 0, and a worktree of a fixture repo prints its parent's records.
- Test: one case per state: match, no clone, unreadable record, no match, worktree, a checkout named `.dotfiles` whose origin is `workstation`, and `yq` missing from `PATH`.

**W3. Skills and rule text (110, runner).**

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
- Acceptance: `git grep -n ROADMAP -- claude/.claude/skills .claude/skills bin` finds only hits that name cairn-cms's ROADMAP or a history file. Each file in the design's named set (`log-issue`, `log-project`, `cairn-pass`, `site-pass`, `cairn-release`, `dependency-upgrade`, `pass-core`, `claude-infra`, `cairn-figure`, `dotfiles-pass`, `claude-memory-write-check`, and `claude/.claude/CLAUDE.md`) is checked by name. `CLAUDE.md` is at or under 200 lines. `log-project` names `initiative.yaml`, and `pass-core` names `Initiative:`.
- Test: `scripts/check-claude-refs.py` passes. The existing `claude-memory-write-check` test gains a case for a memory write naming ROADMAP, and the grep leg gets a fixture skill with a planted non-cairn ROADMAP reference, which must fail.

**W5. Workstation ROADMAP (35, ordinary).**

- Outcome: the session applies Geoff's workstation decision. `defer` rows go to `BACKLOG.md` with `#initiative:<id>` tags, and `ROADMAP.md` is deleted.
- Files: `BACKLOG.md`, `ROADMAP.md` (deleted).
- Acceptance: the `defer` count equals the `BACKLOG.md` lines with `#initiative:` added in the branch diff. The `now` count equals the record ids present on initiatives `origin/main`, the `drop` count is the remainder, and `test ! -e ROADMAP.md` succeeds.
- Test: `roadmap-count` from I7 against the deleted file's last committed version.

**W6. Approval-queue code leaves workstation (30, runner).** This task waits on the dry-run approval and A1's `verify.txt`.

- Outcome: it removes `approval-queue/`, the command, the reminder script, their tests, and their legs. The hook's `settings.json` entry stays.
- Files: those paths and `scripts/check.sh`.
- Acceptance: the gate passes with no leg naming a removed path, and `git ls-files` lists none of the removed paths.
- Test: the gate.

**W8. Retired secrets and live ties (90, auth-data, test-first).**

- Outcome: this task waits on the dry-run approval and on R1's `cloudflare` stage.
  - `scripts/secrets/secret-set.sh` gains four overrides, each an environment variable defaulting to today's value: the store path (`VALUES`), `LOCAL_SECRETS`, the recipient (`RECIP`), and the identity cache (`CACHE`). The script hard-codes all four, and `--delete` always rewrites `LOCAL_SECRETS`. That change is its own commit, with its test first.
  - Just before the store commit, the session merges `origin/main` into the worktree and requires `git diff <merge-base> origin/main -- secrets/` to be empty.
  - Then one commit, with the subject `W8 retire secrets from the store` and pushed at once, removes each retired secret in the manifest from the worktree's `values.age` (`secret-set.sh NAME --delete`, with `VALUES` on the worktree store and `LOCAL_SECRETS` on a temp path) and from `secrets/registry.md`. The live `~/.local/secrets` is regenerated only by C6's `--sync` after the merge. The same commit removes every manifest line the manifest lists, such as the `bash/.bashrc`, `bluefin/bootstrap.sh`, and `SECOND-WORKSTATION.md` lines.
  - It refuses any name whose registry "Used by" names a non-target, any name in `sync.sh`'s `WORKER_SECRETS`, and `CLOUDFLARE_API_TOKEN`, `CF_ZT_TOKEN`, and the GitHub App keys, and stops for Geoff on a hit.
  - `diff-reviewer` reads each commit at task scope, and `RUN_GATE_IF_BUSY` is never set.
  - If the age key's tmpfs cache is gone and 1Password must unlock, the session notifies Geoff and waits.
- Files: `scripts/secrets/secret-set.sh`, `tests/secret-set-overrides.test.sh`, `secrets/values.age`, `secrets/registry.md`, and each file a manifest line names.
- Acceptance: no retired name appears in `registry.md` or in the decrypted store's name list (checked by name only), and every remaining registry row has a store entry. The sha256 of `~/.dotfiles/secrets/values.age`, read by path, equals its value at task start and `git show origin/main:secrets/values.age | sha256sum` run in the worktree. `git grep -nw` for each retired name over `bluefin/`, `bash/`, `bin/`, `scripts/`, and `claude/` returns only history-file hits, and the PR body records a reason for each.
- Test, written first: the override test and Review Focus 2.

**W7. Workstation docs, references, and the draft check (75, runner).**

- Outcome: this task waits on the merges of initiatives PR 1, dubplate, poplar, approval-queue, and every other main-set repo the map's per-repo counts name as a receiver, and on a pull, so the final map and tool are on `main`.
  - It deletes each moved docs entry in the map, except rows marked `deferred:<pass>`.
  - It runs `refs apply` over the worktree, edits `live-tie` hits by hand, and adds a backlog item per `deferred:<pass>` row other than `deferred:p5`.
  - It regenerates only the goldens whose embedded path the map changes.
  - It runs the draft check per row from that row's `pin`. Every destination path exists on its repo's `origin/main`, seen through `gh api`. For a row not in a `collision-*` state, the destination blob equals the source blob at the pin. `git diff <pin> origin/main` over the row's moved path is empty. A docs-row hit is re-copied by its destination's session, and a code-row hit stops for a cherry-pick into approval-queue.
- Files: `docs/**` deletions, files `refs` rewrites, `BACKLOG.md`.
- Acceptance: the draft check passes with its checked-row count equal to the map's moved-row count, `refs check` finds nothing new against the baseline, and the PR leaves draft only after the check passes.
- Test: the draft check's fixtures for an edited moved file, a missing destination, and an edited code row. Each must fail.

Close for W (50): run the gate, `gitleaks git` over the branch history, the name check, `claude-tooling-sync verify`, and the whole-branch review with the dotfiles checklist globs. The PR body carries `## Before merge`.

### approval-queue-repo-organization

**A1. The queue's own repo (95, runner).** This task waits on the dry-run approval and W4's `git-filter-repo`.

- Outcome: the session runs I6's `extract` tool from a fixed copy, on a fresh `git clone --revision=<sha>` of `glw907/workstation`, into `extracts/approval-queue/`, with the pin in its `verify.txt`. It merges the verified extract into its branch as unrelated history, keeping `bin/.local/bin/approval-queue` and `approval-queue/` at the root, then runs the setup.
  - It receives every map row whose `new_repo` is approval-queue, in one commit naming the pinned commit, and prints the count (0 is allowed).
  - The brief-register test reads `REGISTER`, defaulting to `~/.claude/docs/voice/approval-brief.md`.
  - `scripts/gate.sh` runs the app's checks and the two shell tests.
  - The install step links both commands into `~/.local/bin`.
  - A committed fixture brief, `tests/fixtures/e2e-brief.md`, serves end-to-end check 3, and the README covers install and the gate.
- Files: the extract's paths, `scripts/gate.sh`, `scripts/install.sh`, `tests/approval-queue.test.sh`, `tests/fixtures/e2e-brief.md`, `README.md`.
- Acceptance: `verify.txt` ends `verified`, and `git log --follow` on `approval-queue/src/lib/brief.ts` reaches a `review-desk`-era commit. The gate passes, and an install against a temp `HOME` sets both `realpath`s under the checkout.
- Test: the install test, and the existing tests under the new paths.

Close for A (30): `refs apply` after PR 1 merges, the gate, the name check, and the review with `ts-conventions`.

### Sweep executors, one per repo (each launched after initiatives PR 1 merges and is pulled)

Each S task applies its repo's triage decision.

- Outcome:
  - It receives every map row whose `new_repo` is this repo, from the scratch clone at the row's pin, in one commit naming the pin, and prints the count (0 is allowed).
  - `defer` rows go to `BACKLOG.md`, created if absent, with `#initiative:<id>` tags, and `ROADMAP.md` is deleted.
  - `#project:<slug>` tags become `#initiative:<id>` or go, by the entry's disposition.
  - `.claude/project-tracking.json` drops its ROADMAP path.
  - The session runs `refs apply` over its worktree and edits `live-tie` hits by hand.
  - It runs its gate and the name check, and opens the PR.
- Acceptance: the received rows' `new_path`s exist, and their count equals the map's count for the repo. The `defer`, `now`, and `drop` counts are measured as W5's are, `git grep -c '#project:'` is 0, and `test ! -e ROADMAP.md` succeeds (cairn-cms excepted). `refs check` over the worktree finds nothing new against the baseline.
- Test: the gate, plus `roadmap-count` against the deleted file.

Class is `ordinary`, unless a rewrite lands in `.github/workflows/**`, `scripts/**`, or `scripts/checks/**`, which makes the task `runner`. A sweep PR merges itself (Geoff, 2026-10-14) when three things hold. Its diff touches no `runner` or `auth-data` path under the repo's adapter map. For dubplate, poplar, cairn-themes, and phonebook, which have no adapter, that means no path under `pass-core`'s `runner` definition and no rewrite in a file whose path matches `auth`, `credential`, `secret`, or `token`. Its full-suite home is green. Its whole-branch review accepts with an empty "Found, not done" list, which is the review `pass-core`'s exception requires. The conductor then merges it in merge order, and one batched triage item tells Geoff what merged. Any other sweep PR goes to Geoff for a read.

| Task | Minutes | Repo-specific work |
|---|---|---|
| S-dubplate | 90 | Receives its docs rows. On a `collision-differs` row, applies the map-calls decision. 31 `#project:` tags. Heavy gate. |
| S-poplar | 75 | Receives its docs rows (the adapter work). CI watch. |
| S-cairn-cms | 70 | References only. Its ROADMAP and every reference to it stay. `cairn-pass` fast lane, CI. |
| S-aksailingclub-org | 80 | 21 entries. CI watch. |
| S-ecxc-ski | 65 | Also folds the facts that still hold from `~/Projects/ecxc-ski-agent-memory` (read by path, or from R0's archive if the folder is gone). The PR body lists each of the folder's files with its disposition: folded to a named ecxc-ski file, or obsolete with a reason. It stops if neither source exists. The fold commit's subject is `S-ecxc-ski fold ecxc-ski-agent-memory`, which R3 matches. |
| S-xcathletes-org | 60 | One `#project:` tag. |
| S-907-life | 55 | |
| S-cairn-pub | 50 | |
| S-cairn-themes | 50 | No gate exists. |
| S-phonebook | 45 | No gate exists. |

### The drafter follow-up (launched by C9; G-p5 passes at C0)

**D1. Drafter receives its pieces (125, runner).**

- Outcome: the session runs I6's `extract` tool from a fixed copy, on a fresh `git clone --revision=<sha>` of `glw907/workstation`, into `extracts/drafter/`, with the pin in its `verify.txt`. It merges the verified extract into its branch as unrelated history, and receives the map's drafter rows.
  - Two tests find the agent files through `WORKSTATION_DIR`, defaulting to `~/Projects/workstation`, and fail loudly when it's absent, never skipping.
  - The four legs join `make check`.
  - `make install` creates `~/.claude/workflows` as a directory, then links `docs-page-chain.js` and `cairn-docs-outline` with `ln -sfn`.
  - The goldens the map changes are regenerated, and the README's install section is updated.
- Files: the extract's paths, `Makefile`, the two tests, `README.md`.
- Acceptance: `verify.txt` ends `verified`, and `git log --follow` on `docs-page-chain.js` reaches its first commit. `make check` passes with the four legs, and an install against a temp `HOME` sets both `realpath`s under the checkout.
- Test: the install test with a temp `HOME`, plus Review Focus 1.

Close for D (30): run `refs apply` over the worktree, then the gate on the close head, the name check, and the whole-branch review (`go-conventions` and `ts-conventions` globs).

**I11. Drafter docs into initiatives (30, ordinary).** It copies the `deferred:p5` initiatives rows from the scratch clone at the pin, in one commit naming it, runs `refs apply`, and opens initiatives PR 4. Acceptance: each row's `new_path` exists, and `refs check` finds nothing new. Test: the I4 tool.

**W9. Drafter code and docs leave workstation (35, runner).** After the drafter PR and initiatives PR 4 merge, since its draft check needs every drafter row's destination on `origin/main`, the session removes `docs-page-chain.js`, `cairn-docs-outline`, `scripts/drafter-gate.sh`, the five tests, and their fixtures, along with the four `check.sh` legs. The `cairn-run-gate` test drops its moved path, and `claude-tooling.md` records the workflow's new source repo. It deletes the `deferred:p5` docs rows and runs W7's draft check over the drafter rows. Files: those paths, `scripts/check.sh`, `tests/cairn-run-gate.test.sh`, `claude/.claude/docs/claude-tooling.md`. Acceptance: the gate passes with no leg naming a removed path, and the draft check passes over the drafter rows. Test: the gate and the draft check. Close for W9 (30): the gate, the name check, and the review, with a `## Before merge` that confirms the drafter PR and PR 4 merged.

### initiatives-repo-organization-thinkpad (PR 3)

**T1. The thinkpad leg (115, ordinary, live-account).**

- Outcome: Geoff launches this session on the thinkpad after the follow-up set merges. It is unisolated and makes its own initiatives worktree for its one commit, after excluding `.claude/worktrees/`, and writes its clock file in that worktree's git dir. Its own checkout is exempt from the "no live session" pull rule, since Geoff's first command pulls it. It works in this order:
  0. It clones every `edit` row missing on the thinkpad at its `origin/main`, and the tools report a missing `read` row `absent` under `--host thinkpad-x1`. A fresh clone's baseline is taken from the clone. It checks the dry-run file at `doc_commit` against `doc_sha256` as "Shared interfaces" states, and stops for Geoff on a mismatch.
  1. It records `refs-baseline-thinkpad-x1` against the thinkpad's main checkouts before any pull.
  2. It runs `thinkpad-cleanup` as a dry run against the approved manifest, prints it, then removes only the targets it marks removable.
  3. It records `batched-docs-tool-initiative.md`'s line count and sha256 in its results if the file exists, folds it into the drafter record, deletes it, and removes its index line. If it's absent, it records the file as lost and removes the line.
  4. It checks that `git -C ~/.dotfiles status --porcelain secrets/` is empty, and stops for Geoff if it isn't. It pulls every `edit` row in `scope.tsv` in merge order with `git pull --ff-only`, and reports any repo that can't fast-forward as stale and leaves it alone. Only if `~/.dotfiles`, drafter, and approval-queue all fast-forwarded does it restow, run both install steps, and run `secret-set.sh --sync`. Otherwise it stops for Geoff before the restow.
  5. It runs `refs apply` over the thinkpad's scope memory directories.
  6. It runs `e2e-check --host thinkpad-x1`, and `grep -c batched-docs-tool-initiative` in each `MEMORY.md` must be 0.
- Files: `docs-system/README.md` (the fold; the drafter record became docs-system by the 2026-10-14 record-set ruling) and `repo-organization/research/2026-10-14-thinkpad-checks.md`, which holds the tool's output.
- Acceptance: the tool exits 0, and check 1 is diffed against the thinkpad's own baseline.
- Test: the tool's own tests.

## Path

Here is the longest chain:

| Step | Minutes |
|---|---|
| C0 | 30 |
| I1 | 85 |
| Pair A (I3) | 115 |
| Pair B (I4, I5) | 160 |
| Pair C (I6) | 100 |
| Pair D (I8) | 90 |
| Geoff's ten triage calls and map calls | not counted |
| I9 | 70 |
| I close | 45 |
| Merge PR 1 | 5 |
| Sweeps, three at once, dubplate and poplar first | 215 |
| Merge the sweeps and approval-queue, then the workstation PR | 5 |
| W9 with its close (C6 and C7 run beside it) | 65 |
| Merge the workstation follow-up PR | 5 |
| C9 | 20 |
| T1 | 115 |
| C8 | 25 |
| **Total** | **1,150** |

The figure rests on two assumptions. The sweeps pack into three slots of about 215 minutes: dubplate, aksailingclub-org, and phonebook; poplar, cairn-cms, and ecxc-ski; then xcathletes-org, 907-life, cairn-pub, and cairn-themes. And dubplate, poplar, and approval-queue are W7's only receivers. If I3's counts name another sweep repo as a receiver, W7 and the W close start after that repo merges, and the path can reach about 1,275, still under the ceiling. W9 now sits on the chain: it launches only after the main workstation merge, and C9's install and T1 follow it. Collapsing W9 into the main workstation PR would save about 20 minutes and one read, but it would change the follow-up set's structure in a round no read follows, so the plan keeps it. The chain works because the side branches finish ahead of the steps that need them:

- The retire chain (R0 40, R1 70, W8 90) starts at the dry-run approval, right after I8, and reaches W8's end at 780. The sweeps end at 915.
- A1 (95 plus its 30 close) starts at the same approval and merges before W7 needs it.
- W7 (75) and W close (50) start once dubplate and poplar merge, near 785, and finish at 910, with the last sweep.
- The workstation executor's earlier tasks (W4, the W2 and W3 pair, W5, and W6) finish ahead of W8.
- D1 (155) starts once I6's tool is pushed, near 490, and merges near 650. I11 (30) follows I3's map. Both finish long before W9 needs them.

The task sum is 3,070: the conductor 175, initiatives 1,040 (its close 45 included), retire 205 (close 15), workstation 520 (close 50), queue 125 (close 30), sweeps 640 (each close included), the drafter follow-up 250 (D1 with its close 155, I11 30, W9 with its close 65), and the thinkpad 115. The sum excludes the G-picks PR (#71) and its rebuild, which land before C0.

At 1,150 minutes, the path is 1.37 times the design estimate and under the 1,680 ceiling. The rise from 875 comes from three sources. The old table carried C6 at 30, not its stated 45. It also left out the sweeps that run between PR 1's merge and the workstation merge. The rest is the review folds: the scope harness, the inventory's positive cases, the end-to-end tool, the manifest, and the archive task.

The estimates come from these Score sections:

| PR | Planned path (minutes) | Actual (minutes) |
|---|---|---|
| drafter#30 | 285 | about 70 |
| drafter#31 | 150 | about 10 |
| drafter#16 | 355 | about 30 |
| drafter#6 | 175 | about 35 |
| workstation#61 (its half) | about 180 | about 20 |

drafter#11 recorded no actual. Actuals ran 7 to 25 percent of the planned path. The figures here stay at planning scale anyway, for two reasons: most of this pass is live-account and cross-repo work with no measured precedent, and the clock stop fires at twice a figure, so a figure cut to past actuals would stop on the first API retry or gate queue. Expect the actual well under 1,150.

## Merge order

1. The G-picks PR, workstation#71, and its rebuild (before C0). `glw907/approval-queue` exists (C2). Then initiatives PR 1, then dubplate, then poplar.
2. approval-queue.
3. Initiatives PR 2 (retire), cairn-cms, aksailingclub-org, 907-life, cairn-pub, cairn-themes, ecxc-ski, phonebook, and xcathletes-org, in any order.
4. workstation, last in the main set.
5. On pavilion (C6), then on the thinkpad (T1): pull, restow, then the approval-queue install step, and `make -C ~/Projects/drafter install` once the follow-up has merged. Neither install runs before its workstation merge and the restow, because until then `~/.claude/workflows` is a folded link into `~/.dotfiles` and `~/.local/bin/approval-queue` is a stow link.
6. The follow-up (C9): drafter, then initiatives PR 4, then the workstation follow-up PR, whose session launches only after both.
7. Initiatives PR 3 (thinkpad), after T1.

Before-merge steps known now:

- Initiatives PR 1, `## Before merge`: run `gh repo view glw907/approval-queue`, then `scripts/check --repos` from the PR's worktree under Geoff's `gh` login. The check: both exit 0.
- Workstation PR, `## Before merge`, with three steps:
  1. Confirm the approval-queue PR and every receiver's PR merged and their checkouts are pulled.
  2. Rerun W7's draft check.
  3. Confirm that `git diff <store commit>^ origin/main -- secrets/values.age` is empty. If not, W8 redoes the deletes on the new base.
  - The check: the draft check and the diff both come back empty.
- Workstation follow-up PR, `## Before merge`: confirm the drafter PR merged, then rerun W9's draft check.
- drafter and approval-queue PRs: no before-merge step. Their install waits for step 5.
- Every other PR: none known.

## Geoff's touchpoints

These come in order:

1. Read the G-picks PR, workstation#71 (Geoff, 2026-10-14). workstation#69 has already merged.
2. The ten ROADMAP triage items and the migration-calls item. The design's text implies the migration-calls item ("Geoff's call replaces the state", and three dubplate collisions differ), though the brief's list doesn't name it.
3. The dry-run item, with its by-hand list: revoke the scratch-site token, run `gh auth refresh -s delete_repo` on pavilion, and pick the Decide block confirming the thinkpad's `values.age` is clean.
4. A 1Password unlock at W8, only if the age key's cache has expired.
5. PR reads: the initiatives, workstation, approval-queue, retire, cairn-cms, and other `runner` PRs, then the three follow-up PRs and PR 3. Under the self-merge rule, the `ordinary` sweep PRs come to him as one batched triage item instead (Geoff, 2026-10-14).
6. On the thinkpad, after the follow-up merges, two commands:
   - `gh repo clone glw907/initiatives ~/Projects/initiatives`, or `git -C ~/Projects/initiatives pull` if the clone exists.
   - `cd ~/Projects/initiatives && claude --bg --model sonnet --effort medium --name initiatives-repo-organization-thinkpad --add-dir ~/.local/state --add-dir ~/.dotfiles --add-dir ~/Projects --add-dir ~/.claude/projects -- "$(cat repo-organization/plans/2026-10-14-repo-organization-thinkpad-prompt.txt)"`.

## Review Focus

These are five failure modes the design implies that no task's acceptance test above exercises. Each test is added to the owning task.

1. **The drafter install writes through the folded link.** If `make install` runs while `~/.claude/workflows` is still stow's folded link, `ln -sfn` lands inside `~/.dotfiles/claude/.claude/workflows/` and dirties workstation. Test (D1): with a temp `HOME` whose `.claude/workflows` is a symlink into a fixture "dotfiles" tree, install exits nonzero, and the fixture tree's checksum is the same before and after.
2. **The store edit reaches the live secrets.** `secret-set.sh` hard-codes the store, `~/.local/secrets`, the recipient, and the uid-keyed tmpfs cache. Test (W8): with `HOME` on a temp directory holding a fixture main-checkout store, a generated age key pair, all four overrides on temp paths, and a failing stub `op` first on `PATH`, a `--delete` run leaves the fixture main store byte-identical. The temp `.local/secrets` is rewritten from the override store, and the real `~/.local/secrets` and `/dev/shm` cache keep their mtimes.
3. **Apply mode follows a symlink out of its root.** `~/.claude/skills` resolves into `~/.dotfiles`, and `git ls-files` lists a tracked symlink as one entry, so the live hazards are a tracked symlink to a file and a symlinked memory directory. Test (I4): a fixture root holding a git-tracked symlink to a file outside it that carries a rewritable path, and a memory directory that is a symlink out of the root. After apply, both targets are byte-identical and both appear in the skip list.
4. **A shared resource reads as sole-owner because its binding hides.** A surviving repo may bind the id only under `[env.<name>]`, only in `wrangler.jsonc`, or only in a deploy workflow's `wrangler deploy --name`, and an Access app may cover a surviving hostname. Test (I5): one fixture per hiding place, plus an Access app whose domain list includes one surviving hostname. Each must come out `shared-with`.
5. **An extract that misses a historical path still passes the tip-tree check.** The tip tree matches even when the `review-desk` history is lost. Test (I6): extract a fixture repo with a pure `git mv` rename while listing only the new name; `verify.txt` must report the first-commit mismatch and not end `verified`.

## Later (not built)

- Making `scope.tsv` a standing file the next cross-repo initiative reuses.
- A check-drift leg for a dangling stow link, and a drafter GitHub CI (both refused in the fold, and still not built).
