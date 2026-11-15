# Pennant, a club theme for the catalog

Initiative: theme-garden. Round id: `pennant`. Repo: cairn-cms, read at `47271e397`.
Status: approved by Geoff (2026-11-15), packet `20261115-041501-ead5c5`.

## Brief

Pennant is cairn's second public theme and the catalog's second entry. It is for club teams: a
ski club, a rowing club, a youth league. A club sets two colors and the whole site follows them.
The theme ships five starting color sets, works with photos in every slot and with none, and
orders its home page by what a survey of 51 club sites found people need there.

The round is four passes. The first adds a card block to the template's block list. The second
lets a page be the home page. The third writes the fictional society's sheet into an
organization content set and fixes the publish job for a second theme. The fourth builds the
theme and publishes it with a demo at `demo-pennant.cairn.pub`.

The round puts Pennant in the hosted catalog with a live demo. It doesn't make `cairn new`
offer it. The tool still reads the one theme packed in the engine and asks no option question
(catalog design, lines 414 to 417), and that installer work is planned as a separate piece.

## Why

A site owner picks a theme at setup, and today the catalog offers one, Waymark, a neutral blog
look. A club has different needs. The survey (`../research/club-sites-survey-2026-11-14.md`)
read 51 public club, team, and league home pages and the published guidance beside them:

- 40 of 51 carry a call to join or register. Only the logo and the navigation are more common.
- Programs appear as cards or a list on 8 of 18 club team sites and as tiles on 6 of 16 youth
  club sites. The member-run clubs weren't counted for them.
- 25 of 51 show sponsor logos, and 22 of 51 a news list.
- Seven of the 17 member-run clubs ship a heading over nothing, and stale or undated event
  lists turned up in all three groups. They make a club look closed.
- Most of the sports templates read lead with fixtures and standings. Of the clubs, 3 of 18
  club teams and 2 of 17 member-run clubs show results at all.

The three site reports counted with slightly different definitions, and the totals of 51 are
sums across them. The record's "Open points" section lists each difference.

## Decided by Geoff

Each of these is his words or his answer in the design conversation of 2026-11-14.

- The theme starts from ecxc.ski and is for a team or club that can "easily modify the theme to
  fit their school colors", with "some example starting color sets".
- It pulls every daisyUI lever to give a daisyUI theme a distinct identity.
- It is "our next entry for the new theme catalog".
- It is "targeted at club teams specifically". School teams are a different theme.
- The home page reflects "what people are likely to need on the front page of a site".
- The third mockup is approved: "close enough to move on from design".
- The name is Pennant, id `pennant`.
- A card block joins the block list and the theme waits on it. The scope read below argues
  against this, so the packet asks him again with both sides.
- Pennant comes before Survey. 907.life's live setup waits for Survey, so it waits longer.
- No tinted-photo option in the first version.
- "The theme needs to work both with and without photos."
- A catalog description never addresses the reader as "you".

## Goals

1. A site on Pennant gets a home page in the order below, in one of five color sets, with no
   code edit.
2. A club changes to its two colors by setting four values in `src/site/overrides.css`: each
   color and the text color that sits on it.
3. Every page reads as finished with no photo anywhere.
4. Text meets WCAG 2.2 AA contrast, 4.5:1, in every color set, light and dark.
5. The home page never shows an empty or undated section.

## Non-goals

- Fixtures, results, standings, or rosters. A club that needs them builds them.
- Events. A dated events list with a calendar feed is the next round's work (see "Rulings"), and
  Pennant gains its section for them there.
- School teams.
- A color picker in the admin. The option is chosen at setup and changed in a file.
- A font option, a tinted-photo option, or a layout option.
- The blog, portfolio, landing, and documentation content sets. Only the organization set is
  written here.
- `cairn new` reading the hosted catalog or asking a theme's option questions. No pass touches
  `tool/`, and no pass releases the engine.

## Anti-goals

- A home page that looks broken when a club has no photos, no posts, or no sponsors.
- A child's full name printed beside their photo by the theme.
- A color set that fails contrast in one mode.
- A published release with a known visual fault, since a release can't be withdrawn.

## The look

The approved mockup is `../research/pennant-mockups/varsity-3.html`, with screenshots of the
navy set, the no-photo state, the phone width, and dark mode beside it. It sets layout, type,
color, and spacing. Every word in it is placeholder. "Fidelity" below says how closely the
build follows it.

- **Type.** Big Shoulders Display for the club name and section headings, Barlow Semi Condensed
  for navigation and labels, Barlow for text. All three are under the SIL Open Font License 1.1
  and ship as woff2 inside the theme.
