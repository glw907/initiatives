# Register edit: Add a second sign-in group

- Page: `docs/extend/add-a-second-sign-in-group.md` (worktree `rd-add-a-second-sign-in-group`, commit 2e8e7a827)
- Track: extend, task guide. Base guide: Google. Brief: "Drafting brief: developer docs", plus "Names", "The page anatomies", and "The extend track".
- Blueprint: `blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml`. The page follows its section order and hand-offs. Per the brief, I did not grade hand-offs the plan places for whether they exist or where they sit.
- Verdict: **fix**. There are 5 blocking base-guide findings and 21 non-blocking findings (26 total).

## Deterministic floor

`tellgrader --register docs` (profile `docs-register`) exited 0 with **no findings** and no gate. Counts: exclamation 10 (all inside code or JSX, so not prose), tricolon 6, uniform-paragraph 5.

Vale reported 0 errors, 22 warnings, and 24 suggestions. None of them blocks the page:

- `Google.WordListCase` "admin": a misfire. "admin" is the sanctioned product term (Names, extend vocabulary).
- `Google.WordList` "CLI" (line 28): Names requires "the `cairn` CLI", so this is a misfire.
- `Cairn.NamesRetired` "the package" (lines 32, 158, 162): each one is a package fact (the `engines.node` field, a file in the tarball), which the table allows.
- `Google.OxfordComma` (lines 3, 7, 29, 671): each one is a "such as" phrase or a pair, so the rule is misreading the line.
- `Google.Contractions` and `Google.Passive` suggestions: advisory only. Contractions are still Google's recommendation and no deviation row overrides them. A light pass on the "is not" and "does not" in steps would align the page with the guide, but it isn't required.

### Measurements

| Measure | Value | Source |
|---|---|---|
| sentences (prose) | 248 | tellgrader `measures` |
| hinged_pair_share | 0.351 | tellgrader `measures` |
| short_sentence_share | 0.190 | tellgrader `measures` |
| words | 5,638 | tellgrader |
| average sentence length | about 14 words | my count, with list items split |
| longest sentence | 35 words (line 3, in the introduction, so exempt from the cap) | my count |
| paragraphs and list blocks | 153 | my count |
| disproportionate | Line 5 (second introduction paragraph, 6 sentences) repeats what the "Choose the mechanism" table carries. "Resolve a failed setup" holds 12 items, about one sixth of the page, and restates recovery prose inline. The continuation under Deploy-the-role step 4 (line 182) is four sentences of caveat inside a step. | my reading |

Neither share has a band, and neither gates anything.

---

## Blocking findings (base guide)

### B1. A condition comes after its instruction (3 instances). BLOCKING

Rule: brief Structure checklist, "A sentence states its condition before its instruction" (Google highlights). Line 494 also breaks "Each step holds one action."

- Lines 162 and 168: step 1 says "copy `0001_roles.sql` ..." and its continuation then says "If the site's `migrations` directory already holds the file, skip this step."
  - Rewrite step 1: "1. If the site's `migrations` directory doesn't hold `0001_roles.sql`, copy it from the package's `migrations` directory." Keep the `cp` block and delete the trailing skip sentence.
- Line 318: "add the Turnstile secret key as `TURNSTILE_SECRET`, creating the file if needed."
  - Rewrite: "4. In `.dev.vars` beside the Wrangler config, add the Turnstile secret key as `TURNSTILE_SECRET`." The continuation can say: "If the file doesn't exist, create it." Better still, make that the step before step 4.
- Line 494: "confirm that `test.server.deps.inline` lists `@glw907/cairn-cms`, as the scaffold's config does, and add it if it's missing."
  - Rewrite: "1. In `vitest.config.ts`, if `test.server.deps.inline` doesn't list `@glw907/cairn-cms`, add it." The continuation can say: "The scaffold's config already lists it."

### B2. A step folds in an action the page never gives (line 176). BLOCKING

Rule: "Each step holds one action" (Google procedures). Missing middle step.

- Quoted: "3. In the project directory, after a local build, run `cairn doctor`."
- The local build is a separate action, and no step on the page performs it. Step 5 is the first step that builds. The continuation even admits that the check "reports only that it needs one build" until a build exists.
- Rewrite: split it into two steps:
  - "3. In the project directory, build the site." Show the site's build command. Claims check: confirm the command, `npm run build` on a scaffolded site.
  - "4. In the project directory, run `cairn doctor`."
  - Renumber the steps after these.

### B3. A list item runs over 26 words (line 12). BLOCKING

Rule: the 26-word cap on a list item. The introduction exemption covers introduction sentences. This is a list item, and the cap names list items explicitly.

