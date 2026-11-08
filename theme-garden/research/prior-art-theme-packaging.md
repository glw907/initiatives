# Prior art: packaging, hosting, fetching, and pinning site themes

Research for cairn's theme packaging design (copy-in, look-only, fixed content model, small catalog).
Every claim carries its source URL. Where a primary source did not settle a point, the text says so.

---

## 1. WordPress

**Package.** `style.css` is the only file every theme needs, in the theme root; its header carries Theme Name, Author, Description, Version, Requires at least, Tested up to, Requires PHP, License, License URI, Text Domain (all required for the directory). A child theme adds `Template:` naming the parent's folder. https://developer.wordpress.org/themes/basics/main-stylesheet-style-css/
Block themes also need `readme.txt`, `theme.json`, and `templates/index.html`. https://make.wordpress.org/themes/handbook/review/required/

**Catalog.** wordpress.org theme directory, zip upload, human review. Requirements: GPL-compatible everything with a single credits file, a screenshot of at most 1200x900 at 4:3 that does not look like an ad, no "plugin territory" features (analytics, SEO, forms belong in plugins), no remote resources without consent (Google Fonts excepted), no `.git` or hidden files, one new theme in review at a time, and three or more distinct issues closes the ticket. https://make.wordpress.org/themes/handbook/review/required/

**Fetch and pin.** Install from the directory by slug; the directory serves the latest version. (No lockfile or integrity concept in core; not documented on the pages above.)

**Options.** `theme.json` settings and styles; style variations are extra JSON files in `/styles/*.json` with the same shape. When a user picks one, its JSON is **copied into the database as a user customization**, so later edits to that variation file never reach sites that already applied it; the docs' workaround is to switch away and back. https://developer.wordpress.org/themes/global-settings-and-styles/style-variations/

**Change after adoption.** Updates overwrite the theme's files, so direct edits are lost ("the next time your theme is updated, your function will disappear!"). The sanctioned answer is a child theme that overrides by filename; for extensive changes the docs suggest forking into a full theme. User customizations live in the database as a fourth layer over core, parent, and child. https://developer.wordpress.org/themes/advanced-topics/child-themes/

**Validation.** Theme Check plugin, then human review against the requirements list. https://make.wordpress.org/themes/handbook/review/required/

## 2. Ghost

**Package.** A zip with `index.hbs`, `post.hbs`, and `package.json` required; `default.hbs` and `assets/` recommended. `package.json` carries name, version, description, license, author, `screenshots` (desktop, mobile), and `config` (`posts_per_page`, `image_sizes`, `card_assets`, `custom`). https://docs.ghost.org/themes/structure/

**Options.** `config.custom`: five types (select, boolean, color, image, text), at most 20 settings, optional `group` (homepage, post), and `visibility` conditions. Owners set values in Ghost Admin. **Renaming a key in a new version is a breaking change**: the old value is dropped and the new key starts at its default; no migration path exists. https://docs.ghost.org/themes/custom-settings/

**Catalog.** Ghost Marketplace, curated: a checklist, a working demo over SSL embeddable in an iframe from ghost.org, and "only the very best themes"; forum threads report months without status. https://ghost.org/themes/submit , https://forum.ghost.org/t/theme-submission-status/62948

**Fetch and update.** Zip upload into Ghost Admin; an update is a new zip that replaces the old one (no merge with local edits).

**Validation.** gscan, with errors (must fix; fatal means 500s), warnings (deprecations), recommendations, and detected features; targets a Ghost major via `-1`..`-6`; runs on folder or zip; pre-installed in Ghost. https://github.com/TryGhost/gscan . Ghost checks fatal errors on upload. https://docs.ghost.org/themes/structure/

## 3. Shopify Online Store 2.0

**Package.** Fixed top-level directories only: `assets`, `blocks`, `config`, `layout`, `locales`, `sections`, `snippets`, `templates`; `layout/theme.liquid` is the only file required to upload. https://shopify.dev/docs/storefronts/themes/architecture

