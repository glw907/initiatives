# Theme garden design

Status: proposed (2026-11-08), from the theme-garden brainstorm. Not yet approved.

## Intent

cairn needs one standard way to package, store, and host a public theme, and to lay it into a new
site at setup. The catalog holds house themes only. It starts with Waymark and Survey, and gains one
theme for each site Geoff rebuilds. Each new theme comes from a design pass and is finished before
its site is rebuilt. The rebuild then takes it from the catalog at setup, like any new site. A naive
builder never builds a theme (907-rebuild planning miss 16).

Browsing themes on cairn.pub comes later. This design leaves that page something to read: a catalog
with a manifest, tokens, and screenshots for each theme.

## Decided by Geoff

These came from Geoff, in the 2026-11-08 hand-off (`cairn-setup/research/handoff-theme-garden.md`)
or in this brainstorm.

- One content model for every theme: the same collections (posts, pages, fragments, authors), the
  same front-matter fields, and the same page paths. A theme may not require content of its own.
- Two sets of standard content. The starter set goes into every new site, and the cairn-setup
  initiative owns it. The conformance set is for theme authors and CI and is never shown to owners.
- Conformance pages show every markdown construct, one page per layer.
- Waymark's catalog entry says it is an intentionally neutral, easy-to-edit default.
- The catalog holds house themes. Two start it, and one is added before each site rebuild.
- A theme viewer exists as an internal developer tool. Theme developers outside the house may use it
  later.
- A site's copy of its theme is the site's own after setup, unless best practice dictates otherwise.
  The research found no reason to change that.
- Switching a live site's theme is not in phase one. The design must keep it possible, and switching
  needs further research later, with a target set then.
- At setup, an owner picks a light, dark, or system default and the theme's options: an accent from
  the theme's set, a color scheme, a font pairing, or another option themes commonly offer. Options
  are picked at setup only.
- The cost of converting Waymark to the new token format is acceptable. Waymark and Survey both
  change to fit the new system.
- The 907.life rerun waits for Survey to be in the catalog.
- Waymark stays optionless. Its goal is to be a vanilla build theme. Survey's design pass chooses
  the first real options, and the check's tests use a small fixture theme with options, so the
  option machinery is proven before Survey exists.
- Acceptance: Geoff runs a test build with Waymark, takes it down, then runs another with Survey.

## Goals

- A theme has one documented shape. A check can prove a theme fits it.
- `cairn new` fetches any catalog theme by id, applies the owner's options, and writes a site that
  builds and deploys.
- Every catalog theme renders the starter set and the conformance set unchanged.
- A theme's metadata ships inside the theme, in machine-readable files on published standards, each
  with a JSON Schema.
- A theme author, human or agent, can render any page under any theme, option, and width, and get a
  machine-readable verdict from the check.

## Non-goals

- Browsing or comparing themes on cairn.pub. That comes later and reads the catalog this design
  defines.
- Switching a live site's theme, updating a site's theme copy, and changing options after setup. The
  design keeps each possible (see "Kept possible").
- Themes from outside the house: submission, review, and an external source kind.
- An admin screen for theme options. It would be new engine surface with no site asking for it.
- A free-form brand color or font field. Every option is a closed set of named values.

## Anti-goals

These would make the work a failure even if it ran (Geoff, 2026-11-08):

- Significant redevelopment of the theme structure or packaging later. The structure is settled
  now, in the pre-1.0 window. Its versioned contract and the catalog's `source` field leave room
  for what comes next.
- A setup or theme workflow that is hard for agents to work with.
- Theme metadata that is scattered, outside the theme, or in a format of cairn's own invention.

## Scope verdict on BACKLOG #361

`cairn-judging-scope`, 2026-11-08. The first engine pass records it in
`docs/internal/engine-rulings.md`.

- **(a) Setup asks for the theme first, or takes `--theme`:** accept. Choosing which template
  `cairn new` copies belongs to the operator's tool, not the engine surface.
