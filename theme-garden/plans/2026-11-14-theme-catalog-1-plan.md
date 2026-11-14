Initiative: theme-garden

# Theme catalog 1: the hosted catalog, its publish job, and the reference page

Design: `../specs/2026-11-14-theme-catalog-design.md` (approved by Geoff 2026-11-14, Approval Queue
item 20261114-194635-5aa21f; binding). This pass is step 1 of its "Order of work".
Repo: `glw907/cairn-cms`, main checkout `/var/home/glw907/Projects/cairn-cms`. Every `file:line` was
read at `839232fe9`; the conductor re-checks them against `main` before launch (pre-flight item 1).
Conductor: `conductor-cairn-cms`. Executor: `cairn-cms-theme-catalog-1`.
Load at start: `pass-core`, `cairn-pass`, `cairn-running-passes`; `cairn-writing-engine-code` for
`scripts/**`; `standards:ts-conventions` for comments; `cloudflare:wrangler` for the demo's Wrangler
file; `cairn-writing-docs` only if a page under `docs/` changes; `cairn-judging-scope` before any
new surface the plan does not name.

The two rules every dispatch carries are `pass-core` step 1's quoted samples ("Avoid
over-engineering..." and "Deliver what was asked..."). Nothing below adds a feature the design does
not name. This pass changes no file under `tool/`, and `cairn new` reads nothing new: the installer
is the design's step 2 and has its own plan.

Class: `runner` (`.github/workflows/**`, `.github/ci-green.json`, `scripts/checks/gate-table.json`),
and `live-account`: CI publishes to a real R2 bucket and deploys a real Worker.

## Pre-flight

Items 2 to 5 are done by one interactive session with `ws-admin`, in order, before the conductor
launches the executor. A `claude --bg` executor can do none of them: the denial log shows auto mode
refusing public surfaces, domain changes, secret-store writes, and deploys (see "Permissions
checked"). Item 2 is Geoff's and was not in the design, so launch holds for a pre-launch packet
that asks for it.

1. **[session] The re-check.** The conductor fetches cairn-cms and reads every `file:line` below
   against `origin/main`. If `themes/survey/` is on `main`, the conductor adds Survey to C1.1 (its
   manifest gains the same fields, `kinds` `["blog", "organization"]`), adds a `cairn-demo-survey`
   Worker at `demo-survey.cairn.pub` to items 3 to 5, and commits the fold. Check: the fold commit,
   or a "no drift" line under this item, is on `origin/main` of `glw907/initiatives`.
2. **[you] The temporary token.** Geoff creates `tmp-account-tokens` as
   `~/.claude/docs/cloudflare-estate/api-tokens.md` rule 6 says, with a TTL ending the next day. The
   session receives it with `secret-receive` into the RAM-only scratch store that rule describes,
   never the age store and never chat. All four tokens below are account-owned, so
   `tmp-token-setup` isn't needed. Check: the token verifies active through the API.
3. **[session] The buckets and their addresses.** Two R2 buckets: `cairn-catalog` at
   `catalog.cairn.pub`, and `cairn-catalog-proving` at `catalog-proving.cairn.pub`. Each has its
   `r2.dev` address off and a CORS policy allowing `GET` and `HEAD` from any origin. No cache rule
   is added (see "Calls settled here"). `cairn-catalog` gets a bucket lock rule with no end date on
   the prefixes `themes/` and `sets/`; the proving bucket gets none. The session shows the commands
   as a dry run first. Check: `curl -sI https://catalog.cairn.pub/index.json` answers 404 from R2, the same for the
   proving address, and both `r2.dev` addresses refuse. The CORS header is read on a real object in
   item 5, since no Cloudflare page says a 404 carries it.
4. **[session] The demo Workers.** Two Workers with static assets and no script, each deployed once
   with a one-line placeholder page: `cairn-demo-waymark` at `demo-waymark.cairn.pub`, and
   `cairn-demo-proving` at `demo-proving.cairn.pub`. The Wrangler file sets `workers_dev` and `preview_urls` to false on both. Check: each
   address answers 200 over HTTPS, and neither Worker has a `workers.dev` address.
5. **[session] The four tokens, the store, and the two environments.** Minted with the temporary
   token, each account-owned with no expiry:

   | Cloudflare name | Scope | GitHub environment |
   | --- | --- | --- |
   | `ci-cairn-catalog-r2-rw` | R2 object read and write, `cairn-catalog` | `catalog` |
   | `ci-cairn-demos` | Individual Workers Editor on `cairn-demo-waymark` | `catalog` |
   | `ci-cairn-catalog-proving-r2-rw` | R2 object read and write, `cairn-catalog-proving` | `catalog-proving` |
   | `ci-cairn-demos-proving` | Individual Workers Editor on `cairn-demo-proving` | `catalog-proving` |

   Each value goes first into the age store through `scripts/secrets/secret-set.sh` under the
   scheme's names (`CF_CI_CAIRN_CATALOG_R2_RW_TOKEN` with its `_KEY_ID` and `_SECRET` pair, and so
   on), and from there to the environment by `gh secret set --env`, on stdin. The environment
   `catalog` has one deployment branch rule, `main`. `catalog-proving` has no deployment branch
   restriction, because a pull request run's ref is `refs/pull/<n>/merge` and a branch pattern
   would refuse it. Each environment holds the secrets `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`,
   and `CLOUDFLARE_API_TOKEN`, and these variables:

   | Variable | `catalog` | `catalog-proving` |
   | --- | --- | --- |
   | `CLOUDFLARE_ACCOUNT_ID` | the account id | the same |
   | `CATALOG_BUCKET` | `cairn-catalog` | `cairn-catalog-proving` |
   | `CATALOG_ORIGIN` | `https://catalog.cairn.pub` | `https://catalog-proving.cairn.pub` |
   | `DEMO_WORKER` | `cairn-demo-{id}` | `cairn-demo-proving` |
   | `DEMO_ORIGIN` | `https://demo-{id}.cairn.pub` | `https://demo-proving.cairn.pub` |
   | `RELEASE_CACHE_CONTROL` | `public, max-age=31536000, immutable` | `public, max-age=60` |

   The session then proves, from the workstation, with each new token and never `ws-admin`, the
   requests the run makes. With each Editor token: a `wrangler deploy` of the placeholder over its
   Worker, once with the `routes` entry in the Wrangler file and once without, and then a re-read
   that neither Worker gained a `workers.dev` address. With each R2 token, under the prefix
   `probe/`: a `PutObject` with `If-None-Match: *`, a `Cache-Control`, and a `Content-Type`; a
   `HeadObject` that shows both headers; the same put again, which answers 412; a `GetObject`; a
   read through the bucket's address with an `Origin` header, which carries
   `access-control-allow-origin: *`; a `ListObjectsV2`; and a `DeleteObjects`, after which the list
   is empty. For the lock's reply, the session adds a one-day lock rule on `probe-lock/` in the
   proving bucket with `ws-admin`, puts one object there, tries an overwrite and a delete with the
   proving token, then removes the rule and the object. It saves every raw reply (status, headers,
   and error body, no credential) in the plan's review file, and C1.6 builds its fake bucket from
   them. It records which Wrangler form the Editor token accepts under this item, adds the four
   rows to the token table, and deletes `tmp-account-tokens` through the API. Check: `gh api
   repos/glw907/cairn-cms/environments/catalog/deployment-branch-policies -q
   '.branch_policies[].name'` prints `main` alone; `gh api
   repos/glw907/cairn-cms/environments/catalog-proving -q .deployment_branch_policy` prints `null`;
   `gh secret list --env catalog` and `--env catalog-proving` each name three secrets; both
   `probe/` prefixes list empty; the temporary token's id answers 404.
