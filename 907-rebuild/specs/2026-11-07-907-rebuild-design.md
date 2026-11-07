# 907.life rebuild on cairn 0.99.0-rc.4

## Brief

Approving this design rebuilds 907.life on cairn rc.4, using only cairn's and Survey's published tools, the way a newcomer would. Every place those tools fall short gets recorded as a backlog item.

You set two goals on 2026-11-07: a useful personal blog that also shows off four of your projects, and a real test of the engine and its new tooling. The test only counts if the builders don't have the workstation's knowledge, so two clean-room Claude Code sessions do the building, and this session watches and records (your ruling, 2026-11-07). The house bar (visual verify, review, audits, your full-page read) applies at acceptance, not to the builders.

Your mail keeps working throughout (Geoff, 2026-11-07: "my mail needs to continue to work"). A mail check runs before the teardown, after it, and after setup: `dns.sh --check` finds every mail record unchanged, and before the teardown and after setup you send one message to `glw@907.life` that this session reads on ward. Any change to a mail record stops the run until `conductor-servers` puts it back.

One part of mail does go down. The three `/.well-known` redirects that point a mail client at ward stop answering when the teardown detaches the old site's domain, and come back when setup attaches the new one, about an hour later unless setup stops first. They serve only a client's first setup: delivery, sending, and clients you already use don't touch them. Setup's check confirms all three answer again, and if they don't, the run stops under the mail requirement.

### What changes

- Survey gains a cairn theme: a `cairn-theme/` folder in `glw907/survey`, built only from cairn's published theme docs and held to cairn's theme contract with nothing suppressed.
- The old site gets saved and retired first. Its posts, About bio, privacy page, media, and settings are exported. Then its Worker, database, and bucket are deleted, and its repo is renamed `907-life-legacy` and archived.
- `npx create-cairn-site` then builds the new 907.life under the real names, `glw907/907-life` and the `907-life` Worker. You run setup in your terminal, the way cairn's docs tell a newcomer to, and it connects 907.life, sign-in email, and Workers Builds in that one run (Geoff, 2026-11-07: "connect the domain at setup, not after acceptance").
- The new site carries all eight posts, the About page, the privacy page, a Projects section with a page for each of four projects, and the home page you approved (variant A, the side rail).
- Every gap the builders hit goes to the place that owns it. Engine, scaffolder, skill, and docs gaps go to `conductor-cairn-cms`, Survey's go to Survey's backlog, and 907 issues go to 907-life's backlog.
- From the teardown until setup's domain step finishes, 907.life's pages, the privacy page, and the mail discovery redirects are down. Then it shows the bare starter until the new site is ready (Geoff, 2026-11-07: "save the content for the current 907.life site and then delete everything and start fresh").

### If you approve

1. You run the one pre-flight sitting: set up the clean room, sign in both clean-room Claude sessions and `gh`, and prove a wrangler sign-in in the clean shell.
2. This session probes the clean room, exports the old site, and writes both briefs.
3. The retirement's inventory and dry run come to you as a separate packet while rc.4 is still waiting. At promotion you run the reviewed teardown script, just before setup, so the site is down for as short a time as possible.
4. On promotion, run 1 starts. Run 2 hands you its setup command, and you run it in the clean shell (your step-12 install), clicking its browser approvals.
5. Acceptance runs, and then you get a packet for the new site, with a full-page read.

### Decide: Let setup write 907.life's DNS once

Setup's domain step adds the Worker's domain record to 907.life, and its email step onboards the domain for Cloudflare Email Sending. The servers repo makes `cloudflare/dns.sh` the zone's only writer (`servers/docs/decisions.md`, line 103). The zone is already onboarded, since `cf-bounce.907.life` answers today, and Cloudflare's docs say "If you already have a DMARC record, Cloudflare keeps it unchanged." So `_dmarc` should stay at its declared `p=none`, even though setup's closing message says it wrote `p=reject` (`chapter2.mjs`, line 1064). The run treats that message as a cairn backlog item. If `_dmarc` does change, `conductor-servers` puts the declared value back with `dns.sh --apply`. A move to `p=reject` is the servers repo's call, not this rebuild's. After setup, a servers PR declares the Email Sending records, so `dns.sh` stays the only writer from then on.

Source: `servers/cloudflare/dns.sh`, header comment; `servers/cloudflare/dns/ward`, line 18

