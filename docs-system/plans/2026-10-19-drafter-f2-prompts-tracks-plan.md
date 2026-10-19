# drafter pass F2 plan: prompts and tracks

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-f-foundations-design.md`, its
"F2, prompts and tracks", "Shared", and "Standing answers" sections, approved by Geoff on 2026-10-18
(glw907/initiatives#20). Its scope comes from `specs/2026-10-18-drafter-onboarding-design.md` ("F,
foundations", its acceptance table, "What a new project builds" item 2, "The house register,
optional", "Introductions and background"). Two later rulings add to it:

- The edit-quality design (`specs/2026-10-19-drafter-edit-quality-design.md`, "Out of scope") sends
  its reviewer-grade change-read rule and the "no register rules in blueprint reads" ruling into the
  stock read prompt F2 builds.
- Geoff's packet ruling on glw907/drafter#51 (2026-10-19) puts drafter backlog #12 into F2's plan.

Code: facts are quoted at drafter `main` `6583012` (edit-quality merged) and cairn-cms `main`. Lines
move; the executor finds each quoted symbol by name. Planning probes ran in this session's
scratchpad on 2026-10-18; #12's evidence came from the saved run directories under
`~/.local/state/drafter/runs/cairn-cms/` (below, "#12").

## Outcome

drafter runs on a stock prompts module when a project names none, and a project can refuse that
fallback with one committed setting. `drafter config` and every run report name the module's source
and hash, and the run directory keeps the module's bytes. The stock module carries a real blueprint
read, the reviewer-grade change read included, and no register. Its other seats wait for B3, and a
run that needs one refuses before any spend. A prompt can name an embedded drafter file
(`drafter:<name>`) and a section of a file (`<path>#<heading-slug>`). The outline declares reader
tracks, every type names a known anatomy, and every blueprint plans its introduction. A change read
no longer escalates on a fact conflict the base already carried (#12).

- Risk class `runner` (the gate tools, the prompt contract, and the skill). Not `live-account`: no
  acceptance check calls the API. `internal/pipeline/money.go` and `internal/pipeline/resume.go` are
  never edited; a need to edit either stops the line.
- Path estimate: 310 minutes, against the design's 200 (1.55x), inside standing answer 2's 400.
  F2.0 (25), then pair A: F2.1 (90) beside F2.4 (100), with the session running F2.2 (50) in the
  pair's shadow: 100. Then pair B: F2.3 (75) beside F2.5 (50), with the session running F2.6 (40) in
  its shadow: 75. Then F2.7 (70) and Close (30), plus 10 for the two inter-pair merges. Recent
  scores ran well under plan (F1 planned 300; edit-quality planned 355 and closed early), so this
  path carries no padding beyond the merges.
- Clock file: `pass-task-clock` in the session worktree's git dir (`git rev-parse
  --absolute-git-dir` run in `.claude/worktrees/f2-prompts-tracks`). During a pair it holds the task
  the session runs in the shadow. When a pair returns, the session checks each pair task against
  twice its estimate.
- Pair subagents run on `sonnet` at `medium` with the `description` `f2-prompts-tracks task <n>`,
  with two exceptions. F2.3 runs on `opus` at `medium`: it writes the reference pages and the stock
  read prompt, which a seat reads as rules. F2.5 runs on `sonnet` at `high`: it changes when a
  change read blocks, and its fail-closed cases decide correctness. A new test helper in package
  `main` or `e2e` carries its task's subject in its name (`tracksOutline`, not `outline`), since a
  pair's two tasks add tests to those packages in parallel.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-18):
  1. A plan whose path stays within 400 minutes launches unattended.
  2. A plan over that line, or a finding that changes the design, stops and asks Geoff.
- Depends on, checked at launch:
  - edit-quality is merged to drafter `main` (done: `6583012`, PR #51) and its worktree is gone.
  - One executor per worktree: `pgrep -f .claude/worktrees/f2-prompts-tracks` finds nothing, and
    `claude agents --json` shows no session working in drafter or cairn-cms other than the
    launching conductor's own.
  - Clean main checkouts: `~/Projects/drafter` and `~/Projects/cairn-cms` each print nothing for
    `git status --porcelain`, are on `main`, and `git rev-list --count HEAD..origin/main` prints 0.
  - Tools: `vale --version` prints 3.x, and `claude --version` runs (F2.7's headless check).

## Design resolutions

These are the method calls the design leaves to the planner. Each is decided here; the executor
doesn't reopen one without stopping the line.

1. **Where the stock module and reference pages live.** A new top-level Go package `stock/` holds
   `prompts.js`, `anatomies.md`, and `introductions.md`, embedded by `stock/stock.go` with
   `//go:embed`. One file is both the reference page a person reads on GitHub and the bytes a seat
   receives, so the two never drift. `stock.go` exports the bytes and a `Files` lookup by name for
   the `drafter:` token (resolution 5). It holds no logic beyond the embed and the lookup. The
   design's "reference pages" are these two Markdown files; `docs/` links to them.

2. **How a run picks its module.** `prompts` stops being required. `Validate(ScopeRun)`
   (`internal/config/validate.go`, the `c.Prompts == ""` branch) no longer reports it missing. A new
   method on `*config.Config`, `Module() (name string, src []byte, err error)`, returns the file
   `prompts` names, or `"drafter:prompts.js"` and `stock.Prompts` when it is unset. Three callers
   use it in place of reading `c.Prompts` themselves: `copyInputs` and `loadModules`
   (`internal/pipeline/start.go`) and `runCheckPrompts` (`cmd/drafter/checkprompts.go`, the branch
   that errors when `c.Prompts == ""`). `copyInputs` already writes the module to the run directory
   as `prompts.js` and records its hash in `state.Inputs["prompts"]`, and `useCopies` in `resume.go`
   already reads that copy back on a resume. So "a resume after an upgrade uses the same prompts"
   holds with no edit to `resume.go`; F2.1 adds the test that proves it for the stock module.

3. **The refusal setting.** A new top-level boolean, `require_prompts`, allowed only in the project
   layer (`allowedIn` in `internal/config/layer.go` gets `inProject`), so only a committed
   `drafter.toml` can set it. When it is true and `prompts` is unset, `Validate(ScopeRun)` reports
   `prompts is not set, and require_prompts in drafter.toml refuses the stock module`, and
   `drafter check-prompts` with no `--module` refuses with the same sentence. It joins the
   `drafter config` rows. cairn's `drafter.toml` sets it (F2.7).

   Every channel, named: the project file sets it. The user and local files can't (`checkAllowed`
   refuses the key). It has no environment variable: `allowedIn` restricts file layers only ("The
   environment and the flags are not file layers and are never restricted", `layer.go`, the
   `allowedIn` comment), so `fromEnv`'s explicit key list in `env.go` doesn't gain it, and
   `DRAFTER_REQUIRE_PROMPTS=false` changes nothing. It has no flag, and `stock.toml` leaves it unset.
   `configuration.md`'s row reads "Environment variable: none".

   It stays out of the fingerprint: it changes no request and no cost, which is the fingerprint's
   scope (`fingerprint.go`, the `fingerprint` doc comment). Adding it would break the resume of every
   run saved before F2, since `changedSettings` reports a key of `now` that `was` lacks. A resume
   already re-runs `Validate(ScopeRun)` on the current config (`newRunner`, `start.go`), so the guard
   still holds there: a run started on the stock module refuses to resume once the guard is set and
   `prompts` is unset. That is the guard's meaning (a resume is a run), and no such cairn run exists,
   since cairn's reads fail on `prompts` today.

