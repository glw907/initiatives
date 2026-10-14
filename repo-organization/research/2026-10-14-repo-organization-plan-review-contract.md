# Repo organization plan review: contract and criteria

Target: `repo-organization/plans/2026-10-14-repo-organization-plan.md` and its 17 launch prompts, at
commit `f2362ab`. Spec: `specs/2026-10-14-repo-organization-design.md`. Lens: is every acceptance
check testable, does it name its fixture and why it would fail, can it pass vacuously, does every
spec outcome map to a proving task, does the scope-list exclusion hold for every repo-wide tool, and
do the Review Focus tests pin what they claim.

Counts: 1 blocker, 25 major, 22 minor (one of them tagged `optional`), and 4 over-ceremony findings
tagged `optional`. Three owner forks sit inside those findings: B1, M2, and O1.

Probes run (all read-only): `gh repo list glw907` (names only), a listing of `~/Projects` (names
only), `gitleaks git` over this repo (clean), the `approval-queue` command and its `items.ts` and
`brief.ts` code, `scripts/secrets/secret-set.sh`, the `ebb4877` ROADMAP entry, and a `git grep` of
workstation's live files for the retirement targets' names. One glw907 repo sits outside the scope
list, both on GitHub and in `~/Projects`, and it has a memory directory under `~/.claude/projects/`
holding one file. This record never names it.

## Blocker

**B1. correctness. Plan 162, 236, 247-248, 54; conductor prompt 28.** Two design items carry
`### Decide:` blocks: the migration calls (one per `flagged` and `collision-differs` row) and the
dry run's worktree calls. Geoff's picks reach executors only through `decision.json`. Workstation's
own ROADMAP (`ebb4877`, logged today) records that approving a design item drops its Decide picks:
the repo organization design came back as `{"decision":"approve"}` with no `choices`. So I9 will read
an approve with no calls. It then either stalls or, worse, applies each block's recommended choice
("Keep the destination") as if Geoff chose it. C5 would act on worktree calls nobody made. No
acceptance anywhere checks that a decision carries one choice per Decide block.
Fold: add to I9's and C5's acceptance that `decision.json`'s `choices` length equals the doc's
Decide-block count and that each `title` matches a block, and say to stop for Geoff otherwise.
**OWNER FORK** on the route:
(a) fix the dropped-picks bug in a small workstation PR before C2 sends any design item
(recommended: the bug is logged, the app moves out of workstation in this pass, and both design
items depend on it);
(b) carry each call as a triage row instead, with `now` read as "apply the recommendation" and
`drop` read as "the other choice", which bends the triage vocabulary further;
(c) have Geoff type his picks in a reject note, which makes the decision free text again.

## Major

**M1. correctness. Plan 52, 167, 196, 206, 232.** The mode-000 fixture doesn't prove "never read".
It catches only a tool that opens the directory and lets the error surface. Three of the commonest
violations pass it cleanly:
- A bash glob such as `for d in ~/Projects/*; do [ -d "$d/.git" ] ...` lists the name from the
  parent's readdir, and the `-d` test on a child of a mode-000 directory returns false with no
  error.
- Python's `os.walk` ignores permission errors by default (`onerror=None`), and `find ... 2>/dev/null`
  hides them.
- Run as root (a CI container job), mode 000 doesn't block the read at all.

The test also exercises nothing unless the tool's scan root is the fixture root. A tool that globs
the real `~/Projects` reads the real outside repo while its test, run against fixture scope paths,
passes. The plan's actual risk is the name leaking into committed output, and mode 000 leaves the
name readable in the parent listing.
Fold: replace the mode-000 fixture with a canary fixture. The outside fixture is readable, has a
`.git`, and carries a unique canary token in its directory name and contents. Each tool takes a
`PROJECTS_ROOT` (or a `HOME`) override pointed at the fixture root. The test asserts that the canary
appears in no stdout, stderr, or file the tool writes. Add a positive control: an in-scope canary
must appear. Where `strace` is available, also assert that no `openat` or `stat` path contains the
canary directory. Write it once as a shared harness that every scope-reading tool's test calls (see
O4).

