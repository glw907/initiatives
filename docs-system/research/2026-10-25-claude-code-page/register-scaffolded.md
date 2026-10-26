# Register edit: docs/extend/scaffolded-site-files.md

- Page: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/rd-scaffolded-site-files/docs/extend/scaffolded-site-files.md` at `74e9f8aa6` (extend track, concept page)
- Blueprint: `blueprints/docs/extend/scaffolded-site-files.blueprint.yaml` (same worktree)
- Base guide: Google developer documentation style guide. Overlay: `docs/internal/docs-register.md` (developer brief, Names, page anatomies, extend track, Deviations).
- Verdict: **fix** (2 blocking, 26 non-blocking)

## Deterministic floor

`tellgrader --register docs` (profile resolved to `docs-register`, exit 0): **no findings and no gates.** The counts are `tricolon` 5 and `uniform-paragraph` 5. Tells per 1000 words: 0.

Vale (repo `.vale.ini`): **0 errors**, so the `check:vale` gate passes. The warnings are the arm's usual baseline. `Google.WordListCase` flags "admin" throughout, but the Names table sanctions "the admin". `Google.Colons` flags the capitalized page titles after colons in the out-of-scope list, which matches the sibling pages. `Google.OxfordComma` fires on lines 12 and 237. Line 12 is a false positive, and line 237 is addressed in N20. The one warning that matters is `Google.WordListCase` "chapter" on lines 314, 316, and 318 (see N5).

### Measurements

| Measure | Value | Source |
|---|---|---|
| sentences | 220 | tellgrader `measures` (prose selector) |
| hinged_pair_share | 0.277 | tellgrader `measures` |
| short_sentence_share | 0.195 | tellgrader `measures` |
| Average sentence length | 13.9 words | own count (270 sentences, code and tables excluded) |
| Longest sentence | 41 words, at lines 3, 7, and 314 (lines 3 and 7 are introduction sentences and exempt; line 314 is explanatory and exempt) | own count |
| Paragraph count | 73 prose and list blocks, with code and tables excluded | own count |
| Disproportionate paragraphs | Line 5 (the introduction's ownership paragraph: six sentences and four ideas, ending on a balanced closer). Line 229 (the dev-backend paragraph, which states one fact twice). Line 314 (the setup-state opener, which joins two separate facts into one 41-word sentence). | own reading |

The two shares carry no band and gate nothing.

## Blocking findings

### B1. A list item reaches the 26-word cap

> The root files, the build and deploy configuration with the Worker's one D1 database, and the migrations, with why an added database takes a separate directory (line 13)

**Rule:** A sentence in a list item stays under 26 words (brief checklist; Google accessibility; deviation row 2). This item is exactly 26 words. The item also packs three body sections and a reason into one bullet. Every other bullet names one or two sections.

**Rewrite:** Split the item to match the body's sections.

> - The root files and the build and deploy configuration
> - The database migrations, and why an added database takes a separate directory

### B2. A link points to a page that doesn't exist on this branch

> `CLAUDE.md` and `.claude/` hold Claude Code's guidance files; see [Using Claude Code with cairn](../claude-code/using-claude-code-with-cairn.md). (line 103)

**Rule:** Link text names its destination (brief checklist, link text). A link whose destination is missing fails the reader no matter how good the anchor is. `docs/claude-code/` doesn't exist in this worktree. The target lives on another branch, commit `3aeac6882` ("Draft Using Claude Code with cairn from its blueprint"). If this branch merges first, the link 404s on `main` and on cairn.pub at the next release.

**Fix:** Merge the Claude Code page first, or merge both together. Otherwise, hold this line until that page lands. The line's form is the sanctioned one-line form and needs no change.

## Non-blocking findings (register), most severe first

### N1. The introduction closes on a balanced-halves pair (tell family checked first)

> An owner who knows which files carry a contract can change the rest freely and change those few with the contract kept. (line 5)

**Rule:** No balanced-halves constructions. This is an echo pair ("change the rest ... and change those few ...") used as a two-beat closer. It is also the line where the paragraph ends on its strongest note (no crafted cappers). The second half restates the paragraph's own premise.

**Rewrite:** Cut the sentence. The paragraph's job is done once the reader knows which kinds of file carry contracts. If the page needs a hand-off to the tree, use: "The file tree marks each file that carries such a contract." Line 48 already says this, so the sentence can move up from there.

### N2. Four words each mean two things on this page (equivocation)

- **"owner."** The page uses it for the person who owns the repository: "An owner who knows" (line 5), "a `.dev.vars` the owner creates" (line 107), and "The settings a new owner edits" (line 16). It also uses it for the role: "signs in an owner with no email" (line 229) and "the zero-config owner and editor floor" (line 227). `owner` is a sanctioned role name, so the collision is real. **Rewrite:** Use "the developer" for the person, as line 298 already does ("the developer edits by hand"). Keep "owner" for the role only, in code font (see N18).
- **"readers."** The page calls the engine, the admin, and the checks "readers": "Ownership still leaves some files with readers that depend on them" (line 5) and "files that only the site reads". Two sentences later, line 7 uses "reader" for people ("A reader who knows the engine's import points"). **Rewrite** for line 5: "Some files still carry a contract, because something else depends on their shape."
- **"branch."** "On the dev branch, `devBackendHandle` installs ..." (line 229). Here "branch" means one arm of an `if`, but on cairn pages "branch" means a git branch (the holding branch). **Rewrite:** "When the dev backend is on, `devBackendHandle` installs ..."
- **"test."** "The test reads the build-time `__CAIRN_DEV_BUILD__` define first" (line 225). "Test" here means the `if` condition, but the page uses "test" for test suites elsewhere (lines 35 and 52). **Rewrite:** "The condition checks the build-time `__CAIRN_DEV_BUILD__` define first, then the runtime opt-in `CAIRN_DEV_BACKEND === '1'`."

### N3. The page repeats itself (No restatement or filler)

- **Ownership** is stated four times. Line 5 says "Every file in that tree belongs to the site. The engine's npm package carries neither Waymark nor the chassis". Line 46 says "Every file in the tree belongs to the site: the engine's npm package carries neither the template nor the chassis". Line 274 says "The engine's package carries none of it, so the chassis belongs to the site like every other file". Line 48 echoes line 5's contract sentence. **Fix:** State ownership once in the introduction. In "The scaffold", cut the line 46 clause after "deploys it, so the tree arrives already live". Cut line 274's second sentence.
- **The definition** in line 33 nearly repeats line 3. Line 33 reads "Waymark, cairn's reference theme, wired onto a chassis of design-neutral plumbing, and the setup command copies both from the same tree the engine runs its tests against". Line 3 reads "Waymark, cairn's reference reading theme, set on a chassis of design-neutral plumbing and copied from the same tree the engine tests itself against". The blueprint defers the definition to this section, so the introduction should state less. **Rewrite** for line 3: "Its files are Waymark, cairn's reference reading theme, together with the design-neutral code in `src/chassis/`." Line 33 then defines the scaffold and names `examples/showcase`.
- **"No `src/access.ts`"** appears at lines 103 and 227. **"No `LICENSE`"** appears at lines 103 and 134. **"One D1 database"** appears at lines 3, 13, and 168, and again as "binds no second database" at line 176 and "only migrations directory" at line 184. **The adapter sharing `src/theme/`** appears at lines 5 and 253. **Fix:** Keep each fact in its own section and cut the echoes. That means lines 103 and 134 drop their negatives, line 176 drops "The scaffold binds no second database.", and line 253 drops its second sentence.
- **Line 249** says the same thing twice in a row: "returns the menus, the site name, and whether the site registers any island ... The load returns `nav`, `footerNav`, `siteName`, and `hasIslands`". The section's last sentence also repeats the 404 section. **Rewrite:** "The root `+layout.server.ts` load returns `nav`, `footerNav`, `siteName`, and `hasIslands`. It reads them from `site-config.ts` and the island registry, not the full adapter, to keep each request that isn't prerendered light. `SiteHeader` and the root `+error.svelte` read those values through `page.data`."
- **Line 229** gives the dev state's lifespan twice: "Its state lasts as long as the server process" and "the overlay lasts until the dev server restarts". See N11 for the rewrite.
- **Line 292** ends by restating the `cairn-audit.config.json` section: "The audit config still names the engine's precompiled `dist` sheet ... The compiled `.cairn/admin.css` is the other sheet the config names, and ... lists both." **Rewrite:** "The audit config names this compiled sheet beside the engine's precompiled `dist` sheet, as [`cairn-audit.config.json`](#cairn-auditconfigjson) describes."

### N4. The page treats a pre-release mechanism as if it exists (presupposition, for the claims checker)

> Only the Deploy-button tree, `templates/waymark/`, carries a template for it. (line 115; also lines 156 and 117)

`templates/waymark/README.md` says, "This template is pre-release. The Deploy button ... land[s] once the button flow has been verified live." A WATCH comment in the same file adds that announcing it now "would promise a Deploy button that does not exist." The phrase "the Deploy-button tree" presupposes a live button, and an extend reader has no definition of the phrase anyway. "The same template build plus an overlay" uses contributor-zone vocabulary ("the bake"). **Rewrite:** "The scaffold ships no `.dev.vars.example`. Local secrets go in a `.dev.vars` file that the developer creates and the `.gitignore` keeps out of the repository. The file holds the following two entries:" Keep the two bullets, and drop every mention of the Deploy-button tree, including the last sentence of the `cf-typegen` cell, until the button ships. Line 44's "The template build writes" becomes "The setup command writes".

### N5. The page uses internal jargon the reader can't decode (extend vocabulary contract: imprecision)

- **"chapter"** (lines 314, 316, and 318: "its Workers Builds chapter", "any chapter that has not yet run", "The chapter registers"). "Chapter" is a term from the setup command's source and tests. It appears on no other published page, and Vale flags it. **Rewrite:** Use "step": "when the setup run's Workers Builds step connected the repository", and "a saved answer for any step that hasn't run yet".
- **"Its rebuild keeps only the engine's four `editor` columns, so a site carries any columns it added across first"** (line 186). "Rebuild" and "carries across" are undefined. See N10.
- **"reusing an existing build token that wraps the same token id"** (line 318). **Rewrite:** "If a build token for the same Cloudflare token already exists, the setup command reuses it."

### N6. Definitional metaphors

> a chassis of design-neutral plumbing (lines 3 and 33); the chassis holds the plumbing (line 253); The chassis is the design-neutral plumbing (line 274); its raw-markdown twin (line 237); the zero-config owner and editor floor (line 227); The rename fails loudly (line 130); two pieces that need each other (line 308)

**Rule:** No figurative language (Google tone), and the tell is worst in a definitional position. "Plumbing" is how the page defines the chassis, every time it defines it. **Rewrites:** "The chassis is the design-neutral code every scaffolded site shares, copied into `src/chassis/` with Waymark." Replace "twin" with "its raw-markdown counterpart `[...path=md]`". Replace "floor" with "the zero-config `owner` and `editor` roles". Replace "fails loudly" with "fails with an error". For line 308: "A scaffolded site serves a themed 404 page only when two settings are both in place: the root `src/routes/+error.svelte` and `assets.not_found_handling` set to `"none"` in `wrangler.jsonc`."

### N7. The setup-state section never says why the missing record matters, and it drifts off topic (missing middle step; one subject per section)

Line 314 tells an inheritor that they have "no copy of that record", but never says what that costs them. The blueprint's own background says the record "a resumed run reads (`f:3my5c1`) and `--sign-in` needs (`f:o8uoci`)". That consequence is the inheritor's practical point, and the page dropped it. Line 316 then moves to `--brand-color`'s accepted formats, which is a flag reference fact rather than state outside the tree. Line 314's first sentence joins two separate facts into one 41-word sentence. **Rewrite** for the opening:

> The setup command keeps its record of the run at `~/.config/cairn/sites/<id>.json` on the machine that ran it, never under the project directory. The directory has mode 0700 and the file mode 0600, and the record includes the pasted Cloudflare token. A resumed run reads this record, and `--sign-in` needs it, so a developer who took over the site can do neither from their own machine.

Move the flag-format sentences to the setup command's reference, or cut them. Keep `--yes` and `CAIRN_CF_API_TOKEN` only if the section says why an inheritor needs them. Verify the `--sign-in` consequence against `f:o8uoci` before landing it.

### N8. Two `.cairn/` directories are never told apart (logic: missing middle)

The root `/.cairn/` is gitignored, holds the compiled `admin.css` (lines 126, 130, and 292), and is absent from the tree. `src/content/.cairn/` is committed, holds the manifests (lines 76 and 280), and is marked `[engine] [gate]`. Line 41 also lists the showcase's `.cairn` as excluded. A reader who sees ".cairn/admin.css" (line 126) can easily look in the marked directory. **Rewrite:** Add one sentence to the `.gitignore` entry: "This root `.cairn/` is separate from the committed `src/content/.cairn/`, which holds the content manifests." Also add a line for `.cairn/` to the File tree's lead-in list of omissions: "and the gitignored root `.cairn/` that the pre-scripts build".

### N9. The `.cairn/` list's lead-in is false, and one item is empty

> Each file has a different writer: (line 282) ... `site-facts.json`: a file that `cairn-manifest` writes. (line 286)

The writers overlap. `cairn-manifest` writes both `index.json` and `site-facts.json`, and the publish commit also patches `index.json`. The lead-in's universal is therefore false. The `site-facts.json` item never says what the file is, unlike its siblings ("the content manifest", "the media registry"). **Rewrite:** Use "The directory holds the following committed files:", and write the item as "`site-facts.json`: the site facts that `cairn-manifest` writes, described in [The `site-facts.json` contract](../reference/site-facts.md)". Take the noun from that reference page's lede rather than inventing one.

### N10. The migrations paragraph hides a data-loss warning in opaque hinges (trailing hinge, two of three)

> `0001_roles.sql` is needed once a site declares roles beyond the default owner and editor pair, and the scaffold ships it, so a new site already has it. Any automated `wrangler d1 migrations apply` runs it. Its rebuild keeps only the engine's four `editor` columns, so a site carries any columns it added across first. `0003_preview.sql` serves draft-preview links. (line 186)

"So a new site already has it" adds nothing, because the scaffold ships the file. "Any automated" is an unexplained qualifier. The real warning, that applying the migration drops custom columns, sits in an undefined hinge. `0004_login_nonce.sql` gets no gloss while `0003` does. **Rewrite** (the claims checker should confirm the column behavior first):

> The scaffold ships `0001_roles.sql`, which a site needs once it declares roles beyond the default `owner` and `editor` pair. The migration rebuilds the `editor` table with only the engine's four columns. A site that added columns to that table copies their data out before `wrangler d1 migrations apply` runs it. `0003_preview.sql` backs draft-preview links.

### N11. The dev-backend paragraph needs reordering

Line 229 currently gives the lifespan twice and defines `'repository'` mode after the reader has already met it. **Rewrite:**

> When the dev backend is on, `devBackendHandle` installs in-memory stand-ins for the GitHub backend, the media bucket, and `AUTH_DB`, and it signs in an `owner` with no email. Nothing leaves the machine. The hook passes no `content` option, so the dev admin runs in the default `'repository'` mode and lists the site's entries from its working tree. Edits land in an in-memory overlay over that tree, nothing is written to disk, and the overlay lasts until the dev server restarts. The `'fixtures'` mode seeds an in-memory repository with sample content instead.

### N12. "On purpose" without a reason (missing middle step)

> beside two routes that sit outside `/admin` on purpose, the media route and `/healthz` (line 241)

The section never says what the purpose is. Line 243 inverts the cause: it says the media route adds headers because it sits outside `/admin`, but not why it sits there. For `/healthz`, line 245 says "sits outside the guard" with no reason. **Fix:** State each reason from the facts (for example, that public pages load media without signing in and that a monitor polls `/healthz` without a session), after the claims checker confirms them. Or drop "on purpose".

### N13. `vite.config.ts` has a non-sequitur and an unintroduced package

> Its `config` hook defines `__CAIRN_DEV_BUILD__` for the dev backend to gate on, and the scaffold's config sets no define. (line 164)

The clause after "and" has no stated relation to the first. `@glw907/cairn-cms-dev` appears in the same paragraph, but `package.json` never says the scaffold depends on it. **Rewrite:** "The scaffold's config sets no `define` entry of its own. The `cairnManifest` plugin's `config` hook defines `__CAIRN_DEV_BUILD__`, which the dev backend gates on." Next: "The config also lists `@glw907/cairn-cms-dev`, the dev backend's package, in `ssr.noExternal`. Without that entry, `/admin` answers 500 under `vite dev`, because the package ships built JavaScript that imports `cloudflare:workers` and Node's loader rejects that module." Add the dev package to the `package.json` entry if the scaffold declares it.

### N14. In the `package.json` entry, "The field" is ambiguous and the run is staccato

> ... rather than config aliases. [Upgrade cairn](upgrade-cairn.md) covers moving the engine's range. The field maps `#lib/*` to `./src/lib/*`. That directory holds one file. `log.ts` is ... (line 142)

