# B3c's eight drafts, read and fact-checked

Date: 2026-10-19. Initiative: `docs-system`. Written by the brainstorm session Geoff opened after
B3c (glw907/drafter#55, glw907/cairn-cms#132) scored 0 of 8 against a bar of 3. He asked for a read
of the eight drafts, then for a fact-check of each against cairn's code. This record carries both,
and the acceptance design (`specs/2026-10-19-drafter-acceptance-design.md`) cites it.

Each draft is the `final.page.md` of its last run under `~/.local/state/drafter/runs/cairn-cms/`;
the run ids are in cairn-cms#132's table. The fact-checks ran as seven Opus agents at medium, one
per page, each reading the draft against cairn-cms `main` at `b1c2bccbb` and reporting only what it
could show with a file and line. Rotate was not checked: its blueprint never accepted, and its
draft escalated on the page cap.

## The read

Seven of the eight drafts read as publishable developer docs in cairn's register. Every one of the
seven stopped on bookkeeping, not prose. Two corrections to the pilot's record. The drafts did not
shrink: the live pages are hard-wrapped at 100 columns and the drafts are not, so cairn-cms#132's
line counts mislead. By word count every draft is longer than its live page, by 2 to 20 percent,
except rotate at 80 percent. And where a draft drops something the live page had, the blueprint or
the facts store asked for it: scaffolded-site-files drops the second D1 database and `src/access.ts`
because the scaffold no longer ships them, and debug-your-site drops the CSRF row because its
blueprint says so.

| Page | Words, live to draft | What stopped it | The draft as a reader sees it |
|---|---|---|---|
| using-claude-code-with-cairn | new page, 2,689 | structure seat: two snippet blocks missing | Clean how-to. The fix agent could not quote the snippet files because no input carried them |
| debug-your-site | 3,461 to 3,526 | fact seat: three facts cite a dead anchor, one claim has no fact | Tighter than the live page, one row per event |
| restrict-admin-access | 3,353 to 4,054 | coverage seat: one link, one handoff | The link it wants is already on the page two sections up; the handoff is one sentence |
| scaffolded-site-files | 3,966 to 4,287 | cairn's provenance check, 8 hits | Every hit is a linked name in a no-claim sentence |
| security-model | 5,049 to 5,726 | coverage seat: one brief entry | The best of the eight |
| add-a-second-sign-in-group | 5,102 to 5,793 | cairn's gate red on a no-claim sentence | Complete across both paths |
| add-cairn-to-a-sveltekit-app | 7,536 to 8,650 | cairn's provenance check, 50 hits, "npm package" read as a command | Every milestone intact |
| rotate-the-github-app-key | 2,038 to 3,680 | blueprint never accepted, page cap | Sprawling: "Before you begin" branches four ways before any step, recovery runs 14 cases |

Where the endings came from: cairn's gate, four pages (cairn backlog #14, #15), and it also drained
the two fix rounds on add-a-second-sign-in-group before its review seats ran; seat strictness, two
pages (a missing link, a missing handoff, a brief entry, each escalated by the "second fix verdict"
rule with no weight on the finding's kind); a missing input, one page (the snippet files the
blueprint names never reached the draft seat); blueprint content, one page (rotate).

## The fact-check

| Page | Claims checked | Wrong | Imprecise | Unverified |
|---|---|---|---|---|
| using-claude-code-with-cairn | 31 | 0 | 3 | 0 |
| debug-your-site | 62 | 1 | 3 | 4 |
| restrict-admin-access | 72 | 1 | 2 | 1 |
| scaffolded-site-files | 95 | 4 | 4 | 4 |
| security-model | 112 | 0 | 4 | 5 |
| add-a-second-sign-in-group | 46 | 0 | 3 | 3 |
| add-cairn-to-a-sveltekit-app | 96 | 0 | 5 | 13 |
| Total | 514 | 6 | 24 | 30 |

Every agent answered yes to "would a careful cairn maintainer merge this page after fixing the
listed errors". Every code sample on add-a-second-sign-in-group and add-cairn matches the engine's
exports, import paths, and types; the SvelteKit 3 claims were checked against an installed
`@sveltejs/kit` 3.0.1. "Unverified" is a claim the agent could not locate in the repo, mostly
platform behavior (SvelteKit, Wrangler, GitHub, Cloudflare), never a contradiction.

### Where the six wrong claims came from

Each was traced to its source. None was invented by the drafting seat.

| Page | Claim | Source |
|---|---|---|
| scaffolded-site-files | the scaffold ships `.dev.vars.example` | fact `f:qlgggh`, copied from the stale live page; the file exists only in the Deploy-button overlay `packages/create-cairn-site/template-repo/` |
| scaffolded-site-files | the scaffold ships `LICENSE` | the same fact, same overlay |
| scaffolded-site-files | `.gitignore` re-includes `.dev.vars.example` | the live page; the showcase's `.gitignore` has no negation, and line 7 ignores `.dev.vars.*` |
| scaffolded-site-files | a "separate `--connect` run" connects Workers Builds | the blueprint's own wording, citing `f:qca0t0`; chapter 3 runs in the same setup run (`packages/create-cairn-site/bin.mjs:260-268`), and `--connect` only re-enters it |
| debug-your-site | `admin.action.session_absent` records a session that lapsed after the guard resolved it | the blueprint's lapse row, citing `f:v1jj2k`, which paraphrases the doc comment at `src/lib/sveltekit/admin-action.ts:155-156`; the guard redirects a lapsed session with no record (`guard.ts:363-365`), so the event fires only on a route no hook resolved an editor for |
| restrict-admin-access | an exhaustive map leaves the tidy and dictionary actions outside it | fact `f:cvv6to` lists them as "exceptions"; the draft and the live security-model page both read that as "outside the map", while `f:arr13a` and the code (`content-routes-tidy.ts:120-128`) gate them against the concept key |

### The findings, page by page

Each entry gives the draft line, the claim, the code, and the fix. These are the acceptance pass's
fact and blueprint edits.

**using-claude-code-with-cairn.** All imprecise.

1. Line 172, the Tailwind line: the check also accepts a `.gitignore` entry that ignores `.claude`
   (`src/lib/guidance/check.ts:82`, checked first), reads only `src/admin.css` then
   `src/theme/admin.css` (`check.ts:29`), and matches `source(none)` anywhere in the file
   (`check.ts:89`). Fact `f:1kwkl0` names only the two forms the draft names.
2. Line 195, the install refusal cases: the list is incomplete. The install also refuses a path
   component that is a regular file (`install.ts:304`), a `.orig` copy it cannot make
   (`install.ts:427`, `:442`), and a symlinked MANIFEST (`install.ts:416-419`, a refusal that exits
   0). The blueprint's item lists the three cases the draft lists.
3. Line 135, "`cairn-guidance check` exits 0 by default": `bin.ts:57` exits 2 on a bad flag or
   unknown command, and an uncaught read error exits nonzero. Fact `f:4ax489` says "exits 0 by
   default". A qualifier such as "exits 0 whatever the report says" fixes it.

**debug-your-site.**

1. Wrong, lines 90 and 92: the `session_absent` lapse scenario, traced above. Only the "route
   outside `/admin`" paragraph is right, and it should also name public admin paths
   (`isPublicAdminPath`, `guard.ts:298`, `:360`). The engine's doc comment is the source and is worth
   fixing too.
2. Lines 77-79, `createSectionAction` step 1 leaves out the CSRF check inside `createAdminAction`,
   which logs `admin.action.csrf_refused` and throws `error(403)` (`admin-action.ts:218-240`).
3. Line 121, the access-rule check: the `reason` field is `no_rule`, `shadowed`, or `role`
   (`src/lib/log/events.ts:103-109`); the draft never names `shadowed`.
4. Line 128, `admin.action.unaudited`: a handler that returns `fail()` is exempt
   (`admin-action.ts:317-321`), and the stated rationale is "should not 500 a live site"
   (`:172-173`), not redirects.

**restrict-admin-access.**

1. Wrong, line 208: tidy and dictionary, traced above. `publishAllAction` stays as described
   (`content-routes-entry-write.ts:440-448`). The live security-model page, lines 312-314, carries
   the same error.
2. Line 139, the inline image picker: only the upload path is gated
   (`content-routes-media-ingest.ts:120-127`); reusing an existing image makes no request
   (`MediaInsertPopover.svelte:60-63`), so a role shut out of `media` can still insert a library
   image.
3. Line 146 and line 88: the screen-key and route-key checks run in `validateAccessComposition`
   from `createContentRoutesContext` (`content-routes-context.ts:349-351`), not in `composeRuntime`,
   which checks only role names (`compose.ts:46`). Same effect at server start.

**scaffolded-site-files.** The setup command's template is built at pack time by
`bakeForPacking()` in `packages/create-cairn-site/scripts/bake-template.mjs` and never applies the
`template-repo/` overlay; only `scripts/emit-template-dir.mjs` does, for the Deploy-button tree.

1. Wrong, lines 79 and 106-108: `.dev.vars.example`, traced above. The emitter skips every
   `.dev.vars.*` file (`emit-template.mjs:139-142`).
2. Wrong, lines 85 and 120: `LICENSE`, traced above.
3. Wrong, line 116: the `.gitignore` negation, traced above.
4. Line 116: the scaffold's `.gitignore` ignores the whole `/.cairn/` directory
   (`examples/showcase/.gitignore:5`), not one file.
5. Wrong, lines 7 and 309: "separate `--connect` run", traced above.
6. Line 158: `wrangler.jsonc` declares four bindings, `ASSETS` included (`wrangler.jsonc:10`).
7. Line 250: the adapter also passes `media` (`examples/showcase/src/theme/cairn.config.ts:189`),
   and the `editor` group also carries `nav` and `preview` (`:212` on).
8. Line 257: `site.config.yaml` also holds `spellcheck` and `tidy`, and ships `tidy.enabled: true`
   (`site.config.yaml:31-34`), which bears on line 108's "only when tidy is enabled".
9. Line 33: the exclusion list is incomplete. `examples/showcase/.cairn-template.json` also excludes
   `admin/signups` and `migrations-app/`, `admin/error-fixture`, `src/lib/env-check.ts`,
   `src/routes/(site)/+layout.server.ts`, `migrations-members/`, and 13 of the 27 posts.

**security-model.** All imprecise; 1 and 2 are in the live page word for word.

1. Line 103: the guard does clone the body on the field path
   (`csrf.ts:183`, `event.request.clone().formData()`); only the header path decides without a
   clone (`guard.ts:290-293`).
2. Line 230: a `build()` cannot emit raw markup (it returns a hast `Element`, `registry.ts:66`;
   stringify sets no `allowDangerousHtml`, `pipeline.ts:152`), and the sink guard runs over its
   output (`pipeline.ts:131-134`). Line 222 says this correctly, so line 230 contradicts the page.
3. Lines 197-207: the site's `remarkPlugins` run in the markdown stage, before the floor
   (`pipeline.ts:97-107`, `:148`); only its `rehypePlugins` run ninth (`:140`). The list does not
   separate them.
4. Line 139: the dev-backend 503 is a bare `Response` with none of the headers (`guard.ts:208-210`)
   and runs on every path, not only `/admin`.

**add-a-second-sign-in-group.** All imprecise.

1. Lines 169 and 600: on this engine `createAuthGuard` with no runtime throws at construction
   (`guard.ts:182-183`); the "falls back to owner and editor" wording is the doctor's fail text
   (`tool/internal/doctor/check_roles.go:29`) describing an older engine.
2. Line 58: `devBackendHandle` reads only `runtime.access`, never `runtime.roles`
   (`packages/cairn-cms-dev/src/handle.ts:72-80`); line 190 says so correctly.
3. Line 614: `createChannelDb` works from Node 22.13 (`channel-db.ts:38-42`); the `>=24` floor is
   the package's `engines` field.

**add-cairn-to-a-sveltekit-app.** All imprecise.

1. Line 927: a missing `AUTH_DB` does not throw; the guard logs `guard.refused` and returns the
   branded 500 directly (`guard.ts` after the https check; `condition-response.ts`). `requireDb`
   (`src/lib/env.ts`) is what throws `config.bindings-missing`.
2. Line 472: `npx cairn-manifest` also writes `site-facts.json` (`vite/bin.ts`,
   `DEFAULT_SITE_FACTS_PATH` at `vite/internal.ts:60`), and a stale one stops the build, a fourth
   failure line 570's "three ways" leaves out.
3. Line 1040: a separate D1 binding for `0002_audit.sql` is a recommendation
   (`docs/reference/sveltekit.md:659-668`), not a requirement.
4. Lines 1153 and 631: `editor.bootstrapped` logs when the bootstrap email submits the request form
   (`auth-routes.ts:204-206`), before any link is opened.
5. Line 740: a build with `VITE_CAIRN_E2E=1` also defines the flag `true` (`vite/internal.ts`,
   the `config` hook).

## What the evidence settles

- The drafting seat is faithful. Across 514 checked claims it invented none; every wrong claim
  entered through a fact bullet, a blueprint sentence, a stale live page, or a misleading code
  comment. The `blueprint` skill's fact-writing step is where truth leaks, and `drafter check`
  cannot catch it because it verifies that a source pointer resolves, not what the fact says.
- The acceptance machinery, not the drafts, produced the zero. The gate's two false-positive
  patterns, the "second fix verdict" rule's blindness to a finding's kind, and the missing snippet
  input account for seven of eight endings.
- Three of the seven would have accepted with a one-line fix each, on the pilot's bar of three.
