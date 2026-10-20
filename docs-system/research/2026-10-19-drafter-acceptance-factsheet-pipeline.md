# drafter pipeline factsheet (main at 8ee513a, read-only)

Paths are relative to /var/home/glw907/Projects/drafter unless absolute. The spec for this pass already exists:
`~/Projects/initiatives/docs-system/specs/2026-10-19-drafter-acceptance-design.md` ("What it builds", items 3, 5, 6). Its item 3 says the
small-kind rule "applies at the round-2 verdict and at the coverage check's second miss (`afterCoverage`) ... the reader and
coherence retests keep their rules."

## 1. Escalations

`escalate` itself, internal/pipeline/page.go:403-410:
```go
func (p *page) escalate(rule, seat string, findings []int, detail string) error {
	p.w.Rec.Escalation = &escalation{Rule: rule, Seat: seat, Findings: findings, Detail: detail}
	if findings == nil {
		p.w.Rec.Escalation.Findings = []int{}
	}
	p.leftUnresolved()
	return p.finalize(StatusEscalated)
}
```
- Record shape, internal/pipeline/record.go:88-93: `escalation{Rule json:"rule"; Seat json:"seat"; Findings []int json:"findings"; Detail string json:"detail,omitempty"}`.
- `leftUnresolved` (page.go:416-430) writes a fault `"blocking finding %d (%s) ended with no resolution"` for each blocking `p.w.Ex.Findings` entry with no resolution.
- `finalize` (page.go:289-329) sets `Status`, `Step = stDone`, saves `final.*` copies, calls `p.restore()` for an escalated page (puts page and brief back), sets `Restored`, writes `record.json`.
- Summary carries it: pipeline.go:260 `res.Rule, res.Detail = p.w.Rec.Escalation.Rule, p.w.Rec.Escalation.Detail`.

Every `p.escalate(` call (rule, seat, where):

| file:line | rule | seat | step / function |
|---|---|---|---|
| steps.go:349 | `second fix verdict` | `coverage` | `afterCoverage`, phase `covRedraft`, misses > 0 |
| steps.go:355 | `coherence` | `coverage` | `afterCoverage`, phase `covCoherence` |
| steps.go:362 | `fix after the reader redraft` | `coverage` | `afterCoverage`, default phase (`covFinal`) |
| steps.go:593 | `second fix verdict` | the round-2 seat | `afterRound2` |
| steps.go:680 | `fix after the reader redraft` | `editor`/`fact` | `afterScoped` |
| handle.go:373 | `fix after the reader redraft` | `reader` | `completeReader`, retest fix |
| handle.go:413 | `coherence` | `coherence` | `completeCoherence`, retest fix |
| handle.go:145, :156 | `api error` | rq.Seat | `take` (resubmit budget / default) |
| handle.go:152 | `refusal` | rq.Seat | `take` |
| handle.go:168 | `unreadable <seat>` | seat | `answerFailure` |
| handle.go:306 | `plan` | `consistency` | `completeConsistency` |
| handle.go:465 | `contract` | `draft` | `refused` (edit-contract budget) |
| check.go:73 | `plan` | `check-plan` | `doPlan` |
| check.go:209 | `red gate` | `gate` | `redGate`, kind exDraft over `retries.gate_fix` |
| check.go:215 | `contract` | `gate` | `redGate`, other kinds over `retries.edit_contract` |
| blueprint.go:116 | `plan` | `check` | blueprint check |
| blueprint.go:265 | `plan` | `consistency` | blueprint read consistency |
| blueprint.go:281 | `plan` | `blueprint` | blueprint read returned fix |
| money.go:123 | `cap` | `""` | page cap |
| money.go:162, :410 | `api error` | `""` | count / send failure |

`afterCoverage`, steps.go:335-368:
```go
func (p *page) afterCoverage() error {
	cov := p.w.Cov
	switch cov.Phase {
	case covInitial:
		p.w.CovFindings = nil
		for _, m := range cov.Misses {
			p.w.CovFindings = append(p.w.CovFindings, missFinding(m))
		}
		p.w.Got = nil
		p.ps.Step = stRound1
		return nil
	case covRedraft:
		if len(cov.Misses) > 0 {
			return p.escalate("second fix verdict", "coverage", nil, missSummary(cov.Misses))
		}
		p.w.Got = nil
		p.ps.Step = stRound2
	case covCoherence:
		if len(cov.Misses) > 0 {
			return p.escalate("coherence", "coverage", nil, missSummary(cov.Misses))
		}
		p.w.CoherenceRetest = true
		p.w.Got = nil
		p.ps.Step = stCoherence
	default:
		if len(cov.Misses) > 0 {
			return p.escalate("fix after the reader redraft", "coverage", nil, missSummary(cov.Misses))
		}
		p.w.Got = nil
		p.ps.Step = stScoped
	}
	return nil
}
```
Note: the coverage escalation at :349 passes `findings nil` (no finding numbers) and does not call `p.w.Rec.findings` for the misses.

