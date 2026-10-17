# B1 plan review: data integrity and failure risk

Target: `plans/2026-10-17-drafter-b1-blueprint-format-plan.md` at `2e44160`. Code read at drafter
`d3447d9` (main) and cairn-cms `9754d6357` (main). Lens: crash, concurrency, partial write,
upgrade, resume, restore, money. Findings are ranked by consequence. Plan line numbers are the
plan file's.

## Summary

| # | Severity | Tag | Finding |
|---|---|---|---|
| 1 | blocker | correctness | The lock write on accept can't be recorded "as a drafter write" without editing `resume.go`, and an untracked lock change makes every resume refuse |
| 2 | major | correctness | Registering `blueprint` as a seat breaks `drafter page` and config loading in both directions of version skew, and can silently skip the read |
| 3 | major | correctness | The accepted hash can name bytes the read never saw |
| 4 | major | correctness | The lock's "commit drafter last wrote the page in" can't be known inside that commit; B1 freezes the field |
| 5 | major | correctness | B1.5 runs against the wrong prompts module and binary, and its worktree has no local config |
| 6 | major | correctness | The convert seed records a state that no commit holds; section hashes are undefined. Includes an OWNER FORK on call 15 |
| 7 | major | correctness | `drafter read` creates lock entries that `drafter check` then reports as errors |
| 8 | major | correctness | The consistency read isn't "unchanged": it decodes a v1 plan |
| 9 | minor | correctness | Live-run stop rules miss the page-cap escalation and exit-3 resumes; the meter isn't per branch |
| 10 | minor | correctness | The converter's never-overwrite rule and its lock seed have race and partial-write gaps |
| 11 | minor | correctness | B1.5 loop gaps: the lock commit, in-flight edits, fetch, and edits to existing facts |
| 12 | minor | optional | Dry run and lock-format follow-ups |
| 13 | minor | optional | Ceremony: the baseline gate, and a missing one-executor check at launch |

## Findings

### 1. blocker, correctness: the accept-time lock write can't be recorded without editing `resume.go`

Location: plan 296-298 ("records the write in state as a drafter write"), 302, 318, 322-323;
`internal/pipeline/page.go:53`, `internal/pipeline/resume.go:222-252`, `:254-303`, `:364-398`.

The defect: the state's write record is built for the page and its brief only.

- `files()` returns exactly `[page, brief]` (`page.go:53`).
- `finishWrite` reads `w.Saved[rel]` for each of those two paths (`resume.go:373-376`).
- `wantHashes` takes the last non-restore write's `Post[rel]` for the page's own files
  (`resume.go:238-247`).

Appending a `run.Write` that holds only `blueprints/drafted.lock` breaks both functions:

- `finishWrite` reads `filepath.Join(p.dir, "")`, the record directory itself, and fails.
- `wantHashes` returns `""` for the page, so `checkTree` refuses the page as "not as the run left
  it".

If the lock isn't recorded at all, `checkTree` refuses anyway. It refuses every changed path in
`git status` that isn't a page file or an index-link file: "changed and is not a file of this run"
(`resume.go:279-290`).

The plan has no unrecorded-lock path. Any stop after the lock write and before the run ends leaves
a run that can't resume until someone reverts the lock by hand. That includes these cases:

- a crash between the lock write and the `Restored` save
- a multi-blueprint run where page A was accepted and page B is still in batch

Every route the plan allows to make this work needs `resume.go`, which plan 49-51 makes a
line-stop. The B1.4 resume acceptance (318) stops before the accept, so it never exercises the
window.

A second hazard follows if the lock is made a page-owned file in a multi-page run. An escalated
page's restore writes back its own pre-run snapshot of the lock (`page.go:290-294`). That erases
another page's accepted entry from the same run, which is silent data loss.

Proposed fold:

- B1's `drafter read` takes exactly one blueprint per run. A second argument is a usage error
  (exit 2).
- A read page's `files()` is `[<root>/drafted.lock]`, not the page and brief. The read never
  writes them, so it should never snapshot or restore them (see finding 11).
- The lock write goes through a read-specific variant of `writeFiles` in `page.go`: it records
  `Pre`, saves the new bytes, writes them, and records `Post`. `finishWrite`, `wantHashes`, and
  `checkTree` then cover the lock generically, with no change to `resume.go`.
