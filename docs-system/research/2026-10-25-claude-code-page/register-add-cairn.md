# Register edit: Add cairn to a SvelteKit app

- Page: `docs/extend/add-cairn-to-a-sveltekit-app.md`, worktree `rd-add-cairn-to-a-sveltekit-app`, commit `e894e08e3`
- Track: extend, under Google plus the cairn docs voice (developer brief). Anatomy: tutorial, with tutorial milestones.
- Contract read: the developer brief (Structure, Voice, The introduction, Exemplars, Tells), Names, The page anatomies, The extend track, and Deviations from the base guides. Blueprint headings checked against the page; they match one for one.
- Verdict: **fix**. 4 blocking base-guide findings and 24 non-blocking findings, 28 in total.

## Deterministic floor

`tellgrader --register docs` returned exit 0 under the `docs-register` profile, with no gate finding: no trailing-hinge run and no appositive stack.

- Finding: `scaffold-header` at line 1333, `## Summary`. I'm reporting it as a fact. The tutorial anatomy requires a closing summary, and Good Docs' tutorial template names that section "Summary", so the heading follows the anatomy. I propose no change. It's listed under N24 so Geoff can rule on it.
- Warning: `empty-own` at line 1027 ("your own"). This is a false positive, because the text is GitHub's page title, "Installing your own GitHub App".
- Counts: exclamation 1, scaffold-header 1, tricolon 1, uniform-paragraph 4. The rate is 0.12 tells per 1,000 words.

Vale reported 0 errors, 75 warnings, and 25 suggestions. Most are the usual `Google.WordList` "admin"/"email" noise. The ones worth noting:

- `Cairn.ProseProcedure` at line 911.
- `Google.Timeless` at line 772 ("latest").
- `Cairn.NamesRetired` "the package" at lines 779, 1077, 1081, 1092, and 1251. Each is a fact about the package itself (its files, its `migrations/` directory, its export conditions), so each is the sanctioned sense.
- `Google.OxfordComma` at lines 225, 641, 1018, 1218, and 1328. All five are false positives on "build the site and deploy it".

## Measurements

| Measure | Value | Source |
|---|---|---|
| Sentences (prose selector) | 402 | tellgrader `measures` |
| `hinged_pair_share` | 0.435 | tellgrader `measures` (no band; reported, not gated) |
| `short_sentence_share` | 0.236 | tellgrader `measures` |
| Prose paragraphs (excluding lists, code, and trees) | 110 | my count |
| Average sentence length (prose paragraphs) | 14.9 words | my count |
| Longest sentence | 32 words, line 16 (introduction, so exempt from the cap) | my count |
| Disproportionate paragraphs | line 253 (9 sentences), line 431 (10), line 647 (8). Each is a stack of one-fact sentences with reference pointers between them. | my judgment |

The 26-word cap held. No step or list item runs past 26 words. The prose sentences over 26 words (lines 6, 8, 16, 17, 22, 75, 239, 253, 511, 633, 850, 959, 986, 1077, 1128, and 1318) are all introduction or explanation sentences, so the cap doesn't apply to them. Several still read as run-ons, and N-findings below take them up.

## Blocking findings (base guide)

### B1. A concept section carries a task heading (line 1312)

> `### Edit the message in a custom sender`

The section has no steps. It says "This tutorial writes no custom sender" and describes the `SendMagicLink` contract. Rule: Google headings, as in the brief's checklist. A task heading starts with a bare infinitive, and a concept heading is a noun phrase. A reader who scans for a task is promised one the section doesn't hold.

Proposed heading: `### The custom sender contract`. Then update the in-page link at line 1176: "To send mail some other way, see [The custom sender contract](#the-custom-sender-contract)."

### B2. Steps that cross locations (lines 918 and 1205)

> 3. In the terminal, restart the dev server with the flag, reopen the post in the admin, and confirm that the edit is gone.

> 1. On the deployed origin, request a sign-in to the admin with the `bootstrapOwner` email, and open the link in the email.

