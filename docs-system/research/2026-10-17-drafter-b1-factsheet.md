# Blueprint pass factsheet (drafter @ d3447d9, cairn-cms main)

Paths are relative to `~/Projects/drafter` unless prefixed. Read-only survey, 2026-10-17.

## 1. Plan format v1

### Top level (`schema/plan.schema.json:8-102`, `internal/plan/plan.go:18-32`)
Required: `version`, `page`, `argument`, `introduction`, `orderReason`, `sections` (schema:8).
- `version`: `{ "const": 1 }` (schema:10); `plan.Version = 1` (plan.go:10).
- `page`: `path`, `title`, `type`, all required (schema:11-20; plan.go:35-38). `path` must be `filepath.IsLocal` (decode.go:250).
- `argument`: prose string (plan.go:21).
- `introduction`: required `covers`, `priorKnowledge`, `notCovered`; optional `facts []string` (schema:22-36; plan.go:46-50).
- `orderReason`: prose (plan.go:23).
- `preconditions []string`: "State tokens the reader holds before the first step." (schema:41).
- `sections[]` (minItems 1): `heading` (req), `level` (2|3, default 2), `anchor` (optional slug pin), `opens` (req), `items` (req; empty only for a level-2 section the next level-3 fills, decode.go:262-266) (schema:47-73; plan.go:60-66).
- `dispositions[]`: `fact`, `disposition` (`subordinated`|`cut`), `reference` (required when subordinated), `reason` (schema:76-92; plan.go:99-104).
- `constraints []string` (prose), `friction []string` (prose) (schema:93-102; plan.go:27-28).
- Every struct carries `Line int` and `Lines map[string]int` (`yaml:"-"`) for finding lines (plan.go:30-31 etc.).
- Tag `plan:"prose"` refuses a plain-style value with a line comment (plan.go:14-17). plan.go:5-6: "The struct tags are the schema's source of truth: schema/plan.schema.json must list the same fields and required sets, and a test enforces it" (`internal/plan/schema_test.go`).

### Item kinds (`internal/plan/decode.go:23-33`; schema `$defs` 104-227)
Every item: `id` (pattern `^[a-z0-9][a-z0-9_-]*$`, unique across plan, schema:227), `kind`.
| kind | required | optional |
|---|---|---|
| fact | fact | use |
| sentence | mode (`verbatim`/`claim`), text | facts |
| link | target | text |
| handoff | text | |
| reason | text | facts |
| step | text | requires, produces, canFail, optional |
| failure | symptom, handledBy | from, cause, facts |
| code | text | source, facts |
| figure | text | source |
Single flat Go `Item` struct holds all fields (plan.go:74-95). decode.go:301-305 refuses any field outside a kind's allowed set.

### Checks (`internal/plan/check.go`)
Check names (check.go:14-20): `ids`, `reader-state`, `recovery`, `links`, `facts`; plus `decode` (decode.go:20).
Order in `Check` (check.go:49-62): `c.ids(); c.readerState(); c.recovery(); c.links(); c.crossLinks(); c.facts()`. `CheckFile` (run.go:16-26) runs `Decode` then `Check` only if decode has no error.
- `Decode` (decode.go:60) + `validate` (decode.go:246) + `item` (decode.go:288): walks yaml.Node itself to catch duplicate keys; version==1, local page path, level 2/3, empty items rule, disposition enum + subordinated needs reference, id pattern, unknown kind, foreign fields, required fields, mode enum.
- `ids` (check.go:72-122): duplicate item ids; failure `from` must name a step; `handledBy` must name an item; a fact both placed by a `fact` item and disposed is an error; a facts-list id that is disposed is an error.
- `readerState` (check.go:135-180): walks steps in page order; each `requires` must be in `preconditions` or produced by an earlier non-optional step (error); produced only by optional steps -> warning.
- `recovery` (check.go:182-202): failure `from` naming a step without `canFail` -> warning; `canFail` step with no failure naming it in `from` -> error.
- `links` (check.go:204-224) via `link` (check.go:331), `codeSource` (check.go:319), `anchorPins` (check.go:246): link targets/anchors resolve (planned-outline pages warn instead of error), code `source` path exists, pinned anchor equals heading slug (github-slugger port, slug.go), subordinated `reference` resolves.
- `crossLinks` (check.go:274): warning per outline crossLink from this page with no matching link item, and per crossLink whose `to` is not in the outline.
- `facts` (check.go:393-459): no `FactsDir` -> warnings only; else each id must be on exactly one bullet (error 0 or >1), cited ids must be `Citable()` (tag verified/external/vendor). Dispositions only resolve (no citability check, check.go:456-458).
`Finding{File, Line, Severity, Check, Message, Fix}` (plan.go:116-123).

