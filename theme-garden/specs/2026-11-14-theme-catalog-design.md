# Hosted theme catalog design

Status: proposed (2026-11-14), from the theme catalog brainstorm. Not yet approved.

cairn's themes and default content move out of the engine package and into a small hosted catalog.
The catalog is one JSON file and a set of archives on Cloudflare R2, at a public address. `cairn new`
reads it to ask what kind of site the owner is building, offer the themes that fit their engine
version, and lay in a theme and a believable set of starting content. Every theme release comes
with screenshots and a hosted demo. The same file holds everything the theme section of a rebuilt
cairn.pub needs, and a reference page proves it. A release reaches new sites the day it merges,
with no engine release and no new `cairn` binary. This design revises one section of the approved
theme garden design and leaves the rest standing.

## Why

The approved design ships every catalog theme inside each engine release. That ties a theme to the
engine's release schedule. Geoff expects a continuous stream of theme releases, and a hosted catalog
fits that better.

A new site also needs content that suits it. Waymark's starter posts are lessons for the owner
("Write your first post", "Add an image to a post"). A photographer or a club gets the same lessons
laid out as a blog. Geoff wants a new owner to find a believable site of the kind they asked for,
with the lessons somewhere else.

## Decided by Geoff

These came from Geoff in this brainstorm (2026-11-13 and 2026-11-14).

- The catalog is lightweight, hosted on Cloudflare, and neutral about who displays it. The Go
  installer and cairn.pub read the same information.
- The catalog holds the correct information for a theme, settled by studying other theme catalogs.
- Themes no longer need to ride in the npm package.
- A theme comes with an engine version requirement. The installer shows only compatible themes.
  cairn.pub probably offers a filter.
- Each theme comes with a demo and a screenshot, made as the theme is built.
- The work that makes cairn.pub's theme section easy to build is done now.
- cairn.pub is scrapped and rebuilt, so nothing here depends on the present site.
- Default content comes in categories by kind of site, and `cairn new` asks the kind.
- The list of kinds is settled up front so the content can be written. It is short. It is `blog`,
  `portfolio`, `docs`, `landing`, and `organization`.
- Each kind has a plain label and a good description. The `landing` kind is labeled "Product or
  event page".
- A new owner finds a believable site. The lessons live somewhere else.
- The documentation page tree is settled by looking at the best documentation templates.
- Every content set is about geography and mapping. The sets use a variety of real places, with
  invented people and organizations. One fictional geographic society appears across all of them.
- The readers, for now, are cairn.pub and the installer.
- The technical design is lightweight, streamlined, and built on current published standards that
  suit SvelteKit and Go. With two readers, it stays light and easy to change.
- Acceptance: a system the installer can use, and that cairn.pub can adopt easily when it is built.

## Goals

- `cairn new` installs a theme that the engine package doesn't carry.
- A theme or content release reaches `cairn new` with no engine release and no new binary.
- An owner is offered only themes that work with their engine version.
- An owner starts with content that suits the kind of site they asked for.
- Every theme in the catalog has screenshots and a demo a visitor can open.
- A web page on another origin can show the whole catalog from one fetch: a grid of themes, a page
  for each theme, and filters by kind and by engine version.
- Nothing about a theme is written twice. The catalog file is generated from each theme's manifest.

## Non-goals

- The design of cairn.pub's theme section: its layout, its words, and its place in the site.
  That belongs to the cairn.pub rebuild.
- Themes from outside the house, a marketplace, download counts, and ratings.
- Switching or updating the theme of a live site. The earlier design's "Kept possible" section
  still holds.
- A database, an API, or a search service. The catalog is files.
- A demo of the admin. A demo shows the public pages only.
- Signed releases. See "Trust".

## Anti-goals

These would make the work a failure even if it ran.

