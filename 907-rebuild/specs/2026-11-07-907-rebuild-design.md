# 907.life rebuild on cairn 0.99.0-rc.4

## Brief

Approving this design rebuilds 907.life on cairn rc.4, using only cairn's and Survey's published tools, the way a newcomer would. every place those tools fall short gets recorded as a backlog item.

You set two goals on 2026-11-07: a useful personal blog that also shows off four of your projects, and a real test of the engine and its new tooling. The test only counts if the builders don't have the workstation's knowledge, so two clean-room Claude Code sessions do the building, and this session watches and records.

### What changes

- Survey gains a cairn theme: a `cairn-theme/` folder in `glw907/survey`, built only from cairn's published theme docs and held to cairn's theme contract with nothing suppressed.
- The old site gets saved and retired first. Its posts, About bio, media, and settings are exported. Then its Worker, database, and bucket are deleted, and its repo is renamed `907-life-legacy` and archived.
- `npx create-cairn-site` then builds the new 907.life under the real names, `glw907/907-life` and the `907-life` Worker, and connects the 907.life domain during setup. The new site carries all eight posts, the About page, a Projects section with a page for each of four projects, and the home page you approved (variant A, the side rail).
- Every gap the builders hit goes to the place that owns it. Engine, scaffolder, skill, and docs gaps go to `conductor-cairn-cms`, Survey's go to Survey's backlog, and 907 issues go to 907-life's backlog.
- From the retirement until the new site is ready, 907.life is down or shows the bare starter (Geoff, 2026-11-07: "save the content for the current 907.life site and then delete everything and start fresh").

### If you approve

1. You run the one pre-flight sitting: sign in the clean-room Claude, and accept its workspace trust.
2. This session probes the clean room, exports the old site, and writes both briefs.
3. The retirement's inventory and dry run come to you as a separate packet while rc.4 is still waiting. The teardown runs at promotion, just before setup, so the site is down for as short a time as possible.
4. On promotion, run 2's setup runs first (your step-12 install), and run 1 starts beside it.
5. You click setup's browser approvals when this session pings you.
6. Acceptance runs, and then you get a packet for the new site, with a full-page read.

### Decide: Run the builders outside the pass process

`pass-core` expects one Sonnet executor following the plan, with pair subagents and the house gates on every task. A newcomer would have none of that, and a builder that has it would cover over the gaps this test is looking for. So both builders run without workstation skills or rules, and the house bar (visual verify, review, audits, your full-page read) applies only in the acceptance step. The departure is recorded in the PR's `## Decisions`.

Source: Geoff, 2026-11-07, in chat: "simulate the process of building a site from a new person perspective"

- Clean-room builders, with the house bar at acceptance only (recommended)
- Builders follow `site-pass`, which makes the build better and the test worse

### Decide: Let setup write 907.life's DNS once

Setup's domain chapter writes 907.life's DNS. It adds the Worker's domain record and the sign-in mail's sending records, and it sets `_dmarc.907.life` to `p=reject` (`cairn-cms/docs/admin/own-your-domain.md`, line 93). The servers repo makes `cloudflare/dns.sh` the zone's only writer (`servers/docs/decisions.md`, line 103). That script declares `_dmarc` as `p=none` with a report address, so its next `--apply` would put the old policy back. It never touches a name it doesn't declare, but its `--check` reports any such name as undeclared. `p=reject` is safe for your own mail: Stalwart signs 907.life mail with DKIM, and the `w1-ed25519` and `w1-rsa` keys both resolve. So the plan lets setup write once, the way a newcomer's domain would be written. 907-life-e7 then adds setup's records, `p=reject` included, to `cloudflare/dns/` through a servers PR, coordinated with `conductor-servers`, so `dns.sh` stays the only writer from then on.

Source: `servers/cloudflare/dns.sh`, header comment

- Setup writes once, then the servers declarations take over its records (recommended)
- Skip setup's domain chapter and connect the domain through `dns.sh` by hand, which keeps the ruling but leaves the domain and sign-in mail chapters untested

### Worth knowing

The rebuild record said the rebuild starts after `cairn-docs-standard` completes, and that initiative is still active. You started the rebuild anyway on 2026-11-07, so the record moves to active on your word.

### Roles

Three sessions take part. Each has one job, and only the observer talks to you or to the conductor.

- **Run 1, the theme author.** A clean-room session with no workstation skills, CLAUDE.md, hooks, or memory. It clones `glw907/survey` fresh, builds the theme from Survey's `DESIGN.md` and cairn's `cairn-styling-public-pages` skill, and proves it on a local-only scaffold, with no GitHub or deploy. It opens a PR on `glw907/survey`.
- **Run 2, the site builder.** A second clean-room session. It runs setup with the 907.life domain and sign-in email, adds the projects content type, migrates the content, swaps in the Survey theme once run 1 lands, and builds the home page from the prototype.
- **The observer, 907-life-e7 (Opus).** Follows each builder's output stream, pings you at browser approvals, sends backlog items to their owners, answers a builder's taste questions from this design and the prototype, and runs acceptance.

