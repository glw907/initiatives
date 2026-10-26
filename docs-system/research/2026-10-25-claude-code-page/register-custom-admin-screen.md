# Register edit: docs/extend/add-a-custom-admin-screen.md

- Page: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/redraft-prep/docs/extend/add-a-custom-admin-screen.md` at `d4f576d7d` (extend track, task guide)
- Blueprint: `blueprints/docs/extend/add-a-custom-admin-screen.blueprint.md` (same worktree)
- Base guide: Google developer documentation style guide. Overlay: `docs/internal/docs-register.md` (developer brief, Names, page anatomies, extend track, Deviations).
- Verdict: **fix** (6 blocking base-guide findings, 19 non-blocking)

## Deterministic floor

`tellgrader --register docs` (profile resolved to `docs-register`, exit 0): **no findings, no gates.** Counts: `exclamation` 3 (the `!name`/`!db` negations in code, a scanner artifact), `tricolon` 3, `uniform-paragraph` 7. Tells per 1000 words: 0.

Vale (repo `.vale.ini`): **0 errors** (the `check:vale` gate passes). Warnings: `Google.WordListCase` on "admin" throughout (overridden by the Names table, which sanctions "the admin"); `Google.OxfordComma` on lines 7, 83, 111, 248 (false positives: no series in any of them); `Google.Colons` on the bold `Symptom:`/`Cause:`/`Fix:` labels (see N16); `Google.WordListCase` "touch" on line 48 (see N17); `Cairn.NamesRetired` "the package" on line 357 (a correct use: a fact about what the tarball ships).

### Measurements

| Measure | Value | Source |
|---|---|---|
| sentences | 220 | tellgrader `measures` (prose selector) |
| hinged_pair_share | 0.359 | tellgrader `measures` |
| short_sentence_share | 0.127 | tellgrader `measures` |
| Average sentence length | 14.4 words | own count (299 sentences, code excluded) |
| Longest sentence | 38 words, line 6 (introduction, exempt from the cap) | own count |
| Paragraph count | 122 (prose and list blocks, code excluded) | own count |
| Disproportionate paragraphs | Lines 236-242 (seven one-fact sentences after the actions code), lines 284-289 (six facts from three different subjects), lines 9-15 (the introduction's second paragraph, seven short declaratives) | own reading |

The shares carry no band and gate nothing.

## Blocking findings (base guide)

### B1. The page's core contract has no step: `ctx.audit` on every successful path

> Every successful path through a handler calls `ctx.audit` before it returns. (line 240)

**Rule:** A sequence of actions is a numbered list; an action the reader must take never sits in explanatory prose (brief checklist, "highlights" and "procedures"; register tell "a micro-instructed action in explanatory prose outside a procedure's steps"). The introduction promises a screen that "records each write in the audit trail", and the "Wrap the actions" steps (1 to 3) never tell the reader to call `ctx.audit`. The requirement appears only as a description after the code, where a skimming reader of the steps misses it, and missing it is the exact failure "Resolve a missing audit record" exists for.

**Rewrite:** add a step to "Wrap the actions" and cut the sentence from the prose block.

> 4. In each handler, call `ctx.audit` on every path that succeeds, before the handler returns.

and, after the code, keep only: "A handler that rejects with `fail()` before it writes owes no record."

### B2. Verify step 2 holds two actions and a buried prerequisite

> 2. In a second browser, sign in as an editor whose role the screen's rule does not name, and open the screen.
>
>    The admin's error page reports that the account has no access to the page.
>    An owner adds that account through the **Add editor** form on `/admin/editors`, choosing a role the rule leaves out, such as `editor` for the signups rule.

**Rule:** Each step holds one action (procedures); a prerequisite or an earlier step precedes the step, never follows it (notices/procedures). The step signs in and opens the screen, and the account it needs is created in a sentence after the step.

**Rewrite:**

> 2. In the owner's browser, on `/admin/editors`, add an account through the **Add editor** form with a role the screen's rule leaves out, such as `editor` for the signups rule.
>
>    Each role option shows its name, followed by its capability in parentheses when the two differ. [Assign the roles](restrict-admin-access.md#assign-the-roles) describes the roles an owner can assign.
>
> 3. In a second browser, sign in as that account.
> 4. In the second browser, open the screen.
>
>    The admin's error page reports that the account has no access to the page.

(Renumber the later steps.)

### B3. Table introduction over the 26-word cap in a task section

> The following table compares when each wrapper checks the access map, how it refuses a session, whether it needs a binding, and how it records a refusal. (line 162, 27 words)

**Rule:** A sentence in a task section stays under 26 words (brief checklist; Deviations row 2).

**Rewrite:** "The following table compares how the two wrappers check the access map, refuse a session, and record a refusal, and whether each needs a binding." (24 words)

### B4. Symptom sentence over the cap in a task section

> **Symptom:** The admin shell does not fill the viewport, and in dev the browser console shows one error about a width cap on an ancestor of the admin root. (line 85, 29 words)

**Rule:** 26-word cap in a task section. The blueprint already had the split.

**Rewrite:** "**Symptom:** The admin shell does not fill the viewport. In dev, the browser console shows one error about a width cap on an ancestor of the admin root."

### B5. Positional references in the hand-offs

> The next section states the motion rules an animating screen meets. (line 551)
> The second recipe loads detail for rows that expand. (line 485)
> The two optional recipes that follow serve a screen with a dialog form or with expanding rows. (line 391)

**Rule:** A reference names its target, never its position on the page (brief checklist, procedures). The hand-offs are plan-placed, so only their wording is graded; "the next section", "the second recipe", and "that follow" are position words. "Recipe" also names the docs' anatomy by metaphor (see N14).

**Rewrite:**
- Line 391: "The dialog form and row detail apply only to a screen that has a dialog or rows that expand."
- Line 485: "Row detail on demand serves a screen whose rows expand."
- Line 551: "Motion tokens apply to a screen that animates."

### B6. Two actions stated as description inside step 4 of "Load row detail on demand"

> The trigger cell has no visible heading.
> Your `header` snippet matches it with a `<th scope="col">` whose text sits in an `sr-only` span, as the signups table does for its actions column.
> A click inside an element carrying `data-cairn-inert-cell` does not toggle the row.
> An interactive summary cell wraps its content in that attribute in place of calling `stopPropagation()`. (lines 508-511)

**Rule:** Each step holds one action, and a sequence of actions is a numbered list. Two things the reader must write, the screen-reader heading for the trigger column and the inert wrapper on an interactive cell, are phrased as descriptions of what "your snippet" and "an interactive cell" do, inside another step's note.

**Rewrite:** split them out as steps after step 4.

> 5. In the `header` snippet, add a `<th scope="col">` for the trigger cell, with its text in an `sr-only` span.
>
>    The trigger cell has no visible heading. The signups table labels its actions column the same way.
>
> 6. In each interactive summary cell, wrap the content in an element that carries `data-cairn-inert-cell`.
>
>    A click inside that element does not toggle the row, so the cell needs no `stopPropagation()` call.

## Non-blocking findings (register and logic)

### N1. Restatement: the same fact told two to four times

**Rule:** No restatement or filler ("a re-explanation of what the reader was just told").

| Fact | Where it repeats |
|---|---|
| The guard decides nothing per route | lines 10, 96, 97-98 |
| The screen sits behind the same `/admin` sign-in guard as the engine's screens | lines 3, 74 (verbatim) |
| A scaffolded site does not ship the signups screen | lines 17, 38, 47 |
| `createSectionAction` requires a binding resolver | lines 41, 155, table row 3, 179 |
| Listing the screen in the sidebar is another page's task | lines 23, 92, 663 |
| A class compiles only under a scanned root | lines 364, 366, step 1 |
| A nested route's access-map keying | lines 147-149, step 3 note (500-501) |
| Write durations and easings as motion tokens | line 555, the step at 559 |

**Rewrites:**
- "Gate it" lead (96-98): "The access check goes in the screen's `load`. `createAuthGuard({ runtime })` signs a session in for the whole `/admin` subtree before any load runs, and it does not decide which routes that session may reach." (drops the third telling)
- Line 74: cut; line 75 then reads "Every `/admin` path except the sign-in page and the magic-link confirm page sits behind the sign-in guard."
- Line 47: cut (line 17 already says it).
- Line 92: cut (introduction and See also both carry it).
- Line 366: cut (line 364 states it, and step 1 acts on it).
- Lines 147-149: replace with "The access map matches a route by its deepest key prefix, so the screen's key usually covers a nested route. [Key nested and parameterized routes](restrict-admin-access.md#key-nested-and-parameterized-routes) covers the case that resolves to no rule." Step 3's note then keeps only its link.
- Line 555: "The admin declares its durations and easings as tokens, and `cairn-audit` fails a literal duration or easing in an admin screen." (ties the section to the task without echoing the step)

### N2. Balanced halves in "Choose the action wrapper"

> A screen whose actions write through a database binding uses `createSectionAction`, and a screen with no binding uses `createAdminAction` with its `access` option set.
> `createSectionAction` requires a `resolveDb` binding resolver.
> `createAdminAction` carries the CSRF and audit contract with no binding. (lines 154-156)

**Rule:** No balanced-halves constructions ("for X, A; for Y, B", echo pairs). Line 154 is the "for X, A; for Y, B" shape, and 155-156 is an echo pair that restates the table's "Needs a binding" row.

**Rewrite:** "The choice turns on whether the screen's actions write through a database binding. `createSectionAction` requires a `resolveDb` resolver for that binding, and `createAdminAction` carries the same CSRF and audit contract without one, provided the call sets its `access` option."

### N3. Equivocation on "section"

> One `createSectionAction` call builds a reusable wrapper for the section (line 178); A section never calls `createAdminAction` directly. (line 239)

**Rule:** Logic, equivocation; Names (one sanctioned name per thing: "custom admin screen" names a whole admin route). The page uses "section" for its own page sections ("each such section", "the rest of the page") and here for the admin screen, a term it never defines.

**Rewrite:** "One `createSectionAction` call builds a reusable wrapper for the screen, and each form action runs through it." / "A screen never calls `createAdminAction` directly."

### N4. A causal "because" the facts do not support

> `Env` is a type parameter for your site's bindings, because the engine ships no `Env` type. (line 180)

**Rule:** Logic, non-sequitur. The blueprint has two facts; the draft joined them with a cause. `Env` is a parameter because the bindings are the site's, not because the engine lacks a type.

**Rewrite:** "`Env` is a type parameter that names your site's bindings. The engine ships no `Env` type, and the example site passes the one its generated `worker-configuration.d.ts` declares." (folds line 181)

### N5. The introduction's second paragraph is a fact list in staccato

> The route's place under `/admin` gives the screen the shell and the sign-in guard. The guard decides nothing per route, so the access check belongs to the screen. An entry's history comes from git. A screen's actions sit outside git, ... Every wrapped action that succeeds must emit an audit record, and both action wrappers audit an access refusal. `cairn-audit` holds the screen to the rules ... (lines 9-15)

**Rule:** No list cadence in prose; voice ("fewer, longer sentences, each one carrying one qualified claim"); missing middle step. "An entry's history comes from git." stands alone with no stated link to the screen, and "wrapped action" and "action wrappers" appear before anything defines them.

**Rewrite:** "The route's place under `/admin` gives the screen the shell and the sign-in guard, but the guard decides nothing per route, so the screen checks access itself. An entry's history lives in git, while a screen's actions, whether they write a site database or call an outside service, leave no commit, and the audit trail becomes their record. Each action that runs through one of the engine's action wrappers emits an audit record when it succeeds, and both wrappers also audit an access refusal. `cairn-audit` then holds the screen to the rules it applies to the engine's admin components. The steps that follow build a screen that renders inside the admin shell, enforces your site's access map on its reads and writes, records each write in the audit trail, and passes `cairn-audit`."

### N6. A precondition carries the wrapper choice

> A screen with no data skips this item. Its actions use `createAdminAction` with the `access` option set, since `createSectionAction` requires a binding resolver. (lines 40-41)

**Rule:** Task-guide anatomy (preconditions state what the steps assume, each with a link to what produces it); restatement of "Choose the action wrapper".

**Rewrite:** "A screen with no data skips this item, and [Choose the action wrapper](#choose-the-action-wrapper) covers its actions."

### N7. The reader in the third person

> A developer builds one for an administrative function the engine does not provide (line 4); A developer who has opened that screen finds each of its calls ... explained in the step that adds it. (line 18)

**Rule:** Google, [second person](https://developers.google.com/style/person); the rest of the page says "your site".

**Rewrite:** "You build one for an administrative function the engine does not provide, such as a report, a tool, or a dashboard." / "The step that adds each of that screen's calls, `requireAccess`, `createSectionAction`, and `ctx.audit`, explains what the call is for."

### N8. Sentences the reader's stack docs already own

> `sequence`, which `@sveltejs/kit/hooks` exports beside the `Handle` type, composes several handles into it and runs them in order. (line 248)
> The default `update()` resets the form and refreshes the page's data on `'success'` only. It then calls `applyAction` for a same-page result and for every `'redirect'`. (lines 397-398)

**Rule:** Extend-track counterpart question ("would a competent SvelteKit developer find any sentence here that their stack's docs already own?"); the introduction lists server hooks and `enhance` as assumed knowledge. Line 248 is also a mild appositive stack (noun, `which` clause, then the predicate).

**Rewrite:** cut line 248 (the step and code show `sequence`). For 396-398, keep the consequence and the existing link: "On an `'error'` result, the default `update()` calls `applyAction`, which renders the nearest error page and destroys the dialog. For the callback's full contract, see SvelteKit's [Customizing use:enhance](...) section."

### N9. Facts filed in the wrong section, and two the reader does not need

> A Cron `scheduled` handler that holds an `ExecutionContext` passes `ctx.waitUntil.bind(ctx)` instead. (line 285)
> `createSectionAction` audits each refusal its checks make, except a rate-limit refusal. The session and CSRF refusals underneath it leave no audit record. (lines 287-288)
> It imports `runtime` from `#chassis/cairn.server.js` and imports no access map. (line 261)

