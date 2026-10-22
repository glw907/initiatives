# Bulwark webmail pass

## Brief

This pass gives Geoff and the second operator webmail at `webmail.907.life`: Bulwark's full edition on orpheus, signing in to ward's Stalwart, styled in the Survey house theme, and carried by the runbook, the monthly review, the advisory watch, and the monitor.

Geoff asked for it on 2026-10-21 (servers BACKLOG #13), ruled the Survey theme the same day ("Use the theme."), and left the timing to Claude. It runs after Pass 6's cutover and the bookmarks pass, because Pass 5's executor is live in the same role and host files and nobody uses ward for mail until the cutover.

Status: draft, not yet brought for approval. It waits for the Survey house style (workstation BACKLOG #28, Geoff, 2026-10-21), which pulls the approval queue's reusable styling back into Survey and describes how a third-party app takes it. Section 4 is re-read against that result before this design goes to Geoff.

Initiative: self-hosting

## Outcome

Both mailbox holders can read, search, and send 907.life mail in a browser, and use their calendars and contacts there. Bulwark ([bulwarkmail/webmail](https://github.com/bulwarkmail/webmail), AGPL-3.0) is a Next.js JMAP client built for Stalwart. Pass 5 pins Stalwart v0.16.27, which meets Bulwark's 0.16 floor.

## What changes

1. **A `bulwark` role on orpheus.** The official image `ghcr.io/bulwarkmail/webmail`, pinned by tag and index digest (it publishes amd64 and arm64), runs under Docker on loopback port 3000, as Immich does. Caddy gets a `webmail.907.life` site with a Let's Encrypt certificate, and `cloudflare/dns/orpheus` gets a `webmail` CNAME. `JMAP_SERVER_URL` is `https://ward.907.life`.
2. **No state outside the repo.** The config directory (`config.json`, `policy.json`, the theme, the logos) is committed in the role and mounted read-only with `ADMIN_CONFIG_READONLY=true`. Settings sync and telemetry stay off. A rebuild from the repo restores Bulwark, so the nightly backup does not change. The one new secret is `SESSION_SECRET`, stored through `secret-set.sh` and rendered to a root-only file. If the admin dashboard demands a password even with a read-only config, the plan generates one into the age store and nobody uses it day to day.
3. **Sign-in.** Mailbox passwords against Stalwart. Bulwark's server checks each sign-in itself, from orpheus's address, so a run of wrong passwords could make Stalwart's auto-ban block orpheus and cut off webmail for both users. The plan probes this. If it holds, Stalwart's plan allowlists orpheus's two addresses and a sign-in throttle goes in front of Bulwark. The plan also probes whether the browser's JMAP calls to `ward.907.life` need a CORS origin in Stalwart.
4. **The Survey theme.** Bulwark's advanced theme manifest takes Survey's tokens, light and dark, from Survey's core as workstation BACKLOG #28 leaves it (today the only copy is `approval-queue/src/lib/survey/theme.css`), with `policy.json` pinning it for every user. `APP_NAME`, the favicon, and the light and dark logos come from 907.life's marks. Bulwark's theme sanitizer strips every `url()` (`lib/plugin-types.ts`, `DISALLOWED_CSS_PATTERNS`), so no theme can load a web font or a background image: Spectral, Karla, and Monaspace Neon fall back to their system stacks, and Survey's contour texture does not come through. The palette, radii, density, and marks do.
5. **Maintenance.**
   - The monthly review's upgrade step reads Bulwark's release notes. Bulwark ships a minor release every few days (1.11.0 on 2026-09-23 to 1.17.0 on 2026-10-21), so the review takes the newest release in a packet part. With no state, an upgrade is a new pinned digest, `apply.sh orpheus`, and the smoke check. A rollback is the previous digest. There is no drill copy.
   - Pass 6's advisory watch (C6) adds `bulwarkmail/webmail`, so a security release raises the urgent alert and the emergency patch path.
   - The monitor checks `https://webmail.907.life/api/health`.
6. **Docs.** The runbook gains Bulwark in the service catalog, its upgrade and rollback lines, and the rebuild note. `docs/addresses.md` names the new hostname, and `docs/decisions.md` records the host, the theme ruling, and the font gap.

## Out of scope

Sign-in through Stalwart's OpenID Connect provider (BACKLOG #12's pass), settings sync, plugins, Bulwark Lite, accounts for household members A, B, and C, and any font workaround.

## Later

Ask the Bulwark project for theme fonts and assets, a GitHub issue on their repo that Geoff approves first. A custom image with the fonts baked in is the fallback, at the cost of a rebuild for every release.

## Contestable calls

- **orpheus, not ward.** Stalwart owns port 443 on ward with host networking and terminates its own TLS, and ward has no Caddy. Putting Bulwark on ward means a proxy in front of the live mail server's HTTPS, or a Cloudflare tunnel that decrypts the webmail traffic at Cloudflare. orpheus already runs Docker and Caddy, with about 6 GB of memory free (`free -m`, 2026-10-21). The cost is that webmail needs both servers up.
- **No custom image.** Real fonts would need one, rebuilt against a release every few days.

## End-to-end check

1. Sign in at `webmail.907.life` as Pass 5's test mailbox, from Claude's Chromium profile.
2. Send to the second test mailbox and see the message arrive there.
3. Read full-page renders in light and dark against Survey's approved specimen (`cairn-themes/survey-theme/reference/2026-10-07-approved-specimen.html`), graded by `visual-verifier`.
4. See the monitor's new check pass, and `apply.sh orpheus --check` exit 0.

## Pre-flight

None. Every credential is Claude's to generate, and the test mailboxes exist from Pass 5.

## Standing answers

- A plan over twice this estimate keeps launching up to the initiative's ceiling and says so in the packet.
- The font gap is accepted, and the pass does not stop on it.
- The auto-ban and CORS probes each have the fix written above, so neither stops the run.

## Risk class and estimate

`auth-data` and `live-account`: it adds a credential, changes Stalwart's config, and touches live servers and DNS. About 300 path minutes.
