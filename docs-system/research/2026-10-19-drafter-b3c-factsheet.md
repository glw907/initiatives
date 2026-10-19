# Factsheet: drafter B3c, the cairn pilot (read 2026-10-19)

Code is quoted at drafter `3c2c5cb` (branch `worktree-b3-drafting`, PR glw907/drafter#53, open) and
cairn-cms `main` `11104274e`. Lines move; find each symbol by name. Probes ran in
`/tmp/claude-1000/-var-home-glw907-Projects-drafter/98272137-e879-4cd3-b816-037dd2bfda73/scratchpad/b3c-probes/`
with a binary built from `git archive 3c2c5cb` (`drafter-b3`) and a `git clone --shared` of cairn at
`11104274e` (`cairn/`). No API call was made.

## How a whole read records its outcome today

- `drafter read` with no `--since` reads each blueprint whole; `--since <rev>` resolves the rev with
  `git rev-parse --verify <rev>^{commit}` and calls `scopePages` (`cmd/drafter/read.go:121-129`).
- `scopePages` (`read.go:232-252`) builds `old`/`cur` with `revisionAt` (`read.go:315-356`), runs
  `blueprint.Compare`, skips `ScopeUnchanged` with "nothing changed since <rev>", and for
  `ScopeScoped` builds the change block with `changeBlock` (`read.go:266-305`). It takes one `since`
  for every page.
- `pipeline.Options.Since` is one string (`internal/pipeline/pipeline.go:61`); `addPages` copies it
  with the page's scope and change into `work` (`internal/pipeline/start.go:276-278`). Nothing else
  reads `w.Since` (grep at `3c2c5cb`).
- After `pipeline.Run`, `recordAccepted` (`read.go:464-502`) writes only `accepted`, only for an
  accepted page whose accept was not scoped; a dry run or a stopped run writes nothing
  (`read.go:465-467`). `scopedAccept` is an accept on a `ScopeScoped` page (`read.go:360-362`).
- A blocked read writes nothing to the lock. Its findings reach the summary as
  `PageResult.Findings` (`pipeline.go:107-108`), with no field saying whether the read was whole.
- The read's prompt: `stageBlueprintRead` renders the `blueprint` seat at round 1; on a change read
  it sets `c.Scope` to `page` or the section ids and appends the scope sentence and `p.w.Change` to
  the request's `Extra` (`internal/pipeline/blueprint.go:145-153`). `c.Findings` is never set for
  the blueprint seat. `changeRead()` is a `ScopeScoped` scope with non-nil `Facts`
  (`blueprint.go:61-63`); `untouched` reads `p.w.Scope` (`blueprint.go:191-215`).
- `completeBlueprintRead` escalates a consistency conflict before it looks at the blueprint verdict
  (`blueprint.go:234-270`), escalates `fix` with rule `plan` (`blueprint.go:271-277`), and on accept
  sets `p.w.Accepted` and either drafts (`toDraft`) or accepts (`blueprint.go:278-286`).
- `PageResult` carries `Scope`, `Accepted`, `Findings`, `Rule`, `Detail` (`pipeline.go:91-114`).

## The lock

- `LockEntry{Page, Blueprint, Accepted, Sections}` (`internal/blueprint/blueprint.go:185-195`).
- `DecodeLock` decodes with `KnownFields(true)` and requires `version: 1` (`internal/blueprint/lock.go:58-69`),
  so a binary that lacks a new field refuses a lock that holds it.
- `LockIntroducedAt` compares only `page`, `blueprint`, and `sections` (`internal/blueprint/drafted.go:64`),
  so any other field is ignored by the walk.
- `DraftedEntry` builds a fresh entry through `newLockEntry` and sets `Accepted` from its argument
  (`drafted.go:15-39`); any other field the old entry held is dropped.
- cairn's lock today holds one entry, rotate's, with `page`, `blueprint`
  (`e299f141f3305a3a68cc67fbfdc6350f589d0918`), and `sections`, and no `accepted`
  (`cairn-cms blueprints/drafted.lock:1-17`). Rotate's blueprint changed in six commits after the
  conversion that seeded it (`git log -- blueprints/`: `80b7a9079` to `dca26f670`), and the last,
  `dca26f670`, says "This commit has not been read through the API".

## How `drafter page` scopes from the lock (B3)

- `runPageBlueprints` (`cmd/drafter/pagebp.go:25-109`): validates seats `blueprint` and `coherence`
  (`:38-42`), takes the start commit, builds handoffs with `blueprintHandoffs`, then `inRun` on a
  resume or `scopeFromLock` otherwise (`:55-60`), and calls `pipeline.Run` with `Scopes`, `Changes`,
  `Draft: true`, `SkipRead` (`:84-88`). `recordDrafted` follows (`:96`).
- `scopeFromLock` (`cmd/drafter/draftscope.go:65-95`): a page `pageScopeFor` finds up to date is
  skipped with "up to date with drafted.lock"; `SkipRead` is set when the entry's `accepted` equals
  the blueprint's blob at the start commit (`:90-92`, `skipRead` at `:99-101`).
- `pageScopeFor` (`draftscope.go:110-157`): no `page` id drafts whole (`:111-113`); otherwise the old
  revision is the entry's blueprint blob plus the outline and facts at the parent of the commit that
  introduced the entry (`:117-123`), and `Compare` decides. A scoped page with ids and no brief at
  the start commit drafts whole (`:133-136`); otherwise it may become a section redraft.
- `pageFlags` (`cmd/drafter/page.go:22`) has `--workflow-run`, `--resume`, `--dry-run`, `--sync`,
  `--json` (`page.go:53-57`). No flag forces a whole draft. So a converted page whose blueprint is
  unchanged since conversion is "up to date" and never drafts, and one whose blueprint changed may
  become a section redraft of the old page once a brief exists at its brief path.
- `recordDrafted` (`pagebp.go:182-233`): writes an entry only for an accepted page; its `accepted`
  is the run's when the accept was not scoped, else the prior value (`:211-214`).
- An escalated page's page and brief are restored to their pre-run content, or removed when the run
  created them (`internal/pipeline/page.go:317-320`, `restore` at `:331-345`).

## How conversion seeds a lock entry

- `drafter convert plan [--framing <record>] --outline <json>... <plan.yaml>`
  (`cmd/drafter/convert.go:97-126`); `--framing` is optional (`convert.go:150-154`).
- `InstallConverted` writes the blueprint, refuses a page with uncommitted changes (`install.go:76`)
  and a page the lock already has (`install.go:84`), and seeds the entry from the page at HEAD when
  the page exists (`install.go:109`, `newLockEntry` at `:126`). No page means no entry
  (`convert.go:201-202`).
- The framing record's headings must be the four in `framingFields`
  (`internal/blueprint/convert.go:156-161`) or "Departures from the plan's introduction"; any other
  heading fails the conversion (`convert.go:264`).
- `seedEntry` keeps the old `accepted` (`internal/blueprint/seed.go:108`).

Probe (scratch clone, `drafter-b3`): converting the seven plans.

| Page | Plan lines | Framing record | Page lines | Convert | `drafter check` errors |
|---|---|---|---|---|---|
| using-claude-code-with-cairn | 656 | none | no page | ok, no seed | 25 |
| debug-your-site | 1125 | none | 413 | ok, seeded | 42 |
| restrict-admin-access | 1270 | none | 366 | ok, seeded | 81 |
| scaffolded-site-files | 1299 | yes | 554 | ok, seeded | 109 |
| security-model | 1566 | yes | 539 | fails: heading "Who arrives, from where, why" | 108 (from a copy with the two headings renamed) |
| add-a-second-sign-in-group | 1944 | yes | 682 | ok, seeded | 39 |
| add-cairn-to-a-sveltekit-app | 2617 | yes | 1225 | ok, seeded | 120 |

- The 524 errors are 345 `use` (a use that doesn't open with Only or Omit), 173 `why` (a section with
  no why), 3 `framing` (no `introPlan`: debug, restrict, claude-code), and 3 `ids`. `drafter check`
  on the unchanged clone prints `0 errors, 56 warnings`.
- security-model's record also has "Background the page rests on (the old intro skipped it)". With
  both headings renamed to the converter's in a scratch copy, it converts.
- Converted blueprint lines: claude-code 626, debug 1145, restrict 1312, scaffolded 1452, security
  1612, add-a-second 2246, add-cairn 2871; rotate's reshaped blueprint is 1187.
- Rotate's conversion commit (`80b7a9079`) names the reshape: "gave each section a why, cut
  orderReason to the order as a whole, rewrote each use to name scope only, replaced heading
  references with [[section-id]], and moved planning history out of the durable fields". Its
  framing preamble and departures went into the commit message.
- The design says only claude-code lacks a framing record. debug-your-site and
  restrict-admin-access lack one too (`ls docs/internal/briefs/extend/`).

## The brief path

- `blueprint.BriefPath(root, page)` is the blueprint path with `.blueprint.yaml` replaced by
  `.brief.json` (`internal/blueprint/brief.go:8-10`). Callers: `blueprintHandoffs`
  (`cmd/drafter/read.go:406`, which sets both `handoff.Page.Brief` and `entryJSON`'s `brief`) and
  `gateProvenance` (`cmd/drafter/gate.go:159`, from `blueprint.Project.BlueprintRoot`).
  `pageScopeFor` reads `h.Page.Brief` (`draftscope.go:133`).
- `blueprint.Project` has `Root`, `BlueprintRoot`, `Outline`, `FactsDir`, `Required`
  (`internal/blueprint/project.go:19-25`), filled by `projectFor` (`cmd/drafter/check.go:48-71`).
  `config.Blueprints` has `Root`, `Required`, `Outline` (`internal/config/config.go:102-106`;
  file keys `internal/config/file.go:87-91`; applied `internal/config/apply.go:155-157`).
- Config files decode strictly: an unknown key fails the load (`internal/config/file.go:98-106`).
- cairn: a brief lives at `docs/internal/briefs/<track>/<page>.json`
  (`scripts/checks/check-provenance.mjs:1-3`; `BRIEFS_DIR` at `:107`). A brief argument outside that
  directory is a defect "is not under docs/internal/briefs/" (`:661`). A brief needs a `page` string
  (`:698`) and must be filed under its page's own base name (`:714`).
- cairn's gate is `npm run check:docs-gate -- --page {page} --brief {brief}` through
  `cairn-run-gate` at lane `light` (`cairn-cms drafter.toml:8-11`). `docs-gate.mjs` builds `dist` once
  (`npm run package`), narrows Vale and tellgrader to `--page`, narrows `check:provenance` to
  `--brief`, and runs every other check over the whole tree (`scripts/checks/docs-gate.mjs:7-12`,
  `:66-109`, `:115-123`).
- cairn CI on `11104274e`: e2e, design, scaffold, create-site, and test all `success`
  (`gh run list --branch main`).

## The prompts module cairn loads

- cairn's committed config sets `require_prompts = true` (`drafter.toml:6`); the module comes from
  each workstation's ignored `drafter.local.toml` (`.gitignore:33`). cairn's STATUS says to copy
  `~/.config/drafter/cairn-cms.local.toml` into the drafting worktree as `drafter.local.toml`
  (`docs/STATUS.md:21-24`). On this workstation (pavilion) that file sets `prompts =
  "~/.claude/workflows/docs-page-chain.js"`, `inline_files = ["~/.local/share/cairn/exemplars"]`,
  `gate.index_link_command`, and `seat.draft.agent` and `seat.editor.agent`. No `drafter.local.toml`
  exists in cairn's main checkout.
- `~/.claude/workflows/docs-page-chain.js` is a symlink into drafter's main checkout,
  `claude/.claude/workflows/docs-page-chain.js` (`ls -la`), made by `make install`
  (`Makefile:39-53`, the `ln -sfn $(CURDIR)/...` line). So the module a run loads is whatever
  drafter's main checkout holds.
- `DRAFTER_SEATS` defines `blueprint`, `draft`, `structure`, `editor`, `fact`, `reader`, and no
  `coherence` (`docs-page-chain.js:2377-2388` at `3c2c5cb`). B3's stock module defines those plus
  `coherence` (`stock/prompts.js:638-648`).
- A blueprint handoff carries no chain args, so drafter loads the module with `args` `{}`
  (`internal/pipeline/start.go:342-343`; `internal/prompts/prompts.go:53-56`). The chain's header
  says so: "drafter loads the module for a blueprint read with no chain args"
  (`docs-page-chain.js:321`), and its args guard runs only outside `DRAFTER_HOST` (`:612`).
- The page context of a blueprint page is `entryJSON`'s: `path`, `slug`, `title`, `pageType`, `job`,
  `covers`, `outOfScope`, `figure`, `anatomy`, `brief`, `standard`, and `reader`/`register` from a
  track (`cmd/drafter/read.go:432-448`). It has no `track`. cairn's `outline.yaml` declares no
  `tracks` (top-level keys `version`, `types`, `pages`).
- The chain's back-half seats read handoff-only values: `registerSectionsFor(p.track)` throws on an
  unknown track (`docs-page-chain.js:630-651`); `gateFor` calls `GATE.replaceAll`, with `GATE =
  a.gate` (`:575`, `:982-985`); the shared preamble names `WT = a.worktree` (`:574`, `:862-867`);
  `briefPathFor`, `planPathFor`, and `framingPathFor` build `docs/internal/briefs/<track>/...` paths
  (`:883-904`).

Probe (`drafter-b3 check-prompts --module <chain at 3c2c5cb>`, host args `{}`, rotate's `entryJSON`):

- `blueprint` renders. `draft` and `editor` fail: "unknown track \"undefined\": no register track
  section". `coherence` fails: "no seat \"coherence\"". `structure` and `fact` render.
- With `track: "extend"` added to the page, `draft` still fails at `gateFor`: "Cannot read property
  'replaceAll' of undefined or null". A Node render of the same module (`js/render.mjs`) shows
  `structure`, `editor`, and `fact` naming "the worktree undefined",
  `docs/internal/briefs/extend/rotate-the-github-app-key.plan.yaml`, and
  `docs/internal/briefs/extend/rotate-the-github-app-key.framing.md`, and the reader naming "in
  undefined".
- A prompt token naming a tracked repo file, or a path under `inline_files`, is inlined in the
  request (`internal/assemble/files.go`, `openRepo` and `allows`), so a seat naming the v1 plan
  would be sent the stale plan beside the blueprint. Inlining caps a file at 256 KiB
  (`files.go`, `sizeLimit`); cairn's register is 90,601 bytes.
- cairn-docs-outline maps an exemplar capture directory to `page.md` inside it under
  `~/.local/share/cairn/exemplars` (`bin/.local/bin/cairn-docs-outline:168-176`, `:31`). Rotate's
  blueprint exemplars name capture directories (`operators/cloudflare-create-token/`), with `take`
  lines (`blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml:264-272`).

## claude-code

- The page is `docs/claude-code/using-claude-code-with-cairn.md` (`docs/internal/outlines/claude-code.json`
  `pages[0].path`); no `docs/claude-code/` directory exists. Its JSON outline names `track:
  "claude-code"` and no `index` (`claude-code.json:2-3`); extend's names `docs/extend/README.md`
  (`extend.json:4`).
- The register has no claude-code track section (`docs/internal/docs-register.md` headings
  `:824-961`), and the chain throws on that track (`registerSectionsFor`, above).
- The plan's own friction, printed by `convert`: the register "has no `claude-code` track entry ...
  This plan takes the extend track's reader profile as the baseline, per the outline's `job`"; and
  "no gate registers the `claude-code` arm yet. ARM_NAMES, ARM_DIRS, the arm-index check,
  package-files, snippets, symbols, visuals, leaks, the links check, and `package.json` `files` all
  need the new `docs/claude-code/` directory before the page can ship".
- `check-arm-indexes.mjs` checks only the arms in its `ARMS` list (`:37-43`), which lacks
  `docs/claude-code`. `ARM_DIRS` lacks it (`scripts/checks/arm-state.mjs:28`).
- cairn's STATUS puts the arm's gate registration and its register track entry in "the drafting run
  that follows" (`docs/STATUS.md:29-31`). The B3c design's out-of-scope list names relinks,
  `LEGACY_PATH_MAP`, the arm index, and the boundary test.

## Money

- Meter on 2026-10-19 (`drafter spend --since 2026-10-19 --json`): `total 25.5906`, `open {count 1,
  worst 0.99695}`. The open intent is the batch B3 cancelled (PR #53 body, "Departures").
- Month to date (`--since 2026-10-01`): `total 40.2748`. User layer: `page_cap = 10`,
  `cycle_ceiling = 160`, `mode = batch` default (`drafter config`).
- cairn reads since 2026-10-19: 51 blueprint reads $8.0333 and 51 consistency reads $1.4104, so about
  $0.185 a read with its consistency read (the design's $0.22 is the month's average).
- `DRAFTER_PAGE_CAP` is read by the environment layer (`internal/config/env.go:12`, `:84`), and a cap
  resolves to the lowest layer's value (`putCap`, `internal/config/apply.go:90-98`). The cap is per
  page per run (`internal/ledger/ledger.go:125-128`, `pageTotal(r.RunID, r.Page)`).
- The run mode is in the config fingerprint (`internal/pipeline/fingerprint.go:18`), so a resume
  can't switch between batch and `--sync`.
- B3's reader finding (PR #53 body, "Decide"; drafter backlog #18): about one reader call in four hit
  its 32000-token ceiling at about $1.2, and the failures table gives the reader reads no retry. B3
  moved the stock reader to `low`; cairn's own `drafter.toml` sets the reader at `medium`
  (`drafter.toml:51-54`).

## Other

- `make build` writes `./drafter` (`Makefile:7-8`, ignored by `.gitignore`'s `/drafter`); `make
  install` installs it and points the chain and skill symlinks at `$(CURDIR)` (`Makefile:39-53`), so
  installing from a worktree would point them into the worktree.
- `make check` runs vet, lint, test, chain-test, prompts-parity, install-test, hook-test
  (`Makefile:55`). `prompts-parity` renders `tests/fixtures/drafter/matrix.json` in Node and in
  goja and requires byte equality (`tests/drafter-prompts-parity.sh`).
- `drafter page` exit: 3 stopped, 1 any page not accepted or unchanged, else 0
  (`cmd/drafter/page.go:63-72`).
- cairn worktrees present: `blueprint-pilot` (at `dca26f670`) and `repo-organization` (another
  session's); `git -C ~/Projects/cairn-cms worktree list`.
- cairn worktree setup: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx
  svelte-kit sync)` (`cairn-pass` skill, "Worktree setup").
