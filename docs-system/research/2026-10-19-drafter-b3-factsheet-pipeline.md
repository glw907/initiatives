# Factsheet: drafter pipeline internals for B3 (read at drafter main f286162, 2026-10-19)

## Step machinery
- Step constants internal/pipeline/work.go:11-28 (stPlan, stBpCheck, stBpRead, stConsistency, stDraft, stGateFix, stCoverage, stRound1, stRedraft, stRound2, stReader1, stReader2, stFinalRedraft, stScoped, stDone); stages s1..s7 work.go:30-39; exchange kinds exDraft/exRedraft/exFinal work.go:41-47.
- `advance` steps.go:~128-165 switches on `p.ps.Step`; default errors `unknown step`.
- Persistence: run.PageState (internal/run/state.go:46-66); `work` struct work.go:84-133 marshalled into ps.Work by runner.save (pipeline.go:288-298).
- A new step needs: constant; `advance` case; `stepSeats` (handle.go:44-79); `validate` (handle.go:192-234); `complete` (handle.go:238-275); maybe `noRetry` (handle.go:98-104) and `isRead` (handle.go:107); transitions in the previous step; `exchangeStep` (check.go:125-133), `coveragePhase` (check.go:115), `exchangeStage` (steps.go) for exchange-based steps.
- record.go has no step switch; page.go:132 `initRecord` hardcodes SeatsNotRun list.
- resume.go has NO switch on step names (works by status, Intents, Writes, PendingGate).

## Blueprint branch
- page.go:44 `p.blueprint = strings.HasSuffix(h.Plan, ".blueprint.yaml")`; start.go:272-274 starts it at stBpCheck.
- doBlueprintCheck blueprint.go:98-117; stageBlueprintRead blueprint.go:121-163 (consistency + blueprint in one s1 batch); completeBlueprintRead blueprint.go:220-279 ends with `p.w.Accepted = <blob>; return p.accept()`.
- missingSeats page.go:161-181: blueprint page needs only `blueprint`.
- Non-blueprint path calls `p.planDoc()` (doPlan, stageConsistency, doCoverage), which decodes plan.Plan YAML and fails on a blueprint. `bpInputs.view` (blueprint.View -> *plan.Plan) exists and could serve as the plan.
- cmd/drafter/read.go:353-401 `blueprintHandoffs`: Page{Path, Brief=<blueprint minus .blueprint.yaml>.brief.json, Type}, Plan=blueprint rel path, Inputs{Job}, Context {"resolved":{"pages":[entryJSON]}}, no Framing/Args.
- cmd/drafter/page.go has no blueprint code; passes handoffs to pipeline.Run without Since/Scopes/Changes.

## Context fields (internal/prompts/context.go:49-60)
- Page, Inputs, Round (1|2|"final"), Findings, AfterFinalRead, Scope (string), Where (string), Narrow (raw JSON), Turn, Facts.
- p.context(round) sets Page, Inputs, Round, Facts.
- scope: change read sets "page" or comma-joined Scope.IDs; stageScoped sets it to the final reader's findings text. `where` is never set outside tests. `narrow` only in stageRound2 ({baseline, own}); round 2 narrows to a diff vs the round-1 snapshot, not to sections.

## Regions and hashes
- coverage.Regions(headings []string, page []byte) (preamble string, text []string, found []bool), sections.go:93-109; heading line omitted; fences ignored; unplanned headings don't split.
- blueprint.SectionHashes(b, page) hash.go:21: `_intro` -> preamble hash, plus `s.ID` -> sha256 of region for found sections.

## Compare (internal/blueprint/since.go:61)
- `Compare(file string, old, cur Revision) Scope`; Revision{Blueprint []byte; Entry *Page; Facts *plan.Facts}; cmd read.go `revisionAt` builds revisions from git show.
- Scope{Kind (ScopeUnchanged|ScopeScoped|ScopeWhole), IDs, Facts, Bullets, Joined, Why}. Whole when old absent/undecodable, cur undecodable, or outline lacks page.
- A removed section, order change, page-level field change (Introduction, Dispositions, Framing), or outline-entry change sets `differs` with no section id: Scoped with empty IDs ("page"). B3 must map these to a whole redraft itself.