- **Color.** Two inputs, color 1 and color 2, each with the text color that sits on it. The
  tinted grounds and borders derive from them (call 13).
- **Shape.** Radii of 10px on cards and 7px on controls. Soft, never pill-shaped.
- **Header.** A color-1 bar with a shield crest, the club name, up to five links, and a color-2
  Join button. The crest is drawn by the theme: a shield holding the club's initials, taken
  from `siteName`. The site config has no logo field, and the round adds none.

### The five color sets

| Value | Color 1 | Color 2 |
| --- | --- | --- |
| `fireweed` (default) | Deep magenta | Spruce green |
| `navy` | Navy | Gold |
| `scarlet` | Scarlet | Charcoal |
| `purple` | Purple | Silver |
| `orange` | Orange | Royal blue |

The values are the mockup's (`varsity-3.html` lines 169 to 173).

### Fidelity

The bar is quite close: a fresh grader compares layout, type, color, and spacing device by
device, and wording is never compared. Two departures from the mockup's markup are decided
here, and the grader is told both.

- A program card in the mockup is one link around a heading, an audience line, text, and a
  meeting line. A card item is one line of markdown (call 2), so the card's title is the link,
  and the audience and meeting lines are emphasis inside the text, which Pennant sets small.
- Where-and-when in the mockup is a definition list. Here it is a `cards` block whose items
  carry no image and no link, and Pennant styles such a block as the mockup's facts row.

## The home page

The order, top to bottom.

1. **Notice.** The existing banner block, with its expiry date. Gone when expired. The editor
   writes it first in the page, and it renders above the hero.
2. **Hero.** The page's title, its description, and its image, with a "Join" button and a
   second button beside them. The buttons are the two links of the `actions` menu (call 12).
   With no image, the crest sits there on a color-1 ground.
3. **Programs.** A card block, each card a title that links, a few lines, and an optional
   picture.
4. **Where and when.** A card block with text-only cards: where the club meets, when, and whom
   to ask.
5. **News.** The newest three posts, each dated, with a link to the archive. The section is
   absent when the site has no post.
6. **Supporters.** A card block of names or logos. Absent when the editor leaves it out.

Sections 3, 4, and 6 are the page's body, which an editor writes. The news list is supplied by
the route and sits where the body's last rule line is (call 7).

The theme prints no caption and no name on a photo. The organization set's footer menu carries
a "Safeguarding and privacy" link and a "Contact" link, and the header's menu carries
"Contact" too when it holds fewer than five links. The contact page is an ordinary page: who to
write to, where and when the club meets, and how soon a volunteer answers. The safeguarding
page says photos of children appear only with a
parent's written consent and never beside a full name. The FA's "Photographing and Filming
Children", Volleyball England's "Use of Photography", and the NSPCC Child Protection in Sport
Unit all state that practice.

## Calls made here

These are Claude's, marked so Geoff can check them while reading.

1. **Color is one theme option, `colors`, with the five values above.** Contract 1 allows four
   options of two to eight values. A club's colors go in `src/site/overrides.css`, which setup
   already writes empty. The theme's README shows the lines.
2. **The card block is one block, `cards`, with a repeatable list of items.** Each item is a
   line of markdown: an optional image, a link that becomes the card's title, and text. A
   block attribute can't hold an image (`src/lib/render/registry.ts:289-302`), and a wrapper
   around nested `card` blocks doesn't survive an edit: a probe of `serializeComponent`
   (`src/lib/render/component-grammar.ts`) printed `{"safe":false,"reason":"undeclared-child"}`.
   One attribute, `columns`, takes `2`, `3`, or `4`. Supporters and where-and-when use the same
   block.
3. **The grid's layout and a plain default look live in the chassis `prose.css`.** A theme
   styles the block further only if it wants to. So no existing theme has to change: Waymark
   1.1.0 is published and permanent, and a site that pairs it with a newer template gets a
   working grid in its colors. Pass 1 doesn't edit `themes/waymark/` and publishes nothing.
4. **The block list grows to ten, and contract 1 keeps its number.** The change is disclosed in
   `MIGRATION-NOTES.md` and `CHANGELOG.md`. The `directive-styled` rule counts the chassis
   sheet (`scripts/theme/check-rules.mjs:193-204`), so a theme with no `cards` rules still
   passes, which is the intent.