- **(b) A theme declares its options in a manifest:** accept, reshaped. The manifest is static data
  that only `cairn new` reads, at scaffold time. It never becomes a runtime API, an admin theme
  switcher, or an npm export. The free-form brand color prompt retires.
- **The `app.html` cookie regex:** accept. It is generated from the theme's names, so a theme never
  edits a file outside its directory.
- **Out of scope:** a theme shipped as an npm dependency that updates in place, a marketplace for
  outside themes, and per-theme content or directives.

## Prior art

Two research reports are in `../research/`: `prior-art-theme-packaging.md` (WordPress, Ghost,
Shopify, Hugo, Jekyll, Gatsby, Astro, Eleventy, shadcn, Drupal, Copier, and others) and
`prior-art-theme-switching.md`. The design follows these lessons:

1. A theme never owns a content feature. WordPress's "plugin territory" rule and Hugo's missing
   shortcode failures both strand content on a switch.
2. Record what was installed: source, version, option answers, and file hashes. Copier and Drupal
   show that a copy with no record can never be updated or compared.
3. Store options by key, not only as written values. WordPress style variations stop following the
   theme once copied, and Ghost loses a value when a key is renamed. Option keys are a contract.
4. Keep the owner's customizations in a layer outside the theme. WordPress's per-theme Additional CSS
   disappears on a switch.
5. Menu slots belong to the engine, not the theme. Theme-declared slots drop their assignments on a
   switch in WordPress, Drupal, and Ghost.
6. Themes die at framework majors (Gatsby). Shipping every catalog theme with the engine release it
   was tested on prevents that.
7. Pin and verify. Jekyll's `remote_theme` defaults to HEAD, and a checksum turns a pin into a
   guarantee. The `cairn new` fetch already verifies npm's integrity digest.
8. Machine validation before acceptance pays off: Ghost's gscan and Shopify's Theme Check.

## The theme contract, version 1

A theme is look-only. It owns how the site looks and how each fixed piece of content renders. It
never owns what content exists.

### What moves out of the theme

