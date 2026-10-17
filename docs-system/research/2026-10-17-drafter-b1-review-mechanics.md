# B1 plan review: mechanics and feasibility

Reviewer: `plan-reviewer` agent (Opus, medium), 2026-10-17. Saved by the planning session, since the
agent's definition forbids writes. Target: `docs-system/plans/2026-10-17-drafter-b1-blueprint-format-plan.md`
at 2e44160. Code: drafter d3447d9, cairn-cms main 9754d6357. Two scratch probes against
go.yaml.in/yaml/v3 v3.0.5 (drafter's pin).

Summary: 1 blocker (B1.5 as written can't run), 14 majors (most from B1.4 assuming the pipeline
accepts blueprints when it's handoff-driven end to end, and the frozen `resume.go` depends on that;
each has a fold that keeps `money.go`/`resume.go` untouched), 13 minors. Path and 2x line hold
(600 = 2 x 300; standing approval to 900). Folds 1 and 2 add work to B1.4; its 150 is the most
overrun-prone estimate.

## Blocker

1. B1.5 runs the wrong drafter, with no local config and the wrong prompts module. blocker,
   correctness. Plan 330-363.
   - Wrong binary: `command -v drafter` is `~/.local/bin/drafter`, built Oct 14 from main, with no
     `convert`/`check`/`read`. Step 1 builds `<drafter worktree>/drafter`, later steps call bare
     `drafter`.
   - Old binary rejects the new config: after step 4 adds `[seat.blueprint]`, it refuses the whole
     config ("is not a seat", `internal/config/check.go:96-100`).
   - No local config: drafter reads only `<root>/drafter.local.toml` (`internal/config/load.go:80`);
     pass 5 copied `~/.config/drafter/cairn-cms.local.toml` in (pass-5 plan:453). Without it
     `prompts` is unset and `drafter read` exits 2 (`validate.go:40-41`).
   - Prompts module lacks the seat: that local file's `prompts` is
     `~/.claude/workflows/docs-page-chain.js`, a link to drafter main's chain, with no `blueprint`.
   - Fold: step 0 copies `cairn-cms.local.toml` to `<cairn wt>/drafter.local.toml` and confirms
     `git check-ignore` (cairn `.gitignore:33`); every drafter command runs as `<drafter wt>/drafter`
     with `DRAFTER_PROMPTS=<drafter wt>/claude/.claude/workflows/docs-page-chain.js` (`env.go:46`;
     env loads after local, `load.go:47-50`); `<wt>/drafter config` exits 0 before any spend.

## Major

2. `drafter read` has no handoff, and the frozen resume path needs one. Plan 266-307, resolution 7.
   `Options.Handoffs` (`pipeline.go:41`) and the project root come from handoffs (`start.go:44-51`);
   `resume.go:154-185` rebuilds pages only from `r.o.Handoffs` and calls `h.Verify()`; `newPage`
   marks any `.yaml` plan as v1 (`page.go:40`), so `doPlan`/`planDoc` would `plan.Decode` a
   blueprint and refuse its fields; `assemble.ConsistencyPrompt` takes `*plan.Plan`
   (`consistency.go:20`). Fold: `read.go` builds one `handoff.Handoff` per blueprint (Plan = the
   blueprint path, Framing empty, Checksum = `handoff.Checksum`, Page.Path from the path rule,
   Inputs from the outline entry); pages whose plan ends `.blueprint.yaml` route to the new step;
   `internal/blueprint` gives projections Blueprint -> `*plan.Plan` (keeping Line/Lines) and
   outline.yaml -> `*plan.Outline`, so `plan.Check` and `ConsistencyPrompt` run unchanged.
   `handoff.Checksum(project, bp, "")` is `"sha256:"` + hex of the blueprint bytes
   (`handoff.go:176-190`), the same form as `hashBytes` (`record.go:138`), so it can be the
   accepted hash.
3. Writing the lock on accept breaks resume. Plan 296-298. `checkTree` (`resume.go:257-304`) owns
   only `p.files()` and index-link files; any other changed file stops the resume. Two blueprints
   stopping after one accepted can't resume, nor can a crash between lock write and `save`.
   `run.Write` is page-and-brief shaped (`state.go:93-103`). Fold: write `drafted.lock` once in
   `cmd/drafter/read.go` after `pipeline.Run` returns a summary with no stop, from accepted pages
   and their handoff checksums. Rows: two blueprints, stop after the first accepts, `--resume` ends
   with both in the lock; a crash before the lock write leaves it untouched. Drop "records the
   write in state as a drafter write".
4. A new seat in `seatNames` becomes required for every run. Plan 272. Default `Seats` is all of
   `seatNames` (`apply.go:29`); `Validate(ScopeRun)` then requires `seat.blueprint.*` for every
   `drafter page` run in a project that doesn't list `seats` (`validate.go:43-48`); only
   consistency is exempt. The plan never says whether `drafter page` on a v1 handoff runs the read.
   Fold: the seat runs and is required only for blueprint pages, following the consistency
   exemption; add `internal/config/validate.go` and `internal/pipeline/page.go` (`runs`) to the
   files; test that `drafter page` with a v1 handoff and no `[seat.blueprint]` validates.
5. The read's request contents match no existing mechanism. Plan 278-279. `AnswerRead` inlines
   every repo file the rendered prompt names, whole, plus the code excerpts of `FactIDs`
   (`assemble.go:107-150`, `excerpt.go:29-41`), not bullets. `prompts.Context` carries no blueprint
   or outline entry; `pageJSON` gives only path, brief, type, job without handoff context
   (`steps.go:52-71`). Without context the chain's `WT` and `OUTLINE` are unset
   (`docs-page-chain.js:570,589`) and `structurePrompt` uses both. Hazard: naming
   `docs/internal/facts/extend.md` inlines 1015 bullets. Fold: for blueprint pages `pageJSON` adds
   `blueprint` (the path) and the outline entry (`type`, `job`, `covers`, `outOfScope`); the
   module names `c.page.blueprint` so `fileBlocks` inlines it; placed-fact bullets come from a
   Go-built block reusing `placedFacts` and `facts.Get` (`consistency.go:73`); add
   `internal/assemble` to files; decide whether `FactIDs` excerpts stay on; forbid naming a facts
   file in the prompt.
6. The B1.2/B1.3 pair isn't independent. Plan 217-228, 257-264. B1.3's "`check` on it reports
   exactly..." needs B1.2's check; B1.2's e2e row builds `../cmd/drafter` (`e2e/e2e_test.go:29`)
   but `check` isn't in `root.go` until after the merge. Fold: both rows move to the session's
   post-merge step.
7. The converter's YAML writer will produce files the decoder refuses. Plan 237-246, 257. Probe:
   `yaml.Marshal` writes every zero field; `decode.go:301-305` refuses keys outside the kind.
   Blanket `omitempty` drops a required-empty `items: []` (`plan.go:66`, `decode.go:262-266`).
   Fold: a kind-aware encoder building a `yaml.Node` with only set fields, keeping required-empty
   `items`, block scalars for multi-line prose; round-trip row covering an empty-items level-2
   section.
8. Exemplars lost, `registerSections` has no source. Plan 142-146, 233-243, 333-339. outline.yaml's
   page fields exclude `exemplars`; `convert outline` doesn't map them; `convert plan` given the new
   outline.yaml yields empty exemplars (cairn's rotate entry has two). `registerSections` comes from
   chain config (`registerSectionsFor`, chain:2203). Fold: `convert plan` reads exemplars from the
   chain's JSON outline entry; lists empty `registerSections` as needing judgment; B1.5 fills it.
9. Lock rule vs read's "create the entry". Plan 203 vs 298. Fold: the existence rule applies only to
   entries carrying a commit or page hash; an accepted-only entry is valid when outline.yaml lists
   the page; add a fixture.
10. `[[id]]` at the start of a plain YAML value is a parse error or a silent list. Resolution 3.
    Probe: `why: [[verify]] carries the checks` -> "did not find expected key"; `why: [[verify]]`
    -> `!!seq`; mid-string and block scalars fine. Fold: a named finding with fix ("quote it or use
    `|`"); the format page states it; two refusal tests.
11. No merge order across the two PRs. Close, 380-406. Once cairn's `drafter.toml` has
    `[seat.blueprint]`, the installed binary refuses every drafter command on cairn main until the
    drafter PR merges and `make install` runs (`check.go:96-100`). Fold: drafter, then `make -C
    ~/Projects/drafter install`, then cairn; the cairn PR carries `## Before merge` with those
    commands and the check `drafter config` exits 0 in cairn; the conductor prompt names the order.
12. Unnamed check states. Fold: one line per state (exit code and finding text) in B1.2-B1.4, each
    with a test row. `check`: root absent, outline.yaml absent/malformed, drafted.lock
    absent/empty/malformed, no drafter.toml, a named file not `.blueprint.yaml` or off its
    path-rule location, many bad files (continue past a decode failure?). `refs`: unknown id vs
    known id with no placements; a blueprint that fails to decode. `convert`: no outline entry;
    unmatched framing section; the H1 `# Framing record:` line (skip, not refuse). `read`: accepted
    hash already equals the blueprint hash.
13. Privileged fields don't name who may set them: the lock's accepted hash, `review: human`,
    `managed: false`, `origin: human`, `blueprints.required`; no config layers or env vars for
    `blueprints.*` (`layer.go:22-44`). Fold: a "Who sets this" line per field in the format page;
    lock fields drafter-only; `blueprints` in `allowedIn` (project, local); note
    `DRAFTER_BLUEPRINTS_*` (`env.go` has no bool parsing); "a hand-edited accepted hash is
    untrusted" as a B4 design input under Later.
14. B1.5's clock either never fires or fires on batch waits. major, optional. OWNER FORK on sync.
    Plan 65, 326. `claude-clock-stop` resolves the git dir from the tool call's cwd; B1.5 runs in
    the cairn worktree. Six rounds of two sequential batches are wall clock the hook counts. Fold:
    B1.5 writes the clock in the cairn worktree's git dir and (a) removes it while a batch is in
    flight, or (b) runs `--sync` at about 2x cost. Recommend (a), with fold 23.
15. `anatomy` has no shape; the register has no anatomy headings. Plan 143, 335-336.
    `docs-register.md:752` holds bold-named bullets (Concept page, Task guide, Tutorial, Tutorial
    milestone, Reference entry, Condition entry, Symptom row). Copying text would give register
    rules a second home. Fold: `anatomy` names the register entry; step 2 maps concept -> Concept
    page, task guide -> Task guide, tutorial milestone -> Tutorial milestone, symptom row ->
    Symptom row.

## Minor

16. `migration-notes.md` is in `extend.json`'s `kept` list, not `pages`. Fold: `convert outline`
    maps `kept` as `managed: false`, or step 2 adds it by hand with required fields named.
17. Hash definitions: `"sha256:<hex>"` over raw bytes (`record.go:138`); a section span follows
    coverage's region rule (`internal/coverage/sections.go:16-26`, unexported: expose or move); a
    blueprint section with no matching heading gets no hash and `convert` lists it; "committed
    blueprint's hash" means this form, not a git blob id.
18. The lock seed records HEAD. Seed with `git log -1 --format=%H -- <page>` so B4's `git show
    <commit>:<page>` survives a squash; as written it also pairs HEAD with an uncommitted
    blueprint hash.
19. Resolution 1 keeps title and path in two homes. Fold: drop them from the blueprint, or `check`
    errors when they differ from the path rule or outline.
20. Section id namespace and pattern: say whether section ids share the item id space (matters
    for `[[id]]` vs `handledBy`); check a slug matches `^[a-z0-9][a-z0-9_-]*$`.
21. Vacuous proofs: the resume row must stop with the blueprint intent open, after consistency
    settles, with a facts dir; the `fix` row needs a pre-existing earlier accepted hash; the
    converted-check fixture needs one `use` opening "Only" and one not; each edit-catalog fixture
    differs from the base in its row's kind; time 11 copies, not one blueprint.
22. Bare heading references go undetected (rotate plan, 12 places:
    `plan.yaml:28,48,54,129,139,345,353,399,420,452,680,701`). optional: a warning when a prose
    field contains another section's heading text.
23. The dry run shows only the consistency read. optional: put consistency and blueprint in one
    stage (`stepSeats` returns both), which halves batch round trips and makes the dry run cover
    the read.
24. B1.5 is labeled `live`, not a risk class; it may edit the chain's prompt, so `runner` plus
    `live-account`.
25. The rotate plan's `friction` lines have no destination; file them in step 3 and add cairn-pass's
    close checklist (triage `docs/internal/docs-friction-log.md`) to Close.
26. B1.5 never commits the lock after `accept`.
27. optional: the live smoke is ceremony; `blueprint` reuses `AnswerRead`'s schema, already in the
    smoke for structure/editor/fact (`smoke/shapes.go:37-47`). Run it in the background alongside
    steps 2-5 or drop the coverage line.
28. Close grep scope: add `tests/fixtures/`, `e2e/testdata/`, `internal/*/testdata/`; "draft until
    CI is green" doesn't apply to drafter (no `.github/`).

Folding priority: fold 1 first (B1.5 can't start without it), then 2-5 (B1.4's real mechanism).
Probe sources: the planning session's scratchpad `yprobe/`.
