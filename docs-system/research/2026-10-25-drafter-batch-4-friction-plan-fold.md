# Fold: drafter batch 4 friction plan, mechanics review

Folded 2026-10-25 against drafter `e41695f` and cairn-cms `origin/main` `75b6138`. Review:
`2026-10-25-drafter-batch-4-friction-plan-review-mechanics.md`. Targets: the plan and its executor
and conductor prompts in `../plans/`. Every finding was checked in source before it was folded;
the probes ran read-only, from the session scratchpad, and sent no signal to any process.

Path: 650 to 660 path minutes (1.32x the design's 500), task sum 945 to 1005. That is under the
1000-minute ceiling.

Incident note: the plan's Shared rules and the executor prompt now say no session or subagent
sends a signal by pattern, and a test or probe kills only PIDs it started. The conductor prompt
carries the same line.

## Dispositions

1. **Folded.** T5 #104 and its acceptance. Checked: `indexLink` (`internal/pipeline/check.go:331`)
   records each file it changes as `IndexPost` in the page's work record, and cairn's local layer
   sets `gate.index_link_command` to `cairn-docs-outline link`. I didn't take the review's
   `git status --porcelain` set: only `begin` calls `requireClean` (`start.go:135`), so a `--resume`
   tree may hold changes that aren't the run's. The commit takes `IndexPost`'s keys, exposed on
   `PageResult`. The e2e fixture sets an index-link command that edits a tracked file, and the test
   asserts that file is in each commit. T5 goes from 150 to 165.
2. **Folded.** T7 acceptance. I measured 30,295 bytes for the author part and 36,778 for the
   reference part, and the doc is 67,073 bytes today. T7's additions come to about 3,600 bytes,
   using the check table's measured 192 bytes a row. The bar is now 35,000, about 1,100 above the
   estimate. The measurement is written into the plan.
3. **Folded.** T7 acceptance loop: it now runs `git grep -nE "(^|[(/])(blueprint-)?format\.md#$a\)" -- ':!BACKLOG.md'`.
   Probed: with `outlineyaml` it finds `new-page.md:11`, and with `items` it finds nothing. The
   plan's wrong `format.md#items` claim is corrected in T7's #97 bullet.
4. **Folded.** T6 #109 has two new sub-bullets and stronger acceptance.
   - Raw text: `pageProseMap` blanks each stripped region with spaces of the same length, then
     normalizes rune by rune and keeps each rune's raw offset. `pageProse` wraps it, and a test pins
     its output. A span is widened over `*`, `_`, and backtick characters, and whitespace is
     collapsed.
   - Splitting: the text also splits at list-item and paragraph starts. A bare `2.` is dropped
     through `hasContent`, and a marker is trimmed as `Check` trims one.
   - The JSON form: sync writes nothing when nothing changed. Otherwise it splices the `sentences`
     span, found with `json.Decoder.InputOffset`. Kept entries are copied verbatim, and new entries
     are encoded from a `text`-then-`id` struct with `SetEscapeHTML(false)`. A probe on cairn's
     add-an-island brief (132 sentences) rebuilt it byte for byte. A struct probe printed
     `{"text":"a <name> b","id":null}`.
   - The C.2 check uses the review's `jq -c '.sentences[]'` diff.
   - T6 goes from 90 to 140.
5. **Folded, option (a), per the planning session's ruling.**
   - In T1 #89 and C.5's `## Decisions`, the error now also fires in `drafter gate`
     (`gate.go:135`) and in `drafter page` stage 1 (`check.go:144`, `pipeline/blueprint.go:99-111`).
   - Standing answer 3 adds a precondition: cairn's outline must list `upgrade-cairn.md` and
     `choose-an-ai-posture.md`. Until it does, STATUS says the install waits.
   - Verified on `origin/main`: #56 is open and carries `choose-an-ai-posture` (and
     `docs/reference/sveltekit.md`) but not `upgrade-cairn`. The hand-over now appends
     `upgrade-cairn` and `share-a-draft-preview` to #56.
   - The plan's scan of covered directories finds the same three unlisted pages. Nine blueprints
     link them:
     - `upgrade-cairn.md`: architecture, add-a-second-sign-in-group, add-cairn-to-a-sveltekit-app,
       debug-your-site, restrict-admin-access, scaffolded-site-files, and
       using-claude-code-with-cairn.
     - `choose-an-ai-posture.md`: build-the-public-routes, define-an-adapter-and-schema, and
       scaffolded-site-files.
     - `share-a-draft-preview.md`: no blueprint.
   - The inbound-anchor error and the `page-drift` warnings also run in `gate`. That is stated in
     T3 and in `## Decisions`.
