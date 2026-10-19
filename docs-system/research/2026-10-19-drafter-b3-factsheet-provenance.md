# Factsheet: cairn-cms check-provenance.mjs (read 2026-10-19 at cairn main)

Script: ~/Projects/cairn-cms/scripts/checks/check-provenance.mjs (926 lines); helpers in check-facts.mjs (facts:N).

## Files
- Briefs at docs/internal/briefs/<track>/<page>.json (:1-3, :106-109); schema `{page, sentences:[{text,id}], cuts?, local?}` (:5-6, :696). Page read from `join(root, page)` (:716). Brief basename must equal page basename (:713-715).
- Default mode walks briefs dir (:611-625); single-brief mode takes args under the briefs dir (:635-662).
- Facts: every *.md in facts dir except README (facts:765-770); bullets via extractBullets (facts:200); skips `harvest record` and `provenance` sections (:374); id is leading code span `/^`(f:[0-9a-z]{6})`/` (facts:147); collects `Key phrase: "..."` (facts:543).

## Rules (all defects, no warnings; each prefixed `<brief rel>: `)
- Shape: invalid JSON, not object, missing `page`, missing `sentences`, filename mismatch, page missing (:681-726).
- Classification (:519-551): empty text; id not string/array -> unclassified; string id neither `no-claim` nor `^f:[0-9a-z]{6}$`; `no-claim` only as bare string; no-claim sentence that states an extractable fact -> `marked no-claim but states the <kind> "<value>"` (:545).
- Cited ids (:470-509): empty array; malformed element (incl. no-claim in array); id not in store -> `<id> resolves to no fact in the container` (:491); tag unparsed (:495); uncitable tags candidate, rejected, docs-drift (:127-131); citable: verified, external, vendor. Each extracted token must be contained in at least one cited bullet -> `the <kind> "<value>" is in no cited fact (...)` (:505).
- Extraction (:243-285, containment :325-352): code spans (date/version/numeral, --flag, command by COMMAND_HEADS :134-137 [cairn list incl. cairn, wrangler, go, git, make, vale...], URL, @scope/pkg, path, identifier name); prose URLs, paths, npm-style commands, flags, dates, versions, numerals; key phrases. Numerals/versions match the claim text only; others the whole bullet. Stated limits :75-89.
- Page coverage (:579-603, pageProse :560-569): strip front matter, fences, HTML comments, details/summary, images, headings; collapse whitespace; no emphasis or link stripping. Brief text must be a literal substring; longest first; consumed. Missing -> `"<preview>" is not on the page`; leftover fragments with alphanumerics -> `unclassified page text: "<preview>"` (:600).
- cuts (:399-421) optional shape check; local (:430-447) per-page exemption of path/name tokens, with a cairn-only engine-export rule; rebuilt-list coverage (default mode only, cairn-only).

## Output
- Clean: stdout `check-provenance: OK` + per-brief `N sentences (cited X, no-claim Y)`, exit 0. Defects: stderr `check-provenance: N defect(s)` + indented lines, exit 1. Exit 2 only for `--extract` misuse.

## Cairn-specific vs general
- Cairn-only: paths, briefs-rebuilt.json, api-surface.md / local engine-export rule, COMMAND_HEADS contents, PATH_EXTENSIONS, owner-brief key-phrase tier, basename convention, `f:`+6 base36 id grammar (drafter's store regex is looser: internal/plan/facts.go:23).
- General: deny-by-default classification, two-way page/brief coverage, id resolution, tag citability, token extraction and containment, no-claim rule, cuts shape, output/exit shape.

## Overlap with drafter
- Brief type internal/coverage/brief.go:14-51 keeps only `sentences`; `IDs` drops no-claim (:24-51), so no-claim and empty lists are indistinguishable and malformed ids pass.
- `Normalize` normalize.go:200-208 strips `*`, `_`, backtick and collapses whitespace (looser than cairn's literal match).
- coverage.Check check.go:93-147 (run-time, steps.go:258): brief sentence on page (:105-120), plan fact item cited by a sentence in its section (:134-135), verbatim and link items (:136-139).
- gate.go never reads a brief; it checks blueprint, VerifyFacts on cited facts (:121-137), page links, Vale; output `file:line: severity: check: message (fix)` (:88), exit 0/1/2.
- Brief path for blueprint handoffs: `<blueprint minus .blueprint.yaml>.brief.json` (cmd/drafter/read.go:393). Citable tags in drafter: internal/plan/facts.go:32, :52.
- New for the gate: unclassified page text; classification rules; id resolves; tag citable; token containment and no-claim rule; optional cuts/local. Port decisions: normalization (literal vs Normalize), id shape, severity (cairn has none below error), page line numbers for defects.
