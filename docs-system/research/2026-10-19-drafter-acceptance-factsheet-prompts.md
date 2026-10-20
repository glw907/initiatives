# Factsheet: review-seat findings shape, for a per-finding `kind` (drafter main 8ee513a)

Read-only. Paths relative to /var/home/glw907/Projects/drafter. CHAIN = claude/.claude/workflows/docs-page-chain.js.

## 1. stock/prompts.js: answer-shape sentences per seat; exports; rendering

Module shape: runs "in goja as the body of an async function, with DRAFTER_HOST and args as globals, and returns the seat map" (prompts.js:1-4). The return (prompts.js:652-664):
```
return {
  blueprint: (c) => { ... return blueprintPrompt(c.scope || undefined, anatomyFor(entry), c.findings || undefined); },
  draft: draftPrompt, structure: structurePrompt, editor: editorPrompt,
  fact: factPrompt, reader: readerPrompt, coherence: coherencePrompt,
};
```
Each seat is a function of one context object `c`. Go side: `prompts.Context` fields page, inputs, round, findings, afterFinalRead, scope, where, narrow (RawMessage), turn, facts (internal/prompts/context.go:49-59); tests call `mod.Render(seat, ctx)`.

Shared closing paragraph `findingRule()` (prompts.js:388-392), used by structure, editor, fact, reader turn 2, coherence:
> "A finding names its location (the section heading, and the sentence when it applies), what is wrong, a rewrite that fixes it, and whether it blocks. Verdict "fix" if any blocking finding exists; otherwise "ok"."

Per seat:
- **blueprint** (does NOT use findingRule): prompts.js:78-79 "A finding's location is a section id and, when it applies, an item id." and 149-151 "A checklist item the blueprint fails is a blocking finding: its section id, and item id where one applies, as location, the item it fails and how, and in rewrite a suggestion for how to address it. Verdict "fix" if any blocking finding exists; otherwise "ok"." Change read adds "Nit:" / "Already present:" prefixes (167-174); the bar adds "Still open:" (178-183).
- **structure**: prompts.js:483 "A checklist item the page fails is a blocking finding. ${findingRule()}".
- **editor**: prompts.js:496-498 "Each rule a sentence breaks, and each pattern a sentence shows, is a blocking finding; name the rule or the pattern by its heading. A point of preference that neither file states is advisory, and its finding starts "Nit:"." then 506 `${findingRule()}`.
- **fact**: prompts.js:523 "Check each of these. Each failure is a blocking finding, located at the sentence:" ... 535 "Leave style to the editor seat and structure to the structural edit. ${findingRule()}".
- **reader** turn 1: no findings (paraphrase/summary/friction; prompts.js:604-611). Turn 2: prompts.js:576-579 "Each mismatch between your paraphrase and that job is a blocking finding ... Each point where you had to infer is a finding, blocking when it is an unstated step, a failure the page never explains, or a term it never defines." then 582 `${findingRule()}`.
- **coherence**: prompts.js:646-649 "A finding blocks when a reader reading straight through would lose the thread; otherwise it is advisory. ${findingRule()}".
- Narrowing (any review seat): prompts.js:420 "A defect outside them that the change didn't cause is advisory: set blocking to false and start its finding with "Already present:"." Round 2 renders own findings as `- [blocking|advisory] location: finding` (prompts.js:424-426), no other field.

Text constraints the stock module carries: prompts.js:190-192 "Their text holds no prose slash and no repository path but the page's and the brief's". Tests enforce: no "register" in any fixture render (stock/stock_test.go:328-335 TestStockNoRegister; and for non-register blueprint renders, stock_test.go:130-132); denylist incl. "cairn", "option-map" (stock_test.go:315; cmd/drafter/checkprompts.go:275-278); any token with "/" must be a tracked path (checkprompts.go:334-339).

## 2. The chain (CHAIN)

**Mode choice**: CHAIN:611 `const WT = a.worktree;`, 641 `const HOST = typeof DRAFTER_HOST === "undefined" || !DRAFTER_HOST ? undefined : DRAFTER_HOST;`, 644 `const BLUEPRINT_MODE = Boolean(HOST) && !WT;`. Header: CHAIN:344-346 "Handoff mode, with a chain handoff's args (so `args.worktree` is set), renders exactly what the chain sends ... Blueprint mode, with no `args.worktree`, is how drafter loads the module for a blueprint page". Seat map CHAIN:2966-2986 (`BLUEPRINT_MODE ? {bp*...} : {handoff adapters}`), returned at 2987 `if (HOST) return DRAFTER_SEATS;`.

