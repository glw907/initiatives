# Foundation: one structure for kinds, themes, features, and starters

Initiative: theme-garden. Round: `foundation`. Status: draft, waiting for Geoff's approval.
Read against cairn-cms at `6499871a8`.

## Brief

This round rebuilds how a cairn starter site is put together, and changes nothing a visitor sees.
Kinds and features become data files. A site records its kind and its features in one file. One
composer builds the showcase, the starter template, and every new site from layers: a base, the
chosen features, a theme, and a content set. The engine gains one thing, which is several menus
in the admin where it has one today. `cairn add <feature>` lays a feature into a site that
exists. Six passes run in one chain of about 690 path minutes. The round starts when Pennant
closes. Round two, site basics, then builds the features themselves on this structure.

## Why

The site-basics design that Geoff approved on 2026-11-15 added four features without touching the
engine. To do that it kept social links in a second settings file, injected a menu link from a
layout, and switched features off at run time in code every site carried. Geoff called that "a
little ugly". The code behind it shows the same strain today. The showcase is cut down into the
starter by a list of 19 excluded paths and 14 marked blocks in 9 files. The Go tool rewrites a
new site's files with eight regular expressions, three of them over TypeScript source. A kind's
id is listed in `sets/kinds.json` and typed again in three schemas. Each of these is a place where the next kind, theme, or feature needs a
workaround. The release is the last cheap moment to remove them.

## Decided by Geoff

Each line is Geoff's, from 2026-11-15.

- "Since we still have room to change the engine, this should be built as if it were designed
  from scratch this way."
- "We're trying to release with a clean, elegant engine with no technical debt."
- "The engine should support themes, kinds, options, and starter kits with no hacking or
  write-arounds."
- "All functionality should live at the logical level."
- "Starter kits and themes should support events where appropriate."
- "This is a bit of a re-work, but the goal is a clean system at the 1.0 mark."
- On whether features are layers laid in only when chosen: "yes, layers with a cairn add
  command".
- On which kinds start with events: "yes, organization only, others can add them".
- On holding the events round's passes 2 and 3 until this structure exists: "yes, hold events
  passes 2 and 3".
- On two rounds, with this one first: "yes, send the foundation design now".

## Where each thing lives

| Level | Holds | Never holds |
| --- | --- | --- |
| Engine, `src/lib` | Content, the editor and admin frame, menu editing, delivery helpers, and logic that binds to no site | Kinds, features, themes, or sets. It never reads the site record |
| Definitions, `definitions/` | The kinds with their labels and default features, and the feature list | Code |
| Theme, `themes/<id>/` | The look and its options. Its manifest names its kinds, the menus it shows, and the feature views it styles | Routes, content, or site logic |
| Content set, `sets/<kind>/` | Starter content for one kind | Code, or the site's name |
| Feature layer, `features/<id>/` | The site code for one feature: its routes, its admin contribution, and its `package.json` additions | Engine surface |
| Site record, `cairn-site.json` | The facts with no other home: kind, features, theme option values, the AI crawler stance, and deploy details | Anything another file already states, with one exception, the public origin |
| Go tool, `cairn` | The questions, the record, and structured edits to `wrangler.jsonc` and YAML. It runs the composer | The composing rules |

A theme stays a choice made at setup and never becomes a run-time API. That is ruling
`scope-verdict-361`, and this design keeps it.

## Goals

1. A kind or a feature is added by editing one data file, and every schema and the Go tool follow
   from it.
2. The showcase, the starter template, and a new site are the same layers in different
   selections, built by one composer.
3. A site states its kind, its features, and its deploy details in one file that the developer
   owns after setup.
4. A feature a site didn't choose leaves no file, route, script, or dependency in that site.
5. A site's admin edits as many menus as the site declares.
6. Site code that binds to no site, or that guards something, lives in the engine and takes its
   fixes from a package update.

## Non-goals

- Any of the features. The contact form, search, topic pages, social links, and events are round
  two.
- New questions in `cairn new`. It asks what it asks today.
- The new docs pages on starters, themes, and the catalog. Round two's last pass writes them.
- The blog, portfolio, documentation, and product-page content sets. The starter's content stays
  a layer and isn't published as a set.
- An engine release. A pass never publishes the package.
- `cairn remove`, and `cairn new` reading the hosted catalog.

## Anti-goals

- A second composer. One set of rules, in one language.
- A feature switched off at run time in a site that still carries its code.
- A regular expression that edits source code in a new site.
- The engine reading a kind, a feature, or the site record.
- A visitor-visible difference in the starter or in either demo.
- A token or sign-in widened so that a pass can finish.

## Calls made here

These are Claude's calls. Geoff can overrule any of them in the approval.