6. **[session] The pre-launch checks** in `pass-core` "Execute".

Items 2 to 5 were done on 2026-11-14, after Geoff created the temporary token and approved the dry
run in chat, so no pre-launch packet is owed for them. Every check in items 3 to 5 passed, and
`tmp-account-tokens` is deleted. The Editor tokens accept only a Wrangler file with no `routes`
entry (with one, `wrangler deploy` exits 1 with code 10084), so C1.5 generates the file without
it. The replies are in the review file under "Replies recorded at pre-flight". Items 1 and 6
remain, and launch still waits behind `tui-language` and Geoff's theme round.

Permissions checked: each task's writes and credentials were read against auto mode for a `claude
--bg` executor, and against the last 30 days of `~/.local/state/claude-denials.jsonl` (66 rows,
2026-11-01 to 2026-11-14). The classes that bear on this pass are Create Public Surface (2), DNS,
Domain, and Cert Changes (1), Secret-Store Writes (1), Production Deploy (1), Auto-Mode Bypass (3,
each a `gh workflow run`), and Code from External (1). So the executor and its pairs write only
tracked files in their own worktrees. They run `npm`, `node --test`, `npx vitest`, Playwright
Chromium, `npm run theme:view`, `npm run check:theme`, and `npm run lane:fast`. They run `npm
install --save-dev` for three named registry packages (C1.1). They read the proving addresses
with `curl`. The executor pushes `theme-catalog-1` to `glw907/cairn-cms` and opens a PR. No task
reads `~/.local/secrets`, holds a Cloudflare token, runs `wrangler deploy`, dispatches a workflow,
creates a bucket, a domain, an environment, or a secret, or edits a `.claude/**` file,
`settings.json`, or a hook. Every write to Cloudflare in this pass is made by CI on the pushed
branch, with the proving tokens.

Reviewed: one `standards:plan-reviewer` read, 2026-11-14, folded. Its findings and what each
changed are in `2026-11-14-theme-catalog-1-review.md`.

## What was probed

| Mechanism | Evidence |
| --- | --- |
| The themes list comes from `templates/catalog.json` in two places | `scripts/theme/check.mjs:77` and `scripts/theme/viewer/site.mjs:44`, both named `catalogThemes`; CI calls the first at `.github/workflows/test.yml:127` (`npm run check:theme -- --catalog`) |
| The Go tool still reads `templates/catalog.json` | `tool/internal/setup/scaffold/catalog.go`, with four test files; so the file stays in this pass |
| A built template is already public pages plus a script the assets ignore | `/var/tmp/cairn-cleanroom/acceptance/site/.svelte-kit/cloudflare/` (built 2026-11-07): prerendered `.html` for every public route, `_app/`, and an `.assetsignore` naming `_worker.js`, `_routes.json`, `_headers`, `_redirects`; 492 files, 19 MB |
| The viewer composes and builds a site with no account | `scripts/theme/viewer/site.mjs` `composeSite` and `buildSite`; its header says the build never signs in |
| A static-assets Worker needs no script | Cloudflare docs: a Wrangler file with `name`, `compatibility_date`, and `assets.directory`; an unmatched path answers 404 |
| An R2 write can be create-only | Cloudflare docs: S3 `PutObject` honors `If-None-Match: *` and answers `412 PreconditionFailed`; a bucket lock rule answers `409` to an overwrite or a delete |
| An R2 custom domain doesn't cache JSON | Cloudflare docs: "HTML and JSON are not cached unless you create a Cache Rule"; a cached 404 lasts until its TTL |
| CORS headers appear only on a request with `Origin` | Cloudflare docs, R2 CORS |
| A per-Worker Editor token deploys over a configured domain and can't add one | `api-tokens.md`, last paragraph; whether `wrangler deploy` accepts a `routes` entry under that token is unprobed, and pre-flight item 5 proves it |
| Every workflow file needs a class and every job a timeout | `src/tests/unit/workflow-yaml.test.ts:95` and the `ci-green.json` cases after it |
| The four hostnames are free | `dig +short` on each printed nothing, 2026-11-14 |
| `npm test` must stay the two Vitest scripts, and `test.yml` steps must appear in the gate tier | `src/tests/unit/workflow-yaml.test.ts:182` splits `scripts.test` and compares it with `test.yml`; `src/tests/unit/gate-tier.test.ts:744` fails on a `test.yml` step missing from `scripts/checks/gate-tier.mjs:98` (`CI_CHECKS`), `CI_EQUIVALENTS`, or `CI_NOT_LOCAL` |
| A bucket pattern needs a row in the gate-tier test | `src/tests/unit/gate-tier.test.ts:41` |
| A lane leg is a fixed string and can't take the range | `scripts/checks/gate-table.json:118` (`extraCommands`); `scripts/checks/fast-lane.mjs:66` passes `--range` to the classifier only |
| A script under `scripts/` that no check reads makes every static check run | `scripts/checks/gate-tier.mjs:421`; `scriptsTestOnly` at `gate-table.json:70` is the exemption |
| The showcase's menus link to `/admin` | `examples/showcase/src/site/site.config.yaml:11` and `:18`; a built site's `index.html` holds `href="/admin"` twice |
| `ajv` and `playwright` are dev dependencies; `sharp`, `semver`, and `aws4fetch` aren't | `package.json:267`, `:275` |

## Calls settled here

- **One pass.** The work is one chain with three pairs, and its proof needs every piece.
- **Waymark's theme version goes to `1.1.0`**, with `notes` "Adds the fields the hosted catalog
  reads." The version-rise check (C1.4) would otherwise fail on the manifest change this pass makes.
  Its other new fields: `engine` `>=0.99.0-0`, `kinds` `["blog"]`, `repository`
  `https://github.com/glw907/cairn-cms`, and a `summary` the executor drafts within 300 characters.
- **The themes list is the directories under `themes/`.** `check.mjs --catalog` and the viewer's
  `catalogThemes` read every `themes/*/cairn-theme.json`. The flag keeps its name.
  `templates/catalog.json` is unchanged and keeps feeding the pack script and the Go tool.
- **Kinds data lives in `sets/kinds.json`**: the five ids, labels, and descriptions from the
  design's table. The fourth row is Geoff's wording and is copied exactly. The other four are
  finished against `~/.claude/docs/voice/editor.md` within 160 characters. The manifest schema
  takes a theme's `kinds` from those five ids.
- **The first catalog lists no kind and no set.** The design offers a kind only when its set
  exists, and no set exists yet. `index.json` carries `"kinds": []` and `"sets": []`, and the schema
  allows both. The generator and the publish script handle sets, proven on fixtures.
- **Waymark's demo is built over the packaged starter overlay**, `scripts/build/starter-overlay/`,
  without the conformance set. It moves to the blog set when one is published.
- **A demo is the adapter's output directory deployed as assets.** The demo build writes a
  Wrangler file with no `main` and with `workers_dev` and `preview_urls` false, so only the
  prerendered public pages are served. The file is written to the output directory and never
  committed, since a tracked `wrangler.*` file would raise the pass to `auth-data`. The demo build
  removes every menu entry whose address is `/admin` from the composed site's configuration,
  because a demo has no admin and the link would answer 404. Each page's
  `<head>` carries `<meta name="cairn-theme-release" content="<id>@<version>">`, written into the
  scratch site's `src/app.html` before the build. That is the version the demo check reads.
- **Two targets, chosen by GitHub environment.** A pull request from a branch of the repo publishes
  to `catalog-proving`. A push to `main` publishes to `catalog`. The script reads the bucket, the
  origin, the Worker name, the demo address, and the release `Cache-Control` from the environment's
  variables, replacing `{id}` with the theme id. It has no target name in it.
- **The proving target starts empty every run.** The job's first step empties the proving bucket,
  and the script refuses that step unless `CATALOG_BUCKET` ends in `-proving`. All proving demos
  deploy over the one Worker `cairn-demo-proving`, in turn. A real theme's Worker is
  `cairn-demo-<id>`. Proving release objects carry `max-age=60`, because a reset can put changed
  bytes at a path the edge would otherwise hold for a year.
- **The index is read from the bucket, never the public address.** The publish script reads
  `index.json` with an S3 `GetObject`, so no edge cache stands between it and the file. Only a
  missing key means an empty catalog. A 5xx, a body that isn't JSON, or one the schema refuses
  fails the run before any write.
- **A release path is written once.** Every release object is put with `If-None-Match: *`. On 412
  or 409 the script reads the object's digest: an equal one means an earlier run stopped partway,
  and the run goes on; a different one fails the run naming the path. A card image already at its
  path is kept. So an archive is built the same way every time. The builder writes ustar itself,
  with no tar library: entries sorted bytewise by path, mtime 0, mode 0644 or 0755, uid and gid 0,
  empty user and group names, and a gzip header with mtime 0, a fixed OS byte, and no file name.
- **`index.json` is the one object overwritten**, last, with `Cache-Control: max-age=300` and
  `Content-Type: application/json`. Release objects carry `RELEASE_CACHE_CONTROL`. No cache
  rule is added, so the edge always reads the newest file and a browser holds it five minutes.
- **The archive's root directory is `theme/`** for a theme and `set/` for a set. A theme archive
  holds the files `layIn` copies to `src/theme/`, the generated `theme-names.ts`, and
  `app-html-block.html`, the lines `rewriteAppHtml` writes between the two markers in
  `src/app.html`, without the markers and without indentation.
- **A set's manifest is `sets/<kind>/cairn-set.json`**, described by a new
  `schema/cairn-set-1.schema.json`: `kind`, `version`, `engine`, `notes`, `license`, and `images`,
  a list giving each image's path, source, and license. No set exists yet, so only fixtures use it.
- **Three new dev dependencies** at the root: `sharp` (the card image), `semver` (range checks in
  scripts), and `aws4fetch` (signed S3 requests that carry `If-None-Match`, which Cloudflare's R2
  docs name for this job). None reaches the packed engine. C1.1 installs all three, so no paired
  task edits `package.json`.
- **The catalog's tests are `npm run test:catalog`**, `node --test` over
  `scripts/catalog/**/*.test.mjs`, like `test:theme`. `npm test` is unchanged. The script is a
  fast-lane leg for the `scripts` and `showcase` buckets and a step in `test.yml`.
  `scripts/catalog/` joins `scriptsTestOnly`, so a catalog script doesn't run every static check.
- **The version-rise check's default range** is `$(git merge-base origin/main HEAD)..HEAD`, so its
  lane leg is a fixed string. CI passes `--range` itself.
- **The engine rule this pass enforces** is the range's form and that it admits the engine version
  in the root `package.json`, by SemVer precedence with prereleases included. Proving that a
  declared minimum is the true minimum needs an engine release that reads the catalog, and none
  exists. C1.9 files that as a backlog item.
- **The reference page is `scripts/catalog/reference/index.html`.** It reads the catalog address
  from a `catalog` query parameter that defaults to `https://catalog.cairn.pub/index.json`, and
  compares versions with its own inline SemVer precedence function. Its check serves it from
  `127.0.0.1`, which is another origin.
