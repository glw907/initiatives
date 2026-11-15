# Round two: the starter features, built as layers

Initiative: theme-garden. Rounds: `site-events`, then `site-basics`. Status: draft, waiting for
Geoff's approval. Read against cairn-cms at `6499871a8`, and against the foundation design
(`specs/2026-11-15-foundation-design.md`), which this design builds on.

## Brief

Round two builds what a visitor gets from a cairn starter site: events with a calendar feed, a
contact form, search, topic pages, and social links. Each is a feature layer on the structure
the foundation round builds, laid into a site only when the site chose it. `cairn new` then asks
the kind first and the look second, and the last pass writes the published docs for the whole
system. The work is seven passes and about 1,020 path minutes, which is more than one round
holds. This design runs it as two rounds under one approval: `site-events` in two passes, then
`site-basics` in five. Nothing launches until the foundation round has closed.

## Why

Geoff approved two designs that this one replaces in part. The events design
(`specs/2026-11-14-events-design.md`) has one pass merged and two held. The site-basics design
(`specs/2026-11-15-site-basics-design.md`) is on hold. Both were written before the foundation
round, and both placed feature code where the foundation design says it must not go: the events
views in a content set, and the form, search, and links in every site behind run-time switches.
Geoff's words on that were "a little ugly", and he asked for the system "built as if it were
designed from scratch this way". This design keeps what each of those designs decided for
visitors, editors, and owners, and moves the code onto layers.

## Decided by Geoff

Each line is Geoff's, from 2026-11-15, in chat or in a queue document.

- "yes, design all of round two now".
- On the events round's held passes: "yes, retire them in round two's design".
- "yes, layers with a cairn add command".
- On which kinds start with events: "yes, organization only, others can add them".
- "Starter kits and themes should support events where appropriate."
- A new site chooses "kind first, then a look with a default", and `cairn new` offers "only
  declaring themes, flag as the override".
- "Lift the cap to five. Waymark should work with all five." Waymark "grows one kind at a time
  as each set lands".
- The contact form "should probably be the default over a bare email address because the latter
  is a spam magnet". It is "on for organization and portfolio, off for the rest".
- Search is on for documentation, blog, and organization. Topic pages are on for the blog kind.
- For social links, `cairn new` asks "the links-or-no-links question" and then "which social
  links" with their addresses. cairn "can do a basic check".
- The round "should include adding documentation of the new system: the themes, types, catalog,
  etc."
- From the site-basics approval, queue document `20261115-212709-ef6b42`: "A "Search" link in
  the menu", "In every set" for the privacy page, and "Build to the mock-up".
- From the events approval, queue document `20261115-055827-bbcf02`: "Build to the mock-up",
  "Two, as a recorded ruling" for the repeat patterns, "Reverse it in this narrow form" for the
  calendar helper, "Show it struck through until the day passes", and "Events first, then
  Survey".
- From the foundation approval, queue document `20261115-223648-1d48b9`: "Split it" for the
  docs, which puts the teaching pages in this design's last pass.

## The feature list for each kind

Each kind's column becomes its `defaultFeatures` in `definitions/kinds.json`. The ids are
`blog`, `organization`, `portfolio`, `docs`, and `landing`.

| Feature | Blog | Organization | Portfolio | Documentation | Product page |
| --- | --- | --- | --- | --- | --- |
| Events | add later | on | add later | add later | add later |
| Contact form | asked, off | asked, on | asked, on | asked, off | asked, off |
| Search | on | on | add later | on | add later |
| Topic pages | on | add later | add later | add later | add later |
| Social links | asked | asked | asked | asked | asked |
| About page | yes | yes | yes | no | no |
| Privacy page | yes | yes | yes | yes | yes |

"On" means the kind's default lays the feature in. "Asked" means `cairn new` asks, with the
default shown. "Add later" means the developer runs `cairn add <feature>`. The first four rows
are feature layers. Social links are a menu, and the two pages are content in a set.

This design builds the blog and organization columns. The other three are recorded in
`definitions/kinds.json` now and proven when each kind's content set is written.

## Goals

1. Each feature exists once, as a layer under `features/<id>/`, and a site that didn't choose it
   holds none of its files, routes, scripts, or dependencies.
2. An editor adds an event as a markdown entry, and a visitor finds it on `/events`, on the event's
   page, and in a calendar they subscribe to.
3. A site with the form on receives a visitor's message by email after `cairn new` finishes,
   with no hand setup where the tool's sign-in allows it.
4. `cairn new` asks the kind, then the look, then the form and the links, and writes a site that
   matches the answers.
5. A developer who has never seen the catalog can learn from the published docs what a kind, a
   content set, a theme, and a feature are, pick a starter, add a feature, and write a theme that
   passes the theme check.

## Non-goals

- The portfolio, documentation, and product-page content sets.
- Event sign-up, registration, fees, and imports. The events design excludes them, and a club
  keeps them in the database it already runs.
- A newsletter box, comments, a donate button, a member sign-in, a phone or address block, a
  people page, a gallery, or an FAQ.
- Storing contact messages, an admin screen for them, file uploads, or an automatic reply to the
  visitor.
- `cairn remove`, an editor switching a feature on, and `cairn new` reading the hosted catalog.
- An engine release. A pass never publishes the package.

## Anti-goals

- An event shown on the wrong day or at the wrong hour in a subscriber's calendar.
- A cancelled night that still looks live on the site or in the feed.
- A page that prints an email address because the form isn't ready.
- A form that accepts a message and drops it.
- A feature a site didn't choose that still loads script or shows a control there.
- A feature switched off at run time in a site that still carries its code.
- A new engine export, or a file under `src/lib/**`, for any of this.
- A token or sign-in widened so that setup can finish.

## What an owner is asked

`cairn new` asks these in order. Each has a flag, so a script or an agent answers without the
questions.

1. The kind of site, with each kind's label and description from `definitions/kinds.json`. Flag:
   `--kind <id>`. Only kinds whose content set is in the package are offered. A run that answers
   by flags and gives no `--kind` gets `blog`, so a script written before this pass still works.
2. The look. It lists only themes that declare the kind, and the first choice is the theme that
   lists the kind first. With one theme, the question is skipped and one line names the look.
   Flag: `--site-theme <id>`, which may name any theme.
3. The questions it asks today: site name, AI-crawler posture, and the owner's email.
4. Whether the site has a contact form. The default is the kind's. Flag: `--contact on|off`.
5. Whether the site has social links, then which networks, then each address. Flags: `--social
   <network>=<address>`, repeatable, and `--no-social`. A network is one of `facebook`,
   `instagram`, `youtube`, `linkedin`, `bluesky`, `tiktok`, `strava`, `github`, or `x`, and its
   link's label is the network's name. Any other link is `--social other:<label>=<address>`.

