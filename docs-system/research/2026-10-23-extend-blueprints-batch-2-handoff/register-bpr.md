Register review of `build-the-public-routes.blueprint.md` and `sc-preview` (commit 14d7ce655)

Files:
- /var/home/glw907/Projects/cairn-cms/.claude/worktrees/ebp2-share-a-draft-preview/blueprints/docs/extend/build-the-public-routes.blueprint.md
- /var/home/glw907/Projects/cairn-cms/.claude/worktrees/ebp2-share-a-draft-preview/blueprints/docs/extend/security-model.blueprint.yaml (`sc-preview`)

What I graded against:
- The developer brief's Structure, Voice, and Tells sections in docs/internal/docs-register.md.
- The Google deviation rows.

**Deterministic floor:** `tellgrader --register docs` exited 0 with no findings: 4524 words, 386 sentences, cadence CV 0.67, 4 tricolons. It returned no `measures` object, so I have no scanner measures table.

From my own reading:
- **Intensifier "own":** none.
- **Em dashes:** none.
- **Sentences over 26 words in a task section:** one, line 69. It is a `Code:` plan line, not page prose. Lines 14, 16, 24, 25 and 26 also run over, but they are in the `:::reader` intro block, which is exempt.
- **Trailing-hinge runs of three:** none.
- **Single hinges:** about 20, half of them the same ", as <Section> shows" tail.
- **Appositive stacks:** none strict. Line 107 is a near case.

## Findings, most severe first

1. **Line 339, an overstated universal that the page's own rows contradict.**
   - Current: "The public routes fail the build on content they can't serve, and each failure names its cause in the error."
   - Problem: Two rows disprove it. Row 344 (`expected input to be a string or buffer`) does not name its cause, a lazy or wrong-shape glob. Row 368 is SvelteKit's crawl check, not a cairn message. Flag this for the claims checker.
   - Replacement: "The public routes fail the build on content they can't serve. :fact[kv3qen] :fact[ky39tz] :fact[d7v5cg]"
   - This drops the false universal clause. That is a claim change for you to rule on, not a style edit.

2. **Line 185, a reference by position (blocks the page under the base guide).**
   - Current: "apply the migration as the earlier steps show."
   - Rule: Google procedures, "a reference names its target, never its position."
   - The quoted message is also in quotation marks, while every Diagnose row puts its message in code font.
   - Replacement: "If a mint answers `The preview_tokens table is missing.`, copy and apply `0003_preview.sql` as Mount the draft preview route's first two steps show. :fact[rr00qr]"

3. **Line 244, a two-action procedure written as one bullet (blocks the page under the base guide).**
   - Current: "If `noindex` entries should stay out, drop each entry whose `robots` includes `noindex` in the sitemap route and the feed mapping. Read the field with `readSeoFields`."
   - Rule: a sequence of actions is a numbered list introduced by a complete sentence, and a bullet holds a one-step procedure only. This line has two places to act and a third instruction. It is also the only task section on the page with no "follow these steps" list.
   - Replacement:
     - "To keep `noindex` entries out, follow these steps: :fact[ms7l5u] :fact[jsh6ae]"
     - "1. In the sitemap route, drop each entry whose `robots` includes `noindex`, read with `readSeoFields`. :fact[ms7l5u] :fact[jsh6ae]"
     - "2. In the feed mapping, drop the same entries. :fact[ms7l5u]"

4. **Lines 328–332, "preview" means two things.**
   - Current: "serve the build. A scaffolded site's `npm run preview` …", "fetch `/sitemap.xml` from the preview address", "not the preview's address", and `'<preview>/<permalink>.md'`.
   - Problem: Three sections earlier, "preview" named the draft preview route and `/preview/<token>`. In the verify section it names the local server. A reader can take "the preview address" to mean a preview link.
   - Replacement for step 3: "fetch `/sitemap.xml` from the local server. Each `loc` starts with your origin literal, not the local server's address."
   - Replacement for step 6: `'<local-server>/<permalink>.md'`
   - The command name `npm run preview` stays as it is. Keep all fact tags on their lines.