- Quoted (30 words): "The channel path provisions a database, writes the channel module, builds the login route and the member area, and ends a removed member's sessions early with `verify` or `revokeSessions`."
- Rewrite: "The channel path provisions a database, writes the channel module, and builds the login route and the member area. It ends a removed member's sessions with `verify` or `revokeSessions`, and it tests the channel on Node with Vitest and `createChannelDb` before the deploy."
  - Each sentence is under 26 words.
  - Dropping "early" here is fine, because the section heading carries the idea.

### B4. "Resolve a failed setup" uses a numbered list for items with no order (lines 623 to 671). BLOCKING

Rule: "Parallel items that need no order form a bulleted list" (Google lists). The register's numbered-list rule covers "checks the reader runs in order". These 12 entries are a catalogue of symptoms that the reader matches against, not a sequence the reader runs. The lead sentence orders them by path, not by procedure.

- Rewrite option 1: make the 12 entries a bulleted list, keeping each entry's symptom, cause, and "If ..." fix.
- Rewrite option 2: split the section by path under two task headings ("Resolve a role failure" and "Resolve a channel failure"), each with a bulleted list.
- Both rewrites change the blueprint's form for this section, so the fix belongs in the plan as well as the page.
- Related, non-blocking: anatomy item 5 says failure paths "point at the track's recovery surface ... rather than restating recovery prose inline". Twelve inline entries strain that rule. The plan placed them, so raise it with the plan owner rather than cutting them here.

### B5. A destructive precondition sits in preamble prose with no action (line 158). BLOCKING

Rules:
- "A sentence states its condition before its instruction."
- Task anatomy item 2: preconditions are stated before the steps, each with a link to whatever produces it.
- Google notices: a prerequisite precedes the step.

Quoted: "Applying it rebuilds the `editor` table with only the engine's four columns. A site that added columns to that table carries them across first."

- The page never says how to "carry them across".
- Step 2 then applies the migration with no condition-first guard, so a reader who added columns loses them.
- Rewrite: add a conditional step before step 2, such as "2. If you added columns to the `editor` table, copy their data out before you apply the migration, because applying it rebuilds the table with only the engine's four columns."
  - Alternatively, state the precondition in "Before you begin", under the role items.
  - Claims check: whether existing rows survive the rebuild. Link the migration's reference if one documents this.

---

## Non-blocking findings (register), most severe first

### R1. Balanced halves (hunted first)

Tell: balanced-halves constructions and the two-beat closer.

- Line 48: "A role suits a group that an owner adds person by person and that works in screens under `/admin`. A channel suits a group whose roster the site already keeps and that never needs the admin. Whichever fits, what a member, a staff assignment, or a signup means is the site's to model, and cairn only signs the people in."
  - The first two sentences mirror each other.
  - The third sentence is a capper that restates line 3.
  - Rewrite: this also fixes R11 by replacing the empty one-step procedure at lines 50 to 52.

    > Make the choice before you build anything:
    >
    > - If an owner adds the group's people one at a time and they work in screens under `/admin`, build a role.
    > - If the site already keeps the group's roster and its people never need the admin, build a channel.

    Delete the "Whichever fits" sentence.
- Line 220: "The site supplies the routes, the code's delivery, and the roster, and the factory owns the codes, the sessions, and revocation."
  - This is a symmetric triad against a triad, and line 7 already says it ("Its factory mints and consumes the codes ... The site supplies the delivery, the roster lookup, and the check that a requester is human").
  - Rewrite: "It ships no route or UI, so the site builds the login route and the member area." This keeps the one new fact and points back to nothing.

### R2. Restatement across sections

Tell: no restatement or filler; a phrase recycled across the page.

- The two-mechanism comparison appears four times:
  - intro line 5
  - line 38 ("A second group signs in either as a declared role ... or through a separate login ...")
  - line 58 ("A role adds the group to the editors' roster at `none` capability", which repeats line 5 word for word)
  - line 425 (a channel session never populates `locals.cairnEditor`, the fourth statement)
  - Rewrite: cut line 38's first sentence and keep only the table's lead ("The following table compares the two mechanisms by where each keeps its people and what the site builds."). Open line 58 on the running example rather than the definition.
- "numeric code, 8 digits by default" appears at lines 42, 220, and 575. Keep the table cell and line 575's assertion note, and cut it from 220.
- Line 14 ("The two paths share no steps, so a developer sent here for a `none` role or for a channel builds only that one.") repeats line 54.
  - "a developer sent here" also talks to a reader the page can't see.
  - Rewrite: "The two paths share no steps."
- Line 186 (continuation of step 5) and line 192 both say that the add action validates the posted role against `runtime.roles`. Cut line 186's continuation, which also removes the undefined "admin mount" (R7).
- Line 473's first sentence repeats the reasons in steps 360 and 431 (prerender would bypass the gate). Cut it.
- Line 32's runtime-floor caveat ("Nothing enforces that floor at runtime, and npm only warns") repeats in failure 6. Keep it in failure 6, and cut it from the precondition.
- Line 479: "with `verify`, with `revokeSessions`, or with both. A site uses either or both of the following:"
  - Rewrite: "A channel session lasts 30 days by default. A site ends a removed member's sessions early with either or both of the following:"

