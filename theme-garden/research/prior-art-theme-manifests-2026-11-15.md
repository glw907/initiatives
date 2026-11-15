# Prior art: theme manifests, capability declarations, options, menu binding, and where the site's choice lives

Fetched 2026-11-15 from official documentation and source repositories. Every claim carries a URL. "Unconfirmed" marks anything a primary page did not settle. Quotes are as the fetched page rendered them. This extends two earlier notes (`prior-art-theme-packaging.md`, `prior-art-theme-switching.md`) and does not repeat their packaging, hosting, pinning, or switching findings except where a correction is needed (see "Corrections to earlier notes").

Limits of method: pages were read through a summarizing fetcher, so exact wording on long pages may be trimmed. Where a page was a 404 or a redirect to a login-less mirror, the substitute URL is given.

---

## 1. WordPress

### 1.1 Manifest and fields

Classic and block themes both use `style.css` header comment fields. https://developer.wordpress.org/themes/basics/main-stylesheet-style-css/
- Required (marked `*` in the docs): "Theme Name", "Author", "Description", "Version", "Requires at least", "Tested up to", "Requires PHP", "License", "License URI", "Text Domain".
- Optional: "Theme URI", "Author URI", "Tags" ("words or phrases that help users find the theme with the tag filter"), "Domain Path" (defaults to `/languages`).
- "Template": "required only for Child Themes."
- Compatibility fields with core: "Requires at least" (oldest WordPress, X.X), "Tested up to" (latest tested), "Requires PHP". These are minimums and a tested ceiling, not an API version.

Block themes add `theme.json`. Top-level keys in the living reference (version 3): `settings`, `styles`, `customTemplates` (`name`, `title`, `postTypes`), `templateParts` (`name`, `title`, `area`), `patterns` (slugs from the Pattern Directory). https://developer.wordpress.org/block-editor/reference-guides/theme-json-reference/theme-json-living/
- The living reference does not list `version` or `$schema` as keys; it says "This is the living specification for **version 3** of `theme.json`." (same URL)
- The intro page says: "The current API version is `2`", "The `version` value should be an integer matching the API your file was written for", "If you omit `version`, WordPress reads the file as version 1", and "`$schema` property is optional". https://developer.wordpress.org/themes/global-settings-and-styles/introduction-to-theme-json/ (The two pages disagree on the current number, 2 versus 3; the discrepancy is the sources', unresolved here.)

### 1.2 Capability declaration

`add_theme_support( string $feature, mixed $args )`: "Registers theme support for a given feature." "Must be called in the theme's functions.php file to work." https://developer.wordpress.org/reference/functions/add_theme_support/
- The page lists "Likely core values include": `admin-bar`, `align-wide`, `appearance-tools`, `automatic-feed-links`, `block-templates`, `block-template-parts`, `border`, `core-block-patterns`, `custom-background`, `custom-header`, `custom-line-height`, `custom-logo`, `customize-selective-refresh-widgets`, `custom-spacing`, `custom-units`, `dark-editor-style`, `disable-custom-colors`, `disable-custom-font-sizes`, `disable-custom-gradients`, `disable-layout-styles`, `editor-color-palette`, `editor-gradient-presets`, `editor-font-sizes`, `editor-spacing-sizes`, `editor-styles`, `featured-content`, `html5`, `link-color`, `menus`, `post-formats`, `post-thumbnails`, `responsive-embeds`, `starter-content`, `title-tag`, `widgets`, `widgets-block-editor`, `wp-block-styles`.
- Vocabulary ownership: the page does not say who owns it; it calls the list "likely" core values and (per the fetch summary of the source) the function stores any string it receives without checking the list. So it is a flag set with a core-conventional vocabulary, open at the edges. Treat the no-validation point as unconfirmed beyond the page's own wording.
- Direction of the flag: the theme declares support, and core and plugins read it with `current_theme_supports()` (not fetched; unconfirmed here).

### 1.3 Options

- Theme mods: `get_theme_mods()` reads `get_option( "theme_mods_$theme_slug" )` with `$theme_slug = get_option( 'stylesheet' )`. https://developer.wordpress.org/reference/functions/get_theme_mods/ `set_theme_mod` writes `update_option( "theme_mods_$theme", $mods )`. https://developer.wordpress.org/reference/functions/set_theme_mod/ `get_theme_mod` is "Retrieves theme modification value for the active theme" with a caller-supplied default. https://developer.wordpress.org/reference/functions/get_theme_mod/
- So theme mods are options in the `options` table keyed by the theme's stylesheet slug; the theme declares no schema for them in the manifest (declaration lives in Customizer PHP code, not fetched here; unconfirmed).
- `theme.json` settings are the declared, typed layer; user choices from the Site Editor are stored separately: for style variations "When a user selects a style variation, the JSON data is migrated to the site's database" and "stored as a user customization" that can override the theme's `theme.json`. https://developer.wordpress.org/themes/global-settings-and-styles/style-variations/
- Style variations: JSON files in `/styles` with "the same structure as `theme.json`"; `title` "is not a required field". Chosen in the Site Editor's Styles screen. (same URL)
- Changeable after install: yes, in the admin, without reinstalling.

### 1.4 Menus

