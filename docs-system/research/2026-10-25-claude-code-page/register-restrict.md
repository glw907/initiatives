# Register edit: docs/extend/restrict-admin-access.md

Page: `docs/extend/restrict-admin-access.md` in worktree `rd-restrict-admin-access`, commit 614cf2ca3.
Track: extend (task guide), base guide Google, developer brief of `docs/internal/docs-register.md`.
Blueprint read for intent: `blueprints/docs/extend/restrict-admin-access.blueprint.yaml`. Hand-offs
are placed by the blueprint, so only their wording is graded here.

Verdict: **fix**. 26 findings, 6 BLOCKING.

## Deterministic floor

`tellgrader --register docs` exited 0 with no findings and no gate. Profile `docs-register`
resolved. Counts: exclamation 1 (in a quoted UI string, not a defect), tricolon 1,
uniform-paragraph 5.

| Measure | Value | Source |
|---|---|---|
| sentences | 184 | tellgrader `measures` |
| hinged_pair_share | 0.348 | tellgrader `measures` |
| short_sentence_share | 0.103 | tellgrader `measures` |
| average sentence length | about 15.7 words | own count (237 sentences, steps included) |
| longest sentence | 41 words (line 15, the intro contract sentence; exempt) | own count |
| paragraphs | 108 | own count |
| disproportionate paragraphs | Lines 131-138 (the map checks: eight sentences carrying three checkers) and lines 255-259 (redeploy lead-in carrying setup-command detail) | own reading |

Vale (repo config): 0 errors, 29 warnings, 27 suggestions. The warnings that matter are
`Cairn.ProseProcedure` at line 376 (finding B4) and `Google.WordListCase` "chapter" at lines 257
and 259 (finding N9). The 21 "admin" warnings are a register question (N20). The `Google.Colons`
warnings on lines 26-30 are false positives because each capital after a colon begins a page title.
`Cairn.NamesRetired` "the package" at lines 235 and 241 is the right sense (a fact about files in
the tarball), so it needs no change.

26-word cap: no step or list item runs over 26 words. The sentences over 26 words at lines 34, 59,
134, 197, 208, 224, 255, 295, and 348 are introductions or explanations inside task sections. The
cap does not apply to them: "The 26-word cap counts each sentence on its own and applies only to a
step, a list item, or a sentence in a task section; an introduction or explanation sentence is
exempt." Lines 197 and 295 have other problems (N6, N19).

Not found: agent content, consumer-site domain examples (webmaster, signups, and
`/admin/money/refunds` are generic), marketing claims, virtue claims, softeners, the intensifier
"own", question or teaser headings, Diataxis vocabulary.

---

## BLOCKING

### B1. Role name `webmaster` out of code font beside coded role names (base guide: code font)

Line 65, step: "maps `owner` to `'owner'` and both `editor` and webmaster to `'editor'`."
Line 99, step: "add a `media` key that admits webmaster".
Line 366, step body: "Add webmaster to the key."
The same thing happens in prose at lines 18, 60, 101, 136, 341, 362, and 370.

Rule: "Commands, code identifiers, file names, and paths sit in code font." A role name is a string
key the reader types into `defineRoles` and `defineAccess`, as the excerpt shows
(`webmaster: 'editor'`, `['webmaster']`). The page sets `owner` and `editor` in code font in the
same sentences, so leaving `webmaster` plain reads as a different kind of thing.

Rewrite: put `webmaster` in code font wherever it names the role key, for example "maps `owner`
to `'owner'` and both `editor` and `webmaster` to `'editor'`" and "add a `media` key that admits
`webmaster`". It can stay plain only where the prose means people in general ("a webmaster
editor"). The simplest fix is to use code font everywhere.

### B2. Select options in code font instead of bold (base guide: UI labels in bold)

Line 282: "choosing `webmaster (editor)` as its **Role**".
Line 308: "choose `editor` in the test editor's role select".
Line 326: "choose `webmaster (editor)` in the test editor's role select".

Rule: "UI labels sit in bold." An option in a select is a UI element the reader picks. Code font
belongs to text the reader types or reads as output, and the reader types none of this.

Rewrite: "In `/admin/editors` on the deployed site, as the owner, add the test editor through the
**Add editor** form, choosing **webmaster (editor)** as its **Role**." Do the same in steps 2 and
7. Line 278 describes how the list renders, so the code span can stay there.

