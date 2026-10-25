# Batch 4 friction (session log)

Candidates in outline order: theme-your-public-site, act-on-newly-published-entries, add-an-island
(fallbacks turn-on-tidy, run-cairn-audit-on-your-site). Base branch `ebp4-base` off
`origin/extend-blueprints-2` (`de8a1064e`) with the five approved batch 3 blueprint branches
merged (`85bcc6cff`, pushed). Worktrees `.claude/worktrees/ebp4-<slug>`.

Items tagged by owning repo. This batch's focus: drafter and approval-queue.

## Session-observed

- S1 (session, cairn-cms): batch 3's approved blueprint branches were never merged into
  `extend-blueprints-2`, so batch 4 needed an integration branch first. Five merges, three
  conflicts. Two were in `docs/internal/facts/extend.md`, where both sides had corrected the same
  bullets (`f:68w9k9`, `f:g39nkp`, `f:sz71ur`, `f:n07oiu`). Each side had one drifted range
  (HEAD's `content-index.ts:...107` against the code's `104`), settled by reading the code. A
  parallel-author batch gets the same shared-fact collisions every time.
- S2 (drafter): no rename command. The configure-rendering rename swept 45 files on its branch,
  but two approved blueprints on sibling branches still linked `configure-rendering.md`, and the
  approved Content model page conflicted with the sweep. Found only by `git grep` after the merge.
  A `drafter rename <old> <new>` that rewrites outline entries, blueprint links, and briefs, or a
  check that names a link to a slug the outline no longer lists, would catch it on any branch.
- S3 (drafter): the cross-blueprint anchor check only sees blueprints on the current branch.
  configure-media's trim dropped `#resolve-media-on-public-pages`, which build-the-public-routes
  (a sibling branch) linked; the error appeared only at the integration merge. Expected; a
  batch's parallel branches need one integration check before queueing.
- S4 (drafter): an unnamed `drafter check` on the merged base reports 23 errors and 2291
  warnings. Besides the pilot blueprints (cairn backlog #30), the stricter store check (drafter
  #60) now errors on dotted pointers to non-declarations (`commit-log.ts#logCommitFailed.reason`,
  `media-route.ts#createMediaRoute.err`), and anchors in `using-claude-code-with-cairn` and
  `rotate-the-github-app-key` name headings their targets no longer have. The whole-tree run
  stays red, so authors still check by name.
- S5 (approval-queue): two page approvals (Content model, Arrange the admin sidebar, 16:26) landed
  in decision files after the queueing session ended, and their follow-up (mark PR #139 ready,
  CI, merge) has no owner. `collect` covers a deferred item, but an approve whose session is gone
  is just a file in a folder. A `approval-queue pending` listing of decided items with no
  recorded follow-up, or a decision hook that runs a named command, would close the gap.
- S6 (drafter, unchanged from batch 2 item 60): a new worktree still needs
  `~/.config/drafter/cairn-cms.local.toml` copied in as `drafter.local.toml` before `drafter
  config` resolves.

## Premise check (one Opus read, five pages)

Verdicts: theme-your-public-site TRIM, act-on-newly-published-entries TRIM, add-an-island TRIM,
turn-on-tidy KEEP with two fixes, run-cairn-audit-on-your-site TRIM. No fold this batch.