Search, topic pages, and events aren't asked. They follow the kind's defaults, and a developer
adds any of them later with `cairn add`.

## What an editor writes

An event is a markdown file under `src/content/events/`, edited in the admin like a post. Its
fields, its repeat patterns, and its change rows are the events design's, unchanged: `title`,
`date`, `endDate`, `time`, `endTime`, `place`, `summary`, `repeats`, and `changes`. A repeat is
weekly on named weekdays or monthly on one weekday of a named week, always with an end date at
most 366 days out. A change row cancels one date or moves it. The editor's page for all of this
is `docs/editors/events.md`.

Social links are a menu named `social`, edited on the admin's menu screen like any other menu.
The privacy page is an ordinary page in every set, with the id `privacy`. The contact page is a
page with the id `contact` that the contact layer lays in, so a site without the form has no
contact page.

## What a visitor sees

Two mock-ups show placement and wording. Colors and type come from each theme.
`research/pennant-mockups/events-1.html` is the events look in Pennant.
`research/site-basics-mockups/basics-1.html` is the form, search, topics, and links, with
screenshots at the five widths beside it.

**Events.** `/events` lists coming events grouped by month, with "Subscribe in Google Calendar"
and "Subscribe in another calendar" links and an empty state. Each event has a page. A cancelled
date shows struck through until the day passes. `/events.ics` is the calendar feed. In Pennant,
the home page gains "Coming up", the next three events.

**The contact page.** The editor's text sits at the top. Below it, the form asks for a name, an
email address, and a message, with one "Send message" button and a line linking to the privacy
page. With two or more subjects defined, a "What is it about?" picker shows between the email
and the message. After a message is sent, the form is replaced by "Your message was sent. We
answer at the address you gave." A field with a mistake keeps what the visitor typed and says
how to fix it.

**Search.** The menu holds a "Search" link to a search page. The page has one box and a button,
then a count of results and a list, each with its title and a short passage with the matched
words marked. With nothing found it says "No results for" and the words, then "Check the
spelling or try a shorter word."

**Topic pages.** Each topic that a published post carries has a page at `/topics/<topic>`,
listing its posts newest first and paged like the archive. A post's topics link to them.

**Social links.** The footer shows one icon for each named network, each at least 44 pixels
square, with the network's name for screen readers. A link added as "other" shows as text.

## Calls made here

These are Claude's calls. Geoff can overrule any of them in the approval.

- **Two rounds.** `pass-core` holds a round to six passes and about 600 path minutes in its
  longest chain. This work is seven passes and about 1,020. It runs as two rounds, each with a
  conductor, a report, and a close packet. Ruling 1 asks Geoff for the order.
- **Four feature layers.** `events`, `contact`, `search`, and `topics`, each listed in
  `definitions/features.json` with the kinds it suits, and each shaped as the foundation design
  says: routes, a module at `src/features/<id>/contribution.ts`, and `package.json` additions.
- **Each feature ships a plain view.** Every feature view is a plain component with class hooks,
  so a theme that doesn't style it still shows it. A theme lists the features it styles in its
  manifest. Waymark styles `contact`, `search`, and `topics` after this design. Pennant styles
  those three and `events`.
- **What a feature tells the site.** The foundation design gives a feature's module three keys:
  `concepts`, `navLayout`, and `accessMap`. This design adds three, typed in the base layer's
  site code and gathered by the generated `src/site/features.ts`. `paths` lists the addresses
  the feature serves itself, and the base's catch-all route leaves them out of the pages it
  prerenders and out of the markdown twins. `homeSections` lists components a theme's home page
  shows after the theme's content. `tagHref` turns a topic into its address. A theme reads all
  three from the generated file and never names a feature. `site-events-1` adds
  `homeSections`, `site-basics-2` adds `paths`, and `site-basics-3` adds `tagHref`. If the
  module's type turns out to live under `src/lib/**`, standing answer 17 applies.
- **A theme's CSS for a feature ships with the theme.** Pennant's rules for the events class
  hooks are part of Pennant, whether or not a site has events. A theme holds no markup, route,
  or script for a feature.
- **Files that are merged, never written.** A layer contributes to `package.json` and
  `wrangler.jsonc` by key. The foundation design's rule that `cairn add` refuses when a file the
  layer writes already exists doesn't cover those two. `cairn add` refuses when a key the layer
  contributes already holds a different value, and writes nothing.
- **What the checks and demos compose.** The theme check and each demo compose a kind's set with
  that kind's default features, the form included where its default is on. A set's menu link to
  a default feature therefore always has its page.
- **Events is one layer.** The events design put the event views and their code in the
  organization set, named by a `code` list in `cairn-set.json` and reached through
  `src/site/set.ts`. Those three calls are dropped. The concept, the routes, the recurrence
  code, the feed route, and the plain views are `features/events/`. The sample events stay in
  the organization set as content. Pennant's look for events lives in Pennant. "Coming up" is
  the layer's plain component, offered through `homeSections`, which each theme's home page
  places and Pennant styles to the mock-up.
- **What carries from the events design.** Everything else in it: the fields and their rules, one
  feed event for each occurrence, the `uid` form, cancelled dates kept with `STATUS:CANCELLED`
  and a "Cancelled:" summary, the IANA time zone constant that throws at build when it is wrong,
  the list function that takes `now`, the script that hides a passed date, the class hooks
  `cairn-events`, `cairn-event`, and `cairn-event-date`, the sample events, the admin steps for
  a daily rebuild and the zone, and its failure table, less the rows that rest on a set's `code`
  list or on `src/site/set.ts`. Where that design names a set-owned file,
  the planner reads the same file under `features/events/`.
- **An events link in the menu.** The events layer adds no menu link. The organization set's
  primary menu holds one, and a developer who runs `cairn add events` on another kind is told
  the address to link.
- **The search link.** Geoff ruled for a "Search" link in the menu. It is an entry in each set's
  primary menu where the kind's default has search on. `cairn add search` prints the address and
  the developer adds the link on the menu screen. Nothing injects a link at run time.
- **Social links.** A menu named `social`, one level deep, which each theme's manifest lists in
  `menus` and each theme's footer shows. The network is read from each address's host by a table
  in the base layer. The rules are the site-basics design's: `https://` is required. Facebook,
  Instagram, YouTube, LinkedIn, Bluesky, TikTok, Strava, and GitHub each accept their one host,
  with or without `www.`. X accepts `x.com` and `twitter.com`. Any other host shows as text with
  the link's label, which covers Mastodon and "other". The menu holds 12 links at most.
