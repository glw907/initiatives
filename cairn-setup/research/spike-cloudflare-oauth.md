# Cloudflare OAuth spike (2026-11-08)

Private OAuth client `spike-cairn-setup` (client id dfc9928abce0a1d4c968dfe4b8c28854), created by
Geoff in the dashboard (Manage account > OAuth clients), public client, auth code + PKCE, redirect
`http://127.0.0.1:8765/callback`. Listener: `listen.mjs`; probes: `probe.mjs`, `mint.mjs`.

## Confirmed

- Creating a client needs a dashboard visit or an OAuth Clients Write token; `ws-admin` gets 403 on
  `GET /accounts/{id}/oauth_clients`. The OAuth scope catalogue is `GET /client/v4/oauth/scopes`
  (403 entries). Dashboard labels say "Edit" where the catalogue says "Write"; "Workers: Edit" is
  `workers-scripts.edit` (Workers Editor). "Workers Scripts Write" is not offered in the dashboard.
- Consent: one page, one click, back on the loopback in 43 s (first run) and 31 s (second). The
  page warns "This application has not verified ownership of any domain" (an unverified, private
  client). API Tokens Write is listed under "Sensitive scopes" and Geoff had to tick it by hand;
  an owner who skips it gets a token with no minting.
- A second authorization shows the consent page again; no remembered grant.
- The callback carries `code`, `scope`, `state`; exchange at `https://dash.cloudflare.com/oauth2/token`
  with the PKCE verifier returns access_token (expires_in 3600), refresh_token, scope (all 13 granted).
- With the access token: `/user`, `/accounts`, zone read, DNS read, Email Sending subdomains read,
  Workers scripts list, Builds triggers list, D1 list, R2 list all 200.
- Token minting from the OAuth token works: `POST /user/tokens` with `expires_on` (Zone Read on one
  zone; then Workers Scripts Write at account scope), verify 200, `DELETE /user/tokens/{id}` 200.
- Refresh works (200, returns a new pair) but REVOKES the previous access token: the old one then
  fails, and wrangler's retries on the dead token hit 9109 "Max auth failures reached". Setup must
  persist the new pair on every refresh and never hand a superseded token to a subprocess.
- wrangler 4.156.2 accepts the OAuth access token as `CLOUDFLARE_API_TOKEN`: it can redeploy an
  existing Worker and `secret put`, but creating a NEW Worker fails ("No access to the specified
  resource" on `PUT /workers/scripts/{name}`) under Workers Editor. A token minted from the OAuth
  token with "Workers Scripts Write" creates the new Worker fine.
- Email Sending onboarding has an API (`POST /zones/{zone_id}/email/sending/subdomains`, in the cf
  CLI's schema); not exercised live, since carin-test.org is already onboarded.

## Not confirmed

- Whether the redirect may use any loopback port (only the registered 8765 was tried).
- Builds writes (`PUT builds/repos/connections`, trigger create) with the OAuth or minted token;
  reads work, and the minted token is user-owned, which is what Builds requires.
- Revoke: `POST /oauth2/revoke` from Python urllib returned 403 (possibly a user-agent block).
- Going public: permanent, needs name, logo, client URL, and a DNS TXT verification (docs).

## Cleanup

Minted tokens deleted; Workers `spike-oauth-deploy` and `spike-oauth-deploy-new` deleted; local
token file deleted. Geoff deleted the client on 2026-11-08, which ended its grant.

## Registering the cairn client (2026-11-08)

- The dashboard's create form has no "offline access" scope. The refresh-token grant type is ticked
  instead; setup still sends `offline_access` in its authorize request, as the spike did. S1's token
  exchange shows whether a refresh token comes back.
- Dashboard labels as registered: Workers: Edit (`workers-scripts.edit`; Admin left unticked), Workers
  Routes: Edit, Workers R2 Storage: Edit, D1: Edit, DNS: Edit, Zone: Read, Email Sending: Edit,
  Account Settings: Read, User Details: Read, and API Tokens: Edit (user tokens; Account API Tokens
  left unticked). Zone: Edit and Workers CI: Edit are optional spares.
- "Sensitive scopes" is a heading on the consent page, not in the create form.
- Token authentication method: `none` (PKCE with S256), per Cloudflare's "Create an OAuth client" page.
- Domain verification: TXT `cloudflare_oauth_client_publisher=...` at the cairn.pub apex, record id `928b587f0e59bcf470b2de581f393c19`, added by API 2026-11-08 (comment names the client).
