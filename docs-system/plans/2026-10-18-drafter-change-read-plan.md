# drafter change-read pass plan: judge the change, then rerun the format test

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-change-read-design.md`, approved
by Geoff on 2026-10-18 (glw907/initiatives#17, merge `56b2c9c`). It reworks B2's scoped read
(glw907/drafter#47) and reruns B2's format test. Facts below are quoted at drafter `main` after
#47 and cairn-cms `50dc211d9`.

## Outcome

`drafter read --since <rev>` judges the change against its diff, as a code reviewer reads a pull
request. It blocks only on what the change adds, alters, or breaks, and reports older defects as
non-blocking. The consistency read under `--since` blocks only on a conflict that touches a fact
the change touched. The skill carries backlog #3 and #4. B2's format test reruns unchanged, and the
bar is four of five by the raw first-try count.

- Risk class `runner` (the read's workflow prompt and the skill). `live-account`: API credit,
  budget $10.
- Path estimate: 180 minutes. CR.1 (90), with CR.2 (15) run by the session in CR.1's shadow; then
  CR.3 (60, using `--sync`, so no batch waits); then Close (30). The design's estimate is 120, and
  180 is 1.5x, inside the standing answer's 360.
- Clock file: the drafter worktree's git dir, except CR.3, which writes it in the cairn worktree's
  git dir with the session's cwd there.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-18):
  1. A plan up to 360 path minutes proceeds.
  2. A format test below four of five closes the pass with the result. The PR's packet then asks
     Geoff what comes next, and no further pass starts on its own.
  3. A read that blocks on an untouched item is recorded and doesn't stop the test.
  4. Live spend: as B2's plan standing answer 4 (`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md`),
     with the meter read as `drafter spend --since 2026-10-18 --json` minus B2's recorded $2.28,
     so this pass's $10 starts clean. A resume uses the worktree binary and `DRAFTER_PROMPTS`, as B2's
     did.
- Depends on, checked at launch:
  - One executor per worktree: no live session works drafter or cairn-cms (`claude agents --json`);
    both main checkouts are clean and on `main`; no worktree named `change-read` or `format-test`
    exists in either repo.
  - drafter `origin/main` holds #47 (`internal/blueprint/since.go` exists).
  - `DRAFTER_API_KEY` in `~/.local/secrets` (by name); `drafter spend --json` shows `open.count` 0.

## Design resolutions

1. **What `Compare` returns.** `internal/blueprint/since.go`'s `Compare` keeps its three kinds, but
   `ScopeWhole` now means only that there is no earlier blueprint to diff against. That covers a
   blueprint absent or undecodable at `<rev>`, a current blueprint that won't decode, and a page
   missing from the outline at `<rev>`. Every other change is `ScopeScoped`, including a removed
   section, an order or level change, a field outside `sections`, and an outline-entry change.
   `Scope` gains `Facts`, the ids of the facts the change touched. That set holds every fact whose
   bullet changed, plus every fact placed or cited by an item that is new or differs after decode,
   or by a page-level field that differs. `Scope.IDs` keeps the changed section ids, for the record.
   `ScopeUnchanged` is as before.
2. **The change block.** For a scoped page, drafter adds one block to the blueprint read's request,
   after `assemble.BlueprintBlock`. It holds `git diff <rev> <head> -- <blueprint path>`, then each
   changed fact bullet's old and new text by id, then the outline entry's old and new JSON when it
   changed. drafter builds the block and passes it as data, never as prompt text, the way it
   already sends the blueprint block. A whole read sends no change block.
3. **The prompt.** With a scope, `blueprintPrompt(scope)` replaces B2's scope paragraph with one
   that names the change block. It says to read the whole blueprint for context and judge the
   change as a code reviewer judges a pull request. A finding blocks only for a defect in what the
   change adds or alters, or one the change causes elsewhere, and that second kind is located at
   the changed item that causes it. Every other defect is non-blocking, with its finding starting
   "Already present:". The design's Google sources are quoted in the paragraph as the other blocks
   quote theirs. The unscoped render still equals B2's golden.
4. **The consistency rule.** In `completeBlueprintRead` (`internal/pipeline/blueprint.go`), a page
   with a scoped read escalates on a conflict only when the conflict's `facts` or its `with` (when
   `with` is a fact id) intersects `Scope.Facts`. Any other conflict goes to the record as a warning
   starting "Already present:", and the page goes on to the blueprint verdict. A whole read
   escalates on any conflict, as today. The consistency prompt doesn't change.
5. **The lock.** A scoped accept still writes no lock (B2's rule, now covering every `--since`
   read that isn't whole).
6. **The skill.** `claude/.claude/skills/blueprint/SKILL.md` gains two sentences. One sends an agent
   to `drafter refs <fact-id>` before it corrects a fact. The other says a caution about something
   that can go wrong is a `failure` item with a handler, linking the format page's failure section
   by heading. No rule is copied.
7. **The format test.** B2.4's protocol (`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md`,
   task B2.4, with its fold and verification changes), run again unchanged:
   - The cairn worktree is `format-test`, cut at `50dc211d9` so the base is identical to B2's.
   - The config copy, the probe session, the harness flags, and the `--add-dir` grant of the skill
     directory are all B2's.
   - The five prompts are the ones drafter#47's body records, verbatim.
   - The seeded control is B2's.
   - The bar is four of five by the raw count.
   The table adds two columns to B2's: blocking findings on the change, and blocking findings on
   untouched items (standing answer 3).

## Tasks

### CR.1: the change read (90 min)

- Risk class: `runner`.
- Outcome: resolutions 1 to 5.
- Files: `internal/blueprint/since.go` and its test, `internal/pipeline/blueprint.go` and its test,
  `cmd/drafter/read.go` (only if the scope's new field needs passing), `internal/assemble` (the
  change block, beside `BlueprintBlock`), `claude/.claude/workflows/docs-page-chain.js`
  (`blueprintPrompt`), `internal/pipeline/testdata/module.js` (if its blueprint seat must echo the
  change), `docs/blueprint-format.md` (the "What `drafter read` does with a blueprint" section's
  `--since` sentences).
- Acceptance:
  - B2's `Compare` table test, revised: the cases that were whole for a removed section, an order
    change, a page-level field, or an outline entry are now scoped, each with its `Scope.Facts`.
    An item edit's `Scope.Facts` names that item's facts and no others.
  - A pipeline test shows the change block in a scoped request and none in a whole one.
  - A pipeline test with a scripted consistency conflict on an untouched fact accepts the page and
    records the warning. One on a touched fact escalates.
  - The unscoped blueprint render equals B2's golden.
  - `tests/drafter-prompts-parity.sh` passes, with its scoped matrix case updated.
- Gate: `make check`. `money.go` and `resume.go` are untouched; a need to edit either stops the
  line.

### CR.2: the skill's two sentences (15 min), run by the session in CR.1's shadow

- Risk class: `runner`.
- Outcome: resolution 6.
- Files: `claude/.claude/skills/blueprint/SKILL.md`.
- Acceptance: the two sentences are present, the failure-section link resolves to a heading in
  `docs/blueprint-format.md`, and Vale with `--config ~/Projects/cairn-cms/.vale.ini` reports no
  error "in 1 file".
- Gate: `make check`.

### CR.3: the format test, rerun (60 min)

- Risk class: `runner` (live spend).
- Outcome: resolution 7, run live from the worktree binary by path with `DRAFTER_PROMPTS` set; the
  skill exposed for the test only, as B2's was, then removed.
- Acceptance: the result table, with each tweak's commit, `drafter check` result, scope,
  blocking findings on the change, blocking findings on untouched items, consistency outcome, and
  cost. The control's row shows a blocking finding at the seeded step. The raw count against the
  bar. The format-test worktree and branch are removed after the table is recorded, and the
  tweak patches are kept outside the public repo, as B2's were.

### Close (30 min)

- The drafter gate (`DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh`, re-issued on exit 75) on the
  close head is the full-suite home.
- Whole-branch `diff-reviewer`; one fix chain; the gate again.
- `BACKLOG.md`: #2 closed, citing the design's 2026-10-18 probe, which showed a headless session is
  denied a read of a real file inside a user-scope skill directory. #3 and #4 closed by CR.2. #1
  closed if the bar is met, or left open with the result. New follow-ups go through `log-issue`.
- A comment on drafter#43 with the rerun's table. The issue closes if the bar is met.
- The PR body opens with `## Brief` and carries the table, the classified findings, and the score.
  The executor stops at PR-ready, and `conductor-drafter` sends the packet.

## Merge order

1. glw907/drafter, then pull `~/Projects/drafter` and `make -C ~/Projects/drafter install`.

## Later

- Drafter recomputing the verdict from findings' locations, if the test shows a blocking finding
  on an untouched item.
- Writing the lock on a change-read accept (B3).
