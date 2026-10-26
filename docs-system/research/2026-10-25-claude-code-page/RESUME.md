# The Claude Code page

Attended run on `pavilion`, started 2026-10-25. It drafts the one blueprint with no page,
`blueprints/docs/claude-code/using-claude-code-with-cairn`, registers the `claude-code` arm in
the gates, and adds the arm's track entry to `docs-register.md`.

## State

- Worktree `.claude/worktrees/claude-code-page`, branch `claude-code-page` off `main` at
  `7ae6fe87d`, with `drafter.local.toml` copied from `~/.config/drafter/cairn-cms.local.toml`.
- Track entry drafted at the session scratchpad's `track-entry.md`; applied after the arm
  registration commits.

## Done

- Tools current: drafter installed at `12b8c02` (drafter's `main` head; STATUS updated in
  drafter `90eabef`). approval-queue's checkout matches `origin/main` (`0a182ba`) and its build
  postdates the last source change.
- cairn-cms `7ae6fe87d` on `main` (direct change, docs gate green): BACKLOG #56, #67, #68.
- `4369cef64` on the branch: the page's 19 cited fact pointers anchored (drafter's suggestions
  replaced where weak), and the blueprint's precondition link to the add-cairn tutorial loses
  its anchor.
- Arm registration dispatched to a `cairn-implementer` (Opus) in the worktree.
- Arm registered in `59ceef08b` (implementer; gates, `package.json` `files`, tests; fast lane and
  docs gate green). Track entry in `3f846388b` (also CLAUDE.md's track list and
  `docs/internal/README.md`). Arm index `docs/claude-code/README.md` in `5a91f5f38`: it links the
  page before the page exists, since the index and the page must land together and drafter gates
  only after drafting. `Claude Code` added to Vale's vocabulary (`c02fdefea`).
- The blueprint was never approved: it predates the queue (last reshaped 2026-10-19) and
  `decisions.jsonl` holds no decision for it. Fresh fact-check dispatched at `59ceef08b`
  (findings under `.../blueprints__docs__claude-code__using-claude-code-with-cairn.blueprint.yaml/`);
  then settle, then `approval-queue blueprint`, then draft.
- Fact-check at `59ceef08b`: 59 hold, 6 imprecise, 0 wrong; settled in `a1f028a69` (plus the
  upgrade-cairn cross-link by path, and `skills/cairn-public/SKILL.md:1-2`). Blueprint queued
  17:43 (item `20261025T174353-51689`; decision to `decision-blueprint.json` here). Don't push
  to the branch while it is queued. On approve: `drafter page` on the blueprint (a new page, so
  whole), fact-check, register edit, settle, then the PR and `approval-queue page`.
- Geoff rejected the blueprint (17:5x): "The blueprint is in the old yaml format and needs updated
  to markdown." `drafter convert markdown` ran; it dropped argument, orderReason, preconditions,
  constraints, dispositions, five code sources, and six failure causes. An Opus agent is carrying
  them into the Markdown file in the worktree; then re-queue. Four of the six redraft blueprints
  are also YAML (restrict, second-sign-in, add-cairn, scaffolded): convert each after its redraft
  lands (convert refuses a stale lock entry), same hand-carry. The other YAML blueprints on
  `main`: debug-your-site, rotate-the-github-app-key, security-model.
- Conversion finished in `33d1dfdc7` (Opus agent; named check 0 errors, docs gate green with the
  one expected pending link). Six causes written from facts; ~15 fact bullets re-scoped to their
  YAML `use`. Fresh recheck of the changed claims dispatched (findings under
  `.../blueprints__docs__claude-code__using-claude-code-with-cairn.blueprint.md/33d1dfdc7.json`);
  then re-queue with an updated description. Geoff's suggestion filed as drafter #115 (validate
  format and components); converter drops as #116 (`dd581fb`, `2199cef`).
- Recheck at `33d1dfdc7`: 57 hold, 3 imprecise; settled in `0c6ac3847` (tags to Cause lines,
  `.orig` row on the reference, `f:guiavc` dropped as the YAML ruled). 59 sentence-length
  warnings (the approved models carry 12 and 1); an Opus agent is splitting them with tags,
  links, and code spans held identical. Then re-queue.