**M2. correctness. Plan 188, 201-203, 225; design step 1, step 6.** Three named inputs cross the
scope list by construction, so the exclusion is false as planned, whatever the fixture:
- I4's memory scope `~/.claude/projects/*/memory/*.md` globs every project's memory, including the
  outside repo's directory, which holds one file today. `refs apply` may rewrite it, and the
  baseline and T1's committed `thinkpad-checks.md` can carry its path.
- I5's step 1 "finds references from ... `~/.claude`", and its account-wide Worker read returns
  every deployed Worker by script name. A `shared-with` result for an outside Worker would put that
  name in the dry-run brief, which is committed.
- I6's `thinkpad-cleanup` "prints its dry run with the remote-less directories it finds". Finding
  directories not already listed means scanning `~/Projects`.

Fold: derive the memory directories from `scope.tsv` paths (the `-var-home-glw907-Projects-<repo>`
encoding plus the `.dotfiles` one), never a `*` glob. Have I5 report an outside binder as
`shared-with account-worker` without its name. Restrict `thinkpad-cleanup` to `retire` rows.
**OWNER FORK** for the last: (a) retire rows only (recommended: it matches the rule, and the design
lists all six remote-less targets already); (b) keep a names-only discovery scan whose output stays
on the machine and is never committed.

**M3. correctness. Plan 52; every prompt's "commit nothing that names a repo outside".** "No
committed file names a repo outside the list" has no check. No gate leg, close step, or acceptance
greps for it, and C0 publishes the repo before `scope.tsv` exists. Today's history is clean: this
review grepped every commit, and `gitleaks` is clean.
Fold: add a close-step check to every PR. It computes the outside names in memory (`gh repo list
glw907` names, plus `~/Projects` entry names, minus `scope.tsv`), then runs
`git diff origin/main...HEAD | grep -wF -f -`, which must be empty. Add the same check before C0's
`--push`, along with `gitleaks git`.

**M4. correctness. Plan 52, 158, 164.** `scope.tsv` is the sole input of every repo-wide tool, and
no acceptance pins its contents. A row left out makes every tool skip that repo, and every check
over the list passes for it. Separately, no tool says what happens when a row's `path` is missing
(a repo not yet cloned on the thinkpad, or `approval-queue` before C2). A tool that silently skips
the row makes check 1 vacuous for it.
Fold: in I3's acceptance, pin the exact row set from the design: 14 `edit` rows (initiatives,
workstation, drafter, approval-queue, and the ten sweep repos), 1 `read` row
(`aksailingclub-legacy`), and 11 `retire` rows, by name. Add one shared rule and test: an `edit` or
`read` row whose path is missing exits nonzero, naming the row, while a missing `retire` path is
reported as `absent`.