**Shared between modes** (an edit to these changes handoff renders): `blueprint` seat is the same `blueprintPrompt` in both maps (CHAIN:2967 and 2975); `coherence: coherencePrompt` in both (2973, 2985); helpers `structureChecklist()` (1844, "Both modes' structure seats send it unchanged", 1841), `CAP_SCOPE` (1209), `combined()` (1983), `registerLine` (893).

**Blueprint-mode answer-shape sentences**:
- blueprint (shared `blueprintPrompt`): CHAIN:2322-2323 "A finding's location is a section id and, when it applies, an item id."; 2397-2399 "A checklist item the blueprint fails is a blocking finding: its section id, and item id where one applies, as location, the item it fails and how, and in rewrite a suggestion for how to address it. Verdict "fix" if any blocking finding exists; otherwise "ok"." Nit/Already present 2415-2422; bar "Still open:" 2441-2445.
- structure `bpStructurePrompt`: CHAIN:2784 "a section that is missing or out of order, or an item a section drops, is a blocking finding"; 2791-2793 "A checklist item the page fails is a blocking finding: its location (the section heading, and the sentence when it applies), the item it fails and how, and in rewrite a suggestion for how to address it. Verdict "fix" if any blocking finding exists; otherwise "ok"."
- editor `bpEditorPrompt`: CHAIN:2815-2816 "Return ranked findings with a proposed rewrite each, and a verdict: "fix" if any finding is blocking, otherwise "ok"." (no location/blocking wording beyond this).
- fact `bpFactPrompt`: CHAIN:2841-2842 "An id that is neither is a blocking finding. A fact the blueprint places in a section that the page omits is a blocking finding."; 2846-2848 "...is a blocking finding (location, claim, what is wrong). For a cited fact that no longer matches its source, name the fact id and quote the excerpt."; 2851 option-map row "is a blocking finding, located at the option map and the row's key"; 2853-2854 "Verdict "fix" if any blocking finding exists; otherwise "ok", with the count of claims traced in summary."
- reader `bpReaderPrompt` turn 2: CHAIN:2915-2919 "...blocking when it is an unstated step or an unclassified error ... Give each its location: the section heading, and the sentence when it applies. Verdict "fix" if any blocking finding exists; otherwise "ok"."
- coherence (shared): CHAIN:2954-2958 "A finding blocks when a reader reading straight through would lose the thread; otherwise it is advisory. A finding names its location (the section heading, and the sentence when it applies), what is wrong, a rewrite that fixes it, and whether it blocks. Verdict "fix" if any blocking finding exists; otherwise "ok"."
- narrowing `bpNarrowing`: 2727 "set blocking to false and start its finding with "Already present:""; round-2 own findings rendered via shared `combined()` (2744).

**Handoff-mode answer lines (for contrast; must stay byte-identical)**: structure CHAIN:1834-1836 ("its file:line as location ... otherwise "accept""); editor 1685-1686; fact 1701-1702, 1713; reader step 3 1951-1956.

**Does the Workflow code parse findings JSON?** No `JSON.parse` of findings in CHAIN (its JSON.parse uses are elsewhere; findings come back as objects from `agent(..., { schema: READ_SCHEMA })`, CHAIN:2023-2032). The schema:
```
const FINDING = { type: "object", properties: { location, finding, rewrite, blocking: { type: "boolean" } },
  required: ["location", "finding", "blocking"] };          // CHAIN:515-524, no additionalProperties
const READ_SCHEMA = { ... verdict: { enum: ["accept", "fix"] }, findings: { items: FINDING } ... } // CHAIN:560-569
```
Consumers read only named fields: `combined()` CHAIN:1983-1988 (`f.blocking`, `f.location`, `f.finding`, `f.rewrite`); `readEntries` 2052 (`f.blocking` count); `runReads` 2037 (`r.verdict`). An extra `kind` is permitted by FINDING (no `additionalProperties: false`) and ignored by every consumer, so it would not break the Workflow path by this code. Whether the Workflow runtime itself validates strictly was not checked (outside this repo). Note: the handoff snapshots record each call's `opts` including `schema` (tests/docs-page-chain-handoff.test.mjs:180-184), so adding `kind` to FINDING changes those snapshots.

## 3. Go side: schema and decoding

