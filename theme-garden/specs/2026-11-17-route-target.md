# cairn's target version

Initiative: theme-garden. Written 2026-11-17 by `cairn-route-design` from cairn-cms at `79d326bed`
on `main`. This file describes what the `cairn-cms` repo holds when the route in
`2026-11-17-route-rounds.md` is done. It is the first of two design files behind the queue page
"Approve cairn's target version and the route that builds it?".

A maintainer who reads only this file should know where each concept lives and why. Every call
here is mine unless it carries Geoff's queue id. Where I differ from a hand-over, the section says
so.

## What Geoff decided

| Ruling | Queue id |
| --- | --- |
| The `cairn` command is TypeScript inside the engine package. A site has one package and one version. `npm create cairn-site` stays. A site keeps `cairn-site.json`. | `20261117-173947-69f637` |
| Stock pages live in the package. A site holds content, settings, a short file per stock page, and what the club took over. An update is one command with a plain report. The theme follows the same rule as a page. Every page starts at an ordinary route file. | `20261117-182244-aa5943` |
| Build straight to the target. No pass builds what a later pass replaces, keeps an old form beside the new, or migrates a site made today. | `20261117-182509-a29435` |
| Everything unmerged stopped, and one route replaces it. | `20261117-182825-8b4207` |
| A demo's contact form is a stand-in that sends nothing. Bot-check setup ships manual. A feature's `wrangler.jsonc` contribution is proven with a test feature. | `20261117-062058-a38126` |
| The sidebar reads the access map. The tidy option is `tidyClient`. Four groups of published names go. Site code can't throw the engine's typed error. The log event becomes `entry.save_prior_read_failed`. | `20261117-091516-5c3656` |
| The routing value is `'custom'`, and the edit screen shows the full address for every kind. | `20261117-080523-be1fbe` |

## The package at a glance

One npm package, `@glw907/cairn-cms`, holds everything a site runs and everything that makes or
tends a site. Its source is `src/lib`, built to `dist` by `svelte-package`. Three kinds of code
live there, and one rule separates them.

- **Runtime code** runs in a site's Worker or its admin's browser.
- **Site-shaping code** (`scaffold`) is pure functions that say what a made site contains. It runs
  anywhere.
- **Node-only code** (`vite`, `audit`, `guidance`, `cli`) runs on a developer's machine or in CI.

The rule: runtime code never imports Node-only code, and the command gets no entry in `exports`.
A site's Worker bundle can't reach provisioning code, because no import path leads to it.

## Layers in dependency order

A folder may import from any row above it and from no row below. `check:layers` reads
`scripts/checks/layers.json` and fails on any upward import. The list has no exceptions key.
Rows 1 to 19 extend the order Geoff approved in the structure design, with `mail` added. Rows 20
to 25 are new.

| Row | Folder | What it holds |
| --- | --- | --- |
| 1 | `log` | The log and the one table of event names |
| 2 | `escape.ts` | HTML escaping |
| 3 | `dev-flag.ts` | The rules for the development flag |
| 4 | `diagnostics` | `CairnError` and the registry of failure conditions |
| 5 | `mail` (new) | One sender through the `EMAIL` binding |
| 6 | `content` | Concepts, fields, validation, front matter, and the routing value |
| 7 | `github` | The repository backend |
| 8 | `nav` | The site config file and menus |
| 9 | `auth` | Roles, the access map, sessions, and the sign-in message |
| 10 | `islands` | Island types |
| 11 | `media` | The media manifest and references |
| 12 | `render` | The Markdown pipeline and the component registry |
| 13 | `site` (new) | The adapter and the runtime (`CairnAdapter`, `CairnRuntime`, `defineAdapter`, `composeRuntime`), plus the site record's type and its one validation |
| 14 | `delivery` | Public routes and feeds |
| 15 | `cloudflare` | Cloudflare helpers |
| 16 | `sveltekit` | The admin's server side and the one bindings shape |
| 17 | `admin-toolkit` | Parts a site's custom admin screen uses |
| 18 | `admin` | The admin screens |
| 19 | `public` | Components for the public site |
| 20 | `stock` (new) | What every site runs, whatever its look: loaders, endpoints, the request hook, the admin mount, the directive vocabulary, the base style sheets |
| 21 | `features/<id>` (new) | One folder per feature: its concept, its loaders, a plain view |
| 22 | `themes/<id>` (new) | One folder per theme: page views, named parts, tokens, modes |
| 23 | `scaffold` (new) | What a made site contains, as pure functions |
| 24 | `vite`, `guidance`, `reproductions`, `audit` | Tools, in that order. `vite`, `guidance`, and `audit` run in Node only. `reproductions` is a published export that a docs page renders in a browser. It sits this high because it imports `admin` and `sveltekit` |
| 25 | `cli` (new) | The `cairn` command |

