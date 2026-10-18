# Fold record: drafter change-read plan

Plan: `plans/2026-10-18-drafter-change-read-plan.md` at `cc15fc7`, revised. Reviews in
`research/`: `-review-mechanics.md` (M), `-review-contract.md` (C), `-review-integrity.md` (I).
Every finding below was checked against drafter `f7d9034` and the B2 plan before its disposition.
Convergent findings fold once, at the root, and the others point there. Planning rulings 1 to 5
(2026-10-18) are applied as given.

Probes run for this fold (read-only):

- `internal/pipeline/blueprint.go:130-131` sets `c.Scope = strings.Join(p.w.Scope.IDs, ",")`;
  `docs-page-chain.js` passes `c.scope || undefined` and renders the scope paragraph on
  `${scope ? ...}`. `since.go:101-103` returns `ScopeUnchanged` when no section changed.
- `scopePages` (`cmd/drafter/read.go:212-214`) calls `revisionAt` at both `since` and `head`, so the
  change block can be built there from commit-pinned inputs.
- `work.go:123-127`: `Since` and `Scope` persist in `work`; `start.go:273-274` sets them from
  `Options`.
- `completeBlueprintRead` records findings only on `fix` (`blueprint.go:162-164`).
- `consistencyAnswer` is `facts []string`, `with string` (`handle.go:177-183`).
- Item and section ids share one unique namespace (`internal/blueprint/decode.go:52`).
- `SKILL.md:16` already holds the `drafter refs` sentence, under case 1 only.
- `docs/blueprint-format.md` has no failure heading; `## The edit catalog` (line 333) holds the
  "Add a failure case" row (line 343).
- `readlink -f ~/.claude/skills/blueprint` is the main checkout's skill directory;
  `~/.claude/settings.json:93` runs `drafter-page-hook`.
- `drafter spend --since 2026-10-18 --json`: `total` 3.1758.
- B2's executor transcript exists and mentions `s-interval` 7 times. PR #47's body records the
  prompt wrapper ("Use the blueprint skill." ... "Commit the change.").
- `git diff --no-color --no-ext-diff --no-textconv <a> <b> -- <path>` runs on git 2.56.0 and prints
  a plain unified diff.

## Counts

- Folded: 38 (7 of them per a planning ruling: M3, M12, C1, C2, C3a, I3, I9)
- Refused: 3 (M16, C12, I8), plus the two `-c` overrides inside I7
- No action: 1 (C15, no finding)
- Owner fork: 0

## Mechanics (M)

| # | Finding | Disposition |
|---|---|---|
| M1 | Scoped page with empty ids renders the unscoped prompt (blocker) | Folded at the root: resolution 3 keys the paragraph on `Kind == ScopeScoped` (scope `page` when no ids); resolution 1 makes every non-whole change scoped, so a reorder or removal no longer falls to unchanged; `scopeText` prints `scoped: page`; CR.1 adds the `Compare` empty-`IDs` cases and the outline-only request test. |
| M2 | No source for old fact text or the old entry; resume | Folded at I6's root: resolution 2 builds the block in `scopePages` from the two commit-pinned revisions and persists it in `work`, off `Scope`; `git diff` flags named; `read.go` and `read_test.go` are unconditional in Files. Moving `revisionAt` was not needed, since `scopePages` already has both revisions. |
| M3 | "Expose, then remove" deletes the installed skill | Folded (ruling 5): resolution 8 swaps and restores the link; launch records its target; CR.3 acceptance checks the restore. |
| M4 | CR.2's refs sentence already exists; #3/#4 close without evidence | Folded: resolution 7 moves the step to case 2, where a fact found while reading is corrected; CR.3 keeps every B2.4 row field; Close shuts #3 and #4 only on transcript and commit evidence. |
| M5 | No failure heading to link | Folded: resolution 7 and CR.2 link `format.md#the-edit-catalog`, naming the "Add a failure case" row. |
| M6 | Proofs pass on an empty fixture | Folded: CR.1's change-block test uses a since commit earlier than head; consistency rows all use a blueprint `ok` and assert `consistency`; a `with`-only row is added. |
| M7 | Seeded control's patch is gone | Folded at C5's root: resolution 8 names the transcript as the source, re-seeds if unrecoverable, states the prompt wrapper, and keeps patches outside any worktree git dir. |
| M8 | `--since` help, comment, and tests not listed | Folded: CR.1 Files names the help text and `scopedAccept`'s comment; `read_test.go:562` moves to a blueprint absent at `<rev>`; `:242` is revised. |
| M9 | Meter starts at $3.18; sessions outside the meter | Folded: standing answer 4 reads the baseline at launch and adds sessions' `total_cost_usd`. |
| M10 | `Scope.Facts` includes facts the page never cites | Folded at I4's root: resolution 1's definition limits it to facts the page places or cites, items matched by id. |
| M11 | Conflict states unnamed | Folded at C3b/I4's root: resolution 4 names empty `facts`, unknown ids, page `with`, mixed conflicts (escalate listing all), and a pre-`Facts` state. |
| M12 | Owner fork: conflict from a new or changed link | Folded (ruling 3): demoted in this pass, stated in resolution 4, "Later" line added. |
| M13 | Harness not literally unchanged; `pgrep -f` dropped | Folded: resolution 8 records the live hook as a known difference; launch restores `pgrep -f`. |
| M14 | Change block framing and delimiters (optional) | Folded, free: one clause in resolution 2. |
| M15 | Predictable conflict on a re-cited fact (optional) | Folded, free, at C14's root: escalated conflicts are classified against base like findings. |
| M16 | CR.2 is single-deliverable (optional) | Refused: merging it changes no path minute and loses CR.2's own acceptance line. |