- A catalog that needs a service to run, or that only one of its two readers can read easily.
- A format of cairn's invention where a published standard exists.
- A new owner's first site reading as placeholder text or as a tutorial.
- `cairn new` failing because the catalog is unreachable.
- A theme in the catalog with no demo, or a demo that shows an older release than the catalog
  offers.
- A theme section that needs a second data source, or a change to the catalog, to show a theme.

## Standards the catalog uses

Each choice is one both stacks already read. These are Claude's calls.

| Need | Standard | How each side reads it |
| --- | --- | --- |
| The catalog file's shape | JSON Schema, draft 2020-12, the draft the theme manifest schema already uses | Go decodes with `encoding/json` and ignores unknown fields. A page uses `fetch` and `JSON.parse`. |
| Checksums | Subresource Integrity strings, `sha512-` and a base64 digest | The Go tool already verifies npm's digest in this form (`sha512Digests` in `fetch.go`). A browser checks it with `fetch`'s `integrity` option. |
| Versions | Semantic Versioning 2.0.0 | Both compare by SemVer precedence. |
| The engine requirement | An npm version range, limited to two forms | See "The engine requirement". |
| Archives | A gzipped tar, the format of an npm tarball | The Go tool's `extract` reads this format and refuses unsafe entries. Today it keeps only entries under `package/template/`, so it gains a parameter for the root directory. |
| Licenses | SPDX ids, as the manifest already uses | Text. |
| Reads from another origin | CORS, with `Access-Control-Allow-Origin: *` | Go doesn't need it. A page does. |
| Freshness | `Cache-Control` and `ETag` | Standard HTTP caching on both sides. |

## Where the catalog lives

The catalog is one R2 bucket on Geoff's Cloudflare account, served at a custom domain. Claude's
call on the address: `https://catalog.cairn.pub`. The `cairn.pub` zone is on the account. The bucket
has a CORS policy that allows `GET` from any origin, and its `r2.dev` address stays off. No Worker
sits in front of it.

R2 fits because a release is written once and kept. Workers static assets would need every past
archive present at every deploy.

| Path | Holds | Caching |
| --- | --- | --- |
| `/index.json` | The whole catalog | `max-age=300` |
| `/themes/<id>/<version>.tgz` | One theme release | One year, `immutable` |
| `/themes/<id>/<version>/<file>` | That release's screenshots and card image | One year, `immutable` |
| `/sets/<kind>/<version>.tgz` | One content set release | One year, `immutable` |

A release path is never overwritten. An older engine keeps resolving to the newest release that
fits it, so old releases stay.

`cairn new` reads the catalog address from a setting that a test or a proving run can change. The
publish job is first proven against a second bucket, and only then pointed at the real one.

## The catalog file

`index.json` validates against a JSON Schema kept in cairn-cms's `schema/` directory beside the
theme manifest's. The engine package already ships that directory, so a SvelteKit site that
installs the engine has the schema on disk and can generate its types from it. The schema's `$id`
is `https://cairn.pub/schemas/cairn-catalog/1.json`, the form the manifest schema uses. The rebuilt
cairn.pub serves both schemas at those addresses.