The entry files (`index.ts`, `internal.ts`, `ambient.ts`, `auth-crypto`) import from anywhere,
and nothing imports them.

### Why each new layer sits where it does

**`mail`** is a leaf because two unrelated callers need it: sign-in in `auth`, and the contact
form in `features/contact`. The structure design moved the sender into `auth`. A contact form
that imports `auth` to send a message would be the wrong dependency, so the sender gets a folder
of its own and `auth` keeps only the sign-in message's wording.

**`site`** holds the adapter and the runtime, as the structure design placed it. It also takes the
site record: the TypeScript type for `cairn-site.json` and the one function that validates it
against `schema/cairn-site-1.schema.json`. The Vite plugin, `scaffold`, and the command all read
the record through that function.

**`stock`** is theme-neutral. A loader in `stock` returns typed data and knows nothing about how a
theme draws it. Exactly one module, `stock/site.ts`, imports the virtual id `virtual:site-config`
and exports the composed runtime, the content resolver, and the site's metadata. Every other
stock module imports from `stock/site.ts`. `check:layers` holds that rule with one line: no other
file may name the virtual id.

**`features`** sits above `stock` and below `themes`. A feature ships a plain view that works under
any theme. A theme may ship its own view for a feature's page, which is why themes come later.

A feature reaches the running site through generated code, because `stock` sits below `features`
and may import none of them. The Vite plugin in the `vite` layer writes the `virtual:site-config`
module from the site's record. The module holds one import for each feature the record lists,
naming that feature's concept module, beside the site's `cairn.config.ts`. `stock/site.ts` reads
the module as a `SiteConfig`, a type the `site` layer defines. A feature's loaders import
`stock/site.ts` like any other loader. No file in `stock` names a feature, so `check:layers`
holds the order with no exception.

**`themes`** moves from the top-level `themes/` folder into `src/lib/themes`. Inside the package a
theme's components get built types, the layer check covers them, and a shell can import them by a
published path.

**`scaffold`** is above the themes because it names them. It holds three functions and their data.
`siteFiles(record)` returns every file a made site holds, each with its path, its kind (owner's,
shell, or generated), and its text. `shellFor(route, record, taken)` returns one route's shell.
`wranglerConfig(record, resources)` serializes a site's first `wrangler.jsonc` from the record and
the resources `cairn new` made: the Worker's name, the database's id, and the bucket's name. The
record holds none of those three. The functions are pure, so
the showcase test, the command, and a unit test all call the same code. The command hand-over
placed this table inside the command as `site-files/`. I put it in the engine, because the
showcase must equal it and the showcase can't import the command.

**`cli`** is last. It may import everything, and one ESLint `no-restricted-imports` rule says
nothing outside `cli/` imports it, `node:http`, `node:child_process`, or the keyring package.

## The seam between the command and the engine

The Go tool couldn't import the engine, so the repo kept a second copy of each shared fact and a
check to hold the copies together. In the target the command holds no copy of anything the engine
knows.

