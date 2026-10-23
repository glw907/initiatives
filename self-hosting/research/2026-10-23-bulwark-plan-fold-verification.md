# Bulwark plan: fold verification

The verification read of `self-hosting/plans/2026-10-23-bulwark-plan.md` at `3b16c4d` against its fold record, the three reviews, the pre-fold plan at `a6107a1`, the approved design, and the base plan. This reader had no part in writing or folding the plan. Sources checked: Bulwark 1.17.1, Stalwart v0.16.27 (sparse), Survey v1.2.0, servers `main` at `e036a70`, and `cairn-themes` at `c19e7ac`.

Counts: 0 blocker, 8 major, 13 minor.

## Probes and source reads run by this check

- Contrast, recomputed with the WCAG formula on Survey v1.2.0's `survey-vars.css`: every figure the fold cites matches (light `muted` on `base-300` 4.44, on `base-200` 5.52; light `warning` 2.50 and `info` 4.42 on `base-100`; the four light inks 6.24 to 7.54 on `base-100`; `site-field-border` 3.65 light and 3.63 dark; every dark status color over 6.7).
- `uv run --offline --no-project --with playwright==1.64.1 python -I` resolves `playwright` 1.64.1 from the cache; `/usr/bin/chromium-browser` exists; Docker Compose v5.6.0 is installed (the `create_host_path: false` run was not repeated).
- Quoted correctly from source: the theme registry files and `contentHash` (`lib/admin/plugin-registry.ts:359-418`), the compiler's `:root`/`.dark` shape, the seven `DISALLOWED_CSS_PATTERNS` (`lib/plugin-types.ts:1366-1378`), the seven built-in ids (`lib/builtin-themes.ts:880-949`), `BULWARK_UPDATE_CHECK=off` (`instrumentation.node.ts:66-69`), `LOGIN_SHOW_REMEMBER_ME` unticked (`app/(main)/[locale]/login/page.tsx:204, 264-266`), the public branding route (`app/api/admin/branding/[filename]/route.ts:20-23`), the public theme CSS and skin routes (`lib/admin/theme-asset.ts:10-36`), `/api/setup/status` and `/api/admin/auth`, the session route's 401-then-429 order (`app/api/auth/session/route.ts:140-146`), the GET pass-through of the origin gate (`proxy.ts:217-218`), Stalwart's `AllowedIp` fields, `usePermissiveCors`, the default `authBanRate` and password floor, `is_auth_fail2banned` running only on a failed sign-in (`crates/common/src/auth/authentication.rs:57-64`), the authenticated rate-limit skip, `apply.sh`'s `rm -rf` and tar of `git ls-files` (`scripts/apply.sh:98-100`) and its render-before-roles order (`:113-118`), the `.txt` template rendering a bare value through `install -D` (`secrets/render.sh:11-12, 133`), the `upsert`/`destroy` line forms (`roles/stalwart/plan.ndjson:2-4`), `stalwart-apply`'s band and restart (`:46-47, 154-158`), the monitor's `probe_failures` upsert to 0 (`cloudflare/monitor/src/tick.ts:32-37`), and the specimen at `c19e7ac`, which loads only Google Fonts.
- Path: 50 + 120 + 50 + 100 + 70 + 50 = 440, each pair at its larger estimate. Correct.

## Closure of the reviews' blockers and majors

Each closed at the cited location, except where a finding below says otherwise: mech B1 and con B1 brought in the `/api/plugins` check that cannot pass (finding 2); mech M2(b) and con M1 depend on a route the plan does not name (finding 4); risk R2's STATUS hold lands only in the PR body, too late (finding 7); mech M8 and risk R5's restart-survival check has no driver support (finding 9); mech M10's ban-list read is not written out (finding 12).

## Findings, ranked by consequence

### 1. The Survey theme does not apply on a first visit, or on the first page after a first sign-in (major, correctness)