**M5. correctness. Plan 203-207, 512.** The one rule that destroys data, `sole-owner`, has only
negative tests: the `asc-*` resources come out `shared-with`, plus Review Focus 4. A tool that marks
everything shared passes I5, and so does one that marks everything sole-owner except the fixture's
three names. The account read can also pass on nothing. A token without the Workers-read scope, or
a wrong account id, can return 200 with an empty list. The design guards against exactly this ("an
empty answer never reads as no ties"), but "exits nonzero on any API or auth error" doesn't catch a
successful empty answer.
Fold: add three cases. A fixture resource bound only by the target must come out `sole-owner`. A
stubbed account Worker outside the targets that binds a fixture id must make it not `sole-owner`. A
stubbed 200 with an empty Worker list must exit nonzero, because the live account always holds the
`pings` Worker, so the tool asserts that the account list contains at least one known deployed
Worker.

**M6. correctness. Plan 265, 271; design checks 5 and 6.** The post-queries prove absence without a
positive control:
- R1's "a query for each id resolves none" passes when every query fails for any reason: a wrong
  account, an expired token, a wrong endpoint per kind, or a network drop.
- R2's "`gh repo view` fails for each deleted repo" passes when `gh` is logged out or offline.
- End-to-end check 5 inherits both on two machines.

Fold:
- R1 runs the same per-kind query before the teardown, and it must resolve every id. Afterwards,
  each id must return the API's not-found code, never just "not 200".
- R2 checks for the exact `Could not resolve to a Repository` error (or `gh api repos/glw907/<r>`
  returning 404), alongside a same-run positive (`gh repo view glw907/initiatives` succeeds).
- Name the by-hand token (`CAIRN_SCRATCH_CF_TOKEN`) as excluded from R1's query, since the pass's
  token may not be able to read it, and check it separately or record it as owed.

**M7. correctness. Plan 57; conductor prompt 22.** G-p5's "`claude agents --json` lists no row whose
`name` starts with `drafter-`" passes when the command errors, prints `[]`, or names the field
differently. This gate keeps the pass from racing live drafter pass 5 sessions.
Fold: require a positive control in the same output. The conductor's own row,
`conductor-initiatives`, must appear under the same field, and a nonzero exit fails the gate.

**M8. correctness. Plan 189, 390, 253; sweep prompts line 7.** `refs check` diffs a baseline that C1
recorded against pavilion's main checkouts (`~/Projects/<repo>/...`). Every S, D, A, and I9 check
runs over a pass worktree (`<repo>/.claude/worktrees/repo-organization/...`). The key is "machine,
file, and path", and "file" isn't normalized. With absolute keys, every baseline hit reads as new
(false red). With keys too loose, a new break can hide.
Fold: specify the key as (host, repo name, repo-relative file, referenced path). Add a test: a
baseline recorded on a fixture main checkout, then a check over a worktree of the same repo, reports
nothing new, and a break planted only in the worktree reports exactly one.

**M9. correctness. Plan 380, 390, 253, 474-477.** S tasks launch once PR 1 merges, and they run
`refs check` as acceptance. drafter and approval-queue merge later (merge order step 2), and S
sessions run beside them. A rewritten reference to a literal `~/Projects/drafter/...` path doesn't
resolve on disk until D1 merges and is pulled. So the check reads the wrong state: it fails, or it
passes only by timing.
Fold: have check mode resolve a rewritten path against its map row's destination (`new_repo` and
`new_path`) on that repo's `origin/main` through `gh api`, or against the map itself for an unmerged
destination. Add a test where the destination exists only in the map.

**M10. correctness. Plan 401, 114-121.** S-ecxc-ski folds facts "from `~/Projects/ecxc-ski-agent-memory`
(read by path)". C5 deletes that directory after R2. S launches only after PR 1 merges, which waits
on ten triage decisions and Geoff's PR read, while R2 can run earlier. The deletion can come first.
The tar holds a copy, but the S prompt reads by path. The fold also has no acceptance.
Fold: make C5 wait until the S-ecxc-ski fold commit is pushed, or carve the fold out as a small task
before C5. Give it acceptance: a list of the folder's files, each with a disposition (folded to a
named ecxc-ski file, or obsolete, with a reason), committed in the PR body.

**M11. correctness. Plan 236, 329; `bluefin/bootstrap.sh:786`, `bluefin/SECOND-WORKSTATION.md:79-81,
253`.** The dry run lists "every manifest line to remove", but only W8 removes any, and only
`bash/.bashrc` lines. `bootstrap.sh:786` loops over `aksailingclub-sveltekit cairn-scratch
ecxc-ski-agent-memory`, and `SECOND-WORKSTATION.md:253` has a clone list naming `displaywidth`.
These are bare names, not `~/Projects/<repo>/` paths, so `refs` won't match them, and W7's hand
edits cover only `live-tie` hits.
Fold: give W8 (or W7) the removal of every manifest line the approved dry run lists. Acceptance:
`git grep -nw` for each retired name over `bluefin/`, `bash/`, `bin/`, `scripts/`, and `claude/`
returns only history-file hits (`docs/superpowers/`, `HISTORY.md`). Each surviving hit gets a
recorded reason in the PR body.