### R3. A garden-path sentence (line 330)

Tell: clarity. The word "types" reads as a noun, then turns out to be a verb.

- Quoted: "The generated `Env` types that export, and the module's local `Env` types only what `resolveDb` receives."
- Rewrite: "The generated `Env` type describes that export. The module's local `Env` describes only the binding `resolveDb` receives."

### R4. Non-sequitur on "one declaration serves both handles" (line 64)

Logic check.

- Quoted: "`devBackendHandle` takes the same required `runtime`, so one declaration serves both handles. The dev backend reads only `runtime.access` from it, never the vocabulary."
- The second sentence undoes the claim the first one makes.
- Rewrite: "`createAuthGuard` reads that vocabulary from `runtime.roles`. `devBackendHandle` takes the same `runtime` but reads only `runtime.access`, so the vocabulary changes nothing under the dev backend."
- Also a missing middle step: the page never says how the adapter's `roles` member becomes `runtime.roles`. One clause or a link to where the runtime is composed would close the gap.

### R5. Likely factual imprecision, flagged for the claims checker (line 119)

Truth-adjacent check.

- Quoted: "SvelteKit runs a form action without its page's load function."
- SvelteKit runs the action first, then reruns load functions to render the result. So the load runs, but only after the action, and it can't gate the action.
- Rewrite, once verified: "SvelteKit runs a form action before the page's load function, so the load's role check never gates the action."

### R6. A step continuation that argues against its own step (line 182)

Logic check; explanation subordinate to steps.

- The paragraph says the condition is a type error on this engine and that such a guard throws when hooks load. It then says the warning concerns "a site whose hooks escape the type check". A guard built that way still throws at load.
- So the reader can't tell when step 4 can ever fire.
- "On this engine" and "an older engine" are version-relative without a version.
- Rewrite: keep one sentence under the step: "The warning means `createAuthGuard` doesn't receive `{ runtime }`; Resolve a failed setup gives the fix." Move the history to the `cairn doctor` reference entry, or drop it.

### R7. Undefined or internal terms

Extend vocabulary: nothing is banned, but imprecision is.

- Line 319: "as a site from the Deploy-button tree does".
  - "Deploy-button tree" exists only in internal plans.
  - Rewrite: "If your site carries `.dev.vars.example`, add `TURNSTILE_SECRET` to it with an empty value." Drop the attribution, or name the template repository the published docs use.
- Line 186: "The admin mount forwards its runtime". The term is undefined and the sentence is redundant (see R2). Cut it.
- Line 278: "the member's subject" is used before line 336 or 473 defines it.
  - Rewrite: "which resolves to a stable identifier for the member, its subject, or `null`." Alternatively, define it in the section lead.

### R8. The role verification assumes the tester can be "one of the role's people" (line 209)

Missing middle step.

- The channel path handles this ("make sure a contact you can receive a code at is on the roster", line 611). The role path doesn't.
- Rewrite: add a first check: "1. On `/admin/editors`, make sure an email address you can receive is on the roster with the `staff` role."

### R9. Crafted pivot (line 152)

Tell: no crafted pivots or cappers.

- Quoted: "The link is not the gate: the screen's role check refuses everyone else, whatever the sidebar shows."
- Rewrite: "The `roles` list controls only whether the link shows, and the screen's role check refuses every other role."

### R10. The introduction's second sentence (line 3)

Tells: appositive mid-stack, a `so` hinge, and loose wording.

- Quoted: "The sign-in that cairn ships exists only to gate the admin, so by default it knows only the people who work there, owners and editors, and it signs them in by an emailed magic link."
- Problems:
  - "only ... only" is doubled.
  - "the people who work there" uses "there" for the admin, which is colloquial.
  - The appositive is wedged mid-sentence.
- Rewrite, following the approved appositive-stack move: "cairn's sign-in exists to gate the admin. By default it signs in owners and editors, by an emailed magic link."

### R11. An empty one-step procedure (lines 50 to 52)

Tell: micro-instruction filler.

- Quoted: "Make the choice before you build anything: - Choose the mechanism whose column fits your group."
- Replace it with the condition-first bullets in R1.

### R12. Terminology drift

Names discipline: one name per thing.

- "welcome view" (line 91), "a welcome screen" (line 45), and "the minimal signed-in welcome screen" (line 633) name one thing. Pick one. The component is `WelcomeView`, so "welcome view" matches line 91.
- "route rule naming `staff`" (lines 117, 637) and "map key" or "the deepest matching key" (lines 117, 641, 643) name one thing. Pick "access-map key".
- Failure 5 ends "A site with no access map skips this check", but the entry is a failure, not a check. Rewrite: "This failure can't occur on a site with no access map."