- P1 (drafter): `drafter outline` with no slug errors ("outline needs exactly one slug or page
  path") instead of printing the outline, so a whole-outline read falls back to the YAML.
- P2 (drafter): no reverse lookup of the outline entries whose `outOfScope` or `crossLinks` name a
  slug; a trim author has to grep `outline.yaml` (batch 3's B3-9 is the same need).
- P3 (drafter): `covers` items carry backticked identifiers nothing checks. This read found three
  stale ones inherited from the pre-rebuild plans: a `$chassis` seam (the real seam is the
  `#chassis` import), `check:public-tokens` (engine-repo script only), and
  `editor.nav.configPath` (the key is `editor.siteConfigPath`, default
  `src/theme/site.config.yaml`). A check that resolves code-font names in `covers` against the
  source tree would have caught all three; `editor.nav.configPath` is batch 3's B3-16 again.
- P4 (cairn-cms): the scaffold's `templates/waymark/src/theme/theme.css:66` comment names
  `check:public-tokens`, which a consumer site doesn't have.
- P5 (cairn-cms): the published run-cairn-audit page's CI fragment runs `npx playwright install
  chromium` but never installs the `playwright` package the rendered pass imports.

## act-on-newly-published-entries author (`98a2c93b1`, about 45 min, 0 errors / 2 warnings)

- A1 (drafter): an anchor shaped `` (`symbol`: more text) `` reads as "no anchor"
  (f:ix641z, f:w3m0ac). format.md:720-722 says only "a second code span in parentheses right
  after the pointer". Workaround: a bare `` (`symbol`) ``.
- A2 (drafter, cairn-cms): the parsers disagree on a `#name` declaration's span. drafter counts
  the leading doc comment (format.md:686, 743); `check:facts` checks only the declaration lines
  (check-facts.mjs:459-465). An anchor taken from the doc comment (f:nsandp) passed `drafter
  check --fact` and failed `check:facts`. Same family as B3-13, a new trigger.
- A3 (drafter): `exhaustive` false positives on a bold UI label (**Publish all**), on "diffs the
  two, keeps" read as a count, and on "the same two manifests"; no way to mark a warning settled,
  so it reprints every run. B3-2 and B3-20 held: the constraints block and absence phrasing no
  longer fire.
- A4 (drafter): B3-3 and B3-21 held: a named run printed only the file's findings.
- A5 (drafter, cairn-cms): the sentence-length check is off unless `check.sentence_words` is set,
  and cairn's `drafter.toml` doesn't set it, so the author enforced the 26-word rule by hand
  script. Set it for cairn.
- A6 (blueprint skill): new-page.md:26 puts a run script's path in the `Code:` bullet's
  `:source`, but a scratchpad script fails the existence check. Workaround: the run goes in the
  fact's tag note. Repeat of B3-6.
- A7 (cairn-cms): f:w3m0ac was `[verified]` and wrong; a pointer read showed the general case,
  and only running the function showed the case inside one diff window. A behavioral fact with a
  case split wants a recorded run.
- A8 (cairn-cms): the page's facts sit in two homes, `## docs/extend/announce-on-publish.md`
  (extend.md:200) and `### act-on-newly-published-entries` (about :1132). Repeat of batch 2's
  #28 class.
- A9 (cairn-cms): the 488-line plan and 260-line framing record predate the trims. Repeat of
  B3-8, B3-24.
- A10 (cairn-cms): `check-facts.mjs --mint` mints one id per call.
- A11 (cairn-cms): docs/reference/sveltekit.md says publishActions is validated "when the runtime
  composes" and that a bad entry "fails the build"; the code validates when the admin's content
  routes are built (content-routes-context.ts:352-356) and composeRuntime passes the list through
  (compose.ts:62). The reference also omits the duplicate-label throw. Open since the 2026-10-12
  plan.
- A12 (prompt): the session's brief repeated the reference's A11 error.

## theme-your-public-site author (`e452dd550`, about 15 min wall clock, 0 errors / 5 warnings)

- T1 (drafter, cairn-cms): the `#decl` span split again. `src/lib/media-seed/run.ts#seedMedia`
  (`Idempotent`) passed `drafter check --fact` and failed `check:facts` ("not found in lines
  46-76"), since the TS-compiler span leaves out the leading JSDoc. Second hit this batch (A2);
  the two parsers need one span rule.
- T2 (drafter): a pointer into `templates/waymark/src/chassis/README.md` gives "no excerpt:
  prose", yet a fact about what a scaffold file says can only point at that file. A
  `prose_sources` default for template READMEs (or per-path globs) would let a read excerpt it.
  Whether a template README is a D1-allowed source is a question for Geoff (open point 8).
- T3 (drafter): 55 anchorless-pointer warnings on a first `--fact` run, and three drifted pointers
  had passed (f:j2qzct, f:gnn3pv off by about 115 lines, f:7pv6se on the wrong comment). Repeat of
  B3-12, B3-28.
- T4 (drafter): a named `drafter check` doesn't report inbound anchors the named blueprint breaks.
  Trimming sections broke anchors in `scaffolded-site-files.blueprint.yaml` and
  `write-a-markdown-component.blueprint.md`; only the unnamed run showed it, and published pages
  linking removed anchors (share-a-draft-preview, run-cairn-audit) are checked by neither.
  `drafter refs --page` lists inbound links but not their anchors. New.
- T5 (drafter): `exhaustive` fires on a quoted section name ("Every override seam") and on counts
  a fact proves ("three flourishes", "five chassis spacing keys"). Partly B3-2/B3-20; with A3,
  the case for a per-line settled marker.
- T6 (blueprint skill, harness): a `sed -i` one-token pointer fix made the harness demand a
  re-Read. Repeat of B3-29's ask for an exact in-place substitution rule.
- T7 (prompt): the session's trims didn't list the inbound anchors they broke
  (`#style-rendered-markdown`, `#resolve-an-audit-finding`, `#style-the-editor-preview`,
  `#the-chassis-boundary`, `#token-tiers-and-cascade-order`); the author found them. With T4,
  a trim should start from `drafter refs --page`. Related to B3-9.
- T8 (prompt): the premise read's pointers were close but not exact (`theme.css:20-68`, not
  22-66), which the author re-verified as told.
- T9 (cairn-cms): the 836-line plan predates the trim. Repeat of B3-8, B3-24.
- T10 (blueprint skill): no guidance on naming a file in the reader's site from a docs page; a
  relative link into `templates/` breaks on cairn.pub. New.
- T11 (blueprint skill): new-page.md says "use the project's id command when it has one", and
  cairn has one (`check-facts.mjs --mint`, A10), but nothing names it, so this author minted ids
  by hand. Name it in cairn's adapter or the facts README.
- T12 (drafter): `Code:` bullets and a `:source` path with parentheses (`(site)/+layout.svelte`)
  parsed cleanly; B3-1 doesn't bite there.
- T13 (cairn-cms): engine and doc defects found: the scaffold's chassis README `content.ts`
  dependents row names `[...path]` where `(site)/archive/[page]` imports it directly;
  `docs/reference/core.md:173-175` says the preview frame pins a white background where the code
  paints `var(--color-base-100,#fff)`; theme.css's recipe says "about fourteen" for twelve values;
  `share-a-draft-preview.md:43` links a removed anchor.

## act-on register edit (applied in `6764893ef`)

- R1 (drafter): the register editor's three blocking findings were structural and mechanical:
  a numbered or single step holding two actions joined by ", and", an imperative bullet outside
  any step ("Choose the order..."), and notes under a step that belong to another (a prerequisite
  filed as a note under the last step). `drafter check` passed all three. A lint for an
  imperative-mood bullet outside a step list, and for a step with two verbs joined by "and",
  would move them before the paid read.
- R2 (drafter, blueprint skill): the anatomy's failure-path item (a pointer to debug-your-site)
  was absent and nothing flagged it; anatomies.md lists it, `drafter check` doesn't check
  anatomy coverage. Settled as an info note rather than an invented failure row.

## theme register edit (23 findings, handed back to the author to apply)

- R3 (blueprint skill): a blueprint that walks a scaffold file's comment inherits its figurative
  words ("paper", "ink", "accent", "corner ladder", "levers"), which collide with real identifiers
  (`--cairn-<status>-ink`, `--color-accent`). The skill's write step could say: name each value by
  its code identifier, never by the source comment's metaphor.
- R4 (cairn-cms, drafter): line 54 said Configure media "sets up" the media library, which
  configure-media's approved blueprint denies. A cross-blueprint claim about what a neighbor page
  does has no check; `drafter check` could compare a "See [X]" line's verb against nothing, but
  the neighbor's `outOfScope` or reader block is where the contradiction showed.
- R5 (session): applying 23 rewrites by hand in the session would cost a long read of a
  290-line file; resuming the author with the review file kept the code context where it was.
  Worth writing into the batch flow.

## add-an-island author (`a8552c77f`, about 45 min, 0 errors / 0 warnings)

- I1 (drafter): a drifted anchor's fix hint names the nearest line of each anchor word ("sandbox
  on line 2239") where the real line is 2248; following it re-points the fact wrong. Name the
  line where all the anchor's words co-occur.
- I2 (drafter): `drafter check --fact pgeeq3` warns every run that an `[external]` fact's vendor
  paths (`@sveltejs/kit`, `src/exports/vite/index.js`) don't exist. An external fact's vendor
  path should be exempt from the existence check. Near B3-14, a new symptom.
- I3 (drafter): an unnamed `drafter check` reports a managed page with no blueprint as missing
  `...blueprint.yaml`, the retired suffix; markdown is the current format.
- I4 (drafter, cairn-cms): 20 anchorless line pointers, five drifted, one on the wrong component
  in the showcase (f:9zxml1 named the showcase where the scaffold was meant). Repeat of B3-12,
  B3-28, T3. Third author this batch; the anchor requirement is the batch's top drafter item.
- I5 (cairn-cms): duplicate facts (f:lv29ox against f:mcxxpp; the showcase and template layouts
  are byte-identical), a code comment read as an engine claim (f:59u3b9), and f:7sc3pe in
  reference.md with the same drifted `EditPage.svelte:2243`. Repeat of B3-16.
- I6 (cairn-cms): `docs/reference/islands.md:33-60` shows a root layout that statically imports
  the adapter on the client, the trap the scaffold's layout comment names, with no `hasIslands`
  gate. Its facts rest on the reference prose, so nothing caught it.
- I7 (prompt): the premise read cited `registry.ts:74` as `true | 'visible'`; it is
  `boolean | 'visible'`.
- I8 (cairn-cms): `check.sentence_words` off in cairn's drafter.toml; second author to hand-script
  the 26-word rule (A5).
- I9 (workstation): the tellgrader PostToolUse hook fires on fact-bullet edits in
  `docs/internal/facts/*.md` ("empty-own" on "Svelte's own mount()"). Facts are not page prose;
  exclude the store from the hook.
- I10 (cairn-cms): the 53.7 KB plan predates the trims. Repeat of B3-8, B3-24, A9, T9: every
  author this batch. Mark plans superseded or delete them once a blueprint exists.
- I11 (blueprint skill): format.md is 65 KB and overflows one read; the markdown-blueprints part
  an author needs is about 180 lines. Split it into its own file.

## act-on fact-check and queue (`ee6dad54e`, `4d84038aa`; queued 20261024T210221-500462)

- Round 1: 92 claims, 87 hold, 1 wrong, 2 imprecise, 2 unsupported. Round 2 (changed lines): 15
  claims, 13 hold, 1 imprecise, 1 unsupported; both taken in the checker's wording or cut.
- F1 (cairn-cms): the wrong claim was the session's own constraint ("never say a bad entry fails
  the build"), copied from the author's reading of the code comment ("fails at server start").
  SvelteKit's build analysis loads every route's server node (`analyse.js:69`), so a
  `createCairnAdmin` throw fails `vite build` on a scaffolded site. The engine's own doc comment
  (`publish-actions.ts:30-33`, "fails at server start") states half of it; fix the comment.
- F2 (blueprint skill): a claim about a scratchpad run ("typechecks against the built package",
  "ran under Node 24") is unsupported by construction, since the fact-checker can't repeat it.
  The skill could say: record such a run in the fact's note, never in a blueprint line.
- Q1 (approval-queue): `approval-queue anchors` slugs the blueprint's H1 as
  `act-on-newly-published-entries-1.heading`, as if a heading with the same text came first; the
  H1 is the only heading with that text. Likely the front matter's `page:` title counted as a
  heading. A note author has to read the printout to learn the suffix.
- Q2 (approval-queue): the queue command takes `--notes` and `--description` as files, and a note
  carrying `was`/`now` must also be `kind: info`; the shape rules are in the skill but no
  `approval-queue notes --check <file>` exists, so a malformed note surfaces only at queue time.
  (This queue went through first time.)

## theme fact-check round 1 (`a6a8d7136`)

- 165 claims: 156 hold, 9 imprecise, 0 wrong, 0 unsupported. The imprecise ones are the batch
  pattern: a list that stops short of the code's set (the `content.ts` dependents also include
  three chassis modules), a missing qualifier (`--fail-on advisory`), and a symptom row whose
  cause the code states more narrowly (an ink on its callout tint, not "directive text").
- F3 (workstation, fact-checker agent): a proposed fix often runs past the register's 26-word
  cap or adds ", which" and ", so" tails, so a fix can't be pasted; the settle step re-splits it.
  The agent's brief could cap a proposal at the register's sentence length.

## island register edit (applied by its author, `db8e4a9af`)

- N1 (drafter, blueprint skill): format.md has no notice form. The island author wrote
  "- Caution notice: ..."; define-an-adapter's approved blueprint writes "- A caution notice says
  that ...". Neither is checked, and the draft seat may render either as prose. The session
  aligned the island's two lines to the approved form. Give notices a syntax (a `:::caution`
  block or a `Caution:` bullet) and a check.