### Facts (`internal/plan/facts.go`)
- Header comment (facts.go:12-15): "follows cairn's scripts/checks/check-facts.mjs ... each leading with its id as a code span and ending with one status tag."
- Every `.md` in dir except `README.md` (facts.go:18, 72-85). Bullet = `- ` line plus following non-blank lines joined by spaces, up to next bullet/blank/`## ` (facts.go:144-146). Bullets under `## Harvest record` / `## Provenance` skipped (facts.go:28).
- id regex ``^`([^`\s]+)` `` (facts.go:21); tags `verified|docs-drift|external|vendor|candidate|rejected` (facts.go:23), exactly one, last, masking code/quoted spans (facts.go:176-178 comment). Citable: verified, external, vendor (facts.go:31).
- `Fact{ID, File, Line, Tag, Problem, Text, Sources}` (facts.go:34-49); `Text` is the claim up to `Source:` or tag; `Sources` are backticked repo paths in the Source: part (`path`, `path:100-110`, `path#name`).
- `LoadFacts(dir)` (facts.go:109) -> `*Facts{byID map[string][]Fact}`; `Get(id)` true only for exactly one bullet (facts.go:63). `CheckFactsDir` (facts.go:89).
- Docs: `docs/plan-format.md:365-381`.

### Outline (`internal/plan/outline.go`)
JSON object; reads only `pages[].path`, `pages[].slug`, top-level `crossLinks[] {from,to,why}` (outline.go:35-45); fails without a `pages` array (outline.go:49-51). `LoadOutline` (29), `LoadOutlines` merges several (71), `OutlineWithPages(files, pages)` adds the run's pages (106). Docs: plan-format.md:383-413 ("Drafter reads nothing else from the file").

## 2. CLI (`cmd/drafter/`)
Root (root.go:7-12): `cmd.AddCommand(newCheckPlanCmd(), newAnchorsCmd(), newConfigCmd(), newSpendCmd(), newCheckPromptsCmd(), newPageCmd())`.
| subcommand | file | args/flags |
|---|---|---|
| `check-plan [flags] <plan>...` | checkplan.go | `--facts dir`, `--outline file` (repeatable StringArray), `--root dir` (default git top level of first plan), `--json` (checkplan.go:38-41) |
| `anchors [flags] <file>...` | anchors.go | `--json` |
| `config` | config.go | `--json`, `--sync` |
| `spend` | spend.go | `--since`, `--until`, `--json` |
| `check-prompts` | checkprompts.go | `--module`, `--matrix` (required), `--expect`, `--json` |
| `page [flags] [handoff-file...]` | page.go | `--workflow-run`, `--resume`, `--dry-run`, `--sync`, `--json` (page.go:42-46) |
check-plan: needs >=1 arg else usage error exit 2 (checkplan.go:29-34); runs `plan.CheckFactsDir`, `plan.LoadOutlines`, `plan.GitRoot`, then `plan.CheckFile` per file (45-73). Text output `file:line: severity: check: message (fix)` (83); counts to stderr (90); exit 1 on any error finding (93-95). Exit codes main.go:12-16: 1 findings, 2 cannot run, 3 stopped. Test: checkplan_test.go.

