# Site basics: what every new cairn site starts with

Replaced on 2026-11-17. Round `site-basics` is stopped (`20261117-182825-8b4207`), and its work
moves to the route in `specs/2026-11-17-route-rounds.md`, which Geoff approved in queue document
`20261117-210356-a03b21`. This file is kept as the source of its findings.

Initiative: theme-garden. Round: `site-basics`. Status: draft, waiting for Geoff's approval.
Read against cairn-cms at `6499871a8`.

## Brief

A new cairn site picks its kind first: blog, organization, portfolio, documentation, or product
page. Each kind starts with the features that the large majority of real sites of that kind have.
This round builds the four shared ones, which are a contact form, search, topic pages, and social
links, and it teaches `cairn new` to ask for the kind, the look, the form, and the links. Its last
pass writes the published documentation for the whole system: kinds, content sets, themes, and the
catalog. Six passes run in one chain of about 700 path minutes. The round starts after the events
round closes
and before Survey.

## Why

A survey of 88 public sites on 2026-11-15 showed what each kind of site carries
(`research/site-features-survey-2026-11-15.md`). Today `cairn new` hands every owner the same blog
with a different look. A club gets no way to be written to, a documentation site gets no search,
and a developer builds both by hand on every site. Cloudflare already supplies the hard parts of a
contact form: mail sending, a bot check, and a rate limit. cairn can therefore ship a working form
where most starter kits ship an address that collects spam.

## Decided by Geoff

Each line is Geoff's, from the brainstorm of 2026-11-15.

- The feature lists cover every cairn site kind, "blogs, documentation, and the other cairn
  template sites".
- What `cairn new` hands over is "really more like starter kits", with "(at least) one starter kit
  per site type". Each has "different functionality aimed at its audience", set by what "the large
  majority" of sites of that kind have. A developer builds the less common items.
- A new site chooses "kind first, then a look with a default". `cairn new` offers "only declaring
  themes, flag as the override".
- "Lift the cap to five. Waymark should work with all five." Waymark "grows one kind at a time as
  each set lands".
- The contact form "should probably be the default over a bare email address because the latter is
  a spam magnet". It is "on for organization and portfolio, off for the rest", with the switch in
  `cairn new`.
- Search is on for documentation, blog, and organization. Topic pages are on for the blog kind,
  with a switch for organization, because a "news-heavy organization will need topics".
- For social links, `cairn new` asks "the links-or-no-links question" and then collects "which
  social links" with their addresses. The list is Facebook, Instagram, YouTube, LinkedIn, Bluesky,
  Mastodon, TikTok, X, Strava, GitHub, and "other". cairn "can do a basic check", on the
  understanding that the developer "can always fix it later".
- The round "should include adding documentation of the new system: the themes, types, catalog,
  etc."
- "I'd like to get the kind features established now, and we can then do the ongoing work as we
  add new sites."

## The feature list for each kind

| Feature | Blog | Organization | Portfolio | Documentation | Product page |
| --- | --- | --- | --- | --- | --- |
| Contact form | switch, off | on | on | switch, off | switch, off |
| Search | on | on | switch, off | on | switch, off |
| Topic pages | on | switch, off | none | none | none |
| Social links | asked | asked | asked | asked | asked |
| About page | yes | yes | yes | no | no |
| Privacy page | yes | yes | yes | yes | yes |

