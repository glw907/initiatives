# Bulwark webmail pass

## Brief

This pass gives Geoff and the second operator webmail at `webmail.907.life`: Bulwark on orpheus, signing in to ward's Stalwart, styled with Survey's theme-limited recipe, and carried by the runbook, the monthly review, the advisory watch, and the monitor.

Geoff asked for it on 2026-10-21 (servers BACKLOG #13), ruled the Survey theme the same day ("Use the theme."), and on 2026-10-22 asked for it again with "the Survey look and feel where possible given Bulwark's theming limitations", and for Bulwark's upkeep and upgrades in the runbook. The Survey house style it waited on closed at Survey v1.2.0, whose `DESIGN.md` now carries a recipe written for this app. Pass 6's cutover and the bookmarks pass have merged. The executor launches after `servers-backlog-2` merges, because that pass edits the same Caddyfile, runbook, and monitor test.

Initiative: self-hosting

### Standing answers

- A plan over twice this estimate keeps launching up to the initiative's ceiling and says so in the packet.
- The font gap is accepted, and the pass does not stop on it.
- The auto-ban and CORS probes each have the fix written below, so neither stops the run.
- A Bulwark theme hook that cannot take a Survey value keeps Bulwark's own value and goes in the PR's `## Decisions` and a drafted upstream issue; the pass does not stop on it.

## Outcome

Both mailbox holders can read, search, and send 907.life mail in a browser, and use their calendars and contacts there. Bulwark ([bulwarkmail/webmail](https://github.com/bulwarkmail/webmail), AGPL-3.0, 1.17.1 at 2026-10-22) is a Next.js JMAP client built for Stalwart. Ward runs Stalwart 0.16.27, which meets Bulwark's 0.16 floor.

## What changes

1. **A `bulwark` role on orpheus.** The official image `ghcr.io/bulwarkmail/webmail`, pinned by tag and index digest (it publishes amd64 and arm64), runs under Docker on loopback port 3000, as Immich does. Caddy gets a `webmail.907.life` site with a Let's Encrypt certificate, and `cloudflare/dns/orpheus` gets `webmail` A and AAAA records beside `photos-new`. `JMAP_SERVER_URL` is `https://ward.907.life`, and Bulwark trusts one proxy hop (Caddy).
2. **No state outside the repo.** The config directory (`config.json`, `policy.json`, the theme, the marks) is committed in the role, mounted read-only, with `ADMIN_CONFIG_READONLY=true`. The admin dashboard stays off: `STALWART_ADMIN_ACCESS=off` and no `ADMIN_PASSWORD`, which Bulwark's `.env.example` says leaves it "disabled", so ward's admin account gains no way into Bulwark. The state directory (login timestamps, audit log) is a tmpfs. Settings sync and telemetry stay off. A rebuild from the repo restores Bulwark, so the nightly backup does not change. The one new secret is `SESSION_SECRET`, stored through `secret-set.sh` and read through `SESSION_SECRET_FILE` from a root-only file.
3. **Sign-in.** Mailbox passwords against Stalwart. The browser calls Stalwart's JMAP directly, so Stalwart's plan probably needs `https://webmail.907.life` as a CORS origin; the plan probes it and adds the origin if so. Bulwark's server also calls Stalwart from orpheus, so a run of wrong passwords could make Stalwart's auto-ban block orpheus for both users. The plan probes this, and if it holds, Stalwart's plan allowlists orpheus's two addresses and Caddy throttles sign-in posts.
4. **The Survey theme, by the theme-limited recipe** (Survey v1.2.0, `DESIGN.md` "Theme-limited app"). Bulwark's Theme API v2 bundle (`manifest.json` plus `skin.css`) lives in the role, generated from `theme/survey-vars.css` at the pinned tag by a short script so every value is a Survey token. `policy.json` makes it the default, disables the built-in themes, and leaves the color mode following the system.
   - **Comes through:** the light and dark palettes (grounds to `base-100` through `-300`, text to `base-content` and `muted`, accents to `primary` and `secondary`, status colors), the radii (`--radius-field` 3px, `--radius-box` 4px), flat depth, and, through `skin.css`, the field edge, the alert's 4px status bar, and the dashed contour rule under sidebar groups. Every mapped pair is checked against the contrast floor.
   - **Doesn't:** web fonts and the contour texture. Bulwark's sanitizer removes every `url()` from theme and skin CSS (`lib/plugin-types.ts`, `DISALLOWED_CSS_PATTERNS`), so no face can load. The stacks still name Spectral, Karla, and Monaspace Neon first, so a machine with the faces installed shows them and others fall back to system fonts. The contour texture is inline SVG in markup, which a theme cannot add, and the index rail has no list to sit on.
   - **Marks:** no 907.life logo file exists (searched `~/Projects/907-life`), so the favicon and the light and dark logos are Survey's benchmark triangle as SVG, with `APP_NAME` "907.life Mail".
5. **Runbook.** A Bulwark section in the operator guide covers upkeep and upgrades: where it runs and what it depends on (orpheus, Caddy, ward's JMAP); checking and restarting it; an upgrade (read the release notes, bump the pinned tag and digest, `apply.sh orpheus`, the smoke check) and a rollback (the previous digest); regenerating the theme after a Survey release; rotating `SESSION_SECRET`; and the rebuild note. The service catalog gains a Bulwark row, the emergency screens point a "webmail is down" report at the check-and-restart steps, and `docs/addresses.md` and `docs/decisions.md` record the hostname, the host, the theme ruling, and the font gap.
6. **Maintenance hooks.** The monthly review's upgrade step reads Bulwark's release notes and takes the newest release in a packet part (Bulwark shipped 1.11.0 to 1.17.1 between 2026-09-23 and 2026-10-22). Pass 6's advisory watch adds `bulwarkmail/webmail`, so a security release raises the urgent alert and the emergency patch path. The monitor checks `https://webmail.907.life/api/health`.

## Where it runs

orpheus. Bulwark is a long-running Node server, so Workers alone cannot host it; Cloudflare Containers could, at the cost of the paid Workers plan, cold starts, and a new deploy path with nothing else of the estate on it. Ward runs Stalwart with host networking on port 443, terminating its own TLS, and has no Caddy, so Bulwark there means a proxy in front of the live mail server's HTTPS. orpheus already runs Docker and Caddy for Immich and the bookmark share, with about 6 GB of memory free on 2026-10-21 (`free -m`; the plan re-reads it). Bulwark holds no state, so backup and restore are a rebuild from the repo wherever it runs. The cost is that webmail needs both servers up, and a mail client keeps working when orpheus is down.

## Out of scope

Sign-in through Stalwart's OpenID Connect provider (BACKLOG #12's pass), settings sync, plugins, Bulwark Lite, accounts for household members A, B, and C, a custom image, and installing the Survey faces on the workstations.

## Later

- Ask the Bulwark project to let a theme ship its own fonts, in a GitHub issue Geoff approves first. A custom image with the fonts baked in is the fallback, at the cost of a rebuild for every release.
- Install Spectral, Karla, and Monaspace Neon on pavilion and thinkpad-x1 through the dotfiles, which would show the real faces there with no Bulwark change.

## End-to-end check

1. Sign in at `webmail.907.life` as Pass 5's test mailbox, from Claude's Chromium profile.
2. Send to the second test mailbox and see the message arrive there.
3. Read full-page renders of the inbox, a message, and the composer in light and dark against Survey's approved specimen (`glw907/cairn-themes` at `c19e7ac`, `survey-theme/reference/`), graded by `visual-verifier`.
4. See the monitor's new check pass, and `apply.sh orpheus --check` exit 0.

## Pre-flight

None. Every credential is Claude's to generate, and the test mailboxes exist from Pass 5.

## Risk class and estimate

`auth-data` and `live-account`: it adds a credential, changes Stalwart's config, and touches live servers and DNS. About 300 path minutes, from recent passes running about 1.25 times their plan (Pass 3's cutover phase, 250 against 200).