- **Location:** plan:81 (T5's renders), :92 (T7 step 7's computed `--color-background`), :100 (T8 grades the sign-in page), :77 (`policy.json`).
- **Defect:** A server theme reaches the browser only through `syncServerThemes`, which the mail app calls after sign-in (`components/mail/mail-app.tsx:1284-1287`), from `/api/plugins`, which needs a session. A sign-in page in a fresh browser therefore never has the theme: the sync has not run there. On the first sign-in, the sync installs `survey` but does not apply it. The new-install branch adds it to `installedThemes` with no `applyCustomThemeCSS` call (`stores/theme-store.ts:382-414`), and only a forced theme is applied after the sync (`:492-498`). The policy default is applied only by `initializeTheme` at boot, and only when the theme is already installed (`:140-170`). So the theme first shows on the next full page load. The driver runs a throwaway context (T5), so every T5 render of the sign-in page shows stock Bulwark, and the inbox render may too, depending on timing. T8 then returns STRUCTURAL on devices no token can fix, and T7 step 7 can read Bulwark's own `--color-background`. Each household member's first visit on each device also shows the stock sign-in page, which the design's "Comes through" list does not expect. This comes from reading the source; no probe ran.
- **Proposed fix:** Add a probe as T7's first driver action: in a fresh context, read `--color-background` on the sign-in page, after sign-in, and after a reload. Then take one of two fixes, recorded in `## Decisions`. (a) Set `forceEnabled: true` on the registry entry. The post-sync forced branch then applies it at once (`:492-498`), and with every built-in disabled the only choice members lose is the stock card. (b) Have the driver sign in, reload, and sign out before it captures, and record the stock first-visit sign-in page under the theme-hook standing answer and in the upstream issue. (a) is the smaller change and makes the visual gate deterministic.

### 2. T7 step 6's `/api/plugins` check cannot pass from curl (major, correctness)

- **Location:** plan:91.
- **Defect:** `/api/plugins` answers 401 to a request with no session whenever a session secret is set (`app/api/plugins/route.ts:16-19`, `lib/auth/instance-details.ts:22-23`). Step 6 runs curl with no session, so this step fails on every run and sends the session down the "A T7 step fails" row for a plan defect.
- **Proposed fix:** Drop `/api/plugins` from step 6. Step 7's computed `--color-background` already proves the theme loads, and the public `/api/admin/themes/survey/css` and `/skin` checks stay.

### 3. Fact 8 misses an outbound default of the same class as translate: sender favicons (major, correctness)

- **Location:** plan:18 (fact 8, "Two more defaults leave the estate"), plan:50 (the Caddy site), plan:91.
- **Defect:** `senderFavicons` defaults to on (`stores/settings-store.ts:913`). Each avatar loads `/api/favicon?domain=` (`components/ui/avatar.tsx:245`), and that route fetches `https://icons.duckduckgo.com/ip3/<domain>.ico` from orpheus (`app/api/favicon/route.ts:478-479`). So the domain of every correspondent goes to a third party. The fold's own posture closed translate for this reason, and fact 8 goes into `docs/decisions.md` as a complete list.
- **Proposed fix:** Close it as translate was closed: in T2, add a `handle /api/favicon*` that answers `respond 404` (the avatar falls back to initials when the image errors, `avatar.tsx:237-278`). Add it to T2's test and T7 step 6, and reword fact 8 to "three more defaults". No ruling is needed, by the fold's own reasoning for translate.

### 4. The wrong-password check does not name its route, and the UI route never returns 429 (major, correctness)

- **Location:** plan:81 (T5: "send six sign-ins with a wrong password"), plan:95 (T7 step 10).
- **Defect:** The sign-in form first posts to `/api/auth/verify` (`stores/auth-store.ts:178-196`). That route has its own budget of 5 per client and 30 across all clients (`lib/auth/verify-budget.ts:16-23`). Over budget it answers `inconclusive`, and the browser then sends the password to ward directly, from the workstation's address (`app/api/auth/verify/route.ts:86-87`). A driver that drives the form therefore sees no 429, and its sixth try spends ward's count against the workstation. The 401-then-429 behavior holds only for a direct `POST /api/auth/session` (`app/api/auth/session/route.ts:76-91, 140-146`), which the fold record names (mech M2) and the plan does not.
- **Proposed fix:** T5 names the request: `POST https://webmail.907.life/api/auth/session` with JSON `serverUrl`, `username`, `password`, `Content-Type: application/json`, and `Origin: https://webmail.907.life`, sent through Playwright's request context. Print only each status and `Retry-After`.

### 5. Ruling 1's "No" is more than the one edit it names (major, correctness)

- **Location:** plan:35, plan:37.
- **Defect:** The plan says the other answer is "the one named edit". Under No, these also change, and the ruling names none of them:
  - T7 step 3 still reads back two `AllowedIp` rows (plan:88), so it fails.
  - The standing answer "trace why the allowlist missed" (plan:134).
  - The back-out's `destroy` lines (plan:123).
  - Fact 2's "The plan instead adds `AllowedIp` objects" (plan:12).
  - T9's runbook text "the allowlist and why", and its amendment of `decisions.md:109` (plan:103, :109), which stays true under No.
