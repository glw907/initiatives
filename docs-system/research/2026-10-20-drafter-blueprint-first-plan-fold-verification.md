# Fold verification: drafter blueprint-first plan

Date: 2026-10-20. The `spec-plan-review` verification step, run because the pass is `runner` with
`live-account` API spend. The reader had no part in the fold. Read: the revised plan and its
executor and conductor prompts (uncommitted on initiatives `main`), the fold record, the three
reviews, and the approved design. Code checked read-only: drafter `6a42564` and cairn-cms
`origin/main` `52b3f979e`.

## Brief

Counts: 0 blockers, 3 majors, 8 minors.

Every blocker and major from the three reviews closed where the fold record says. The text is in
the plan, not only in the record's claim. The fold introduced one contradiction. D1's bar plumbing
needs code that its file list keeps out of reach, and it names `read.go` as D3's file when D3's list
doesn't hold it. Two older gaps in D2's refusal rule also surfaced on the re-read. Both are short
folds. The path sums to 1075, at or under 1080. "Rulings for Geoff: None" holds.

## 1. Did each blocker and major close where the record cites?

Yes, all 33 (contract B1 and M1 to M9, mechanics 1 to 14, integrity 1 to 10), checked against the
plan text:

- Contract B1 and integrity 8: finding 12 (plan:166-176), finding 19 (:222-231), the D2 writes and the
  page-run test (:755-758, :792-794).
- Contract M1, mechanics 22, and M7: finding 8 (:138-149), the D3 build and tests (:650-654,
  :681-683), the E `prose_sources` line (:952-954), control 5 (:921-925), and B step 5 (:1047-1049).
- M2: standing answer 3 (:371-382), R1 step 3 (:863-869), and R2 step 4 (:904-907). M3: finding 7
  (:123-137), R2 step 2 (:894-902), and the conductor's ask row (conductor prompt:44).
- M4, mechanics 6, and integrity 5: finding 22 (:246-252), M2 step 2 (:960-964), and K step 1.2
  (:1119-1124). The `spend.go` quotes check out: `:38` takes a date only, and `spendRow` holds
  totals.
- M5 and mechanics 27: finding 21 (:244-245), the D2 test (:790), and K step 1.3 (:1127-1128).
- M6: S (:1062-1065) and RB steps 1 and 2 (:1080-1091). M8, mechanics 8 and 11, and integrity 10:
  the meter (:435-444) and M1 step 4 (:713-720). M9: R1 step 3's match column.
- Mechanics 1: the D1 files (:537-549). The four broken tests match the code. Mechanics 2: M1 step 1
  (:698-700) and the D3 byte-identity test (:689-691). Mechanics 3: the E read call (:992-995).
  Mechanics 4 and integrity 3: finding 20 (:232-237) and D2 (:755-757). Mechanics 5 and integrity 6:
  standing answer 3 (:374-376). A check of cairn shows rotate's blueprint changed after its bar
  commit (`fd90da8d8` holds blob `491ba25e`, `main` holds `7e91b7f5`), so rotate's bar read is
  never held. Mechanics 7: the path (:276-296). Mechanics 10: M2 step 2. Mechanics 12: Window W
  (:726-733) and the D4 base (:815-816). Mechanics 13: M1 step 1 and the run rules (:1167-1168).
  Mechanics 14: K step 1.2.
- Integrity 1: finding 13 (:177-185) and D2 (:759-761). Integrity 2: finding 21 and D2 (:757).
  Integrity 4: K step 1.2. Integrity 7: the run rules (:1159-1162), in part, as recorded.
  Integrity 9: Close step 4 (:1201-1203).

The code facts the record quotes also hold: `bar.go:91`/`:96`, `read.go:395-404`, `pagebp.go:195-212`,
`seed.go:107-108`, `money.go:131` (`Mode: r.cfg.Mode`), `spend.go:38,66`, and
`internal/config/{config.go:94-97,file.go:96,apply.go:151-152,env.go:53-54}`. Control 6 bites on the
anchor span. `signing.ts` has 228 lines, so `:150` resolves, but its code span is not found there,
and the factsheet says so.

## 2. Contradictions and build order

No concurrent-subagent file overlap remains. D1 and D3 share only `docs/configuration.md`, in named
sections. D2 and D4 run in sequence. The tuning files are ones D2 and D4 never edit. One
contradiction is new (major 1). Two older gaps are majors 2 and 3.

## 3. The new mechanisms