The Upgrade sentence interrupts the `imports` thread, so "The field" no longer has a clear antecedent. Three short sentences follow (no noir overcorrection). **Rewrite:** "The engine, `@glw907/cairn-cms`, sits in `dependencies`, and [Upgrade cairn](upgrade-cairn.md) covers moving its range. The `imports` field declares `#chassis`, `#theme`, and `#lib` as subpath imports rather than config aliases. It maps `#lib/*` to `./src/lib/*`, which holds only `log.ts`, the site's [`createLogger`](../reference/log.md#createlogger) instance typed over the site's log event names."

### N15. The `.gitignore` entry narrates implementation (extend counterpart question)

Line 130 spends two sentences on npm packlist mechanics, and the rename's failure mode bolts on an unrelated `.gitattributes` clause. Line 107 makes the rename the file's defining trait. A site's developer needs to know what the file ignores. **Rewrite:**

> The file ignores `.dev.vars` and every `.dev.vars.*` file, and no line re-includes any of them. It also ignores the root `.cairn/` directory (`/.cairn/`), where the pre-scripts rebuild the compiled `.cairn/admin.css`. The setup command's package ships the file as `gitignore`, because npm drops a file named `.gitignore` from a package, and renames it on copy.

On line 107, change "a `.gitignore` that the setup command renames" to "a `.gitignore`".

