# drafter pass B1 plan: the blueprint format and the blueprint read

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-17-blueprint-architecture-design.md`,
approved by Geoff on 2026-10-17 with two review fixes folded (commit `b3665ea` on branch
`docs-system-blueprint-design`). Sections this pass builds: "Blueprints" (all of it, including
"Layout", "Managed pages", "Bootstrapping" item 1, "`drafter check`", "Fitting the format to its
jobs", and "The edit catalog"), and "The pilot" first milestone. It amends
`specs/2026-10-12-drafter-pipeline-design.md`, whose stage 1 ("Plan check") and stop table this pass
extends. Planning fact sheet (paths and line numbers at drafter `d3447d9`): `research/2026-10-17-drafter-b1-factsheet.md`.

## Outcome

drafter reads, checks, and converts blueprints. `drafter check` validates every blueprint in a
project offline in seconds, `drafter refs <fact-id>` lists every placement and citation of a fact,
and `drafter convert` turns a v1 plan and its framing record into a blueprint and seeds the page's
`drafted.lock` entry. `drafter read` runs stage 1 on blueprints through the API: the local check,
the consistency read, and a new `blueprint` read seat that takes over the chain's plan read, and on
`accept` records the blueprint's hash in the lock. The pass ends live: cairn's
`rotate-the-github-app-key` plan is converted, reshaped to the format's rules, and fixed until its
blueprint passes `drafter check` and reaches `accepted` in the blueprint read, run by hand. That is
the pilot's first milestone.

## Build sequence

The design is built in five passes, in order. Only B1 is planned here; each later pass is planned
when the one before it merges, from what B1's pilot shows.

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
  (`claude/.claude/workflows/docs-page-chain.js`), a workflow. Every other task is `ordinary`.
  B1.4 adds a stage without editing `internal/pipeline/money.go` or `internal/pipeline/resume.go`;
  a change to either file stops the line, since the money path is `auth-data` by Geoff's pass 5
  ruling.
- `live-account`: yes. B1.5 spends API credit.
- Repos and branches:
  - `glw907/drafter` at `~/Projects/drafter`: the executor launches from the main checkout and works
    in the worktree `EnterWorktree` creates (name `b1-blueprint-format`).
  - `glw907/cairn-cms` at `~/Projects/cairn-cms`, through the `cairn-pass` adapter: B1.5 creates
    `git -C ~/Projects/cairn-cms worktree add .claude/worktrees/blueprint-pilot -b blueprint-pilot
    origin/main` and runs cairn-pass's setup command there. cairn's main checkout is never touched.
- Gates: drafter, from its worktree, `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` (`make
  check` under `cairn-run-gate`), re-issued on exit 75. drafter has no CI, so this gate once on the
  close head is the full-suite home. cairn: cairn-pass's fast lane, with CI on the draft PR as the
  full-suite home and `ci-green <sha> --pr <n> --wait` as a background watch.
- Baseline: before B1.1, the drafter gate runs once on the fresh worktree. A red baseline stops the
  line, since every later red would be ambiguous.
- Clock file: the drafter worktree's git dir. A wait on Geoff removes the clock file first.
- Path estimate: 600 minutes. B1.1 (150), B1.2 and B1.3 as a pair (100), B1.4 (150), B1.5 (150, not
  counting waits), Close (50). The design's estimate is 300 path minutes, set from recent actuals
  (pass 4 planned 285 and ran about 70; pass 5 was not measured). The path is 2x the estimate.
- Pair subagents run on `sonnet` at `medium` with the `description` `b1-blueprint-format task <n>`.
- Standing approvals (Geoff, 2026-10-17):
  - The plan proceeds within 3x its design estimate (900 path minutes).
  - Live spend up to $10 for this pass runs without asking. The meter is this branch's `drafter
    spend --since 2026-10-17 --json`: its `total` plus `open.worst`. Each live run carries
    `DRAFTER_PAGE_CAP` set to the smaller of 5 and 10 minus the meter. When that cap would fall
    under $1, the pass stops for Geoff.
  - A live run that exits 3 with `cycle cap` or `spend limit` runs `notify-send -u normal` and stops
    for Geoff.
  - The blueprint's content fixes in B1.5 are made by the executor from cairn's code, each new claim
    cited to a fact, and the cairn PR goes to Geoff for review.
- Depends on, checked at launch: drafter `origin/main` at or after `d3447d9` (pass 5 and the
  repo-organization pass merged); `DRAFTER_API_KEY` in `~/.local/secrets` (check by name only);
  `~/.config/drafter/config.toml` and `~/.config/drafter/cairn-cms.local.toml` present from pass 5.

## Design resolutions

The design leaves these to the builder. The plan takes them so the executor doesn't have to.

1. Job and type have one home. The design lists the job and type among the blueprint's fields and
   also has `outline.yaml` hold "the doc set's pages, order, jobs, and types". A field kept in both
   would go stale in one, so job and type live only in the page's `outline.yaml` entry, and drafter
   joins the entry to the blueprint when it builds a read or draft input. The blueprint holds the
   exemplar sources and register sections. This matches call 5, which counts an outline-entry change
   as a page change.
2. `check-plan` stays unchanged. The chain's front half still calls it for figure pages and the
   unconverted plans. `drafter check` is a new command for blueprints. `check-plan` retires with the
   chain.
3. Section references in prose fields use `[[<section-id>]]`. `drafter check` resolves each one
   against the blueprint's section ids and reports an unknown id as an error.
4. A placement's `use` starts with `Only` or `Omit` (format change 1). `drafter check` enforces the
   opening word, and the blueprint read judges whether the rest restates the fact.
5. The converter does the mechanical mapping and nothing that needs judgment. It never writes a
   section's `why`, and `drafter check` reports a missing `why` as an error. A converted blueprint
   therefore fails `check` until someone reshapes it, which keeps the judgment work visible.
6. The blueprint read is a seat named `blueprint`, rendered through the project's prompts module
   (call 23), answering in the existing read schema (`assemble.AnswerRead`: verdict, findings with
   location, finding, rewrite, and blocking, and summary). A blocking finding sets the page aside
   with rule `plan` and seat `blueprint`; drafter never edits a blueprint in B1.
7. `drafter read` stops after stage 1. The tree must be clean, as for `drafter page`, so each
   read round runs on a committed blueprint and the round history is the git log.

## Out of scope

The blueprint skill, the hook, and the format test (B2); drafting from blueprints, section
redrafts, the coherence read, and lock writes on a draft (B3); `drafter status`, `drafter nightly`,
the write-back seat, bootstrapping by the write-back seat, the pending fact tag, and the timer (B4);
cairn's directory move, its gate change, and every workstation change in the design's "Changed"
table (B5); figure pages; the stock prompts module.

## Tasks

Every drafter task starts by invoking `go-conventions`. The fixtures are synthetic: no cairn text
and no workstation path goes into drafter.

### B1.1 The blueprint format (150 min, ordinary)

- Outcome: a new package, `internal/blueprint`, decodes three files, each with `version: 1`:
  - A blueprint (`*.blueprint.yaml`). It starts from plan format v1's fields and item kinds and
    changes them as the design's "Fitting the format to its jobs" says:
    - A required `id` on every section, unique within the blueprint.
    - A required per-section `why`, and a page-level `orderReason` that explains only the order as
      a whole.
    - A `framing` block that holds what the framing record holds today. Its fields follow the
      record's sections ("Who arrives, from where, and why", "Background the page rests on", "Place
      in the doc set", "Intro plan", "Departures from the plan's introduction").
    - `exemplars` and `registerSections`.
    - An `example` item kind, for a worked example in prose.
    - `origin: human` on any item.
    - `styleNotes` on a section, each holding the old and new wording.
    - An optional `review: human`.
    - No `friction` field. `constraints` stays, for rules specific to the page.
    - No `page.type`, per resolution 1.
  - `outline.yaml`, holding:
    - `types`, each with the register `anatomy` it follows.
    - `pages`, each with `path`, `slug`, `title`, `type`, `job`, `covers`, `outOfScope`, `figure`,
      and `managed` (default true).
    - `crossLinks`.
  - `drafted.lock`, holding one entry per page, keyed on the page path:
    - the commit drafter last wrote the page in
    - the page hash and the blueprint hash at that commit
    - one hash per section id
    - the blueprint hash the blueprint read last accepted
  - A writer for `drafted.lock`, through `atomicfile.WriteFile`, with entries sorted by path so its
    diffs are stable.

  The decoder follows `internal/plan/decode.go`'s approach: it walks the `yaml.Node` to catch
  duplicate keys, refuses fields outside a kind's set, and keeps line numbers for findings.
  `schema/blueprint.schema.json` and `schema/outline.schema.json` match the Go struct tags, and a
  test enforces it, as `internal/plan/schema_test.go` does for plans. The path rule maps a page
  path to its blueprint path and back: `<root>/<page path without .md>.blueprint.yaml`, with root
  `blueprints` by default.
- `docs/blueprint-format.md` is the format's one home. It covers:
  - every field and item kind
  - the layout and the path rule
  - `outline.yaml`
  - `drafted.lock`
  - the section-reference syntax
  - the `use` rule
  - the edit catalog, copied from the design's table and mapped to the kinds

  It's written in the Google developer documentation style. `README.md` links it.
- Files: `internal/blueprint/` and its tests and `testdata/`, `schema/blueprint.schema.json`,
  `schema/outline.schema.json`, `docs/blueprint-format.md`, `README.md`.
- Acceptance:
  - A table-driven decode test covers each item kind including `example`, and each new field.
  - Each refusal has its own test: a missing section `id`, a duplicate section `id`, a field outside
    a kind's set, a duplicate key, `friction` present, and an unknown kind.
  - The schema tests fail when a struct field is added without its schema entry.
  - A round-trip test writes a lock and reads it back equal, with entries in path order.
  - A path-rule table covers `docs/extend/x.md`, the root `README.md`, and a nested path, both ways.
  - A docs test fails when a blueprint field the decoder knows is missing from
    `docs/blueprint-format.md`, as `internal/plan/docs_test.go` does for plans.
  - An edit-catalog test takes one synthetic fixture blueprint and, for each catalog row except
    "Start a new page" and "Follow a rename the gate demands", holds a fixture after the edit. It
    asserts that each one decodes. B1.2 extends it to assert `check` passes.
- Test: the drafter gate.

### B1.2 `drafter check` and `drafter refs` (100 min, ordinary)

- Outcome: `drafter check [--root dir] [--json] [<blueprint>...]` validates every blueprint under
  the project's blueprint root, or the ones named, offline.
  - It runs the v1 checks, adapted to the blueprint types: decode, ids, reader-state, recovery,
    links, crossLinks, and facts. Reuse `internal/plan`'s logic where the types allow it, rather
    than copying it.
  - It adds these checks:
    - Every managed page in `outline.yaml` has exactly one blueprint, and every blueprint names a
      page in the outline. The first part is a warning until `blueprints.required = true`, and an
      error after.
    - Section ids are unique.
    - Every `[[id]]` resolves.
    - Every section has a non-empty `why`.
    - Every `use` starts with `Only` or `Omit`.
    - The page's outline `type` is one that `types` declares, and that type's `anatomy` is non-empty.
    - `drafted.lock` parses, and every page it names exists.
  - The output and exit codes match `check-plan`'s: `file:line: severity: check: message (fix)`, 1 on
    any error, and 2 when it can't run.
  - `drafter refs <fact-id> [--root dir] [--json]` lists every blueprint item, on every page, that
    places or cites the fact (`fact` items, every `facts` list, the introduction's facts, and
    dispositions), one `file:line: item-id (kind)` per line. It exits 1 when there are none.
  - New settings, each in `docs/configuration.md`, which `internal/config/docs_test.go` enforces:
    - `blueprints.root` (default `blueprints`)
    - `blueprints.required` (default false)
    - `blueprints.outline` (default `<root>/outline.yaml`)
    - `facts.dir` (unchanged). When it's unset and `<root>/facts` exists, it defaults there.
- Files: `internal/blueprint/` (the check and refs), `cmd/drafter/check.go`, `cmd/drafter/refs.go`
  and their tests, `internal/config/` and its docs test, `docs/configuration.md`,
  `docs/blueprint-format.md` (the checks section), `e2e/` rows.
- Acceptance:
  - Each new check has a failing fixture and a passing twin.
  - The B1.1 edit-catalog fixtures all pass `check`.
  - A synthetic project with a managed page and no blueprint warns with `blueprints.required` false
    and errors with it true.
  - `refs` on a fixture fact placed twice and cited once prints three lines.
  - An e2e row builds the binary and runs `check` and `refs` on `e2e/testdata`, asserting the exit
    codes.
  - `check-plan`'s tests are unchanged and pass.
- Test: the drafter gate.
- Pair: with B1.3. Neither task touches `cmd/drafter/root.go`. The session registers both commands
  there after it merges the pair.

### B1.3 `drafter convert` (90 min, ordinary)

- Outcome: `drafter convert` has two subcommands.
  - `drafter convert outline [--out file] <outline.json>...` writes `outline.yaml` from the chain's
    JSON outlines. It takes each page's `path`, `slug`, `title`, `pageType` as `type`, `job`,
    `covers`, `outOfScope`, and `figure`, plus the top-level `crossLinks`. It declares every
    distinct type with an empty `anatomy`, which `check` then reports.
  - `drafter convert plan [--framing file] [--outline file] [--root dir] <plan.yaml>` writes the
    page's blueprint at its path-rule location. It never overwrites an existing file.
    - It maps every v1 field and item.
    - It derives each section `id` from its anchor or heading slug.
    - It copies the framing record's sections into `framing` by heading, and refuses a record
      heading it doesn't know, naming it.
    - It takes `exemplars` from the outline entry.
    - It drops `friction` and `page.type`, printing the friction lines to stderr so they can go to
      a friction log.
    - It leaves every `why` unwritten.
    - When the page exists, it seeds the page's `drafted.lock` entry with the page as it stands:
      the current HEAD commit, the page and blueprint hashes, and one hash per section matched by
      heading. The accepted blueprint hash stays empty (call 15).
    - It prints the blueprint path and the list of what needs judgment: each section with no
      `why`, and each `use` that doesn't start with `Only` or `Omit`.
- Files: `internal/blueprint/convert.go` and its tests, `cmd/drafter/convert.go` and its test,
  synthetic fixtures (a v1 plan, a framing record, an outline JSON).
- Acceptance:
  - Converting the synthetic v1 plan keeps every item's id, kind, and fields, and the framing
    record's sections, which a test checks field by field.
  - The converted file decodes. `check` on it reports exactly the expected missing-`why` and `use`
    findings, and nothing else.
  - A record with an unknown heading is refused.
  - An existing blueprint is never overwritten.
  - The lock seed's section hashes match a hand-computed fixture.
  - `convert outline` on a two-page fixture writes both pages and declares both types.
- Test: the drafter gate.
- Pair: with B1.2.

### B1.4 The blueprint read and `drafter read` (150 min, runner)

- Outcome: stage 1 runs on blueprints.
  - A new step runs `drafter check`'s logic locally, then the consistency read when the project has
    a facts store, unchanged, then the new `blueprint` read.
  - The seat is added where the fact sheet's section 3 names:
    - `config/check.go`'s `seatNames`
    - a step constant in `work.go`
    - `advance` in `steps.go`
    - `stepSeats`, `validate`, and `complete` in `handle.go`
    - the smoke shape table in `internal/smoke`

    Its answer is `assemble.AnswerRead`. Its request inlines the blueprint, the page's outline
    entry, and the bullets of every fact the blueprint places or cites.
  - The prompt is a `blueprint` export in the chain's prompts module, `claude/.claude/workflows/
    docs-page-chain.js`, added to `DRAFTER_SEATS`. It's adapted from `structurePrompt(p, "plan")`:
    - order, pace, and user goal
    - the introduction's three parts
    - completeness of steps and failures

    It adds these:
    - a reader-state read (a step whose prerequisite a reader can't hold at that point)
    - a recovery read (a failure with no step where it occurs, and recovery named before diagnosis)
    - a report of each `use` that restates its fact's content
    - a report of each human-origin item the blueprint would bury

    Its bar is the chain's: any blocking finding means `fix`.
  - `drafter read [--dry-run] [--sync] [--json] [--resume <run-id>] <blueprint>...` runs the
    pipeline through stage 1 only, on the same run directory, locks, clean-tree refusal, ledger,
    and records as `drafter page`.
    - On `accept`, it writes the blueprint's hash into the page's `drafted.lock` entry as the
      accepted hash, through the B1.1 writer, and records the write in state as a drafter write.
      The page entry is created if missing.
    - On `fix`, it sets the page aside with the findings printed.
    - Exit codes match `drafter page`'s: 0 when all are accepted, 1 when any is set aside, 2 when
      it can't start, and 3 when it stopped resumable.
  - `money.go` and `resume.go` are not edited.
- Files: `internal/pipeline/` (`work.go`, `steps.go`, `handle.go`, `check.go`, a new input builder
  from a blueprint and its outline entry) and tests, `internal/config/check.go`, `internal/smoke/`,
  `internal/prompts/` if the context needs a field, `cmd/drafter/read.go` and its test,
  `claude/.claude/workflows/docs-page-chain.js`, the prompts-parity matrix and fixtures under
  `tests/`, `e2e/`, `docs/prompts-module.md` (the seat), `README.md` (the commands).
- Acceptance:
  - Against the fake `pipeline.API`, three runs end as expected:
    - A blueprint whose read answers `accept` ends accepted, and its lock entry holds the
      blueprint's hash.
    - A `fix` answer sets the page aside with rule `plan`, seat `blueprint`, and the findings in
      the record, and the lock is unchanged.
    - A `check` error sets the page aside before any request, and the fake records zero
      `CountTokens` calls.
  - Every `Create` the fake records follows a reserve line, as in pass 5's money rows, which run
    unchanged and pass.
  - A stop and `--resume` mid-read ends accepted with one settle line per `custom_id`.
  - `--dry-run` prints the first stage's estimate and submits nothing.
  - The prompts-parity test renders the `blueprint` seat byte-identically in Node and goja.
  - The smoke's shape table holds the eight seats.
  - `git diff --stat origin/main -- internal/pipeline/money.go internal/pipeline/resume.go` is
    empty.
- Test: the drafter gate.

### B1.5 The first cairn blueprint (150 min, live)

- Outcome: the pilot's first milestone, in the cairn worktree, per cairn-pass. The steps run in
  this order:
  1. Run `make -C <drafter worktree> build`, then the live smoke:
     `bash -c '. ~/.local/secrets && make smoke'` from the drafter worktree, as a
     `run_in_background` task. The smoke must cover the `blueprint` seat's production shape.
  2. In the cairn worktree, run `drafter convert outline` on `docs/internal/outlines/extend.json`
     and `claude-code.json` into `blueprints/outline.yaml`.
     - Fill each type's `anatomy` from the headings under "The page anatomies" in
       `docs/internal/docs-register.md`.
     - Mark `docs/extend/migration-notes.md` `managed: false` (call 16).
  3. Run `drafter convert plan` on `docs/internal/briefs/extend/rotate-the-github-app-key.plan.yaml`
     with its `.framing.md` and the new outline.
  4. Add `[seat.blueprint]` to `drafter.toml`: `claude-opus-5-5`, effort `medium`, `max_tokens`
     32000. The `[facts] dir` stays `docs/internal/facts`, since cairn's move is B5.
  5. Reshape the blueprint until `drafter check` exits 0:
     - write a `why` for each section, from the old `orderReason`
     - cut the `orderReason` to the order as a whole
     - rewrite each `use` to name scope only
     - replace heading references in prose with `[[id]]`
     - move narrated planning history out of durable fields
  6. Commit, then run the blueprint read live, and repeat:
     - Run `drafter read` on the blueprint in batch mode, from the cairn worktree, with the page
       cap the standing approvals set, as a `run_in_background` task.
     - On `fix`, check each blocking finding against cairn's code and facts.
     - Fix a real gap in the blueprint. Each new claim cites a fact, and a new fact is filed
       `[verified]` with its source in `docs/internal/facts/extend.md`, passing cairn's facts check.
     - Record a finding you judge wrong in the cairn PR, with its reason and the code that shows
       it.
     - Commit, and read again.
     - A finding judged wrong in two rounds may justify one clarifying edit to the `blueprint`
       seat's prompt in the drafter worktree, if it keeps every read the prompt names and is listed
       in the drafter PR with the findings it answers. The gate runs again after it.
     - The loop ends at `accept`, or after six read runs, or when the meter leaves less than $1. If
       it hasn't reached `accept`, the pass reports the milestone missed and classifies every
       open finding as a blueprint gap or a bar defect.
  7. Check `drafter check` timing on the cairn worktree: `time drafter check` finishes under 5
     seconds.
- Files (cairn): `blueprints/outline.yaml`,
  `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml`, `blueprints/drafted.lock`,
  `drafter.toml`, `docs/internal/facts/extend.md` where new facts are filed. The JSON outlines and
  the v1 plan stay, and the PR notes that the outline is duplicated until B5 retires the JSON
  outlines.
- Acceptance:
  - the live smoke passed, and the meter after it is recorded
  - `drafter check` exits 0 on the cairn worktree, with the managed-page warnings expected while
    `blueprints.required` is false
  - `drafter read` exits 0, and the lock's accepted hash equals the committed blueprint's hash
  - cairn's fast lane passes, and CI on the draft PR is green
- Test: the live runs and cairn's fast lane.

### Close (50 min)

1. Run the drafter gate once on its close head. cairn's CI is green on its head.
2. Run two whole-branch `diff-reviewer` runs:
   - drafter's branch against `main`, under go-conventions for `*.go`, confirming that
     `money.go` and `resume.go` are untouched
   - cairn's branch against `origin/main`, with cairn-pass's checklist globs
3. Run one batched fix chain, then the gates again.
4. Run `gitleaks git` over drafter's branch history. Grep drafter's `testdata/` and `docs/` for
   workstation paths and for anything shaped like an `sk-ant-` key; the grep must find nothing.
5. Push, and open the PRs on `glw907/drafter` and `glw907/cairn-cms`, each as a draft until CI is
   green and then ready. Each PR body names the other and opens with `## Brief`.

   The drafter PR carries:
   - what landed and the review verdicts
   - B1.5's record: each read round's verdict, its blocking findings, and their disposition, plus
     the ledger total from `drafter spend --since 2026-10-17` by seat
   - any prompt edit with the findings it answers
   - the score rows, where the Work and review row puts the 600-minute path beside the actual
   - the milestone statement: "first blueprint accepted", or "missed" with the classification

   The cairn PR carries:
   - what landed
   - the findings judged wrong, with their evidence
   - the outline duplication note
   - its CI line

   Its "Found, not done" carries a proposed disposition for each item.
6. Stop at PR-ready. The conductor takes both PRs to Geoff.

## Later

- Scoping the blueprint read to changed sections (B3/B4, from the lock's section hashes).
- A JSON Schema association for editors (`.blueprint.yaml` by glob), when the B2 skill lands.
