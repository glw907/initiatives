# Change-read plan review: mechanics and feasibility

Reviewer: `plan-reviewer`, at plan commit `cc15fc7`, against drafter `main` (with #47) and cairn-cms
`50dc211d9`. Probes read-only. Verdict: not ready; 1 blocker, 6 majors, 7 minors, 2 optional.
Verified as stated: the task list, risk class, estimate (180 against 360), the cairn base (still
`origin/main`, holds the rotate blueprint), drafter#43 open, initiatives#17 merged `56b2c9c`, and
the Google quotes against the live pages. Saved by the planning session from the agent's reply.

## Blocker

1. **A scoped page with no changed section ids gets the unscoped prompt** (correctness). plan:43-50,
   57-63; `internal/pipeline/blueprint.go:130-131`; `docs-page-chain.js:2355`. The prompt's scope is
   `c.Scope = strings.Join(p.w.Scope.IDs, ",")`, the adapter passes `c.scope || undefined`, and the
   paragraph renders only when `${scope ? ...}` is truthy (js:2346). Resolution 1 makes a reorder, a
   removed section, a page-level field, an outline-entry change, and a fact cited only from framing,
   introduction, or dispositions scoped with empty `IDs`, so each renders the unscoped prompt (the B2
   failure mode). `Compare` builds `changed` only from section content (`since.go:87-104`), so a
   reorder or removal with no content change falls to `ScopeUnchanged` without an explicit return.
   `cmd/drafter/page.go:195` prints `scoped: ` with nothing after. Fold: resolution 3 decouples the
   prompt from `IDs` (a fixed non-empty scope value, since the paragraph names the change block, or
   ids with a fixed fallback); resolution 1 says a reorder or removal with no content change returns
   `ScopeScoped`; CR.1 adds a `Compare` case and a render case for scoped-with-empty-IDs and names
   `page.go:195`'s text for it.

## Major

2. **The change block has no source for old fact text or the old outline entry** (correctness).
   plan:52-56, 93. The pipeline reads only head (`bpInputs`, `blueprint.go:50-83`); `p.r.facts` is
   the current store. Parsing the facts and outline at an earlier rev lives only in
   `cmd/drafter/read.go:228-271` (`revisionAt`). `Scope` gains only ids. `w.Since` persists
   (`work.go:126`), so `git diff` rebuilds on resume, but old bullets don't. Fold: move `revisionAt`
   into `internal/blueprint` or `pipeline` and call it at stage time with `w.Since` and `state.Head`,
   so a resume rebuilds the same block; keep old/new texts off `Scope` (it serializes into
   `PageResult` and `--json`); make `read.go` and `read_test.go` unconditional in Files; name the git
   call `git diff --no-color --no-ext-diff <since> <head> -- <h.Plan>` via `r.gitOut`.
3. **CR.3's "expose, then remove" deletes the installed skill** (correctness). plan:123-124, from B2
   resolution 9. After #47 and `make install`, `~/.claude/skills/blueprint` points at
   `~/Projects/drafter/claude/.claude/skills/blueprint`; removing it after the test deletes the live
   skill. The test also needs the worktree's CR.2 `SKILL.md`. Fold: point the link at
   `<drafter wt>/claude/.claude/skills/blueprint`, confirm with `readlink -f`, and afterwards restore
   it to the main checkout (`ln -sfn ~/Projects/drafter/claude/.claude/skills/blueprint
   ~/.claude/skills/blueprint` or `make -C ~/Projects/drafter install`), never remove it.
4. **CR.2's first sentence already exists, and #3 and #4 close without evidence** (correctness).
   plan:71-74, 110-118, 137-138; `SKILL.md:16`, `:35`. `SKILL.md:16` already says "Run `drafter refs
   <fact-id>` before you correct a fact" (blame `97cf6d0`, present during B2's test, where the agent
   still used grep). CR.3's acceptance drops B2.4's per-row fields, among them "whether `refs` ran
   before the edit (tweak 2)" and "whether the skill fired". Fold: CR.2 changes the remedy for #3
   (for example, move the refs sentence to where the agent acts) instead of copying it; CR.3 keeps
   every B2.4 row field plus the two new columns; Close shuts #3 only if tweak 2's transcript shows
   `drafter refs` before the edit and #4 only if tweak 4 lands a `failure` item, else both stay open
   with the evidence.
5. **The failure-section link has no heading to point at** (correctness). plan:73, 115-117.
   `docs/blueprint-format.md` has no failure heading; the rule lives in the Items kinds table's
   `failure` row (line 150) and the catalog row "Add a failure case" (line 343). Fold: link
   `format.md#the-edit-catalog` and name the "Add a failure case" row, as `SKILL.md:17` does; state the
   acceptance as anchors within `format.md`.
6. **Proofs that pass on an empty fixture** (correctness). plan:102-104. The scoped pipeline harness
   sets `o.Since = h.head()` (`internal/pipeline/blueprint_test.go:357`), so the change block is an
   empty diff. The consistency tests don't name the blueprint answer; if it's `fix`, "escalates"
   passes on the wrong seat. Nothing tests `with`. Fold: a since commit earlier than head where one
   item and one fact bullet differ, asserting the hunk and both bullet texts are in the request,
   including after a resume; a non-empty `Scope.Facts` excluding the untouched conflict's facts; a
   blueprint answer of `ok` in both consistency tests, asserting the escalation names `consistency`;
   one case where only `with` is touched.
7. **The seeded control's patch is gone** (correctness). plan:80. B2.4 kept patches in
   `<drafter wt git dir>/b2-format-test.md`, deleted with the worktree. The control diff (the
   `s-interval` step) survives in B2's executor transcript,
   `~/.claude/projects/-var-home-glw907-Projects-drafter--claude-worktrees-b2-blueprint-skill/69b40c50-ef79-4971-9804-17db5aacf17b.jsonl`.
   Per #47's body, each prompt began "Use the blueprint skill." and ended "Commit the change." Fold:
   name the transcript as the control's source, or re-seed by B2.4's description and record the
   patch; state the prompt wrapper; keep this pass's patches outside the worktree git dir.

## Minor

8. **`--since` text and tests not listed** (correctness). `read.go:49-52` help says "any other change
   makes the page read as a whole"; `scopedAccept`'s comment (read.go:273) goes stale;
   `read_test.go:562-572` ("a whole accept under --since writes the lock") relies on a page-level
   change being whole; `read_test.go:242` asserts B2's paragraph text. Fold: list them in CR.1; keep
   the whole-accept proof with a blueprint absent at `<rev>`.
9. **The meter starts this pass at $0.90** (correctness). plan:30-33. `drafter spend --since 2026-10-18
   --json` shows `total` 3.1758 (20 requests), not $2.28; headless session cost (B2's $2.18) is left
   out though the design compares $10 with B2's $4.46. Fold: read the meter at launch as the baseline;
   say the sessions' `total_cost_usd` counts toward the $10.
10. **`Scope.Facts` and the block include facts the page never cites** (correctness). plan:48-49, 54.
    Fold: limit to facts the page places or cites, at either revision, whose bullet changed; match
    items by `id` (required and unique, `blueprint.go:91`).
11. **Conflict states unnamed** (correctness). plan:64-68. Empty `facts` with a `page#heading` `with`;
    fact ids not in the store; a mix of touched and untouched conflicts (does the escalation list only
    the touched and warn the rest?); a resumed run whose state predates `Scope.Facts`. Fold: one
    sentence per state; intersect `facts ∪ {with}` with `Scope.Facts`, no "is `with` a fact id" test.
12. **OWNER FORK: a conflict caused by a new or changed link** (correctness). plan:64-67. The
    consistency read checks placed facts against linked pages (`assemble/consistency.go:42-67`); a
    tweak that adds or retargets a `link` causes a conflict with untouched `facts` and a `page#heading`
    `with`, which the rule demotes. Options: (a) keep the approved rule with a "Later" entry (none of
    the five tweaks adds a link); (b) touched when `with`'s page is a link target the change added or
    altered. Recommend (a).
13. **"Harness unchanged" isn't literal** (correctness). plan:77-80, 35-37. `drafter-page-hook` is live
    in `~/.claude/settings.json` (line 93), so it runs in every tweak session; it wasn't in B2.
    `claude agents --json` lists background sessions only; the launch drops B2's `pgrep -f` on the
    worktree paths, which global CLAUDE.md requires. Fold: record the hook as a known difference;
    restore `pgrep -f`.
14. **The change block's framing** (optional). `internal/assemble/blueprint.go:19`'s `BlueprintBlock`
    opens "They are everything you read.", false once a change block follows; no delimiter may be a
    `=== file:` line. Fold: a wording note and the delimiter rule in resolution 2.
15. **A predictable result** (optional). The pre-existing conflict on four of B2's reads still
    escalates when a tweak's new item cites one of its facts (tweak 4 may). Fold: CR.3 notes that
    conflict's facts in advance.
16. **CR.2 is single-deliverable** (optional, about 5 min). Fold: a bullet of CR.1 or CR.3's
    pre-flight; the estimate doesn't change.