6. **Folded, in a different form.** T3 #88. I checked the review's narrowing and it would miss
   real published links. Six `docs/reference` pages link `../extend/*.md#...`, and
   `docs/reference` is not a directory the outline covers. The fold grades instead:
   - an error from other blueprints and from pages in covered directories;
   - a warning from every other tracked `.md`, which covers `CHANGELOG.md:1199/1327/2891`, the
     records, and the reference pages.
   The acceptance gains a `CHANGELOG.md` warning case.
7. **Folded.** Standing answer 3, "Merge order and hand-over", and the conductor prompt. The pull
   waits on the same three conditions as the install. Until then STATUS reports the checkout
   stale, which pass-core "Close" (line 286) allows. The hand-over's STATUS merge no longer pulls.
8. **Folded.** The conductor prompt and the plan's hand-over now name the push target:
   glw907/cairn-cms, `git push origin HEAD:main` from the worktree. Checked: `log-issue` step 6
   and pass-core "Execute" line 181.
9. **Folded.** T4 #91 gets a separate `noticeLabel` regex and branch. Checked: the `formLabel`
   branch strips the label, reads `:source`, and sets `formAt` (`markdown.go:300-314`), and
   `isForm` shares the regex (`:387-392`).
10. **Folded.** T5 acceptance names the fixture: a copy of `count-items.blueprint.yaml` under a
    second slug, listed in the outline. `setAnswer` covers any answer that names a path.
11. **Folded.** In C.2, the planted line's proof greps the output for the unlisted-target message
    at the line's number.
12. **Folded.** T4 is marked `runner`, and the risk-class paragraph says why.
13. **Refused** (optional). This was a rerun rule for a `chain-test` red caused by workstation
    changes. The existing gate re-issue and the stop path cover it, and the case is hypothetical.
14. **Folded** (optional, one line). T4's file list names `tests/docs-page-chain-blueprint.test.mjs`.
    The assertions are near line 307.
15. **Folded.**
    - #102: its move to cairn's backlog stays a `## Decisions` row, as before, and now also appears
      in C.5's list.
    - Decorators: cairn's function is `resolveSymbolDeclaration`, and its start is the node's
      `getStart`. A probe with TypeScript 6.0.3, cairn's version, shows that range includes
      decorators and leaves out the doc comment. T2 #85's range now starts at the decorator run
      and stops before comments, and the acceptance gains a decorator case. I also corrected the
      plan's `resolveSymbol` name.
16. **Folded.** The executor prompt's pair dispatch names `effort: "medium"`.
17. **Folded, partly.** T7's own `prose-voice-reviewer` read is dropped, and C.3's read stays.
    T7 goes from 120 to 115.
18. **Folded.** T0 becomes the first pair's opening step. Its 5 minutes stay on the path.

## For the approved design (listed, not applied)

- #88: the design says links from "published pages" are errors. The fold makes a link from a
  file outside the outline's covered directories a warning, such as cairn's `docs/reference` pages
  and `CHANGELOG.md`. Standing answer 4 allows a smaller form, and `## Decisions` records it.
- #89 and #88 in `drafter gate`: the design says "`drafter gate` is unchanged, so a page run never
  stops on a fact problem". That sentence is scoped to #84, but the unlisted-link and
  inbound-anchor errors now do stop `gate` and `drafter page` stage 1. The planning session ruled
  that this follows the design's "error, in named and unnamed runs", and the install is held on
  cairn's outline.