**Options.** `config/settings_schema.json` declares settings plus a `theme_info` block (name, author, version, docs URL, exactly one support email or URL). https://shopify.dev/docs/storefronts/themes/architecture/config/settings-schema-json . Values live in `config/settings_data.json`: `current` plus up to five `presets`; selecting a preset overwrites `current` only for presentational settings. https://shopify.dev/docs/storefronts/themes/architecture/config/settings-data-json

**Catalog.** Theme Store with human review: version number and release notes per submission, one demo store per preset with real content, Lighthouse averages of at least 60 performance and 90 accessibility, and a long list of required features. https://shopify.dev/docs/storefronts/themes/store/requirements

**Change after adoption.** The best-documented update flow in this survey. An update arrives as an unpublished draft "Updated copy of ...". Theme-editor customizations (settings, sections, templates) are carried over; **code edits are included only if they do not conflict**, with a card message saying either "code edits successfully included" or "could not be included". Updates only exist for themes from the Theme Store; uploaded themes get none. Shopify may push automatic bug and security updates that do not change look or settings. https://help.shopify.com/en/manual/online-store/themes/managing-themes/updating-themes . Community pain: `shopify theme push` overwriting `settings_data.json`. https://community.shopify.com/t/shopify-cli-pushing-a-theme-overwrites-settings-and-section-data/54313

**Validation.** Theme Check linter (syntax, missing templates, unused snippets, deprecated tags, performance), runnable in CLI and CI, with custom checks. https://shopify.dev/docs/storefronts/themes/tools/theme-check

## 4. Hugo

**Package.** Catalog requirements: `theme.toml` at root (TOML only) with name, license, licenselink, description, homepage, optional demosite, tags, features, authors, and `[original]` for ports; supported Hugo versions in `[module.hugoVersion]`; `images/screenshot.png` at least 1500x1000 and `images/tn.png` at least 900x600, both 3:2 with no device mockups; a README with absolute image URLs; an open source license; no paid themes. https://github.com/gohugoio/hugoThemesSiteBuilder

**Catalog.** A plain list of repo URLs in `themes.txt`, added by PR; the site builder fetches each repo through Go modules and reads metadata from the **latest release, or latest commit if none**. A fork must be "notably different" to list. **Themes not updated in 18 months are removed.** https://github.com/gohugoio/hugoThemesSiteBuilder

**Fetch and pin.** Historically `git submodule` into `themes/`; now Hugo Modules: `go.mod` plus `go.sum` checksums, pin by semver, prefix, range, branch, or commit; `hugo mod get -u` to update; `hugo mod vendor` copies modules into a committed `_vendor/`, and you override a vendored file by placing the same relative path in the project, never by editing `_vendor`. https://gohugo.io/hugo-modules/use-modules/

**Pain.** Users find the dual submodule/module ecosystem confusing; some themes work only one way; modules require a Go toolchain. https://discourse.gohugo.io/t/new-user-confused-by-the-current-state-of-the-theme-ecosystem/48747 , https://discourse.gohugo.io/t/theme-as-a-hugo-module-or-theme-as-a-git-submodule/54388

**Validation.** The catalog PR must produce a passing Netlify deploy preview. https://github.com/gohugoio/hugoThemesSiteBuilder

## 5. Jekyll

**Package.** A gem carrying `assets`, `_data`, `_layouts`, `_includes`, `_sass`; the site holds only content, Gemfile, lockfile, and `_config.yml`. Theme `_config.yml` merges under site config. https://jekyllrb.com/docs/themes/

**Pin.** Gemfile constraint (`~> 2.5`) plus `Gemfile.lock`; `bundle update <theme>`. https://jekyllrb.com/docs/themes/

**Override.** Copy a theme file into the same path in the site to shadow it; the docs warn that copying the main Sass file to change styles cuts you off from updates and suggest a separate higher-specificity stylesheet instead. "Converting" to a regular theme means copying all gem files in and dropping the gem. https://jekyllrb.com/docs/themes/

**remote_theme.** `OWNER/REPO@ref` with branch, tag, or commit; **defaults to HEAD when unpinned**; `@latest` uses the GitHub Releases API, which at 60 unauthenticated requests per hour falls back to HEAD with only a warning; public repos only. https://github.com/benbalter/jekyll-remote-theme

## 6. Gatsby themes

