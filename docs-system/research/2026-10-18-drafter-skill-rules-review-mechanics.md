# Skill-rules plan review: mechanics and feasibility

Reviewer: `plan-reviewer`, on `plans/2026-10-18-drafter-skill-rules-plan.md` (uncommitted), against
drafter `0a7a30b` and cairn `50dc211d9` (probes in a scratch clone; cairn's checkout untouched). Saved
by the planning session from the agent's reply. No owner fork.

## Verified

The Unplaced rule's mechanics (`untouched`, `blueprint.go:167-182`, returns false for an empty `facts`;
`changeRead()` at `:59`; `escalate` stores `Detail`, `page.go:349`; the escalated branch exempts the
`blueprint` row, `blueprint_change_test.go:206`; `null` and `[]` decode to length 0). money.go and
resume.go don't touch `Demoted`, `Warnings`, or consistency. SR.1 and SR.2 files are disjoint. Prompt 6
and 7's correct edits pass `drafter check` at `50dc211d9`. The #48 harness is present at
`~/.claude/jobs/e63b19d8/tmp/ft/`, and `c1.patch` and `c2.patch` apply. `blueprintPrompt` ranges
2267-2271, 2281-2284, 2312-2315, 2322-2327, 2329-2332 are exact; the Red Hat "Table 4. Structure
checklist" items and Google headings sentences are verbatim. Path 140 (task sum 195); SR.4's 75 minutes
is plausible from #48's pace.

## Findings

1. **Blocker: the settled pair check is missing and contradicted** (resolutions 2-3, lines 100-117;
   SR.3, 287-318; Later, 378-379). Resolution 3 says "One bullet changes", SR.3 requires "one file, one
   line changed", and Later defers `f:ejuoh6`/`f:1pb077`, `f:ejuoh6`/`f:vg42j3`, `f:86h9o6`/`f:vg42j3`.
   `Compare` (`internal/blueprint/since.go:50-53,117-128`) adds a removed item's facts to `Scope.Facts`, so
   prompt 7 (removes `ver-live-wait`, citing `f:1pb077`) always touches `f:1pb077`; run
   `20261018T210429Z-592c0739` named `f:ejuoh6`/`f:1pb077`. #48's t5 added `f:vg42j3`, so prompt 5
   touches every `f:vg42j3` pair. Up to 6 of 21 runs are exposed against 4 allowed misses. Fold: SR.3
   reads both sides of every reachable pair (`f:sszb7b`/`f:vg42j3`, `f:ejuoh6`/`f:vg42j3`,
   `f:86h9o6`/`f:vg42j3`, `f:ejuoh6`/`f:1pb077`; for the last, `health.ts:57-58` `VERDICT_TTL_MS = 60_000`
   and `createLiveTokenCheck`), lists `f:72yc97`/`f:olofdb` as unreachable, corrects each pair the code
   proves wrong, records scope differences as no defect; acceptance "one line per corrected bullet, in
   `extend.md` only"; row 0 revises once if it names a corrected pair; delete those pairs from Later;
   the PR names every corrected bullet; SR.3 about 40 minutes, path 145.
2. **Major: the self-check links a file whose read is a breach** (resolution 4, 127-129, against
   resolution 7, 212-214). "Check what you add" links `docs-page-chain.js`, and any read of it is a miss.
   Fold: cite `blueprintPrompt` by name with no link, link only `#what-drafter-read-does-with-a-blueprint`;
   name `docs-page-chain.js` in the probe's stream check.
3. **Major: SR.2's vale acceptance can't be met** (line 284). At `0a7a30b`, vale with cairn's config
   reports 3 `Google.Quotes` errors in `docs/blueprint-format.md` (two at 311, one at 370:8, the paragraph
   SR.2 edits); `SKILL.md` matches no glob. Fold: no vale error on any added line, against a baseline of
   3; `SKILL.md` stated unlinted.
4. **Minor: two clauses lack a quoted source** (152-153): "never invents output" and "its symptom
   differs from every existing row". Fold: source both to drafter's own format rule (`#items`; the "Add a
   failure case" row) and mark them so.
5. **Minor: the spend projection is low** (43-50, 327). Sessions averaged $0.375; the probe cost $0.19;
   projected about $16.7 of $20; the $0.75 reserve is under the worst session plus read. Fold: state
   about $17, reserve $0.90, probe about $0.20.
6. **Minor: harness reuse needs more edits** (199, 208-210, 74-78). `OUT` hardcoded to the jobs dir in
   three scripts; `read.sh` hardcodes `50dc211d9`; `tweak.sh` lacks `git clean -fdq` and a HEAD check;
   `control.sh` seeds through `control.py`. Fold: list each edit; use `git apply` for the controls.
7. **Minor: tweak 5 cited `f:vg42j3`, not `f:sszb7b`** (104). Fold: correct it.
8. **Minor: SR.2's "fails today" grep passes vacuously** (272). Fold: use the full path
   `claude/.claude/skills/blueprint/SKILL.md`.
9. **Minor: SR.1's two-conflict row can pass vacuously** (249-258). Fold: distinct conflict texts, both
   asserted in `Escalation.Detail`.
10. **Optional: classify "Unplaced:" warnings** (219). Fold: present or introduced, per row.
11. **Optional: the `ConsistencyPrompt` quote is on `consistency.go:25`.**

No over-ceremony worth cutting.