## 3. Pipeline stage 1 and seats
- Package doc (pipeline/api.go:1-3): "the plan check, the draft, the coverage check, the review seats, the redraft, and the final reader. It owns the stop rules and the money path, and starts no goroutines."
- Steps (work.go:11-25): `plan, consistency, draft, gatefix, coverage, round1, redraft, round2, reader1, reader2, finalredraft, scoped, done`. Stage tokens s1..s7 (work.go:28-36). New pages start at `stPlan` (start.go:268).
- Stage 1 today = `doPlan` (check.go:32-81, local, no API): markdown plan skips with warning; builds `CheckOptions{Root, FactsDir: cfg.Facts.Dir}`, outline from `context.args.outline` + run's pages (`OutlineWithPages`), `plan.CheckFile`; errors -> `p.escalate("plan", "check-plan", nil, ...)`; warnings into record. Then `stConsistency` if `p.runs("consistency")` (needs facts dir, page.go:147-152) else `stDraft`.
  Then `stageConsistency` (steps.go:173-187): prompt from Go `assemble.ConsistencyPrompt(doc, p.r.facts, p.r.root)` (assemble/consistency.go:20), NOT the JS module; `p.build(ctx, s1, "consistency", assemble.AnswerConsistency, prompt, nil, nil)`; returns `&stage{page: p, name: s1, reqs: ...}`. Completed by `completeConsistency` (handle.go:272-289): empty `conflicts` -> `stDraft`; else escalate rule `plan`, seat `consistency`. Answer type `consistencyAnswer{Conflicts []{Facts, With, Conflict}}` (handle.go:172-178).
- Seat names: `config/check.go:13` `seatNames = []string{"draft", "structure", "editor", "fact", "reader", "coverage", "consistency"}` (unknown name in `seats` or `[seat.<name>]` is a load error, check.go:52-56, 96-100). `config.Seat{Agent, Model, Effort, MaxTokens, Inputs}` (config/config.go:51-57); `Config.Seats []string` and `Seat map[string]Seat` (config.go:23-24); `validateSeat` requires model/effort/max_tokens and a price entry (validate.go:53-68). Fingerprint for resume includes `seats` and each `seat.<name>.*` (pipeline/fingerprint.go:16-45).
- Prompts module (`internal/prompts/prompts.go`): goja; module returns `{seat: fn(ctx)}` (prompts.go:3-5); `Load(name, src, Host{Args, Resolved})` (49), `Seats()` (122), `Render(seat, Context)` (133) errors on unknown seat. `prompts.Context{Page, Inputs, Round, Findings, AfterFinalRead, Scope, Where, Narrow, Turn, Facts}` (context.go:49-60). Seats actually rendered through the module: draft/structure/editor/fact/reader (chain `DRAFTER_SEATS`, docs-page-chain.js:2252-2262); coverage and consistency prompts are built in Go (`coverage.Prompt`, `assemble.ConsistencyPrompt`). docs/prompts-module.md:31-32 lists all seven names.
- Request build: `p.build(ctx, stage, seat, assemble.Answer, prompt, hist, declined)` (steps.go:107) -> `assemble.Build(ctx, assemble.Input{...})` (assemble/assemble.go:63), which needs `cfg.Seat[seat]`, picks answer schema via `answerSchema(a)` (assemble/schema.go:15-28). Answers: `AnswerDraft, AnswerEdits, AnswerRead, AnswerReader1, AnswerReader2, AnswerCoverage, AnswerConsistency` (assemble.go:24-30); a new answer shape needs a new constant + schema case + `inputBlocks` case (assemble.go:107-110 skips repo inlining for coverage/consistency/reader2).
- Money path single entry: `(r *runner) submitUnit(ctx, p, name, reqs)` (money.go:89-149): "counts, reserves, records, and sends one submission unit ... a request is never sent before its reservation is in the ledger and its intent is in the state." Called only by `submit(ctx, stg *stage)` (money.go:59-74), which `loop` calls per staged stage (pipeline.go:206-266). Results return via `process` -> `p.handle(ctx, intent, results)` (money.go:518-519).
- money.go and resume.go name no seat or step: grep finds no `"consistency"`, `stPlan`, `stConsistency` in money.go/resume.go/dry.go/fingerprint.go; resume.go only calls `p.gateStep` (resume.go:351). Seat is parsed from custom_id `"%s_%s_%s_%s_%d"` (steps.go:48), `seatOf` = `parts[3]` (money.go:29-35), so a seat name must contain no `_`.
- So yes: a new read stage needs no change to money.go or resume.go. It touches: `config/check.go:13` seatNames; `work.go` new step const (+ maybe stage token); `steps.go` `advance` switch (127-161) and a `stageX` fn calling `p.build(...)` returning `&stage{...}`; `handle.go` `stepSeats` (44-76), `validate` (187-224), `complete` (226-260), optionally `noRetry` (93-100) and `isRead` (102-105, defaults true for any seat but draft/consistency); `assemble` Answer + schema; prompt via `p.render(seat, p.context(round))` (steps.go:89) if from the module, or a Go prompt builder like consistency. Escalate with `p.escalate(rule, seat, findings, detail)` (page.go:342). Dry run estimates whatever stage `advance` returns first (dry.go:15-52), so a new first read stage changes `--dry-run`'s estimate.

