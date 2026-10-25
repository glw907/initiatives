# Register edit: docs/extend/define-an-adapter-and-schema.md at 9e121e895

Verdict: fix. Blocking: B1, B2. [claims] marks a finding that touches a claim.

B1 (blocks). L284, 288, 294, 295: four verify steps each hold two actions (Google: one action per step; exemplar choose-an-ai-posture.md L81-82, L98-99). Split action from check:
 1. In a terminal at the site's root, run `npm run check`. (keep the svelte-check paragraph)
 2. In the output, confirm that `npm run check` reports no errors.
 3. In the same terminal, run `npm run build`.
 4. In the output, confirm that the build completes.
 5. If the concept's directory holds entries, in `src/content/.cairn/index.json`, confirm that a row names one of the concept's entries.
 6. In the same terminal, run `npm run dev`. (keep the dev-backend note)
 7. In a browser, open `/admin`.
 8. In the sidebar, confirm that the concept's label appears.
 9. In the sidebar, select the concept's label.
 10. On the list screen, confirm that the create button reads **New** followed by the concept's `singular`.
B2 (blocks). L317, 321, 325: fixes written as prose procedures (Vale Cairn.ProseProcedure at L325). Keep each cause sentence; turn each fix into a nested numbered list introduced by "To ..., follow these steps:".
 - L321: 1. In a terminal at the site's root, run `npx cairn-manifest`. 2. Commit `src/content/.cairn/index.json`.
 - L325: 1. In the Vite config, add the concept's id and pattern to the plugin's `content` option. 2. In a terminal at the site's root, run `npx cairn-manifest` again.
 - L317 [claims]: 1. In the adapter's `content` map, rename the key. 2. In the content module, rename the key passed to `createSiteIndexes`. 3. In the Vite config, rename the key in the `cairnManifest` plugin's `content` option. (confirm these are the places the key appears)
C1. L174 ("Optional: In"), L278 (two items): Vale false positives; don't reword.
R1. "entry" means content entry, vocabulary item, behavior key, map key, list item. Keep "entry" for content entries:
 - L198: "Each vocabulary item pairs a lowercase hyphenated `value`, stored in frontmatter, with a display `label`. ... Once the vocabulary holds an item, a save can add only vocabulary values to a concept's marked field. A content entry keeps its existing tags outside the vocabulary as orphans."
 - L206: "Each key in `behavior` checks one field, and `refine` checks the whole entry."
 - L219: "2. In that argument, add the field's key under `behavior`, with a `validate` function that returns a message for a value the field must refuse."
 - L3: "... one more `defineConcept` call in the `content` map."
R2. L254 balanced halves plus "summary" two ways. -> "Set each of the following options that the site needs:"
R3 [claims]. L60 "the pages under See also cover the other groups" is false (no editor-group page in See also). Rewrite: "The [`createGithubApp`](../reference/core.md#creategithubapp) entry lists the backend's options. The pages under [See also](#see-also) cover most of the other groups, and [Arrange the admin sidebar](arrange-the-admin-sidebar.md) covers the `editor` group's `navLayout`." (or see Against the blueprint 1)
R4. L301 echo pair. -> "Every failure in the following list traces to one registration or one rule in the declaration. Under each failure, the list gives its cause and its fix:"
R5. L5 42-word sentence, subject confusion. -> "The site writes each concept's glob in its content module, and the content module passes the glob to `createSiteIndexes`. The `cairnManifest` Vite plugin checks the committed content manifest against the markdown, and the site writes the same pattern again in that plugin's `content` option."
R6. L3 restatement and inventory cadence. -> "The call holds the site's concepts under `content`. It also names the GitHub backend that receives commits, the sender of the sign-in email, and the renderer. A concept is one key in the `content` map, so a new kind of content starts as one more `defineConcept` call there."
R7. L9 unsupported "most often", unclear "them". -> "A scaffolded site's adapter declares the `posts`, `pages`, and `fragments` concepts. A developer on such a site arrives when the site needs a kind of content that the adapter does not declare yet. Others arrive to change ... Each step names a file by its role and gives the scaffold's path for it, and on a site built by hand the step applies to the matching file."
R8. L11 -> "It also assumes familiarity with the content model. [Content model](content-model.md) explains what a concept is, what routing decides, how an entry gets its id, and the normalized frontmatter a save writes."
R9. L81 -> "The engine refuses some concept ids. A concept keyed `login`, `auth`, `editors`, `help`, `media`, `vocabulary`, `nav`, `settings`, or `site` throws an error. A concept keyed `fragments` must set `routing: 'embedded'`."
R10 [claims]. L168 garden path. -> "When an editor picks a date in the create dialog, `datePrefix` sets how much of that date prefixes the new entry's id." (blueprint L172 says "filename"; code decides id vs filename)
R11. L208 -> "A check that refuses an empty value therefore tests that the value is a string."
R12 [claims]. L214 conclusion names only `refine`; if `validate` messages share the banner -> "Each message a check returns therefore needs to read as a standalone sentence."
R13. L33 -> "The call accepts five optional groups: `roles`, `access`, `media`, `aiPosture`, and `editor`. It also requires the four groups that the following list describes:"
R14 [claims]. L66 "Every other member has a default." Confirm against `defineConcept`'s type.
R15. Hand-offs: L202 -> "With the tag field marked, add the checks a save runs on the concept's entries." L250 -> "With the checks in place, set the list summary and array row options."
R16. Link first mentions: L5 `createSiteIndexes` -> ../reference/delivery-data.md#createsiteindexes; L5 `cairnManifest` -> ../reference/vite.md#cairnmanifest; L150 `npx cairn-manifest` -> ../reference/cli-cairn-manifest.md; L258 `composeRuntime` -> ../reference/core.md#composeruntime; optional L3 `defineAdapter`/`defineConcept` -> core.md anchors.
R17. L315 -> "says that the id names an engine view under `/admin`, or that a concept cannot be named `site`."
R18. L7 -> "... and they end by confirming that the site typechecks and builds with the new declaration."

Against the blueprint:
1. See also (blueprint L361-368) lacks Arrange the admin sidebar, so blueprint L84 / page L60 is false. Adding `- [Arrange the admin sidebar](arrange-the-admin-sidebar.md)` makes it true (a link addition, no section change).
2. Blueprint L361 lead-in vs list includes Build the public routes. Proposed: "The following pages cover the content model, the adapter's other groups, and the public routes:"
3. Content-model prerequisite twice (L11, L27). Noted only.
4. `permalink` default twice (L75, L162). Noted only.

Draft departs from blueprint (for the fact-checker): L14 links Write a markdown component where blueprint L29 says "Configure rendering" (renamed; update the blueprint); L79 `Posts`/**New Posts** vs blueprint `Events`; L173 `'/:year/:slug'` vs `'/events/:year/:slug'`; L256 `['description']` vs `['location']` (the events fieldset declares no description); L168 id vs filename; L286 "reads such a key as always present" vs "uses such a key without handling `undefined`".
