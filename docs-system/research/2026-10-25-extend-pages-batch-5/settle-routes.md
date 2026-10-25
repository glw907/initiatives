# Routes page settlement: 441a2c181 on ebp5-routes-page

Gates: drafter check 0 errors (13 warnings, pre-existing); check:docs-gate exit 0.
All 12 non-holds fact findings and 30 register findings settled; no disputes.

Question for Geoff (f:n07oiu): the fact says a glob "without `?raw` and `import: 'default'`"
throws `expected input to be a string or buffer`. gray-matter throws it for non-string input
(`node_modules/gray-matter/lib/utils.js:46`), so a lazy glob or a missing `import: 'default'`
reaches it. Without `?raw`, Vite imports the .md as a module first; whether that reaches the
message depends on a markdown plugin (the scaffold has none). This page now names only the
proven cases; the fact and define-an-adapter-and-schema.md (brief s102, s214; blueprint L116,
L296-297) keep the `?raw` clause. Choices: narrow the fact and that page in a separate change, or
keep the clause.

Key changes (page line after change):
- L5 "Every route reads the same two inputs" -> "The routes draw on two shared inputs" (fact p1)
- L9 share image: adds the `defaultImage` fallback (fact p3)
- L107, L739 glob failure narrowed to a lazy glob or a missing `import: 'default'` (fact)
- L221 `assetsEnabled` logs once per `createPublicRoutes` call (fact p10)
- L248 `article:author` and feed links conditional (fact p8; f:j81xye edited)
- L255, L723 twin serves the body without frontmatter, not for noindex entries (fact p0)
- L301 wrangler dev content type worded as a local measurement (unsupported -> measurement)
- L367-373 share steps split to four; Details slide-over location confirmed in
  `src/lib/admin/EditPage.svelte:2383-2444` (f:sp1mbt edited; blueprint L184)
- L462-481, L571-603 about page examples -> contact page (collided with the scaffold's about entry)
- L528-538 sitemap noindex helper now looks up `site.byPermalink`, so noindex pages in any
  concept are excluded (register 20)
- L707 `vite preview` limit linked to sveltejs/kit#17271 (unsupported -> linked)
- f:rzfdqw scheme list `http://`, `https://`
- Register: blocking 1 (named targets at L158) and 2 (one action per step) fixed; 28 others applied.
- Left alone (against the blueprint): out-of-scope list omits share-a-draft-preview.md; L420
  copies the FeedChannel/FeedItem member list.

Recheck ranges: 3, 5, 7, 9, 13-19, 23, 25, 67, 107, 109-113, 119-121, 158, 221, 248, 255, 297,
301, 321, 367-379, 425, 462, 477, 481, 488-491, 521, 528-538, 547, 556, 571-603, 683, 689, 701,
707, 711, 723, 739, 746, 750, 760.