### The clean room

Each builder runs as `claude -p` in headless mode with `CLAUDE_CONFIG_DIR` pointing at an empty config directory, so no user skill, CLAUDE.md, hook, plugin, or memory loads. It works under `~/Projects/cleanroom/`. That config enables Claude Code's sandbox. Its deny rules block reads of `~/.claude`, `~/.local/secrets`, `~/.dotfiles`, and every repo under `~/Projects` except `cleanroom/`, as well as any command that touches `907-life-legacy` or the shared `cairn-build` Workers Builds registration. A probe proves the isolation before launch: the session lists no workstation skill, can't read a denied path through either Read or Bash, and starts with no trust prompt. Each builder keeps a `BACKLOG.md` as it works, adding an item wherever the published tools left it guessing, stuck, or wrong. That file is the test's one instrument.

### The brief each builder gets

A brief holds what a newcomer would bring, and nothing more. Run 1 gets Survey's public repo and tag (`v1.5.2`), cairn's published theme path, and the bar: a clean, idiomatic cairn theme. Run 2 gets:
- The goal.
- An export of all eight posts, the About bio, and the old site's media.
- One fact sheet per project, with its summary and links. Phonebook's sheet has no source link until `phonebook-public` lands.
- The approved prototype.
- The domain, 907.life, already on the same Cloudflare account, with mail on it that must keep working.
- A request for a contact form, if the published tools offer a way to build one.

### The theme's bar

The theme follows cairn's published contract and nothing else:
- Its look comes through the token for each job.
- It uses stock daisyUI components.
- `npx cairn-audit --rule public-literals --rule theme-conformance --rule theme-contrast` passes with nothing suppressed.
- It has no `!important` and no hand-written `[data-theme]` overrides.
- It contains all five of Survey's signature details, with the collar's two fields as site settings.

Where the contract can't carry Survey cleanly, that gap is a backlog item, with the smallest workaround marked by the item's id. A site takes the theme by copying the folder in. Since no published path covers that step, it's a backlog item too.

### The site

Navigation is Writing, Projects, and About. The home page is variant A from the prototype (artifact `VJDBSisKZ5KRnqSXwKc8d5`): an intro sentence, the post stream grouped by year, and a quiet Projects rail. On a phone the rail falls below the first year's posts. Projects is a second cairn content type next to posts, edited in the admin. Each project has a name, a summary, a status, and site, source, and docs links. Its page carries general information and links, and its source link is optional. The four projects are cairn-cms, dubplate, phonebook, and approval-queue.

### Sequence and estimate

The path runs about 600 minutes:
- Prep, the clean-room probe, and the export, 45.
- The teardown, 15.
- Setup with the domain and sign-in email, then the first deploy, 45.
- Run 1's theme, 180, running beside run 2's projects type and content migration, 120.
- The theme swap and the home page, 120.
- Acceptance and its fix rounds, 150.
- The servers DNS declarations, 30.

The ceiling is 1,200 path minutes. rc.4 now waits on the name-clash fix in your queue, so the start waits too.

### Retirement first

The old site is retired through `retire-project` before setup runs. Retiring it first gives setup the real names, and it skips the cutover. The export and the inventory happen while rc.4 waits. The teardown runs at promotion, so 907.life is dark only from the teardown to setup's first deploy. The steps:
1. Export the posts, the About bio, the R2 media, the editor list from `cairn-907-auth`, and the names of the secrets in use. All of it goes into an encrypted archive.
2. Rename `glw907/907-life` to `907-life-legacy` and archive it. That frees the name, and it can be undone.
3. Delete the `907-life` Worker, the `cairn-907-auth` database, and the `907-life-media` bucket, after a dry run that lists each one. This can't be undone.
4. Leave the shared `cairn-build` registration and the shared GitHub App alone.

The inventory and the dry run come to you as a separate packet. Your approval there authorizes the deletes.

### Standing answers

The run takes these answers without stopping:
- **A backlog item that blocks a builder.** The observer sends it to the conductor right away, and the builder waits. When a fixed candidate ships, the builder resumes on it, and the observer records which version it moved to.
- **A builder's question a newcomer would answer for themselves.** The observer answers it from this design and the prototype. Only a product, taste, or scope question this design doesn't settle comes to you.
- **A builder struggling.** The observer lets it struggle, since that is where the gaps show. It steps in only when the builder is truly stuck, as the spec defines it, and each hint is logged as a backlog item (Geoff, 2026-11-07).
- **Setup offering a second Workers Builds registration.** The builder stops, and the observer tells the conductor.
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
