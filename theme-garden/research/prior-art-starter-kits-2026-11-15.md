# Prior art: starter kits, per-site values, and the record left behind

Date: 2026-11-15. Public pages only. Method: pages fetched through a summarizing fetcher, so quotes are as the fetcher returned them; a few claims come from search-result snippets and are marked. "Unconfirmed" means no primary source was reached. No design recommendations.

## 1. Copier, Cookiecutter, Cruft

### Copier
- Unit: a template directory, "usually the root folder of a Git repository", declared by `copier.yml`. https://copier.readthedocs.io/en/stable/creating/
- Fields in `copier.yml`: questions (simple form `name_of_the_project: My awesome project`, or a dict with `type`, `help`, `choices`, `default`, `secret`, `validator`, `when`); underscore settings `_subdirectory` ("Subdirectory to use as the template root"), `_exclude`, `_skip_if_exists`, `_tasks` ("Commands to execute after generating or updating"), `_migrations` (tasks with an optional `version`; "If no version is specified the migration will run on every update"), `_answers_file`. https://copier.readthedocs.io/en/stable/configuring/
- Composition: one tree. Files are copied unchanged "unless they end with `.jinja`"; file and folder names may contain Jinja; `yield` in names generates several files from a list. Optional parts are conditional via `when` on questions and Jinja in names (the names page shows templated names; conditional names are not described there). https://copier.readthedocs.io/en/stable/creating/
- Parameters: Jinja rendering of `.jinja` files and names.
- Record: `.copier-answers.yml` (default `_answers_file`), made from a template file `{{_copier_conf.answers_file}}.jinja` containing `{{ _copier_answers|to_nice_yaml -}}`. It holds the answers plus `_commit` (example `0.1.0`) and `_src_path` (example `gh:your_account/your_template`), "indicating how the last template update was done". The file says "NEVER EDIT MANUALLY". https://copier.readthedocs.io/en/stable/creating/ and https://copier.readthedocs.io/en/stable/configuring/
- Committed: it must be in the project for update to work ("The destination folder has a valid `.copier-answers.yml` file"). https://copier.readthedocs.io/en/stable/updating/
- Update: `copier update` "regenerates a fresh project from the current template version", diffs it against the current project, runs pre-migrations, applies the template changes, re-applies the project's own diff, then runs post-migrations. Needs a git-tagged template and a git-versioned, clean destination; tags compared by PEP 440. Conflicts: `--conflict inline` (default, markers) or `rej` (`.rej` files). Limits quoted from the page: hand-editing the answers file is "an unsupported way to update"; files deleted from the project are excluded from future updates; aborting a conflicted update is not simple (`git merge --abort` does not work); `copier recopy` regenerates "like a first-time application", overriding local changes. https://copier.readthedocs.io/en/stable/updating/
- Testing: no FAQ entry on testing templates; `-r HEAD` tests uncommitted template work. Credentials embedded in an HTTPS clone URL get saved to the answers file. https://copier.readthedocs.io/en/stable/faq/

### Cookiecutter
- Unit: a template with `cookiecutter.json` (prompts and defaults), a `{{ cookiecutter.project_name }}/` directory, and pre/post-gen hooks. https://cookiecutter.readthedocs.io/en/stable/overview.html
- Hooks: `pre_prompt`, `pre_gen_project`, `post_gen_project` in the template's `hooks/` folder, Python or shell; "The `pre_gen_project` and `post_gen_project` hooks support Jinja template rendering"; variables are not available to `pre_prompt`; `pre_prompt` works on a copy of the repository, "which allows the rewrite of `cookiecutter.json`". https://cookiecutter.readthedocs.io/en/stable/advanced/hooks.html
- Record: not in the project. Replay dumps "a json file to `~/.cookiecutter_replay/`" with a top-level `"cookiecutter"` object; `--replay` reuses it; `--replay-file` (new in 2.0) takes a chosen file. https://cookiecutter.readthedocs.io/en/stable/advanced/replay.html
- Update: none in Cookiecutter itself (replay "is useful for creating a new project from an updated template", per the replay page). Conditional parts: the overview page does not describe them; the usual route is a post-gen hook (unconfirmed from the pages fetched).