- N2 (prompt, workstation register editor): three register rewrites reintroduced words the
  `exhaustive` lint flags ("only for this check", "imports only the live components", "Two
  behaviors"), so the author re-worded around the lint. The register editor's brief could name
  the lint's words. With A3 and T5, the lint and the editor pull against each other.
- F4 (workstation, fact-checker agent): one of the checker's proposed fixes was itself wrong
  (`toggleTheme`, where the scaffold calls `toggleThemeWithTransition`, `SiteHeader.svelte:32`).
  The settle step's re-verify caught it; a proposal is never pasted unread.
- F5 (cairn-cms): facts f:ctognq and f:i9pgd2 still point at `examples/showcase` paths for claims
  about the scaffold; the author added `templates/waymark` pointers beside them. Showcase-sourced
  facts about the scaffold are the B3-16 / I5 duplicate class.

## island fact-check round 1 (`1e49f00b6`, settled `0c0ea6bca`)

- 114 claims: 109 hold, 5 imprecise, 0 wrong, 0 unsupported. Three were one missing action (the
  registry needs the component imported, not just an entry); one was the session's own reference
  sentence (a gated dynamic import isn't kept out of the bundle, it is never requested).
- F6 (cairn-cms): the register editor's fix for the anatomy's missing failure link sent the
  reader to Debug your site, which has no island section; the runtime swallows a props parse
  failure and a mount throw with no log (`index.ts:43-51`). An island failure that logs nothing
  is invisible in Workers Logs and the browser console alike. An engine `console.warn` or a
  log event for it is a candidate backlog item.
- F7 (drafter): anatomy item 5 (a failure path to debug-your-site) is wrong for a client-side
  feature with no log event; the anatomy could say "or the checks that settle it" so an author
  isn't pushed toward a dead link (R2 is the same item from the other side).

## island and theme queue (island 20261024T211146-511448, theme 20261024T211229-512193)

- Q3 (approval-queue): `approval-queue withdraw <id>` printed `line 25: /proc/511192/stat: No
  such file or directory` and exited without saying it withdrew. The item was gone (404) and the
  waiting command had exited, so `proc_stat` raced the exiting process. Print "withdrew <id>" and
  silence the stat read's error when the process is already gone.
- Q4 (approval-queue): a misplaced note anchor needs a withdraw and a full requeue; the queue
  has no way to amend an undecided item's notes in place. Cheap here, but a requeue resets the
  item's id and URL.
- Island round 2: 10 claims, 9 hold, 1 imprecise (a wording repeat, taken in the checker's words).
  Theme round 2: 28 claims, 26 hold, 2 imprecise, settled (`6887e10dc`).

## drafting (ebp4-base)

- D1 (drafter): `drafter page` refuses a dirty worktree (exit 2), and an accepted run leaves its
  page, brief, and `drafted.lock` uncommitted, so a loop over several blueprints fails on the
  second page. Commit the accepted output itself (an opt-in `--commit`), or take several
  blueprints in one run. The skill doesn't say to commit between runs.
- D2 (drafter): `facts.prose_sources` takes exact paths only; listing "every template README"
  (Geoff's N4 ruling) means naming each file. A glob would follow a new README automatically.