## Contract (C)

| # | Finding | Disposition |
|---|---|---|
| C1 | "Already present:" label can pass a defective tweak (owner fork) | Folded (ruling 1): resolution 8's pass rule counts an introduced "Already present:" finding as a miss, classified against `git show <base>`; CR.3 adds the column. |
| C2 | Control proves only a defect inside the added item (owner fork) | Folded (ruling 2): control 2, a broken `requires` in an untouched section caused by the change, outside the bar, about $0.35. Control (ii) is covered offline by CR.1's consistency rows. |
| C3a | Link-caused conflict demoted | Folded (ruling 3): as M12. |
| C3b | `with` exact-match fails open | Folded: resolution 4 fails closed; CR.1 adds the unknown-id, empty-`facts`, and unmatched-`with` rows. |
| C4 | Empty ids render the unscoped prompt | Folded at M1. |
| C5 | Control artifact gone | Folded: resolution 8 names B2's executor transcript, with "re-seeded" marking as the fallback. |
| C6 | Accept drops non-blocking findings | Folded at I3's root: resolution 5 records findings on every verdict; CR.1 row. |
| C7 | Change-block test checks presence only | Folded: CR.1's change-block row asserts each part's content and its place in the data, not the prompt. |
| C8 | Resume can lose `Scope.Facts` | Folded at I2's root: resolution 1 tags the field without `omitempty`; CR.1 asserts the round trip. |
| C9 | Consistency tests omit cases | Folded: the four rows are in CR.1's consistency table. |
| C10 | `Compare` gaps; `Scope.Facts` ambiguous; departures unflagged | Folded: level change and framing/introduction/dispositions cases named; uncited-fact case added; the two extra whole cases marked as departures in resolution 1. |
| C11 | Scoped prompt content asserted nowhere | Folded: CR.1 revises the existing contains-assertion at `read_test.go:242` with the four strings. |
| C12 | Verdict disagreeing with flags | Refused: B2.4's rule (read exits 0 and zero blocking findings) already counts both disagreements as misses, and the row's verdict and blocking columns show them; a separate column adds nothing. |
| C13 | #3 and #4 close on presence | Folded at M4's root. |
| C14 | Base conflict re-escalates on re-cite (optional) | Folded, free: resolution 8 classifies each escalated conflict against base. |
| C15 | Over-ceremony | No action: the review found nothing material. |

## Integrity (I)

| # | Finding | Disposition |
|---|---|---|
| I1 | Empty ids read as unscoped (blocker) | Folded at M1. |
| I2 | A B2-era state demotes every conflict | Folded: resolution 1 makes `Facts` non-nil on every scoped page with no `omitempty`; resolution 4 reads a nil `Facts` as whole for prompt and rule, no lock; CR.1 row. |
| I3 | Findings and demoted conflicts dropped on accept | Folded (ruling 4): resolution 5 records findings on every verdict and prints both counts in the summary, text and `--json`. |
| I4 | Touched set and match fail open | Folded: resolution 1's union over old and new versions; resolution 4's fail-closed rule. A page `with` demotes when the facts are known and untouched, per ruling 3, instead of always escalating. |
| I5 | CR.3 deletes the installed skill | Folded at M3. |
| I6 | Change block not pinned across a resume | Folded: resolution 2 builds it once in `scopePages`, persists it in `work`; CR.1 asserts same bytes on resume; Files adds `pipeline.go`, `start.go`, `work.go`. |
| I7 | `git diff` shaped by user config | Folded: `--no-color --no-ext-diff --no-textconv` (probed). The `-c core.quotepath` and `color.ui` overrides are refused: blueprint paths are ASCII and `--no-color` already wins over `color.ui`. |
| I8 | `<rev>` not an ancestor (optional) | Refused: it fails closed (more blocking, never a silent accept), and the stderr line is new code and a test for no measured defect. |
| I9 | Demoted conflict has no durable sink (optional, owner fork) | Folded (ruling 4): summary counts now, a "Later" line requiring B3 to persist them before a scoped accept writes the lock. |
| I10 | Headless spend outside the cap (optional) | Folded, free, at M9's root. |

## Estimate

CR.1 rises from 90 to 150 minutes (the scoped `Compare` rework, the persisted change block, the
fail-closed rule, the summary counts, and their tests). CR.3 rises from 60 to 80 (control 2, the
base classification, the link swap and restore, the control recovery). CR.2 stays in CR.1's shadow.
Path: 150 + 80 + 30 = 260 minutes, inside 360.