### Cruft
- Adds `.cruft.json` to a Cookiecutter project: "contains the git hash of the template used as well as the template variables specified", plus optional `skip` entries. `cruft update` shows changes for review, applies them, updates `.cruft.json`; `--variables-to-update` (JSON string) and `--variables-to-update-file` change variables. `cruft check` exits 1 when out of date, for CI. `cruft link TEMPLATE_REPOSITORY` attaches an existing Cookiecutter project. Cruft "retains full compatibility with all existing Cookiecutter templates". https://cruft.github.io/cruft/

## 2. Yeoman, Nx, Plop

### Yeoman
- Unit: a generator (npm package). Substitution: `copyTpl` "is using ejs template syntax"; all writes go to an in-memory file system, and "every write happening on a pre-existing file will go through a conflict resolution process". https://yeoman.io/authoring/file-system.html
- Record: `.yo-rc.json`, "a JSON file where configuration objects from multiple generators are stored"; each generator's section is namespaced; it "also determines the root of a project". Generators use `config.get`, `config.set`, `config.save`, `config.getAll`, `config.delete`, `config.defaults`. Sub-generators can share it; separate generators pass data through options and arguments. https://yeoman.io/authoring/storage.html
- Update: none described on these pages.
- Regret: "Though no longer at the cutting edge of web tooling"; "After some sporadic updates in recent years, we're now prioritizing stability"; "Some older, less relevant projects will be deprecated to streamline maintenance." https://yeoman.io/blog/maintenance-reboot

### Nx generators
- Unit: "generators are just functions with a specific signature and input options that get invoked by Nx", shipped in plugins, run as `nx g <plugin>:<generator> [options]`. https://nx.dev/docs/features/generate-code (the page does not cover `generators.json`, `schema.json`, templating, or a run record).
- From a search snippet only (unconfirmed from a primary page; the nx.dev creating-files URLs returned 404 here): `generators.json` registers generators, `schema.json` declares options, `generateFiles(tree, srcDir, targetDir, substitutions)` applies EJS and `__name__` filename placeholders.
- Record of runs and update: unconfirmed.

### Plop
- Unit: a plopfile, `plop.setGenerator(name, config)`, config holding `prompts` ("questions to ask the user"), `actions`, optional `description`. Actions `add`, `addMany` (`destination` plus `templateFiles` glob), `modify` (`pattern` find-and-replace and/or `transform`), `append`. Templates are Handlebars; `templateFile` points to a template file; action `data` is "mixed with user prompt answers". No record file described. https://plopjs.com/documentation/

## 3. Create-tool family

### create-astro
- `--template` takes an official example name or a GitHub repo (`main` by default, `<user>/<repo>#<branch>` for another). `--add` installs integrations during setup, for official and "community integrations that support the `astro add` command". https://docs.astro.build/en/install-and-setup/
- CLI reference entry: "Adds an integration to your configuration." The page does not say how the config is edited. https://docs.astro.build/en/reference/cli-reference/
- Record, update, testing: unconfirmed. The astro monorepo `ci.yml` does not mention `examples/` or `create-astro` in any job. https://raw.githubusercontent.com/withastro/astro/main/.github/workflows/ci.yml

### sv create and sv add (Svelte)
- `sv create` options: `--template <name>` (`minimal`, `demo`, `library`, `addon`), `--types`, `--add [add-ons...]`, `--no-add-ons`, `--install <package-manager>`. https://svelte.dev/docs/cli/sv-create
- `sv add` "updates an existing project with new functionality"; official add-ons: ai-tools, better-auth, drizzle, enhanced-img, eslint, mdsvex, paraglide, playwright, prettier, storybook, sveltekit-adapter, tailwindcss, vitest; community add-ons are npm packages or `file:../path`. Options: `-C/--cwd`, `--no-git-check` ("Do not warn about uncommitted changes."), `--no-download-check`, `--install`, `--no-install`. https://svelte.dev/docs/cli/sv-add
- AST edits (not string patches): `@sveltejs/sv-utils` offers `transforms` described as "parser-aware functions that lets you modify the files via abstract syntax tree (AST)"; kinds `transforms.script`, `svelte`, `svelteScript`, `css`, `json`, `yaml`/`toml`, `text`. Rationale quoted: "you can't accidentally parse a vite config as Svelte because you never call a parser yourself." Returning `false` leaves the file unchanged. Docs recommend bundling sv-utils "to pin its version". https://raw.githubusercontent.com/sveltejs/cli/main/documentation/docs/50-api/20-sv-utils.md (also listed at https://svelte.dev/docs/cli/sv-utils)
- Record: neither the sv-create nor sv-add page mentions a record file. Unconfirmed whether any is written.
- Keeping starters working: `ci.yml` runs `pnpm test:ci` on Ubuntu, Windows, macOS, and an `addon-integration-tests` job (`pnpm test:addons`) only on pull requests labeled `needs-addon-integration-tests`. A manual workflow `update-starters.yml` ("Update starters (manual)") picks `kit-template-default` or `kit-template-railway` and runs `pnpm update:kit-starter` or `pnpm update:railway-starter` using SSH-key secrets. https://raw.githubusercontent.com/sveltejs/cli/main/.github/workflows/ci.yml and https://raw.githubusercontent.com/sveltejs/cli/main/.github/workflows/update-starters.yml