**M12. correctness. Plan 380-398, 249; design "Migration of past work".** The plan names only
dubplate and poplar as docs receivers (S-dubplate, S-poplar), and only initiatives through I9. The
design names "the uploader" and "the music VPS" too, and the classifier routes by rule, so its map
may send rows to cairn-cms, drafter, a site, or approval-queue. No other S, D1, or A1 task copies
docs rows. Such a row would surface only at W7's draft check, as a missing destination with no
owner.
Fold: make "receive every map row whose `new_repo` is this repo, in one commit naming the pinned
commit" a step of every S, D, and A task. Acceptance: every such row's `new_path` exists in the
worktree, and the count equals the map's count for the repo (0 is allowed, and it's printed). Have
I3's acceptance print the per-repo row counts, so the conductor sees any receiver beyond the two.

**M13. correctness. Plan 333, 240; plan 25.** Two checks are assigned to isolated sessions whose
guard refuses git aimed outside their worktree:
- W8's acceptance runs `git -C ~/.dotfiles status --porcelain secrets/` from the workstation
  executor's worktree.
- I8's pre-check that "`values.age` is clean and at `origin/main` on pavilion" runs in the
  initiatives executor's worktree.

Both are unrunnable as written, so they'll be skipped or rephrased at run time.
Fold: for W8, compare `sha256sum ~/.dotfiles/secrets/values.age` with `git show
origin/main:secrets/values.age | sha256sum` run inside the worktree. That needs no git outside it.
Move I8's pavilion fact check to the conductor, which writes it to the state directory, and have I8
read the result file. Read workstation#69 through `gh pr view`.

**M14. correctness. Plan 328, 334, 510; `secret-set.sh:33-36`.** Review Focus 2's test can't be
hermetic with only a store-path override. `secret-set.sh` also hard-codes three more paths:
- `RECIP` (line 33), so "a temporary recipient" isn't possible.
- `CACHE=/dev/shm/.age-key-$(id -u)` (line 36), which is keyed by uid, not `HOME`. The test would
  read the real cached age key, or call 1Password through `ensure_key` when the cache is cold.
- `LOCAL_SECRETS=$HOME/.local/secrets` (line 35), which the test rewrites unless `HOME` is a temp
  directory.