**Model.** Themes are npm packages (plugins with a `gatsby-config.js`), "versioned packages that can be updated like any other package", pitched explicitly against starters, which are "ejected" and cannot pull upstream changes. https://www.gatsbyjs.com/docs/themes/what-are-gatsby-themes . Customization is component shadowing: files under `src/<theme-name>/` replace theme files via a webpack resolver. https://v2.gatsbyjs.com/docs/how-shadowing-works/

**What went wrong.** I found no formal Gatsby deprecation notice for themes; the decline shows in the ecosystem. Shadowing silently fails or partially applies (a shadowed file's GraphQL query is still scraped from the original; reports of shadowed files ignored). https://v2.gatsbyjs.com/docs/how-shadowing-works/ , https://www.github.com/LekoArts/gatsby-themes/discussions/631 . A shadowed file couples the site to the theme's internal file layout, so a theme refactor breaks overrides. Major themes were abandoned at framework majors, e.g. Gatsby Theme Catalyst "will not be updated to Gatsby v4", archived 2022. https://github.com/ehowey/gatsby-theme-catalyst . Gatsby's own starters library was cut from nearly 500 community starters to a small set. https://www.github.com/gatsbyjs/gatsby/discussions/33346 . `gatsby new` copies a starter and clears its git history. https://www.gatsbyjs.com/docs/starters/

## 7. Astro

**Fetch.** `create astro --template <name>` (official examples) or `<user>/<repo>`, `main` by default, `#branch` for others. https://docs.astro.build/en/install-and-setup/ . A copied template has no update channel.

**Catalog.** astro.build/themes, open submissions; a reviewer reply template (unofficial) says new themes must target the current Astro major. https://astro.build/themes/author/5 , https://hackmd.io/@sarah11918/BJMjDSMDZl.md . I did not find the official requirements page.

## 8. Eleventy starters

Listed as data files in the docs repo's `src/_data/starters`, each with demo and screenshot, sorted by Speedlify (performance) rank; no stated requirements and no update path. https://www.11ty.dev/docs/starter/

## 9. shadcn/ui registry

**Package.** `registry.json` (name, homepage, items or include) built by `shadcn build` into static JSON under `public/r`; a public GitHub repo can serve as a registry directly. https://ui.shadcn.com/docs/registry/registry-json . Each `registry-item.json` has name, title, description, `type` (including `registry:theme` and `registry:style`), author, `files[]` with `path`, `type`, and `target` (with `~` and alias placeholders), npm `dependencies`, `registryDependencies`, `cssVars` (theme, light, dark), `css` rules, `envVars`, `font`, `docs` (message on install), `categories`, `meta`. https://ui.shadcn.com/docs/registry/registry-item-json

**Hosting.** Third-party registries are namespaced in `components.json` (`@acme` maps to a URL template with `{name}`, optional headers and env-expanded auth). Versioning is **left to the server** via query params; the CLI has none. https://ui.shadcn.com/docs/registry/namespace

**Pin.** GitHub registry dependencies can be pinned to a tag or full SHA, recommended for published registries, and **refs are not inherited across dependencies**. No checksum or signature verification is documented. https://ui.shadcn.com/docs/registry/registry-item-json

**Change after adoption.** No update command. `add --overwrite`, `add --diff [path]`, `init --reinstall`, `--dry-run`, `view`. https://ui.shadcn.com/docs/cli . The long-running request for an `update` command (discussion #790) collected workarounds: overwrite on a branch and re-apply by hand, have an LLM re-apply changes, mark local edits in comments, and a proposal to **record the installed version so diff compares against it rather than latest**; one commenter says the experimental diff does not work well. https://github.com/shadcn-ui/ui/discussions/790

## 10. Fetchers: degit, tiged, giget

**degit/tiged.** `user/repo/subdir#ref` (branch, tag, commit), tarball download with no `.git`, cache keyed by commit hash with a `map.json` ref map, `degit.json` post-actions. degit's last release was February 2020 and the maintainer stopped responding, hence the tiged fork. https://github.com/tiged/tiged

**giget.** `provider:repo/subpath#ref`, GitHub, GitLab, Bitbucket, Sourcehut, `git:` provider; offline cache; a **registry protocol** resolving `/:template.json` to `{name, tar, defaultDir, url, subdir, headers}`; no integrity check documented. https://github.com/unjs/giget

## 11. Other systems with strong lessons

**Drupal Starterkit (inheritance abandoned for copy).** Drupal kept Classy's markup and CSS frozen because subthemes depended on it, so "it is difficult for the base theme to ship improvements to the subtheme without risking regressions"; Classy got no updates after 8.0.0 and was removed in Drupal 10 in favor of a generator that copies. https://www.drupal.org/about/core/blog/new-starterkit-will-change-how-you-create-themes-in-drupal-10 , https://drupal.org/project/classy . The generated `info.yml` records `generator: starterkit_theme:<version>`, and the upgrade path is `git diff <old> <new> -- core/themes/starterkit_theme` applied by hand. https://www.drupal.org/docs/core-modules-and-themes/core-themes/starterkit-theme

**Copier (copy-in with real updates).** The project keeps `.copier-answers.yml` (source, commit, answers). `copier update` regenerates the old version with the old answers, diffs it against the project to isolate local changes, regenerates at the new tag, then reapplies the local diff, with conflicts inline or as `.rej`; requires a git-tagged template and a clean project tree; never hand-edit the answers file. https://copier.readthedocs.io/en/stable/updating/

**Discourse themes and components.** `about.json` (name, component flag, license_url, about_url, authors, theme_version, min and max Discourse version, assets, color_schemes, screenshots), optional `settings.yml`; git-installed themes check the remote daily and offer "Update to Latest". https://meta.discourse.org/t/structure-of-themes-and-theme-components/60848 . Settings types and owner values that survive updates. https://meta.discourse.org/t/add-settings-to-your-discourse-theme/82557 . Since 3.2 a theme can ship ordered JS **settings migrations** in `migrations/settings/` that run on install and update, e.g. to rename a setting. https://meta.discourse.org/t/migrate-discourse-theme-settings/287783

**Zola.** `theme.toml` with name, description, tags, license, homepage, `min_version`, demo, `[extra]` defaults the site overrides in its own config, `[author]`, `[original]`; gallery needs a roughly 2000x1000 `screenshot.png`, a working default site, and a README; listing by PR. https://www.getzola.org/documentation/themes/creating-a-theme/

**VS Code color themes.** A theme is data (a JSON of color IDs); users override per-key through `workbench.colorCustomizations` and `editor.tokenColorCustomizations`, scoped per theme, so tweaks never require forking. https://code.visualstudio.com/api/extension-guides/color-theme

---

## Synthesis

### Lessons, ranked by bearing on a copy-in, look-only, small-catalog design

1. **Record provenance at copy time, or no update is ever possible.** Copier's answers file (source, commit, answers) enables a three-way update; Drupal's `generator:` line enables a manual diff; shadcn users asked for exactly this after the fact. https://copier.readthedocs.io/en/stable/updating/ , https://www.drupal.org/docs/core-modules-and-themes/core-themes/starterkit-theme , https://github.com/shadcn-ui/ui/discussions/790
2. **Inheritance and shadowing freeze the upstream.** Drupal gave up Classy because subthemes pinned its markup; Gatsby shadowing coupled sites to theme internals and failed silently. Copy-in is the direction mature systems moved to. https://www.drupal.org/about/core/blog/new-starterkit-will-change-how-you-create-themes-in-drupal-10 , https://v2.gatsbyjs.com/docs/how-shadowing-works/
3. **Options applied once by copying values do not follow later theme edits.** WordPress style variations are copied to the DB and stop updating. If cairn writes token values, it must also record which option was chosen so a later update can re-derive them. https://developer.wordpress.org/themes/global-settings-and-styles/style-variations/
4. **Option keys are a contract.** Ghost loses owner values on a key rename; Discourse had to add settings migrations. Keep the option set closed and its keys stable. https://docs.ghost.org/themes/custom-settings/ , https://meta.discourse.org/t/migrate-discourse-theme-settings/287783
5. **Separate the owner's data from the theme's code.** Shopify's update keeps editor settings and merges only non-conflicting code edits, delivered as a draft for review. https://help.shopify.com/en/manual/online-store/themes/managing-themes/updating-themes
6. **Never default to an unpinned ref.** remote_theme defaults to HEAD and degrades `@latest` to HEAD under rate limits. Resolve to a commit SHA and record it. https://github.com/benbalter/jekyll-remote-theme , https://ui.shadcn.com/docs/registry/registry-item-json
7. **Checksums turn a pin into a guarantee.** Hugo Modules record `go.sum`; shadcn, giget, and tiged document none. https://gohugo.io/hugo-modules/use-modules/ , https://github.com/unjs/giget
8. **A catalog is a list of repos plus a metadata file and fixed-shape images, validated by a build.** Hugo: `themes.txt`, `theme.toml`, 3:2 screenshots, passing deploy preview, prune after 18 months. https://github.com/gohugoio/hugoThemesSiteBuilder
9. **Machine validation before acceptance pays.** gscan (with per-major targets), Theme Check, Shopify Lighthouse floors. https://github.com/TryGhost/gscan , https://shopify.dev/docs/storefronts/themes/tools/theme-check , https://shopify.dev/docs/storefronts/themes/store/requirements
10. **Declare the engine and contract range in the manifest.** Hugo `hugoVersion`, Zola `min_version`, Discourse min and max, gscan per-major; themes die at framework majors (Gatsby Catalyst). https://www.getzola.org/documentation/themes/creating-a-theme/ , https://github.com/ehowey/gatsby-theme-catalyst
11. **Own the fetcher.** degit went unmaintained in 2020. https://github.com/tiged/tiged
12. **Keep the theme surface fixed and enumerated.** Shopify allows only its fixed directories; WordPress bans "plugin territory" in themes. Both keep themes swappable. https://shopify.dev/docs/storefronts/themes/architecture , https://make.wordpress.org/themes/handbook/review/required/

### Recommended model for cairn

- **Package:** a directory holding exactly `src/theme/`'s shape plus a manifest (`cairn-theme.json`): name, version, license, author, description, content-model version (the contract), cairn engine range, a closed `options` list (stable keys, each option mapping to token values), screenshots of a fixed size and ratio, demo URL. The theme can sit in any git repo, at any subdirectory.
- **Host and catalog:** a single index in the cairn repo, Hugo style: one entry per theme (repo, subdir, pinned tag). A CI build fetches each one, runs `cairn theme check` (manifest schema, file set equals the theme surface, no files outside it, the showcase builds against the fixed content model, contrast and Lighthouse floors), and emits `catalog.json` with the metadata and images. The browse page later reads that same file.
- **Fetch and pin:** `cairn new` downloads the tag's tarball natively in Go (no degit dependency), resolves the tag to a commit SHA, checks a sha256 of the theme tree, and writes `.cairn/theme.lock` into the site with source, subdir, tag, commit, tree hash, and the option answers.
- **Update later (optional):** that lock file makes Copier's algorithm possible: regenerate old theme plus old answers, diff it against the site, lay the new version, reapply the diff, deliver on a branch or PR.

**Alternative A: npm package plus shadowing (Gatsby, Jekyll gem).** It gives a real update channel and semver for free. The cost: theme files leave the site, an override layer has to be built, sites couple to theme internals, and the site no longer owns its look, which contradicts the scaffold model.

**Alternative B: shadcn-style JSON registry (file contents inlined in registry items, `cssVars` as data).** It fits the browse page and per-file targets. The cost: every theme repo needs a build-and-host step, there is still no version or integrity layer (versioning is left to the server), and the per-item granularity solves a composition problem cairn does not have.

### Copy-in pitfalls and mitigations in practice

- **Drift and no updates.** Mitigations: a recorded provenance line (Drupal), a recorded commit plus answers for a three-way update (Copier), a diff against the installed version, not the latest (shadcn #790).
- **Merge pain.** Mitigations: conflict markers or `.rej` files plus a pre-commit block on them (Copier); deliver the update as a reviewable draft (Shopify "Updated copy"); keep owner overrides in a separate token file that the theme never ships, the way VS Code customizations sit beside the theme, so most local changes never conflict.
- **Stale option values.** Record which option was chosen, not only the values it wrote (WordPress lesson).
- **Abandoned catalog entries.** Prune on staleness and on contract-range expiry (Hugo's 18 months).
