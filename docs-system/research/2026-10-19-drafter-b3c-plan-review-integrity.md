# B3c plan review: data integrity and failure risk

Target: `docs-system/plans/2026-10-19-drafter-b3c-cairn-pilot-plan.md` at `68ae25d`. Design:
`docs-system/specs/2026-10-19-drafter-b3c-cairn-pilot-design.md`. Factsheet:
`docs-system/research/2026-10-19-drafter-b3c-factsheet.md`. Code was read at drafter `3c2c5cb` and
cairn-cms `main` `11104274e`, read-only, with no API call. Every claim below was checked against the
source named beside it.

Totals: 1 blocker, 6 major (1 of them an OWNER FORK), 13 minor (1 of them an OWNER FORK). Two
patterns cover most of them. First, the plan meets a second binary in two places and names only
one: B3's installed `drafter` sits beside `$B3C_DRAFTER`, and B3's installed binary refuses the
cairn branch once it holds `brief_path` or a `blocked` field. Second, the plan states the happy
path of each live call, but not what a killed, cancelled, or crashed call leaves behind: a dirty
tree, an unrecorded bar, a resumable run, or an open reserve.

The $80 ceiling holds for every call the plan runs in sequence. Each reservation is page-attributed
and checked at worst case against the page cap (`internal/ledger/ledger.go`, `Reserve`;
`internal/pipeline/money.go:110-135`), so one call spends at most N × `min(10, left/N)`. The
ceiling can fail only where two calls overlap, or where a call runs outside resolution 7 (findings
2 and 6).

## Blocker

### 1. The fix subagents' `drafter check` can't pass once the cairn branch holds `brief_path` or a bar