- Setup writes once, then the servers declarations cover its records (recommended)
- Skip setup's domain and email steps and connect the domain through `dns.sh` by hand, which keeps the ruling but leaves those steps untested

### Decide: Bring a long outage to you after 48 hours

If setup fails after the teardown on an engine defect, 907.life stays dark while the conductor ships a fix, and nothing in this design limits how long. Restoring the old site means rebuilding it from the archive: rename the repo back, recreate the database and bucket, and deploy the old `main`.

- After 48 hours dark, the observer stops and brings you the choice of waiting or restoring (recommended)
- The site stays dark until the fix ships, however long that takes

### Worth knowing

The rebuild record said the rebuild starts after `cairn-docs-standard` completes, and that initiative is still active. You started the rebuild anyway on 2026-11-07, so the record moves to active on your word.

`pass-core` expects one Sonnet executor with pair subagents and the house gates on every task. The builders run without them, by your clean-room ruling, and the PR records that departure in its `## Decisions`.

### Roles

Three sessions take part. Each has one job, and only the observer talks to you or to the conductor.

- **Run 1, the theme author.** A clean-room session. It clones `glw907/survey` fresh, builds the theme from Survey's `DESIGN.md` and cairn's `cairn-styling-public-pages` skill, and proves it on a local-only scaffold, with no GitHub or deploy. It opens a PR on `glw907/survey`.
- **Run 2, the site builder.** A second clean-room session. It works out the setup command and hands it to you, then adds the projects content type, migrates the content, swaps in the Survey theme once run 1 lands, and builds the home page from the prototype.
- **The observer, 907-life-e7 (Opus).** Follows each builder's output stream, pings you when you're needed, sends backlog items to their owners, answers a builder's taste questions from this design and the prototype, and runs acceptance.

### The clean room

Each builder runs as `claude -p` with a separate home directory under `/var/tmp/cairn-cleanroom/`, outside your home, so no CLAUDE.md, skill, or rule of yours sits above its work. It starts from a cleared environment that holds no workstation secret, SSH agent, or keyring session. Its settings turn on Claude Code's sandbox, hold its file tools and commands to its work tree, close your home, `/tmp`, and your session's runtime directory, turn off claude.ai connectors and synced skills, and allow only a short list of commands. Each builder signs in to `gh` and wrangler separately. Run 1 never signs in to Cloudflare, and run 2 signs out of wrangler once setup ends. A probe proves the isolation before launch. Each builder keeps a `BACKLOG.md` as it works, adding an item wherever the published tools left it guessing, stuck, or wrong. That file is the test's one instrument.

### The brief each builder gets

A brief holds what a newcomer would bring, and nothing more. Run 1 gets Survey's public repo and tag (`v1.5.2`), cairn's published theme path, and the bar: a clean, idiomatic cairn theme. Run 2 gets:
- The goal.
- An export of all eight posts, the About bio, the privacy page, and the old site's media.
- One fact sheet per project, with its summary and links. Phonebook's sheet has no source link until `phonebook-public` lands.
- The approved prototype.
- The domain, 907.life, already on the same Cloudflare account, with mail on it that must keep working.
- A request for a contact form, if the published tools offer a way to build one.

### The theme's bar

Acceptance holds the theme to cairn's published contract and nothing else:
- Its look comes through the token for each job.
- It uses stock daisyUI components.
- `npx cairn-audit --rule public-literals --rule theme-conformance --rule theme-contrast --fail-on advisory` passes with nothing suppressed and nothing left unmeasured.
- It has no `!important` and no hand-written `[data-theme]` overrides.
- It contains all five of Survey's signature details, with the collar's two fields as site settings.

Where the contract can't carry Survey cleanly, that gap is a backlog item, with the smallest workaround marked by the item's id. A site takes the theme by copying the folder in. Since no published path covers that step, it's a backlog item too.

### The site

Navigation is Writing, Projects, and About. The home page is variant A from the prototype (artifact `VJDBSisKZ5KRnqSXwKc8d5`): an intro sentence, the post stream grouped by year, and a quiet Projects rail. On a phone the rail falls below the first year's posts. Projects is a second cairn content type next to posts, edited in the admin. Each project has a name, a summary, a status, and site, source, and docs links. Its page carries general information and links, and its source link is optional. The four projects are cairn-cms, dubplate, phonebook, and approval-queue. The privacy page stays at `/privacy.html`, since Google requires it for your Geoff's Tools sign-in app.