`afterRound2`, steps.go:581-599:
```go
func (p *page) afterRound2(seats []string) error {
	for _, seat := range seats {
		a, err := parseRead(p.w.Got[seat])
		if err != nil {
			return err
		}
		if a.Verdict == "fix" {
			var ns []int
			for i := range a.Findings {
				ns = append(ns, i+1)
			}
			p.w.Rec.findings(s6, a.findings(seat, 0))
			return p.escalate("second fix verdict", seat, ns, "")
		}
	}
	p.w.Got = nil
	p.ps.Step = stReader1
	return nil
}
```
It escalates on the FIRST seat (in `reviewSeats` order structure, editor, fact) that says fix; later seats' fixes are not inspected. Called from handle.go:263 (`p.afterRound2(p.round2Seats())`) and steps.go:545.

- ok at round 2 -> `stReader1` (steps.go:597).
- ok (no misses) at `covRedraft` -> `stRound2` (steps.go:351-352).

## 2. Exchange -> gate -> coverage

All exchange answers land in `completeExchange` (handle.go:421-454), which applies edits and ends with `return p.gateStep(ctx, ex.Kind)` (handle.go:453). The draft lands in `completeDraft` -> `p.gateStep(ctx, exDraft)` (handle.go:321).

`gateStep` / `gateStepOnce`, check.go:86-113:
```go
func (p *page) gateStep(ctx context.Context, kind string) error {
	err := p.gateStepOnce(ctx, kind)
	if err == nil && p.r.stop == "" {
		p.w.PendingGate = ""
	}
	return err
}

func (p *page) gateStepOnce(ctx context.Context, kind string) error {
	if err := p.indexLink(ctx); err != nil {
		return err
	}
	res, own, foreign, err := p.runGate(ctx)
	if err != nil || p.r.stop != "" {
		return err
	}
	switch {
	case res.Green:
		p.toCoverage(coveragePhase(kind))
		p.w.Held = nil
	case foreign:
		p.w.Held = &held{Kind: kind, OnGreen: coveragePhase(kind)}
		p.ps.Status = StatusHeld
	default:
		return p.redGate(kind, own)
	}
	return nil
}
```
Kind -> coverage phase (check.go:117-127) and -> step (check.go:130-142), stage token (steps.go:223-233):

| exchange kind | `coveragePhase` | `exchangeStep` | `exchangeStage` | afterCoverage goes to |
|---|---|---|---|---|
| `exDraft` "draft" (gate-fix after the draft; step `stGateFix`) | covInitial (default) | stGateFix (default) | s2 (default) | stRound1 |
| `exRedraft` | covRedraft | stRedraft | s5 | stRound2 or escalate `second fix verdict` |
| `exFinal` | covFinal | stFinalRedraft | s7 | stScoped or escalate `fix after the reader redraft` |
| `exSection` | covInitial (default) | stSection | s2 (default) | stRound1 |
| `exCoherence` | covCoherence | stCoherenceFix | s8 | stCoherence (retest) or escalate `coherence` |

There is no `exGateFix` constant: the gate-fix conversation is kind `exDraft`, step `stGateFix`. Every helper's `default` falls to the draft path (covInitial / stGateFix / s2), so a new kind not added to all four switches silently behaves as a draft gate-fix.

`toCoverage`, steps.go:329-333: `p.w.Cov = coverageState{Phase: phase}; p.w.Got = nil; p.ps.Step = stCoverage`. `doCoverage` (steps.go:274-306) runs `coverage.Check` (mechanical) then, if `!cov.ReadIn && p.runs("coverage") && hasReadItems(doc)`, sends a model coverage read (seat `coverage`, stage `coverageStage(phase)`: covRedraft s5, covFinal s7, covCoherence s8, else s3). So "the coverage check" includes an API read whenever the plan has `handoff`, `reason`, or `claim` items (check.go:20-29). Handoff misses only come from that read.

Gate-fix budget, `redGate` check.go:206-232:
```go
	if kind == exDraft {
		if p.w.spend("s2.gatefix") > p.r.cfg.Retries.GateFix {
			return p.escalate("red gate", "gate", nil, strings.Join(p.w.Rec.GateExcerpts, "\n"))
		}
		if p.w.Ex == nil {
			p.w.Ex = &exchange{Kind: exDraft, History: p.w.DraftHist}
		}
	} else if p.w.spend(kind+".contract") > p.r.cfg.Retries.EditContract {
		return p.escalate("contract", "gate", nil, "the gate stayed red after the edits applied")
	}
```
then appends gate findings (seat `gate`), sets `ex.GateFix = true`, writes `ex.Turn`, `p.ps.Step = exchangeStep(kind)`. Defaults `retries.gate_fix = 2`, `retries.edit_contract = 2` (docs/configuration.md:212-213). The `kind+".contract"` row is shared with `refused` (handle.go:464), so a new kind gets its own budget row automatically.

Foreign classification, internal/gate/run.go:236-252:
```go
func (r Result) ForPage(page, brief string) (own []Section, foreign bool) {
	if r.Green {
		return nil, false
	}
	if r.Unparsed {
		return []Section{{Lines: r.Tail, Failing: r.Tail}}, false
	}
	for _, s := range r.Sections {
		for _, line := range s.Failing {
			if namesPath(line, page) || namesPath(line, brief) {
				own = append(own, s)
				break
			}
		}
	}
	return own, len(own) == 0
}
```
- A section is "own" when ANY failing line names this page or brief anywhere in the line (path-boundary match, `namesPath` run.go:254-270). A line about a sibling that also names this page (e.g. as a link target) makes the whole section own; and an own section's excerpt (first 20 failing lines, check.go:176-185) carries the sibling's lines into the fix turn too.
- An unparsed red log is never foreign (run.go:240-241).
- Called from `runGate` check.go:165: `own, foreign = res.ForPage(p.h.Page.Path, p.h.Page.Brief)`.