- **Definitions.** `sets/kinds.json` moves to `definitions/kinds.json`, and each kind gains
  `defaultFeatures`. A new `definitions/features.json` lists each feature's id, label, the kinds
  it suits, and its layer path. A script writes the kind and feature enums into every schema that
  names one: three today, and the site record's in pass 3. Pass 3 also adds the copy the Go tool
  embeds, because the record's writer is the first Go code that reads a kind. A check fails when
  any of them differs from the data. `defaultFeatures` and a theme's `features` may name only ids
  in `definitions/features.json`, and a theme's `menus` is a list of unique menu names.
  The same pattern already guards `site-config-path.json`.
- **The feature list starts empty of offered features.** This round builds the structure, and
  round two adds each feature as a layer. The composer and `cairn add` are proven with a feature
  kept under the tests, which is never offered. The tests point the composer at a separate
  layers folder. The shipped tool has no flag or setting that does that.
- **The theme manifest.** `kinds` takes one to five ids, where it takes three today. Two optional
  fields are added: `menus`, the menu names the theme shows, and `features`, the feature views it
  styles. Both themes declare them in pass 4.
- **The site record.** `cairn-site.json` sits at the site root, with schema
  `schema/cairn-site-1.schema.json`. It holds `kind`, `features`, `themeOptions`, an optional
  `aiPosture` (`invite` or `decline`, which the tool writes into `cairn.config.ts` today),
  `scaffold` (the engine and composer versions that wrote the site), and `deploy` (`publicOrigin`, `emailFrom`,
  and the GitHub `owner`, `repo`, `branch`, `appId`, and `installationId`). It leaves out the
  theme's id and version, which the laid-in manifest states, the Cloudflare names, which
  `wrangler.jsonc` states, and the site name, which `site.config.yaml` states. It holds no
  secret. `cairn.config.ts` imports it, and the Go tool edits no `.ts` file. The tool still sets
  the site name in `site.config.yaml` and the package name in `package.json`, both by key.
- **The public origin is stated twice.** The engine reads `PUBLIC_ORIGIN` from `wrangler.jsonc`
  at run time, and the build reads `deploy.publicOrigin` from the record. Changing how the
  engine reads it is outside this round. The tool writes both, and a test the site carries
  fails when they differ. `cairn doctor` reports the same.
- **The starter's kind.** The default template's record says `blog`. Its starter content stays
  where it is today and is passed to the composer as the content layer. No blog set is
  published in this round.
- **Where the layers live.** A new `starter/` folder holds `compose.mjs`, `base/`, and
  `fixture/`. Features are under `features/`, themes under `themes/`, and sets under `sets/`.
  `examples/showcase` and `templates/waymark` are both committed composer output, each held by
  a drift check. A change is made in a layer and composed with `npm run compose`. Generating the
  showcase without committing it was the alternative. It would move every path the tests, CI,
  and the visual baselines name.
- **Composition.** Layers apply in the order base, features, theme, set. Two layers that write
  one path are refused. `package.json` merges by key. A file that depends on the selection is
  written whole by the composer: `theme-names.ts` today, with `src/site/features.ts` and
  `theme-options.css` added. The showcase's test fixtures become one more layer, which is never
  offered.
- **One composer.** A dependency-free Node script. The builds run it, and the Go tool runs it as
  a child process. `cairn new` fetches the package and reads `template/` from it in memory
  today. From pass 6 it unpacks `starter/`, `features/`, `themes/`, `sets/`, and `definitions/`
  to a temporary folder and runs the composer there. The package keeps shipping `template/`, so
  a tool released earlier still works. `cairn new` already requires Node and checks its version. A second composer in
  Go would be the same rules written twice.
- **The committed template stays.** `templates/waymark` remains in the repo as the composed
  default, with a check that fails when it drifts. Ruling `cleanup-starter-template` set that,
  and nothing here reopens it.
- **A feature's shape.** A layer under `features/<id>/` with its routes, a module at
  `src/features/<id>/contribution.ts` that exports `{ concepts?, navLayout?, accessMap? }`, and
  its `package.json` additions. The composer writes `src/site/features.ts`, which imports each
  chosen feature's module in the order of `definitions/features.json`, and `cairn.config.ts`
  spreads them after the site's entries. Two contributions with the same concept id, admin
  address, or sidebar entry fail the build, naming both features. Each feature view ships a plain
  component with class hooks, so a theme that doesn't style it still shows it.
- **A theme and a feature it doesn't style.** The composer warns and goes on. It refuses only
  when the content set fills a menu the theme doesn't show.
- **Several menus.** `editor.nav` becomes a list of menu configs, and the admin's menu route is
  keyed by the menu's name, at `/admin/nav/<name>`. One access rule, `nav`, still covers every
  menu, and the commit scope stays `nav` with the menu's name in the message. `screen: 'nav'` in
  a `navLayout` places all the menus together, in the config's order. `site.config.yaml` already holds menus as an open map, so the admin
  is the only part that knows one menu. This breaks every consumer's config by one line, and the
  changelog says how to change it.
