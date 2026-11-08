# Recon: browserless and reduced-browser provisioning (as of 2026-11-07)

Legend: [CONFIRMED-DOC] stated by an official page I read; [CONFIRMED-CODE] read from an installed package, not documented; [SECONDARY] third-party or search snippet only; [UNCONFIRMED] inference or not found.

## 1. GitHub

### (a) CLI authentication
- OAuth device flow is the browserless standard. Two endpoints: POST https://github.com/login/device/code and POST https://github.com/login/oauth/access_token. Codes expire in 900 s; polling interval 5 s with slow_down; a user may submit a code 50 times per hour per app. The device flow must be enabled in the App/OAuth app settings. The documented response lists `verification_uri` and `user_code` only (no pre-filled "complete" URI), so the human types or pastes a code. [CONFIRMED-DOC] https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps
- `gh auth login` defaults to a browser flow with a one-time device code (`--clipboard` copies it); `--with-token` reads a classic PAT (min scopes repo, read:org, gist); GitHub warns against passing a fine-grained PAT to `--with-token` and says to use `GH_TOKEN` instead; `GH_TOKEN` suits headless use. [CONFIRMED-DOC] https://cli.github.com/manual/gh_auth_login
- `gh auth token` reuse: Claude Code's own `/install-github-app` requires `gh` already authenticated and reuses it. [CONFIRMED-DOC] https://code.claude.com/docs/en/github-actions
- Fine-grained PATs are GA (2025-03-18) but are created only in the web UI; I found no API to mint one. [SECONDARY] https://github.blog/changelog/2025-03-18-fine-grained-pats-are-now-generally-available/ . Some endpoints still need a classic PAT or OAuth token.
- GitHub MCP server is adding device-flow login (PR #1649). [SECONDARY]

### (b) Creating an identity that commits to one repository
- GitHub App creation has no direct API. The REST "Apps" page lists exactly one create endpoint, "Create a GitHub App from a manifest" (`POST /app-manifests/{code}/conversions`), and no endpoint to create or rotate a private key. [CONFIRMED-DOC] https://docs.github.com/en/rest/apps/apps
- The manifest flow needs a browser: the user's browser POSTs the manifest to GitHub, the user may edit the name and clicks "Create GitHub App", GitHub redirects to `redirect_url?code=...`, the tool exchanges the code (valid one hour, rate limited). The manifest does not auto-install the App; `setup_url` can redirect the user after install. [CONFIRMED-DOC] https://docs.github.com/en/apps/sharing-github-apps/registering-a-github-app-from-a-manifest
- Blog posts (Rob Bos / Xebia, updated Jan 2026) and Josh Johanning (about Sept 2026) say the same: no API to create Apps, none to rotate keys. [SECONDARY] https://xebia.com/blog/create-a-github-app-from-a-manifest , https://josh-ops.com/posts/github-enterprise-apps/
- Why a human is required: App creation mints a long-lived private key and a permission set that act as a new principal; GitHub makes the account owner see and click that. This is my reading of the model, not a stated GitHub rationale. [UNCONFIRMED rationale]
- 2026 changes that help automation but do not remove the browser:
  - 2026-10-13: new fine-grained permissions `repository_creation:write` and `installation_repositories:write` (fine-grained PATs and Apps). The org-level "add/remove a repository to an installation" APIs now accept Apps and fine-grained PATs (before: classic `repo` scope only). A repo admin can add repos to an existing org-level installation without owner approval; org-level permissions, repository administration, and repository creation still need an owner. An App with `repository_creation` "still requires an organization administrator to install the app." [CONFIRMED-DOC] https://github.blog/changelog/2026-10-13-github-app-improvements-for-least-privilege-and-management/
  - Stateless installation tokens rolled out 2026-10-02; one-hour expiry and repository scoping unchanged. [SECONDARY] https://github.blog/changelog/2026-10-02-stateless-github-app-installation-tokens-rolled-out/
  - Enterprise installation API and GA (2026-05-13, 2026-10-23): enterprise-only, not relevant to a personal or small-org owner. [SECONDARY]
- Repository-scoped tokens: an installation access token can be limited to named repositories (`Create a scoped access token`, `Create an installation access token` on the same REST page above). A fine-grained PAT can also be single-repo but cannot be created by API.
- Deploy keys: creatable by API, can have write access, one repository per key, no expiry. They are SSH-for-git credentials; the docs point to App installation tokens for REST/GraphQL. A Worker committing through the Contents API cannot use one. [CONFIRMED-DOC] https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys ; "cannot use for REST" is my inference from that page [UNCONFIRMED as an explicit statement].
- Copilot coding agent / agent-era GitHub changes: I found no GitHub feature that creates or installs an App without a browser. The agent-friendly work is the Oct 2026 permissions above and enterprise installs. [searched, not found]

### (c) Installing an App on a repository via API
- First install of an App on an account/org: browser only (the install page). I found no API for it. The Claude GitHub App install in `/install-github-app` still ends in a GitHub install page. [CONFIRMED-DOC for Claude Code; absence of API UNCONFIRMED but consistent with REST listing]
- After an installation exists: `PUT /user/installations/{installation_id}/repositories/{repository_id}` adds a repo (204). The authenticated user must have admin on the repo; the docs page does not name the token type. [CONFIRMED-DOC] https://docs.github.com/en/rest/apps/installations . Whether the `gh` OAuth token (repo scope) works for a personal-account installation is [UNCONFIRMED] and should be tested with a throwaway App. For org installs, the Oct 2026 change makes it work with a fine-grained PAT or App token holding `installation_repositories:write`.
- `GET /user/installations` needs a user-to-server token of that App (device flow on the App, if the manifest or settings enable it). Whether a manifest can turn on device flow: [UNCONFIRMED].

## 2. Cloudflare

### OAuth for third parties
- Cloudflare now lets anyone register OAuth clients: dashboard "Manage account > OAuth clients" (changelog 2026-06-03), or API `POST /client/v4/accounts/{account_id}/oauth_clients` with an `OAuth Clients Write` token; `cf iam oauth-clients create` exists. Only Authorization Code is supported; the page explicitly lists Device Authorization, Client Credentials, Implicit and Password as unsupported. CLI apps use PKCE with `token_endpoint_auth_method: none`. New clients are `private` (only members of the creating account can authorize); going public is permanent and needs a name, logo, client URL, and a DNS TXT domain verification. Loopback redirect rules, token lifetime, refresh: not documented on that page. [CONFIRMED-DOC] https://developers.cloudflare.com/changelog/post/2026-06-03-public-oauth-clients/ , https://developers.cloudflare.com/fundamentals/oauth/create-an-oauth-client/
- Consequence: a cairn-owned third-party client would use auth-code + PKCE (needs a localhost redirect and a browser on the same machine) unless the owner uses Cloudflare's own first-party device flow via wrangler or cf.
- Remote MCP server mcp.cloudflare.com (Code Mode: search/execute) uses OAuth with selectable, optionally declinable scopes, or an API token. [SECONDARY] https://www.scalekit.com/blog/cloudflare-mcp-vs-api

### Device flow (first-party)
- `wrangler login --device` (Wrangler >= 4.119.0, changelog 2026-08-04): RFC 8628, prints URL and code, opens the URL with the code filled in, polls up to 5 minutes, no localhost:8976 server; `--browser=false` suppresses the launch. [CONFIRMED-DOC] https://developers.cloudflare.com/changelog/post/2026-08-04-wrangler-login-device-flow/ , https://developers.cloudflare.com/workers/wrangler/commands/general/index.md
- New `cf` CLI (beta, 2026-09-28; npm package `cf`, 1.0.0-beta.28 when I checked): `cf auth login` is device auth by default (prints link plus one-time code, opens browser; `--no-browser` prints only), keeps its own credentials (does not reuse Wrangler's), credential order is CLOUDFLARE_API_TOKEN, `--profile`, directory-bound profile, default profile. Fully unattended use is a token in env. Includes `cf cli search "<task>"` returning JSON for agents, 2,900+ commands. [CONFIRMED-DOC] https://developers.cloudflare.com/cf/get-started/ , https://developers.cloudflare.com/changelog/post/2026-09-28-cloudflare-cli-beta/
- I installed cf@1.0.0-beta.28 in the scratchpad and read it. [CONFIRMED-CODE, not documented]:
  - Device endpoint `/oauth2/device/auth`, built-in first-party client id.
  - The default login scope set (all known scopes minus billing and a few read scopes) includes `account_api_tokens:create`, `workers_builds:write`, `workers_builds:read`, `dns_records:edit`, `email_sending:write`, `email_routing:write`, `workers_routes:write`, `workers_scripts:write`, `registrar:write`, `zone:read`.
  - `wrangler login --scopes-list` (4.158.0) shows a much narrower set: no token-creation, no builds, no DNS-write scope. So Wrangler's OAuth cannot mint tokens or configure Builds; cf's can (per the scope list; server grant not tested).
- Commands relevant to cairn, from `cf cli search` and `cf schema`: `cf accounts tokens create`, `cf user tokens create`, `cf builds repos connections upsert` (PUT /accounts/{id}/builds/repos/connections; body: provider-account-id, provider-account-name, provider-type, repo-id, repo-name), `cf builds workers create`, `cf builds triggers create`, `cf builds tokens`.

### Token creation from an existing token ("API Tokens Write")
- Yes: `POST /accounts/{id}/tokens` (account-owned) or `/user/tokens`. Needs a token with API Tokens Write (user) or Account API Tokens Edit (account). Docs say the first seed token must be made in the dashboard from the "Create Additional Tokens" template, and warn such a token can mint tokens for any of the user's resources. [CONFIRMED-DOC via search] https://developers.cloudflare.com/fundamentals/api/how-to/create-via-api/ , https://developers.cloudflare.com/api/tokens/advanced/api . The cf default scope `account_api_tokens:create` suggests the seed token is no longer needed when signed in with cf [UNCONFIRMED end to end].
- Cloudflare's own agent page: use Wrangler OAuth locally, scoped tokens for scripts; check for existing Wrangler or CLOUDFLARE_API_TOKEN auth before asking; never ask users to paste tokens in chat; account creation for agents via auth.md (ID-JAG) is "coming soon" and must not be attempted. [CONFIRMED-DOC] https://www.cloudflare.com/auth.md

### Agent-era account creation
- Temporary accounts: `wrangler deploy --temporary` (Wrangler >= 4.102.0, 2026-06) deploys with no account; a claim URL goes to a human; unclaimed accounts delete after 60 minutes; errors if credentials exist; workers.dev, assets, KV, DO, one D1, queues. Not suited to custom domains or email (not mentioned). [CONFIRMED-DOC] https://blog.cloudflare.com/temporary-accounts
- Stripe Projects protocol (2026-04-30, open beta): `stripe projects init`, agent can create a Cloudflare account, buy a domain, get an API token; existing accounts go through a standard OAuth flow; humans accept Cloudflare's terms; $100/month default cap per provider. [CONFIRMED-DOC] https://blog.cloudflare.com/agents-stripe-projects/ . Adds a Stripe dependency; probably out of scope for cairn.

### Workers Builds connect (the GitHub half)
- API exists: create a build configuration with `POST /accounts/{id}/builds/workers` (script_tag, git_repository with provider ids from api.github.com, build_token_uuid, production_settings). The token must be user-scoped, "account-scoped tokens aren't supported", with Workers Builds Configuration: Edit and Workers Scripts: Read. [CONFIRMED-DOC] https://developers.cloudflare.com/workers/ci-cd/builds/api-reference/
- Prerequisite that stays in the browser: install the "Cloudflare Workers & Pages" GitHub App, once per GitHub account/org, via Settings > Builds > Connect > GitHub > authorize. No API equivalent documented. The Git integration page names no CLI path. [CONFIRMED-DOC] same API page; https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/ ; https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/github-integration/
- Option that removes this visit entirely: skip Workers Builds and deploy from a GitHub Actions workflow using a Cloudflare token stored as a repo secret (gh sets secrets via API). Trade-off: a deploy token in GitHub secrets, workflow permission needed to push the workflow file. [Design inference; Cloudflare documents the pattern at https://developers.cloudflare.com/workers/ci-cd/external-cicd/github-actions/]
- C3 (`create-cloudflare`): I found no 2026 source describing its sign-in; general guidance is `wrangler login` locally and token plus account id in CI. [UNCONFIRMED for C3]

## 3. Prior art

| Tool | First-run browser visits (my count) | Skipped when a credential exists | Hand-off to a human |
|---|---|---|---|
| Vercel CLI | login (OAuth 2.0 device flow since 2026-02-26 replacing email login: https://vercel.com/changelog/new-vercel-cli-login-flow ); `vercel git connect` needs the Vercel GitHub App installed on the account (error "GitHub app installation not found" otherwise: https://vercel.com/docs/errors/error-list ) so 1 login + 1 GitHub install [SECONDARY on count] | `VERCEL_TOKEN` env skips login | device code; `vercel api` added for agents [SECONDARY] |
| Netlify CLI | `netlify login` opens browser to authorize Netlify CLI (1); `netlify init` for GitHub prompts a GitHub login that mints an account-level token used to create a deploy key and webhook (1 more). `netlify init --manual` prints a deploy key and webhook for you to paste (0 browser, many copy steps). [CONFIRMED-DOC] https://docs.netlify.com/api-and-cli-guides/cli-guides/get-started-with-cli.md | `NETLIFY_AUTH_TOKEN` skips login; stored GitHub token reused for later sites | `netlify deploy --allow-anonymous` deploys with no account, 1 hour claim window, "for AI agents" |
| Supabase CLI | `supabase login` automatic browser login with a verification code; `--no-browser`, `--token`, or `SUPABASE_ACCESS_TOKEN` skip it. [SECONDARY] https://supabase.com/blog/automatic-cli-login , https://supabase.com/docs/reference/cli/supabase-login | env token | verification code in terminal |
| Railway | `railway login` browser or `--browserless` (pairing code at a URL); `RAILWAY_TOKEN` overrides. Community reports bugs without a TTY. [SECONDARY] https://docs.railway.com/cli/login | token env | pairing code |
| Fly.io | `fly auth login` browser; repo link is via GitHub Actions with a per-app deploy token (`fly tokens create deploy`), so no GitHub App at all. [SECONDARY] https://fly.io/docs/launch/continuous-deployment-with-github-actions/ | deploy token | none needed; the token goes into a repo secret |
| Render | dashboard: first service prompts to connect Git provider and install the Render GitHub App. No confirmed API to link a repo without that install. [SECONDARY] https://render.com/docs/your-first-deploy |  |  |
| Coolify | Automated path uses the manifest flow: create a GitHub App source, click Create on GitHub, then install for repositories (2 GitHub pages). Self-hosted, so the callback is the user's own Coolify. [SECONDARY] https://coolify.io/docs/applications/ci-cd/github/setup-app | an existing App source is reused for new apps | browser redirect back to Coolify |
| Claude Code `/install-github-app` | Needs `gh` signed in first; installs the Claude GitHub App (a GitHub install page), stores the secret, pushes a branch, and opens GitHub in the browser with a PR ready to create. Repo admin required. 2 visits after gh login (app install, PR) [CONFIRMED-DOC] https://code.claude.com/docs/en/github-actions | App installed once per account or org; rerun skips to workflow/secret | Opens browser itself; no remote path |
| OpenAI Codex cloud | Connect GitHub in ChatGPT: one authorize pop-up for the connector, then repo selection. [SECONDARY] https://developers.openai.com/codex/cloud.md |  |  |
| Devin | Org admin authorizes the Devin GitHub App and chooses all or selected repos (1 GitHub visit). [SECONDARY] https://docs.devin.ai/Integrations/gh |  |  |
| Cloudflare Workers Builds | Dashboard: Install & Authorize the Workers & Pages GitHub App (1 GitHub visit per account), then pick repo. API for the rest. See section 2. |  |  |

Pattern across the tools: nobody avoids the one-time GitHub App install or authorize; the tools that avoid it (Fly, Cloudflare via Actions) push a deploy token into a repo secret instead. Device flow is now the common login (GitHub, Cloudflare wrangler/cf, Vercel, Railway). Anonymous-then-claim deploys (Cloudflare `--temporary`, Netlify `--allow-anonymous`) are the agent-era hand-off for account creation.

## 4. Hand-off patterns for human-only approvals

- Device code (RFC 8628): works with no local server and no shared screen, so it also works over SSH, in containers and for a remote agent. Cloudflare's own change was motivated by the localhost:8976 callback failing in containers, SSH, and Codespaces; the code can be approved on another device. Times: GitHub 15 min, Cloudflare 5 min. A pre-filled URL is better than a typed code: wrangler opens the URL with the code filled in; GitHub's documented response has no complete-URI field. [CONFIRMED-DOC] sources in sections 1 and 2.
- MCP URL-mode elicitation (spec 2025-11-25): a server asks the client to send the user to a URL for sign-in, payment, or entering a key out of band so the secret never passes through the client or model; "accept" does not mean done; the server may send a completion notification. Same concept as a hand-off to a local page. [CONFIRMED-DOC] https://modelcontextprotocol.io/specification/2025-11-25/client/elicitation
- Cloudflare's agent guidance: check for existing credentials first, never have the user paste tokens in chat, read secrets from the environment or a secret store at point of use. [CONFIRMED-DOC] https://www.cloudflare.com/auth.md
- Single local page chaining approvals: Coolify's manifest flow and cairn's own existing manifest step use it. A localhost page can POST the manifest to GitHub, receive the redirect, call the conversion endpoint, then redirect to `/apps/<slug>/installations/new`, with `setup_url` returning to localhost; the owner clicks twice and copies nothing. [Design inference from the manifest docs; the install redirect chain itself is UNCONFIRMED]
- Best by situation (my judgment, not a sourced ranking):
  - Same desktop: local page opened by the tool (it can open the browser itself, as Claude Code does) and chain every GitHub step on it; a desktop notification adds nothing when the browser already pops up.
  - Remote or sandboxed agent: device code with a pre-filled URL printed in the agent's chat, since a localhost callback cannot reach the user's browser; for the GitHub App step, the manifest redirect_url must be reachable by the user's browser (a tunnel or a tool-hosted public page), which is the hard case.
  - Always: the tool polls for completion so the agent does not wait on the human's report.

## 5. Realistic minimum browser visits

Counts treat one "visit" as one page load that needs a human click. Assumes a Cloudflare account and a domain already on it.

First cairn site (owner has no gh login, no App, no cf login):
1. GitHub device approval for `gh` (skipped if `gh auth status` is already good). [gh docs above]
2. GitHub: Create GitHub App (manifest page, one click). Required; no API. [CONFIRMED-DOC]
3. GitHub: install that App on the repo (one click, can be chained from step 2 by redirect). Required for first install. [CONFIRMED-DOC absence of API]
4. Cloudflare: one `cf auth login` device approval; then token minting, deploy, DNS, Email Sending, and Builds configuration can all be API calls given the scopes in cf's default set. [CONFIRMED-CODE for scopes; untested end to end]
5. Workers Builds: Cloudflare GitHub App install and authorize, once per GitHub account. Avoidable by using GitHub Actions plus a repo secret.
Minimum: 3 visits (steps 2, 3, 4) when gh is already signed in and Builds is replaced by Actions; 4 with Builds; 5 on a machine with no gh login. This is the floor given current docs, not a tested run.

Later site by the same owner (App exists, gh and cf signed in, Cloudflare GitHub App already installed):
- Create the repo through the API (gh token). Add it to the existing App installation with `PUT /user/installations/{id}/repositories/{repo_id}` (or the org form with `installation_repositories:write`). Mint tokens, deploy, connect the domain, email, and Builds by API. Realistic minimum: 0 visits. [UNCONFIRMED until the add-repo call is tested with the token the tool will hold; this requires reusing one App across sites, which changes the "one App per site" model and key custody.] If each site must have its own App, the later-site cost stays at 2 (create and install).

Key unconfirmed items to test before committing to the design:
1. Does `PUT /user/installations/{id}/repositories/{rid}` accept the `gh` OAuth token for a personal-account App installation?
2. Can a manifest-created App have device flow enabled, and can the manifest redirect straight to the install page?
3. Does a `cf auth login` token get granted `account_api_tokens:create` and `workers_builds:write`, and does the Builds API accept an OAuth token (docs require a user-scoped token)?
4. Does Email Sending domain onboarding fully work through the API with those scopes?