**Rule:** Task-guide anatomy ("Explanation stays subordinate to the steps"; anything more belongs on the reference entry). A Cron handler is outside this task and the reference entry is linked; the refusal-audit facts belong with the wrapper comparison; "imports no access map" answers a question the page never raises.

**Rewrite:** cut line 285 (the linked `createD1AuditSink` entry carries it); move 287-288 to "Choose the action wrapper" after the table; line 261 becomes "It imports `runtime` from `#chassis/cairn.server.js`."

### N10. "Style the screen" notes attached to the wrong steps

> (under step 1) Both admin themes set daisyUI's radius tokens as a corner ladder. `--radius-selector` is `0.25rem` ...
> (under step 2) A bare `btn` with no color, style, or state renders as a hairline button. A `btn` in a selected form ... `btn-link`, the color variants, `btn-outline`, and `btn-dash` keep their look. (lines 376-377, 383-385)

**Rule:** Each such explanation opens tied to the task (anatomy); non-sequitur. The corner-ladder note explains step 2 but sits under step 1, and the button-rendering facts relate to no step about radius.

**Rewrite:** move lines 376-377 under step 2; move 383-385 to a short paragraph after step 3 that opens on the task: "Stock daisyUI buttons need no extra classes in the admin: a bare `btn` with no color, style, or state renders as a hairline button, ..." or cut them to the admin toolkit reference.