### N16. `.dev.vars` never says when it's needed (missing middle step, for the claims checker)

`npm run dev` runs the in-memory dev backend (line 148), which stands in for GitHub (line 229). That leaves the question of when a developer actually needs `GITHUB_APP_PRIVATE_KEY_B64` in `.dev.vars`. Line 120 also says tidy ships enabled while `ANTHROPIC_API_KEY` ships empty, and never says what tidy does with no key. **Fix:** Add one sentence on when local secrets are read, and one on tidy's behavior without a key, both from the facts. Otherwise, cut the claim.

### N17. Exports are unlinked at first mention

`requireAccess` and `createSectionAction` (line 227), `createPublicRoutes` (line 237), `defineAdapter`, `parseSiteConfig`, and `defineComponent` (lines 257 to 263) all appear without links. Verified anchors exist for each: `../reference/sveltekit.md#requireaccess`, `../reference/sveltekit.md#createsectionaction`, `../reference/delivery.md#createpublicroutes`, `../reference/core.md#defineadapter`, `../reference/core.md#parsesiteconfig`, and `../reference/core.md#definecomponent`. **Fix:** Link each at first mention, as the page already does for `createAuthGuard` and `loadHealth`.

### N18. Role names aren't in code font

> the default owner and editor pair (line 186); the zero-config owner and editor floor (line 227); signs in an owner (line 229)