### create-next-app
- Unit: the default template or an "example" from `https://github.com/vercel/next.js/tree/canary/examples`, chosen by `-e/--example [name] [github-url]` and `--example-path`. Option flags: `--ts/--js`, `--tailwind`, `--react-compiler`, `--eslint`, `--biome`, `--no-linter`, `--app`, `--api`, `--src-dir`, `--turbopack`, `--webpack`, `--import-alias`, `--empty`, `--agents-md`, `--skip-install`, `--disable-git`, `--yes`. `--reset-preferences` "reset any stored preferences", and `--yes` "Use previous preferences or defaults"; a prompt offers "No, reuse previous settings". So choices are remembered in the tool, not (per this page) in the project. https://nextjs.org/docs/app/api-reference/cli/create-next-app

### create-t3-app
- Positioning: it is "NOT an all-inclusive template"; each piece is optional. https://create.t3.gg/en/introduction
- Composition by installer module: `export type Installer = (opts: InstallerOptions) => void;` `availablePackages` = `nextAuth`, `betterAuth`, `prisma`, `drizzle`, `tailwind`, `trpc`, `envVariables`, `eslint`, `biome`, `dbContainer`. `buildPkgInstallerMap` maps each to an installer with an `inUse` flag; `dbContainer` is `inUse: ["mysql", "postgres"].includes(databaseProvider)`; `envVariables` is always `inUse: true`. https://raw.githubusercontent.com/t3-oss/create-t3-app/main/cli/src/installers/index.ts
- Testing: `.github/workflows/e2e.yml` runs `generate-matrix` (`node .github/scripts/generate-matrix.js`), scaffolds every valid combination outside the CLI project ("so that no lint/tsconfig are leaking") and runs `pnpm build` on each; a separate job toggles ESLint and Biome and runs lint or `pnpm check`; one Bun job. https://raw.githubusercontent.com/t3-oss/create-t3-app/main/.github/workflows/e2e.yml . `ci.yml` has no scaffold matrix. https://raw.githubusercontent.com/t3-oss/create-t3-app/main/.github/workflows/ci.yml
- Record in the project: unconfirmed.

### create-vite, degit, giget
- create-vite: 18 template names (`vanilla`, `vanilla-ts`, `vue`, `react`, `react-compiler`, `svelte`, `solid`, `qwik`, plus `-ts` variants, and others); `--template`, `--no-interactive`; community templates go to Awesome Vite; the page shows `npx tiged user/project my-project`. https://vite.dev/guide/#scaffolding-your-first-vite-project . The repo has `template-*` directories. https://github.com/vitejs/vite/tree/main/packages/create-vite . The Vite `ci.yml` fetched has a path filter `packages/create-vite/template**` and jobs `test-unit`, `test-serve`, `test-build`; whether any job builds each template is unconfirmed. https://raw.githubusercontent.com/vitejs/vite/main/.github/workflows/ci.yml
- degit: "makes copies of git repositories"; no leftover `.git` folder; "Composable post-clone actions via `degit.json`" (details not on the README page). https://github.com/Rich-Harris/degit
- giget: "Download templates and git repositories"; built-in registry (JSON with `name`, `tar`, optional `defaultDir`, `url`, `subdir`, `headers`); providers GitHub, GitLab, Bitbucket, Sourcehut, `git:`; `--install`, `--ignore`. https://github.com/unjs/giget
- None records anything in the copied tree on these pages.

