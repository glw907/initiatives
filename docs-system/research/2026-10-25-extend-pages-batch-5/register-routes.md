# Register edit: docs/extend/build-the-public-routes.md at f928869b8

Verdict: fix. Blocking: 1 and 2. [claims] marks a finding that touches a claim.

1. L158 (blocking): "Later sections explain the `defaultImage`, `feeds`, `resolveMedia`, and `assetsEnabled` members..." names position, not target; `resolveMedia`/`assetsEnabled` are in this section (L221). Rewrite: "The scaffold's config module also sets `resolveMedia` and `assetsEnabled`, which this section covers after the entry page, and `defaultImage` and `feeds`, which [Declare the fields the head reads](#declare-the-fields-the-head-reads) and [Serve the feeds](#serve-the-feeds) cover:"
2. L367 (blocking): "1. In the admin, open an entry and save an edit." holds two actions. Split into "In the admin, open an entry." and "On the entry's edit screen, save an edit."; renumber.
3. L702: "1. In the project directory, build the site." names no command; blueprint L330 gives one. Rewrite: "run `npm run build`".
4. L13-19: Google.Colons, capital after colon in seven items. Rewrite to "A stance toward AI training crawlers, in [Choose an AI posture](choose-an-ai-posture.md)." form for all seven, as define-an-adapter-and-schema.md does.
5. L67, L107, L555-557: vendor specifics need a link (blueprint L48 names Vite import.meta.glob and SvelteKit prerendering). Add after L67: "Vite's [glob import](https://vite.dev/guide/features#glob-import) documentation covers the options." After L557: "SvelteKit's [prerender configuration](https://svelte.dev/docs/kit/configuration#prerender) documents `handleUnseenRoutes`, and its [page options](https://svelte.dev/docs/kit/page-options#entries) document `entries`."
6. L305-378: never links share-a-draft-preview.md. Add at L378: "[Share a draft preview](share-a-draft-preview.md) covers the rest of the feature, including hiding the **Share preview** group, setting a link's lifetime, and minting links from a custom admin screen." and a See also row "- [Share a draft preview](share-a-draft-preview.md): the preview link's lifecycle and options."
7. L321: imperative outside a step. Rewrite: "The scaffold's route module reads as follows. A hand-built site replaces its `#chassis` imports with the matching modules in its tree:"
8. L7: misparse plus empty "own". Rewrite: "The section on the draft preview route serves only that reader, because a scaffolded site already carries the route. Each single piece, such as a tag page built on `byTag()` or a menu that editors change at `/admin/nav`, has a separate section." (Fact-checker: "Only a hand-built site needs...")
9. L5 [claims]: "Every route reads the same two inputs" overstated. Rewrite: "The routes draw on two shared inputs, one set of typed indexes from `createSiteIndexes` and one origin string."
10. L3: "reads the shared entry from its holding branch" equivocates on "shared". Rewrite: "reads the draft from its entry's holding branch."
11. L522 [claims]: "Only the head's robots meta tag and the markdown twin read the `robots` field." Rewrite: "Of the public outputs, the head's robots meta tag and the markdown twin read the `robots` field. The sitemap builders and the scaffold's feed mapping ignore it." (page's isNoindex helper also reads it)
12. L690 [claims]: "every request that runs the load skips the renderer's cost" exceeds blueprint L321. Rewrite: "Because the layout load imports that module rather than the full adapter, the load skips the renderer's cost."
13. L119, L712: treat the origin as a literal though L121 says the literal is the scaffold's choice. L119 "writes the literal" -> "writes the origin"; L712 "your origin literal" -> "your deployed origin".
14. L117-121: restatement and an X-not-Y frame. Combine L117+L121: "The origin is one string with no trailing slash, and a production build needs it set to the deployed origin. The engine takes `PublicRoutesConfig.origin` as a plain string, and the scaffold happens to keep it in one string literal." L119 last sentence: "Because the prerendered routes run at build time, the origin a build sees is the one its output carries."
15. L548: echo pair. Rewrite: "In a dated concept, an entry with no date sorts after the dated ones. An undated concept sorts its entries by `title`."
16. L221 [claims]: "Either way, `entry.frontmatter.image.src` stays the raw token." follows three conditions; with no hero there is no src. Rewrite: "In each case, ... keeps the raw token." Confirm scope.
17. L747 [claims]: validate:false reads as contradicting "invalid entry is still left out". Rewrite if confirmed: "With `validate: false` in its fourth argument, `createSiteIndexes` doesn't fail the build on invalid frontmatter. An invalid entry, draft or not, is still left out of the index and listed by the index's `problems()`."
18. L255, L724: "stored markdown" vs "stored markdown body"; blueprint L335 says without frontmatter. L255: "It serves each entry's stored markdown body, unrendered and without its frontmatter, at the entry's permalink plus `.md`." L724: "The response is the entry's stored markdown body, without its frontmatter and unrendered."
19. L376: paraphrased symptom. Rewrite: "If a mint answers `The preview_tokens table is missing.`, copy and apply `0003_preview.sql` to `AUTH_DB` before you mint again." (verify the literal message)
20. L536-538 code [claims]: helper looks up with `posts.byId` but sitemap rows come from `site.all()` across concepts; a noindex page would slip through. Step L526 says "each entry".
21. L301: "apparently", passive, not-frame. Rewrite: "A local test under `wrangler dev` still served the file with that type, which suggests that Cloudflare derives it from the `.md` extension. No deployed zone has been tested."
22. L9: unsupported "most symptoms"; "share image" vs "social image" at L240/L247. Rewrite: "Two limits of the head the engine builds cause symptoms on a site that otherwise builds. ... the hero and the social image..."
23. L23: "Read a SvelteKit build" inexact; parsed-site-config precondition needs a link. Lead: "The routes need an adapter, a parsed site config, and a SvelteKit app that builds for Cloudflare. Before you start, confirm that your site has the following:" L25 tail: "[Define an adapter and schema](define-an-adapter-and-schema.md) covers the adapter and the site config." [claims] confirm that page covers parsing the site config.
24. L297: fold the link into the claim: "SvelteKit's [route sorting rules](https://svelte.dev/docs/kit/advanced-routing#Sorting) prefer the more specific matched route, so `[...path=md]` takes the `.md` paths and `[...path]` keeps the rest."
25. L111: two subjects; break paragraph after "[Build the archive](#build-the-archive) relies on that order." No words change.
26. L490: lead restates the one-step procedure (L494). Cut L490.
27. L708: "`@sveltejs/adapter-cloudflare` 8 output" ambiguous -> "the output of `@sveltejs/adapter-cloudflare` version 8".
28. L684: `http(s)://` -> `http://`, `https://`.
29. L751: circular see-also lead -> "The following pages cover the reference entries and neighboring guides for these routes:"
30. L424 (low): "Readers" -> "Feed readers fetch the feeds from the two feed routes."

Against the blueprint (not to act on without a blueprint change):
- Blueprint L183 [claims]: share-a-draft-preview.md (L14, L280) puts the Share preview group inside the editor's **Details** slide-over; page L368 may lack the location. Possible: "In the entry's **Details** slide-over, in the **Share preview** group, select **Share preview link**."
- Blueprint L29-35: out-of-scope list omits share-a-draft-preview.md (finding 6 links it in-section).
- Blueprint L202: L420 copies the FeedChannel/FeedItem member list the reference owns.