## 4. Handoff (`internal/handoff`)
`Handoff{Version, Project, Page{Path, Brief, Type}, Plan, Framing, Inputs, Context json.RawMessage, Checksum, File}` (handoff.go:24-43). `Inputs{Job, PageType, RegisterSections, ExemplarSources, ClaimInventory []Claim, FactIDs}` (handoff.go:46-53); `Claim{Claim, Disposition, FactID, Reason, Section}` (56-62). Checksum = sha256 of plan bytes then framing bytes (handoff.go:173-189); `ReadFiles` verifies it (65-82). `ReadWorkflowRun` (run.go:31-89) reads `.result.handoff` `{version, worktree, args, resolved, pages[{page, plan, framing, inputs}]}` and refuses resolved pages with `figure: true` or non-empty `rework` (run.go:92-115).
Origin of inputs, from chain `handoffFor` (docs-page-chain.js:2039-2068):
- `job`: `e.pageInputs.job` (page-inputs step).
- `pageType`: `e.pageInputs.pageType || e.page.pageType` (page-inputs step, outline fallback); `page.type` is mapped to concept/task-guide/reference by regex (2040-2045).
- `registerSections`: `e.registerSections` = `registerSectionsFor(p.track, "drafter")` (2203), chain config, not page inputs.
- `exemplarSources`: `e.page.exemplarSources` (the outline entry), not page inputs.
- `claimInventory`: `e.pageInputs.claimInventory`, but by then replaced by plan step's `applyPlan` inventory (2169-2171).
- `factIds`: page inputs' `factIds` unioned with plan-placed ids (2169-2170), then framing (`applyFraming`, 1403).

## 5. The docs page chain's plan read
File: `claude/.claude/workflows/docs-page-chain.js` (2292 lines); `~/.claude/workflows/docs-page-chain.js` is a symlink to it.
Prompt functions: `pageInputsPrompt` (993), `planPrompt(p, pageInputs, findings)` (1205), `framingPrompt` (1314), `structurePrompt(p, mode="page"|"plan", narrow)` (1721), the plan read being `structurePrompt(p, "plan")`. Driver: `planStep` (2145-2179), called from `chain` (2181) after page inputs and before `framingStep` (1450).
Flow (`planStep`): plan agent (`PLAN_SCHEMA`, `claude-opus-5-5` @ `high`, 581-582) -> YAML mode requires its self-reported `checkPlan` with `exit 0` else escalate (2155-2158: "the runtime cannot rerun the validator") -> `applyPlan`; undisposed fact ids escalate (2160-2163) -> plan read: `agent(structurePrompt(p, "plan"), {schema: READ_SCHEMA, model: REVIEWER})` (2164; REVIEWER default `claude-opus-5-5`, 577) -> verdict not "fix" passes -> first "fix" triggers one `replan` with findings, second "fix" escalates `"second fix verdict on the plan read"` (2173-2175).
Only ONE model read runs on the plan: the structural edit seat in plan mode. Reader-state and recovery are mechanical (check-plan), not model reads. What the plan read grades (1733-1755): order, pace, user goal (Red Hat Block 1 items "Information is presented in the most logical order and location.", "Information is provided at the right pace.", "The user goal is clear.") and Block 2's three introduction items against the outline entry's job/covers/outOfScope; in YAML mode also completeness of `step`/`failure` items: "That walk proves the plan consistent, not complete ... Return a blocking finding for each step the page's job needs that the plan lacks, and for each failure a reader following the steps could meet that has no `failure` item" (1746-1754).
Bar (1835-1837): "A checklist item the plan fails is a blocking finding ... Verdict "fix" if any blocking finding exists; otherwise "accept"."
Output schema `READ_SCHEMA` (519-528): `{verdict: accept|fix, findings: [FINDING{location, finding, rewrite?, blocking}], summary, frictionFiled?}`; required verdict, findings, summary. FINDING at 473-482.
Other schemas: `PLAN_SCHEMA` (375-391: `plan`, `claimInventory` carried|cut, `couldNotDo`, `frictionFiled`, `checkPlan{exit, output}`), `PAGE_INPUTS_SCHEMA` (423-456: job, pageType, factIds, addedFactIds, claimInventory, factsFiled, rowsReceived, rowsDisposed...), `FRAMING_SCHEMA` (396-407).