## 4. Rails, Laravel

### Rails application templates
- Unit: a Ruby script, "simple Ruby files containing DSL for adding gems, initializers, etc." Applied with `rails new blog -m ~/template.rb` (path or URL) or `rails app:template` with `LOCATION` for an existing app. DSL: `gem`, `gem_group`, `add_source`, `environment`/`application`, `initializer`, `lib`, `vendor`, `file`, `rakefile`, `generate`, `run`, `rails_command`, `route`, `inside`, `ask`, `yes?`, `no?`, `git`, `after_bundle`. Parameters come from `ask` and `yes?` at run time. No re-apply guidance and no record. https://edgeguides.rubyonrails.org/rails_application_templates.html (fetched via the redirect target http://edgeguides.rubyonrails.org/rails_application_templates.html)

### Laravel
- Unit: an application starter kit (React, Svelte, Vue, Livewire; WorkOS variants), chosen by prompts from `laravel new my-app`. Community kits: `laravel new my-app --using=example/starter-kit`; publish to Packagist; "define its required environment variables in its `.env.example` file", post-install commands in the `post-create-project-cmd` array of the kit's `composer.json`. https://laravel.com/docs/starter-kits
- Composition: the installer prompts choose among whole kits; teams "may also be generated with team support" (a generation option). https://laravel.com/docs/starter-kits
- Record and update: "all of the backend and frontend code exists within your application"; FAQ "How do I upgrade?": "there is no need to update the starter kit itself." https://laravel.com/docs/starter-kits
- `.env` is not committed. https://laravel.com/docs/installation

## 5. Statamic starter kits
- Unit: a starter kit declared by `starter-kit.yaml`. `export_paths` lists what is exported ("Anything not configured in your `starter-kit.yaml` **will not be exported**"), e.g. `content`, `config/filesystems.php`, `resources/views`. `dependencies` is an array, e.g. `statamic/ssg`. `modules` nest optional parts, each with its own `dependencies` and `export_paths`, and `options` nest further choices (e.g. `vue`, `react`). Post-install hook: a `StarterKitPostInstall.php` class with `handle($console)` in the kit root. Export command: `php please starter-kit:export {export_repo_path}`, `--clear` wipes configured `export_paths` first. https://statamic.dev/starter-kits/creating-a-starter-kit.md
- Modules: each has a `prompt` ("Would you like some awesome SEO with that!?"); the CLI lets users install or skip; modules can nest. https://statamic.com/blog/starter-kit-modules
- Updates: "By default, the Kit is removed after installation." With `updatable: true` in `starter-kit.yaml`, it "can be updated like any other Composer package" (`composer update`). https://statamic.dev/starter-kits/creating-a-starter-kit.md
- Content is part of the kit: `content` appears as an `export_paths` entry in the page's example. Content and theme chosen independently: unconfirmed.
- `export_as`: the page does not mention it.
- Search-result snippet only (not fetched): the Bedrock kit's release notes describe a post-install step and dropping `dependencies_dev` from `starter-kit.yaml`. https://statamic.com/starter-kits/jasonbaciulis/bedrock/release-notes

