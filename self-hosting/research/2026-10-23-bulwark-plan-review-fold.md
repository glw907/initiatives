# Bulwark plan review: fold record

The fold of the three reviews of `self-hosting/plans/2026-10-23-bulwark-plan.md` at `a6107a1`:

- mechanics, `2026-10-23-bulwark-plan-review-mechanics.md`, cited as `mech`
- contract, `2026-10-23-bulwark-plan-review-contract.md`, cited as `con`
- risk, `2026-10-23-bulwark-plan-review-risk.md`, cited as `risk`

Each finding was checked against Bulwark 1.17.1, Stalwart v0.16.27, Survey v1.2.0, and servers `main` at `e036a70` before it was taken. A finding that several reviews raised folds once, at the root named below, and the others point there. The revised plan renumbers the tasks:

| Old | New | Task |
| --- | --- | --- |
| T1 | T1 | the session secret |
| T2 | T2 | the role |
| T3 | T3 | the theme |
| T4 | T4 | ward |
| (new) | T5 | the webmail driver |
| T8 | T6 | the monitor |
| T5 | T7 | live and the end-to-end check |
| T6 | T8 | the visual gate |
| T7 | T9 | runbook and records |
| T9 | T10 | close |

Counts: 70 findings (mech 31, con 24, risk 15). 63 folded (seven of them in part, with the rest refused); 3 refused whole; 4 owner forks (mech M3, con M2, risk R3, risk R4), which became the plan's two rulings. Two candidate forks, the theme mapping and the privacy and remember-me defaults, were decided rather than ruled, and the reasons are below.

## Probes run by the fold

- Bulwark chart tokens: `chart-1` to `chart-5` appear only in `app/globals.css`, `app/theme-inline.css`, `lib/builtin-themes.ts`, `lib/theme-flat-fields.ts`, and `lib/plugin-sandbox/host-theme.ts`. No file under `components/` or `app/` draws them (grep for `bg-chart`, `text-chart`, `border-chart`, `fill-chart`, `stroke-chart`: none).
- Bulwark class use: `text-destructive` 158 and `text-warning` 40 places; `bg-sidebar-accent` and `bg-sidebar` none.
- Contrast, WCAG relative luminance, on Survey v1.2.0's `survey-vars.css`:
  - Light `muted` on `base-300`: 4.44; on `base-200`: 5.52.
  - Light `warning` on `base-100`: 2.50; light `info` on `base-100`: 4.42.
  - Light inks on `base-100` and `base-200`: info 6.85 and 6.27, success 7.11 and 6.50, warning 6.24 and 5.71, error 7.54 and 6.90.
  - Dark status colors on `base-100` and `base-200`: all over 6.7.
  - `site-field-border` on `base-100`: 3.65 light, 3.63 dark.
- Playwright: `uv run --no-project --with playwright python -I` resolved `playwright` 1.64.1. With `executable_path=/usr/bin/chromium-browser` (Chromium 154), it filled a password field and reported `prefers-color-scheme: dark` under `color_scheme='dark'`.
- Docker Compose v5.6.0: a short-syntax bind of a missing file created it on the host as a root-owned directory and started. A long-syntax bind with `create_host_path: false` refused: "bind source path does not exist".
- `scripts/apply.sh --check` prints and exits 0 at `:73-95`, comparing nothing. `cloudflare/dns.sh --check` compares the zone with the files and fails on a difference (`:218-251`).
- Stalwart's `Authentication` default floor is `passwordMinLength` 8 and `passwordMinStrength` `Three`, the zxcvbn score (`crates/registry/src/schema/structs_impl.rs:3428-3430`). `roles/stalwart/plan.ndjson` sets no `Authentication` line.
- `LOGIN_SHOW_REMEMBER_ME=true` shows the box unticked (`app/(main)/[locale]/login/page.tsx:204, 266`). Web push registers only from the permission prompt (`components/push-notification-prompt.tsx:294`).

## Rulings needed: what became a fork, and what did not