- Add two fake-API acceptance rows:
  - A crash after the lock write and before the state save. The resume ends accepted, with the
    lock written once.
  - A crash after the state records the write and before the lock rename. The resume rewrites
    the lock from the saved bytes.
- Record under "Later" that a multi-page lock writer belongs to B4, and that B4 touches
  `resume.go` under `auth-data`.

### 2. major, correctness: registering the seat breaks existing configs and can skip the read

Location: plan 272, 340; `internal/config/apply.go:29`, `internal/config/validate.go:36-46`,
`internal/config/check.go:96-99`, `internal/pipeline/fingerprint.go:19,38-44`,
`internal/pipeline/page.go:146-151`.

The defect: the default `seats` list is every name in `seatNames` (`apply.go:29`). `ScopeRun`
validation then requires `model`, `effort`, `max_tokens`, and a price for every seat in that list
(`validate.go:41-46`). Adding `blueprint` to `seatNames` breaks configs in both directions:

- New drafter on a project without `[seat.blueprint]`, such as cairn main, the e2e testdata, or
  any other project: `drafter page` exits 2.
- Old drafter, the `~/.local/bin/drafter` built from main, on cairn after its B1.5 PR merges:
  `[seat.blueprint]` "is not a seat" (`check.go:96-99`), so every drafter command on cairn exits 2.

Both checkouts break until both PRs merge and `make install` runs. The plan names no merge order.

`seats` and every `seat.*` key are in the resume fingerprint (`fingerprint.go:19,38-44`). Today
there are no stopped runs and no open reservations (`drafter spend --json` shows `open.count` 0).
Any run stopped across the upgrade would still refuse to resume.

There's also a silent-accept risk. If B1.4 gates the new stage with `p.runs("blueprint")`, as the
consistency stage is gated, a project whose `seats` omits `blueprint` would accept on the check
and consistency reads alone. The read would then write an accepted hash that no blueprint read
produced.

Proposed fold:

- Keep `blueprint` out of the default `seats`, and validate it only for `drafter read`.
- `drafter read` refuses to start (exit 2) when the `blueprint` seat isn't configured.
- An accepted hash is written only after a `blueprint` answer of `accept`.
- Add a test that `drafter page` on a config without `[seat.blueprint]` still validates.
- Close step 6 states the merge order: drafter's PR first, then `make install`, then cairn's PR.

### 3. major, correctness: the accepted hash can name a blueprint the read never saw

Location: plan 296-297, 349-356, 374; `internal/pipeline/money.go:462-480` (batch mode polls
in-process); `internal/pipeline/resume.go:96-108` (resume accepts any descendant HEAD).

The defect: a batch-mode `drafter read` holds the process for the whole batch, and B1.5 runs it as
a `run_in_background` task. The plan never says which bytes the accepted hash is computed from.

If the write hashes the blueprint on disk at accept time, an executor that edits and commits the
next round while the read is in flight gets that edit stamped as accepted. Nothing would catch it:
the tree is clean, and the blueprint isn't a file of the run.

The hash also covers the blueprint alone. The read's verdict depends on the outline entry and the
cited fact bullets too, and design call 5 counts a change to either as a page change. Design call 9
caches acceptance so that "an unchanged blueprint is never read twice". With a blueprint-only hash,
a fact or outline change after acceptance never triggers a re-read.

Proposed fold:

- The accepted hash is the hash of the blueprint bytes inlined into the request, captured when the
  request is built and kept in `work`. It's never re-read from disk at accept.
- The lock entry gets a second field, `acceptedInputs`: a hash over the blueprint bytes, the
  canonical outline entry, and the cited fact bullets.
- B1.5 states that the blueprint isn't edited while a read is in flight.
- Add a fake-API row: the blueprint changes on disk between build and answer, and the lock records
  the built bytes.

### 4. major, correctness: the lock's commit field can't be known inside the commit that holds it