- **Proposed fix:** List each of these under the No answer, or rewrite the ruling as "No removes every `AllowedIp` mention: T4's line and test, T7 steps 3 (the rows) and 9, the ban-list standing answer row, the back-out's `destroy` lines, fact 2's last two sentences, and T9's allowlist text and `:109` amendment".

### 6. T2's test depends on files that T3, its pair, writes (major, correctness)

- **Location:** plan:52 ("every branding variable names a file under `roles/bulwark/config/branding/`"), plan:77.
- **Defect:** T3 creates the three marks in its own worktree, alongside T2. T2's acceptance ("tests pass") fails in T2's worktree until T3 merges, and placeholder marks in T2 would overlap T3's files.
- **Proposed fix:** T2's test asserts that the five variables name `/api/admin/branding/benchmark-light.svg`, `benchmark-dark.svg`, and `favicon.svg`, names the plan already fixes. T3's test asserts that the three files exist. The cross-check of the two runs once the pair merges, before T5 is dispatched.

### 7. Nothing tells other sessions to hold applies from the first live write until the packet, and a stop inside T7 has no answer (major, correctness)

- **Location:** plan:98 (T7 acceptance: "the PR's `## STATUS lines` records..."), plan:111, plan:143.
- **Defect:** The `## STATUS lines` section is part of the PR body, which T10 writes, and the conductor copies it after review. From T7 step 2 to the packet (T8, T9, T10, and the wait for review), ward and orpheus run branch `bulwark`, but nothing in STATUS says so. An apply from `main` by another session in that window removes the webmail Caddy site, and on ward it keeps the merged `update` and the `AllowedIp` rows. A stop inside T7 (an untraced cause, or a stray DNS line) leaves ward changed, and perhaps DNS too, with no line and no standing answer. The Entry checks for other executors only at launch.
- **Proposed fix:** Before T7 step 2, the main loop writes the hold line into the initiative's STATUS: orpheus, ward, DNS, and the monitor run branch `bulwark`, so no session applies from `main`. Add a standing answer for a stop after step 2: keep the live state, report it, and back out only on a rejection.

### 8. Fixes after T7 can leave the hosts out of step with the merged code (major, correctness)