- **Ruling 1, the orpheus allowlist.** The root is mech M3. Con M2 and risk R4 converge on it. The design promised two controls, and stock Caddy cannot give the second. The allowlist lifts the per-login count as well (`security.rs:298-309`). So the choice is between a recoverable denial of service for both users and unbounded distributed guessing on the webmail path. That trade belongs to the owner.
- **Ruling 2, CORS and a household member's ban allowance.** Risk R3. The switch is required for the design's browser-direct JMAP. The only other lever is the ban period, which weakens the ban for every client. Accepting a new attack on the household belongs to the owner.
- **Not a fork: the theme's secondary and accent colors (con M11, mech minor 11).** Option (b) maps Survey's colors onto `chart-1` to `chart-5`. The probe found no component that draws those tokens, so (b) would change nothing visible. Option (c) puts saturated colors on Bulwark's hover and selected grounds, which breaks the recipe's own rule to map hooks by role. That leaves (a), and the design's standing answer already covers it: a Survey value with no hook to take it goes to `## Decisions` and the drafted upstream issue. Fact 7 records it, and T10 adds a second accent hook to the upstream issue. The mark color has one correct answer: Survey draws the benchmark triangle in `--site-contour` (`theme/components.css:68-73`), so the marks take it.
- **Not a fork: the privacy defaults (risk R10, mech minor 13).** The design's posture is that the household's data stays home, with telemetry and settings sync off.
  - The update check is a phone-home of the same class as telemetry, and the monthly review already carries upgrades, so it goes off.
  - Translate sends message text to a public API, the one flow that posture plainly excludes. Caddy answers 404 on that route, and deleting one handle restores it.
  - Web push is opt-in, through the browser's permission prompt, so it stays.
- **Not a fork: remember-me (risk R11).** By default every sign-in persists for 30 days with the encrypted password in the cookie. Showing the box costs one variable and a click on the member's own machines, and it closes the borrowed-machine case. With the box shown it starts unticked. The safer default with the member's own choice is the clear answer.

## Mechanics review

| Id | Disposition |
| --- | --- |
| B1 | Folded, root for con B1. T3 writes the installed form: `themes/registry.json`, `themes/survey.css` in the compiler's shape, and `themes/survey.skin.css`. T7 step 6 checks `/api/plugins` and the CSS routes. Brief fact 6. |
| M1 | Folded. T2's `install.sh` copies the config file by file and restarts `bulwark.service` when the installed tree's hash changes. T8's rounds and T9's regeneration step apply orpheus, which restarts. T2's test covers the restart. |
| M2 | Folded, root for "the ban check cannot fail" (con M1, risk R9). (a) T7 step 3 reads back the objects and the `applied and restarted` line. (b) T7 step 10 proves the 429 on the sixth try. The allowlist proof is T7 step 9 (risk R9). |
| M3 | Owner fork: ruling 1, root for con M2 and risk R4. Fact 2 now says the per-login count is lifted too. |
| M4 | Folded. T5 is the Playwright driver, run through `uv` with the password read from the environment (probed). This also covers risk R12. |
| M5 | Folded, root for con M9. T8 grades one verdict per device from the design's list. Composition and chrome are ungraded. A non-token STRUCTURAL verdict goes to the theme-hook standing answer. |
| M6 | Folded, root for con M6. T3 names the pair list, `selection` maps to `base-200`, and `input` and `ring` are the only 3:1 edges. |
| M7 | Folded, root for con M5. T2 sets all five branding variables at `/api/admin/branding/<file>.svg`. T3 puts the marks under `config/branding/`. T7 step 6 checks each URL. |
| M8 | Folded, root for con M4 and risk R5. T7 step 8 checks the journal line, the state file, and that a sign-in survives a restart. Fact 5 records the owner. |
| M9 | Folded. Standing answers gained "A T7 step fails", "T7's end-to-end check cannot pass", and the visual-gate row now runs T9 and T10. |
| M10 | Folded. T7 writes out steps 1, 5, 6, and 11, and the ban-list read in step 10. |
| M11 | Folded. T4's schema read runs in the main loop before dispatch. T1's store and push run in the main loop, and the Tasks preamble says so. |
| minor 1 | Folded, root for con M7. T1 and T2 re-baseline `orpheus-golden.test.sh` and `apply.test.sh`. |
| minor 2 | Folded. The DNS row check moves to `tests/bulwark.test.sh`. |
| minor 3 | Folded. T3 checks all seven `DISALLOWED_CSS_PATTERNS` and the `:root`/`.dark`-only rule. |
| minor 4 | Folded, root for con m6 and risk R15. T2's test asserts the privileged channels are absent. |
| minor 5 | Folded, root for con m3. T4 extends the existing `Http` line and adds an `AllowedIp` upsert on `address`. The test expects one `Http` line. |
| minor 6 | Folded, root for con m4. T7 step 1 reads memory. |
| minor 7 | Folded, root for risk R8. T7 states the band, and a standing answer says to wait until 04:00. |
| minor 8 | Folded. T5 reads Message-IDs with JMAP `Email/query` and `Email/get`, and T7 step 7 records them. |
| minor 9 | Folded at con M8 (T7 step 7). |
| minor 10 | Folded. T3 lists the seven built-in ids, and T9's upgrade step re-reads them. |
| minor 11 | Folded, optional but free and plainly right. The marks are drawn in `--site-contour` (fact 7). |
| minor 12 | Folded. T9 adds the credentials table row and the monitor section entry. |
| minor 13 | Folded, decided rather than ruled (above). `BULWARK_UPDATE_CHECK=off` and the translate 404 (fact 8, T2). |
| minor 14 | Folded, optional but free. T9 says Bulwark's upgrade needs no snapshot, backup, or drill copy. |
| minor 15 | Folded. T8 is `live-account`, in the main loop. |
| minor 16 | Folded, root for con m2. T1's test fails first on "owner 1001 renders". |
| minor 17 | Refused, optional. Nothing on the other workstation reads the name before its next pull. |
| minor 18 | Folded in part, optional. T9 runs as an arm beside T8, which saves path. It does not run beside T7, because T9 records T7's outcomes. |
| minor 19 | Refused, optional. With the device scoping, one round is likely, so T8 stays at 60 minutes. The three-round guard is a ceiling, not the estimate. |

