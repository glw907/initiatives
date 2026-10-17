# B1 plan fold verification

Reader: a fresh-context verification agent with no part in the fold, 2026-10-17. Target:
`plans/2026-10-17-drafter-b1-blueprint-format-plan.md` at `283dd6e` (fold of `2e44160`), against the
fold record, the three reviews, the approved design, drafter `d3447d9`, and cairn-cms `9754d6357`.
Every claim below was checked in code; line numbers are at those commits.

Counts: 1 blocker, 1 major, 7 minors. The departures from the design's text are justified and need
no ruling, though four belong in the approval packet as visible rows. The path arithmetic is right.

## 1. Did each blocker and major close where the fold record says?

Yes, every one has text at the location it cites: R6, R8, R9, R12, R13, and R14; B1.1's refusal and
edit-catalog rows; B1.2's pair note, lock rule, and fixtures; B1.3's writer and seed rules; B1.4's
handoff, lock, and rows; B1.5's preamble, steps 1 to 9, and its split acceptance; and Close steps 7
and 8. The count of 59 + 5 + 4 = 68 checks out (mechanics 28, contract 27, integrity 13).

### The lock-write mechanism (R14) traced through `resume.go`

It holds. `money.go` and `resume.go` need no edit, and a stopped read run resumes:

- `rehydrate` (`resume.go:154-185`) needs one handoff per state page and calls `h.Verify()`.
  `read.go` builds each handoff with `handoff.Checksum` over the blueprint as it is on disk
  (`handoff.go:176-189`), so `Verify` (`handoff.go:162-171`) passes, including after the blueprint is
  committed again between the stop and the resume. Given the same blueprints, every page key
  matches.
