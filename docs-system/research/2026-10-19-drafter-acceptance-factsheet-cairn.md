# Factsheet: cairn docs-gate fixes and the 31 fact-check findings

Repo `/var/home/glw907/Projects/cairn-cms`, `main` at `517158fae`, clean. Read-only throughout; no
live API command run. `git diff --quiet b1c2bccbb HEAD -- src/lib` holds: `src/lib` is byte-identical
to the fact-check checkout, so every code-line mismatch below is in the record's own citation, not
drift. Shorthand: `R` = `/var/home/glw907/Projects/initiatives/docs-system/research/2026-10-19-drafter-b3c-draft-review.md`.

Finding count: "The findings, page by page" (R:74-177) holds **31** entries: using 3, debug 4,
restrict 3, scaffolded 9, security 4, second 3, add-cairn 5. Of these, 6 are marked Wrong and 25
Imprecise. The table (R:44-53) says 30 (6 wrong + 24 imprecise). The gap is scaffolded-site-files:
the table gives it 4 imprecise (R:49), and the list has 5 (R:128 #4, R:131 #6, R:132 #7, R:134 #8,
R:136 #9).

Side observations made while reading:
- The main checkout has no `node_modules`, so `node scripts/checks/check-facts.mjs` dies there
  with `Cannot find module 'typescript'` (check-facts.mjs:402). Run the gates in a worktree after
  the cairn-pass setup.
- Worktrees present: `b3c-pilot-pages` (7187a5517, merged into main), `blueprint-pilot`,
  `docs-layout`, `repo-organization`, plus `/var/home/glw907/.claude/jobs/38d6acde/tmp/cairn-wt`
  [drafter-require-prompts]. The newest drafter run, `20261020T023009Z-7a23e89e`
  (scaffolded-site-files, status `escalated`), left a `run.lock`. The lock's pid 1881500 is dead.

---

## 1. #14 `scripts/checks/check-provenance.mjs`

**How it finds claims.** It runs a deterministic regex extractor over each brief sentence
(`extractFacts`, :243). A no-claim sentence fails on any extracted fact:

```
:543  const extracted = withoutLocal(extractFacts(text, index.keyPhrases), local);
:544  if (id === NO_CLAIM) {
:545    for (const fact of extracted) defects.push(`${label}: marked ${NO_CLAIM} but states the ${fact.kind} "${fact.value}"`);
```

The header states the rule: "a no-claim sentence cites nothing, so any extractable fact in it
fails" (:55).

**Why a linked name or file in a no-claim sentence is flagged.** Only the link *target* is
stripped. The link text, with its code span, stays:

```
:144  const LINK_TARGET_RE = /\]\([^)]*\)/g;
:244  const withoutLinks = text.replace(DETAILS_TAG_RE, ' ').replace(IMAGE_RE, ' ').replace(LINK_TARGET_RE, ']');
:247  for (const m of withoutLinks.matchAll(CODE_SPAN_RE)) found.push(...codeSpanFacts(m[1]));
```

The comment says so too: "markdown link targets (navigation, not a claim; the link text is still
checked)" (:83). Inside `codeSpanFacts`:

```
:227  if (!/\s/.test(content) && (content.includes('/') || PATH_EXTENSION_RE.test(content) || /^\.\w/.test(content))) {
:228    return [{ kind: 'path', value: content }];          // `cairn-audit.config.json`
:230  const bare = content.replace(/\(\)$/, '');
:231  if (NAME_RE.test(bare)) return [{ kind: 'name', value: bare }];   // `createAuthGuard`
```

The only escape is a `local` entry (`withoutLocal`, :294-296), and that covers site-invented names
only. An engine export is a defect there (:430 `checkLocal`).

**Why "npm package" reads as a command.** This is the prose-command regex, applied to text outside
code spans:

```
:151  const PROSE_COMMAND_RE = /(?<![\w-])(?:npm|npx|pnpm|yarn)\s+(?:run\s+)?[a-z][\w:@-]*/g;
:267  take(PROSE_COMMAND_RE, 'command', (t) => t.replace(/\s+/g, ' '));
```

Any `npm <lowercase word>` matches. I confirmed it with the extractor's read-only mode
(`node scripts/checks/check-provenance.mjs --extract <file>`, header :23-26):

```
1  command  npm package          <- "Install the npm package first."
2  name     createAuthGuard      <- "See [`createAuthGuard`](../reference/x.md)."
3  path     cairn-audit.config.json
4  path     #lib/cairn.config.js <- provenance keeps the `#`
```

**Tests.** `src/tests/unit/check-provenance.test.ts`. The suites are `extractFacts` (:31),
`checkSentences, one failure mode per case` (:82), `--extract` (:511), and others. Vitest project
`unit` (vitest.config include `src/tests/unit/**/*.test.ts`) runs them through `npm run test:unit`
(package.json:89, `vitest run --project unit`). The fast lane runs
`npx vitest related --run --passWithNoTests --project unit <paths>`.

## 2. #15 `scripts/checks/check-symbols.mjs`

`#lib/cairn.config.js` becomes `lib/cairn.config.js` because the path tokenizer's character class
has no `#`, so the match starts after it:

```
:314  const pattern = /[\w./@-]+/g;
:319  const token = m[0].replace(/^(?:\.{0,2}\/)+|[./]+$/g, '');
:320  if (!token.includes('/')) continue;
```

It is resolved by `pathExists` (:610-617) against the repo root, `templates/waymark/`, and the
package prefixes. It never checks an import map:

```
:611  if (existsSync(join(root, path))) return true;
:612  if (existsSync(join(root, 'templates/waymark', path))) return true;
```

Neither `lib/cairn.config.js` nor `templates/waymark/lib/...` exists, so it fails. I probed this
read-only: `extractFilePaths(codeVoiceSegments('Prose naming `#lib/cairn.config.js` here.'))` ->
`[{"line":3,"token":"lib/cairn.config.js"}]`, and `pathExists('lib/cairn.config.js')` -> `false`.

**`"imports"` map.** The root `package.json` has no `"imports"`. The map lives in the site
packages:
- `examples/showcase/package.json:5-9`: `"#chassis/*": "./src/chassis/*"`, `"#lib/*": "./src/lib/*"`, `"#theme/*": "./src/theme/*"`.
- `templates/waymark/package.json:7`: `"#lib/*": "./src/lib/*"`.