## Contract review

| Id | Disposition |
| --- | --- |
| B1 | Folded at mech B1. Also taken from con: the `:root`/`.dark`-only test, the computed `--color-background` check in T7 step 7, and a test that `defaultThemeId` equals the registry id. |
| M1 | Folded in part, at mech M2. Refused: the claim that six wrong passwords fail without the allowlist. Stalwart's default `authBanRate` is 100 a day (`structs_impl.rs:35589-35592`), so five failures ban nothing either way. The live budget check is T7 step 10. The allowlist proof is T7 step 9. No cleanup of the workstation's address is needed, because Bulwark calls ward from orpheus. |
| M2 | Owner fork: ruling 1, at mech M3. Option (b), a custom Caddy build, is named in fact 3 as not built. |
| M3 | Folded. The Entry compares the host files' SHA-256 with `main`'s, and After merge step 2 repeats it. T7 steps 2 to 4 replace the empty `--check` runs with checks that can fail. |
| M4 | Folded at mech M8. The T2 test checks that `SESSION_SECRET_FILE` names a path inside the read-only mount and that `SESSION_SECRET` is unset. |
| M5 | Folded at mech M7. The T2 test checks that each branding file exists. |
| M6 | Folded at mech M6. Also taken from con: the printed pair count, the `--vars` fixture, the exceptions table that settles the conflict with the standing answer, and the light status hooks on Survey's inks. The probe confirms warning at 2.50 and info at 4.42. |
| M7 | Folded at mech minor 1. Also taken: `bulwark` joins `restore-drill.test.sh:417`'s never-installs loop. |
| M8 | Folded in part. T7 step 7 checks search and opens Calendar and Contacts. Refused: creating and deleting an event and a contact. The views' loads exercise the path they ride, and the writes add cleanup with no named defect. |
| M9 | Folded at mech M5. Also taken: the specimen rendered from `git show c19e7ac:...` at the same widths, light and dark. |
| M10 | Folded. T6 states each verdict, adds the alert-wiring case, and sets `config.json` to an explicit `true`. |
| M11 | Decided rather than ruled (above). The marks, fact 7, and the upstream issue in T10. |
| m1 | Folded. T3 names the radii keys and leaves `full` alone. |
| m2 | Folded at mech minor 16. T1 names the regex, and fact 5 records the owner. |
| m3 | Folded at mech minor 5. |
| m4 | Folded at mech minor 6. |
| m5 | Folded. T7 step 6 checks `/api/admin/auth` and `/api/setup/status`. The T2 test checks that no `admin.json` exists. |
| m6 | Folded at mech minor 4. The no-other-role-on-port-3000 check is in T2. |
| m7 | Folded. Fact 1 is reworded. |
| m8 | Folded at mech M10. The row is `probe_failures` with `count` 0 (`src/tick.ts:32-37`), not an `ok` column. |
| m9 | Folded, optional but cheap and plainly right. T3 vendors `components.css`, and the build fails when a selector it copies is missing. T9's regeneration vendors both files. |
| m10 | Folded. After merge step 3 names the tools and the count check. |
| m11 | Folded at risk R7. |
| m12 | Folded in part, optional. T8 states each round's re-apply and re-grades only the devices that failed. Refused: the two-round cap. The guard is a ceiling, and scoping makes a second round unlikely. |