5. **Line 164, an abstract noun and an equivocation.**
   - Current: "The route renders the draft through the composition the entry pages use, from the same shared config."
   - Problem: "the composition" stands in for a named public export, `composeEntryData`, which `/delivery` exports (f:umdf7r). Elsewhere in the extend arm, "composition" means the engine building its runtime at server start (restrict-admin-access.md:71), and step 3 here passes a composed `runtime`.
   - Replacement: "An editor shares an unpublished draft through a link to `/preview/<token>`. The route renders the draft with `composeEntryData` from the same shared config, and `entryLoad` runs that function too. :fact[76m2vf] :fact[umdf7r] :fact[6c3amx]"

6. **Line 93, an imperative outside a step that pulls against line 96 and repeats step 1.**
   - Current: "Keep the site's origin in one string literal with no trailing slash. Set it to the deployed origin before a production build."
   - Problem: Imperatives belong only in steps, task headings, cross-references and notices. Line 96 then says the literal "is the scaffold's choice, not an engine rule", which contradicts the order to keep it in a literal. The second sentence repeats step 98.
   - Replacement: "The origin is one string with no trailing slash, and a production build needs it set to the deployed origin. The scaffold keeps it in one string literal. :fact[niuzzg] :fact[k16chc]"

7. **Line 252, two hinges in one sentence, and a restatement.**
   - Current: "An archive reads a dated concept's `all()`, which already returns entries newest first, so the route paginates the list without sorting it."
   - Problem: Line 84 says `all()` returns entries in order, and line 253 gives the order on the next line.
   - Replacement: "The archive route paginates a dated concept's `all()` as it comes, with no sort of its own. :fact[upec9v]"
   - Line 253 still carries "newest first", so no claim is lost across the pair. If each line must stand alone, use this instead: "A dated concept's `all()` already returns entries newest first. The archive route paginates that list without sorting it. :fact[upec9v]"

8. **Line 107, paired "which" clauses (balanced halves, near an appositive stack).**
   - Current: "`createPublicRoutes` turns one `PublicRoutesConfig` into `entries`, which lists each routable entry for the prerenderer, and `entryLoad`, which loads one entry."
   - Replacement: "`createPublicRoutes` turns one `PublicRoutesConfig` into two functions. `entries` lists each routable entry for the prerenderer, and `entryLoad` loads one entry. :fact[pkt8i6]"
   - Both are called as functions at line 110.

9. **Line 84, an abstract noun and a pointer hinge.**
   - Current: "Each index's `all()` already returns its entries in the engine's order, which Build the archive relies on."
   - Replacement: "Each index's `all()` already returns its entries in the engine's sort order. [Build the archive](#build-the-archive) relies on that order. :fact[upec9v]"

10. **Line 176, an imperative outside a step, a "since" hinge, and a restatement.**
    - Current: "Keep the directory name `preview/[token]`, since a minted link points at `/preview/<token>`."
    - Problem: The path is already in lines 164 and 171.
    - Replacement: "A minted link points at `/preview/<token>`, and the route's directory name has to match it. :fact[76m2vf]"

11. **Bare section titles used as nouns, and the recycled ", as X shows" tail.**
    - Lines: 81, 166, 225, 246, 261, 289, 290, 370 and 376.
    - Problem: A repeated phrase across the page is a restatement tell. Some lines read as garbled because the title sits unlinked inside the sentence, worst at 166: "the `PUBLIC_ORIGIN` that Name the origin once sets".
    - Replacement for 166: "A hand-built site needs an `AUTH_DB` D1 binding and the `PUBLIC_ORIGIN` value from [Name the origin once](#name-the-origin-once). The mint builds each link from `PUBLIC_ORIGIN`. :fact[049lo2] :fact[sp2org]"
    - Replacement for 81: "A glob in another form fails the build. See [Diagnose a failed build](#diagnose-a-failed-build). :fact[n07oiu]"
    - Replacement for 225: "An entry marked `noindex` still gets a row. :fact[ms7l5u]" plus a separate line, "See [Keep noindex entries out of the sitemap and feeds](#keep-noindex-entries-out-of-the-sitemap-and-feeds)."
    - Replacement for 261: "The engine builds no head for the archive. See [Give other pages a head](#give-other-pages-a-head). :fact[k7nln3]"
    - Lines 246, 290, 370 and 376 can keep their wording if the title becomes a link.