- **What moves into the engine.** Seven chassis files import nothing from the site: `date.ts`,
  `archive.ts`, `feed-items.ts`, `render.ts`, `theme-toggle.ts`, `dev-gate.ts`, and
  `directives/banner-expiry.ts`. They move behind the existing `/public`, `/delivery`, and
  `/cloudflare` entry points, with their tests. No new entry point is added.
- **What stays copied.** The five files that import the site's config, the three style sheets,
  `directives/vocabulary.ts`, `directives/classes.json`, and `directives/compose.ts`. The
  vocabulary is the starter's content contract, which a developer edits, and `compose.ts` reads
  it.
- **`cairn add`.** It reads the site record, refuses a feature the record already lists, runs the
  composer from the engine package installed in the site, with that one layer over the site, adds the id to the record, and prints what it
  wrote. It refuses when a file the layer writes already exists. It never deploys.
- **An editor can't switch a feature on.** A feature is code laid into the site, so adding one is
  the developer's act.
- **Docs.** Each pass corrects the pages and skills its change makes wrong. Pass 3 adds one
  reference page for `cairn-site.json`, because the developer owns that file from the first day.
  The pages that teach the system wait for round two, when `cairn new` asks its final questions.
- **Pennant.** Pennant finishes as planned. Pass 2 moves its third menu, `actions`, onto the menu
  list, and pass 4 moves the organization set and both themes onto layers.
- **Classes.** Passes 4, 5, and 6 are `auth-data`, because each changes `wrangler.jsonc`,
  `hooks.server.ts`, or how the tool writes a site's deploy details.

## Scope

In scope: `definitions/`, `schema/`, `features/`, `themes/**`, `sets/**`, `examples/showcase`,
`templates/waymark`, `scripts/build/**`, `scripts/theme/**`, `scripts/catalog/**`,
`scripts/checks/**`, `tool/**`, the engine's menu files and its `/public`, `/delivery`, and
`/cloudflare` entry points, the packaged skills, and one new page under `docs/admin/`.

Out of scope: any other file under `src/lib/**`. A pass that needs one parks, and the question
goes through `cairn-judging-scope`.

The on-hold site-basics design (`specs/2026-11-15-site-basics-design.md`) is replaced by round
two's design. Its feature table, its mock-up, and Geoff's three rulings carry over. Its
`src/site/settings.json` is dropped.

## How it fails

| What happens | What the composer or the tool does |
| --- | --- |
| Two layers write the same path | The composer exits nonzero, names both layers and the path, and writes nothing |
| Two layers give one `package.json` key different values | The same, naming the key and both values |
| A layer names a feature that `definitions/features.json` doesn't list | Exits nonzero, naming the id |
| The content set fills a menu the theme's manifest doesn't list | Exits nonzero, naming the menu and the theme |
| A chosen feature isn't in the theme's `features` | Prints one warning line and composes with the feature's plain view |
| The target folder isn't empty, for a new site | Exits nonzero before writing |
| A theme declares six kinds, none, or one kind twice | The theme check fails, naming the manifest |
| A schema or the Go tool's embedded copy differs from `definitions/` | `check:definitions` fails, naming the file |
| `templates/waymark` differs from what the composer writes | `check:template` fails and lists up to 20 differing paths |
| `cairn-site.json` is missing, isn't JSON, or fails its schema | The site's build fails with one line naming the field. `cairn add` and `cairn doctor` say the same |
| `cairn add` names a feature the site already has | Exits nonzero: "This site already has" and the id. Nothing changes |
| `cairn add` names a feature that isn't offered | Exits nonzero and lists the features that are, or says that none is |
| `cairn add` is run with no feature named | Lists the features the site can add and exits 0. With none, it prints "No features to add yet." |
| The record's `deploy.publicOrigin` differs from `PUBLIC_ORIGIN` in `wrangler.jsonc` | The site's test fails, naming both values. `cairn doctor` says the same |
| Two features contribute the same concept id, admin address, or sidebar entry | The site's build fails, naming both features |
| A file the feature's layer writes already exists in the site | Exits nonzero, lists up to 20 such paths, and writes nothing |
| The site's git tree has uncommitted changes | `cairn add` exits nonzero and says to commit first, so its change can be reviewed and undone as one commit |
| Node is missing or older than `cairn new` requires | The tool exits before anything is created, as it does today |
| The composer exits nonzero under the tool | The tool prints the composer's lines, removes the folder it created, and exits nonzero |
| A site's config still gives `editor.nav` as one object | `defineCairn` throws at build with the one-line fix. Nothing guesses |
| Two menus in `editor.nav` share a name, or a list holds more than 8 | `defineCairn` throws, naming the menu or the limit |