So `#lib/cairn.config.js` maps to `./src/lib/cairn.config.js`. Neither tree has that file today:
`examples/showcase/src/lib/` holds `env-check.ts` and `log.ts`, and `templates/waymark/src/lib/`
holds `log.ts`. The file is the add-cairn tutorial's own site file. The `.ts` file is reached by a
`.js` specifier.

**Tests.** `src/tests/unit/check-symbols.test.ts`: `pathExists` (:328), `extractFilePaths` (:342),
`findUnresolvedSymbols` (:613). Same `unit` project and npm script as above.

## 3. #20 `check-leaks` `SCAN_ROOTS`

```
scripts/checks/check-leaks.mjs:478-500
export const SCAN_ROOTS = [
  'README.md', 'CHANGELOG.md', 'docs/README.md', 'docs/why-cairn.md',
  'docs/extend', 'docs/reference', 'docs/admin', 'docs/editors',
  'docs/internal/briefs', 'docs/internal/outlines', 'docs/internal/facts',
  'docs/internal/docs-register.md',
  'skills', 'claude', 'migrations', 'migrations-channel',
  'examples/showcase/README.md', 'examples/showcase/src/chassis', 'src/lib',
  'tool/cmd/cairn/messages.go',
  ...TEMPLATE_ROOTS,
];
```

**Adding `'blueprints'` alone flags nothing.** `runLeakCheck` skips any file whose `profileFor`
returns null (:521-522 `const profile = profileFor(rel); if (!profile) continue;`), and `profileFor`
(:174-216) has no `blueprints/` branch. The fix needs a `profileFor` tier as well. I confirmed this
with a read-only node script that imports `profileFor`/`scanText` and reads the 10 tracked
`blueprints/` files:

- `profileFor` today: 0 of 10 files mapped.
- As T3 (`C1,C2,C4`, the briefs/outlines/facts tier, :190-195): **0 findings**.
- As T1/T2 (all classes): **1,346 errors**. 1,340 are C3 "a fact id" (`/\bf:[a-z0-9]{6}\b/`, :105,
  PUBLIC_TIERS; every citation trips it). The rest are 4 C3 "a maintainer ruling" at
  `scaffolded-site-files.blueprint.yaml:1239,1246,1272,1450` ("owner ruling"), 1 C1 "the
  maintainer's name" at `blueprints/outline.yaml:225` ("Geoff"), and 1 C3 "a dated attribution" at
  `blueprints/outline.yaml:225` ("Geoff 2026-09-24").

