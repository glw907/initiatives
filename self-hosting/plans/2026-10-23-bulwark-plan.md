Initiative: self-hosting

# Bulwark webmail: plan

## Brief

This plan builds the approved design `self-hosting/specs/2026-10-21-bulwark-design.md` (initiatives#114, `38d5b27`): Bulwark on orpheus at `webmail.907.life`, signing in to ward, themed by Survey's theme-limited recipe, with its upkeep and upgrades in the runbook. One servers branch and one workstation branch, whose PRs come back to Geoff in one packet through `conductor-servers`. The planned path is 365 minutes against the design's 300, under the 600-minute line where the standing answer applies. Nothing here needs Geoff before launch.

Four facts found at planning correct the design's mechanisms without changing its outcome, and each goes in the servers PR's `## Decisions`:

1. **CORS.** Stalwart has no per-origin CORS. Its one switch, `Http.usePermissiveCors`, sends `Access-Control-Allow-Origin: *` with fixed allow-headers and methods and no `Access-Control-Allow-Credentials` (Stalwart v0.16.27, `crates/common/src/config/network.rs:404-427`). Ward sends no CORS header today: a preflight from `https://webmail.907.life` to `/jmap/session` answered 204 with none (probed 2026-10-23). Bulwark's browser code calls the JMAP server directly (`lib/jmap/client.ts:1397`), so the switch must go on. The Fetch standard refuses a wildcard origin on a credentialed request, so a browser never attaches cookies or a saved login to a cross-origin call, and another site can reach ward only with credentials it already has, as curl can today.
2. **Auto-ban.** Bulwark's sign-in routes check each password from orpheus (`app/api/auth/session/route.ts:154`, `resolveJmapIdentity`), so the ban risk the design names is real, and no probe runs (a probe would spend the allowance it measures). Stalwart's forwarded-header trust is global: with `Http.useXForwarded` on, it reads `Forwarded` and `X-Forwarded-For` from every connection (`crates/http/src/request.rs:749-775`), so turning it on would let any client choose its own address. The plan instead adds Stalwart `AllowedIp` objects for orpheus's IPv4 and IPv6 addresses, which the ban checks skip (`crates/common/src/network/security.rs:83-102, 220`).
3. **The throttle.** Stock Caddy has no rate limiter (that is the third-party `caddy-ratelimit` module), so Caddy gets none. Bulwark already budgets sign-in failures per client address: 5 per 15 minutes (`lib/auth/verify-budget.ts:16-17, 115`), keyed on the address Caddy forwards, so Bulwark trusts exactly one proxy hop.
4. **The record type.** `webmail` is a CNAME to `orpheus.907.life`, like `dav` (`cloudflare/dns/orpheus`), in place of the design's A and AAAA pair.

The advisory watch the design names (Pass 6's C6) is not built yet. This plan amends C6's line in the base plan to watch `bulwarkmail/webmail` too, and T7 adds it to the watch list if C6 has merged first.

## Entry

`servers-backlog-2` has merged, since it edits `roles/caddy/Caddyfile`, `docs/runbook.md`, and `cloudflare/monitor/test/tick.test.ts`. No other servers executor is live (C6 included): `claude agents --json`, and `git -C /var/home/glw907/Projects/servers status`. The servers main checkout is on `main`, clean, and level with `origin/main`. `git -C ~/.dotfiles diff --quiet -- secrets/values.age` passes.

## Pre-flight

None. The live steps run on rules the workstation already holds: `scripts/apply.sh * --apply` and `--check`, `cloudflare/dns.sh --apply` and `--check`, ssh to both hosts under the 2026-10-22 server rule, and the `secret-set.sh` worktree form. The test mailbox passwords are `STALWART_PASSWORD_TEST` and `STALWART_PASSWORD_TEST2` (`docs/runbook.md:479`). `cloudflare/deploy.sh monitor` may meet the classifier outside the cutover's wording; the standing answer covers a denial.

## Tasks

The servers branch is `bulwark`, cut from `origin/main`; the workstation worktree is `.claude/worktrees/self-hosting-bulwark` on branch `self-hosting-bulwark`, cut from `origin/main`. Every task is `auth-data` unless marked, runs test-first, and gets a `diff-reviewer` task-scope read while CI runs. Line numbers are from servers `main` at `e036a70`; follow the function if a line has moved.

- **T1. The session secret (45 min, pair with T4).** Generate 48 random bytes, base64url, as `BULWARK_SESSION_SECRET`, and store it with `secret-set.sh` into the workstation worktree's `secrets/values.age` and the overlay `$XDG_RUNTIME_DIR/self-hosting/secrets-bulwark`, per the base plan's "Secrets in the age store" (decrypt back and compare hashes, commit, push, open the workstation PR as a draft). Add the template `secrets/templates/orpheus/bulwark-session-secret.txt` and the line `bulwark-session-secret.txt /etc/bulwark/session-secret 0400 1001` to `hosts/orpheus/secrets.txt`; uid 1001 is the image's `nextjs` user (Bulwark `Dockerfile:51,56`). If `secrets/render.sh` does not take a numeric owner, teach it one, refusing anything that is neither a name nor digits. List the name in both registries. *Test* (`tests/render.test.sh`): the file renders with mode 0400 and owner 1001, the value appears in no output or ssh log, and an owner like `1001x` refuses. *Acceptance*: tests pass, and the pushed workstation blob decrypts to the stored hash.

- **T2. The role (90 min, pair with T3).** `roles/bulwark/` after `roles/immich/`'s shape: `compose.yaml` installed to `/opt/bulwark`, `systemd/bulwark.service` (`Type=oneshot`, `RemainAfterExit=yes`, `ConditionPathExists=/etc/bulwark/session-secret`), and an `install.sh` that is safe to rerun. Add `bulwark` to `hosts/orpheus/roles.txt` before `caddy`. The compose file:
  - `image: ghcr.io/bulwarkmail/webmail:<newest release>@sha256:<index digest>`, read at build time as the SHA-256 of `skopeo inspect --raw` (1.17.1's index was `sha256:4a766a3f966b0ee382a68475b59aea91b334e633644196eac4aada07c8fd4958`, listing amd64 and arm64, on 2026-10-23); `ports: ['127.0.0.1:3000:3000']`; journald logging; `restart: always`.
  - The config directory `roles/bulwark/config` installed to `/opt/bulwark/config` and mounted read-only at `ADMIN_CONFIG_DIR`; `ADMIN_CONFIG_READONLY=true`; a tmpfs at `ADMIN_STATE_DIR`; the secret mounted read-only and named by `SESSION_SECRET_FILE`.
  - `JMAP_SERVER_URL=https://ward.907.life`, `STALWART_ADMIN_ACCESS=off`, no `ADMIN_PASSWORD`, `BULWARK_TELEMETRY=off`, settings sync off, one trusted proxy, `APP_NAME="907.life Mail"`, and the logo and favicon URLs pointing at the marks T3 makes. Read each variable's name and accepted values from the pinned release's `.env.example` and record any that differ.

  In `roles/caddy/Caddyfile`, add a `webmail.907.life` site proxying to `127.0.0.1:3000`, with a comment saying why it carries no throttle (Brief, fact 3). In `cloudflare/dns/orpheus`, add `webmail CNAME orpheus.907.life ttl=300 proxied=no`. *Test* (`tests/bulwark.test.sh`): the image names a digest; every port binds loopback; the config mount is `:ro`; `STALWART_ADMIN_ACCESS=off` is set and `ADMIN_PASSWORD` appears nowhere; telemetry is off; `apply.sh orpheus --check` under the harness lists the role. `tests/dns.test.sh` sees the record. *Acceptance*: tests pass.

- **T3. The theme (90 min, `ordinary`, pair with T2).** Survey's "Theme-limited app" recipe (Survey v1.2.0, `DESIGN.md`). Vendor `theme/survey-vars.css` from the tag as `roles/bulwark/theme/survey-vars.css` with the tag in a header line, so the gate needs no network. A stdlib script `roles/bulwark/theme/build`, run as `python3 -I`, writes `roles/bulwark/config/themes/survey/manifest.json` (Theme API v2: `apiVersion: 2`, `tokens.light`, `tokens.dark`, `radii`, `typography`, `density`) and `skin.css`, and `--check` compares the committed output with a fresh build. Map by role, not by name, since Bulwark's names follow shadcn, where `secondary` and `accent` are quiet grounds:

  | Bulwark | Survey |
  | --- | --- |
  | `background`, `card`, `popover` | `base-100` |
  | `muted`, `secondary`, `accent`, `sidebar` | `base-200` |
  | `border`, `sidebar-border`, `selection`, `sidebar-accent` | `base-300` |
  | every `*-foreground` on those grounds, `foreground` | `base-content` |
  | `muted-foreground` | `muted` |
  | `input` | `site-field-border` |
  | `primary`, `ring`, `unread` / `primary-foreground` | `primary` / `primary-content` |
  | `destructive`, `success`, `warning`, `info` and their foregrounds | the status colors and their `-content` |

  `radii` take `--radius-field` (3px) and `--radius-box` (4px). `typography.fontSans` is `"Karla Variable", "Karla", system-ui, sans-serif`, `fontDisplay` leads with `"Spectral"`, `fontMono` with `"Monaspace Neon"`. `skin.css` carries what is pure CSS: the input edge in `--site-field-border`, the alert's 4px status bar on `base-200`, and a dashed `--site-contour` rule under sidebar groups, each copied from `theme/components.css` with its variables and scoped to Bulwark's selectors (read from the pinned release). The output holds no `url(`, `@import`, or `image-set(` (`lib/plugin-types.ts:1367`). The script checks each text pair at 4.5:1 and each control edge at 3:1, and a pair below the floor fails the build; per the recipe it never substitutes a nearby color. `config/policy.json` sets `themePolicy.defaultThemeId` to the theme, disables every built-in theme, and leaves `defaultColorMode` null and `lockColorMode` false. The marks are `branding/benchmark-light.svg` and `-dark.svg` and a favicon: Survey's benchmark triangle (`components.css`, `site-benchmark`) in `base-content` and in the dark `base-content`. *Test* (`tests/bulwark-theme.test.sh`): `build --check` passes; a tampered token fails it; a pair forced below the floor fails; the output has no banned pattern. *Acceptance*: tests pass.

- **T4. Ward accepts the webmail (40 min, pair with T1).** In `roles/stalwart/plan.ndjson`, set `Http.usePermissiveCors` to true, and add two `AllowedIp` objects for orpheus's addresses (from `cloudflare/dns/orpheus`) with `reason` "orpheus: Bulwark sign-in checks" and no `expiresAt` (`crates/registry/src/schema/structs.rs:173-182`). Confirm both object shapes against stalwart-cli 1.0.13's schema on ward, read-only, before writing. If `stalwart-apply` needs a reload for `Http` changes, do it the way the role already does. *Test* (`tests/stalwart.test.sh`): the plan carries the switch and both addresses, and the addresses match the DNS file. *Acceptance*: tests pass.

- **T5. Live, and the end-to-end check (60 min, `live-account`).** From the branch, in this order: `cloudflare/dns.sh --check` then `--apply`; `scripts/apply.sh ward --check`, `--apply`, `--check`; `scripts/apply.sh orpheus --check`, `--apply`, `--check`. Then:
  1. A preflight from `https://webmail.907.life` to `https://ward.907.life/jmap/session` returns `access-control-allow-origin: *`.
  2. `curl -sS https://webmail.907.life/api/health` reports healthy, and `https://webmail.907.life/admin` does not offer a sign-in.
  3. In Claude's Chromium profile, sign in as the first test mailbox, send to the second, and sign in as the second to read it. Record each test message's Message-ID with `scripts/mail-test-ids.sh add`.
  4. Read ward's ban list read-only and confirm orpheus is on no list after the sign-ins.

  *Acceptance*: each step's output excerpt goes under `## Decisions`, credentials and IPs masked.

- **T6. The visual gate (60 min, `ordinary`).** `visual-verifier` grades full-page renders of the sign-in page, the inbox, an open message, and the composer, in light and dark, against Survey's approved specimen (`glw907/cairn-themes` at `c19e7ac`, `survey-theme/reference/`), each in a separate labeled block. Expected gaps (fonts where the faces are not installed, no contour texture) are named in the dispatch so they are not graded as defects. A STRUCTURAL verdict goes back to T3's mapping and is re-applied and re-rendered; the loop guard is three rounds. *Acceptance*: no STRUCTURAL verdict outside the named gaps, and the main loop has read each render itself.

- **T7. Runbook and records (60 min, `ordinary`, pair with T8).** In `docs/runbook.md`, an operator-guide section "Bulwark webmail": where it runs and what it needs (orpheus, Caddy, ward's JMAP, the CORS switch and the allowlist and why); checking it (`systemctl is-active bulwark.service` reads `active` even when the container died, so the check is `docker compose ... ps` and `/api/health`) and restarting it (`systemctl restart bulwark.service` only); an upgrade (read the release notes, take the newest tag's index digest, `apply.sh orpheus --apply`, the smoke check: health, sign-in, one message) and a rollback (the previous digest, the same steps); regenerating the theme after a Survey release (vendor the new `survey-vars.css`, `build`, the visual gate); rotating `BULWARK_SESSION_SECRET` (store, render, restart; every session signs in again); and rebuilding (the role and the secret restore it, with nothing in the backup). Add a "Webmail" line to the emergency screens' "Check a service and restart it" pointing at those steps, and re-render `EMERGENCY.md` with `scripts/render-emergency.sh --write`. Add Bulwark to the service catalog. In `docs/monthly-review/prompt.txt` step 2, add Bulwark to the release notes read, with its upgrade taking the runbook's steps and no drill copy, since it holds no state. In `docs/addresses.md`, add `webmail.907.life`. In `docs/decisions.md`, record the host, the theme ruling and the font gap, and the four Brief facts. If C6 has merged, add `bulwarkmail/webmail` to its watch list with its pinned version read from `roles/bulwark/compose.yaml`, and a test case for it. *Test*: the render check passes. *Acceptance*: the gate passes.

- **T8. The monitor (45 min, `ordinary`, pair with T7).** Add `webmail_ping` (`https://webmail.907.life/api/health`) to `HTTP_PROBES` (`cloudflare/monitor/src/checks.ts:17-23`), `CheckName` (`types.ts`), `config.json`, and the down-alert list in `alerts.ts:91`, with `tick.test.ts` cases for 200, 503, and a rejected fetch. In the main loop after the arm returns, run `cloudflare/deploy.sh monitor`. *Test*: `npm test` in `cloudflare/monitor`. *Acceptance*: tests pass, and after the deploy the next tick records `webmail_ping` passing (read with the Cloudflare D1 query tool on `servers-monitor`).

- **T9. Close (50 min).** One whole-branch `diff-reviewer` over the servers branch and the workstation branch, then one batched fix chain quoting its findings verbatim, then the gate (`bash scripts/check.sh`) and the base plan's close checklist. Mark BACKLOG #13 done with the PR number. File through `log-issue`: the upstream issue asking Bulwark to let a theme ship fonts (drafted in the servers BACKLOG entry; never filed on GitHub without Geoff), and installing the Survey faces on the workstations. The servers PR body carries `## Brief`, `## After merge`, `## Decisions` (the four Brief facts and T5's excerpts among them), `## Not checked`, `## Found, not done`, the score, and `## STATUS lines`.

**Path**: the T1 and T4 pair at 45, the T2 and T3 pair at 90, T5 60, T6 60, the T7 and T8 pair at 60, T9 50: 365 minutes.

## After merge

The conductor runs these after Geoff approves:

1. Merge the workstation PR, then the servers PR. Pull both checkouts, run `sync.sh --local`, and remove the pass overlay.
2. `scripts/apply.sh orpheus --check` and `scripts/apply.sh ward --check` show nothing to converge.
3. Delete the pass's test messages by Message-ID, as the plan's earlier passes did.

## Standing answers

The design's apply, plus these.

| Situation | Answer |
|---|---|
| A Bulwark variable or theme field differs in the pinned release from what this plan names | Use the release's own name, from its `.env.example` or `lib/plugin-types.ts`, and record it under `## Decisions`. |
| A theme hook cannot take a Survey value, or a mapped pair fails contrast | Keep Bulwark's value for that hook, record it under `## Decisions`, and add it to the drafted upstream issue (the design's standing answer). |
| The browser still reports a CORS error after the switch | Read the listener and `allowedEndpoints` (`plan.ndjson:13`) before anything else; the forum case was a wrong listener. Fix a traced cause and rerun once. |
| Orpheus shows on a ban list during T5 | Unban it per the runbook's "Unban a client from Stalwart's auto-ban", trace why the allowlist missed, fix, and rerun T5 once. |
| Orpheus's free memory reads under 2 GB before T5 | Give the container a `mem_limit` of 768m and record it; under 1 GB, stop for the conductor. |
| `visual-verifier` still returns STRUCTURAL after three rounds | Close with `## Bar unmet: visual gate`, the renders and verdicts attached. |
| The auto-mode classifier denies a live call | The base plan's row: never retried; record the command and the site, continue, list it under `## Not checked`, and send conductor-servers one message. |
| A pair's files overlap | Run the two tasks in sequence and record it. |

Stops: the initiative's path ceiling, a cause the session cannot trace, a secret only Geoff has, and mail on ward that a step would change beyond the pass's own test messages.

## Close

The base plan's "Adapter facts for the servers repo" and its close checklist stand. The pass's PRs go to Geoff in one packet through `conductor-servers`.
