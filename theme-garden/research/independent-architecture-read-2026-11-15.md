# Independent architecture read, 2026-11-15

An Opus `Plan` agent designed the themes, kinds, options, features, and starter-kit system from the
owner's requirements and the cairn-cms code at `origin/main` `6499871a8`. It was not shown the
session's level map. This note records its design as reported, and what the session checked. The
agent edited and ran nothing. Three prior-art notes of the same date sit beside this one.

## Where each concept lives

| Level | Holds | Does not hold |
| --- | --- | --- |
| Engine (`src/lib`) | Content, the editor and admin frame, menu editing, delivery helpers, and logic with no site binding | Kinds, features, themes, sets. It never reads the site record at run time. |
| Definitions (repo data) | Kind ids, labels, default features; the feature list; schema enums generated from both | Code |
| Theme (`themes/<id>/`) | Presentation and options. Its manifest declares its kinds, the menus it reads, and the optional feature views it styles. | Routes, concepts, content |
| Set (`sets/<kind>/`) | Starter content for one kind | The site's name, code |
| Feature layer (`features/<id>/`) | Site code for one starter feature: routes, a concept, a contribution module, `package.json` additions | Engine surface |
| Site record (`cairn-site.json`) | Facts with no other source: kind, chosen features, theme option values, scaffold versions, deploy parameters | Anything that already has a source |
| Go `cairn` tool | Asks the questions, writes the record, edits `wrangler.jsonc` and YAML by structure, runs the composer | Composition logic |

The agent keeps `scope-verdict-361` (`engine-rulings.md:538`): a theme is a scaffold-time choice and
never a run-time API.

## Composition

Layers are applied in order: base, selected features, theme, set content. The composer refuses two
layers that write one path. `package.json` merges by key. A file that depends on the selection is
generated whole (`theme-names.ts` today; `src/site/features.ts` and `theme-options.css` added). The
showcase's test fixture becomes one more layer that is never offered, so the exclude list and the
`cairn-template:exclude` markers go away. The showcase is then base, every feature, Waymark, a set,
and the fixture.

One composer, in dependency-free Node, runs in the builds and under `cairn new`. The Go tool starts
it as a child process; Node is already a checked prerequisite (`new_wire.go:96`). The agent rejected
a second composer in Go (two implementations of one rule) and precomposing every combination at
pack time (combinatorial). `templates/waymark` stays committed as the composed default, checked for
drift.

## Site record

`cairn-site.json` at the site root, schema `schema/cairn-site-1.schema.json`. The Go tool writes it
once and the developer owns it after. It holds `kind`, `features`, `themeOptions`, `scaffold`
(engine and composer versions), and `deploy` (`publicOrigin`, `emailFrom`, and the GitHub `owner`,
`repo`, `branch`, `appId`, `installationId`). It leaves out the theme id and version (read from the
laid-in `src/theme/cairn-theme.json`), Cloudflare names (in `wrangler.jsonc`), the site name (in
`site.config.yaml`, set as a YAML key), and roles and AI posture (from the adapter).
`cairn.config.ts` imports the record in place of the literals the tool rewrites today.

## Features

`definitions/kinds.json` carries each kind's `defaultFeatures`, and `definitions/features.json` each
feature's id, label, suited kinds, and layer path. The Go tool embeds a generated copy behind a
drift gate, following `site-config-path.json`.

A feature is a layer. Its `src/features/<id>/contribution.ts` exports typed
`{ concepts?, navLayout?, accessMap? }`; the generated `src/site/features.ts` imports each enabled
one and `cairn.config.ts` spreads them. Each feature view ships a plain fallback component with
class hooks, so no theme is required to implement one. The composer warns when a feature is on and
the theme does not style it, and refuses when the theme lacks a menu the kind's set fills.

| Feature | Shape |
| --- | --- |
| Contact form | Layer: route and action on the `EMAIL` binding |
| Search | Layer: a search route, a postbuild script, a dev dependency |
| Topic pages | Layer: routes over tags |
| Privacy page | Set content only |
| Social links | A depth-1 `social` menu; the network is read from the URL's host by a table in site code |
| Events | Layer: concept, list and event routes, the calendar route through `buildICalendarResponse`. Default for organization, offered to other kinds, styled by themes that declare it. |

The one engine change features need is several menus: `editor.nav` becomes `NavMenuConfig[]` and the
menu route is keyed by name.

## Chassis

Split by what each file binds to. CSS and the five files that import `#site/` stay copied. `date.ts`,
`archive.ts`, `feed-items.ts`, `render.ts`, `theme-toggle.ts`, `dev-gate.ts`,
`directives/banner-expiry.ts`, and `directives/compose.ts` import nothing from the site and move
behind the existing `./public` and `./delivery` exports, under a new ruling entry.
`directives/vocabulary.ts` (409 lines) stays copied as the starter's content contract; the agent
flagged this as a judgment call.

## One-way doors it named

Theme schema (`kinds` to five, new `menus` and `features`); `editor.nav` as an array; the site record
schema; the set schema losing the site name; the feature contribution shape and class hooks; the new
chassis exports.

## Risks it named

Six files hold fixture-only text and each needs a decision (`wrangler.jsonc`, `vite.config.ts`,
`vitest.config.ts`, `tsconfig.json`, `app.d.ts`, `hooks.server.ts`). A feature must be edited in
`features/<id>/`, never in the laid-in copy. The Go tool running Node adds a failure point before
`npm install`. The open Pennant pull requests add a third menu and a home data type that need
re-homing.

## Passes it proposed

1. Definitions and the drift gate.
2. Several menus.
3. The site record; the literal rewrites in `substitute.go` deleted.
4. The composer and layers; the exclude list, markers, and prune lists retired.
5. The chassis split.
6. Starter features as layers.
7. Events as a layer (the held passes 2 and 3).
8. The `cairn new` flow.
9. Published docs, written beside each pass.

## What the session checked

- The charter says "Copied site code holds presentation only: the component registry, icons, CSS,
  the adapter, and thin route shims" and "Anything security-critical or prone to fixes lives in the
  engine" (`what-cairn-is-and-is-not.md:136-138`). Confirmed.
- The six top-level chassis files the agent named import nothing from `#site/` (329 lines), and
  exactly five chassis files do: `cairn.server.ts`, `content.ts`, `public-routes.ts`,
  `entry-data.ts`, `feed.ts`. Confirmed by grep. `dev-gate.ts:17` imports only `cloudflare:workers`.
- `site-today-export` reopens on "Evidence an export fixes discoverability better than the chassis
  copy" (`engine-rulings.md:245-246`). Confirmed.
- The theme schema caps `kinds` at three (`cairn-theme-1.schema.json:36-39`). Confirmed.
- Not checked: the Pennant branch claims, `new_wire.go:96`, and the line numbers in `substitute.go`
  beyond those the earlier inventory spot-checked.