### N11. "That feature" with three antecedents

> [Build the dialog form](#build-the-dialog-form), [Load row detail on demand](#load-row-detail-on-demand), and [Animate the screen](#animate-the-screen) apply only to a screen with that feature. (line 19)

**Rule:** Logic, ambiguous reference.

**Rewrite:** "The dialog form, row detail, and animation sections apply only to a screen that has a dialog, rows that expand, or motion." (Drop the three in-page links here; the headings sit a scroll away and the links recur at B5's hand-offs.)

### N12. Verify steps 3 to 5: a missing result, a redundancy, an obscured command

> 3. In the owner's browser, submit one of the screen's actions. (no expected result)
> The row names the action, and its `action` and `entity` match the wrapper's options. (line 615)
> 5. In the site directory, run the scaffold's `check:cairn` script with npm. (line 624)

**Rule:** The verification section names the observable result (anatomy item 4); commands sit in code font as the reader types them (checklist, highlights).

**Rewrite:**
- Step 3, add: "The action completes and the screen reloads its data."
- Step 4 result: "The row's `action` and `entity` match the wrapper's options, such as `create` and `signup` for the signups screen's `create` action."
- Step 5: "In the site directory, run `npm run check:cairn`." and the symptom "**Symptom:** `npm run check:cairn` exits 1."

### N13. Steps 7 to 11 of "Load row detail on demand" narrate the snippet line by line

> 9. Inside the `try` block, check `response.ok`.
> 10. In the same block, parse the body with `Response.json()`.
> 11. In the same block, cache the detail only after the status check and the parse both succeed, which leaves a failed row retryable.

**Rule:** Extend-track register ("resents padding or hand-holding on it"); the illustrative code already shows each line.

**Rewrite:** collapse 6-11 into "6. In the same file, write an open handler that returns a row's cached detail, and otherwise fetches it, checks `response.ok`, and caches the parsed body only on success." Keep the `fetch`/`Response.json()` note under it; it is the reason the order matters, and it leaves a failed row retryable.

### N14. "Recipe" names the docs' anatomy by metaphor

> The two optional recipes that follow (line 391); The second recipe (line 485)

**Rule:** No figurative language, worst "where it names the docs' anatomy" (the killed "The four arms"). Soft: "recipe" is a dead metaphor common in technical docs. B5's rewrites already remove both.

### N15. Missing link to the sibling section that owns nested-route keying

Lines 147-149 and 500-501 restate how the access map keys nested and dynamic routes, and `restrict-admin-access.md` has a section, "Key nested and parameterized routes" (`#key-nested-and-parameterized-routes`), that owns it. **Rule:** Linking (an existing sibling page referenced but not linked). The N1 rewrite links it.

### N16. Bold-labelled Symptom, Cause, and Fix paragraphs

Lines 85-90, 187-191, 592-596, 607-611, 617-622, 629-633. **Rule:** Vale `Google.Colons` warns on each (capital after a colon), and every sibling extend page that carries symptoms (`theme-your-public-site.md`, `configure-media.md`, `build-the-public-routes.md`) renders them as a `| Symptom | Cause | Fix |` table. The bold-lead pattern also reads as the bold-lead-phrase list default. Soft, because the inline placement under the step is the blueprint's `:::row` form and may be the converter's settled rendering. If it stays, drop the colon into the bold label's sentence rather than starting a new sentence after it, or confirm a Vale exception for the form.

### N17. Vale word-list warning

> The following tree shows the source files that the steps touch (line 48)

**Rewrite:** "The following tree shows the source files that the steps change, with the new screen's directory named after the example site's."

### N18. The toolkit list duplicates the reference

Lines 299-309 list all eleven primitives with one-line jobs, and the page links the admin toolkit reference, which lists every export with its props. Soft: the list helps a reader pick primitives in step 1, but if it stays, it should match the reference's descriptions word for word or shrink to the three the example uses plus the link.

### N19. For the claims checker

> Each primitive ships its compiled classes and its scoped styles with the package. A later release still renders it under your route with no change on your side. (lines 357-358)

The second sentence is a forward stability promise (fact `7m5o61`). Confirm the fact states it at this strength and that the toolkit's stability tier backs it; otherwise qualify it ("A later release in the same major version ...").

Spot-checked and not flagged: `building` from `$app/env` and `SubmitFunction` from `$app/forms` both match the showcase on `@sveltejs/kit` ^3.

## Verdict

The draft reads as a plausible cairn extend page in most of its body: the steps name the place before the action, the code is traced to the showcase, the D1 and SvelteKit vendor details sit behind links, and tellgrader and Vale's error tier come back clean. It fails on structure, not voice. The page's central promise, that every write is audited, has no step, a verify step buries its own prerequisite, and the row-detail step hides two actions in a note. The two over-cap sentences and the positional hand-offs are mechanical fixes. Beneath that, the most audible slip is restatement: the guard's per-route silence is told three times, the binding-resolver requirement four, and the reader skims past repeats until they stop trusting the page to be terse. The single change that would move it most is adding the `ctx.audit` step (B1) and making the same pass for repeats (N1), which together also shorten the two disproportionate prose blocks after the code samples.