- **`facts.prose_sources`** is a new config key. D3 adds it (`config.go`, `file.go`, `apply.go`) and
  documents it in the `docs/configuration.md` facts table, which `TestConfigurationDocNamesEverySetting`
  enforces. It gets no value check beyond the excerpt code's own tracked and inside-the-root checks
  (`excerpt.go:58`, `:67`), and that is enough: a wrong entry fails safe as `no-excerpt`. The `facts`
  table is already allowed in the project and local layers (`layer.go`, `"facts": inProject |
  inLocal`), so `layer.go` needs nothing. It is new public surface, but it is the minimum that keeps
  the design's rule (a live page is never a source) by construction. The design's "Three format
  changes" govern the blueprint format, not config. The design also assumed every prose pointer
  could be re-pointed (design:278-280), and the owner tier can't be. So this is a method call
  inside the design's latitude, marked contestable and listed in both PRs. Two gaps are minors 2
  and 3.
- **Who writes `facts`.** The rules (finding 12, D2 :755-761) can be built against `recordReads`.
  The bar accept and the whole accept share one case (`r.Status == StatusAccepted && r.Accepted !=
  ""`), and a seatless bar is told apart from `e.Blocked`. A page run's results carry no `Facts`,
  so "leave as it was" means writing only a non-nil `Facts`. `recordDrafted` calls `recordReads`
  first (`pagebp.go:199`), then `DraftedEntry`, so D2's carrying of `facts` through the drafted entry
  is needed and is listed. The open gaps are majors 2 and 3 and minor 7.
- **The meter.** It is consistent with `spend.go`. `--since` with a date, `total`, `open.count`,
  `open.worst`, and `rows[].requests` all exist. `used = total − baseline.total + open.worst` counts
  the baseline's open batch against the pass, which errs safe. Any fixed date at or before launch
  works, because the baseline and every reading use the same date. The reserve's planning figure
  doesn't match the table (minor 5).
- **The `/tmp` skill copy** is minor 1.
- **The path**: 30 + 30 + 150 + 35 + 235 + 25 + 130 + 240 + 40 + 60 + 35 + 65 = 1075, which is
  1.99x the 540 design figure and at or under 1080. W's line is worded loosely (minor 6).

## 4. "Rulings for Geoff: None"

It holds. Three points could have been rulings, and none changes the outcome, gate, proof, bars,
budget, or standing answers:

- **Finding 7** reads the design's own definition of `wider` ("the fact claims more than the
  excerpt shows"). It reports the design-literal count beside its own, and the conductor turns any
  divergence into an ask row. The design's false-block sentence admits both readings, and the plan
  leaves Geoff the choice once data exists.
- **`facts.prose_sources`**: see section 3.
- **Finding 19's residual** is the design's "Later" item. Major 2 below brings the plan's refusal
  back to the design's own item 2 for the one case that item already covers.

## Findings

### Major 1. D1's bar plumbing needs code outside its file list, and its exclusion list names `read.go` as D3's