- **Location:** plan:111 (T10's batched fix chain), plan:120 (After merge step 2).
- **Defect:** T10's review fixes can touch `roles/bulwark/**`, `roles/caddy/Caddyfile`, or `roles/stalwart/plan.ndjson` after T7 and T8 applied them. Nothing re-applies those files, so T7's excerpts in `## Decisions` then describe code that is not on `main`. After-merge step 2's hash comparison has no answer for a mismatch.
- **Proposed fix:** T10: when the fix chain changes a file that a host installs, re-apply that host and rerun the T7 steps that cover the file, before the packet. After merge step 2: on a mismatch, apply that host from `main` and rerun T7 steps 3 and 4.

### 9. T7 step 8's restart-survival check has no driver action behind it (minor, correctness)

- **Location:** plan:93, plan:81.
- **Defect:** To see a remembered sign-in survive `systemctl restart bulwark.service`, the browser context must stay open while the main loop restarts the service over ssh. T5's action list does not include this. Saving Playwright storage state instead would write the encrypted credential cookie to disk.
- **Proposed fix:** Add a T5 action: sign in with "Remember me" ticked, wait for a named file or a keypress, reload, and report whether the session is still signed in. Or drop the third check: the journal line and the absent `.session-secret` already prove the file is used.

### 10. Step 10 spends the workstation's sign-in budget just before T8 needs it (minor, correctness)

- **Location:** plan:95, plan:100.
- **Defect:** The session route reserves a try before it checks the password (`app/api/auth/session/route.ts:140-146`). After step 10's five failures, the workstation's address is over budget for 15 minutes (`verify-budget.ts:16-17`), and T8's correct sign-ins then get a 429.
- **Proposed fix:** Run step 10 before step 8, whose restart clears the in-memory budget, or have T8 start after the window.

### 11. The stop list and the standing answers disagree, and one stop has no check behind it (minor, correctness)

- **Location:** plan:138, plan:143.
- **Defect:** The standing answers say "under 1 GB, stop for the conductor", but the stop list does not carry that stop. The stop list does carry "a host file outside the pass's own changes at T7", but no T7 step compares host files: the Entry's hash comparison runs only at launch.
- **Proposed fix:** Add the memory stop to the list. In T7, after the merge of `origin/main`, rerun the Entry's hash comparison on both hosts before step 3.

### 12. Two of the ward read-backs are still unwritten (minor, correctness)

- **Location:** plan:88 (step 3's stalwart-cli read-back), plan:95 (step 10's "Ward's ban list, read-only").
- **Defect:** The fold record says mech M10 wrote out the ban-list read. The plan names no object, no command, and no credential path for either read.
- **Proposed fix:** Write out both commands from T4's main-loop schema read: the object names, and the `cli_as` credential source on ward.

### 13. Ruling 1 and fact 3 understate what one address gets (minor, correctness)

- **Location:** plan:13, plan:37.
- **Defect:** One address gets 5 failures on the verify route plus 5 on the sign-in routes per 15 minutes, so 10, not 5 (`verify-budget.ts:16-23, 113-117`). The verify route also has a global ceiling of 30, so "no global ceiling" holds only for the sign-in routes. The recommendation stands either way, but the owner rules on these figures.
- **Proposed fix:** Reword fact 3 and ruling 1: "5 on the sign-in routes and 5 on the pre-check per address per 15 minutes, with a 30-failure ceiling across all clients on the pre-check only".

### 14. Back-out leaves the unit, the image, and the user (minor, optional)

- **Location:** plan:123.
- **Proposed fix:** Add removing `/etc/systemd/system/bulwark.service` with `systemctl daemon-reload` and `docker image rm` on the pinned digest. Keep the `bulwark` user, so that uid 1001 stays reserved.

### 15. The sign-in page keeps Bulwark's name and link (minor, optional)

- **Location:** plan:49.
- **Defect:** `LOGIN_COMPANY_NAME` defaults to "Bulwark Webmail" and `LOGIN_WEBSITE_URL` to `https://bulwarkmail.org`, both shown on the sign-in page (`.env.example:305-315`).
- **Proposed fix:** Set both in T2, or record them as accepted.

### 16. `registry.json`'s top-level shape is unstated (minor, optional)

- **Location:** plan:55.
- **Proposed fix:** Say that the file is `{"themes": [<entry>]}`, the shape `getThemeRegistry` reads (`plugin-registry.ts:131-133, 359-361`).

### 17. No task owns `roles/bulwark/config/config.json` (minor, optional)

- **Location:** plan:52.
- **Defect:** T2's test reads the file, and no task says it exists or what it holds.
- **Proposed fix:** State that the file is absent and the test asserts it is absent, or name T2 as its owner and give its keys.

### 18. Step 2 quotes a `FAIL` line in a form `dns.sh` does not print (minor, optional)

- **Location:** plan:87.
- **Defect:** `dns.sh` prints `FAIL <name> CNAME: missing <content>` (`cloudflare/dns.sh:227`), with the name in the API's form.
- **Proposed fix:** Quote the line as a pattern (`FAIL webmail.* CNAME: missing orpheus.907.life`).

### 19. The translate 404 is not checked against an escaped spelling (minor, optional)

- **Location:** plan:91.
- **Defect:** Bulwark notes that Next routes on the decoded path, so an escaped spelling reaches a handler (`proxy.ts`, `routePathOf`). Caddy's path matcher also matches the decoded form, so the 404 should hold, but nothing probes it.
- **Proposed fix:** Add a POST to `/api/%74ranslate` to step 6, also expecting 404.

### 20. Three design departures are missing from the list headed for `## Decisions` (minor, optional)

- **Location:** plan:9-18; design "End-to-end check" 1, 3, and 4.
- **Defect:** Three departures from the design go unrecorded: the sign-ins run in a throwaway Playwright context, not "Claude's Chromium profile"; the sign-in page joins the graded renders; and design check 4's "`apply.sh orpheus --check` exit 0" is replaced by checks that can fail.
- **Proposed fix:** Add one line for each to T9's decisions entry and the PR's `## Decisions`.

### 21. Fact 7's source line does not say what the plan claims (minor, optional)

- **Location:** plan:73.
- **Defect:** The plan says Survey "names the inks as its status text colors (`DESIGN.md:31`)". The line itself calls the inks "the status colors for alert headings". The choice stands on the contrast figures, but the claim goes into `docs/decisions.md`.
- **Proposed fix:** Quote the line as written, and rest the choice on the measured ratios.
