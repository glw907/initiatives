# R2b1 pointer-column wider rows: second read

| fact | answer | part missing, or lines that show it |
|---|---|---|
| f:0gihxq | lacks | No excerpt shows entry delete or rename committing without `expectedHead`; `content-routes-entry-destructive.ts` is absent (repo.ts only shows `commitFiles` retry in general). |
| f:0ygumq | lacks | `templates/waymark/.claude/` is "no excerpt: directory"; `cairn-extension-reviewer.md` and the `.claude/cairn/{CLAUDE.md,VERSION,MANIFEST}` names are never shown (only "guidance tree, version stamp, manifest"). |
| f:1kwkl0 | lacks | `hashFileTree` skips `VERSION_DEST`, but the value `.claude/cairn/VERSION` is not in any block. |
| f:2glcaf | lacks | The 30-day session constant is in no excerpt (guard.ts shows only the identity branch); Access's 24-hour default is external. |
| f:2pv4r5 | lacks | `ssr.noExternal` and the `cloudflare:workers` comment are shown; "`/admin` answers 500" and "the scaffold's vite.config.ts carries the entry" are not. |
| f:33upyd | lacks | guard.ts shows the normalize and `findEditor` step; "Access takes the email from the IdP claim" is external and absent. |
| f:3bbeia | lacks | Token name is shown; "revoking breaks deploys, build fails" is in the README block, which is "no excerpt: prose". |
| f:3jpoi3 | lacks | `wrangler secret put` and the rotation URL are shown; the App's GitHub settings page and the two-keys / no-downtime behavior are not. |
| f:3my5c1 | lacks | bin.mjs `overridable` list and the override note are shown, but no line applies `--owner-email` (chapter.mjs shows only appName, repoName, org). |
| f:3z1uxv | lacks | Waymark `cairn.config.ts` has no `access`, and the showcase map is shown; "holds no `src/access.ts`" is shown by no listing. |
| f:4nccq6 | lacks | The Stop-hook snippet JSON is shown; "`install` never writes `.claude/settings.json`" is in guidance.md, "no excerpt: prose". |
| f:4xrx5f | lacks | Required `runtime`, `includeSubDomains`, and `identity` are shown; "earlier versions took optional `roles`/`access`" is absent. |
| f:5iqvmt | lacks | Unbound row matching (`nonce_hash IS NULL`) is shown; that a cookie-less confirm passes NULL is not (caller not shown). |
| f:6jxd81 | lacks | Registry samples and `withoutPreview` are shown; the type scale and component recipes are not (loader returns only `proseHtml, components, withoutPreview`). |
| f:7cv105 | lacks | Required `runtime`, `access ?? {}`, and "roles resolves no capability" are shown; "earlier versions took their own `access`/`roles`" is absent. |
| f:7idpoq | lacks | Only a constants/doc block around factory.ts:62; no line shows a failed challenge on an escalated action returning `challenge-required` again. |
| f:7qwrb9 | shows | backend.ts: "Set only by a development backend that holds commits in memory ... A production backend never sets it." (`Backend.ephemeral`). content-routes-shell.ts: "Present only while the dev backend serves the site's own content from memory (its backend sets `ephemeral`) ... Absent on a production request ... and under the seeded fixtures"; `...(event.locals.cairnBackend?.ephemeral ? { contentEphemeral: true as const } : {})`. CairnAdminShell.svelte: `role="status" class="alert alert-info"` with "Edits are held in memory. They're discarded when the dev server stops." Borderline: the repository backend is identified by description, not by file name. |
| f:8ciz2s | lacks | `ACCESS_FIXED_SCREENS = FIXED_SCREEN_IDS` is shown; the four names `media`, `vocabulary`, `nav`, `settings` are never listed. |
| f:8u4iiv | lacks | Factory comment ("SvelteKit's own origin check covers form posts but not `vite dev`") and `originMatches` are shown; the `csrf.trustedOrigins` clause and the double-submit token on unsafe `/admin` POSTs are not; kit blocks are "no excerpt: missing". |
| f:8xxe3b | lacks | createAuthRoutes excerpt ends at line 357 and omits `logoutAction`; only `isSafeLogoutUrl` validation is shown. |
| f:9exogy | lacks | auth-routes.ts comment "the CSRF cookie rotated after it" and `isPublicAdminPath` are shown; the other open tab's form failing with a generic 403 that a reload recovers is not. |
| f:bw5uk0 | lacks | Absence claim over all doctor/health checks; excerpts show the condition list, the check list, and three health files only, not the other check bodies. |
| f:cvzb8z | lacks | Current `access: adapter.access` flows are shown; "earlier versions ... left every engine screen open" is absent. |
| f:ez788q | lacks | normalize and challenge obligations are partly shown (idempotent, canonical, injective; Turnstile); `lookup`'s "stable and canonical per person" and the `async () => true` remark are not. |
| f:f21bcz | lacks | Current `{ runtime }` hooks are shown; "earlier versions took optional `roles`/`access`, bare `createAuthGuard()` was valid" is absent. |
| f:gepykz | lacks | The migration directory listing is "no excerpt: directory" (the test asserts the four names); "showcase 0001 is byte-identical to the engine's" is not shown (no showcase file). |
| f:gj96px | lacks | Concept dirs are shown; `templates/waymark/src/content/` is "no excerpt: directory", so the 14 posts, the two pages, the fragment, and the frontmatter keys are absent. |
| f:h0xykj | lacks | `"version": "0.98.0"` is shown; the 0.86.0 and 0.94.0 breaks are in blocks that are "no excerpt: prose". |
| f:irs7fg | lacks | capture-transport and chassis blocks are shown; e2e.yml lines 54-75 hold install steps only and the markers file is "no excerpt: prose", so the `wrangler deploy --dry-run` check and `devBackendHandle` marker are absent. |
| f:iwf4nu | lacks | Single declaration and `access ?? {}` are shown; "earlier versions took a separate guard `access` option" is absent. |
| f:j254i8 | lacks | Only the `AuthChannelConfig` block: "Awaited before any mint on `request`, and on an escalated `confirm`; false ... answers `challenge-required`". Not shown: charges/destroys nothing, step ordering, and the failure-gate threshold where `charge()` adds no unit. |
| f:jtl15v | lacks | Package range, `BUILD_COMMAND`/`DEPLOY_COMMAND`, and scripts without a migration are shown; the `Consumers must:` step and "apply a D1 migration by hand" are in upgrade-cairn.md, "no excerpt: prose". |
| f:jud805 | lacks | The `nonce_hash` column and the `auth.store-unmigrated` error are shown; "no command checks this pre-deploy / `cairn doctor` runs no D1 check" is in a "no excerpt: prose" block. |
| f:k6u4g2 | lacks | The excerpt (store.ts 227-244) shows `consumeCode` only; eviction keyed on `requester_bucket` is not shown. |
| f:keuj8l | lacks | Header-decides-outright, body clone, and `guard.refused` reason `csrf` are shown; the `tokensMatch` compare on the field path (`csrfFieldVerdict`, `verdictFromWitness` not shown) and the "branded 403" page (only `renderConditionResponse('auth.csrf-token-invalid')`) are not. |
| f:kouawx | lacks | Both transcript blocks are "no excerpt: prose"; the site name, the account, and "nothing about CI" are unshown (scaffold.mjs `handoverText` only is shown). |
| f:l3cxgc | lacks | wrangler bindings are shown (EMAIL, AUTH_DB, MEDIA_BUCKET, observability, PUBLIC_ORIGIN); the doctor-report transcript is "no excerpt: prose". |
| f:mrv24k | lacks | `check:cairn` script, `exitCodeFor`, and the peer message are shown; the three public-scope rules and their advisory printing are not. |
| f:n2skkz | lacks | The exclude list is shown; the post counts (27 and 14) and the dir comparisons are "no excerpt: directory". |
| f:n52h8f | lacks | app.d.ts shows the ambient import, the PageData members, and the references; what the ambient module declares (`__CAIRN_DEV_BUILD__`) is not shown. |
| f:nls26c | lacks | `.dev.vars.example` and the gitignore lines are shown; "the bake never applies the overlay" and the removed `GITHUB_APP_ID` history are not. |
| f:o8uoci | lacks | `live`, `TERMINAL_STEPS`, and `CHAPTER3_RESUMABLE_STEPS` branches are shown; the chapter-3 terminal-steps branch (`CHAPTER3_TERMINAL_STEPS`) is not. |
| f:p1v88s | shows | handle.ts `DevBackendConfig`, the whole interface, holds only `content?: 'repository' \| 'fixtures'` (doc: "`'repository'` (the default)") and `runtime`, so no `seedContent`. Comment: "Every seed runs only in fixtures mode"; `if (content === 'fixtures') { seedMediaLibrary(); seedFragments(); ... seedPreviewTwin(); }` and `if (content === 'fixtures') for (const key of SEED_MEDIA_KEYS) fakeR2.seedObject(key);`. Borderline: "gone" and "unchanged" are read off the current interface. |
| f:pfy9cw | lacks | The `admin.action.misconfigured` log line (`path`, `reason`) falls past the excerpt (lines 202-222 end inside `misconfigured`). |
| f:prb2os | lacks | `"observability": { "enabled": true }` is shown; "Workers Logs records only when set" is external. |
| f:q07rd5 | lacks | The tutorial page excerpt is "no excerpt: prose", so the `src/lib/cairn.config.ts` adapter and the bare `createAuthGuard()`/`devBackendHandle()` hooks are unshown. |
| f:qlgggh | lacks | `templates/waymark/` is "no excerpt: directory", so the root and `src` listing is unshown; the bake/overlay mechanics are partly shown. |
| f:qnf469 | lacks | `templates/waymark/src/theme/` is "no excerpt: directory": file names, nine `defineComponent`s, and one hydrated are unshown (only showcase config pieces and `registry.ts` are). |
| f:qtm9y2 | lacks | `params.ts` and the `md` matcher are shown; the `src/routes/` listing is "no excerpt: directory". |
| f:r0cv6e | lacks | pipeline.ts shows the current sanitizing pipeline; commit `40d466ad`, the "before" state, and v0.17.0 are not shown. |
| f:rv9gdc | lacks | `deliver` refusing without the flag and the dynamic `import()` behind `__CAIRN_DEV_BUILD__` are shown; "MEMBER_DB is a local D1 under `wrangler dev`, no handle builds a database double" is not (only `resolveDb: (env) => env?.MEMBER_DB`). |
| f:shv6wv | lacks | `DEFAULT_SITE_CONFIG_PATH`, `adapter.editor?.siteConfigPath`, and the nav/Settings/Tags reads are shown; the `NavMenuConfig` type (no path member) is not. |
| f:t976f1 | lacks | `omitHsts` on `brandedAdminPage`, the resolve path, the early return, and the bare 503 are shown; "every identity refusal" using the branded page is not (doc lists CSRF, https, bindings only). |
| f:u705t5 | lacks | Waymark description and `DEFAULTS` are shown; "Topo is planned but not shipped" is in no excerpt (`packages/` and `examples/` listings are directory placeholders). |
| f:u78zg6 | lacks | Handles setting `cairnAccess`, `session_absent`, and `access_map_not_attached` are shown; "earlier versions needed `devBackendHandle({ access })`, that option is gone" is absent. |
| f:v85shm | lacks | `isPublicAdminPath` (two public paths) is shown; the threat position is in a "no excerpt: prose" block. |
| f:vqh4a9 | lacks | `canReach` and reads of `runtime.access` are shown; "earlier versions took the guard's map as a separate option" is absent. |
| f:vrue1g | lacks | `templates/waymark/src/content/.cairn/` is "no excerpt: directory"; the three-file contents are unshown. |
| f:wnsv5x | lacks | `log.ts` content is shown; "`src/lib/` holds one file" is not (no listing). |
| f:xffr6i | lacks | `runRoleWrite` and the registry are shown; the four call sites, the unrouted `insertOwnerIfEmpty`, and "no tool check raises it" are not. |
| f:xluud1 | lacks | `command === 'serve' \|\| (await e2eFlagSet(mode))`, the define-wins check, and the default-false result are shown; `VITE_CAIRN_E2E=1` is not (`e2eFlagSet` body absent). |
| f:xw0bit | lacks | The live address, the `/admin` sign-in line, and "what exists now" are shown; the GitHub repo URL and App URL come from `closingInfoLines`, not shown; the `01d-resume.txt` staleness is unshown. |
| f:ytwrgp | lacks | `*`/`null` failure, the pass-with-note clause, and the UNCHECKED cases are shown; the `viteConfigCandidates` value is cut off (the comment names only the unread `.mjs`, `.cjs`, `.cts`), so `.js`, `.ts`, `.mts` are not listed. |

Totals: lacks 61, shows 2 (f:7qwrb9, f:p1v88s; both borderline).