## Passes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `foundation-1` definitions | Kinds and features are data under `definitions/`. The schemas are generated from it, and a check holds them. A theme may declare five kinds, menus, and features. | `definitions/**`, `sets/kinds.json` (removed), `schema/**`, `scripts/build/**`, `scripts/catalog/**`, `scripts/theme/**`, `scripts/checks/**`, `src/tests/unit/gate-tier.test.ts`, `skills/**`, `templates/waymark/.claude/**`, `docs/internal/theme-catalog.md`, `MIGRATION-NOTES.md` | `runner` | 80 | none | 2 to 6 |
| 2 `foundation-2` menus | The admin edits every menu the site declares. Pennant's `actions` menu is one of them. | `src/lib/content/**`, `src/lib/nav/**`, `src/lib/sveltekit/**`, `src/lib/admin/**` (the menu screen and sidebar), `examples/showcase/src/site/cairn.config.ts`, `templates/waymark/**`, `skills/**`, `MIGRATION-NOTES.md` | `ordinary` | 120 | 1 | 1, 3, 4 |
| 3 `foundation-3` record | A site has `cairn-site.json`. `cairn.config.ts` reads it, and the tool writes it and rewrites no source. | `schema/cairn-site-1.schema.json`, `scripts/build/**`, `scripts/checks/**`, `examples/showcase/**`, `templates/waymark/**`, `tool/internal/**` (the scaffold and the embedded copy), `tool/cmd/cairn/**`, `docs/admin/**`, `skills/**` | `ordinary` | 110 | 2 | 2, 4, 6 |
| 4 `foundation-4` composer | One composer builds the showcase, the template, and both demos from layers. The exclude list, the markers, and the prune lists are gone. | `starter/**`, `scripts/build/**`, `scripts/theme/**`, `scripts/catalog/**`, `scripts/checks/**`, `features/**`, `examples/showcase/**` with `wrangler.jsonc` and `src/hooks.server.ts`, `templates/waymark/**`, `themes/**`, `sets/**`, `package.json` | `auth-data`, `live-account` | 200 | 3 | 1, 2, 3, 5, 6 |
| 5 `foundation-5` chassis | Seven files that bind to no site are engine exports. The copied chassis holds the site's bindings, its vocabulary, and its CSS. | `src/lib/public/**`, `src/lib/delivery/**`, `src/lib/cloudflare/**`, `examples/showcase/src/chassis/**`, `examples/showcase/src/hooks.server.ts`, `themes/**`, `templates/waymark/**`, `docs/internal/engine-rulings.md`, `skills/**` | `auth-data`, `live-account` | 90 | 4 | 4, 6 |
| 6 `foundation-6` add | `cairn new` composes a site from the package's layers, and `cairn add` lays a feature into a site that exists. | `tool/**`, `package.json` (the `files` list), `scripts/build/pack-engine-template.mjs`, `docs/admin/**`, `skills/**` | `auth-data` | 90 | 5 | 3, 4, 5 |

Every pass also touches `BACKLOG.md` and `CHANGELOG.md`, and the conductor holds `docs/STATUS.md`.

## What each merge publishes

A change under `themes/<id>/` or `sets/<kind>/` must raise that theme's or set's version, and the
merge then publishes the new version to the catalog for good.

| Pass | Publishes |
| --- | --- |
| 1 | Nothing. The schema fields are optional, and no theme changes |
| 2 | Nothing |
| 3 | Nothing |
| 4 | Waymark and Pennant, one minor version each, with both demos redeployed, and the organization set if its files move |
| 5 | Waymark and Pennant, one minor version each, because their imports change |
| 6 | Nothing. The tool ships with the next engine release |

Passes 1, 2, and 3 land once their checks are green and their review is accepted. Passes 4, 5,
and 6 wait for Geoff's merge.

## Acceptance

Every pass:

- CI is green on the head commit, and the whole-branch review is accepted with no open finding.
- The built showcase, the Waymark demo, and the Pennant demo show no visitor-visible change. A
  fresh `standards:visual-verifier` compares each of the home page, a post, a plain page, and the
  archive at the five widths with the same page built from the pass's base commit, and returns no
  difference.
- The showcase's built public output (every prerendered page, the feeds, the sitemap, and
  `robots.txt`) equals the base commit's, file for file, once hashed asset names are replaced
  with a fixed token. The PR lists any file that differs, with the reason.

Each item below was run once against `origin/main` at `6499871a8` on 2026-11-15. "Today" gives
what it returned.

Pass 1, definitions:

- `definitions/kinds.json` and `definitions/features.json` exist, and `sets/kinds.json` doesn't.
  Today: `git cat-file -e origin/main:definitions/kinds.json` exits 128.
- No tracked file names `sets/kinds.json`, apart from `BACKLOG.md`, `CHANGELOG.md`, and the
  dated entries in `MIGRATION-NOTES.md`, which the pass leaves as written. Today: 13 files do.
- `npm run check:definitions` passes. A test adds a sixth kind to a copy of the data, runs the
  generator, and finds the id in all three schemas. A second test
  changes one schema by hand and the check fails, naming it. Not runnable today: the script
  doesn't exist.
