# Acceptance plan review: data integrity and failure risk

Target: `docs-system/plans/2026-10-19-drafter-acceptance-plan.md` at initiatives `70ecab5`. Code
read at drafter `6b110ad` and cairn-cms `517158fae` (origin/main, fetched during the review). Run
state read under `~/.local/state/drafter/runs/`. Plan locations are `plan:<line>`.

Thirteen correctness findings and nine minor or optional ones, ranked by consequence. No blocker:
every gap either fails safe (a stop or a wasted rerun) or is a few lines of plan or test to fold.
The majors are where a page can be accepted against inputs nobody read, where a lock entry or an
accepted draft can be lost, or where a fresh process can be killed mid-batch.

## Major

### M1. Live calls have no background rule, and a killed drafter leaves a live batch (correctness)

- Location: plan:581-585 (R2), :603-605 (R3), :623-625 (R4), :645-649 (R5), :556-558 (R1).
- Defect: the waves are budgeted at 45 to 90 minutes each. The Bash tool's foreground timeout is
  at most 10 minutes, and drafter has no signal handling (`grep -rn 'signal\.' cmd internal`
  finds nothing). So a wave run in the foreground gets killed at the timeout, and a session
  restart or API drop kills its children the same way. The killed run's state stays `running`
  with its batch live and its reservations open (B3c resolution 8 says the same thing:
  "Never kill it"). B3c ran the probe "in the background" (B3c plan:606-607). This plan says
  nothing about it, so every wave depends on the executor guessing right.
- Fold: add to "Run rules for R1 to R5": every live `ACC page` or `ACC read` call runs with
  `run_in_background: true` (or under `nohup`, with stdout and stderr going to a log STATUS names).
  Its STATUS row gets the run id from the log as soon as it prints. Before any `--resume`, the
  session checks with `pgrep -f '/acceptance/drafter (page|read)'` that the original process has
  exited. The run lock (`run.TryLock`, resume.go:34-38) already refuses a second process; the
  check only stops the session from reading that refusal as a failure.

### M2. #25 as specified drops a bar and certifies blueprint changes nobody read (correctness)

- Location: plan:397-401 (A2 build), :409-416 (A2 tests).
- Defect: `drafter read --since` never consults a bar. The `f.since != ""` branch calls
  `scopePages` and skips `readBars` (cmd/drafter/read.go:122-127 against :128-131). A scoped
  accept has `BarFrom == ""`, so `scopedAccept` is true (read.go:397-406). Today that falls to
  `default` in `recordReads` and writes nothing (bar.go:74-100), so the bar survives. A2's spec,
  "writes `accepted` ... and drops `blocked`", turns that into two silent losses in the drafter
  that ships to main:
  - Run against an entry that holds a bar, a `--since <rev>` accept clears the bar even though the
    read never saw the bar's findings.
  - When the lock's prior `accepted` isn't the blueprint's blob at `<rev>`, the accept records the
    whole blueprint as read-accepted, though the read judged only the diff since `<rev>`. Every
    change between the prior accept and `<rev>` goes unread. `skipRead` then trusts the entry
    (draftscope.go:111-114), and the next `drafter page` skips the read.

  This pass escapes it only because all seven entries carry `accepted` equal to their blob at
  `517158fae` and no `blocked` (verified with `yq` over `origin/main:blueprints/drafted.lock`, all
  seven match). Nothing re-checks that at launch (see m2).