```json
{
  "$schema": "https://cairn.pub/schemas/cairn-catalog/1.json",
  "format": 1,
  "generated": "2026-11-20T18:04:00Z",
  "kinds": [
    { "id": "blog", "label": "Blog", "description": "Dated posts, newest first. For a journal, a newsletter, or news." }
  ],
  "themes": [
    {
      "id": "survey",
      "name": "Survey",
      "description": "One line an owner sees at setup.",
      "summary": "A few sentences for a catalog page.",
      "author": { "name": "glw907", "url": "https://github.com/glw907" },
      "license": "MIT",
      "repository": "https://github.com/glw907/cairn-cms",
      "kinds": ["blog", "organization"],
      "demo": "https://demo-survey.cairn.pub/",
      "card": { "url": "https://catalog.cairn.pub/themes/survey/1.0.0/card.webp", "width": 720, "height": 480 },
      "releases": [
        {
          "version": "1.0.0",
          "date": "2026-11-20",
          "notes": "First release.",
          "engine": ">=0.99.0-0",
          "contract": 1,
          "url": "https://catalog.cairn.pub/themes/survey/1.0.0.tgz",
          "integrity": "sha512-...",
          "size": 412000,
          "colorModes": { "light": "survey-light", "dark": "survey-dark" },
          "options": [],
          "screenshots": [
            { "url": "https://catalog.cairn.pub/themes/survey/1.0.0/light.png", "shows": "Home page, light", "width": 1440, "height": 960 }
          ]
        }
      ]
    }
  ],
  "sets": [
    {
      "kind": "blog",
      "releases": [
        { "version": "1.0.0", "date": "2026-11-20", "notes": "First release.", "engine": ">=0.99.0-0", "url": "https://catalog.cairn.pub/sets/blog/1.0.0.tgz", "integrity": "sha512-...", "size": 900000 }
      ]
    }
  ]
}
```

Those values are examples. The rules for the file:

- `format` is an integer. Adding a field never raises it, and both readers ignore fields they
  don't know. It rises only when an old reader would misread the file.
- `releases` is newest first. A theme's top-level fields come from its newest release's manifest.
- A theme release and a set release share `version`, `date`, `notes`, `engine`, `url`,
  `integrity`, and `size` in bytes. A theme release adds `contract`, `colorModes`, `options`,
  `screenshots`, and `fonts`, copied from that release's manifest.
- `notes` is one line on what the release changed. The publish job refuses a release without it.
- `contract` is the theme contract's number. A set has none, because a set is content, and the
  set's `engine` range already says which engines read it.
- `demo`, `card`, and at least one screenshot are required. The schema refuses a theme without
  them.
- `card` is a small image for a grid, 720 by 480 in WebP. The publish job makes it from the first
  screenshot. The earlier design fixes that screenshot at 1440 by 960, the same 3:2 shape.
- Every image carries its width and height, so a page can hold its place before the image loads.
  The `shows` text of a screenshot is its alternative text.
- Every URL is absolute, so a page needs no knowledge of the layout.

## What cairn.pub's theme section gets

cairn.pub is being rebuilt, so this design fixes only what its theme section can count on. These
are Claude's calls.

| The section shows | It comes from |
| --- | --- |
| A grid of themes | `themes`, each with `name`, `description`, `card`, and `kinds` |
| A filter by kind, with a label and a sentence for each | `kinds` |
| A filter by engine version | Each release's `engine`, compared with a version the visitor picks or the site supplies |
| A page for a theme | `summary`, every screenshot, the options with their labels, `colorModes`, `fonts`, `license`, `author`, and `repository` |
| A link to try the theme | `demo` |
| A version history | `releases`, each with `version`, `date`, `notes`, and `engine` |
| The command that installs it | The theme's `id`, as `cairn new --theme <id>` |

The section can read the file while the site builds, or in the visitor's browser. The CORS policy
allows the second, and the five-minute cache keeps either one current.

The proof is a reference page, kept in cairn-cms and run as a check. It is one plain HTML file with
no library. From one fetch of the catalog address it shows the grid, a theme's page, the kind
filter, and the engine filter. If that page needs something the file lacks, the file is wrong, and
it changes before cairn.pub is built. The rebuild can take the page as its starting point.

## Manifest changes