### Sequence and estimate

The path runs about 680 minutes:
- Prep, the clean-room probe, the export, the briefs, and the retirement packet, 145.
- The teardown and setup with the domain, sign-in email, and Builds, 85, then run 2's projects type and content migration, 120. Run 1's theme, 180, runs beside these.
- The theme swap and the home page, 120.
- Acceptance and its fix rounds, 150.
- The close and the end-to-end check, 60.

The servers DNS declarations, 20, run beside the builders. The ceiling is 1,200 path minutes. rc.4 now waits on the name-clash fix in your queue, so the start waits too.

### Retirement first

The old site is retired through `retire-project` before setup runs. Retiring it first gives setup the real names, and it skips the cutover. The export and the inventory happen while rc.4 waits. The steps:
1. Export the repo bundle, the posts, the About bio, the privacy page, every R2 object, the whole `cairn-907-auth` database, and the names of the secrets in use. All of it goes into an encrypted archive, proven by a scratch restore.
2. Remove the old site's secrets from `sync.sh` and the registry through a dotfiles PR, so a routine sync can't push the shared App key into the new Worker.
3. At promotion, you run the teardown script. It detaches the 907.life domain from the old Worker, which opens the redirect gap. It then deletes its Builds triggers, the `907-life` Worker, the `cairn-907-auth` database, and the emptied `907-life-media` bucket. It deletes the repo's Actions token secret, renames the repo to `907-life-legacy`, and archives it. The deletes can't be undone.
4. Leave the shared `cairn-build` registration, the shared GitHub App, the Email Sending onboarding the servers monitor shares, and the zone's mail records alone.

Three `retire-project` steps would break mail or don't fit, so they don't run: removing the zone's DNS records (step 4.1, apart from the old Worker's own domain record), parking the domain with `MX 0 .` (step 4.4), and deleting the repo (step 4.5, replaced by the rename). The inventory and the dry run come to you as a separate packet. Your approval there authorizes the deletes.

### Standing answers

The run takes these answers without stopping:
- **A backlog item that blocks a builder.** The observer sends it to the conductor right away, and the builder waits. When a fixed candidate ships, the builder resumes on it, and the observer records which version it moved to.
- **A builder's question a newcomer would answer for themselves.** The observer answers it from this design and the prototype. Only a product, taste, or scope question this design doesn't settle comes to you.
- **A builder struggling.** The observer lets it struggle, since that is where the gaps show. It steps in only when the builder is truly stuck, as the spec defines it, and each hint is logged as a backlog item (Geoff, 2026-11-07).
- **A mail check fails, or a mail record changes.** The run stops before anything further runs, and `conductor-servers` restores the record through `dns.sh`.
- **Setup offering a second Workers Builds registration.** You decline it, and the observer tells the conductor.
- **A gap in the theme contract.** It becomes a backlog item, and the theme carries the smallest workaround, marked with the item's id.
- **A Survey gap.** It goes into Survey's `BACKLOG.md` as a direct commit, which `DESIGN.md` asks for.
- **Anything irreversible beyond what this design and the retirement packet approve** waits for a separate packet. Setup's DNS writes are approved here, if you take the recommended choice.

### Backlog sweep

All four open items in `907-life/BACKLOG.md` got a verdict:
- **#2 (devcontainer): keep.** It moves to the new repo's backlog at acceptance.
- **#3 (PR test workflow): fold.** Acceptance checks whether the scaffold ships PR CI. If it doesn't, that's a backlog item, and the workflow gets added.
- **#4 (Survey look): fold.** This pass delivers it. The item's source path, `cairn-themes/survey-theme/`, is stale, since Survey now lives in `glw907/survey`.
- **#5 (failing Workers Builds check): done at retirement.** The check belongs to the old Worker. Acceptance watches whether the new site's PR checks fail the same way.

### Backlog items so far

The design work has turned up three backlog items so far:
- **Setup's name clash.** Setup never checked for an existing Worker, D1 database, or bucket with the same name before its first deploy. The conductor confirmed it, you ruled that it blocks rc.4, and the fix is in your queue.
- **No theme picker.** No published path takes a third-party theme into a site, and create-cairn-site has no way to choose a theme.
- **Survey's skill and design guide disagreed** on where a gap goes. `glw907/workstation#211` points the skill at `BACKLOG.md`, the file Survey's `DESIGN.md` names.