4. **What `drafter config` and the run report show.** The `prompts` row in `Sources()` shows the
   module's source and a short hash: the path and `sha256:<first 12 hex>` from its layer, or
   `drafter:prompts.js sha256:<12 hex>` from `default`; a `prompts` path that can't be read shows
   `<path> (missing)`, and the run itself fails as it does today. The run report is the summary `drafter page`
   and `drafter read` print, as F1 resolution 2 defined it. Text gains a line under `prices:`,
   `prompts: <name> sha256:<12 hex>`, and JSON gains `prompts` and `prompts_hash`. For a run that
   copied its inputs, the hash is the run copy's, taken from `state.Inputs["prompts"]`, so a resumed
   run reports what it used and never the binary's current module. `run.Input`
   (`internal/run/state.go`) gains a `Source` field that `copyInputs` fills with the module's name;
   a state written before F2 has none and reports `prompts.js (run copy)`. A dry run copies nothing
   and reports the config's module. `pipeline.Summary` gains the two fields, filled in `summary()`
   (`internal/pipeline/pipeline.go`), so `writeSummaryText` and `writeSummaryJSON`
   (`cmd/drafter/page.go`) and `writeReadSummary` print them. `runRead`'s early return, when every
   page is unchanged (the `len(handoffs) == 0` branch), builds its `Summary` without a runner, so
   it fills the two fields from `c.Module()`.

5. **Embedded blocks and the excerpt form.** `fileBlocks` (`internal/assemble/files.go`) scans the
   rendered prompt for path tokens. It learns two forms:
   - `drafter:<name>` names a file in `stock.Files`. It inlines as a `file` block labeled with the
     token, and an unknown name inlines as `not inlined: no drafter file <name>`.
   - `<path>#<slug>`, where `<path>` resolves as a token does today (tracked, or allowed by
     `inline_files`), or is a `drafter:` name. It inlines one section as an `excerpt` block labeled
     with the token: from the heading whose GitHub-style slug is `<slug>` to the next heading of the
     same or a higher level. A slug no heading has inlines as `no excerpt: no heading <slug>`. A
     heading's slug follows the rule `drafter check` already uses for `#anchor` links: the
     github-slugger port, `slugger` and `slugOf` in `internal/plan/slug.go`. No exported function
     gives what the excerpt needs (`Anchors` returns deduplicated anchors with no level or line;
     `HeadingSlugs` takes a title first, which shifts the `-1` numbering), so F2.2 adds one exported
     function in `slug.go` that returns each heading's level, line, and slug from one slugger, and
     refactors `Anchors` onto it. There is no second copy of the rule.

   The slug form is the excerpt's because `tokens` splits on spaces, so a heading's own text can't
   be a token. A file token and an excerpt token of the same file both inline. The size limit
   applies to the excerpt's text, not the file's, so a section of cairn's 90,601-byte register fits.