Schema is per **Answer**, not per seat: internal/assemble/schema.go:19-20
```
case AnswerRead, AnswerReader2:
    return marshal(readSchema()), "Answer with a verdict, each finding with its location, the finding, a rewrite, and whether it blocks, a summary, and any friction you met in friction.", nil
```
readSchema (schema.go:80-95): finding = `obj({location, finding, rewrite, blocking})`; top = `obj({verdict enum ["ok","fix"], findings, summary, friction}, "friction")`. `obj` sets `"additionalProperties": false` and makes every property required except named optionals (schema.go:49-67; comment 12-14 "each object closes with additionalProperties false"). The contract string is appended as the last part of every request (internal/assemble/assemble.go:75, 106). Sent as structured output: internal/batch/request.go:44-50 `w.output.Format = anthropic.JSONOutputFormatParam{Schema: schema}`. AnswerRead is used by blueprint (internal/pipeline/blueprint.go:160), round-1/2 seats (steps.go:418, 558), final scoped reads (steps.go:659) and coherence; AnswerReader2 by reader turn 2 (steps.go:630). Same schema for handoff pages and blueprint pages: a schema change reaches handoff-mode requests even if handoff prompt bytes stay identical.

Decoding: internal/pipeline/steps.go:447-458 `readAnswer{Verdict; Findings []struct{Location, Finding, Rewrite, Blocking}; Summary; Friction}`; `parseRead` 460-469; `decodeAnswer` 471-482:
```
dec := json.NewDecoder(strings.NewReader(text))
dec.DisallowUnknownFields()
```
Yes: an answer carrying `kind` with no `Kind` field in readAnswer fails decode ("unknown field"). Under the current schema (additionalProperties false, no kind) structured output would not emit one. `readAnswer.findings` maps to `edits.Finding{N, Seat, Location, Text, Rewrite, Blocking}` (steps.go:484-491; internal/edits/types.go:8-15), which has no kind field either. Blueprint read results also go to `FindingResult{Location, Text, Blocking}` (internal/pipeline/pipeline.go:137-142).

## 4. Tests and goldens that pin prompt bytes or the schema

Assumed change: kind instruction added to stock review prompts and blueprint-mode review prompts; handoff mode byte-identical.