- **The live publish is the merge.** Merging changes `themes/waymark/`, so the push to `main`
  publishes Waymark `1.1.0` to the real bucket. Nothing reads that bucket yet.

## Backlog verdicts (scoped sweep, cairn-cms `BACKLOG.md` at `839232fe9`)

Read: every open item tagged `#initiative:theme-garden` or naming the catalog. #417 (let an outside
designer run the viewer) keeps, and its placement still holds. #410 and #416 keep for the installer
pass and a showcase pass. #412, #413, #415, #419, #378, and #471 keep and are untouched here. The
three items placed in "the installer round, after theme-garden G3" keep. This pass clears none.

## Estimate

Path 750 minutes, stop line 1,500. Expected actual is about 240 minutes at the 0.32 factor. C1.1,
C1.4, and C1.8 each carry 15 minutes of CI wait. The
design carried no number.

## The pass

| Pass | Slug | Class | Path minutes | Merge |
| --- | --- | --- | --- | --- |
| C1 | `theme-catalog-1` the hosted catalog | `runner`, `live-account` | 750 | the conductor, on Geoff's approve in the end packet |

Every task writes `.pass-task-clock` at its start, commits, and runs `npm run lane:fast -- --range
<base>..HEAD` at its end. A task that edits `.github/workflows/`, `.github/ci-green.json`, or
`scripts/checks/gate-table.json` waits for CI green on its own commit, and its estimate carries the
wait. No task bumps the engine's version or publishes to npm. New scripts live in
`scripts/catalog/`, and from C1.2 on each task also runs `npm run test:catalog` at its end.

