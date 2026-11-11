# Setting up 907.life with `cairn new`: the walk-through

For the live setup of 907.life on the Waymark theme with cairn's default content. You run it in your own terminal and your
daily Chromium, which is signed in to Cloudflare and GitHub. No clean room, no test accounts. It takes about 10 minutes, most
of it clicks, and the setup itself runs about two and a half minutes after the last approval.

The screens below come from a full rehearsal of the no-token path on dev.7 (setup took 2:22 on its last stretch), against the
real Cloudflare and GitHub pages. Where dev.8 changed a word, this page uses the dev.8 word. The rehearsal's screenshots are in
`~/.local/state/cairn-rehearsal/2611110552/` (private, outside every repository): `tui-redacted/t01-shell.png` to
`t20-done.png` for the terminal, and `browser/b01-...` to `b12-...` for the pages.

## Before you start

- 907.life is on your Cloudflare account, the account is on the Workers Paid plan, and you are signed in to both Cloudflare and
  GitHub in the browser setup will open. If your default browser is another one, copy the address setup prints and open it in
  Chromium.
- Node 24 or later, git, and a keyring you can unlock. Port 49152 is free: close anything else that uses it (the clean room and
  every test run are off for this).
- Make an empty folder and open a terminal in it. Setup creates the site's folder inside it.
- Use the `gate` tag, because `npm create cairn-site` with no tag still fetches the retired wizard:
  `npm_config_tag=gate npm create cairn-site`
- If something goes wrong, stop and write down the screen. Setup saves its place, and running the same command again resumes
  (`To resume, run cairn new again.`).

## In the terminal, before the browser

1. **npm's question** (`t02-npx`). "Need to install the following packages: create-cairn-site@2.0.0-dev.8. Ok to proceed? (y)".
   Type `y` and Enter.
2. **Welcome** (`t03-welcome`). "Set up a cairn site", "You approve four requests in your browser." Press Enter.
3. **Site name** (`t04-name`). The name shows at the top of every page, and setup derives the repository, Worker, database, and
   bucket names from it. Type it and press Enter.
4. **AI crawlers** (`t05-crawlers`). Two rows, "Block AI training" selected, "Allow AI training". Choose and press Enter.
5. **Approve setup in your browser** (`t06-approve-intro`). Four requests are listed as open circles: Cloudflare: Authorize,
   GitHub: Create, GitHub: Install & Authorize, GitHub: Approve. Press Enter and your browser opens a tab. The terminal then shows
   the first request and a fallback address, `http://127.0.0.1:49152/?k=...` (`t07-browser-wait`); if no tab opened, open that
   address yourself, once. It works one time only.

## The four approvals, in the browser tab

6. **Cloudflare** (`b01-cairn-approve-cloudflare`, `b02-cloudflare-consent`). The tab shows cairn's page "Approve setup on
   Cloudflare" with the callout "Turn on API Tokens Write". Select **Continue to Cloudflare**.
   - Cloudflare may stop you with "Verify you are human". That check is yours to pass; nothing in setup can or should pass it.
   - The consent page is headed "cairn wants to access your account". It lists ten required permissions, shows the account
     setup will use (select **Edit** if you have several accounts and this is the wrong one), and has a collapsed row,
     **Sensitive scopes**. Open it, turn on **API Tokens Write** (it is off by default; setup needs it to create the site's deploy
     key), and select **Authorize**.
7. **Domain** (back in the terminal, `t08-domain-chooser` to `t10-after-domain`). The terminal lists the domains on your account.
   No row is selected at first, and Enter does nothing until you press an arrow key; that is deliberate, so a domain is never
   accepted unread. Press the down arrow until **907.life** is marked, check it, and press Enter. The tab then moves to GitHub.
8. **GitHub: Create** (`b04-github-confirm-access`, `b05-github-create-app`). GitHub may first show **Confirm access** and ask
   for a passkey, your authenticator app, or your password: approve it. Then comes "Create GitHub App" with the App's name
   already filled in (you can change it; names are unique across GitHub). Select **Create GitHub App for ...**. The terminal says
   "The admin saves changes to your site through the App."