- Split in `4a6cc2311` (59 to 0 sentence-length; tags, links, code spans identical), the
  `, which` run listed in `75488abf0`, the reader block's stale "no register track" fixed in
  `7819c112f`. Re-queued 18:09 (item `20261025T180929-68017`, decision to
  `decision-blueprint-r2.json`). Don't push to the branch while queued.
- Geoff rejected r2 ("The hard line breaks are causing strange wrapping issues."): unwrapped to
  one line per paragraph and bullet (`641155daa`, text identical apart from whitespace).
  Re-queued; Geoff approved r3 (blob `f39a470d1`, commit `641155daa`).
- The redraft run stopped at drafter's October ceiling ($200; cycle total $194.82, including
  $16.15 of drafter's 2026-10-19 acceptance-test batches). Geoff: "In the meantime, you can just
  use regular tokens." So drafter's API is out until November 1; the rest runs on session
  agents. add-a-custom-admin-screen was accepted by drafter before the stop and is committed on
  `redraft-prep` (`d4f576d7d`, docs gate green; no lock entry). The run
  `20261026T014209Z-39411e00` is abandoned, not resumed. The other five redrafts and the Claude
  Code page are drafting via `cairn-docs-drafter` agents, one worktree each
  (`.claude/worktrees/rd-<slug>` off `d4f576d7d`; the Claude Code page in `claude-code-page`).
  Fact-check and register edit of the admin-screen page dispatched.
- Architecture drafted (`f7fa2a065` on `rd-architecture`, gate green); four departures from its
  blueprint (three names no tagged fact carries, one self-contradicting hand-off). Fact-check
  (ruling on each) and register edit dispatched. Admin-screen settler running in `redraft-prep`.