Location: plan 148-151; design 157-160 and 379-380 ("Commit each accepted page with ... its lock
entry, one commit per page"); design 305-306 (`git show <lock commit>:<page>`).

The defect: a lock entry committed in the same commit as its page can't contain that commit's hash.
B1 defines `drafted.lock` v1, which design "Left to the builder" leaves to this pass. B3 and B4
then inherit an unfillable field, or a field that names the parent commit. The parent commit is
wrong for B4's hunk mapping, because `git show <parent>:<page>` returns the text before drafter's
draft.

Proposed fold:

- Store each page's and blueprint's git blob id (`git hash-object`) as its hash.
- The blob id is known before the commit, identifies the content, and retrieves it with
  `git cat-file blob <id>`, so B4 needs no commit field to diff a hand edit.
- Keep `commit` as informational, the base commit, or drop it.
- `docs/blueprint-format.md` states the rule.

### 5. major, correctness: B1.5 reads through the wrong module and binary, and has no local config

Location: plan 330-350; `~/.config/drafter/cairn-cms.local.toml:1`; `readlink -f
~/.claude/workflows/docs-page-chain.js` resolves to
`~/Projects/drafter/claude/.claude/workflows/docs-page-chain.js`, the main checkout;
`internal/config/load.go:76-101`; cairn `docs/STATUS.md:22`; cairn `.gitignore:33`.

The defect has three parts:

- A fresh cairn worktree has no `drafter.local.toml`. The file is ignored, and cairn's main
  checkout has none either. Without it, `prompts`, `inline_files`, and the agent definitions are
  unset, and `drafter read` exits 2. cairn's own STATUS says to copy `cairn-cms.local.toml` into
  the drafting worktree; the plan doesn't.
- Copied verbatim, its `prompts` path points through the symlink to drafter's main checkout. That
  module has no `blueprint` export, so the read fails to render. The tempting workaround is to edit
  drafter main, which plan 58 and the one-executor rule forbid.
- Steps 2 through 7 call bare `drafter`, which resolves to `~/.local/bin/drafter`, built from main,
  with no `convert`, `check`, or `read`. Running `make install` from the branch would swap the
  shared binary under any other session.

Proposed fold:

- B1.5 gets a step 0: copy `cairn-cms.local.toml` to `<cairn worktree>/drafter.local.toml` and set
  `prompts` to `<drafter worktree>/claude/.claude/workflows/docs-page-chain.js`.
- Confirm with `<drafter worktree>/drafter config --json` that `prompts` resolves into the worktree.
- Every B1.5 command names `<drafter worktree>/drafter` explicitly.
- `make install` waits until after merge.

### 6. major, correctness: the convert seed records a state no commit holds. Includes an OWNER FORK

Location: plan 247-249, 257, 342-347; design 178-181 and call 15 (585-586); plan resolution 5
(101-103).

The seed has four defects:

- Seed versus HEAD. The seed records "the current HEAD commit" with the page's working-tree hash.
  If the page differs from HEAD, the entry pairs a commit with content that commit doesn't hold,
  and B4's hunk mapping reads the wrong base. Fold: hash `git show HEAD:<page>` (the blob id from
  finding 4), or refuse when `git diff --quiet HEAD -- <page>` fails.
- An uncommitted blueprint hash. The blueprint hash is the converted, pre-reshape file, which is
  never committed: B1.5 reshapes it before the first commit (342-348). Fold: document that the
  seed's blueprint hash names the conversion output, and keep a copy beside the record or under
  `.git/`, so B3 can diff sections against it. If section diffs aren't needed for a seed, say so.
- Undefined section hashes. Neither the plan nor the design defines a section hash. Three things
  are open: whether a level-2 section's hash includes its level-3 children, how the text before
  the first heading is treated, and what an unmatched heading on either side records. Ids can
  also change during the reshape, which strands the seeded keys. Whatever B1 writes, B3 must
  reproduce byte for byte. Fold: define the hash in `docs/blueprint-format.md`. The range runs
  from the heading line to the next heading of the same or higher level, children included. An
  `_intro` key covers the text before the first `##`. A section with no match gets no key, and a
  missing key reads as changed. The B1.3 fixture test asserts each rule.
- OWNER FORK, call 15 against resolution 5. Resolution 5 makes every converted blueprint fail
  `check` until someone writes each `why`. So every converted blueprint changes after its seed,
  and at B4 every converted page reads as "blueprint changed" and is redrafted once. Call 15
  promised "redrafted only when its blueprint changes" and "at no cost". Mechanically the promise
  holds, but in practice every page redrafts. At $3 to $4.50 a page, that's roughly $35 to $50
  for the 11 stage 2b pages, spent in the first nights. The options:
  - (a) Accept it. Every converted page redrafts once, and the pilot's content fixes need that
    anyway. Amend the call 15 wording in the B1 docs.
  - (b) `drafter read`, on first accept of a page whose lock entry is still a conversion seed,
    moves the seed's blueprint hash to the accepted blueprint. A reshape then costs nothing, but
    real content fixes, such as the pilot's missing deploy step, never reach the page until the
    blueprint next changes.
  - (c) A separate `drafter lock --reseed <page>` that a person runs after a purely formal
    reshape.

  Recommendation: (a). It costs little next to the $160 cycle, and (b) silently drops the pilot's
  own blocking fixes.