## Risk review

| Id | Disposition |
| --- | --- |
| R1 | Folded. After merge carries the back-out: explicit `usePermissiveCors: false`, a `destroy` per `AllowedIp` address, `webmail CNAME absent`, the service removed, orpheus applied from `main`, and the monitor redeployed. Refused: the fixture-plan-diff test. The back-out runs once, by the conductor, and its read-back shows the result, so a test of lines that live on a future branch costs more than it removes. |
| R2 | Folded in part. The Entry requires that backlog-2's applies ran, that the host files match `main`, and that `dns.sh --check` is clean. T7 merges `origin/main` first, and step 2 allows only the pass's own `FAIL`. The STATUS line holds applies from `main`, and the stop covers the rest. Refused: "`apply.sh --check` shows nothing to converge", which `apply.sh` never compares (con M3). The hash comparison replaces it. |
| R3 | Owner fork: ruling 2. |
| R4 | Owner fork: ruling 1, at mech M3. Folded: T9's amendment of `decisions.md:109`. Refused: raising `passwordMinStrength`. The default floor is already zxcvbn score 3 with 8 characters, ward's plan does not lower it, and Bulwark holds each address to 5 tries per 15 minutes. Fact 3 records the floor. |
| R5 | Folded at mech M8. The restart-survival check (T7 step 8) comes from here. |
| R6 | Folded in part. T2's role reserves uid 1001 as `bulwark` and refuses another name, the Entry checks uid 1001 on orpheus, and fact 5 records it. Refused: leaving `render.sh` unchanged with a named owner. `apply.sh` renders before any role runs (`scripts/apply.sh:113-118`), so a named owner fails the first apply. |
| R7 | Folded. T2 gates the stack on the secret, mounts `/etc/bulwark` in long syntax with `create_host_path: false` (probed), and tests it. |
| R8 | Folded at mech minor 7. T4 states the one restart. |
| R9 | Folded, optional, because it is the only check that proves the allowlist: T7 step 9 checks the container's IPv6 state and the host's `src` for ward. |
| R10 | Decided rather than ruled (above). Fact 8 and T2. |
| R11 | Decided rather than ruled (above). Fact 8 and T2. |
| R12 | Folded at mech M4. The driver's throwaway context leaves no cookie in Claude's profile. |
| R13 | Refused, optional. No measured footprint backs a 768m cap, and a cap set too low kills the service. The free-memory standing answer stands. |
| R14 | Folded, optional but free. T9's upgrade step handles a config migration. |
| R15 | Folded at mech minor 4. The `JMAP_SERVER_URL` and impersonation assertions are in T2, and the `/setup` check is in T7 step 6. |

## Method calls made in the fold

- **The driver's language.** The workstation default for a tool that needs a package is Go. T5 instead uses Python with Playwright through `uv run --with`, for three reasons. Playwright is the browser driver the house already names (`visual-verifier`'s rendering recipe). The `uv` form leaves no manifest or lockfile in the servers repo. It was probed on this workstation with the layered Chromium. This is the one contestable point.
- **The path.** The theme's installed form, the driver, and the live checks raise the path from 365 to 440 minutes, under the 600-minute line. Pairing T9 with T8 keeps the runbook's 70 minutes off the path.
