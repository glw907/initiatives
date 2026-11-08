# cairn site setup redesign: the design so far (2026-11-08, brainstorm in progress)

cairn is an embedded, magic-link, GitHub-committing CMS for SvelteKit on Cloudflare Workers. Each
site is a SvelteKit repo on the owner's GitHub; the CMS's admin commits content through a per-site
GitHub App; the site runs on Cloudflare Workers with D1, R2, Email Sending (magic-link sign-in),
and deploys from GitHub Actions. Setup today is `npm create cairn-site` (JavaScript, @clack/prompts); its
live run on 0.99.0-rc.4 was "way too manual, user-hostile, and fragile".

## Standing goals (Geoff)

- The lowest possible friction for a new owner, at the web admin's UI/UX bar.
- Lean: the tool stays as small and simple as quality allows (2026-11-08). No mode, flag, or path
  that only a minority needs.
- Very effective for AI agents to drive.
- Gently educational: the terminal says what it's doing and why, and the browser opens by itself.
- Never: walls of streamed output, visual clutter, failure, and above all unexplained failure.

## Who the owner is

Comfortable in a terminal. Probably has a GitHub account (not guaranteed) but no repo for the site;
assume no Cloudflare account; most make one site. They probably read cairn.pub's before-you-start
page first; the command's first screen points there in case they didn't.

## Friction ranking (cheapest first)