- Fold: A2 writes the new `accepted` only when the entry holds no `blocked` and its prior
  `accepted` equals `git rev-parse <since>:<blueprint>`. That's when the read covered exactly the
  change since the last accept. Otherwise the entry stays as it is, and the stderr line stays,
  reworded to give the reason. Add test rows for both refusals (an entry with a bar, and a prior
  `accepted` that isn't the blob at `--since`), and keep `TestRecordReads`' old row as the refusal
  case. The docs at `docs/blueprint-format.md:557` state the condition. In this pass the condition
  always holds, so the outcome doesn't change.

### M3. A fact edited during R1 or R5 leaves another accepted blueprint stale (correctness)

- Location: plan:562-566 (R1 fix loop: "or, for a fact the read names, the fact"), :640-642 (R5
  rerun causes), :472-476 (C2's shared facts).
- Defect: R1 reads all seven in one call. Some accept, and the lock records `accepted` equal to
  their blob. A later fix round edits a fact for a still-blocked blueprint, then re-reads "only
  those blueprints' paths". If the edited fact is shared, the plan's own list says it can be
  (`f:cvv6to`, `f:nls26c`, `f:qca0t0`, factsheet-cairn section 6), an already-accepted citer's blob
  doesn't change. `skipRead` compares the blueprint blob alone (draftscope.go:96-97, :111-114), so
  that page's `--whole` run skips its read and drafts against a fact change no blueprint read
  judged. That's a page accepted against a stale blueprint, and "Check after" (plan:570-571)
  passes, since it compares blobs only. R5's fact fixes do the same to pages already accepted in
  R2 to R4. Worse, they also make those pages' lock entries not up to date: `pageScopeFor` compares
  the facts at the lock commit's parent with HEAD (draftscope.go:133-137). Close 3 (plan:700) then
  fails with no rule for what follows.
- Fold: before committing any fact edit after C4, the session runs `ACC refs f:<id>` (or reads
  factsheet-cairn section 6's method) and adds every citer among the seven to the next read call.
  The read goes out `--since BASE`, so the scoped read sees the fact change (since.go:143-151).
  After R2 starts, a fact edit whose citers include an accepted page isn't allowed: the cause gets
  fixed in the blueprint instead, or the citer reruns inside the budget, recorded in
  `## Decisions`. Extend "Check after" with: no fact cited by a page in the waves changed after
  that page's last accepted read (`git log --format=%H <read commit>..HEAD -- docs/internal/facts`
  is empty, or every changed bullet is uncited by it).

### M4. The small exchange's origin has no persisted home, so a resume or a hold can misroute it (correctness)

- Location: plan:337-343 (A1 "a coverage check in a new phase that remembers its origin"),
  :370-372 (the resume test).
- Defect: three routes pick the coverage phase from the exchange kind alone:
  - the gate, `gateStepOnce` → `toCoverage(coveragePhase(kind))` (check.go:139-140);
  - the hold, `held{Kind: kind, OnGreen: coveragePhase(kind)}` (check.go:143), which `regate`
    replays;
  - a resumed pending gate, `p.gateStep(ctx, p.w.PendingGate)` (resume.go:349-358), where
    `PendingGate` holds the kind.

  One new kind has two origins, so `coveragePhase(small)` can't know which one it came from
  unless the origin lives in persisted work state. If the origin sits only in a local, or is set
  on `coverageState` after `toCoverage`, a resumed or held small exchange lands on one fixed
  origin. A coverage-origin page could then skip round 2 and go straight to the reader, which is
  less review than a clean page gets. Every `default` arm falls to the draft gate-fix path
  (factsheet-pipeline section 2), and that's the silent failure finding 9 warns about. The plan's
  only resume test covers "the small exchange's gate pending" for one origin, and no test covers
  a hold during the small exchange.
- Fold: name the mechanism in A1. Either use two phase constants (`covSmallRound2` and
  `covSmallCoverage`) chosen by `coveragePhase` from a work field such as
  `SmallFrom string json:"small_from,omitempty"`, set when the exchange opens, or use two exchange
  kinds. Add test rows: the pending-gate resume for each origin; and a sibling-held small-exchange
  gate (#23) released by `regate` into the right phase for each origin. Both rows assert the page's
  next step (`stReader1` against `stRound2`).

### M5. A stopped run resumes on a different binary and on facts committed after it stopped (correctness)

- Location: plan:659-662 ("Recovery, the binary, and the stall rule ... each on a fresh meter
  reading"), :505-507 ("`ACC` is rebuilt after any later drafter fix").
- Defect:
  - `state.json` records `drafter_version` (internal/run/state.go:22, start.go:136), but nothing
    reads it on resume (grep finds no other use). The fingerprint hashes config only, not code or
    schemas (fingerprint.go:16-45). A run stopped under one `ACC` and resumed after R2's rebuild
    mixes old saved requests with new assembly, new step switches, and the new answer schema,
    with no warning.
  - `checkPosition` accepts any HEAD that descends from the run's start (resume.go:104-108), and
    resume loads facts fresh from the working tree (`plan.LoadFacts(cfg.Facts.Dir)`, resume.go:59-63).
    The tree rule (plan:656-658) covers only a *live* run. So a commit that lands while a run is
    stopped (an R1 or R5 fact fix, an inbound-anchor retarget) feeds new facts into the resumed run
    mid-flight. The lock entry is then dated by its commit's parent, which has the new facts
    (draftscope.go:133-137), so the lock says the draft saw facts it saw only in part.
    `warnMovedInputs` (pagebp.go:220-238) warns but doesn't refuse.
- Fold: add to Run rules:
  - A run resumes only on the `ACC` commit its STATUS row names: compare `state.json`'s
    `drafter_version` with `go version -m ACC`. Otherwise the run is abandoned, its `open.worst`
    is recorded, and its pages rerun fresh.
  - While any run in STATUS is stopped and not abandoned, nothing is committed in the cairn
    worktree but that run's own outputs.

  The `drafter_version` check on resume goes to drafter's backlog, since `resume.go` is outside
  this pass's edit set.

### M6. Several subagents share one cairn worktree, and the cairn-implementer runs `npm ci` and commits there (correctness)

- Location: plan:419-455 (C1), :457-463 (C2), :483-499 (C3), :186-189 (the build window runs C1
  beside C2 then C3).
- Defect: C1, C2, and then C3's seven subagents all work in
  `.claude/worktrees/acceptance-pages` at once. This breaks the global "One executor per worktree"
  rule, and the mechanics fail in four ways:
  - The `cairn-implementer` definition begins with "Run `npm ci && npm ci --prefix
    examples/showcase` first" and ends with "Commit only the files the task lists"
    (`~/.claude/agents/cairn-implementer.md`, Workflow 5). `npm ci` deletes `node_modules` while
    C2's `cairn-run-gate 'npm run check:facts'` may be running, which gives a spurious red that C2
    may "fix".
  - The commit rule "the session commits once `git status --porcelain` names only them"
    (plan:424) can't hold while C2 and C3 have uncommitted edits in the same tree.
  - C1's acceptance runs `gate-tier.mjs --fast --range BASE..HEAD` before anything is committed.
    The range is empty, and gate-tier exits non-zero on an empty range with nothing on stdout
    (`scripts/checks/gate-tier.mjs:8-11`).
  - C2's whole facts edit stays uncommitted through C3 (plan:496-498). One stray `git checkout`
    or `git stash` from a parallel agent loses it.
- Fold: give C1 its own cairn worktree from `BASE` (`acceptance-gate`), where the implementer runs
  its setup, its fast lane, and its commit the way its definition says. The session merges it into
  `acceptance-pages` before A3. C2 commits on its own once its acceptance passes, before C3
  dispatches. The 31-finding map can then span the C2 and C3 commits. C3's seven stay in the shared
  tree, which is safe because they edit disjoint files and run read-only `drafter check`. The path
  doesn't move: C1 already runs beside C2.

### M7. A held page that stops the run as "tree red" strands its siblings' accepted drafts (correctness)

- Location: plan:348-351 (#23 widens the hold), :640-642 (R5 "an inbound link retargeted after
  'tree red outside drafter's pages': once more"), :659-662 (Recovery).
- Defect: #23 turns more unparsed reds into holds. A hold that doesn't clear stops the whole run
  with `StopTreeRed` (pipeline.go:446-449). A stopped run writes no lock (`recordDrafted` returns
  early on `s.Stop != ""`, pagebp.go:186-188) and restores nothing. So in a three-page wave, a
  sibling that already reached `accepted` sits uncommitted in the tree with no lock entry. B3c's
  Recovery rule says "Any other dirty state stops the line", but R5 implies a fresh rerun, which
  needs a restored tree. That throws away the accepted drafts and their spend. The plan never says
  which rule applies.
- Fold: add a Run rule for `StopTreeRed`. The session traces the red. When the cause is outside
  the run's pages (an inbound link in another doc), it fixes that file, `--resume`s the run so the
  accepted pages record their lock entries, and only then commits the fix. M5's rule bends here on
  purpose, since the fix isn't a fact or outline file. When the cause is in a held page's own draft,
  the session abandons the run, records which pages had reached `accepted` in `state.json`, and
  reruns them. Add an A1 test: a hold that persists beside an accepted sibling leaves that
  sibling's resume able to record it.

### M8. A review or CI fix after the waves can invalidate accepted pages, and nothing reruns Check 3 (correctness)

- Location: plan:692-698 (Close 2 review fixes on "the facts, the blueprints"), :704-707 (Close 4
  CI fixes "on the branch"), :682-685 (Check 3 runs at close, before those).
- Defect: the plan forbids hand edits to a drafted page or brief only. A review or CI fix to a
  fact, a blueprint, or the outline that an accepted page uses moves that page off its lock
  entry. A blueprint change makes `accepted` differ from the blob, and a fact or outline change
  makes the page not up to date (draftscope.go:133-142). Close 3's dry run would catch the first
  case, but Close 4's CI fixes land after Close 3, and nothing re-checks them.
- Fold: a fix to the facts, the outline, or the blueprint of an accepted page is reported and
  filed, not made, unless the page reruns inside the budget. Check 3 and the dry-run line run again
  after every commit made after Close 3, and the PR body quotes the last run.

### M9. drafter's public diff gets no leak check, and the PR bodies are never grepped (correctness)

- Location: plan:699-703 (Close 3 greps only `cairn` `git diff origin/main...HEAD`), :709-717
  (PR bodies carry STATUS-derived content).
- Defect: drafter is public, and its CLAUDE.md says "no private path, account detail, or key
  belongs in it". drafter's gate has no leak check (`grep -rni leak Makefile scripts/` finds
  nothing). A1 adds fixtures copied "in shape" from a real gate log, A1 regenerates
  `record.golden.json` from the harness, and A2 writes docs. None of it is grepped. Both PR bodies
  are built from STATUS. STATUS spells out the absolute `ACC` path and the worktree paths in every
  command row (plan:222-228), and "every departure from this plan" is likely to quote them. B3c's
  bodies were clean (checked: 0 hits in drafter#55, and cairn-cms#132 holds only the grep's own
  pattern list), so this guards a habit, not a past leak.
- Fold: Close 3 runs the same grep over drafter's `git diff origin/main...HEAD`, and over each PR
  body file before `gh pr create`. The patterns are `/home/`, `/var/home/`, `thinkpad-x1`,
  `pavilion`, `~/.local`, `~/.config`, and `.claude/worktrees`. The tilde forms matter because the
  local layer inlines `~/.local/share/cairn/exemplars`, and a draft or brief could echo the tilde
  path, which `/home/` misses.

## Minor

### m1. The stopped-run check at merge misses killed runs and says nothing about what to do (correctness)

- Location: plan:733-737.
- Defect: `state.json` marks a resumable stop with a `"stopped"` key (run/state.go:28), so the grep
  finds runs that stopped cleanly. A killed run (M1) has no such key, and its pages read `running`.
  One already exists on this machine
  (`runs/tally-1792393364/20261019T070246Z-eb2482af`, page status `running`, no `stopped` key).
  The check also gives no action when it does find a run.
- Fold: flag any `state.json` with a `stopped` key or any page whose status is `running`,
  `pending`, or `held`, minus the ids the PR lists. On a hit, hold `make install` and name the run
  in the merge report. The stock change (finding 10) is what makes those runs unresumable.

### m2. A0 doesn't check that BASE still matches the lock (correctness)

- Location: plan:229-231, :302-303.
- Defect: "one base serves every scoped read" holds only while every entry's `accepted` equals its
  blob at `BASE`. That's true at `517158fae` (verified), but `BASE` is whatever origin/main is at
  launch. M2's fold makes this the precondition for every R1 accept.
- Fold: A0 step 4 asserts, for each of the seven, that the lock's `accepted` at `BASE` equals
  `git rev-parse BASE:<blueprint>` with no `blocked`. A mismatch stops the line.

### m3. Drift on cairn main before the merge (correctness)

- Location: plan:739-740.
- Defect: the cairn PR waits on Geoff's read, so main can move in the meantime.
  - A textual conflict in `drafted.lock` invites a hand resolution against its "do not edit by
    hand" header.
  - `LockIntroducedAt` walks `git log -- drafted.lock` newest first (drafted.go:41-60). When both
    sides changed the lock, the walk interleaves both parents by date and can name the merge
    commit as the entry's origin. `pageScopeFor` then reads the old facts from the merge's main
    parent (draftscope.go:133-137), and the result can be a spurious stale or a spurious up to
    date. That's an inference from the code, and no probe was run.
- Fold: Merge order step 2 adds two rules. A conflict in `drafted.lock` stops the merge and is
  reported, never hand-resolved. After the merge, `drafter page --dry-run --json` on main over the
  accepted pages prints "up to date with drafted.lock", or the merge report files the mismatch.
  File "LockIntroducedAt across merge commits (`--first-parent`)" in drafter's backlog.

### m4. The meter can't see concurrent spend, and drafter could enforce the ceiling itself (optional)

- Location: plan:262-277.
- Defect: `left` is read before the call, and another session's reservations during the call
  aren't fenced. The plan notes that other sessions count, but it doesn't stop them overrunning.
  The ledger already reserves atomically under its lock against `cycle_ceiling`, counting every
  open intent (ledger/store.go:94-110, money.go:117-130). `DRAFTER_CYCLE_CEILING` overrides it
  (config/env.go:84-86), and caps aren't fingerprinted (fingerprint.go:13-15), so a resume reads it
  fresh.
- Fold: each live call also sets `DRAFTER_CYCLE_CEILING` to this cycle's `drafter spend` total
  plus open worst plus `left`. Concurrent spend then makes the run stop as `cycle cap`
  (resumable) instead of overrunning $50. Also floor each computed cap to the cent. Writing
  `left/3` rounded up lets N × cap exceed `left`.

### m5. On a resume, the page cap shrinks below what the page has already spent (optional)

- Location: plan:660-662.
- Defect: `pageTotal` counts the run's settled and open spend for the page (ledger/store.go:78-92).
  A resume on a fresh `min(10, left/N)` sets the cap below what a partly run page already spent,
  so its next reservation escalates `cap` with money left. That fails safe, but it can turn a
  recoverable page into an escalation.
- Fold: resume with `min(10, spent_page + left/N_unfinished)`, taking `spent_page` from the run's
  ledger rows.

### m6. STATUS is the only copy of the meter baseline and of abandoned runs (correctness)

- Location: plan:218-221, :264-266.
- Defect: STATUS sits in the drafter worktree's git dir, never committed, and the PR quotes it
  only at close. B3c put its baseline in the B3c.0 commit body. If the worktree is removed or
  pruned, the baseline and the abandoned runs' `open.worst` are gone, and the $50 can't be metered.
- Fold: A0 also writes the baseline and the host name into an `--allow-empty` commit on
  `worktree-acceptance`, with no paths in the body. A row recording an abandoned run is mirrored in
  the next drafter commit body. A0 records the host as well: the ledger is per machine, so the
  executor must stay on one.

### m7. The one-executor check matches the planning worktree (optional)

- Location: plan:293-294.
- Defect: `pgrep -f worktrees/acceptance` also matches
  `initiatives/.claude/worktrees/acceptance-plan` and the pass's own `acceptance-pages`. The
  result is a false stop, or a habit of ignoring hits.
- Fold: `pgrep -af 'worktrees/acceptance(/|$| )|worktrees/acceptance-pages'`, with the planning
  worktree named as expected.

### m8. A stall-rule restore discards pages the stalled run accepted, and an escalated page can leave index edits (optional)

- Location: plan:659-662 (B3c resolution 8 step 3, "restore the tree to HEAD"), :607.
- Defect:
  - A multi-page batch that stalls may already hold accepted pages in the tree, with no lock entry
    because the run stopped. The restore throws them away, and the rule reruns only "the remaining
    pages".
  - `restore` leaves a shared index file alone when a sibling's link command changed it after this
    page's (page.go:358-367, friction "index-link: ... not restored"). R3's commit, which takes
    "their index edits", can then carry an escalated page's index edit.
- Fold: before a stall restore, STATUS lists each page `state.json` marks `accepted`, and the rerun
  includes them. Before a wave commit, the session greps each escalated page's `record.json` for
  `index-link:` friction and confirms that the index diff names only accepted pages.

### m9. Coverage misses carry their kind only in the text (correctness)

- Location: plan:345-346, :670-674 (Check 1 reads the kinds from `record.json`).
- Defect: `missFinding` puts the miss kind into `Text` only (steps.go:370-380), and finding 4's
  mapping keys on the miss's kind and reason. If A1 maps from `missRecord` but leaves
  `edits.Finding.Kind` empty, `record.json` shows a coverage-origin small exchange with no kinds,
  and Check 1 and the cairn PR's "kinds" column can't be read from the record.
- Fold: A1 sets `Kind` on each `missFinding` to the mapped review vocabulary (or the raw miss kind
  under a documented prefix), and a test asserts that the record carries it.

### m10. C4 and the R1 fix subagents don't name which `drafter` binary to run (correctness)

- Location: plan:544-546.
- Defect: C4 runs after A3, so B3c resolution 6's binary rule applies, but its acceptance says
  "`drafter check`". Nothing breaks today: the installed `611adbe` reads this config. But it's the
  ambiguity resolution 6 exists to remove.
- Fold: write `ACC check` in C4.

## Over-ceremony

### o1. Close 3 repeats Check 2 and Check 3 (optional)

- Location: plan:699-701 against :676-685.
- Defect: Check 2 says "at close" and Check 3 says "again at close", and Close 3 lists both again.
  A reader can't tell whether the gate rerun and `npm run package` run once or twice.
- Fold: Close 3 says "run Check 2's close rerun and Check 3 (once each)", plus the leak grep.

### o2. A3's `check-prompts --matrix` repeats `make check`'s parity run (optional)

- Location: plan:511-513.
- Defect: `make check` already runs `prompts-parity` over the same chain module and
  `blueprint-matrix.json` (Makefile:30-31, factsheet-pipeline section 10). A3 step 1 ran
  `make check` minutes earlier on the same head.
- Fold: drop it, or keep it only if the local layer's `inline_files` changes the rendering, and
  say so.

## Owner fork

### F1. How visible the self-labeled kind is (optional)

- Location: plan:85-96, :714-717.
- Context: the review seat labels its own findings. A round-2 finding of substance labeled `link`
  takes the small path, and at the round-2 origin no review seat re-reads the fix; only the reader
  does (plan:66-68). The design rules this, so it isn't a correctness gap. It's a question of how
  much of it Geoff sees.
- Options:
  1. The cairn PR lists every small-path finding verbatim with its kind and seat, from
     `record.json`.
  2. Only the counts per page.
  3. Nothing beyond the table's yes or no.
- Recommendation: option 1. It costs no spend, and it lets Geoff's read audit the labels on the
  pages it accepts.

## Checked and sound

- **States saved before the pass.** `edits.Finding` has no json tags (edits/types.go:8-15), so
  `Kind` decodes as "" from an old state. Every new work field can be `omitempty`. An old state
  never names a new phase or kind. The resume unmarshal doesn't refuse unknown fields
  (resume.go:171-176). Plan:372 tests this direction. The reverse, a new state resumed by an older
  binary, misroutes silently, and M5's fold covers it.
- **Partial lock writes.** `WriteLock` writes through `atomicfile` (lock.go). `updateLock` holds
  the worktree lock and reads the working-tree file (bar.go:46-66). `DecodeLock` refuses unknown
  fields and a wrong version, and `committedLock` refuses to read an undecodable lock as empty
  (bar.go:29-43).
- **The meter.** Each call's worst case is N × cap ≤ `left`, with reservations made before any
  send (money.go:86-130). `DRAFTER_PAGE_CAP` is read from the environment (config/env.go:84). A dry
  run and the stub render spend nothing.
- **Fingerprint and #26.** cairn's `drafter.toml` sets `[seat.draft] max_tokens = 128000` at
  `drafter.toml:24`, so finding 10 holds for cairn. Note that `gate.failure_pattern` is
  fingerprinted (fingerprint.go:27): a failure_pattern fix after C1 would also make stopped runs
  unresumable.
- **Goldens.** Only `TestRecordGolden` honors `UPDATE_GOLDEN` (flow2_test.go:602), so A1's
  regeneration can't move the two pinned read goldens.
- **Rotate.** `f:nls26c`, edited by C2, is cited outside the seven only by rotate. Rotate's entry
  holds a bar (factsheet-cairn section 7), so its next read is a bar read that covers the change.
  No gap there.