drafter#38 (OPEN, no comments), "Fix the docs page chain's plan step or the structural read's bar": "Both real-page runs (rotate-the-github-app-key, restrict-admin-access) escalated at the chain's plan read after one revision, so drafter's back half has never run on a real page. ... Records: drafter#37 body, cairn-cms#124."
drafter#37 (MERGED PR, pass 5) P5.8 record: both runs escalated with "second fix verdict on the plan read", model-caused (plan seat), drafter stages reached: none.
- Run 1 `extend/rotate-the-github-app-key`, `wf_35ab6cae-d62`, blocking plan findings 2 then 3: "plan lacked a deploy step after `wrangler versions secret put`, routed the wrong-key case only to a third key, and named recovery routes before diagnosing."
- Run 2 `restrict-admin-access`, `wf_bad3ccbd-fac`, findings 3 and 3: "a step depending on a warning visible only after deploy, failures with no step where they can happen, a migration step with no sign-in or database-name guidance, and Verify checks lacking failure items for the main traps."
- Also: `pages` was empty in both handoffs, so `drafter page --dry-run --workflow-run` exits 2 "result.handoff has no pages"; "The populated-page shape is still unexercised against a real run file."

## 6. The real plan (cairn-cms main)
`~/Projects/cairn-cms/docs/internal/briefs/extend/rotate-the-github-app-key.plan.yaml`: 857 lines (last commit e27db3793 "Bring the 11 page plans onto the plan format v1 reference"). Siblings: `.framing.md` (264 lines), `.json` brief, legacy `.plan.md`.
Top level: `version` 1, `page` (path `docs/extend/rotate-the-github-app-key.md`, title "Rotate the GitHub App key", type `task guide`), `argument` (6), `introduction` (16), `orderReason` (40), `preconditions` (61: deployed-site, app-settings-access, wrangler-access, healthz-route, workers-logs-on), `sections` (67), `dispositions` (728), `constraints` (755), `friction` (807).
9 sections: Before you begin (68), Generate a new key (167), Push the new key to the Worker (194), Verify the new key (288), Delete the old key (418), Recover from a failed key (454), Roll back to the old key (614), Generate a third key (653), See also (705).
Items by kind (100 total): fact 30, link 24, step 14, failure 12, sentence 9, handoff 7, code 3, reason 1, figure 0. 44 `use:` blocks. Dispositions 4 (3 cut, 1 subordinated).
Fact placement with `use` (plan.yaml:73-79):
```yaml
      - id: intro-two-keys
        kind: fact
        fact: "f:ixr3ny"
        use: |
          Backs the introduction's model only: an App holds more than one private key at once, a
          new key does not invalidate the old, and the App keeps signing with any key until it is
          deleted by hand. Not restated in this section.
```
Step (plan.yaml:172-177):
```yaml
      - id: s-generate
        kind: step
        text: |
          On the App's settings page on GitHub, generate a private key and download its PEM file.
        requires: [app-settings-access]
        produces: [new-key-file]
```
Framing record headings: `# Framing record: Rotate the GitHub App key`, `## Who arrives, from where, and why` (16), `## Background the page rests on` (91), `## Place in the doc set` (131), `## Intro plan` (170), `## Departures from the plan's introduction` (230).
Facts: `~/Projects/cairn-cms/docs/internal/facts/`, 5 facts files + README.md: admin.md (207 id bullets), editors.md (145), extend.md (1015), front-door.md (58), reference.md (321); README has 2 example bullets. `drafter.toml` sets `[facts] dir = "docs/internal/facts"`. Example (extend.md:680):
> - `f:ixr3ny` A GitHub App can hold more than one private key at once; generating a new key does not invalidate the old one, and the App keeps signing with whichever key a caller presents until a key is deleted by hand. Source: https://docs.github.com/en/apps/..., read 2026-09-29 (...). [external: GitHub]
A verified one (extend.md:8): "- `f:2sd4if` `createAuthGuard({ runtime })` gates ... Source: `src/lib/sveltekit/` guard plus ... [verified]".