A one-click approval that returns by itself; waiting with nothing to do; a choice to think about;
switching windows (very high when you can't tell which window wants you); a form; a copy-paste;
anything that fails silently. Any copied URL is a failure.

## Shape

One opening collects every answer and every browser approval, ends on one summary screen with a
single "go", then the owner only watches a fixed plan tick off. Rerunning resumes; no lockout. A
failure in the watching stretch is a cairn bug: everything checkable is checked in the opening.

## Before setup: prerequisites (decided 2026-11-08)

The before-you-start page on cairn.pub lists, each linked to the provider's own instructions:
a GitHub account; a Cloudflare account ("Continue with GitHub" on Cloudflare's sign-up works; only
the in-form Sign up link keeps the return path); Workers Paid ($5/month; no API reads or sets it);
and **a domain already on Cloudflare**, either registered at Cloudflare or migrated there
(nameserver change, activation can take hours). The domain is required: Email Sending needs a
domain on Cloudflare DNS, and without email nobody can sign back in or invite an editor. There is
no workers.dev or preview path. The opening checks each prerequisite; a failed check names the
exact section of the page, and the next run resumes there (a pending zone says "still activating").

## The opening

Asks: theme (curated catalog on cairn.pub; Waymark default, Survey second; each entry describes its
design, features, options; a theme may declare options setup asks for; Waymark's entry says it is
an intentionally neutral, easy-to-edit default, Geoff 2026-11-08), site name, domain (picked
from the account's active zones; a choice only when there is more than one), sign-in email,
AI-crawler stance; GitHub owner and Cloudflare account only when there is a real choice. No brand
color, no "do this now?" confirms. Detects SSH, remote, and CI sessions up front.

The summary shows every derived value with a one-line reason ("derived from your site name"), and
derived names are editable there. One "go".

## The approval chain (spiked)

"Press Enter to open your browser." Setup opens a local loopback page once; each approval chains in
that tab, and each page says what happened and what's next. The last page says setup is running in
the terminal. Two window switches total.

1. GitHub App manifest (with `administration: write`): "Create". Proven; a signed-out owner signs
   in mid-chain and lands back on Create intact.
2. Plain install (All repositories): "Install & Authorize". Setup uses the user token to create the
   repo (201), then deletes the All install with the App JWT within about 5 s. Proven (Flow K).
3. Install preselected to only the new repo: "Approve, Install & Authorize". Setup reads back
   `repository_selection: selected` with exactly that repo and refuses an over-grant. The
   installation token pushes the site and its workflow. Proven, 4 of 4 runs.
4. Cloudflare OAuth consent, cairn-owned public client (auth code + PKCE, any loopback port):
   "Allow". API Tokens Write is a sensitive scope the owner ticks; setup checks the granted scopes
   and re-asks on the spot if one is missing. Proven on a private client.
That is the whole chain: four clicks. Workers Builds is dropped (decided 2026-11-08), so
Cloudflare's own GitHub App and its dashboard detour are gone.

## Deploys: GitHub Actions (decided 2026-11-08)

Each push runs one workflow job: install, check, build, then `wrangler deploy`, with a concurrency
group that cancels a deploy a newer push supersedes. The deploy token is a narrow, long-lived
Cloudflare token (Workers Scripts, D1, R2, the same scope as today's "cairn-build" token), minted
from the OAuth grant and stored as a repository secret by the App (so the App also needs Secrets
write; the value is sealed to the repo's public key). The admin shows when the last deploy failed;
GitHub emails the owner on a failed run by default.

Known cost: GitHub's free plan includes about 2,000 Actions minutes a month on private repos (public
repos are unlimited), roughly 650 publishes at an estimated 3 minutes each; when they run out,
deploys stop until the month resets. Workers Builds includes 6,000 with Workers Paid. The docs
record this decision and explain how a busy site switches to Workers Builds by hand. No switch
command (lean). Setup explains it in the flow too: a "Deploys" line on the summary with the limit
and a link to cairn.pub's page, and the first-deploy step's sentence (Geoff, 2026-11-08).

## Flow order (Claude's calls from the prototype, 2026-11-08)

Welcome, then the terminal questions (theme, theme option, site name with the live repository
name, AI crawlers), then "Press Enter to open your browser". The approvals run Cloudflare first,
then GitHub's three, so the domain check runs before anything exists on GitHub. Then the summary
in the terminal, then one "go", then the watch. Names are settled before the browser opens: the
summary shows repository, Worker, database, and bucket read-only (a taken repository name gets a
suffix and says why). Only the sign-in email is editable. With several domains, the choice is its
own short question right after the approvals (it fits 60x24 with five); the summary shows it
read-only. The welcome names both prerequisites (a domain on Cloudflare, Workers Paid). The last browser page says setup is waiting in the terminal for you to
confirm. Over SSH, setup says to run it on the computer you browse with. Inline, not
full-screen; the final frame stays in scrollback. Minimum 50 columns.

The aim (Geoff, 2026-11-08): use all the levers, leaning toward clean, simple beauty, with the
prose and the visual design fully aligned.

Copy and layout (Geoff, 2026-11-08): every string follows the house register, the cairn admin's
Voice (Microsoft UI text, professional and restrained), and the tool's binding CLI copy standard
(`tool/docs/design/copy-standard.md`: its messages tables, `make check-copy`, and section 2.7's
error grammar for agent-mode stderr). The deck is `copy-deck-final.md`; one layout grid governs
every screen (`layout-grid.md`). Charm levers in use: a window title per phase (tells the owner
which window wants them), the terminal progress indicator, bubbles help for footers, a Warm Stone
Huh theme.

Open for the written design: detect Workers Paid in the checks (the one failure the watch can
still hit today); resume when the App exists but the install never finished; Huh v2.0.3 limits
(unfocused fields ignore the theme, pages pad to the tallest field).

## Non-goals

Setup makes a clean new site. Content migration is out (Geoff, 2026-11-08): a migration skill or
process may come later as its own feature; file it in ROADMAP with the written design.

## After this brainstorm

Geoff wants a second brainstorm, on tooling, once this one is done: in this session or a new one
with clean context. Scope (Geoff, 2026-11-08): the tooling that proves setup (gate, test accounts,
#366), the Claude tooling (skills, agents, rules), the packaged skills, and the docs, rebuilt
around the new setup process and CLI. Inputs: the rc.4 build session recon, the naive builders'
friction files, and the 907-rebuild planning-misses record. Ruling: a naive builder never gets a
theme to build; naive builders test docs-driven mechanical paths, and the theme comes from the
catalog.

Tradeoffs: an All install exists for about 5 s; `administration: write` stays on the App for the
repo's life (the Worker requests content-only installation tokens; dropping it costs one more
approval).

## After consent

Setup mints short-lived narrow Cloudflare tokens from the OAuth token (wrangler takes them as
`CLOUDFLARE_API_TOKEN`; no `wrangler login`). Every OAuth refresh revokes the old access token, so
setup persists each new pair and never hands a superseded token to a subprocess. One GitHub App per
site. No credentials kept for a second site.

## Watching and the end

No streamed output; a fixed plan with a clutter budget. A failure reads in four parts (what
happened, why, what setup already did, what to do). Limits: the approval chain 30 min with a
countdown in the last 5; HTTPS on the domain 15 min. The sign-in is last: setup writes a one-time
sign-in link into the site's database and the loopback tab redirects to the live site, signed in.
Look: the admin's Warm Stone palette.

## Two lanes (Geoff, 2026-11-08)

Clean-site setup has two first-class lanes over one set of setup steps: the human-driven lane
(the terminal UI) and the agent-driven lane (flags, plan file, event stream, waiting states, with a
human clicking only the four approvals). Each lane gets its own docs entry point and its own
release-candidate test: Geoff's own install for the human lane, the naive-agent run for the agent
lane, both on top of the shared offline and real-account suites.

## One flow, attended or not (Geoff, 2026-11-08)

The best case for every run, attended or not, is a short attended start (the questions, the four
approvals, the summary's one Enter), then a run that needs nobody. The watch screen says the owner
can leave. When the site is live, setup emails the owner a one-time sign-in link, and if the setup
tab is still open it also redirects there, signed in. There is no separate unattended mode: an
agent or CI run differs only in who supplies the answers and the approvals (a plan file; Playwright
on the test account for GitHub; an injected Cloudflare API token in place of the consent). GitHub
has no API to create or install an App, so a run from zero always needs those three clicks once.
To verify in the design: a brand-new sending domain's first email may land in spam.

## The agent kit (decided 2026-11-08)

Claude Code is the single target agent for now (Geoff). Before a site exists: the CLI describes
itself (`cairn new --help`, `cairn help agents`, a schema command for the plan file and events,
all generated from the step definitions); one new skill, `cairn-setting-up-a-site`, thin, deferring
to `cairn help agents`; cairn.pub serves each docs page as plain markdown, version-stamped, with an
agent entry page beside before-you-start. No llms.txt (evidence of agent use is thin). During
setup, each waiting state carries the sentence to show the person; a status command reads
progress. After setup, the scaffold's four packaged skills, with the setup skill handing off to
`cairn-extending-a-site`. Suggested for every site, preconfigured by the scaffold where Claude
Code allows: cairn's skills, the Svelte MCP server, Cloudflare's skills, the daisyUI skill; nothing
generic. The naive-agent run on each release candidate runs with and without the setup skill.

Single source (Geoff, 2026-11-08): the markdown docs in the cairn repo are the one source of truth.
cairn.pub renders them (it already does, from the installed package), and everything else derives:
the CLI's no-terminal guide embeds the agent page at build time; the flag and event reference is
generated from the step definitions into a docs page that a gate keeps in sync; the setup skill,
the README sections, and the site agent guide route to the docs pages instead of restating them;
the plugin suggestions live on one docs page that the others link to.

Install order (Geoff, 2026-11-08): before setup, only the cairn plugin (the setup skill). At the end
of setup, the agent installs the vendor plugins (Svelte from `sveltejs/ai-tools`, Cloudflare from
`cloudflare/skills`, daisyUI from `saadeghi/daisyui`); the scaffold declares them in the site's
`.claude/settings.json` (plugins from external sources still need one install per person) and the
Svelte server in `.mcp.json`. GitHub's plugin is not in the default set. The suggestions are part
of the docs and the process: the agent entry page, the before-you-start page, the setup skill, and
the site's own agent guide all list the same set from one source.

## Agents

One set of setup steps with two views: a Bubble Tea UI for people, and flags for every answer, a
plan file (`cairn new --apply plan.json`), a `--plan --json` dry run, an NDJSON event stream,
stable exit codes, and browser approvals surfaced as named waiting states whose text tells the agent
to show the step to the human and keep running. An auth.md on cairn.pub. The sign-in link never
appears in agent output.

## Build

Go with Charm (Bubble Tea v2, Huh v2, Lip Gloss v2), likely inside the existing `cairn` Go tool
(`cairn new`), with `npm create cairn-site` kept as a thin launcher. Charm pieces to weigh in the
design (checked 2026-11-08; Charm ships no MCP server or Bubble Tea agent skill): teatest v2
(`x/exp/teatest/v2`, experimental, pinned to a v2 rc) for golden-frame tests in #366; Fang v2
(styled Cobra help, errors, man pages, completions, themeable to Warm Stone) for the whole tool;
VHS (`standards:vhs-cli-demos`) for cairn.pub's before-you-start page and docs; Crush as the
reference v2 codebase. Not Tone (Charm's brand palette). Next: a throwaway prototype of
every screen on fake data, reviewed by Geoff; then the written design with a builder check; then a
plan with outside-in tests (#366) first.

## Plan scope (Geoff, 2026-11-08)

The plan includes the docs fixes and building the Claude Code tooling the agent lane needs (the
cairn plugin and its marketplace entry, the setup skill, the scaffold's `.claude/settings.json` and
`.mcp.json`, the site agent guide's plugin section, the plugin-suggestions docs page), not only the
CLI. The harness that proves setup (gate legs, #366, clean-room settings) stays for the tooling
brainstorm, which takes the test shape above as its input.

Placement (Claude's call): the work spans cairn-cms, cairn-pub (markdown copies of docs pages), and
the shared-standards marketplace, so the written design goes in a new initiative record,
`cairn-setup`, status `proposed`, at `~/Projects/initiatives/cairn-setup/specs/`.

## Starter content (Geoff raised, 2026-11-08)

Today's scaffold ships the showcase's trail demo into every new site: 14 posts (11 are one-line
topic-filter fixtures), a "trail crew" author page, a fragment. That demo reached the live 907.life
domain (miss 15). A new site needs plain starter text instead. Proposal: a home page and an About
page that use the site's name, and one first post, a short guide to writing in cairn adapted from
"The reading surface", each easy to edit or delete; the fixtures move to the showcase and tests.
Copy follows the editor register (Microsoft). Open: confirm the set with Geoff.
Geoff, 2026-11-08: the starter text is in the house register (cairn's editor brief over Microsoft,
the same voice as the admin and the editor docs), and the set adds a sample Contact page. The
engine has no contact form, and a form would be site functionality (scope charter). Proposal: a
plain markdown Contact page with a placeholder address the owner replaces; setup never publishes
the sign-in email on a public page.
Geoff, 2026-11-08: the set also gets an archives page and enough items to exercise a theme
properly. Waymark's home is archive page one (lead and topic filter), `archive/[page]` the rest,
13 per page, and the content uses ten directives (alert, banner, cta, faq, figure, icon, include,
points, pull-quote, video). Proposal (Claude's): one starter corpus, owned by cairn, that is both
every new site's starter content and the conformance corpus every catalog theme must render (ties
to #361). Its posts are short real how-tos in the house register, one task each (add a page,
change the menu, add an image, use a topic, invite an editor, and so on), enough to fill two
archive pages; together they cover every page type and every element and directive the theme
contract names. The one-line placeholder fixtures go.
Geoff, 2026-11-08: some test pages show all possible markdown. The engine parses CommonMark
(remark-parse) plus GFM (remark-gfm: tables, task lists, strikethrough, extended autolinks,
footnotes) plus directives (remark-directive), and passes raw HTML through rehype-raw and
rehype-sanitize. So the corpus carries a syntax page per layer: every CommonMark construct, every
GFM extension, every directive the theme contract names, and the raw HTML the sanitizer keeps
(and one it strips). Research on mature theme test corpora is running to check coverage.
Geoff, 2026-11-08: standard content and structure, so an owner can easily compare themes. The
corpus is theme-independent: one content model (the collections, front-matter fields, and page
paths every theme reads) and one set of pages, which every catalog theme renders unchanged. A theme
may not require content of its own. This becomes part of the theme contract (#361).
Prior art (research, 2026-11-08; WordPress Theme Unit Test and starter-content API, Ghost gscan,
Hugo theme rules, Astro's markdown-style-guide, Eleventy, Minima, CommonMark spec): mature systems
keep two artifacts. Proposal now: (1) a small, friendly, standard starter set (home, archive page
one, About, Contact, an author page, a handful of how-to posts including one "everything renders"
post on Astro's model, each directive once, one image and one video), identical for every theme so
an owner compares themes on the same pages; (2) a separate conformance corpus for theme authors and
CI, never shown to owners, holding the hostile cases: three-plus archive pages with a short last
page, a child page, 404 and error pages, feeds, many topics, long titles and unbroken strings, no
title, no image and image-only posts, drafts hidden, non-ASCII and RTL text, every directive empty,
long, and nested, fragments, and one page per markdown layer (CommonMark blocks, CommonMark inlines,
GFM, raw HTML kept and stripped; the commonmark-spec npm package's examples can seed it). Backed by
a gscan-style machine check of the theme's markup contract. Starter assets ship with the site, never
hot-linked (WordPress forbids external URLs in starter content; Waymark's posts hot-link Unsplash
today). This replaces the earlier "one corpus, 14 how-tos" proposal.
Geoff approved the two-set split, 2026-11-08.