### R13. Ambiguous modality

Logic check: is this a rule for the site or a description of the engine?

- Line 280 and line 481: "the function never reads request-shaped data" / "`verify` ... never reads request-shaped data".
  - Rewrite: "`lookup` receives only `{ env }`, never the request."
- Line 473: "the page loads the member's records by it from the site's store". The example page doesn't do this.
  - Rewrite: "A member page loads the member's records from the site's store by that subject."

### R14. The introduction's not-covered list is not parallel, and one pronoun is ambiguous (line 18)

Rules: "Every item in a list shares one form"; ambiguous antecedent.

- Items 2 and 3 open on the linked page. Item 1 opens on the group.
- "it owns access maps themselves" leaves unclear whether "it" means the page or the group.
- Rewrite: "[Restrict admin access](restrict-admin-access.md) covers access maps and a group whose people write the site's content. Such a group needs editor capability, because `none` capability closes the engine's content screens, and this page configures no access map."

### R15. Overlinking

Wikipedia linking guideline: link at first occurrence only.

- `defineRoles` links to `../reference/core.md#defineroles` at line 58 and again at line 91, within one section. Drop the line 91 link, or rewrite that sentence as "The `defineRoles` entry lists every validation rule."

### R16. Vendor specifics without a link

Register: a vendor's specifics get a link, never a copy.

- Line 599: "The command creates a new Worker version and deploys it at once." This restates Wrangler behavior that can change, for example under gradual deployments. Link Cloudflare's Workers secrets page beside it. I'm not proposing a URL I haven't verified.
- Line 28: "or from a release archive". This is unlinked. Link the `cairn` CLI's install section on its reference page, if one exists.

### R17. Failures 10 and 11 share one symptom

The structure doesn't help the reader.

- Both open "The request answers that a code was sent, but no code arrives", and only the logs tell them apart.
- Rewrite: merge them into one entry whose fix reads the request record. An `outcome` of `'unknown'` means not on the roster, `'lookup_failed'` means `lookup` threw, and a delivery-failure record means `deliver` threw.

### R18. "actually" (lines 31, 345)

Tell: softener or intensifier family.

- Quoted: "the channel's `challenge` must actually verify a human".
- The contrast with a stub that returns `true` is real, so this one is soft. Saying that contrast outright is stronger: "must verify a human, never return `true` unconditionally."

### R19. A lead that describes the list (line 623)

Tell: no prose about the docs' writing, plus a reflexive triad.

- Quoted: "Each failure in the following list names its symptom, its cause, and its fix, with the role path's failures first and the channel's after them."
- Rewrite: "The following failures cover the role path first, then the channel." Or drop it after the B4 split.

### R20. The channel verification fuses an action with a check (lines 616 and 617)

Rules: one action per step; precision.

- "6. Confirm that the login page returns." "returns" is vague. Rewrite: "6. Confirm that the page redirects to `/members/login`."
- "7. Confirm that `/members` now redirects to the login page." The reader must open `/members` first, so split it into "Open `/members`." and "Confirm that it redirects to `/members/login`."

### R21. Awkward phrasing (line 228)

Quoted: "bound beside `AUTH_DB` and never as it".

Rewrite: "The channel keeps its codes and sessions in a separate D1 database under a binding of its own, never `AUTH_DB`."

---

## Clean dimensions

- **Generic examples:** clean. `staff`, members, customers, and signups are all generic, and no consumer-site domain appears.
- **Coding assistant:** no assistant is assumed, and no agent content appears.
- **Names:** clean. "the setup command" follows a first mention of `create-cairn-site`. The page uses "the `cairn` CLI" with its verb, "second sign-in group", "Worker", and "the engine".
- **Headings:** sentence case, bare infinitives on every task section, no teaser or two-headed headings, and no skipped levels.
- **Code font and bold:** correct throughout.
- **Marketing or virtue claims:** none.
- **Coverage against the blueprint:** the page follows the blueprint's sections and order.

## Verdict

The page reads as its register's plausible human author for most of its length. The steps are concrete, the code is load-bearing, and the voice is measured. It fails on structure, not voice:

- three conditions come after their instructions
- one step hides an unlisted build
- one introduction list item runs over the cap
- the failure catalogue is numbered as if it were a sequence
- the destructive `editor`-table rebuild warning has no condition-first step

These five block the page. Beyond them, the strongest register residue is restatement. The two-mechanism comparison is said four times and the factory-versus-site split twice, and the "A role suits ... A channel suits ... Whichever fits" balanced triple is the one Geoff would catch first. The single change that would move the page most is to rewrite "Choose the mechanism" as condition-first decision bullets (R1) and cut the repeated framing that it makes redundant (R2). After that, fix the five blocking structure findings.