These are the role identifiers, and the register's approved exemplar sets them as `owner` and `editor`. This is borderline for the code-font checklist rule, so I'm grading it non-blocking. Setting them in code font also resolves N2's "owner" collision.

### N19. A short sentence with an ambiguous antecedent

> A site built by hand starts with neither. (line 46)

"Neither" could refer to the template and chassis, or to the live deploy and the GitHub App. **Rewrite:** "A site built by hand starts with no template, no chassis, and no deploy, and [Add cairn to a SvelteKit app](add-cairn-to-a-sveltekit-app.md) walks through that build."

### N20. List cadence in prose (reflexive triads)

> SvelteKit routes mount the admin and the public site, a server hook guards `/admin`, and the whole SvelteKit config sits inline in `vite.config.ts`, while `wrangler.jsonc` binds ... (line 3)

The next sentence repeats the shape (repository, GitHub App, workflow). Line 253 runs three parallel "holds" clauses, and line 107 joins a triad to an unrelated clause. Line 237 runs "..., with a sample for each one ..., plus the type scale and the component recipes", which Vale flags. **Rewrite** for line 3: "In SvelteKit terms, routes mount the admin and the public site, and a server hook guards `/admin`. The SvelteKit config sits inline in `vite.config.ts`. In Cloudflare terms, `wrangler.jsonc` binds the Worker's D1 auth store, a mail binding, and an R2 bucket." For line 253, keep the first clause and let each H3 carry its directory. For line 237: "The `styleguide/` route renders the type scale, the component recipes, and every registered markdown component, with a sample for each component that declares a `preview`."

