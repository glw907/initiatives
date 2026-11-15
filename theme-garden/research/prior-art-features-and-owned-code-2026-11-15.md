# Prior art: site features between core, theme and site; owned versus packaged code

Research date 2026-11-15. Public pages only. Quotes come from pages fetched this session. The fetch tool returns a model-made extract of each page, so quotes are as extracted and should be re-checked against the page before reuse in published text. "Unconfirmed" marks anything I could not read from a primary source. Systems and sub-questions that no fetched page answered are said so rather than filled from memory.

---

## Part A. Features that are neither core nor look

### WordPress

- **Boundary rule (primary).** Theme Review Handbook, required section: https://make.wordpress.org/themes/handbook/review/required/
  - Section 5 "Presentation vs. functionality" lists what a theme must not include: "Custom post types", "Custom blocks", "Custom roles", "Custom user contact methods", "Custom mime types", "Shortcodes", "Functionality that is not related to design and presentation".
  - Section 6 "Examples of plugin territory": "Analytics or tracking support", "SEO options", "Contact forms", "Non-design related meta boxes", "Resource caching", "Social media 'like', 'follow' and 'share buttons'", "Session tampering".
  - Escape hatch: "If you are not sure if a feature is plugin functionality, contact the team and ask first."
  - Social links are not named. Only like, follow and share buttons are.
- **Developer handbook rationale.** https://developer.wordpress.org/themes/basics/theme-functions/ : features meant to work regardless of design, "it is best practice to put them in a plugin". Plugins "apply to all themes". `functions.php` "applies only to that theme", and after a theme switch the features "can no longer be used".
- **Why (secondary).** Tuts+ explains the rule as leaving out things that prevent users from switching themes: https://code.tutsplus.com/the-concept-of-plugin-territory-in-wordpress--cms-25083t . Justin Tadlock's write-up treats custom post types as plugin territory: https://justintadlock.com/archives/2015/05/28/the-theme-review-teams-content-creation-discussion . Both were seen only as search snippets, not fetched.
- **Where code lives.** Contact form, SEO, analytics, social buttons: plugin. Taxonomies (categories and tags) are WordPress core. Search is core (I did not fetch a page for this, so it is unconfirmed here).
- **Switch and who flips it.** A plugin is activated in the admin Plugins screen by an administrator. The theme-side switch is the theme being active. The rule is enforced only for themes submitted to WordPress.org. Privately built themes are not bound (unconfirmed from a primary source).
- **How a theme detects a feature.** Not covered by a page I fetched. Common practice is `function_exists` or `class_exists` checks. This is unconfirmed here.
- **Events.** The Events Calendar is a plugin that registers its own events post type. Themes override its templates by copying them into a `tribe/` folder in the theme. This is from a search summary, not a fetched primary page: https://theeventscalendar.com/knowledgebase/themers-guide/ (my fetch of that URL returned 404, so unconfirmed). The same summary says older docs use `tribe-events/`, and that each template's header comment states its override path. Events are a plugin concern on every site type by default. Core ships no events type.
- **Site kind.** Not confirmed: WordPress has no site-kind concept in the pages I read.

### Ghost