**Test that pins the roots.** `src/tests/unit/check-leaks.test.ts:95-119` ("maps every tracked file
under a package.json "files" root to a scanned tier and a scan root") walks package.json `files`
only. `blueprints/` is not in `files`, so the test does not force it.

## 4. #16 the three facts and where `wrap` lives

```
docs/internal/facts/extend.md:402
- `f:i1dayf` `admin.action.rate_limit_absent` and `admin.action.rate_limit_failed` (both warn) both degrade to open (never block) on purpose: the former fires when the configured rate-limit binding resolves to nothing; the latter when the site's `key()` call or the resolved limiter's own `limit()` call throws (carries the `error` field). Source: `src/lib/sveltekit/section-action.ts#createSectionAction.wrap` (`admin.action.rate_limit_absent` logged when `!limiter`; `admin.action.rate_limit_failed` logged in the `key()`-throw and `limit()`-throw catch blocks). [verified]

docs/internal/facts/extend.md:403
- `f:nup3og` `admin.action.misconfigured` (error) fires with `reason: 'db_not_bound'` when `config.resolveDb` returns null/undefined, or `reason: 'access_map_not_attached'` when `event.locals.cairnAccess` was never set (a hook set `locals.cairnEditor` without `locals.cairnAccess`; the engine guard always sets both). Source: `src/lib/sveltekit/section-action.ts#createSectionAction.wrap` (`misconfigured('rejected: access map not attached', 'access_map_not_attached')`, `misconfigured('rejected: database not bound', 'db_not_bound')`). [verified]

docs/internal/facts/extend.md:396
- `f:gy2h7p` The developer-facing log events (...) fire from engine code running inside a site's own extension points (...). Source: `src/lib/content/fieldset.ts#defineFieldset` (`content.field_behavior_failed`), `src/lib/delivery/public-routes.ts:47,210` (`media.resolver_absent`), `src/lib/sveltekit/admin-action.ts#createAdminAction` (`admin.action.unaudited`), `src/lib/sveltekit/section-action.ts#createSectionAction.wrap` (rate-limit events), `src/lib/log/events.ts#CairnLogEvent` (`config.invalid`); ... [verified: a summary of the individually verified events]
```

**Where the logic lives.** `wrap` is a named function expression *returned* by
`createSectionAction`. It is not a top-level declaration:

```
src/lib/sveltekit/section-action.ts:179  export function createSectionAction<Env, Db>(config: SectionActionConfig<Env, Db>): SectionAction<Env, Db> {
src/lib/sveltekit/section-action.ts:180    return function wrap<T>(
```

- `misconfigured` helper: :221-225 (`log.error('admin.action.misconfigured', { path, reason })` at :223).
- Rate-limit block: :227-282 (`rate_limit_absent` :230; `rate_limit_failed` :245 and :262; `rate_limited`/`fail(429)` :269-277).
- `access_map_not_attached`: :286-289. `db_not_bound`: :303-304.

**Why the excerpt reads "declaration not found."** drafter's resolver takes only the name after the
last dot, then matches a line-start declaration
(`/var/home/glw907/Projects/drafter/internal/assemble/excerpt.go:86-92`: `name =
name[strings.LastIndex(name, ".")+1:]`, then `declaration(...)`; the TS regex at :127-128 is anchored
`^(export\s+...)?(function|class|...|const|let)\s+<name>\b`). The line `  return function wrap<T>(`
is indented, so nothing matches. cairn's own `check:facts` resolves the same pointer through the
TypeScript AST, walking each dotted segment (`scripts/checks/check-facts.mjs:479-499`
`resolveSymbolDeclaration`), so the pointer passes there.

**Re-anchor targets that drafter resolves.**
- `src/lib/sveltekit/section-action.ts#createSectionAction` resolves to line 179. drafter's window is
  5 before and 40 after (excerpt.go:20, `declBefore, declAfter = 5, 40`), so lines 174-219. That
  stops before both the rate-limit block and the misconfigured calls.
- Line ranges cover the cited code: `section-action.ts:221-282` (misconfigured helper plus the rate
  limit) and `:286-289,303-304` (the two misconfigured reasons). A span takes ±5 lines
  (excerpt.go:19).

**Scope.** I reproduced drafter's rule over every `path#A.B` pointer in `docs/internal/facts/*.md`.
**158** dotted anchors fail it. Among them are facts the seven cite: `f:ubuj1w`, `f:keuj8l`,
`f:t976f1` (`guard.ts#createAuthGuard.handle`), `f:cvv6to`
(`content-routes-media-ingest.ts#createMediaIngestActions.ingestAndStore`), `f:21by9u`
(`sanitize-schema.ts#isSafeSrcset.candidates`), and `f:147zhc` (`createSectionAction.wrap`). Only
debug's three were reported as blocking in R:28.

## 5. Findings to sources

`R` lines are the record. "Code OK" means the record's code line matches main. Fact lines are
`docs/internal/facts/<file>:<line>`. Blueprint items are `<page>.blueprint.yaml:<range> <id>`.

### using-claude-code-with-cairn (blueprint `blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml`)

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | Imprecise | fact + blueprint | `f:1kwkl0` reference.md:1163; item `f-verify-tailwind` :532-538 ("Only two clauses: ... `source(none)` ... beside the literal `@source not "./.claude";`") | check.ts:82 (.gitignore first), :29, :89 | OK (:81-83 gitignore, :29 `SOURCE_CSS_CANDIDATES`, :88-89 `SOURCE_NONE`) |
| 2 | Imprecise | blueprint (+ fact) | item `x-refused` :590-598 (cause lists symlink, symlinked `.claude`, existing directory); `f-diag-refused` :599-604 using `f:vhxkab` reference.md:1154 | install.ts:304; :427, :442; :416-419 (symlinked MANIFEST) | **:304 is off by one**: the regular-file component check is :303 (`if (isLast ? !stats.isFile() : !stats.isDirectory()) return null;`). :427 and :442 are OK (`report.refused.push(origRelPath)`). **:416-419 is wrong**: those lines are `preserveOriginal`'s signature. The MANIFEST refusal is :399-402 (`if (manifestAbs === null) { report.refused.push(MANIFEST_DEST); return report; }`), resolved at :361 |
| 3 | Imprecise | fact + blueprint | `f:4ax489` extend.md:923 ("exits 0 by default"); items `f-ci-exit` :456-461, `f-verify-lines` :521-526 | bin.ts:57 | OK (`process.exitCode = 2;`) |

### debug-your-site (`blueprints/docs/extend/debug-your-site.blueprint.yaml`)

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | **Wrong** | fact + blueprint + engine comment | `f:v1jj2k` reference.md:1304-1309; section `admin-action-session-absent` :391-457: `opens` :397-400, `f-session-absent` :402-408, `x-session-absent` :409-416 (cause "lapsed after the guard resolved it"), `s-session-absent-fix` :417-426, `x-session-every-submit` :427-435 (route-outside-/admin cause; add public admin paths); disposition :1233. Doc comment admin-action.ts:155-156 (Q12) | guard.ts:363-365; `isPublicAdminPath` guard.ts:298, :360 | :363-365 OK (`if (!editor) throw redirect(303, '/admin/login');` at :365). **298/360 are off by one**: `isPublicAdminPath` calls are at :297 and :359 (definition :33). The fact's own source `admin-action.ts:146-153,207-211` is stale: `session_absent` is at :214-216 |
| 2 | Imprecise | fact + blueprint | `f:1b3ye3` reference.md:1729- (step "(1) `createAdminAction`'s own authentication"); item `f-check-order` :371-383 | admin-action.ts:218-240 | **Approximate**: the form read is :221, the CSRF verdict :228-231, `log.warn('admin.action.csrf_refused'` :239, `throw error(403, ...)` :245, so the span is 221-245 |
| 3 | Imprecise | blueprint | item `x-refused` :609-617 (cause omits `shadowed`); `f-refused-steps` :618-623 (`f:1b3ye3` steps 4-5). The correct fact exists unplaced: `f:147zhc` extend.md:643 (`drafter refs`: no blueprint cites it) | events.ts:103-109 | OK (`AccessRefusedReason = 'no_rule' \| 'shadowed' \| 'role'`, doc :103-108, type :109) |
| 4 | Imprecise | fact + blueprint | `f:07efts` extend.md:400 (rationale "a redirect or error response mid-request would be worse"); items `r-unaudited` :657-661 (same rationale), `opens` :641-644 and `x-unaudited` :646-653 (no `fail()` exemption) | admin-action.ts:317-321; :172-173 | OK (`if (emitted === 0 && !isActionFailure(result))` :318, `log.error` :320; ":172-173" reads "should not 500 a live site") |

### restrict-admin-access (`blueprints/docs/extend/restrict-admin-access.blueprint.yaml`)

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | **Wrong** | fact + blueprint | `f:cvv6to` extend.md:741 ("Every engine write action gates through the access map except ... `f:arr13a` (the tidy and dictionary actions ...)"); items `exh-exceptions` :556-561 ("Only the actions an exhaustive map still leaves outside it"), `map-writes` :369-374. `f:arr13a` extend.md:743 is correct | content-routes-tidy.ts:120-128; entry-write.ts:440-448 | OK (`if (!conceptId) throw error(404, 'Not found');` :127, `requireEngineAccess(...)` :128; `publishAllAction` :448, `canReach` filter :462) |
| 2 | Imprecise | fact + blueprint | `f:iewhzh` extend.md:637 ("also restricts the inline image picker"); item `map-media-trap` :363-368 | content-routes-media-ingest.ts:120-127; MediaInsertPopover.svelte:60-63 | OK (comment :121-123, `canReach(... 'media')` :124; popover "direct-insert path ... (no upload)" :61-62) |
| 3 | Imprecise | fact + blueprint | `f:3z48zf` extend.md:647 ("Composition then throws ..."); items `map-validation` :378-382, `x-map-throw` :392-399 ("The server start throws ..."). Draft line 88 comes from `map-where` :280-286 (`f:iwf4nu` extend.md:633, "`composeRuntime` carries it"), which is true as stated | content-routes-context.ts:349-351; compose.ts:46 | OK (`validateAccessComposition(...)` :350; compose.ts:46 `validateAccessRoles` only). The fact's own pointer `admin-nav.ts:300-321` fits; the function is at :304 |

### scaffolded-site-files (`blueprints/docs/extend/scaffolded-site-files.blueprint.yaml`)

Context: `templates/waymark/` (the Deploy-button tree, which carries the `template-repo/` overlay)
holds `.dev.vars.example`, `LICENSE`, and a `.gitignore` with `!.dev.vars.example` at :14.
`examples/showcase/` is what `bakeForPacking()` ships (bake-template.mjs:366); `OVERLAY_DIR` is
emit-template-dir.mjs:29. The scaffold facts cite `templates/waymark/`.

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | **Wrong** | fact + blueprint | `f:qlgggh` extend.md:867; `f:nls26c` extend.md:929 (source `templates/waymark/.dev.vars.example:1-11`); section `dev-vars-example` :373-391 (`devvars-contents` :383-388); `root-two-entries` :335-341; `tree-root-entries` :308-314; disposition :1412-1413 | emit-template.mjs:139-142 | **Wrong lines**: :136-144 is `regenerateManifest`'s doc. The skip is `isAlwaysSkippedPath` at scripts/build/emit-template.mjs:115-118 (`base === '.dev.vars' \|\| base.startsWith('.dev.vars.')` :117) |
| 2 | **Wrong** | fact + blueprint | `f:qlgggh` extend.md:867 (lists `LICENSE`); item `other-plain` :445-450 | (traced to the overlay) | `templates/waymark/LICENSE` and `packages/create-cairn-site/template-repo/LICENSE` exist; the showcase has none |
| 3 | **Wrong** | fact + blueprint | `f:nls26c` extend.md:929 ("while `.gitignore` re-includes `.dev.vars.example`", source `templates/waymark/.gitignore:6-7,14`); item `gitignore-devvars` :426-430 | showcase .gitignore:7 | OK (examples/showcase/.gitignore:7 `.dev.vars.*`, no negation; the negation is only templates/waymark/.gitignore:14) |
| 4 | Imprecise | fact + blueprint | `f:666eg6` extend.md:927 ("gitignored `.cairn/admin.css`", source `templates/waymark/.gitignore:5`); item `gitignore-admin-css` :431-435 | examples/showcase/.gitignore:5 | OK (`/.cairn/`) |
| 5 | **Wrong** | blueprint (+ fact) | "separate `--connect` invocation": `scaffold-same-run` :238-244 (:243-244), `setup-state-outside-the-tree` opens :1142-1144, framing :95, :172; fact `f:qca0t0` admin.md:157 (true, but silent on the same-run chapter 3) | bin.mjs:260-268 | OK (`await runChapter3AndReport(...)` :266 inside `continueIntoChapter2`) |
| 6 | Imprecise | fact + blueprint | `f:n7t4bn` extend.md:839 (three bindings + var); section `wrangler-jsonc` opens :604-606 ("declares three bindings and one variable"), `wrangler-bindings` :608-613 | wrangler.jsonc:10 | OK (`"binding": "ASSETS"` :10, in both showcase and waymark) |
| 7 | Imprecise | fact + blueprint | `f:qnf469` extend.md:868 ("one `defineAdapter` call over `content`, `backend`, `email`, `rendering`, and an `editor` group carrying `navLayout`"); section `src-theme` opens :903-904, `theme-adapter` :906-910 | cairn.config.ts:189, :212 on | OK (`media,` :189; `editor: {` :211, `nav:` :212) |
| 8 | Imprecise | fact + blueprint | `f:qnf469` extend.md:868 ("`site.config.yaml` (`siteName`, `description`, primary and footer menus, and the tag `vocabulary`)"); item `theme-files` :938-944; `f:nls26c` extend.md:929 ("read only when tidy is enabled") via `devvars-contents` :383-388 | site.config.yaml:31-34 | OK (`spellcheck:` :31, `tidy:` :33, `enabled: true` :34) |
| 9 | Imprecise | fact + blueprint | `f:n2skkz` extend.md:834 (source `examples/showcase/.cairn-template.json:1-19`); item `scaffold-source` :227-231 | .cairn-template.json | OK (the exclude list is :2-34: signups :6, error-fixture :7, migrations-app :8, `(site)/+layout.server.ts` :9, env-check :11, migrations-members :13, and 13 posts at :21-33 of 27 in `src/content/posts`). The fact's cited `:1-19` stops short of the posts |

### security-model (`blueprints/docs/extend/security-model.blueprint.yaml`)

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | Imprecise | fact + blueprint | `f:keuj8l` extend.md:736 ("since the guard does not clone its body"); item `cs-token` :476-482 | csrf.ts:183; guard.ts:290-293 | **Wrong lines**: `event.request.clone().formData()` is csrf.ts:176. The header-vs-field branch is guard.ts:275-278 (`headerSent` :275, `csrfHeaderVerdict` :277). guard.ts:290 is `witness:` inside the refusal log |
| 2 | Imprecise | fact + blueprint | `f:21by9u` extend.md:621 ("can still bypass all render-safety guarantees by rendering trusted literal markup"); item `rs-build-bypass` :900-904; also `rp-build` :1267 | registry.ts:66; pipeline.ts:152, :131-134 | OK (`build: (ctx: ComponentContext) => Element;` registry.ts:66; `.use(rehypeStringify)` :152; anchor-rel :131, sink guard :134) |
| 3 | Imprecise | fact + blueprint | `f:zzbzo8` extend.md:613 (nine stages ending "site's own plugins"); item `rs-stages` :832-836. The correct `f:xothz1` extend.md:623 is cited by no blueprint; `f:phx4lo` :622 is `[rejected]` | pipeline.ts:97-107, :148, :140 | OK (`remarkPlugins` :97-106, `.use(remarkPlugins)` :148, `rehypePlugins.push(...(options.rehypePlugins ?? []))` :140) |
| 4 | Imprecise | fact + blueprint | `f:ubuj1w` extend.md:717 (rejection pages carry the set less HSTS); `f:t976f1` extend.md:747; items `gd-headers` :570-575, `gd-hsts-why` :576-581 ("the guard applies the headers only on `/admin` paths") | guard.ts:208-210 | **Wrong lines**: :208-210 are comments. The 503 is guard.ts:213-216 (`if (!(await isBuilding()) && isDevBackendFlagSet(...))` :213, `return new Response(CAIRN_DEV_BACKEND_MESSAGE, { status: 503 });` :215), before the `isAdminPath` early return at :220 |

### add-a-second-sign-in-group (`blueprints/docs/extend/add-a-second-sign-in-group.blueprint.yaml`)

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | Imprecise | fact + blueprint | `f:hwffph` admin.md:140 ("the running guard falls back to the owner and editor pair"); items `vr-doctor` :798-805, `x-wiring` :1883-1891 (cause "resolves every session against the owner and editor pair"); `r-wiring` :1892- | guard.ts:182-183; check_roles.go:29 | OK (`const vocabulary = runtime.roles ?? DEFAULT_ROLES;` :183 on an undefined `runtime`; `tmplRoleWiringUnwired` :29) |
| 2 | Imprecise | fact + blueprint | `f:7cv105` extend.md:103 ("reads the access map (`access`) and the role vocabulary (`roles`) from it"); item `dr-dev` :500-507 | packages/cairn-cms-dev/src/handle.ts:72-80 | OK (doc: "Its `roles` resolves no capability here", :76-78) |
| 3 | Imprecise | blueprint | items `x-node` :1998-2006 ("on a Node release below 24"), `r-node` :2013-2017, `rs-node` :2007-2012, `bb-node` :325-331; fact `f:fcqs22` extend.md:79 is correct | channel-db.ts:38-42 | OK (packages/cairn-cms-dev/src/channel-db.ts:39-40 "unflagged since Node.js 22.13 ... `engines.node` (`>=24`)") |

### add-cairn-to-a-sveltekit-app (`blueprints/docs/extend/add-cairn-to-a-sveltekit-app.blueprint.yaml`)

| # | Kind | Source | Location | Record's code citation | Code on main |
|---|---|---|---|---|---|
| 1 | Imprecise | fact + blueprint | `f:ntdafg` extend.md:152 ("a missing `AUTH_DB` throws `config.bindings-missing`"); item `r-env` :1778-1785 | guard.ts after the https check; condition-response.ts; env.ts `requireDb` | OK (guard.ts:240-246 `if (!env.AUTH_DB) { ... return renderConditionResponse(REASON_CONDITION.bindings); }`; env.ts:75-77 `requireDb` throws) |
| 2 | Imprecise | blueprint | item `s-write-manifest` :830-839 (writes only `index.json`); section `resolve-a-content-build-failure` opens :985 ("three ways"), `f-modes` :987-993 (`f:n0laoh`). The correct fact exists unplaced: `f:yio35u` reference.md:1575 (`drafter refs`: none) | vite/bin.ts; vite/internal.ts:60 | OK (bin.ts:2-4 "then does the same for the site-facts contract"; `DEFAULT_SITE_FACTS_PATH` :60) |
| 3 | Imprecise | blueprint | item `db-audit` :2151-2156 ("Only the separate D1 binding ... for `0002_audit.sql`"); fact `f:pkrwom` extend.md:141 already says "recommended" | docs/reference/sveltekit.md:659-668 | OK (":659 A separate database ... keeps audit writes from contending") |
| 4 | Imprecise | fact + blueprint | `f:f2vudv` extend.md:281 ("creates the first real owner row automatically on first real sign-in, logged as `editor.bootstrapped`"); items `c-bootstrap` :1180-1186, `pv-bootstrap` :2332-2336 | auth-routes.ts:204-206 | OK (`insertOwnerIfEmpty` :205, `log.info('editor.bootstrapped'` :206, inside the request handler) |
| 5 | Imprecise | blueprint | item `d-define` :1330-1336 ("its value under `vite dev` and in a default build"); fact `f:xluud1` extend.md:842 already names `VITE_CAIRN_E2E=1` | vite/internal.ts config hook | OK (`VITE_CAIRN_E2E === '1'` :255; define :272) |

**Unlocated:** none. **Record lines that do not match main:** using #2 (install.ts:304,
:416-419), debug #1 (guard.ts:298, :360), debug #2 (admin-action.ts:218-240, approximate), scaffold
#1 (emit-template.mjs:139-142), security #1 (csrf.ts:183, guard.ts:290-293), and security #4
(guard.ts:208-210). Every other cited line matches. Stale fact source pointers seen on the way:
`f:v1jj2k` (admin-action.ts:146-153,207-211 -> :214-216) and `f:n2skkz` (`:1-19` -> :2-34).

## 6. Blueprints citing each touched fact (`drafter refs f:<id>`)

| Fact | Cited by (file:line item) |
|---|---|
| f:1kwkl0 | using:534 f-verify-tailwind; scaffolded:1286 dispositions |
| f:vhxkab | using:601 f-diag-refused |
| f:4ax489 | using:458 f-ci-exit, :494 r-ci-trade, :523 f-verify-lines, :670 x-ci-stale, :691 x-ci-other; scaffolded:1261 dispositions |
| f:v1jj2k | debug:404 f-session-absent, :424 s-session-absent-fix, :454 s-session-route-fix |
| f:1b3ye3 | debug:373 f-check-order, :486 f-rate-limit, :505 s-rate-absent-fix, :513 s-rate-failed-fix, :620 f-refused-steps, :630 s-refused-fix |
| f:147zhc | none (to place) |
| f:07efts | debug:656 f-unaudited, :668 s-unaudited-fix |
| f:i1dayf | debug:494 f-rate-events |
| f:nup3og | debug:529 f-misconfigured, :569 s-access-map-fix, :590 s-db-fix |
| f:gy2h7p | debug:44 introduction, :48 _framing-introPlan |
| f:cvv6to | restrict:371 map-writes, :558 exh-exceptions; **security:733 am-write-actions** |
| f:arr13a | security:768 am-tidy |
| f:iewhzh | restrict:365 map-media-trap |
| f:3z48zf | restrict:380 map-validation |
| f:iwf4nu | second:2243 disp; add-cairn:1492 d-access; debug:557 f-one-declaration, :569 s-access-map-fix; restrict:282 map-where; scaffolded:1331 disp; security:1456 disp |
| f:qlgggh | second:2316 disp; add-cairn:2873 disp; debug:1202 disp; restrict:1308 disp; scaffolded:39 _framing-readers, :310 tree-root-entries, :321 tree-claude-label, :337 root-two-entries, :447 other-plain; security:1487 disp |
| f:nls26c | **second:1211 wm-dev-vars**; **rotate:1359 dispositions**; scaffolded:385 devvars-contents, :428 gitignore-devvars |
| f:qca0t0 | **restrict:715 dep-paths, :720 dep-builds**; scaffolded:39, :54, :140 (framing) |
| f:666eg6 | scaffolded:292 tree-block, :433 gitignore-admin-css, :524 pkg-pre-scripts, :1033 styles-admin-compile |
| f:n7t4bn | restrict:1290 disp; scaffolded:54, :140 (framing), :292 tree-block, :610 wrangler-bindings |
| f:qnf469 | scaffolded:54, :140 (framing), :908 theme-adapter, :940 theme-files |
| f:n2skkz | scaffolded:54, :140 (framing), :229 scaffold-source |
| f:kldwss (context for #5) | add-cairn:43 intro; **rotate:43 intro, :59, :129, :205 (framing), :360 bb-scaffold-claim**; scaffolded:39, :54, :140, :240 scaffold-same-run |
| f:keuj8l | security:478 cs-token, :1197 rp-guard |
| f:21by9u | security:902 rs-build-bypass, :1267 rp-build |
| f:zzbzo8 | security:834 rs-stages |
| f:xothz1 | none |
| f:ubuj1w | security:462 cs-referrer, :472 cs-referrer-why, :572 gd-headers |
| f:t976f1 | security:578 gd-hsts-why |
| f:hwffph | second:800 vr-doctor; add-cairn:2842 disp; debug:1217 disp; restrict:1244 disp; scaffolded:1378 disp; security:1450 disp |
| f:7cv105 | second:502 dr-dev, :923 vr-deployed; add-cairn:1436 d-runtime-dev; debug:1175 disp; restrict:167 bb-dev-reason, :172 bb-dev-roles, :295 map-dev-reads; scaffolded:1343 disp; security:1433 disp |
| f:fcqs22 | second:327 bb-node, :352 bb-list, :1643 tn-node, :2009 rs-node |
| f:ntdafg | add-cairn:43 intro, :1780 r-env, :2187 em-origin, :2437 pf-origin-fix |
| f:f2vudv | add-cairn:1182 c-bootstrap, :2334 pv-bootstrap |
| f:pkrwom | add-cairn:2153 db-audit |
| f:xluud1 | add-cairn:43 intro, :774 x-verify, :1332 d-define, :1567 v-checks; scaffolded:292 tree-block, :588 vite-manifest-define |
| f:n0laoh | add-cairn:989 f-modes, :1025 f-drift-fix, :1038 f-zero, :1046 f-zero-fix, :2722 sum-text |
| f:yio35u | none (to place) |

Abbreviations: using = `claude-code/using-claude-code-with-cairn`, the rest are under `extend/`, and
disp = dispositions. Cross-page hits are in bold. rotate cites `f:nls26c` and `f:kldwss`, and no
other touched fact.

## 7. `blueprints/drafted.lock`

| Page | `accepted` | `git rev-parse HEAD:<blueprint>` | Match | page / blueprint / sections | blocked |
|---|---|---|---|---|---|
| using-claude-code-with-cairn (:4-5) | f8047ba0… | f8047ba0… | yes | none (accepted only) | none |
| debug-your-site (:68-) | a2cc75f3… | a2cc75f3… | yes | page be3ce83e (= HEAD docs blob), blueprint ad3be2d6, 22 sections | none |
| restrict-admin-access (:95-) | 7bc844b8… | 7bc844b8… | yes | page 1d4a936b (= HEAD), blueprint 68d14d75, 14 sections | none |
| scaffolded-site-files (:136-) | e666c973… | e666c973… | yes | page e719abcd (= HEAD), blueprint 866835f4, 29 sections | none |
| security-model (:170-) | df3d6338… | df3d6338… | yes | page ea4bd221 (= HEAD), blueprint f10cff21, 29 sections | none |
| add-a-second-sign-in-group (:6-) | ad021194… | ad021194… | yes | page 16ad2daf (= HEAD), blueprint e61f10b2, 20 sections | none |
| add-cairn-to-a-sveltekit-app (:31-) | 7b6c8f45… | 7b6c8f45… | yes | page 65163162 (= HEAD), blueprint b307ed09, 32 sections | none |
| rotate-the-github-app-key (:114-135) | c6591582… | **7e91b7f5…** | **no** | page 25d0f25c (= HEAD), blueprint e299f141, 10 sections | **yes**: `commit: fd90da8d` ("Drop the one-key identification ..."), 2 findings (`roll-back-to-the-old-key / s-rollback`; `/ x-rollback-verify, rb-repush`) |

The lock was last written by `77c308a18` ("Record the last blueprint reads of the seven").
`docs/claude-code/using-claude-code-with-cairn.md` does not exist at HEAD (new page).

## 8. Blueprint line counts, smallest first

| Lines | Blueprint |
|---|---|
| 829 | claude-code/using-claude-code-with-cairn |
| 1277 | extend/debug-your-site |
| 1387 | extend/restrict-admin-access |
| 1485 | extend/scaffolded-site-files |
| 1567 | extend/security-model |
| 2395 | extend/add-a-second-sign-in-group |
| 2952 | extend/add-cairn-to-a-sveltekit-app |
| (1437) | extend/rotate-the-github-app-key |

## 9. drafter config

`/var/home/glw907/Projects/cairn-cms/drafter.toml`, whole:

```toml
# drafter's project layer for cairn-cms: what every drafting run on this repo shares. Money, the
# key, the prompts module, agent definitions, and the index-link command live in each
# workstation's drafter.local.toml (ignored) and the user config until cutover.

# cairn runs on its own prompts module, so a run with none set must refuse the stock fallback.
require_prompts = true

[gate]
command = "npm run check:docs-gate -- --page {page} --brief {brief}"
protocol = "cairn-run-gate"
lane = "light"
# The docs gate prints one "== check:<name> ==" header per component.
section_pattern = '^== (check:\S+) ==$'
failure_pattern = '✖|defect\(s\)|broken link|target not found|\.json: [^0-9]|^ +\S+\.md$|^ +[0-9]+:[0-9]+ +error |^\S+\.md:[0-9]+: ([^w]|w[^a])'

[facts]
dir = "docs/internal/facts"

[seat.draft]
model = "claude-opus-5-5"
effort = "high"
# The longest task guides (restrict-admin-access, scaffolded-site-files) stopped at 64000 tokens
# of page, brief, and thinking.
max_tokens = 128000

[seat.structure]
model = "claude-opus-5-5"
effort = "medium"
max_tokens = 32000
inputs = ["git cat-file blob {baseline} | diff -u --label round-1 --label round-2 - {page}"]

[seat.editor]
model = "claude-opus-5-5"
effort = "medium"
max_tokens = 32000
inputs = [
  "vale {page}",
  "git cat-file blob {baseline} | diff -u --label round-1 --label round-2 - {page}",
]

# The chain selects option-map rows by the page's slug and its fact IDs. A command template can't
# name fact IDs, so this reads the slug's pending rows only. No row is the expected case: the
# command then prints nothing and exits 1.
[seat.fact]
model = "claude-opus-5-5"
effort = "medium"
max_tokens = 32000
inputs = [
  "grep -n 'pending {slug}' docs/internal/option-map.json",
  "git cat-file blob {baseline} | diff -u --label round-1 --label round-2 - {page}",
]

[seat.reader]
model = "claude-opus-5-5"
effort = "medium"
max_tokens = 32000

[seat.coverage]
model = "claude-opus-5-5"
effort = "low"
max_tokens = 32000

[seat.consistency]
model = "claude-opus-5-5"
effort = "low"
max_tokens = 32000

# The blueprint read, run by `drafter read`. It stays out of `seats`, which lists the seats
# `drafter page` runs.
[seat.blueprint]
model = "claude-opus-5-5"
effort = "medium"
max_tokens = 32000

# The brief path cairn's provenance check accepts, kept until cairn moves to the convention.
[blueprints]
brief_path = "docs/internal/briefs/{dir}/{name}.json"
```

`/var/home/glw907/.config/drafter/cairn-cms.local.toml`, whole. It holds no secret, but it sets
more than a prompts path:

```toml
prompts = "~/.claude/workflows/docs-page-chain.js"
inline_files = ["~/.local/share/cairn/exemplars"]

[gate]
index_link_command = 'arm=$(echo {page} | cut -d/ -f2); cairn-docs-outline link --worktree "$PWD" --outline docs/internal/outlines/${arm}.json --page {page}'

[seat.draft]
agent = "~/.claude/agents/cairn-docs-drafter.md"

[seat.editor]
agent = "~/.claude/agents/cairn-register-editor.md"
```

drafter does not read this file where it sits. `Load` reads the user layer
`<UserConfigDir>/drafter/config.toml`, then `drafter.toml` and `drafter.local.toml` under the
project root (`drafter/internal/config/load.go:13-15,33,85`). The file has to be copied into the
worktree as `drafter.local.toml`, which `.gitignore:33` ignores (load.go:113-133 refuses an
unignored one). B3c's copy, `.claude/worktrees/b3c-pilot-pages/drafter.local.toml`, differs only in
an absolute `prompts` path. `drafter config` in the main checkout (no local file) shows
`prompts = drafter:prompts.js ... (default)`, `inline_files = (unset)`, and
`gate.index_link_command = (unset)`.

**`require_prompts`.** It is project-layer only (`layer.go:40`). With `prompts` unset it makes every
run-scope command fail validation:

```
internal/config/validate.go:21  const RefusedStock = "prompts is not set, and require_prompts in drafter.toml refuses the stock module"
internal/config/validate.go:43  if c.Prompts == "" && c.RequirePrompts {
```

A run in a worktree without the copied local file refuses rather than drafting on the stock
`prompts.js`.

## 10. The cairn docs gate

**`npm run check:docs-gate -- --page <p> --brief <b>`** runs `node scripts/checks/docs-gate.mjs`
(package.json:58). It builds `dist` once (`npm run package`, skipped with `--prebuilt`), then runs
these components in order (`buildSteps`, docs-gate.mjs:66-110):

`check:docs`, `check:vale` (narrowed to `--page`), `check:vale-rules` (tree mode only, skipped with
`--page`), `check:facts`, `check:provenance` (narrowed to `--brief`), `check:leaks`,
`check:symbols`, `check:snippets`, `check:transcripts`, `check:visuals`, `check:arm-indexes`,
`check:editor-quotes`, `check:readiness`, `check:tool-conditions`, `check:target-stack`,
`check:reference`, `check:reference:signatures`, `check:options`, `check:tellgrader` (narrowed to
`--page`; it skips when the binary is absent).

Only Vale, provenance, and tellgrader narrow. The rest scan the whole tree, so `check:leaks` and
`check:symbols` see every page.

**`npm run check:facts`** runs `node scripts/checks/check-facts.mjs` (package.json:54). It needs
`typescript` installed (check-facts.mjs:402).

**Briefs** (`brief_path = docs/internal/briefs/{dir}/{name}.json`):

| Page | Brief | Exists |
|---|---|---|
| docs/claude-code/using-claude-code-with-cairn.md | docs/internal/briefs/claude-code/using-claude-code-with-cairn.json | **no** (only `.plan.yaml`) |
| docs/extend/debug-your-site.md | docs/internal/briefs/extend/debug-your-site.json | yes |
| docs/extend/restrict-admin-access.md | docs/internal/briefs/extend/restrict-admin-access.json | yes |
| docs/extend/scaffolded-site-files.md | docs/internal/briefs/extend/scaffolded-site-files.json | yes |
| docs/extend/security-model.md | docs/internal/briefs/extend/security-model.json | yes |
| docs/extend/add-a-second-sign-in-group.md | docs/internal/briefs/extend/add-a-second-sign-in-group.json | yes |
| docs/extend/add-cairn-to-a-sveltekit-app.md | docs/internal/briefs/extend/add-cairn-to-a-sveltekit-app.json | yes |

**Through `cairn-run-gate`.** cairn-pass says "Gate: `cairn-run-gate '<string>'` from the pass
worktree" (SKILL.md:19), with "a leading `CAIRN_GATE_LANE=<lane>` lifted onto the call
(`CAIRN_GATE_LANE=light cairn-run-gate '<rest>'`)" (:22-23), re-issued on exit 75
(`~/.local/bin/cairn-run-gate` header). For example:

```
CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:docs-gate -- --page docs/extend/debug-your-site.md --brief docs/internal/briefs/extend/debug-your-site.json'
CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:facts'
```

A tension, not resolved here: drafter.toml pins the gate to `lane = "light"`, but gate-tier keeps
fast line 1 (which contains `check:docs-gate`) on the heavy lane, because `check:reference` ran out
of heap under the light cap. gate-tier.mjs:155-163 reads "check:reference ran out of heap (`gate
exit: 1`, `JavaScript heap out of memory`)" and sets `FAST_LINE_1_LANE = ''`.

**Fast lane.** `node scripts/checks/gate-tier.mjs --fast --range <base>..HEAD` (SKILL.md:21). I
computed the output read-only with `decideFastGate` over hypothetical path lists:

- `scripts/checks/check-provenance.mjs` + `src/tests/unit/check-provenance.test.ts`:
  - line 1: `npm run check:close -- check:options check:chassis-boundary check:cm-internals check:idioms check:provenance check:comments && npm run check && npx vitest related --run --passWithNoTests --project unit scripts/checks/check-provenance.mjs src/tests/unit/check-provenance.test.ts`
  - line 2: `npm run test:component -- --no-file-parallelism` (whole component project: "nothing under src/ to select from"; a browser, heavy lane).
- `check-symbols.mjs` + `check-leaks.mjs` gives the same shape, with `check:leaks check:symbols`
  added to the close list. No docs gate.
- `docs/internal/facts/extend.md` alone: line 1 runs `check:close` over 20 docs checks
  (check:facts, provenance, leaks, symbols, vale, ...), then `npm run check && npm run
  check:docs-gate`, with tellgrader and vale-rules beside them. No unit tests and no component leg.
- **`blueprints/**` is in no bucket** ("is in no bucket, so every static check runs"). It selects
  every static check, `test:emit`, the showcase unit tests, and the whole component project (line
  2). Any blueprint edit gets the widest fast lane. gate-table.json `buckets` has no `blueprints/`
  entry.

**CI.** `test.yml`, `e2e.yml`, `design.yml`, `scaffold.yml`, and `create-site.yml` run
`on: push: branches: [main, rebuild]` and `pull_request`, with `paths-ignore: ['tool/**']`.
test.yml:144 runs `npm run check:docs-gate` (the whole tree, no `--page`). Watch:
`ci-green <sha> --pr <n> --wait` as a background Bash task, re-issued on 75 (exit 0 green, 1 red,
2 missing, 3 unavailable). The first push opens a draft PR (SKILL.md:40-45).

## 11. Live pages carrying the same claims

The seven pages (the rerun redrafts these):
- security-model.md:312-314: "The tidy action and the personal-dictionary action run their access
  check only when the route carries a `concept` parameter. On a route without one, either action is
  open to any editor-capability session." This contradicts `f:arr13a` (404). Related: :496 lists
  "Mounting the tidy and dictionary actions on a route that carries a `concept` parameter" as a site
  responsibility.
- security-model.md:173-174 ("the guard does not clone a request body", sec #1); :347 ("9. The
  site's plugins.", sec #3); :373-375 ("A registered `build()` can bypass every render-safety
  protection", sec #2).
- restrict-admin-access.md:206 ("Even an exhaustive map leaves the site-wide publish and the tidy
  and dictionary actions outside it."); :98 (inline image picker, restrict #2); :71-72 ("When the
  server starts, the engine builds its runtime ... a step called composition. Composition throws on
  a screen key", restrict #3); :43 (`--connect` "makes that connection", scaffold #5 analogue).
- debug-your-site.md:149-153 ("redirects to `/admin/login` when the editor's session lapsed after
  the guard resolved it ... This record is the only trace of the lapse.").
- scaffolded-site-files.md:126 (tree `├── .dev.vars.example`), :160-166 (the `.dev.vars.example`
  section; it also still names `GITHUB_APP_ID`/`GITHUB_APP_INSTALLATION_ID`, which `f:nls26c` says
  were dropped, and "read only when tidy is enabled"), :186 (`LICENSE`). The live page does not
  carry the `.gitignore` negation (:181-182).
- add-cairn-to-a-sveltekit-app.md:788 ("fails in three ways"); :1093 ("The first real sign-in
  creates the owner row and logs `editor.bootstrapped`"). :980 already says "recommended" for
  `0002_audit.sql`.
- add-a-second-sign-in-group.md:132 ("A guard created without `roles` resolves every session
  against the owner and editor pair"). :98 and :112 still teach the old `roles` option
  (`devBackendHandle({ roles })`), a separate staleness.
- Pages that tell a scaffold reader to edit `.dev.vars.example` (which the setup command's scaffold
  lacks): add-a-second-sign-in-group.md:350, :360; debug-your-site.md:346, :349.

**Outside the seven (not redrafted by the rerun):**
- docs/reference/log-events.md:74 (`admin.action.session_absent` row): "...so this is the only trace
  a `createAdminAction`-mounted route leaves for a session that lapsed between the guard's resolve
  and this action running." This is debug #1's wrong claim, word for word from `f:v1jj2k`.
- docs/extend/upgrade-cairn.md:101 ("Run `npx wrangler types --env-file=.dev.vars.example`") and
  docs/reference/sveltekit.md:2100 (`wrangler types --env-file .dev.vars.example`). Both assume the
  file exists; scaffold #1.
- docs/reference/sveltekit.md:99-103 ("The engine's own screens (gated through
  `requireEngineAccess`'s `canReach` check) stay open to any editor-capability session") is about
  an omitted map, which is correct as stated. It is listed only because the phrase matched.

## 12. The doc comment at admin-action.ts:155-156

```
src/lib/sveltekit/admin-action.ts:155   * 1. `event.locals.cairnEditor` must be populated (the engine's admin guard already resolved it); its
src/lib/sveltekit/admin-action.ts:156   *    absence means the session expired or was never established, so this logs
src/lib/sveltekit/admin-action.ts:157   *    `admin.action.session_absent` and redirects to `/admin/login`, matching `requireSession`
```

The code it documents is at :213-216. It is filed for the backlog, not edited here.
