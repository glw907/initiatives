# B3 plan review: data integrity and failure risk

Target: `docs-system/plans/2026-10-19-drafter-b3-drafting-plan.md` at `46a83da`. Design:
`docs-system/specs/2026-10-19-drafter-b3-drafting-design.md`. Code was read at drafter `main`
`f286162`, read-only. Every claim below was checked against the source named beside it.

Totals: 1 blocker, 11 major (2 of them OWNER FORKs), 12 minor. Every finding that can cost money
or leave a stale page traces to one of three things. The lock walk infers the old revision, the
region bound meets findings and reds outside the allowed sections, and the live harness checks the
spend meter before a run but doesn't cap the run.

## Blocker

### 1. The lock walk counts an `accepted`-only change as a new entry, so a fact edit can go unseen

- Severity: blocker. Tag: `correctness`.
- Location: plan lines 206-210 (resolution 3, "keep the last commit whose entry for the page equals
  the current entry"). Source: `cmd/drafter/read.go:432-470` (`recordAccepted` rewrites only
  `Accepted`).
- Defect: the walk compares whole entries. `drafter read` rewrites `accepted` when it accepts an
  edited blueprint, and the plan's own `SkipRead` flow depends on that read. Here's the sequence:
  1. A draft lands at commit D, with the lock entry `{P, B0, A=B0}`.
  2. The user commits a fact bullet edit and a blueprint edit together, as C1.
  3. `drafter read` writes `accepted=B1`, and the user commits the lock as C2. A clean tree is
     required, so the commit has to happen before the next run.
  4. The walk sees the entry change at C2, so L = C2 and L^ = C1. The old facts then come from C1,
     which already holds the edited bullet.

  The fact change goes unseen. The blueprint change is caught, since the entry holds the blob, but
  a section that cites the edited fact and isn't in the blueprint diff is never redrafted. Nothing
  reports it. This breaks the design's "a changed fact bullet counts for every section that cites
  it" on the documented read-then-draft path.
- Fold: the walk compares only the fields a draft or seed writes: `page`, `blueprint`, and
  `sections`. It ignores `accepted`. Add a B3.2 scope row for this case: draft, then a fact edit and
  a blueprint edit in one commit, then a read-accepted lock commit. The changed fact's citing
  section must be in scope.

## Major

### 2. A commit between the run's start and the lock's commit hides fact and outline edits (OWNER FORK)

- Severity: major. Tag: `correctness`.
- Location: plan lines 212-219 ("`L^` holds the outline and facts the draft or seed saw"). Source:
  `internal/pipeline/resume.go:96-108` (`checkPosition` lets HEAD move to a descendant during a
  stopped run). The lock is a working-tree file that the user commits whenever they like.
- Defect: the plan backs `L^` with the clean-tree check at the start, but nothing stops a commit
  landing after the start commit S and before L. Two ways it happens:
  - a commit made between a stop and its resume, which `checkPosition` allows;
  - a fact edit committed separately before the user commits the page, brief, and lock.

  Either way, `L^` holds an edit the draft never saw, and the next run reads it as old. A merge
  commit that introduces the entry has the same effect through its first parent. This isn't
  finding 2's case, and the plan's "Later" list doesn't name it.
- Options:
  - (a) Keep the walk and add a guard. At lock-write time, when HEAD isn't the start commit and
    `git diff --name-only <start> HEAD -- <facts dir> <outline>` isn't empty, print a warning that
    names the files. Document the rule: commit the page, brief, and lock with nothing between them
    and the run's start. List the case in "Later".
  - (b) Record the start commit in the lock entry now. The draft reads S, which is different from
    the commit the entry lands in, so the architecture's objection doesn't apply. This removes the
    walk and closes finding 2 too. It changes the lock format, which the design rules out for B3.
- Recommendation: (a) for B3, since (b) changes the design and would stop an unattended run. Take
  (b) into B4's design.

### 3. A crash or a busy lock after `pipeline.Run` returns leaves a drafted page with no lock entry and no stated recovery

