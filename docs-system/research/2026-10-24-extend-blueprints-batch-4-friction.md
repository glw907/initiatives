# Extend blueprints batch 4: friction record (2026-10-24)

Initiative: docs-system

Batch 4 built three extend blueprints on `pavilion` in one attended evening run: Theme your public
site, Act on newly published entries, and Add an island, all task guides. Batch 3's six approved
blueprints had not been merged, so the run first built `ebp4-base` from `extend-blueprints-2`
(`de8a1064e`) with those five branches merged and their stale links repointed (`85bcc6cff`). One
Opus read ran the premise check on the five remaining extend candidates; it kept all five and
trimmed four. Each page then took an Opus author, `cairn-register-editor`, a fresh `fact-checker`,
the session's settlement, a fresh check of the changed lines, notes, and `approval-queue
blueprint`. Two register edits were handed back to their authors to apply, since each author still
held the code in context. The session log is `2026-10-24-extend-blueprints-batch-4/friction.md`;
the batch 3 record this one follows is the "Batch 3" section of
`2026-10-22-extend-blueprints-batch-2-friction.md` ("B3-N" below).

## The numbers

| Page | Author (min) | Register verdict | Round 1 claims | Hold | Imprecise | Unsupported | Wrong | Round 2 | Queue item |
|---|---|---|---|---|---|---|---|---|---|
| Act on newly published entries | 45 | fix (3 blocking) | 92 | 87 | 2 | 2 | 1 | 15: 13 hold, 1 imprecise, 1 unsupported | 20261024T210221-500462 |
| Theme your public site | 15 | fix (5 blocking, 23 in all) | 165 | 156 | 9 | 0 | 0 | 28: 26 hold, 2 imprecise | 20261024T211229-512193 |
| Add an island | 45 | fix (9 blocking, 25 in all) | 114 | 109 | 5 | 0 | 0 | 10: 9 hold, 1 imprecise | 20261024T211146-511448 |

The fact layer held again: one wrong claim in 371 round-1 claims, and it was the session's own
constraint, not an author's line (item cairn-cms 1). The authors corrected one wrong `[verified]`
fact (`f:w3m0ac`, delete-and-recreate inside one diff window), found only by running the
function. All three register reviews answered fix, and two of three blocking sets were Google
procedure rules a lint could catch: a step with two actions, an imperative outside a step, a
prerequisite filed as a step's note (drafter 3).

Each branch also fixed a published reference page the fact rule reached: the sveltekit
reference's publish-actions paragraph (when validation runs, and that a bad entry fails the
build), the islands reference's root-layout example (it imported the whole adapter on the
client), and the core reference's preview-background sentence.

## drafter

1. **Require an anchor on every line pointer.** Every author this batch met drifted, anchorless
   `path:N-M` pointers that passed (`f:j2qzct`, `f:gnn3pv` off by about 115 lines, `f:7pv6se` on
   the wrong comment, `f:9zxml1` on the wrong component, five more on the island page; 55
   anchorless warnings on one first run). Repeat of B3-12, B3-22, B3-28, and pilot 5. The batch's
   top drafter item.
2. **One span rule for `#decl` pointers.** drafter's declaration span includes the leading doc
   comment (format.md:686, 743) and `check:facts` checks the declaration lines only
   (check-facts.mjs:459-465), so an anchor from the JSDoc passed one and failed the other twice
   (`f:nsandp`, `src/lib/media-seed/run.ts#seedMedia`). Same family as B3-13.
3. **Lint the procedure rules the register editor blocked on.** An imperative bullet outside a
   step list, a step joining two actions with "and", and a step whose condition follows its
   instruction. `drafter check` passed all of them on all three pages.
4. **Let a fact-backed line settle an `exhaustive` warning.** False positives: a bold UI label
   (**Publish all**), a quoted section name ("Every override seam"), "diffs the two, keeps" read
   as a count, and counts the code proves ("three radius keys"). Nothing marks a warning settled,
   so it reprints each run, and register rewrites reintroduce the flagged words. B3-2 and B3-20
   held (the constraints block and absence phrasing no longer fire).
5. **Report inbound anchors a named run breaks.** Trimming theme's sections broke anchors in
   `scaffolded-site-files` and `write-a-markdown-component`; only the unnamed run showed it, and
   published pages linking removed anchors are checked by neither. `drafter refs --page` lists
   inbound links without their anchors.