### N21. The `wrangler.jsonc` entry has two lead-ins and an empty item

> The Worker's config declares four bindings, the static-assets binding `ASSETS` among them, and one variable, and its only D1 database is the auth store. The following list names each one: (line 168) ... `PUBLIC_ORIGIN`, a variable (line 174)

**Rewrite:** "The Worker's config declares the following four bindings and one variable:". If the facts state what `PUBLIC_ORIGIN` holds, say it in the item; otherwise leave the item as it is.

### N22. In the crawl rules, "otherwise" has no clear referent

> A corpus that fits on page one gives that route no entries, and SvelteKit's crawl-completeness check would otherwise fail the build. (line 302)

**Rewrite:** "When every post fits on page one, the crawl finds no page of that route. Without the exemption, SvelteKit's unseen-route check would fail the build."

### N23. A roadmap claim, and "not shipped" said twice

> Waymark is the only template the setup command ships. A second template, Topo, is planned but not shipped. (line 44)

A published page promising a planned template is a roadmap claim, and "Topo" appears in no other published page. **Fix:** Cut the second sentence, or confirm that the roadmap commits to Topo.

### N24. The readers paragraph repeats one sentence shape (soft)

Line 7 opens five sentences in a row on "A developer / One / A reader / a reader / A developer". The house ruling on several readers permits naming each reason, so this is soft. Varying one opening would break the skeleton: "Someone still choosing between the setup command and a by-hand build can see here what the command writes."