And the "fixture main checkout" store is exercised only if it sits at the default
`$HOME/.dotfiles/secrets/values.age`. That again requires a temp `HOME`, or the default branch the
test claims to guard is never taken.
Fold: name the overrides W8 adds (store path, recipient, and identity cache, each defaulting to
today's value). The test sets `HOME` to a temp directory holding the fixture main-checkout store,
uses a generated age key pair, puts a failing stub `op` on `PATH` so any 1Password call fails the
test, and asserts three things: the fixture main store is byte-identical, the temp
`.local/secrets` was rewritten from the override store, and the real `/dev/shm` cache was never
opened.

**M15. correctness. Plan 511, 187.** Review Focus 3's fixture is "a root containing a symlink to a
directory outside it". The tool's scope is git-tracked files, and `git ls-files` lists a tracked
symlink as one entry. It never descends into it. So a tool with no `realpath` guard at all passes.
The live hazards are a tracked symlink to a file (opening it follows the link) and a symlinked
memory directory.
Fold: make the fixture a git-tracked symlink to a file outside the root that holds a rewritable
path, plus a memory-glob directory that is a symlink out of the root. Assert that both targets are
byte-identical after apply and that both appear in the skip list.

**M16. correctness. Plan 226, 513; design "Code leaving workstation".** Review Focus 5 pins the lost
`review-desk` history only if `verify.txt` computes each moved file's first `workstation` commit
with `git log --follow` (rename-following). Without `--follow`, the first commit of the new path is
the rename commit, which filter-repo keeps when only the new name is listed. Its commit-map entry
is then non-null, and the check reads `verified` on exactly the extract it exists to catch.
Fold: state `--follow --diff-filter=A` (or equivalent) for the source side. Make the fixture's
rename a pure `git mv` so rename detection fires, and add a fixture assertion that the source-side
first commit predates the rename.

**M17. correctness. Plan 224, 229-232; design "Worktrees and descriptions".** Every worktree-rule
case is negative: branch equals base, locked, dirty. A tool that marks nothing removable passes.
Three of the design's five rules have no case at all: clean under `git status` but dirty under
`--ignored` (the design's stated subtlety), in use by a process (`pgrep -f`), and touched within a
day.
Fold: add a positive fixture (merged, clean under `--ignored`, unlocked, no process, mtime set back
two days with `touch -d`) that must come out removable. Add one negative per missing rule: an
ignored file only, a `sleep` process holding the path, and a fresh mtime.

**M18. correctness. Plan 191-196.** I4's "a second apply run changes nothing" passes vacuously when
the first run changes nothing. Several stated behaviors have no case: the `live-tie` class, every
exclusion (`.claude/worktrees/`, lockfiles, `_salvage/`, the named fixture list), tar-before-write
for memory files, and "edits only references that resolved to a moved entry before the move".
Fold: the idempotence case asserts that the first run rewrote at least one fixture file and the
second rewrote none. Add one case each:
- a live-file reference to a retired target comes out `live-tie`, and check exits nonzero;
- a planted rewritable path under each excluded location is untouched;
- the memory tar exists before the first write and holds the pre-edit bytes;
- a reference that was already broken before the move isn't rewritten.

**M19. correctness. Plan 250, 253.** "The count of new records equals the count of `now` rows" is
the wrong equation:
- Two repos' ROADMAPs can name the same cross-repo effort, so two `now` rows map to one record.
- A `now` row can map to an existing record, such as `drafter` or `cairn-docs-standard`.
- A row Geoff moves from `defer` to `now` has no `detail` naming a record id. `SubmittedRow`
  carries `action`, `disposition`, and `note`, with no `detail`.

So the check fails on a correct apply, or pushes the executor to mint duplicate records.
Fold: acceptance becomes "every `now` row's record id exists after I9, and the set of new record ids
equals the distinct proposed ids not already present". A `now` row with no `detail` id stops for a
call, or takes an id derived from its entry and lists it in the PR body.

**M20. correctness. Plan 307.** W3's "a grep over the changed files finds no `ROADMAP`" lets the
executor pick the file set. A consumer it forgot is not a changed file, so the grep passes.
Fold: grep the design's full named set (`log-issue`, `log-project`, `cairn-pass`, `site-pass`,
`cairn-release`, `dependency-upgrade`, `pass-core`, `claude-infra`, `cairn-figure`,
`dotfiles-pass`, `claude-memory-write-check`, and `claude/.claude/CLAUDE.md`). Add a tree-wide
`git grep -n ROADMAP -- claude/.claude/skills .claude/skills bin` whose only allowed hits name
cairn-cms's ROADMAP or a history file, with a test that plants a non-cairn ROADMAP reference in a
fixture skill.

**M21. correctness. Plan 117-121.** C5's acceptance reads state the step deletes. "The tool's
removable check passes on every worktree it removes" can't be run after `git worktree remove`.
"`tar -tf` lists all three directories" runs after the removals, so it neither proves the archive
was complete before deletion nor stops a deletion when the archive is short.
Fold: before any removal, log each worktree's removable verdict, with its five rule values, to
`~/.local/state/repo-organization/c5-removals.tsv`, and make that log the acceptance. Make the tar
check a precondition for removal: for each archived directory, the tar's member count equals
`find <dir> | wc -l` taken just before, and the removal of the three archived directories runs only
after it passes.

**M22. correctness. Plan 133, 418-420, 502-503; design checks 1 to 6.** The six end-to-end checks
are the pass's whole outcome, and no task writes them as an executable artifact. C7 and T1 each
improvise "the checks themselves", so the two machines may run different commands, and T1 commits
whatever it ran. Several have no stated mechanism:
- Check 2 says "a session opened in drafter prints". A session can't be opened headlessly, so the
  check should run the hook script from that directory and match the expected records.
- Check 3's "the item appears" has no stated read (the app's `/item/<id>` or the items directory),
  and neither does "a server whose working directory is under `~/Projects/approval-queue`"
  (`readlink /proc/<pid>/cwd`). Nor does "withdraw": the command has no withdraw verb, and only
  killing the waiting command removes the item, through its EXIT trap.
