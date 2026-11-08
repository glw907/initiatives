# cairn new: copy deck (final for the prototype, 2026-11-08)

Every user-facing string in the setup prototype, in flow order. Register: the cairn admin's voice
(Microsoft UI-text style, professional and restrained; no cute, no chatty; the writing-voice tells).
`<name>`, `<repo>`, `<domain>`, `<n>` are filled at run time. Footer keys are written `Key action`.

## welcome

- Title: Set up a cairn site
- Body: Setup creates your site on GitHub and Cloudflare and publishes it to your domain.
- Body: You approve four requests in your browser.
- Body: You need a domain on Cloudflare and the Workers Paid plan.
- Link line: Before you start, read cairn.pub/start.
- Footer: Enter start · Ctrl+C quit

## welcome-ssh

- Title: Setup can't run over SSH
- Body: Setup opens its approval pages in a browser on the computer where it runs. Run cairn new in a terminal on the computer where you use your browser.
- Muted: Nothing was created.

## questions (title for all four): About your site

- Theme field. Label: Theme. Description: How your site looks to readers.
  - Waymark. Design: An intentionally neutral look that's easy to edit. Features: Posts and pages, light and dark modes, search. Options: None.
  - Survey. Design: A field-journal look with a bold masthead and wide photographs. Features: Photo essays, maps on pages, light and dark modes. Options: Header style.
- Header style field. Label: Header style. Description: The position of the site name in the header. Options: Centered, Left.
- Site name field. Label: Site name. Description: Shown at the top of every page. Preview row: Repository   field-notes
  - Error: Enter a name with at least one letter or number.
- AI crawlers field. Label: AI crawlers. Description: Choose whether AI companies can use your content to train their models. This setting doesn't affect search engines. Options: Block AI training, Allow AI training.
- Footers: ↑↓ choose · Enter next · Shift+Tab back (text field: Enter next · Shift+Tab back)

## browser-start

- Title: Approve setup in your browser
- Body: Setup opens a tab in your browser. Approve these four requests in that tab.
- Rows: 1 Cloudflare: Allow · 2 GitHub: Create · 3 GitHub: Install & Authorize · 4 GitHub: Approve (the button name in bold)
- Footer: Enter open your browser · Ctrl+C quit

## browser (in progress)

- Title: Approve setup in your browser
- Body: Approve each request in the setup tab. The next request opens in the same tab.
- Current-step sentence, one per approval:
  - Allow: Select Allow to let setup create your site on Cloudflare and send sign-in email from your domain.
  - Create: Select Create to add a GitHub App for <name>. The admin saves changes to your site through the App.
  - Install & Authorize: Select Install & Authorize to let setup create the <repo> repository. This access covers all your repositories. Setup removes it within seconds.
  - Approve: Select Approve to give the App access to <repo> only. Setup uses this access to push your site and store the deploy key.
- Fallback link: If no tab opened, go to http://127.0.0.1:49152
- Muted: Press Ctrl+C to stop setup. To resume, run cairn new again.

## browser-late

- Countdown line: 4:12 left to approve
- Muted: If the countdown reaches 0:00, run cairn new again to resume.

## prereq-failure

- Title: Setup needs a domain on Cloudflare
- What happened: Your Cloudflare account has no domains.
- Why: The admin sends sign-in links by email. Cloudflare sends email only from a domain on your account.
- Already done: Nothing was created.
- What to do: Register a domain with Cloudflare, or add a domain you already own to Cloudflare. Then run cairn new again.
- Links: Register a domain · Add a domain you own · cairn.pub/start

## domain (only with several domains)

- Title: Choose a domain
- Field label: Domain. Description: <n> domains on your Cloudflare account
- Footer: ↑↓ choose · Enter next

## summary