12. **Line 318, a "which" with an unclear antecedent.**
    - Current: "…rather than the full adapter, which skips the renderer's cost."
    - Problem: The sentence seems to say the adapter skips the cost.
    - Replacement: "Because the layout load imports that module rather than the full adapter, it skips the renderer's cost. :fact[ri06xw]"

13. **Line 21, a crafted capper.**
    - Current: "What a build writes is what the site serves."
    - Problem: An aphoristic chiasmus.
    - Replacement: "The routes prerender from the markdown in the deployed commit, and the site serves the files that build writes, with no GitHub read per request. :fact[1mkckz] :fact[8k9xwm]"

14. **Line 24, a setup-colon triad with balanced halves.** This is an intro plan line, but the drafter will copy its cadence.
    - Current: "the site owns the routes, the engine supplies the builders, and the routes read the index and the origin."
    - Replacement: "The introduction opens on that model: each route is a site file that calls an engine builder and reads the index and the origin. :fact[pkt8i6] :fact[yef4lo]"

15. **Line 83, an imperative outside a step, and casual "anyway".**
    - Current: "Pass the parsed config anyway."
    - Replacement: "The site config argument doesn't change the indexes, and the call still takes the parsed config. :fact[n33lwb]"

16. **Line 87, a declarative that hides an obligation.**
    - Current: "A route that looks an entry up by id checks its `draft` field."
    - Problem: It reads as if something checks the field automatically.
    - Replacement: "A route that looks an entry up by id has to check its `draft` field. :fact[m9z6sr]"

17. **Line 101, "Its" has no clear antecedent.**
    - Current: "Its entry config, feeds, sitemap, and robots route read that object."
    - Replacement: "The scaffold's entry config, feeds, sitemap, and robots route read that object. :fact[niuzzg] :fact[ioh6uj]"

18. **Line 303, a restated argument.**
    - Current: "…with `readMenu(siteConfig, name, maxDepth)`, at the depth `maxDepth` sets."
    - Problem: The tail restates the argument and leaves unclear which `maxDepth` is meant.
    - Replacement: "…with `readMenu(siteConfig, name, maxDepth)`, passing the `maxDepth` that `editor.nav` declares. :fact[rnwver] :fact[ri06xw]"
    - The scaffold passes 2 for primary, which matches its `maxDepth: 2`.

19. **Line 212, an ambiguous apposition.**
    - Current: "each a `loc` built from the origin and an optional `lastmod`"
    - Problem: It reads as if the `loc` is built from the origin and the `lastmod`.
    - Replacement: "The sitemap route passes `sitemapResponse` one `SitemapUrl` per page. Each has a `loc`, built from the origin, and an optional `lastmod`. :fact[pvk6h5]"

20. **Line 328, an awkward subject in a step.**
    - Current: "and another site runs `wrangler dev` itself."
    - Replacement: "A scaffolded site's `npm run preview` runs `wrangler dev`. On another site, run `wrangler dev` directly. :fact[8k9xwm] :fact[gwpffe]"

21. **Line 319, a restatement.**
    - Current: "`/admin/nav` edits the menu `menuName` names."
    - Problem: Lines 298 and 302 already say this, and the sentence is only a setup for the footer contrast.
    - Replacement: "The scaffold's `menus.footer` is a flat list outside `/admin/nav`: you edit it in `site.config.yaml` and read it with `readMenu(siteConfig, 'footer', 1)`. :fact[2s8u70] :fact[t895qz]"

