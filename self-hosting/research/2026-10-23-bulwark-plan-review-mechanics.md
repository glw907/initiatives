# Bulwark plan review: mechanics and feasibility

Reviewer: `plan-reviewer` (Opus, medium), against `self-hosting/plans/2026-10-23-bulwark-plan.md` at `2bb9672`. Saved verbatim from the agent's reply by the planning session.

Probes run: the Bulwark 1.17.1 and Stalwart v0.16.27 source clones, servers main at e036a70, Survey v1.2.0, `skopeo` against ghcr.io, and a Python contrast calculation on Survey's variables.

## Verified as the plan states

- Env var names: `SESSION_SECRET_FILE`, `ADMIN_CONFIG_DIR`, `ADMIN_STATE_DIR`, `ADMIN_CONFIG_READONLY`, `STALWART_ADMIN_ACCESS=off`, `BULWARK_TELEMETRY`, and `APP_NAME` all exist in `.env.example`. "One trusted proxy" is `TRUSTED_PROXY_DEPTH`, default 1 (`lib/admin/session.ts:166`).
- Admin stays off: `JMAP_SERVER_URL` puts Bulwark in `env-managed` mode with no setup wizard (`lib/setup/state.ts`); startup migrations skip a read-only config dir (`lib/admin/migrate.ts:79`); with no password and access `off`, `GET /api/admin/auth` returns `enabled:false` (`app/api/admin/auth/route.ts:224-228`).
- uid 1001 is `nextjs` (`Dockerfile:51-56`).
- Image digest: `skopeo inspect --raw docker://ghcr.io/bulwarkmail/webmail:1.17.1 | sha256sum` gives `4a766a3f…4958`.
- Brief fact 1: `network.rs:404-427` matches; `Authorization` is in the fixed allow-headers.
- Brief fact 2: `request.rs:749-775` confirms global trust. `AllowedIp` shape at `structs.rs:173-182` (also has `createdAt`).
- Brief fact 3: 5 failures per client per 15 minutes (`verify-budget.ts:16-17, 117-121`).
- `render.sh` owner regex is `^[a-z_][a-z0-9_-]*$`, so it does not accept `1001`; T1's change is required, not conditional. The fake ssh records owner in `.meta`, so T1's test can be built.
- Path: 45 + 90 + 60 + 60 + 60 + 50 = 365.
- Pairs are file-disjoint including generated outputs; the shared golden test is touched by T1 and T2, in sequential pairs.

## Blocker

**B1. T3's theme output is never read by Bulwark** (correctness; plan:39, :52). Bulwark does not read `config/themes/<id>/manifest.json` or `skin.css` at runtime. An installed theme is three files: `themes/registry.json` (`lib/admin/plugin-registry.ts:357-418`), `themes/<id>.css` holding the compiled `:root` / `.dark` variables (`:487-494`), and `themes/<id>.skin.css`. Users get the theme list from `/api/plugins`, which keeps only registry entries with `enabled` (`app/api/plugins/route.ts:76-89`); the CSS is served raw from `themes/<id>.css` (`lib/admin/theme-asset.ts`). A `manifest.json` is read only from a ZIP uploaded through the admin API (`lib/extension-package.ts:630+`), which is off, and the config dir is read-only. The manifest also lacks required base fields `id`, `name`, `version`, `author`, `type:"theme"`, `variants` (`checkThemeManifest`, `:568-610`). Radii keys are `sm`, `md`, `lg`, `xl`, `full` (`ThemeRadii`), not field and box. *Fold*: `build` writes `themes/registry.json` (id `survey`, `enabled:true`, `variants:["light","dark"]`, `hasSkin:true`, `contentHash` = sha256(css + "\0" + skin), `:383`), `themes/survey.css` in the compiler's shape (`--color-<key>`, `--radius-<k>`, `--font-sans/mono/display`, `lib/theme-compiler.ts:52-58, 117-169`), and `themes/survey.skin.css`. Radii: `sm`, `md` 3px; `lg`, `xl` 4px. A `manifest.json` only for provenance if wanted. T5 step: `/api/plugins` lists `survey`, and `/api/admin/themes/survey/css` and `/skin` return 200.

## Major

**M1. A config change never reaches the running container** (correctness; T2 plan:34, T6 plan:64, T7). `policy.json` is read once at startup (`configManager.load()` in `instrumentation.node.ts`). If `install.sh` replaces `/opt/bulwark/config` wholesale, the bind mount keeps the old directory (expected from bind-mount resolution, not probed), and `docker compose up -d` does not recreate a container whose compose file is unchanged, so T6 rounds and the runbook regen step render stale output. *Fold*: `install.sh` updates files in place and restarts `bulwark.service` when the config tree's hash changes; the runbook regen step includes the restart; T2's test covers it.