### B3. Steps with more than one action (base guide: each step holds one action)

Verify step 2: "choose `editor` in the test editor's role select, then select **Change**."
Verify step 7: the same shape.
Verify step 10: "select **Delete** on the signup you added, then **Delete** in the confirmation
dialog."
Verify step 9 ("enter a name and an email, then select **Add**") is one form submission and is
borderline.

Rule: "Each step holds one action." The brief states this literally. If Geoff reads Google as
allowing short combined actions, steps 9 and 10 can go back, but steps 2 and 7 are a pick plus a
save, two separate actions.

Rewrite (steps 2 and 7):

```
2. In `/admin/editors`, in the test editor's row, choose **editor** in the role select.
3. In the same row, select **Change**.
```

Step 10 becomes "On the signups screen, select **Delete** on the signup you added." followed by
"In the confirmation dialog, select **Delete**." Renumber after the split.

### B4. A procedure written as prose in Resolve step 6 (Vale `Cairn.ProseProcedure`; brief: a sequence of actions is a numbered list)

Lines 376-377: "For a Worker that predates the map, redeploy as [Deploy the changes] does. For a
`requireEditor` call, replace it with `requireAccess` as [Enforce the map on your routes] does,
then redeploy."

Two branches and a chained "then" sit inside one step body. Step 7 repeats step 6's first branch
("the deployed Worker predates the map ... Redeploy").

Rewrite (replaces steps 6 and 7):

```
6. If the signups screen opens for an `editor` session and the route's `load` calls
   `requireEditor`, replace that call with `requireAccess` as
   [Enforce the map on your routes](#enforce-the-map-on-your-routes) does.
7. If the signups screen or the media library still opens for an `editor` session, the deployed
   Worker predates your edits.

   Redeploy as [Deploy the changes](#deploy-the-changes) does.
```

### B5. A data-loss precondition hidden in explanation, with no step or precondition (anatomy: preconditions; a prerequisite precedes the step)

Line 236: "Applying it rebuilds the `editor` table with only the engine's four columns, so a site that
added a column to `editor` carries it across first."

Applying the migration drops any site-added column from `editor`. The page gives no precondition,
no step, and no link for carrying the column across, and the reader meets it in a trailing "so"
clause. That is a missing middle step on a destructive operation. The claims checker should also
confirm what "carries it across" involves. Do not invent a procedure.

Rewrite: add a "Before you begin" item and take the clause out of the Deploy paragraph:

- "If your site added a column to the auth database's `editor` table, a way to restore it:
  applying `0001_roles.sql` rebuilds the table with only the engine's four columns."