- The theme schema accepts five kinds and rejects six, none, and one kind twice. It accepts a
  manifest with `menus` and `features` and one without. It rejects `menus` that isn't a list of
  unique names, and a `features` id that `definitions/features.json` doesn't list. Today: `maxItems` is 3, and the schema's
  `additionalProperties: false` rejects both new fields.
- Each kind in `definitions/kinds.json` carries `defaultFeatures`, an empty list in this round.
  A test gives a copy of the data a default that `features.json` doesn't list, and
  `check:definitions` fails, naming the kind and the id.

Pass 2, menus:

- `editor.nav` is typed as a list. Today: `src/lib/content/types.ts` line 328 reads
  `nav?: NavMenuConfig;`.
- With two menus declared, an end-to-end test opens each menu's admin screen by name, adds a link
  to the second, saves, and finds the link under that menu's key in the committed
  `site.config.yaml`, with the first menu unchanged.
- The admin sidebar lists one entry for each declared menu, in the config's order.
- An address for a menu the config doesn't declare returns 404.
- A unit test for each of the last two rows of "How it fails" asserts the thrown line.
- The showcase declares its menus as a list. Its fixture declares a second menu, which the
  end-to-end test above edits. Every config in the repo that declares Pennant's `actions` menu
  has it on the list, and `git grep` finds no `editor.nav` given as one object.
- A user whose role lacks the `nav` rule gets 403 on every menu's address, and a commit from the
  second menu's screen carries that menu's name in its message.
- `CHANGELOG.md` carries a `Consumers must:` line for the change, and `MIGRATION-NOTES.md` shows
  the before and after.
- The three packaged skill files that name the menu setting describe the list. Today:
  `cairn-building-admin-screens/SKILL.md`, its `references/sidebar-and-access.md`, and
  `cairn-extending-a-site/references/public-routes.md` name the single form.

Pass 3, record:

- `schema/cairn-site-1.schema.json` exists and rejects an unknown key, a kind outside
  `definitions/kinds.json`, and a record with no `deploy.publicOrigin`. Its kind and feature
  enums are written by pass 1's generator, and `check:definitions` covers it and the copy the Go
  tool embeds. The tool's record writer reads that copy and refuses a kind that isn't in it. Today: the file
  doesn't exist.
- `tool/internal/setup/scaffold/substitute.go` holds none of `descriptionLineRE`, `emailFromRE`,
  `publicOriginTSRE`, `githubAppRE`, and `publicOriginJSONRE`, and no regular expression that
  matches a `.ts` file. Today: `git grep -c` finds those names on 11 lines, and three of the
  five rewrite `cairn.config.ts`.
- A `cairn new` run in the tool's end-to-end test writes a `cairn-site.json` that passes the
  schema, and every `.ts` file in the written site is byte-for-byte the template's. The run's
  AI crawler answer is in the record, and the built `robots.txt` reflects it for each of
  `invite`, `decline`, and unset.
- The written site's public origin, sending address, and GitHub App details at run time equal the
  record's values. A test changes each `deploy` value in the record alone, rebuilds, and finds the
  new value where the site uses it. With the origin changed in the record alone, the site's test
  from "How it fails" fails, naming both origins.
- A test records every value the run hands to the tool's secret store, through the fake store
  the tool's tests already use, and finds none of them in the record.
- Each row of "How it fails" that names `cairn-site.json` has a test.
- `docs/admin/` holds one reference page for the record that lists every field, and a check fails
  when the page's field list differs from the schema's. `npm run check:docs-gate` and `vale`
  pass, and a fresh `docs-fact-checker` returns no finding on it.
- `make -C tool check` passes.

Pass 4, composer:

- No tracked file holds `cairn-template:exclude`. Today: 14 files do, 10 of them in the showcase.
- `examples/showcase/.cairn-template.json` doesn't exist. Today: it does, with 19 excludes.
- `scripts/build/bake-template.mjs` holds no `PRUNED_SCRIPTS` or `PRUNED_DEV_DEPENDENCIES`.
- `templates/waymark` at the pass's head is byte-for-byte what the composer writes from base,
  Waymark, and the starter content, and the PR lists every path that differs from the tree at the
  pass's base commit, each with its reason. A difference in a file a visitor's browser loads
  fails the item. `npm run check:template` passes.
- The showcase is the composer's output from base, Waymark, its content, and the fixture layer.
  `npm run check:showcase` fails when the committed tree differs from that output, and a test
  shows it failing on a hand edit. The whole end-to-end suite passes unchanged.
- A unit test for each of the first six rows of "How it fails" asserts the exit code and the
  line. For the five rows that refuse, it asserts that the target holds no file. For the
  warning row, it asserts exit 0, the warning line, and the plain view in the output.