How the run knows its siblings (for #23): `p.r.o.Handoffs` (each `h.Page.Path`, `h.Page.Brief`), already walked at check.go:50-53 in `doPlan`; and `p.r.pages` (pipeline.go:428). Nothing in `runGate`/`ForPage` consults them today.

Hold path: `gateStepOnce` sets `p.w.Held = &held{Kind: kind, OnGreen: coveragePhase(kind)}` and `p.ps.Status = StatusHeld` (`"held"`, pipeline.go:36). No escalation rule and no record finding; the page simply waits. `held` struct, work.go:90-93 (`Kind json:"kind"`, `OnGreen json:"on_green"`). Release, `releaseHeld` pipeline.go:426-457: once no page is running or pending, `p.regate(ctx)` for each held page; if none progressed, `r.halt(StopTreeRed)` (`"tree red outside drafter's pages"`, pipeline.go:27). `regate` check.go:235-260: green -> `Status = StatusRunning; Held = nil; toCoverage(h.OnGreen)`; still foreign -> stays held; own red -> `redGate(h.Kind, own)`.

Existing tests: `TestHeldPageSpendsNoFixTurn` (flow2_test.go:362) and `TestForeignRedThatPersistsStopsTheRun` (flow2_test.go:388).

## 3. Structs, kinds, misses

`edits.Finding`, internal/edits/types.go:8-15 (no json tags; persisted in work state with Go field names as keys):
```go
type Finding struct {
	N        int
	Seat     string
	Location string
	Text     string
	Rewrite  string
	Blocking bool
}
```
`edits.Render` (render.go:29-45) prints `Finding %d (%s, blocking|advisory)`, Location, Text, Rewrite. A new field is not rendered unless added there.

work.go structs:
```go
type exchange struct {                                   // work.go:61-70
	Kind        string             `json:"kind"`
	History     []batch.Message    `json:"history,omitempty"`
	Findings    []edits.Finding    `json:"findings,omitempty"`
	Resolutions []edits.Resolution `json:"resolutions,omitempty"`
	Turn        string             `json:"turn"`
	GateFix bool `json:"gate_fix,omitempty"`
}
type coverageState struct {                              // work.go:74-79
	Phase    string       `json:"phase"`
	MechDone bool         `json:"mech_done,omitempty"`
	Misses   []missRecord `json:"misses,omitempty"`
	ReadIn   bool         `json:"read_in,omitempty"`
}
type missRecord struct {                                 // work.go:82-87
	Item    string `json:"item"`
	Section string `json:"section"`
	Kind    string `json:"kind"`
	Reason  string `json:"reason"`
}
```
The record's finding copy is `findingRecord` (record.go:144-150 copies Stage, Seat, N, Location, Text, Blocking); `internal/pipeline/testdata/record.golden.json` pins the record (TestRecordGolden, flow2_test.go:589).

Blueprint item kinds, internal/blueprint/decode.go:16-27, verbatim:
```go
var kinds = map[string]struct{ required, optional []string }{
	"fact":     {required: []string{"fact"}, optional: []string{"use"}},
	"sentence": {required: []string{"mode", "text"}, optional: []string{"facts"}},
	"example":  {required: []string{"text"}, optional: []string{"facts"}},
	"link":     {required: []string{"target"}, optional: []string{"text"}},
	"handoff":  {required: []string{"text"}},
	"reason":   {required: []string{"text"}, optional: []string{"facts"}},
	"step":     {required: []string{"text"}, optional: []string{"requires", "produces", "canFail", "optional"}},
	"failure":  {required: []string{"symptom", "handledBy"}, optional: []string{"from", "cause", "facts"}},
	"code":     {required: []string{"text"}, optional: []string{"source", "facts"}},
	"figure":   {required: []string{"text"}, optional: []string{"source"}},
}
```
There is no "heading" or "citation" item kind. The view also adds framing items `ID: "_framing-"+name, Kind: "example"` (blueprint/view.go:62).

Coverage miss kinds. `coverage.Miss` doc, coverage/check.go:11-19: "Kind is the item's kind, its mode for a sentence, or "brief" for a brief sentence; Section is the plan section's heading, empty for a brief sentence."

Mechanical (`coverage.Check`, check.go:34-88; `checked` :91-101 covers fact, link, verbatim only):
| Kind | Reason (verbatim) | where |
|---|---|---|
| `brief` | `brief sentence not found on the page` (Item = the sentence text, Section "") | check.go:59 |
| any checked kind | `heading not found` (`reasonNoHeading`, check.go:21) | check.go:74 |
| `fact` | `no brief sentence in this section cites fact <id>` | check.go:76 |
| `verbatim` | `verbatim sentence not found in this section` | check.go:78 |
| `link` | `no link to <target> in this section` | check.go:80 |

Model read (`coverage.Verify`, coverage/read.go:88-113; kind via `listed.kind()` read.go:17-22, mode for a sentence) over `handoff`, `reason`, `claim` items:
| Reason (verbatim) | line |
|---|---|
| `heading not found` | read.go:107 |
| `the coverage read found no passage for this item` | read.go:109 |
| `the quoted passage is not in this section` | read.go:113 |

So a "heading" miss is any kind with Reason `heading not found`; a "brief citation" miss is Kind `brief` (sentence absent) or Kind `fact` with the "no brief sentence ... cites" reason.

`missFinding`, steps.go:370-380 (Section "" -> Location "the brief"; kind goes into Text only):
```go
	loc := m.Section
	if loc == "" {
		loc = "the brief"
	}
	return edits.Finding{
		Seat: "coverage", Location: loc, Blocking: true,
		Text:    fmt.Sprintf("plan item %s (%s) is not carried: %s", m.Item, m.Kind, m.Reason),
		Rewrite: "Add what the plan item asks for in the section named.",
	}
```
`missSummary` (steps.go:382-388): `m.Item + ": " + m.Reason` joined by `"; "`.

## 4. Read answer and its schema

`readAnswer` steps.go:448-458; `parseRead` :460-469; `decodeAnswer` :472-482 (`dec.DisallowUnknownFields()`, then `dec.More()` -> "data after the JSON value"). `findings()` :484-491 maps each to `edits.Finding{N, Seat, Location, Text: f.Finding, Rewrite, Blocking}`. A `kind` key in an answer today fails decoding -> `answerFailure` -> `unreadable <seat>` (round 2 has no retry, handle.go:100-106).

Schema: internal/assemble/schema.go:80-95 `readSchema()`; finding object = `obj(map{location, finding, rewrite, blocking})` with all four required. `obj` (schema.go:50-68) always emits `"additionalProperties": false`, and `obj(props, optional...)` makes named props optional. `answerSchema` (schema.go:15-31) uses `readSchema()` for BOTH `AnswerRead` and `AnswerReader2`, with contract text "Answer with a verdict, each finding with its location, the finding, a rewrite, and whether it blocks, a summary, and any friction you met in friction." (schema.go:20).

It is sent as structured output: `Build` puts it in `batch.Request.Schema` (assemble.go:118); internal/batch/request.go:44-50 sets `w.output.Format = anthropic.JSONOutputFormatParam{Schema: schema}` (OutputConfig). So the API itself forbids extra properties.

`AnswerRead` users: review seats round 1/2 (steps.go:418, :558), scoped reads (:659), coherence (:707), and the stage-1 BLUEPRINT read (internal/pipeline/blueprint.go:160 `assemble.Input{Answer: assemble.AnswerRead, ...}`). Reader turn 2 uses AnswerReader2 (same schema).

What an optional per-finding `kind` touches:
- `readAnswer.Findings` struct (steps.go:450-455) and `findings()` (:484-491); `edits.Finding` (types.go:8); optionally `findingRecord`/record.go:144 (moves record.golden.json).
- `readSchema()` finding object, and the contract sentence (schema.go:20).
- Schema tests: `TestSchemaShapes` row `{AnswerRead, ...}` (internal/assemble/schema_test.go:91); `TestSchemasKeepToStructuredOutputLimits` (:63-82, at most 24 optional params, every object additionalProperties false).
- Request-byte goldens that include the read schema (both hold `additionalProperties`): `internal/pipeline/testdata/blueprint-read-request.golden.json` (pinned by `TestBlueprintReadRequestGolden` internal/pipeline/readgolden_test.go:15 and `TestDraftRunKeepsTheBlueprintReadGolden` draftpath_test.go:267) and `cmd/drafter/testdata/read-dryrun-count.golden.json` (`TestReadDryRunRequestGolden` cmd/drafter/clifixture_test.go:131-168). Both comments say the golden "was captured before the drafting pass ... so the read's bytes stay what they were". Changing `readSchema()` moves both, because the blueprint read shares AnswerRead; a separate Answer value (or schema variant) for the review seats would leave them untouched.
- Prompt text: stock/prompts.js `findingRule()` (stock/prompts.js:388-392) is where a read is told what a finding holds; the chain module (claude/.claude/workflows/docs-page-chain.js) is checked by `make prompts-parity` against Node renderings (tests/fixtures/drafter/matrix.json, blueprint-matrix.json).
- fingerprint.go hashes no schema (fingerprint.go:16-45: mode, seats, retries, gate.*, facts.*, inline_files, prices, and per seat model, effort, max_tokens, inputs, agent-present). money.go reads only `q.Model`, token count and `q.MaxTokens` (money.go:93-101). A schema change can avoid both files.

## 5. work state, steps, resume

`work` struct, work.go:97-166 (json tags):
`Got map[string]string "got,omitempty"`; `Ex *exchange "ex,omitempty"`; `Cov coverageState "cov"`; `Held *held "held,omitempty"`; `Baseline string "baseline,omitempty"`; `Round1 map[string]string "round1,omitempty"`; `CovFindings []edits.Finding "cov_findings,omitempty"`; `Reader readerState "reader"`; `Cited string "cited,omitempty"`; `Budgets map[string]int "budgets,omitempty"`; `Gates int "gates"`; `IndexPre map[string]*string "index_pre,omitempty"`; `IndexPost map[string]string "index_post,omitempty"`; `Rec record "rec"`; `PendingGate string "pending_gate,omitempty"`; `Sent map[string][]batch.Message "sent,omitempty"`; `DraftHist []batch.Message "draft_hist,omitempty"`; `Accepted string "accepted,omitempty"`; `Since string "since,omitempty"`; `Scope *blueprint.Scope "scope,omitempty"`; `Change string "change,omitempty"`; `Demoted int "demoted,omitempty"`; `Draft bool "draft,omitempty"`; `SkipRead bool "skip_read,omitempty"`; `Section bool "section,omitempty"`; `CoherenceRetest bool "coherence_retest,omitempty"`; `WholeBlocked bool "whole_blocked,omitempty"`; `Bar string "bar,omitempty"`; `BarFrom string "bar_from,omitempty"`; `ReadScope *blueprint.Scope "read_scope,omitempty"`; `ReadChange string "read_change,omitempty"`.

Step constants, work.go:12-33: `stPlan "plan"`, `stBpCheck "bpcheck"`, `stBpRead "bpread"`, `stConsistency "consistency"`, `stDraft "draft"`, `stGateFix "gatefix"`, `stCoverage "coverage"`, `stRound1 "round1"`, `stRedraft "redraft"`, `stRound2 "round2"`, `stReader1 "reader1"`, `stReader2 "reader2"`, `stFinalRedraft "finalredraft"`, `stScoped "scoped"`, `stDone "done"`, `stSection "section"`, `stCoherence "coherence"`, `stCoherenceFix "coherencefix"`.
Stage tokens, work.go:36-45: `s1`..`s8`.
Exchange kinds, work.go:51-57: `exDraft "draft"`, `exRedraft "redraft"`, `exFinal "final"`, `exSection "section"`, `exCoherence "coherence"`.

resume.go does NOT switch on step names or exchange kinds. It unmarshals `ps.Work` into `work` (resume.go:171-176) and, in `recoverPage`, replays a pending gate by kind (resume.go:349-358):
```go
	if p.w.PendingGate != "" && p.ps.Open() == nil {
		// The write that opened this gate came from the last intent's answer.
		if err := p.gateStep(ctx, p.w.PendingGate); err != nil {
```
which goes through `coveragePhase`, so a new kind must be in `coveragePhase`. `checkConfig` (resume.go:190-217) compares `fingerprint` only.

The step/kind switches a new step or exchange kind must join (none in resume.go):
- `advance` steps.go:148-175 (exchange steps at :159 `case stGateFix, stRedraft, stFinalRedraft, stSection, stCoherenceFix:`; unknown step is an error :174).
- `stepSeats` handle.go:44-81 (:55), `noRetry` handle.go:100-106, `validate` handle.go:194-236 (:217), `complete` handle.go:240-279 (:253; unknown step is an error :278).
- `exchangeStage` steps.go:223-233, `coveragePhase` check.go:117-127, `exchangeStep` check.go:130-142, `coverageStage` steps.go:308-318, `afterCoverage` steps.go:335-368, `stageExchange` round selection steps.go:245-250, `bound` blueprint.go:375-395 (`case exSection, exRedraft, exFinal`).
- A custom_id stage token is parsed by `seatOf` (money.go:29-35, index 3 = seat) and the fake API `stageSeat` (fake_test.go:102-108); a new token is just a string.
- Old states: fields with omitempty decode as zero; `exchangeStep`'s defaults mean an old state never names an unknown kind.

## 6. #25: scoped accept and the lock

Help text, cmd/drafter/read.go:51-57: "--since <rev> reads the change since that revision. A page with no change is not read. ... A change read writes no drafted.lock entry. A resume takes no --since: the run recorded each page's scope."

Flow, read.go:120-132: `case f.since != "":` resolves `since` then `scopePages(c, root, since, head, f.since, handoffs, bm.scopes, bm.changes)`. After the run, read.go:166-173:
```go
	lockErr := recordAccepted(c, root, head, s, f.dryRun)
	if lockErr == nil && !f.dryRun && s.Stop == "" {
		for _, r := range s.Pages {
			if scopedAccept(r) {
				_, _ = fmt.Fprintf(cmd.ErrOrStderr(), "%s: accepted on a scoped read; drafted.lock keeps its earlier entry\n", r.Path)
			}
		}
	}
```
`scopedAccept`, read.go:397-406:
```go
func scopedAccept(r pipeline.PageResult) bool {
	if r.Status != pipeline.StatusAccepted || r.Accepted == "" || r.BarFrom != "" {
		return false
	}
	sc := r.Scope
	if r.ReadScope != nil {
		sc = r.ReadScope
	}
	return sc != nil && sc.Kind == blueprint.ScopeScoped
}
```
`recordAccepted` read.go:509-514 -> `updateLock(..., recordReads(l, start, s))`. `updateLock` cmd/drafter/bar.go:46-66 (worktree `drafter.lock`, ReadLock, edit, WriteLock only when changed). `recordReads` bar.go:74-100:
```go
		case r.Status == pipeline.StatusAccepted && r.Accepted != "" && !scopedAccept(r):
			if e.Accepted == r.Accepted && e.Blocked == nil {
				continue
			}
			e.Accepted, e.Blocked = r.Accepted, nil
		case r.WholeBlocked:
			b := barOf(start, r.Findings)
			...
			e.Blocked = b
		default:
			continue
```
So a scoped accept today writes nothing (falls to `default`). `r.Accepted` is the blueprint blob at the run's start commit (pipeline/blueprint.go:283-287: `git rev-parse <Head>:<plan>`).
`drafter page` writes through `recordDrafted` (cmd/drafter/pagebp.go:183-215): `recordReads` first, then each accepted page's `DraftedEntry(..., prior.Accepted)` (blueprint/drafted.go:15-39 sets `e.Accepted = accepted`), so a skipped read and a scoped accept keep the prior id (comment pagebp.go:179-182).

Pins of today's behavior: `TestRecordReads` row "a scoped accept with no bar keeps the old accepted" (bar_test.go:23-88), `TestScopedAccept` (bar_test.go:116), read_test.go:577-597 subtest "a scoped accept names its sections, sends them, and writes no lock" (expects the stderr line and `lockBytes == ""`), e2e/readbar_test.go:81/:105, bar_test.go:255/:267. Docs: docs/blueprint-format.md:557 "A change read writes no `drafted.lock` entry when it accepts." (claude/.claude/skills/blueprint/format.md is a symlink to it, tests/install.test.sh:49).

SkipRead in `drafter page`, cmd/drafter/draftscope.go:89-114:
```go
		if ps.upToDate {
			d.skipped = append(d.skipped, unchangedPage(h.Page.Path, upToDate))
			continue
		}
		if blob, err := blueprint.CommitBlobID(root, head, h.Plan); err == nil && skipRead(e, blob) {
			d.skipRead[h.Page.Path] = true
		} else if e.Blocked != nil {
...
func skipRead(e blueprint.LockEntry, blob string) bool {
	return e.Accepted != "" && e.Accepted == blob
}
```
Consumed at pipeline/blueprint.go:118-120 (`if p.w.Draft && p.w.SkipRead { return p.toDraft() }`).

Facts-only change, `blueprint.Compare` (internal/blueprint/since.go:61-186):
- A changed bullet of a fact the page places or cites (at either revision) sets `differs = true` (since.go:143-151) and marks the sections citing it changed (since.go:168-175, `sectionCites`) -> `ScopeScoped` with those IDs, `Bullets` listing it. `drafter read --since <rev>` READS (scoped, change block with `=== changed facts ===`).
- A changed bullet the page never cites only lands in `Bullets` (since.go:153-158); with nothing else different, `len(changed) == 0 && !differs` -> `ScopeUnchanged` (since.go:176-177): `read --since` prints `nothing changed since <rev>` (read.go:261) and sends nothing. `Joined` is new citations (since.go:159-166) and needs a blueprint change.
- `drafter page` with `accepted` == current blueprint blob and a cited fact changed: `pageScopeFor` sees a scoped change (not up to date), and `skipRead` compares only the blueprint blob, so the read is skipped and the page section-redrafts with no blueprint read.

## 7. #26: 64000

Every hit outside .claude/worktrees and .git:
- internal/config/stock.toml:22 `max_tokens = 64000` under `[seat.draft]` (model claude-opus-5-5, effort high).
- internal/config/stock_test.go:33 `{"seat.draft.max_tokens", "64000", "default"},`
- docs/configuration.md:292 table row "`64000` for `draft`, `32000` for the rest."
- docs/configuration.md:417 `max_tokens = 64000` in an example config block (model "example-model").
- BACKLOG.md:77-78.
No golden or e2e fixture holds 64000 (the pipeline harness uses `MaxTokens: 4000`, harness_test.go:167).

Worst case scales linearly with max_tokens. internal/ledger/price.go:53-64:
```go
func Worst(p config.Prices, model string, inputTokens, maxTokens int64, batchMode bool) (float64, error) {
	...
	r := ratesFor(price, inputTokens)
	r.input = max(r.input, r.write5m)
	return r.apply(batch.Usage{InputTokens: inputTokens, OutputTokens: maxTokens}, discount), nil
}
```
called per request at internal/pipeline/money.go:97 `w, err := ledger.Worst(r.cfg.Prices, q.Model, n, q.MaxTokens, r.batchMode())`, summed into the reservation (money.go:101-110) and checked against the page cap at ledger.go:125 (`page+r.Worst > c.Page`). Stock output price is $20/MTok with batch_discount 0.5 (stock.toml:10, :14): 64000 -> $1.28 sync / $0.64 batch output worst per draft request; 128000 -> $2.56 / $1.28.
Resume caveat: fingerprint.go:40 hashes `seat.<name>.max_tokens`, so a run started under 64000 refuses to resume after the stock default changes ("the configuration changed since the run started (seat.draft.max_tokens)", resume.go:213-214), the same class as BACKLOG.md:66.

## 8. Snippet inputs

Blueprint `code` item: `blueprint.Item` (internal/blueprint/blueprint.go:90-112); a code item uses `Text` (required), optional `Source` (`yaml:"source"`) and `Facts`. The plan view copies `Source` (blueprint/view.go:72). `plan.check` validates it, plan/check.go:210-213 and :317-329: `file, _, _ := strings.Cut(source, "#")`, resolved by `resolveFile` (check.go:264-269) relative to the PAGE's directory (or repo root with a leading "/"), must exist; the `#Symbol` part is unchecked.

cairn blueprint, /var/home/glw907/Projects/cairn-cms/blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml:
```yaml
      - id: c-script                     # :377
        kind: code
        text: |
          The script entries a site needs for the admin stylesheet build and the `check:cairn`
          gates, as the package ships them; a scaffolded site already carries them.
        source: ../../claude/snippets/check-cairn.json
...
      - id: c-ci-workflow                # :447
        kind: code
        text: |
          The starting workflow as the package ships it, for a site that has none, with the
          comment above the guidance step left out.
        source: ../../claude/snippets/check.yml
```
Both resolve to `claude/snippets/check-cairn.json` and `claude/snippets/check.yml` (exist in cairn-cms). The blueprint's constraint at :826-829 says the sentences rest on "the snippet files the code items `c-script` and `c-ci-workflow` quote".

The inlining mechanism, internal/assemble/files.go:177-205 `fileBlocks(texts ...string)`: tokenizes each text (`tokens`, :104-116, split on whitespace, backticks, quotes, parens, brackets, angle brackets, commas), resolves a token that is a `git ls-files` path (`trackedRel`, :157-164, also trying it without a trailing `.:;!?`), or an absolute path under the root that is tracked, or an `inline_files`-allowed out-of-repo path (`resolve`, :127-146), then `fileBlock` (:221-236): missing -> `not inlined: missing`; over `sizeLimit = 256 << 10` (:18) -> `not inlined: <n> bytes`; else the contents between `=== file: PATH ===` lines. Tokens with `#` or `drafter:` go to `tokenBlock` (section.go:17-...) for excerpts.

Which texts are scanned, `inputBlocks` assemble.go:123-170:
```go
	switch in.Answer {
	case AnswerReader2, AnswerCoverage, AnswerConsistency:
		return nil, nil
	}
	...
	switch in.Answer {
	case AnswerReader1:
		return r.pageBlocks(in.Page)
	case AnswerEdits:
		return r.pageBlocks(in.Page, in.Brief)
	}
	texts := []string{in.Prompt}
	...
	blocks := r.fileBlocks(texts...)
```
Only the rendered prompt is scanned (plus page and brief for a fact seat without a facts store), and only for AnswerDraft and AnswerRead. `Input.Cached` and `Input.Extra` are "never scanned for paths to inline" (assemble.go:52-58). The blueprint (with the `source:` lines) travels in `Extra` via `assemble.BlueprintBlock` (pipeline/blueprint.go:415), so its paths are not inlined; and the `source` value is page-relative (`../../claude/...`), which is not a tracked repo path anyway. Edit turns (AnswerEdits, every exchange) inline only the page and brief.

Would naming the file in the draft prompt deliver it? Yes for the whole-draft turn only, if the prompts module writes the repo-relative path (e.g. `claude/snippets/check.yml`) into the prompt text and the file is tracked and <= 256 KiB. The stock draft prompt (`wholeDraft`, stock/prompts.js:299-327) names only the page, the brief, and `drafter:` files; it never renders `inputs.exemplarSources` or any code source, and the module sees only `c.page`, `c.inputs` etc. (prompts.Context, steps.go:83-87), not the blueprint. So today nothing delivers the snippet; Go must add it (resolving `Source` against the page dir, as plan/check.go:264-269 does), or the handoff/page JSON must carry repo-relative paths that the module prints.

Draft request assembly: `p.build` (steps.go:109-120) sets `Cached, Extra = p.draftingBlocks(seat)` on the first turn of a conversation only; `draftingBlocks` (pipeline/blueprint.go:402-423) gives draft, structure, editor, fact, coherence `Cached = [DraftingFactsBlock]` and `Extra = BlueprintBlock(raw, entryJSON)` (+ scope sentence and change block for a section-redraft draft). `assemble.Build` (assemble.go:70-120) order: note, prompt, inlined file/command/excerpt blocks; when Cached is present those become the first cached part followed by each Cached block; then Extra, declined block, contract. Per-seat `inputs` commands run only for AnswerDraft/AnswerRead (commands.go:26-43); stock sets none for the draft seat. `draftInputs` (cmd/drafter/draftscope.go:24-45) builds handoff Inputs with `ExemplarSources` (from `b.Exemplars`) and `FactIDs`; there is no snippet field in `handoff.Inputs` (internal/handoff/handoff.go:47-54).

## 9. Where the rule is documented

In this repo: no doc under docs/*.md states "second fix verdict" or the round-2 rule (grep over docs/, README.md). Code/test hits: steps.go:349, :593; flow2_test.go:203-204, :280. The chain workflow claude/.claude/workflows/docs-page-chain.js:2229, :2300 and tests/docs-page-chain-derivation.test.mjs:112 carry the chain's own (Node) rule, separate from drafter's pipeline.

Specs (in ~/Projects/initiatives/docs-system/):
- specs/2026-10-12-drafter-pipeline-design.md: "## The pipeline" (:366, steps 5 and 6 describe redraft and round 2), "### Stop rules" table (:400-418, rows :410 "Redraft | A coverage miss after the redraft | none | escalate: `second fix verdict`" and :411 "Round 2 | Any seat returns fix | none | escalate: `second fix verdict`", and "There is no third round." :416), "### Coverage" (:482), "### Shared worktree" (:513, the hold rule a #23 change amends), "### Input assembly" (:420, files inlined from the rendered prompt; snippet inputs amend it).
- specs/2026-10-19-drafter-acceptance-design.md:76-96 (the new rule, #23/#25/#26, snippet inputs).
- research/2026-10-12-drafter-pipeline-review-contract.md:79 ("A miss after the redraft counts as a second fix verdict").
Repo docs a #25 change must update: cmd/drafter/read.go:56 (help), docs/blueprint-format.md:557, the stderr line read.go:170, pagebp.go:179-182 comment. A #26 change: docs/configuration.md:292 (and :417 example).

## 10. Gate and tests

- scripts/drafter-gate.sh: runs `cairn-run-gate --fresh "make -C '$dir' check"` with `CAIRN_GATE_LANE=light`, prints and repeats the `gate exit:` line, exits with cairn-run-gate's code (75 means re-issue).
- Makefile:57 `check: vet lint test chain-test prompts-parity install-test hook-test`. `vet` runs plain, `-tags smoke`, `-tags live` (:13-16). `chain-test` (:23-27) builds then runs four Node tests under tests/ (the last with DRAFTER_BIN). `prompts-parity` (:30-31) runs tests/drafter-prompts-parity.sh: Node renders tests/fixtures/drafter/matrix.json and blueprint-matrix.json and `drafter check-prompts --module claude/.claude/workflows/docs-page-chain.js --expect -` compares byte for byte. `smoke` and `live` spend money and are outside check.
- Pipeline harness, internal/pipeline/harness_test.go: `newHarness(t, opts...)` (:139-198) copies testdata/project into a temp git repo, writes `gate.sh` (:29-36: red when any docs/guides/*.md contains `BROKEN`, printing `<file>: contains BROKEN`), config with `MaxTokens: 4000`, seats draft/structure/editor/fact/reader/coverage/consistency, `Retries{GateFix: 2, EditContract: 2}`, handoffs for pageA (rotate) and pageB (revoke). Options: withoutFacts, withMode, withPageCap, withCeiling, withMaxTokens, withSeats, withInFlight, withPages, withoutContext. Helpers: mustRun, statusOf, ruleOf (:369), record, requestsFor.
- Fake API, internal/pipeline/fake_test.go: `h.api.script(stage, seat, outcomes...)` (:96-99) queues answers keyed by the custom_id's stage token and seat (`stageSeat`, :102-108); unscripted requests get `defaultAnswer` chosen by schema (:355-379: edits `{"edits":[],"resolutions":[]}`, coverage quotes, `readText("ok")`, good draft). Builders: `okText`, `readText(verdict, findings...)` (:343-348), `finding(location, text)` (:350-352, blocking true), `draftText`; `answer(old, new, findings...)` in flow_test.go:12-18; `structureFixes(h)` flow2_test.go:27-29 scripts a round-1 structure fix.
- Tests that reach "second fix verdict" to copy:
  - `TestSecondRoundFixEscalates`, internal/pipeline/flow2_test.go:274-286 (round 2):
    ```go
    h := newHarness(t, withoutFacts, withPages("b"))
    structureFixes(h)
    h.api.script("s5", "draft", okText(answer("Revoke the old key after the grace period.", "Revoke the old key once the grace period ends.", 1)))
    h.api.script("s6", "structure", okText(readText("fix", finding("Revoke the key", "Still wrong."))))
    s := h.mustRun()
    if r := ruleOf(s, pageB); r != "second fix verdict" { ... }
    ```
  - `TestCoverageMisses/"a miss after the redraft"`, flow2_test.go:197-206 (covRedraft): scripts `s5.coverage` with a quote-less item.
- e2e/: Go tests over the built CLI (blueprint_test, checkprompts_test, draft_rows_test, draft_test, e2e_test, gitfail_test, page_test, readbar_test, setup_test, spend_test, stockmodule_test; live_test and meter.go behind `-tags live`). testdata: cli/ (blueprints, drafter.toml, main.go stub, prompts-matrix.json, README.md), cli-answers/ (brief.json, coverage.json, edits-fact.json, edits-sentence.json, page.md), config/, project/ (docs, plans), prompts/ (expect.json, matrix.json, module.js).

## 11. Help output (built from main)

`drafter page --help` (long text, then):
```
Usage:
  drafter page [flags] [handoff-file | blueprint | page]...

Flags:
      --dry-run               estimate the first stage and submit nothing
  -h, --help                  help for page
      --json                  print the result as one JSON object
      --resume string         continue the stopped run with this ID
      --sync                  send ordinary Messages calls instead of a batch
      --whole                 draft each page whole, whatever its lock entry says
      --workflow-run string   read the handoffs from a chain's Workflow run file
```
Long text includes: "A page whose blueprint, facts, and outline entry match its lock entry is not run ... After a blueprint change, only the sections the change touched are redrafted, and a read of the whole page for coherence follows. --whole drafts each page whole ..." and exit codes 0/1/2/3.

`drafter read --help` (long text quoted in section 6, read.go:40-66):
```
Usage:
  drafter read [flags] <blueprint>...

Flags:
      --dry-run         estimate the stage and submit nothing
  -h, --help            help for read
      --json            print the result as one JSON object
      --resume string   continue the stopped run with this ID
      --since string    read the change in each blueprint since this revision
      --sync            send ordinary Messages calls instead of a batch
```

`drafter spend --help`:
```
Print what the ledger recorded as spent, by repo and seat, with a total. The window is the
current billing cycle unless --since or --until name UTC dates; --until is inclusive. Lines
settled at an estimate are marked. Open reservations print on a line of their own at their
worst case and are never part of the cost. With --json the report prints as one object with
rows, total, and open. The exit status is 0 on success and 1 when the ledger is unreadable.

Usage:
  drafter spend [flags]

Flags:
  -h, --help           help for spend
      --json           print the report as one JSON object
      --since string   first UTC date to count, YYYY-MM-DD (default: the cycle start)
      --until string   last UTC date to count, YYYY-MM-DD, inclusive (default: now)
```
