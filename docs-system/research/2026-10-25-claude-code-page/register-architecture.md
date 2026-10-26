# Register edit: docs/extend/architecture.md

- Page: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/rd-architecture/docs/extend/architecture.md` (commit f7fa2a065)
- Blueprint: `blueprints/docs/extend/architecture.blueprint.md` (same worktree)
- Track: extend, concept page. Base guide: Google. Overlay: `docs/internal/docs-register.md` (developer brief, Names, Visuals, page anatomies, extend track).
- Verdict: **fix** (3 blocking, 15 non-blocking)

## Deterministic floor

`tellgrader --register docs` exited 0 with no findings (profile `docs-register`). Counts: tricolon 5, uniform-paragraph 3. Vale reported 0 errors. Its warnings are `admin` to `administrator` (the register sanctions "admin" for the extend reader), one `Cairn.NamesRetired` on line 337 "The package lists..." (a package fact, so correct as written), `Email` capitalized in "Email Sending binding" (a Cloudflare product name, so correct), and passive-voice and contraction suggestions that the measured register overrides.

| Measure | Value |
|---|---|
| sentences (prose, scanner) | 168 |
| hinged_pair_share | 0.327 |
| short_sentence_share | 0.107 |
| average sentence length | about 16 words (3,357 words over 212 sentences) |
| longest sentence | about 37 words, intro line 20 ("A developer who takes over a site it set up ... covers those files one by one.") |
| paragraphs | about 70, plus 7 lists and 3 tables |
| disproportionate paragraph | the introduction: five paragraphs and two lists (about 330 words) before the first heading, where the brief's guidance is two or three paragraphs |

The shares carry no band. The 0.33 hinged-pair share does match what a read finds: about a third of the sentences take the "A does X, and B does Y" shape, and findings 9 and 10 cover that cadence.

## Guide conformance (first lens)

The structure checks pass. Every list and table has a complete-sentence lead-in. Headings are sentence-case noun phrases with no links and no skipped levels. No step, list item, or task sentence runs past 26 words. Code font is consistent apart from finding 14. The diagram carries `accTitle`, `accDescr`, and an emphasis caption on the line after the fence. Related resources come in three groups of 5, 3, and 5 links. No base-guide structural finding blocks the page. The three blocking findings are truth and logic defects in the page's claims.

## Findings, ranked

### 1. BLOCKING: the head-guard list contradicts its own exception (logic)

> "The head guard fails on the first stale head. It covers single publish, ... and the personal-dictionary add." ... "The personal-dictionary add retries once after a conflict, re-reading the head and the file."

The list puts the personal-dictionary add under a rule that "fails on the first stale head". Two sentences later, the page says that same commit retries. A reader can't trust either rule while one commit sits under both. Move the personal-dictionary add out of the list and state it as the one exception, or make the guard's wording admit the exception.

Proposed rewrite (list item 2 and the paragraph after it):

> - The head guard refuses on the first stale head. It covers single publish, publish-all, revert, the nav, tidy settings, and the site vocabulary.
> - (second sentence of that item unchanged: the media commits)
>
> The personal-dictionary add takes the head guard but retries once after a conflict, re-reading the head and the file. A guarded commit reads the head before any file its new contents are computed from. ...

(Send to the claims checker as well. Fact `0gihxq` should settle which rule the dictionary add follows.)

### 2. BLOCKING: "frozen contract" contradicts the next paragraph (equivocation, overstated universal)

> "Extension API and Scaffold API are the frozen contract, and Unstable API stays importable with no promise across minor versions." / "Because cairn is pre-1.0, the tiers are a target discipline, and an Extension-tier break can ship in a minor release."

The first paragraph calls the Extension tier "frozen". The next one says it can break in a minor release, and the section's own 0.86.0 example is such a break. "Frozen" is false before 1.0. "Target discipline" is vague jargon trying to cover the gap.

Proposed rewrite:

> Every export carries one of three stability tiers, and the tier states what the export promises across versions. Extension API and Scaffold API are the exports a site builds on, and Unstable API stays importable with no promise across minor versions. For each export's tier, see [Stability tiers in the reference index](../reference/README.md#stability-tiers).
>
> Until 1.0, the tiers state intent rather than a guarantee, and an Extension-tier break can ship in a minor release. The `check:surface` snapshot gate fails on any change to an export's declared shape until the golden file is regenerated to record it. Before 1.0, the gate detects and discloses a break rather than preventing one.

### 3. BLOCKING: "depends on outright" contradicts "a seam that replaces it" (logic, broken antecedent)

> "Each of these stores is a platform the engine depends on outright, and only the content store has a seam that replaces it."

If the content store can be replaced, the engine does not depend on it "outright". "These stores" is also unclear: the sentence before is about a site's own data and the `cairn_` cookie prefix, not about git, D1, and R2. This hand-off sentence also carries the premise of the next section, so the error spreads into it.

Proposed rewrite:

> The engine depends on the platforms behind these tiers directly. Of them, only the content store has a seam that replaces it.

### 4. The introduction says its first sentence twice (restatement; intro length)

> "A developer comparing content systems first needs to know what kind of system cairn is, and what adopting it commits a site to." ... "An evaluator reads the page end to end to learn what cairn is and what adopting it commits a site to."

Paragraph 4 repeats paragraph 1 almost word for word. The introduction then runs to five paragraphs and two lists, past the brief's two or three paragraphs. Paragraph 4 also drops a scaffolder fact into the middle of the reader list. Its pronoun then breaks: "a site it set up" could refer to the site or to `create-cairn-site`.

Proposed rewrite of paragraph 4:

> An evaluator reads end to end. A developer who inherits a site that `create-cairn-site` set up, with its GitHub App, repository, and Cloudflare bindings, uses the page to map the site's files onto the engine's entry points, seams, and stores, and [Scaffolded site files](scaffolded-site-files.md) covers those files one by one. A developer partway through a task, such as adding a custom admin screen or replacing magic links, arrives here to place one seam among the rest.

Then shorten paragraph 1's opening so the reader framing appears only once. For example: "cairn is a library, not a separate service. The engine ships as the npm package ...". The evaluator's question then lives in paragraph 4 alone.

### 5. Intro paragraph 3 is a comma-spliced triad with a capper (list cadence in prose; crafted capper)

> "One adapter declaration drives the engine, a site extends the engine through seams without forking it, and each export carries a stability tier that states what it promises across versions. Together these properties decide which code a site writes and which contracts it relies on."

Three independent clauses are run together as an inventory. A paired, summarizing capper then closes the paragraph and adds no information.

Proposed rewrite:

> Three properties decide which code a site writes and which contracts it relies on. One adapter declaration drives the engine. A site extends the engine through seams rather than by forking it. Each export carries a stability tier that states what it promises across versions.

### 6. "Two of these seams" contradicts the table, which lists them as one row (logic)

> "Two of these seams, the role vocabulary and the access map, have several readers inside the engine."

The table's row is "Roles and the access map", which is one seam. The subsection heading treats them as one subject too.

Proposed rewrite:

> The roles and access-map seam has several readers inside the engine.

### 7. "the vocabulary" collides with "role vocabulary" (equivocation)

> "It covers single publish, publish-all, revert, the nav, tidy settings, the vocabulary, and the personal-dictionary add."

Everywhere else on the page, "vocabulary" means the role vocabulary. Here it means the site vocabulary that `readVocabulary` reads (core reference, "Runtime and config"). A reader will assume the role vocabulary is a guarded commit. "Tidy settings" and "the nav" are also introduced with no context.

Proposed rewrite: "... the nav menu, tidy settings, the site vocabulary, ...". Link "tidy" to [Turn on tidy](turn-on-tidy.md) at its first mention.

### 8. "member roster" collides with the engine's roster (equivocation; example choice)

> "A site's data, such as a member roster or an event schedule, goes wherever the site chooses, and cairn assigns it no tier."

The page uses "the roster" for the engine's editor list ("The guard still looks that email up in the roster", "The roster screen's routes"). Here, "member roster" names data the engine does not own. Use a different noun. "The roster" is also never defined on the page. Tie it once to the D1 `editor` table.

Proposed rewrite:

> A site's own data, such as a member directory or an event schedule, goes wherever the site chooses, and cairn assigns it no tier.

At the first mention of the roster (Seams table, `identity` row): "The guard still looks that email up in the editor roster, the `editor` table in D1."

### 9. Hand-off wording: balanced halves and a chained capper (balanced-halves; crafted pivots)

The blueprint places these hand-offs, so only their wording is graded here.

> "The map says where each export lives, and the seams say which exports take a site's code or data."

This is an echo pair ("X says ..., and Y says ...") built for its symmetry. Rewrite: "Some of those exports are seams, which take a site's code or data."

> "That manifest is one kind of state the engine keeps in git, and git is one of three stores the engine places state in."

This chains the last word of one clause into the next (anadiplosis). Rewrite: "Git holds that manifest alongside the other state the engine keeps, in one of three stores."

> "Code a site writes against the Extension tier therefore meets each break as a named change."

This capper repeats "detects and discloses" from the paragraph before, and "meets" is figurative. Rewrite: "Each such break is named in the migration notes before a site upgrades. For the upgrade procedure, see [Upgrade cairn](upgrade-cairn.md)." (Send "each" to the claims checker.)

### 10. Paragraph-level "X, and Y" cadence (list cadence in prose; hinged_pair_share 0.33)

The clearest run is the Roles subsection, lines 154 to 170. Nearly every sentence there joins two independent clauses with ", and". Example:

> "The roster screen's routes validate a posted role against `runtime.roles`. The admin mount forwards its runtime to them, and a site passes `runtime` itself only when it wires `createEditorRoutes` by hand. The guard's `runtime` option is required and has no default, and a call without it is a type error."

Proposed rewrite:

> The roster screen's routes validate a posted role against `runtime.roles`. The admin mount forwards its runtime to them. A site passes `runtime` itself only when it wires `createEditorRoutes` by hand. On the guard, `runtime` is required: a call without it is a type error.

Apply the same pass to "The publish commit" paragraph 1 and to "Data tiers" paragraph 3.

### 11. The Read path's opening sentence doesn't parse cleanly (clarity)

> "The admin reads one entry from a concurrent batch of reads through the `Backend`, and it reads the whole corpus from the committed content manifest."

"Reads one entry from a concurrent batch of reads" is circular.

Proposed rewrite:

> To load one entry, the admin sends a concurrent batch of reads through the `Backend`. To read the whole corpus, it reads the committed content manifest.

### 12. The esbuild paragraph leaves out the middle step (missing middle)

> "A `/sveltekit` export bundled with plain esbuild outside Vite, such as `createD1AuditSink` in a Cron Worker, needs no alias for `$app/env`. `loadPreview`, on the same subpath, imports that module dynamically at call time."

The reader has to infer why the second sentence explains the first.

Proposed rewrite:

> `loadPreview` imports `$app/env` dynamically at call time, not at module load. A `/sveltekit` export bundled with plain esbuild outside Vite, such as `createD1AuditSink` in a Cron Worker, therefore needs no alias for that module. For more information, see [the `loadPreview` reference](../reference/sveltekit.md#loadpreview).

### 13. Engine-internal mechanics "covered by a stability-tiered subpath" (unclear claim)

> "Each is covered by a stability-tiered subpath (`/render`, `/sveltekit`, or `/auth-crypto`), and none is a seam a site reaches into."

As written, internal mechanisms seem to carry a stability tier, which conflicts with calling them engine-internal.

Proposed rewrite:

> Each runs behind a subpath, `/render`, `/sveltekit`, or `/auth-crypto`, whose exports carry the stability tier. The mechanism itself is not a seam a site reaches into.

### 14. Role names and the dev package are not named precisely (Google code font; Names)

> "With no roles declared on the adapter, it falls back to the owner and editor pair." / "to `devBackendHandle` from a separate dev package"

The role identifiers appear in code font in the Seams table (`none`, `editor`, `owner`) but not here. The blueprint names the package (`@glw907/cairn-cms-dev`), and other extend pages name it too. "A separate dev package" is vaguer than the fact it comes from.

Proposed rewrite: "... it falls back to the default pair, `owner` and `editor`." and "... to `devBackendHandle` from `@glw907/cairn-cms-dev`."

### 15. Restated store facts across four sections (restatement and filler)

The page says D1 holds sign-in or session rows and R2 holds media bytes in the introduction, in Write path ("The path crosses three stores. Git holds ..."), in the Data tiers table, and again in Data tiers ("R2 holds the media bytes, and the delivery route streams them directly."). The editor-as-author fact appears in The holding branch, The publish commit, and Data tiers. The deploy trigger appears in step 3, in the Concurrent writes hand-off, and in the first sentence of Build verification.

Proposed cuts:
- In Write path, keep only "The following diagram shows the path and the three stores it crosses." The table owns the per-store detail.
- In Data tiers, change "R2 holds the media bytes, and the delivery route streams them directly." to "The delivery route streams media bytes directly from R2."
- Open Build verification with "The build rebuilds the content manifest from the markdown on disk and verifies it against the committed manifest."
- In Data tiers, cut "An entry's body lives only in git." The sentence before it already says this.

### 16. "only the bytes it describes live in R2" is ambiguous, and "no audit table involved" misleads (clarity)

> "The media manifest carries what the bytes cannot, such as alt text and the original filename, and only the bytes it describes live in R2."
> "The default branch's history records who published each change and when, with no audit table involved."

The first could mean that R2 holds no undescribed bytes. The intended sense is that R2 holds no metadata. The second sits a paragraph above the opt-in `audit_log` table and reads as if no audit table exists.

Proposed rewrite:

> The media manifest carries what the bytes cannot, such as alt text and the original filename, and R2 holds only the bytes.
> The default branch's history records who published each change and when, whether or not the site wires the audit log.

### 17. "The engine keeps a few names for itself" merges a list with a rule (appositive-adjacent stack)

> "Among them are the manifest paths under `src/content/.cairn/` and the `/admin` segments the engine's screens own, and no concept may take one of those segments as its id."

Proposed rewrite:

> The engine reserves a few names, such as the manifest paths under `src/content/.cairn/` and the `/admin` segments its screens own. No concept may take a reserved segment as its id.

### 18. Links at first mention and a dropped fact (linking; fidelity)

- `composeRuntime` (line 56) and `defineAdapter` (line 67) have reference anchors (`../reference/core.md#composeruntime`, `../reference/core.md#defineadapter`) but are not linked at first mention. `createCairnAdmin` has `../reference/sveltekit.md#createcairnadmin`. Link each once.
- The blueprint's Export map list includes `./package.json` among the subpaths outside the groups (fact `533flu`). The page drops it. Restore it or record the cut.
- Concept-page anatomy: the brief expects a definition after the introduction. "The adapter" works as the premise, so this is advisory only.
- "On every admin path where it signs an editor in" (line 157): the guard resolves a session on most paths rather than signing anyone in. Send this to the claims checker. A possible rewrite is "On every admin path where it resolves a signed-in editor".

## Verdict

The body mostly reads as cairn's measured technical-report voice. Sections are scoped tightly to their facts, there's no marketing, no figurative headings, no agent content, and no consumer-domain examples. The deterministic floor is clean. The draft has two weaknesses that a plausible human author would avoid. First, the internal logic slips in three places where one sentence contradicts another (the personal-dictionary guard, the "frozen" tier, and the "outright" dependency with its seam). Second, a pervasive "A does X, and B does Y" compound cadence, a third of all sentences, makes the page read assembled rather than written. That cadence gets worst in the planned hand-offs and in an introduction that repeats its first sentence. The single change that would move it most is to fix the three contradictions, then rewrite the introduction down to three paragraphs with one statement of the evaluator's question. That removes the blocking defects and the page's most visibly machine-made stretch together.