## 6. Drupal recipes, profiles, distributions
- Unit: a recipe is declarative: "Declarative, not functional: YAML, not PHP" (https://berdir.github.io/recipes), a `recipe.yml` plus `config/` and `content/`. Keys per the distributions_recipes docs: `name`, `description`, `type` (type "Site" lists it in the installer), `recipes` ("Recipes to apply before this one. If any of these recipes fail to be applied, this recipe is not applied either."), `install` (modules or themes), `input` (prompts with `data_type`, `description`, `constraints`, `form`, `prompt`, `default`; referenced as `${recipient}` in `config:actions`), `extra`, `config` (`import`, `strict`, `actions` such as `createIfNotExists`, `grantPermissions`), `content` ("All content in this directory will be created after the configuration is installed."). https://project.pages.drupalcode.org/distributions_recipes/recipe.html . Core issue comment lists name, description, type, recipes, install, config, content (search snippet, https://www.drupal.org/i/3400672).
- Composition: "Recipes can build on other recipes to create larger Recipes" (https://www.drupal.org/about/starshot/initiatives/recipes); "Drupal recipe inheritance is not possible. Drupal recipes can be composed." Composer `suggest` lists follow-on recipes. https://project.pages.drupalcode.org/distributions_recipes/recipe.html
- Parameters: `input` tokens; config actions. Application order: modules, then config, then content last. https://project.pages.drupalcode.org/distributions_recipes/recipe.html
- Record: that page lists tracking as an open question ("A log of applied recipes is proposed, possibly borrowing Symfony's `symfony.lock` idea"; reverting and re-applying "listed as unresolved"). A community write-up states: "Drupal doesn't know if you've already applied a recipe or not." and "Every time a recipe is applied, all recipes it depends on are applied again." https://berdir.github.io/recipes . Whether current core has changed this: unconfirmed. A Drupal CMS work item reports a recipe that "cannot be reapplied" (search result title, https://git.drupalcode.org/project/drupal_cms/-/work_items/3589783; not fetched).
- Updates: none. Search snippet: "recipes are apply-once and config is permanent after application" (community guide, https://camoa.github.io/dev-guides/drupal/recipes/recipe-system-overview; not fetched). Strict mode: a recipe's config can only be applied if absent or an exact match (https://berdir.github.io/recipes).
- Distributions' regrets (quoted): install profiles and distributions "are difficult to keep updated", "cannot be added after a project starts", "cannot be removed easily", "cannot be mixed and matched with other sets of functionality" (https://www.drupal.org/about/starshot/initiatives/recipes). Community list: "Difficult to update, 100% dependant"; "Can not be added to existing projects"; "Can't be removed (easily)"; "Can't combine multiple distributions"; and "Dealing with existing sites remains the hard part for a distribution." https://berdir.github.io/recipes . The Drupal.org distributions docs page returned 404 at the redirect target.

## 7. WordPress
- Starter content: themes call `add_theme_support( 'starter-content', array( ... ) )` from a function hooked to `after_setup_theme`; the Customizer reads it at priority 100. Array: widgets, posts, attachments, options, theme mods, nav menus; items may reference core-provided ones by symbol, imported ones as `{{home}}`. Loads only on "fresh sites" (`fresh_site` option `1`), appears in the Customizer preview, and nothing is live until published. Attachments must come from the theme or plugin folder. "Starter content is never copied between themes." "Content merging with existing site content was not yet implemented." https://make.wordpress.org/core/2016/11/30/starter-content-for-themes-in-4-7/
- `get_theme_starter_content()` "Expands a theme's starter content configuration using core-provided data"; `options` and `theme_mods` pass through as-is; the `get_theme_starter_content` filter alters the result. https://developer.wordpress.org/reference/functions/get_theme_starter_content/
- So sample content is declared inside the theme (code), not selectable apart from the theme.
- Playground Blueprints: "JSON files for setting up your very own WordPress Playground instance" (https://developer.wordpress.org/playground/blueprints/). Properties: `$schema`, `landingPage`, `preferredVersions` (`php`, `wp`), `steps`, `plugins`; "Shorthands such as `plugins`, `login`, `siteOptions`, and `constants` are expanded before the `steps` array" (https://developer.wordpress.org/playground/blueprints/data-format/). Steps are objects with a `step` property, e.g. `installTheme`, `installPlugin`, `importWxr`, `setSiteOptions`, `writeFile` (https://developer.wordpress.org/playground/blueprints/steps/). It is a re-runnable recipe for an ephemeral instance; no record in the site.

## 8. Ghost, Hugo, Eleventy, Jekyll, Docusaurus
- Ghost: themes carry custom settings in `package.json` at `config.custom`; types `select`, `boolean`, `color`, `image`, `text`; `default` required for select/boolean/color, not allowed for image, optional for text; optional `"group"` of `"homepage"` or `"post"`; renaming a key loses the owner's value ("losing any value entered by the site owner"). https://docs.ghost.org/themes/custom-settings . Uploaded themes are checked by GScan; fatal errors block use. https://docs.ghost.org/themes/
- Hugo: quick start uses `hugo new project quickstart` (the `hugo_new_site` page 404ed), adds the theme "as a Git submodule" in `themes/`, and appends `theme = 'ananke'` to `hugo.toml`; no `exampleSite` mention. https://gohugo.io/getting-started/quick-start/ . `hugo new theme` "generates a functional theme including template examples and sample content", into `./themes`, `--format` toml/yaml/json. https://gohugo.io/commands/hugo_new_theme/ . Components: left-most wins; "Components can only configure `params`, `menu`, `outputformats`, and `mediatypes`." https://gohugo.io/hugo-modules/theme-components/ . `exampleSite`: no official page found; community usage (demo site and config reference, run with `hugo server --themesDir ../..`, `theme.toml` metadata) per forum and theme repos. https://discourse.gohugo.io/t/how-do-i-do-theme-development-with-an-example-site-in-the-repo/2136 (search result, not fetched).
- Eleventy: "eleventy-base-blog" is the official starter; the starter page lists community starters with demos; no create tool or update mechanism mentioned. https://www.11ty.dev/docs/starter/
- Jekyll: `jekyll new` "Creates a new Jekyll site with default gem-based theme" and `--blank` creates a blank scaffold. https://jekyllrb.com/docs/usage/ . Themes are gems; activated with `theme:` in `_config.yml`; "only one theme can be selected"; the site's files win over the gem's; "making copies of theme files will prevent you from receiving any theme updates on those files." `jekyll new-theme` scaffolds a theme. https://jekyllrb.com/docs/themes/
- Docusaurus: `create-docusaurus`, "We recommend the `classic` template", `--typescript` flag for the variant. https://docusaurus.io/docs/installation . "Presets are bundles of plugins and themes"; `@docusaurus/preset-classic` "will relay each option entry to the respective plugin/theme"; set an entry to `false` to disable it. https://docusaurus.io/docs/using-plugins

## 9. Shopify, Squarespace, Wix
- Shopify `settings_data.json`: "contains the setting values for a theme based on the settings included in settings_schema.json"; `current` "Contains all of the setting values that are currently saved in the theme editor"; `presets` "Contains an object for each theme preset. Each object is in the same format as `current`." Merchant choices are written to the file. The page does not say what happens to them on theme update. https://shopify.dev/docs/storefronts/themes/architecture/config/settings-data-json
- Shopify section presets: "predefined section configurations that merchants can select when adding sections to a JSON template", with `name`, `category`, `settings`, `blocks`; `default` applies on static render. https://shopify.dev/docs/storefronts/themes/architecture/sections/section-schema
- Squarespace and Wix: no official help page reached (the Squarespace help URL 404ed; search returned third-party guides only). Unconfirmed from primary sources. Third-party claim, not primary: on Squarespace 7.1 you cannot simply switch templates; 7.0 previews show demo content you must remove. (search snippet, e.g. https://www.stylefactoryproductions.com/blog/squarespace-change-template)

## 10. Documented regrets and migrations
- Create React App: "since Create React App currently has no active maintainers, and there are many existing frameworks that solve these problems already, we've decided to deprecate Create React App."; it "will continue working in maintenance mode"; "We recommend creating new React apps with a framework" (Next.js, React Router, Expo), or Vite, Parcel, Rsbuild. Limits named: no routing, data fetching, or code splitting solution. https://react.dev/blog/2025/02/14/sunsetting-create-react-app
- Yeoman: see section 2 (https://yeoman.io/blog/maintenance-reboot). A 2025 security overhaul archived legacy generator repos (search snippet, https://yeoman.io/blog/security-overhaul-2025; not fetched).
- Drupal: distributions to recipes; quotes in section 6.
- Gatsby starters going stale: unconfirmed. Search found only opinion and news about Gatsby's slowdown after the Netlify acquisition (https://www.smashingmagazine.com/2024/03/end-of-gatsby-journey, https://github.com/gatsbyjs/gatsby/discussions/39062; not fetched), nothing about starters specifically.
- Laravel: starters are copied code; no upgrade path by design (section 4).
- Copier: update limits quoted in section 1.

## 11. Keeping the starter working, and dogfooding
- Matrix over option combinations: create-t3-app builds each valid combination (https://raw.githubusercontent.com/t3-oss/create-t3-app/main/.github/workflows/e2e.yml).
- Opt-in add-on integration tests: sv (https://raw.githubusercontent.com/sveltejs/cli/main/.github/workflows/ci.yml).
- Template repo updated by a script: sv `update-starters.yml`.
- Template-update CI check: `cruft check` exits 1 when out of date (https://cruft.github.io/cruft/).
- Demo or docs site built from the same starter: unconfirmed for all systems. Hugo's `exampleSite` is a demo inside the theme repo (community sources above). Svelte's `demo` template is "showcase app with a word guessing game" (https://svelte.dev/docs/cli/sv-create), not stated to be the docs site.

## 12. Starter content separation
- WordPress: content declared inside the theme's `add_theme_support( 'starter-content' )`, fresh sites only, never copied between themes (section 7).
- Hugo: `hugo new theme` ships "template examples and sample content" with the theme; `exampleSite` beside it.
- Statamic: `content` in `export_paths` ships with the kit; optional modules add dependencies and paths.
- Drupal: `content` directory in the recipe, created after config, "asks whether to include it" (https://project.pages.drupalcode.org/distributions_recipes/recipe.html).
- Shopify: presets carry setting values; merchant data lives in `current`.
- Squarespace 7.0: demo content removed manually (third party).
- Independent selection of a content set apart from a theme: not documented in any fetched system except Drupal's recipe split (content in its own directory, optionally skipped).

## Patterns that recur (at least three systems)
1. Starter as a plain file tree plus a small declaration file: Copier (`copier.yml`), Cookiecutter (`cookiecutter.json`), Statamic (`starter-kit.yaml`), Drupal (`recipe.yml`), Ghost (`config.custom`), Shopify (`settings_schema.json`), Plop (plopfile).
2. Per-site values by template-engine substitution with prompts: Jinja (Copier, Cookiecutter), EJS (Yeoman, Nx snippet), Handlebars (Plop), Ruby `ask` (Rails), Drupal `input` tokens.
3. Copy-once, then the project owns the code: Laravel ("no need to update the starter kit"), Rails templates, degit/giget, create-next-app, create-vite, Statamic (kit removed by default), Jekyll copies lose updates.
4. Optional parts as prompted, nested modules or per-option installers: Statamic `modules`/`options`, create-t3-app installers, sv add-ons, Laravel kit choice and teams, Astro `--add`, Docusaurus preset toggles.
5. Post-generation hook or task list: Copier `_tasks`, Cookiecutter hooks, Statamic `StarterKitPostInstall.php`, Laravel `post-create-project-cmd`, Rails `after_bundle`, Plop actions.
6. Authored settings kept apart from theme code, keyed by schema: Ghost `config.custom`, Shopify `settings_data.json` (`current`, `presets`), Hugo `params` precedence.
7. Version-controlled install without a project-side record in most create tools: create-vite, degit, giget, create-astro, sv add, Laravel (none documented).
8. Only a few systems leave a record that supports updates: Copier `.copier-answers.yml`, Cruft `.cruft.json`, Yeoman `.yo-rc.json` (config only), Statamic `updatable: true` via Composer.
9. Starters age and tooling is deprecated: CRA, Yeoman, Drupal distributions.

## Where systems disagree
- Record or none: Copier and Cruft write a committed record with source, commit, and answers; Cookiecutter keeps answers outside the project (`~/.cookiecutter_replay/`); create-next-app keeps preferences in the tool; most create tools write nothing documented; Drupal has no applied-recipe log (an open design question on the docs page).
- Update model: Copier regenerates and re-applies the project's diff (merge conflicts as markers or `.rej`); Cruft applies a reviewed diff; Statamic uses Composer; Laravel declines to offer one; Drupal recipes are apply-once; Jekyll updates the gem but not copied files.
- Whole tree versus parts: Laravel and Next kits are whole trees with a few flags; create-t3-app and sv build from per-option modules; Statamic and Drupal compose by dependencies and nested modules; Docusaurus bundles plugins in a preset.
- How files get edited: Plop `modify` uses regex `pattern` or `transform`; sv add-ons use AST transforms (with a text transform as an option); Yeoman uses an in-memory file system with conflict prompts; Copier uses a diff merge; Drupal uses config actions, not text edits.
- Where sample content lives: inside the theme (WordPress, Hugo), inside the kit (Statamic), in the recipe's own `content/` (Drupal), or demo-only with manual removal (Squarespace 7.0, third party).
- Testing: create-t3-app builds a generated matrix per PR; sv runs add-on integration tests opt-in by label; Vite's template path appears filtered out of its CI trigger; Astro's CI does not mention the examples (all as read from the workflow files fetched).
- Maintained pieces: Yeoman revived for stability; CRA in maintenance mode; Drupal recommends recipes over distributions.