- Check 5's "on either machine" can't pass on pavilion at C7 before the thinkpad leg.

Fold: add the checks as `repo-organization/tools/e2e-check` with a `--host` flag that selects the
host-local legs. Give it a fixture test per check that fails on a planted violation and on an empty
input list (teardown ids, deleted repos, ROADMAP repos, which must number exactly ten). C7 and T1
run the same tool, and T1 commits its output.

**M23. correctness. Plan 164, 156-158.** Nothing proves the map's "moved code paths get rows". The
acceptance counts "173 expected, plus code rows" with no expected code list. A map with zero code
rows passes, and then `refs` rewrites no reference to `docs-page-chain.js`, `cairn-docs-outline`,
`drafter-gate.sh`, or the approval-queue paths.
Fold: pin the code rows to the design's two lists, the drafter pieces and the approval-queue pieces
(including the `review-desk` historical names, as non-rewritten history rows), and check them by
exact path. Compute the 173 independently of the classifier, with
`ls docs/superpowers/{specs,plans,research} | wc -l` at the pinned commit.

**M24. correctness. Plan 390, 386, 314.** The S and W5 "applied count equals the decision's row
count" has no measurement. "now + defer applied + drop = rows" is a partition of the decision, true
by construction unless "defer applied" is measured. The 31 dubplate and 1 xcathletes-org
`#project:` tags have no zero check.
Fold: measure the `defer` count as BACKLOG.md lines added in the branch diff carrying
`#initiative:`. Measure the `now` count as record ids present on initiatives `origin/main`. Assert
`git grep -c '#project:'` is 0 in each swept repo, and the drop count is the remainder.

**M25. correctness. Plan 103, 54; `approval-queue` lines 13 and 20.** The command prints no item id.
It prints only the decision, at the end. So "its id goes into `items.tsv`" has no stated way to
capture it: the id is a timestamp plus the PID, and must be found by title under `items/`. Its EXIT
trap removes `item.json` when the command dies without a decision. A conductor restart, API-drop
relaunch, or `claude stop` therefore silently withdraws every pending item, and every executor's
wait loop on `decision.json` spins forever with no failure condition. That makes every
decision-gated task's wait vacuous in the bad direction.
Fold: C2 records the id by reading `item.json` whose `title` matches, right after the command
starts. Every wait loop fails, with a notify, when that `item.json` is gone and no `decision.json`
exists. C2's acceptance re-reads each `item.json`.

## Minor

**m1. correctness. Plan 177.** I7 compares the triage file to `roadmap-count`, and one session wrote
both. Pin the design's known counts as a cross-check: workstation 22, aksailingclub-org 21 (19
headings, 2 bullets), and about 80 in all.

**m2. correctness. Plan 164.** `migration-calls.md` passes the brief check even with fewer Decide
blocks than rows. Assert that the block count equals the `flagged` plus `collision-differs` row
count, which is at least 3 given dubplate's known collisions. I9's acceptance should state
`grep -c flagged migration-map.tsv` is 0.

**m3. correctness. Plan 283.** `git filter-repo --version` probably prints a short hash of the
script, not `2.47`. Probe it, or use `brew list --versions git-filter-repo`. W4's acceptance also
leaves the Brewfile line and the bootstrap change unchecked: add `grep -x 'brew "git-filter-repo"'
bluefin/Brewfile` and a `bash -n` plus a dry-run leg for `bootstrap.sh`.

**m4. correctness. Plan 442 against 126, 456.** The path table lists C6 at 30, but the task and the
sum say 45. The path is 890, not 875. The sweep cap of three at once also puts about 180 minutes of
sweeps (540 / 3) after PR 1's merge and ahead of the workstation merge. That chain, roughly 885 to
900, isn't in the table. Both are well under 1,680, so this is a correctness fix to the figure, not
a stop.