- Severity: blocker. Tag: `correctness`.
- Location: plan lines 465-467 (the probe's own fix runs "until `drafter check` reports 0 errors"),
  475-480 (round-1 fix subagents), 496-498 (later rounds), and 400-404 (the reshape prompt names the
  blueprint skill, which says to run `drafter check`). Source: `internal/config/file.go:98-106`
  (strict config decode), `internal/blueprint/lock.go:58-69` (`KnownFields(true)`), and
  `internal/blueprint/project.go:98-101` (`drafter check` loads the lock through `ReadLock`).
- Defect: resolution 5 has the reshape agents use the installed B3 binary. That works because the
  branch holds no `brief_path` and no `blocked` yet. B3c.5 then commits `brief_path` to cairn's
  `drafter.toml`, and P1 commits `blocked` entries. Every fix worktree branches from the P1 lock
  commit, so it holds both. The plan names no binary for the fix subagents or for the session's own
  probe fix. Each fix prompt reuses the reshape recipe, which says `drafter check`, and the
  `drafter` on PATH is B3's. Two things follow:
  - B3's binary refuses the config at load with an unknown key, and if it got past that, it would
    refuse the lock. No fix agent can ever reach the acceptance line "0 errors from `drafter
    check`".
  - A subagent told to reach 0 errors, with the error naming `drafter.toml` or `drafted.lock`, may
    "fix" that file. If it drops `brief_path` or the `blocked` entries, the merge carries the
    damage into the pass worktree. A dropped bar silently turns the next read whole, which is
    #13's original defect.
- Fold:
  - Every fix prompt, and the session's own probe loop, names `$B3C_DRAFTER check` by absolute
    path. The prompt adds: "Edit only `<blueprint path>`. Never edit `drafter.toml`,
    `drafted.lock`, facts, or outlines."
  - Before each merge, the session runs `git diff --name-only <base>..<branch>` and merges only
    when the output is exactly that one blueprint. Anything else stops the merge.
  - Add the binary rule to resolution 6's "The binary" bullet, so it covers every `drafter` call in
    the cairn worktree after B3c.5, offline calls included.

## Major

### 2. The stall rule overlaps two live calls and strands the cancelled run

- Severity: major. Tag: `correctness`.
- Location: plan lines 504-505 ("cancels it through the API, as B3 did, and reruns that round's
  remaining pages with `--sync`") and 513-514 (the same rule for the waves). Sources:
  - `internal/batch/classify.go:11`: a canceled result maps to `ActionResubmitThenStop`.
  - `internal/pipeline/handle.go:146-149`: the first cancel resubmits, and only a second halts.
  - `internal/pipeline/start.go:88-117`: `requireClean` and the non-blocking worktree lock.
  - `internal/pipeline/money.go:526-537`: a failed poll stops the run while the batch keeps running.
- Defect: the rule doesn't say to stop the drafter process first, and four things go wrong without
  that step:
  - **Overlapping spend.** If `drafter` is still polling when the session cancels the batch, it
    reads the canceled results and resubmits them as a new batch. The `--sync` rerun computes its
    cap from a meter reading taken before that resubmission. Two calls then spend against the same
    `left`, and the pass can pass $80.
  - **The rerun can't start.** The live process still holds the worktree lock, so the `--sync`
    rerun is refused.
  - **A dirty tree in a wave.** A `drafter page` batch that stalls at a review stage has already
    written its drafts. Killing it leaves them in the tree, unrestored, since nothing escalated.
    The rerun fails `requireClean`. Pages the cancelled run accepted before the stall never get a
    lock entry or a bar, because the helper skips a stopped run (plan line 214).
  - **A stranded run.** The cancelled run stays resumable, and its reservations stay open at worst
    case in the meter (B3 left $1.00 this way). A wave's draft-stage reserve is several dollars a
    page, so the leftover can stop the line on `left <= 0` for spend that never happened. The
    merge order's "no stopped run" check (plan lines 819-820) will also find this run and block
    Geoff's `make install` step, and nothing tells him what to do.
- Fold: write the stall rule as an ordered procedure.
  1. Stop the `drafter` process and confirm with `pgrep` that it has exited.
  2. Cancel the batch through the API.
  3. For a `drafter page` run, print `git status --porcelain` to STATUS as the dry run, then
     restore the tree to HEAD.
  4. Record the run id in STATUS as abandoned, with its `open.worst`.
  5. Start the `--sync` run on a fresh meter reading.

  Close lists every abandoned run id in the drafter PR's merge steps, so the merge-order check can
  tell B3c's own abandoned runs from a real stopped run. Give `--sync` calls a hang rule too: none
  exists today.

### 3. No recovery rule for a session or process that dies during a live call

- Severity: major. Tag: `correctness`.
- Location: plan lines 425-427 ("The tree"), 441-443 (one STATUS row per live call), and 149-154
  (the clock file). The plan has no resume section.
- Defect: the pass is unattended for hours, and the probe draft runs in the background (plan line
  476). A session death, a compaction, or a killed background shell can leave three states, and the
  plan covers none of them:
  - **A run in flight.** Its pages and briefs are half-written in the tree.
  - **A finished run whose `drafted.lock` change isn't committed yet.** The tree holds new bars or
    an `accepted`.
  - **A stopped run.**

  A fresh session sees a dirty tree, and the plan says a run needs a clean one. The likely moves
  are `git restore`, which drops the bars and makes the next read whole again, or a commit of the
  half-drafted pages. Either one corrupts the data #13 depends on, or leaves a page with no entry.
- Fold: add a "Recovery" bullet to resolution 6.
  - Write each STATUS row before its call, with the run id once printed and an "after" cell left
    empty.
  - When a session finds a row with no "after" cell, it resumes that run with `--resume <id>` in
    the same mode, on a fresh meter reading. It never restores or commits the tree first.
  - A dirty tree that holds only `blueprints/drafted.lock`, after a run whose summary shows it
    finished, is committed as is.
  - Any other dirty state stops the line.

### 4. A failed lock write in `drafter read` loses the bar, and a resume may not rebuild it

- Severity: major. Tag: `correctness`.
- Location: plan lines 206-214 (recording) and 589-654 (B3c.2's tests). Sources:
  - `cmd/drafter/read.go:154-156`: `recordAccepted`'s error returns `cannot(err)` before the
    summary prints, with no resume line. `pagebp.go:96-107` prints both.
  - `internal/pipeline/pipeline.go:233-250`: `summary()` builds each `PageResult` from `p.w` and
    `p.ps`.
- Defect:
  - The shared helper takes the worktree lock with `TryLock`, so a crash or a busy lock fails the
    write. In `drafter read`, that failure prints no summary. The findings the bar was meant to
    hold reach neither the lock nor stdout, and the next read is whole, with no bar.
  - The plan says `WholeBlocked` is "set in `completeBlueprintRead`" but doesn't say on what. A
    resume of a finished run rebuilds its summary from `work`. If `WholeBlocked` lives only on the
    `PageResult`, `--resume` can't rebuild it, so it can't write the bar either.
- Fold:
  - Make `whole_blocked` a `work` field (`omitempty`, like `bar` and `bar_from`), and have
    `summary()` copy it.
  - Give `drafter read`'s lock-error path `pagebp.go`'s shape: print the summary first, then the
    error with the resume line.
  - Add a B3c.2 row: a finished read whose bar write failed resumes with `--resume`, writes the
    bar, and makes no API call.

### 5. claude-code's green gate skips the leak, symbol, snippet, and visual checks (OWNER FORK)

- Severity: major. Tag: `correctness`.
- Location: plan lines 55-66 (finding 3: "If cairn's docs gate refuses the page ... the page
  escalates") and 531-535 (Check 2). Sources (cairn):
  - `scripts/checks/check-leaks.mjs:473-495`: `SCAN_ROOTS` lists `docs/extend`, `docs/admin`,
    `docs/editors`, and `docs/reference`, and not `docs/claude-code`.
  - `check-symbols.mjs:66-70`, `check-snippets.mjs:59-62`, and `check-visuals.mjs:35-38` list the
    same directories.
  - `arm-state.mjs:28`: `ARM_DIRS` leaves the arm out, and `armOf` returns null for the page.
  - `package.json` `files` (`:205-218`) leaves `docs/claude-code` out.
- Defect: the gate won't refuse the page. It passes it, and four of its whole-tree checks never
  look at the page. cairn-cms is public, and `check:leaks` is the check that keeps a private path
  or account detail out of it. Check 2's "passes the docs gate" claim means less for this page
  than for the other seven, and the PR wouldn't say so. The page also lands on `main` outside the
  package, unlinked from any index.
- Options:
  - (a) Draft and include it. Before its acceptance, run the four checks against a scratch copy of
    the worktree, with the page and brief moved under `docs/extend/`. `check-leaks` takes only
    `--root`, not a file. The cairn PR's table marks the page's gate coverage as partial.
  - (b) Draft it, but keep it on a side branch out of the cairn PR until stage 2b registers the
    arm. Report it in the PR.
  - (c) Add `docs/claude-code` to the four checks' lists in B3c. That's code in cairn's
    `scripts/checks`, outside the design, so it needs Geoff's ruling.
- Recommendation: (a). It keeps "all eight", makes the coverage gap visible, and costs one scratch
  run.

### 6. Check 3's confirmation is a live call outside the budget rule

- Severity: major. Tag: `correctness`.
- Location: plan lines 541-542 (`$B3C_DRAFTER page --json <page>` "then confirms by printing 'up to
  date ...' with no run id and no spend") and 482-484 ("Run the checks of resolution 9, then
  commit"). Sources: `cmd/drafter/draftscope.go:65-95` (`scopeFromLock` reads the lock committed at
  HEAD) and `cmd/drafter/pagebp.go:84-88`.
- Defect:
  - "No spend" is an expectation, not a guard. If the page isn't up to date at HEAD, the call runs
    a live whole draft. Two causes would do it: a scoping bug, or a lock entry that doesn't match
    the commit. The call sets no `DRAFTER_PAGE_CAP`, so the user layer's $10 applies to each page,
    with no meter reading first. Across eight pages that's up to $80 outside resolution 7.
  - Resolution 8 runs the checks before the commit. At that point HEAD's lock lacks the new entry,
    so the call isn't "up to date". `requireClean` refuses only because the tree is dirty, so the
    check fails for the wrong reason.
- Fold: run Check 3's confirmation as `$B3C_DRAFTER page --dry-run --json <page>`, after the
  commit. The skip prints before any run starts (`draftscope.go:79-82`). Change resolution 8 to
  commit first, then run Check 3.

### 7. Bars name branch commits, and their loss falls back to a whole read with no notice

- Severity: major. Tag: `correctness`.
- Location: plan lines 216 (the bar's `commit` is the run's start commit), 238-239 ("`ScopeWhole`
  (the bar's commit is gone ...): the read is an ordinary whole read, with no bar"), and 825-828
  (merge order step 2). Source: `gh api repos/glw907/cairn-cms` reports `allow_squash_merge` and
  `allow_rebase_merge` true. cairn's recent PRs (#123 to #129) all used merge commits.
- Defect: every bar names a commit on `b3c-pilot-pages`. The bars that matter after the pass are on
  pages that escalated in the read loop, and those go to Geoff. A squash or rebase merge leaves
  those commits off `main`, and a fresh clone on the other workstation doesn't have them. The next
  read then falls back to a whole read with no bar and no message. That's #13's non-convergence on
  exactly the pages that need the fix. A rebase of the branch during the pass would do the same.
- Fold:
  - Merge order step 2 says "merge commit, not squash or rebase", and the session never rebases
    `b3c-pilot-pages`.
  - The `ScopeWhole` fallback for a page that holds a bar prints one line, such as "the blocked
    read's commit <short> is not in this repository; reading whole", so the loss is visible.
  - Add a B3c.2 test row for that line.

## Minor

### 8. The `drafter page` path swallows a lock decode error, so a bad bar turns into a whole draft

- Severity: minor. Tag: `correctness`.
- Location: plan lines 250-252 and 282-284 ("The plan adds no handling for a malformed bar beyond
  the lock's own decode"). Source: `cmd/drafter/draftscope.go:69-75` sets `lock = nil` on a decode
  error and goes on with an empty lock.
- Defect: in `drafter page`, the lock's decode isn't a guard. A lock that fails to decode is
  treated as empty, so the bar, `SkipRead`, and every entry vanish without a message. The run then
  reads and drafts every page whole, and fails afterward at `recordDrafted`'s `ReadLock`
  (`pagebp.go:196`), after the spend.
- Fold: the bar lookup and `scopeFromLock` refuse on a decode error, naming the file. Add one test
  row.

### 9. The config refusal, not the lock refusal, is what stops an old binary

- Severity: minor. Tag: `optional`.
- Location: plan lines 67-73 (finding 4) and 825-828.
- Defect: the plan relies on the lock's `KnownFields` refusal to stop a pre-B3c binary. On the
  `drafter page` path that refusal is swallowed (finding 8). The guard that actually works is
  `brief_path` failing strict config decode, and B5 plans to remove `brief_path`. After that, a
  pre-B3c binary on a lock that holds `blocked` would draft whole and fail only at the lock write.
- Fold: name the config refusal as the working guard in finding 4, and file a backlog note
  against B5. B5 drops `brief_path`, so it needs another guard, or this pass's fix to finding 8
  must have reached every install.

### 10. Check 2 says `blocked` holds the last read's findings, but it holds the first

- Severity: minor. Tag: `correctness`.
- Location: plan lines 532-533 vs 218-220 ("The bar stays fixed at the first blocked whole read").
- Defect: a page that escalates at its fourth read has the P1 findings in `blocked`, not read 4's.
  Taken as written, Check 2 would put stale findings in the PR table.
- Fold: the PR table takes each page's last findings from that read's summary JSON, as recorded in
  STATUS. Check 2 says `blocked` holds the first blocked read's findings.

### 11. A bar on a page with no lock entry is untested

- Severity: minor. Tag: `correctness`.
- Location: plan lines 199-203 and 609-617. Source: `internal/blueprint/blueprint.go:185-195` (the
  comment defines an entry that holds only `accepted`).
- Defect: claude-code has no entry (plan line 372), and its P1 whole read will likely block. That
  writes an entry that holds only `blocked`, a shape no test covers. Untested paths include
  `drafter check`'s lock load, `pageScopeFor` (where `e.Page == ""` drafts whole), the walk, and
  the clear on accept.
- Fold: add a B3c.2 row. A page with no entry blocks, and the entry holds only `blocked`. A bar
  accept leaves only `accepted`. A draft writes a full entry with no `blocked`.

### 12. Wave 1's cap can use up wave 2's room (OWNER FORK)

- Severity: minor. Tag: `optional`.
- Location: plan lines 434-438 and 509-512.
- Defect: wave 1's cap is `left/4`, which lets four small pages reserve up to $40. Wave 2's three
  largest pages then split what's left. A page that hits its cap partway through a draft escalates
  with rule `cap` (`money.go:121-123`). The spend is lost, and the plan doesn't rerun a cap
  escalation.
- Options:
  - (a) As planned.
  - (b) Wave 1's cap is `min(10, left/7)`, so each page still to draft keeps a fair share.
  - (c) Before wave 2, a page whose share is under $6 is skipped and reported, with nothing spent.
- Recommendation: (b). It costs nothing when the money is plentiful, and it protects the two
  largest pages when it isn't.

### 13. Another session's concurrent spend can push the counted total past $80

- Severity: minor. Tag: `optional`.
- Location: plan lines 441-443.
- Defect: the cap comes from a reading taken before the call. Spend by another session on this
  machine during the call isn't bounded, so `used` can end above $80 even though B3c's own spend
  stays inside its caps. Spend on the other workstation never appears in this ledger.
- Fold: say so in resolution 7. The PR reports both B3c's own spend and the counted `used`.

### 14. The mechanical-fix loop on rotate's reads has no bound

- Severity: minor. Tag: `optional`.
- Location: plan lines 470-473 vs 489-490 ("At most two such cycles" for the probe draft only).
- Fold: apply the same bound of two cycles to the read loop's mechanical fixes, then stop the line.

### 15. Close-review fixes can change the bar format that cairn's lock already holds

- Severity: minor. Tag: `correctness`.
- Location: plan lines 408-411 and 783-788.
- Defect: the cairn lock's `blocked` entries are written by the pair-A binary. Close's fix chain
  can rename or reshape the field after that. The cairn PR would then carry a lock the merged
  drafter refuses or misreads.
- Fold: the close fix chain must leave the lock schema alone, and a fix that changes it stops the
  line. After the close build, run the final binary in the cairn worktree: `drafter check`, plus
  `drafter page --dry-run --json` over all eight pages. Both results go in the cairn PR.

### 16. Fix worktrees are never removed

- Severity: minor. Tag: `optional`.
- Location: plan lines 476-479 and 496-498 vs 712. Only the reshape worktrees' removal is in an
  acceptance. Lines 178-181 hold the next launch's "no `b3c-` worktree" check.
- Fold: B3c.7's acceptance adds "every `b3c-fix-*` worktree and branch removed".

### 17. Over-ceremony: a worktree and a merge per page per fix round

- Severity: minor. Tag: `optional`.
- Location: plan lines 476-479 and 496-498.
- Defect: up to 28 worktrees, branches, and merges. Isolation is needed only while the probe is
  live. B3c.7's rounds run between live calls. The files are disjoint, and the session could
  commit them in the pass worktree. Every merge is another chance for finding 1's damage to slip
  in.
- Fold: keep worktrees for round 1, while the probe runs. In B3c.7, fix subagents edit their one
  blueprint in the pass worktree without committing. The session runs finding 1's file check
  (`git status --porcelain` names only those blueprints) and commits once per round.

### 18. A link added by an escalated page's index-link command can land in the wave commit

- Severity: minor. Tag: `optional`.
- Location: plan lines 482-484 and 515-516. Source: `internal/pipeline/page.go:358-366`. When a
  later page changed an index file after an escalated page linked it, drafter doesn't restore the
  file and records only friction.
- Defect: in a wave, the shared index can keep a link to a page that escalated and was restored or
  removed.
- Fold: before each wave commit, check each changed index file's diff against the accepted pages.
  Check 2's gate rerun covers broken links through `check:docs`, as long as it runs after the
  restore.

### 19. cairn `main` can move during the unattended run

- Severity: minor. Tag: `optional`.
- Location: plan lines 789-791 and 825-828.
- Defect: other sessions may merge facts, page, or friction-log edits while the pass runs or while
  Geoff reads. `docs/internal/docs-friction-log.md` is append-only, and the conversion commit
  appends to it, so a text conflict is likely. A facts change would make an accepted page's gate
  red only after the merge.
- Fold: merge order step 2 reruns `ci-green` on the PR's current merge ref before merging, and
  resolves a friction-log conflict as a pure append.

### 20. `check:leaks` doesn't scan blueprints or the lock

- Severity: minor. Tag: `optional`.
- Location: plan lines 374-377 and 206-217. Source: `check-leaks.mjs:473-495` (no `blueprints`
  entry).
- Defect: eight blueprints and the bar's finding text land in the public repo without a leak scan.
  This gap predates the pass, but B3c multiplies the content by eight.
- Fold: file a cairn backlog item to add `blueprints` to `SCAN_ROOTS`. Until then, the session
  greps the cairn diff for `/home/`, `/var/home/`, and the workstation names before pushing.
