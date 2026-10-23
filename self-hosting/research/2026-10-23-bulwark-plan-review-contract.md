# Bulwark plan review: contract and criteria lens

Target: `self-hosting/plans/2026-10-23-bulwark-plan.md` at `2bb9672`. Design: `self-hosting/specs/2026-10-21-bulwark-design.md`. Sources read: Bulwark 1.17.1 (scratchpad checkout, `VERSION` 1.17.1), Stalwart v0.16.27 (sparse), Survey v1.2.0, servers `main` at `e036a70`.

Counts: 1 blocker, 11 major, 12 minor (one of them over-ceremony).

## Blocker

### B1. The theme T3 builds is a package Bulwark never reads from the config directory (blocker, correctness)

- **Location:** plan:39 (T3: "writes `roles/bulwark/config/themes/survey/manifest.json` ... and `skin.css`") and plan:34 (config mounted read-only, `ADMIN_CONFIG_READONLY=true`).
- **Defect:** Bulwark loads installed themes only from `<ADMIN_CONFIG_DIR>/themes/registry.json`, `themes/<id>.css`, and `themes/<id>.skin.css` (`lib/admin/plugin-registry.ts:14-16, 358-366, 457-462, 481-488`). A `manifest.json` plus `skin.css` is the upload package. Only the admin install path compiles it (`lib/extension-package.ts` `readThemePackage`, then `saveTheme`), and that path calls `assertWritable` (`plugin-registry.ts:378`), which a read-only config refuses. The admin dashboard is off by design anyway. Nothing loads `themes/<id>/manifest.json` at boot: `plugin-dev.ts` covers plugins only, under `PLUGIN_DEV_DIR`. As written, Bulwark would start with no Survey theme. `policy.json`'s `defaultThemeId` would name a theme that does not exist, and every built-in would be disabled, so users get the unstyled base. T3's tests (`build --check`, tamper, floor, banned patterns) all pass anyway, because none of them checks that Bulwark can load the output. The manifest fields the plan names also leave out the ones `checkThemeManifest` requires (`id`, `name`, `version`, `author`, `description`, `type: "theme"`, `variants: ["light","dark"]`; `extension-package.ts:568-580`). Without `variants` containing `dark`, the compiler emits no `.dark` block (`lib/theme-compiler.ts:213, 251`).
- **Proposed fold:** Have `build` emit the installed form: `config/themes/registry.json` with one entry (`id`, `name`, `version`, `author`, `description`, `variants`, `enabled: true`, `hasSkin: true`, `installedAt`/`updatedAt` fixed for reproducibility, and `contentHash` = SHA-256 of css + `\0` + skin, per `plugin-registry.ts:384`), plus `config/themes/<id>.css` and `config/themes/<id>.skin.css`. The `.css` must be what `compileAdvancedTheme` would write: `:root { --color-<token>: v; --radius-*; --font-* }` and `.dark { ... }`, only those two selectors (`theme-compiler.ts:46-56, 117-143, 199-260`), which takes a few lines of stdlib Python. Keep `manifest.json` beside it as the human record if wanted. Because this skips Bulwark's install-time sanitizers, T3's test must stand in for them: the theme CSS holds only `:root` and `.dark` rules (`lib/theme-loader.ts` `validateThemeSelectors`), and both files are free of every `DISALLOWED_CSS_PATTERNS` entry (`lib/plugin-types.ts:1367-1379`), not just the three the plan names. Add live proof to T5: the theme's CSS route (`app/api/admin/themes/[id]/css`) answers 200, and in the signed-in page `getComputedStyle(document.documentElement).getPropertyValue('--color-background')` equals Survey `base-100` (`#f7f7f3` light). Name the theme id once (for example `survey-907`) and assert that `policy.json`'s `defaultThemeId` equals the registry entry's id.

## Major

### M1. T5's ban check passes whether or not the allowlist works (major, correctness)