**M2. T5 step 4's ban check can't fail** (correctness; plan:60). Correct sign-ins never trip the ban (default `authBanRate` 100/day, `structs_impl.rs:35589-35592`), and `AllowedIp` loads only when Stalwart parses its security settings (`security.rs:77-110`), so the objects are inert until a reload. *Fold*: (a) after the ward apply, read the `AllowedIp` objects back with stalwart-cli and confirm a reload or restart happened; (b) prove Bulwark's budget: six wrong-password POSTs to `/api/auth/session` for the test mailbox from one client, the sixth returns 429 (`verify-budget.ts:107-121`); five failures sit far under Stalwart's 100.

**M3. OWNER FORK: allowlisting orpheus also lifts Stalwart's per-account limit** (correctness; Brief fact 2, plan:12; T4). `is_auth_fail2banned` checks `is_ip_allowed` before both the per-IP and per-login rate (`security.rs:295-309`). Bulwark's budget is per client with `globalMax: Infinity`. A distributed guesser gets 5 tries per IP per 15 minutes with no per-account limit; orpheus is also exempt from rcpt, scan, and loiter bans; the design's Caddy throttle is dropped. Options: (a) accept and record the residual risk in Decisions and the runbook, resting on generated mailbox passwords (L3; confirm for `STALWART_PASSWORD_GEOFF` and `_OPERATOR2`); (b) no allowlist, accepting that about 100 failures a day lock both users out of webmail for 24 h; (c) custom Caddy with `caddy-ratelimit` keyed on login, a new build path. Recommendation: (a), with fact 2 rewritten to say the per-login limit is lifted too.

**M4. Browser sign-ins have no safe way to enter the password** (correctness; T5.3 plan:59, T6). Chromium's password manager and autofill are off by policy (`bluefin-admin.md` "Browsers"); typing through claude-in-chrome puts `STALWART_PASSWORD_TEST` in a tool argument and the transcript. *Fold*: a Playwright script run through Bash loads the value through `scripts/lib/secrets.sh` and fills the field, so the value stays in the environment, and captures T6's renders at fixed widths with color-scheme emulation (the rendering recipe `visual-verifier` requires).

**M5. T6 as framed loops to Bar unmet** (correctness; plan:64). `visual-verifier` inventories chrome anatomy and composition first (`~/.claude/agents/visual-verifier.md:19-26`); the reference is a site specimen HTML (`survey-theme/reference/2026-10-07-approved-specimen.html`) whose layout Bulwark cannot match, so every round returns STRUCTURAL that no mapping change can fix. *Fold*: render the specimen to PNG; scope grading to what a theme carries (color placement per the mapping, radii, field edge, alert bar, contour rule, the named type stacks, the contrast probe); composition and chrome are Bulwark's and ungraded; a STRUCTURAL whose fix is not a token or skin rule goes to the theme-hook standing answer.

