# Repo organization design: mechanics and feasibility review

Target: `repo-organization/specs/2026-10-14-repo-organization-design.md` at `9da8e85` (cited
below as `design.md:N`). Lens: does every mechanism behave as stated, checked against the live
files, tools, GitHub, and the Cloudflare account (read-only) on pavilion, 2026-10-14.

Counts: 3 blocker, 13 major, 16 minor (32 findings). Ranked by consequence.

## Blockers

### B1. The teardown rule would destroy live and shared Cloudflare resources (blocker, correctness)

Location: `design.md:166`, `design.md:160-162`.

Defect: "The pass moves or tears down each tie before its repo goes, so no deployed resource
outlives its source" assumes one resource has one source repo. The account says otherwise
(read-only `GET /workers/scripts`, `/d1/database`, `/r2/buckets`):

- `aksailingclub-sveltekit` (Delete) binds worker `asc-handbook`, worker `asc-uptime` with KV
  `78e79e69...`, and R2 `asc-event-images`. `aksailingclub-legacy` (Archive, not deleted) binds
  the same three. All three are deployed.
- `aksailingclub-legacy/ops/wrangler.toml` and `aksailingclub-legacy/wrangler.toml` bind D1
  `asc-ops` (`59a1f106-...`). The live `aksailingclub-org/wrangler.toml` binds that same database
  as `EVENTS_DB`. A teardown driven by legacy's ties deletes production data.
- `aksailingclub-sveltekit` also owns `asc-staging` (worker plus D1) and the route
  `staging.aksailingclub.org`. Those are its own and safe to tear down.

The spec also never says whether "archive" triggers teardown.

Fold: the inventory resolves every resource by id across all surviving repos' wrangler configs
(not only the retiring repo's) and marks each one `sole-owner`, `shared-with <repo>`, or
`live-elsewhere`. Only `sole-owner` resources are teardown candidates. State that archiving
`aksailingclub-legacy` tears down nothing. The dry-run item lists the shared resources
separately for Geoff's call.

### B2. cairn-cms's ROADMAP is uncounted, and it is load-bearing (blocker, correctness, OWNER FORK)

Location: `design.md:13`, `design.md:111`, `design.md:115-119`.

Defect: "about 80 entries, 22 of them in workstation" matches every ROADMAP except cairn-cms.
`cairn-cms/ROADMAP.md` is 3,851 lines with about 284 top-level bullets across "Toward 1.0",
"Now", "Next", "Later", and "Considering". It calls itself "a pass dimension". 264 lines under
`cairn-cms/docs` (outside `superpowers/`), plus `CLAUDE.md`, cite `ROADMAP.md`. Its "Toward 1.0"
policy prose is cited by `.github/workflows/publish.yml:66`, `tsgo.yml:4,24`,
`scripts/checks/check-consumers.mjs:23,57`, `reference-coverage.mjs:541`, and the
`cairn-release` skill (lines 155 and 223, "the path to 1.0 and its readiness checklist"). Its
docs-link gate (`scripts/checks/docs-links.mjs:27,63`) filters ROOT_DOCS through `existsSync`,
so deleting the file passes there, but every link to it elsewhere in `docs/` breaks. The 840-minute
estimate and the "one triage item per repo" step can't cover this file at the stated scale. The
spec's reference checker scans only `docs/` paths, so it won't see any of these
links.

**OWNER FORK.** Options:
(a) Triage all of cairn-cms's roughly 284 entries in this pass and re-home "Toward 1.0" (to a
`cairn-1-0` record or `docs/internal/`). The estimate grows substantially.
(b) Retire every ROADMAP except cairn-cms's in this pass, and give cairn-cms's its own follow-on
pass under the `repo-organization` record.
(c) Move cairn-cms's tiers wholesale into `BACKLOG.md`, with Geoff ruling only the entries the
session proposes as records, and move "Toward 1.0" verbatim to `docs/internal/`.
Recommendation: (b). It keeps this pass's estimate honest and isolates the cairn-pass and
cairn-release rewiring. Under any option, add a `ROADMAP.md` reference sweep (a checker like the
`docs/{specs,plans,research}` one) to the pass.