- A test composes base and Waymark with the test feature and without it. With it, the site holds
  the feature's route, its `package.json` addition, and its import in `src/site/features.ts`.
  Without it, the site is byte-for-byte the tree composed from a layers folder that never held
  the feature.
- Both themes' manifests declare `menus` and `features`. The Pennant demo is composed from base,
  Pennant, and the organization set, and a search of the set for the demo's site name and its origin, as its `site.config.yaml`
  and record give them, finds neither.
- `standards:web-auth-security-reviewer` returns no open finding on the composed
  `wrangler.jsonc` and `hooks.server.ts`. Each differs from the pass's base only by its fixture
  blocks moving to the fixture layer.
- The search for the retired forms (`emit-template`, `emit:template`, `.cairn-template.json`,
  `cairn-template:exclude`) in `~/.dotfiles/claude`, each repo's `.claude/` and `skills/`, and
  the initiatives prompts returns only lines the PR lists as changed or historical.

Pass 5, chassis:

- `examples/showcase/src/chassis/` holds none of the seven files or their tests. Today: it holds
  all seven.
- Each of the seven files' exported functions is importable from `/public`, `/delivery`, or
  `/cloudflare`, carries a doc comment and a tier tag, and `npm run check:surface`,
  `check:tiers`, and `check:package` pass.
- The seven moved test files pass under `src/tests/unit/`, with no test dropped. The PR carries
  Vitest's list of test names at the base commit and at the head, and every name in the first
  is in the second. `banner-component.test.ts` stays with `compose.ts`.
- No file under `themes/` imports any of the seven from `#chassis/`. Today: four Waymark
  files do.
- `engine-rulings.md` holds one new entry for the move, which names `site-today-export` and
  quotes Geoff's ruling from this design.
- `standards:web-auth-security-reviewer` returns no open finding on the moved dev gate, and the
  dev-fold tripwire test passes on the deploy artifact.

Pass 6, add:

- `cairn new` writes a site by running the composer over the layers it unpacks from the package.
  For each of the two answer sets in the tool's end-to-end fixtures, the written tree is
  byte-for-byte the tree the tool writes at the pass's base commit, apart from
  `cairn-site.json`'s `scaffold` versions.
- `cairn add --help` prints usage. Today: the tool has no `add` command.
- With the test feature, `cairn add <id>` in a composed site writes the layer's files, adds the id
  to `cairn-site.json`, and prints each path it wrote. The site then builds.
- Each row of "How it fails" that names `cairn add`, Node, or the composer under the tool has a
  test that asserts a nonzero exit, the line, and that no file changed.
- `cairn add` with no feature named and none offered prints "No features to add yet." and
  exits 0. The released binary has no flag, setting, or environment variable that names a layers
  folder: `cairn add --help` and a search of `tool/` for the test feature's id show none outside
  test files.
- The agent guide and `docs/admin/setup-reference.md` name `cairn add`, and every command on the
  changed pages is run in the PR's evidence.
- `make -C tool check` passes, and screenshots of the real terminal show `cairn add`'s output at
  80 and 120 columns.

## Shared assumptions

| Assumption | Probe or source | Result |
| --- | --- | --- |
| The engine knows no kind today | `git grep -l "kinds.json" origin/main` | Thirteen files, none under `src/lib` |
| `site.config.yaml` already holds several menus | `src/lib/nav/site-config.ts` line 95 | `menus` is an open map |
| The admin edits one menu | `src/lib/content/types.ts` line 328 | `nav?: NavMenuConfig;` |
| A generated file with a drift gate already feeds the Go tool | `scripts/build/emit-tool-conditions.mjs` and `npm run check:tool-conditions` | It writes `site-config-path.json` and `conditions.json` |
| `cairn new` already needs Node | `tool/cmd/cairn/new_wire.go` lines 95 and 96 | It runs `node --version` as a prerequisite |
| Seven chassis files import nothing from the site | grep for `#site/` under `examples/showcase/src/chassis` | Five other files do: `cairn.server.ts`, `content.ts`, `public-routes.ts`, `entry-data.ts`, `feed.ts` |
| `compose.ts` binds to the vocabulary | `examples/showcase/src/chassis/directives/compose.ts` line 8 | It imports `./vocabulary.js`, so it stays |
| The charter wants this code in the engine | `what-cairn-is-and-is-not.md` lines 136 to 138 | "Anything security-critical or prone to fixes lives in the engine" |
| A composing function already exists for demos | `scripts/theme/viewer/site.mjs` | `composeSite({root, themeDir, contentDirs})` |
| The marked blocks can all move to one layer | Read of all 14 blocks | Six are whole statements or comments. Eight sit inside a list, an object, or an interface that base also writes: one each in `wrangler.jsonc`, `site.config.yaml`, `hooks.server.ts`, `vite.config.ts`, `app.d.ts`, and `tsconfig.json`, and two in `cairn.config.ts`. Unproven for those eight |
| The organization set carries no site name in its manifest | `git show origin/pennant-3:sets/organization/cairn-set.json` | It holds `kind`, `version`, `engine`, `notes`, `license`, and `images` |
| The Go tool can unpack the layers from the package it fetches and run the composer on them | `tool/internal/setup/scaffold/extract.go` reads `template/` in memory today | Unproven |
| The tool writes the AI crawler stance into source today | `substitute.go`, `editCairnConfig` | It replaces a comment block in `cairn.config.ts`, so the record takes the value |