### N25. The CI's guidance step goes unexplained for a reader without an assistant (soft)

> The last step runs `npx cairn-guidance check` without `--strict` and under `continue-on-error: true`, and that step never fails the job. (line 111)

A reader who uses no coding assistant learns that the step exists but not what it checks. Once B2 is resolved, add one clause that labels it and links the Claude Code page, as line 103 does: "... `npx cairn-guidance check`, the Claude Code guidance check, ..."

### N26. Claims for the claims checker

- "SvelteKit 3 removed `csrf.checkOrigin`, and a config that sets it fails validation" (line 162). Check the SvelteKit major version and the validation behavior. If the claim holds, it is also a vendor specific that should get a link instead of a restatement.
- "That file uses SvelteKit's `defineParams`" (line 237). Check that the API exists under that name.
- "SvelteKit's Origin check runs ahead of every handle" (line 162). "Every" is an overstated universal unless verified.
- Line 298's arithmetic (a page size of 13 plus the lead post makes 14, and the scaffold ships 14 posts) is consistent with line 302's exemption rationale.
- "The opt-in `0002_audit.sql` is absent" (line 184). Check that the scaffold's `migrations/` really skips 0002 and that Wrangler accepts the gap.

## Verdict

The draft mostly reads as its register's plausible author. The file-by-file entries are measured and precise, the tellgrader floor is clean, and the `check.yml` entry follows the owner-approved rewrite. Two things stop it. The first is mechanical: one list item reaches the 26-word cap (B1), and a link points to the unmerged Claude Code page (B2). The second is in the prose. The introduction and "The scaffold" say the same things two or three times over and end on a balanced closer. Several words do double duty: "owner" is both the person and the role, "reader" is both people and the files' consumers, and "branch" is both git and `if`. Internal vocabulary ("chapter", "template build", "Deploy-button tree") leaks into a page whose reader has none of that context, and the Deploy button doesn't exist yet. The single change that would help most is to cut the restatements and resolve the equivocations: state ownership once, define the chassis once without "plumbing", use "developer" for the person and `owner` for the role, and cut the line 5 closer. That would turn the opening from a summary repeated in each section into a frame the entries then prove.
