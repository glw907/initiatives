# skill-rules plan review: data integrity and failure risk

Reviewer: fresh context, lens data integrity and failure risk, 2026-10-18. Read-only.
Plan: `plans/2026-10-18-drafter-skill-rules-plan.md` (uncommitted). Design:
`specs/2026-10-18-drafter-skill-rules-design.md`. Code: drafter `main` `0a7a30b`; cairn-cms
`50dc211d9` read through `git show` only. Harness: `~/.claude/jobs/e63b19d8/tmp/ft/` (141 files,
present).

Counts: 0 blocker, 7 major, 8 minor, 2 owner forks (one inside M5, one standalone).

## Major

### M1. The settled pair rule isn't in the plan (correctness)

- Location: plan:100-117 (resolutions 2 and 3), plan:287-318 (SR.3; acceptance at 315, "one file,
  one line changed"), plan:330-331 (row header "plus one bullet"), plan:378-379 ("Later" defers the
  other pairs); design:49-52 (Outcome 4, one bullet).
- Defect: the settled answer has the executor check every base conflict pair the reads have named
  that a prompt can touch, and correct each pair that cairn's code proves wrong. The plan checks
  only `f:sszb7b`/`f:vg42j3` and defers the rest. Several are in reach. In the base blueprint,
  `f:vg42j3` and `f:1pb077` are cited in `verify-the-new-key`, which prompts 6 and 7 edit, and
  `f:86h9o6`/`f:olofdb` are cited in `push-the-new-key-to-the-worker`. SR.3's one-line acceptance
  would fail an executor that follows the settled rule, and the rows' "plus one bullet" header would
  misstate the base.
- Fold: in SR.3, add step 2b. List the pairs the named runs flagged: the four in "Later" plus the
  main pair. Keep each pair that has a fact cited in a section that one of the seven prompts' correct
  edits lands in. For each kept pair, read the code its `[verified]` side cites. Correct a bullet
  only when the code contradicts it. Record every unproven pair as present at base, so standing
  answer 3 applies. Change the acceptance to "one changed line per corrected bullet in
  `docs/internal/facts/extend.md`, nothing else". Change the row header to "`50dc211d9` plus the
  corrected bullets (ids listed)". Give each correction its own "For cairn's backlog" entry. Row 0
  covers all of them. Remove the "Later" bullet for each pair that SR.3 settles.

### M2. Evidence and session spend live on tmpfs in one session's scratchpad (correctness)

- Location: plan:76-78 (the harness is copied into the scratchpad), plan:235-236, plan:309,
  plan:330.
- Defect: `/tmp` is tmpfs, and a scratchpad belongs to one session. If the executor dies, the
  session restarts, or the machine reboots partway through SR.4, the rows, the streams, the
  `<base'>` show, and `sessions.txt` are lost or orphaned. `sessions.txt` holds the only record of
  the headless sessions' cost, because drafter's ledger doesn't hold that cost. A resumed session
  would undercount spend and could run past $20. It would also redo runs it can't see. #48 kept its
  harness in a durable job directory, which is why it survives today.
- Fold: keep the harness and every output in a durable directory outside every repo, for example
  `~/.claude/jobs/<this pass>/ft/`, as #48 did. Name it in the STATUS launch prompt. Before any
  dispatch, a resumed session reads `sessions.txt` and the rows table from there.

### M3. The reused harness carries stale constants beyond `BASE` and `DWT` (correctness)

- Location: plan:74-78, plan:199-200.
- Defect: every script hardcodes `OUT=/var/home/glw907/.claude/jobs/e63b19d8/tmp/ft`. A copy left
  unedited writes into #48's directory, where it overwrites #48's `c1.*`, `c2.*`, and `probe.*`
  evidence and splits this pass's rows across two places. `read.sh` has its own
  `BASE=$(git -C "$WT" rev-parse 50dc211d9)` and `DWT=.../change-read`. The locked change-read
  worktree still holds a built `drafter` binary from 13:10, so a stale `read.sh` runs silently: it
  reads without SR.1's rule, and `--since 50dc211d9` puts the corrected bullet into the change as a
  touched fact bullet. `control.sh` resets to `50dc211d9` and re-seeds through `control.py`, whose
  path also points at the old directory. `base.sh` shows `50dc211d9`. `spend.py` has
  `BASE = 3.1758…` and sums the old `sessions.txt`, which already holds $2.22 from #48. `tweak.sh`
  runs no `git clean` and doesn't check HEAD before a run, though resolution 7 (plan:208-210)
  requires both. The plan's fallback covers only a harness that is entirely gone, not one that is
  partly gone.
- Fold: after copying, rewrite `OUT`, `DWT`, and `BASE` in every `*.sh` and `*.py`. Point
  `spend.py` at the new `sessions.txt`, start that file empty, and set the launch baseline. Add
  `git clean -fdq` and a `rev-parse HEAD` check to `tweak.sh`. Then gate the copy: running
  `grep -n 'change-read\|50dc211d9\|e63b19d8' <dir>/*.sh <dir>/*.py` prints nothing. Check each
  listed file one by one. Rebuild a missing script from resolution 8. Take a missing `p*.txt` from
  #48's PR body. Re-seed a missing `c*.patch` through `control.py` and mark its row "re-seeded".

