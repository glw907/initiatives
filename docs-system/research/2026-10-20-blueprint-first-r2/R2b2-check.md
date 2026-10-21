# R2b2 second read: does the excerpt lack part of the claim?

Judged on the full `drafter excerpt` output for each fact, from the cairn-cms worktree `blueprint-first-pages`.

| fact | answer | the part missing, or the lines that show it |
|---|---|---|
| f:n0fg3w | shows | `scripts/build/emit-template.mjs` lines 173-186: `regenerateWorkerTypes(tree, extraArgs = [])` runs `['types', ...extraArgs, '--include-runtime=false']`. Lines 188-207: `writeTypegenScript` reads the `.d.ts` second line (`running \`(wrangler types ...)\``) into `pkg.scripts['cf-typegen']`, and the docstring says "bake and the composed template differ: only the template carries the `.dev.vars.example` that `--env-file` names". Lines 231-251: the bake calls `regenerateWorkerTypes(to);` with no extra args. `emit-template-dir.mjs` lines 64-84: `SECRET_NAMES_ARGS = ['--env-file=.dev.vars.example']` ("The bake's own regeneration has no such file to read"); lines 76-96: `regenerateWorkerTypes(scratch, SECRET_NAMES_ARGS)`. `templates/waymark/package.json` lines 1-58: `"cf-typegen": "wrangler types --env-file=.dev.vars.example --include-runtime=false"`. Residual: no block in this excerpt prints the scaffold's literal `wrangler types --include-runtime=false`; it follows from the empty arg list and the same argument order the template's script shows. Contestable, but every named part has a line. |
| f:1dhk1a | lacks | The install routes (`go install .../cmd/cairn@latest`, a release archive). `tool/go.mod` shows the separate module; `tool/README.md` is "no excerpt: prose". |
| f:3z1uxv | lacks | "holds no `src/access.ts`": no directory listing in any block. The showcase `access: defineAccess(...)` and the waymark adapter without `access` are shown. |
| f:4xrx5f | lacks | "Earlier versions took optional `roles` and `access` options and resolved a bare `createAuthGuard()`": nothing in the two guard.ts blocks about earlier versions. |
| f:5iqvmt | lacks | That a cookie-less confirm passes NULL: the caller is not shown. `nonceHash: string \| null = null` and `nonce_hash IS NULL OR ...` are shown. |
| f:69xbyh | lacks | The `opts.ip` half ("from `CF-Connecting-IP`, never a forwardable header"): only lines 1-8 of turnstile.ts. Also the list of failure modes beyond "every failure mode". |
| f:6oopkt | lacks | That `config.media-bucket`, `auth.role-wiring`, and `ai.posture-effective` are the checks that read site-facts.json and report the message. facts.go says only "every check backed by site-facts.json". |
| f:7cv105 | lacks | "Earlier versions took optional `access` and `roles` options of their own": not in either handle.ts block. The required `runtime`, `access ?? {}`, and roles-not-read parts are shown. |
| f:8ciz2s | lacks | The members of the fixed screens (`media`, `vocabulary`, `nav`, `settings`): `ACCESS_FIXED_SCREENS = FIXED_SCREEN_IDS` with no definition shown. |
| f:bw5uk0 | lacks | The absence claim: the bodies of the eleven doctor checks and the whole health check set are not shown, only the doctor check list, condition.go, and three health files. "auth.role-wiring-missing is the one auth-family condition doctor still raises" is also not shown. |
| f:cvzb8z | lacks | "Earlier versions took the guard's map as its own `access` option ... left every engine screen open": nothing about earlier versions in any of the six blocks. |
| f:ditn3e | lacks | `ChannelStatementLike` (bind/first/run) and `ChannelSessionLike` (prepare/batch) are not shown, only `prepare` and `withSession` on `ChannelDatabaseLike`; `AuthChannel.revokeSessions` taking the type is not shown. |
| f:ez788q | lacks | "`lookup`'s subject must be stable and canonical per person" (the lookup doc says only "Normalized contact to subject id, or null"); "`challenge` must actually verify a human / cannot distinguish a real Turnstile call from `async () => true`" (the doc says "most load-bearing ... cannot itself verify", no `async () => true`). |
| f:f21bcz | lacks | "Earlier versions took optional `roles` and `access` options and a bare `createAuthGuard()` was valid": not in the four blocks. |
| f:gepykz | lacks | "The showcase copy is byte-identical" to the engine's `migrations/0001_roles.sql` (no comparison shown). The four-file list and the 0002 header are shown (test lines 'emits exactly the migrations 0000, 0001, 0003, and 0004'); `templates/waymark/migrations/` is "no excerpt: directory". |
| f:gubeex | lacks | The logout body: no `cookies.delete` and no destroy of one session row (the createAuthChannel block ends before it; only `logSessionDestroyed` mentions "the member's logout"). |
| f:iwf4nu | lacks | "Earlier versions took the map as a separate `access` option on the guard": not shown. |
| f:l2xruc | lacks | That under workerd `new DatabaseSync(':memory:')` throws `Illegal constructor`: the spec block is "no excerpt: prose". `channel-db.ts` shows the `node:sqlite` import only. |
| f:mfmmof | lacks | The absence over every toolkit component (no session / `locals.cairnEditor` read): only the barrel `index.ts` and one MediaPicker line are shown, not the other components' source. |
| f:mou1li | lacks | That it runs at module evaluation, at most once per isolate: the doc says only "once at composition (server start)"; the composition call site (module scope) is not shown. |
| f:nj0nfm | lacks | The `/admin/editors` path and the "Add editor" label: neither appears. `editorAddAction` (name, email, role, `editor.added`, no mail send) is shown. |
| f:nls26c | lacks | "earlier versions of it named `GITHUB_APP_ID` / `GITHUB_APP_INSTALLATION_ID`": no earlier-version text in any block. |
| f:pa2hqh | lacks | That a lossy `normalize` shares one identity's rate budget, and that `challenge` is "the whole economic bound on guessing a code": the docs say only "idempotent/canonical/injective" and "most load-bearing". `lookup`'s obligation is not shown either. |
| f:pe4vuc | lacks | The local-`Env` half: that a module's own local `Env` interface never types the `cloudflare:workers` export, and a secret read from it typechecks only once the generated file names it. app.d.ts says only that `cloudflare:workers` types its `env` with the generated `Env`. |
| f:pfy9cw | lacks | `admin.action.misconfigured` carrying `path` and `reason`: the `misconfigured(detail, reason)` block is cut off before its log call. The other four events' fields are shown. |
| f:q07rd5 | lacks | The tutorial's adapter path (`src/lib/cairn.config.ts`), its bare hook calls, and "no `src/access.ts`": the tutorial page is "no excerpt: prose". |
| f:qlgggh | lacks | The scaffold's root and `src` listing (root files, `.claude/` contents, `src` members): `templates/waymark/` is "no excerpt: directory". |
| f:qqy4uq | lacks | That `/auth-channel` is for a group the owner/editor sign-in was never meant to model (members, customers), and that the magic link stays the documented editor path: those are in `docs/reference/auth-channel.md`, "no excerpt: prose". |
| f:u78zg6 | lacks | "Earlier versions ... `devBackendHandle({ access })`; that option is gone": not shown. |
| f:wu8x70 | lacks | That `request`, `confirm`, and `logout` each call `assertOriginAndScheme`: only the helper is shown, whose doc says "Step 1 of every action" without naming the three actions or any call site. Close call: the generic "every action" comment is the nearest line. |
| f:xffr6i | lacks | The four routed statements (`insertEditor`, both `setEditorRole` branches, `demoteOwnerIfNotLast`), `insertOwnerIfEmpty` unrouted, and "No tool check raises it": the call sites are not shown, only `runRoleWrite`. |
| f:zxdoaf | lacks | That magic-link owner/editor is the default "so a content site runs with zero config": the source doc is "no excerpt: prose"; `env.ts` shows `AUTH_DB` only. |
| f:2pv4r5 | lacks | That an externalized copy makes `/admin` answer 500, and that the scaffold's `vite.config.ts` carries the entry (only the showcase's `ssr.noExternal` and the "scheme Node's own loader rejects" comment are shown). |
| f:47v0r9 | lacks | That the root `package` script builds the dev package after `svelte-package` and the release job installs (which builds) before publishing: no root scripts and no workflow in any block. `files`, `exports`, and no `svelte` condition are shown. |
| f:4lcto0 | lacks | The failure itself ("Cannot find name 'process'" on a fresh `sv create` scaffold) and the `/// <reference types="node" />` line: only the template's `@types/node` and `types` array are shown. |
| f:6ebew3 | lacks | The defaults (`/<id>/:slug`, `/:slug` for pages, `datePrefix` `day`): the block is only `defineConcept` up to `validateUrlPolicy`. |
| f:75hawi | lacks | The GitHub account requirement, the free tier for bare SvelteKit, Workers Paid tied to a second person's sign-in, and a domain zone for mail. Node >=24 and the Workers Paid consent text are shown. |
| f:7dtrwy | lacks | "Contents write" on the installation token, the `.pem`, and "never in a tracked file": `env.ts` and `signing.ts` show the base64 secret name and the JWT/installation-token exchange only. |
| f:9yi7fu | lacks | That the App's name and homepage are cosmetic and never read: no grep result or reader code shown. The author-is-editor, committer-omitted part is shown (repo.ts docstring). |
| f:c4nnu9 | lacks | The surface test holding `docs/reference/public-css.md` to the file: the test file is not shown, and the `SUBPATH_EXCLUSIONS` reason is cut off at "its reference page,". The CSS contents and the exclusion entry are shown. |
| f:e5vm42 | lacks | The D1 database id coming from `wrangler d1 create` output, and the order (bindings/secret last): not shown. The App identity (appId, installationId) and the key secret are shown. |
| f:f2vudv | lacks | That `bootstrapOwner` does nothing while the dev backend is active: only the identity-mode inertness is shown. The empty-allowlist insert and `editor.bootstrapped` log are shown. |
| f:fekvhi | lacks | That the reference's worked hook reads the binding as `AUDIT_DB`, and that `0002_audit.sql` is applied to that database: the reference page is not shown. |
| f:gj96px | lacks | The seeds (14 posts, two pages, one fragment, file names) and the frontmatter keys: `templates/waymark/src/content/` is "no excerpt: directory". Only the three `dir` values are shown. |
| f:hft8s8 | lacks | That `0000_auth.sql` and `0004` are "the two migrations every site applies", and that `nonce_hash` binds a token to the browser: store.ts shows only the named-error rethrow. |
| f:if45on | lacks | `npx wrangler d1 create <name>` and `migrations_dir`: external CLI mechanics, not shown. `requireDb` and the `AUTH_DB` binding are shown. |
| f:m0ouh8 | lacks | "No command checks the GitHub App" and the other eleven doctor checks: only `check_bindings.go` is shown (EMAIL and AUTH_DB confirmed there). |
| f:p1v88s | lacks | That `DevBackendConfig.seedContent` is gone: an absence, not shown. `content?: 'repository' \| 'fixtures'`, the default `'repository'`, and seeds only in fixtures mode are shown. |
| f:pg2smj | lacks | How the retired JS doctor's `github.app` check read its credentials and skipped: historical, `cli-cairn-doctor.md` is "no excerpt: prose". The runtime `github.app-unreachable` throw is shown. |
| f:pkrwom | lacks | That `0002_audit.sql` is recommended on a dedicated `AUDIT_DB` with its own `migrations_dir`, apart from the auth DB for contention: the reference page is "no excerpt: prose". |
| f:rn62i1 | lacks | That the scaffold ships `0001_roles.sql`: no listing of the scaffold's migrations. The 0001 file's first line, 0003's opt-in header, and `runRoleWrite` are shown. |
| f:rp65d2 | lacks | GitHub's registration and installation options (external GitHub docs); `backend.ts` shows only `owner`/`repo`/`appId`/`installationId`. |
| f:shv6wv | lacks | "`NavMenuConfig` no longer carries a path": the type is not shown. The default path and the nav, settings, and vocabulary-load uses of `siteConfigPath` are shown; the vocabulary save block is cut off. |
| f:skeche | lacks | That a kit 2 project hits `ERESOLVE`: npm behavior from an external run, not shown. The `^3` peer range is shown. |
| f:vvgpr5 | lacks | "adapter-cloudflare 8 declares no `App.Platform`" and the custom-route read from `cloudflare:workers`: not shown. The five `App.Locals` fields and `Env` from `wrangler types` are shown. |
| f:yegr67 | lacks | That `sv create` pins 6 (an external run) and that cairn's own code is 7-clean (the weekly advisory comparison): `supported-toolchain.md` is "no excerpt: prose". The `typescript` ^6 pin and the 7.1 hold comment are shown. |

Counts: 55 lacks, 1 shows (f:n0fg3w).
