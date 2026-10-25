# Register edit: docs/extend/migrate-existing-content.md at bb835a5f7

Verdict: fix. Blocking: 1, 2, 3, 4, 5. [claims] marks a finding that touches a claim.

1. L116 (blocks, 26-word cap in a step) -> "The `id` line builds a dated id the way the admin's create dialog does. It joins the date, cut to the concept's `datePrefix`, to the slug with a hyphen."
2. L214 (blocks, cap) -> "An old image address left in a body keeps pointing where it did. An image whose old address still serves it can stay as it is."
3. L313 (blocks, two actions) -> "If a migrated entry's body starts with a `+++` block, convert the old file's TOML frontmatter to YAML before the next run."
4. L216-221 (blocks, prerequisite after its steps) [claims] -> "Moving an image into the media library needs media turned on. For more information, see [Configure media](configure-media.md). To move an image into the media library instead, follow these steps: 1. In the admin's **Media library** screen, upload the image. 2. In the entry's body, replace the old address with the image's `media:` reference. The media library takes one file per upload, and it stores and commits each file in one step." (blueprint L251 places the link after the steps: carry the move to the blueprint)
5. L204 (blocks, logic) [claims]: "convert each number or boolean to a string" would turn `draft: true` into a string and publish every draft. -> "In the script's `toFrontmatter`, convert each number or boolean bound for a text field to a string, and convert each such date with `toDay`." (code decides exact scope)
6. L138 -> "The mismatch throws no error and doesn't fail the build."
7. L307 -> "A failed check usually traces to a migrated file's name, one of its frontmatter values, or a block in its body. Work through the following checks in order:"
8. L134 [claims] -> "An entry's id is its filename stem, verbatim. The script therefore writes each entry to `<id>.md`."
9. L278 -> "With validation off, each invalid entry drops from the site with no error." then a step: "- Once every migrated entry validates, remove `{ validate: false }` from the `createSiteIndexes` call."
10. L274 -> "For the migration's causes of a listed field, see [Diagnose a failed check](#diagnose-a-failed-check). An invalid draft never fails the build, though the index still leaves it out. To find one, see [Verify the migrated entries](#verify-the-migrated-entries)."
11. L276 "as its fourth argument" -> "as the call's fourth argument".
12. L7 -> "A developer who copied old files in by hand and then found the build stopped, or an entry missing from the site, can start at [Diagnose a failed check](#diagnose-a-failed-check). ... The steps assume familiarity with Node.js ES-module scripts that read and write files, regular expressions, YAML frontmatter, and the old site's conventions, such as its shortcodes and how it spells drafts and dates."
13. L174: keep through "...lands on the next day." New paragraph: "The script's `toDay` returns the day as a `YYYY-MM-DD` string, and `frontmatterBlock` writes it quoted. For a `Date`, `toDay` takes the UTC day, as the field does, and reproduces the shift."
14. L5 [claims]: split at "This page builds one script..."; "...a script that reads the old files with it gets each frontmatter value typed as the build and the admin read it."; "...fails on any entry not marked as a draft whose frontmatter fails validation."; "...so a Hugo site's TOML files need converting to YAML before the script reads them."
15. L23 [claims] (blueprint L34 constraint) -> "A scaffolded site keeps the adapter in `src/theme/cairn.config.ts` and imports it as `cairn` from `#theme/cairn.config.js`, through the `#theme/*` import that [`package.json`](scaffolded-site-files.md#packagejson) maps to `src/theme/*`."
16. First-mention links: L5 [`parseMarkdown`](../reference/core.md#parsemarkdown); L25 [`createSiteIndexes`](../reference/delivery-data.md#createsiteindexes) and [`cairnManifest`](../reference/vite.md#cairnmanifest), plus "For more information, see [Build one typed index](build-the-public-routes.md#build-one-typed-index)."; L170 `content.field_undeclared` -> [Log events](../reference/log-events.md).
17. L216, 218, 221: screen title is "Media library" (`CairnMediaLibrary.svelte:638`). Step: "In the admin's **Media library** screen, upload the image."; prose: "the media library".
18. L17 [claims] -> "This page leaves out redirects from the old site's addresses."
19. L290, L301 [claims] -> "2. In the project directory, run `npm run build`." and "7. In the project directory, run `npm run dev`."
20. L182 [claims]: `toFrontmatter` gets the parsed object and filename, not raw text. -> "- For a `datetime` field, in `toFrontmatter`, write the timestamp as a quoted string, rebuilt with its offset or taken from the old file's raw text." plus "Taking it from the raw text means passing the text `readFile` returns into `toFrontmatter`." (confirm against the page's script)
21. L154 -> "Each of the following sections changes `toFrontmatter`."
22. L347 -> "The following pages cover what this migration depends on and the links between migrated entries:"
23. L322-323: "See [...]" -> "For more information, see [...]".
24. L194 [claims] -> "An admin save keeps an entry's existing tag that sits outside the vocabulary, as an orphan, and doesn't refuse it." (confirm)
25. L5, L33 (Cairn.NamesRetired "the package"): "`@glw907/cairn-cms` exports the same function from its root"; "...with a function that `@glw907/cairn-cms` doesn't export." ("the package's bins" can stay)
26. L146 [claims]: "rename and delete guards ... too" -> "The admin's rename and delete guards also treat the id as unparseable." (or the blueprint's "the admin's rename and delete actions refuse it"; code decides)
27. L180 -> "Because `parseMarkdown` hands an unquoted timestamp over as a `Date`, `frontmatterBlock` writes it as a UTC string that loses the offset."

Against the blueprint (noted, not edits):
- "An admin save deletes an undeclared key" five times (L3, 23, 154, 158, 190; blueprint L19, 47, 179, 186, 215); L154 and L158 back to back.
- "No importer ships with cairn" twice (L5, L31).
- "Set `DATE_PREFIX`..." twice (L114, L140).
- "An unquoted date or timestamp arrives as a `Date`" three times (L31, 174, 180).
- Media prerequisite: cleaner as a Before you begin bullet (blueprint L46-54 has none).

Departures: blueprint L26 names "Configure rendering" (now Write a markdown component; update the blueprint). The draft leaves out blueprint L322's rolled-over date fact (`2024-13-45` parses as `2025-02-14`, never reported invalid): restore it unless the code says otherwise.
