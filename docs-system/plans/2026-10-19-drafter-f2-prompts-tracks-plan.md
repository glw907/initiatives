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
- Path estimate: 275 minutes, against the design's 200 (1.4x), inside standing answer 2's 400.
  F2.0 (10), then pair A: F2.1 (90) beside F2.4 (90), with the session running F2.2 (50) in the
  pair's shadow: 90. Then pair B: F2.3 (75) beside F2.5 (50), with the session running F2.6 (40) in
  its shadow: 75. Then F2.7 (60) and Close (30), plus 10 for the two inter-pair merges. Recent
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
   `drafter config` rows and the fingerprint. cairn's `drafter.toml` sets it (F2.7).

4. **What `drafter config` and the run report show.** The `prompts` row in `Sources()` shows the
   module's source and a short hash: the path and `sha256:<first 12 hex>` from its layer, or
   `drafter:prompts.js sha256:<12 hex>` from `default`. The run report is the summary `drafter page`
   and `drafter read` print, as F1 resolution 2 defined it. Text gains a line under `prices:`,
   `prompts: <name> sha256:<12 hex>`, and JSON gains `prompts` and `prompts_hash`. For a run that
   copied its inputs, the hash is the run copy's, taken from `state.Inputs["prompts"]`, so a resumed
   run reports what it used and never the binary's current module. `run.Input`
   (`internal/run/state.go`) gains a `Source` field that `copyInputs` fills with the module's name;
   a state written before F2 has none and reports `prompts.js (run copy)`. A dry run copies nothing
   and reports the config's module. `pipeline.Summary` gains the two fields, filled in `summary()`
   (`internal/pipeline/pipeline.go`), so `writeSummaryText` and `writeSummaryJSON`
   (`cmd/drafter/page.go`) and `writeReadSummary` print them.

5. **Embedded blocks and the excerpt form.** `fileBlocks` (`internal/assemble/files.go`) scans the
   rendered prompt for path tokens. It learns two forms:
   - `drafter:<name>` names a file in `stock.Files`. It inlines as a `file` block labeled with the
     token, and an unknown name inlines as `not inlined: no drafter file <name>`.
   - `<path>#<slug>`, where `<path>` resolves as a token does today (tracked, or allowed by
     `inline_files`), or is a `drafter:` name. It inlines one section as an `excerpt` block labeled
     with the token: from the heading whose GitHub-style slug is `<slug>` to the next heading of the
     same or a higher level. A slug no heading has inlines as `no excerpt: no heading <slug>`. A
     heading's slug follows the rule `drafter check` already uses for `#anchor` links
     (`internal/plan/pagelinks.go`); the excerpt reuses that function rather than a second copy.

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
   checks, after loading, that the module defines every seat this run renders through it: the
   `p.render` seats of `steps.go` that `cfg.Seats` lists, plus `blueprint` when a page has a
   blueprint. It names the missing seats and, for the stock module, adds `the stock prompts module
   carries only the blueprint read until drafter's stock seat prompts land; set prompts`. Before
   coding, F2.1 confirms that `loadModules` runs before the first stage's spend and records the
   call order in the commit message. If it doesn't, that's a stop: moving it would touch the run's
   start order.

8. **Tracks.** `outline.yaml` gains an optional top-level `tracks` list, so outline v1 stays v1.
   Each entry has `name` (required, unique), `reader` (required, prose: the reader profile),
   `standard` (required; `google` is the only value drafter ships), `paths` (required, at least one
   glob), and `register` (optional, a tracked repo-relative path). A glob matches a page path with
   `path.Match`, except that a `**` segment matches any number of segments; the helper lives in
   `internal/blueprint`. `drafter check` errors when a managed page matches no track or two, when a
   standard is unknown, and when a register path doesn't exist. An outline with no `tracks` checks
   as before. The struct tags stay the schema's source of truth, and `schema/outline.schema.json`
   gains the same fields (the existing test enforces the match).