## 7. Stage 2b part 2's 11 plans
Source: cairn `docs/STATUS.md:21-33` ("The 11 page plans exist, written in drafter's plan format v1 under `internal/briefs/extend/` and `internal/briefs/claude-code/` (ten extend pages and "Using Claude Code with cairn"), each with 0 errors from `drafter check-plan`"); plan `docs/superpowers/plans/2026-10-12-draft-docs-2b-part2-plans.md`; record `docs/superpowers/research/2026-10-12-2b-part2-plans-record.md`; file list from commit e27db3793.
| plan (under docs/internal/briefs/) | page | lines | .framing.md | .plan.md | outline figure | figure items |
|---|---|---|---|---|---|---|
| claude-code/using-claude-code-with-cairn | docs/claude-code/using-claude-code-with-cairn.md | 656 | no | no | false | 0 |
| extend/add-a-custom-admin-screen | docs/extend/... | 1749 | yes | yes | true | 1 |
| extend/add-a-second-sign-in-group | | 1944 | yes | yes | false | 0 |
| extend/add-cairn-to-a-sveltekit-app | | 2617 | yes | yes | false | 0 |
| extend/architecture | | 1038 | yes | yes | true | 1 |
| extend/debug-your-site | | 1125 | no | yes | false | 0 |
| extend/replace-magic-links-with-cloudflare-access | | 1317 | yes | yes | true | 1 |
| extend/restrict-admin-access | | 1270 | no | yes | false | 0 |
| extend/rotate-the-github-app-key | | 857 | yes | yes | false | 0 |
| extend/scaffolded-site-files | | 1299 | yes | yes | false | 0 |
| extend/security-model | | 1566 | yes | yes | false | 0 |
All 11 have `.plan.yaml`; 8 have `.framing.md`. All 10 extend pages also have `.json` briefs. Outlines: `docs/internal/outlines/claude-code.json` (keys arm, crossLinks, pages, track) and `extend.json` (keys arm, crossLinks, generatedFrom, groups, index, kept, pages, rearms, redirects, terms, track; page keys absorbs, batch, covers, exemplars, factIds, factSections, figure, figureNote, group, job, order, outOfScope, pageType, path, pinned, rearms, slug, title). Outline pageTypes: architecture/scaffolded-site-files/security-model `concept`; add-cairn-to-a-sveltekit-app `tutorial milestone`; debug-your-site `symptom row`; rest `task guide`. Note `handoff.ReadWorkflowRun` refuses `figure: true` pages (run.go:107-108), i.e. 3 of the 11.