If a page covers how to carry the column across, link it. If none does, file it as docs friction.
Then the Deploy lead-in can read: "Applying `0001_roles.sql` rebuilds the `editor` table, as
[Before you begin](#before-you-begin) notes."

### B6. "Two points" followed by three checkers (logic: internal contradiction)

Lines 131-135: "The map is checked at two points. `defineAccess` checks it at construction: ...
When the admin routes are built at server start, `createContentRoutesContext` runs the key
checks. ... `composeRuntime` checks only the map's role names against the vocabulary."

The paragraph names three checkers after promising two. The sentence is false as written. It is
also passive.

Rewrite: "Three calls check the map. `defineAccess` checks it at construction and throws a
`defineAccess:` error on an empty map, an empty role list, a role name outside the vocabulary, or
a malformed key. `composeRuntime` checks the map's role names against the vocabulary. At server
start, `createContentRoutesContext` throws an `access:` error on a screen id that is neither a
declared concept nor a fixed screen, and on a route key that collides with a built-in admin view."
If `composeRuntime`'s check is the same check as `defineAccess`'s role-name check run again, the
claims checker should say so. In that case, cut the `composeRuntime` sentence and keep "two".

---

## Not blocking (register, logic, links)

### N1. Balanced halves in hand-offs (tell: balanced-halves constructions; this is what Geoff catches most)

- Line 141: "The engine now enforces the map on its screens, and your routes enforce it through two
  calls." The two clauses are set against each other for symmetry. The first half is also false at
  this point, because the deployed engine enforces nothing until the Deploy section. Rewrite:
  "Your routes enforce the map through two calls."
- Line 229: "The edits are complete in the site's files, and the deployed site does not have them
  yet." Rewrite: "The deployed site still runs without these edits."
- Line 276: "An owner can add and remove editors and change their roles, and an editor can do none
  of these." Rewrite: "Only an owner can add or remove editors and change their roles."
- Line 34: "The steps need a site with an admin route that does not yet check the access map, and
  the checks need a deployed site you can redeploy and a second person to sign in as." The list
  below repeats this. Rewrite: cut the sentence, and keep "Before you start, have the following in
  place:" as the lead-in.

### N2. Trailing-hinge paragraph at lines 80-84 (owner ruling: the trailing hinge)

"`composeRuntime` carries it onto the runtime, and the guard attaches it to every admin request, so
the guard takes no second copy. [`createAuthGuard`] takes the composed runtime as its required
`runtime` and reads `roles` and `access` from it. `devBackendHandle` takes the same runtime, and
one declaration serves both handles."

Most sentences hang a consequence clause, and the guard's attachment is the third time the page
states it (lines 13 and 146 are the others).

Rewrite: "The map goes on the adapter as its `access` member, and nowhere else. `composeRuntime`
carries it onto the runtime. Both handles take that runtime:
[`createAuthGuard`](../reference/sveltekit.md#createauthguard) reads `roles` and `access` from it,
and `devBackendHandle` receives it too. The scaffold's `src/hooks.server.ts` already passes the
runtime to both handles." (See N14 on what `devBackendHandle` does with it.)

### N3. Hinge run and buried caveat at lines 233-237 (owner ruling: the trailing hinge)

Lines 233 (", so"), 235 (", and"), and 236 (", so") repeat one cadence. B5 moves the line-236
caveat out. Rewrite of the rest: "The roster and the per-role checks run on the deployed site.
Before you redeploy, apply `0001_roles.sql` to the auth database with Wrangler. A vocabulary beyond
the default pair needs it. A scaffolded site already holds the file in `migrations/`. A site
scaffolded before the file shipped copies it from the package."

### N4. The same fact restated across sections (tell: no restatement or filler)

- Line 46 against line 50: "The map admits roles by name, so the vocabulary comes first." followed
  directly by "The access map admits roles by name, so the site first declares its role vocabulary,
  ...". Rewrite line 50: "The role vocabulary maps each role name to the capability it resolves
  to."
- Line 13 against line 146: "decides no per-route authorization" appears twice in the same words.
  Rewrite line 146: "The guard admits a signed-in session to the `/admin` subtree before any
  `load` runs, and the route itself decides which roles reach it."
- Line 8 against line 78: "An owner reaches every mapped target whatever the map lists." and
  "...whatever its list says." Cut line 78. The introduction already states it.
- "Refuses every session, owner included" appears at lines 103, 177, 178, 227, and 354. Line 178 is
  the clearest duplicate: "A route that calls `requireAccess` with no rule for its path is treated
  as a misconfiguration, and the refusal reaches owners too." Rewrite: "cairn treats a route with
  no rule as misconfigured." This also removes a passive.
- Lines 53-54 ("The map widens access in one case only: ...") restate intro line 9. Keep one. The
  roles section is the better home, because it defines `none`.

### N5. "Floor", "narrows", and "widening" make a mixed figure in the model sentences (tell: no figurative language; definitional position)

Lines 5-9: "capability is the floor cairn enforces. The access map narrows that floor. ... The one
widening is a `none` role".

A floor is a lower bound, yet the map narrows it and a `none` role widens it. The figure sits where
the page defines its model, which the brief calls the most damaging position. The blueprint
supplies "floor", so this may be engine vocabulary. Flag softly and ask whether Geoff wants it.

Rewrite: "Each role resolves to one of three capabilities, `owner`, `editor`, or `none`, and cairn
always enforces capability. The access map restricts it further. ... The one exception is a `none`
role, which a route rule can admit by naming it."

### N6. Overstated universal at line 197 (Russell: overstated universals; flag for the claims checker)

"With every target keyed, no engine write action stays outside the map: ..."

The roster's add, remove, and change actions are gated by owner capability, and roster is not a
map target (the fixed screens are `media`, `vocabulary`, `nav`, and `settings`). So "no engine
write action" looks too broad, and the next sentence points to what the map still leaves
uncovered. The colon close is also a trailing tail.

Rewrite: "With every target keyed, the tidy and personal-dictionary actions gate against the entry's
concept like any entry action, and the site-wide publish filters each entry by its concept." The
claims checker should confirm the roster exception.

### N7. "Editor-capability roles" contradicted two sentences later (Russell: overstated universal)

Line 7: "each key lists the editor-capability roles that reach that target." Line 9 then says a
route rule can list a `none` role. Rewrite line 7: "each key lists the roles that reach that
target." Line 9 already carries the exception.

### N8. Imperatives outside steps (brief: imperatives only in steps, task headings, cross-references, notices)

- Line 191: "To admit only named roles to every engine screen, map every concept and fixed screen
  until `config.access_unmapped` no longer fires." This repeats the single step that follows it.
  Rewrite: "A map is exhaustive when it keys every concept and fixed screen, and
  `config.access_unmapped` then stops firing."
- Line 297: "On your site, open the route you gated in its place, and run its actions in place of
  the signups add and delete." Rewrite: "On your site, the route you gated stands in for
  `/admin/signups`, and its actions stand in for the signups add and delete."

### N9. Setup-command detail in the redeploy lead-in (anatomy: explanation subordinate to steps; Vale `Google.WordListCase` "chapter")

Lines 257-259: "The setup command offers to connect Workers Builds in its chapter 3, during the same
setup run. ... On a site at or past its first deploy, `npx create-cairn-site --dir
<site-directory> --connect` re-enters that chapter."

These sentences explain how to connect Workers Builds, which is not this page's task. "The same
setup run" has no antecedent on this page, and "chapter" trips Google's word list. The line-270
link to [Deploy a change] already covers both paths. Line 256 also ends in a ", which is why"
hinge.

Rewrite: cut lines 257 and 259. Keep "A connected repository deploys on every push to its default
branch." Recast line 256 as: "Neither path applies a migration. That is why the apply step comes
first." If the `--connect` path must stay, it belongs on the linked page.

### N10. An alternate procedure in prose, and a capper (base guide: a sequence of actions is a numbered list; tell: crafted cappers)

Lines 289-291: "For an editor already on the roster, the row's role select picks the new role, and
its separate **Change** button saves it. A role change applies on the editor's next request, with
no new sign-in. One test editor, moved between roles, proves the map."

The first sentence describes a two-action path the reader may need, and the procedure does not
include it. "Proves the map" is an aphoristic close on the hand-off.

Rewrite: add a conditional step to the Assign procedure, "If the test editor is already on the
roster, in its row, choose **webmaster (editor)** in the role select, and then select **Change**."
Split it per B3 if that ruling holds. Then use the line: "A role change applies on the editor's
next request, with no new sign-in, so the checks that follow move one test editor between roles."

### N11. The Resolve lead-in repeats one sentence shape three times (tell: list cadence in prose; restatement)

Lines 348-350 repeat the "X traces to Y" shape three times, and the numbered list then states each
item again.

Rewrite: "Each check pairs a symptom from the verification with the log record or the code that
explains it." Or cut the paragraph and keep "To find the cause, run these checks in order:".

### N12. The verification lead-in packs two claims, one with an anthropomorphic verb (voice)

Line 295: "On the deployed site, the warning logged when the admin routes are built names the targets
the map leaves open, and each role meets the admin's error page wherever the map excludes it."

Rewrite: "On the deployed site, the `config.access_unmapped` warning names the targets the map leaves
open. A role the map excludes gets the admin's error page."

### N13. Quoting of UI strings is inconsistent (Names: a quoted screen string goes in a code span)

Line 319 puts a screen string in double quotes: the heading "You don't have access to this page."
Lines 334 and 340 put status strings in code spans: `Signup added.`, `You do not have access to
this action.`. Use a code span at line 319 too: `You don't have access to this page.`

### N14. `devBackendHandle` "takes the same runtime" but "never reads `runtime.roles`" (Russell: flag for the claims checker)

Line 83 says one declaration "serves both handles". Line 43 says the dev backend never reads
`runtime.roles`. A reader can't tell what the declaration does for the dev handle. Say what
`devBackendHandle` reads from the runtime, or drop "serves both handles".

### N15. Rest versus dynamic parameters, and a missing step in the reasoning (Russell: missing middle step; claims checker)

Line 207 says "a route with a rest or dynamic parameter ... refuses every session until it declares
`target`." Line 208 says "`target` is required on a route that carries a rest parameter or serves
more than one section". The two sentences disagree on dynamic parameters. Step 1 at line 212 says
"such a parameter", which follows line 207. The page also never says why a verbatim parameterized
id under a deeper key resolves to `shadowed` and not to the governing key. A reader cannot
reconstruct that, and Resolve step 2 depends on it. The claims checker should confirm the rule.
Then state the mechanism in one sentence, for example: "The verbatim id, such as
`/admin/money/[id]`, matches the deeper key's prefix rule and not the governing key's."

### N16. The sidebar's owner exception is stated after a sentence that excludes it (Russell: overstated "only")

Line 222: "a keyed entry shows only to the roles its key admits." Line 224 then adds "and to an
owner". Rewrite line 222: "...so a keyed entry shows to the roles its key admits and to an owner."
Cut the repeat at line 224.

### N17. `src/access.ts` appears with no context (completeness)

Line 39: "and the scaffold holds no `src/access.ts`." The page never says why a reader would expect
that file. Either explain it ("Older sites kept the map in `src/access.ts`; [Upgrade cairn] moves
it onto the adapter.") or cut the clause.

### N18. Redundant "skips this step" notes after conditional steps (tell: restatement, hand-holding)

Line 93 ("A site with no `access` member skips it and takes the next step."), line 97, line 171,
and line 247. Each step's opening "If ..." already states its condition, and the base guide's
condition-first rule does the work. Cut these. Keep line 214 ("Any other route skips this step and
the next."), because step 2 has no condition of its own. Better still, give step 2 its own
condition and cut line 214 too.

### N19. Two-beat closer in the readers sentence (tell: balanced halves; Vale `Google.Semicolons`)

Line 19: "Some readers arrive to gate the route of a custom admin screen, and others to close an
engine screen, such as the media library, to most editors; both follow the page in order."

Rewrite: "A reader may arrive to gate a custom admin screen's route or to close an engine screen,
such as the media library, to most editors. The steps serve both in order."

### N20. Register-level, not this page: "admin" against Google's word list with no deviation row

Vale raises `Google.WordListCase` "Use 'administrator' instead of 'admin'" 21 times. The register
permits "admin" (Voice: "an extend page says 'admin' ... freely"; Names: "The editing surface: the
admin"). If Google's word list forbids that form, the permission is an override with no row in
"Deviations from the base guides", which the override test treats as a finding against the
register. "The admin" may instead count as the product surface's proper name, which Google allows.
Either way, Geoff needs to rule: add a row, or add a scoped Vale exception with the reasoning. The
page itself is correct under the register as written. Only Geoff adds a row, and this report does
not propose its wording.

### Minor (not ranked)

- Line 202, heading "Key nested and parameterized routes": "Key" can read as a noun or adjective
  until the second word. "Declare targets for nested and parameterized routes" is unambiguous. No
  outside page links the anchor. Only the internal links at lines 336 and 360 would change.
- Lines 11, 126, 151, and 263 use passives that Vale flags. Only line 11 ("The map is declared
  once") is worth an active rewrite: "You declare the map once, as the adapter's `access` member."
- Line 197, "tidy and personal-dictionary actions": an extend reader meets these names here for the
  first time. Link their reference entry, if one exists.

---

## Verdict

The page sounds like a measured technical report, close to the primary exemplar. Its anatomy is
correct, its example is generic, and it has no marketing, no agent content, and no consumer-site
domain. The weaknesses are mechanical and logical, not voice. Three base-guide breaks recur across
steps: code font for role keys, bold for select options, and one action per step. Resolve step 6
is a procedure written as prose. One paragraph promises two checks and names three. A destructive
migration caveat sits in a trailing clause with no step. Under those, the residue Geoff catches
most often shows up mostly in the hand-offs (N1), and the intro's facts get restated through the
body (N4). The change that would help most is B5 together with B3: move the `editor`-table caveat
into "Before you begin" and split the multi-action steps. B5 removes the one real way the page
could cost a reader data. B3 fixes the most visible guide break.