Two mechanisms are unproven. Pass 4 settles the eight blocks first, before any other task: each
becomes a contribution the fixture layer makes through a generated file or a merged key, and
standing answer 13 applies if one can't. One of the eight is in `hooks.server.ts`, so expect
that answer's `merge` record. Pass 6's planner proves the tool can unpack the layers and run the
composer from a freshly fetched package before it plans anything else, and standing answer 16
applies if it can't.

## Order

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 definitions | `plans/2026-11-15-foundation-1-planner-prompt.txt` | none | 80 | no |
| 2 menus | `plans/2026-11-15-foundation-2-planner-prompt.txt` | 1 | 120 | no |
| 3 record | `plans/2026-11-15-foundation-3-planner-prompt.txt` | 2 | 110 | no |
| 4 composer | `plans/2026-11-15-foundation-4-planner-prompt.txt` | 3 | 200 | yes |
| 5 chassis | `plans/2026-11-15-foundation-5-planner-prompt.txt` | 4 | 90 | yes |
| 6 add | `plans/2026-11-15-foundation-6-planner-prompt.txt` | 5 | 90 | yes |

The passes run one at a time, because every pair shares a file. Each pass's worktree is cut from
the pass before it once that pass's whole-branch review is accepted. The merge order is 1 to 6.
Passes 1 to 3 land without Geoff. He sees one `merge` document, for passes 4, 5, and 6 together,
when pass 6's review is accepted. The chain is 690 path minutes, and the round stops new launches
past 1,380. The usage ceiling is 85 percent of the weekly allowance.

The menu change goes second because it is the one engine contract change, and the least proven
step that has no dependency on the composer. Pass 4 is the largest and waits for the record, so
that the composer never has to preserve the tool's rewrites.

## Start line

The round launches when each of these reads true. Lines 1 and 2 aren't true today.

1. `docs/STATUS.md` on `origin/main` holds a line that reports round `pennant` closed.
2. `claude agents --json` holds no row named `cairn-cms-pennant-*`, `cairn-cms-events-*`,
   `conductor-pennant`, or `conductor-events`.
3. This design's document in the Approval Queue is answered "approve".
4. `specs/2026-11-14-events-design.md` in initiatives still holds its `Held:` line.

Launch checks, read on 2026-11-15:

| Check | Command | Output |
| --- | --- | --- |
| Main is current | `git rev-list --count HEAD..origin/main` | `0`, at `6499871a8` |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 38% used` |
| Live sessions | `claude agents --json` | `conductor-pennant` busy, `cairn-cms-pennant-3` busy, `cairn-cms-pennant-3-plan` idle, no `foundation` row |
| Open pull requests | `gh pr list` | #251 `pennant-1`, #253 `pennant-2`, #254 `pennant-3` (draft) |
| Launch flags | `claude --help` | Lists `--bg`, `--model`, `--effort`, and `--name`, and no `--advisor`, which is accepted all the same: Pennant's planners launched with the same line on 2026-11-15. The conductor probes the listed flags the day it launches |
| Main checkout | `claude-worktree-busy /var/home/glw907/Projects/cairn-cms` | busy, with Pennant's conductor in it |
| Start line 1 | read of `docs/STATUS.md` | Pennant is running. Not met |
| Start line 4 | `grep -n "^Held:" specs/2026-11-14-events-design.md` | Line 452. Met |

The conductor reads all of them again on the day it launches.

## Steps for Geoff

- [you: approve this design in the queue]
- [you: answer the one `merge` document, for passes 4, 5, and 6]

Nothing else needs him. The round uses no new account, secret, or service, and nothing in it runs
on orpheus or ward.

## Standing answers

The twelve in `round-run.md` hold. This design adds:

13. A marked block can't become a layer contribution: the file it sits in is written whole by the
    composer from a small template the base carries. If that file is `wrangler.jsonc` or
    `hooks.server.ts`, the pass records the generated form in its `merge` document.
14. A pass needs a file under `src/lib/**` that its row doesn't name: the pass parks.
15. A pixel difference shows in a demo: the pass fixes the cause. It never accepts a new
    baseline for a round whose claim is no visible change.
16. The tool can't unpack and run the composer from the fetched package: `cairn new` keeps
    copying the packed, composed template, `cairn add` runs the composer from the site's installed engine
    package, and the PR says so.
17. A theme or set version is already published at the number a pass picked: take the next one.
18. Pennant's merged files differ from what this design read: the planner plans against the
    files as merged, and parks only if an acceptance item can no longer be met.
19. A pass needs a change under `.github/**`, `scripts/release/**`, or `.claude/settings*`: it
    leaves the file alone, records the change it needs in the round's `merge` document, and
    finishes everything else.
20. A pass comes out over twice its path minutes at planning: it parks, as `round.md` says.

## Rulings

Geoff approved this design in queue document `20261115-223648-1d48b9`, 2026-11-15. Each `Ruled:`
line quotes his answer there.

1. Whether to overturn `site-today-export`, the ruling of 2026-08-26 that declined a date helper
   as an engine export. It reopens on "Evidence an export fixes discoverability better than the
   chassis copy". The evidence here is different in kind: both themes import the copied helpers,
   a fix to one reaches no site that already exists, and the charter puts fix-prone code in the
   engine. Pass 5 depends on the answer. If Geoff declines, pass 5 moves only `dev-gate.ts`,
   which guards something, and drops to 50 path minutes.
   Ruled: "Move all seven into the engine". Pass 5 keeps its 90 path minutes and records the
   new ruling in `engine-rulings.md`.
2. When the docs are written.
   Ruled: "Split it". Each pass corrects what it breaks, pass 3 adds the record's reference
   page, and the teaching pages are written in round two's last pass.

## Backlog verdicts

A scoped sweep read the open items at `6499871a8`.

| Item | Verdict | Where |
| --- | --- | --- |
| #488 lay-in rewrites `app.html` and `theme-names.ts` unchanged | fold | pass 4 |
| #483 demo canonical and feed links name `showcase.test` | fold | pass 4 |
| #481 Waymark's demo falls back to the starter overlay | reword | cut to "no blog set exists", which round two closes |
| #410 ship a tokens build or drop `tokens.json` | fold | pass 4 |
| #388 neutral starter tag vocabulary | keep | round two, with the blog set |
| #484 starter posts write `/admin` as inline code | keep | round two, with the blog set |
| #378 table scroll cue | keep | the CSS it names stays copied |
| #482 serve schemas at their `$id` | reword | add `cairn-set-1` and `cairn-site-1`, and state the split with #168 |
| #168 | reword | its file list, after the `kinds.json` move |
| #486, #485, #480, #472, #419, #417, #416, #415, #413, #412, #406, #394, #373, #333, #323, #304, #302 | keep | stamped by pass 1 |

The sweep proposed folding #484, #388, and #378. They stay open, because each changes what a
visitor sees or reads and this round's claim is that nothing does. The backlog holds 153 open
items, 45 of them unstamped in the last 90 days, so a full sweep is due. It runs separately and
never rides this design.

## Round two, in a page

Round two is `site-basics`, redesigned on this structure. Its full design is written when this
round's report is read.

- **Features as layers.** A contact form, search, topic pages, and events, each under
  `features/<id>/` and listed in `definitions/features.json`. Social links are a menu named
  `social`, which pass 2 makes possible, with the network read from each address. The privacy
  page is content in every set.
- **Defaults by kind.** The approved feature table becomes each kind's `defaultFeatures`. Events
  start on for the organization kind only, and any kind can add them.
- **Events.** The events round's passes 2 and 3 are built as the events layer, on the calendar
  helper pass 1 already merged. A theme that declares events styles them. Another theme shows
  the plain view.
- **`cairn new`.** Kind first, then the look from the themes that declare it, then the form and
  the links. Geoff's decisions and his three rulings from the approved design stand.
- **Docs.** The pages on starters, writing a theme, and the catalog, with the two fresh-reader
  checks.
- **Carried over.** The mock-up, the form's limits and log events, the two unproven mechanisms
  (Pagefind, and a Turnstile scope for the tool's sign-in), and backlog #407 and #501.

## Estimate

Six passes, 690 path minutes in one chain: 80, 120, 110, 200, 90, and 90.

## Practice and sources

- The independent architecture read and the three prior-art notes, all dated 2026-11-15, in
  `research/`. The prior-art notes cover how other site generators separate a theme, a starter,
  and an integration.
- The scope charter, `.claude/skills/cairn-judging-scope/references/what-cairn-is-and-is-not.md`,
  lines 136 to 138.
- `docs/internal/engine-rulings.md`: `scope-verdict-361`, `cleanup-starter-template`, and
  `site-today-export`.
- JSON Schema draft 2020-12, for the site record and the generated enums.
- The repo's `cairn-writing-docs` procedure and the Google Developer Documentation Style Guide,
  for the reference page.

## Out of scope and later

- `cairn remove <feature>`. Removing a layer from a site a developer has edited needs a separate
  design.
- An editor switching a feature on in the admin.
- `cairn new` reading the hosted catalog, with the lock file.
- Dropping `template/` from the package, once no supported tool reads it.
- Themes or features from outside the repo.
- The engine release that carries all of this. It follows round two.