## 8. Gate
`make check` = `vet lint test chain-test prompts-parity install-test` (Makefile:48). vet: `go vet ./...` and `go vet -tags smoke ./...`; lint: `golangci-lint run ./...`; test: `go test ./...`; chain-test: three `node tests/docs-page-chain-*.test.mjs` (comment: they "read the agent definitions from a workstation checkout (WORKSTATION_DIR)"); prompts-parity: build then `DRAFTER_BIN=./drafter bash tests/drafter-prompts-parity.sh` (Node vs goja byte parity); install-test: `bash tests/install.test.sh`. `make smoke` (live API, spends money) is outside check.
`scripts/drafter-gate.sh`: runs `cairn-run-gate --fresh "make -C '$dir' check"` with `CAIRN_GATE_LANE=light`, `DRAFTER_DIR` default this checkout; repeats the `gate exit:` line; exit code is cairn-run-gate's (75 = re-issue).
CI: none (`.github/` does not exist).
Go: `go 1.27.2` (go.mod:3), module `github.com/glw907/drafter`. `.golangci.yml` v2: default none; enabled errcheck (check-type-assertions), govet, ineffassign, staticcheck, unused, modernize, misspell, unparam; formatters gofmt, goimports.

## 9. Pipeline spec (`~/Projects/initiatives/docs-system/specs/2026-10-12-drafter-pipeline-design.md`, 914 lines)
Stage 1 (372-375): "Plan check. `check-plan` runs on the page's plan. When the project has a facts store, one batched consistency read then checks the placed fact bullets against each other and against the headings of every linked page. A `check-plan` error or a consistency finding escalates to the planning session before any drafting spend." Stop-rule row (396): "| Plan check | A `check-plan` error or a consistency finding | none | escalate: `plan` |".
Pilot (867-886), verbatim criteria: "Cutover needs all four:
1. Geoff accepts every page drafter accepted, after ordinary fixes, in the pass's PR, and the pilot meets the acceptance floor Owner ruling 1 sets. A blind grader reads each accepted page against the register as a second opinion.
2. Every escalated record has an empty `faults` list. The planning session writes one cause per escalation into the pass record (a plan gap, a fact conflict, or a missing fact), citing the record's escalation findings, and Geoff confirms them in the PR.
3. Accepted pages average $5 or less in ledger cost, no record ends with `cap`, and no page's ledger total exceeds $10.
4. `drafter spend` over the pilot's UTC dates matches the Console's cost for drafter's workspace over the same dates within 5%, and the key tests above pass.
The pilot covers at least five pages, including two task guides and one concept page." Also: runs in `batch` mode on the chain's Workflow run file, every pilot page on a YAML plan.
Seats/models: the spec has no seats table; "### Models" (792-796) is prose: "cairn's `drafter.toml` runs every seat on `claude-opus-5-5`: the drafter and redrafts at high effort, the review seats at medium, the coverage and consistency reads at low. cairn changes a seat's model only on pilot evidence." Settings table row (224): "`seat.<name>`: agent definition, model, effort, `max_tokens`, inputs | project, local | none; required for each seat that runs". Actual `~/Projects/cairn-cms/drafter.toml`:
| seat | model | effort | max_tokens | inputs |
|---|---|---|---|---|
| draft | claude-opus-5-5 | high | 64000 | |
| structure | claude-opus-5-5 | medium | 32000 | baseline diff |
| editor | claude-opus-5-5 | medium | 32000 | vale, baseline diff |
| fact | claude-opus-5-5 | medium | 32000 | option-map grep, baseline diff |
| reader | claude-opus-5-5 | medium | 32000 | |
| coverage | claude-opus-5-5 | low | 32000 | |
| consistency | claude-opus-5-5 | low | 32000 | |
Chain-side defaults for comparison: plan step opus-5-5 @ high, framing opus-5-5 @ xhigh, reviewer (plan read) opus-5-5, effort unset (docs-page-chain.js:574-585).

## 10. drafter `docs/`
- `docs/plan-format.md` (444): the `.plan.yaml` format, fields, item kinds, what `check-plan` checks, facts-file and outline formats, `anchors`, output and exit codes.
- `docs/configuration.md` (326): three TOML layers + env + flags, refusals, every setting (incl. `seat.<name>.*`).
- `docs/handoff.md` (124): the handoff file, inputs, checksum, the planner's Workflow run file, what drafter refuses.
- `docs/prompts-module.md` (105): the JS prompts module, seat names, loader, context object.
- `docs/setup.md` (117): API key source, workspace, spend limits before a first run.
- `README.md` (134): overview. `internal/plan/docs_test.go` and `internal/config/docs_test.go` tie docs to code (presumably field/setting lists; not read).