### B3. The moved drafter tests read workstation files that stay, and drafter has no CI (blocker, correctness)

Location: `design.md:150`.

Defect: "five tests, and their fixtures ... The four gate legs leave `workstation`'s
`scripts/check.sh` and join `drafter`'s CI." Probes:

- `tests/docs-page-chain-derivation.test.mjs:13` reads `claude/.claude/agents/cairn-docs-drafter.md`,
  and `:304` reads `claude/.claude/agents/cairn-register-editor.md`. Both stay in workstation
  (`design.md:50`).
- `tests/docs-page-chain-outline.test.mjs:19,21` and `tests/docs-page-chain-handoff.test.mjs:16`
  `require()` `bin/.local/bin/cairn-docs-outline`. That helper is "the filesystem half of the
  docs-page-chain workflow" (its own line 2). The workflow shells out to it at lines 783, 819,
  and 1106. The spec doesn't list it among the moved pieces.
- Every test resolves the workflow as `join(HERE, "..", "claude", ".claude", "workflows", ...)`,
  and `tests/drafter-prompts-parity.sh:16-18` passes repo-relative `claude/.claude/workflows/...`
  and `tests/fixtures/drafter/matrix.json`.
- `~/Projects/drafter` has no `.github/` directory, so there is no CI to join. `make check` is
  `vet lint test` (Go only). Workstation has no CI either: both gates are local.

Fold: move `bin/.local/bin/cairn-docs-outline` with the workflow (it is a drafter piece). State
the destination layout: keep the extracted paths, or `--path-rename` them and rewrite the tests'
path constants. Decide how the two agent-file reads resolve: a `WORKSTATION_DIR` variable
defaulting to `~/Projects/workstation`, plus an `actions/checkout` of the public `glw907/workstation`
in CI, or move those assertions into a workstation-side test. Name the CI work as a deliverable
(a new `.github/workflows/` in drafter, which also needs Node), or add the legs to drafter's
`make check` as a `check-workflow` target so a local gate still runs them.

## Major

### M1. `claude-tooling-sync verify` never checks workflows, so end-to-end check 4 passes vacuously (major, correctness)

Location: `design.md:150`, `design.md:183`.

Defect: `bin/.local/bin/claude-tooling-sync` `verify()` (line 207 on) checks live
settings, MCP servers, vendored skills, plugins, and skill-name collisions. Nothing reads
`~/.claude/workflows/`. `claude-tooling.md:24` records workflows only as a table row. "So
`claude-tooling-sync verify` still tracks it" is false today, and check 4 passes with the workflow
missing.

Fold: either add a workflows leg to `verify` (every expected workflow name resolves to a readable
file whose realpath sits in its recorded source repo), with a fixture test proving it fails on a
missing or dangling link, or replace check 4 with `cmp ~/.claude/workflows/docs-page-chain.js
~/Projects/drafter/<path>` plus a by-name Workflow invocation.

### M2. The stow-folded `~/.claude/workflows` link dangles, and drafter's install link fails or lands in workstation (major, correctness)

Location: `design.md:150`.

Defect: `~/.claude/workflows` is itself a folded stow symlink to
`../.dotfiles/claude/.claude/workflows`, and `docs-page-chain.js` is that directory's only
tracked file. A scratch probe (stow into a temp home, then remove the package dir) confirmed the
following:
(1) After the deletion, the folded link dangles, and `ln -s <drafter>/docs-page-chain.js
~/.claude/workflows/` fails with "No such file or directory".
(2) If the directory survives (untracked leftovers), the new link is written inside the
workstation tree as an untracked file.
(3) `stow -R` removes the dangling folded link.

Fold: the drafter install target runs only after the workstation deletion lands and `stow -R
claude` has run. It then makes `~/.claude/workflows` a real directory before linking, with
`ln -sfn`. The thinkpad script follows the same order. Add a check-drift leg that fails on a
dangling `~/.claude/workflows`.

### M3. `--path approval-queue` drops the app's history before the 2026-10-12 rename, and git-filter-repo isn't installed (major, correctness)

Location: `design.md:148`, `design.md:150-152`.