Rule: each step holds one action, and a step names where the action happens before it names the action (Google procedures, in the brief's checklist). Each of these steps moves between two locations: the terminal and the browser, then the browser and the mail client. The location at the head of the step only covers the first action.

Proposed rewrite for 918:

> 3. In the terminal, restart the dev server with `CAIRN_DEV_BACKEND` set to `1`.
> 4. In the admin, reopen First light, and confirm that the edit is gone.

Proposed rewrite for 1205:

> 1. On the deployed origin, request a sign-in to the admin with the `bootstrapOwner` email.
>    With the allowlist empty, that request inserts the owner row and logs `editor.bootstrapped` before the link is sent.
> 2. In your mail client, open the sign-in link.

Renumber the steps that follow. The "The row therefore exists before you open the link." sentence repeats the line before it (see N12), so it can go.

### B3. A reference by position (line 1279)

> The next two sections take them in that order.

Rule: a reference names its target, never its position on the page (Google procedures, in the brief's checklist). The sentence also describes the page's own layout.

Proposed rewrite: drop the sentence, and link each list item to its section.

> - A supplied `auth.branding` overrides the three members it names, as [Rebrand the email](#rebrand-the-email) shows.
> - A custom `auth.send` makes any other change, as [The custom sender contract](#the-custom-sender-contract) describes.

### B4. UI labels in plain text (line 315)

> The nav editor, the Settings save, and the Tags screens read and commit the one site-config file ...

Rule: UI labels sit in bold (Google highlights, in the brief's checklist). "Settings" and "Tags" are screen names in the admin. "The Settings save" is also unclear: it could mean a button, an action, or a screen. The intensifier "one" adds nothing (N22).

Proposed rewrite: "The nav editor, the **Settings** screen's save, and the **Tags** screens read and commit the site-config file that [`editor.siteConfigPath`](...) names." If the nav editor has an on-screen label, bold that label too.

## Non-blocking findings (register, logic, links), ranked

### N1. The pointer-sentence skeleton recurs throughout the page (flat, list cadence in prose, recycled phrase)

About 18 times, a section's lead paragraph follows the same shape: a fact, then "The [`x`](...) entry lists/documents/covers/describes ...", then the next fact. Examples are at lines 259, 313, 395, 434, 438, 501, 513, 649, 651, 652, 855, 856, 1060, 1124, 1208, 1221, 1310, and 1320. The primary exemplar uses this pointer once, where it carries real information. Used this often, it becomes the "section skeletons that repeat one … shape" tell, and it makes the lead paragraphs read like an inventory. Most of the measured hinge share and the three disproportionate paragraphs come from this pattern.

Proposed fix: link the identifier at its first mention, as Wikipedia's linking guideline does, and drop the separate sentence. For example, lines 511 to 513:

> The entry route is a prerendered catch-all built on the engine's public routes loader. [`createPublicRoutes`](../reference/delivery.md#createpublicroutes) returns `entryLoad`, which resolves one entry by request path and throws a 404 on a miss, and `entries`, which enumerates every routable entry for the prerenderer.

Keep a separate pointer sentence only where it says what the reader will find there, as at line 1034.

### N2. The paragraph at lines 431 to 440 is an inventory of ten one-fact sentences

> The site passes `createSiteIndexes` one literal `import.meta.glob` per concept, and the `cairnManifest` plugin checks ... The manifest's default path is ... The [`CairnManifestOptions`](...) entry covers the other optional path. The content module also exports an `origin` constant. It holds the local dev origin for now, ...

Tell: list cadence in prose. Also, the explanation should stay subordinate to the steps. The paragraph covers three subjects: the index, the plugin, and `origin`.

Proposed rewrite, in two paragraphs:

> The content module passes [`createSiteIndexes`](../reference/delivery-data.md#createsiteindexes) one literal `import.meta.glob` per concept. Vite needs the pattern written at the call site, and `createSiteIndexes` throws at build time for a declared concept with no glob. The module also exports `origin`, which holds the local dev origin until the production milestone changes it.
>
> The [`cairnManifest`](../reference/vite.md#cairnmanifestoptions) plugin checks the committed manifest at `/src/content/.cairn/index.json` against the markdown on every build. Its `configModule` option names the module that exports `cairn` and `siteConfig`, and its `content` option maps each concept id to that concept's glob.

### N3. Circular reasoning in the CSRF paragraph (lines 873 to 876) (Russell: logic)

> ... SvelteKit's default Origin check runs ahead of every handle, `/admin` included, because this site's config has no `csrf` key. The guard adds a double-submit token on top. SvelteKit 3 removed `csrf.checkOrigin` and left `trustedOrigins` as the only setting, so the site sets no `csrf` key. The check doesn't run under `vite dev`.

The first sentence says the check runs because there's no `csrf` key, and the third says there's no `csrf` key because of SvelteKit 3. "The check" in the last sentence could mean the Origin check or the double-submit token.

Proposed rewrite:

> On the `createAuthGuard` branch, SvelteKit's default Origin check runs ahead of every handle, `/admin` included, and the guard adds a double-submit token on top. SvelteKit 3 removed `csrf.checkOrigin` and kept `trustedOrigins` as the only `csrf` setting, which this site doesn't need. Under `vite dev`, SvelteKit skips the Origin check.

Send to the claims checker: is it the Origin check that's skipped under `vite dev`, or both checks?

### N4. Overstated universal in the introduction (line 18) (Russell)

> Every file the engine needs appears once, in the milestone that needs it, with the reason it exists.

`vite.config.ts` is shown whole three times (lines 146, 479, and 796), and the server module twice (lines 672 and 1294). "Appears once" is false as written.

Proposed rewrite: "Each file the engine needs is introduced in the milestone that needs it, with the reason it exists."

### N5. "Before you begin" repeats itself and points at the setup command for the third time (lines 46 to 48)

> You need Node 24 or later, a GitHub account, a Cloudflare account on the Workers Paid plan, and a domain whose zone is on that account.
> If you want the faster route for a new site, use the setup command instead.
> [Scaffolded site files](scaffolded-site-files.md) describes the site it writes.

The list right after it states the same requirements. The opening sentence also contradicts the list item that says the first milestone runs on the free tier. The setup-command pointer already appears at lines 10 to 12 and line 37, which also makes three links to Scaffolded site files for the same point (overlinking). Tell: restatement.

Proposed rewrite: delete lines 46 to 48, and open the section with "You need the following accounts and tools:".

### N6. A trailing-hinge run (lines 953 to 955) (owner ruling)

> The App's private key is no file edit, because `GITHUB_APP_PRIVATE_KEY_B64` is a Worker secret that `wrangler.jsonc` never lists. `hooks.server.ts` needs no edit: `__CAIRN_DEV_BUILD__` is `false` on a production build, and the dev-backend branch is dropped. Each section makes its edit once the value it needs exists, so the bindings come last.

These are three consecutive sentences, each hanging a reason off a comma or colon. The punctuation varies enough that tellgrader doesn't mark it, but read aloud it has the same cadence.

Proposed rewrite:

> The App's private key lives in a Worker secret, `GITHUB_APP_PRIVATE_KEY_B64`, which no file names. On a production build `__CAIRN_DEV_BUILD__` is `false`, and the build drops the dev-backend branch, so `hooks.server.ts` stays as it is. The bindings come last. Each section edits a file only once the value it needs exists.

### N7. Ambiguous antecedent and a restatement (lines 1180 to 1183)

> `cairn doctor` confirms the two bindings, and a publish from the deployed admin confirms the App, since no command checks the App itself. Its `config.bindings` check, run with no flags from the site's directory, confirms that `AUTH_DB` and `EMAIL` are both wired. Checking the App takes a manual publish whose commit lands on `main`. The entry route is prerendered, and a published edit reaches the deployed page only after the next build and deploy, which the steps perform.

"Its" follows "the App", but it means `cairn doctor`. Sentence 3 repeats sentence 1. The last sentence ends on a tail about the docs themselves ("which the steps perform").

Proposed rewrite:

> No command checks the GitHub App, so this section verifies it with a real publish. [`cairn doctor`](../reference/cli-cairn-doctor.md#the-checks), run with no flags from the site's directory, verifies the bindings: its `config.bindings` check confirms that `AUTH_DB` and `EMAIL` are both wired. The entry route is prerendered, so a published edit reaches the deployed page only after the next build and deploy.

Then line 1221 can go, because the link now appears at first mention.

### N8. Ambiguous "changes nothing" (line 762) (Russell: equivocation)

> In development, a width cap logs one console error and changes nothing.

The line before says chrome "keeps the admin shell from filling the viewport", so "changes nothing" can be read as contradicting it.

Proposed rewrite: "In development, the engine logs one console error for a width cap and leaves the layout as it is."

### N9. Non-sequiturs that interrupt the milestone (lines 260 and 261, 652, 772, 879)

- Lines 260 and 261 ("A custom route that needs a Worker binding reads it from `cloudflare:workers` … Version 8 of `@sveltejs/adapter-cloudflare` declares no `App.Platform`.") No step uses either fact, and the link to `app.d.ts`, whose `Platform` line stays commented out, is never stated. Either connect it ("so `app.d.ts` declares no `Platform`, and a custom route reads a binding from `cloudflare:workers`, typed by the `Env` that `wrangler types` generates") or move it to the reference.
- Line 652: the `createEditorRoutes` pointer. The tutorial never uses it. Cut it.
- Line 772: "The [migration notes](migration-notes.md#unreleased) record the option's latest change." This is a time-bound word (Vale `Google.Timeless`), and the anchor stops working at the next release. A tutorial reader doesn't need it. Cut it.
- Line 879: an access map, its composition event, and its section-action event. None is part of wiring the dev backend. Move "Restrict admin access" to Next steps, and cut the debug-event links. Line 880 can stay if the access map is mentioned at all.

The anatomy rule is that explanation stays subordinate to the steps.

### N10. Missing middle steps (lines 71, 316, and 779)

- Line 71: "On a machine without Go, install it from a release archive instead." The sentence doesn't say where the archive is, and no published page I could find covers it. This is a dead end for the reader. Link the release page or the install doc. I'm not proposing a URL, because I couldn't verify one. Send to the claims checker.
- Line 316: "Its default is the scaffold's path, so this site's adapter sets it to `src/lib/site.config.yaml`." The default isn't named, so the reader can't tell why it doesn't apply here. Name the default path, verified by the claims checker.
- Line 779: "That JavaScript sits in `dist/`, and the package declares no `svelte` export condition." The point is left unstated: unlike the engine, the dev package isn't compiled as Svelte source, so `noExternal` is there for the `cloudflare:workers` import alone. Either state that or cut the sentence.

### N11. Explaining code the reader just read (lines 845 to 847 and 853 to 854) (extend counterpart question)

> The hooks module picks its handle in one `if`. The test reads `__CAIRN_DEV_BUILD__` directly, then checks `CAIRN_DEV_BACKEND === '1'`, and the module exports the handle it picks as `handle`. Both handles take `{ runtime }`.

This restates the twelve-line code block above it. Lines 853 and 854 then repeat "both handles take the runtime" a second time. Cut lines 845 to 847, and open the paragraph on the reason: "The opt-in reads `process.env` because `vite dev` runs the hooks in Node, …". Merge line 854 into line 853: "`createAuthGuard` and `devBackendHandle` both require `runtime`, so one declaration serves both, and a call that passes none is a type error."

### N12. Restatements within a paragraph (lines 1077 to 1082, 1206 and 1207, 1283 to 1285, 865 and 866)

- Line 1079 ("Every site applies `0000_auth.sql` and `0004_login_nonce.sql`.") repeats line 1077. Line 1082 ("The database is created with `npx wrangler d1 create` and bound as `AUTH_DB` …") narrates the steps just below it, in the passive. Rewrite line 1077 as "… and every site applies two of the five migrations the package ships, `0000_auth.sql` and `0004_login_nonce.sql`." Then cut lines 1079 and 1082.
- Line 1207 ("The row therefore exists before you open the link.") repeats line 1206 (covered under B2).
- Line 1285 ("Through `createCairnAdmin`, `branding` is a partial of those three members, each defaulting to …") repeats line 1284. Cut it, or fold "a partial" into line 1283.
- Line 866 ("The site declares nothing for it.") is a capper after line 865. Merge: "`@glw907/cairn-cms/ambient`, already imported in `src/app.d.ts`, declares `__CAIRN_DEV_BUILD__` as a boolean global, so the site needs no declaration of its own." Or end the sentence at "global".

### N13. Exercise prompts give imperatives outside any step (lines 219, 611, 911, and 1245)

> Edit the post in the admin, confirm that the file on disk is unchanged, then restart the dev server and find the edit gone.

Rule: the register's imperatives tightening. Vale's `Cairn.ProseProcedure` fires at line 911. The anatomy asks for "stated objectives" in each milestone, and the disclosure block holds the steps. State each exercise as an objective:

> This exercise shows where a dev-backend edit lives: the admin shows it, the file on disk stays unchanged, and a restart discards it.

Then line 920, the explanation inside the disclosure, can go (N14).

### N14. A reflexive triad under one "because" (line 920)

> The edit shows in the admin because the overlay answers first, the file on disk stays untouched, and a restart discards the overlay.

"Because" only explains the first of the three clauses. Once N13 states the objective, cut this line. If it stays: "The admin reads the in-memory overlay first, so the edit shows there while the file on disk stays untouched. A restart discards the overlay."

### N15. A summary sentence whose reason doesn't fit its claim (line 1338) (Russell)

> Because the hooks module names the build-time flag directly, the dev backend works on your content in memory and never reaches a production bundle.

The flag explains why the dev backend never reaches production. It doesn't explain why the backend works in memory.

Proposed rewrite: "The dev backend works on your content in memory, and because the hooks module names the build-time flag directly, it never reaches a production bundle."

### N16. Tension between two claims: "validates nothing" and "requires all five strings" (lines 323 and 1059) (Russell)

> `createGithubApp` makes no network call and validates nothing, ...
> `createGithubApp` requires all five strings, ...

If the requirement is only enforced by the type, say so ("its types require all five strings"). If the function rejects a missing one, then "validates nothing" is false. Send to the claims checker.

### N17. Facts for the claims checker

- Line 15: the setup command "refuses any target directory that already holds files".
- Lines 56 and 997: the first deploy that carries the admin needs Workers Paid, even though it has no bindings yet. The page gives no reason, and the fact file ties Paid to Email Sending (`f:a6wpbm`).
- Line 1123: audit writes "never contend" with session and token lookups. "Never" is an absolute. Also, "is recommended" is passive and doesn't say who recommends it.
- Line 61: "`svelte-check` can't run on TypeScript 7 yet". This is time-bound and will go stale.

### N18. The production site stops at manual deploys (lines 1183 and 1341)

The tutorial ends with the developer pulling each publish and redeploying by hand. Scaffolded sites deploy on push through Workers Builds, as `scaffolded-site-files.md` (lines 39 and 498) and `upgrade-cairn.md` (line 34) state. The page neither says that this site has no automatic deploy nor points to how to add one, so a reader may hand editors a site where Publish appears to do nothing. This is a planning omission, so it goes back to the blueprint: add a not-covered line or a Next steps link. Don't add a vendor procedure to this page.

### N19. Inconsistent name for Waymark across pages (line 16)

> A scaffolded site ships Waymark, cairn's public reading template, ...

Other extend pages call Waymark "cairn's reference reading theme" and "cairn's own reference theme", and the blueprint says "theme". Choose one term. If Geoff wants it fixed, it should go in the Names table. The sentence is also a 32-word chain (appositive, ", and", ", so if"). Proposed rewrite: "A scaffolded site ships Waymark, cairn's reference reading theme. The engine's npm package carries no theme, so a site without Waymark starts from a bare SvelteKit app."

### N20. Balanced halves and two-beat closers (lines 23, 776, 1319, and 1340)

- Line 1319: "This tutorial writes no custom sender, and the site keeps the Cloudflare sender." The second half repeats the first. Proposed: "This tutorial keeps the Cloudflare sender."
- Line 776: "A define the site sets would win, so the site writes none." Proposed: "The site sets no define of its own for the flag, because a site define would override the plugin's."
- Line 1340: "your editors sign in against the D1 database you created, and their edits commit through the App you registered." This is an echo pair ("you created", "you registered"). Proposed: "In production, editors sign in against your D1 database, and each publish commits through your GitHub App."
- Line 23: "It explains every Cloudflare and cairn step it uses, and no SvelteKit basics." This one is mild, and as a scope statement it's acceptable. Optionally: "It explains each Cloudflare and cairn step and assumes the SvelteKit basics."

### N21. The step's consequence is phrased about "the app" in the third person (line 272)

> If npm stops with `ERESOLVE`, the app still requires `@sveltejs/kit` `^2`, and it upgrades to SvelteKit 3 before it continues.

Inside a step, a recovery should be stated as an instruction to the reader. Proposed: "If npm stops with `ERESOLVE`, your app still requires `@sveltejs/kit` `^2`. Upgrade it as [Upgrade cairn](upgrade-cairn.md#when-your-range-crosses-sveltekit-3) describes, and run the install again."

### N22. Small wording slips

- Line 1029: "In the installation settings address that GitHub opens after the install, note the trailing number …" The location phrase doesn't read cleanly. Proposed: "In the browser's address bar, after the install, note the trailing number of the installation settings URL, which is the installation ID."
- Line 1068: "The engine documents the secret as …" Proposed: "The engine expects the secret to hold the PEM's contents base64-encoded onto one line, and it decodes the secret with `atob()` before signing."
- Line 1239: "put the secret again" uses wrangler's verb as if it were plain English. Proposed: "set the secret again with `npx wrangler secret put`."
- Line 310: "…placeholder backend and sender values, which the dev backend stands in for until production." It's unclear what "which" refers to. Proposed: "…and placeholder backend and sender values. The dev backend stands in for both until production."
- Line 315: "the one site-config file". Drop "one".
- Line 75: "with no cairn code yet, … so the deploy path works before the engine joins it". This stacks "with" phrases and ends on a hinge. Proposed: "This milestone ends with a plain SvelteKit site, with no cairn code, answering at its `workers.dev` address. Deploying it first proves the deploy path before the engine is installed."
- Line 591: "The content wiring fails in four ways". This claims the list is complete. Proposed: "The content wiring has four common failures, and the first three stop the build."

### N23. Mild figurative names (lines 858, 862, and 1351)

"Three layers fence it", "the runtime tripwire", and "the dev-backend fence". Google's tone guidance bans figurative language, and these sit in a structural position. Proposed: "The dev package is kept out of a deployed site at three points:", "a runtime check in the guard", and "the dev backend's exclusion from production". Flagged softly. If `security-model.md` uses "tripwire" as a term, keep it there and link it.

### N24. Items for Geoff, not defects

- `## Summary` (the tellgrader scaffold-header finding). The anatomy requires it. Keep it unless Geoff rules otherwise.
- The capitalized short form "the App" (about 30 uses). The Names table sanctions "the GitHub App". Google's capitalization guide would lowercase a bare "app", and GitHub's own docs say "the app". It's consistent within the page, so I'm flagging it for a ruling, not a rewrite.
- Steps that bundle closely related actions in one location with one code block: line 104 (create and `cd`), 114 (init and commit), 125 (uninstall and install), 265, 916, and 1188. Google allows short related actions to be combined. Strictly, these fall under "each step holds one action". I'm leaving them unless Geoff wants the stricter reading.

## Clean on

- No coding-assistant content, and no other agent or AGENTS.md.
- The examples are generic: Field Notes, `notes.example.com`, `your-account`. No consumer site's domain appears.
- The Names table is followed: the engine, the `cairn` CLI with its verb, the setup command, and a second sign-in group.
- No question or teaser headings, and no two-headed comma heading.
- No marketing, virtue claims, or softeners.
- The vendor specifics are linked, not copied.
- The tutorial overview carries all four parts.
- Each milestone has objectives, its starting state, steps, a checklist, and a disclosure block.

## Verdict

The page reads as a careful developer's work. The milestone order is argued, the reasons sit next to the steps that need them, and most explanatory sentences carry one qualified claim, as the register asks. It falls short of the exemplar's voice mostly through accumulation. In the section leads, one-fact sentences alternate with "The [x] entry lists …" pointers, and the result reads more like an inventory than a colleague explaining. The page also has four base-guide defects that block it: a concept section under a task heading, two steps that cross locations, a reference by position, and unbolded UI labels. Fix those first. After that, the change that would help most is N1: link each identifier at its first mention and drop the separate pointer sentences. That one pass fixes the three disproportionate paragraphs, most of the hinged cadence, and the recycled phrase together.
