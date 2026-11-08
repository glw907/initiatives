# Prior art compared with the cairn setup design (2026-11-08)

## 1. Git-based CMSs

- **Keystatic** is the closest relative. Its admin page at `/keystatic/setup` POSTs a manifest. The callback calls `app-manifests/{code}/conversions`, appends the client id, secret and slug to `.env`, then sends the owner to install the App (source: `packages/keystatic/src/api/api-node.ts`, https://keystatic.com/docs/github-mode). The cost: the repo has to exist already, the owner pastes `.env` into the host by hand (https://egghead.io/lessons/react-manually-connect-a-keystatic-project-to-a-github-repo), and the docs' deploy section says "coming soon". Owner steps: about 5 plus a copy-paste. *Bears on the chain.* This confirms the manifest-then-install chain. Ours beats Keystatic because it never makes the owner copy anything.
- **TinaCloud**: create a project on app.tina.io, authorize GitHub, then copy the client ID and the token from two dashboard tabs into the host's env (https://tina.io/docs/tinacloud/overview). That is two copy-pastes plus a hosted dependency.
- **Outstatic** and **Decap/Sveltia**: the owner creates an OAuth app by hand and pastes its id and secret into Vercel or a Worker. Outstatic then has to edit the callback URL after the deploy, and one OAuth app allows only one callback (https://outstatic.com/docs/access-integration/setting-up-github-authentication). Sveltia's escape is "Sign in with Token" (a PAT). Its auth Worker has a deploy button but still needs a manual OAuth app.
- **Pages CMS**: the hosted app needs no setup but holds the tokens. Self-hosting means a `.env` file and a helper command that creates the GitHub App (https://pagescms.org/docs/guides/installing/self-host/).
- **Coolify** uses the same manifest create-and-install pair with its own instance as the callback (https://coolify.io/docs/applications/ci-cd/github/setup-app).

**Verdict:** nobody in this category gets the owner to zero copy-pastes. Cairn's chain beats every one. What they have that we don't: setup happens inside the CMS admin itself, and Keystatic editors sign in with GitHub, so editors need no mail infrastructure. Our "workers.dev, no domain" path means single-writer only, because Email Sending needs an onboarded domain. That is already documented in `docs/admin/before-you-start.md`, but the summary screen should say it in one line.

## 2. Deploy buttons

- **Deploy to Cloudflare** clones the repo into the owner's GitHub, provisions D1, R2 and KV from the Wrangler config, and sets up Workers Builds. Owners rename resources on one page. Since 2025-07-01 the page also prompts for secrets declared in `.dev.vars.example` (https://developers.cloudflare.com/workers/platform/deploy-buttons/, https://developers.cloudflare.com/changelog/post/2025-07-01-workers-deploy-button-supports-environment-variables-and-secrets/). It also covers Cloudflare sign-up and the Cloudflare GitHub App authorization inline, which are exactly our before-you-start item and chain step 5. The docs say nothing about custom domains or a return redirect. The template repo must be public, and each template needs its own button.
- **Vercel** has `integration-ids` and `redirect-url` (https://vercel.com/docs/deployments/deploy-button/integrations, https://vercel.com/docs/deploy-button/callback). **Netlify** takes `[template.environment]` labels, with values passed in the URL hash.

**Could cairn start from a button?** It would lose four things:
- The per-site GitHub App. A button has no hook for a manifest POST. The live site could run its own `/admin/setup` the way Keystatic does, but the Worker has no Cloudflare token to store the App key as a secret.
- Email Sending onboarding, the custom domain, and the Workers Paid check.
- The signed-in end.
- Agent drivability.

An open setup page on a fresh public URL is also the WordPress setup-hijack pattern, where attackers find new installs through CT logs within minutes (https://www.wordfence.com/blog/2017/07/hackers-find-wordpress-within-30-mins/). Our design never exposes a claimable window, which is better. **Terminal-first holds.** The thing worth stealing is the button's one editable resource page. The summary screen already plays that role: make every derived name on it editable in place, not just displayed.

## 3. Terminal setups

- **fly launch** prints a derived plan with a reason on each line ("derived from your directory name"), then asks "Do you want to tweak these settings before proceeding?". It also has `--no-deploy` (https://docs.fly.io/launch/create). *Bears on the opening and the summary.* This confirms one summary with one go. Steal the per-line provenance.
- **gh, Shopify, and Stripe sandbox claim** all use the same hand-off: print the URL, then "Press Enter/any key to open the browser". Shopify's forum shows the auto-open failing silently on headless boxes (`spawn xdg-open ENOENT`) (https://community.shopify.com/t/cannot-skip-browser-login-with-shopify-cli-device-auth-1/362302). *Bears on the friction ranking.* Have the owner press Enter to start the switch, so they know which window wants them. Always print the URL as a fallback. Don't count the printed URL as a "copied URL" failure.
- **C3** asks "Do you want to deploy your application?" late, and its non-interactive mode needs every flag (https://developers.cloudflare.com/pages/get-started/c3/). That is the late-question pattern we rejected.
- **Terraform machine-readable UI** has a JSON plan plus `apply plan.out` (https://developer.hashicorp.com/terraform/internals/machine-readable-ui). *Bears on agents.* Make `--plan --json` emit a plan file that `cairn new --apply plan.json` runs exactly, so what the agent showed the human is what runs.
- **Build choice:** Stripe CLI (`npm install -g @stripe/cli`), Supabase, gh, and flyctl are all Go binaries, and several ship through npm. That confirms a Go tool behind an `npm create` launcher.

## 4. Agent-driven setup

- **MCP URL-mode elicitation** (https://modelcontextprotocol.io/specification/2025-11-25/client/elicitation) is the same shape as our named waiting states. It adds two rules:
  - "Accept does not mean done". Completion is a separate notification.
  - The person who opens the URL must be bound to the person who started the flow, and the URL must not be pre-authenticated (the phishing section).
  
  Our loopback URL should carry an unguessable nonce. It must never be a credential, and should rely on the loopback origin for safety. Put an `elicitationId`-style id on each waiting state in the NDJSON stream.
- **Shopify CLI PR #7628** (2026-05-25) changed its login output to tell agents "show the URL/code to the user and keep the command running" (https://github.com/Shopify/cli/pull/7628). Steal that: the waiting-state event should carry agent-facing text.
- **auth.md**: Cloudflare (https://www.cloudflare.com/auth.md) and Clerk (https://clerk.com/auth.md) publish agent instruction files. cairn.pub should publish one for `cairn new`.
- **Stripe Projects**: an agent creates a Cloudflare account with no signup page, buys a domain, and starts a paid subscription, capped at $100 a month per provider (https://blog.cloudflare.com/agents-stripe-projects/). Stripe sandboxes and Clerk keyless apps follow "provision anonymously, claim later" (https://docs.stripe.com/cli/sandbox). *Bears on before-you-start.* Today this would add a Stripe dependency and it is still beta. Keep sign-ups outside the command, but log a ROADMAP watch: it could collapse the whole before-you-start page.
- **Remote agents.** A third-party Cloudflare OAuth client gets only auth code plus PKCE, with no device flow, and the manifest needs a browser POST. That means a cloud or SSH agent cannot complete the loopback. Detect it in the opening (SSH session, no display, CI) and fail with the reason before asking any questions.

## Ranked suggestions

1. **Replace Workers Builds (step 5) with a GitHub Actions deploy.** The CI workflow already ships, and step 5 is the only unverified hop and the only third-party GitHub App. Fly and Cloudflare both document a token kept as a repo secret (recon §2, https://developers.cloudflare.com/workers/ci-cd/external-cicd/github-actions/). The cost is a long-lived narrow token in GitHub. If Builds stays, test step 5's return before the prototype. The deploy button handles it inline, so it can be done.
2. **Verify scopes on the Cloudflare consent return.** The token-creation scope is one the owner has to tick. If they miss it, the failure surfaces in the watching stretch, which is the design's own definition of a bug. Re-prompt on the spot with one line of explanation (MCP accept-is-not-done principle).
3. **Plan file plus apply, and auth.md** for agents (Terraform, Clerk, Cloudflare).
4. **Press Enter to open, with the URL printed as a fallback**, plus a terminal line showing which browser step is live (gh, Shopify, Stripe).
5. **Confirmations:** terminal-first and one summary (fly launch); the manifest chain and zero copy-paste (beats Keystatic, Tina, Outstatic, Sveltia); the signed-in end with no open setup window (beats the WordPress pattern); Go behind npm.

**Shape check:** nothing argues against terminal-first for this owner. Two things limit it: remote agents cannot use the loopback, and Stripe Projects could later remove the before-you-start sign-ups. A cairn.pub button is worth adding only as a launcher that opens the terminal command, not as a replacement for it.