| Pin | What it pins | Changes? | Regenerate |
|---|---|---|---|
| stock/testdata/{whole,change}-{anatomy,register,neither}.txt via TestStockRenderings (stock_test.go:72-98; matrix stock/testdata/matrix.json, 6 blueprint cases) | stock blueprint seat bytes | Yes if stock `blueprintPrompt` gains it | `go test ./stock -update` (flag stock_test.go:21) |
| stock/testdata/bar-{anatomy,register}.txt via TestStockBarRenderings (148-) | stock blueprint bar reads | Yes, same | `-update` |
| stock/testdata/{draft-whole,structure-whole,editor-whole,fact-whole,reader-turn1,coherence-read}.txt via TestFixtureMatrixRenders (278-310; matrix e2e/testdata/cli/prompts-matrix.json, first case per seat) | stock seat bytes | structure/editor/fact/coherence: yes. reader-turn1: no (no findingRule). draft-whole: no. reader turn 2 has no golden | `-update` |
| TestStockSeatContent / TestStockEditTurns / TestStockRenderingContent (stock_test.go:389-453, 100-141) | substrings | No for an additive sentence; but "register" anywhere in a fixture render fails TestStockNoRegister (328) and non-register blueprint renders (130) | none |
| TestStockDenylist, TestStockDrafterTokens, check-prompts `stockNames`/`stockPaths` | banned words, `drafter:` tokens, slash tokens | Only if the kind list uses "register", a slash, "option-map", etc. | none |
| e2e TestStockCheckPromptsOnTheFixture (e2e/checkprompts_test.go:152-165) | stock check-prompts on prompts-matrix.json: "22 cases, 0 failed" | No (containment only) | none |
| cmd/drafter/testdata/read-dryrun-count.golden.json via TestReadDryRunRequestGolden (cmd/drafter/clifixture_test.go:134-170; fixture has no prompts setting so stock module) | count_tokens bodies: stock blueprint prompt AND read schema | Yes if stock blueprint seat or read schema changes | `go test ./cmd/drafter -run TestReadDryRunRequestGolden -update` (flag clifixture_test.go:19) |
| cmd/drafter/testdata/blueprint-prompt.golden.txt (cmd/drafter/read_test.go:227-255) | CHAIN blueprint seat, blueprint mode (args `{}`), unscoped | Yes if chain `blueprintPrompt` changes | no flag; hand-written file |
| internal/pipeline/testdata/blueprint-read-request.golden.json via TestBlueprintReadRequestGolden (readgolden_test.go:16-43) and draftpath_test.go:284 | whole request incl. `Schema` and contract; prompt from synthetic testdata/module.js ("Read the blueprint below.") | Prompt edits: no. Schema/contract change: yes | `go test ./internal/pipeline -run TestBlueprintReadRequestGolden -update` (readgolden_test.go:11) |
| internal/pipeline/testdata/record.golden.json (flow2_test.go:600-613) | normalized record.json | Only if record gains kind | `UPDATE_GOLDEN=1` |
| internal/assemble/schema_test.go:84-95 TestSchemaShapes | required keys of AnswerRead incl. location/finding/rewrite/blocking | Additive kind: passes; list does not include it | none |
| tests/fixtures/drafter/handoff-renders.golden.json ("handoff mode: every case equals the B3c.0 golden", tests/docs-page-chain-blueprint.test.mjs:103-108; 51 cases of tests/fixtures/drafter/matrix.json) | handoff-mode renders incl. `install-widget/blueprint`, `blueprint-scoped`, `blueprint-scoped-page` | Stays if handoff builders untouched; BUT the blueprint seat is shared (CHAIN:2967/2975), so editing `blueprintPrompt` unconditionally breaks these 3 cases. No coherence cases in this matrix | no flag; captured in a577ff2 "Record the chain's renders before blueprint mode" |
| tests/fixtures/drafter/blueprint-seat-renders.golden.json (blueprint.test.mjs:241-247; matrix blueprint-seat-baseline.matrix.json, cases blueprint/whole, blueprint/change) | chain blueprint seat, blueprint mode, empty findings | Yes if chain blueprint seat gains it | no flag |
| blueprint.test.mjs:249-262 bar test | `text.startsWith(RENDERS["blueprint/change"])` and bar sentences | Holds if the kind sentence sits before the bar paragraph consistently | none |
| tests/fixtures/drafter/blueprint-matrix.json (24 cases) via parity + "check-prompts: ... exits 0" (blueprint.test.mjs:92-101) | goja == Node, containment | No (both render the same source) | none |
| tests/drafter-prompts-parity.sh (runs both matrices, node tests/drafter-render-prompts.mjs | drafter check-prompts --expect -) | goja vs Node byte parity; no stored golden | No | none |
| tests/fixtures/docs-page-chain/default-run.*.json (handoff.test.mjs:191-205) | chain's own Workflow run: every agent call's label, prompt, opts (incl. schema) | Not by bp* prompt edits; yes if FINDING/READ_SCHEMA changes | `UPDATE_SNAPSHOTS=1` (handoff.test.mjs:5, 199) |
| tests/fixtures/docs-page-chain/*plan-prompt.markdown.golden.md | handoff plan prompts | No | (outline test) |
| e2e/testdata/prompts/{matrix,expect,module}.json/js (e2e/checkprompts_test.go) | synthetic module | No | none |
| `drafter check-prompts` (cmd/drafter/checkprompts.go:28-41) | containment of page.path, findings text, narrow.own.findings[].finding; with --expect byte equality; stock path/name checks when no --module | No golden of its own | n/a |

## 5. Finding categories each seat already names

- **blueprint** (stock prompts.js:102-147; chain 2350-2396 same text): order/pace/user goal/tasks/troubleshooting (Red Hat items 104-108); introduction vs `job`/`covers`/`outOfScope` (112-116); "each step the page's job needs that the blueprint lacks", "each failure ... that has no `failure` item" (118-121); reader state "a step whose prerequisite a reader cannot hold" (123-126); recovery: failure with no/wrong `from`, recovery before diagnosis (128-133); "each `use` that restates the fact's content" (135-138); durable fields that "narrates the planning session" (140-143); human-origin items "the blueprint would bury" (145-147). Change read names "a claim past its fact, invented output, a handler that loops or dead-ends, a state no step supplies, or a missing step" (162-163) and non-blocking "Order, pace, heading form, field placement, and a `use` that restates its fact" (166-167).
- **structure** stock: "A section that is missing or out of order, or an item a section drops" (460-461); anatomy introduction and closing section (464-466); Red Hat items incl. "Cross-references are used appropriately and only when useful" (470-475); intro vs `job`/`covers`/`outOfScope`/`framing.introPlan` (479-481). Chain bp adds `bpFramingReadLine` (2606-2608: omitted reader's reason, dropped background, departure from `introPlan`, opening on an imperative or about the page) and `structureChecklist` (1852-1858 "Module types are not mixed./used correctly.", navigation 1878-1884 "links to related resources", "links to what to learn next", "brief introduction under each heading"); hand-offs owned by blueprint, wording only (BP_HANDOFF_OWNER 2518).
- **editor** stock: rules of `drafter:google-rubric.md` and patterns of `drafter:google-tells.md`, "name the rule or the pattern by its heading" (494-497); "a finding on a heading is advisory: its fix goes in the blueprint" (502-503); "Nit:" preference (497-498). Rubric headings (stock/google-rubric.md:8-109): Address the reader as you; imperative; active voice; present tense; condition before instruction; numbered steps; sentence case and task headings; lists parallel; code in code font; descriptive link text; define abbreviations; avoid jargon; timeless documentation; conversational tone; contractions. Tells (google-tells.md:9-99): passive hiding actor; future tense; first person; instruction before condition; dating words; easy filler; polite padding; link text that says nothing; -ing heading; procedure introduced by a fragment; undefined abbreviation. Chain bp: "the drafting brief's structure checklist, its tells, and Vale's alerts together, with the Names section, logic, and facts-adjacent phrasing" (2813-2815); 26-word cap scope (CAP_SCOPE 1209); framing line (2810).
- **fact** stock (524-533): cited id not in facts block or wrong tag; sentence states more than its facts (number, version, date, path, URL, command, flag, code name); cited fact no longer matches excerpt; "no-claim" sentence with a checkable specific; page/brief sentence mismatch; `fact` item not cited in its section; cut fact on the page. Chain bp (2840-2851): fact id neither cited nor in `dispositions`; placed fact the page omits; claim with no cited fact; cited fact no longer matches its source; option-map row pending the slug.
- **reader** turn 2: stock 576-579 "mismatch between your paraphrase and that job", "an unstated step, a failure the page never explains, or a term it never defines"; chain bp 2915-2918 "an unstated step or an unclassified error".
- **coherence** (stock 634-639; chain 2945-2950): "Transitions: ... no lead-in promises what the next section no longer delivers", "Repetition: no point is made twice across sections", "Flow: ... no section relies on something only a later section explains". Chain also reads against the register drafting brief (2942-2944).

## 6. Draft seat: blueprint items, `code` items

- stock `blueprintReading()` prompts.js:268-279: "Each item is content its section carries. A `fact` item places a fact ... A `sentence` item with `mode: verbatim` appears word for word ... A `step` is a numbered step, in order. A `failure` item is a symptom with the recovery its `handledBy` names. An `example` or `code` item is a worked example, a `link` item a Markdown link to its `target`, and a `handoff` the lead-in to what the reader does next." Used by `wholeDraft` (308); `editDraft` says only "Draft as the first draft did: from the blueprint and its facts" (361-363).
- chain `bpBlueprintAsPlan()` CHAIN:2564-2576: same item sentences, incl. 2572-2573 "An `example` or `code` item is a worked example, a `link` item a Markdown link to its `target`, and a `handoff` the lead-in to what the reader does next."; used by `bpDraftPrompt` (2688) on every draft turn.
- Neither names a code item's `source` field or file. The schema gives `code` items `source` ("path, path#Symbol, or an http(s) URL. A path resolves from the page's directory and must exist", schema/blueprint.schema.json:243; decode allows it, internal/blueprint/decode.go:25). The item reaches the model only as part of the inlined blueprint YAML; no code in internal/assemble or internal/pipeline was found that inlines a code item's source file (grep for `.Source` there finds none for items).

## 7. Coverage seat (internal/coverage)

`Prompt` (internal/coverage/read.go:44-58): "Check a documentation page against its plan. Each item below must be carried by the page, in the section named." / "For each item, quote the passage of the page that carries it, copied exactly as the page has it and taken from that item's own section. If the page doesn't carry the item, give an empty quote. Answer every item, by id." Then per item `- id / section / kind / text`, then "Page:". Listed items: `handoff`, `reason`, and `sentence` with `mode: claim` (read.go:24-34); `kind()` is the item kind, or the mode for a sentence (17-22). Schema: `{items: [{id, quote}]}`, additionalProperties false (60-82); answer contract "Answer with one entry per listed item: its id and the exact quote, empty when the page does not carry it." (assemble/schema.go:26).

`Miss` (internal/coverage/check.go:14-19): `Item, Section, Kind, Reason`. From `Verify` (read.go:101-121): Kind = handoff | reason | claim; Reason "heading not found", "the coverage read found no passage for this item", or "the quoted passage is not in this section" (plus a fault naming where else the quote is). From the mechanical `Check` (check.go:33-87): Kind "brief" ("brief sentence not found on the page", Item = sentence text), "fact" ("no brief sentence in this section cites fact <id>"), "verbatim" ("verbatim sentence not found in this section"), "link" ("no link to <target> in this section"), or any of these with "heading not found".