## Lock
- Types blueprint.go:180-195: Lock{Version, Pages map[string]LockEntry}; LockEntry{Page, Blueprint, Accepted, Sections}. LockFile install.go:17, path = dir(outline)/drafted.lock.
- newLockEntry(b, pageBlob, pageBytes, bpBlob) install.go:126; callers InstallConverted (install.go:105), seedEntry (seed.go:107, keeps old.Accepted).
- ReadLock lock.go:46 (missing -> empty; KnownFields); WriteLock lock.go:68 atomic, sorted, header comment. FileBlobID, CommitBlobID in hash.go. Writers take worktree lock `<git dir>/drafter.lock` via run.TryLock.
- recordAccepted cmd/drafter/read.go:432-470 runs AFTER pipeline.Run returns (lock released by then), no-op on dry run or stop, sets only Accepted, skips scoped accepts.
- Inference: writing the drafted-page entry the same way, in cmd after Run returns, keeps the lock out of the run's file ownership and out of resume.go.

## Ownership and resume
- page.files() page.go:57 = {page, brief}. snapshotPre page.go:81; writeFiles page.go:206 records run.Write; finalize page.go:257; restore page.go:301 restores only files() and index-link files.
- resume.go wantHashes :223-252; checkTree :257-304 refuses any changed path not owned ("%s changed and is not a file of this run"). A mid-run lock write would break resume; a post-run write in cmd does not.
- begin requires a clean tree (start.go:88).

## edits.Apply
- apply.go:27 `Apply(page, brief string, fs []Finding, prior []Resolution, a Answer) (Applied, error)`; types.go Edit{File, Old, New}, Answer, Finding{N, Seat, Location, Text, Rewrite, Blocking}, Resolution.
- completeExchange handle.go:~367-386: Apply; on *Refusal -> p.refused (retry within cfg.Retries.EditContract, then escalate "contract"); on success writeFiles then gateStep. No region parameter today.

## Money and seats
- money.go keys on no seat or step names; seatOf splits custom_id on "_" (seat names must not contain "_"); modelOf reads cfg.Seat. No money.go edit needed for a new seat.
- A `coherence` seat needs: seatNames in internal/config/check.go:14 (append after index 7 to keep defaultSeats = seatNames[:7]); `[seat.coherence]` in internal/config/stock.toml (draft opus high 64000; reviewers medium 32000; coverage/consistency low; prices only for claude-opus-5-5); validateSeat validate.go:56-72; initRecord list page.go:132; missingSeats page.go:161-181; internal/smoke/shapes.go:38-49 seatAnswers; maybe assemble.Answer consts (assemble.go:22-31); scaffold template and e2e/testdata/config/drafter.toml.

## check-prompts (cmd/drafter/checkprompts.go)
- Flags --module, --matrix (required), --expect, --json. No built-in fixture or matrix; user matrix decoded strictly into prompts.Context.
- Containment (:219-253): prompt contains context.page.path (blueprint seat must NOT); findings appear; narrow.own findings appear.
- Fixtures e2e/testdata/prompts/{module.js, matrix.json, expect.json}, 3 cases. Other: tests/drafter-prompts-parity.sh, cmd/drafter/testdata/blueprint-prompt.golden.txt.
- B3's "renders every stock seat against the fixture, no path the fixture lacks, no cairn-only name" is new behavior.

## Other
- read and page share pipeline.Run; only read sets Options.Command/Since/Scopes/Changes; Options.Scopes feeds p.w.Since/Scope/Change (start.go:~275-277); changeRead() blueprint.go:59.
- stock/prompts.js (181 lines) returns only {blueprint}.