- Theme declares named locations: `register_nav_menus()` "Registers navigation menu locations for a theme"; `$locations` is an "Associative array of menu location identifiers (like a slug) and descriptive text". https://developer.wordpress.org/reference/functions/register_nav_menus/
- The theme prints a location with `wp_nav_menu( array( 'theme_location' => 'header-menu' ) )`; registering "sets the name that will appear at Appearance -> Menus" and adds the location to "Manage Locations". https://developer.wordpress.org/themes/functionality/navigation-menus/
- The site defines menus as objects and assigns one per location in the admin. The reference page does not describe the assignment steps; a user note implies the dashboard ("reassign the menu to the new location in the dashboard"). Assignment storage format: unconfirmed from the primary pages (the earlier switching note cites a `theme_switch_menu_locations` option via Trac).
- Missing assignment: by default WordPress "displays the first non-empty menu when the specified menu or location is not found" or "generates a Page menu when there is no custom menu selected"; set `fallback_cb` to `false` to stop that. https://developer.wordpress.org/themes/functionality/navigation-menus/
- Block themes: the classic navigation page does not cover block themes (its URL is under classic-themes). I could not fetch a block-theme navigation page (404 at https://developer.wordpress.org/themes/block-themes/block-theme-navigation/). Treat "block themes use the Navigation block and no theme locations" as unconfirmed here.

### 1.5 Category / site kind

- `Tags` header is catalog filtering only, optional, many allowed. https://developer.wordpress.org/themes/basics/main-stylesheet-style-css/ No single-kind declaration in `style.css`. Whether the directory's tag taxonomy is closed: unconfirmed.

### 1.6 Versioning and compatibility

- Theme `Version` is read by the directory to detect updates. `Requires at least`, `Tested up to`, `Requires PHP` as above. (same style.css URL)
- `theme.json` carries an integer schema version (see 1.1).

### 1.7 Regret, deprecation, migration

- theme.json was introduced to consolidate flags: "This new mechanism aims to take over and consolidate all the various `add_theme_support` calls." Older declarations are mapped: "disabling custom colors through the older call is equivalent to setting `settings.color.custom` to `false`"; a `theme.json` setting "will take precedence over the values declared via" `add_theme_support`. https://make.wordpress.org/core/2021/06/25/introducing-theme-json-in-wordpress-5-8/
- Classic themes may adopt it without leaving the flags: "the ability to add support for block editor functionality, without having to use the add_theme_support function." https://learn.wordpress.org/tutorial/using-theme-json-with-classic-themes/ That page also warns adding the file changes editor behavior and defaults "may conflict with or duplicate your existing CSS rules."
- `add_theme_support` page notes block themes get some features by default from 5.9 (`post-thumbnails`, `responsive-embeds`, `editor-styles`, `html5`, `automatic-feed-links`) via a user note, and marks `sidebars`, `menus`, `editor-style` read-only in "Other Notes". https://developer.wordpress.org/reference/functions/add_theme_support/ Note the feature list itself is not deprecated as a whole; menus and widgets remain on the flag and function path in classic themes.
- Style variations are copied to the database on choice (the earlier packaging note already captures the consequence).

---

## 2. Shopify

### 2.1 Manifest and fields

There is no single manifest. The declaration is `config/settings_schema.json`; stored values are `config/settings_data.json`. https://shopify.dev/docs/storefronts/themes/architecture
- Architecture page: "Config files define settings in the Theme settings area of the theme editor, as well as store their values." "Only a layout directory containing a theme.liquid file is required for the theme to be uploaded to Shopify." Directories are fixed: "Subdirectories, other than the ones listed, aren't supported."
- `settings_schema.json` is "an array of objects that represent setting categories", each with `name` and `settings`. One object has `"name": "theme_info"` with `theme_name`, `theme_author`, `theme_version`, `theme_documentation_url`, and exactly one of `theme_support_url` or `theme_support_email`. https://shopify.dev/docs/storefronts/themes/architecture/config/settings-schema-json
- `settings_data.json`: `current` (required: "all of the setting values that are currently saved in the theme editor"), `presets` (required, "Each object is in the same format as `current`"), `platform_customizations` (optional, added by Shopify). Limits: "can't exceed 1.5MB"; "A theme can't contain more than five presets." https://shopify.dev/docs/storefronts/themes/architecture/config/settings-data-json

### 2.2 Capability declaration

- No feature-flag vocabulary was found in the manifest. Theme capability is structural: which sections exist, and `enabled_on` / `disabled_on` on a section schema "restrict a section to certain template page types and section group types." https://shopify.dev/docs/storefronts/themes/architecture/sections/section-schema
- Section schema attributes: `name`, `tag`, `class`, `limit` ("a limit of 1 or 2"), `settings`, `blocks`, `max_blocks`, `presets`, `default`, `locales`, `enabled_on`, `disabled_on`. (same URL) Presets "pre-fill settings and blocks" when a merchant adds the section; `default` configures a statically rendered section with the same structure.
- Shopify's Theme Store lists required features in its requirements; those requirements are a review checklist, not a manifest vocabulary (see the earlier packaging note).

### 2.3 Options

- Input setting attributes: `type` (required), `id` (required, "used to access the setting value"), `label` (required), `default` (optional), `info` (optional). https://shopify.dev/docs/storefronts/themes/architecture/settings/input-settings
- Types: basic `checkbox, number, radio, range, select, text, textarea`; specialized `article, article_list, blog, collection, collection_list, color, color_background, color_palette, color_scheme, color_scheme_group, font_picker, html, image_picker, inline_richtext, link_list, liquid, metaobject, metaobject_list, page, product, product_list, richtext, text_alignment, url, video, video_url`. (same URL)
- Stored value lives in `settings_data.json` inside the theme; editing in the theme editor writes it back. Selecting a preset "updates the `current` object", and "only values from presentational settings are updated." https://shopify.dev/docs/storefronts/themes/architecture/config/settings-data-json
- Missing-value behavior in `settings_data.json`: the page does not describe it (unconfirmed).
- Changeable after install: yes, in the theme editor; the data file is part of the theme, so it travels with the theme (the earlier notes cover the update and switch consequences).

### 2.4 Menus

- Menus (linklists) are store data defined in admin. A theme setting of type `link_list` is the binding: it "gives merchants a menu picker, pre-filled with the store's existing menus"; "Accepted values for the `default` attribute are `main-menu` and `footer`." In Liquid it returns a `linklist`; "If no menu is selected or the selected menu no longer exists, it returns `blank`." https://shopify.dev/docs/storefronts/themes/architecture/settings/input-settings
- So the theme declares the binding point (a setting with an id), the site picks a menu, and the pick is stored in `settings_data.json` (or in a section's JSON template). Default values are restricted to two handles Shopify itself provides.
- The `linklist` object page does not document handle access or a missing-handle result (unconfirmed). https://shopify.dev/docs/api/liquid/objects/linklist

### 2.5 Category / site kind

- Not found in the manifest. Theme Store category: unconfirmed (not fetched).

### 2.6 Versioning and compatibility

- `theme_version` in `theme_info` only. No core-API range field found in the config files. Section and template format changes are gated by file type (`.json` versus `.liquid`), not by a declared version number. https://shopify.dev/docs/storefronts/themes/os20/migration

### 2.7 Regret, deprecation, migration

- JSON templates: "JSON templates act only as a wrapper for sections, while Liquid templates contain code." https://shopify.dev/docs/storefronts/themes/architecture ; "JSON templates are data files that store a list of sections to be rendered, and their associated settings." https://shopify.dev/docs/storefronts/themes/architecture/templates/json-templates
- Migration is per template: "Learn how to migrate Liquid templates to JSON templates to take advantage of Online Store 2.0 features"; a `product.liquid` and `product.json` "can't be stored in the `/templates` directory at the same time." https://shopify.dev/docs/storefronts/themes/os20/migration The page does not say whether Liquid templates remain supported in general (unconfirmed). I found no official statement of regret; the mechanism is a opt-in per-template migration.

---

## 3. Ghost

### 3.1 Manifest and fields

`package.json` is the manifest. Required files: "Two template files are required: `index.hbs` and `post.hbs`", and `package.json`. https://docs.ghost.org/themes/structure
- Fields the structure page names: `config.posts_per_page` ("the default number of posts per page is 5"), `config.image_sizes`, `config.card_assets` ("controls whether Ghost automatically includes the editor card CSS and JS"). Real example (Source theme 1.5.3): `name`, `version`, `license`, `description`, `engines.ghost: ">=5.0.0"`, and `config: { posts_per_page: 12, image_sizes: {xs..xxl: {width}}, card_assets: true, custom: {...} }`. https://cdn.jsdelivr.net/npm/ghost@6.30.0/content/themes/source/package.json
- `engines.ghost` as the compatibility field is evidenced from theme repos and a Ghost changelog quote (see 3.6) and not from a docs page I could fetch (https://docs.ghost.org/themes/packagejson returned 404). The structure page does not mention `engines`.
- The `config` key must stay in `package.json`: staff reply "The config key has to stay in package.json: Ghost reads it when the theme is activated" and "There is no alternative file." https://forum.ghost.org/t/can-ghost-theme-configuration-move-outside-package-json/62184.md (community forum, staff answer; the thread reports npm warnings about it).

### 3.2 Capability declaration

- No feature flags. A theme "must make use of the required helpers": `{{asset}}`, `{{body_class}}`, `{{post_class}}`, `{{ghost_head}}`, `{{ghost_foot}}`. https://docs.ghost.org/themes/structure
- gscan reports "Features: detected features which may impact on compatibility" and lists no specific ones on the README. https://github.com/TryGhost/gscan So capability is detected from template content, not declared. The core owns the helper vocabulary.
- A theme that does not render `{{navigation type="secondary"}}` simply omits it; the helper "doesn't output anything if there are no navigation items". https://docs.ghost.org/themes/helpers/data/navigation

### 3.3 Options

- `config.custom`, defined by the theme developer; keys "all lowercase with no special characters", `snake_case`; an unknown type is a validation error. Types: `select`, `boolean`, `color`, `image`, `text`. Attributes: `type` (required), `default` (required for select, boolean, color; "Not allowed for `image`"; optional for text), `options` (required for select, array of strings), `group` (`homepage` or `post`, otherwise "Site wide"), `description` (under 100 characters), `visibility` (parent setting and value, or NQL). "Themes are limited to a total of 20 custom settings." https://docs.ghost.org/themes/custom-settings
- Owners set values in Admin, "**Theme** tab in **Design & branding**". Themes read `@custom`; text defaults belong in `package.json`. (same URL)
- Stored value: in Ghost's database, bound to the theme by name (the earlier switching note cites a staff statement); the custom-settings page does not name the store. Treat storage detail as unconfirmed on the docs page.
- Changeable after install: yes, in Admin. Renaming a key "is a breaking change for site owners who upgrade": the old value is removed and a new setting gets its default. (same URL)

### 3.4 Menus

- Site-owned only. `{{navigation}}` "outputs formatted HTML of menu items defined in the Ghost admin panel (Settings > Design > Navigation)"; "There are two types of navigation, primary and secondary"; markup comes from the theme, overridable with `./partials/navigation.hbs`. https://docs.ghost.org/themes/helpers/data/navigation
- The theme declares no menu locations. Exactly two slots exist, named by core. Empty: no output; test `@site.navigation` or `@site.secondary_navigation`.

### 3.5 Category / site kind

- None found in `package.json`. `routes.yaml` lives at `content/settings/routes.yaml`, edited or uploaded in Admin; routes point at theme templates by name ("`/features/: features`" uses `features.hbs`), and a collection template defaults to `index.hbs`. https://docs.ghost.org/themes/routing The routing page does not state ownership; its location suggests it is site-level (the page's own hedge).

### 3.6 Versioning and compatibility

- `version` in `package.json`. `engines.ghost` (minimum Ghost). `engines.ghost-api` was deprecated: "The `engines.ghost-api` property has been deprecated and the support for it will be dropped in Ghost v5 due to versionless nature of the Content API." (quoted via search result; the changelog page itself was not fetched) https://forum.ghost.org/t/gscan-claims-ghost-api-is-deprecated-but-official-docs-still-recommend-it/29125
- gscan validates per Ghost major: "GScan supports the current and previous major Ghost versions, v1 through v6", default latest, flags like `--v5`, `--canary`. Rule levels: errors ("must be fixed", fatal can cause 500s), warnings (deprecated features), recommendations, features. https://github.com/TryGhost/gscan

### 3.7 Regret, deprecation, migration

- Custom settings were added later: the changelog post "Custom design settings" is dated 24 Nov 2021 per a search result listing; the page itself returned 404 on my direct fetches (https://ghost.org/changelog/custom-theme-settings/) and the search-result URL https://ghost.org/changelog/custom-design-settings/ was not fetched. Treat the date as unconfirmed.
- `engines.ghost-api` removal (above) is a documented deprecation of a compatibility field when the API became versionless.
- Key rename loses owner values with no migration (custom-settings page above).

---

## 4. Hugo

### 4.1 Manifest and fields

- `theme.toml` is catalog metadata. The site-builder README example fields: `name`, `license`, `licenselink`, `description`, `homepage`, `demosite`, `tags`, `features`, `authors` (name, homepage), `[author]`, `[original]` (author, homepage, repo). "The source doesn't label any `theme.toml` field as required or optional." https://raw.githubusercontent.com/gohugoio/hugoThemesSiteBuilder/main/README.md
- Compatibility is not in `theme.toml`: it goes in the theme's config file: `[module.hugoVersion]` with `min`, `max`, `extended`; "You may omit the fields". (same URL) `extended` is "deprecated since v0.153.0: This setting has no effect"; users get a warning if incompatible. https://gohugo.io/configuration/module/

### 4.2 Capability declaration

- `features = ["some", "awesome", "features"]` in `theme.toml` is free text for the catalog; the README's placeholder values show no vocabulary. (README URL above) No core-owned feature vocabulary was found. Whether the catalog treats `features` as closed: unconfirmed.

### 4.3 Options

- A theme component's own config file may set only these: "`params` (global and per language), `menu` (global and per language)" plus output formats and media types. https://gohugo.io/hugo-modules/theme-components/ Merge: "The left-most parameter/menu etc. with the same ID will win"; the page does not say explicitly that project config overrides theme config for params and menus (unconfirmed). 
- No declared types, defaults list, or limits: a theme documents its param names in prose. Stored value: the site's `hugo.toml` params. Changeable at any time by editing config.
- Mounts: `module.mounts` maps `source` to `target`; target must begin with `archetypes`, `assets`, `content`, `data`, `i18n`, `layouts`, `static`; "Mounts defined in a module or module import remove all default mounts for that module"; `files`, `sites`, `disableWatch`; `lang` deprecated for `sites`. https://gohugo.io/configuration/module/

### 4.3b Imports

- `module.imports` entries: `path`, `disable`, `ignoreConfig`, `ignoreImports`, `noMounts`, `noVendor`, `usePackageJSON`, `version`. (same URL)

### 4.4 Menus

- Site defines named menus; theme reads by name. Config: top-level `menus` keyed by menu name; entry keys `name`, `pageRef` (internal) or `url` (external), `weight`, `identifier`, `parent`. https://gohugo.io/configuration/menus/ Menus can also be set in front matter (`menus: main`) or automatically with `sectionPagesMenu`. Templates read `site.Menus.main`, `site.Menus.footer`. https://gohugo.io/content-management/menus/
- A theme-component config may supply default `menu` entries (4.3). The theme declares no locations.
- Missing menu: the template page does not say (unconfirmed); its example guards with `{{ with site.Menus.main }}`. https://gohugo.io/methods/site/menus/

### 4.5 Category / site kind

- `tags` in `theme.toml`: free tags for catalog search. No exclusive kind.

### 4.6 Versioning

- Module path/version via Go modules (earlier note). Core range via `module.hugoVersion` `min`/`max`.

### 4.7 Regret, deprecation

- Documented deprecations inside the configuration vocabulary: `module.hugoVersion.extended` (since v0.153.0), mounts `lang` replaced by `sites`, config keys `cleanDestinationDir` (v0.167.0) and `languageCode` (v0.158.0, use `locale`). https://gohugo.io/configuration/module/ , https://gohugo.io/configuration/all/ None is a regret about themes as such.

---

## 5. Zola and Jekyll

### 5.1 Zola

- Manifest: `theme.toml`: `name`, `description`, `tags` ("optional tags to allow quick search"), `license`, `homepage`, `min_version` ("The minimum version of Zola required"), `demo` ("optional live demo URL"), `[extra]` ("Any variable there can be overridden in the end user `zola.toml`" and "as this will be merged with user data, some kind of prefix or nesting is preferable"), `[author]`, `[original]`. https://www.getzola.org/documentation/themes/creating-a-theme/ (the page says `zola.toml`; the same site's install page says "configuration file", and Zola's file is conventionally `config.toml`; flagged only as the page's wording.)
- Enable: `theme` variable at the top level of the config "not after a dict like [extra]"; theme directory name must match. Site sets theme options "in the `extra` section of the configuration file", e.g. `[extra]` `show_twitter = true`. https://www.getzola.org/documentation/themes/installing-and-using-themes/
- Capabilities: none declared. Options: no types; defaults are the theme's `[extra]` and the site overrides. Menus: no menu system found in these pages (unconfirmed; Zola sites typically keep menus in `[extra]`, not fetched).
- Compatibility: `min_version` only (no max).

### 5.2 Jekyll gem themes

- Manifest: the gemspec; theme config is the theme's root `_config.yml`, "merge[d] into the site's configuration"; "Any settings defined by the theme-config can be overridden by the user"; defaults of Jekyll can't be overridden by a theme config. Select with `theme:` in the site `_config.yml`; "Only one theme can be selected". https://jekyllrb.com/docs/themes/
- Capabilities: none declared. Options: free-form keys in `_config.yml`; no types. Jekyll version compatibility is not stated on the page; notes that auto-required runtime dependencies arrived in 3.5.0, config merging in 4.0, theme `_data` in 4.3.0. (same URL)
- Menus: no standard; sites use `_data`. Unconfirmed from primary pages here.

---

## 6. Astro Starlight and Docusaurus

### 6.1 Starlight (a configured framework, not a swappable theme)

- Config is `starlight({...})` in `astro.config.mjs`. Relevant options: `title` (`string | Record<string, string>`, required), `logo` (`LogoConfig` = `{ alt?: string; replacesTitle?: boolean } & ({ src: string } | { light: string; dark: string })`), `social`, `sidebar` (`SidebarItem[]`), `customCss` (`string[]`), `components` (`Record<string, string>`), `plugins` (`StarlightPlugin[]`). https://starlight.astro.build/reference/configuration/
- Social links exact shape: type `Array<{ label: string; icon: StarlightIcon; href: string }>`; "Each entry will be displayed as an icon link in the site header."; example `social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/withastro' }]`. (same URL) All three fields required.
- Regret/migration: in 0.33.0, "The `social` configuration option has changed syntax. You will need to update this in `astro.config.mjs` when upgrading." Marked breaking; the old keyed-object form replaced by an array; entry does not use the word "deprecated". https://raw.githubusercontent.com/withastro/starlight/refs/heads/main/packages/starlight/CHANGELOG.md (read first 100,000 characters only; the entry's heading text is "Makes `social` configuration more flexible".)
- Sidebar: omitted means auto-generated from the filesystem; items may use `slug`, `link`, `label`, `autogenerate` (with `directory`), `items` groups, `translations`. https://starlight.astro.build/guides/sidebar/ The site config names the content, so the binding is by slug to site content.
- Theme replacement: no manifest; overriding is by `components` mapping, e.g. `SocialIcons: './src/components/EmailLink.astro'`. https://starlight.astro.build/guides/overriding-components/ (that page does not discuss themes or plugins overriding components.)
- Compatibility: none declared by the site; plugins are `StarlightPlugin`. Starlight-theme-as-package manifest: unconfirmed.

### 6.2 Docusaurus

- Preset and theme are the unit: "Presets are bundles of plugins and themes."; `presets: ['@docusaurus/preset-classic']`; `themes: ['@docusaurus/theme-classic', ...]`; "Themes are loaded in the exact same way as plugins" and "loaded after plugins"; preset options relayed to each plugin or theme. https://docusaurus.io/docs/using-plugins
- Config types: `presets: PresetConfig[]`, `themes: PluginConfig[]`, `themeConfig` ("the theme configuration object to customize your site UI like navbar and footer"), `customFields` ("Docusaurus guards `docusaurus.config.js` from unknown fields. To add a custom field, define it on `customFields`."). https://docusaurus.io/docs/api/docusaurus-config
- Navbar: `themeConfig.navbar` with `title`, `logo` (requires `src`; optional `alt`, `srcDark`, `href`, `width`, `height`, `target`, `className`, `style`), `items` (each a `NavbarItem` with `type`: default link, `dropdown`, `doc`, `docSidebar`, `docsVersionDropdown`, `docsVersion`, `localeDropdown`, `search`, `html`; link items use `label` with `to` or `href`, not both). Footer: `logo`, `copyright`, `style` (`'dark'|'light'`, default light), `links` (multi-column `{title, items}` or simple flat array; each item `label` with `to`/`href`, or `html`). https://docusaurus.io/docs/api/themes/configuration
- Social links: the premise is not borne out. Neither the theme-configuration page nor the config API page documents a typed social-links setting; the footer shows plain text links such as `label: 'X'` with `href: 'https://x.com/docusaurus'`. https://docusaurus.io/docs/api/themes/configuration#footer-links , https://docusaurus.io/docs/api/docusaurus-config Only a meta-image `image` and free `metadata` tags are documented. If a typed social setting exists elsewhere in Docusaurus, it is unconfirmed.
- Menus: site config defines navbar and footer items by hand; the theme reads `themeConfig`. There are no theme-declared locations; navbar and footer are fixed slots owned by the theme-classic schema.
- Compatibility: none declared in the site config pages above (unconfirmed).

---

## 7. Drupal

### 7.1 Manifest and fields

`THEME.info.yml`. https://www.drupal.org/docs/theming-drupal/defining-a-theme-with-an-infoyml-file
- Required: `name`; `type` ("Set to `theme` for themes. This value is case-sensitive"); `core_version_requirement` (required in Drupal 9+, e.g. `^9 || ^10`); `base theme` (required in Drupal 9+; recommends `stable9`). `core` is required for Drupal 8 and "not valid in Drupal 9+".
- Optional: `description`, `package`, `dependencies` (8.9.x), `php` (default `DRUPAL_MINIMUM_PHP`), `version` (omit for drupal.org-hosted themes: the packaging script fills it), `libraries`, `libraries-override`, `libraries-extend`, `hidden`, `engine` (default `twig`), `logo` (8.6.x), `screenshot` (recommended 588x438), `regions` ("a `content` region is required"), `regions_hidden`, `features` ("Features exposed on the theme Settings page"), `stylesheets-remove` (deprecated; use `libraries-override`), `ckeditor_stylesheets`, `ckeditor5-stylesheets` (9.3.x).
- The page did not mention `generator` (the earlier note cites it for Starterkit from a different page).

### 7.2 Capability declaration

- The `features` key lists toggles exposed on the theme settings page. Its vocabulary values are not on the page (unconfirmed). Capability is otherwise declared by regions and libraries, which are theme-declared names.

### 7.3 Options

- Declared in PHP: a form alter `THEMENAME_form_system_theme_settings_alter` in `THEMENAME.theme` or `theme-settings.php` adds Form API elements (the example adds a textfield `foo_example`). Defaults: `config/install/THEME.settings.yml`, lines `SETTING_NAME: DEFAULT_VALUE`. Read with `theme_get_setting('foo_example')`. "Sub-themes do not inherit parent theme's settings". https://drupal.org/node/2623936 The page does not say where user-saved values are stored or mention config schema. A runtime wrapper "Provides a configuration API wrapper for runtime merged theme settings" with values "therefore not persisted" in merged form. https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Theme%21ThemeSettings.php/class/ThemeSettings/10
- Changeable after install: yes, in the theme settings UI. (UI behavior inferred from the declared form; no page states it directly.)

### 7.4 Menus and regions

- Themes declare `regions` (named slots); the site places blocks, including menu blocks, into regions per theme. Menus are site entities. Region-to-block assignments are per theme; the earlier switching note covers losses on a switch (https://www.drupal.org/node/1117778). A menu is not bound by the theme manifest.

### 7.5 Category / site kind

- `package` groups themes in the admin list; free text, optional. `type: theme` distinguishes theme from module/profile. https://www.drupal.org/docs/theming-drupal/defining-a-theme-with-an-infoyml-file

### 7.6 Versioning

- `core_version_requirement` is a Composer-style constraint on core; `core: 8.x` was the older single-version field.

### 7.7 Regret, deprecation

- `theme_get_setting()` is deprecated in drupal:11.3.0 and removed from drupal:13.0.0; replacement `\Drupal::service('\Drupal\Core\Extension\ThemeSettingsProvider')->getSetting()`. Source: search result excerpt only; I did not fetch the API page (https://api.drupal.org/api/drupal/core%21includes%21theme.inc/function/theme_get_setting/9 appeared in results), so treat as partly unconfirmed.
- `core` key replaced by `core_version_requirement`; `stylesheets-remove` deprecated for `libraries-override` (7.1 page).

---

## 8. Flat-file and Git-based CMSs

### 8.1 Grav

- Theme manifest: `blueprints.yaml`: "should have a definition file called `blueprints.yaml`". Antimatter example fields: `name`, `slug`, `type`, `version`, `description`, `icon`, `author` (`name`, `email`, `url`), `homepage`, `demo`, `keywords`, `bugs`, `license`, `dependencies` (`{ name: grav, version: '>=1.6.0' }`), and `form` ("defines the theme options editable in the Administration Panel"). https://learn.getgrav.org/17/themes/theme-basics
- Options: defaults in `<themename>.yaml` in the theme root; the site overrides in `user/config/themes/<themename>.yaml`; "strongly recommended not to actually change the theme's default YAML file". Merge semantics are not stated (the page's own editor note asks for it). https://learn.getgrav.org/17/themes/theme-configuration The form definition makes options typed through blueprints, and the admin writes the override file (the admin-write detail is unconfirmed from fetched text).
- Read in Twig as `config.theme`, "An alias to the `config.theme` object". https://learn.getgrav.org/17/themes/theme-vars
- Compatibility: `dependencies` entry naming `grav` with a version constraint.
- Menus: the theme-menus page returned 404; unconfirmed.

### 8.2 Statamic

- Themes: not a distinct concept. An addon's `composer.json` has `extra.statamic` with `name` and `description`; the page says it marks the package as an addon. Starter kits are described as installing "pre-configured files and settings into your site" and "An example use case is a frontend theme with sample content"; kit files are meant to be owned and modified, unlike addons in `vendor`. https://statamic.dev/extending/addons
- Starter kit manifest `starter-kit.yaml`: `export_paths`, `dependencies` (Composer packages, versions auto-detected), `modules` (optional opt-in file sets), `options` (alternative modules; user picks one), `prompt` (string or `false`), `skip_option`, `label`; "Anything not configured in your `starter-kit.yaml` **will not be exported**." `updatable: true` keeps the kit as a Composer dependency. The page specifies no `statamic/cms` requirement in the kit's own `composer.json`. https://statamic.dev/starter-kits/creating-a-starter-kit (`export_as` appeared in my query but is not documented on the page.)
- Site's choice: made at install via prompts, recorded as the installed files themselves; per-module choice record: unconfirmed.

### 8.3 Kirby

- Plugins: `index.php` registration with name `{vendor}/{plugin}`, "Both parts may only contain the characters `a-z`, numbers and dashes", "`extends` is required, even when it is empty". https://getkirby.com/docs/guide/plugins/plugin-setup-basic The page links to a Themes section but explains no theme manifest. Starterkit is "a full-blown Kirby installation with a lot of example content", Plainkit "a minimal Kirby setup". https://getkirby.com/docs/guide/quickstart No theme manifest was found: unconfirmed.

---

## 9. Answers by question (cross-system tables)

### Q1 Manifest file and fields (one line each, detail above)

| System | Manifest | Fields |
|---|---|---|
| WordPress | `style.css` header; `theme.json` | Theme Name, Theme URI, Author, Author URI, Description, Version, Requires at least, Tested up to, Requires PHP, License, License URI, Text Domain, Tags, Domain Path, Template; theme.json: settings, styles, customTemplates, templateParts, patterns |
| Shopify | `config/settings_schema.json` (+ `settings_data.json`) | theme_info (name, theme_name, theme_author, theme_version, theme_documentation_url, theme_support_url or theme_support_email) + setting categories |
| Ghost | `package.json` | name, version, license, description, engines.ghost, config.posts_per_page, config.image_sizes, config.card_assets, config.custom |
| Hugo | `theme.toml` + config `[module]` | name, license, licenselink, description, homepage, demosite, tags, features, authors, [author], [original]; `module.hugoVersion` min/max |
| Zola | `theme.toml` | name, description, tags, license, homepage, min_version, demo, [extra], [author], [original] |
| Jekyll | gemspec + theme `_config.yml` | not enumerated on the page |
| Starlight | none (plugin config) | n/a |
| Docusaurus | none (package + preset/theme config) | n/a |
| Drupal | `THEME.info.yml` | see 7.1 |
| Grav | `blueprints.yaml` | see 8.1 |
| Statamic | `starter-kit.yaml` (kit only) | see 8.2 |

### Q2 Capability declaration, and owner of the vocabulary

- WordPress: flag strings declared by the theme with `add_theme_support`; the list on the reference page is "Likely core values" so the core owns the conventional vocabulary; no validation is stated on the page.
- Ghost: no declared flags; required helpers and gscan-detected features; the core owns it.
- Shopify: none declared; structure and `enabled_on`/`disabled_on`; Shopify review checklist owns required features.
- Hugo: free-text `features` in `theme.toml`; no owner found.
- Drupal: `features` key (toggles) and regions; the theme names regions, core names the toggle vocabulary (unconfirmed).
- Zola, Jekyll, Starlight, Docusaurus, Grav, Statamic, Kirby: no capability vocabulary found.

### Q3 Options (declared where, stored where, changeable)

| System | Declared | Types/limits | Stored | Change after install |
|---|---|---|---|---|
| WordPress | Customizer code; theme.json settings | theme.json typed; Customizer in PHP | `theme_mods_{stylesheet}` option; user styles in the DB | yes |
| Shopify | `settings_schema.json` | 40+ types; 5 presets; 1.5MB data | `settings_data.json` in the theme | yes |
| Ghost | `config.custom` | 5 types, 20 settings | Ghost DB, tied to theme name | yes |
| Hugo | prose; theme config `params` | none | site `hugo.toml` | yes (edit file) |
| Zola | theme `[extra]` | none | site config `[extra]` | yes |
| Jekyll | theme `_config.yml` | none | site `_config.yml` | yes |
| Starlight | typed config object | TypeScript types | `astro.config.mjs` | yes |
| Docusaurus | `themeConfig` | typed by theme | `docusaurus.config.js` | yes |
| Drupal | PHP form + `THEME.settings.yml` | Form API | active config (storage not stated on fetched page) | yes |
| Grav | `blueprints.yaml` `form` | blueprint form | `user/config/themes/<name>.yaml` | yes |

### Q4 Menu binding

- Theme declares locations, site assigns a menu to each: WordPress (`register_nav_menus` + admin).
- Theme declares a binding point as a setting, site picks a menu: Shopify (`link_list`).
- Core names two slots, site defines items, theme only styles markup: Ghost (primary, secondary).
- Site defines named menus, theme reads by name: Hugo (`site.Menus.<name>`), Docusaurus (navbar and footer items in `themeConfig`).
- Theme declares regions, site places blocks that hold menus: Drupal.
- Not found: Zola, Jekyll, Starlight (the sidebar is content-derived), Grav, Statamic, Kirby.
- Missing menu: WordPress falls back (first non-empty menu or page menu); Shopify returns `blank`; Ghost emits nothing; Hugo unconfirmed.

### Q5 Category or site kind

- No system found where a theme declares one required "site kind" that gates behavior. Catalog filtering only: WordPress `Tags`, Hugo `tags` and `features`, Zola `tags`, Drupal `package`. Whether any directory (wordpress.org, Shopify Theme Store) uses a closed category beyond tags: unconfirmed.

### Q6 Versioning and compatibility

- WordPress: Version + Requires at least / Tested up to / Requires PHP; theme.json integer `version`.
- Shopify: `theme_version` only; format gated by file type.
- Ghost: `version`; `engines.ghost`; gscan checks per major.
- Hugo: `module.hugoVersion` min/max; Zola `min_version`; Drupal `core_version_requirement`; Grav `dependencies` with grav version; Jekyll none stated on the page.
- Starlight and Docusaurus: none declared by the site; breaking config changes are made in releases (Starlight 0.33.0 `social`).

### Q7 Documented regret, deprecation, migration

(See per-system 1.7, 2.7, 3.7, 4.7, 6.1, 7.7.) Quotes collected:
- WordPress: "This new mechanism aims to take over and consolidate all the various `add_theme_support` calls." https://make.wordpress.org/core/2021/06/25/introducing-theme-json-in-wordpress-5-8/
- Ghost: "a breaking change for site owners who upgrade from an older version" (key rename). https://docs.ghost.org/themes/custom-settings
- Ghost: "The `engines.ghost-api` property has been deprecated and the support for it will be dropped in Ghost v5". https://forum.ghost.org/t/gscan-claims-ghost-api-is-deprecated-but-official-docs-still-recommend-it/29125
- Starlight: "The `social` configuration option has changed syntax." https://raw.githubusercontent.com/withastro/starlight/refs/heads/main/packages/starlight/CHANGELOG.md
- Shopify: migrate "Liquid templates to JSON templates to take advantage of Online Store 2.0 features". https://shopify.dev/docs/storefronts/themes/os20/migration
- Hugo: `extended` "has no effect" since v0.153.0. https://gohugo.io/configuration/module/
- Drupal: `core` removed in favor of `core_version_requirement`; `theme_get_setting()` deprecated in 11.3.0 (search-excerpt only).

---

## Corrections to earlier notes

- The packaging note says Ghost's `package.json` carries name, version, description, license, author, `screenshots`, and `config`. This pass confirmed `engines.ghost` as the compatibility field in real themes (Source theme, https://cdn.jsdelivr.net/npm/ghost@6.30.0/content/themes/source/package.json), which the earlier note did not list.
- The packaging note says Zola's `theme.toml` page says `config.toml` overrides; the page actually says "`zola.toml`" (https://www.getzola.org/documentation/themes/creating-a-theme/).
- The packaging note states Hugo supported versions go in `[module.hugoVersion]`; confirmed, and `extended` is now a no-op (https://gohugo.io/configuration/module/).
- The packaging note says Shopify allows "up to five presets"; confirmed, plus a 1.5MB cap on `settings_data.json` (https://shopify.dev/docs/storefronts/themes/architecture/config/settings-data-json).

---

## Patterns that recur

1. **Declaration and value are separated, and the value is site-owned.** Shopify (`settings_schema.json` vs `settings_data.json`), Ghost (`config.custom` vs Admin values), Drupal (`THEME.settings.yml` default vs saved config), Grav (`<theme>.yaml` default vs `user/config/themes/<theme>.yaml`), Zola and Jekyll (theme `[extra]` or `_config.yml` default vs site override), WordPress (theme.json vs user customization in the database). Sources in sections 1.3, 2.3, 3.3, 5, 7.3, 8.1.
2. **Defaults ship with the theme; the site overrides by key.** Hugo theme-component `params`, Zola `[extra]` ("Any variable there can be overridden"), Jekyll ("can be overridden by the user"), Grav, Drupal. 
3. **Site-defined menus read by a name the theme or core fixes.** Ghost (two core slots), Hugo (`site.Menus.<name>`), Shopify (`link_list` picks a store menu), WordPress (theme locations, site assigns), Drupal (regions). The site owns menu contents in all of them; only WordPress and Drupal let the theme declare the slots.
4. **A graceful empty case for a missing menu.** Ghost "doesn't output anything", Shopify returns `blank`, WordPress has `fallback_cb`. (Hugo unconfirmed.)
5. **A compatibility range with the core in the manifest.** WordPress (Requires at least, Tested up to, Requires PHP), Ghost (`engines.ghost`), Hugo (`module.hugoVersion`), Zola (`min_version`), Drupal (`core_version_requirement`), Grav (`dependencies`).
6. **Tags or labels for the catalog only.** WordPress `Tags`, Hugo `tags` and `features`, Zola `tags`, Drupal `package`; no system found where one gates behavior.
7. **A closed, validated option vocabulary with a hard cap where the platform wants control.** Ghost (5 types, 20 settings, unknown type is an error), Shopify (fixed type list, 5 presets, 1.5MB). Hugo, Zola, Jekyll leave it to prose.
8. **Option keys are a contract across versions.** Ghost's rename loses values; Drupal sub-themes do not inherit settings; Starlight 0.33.0 changed `social` shape as a breaking change.
9. **Migration of declarations is gradual, with the old and new coexisting.** WordPress theme.json over `add_theme_support` ("will take precedence"), Shopify per-template Liquid to JSON, Ghost `engines.ghost-api` deprecated then dropped, Drupal `core` to `core_version_requirement`.

## Where systems disagree

- **Who declares menu slots.** WordPress and Drupal: the theme (`register_nav_menus`, `regions`). Ghost: core fixes two. Hugo and Docusaurus: the site's config names the menus and the theme reads them. Shopify: the theme declares a settings key, the site picks which store menu fills it.
- **Is there a capability vocabulary.** Only WordPress has an explicit flag call (`add_theme_support`), and its page calls the list "Likely core values". Ghost detects features from the templates; Shopify uses structure; Hugo `features` is free text; Zola, Jekyll, Starlight, Docusaurus, Grav have none.
- **Typed options versus prose.** Ghost, Shopify, Grav (blueprint forms), Drupal (Form API in PHP) give typed settings with a UI; Hugo, Zola, Jekyll give a bare key-value merge.
- **Where the chosen value lives.** In the theme directory (Shopify `settings_data.json`), in the platform database (WordPress options, Ghost), in site config files (Hugo, Zola, Jekyll, Grav, Starlight, Docusaurus), or in active config (Drupal).
- **How the core range is expressed.** Minimum plus tested ceiling (WordPress), `engines` semver (Ghost), min and max (Hugo), minimum only (Zola), Composer constraint (Drupal), none stated (Jekyll, Shopify).
- **Whether the manifest is one file.** Ghost: one file, with config forced into `package.json` ("There is no alternative file"). WordPress: two (`style.css`, `theme.json`). Hugo: two (`theme.toml` for the catalog, the config for compatibility). Shopify: a schema file and a data file.
- **Docusaurus social links.** The question assumed a typed social-links setting; none was found in Docusaurus's official configuration pages, whereas Starlight's `social` is a typed array.
