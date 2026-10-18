# drafter pass B1 plan: the blueprint format and the blueprint read

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-17-blueprint-architecture-design.md`,
approved by Geoff on 2026-10-17 with two review fixes folded (commit `b3665ea` on branch
`docs-system-blueprint-design`). Sections this pass builds: "Blueprints" (all of it, including
"Layout", "Managed pages", "Bootstrapping" item 1, "`drafter check`", "Fitting the format to its
jobs", and "The edit catalog"), and "The pilot" first milestone. It amends
`specs/2026-10-12-drafter-pipeline-design.md`, whose stage 1 ("Plan check") and stop table this pass
extends. Planning fact sheet (paths and line numbers at drafter `d3447d9`): `research/2026-10-17-drafter-b1-factsheet.md`.
Review fold: `research/2026-10-17-drafter-b1-plan-fold.md` (three lenses and the fold's verification
read, `research/2026-10-17-drafter-b1-fold-verification.md`, folded at this revision).

## Outcome

drafter reads, checks, and converts blueprints. `drafter check` validates every blueprint in a
project offline in seconds, `drafter refs <fact-id>` lists every placement and citation of a fact,
and `drafter convert` turns a v1 plan and its framing record into a blueprint and seeds the page's
`drafted.lock` entry. `drafter read` runs stage 1 on blueprints through the API: the local check,
then the consistency read and a new `blueprint` read seat in one batch, the read taking over the
chain's plan read. When the run ends with every page decided, it records each accepted blueprint's
id in the lock. The pass ends live: cairn's `rotate-the-github-app-key` plan is converted, reshaped
to the format's rules, and fixed until its blueprint passes `drafter check` and reaches `accepted`
in the blueprint read, run by hand. That is the pilot's first milestone. A miss closes the pass
with the miss classified (settled ruling 1).

## Build sequence

The design is built in five passes, in order. Only B1 is planned here; each later pass is planned
when the one before it merges, from what B1's pilot shows.

Erratum, 2026-10-18: the approved onboarding design (`specs/2026-10-18-drafter-onboarding-design.md`)
sets the order as change-read, F (foundations), B3, O (onboarding), B4, B5. B3 also writes the stock
seat prompts and the provenance check, and B5 also splits cairn's register into the base and its
overlay. That design's build order governs where it differs from the list below.

1. B1, this pass: the format, `check`, `refs`, `convert`, the blueprint read, and the first cairn
   blueprint accepted by hand.
2. B2: the blueprint skill with its new-page reference file, the advisory `PreToolUse` hook, and the
   format test (a Sonnet agent at medium effort, four of five catalog tweaks passing on the first
   try).
3. B3: drafting from blueprints. The handoff becomes internal, `drafter page` takes blueprints,
   section redrafts with the edit contract, the coherence read, the lock written on accept, and
   the remaining non-figure stage 2b plans converted.
4. B4: the nightly run (detection, the write-back seat, commits, the one pull request with merging
   off, the report, the timer, the registry, and the GitHub token). Code that holds the token or
   decides a merge is a candidate for `auth-data`, which Geoff rules at B4's design.
5. B5: the migrations. cairn moves `docs/internal/briefs/` and `docs/internal/facts/` under
   `blueprints/`, retires its JSON outlines for `blueprints/outline.yaml`, and adds `drafter check`
   to its gate; the workstation changes under the design's "Changed" table land.

## Shape

- Risk class: `runner`, because B1.4 adds the `blueprint` seat to the docs page chain
  (`claude/.claude/workflows/docs-page-chain.js`), a workflow, and B1.5 may edit that seat's
  prompt. Every other task is `ordinary`. B1.4 adds a stage without editing
  `internal/pipeline/money.go` or `internal/pipeline/resume.go`; a change to either file stops the
  line, since the money path is `auth-data` by Geoff's pass 5 ruling.
- `live-account`: yes. B1.5 spends API credit.
- Repos and branches:
  - `glw907/drafter` at `~/Projects/drafter`: the executor launches from the main checkout and works
    in the worktree `EnterWorktree` creates (name `b1-blueprint-format`).
  - `glw907/cairn-cms` at `~/Projects/cairn-cms`, through the `cairn-pass` adapter: B1.5 runs
    `git -C ~/Projects/cairn-cms fetch origin`, then `git -C ~/Projects/cairn-cms worktree add
    .claude/worktrees/blueprint-pilot -b blueprint-pilot origin/main`, and runs cairn-pass's setup
    command there. cairn's main checkout is never touched.
- Gates: drafter, from its worktree, `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` (`make
  check` under `cairn-run-gate`), re-issued on exit 75. drafter has no CI (no `.github/`), so this
  gate once on the close head is the full-suite home. cairn: cairn-pass's fast lane, with CI on the
  draft PR as the full-suite home and `ci-green <sha> --pr <n> --wait` as a background watch.
- Baseline: before B1.1, the drafter gate runs once on the fresh worktree. A red baseline stops the
  line, since every later red would be ambiguous.
- Clock file: the drafter worktree's git dir for B1.1 to B1.4 and Close; the cairn worktree's git
  dir for B1.5 (settled ruling 3). A wait on Geoff removes the clock file first.
- Path estimate: 780 minutes. B1.1 (180), B1.2 and B1.3 as a pair (140) plus the post-merge rows
  (15), B1.4 (225), B1.5 (160, not counting batch waits), Close (60). The design's estimate is 300
  path minutes, set from recent actuals (pass 4 planned 285 and ran about 70; pass 5 was not
  measured). The path was 600 before the review fold; the fold added the blueprint view, the hash
  and lock rules, the read's request block, and the lock-after-run write, and dropped the live
  smoke run; the fold's verification added the module load fix, the framing citation rule, and the
view's outline constructor. The path is 2.6x the estimate, inside the 3x approval.
- Pair subagents run on `sonnet` at `medium` with the `description` `b1-blueprint-format task <n>`.
- Standing approvals (Geoff, 2026-10-17):
  - The plan proceeds within 3x its design estimate (900 path minutes).
  - Live spend up to $10 for this pass runs without asking. The meter is `drafter spend --since
    2026-10-17 --json`: its `total` plus `open.worst`. It reads the one user ledger, so it counts
    every drafter spend since that date, which errs safe. Each live run carries
    `DRAFTER_PAGE_CAP` set to the smaller of 5 and 10 minus the meter. When that cap would fall
    under $1, the pass stops for Geoff.
  - A live run stops for Geoff, after `notify-send -u normal`, when it exits 3 with `cycle cap` or
    `spend limit`, or exits 1 with a page escalated on rule `cap` (`internal/pipeline/money.go:120-123`). Any other
    exit 3 gets one `drafter read --resume <run-id>` with the same blueprint argument; a second
    exit 3 stops for Geoff.
  - The blueprint's content fixes in B1.5 are made by the executor from cairn's code, each new claim
    cited to a fact, and the cairn PR goes to Geoff for review.
- Depends on, checked at launch:
  - One executor per worktree: `pgrep -af 'drafter|cairn-cms'` shows no other session working
    either repo; `git -C ~/Projects/drafter status --short` and `git -C ~/Projects/cairn-cms status
    --short` are clean; `git worktree list` in both repos shows no live worktree named
    `b1-blueprint-format` or `blueprint-pilot`. Warm changes you didn't author stop the launch.
  - drafter `origin/main` at or after `d3447d9` (pass 5 and the repo-organization pass merged).
  - `DRAFTER_API_KEY` in `~/.local/secrets` (check by name only).
  - `~/.config/drafter/config.toml` and `~/.config/drafter/cairn-cms.local.toml` present from
    pass 5.
  - No stopped drafter run and no open reservation: `drafter spend --json` shows `open.count` 0.

## Design resolutions

The design leaves these to the builder. The plan takes them so the executor doesn't have to.

1. Each page fact has one home. Job, type, title, and path live only in the page's `outline.yaml`
   entry and the path rule, and drafter joins the entry to the blueprint when it builds a read or
   draft input. The blueprint has no `page` block. A field kept in both would go stale in one; call
   5 already counts an outline-entry change as a page change. The blueprint holds `exemplars`, in
   the shape cairn's JSON outlines give them (`source`, `slice`, `manifestType`, `take`).
   `registerSections` is not a blueprint field: `register.<track>` (`docs/configuration.md:268-274`)
   already holds the register sections per track, and how a page names its track is B3's, since
   only drafting reads them.
2. `check-plan` stays unchanged. The chain's front half still calls it for figure pages and the
   unconverted plans. `drafter check` is a new command for blueprints. `check-plan` retires with the
   chain.
3. Section references in prose fields use `[[<section-id>]]`. `drafter check` resolves each one
   against the blueprint's section ids and reports an unknown id as an error. A plain YAML value
   can't start with `[[`: probed on drafter's yaml pin, `why: [[verify]] carries the checks` is a
   parse error and `why: [[verify]]` decodes as a sequence. The format page says to quote such a
   value or use `|`, and a prose field that decodes as a sequence is a decode error naming that fix.
4. A placement's `use` is optional, as in v1 (`internal/plan/decode.go:25`); a `fact` item with no
   `use` places the whole fact. A `use` that is present starts with `Only` or `Omit` (format change
   1). `drafter check` enforces the opening word, and the blueprint read judges whether the rest
   restates the fact.
5. The converter does the mechanical mapping and nothing that needs judgment. It never writes a
   section's `why`, and `drafter check` reports a missing `why` as an error. A converted blueprint
   therefore fails `check` until someone reshapes it, which keeps the judgment work visible.
6. The blueprint read is a seat named `blueprint`, rendered through the project's prompts module
   (call 23), answering in the existing read schema (`assemble.AnswerRead`: verdict, findings with
   location, finding, rewrite, and blocking, and summary). The module's prompt carries the
   instructions and names the register, which `fileBlocks` inlines as it does for the structure
   seat (`internal/assemble/assemble.go:106-150`). drafter appends one block it builds itself: the
   blueprint's bytes, the page's outline entry, and the bullet of each fact the blueprint places or
   cites, from `placedFacts` and `facts.Get` as `ConsistencyPrompt` uses them
   (`internal/assemble/consistency.go:20-30,73`). `fileBlocks` never scans that block, and the
   seat sends no code excerpts. A blocking finding sets the page aside with rule `plan` and seat
   `blueprint`; drafter never edits a blueprint in B1.
7. `drafter read` stops after stage 1. The tree must be clean, as for `drafter page`, so each
   read round runs on a committed blueprint and the round history is the git log.
8. The lock's hashes. A page or blueprint hash is the file's git blob id. For a committed file
   (the page seed and the accepted id) it's `git rev-parse <commit>:<path>`; for the new,
   uncommitted blueprint it's `git hash-object -- <file>`, the command pipeline's unexported
   `gitHashObject` runs (`internal/pipeline/page.go:371-380`) without its `-w`. The new code shells
   out itself rather than calling that helper. B4 retrieves drafter's last text with
   `git cat-file blob <id>`. The lock has
   no commit field: an entry committed with its page can't name that commit. A section hash is
   `sha256:<hex>` (`hashBytes`, `internal/pipeline/record.go:138`) over the section's region as
   coverage splits a page (`internal/coverage/sections.go:16-26`), with the text above the first
   planned heading under the key `_intro`. A section with no matching heading gets no key, and a
   missing key reads as changed.
9. The blueprint view. `internal/blueprint` projects a blueprint and its outline entry onto a
   `*plan.Plan`, keeping line numbers. The shared checks (`plan.Check`), the consistency prompt,
   and coverage's split run on the view unchanged. An `example` item's facts enter the view's
   placed facts. Three parts complete it:
   - The crossLinks check needs a `*plan.Outline`, whose fields are unexported and which only JSON
     files build (`internal/plan/outline.go:16-20,29-66`), so `internal/plan` gains an exported
     constructor from paths, slugs, and crossLinks.
   - The view's `Page` comes from the outline entry and the path rule, so a finding on a page-level
     field cites line 1 of the blueprint.
   - Each framing field with citations becomes one synthetic `example` item in the view, its
     `facts` the field's citations and its line the field's line, with the id `_framing-<field>`,
     which the item pattern can't produce. `eachFactsList` (`internal/plan/check.go:122-130`) and
     `refs` then see them.
10. The `framing` block holds the framing record's four descriptive sections ("Who arrives, from
    where, and why", "Background the page rests on", "Place in the doc set", "Intro plan").
    "Departures from the plan's introduction" narrates the planning session's moves against the old
    plan, which format change 4 puts in the commit message, so the converter drops it. Framing
    prose cites a fact as a backticked id, as the records do today. drafter has no fact-id pattern
    (`factIDRe` takes any leading code span, `internal/plan/facts.go:21`), so the store supplies
    one: a backticked token is a citation when the store holds any bullet with that id, or when it
    starts with the prefix every id in the store shares through its first `:` (cairn's `f:`).
    `Facts.Get` alone won't do, since it hides an id on no bullet or on two
    (`internal/plan/facts.go:62-68`), so `Facts` gains an exported count or id list. A typo'd id
    then reaches the facts check as "in no facts file" and a doubled one as "on 2 bullets"
    (`internal/plan/check.go:419-436`), and `refs`, the consistency read, and the read's fact
    block see every citation.
11. Section ids and item ids share one namespace, unique within the blueprint, with the item id
    pattern `^[a-z0-9][a-z0-9_-]*$` (`schema/plan.schema.json:227`).
12. The read reads one version of the blueprint and its outline entry. Every stage-1 input for a
    blueprint page (the local check, the consistency read, and the blueprint read) loads the
    blueprint and the outline from `git show <head>:<path>`, where `<head>` is the commit the run
    started at (`internal/pipeline/start.go:160-168`, `r.state.Head`). On `--resume`, `read.go`
    reads `Head` from the run's state before calling `Run` (`run.LoadState`,
    `internal/run/state.go:116`, in the run directory `internal/pipeline/resume.go:38-45`
    computes) and builds the handoff's outline entry from that commit too. The accepted id is the
    blueprint's blob id at `<head>`. A blueprint committed during a batch wait, or between a stop
    and its resume, is never stamped as accepted. The facts store is the exception: a resume
    reloads it from disk (`internal/pipeline/resume.go:73-77`), which Later's fact item covers.
13. The `blueprint` seat joins `seatNames` but not the default `seats` list
    (`internal/config/apply.go:29`), so `drafter page` validates and runs as before on every
    existing config. `drafter read` always runs the seat, validates it itself, and refuses to start
    (exit 2) when `[seat.blueprint]` is incomplete.
14. The lock is written once per run, after the run ends. `Run` releases its locks before it
    returns (`internal/pipeline/pipeline.go:120`) and can return a summary with an error
    (`pipeline.go:124-129`). So `cmd/drafter/read.go` takes `run.TryLock` on
    `<git dir>/drafter.lock` itself, and writes `drafted.lock` only when `Run` returned no error
    and no stop, from each accepted page's blueprint id. It leaves the file byte-identical when no
    accepted id changed. A stopped run leaves the lock untouched, so `checkTree`
    (`internal/pipeline/resume.go:257-304`) never meets a lock change it doesn't own, and the
    resume path runs unchanged. A crash after the run ends and before the lock write loses that
    acceptance; the recovery is to read again.

## Settled by the planning session

These were owner forks in the review. The planning session ruled them under the standing approvals,
each for the reason given.

1. A missed milestone closes B1 (contract M2). The drafter PR proceeds; the cairn PR carries the
   blueprint as reached, marked not accepted; the drafter PR says "missed" with the classification.
   Reason: the build has its own acceptance, and pass 5's "not pilot-ready" close set the precedent.
2. Converted pages redraft once (integrity 6). The convert seed records the conversion output's
   blueprint id, so the reshape counts as a blueprint change and each converted page redrafts once
   at B3 or B4. Reason: the 11 stage 2b pages are meant to be drafted, and a seed that absorbed the
   reshape would also hide the pilot's content fixes from the page. `docs/blueprint-format.md`'s
   lock section says so.
3. The clock during batch waits (mechanics 14). B1.5 writes the clock in the cairn worktree's git
   dir, removes it while a batch read is in flight, and rewrites `start=` when the read returns.
   Batch mode stays. Reason: batch halves the read's cost, and the wait is not work.

## Out of scope

The blueprint skill, the hook, and the format test (B2); drafting from blueprints, section
redrafts, the coherence read, and lock writes on a draft (B3); `drafter status`, `drafter nightly`,
the write-back seat, bootstrapping by the write-back seat, the pending fact tag, and the timer (B4);
cairn's directory move, its gate change, and every workstation change in the design's "Changed"
table (B5); figure pages; the stock prompts module.

## Tasks

Every drafter task starts by invoking `go-conventions`. The fixtures are synthetic: no cairn text
and no workstation path goes into drafter.

### B1.1 The blueprint format (180 min, ordinary)

- Outcome: a new package, `internal/blueprint`, decodes three files, each with `version: 1`:
  - A blueprint (`*.blueprint.yaml`). It starts from plan format v1's fields and item kinds and
    changes them as the design's "Fitting the format to its jobs" says:
    - A required `id` on every section (resolution 11).
    - A required per-section `why`, and a page-level `orderReason` that explains only the order as
      a whole.
    - A `framing` block with the four descriptive fields (resolution 10).
    - `exemplars` (resolution 1).
    - An `example` item kind, for a worked example in prose: `text` required, `facts` optional.
    - `origin: human` on any item.
    - `styleNotes` on a section, each holding the old and new wording.
    - An optional `review: human`.
    - No `page` block, no `friction` field, and no `registerSections` (resolution 1).
      `constraints` stays, for rules specific to the page.
  - `outline.yaml`, holding:
    - `types`, each with the `anatomy` it follows: the name of a register anatomy entry, such as
      `Task guide`.
    - `pages`, each with `path`, `slug`, `title`, `type`, `job`, `covers`, `outOfScope`, `figure`,
      and `managed` (default true). An entry with `managed: false` needs only `path`.
    - `crossLinks`.
  - `drafted.lock`, holding one entry per page, keyed on the page path: the page's blob id and
    the blueprint's blob id at drafter's last write, one hash per section id, and the blueprint id
    the blueprint read last accepted (resolution 8). Only drafter writes it.
  - A writer for `drafted.lock`, through `atomicfile.WriteFile`, with entries sorted by path so its
    diffs are stable.
  - The blueprint view (resolution 9), and the section hash, which needs coverage's split exported.

  The decoder follows `internal/plan/decode.go`'s approach: it walks the `yaml.Node` to catch
  duplicate keys, refuses fields outside a kind's set, and keeps line numbers for findings.
  `schema/blueprint.schema.json` and `schema/outline.schema.json` match the Go struct tags, and a
  test enforces it, as `internal/plan/schema_test.go` does for plans. The path rule maps a page
  path to its blueprint path and back: `<root>/<page path without .md>.blueprint.yaml`, with root
  `blueprints` by default.
- `docs/blueprint-format.md` is the format's one home. It covers:
  - every field and item kind, with who sets each privileged one (`origin: human`, `review: human`,
    `managed: false`, the lock's fields)
  - the layout and the path rule
  - `outline.yaml`
  - `drafted.lock`, its hash rules, and that a converted page redrafts once (settled ruling 2)
  - the section-reference syntax and its quoting rule
  - the `use` rule
  - the edit catalog, copied from the design's table and mapped to the kinds

  It's written in the Google developer documentation style. `README.md` links it.
- Files: `internal/blueprint/` and its tests and `testdata/`, `internal/coverage/` (the exported
  split), `schema/blueprint.schema.json`, `schema/outline.schema.json`, `docs/blueprint-format.md`,
  `README.md`.
- Acceptance:
  - A table-driven decode test covers each item kind including `example`, and each new field.
  - Each refusal has its own test: a missing section `id`, a duplicate id across sections and
    items, an id off the pattern, a field outside a kind's set, a duplicate key, `friction` or
    `page` present, an unknown kind, and a prose field that decodes as a sequence.
  - The schema tests fail when a struct field is added without its schema entry.
  - A round-trip test writes a lock and reads it back equal, with entries in path order.
  - A path-rule table covers `docs/extend/x.md`, the root `README.md`, and a nested path, both ways.
  - A docs test fails when a blueprint field the decoder knows is missing from
    `docs/blueprint-format.md`, as `internal/plan/docs_test.go` does for plans.
  - The view of a fixture blueprint lists, as placed facts, the ids from `fact` items, every
    `facts` list, an `example` item, and a framing citation.
  - Section hashes: a fixture page with a preamble, a level-2 section, a level-3 child, and a
    section with no matching heading gets hashes equal to `sha256sum` over byte ranges written
    into the test, an `_intro` key, and no key for the unmatched section.
  - An edit-catalog test takes one synthetic base blueprint and, for each catalog row except
    "Start a new page" and "Follow a rename the gate demands", holds an after fixture. Each after
    fixture decodes, differs from the base, and differs only in items of the kinds the row names,
    inside one section (except "Add or move a section"). The fact-bullet rows also change a
    fixture facts file. B1.2 extends the test to assert `check` passes.
- Test: the drafter gate.

### B1.2 `drafter check` and `drafter refs` (140 min, ordinary)

- Outcome: `drafter check [--root dir] [--json] [<blueprint>...]` validates every blueprint under
  the project's blueprint root, or the ones named, offline.
  - It runs the v1 checks on the blueprint view (resolution 9): decode, ids, reader-state,
    recovery, links, crossLinks, and facts, through `internal/plan`'s logic rather than a copy.
  - It adds these checks:
    - Every managed page in `outline.yaml` has exactly one blueprint, and every blueprint names a
      page in the outline. The first part is a warning until `blueprints.required = true`, and an
      error after.
    - Every `[[id]]` resolves to a section id.
    - Every section has a non-empty `why`.
    - Every `use` that is present starts with `Only` or `Omit`.
    - The page's outline `type` is one that `types` declares, and that type's `anatomy` is non-empty.
    - `drafted.lock` parses. An entry carrying a page blob id names a page that exists. An entry
      with only an accepted id names a page the outline lists, which is a page not drafted yet.
    - A warning when the blueprint root or the facts dir departs from the convention (design
      "Layout").
  - The output and exit codes match `check-plan`'s: `file:line: severity: check: message (fix)`, 1 on
    any error, and 2 when it can't run. It reports every file's findings and continues past a file
    that fails to decode.
  - `drafter refs <fact-id> [--root dir] [--json]` lists every blueprint item, on every page, that
    places or cites the fact (`fact` items, every `facts` list, the introduction's facts,
    dispositions, and framing citations), one `file:line: item-id (kind)` per line. It exits 1
    when there are none, with a message that says whether the facts store holds the id.
  - New settings, each in `docs/configuration.md`, which `internal/config/docs_test.go` enforces.
    `blueprints` goes in `allowedIn` for the project and local layers (`internal/config/layer.go:22`),
    with no environment variable:
    - `blueprints.root` (default `blueprints`)
    - `blueprints.required` (default false)
    - `blueprints.outline` (default `<root>/outline.yaml`)
    - `facts.dir` (unchanged). When it's unset and `<root>/facts` exists, it defaults there.
- Files: `internal/blueprint/` (the check and refs), `internal/plan/outline.go` and
  `internal/plan/facts.go` (R9's constructor and R10's count), `cmd/drafter/check.go`,
  `cmd/drafter/refs.go` and their tests, `internal/config/` and its docs test, `docs/configuration.md`,
  `docs/blueprint-format.md` (the checks section).
- Acceptance:
  - Each new check has a failing fixture and a passing twin.
  - Each adapted v1 check has a failing blueprint fixture asserting its check name, including a
    fact cited from an `example` item and from framing prose.
  - Framing citations: a typo'd framing id is a `facts` error "in no facts file", and an id on two
    bullets reports "on 2 bullets", each at its framing field's line.
  - A synthetic project with a managed page and no blueprint warns with `blueprints.required` false
    and errors with it true.
  - Each "can't run" state has a row with its exit code and message: no blueprint root, no
    `outline.yaml`, a malformed `outline.yaml`, a malformed `drafted.lock`, and a named file that
    isn't a `.blueprint.yaml` at its path-rule location. An absent `drafted.lock` is valid.
  - `refs` on a fixture fact placed twice, cited once in an item, and cited once in framing prose
    prints four lines; an id the store doesn't hold and a held id with no placements both exit 1
    with different messages.
  - `check-plan`'s tests are unchanged and pass.
- Test: the drafter gate.
- Pair: with B1.3. Neither task touches `cmd/drafter/root.go` or `e2e/`. After it merges the pair,
  the session registers both commands in `root.go` and adds the post-merge rows (15 min): an e2e
  row that builds the binary and runs `check`, `refs`, and `convert` on `e2e/testdata`, asserting
  the exit codes; the edit-catalog fixtures passing `check`; and B1.3's converted fixture reporting
  exactly its expected `check` findings.

### B1.3 `drafter convert` (120 min, ordinary)

- Outcome: `drafter convert` has two subcommands.
  - `drafter convert outline [--out file] <outline.json>...` writes `outline.yaml` from the chain's
    JSON outlines. It takes each entry under `pages`: `path`, `slug`, `title`, `pageType` as `type`,
    `job`, `covers`, `outOfScope`, and `figure`, plus the top-level `crossLinks`. It declares every
    distinct type with an empty `anatomy`, which `check` then reports. It doesn't map `kept`.
  - `drafter convert plan [--framing file] --outline <outline.json> [--root dir] <plan.yaml>` writes
    the page's blueprint at its path-rule location.
    - It maps every v1 field and item, dropping `page` (resolution 1).
    - It derives each section `id` from its anchor or heading slug. An id that collides takes a
      `-2`, `-3` suffix and goes on the judgment list.
    - It copies the framing record's four descriptive sections into `framing` by heading, skips
      the `# Framing record:` title line, and refuses a heading it doesn't know, naming it.
    - It takes `exemplars` from the page's entry in the JSON outline.
    - It drops `friction` and the framing's "Departures" section, printing both to stderr: the
      friction lines go to a friction log, and the departures to the conversion's commit message.
    - It writes only the fields a value sets, keeping a required-empty `items: []`. A probe on
      drafter's yaml pin shows `omitempty` drops `items: []` and its absence writes zero values,
      either of which the decoder refuses.
    - It leaves every `why` unwritten.
    - It creates the blueprint exclusively and never overwrites a file.
    - When the page exists, it seeds the page's `drafted.lock` entry under the worktree lock
      (`run.TryLock` on `<git dir>/drafter.lock`, as `internal/pipeline/start.go:104-115` takes
      it). The seed records the page's blob id at HEAD, the converted blueprint's blob id, and one
      hash per section matched by heading. The accepted id stays empty (call 15). It refuses a
      page with uncommitted changes and a page the lock already has an entry for. After a crash
      between the two writes, the recovery is to delete the blueprint and convert again, since
      conversion is free and deterministic.
    - It prints the blueprint path and what needs judgment: each section with no `why`, each `use`
      that doesn't start with `Only` or `Omit`, each suffixed id, and each heading reference in a
      prose or framing field.
- Files: `internal/blueprint/convert.go` and its tests, `cmd/drafter/convert.go` and its test,
  synthetic fixtures (a v1 plan, a framing record with a "Departures" section, a JSON outline with
  exemplar objects).
- Acceptance:
  - Converting the synthetic v1 plan keeps every item's id, kind, and fields, and the framing
    record's four sections, which a test checks field by field. The fixture holds a level-2 section
    with empty items, one `use` opening with `Only`, and one that doesn't.
  - The converted file decodes.
  - A record with an unknown heading is refused, and the "Departures" text appears on stderr only.
  - An existing blueprint is never overwritten, and an existing lock entry is refused.
  - A page with uncommitted changes is refused.
  - The seed's page id equals `git rev-parse HEAD:<page>` in a fixture repo, and its section hashes
    equal `sha256sum` over byte ranges written into the test.
  - Two sections whose headings slug alike get distinct ids, both listed.
  - `convert outline` on a two-page fixture writes both pages and declares both types.
- Test: the drafter gate.
- Pair: with B1.2.

### B1.4 The blueprint read and `drafter read` (225 min, runner)

- Outcome: stage 1 runs on blueprints.
  - A blueprint page starts at a new local step, which runs `drafter check`'s logic on the
    blueprint view. Its next step sends one stage-1 batch holding the consistency read, when the
    project has a facts store, and the `blueprint` read, so `stepSeats` returns both. Both requests
    are built from the inputs at `<head>` (resolution 12). The consistency prompt takes the
    blueprint view unchanged.
  - The seat is added where the fact sheet's section 3 names, with resolution 13's validation:
    - `config/check.go`'s `seatNames`, and `config/apply.go`'s default `seats` without it
    - step constants in `work.go`
    - `advance` in `steps.go`
    - `stepSeats`, `validate`, and `complete` in `handle.go`
    - the smoke shape table in `internal/smoke`, as a `read` answer at `medium`

    Its answer is `assemble.AnswerRead`. Its request is resolution 6's: the module's prompt with
    `fileBlocks`, then drafter's block, through a field on `assemble.Input` that `fileBlocks` never
    scans.
  - The chain module loads under drafter with no chain args. Its guard
    (`docs-page-chain.js:606-608`) throws on a missing `args.worktree`, `args.gate`, or
    `args.pages` before `if (HOST) return DRAFTER_SEATS` (`:2261`), and `read.go`'s handoffs carry
    none. The guard runs only when `HOST` is unset. Supplying args instead would need a real
    `track` per page, since `:649` runs `registerSectionsFor` on every `args.pages` entry and it
    throws on an unknown track (`:634`), and B1's outline carries no track. The Workflow run keeps
    its guard, and the parity matrix supplies full args, so both are unchanged.
  - The prompt is a `blueprint` export in the chain's prompts module, `claude/.claude/workflows/
    docs-page-chain.js`, added to `DRAFTER_SEATS`. It reads only `c.page` and module constants that
    don't depend on `args.worktree` or `args.outline` (so not `common` or `registerLine`). It
    names no facts file, and neither the page path nor the blueprint path as a bare path, since
    `fileBlocks` would inline either (`internal/assemble/files.go:104-116,178-197`). It's adapted from
    `structurePrompt(p, "plan")`:
    - order, pace, and user goal
    - the introduction's three parts
    - completeness of steps and failures

    It adds these:
    - a reader-state read (a step whose prerequisite a reader can't hold at that point)
    - a recovery read (a failure with no step where it occurs, and recovery named before diagnosis)
    - a report of each `use` that restates its fact's content
    - a report of each durable field that narrates planning history
    - a report of each human-origin item the blueprint would bury

    Its bar is the chain's: any blocking finding means `fix`.
  - `drafter read [--dry-run] [--sync] [--json] [--resume <run-id>] <blueprint>...` runs the
    pipeline through stage 1 only, on the same run directory, locks, clean-tree refusal, ledger,
    and records as `drafter page`.
    - It builds one `handoff.Handoff` per blueprint: `Plan` is the blueprint path, `Framing` is
      empty, `Checksum` is `handoff.Checksum(project, blueprint, "")`, `Page.Path` comes from the
      path rule, `Page.Brief` from the layout, and `Page.Type` and `Inputs.Job` from the outline
      entry. `Context` carries `{"resolved": {"pages": [<entry>]}}`, the entry in the JSON
      outline's shape, which `prompts.Load` requires (`internal/prompts/prompts.go:50`) and
      `pageJSON` returns to the module (`internal/pipeline/steps.go:52-66`). `rehydrate`
      (`internal/pipeline/resume.go:154-187`) then runs unchanged on a resume given the same
      blueprints.
    - When the run ends with no stop, it writes each accepted page's blueprint id at `<head>`
      into the lock as the accepted id, through the B1.1 writer (resolution 14). The page entry is
      created if missing. `PageResult` carries the id to `read.go`.
    - On `fix`, it sets the page aside with the findings printed.
    - The resume hint names `drafter read --resume`, through a command name in `Options`, since
      `summary` and `finish` hardcode `drafter page` (`internal/pipeline/pipeline.go:157,271`).
    - Exit codes match `drafter page`'s: 0 when all are accepted, 1 when any is set aside, 2 when
      it can't start, and 3 when it stopped resumable.
  - `money.go` and `resume.go` are not edited.
- Files: `internal/pipeline/` (`work.go`, `steps.go`, `handle.go`, `check.go`, `page.go`,
  `pipeline.go`, `start.go`, a new input builder from a blueprint and its outline entry) and tests,
  `internal/assemble/` and tests, `internal/config/` (`check.go`, `apply.go`, `validate.go`) and
  tests, `internal/smoke/`, `cmd/drafter/read.go` and its test,
  `claude/.claude/workflows/docs-page-chain.js`, the prompts-parity matrix and fixtures under
  `tests/`, `e2e/`, `docs/prompts-module.md` and `docs/configuration.md` (the seat, and the "seven
  seats" sentences), `README.md` (the commands).
- Acceptance, against the fake `pipeline.API` with a facts store present unless a row says so:
  - A blueprint whose read answers `accept` ends accepted, and its lock entry holds the blueprint's
    blob id at the run's start commit.
  - A `fix` answer sets the page aside with rule `plan`, seat `blueprint`, and the findings in
    the record, and a lock entry holding an earlier accepted id is unchanged.
  - A `check` error sets the page aside before any request, and the fake records zero
    `CountTokens` calls.
  - Two blueprints, one `accept` and one `fix`, leave exactly one new accepted id in the lock.
  - Two blueprints, stopped with the second page's batch in flight after the first page's settles,
    write no lock; `--resume` ends with both pages decided, one settle line per `custom_id`, and
    the accepted page's id in the lock.
  - A blueprint edited and committed after a stop: the resume reads and records the start
    commit's version.
  - Golden request: the `blueprint` request holds the fixture blueprint's bytes, its outline entry,
    the bullet of each placed and cited fact, no bullet for an unplaced fact, no facts-file or
    code-excerpt block, no `=== file:` block for the page or the blueprint path, and the
    blueprint's bytes exactly once.
  - Real module: a `cmd/drafter/read_test.go` row builds the handoff as `read.go` does, loads
    `claude/.claude/workflows/docs-page-chain.js` through `prompts.Load` with that handoff's host,
    and renders the `blueprint` seat.
  - Every `Create` the fake records follows a reserve line, as in pass 5's money rows, which run
    unchanged and pass.
  - `--dry-run` prints both stage-1 requests' estimates, submits nothing, and writes no lock.
  - `drafter read` with no `[seat.blueprint]` exits 2; `drafter page` on a v1 handoff with a
    config that has no `seats` list and no `[seat.blueprint]` validates, and its request sequence
    is unchanged.
  - The prompts-parity test renders the `blueprint` seat byte-identically in Node and goja.
  - `git diff --stat origin/main -- internal/pipeline/money.go internal/pipeline/resume.go` is
    empty.
- Test: the drafter gate.

### B1.5 The first cairn blueprint (160 min, runner and live-account)

- Outcome: the pilot's first milestone, in the cairn worktree, per cairn-pass. Every drafter
  command runs as `<drafter wt>/drafter`, never the installed `drafter`, and with
  `DRAFTER_PROMPTS=<drafter wt>/claude/.claude/workflows/docs-page-chain.js`, since the installed
  binary and the linked module are drafter main's. The steps run in this order:
  1. Run `make -C <drafter worktree> build`. Copy `~/.config/drafter/cairn-cms.local.toml` to
     `<cairn wt>/drafter.local.toml` and confirm `git -C <cairn wt> check-ignore
     drafter.local.toml`. `<drafter wt>/drafter config --json` exits 0 and shows `prompts` in the
     drafter worktree. Write the clock file in the cairn worktree's git dir.
  2. In the cairn worktree, run `drafter convert outline` on `docs/internal/outlines/extend.json`
     and `claude-code.json` into `blueprints/outline.yaml`.
     - Set each type's `anatomy` to its entry in "The page anatomies" of
       `docs/internal/docs-register.md`: concept to `Concept page`, task guide to `Task guide`,
       tutorial milestone to `Tutorial milestone`, symptom row to `Symptom row`.
     - Add `docs/extend/migration-notes.md` by hand as an entry with `managed: false` (call 16).
       It's in `extend.json`'s `kept` list, not `pages`.
  3. Run `drafter convert plan` on `docs/internal/briefs/extend/rotate-the-github-app-key.plan.yaml`
     with its `.framing.md` and `--outline docs/internal/outlines/extend.json`. File the printed
     friction lines in `docs/internal/docs-friction-log.md`, and put the printed departures in the
     commit message.
  4. Add `[seat.blueprint]` to `drafter.toml`: `claude-opus-5-5`, effort `medium`, `max_tokens`
     32000. The `[facts] dir` stays `docs/internal/facts`, since cairn's move is B5.
  5. Reshape the blueprint until `drafter check` exits 0:
     - write a `why` for each section, from the old `orderReason`
     - cut the `orderReason` to the order as a whole
     - rewrite each `use` to name scope only
     - replace heading references in prose and framing with `[[id]]`
     - move narrated planning history out of durable fields
  6. Commit, then run the blueprint read live, and repeat:
     - Run `drafter read` on the blueprint in batch mode, from the cairn worktree, with the page
       cap the standing approvals set, as a `run_in_background` task. Remove the clock file while
       it's in flight, and rewrite its `start=` when it returns. Nothing in the cairn worktree is
       edited while a read is in flight.
     - On `fix`, check each blocking finding against cairn's code and facts.
     - Fix a real gap in the blueprint. Each new claim cites a fact, and a new fact is filed
       `[verified]` with its source in `docs/internal/facts/extend.md`, passing cairn's facts check.
       An existing fact found wrong isn't edited, since it reaches every page that cites it; it
       goes to the cairn PR's "Found, not done".
     - Record a finding you judge wrong in the cairn PR, with its reason and the code that shows
       it.
     - Commit, and read again.
     - A finding judged wrong in two rounds may justify one clarifying edit to the `blueprint`
       seat's prompt in the drafter worktree, if it keeps every read the prompt names and is listed
       in the drafter PR with the findings it answers. The gate runs again after it.
     - The loop ends at `accept`, or after six read runs, or when the meter leaves less than $1. If
       it hasn't reached `accept`, the milestone is missed: classify every open finding as a
       blueprint gap or a bar defect (settled ruling 1).
  7. On `accept`, commit `blueprints/drafted.lock`.
  8. Control read: on a throwaway branch in the cairn worktree, commit the final blueprint with two
     seeded gaps (one step removed whose output a later step requires in prose only, and one
     failure item removed). Each gap must leave `drafter check` passing, or the page is set aside
     before any request: remove a step that no `from` or `requires` names, and a failure whose
     step keeps another failure or has its `canFail` cleared, with no `handledBy` left dangling.
     Run `drafter check`, then `drafter read` once. It must answer `fix` with a blocking finding on
     each gap. If it accepts, discard the lock change. Return to `blueprint-pilot` and delete the
     branch. This proves the final
     prompt still bites, including after any prompt edit.
  9. Time `drafter check` on a scratch root holding the blueprint copied to the path-rule location
     of each of the 11 stage 2b pages, with the new `outline.yaml`.
- Files (cairn): `blueprints/outline.yaml`,
  `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml`, `blueprints/drafted.lock`,
  `drafter.toml`, `docs/internal/facts/extend.md` where new facts are filed,
  `docs/internal/docs-friction-log.md`. The JSON outlines and the v1 plan stay, and the PR notes
  that the outline is duplicated until B5 retires the JSON outlines. `drafter.local.toml` is
  ignored and never committed.
- Acceptance, built and measured:
  - `drafter check` exits 0 on the cairn worktree, with the managed-page warnings expected while
    `blueprints.required` is false.
  - The 11-blueprint `time drafter check` finishes under 5 seconds.
  - Every read round is recorded with its verdict, blocking findings, dispositions, and the meter.
  - The control read answered `fix` on both seeded gaps.
  - cairn's fast lane passes, and CI on the draft PR is green.
- Acceptance, milestone: accepted, or missed with every open finding classified. Accepted means
  `drafter read` exited 0 and `git -C <cairn wt> rev-parse HEAD:blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml`
  equals the lock's accepted id in the committed lock.
- Test: the live runs and cairn's fast lane.

### Close (60 min)

1. Run the drafter gate once on its close head. cairn's CI is green on its head.
2. Run two whole-branch `diff-reviewer` runs:
   - drafter's branch against `main`, under go-conventions for `*.go`, confirming that
     `money.go` and `resume.go` are untouched
   - cairn's branch against `origin/main`, with cairn-pass's checklist globs
3. Run one batched fix chain, then the gates again.
4. Run `gitleaks git` over drafter's branch history. Grep drafter's `testdata/` dirs (every
   `internal/*/testdata/`, `e2e/testdata/`), `tests/fixtures/`, and `docs/` for workstation paths
   and for anything shaped like an `sk-ant-` key; the grep must find nothing.
5. Run cairn-pass's close checklist items for the cairn branch, including the friction-log triage.
6. The executor never edits the initiatives repo. The drafter PR body carries the pipeline spec
   amendment's text: stage 1 and the stop table gain the blueprint step, the `blueprint` seat, and
   its stop row, as built. The conductor commits it to `specs/2026-10-12-drafter-pipeline-design.md`
   in its hand-over.
7. Push, and open the PRs on `glw907/drafter` and `glw907/cairn-cms`. The drafter PR opens ready,
   since drafter has no CI; the cairn PR stays a draft until its CI is green. Each PR body names
   the other and opens with `## Brief`.

   The drafter PR carries:
   - what landed and the review verdicts
   - B1.5's record: each read round's verdict, its blocking findings, and their disposition, the
     control read's result, plus the ledger total from `drafter spend --since 2026-10-17` by seat
   - any prompt edit with the findings it answers
   - the score rows, where the Work and review row puts the 780-minute path beside the actual
   - the milestone statement: "first blueprint accepted", or "missed" with the classification

   The cairn PR carries:
   - what landed, and when the milestone was missed, that the blueprint is as reached and not
     accepted
   - the findings judged wrong, with their evidence
   - the outline duplication note
   - its CI line
   - `## Before merge`: drafter's PR merges first, then `make -C ~/Projects/drafter install`, then
     `drafter config` exits 0 in cairn's main checkout, since the installed binary refuses
     `[seat.blueprint]` until then (`internal/config/check.go:96-100`)

   Its "Found, not done" carries a proposed disposition for each item.
8. Stop at PR-ready. The conductor takes both PRs to Geoff, with the merge order.

## Later

- Scoping the blueprint read to changed sections (B3/B4, from the lock's section hashes).
- A JSON Schema association for editors (`.blueprint.yaml` by glob), when the B2 skill lands.
- A multi-page lock writer inside the run, which needs `resume.go` and so belongs to B4 under
  `auth-data`.
- Whether a fact or outline-entry change re-runs the blueprint read for an accepted blueprint
  (B4's detection, call 5), and that a hand-edited accepted id is untrusted (B4 design input).
- Framing records whose headings vary from the four (several stage 2b records do); `convert`
  refuses them, and B3 maps them when it converts the remaining plans.