5. **The home page is the page whose id is `home`.** It needs no new field and no setting, and
   an editor controls it by creating or renaming a page. The scope read chose it over a
   frontmatter flag and a config key.
6. **With a home page, the archive serves page one, and page one starts at the newest post.**
   Today posts page one exists only at `/` and the archive drops the lead post
   (`archive/[page]/+page.server.ts:12-27`), so a page home would leave the newest post with no
   index address.
7. **The home route hands the theme's article view a `home` marker, the newest three posts,
   and the body in two parts.** `ArticleView` renders the body as one block of HTML
   (`themes/waymark/components/ArticleView.svelte:145`), so the route splits it at the body's
   last rule line (`---` in markdown) and the view puts the news list between the parts. With
   no rule line the list follows the body. A theme controls no route
   (`schema/cairn-theme-contract-1.json`), so the template does this once and each theme
   styles it. The preview route passes the same marker and posts. A planner may choose another
   split that keeps two properties: the editor places the list with ordinary markdown, and no
   block is added.
8. **Pages gain two optional fields, `description` and `image`,** in the template's
   `cairn.config.ts`. Posts already have both. The hero shows them.
9. **Pennant's demo serves the organization set**, written so the society reads as a member
   club with programs, a place to meet, and a way to join. The catalog rule gives a theme the
   set of its first kind.
