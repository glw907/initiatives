# Plan review: data integrity and failure risk

Target: `plans/2026-10-20-drafter-blueprint-first-plan.md` (uncommitted), with its executor and
conductor prompts. Checked against drafter `6a42564` and cairn-cms `52b3f979e`. Lens: crash,
concurrency, partial write, upgrade, restore, API drop, compaction, lock corruption, a lapse that
should fire and doesn't (or fires forever), an accept no read judged, and money outside the $45 or
the meter.

Counts: 0 blockers, 10 major, 7 minor (2 of them over-ceremony). One OWNER FORK (finding 8).

## Major

### 1. The accept short-circuits never write `facts` onto an entry whose `accepted` already matches

- Severity: major. Tag: `correctness`.
- Location: plan:590-592 and :615-617 (D2's writes and tests); code `cmd/drafter/bar.go:91`
  (`if e.Accepted == r.Accepted { continue }`) and `:96` (`if e.Accepted == r.Accepted && e.Blocked == nil { continue }`).
- Defect: `recordReads` skips the write whenever `accepted` is unchanged. After R2, the five entries
  that R2 accepted (using, second, add-cairn, debug, security) hold `accepted` equal to their blob and
  no `facts`. M2's whole read accepts with the same blob id, hits `:96`, and writes nothing. The entry
  never gains `facts`, so every later `drafter read` reads it whole again and `drafter page` refuses
  it every time: a lapse that fires forever, and a fresh charge on each E round. D2's test row "a
  whole accept writes both fields" passes from an empty entry and misses this case. E's check-after
  would find it, but only after a round of reads had been spent.
- Fold: in D2's build, both short-circuits also compare `facts`. The skip happens only when
  `accepted`, `blocked`, and the `facts` map all equal what the write would set. Add a test row: "an
  entry with `accepted` equal to the blob and no `facts`; a whole read accepts; the lock gains
  `facts`, and a second `drafter read` is not a lapse read."

### 2. A lapse accept is a scoped accept to `scopedAccept`, and `scopedRefusal` always refuses it

- Severity: major. Tag: `correctness`.
- Location: plan:590-598 (D2's lapse read and "a lapse accept writes `facts` and leaves
  `accepted`"), finding 12 (plan:146-151); code `cmd/drafter/read.go:395` (`scopedAccept`),
  `:522-538` (`scopeBases` needs `r.Since`), `bar.go:118-131`.
- Defect: the plan sets a lapse read's scope "as a change", which makes it scoped, with no
  `BarFrom`. `scopedAccept(r)` returns true. `scopeBases` skips the page because a lapse read has no
  `Since` commit, so its base is "". `scopedRefusal` then refuses ("the blueprint it accepted is not
  the one at the scoped read's base"). Finding 12's new third clause, "facts equals the map at the
  base", fails by definition on a lapse read. The likely implementation therefore keeps the stale
  map, and the lapse never clears. This hits every citer that standing answer 8 sends through E and
  B. K step 3 does not catch it, because there the lapse read blocks.
- Fold: give the lapse read its own marker, for example `PageResult.Lapse` set where D2 builds the
  lapse scope. `recordReads` takes a `Lapse` accept in its own case, before `scopedAccept`: write
  `facts` and keep `accepted`, valid only while `accepted` still equals the blob at start. Add one CLI
  test: a stub answers accept to a lapse read; the lock's `facts` updates; the next `drafter read` is
  a whole read, not a lapse read; and `drafter page --dry-run` prints no lapse line.

### 3. rotate's pre-seat bar lets a bar accept certify facts that no fact-truth read judged

- Severity: major. Tag: `correctness`.
- Location: finding 11 (plan:140-145: a bar read covers the changed facts plus the bar's
  `facttruth` findings), D2 (plan:590: "a whole or bar accept writes `accepted` and `facts`");
  factsheet-cairn section 1 (rotate's bar at `fd90da8d8`, written before the seat existed).
- Defect: a bar read only re-judges the facts that changed since the bar. That is sound for a bar
  that a seat-aware whole read wrote, because that read judged every fact. rotate's bar predates the
  seat, so no fact-truth read ever judged rotate's unchanged facts. If rotate's bar read accepts in
  E, which runs on M2's binary, the lock records a full `facts` map for facts no read saw. That is an
  accept for something no read judged. (In R2 on M1's binary, an accept writes no `facts`, so rotate
  reads whole later, but R2 most likely leaves the old bar in place.)
- Fold, in D2: a bar none of whose findings carries a `seat` predates the fact-truth seat. Treat it
  as `applyBar` treats a bar whose commit is gone: read the page whole and drop the bar. This needs
  D1 to set `seat` on every finding, the blueprint and consistency seats included. State that in D1,
  because the plan only says the field is `omitempty`. Add one test row.

### 4. K step 2 runs a live, uncapped, unmetered `drafter page` on a page with no drafted entry

- Severity: major. Tag: `correctness`.
- Location: plan:880-884 (K step 1.2). The design says no `drafter page` run spends anything.
- Defect: the call carries no `DRAFTER_PAGE_CAP`, takes no meter reading beforehand, and has no
  `--dry-run`. tidy's lock entry has no `page`, so if the lapse refusal has a bug (for example finding
  1 or 2, or a hash drift), `drafter page` drafts the whole page under the config's $10 cap. That
  spend falls outside the meter's cap rule, and the draft overwrites the live
  `docs/extend/turn-on-tidy.md` in the worktree. M2's refusal test ran on debug with `--dry-run`, so
  it doesn't cover tidy's path.
- Fold: run `BIN page --dry-run --json docs/extend/turn-on-tidy.md` first. The live call runs only
  if the dry run refuses with the lapse line, and it runs with `DRAFTER_PAGE_CAP=0.01`, so any
  reservation escalates on the cap before a request goes out. Take a meter reading before and after.

### 5. `spend --since <that minute>` is not a valid command, and spend has no per-call "row"

- Severity: major. Tag: `correctness`.
- Location: plan:758-759 (M2 step 2) and :884 (K); design "Check" step 2. Code:
  `cmd/drafter/spend.go:38,66` (`--since` takes a UTC `YYYY-MM-DD` only); `internal/ledger/ledger.go:189-228`
  (rows are summed by repo and seat).
- Defect: the command exits with a usage error. Even with a date, "no new row" can't show that one
  call spent nothing, because rows are per repo and seat totals. The proof that the refusal spends
  nothing, which is one of the design's three check rows, can't be taken as the plan writes it.
- Fold: just before the call, record `total`, `open.count`, and `open.worst` from
  `BIN spend --since 2026-10-20 --json`. Just after it, all three must be unchanged.

### 6. The R2 tuning rerun is held by R2's own bar and sends no request

- Severity: major. Tag: `correctness`.
- Location: standing answer 3 (plan:283-285, rerun "the blueprint holding a false block"), R2 step 1
  (plan:702, the lock is committed at once); code `bar.go:191-207` (`applyBar` returns `heldPage` on
  `ScopeUnchanged`).
- Defect: a page R2 blocked on gets a bar at R2's start commit, and the session commits that bar.
  A rerun in the cairn worktree with no blueprint change is held: no request, no verdict. The "zero
  false blocks at main after tuning" bar then can't be re-measured. R1 and R3 avoid this because
  they restore the lock after each run; R2 does not.
- Fold: rerun the false-block blueprints in a scratch worktree detached at R2's head, with the lock
  restored to its pre-R2 bytes (`git checkout <R2 head>~1 -- blueprints/drafted.lock`, then restore
  again afterward), the same pattern as R1. The bar in the real worktree self-heals in E, because a
  bar read re-sends the bar's `facttruth` fact ids to the tuned seat.

### 7. The `facts` map comes from facts on disk, which a resume reloads at a later HEAD

- Severity: major. Tag: `correctness`.
- Location: D2 (plan:586-589: `PageResult.Facts` is built "from the facts the run loaded at its
  start"); code `internal/pipeline/start.go:176-179` and `resume.go:73-76` (`LoadFacts` from the
  working tree); `resume.go:104` (a resume accepts any HEAD that descends from the start commit).
- Defect: commit a fact edit between a stop and its `--resume`, and the resumed run hashes the new
  bullets, even though the requests sent before the stop judged the old ones. The result is an accept
  of bullets no read saw. `resume.go` may not be edited. Separately, the plan computes the map in
  three places (the writer, `drafter read`'s lapse check, and `drafter page`'s refusal) without
  naming one source. If any two drift (disk against `git show`, or `Get` against all bullets of an
  id), the lapse fires forever.
- Fold: one function, `blueprint.FactsMap(root, rev, bp)`, parses facts at a commit through
  `revisionAt`'s git path, and all three callers use it at the run's start commit. In `cmd/drafter`
  (not `resume.go`), `--resume` refuses when `git diff --quiet <state head> HEAD -- <facts dir>`
  fails. Add to the run rules: no commit in a worktree between a stop and its resume.

### 8. A `drafter page` run can write a `facts` map no fact-truth read judged (OWNER FORK on the residual)

- Severity: major. Tag: `correctness`.
- Location: D2 (plan:590-592: "a whole or bar accept writes `accepted` and `facts`", applied inside
  `recordDrafted`); D1 (plan:458: `drafter page` never sends the seat); code `pagebp.go:186-199`
  (`recordDrafted` calls `recordReads`), `draftscope.go:93-100` (a page with a stale `accepted` and a
  bar reads inside `drafter page`).
- Defect: a `drafter page` call on rotate, or on any entry whose `accepted` is stale, runs an in-page
  bar or whole read with no fact-truth seat. Under D2's rule, its accept writes a full `facts` map.
  D2's refusal fires only when `accepted` equals the blob, so drafting a page with a stale accept
  stays open. The design's Outcome says drafter refuses to draft a page whose blueprint is not
  dependable. This pass drafts nothing, so the money risk lands on the drafting pass.
- Fold, for this pass: only `drafter read` results carry `Facts`. A `drafter page` accept leaves the
  entry's `facts` as it was, so an unjudged change lapses on the next `drafter read`.
- OWNER FORK, the residual (a stale-accept page drafting inside `drafter page` with no fact-truth
  seat):
  - (a) This pass makes `drafter page` refuse any page that lacks a current accept with a matching
    map. That is strict, matches the Outcome, and leaves `drafter page`'s in-page reads unreachable.
  - (b) Keep D2's narrow refusal plus the fold above, and name the residual as an entry condition of
    the drafting pass.
  - Recommendation: (b). No draft runs here, the drafting pass is designed from this pass's record,
    and (a) changes `drafter page` beyond the design's text. Record it in `## Decisions`.

### 9. The close never re-verifies the nine accepts at the close head

- Severity: major. Tag: `correctness`.
- Location: E's check-after (plan:794-797, run before B), standing answer 8, B step 3, Close step 3
  (plan:944-945); Merge order 2 (plan:984-986, the first check after E).
- Defect: B's tidy fact edits, fixes from the close review, and any later fact touch can lapse
  accepts that E recorded. The PR's "eight's table" and the packet then tell Geoff "accepted" while
  the lock says lapsed. The plan first checks again after the merge to `main`, which is too late to
  fix it on the branch.
- Fold: add a Close step before the push. Run `BIN page --dry-run --json` over the eight's and tidy's
  page paths. Every page the table reports as accepted must print no lapse line. A lapsed page reads
  inside the budget or is reported as open.

### 10. The budget has no reserve for B, and worst-case reservations make the cap bind early

- Severity: major. Tag: `correctness`.
- Location: the meter and its table (plan:324-350); standing answers 3, 5, and 6.
- Defect: the table's high ends sum to $42, and tuning adds up to $10, so $52 against a $45 hard
  ceiling. M2 also re-reads the five R2 accepts whole just to stamp `facts`; the table should name
  that as a line (about $3 to $5). E runs before B and nothing caps it. B "takes the rounds it needs"
  and "may not escalate", so if E drains the budget, the pass stops and asks partway through the one
  deliverable the design ranks above E.
  - Separately, `Reserve` checks each request's worst case (`ledger.go:126`, `money.go:97`). With
    `max_tokens` at 32000, one fact-truth request's worst case is about $1. Once `left/N` falls below
    a page's worst case, every page in the call escalates on the cap and sends nothing. That reads as
    a block, not as a budget limit.
- Fold:
  - Hold a reserve for B, RB, and K, sized from M1's dry run (about $12). An E read call starts only
    while `left − reserve > 0`. Otherwise E's open blueprints go to standing answer 5.
  - Split any call whose `left/N` is below the largest per-page worst case M1 recorded.
  - Report a cap escalation as a budget limit, never as a finding.
  - This follows the design's own ranking, so it is a method call, not a fork.

## Minor

### 11. `FactChanged` misses two kinds of edit the hash catches; the scoped clause costs more than it buys

- Severity: minor. Tag: `correctness`.
- Location: finding 12 (plan:146-151), D2 (plan:590); code `since.go:205-218` (`FactChanged`
  compares `Tag` without its qualifier, and `Sources` without pointers inside parentheses, per
  `facts.go` `parseBody`'s depth rule).
- Defect: a `--since` or bar read never sees an edit to a tag qualifier or a parenthesized pointer,
  but the map written at accept includes it, so the map certifies an edit no read saw. The impact is
  low. The finding-12 clause also needs a second map computed at the base.
- Fold, which also simplifies: a scoped accept advances `accepted` under today's two clauses and
  never writes `facts`. Any fact change since the map then lapses on the next read and is read
  exactly. Drop the third clause and its at-base map. That saves about 15 minutes of D2 and a test
  row; the pass never runs `--since`.

### 12. A lapse read's set should exclude ids that are no longer cited

- Severity: minor. Tag: `correctness`.
- Location: finding 3 (plan:87-89), finding 11 (plan:143), D2 (plan:597).
- Defect: "no longer cited" ids go into the changed set. Sent to the seat, they draw "returned no
  verdict" blocks that can't clear, because the blueprint can't place them.
- Fold: the fact-truth set of a lapse read is the changed ids that are still in the current read set.
  Removed ids appear only in the changed-facts block.

### 13. A duplicate fact id hashes its first bullet only

- Severity: minor. Tag: `correctness`.
- Location: D2's `FactsHashes` (plan:586); code `facts.go:64` (`Count`). Only `provenance.go:268`
  flags `Count > 1`, and `drafter check` does not.
- Defect: an edit to the second bullet of a duplicated id never lapses the accept.
- Fold: hash every bullet of the id, in file order, joined.

### 14. A second stop of a sync read has no rule

- Severity: minor. Tag: `correctness`.
- Location: run rules (plan:910-915).
- Defect: an API outage that outlasts the one resume leaves the session with no answer, short of
  standing answer 11's catch-all.
- Fold: on a second stop, abandon the run (`open.worst` to STATUS), wait on the `/loop` wake-up, then
  read fresh. A third stop is standing answer 11.

### 15. No hard check that a subagent never spent

- Severity: minor. Tag: `optional`.
- Location: finding 15, B step 2, E's fix round (plan:168-173, :776-781).
- Defect: a subagent inherits `DRAFTER_API_KEY` and is handed `BIN`'s path, and the skill's loop text
  tells an author to run `drafter read`. Only the prompt stops it. (Plain `drafter` on `PATH` is the
  old binary, which refuses the branch's lock after R2 under `KnownFields(true)`. That guards by
  accident.)
- Fold: take a meter reading at each subagent return. A rise in `total + open.worst` with no session
  row behind it stops the run.

### 16. The other workstation's stopped runs and the evidence's lifetime

- Severity: minor. Tag: `optional`.
- Location: Merge order 1 (plan:976-982), conductor prompt; STATUS and the friction log
  (plan:242-246, :263).
- Defect:
  - The run scan covers `pavilion` only. A run stopped on the other workstation can't resume after
    its `make install`, because `[seat.facttruth]` changes the fingerprint.
  - STATUS, `live-*.json`, the R1 record copies, and the friction log live in the drafter worktree's
    git admin directory, which `git worktree remove` deletes.
- Fold:
  - The conductor's note to Geoff says to check for stopped runs there before installing.
  - K's record carries every table it needs, and nothing removes the drafter worktree before the
    packet is decided.

### 17. Over-ceremony: R1 reads rotate

- Severity: minor. Tag: `optional`.
- Location: R1 (plan:671-674).
- Defect: rotate places none of the 25, and at `517158fae` it reads as a bar read, so R1's scoring
  gets nothing from it. It costs about $0.5 to $1 on each R1 run and tuning rerun, and a few minutes.
- Fold: drop rotate from R1's command, which leaves R1's N at 7. R2 keeps it.

## Checked and sound

- `KnownFields(true)` (`lock.go:60`) makes an older drafter refuse a lock that carries `facts`, `seat`,
  or `kind`, loudly and with no write. The plan's merge note covers it. The new binary decodes the old
  lock.
- The fingerprint claim holds: `fingerprint.go:37-43` iterates every `cfg.Seat` table, so a stock
  `[seat.facttruth]` blocks the resume of a run stopped on the old binary.
- The replay worktree's lock restore (R1 step 2) and the controls' restore keep reruns whole.
- The meter's arithmetic holds: per-page caps of `left/N` bound a call's new spend by `left`.
  `Spend` counts open intents at their worst case, whatever their age, so the baseline's $0.997 errs
  safe.
- K's revert restores the old map byte for byte, because hashes are content-based. The merge commit
  (never a squash) keeps the blob ids and bar commits valid.
- No cairn CI job or script decodes `drafted.lock`, so the cairn PR's CI is unaffected by the format
  change.