### M4. A session can edit the drafter files under test, and no check sees it (correctness)

- Location: plan:200-204 (session flags), plan:211-214 (after-run checks).
- Defect: each session runs with `--permission-mode acceptEdits`, `--add-dir <drafter wt>/docs`, and
  `--add-dir ~/.claude/skills/blueprint`. During SR.4 that link resolves to the drafter worktree's
  skill directory. A session can therefore edit `docs/blueprint-format.md` or `SKILL.md`, the very
  files the test measures, with no prompt. The edit would carry into every later run and into the
  PR. The after-run checks cover only the two main checkouts.
- Fold: after each run, check that `git -C <drafter wt> status --porcelain` is empty and that the
  worktree's HEAD hasn't changed. Anything else is a breach. Restore the files with `git -C <drafter
  wt> checkout -- .` before the next run, and record the breach on the row.

### M5. An "Unplaced:" warning can hide a conflict the change introduced, and grading never sees it (correctness, OWNER FORK)

- Location: plan:82-99 (resolution 1), plan:218-222 (grading), plan:336.
- Defect: tweak 4 shows how this happens. The model described a real conflict in prose and left
  `facts` and `with` empty. Under SR.1, that answer becomes a warning and never blocks. The grade
  says "An 'Unplaced:' warning never fails a run", and the plan classifies only "Already present:"
  findings and escalated conflicts against `<base'>`. A conflict that the change introduces and the
  model reports this way therefore passes, and the rate goes up. The warnings are also hard to see.
  The `--json` summary carries only `demoted`, which counts both kinds without telling them apart
  (`pipeline.go:93-96`), and the warning text lives only in
  `~/.local/state/drafter/runs/cairn-cms/<run_id>/<page key>/record.json`. `read.sh` captures
  neither. Run directories are also pruned after the retention period (`start.go:121`).
- Fold: for each run, read the record's warnings from that `record.json` path and copy each
  "Unplaced:" text into the row. Classify it the way the plan classifies "Already present:": present
  at base, or introduced by the diff, judged from the conflict's prose against the diff.
- OWNER FORK: how does an introduced "Unplaced:" count?
  - (a) It counts as a miss, the same rule as an introduced "Already present:". **Recommended**:
    the test measures the skill, and the read's leniency shouldn't raise the score.
  - (b) It passes and is listed on its own line.
  - (c) It passes silently, which is the plan today.
  Optional, product side: the backlog #6 entry should note that `--json` can't tell an unplaced
  conflict from an already-present one.

### M6. The spend meter misses open reservations and sessions that died (correctness)

- Location: plan:41-50 (standing answer 4); the harness's `spend.py`.
- Defect: the `total` in `drafter spend --json` is settled cost only. Open intents are reported
  apart (`ledger.go:213` against `ledger.go:222-224`). If a read is killed after it reserves, the
  billed cost sits in `open.worst`, and the plan's meter doesn't count it. `spend.py` prints `open`
  but doesn't add it. A headless session that is killed or crashes writes no `result` event, so its
  `total_cost_usd` is never added.
- Fold: meter = `total + open.worst - baseline` + sessions. Charge any session whose stream has no
  `result` event at $0.75, the plan's own margin, and note that on its row.

### M7. A tool timeout can kill a run or orphan it, and the plan never handles it (correctness)

- Location: plan:46-49 (the resume rule is keyed on exit 3); the harness's `tweak.sh` and
  `read.sh`.
- Defect: `tweak.sh` runs `claude -p` in the foreground. The Bash tool's timeout (2 minutes by
  default, 10 at most) can kill the script and leave the `claude -p` child running. That child
  could then edit or commit in the worktree after the next run's reset, which mixes two runs. A
  killed `read.sh` writes no `.read.exit` and no JSON, so the resume rule never fires, and the run
  id is unknown.
- Fold: run each script with `run_in_background`, and wrap the session in `timeout 900 claude -p
  …`. Before each reset, confirm the previous script's exit file exists. If a read has no exit
  file, take the newest directory under `~/.local/state/drafter/runs/cairn-cms/` whose
  `state.json` head is the run's commit, and give it the one resume that exit 3 gets.

## Minor

### m8. A reset before a resume makes the resume fail (correctness)

- Location: plan:46-49.
- Defect: `checkPosition` (`resume.go:96-110`) needs the same branch, with HEAD at or after the
  run's head. If the worktree is reset to `<base'>` first, the resume fails, and with the "a second
  stops" rule that halts the test.
- Fold: add one sentence: resume before the next reset, and never reset while a stopped read is
  outstanding. Also say that "a second stops" means the test stops for Geoff, with the skill link
  restored.

### m9. The one-commit check accepts an amended base (correctness)

- Location: plan:211.
- Defect: `Bash(git *)` lets a session run `git commit --amend` on `<base'>`, and
  `rev-list --count <base'>..HEAD` would still print 1. The read's `--since <base'>` would then grade
  a change that reverts the corrected bullet.
- Fold: also check that `git rev-parse HEAD^` is `<base'>`.