**m5. correctness. Plan 89.** C0's acceptance proves 2 of its 5 outcomes. `rev-list --count
HEAD..origin/main` is 0 whenever origin is equal or behind. Add `origin/main..HEAD` = 0, the
`secrets/` porcelain line, and `git check-ignore -q .claude/worktrees/x` per launch checkout.

**m6. correctness. Plan 151.** `--repos` has only a failing case. A version that always fails
passes. Add a good fixture that `--repos` passes, and a CI-mode case that passes on a fixture
naming a missing repo.

**m7. correctness. Plan 218.** I2's acceptance never counts the records or checks the KEP sections,
and `scripts/check` doesn't read README sections. Assert eight directories, the eight named ids,
and the six section headings per README.

**m8. correctness. Plan 292-293.** W2's states don't assert the exit code. "Always exits 0" needs
`$? -eq 0` in each case, including a case where `yq` is missing from `PATH`.

**m9. correctness. Plan 161.** The `deferred:<pass>` state reads live `claude agents --json` and
STATUS files. Its fixture needs a stubbed agents list and STATUS, or it runs against the live
machine.

**m10. correctness. Plan 127.** `git status --porcelain` empty doesn't prove `~/.dotfiles/approval-queue/`
is gone, because the ignored `node_modules/` and `build/` don't show. Add `test ! -e
~/.dotfiles/approval-queue`. Also check `realpath` for `claude-approval-queue-reminder` and
`cairn-docs-outline`, not just one command each.

**m11. correctness. Plan 126, 415.** The `MEMORY.md` index-line removal on both machines and the
thinkpad memory fold have no acceptance. Add `grep -c batched-docs-tool-initiative` = 0 in each
`MEMORY.md`. Before the delete, record the memory file's line count and `sha256` in
`thinkpad-checks.md`, so the fold's completeness is checkable after the file is gone.

**m12. correctness. Plan 329.** W8 re-encrypts the worktree's `values.age` from the branch base. A
secret added on main after branch start would be lost from the live `~/.local/secrets`, which the
script regenerates from the worktree store, before the binary merge conflict surfaces. Add a
precondition: the worktree's `values.age` equals `origin/main`'s by `sha256` at task start, and if
not, merge main first.

**m13. correctness. Plan 509.** Review Focus 1 pins the refusal. It should also assert the fixture
dotfiles tree is byte-identical (a checksum before and after), not only the nonzero exit.

**m14. correctness. Plan 342-345.** W7's draft-check fixture covers an edited moved file only. Add
a missing-destination fixture, and assert that the checked-row count equals the map's moved-row
count, so an empty row read fails.

**m15. correctness. Plan 314, 390; `ebb4877`.** A ROADMAP can gain entries between I7's draft and
its repo's apply. Workstation's gained one today. The count checks then fail with no named remedy.
State it: a new entry goes to Geoff as a one-row triage item, never applied unasked.

**m16. correctness. Plan 55; `TriageView.svelte:30`.** The app labels the three choices "Do now",
"Do later", and "Don't do". The plan means "become a record", "backlog", and "drop", and only the
lede says so. Geoff may pick "Do now" for an urgent single-repo task. Have each row's `why` or
`detail` restate its effect ("now: becomes record `<id>`").

**m17. correctness. Plan 361.** D1's two `WORKSTATION_DIR` tests should fail loudly when the
directory is absent, never skip. A skip would make them vacuous on a machine without the symlink.

**m18. correctness. Plan 105.** C2's acceptance counts the dry-run item, which I8 produces much
later. Split the acceptance by item, or move the dry-run hand-over into I8's or C1's follow-on.

**m19. correctness. Plan 240, 498.** The thinkpad's clean `values.age` is a by-hand confirmation
with no recorded evidence, and design step 4 requires it before the confirmation. Have the dry-run
doc carry it as a Decide block or checklist line, so the approve records it (once B1 is fixed).

**m20. correctness. Design check 6; prompt `thinkpad` line 9.** On the thinkpad, a stale checkout
(reported, never forced) makes check 6 read old state. Check ROADMAP absence on `origin/main`
through `gh api`, as well as locally.

**m21. correctness. Plan 512.** Review Focus 4 should also cover a binding named only in a surviving
repo's deploy workflow (`wrangler deploy --name`), which design step 2 counts as a tie.

**m22. optional. Plan 167, 196, 206, 232.** Each tool repeats its own outside-scope test. Once M1's
shared harness exists, one parameterized test over every tool replaces four or five bespoke ones.

## Optional, over-ceremony

**O1. optional. Plan 500, 517; `pass-core` step 6.** **OWNER FORK.** Geoff reads 16 PRs. Eight of
the ten sweep PRs are `ordinary` (deletion of a ROADMAP, BACKLOG rows, path rewrites), and
`pass-core` already lets an `ordinary` change merge itself. Each read is a queue item plus a diff
read, and Geoff's wait time doesn't count on the path but holds the workstation merge, since
workstation merges last.
- (a) Sweep PRs whose diff touches no `runner` path self-merge on a green gate and a task-scope
  `diff-reviewer` accept, with one batched triage item listing what merged (recommended: it cuts
  about nine reads and shortens the time to the workstation merge).
- (b) Keep all sixteen reads, as planned.

**O2. optional. Plan 31, 258-272.** The retire session is a full cold start (pass-core, the whole
plan) for 75 minutes of work. The initiatives executor sits idle at PR-ready while the dry run
waits, and could open PR 2 from a second worktree. The saving is one session's context load,
roughly a few tens of thousands of tokens. It costs some isolation clarity, so it's low value.
Keep it unless tokens matter.

**O3. optional. Plan 408-421.** PR 3 exists to commit `thinkpad-checks.md` and the drafter README
fold. If M22's tool writes its output to the state directory and C8 lands the results in STATUS, PR
3 shrinks to the README fold. That could ride on PR 1's follow-up instead, saving one Geoff read.
This is small.

**O4. optional. Plan 505-513.** Review Focus is a separate section that each task then cites. It
works, but executors read the plan twice for one test. Inlining each case into its task's Test line
would save a little reading per session across 18 sessions. This is cosmetic.

## Outcome coverage (spec "What changes" and the end-to-end checks)

| Spec outcome | Proving task | Gap |
|---|---|---|
| Public repo with records and a CI-checked index | C0, I1, I2 | m5, m6, m7 |
| Every session prints its initiatives | W2, check 2 | m8, M22 |
| ROADMAP retires and entries are dispositioned | I7, I9, W5, S | B1, M19, M24, m1, m15 |
| Past docs move by the placement rule | I3, I9, S-dubplate, S-poplar, W7 | M12, M23, m2, m14 |
| Drafter and the queue move with history | C4, D1, A1 | M16, m17 |
| Eleven retired, sole-owner teardown only | I5, I8, R1, R2, C5, T1 | M5, M6, M10, M11, M21 |
| Rules and skills point at the new home | W3 | M20 |
| bootstrap and check-drift | W4 | m3 |
| Checks 1 to 6 on both machines | C7, T1 | M22, M8, M9, m20 |
| Scope exclusion | every repo-wide tool | M1, M2, M3, M4 |

## Scope exclusion, per repo-wide tool

| Tool or step | Outside-scope test in plan | Holds? |
|---|---|---|
| `classify-docs` (I3) | mode 000 | No: M1 |
| `refs` (I4) | mode 000 | No: M1; its memory glob reads the outside memory directory (M2) |
| `inventory` (I5) | "never reads" | No: M1; it reads `~/.claude` and the account Worker list by name (M2) |
| `worktrees`, `thinkpad-cleanup`, `extract` (I6) | "the outside-scope fixture", tool not named | No: M1; `thinkpad-cleanup` scans for remote-less directories by design (M2) |
| `roadmap-count` (I7) | none | Per-file, so not needed |
| End-to-end checks (C7, T1) | none, and no tool exists | No: M22 |
| "Pulls every repo" (T1 step 4) | none | Reads `scope.tsv`, but a missing row path is unspecified (M4) |
| Committed output, every PR | none | No check exists (M3) |