- **Location:** plan:60 (T5 step 4), plan:12 (fact 2: "no probe runs").
- **Defect:** Step 4 runs after correct sign-ins only. Correct passwords cause no `AuthFailure`, so orpheus is on no ban list with or without the `AllowedIp` objects. The check cannot fail, so the allowlist (and whether `stalwart-apply` made Stalwart reread it: `Security::parse` reads `AllowedIp` at bootstrap, `crates/common/src/network/security.rs:77-102`) goes unverified. Fact 2's reason for skipping the probe ("it would spend the allowance it measures") no longer holds once T4 is live, since an allowlisted address spends nothing (`is_auth_fail2banned` short-circuits on `is_ip_allowed`, `security.rs:295-317`). Fact 3's budget also has no live check.
- **Proposed fold:** Add T5 step 4a, after T4 is applied. From the workstation, through `https://webmail.907.life/api/auth/session`, send 6 wrong passwords for the first test mailbox. Expect 401 for the first five and 429 with `Retry-After` for the sixth (`lib/auth/verify-budget.ts:17, 116-125`; `app/api/auth/session/route.ts:140-145`). Then confirm that ward's ban list holds neither orpheus address and that a correct sign-in from a second network path (Claude's Chromium) still succeeds. Without the allowlist, failures from orpheus count toward Stalwart's limit, so this fails if the allowlist did not take. Record the workstation's address being budgeted and mask it in the excerpt. If Stalwart's per-IP threshold is below 6, the run bans the workstation's address, not orpheus: name the unban step (the runbook's "Unban a client") as the cleanup.

### M2. The plan drops the design's sign-in throttle, and what replaces it is weaker (major, correctness, OWNER FORK)

- **Location:** plan:13 (fact 3), plan:12 (fact 2), design:26 ("Stalwart's plan allowlists orpheus's two addresses and Caddy throttles sign-in posts").
- **Defect:** The design promised two controls. The plan keeps the allowlist and replaces the Caddy throttle with Bulwark's own budget. That budget is per client address only, with no global ceiling on the sign-in routes (`verify-budget.ts:113`, `globalMax: Infinity`, by design) and no per-account limit. The allowlist also removes Stalwart's per-login limit for everything from orpheus: `is_auth_fail2banned` checks `is_ip_allowed(ip) || (per-IP ok && per-login ok)`, so an allowed IP skips the login-keyed limit too (`security.rs:298-309`). The net effect is that a distributed guesser through webmail gets 5 tries per source address per 15 minutes against any mailbox, with no account-level stop. The exemption also covers every other process on orpheus (Immich, rclone, any future container). The Brief records the mechanism but not this residual risk, and nothing in `## Decisions` asks whether it is acceptable.
- **Options:**
  - (a) Accept it: the allowlist plus Bulwark's per-address budget, with the residual risk written into `docs/decisions.md` and the PR's `## Decisions`.
  - (b) Build Caddy with `caddy-ratelimit` (xcaddy, a custom binary outside the cloudsmith package: a new upgrade path) and key a zone on the account name in the sign-in POST body.
  - (c) No allowlist: rely on Bulwark's budget to keep orpheus under Stalwart's per-IP threshold. This fails because there is no global ceiling: N attacker addresses × 5 failures each can ban orpheus for 24 hours (`authBanPeriod` 86400000, `plan.ndjson`).
- **Recommendation:** (a), with the residual risk stated and a "Later" item for a per-account limit (upstream Bulwark issue or option b). Option (c) turns the risk into a denial of service for both users, and (b) adds a build path for one control.

### M3. `apply.sh --check` cannot fail on drift, so T5's check brackets, After-merge step 2, and design E2E check 4 are vacuous (major, correctness)

- **Location:** plan:56 (`--check`, `--apply`, `--check` for ward and orpheus), plan:79 (After merge 2: "show nothing to converge"), design:52.
- **Defect:** `scripts/apply.sh --check` always prints "would copy" for every file of every role, plus present or absent for each secret path, and exits 0 (`scripts/apply.sh:73-96`). It exits non-zero only when `sudo -n true` fails, and it compares nothing with the host. "Nothing to converge" is not an output it ever produces.
- **Proposed fold:** Replace the post-apply `--check` with observables that can fail:
  - `apply.sh orpheus --check` lists `secret /etc/bulwark/session-secret: present`.
  - On orpheus, `systemctl is-active bulwark.service` reads `active`, and `docker compose -f /opt/bulwark/compose.yaml ps --format json` shows the container `running`.
  - `docker inspect --format '{{index .RepoDigests 0}}'` on the running container ends in the digest pinned in `roles/bulwark/compose.yaml`.
  - On ward, the `Http` object reads back with `usePermissiveCors: true` and two `AllowedIp` rows (read-only through `stalwart-cli`).

  For After-merge step 2, say what is compared: the installed `/opt/bulwark/compose.yaml` and the `/opt/servers/roles` tree match `main` (`sha256sum`). Dropping the four pre-apply `--check` runs that carry no signal also saves clock.

### M4. A wrong `SESSION_SECRET_FILE` path silently falls back to a tmpfs-generated secret (major, correctness)

- **Location:** plan:34 (T2: "the secret mounted read-only and named by `SESSION_SECRET_FILE`"), plan:37 (T2 test list), plan:66 (T7 rotation steps).
- **Defect:** Bulwark resolves the secret from `SESSION_SECRET`, then from the file, then from config. Failing all three, it generates `.session-secret` in the state directory (`lib/auth/session-secret.ts:25-41, 55-70`), which this plan makes a tmpfs. If the variable names a path that is not the mount target, or the file is unreadable by uid 1001, Bulwark logs nothing fatal and keeps working. Every restart then signs everyone out, and the runbook's rotation becomes a no-op. No T2 test or T5 step would notice.
- **Proposed fold:**
  - T2 test: the `SESSION_SECRET_FILE` value equals the container-side target of a `:ro` volume whose host side is `/etc/bulwark/session-secret`, and `SESSION_SECRET` is not set anywhere in the compose file.
  - T5: after start, `docker compose exec bulwark test ! -e "$ADMIN_STATE_DIR/.session-secret"` succeeds, which shows that no generated secret exists.

### M5. The logo and favicon URLs are unspecified, and the obvious reading serves 404s (major, correctness)

- **Location:** plan:35 (T2: "the logo and favicon URLs pointing at the marks T3 makes"), plan:52 (T3: marks are `branding/benchmark-light.svg` and `-dark.svg` and a favicon).
- **Defect:** A `/branding/...` URL resolves against the image's `public/` directory (`.env.example:250-299`). Files in the config directory are served only from `<config>/branding/` at `/api/admin/branding/<file>` (`app/api/admin/branding/[filename]/route.ts:6-8, 45`; `lib/admin/branding-asset.ts:14-15`). The plan names neither the directory nor the URL form. It also leaves unnamed which variables to set: `FAVICON_URL`, `APP_LOGO_LIGHT_URL`, `APP_LOGO_DARK_URL`, `LOGIN_LOGO_LIGHT_URL`, `LOGIN_LOGO_DARK_URL`. The login logos otherwise default to the Bulwark logo (`lib/admin/types.ts:224, 232-233`), which contradicts design:30. No test or live step loads a mark.
- **Proposed fold:** In T3, put the marks at `roles/bulwark/config/branding/`. In T2, set all five variables to `/api/admin/branding/<file>.svg`. T2 test: every branding variable names a file that exists under `roles/bulwark/config/branding/`. T5: each URL answers 200 with `image/svg+xml`, and the sign-in page's logo `img` resolves to the mark, not `Bulwark_Logo_*`.

### M6. The contrast gate names no pairs, so it can pass with zero checks, and it conflicts with a standing answer (major, correctness)

- **Location:** plan:52 (T3: "checks each text pair at 4.5:1 and each control edge at 3:1"; test "a pair forced below the floor fails"), plan:89 (standing answer: "a mapped pair fails contrast: Keep Bulwark's value for that hook").
- **Defect:**
  - The plan never lists the pairs. A script that checks an empty or partial list passes `build --check` and the floor test, provided the forced pair is one it happens to check.
  - The floor test names no fixture or mechanism for forcing a value.
  - T3 says a failing pair fails the build, while the standing answer says to keep Bulwark's value and continue. The executor can follow the standing answer only by changing the gate, and nothing records how.
  - Survey's status colors as text fail on `base-100`: `--color-warning` `#c9952e` is about 2.6:1 on `#f7f7f3`. Survey supplies `--cairn-*-ink` for status text, and the plan's table does not map it. Some pair will very likely trip this.
- **Proposed fold:**
  - Enumerate the pairs in the plan, for both light and dark: each `*-foreground` on its ground, `foreground` on `background`, `muted-foreground` on `background` and on `muted`, `primary-foreground` on `primary`, each status color's `-foreground` on that status color, `primary` on `background` (links), `input` on `background` (3:1), and `ring` on `background` (3:1).
  - Have the script print each pair with its ratio. The test asserts the printed count equals the list's length.
  - Floor test fixture: a copy of `survey-vars.css` with `--color-base-content` set to `#d9d6c9`, passed through a `--vars FILE` argument, expecting a non-zero exit that names the pair.
  - Add an explicit exceptions table in `build` (hook, reason, Bulwark value kept). Each row must also appear in `## Decisions` and the drafted upstream issue, and the test checks that each exception's hook is absent from the emitted tokens.

### M7. Two existing guard tests fail the gate, and the plan does not say to re-baseline them (major, correctness)

- **Location:** plan:30 (T1 edits `hosts/orpheus/secrets.txt`), plan:32 (T2 edits `hosts/orpheus/roles.txt`).
- **Defect:**
  - `tests/orpheus-golden.test.sh` pins the SHA-256 of `hosts/orpheus/secrets.txt` and `hosts/orpheus/roles.txt` and fails when either changes. Its header asks each pass that changes orpheus on purpose to say so there, as the bookmarks pass did.
  - `tests/apply.test.sh:63, 111, 118` hard-codes orpheus's role list and the `--apply` order string, including eleven `install -m` secret installs. Adding `bulwark` before `caddy` and one secret row breaks both lines.
  - Neither test is in T1's or T2's test list. The executor meets two red guards mid-task and has to decide on its own to re-hash them.
- **Proposed fold:** In T1 and T2, name both edits:
  - `orpheus-golden.test.sh`: new hashes for the two host files and a header sentence ("the Bulwark pass added the bulwark role and its session secret").
  - `apply.test.sh`: add `bulwark` to the role loops at lines 63 and 111, and to line 118's order with a twelfth `install -m`.

  Add `tests/restore-drill.test.sh:417`'s "never installs" loop for the ward drill if bulwark should be covered there too.

### M8. Three of the design's outcome promises go unchecked: search, calendars, and contacts (major, correctness)

- **Location:** design:20 ("read, search, and send ... and use their calendars and contacts there"), plan:59 (T5 step 3).
- **Defect:** T5 checks sign-in, send, and read. Nothing exercises search, the calendar view, or the contacts view, all of which ride Stalwart's JMAP through the same CORS path and could fail on their own (missing capability, blocked method). The design's Outcome is the contract, and three of its five verbs have no evidence.
- **Proposed fold:** Add to T5 step 3, as the first test mailbox:
  - Search by the test message's subject and see exactly one result.
  - Open Calendar and Contacts, see each load with no error toast and no CORS error in the console (read with `read_console_messages`), and create and then delete one event and one contact. These are test-mailbox data and leave nothing behind.

  Excerpt each result under `## Decisions`.

### M9. T6 names no graded devices against a specimen of a different app, so its verdict is arbitrary (major, correctness)

- **Location:** plan:64 (T6).
- **Defect:** The specimen (`survey-theme/reference/2026-10-07-approved-specimen.html` at `c19e7ac`, present only in history, not in the cairn-themes working tree) is a cairn page, not a mail client. A grader comparing Bulwark renders to it has no shared layout, so "no STRUCTURAL verdict" depends on which devices it chooses to grade, and the result can be vacuous or unbounded. The plan also does not say how to render the specimen (viewport, light and dark) or which file to use.
- **Proposed fold:**
  - Name the graded devices as the design's "Comes through" list (design:28): grounds `base-100/200/300`, text `base-content` and `muted`, primary accent, status colors, radii 3px and 4px, flat depth, field edge, the alert's 4px status bar, and the dashed contour rule under sidebar groups. Have the grader return one verdict per device.
  - Render the specimen from `git -C ~/Projects/cairn-themes show c19e7ac:survey-theme/reference/2026-10-07-approved-specimen.html` at the same viewport, in light and dark (`emulateMedia`).
  - Keep the named gaps (faces, contour texture) as pre-declared.

### M10. Nothing tests the alert wiring for `webmail_ping` (major, correctness)

- **Location:** plan:68 (T8).
- **Defect:** The three named cases (200, 503, rejected fetch) exercise the probe. Leaving `webmail_ping` out of the `media_down` loop (`cloudflare/monitor/src/alerts.ts:91`) still passes all three, and the check then records failures that never alert. The cases also do not state the expected verdict for each.
- **Proposed fold:**
  - State the expected verdicts: 200 passes, 503 fails, and a rejected fetch fails.
  - Add a case after the model of `tick.test.ts:324-332`: `webmail_ping` failing `media_down.threshold` times in a row raises one alert whose body contains `webmail_ping`.
  - Add `"webmail_ping": true` to `config.json` explicitly, since `music_ping` shows a check can be configured off.

### M11. The theme mapping departs from the recipe and the design without a recorded ruling (major, correctness, OWNER FORK)

- **Location:** plan:41-50 (mapping table), plan:52 (marks "in `base-content`"), plan:9 ("Four facts ... each goes in `## Decisions`").
- **Defect:**
  - The design (design:28) and the recipe (Survey `DESIGN.md:202`) both say "accents to `--color-primary` and `--color-secondary`". The plan maps Bulwark's `secondary` and `accent` to `base-200`, so Survey's `--color-secondary` (`#8a5f36`) and `--color-accent` (`#2e4a5c`) appear nowhere.
  - The benchmark triangle in Survey is drawn in `--site-contour` (`theme/components.css:68-73`), not `base-content`.
  - Both are taste departures from a ruled theme ("Use the theme."). Neither is among the facts headed for `## Decisions`.
- **Options:**
  - (a) Keep the plan's mapping and record both departures.
  - (b) Keep the role mapping for `secondary` and `accent` grounds, but map Survey `primary`, `secondary`, `accent`, `success`, and `error` onto Bulwark's `chart-1` to `chart-5` (`app/globals.css:71-75`), so Survey's secondary shows where Bulwark uses categorical color. Draw the marks in `--site-contour` as Survey does.
  - (c) Map Survey `secondary` onto Bulwark `accent` (hover and selected ground). This risks a saturated hover and breaks the role semantics.
- **Recommendation:** (b), recorded under `## Decisions`. It honours both the recipe line and shadcn's roles at no extra cost.

## Minor

### m1. `radii` keys are unstated (minor, correctness)

- **Location:** plan:52 ("`radii` take `--radius-field` (3px) and `--radius-box` (4px)").
- **Defect:** `ThemeRadii` takes `sm`, `md`, `lg`, `xl`, and `full`, emitted as `--radius-<key>` (`lib/plugin-types.ts:49-55`; `theme-compiler.ts:117-124`). Nothing ties field and box to keys, so two executors produce two themes. `full` must stay a pill, or Survey's `--radius-selector` (2rem) is lost.
- **Proposed fold:** Name the keys: `sm` and `md` take `--radius-field`, `lg` and `xl` take `--radius-box`, and `full` is untouched. The T3 test asserts the emitted values.

### m2. T1's negative owner test passes before the change, and the owner departs from the design (minor, correctness)

- **Location:** plan:30.
- **Defect:**
  - `render.sh:69` refuses any owner that does not match `^[a-z_][a-z0-9_-]*$`, so `1001` is refused today and the plan's "If ... does not take a numeric owner" is already settled. The `1001x` case is refused today too, so that test cannot fail before or after the change.
  - The design says "a root-only file" (design:25), and the plan makes it 0400 owned by uid 1001. That departure is not among the recorded facts.
- **Proposed fold:** Drop the "if" and teach the regex `^([a-z_][a-z0-9_-]*|[0-9]+)$`. Keep the `1001x` case, and add the case that does discriminate: `1001` renders with owner 1001 (it fails before the change), and `root` still renders. Record the owner change under `## Decisions` (the container runs as `nextjs`, `Dockerfile:51,56`).

### m3. T4 does not name the op shape for `AllowedIp` or `Http`, so a rerun can duplicate rows or break existing tests (minor, correctness)

- **Location:** plan:54.
- **Defect:** The plan is applied on every `apply.sh ward --apply`. A `create` op for `AllowedIp` duplicates rows on each run. A second `Http` line breaks `tests/stalwart.test.sh:75-76`, whose `jq select(.object == "Http")` expects one line.
- **Proposed fold:** Specify `usePermissiveCors: true` on the existing `Http` `update` line, and `{"@type":"upsert","object":"AllowedIp","matchOn":["address"],...}`. Test both, and that `select(.object=="Http")` yields one line.

### m4. The free-memory standing answer has no step that reads memory (minor, correctness)

- **Location:** plan:92, design:36 ("the plan re-reads it").
- **Defect:** No task runs `free -m` on orpheus, so the standing answer never triggers.
- **Proposed fold:** T5 opens with `ssh orpheus free -m` and excerpts the `available` column.

### m5. T5 step 2's "does not offer a sign-in" has no observable (minor, correctness)

- **Location:** plan:58.
- **Proposed fold:**
  - `curl -sS https://webmail.907.life/api/admin/auth` returns `"enabled":false` (`app/api/admin/auth/route.ts:225-228`).
  - `/api/setup/status` returns `"state":"env-managed"` (`lib/setup/state.ts:23-27`). This also proves the setup wizard is closed.
  - The T2 test asserts that no `admin.json` exists under `roles/bulwark/config/`.

### m6. The T2 tests skip the settings that fact 3 and the admin-off promise rest on (minor, correctness)

- **Location:** plan:37.
- **Defect:** Fact 3 depends on one proxy hop. "Settings sync off" and "no custom JMAP endpoint" are promises too. None of them is asserted.
- **Proposed fold:** Assert that `TRUSTED_PROXY_DEPTH` is absent or `1` (default 1, `lib/admin/session.ts:166`), that `SETTINGS_SYNC_ENABLED` is absent or `false`, and that `ALLOW_CUSTOM_JMAP_ENDPOINT` is absent or `false` (`lib/admin/types.ts:292, 310`). Add a check, after `tests/webdav.test.sh`'s pattern, that no other orpheus role binds port 3000.

### m7. Fact 1 overstates the browser's behavior, and the wording goes into `docs/decisions.md` for good (minor, correctness)

- **Location:** plan:11 ("a browser never attaches cookies or a saved login to a cross-origin call").
- **Defect:** With `Access-Control-Allow-Origin: *`, a credentialed request that needs a preflight fails at the preflight, but a simple request (a GET with no custom headers) is still sent with credentials. The browser only withholds the response. The conclusion holds, because JMAP calls carry `Authorization` and so need a preflight, but the stated mechanism is wrong.
- **Proposed fold:** Reword: "the Fetch standard does not expose a response to a credentialed request when the allowed origin is `*`, and a request carrying `Authorization` stops at its preflight, so another site cannot read ward's answers with the visitor's credentials."

### m8. T8's live acceptance does not name what to read in D1 (minor, correctness)

- **Location:** plan:68 ("read with the Cloudflare D1 query tool on `servers-monitor`").
- **Proposed fold:** Name the table, column, and expected row (from `cloudflare/monitor/migrations/`): for example, the latest row for `webmail_ping` with `ok = 1` and a timestamp after the deploy.

### m9. Regenerating the theme vendors only `survey-vars.css`, while the skin rules come from `components.css` (minor, optional)

- **Location:** plan:39, plan:66 (T7: "vendor the new `survey-vars.css`, `build`, the visual gate").
- **Defect:** A Survey release that changes the alert, field, or contour rule in `components.css` would not reach `skin.css`, and `build --check` cannot notice.
- **Proposed fold:** Vendor `components.css` beside `survey-vars.css` with the same tag header, and have `build` copy the three rules from it by selector, or fail if it cannot find one.

### m10. After-merge test-message deletion names no tool and no acceptance (minor, correctness)

- **Location:** plan:80.
- **Proposed fold:** Use `scripts/mail-test-ids.sh list`, then `stalwart-jmap find` and `scripts/ward-mail-delete.sh probe|probe2 <ids>`, reading each mailbox's counts before and after. Acceptance: each difference equals the number of copies found (the sent copy and the received one), as L8 and C3 state.

### m11. The new role's install path has no test that it is safe to rerun or that it refuses without the secret (minor, optional)

- **Location:** plan:32 ("an `install.sh` that is safe to rerun"; `ConditionPathExists`).
- **Proposed fold:** Copy `roles/immich/install.sh`'s guard (start only when the secret exists, otherwise print the render hint), and test it under the harness: with no `/etc/bulwark/session-secret`, it installs the unit and does not start it.

### m12. Over-ceremony: T6's three-round loop leaves its live re-apply unstated and costs the most clock (minor, optional)

- **Location:** plan:64, plan:93.
- **Defect:** Each round means a commit, `apply.sh orpheus --apply` (the theme lives in the role), a container restart, eight renders, and a fresh `visual-verifier` dispatch, so three rounds are roughly the cost of the theme task again. The re-apply step itself is not written down. With M9's device rows, most fixes are token swaps that one round confirms.
- **Proposed fold:** Cap the loop at two rounds. State that each round re-runs `build`, commits, and applies orpheus. In round two, re-grade only the devices that failed.