Waymark's `src/theme/` holds site-owned files today. They move to a new site-owned directory,
`src/site/` (the directory name is Claude's call):

- `cairn.config.ts` (the adapter, concepts, backend, media, navLayout). `vite.config.ts` reads it at
  the new path.
- `site-config.ts` and `site.config.yaml` (site name, description, menus, topics, tidy settings).
- The directive vocabulary: each directive's name and fields, which move to the chassis rather than
  `src/site/`. The theme supplies only how a directive renders (see "Directives").

Menus use the fixed slots the engine names, `primary` and `footer`. A theme can't declare a slot.

### What a theme directory holds

A catalog theme lives at `themes/<id>/` in cairn-cms. Setup copies it to `src/theme/` in a new site.

| Path | Role |
| --- | --- |
| `cairn-theme.json` | The manifest. |
| `tokens/tokens.json` | Every color, font, size, space, radius, and motion value, in the W3C Design Tokens format (2025.10). The one source of the theme's values. |
| `tokens/resolver.json` | The Design Tokens Resolver module document. One modifier is the color mode (`light`, `dark`), and each theme option is another modifier. |
| `theme.css` | The built base sheet: the two daisyUI theme blocks and the `@theme` scale, generated from the tokens, plus the theme's hand-written rules. |
| `options/<key>/<value>.css` | One built sheet per option value, generated from the resolver. |
| `site.css` | The reading column and the figure-placement rules, as today. |
| `components/` | `SiteHeader.svelte`, `SiteFooter.svelte`, `ArticleView.svelte`, `EntryRow.svelte`, with the props the contract fixes. |
| `directives/` | The theme's renderers for the fixed directive vocabulary, and their islands. |
| `icons.ts` | The theme's icon glyphs. |
| `fonts/` | Self-hosted font files for every pairing the theme offers. |
| `screenshots/` | The catalog images (see "Limits"). Kept in the catalog, never copied into a site. |

A theme imports nothing outside its directory except the chassis, through `#chassis`. The light and
dark daisyUI theme names come from the manifest. The `app.html` cookie regex and `theme-names.ts`
are generated from them.

Whether the hand-written rules stay in `theme.css` or move to a separate sheet that `theme.css`
imports is left to the builder. Either way, the token values come only from the build.

### Directives

The standard vocabulary is the set content uses today, with the fields each takes. Waymark's
`markdown-blocks.ts` defines nine blocks: alert, banner, callout (whose `points` slot is the
takeaway list), cta, faq, icon, micro-cta, pull-quote, and video. The engine renders figure and
include itself (`src/lib/render/`). None is dropped or renamed, so no content changes. Content may
use any of them under any theme.

Claude's call: the chassis owns the standard vocabulary, read-only to both themes and sites. It
carries a default renderer for each block, producing documented markup with stable class names. A
theme styles that markup, and it may replace a renderer with its own, provided it accepts the same
fields. A theme can't add, drop, or rename a directive. The check covers the standard vocabulary and
fails a theme that leaves one of its directives unrendered or unstyled.

A developer may still add a site-specific directive, which is site functionality. It lives in
`src/site/` with its own renderer and styles, so a theme switch leaves it working. Themes render
only the standard vocabulary, and the check doesn't see a site's extra directives.

### Components

The four components keep their roles. The contract fixes each component's props and the `page.data`
fields it reads, and the check renders each one against the standard content. The builder writes
the prop list from Waymark's components as they stand.

### Tokens

The chassis owns the reading-scale names, such as `--text-step--2` through `--text-step-5`, and the
`--cairn-*` roles. A theme maps its values onto those names. It never imports its own `@theme`
scale over them (builder A's friction item 3). The contract lists every token name a theme must
define. Two more roles join the list: `--cairn-eyebrow-case` and a scroll-cue role (builder A's
friction items 5 and 9).

## The manifest, `cairn-theme.json`

The manifest names its schema with `$schema`, the way WordPress's `theme.json` and shadcn's
`registry-item.json` do. The schemas ship in the engine package's `schema/` directory, which the
package already publishes. The check always validates against that bundled copy and never fetches.
The `$schema` URL serves editors and outside readers: cairn.pub publishes each schema at
`https://cairn.pub/schemas/<name>/<contract>.json`, a cairn-pub task (Claude's call).

| Field | Content |
| --- | --- |
| `$schema` | The manifest schema's URL, versioned by contract. |
| `id` | Stable id, matching the directory name. |
| `name` | Display name. |
| `description` | One line an owner sees at setup. At most 60 characters, because setup's summary prints it beside the theme name (cairn-setup planner, 2026-11-08). |
| `version` | Semver for the theme itself. |
| `license` | SPDX id. |
| `author` | Name and URL. |
| `contract` | The theme-contract major version it targets, `1` today. |
| `colorModes` | The daisyUI theme names for `light` and `dark`. |
| `options` | Up to four, each with `key`, an owner-facing `label`, a `values` list (`value`, `label`), and a `default`. Each key matches a resolver modifier, and each value matches one of its contexts. |
| `fonts` | Each family: name, license (SPDX), source URL, and the files it ships. |
| `screenshots` | Paths and what each shows. |
| `derivedFrom` | Optional. The design system a theme was built from, as a repository and a commit. Survey's theme records `glw907/survey` here. |

A theme may declare zero options. Then setup asks only the color-mode question.

Waymark's description is the cairn-setup copy deck's: "An intentionally neutral look that's easy to
edit."

An option key is a contract once a theme ships. Renaming or removing one is a breaking change to the
theme. The manifest schema records that, and a later update or switch matches options by key.

## Catalog and hosting

House themes live in cairn-cms under `themes/`, and each engine release ships every catalog theme.
That builds on the cairn-setup spec's section 2, at initiatives commit `f69a37c` or later:

- `templates/catalog.json` is the source catalog. Its entries keep `{ id, name, description, path }`
  and gain `source`, which is `"engine"` for every house theme. An outside git source later is a new
  value, not a restructure. The `cairn new` catalog reader already ignores fields it doesn't know.
- The base site is the showcase with its `src/theme/` taken out. Today
  `scripts/build/emit-template.mjs` copies `examples/showcase` to `templates/waymark/` ("the
  showcase is the single source", Reversal 2), and that stays true for everything but the theme.
  `themes/` becomes the single source for themes (Claude's call).
- One lay-in step copies `themes/<id>/` into a site tree's `src/theme/`, minus `screenshots/`. The
  showcase runs it before dev and build to take `themes/waymark/`, so its `src/theme/` is generated
  and no longer committed. The emit, the pack, and the scaffold use the same step, so a theme reaches
  every channel by one code path.
- The pack script (`scripts/build/pack-engine-template.mjs`, cairn-setup T1.2) composes each entry
  as the base site plus that entry's theme laid in. Today it composes from `templates/waymark/`.
- `templates/waymark/` stays a complete site, because Cloudflare's Deploy button reads it. It is the
  base site with `themes/waymark/` laid in, emitted as now.
- The fetch, the integrity check, and the exact-version pin are the cairn-setup spec's, unchanged. A
  theme is tied to the engine release it ships in, so a new theme rides a release. That release
  waits on the release gates the tooling brainstorm is designing (cairn-setup planner, 2026-11-08),
  and a release candidate counts as a release. The acceptance builds run on the first release, or
  release candidate, that carries both themes. This plan holds no release work of its own.

A catalog theme passes the theme check in cairn-cms CI before a release can cut.

## Setup

These are additions to `cairn new`, each landing after the catalog holds a second theme.

1. The theme question appears when the catalog has more than one entry, as the cairn-setup design
   already says. `--theme <id>` answers it for an agent.
2. Setup always asks for the color-mode default: light, dark, or follow the system. `--color-mode`
   answers it.
3. Setup asks each of the chosen theme's options, in manifest order, with its default selected.
   `--theme-option <key>=<value>` answers one. Pressing Enter through them gives the designer's
   default look.
4. The scaffold copies the theme to `src/theme/`, leaving out `screenshots/`.
5. It writes `src/site/theme-options.css` by concatenating the chosen `options/<key>/<value>.css`
   sheets and the color-mode default. The chassis links it after the theme's sheets and before the
   owner's overrides. Setup only copies built CSS, so the Go tool needs no Design Tokens logic.
6. It writes an empty `src/site/overrides.css`, the owner's layer, which the chassis links last. A
   later theme switch leaves it alone.
7. It writes the lock, `src/content/.cairn/theme-lock.json`, a separate file (it never joins
   `site-facts.json`, which the engine regenerates). The lock holds the theme id, theme version,
   engine version, contract version, the color-mode default, each option by key, and a sha256 for
   every file copied into `src/theme/`.

The planner confirms the option questions and their summary rows are additive form fields and copy
in its design, with no screen rework (cairn-setup planner, 2026-11-08).

## The viewer

The viewer is a developer tool in cairn-cms. It runs the chassis with the standard content and
loads any theme directory, whether a catalog theme or a theme in progress. It reads themes through
the same catalog and manifest `cairn new` reads, with no house-only paths, so it can be published to
outside theme developers later.

In interactive mode it serves a page list (every starter and conformance page), a theme picker, an
option and color-mode control, and a width control with the five bar widths (320, 390, 768, 1440,
2560). Editing a theme's files updates the page live, and token edits rebuild the generated CSS.

In headless mode it saves a screenshot of any page, theme, option set, color mode, and width, and
prints a JSON list of what it wrote. The catalog screenshots come from this mode, and so will the
later cairn.pub browsing page's previews.

It replaces the template's `/styleguide` route as the place to see every directive under a theme.
Whether the `/styleguide` route then retires is left to the builder, along with whether the viewer
grows out of the showcase or is a separate app.

## The theme check

The check takes a theme directory and returns a verdict. `--json` prints each failure with a file, a
rule id, and a message. It fails when:

- the manifest doesn't validate against its schema, or its contract version isn't one the engine
  supports;
- the tokens or resolver don't validate, or a resolver modifier has no matching manifest option, or
  the reverse;
- the directory holds a path the contract doesn't list, or lacks one it requires;
- a required token name is undefined in any color mode or option value;
- any starter or conformance page fails to build or render under any option value and color mode;
- a directive renders unstyled, judged by the documented class list;
- `cairn-audit`'s public rules (`theme-contrast`, `theme-conformance`, `public-literals`) report a
  finding. They run at blocking tier for a catalog theme. The check also lists the files and daisyUI
  blocks the audit measured, so zero findings can't mean "nothing measured" (builder A's friction
  item 8);
- a font file lacks a license entry, or anything in the theme loads from an external host.

The check runs in cairn-cms CI on every catalog theme and in the viewer on demand. Whether it is a
node script in cairn-cms first and a `cairn theme check` command later is left to the builder. The
contract above is what it checks.

## Standard content

The starter set is cairn-setup's (its T4.1 starter overlay, emitted into
`templates/waymark/src/content/**`). The garden reads it and doesn't change it.

The conformance set lives in cairn-cms outside `templates/` and outside the starter overlay
directory, so it never reaches a site (cairn-setup planner, 2026-11-08). It holds the hostile cases
from the setup design's "Starter content" section:

- three or more archive pages with a short last page, and a child page
- the 404 and error pages, and the feeds
- many topics, long titles and unbroken strings, a post with no title, posts with no image and
  image-only posts, and a draft that must stay hidden
- non-ASCII and right-to-left text
- every directive empty, long, and nested, and the fragments
- one page per markdown layer: CommonMark blocks, CommonMark inlines, GFM (tables, task lists,
  strikethrough, extended autolinks, footnotes), cairn's directives, and the raw HTML the sanitizer
  keeps with one tag it strips

The `commonmark-spec` npm package's examples can seed the CommonMark pages. All assets ship in the
set, with no hot-linked image.

## Limits

These numbers are Claude's calls unless marked otherwise.

| Limit | Value |
| --- | --- |
| Options setup asks per theme | 0 to 4 |
| Values per option | 2 to 8 |
| Description | At most 60 characters, one line (cairn-setup planner) |
| Theme id | `^[a-z][a-z0-9-]{1,31}$` |
| Screenshots | 1440 by 960 (3:2), light and dark, plus one at 390 wide, all PNG from the viewer's headless mode |
| Font files | woff2 only, at most 400 KB in total per font pairing |
| Viewer widths | 320, 390, 768, 1440, 2560 (the family's five-viewport bar) |

## Failure behavior

- An unknown `--theme` id or an unknown option key or value: setup lists the valid ids or values and
  exits nonzero before anything is created.
- A catalog theme whose contract version the engine doesn't support: the release can't cut, because
  the check fails in CI. Setup never meets one.
- An integrity mismatch on the fetched tarball: the cairn-setup spec's rule applies, a failure and
  never a retry.
- A theme that fails the check: CI fails, and the JSON report names each file and rule.
- An owner who edits `src/theme/` after setup: nothing fails. The lock's hashes let a later command
  tell edited files from untouched ones.

## Order of work

1. **Contract and tooling.** The engine pass moves the site-owned files out of the theme, fixes the
   directive vocabulary with chassis defaults, generates the cookie regex, and adds the two token
   roles. It also writes the manifest and token schemas, the tokens build, the conformance set, the
   check, and the viewer, and records the #361 ruling.
2. **Waymark's port.** Waymark moves to `themes/waymark/`, converted to tokens and a resolver with a
   manifest. Its renders before and after must be glance-indistinguishable in the viewer at all five
   widths. Waymark is the proof that the contract, the check, and the viewer work. It declares no
   options (Geoff, 2026-11-08).
3. **Survey's design pass.** Survey's cairn theme is built in `themes/survey/` from
   `glw907/survey`'s `tokens.json`, under the visual-fidelity process with Geoff's eye on it. The
   design system stays in `glw907/survey` as the source. The naive builder's version doesn't carry
   forward.

   Claude's call on how the two stay tied: `themes/survey/tokens/` is a derived copy, never a live
   sync. Survey's `tokens.json` groups colors as `color.light` and `color.dark`, has no resolver, and
   its `text-step-1` through `text-step-10` are interface sizes that collide with the chassis's
   reading scale (builder A's friction item 3). Mapping Survey's values onto the chassis names is
   design work, done once in the design pass. `glw907/survey` keeps its own format, because other
   house tools read it. The manifest's `derivedFrom` records the Survey commit the theme was built
   from. A scheduled check reports when Survey's `tokens.json` changes after that commit, and a
   design pass then decides whether to carry the change across.
4. **Setup's theme and option questions**, once the catalog holds two themes: the cairn-setup
   additions above, through the alignment protocol below.
5. **Acceptance.** Geoff runs a test build with Waymark, takes it down, and runs another with Survey.
   Then the 907.life rerun takes Survey at setup.

Each later rebuild starts with its own theme's design pass, the same way as step 3.

## Alignment with cairn-setup

The cairn-setup plan's "Alignment with the theme-garden initiative" section names five boundary
points. Before a `cairn new` task changes one, its conductor messages a live theme-garden session,
or reads this section when none is running. This section stays current on each point.

1. **Catalog entry shape.** `{ id, name, description, path }` stays valid. The garden adds `source`
   and reads the rest of a theme's data from its manifest. The reader tolerates unknown fields
   (T1.9 unit case).
2. **The scaffold's target table.** Today's targets are `src/theme/site.config.yaml` (siteName) and
   `src/theme/cairn.config.ts` (aiPosture, the `createGithubApp` literal, `email.from`). The garden's
   first engine pass moves both to `src/site/`, which is a one-line change per target in that table.
3. **The questions form and the summary's Theme row.** The garden adds the color-mode question and
   up to four option selects after the theme question, plus their summary rows. These are additive
   and not reserved now.
4. **`src/content/.cairn/`.** The garden adds `theme-lock.json` there, as a separate file. It never
   writes `site-facts.json`.
5. **The starter overlay.** The garden reads it and never writes it. The conformance set stays out
   of `templates/` and out of the overlay directory.

## Kept possible

None of these is built now. Each is possible because of a choice above.

- **Switching a live site's theme.** Content, site config, menus, and the owner's overrides all
  live outside `src/theme/`. Options match across themes by key, and the lock's hashes show which
  theme files the owner edited. A later switch command could replace `src/theme/` on a branch,
  regenerate `theme-options.css`, run the check, and preview on a Cloudflare preview deployment.
  Its target needs research first (Geoff, 2026-11-08).
- **Updating a site's theme copy.** The lock records the source, version, and hashes that a
  Copier-style three-way update needs.
- **Changing options after setup.** It regenerates one file from the lock.
- **Outside themes.** A new `source` value (a git repository, a tag, and a digest) and the published
  schemas, the check, and the viewer.
- **The cairn.pub browsing page.** It reads `templates/catalog.json`, each manifest, the tokens for
  swatches and fonts, and the viewer's screenshots.

## Left to the builder

- The exact directory and file names under `src/site/`, the chassis's directive defaults, and the
  conformance set.
- The tokens build's implementation. Survey's `scripts/build` is a working precedent.
- How the generated option sheets target the daisyUI theme blocks in the cascade.
- Whether the viewer grows out of the showcase or stands alone, and whether `/styleguide` retires.
- Whether the check starts as a node script or a Go command.
- The pass split, within the order of work above.