- **The contact route.** `/contact` is rendered at request time, because a form can't post to a
  prerendered page. The layer names `/contact` in `paths`, so the catch-all route doesn't also
  build it. It shows the entry whose id is `contact`, then the form, which posts as a
  SvelteKit form action. The form calls `verifyTurnstile` and `resolveRateLimit` from
  `/cloudflare`, `createLogger` from `/log`, and the site's `EMAIL` binding. With scripts off the
  page says "This form needs JavaScript."
- **The contact page and its link.** The layer lays in the page whose id is `contact`, with one
  plain paragraph the editor rewrites. No set carries a contact page, and the organization set's
  is removed. `cairn new` adds a "Contact" link to the end of the primary menu when the form is
  on, the way it writes the `social` menu. `cairn add contact` prints the address to link.
- **The form's mail.** One message goes to the recipient, with the visitor's address as reply-to
  and the site's sending address as the sender. Nothing is stored.
- **Recipients.** The default recipient is a `wrangler.jsonc` variable, `CONTACT_TO`, which
  starts as the owner's sign-in address. A subject's address is a variable named `CONTACT_TO_`
  and the subject's id in capitals, with each hyphen written as `_`. No address ever reaches
  the browser, in the page, in its data, or in a script.
- **Where subjects live.** The contact layer lays in `src/features/contact/subjects.json`, an
  empty list the developer edits. Each subject is an `id` of lowercase letters, digits, and
  hyphens with a `label`. The site-basics design kept them in `src/site/settings.json`, which
  the foundation design dropped.
- **The bot check and the guards.** Cloudflare Turnstile in managed mode, with its site key as a
  `wrangler.jsonc` variable and its secret key as a Worker secret. The form also has a hidden
  field that real visitors leave empty, and two rate limits. One binding carries one limit, so
  the layer contributes two: `CONTACT_RATE_VISITOR`, 3 in 60 seconds, keyed on the visitor's
  network address, and `CONTACT_RATE_FORM`, 20 in 60 seconds, on one fixed key.
- **How the contact layer's deploy settings arrive.** The layer contributes its `wrangler.jsonc`
  variables and its two rate-limit bindings through the composer's merge by key. `cairn new` and
  `cairn add contact` write the values. Neither deploys.
- **Log events.** The form logs `contact.sent`, `contact.rejected`, `contact.send_failed`, and
  `contact.not_configured` through `createLogger`. They are the site's events, so the form's
  docs page lists them. No record carries the message, the visitor's name, or the visitor's
  address.
- **Search.** A build-time index that runs in the visitor's browser, built by Pagefind after the
  site build. The search page loads Pagefind's script only when a visitor opens that page.
- **Topic pages.** Routes at `/topics/<topic>` over the topics that published posts carry. A
  draft doesn't count, and any other topic address returns 404. Each theme's post view links a
  topic through `tagHref` and shows it as plain text when no feature gives one.
- **Link-preview tags.** `og:title`, `og:description`, `og:url`, and `og:type` on every public
  page, and `og:image` where a post has a lead image. They belong to the base layer, since every
  kind wants them. Today only the article view writes them.
- **The blog set.** `sets/blog/` at 1.0.0, made from the starter content the foundation round
  keeps as a layer, with an about page and a privacy page. That starter content layer is then
  removed, and `templates/waymark` is the base, the blog kind's defaults, Waymark, and
  `sets/blog/`. Waymark then declares `blog` and `organization`.
- **One pass for `cairn new`.** All its questions and flags change together, because they rewrite
  the same form and the same answer list.
- **The docs.** Three pages in `docs/admin/`: how a starter is put together, how to write a
  theme, and how the catalog publishes versions. Each feature's pass writes that feature's page.
  The front-door pages gain links only.

## Scope

In scope: `features/**`, `definitions/**`, `starter/**` where a base file must change, `sets/**`,
`themes/**`, `examples/showcase/**` and `templates/waymark/**` as composer output, `tool/**`,
`docs/admin/**`, `docs/editors/**`, `docs/README.md`, `docs/why-cairn.md`, `skills/**`, and
`docs/internal/theme-catalog.md`.

Out of scope: `src/lib/**`. A pass that needs an engine change parks, and the question goes
through `cairn-judging-scope`.

When this design is approved:

- The site-basics design of 2026-11-15 is replaced. Its feature table, its mock-up, and Geoff's
  three rulings carry over as written here.
- The events round's passes `events-2` and `events-3` are retired, and their planner prompts are
  never launched. The events design stays as the record for everything this design says carries.
- The catalog design (`specs/2026-11-14-theme-catalog-design.md`) changes in two places: a theme
  declares one to five kinds, and `cairn new` offers only the themes that declare the chosen
  kind.

## How it fails

The events design's failure table holds for events as written, less the rows that rest on a
set's `code` list or on `src/site/set.ts`, which this design drops. These rows are the rest.

| What happens | What the site or the tool does |
| --- | --- |
| The form is laid in and `CONTACT_TO`, the site key, or the secret key is missing | The contact page shows the editor's text and no form. The site logs `contact.not_configured` with the missing part's name. |
| A required field is empty, the email has no `@` or no dot after it, the name is over 100 characters, the email over 254, or the message over 5,000 | The form returns with what the visitor typed and one line under the field. Nothing is sent. |
| The hidden field has a value | The visitor sees the "sent" line. Nothing is sent, and the site logs `contact.rejected` with reason `trap`. |
| The bot check fails or its token is missing | The form returns with "The check didn't finish. Try again." The site logs `contact.rejected` with reason `check`. |
| More than 3 messages from one network address in 60 seconds, or more than 20 for the whole form in 60 seconds | The form returns with "Too many messages just now. Try again in a minute." The site logs `contact.rejected` with reason `rate`. |
| Either rate-limit binding is absent or errors | The message is sent. Turnstile still guards the form, and the `contact.sent` record carries `rateLimit: "unavailable"`. |
| Cloudflare refuses the mail | The form returns with what the visitor typed and "Your message wasn't sent. Try again later." The site logs `contact.send_failed` with Cloudflare's reason. |
| A subject is chosen whose variable isn't set, or one that `subjects.json` doesn't list | The message goes to `CONTACT_TO`. |
| `subjects.json` holds an id with a capital, a space, or no label | The site's build fails with one line naming the entry. |
| The visitor's browser runs no scripts | The contact page shows the editor's text and "This form needs JavaScript." |
| The search index is missing, as in `npm run dev` | The search page says "Search isn't available in this preview." |
| The `social` menu holds an address that doesn't start with `https://`, or a thirteenth link | The site's build fails with one line naming the link or the limit. `cairn new` asks again, and with a flag it exits nonzero before anything is created. |
| A site has no events | The build succeeds. `/events` shows its empty state, and the feed holds no event. |
| A theme doesn't style a feature the site chose | The composer prints one warning line, and the feature shows its plain view. |
| `--kind` names a kind with no set in the package, or `--site-theme` a theme that isn't there | Exits nonzero before anything is created. |
| The tool's sign-in can't create the bot check | `cairn new` finishes the site with the form in its "missing setup" state and prints the two dashboard steps and the command that stores the keys. |
| The recipient's address isn't a verified destination on the account | `cairn new` says so and prints the step. Sending to an unverified address needs a paid Workers plan. |

