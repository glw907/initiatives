# GitHub App one-trip spike (2026-11-08)

Run on `glw907-test` with Playwright (persistent profile). Evidence: `events.log`, `shots/`.
Recorded by the main session from the spike agent's hand-back.

## Confirmed

- One trip, no copied URL: start page, then "Create GitHub App" confirm (click 1), then a 302
  through the loopback `/manifest` (state verified, conversion 201), then the install page
  (click 2), then `127.0.0.1/callback?code&installation_id&setup_action=install`. One hop delivers
  all three. About 4 page loads. A stale session can interpose a sudo or login prompt.
- `setup_url` is ignored when `request_oauth_on_install` is true (never hit).
- Preselect works: `/apps/<slug>/installations/new/permissions?suggested_target_id=<user id>&repository_ids[]=<repo id>`
  checks "Only select repositories" with the repo marked suggested; the button reads "Approve,
  Install, & Authorize". The plain URL defaults to "All repositories" (3 extra clicks to narrow).
- The code exchange returns a `ghu_` user token with expiry and a refresh token;
  `GET /user/installations` lists the install. The App JWT mints an installation token with
  contents, metadata, and workflows write, which pushed a normal file and
  `.github/workflows/check.yml` (201). The owner's classic token without `workflow` got 404 on the
  workflow path, so the App alone pushes the workflow; gh's `workflow` scope is not needed.

## Caveat

- Headless Chromium: an install page opened in a fresh browser minutes after creating the App
  bounced on the first Install click ("This App has changed since you last viewed it") in about
  12 of 12 tries; a reload or second click then worked. The bounce resets the choice to "All
  repositories", so the callback must check `repository_selection` and the repo list and refuse
  an over-grant. A headed run also saw an unexplained second POST with `install_target=all`.
  Whether a person in a real browser meets the bounce is unconfirmed.

## Not tested

Org owners (target chooser), a human-driven browser, token refresh, accounts with many repos.

## Cleanup (read back)

User token revoked (401 after). Seven test Apps deleted (`/settings/apps` shows none). Repo
deleted (404). The Cloudflare Workers and Pages installation is untouched.