6. **A rename command.** The configure-rendering rename swept 45 files on its branch, but two
   approved sibling blueprints still linked the old slug, found by `git grep` after the merge. A
   `drafter rename <old> <new>`, or a check naming a link to a slug the outline no longer lists.
7. **Check backticked identifiers in `covers`.** Three stale names reached the outline from the
   pre-rebuild plans: a `$chassis` seam, `check:public-tokens`, and `editor.nav.configPath` (B3-16
   again). Resolve code-font names against the source tree.
8. **Give notices a syntax.** format.md has none. One author wrote "- Caution notice: ...", the
   approved define-an-adapter blueprint "- A caution notice says that ...", and the draft seat may
   render either as prose.
9. **Fix the drifted-anchor hint.** It names the nearest line of each anchor word ("sandbox on
   line 2239" where the line is 2248); following it re-points the fact wrong.
10. **Exempt an `[external]` fact's vendor paths from the existence check.** `drafter check
    --fact pgeeq3` warns every run that `@sveltejs/kit` paths don't exist. Near B3-14.
11. **Read anchors with trailing text.** `` (`symbol`: more text) `` reads as no anchor;
    format.md:720-722 doesn't say a bare span is required.
12. **Allow template READMEs as excerptable sources.** `templates/waymark/src/chassis/README.md`
    gives "no excerpt: prose", so a fact about what a scaffold file says can't be read. Pairs with
    the question to Geoff on the theme blueprint (N4).
13. **Smaller items.** `drafter outline` with no slug errors instead of printing the outline; no
    reverse lookup of the entries whose `outOfScope` names a slug (B3-9); an unnamed check calls
    a missing blueprint `...blueprint.yaml`, the retired suffix; the unnamed check on the merged
    base reports 23 errors and 2291 warnings, now including dotted pointers to non-declarations
    (`#logCommitFailed.reason`, `#createMediaRoute.err`) under the stricter store check; the
    cross-blueprint anchor check sees only the current branch, so a batch of sibling branches
    needs one integration check before queueing.
14. **Held this batch.** B3-3 and B3-21 (a named run prints only the file's findings); `Code:`
    bullets and a `:source` path with parentheses parse cleanly (B3-1 doesn't bite).

### drafter: the blueprint skill (lives in the drafter repo)

15. **Split format.md.** It is 65 KB and overflows one read; the markdown-blueprints part an
    author needs is about 180 lines.
16. **Say where a scratchpad run goes.** new-page.md:26 puts a run script's path in `:source`,
    which fails the existence check, and a blueprint line about a scratchpad run ("typechecks
    against the built package", "ran under Node 24") is unsupported by construction. Record the
    run in the fact's note, never in a blueprint line. Repeat of B3-6.
17. **Name each value by its identifier.** A blueprint that walks a scaffold comment inherits
    its metaphors ("paper", "ink", "accent", "corner ladder"), which collide with real variables.
18. **Name the facts id command.** new-page.md says "use the project's id command when it has
    one"; cairn has `check-facts.mjs --mint`, but nothing names it, so an author minted by hand.
19. **Guidance for naming a file in the reader's site.** A relative link into `templates/` breaks
    on cairn.pub; the theme page names the chassis README by path (question to Geoff, N3).
20. **Loosen anatomy item 5 for client-side features.** The task-guide anatomy's failure path to
    debug-your-site sent the island page to a page with no island section; "or the checks that
    settle it" would fit a feature with no log event.
21. **Allow an exact in-place substitution** in the fact-edit rule. A one-token `sed -i` pointer
    fix is not an append. Repeat of B3-29.

## approval-queue

1. **Own a decision whose session ended.** Two page approvals (Content model, Arrange the admin
   sidebar, 2026-10-24 16:26) landed in decision files after their queueing session ended; the
   follow-up (mark glw907/cairn-cms#139 ready, CI, merge) has no owner. `collect` covers a
   deferred item, but an approve with no live session is a file in a folder. A
   `approval-queue pending` listing of decided items with no recorded follow-up, or a decision
   hook that runs a named command.
2. **Make `withdraw` say what it did.** It printed `line 25: /proc/511192/stat: No such file or
   directory` and nothing else; the item was gone (404). `proc_stat` raced the exiting waiter.
   Print "withdrew <id>" and drop the stat error when the process is already gone.
3. **Amend an undecided item's notes in place.** A misplaced note anchor took a withdraw and a
   full requeue, which resets the item's id and URL.
4. **Fix the H1 anchor slug.** `approval-queue anchors` prints a blueprint's H1 as
   `<slug>-1.heading` on all three pages, as if a heading with the same text came first. The
   front matter's `page:` title is the likely cause.
5. **A notes check before queueing.** No `approval-queue notes --check <file>` exists; a
   malformed note or a quote anchor matching more than once shows up only at queue time or in
   the review (one theme note quoted `cairn-audit`, which occurs many times; caught by hand).

## cairn-cms

1. **Fix the publishActions doc comment.** `publish-actions.ts:30-33` says a bad entry "fails at
   server start". SvelteKit's build analysis loads every route's server node
   (`analyse.js:69`), so on a scaffolded site it also fails `vite build`. The session's
   constraint copied the comment and was the batch's one wrong claim.
2. **Decide whether a failed island logs.** `src/lib/islands/index.ts:43-51` swallows a props
   parse failure and a mount throw in bare `catch` blocks; nothing reaches the console or Workers
   Logs. Question to Geoff on the island blueprint (N4).
3. **Fix the scaffold's stale comments.** `templates/waymark/src/theme/theme.css` names
   `check:public-tokens` (lines 11-12, 66, 126), an engine-repo script a site doesn't have, and
   its recipe says "about fourteen" values for twelve. The chassis README's `content.ts`
   dependents row misses `(site)/archive/[page]` and three chassis modules.
4. **Set `check.sentence_words = 26`** in cairn's `drafter.toml`; two authors hand-scripted the
   register's 26-word rule.
5. **Retire or mark superseded the page plans once a blueprint exists.** Every author this batch
   read a 488 to 836-line plan or a 53 KB one that predated the trims. Repeat of B3-8, B3-24.
6. **Merge each batch's approved blueprints before the next batch cuts.** Batch 3's sat
   unmerged, so batch 4 built an integration branch and settled shared-fact conflicts both sides
   had corrected (`f:68w9k9`, `f:g39nkp`, `f:sz71ur`, `f:n07oiu`), each with one drifted range.
   `ebp4-base` can be merged into `extend-blueprints-2` once glw907/cairn-cms#139 lands.
7. **Facts store cleanup (repeat of B3-16).** Duplicates (`f:lv29ox` against `f:mcxxpp`, the
   showcase and template layouts being byte-identical); showcase-sourced facts about the scaffold
   (`f:ctognq`, `f:i9pgd2`, `f:9zxml1` named the showcase where the scaffold was meant); a code
   comment read as an engine claim (`f:59u3b9`); `f:7sc3pe` in reference.md with the drifted
   `EditPage.svelte:2243`; and act-on's facts in two homes (`## announce-on-publish.md` and
   `### act-on-newly-published-entries`).
8. **A behavioral fact with a case split wants a recorded run.** `f:w3m0ac` was `[verified]` and
   wrong; reading the pointer showed the general case.
9. **Published-page defects found, not fixed here.** run-cairn-audit's CI fragment runs `npx
   playwright install chromium` but never installs the `playwright` package; it also sets
   `BASE_URL` to 4173 while the scaffold's `preview` is `wrangler dev`.
   `share-a-draft-preview.md:43` links a removed anchor (that page retires with the fold).

## workstation (`~/.dotfiles` agents and hooks)

1. **Cap a fact-checker proposal at the register's sentence length.** Proposed fixes ran past 26
   words or stacked ", which" and ", so" tails, so none could be pasted, and one proposal was
   itself wrong (`toggleTheme` where the scaffold calls `toggleThemeWithTransition`).
2. **Have the register editor quote its target text.** Its line numbers drifted from the file at
   the named commit; the author matched on text. It should also avoid the words the `exhaustive`
   lint flags, or say a count is fact-backed.
3. **Exclude the facts store from the tellgrader PostToolUse hook.** It flagged "empty-own" on
   fact bullets ("Svelte's own mount()"), which aren't page prose.

## The batch prompt and session (initiatives)

1. The premise read's pointers were close but not exact (`theme.css:20-68`, not 22-66;
   `registry.ts:74` is `boolean | 'visible'`, not `true | 'visible'`), and its brief repeated the
   sveltekit reference's validation error. Authors re-verified, as told.
2. A trim brief should list the inbound anchors it breaks; start it from `drafter refs --page`.
3. Handing a long register review back to the author who wrote the blueprint worked: the author
   re-verified each "verify" rewrite against code it had already read, and declined none without
   a code reason. Worth keeping in the batch flow.