**C1.1 The manifest fields and the lane** (110 min, waits for CI on its commit). Outcome: the contract-1 manifest schema gains `engine`
(required, the two forms only), `kinds` (required, one to three of the five ids, no repeats),
`notes` (required, at most 200 characters), `summary` (at most 300), and `repository`. Waymark's
manifest carries them, at `1.1.0`. The theme check gains an `engine-range` rule, and the check and
the viewer list themes from `themes/`. `sets/kinds.json` exists, with `schema/cairn-set-1.schema.json` for a set's manifest. The three
dev dependencies are installed, and `test:catalog` exists with one test of the
kinds data. In `scripts/checks/gate-table.json`, `sets/` joins the `showcase` bucket,
`scripts/catalog/` joins `scriptsTestOnly`, and `test:catalog` is an `extraCommands` leg. The
schema edit also runs the Go tool's legs, since `schema/` is a tool input. Files:
`schema/cairn-theme-1.schema.json`, `schema/cairn-set-1.schema.json`, `package.json`,
`package-lock.json`, `knip.jsonc` if it flags the new entries, `src/tests/unit/gate-tier.test.ts`,
`themes/waymark/cairn-theme.json`, `sets/kinds.json`, `scripts/theme/{check.mjs,check.test.mjs,
viewer/site.mjs}` and the viewer's tests, the theme fixtures' manifests, both copies of
`checking-a-theme.md`, `scripts/checks/gate-table.json`, `templates/waymark/**` only where the
bake regenerates it. Acceptance: a manifest test fails unless each of these is refused: no
`engine`, `engine` `^1.0.0`, `engine` `>=1.0.0 <2.0.0 <3.0.0`, four kinds, an unknown kind, `notes`
of 201 characters. The same test fails unless `>=1.2.0`, `>=1.2.0 <2.0.0`, and `>=0.99.0-0` are
each accepted, and unless the schema's kind ids equal the ids in `sets/kinds.json`. `check.mjs
themes/waymark` passes every rule. With a second fixture directory
under a scratch `themes/`, `--catalog` checks both. The gate-tier test gains the row `['showcase', 'sets/',
'sets/kinds.json']` and a case that a path under `scripts/catalog/` picks the `test:catalog` leg
without the every-check fallback; both fail on today's table. `git grep -n "catalog.json" --
scripts/theme` prints nothing, comments included. The readers outside `scripts/theme` stay:
`scripts/build/pack-engine-template.mjs`, `scripts/checks/check-package-files.mjs`, and the Go
tool.

**Pair A: C1.2 and C1.3** (after C1.1)

**C1.2 The catalog schema and the index generator** (100 min). Outcome:
`schema/cairn-catalog-1.schema.json` (`$id` `https://cairn.pub/schemas/cairn-catalog/1.json`, draft
2020-12) describing the design's file, and `scripts/catalog/index.mjs`, a pure function from the
previous index, the theme manifests, the kinds data, and the new release records to the next index.
Top-level theme fields come from the newest release's manifest, `releases` is newest first by
SemVer, a kind is listed only when a set for it has a release, and unknown fields in the previous
index survive. Files: the schema, `scripts/catalog/{index.mjs,index.test.mjs}`,
`scripts/catalog/fixtures/index/**`, `scripts/checks/check-package-files.mjs` if it lists `schema/`.
Acceptance: tests fail unless the schema refuses a theme with no `demo`, no `card`, or no
screenshot, a release with no `notes`, a relative URL, and an image with no width; adding `1.1.0`
to an index holding `1.0.0` puts it first and moves the top-level fields; a set release for
`blog` makes the `blog` kind appear and no other; the design's example file validates once its
placeholder digests are filled. `npm run check:package` passes.