Defect: The app was `review-desk/`, `bin/.local/bin/review-desk`, `claude-desk-reminder`, and
`tests/review-desk.test.sh` until `27a7a16` (2026-10-12, "Rename review-desk to
approval-queue"). The manual says "renames are NOT followed so you may need to specify multiple
paths, e.g. `--path olddir/ --path newdir/`" (git-filter-repo `Documentation/git-filter-repo.txt`).
Without the old paths, the new repo starts at 2026-10-12 and loses T1 and T2 (2026-10-11).
`git filter-repo` is absent on pavilion (`git: 'filter-repo' is not a git command`) and isn't
in `bluefin/Brewfile` (Homebrew offers `git-filter-repo` 2.47.0). The global rule says every
install records itself in its tier's manifest in the same session. The docs-page-chain paths
show no renames (first add `d09b9ea`), so drafter's extract is fine.

Fold: the plan lists every historical path per extract (approval-queue: the five old names plus
the five new ones; derive the list with `git log --all --name-only` filtered per move). Acceptance:
`git log --follow` on each moved file reaches the commit the source repo shows. Add a task step
to `brew install git-filter-repo` and add a Brewfile line, or use it via `uvx git-filter-repo`
with a `uv-tools.txt` line.

### M4. The approval-queue move: a test reads the workstation register, the CI doesn't exist, and the layout is load-bearing (major, correctness)

Location: `design.md:152`.

Defect:
- `tests/approval-queue.test.sh:209` reads `claude/.claude/docs/voice/approval-brief.md`
  repo-relative, and asserts at least three exemplars. The register stays in workstation
  (`design.md:50`), so the moved test fails from the new repo and in its CI.
- "The app's gate leg moves to the new repo's CI": no CI exists to receive it. In workstation it
  is a local `check.sh` leg (`check.sh:40-57`), and the new repo needs a workflow written.
- `bin/.local/bin/approval-queue:23` finds the app at `realpath(dirname(realpath $0))/../../../approval-queue`.
  It works in the new repo only if the extract keeps `bin/.local/bin/approval-queue` and
  `approval-queue/` at the root. Any `--path-rename` breaks it silently, and the first run then
  `npm ci`s in a nonexistent directory.

Fold: state the new repo's tree (keep the extracted layout, or rewrite line 23 plus its test).
Read the register through a `REGISTER` variable defaulting to `~/.claude/docs/voice/approval-brief.md`
(which `src/lib/brief.ts:8` already names), and check out `glw907/workstation` in CI. Name the CI
workflow as a deliverable.

### M5. A running server on port 7907 makes end-to-end check 3 pass on the old code (major, correctness)

Location: `design.md:182`.

Defect: `approval-queue:70-77` starts a server only when `curl 127.0.0.1:7907` fails. A
`setsid`-detached node from the old `~/.dotfiles/approval-queue/build` keeps serving after the
move. Its files stay on disk too, because `node_modules/` and `build/` are untracked and
survive `git rm`. So "opens an item in Design & PR Approvals" proves nothing about the new
install. The command also blocks until Geoff decides.

Fold: the fixture state for check 3 is "no process on 7907, and `~/.dotfiles/approval-queue/`
absent", asserted by `! curl -sf 127.0.0.1:7907` and `test ! -e`. The check also confirms the
serving process's cwd is under `~/Projects/approval-queue` (`readlink /proc/<pid>/cwd`). Name that
Geoff withdraws or decides the test item. The cleanup removes the untracked leftovers on both
machines.

### M6. Bare `docs/` paths are ambiguous: every repo has its own tree (major, correctness)

Location: `design.md:125`, `design.md:132`, `design.md:136`.

Defect: Twelve repos carry their own `docs/` (cairn-cms 659 files, dubplate 506,
poplar 278, and others: about 1,600 outside workstation). Workstation files cite cairn-cms's tree
by bare path: `docs-page-chain.js:1,122,197,229` and `tests/docs-page-chain-outline.test.mjs:687`
name files that exist only in `cairn-cms/docs/` (verified for three). "A rewrite
script applies the map across every repo" keyed on bare old paths would rewrite such references
wherever a filename collides. A checker "fails on a path that doesn't resolve" needs a stated
resolution base. Separately, `tests/fixtures/ci-green/pr-107-files.txt:100-109` is a captured
PR file list: rewriting it corrupts the fixture. The docs-page-chain goldens embed cairn-cms
paths that the migration doesn't move at all.

Fold: the map and checker resolve a bare path against the containing repo, and a prefixed path
(`~/.dotfiles/`, `~/Projects/<repo>/`, `workstation/`) against that repo. The rewriter edits only
references that resolved to a workstation entry before the move. Exclude captured-data fixtures
by an explicit list. Restate "regenerates the test goldens" as "regenerates only goldens whose
embedded path changed, which the map shows is none of the docs-page-chain goldens".

### M7. Destination collisions in dubplate: three of five already exist with different content (major, correctness)

Location: `design.md:128`, `design.md:134`.

Defect: `cmp` shows workstation `specs/2026-08-30-dubplate-go-rewrite-design.md` and
`specs/2026-08-31-dubplate-uploader-design.md` differ from dubplate's same-named files.
`plans/2026-08-31-dubplate-uploader.md` differs from `dubplate/docs/archive/plans/...`.
`plans/2026-08-30-dubplate-go-rewrite.md` and `research/2026-08-31-beets-plugin-usage.md` are
byte-identical. "Copy and delete" overwrites or duplicates them.

Fold: the classifier adds a `collision` column: `identical` (delete the source, rewrite refs to the
existing file), `differs` (flag for Geoff, default keep the destination and drop or rename the
source as `-workstation-copy`), or `none`. It runs collision detection against the whole
destination tree, `archive/` included.

### M8. The reference-checker baseline is per-machine, but the after-run is on the thinkpad (major, correctness)

Location: `design.md:136`, `design.md:180`.

Defect: The pre-migration run records broken references on pavilion. The thinkpad check compares
against "the pre-migration run" while scanning thinkpad's own `~/.claude` and auto-memory. Those
copies came from the 2026-10-12 bundle and diverged since, and the rewrite (run on pavilion)
never touches them. Check 1 can fail on stale thinkpad memory, or pass because the thinkpad
lacks files pavilion had. "Every repo, `~/.claude`" also takes in `~/.claude/projects/*.jsonl`
transcripts, `history.jsonl`, and `file-history/`, which must never be rewritten.

Fold: the baseline is keyed `(machine, file, path)`. The thinkpad script runs the rewrite over its
own memory directories before check 1, or check 1 scopes to git-tracked files and the memory
check runs per machine. Name the `~/.claude` include list (the stowed dirs plus
`projects/*/memory/*.md`) and exclude transcripts.

### M9. The global CLAUDE.md is at 199 of its 200-line cap (major, correctness)

Location: `design.md:113`.

Defect: `claude-context-budget` sets `CLAUDE_MD_LINE_CAP=200` (line 22), and
`claude/.claude/CLAUDE.md` is 199 lines. The gate runs it (`check.sh:83`). A "short Initiatives
section" of a heading plus two lines fails the gate.

Fold: the task that adds the section moves an equal line count to
`~/.claude/docs/claude-md-archive.md` (the budget's own advice), or folds the placement rule into
an existing section as one line pointing at `initiatives/README.md`.

### M10. The SessionStart hook can't name "the session's repo" as specified (major, correctness)

Location: `design.md:70-79`, `design.md:97-103`, `design.md:113`.

Defect: The hook is `~/.claude/gather-dotfiles.sh` (settings.json:77-85). It ignores stdin and
knows no repo. Hook input carries `cwd`, and `CLAUDE_PROJECT_DIR` is "the project root where the
session started" (code.claude.com/docs/en/hooks). But:
- workstation's checkout basename is `.dotfiles`, not `workstation`;
- a worktree session's top level is `.claude/worktrees/<name>`;
- the YAML has no summary field, though the hook prints "each with its summary line" and
  `design.md:70` says the YAML holds "only the fields that tools read";
- `repos` values include non-repos: "every repo it touches", "the sites", "Google Docs",
  "a new marketplace repo".
The spec names no output for an absent clone, malformed YAML, or zero matches. SessionStart
fires on startup, resume, clear, compact, and fork, and plain stdout counts against a
10,000-character cap. Current output is 552 characters, so the cap has room.

Fold: derive the repo name from `git -C "$cwd" rev-parse --git-common-dir` and the `origin`
remote's basename (falling back to the directory name). Add `summary:` to `initiative.yaml`.
Make `repos` GitHub repo names only, enforced by `scripts/check`, and move surfaces to the
README. Name the states: clone absent, print nothing (check-drift reports it); YAML that fails
to parse, print one `initiatives: unreadable <file>` line; no match, print nothing. Parse with
`yq` (mikefarah v4.54.1, in Brewfile line 15). Python `yaml` isn't installed.

### M11. The merge order covers docs only; the code moves and the thinkpad have no order (major, correctness)

Location: `design.md:138-142`, `design.md:168`, `design.md:178`.

Defect: Workstation's deletion of the workflow, `approval-queue`, the reminder hook, and
`cairn-docs-outline` makes the stow links dangle on any machine that pulls before installing
from the new repos. The live reminder hook (settings.json:128) keeps telling sessions to run
`approval-queue`, which then doesn't exist. The order lists no step for the drafter and
approval-queue PRs, their installs, or `stow -R bin claude`.

Fold: extend the order: (1) new repos and drafter's PR merge; (2) workstation's deletion merges;
(3) per machine: pull, `stow -R bin claude`, run both installs. The thinkpad script runs (3), and
the e2e begins after it.

### M12. The retirement set holds three more local-only directories, and two aren't git repos (major, correctness)

Location: `design.md:37`, `design.md:160`, `design.md:166`.

Defect: Six of the deletions have no remote on pavilion, not three:
- `aksailingclub-sveltekit` is an orphaned worktree. Its `.git` file points at the pruned
  `aksailingclub-legacy/.git/worktrees/aksailingclub-sveltekit` (129 MB, uncommitted by
  construction).
- `cairn-scratch` and `ecxc-ski-agent-memory` aren't git repositories.
- The inventory's "unpushed branches and stashes" step errors on all three (`fatal: not a git
  repository` and `gitdir: ... not a valid repository`), and the spec names no report for that
  state.
- The brief says "nothing can bring them back". `bluefin/SECOND-WORKSTATION.md:77-82` says a
  handoff bundle built on thinkpad-x1 on 2026-10-12 holds all six, so the brief may overstate
  irreversibility.

Fold: the inventory reports a per-directory kind (`git`, `orphaned-worktree`, `plain-dir`) and
treats the last two as "contents unrecoverable once removed". Correct the brief's count. State
whether the bundle (and the thinkpad's copies) stay, which is a fact to record, not a reversal of
the ruling.

### M13. ROADMAP retirement reaches past the three named skills (major, correctness)

Location: `design.md:115-119`.

Defect: These also read or write ROADMAP:
- `log-issue` (`SKILL.md:31,37,55,90,154`). It holds `roadmap_path` and the `#project:slug` tag,
  so "log-issue doesn't change" is wrong.
- 32 `#project:` tags live in `dubplate/BACKLOG.md` (31) and `xcathletes-org/BACKLOG.md` (1).
- `.claude/project-tracking.json` exists in nine repos.
- Skills: `cairn-pass`, `site-pass:36`, `cairn-release`, `dependency-upgrade:70,118`,
  `pass-core:220,227,278,294`, `claude-infra`, `cairn-figure`.
- `bin/.local/bin/claude-memory-write-check:11` and `dubplate/scripts/check.sh:395` (a path
  allowlist, harmless).
- `log-project:39` creates ROADMAP.md when it's absent, which would resurrect the file.

Fold: the plan's file list takes this inventory. `#project:<slug>` maps to `#initiative:<id>`, or is
stripped by the triage disposition. `project-tracking.json` drops `roadmap_path`. Add a gate leg
that fails on a live `ROADMAP.md` reference outside history files.

## Minor

### m1. Workstation and secret ties the inventory must reach (minor, correctness)

Location: `design.md:166`.

Defect: `bluefin/bootstrap.sh:786` restores `aksailingclub-sveltekit cairn-scratch
ecxc-ski-agent-memory`. `SECOND-WORKSTATION.md:79-81,253` lists them and clones `displaywidth`.
`bash/.bashrc:152` matches `~/Projects/hugo-blog-template/*`. `secrets/registry.md:182,249-251,476-480`
carries `PINGS_ADMIN_TOKEN` and the account-owned token "cairn-scratch-b docs readers". The
resource list (Workers, D1, KV, R2, DNS) omits API tokens, Access applications, Email Routing,
Worker routes and custom domains, and cron triggers. Deployed today: `pings`, `cairn-scratch-b`
plus D1 `cairn-scratch-b-auth`, `asc-staging`.

Fold: add those resource kinds, and seed the inventory's reference search with these known hits
as its fixture, so a run that finds none of them fails.

### m2. Fork repos: their PRs live in the parent (minor, correctness)

Location: `design.md:166`.

Defect: `kit` is a fork of `sveltejs/kit` (pushed 2026-10-13). Its PR is
`sveltejs/kit#17368` (merged 2026-10-14), and `displaywidth` is a fork of
`clipperhouse/displaywidth`. "Open PRs and issues" on the fork misses open upstream PRs, and
deleting a fork closes them. poplar depends on upstream `clipperhouse/displaywidth`, not the
fork, so deletion is safe there.

Fold: for `isFork` repos, list `gh pr list -R <parent> --author glw907 --state open`.

### m3. The cairn-run-gate test goes vacuous after the move (minor, correctness)

Location: `design.md:150`.

Defect: `tests/cairn-run-gate.test.sh:448-451` greps `claude/.claude/workflows/docs-page-chain.js`
with `|| true`. Once the file is gone, grep errors to stderr, `hits` is empty, and the assertion
passes.

Fold: drop the path from that test and carry the "no vanished clause" assertion into drafter's
tests.

### m4. `scripts/drafter-gate.sh` and gate.sh's `DRAFTER_BIN` logic have no meaning in drafter (minor, optional)

Location: `design.md:150`.

Defect: `drafter-gate.sh` runs `make -C ~/Projects/drafter check` from workstation through
`cairn-run-gate` (lines 11-12). Moved into drafter, it calls its own repo through a
`DRAFTER_DIR`. `scripts/gate.sh:11-13` forces `--fresh` on `DRAFTER_BIN`, which is dead once
parity leaves.

Fold: replace it with a drafter-local `scripts/gate.sh` (same shape, `make check`), and delete
gate.sh lines 11-13.

### m5. Worktree scale and locked worktrees (minor, correctness)

Location: `design.md:136`, `design.md:172`.

Defect: drafter holds 22 worktrees (19 agent branches merged by ancestry, 2 unmerged, and
`p5-pipeline` locked). A locked worktree needs `git worktree remove --force --force`.
`git branch --merged` misreads squash merges. The rewrite "skips stale worktrees", but the
checker's scope over unremoved worktrees is unstated.

Fold: define "merged" as "the branch tip is an ancestor of the default branch, or its PR is
merged" (`gh pr list --head`). Locked worktrees go to the dry run. Both the rewriter and the
checker exclude `.claude/worktrees/`.

### m6. Archive order for `aksailingclub-legacy`, and triage items for retiring repos (minor, optional, over-ceremony)

Location: `design.md:111`, `design.md:162`.

Defect: An archived repo is read-only, so legacy's ROADMAP PR must merge before
`gh repo archive`. The plan also spends a triage item each on `healthy-diet` (deleted) and
`aksailingclub-legacy` (archived): one entry and a dozen lines, about two approval round trips
of Geoff's time plus a session drafting dispositions.

Fold: skip ROADMAP triage for repos in the retirement set. Any entry worth keeping goes to the
dry-run item as one line.

### m7. check-drift's "behind its remote" needs a network fetch (minor, correctness)

Location: `design.md:121`.

Defect: check-drift has no `fetch` or `ls-remote` today, so it runs offline. "Behind" needs
`git fetch` or `git ls-remote`, and offline it would false-warn or hang.

Fold: use `git ls-remote --exit-code origin HEAD` with a short timeout, and report "remote
unreachable" as its own non-failing line.

### m8. The memory fold has a thinkpad copy and an index line (minor, correctness)

Location: `design.md:121`.

Defect: deleting `batched-docs-tool-initiative.md` leaves its `MEMORY.md` index line, and the
thinkpad's copy (from the bundle) survives.

Fold: remove the index line in the same step, and add both to the thinkpad cleanup script.

### m9. The `delete_repo` scope stays on the token (minor, optional)

Location: `design.md:24`.

Defect: The scope is granted and never removed. `gh auth refresh` supports `-r,
--remove-scopes` (`gh auth refresh --help`). `gh repo delete` needs `owner/repo --yes` to run
non-interactively (`gh repo delete --help`).

Fold: after the deletions, run `gh auth refresh -r delete_repo`. This is one more Geoff
touchpoint, so it can ride with the first.

### m10. The new repo's visibility is unstated (minor, optional, OWNER FORK)

Location: `design.md:152`.

**OWNER FORK.** `glw907/approval-queue` could be public (matches workstation, where the code is
public now) or private. Recommendation: public, since the history is already public in
workstation.

### m11. Teardown of D1 and R2 is data destruction, but the class is `runner` (minor, correctness, OWNER FORK)

Location: `design.md:53`.

Defect: `runner` plus `live-account` fits the skills, settings, and repo deletions. The teardown
tasks delete databases (`asc-staging`, `cairn-scratch-b-auth`) and buckets, which is
`auth-data`'s territory. pass-core says "Only Geoff's ruling raises a class".

**OWNER FORK.** (a) Keep `runner`; the dry-run confirmation is the guard. (b) Raise the
teardown task to `auth-data`, adding its read. Recommendation: (a), if B1's sole-owner rule
lands, since every destroyed resource is then listed by id in a Geoff-confirmed item.

### m12. Extracted commit messages autolink `#NN` to the wrong repo (minor, optional)

Location: `design.md:148`.

Defect: Workstation commit subjects carrying `(#NN)` link to the destination repo's PRs and
issues after the extract.

Fold: run filter-repo's message replacement to rewrite `#NN` to `glw907/workstation#NN`. Check
the option name against the manual before relying on it.

### m13. "About 41 distinct paths" isn't reproducible (minor, optional)

Location: `design.md:125`.

Defect: A grep for workstation-prefixed `docs/` paths in other repos finds 15
distinct paths. Bare-path references can't be counted without M6's resolution rule.

Fold: drop the figure and let the checker's pre-run report the count.

### m14. `scripts/check` has no named states (minor, correctness)

Location: `design.md:63`, `design.md:70`, `design.md:89`.

Defect: The check names one failure (index against the YAML). The spec names no report for a
missing `initiative.yaml`, malformed YAML, `id` not equal to the directory name, an unknown
`status`, a duplicate `id`, or a `repos` entry that isn't a glw907 repo. Its proof also needs a
fixture with at least one bad record, so it can't pass vacuously.

Fold: list each state with its message, and add one bad fixture per state.

### m15. The new initiatives repo can't take its first content by PR (minor, optional)

Location: `design.md:140`.

Defect: "The initiatives repo merges" first, but a new empty repo has no base branch for a PR.

Fold: push the skeleton commit directly, and PR the records on top.

### m16. The design runs past pass-core's "a page or less" (minor, optional, over-ceremony)

Location: `design.md:1-183`.

Defect: pass-core step 1 asks for "a design of a page or less". This one is 183 lines. It's
approved, so the cost is sunk. The plan should not re-narrate it.

Fold: the plan cites design sections by heading instead of restating them.

## Probe notes

- Workstation's checked-out branch changed during this review (`roadmap-decide-bug`, then
  `main`), and worktree `top-bar-tidy` is live. Another session is active in `~/.dotfiles`, and
  the one-executor checks (`design.md:144`) apply at dispatch.
- Verified as stated: the docs/{specs,plans,research} entry counts (25, 60, 88; 281 tracked files), the
  four gate legs (`check.sh:71-74`), the hook command called by name (`settings.json:128`), and
  the `gh` scopes (`repo` present, `delete_repo` absent).
