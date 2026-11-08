# cairn new: mechanisms spec

Initiative: cairn-setup
Design: `2026-11-08-cairn-new-design.md` (approved 2026-11-08, binding)
Plan: `../plans/2026-11-08-cairn-new-plan.md`
Base: cairn-cms `main` at `d27ea60b0`; cairn-pub `main` at `85c97cc`. Every `file:line` below is at
those commits. Revised by the review fold (`../plans/2026-11-08-cairn-new-review-fold.md`).

This spec states each mechanism the design names at the precision a builder needs, with its
source. It adds no behavior beyond what the fold record lists. Where the design left a value to the
builder, the spec says so and names the probe that settles it. A mark **(probe S1)** means the
recording sitting settles it; a mark **(builder)** means the task decides it and records the call in
its PR's `## Decisions`. Sections marked **Decide N** carry a finding that changes what the approved
design says; the plan builds the recommended answer only after Geoff rules (plan, "Rulings before
launch").

Sources are cited inline. "Spike CF" is `research/spike-cloudflare-oauth.md`; "spike GH" is
`research/spike-github-app.md`. "Recon CF/GH/core" are the `research/recon-*.md` files, which cite
the provider docs by URL.

## 1. Where the code lives

| Unit | Path | Note |
| --- | --- | --- |
| Planner, runner, events, record mapping | `tool/internal/setup/` | ADR-0001's spine rule: no printing, no prompts, injected clients (`tool/docs/adr/0001-the-spine-is-the-product.md:25-61`). |
| Loopback server, approval chain, browser opener | `tool/internal/setup/loopback/` | Owns the four callbacks, the `/next` route, and the two browser pages. |
| Scaffold (fetch, extract, substitute, commit) | `tool/internal/setup/scaffold/` | Pure file edits plus `git`; no `npm` here except the background install (section 9). |
| Provider writes | `tool/internal/providers/` | Same transport rules as today: one pinned host per client, no redirects followed, 15 s timeout, GET-only retry (`tool/internal/providers/transport.go:12-58,116`). |
| OAuth and key storage | `tool/internal/secrets/` | Keyring through the package-level `keyringGet`/`keyringSet`/`keyringDelete` vars (`tool/internal/secrets/keyring.go:21-26`). |
| Command and flags | `tool/cmd/cairn/new.go` and siblings | Thin view per ADR-0001; hidden until the switch pass (plan P6). |
| Agent view (NDJSON) | `tool/internal/setup/agentview/` | Writes events; never asks. |
| Terminal view (Bubble Tea) | `tool/internal/ui/newview/` | One model, components as plain structs (`standards:elm-conventions` Rule 1). |
| Recorded responses | `tool/testdata/fixtures/{cloudflare,github,npm}/` | Moved from `packages/create-cairn-site/fixtures/` (section 12). |
| Setup overlay | `scripts/build/setup-overlay/` | `deploy.yml`, the `pull_request`-only `check.yml`, and (P5) `.claude/settings.json` and `.mcp.json`; applied only to the engine tarball's `template/` (section 2). |

## 2. The template and its fetch

**Correction to the design (owed erratum E1).** The design says Waymark's template "lives in the
engine package today". It does not: `@glw907/cairn-cms`'s `files` lists `dist`, `migrations`,
`schema`, `skills`, `claude`, docs, and records, and no template (`package.json` "files"). The
template ships only in `create-cairn-site`'s gitignored `template/`
(`packages/create-cairn-site/.gitignore:1`), baked by the release workflow, since every pack and
publish there runs with `--ignore-scripts` (`.github/workflows/publish.yml:116-130,196,239,322`).

- **The pack.** One script, `scripts/build/pack-engine-template.mjs`, writes a root `template/`
  (gitignored by a new `/template/` line in the root `.gitignore`): `template/waymark/` is the
  composed tree (`composeTemplate`, bake plus the `template-repo` overlay,
  `packages/create-cairn-site/scripts/emit-template-dir.mjs:82-86`) plus the setup overlay, with the
  bake's `.gitignore` to `gitignore` rename kept, and `template/catalog.json`. The engine's
  `files` gains `template`. npm's docs: an ignore file "at the root of your package ... will not
  override the 'files' field, but in subdirectories it will"
  (<https://docs.npmjs.com/cli/v11/configuring-npm/package-json#files>), which is why the root `/template/` line does not drop the tree. The nested `.gitignore` is renamed
  to `gitignore` after composing, because "npm's packlist unconditionally drops any file literally
  named `.gitignore` ... wherever it sits in the tree" (`bake-template.mjs:324-330`; fix
  `26c4b66ff`); `composeTemplate` calls the plain `bake()` and the overlay appends to `.gitignore`
  (`emit-template-dir.mjs:51-63,82-86`), so the rename runs last. `publish.yml`'s "Pack the three tarballs" step and `npm run check:package` run the script
  before their `npm pack --ignore-scripts`. No root `prepack` is added. The bake script stays in
  `packages/create-cairn-site/scripts/` until P6 moves it, so its six callers do not move in P1.
- **The setup overlay** applies only here, never to the wizard's bake or to `templates/waymark/`
  (which also serves Cloudflare's Deploy button, `emit-template-dir.mjs:6-9`), so neither gains a
  `deploy.yml` that would fail with no `CLOUDFLARE_API_TOKEN`.
- `template/catalog.json`: `{ "themes": [ { "id": "waymark", "name": "Waymark", "description":
  "An intentionally neutral look that's easy to edit.", "path": "waymark" } ] }` (copy deck
  "questions"). The theme question appears only when `themes` has more than one entry.
- **Fetch.** `GET https://registry.npmjs.org/@glw907%2fcairn-cms` (`tool/internal/providers/npm.go:14,63`),
  take `dist-tags[<tag>]` (default `latest`, `--tag` for another), then `versions[v].dist.tarball`
  and `.dist.integrity`. Download from the same pinned host, verify the `sha512-` SRI digest before
  extracting, and extract only `package/template/**`: an entry whose path after the prefix fails
  `filepath.IsLocal` ("reports whether path, using lexical analysis only, has all of these
  properties", `go doc path/filepath.IsLocal`), or that is neither a regular file nor a directory,
  fails the fetch. A digest mismatch is a failure, never a retry. The record stores the resolved
  version and integrity, and a resume fetches exactly that version.
- **Pin.** The scaffold writes `@glw907/cairn-cms` at the exact fetched version into the site's
  `package.json` (today's emit writes `^<version>`).
- **Tests** read a packed local tarball through the npm client's RoundTripper seam (`npm.go:28`).
  The answer matrix rewrites the scaffold's two engine dependencies to `file:` tarballs after
  scaffolding, the pattern `create-site.yml:81-95` uses, because the exact pin is unpublished.

## 3. Names and the plan

`Plan(Answers)` is pure: the same answers give byte-identical plans (ADR-0001:36-61).

| Name | Derivation | Source |
| --- | --- | --- |
| slug | lowercase, runs of non-alphanumerics to `-`, trim dashes; ASCII only, so `Café` gives `caf` and a non-Latin name gives empty; empty is a validation error (copy task rewords it for a name with no Latin letters) | `packages/create-cairn-site/src/slug.mjs:16-19`; copy deck "questions" |
| base | slug truncated to 57 characters, trailing dash trimmed, so `<base>-media` fits R2's 63 | `cloudflare/config.mjs` `workerNameFor`; fix `83d395629` |
| repository, Worker | `<base>` | design "The summary" |
| database | `<base>-auth` | `templates/waymark/wrangler.jsonc` `database_name` pattern |
| bucket | `<base>-media` | same, `bucket_name` |
| GitHub App | `cairn-<base>` cut to 34 characters, trailing dash trimmed. GitHub: the name "cannot be longer than 34 characters", "must be unique across GitHub", and cannot match an existing account name other than your own (<https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app>). A taken name: **Decide 8**. | fix `c84be2e93` |
| address | the chosen zone's apex plus `www.<apex>`; a subdomain of the zone gets no `www` | design "The summary" |
| local folder | `./<repository>` in the directory `cairn new` ran in; an existing non-empty folder is refused in the opening, except the folder a resumed record names (section 4) | design "The watch plan" |

**Taken names (builder).** One suffix applies to the four names together (`<base>-2`, then `-3`).
The Cloudflare checks run after approval 1 (`GET /accounts/{id}/workers/scripts`, `GET
/accounts/{id}/d1/database?name=`, `GET /accounts/{id}/r2/buckets/{name}`; recon CF 4). The GitHub
free check before approval 3 is an unauthenticated `GET https://api.github.com/repos/{login}/{name}`,
which shows public names only; a private clash surfaces as `422` with `errors[].field == "name"` on
create (`github/repo.mjs:68`), takes the next suffix there, and reruns the Cloudflare name checks for
it before the chain continues. The summary states the reason for a suffix.

**Ownership (#367).** Before each create, the record stores the name about to be created (the
intent); the moment a create returns, it stores the id: D1 `uuid`, R2 bucket name, Worker tag after
the first deploy, the App id, the repository id, the installation id, the deploy key's token id. On
resume, a "name exists" for a recorded intent with no id reads the resource by exact name and
adopts it only when it is empty (D1 with no tables, a bucket with no objects, a repository with no
commits; builder confirms each read on the provider's reference), else stops with the four-part
failure naming it. A recorded id that differs from what the provider reports is never ours. The
`deployments list` cap and the clock window (`cloudflare/deploy.mjs:191,213,235-243,347-350`) are
not ported (BACKLOG #367, #381).

## 4. The record and resume

- The record is a site record in the existing store (`tool/internal/store/store.go:49,139,169`:
  `Open`, `Load`, `Save` with atomic rename and fsync), so `cairn sites` and `cairn health` see a
  finished site and load a record at every setup step.
- **Discriminator.** Setup's fields sit under one typed `setup` object holding the run id and a
  setup schema version. Resume candidates are only records that carry it, because the registry also
  holds wizard records (19 step strings, `tool/internal/spine/step.go:11-31`) and adopted ones
  (step `live`, `tool/internal/adopt/adopt.go:178`). A record whose schema version is newer than the
  tool's is refused with an upgrade message.
- Id: `<slug>-<6 hex>` (`packages/create-cairn-site/src/state.mjs:20`). The run's first save
  refuses an id the store already holds and draws a new suffix, since `Save` replaces silently
  (`store.go:164-168`).
- `step` reuses a `spine.Step` string where the meaning is the same (`app-created`, `repo-created`,
  `pushed`, `deployed`, `live`) and adds setup constants otherwise. `TestStepConstantsMatchNodeRecordSteps`
  (`spine/step_test.go:80-108`) requires the Go set to equal the wizard's literal set, so new
  constants either live outside `spine.allSteps` or the test gains a named setup-only set (builder).
- The record also holds the resolved engine version and integrity, the folder's absolute path, the
  local commit's SHA, and the name of every keyring entry before it is written. Resume treats the
  folder as its own only when its `HEAD` is the recorded SHA, and past `pushed` compares the remote
  ref instead of pushing again.
- No secret enters the record. `record_test.go:133-169` checks typed field names only, and
  `record.Record` carries untyped keys through `Extra` (`record/record.go:1-4`), so a value test
  marshals a fake run's record and fails on any credential the fakes issued or any `Extra` key setup
  wrote.
- **Resume.** One unfinished setup record resumes; several, the terminal view asks which and the
  agent lane needs `--resume <id>` (a usage error otherwise). **Decide 9** may add "Start a new
  site". Resume never keys on a directory (recon core 1: `findSiteByDir`).
- An App that exists without a finished install resumes at the install, for the same App: the App
  id, slug, and client id are in the record, and its key and client secret in the keyring from the
  moment the manifest converts.
- **One run at a time.** Every run, `--apply` included, binds `127.0.0.1:49152` at its start and
  holds it until exit. A bind failure stops in the opening, before any record write: "Port 49152
  is in use. Another setup may be running." The port is the client's registered redirect (plan
  pre-flight 1), so the any-port question in the design's "Left to the builder" is closed without a
  probe.

## 5. Credentials

| Credential | Holder | Lifetime | Deleted |
| --- | --- | --- | --- |
| Cloudflare OAuth access and refresh token | keyring, two entries per run | access 3600 s (spike CF) | revoked and deleted when setup finishes |
| GitHub user token (`ghu_`, refresh `ghr_`) | process memory only | 8 h (recon GH 2) | dropped at exit |
| GitHub App private key, client secret | keyring | until the key moves to the Worker secret | deleted when setup finishes |
| GitHub installation token (`ghs_`) | process memory only | 1 h | dropped |
| Deploy key (Cloudflare user token) | GitHub repository secret only | no expiry | never; it is the site's |
| Sign-in token | the D1 row's hash only | 10 min (`src/lib/auth/crypto.ts:68`) | consumed or expired |

- **Entries.** Every setup entry is named under `setup/<run id>/`, a prefix `cairn auth list` and
  `cairn auth unset` do not treat as theirs, and fits Windows' limit: go-keyring's Windows backend
  returns `ErrSetDataTooBig` when "password may not exceed 2560 bytes"
  (`go-keyring@v0.2.8/keyring_windows.go:28-30`), which `keyring.go` flattens to unavailable.
- **The opening** writes, reads, and deletes a throwaway entry with a deadline long enough for an
  unlock prompt, so a missing or locked keyring fails before anything exists.
- **At conversion** the key and secret are persisted before the record's step advances. A failed
  write stops with the four-part failure whose "already did" names the App and links its settings
  page for deletion (GitHub has no delete API, spike GH "Cleanup").
- **Refresh.** "Refresh works (200, returns a new pair) but REVOKES the previous access token"
  (spike CF, "Confirmed"). Setup writes the new pair before it uses either token. A failed write
  stops resumable. On resume, an `invalid_grant` or 401 from the stored pair reruns approval 1 alone,
  under its own waiting state (owed erratum E5), and refuses a grant whose account list lacks the
  recorded account id.
- **End and stop.** Done revokes and deletes every entry the record names, including one whose
  `Set` reported unavailable, since an abandoned keyring call can still land after its 2 s deadline
  (`keyring.go:59-62`). A failure or Ctrl+C keeps the entries for the resume, and the record says
  so (owed erratum E6).
- **Tests** swap the package vars at `keyring.go:21-26` for an in-memory map, never the real
  keyring; `TestKeyringLibraryOnlyInKeyringGo` (`keyring_test.go:308-345`) keeps `MockInit` out of
  any other file. The end-to-end binary is built with a test build tag (`go help buildconstraint`:
  "a condition under which a file should be included in the package") whose file binds those vars
  to a file store under a directory the harness names; a release build never sets the tag (owed
  erratum E4).
- **Child processes** (`git`, `npm`) get the parent environment minus every token variable
  (`CLOUDFLARE_API_TOKEN`, `CAIRN_*_TOKEN`, `GH_TOKEN`, `GITHUB_TOKEN`), with stdout and stderr
  captured, never passed to the terminal (BACKLOG #352; `cloudflare/exec.mjs:65` passes the whole
  environment today).
- **Never printed:** a token, a key, a sign-in link. `logx.New` takes its needles once, before any
  command runs (`tool/internal/logx/logx.go:1-5,46-59`), so logx gains a registration call the
  runner reaches through an injected sink the moment each credential arrives, guarded by a mutex
  because the views write from other goroutines; a PEM registers line by line, since logx cannot
  match a value with a newline (`logx.go:32-33`). The terminal view writes its frames to the raw
  terminal, not through the logx stream `main` wraps (`tool/cmd/cairn/main.go:50-56`), because logx
  holds output "until a newline" (`logx.go:27-30`) and an inline frame does not end on one; it
  renders only typed event fields, and the frame grep (plan T3.6) is the proof. ADR-0004 records it.

## 6. Cloudflare approval and API

**OAuth client.** A cairn-owned client in Geoff's account (plan pre-flight 1): public client,
authorization code with PKCE (S256), redirect `http://127.0.0.1:49152/cloudflare/callback`. The
client id is public and is a constant in the tool's source.

- Authorize: `https://dash.cloudflare.com/oauth2/auth?response_type=code&client_id=...&redirect_uri=...&scope=...&state=...&code_challenge=...&code_challenge_method=S256` (spike CF).
- Token: `POST https://dash.cloudflare.com/oauth2/token` with the verifier; answers
  `access_token, expires_in, refresh_token, scope, token_type`.
- Revoke: `POST https://dash.cloudflare.com/oauth2/revoke` answered 403 from Python urllib,
  "possibly a user-agent block" (spike CF) **(probe S1)**. If it cannot work, setup deletes the
  keyring entries and the done screen says nothing about revocation (BACKLOG #354).

**Hosts per client** (each pinned, refused before dialing otherwise): Cloudflare API
`api.cloudflare.com`; Cloudflare OAuth `dash.cloudflare.com`; GitHub `api.github.com` and
`github.com`; npm `registry.npmjs.org`; the HTTPS wait's own client, pinned to the site's address.

**Scopes requested** (builder may add one only on a recorded 403, within the registered set):
`user-details.read`, `account-settings.read`, `zone.read`, `dns.write`, `workers-scripts.edit`,
`workers-routes.write`, `d1.write`, `workers-r2.write`, `email-sending.write`,
`user-api-tokens.write`, `offline_access`. The registration keeps spike CF's full set (adds
`zone.write`, `workers-ci.write`), so a later scope needs no dashboard visit.

**Granted-scope check.** A token response whose `scope` lacks `user-api-tokens.write` sends the tab to
`error.html`, and Try again re-consents (copy deck "error.html").

**Calls** (wizard paths in `packages/create-cairn-site/src/cloudflare/api.mjs` where it has them):

| Purpose | Call | Source |
| --- | --- | --- |
| Accounts | `GET /accounts` | recon CF 4 |
| Owner email | `GET /user` (`email`) | spike CF |
| Active zones | `GET /zones?account.id=...&status=active` | `api.mjs:500` lists by `name`; the filter is recon CF 4 |
| Address check | `GET /zones/{id}/dns_records?name=<host>` for the address and `www`; also `GET /accounts/{id}/workers/domains` filtered by hostname (`api.mjs:525`) and `GET /zones/{id}/workers/routes` (builder quotes the reference); any match refuses the address | design "Claude's calls"; `api.mjs:510` lists all records |
| Name checks | section 3 | recon CF 4 |
| Workers Paid | `GET /accounts/{id}/subscriptions` answered code 10000 to every token so far (cloudflare-estate-inventory.md) **(probe S1 with the OAuth token)**; the signal rule is **Decide 3** | design "Left to the builder" |
| Database | `POST /accounts/{id}/d1/database {name}`, keep `uuid` | builder, D1 API reference |
| Bucket | `POST /accounts/{id}/r2/buckets {name}` | builder, R2 API reference |
| Email | `GET` then `POST /zones/{zone_id}/email/sending/subdomains {name}` | `api.mjs:529,535`; read before write |
| Deploy key | `GET /user/tokens/permission_groups`, then `POST /user/tokens` named with the run id, Workers Scripts, D1, and R2 write at `com.cloudflare.api.account.<id>`, no `expires_on`; on resume before step 5 completes, delete the recorded token id and any token named with the run id (`DELETE /user/tokens/{id}`, spike CF), then mint again | spike CF; recon CF 2 |
| Worker secret | `PUT /accounts/{id}/workers/scripts/{name}/secrets {name: "GITHUB_APP_PRIVATE_KEY_B64", text, type: "secret_text"}` after the first deploy creates the Worker | `templates/waymark/.dev.vars.example`; spike CF |
| Custom domains | `PUT /accounts/{id}/workers/domains {hostname, zone_id, service}` per hostname, after the step-7 recheck of the address check | `api.mjs:514`; recon CF 1 |
| HTTPS wait | `https://<address>/` answers 200 and `/admin` answers 303 to `/admin/login`, polled to 15 minutes | `cloudflare/hostname.mjs`; design limits table |
| Sign-in rows | `POST /accounts/{id}/d1/database/{uuid}/query` | section 10 |

Step 4 rechecks that no Worker of the name exists before the push that triggers the first deploy,
and stops with the four-part failure if one does.

**Minted tokens (owed erratum E3).** The only minted token is the deploy key. The design's
"short-lived, narrow Cloudflare tokens ... wrangler takes them" has no consumer once wrangler runs
only in Actions with the deploy key, so none is minted.

**Subdomain depth (builder).** Whether a Worker custom domain gets a certificate below one level,
and whether sign-in mail sends from the zone or the subdomain, are settled from Cloudflare's docs.
An address setup cannot serve is refused on the summary with the copy deck's address error pattern.

## 7. GitHub approvals

All four approvals run in one tab served from `http://127.0.0.1:49152`. Each callback answers the
browser at once and does its API work after (recon GH 1).

**Manifest** (spike GH `server2.mjs:20-25`):

```json
{
  "name": "cairn-<base, cut to fit 34>",
  "url": "https://cairn.pub",
  "redirect_url": "http://127.0.0.1:49152/github/manifest",
  "callback_urls": ["http://127.0.0.1:49152/github/callback"],
  "hook_attributes": { "url": "https://cairn.pub", "active": false },
  "request_oauth_on_install": true,
  "public": false,
  "default_permissions": {
    "administration": "write", "contents": "write", "metadata": "read",
    "workflows": "write", "secrets": "write"
  },
  "default_events": []
}
```

`hook_attributes.url` is required (recon GH 1). The first callback URL carries the real port,
because the install redirect uses it verbatim (recon GH 2). **Decide 3** may add `actions: read`.

The chain:

1. **Create.** The loopback `/` auto-submits the manifest to
   `https://github.com/settings/apps/new?state=<nonce>`. `/github/manifest` checks `state`, then `POST
   https://api.github.com/app-manifests/{code}/conversions` (201: `id, slug, client_id,
   client_secret, pem, owner`) within the hour (recon GH 2). The record gets the App's id, slug, and
   client id and the keyring the key and secret (section 5) before the tab moves on; the slug comes
   from the conversion, never from the manifest. Then `302` to
   `https://github.com/apps/<slug>/installations/new`.
2. **Install & Authorize** (all repositories). The callback carries `code`, `installation_id`,
   `setup_action=install` (spike GH); GitHub's manifest docs make `state` optional on redirect
   (recon GH 75), so whether the install callbacks carry it is recorded at S1 and the read-back in
   step 3 is what authenticates the result. The record stores `installation_id` before any other
   call. Exchange `POST https://github.com/login/oauth/access_token` (`bad_verification_code` or a
   missing `access_token` fails, `github/oauth.mjs:29-52`). With the user token, `POST /user/repos
   {name, private: true, auto_init: false}`; `422` on `name` takes the next suffix (section 3). Then
   `DELETE /app/installations/{installation_id}` with the App JWT (RS256, `iat` now-60, `exp`
   now+540; `github/jwt.mjs`). Then `302` to
   `https://github.com/apps/<slug>/installations/new/permissions?suggested_target_id=<user id>&repository_ids[]=<repo id>`.
3. **Approve, Install & Authorize** (only the repository). The code exchanges for a user token; `GET
   /user/installations` finds the installation whose `app_id` is the record's App id (the list also
   holds other Apps' installations, such as the Cloudflare Workers and Pages App), and `GET
   /user/installations/{id}/repositories` (paged by 100, fix `821844180`) must list exactly the new
   repository with `repository_selection == "selected"`. Anything else deletes that installation and
   resends the tab to the preselect URL (spike GH "Caveat"). Then the tab shows `done.html`.

**Over-grant on every exit.** A non-selected installation is deleted on every exit path of the
chain: an error, Ctrl+C, and the 30-minute stop. On resume, and in any run whose record holds an App
id, the first GitHub act is the App JWT's `GET /app/installations` (today's `findInstallation`; "a
private App has at most its owner's", recon GH 28,89), deleting every installation whose
`repository_selection` is `all` or whose list is not exactly the recorded repository.

**After the chain:** `POST /app/installations/{id}/access_tokens` (JWT) mints the installation
token that pushes and stores the deploy key.

- **Push** (watch step 4): the scaffold runs `git init -b <default_branch>` with the create
  response's `default_branch`, since `auto_init: false` leaves no branch until the first push.
  `origin` is `https://github.com/<login>/<repo>.git`. The token reaches git through
  `GIT_CONFIG_COUNT`, `GIT_CONFIG_KEY_<n>`, `GIT_CONFIG_VALUE_<n>` with an
  `http.https://github.com/.extraheader`, never argv or `.git/config`. git-config(1): "If
  GIT_CONFIG_COUNT is set to a positive number, all environment pairs GIT_CONFIG_KEY_<n> and
  GIT_CONFIG_VALUE_<n> up to that number will be added ... The config pairs are zero-indexed." Setup
  appends its pairs after any inherited count, so the harness's pairs survive (section 13).
- **Deploy key** (watch step 5): `GET /repos/{o}/{r}/actions/secrets/public-key` (`key_id, key`),
  seal with `golang.org/x/crypto/nacl/box.SealAnonymous`, `PUT
  /repos/{o}/{r}/actions/secrets/CLOUDFLARE_API_TOKEN {encrypted_value, key_id}` (builder quotes the
  REST page). The secret name is one Go constant that the `deploy.yml` test (section 9) reads.
  `golang.org/x/crypto` is a new direct require: ADR-0003 records it and `purity_test.go:184`'s
  `otherDirectRequires` moves with it.
- **Personal accounts only.** The manifest posts to the user path (design "Non-goals").

**30-minute limit.** The chain's clock starts when the tab opens and stops at `done.html`. At 25
minutes the views show the countdown. At 30, setup stops: nothing exists outside the completed
approvals (after the over-grant deletion), and the rerun resumes.

## 8. The opening and the browser

Order: welcome; the SSH or remote stop; the questions; the prerequisite checks that need no account
(git present, Node 24 or later, port 49152 bindable and bound, the keyring probe, the npm fetch, the
folder free); "Press Enter to open your browser"; approval 1; the Cloudflare checks (accounts,
active zones, Workers Paid probe, names, the address default); the account question (several
accounts only) and domain question (several active zones only); approvals 2 to 4; the summary; one
Enter. Every check here fails before any provider write, and each failure's messages-table entry
carries a section anchor in `docs/admin/before-you-start.md`, resolved by a Go test against the
page's headings (plan T5.2). `scripts/checks/shipped-anchors.json` cannot hold them yet:
`checkShippedAnchors` accepts only `is-it-working.md` (`scripts/checks/check-readiness.mjs:27,146-166`).

- **SSH or remote** (builder): `SSH_CONNECTION` or `SSH_TTY` set; or, on Linux with `$BROWSER`
  unset, neither `DISPLAY` nor `WAYLAND_DISPLAY` set (recon core 3). macOS never stops on `DISPLAY`.
  The stop screen is "welcome-ssh".
- **Opener**: Linux `xdg-open`, macOS `open`, Windows `rundll32 url.dll,FileProtocolHandler <url>`,
  which keeps a `&` (BACKLOG #338). `$BROWSER`, when set, wins. The opener runs detached with its
  standard streams closed and a timeout (recon core 3). A missing or failing launcher is reported
  beside the fallback link (BACKLOG #363).
- **Loopback**: `127.0.0.1` only; `Host` must be `127.0.0.1`, `localhost`, or `[::1]` with the
  port, else 403 (`loopback-core.mjs:21-30,66-70`, fix `4deda84eb`); one state nonce per approval; a
  path nobody waits on answers 404.

## 9. Scaffold and deploy files

Substitutions, each fail-loud on a missing anchor (`substitute.mjs`):

| File | Edit | Source |
| --- | --- | --- |
| `package.json` | `name` = repository; engine pinned to the fetched version | `scaffold.mjs` |
| `src/theme/site.config.yaml` | `siteName`; the duplicate-`description:` guard kept | `substitute.mjs`; fix `7878c2fea` |
| `src/theme/cairn.config.ts` | `aiPosture` block for decline/invite | `substitute.mjs:280-291` |
| `src/theme/cairn.config.ts` | the `createGithubApp({ owner, repo, branch, appId, installationId })` literal with real values and the repository's real default branch | `github/finalize.mjs:21-32` (its hard-coded `'main'` is not ported) |
| `src/theme/cairn.config.ts` | `email: { from }` | `cloudflare/config.mjs` `writeEmailFrom` |
| `wrangler.jsonc` | Worker `name`, `database_name` and the real `database_id`, `bucket_name`, `vars.PUBLIC_ORIGIN = https://<address>`; `account_id` inserted after the top-level `name`, which the template lacks (`templates/waymark/wrangler.jsonc:4`) | `config.mjs` `nameWranglerResources`, `writePublicOrigin` |
| `.github/workflows/deploy.yml` | the push branch filter = the default branch | section 7 |
| `src/content/.cairn/site-facts.json` | regenerated after the posture edit: keys `version, mediaBucketBinding, roles, aiPosture`, absent keys omitted, trailing newline | BACKLOG #365; `src/lib/vite/internal.ts:665-676` |
| `.gitignore` | restored from `gitignore` | `scaffold.mjs:48-66` |

"Block AI training" is `decline`, "Allow AI training" is `invite`; `none` is never written.

**Deploy workflow** (setup overlay `deploy.yml`): on push to the default branch; `concurrency: {
group: deploy, cancel-in-progress: true }`; checkout, setup-node 24, `npm install`, `npm run check`,
`npm run build`, `npx wrangler d1 migrations apply AUTH_DB --remote`, `npx wrangler deploy`, with
`CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}`. The overlay's `check.yml` runs on
`pull_request` only. Action pins follow `check.yml`. A Go test parses both emitted workflows and
asserts these properties against the runner's secret-name constant, and actionlint runs over them.

**Background install**: while step 6 runs, `npm install` runs in the folder with the scrubbed
environment and captured output. A failure is a done-screen next step, never a setup failure.

## 10. The sign-in

The engine's facts:

- A request-action token is bound to the requesting browser's nonce; the request action "always
  passes one" (`src/lib/auth/store.ts:90-94`). Consume requires `nonce_hash IS NULL OR nonce_hash =
  ?` (`store.ts:208`). `issueToken` replaces the email's prior token and sweeps expired rows in one
  batch (`store.ts:104-113`).
- Inside the 60 s send cooldown (`crypto.ts:74`), a second request for the same email sends nothing
  and rebinds the live row to the new browser (`auth-routes.ts:271-293`, `rebindToken` at
  `store.ts:159`); outside it, a request mints a new token. A link opened in a browser without the
  matching nonce is not consumed: with no pending cookie it falls through to the no-pending-request
  redirect, and with a wrong nonce it reads as expired (`auth-routes.ts:366-370,379-385`).
- `GET /admin/auth/confirm` "Renders the confirm page and consumes nothing; only the POST verifies"
  (`auth-routes.ts:341-347`). An unbound row confirms without the pending cookie
  (`auth-routes.ts:379-385`).
- Token format, as the wizard's seed and the engine write it: the token is 32 random bytes as
  base64url; the stored `token_hash` is the lowercase hex SHA-256 of that token string
  (`cloudflare/bootstrap.mjs:93-94`; `hashToken`, `crypto.ts:115`); the owner row has role `owner`
  and a normalized email.

Setup's sign-in (watch step 8), through the D1 query API, as one batch mirroring the wizard's three
statements (`bootstrap.mjs:87-120`) and `issueToken`'s sweep: insert the owner (role `owner`) only
when `editor` is empty; delete the email's rows and every expired row; insert an unbound
`magic_token` row expiring in 10 minutes, only for an address the editor table holds (the wizard's
`WHERE EXISTS` guard, `bootstrap.mjs:105-107`). A Go test checks the hash against a fixed vector the
engine's `hashToken` produces, and another checks the statements' column names against
`migrations/*.sql`. The done page learns the URL through one loopback route, `/next`, which
`done.html` polls: it answers 204 until the URL is ready, then answers once, only to a request
carrying a cookie the loopback set on `/`, and 404s after. The tab goes to
`https://<address>/admin/auth/confirm?token=<t>`. The token is never printed, logged, or put in an
event. Step 8 finishes when a D1 read shows the row gone or at its expiry. In the agent lane the
`--plan` process and its tab are gone, so step 8 skips the redirect and the email is the path.

**Decide 1 (the confirm click).** The redirect lands on the confirm page, which takes one click,
because GET consumes nothing by design. The design says the tab "redirects through it at once,
signed in". Recommendation: keep the engine, accept the click, and change step 8's watch sentence
and `done.html`'s footer to name it. The done screen says "You're signed in" only when the D1 read
shows the token consumed, and otherwise "Your site is open in the setup tab. Select Sign in there,
or use the link in your email." (register-checked in the plan's copy task).

**Decide 2 (the sign-in email).** The design has setup "ask the live site to send its ordinary
sign-in email". A request from setup binds that token to setup's nonce, so a plain click in the
owner's browser does not sign in (section 10's facts); the link works there only if the owner first submits the sign-in
form for that address from the same browser within 60 seconds of setup's request, which rebinds it.
An owner reading mail later gets a dead link and must request a new one. Recommendation: setup
writes a second unbound row and sends the email itself through Email Sending (`POST
/accounts/{id}/email/sending/send`, `api.mjs:543`; scope `email-sending.write`), with the link and a
line to request a new link from the sign-in page if it has expired. It sends when the redirect's
token is consumed or expires, whichever comes first, and at once in the agent lane. The engine's
auth code stays unchanged; the emailed row is unbound, the same path the engine keeps for a
hand-seeded row. The alternative is to drop the email and change the done screen's second sentence.

## 11. Events, exit codes, and the agent lane

- Event kinds: `step_started`, `step_done`, `step_failed`, `waiting`, `resumed`, `summary`. Every
  line carries `schemaVersion`, `kind`, and a timestamp; a stream without a `summary` is unfinished
  (`tool/cmd/cairn/messages.go:197-257`). Field names and the schema command's name are the
  builder's; the schema goes in `schema/`, validated by a test like
  `tool/internal/render/json_schema_test.go`.
- `waiting` names one state per approval, plus one for a resume's Cloudflare re-consent (section
  5), and carries the copy deck's sentence for it. It carries no token, code, or key.
- Exit codes (builder): a table in `cairn help agents` (`agentsPage`, `messages.go:197`), shown
  only once `cairn new` is. A usage error keeps today's contract: it "exits 3 and writes nothing to
  stdout".
- `--plan plan.json` runs the flag questions and the four approvals and writes the run id, every
  derived name, the account's domains when there are several, and the email; nothing exists on
  Cloudflare yet. The file is written 0600 and holds no credential. `--apply plan.json` is the
  summary's Enter: it loads the record named by the run id, takes from the file only the open fields
  (email, address, and the account and zone from the listed options), recomputes every derived name
  from the record, reruns the free checks and the address check, and refuses an edited closed field,
  an invalid email, or an open choice left open with a usage error that names it.
- **The dry run is `--dry-run --json`** (no file, no approvals). The design's `--plan --json`
  cannot parse beside `--plan <file>`: probed on pflag v1.0.10, a string `--plan` takes `--json` as
  its value, and with `NoOptDefVal` set `--plan plan.json` sets `"-"` and strands `plan.json` (owed
  erratum E2).
- Run without a terminal and without a plan, `cairn new` prints the agent guide.

## 12. Recorded responses

The corpus rule: "Every provider route the Go tool reads has a body here recorded from a live
call" (`packages/create-cairn-site/fixtures/README.md`). ADR-0003 extends it to the write routes.
The corpus moves to `tool/testdata/fixtures/`, as `tool/internal/providers/corpus.go:14` foresees;
its hygiene test (`packages/create-cairn-site/test/fixtures-hygiene.test.mjs`) moves beside it.
Hygiene stays: no email, ray id, account id, zone id, or Worker name; every token-shaped value is a
fixed placeholder; the conversion fixture's PEM is a committed test-only key, which the hygiene test
asserts.

**The recorder** (plan T1.0) runs once in sitting S1, in Geoff's terminal, from the P1 worktree's
absolute path:

- `record.sh` sources `~/.local/secrets` in a subshell and starts node under `env -i` with only
  `PATH`, `HOME`, and `GITHUB_TEST_LOGIN`, `GITHUB_TEST_PASSWORD`, `GITHUB_TEST_TOTP_SECRET`,
  `GITHUB_TEST_TOKEN`; it fails naming a missing one, never printing a value.
- **Cloudflare** consent opens Geoff's Chromium once; the recorder's callback ends the tab and never
  redirects to `github.com`. Every Cloudflare write is refused unless its path carries the
  `carin-test.org` zone id or a name carrying the run id. The minted token takes `expires_on` one
  hour out in recording mode.
- **GitHub** runs through the gate's Playwright driver (`scripts/gate/browser.mjs`) as
  `glw907-test`: before any GitHub write, `GET /user` must answer `glw907-test`. Installation routes
  are called only with the JWT of the App the run created, so the Workers and Pages installation on
  `glw907-test` is never touched (test-accounts.md "Cloudflare"). The sealed-secret PUT carries a
  dummy value.
- **Ledger and cleanup.** Every id is written to a 0600 ledger outside the repository before its
  create. The run ends by deleting what it made (database, bucket, minted token,
  repository by `GITHUB_TEST_TOKEN`, App through its settings page) and verifying each delete by a
  read; `record.sh --cleanup <run id>` sweeps from the ledger after a crash. A results file lists
  each resource's outcome, each probe's outcome (revoke, subscriptions, whether the install
  callbacks carry `state`), and each route's latency against the 15 s timeout.
- **Scrub.** The recorder scrubs by key name and by exact value (every credential it handled is a
  needle), then greps the staged corpus for each held value.
- **Output** goes to a staging directory outside the worktree,
  `~/.local/state/cairn-setup-s1/<run id>/`. The executor copies it in, runs the hygiene test, and
  commits.
- **Not recordable in S1**, each taking a docs-sourced body with `provenance.note: "pending live
  recording"` that the release's real-account leg records: the Email Sending onboarding POST
  (`carin-test.org` is already onboarded, test-accounts.md:69), "zone pending" (none is), a
  missing-scope 403 (a second consent), the Worker-secret PUT and the custom-domain PUT (each needs a
  deployed Worker), Decide 2's Email Sending send (an unverified destination fails as
  `E_SENDER_NOT_VERIFIED`, durable gotchas), and Decide 3's Actions run read.

## 13. The end-to-end harness

The design's "every pull request runs `cairn new` from the built binary" needs a way to point the
binary at fakes, and the providers have no base-URL override by design
(`tool/internal/providers/cloudflare.go:15-19`). The harness uses the standard environment:

- `HTTPS_PROXY` to a test proxy that terminates TLS for the pinned hosts and the test address with
  a test CA, read through `SSL_CERT_FILE`. The providers send through `http.DefaultTransport` when
  given a nil RoundTripper (`transport.go:35-38`), which reads the proxy from the environment; Go
  reads `SSL_CERT_FILE` on Unix other than macOS (crypto/x509 docs). ADR-0003 quotes both. The proxy
  refuses `CONNECT` to any host it does not fake. The harness runs on the Linux CI leg only.
- `BROWSER` names a test helper that walks the chain, following redirects through the fake
  `dash.cloudflare.com` and `github.com`. With `$BROWSER` set, the no-display stop does not fire.
- `GIT_CONFIG_COUNT` with `url.<local bare repo>.insteadOf https://github.com/`, which setup's
  appended pairs keep (section 7).
- PATH stubs for `node` (reports v24) and `npm` (logs and exits 0).
- The test build tag's keyring file store (section 5), under the case's temp directory.
- Cases run serially, since every run holds port 49152.

## 14. cairn-pub

cairn.pub pins `@glw907/cairn-cms@0.94.0-rc.1` (`cairn-pub/package.json:15`) and its loader reads
the arms `guides`, `reference`, `explanation` (`src/lib/docs/loader.ts:24-28`), a layout the engine
removed (`7c4c51c52`). The engine's docs are now `docs/admin/` and `docs/editors/`, and the published
`0.99.0-rc.4` (dist-tag `next`) ships both. cairn.pub has no `/start` or `/deploys` page. **Decide
4** carries the scope question.

Markdown copies: each docs page's source is served at its route plus `.md`, prerendered, as
`text/markdown; charset=utf-8`, with a first line naming the engine version (from
`resolveCorpus().version`, `src/lib/docs/corpus.ts:21-28`). `/deploys` waits for the pin that ships
`docs/admin/deploys.md`, since a prerendered redirect to a missing page fails the build.