- `checkTree` (`resume.go:257-304`) owns only `p.files()`, the page and its brief
  (`page.go:53`). A read writes neither, so both stay at their `Pre` hashes (`wantHashes` returns
  `pre` when there's no write, `resume.go:237-238`). The lock is never written mid-run, so
  `git status` stays clean apart from ignored files like `drafter.local.toml` (cairn
  `.gitignore:33`). An escalated page's `restore` writes back pre bytes that are identical, or
  removes a file that was never there (`page.go:272-339`), so nothing shows in `git status`.
- `checkPosition` (`resume.go:96-110`) accepts a descendant HEAD, so a blueprint committed after a
  stop still resumes. R12 then builds any request it rebuilds from `r.state.Head` (`start.go:160-168`,
  restored by `LoadState`), and the accepted id is the blob at that commit.
- `settleOpen`, `recoverIntent`, and `reattach` are generic over stages and seats. A two-seat `s1`
  stage goes through `submitUnit` (`money.go:89-148`) the way round 1's three seats already do,
  and `seatOf` (`money.go:29-35`) reads `blueprint` out of the custom_id.
- The `[seat.blueprint]` settings join the resume fingerprint through `c.Seat`
  (`fingerprint.go:37-43`), while `seats` keeps its old default (R13), so a run stopped under the
  old default list still matches its fingerprint.

There's one residual gap in R14, minor m1 below: the write happens after `Run`'s
`defer r.release()` (`pipeline.go:120`) has dropped the worktree lock.

## 2. Contradictions and task order

The order builds. B1.2 and B1.3 share only `internal/blueprint` (separate files) and B1.1's
decoder, lock reader, path rule, and exported split. Every cross-task row (e2e, catalog fixtures
passing `check`, converted fixture's findings) sits in the post-merge step. B1.2 needs a new export
in `internal/plan` (m2), which B1.3 doesn't touch, so the pair stays independent. No acceptance row
depends on a later task. I found no contradiction in the text between R1 to R14, S1 to S3, the
tasks, and Close.

## Findings

### B-1. blocker, correctness: the chain module throws at load for every `drafter read` handoff

- Location: B1.4 "It builds one `handoff.Handoff` per blueprint ... `Context` carries
  `{"resolved": {"pages": [<entry>]}}`"; B1.5 step 6.
- Defect: `docs-page-chain.js:569-570` reads `args`, and `:606-608` throws "docs-page-chain needs
  args.worktree, args.gate, and args.pages" when any of the three is missing. That throw runs
  before `if (HOST) return DRAFTER_SEATS;` (`:2261`). `prompts.Load` runs the whole body
  (`prompts.go:86-101`) and returns the rejected promise as a load error. The plan's Context carries
  no `args`, so `hostFor` substitutes `{}` (`start.go:305-307`). `newRunner` then fails in
  `loadModules` (`start.go:181`, and `resume.go:78` on a resume), and every `drafter read` exits 2.
  The fold kept the seat's prompt free of `WT` and `OUTLINE` (mechanics 5) but missed the
  load-time guard.
  - Nothing in B1.4 catches it. The pipeline rows use the fake module, and the parity matrix
    supplies full `args` (`tests/fixtures/drafter/matrix.json:3-24`). The first failure would be
    B1.5 step 6's first live read: no spend, but it needs a drafter code change that B1.5 doesn't
    allow (B1.5 may only edit the seat's prompt), so it stops the line.
- Fix: B1.4's handoff Context carries `args` too, as
  `{"args": {"worktree": <project>, "gate": <gate.command>, "pages": [{"id": <slug>, "path":
  <page>, "track": ""}]}, "resolved": {...}}`. Or the guard at `:606` is skipped under
  `DRAFTER_HOST`, which is the cleaner fix if no other load-time code reads those args. Add a B1.4
  row in `cmd/drafter/read_test.go`: a handoff built by `read.go` loads the real
  `claude/.claude/workflows/docs-page-chain.js` through `prompts.Load` and renders the
  `blueprint` seat.

### M-1. major, correctness: matching framing citations against the store hides bad citations

- Location: R10 ("drafter collects those citations by matching each backticked token against the
  facts store (`facts.Get`) ... so `refs`, the facts check, the consistency read, and the read's fact
  block all see them"); B1.2's adapted-check fixture "a fact cited ... from framing prose".
- Defect: `Facts.Get` reports false unless exactly one bullet holds the id
  (`internal/plan/facts.go:62-68`). Under R10, a framing citation is collected only when it's
  already well formed and unique. A typo (`f:5dwnh2`) or an id on two bullets is never projected
  into the view, so the facts check never says "in no facts file" or "on 2 bullets"
  (`check.go:415-436`) for framing. `refs` on a doubled id also misses the framing placement. These
  are the failures contract M8 was about. B1.2's fixture can pass with a held fact tagged
  `[candidate]`, so it doesn't prove the gap closed. drafter has no fact-id pattern
  (`factIDRe` takes any leading code span, `facts.go:21`), so the store is the only signal, which
  explains the choice. The claim still overstates what R10 delivers.
- Fix: collect a backticked token when the store holds any bullet with that id, not exactly one.
  That needs an exported count or lookup on `Facts`. Also collect a token whose prefix up to and
  including `:` is shared by every id in the store (cairn's are all `f:`). Add two B1.2 rows: a
  typo'd framing id is a `facts` error, and a doubled one reports "on 2 bullets". If that's judged
  too clever, return to M8's own fold, a `facts` list per framing field that `convert` fills.

### m1. minor, correctness: the lock write runs outside the worktree lock

- Location: R14 and B1.4's lock bullet.
- Defect: `Run` releases its locks before it returns (`pipeline.go:120,133-137`), so `read.go`'s
  read-modify-write of `drafted.lock` runs unlocked. `convert` takes the same lock for its seed
  (B1.3), so a concurrent `convert` or second `read` can lose an entry. R14 also says only "a
  summary with no stop"; `Run` can return a summary and an error together (`pipeline.go:124-129`).
- Fix: `read.go` takes `run.TryLock(<git dir>/drafter.lock)` after `Run` returns, writes only when
  `err == nil && s.Stop == ""`, and leaves the file byte-identical when no accepted id changed.

### m2. minor, correctness: the `*plan.Plan` projection has three unstated parts

- Location: R9; B1.2 ("through `internal/plan`'s logic rather than a copy"), and its files list.
- Defect:
  - The crossLinks check needs a `*plan.Outline`. Its fields are unexported, and it's built only
    from JSON files (`outline.go:16-20,29-66`), so outline.yaml needs a new exported constructor
    in `internal/plan`, which isn't in B1.2's files.
  - The view's `Page` comes from outline.yaml. A page-level finding cites `Page.Lines["path"]`
    (`check.go:287`), a line in another file, under the blueprint's file name.
  - R9 doesn't say where framing citations live in a `Plan`. `Introduction.Facts` carries one line
    for the whole list (`plan.go:50-53`, `check.go:126-128`), so every framing citation would report
    at one line.
- Fix: R9 names the outline constructor (and adds `internal/plan/outline.go` to B1.2's files), the
  line rule for outline-sourced fields (report them in `outline.yaml` at the entry's line, or at
  line 1 of the blueprint), and where framing citations go with their own lines. For example, one
  synthetic `example`-kind item per framing field, with an id outside the item pattern (such as
  `_framing-<field>`) so it can't collide.

### m3. minor, correctness: `fileBlocks` can inline the page and a second, unpinned copy of the blueprint

- Location: R6; B1.4's prompt bullet ("adapted from `structurePrompt(p, "plan")`") and its
  golden-request row.
- Defect: `fileBlocks` inlines every tracked file whose path appears as a token in the rendered
  prompt (`files.go:104-116,178-197`; `assemble.go:131-132`). `structurePrompt` names `${p.path}`
  (`docs-page-chain.js:1729-1731`). rotate's page exists in cairn, so an adapted prompt would inline
  the old page whole. A prompt that names the blueprint path would inline the working-tree copy
  beside drafter's `<head>` copy, which breaks R12 after a resume. The golden row forbids facts and
  excerpt blocks but not these.
- Fix: the golden row asserts there's no `=== file:` block for the page path or the blueprint path,
  and that the blueprint's bytes appear once. The prompt names neither as a bare path.

### m4. minor, correctness: R12's "one version" doesn't cover the outline entry `read.go` puts in Context

- Location: R12; B1.4's handoff bullet.
- Defect: `read.go` builds `Page.Type`, `Inputs.Job`, and the Context entry from outline.yaml before
  `Run`. It can't know `<head>` on a resume, since the state is loaded inside `Run`. If the outline
  is committed between a stop and the resume, the module's `c.page` (`steps.go:52-66`) comes from
  the new outline while the drafter block comes from `<head>`. The facts store is also reloaded
  fresh on a resume (`resume.go:73-77`). Both are minor, since integrity 3's outline and fact
  sensitivity is under Later, but R12 claims more than it delivers.
- Fix: on `--resume`, `read.go` reads `Head` from the run's `state.json` (read-only, before `Run`)
  and builds each entry from `git show <head>:<outline>`. Or R12 narrows its claim to "the blueprint
  and the drafter block".

### m5. minor, correctness: the control read's seeded gaps can trip `drafter check` first

- Location: B1.5 step 8.
- Defect: removing a failure item leaves a `canFail` step with no failure (the recovery check,
  `check.go:182-200`) or a dangling `handledBy` or `from` (`check.go:86-102`). Removing a step can
  orphan a failure's `from`. Each is a `check` error, and B1.4 sets the page aside before any
  request, so the control never reaches the read. If the read wrongly accepts, the throwaway branch
  is also left with a dirty lock.
- Fix: step 8 requires the seeded blueprint to pass `drafter check` first: clear `canFail` or pick
  a step with two failures, and remove a step that no `from` or `requires` names. If the read
  accepts, discard the lock change before returning to `blueprint-pilot`.

### m6. minor, optional: `convert outline` drops the track that R1 hands to B3

- Location: R1 ("how a page names its track is B3's"); B1.3 `convert outline`.
- Defect: cairn's JSON outlines carry a top-level `track` (extend.json's keys include `arm` and
  `track`). Merging `extend.json` and `claude-code.json` into one outline.yaml without it loses
  each page's track, which `registerSectionsFor(track, role)` (`docs-page-chain.js:623-`) needs.
- Fix: carry `track` onto each converted page as an optional field now. Or say under Later that B3
  must recover it from the JSON outlines before B5 retires them.

### m7. minor, optional: "computed as `gitHashObject` runs it" names a helper the new code can't call

- Location: R8; B1.3's seed.
- Defect: `gitHashObject` is a method on pipeline's unexported `*page` (`page.go:371-380`), so
  `internal/blueprint` and `convert` must write their own copy. The command matches. `-w` writes
  an object, and for a committed, clean file `git rev-parse <commit>:<path>` gives the same id
  without writing one.
- Fix: say whether the helper moves to a shared package (such as `internal/run`) or is duplicated.
  Use `rev-parse <commit>:<path>` for committed files (the page seed and the accepted id), and
  `hash-object` only for the new, uncommitted blueprint.

## 3. Whether each new mechanism is quoted from code or proven

| Mechanism | Verdict |
|---|---|
| Git blob ids via `gitHashObject` | Command quoted correctly (`page.go:371-380`); the helper isn't reusable as written (m7) |
| Section regions | Correct: `sections.go:15-27` (the region and `split`), heading line excluded (`:88`), unexported, so B1.1 exports it |
| Projection onto `*plan.Plan` | Stated, not proven: outline constructor, line rule, framing home missing (m2). `plan.Check` takes an in-memory plan (`check.go:49`), and `example` items reach `eachFactsList` |
| Seat excluded from default seats | Correct: `apply.go:29` sets the default to `seatNames`, so R13 needs a separate default list; `validate.go:43-48` validates only `Seats` |
| `DRAFTER_PROMPTS` override | Correct: `env.go:46`, and the env layer follows local (`load.go:43-49`) |
| Backticked-token fact matching | Real format (rotate's framing cites `` `f:…` ``), but `Get`'s exactly-one rule hides bad citations (M-1) |
| Synthetic handoff and Context | `hostFor`, `pageJSON`, and `rehydrate` are as cited, but the real module throws at load (B-1). `prompts.Load` requires resolved pages (`prompts.go:50`), though `hostFor` would synthesize them anyway (`start.go:313-325`) |
| Other citations | All checked and accurate: `consistency.go:20-30,73`, `assemble.go:106-150`, `record.go:138`, `decode.go:25`, `plan.schema.json:227`, `start.go:104-115,160-168`, `pipeline.go:157,271`, `money.go:120-123`, `config/check.go:96-100`, `layer.go:22`, `configuration.md:268-274`, cairn's anatomy entry names (`docs-register.md:762,770,807,818`), and `kept` holding `migration-notes.md` |

## 4. Departures from the design's literal text

Each departure is justified by the design's own principles, and none needs a ruling. Each should be
a visible row in the approval packet, so Geoff can veto it on the evidence below.

- No `page` block, with job and type only in the outline. The design puts "the page's job, type,
  ..." in the blueprint (design:107), and also puts "jobs, and types" in outline.yaml
  (design:133). Keeping both would give one fact two homes, against design:90-92. Justified.
- No `registerSections` field. The design lists register sections in the blueprint (design:107).
  The chain derives them from track and role alone (`registerSectionsFor`), so a per-page copy
  would duplicate config. Justified, but it leaves B3 to find each page's track (m6).
- No commit field, and blob ids for hashes. This changes design:157-159 and the
  `git show <lock commit>:<page>` in design:306. The lock's format is "Left to the builder", and a
  commit can't name itself. `git cat-file blob <id>` serves B4's diff. Justified. The packet should
  say that B4's hunk diff now reads the blob, not a commit.
- Framing "Departures" dropped. Format change 4 (design:243-246) sends planning history to the
  commit message, and the converter prints it there. Justified.
- Settled rulings S1 and S2. S1 (a miss closes B1) is a scope call. S2 means every converted page
  redrafts once. That keeps design call 15's letter ("redrafted only when its blueprint changes",
  since the reshape is a change) but drops its "at no cost" effect. The spend lands in B3 and B4,
  on pages the pilot drafts anyway (design:526-527). Both are reasonable under the standing
  approvals. Since they're scope and budget, the packet should list them as routine rows with
  their reasons, not as "None" under rulings.

## 5. The path estimate

B1.1 (180) + the pair at the larger of 130 and 120 (130) + the post-merge rows (15) + B1.4 (210) +
B1.5 (160) + Close (60) = 755. That's 2.52x the design's 300 and under the 900 approval. Correct.