9. **Anatomies.** The stock anatomies are five Good Docs templates (templates v1.6.0, the version
   cairn's register cites): `Concept page`, `Task guide`, `Tutorial`, `Reference entry`, and
   `Troubleshooting page`. The names match cairn's register entries where the two overlap, so
   cairn's types need no rename. Each is an `##` heading in `stock/anatomies.md`, paraphrased with
   its template's URL, never copied. The check in `pageType` (`internal/blueprint/check.go`) changes
   from "names an anatomy" to "names a known anatomy". An anatomy is known when it's a stock name,
   or an entry in a register the outline's tracks name. An entry is a heading, or a bullet whose
   bold lead is the name, under that register's `## The page anatomies`, which is how cairn's
   register writes its entries. Severity:
   - With tracks declared, an unknown anatomy is an error.
   - With no tracks, an unknown anatomy is a warning. A v1 outline has no way to name a register,
     so cairn's `Tutorial milestone` and `Symptom row` would otherwise fail a check that passes
     today.

   The fix text names the stock anatomies and says a register entry needs a track that names the
   register. This replaces `check.go`'s "set anatomy to the name of a register anatomy entry, such
   as Task guide".

10. **`framing.introPlan`.** `Framing` becomes `plan:"required"` on `Blueprint` and `IntroPlan`
    becomes `plan:"required,prose"`, so `drafter check` reports a missing one as an error. Decode
    still succeeds (`internal/blueprint/blueprint.go`, the comment on required fields). `drafter
    convert` still writes a blueprint whose source plan had no framing record, and its report
    lists the missing `introPlan` as a warning: what the conversion left for a person, beside the
    anatomy it already leaves. That is the design's "a warning, not an error, on a converted
    blueprint"; the check then holds the line. `schema/blueprint.schema.json` follows the tags.
    cairn's one blueprint carries `introPlan` (checked at planning).

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
    blueprint places or cites that the earlier one didn't), both never nil on a scoped page.
    `untouched` then treats a conflict as present at the base when every fact on both sides is a
    store fact, none is in `Bullets`, and none is in `Joined`. Such a conflict comes back as
    "Already present:" and never blocks. A conflict with a changed bullet, or with a fact the change
    brought onto the page, still blocks, since the change made the page carry it. The page-link
    `with` branch and the "Unplaced:" rule stay as they are. A scoped state saved before F2 has nil
    `Bullets` and `Joined` and keeps today's rule. `Scope.Facts` is unchanged, so the change block
    and the scoped sections are byte-identical to today's.

## Tasks

### F2.0: the `stock` package skeleton (10 min), by the session

Outcome: `stock/stock.go` embeds `prompts.js`, `anatomies.md`, and `introductions.md` and exports
`Prompts` and `Files`. The three files exist as one-line stubs, so pair A's tasks import a package
whose API doesn't move. `prompts.js` returns `{}`.

- Files: `stock/stock.go`, `stock/prompts.js`, `stock/anatomies.md`, `stock/introductions.md`.
- Acceptance: `go build ./...` and `go vet ./stock` pass; the session commits before pair A starts.

### F2.1: stock module selection, `require_prompts`, and the run report (90 min), paired with F2.4

Outcome: resolutions 2, 3, 4, and 7.

- Files: `internal/config/{validate.go,layer.go,file.go,config.go,apply.go,sources.go,env.go}` as
  needed, a new `internal/config/module.go` for `Module`, `internal/pipeline/{start.go,pipeline.go}`
  and the `Summary` type's file, `internal/run/state.go`, `cmd/drafter/{page.go,read.go,checkprompts.go,config.go}`,
  `docs/configuration.md`, `docs/prompts-module.md`, and tests beside each. Never `money.go` or
  `resume.go`.
- Tests, table-driven:
  - `Validate` passes with `prompts` unset and fails with `require_prompts = true` and `prompts`
    unset.
  - `require_prompts` in the user or local layer is refused as a misplaced key, as `checkAllowed`
    refuses one today.
  - `Module` returns the stock bytes and `drafter:prompts.js` when unset, and the file when set.
  - The `drafter config` row shows `drafter:prompts.js sha256:` and its 12 hex from `default`.
  - A non-dry run against the e2e fake API (the harness `e2e/page_test.go` uses) writes
    `prompts.js` equal to `stock.Prompts` into the run directory, with the matching hash and
    `Source` in `state.Inputs`.
  - A resume reports the run copy's hash after the test swaps the run's recorded config to a
    different module file. This proves the report reads state, not config; it adds no seam to the
    binary.
  - The run report's text and JSON carry the `prompts` line and fields, for a dry run and a real
    one.
  - `drafter page` on the stock module refuses before any request with the missing-seat message,
    and `drafter read` on the stock module passes the preflight.
- Docs: `configuration.md` drops `prompts` from the required list and documents `require_prompts`;
  `prompts-module.md` gains a section on the stock module, its one seat until B3, and the
  `drafter:` and `#slug` tokens (with F2.2's rules).
- Acceptance: `make check` green in the pair worktree.

### F2.4: tracks, known anatomies, and `introPlan` (90 min), paired with F2.1

Outcome: resolutions 8, 9, and 10.

- Files: `internal/blueprint/{blueprint.go,decode.go,check.go,convert.go}`, a new
  `internal/blueprint/tracks.go` (the glob helper, track matching, and register entry lookup),
  `schema/outline.schema.json`, `schema/blueprint.schema.json`, `cmd/drafter/convert.go` if its
  report prints the warning, `docs/blueprint-format.md` (the `tracks` table, the stock anatomy names
  with a link to `stock/anatomies.md`, and `introPlan` as required), and tests beside each.
- It reads `stock/anatomies.md` for the stock names only through an exported list in `stock`
  (`stock.Anatomies`, added by this task as a literal list beside the embed). F2.3 writes the
  page's headings to match it, and a test in `stock` (F2.3's) asserts the page's `##` headings
  equal the list.
- Tests: each track error (no match, two matches, unknown standard, missing register), the `**`
  glob cases, an anatomy known by stock name, by register heading, and by register bold-lead
  bullet. An unknown anatomy is an error with tracks and a warning without. A blueprint with no
  `framing` or an empty `introPlan` fails the check. `drafter convert` on a plan with no framing
  record reports the `introPlan` warning and still writes the blueprint. The existing schema-match
  test passes.
- Acceptance: `make check` green; `drafter check` on cairn's main checkout reports no new error,
  and its new warnings are exactly the unknown-anatomy warnings for `Tutorial milestone` and
  `Symptom row` where a managed page uses them (listed in the commit message).

### F2.2: embedded blocks and the `#slug` excerpt (50 min), by the session in pair A's shadow

Outcome: resolution 5.

- Files: `internal/assemble/files.go` (and a new `internal/assemble/section.go` if the excerpt
  outgrows a function), `internal/plan/pagelinks.go` only to export its slug function if it isn't
  exported, and tests.
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

### F2.7: acceptance on the fixture, the headless session, and cairn's guard (60 min), after pair B merges

Outcome: the design's F2 acceptance rows, run end to end.

- Files: `e2e/setup_test.go` (`TestSetupFromNothing` grows), `e2e/testdata/`, and one cairn-cms
  branch.
- `TestSetupFromNothing` runs with `HOME` holding only drafter and Vale. It drops the
  `prompts = "prompts.js"` lines it writes today, adds a one-track `tracks` entry with a non-cairn
  name and `standard = "google"`, and asserts the following:
  - `drafter config` resolves with only a key source, `workspace_id`, and two caps in the user
    layer and no `prompts` setting, showing the stock module's row.
  - `drafter read --dry-run` on the fixture's blueprint exits 0 and prints the `prompts:` line.
  - A type naming an unknown anatomy fails `drafter check`.
  - A blueprint with no `introPlan` fails `drafter check`.
  - `require_prompts = true` in the fixture's `drafter.toml` makes `drafter read --dry-run` exit 2
    with resolution 3's sentence.
- The headless check, outside `make check`, since it runs a Claude Code session on session tokens:
  in a temp copy of the fixture with no register file anywhere, run `claude -p` with the
  `blueprint` skill on a new-page request, `ANTHROPIC_API_KEY` unset, `--output-format
  stream-json`, and the fixture as its only added directory. Then assert that no tool call's path
  argument names a register (no `register` in any Read, Glob, or Grep path). Record the command and
  the result in the PR body. The fixture is synthetic; no cairn content goes in it.
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