- Severity: major. Tag: `correctness`.
- Location: plan lines 169-191 (resolution 2). Source: `cmd/drafter/read.go:425-439`
  (`recordAccepted`'s comment says "a crash before this write loses an acceptance that reading again
  recovers") and `internal/run/lock.go:21-36` (`TryLock` is non-blocking).
- Defect: the lock write takes the worktree lock again with `LOCK_NB`. A concurrent drafter
  invocation that holds the lock for a moment makes the write fail, and so does any crash. One
  example is another `drafter page` that takes the lock and then fails `requireClean`
  (`internal/pipeline/start.go:117-131`). The read's reasoning, "reading again recovers", doesn't
  carry over to drafting:
  - A rerun can't start, because the drafted page leaves the tree dirty.
  - If the user commits the page, the next run finds no entry and drafts the accepted page whole
    again. That spends a full draft and replaces the page.

  There is a recovery path. `--resume <id>` on a finished run passes `checkTree`, because the lock
  is untouched, finds nothing to run, and returns the full summary, so the lock gets written.
  `resume()` doesn't refuse a finished run. The plan neither states this path nor tests it.
- Fold: when the lock write fails, print `drafter page --resume <id> …` through
  `pipeline.ResumeCommand`, and print the run summary before the error so the acceptance isn't lost
  from the output. Add two B3.2 tests:
  - A finished run whose lock write failed: `--resume` writes the lock and makes no API call.
  - A run that stopped after page A was accepted: its resume writes A's entry. Today's test list
    has only "a stopped run writes nothing".

### 4. The new `[seat.coherence]` makes every run stopped before the upgrade impossible to resume

- Severity: major. Tag: `correctness`.
- Location: plan lines 345-349 and B3.0 item 2. Source: `internal/pipeline/fingerprint.go:16-61`
  (`fingerprint` walks every `c.Seat`, and `changedSettings` flags any key in `now` that's missing
  from `was`) and `internal/pipeline/resume.go:262-289` (`checkConfig`).
- Defect: the stock layer adds `seat.coherence.*`, which a pre-B3 run's `fingerprint.json` lacks.
  Every pre-B3 stopped run then refuses with "the configuration changed since the run started
  (seat.coherence.agent, …); put it back". The user can't remove a stock seat, so the run is
  stranded. Its written pages block a new run, and its open intents stay open in the ledger at worst
  case (finding 9). The plan's upgrade test (B3.1, "A state saved before B3 … resumes as a read")
  will pass if it builds the fingerprint from the current configuration, and that hides the bug. No
  run is stopped on this workstation right now. I checked `~/.local/state/drafter/runs`, and the
  risk is still live for any run that stops before `make install`.
- Fold: `changedSettings` ignores a seat whose keys are all absent from `was`, as long as no page in
  the run renders that seat. Pre-B3 pages have no `draft` flag, so none renders `coherence`. Write
  it test-first, with a fixture `fingerprint.json` frozen from `f286162`. The change lives in
  `fingerprint.go` or `resume.go`'s `checkConfig`, so it takes the ALLOW ruling's per-commit
  `diff-reviewer` read. That adds about 20 minutes to B3.1.

### 5. A section redraft's final reader isn't narrowed, but its fix exchange is bounded

- Severity: major. Tag: `correctness`.
- Location: plan lines 323-327 (the bound applies to `exFinal`) and 334-336 ("The final reader isn't
  narrowed"). Source: `stageScoped` scopes editor and fact to the reader's findings, which can name
  any section.
- Defect: a reader finding located in an unchanged section opens `exFinal` under the region bound.
  The bound refuses every edit that could fix it, the contract budget runs out, and the page
  escalates with rule `contract`. A section redraft that passed review is thrown away after the
  spend. A gate red located outside the allowed sections does the same, through the bounded gate
  fix. That includes a Vale rule added since the last accept, or provenance's unclassified page
  text (finding 6). Each rerun repeats it, and it's a likely live miss on row 2.
- Fold, a method call with no design change:
  - In a section redraft, pass reader findings located outside the allowed sections to the
    coherence read, which is unbounded, rather than to `exFinal`.
  - Before a bounded gate fix opens, check whether every red line lies outside the allowed regions.
    If it does, escalate at once with a named rule, such as `out-of-scope`, instead of spending the
    contract budget.
  - Add a fake-API row for each.

### 6. A section redraft of a page with no brief at the blueprint-adjacent path can't pass

- Severity: major. Tag: `correctness`.
- Location: plan lines 198-201 and 223-229 (scope cases), plus resolution 9's two-way coverage.
  Source: `internal/blueprint/seed.go:90-110` and `internal/blueprint/install.go:60-110`. Both
  write a lock entry with a `page` id and no brief.
- Defect: seeded pages and converted pages have a lock entry with a page id and no brief at
  `<blueprint>.brief.json`. cairn's briefs live under `docs/internal/briefs/`. Resolution 3 sends
  such a page to Compare, and a one-item edit then makes it a section redraft. The draft writes
  brief sentences for the changed section only. Two checks then fail on every untouched section:
  - the provenance gate reports `unclassified page text` for each one;
  - run-time coverage finds every out-of-scope fact item uncited.

  Each run spends a section redraft and then escalates.
- Fold: add a scope case to resolution 3. A page whose brief is absent at the start commit drafts
  whole, or refuses: see finding 18 for that fork. Add a B3.2 scope row for a seeded page with a
  one-item edit.

### 7. Resolution 3 decides "whole, with a change read" for a missing heading, but gives the pipeline no way to tell

- Severity: major. Tag: `correctness`.
- Location: plan line 228 (the table row for a missing heading) and line 283 (the section-redraft
  test: `Draft` set, scope `ScopeScoped`, and `IDs` present).
- Defect: in the missing-heading case, cmd holds a `ScopeScoped` scope with `IDs`. That's the most
  common edit, an added section or a renamed heading. If cmd passes the scope as is, which is all
  the plan says, the pipeline's test reads it as a section redraft. The bound then fails its "each
  allowed heading must still be found" check on the pre-edit page, and every answer is refused.
  It fails closed, but only after the spend, on every rerun, and it never succeeds.
- Fold: say how cmd marks the case. The simplest way: cmd keeps `Kind: ScopeScoped` and its `Why`,
  sets `IDs` to nil, and lets the change read run on scope "page". Add a B3.2 row and a B3.1 row:
  an added section drafts whole with no bound.

### 8. The live harness checks the meter before a run but doesn't cap the run

- Severity: major. Tag: `correctness` (standing answer 2, "a run that would start at or past $20
  doesn't start").
- Location: plan lines 102-105 and 572-574. Source: `internal/ledger/ledger.go:124-131` (the page
  cap is per run and page, $10 from the user layer) and `internal/config/apply.go:91-99`
  (`putCap` lets a higher layer, including the `DRAFTER_PAGE_CAP` environment variable, only
  lower a cap).
- Defect: a row that starts at $19 can reserve and spend up to the $10 page cap, which puts the
  pass's spend at $29. The standing answer stops spend past $20, and the plan's check bounds only
  where a run starts.
- Fold: before each `drafter page`, the harness sets `DRAFTER_PAGE_CAP` to
  `min(page_cap, 20 − spent)`, with spent counted as the plan counts it. A run that would cross the
  line then escalates with rule `cap` instead of overspending. Add a row to the meter helper's unit
  test.

### 9. A live run left stopped in a temp directory keeps its worst case in the real ledger for good

- Severity: major. Tag: `correctness` (money accounting).
- Location: plan lines 566-570 and B3.7. Source: `internal/ledger/store.go:94-107` (`cycleTotal`
  counts every open intent at worst case, whenever it was reserved). `cmd/drafter` has no settle
  or void command, so only `--resume` settles one.
- Defect: the live project is a temp copy, and the run state goes to the real `state_dir`. Several
  things can stop a live row with an intent open: a transport error, a `-timeout 3h` panic, or a
  kill. Once the temp directory is removed, nothing can resume that run. Its reservation then
  inflates `open.worst` and the $160 cycle ceiling forever, and the next live attempt's meter
  check reads it as spent.
- Fold: the live test creates its project with `os.MkdirTemp` and removes it only when the test
  passes. On failure, it logs the run id, the project path, and the resume command, and the PR body
  carries them. It starts `drafter` with `exec.CommandContext` and a deadline taken from
  `t.Deadline()` minus a margin. That way a timeout ends the child rather than orphaning it.

### 10. A plain `go test -tags live` spends money, and B3.6's own acceptance command does

- Severity: major. Tag: `correctness`.
- Location: plan lines 118-119 (`DRAFTER_API_KEY` is set in the executor's environment at launch)
  and 786-788 (B3.6: "`go test -tags live -run Live ./e2e/` with `DRAFTER_API_KEY` unset skips").
- Defect: the executor's shell has the key set. Run as written, the acceptance command makes a live
  run in pair B's shadow, before provenance merges and before the B3.7 baseline exists. The test's
  only guard is that the key is set.
- Fold:
  - Write the acceptance as `env -u DRAFTER_API_KEY go test -tags live -run Live ./e2e/`.
  - Gate the test on an explicit opt-in, such as `DRAFTER_LIVE=1`, that only `make live` sets.
  - Fail, rather than default to 0, when `DRAFTER_LIVE_BASELINE` is unset or doesn't parse.

  `make check` is safe as it stands: the `test` target runs `go test ./...` with no tag
  (`Makefile:11-12`).

### 11. Live row 2's "page outside that section equals row 1's" fails whenever the coherence read returns `fix`

- Severity: major. Tag: `correctness` (the acceptance is wrong, and live reruns are wasted).
- Location: plan line 579 (row 2), against resolution 6's unbounded coherence fix (lines 358-359).
- Defect: the design lets the coherence fix edit any section. A well-behaved run whose coherence
  read returns `fix` fails row 2. The executor then spends budget "fixing" a miss that isn't one.
  Finding 4 at lines 47-49 says the same thing: a hand edit outside the changed sections "survives,
  because of the region bound". That's false whenever the coherence fix runs (finding 13).
- Fold: assert the bound on the section exchange's last write. Each `run.Write` in the page's state
  or record carries the page as it stood before `stCoherence`. When the coherence fix ran, report
  the diff outside the section instead of failing on it.

### 12. Live spend: which $20 (OWNER FORK)

- Severity: major. Tag: `correctness`.
- Location: plan lines 30-35 and 102-105, against the design's "Standing answers" ("its `total`
  plus `open.worst`").
- Defect: the plan settles an ambiguous spend limit on the looser reading, the pass's own spend
  above a $9.44 baseline. If launched unconfirmed, the meter could reach $29.44.
- Options:
  - (a) The design's literal reading: the absolute meter, about $10.56 of headroom, roughly one and
    a half live attempts.
  - (b) The plan's reading: $20 of this pass's own spend.
- Recommendation: (b) only if the conductor confirms it with Geoff before launch. Otherwise launch
  on (a), since an overnight run has no one to ask and the money path defaults to the stricter
  reading.

## Minor

### 13. Finding 4's claim that out-of-scope hand edits survive is false

- Severity: minor. Tag: `correctness`.
- Location: plan lines 47-49.
- Defect: the coherence fix is unbounded, so a hand edit anywhere on the page can be rewritten.
- Fold: reword finding 4 to say so. Git still holds the committed page.

### 14. The bound requires only the allowed headings to be found

- Severity: minor. Tag: `correctness`.
- Location: plan lines 311-314. Source: `internal/coverage/sections.go:27-61`. `split` toggles on
  fence lines and matches the first heading with the same normalized text, at or after the previous
  match.
- Defect: an edit in an allowed section can hide a later out-of-scope heading. It can open an
  unbalanced fence, or add a heading that duplicates a later one's text. The region comparison
  catches this only if it compares not-found regions too.
- Fold: require every blueprint heading to be found after the edit, at the same order, and add
  refusal rows for the fence case and the duplicate-heading case.

### 15. The brief bound doesn't police added sentences or text that appears in two places

- Severity: minor. Tag: `correctness`.
- Location: plan lines 315-318.
- Defect: the rule doesn't cover two cases:
  - a new sentence whose text lies in an out-of-scope section;
  - a sentence whose text appears in both an allowed section and an out-of-scope one, which is
    treated as allowed.

  The provenance gate's consumption check usually catches both, at the cost of a gate cycle.
- Fold: refuse an added sentence that lies only outside the allowed sections, and match brief
  sentences as a multiset.

### 16. The bound for the coherence fix's own gate fixes is ambiguous

- Severity: minor. Tag: `correctness`.
- Location: plan lines 323-325 ("Only the coherence fix passes nil").
- Defect: if `exCoherence`'s gate-fix turns are bounded, a red the coherence fix itself introduced
  out of scope can't be fixed.
- Fold: key the bound on the exchange kind. Every turn of `exCoherence`, gate fixes included, passes
  nil.

### 17. The walk's behavior on an undecodable historical lock isn't stated

- Severity: minor. Tag: `correctness`.
- Location: plan lines 206-210. Source: `internal/blueprint/lock.go:46` (`ReadLock` decodes with
  `KnownFields`).
- Defect: a commit with a lock in an older format makes the walk error out rather than stop.
- Fold: treat a decode failure as "differs": stop the walk there.

### 18. An existing page whose entry holds only `accepted` is overwritten by a whole draft (OWNER FORK)

- Severity: minor. Tag: `optional`.
- Location: plan lines 198-201.
- Defect: a hand-written page that `drafter read` accepted but nobody seeded is replaced wholesale.
  It can be recovered from git, since the tree was clean at the start.
- Options:
  - (a) Draft whole, as planned.
  - (b) When the page exists at the start commit, refuse with "run `drafter seed` first".
- Recommendation: (a) for B3's synthetic scope, with a stderr warning naming the page it replaces.
  Revisit (b) in B3c, where real cairn pages are in play.

### 19. The page at HEAD can differ from the lock entry's `page` id with no warning

- Severity: minor. Tag: `optional`.
- Location: resolution 3.
- Defect: a page discarded after its lock was committed, or hand-edited, still reports `up to date
  with drafted.lock`. Detection is B4's.
- Fold: print a one-line warning when `CommitBlobID(start, page)` doesn't equal `entry.page`.

### 20. An old outline entry missing at `L^` drafts whole

- Severity: minor. Tag: `optional`.
- Location: plan line 206. Source: `internal/blueprint/since.go:71-73` ("the outline does not list
  the page at both revisions").
- Defect: an outline entry committed together with the lock reads as absent at `L^`, so the page
  drafts whole once, needlessly.
- Fold: when `L^`'s outline lacks the page, take the entry from `L`.

### 21. A draft that escalates loses its read's acceptance

- Severity: minor. Tag: `optional`.
- Location: plan lines 186-187.
- Defect: when the blueprint read accepts on an unscoped read but the draft escalates, the
  acceptance isn't recorded. The next run reads again, at the cost of one Opus read.
- Fold: record `accepted` alone for such pages, as `recordAccepted` does. This is a cost call, not
  a correctness one.

### 22. The live harness's binary isn't named exactly

- Severity: minor. Tag: `correctness`.
- Location: plan line 568 ("The worktree's built `drafter` goes first on `PATH`"). Source:
  `e2e/e2e_test.go:17-33` (`TestMain` builds a fresh binary). A stale `./drafter` sits at the
  repo root.
- Defect: a harness that puts the repo-root binary on `PATH` could spend on old code.
- Fold: put the directory of `TestMain`'s `binary` on `PATH`, and run `drafter spend` from the same
  binary.

### 23. A run that stops and is abandoned leaves its accepted pages with no entry

- Severity: minor. Tag: `optional`.
- Location: plan line 189. Source: `internal/pipeline/resume.go:257-304`. `checkTree` would refuse
  a resume if `drafted.lock` changed mid-run, so writing on a stop isn't an option.
- Defect: the recovery path isn't documented.
- Fold: one sentence in `docs/blueprint-format.md`. Resume the run, or discard its pages and run
  again.

### 24. B3.7's scripted coherence run repeats B3.1's coherence rows (over-ceremony)

- Severity: minor. Tag: `optional`.
- Location: plan lines 796-797.
- Defect: it repeats B3.1's coherence `fix` and retest rows on the fake API, at about 15 minutes and
  one test file's tokens. The stock-prompt render it adds is already proven by the line above it.
- Fold: drop it, or keep only the whole-draft render.

## Checked and clean

- **Coherence seat spend.** `submitUnit` prices every request from `CountTokens` plus the seat's
  `max_tokens` (`internal/pipeline/money.go:89-110`, `internal/ledger/price.go:53-65`). `seatOf`
  keys on no seat name, and nothing parses stage tokens with a pattern, so `s8` is safe. The page
  cap and the cycle ceiling cover `coherence` with no `money.go` edit. Opus has a price on the user
  layer.
- **`make check`.** It runs no tagged test. Adding `go vet -tags live` only compiles the file.
- **Writes and resume.**
  - `WriteLock` is atomic, and `writeFiles` is journaled through `run.Write`.
  - The prompts module is copied per run, so a pre-B3 resume renders its own copy.
  - `work` decodes without strict mode, so the new bools default to false.
  - A resumed run's `summary()` covers every page, so the lock write after a resume sees pages
    accepted before the stop.