The catalog file is generated from each theme's `cairn-theme.json`. The manifest gains these
fields, and the contract-1 schema is amended in place, since only house themes use it and cairn is
before 1.0 (Claude's call).

| Field | Required | Content |
| --- | --- | --- |
| `engine` | Yes | The engine versions the theme works with. See the next section. |
| `kinds` | Yes | One to three kind ids. The first is the kind the theme was designed for. |
| `notes` | Yes | One line on what this version changed, at most 200 characters. |
| `summary` | No | Up to 300 characters for a catalog page. |
| `repository` | No | The URL of the theme's source. |

### The engine requirement

`engine` is an npm version range in one of two forms: `>=1.2.0`, or `>=1.2.0 <2.0.0`. The schema
allows only those. Any npm range library reads them. The Go tool needs only a SemVer comparison and
no range parser. `golang.org/x/mod/semver` supplies the comparison, and it is a new dependency for
the tool.

A reader compares by plain SemVer precedence, where a prerelease sorts below its release. The
engine is at `0.99.0-rc.4` today, and proving runs use `0.99.0-dev` snapshots. Both sort below
`0.99.0`. So while the engine is in prerelease, a house theme declares `>=0.99.0-0`. That is npm's
usual way to admit every prerelease of a version, and plain precedence reads it correctly. A
JavaScript reader that uses the `semver` package passes `includePrerelease`.

The author declares the minimum. The upper bound is for a recorded exception and is normally
absent. It isn't needed because of one rule, enforced in CI: a theme's newest published release
always equals its source on `main`. cairn-cms CI checks the themes on `main` against the engine on
`main`. Today that check takes its list from `templates/catalog.json`, which this design retires,
so the check changes to read every directory under `themes/`. When an engine release is cut, each
theme's newest release is then known to work with it.

A content set has a small manifest too. It carries `engine` and `notes` in the same way.

### Releases that were never built together

`cairn new` picks the newest theme release and the newest set release that each fit the engine. CI
builds only the newest of each together. On an older engine the pair can be one that CI never
built. This design accepts that (Claude's call). Every set uses the one content model, and the
conformance set already proves each theme against that model. A matrix of every pair would cost
more than the risk warrants with house themes only.

## Kinds

The list is closed at five. It follows what purpose lists look like in other catalogs: the closed
ones run five to nine entries (Carrd 5, Astro 5, Ghost 8, WordPress.org 9), and long lists come from
free tagging (`../research/site-kinds.md`). WordPress.org caps a theme at three subjects, and this
design takes the same cap.

The labels and descriptions are data in the catalog file, so both readers show the same words. The
wording here is a draft to finish against the editor-copy standard. Geoff approved the fourth
label and its description.

| Id | Label | Description |
| --- | --- | --- |
| `blog` | Blog | Dated posts, newest first. For a journal, a newsletter, or news. |
| `portfolio` | Portfolio | Collections of your work, mostly images. For a photographer, a designer, or a maker. |
| `docs` | Documentation | Pages in a sidebar, read in order. For a manual, a handbook, or a guide. |
| `landing` | Product or event page | One long home page in sections (what it is, what it offers, pricing, questions) that leads to one action. For a product, a project, or an event. |
| `organization` | Organization | Several pages about a group, with a news section. For a club, a team, a nonprofit, or a small business. |

Two rules keep the list honest (Claude's calls). A kind is offered only when a content set for it
exists. A kind may not need a content shape other kinds lack: every set uses the one content model
the earlier design fixed, so every theme renders every set.

### The home page

This part waits on Geoff's answer.

The template's home page is always the newest posts (`src/routes/(site)/+page.server.ts`). That
suits a blog. A product page, a portfolio, and an organization site each need a home page that
isn't a list of posts, and no content set can change a route.

Claude recommends one small template change. When the content holds a page marked as the home page,
the home route shows that page, and otherwise it shows the newest posts. The change is in the
template's route, which a site owns, and the engine library doesn't change. It still needs a scope
ruling before a pass builds it. The other choice is to leave the home page alone, and then those
three sets open on a post list with their pages in the menu.

## Content sets

A set is a tree of files laid over a new site. It holds `src/content/` and `static/images/`, the
shape the starter overlay already has in `scripts/build/starter-overlay/`. It also holds the whole
of `src/site/site.config.yaml`, which carries the menus, the footer, and the tag vocabulary. Today
that file comes from the template. Its images are committed files under `static/`, so laying in a
set needs no upload.

The Go tool never merges YAML. It replaces the template's file with the set's and then makes the
same two edits it makes today: it writes the owner's site name over the literal `siteName: Waymark`,
and it writes the neutral description, "A new site built with cairn." The publish job refuses a set
whose file lacks that literal. These are Claude's calls.

One fictional geographic society runs through all five sets. A sketch, Claude's call:

| Kind | The site |
| --- | --- |
| `organization` | The society's website |
| `blog` | A member's field journal |
| `portfolio` | The society's map collection |
| `landing` | The society's atlas, or its annual expedition |
| `docs` | The society's field handbook |

Rules for the writing, also Claude's calls:

- A short sheet on the society comes first: its name, founding story, members, and places. Geoff
  reads it before any set is written, because every set repeats it.
- The places are real. The people and organizations are invented, and each invented name is
  searched before use so it doesn't match a real one.
- The writing stays close to what a map shows. It makes no claim about a real place that a
  public source doesn't support.
- Images are maps only, from public-domain sources such as the USGS and Natural Earth.
  OpenStreetMap is out, because its license needs attribution on every page. Each image's source
  and license is recorded in the set's manifest.

The lessons in Waymark's starter posts leave the starter content. Where they go is the cairn-setup
initiative's decision. The editor guide likely covers most of them.

### The documentation set

Documentation needs a page tree. A study of 18 documentation systems found two families: a tree
derived from folders, and a tree kept in one central file (`../research/docs-page-trees.md`).
cairn's content is flat, and its menus are central trees in `site.config.yaml`. The admin reorders
the primary menu by dragging. So the central family fits. The documentation set is flat pages plus
a `docs` menu in `site.config.yaml`.

That needs engine work that belongs to Topo, the documentation template on the roadmap: a second
menu the admin can edit, a deeper nesting limit, and previous and next links from the menu's order.
It also needs a scope ruling. So the documentation set is written last, after Topo's design, and
the catalog doesn't list the kind until its set is published.

## Demos

Each theme has one demo, a real build of the theme over the content set of its first kind. It
shows the public pages only and has no admin. A demo always shows the theme's newest release.

A demo is static files on Workers static assets, with no script. Claude's call on the address is
one name per theme directly under cairn.pub, such as `demo-survey.cairn.pub`. Cloudflare's standard
certificate covers one level under the zone, so a name like `survey.demo.cairn.pub` would need a
paid certificate.

The publish job deploys the demo before it adds the release to the catalog file. A release whose
demo fails to deploy isn't published. No theme is finished until its screenshots and its demo
exist, and that holds for Survey and for each theme after it.

## Publishing

Theme sources stay in cairn-cms at `themes/<id>/`, where the check, the viewer, and the conformance
set already are. Content sets live beside them at `sets/<kind>/`. A new repository would mean
publishing that tooling, which two readers don't justify (Claude's call).

A job on cairn-cms's `main` publishes. For each theme or set whose version isn't in the catalog:

1. It runs the theme check, and builds the theme against every set.
2. It builds the archive. A theme's archive holds the files for `src/theme/`, with
   `theme-names.ts` already generated. It also holds the built text for the marked block in
   `src/app.html` that names the theme's color modes.
3. It makes the card image, then uploads the archive and the images, refusing to replace an
   existing path.
4. For a theme, it builds and deploys the demo.
5. It adds the release to the catalog file, validates the file against the schema, and uploads it
   last. The file never names an archive or a demo that isn't there.

The Go tool copies the theme's files and writes the built text between the two markers in
`src/app.html`. It runs no theme logic, and an archive never replaces `app.html` whole, so an older
theme release still works with a newer engine's file.

A change under `themes/<id>/` or `sets/<kind>/` with no version rise fails CI. The job runs one at
a time.

## What `cairn new` does

1. It fetches the engine template from npm, as now, and then the catalog file.
2. It keeps the newest release of each theme and set whose `engine` admits the engine version. For
   a theme, the `contract` must also equal the one in the packaged Waymark's manifest, which is
   how the tool learns what the engine supports.
3. It asks the kind of site, showing each kind's label and description. `--kind <id>` answers it.
4. It asks the theme. Themes that declare the kind come first, and the rest follow, since every
   theme renders every set. `--theme <id>` answers it. The color-mode and option questions follow
   as the earlier design describes.
5. It downloads the theme and set archives and verifies each against its `integrity`.
6. Only then does it write the site: the engine's template, with the chosen theme and set in place
   of the packaged ones.
7. It records the theme, the set, their versions, their addresses, and their digests in the lock
   file, and in the state a resumed run reads.

A resumed run doesn't read the catalog file. It downloads the recorded addresses and checks the
recorded digests, the way a resumed run already fetches the recorded engine version.

The engine package keeps Waymark and the blog set. They are what `cairn new` uses when the catalog
can't be read, and the template stays a complete site for Cloudflare's Deploy button.

The color-mode question, the option questions, and the lock file are step 4 of the earlier design,
and none of them is built yet. That step and this design's installer work are planned as one piece
of work (Claude's call), because both rewrite the same part of the tool.

## Failure behavior

| What happens | What `cairn new` does |
| --- | --- |
| The catalog can't be fetched, isn't valid, or has a `format` the tool doesn't know | Continues with the packaged Waymark and blog set, and says in one line why the choices are short. For an unknown `format`, it says to update `cairn`. |
| The same, and `--theme` or `--kind` named something the package doesn't hold | Exits nonzero before anything is created. An agent never gets a different theme than it asked for. |
| `--theme` names a theme with no release for this engine | Exits nonzero and says which engine versions the theme needs. |
| An archive fails its digest | Stops, writes nothing, and never retries. This is the existing rule for the engine tarball. |
| An archive can't be downloaded after the owner chose it | Stops before anything is written and says the run can be repeated. It doesn't fall back, because the owner chose. |
| A resumed run can't download a recorded archive | Stops and says so. It never changes the theme or the set. |
| An archive holds an unsafe entry | Refused by the existing `extract` rules. |

## Limits

These are Claude's calls.

| Limit | Value |
| --- | --- |
| Catalog file | 2 MiB read limit, and the 15 second timeout the npm metadata fetch uses |
| Theme archive | 8 MiB |
| Set archive | 8 MiB, with each image at most 400 KB |
| Card image | 100 KB |
| Archive download | 2 minute timeout, the same as the engine download |
| Kinds per theme | 1 to 3 |
| Kind description | At most 160 characters |
| Theme `summary` | At most 300 characters |
| Release `notes` | At most 200 characters |

## Trust

The catalog file and the archives come from one origin over HTTPS. The digest catches a corrupted
or swapped archive. It doesn't protect against someone who can write to the bucket, because they
could change the file and the archive together. That is the same trust `cairn new` places in the
npm registry today. Signing waits for a real need, such as outside themes.

Only the publish job writes to the bucket, with an R2 token scoped to it. The token is a new
long-lived secret, so it starts in the workstation's secret store and reaches CI from there. The
demo deploys need a second token, scoped to the demo Workers, that follows the same rule.

## What changes in the earlier design

This design replaces the "Catalog and hosting" section of `2026-11-08-theme-garden-design.md` in
these ways. Everything else in that design stands.

- A theme is no longer tied to the engine release it ships in. Only Waymark ships in the package.
- `templates/catalog.json` and its `source` field retire. The hosted file is the catalog, and the
  packaged fallback is Waymark alone.
- The pack script composes one template, not one per catalog entry.
- "Per-theme content" stays out of scope. A set belongs to a kind, never to a theme.
- The lock file, which that design describes and no pass has built, also records the content set,
  both addresses, and both digests.
- Its step 4, setup's theme and option questions, is planned together with this design's installer
  work.
- Each theme gains a hosted demo and a card image, which that design didn't have.

The Survey theme's plan builds it at `themes/survey/`, which still holds. Survey then reaches
`cairn new` through the catalog and not through an engine release.

## Consequences for cairn-setup

- The starter set, which cairn-setup owns, becomes the blog set and is rewritten as a believable
  site. Its lessons need a new home.
- The questions form gains the kind question before the theme question.
- The scaffold's theme reader moves from the template's `catalog.json` to the hosted file.
- `site.config.yaml` comes from the content set and no longer from the template.

The cairn-setup conductor reads this section before a `cairn new` task touches one of these.

## Order of work

1. The catalog schema, the manifest fields, the bucket, the publish job with its demo step, and
   the reference page, proven by publishing Waymark.
2. `cairn new` reading the catalog, with every row of the failure table, together with the earlier
   design's step 4.
3. The society sheet, then the blog, portfolio, organization, and product-page sets, which can be
   written in parallel with step 2.
4. The documentation set, after Topo's design.

## Left out now

Each of these is a field or a feature that can be added later without changing `format`: a free
list of features, credit for the original of a ported theme, screenshots of a theme on every kind,
and a demo for each kind.

## Left to the builder

- The schema's exact text, and the root directory name inside an archive.
- How the template marks which of its files belong to its content set, so that replacing them is
  exact.
- How the publish job proves a declared engine minimum is honest.
- How the template builds as public pages only for a demo.
- The R2 bucket's name.
- The name of the setting that holds the catalog address.
- The kind question's place on the setup screen and its copy.
- The pass split, within the order of work.

## What done looks like

Each of these can fail. Checks 8 to 10 cover four kinds at first, and the fifth when the
documentation set is published. Checks 1 to 4 run against the real bucket and the publish job, not
a stand-in.

1. `cairn new` installs Survey from an engine package whose tarball is shown to hold no Survey
   file. The site builds and deploys. Its light and dark toggle works, which proves the
   `app.html` block names Survey's color modes. Its lock file names Survey's version and digest.
2. A new theme release is published with no engine release and no new `cairn` binary. After the
   catalog file's five-minute cache passes, `cairn new` lists it, downloads that version, and
   records that version in the lock file.
3. A theme whose newest release doesn't admit the engine version is offered at its older release
   that does. A theme with no release that fits isn't listed, and naming it with `--theme` exits
   nonzero with the versions it needs. The same holds on an `rc` engine and a `dev` snapshot.
4. A theme archive altered after publishing is refused, and so is a set archive. In each case the
   target folder is left empty and no repository or Cloudflare resource has been created.
5. `cairn new` finishes on Waymark and the blog set, and prints why the list is short, in each of
   these cases: the address doesn't resolve, the file isn't JSON, the file fails the schema, the
   `format` is unknown, the response hangs past the timeout, and the file passes the size limit.
   In each case, `--theme survey` exits nonzero and creates nothing.
6. The reference page, served from another origin, fetches the real catalog address and nothing
   else but images. It shows every row of the table in "What cairn.pub's theme section gets": the
   grid, the kind filter, the engine filter, a theme's page, the demo link, the version history,
   and the install command. Choosing a kind or an engine version changes which themes show. The
   check fails when a card, a screenshot, or a demo address doesn't return 200. It runs on a
   schedule, so a network fault never blocks a pull request.
7. Each theme's demo address serves that theme's newest release over the set of its first kind.
   The check reads the version from the demo's page and compares it with the catalog file.
8. The catalog holds one content set for each kind it lists, and lists no kind without one. Each
   set's published archive matches its digest.
9. Every catalog theme builds every set from the published archives with no theme-check failure.
   If Geoff approves the home page change, each set's home page is the one its kind describes.
10. `cairn new` asks the kind and lays in that kind's set. Two runs with different kinds both
    build. Each site holds only its set's content files, with none left from the packaged blog
    set, and its menus are the set's.