- Architecture register: 18 findings, 3 blocking (`register-architecture.md`); settle waits on
  its fact-check. Restrict drafted (`614cf2ca3` on `rd-restrict-admin-access`, gate green, the
  three #71 errors absent); fact-check and register edit dispatched.
- Scaffolded drafted (`74e9f8aa6` on `rd-scaffolded-site-files`, gate green, tree without the
  Deploy-button files); fact-check and register edit dispatched.
- Architecture fact-check: 83 holds, 5 imprecise; rulings: `./package.json`, `defineFieldset`,
  `@glw907/cairn-cms-dev` go back on the page via fact edits; the blueprint's "every action that
  changes content travels one path" is false (only save and revert use a holding branch) and is
  corrected under the Fix rule. Settler dispatched in `rd-architecture`. The check surfaced an
  engine defect, verified and filed as BACKLOG #74 (`e260728ad` on main): media replace leaves
  the content manifest's `mediaRefs` on the old hash, so the delete gate sees the new asset as
  unused.
- Claude Code page drafted (`3aeac6882`, then `542262e03`: leak-check comment, retired
  `plan.yaml` dropped; gate green). Three clauses left out for lack of a tagged fact; fact-check
  (ruling on each) and register edit dispatched.
- Admin-screen settled (`ae7a08353`) and its nested-route note aligned with restrict's
  governing-key method (`891546899`, gate green); recheck dispatched. Restrict register: 26
  findings, 6 blocking (`register-restrict.md`); settle waits on its fact-check. Second sign-in
  drafted (`2e8e7a827` on `rd-add-a-second-sign-in-group`, gate green, three uncited blueprint
  names left vague); fact-check and register edit dispatched.
- Scaffolded register: 28 findings, 2 blocking (`register-scaffolded.md`); B2 is merge order:
  the page links the Claude Code page, so the claude-code-page PR merges before the redraft PR.
  The "Deploy-button tree" naming is questioned (the template README says the button doesn't
  exist yet); the settle rules on it against the code. Settle waits on its fact-check.
- Restrict fact-check: 82 holds, 5 imprecise, 1 unsupported; settler dispatched (three fact
  edits from the rulings). Scaffolded fact-check: 103 holds, 6 imprecise, 4 unsupported; settler
  dispatched (rules on the "Deploy-button tree" name). Claude Code page: fact-check 96 holds, 4
  imprecise (three left-out clauses true, fact edits proposed); register 26 findings, 8 blocking;
  settler dispatched. B7 (the -ing title "Using Claude Code with cairn") is declined in the
  settle: the title is set by the approved blueprint and outline and matches the slug. Raise it
  in the page's review notes as Geoff's call (rename would touch the slug, outline, README, the
  scaffolded page's link, and the blueprint).
- Admin-screen recheck: 47 holds, 4 imprecise (three page wordings, plus the blueprint never
  synced). Finisher dispatched: the three fixes plus a blueprint sync. Every settled page gets
  the same sync (YAML blueprints too, so the November conversion carries the fixes).
- Architecture settled (`397a290c4`, gate green; facts f:533flu, f:i87sd3, f:f21bcz, f:e69d0l
  edited; blueprint L118 corrected); recheck dispatched, then a blueprint sync (the settler names
  three more blueprint lines a redraft would undo: L158, L199, L234/236). Add-cairn drafted
  (`e894e08e3`, 1353 lines, gate green); fact-check and register edit dispatched. #74 extended
  (`ae7979b0d`): likely build failure on manifest drift after a replace.
- Second sign-in register: 26 findings, 5 blocking (`register-second-sign-in.md`); settle waits on
  its fact-check. Shared ruling for restrict and second sign-in, verified in
  `migrations/0001_roles.sql`: the rebuild keeps every row but only four columns; precondition
  "if your site added `editor` columns, add each to `editor_new` and the `INSERT … SELECT` in
  your copy before applying it" (sent to the restrict settler; give the same to second sign-in's).
- Admin-screen DONE (`38ce9ccab` on `redraft-prep`): recheck fixes plus blueprint synced to the
  page (drafter check 0 errors, gate green). The page's review notes must say the blueprint
  changed after approval, with the list of changes (the finisher's report). Second sign-in
  settler dispatched with the blueprint sync folded in (fact-check 79 holds, 3 imprecise; three
  rulings hold, new facts for `auth.channel.requested`, `auth.channel.send_failed`, `challenge`).
- Architecture recheck: 46 holds, 3 imprecise (figure's "on each request", two fact lags), 35
  drift places; finisher dispatched (fixes plus blueprint sync). Claude Code settled
  (`461b7aeef`; f:vufjc3, f:ohxg28 minted; B7 title declined, owner's call); recheck dispatched
  with two gap rulings (Tailwind `.claude/` exclusion step, `pre*` scripts overwrite). Scaffolded
  settled (`59e6b58fd`; six facts edited; Deploy-button tree renamed to `templates/waymark/`);
  recheck dispatched. Add-cairn register: 28 findings, 4 blocking; settle waits on fact-check.
- Architecture DONE (`5986a38e4` on `rd-architecture`): figure fixed, f:f21bcz, f:pgy0mr,
  f:b6gquz tightened, blueprint synced (drafter check 0 errors, gate green). Integration
  to-do: fix f:lccuuc's stale pointers (`reference.md:229`: `0000_channel.sql:19-46` anchorless,
  `provisionSalt` not near `store.ts:60-84`) and the three drifted anchors in `facts/extend.md`
  (lines 14, 50, 51), then run the whole docs gate on the integrated branch.
- Restrict settled (`a891e967f`; f:3z48zf, f:qca0t0, f:8ciz2s, f:rn62i1 edited; shared
  `editor`-table precondition in); recheck dispatched. Its finisher must move `webmaster` to the
  brief's `local` list and drop the borrowed f:2dgbff citations, then sync the blueprint.
  Add-cairn fact-check: 105 holds, 3 imprecise; settler dispatched with the sync folded in.
- Claude Code recheck: 51 holds, 9 imprecise; gap (a) a conditional Tailwind-exclusion step
  (scaffold already carries it), gap (b) a caution on merging `pre*` scripts. Found an engine
  defect, verified and filed as BACKLOG #75 (`8045cb292`): `cairn-guidance check` accepts only
  the literal `@source not "./.claude";` in the two admin stylesheets, which in `src/` excludes
  `src/.claude`, so its advice is wrong. Finisher dispatched (fixes, two steps, caution, sync).
  The Claude Code blueprint was approved before; its review notes list every change.
- Scaffolded recheck: 53 holds, 6 imprecise, 1 "unsupported" overruled (Workers Logs rests on
  f:prb2os, a Cloudflare doc source); 33 drift places. Finisher dispatched (fixes plus sync,
  f:u705t5 cut disposition for Topo).
- Restrict recheck: 56 holds, 7 imprecise, 2 "unsupported" (rulings were in the dispatch, not
  the findings file; the borrowed citations); 36 drift places; caught two sibling pages off their
  edited facts (debug-your-site.md vs f:8ciz2s; second sign-in's unconditional copy step vs
  f:rn62i1). Finisher dispatched on `rd-restrict-admin-access` (fixes, `webmaster` into `local`,
  debug-your-site lines ~238/252 and its blueprint, restrict blueprint sync). Second sign-in
  settler told to make its copy step conditional.
- Second sign-in settled and synced (`ed0ef55fd`; f:7cot0m, f:tx48wk, f:am6hhb, f:2ihgrk added;
  f:rn62i1 edited identically to restrict's); recheck dispatched.
- Scaffolded DONE (`69ec34a90` on `rd-scaffolded-site-files`; f:n2skkz, f:vrue1g, f:3m0oxs
  edited; blueprint synced, drafter check 0 errors, gate green). Integration to-do: drop the Topo
  clause from f:u705t5 (`front-door.md:67`) and remove its ROADMAP.md bullet (~line 1086, the fix
  ships); reword f:nls26c's "Deploy-button tree" to the `templates/waymark/` copy.
- Add-cairn settled and synced (`58057072e`, gate green, drafter check 0 errors); recheck
  dispatched. Questions for Geoff collected so far: (1) the Claude Code page title's -ing form;
  (2) a Names entry for Waymark (template vs theme); (3) "the App" for the GitHub App (add-cairn
  register N24).
- Claude Code DONE (`4d3572735` on `claude-code-page`; f:7jn3wz, f:6jtwh2 minted, f:vufjc3,
  f:qzsspl edited; Tailwind step, `.orig` step, commit step, `pre*` caution; blueprint synced,
  drafter check 0 errors, gate green; the page carries no BACKLOG reference). Second sign-in DONE
  (recheck 54 holds, one drift trimmed in `ce0da3da4`, drafter check 0 errors).
- Restrict DONE (`49137969f`; `webmaster` in `local`, borrowed citations gone, debug-your-site
  lines ~238/252 aligned with f:8ciz2s, both blueprints synced; restrict drafter check 0 errors).
  Follow-up: debug-your-site's blueprint cites facts with 27 old anchorless or drifted pointers
  (main shows 33): facts/extend.md 407-416, 662, 1225-1229; front-door.md 120; reference.md 1239,
  1243, 1325, 1746; some drifted (`content-routes-settings.ts:151,168`, `admin-action.ts:33-38`).
  An anchoring pass, not this batch.
- All seven pages DONE. Add-cairn finished (`12f5f8310`). PR 1 = #143 (`claude-code-page`, head
  `86d29c63b`, whole docs gate green, CHANGELOG entry, `## Brief` on the body). Claude Code page
  queued 19:15 (item 20261025T191514-1152377, decision to `decision-page-claude-code.json`; one
  decide note N1, the title). Do not push to #143 while queued. On approve: wait for CI, then
  `gh pr merge 143 -R glw907/cairn-cms --merge --match-head-commit <head>`.
- PR 2: six redrafts merged into `redraft-prep` (`96a30e558`; two facts conflicts resolved: f:m4y3m4
  anchor, f:rn62i1 plus f:pkrwom). Integration agent running: merge origin/main, f:u705t5 (Topo)
  and its ROADMAP bullet, f:nls26c, f:lccuuc pointers, drifted anchors, CHANGELOG entry, whole
  gate. Then: push, PR, `## Brief`, notes and descriptions for six pages, queue each.
- Lock and format follow-ups for November (drafter's API back): none of the session-drafted
  pages has a `drafted.lock` entry, and four redraft blueprints are still YAML (restrict,
  second-sign-in, add-cairn, scaffolded). `drafter convert markdown` refuses a stale lock entry,
  so the order is `drafter read` and `drafter seed` (or a scoped `drafter page`), then convert
  with the hand-carry, then a format-only blueprint review if Geoff wants one.
- Prep for the six finished: `29723f014` (397 anchors, 296 chosen over drafter's suggestion),
  `c48709373` (format fixes), and the session's `5abe05dab` (six drifted pointers re-pointed,
  `f:4bazhe` and the restrict symptom corrected; docs gate green). The six redrafts launched
  under `setsid -f` with `--whole --commit` on `redraft-prep` (log `redraft-run.log` in the
  session scratchpad; draft stage worst case $12.59).
- Geoff (2026-10-25): after the Claude Code page, redraft six #71 pages as one batch:
  restrict-admin-access, add-a-second-sign-in-group, add-a-custom-admin-screen,
  add-cairn-to-a-sveltekit-app, scaffolded-site-files, architecture.
- Prep for the six dispatched to a second `cairn-implementer` (Opus) in worktree
  `.claude/worktrees/redraft-prep` (branch `redraft-prep` off `4369cef64`): anchor the cited
  pointers and fix the blueprints' format and link errors so each passes a named `drafter check`.
- #71 audit of the six blueprints: only restrict-admin-access needs a content change. Its
  `x-role-unknown` symptom says "refused on every screen", but `/admin` shows the welcome view
  (`content-routes-shell.ts` `indexLoad`; `f:kqcyv1`). The error comes from `f:4bazhe` ("refuses
  it on every admin target"). After the prep commits: sharpen `f:4bazhe`, correct the symptom and
  cite `f:kqcyv1`, then queue the blueprint change for Geoff before drafting. The other #71 items
  are page-only (each blueprint already says the right thing), so a redraft fixes them.

## Friction

1. Listing `docs/reference/sveltekit.md` as `managed: false` (BACKLOG #56's ask) made drafter
   treat all of `docs/reference/` as outline-covered: 200-odd links into the reference arm
   became unlisted-link errors. Dropped the entry. drafter: an outline entry should cover its
   own path, or the coverage rule should be documented and the check should name it.
2. `drafter check` resolves a cross-page anchor against the target's blueprint, and the docs
   gate resolves it against the published page. When the two disagree (the add-cairn tutorial,
   BACKLOG #71), no anchor satisfies both, so the link had to drop its anchor.
3. drafter's suggested anchors stay weak (`for`, `const`, `Every`, `claude`, `cairn`): 7 of 19
   needed a better pick (drafter #111 already tracks it). For JSON and front-matter pointers it
   suggests nothing.
4. A fact's existing parenthesized anchor in prose form (`f:1kwkl0`, a code expression in
   backticks) reads as anchorless; the format accepts only a bare name.
5. The main checkout has no `node_modules`, so the unnamed `drafter check` there reports 186
   false missing-file errors for `node_modules/...` pointers. Run it in a worktree with deps.
6. Installing the batch 4 build turned every existing blueprint but one red on a named
   `drafter check`: the new `anchorless` error fires 20 to 120 times per extend blueprint
   (add-an-island is the only clean one). `drafter page` does not block on it, but the
   blueprint skill's commit rule does, so any blueprint edit now carries an anchoring sweep.
   drafter: a release that raises a warning to an error wants a migration note or a
   `--fix` that writes the suggested anchors for review.
7. Each gate keeps its own hard-coded arm list (about eight places), so registering an arm is
   hand edits across scripts; a missed list fails silently. `verify-harvest.mjs` imported
   `ARM_NAMES` and would have widened a frozen record (implementer decoupled it). cairn: derive
   the lists from `ARM_DIRS`.
8. An arm can't take its first page without its index (`check:arm-indexes`, `check:package`),
   and nothing in ROADMAP's arm-stage text says so.
9. `approval-queue approved` keys on path plus blob, and every approval on record names a
   `.blueprint.md` path. Blueprints converted to `.blueprint.yaml` since then read as never
   approved, so the check can't tell a converted approved blueprint from one that was never
   reviewed (the Claude Code one).
10. A worktree set up with the root `npm ci` lacks the showcase's dependencies, so the fast lane
   fails five checks until `npm ci --prefix examples/showcase`. The worktree setup command
   should install both.
11. `approval-queue anchors` prints nothing for a `.blueprint.yaml`, so a YAML blueprint's notes
   anchor only by quote.
12. Anchoring a drifted pointer without moving its range locks the drift in: 6 of 397 pointers
   cited lines unrelated to their claim, and the anchor check passed on whatever word sat
   there. Nothing flags a pointer whose lines don't show its claim. Seven more cite a blank or
   `{` line, so any anchor lands off-line as a warning.
13. A parenthetical that opens with a code span (``(`x`, `y`)``, ``(`path`: commentary)``) reads
   as an anchor and fails, and a path-shaped one is then taken as a pointer (the admin.md:59
   store error). drafter's format doc never says the comma and prose forms fail.
14. A `links` error is reported only under the target blueprint's named run, not the blueprint
   that holds the link (rotate-the-github-app-key's `#devvarsexample`).
15. Outline cross-links to reference pages warn ("names no page the outline lists") because the
   reference arm can't be listed (item 1): four such warnings on `main`, now permanent noise.
16. Nothing told the session the YAML blueprint format is retired for review: drafter reads and
   checks YAML without a warning, the skill drafts from either, and the converter is a manual
   step. The session queued a YAML blueprint and Geoff rejected it for format alone. drafter:
   a `convention` warning on a `.blueprint.yaml`, or the skill's queue step requiring Markdown.
17. `drafter convert markdown` drops content the Markdown format can hold (constraints, code
   sources) along with fields it can't, so every conversion needs a hand-carry against the YAML.
18. YAML blueprints never met the sentence-length check (it reads Markdown prose only), so a
   converted blueprint arrives with every long sentence at once: 59 here. The conversion also
   moved fact tags onto Fix lines, against the blueprint's own constraint.
19. The approval app renders a blueprint's hard line breaks literally, so a wrapped blueprint
   reads with mid-sentence breaks; drafter's converter and the split pass both wrapped at ~100
   columns. Nothing in drafter or the format doc says blueprints are one line per paragraph.
20. drafter's billing-cycle ceiling counts its own acceptance-test batches ($16.15 this cycle)
   against the project's budget, and a multi-page run stops mid-page at the cap. A dry run
   reports the stage's worst case but not the headroom left in the cycle.
21. A session-drafted page cannot name a thing no tagged fact carries, even when the blueprint
   names it (`./package.json`, `defineFieldset`, `@glw907/cairn-cms-dev` on Architecture): the
   provenance check fails the sentence, so the drafter drops the claim and the page departs from
   its approved blueprint. The blueprint author should have tagged a fact for each name; drafter's
   check doesn't flag a blueprint bullet that names code no tagged fact carries.
22. A blueprint can contradict itself across sections (Architecture's "every action that changes
   content travels one path" against its own Concurrent writes section), and only a drafter
   notices.
23. The brief needs every table cell as a separate entry; the Architecture drafter scripted it.
24. The agent drafter's definition says to link every subordinated fact's reference page, while
   a blueprint lists its links exactly; the two disagree on restrict-admin-access.
25. Session drafters again reached for `snippet-check-skip` on an excerpt (restrict), the marker
   BACKLOG #73 wants retired; they typechecked by hand in a scratch file instead.
26. Plan-supplied section openers run past the 26-word cap (three on restrict); the drafter may
   not change them, so the gate's cadence rule and the blueprint disagree.
27. `check:symbols` resolves a path only against the repo root and `templates/waymark`, so a page
   can't name a showcase-only file by its path (`src/lib/env-check.ts` on scaffolded-site-files).
28. A pending link to an undrafted page passes only while `docs/internal/outlines/claude-code.json`
   names it; the outline deletion (2b part 2) would turn it red if it lands before the page.
29. `check:symbols` has no allowlist entry for site paths that cairn code reads but neither the
   repo nor the template holds (`src/theme/admin.css`, read by `src/lib/guidance/check.ts:29`).
30. The provenance check fails a code-font file name no cited fact carries (`check-cairn.json`,
   `cairn-audit.config.json`), and a number inside link text, while it skips the link's code
   spans; drafters reword around it.
31. A stale tier comment in `check-leaks.mjs` led the Claude Code drafter to doubt the new arm was
   scanned (it is, at line 485); fixed on the branch.
32. `drafter brief --sync` matches old short entries (table header cells) as substrings of new
   sentences, fragmenting them, and rewrites a compact brief as spaced JSON.
33. Two drafted pages each picked a different true fix for the shadowed dynamic-segment case
   (map entry vs governing `target`); nothing cross-checks sibling pages built from one fact
   (f:lmtfkt). Aligned by hand in `891546899`.
34. `check:snippets` resolves `cloudflare:workers` but has no types for it, so any snippet that
   imports it needs a skip marker.
35. The settle step edits the page and leaves the blueprint on the old wording, so a later
   redraft from the blueprint would reintroduce every fixed error (the admin-screen recheck caught
   it). Nothing in the chain writes reviewed corrections back. Added a per-page "blueprint sync"
   step after each settle this run; the chain (and drafter, which owns the blueprint as source)
   needs it as a standing step or a check that a page's facts and steps match its blueprint.
36. Fact anchors drift silently between store refreshes: the admin-screen finisher saw three
   drifted anchors in `facts/extend.md` (lines 14, 50, 51: `AdminTable.svelte:189`,
   `ManageEditors.svelte:18`) that no gate on this page caught.
37. A settle that edits a shared fact can leave another page's sentence saying more or less than
   its fact; only the whole-docs gate at integration catches a provenance break, and nothing
   catches a meaning change.
38. The page-edit hook ("change the blueprint, not the page") fires on every settle, against a
   dispatch that forbids blueprint edits; the two need one rule (settle, then sync).
39. A figure's accDescr and edge labels are not brief sentences, so neither provenance nor the
   first fact-check covered them; only the recheck caught the Architecture figure's overreach.
40. A Vale-style anchor with backticks inside (`never \`AUTH_DB\``) fails drafter's anchorless
   check; anchors must be plain text.
41. The provenance check treats a page's invented example name in code font (`webmaster`) as an
   unsourced identifier; the restrict settler borrowed an unrelated fact's citation rather than
   using the brief's `local` list. Settlers need the `local` list named in their brief.
42. Agents share one scratchpad root and overwrite each other's scratch files (`brief-orig.json`,
   `facts.txt`); each dispatch needs its own scratch subdirectory.
43. Fact-checkers mark a claim backed by a fact whose Source is a published vendor doc URL as
   "unsupported" because no repo code shows it; the checker's definition should accept the store's
   external-source facts (f:prb2os, Workers Logs).
44. A register editor's proposed fix can carry a code claim of its own (second sign-in B2 assumed
   a build writes `site-facts.json`; only `npx cairn-manifest` does). Register fixes need the same
   verify-against-code step as fact fixes before a settler takes them.
45. Facts edited on parallel branches must stay byte-identical to merge (f:rn62i1 on restrict and
   second sign-in); a fact edit belongs on one branch, or the integration step reconciles.
46. A subordinated disposition puts a link on the page that the blueprint never shows as an item,
   so cutting the link means hunting the disposition by hand (add-cairn: five turned into cuts).
47. The register's Names section has no Waymark entry; facts say "template", pages say "theme",
   add-cairn now says "cairn's reference reading theme". Geoff's question.
48. Fact-checkers number brief sentences from 0, the gate from 1; finishers mix them up.

## 19:22 state

- PR #144 (`redraft-prep`, head `25c49090f`): integration done (`fae1aca1b`), public-template clause
  dropped (`50d115a3a`), BACKLOG #76 filed. Whole docs gate, check:facts, check:comments green.
- Six pages queued 19:22 on #144, items 20261025T192207-1165935 (admin-screen),
  ...192209-1166140 (architecture), ...192211-1166361 (restrict), ...192213-1166556 (second-group),
  ...192215-1166728 (scaffolded), ...192217-1166894 (add-cairn; decide N2 Waymark, N3 "the App").
  Decisions to `decision-page-<key>.json`. Don't push to #143 or #144 while queued.
- Merge order: #143 first, then merge main into #144 if needed, then #144.
- drafter/approval-queue friction is filed by approval-queue-fd (drafter #117-#133, aq #53); tell it
  when this run's tool use is done. Still to file at close: cairn items 7, 8, 10, 25, 27, 28, 29,
  31, 34, 47 (BACKLOG) and agent items 24, 43, 48 (dotfiles agents).

## 19:41 state

- #143 MERGED as `f099f2356` (Geoff approved; chose "Rename it": page is now
  `docs/claude-code/work-on-a-cairn-site-with-claude-code.md`, "Work on a cairn site with Claude
  Code"; CI's `test` caught the leak check's T1 regex missing `claude-code`, fixed `58b7b5af8`).
- Geoff rejected Add a custom admin screen: one sentence per line shows as broken wrapping in the
  queue. Unwrapped it plus architecture, restrict, add-cairn (`114bff8f3`, rendered HTML identical);
  withdrew the five other first-round items.
- #144 head `d2a423e67`: main merged in (`3f4d51510`, facts conflict resolved per fact against the
  merge base), scaffolded links the renamed page, f: CHANGELOG range for `editor.adminNav` re-pointed
  (4458 -> 4476; CHANGELOG line pointers drift on every merge: friction). Whole gate green.
- Six pages requeued 19:40: 20261025T194054-1236526 (admin-screen, revision), ...194056-1236652
  (architecture), ...194058-1236771 (restrict), ...194100-1236891 (second-group), ...194102-1237011
  (scaffolded), ...194104-1237148 (add-cairn). First-round decisions kept as `*.r1.json`.
- Friction to file at close (cairn): the arm-registration missed check-leaks' T1 regex (a test
  caught it only in CI; the registration checklist should name every arm list); sentence-per-line
  page output reads as broken in the queue (drafter/agent output convention: one line per
  paragraph).

## 21:40 state

- All six #144 pages approved (Architecture after two revisions: intro now category-first; Geoff's
  "a site's" edit committed locally `549fe4222`, unpushed). Waymark/the App Names rows `da68306af`.
- Four YAML blueprints rewritten by hand in Markdown (no converter, per Geoff), merged, gate green,
  queued 21:22 as blueprint reviews: decision-bp-{restrict,second-group,scaffolded,add-cairn}.json.
  BACKLOG #77 filed (last three YAML blueprints, stale lock entries).
- Geoff then ruled to RETIRE BLUEPRINTS (docs-as-code; new design under approval-queue-fd). Start no
  blueprint work. Leave #144's queued items; act only on Geoff's decisions. #77 may be moot.
- On approval of the blueprint items: push (549fe4222), wait CI, `gh pr merge 144 --merge
  --match-head-commit <head>`. Then tell approval-queue-fd this run's tool use is done; file cairn
  friction items (RESUME list) unless the new design absorbs them; remove worktrees.

## Done (22:2x)

- #144 MERGED as `2b5549ea0` (head `31d06c90e`, CI 8/8) on Geoff's six page approvals plus his
  Architecture edit. Blueprint reviews withdrawn (moot: Geoff retired blueprints, the facts store,
  and drafter for docs-as-code). BACKLOG #77 dropped. #143 merged earlier as `f099f2356`.
- approval-queue-fd told: merge commit, tool use done, STATUS/#71 and the unfiled friction left to
  the cleanup inventory. All seven run worktrees and their branches removed (each an ancestor of
  origin/main, no tracked changes). Nothing queued or in flight.