22. **Line 379, "its" points at the wrong noun.**
    - Current: "…left out of the index and listed by its `problems()`."
    - Problem: It reads as the entry's `problems()`. Per f:kv3qen it is `ContentIndex.problems()`.
    - Replacement: "…left out of the index and listed by the index's `problems()`. :fact[kv3qen]"

23. **Line 254, a trailing "which".**
    - Current: "Both paginate the posts after the newest, which the home page shows as its lead."
    - Replacement: "The home page shows the newest post as its lead, and both paginate the posts after it. :fact[38pjqy]"

24. **Line 71, a dangling "such as".**
    - Current: "may lay these files out differently, such as routes directly under `src/routes/` with no `(site)` group."
    - Replacement: "may lay these files out differently, for example with routes directly under `src/routes/` and no `(site)` group."

25. **Line 147, a comma chain in list cadence.**
    - Current: "serves each entry's stored markdown, unrendered, at its permalink plus `.md`, from a prerendered route beside the catch-all."
    - Replacement: "The markdown twin is a prerendered route beside the catch-all. It serves each entry's stored markdown, unrendered, at the entry's permalink plus `.md`. :fact[03lbjg]"

26. **Line 119, a partial restatement.**
    - Current: "and the origin also anchors `og:url`."
    - Problem: Line 95 already says this.
    - Replacement: "The canonical URL is the origin plus the permalink, and `og:url` starts from the same origin. :fact[k16chc]"
    - The claim is kept, so this is a soft finding.

27. **Line 56, a lead-in that repeats the heading.**
    - Current: "Before you start, your site needs the following:"
    - Replacement: "Your site needs the following:"
    - The flat list also mixes requirement items with "See" lines. The drafter should nest each See under its item so the list stays one form.

28. **Line 331, a step with no location.**
    - Current: "Fetch `/robots.txt`."
    - Problem: Steps 3 and 4 name where; this one doesn't.
    - Replacement: "In the same terminal, fetch `/robots.txt`. …"

29. **`sc-preview` in security-model.blueprint.yaml, a nested serial list inside prose (list cadence), plus one imprecise verb.**
    - Current: "Anyone who holds it reads that one draft with no sign-in, until the link expires, an editor revokes it, the entry is published, discarded, renamed, or deleted, or the editor who minted it is removed."
    - Problem: The sentence is 39 words. That is allowed in explanation, but one series nested in another is hard to parse. "is removed" could also be read as a role change, and f:sp9rem says a role change leaves the links in place.
    - Replacement: "A draft preview link sits outside `/admin`, and the link is the credential. Anyone who holds it reads that one draft with no sign-in until the link stops working. It stops working when it expires, when an editor revokes it, when the entry is published, discarded, renamed, or deleted, or when the editor who minted it is removed from the site."
    - Keep the facts list unchanged: f:afkvsb, f:76m2vf, f:pimnjy, f:a7yrhq, f:l4waby, f:sp9rem.
    - I checked the content against those facts. Publishing or discarding ends the draft view through the ended state (f:l4waby, f:a7yrhq), so the claim holds.

30. **No rewrite needed:**
    - **Line 69, 36 words:** a `Code:` plan line describing a file tree; it never reaches the page as prose.
    - **Lines 14, 16, 25, 26, over 26 words:** `:::reader` intro material, which is exempt.
    - **Lines 78, 116, 141, 155, 223, 300:** each has a single hinge with no run, which is acceptable.
    - **Line 48, 30 words:** a `:::constraints` instruction, not a claim.

## Verdict: fix

Findings 2 and 3 are base-guide structural defects: a reference by position, and a two-action procedure in a bullet. Finding 1 is a false universal the page's own rows disprove. Otherwise the blueprint reads as a plausible plan in the cairn developer register. It has no "own", no em dashes, no marketing, and tellgrader found nothing.

The leftover AI cadence is local: a recycled ", as <Section> shows" tail, a few double-hinge sentences (252, 107, 318), and unclear "its" and "which" references. The change that would move it most is to rewrite line 339, then make every same-page section reference a real link in its own sentence or clause (finding 11). That removes the repeated tail and the garbled line 166 in one sweep.