**C1.3 The archive builder and the card image** (130 min). Outcome:
`scripts/catalog/archive.mjs` builds a theme's or a set's gzipped tar as "Calls settled here"
says, and returns its bytes, `sha512-` integrity string, and size. `scripts/catalog/card.mjs`
makes a 720 by 480 WebP from the manifest's first screenshot. Files: those two, their tests,
`scripts/catalog/fixtures/archive/**`. Acceptance: tests fail unless a small fixture theme's
archive hashes to a `sha512-` string committed in the test, which the workstation and the CI
runner must both reach; two builds of Waymark give the same digest; `tar -tzf` lists the archive
with exit 0; the archive holds `theme/theme-names.ts` and
`theme/app-html-block.html` and no path outside `theme/`; the block text equals what
`rewriteAppHtml` writes for Waymark's color modes; a set fixture missing the literal `siteName:
Waymark` is refused; an archive over 8 MiB, a set image over 400 KB, and a card over 100 KB are
each refused with the limit in the message; a first screenshot that isn't 3:2 is refused.

**Pair B: C1.4 and C1.5** (after pair A)

**C1.4 The version-rise check** (65 min, waits for CI on its commit). Outcome: `scripts/catalog/version-rise.mjs --range
<base>..<head>` fails when any file under `themes/<id>/` or `sets/<kind>/` differs across the range
and that directory's manifest version did not rise by SemVer precedence. A directory new in the
range passes. With no `--range` it uses the default in "Calls settled here". It is an
`extraCommands` leg for the `showcase` bucket, so this task waits for CI on its commit. Files: the
script, its test, `scripts/checks/gate-table.json`, `src/tests/unit/gate-tier.test.ts`. Acceptance: the test builds a scratch git
repository and fails unless a changed theme file with an unchanged version exits 1 naming the
theme, the same change with a raised version exits 0, a lowered version exits 1, and a new theme
exits 0. On this branch the check passes, because Waymark rose to `1.1.0`.

**C1.5 The demo build** (90 min). Outcome: `scripts/catalog/demo.mjs <themeDir> --out <dir>`
composes a site with the theme and the given content directories, writes the release marker into
`src/app.html`, removes the `/admin` menu entries, builds it, and leaves in `<dir>` the assets
directory and a Wrangler file with `name` from `DEMO_WORKER`, a `compatibility_date`,
`assets.directory`, `workers_dev` and `preview_urls` false, and the `routes` form pre-flight item 5
recorded, its host from `DEMO_ORIGIN`.
`composeSite` gains a parameter for the content directories, defaulting to today's two. Files:
`scripts/catalog/{demo.mjs,demo.test.mjs}`, `scripts/theme/viewer/site.mjs`. Acceptance: the test
builds Waymark's demo and fails unless `index.html` carries the marker `waymark@1.1.0`, no file
named `_worker.js` is in the assets directory after `.assetsignore` is applied, no page from the
conformance set is present, no page holds `href="/admin"`, and every internal `href` and `src` in
every built page resolves to a file in the directory. The viewer's existing tests pass unchanged.

**Pair C: C1.6 and C1.7** (after pair B)

**C1.6 The publish script** (150 min, test first). Outcome: `scripts/catalog/publish.mjs` does the
design's five publishing steps for each theme and set whose version is not in the index it reads
from the bucket. It
runs the theme check; builds the archive and the card; puts each release object create-only with
the resume rule; builds and deploys the demo, then polls the demo address for up to two minutes
until its marker names the new release; then generates the index, validates it against the schema,
and puts it last. It takes its S3 client, its deploy function, and its `fetch` as arguments. With
nothing to publish it prints `catalog: nothing to publish` and writes nothing. `--reset` empties
the bucket and is refused unless `CATALOG_BUCKET` ends in `-proving`. Files:
`scripts/catalog/{publish.mjs,publish.test.mjs,r2.mjs}`, `scripts/catalog/fixtures/r2/**` (the
replies pre-flight item 5 recorded). Acceptance, each against a fake deploy and a fake bucket that
answers as those replies do, committed first and red: an index read that answers 5xx, one that
isn't JSON, and one the schema refuses each fail the run with no object written, and only a
missing key starts an empty catalog; a first publish writes the archive, the screenshots, the card, then the index, in that
order; a failed theme check, a failed deploy, and a marker that never appears each leave the index
unwritten; a second run is a no-op; a run after a simulated stop between the archive and the index
finishes without rewriting the archive; an existing archive with a different digest fails naming
its path; a release with no `notes` is refused; `--reset` against a bucket named `cairn-catalog`
exits nonzero and deletes nothing; a 412 and a 409 on a release path both take the resume rule;
every put carries the `Cache-Control` and `Content-Type` in "Calls settled here".

**C1.7 The reference page and its check** (150 min). Outcome: `scripts/catalog/reference/index.html`,
one HTML file with inline CSS and script and no library, showing every row of the design's "What
cairn.pub's theme section gets" from one fetch. `scripts/catalog/reference-check.mjs --catalog
<url>` serves it on `127.0.0.1`, opens it in Playwright Chromium, and fails on any of: a request
that is neither the page, the catalog address, nor an image; a missing row; a kind or engine choice
that leaves the shown themes unchanged when the data says they differ; a card, a screenshot, or a
demo address that doesn't answer 200; a demo whose marker differs from its theme's newest version.
The page follows the five-viewport bar with no horizontal scroll, and its markup is plain and
accessible, since the cairn.pub rebuild may start from it. Files: the page, the check, its test,
`scripts/catalog/fixtures/reference/**` (a two-theme, two-kind catalog with local images and a
local demo page). Acceptance: the test serves the fixture catalog on a second port, so the fetch
is cross-origin, runs the check with no network, and fails unless the page has no horizontal
scroll (`scrollWidth` at most `innerWidth`) at 320, 390, 768, 1440, and 2560; choosing the second kind hides the first theme, choosing an engine version below a
theme's minimum hides it, and choosing one that only an older release admits shows that older
version; a fixture with a wrong demo marker, one with a missing card, a catalog served with no
`access-control-allow-origin` header, and a page edited to fetch a second address each make the
check exit 1. `standards:daisyui-a11y-reviewer` reads the page for
its accessibility findings only, and each is fixed or answered in the PR.

**C1.8 The workflows and the proving run** (120 min, `runner`, waits for CI on its commit, after
pair C). Outcome: `.github/workflows/catalog.yml` runs on `pull_request` and on `push` to `main`
for the paths `themes/**`, `sets/**`, `schema/cairn-catalog-1.schema.json`, `scripts/catalog/**`,
`scripts/theme/**`, `scripts/build/starter-overlay/**`, and its own file, and on
`workflow_dispatch`, which runs on `main` only, uses `catalog`, and never resets. The job's setup
is the root `npm ci`, `npm ci --prefix examples/showcase`, `npm run package`, and `npx playwright
install --with-deps chromium`. A pull request uses the environment
`catalog-proving`, runs `publish.mjs --reset`, then runs `publish.mjs` a second time and fails
unless it prints `catalog: nothing to publish`, then runs `reference-check.mjs` against the proving
address. A push to `main` uses `catalog` and runs `publish.mjs` once, then the reference check
against the real address. The job skips a pull request from a fork or from Dependabot, since
neither gets the environment's secrets. It sets `permissions: contents: read`, a
`timeout-minutes`, and `concurrency` with one group per environment and `cancel-in-progress:
false`. GitHub still drops an older queued run when a newer one queues in the same group, and that
is fine here because each run publishes whatever is missing. `.github/workflows/catalog-check.yml` runs `reference-check.mjs`
against the real address daily and on dispatch, with no secret. `ci-green.json` lists the first
under `judgedWhenPresent` and the second under `neverOnPullRequest`, and the second installs
Playwright Chromium too. `test.yml` gains two steps, `npm run test:catalog` and `node
scripts/catalog/version-rise.mjs --range <base>..HEAD`, with `fetch-depth: 0` on its checkout. The
base is `github.event.pull_request.base.sha` on a pull request and `github.event.before` on a push,
and the step is skipped when `before` is all zeros. Both steps join `CI_CHECKS` in
`scripts/checks/gate-tier.mjs`, the version-rise one in its no-range form through
`CI_EQUIVALENTS`. If the workflow test's rule against an `if:` naming `pull_request` covers
`catalog.yml`, the fork skip is written on `github.event.pull_request.head.repo.full_name` and the
test gains one named exception for it. Files: the two workflows, `.github/ci-green.json`,
`.github/workflows/test.yml`, `scripts/checks/gate-tier.mjs`,
`src/tests/unit/{gate-tier,workflow-yaml}.test.ts`. Acceptance:
`src/tests/unit/workflow-yaml.test.ts` and `gate-tier.test.ts` pass. On the pushed commit the
`catalog` job is green, and the executor then makes these reads itself:

1. `curl -sS https://catalog-proving.cairn.pub/index.json`, validated against the schema with
   `ajv`. It lists Waymark `1.1.0` with `kinds` and `sets` empty.
2. The archive at that release's `url`, downloaded, hashes to its `integrity`.
3. `curl -sI -H 'Origin: https://example.com' https://catalog-proving.cairn.pub/index.json` shows
   `access-control-allow-origin: *` and `cache-control: max-age=300`.
4. `curl -sI` on the archive's `url` shows `cache-control: public, max-age=60`.
5. `curl -sS https://demo-proving.cairn.pub/ | grep -F 'waymark@1.1.0'` matches.
6. `curl -so /dev/null -w '%{http_code}' https://demo-proving.cairn.pub/admin` prints 404.

A read that disagrees is repeated once after three minutes, since the edge holds a 404 about that
long. If the release or the marker belongs to another pull request, which shares the proving
target, the executor reads the environment's latest deployment and reruns its own job's failed
attempt from the PR's checks page with `gh run rerun`. If actionlint refuses an `environment` chosen by an expression, the
workflow has two jobs with fixed environments. The executor never dispatches either workflow.

**C1.9 Docs and harvest** (70 min). Outcome: `CHANGELOG.md` under `## Unreleased` names the new
manifest fields, the catalog schema, and that the theme check reads `themes/`.
`MIGRATION-NOTES.md` says a theme manifest must now carry `engine`, `kinds`, and `notes`.
`skills/cairn-styling-public-pages/references/theme-directory.md` documents the five fields, and
`checking-a-theme.md` the `engine-range` rule. A new maintainer page,
`docs/internal/theme-catalog.md`, says how a release is published, how a new theme gets its demo
Worker and its token scope (a `ws-admin` session, as pre-flight items 4 and 5 did), how to rerun a
stopped publish, and what to do when a path is locked. Backlog items go in through
`standards:log-issue`, tagged `#initiative:theme-garden`: proving a declared engine minimum; moving
Waymark's demo to the blog set; serving both schemas from the rebuilt cairn.pub. Files: those.
Acceptance: `npm run check:docs-gate` passes on the head; a fresh subagent that did not write the
maintainer page checks every command, path, and name in it against the branch head, and each
finding is fixed.

**Close** (70 min). `standards:diff-reviewer` reads the whole branch against the design and this
plan, and `standards:cloudflare-workers-reviewer` reads the demo's Wrangler file and the publish
script. Findings are fixed or answered in one fix chain, and `npm run check:docs-gate` reruns
after the last docs edit. A second review runs only on a blocker, and its low findings are fixed
once or filed, never the start of a third round. The PR goes ready. Its body carries the acceptance list below with the evidence for each
line, the proving run's URL, and screenshots of the reference page against the proving catalog at
1440 and 390, read by the executor's own eyes first. The executor sends the conductor the PR
number, the head, the CI verdict on that head, and the screenshots' absolute paths.

Path: 110 + 130 + 90 + 150 + 120 + 70 + 70 = 740, plus 10 for merging the three pairs.

## Acceptance list for the PR

Each line can fail. Lines 1 to 5 are shown on the proving target before merge, and line 6 on the
real one after it.

1. The catalog file at the proving address validates against the schema and lists Waymark `1.1.0`.
2. Waymark's published archive matches its digest, and a second publish run changes nothing.
3. The reference page, from another origin, shows the grid, a theme's page, the engine filter, the
   demo link, the version history, and the install command from one fetch, and requests nothing
   else but images. The kind filter is shown on the fixture, since the first catalog lists no kind.
4. The demo serves the release the catalog names, and has no admin.
5. A theme changed without a version rise fails CI, shown by the check's test.
6. After merge: the same five readings hold at `catalog.cairn.pub` and `demo-waymark.cairn.pub`,
   and the archive answers `immutable`.

## After merge

The conductor, not the executor, does these once the merge's `catalog` run on `main` finishes.

1. Read the run's verdict. On red, nothing reads the bucket yet, so fix forward in a follow-up PR.
   A red `catalog` run on `main` holds a release judgment until it is fixed, and that is accepted.
2. Run `node scripts/catalog/reference-check.mjs --catalog https://catalog.cairn.pub/index.json`
   from the main checkout and read line 6 of the acceptance list against it.
3. Record the real addresses and the run in the theme-garden record and in cairn-cms STATUS.

## Stops and standing answers

| Stop | Standing answer |
| --- | --- |
| Clock stop: a task past twice its estimate | With the cause traced and the rest in scope, reset `start=` once with `estimate=` the remaining work and record it in `## Decisions`. On a second stop on the same task, the conductor splits the rest into a follow-up task and records the call |
| Path ceiling | Go on while the cause is traced and actual minutes stay under 480 (twice the expected 240); record the overrun in the score. Past that, or on an untraced cause, the conductor asks with the trace and a recommendation |
| The proving run fails on a Cloudflare permission (a 403 from R2 or from `wrangler deploy`) | Never widen a token and never use another credential. Write the request, the response, and the token's name to STATUS and stop for the conductor, whose interactive session rescopes it |
| `wrangler deploy` rejects the recorded `routes` form | Use the other form pre-flight item 5 proved, and record it. If neither works, stop as in the row above |
| The proving run can't go green and the conductor can't clear the cause | Finish C1.9 and the Close on what is built. The PR stays draft, its body names acceptance lines 1 to 4 as unmet with the failing run, and the conductor sends Geoff a `decide` document |
| Auto mode denies an `npm install --save-dev` of one of the three packages | Stop for the conductor with the denial text. Never fetch the package another way |
| Two builds of an archive differ between the workstation and the runner | Trace the differing bytes and fix the builder. A looser comparison is never the answer. Not escalable |
| The card can't reach 100 KB at a quality that reads well | Lower the quality to 60 at most, then record the size and stop for the conductor, since the limit is the design's |
| A red on the fast lane or CI | Fix forward or revert. A known trap (`durable-gotchas.md`) reruns once. A red traced to executor reasoning moves the next task to `high` |
| The design's file needs a field the reference page can't be built without | Add it to the schema, record it in `## Decisions`, and list it in the PR. The design says the file changes before cairn.pub is built |
| A found item outside the task | `standards:log-issue`, tagged `#initiative:theme-garden`, listed in the PR |

**Not escalable**: create-only release paths, the index written last, the `--reset` guard, the
digest check, the fork skip, and `permissions: contents: read`.

## Planning misses at design

The temporary token (pre-flight item 2) is a step for Geoff that the design named only as "starts
in the workstation's secret store". It goes to him in the pre-launch packet.