- **Where code lives.** Members, search and tags are core. Themes call them through Handlebars helpers and `data-` attributes. A theme is "static HTML templates that make use of helpers to output data from your site" (https://docs.ghost.org/themes/structure). Required helpers include `{{ghost_head}}` and `{{ghost_foot}}`.
- **Members.** Activated through Portal, "an embeddable memberships feature that can be enabled and customised from the Admin UI" (https://docs.ghost.org/themes/members). The theme hooks in with `data-portal` links, `data-members-form` forms, `{{#if @member}}` and `{{#if access}}`. The admin owner flips the switch.
- **Theme detection.** `@site.members_enabled` is "True if subscription access is not set to" a certain value. `@site.comments_enabled` is "True if comments enabled". `@site.paid_members_enabled` is "True if members is enabled and Stripe is connected" (https://docs.ghost.org/themes/helpers/data/site). The wording of the first is truncated in my extract.
- **Search.** Core, in the admin-configured setup. Per search results, a theme adds `data-ghost-search` to any element, or uses the `{{search}}` helper, and Ctrl/Cmd+K opens it. The search script is injected by `ghost_head`. Search snippets only, not fetched: https://docs.ghost.org/themes/search and https://docs.ghost.org/themes/helpers/utility/search . Algolia is suggested for large sites.
- **Tags.** Core. `tag.hbs` is "An optional template for tag archive pages. If not specified the index.hbs template is used." `tag-:slug.hbs` makes per-tag templates (https://docs.ghost.org/themes/structure).
- **Contact form.** No page found that documents a core contact form. Unconfirmed. Ghost's mechanism for extra pages is a static page plus a custom template.
- **Theme settings.** The theme declares them in `package.json` under `config.custom` (types `select`, `boolean`, `color`, `image`, `text`; limit 20). The site owner edits them in Admin under Design & branding, Theme tab. Templates read `@custom.key` (https://docs.ghost.org/themes/custom-settings). This is the clearest example here of a theme-declared switch that an editor flips in an admin screen.
- **Events.** Not a content type. Per https://docs.ghost.org/themes/routing , `routes.yaml` (`content/settings/routes.yaml`) can build a collection filtered by tag, for example `filter: primary_tag:podcast`, served at `/podcast/`. An events section would be a tag-filtered collection. The docs do not mention events. The file is edited on the server, or uploaded in admin under Settings, Labs.
- **Site kind.** Not confirmed. The `@site` flags change with site configuration, not with a declared kind.

### Hugo

- **Taxonomies are built in.** "The default configuration defines two taxonomies, `categories` and `tags`." A custom taxonomy replaces them unless you redefine the defaults. To switch them off, put `taxonomy` and `term` in `disableKinds` (https://gohugo.io/configuration/taxonomies/). The kind list is "404, home, page, robotstxt, rss, section, sitemap, taxonomy, or term" (https://gohugo.io/configuration/all/). The developer sets it in the site config file. No editor admin exists.
- **Themes with search or contact.** I did not retrieve a theme's documentation. PaperMod's feature page returned 404, so how theme `params` switch search is unconfirmed here.
- **Detection.** Unconfirmed from fetched pages. Hugo templates can test config values and page kinds, but I have no page to cite.
- **Events.** No built-in type. A section of content with front matter dates is the usual shape (unconfirmed). Hugo skips future-dated and expired content by default: `buildFuture` is "Whether to include future content when building a site", and `buildExpired` likewise for expired content, both off by default (https://gohugo.io/getting-started/configuration/ ). So an events list needs `buildFuture` set or a date scheme that avoids it.

### Jekyll and Eleventy

- **Jekyll.** Gem themes carry layouts, includes and Sass (assets from 3.3). Features come from plugins in the `Gemfile` and `_config.yml` (plugin details unconfirmed). See Part B for gem themes.
- **Eleventy.** "Plugins are custom code that Eleventy can import into a project from an external repository", and "just configuration". Official plugins include RSS (feeds), Navigation, Image and i18n (https://www.11ty.dev/docs/plugins/). The page does not discuss themes. A search or contact feature is the site's own code or a community plugin (unconfirmed).
- **Events.** No documented model on the pages fetched.

### Astro, Starlight, Docusaurus, VitePress

- **Astro integrations.** "Astro integrations add new functionality and behaviors for your project with only a few lines of code", added in the `integrations` property of `astro.config.mjs` (https://docs.astro.build/en/guides/integrations-guide/). The page does not document themes. Content types are site-owned: collections are "defined in a special `src/content.config.ts` file" (https://docs.astro.build/en/guides/content-collections/). An events type would be a site-defined collection.
- **Starlight search.** Built in. Pagefind is the default and "No configuration is required to enable search" (https://starlight.astro.build/guides/site-search/). Switch off site-wide: the `pagefind` option, "Set to `false` to disable indexing your site with Pagefind" (https://starlight.astro.build/reference/configuration/#pagefind). The guide page itself only shows per-page exclusion (`pagefind: false` in front matter, or `data-pagefind-ignore`). Alternatives are plugins: Algolia DocSearch via `@astrojs/starlight-docsearch` in `plugins`, and a community Typesense plugin. The developer flips it in `astro.config.mjs`. No admin screen exists.
- **Starlight plugins.** Per https://starlight.astro.build/reference/plugins/ , plugins can change config, UI and behavior. `config:setup` can "update the Starlight configuration, add Astro integrations, add route middleware". The page does not mention search.
- **Starlight theme detection.** Not documented on the pages fetched. Components such as `SocialIcons` can be overridden (see Part B).
- **Docusaurus.** "The Docusaurus core doesn't provide any feature of its own." Plugins supply docs, blog and pages. Themes load after plugins and can override a plugin's theme components. Presets bundle both. `preset-classic` bundles docs, blog, pages, sitemap, gtag and the Algolia search theme (https://docusaurus.io/docs/using-plugins). Docs, blog, pages and sitemap switch off with the option `false`. gtag turns on only when its options are given.
- **Docusaurus search.** No built-in search. Algolia DocSearch is "first-class", turned on by an `algolia` field in `themeConfig`. Local search is community-made. A custom search is made by swizzling `SearchBar` (https://docusaurus.io/docs/search).
- **VitePress.** Local search: set `themeConfig.search.provider` to `'local'` in `.vitepress/config.ts` (https://vitepress.dev/reference/default-theme-search). The developer sets it in a file.
- **Events.** None of these have an events model in the pages fetched. Docusaurus has no events plugin in the preset list.
- **Site kind.** Docusaurus and Starlight are docs-site tools with one kind, so there are no per-kind defaults (inference, not stated).

### Statamic, Kirby, Craft, Drupal

- **Statamic.** Forms are core, with "tags, settings, and a dedicated area of the Control Panel". A form is a YAML file in `resources/forms` (or made in the Control Panel) plus a blueprint in `resources/blueprints/forms/{handle}.yaml`. Templates use the `{{ form:handle }}` tag, and `form:submissions` shows submissions (https://statamic.dev/forms). The page does not discuss themes. A site calls the form tags from its own templates. Both the Control Panel and files can create forms, so an editor with permission can add one.
- **Statamic collections and events.** "Each entry in a collection can represent a blog post, product, recipe" or another kind of content, with fields from the collection's blueprint. Each collection sets date behavior (public, unlisted or private) for past and future dates. Past private works like "upcoming events" that disappear when over. The page never names events (https://statamic.dev/collections). So events are a custom collection, with the dates behavior built in.
- **Statamic addons.** I could not fetch the addon page (404). See Part B for the starter kit versus addon contrast.
- **Kirby.** "A plugin is a folder inside `/site/plugins`". Plugins can register "snippets, templates, page methods, Panel fields, hooks, and routes". "Kirby's own extensions are already registered" before plugins load. An underscore prefix on the folder name disables a plugin (https://getkirby.com/docs/guide/plugins). The developer flips it in the filesystem. The page does not define themes.
- **Craft.** "Craft is adamantly agnostic about your content model", with no predefined page or post type. Entries use entry types and sections. Search is built in ("Automatic indexing for search") (https://craftcms.com/docs/5.x/system/elements.html). "Plugins extend Craft's core functionality". They install through the Plugin Store or `composer require` then `php craft plugin/install`, and a disabled plugin's code is not loaded (https://craftcms.com/docs/5.x/system/plugins.html). Front-end forms are not covered by these pages. Events are a developer-defined section, or a plugin (unconfirmed).
- **Drupal.** Events are a content type plus Views. The Calendar module "works with any date field" configured in a View and offers year, month, week and day views. It lists Date iCal ("import or export dates using iCal feeds") and Registration as companions. Its release is 8.x-1.0-beta5 with "currently no supported stable releases" (https://www.drupal.org/project/calendar). Drupal's boundary rule, from search results only (older pages, Drupal 6/7 era): the theme's role is "output and presentation", and core and modules "handle input" (https://www.drupal.org/node/171188). The Drupal 8+ statement of the rule is unconfirmed. A community thread notes that nothing stops a template from containing logic, so the rule is a convention (https://groups.drupal.org/node/114809, snippet only).

### Shopify

- **Theme rules.** https://shopify.dev/docs/storefronts/themes/best-practices says a theme should be "modular, highly customizable" (sections and blocks) and "include options that let merchants tailor it to their brand or use case". It says "Themes should minimize the use of JavaScript". The page does not address app blocks.
- **Apps.** https://shopify.dev/docs/apps/build/online-store/theme-app-extensions : app blocks and app embed blocks are "Liquid files that act as the entry point for what you want to inject in a theme". Apps built this way do not modify theme code, which "decreases the risk of introducing breaking changes to the theme". Merchants add them in the theme editor. Merchants flip the switch in an admin screen. Detection of an installed app by a theme is unconfirmed.
- **Site kind.** The best-practices page says each theme should be opinionated for a merchant segment. No per-kind core defaults are documented on the pages fetched.

### Squarespace and Wix

- **Squarespace.** Calendar pages (named events pages on version 7.0) "add a list of events to your site". Version 7.1: Pages panel, then Calendar under Showcase. Limits: "Calendar pages don't support booking", no recurring events, 350 events per month, up to two years ahead, no comments. Version 7.0 differs from 7.1, and the "Marquee family can't show past events" (https://support.squarespace.com/hc/en-us/articles/206543837-Calendar-pages). So events are a core page type, and availability varies by platform version and template family.
- **Wix.** Events is an app installed from the App Market or dashboard. Per a search summary (snippets only, https://support.wix.com/en/article/adi-adding-and-setting-up-wix-events and https://support.wix.com/en/article/wix-vibe-request-adding-wix-events-to-vibe-sites ), it is "no longer available to add to ADI sites" and is not available on Wix Vibe sites. My direct fetch of the ADI page returned 404, so treat these as unconfirmed. This is the one documented case of a feature varying by editor or site type.

### Events summary (seven systems)

| System | Model | Default for which kinds | How the theme renders it |
|---|---|---|---|
| WordPress | Plugin with own post type (The Events Calendar) | None in core | Theme copies plugin templates into a `tribe/` folder (unconfirmed primary) |
| Ghost | No type. Tag-filtered collection via `routes.yaml` | None | Normal tag and collection templates |
| Statamic | Site-defined collection, with built-in future and past date behavior | None | Site's own templates |
| Drupal | Content type plus Views, Calendar module (beta) | None | Theme templates for the content type and View |
| Squarespace | Core page type (events or calendar page) | Per platform version and template family | Template renders it. The owner adds the page |
| Wix | App from the App Market | Not on ADI or Vibe sites | App supplies the widgets |
| Hugo | Content section with dates. `buildFuture` and `buildExpired` control visibility | None | Site or theme layouts |

No system fetched documents a calendar feed (iCal) as a core feature. Drupal's Date iCal module and Squarespace's per-event "add to calendar" appeared in snippets.

---

## Part B. Owned code versus packaged code

### shadcn/ui

- **Copied versus imported.** Component source is copied into the project. Reasoning, from https://ui.shadcn.com/docs : "This is not a component library. It is how you build your component library." With normal libraries you "have to override styles or wrap the component". With open code you edit the source, with "full control to customize and extend".
- **Distribution.** The registry is "A distribution system for code", usable by anyone: "Run your own code registry". It "works with any project type and any framework" (https://ui.shadcn.com/docs/registry).
- **Record.** `components.json` records style (which "cannot be changed after initialization"), alias roots and registry URL templates. It does not record installed component versions (https://ui.shadcn.com/docs/components-json). No per-file version record was found.
- **How a fix reaches a project.** The CLI page documents `add` with `-o, --overwrite`, `--diff [path]`, `--view [path]` and `--dry-run`, and no standalone `diff` command (https://ui.shadcn.com/docs/cli). A 2023 changelog introduced a `diff` command (https://ui.shadcn.com/docs/changelog/2023-06-new-cli, snippet only). Search summaries say it was replaced by `add --diff`. No changelog says it was removed, so the removal is unconfirmed. Updating is re-running `add --overwrite`, and the guidance (Vercel academy, snippet) is to commit local changes first because the CLI overwrites.
- **2026 addition.** `npx shadcn@latest apply` "apply a new preset, reinstall your existing components, and update your theme, colors, CSS variables, fonts, and icons" in an existing project (https://ui.shadcn.com/docs/changelog/2026-04-shadcn-apply). It reinstalls components, which would replace local edits. Whether it preserves them is unconfirmed.
- **Other registries.** shadcn-svelte, shadcn-vue and Flux UI appear in Laravel's docs as the same pattern (https://laravel.com/docs/12.x/starter-kits).
- **Regrets.** None stated. The reversal-like signal is a command that moved from `diff` to a flag, and a later `apply`.

### Docusaurus swizzling

Source: https://docusaurus.io/docs/swizzling
- **Eject** "creates a copy of the original theme component, which you can fully customize". **Wrap** "creates a wrapper around the original theme component, which you can enhance". "Prefer wrapping whenever possible."
- **Safety levels.** Safe: public API stable, "no breaking changes should occur within a theme major version". Unsafe: internal detail, "Breaking changes may happen within a theme minor version". Forbidden: the CLI blocks it. Some components are safe to wrap but not safe to eject.
- **Upgrade pain.** Unsafe components "may change in a backward-incompatible way between theme minor versions", and customizations might "behave unexpectedly". Advice: re-run the eject command and compare with `git diff`, and comment the top of the file. Try CSS or translations first, and keep swizzled code small.
- **Record.** None. The comment at the top of the file is manual.

### Starlight overrides and Astro template versus integration

- **Starlight.** You register a replacement in the `components` option, which "replaces or extends" the default. You can import the default and render it with extras ("keep all of Starlight's basic UI within your design, while adding extra UI alongside them"). The page has no maintenance warning (https://starlight.astro.build/guides/overriding-components/). Overrides are by name, not by file copy, so the base stays in the package.
- **Template versus integration.** The Astro Theme Provider "why" page (a community project, not Astro official) says to move "away from project templates and towards Astro integrations". Templates are "hard to setup and understand for new developers". Once customized, merging later improvements "can be difficult if not impossible". Templates "can't be dropped into" an existing project. It names Starlight as the pioneer (https://astro-theme-provider.netlify.app/why). I found no official Astro statement of the trade-off. A competing blog view, that forking makes tracking changes easier, appeared only in a search summary.

### Hugo

- **Lookup.** "If the project and a module provide templates with the same file name, Hugo uses the template in the project" (https://gohugo.io/templates/lookup-order/). Themes stack left to right. `static`, `layouts` and `archetypes` merge "on file level. So the left-most file will be chosen". `i18n` and `data` merge deeply by key. `params` and `menu` take the leftmost matching ID (https://gohugo.io/hugo-modules/theme-components/).
- **Copy versus import.** The theme stays a module or folder. A file with the same path in the project shadows it. A fix reaches the project when the theme is updated, except for shadowed files. No record is kept of which files were shadowed. The page does not say this.

### Jekyll

- **Gem themes.** "The goal of gem-based themes is to allow you to get all the benefits of a robust, continually updated theme." Your site can override any of the defaults by creating a file with the same name. Warning: "making copies of theme files will prevent you from receiving any theme updates on those files." Updates come from `bundle update <THEME>` (https://jekyllrb.com/docs/themes/).
- **Why introduced.** 3.2.0 made themes its flagship feature: "proper, versionable, releasable, first-class themes", at first layouts, includes and Sass only (https://jekyllrb.com/news/2016/07/26/jekyll-3-2-0-released/). The release notes do not state the problem with forked or copied themes. A DigitalOcean tutorial says gems make themes "properly versionable and updatable" (snippet, https://www.digitalocean.com/community/tutorials/jekyll-jekyll-themes). The documented reason beyond that is unconfirmed.

### Next.js and SvelteKit starters

- **Next.js.** `create-next-app` creates an app from the default template or an `--example` from a public GitHub repository (https://nextjs.org/docs/app/api-reference/cli/create-next-app). The files are copied. The page documents no update path.
- **SvelteKit.** `sv create` offers templates `minimal`, `demo`, `library` and `addon`, and add-ons through `--add` (https://svelte.dev/docs/cli/sv-create). The page "says nothing about updating an existing project".
- **Record.** None found for either, beyond the lockfile.

### Laravel starter kits

- **Copied.** "all of the backend and frontend code exists within your application to allow for full customization" (https://laravel.com/docs/12.x/starter-kits).
- **Fixes.** FAQ "How do I upgrade?": "With full ownership of the code, you can tweak, customize, and build your application exactly as you envision. However, there is no need to update the starter kit itself." Backend behavior lives in the Fortify package, which stays imported and has a `config/fortify.php` `features` array to switch features on or off. The docs warn that disabling a feature also needs its frontend route references removed, because the Wayfinder route generation will otherwise fail the build.
- **Reversal.** Laravel 12 release notes: "With the introduction of our new application starter kits, Laravel Breeze and Laravel Jetstream will no longer receive additional updates" (https://laravel.com/docs/12.x/releases). The installer no longer lists them (community sources, snippet). Breeze and Jetstream history beyond this is unconfirmed.
- **Record.** None found.

### Rails

- `bin/rails app:update` handles "the creation of new files and changes of old files in an interactive session". On conflict it prompts `Overwrite ...? [Ynaqdh]`, with `THOR_DIFF` and `THOR_MERGE` for diff tools. It writes `config/initializers/new_framework_defaults_X_Y.rb` and leaves `config.load_defaults` unchanged until you delete that file and bump the value (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html). The record of version is `config.load_defaults`. The generators' stated reasoning was not on the page (the page was read to character 100000 of 152796).

### Statamic starter kits versus addons

- **Kits.** Installed with `php please starter-kit:install vendor/name`, and the installer "will ask you if you wish to clear your site first" (https://statamic.dev/starter-kits/installing-a-starter-kit.md). Not all kits update: "Starter Kits aren't all designed to be updatable, but when they are you'll need to know how." An updatable kit "will be left as a dependency in your `composer.json` file", so `composer update vendor/kit` works. Some need asset steps (https://v5.statamic.dev/starter-kits/updating-a-starter-kit, an old-version page).
- **Addons.** Composer packages the vendor keeps updating (search summary; the addon page returned 404).
- **Record.** The `composer.json` dependency is the record, only for updatable kits.

---

## Patterns that recur (three or more systems)

1. **Content-and-feature split follows reversibility.** WordPress, Drupal, Ghost, Shopify and Craft put behavior in a unit that outlives the look (plugin, module, core, app), and keep themes to presentation. The stated reason is theme switching (WordPress) or avoiding theme breakage (Shopify).
2. **Switches live in a file for developer tools and in an admin screen for hosted or editor-facing tools.** Starlight, VitePress, Docusaurus, Hugo and Kirby: a config file or folder. Ghost, Shopify, WordPress and Squarespace: an admin screen. Ghost's theme-declared custom settings are the one case where the theme defines a switch and the editor flips it.
3. **Core ships a small default set and the rest is opt-in.** Docusaurus ("core doesn't provide any feature of its own"), Hugo (categories and tags only), Craft (no predefined page or post type), Starlight (search on by default, `pagefind: false` to turn off).
4. **Events are almost never core.** Plugin (WordPress), custom collection (Statamic), content type plus Views (Drupal), tag collection (Ghost), app (Wix). Squarespace is the exception.
5. **Theme reads the state of a feature through a helper or context flag, or by template presence.** Ghost `@site.*` flags and `@member`, Ghost template fallbacks (`tag.hbs` to `index.hbs`), Hugo `disableKinds` removing page kinds, Shopify app blocks added in the editor.
6. **Override by path or name, with the project winning.** Hugo, Jekyll, Docusaurus swizzle, Starlight `components` map, WordPress theme folders for plugin templates (The Events Calendar), Ghost templates.
7. **A copy stops receiving fixes.** Jekyll ("will prevent you from receiving any theme updates on those files"), Docusaurus eject (re-run and `git diff`), Astro template critique ("difficult if not impossible"), shadcn (`--overwrite` after committing), Laravel ("no need to update the starter kit itself").
8. **Copied code pairs with an imported core.** Laravel kits keep Fortify as a package, Docusaurus wraps the original, Starlight overrides can render the default, shadcn keeps behavior in Radix or Base primitives (the last point is not in a fetched page).
9. **Little or no record of what was copied.** shadcn does not record component versions. Docusaurus uses a manual comment. Rails has `load_defaults`, and Statamic uses `composer.json` for updatable kits only.

## Where systems disagree

- **Who may add behavior to a theme.** WordPress.org forbids custom post types, shortcodes and contact forms in themes. Ghost themes carry custom settings and members markup. Shopify themes carry sections and blocks with merchant options. Hugo and Jekyll themes carry no such rule on the pages fetched.
- **Where search lives.** Core with a theme hook (Ghost, Craft, Starlight), a preset-bundled theme (Docusaurus Algolia), a config provider (VitePress local), or a community plugin (Docusaurus local).
- **Copy or import.** shadcn and Laravel copy by design. Jekyll moved from copied themes to gems. Astro's theme-provider guidance argues for integrations. Starlight overrides keep the base in the package. Statamic offers both (kits copy, addons import).
- **Updating a copy.** Laravel says do not update. shadcn offers `--overwrite`, `--diff` and now `apply`. Docusaurus says re-eject and diff. Rails offers interactive `app:update`. Statamic updates only kits marked updatable.
- **Site kind.** Only Squarespace (by platform version and template family) and Wix (ADI, Vibe) document a feature varying with site type. The other systems fetched do not tie defaults to a site kind.
- **Template-or-integration claims.** The Astro Theme Provider page says templates are hard to update. A blog in the same search says forking makes tracking changes easier. Neither is an Astro official statement.

## Gaps

WordPress core search and theme-side detection; Hugo theme search and contact params (PaperMod page 404); Jekyll and Eleventy contact and search; Ghost contact form; Drupal's current Drupal 8+ rule on themes and logic; Statamic addon page; Craft front-end forms; Kirby themes; Breeze and Jetstream history beyond the release note; Rails generator reasoning; Next.js and SvelteKit update guidance; a first-party statement on Jekyll's reason for gem themes; the Events Calendar themer's guide itself.