The columns are the kinds in `sets/kinds.json`, whose ids are `blog`, `organization`, `portfolio`,
`docs`, and `landing`. Flags and files use the ids. Geoff asked for a privacy page wherever the
form is on. Every set carries one, so that a site whose owner switches the form on later already
has the page the form links to (Claude's call).

Every kind also keeps what the template has today: a themed "not found" page, a sitemap, feeds,
and a paged archive. Link-preview tags move from the article view to every page.

This round builds the blog and organization columns. The other three columns are recorded now and
built when each kind's content set is written.

## Goals

1. Each of the four shared features exists once, in the site template, and a content set switches
   it on or off for its kind.
2. `cairn new` asks the kind, then the look, then the form and the links, and writes a site that
   matches the answers.
3. A site with the form on receives a visitor's message by email after `cairn new` finishes, with
   no hand setup where the tool's sign-in allows it.
4. A developer finds every switch, with its default for each kind, on one docs page.
5. A developer who has never seen the catalog can learn from the published docs what a kind, a
   content set, and a theme are, pick a starter, and write a theme that passes the theme check.

## Non-goals

- The portfolio, documentation, and product-page content sets, and their columns of the table.
- A newsletter box, comments, a donate button, a member sign-in, a phone or address block, a
  people page, a gallery, or an FAQ. The survey found each on fewer than the large majority of
  sites, or it belongs to the developer.
- Storing contact messages, an admin screen for them, file uploads, or an automatic reply to the
  visitor.
- `cairn new` reading the hosted catalog. The catalog design's step 2 keeps that work.
- An engine release. A pass never publishes the package.

## Anti-goals

- A page that prints an email address because the form isn't ready.
- A form that accepts a message and drops it.
- A feature a kind doesn't use that still loads script or shows a control on that kind's sites.
- A new engine export or a new key in `site.config.yaml` for any of this.
- A token or sign-in widened so that setup can finish.

## What an owner is asked

`cairn new` asks these in order. Each has a flag, so a script or an agent answers without the
questions.

1. The kind of site. It shows each kind's label and description from `sets/kinds.json`. Flag:
   `--kind <id>`. Only kinds whose content set is in the package are offered.
2. The look. It lists only themes that declare the kind, and the first choice is the theme that
   lists the kind first. With one theme, the question is skipped and one line names the look.
   Flag: `--site-theme <id>`, which may name any theme.
3. The questions it asks today: site name, AI-crawler posture, and the owner's email.
4. Whether the site has a contact form. The default is the kind's. Flag: `--contact on|off`.
5. Whether the site has social links, then which networks, then each address. Flags: `--social
   <network>=<address>`, repeatable, and `--no-social`.

Search and topic pages aren't asked. They take the kind's default and are switched later in the
site's settings file.

## What a visitor sees

The mock-up is `research/site-basics-mockups/basics-1.html`, with screenshots at 1440 and 320
pixels beside it. It shows placement and wording. Colors and type come from each theme.

**The contact page.** The editor's text sits at the top, as on any page. Below it, the form asks
for a name, an email address, and a message, with one "Send message" button and a line linking to
the privacy page. When the site defines two or more subjects, a "What is it about?" picker shows
between the email and the message. After a message is sent, the form is replaced by "Your message
was sent. We answer at the address you gave." A field with a mistake keeps what the visitor typed
and says how to fix it.

**Search.** The menu gains a "Search" link to a search page. The page has one box and a button,
then a count of results and a list, each result with its title and a short passage with the
matched words marked. With nothing found it says "No results for" and the words, then "Check the
spelling or try a shorter word."

**Topic pages.** Each topic has a page listing its posts, newest first, paged like the archive. A
post's topics link to them.

**Social links.** The footer shows one icon for each named network, each at least 44 pixels square
to tap, with the network's name for screen readers. A link added as "other" shows as text.

## Calls made here

These are Claude's calls. Geoff can overrule any of them in the approval.

- **Words.** "Theme" keeps meaning the look. A "starter" is a kind's content set, the site
  template, and a theme together.
- **Where the switches live.** A site-owned file, `src/site/settings.json`, holds the three
  switches (`contact`, `search`, `topicPages`), the form's subjects, and the social links. A content
  set carries the file with its
  kind's defaults, and `cairn new` rewrites it. `site.config.yaml` rejects any key it doesn't know
  (`src/lib/nav/site-config.ts`, line 329), and the Go tool never merges YAML, so a JSON file the
  tool can rewrite whole is the smallest change.
- **Kind defaults.** `sets/kinds.json` gains each kind's defaults for the three switches. A check
  fails a set whose `settings.json` differs from its kind's defaults.
- **No engine surface.** The form is site code in the template. It calls two functions the engine
  already exports from `/cloudflare`, `verifyTurnstile` and `resolveRateLimit`, plus `createLogger`
  from `/log` and the site's `EMAIL` binding.
- **How a theme gets the links and the search flag.** The root layout's server load adds them to
  `page.data`, where a theme already reads the site name and the menus. The template supplies a
  social-links component with the ten icons. A theme's footer places it.
- **The contact route.** The public pages are prerendered, and a form can't post to a prerendered
  page. `/contact` is therefore its own route, rendered at request time. It shows the content
  entry whose id is `contact`, then the form. The switch, the variables, and the secret are read
  on each request, so the "missing setup" state needs no rebuild to clear. The form posts as a
  SvelteKit form action. Turnstile needs JavaScript, so with scripts off the page says "This form
  needs JavaScript."
- **The privacy page.** It is the entry whose id is `privacy`, and the form's line links to it.
  A check fails a set that has no such entry.
- **Search.** A build-time index that runs in the visitor's browser, built by Pagefind after the
  site build. It adds no service and no cost. The search page loads Pagefind's script only when a
  visitor opens that page.
- **Reaching search.** A "Search" link in the menu, added by the layout load when the switch is
  on. Geoff ruled for the link (ruling 1).
- **The form's mail.** One message goes to the recipient, with the visitor's address as reply-to
  and the site's sending address as the sender. Nothing is stored.
- **Recipients.** The default recipient is a `wrangler.jsonc` variable, `CONTACT_TO`, which
  `cairn new` writes as it writes `PUBLIC_ORIGIN`. It starts as the owner's sign-in address. The
  picker's choices are called subjects, to keep them apart from a blog's topics. Each is an `id`
  of lowercase letters, digits, and hyphens with a `label`, listed under `contact.subjects` in
  `settings.json`. A subject's address is a variable the developer adds, named `CONTACT_TO_` and
  the id in capitals with each hyphen as an underscore, so `membership` reads
  `CONTACT_TO_MEMBERSHIP`. No address ever reaches the browser, in the page, in its data, or in a
  script.
- **The bot check.** Cloudflare Turnstile in managed mode. Its site key is a `wrangler.jsonc`
  variable and its secret key is a Worker secret.
- **Guards.** The form has Turnstile, a hidden field that real visitors leave empty, and two
  rate limits. The numbers are in "How it fails".
- **A form with missing setup.** The page shows the editor's text and no form, and the site logs
  which part is missing.
- **What the privacy page says.** What the form collects, who receives it, and that the site
  keeps no copy.
- **Log events.** The form logs four events through `createLogger`: `contact.sent`,
  `contact.rejected`, `contact.send_failed`, and `contact.not_configured`. They are the site's
  events, so the form's docs page lists them. The engine's event table stays the engine's.
- **The basic check on a social address.** It must start with `https://`. Facebook, Instagram,
  YouTube, LinkedIn, Bluesky, TikTok, Strava, and GitHub each accept their one host, with or
  without `www.`. X accepts `x.com` and `twitter.com`. Mastodon and "other" accept any host,
  because Mastodon has no single one.
- **Where `cairn new` gets sets.** From the package: the template tarball packs each kind's set
  and each theme beside the catalog file it already carries, and the tool composes the site by
  file copy, as the demo build does. Reading the hosted catalog stays the catalog design's step 2.
- **Where the system is documented.** In the admin track, `docs/admin/`, which is the developer's.
  No published page covers themes, kinds, sets, or the catalog today. Pass 6 adds three pages:
  how a starter is put together, how to write a theme, and how the catalog publishes versions. It
  runs last so that it describes `cairn new` as pass 5 left it. The earlier passes still document
  what they change, as every pass does. The front-door pages gain links only.
- **One pass for `cairn new`.** All its questions and flags change together, because they rewrite
  the same form and the same answer list.
- **Waymark's kinds.** Waymark declares blog and organization at the end of this round. The check
  that a theme renders each kind it declares is what lets it gain the next.

## Scope

In scope: the site template (`examples/showcase`, and `templates/waymark` generated from it), the
blog and organization content sets, the Waymark and Pennant themes, the theme schema and check,
`sets/kinds.json`, `cairn new`, the docs under `docs/admin/`, and two edits to the catalog design.

Out of scope: `src/lib/**`. If a pass finds it needs an engine change, it parks, and the question
goes through `cairn-judging-scope` before anything is built.

The catalog design (`specs/2026-11-14-theme-catalog-design.md`) changes in two places when this
design is approved: a theme declares one to five kinds, and `cairn new` offers only the themes
that declare the chosen kind.

## How it fails

| What happens | What the site or the tool does |
| --- | --- |
| The form's switch is on and `CONTACT_TO`, the site key, or the secret key is missing | The contact page shows the editor's text and no form. The site logs `contact.not_configured` with the missing part's name. |
| A required field is empty, the email has no `@` or no dot after it, the name is over 100 characters, the email over 254, or the message over 5,000 | The form returns with what the visitor typed and one line under the field. Nothing is sent. |
| The hidden field has a value | The visitor sees the "sent" line. Nothing is sent, and the site logs `contact.rejected` with reason `trap`. |
| The bot check fails or its token is missing | The form returns with "The check didn't finish. Try again." The site logs `contact.rejected` with reason `check`. |
| More than 3 messages from one network address in 60 seconds, or more than 20 for the whole form | The form returns with "Too many messages just now. Try again in a minute." The site logs `contact.rejected` with reason `rate`. |
| The rate-limit binding is absent or errors | The message is sent. Turnstile still guards the form, and the site logs the gap once per request. |
| Cloudflare refuses the mail | The form returns with what the visitor typed and "Your message wasn't sent. Try again later." The site logs `contact.send_failed` with Cloudflare's reason. |
| A subject is chosen whose variable isn't set, or one that `settings.json` doesn't list | The message goes to `CONTACT_TO`. |
| The visitor's browser runs no scripts | The contact page shows the editor's text and "This form needs JavaScript." |
| The search index is missing, as in `npm run dev` | The search page says "Search isn't available in this preview." The menu link stays. |
| A social address fails the basic check in "Calls made here" | `cairn new` asks again, and with a flag it exits nonzero before anything is created. |
| More than 12 social links | `cairn new` refuses the thirteenth and says the limit. |
| `--kind` names a kind with no set in the package, or `--site-theme` a theme that isn't there | Exits nonzero before anything is created. |
| The tool's sign-in can't create the bot check | `cairn new` finishes the site with the form in its "missing setup" state and prints the two dashboard steps and the command that stores the keys. |
| The recipient's address isn't a verified destination on the account | `cairn new` says so and prints the step. Sending to an unverified address needs a paid Workers plan. |

A message that is sent logs `contact.sent` with the subject's id. The rate limit's key for one
visitor is the `CF-Connecting-IP` header, which Cloudflare sets and a visitor can't. The name
and the subject's label go into the mail's subject line with line breaks removed. No log record
carries the message, the visitor's name, or the visitor's address.

## Passes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `site-basics-1` search | The template has `src/site/settings.json` and a search page over a Pagefind index. Search is on in the template's starter content. | `examples/showcase/**`, `templates/waymark/**`, `sets/kinds.json`, `docs/admin/**` | `ordinary` | 90 | none | 2, 3, 4 |
| 2 `site-basics-2` form | The template has the contact form, its guards, its three log events, and the privacy page. | `examples/showcase/**`, `templates/waymark/**` with `wrangler.jsonc`, `sets/organization/**`, `docs/admin/**` | `auth-data` | 150 | 1 | 1, 3, 4, 5 |
| 3 `site-basics-3` links | Social links show in both themes' footers, topic pages follow their switch, and every page carries link-preview tags. | `examples/showcase/**`, `templates/waymark/**`, `themes/waymark/**`, `themes/pennant/**`, `sets/organization/**` | `live-account` | 90 | 2 | 1, 2, 4 |
| 4 `site-basics-4` kinds | The blog set exists at 1.0.0, made from the template's starter content. A theme declares up to five kinds and is checked against each. Waymark declares blog and organization. One docs page lists every switch. | `schema/cairn-theme-1.schema.json`, `scripts/theme/**`, `scripts/checks/**`, `themes/waymark/cairn-theme.json`, `sets/**`, `docs/admin/**`, `docs/internal/theme-catalog.md` | `runner`, `live-account` | 130 | 3 | 1, 2, 3, 5 |
| 5 `site-basics-5` new | `cairn new` asks the kind, the look, the form, and the links, and sets up the form. | `tool/**`, `scripts/build/pack-engine-template.mjs`, `templates/waymark/**`, `docs/admin/**`, `skills/**` | `auth-data` | 140 | 4 | 2, 4, 6 |
| 6 `site-basics-6` docs | The admin docs explain kinds, content sets, themes, and the catalog, and teach a developer to write a theme. | `docs/admin/**`, `docs/README.md`, `docs/why-cairn.md`, `skills/**`, `docs/internal/theme-catalog.md` | `ordinary` | 100 | 5 | 1, 2, 4, 5 |

Every pass also touches `BACKLOG.md` and `CHANGELOG.md`, and the conductor holds `docs/STATUS.md`.

## What each merge publishes

A change under `themes/<id>/` or `sets/<kind>/` must raise that theme's or set's version, and the
merge then publishes the new version to the catalog for good.

| Pass | Publishes |
| --- | --- |
| 1 | Nothing |
| 2 | The organization set, one minor version up |
| 3 | Waymark and Pennant, one minor version each, with both demos redeployed, and the organization set |
| 4 | The blog set at 1.0.0, Waymark one minor version up, and the organization set if the check changed it |
| 5 | Nothing. The tool ships with the next engine release |
| 6 | Nothing. cairn.pub shows the new pages at the next engine release |

Pass 1 publishes nothing and lands once its checks are green and its review is accepted. Passes 2
to 4 wait for Geoff's merge. Pass 5 waits too, because it is `auth-data`. Pass 6 lands the same
way as pass 1, unless its fact check leaves a claim only Geoff can settle.

No blog set exists yet: the template's starter content stands in for it, and the catalog design
says that content becomes the blog set. Pass 4 makes it one, which is backlog #481. Until then
the blog kind's defaults live in the showcase's `settings.json`. The pack script under
`scripts/release/` is a held path and no pass touches it.

## Acceptance

Every pass:

- CI is green on the head commit, and the whole-branch review is accepted with no open finding.
- Each page and each line of copy a person reads follows
  `~/.claude/docs/voice/written-for-people.md`
  for visitor copy and the repo's docs rules for `docs/admin/**`. `vale` reports nothing on the
  changed docs, and the PR lists every line of visitor copy the pass added, each matching this
  design's wording where the design gives one.

Pass 1, search:

- A test builds the showcase, runs the index step, and finds `pagefind/pagefind.js` inside the
  folder `wrangler.jsonc` names as `assets.directory`. It reads the index's page count and fails
  when the count differs from the number of public pages the build wrote.
- An end-to-end test opens `/search`, types a word that appears in exactly one seeded post, and
  finds one result whose link is that post. It types a word that appears nowhere and finds the
  "No results" line.
- With `search` set to `false` in `settings.json`, the built site has no "Search" menu link,
  `/search` returns 404, and the built assets folder holds no `pagefind` folder.
- A test visits every address in the built sitemap and fails if any page but `/search` requests a
  file under `/pagefind/`.
- Unit tests fail the loader on each of: an unknown key, a switch that isn't a boolean, a social
  link with no `https://` address, a social network name outside the list, a thirteenth social
  link, and a subject whose id has a capital, a space, or no label.
- `emit-template-dir.mjs --check` passes.

Pass 2, form:

- With Cloudflare's test keys, an end-to-end test sends a valid message and the test's mail
  binding receives one message whose `to` is `CONTACT_TO`, whose `from` is the site's sending
  address, whose `replyTo` is the visitor's address, and whose text holds the message. A second
  test sends a name holding a line break and asserts the mail's subject is one line.
- A test for each row of "How it fails" that names the form asserts the visitor's line, that the
  binding received nothing where the row says so, and the log event with its reason.
- With `CONTACT_TO` unset, the contact page's HTML holds no `<form>` and no `@`.
- With the form on and with it off, a test searches the contact page's HTML, its `__data.json`,
  and every file in the built client folder for `CONTACT_TO`'s value and a subject's address, and
  finds neither.
- With the switch off, `/contact` renders the editor's page with no form. With it on or off, a
  test visits every address in the sitemap and only `/contact` with the form showing requests
  anything from `challenges.cloudflare.com`.
- The rate-limit test sends four messages with one `CF-Connecting-IP` value and a different
  `X-Forwarded-For` each time, and the fourth is refused.
- A test reads every log record the form's tests emit and fails if one holds the visitor's name,
  address, or message. The form's server file contains no `console.` call, so nothing logs
  outside the checked path.
- The organization set holds a privacy page linked from its footer menu, and the contact form's
  privacy line links to it.
- `standards:web-auth-security-reviewer` returns no open finding on the form's server code.
- Four states match the mock-up's placement at the five widths, graded by a fresh
  `standards:visual-verifier`: the empty form with two subjects, the form with one field in
  error, the "sent" line, and "missing setup".

Pass 3, links:

- With three named networks and one "other" link in `settings.json`, each theme's footer holds
  four links in the file's order, three with an `svg` and an accessible name equal to the
  network's name, and one with visible text.
- With no links, each theme's footer holds no social list element.
- Each icon link measures at least 44 by 44 CSS pixels at 320 pixels wide.
- With topic pages on, each topic in the set's vocabulary has a page listing every post that
  carries the topic and no other, newest first, paged at the archive's page size. A test with
  one more post than a page holds proves the second page. A topic with no posts returns 404. With
  the switch off, every topic address returns 404 and no
  post links to one.
- A test fetches the home page, a post, a plain page, the archive, and the search page, and each
  holds `og:title`, `og:description`, `og:url`, and `og:type`. Each `og:url` equals the page's
  canonical link and starts with `PUBLIC_ORIGIN`. A post with a lead image also holds an
  `og:image` that is an absolute address under `PUBLIC_ORIGIN`.
- In the Waymark demo build and the Pennant demo build, no built file holds `showcase.test`
  (backlog #483).
- The blog set's topic vocabulary names no trail or weather subject (backlog #388).
- Both themes' footers pass a fresh `standards:visual-verifier` at the five widths in light and
  dark.

Pass 4, kinds:

- The schema accepts a theme with five kinds and rejects one with six, one with none, and one with
  a kind twice.
- The theme check builds a theme against the set of each kind it declares, and fails when a
  declared kind has no set or a built page has a console error or a broken internal link.
- `sets/blog/cairn-set.json` exists at version 1.0.0, and the set holds an about page, a contact
  page, and a privacy page.
- A test holds the defaults in `sets/kinds.json` to a fixture copied from this design's feature
  table, all fifteen switch values, and fails on any difference.
- The settings check fails when a set's `settings.json` differs from its kind's defaults in
  `sets/kinds.json`, or when a set has no entry whose id is `privacy`. A test proves each with a
  changed set.
- Waymark's manifest declares `blog` then `organization`, and its demo build uses the blog set,
  never the starter overlay (backlog #481).
- `docs/admin/` holds one page whose table matches `sets/kinds.json` switch for switch. A check
  fails when they differ.
- The catalog design says one to five kinds, and that `cairn new` offers only declaring themes.

Pass 5, new:

- `cairn new --kind organization` with no theme flag writes a site whose theme lists
  `organization` first among its kinds, and whose `settings.json` holds the organization defaults.
- `cairn new --kind blog --contact on` writes `contact: true`, and its `wrangler.jsonc` holds
  `CONTACT_TO`, the Turnstile site-key variable, and the rate-limit binding. `--kind organization
  --contact off` writes `contact: false`.
- `--social instagram=https://www.instagram.com/example --social other:Trail
  cam=https://example.org/cam`
  writes both links in order. Each refusal row of "How it fails" has a test that asserts a nonzero
  exit and that no directory was created. A test of the question form enters a bad address and
  asserts the same question shows again with its error, and one enters thirteen links and asserts
  the refusal.
- The look question lists only themes declaring the chosen kind. A test with a two-theme fixture
  proves a non-declaring theme is absent, and that `--site-theme` still accepts it.
- With the form on, a run against the test account leaves `CONTACT_TO` set to the owner's address
  and either a working bot check or the printed steps. A message sent through the deployed form
  then arrives. This item is checked by hand against carin-test.org. Its evidence is the log
  record `contact.sent` and the message read in the recipient's mailbox, with its reply-to
  header.
- With the form off, the written `wrangler.jsonc` holds no contact variable and no rate-limit
  binding.
- A test asserts the agent guide in `messages.go` names every flag in `newAnswerFlags`, holds
  one link, and is at most 25 lines (backlog #407). A test with two themes of different ground
  colors asserts the ground follows the chosen theme (backlog #501).
- `make -C tool check` passes.

Pass 6, docs:

- `docs/admin/` holds a page on starters, a page on writing a theme, and a page on the catalog,
  each listed in `docs/admin/README.md`. `npm run check:docs-gate` and `vale` pass.
- A fresh `docs-fact-checker` returns no finding on the three pages and on every other page the
  round changed.
- A fresh agent given only the theme page and a clean checkout writes a theme with one changed
  color that passes the theme check. Its transcript shows it read no file under `themes/`,
  `scripts/theme/`, or `docs/internal/`.
- A fresh agent given only the starters page answers five questions, written in the plan before
  the page is drafted: which kinds exist, what a set carries, which file holds the switches, how
  to change a site's look after `cairn new`, and which flag picks the kind. All five answers match
  the code.
- Every command and flag on the three pages is run in the PR's evidence, and its output matches
  what the page says.
- The starters page's kind table is checked against `sets/kinds.json` by the check pass 4 wrote.
- `docs/README.md` and `docs/why-cairn.md` each change by links and at most one sentence.
- A fresh `prose-voice-reviewer` returns no open finding on the three pages.

## Shared assumptions

| Assumption | Probe or source | Result |
| --- | --- | --- |
| The engine exports a Turnstile check and a rate-limit helper | Read of the `/cloudflare` entry | `verifyTurnstile(token, secret, opts?)` and `resolveRateLimit(binding, keys)` exist |
| A theme reads site data from `page.data` | Read of `themes/waymark/components/SiteHeader.svelte` and `SiteFooter.svelte` | Both read `page.data` and import no config |
| `site.config.yaml` can't hold a new key | `src/lib/nav/site-config.ts` lines 281 and 329 | Any unknown top-level key throws |
| The template already has a mail binding | `templates/waymark/wrangler.jsonc` line 24 | `"send_email": [{ "name": "EMAIL" }]` |
| Mail to a verified address is free | Cloudflare's Email Service pricing page | "Sending to verified destination addresses in your account is free on Workers Free and Paid plans" |
| The rate limit counts per location and allows 10 or 60 second windows | Cloudflare's rate-limit binding page | Stated there. It needs Wrangler 4.36.0 or later |
| A Turnstile widget can be created through the API | Cloudflare's Turnstile widget API page | `POST /accounts/{id}/challenges/widgets`, with the permission "Turnstile Sites Write" |
| The tool's sign-in holds that permission | `tool/internal/providers/cloudflare_oauth.go` lines 30 to 32 | It doesn't. The scope list has no Turnstile entry |
| The public pages are prerendered | `examples/showcase/src/routes/(site)/[...path]/+page.server.ts` line 6 | They are, so the form needs a route rendered at request time |
| A blog set exists | `git ls-tree origin/main sets/` | It doesn't. Only `kinds.json` is there |
| Pagefind indexes what `adapter-cloudflare` builds | Pagefind's docs: it reads a folder of built HTML | Unproven for `.svelte-kit/cloudflare` |
| No published page covers the catalog | `ls docs/admin` and a search for "theme" and "catalog" | Fifteen admin pages, none on themes, kinds, sets, or the catalog. `docs/internal/theme-catalog.md` is the only write-up |
| `cairn new` reads no kind today | `tool/cmd/cairn/new.go` and `tool/internal/setup/scaffold/catalog.go` | It reads themes from the packed catalog only |

Two mechanisms are unproven. Pass 1 proves Pagefind first, before any other task: if the built
folder holds no HTML that Pagefind can read, standing answer 13 applies. Pass 5's planner probes
whether the tool's sign-in can ask for a Turnstile scope: if it can't, standing answer 16 applies.

## Order

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 search | `plans/2026-11-15-site-basics-1-planner-prompt.txt` | none | 90 | no |
| 2 form | `plans/2026-11-15-site-basics-2-planner-prompt.txt` | 1 | 150 | yes |
| 3 links | `plans/2026-11-15-site-basics-3-planner-prompt.txt` | 2 | 90 | yes |
| 4 kinds | `plans/2026-11-15-site-basics-4-planner-prompt.txt` | 3 | 130 | yes |
| 5 new | `plans/2026-11-15-site-basics-5-planner-prompt.txt` | 4 | 140 | yes |
| 6 docs | `plans/2026-11-15-site-basics-6-planner-prompt.txt` | 5 | 100 | no |

The passes run one at a time, because every pair shares a template file. Each pass's worktree is
cut from the pass before it once that pass's whole-branch review is accepted. The merge order is
1 to 6. Pass 1 lands without him. Geoff sees two `merge` documents: passes 2 and 3 together when
pass 3's review is accepted,
and passes 4 and 5 together at the end. Pass 6 lands after the second document is
answered. The chain is 700 path minutes, and the round stops new launches past 1,400. The usage
ceiling is 85 percent of the weekly allowance.

## Start line

The round launches when each of these reads true. None is true today.

1. `docs/STATUS.md` on `origin/main` holds a line that reports round `events` closed.
2. `claude agents --json` holds no row named `cairn-cms-events-*`, `cairn-cms-pennant-*`,
   `conductor-events`, or `conductor-pennant`.
3. This design's document in the Approval Queue is answered "approve".
4. `sets/organization/cairn-set.json` exists on `origin/main`.

Survey's round starts after this one's report. If Geoff starts Survey first, this round waits for
it the same way.

Launch checks, read on 2026-11-15:

| Check | Command | Output |
| --- | --- | --- |
| Main is current | `git rev-list --count HEAD..origin/main` | `0`, at `6499871a8` |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 35% used` |
| Live sessions | `claude agents --json` | `conductor-pennant` idle, `cairn-cms-pennant-3-plan` running, no `site-basics` row |
| Open pull requests | `gh pr list` | #251 `pennant-1`, #253 `pennant-2` |
| Start line 1 | read of `docs/STATUS.md` | Events passes 2 and 3 wait on Pennant. Not met |
| Start line 4 | `git ls-tree origin/main sets/` | Only `kinds.json`. Not met |

The conductor reads all of them again on the day it launches.

## Steps for Geoff

- [you: approve this design in the queue]
- [you: answer the two `merge` documents]
- [you: confirm the mail Cloudflare sends when `cairn new` adds a recipient address, during pass
  5's hand check on carin-test.org]

Nothing else needs him. The form runs on each site's Cloudflare account, because that is where the
site, its mail binding, and its bot check already are. Nothing in this round runs on orpheus or
ward.

## Standing answers

The twelve in `round-run.md` hold. This design adds:

13. Pagefind can't index the adapter's output: pass 1 has the build write the prerendered HTML to
    a folder Pagefind can read and copies the index into the assets folder. If no page is
    prerendered, the pass parks.
14. A feature needs a file under `src/lib/**`: the pass parks.
15. A theme's contrast fails on a new control: tune the value within its hue and list old and new
    in the PR.
16. The tool's sign-in can't create a Turnstile widget: `cairn new` prints the dashboard steps and
    the command that stores the keys, and the form stays in its "missing setup" state. Never ask
    for a wider scope without a ruling, and never try another credential.
17. A set or theme version is already published at the number a pass picked: take the next one.
18. Pennant's or the organization set's files differ from what this design read: the planner
    plans against the files as merged, and parks only if an acceptance item can no longer be met.
19. The hand check on carin-test.org can't send mail because the address isn't verified: the pass
    records the step for Geoff in its `merge` document and finishes everything else.
20. A pass comes out over twice its path minutes at planning: it parks, as `round.md` says.

## Rulings

Geoff approved this design in queue document `20261115-212709-ef6b42`, 2026-11-15. Each `Ruled:`
line quotes his answer there.

1. How a visitor reaches search: a "Search" link in the menu that opens a search page, or a search
   box in the header of every page.
   Ruled: "A "Search" link in the menu". Pass 3 keeps its 90 path minutes.
2. Whether every content set carries a privacy page, or only the sets where the form starts on.
   Ruled: "In every set".
3. Whether to build to the mock-up or revise it first.
   Ruled: "Build to the mock-up".

## Backlog verdicts

A scoped sweep read the open items at `6499871a8`.

| Item | Verdict | Where |
| --- | --- | --- |
| #483 demo canonical and feed links name `showcase.test` | fold | pass 3 |
| #388 neutral starter tag vocabulary | fold | pass 3 |
| #481 Waymark's demo falls back to the starter overlay, with no blog set | fold | pass 4 |
| #407 `newAgentGuide` shrinks to the flag list and a link | fold | pass 5 |
| #501 `cairn new` reads ground from `rf.theme` alone | fold | pass 5 |
| #508, #168 | reword | cut to what is left |
| #488, #486, #485, #484, #482, #480, #412, #413, #415, #416, #417, #419, #410, #378, #302, #394, #472, #504, #524, #437, #469, #383, #304 | keep | stamped by pass 1 |

The backlog holds 153 open items, 45 of them unstamped in the last 90 days, so a full sweep is
due. It runs separately and never rides this design.

## Estimate

Six passes, 700 path minutes in one chain: 90, 150, 90, 130, 140, and 100.

## Practice and sources

- The survey: `research/site-features-survey-2026-11-15.md`, with its limits stated at the top.
- Cloudflare Turnstile, widget management through the API and server-side validation:
  developers.cloudflare.com/turnstile/.
- Cloudflare Workers rate-limit binding:
  developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/.
- Cloudflare Email Service, sending from a Worker and its pricing.
- Pagefind: pagefind.app/docs/. Starlight and AstroPaper ship it as their built-in search.
- The Google Developer Documentation Style Guide and the repo's `cairn-writing-docs` procedure,
  for pass 6.
- WCAG 2.2, target size and error identification, for the form and the icon links.
- The Open Graph protocol, ogp.me, for the four required tags.

## Out of scope and later

- The portfolio, documentation, and product-page sets, each with its column of the feature table.
- Waymark's remaining three kinds, one as each set lands.
- `cairn new` reading the hosted catalog, with the lock file.
- A stored copy of contact messages, if a site asks for one. It would be a scope question first.
- Search across more than one language.