6. **What the stock module holds.** Only a `blueprint` builder. Its text ports `blueprintPrompt` from
   `claude/.claude/workflows/docs-page-chain.js` whole, the change-read paragraph and the "Nit:" rule
   included, with one paragraph replaced. The chain's "Read the section "## The page anatomies" of
   ${REGISTER}" paragraph becomes: read the anatomy this page's type names, by its token, only for
   the introduction and closing section it requires; no other rule in it is graded here. The
   builder finds the token from `DRAFTER_HOST.resolved.pages`, the entry whose `path` is
   `c.page.path`:
   - with a `register`, `<register>#the-page-anatomies`;
   - with an `anatomy` and no `register`, `drafter:anatomies.md#<slug of the anatomy>`;
   - with neither, as for a planner's handoff, `drafter:anatomies.md` whole.

   `entryJSON` in `cmd/drafter/read.go` gains `anatomy` (the type's, from the outline) and
   `register` (the matching track's, when it names one). The other seats are absent until B3 writes
   them. That is the design's "placeholder": a missing builder is an error that names the seat
   (`Render`, `internal/prompts/prompts.go`), and resolution 7 moves that error before any spend.

7. **A module that lacks a seat the run renders.** `loadModules` (`internal/pipeline/start.go`)
   checks, after loading, that the module defines every seat this run renders through it, per page.
   A blueprint page (`page.blueprint`) renders only `blueprint`, since stage 1 reads it and stops.
   Any other page needs `draft`, plus each of `structure`, `editor`, `fact`, and `reader` that
   `p.runs` reports. The consistency and coverage prompts are built in Go
   (`assemble.ConsistencyPrompt`, `coverage.Prompt`), never by the module, so they need no seat.
   `loadModules` passes `Module()`'s name to `moduleFor`, since `filepath.Base` of an unset
   `prompts` is `"."`. It names the missing seats and, for the stock module, adds `the stock prompts module
   carries only the blueprint read until drafter's stock seat prompts land; set prompts`. Before
   coding, F2.1 confirms that `loadModules` runs before the first stage's spend and records the
   call order in the commit message. If it doesn't, that's a stop: moving it would touch the run's
   start order.

8. **Tracks.** `outline.yaml` gains an optional top-level `tracks` list, so outline v1 stays v1.
   Each entry has `name` (required, unique), `reader` (required, prose: the reader profile),
   `standard` (required; `google` is the only value drafter ships), `paths` (required, at least one
   glob), and `register` (optional, a tracked repo-relative path). A glob matches a page path with
   `path.Match`, except that a `**` segment matches any number of segments; the helper lives in
   `internal/blueprint`. An outline with no `tracks`, or `tracks: []`, checks as before. The struct
   tags stay the schema's source of truth, and `schema/outline.schema.json` gains the same fields
   (the existing test enforces the match).

   Where each state is reported:
   - Decode, so the outline is malformed and the command stops, as for a type declared twice today
     (`validateOutline` in `decode.go`, and the decoder's own rules in `internal/plan/decode.go`): a
     missing required field, an empty string (the decoder's "is empty"), `paths: []` (a required
     list with no entry), and a duplicate track `name`.
   - `drafter check` errors, at the track's line: an unknown standard; a register path that doesn't
     exist; a malformed glob, found by calling `path.Match(segment, "")` on each non-`**` segment,
     which returns `ErrBadPattern` even on an empty name (probed: `path.Match("docs/[a", "")`
     returns "syntax error in pattern"); a managed page that matches no track or two.
   - `drafter check` warns: a track whose globs match no managed page.

   These checks, and the anatomy check of resolution 9, run once per `Project.Check`, named files
   included, in a new outline phase beside `pairing`. `CheckSource` doesn't run them: it checks one
   blueprint for the pipeline, and its doc comment already leaves the outline-wide checks to the
   project walk. So a read's blueprint check changes only by resolution 10.

   The config's existing `register.<track>` map (`config.Register`, "Facts and registers" in
   `configuration.md`) stays as it is, for cairn's module until B5, and is not matched to the
   outline's track names.

9. **Anatomies.** The stock anatomies are five Good Docs templates (templates v1.6.0, the version
   cairn's register cites): `Concept page`, `Task guide`, `Tutorial`, `Reference entry`, and
   `Troubleshooting page`. The names match cairn's register entries where the two overlap, so
   cairn's types need no rename. Each is an `##` heading in `stock/anatomies.md`, paraphrased with
   its template's URL, never copied.

   The known-anatomy check runs on the outline, once per declared type, in resolution 8's outline
   phase. It can't stay in `pageType`: that runs only from `blueprintData`, so only for a page with a
   blueprint (`check.go`), and cairn's one blueprint has the stock type `task guide`. A type
   declaration is an outline fact. `pageType` keeps its declared-type and empty-anatomy checks.

   An anatomy is known when it's a stock name. Otherwise it's known by register, decided by each
   page's own track, since that is the register the stock read inlines (resolution 6): every managed
   page of the type must match a track whose register holds the entry, and a type with no managed
   page passes when any track's register holds it. An entry is a heading, or a bullet whose bold
   lead is the name, under that register's `## The page anatomies`, which is how cairn's register
   writes its entries (`**Tutorial milestone**:`, `**Symptom row**`). A register with no such
   section holds no entries, and the message says the section is missing. Severity:
   - With tracks declared, an unknown anatomy is an error, naming the first page whose track lacks
     the entry.
   - With no tracks, an unknown anatomy is a warning. A v1 outline has no way to name a register,
     so cairn's `Tutorial milestone` and `Symptom row` would otherwise fail a check that passes
     today.

   The fix text names the stock anatomies and says a register entry needs a track that names the
   register. This replaces `check.go`'s "set anatomy to the name of a register anatomy entry, such
   as Task guide". `drafter init`'s outline template (`internal/scaffold/templates/outline.yaml`)
   names `Reference page`, which no list holds; F2.4 changes it to `Reference entry`, so a new
   project's types are all stock.

10. **`framing.introPlan`.** The struct tags don't change, so the schemas don't. A `plan:"required"`
    tag is the decoder's rule (`internal/plan/decode.go`, "missing required field", an error), and
    convert, install, seed, and `Compare` each treat a decode finding as fatal, so a tag would stop
    every one of them on a blueprint with no framing (the review's probe: 30 tests in 3 packages
    failed). The rule goes where `Section.Why`'s does, for the reason its doc comment gives ("A
    check requires a Why; the decoder does not, so a converted blueprint decodes"): a check in
    `blueprintData`, beside `sections`, reports no `framing` or no `framing.introPlan` as an error
    with check `framing`. An empty `introPlan` is already a decode error ("is empty"). `drafter
    convert` still writes a blueprint whose source plan had no framing record, and `judgment` in
    `convert.go` gains a `framing.introPlan: write it` line for the report: what the conversion left
    for a person. That is the design's "a warning, not an error, on a converted blueprint"; the
    check then holds the line. Decode, convert, seed, install, and `Compare` are unchanged. The rule
    runs in `CheckSource` too, so a read's blueprint check refuses a blueprint with no `introPlan`.
    cairn's one blueprint carries `introPlan` (checked at planning), and F2.0 adds one to every
    drafter fixture first.

11. **#12, a base-only fact conflict.** The evidence, from the saved runs of the edit-quality
    rerun's prompt 5:
    - t5a's reads 1 to 3 (`20261019T011248Z-60cf77b3`, `…T011338Z-41982899`, `…T011423Z-923a9e20`)
      returned conflicts `[f:sszb7b] with f:vg42j3` and `[f:86h9o6] with f:vg42j3`.
    - t5b's read 2 (`20261019T012604Z-a7182704`) returned `[f:3jpoi3] with f:zoekqt`.
    - In each, the `with` fact is in `Scope.Facts` because the new section cites it, and no bullet
      changed. `untouched` (`internal/pipeline/blueprint.go`) returned false at its
      `p.r.facts.Count(with) > 0` branch, and the page escalated with no blocking finding.

    `Scope.Facts` counts every fact a changed item cites. A re-citation is a touch, so a conflict
    the store already carried blocks the change that cites one side. The fix narrows the
    consistency rule only. `blueprint.Scope` (`internal/blueprint/since.go`) gains `Bullets` (the
    facts whose bullet changed between the revisions) and `Joined` (the facts the current
    blueprint places or cites that the earlier one didn't), both never nil on a scoped page. Their
    tags are `json:"bullets"` and `json:"joined"`, with no `omitempty`: the scope persists in
    `state.json`, and `omitempty` drops an empty slice, which then unmarshals as nil and would read
    as a pre-F2 state on resume (encoding/json: omitempty omits "any array, slice, map, or string of
    length zero"). `Facts` already avoids this with `json:"facts"`.
    `untouched` then treats a conflict as present at the base when every fact on both sides is a
    store fact, none is in `Bullets`, and none is in `Joined`. Such a conflict comes back as
    "Already present:" and never blocks. A conflict with a changed bullet, or with a fact the change
    brought onto the page, still blocks, since the change made the page carry it. The page-link
    `with` branch and the "Unplaced:" rule stay as they are. A scoped state saved before F2 has nil
    `Bullets` and `Joined` and keeps today's rule. `Scope.Facts` is unchanged, so the change block
    and the scoped sections are byte-identical to today's.

## Tasks

### F2.0: the `stock` package skeleton and the `introPlan` fixture sweep (25 min), by the session

Outcome: two things pair A needs before it splits.

1. `stock/stock.go` embeds `prompts.js`, `anatomies.md`, and `introductions.md` and exports
   `Prompts` and `Files`. The three files exist as stubs, so pair A's tasks import a package whose
   API doesn't move. `prompts.js` returns `{ blueprint: (c) => "stock blueprint read placeholder" }`,
   so F2.1's `drafter read` on the stock module passes the preflight before F2.3 replaces it.
2. Every drafter blueprint fixture gains a `framing.introPlan`, which is valid today since the
   field is optional. Without this, F2.4's check rule breaks fixtures F2.1 and F2.7 own. The set,
   from `git ls-files '*.blueprint.yaml' | xargs grep -L introPlan` and a grep for inline
   `orderReason:` in tests: the nine files under `internal/blueprint/testdata/catalog/`, the two
   under `internal/pipeline/testdata/project/blueprints/` (`revoke-a-key` has no `framing` and
   gains one), and the inline blueprints in `cmd/drafter/read_test.go`, `e2e/blueprint_test.go`,
   and `e2e/setup_test.go`. The catalog's `after/` files carry the base's text unchanged, so no
   `Compare` row moves. Probed at planning: with the sweep and a draft of the rule, `go test
   -count=1 ./...` is green; with the rule and no sweep, `cmd/drafter` and `e2e` fail.

- Files: `stock/stock.go`, `stock/prompts.js`, `stock/anatomies.md`, `stock/introductions.md`, and
  the fixtures above.
- Acceptance: `make check` green; the session commits before pair A starts.

### F2.1: stock module selection, `require_prompts`, and the run report (90 min), paired with F2.4

Outcome: resolutions 2, 3, 4, and 7.

- Files: `internal/config/{validate.go,layer.go,file.go,config.go,apply.go,sources.go}` as
  needed (never `env.go`: the setting has no variable), a new `internal/config/module.go` for
  `Module`, `internal/pipeline/{start.go,pipeline.go}` and the `Summary` type's file,
  `internal/run/state.go`, `cmd/drafter/{page.go,read.go,checkprompts.go,config.go}`,
  `docs/configuration.md`, `docs/prompts-module.md`, and tests beside each. Never `money.go`,
  `resume.go`, or `fingerprint.go`.
- Tests, table-driven:
  - `Validate` passes with `prompts` unset and fails with `require_prompts = true` and `prompts`
    unset.
  - `require_prompts` in the user or local layer is refused as a misplaced key, as `checkAllowed`
    refuses one today. With it true in the project layer, `DRAFTER_REQUIRE_PROMPTS=false` in the
    environment changes nothing.
  - `Module` returns the stock bytes and `drafter:prompts.js` when unset, and the file when set.
  - The `drafter config` row shows `drafter:prompts.js sha256:` and its 12 hex from `default`, and
    `<path> (missing)` for a `prompts` path that doesn't exist.
  - `fingerprint` has no `require_prompts` key, and a `fingerprint.json` saved without it passes
    `checkConfig`, so a run started before F2 still resumes.
  - The non-dry and resume rows use `internal/pipeline`'s scripted `fakeAPI`
    (`internal/pipeline/fake_test.go`) and the blueprint harness (`newBlueprintHarness` in
    `blueprint_test.go`) with `Prompts` unset, as `resume_test.go` drives resumes. The e2e
    `apiStub` answers only `GET /v1/models` and `POST /v1/messages/count_tokens` and returns 404
    for anything else (`e2e/page_test.go`), so it serves the dry-run rows only.
    - A non-dry blueprint read writes `prompts.js` equal to `stock.Prompts` into the run directory,
      with the matching hash and `Source` in `state.Inputs`.
    - The fixture state for the resume row: a run that stopped after stage 1 was submitted, with
      `state.Inputs["prompts"]` holding the stock hash. The test then points the project config's
      `prompts` at a different module file (never the run directory's `config.json`, which a resume
      never reads: `useCopies` reads only `state.Inputs` and `fingerprint.json`), resumes, and the
      report carries the run copy's hash. This proves the report reads state, not config; it adds
      no seam to the binary.
  - The run report's text and JSON carry the `prompts` line and fields, for a dry run, a real one,
    and `drafter read`'s every-page-unchanged early return.
  - `drafter page` on the stock module refuses with the missing-seat message before any spend
    (`stub.submitted()` is empty; `CheckWorkspace` has run, and the run directory with its input
    copies is left behind, as for any module load error today). `drafter read` on the stock module
    passes the preflight, through F2.0's stub `blueprint` seat.
- Docs: `configuration.md` drops `prompts` from the required list and documents `require_prompts`
  (project file only; environment variable: none);
  `prompts-module.md` gains a section on the stock module, its one seat until B3, and the
  `drafter:` and `#slug` tokens (with F2.2's rules).
- Acceptance: `make check` green in the pair worktree.

### F2.4: tracks, known anatomies, and `introPlan` (100 min), paired with F2.1

Outcome: resolutions 8, 9, and 10.

- Files: `internal/blueprint/{blueprint.go,decode.go,check.go,convert.go}` (`blueprint.go` gains
  only the `Outline.Tracks` field and its `Track` type; `Blueprint` and `Framing` tags are
  unchanged), a new `internal/blueprint/tracks.go` (the glob helper, track matching, and register
  entry lookup), `schema/outline.schema.json`, `cmd/drafter/convert.go` if its report prints the
  judgment line, `internal/scaffold/templates/outline.yaml` (`Reference entry`),
  `docs/blueprint-format.md` (the `tracks` table, the stock anatomy names with a link to
  `stock/anatomies.md`, and `introPlan` as required by the check), and tests beside each.
  `schema/blueprint.schema.json` doesn't change.
- It reads `stock/anatomies.md` for the stock names only through an exported list in `stock`
  (`stock.Anatomies`, added by this task as a literal list beside the embed). F2.3 writes the
  page's headings to match it, and a test in `stock` (F2.3's) asserts the page's `##` headings
  equal the list.
- Tests: one row per state resolution 8 names, at its severity: each decode error (missing field,
  empty `reader`, `paths: []`, duplicate name), each check error (no match, two matches, unknown
  standard, missing register, malformed glob), the no-match warning, and `tracks: []` checking as
  no tracks. The `**` glob cases. An anatomy known by stock name, by register heading, and by
  register bold-lead bullet; one unknown when the type's page matches a track with no register
  though another track's register holds it; one unknown in a register with no `## The page
  anatomies` section. An unknown anatomy is an error with tracks and a warning without, reported
  for a declared type whose pages have no blueprint. A blueprint with no `framing`, and one with
  `framing` but no `introPlan`, fails the check, through `Check` and through `CheckSource`.
  `drafter convert` on a plan with no framing record lists the `introPlan` judgment line and still
  writes the blueprint. Every type in the scaffold's outline template names an anatomy in
  `stock.Anatomies`. The existing schema-match test passes.
- Acceptance: `make check` green. The baseline, measured at planning with the `6583012` binary on
  cairn `main`, is "0 errors, 54 warnings", none about anatomy. With this task, `drafter check` on
  cairn's main checkout reports 0 errors and 56 warnings: the baseline plus exactly the two
  unknown-anatomy warnings, for the types `tutorial milestone` and `symptom row` (listed in the
  commit message).

### F2.2: embedded blocks and the `#slug` excerpt (50 min), by the session in pair A's shadow

Outcome: resolution 5.

- Files: `internal/assemble/files.go` (and a new `internal/assemble/section.go` if the excerpt
  outgrows a function), `internal/plan/slug.go` (the exported headings function of resolution 5,
  with `Anchors` refactored onto it), and tests.
- Tests: a `drafter:` token inlines the embedded bytes; an unknown name says so. `path#slug` inlines
  exactly one section, stopping at the next heading of the same or a higher level, and a deeper
  heading stays inside it. A missing slug says so. A `drafter:` excerpt works. A path token and an
  excerpt token of the same file both inline. An excerpt of a file over the size limit inlines when
  the section is under it. An untracked path's excerpt stays out, as an untracked path does today.
- Acceptance: `go test ./internal/assemble/... ./internal/plan/...` green, then `make check` after
  pair A merges.

### F2.3: the stock read prompt and the reference pages (75 min), paired with F2.5 after pair A merges

Outcome: resolutions 6 and 9's page.

- Files: `stock/prompts.js`, `stock/anatomies.md`, `stock/introductions.md`, `stock/stock_test.go`,
  `stock/testdata/` (a matrix and its expected renderings), and `cmd/drafter/read.go`'s `entryJSON`
  (the `anatomy` and `register` fields) with its test.
- `anatomies.md`: one `##` section per stock anatomy, each giving the sections in order, the
  introduction's parts, and the closing section, with the template's URL and version. It
  paraphrases, never copies, and follows Google developer documentation style.
- `introductions.md`: the design's "Introductions and background" as reference. Every page opens
  with an introduction reasoned fresh. It answers who arrives, what they know, and why they're
  reading, and says what the page covers and doesn't (Google Technical Writing). It says whether the
  reader is studying or working (Diátaxis). The template never supplies its wording. Background a
  reader lacks is a concept-page link or a `sentence` or `reason` item citing its facts. Each rule
  carries its source URL. cairn's register section "### The introduction" is the shape to
  generalize. No cairn text is copied; the drafter repo is public.
- `prompts.js`: the `blueprint` builder per resolution 6, written as goja runs it (no `import`, an
  async body returning the seat map). It holds no reference to a register except the `register`
  branch's token.
- Tests in `stock`:
  - The module loads under `prompts.Load` and defines exactly `blueprint`.
  - Golden renderings for the whole read and the change read, each with an `anatomy`, a `register`,
    and neither. The change-read rendering contains the "Nit:" rule and "Already present:".
  - No rendering without a `register` contains the word "register".
  - The `##` headings of `anatomies.md` equal `stock.Anatomies`.
- Acceptance: `make check` green. The PR body shows `diff` of the stock and chain renderings of the
  change read, which differ only in the anatomy paragraph.

### F2.5: a base-only fact conflict stops escalating (50 min), paired with F2.3

Outcome: resolution 11, closing drafter backlog #12.

- Files: `internal/blueprint/since.go` (`Scope.Bullets` and `Scope.Joined`, computed in `Compare`),
  `internal/pipeline/blueprint.go` (`untouched` and its doc comment), and tests beside each.
- Tests: rows in `TestChangeReadConsistency`:
  - a conflict between two facts the base already cited, one re-cited by a new section, is demoted
    to "Already present:" (the t5a shape);
  - a conflict whose `with` fact the change newly brings onto the page blocks;
  - a conflict whose bullet changed blocks;
  - a scoped state with nil `Bullets` and `Joined` keeps today's rule.

  `Compare` tests cover `Bullets` and `Joined` on add, remove, re-cite, and bullet edit.
- Replay, recorded in the PR body and not a bar: for each of the four saved conflicts above,
  `Joined` and `Bullets` from the cairn format-test commits (base `2c69e5da`, heads `f0ff7d5`,
  `5dbcbdb`, `5bd505d`, `4fd5476`, all still in cairn's object store), computed with `git show`
  and `drafter refs` offline, and the rule's verdict on each. No API call.
- Acceptance: `make check` green. `BACKLOG.md` #12 is closed with the replay's result, and #6 notes
  the base-pairing case closed.

### F2.6: the skill stops naming a register (40 min), by the session in pair B's shadow

Outcome: the blueprint skill's new-page steps 1 and 4 and anything else in the skill that sends an
agent to a register now send it to the stock anatomy and introduction pages, or to the track's
register when the outline names one.

- Files: `claude/.claude/skills/blueprint/{new-page.md,SKILL.md}`, two new links in that
  directory, and `tests/install.test.sh`. Load `claude-infra` first; this is a `runner` path, and
  the wording changes what an agent opens.
- The skill ships `format.md` as a relative link to `docs/blueprint-format.md`, which `make install`
  carries with the skill directory and `tests/install.test.sh` checks. The two stock pages ship the
  same way: `anatomies.md -> ../../../../stock/anatomies.md` and `introductions.md ->
  ../../../../stock/introductions.md`. Step 1 reads the anatomy the type names in
  [anatomies.md](anatomies.md), or the track's register entry when the outline's track names a
  register. Step 4 reads [introductions.md](introductions.md), plus the register's introduction
  rules only when a track names one. O's plugin later packages the same files.
- Acceptance: `grep -rn -i register claude/.claude/skills/blueprint/*.md` (the links' targets
  excluded) shows only lines conditioned on a track that names a register, listed in the commit
  message. `tests/install.test.sh` asserts both new links resolve to the stock files. `make check`
  green.

### F2.7: acceptance on the fixture, the headless session, and cairn's guard (70 min), after pair B merges

Outcome: the design's F2 acceptance rows, run end to end.

- Files: `e2e/setup_test.go` (`TestSetupFromNothing` grows), `e2e/testdata/`, and one cairn-cms
  branch.
- `TestSetupFromNothing` runs with `HOME` holding only drafter and Vale. It drops the
  `prompts = "prompts.js"` lines it writes today, adds a one-track `tracks` entry with a non-cairn
  name and `standard = "google"`, and asserts the following:
  - `drafter config` resolves with only a key source, `workspace_id`, and two caps in the user
    layer and no `prompts` setting, showing the stock module's row.
  - `drafter read --dry-run` on the fixture's blueprint exits 0 and prints the `prompts:` line. A
    dry run resolves the key and calls `GET /v1/models` and `count_tokens` against `api_base_url`,
    and `setupEnv`'s environment holds only `HOME`, `PATH`, and the git variables, so the test
    starts `newAPIStub(t)` and adds `DRAFTER_API_BASE_URL=<stub URL>` and a synthetic
    `DRAFTER_API_KEY` to this one call's environment, then asserts `stub.submitted()` is empty.
  - A type naming an unknown anatomy fails `drafter check`. The fixture state: the test changes the
    anatomy of the type the fixture's blueprinted page uses, so the row can't pass on a type no
    page has.
  - A blueprint with no `introPlan` fails `drafter check`.
  - `require_prompts = true` in the fixture's `drafter.toml` makes `drafter read --dry-run` exit 2
    with resolution 3's sentence. This row needs no stub, since `Validate` refuses first.
- The headless check, outside `make check`, since it runs a Claude Code session on session tokens.
  Probed facts it rests on: with `--print`, `--output-format=stream-json` requires `--verbose`
  (Claude Code 2.1.302 refuses without it); `~/.claude/skills/blueprint` links to the main
  checkout's pre-F2 skill until the merge's `make install`, and "personal over project" decides a
  shared name (<https://code.claude.com/docs/en/skills>, "Resolve skills that share a name"); the
  `user` setting source is what loads `~/.claude/skills/`
  (<https://code.claude.com/docs/en/agent-sdk/claude-code-features>, the `settingSources` table);
  and `--bare` can't serve, since it never reads the subscription login
  (<https://code.claude.com/docs/en/headless>, "Start faster with bare mode"). So:
  1. Make a temp copy of the fixture with no register file anywhere, and put the worktree's
     `claude/.claude/skills/blueprint` under the copy's `.claude/skills/` with its links
     dereferenced (`cp -rL`).
  2. From the copy, with `ANTHROPIC_API_KEY` unset, run `claude -p --verbose --output-format
     stream-json --setting-sources project` with a new-page request that names the `blueprint`
     skill.
  3. Assert the skill under test loaded: the stream carries a sentence only F2.6's skill has (its
     new step 1 wording), so the check can't pass on the pre-F2 skill.
  4. Assert no tool call names a register: no `register` in any Read, Glob, or Grep path or pattern
     argument, and none in any Bash `command` string.

  Record the exact command and the result in the PR body. The fixture is synthetic; no cairn
  content goes in it.
- cairn's guard: on a cairn-cms branch `drafter-require-prompts` from `origin/main`, add
  `require_prompts = true` under the comment at the top of `drafter.toml`, with one comment line.
  With this pass's binary built in the worktree and run by its path, `drafter read --dry-run
  <cairn's one blueprint>` in that branch's worktree with no `drafter.local.toml` exits 2 with
  resolution 3's sentence. Push the branch to `glw907/cairn-cms` and open its PR, held for Geoff's
  packet.
- Acceptance: `make check` green; the headless check and the cairn check pass and are in the PR
  body.

## Close (30 min)

1. The drafter gate on the close head, from the worktree: `DRAFTER_DIR="$PWD" bash
   scripts/drafter-gate.sh`, re-issued on exit 75. drafter has no CI, so this is the full-suite home.
2. One whole-branch `diff-reviewer` read against this plan and the design, at whole-branch scope.
   `prose-voice-reviewer` reads `stock/anatomies.md`, `stock/introductions.md`, and the changed
   `docs/` pages. One batched fix chain follows, then the gate again; a second review only on a
   blocker. A fix dispatch quotes each finding verbatim as its acceptance.
3. The PR body opens with `## Brief` per `~/.claude/docs/voice/approval-brief.md`. Below it go what
   landed, each acceptance row with its result, the headless and cairn checks, the #12 replay, the
   stock and chain change-read diff, every departure from this plan with its reason, and the score
   per pass-core "Score". Name the cairn-cms PR.
4. Each "Found, not done" item worth doing goes to drafter's `BACKLOG.md` through `log-issue`,
   tagged `#initiative:docs-system`, and is listed in the PR body with its number.
5. Stop at PR-ready. The conductor hands the PRs to Geoff.

## Merge order

1. glw907/drafter's F2 PR, `--match-head-commit` from the decision. Then pull `~/Projects/drafter`
   and run `make install` from it, as after F1.
2. glw907/cairn-cms's `drafter-require-prompts` PR. Then pull `~/Projects/cairn-cms` if no session
   works it. From this merge on, cairn's `drafter read` and `drafter page` refuse without a
   `drafter.local.toml` naming its module, which is the guard's purpose. The packet says so: this
   workstation has no `drafter.local.toml` in cairn today, so cairn's reads already fail on
   `prompts`, and they keep failing with the clearer sentence.
3. No architecture spec erratum: the design's F2 scope is unchanged. The hand-over's Status line
   names B3's planning as next.

## Later

Kept out of F2 and never built here:

- The stock text of the draft, structure, editor, fact, and reader seats, the standard package's
  embedded blocks, and the provenance check (B3).
- A `drafter anatomies` subcommand that prints a stock page, if F2.6 finds the skill needs one.
- A track's `reader` profile reaching a seat (B3 decides what the stock prompts read).
- Splitting cairn's register into base and overlay (B5).