- Severity: major. Tag: `correctness`.
- Location: plan:550-552 (D1's "Not ... `read.go` ..., which D3 owns"), :534 (`cmd/drafter/bar.go`
  (`barOf` only)), :561-563 and :591-593 (the bar read's set; "the blueprint seat's bar block holds
  only the bar's blueprint-seat findings"), :612-613 (the bar-read test); finding 11 (:159-162). Code:
  the bar reaches the pipeline as rendered text, `Options.Bars map[string]string`
  (`internal/pipeline/pipeline.go:78`), filled by `applyBar` with `renderBar(b)` (`cmd/drafter/bar.go:204`,
  `:159-165`) and passed at `cmd/drafter/read.go:158`.
- Defect: D3's file list (:632-640) doesn't hold `read.go`, so the exclusion is wrong. The bar read
  has two needs. It must add the bar's `facttruth` fact ids to the read set, and it must keep
  `facttruth` findings out of the blueprint request's bar block. Both need the bar's structured
  findings. The pipeline only gets a rendered string with no seat in it. Inside D1's files, the only
  route is to parse `[fact f:<id>]` back out of that string, and the plan doesn't name it.
  "Only the bar's blueprint-seat findings" also misreads today's bars. `barOf` keeps every blocking
  finding, consistency's included (`bar.go:147-150`). A literal filter on `seat == "blueprint"`
  would drop consistency findings from new bars, and would drop every finding of a seatless bar
  such as rotate's. Either way the request bytes change, which the line says they won't.
- Fold:
  1. D1's files gain `cmd/drafter/bar.go` (`barOf`, `renderBar`, `applyBar`, `barMaps`) and
     `cmd/drafter/read.go` (the `pipeline.Options` literal only). Drop "which D3 owns" for
     `read.go`; D2 edits `read.go` only after M1.
  2. `renderBar` skips findings whose `seat` is `facttruth`, and renders seatless and `consistency`
     findings as today.
  3. `applyBar` records the bar's `facttruth` fact ids in a new `Options.BarFacts
     map[string][]string`, which the pipeline adds to the read set.
  4. Replace the sentence at :591-593 with "the blueprint request's bar block drops `facttruth`
     findings only; seatless and consistency findings render as today".

### Major 2. `drafter page` checks the facts map only when `accepted` equals the blob; design item 2 compares it at every page run

- Severity: major. Tag: `correctness`.
- Location: plan:769-774 (D2, "an entry whose `accepted` equals the blob but whose `facts` is missing
  or differs"), finding 19 (:222-231); design:174-178 ("compared at every read and page run. A
  mismatch is `lapsed` ... `drafter page` refuses before any request").
- Defect: take an entry whose `accepted` is stale and whose map differs, because a fact it cites
  changed. D2 doesn't refuse it. The page run's read stage judges the blueprint without the
  fact-truth seat, accepts, and drafts in the same run on a changed fact that no read judged. Finding
  19 defers "drafting from gated blueprints only", which is the missing-map case. But the design
  already requires refusal on a mismatch at every page run, so the plan's narrower condition is a
  departure the record doesn't name.
- Fold: D2 refuses when a `facts` map is present and differs from the current read set, whatever
  `accepted` holds. It also refuses when `accepted` equals the blob and the map is missing, as now.
  Add one D2 test: a stale `accepted` with a differing map refuses before any request. Finding 19's
  residual then shrinks to an entry with no map whose `accepted` is stale, which is the case the
  design's "Later" names. Reword finding 19 and the plan's "Later" item to match. In this pass,
  `drafter page` runs only as dry runs and K's capped refusal, so the change costs no run time.

### Major 3. A project with no facts directory, or a blueprint that cites no facts, is refused by `drafter page` forever

- Severity: major. Tag: `correctness`.
- Location: plan:748-754 (D2, `FactsHashes` and `yaml:"facts,omitempty"`), :769-774 (the refusal on a
  missing map), finding 10 (:155-158). Code: drafter supports a project with no facts directory
  (`internal/plan/check.go:23`, "empty when the project has no ..."; `cmd/drafter/read.go:363`,
  `if c.Facts.Dir == ""`).
- Defect: with no facts directory, or with an empty read set, `FactsHashes` returns an empty map.
  `omitempty` then leaves the field out of the lock. `drafter page` reads that as "no facts
  recorded" and refuses every accepted page, and no `drafter read` can write a map that clears the
  refusal. D2's file list also doesn't name the existing skip-read tests the refusal changes
  (`cmd/drafter/draftscope_test.go:324-344`, `bar_test.go:526-626`). They run `drafter page` on an
  accepted entry with no `facts`. This also cuts against the repo's rule that a new project's setup
  stays ergonomic.
- Fold: in D2, a missing map matches when the current read set is empty, including when
  `facts.dir` is unset. Neither the refusal nor the lapse check fires then. Add one test for each
  case: no facts directory, and a blueprint citing nothing. Add the skip-read tests to D2's files,
  each given a matching `facts` map where its fixture has a facts directory.

### Minor 1. The rebuild's skill copy sits in shared `/tmp` under a fixed name

- Severity: minor. Tag: `correctness`.
- Location: plan:343, :1082-1086, :1101.
- Defect: parallel sessions on this workstation share `/tmp`. A fixed name can collide with a
  sibling's files or with a copy left by an earlier attempt. `cp` into an existing directory keeps
  stale files, such as a file the tuned skill has since dropped. A subdirectory of the drafter
  worktree's git dir won't do either: the friction log and STATUS sit beside it.
- Fold: copy into the rebuild worktree's own git dir,
  `/var/home/glw907/Projects/cairn-cms/.git/worktrees/blueprint-first-rebuild/rebuild-skill/`. Take
  the path from `git -C <rebuild worktree> rev-parse --absolute-git-dir`, and run `rm -rf` on it before
  the `cp -L`. It holds no friction log or STATUS, and `git worktree remove` deletes it at RB step 4.
  The prompt already forbids other branches, so the shared object store adds no exposure. Keep the
  grep step. If a `.git` path is unwelcome, use `mktemp -d /tmp/blueprint-first-rebuild-skill.XXXXXX`
  recorded in STATUS.

### Minor 2. The merge note misses `prose_sources` as a reason an older drafter refuses cairn

- Severity: minor. Tag: `correctness`.
- Location: plan:1240-1242 (Merge order 1).
- Defect: config files decode strictly. An unknown key is an error (`internal/config/file.go`
  `decode`), so a drafter older than this pass refuses cairn's committed `drafter.toml` once it
  carries `prose_sources`. That happens on every command, not only on the lock. The fold added the
  key but not this reason. The remedy (pull and `make install`) is the same.
- Fold: add "or a `drafter.toml` carrying `facts.prose_sources`" to the reasons in Merge order 1 and
  in the conductor's note to Geoff.

### Minor 3. `prose_sources` is outside the run fingerprint and `settingKeys`

- Severity: minor. Tag: `optional`.
- Location: plan:632-634 (D3 files); code `internal/pipeline/fingerprint.go:17-31` (off limits) and
  `internal/config/sources.go:17` (`settingKeys`).
- Defect: a resume can't detect a changed `prose_sources`, because `fingerprint.go` is never edited.
  The run rule (nothing changes between a stop and its resume) covers this pass. Without a
  `settingKeys` entry, `drafter config` lists the key only when set, not as "unset" in table order.
- Fold: add `internal/config/sources.go` to D3's files, with the key after `facts.bullet_format`. Add
  "`facts.prose_sources` joins the run fingerprint" to the plan's "Later" and to the drafter PR's
  Decisions.

### Minor 4. Standing answer 3's tuning file list omits the goldens a wider excerpt view moves

- Severity: minor. Tag: `correctness`.
- Location: plan:366-369.
- Defect: a tuning round that widens the view in `excerpt.go` moves every golden D3 regenerated for
  excerpt content, not only the count golden. `make check` then goes red on a file the round may not
  touch.
- Fold: the list adds "every golden whose bytes move only by excerpt content, regenerated, each
  `git diff --stat` in the commit". None of them is a D2 or D4 file, so M2's merge stays clean.

### Minor 5. The reserve's planning figure disagrees with the table, and post-M2 tuning reruns can draw on it

- Severity: minor. Tag: `correctness`.
- Location: plan:440-444 ("about $12"), :456-457 (B $5 to $8; RB and K $2), :904-907 (R2 step 4's
  tuning after M2).
- Defect: the table's reserve rows sum to $7 to $10, not "about $12". M1 step 4's formula
  (seven reads of the largest blueprint, plus RB, plus K) governs, so the prose figure misleads
  only. A tuning rerun after E's first read is not bound by `left − reserve`, so it can eat B's
  reserve. The spend stop then catches it, which fails safe.
- Fold: write "the reserve is M1 step 4's figure ($7 to $12 at planning)". Add "a tuning rerun
  after M2 also starts only while `left − reserve > 0`, or it goes to standing answer 3's stop
  question".

### Minor 6. W's path line is worded ambiguously

- Severity: minor. Tag: `optional`.
- Location: plan:281-282.
- Defect: "E's first fix round (about 200 with the round): 235" can read as "200 including the
  tuning round", which gives W 205, not 235.
- Fold: "R1 to R3 and E's first fix round (about 200), plus one tuning round (35): 235, beside D2
  then D4 (205)".

### Minor 7. A seat-aware bar accept writes a full map, but its read set rests on `FactChanged`

- Severity: minor. Tag: `correctness`.
- Location: finding 12 (:166-170), finding 11 (:160-162), D2 (:755-757); code
  `internal/blueprint/since.go:143-151` (scope facts come from `FactChanged`).
- Defect: integrity 11 found that `FactChanged` misses edits to a tag qualifier and to a pointer in
  parentheses. The fold applied that to scoped accepts. A bar accept on a bar with `seat` still
  writes a full map, while its fact-truth set comes from the same `FactChanged` scope. A qualifier
  edit made after the bar is then recorded in the map without being judged. That breaks finding
  12's invariant, and E's bar reads exercise this path.
- Fold: in D1's bar-read set, add every cited id whose `Raw` differs between the bar's commit and
  the start commit, compared as `Raw` rather than through `FactChanged`. Or, more simply, a bar
  accept writes `facts` only when no cited bullet's `Raw` changed since the bar's commit. Otherwise
  it leaves the map, and the next read lapses exactly.

### Minor 8. The resume rule guards commits, but a resume reads the working tree

- Severity: minor. Tag: `correctness`.
- Location: plan:1159-1162.
- Defect: "Nothing is committed in that worktree between the stop and the resume" still allows an
  uncommitted fact edit there, for example by an E fix subagent dispatched while the session waits.
  `LoadFacts` would read that edit on resume.
- Fold: "Nothing in that worktree changes, committed or not, between the stop and the resume. No
  fix subagent works in it meanwhile."
