# Register edit: docs/extend/configure-media.md at 30e58dd56

Verdict: fix. Blocking: 1, 2, 3. [claims] marks a finding that touches a claim.

1. L237-240 (blocks): step 7 lacks step 6's condition. "7. In the site directory, build the site." -> "7. If you wrapped the resolver, in the site directory, build the site from that branch."
2. L197 (blocks): link text is an event name but lands on the page top. -> "For every reason the action logs, see the `media.upload_failed` row in [Log events](../reference/log-events.md)."
3. L11-12 (blocks): list items not parallel ("X should Y"). -> "The developer should learn which references the Library counts before an editor deletes an asset that a page may still use." / "A custom admin screen on the site should upload images."
4. L3, L90 [claims]: overstated universals contradicted by L153-157 (raw HTML URLs). L3 -> "...renaming an asset doesn't break a `media:` reference to it." L90 -> "Neither change requires an edit to a `media:` reference, because the resolver builds each URL from the manifest's row. A URL written out in a raw HTML block isn't a `media:` reference, and it doesn't follow either change." Rename claim not in blueprint Background: confirm source.
5. L161, L166 [claims]: restore the literal URL from blueprint L176/L180. L161 -> "...so the request goes to `/admin/media?/mediaUpload`." L166 -> "...post the file's bytes as the body to `/admin/media?/mediaUpload`, with `redirect: 'manual'`."
6. L187 [claims]: blueprint L187-188 names `data` and `data.error`. -> "A success envelope's `data` holds the `reference`, a `media:` reference, and the manifest `record` that the server derived. Each refusal the action makes arrives as a `failure` envelope with the HTTP status still 200, and its `data.error` names the reason."
7. L110 [claims]: say what the throwing wrapper does on a request-time render (one sentence after "fails the build instead"); code supplies the behavior.
8. L104: qualified claim split. -> "With `transformations` on, an image gets a `srcset` of Cloudflare transform URLs when its manifest row records a width wide enough to offer more than one candidate width. The `sizes` hint comes from the image's `:::figure` placement, and an image with no placement gets `100vw`. With `transformations` off, every image gets its full-size path. Either way, ..." and drop the separate "gets no `srcset`" sentence.
9. L157 [claims]: missing consequence plus "never sees". -> "Deleting an asset that only those places name leaves each reference as written, because the resolver doesn't process an uncounted reference. Where that reference is the asset's URL, as in a raw HTML block, the media route answers it with 404. The wrapper in [Fail the build on a missing asset](#fail-the-build-on-a-missing-asset) doesn't catch these references." Confirm.
10. L246, L247, L248, L255 [claims]: restore the blueprint's log signals. L246 Symptom -> "The upload fails with the refusal `too_large`, and the Worker logs `media.upload_failed` with `reason: 'too_large'`." Same for L247 (`unsupported_type`). L248 add "and the Worker logs no `media.upload_failed` record". L255 restore "answers 403" if confirmed.
11. L251 [claims]: two causes, one fix. Split: narrow-width row keeps "None is needed. An image with only one candidate width renders at its full-size path."; no-width cause gets its own row with a fix from the code (perhaps re-upload recording the width; `X-Cairn-Width`).
12. L255 vs docs/reference/log-events.md L47 [claims]: log-events lists `csrf` among `media.upload_failed` reasons; page gives CSRF refusal only to `guard.refused`. Confirm which record a bad-CSRF upload produces (fix the reference page if it is wrong).
13. L75: -> "Because the route reads only the URL's last path segment, the same handler at both paths serves the preview's URLs and the published ones."
14. L88 [claims]: -> "With any other value, the engine throws `cairn: media urlForm must be "slug" or "opaque", got "<value>"` when it resolves the config."
15. L153 vs L201 [claims]: "`main`" vs "the default branch"; use "the default branch" unless the Library reads `main` literally.
16. L169: -> "Before the action runs, SvelteKit refuses a form action's POST whose content type isn't a form type, and `text/plain` is one of the form types it accepts."
17. L183: "Each header's value is URI-encoded." -> "URI-encode each header's value." [claims] blueprint says "Each text value"; confirm width/height.
18. L220 [claims]: blueprint verify step 4 gives "a recorded width of at least 800 pixels"; draft says "wide enough to offer more than one size". Restore the threshold if real.
19. Library naming (first use L11): -> "the media library, the admin screen labeled **Library** at `/admin/media`", then one form consistently.
20. L167, L235: "media type" wording. L167 -> "In the same request, set the `Content-Type` header to `text/plain` and the `X-Cairn-CSRF` header to the token." L235 -> "Its `Content-Type` is the type the upload stored, such as `image/jpeg`."
21. L112: -> "It's the fallback in the adapter's `render` and the `resolveMedia` value in the public routes config, so wrapping it where it's defined covers both."
22. L44: -> "The engine refuses a sniffed HEIC or unrecognized file as `unsupported_type`, whatever the list holds. It also refuses an upload declared as `image/svg+xml`, `image/svg`, `text/html`, or `application/xml`, or one whose first non-whitespace byte is `<`."
23. L5 -> "This page covers changing how those pieces behave on a site that already has them, not setting them up." L14 "the page ends by checking each change" -> "the page ends with a check of each change on the deployed site".
24. L214 -> "3. In the same entry, publish the entry." L216 -> "The editor documentation covers placing an image and publishing an entry."
25. L48, L197, L248: use "an HTTP 413 response" throughout; L197 -> "Cloudflare answers a body over the plan's request limit with an HTTP 413 response before the action runs."
26. L254 [claims]: "the guard" undefined -> "the admin guard".
27. L201: "still runs at runtime" -> "The action exists at runtime, and typed code reaches it only through a spread or a cast."
28. L261: "the tasks beside this one" -> "related tasks".

Against the blueprint:
- Blueprint L26 copied at L14 names planning taxonomy ("A concept section ... An optional task ..."). Proposed: "A section after the steps says which references the Library counts as a use of an asset, and a section for a site with a custom admin screen covers uploading from one."
- Blueprint L214-274 inline symptom rows: standing pattern on sibling pages; advisory, no change.
