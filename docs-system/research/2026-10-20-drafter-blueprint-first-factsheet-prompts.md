# Factsheet: the prompts modules, covers readers, and the blueprint skill (blueprint-first design)

Read at drafter `main` 6a42564 ("Merge pull request #56 from glw907/worktree-acceptance"), cairn-cms
`main` 52b3f979e. Read-only; no repo file changed. Line numbers are from those commits; each cite
also names its symbol. Design read: `specs/2026-10-20-drafter-blueprint-first-design.md` ("The
gate", "The build path", "What it builds", "The skill").

## 1. stock/prompts.js

**Shape.** The module runs in goja as the body of an async function, with `DRAFTER_HOST` and
`args` as globals, and returns the seat map (`stock/prompts.js:1-4`). It is embedded:
`//go:embed prompts.js` / `var Prompts []byte` (`stock/stock.go:12-15`), served as
`drafter:prompts.js` by `Files` (`stock/stock.go:44-63`). The return (`stock/prompts.js:652-664`):

```js
return {
  blueprint: (c) => {
    const path = c.page && c.page.path;
    const entry = PAGES.find((p) => p.path === path) || {};
    return blueprintPrompt(c.scope || undefined, anatomyFor(entry), c.findings || undefined);
  },
  draft: draftPrompt,
  structure: structurePrompt,
  editor: editorPrompt,
  fact: factPrompt,
  reader: readerPrompt,
  coherence: coherencePrompt,
};
```

Seven seats. `PAGES = (DRAFTER_HOST.resolved && DRAFTER_HOST.resolved.pages) || []` (`:8`). Each
builder takes one context object, rendered to JSON and parsed in the module
(`internal/prompts/context.go:47-60`, `type Context`): `page`, `inputs`, `round` (1, 2, `"final"`),
`findings` (string), `afterFinalRead`, `scope`, `where`, `narrow`, `turn`, `facts` (bool).
`docs/prompts-module.md:117-133` documents the fields; for the blueprint seat `findings` is the read
bar, lines `<n>. [<location>] <text>` (`:127`). Load/render: `prompts.Load`
(`internal/prompts/prompts.go:49`), `(*Module).Render` (`:133`), which errors `no seat %q (have
...)` (`:136`). The comment above the seats: "Their text holds no prose slash and no repository
path but the page's and the brief's, since drafter inlines every path a prompt names"
(`stock/prompts.js:190-192`).

**There is no `consistency` seat in either module.** `docs/prompts-module.md:90-93`: "The seat
names are `draft`, `structure`, `editor`, `fact`, `reader`, `blueprint`, and `coherence`. ...
drafter builds the `coverage` and `consistency` prompts itself, so a module never defines them."
Also `internal/pipeline/start.go:330-331` (`missingSeatsError`): "The consistency and coverage
prompts are built in Go, so no module seat serves them." The consistency prompt is
`assemble.ConsistencyPrompt` (`internal/assemble/consistency.go:21-58`), verbatim user text:

```
Check a documentation page plan for conflicts. The page is %s (%s).
Find each place where two of the placed facts below conflict, or where a placed fact conflicts with a page the plan links. Report a conflict only when both sides cannot be true together; a difference of scope is not one.

Placed facts:
- <id>: <bullet text>            (or ": (not held by exactly one bullet of the facts store)")
Linked pages:
- <rel>  + each heading line     (or "- missing: <rel>")
```

Its answer is `consistencySchema` (`internal/assemble/schema.go:132-141`): `{conflicts: [{facts:
[ids], with: "fact id or page#heading", conflict}]}`, contract "Answer with each conflict you
find, or an empty list." (`:30`). No verdict, kind, blocking, "Nit:", or "Already present:" in
the text; blocking and "Already present"/"Unplaced:" demotion are decided in Go
(`internal/pipeline/handle.go:179-205`, `completeConsistency` `:290`; `record.go:115`
`unplacedPrefix`).

**System text.** Neither the blueprint nor the consistency request carries a system prompt unless
`seat.<name>.agent` is set (`assemble.Build` -> `systemPrompt(seat.Agent)`,
`internal/assemble/assemble.go:81,184-186`); cairn sets `agent` only for `draft` and `editor`.
Every request's first user part opens with `note` (`assemble.go:62-63`, "Files and command outputs
your task needs are inlined below, ...").

**The blueprint read (`blueprintPrompt`, `stock/prompts.js:74-188`), in outline.**
- Opening (`:75-79`): "Blueprint read. The blueprint below is a documentation page's durable plan
  ... No prose exists yet: read the blueprint, never a page. The page's job, type, and what it covers
  sit in its outline entry, and the facts it places sit in the facts block, all inlined below. A
  finding's location is a section id and, when it applies, an item id."
- Google outline + EFA developmental-editor stance (`:81-87`); "How the blueprint is read" field
  glossary and "`drafter check` has already run ... That proves the blueprint consistent, not
  complete" (`:89-98`); `anatomyParagraph(anatomy)` (`:100`, built at `:38-55`: "No other rule in it
  is graded here ... neither blueprint read returns a finding under one").
- Checklist blocks: Red Hat "Structure Checklist" (`:102-108`); covers line (`:109-110`): "Read the
  sections in order against the outline entry: its \`job\` is the page's purpose, its \`covers\` the
  list the page must deliver, and its \`outOfScope\` the page's "doesn't cover" list."; Google
  introduction block (`:112-116`, "Compare the blueprint's introduction to the outline entry's
  \`job\`, \`covers\`, and \`outOfScope\`"); Completeness (`:118-121`); Reader state (`:123-126`);
  Recovery (`:128-133`); "A \`use\` names scope only" (`:135-138`); "Durable fields describe the page
  as it is" (`:140-143`); Human-origin items (`:145-147`).
- Verdict (`:149-151`): "A checklist item the blueprint fails is a blocking finding: its section
  id, and item id where one applies, as location, the item it fails and how, and in rewrite a
  suggestion for how to address it. Verdict "fix" if any blocking finding exists; otherwise "ok"."
- Change read, only when `scope` is truthy (`:151-174`): blocks "only when the change makes the page
  wrong or leaves a reader stuck: a claim past its fact, invented output, a handler that loops or
  dead-ends, a state no step supplies, or a missing step" (`:161-163`); "Order, pace, heading form,
  field placement, and a \`use\` that restates its fact are non-blocking, and their finding text
  starts "Nit:"" (`:166-167`); "A Nit never makes the verdict "fix". Every other defect is
  non-blocking: set blocking to false and start its finding with "Already present:"" (`:171-173`).
- Bar, only when `findings` is truthy (`:174-186`): "A listed finding the change didn't fix is a
  blocking finding at its location, and its text starts "Still open:". It blocks whatever its
  class" (`:177-179`), then "The earlier findings:\n${findings}".
- No "kind" anywhere in the blueprint text. The blueprint answer schema omits `kind` on purpose:
  `AnswerBlueprint` -> `readSchema(false)`; "The blueprint read's findings carry no kind, so its
  request bytes stay as they were before kinds existed." (`internal/assemble/schema.go:21-22,101-112`).
  The review kinds enum (`schema.go:84`) already includes `fact`: "fact, a fact the page states
  wrongly or leaves out" (`:93`).

**How `covers` and the outline entry render.** The stock module never interpolates `covers`; it
only names the field in prose (`:109-110`, `:115`, `:480`). Drafter appends the entry itself:
`BlueprintBlock` (`internal/assemble/blueprint.go:54-57`) wraps the blueprint and `EntryJSON`
(`internal/pipeline/blueprint.go:40-57`, `type outlineEntry` with `Covers []string
json:"covers,omitempty"`) between `=== outline entry ===` delimiters. The facts precede it in
`FactsBlock` (`assemble/blueprint.go:17-49`): `- <id> [<tag>]: <text>`, no excerpts. The module's
`resolved.pages` entries come from `entryJSON` (`cmd/drafter/read.go:474-486`): `"covers":
nonNil(p.Covers)`. Source type: `blueprint.Page.Covers []string yaml:"covers" plan:"prose"`
(`internal/blueprint/blueprint.go:160`); `schema/outline.schema.json:39` `"covers": {"type":
"array", "items": {"type": "string", "minLength": 1}}`; `internal/blueprint/convert.go:38`
`Covers []string json:"covers"`. (A blueprint's own `introduction.covers` is a separate string
field, `schema/blueprint.schema.json:17`.)

**stock/stock_test.go assertions on rendered text.**
- `TestStockModuleSeats` (`:62-68`): seats must equal `{"blueprint","coherence","draft","editor","fact","reader","structure"}`.
- `TestStockRenderings` (`:72-98`): `stock/testdata/matrix.json` must hold exactly 6 cases
  (`:74`), each byte-equal to `stock/testdata/<name>.txt` (whole-anatomy, whole-register,
  whole-neither, change-anatomy, change-register, change-neither; all blueprint seat).
- `TestStockRenderingContent` (`:100-141`): the anatomy token present; the **register ban**: "if
  !tt.mention && strings.Contains(strings.ToLower(got), "register")" (`:130`); and
  `starting "Nit:"`, `start its finding with\n"Already present:"` (a literal newline, so line
  wrapping is pinned), and `Change read.` present iff a change case (`:133-138`).
- `TestStockBarRenderings` (`:148-195`): `bar-matrix.json` exactly 2 cases (bar-anatomy,
  bar-register) with goldens; the bar render must equal the plain change read +
  `"\n\nEarlier findings."`; must carry `"The earlier findings:\n"+findings`, `its text starts
  "Still open:"`, `It blocks whatever its class`, `A defect the change adds or causes blocks`,
  `its text starts "Already present:"`; must end with the findings.
- `TestStockAnatomySlugs`, `TestStockAnatomyHeadings` (`:199-238`): blueprint render carries
  `` `drafter:anatomies.md#<slug>` `` per stock anatomy.
- `TestFixtureMatrixRenders` (`:278-310`): renders every case of `e2e/testdata/cli/prompts-matrix.json`
  and goldens the first case of each non-blueprint seat; the seats with a golden must equal
  `{"coherence","draft","editor","fact","reader","structure"}` (`:306`). Goldens:
  `stock/testdata/{draft-whole,structure-whole,editor-whole,fact-whole,reader-turn1,coherence-read}.txt`.
- `TestStockDenylist` (`:312-324`): no render (fixture matrix + stock matrix) holds `cairn`,
  `docs/internal`, `docs-register`, `sveltekit`, `cloudflare`, `wrangler`, `glw907`,
  `npm run check:`, `option-map`.
- `TestStockNoRegister` (`:328-334`): no fixture render names "register".
- `TestStockDrafterTokens` (`:376-386`): every `drafter:` token names a served file.
- `TestStockSeatContent` (`:389-428`), `TestStockEditTurns` (`:431-453`): per-case required
  strings for draft/editor/structure/fact/coherence/reader.
- The **slash ban** is not in stock_test.go. It is `drafter check-prompts`' stock-only `path`
  check (`docs/prompts-module.md:209-216`: "A token is a path when it holds a `/` and no `://`, or
  begins `drafter:` ... A repository path must name a file or directory that git tracks, except
  the context's `page.path` and `page.brief`"), run via `stockPaths`/`stockNames`
  (`cmd/drafter/checkprompts.go:162-165`, `:280-281`), tested in `cmd/drafter/checkprompts_test.go:70`
  (`TestStockCheckPromptsPathAndNames`).
- Other goldens of the stock blueprint text: `cmd/drafter/testdata/blueprint-prompt.golden.txt`
  (`cmd/drafter/read_test.go:250-255`) and `cmd/drafter/testdata/read-dryrun-count.golden.json`
  (`cmd/drafter/clifixture_test.go:147-170`, which asserts "count_tokens requests = %d, want the
  consistency read and the blueprint read" `len == 2`).

**What a `facttruth` seat function requires (as the code stands).**
- Module: a map entry in the return (`prompts.js:652-664`) and a builder.
- `TestStockModuleSeats` want list (`stock_test.go:64`).
- `TestStockCheckPromptsMatrixHoldsEverySeat` (`cmd/drafter/checkprompts_test.go:119-140`): the
  stock fixture matrix `e2e/testdata/cli/prompts-matrix.json` must contain a case for every stock
  seat ("matrix seats %v, stock seats %v").
- `TestFixtureMatrixRenders` then goldens the seat's first case and its want list (`:306`) grows,
  unless the seat is special-cased like `blueprint` (`:287`).
- `drafter check-prompts` containment (`cmd/drafter/checkprompts.go:236-251`, `containment`): every
  seat but `blueprint` "must contain page.path"; the blueprint seat must not name it, because "its
  request inlines every repository path its prompt names, and the page is not yet written". A
  pre-prose `facttruth` seat hits the same problem and needs the blueprint's exemption.
- Config: `seatNames` (`internal/config/check.go:16`) lists nine seats; "A `seat.<name>` table for
  any other name is an error" (`docs/configuration.md:328`); config tests pin the seat list text
  (`internal/config/config_test.go:45,514,516`). Stock effort default "`medium` for the rest"
  (`configuration.md:291`).
- Pipeline: read seats are chosen in `internal/pipeline/handle.go:47-48` (`return
  []string{"consistency", "blueprint"}`); `missingSeats` (`internal/pipeline/page.go:169-194`).
- Docs: `docs/prompts-module.md:16-26` ("It defines seven seats") and `:90-93`;
  `docs/configuration.md:308-317` ("The nine seats ...").
- The `drafter check-prompts` matrix fixture `tests/fixtures/drafter/blueprint-matrix.json` is the
  **chain module's** blueprint-mode matrix, not the stock module's (24 cases: blueprint/whole,
  blueprint/change, blueprint/change-bar, draft x6, structure x3, editor x4, fact x4, reader x2,
  coherence x2). The stock matrices are `stock/testdata/matrix.json`, `bar-matrix.json`, and
  `e2e/testdata/cli/prompts-matrix.json` (22 cases, also run by `e2e/checkprompts_test.go:158`).

Touches: `stock/prompts.js`, `stock/stock_test.go`, `stock/testdata/*`,
`e2e/testdata/cli/prompts-matrix.json`, `cmd/drafter/checkprompts.go` (containment),
`internal/config/check.go`, `internal/assemble/schema.go` (an answer with `kind`),
`internal/pipeline/handle.go`, `cmd/drafter/testdata/read-dryrun-count.golden.json`, two docs pages.

## 2. The chain's prompts module (`claude/.claude/workflows/docs-page-chain.js`, 3018 lines)

**Two paths in one file.** The Workflow path runs agents; the drafter path returns early:
`const HOST = typeof DRAFTER_HOST === "undefined" || !DRAFTER_HOST ? undefined : DRAFTER_HOST;`
(`:641`), `const BLUEPRINT_MODE = Boolean(HOST) && !WT;` (`:644`), and `if (HOST) return
DRAFTER_SEATS;` (`:2987`) "just before the slot pool, so no page runs" (header `:310-315`). The
header documents the seat context and both modes (`:300-381`). Under `DRAFTER_HOST`,
`resolvePages()` returns `HOST.resolved` (`:821-822`). Blueprint-mode builders sit between
`// === BLUEPRINT MODE ===` (`:2448`) and `// === END BLUEPRINT MODE ===` (`:2961`). The seat map
(`DRAFTER_SEATS`, `:2966-2986`): blueprint mode maps `blueprint` -> `blueprintPrompt(c.scope ||
undefined, c.findings || undefined)`, `draft: bpDraftPrompt`, `structure: bpStructurePrompt`,
`editor: bpEditorPrompt`, `fact: bpFactPrompt`, `reader: bpReaderPrompt`, `coherence:
coherencePrompt`; handoff mode maps the same seven keys to adapters over the chain's own builders.
Everything else (page inputs, plan, framing, `chain(p)` `:2236`, `worker` `:2992`) is the Workflow
path.

**`blueprintPrompt(scope, findings)`** (`:2318-2425`): the same text as the stock module's except
the anatomy paragraph names cairn's register (`:2344-2348`: "Read the section "## The page
anatomies" of ${REGISTER}, by its exact heading ..."; `REGISTER = a.registerPath ||
"docs/internal/docs-register.md"` `:656`), and the bar is `barParagraph(findings)` (`:2434-2446`),
worded differently from stock ("A listed finding the change didn't fix blocks whatever its class.
This overrides the change read's Nit rule ..."). Covers mention: `:2357-2358`, `:2363`, prose only.
Verdict `:2397-2399`; "Nit:" `:2415,2419`; "Already present:" `:2421,2445`; "Still open:" `:2441`.
**No consistency prompt exists in the chain** (Go builds it, as in section 1).

**Every place `covers` is read, and the string assumption.**
- `canonicalEntry` (`:705-723`): `const list = (v) => (Array.isArray(v) ? v.map(String) : []);`
  ... `covers: list(e.covers),` (`:706,715`). A mapping becomes `"[object Object]"`. Hashed by
  `checksumOf` (`:743-745`), merged by `mergeOutline` (`:776-799`, fields list `:786`). Workflow
  path only (outline probe). Must stay identical to the helper's copy (section 3).
- `OUTLINE_ENTRY` schema (`:526-545`): `covers: { type: "array", items: { type: "string" } },`
  (`:536`), the probe agent's structured output. Workflow path only.
- `startingInventory(p)` (`:1084-1101`): `` ${covers.map((c) => `- ${c}`).join("\n") || "(none listed)"} `` (`:1093`). Workflow (`pageInputsPrompt` `:1048`).
- `scopeLines(p)` (`:1134-1140`): `` const bullets = (xs) => xs.map((x) => `- ${x}`).join("\n"); `` and
  `` parts.push(`What the page covers, from the outline:\n${bullets(p.covers)}`) `` (`:1135,1137`).
  Called by `planPrompt` (`:1279`), `framingPrompt` (`:1381`), `draftPrompt` (`:1580`, handoff
  mode) and **`bpDraftPrompt` (`:2692`, blueprint mode, i.e. `drafter page` on a blueprint)**.
- `structurePrompt` (`:1767-1842`): `` const bullets = (xs) => (xs || []).map((x) => `- ${x}`).join("\n") || "(none listed)"; `` (`:1768`), `${bullets(p.covers)}` (`:1820`). Handoff mode.
- **`bpStructurePrompt(c)`** (`:2762-2795`): same `bullets` (`:2764`), `${bullets(p.covers)}`
  (`:2776`). Blueprint mode.
- Header comments naming covers as strings: `:67` (`covers: ["<a topic the page covers>"]`),
  `:78-80`, `:347`.
- `drafter read` renders only the `blueprint` seat, which never interpolates covers; the
  object-to-string breakage appears at `drafter page` (draft and structure seats) and in the
  Workflow path.

**Tests and fixtures that hold covers.** All are string arrays (checked by walking every JSON
fixture): `tests/fixtures/drafter/blueprint-matrix.json` (27 `covers`, e.g. `["The rotation
steps.", "How to confirm the new key signs."]`), `tests/fixtures/drafter/matrix.json` (51),
`blueprint-seat-baseline.matrix.json` (1, `["A."]`); `default-run.with-outline*.json` hold the
probe schema `covers: {type: array, items: {type: string}}`; the `.golden.md` plan prompts render
covers bullets. Test files: `tests/docs-page-chain-handoff.test.mjs:59-73` (OUTLINE pages with
`covers: ["The install command."]` etc.), `:161` (`pagesFor`); `tests/docs-page-chain-outline.test.mjs:58-74`
(fixture), `:225` (`assert.deepEqual(e.covers, ["The export map."])`), `:198-206` ("the runner and
the helper hash every entry identically", `assert.equal(runnerMerge.canonicalEntry.toString(),
helper.canonicalEntry.toString())`), `:401` (checksum per field), `:709` (`/- The export map\./`
in the structure prompt), `:756` (covers absent from the reader prompt).
`tests/docs-page-chain-blueprint.test.mjs`: parity (`:87-95`), "check-prompts: the blueprint
matrix exits 0" asserting `/24 cases, 0 failed/` (`:97-101`), handoff goldens (`:103-108`), banned
strings in blueprint mode `[".plan.yaml", ".plan.md", ".framing.md", "undefined", "worktree",
"cairn-run-gate", "check:docs-gate"]` (`:114-119`), blueprint goldens (`:241-247`), and
"DRAFTER_SEATS: defines exactly the seven seats in each mode" (`:268-276`). Parity script
`tests/drafter-prompts-parity.sh:18-24` runs both matrices through Node
(`tests/drafter-render-prompts.mjs`) and goja (`drafter check-prompts --expect -`). A
`facttruth` key in `DRAFTER_SEATS` changes the seven-seat test and needs a blueprint-matrix case
(count 24 changes) in both modes, since the test requires the same keys in each mode.

**cairn's local config.** `~/.config/drafter/cairn-cms.local.toml` (no secrets in it) has keys:
`prompts = "~/.claude/workflows/docs-page-chain.js"`, `inline_files =
["~/.local/share/cairn/exemplars"]`, `[gate] index_link_command = '... cairn-docs-outline link
--worktree "$PWD" --outline docs/internal/outlines/${arm}.json --page {page}'`, `[seat.draft]
agent`, `[seat.editor] agent`. drafter does not read that path: it reads `drafter.local.toml` at the
project root (`internal/config/load.go:81-106`; `docs/configuration.md:15`). cairn's
`docs/STATUS.md:20-22` says to copy it "into the drafting worktree as `drafter.local.toml`".
cairn's main checkout has no `drafter.local.toml` today (gitignored, `.gitignore:33`); three cairn
worktrees do, and two point `prompts` at drafter worktrees
(`.claude/worktrees/acceptance-pages/drafter.local.toml`: `prompts =
".../drafter/.claude/worktrees/acceptance/claude/.claude/workflows/docs-page-chain.js"`).
Committed `cairn-cms/drafter.toml` has `require_prompts = true` and `[seat.*]` tables for draft,
structure, editor, fact, reader, coverage, consistency (effort low), blueprint (medium).

**Installed copy.** `~/.claude/workflows/docs-page-chain.js` is a symlink to
`/var/home/glw907/Projects/drafter/claude/.claude/workflows/docs-page-chain.js`, made by `make
install` (`Makefile:45-55`: `ln -sfn $(CURDIR)/claude/.claude/workflows/docs-page-chain.js
$(CLAUDE_DIR)/workflows/docs-page-chain.js`), which refuses a symlinked `~/.claude/workflows`
(stow fold) (`Makefile:41-49`; `tests/install.test.sh`). Not stow. So the main checkout's working
tree is what cairn runs.

Touches: `docs-page-chain.js` (`DRAFTER_SEATS` both modes, a facttruth builder, `scopeLines`,
`bpStructurePrompt` bullets, `canonicalEntry`, `OUTLINE_ENTRY` if the Workflow path must take
mappings), `tests/docs-page-chain-blueprint.test.mjs`, `tests/fixtures/drafter/blueprint-matrix.json`
and `matrix.json`, `tests/docs-page-chain-outline.test.mjs`.

## 3. The cairn-docs-outline helper

Source: `bin/.local/bin/cairn-docs-outline` (462 lines), **Node** (`#!/usr/bin/env node`, CommonJS,
`"use strict"`, `:1,35`). Commands (header `:6-28`): `resolve --worktree --outline --paths`
(prints `{ ok, index, missing, entries, error?, checksum }`, the Workflow's outline probe), `link
--worktree --outline --page` (adds the page's link to the outline index under its group heading,
under a lock; used by cairn's `index_link_command`), `rework-state --worktree --paths --briefs`.
It reads the chain's **JSON stage outlines** (`docs/internal/outlines/<arm>.json`), not drafter's
`blueprints/outline.yaml` (`main` `:429-450`: `JSON.parse(fs.readFileSync(path.resolve(o.worktree,
o.outline), "utf8"))`).

How it reads `covers` (`:50-66`, `canonicalEntry`):

```js
function canonicalEntry(e) {
  const list = (v) => (Array.isArray(v) ? v.map(String) : []);
  return {
    ...
    covers: list(e.covers),
```

called from `resolveEntries` (`:187-211`: `const entry = canonicalEntry({ ...page, exemplarSources,
exemplarTakes }); entries.push({ ...entry, checksum: checksumOf(entry) });`). That is the only
covers read; `link` and `rework-state` never touch covers. Header `:30-33`: "keep canonicalEntry,
fnv, checksumOf, and probeChecksum identical to the runner's copies". In cairn-cms today
`docs/internal/outlines/extend.json` carries `covers` on all 25 pages, as strings duplicating
`blueprints/outline.yaml` (tidy's nine entries match word for word).

Tests: `tests/docs-page-chain-outline.test.mjs` (requires the helper as a module, `:19-21`;
`resolve` `:217-229`; toString identity `:198-206`; link and rework tests). Install: `make install`
symlinks it, `ln -sfn $(CURDIR)/bin/.local/bin/cairn-docs-outline $(PREFIX)/bin/cairn-docs-outline`
(`Makefile:50`); `~/.local/bin/cairn-docs-outline` is that symlink; `tests/install.test.sh:45,56`
checks it.

Touches: `canonicalEntry` here and in the chain together (toString equality test), only if the JSON
outlines carry mapping covers; converting `blueprints/outline.yaml` alone never reaches this helper.

## 4. The blueprint skill (`claude/.claude/skills/blueprint/`)

Files: `SKILL.md` (66 lines), `new-page.md` (47), and three **symlinks**: `format.md ->
../../../../docs/blueprint-format.md`, `anatomies.md -> ../../../../stock/anatomies.md`,
`introductions.md -> ../../../../stock/introductions.md` (git mode 120000).

**SKILL.md frontmatter** (`:1-4`): `name: blueprint`; `description: Change a documentation page
by changing its blueprint. Use when code changes documented behavior, when you notice a docs
deficiency while reading (a wrong claim, a missing example, caveat, failure case, or link), when a
new docs page is needed, when a repo has a \`blueprints/\` directory, or when you run \`drafter
check\` or \`drafter refs\`.` Sections: `# Change a page through its blueprint` (6), `## Find the
blueprint` (10), `## Pick the case` (14), `## Edit` (24), `## Check` (33), `## Read` (39), `## Page
prose is off limits` (57), `## Related` (63).

**The read step, verbatim** (`SKILL.md:39-55`):

> Before the first edit, note `git rev-parse HEAD` as the base. Every read uses that base. Run `drafter check <blueprint>`, commit, then read as a separate command: `drafter read --sync --since <base> <blueprint>`. A read of an uncommitted tree prints "nothing changed" and judges nothing. The read judges the change as a code reviewer judges a pull request; [What `drafter read` does with a blueprint](format.md#what-drafter-read-does-with-a-blueprint) says what blocks and what returns as a "Nit:". It prints each finding with its location and whether it blocks.
>
> Fix every blocking finding, and any Nits you choose, in one batch. Run `drafter check <blueprint>`, commit, and read again. Polish goes before a read, never after an accepted one: once a read accepts, make no further edit, Nits included, because an edit after the last read is a change no read saw. Stop at an accept or after the third read. Findings that start "Already present:" are older defects and stay out of the edit.
>
> | The read ends with | Do |
> |---|---|
> | Exit 0, no blocking finding printed, and no "nothing changed" line | Accepted. Stop. |
> | Exit 0 with a blocking finding printed, or exit 1 with the blueprint read's findings | Fix and read again. |
> | Exit 1 from a consistency escalation | Fix the conflict the change caused and read again. |
> | Exit 1 escalated on rule `cap`, or exit 3 naming `cycle cap` or `spend limit` | Stop reading, commit, and report the stop to the user. |
> | Any other exit 3 | Run `drafter read --sync --resume <run-id> <blueprint>` once. It counts as the same read. |
> | Exit 2 naming the key | Skip the reads and say so in the report. |
> | Exit 2 for a dirty tree, an unresolved `--since`, or config | Fix the cause and rerun. It isn't a read. |
>
> When blocking findings remain after the third read, add one empty commit (`git commit --allow-empty`) whose message lists each by location, and list them to the user in the final report.

Case 3 sends a new page to new-page.md: "3. **A page is missing.** Follow [new-page.md](new-page.md)." (`:18`).

**new-page.md, all steps verbatim.**

> # Add a new page
>
> Use this procedure when a docs page does not exist yet. You write two things: the page's entry in `outline.yaml` and its blueprint. You write no page prose, and you do not run a drafting gate. The nightly run drafts the page. Read the [format page](format.md) sections linked below before you write.
>
> ## 1. Settle the page's job and type
>
> Write down the job: what the reader accomplishes with the page. Pick its page type from the types `outline.yaml` declares. Read the anatomy the type names in [anatomies.md](anatomies.md) for its introduction and ending, or, when the outline's track for the page names a register, that register's entry for the anatomy. The entry's fields and what each requires are in [outline.yaml](format.md#outlineyaml).
>
> Set `covers` and `outOfScope` from the neighbors: read the outline whole, so you know each page's job and what another page owns. Keep out of this page whatever a neighbor owns.
>
> ## 2. Trace each claim to a source
>
> Every command, step, transcript, figure, warning, success signal, and assertion the page makes is a claim. Give each claim one disposition:
>
> - **Carried.** A fact bullet in the facts store already covers it exactly. Cite the fact id.
> - **Filed.** You traced it to code, config, or a vendor doc and filed a new fact bullet with a valid tag and its source; see [What `drafter check` checks](format.md#what-drafter-check-checks). Never file a fact tagged `candidate` or `docs-drift`.
> - **Cut.** The claim does not survive the page. Record the reason in a `dispositions` entry.
> - **Re-pointed.** Another page owns it. Link to that page.
>
> A fact whose only source is another docs page gets retraced to code, config, or a vendor doc first. When that fails, do not cite it. Edit fact bullets with the Edit tool, never a shell append. `drafter check` reports a fact with no valid tag; see [What `drafter check` checks](format.md#what-drafter-check-checks).
>
> ## 3. Write the plan into the blueprint
>
> Argue the order of the sections. Google's outline guidance is the source: structure the page so it introduces information when it is most relevant to the reader. Do not copy the order of `covers`; that list is an inventory.
>
> Fill every required field that [Top-level fields](format.md#top-level-fields) and [sections](format.md#sections) list:
>
> - The `orderReason` explains the order as a whole.
> - A section's `opens` is the one sentence a reader takes from it, decided now. The ending section the page type requires is one of the sections.
> - A placement for every fact id, a `dispositions` entry for every fact the page does not carry, and a link item to the page or entry that states a subordinated fact. Open that target and confirm it states the fact. When it does not, say so in your report.
>
> Use the item kinds in [Items](format.md#items). Place facts as [Say what a placement carries](format.md#say-what-a-placement-carries) says.
>
> ## 4. Frame the introduction
>
> Decide the introduction's framing from the reader before any prose exists. Introductions follow no fixed pattern; reason this page's framing fresh, never from another page's record. Read [introductions.md](introductions.md), and the introduction rules of the register only when the page's track names one. Then fill the `framing` mapping, whose four parts are in [framing](format.md#framing):
>
> 1. **Readers.** Work out who arrives, from where (which pages link here, which index group lists it, a search, a command's output), what each is looking for, what each knows, and what each lacks. Name each reader. When a reader is likely to arrive in the wrong place, name them and the page they belong on.
> 2. **Background.** Name the general model the page sits in, where each outside system fits when the page touches it, and why the thing the page covers exists. Back every point with a fact id. A point you cannot back stays out of the record, and you say so in your report.
> 3. **Place in the doc set.** The page's group and neighbors, what links in and why, what sibling pages own. Word a shared idea fresh instead of repeating a neighbor's opening.
> 4. **Intro plan.** The introduction as two or three paragraphs. It opens on a statement about the subject from the reader's situation, never an imperative and never a sentence about the page. It names each reader's reason, so every reader learns early whether the page answers it. It keeps the three introduction parts and, on a task guide, the one-line contract that names what the reader accomplishes. Name the fact ids each paragraph draws on.
>
> Cite a fact in the framing as [framing](format.md#framing) describes. Put narration of how your planning moved in the commit message, never in the blueprint.
>
> ## 5. Check and commit
>
> Run `drafter check`. Fix every error: [What `drafter check` checks](format.md#what-drafter-check-checks) lists them. Commit the outline entry, the blueprint, and any new fact bullets together. The nightly run drafts the page from there.

The new-page path runs no `drafter read` today; the read loop and its third-read cap live only in
SKILL.md's Read step.

**format.md sections** (`format.md` is `docs/blueprint-format.md`, 801 lines; `# Blueprint format`
1-12): Version and stability 13-17; Layout 18-44; Write prose fields as blocks 45-62; Top-level
fields 63-93 (framing 94-116, exemplars 117-122, sections 123-140); Items 141-164 (Say what a
placement carries 165-179, Refer to a section by id 180-186, Who sets what 187-199); outline.yaml
200-214 (Anatomies 215-224, tracks 225-272); drafted.lock 273-362; What `drafter check` checks
363-411 (Find where a fact is used 412-427); The facts store 428-437 (The bullet grammar 438-455,
The `Source:` grammar 456-490, What verification skips 491-499, Where it runs 500-506); The edit
catalog 507-528; Check what you add 529-540; What `drafter read` does with a blueprint 541-584 (The
read bar 585-612); What `drafter page` does with a blueprint 613-671 (What the draft seat receives
672-681, Small findings 682-705, A red gate that names another page 706-715, What the run writes
716-728); The brief 729-755 (What `drafter gate` checks in a brief 756-801).

**Relation to `docs/blueprint-format.md`.** Not a copy and not generated: a git symlink to it, so
`docs/blueprint-format.md` is the one canonical file. `tests/install.test.sh:49` checks the
installed link resolves there: `check test "$(readlink -e "$home/.claude/skills/blueprint/format.md")"
= "$repo/docs/blueprint-format.md"` (likewise `anatomies.md` `:50`, `introductions.md` `:51`).

**How the skill reaches a session.** `make install` (`Makefile:54-55`): `ln -sfn
$(CURDIR)/claude/.claude/skills/blueprint $(CLAUDE_DIR)/skills/blueprint`. Live:
`~/.claude/skills/blueprint -> /var/home/glw907/Projects/drafter/claude/.claude/skills/blueprint`.
Not stow (`~/.claude/docs/claude-tooling.md:14` records the home: "`claude/.claude/skills/<name>/`
in `~/Projects/drafter` (the `blueprint` skill), linked into `~/.claude/skills/` by its `make
install`"). Edits on drafter `main`'s working tree are live at once.

**Headless reads: BACKLOG #2** (`BACKLOG.md:115-116`, closed): "**#2** Let a headless agent read
the skill's format page from a user-scope install ... Closed with no change. The design's
2026-10-18 probe showed that a headless session is denied a read of a real file inside a
user-scope skill directory, so the denial comes from the harness. Live agents run interactively,
and the format test grants the directory."

**Reference depth.** SKILL.md links `format.md` (29 anchors) and `new-page.md` directly: one level.
new-page.md links `format.md`, `anatomies.md`, `introductions.md`: two levels from SKILL.md.
format.md (the symlinked doc) itself links repo-relative files: `plan-format.md` (`:7,160`),
`../schema/blueprint.schema.json` and `../schema/outline.schema.json` (`:9-10`),
`configuration.md` (`:43,714,733`), `../stock/introductions.md` (`:115`), `../stock/anatomies.md`
(`:219`), `../internal/assemble/consistency.go#L25` (`:539`), `handoff.md` (`:617`). From
`~/.claude/skills/blueprint/` none of these resolve (checked: all MISSING); `anatomies.md` and
`introductions.md` link each other and resolve.

Touches: `new-page.md` steps 2 and 5, SKILL.md `## Read`, a new `exemplar.md` (a real file in the
skill dir; any format change goes in `docs/blueprint-format.md`).

## 5. Tests and lint over the skill files

No test reads `SKILL.md` or `new-page.md` content, checks their commands, or checks their links.
No Vale config in drafter (`.vale.ini` absent) and no CI directory (`.github` absent). `make check`
(`Makefile:59`) = `vet lint test chain-test prompts-parity install-test hook-test`; over `claude/`
it runs only: `chain-test` (the four `tests/docs-page-chain-*.test.mjs` on the chain module),
`prompts-parity` (Node vs goja on the chain module), and `install-test`
(`tests/install.test.sh:47-51`: the skill dir links into a temp HOME, `SKILL.md` is a file, and the
three symlinks resolve to `docs/blueprint-format.md` and `stock/*`). `golangci-lint` covers Go only.
Over `docs/blueprint-format.md` (format.md): `internal/blueprint/docs_test.go:28-52`
(`TestReferenceNamesEverySchemaField`: every property in `blueprint.schema.json` and
`outline.schema.json`, plus the lock fields `page`, `blueprint`, `accepted`, `sections`, appears
in a code span, and every item kind has a `| \`kind\` |` row); `internal/blueprint/catalog_test.go`
(the edit catalog rows); `cmd/drafter/init_test.go:242-251` (the `#the-facts-store` anchor). A new
schema property (covers `id`/`text`, section `covers`) or lock field (`facts`) must appear in the
page in a code span; the lock list at `docs_test.go:37` is hand-kept.

Touches: none required for skill prose; `docs_test.go` lock list if `facts` joins the lock.

## 6. docs/configuration.md and docs/blueprint-format.md

**configuration.md, read mode.** `:209` `| \`mode\` | all | \`batch\` | \`DRAFTER_MODE\` |`;
`:215-217` "\`mode\` is \`batch\` or \`sync\`. In \`batch\` mode drafter sends each stage as a Message
Batch, which costs less and takes longer. In \`sync\` mode it sends streamed Messages calls one at
a time. The flag is \`--sync\`."; `:46` "Only two settings have flags. \`--sync\` sets \`mode\` to
\`sync\`". `mode` is one global setting for `read` and `page`; `drafter read --sync`
(`cmd/drafter/read.go:86`) maps to `config.Flags{Sync: f.sync}` (`:101`).

**configuration.md, seats.** Table `:284-293` (`seats` default "Every seat."; `seat.<name>.effort`
"`high` for `draft`, `low` for `reader`, `coverage`, and `consistency`, `medium` for the rest").
`:308-312` "The nine seats are \`draft\`, \`structure\`, \`editor\`, \`fact\`, \`reader\`, \`coverage\`,
\`consistency\`, \`blueprint\`, and \`coherence\`. \`seats\` lists the ones that run in \`drafter page\`,
and by default it names the first seven. ... The \`consistency\` seat runs only when \`facts.dir\` is
set." `:314-317` the `blueprint` seat runs in `drafter read`, stays out of default `seats`, and
`read` refuses (exit 2) when `[seat.blueprint]` lacks model, effort, or `max_tokens`. `:325-328`
stock defaults for all nine; "A \`seat.<name>\` table for any other name is an error." `:347-349`
`facts.dir` turns on the `consistency` seat.

**blueprint-format.md headings:** as listed in section 4.

- **Covers** (outline.yaml pages table, `:259-269`): "| \`covers\` | What the page covers. |"; schema
  `outline.schema.json:39` strings only. `introduction` mapping "holds \`covers\`, \`priorKnowledge\`,
  \`notCovered\`, and an optional list of \`facts\`" (`:87-88`), a string field. Sections table
  (`:123-140`) has no `covers` field; the schema's section object would need one.
- **Dispositions** (`:75`, `:87-92`): "Each disposition has a \`fact\`, a \`disposition\` of \`cut\` or
  \`subordinated\`, a \`reason\`, and, for \`subordinated\`, a \`reference\` to the link target that now
  carries the fact." Schema `blueprint.schema.json:108-123`: `required: ["fact", "disposition",
  "reason"]`, `additionalProperties: false`, so a disposition naming a covers id needs a schema
  change.
- **Facts pointers and anchors** (`:438-499`): "A pointer is a code span. An anchor is a second code
  span in parentheses right after the pointer, and it quotes or names what the pointer should show"
  (`:446-448`). Forms (`:463-467`): `path:lines` (anchor word within cited lines plus 10 each side),
  `path#name` for `.go/.ts/.tsx/.mts/.cts/.js/.jsx/.mjs/.cjs` with one identifier (anchor word in
  the declaration), bare `path` (exists; a missing one is a warning). Skipped (`:493-498`): "A
  \`#name\` with a dot, such as \`Class.method\`", any `#name` on another extension, and paths with
  characters outside `[A-Za-z0-9_./-]`. Excerpt side: `repo.excerpt` takes the last dotted segment,
  `name = name[strings.LastIndex(name, ".")+1:]`, and looks for a column-0 declaration
  (`internal/assemble/excerpt.go:88`, `excerpt`); BACKLOG #28 (`BACKLOG.md:15-16`).
- **drafted.lock** (`:273-362`): fields `page`, `blueprint`, `accepted`, `sections`, `blocked`
  (`:293-299`); `blocked` holds `commit` and `findings` (`:313-315`); rules `:327-333` ("An accept
  that writes \`accepted\` removes \`blocked\`"; "A read with \`--since\` that accepts writes
  nothing"); `drafter page` writes `accepted` only when "the page's blueprint read covered the whole
  blueprint, or a scoped read accepted when nothing else was new" (`:355-361`). No `facts` field
  today.
- **What `drafter read` does** (`:541-584`): "one batch holding the consistency read, when the
  project has a facts store, and the blueprint read" (`:543-545`); "The consistency read blocks
  only on a conflict that touches a fact the change touched ... a conflict that names no fact and no
  page is recorded as a warning starting "Unplaced:"" (`:556-559`).

Touches: `configuration.md:209-217` and `:308-328`; `blueprint-format.md` outline pages table,
Top-level fields/dispositions, sections table, drafted.lock, What `drafter check` checks (a
`covers` check and `no-excerpt`), What `drafter read` does (a third seat).