### 7. major, correctness: `drafter read` writes lock entries that `drafter check` rejects

Location: plan 203 ("every page it names exists") against 298 ("The page entry is created if
missing").

The defect: reading a blueprint for a page that doesn't exist yet creates a lock entry for a
missing page. `drafter check` then errors on it, and once B5 adds `check` to cairn's gate, CI goes
red. The pilot page exists (`docs/extend/rotate-the-github-app-key.md`), so B1.5 won't hit this. B2's
new-page path and B3 will.

Proposed fold:

- An entry with only the accepted fields means the page was never drafted. `check` allows such an
  entry for a missing page when the outline lists the page.
- Add a failing fixture and a passing twin to B1.2.
- `docs/blueprint-format.md` states how B3 and B4 read an entry with no commit.

### 8. major, correctness: the consistency read can't run on a blueprint unchanged

Location: plan 269-270 ("the consistency read ... unchanged"); `internal/pipeline/steps.go:173-177`,
`internal/pipeline/page.go:156-170`.

The defect: `stageConsistency` calls `p.planDoc()`, which decodes the file at `h.Plan` with
`plan.Decode`. A blueprint carries `framing`, section `id`, `why`, and `example`, so it fails v1
decode. The stage then returns "plan ... does not decode". The failure falls after the local check
and before any reservation, so no money is lost, but every read on a project with a facts store
fails. That includes cairn.

Proposed fold: B1.4 builds the `*plan.Plan` view that `assemble.ConsistencyPrompt` needs from the
decoded blueprint, or makes the prompt take the shared fields. Add it to B1.4's files and to a
fake-API row with a facts store present.

### 9. minor, correctness: live-run stop rules have gaps

Location: plan 72-77, 330-331, 360; `internal/pipeline/money.go:121-123`;
`internal/ledger/ledger.go:123`; `internal/smoke/live_test.go:39-40`; `cmd/drafter/spend.go:89`.

The rules have four gaps:

- Page cap. A reservation over the page cap doesn't exit 3. It escalates the page with rule `cap`
  and exits 1 (`money.go:122-123`). The B1.5 loop reads exit 1 as a `fix` round, so it would
  count a cap stop as a read round and look for findings. The pipeline spec's pilot criterion 3
  also requires that no record end with `cap`. Fold: exit 1 with rule `cap` stops for Geoff, like
  `cycle cap`.
- Exit 3 for transport or infrastructure. The plan doesn't say what to do with it. If the executor
  starts a new run instead of resuming, the old batch still bills, and its reservation sits in
  `open.worst` until adopted. Fold: run `drafter read --resume <run-id>` once, and stop for Geoff
  on a second exit 3.
- The smoke. Step 1 runs the smoke without `DRAFTER_PAGE_CAP`. The smoke takes its cap from
  config (`live_test.go:39-40`), and the user layer has `page_cap = 10`. The measured smoke cost
  is $0.001, so the risk is small. Fold: set the variable anyway, for uniformity with plan 73-74.
- The meter's scope. `drafter spend` reads the one user ledger (`spend.go:89`), so the meter covers
  every drafter spend since 2026-10-17, not "this branch's". That makes it conservative, which is
  safe. Fold: reword plan 72-73.

The cap arithmetic itself holds. The page cap is per run and per page (`ledger.go:123`), and one
blueprint runs per run, so a run spends at most `min(5, 10 - meter)`, and the sum stays at or under
$10.

### 10. minor, correctness: the converter's never-overwrite rule and lock seed have gaps

Location: plan 238, 247-249, 260; `internal/atomicfile/atomicfile.go` (`os.Rename` over the
target).

The defect has three parts:

- `atomicfile.WriteFile` replaces any existing file. A check-then-write is a race, so
  never-overwrite needs an exclusive create, either `os.OpenFile` with `O_EXCL` or `os.Link` of the
  temporary file.
- The seed doesn't say what happens to an existing lock entry for the page. Overwriting it would
  erase an entry drafter wrote.
- `convert` takes no worktree lock, so a concurrent `drafter read` in the same worktree could lose
  one of the two lock writes.

There's also a crash window between the blueprint write and the lock write. It leaves a blueprint
with no seed, and a rerun then refuses because the blueprint exists.

Proposed fold:

- Create the blueprint exclusively.
- Refuse when the lock already has an entry for the page.
- Take `<git dir>/drafter.lock` (`start.go:104-115`) for the seed.
- Document the recovery: conversion is free and deterministic, so delete the blueprint and rerun.
- Add an acceptance row for an existing lock entry.

### 11. minor, correctness: B1.5 loop gaps

Location: plan 328-376.

There are five gaps:

- The lock after accept. Accept leaves `blueprints/drafted.lock` modified. Acceptance 374 compares
  it with "the committed blueprint's hash", but no step commits the lock, so the cairn PR could
  ship without the accepted entry. Fold: commit the lock after the accepting run.
- A stale `origin/main`. Plan 57 runs `worktree add ... origin/main` with no fetch first. Fold:
  `git -C ~/Projects/cairn-cms fetch origin` first.
- Editing during a read. Nothing forbids editing the blueprint while a read is in flight (see
  finding 3). Fold: say so in step 6.
- Edits to existing facts. Only new facts are covered. A blocking finding that shows an existing
  verified fact is wrong has no rule. Editing it changes every page that cites it, under call 5,
  including the other 10 stage 2b plans. Fold: an existing fact found wrong goes to Geoff as a
  "Found, not done" item and isn't edited in B1.5.
- Restoring a page the read never wrote. Under today's `files()`, an escalated read restores the
  page and brief from their snapshots (`page.go:272-310`). The read never wrote them, so a
  concurrent hand edit made in the worktree during a long batch would be overwritten. Finding 1's
  fold removes this.

### 12. minor, optional: the dry-run estimate and the lock format

Location: plan 319; fact sheet 81 (`dry.go:15-52` estimates only the first stage).

The defect has two parts:

- With a facts store, the first stage is consistency, so `--dry-run` never prices the blueprint
  read, and the cap can't be planned from it. Fold: print each stage-1 request's worst case, or
  note the limit in B1.5.
- One sorted lock file for every page means git merge conflicts whenever two branches touch
  adjacent entries, and B4 rebases nightly. Fold: since B1 fixes the format, make each entry one
  self-contained block with a blank line between entries. Line merges then rarely collide.

### 13. minor, optional: ceremony and the launch check

Location: plan 63-64, 80-82.

- The baseline gate. It reruns `make check` on a worktree identical to `d3447d9`, whose gate
  passed at the #42 merge. That costs one full gate, a few minutes of clock and no model tokens.
  It's cheap insurance and can stay. If kept, the plan should cite it as the B1.4 diff baseline.
- The one-executor check. The launch check has none. Both repos carry a locked
  `repo-organization` worktree, and drafter carries 13 stale `agent-*` worktrees. Add `git
  worktree list`, `pgrep -f`, and a warm-change check to "Depends on, checked at launch", per the
  global one-executor rule. This costs nothing at launch and prevents a race.

## Claims checked and confirmed

- "A new stage needs no change to `money.go` or `resume.go`" holds for the request and settle
  path. Neither file names a seat or step, and `seatOf` parses `custom_id` part 3, so `blueprint`,
  which has no `_`, is safe (`money.go:29-35`, `steps.go:48`). The claim fails only for the lock
  write's state tracking (finding 1). It also needs `rehydrate`'s handoff contract
  (`resume.go:154-186`): the read must build a `handoff.Handoff` whose `Plan` is the blueprint
  path, so that `Verify` checksums the blueprint on resume (`handoff.go:165-189`). Add that line
  to B1.4.
- Clean-tree refusal (`start.go:87-101`) and the worktree lock (`start.go:104-115`) apply to
  `drafter read` unchanged.
- The atomic state save (`run/state.go:133-143`) and the append-only ledger reserve under a lock
  (`ledger.go:108-143`) need nothing new.
- There are no stopped runs and no open reservations today. `~/.local/state/drafter` holds no
  `runs/`, and the ledger total is $0.001.
