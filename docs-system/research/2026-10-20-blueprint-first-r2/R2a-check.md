# R2a second read: pointer-column wider rows

Each row: full excerpt run via `drafter excerpt f:<id>`, bullet split into parts, each part searched in the excerpt blocks.

| fact | answer | the part missing, or the lines that show it |
|---|---|---|
| f:0ygumq | lacks | `.claude/cairn/VERSION` and `MANIFEST` paths, the `cairn-extension-reviewer.md` file name, and the `npx cairn-guidance install` adoption claim; `templates/waymark/.claude/` block is "no excerpt: directory" |
| f:hiif6u | lacks | the 3,500-token budget, the `cairn-public` router and `references/` contents, and the failure modes (unresolved token, parser matching nothing); only the header lines 1-11 of check-public-skill.mjs shown, SKILL.md is "no excerpt: prose" |
| f:mrv24k | lacks | that the three public-scope rules print as advisories and never change the exit code (report.ts shows `exitCodeFor` only; no public-scope rule is shown) |
| f:pmmtrm | lacks | the absence claim (no `AGENTS.md`, no other-agent file in package or template); guidance.md:146-152 is "no excerpt: prose" |
| f:3z1uxv | lacks | "holds no `src/access.ts`": no listing of the scaffold's src shown (the config.ts file shows no `access` member, but nothing shows a missing file) |
| f:4xrx5f | lacks | "earlier versions took optional `roles` and `access` options" and bare `createAuthGuard()` was valid; no excerpt line mentions earlier versions |
| f:7cv105 | lacks | "earlier versions took optional `access` and `roles` options of their own" |
| f:8ciz2s | lacks | members of `FIXED_SCREEN_IDS` (`media`, `vocabulary`, `nav`, `settings`): only `ACCESS_FIXED_SCREENS = FIXED_SCREEN_IDS` shown |
| f:bp22uq | lacks | the identity of the five helpers; only `createAdminAction` is shown, plus "none needs a site `handleError` mapping" |
| f:cvzb8z | lacks | the earlier-version history (guard's own `access` option, hooks-only map left engine screens open); also the sidebar reader is not shown |
| f:f21bcz | lacks | "earlier versions took optional `roles` and `access` options and a bare `createAuthGuard()` was valid" |
| f:iwf4nu | lacks | "earlier versions took the map as a separate `access` option on the guard" |
| f:k085q0 | lacks | "the only event" whose `actor` need not be an editor email: exclusivity across events is not shown (only one emit site and one doc comment) |
| f:mou1li | lacks | "once at module evaluation", at most once per isolate on cold start, and a Workers Logs query missing it; excerpt shows only "once at composition (server start)" |
| f:prb2os | lacks | the Workers Logs requirement (Cloudflare's external statement); only the template's `"observability": { "enabled": true }` line is shown |
| f:q07rd5 | lacks | the tutorial's adapter path, `#lib/cairn.config.js`, no `src/access.ts`, and the bare `createAuthGuard()`/`devBackendHandle()` calls; the tutorial page excerpt is "no excerpt: prose" |
| f:qlgggh | lacks | the scaffold root/`src` listing (templates/waymark/ block is "no excerpt: directory"), and no `src/access.ts` |
| f:swjwxb | lacks | adapter-cloudflare 8 passes no `platform`; `cloudflare:workers` returns `vars` under `vite dev` and `wrangler dev`; record.md block is "no excerpt: prose", workers-env.ts only comments on `cloudflare:workers` |
| f:u78zg6 | lacks | "earlier versions left the map unattached ... fix was `devBackendHandle({ access })`; that option is gone" |
| f:vq634h | lacks | the confirm path (and the three call sites): only the `logSessionDestroyed` definition with `path: 'logout' \| 'revoke'` is shown; log-events.md is "no excerpt" |
| f:0qb73i | lacks | the four fixed screen ids (`FIXED_SCREEN_IDS` members) and the owner bypass (access.ts:160-161 is not shown) |
| f:3z48zf | lacks | `FIXED_SCREEN_IDS` members `media`, `vocabulary`, `nav`, `settings` |
| f:5iqvmt | lacks | that a cookie-less confirm passes SQL NULL: `consumeToken` shows the `nonceHash = null` default and the predicate, but not the caller that derives NULL from a missing cookie |
| f:bw5uk0 | lacks | the absence: no doctor or health check body references the listed constants (only the check list names and three health files are shown), and that `authRoleWiring` raises `auth.role-wiring-missing` |
| f:gepykz | lacks | showcase's 0001 byte-identical to the engine's (showcase migrations file not shown) and the "emitted from the showcase" claim; the waymark migrations listing is "no excerpt" |
| f:jtl15v | lacks | the `Consumers must:` line step and the by-hand `wrangler d1 migrations apply` step (upgrade-cairn.md is "no excerpt"); BUILD/DEPLOY commands and script blocks are shown |
| f:l3cxgc | lacks | the doctor report passing the five checks (04-doctor-report.txt is "no excerpt: prose"); the wrangler bindings are shown |
| f:qtm9y2 | lacks | the whole `src/routes/` listing (block is "no excerpt: directory"); `params.ts` `md` via `defineParams` is shown |
| f:vfpai6 | lacks | GitHub App creation and the optional domain by the command (only repo.mjs and wrangler.jsonc shown; wrangler shows `AUTH_DB`, `MEDIA_BUCKET`, one name) |
| f:wnsv5x | lacks | that `src/lib/` holds only `log.ts` (no directory listing) |
| f:xffr6i | lacks | which four statements route through `runRoleWrite` and that `insertOwnerIfEmpty` stays unrouted; only `runRoleWrite` shown |
| f:xw0bit | lacks | the repo URL and App URL lines (`closingInfoLines` contents not shown); live address, `/admin` sign-in and "what exists now" are shown |
| f:xxtooz | lacks | "five migrations" (only 0000 and 0004 shown) and the `wrangler d1 migrations apply <db> --local/--remote` usage |
| f:1pb077 | lacks | the numeric/status values: 55-minute cache, 60 s, 5 s, 500 ms grace, and the 401/404/403 classification; excerpt shows only the constant names and logic flow |
| f:kldwss | lacks (borderline) | "in one run" across both chapters: each chapter header says "one ordered run" of its own, but nothing in the excerpts ties the GitHub and Cloudflare chapters into a single invocation; App, repo, deploy and id-less D1/R2 bindings are all shown |
| f:nls26c | lacks | "the bake never applies the overlay" and "earlier versions of the file named `GITHUB_APP_ID`"; emitter skip, `.gitignore` lines, `.dev.vars.example` content and `tidy.enabled` are shown |

Count: 36 lacks, 0 shows.