A message that is sent logs `contact.sent` with the subject's id. The rate limit's key for one
visitor is the `CF-Connecting-IP` header, which Cloudflare sets and a visitor can't. The name
and the subject's label go into the mail's subject line with line breaks removed.

## Passes

Round `site-events`:

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `site-events-1` layer | Events are a feature layer: the concept, `/events`, event pages, and `/events.ics`, each with a plain view. The organization kind's default lays it in. | `features/events/**`, `definitions/**`, `starter/**` (the module's type and `features.ts`), `sets/organization/**`, `examples/showcase/**`, `templates/waymark/**`, `docs/editors/**`, `docs/admin/**`, `skills/**` | `ordinary` | 240 | none | 2 |
| 2 `site-events-2` look | Pennant styles events to the mock-up, and its home page shows "Coming up". | `themes/pennant/**`, `themes/waymark/**` (its home page shows `homeSections`), `sets/organization/**`, `features/events/**` (class hooks only), `docs/internal/theme-catalog.md` | `live-account` | 150 | 1 | 1 |

Round `site-basics`:

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `site-basics-1` search | Search is a feature layer over a Pagefind index, on for the blog, organization, and documentation kinds. | `features/search/**`, `definitions/**`, `sets/organization/**`, `starter/**` (the starter content's menu), `examples/showcase/**`, `templates/waymark/**`, `docs/admin/**` | `ordinary` | 90 | none | 2, 3, 4 |
| 2 `site-basics-2` form | The contact form is a feature layer, with its guards, its four log events, and the privacy page. | `features/contact/**` with its `wrangler.jsonc` contribution, `definitions/**`, `starter/**` (the catch-all route and `paths`), `sets/organization/**`, `examples/showcase/**`, `templates/waymark/**`, `docs/admin/**` | `auth-data` | 150 | 1 | 1, 3, 4 |
| 3 `site-basics-3` links | Topic pages are a layer. Social links show in both themes' footers, every page carries link-preview tags, and the blog set exists at 1.0.0. | `features/topics/**`, `definitions/**`, `starter/**`, `sets/**`, `themes/waymark/**`, `themes/pennant/**`, `examples/showcase/**`, `templates/waymark/**`, `docs/admin/**`, `docs/internal/theme-catalog.md` | `live-account` | 150 | 2 | 1, 2, 4, 5 |
| 4 `site-basics-4` new | `cairn new` asks the kind, the look, the form, and the links, and sets up the form. | `tool/**`, `docs/admin/**`, `skills/**` | `auth-data` | 140 | 3 | 2, 3, 5 |
| 5 `site-basics-5` docs | The admin docs explain kinds, content sets, themes, features, and the catalog, and teach a developer to write a theme. | `docs/admin/**`, `docs/README.md`, `docs/why-cairn.md`, `skills/**`, `docs/internal/theme-catalog.md` | `ordinary` | 100 | 4 | 3, 4 |

Every pass also touches `BACKLOG.md` and `CHANGELOG.md`, and the conductor holds `docs/STATUS.md`.
The planner takes each pass's class from the repo's path map at planning. A pass that turns out
to change `wrangler.jsonc` or `hooks.server.ts` is `auth-data` and waits for Geoff's merge.

## What each merge publishes

A change under `themes/<id>/` or `sets/<kind>/` must raise that theme's or set's version, and the
merge then publishes the new version to the catalog for good.

| Pass | Publishes |
| --- | --- |
| `site-events-1` | The organization set, one minor version up, for its events menu link |
| `site-events-2` | Pennant and Waymark, one minor version up each, with both demos redeployed, and the organization set for its sample events |
| `site-basics-1` | The organization set, one minor version up, for its search link |
| `site-basics-2` | The organization set, one minor version up, for its privacy page and the contact page it loses |
| `site-basics-3` | The blog set at 1.0.0, and Waymark and Pennant one minor version each, with both demos redeployed |
| `site-basics-4` | Nothing. The tool ships with the next engine release |
| `site-basics-5` | Nothing. cairn.pub shows the new pages at the next engine release |

Every pass that publishes waits for Geoff's merge, and so do the two `auth-data` passes. That
leaves `site-basics-5` as the one pass that can land without him, unless its fact check leaves a
claim only he can settle.

## Acceptance

Every pass:

- CI is green on the head commit, and the whole-branch review is accepted with no open finding.
- Each page and each line of copy a person reads follows
  `~/.claude/docs/voice/written-for-people.md` for visitor copy and the repo's docs rules for
  `docs/**`. `vale` reports nothing on the changed docs, and the PR lists every line of visitor
  copy the pass added, each matching this design's wording where the design gives one.
- A test composes the showcase's base and theme with the pass's feature and without it. Without
  it, the tree is byte-for-byte the tree composed from a layers folder that never held the
  feature. A second test builds the site without the feature and with no set, and fails if any
  page's HTML holds the feature's address or one of its class hooks.

Each "Today" below was read against `origin/main` at `6499871a8` on 2026-11-15. On that commit
`features/`, `definitions/`, and `sets/blog/` don't exist, so every item that names one is not
runnable today.

`site-events-1`, layer:

- `definitions/features.json` lists `events`, and `definitions/kinds.json` names it in the
  organization kind's `defaultFeatures` and in no other kind's.
- A test expands a weekly repeat on Tuesday and Thursday from 2027-01-05 to 2027-03-25 and gets
  24 dates, the first 2027-01-05 and the last 2027-03-25. A second expands "last Friday" from January to June 2027 and gets 2027-01-29, 02-26,
  03-26, 04-30, 05-28, and 06-25.
- An event at 18:30 in `America/Anchorage` on 2027-01-14 reads `20270115T033000Z` in the feed,
  and one on 2027-07-14 reads `20270715T023000Z`. Each is the next day in UTC. A weekly series across 2027-03-14 keeps 18:30 local on both sides. Both
  tests pass under `TZ=UTC` and under `TZ=Asia/Tokyo`.
- The feed holds one event for each occurrence, each with a `uid` made of the entry id, the
  original date, and the host. A cancelled date stays in the feed with `STATUS:CANCELLED` and a
  summary that starts "Cancelled:". A moved date keeps its `uid`, appears once, at its new date
  with its new time and place, and is absent at its old date.
- `/events.ics` is served through `buildICalendarResponse`. Today: `src/lib/delivery/responses.ts`
  line 49 exports it, and no route calls it.
- With the time zone constant set to a name that isn't a zone, the build fails with one line
  naming it.
- A build with no event entry succeeds, `/events` shows its empty state, and the feed parses
  with no event.
- A test gives the list function a `now` after an event's last date and the event is gone from
  the list. With JavaScript on and a date that passed since the build, the hide script removes
  it. When it removes the last one, the empty state shows.
- Each row of the events design's failure table has a test, less the rows that rest on a set's
  `code` list or on `src/site/set.ts`. The PR names the rows it left out.
- The plain views carry the class hooks `cairn-events`, `cairn-event`, and `cairn-event-date`,
  and render with no theme styling at the five widths with no horizontal scroll.
- A site composed without the layer has no `/events` route, no `src/content/events/` folder, and
  no events concept in its admin.
- `docs/editors/events.md` exists and a fresh `docs-fact-checker` returns no finding on it.
  Today: `git cat-file -e origin/main:docs/editors/events.md` exits 128.
- The admin docs say how to schedule the daily rebuild and where the zone constant is, and each
  command on the page is run in the PR's evidence.

`site-events-2`, look:

- Pennant's manifest lists `events` in `features`, and the composer prints no warning for the
  Pennant demo.
- The Pennant demo's `/events`, an event page, and the home page's "Coming up" match
  `research/pennant-mockups/events-1.html` in placement at the five widths, in light and dark,
  graded by a fresh `standards:visual-verifier`.
- "Coming up" shows the next three occurrences. The page's HTML holds the next six, each a
  different date, so that the hide script can drop a passed one and still show three. The block
  comes from `homeSections`: a Pennant site composed without events has no "Coming up" markup.
- A cancelled date shows struck through, with its note, until the day passes. Its "Cancelled"
  label reaches 4.5:1 in every color set, in light and dark.
- The organization set's sample events are a monthly map night, a summer field-day series with
  one cancelled and one moved date, and a two-day course, with dates through 2027.
- Waymark's demo, composed with the events layer, shows the plain views and a plain "Coming up"
  on its home page with no console error.
  Its manifest doesn't list `events`, and the composer prints the one warning line.

`site-basics-1`, search:

- A test builds the showcase, runs the index step, and finds `pagefind/pagefind.js` inside the
  folder `wrangler.jsonc` names as `assets.directory`. It reads the index's page count and fails
  when the count differs from the number of prerendered `.html` pages, less the 404 page. The
  markdown twins and `/search` aren't indexed. A search for a word that appears only in the
  footer finds nothing. Today: no tracked file
  but `ROADMAP.md` names Pagefind.
- An end-to-end test opens `/search`, types a word that appears in exactly one seeded post, and
  finds one result whose link is that post. It types a word that appears nowhere and finds the
  "No results" line.
- A site composed without the layer has no `/search` route, no `pagefind` folder in its built
  assets, and no Pagefind entry in `package.json`.
- A test visits every address in the built sitemap and `/search`. It fails if any page but
  `/search` requests a file under `/pagefind/`, or if `/search` requests none.
- `definitions/kinds.json` names `search` in the defaults of `blog`, `organization`, and `docs`.
  The organization set's primary menu and the starter content's primary menu each hold a
  "Search" link.

`site-basics-2`, form:

- With Cloudflare's test keys, an end-to-end test sends a valid message and the test's mail
  binding receives one message whose `to` is `CONTACT_TO`, whose `from` is the site's sending
  address, whose `replyTo` is the visitor's address, and whose text holds the message. A second
  test sends a name holding a line break and asserts the mail's subject is one line.
- A test for each row of "How it fails" that names the form or `subjects.json` asserts the
  visitor's line, that the binding received nothing where the row says so, and the log event
  with its reason.
- Three tests each unset one of `CONTACT_TO`, the site key, and the secret key. In each, the
  contact page's HTML holds no `<form>` and no `@`, and the log names the missing part.
- The build prerenders no `/contact` page and writes no `contact.md` twin, and a request to
  `/contact` is answered by the layer's route.
- A test searches the contact page's HTML, its `__data.json`, and every file in the built client
  folder for `CONTACT_TO`'s value and a subject's address, and finds neither.
- A test visits every address in the sitemap and `/contact`. `/contact` with the form showing
  requests the script from `challenges.cloudflare.com`, and no other page requests anything
  from that host.
- The form passes `hostname` and `action` to `verifyTurnstile`, and two tests are refused: one
  whose check response names another host, and one whose response names another action.
- The rate-limit test sends four messages with one `CF-Connecting-IP` value and a different
  `X-Forwarded-For` each time, and the fourth is refused. A second test sends 21 messages, each
  with a different `CF-Connecting-IP`, and the twenty-first is refused. A third removes each
  binding in turn, and the message is sent with `rateLimit: "unavailable"` in its record.
- A test reads every log record the form's tests emit and fails if one holds the visitor's name,
  address, or message. The form's server file contains no `console.` call.
- A site composed without the layer has no `/contact` action, and its `wrangler.jsonc` holds no
  contact variable and no rate-limit binding, and it has no page whose id is `contact`. Today: neither the showcase's nor the template's
  `wrangler.jsonc` names a rate limit or Turnstile.
- The organization set holds a privacy page linked from its footer menu and no contact page,
  and the form's privacy line links to the privacy page. `definitions/kinds.json` names `contact` in the defaults of `organization`
  and `portfolio`.
- `standards:web-auth-security-reviewer` returns no open finding on the form's server code.
- Four states match the mock-up's placement at the five widths, graded by a fresh
  `standards:visual-verifier`: the empty form with two subjects, the form with one field in
  error, the "sent" line, and "missing setup".

`site-basics-3`, links:

- With three named networks and one other link in the `social` menu, each theme's footer holds
  four links in the menu's order, three with an `svg` and an accessible name equal to the
  network's name, and one with visible text.
- With an empty `social` menu, each theme's footer holds no social list element.
- Each icon link measures at least 44 by 44 CSS pixels at 320 pixels wide.
- A unit test for each host rule in "Calls made here" asserts the network it reads, and the two
  build failures in "How it fails" each have a test.
- With the topics layer, each topic a published post carries has a page at `/topics/<topic>`
  listing every published post that carries the topic and no other, newest first, paged at the
  archive's page size. A test with one more post than a page holds proves the second page. A
  topic carried only by a draft returns 404. Without the layer, every topic address returns 404
  and a post's HTML holds its topics as text with no link. Today: the showcase's config
  says "cairn ships no public tag pages" at line 101.
- A test fetches the home page, a post, a plain page, the archive, and the search page, and each
  holds exactly one `og:title`, `og:description`, `og:url`, and `og:type`, none of them empty. Each `og:url` equals the page's
  canonical link and starts with `PUBLIC_ORIGIN`. A post with a lead image also holds an
  `og:image` that is an absolute address under `PUBLIC_ORIGIN`.
- `sets/blog/cairn-set.json` exists at version 1.0.0, and the set holds an about page and a privacy
  page. Its topic vocabulary names no trail or weather subject (backlog
  #388), and none of its posts writes an admin address as inline code (backlog #484).
- Waymark's manifest declares `blog` then `organization`. The publish job builds each theme's
  demo over the set of the theme's first kind, and a test fails when it falls back to another
  source (backlog #481). Today: its `kinds` is `["blog"]`, and `scripts/catalog/publish.mjs`
  line 304 passes no content folder.
- The theme check builds a theme against the set of each kind it declares, and fails when a
  declared kind has no set or a built page has a console error or a broken internal link.
- A test holds `defaultFeatures` in `definitions/kinds.json` to a fixture copied from this
  design's feature table, and fails on any difference.
- A check fails a set that has no entry whose id is `privacy`, or one whose id is `contact`.
- `templates/waymark` is composed from `sets/blog/`, and the starter content layer no longer
  exists.
- Both themes' footers pass a fresh `standards:visual-verifier` at the five widths in light and
  dark.

`site-basics-4`, new:

- `cairn new --kind organization` with no theme flag writes a site whose theme lists
  `organization` first among its kinds, and whose `cairn-site.json` lists the organization
  kind's default features.
- `cairn new --kind blog --contact on` writes a record that lists `contact`, and its
  `wrangler.jsonc` holds `CONTACT_TO`, the Turnstile site-key variable, and the rate-limit
  binding. `--kind organization --contact off` writes a site with no page whose id is
  `contact`, no `/contact` route, and no menu entry that links to `/contact`. With the form on,
  the primary menu's last entry is "Contact". A flags run with no `--kind` writes a blog site.
- `--social instagram=https://www.instagram.com/example --social other:Trail
  cam=https://example.org/cam` writes both links to the `social` menu in order. Each refusal row
  of "How it fails" has a test that asserts a nonzero exit and that no directory was created. A
  test of the question form enters a bad address and asserts the same question shows again with
  its error, and one enters thirteen links and asserts the refusal.
- The look question lists only themes declaring the chosen kind. A test with a two-theme fixture
  proves a non-declaring theme is absent, and that `--site-theme` still accepts it.
- With the form on, a run against the test account leaves `CONTACT_TO` set to the owner's address
  and either a working bot check or the printed steps. A message sent through the deployed form
  then arrives. This item is checked by hand against carin-test.org. Its evidence is the log
  record `contact.sent` and the message read in the recipient's mailbox, with its reply-to
  header.
- The tool's Cloudflare scope list is unchanged unless a ruling says otherwise. Today:
  `tool/internal/providers/cloudflare_oauth.go` requests ten scopes and none names Turnstile.
- `newAnswerFlags` holds `--kind`, `--contact`, `--social`, and `--no-social`, and a test
  asserts the agent guide in `messages.go` names every flag in that list. Each new
  refusal is a `fixError` that names the fix.
- `make -C tool check` passes, and screenshots of the real terminal show the kind and look
  questions at 80 and 120 columns.

`site-basics-5`, docs:

- `docs/admin/` holds a page on starters, a page on writing a theme, and a page on the catalog,
  each listed in `docs/admin/README.md`. `npm run check:docs-gate` and `vale` pass. Today: the
  folder holds fifteen pages and none covers a theme, a kind, a set, or the catalog.
- A fresh `docs-fact-checker` returns no finding on the three pages and on every other page the
  two rounds changed.
- A fresh agent given only the theme page and a clean checkout writes a theme with one changed
  color that passes the theme check. Its transcript shows it read no file under a `themes/`
  folder, in the checkout or in `node_modules`, and none under `scripts/theme/` or
  `docs/internal/`.
- A fresh agent given only the starters page answers six questions, written in the plan before
  the page is drafted: which kinds exist, what a set carries, which file records a site's
  features, how to add a feature to a site that exists, how to change a site's look after
  `cairn new`, and which flag picks the kind. All six answers match the code.
- Every command and flag on the three pages is run in the PR's evidence, and its output matches
  what the page says.
- The starters page's feature table is held to `definitions/kinds.json` by a check that fails
  when they differ.
- `docs/README.md` and `docs/why-cairn.md` each change by links and at most one sentence.
- A fresh `prose-voice-reviewer` returns no open finding on the three pages.

## Shared assumptions

| Assumption | Probe or source | Result |
| --- | --- | --- |
| The foundation round's structure exists when these rounds start | `git cat-file -e origin/main:definitions` and `origin/main:features` | Both exit 128 today. The start lines wait for them |
| The calendar helper is merged | `git grep -n "export function buildICalendarResponse" origin/main -- src/lib` | `src/lib/delivery/responses.ts` line 49 |
| The engine exports a Turnstile check and a rate-limit helper | Read of the `/cloudflare` entry, 2026-11-15 | `verifyTurnstile(token, secret, opts?)` and `resolveRateLimit(binding, keys)` exist |
| The public pages are prerendered | `examples/showcase/src/routes/(site)/[...path]/+page.server.ts` line 6 | `export const prerender = true;`, so the form needs a route rendered at request time |
| The template already has a mail binding | `templates/waymark/wrangler.jsonc` line 24, read 2026-11-15 | `"send_email": [{ "name": "EMAIL" }]` |
| Mail to a verified address is free | Cloudflare's Email Service pricing page | "Sending to verified destination addresses in your account is free on Workers Free and Paid plans" |
| The rate limit counts per location and allows 10 or 60 second windows | Cloudflare's rate-limit binding page | Stated there. It needs Wrangler 4.36.0 or later |
| A Turnstile widget can be created through the API | Cloudflare's Turnstile widget API page | `POST /accounts/{id}/challenges/widgets`, with the permission "Turnstile Sites Write" |
| The tool's sign-in holds that permission | `tool/internal/providers/cloudflare_oauth.go`, `CloudflareScopes` | It doesn't. The list has no Turnstile entry |
| A menu config names a menu by key | `src/lib/content/types.ts` lines 179 to 186 | `menuName`, `label`, and `maxDepth`, so a `social` menu needs no engine change once the foundation's pass 2 lands |
| Link-preview tags exist only on the article view | `git grep -n "og:" origin/main -- examples/showcase/src themes/waymark` | Every match is in `ArticleView.svelte` or the preview route |
| No topic pages exist | `examples/showcase/src/site/cairn.config.ts` line 101 | "cairn ships no public tag pages" |
| Waymark declares one kind | `themes/waymark/cairn-theme.json` line 10 | `"kinds": ["blog"]` |
| Pennant's manifest is on a known branch | `git show origin/pennant-3:themes/pennant/cairn-theme.json` | The path doesn't exist there. Pennant's pass 4 hasn't run. Unproven until Pennant closes |
| The organization set carries pages and posts | `git ls-tree -r origin/pennant-3 sets/` | Five pages, three posts, a `site.config.yaml`, and five images. No privacy page and no events |
| A feature layer can add a concept and a content folder | The foundation design, "A feature's shape" | Designed, and proven there only with a test feature. Unproven for a real one |
| A layer can contribute `wrangler.jsonc` variables and a binding by key | The foundation design, "Composition", which merges `package.json` by key | Unproven for `wrangler.jsonc` |
| Pagefind indexes what `adapter-cloudflare` builds | Pagefind's docs: it reads a folder of built HTML | Unproven for `.svelte-kit/cloudflare` |
| The tool's sign-in can ask for a Turnstile scope | Not probed | Unproven |
| The catch-all route can leave out a feature's address | `createPublicRoutes().entries()` returns every entry's path (`src/lib/delivery/public-routes.ts` line 253), and the route file calls it at line 10 | Unproven. The base's route file must filter by `paths` in site code |
| One rate-limit binding carries one limit | `src/lib/cloudflare/rate-limit.ts` line 61 | `resolveRateLimit(binding, keys)` checks each key against the one binding, so two limits need two bindings |
| `cairn new` reads no kind today | `tool/cmd/cairn/new.go` and `tool/internal/setup/scaffold/catalog.go`, read 2026-11-15 | It reads themes from the packed catalog only |

Six mechanisms are unproven, and each is settled before the work that rests on it.
`site-events-1` proves first that a layer can add a concept and a content folder, and standing
answer 13 applies if it can't. `site-basics-1` proves Pagefind before any other task (answer
14). `site-basics-2` proves the `wrangler.jsonc` contribution and the catch-all's filter first
(answer 15).
`site-basics-4`'s planner probes whether the sign-in can ask for a Turnstile scope (answer 16).
Pennant's manifest is read as merged (answer 19).

## Order

Round `site-events`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 layer | `plans/2026-11-15-site-events-1-planner-prompt.txt` | none | 240 | yes |
| 2 look | `plans/2026-11-15-site-events-2-planner-prompt.txt` | 1 | 150 | yes |

Round `site-basics`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 search | `plans/2026-11-15-site-basics-1-planner-prompt.txt` | none | 90 | yes |
| 2 form | `plans/2026-11-15-site-basics-2-planner-prompt.txt` | 1 | 150 | yes |
| 3 links | `plans/2026-11-15-site-basics-3-planner-prompt.txt` | 2 | 150 | yes |
| 4 new | `plans/2026-11-15-site-basics-4-planner-prompt.txt` | 3 | 140 | yes |
| 5 docs | `plans/2026-11-15-site-basics-5-planner-prompt.txt` | 4 | 100 | no |

Within a round the passes run one at a time, because every pair shares a file. Each pass's
worktree is cut from the pass before it once that pass's whole-branch review is accepted. The
merge order is the pass order. Geoff sees one `merge` document for each round: both passes of
`site-events` together, and passes 1 to 4 of `site-basics` together when pass 4's review is
accepted. Pass 5 lands after that document is answered.

`site-events` is 390 path minutes and stops new launches past 780. `site-basics` is 630 and
stops past 1,260. The usage ceiling for each is 85 percent of the weekly allowance.

Events go first because that work was approved first, a merged helper waits on it, and Geoff
ruled "Events first, then Survey". The docs pass is last in the second round, so that it
describes `cairn new` and every feature as built. Ruling 1 lets Geoff reverse the order.

## Start line

`site-events` launches when each of these reads true. Lines 1, 2, and 4 aren't true today.

1. `docs/STATUS.md` on `origin/main` holds a line that reports round `foundation` closed.
2. `claude agents --json` holds no row named `cairn-cms-foundation-*`, `cairn-cms-pennant-*`,
   `conductor-foundation`, or `conductor-pennant`.
3. This design's document in the Approval Queue is answered "approve".
4. `definitions/features.json`, `starter/compose.mjs`, and `themes/pennant/cairn-theme.json`
   exist on `origin/main`.

`site-basics` launches when each of these reads true. None but line 3 can be true before
`site-events` closes.

1. `docs/STATUS.md` on `origin/main` holds a line that reports round `site-events` closed.
2. `claude agents --json` holds no row named `cairn-cms-site-events-*` or
   `conductor-site-events`.
3. This design's document in the Approval Queue is answered "approve".
4. `features/events/` exists on `origin/main`.

If ruling 1 reverses the order, the two rounds swap their lines 1, 2, and 4, and `site-basics`
waits for `foundation`.

Launch checks, read on 2026-11-15:

| Check | Command | Output |
| --- | --- | --- |
| Main is current | `git rev-list --count HEAD..origin/main` | `0`, at `6499871a8` |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 41% used` |
| Live sessions | `claude agents --json` | `conductor-pennant` busy, `cairn-cms-pennant-3` busy, no `foundation`, `site-events`, or `site-basics` row |
| Open pull requests | `gh pr list` | #251 `pennant-1`, #253 `pennant-2`, #254 `pennant-3` (draft) |
| Launch flags | `claude --help` | Lists `--bg`, `--model`, `--effort`, and `--name`, and no `--advisor`, which is accepted all the same: Pennant's planners launched with the same line on 2026-11-15. Each conductor probes the listed flags the day it launches |
| `site-events` line 1 | read of `docs/STATUS.md` | Foundation hasn't launched. Not met |
| `site-events` line 4 | `git cat-file -e origin/main:definitions` | Exits 128. Not met |

Each conductor reads all of them again on the day it launches.

## Steps for Geoff

- [you: approve this design in the queue]
- [you: answer the `merge` document for `site-events`]
- [you: answer the `merge` document for `site-basics`]
- [you: confirm the mail Cloudflare sends when `cairn new` adds a recipient address, during
  `site-basics-4`'s hand check on carin-test.org]

Nothing else needs him. The form runs on each site's Cloudflare account, because that is where
the site, its mail binding, and its bot check already are. Nothing in either round runs on
orpheus or ward.

## Standing answers

The twelve in `round-run.md` hold for both rounds. This design adds:

13. A layer can't add a concept or a content folder as the foundation round built it: the pass
    parks. The fix belongs to the composer, and it is never worked around in the layer.
14. Pagefind can't index the adapter's output: `site-basics-1` has the build write the
    prerendered HTML to a folder Pagefind can read and copies the index into the assets folder.
    If no page is prerendered, the pass parks.
15. A layer can't contribute `wrangler.jsonc` keys through the composer, or the catch-all route
    can't leave out a feature's address in site code: the pass parks, for the same reason as
    answer 13.
16. The tool's sign-in can't create a Turnstile widget: `cairn new` prints the dashboard steps
    and the command that stores the keys, and the form stays in its "missing setup" state. Never
    ask for a wider scope without a ruling, and never try another credential.
17. A feature needs a file under `src/lib/**`: the pass parks.
18. A theme's contrast fails on a new control: tune the value within its hue and list old and new
    in the PR.
19. Pennant's, the organization set's, or the foundation round's merged files differ from what
    this design read: the planner plans against the files as merged, and parks only if an
    acceptance item can no longer be met.
20. A set or theme version is already published at the number a pass picked: take the next one.
21. The hand check on carin-test.org can't send mail because the address isn't verified: the
    pass records the step for Geoff in its `merge` document and finishes everything else.
22. An event's date or hour can't be proven right in the feed under both test time zones: the
    pass parks. It never ships a feed with a known wrong hour.
23. A pass needs a change under `.github/**`, `scripts/release/**`, or `.claude/settings*`: it
    leaves the file alone, records the change it needs in the round's `merge` document, and
    finishes everything else.
24. A pass comes out over twice its path minutes at planning: it parks, as `round.md` says.

## Rulings

Geoff's answers are recorded here when the queue document returns.

1. One round or two, and which goes first.
2. Whether the site-basics design's three rulings and the events design's five rulings stand as
   quoted under "Decided by Geoff". This design assumes they do.

## Backlog verdicts

A scoped sweep read the open items at `6499871a8`. Nothing in the 153 open items covers a
contact form, Turnstile, Pagefind, topic pages, social links, link-preview tags, or events.

| Item | Verdict | Where |
| --- | --- | --- |
| #481 Waymark's demo falls back to the starter content | fold | `site-basics-3`: the publish job picks the set by the theme's first kind, and the blog set is written. About 40 minutes |
| #388 neutral starter tag vocabulary | fold | `site-basics-3`: the blog set's vocabulary is a short neutral list, named in the plan. About 15 minutes |
| #484 starter posts write `/admin` as inline code | fold | `site-basics-3`: reworded as plain prose in the blog set's posts. About 10 minutes |
| #483 demo canonical and feed links name `showcase.test` | keep | The foundation round's pass 4 closes it. `og:url` and the calendar feed need a true origin, so `site-events-1`'s planner confirms it is closed |
| #508 terminal layer rebuilds the triple | reword | Cut to what is left: the `longDoctor` sentence at `messages.go` lines 357 to 358, the comment at `main.go` line 143, and the triple rebuild |
| #383 show an admin a failed deploy | reword | "The App holds Actions read (`github_app.go` line 78), and the admin has no deploy-status view. Needs a scope check before building." |
| #407 agent guide in `cairn help agents` | keep | It asks for a design call. `site-basics-4` adds the new flags to the guide and leaves the item open |
| #501 `cairn new` reads its ground from one flag | keep | Installer-view work, outside an `auth-data` pass's files |
| #504 errors with no typed fix | keep | A rule for the new refusals, which are written as `fixError` |
| #302 `wrangler types --check` after `cairn new` | keep | The contact layer adds a binding and variables, so the item's text gains that line |
| #329, #411 who owns edits under `skills/` | keep | Each plan that edits `skills/` names the skill its executor loads |
| #486 every proving demo shares one address | keep | Checked when Pennant lands |
| #168, #482, #378, #524, #437, #469, #487, #410, #412, #416, #304 | keep | Stamped by `site-events-1` |

The stamps and the two rewords land in `site-events-1`'s PR. The foundation round's landed the
same way, in its pass 1. Neither round changes the installer's sign-in files or the theme check's
internals, and the sweep did not ground the items about them. The backlog holds 153 open items,
and 45 carry no stamp from the last 90 days. A full sweep is due. It runs separately and never
rides this design.

## Estimate

Seven passes and 1,020 path minutes in two chains. `site-events`: 240 and 150. `site-basics`:
90, 150, 150, 140, and 100. The events figures are the events design's for its passes 2 and 3.

## Practice and sources

- The events design, `specs/2026-11-14-events-design.md`, and the site-basics design it sits
  beside, `specs/2026-11-15-site-basics-design.md`.
- The foundation design, `specs/2026-11-15-foundation-design.md`.
- The survey of public sites, `research/site-features-survey-2026-11-15.md`, with its limits
  stated at the top.
- RFC 5545, iCalendar, for the feed.
- Cloudflare Turnstile, widget management through the API and server-side validation:
  developers.cloudflare.com/turnstile/.
- Cloudflare Workers rate-limit binding:
  developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/.
- Cloudflare Email Service, sending from a Worker and its pricing.
- Pagefind: pagefind.app/docs/.
- The Google Developer Documentation Style Guide and the repo's `cairn-writing-docs` procedure,
  for the docs. Microsoft's style guide for `docs/editors/events.md`.
- WCAG 2.2, target size and error identification, for the form and the icon links.
- The Open Graph protocol, ogp.me, for the four required tags.

## Out of scope and later

- The portfolio, documentation, and product-page sets, each with its column of the feature table.
- Waymark's remaining three kinds, one as each set lands.
- `cairn remove <feature>`, and an editor switching a feature on in the admin.
- `cairn new` reading the hosted catalog, with the lock file.
- A stored copy of contact messages, if a site asks for one. It would be a scope question first.
- Search across more than one language.
- The engine release that carries all of this.
