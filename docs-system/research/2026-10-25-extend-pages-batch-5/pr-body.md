## Brief

This PR drafts the last five task guides in the extend track: Build the public routes, Configure media, Define an adapter and schema, Migrate existing content, and Write a markdown component. Each comes from the blueprint you approved in batch 3. The drafter wrote all five for $9.57. A fresh fact-checker read each page against the code, the register editor reviewed each one, and every finding is settled.

### What changes

- Five new pages under `docs/extend/`, with their sentence-to-fact briefs and `blueprints/drafted.lock` entries.
- Their blueprints and facts, corrected wherever a check found the code disagreed.
- Two engine-wide stale claims, fixed everywhere they appeared:
  - Under SvelteKit 3, a `fail()` sets the response's HTTP status, and the body is still the action envelope. The prose said 200 in five places, including `docs/reference/sveltekit.md` and the upload action's TSDoc.
  - A missing `resolveMedia` costs a page its hero image, not every image. Debug your site, the `log-events` and `delivery` reference rows, and the `createPublicRoutes` TSDoc now say so.
- The `parseSiteConfig` entry in `docs/reference/core.md` says the parser doesn't check `spellcheck.dialect`, and any value falls back to American English.
- Two hand-offs on Security model and Define an adapter and schema now name what Write a markdown component covers.
- One code comment, on `groupDefs` in `ComponentInsertDialog.svelte`, now says where the unheaded group sits.

### If you approve

Each page is its own approval-queue item. Once you approve all five, the session merges this PR.

## Decisions

- Turn on tidy linked an anchor on Define an adapter and schema that the adapter blueprint dropped, which stopped the draft run. The link now points at the `parseSiteConfig` reference entry.
- Define an adapter and schema dropped its section on site-config keys, per its blueprint. The `spellcheck.dialect` rule it carried (`f:a81e6y`) moved to the `parseSiteConfig` reference entry, so the rule still has a home.
- `f:n07oiu` named a glob missing `?raw` as a cause of `expected input to be a string or buffer`. The code proves only a lazy glob and a glob missing `import: 'default'`. The fact and both pages that cite it now name only those two.
- The media fact `f:twqb0s` was first corrected too broadly, to say every image loses its source. A recheck caught it, and the correction now separates the hero image from body images.
- Write a markdown component's verify procedure checks the public render through a share link on the dev server instead of publishing and checking the deployed page, as the approved blueprint had it. As approved, the procedure couldn't finish from the dev server. The page's note asks you to keep this or restore the publish step.
- A check on that page found six published extend pages still showing the hooks calls engine pass B replaced (`37797ff35`). That fix is its own PR, off `main`, so these five pages don't wait on it.
- The unnamed `drafter check` reports 27 errors on `main`, all in blueprints and facts outside this batch. CI doesn't run it. This PR leaves them, and they're filed as friction.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