| The command needs | It imports |
| --- | --- |
| The record's shape and validation | `site` |
| Kinds, features, menus, sets | `definitions/*.json`, `sets/` |
| Every file of a made site and each shell's text | `scaffold` |
| A site's first `wrangler.jsonc`, and what the record fixes in it | `scaffold` `wranglerConfig` |
| Failure conditions and their wording | `diagnostics` |
| Log event names | `log` |
| The site's configured values (`mediaBucketBinding`, `roles`, `aiPosture`) | the site's `cairn.config.ts`, evaluated through Vite by `vite` |
| GitHub App signing and repository calls | `github` |
| The agent contract | `docs/admin/set-up-with-an-agent.md`, shipped in the package |

Three things follow. `site-facts.json` and the functions that write and read it go, because
`doctor` evaluates the config. The `config.site-record` check in `doctor` reads the site's
`wrangler.jsonc` and compares what the record fixes in it: the site's address, each binding a
listed feature needs, and `migrations_dir`. The file is the owner's, so a binding, a cron, or a
variable the owner added passes. `wranglerConfig` writes the address by serializing a value,
which replaces the starter's unit test. The check that held the Go tool's conditions
equal to the engine's has nothing to guard.

Only the command holds provider clients, the browser sign-in's loopback server, the keyring,
terminal views, child processes, and the files that record what a site took over.

## The `cairn` command

One bin, `cairn`, at `dist/cli/bin.js`. The three bins of today become subcommands: `cairn audit`,
`cairn guidance`, `cairn manifest`. The names `cairn-audit`, `cairn-guidance`, and
`cairn-manifest` go.

```
src/lib/cli/
  bin.ts        parse the command line, dispatch, set the exit code
  commands/     one thin file per command
  report/       one outcome model, printed as text or as --json; the output scrubber
  doctor/       one module per check
  site/         pages, take-over, changes, give-back, update, add
  secrets/      keyring.ts, env.ts
  providers/    cloudflare.ts, cloudflare-oauth.ts, github-setup.ts, transport.ts
  health/       one module per probe
  setup/        cairn new: the step table, the runner, resume state, the loopback, the event stream
  term/         palette, ground detection, the inline frame, prompts, one file per screen
```

| Command | What an owner or an agent gets |
| --- | --- |
| `cairn new` | From nothing to a deployed site and a sign-in link. Resumable from the site folder. An agent drives it through `--json` events. |
| `cairn doctor` | "Is my site's folder set up right?" No credentials. |
| `cairn health`, `cairn logs` | "Is my live site working?" and what it logged. Run in the site's folder. |
| `cairn auth set / unset / list / check` | Stores and tests the read credentials `health` and `logs` use. |
| `cairn pages` | Lists every stock page and theme part, and which ones the site took over. |
| `cairn take-over <page>` | Makes a page or a part the site's. |
| `cairn changes <page>` | Shows what changed in the stock page since the site took it over. |
| `cairn give-back <page>` | Returns a page or a part to stock. |
| `cairn update` | Installs the new version, checks the site, and ends with a plain report. |
| `cairn add <feature>` | Adds a feature's shells and one line in the record. |
| `cairn audit`, `cairn guidance`, `cairn manifest` | Today's three bins. |
| `cairn help agents` | Prints the agent contract. |

Every command prints through `report/`, as text for a person or as `--json` for an agent, and each
`--json` form has a schema file under `schema/`. Arguments are parsed with `node:util`
`parseArgs`. The command never contacts the npm registry on its own. Only `cairn update` looks.

The command hand-over (`~/.local/state/desk/handover/2026-11-17-cairn-command-design.md`) holds
the step list, the credential rules, the provider choices, and the two throwaway builds. I take
all of it except where this file says otherwise. Two commands of the Go tool have no place in
the target unless Geoff rules otherwise on the queue page: the workstation's list of sites
(`sites`, `adopt`) and shell `completion`.

### The launcher

`create-cairn-site` is a workspace package of about 40 lines with no dependencies. It makes the
folder, writes a `package.json` that depends on `@glw907/cairn-cms` at exactly its own version,
runs `npm install`, and runs `node_modules/.bin/cairn new` there. The command that sets a site up
is then the copy the site keeps. Setup state lives in the site folder in a git-ignored file, with
secrets in the keyring, so `cd my-club && npx cairn new` resumes a stopped run.

## What a made site contains