9. **GitHub: Install & Authorize** (`b06-github-install-authorize`, terminal `t11-install`). The page is "Install & Authorize" on your
   personal account, and **All repositories** is selected. Leave it. This first install is wide on purpose: GitHub cannot limit an
   installation to a repository that does not exist yet, so setup installs the App everywhere, creates the new repository, and
   then deletes this installation within seconds, which the terminal says plainly ("This access covers all your repositories. Setup
   removes it within seconds."). In the rehearsal only the one-repository installation was left afterwards. Select **Install &
   Authorize**. The tab shows "Setup in progress" while setup works (`b07-cairn-setup-in-progress`).
10. **GitHub: Approve** (`b08-github-approve-one-repo`, terminal `t12-approve`). The page is headed "Approve, Install, &
    Authorize" and says "Only select repositories" with "Selected 1 repository", the new repository tagged "suggested". Check that
    it is the new repository only, then select **Approve, Install, & Authorize**. Setup reads the installation back; if it covers
    more than that repository it removes it and asks again.
11. The tab says **Approvals complete** (`b09-cairn-approvals-complete`): "Return to your terminal to review the settings and set
    up your site." Keep this tab open.

## Review, then setup runs

12. **Review the settings** (`t13-summary`). Check each line:
    - Domain: 907.life.
    - Address: "907.life and www.907.life, the bare domain and www, the default". Leave it; this is the address you want.
    - Sign-in email: the address of your Cloudflare account, "from your Cloudflare account". Setup emails the first sign-in link
      there. (`e` edits it.)
    - Repository, Worker, database, bucket: names derived from the site name.
    - Theme: Waymark. AI crawlers: your choice from step 4. Deploys: GitHub Actions, free for about 650 deploys a month.
    Press Enter to set up.
13. **Setting up** (`t17-setup-start` to `t19-https`). A list ticks off: write the site files; set up the database, storage bucket,
    and email; commit the site; store the deploy key in GitHub; push the site; run the first deploy (a few minutes);
    connect 907.life (Cloudflare issues the HTTPS certificate, up to 15 minutes, in the rehearsal about a minute and a half);
    sign in to the admin. You can leave it running.
14. **Confirm sign-in** (`b10-site-confirm-sign-in`). The tab opens your new site's page "Almost there": "Confirm to finish signing
    in." Select **Confirm sign-in**. The admin opens, signed in as the owner, with seven default posts, all published
    (`b11-admin-signed-in`). The public home at `/` shows the Waymark theme (`b12-public-home`).
15. **Done** (`t20-done`). "... is live at https://907.life", "You're signed in to the admin in your browser", and a note that
    setup did not run dependency install scripts (run `npm rebuild` in the site's folder if a dependency needs it).

## After it is live

- A sign-in email also arrives from your site. It is a second way in, and a check that the site's mail works.
- Remove the Cloudflare grant's listing. Setup revokes its Cloudflare tokens when it finishes (a test confirmed the tokens are
  dead), but Cloudflare keeps the grant listed. In the Cloudflare dashboard open **My Profile**, **Access Management**,
  **Connected Applications**, find **cairn**, and revoke it.
- Keep the rest: the repository, the Worker, the database, the bucket, and the GitHub App (the admin saves changes through it).
  The deploy key setup stored in the repository's secrets is a Cloudflare user token named `cairn-deploy-...`; deploys use it. Revoke it
  in **My Profile**, **API Tokens**, only if the site no longer deploys.
- Run `cairn doctor` in the site's folder to check the site.

## What to tell the team

Anything that looks wrong, confusing, or slow: the screen name (or the shot's filename if you took one), what you expected, and
what you saw. The words on a few labels in the rehearsal were wrong and are fixed in dev.8; tell us if one still is.