**M6. One mapped pair fails contrast, and the pair list is unnamed** (correctness; plan:44-46, :52). `selection` on base-300 puts `text-muted-foreground` (#5d5f58) on #d9d6c9 at 4.44:1 in light, the selected message row (`components/email/thread-email-item.tsx:129, 160-182`). "Each text pair" doesn't name cross pairs. If `border` / `sidebar-border` count as control edges they fail at 1.36:1. *Fold*: name the pair list, including `muted-foreground` on muted, card, sidebar, selection, sidebar-accent; map `selection` to base-200 (5.52:1); name `input` (3.65:1 light, 3.63:1 dark) and `ring` as the only 3:1 control edges; borders are decorative dividers.

**M7. Logo and favicon URLs unnamed and would 404** (correctness; plan:35, :52). Config-dir `branding/` files are served at `/api/admin/branding/<file>` (`app/api/admin/branding/[filename]/route.ts`); `/branding/...` resolves against `public/`. The favicon filename is not given, and `LOGIN_LOGO_LIGHT_URL` / `_DARK_URL` default to Bulwark's logo (`lib/admin/types.ts:224-234`). *Fold*: name all five variables (`APP_LOGO_LIGHT_URL`, `APP_LOGO_DARK_URL`, `LOGIN_LOGO_LIGHT_URL`, `LOGIN_LOGO_DARK_URL`, `FAVICON_URL`) and the favicon filename; a T5 curl of each returns 200 `image/svg+xml`.

**M8. A bad secret file fails silently** (correctness; T1/T2/T5). `getSessionSecret` returns null on any read error and falls back to a generated secret in the tmpfs state dir (`lib/auth/session-secret.ts:25-41`); a wrong owner or mode passes every test and T5, then every restart signs everyone out. *Fold*: a T5 check that the container journal lacks "Generated a session secret" and `.session-secret` is absent in `ADMIN_STATE_DIR`. Record the 1001/0400 owner against the design's "root-only file" (design:25) as a fifth Brief fact.

**M9. Rerun answers are bare count caps; two failure paths lack a bar-unmet answer** (correctness; plan:90-93). The CORS and ban rows say "rerun once" without saying what follows a second failure with a new traced cause; nothing covers T5's end-to-end check being unreachable; the visual-gate row doesn't say whether T7 to T9 still run. *Fold*: a traced cause is fixed and rerun, an untraced one stops; if T5 can't pass, T6 is skipped, T7 to T9 run, close with `## Bar unmet: end-to-end`; the visual-gate row adds that T7 to T9 still run.

**M10. Live commands the run repeats are not written out** (correctness; T5 plan:56-60, T8 plan:68, T4). Write in full: preflight `curl -sS -o /dev/null -D - -X OPTIONS -H 'Origin: https://webmail.907.life' -H 'Access-Control-Request-Method: POST' -H 'Access-Control-Request-Headers: authorization,content-type' https://ward.907.life/jmap/session`, and the same against `/.well-known/jmap` (`lib/jmap/client.ts:1397`); admin check `curl -sS https://webmail.907.life/api/admin/auth` returns `"enabled":false`; D1 `SELECT "check", count FROM probe_failures WHERE "check"='webmail_ping'` returns one row with count 0 (`src/tick.ts:35`); and the health curl, the ban-list read (stalwart-cli needs the admin credential over ssh), and the memory read.

**M11. T4's arm would touch ward with the admin credential** (correctness; plan:54, base plan dispatch note). Confirming object shapes against stalwart-cli on ward needs `STALWART_ADMIN_PASSWORD` (`roles/stalwart/stalwart-apply` `cli_as`); arms never touch a live account. *Fold*: the main loop runs the read before dispatching the T1/T4 pair and hands the shapes to the arm; also say whether T1's `secret-set.sh` store and workstation push run in the arm or the main loop.

## Minor

1. Golden test (correctness): `tests/orpheus-golden.test.sh:37-38` pins `hosts/orpheus/secrets.txt` and `roles.txt`; T1 and T2 each update its hash and header comment in the same commit. Add `bulwark` to `tests/apply.test.sh:63`'s role loop instead of a duplicate check.
2. DNS test location (correctness): `tests/dns.test.sh` runs on fixtures and never reads `cloudflare/dns/orpheus`; put the webmail-row grep in `tests/bulwark.test.sh`.
3. Banned-pattern list (correctness): committed CSS skips the upload sanitizer (`serveThemeAsset` serves it raw); the build's check uses all seven `DISALLOWED_CSS_PATTERNS` (`lib/plugin-types.ts:1367-1379`) plus the `:root`/`.dark`-only rule.
4. Privileged channels (correctness): T2's test asserts `ALLOW_CUSTOM_JMAP_ENDPOINT`, plain `SESSION_SECRET`, and `BULWARK_JWT_AUTH_SECRET` / `BULWARK_STALWART_MASTER_*` are absent, and `config.json` carries no `stalwartAdminAccess`, `sessionSecret`, or admin-password key.
5. The Http line (correctness): put `usePermissiveCors` in the existing Http update line (`plan.ndjson:13`); the test asserts a single Http line, in case a second `update` replaces rather than patches.
6. No memory read: add `ssh -o BatchMode=yes geoff@orpheus.907.life free -m` as T5 step 0.
7. Backup window: `stalwart-apply` refuses 03:20 to 04:00 UTC; standing answer: wait and rerun.
8. Message-IDs: T5.3 reads them with JMAP `Email/get` on the test mailbox.
9. Calendars and contacts: the Outcome promises them and nothing checks them; a T5 step opens both views, a failure goes to Decisions.
10. Policy ids: `disabledBuiltinThemes` needs the seven ids from the pinned release (`lib/builtin-themes.ts:880-949`); the runbook upgrade step re-reads the list, since a new built-in arrives enabled. The stock-look card stays selectable (`components/settings/themes-settings.tsx:46`).
11. Mark color (optional): the benchmark triangle is `--site-contour` (`components.css:68-74`), not `base-content`.
12. Records (correctness): T7 adds `BULWARK_SESSION_SECRET` to the runbook's credentials table and documents `webmail_ping` in the monitor section; no emergency copy is needed, since regenerating the secret only signs users out.
13. Phone-home (optional): `BULWARK_UPDATE_CHECK=off` stops an hourly call to `version.telemetry.bulwarkmail.org` (`instrumentation.node.ts:64-69`); note that translate defaults to the public MyMemory API.
14. Monthly review wording (optional): step 2 requires a snapshot and backup before every upgrade; say whether stateless Bulwark is exempt.
15. Risk class (correctness): T6 drives live sign-ins, so it is `live-account` in the main loop.
16. T1 test order: "1001x refuses" already passes before the change; the failing-first case is "renders with owner=1001".
17. Hosts (optional): thinkpad-x1 gets `values.age` at its next pull plus `sync.sh --local`; no other workstation change.
18. Over-ceremony, path (optional): T7 needs no live state and could run as an arm during T5 and T6, about 60 path minutes saved.
19. Over-ceremony, T6 estimate (optional): three rounds in 60 minutes is tight; with M5's scoping one round is likely.

## Design coverage

Sections 1 to 6 and the end-to-end check are all assigned. The gaps are T3 mechanism faults (B1, M6, M7), the vacuous ban proof (M2), the dropped throttle and per-login protection (M3), and the unread memory figure (minor 6).