`cairn new` writes files from `scaffold` and copies no code. A new site holds about 62 written
files, by the site-update session's count.

| Kind | Examples | Who changes it |
| --- | --- | --- |
| Owner's files | `src/content/**`, `site.config.yaml`, `src/site/cairn.config.ts`, `cairn-site.json`, `wrangler.jsonc`, `src/site/overrides.css` | The club |
| Shells | one per stock route file, plus `src/hooks.server.ts` and `src/params.ts` | Nobody, until a take-over |
| Generated | `app.html`, `vite.config.ts` (which holds SvelteKit's config; a made site has no `svelte.config.js`), `tsconfig.json`, `package.json` scripts, `.github/workflows/*.yml` | `cairn update` |

A shell is two lines for a server file and a few more for a page:

```ts
// src/routes/(site)/+page.server.ts
export { load } from '@glw907/cairn-cms/stock/home';
export const prerender = true;
```

```svelte
<!-- src/routes/(site)/+page.svelte -->
<script lang="ts">
  import Home from '@glw907/cairn-cms/themes/waymark/Home.svelte';
  let { data } = $props();
</script>

<Home {data} />
```

A shell names its theme in the import path. `cairn-site.json` gains a `theme` key, and
`shellFor` reads it. Page options such as `prerender` stay literal in the shell, because
SvelteKit reads them statically.

`app.html` is the same file in every site, byte-identical across themes. The `themes-1` planner
picks between two forms that both meet that test: every theme names its daisyUI themes `light`
and `dark` so the no-flash script is constant, or the packaged request hook writes the script.

The package's migrations are one sequence. A site's `wrangler.jsonc` points `migrations_dir` at
`node_modules/@glw907/cairn-cms/migrations`. No per-feature migration mechanism exists, because
no planned feature needs a table.

Every made site applies the whole sequence. That gives every site the `audit_log` table from
`0002_audit.sql`, which stays empty until the site wires the audit sink. `wranglerConfig` writes
`migrations_dir` into the first `wrangler.jsonc`, and the file is the owner's from then on. A
second database is the site's own, with a folder of its own, as the showcase's sign-up demo has.

## The update model

**A shell or a generated file is stock until someone edits it.** No marker in the file says so.
`.cairn-stock/index.json` records a hash of each one as the command last wrote it, and the
command compares. `new`, `add`, `update`, `take-over`, and `give-back` keep the index current. A
site with no index gets one on the first command: each file equal to the installed version's
`siteFiles` output is recorded as stock, and every other file is the owner's. The first draft
compared a route file with `shellFor` alone. A shell whose stock text changed between two
versions would then have looked edited.

**Taking over a page** writes the stock source over the shell, in the route file. The route file is
then the page, where a SvelteKit developer expects it. The command rewrites the source's relative
imports to the package's published paths. It saves a pristine copy of what it wrote under
`.cairn-stock/` in the site, with one line in `.cairn-stock/index.json` naming the route file, the
stock module, and the version. That folder is committed.

Take-over copies views and parts, never server code. A page's server file stays a re-export, so
the data a taken-over view receives still comes from `stock` and keeps its type. A developer who
wants different data edits the server file by hand, as in any SvelteKit site. The file's hash
then differs from the index's, and `cairn update` leaves it alone and names it in its report.

**Taking over a named part** (a theme's `EntryRow`, say) copies the part to `src/parts/` and
regenerates the shell of each page that uses it, with `parts={{ EntryRow }}`. A stock view takes
`parts` as a typed prop and falls back to its stock part.

**Showing changes** diffs the pristine copy against the installed version's stock source. It needs
no hash and no registry fetch. The site-update hand-over leaned to fetching old source from npm. A
saved copy is simpler, works offline, and can't nag.

**Giving back** restores the shell and removes the pristine copy. It refuses when the site's copy
differs from the pristine one, and `--force` overrides.

**`cairn update`** needs a clean git tree. It installs the new version, runs the site's type check
and record check, and writes a shell for each route the release added to the base or to a feature
the site has. A path the site already occupies is left alone and named in the report. Three
more cases follow one rule, which is that the command rewrites what nobody edited and names what
somebody did. A shell whose stock text changed is rewritten when untouched. A generated file
that changed, such as `vite.config.ts` or a workflow, is rewritten when untouched, and when it
was edited the report prints the change to apply by hand. A route the release dropped loses its
untouched shell, and a taken-over page there stays. If a check
fails, the command restores `package.json` and the lockfile, reinstalls, and names the page and
the reason. Nothing is half-changed, because git held everything else.

**What makes take-over safe to promise.** The package ships `src/lib/{stock,features,themes}`
beside `dist`, with declaration maps. Go-to-definition in an editor then lands on readable
TypeScript, and take-over copies that same source. That is shown for a `.ts` module. For a
`.svelte` view it is expected and unproven. `stock-1` tests it, and if the editor lands on the
`.svelte` file under `dist` instead, this paragraph is corrected to say so. That file is
readable source too, and take-over copies from `src/lib` either way. A check holds that every relative import in a
view or a part resolves to a published path. That list of published paths is the theme contract:
what a taken-over page may rely on across updates.

## Routing

The engine's catch-all route serves pages and posts. A concept whose pages a site route serves
carries the routing value `'custom'`. The engine still knows each such entry's address. It lists
them in the sitemap, the link picker, `cairn:` links, and the menu editor, and its catch-all
leaves those addresses to the site's route. In the target that site route is a feature's shell.
`conceptEntryLoad` in `stock` is the one loader a feature's entry page calls. The edit screen
shows the full address for every kind.

The home page's view moves from the showcase's route file into each theme. That reopens ruling
`scope-verdict-page-home`, which said the route is site-owned so `src/lib` doesn't change. Its
"reopens on" clause is a need the template route can't meet without engine code, and the update
model is that need.

## The admin

`createCairnAdmin` is the one way to mount the admin, and `stock` calls it. The admin's client
code reaches the server through `postAdminAction`, which sends the CSRF header. `EditPage.svelte`
is split: state in five modules, markup in child components, dialogs on one `AdminDialog` shell.
`admin-toolkit` doesn't import `admin`, `sveltekit` doesn't import `admin`, and `admin` doesn't
import the root entry.

The packaged request hook holds the development gate. In a dev build it loads the fake backend
from `@glw907/cairn-cms-dev`, which stays a separate dev-only package. Folding it into the engine
would put a fake sign-in inside the package every production site installs.

## Themes and the catalog

A theme is a folder under `src/lib/themes` holding views, named parts, tokens, color modes, fonts,
and a manifest. Waymark, Pennant, and Survey ship in the package. Every theme holds a view for
every stock page and every feature page, so any theme builds any site. The manifest lists the
kinds a theme was made for, and that list decides what `cairn new` offers (Geoff,
`20261117-210356-a03b21`, question 6). The theme's CSS entry carries
the Tailwind 4 `@source` line for its components, as `admin-sources.css` does for the admin today.

With themes in the package, the catalog is a gallery of demos. Theme archives and the rule that a
theme's version must rise lose their job. Ruling `scope-verdict-361` put "a theme shipped as an npm
dependency that updates in place" out of scope, and Geoff's update page overturns that clause:
"The theme follows the same rule as a page."

## Checks and their runner

`scripts/checks/registry.mjs` is the one list of checks. `scripts/checks/run.mjs` builds once and
runs a group. `package.json` scripts, the close gate, the docs gate, the gate tiers, and the fast
lane all read the registry, and a unit test holds `package.json` equal to it. Every check script
has one form: a shared helper, `OK` or `FAIL`, and an exit code.

Checks the route adds: `check:layers`, `check:errors` (no plain throw where the typed-error rule
asks for a condition, and a named list of at most 55 plain throws that mark a programmer's
mistake), the theme contract check, the showcase-equals-scaffold test, and the two
docs checks that return fed by the new command (flags, and quoted terminal output).

Checks the route removes with the code they guard: the template drift checks,
`check:chassis-boundary`, and every check whose subject was the Go tool.

## CI

Each CI job calls the runner with one group, so `test.yml` and `design.yml` name no check script.
No workflow sets up Go: `actionlint` runs from its published binary. One job makes a site with the
real `cairn new` against a fake provider server, builds it, and runs its tests. `publish.yml`
publishes the engine, `cairn-cms-dev`, and the launcher at one version.

## The repo's top level

| Path | State in the target |
| --- | --- |
| `src/lib/**` | The package, as above |
| `examples/showcase` | A committed site of shells plus test routes and the e2e suite, held equal to `scaffold` by a test |
| `packages/cairn-cms-dev` | The dev-only fake backend |
| `packages/create-cairn-site` | The launcher |
| `definitions/`, `sets/`, `schema/`, `migrations/` | Data, as today |
| `scripts/checks`, `scripts/gate`, `scripts/release`, `scripts/catalog` | The runner, the release harness, the gallery build |
| `docs/`, `skills/`, `plugins/`, `claude/` | Docs and agent material |
| `templates/`, `themes/`, `tool/` | Gone |

Gone with `templates/`: `bake-template.mjs`, `emit-template*.mjs`, the exclude markers,
`lay-in.mjs`, `theme-names.mjs`, `starter-overlay`, `setup-overlay`, `pack-engine-template.mjs`,
and the `template` entry in the package's `files`.

## Docs a release needs

- `docs/admin/**`: every page that names a `cairn` command, rewritten against the command that
  exists. The note the Go deletion added is gone.
- A site developer's guide to the update model: what a shell is, taking a page over, reading
  `cairn changes`, giving a page back.
- A theme author's guide: the views a theme supplies, the named parts, the contract.
- `docs/architecture.md`: the layer table above.
- The changelog and the migration notes for one release.

## Reuse or rewrite, part by part

| Part | Call | Reason |
| --- | --- | --- |
| `content`, `render`, `media`, `nav`, `auth`, `github`, `delivery`, `sveltekit`, `admin` | Reuse, with the structure design's renames, moves, and sweeps | The forms are right. The faults are 32 upward imports, 169 plain throws, and names nobody uses. |
| `EditPage.svelte` (2,924 lines) | Reuse, split | The behavior is tested and the visual baselines hold it. |
| The showcase's chassis and routes, which the template copies | Move into `stock` and the themes, reshaped | The code is sound. Its home is wrong. |
| The template's build (`bake`, `emit`, overlays, markers) | Delete | `scaffold` replaces it with functions. |
| The Go tool (34,000 lines) | Rewrite as about 11,500 lines of TypeScript | It couldn't share code with the engine. The hand-over's size table is the estimate. |
| The three bins' hand-written parsers | Rewrite on `parseArgs` | One parser. |
| `scripts/checks/**` | Reuse on one helper | The checks are right, and their forms differ. |
| The catalog's archive and version-rise scripts | Delete | Themes ship in the package. |
| Survey's approved design | Reuse the look, rewrite the plan | It was drawn for `themes/survey/` as a copied folder. |

## Sources

- SvelteKit, "Packaging", "Source maps": "You can create so-called declaration maps (`d.ts.map`
  files) by setting `"declarationMap": true` in your `tsconfig.json`. This will allow editors such
  as VS Code to go to the original `.ts` or `.svelte` file when using features like _Go to
  Definition_. This means you also need to publish your source files alongside your dist folder".
  <https://svelte.dev/docs/kit/packaging>
- The same page, "Best practices": "`svelte-package` rewrites `#`-prefixed imports from your
  package.json `imports` field to relative paths when packaging."
- The shell spike summarized in the site-update hand-over
  (`~/.local/state/desk/handover/2026-11-17-site-update-design.md`): re-exported `load`, the
  virtual site config, `import.meta.glob` from a package, packaged migrations, the `parts` prop,
  and one-line `hooks.server.ts` and `params` shells all ran in a build and in `vite dev`.
- The two throwaway builds in `~/.local/state/desk/handover/2026-11-17-cairn-command-design-files/`:
  the keyring on Linux, and the watch screen.
- Node, `util.parseArgs` and `util.styleText`. <https://nodejs.org/api/util.html>