### m10. A push or a commit on main can slip past the checks (correctness)

- Location: plan:200-204, plan:209-212.
- Defect: the deny rule `Bash(git push *)` doesn't match `git -C <dir> push …`, and `Bash(git *)`
  allows that command. A plain `git push origin format-test` sets no upstream, so the "no upstream"
  check misses it, and cairn-cms is public. `git status --porcelain` stays empty after a commit made
  on a main checkout through `git -C`.
- Fold: keep the flags exactly as #48's. After each run and at SR.4's end, check that `git -C <cairn
  wt> ls-remote --heads origin format-test` prints nothing. Record each main checkout's
  `rev-parse HEAD` and branch before and after each run, beside `status`.

### m11. "Restored on every stop path" can't hold when the executor dies (correctness)

- Location: plan:231-234, plan:342, plan:367-369.
- Defect: if the executor crashes, nothing restores the link. It keeps pointing at the drafter
  worktree, and every other session on the workstation gets the skill under test. If that worktree
  is removed before merge row 1 runs `make install`, the link dangles and the skill disappears.
  `ln -sf` without `-n` writes a new `blueprint` link inside the main checkout's skill directory,
  which leaves an untracked file in the public repo. `readlink` catches that only because the swap
  then never happened.
- Fold: write "skill link swapped to <wt>" into the STATUS note when the swap happens. Any session
  that resumes the pass, and the conductor before it removes the drafter worktree, runs `readlink
  -f` and restores the link. Name `ln -sfn` in the plan. After a stop for Geoff, re-swap the link
  and confirm it before the next run.

### m12. Ignored files survive the reset (optional)

- Location: plan:208-210.
- Defect: `git clean -fd` without `-x` keeps every ignored file, not only `drafter.local.toml`. An
  ignored file that a session creates carries into the next run.
- Fold: record `git status --porcelain --ignored` once after the worktree is created. After each
  reset, compare against that record, and remove any extra path by name.

### m13. Deleting the branch loses the correction text (optional)

- Location: plan:115-117, plan:309, plan:343-344.
- Defect: the PR body quotes no bullet text, the scratchpad copy of `git show <base'>` sits on
  tmpfs, and `branch -D format-test` deletes the commit. The later fix on cairn's main would have to
  redo the work.
- Fold: save `git format-patch -1 <base'>` in the durable job directory from M2, and name it in
  merge row 2.

### m14. A stop partway can leave control 1 unrun, so the bar can't be judged (optional)

- Location: plan:223-230.
- Defect: the plan doesn't place the controls, and the bar depends on control 1.
- Fold: run control 1 right after the probe, before round a. Run control 2 after round c.

### m15. The PR body could carry workstation paths (correctness)

- Location: plan:332-334 (the row field "files read outside the worktree"), plan:358-360.
- Defect: stream paths are absolute (`/var/home/glw907/…`), and glw907/drafter is public. #48's
  body had none, but the plan doesn't say so.
- Fold: rows name paths relative to the worktree or by role. Before opening the PR, check that
  `grep -n '/var/home\|\.local/\|jobs/'` on the body prints nothing.

## Owner fork (standalone)

### F2. Does an infrastructure failure count as a miss?

- Location: plan:211-214 ("Anything else is a protocol breach and a miss"); design:56-57 ("first
  try, by the raw count").
- Defect: a session that ends on an API error, a rate limit, or a missing `result` event scores as
  a skill miss. That mixes outages into the rate.
- Options:
  - (a) Rerun once, mark the row "rerun (infra)", and keep the failed attempt visible.
    **Recommended**: the raw count was meant to rule out retrying skill work, not outages.
  - (b) Count it as a miss, the strict raw count.

## Checked and sound

- Run directories are written to `~/.local/state/drafter/runs/cairn-cms/`. `run.Repo` uses the main
  checkout's base name (`id.go:40-50`), so the reset and the clean never touch them.
- The worktree lock (`drafter.lock` in the worktree's git directory) and `run.lock` are `flock`
  locks (`lock.go:26`), so a dead process frees them.
- The corrected bullet lives in the `<base'>` commit, so `reset --hard <base'>` keeps it.
  `drafted.lock` is tracked, so the reset reverts it. A prior run's commit drops off the branch.
- Fact ids are written into each bullet (`` `f:sszb7b` ``), not derived from its text, so the
  correction keeps the id.
- `drafter.local.toml` is ignored in cairn (`.gitignore:33`), and its keys hold paths, not secrets.
- No over-ceremony is worth cutting. The per-run checks are cheap and each one catches a real
  failure.