10. **The proving run checks each demo as it deploys, on the one proving Worker.**
    `publish.mjs` already waits for each theme's release marker right after its deploy. The
    later reference check then fails every theme but the last, because all share one address
    (backlog #486). On the proving target the reference check reads the demo marker of the
    last-deployed theme only. No proving Worker is added, and
    `docs/internal/theme-catalog.md:114` stays true.
11. **The theme check measures contrast for every option value in both modes.** Today
    `check-rules.mjs` lays the theme into a showcase copy with an empty `theme-options.css`
    (about line 255), so only the default chain is measured.
12. **The Join button and the hero's buttons come from a menu named `actions`** in
    `site.config.yaml`. `menus` is an open map (`src/lib/nav/site-config.ts:95`), so this adds
    no field. Its first link is the header's Join button and the hero's first button, and its
    second is the hero's second button. Like the footer menu, a developer edits it in the file.
    With no `actions` menu, no button renders.
13. **Color 1 paints grounds through `--color-neutral` and text through `--color-primary`.**
    The check requires `--color-primary` to reach 4.5:1 on the page ground in both modes
    (`contrastPairs`, `src/lib/audit/rules/static/theme-contrast.ts:174-196`). Measured on the
    mockup's values, orange reaches 2.76 on a light ground, and fireweed, navy, scarlet, and
    purple reach 2.92, 1.32, 2.93, and 1.67 on a dark one. So the bar, the hero ground, and the
    crest keep the club's color in both modes as `--color-neutral` with
    `--color-neutral-content` on it, and `--color-primary` is an ink form of color 1 fixed per
    set and per mode. Color 2 is `--color-secondary`. Every text and ground pair Pennant paints
    is one of the pairs the check measures.
14. **Derived colors use `color-mix()` in oklch, never relative color syntax.** The contrast
    resolver evaluates one `color-mix()` form over `var()` operands and records a relative
    color as unmeasured (`src/lib/audit/contrast.ts:163`), which the publish job refuses. A
    club's override still flows through, because the mixes read the four custom properties.
15. **Pennant and the organization set declare an `engine` range that excludes
    `0.99.0-rc.4`** and admits every later version, since both need the template that passes 1
    and 2 change. Pass 4's planner confirms how the tool and the publish job read the range.

## Scope

`engine-triage` read both scope items on 2026-11-14 against the charter and the rulings ledger.

- **Page as home: accept, reshaped.** The route is site-owned and `src/lib/` doesn't change.
  The reshaping is calls 5 and 6, and the newest three posts count as part of the change. The
  pass also keeps the `home` page from being served a second time at `/home`.
- **Card block: decline.** The read rests on `scope-verdict-361` and the theme contract, which
  fixed the block list so "no content changes" and sends anything new to a site-specific block
  in `src/site/`. It argues that a theme round shouldn't grow the list, that every later theme
  could ask for its own block, and that the new block is a breaking duty on every theme. It
  would reopen the question on evidence that two or more kinds need linked cards.

Geoff already answered yes to the block. The read is advice and the call is his, so the packet
asks it. Claude recommends keeping the block. A content set holds no code, so without a shared
block the organization set can't show programs as cards at all, and the portfolio and landing
kinds will want the same grid. Call 3 also removes the duty the read names, because the chassis
styles the block for every theme. If he declines, pass 1 drops out, Pennant styles a plain list
of links on the home page as cards, and the where-and-when and supporters sections become plain
lists.

Both verdicts are recorded in `docs/internal/engine-rulings.md` by the pass that builds on them.

## How it fails

| Case | What happens |
| --- | --- |
| No page with the id `home` | `/` lists the newest posts, as today, and `/archive/1` is a 404 |
| A `home` page and no posts | The news section and the archive link are absent |
| A `home` page with no image | The crest shows on a color-1 ground |
| A `home` page with no description | The hero shows the title and the buttons |
| A `home` body with no rule line | The news list follows the body |
| No `actions` menu | No Join button in the header and no buttons in the hero |
| A card with no image, in a grid where others have one | The card shows its text at the top; no empty box |
| A card with no link | The title is plain text |
| A `cards` block with one item, or with nine | One card at the column width; nine wrap by `columns` |
| `columns` missing or not 2, 3, or 4 | 3 |
| An expired banner | Nothing renders, as today |
| A `siteName` with no letters | The shield shows with no initials |
| Colors in `overrides.css` that fail contrast | The site's audit rule `theme-contrast` reports it; the theme can't prevent it |
| Viewport of 320px | Cards stack in one column, the header's links fold into a menu |

Limits, all existing: four options per theme, two to eight values each; fonts 400 KB in total;
the card image 720x480 WebP under 100 KB; a set image 400 KB; an archive 8 MiB; a description
60 characters.

## Passes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares files with |
| --- | --- | --- | --- | --- | --- | --- |
| `pennant-1` cards | The `cards` block in the template and showcase, laid out and plainly styled by the chassis, in the conformance page and the packaged skill | `templates/waymark/src/chassis/**`, `examples/showcase/src/chassis/**`, `examples/showcase/src/routes/(site)/styleguide/`, `examples/showcase/e2e/**`, `scripts/theme/conformance/**`, `scripts/build/starter-overlay/**`, `skills/cairn-styling-public-pages/**`, `skills/cairn-extending-a-site/**`, `templates/waymark/.claude/**`, `docs/**`, `MIGRATION-NOTES.md`, `CHANGELOG.md`, `docs/internal/engine-rulings.md` | ordinary | 110 | none | 2, 3, 4 |
| `pennant-2` home | A page as the home page, the archive's page one, the newest three posts, the pages `description` and `image` fields, the `actions` menu in the template's config | `templates/waymark/src/routes/**`, `templates/waymark/src/site/{cairn.config.ts,site.config.yaml}`, the same under `examples/showcase/`, `examples/showcase/e2e/**`, `themes/waymark/**`, `schema/cairn-theme-contract-1.json`, `docs/admin/**`, `docs/editors/**`, `MIGRATION-NOTES.md`, `CHANGELOG.md`, `docs/internal/engine-rulings.md` | ordinary, `live-account` | 150 | 1 | 1, 3, 4 |
| `pennant-3` set | The organization set from the society sheet; the publish job picks a theme's set by kind, sets the demo's origin, and proves each demo in turn | `sets/organization/**`, `scripts/catalog/{publish,demo,reference-check}.mjs` and their tests, `docs/internal/theme-catalog.md`, `BACKLOG.md` | ordinary, `live-account` | 120 | 2 | 1, 2, 4 |
| `pennant-4` theme | `themes/pennant/` with the `colors` option, checked for contrast in all ten states, in the catalog with its demo | `themes/pennant/**`, `scripts/theme/{build-tokens,check-rules,check-render,lay-in}.mjs` and their tests, `scripts/theme/fixtures/**`, `sets/organization/**`, `CHANGELOG.md`, `BACKLOG.md` | ordinary, `live-account` | 260 | 3 | 1, 2, 3 |

`docs/STATUS.md` is the conductor's alone. `.github/workflows/catalog.yml` is not edited. A
pass that finds it must edit the workflow sends that file to Geoff in a small packet, as the
held-path rule says. `templates/catalog.json` is not edited either: it lists the themes packed
in the engine, and Pennant isn't one.

### What each merge publishes

The `catalog` workflow publishes on every push to `main` that changes `themes/` or `sets/`, and
a release can't be withdrawn. A fix is a new version.

| Merge | Publishes |
| --- | --- |
| Pass 1 | Nothing |
| Pass 2 | Waymark 1.2.0, which renders a home page with the news list |
| Pass 3 | The organization set 1.0.0 |
| Pass 4 | Pennant 1.0.0 and its demo, and the organization set 1.1.0 if the theme's build changed the set |

Passes 2 and 3 publish before Geoff sees a render, so the packet asks whether they land on
review or wait for him.

## Acceptance

Each item can fail. Two hold for every pass: the pull request shows evidence for each item, and
everything written for a person follows `~/.claude/docs/voice/written-for-people.md` or the
repo's docs rules.

### Pass 1, cards

1. The showcase's `/styleguide` page shows two `cards` blocks. One has three items with
   `columns="3"`: one item with an image and a linked title, one with a linked title only, one
   with plain text only. The other has four items with `columns="4"`. An end-to-end test reads
   the page at 320, 390, 768, 1440, and 2560 pixels, light and dark, and asserts no horizontal
   scroll, no `img` without a `src`, three columns at 1440 for the first block and four for
   the second, and one column at 320.
2. In the admin, the insert form adds a `cards` block with two items, one holding an image and
   a link. Editing that block and saving leaves the markdown byte-identical. A test asserts it.
3. With the `cards` rules removed from the chassis `prose.css`, `npm run test:theme` fails on
   `directive-styled` for Waymark. With them present it passes, and `git diff --stat` shows no
   file under `themes/`.
4. `git grep -n -i -E "nine (blocks|directives)|9 (blocks|directives)"` over `templates/`,
   `examples/showcase/`, `skills/`, `scripts/`, `docs/`, `src/lib/`, and `MIGRATION-NOTES.md`
   returns nothing.
5. `docs/editors/` gains a section on adding a card that names the `cards` block and its
   `columns` values, the fact-checker returns no finding on it, and `npm run check:docs-gate`
   passes.

### Pass 2, home

1. With a page whose id is `home` and four posts, `/` returns that page's title in its `h1`,
   `/archive/1` returns 200, and the first entry on `/archive/1` is the newest post.
2. With no such page, `/` and `/archive/1` answer exactly as on `main`: the post list, and 404.
3. With a `home` page and four published posts plus one draft, `/` shows the newest three
   published posts with dates and a link to the archive, and never the draft. With no posts it
   shows neither, and the page holds no empty heading. The test runs on the showcase with
   Waymark.
4. A `home` body with a rule line renders the news list between the two parts, and one with no
   rule line renders it after the body. A test asserts both orders.
5. `/home` and `/home.md` don't answer 200 as a second copy: each redirects to `/` or is
   absent. `sitemap.xml` lists `/` once, lists `/archive/1`, and never lists `/home`.
6. The preview of the `home` page shows the news list.
7. The showcase gains a `home` page fixture only inside the tests that need it, so its real
   home page and Waymark's existing baselines don't change. The end-to-end suite is green on
   CI, and the pull request lists every baseline that changed.
8. A site on the template at `main` with Waymark 1.2.0 renders `/` as before: the theme works
   with a template that passes no marker. A test asserts it.

### Pass 3, set

1. `sets/organization/cairn-set.json` validates against `schema/cairn-set-1.schema.json`. A
   test asserts the set holds a `home` page with a description, an `actions` menu of two
   links, three posts, a safeguarding page linked from the footer menu, a contact page linked
   from the footer menu with no phone number and no person's name on it, and at least four map
   images, each with its source and license in the manifest.
2. Every invented name in the set has a recorded search that found no real match, listed in
   the pull request.
3. A test runs the publish job with injected fakes over two themes and asserts each deploys in
   turn, each is waited on, and the proving reference check passes. The live proof with two
   real themes is pass 4's pull request run.
4. A demo built with the set carries the demo's origin, never `showcase.test`, in the
   canonical link and `og:url` of `index.html`, in `feed.xml`, in `sitemap.xml`, and in
   `robots.txt`. A test asserts all five.
5. The pull request lists every sentence in the set that states a fact about a real place,
   each with its public source, and the closing reviewer checks all of them.

### Pass 4, theme

1. `node scripts/theme/check.mjs themes/pennant` passes, and its output lists a contrast
   measurement for each of the five `colors` values in light and in dark, with no pair
   recorded as unmeasured.
2. With one color set's text color changed to fail 4.5:1, the same command fails and names
   the set and the mode.
3. An axe `color-contrast` run over the home page, a post, a page, the archive, and the 404
   page reports no violation in each of the ten states.
4. A fresh grader compares the demo's home page with `varsity-3.html` under the "Fidelity"
   bar: at 320, 390, 768, 1440, and 2560 pixels in the default set, light and dark, and at
   390 and 1440 in the other four sets, light and dark. It passes each of the 26 renders, or
   the close packet shows the failing one.
5. The home page, a page, a post, the archive, and the 404 page are rendered at 390 and 1440,
   once with a photo fixture in every image slot and once with none. The grader passes both
   against the mockup's type, color, and spacing, and against `v3-bare.png` for the home page
   with no photo.
6. The viewer's scratch site (`scripts/theme/viewer/site.mjs`), built with the `navy` value
   and no color-mode cookie, shows navy as the header's ground on first load.
7. Four custom properties in `src/site/overrides.css` recolor the header, the buttons, the
   links, and the card accents. Screenshots of the home page, a post, and the archive in a
   sixth color pair show it, and the site's `theme-contrast` audit passes on that pair.
8. `themes/pennant/cairn-theme.json` names the three fonts with their SPDX license, lists
   `kinds: ["organization"]`, and carries the description under "Rulings" exactly. A test
   asserts the description is 60 characters or fewer.
9. After merge, `catalog.cairn.pub/index.json` lists Pennant 1.0.0. `demo-pennant.cairn.pub`
   serves the society's home page in the `fireweed` set with all six sections in order, and
   `/admin` there is absent.

## Shared assumptions

Each was probed at `ef9e37206` or `47271e397` on 2026-11-14, or is quoted.

| Assumption | Probe or source |
| --- | --- |
| A wrapper block with nested child blocks breaks on edit | A vitest probe of `serializeComponent` printed `SAFETY {"safe":false,"reason":"undeclared-child"}` and a three-colon outer fence. The script was the session's scratch file and isn't kept; pass 1's planner reruns the probe |
| A block attribute can't be an image | `src/lib/render/registry.ts:289-302`: `defineBlock` throws for `image`, `object`, `array`, `multiselect`, `reference` |
| A repeatable item is one string, entered through its first field | `registry.ts:33-36`: "The insert form reads only the first key" |
| A theme controls no route | `schema/cairn-theme-contract-1.json` requires `SiteHeader`, `SiteFooter`, `ArticleView`, `EntryRow` and allows no route file |
| An option value can set light and dark colors separately | `scripts/theme/build-tokens.mjs:21-26`: each context holds a `light` and a `dark` group |
| Option values aren't measured for contrast | `check-rules.mjs` lays the theme in with an empty `theme-options.css`. An inference: pass 4's planner confirms it with acceptance item 2 before building on it |
| The contrast resolver measures `color-mix()` over `var()` and not a relative color | `src/lib/audit/contrast.ts:113-140` and `:163` |
| The check measures `--color-primary` on the page ground and each role's content on its role | `theme-contrast.ts:174-196`; `ROLES_WITH_CONTENT` at line 39 holds `primary`, `secondary`, `accent`, `neutral`, and the statuses |
| `menus` takes any menu name | `src/lib/nav/site-config.ts:95`: `menus?: Record<string, unknown>` |
| Pages have no `description` or `image` field | `templates/waymark/src/site/cairn.config.ts:130-132`: `title` and `robots` |
| The site config has no logo field | `templates/waymark/src/site/site.config.yaml` holds `siteName`, `description`, `menus`, `vocabulary`, `tidy` |
| The proving target deploys every theme over one Worker | `docs/internal/theme-catalog.md:24-25`; `publish.mjs:299-300`; backlog #486 |
| A published release is permanent | The catalog conductor's report, 2026-11-14: the bucket's lock rules on `themes/` and `sets/` are indefinite |
| `cairn new` doesn't read the hosted catalog | `tool/internal/setup/scaffold/catalog.go:25` reads the template's packed `catalog.json`; catalog design lines 414 to 417 |
| The catalog pass is finished | `git show origin/main:docs/STATUS.md` line 55: "theme-catalog-1 is merged (#246, `ef9e37206`" |

## Order

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 cards | `plans/2026-11-14-pennant-1-planner-prompt.txt` | none | 110 | no |
| 2 home | `plans/2026-11-14-pennant-2-planner-prompt.txt` | 1 | 150 | by his ruling |
| 3 set | `plans/2026-11-14-pennant-3-planner-prompt.txt` | 2 | 120 | by his ruling |
| 4 theme | `plans/2026-11-14-pennant-4-planner-prompt.txt` | 3 | 260 | yes |

The merge order is the same. The chain is 640 path minutes, and no launch starts past 1,280.
Pass 4 waits for Geoff whatever its review says, because merging it publishes a release that
can't be withdrawn. Its close packet carries the grader's renders beside the mockup. The usage
ceiling is 85 percent of the weekly allowance.

The cards pass runs first because it rests on the least-proven mechanism, a repeatable item
that carries an image and a link.

## Start line

The first planner launches when all of these read true:

1. The design packet is answered with an approve.
2. `git show origin/main:docs/STATUS.md` carries the "theme-catalog-1 is merged" line.
3. Geoff's answer on running beside round `tui-language` is recorded under "Rulings" below.
   Beside it, the round has a second conductor, `conductor-pennant`, which never edits
   `docs/STATUS.md` while `conductor-cairn-cms` runs and never runs `make -C tool check`.
   After it, the line also needs `claude agents --json` to show no `tui-language` session.
4. `claude agents --json` shows no `cairn-cms-theme-garden-3` executor. Survey's plan has
   never launched and stays unlaunched until this round reports.
5. The demo Worker step under "Steps for Geoff" is done before pass 4's pull request opens. It
   doesn't hold passes 1 to 3.

Launch checks run on 2026-11-14:

| Check | Output |
| --- | --- |
| `claude -p "/usage" --model haiku` | `Current week (all models): 21% used` |
| `git rev-list --count HEAD..origin/main` | `1`: the main checkout is one commit behind, and live sessions hold it. The conductor pulls with `--ff-only` at launch |
| `claude-worktree-busy /var/home/glw907/Projects/cairn-cms` | `busy: process 1221207 has the path in its command line`, exit 1. Other rounds' sessions run from the main checkout. The conductor runs the check on this round's worktrees only, as the `tui-language` conductor does |
| `claude --help` | lists `--bg`, `--effort`, and `--name` |
| `vale`, `tellgrader`, `approval-queue` | all three on the path |

## Steps for Geoff

- `[you: before pass 4]` A `ws-admin` session creates the Worker `cairn-demo-pennant` with its
  custom domain `demo-pennant.cairn.pub`, as `docs/internal/theme-catalog.md` lines 98 to 111
  describe. The `ci-cairn-demos` token then needs that Worker in its scope. Whether the scope
  can be widened in place is unconfirmed. If it can't, the designing session opens the token
  page and raises `secret-receive` for the new value. Check: `https://demo-pennant.cairn.pub/`
  answers 200 with the placeholder page, and a `wrangler deploy --dry-run` for the Worker under
  the token answers without a 403.
- `[you: the end]` Read pass 4's close packet and the round report.

## Standing answers

The twelve in `round-run.md` hold. The round adds these.

1. A repeatable item can't carry an image and a link as designed. The planner of pass 1 takes
   the nearest form that keeps one block and the insert form, flags it, and goes on.
2. Option values turn out to be measured for contrast already. Pass 4 drops that work and
   keeps acceptance items 1 and 2 as written.
3. The `colors` option hits backlog #412. Pass 4 fixes #412 in `build-tokens.mjs` with a
   fixture test, inside its estimate plus 30 minutes.
4. A color set can't reach 4.5:1 in one mode. The executor tunes the ink or the text color
   within its hue and lists the old and new values in the pull request. The ground colors
   stay the mockup's. It never drops a set.
5. A 403 from R2 or a deploy. The session never widens a token and never tries another
   credential. It parks with the request, the response, and the token's name.
6. An invented name matches a real one. The executor changes the name and records the search.
7. Geoff declines the society sheet in the packet. Passes 1 and 2 run, and pass 3 waits for a
   sheet he approves in a `decide` document.
8. The proving run goes red for a cause outside the pass's files. The pass files it through
   `standards:log-issue`, and the conductor parks pass 4 if the cause blocks a publish.
9. The grader fails a render after two fix rounds. The pass's packet shows the failing render
   beside the mockup and asks.
10. Pennant paints a text and ground pair the check doesn't measure. The executor moves the
    pair onto a measured role. It never edits `src/lib/audit/`.
11. The home body can't be split at a rule line. The planner of pass 2 takes the nearest form
    that keeps the two properties in call 7, flags it, and goes on.
12. Pass 4 needs a change to the organization set. It raises the set's version in the same
    pull request and says so in the close packet.
13. The tool or the publish job can't read the `engine` range in call 15. The planner takes
    the narrowest range both read that excludes `0.99.0-rc.4`, and flags it.

## Rulings

Geoff approved the design packet `20261115-041501-ead5c5` on 2026-11-15 (04:19 UTC) with no notes.

- Ruled: the card block. Keep it, as one `cards` block.
- Ruled: the catalog description. "A two-color club and team look that's easy to recolor."
- Ruled: releases before the gate. Passes 2 and 3 land on review.
- Ruled: the round runs beside `tui-language`, under `conductor-pennant`.
- Ruled: the society sheet. Use it as written.

Geoff ruled one more thing on 2026-11-15, in packet `20261115-043946-a5b754` ("Make both edits"):

- Ruled: events come in the next round, and this round runs as approved. Pass 2 keeps the door
  open: the home route hands the view its lists as named members of one object (`posts` today),
  so a later round adds an events list beside the posts without changing what a theme already
  reads.

Geoff ruled again on 2026-11-15, in packet `20261115-182911-58b350` ("A page with the club's
address and meeting details"):

- Ruled: the organization set holds a contact page, with no form. Pass 3 builds it and grows
  from 110 to 120 path minutes.

## The society sheet

The catalog design says Geoff reads this before any set is written, because every set repeats
it. The places are real. The society, its people, and its history are invented.

- **Name.** The Turnagain Geographic Society. A search on 2026-11-14 found no organization by
  that name.
- **Where.** Anchorage, Alaska, named for Turnagain Arm, the branch of Cook Inlet south of the
  city.
- **Founding story.** A group of weekend map readers began meeting in 1974 to compare USGS
  quadrangles of the Chugach front range against what they had walked. They kept meeting.
- **Members.** About 140, from students to retired surveyors. Anyone can join.
- **What it does.** A monthly map night, summer field days with map and compass, a junior
  program for ages 10 to 16, and a lending shelf of topographic sheets.
- **Places it writes about.** Turnagain Arm, Knik Arm, the Chugach Mountains, the Kenai
  Peninsula, Portage Valley, and the Matanuska Valley. Each claim about them stays close to
  what a USGS map or another public source shows.
- **People.** Invented, each name searched before use. The sets name few of them, by role
  first: the president, the field-day lead, the junior program's coordinator.
- **Images.** Maps only, from the USGS and Natural Earth. The no-photo and all-photo renders
  in pass 4 use test fixtures, never the set.

## Backlog verdicts

A scoped sweep read `BACKLOG.md` at `ef9e37206`: the items tagged `#initiative:theme-garden`
and the items naming a file the round changes. Approving the design approves these edits.

| Item | Verdict | Reason |
| --- | --- | --- |
| #486 proving demos share one address | fold into pass 3 | Pennant is the second theme, and the pass edits `reference-check.mjs`. 40 minutes |
| #483 demo canonical links name `showcase.test` | fold into pass 3 | The pass edits the `buildDemo` call. 25 minutes |
| #412 an option's light value loses with no cookie | keep, with standing answer 3 | A plain `primary` change sits in the daisyUI block and doesn't hit it. Pass 4's item 6 would show it |
| #481 demos fall back to the starter overlay | reword | Pass 3 adds the kind-to-set lookup. What is left: Waymark's demo falls back until `sets/blog/` exists |
| #471 the viewer's pick test answers 500 | reword | The catalog conductor has a fix in flight; the item is cut to what that leaves |
| #485, #484, #482, #480, #413, #415, #416, #417, #419, #410, #378 | keep | Each is real and outside the round's lines |

The sweep counted 18 open items with no stamp from the last 90 days, so a full sweep is due. It
runs as a separate session and holds nothing here.

## Estimate

640 path minutes, set against the theme-garden passes' scores: G1 and G2 ran near their plans,
and the catalog pass planned 240. Pass 4 is the largest because the grader reads 26 home page
renders and 20 page-type renders, and the fix rounds follow them.

## Practice and sources

- WCAG 2.2, success criterion 1.4.3, for the 4.5:1 floor.
- The Design Tokens Community Group format, which `tokens.json` already follows.
- daisyUI 5's theme variables and CSS `color-mix()` (MDN) for the derived palette.
- The FA, Volleyball England, and the NSPCC Child Protection in Sport Unit on photos of
  children.
- SIL Open Font License 1.1 for the three typefaces.
- Cloudflare's Workers custom-domain and API-token docs for the demo step.

## Out of scope and later

- `cairn new` reading the hosted catalog and asking the `colors` question, which is what puts
  Pennant in front of a site owner.
- A `--theme` flag for `cairn new`, which the reference page already prints.
- A logo field in the site config, so a club can show its real crest.
- The `actions` menu in the navigation editor, so an editor can change the Join link.
- The other four content sets.
- A school-team theme.
- Survey, which follows this round.
