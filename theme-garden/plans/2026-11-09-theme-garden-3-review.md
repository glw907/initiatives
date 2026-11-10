# G3 plan review: mechanics and feasibility

Reviewer: `standards:plan-reviewer` (Opus, medium), 2026-11-09, read against cairn-cms `68eb92ecf`.
Plan: `2026-11-09-theme-garden-3-plan.md`. Each finding's fold is in the right column.

## Confirmed

The #412 selectors tie `tokens.css`'s rules (`build-tokens.mjs:323-327`) and win on link order
(`+layout.svelte:69-72`); the mode pin (`build-tokens.mjs:394`) still outranks them. Waymark has no
`options/`, so its `--check` and the equivalence fixture don't change, and the admin's `data-theme`
wrappers use `cairn-admin` names. The viewer and `check.mjs <dir>` render a directory outside the
catalog (`viewer/site.mjs:61-66`, `check.mjs:117-118`, `check-render.mjs:37`). Flags, rule ids, and
the path sum (910) are correct. Survey is public at `79efb98`.

## Findings

| # | Tag | Finding | Fold |
| --- | --- | --- | --- |
| 1 | blocker | `theme-contract.mjs:109` finds the option light rule by `:where(:root)`; the fix silently drops light option values from `tokens-required` | T3.1 changes the matcher to `:root,`, adds a contract test, and widens the grep to `scripts docs skills BACKLOG.md` |
| 2 | blocker | T3.4's viewer run fails: the layout imports `#theme/theme.css` and `site.css`, which T3.5 writes | T3.4 writes a stub `theme.css` and an empty `site.css` |
| 3 | blocker | Pair A both write `cairn-theme.json`; T3.3's `fonts` rule needs the manifest | T3.3 writes `fonts/**` only and returns the entries as text; T3.2 runs after both and runs the rule |
| 4 | fix | `resolve()` reads only `light` and `dark` groups of an option context (`build-tokens.mjs:180-184`) | "Calls settled here" states the shape for `map-detail` |
| 5 | fix | A fixture token in a Tailwind namespace or with `pub.cairn.unlayered` would pass the red test vacuously | Fixture token named outside the namespaces (`opts-rule-style`), no mark |
| 6 | fix | The test misses the mode pin's `var(--cairn-opt-...)` path | The composed-sheet loop (`build-tokens.test.mjs:459-480`) covers the token |
| 7 | fix | "`text-step-1` to `-13` absent" contradicts the reading scale on the same names | Steps 1 to 5 carry reading values; 6 to 13 and `text-step-inline-code` absent |
| 8 | fix | T3.6's screenshots predate T3.8's changes | Screenshots move to Close |
| 9 | fix | Survey's `render` adds about 13 minutes to a 45-minute job that ran 25 | T3.6 times it and raises `timeout-minutes` under a 5-minute margin |
| 10 | fix | The MIGRATION note named the wrong case | Overrides of an optioned token are written on `:root,:root[data-theme]` |
| 11 | fix | T3.8's commands and the post route weren't written out | Full viewer commands; the every-element starter post |
| 12 | note | T3.0 is ceremony; T3.5's separate headless run repeats `render` | T3.0 folded into T3.1; T3.5's run dropped |
| 13 | note | Rerun the docs gate after review fixes; a severity floor on delta rounds; CI verdict in runner reports | Taken (Close, T3.8, T3.6) |
| 14 | note | Name the worktree setup the viewer needs | T3.4 names it |
| 15 | note | T3.7: `timeout-minutes`, an injectable fetch, the `test:theme` glob | Taken |