- Title: Review the settings for <name>
- Rows and reasons (muted):
  - Domain: <domain>. Reason: the only domain on your account (no reason when the owner chose it)
  - Sign-in email: sam@example.com. Reason: from your Cloudflare account
  - Repository, Worker, Database, Storage bucket: the four names. Shared reason under the group: based on your site name
  - Theme: Waymark (no reason)
  - AI crawlers: Block AI training (no reason)
  - Deploys: GitHub Actions, each time you publish. Reason: free for about 650 deploys a month · cairn.pub/deploys
- Address row (added after the builder check): Address: fieldnotes.example.com and www.fieldnotes.example.com. Reason: the bare domain and www, the default
- Footer: Enter set up · e edit email · a edit address · Ctrl+C quit
- Editing the address. Note: Use the bare domain, or a subdomain such as blog.fieldnotes.example.com. A subdomain gets no www. Footer: Enter save · Esc cancel
  - Error: That address already points to another site. Choose another address, or remove its DNS records in Cloudflare first.
- Editing the email. Note: The admin sends your sign-in links to this address. Footer: Enter save · Esc cancel
  - Error: Enter a valid email address.

## watch

- Title: Setting up <name> (elapsed time at the right)
- Steps, with the sentence shown only while the step runs:
  - Create the database: The admin stores sign-ins and settings in this database.
  - Create the storage bucket: This bucket holds the images and files that editors upload.
  - Set up email on <domain>: Cloudflare sends the admin's sign-in links from this domain.
  - Push the site to GitHub: Your site's code and content are stored in <repo>.
  - Store the deploy key in GitHub: GitHub Actions uses this key to deploy to Cloudflare. Only workflows in <repo> can read the key.
  - Run the first deploy: GitHub Actions deploys your site each time someone publishes. The first deploy takes a few minutes.
  - Connect <domain>: Cloudflare is issuing the site's HTTPS certificate. This can take up to 15 minutes.
  - Sign in to the admin: Setup emails you a one-time sign-in link and opens your site in the setup tab.
- Muted: You can leave this running. When your site is live, setup emails a sign-in link to <email>.
- Footer: Ctrl+C stop

## failure (Workers Paid)

- Title: The first deploy failed
- What happened: Cloudflare rejected the first deploy from GitHub Actions.
- Why: Your Cloudflare account doesn't have the Workers Paid plan. Every cairn site needs it. The plan costs $5 a month.
- Already done: The completed steps above are kept.
- What to do: Subscribe to Workers Paid, and then run cairn new again. Setup resumes at the first deploy.
- Link: Workers pricing

## done

- Line: Field Notes is live at https://fieldnotes.example.com
- Body: You're signed in to the admin in your browser. Setup also emailed a sign-in link to <email>. (second sentence muted)
- Next steps (label, value): Edit your site, fieldnotes.example.com/admin · Invite an editor, Admin > Editors · Read the docs, cairn.pub/docs
- Muted: Setup took 8:12.

## Ctrl+C stop line

- Before anything is created: Setup stopped. Nothing was created.
- After: Setup stopped. To resume, run cairn new again.

## too-small

- Bold: This window is too small for setup.
- Setup needs 50 columns. This window has 44. / This step needs 19 rows. This window has 14.
- Muted: Make the window larger to continue.

## done.html (browser)

- Page title: Approvals complete
- Eyebrow: cairn · Field Notes
- Heading: Approvals complete
- Body: Return to your terminal to review the settings and set up Field Notes.
- Rows: the four approvals, muted
- Footer: Keep this tab open. When setup finishes, your site opens here and you're signed in.

## error.html (browser)

- Page title: Permission needed
- Eyebrow: cairn · Field Notes · approval 1 of 4
- Heading: Select API Tokens: Write
- Body: The Cloudflare approval didn't include the API Tokens: Write permission.
- Why setup needs it: Setup uses this permission to create the deploy key for GitHub Actions.
- What to do: Select Try again. On the Cloudflare page, select API Tokens: Write, and then select Allow.
- Button: Try again
- Footer: Nothing was created. Setup continues in your terminal after you select Allow.
