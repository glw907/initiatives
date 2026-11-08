# Prior art: switching a live site's theme

Research for cairn's theme design (2026-11-08). Scope: switching one theme for another on a live site. Packaging, hosting, fetching, and updating themes are covered by a separate report. Where a claim rests on a forum or third-party source rather than a vendor's own docs, it is marked "(community)".

## Per-system findings

### WordPress (classic and block themes)

**Per-theme vs site-level storage.**
- Customizer values ("theme mods") are stored per theme, in an option keyed by the active theme's slug: `get_option( "theme_mods_$theme_slug" )` (https://developer.wordpress.org/reference/functions/get_theme_mods/). Switching away leaves the old theme's mods in place, dormant; switching back restores them.
- The theme directory's rules require themes to "use the Settings and Options APIs", "only add a single database option, which should be an array", "prefixed with the theme slug" (https://make.wordpress.org/themes/handbook/review/required/). So a theme's settings are namespaced by theme by rule, and nothing maps them to the next theme.
- Additional CSS (the owner's own CSS layer, added in 4.7) is also tied to the active theme. Trac #38549, "Additional CSS lost when changing themes", is an open enhancement asking for a warning or a carry-over; the CSS comes back on switching back (https://core.trac.wordpress.org/ticket/38549; same pattern in https://core.trac.wordpress.org/ticket/55291). Owners report it as lost data (https://generatepress.com/forums/topic/all-css-neglected-after-theme-back-and-forth-switch/, community).
- Block themes: style variations, once picked, are "migrated to the site's database and stored as a user customization" overriding the theme's `theme.json` (https://developer.wordpress.org/themes/global-settings-and-styles/style-variations/). Each block theme keeps its own global-styles entity, so user styles do not follow a switch (https://github.com/WordPress/gutenberg/issues/56623).

**What carries over and what is lost.**
- Content (posts, pages, media) and menus as objects survive. Menu *assignments* to theme-declared locations, and widgets in theme-declared sidebars, frequently do not: menus lose their location even where both themes use the ID `primary`, and widgets drop to "Inactive Widgets" even where sidebar IDs match (https://ms-studio.net/notes/painless-theme-switching-in-wordpress/). Core's fix (Trac #39693) stores the old locations in a `theme_switch_menu_locations` option and maps them onto the new theme's locations, and moves stray widgets to `wp_inactive_widgets` (https://core.trac.wordpress.org/ticket/39693; history in https://core.trac.wordpress.org/ticket/17979). The mapping works only by name guessing because location names were never standardized; the ms-studio note asks for naming guidelines for common locations.
- Block themes: customized templates and template parts are stored per theme. The 2021 FSE testing call found users "surprised and frustrated" that they did not carry over; one "mostly lost everything" (layouts, colors, fonts, button styles). Recommendations: keep templates, template parts, and menus across switches; let users pick what to keep; show a side-by-side comparison before switching (https://make.wordpress.org/test/2021/10/05/fse-program-block-theme-switching-summary/; also https://make.wordpress.org/design/2021/10/08/adventures-in-block-theme-switching/).
- Image sizes: a theme registers crops with `add_image_size`, which apply only to uploads made after activation; old images show the previous theme's crops until thumbnails are regenerated (https://www.wpbeginner.com/plugins/regenerate-thumbnails-new-image-sizes-wordpress/, community; https://learn.wordpress.org/tutorial/regenerate-thumbnails/).

**Plugin territory.** The theme directory's required list says themes must not include "Functionality that is not related to design and presentation", custom post types, shortcodes, custom blocks, custom roles; examples of plugin territory are analytics, SEO options, and contact forms (https://make.wordpress.org/themes/handbook/review/required/). The handbook states no reason, but the motivation is consistently switching: "the users of your theme won't be able to switch themes without losing their custom post types", and owners would have to "clean old, non-functional shortcode bits from their content" (https://code.tutsplus.com/the-concept-of-plugin-territory-in-wordpress--cms-25083t). The Themes team's 2018 meeting catalogued contested items (share buttons, contact forms, SEO meta, image resizing, header/footer scripts) and noted that a fallback to the default theme is "essentially a theme switch, but not controlled by the user" (https://make.wordpress.org/themes/2018/12/09/plugin-territory-and-content-creation-meeting/).

**Customizing without blocking a switch or update.** Child themes exist so that "parent themes [can] be updated without losing your modifications"; a same-named template in the child shadows the parent's (https://developer.wordpress.org/themes/advanced-topics/child-themes/). A child theme is bound to one parent, so it protects updates, not switches.

**Preview.** "Live Preview" shows an installed theme "with your site's content" before activating; the docs warn not to activate if the preview is blank, and suggest a test site for more thorough checks (https://wordpress.org/documentation/article/work-with-themes/).

### Ghost

- **Custom theme settings** are declared by the theme in `package.json` (`config.custom`), five types (select, boolean, color, image, text), capped at 20 per theme. Ghost tells authors to avoid micro-adjustments, settings that alter the theme's primary use case, and functional settings. Renaming a setting key between versions "is a breaking change": the old value is removed and lost (https://docs.ghost.org/themes/custom-settings).
- Settings are bound to the theme's identity (folder name plus `package.json` name). Staff: "Theme settings are theme-specific because each theme can define what those settings are"; same name means an overwrite and settings are preserved, a different name resets them (https://forum.ghost.org/t/theme-updates-reset-design-branding/55121). So a switch to another theme starts its settings at defaults; Brand settings (site-level) survive.
- **Site-level data**: navigation (primary and secondary) is edited in Admin settings, not the theme, and themes read it through `{{navigation}}`; a theme that does not render `type="secondary"` silently drops the secondary menu (https://ghost.org/changelog/secondary-navigation/; https://docs.ghost.org/themes/helpers/data/navigation; gap report https://forum.ghost.org/t/secondary-navigation-missing-from-edge-theme/24153).
- **What breaks**: `routes.yaml` may route to templates only the old theme has; theme vendors ship their own `routes.yaml` and require it uploaded separately (https://docs.ghost.org/themes/routing; https://brightthemes.com/docs/tuuli, community). Per-post custom templates (`custom-*.hbs`) are chosen in post settings and stored on the post, so the content records a theme-specific template name (https://docs.ghost.org/themes/structure/). A user who switched Edition to Dawn and back reported lost code injection, brand color, social accounts, and reverted navigation; staff called it a "concerning data bug" with no root cause found (https://forum.ghost.org/t/switching-between-official-themes-erased-data/27115).

### Shopify (Online Store 2.0)

- **Per-theme storage**: `config/settings_data.json` lives inside the theme and holds the merchant's values; presets give "up to five pre-configured designs from the same theme code base", and presentational values "are overwritten when switching theme styles" (https://shopify.dev/docs/storefronts/themes/architecture/config/settings-data-json). Section layouts live in the theme's `templates/*.json`.
- **Site-level**: products, collections, pages, blogs, and navigation live in the admin, outside the theme, and survive a switch; theme, section, and block settings and custom CSS/JS do not, because "themes are generally not compatible with each other" (https://community.shopify.com/t/does-everything-transfer-when-switching-over-your-theme-to-a-new-one/188078, community; https://community.shopify.com/t/how-can-i-move-sections-between-different-themes-in-my-online-store/63870, community). Copying `settings_data.json` across is advised against except between themes from one developer.
- **Switching is non-destructive by design**: "If you publish a new theme, then your previously published theme moves to the Draft themes section. None of your theme changes are lost" (https://help.shopify.com/en/manual/online-store/themes/managing-themes/publishing-themes). Only one theme is published at a time.
- **Preview**: draft themes are previewed and customized in the theme editor before publishing, with a shareable preview link (https://help.shopify.com/en/manual/online-store/themes/adding-themes).
- **Keeping third-party functionality portable**: theme app extensions mean "Merchants won't need to manually edit their theme code" and "a single set of integration logic and instructions works for all themes" (https://shopify.dev/docs/apps/build/online-store/theme-app-extensions); uninstalls leave no "ghost code" (https://shopify.dev/changelog/online-store-2-0-extend-apps-into-the-online-store-with-theme-app-extensions). This was Shopify's fix for apps that pasted code into `theme.liquid`, which leaked across uninstalls and did not follow a switch (https://community.shopify.com/t/672753, community). App blocks still have to be placed per theme.

### Hugo

- Lookup order: "Hugo will look first in the project and then in" each theme component left to right; layouts, static files, and archetypes merge at the file level ("the left-most file will be chosen"), data and i18n merge deeply. A theme's own config may set params, menus, and output formats, and the project's entries win (https://gohugo.io/hugo-modules/theme-components/). Site customizations live in the project tree and so survive a theme change, but an override written against the old theme's partial names is dead or wrong against the new theme.
- Menus and params live in site config; a new theme reads whatever param names it chooses, so param names do not map across themes (same page warns authors to use their own namespaces).
- What breaks: shortcodes are theme files. Content using a theme's shortcode fails the build on a switch with "failed to extract shortcode: template for shortcode ... not found" (https://discourse.gohugo.io/t/error-template-for-shortcode-alert-not-found/18389; https://discourse.gohugo.io/t/academic-theme-failed-to-extract-shortcode-template-for-shortcode-callout-not-found/28857). This is WordPress's shortcode problem, loud instead of silent.

### Jekyll

- Gem themes: the site's own `_layouts`, `_includes`, `_sass`, `assets` take precedence; copying a theme file into the site "stops you from receiving theme updates for those files", and the docs suggest a separate CSS file with more specific selectors instead. Switching means changing the gem and `theme:` in `_config.yml`; converting to a regular theme means copying all its files in (https://jekyllrb.com/docs/themes/). Front matter `layout:` names in content must exist in the new theme.

### Drupal

- Block placement is per theme. When a theme is first enabled its blocks mimic the default theme's configuration, but blocks assigned to a region the new theme lacks vanish from the block admin or land in the first defined region (https://www.drupal.org/node/1117778; https://www.drupal.org/node/233472). Content and menus are entities outside the theme and survive.

### Squarespace and Wix

- Squarespace 7.1 has one template; you restyle it rather than switch, and moving from 7.0 to 7.1 means building a new site (https://forum.squarespace.com/topic/176995-how-to-change-theme/, community; https://studio-elias.squarespace.com/blog/can-you-switch-templates-in-squarespace, community). In 7.0 switching existed and could change structure as well as design (https://www.stylefactoryproductions.com/blog/squarespace-change-template, community).
- Wix: no official source found; consistent secondary reports say a published site cannot swap templates and the path is a new site plus manual content transfer. Treat as unverified.
- Lesson: when the template is also the page structure, the vendor's answer is "restyle, don't switch".

### Copy-in systems (shadcn/ui, Astro and Eleventy starters)

- shadcn/ui: components are copied into the repo; updating means re-running `add`, which overwrites the file, so local edits are lost unless reviewed with the CLI's diff first (https://vercel.com/academy/shadcn-ui/updating-and-maintaining-components). Theming is CSS variables in `globals.css`; because components reference semantic tokens, a theme change is a token change, not a component rewrite.
- Astro theme starters: a "Template" install is "lightweight and simple, but hard to update"; a "Fork" install "is easy to update but needs some skills for git" (https://astro-pure.js.org/docs/setup/getting-started). Fork users merge `upstream/main` into a theme branch, then into the site (https://github.com/codecodeio/codecode.io). There is no switch story: switching starters means porting content into a new repo.

## Cross-system patterns

1. **The universal survivors are content and site-level records** (posts, pages, media, menus as objects, site name, brand). Every system that keeps these outside the theme lets them survive a switch: WordPress, Ghost, Shopify, Drupal, Hugo.
2. **Per-theme settings never map**; they are keyed by theme identity and lie dormant on switch-away, restoring on switch-back (WordPress theme mods, Ghost name-keyed settings, Shopify `settings_data.json`). Nobody maps one theme's options onto another's because option vocabularies are theme-defined.
3. **The worst breakage is content that names theme features**: shortcodes (WordPress, Hugo), custom post types bundled in themes, custom templates selected per post (Ghost, Jekyll `layout:`), routes pointing at theme templates (Ghost). WordPress's plugin-territory rule exists to stop this.
4. **The second worst is slot mismatch**: theme-declared menu locations, widget areas, and regions with unstandardized names (WordPress, Drupal, Ghost secondary nav).
5. **Owner customizations stored with the theme are lost on switch** (WordPress Additional CSS, block template edits, Shopify custom code). Systems that put the owner's layer outside the theme (Hugo project files, Jekyll site files) keep it, but it may target names the new theme lacks.
6. **Safe switching is non-destructive switching plus preview**: Shopify's old theme moves to drafts, WordPress Live Preview and Shopify's draft preview show the new theme on real content.

## Synthesis for cairn

### (a) The minimum the design must guarantee now

1. **The content contract is engine-owned, not theme-owned.** Collections, front-matter fields, fixed page paths, and the directive vocabulary (names, attributes, meaning) are specified outside `src/theme/`. A theme supplies renderers for every directive; it may not add a directive, drop one, or change its attributes. Content never names a theme part (no `layout:` or template field in front matter). This is the plugin-territory rule applied to content syntax (WordPress handbook; Hugo shortcode build failures; Ghost custom templates).
2. **Every site-level record lives outside the theme**: site name, menus, topics, social links, logo, analytics, and head metadata in the site config, read by the theme through a fixed, typed interface. Menus use a closed set of engine-named slots (for example `primary`, `footer`), so a switch never needs name guessing (WordPress #39693, Drupal regions, Ghost secondary nav).
3. **A recorded theme identity and option choices outside the theme directory**: theme id, version, and the selected options by semantic key (`accent: "teal"`), not only the token values written into theme CSS. Without that record, a later switch cannot tell what the owner chose (Ghost key renames lose values; Shopify presets overwrite values).
4. **A site-owned override layer outside `src/theme/`** (for example a site stylesheet loaded after the theme, aimed at the shared token names), so the owner's small adjustments survive a theme replacement. WordPress's per-theme Additional CSS is the counterexample.
5. **The theme interface is closed and fixed**: the four components with stable props, the token names the daisyUI and `@theme` blocks must define, the directive renderer signature. A theme that satisfies it can be dropped in; a contract test can check it.
6. **Provenance for the copied files**: record a hash per theme file at setup, so a later command can tell pristine files from owner-edited ones (shadcn's diff-before-overwrite).

### (b) What a later switch command could reasonably promise

- Replace `src/theme/` wholesale on a branch, re-apply options that map by key, and leave content, site config, and the override layer untouched.
- Report, before acting: which theme files the owner edited (from the provenance hashes) and will lose, which options did not map, and which override-layer selectors target names the new theme lacks.
- Prove the new theme against the contract: every directive, collection, fixed page, and menu slot renders.
- Preview through a Cloudflare preview deployment of that branch, and roll back by reverting the commit (git is the "draft themes" list).
- Not promise: carrying owner edits to the old theme's files forward, merging two themes, or mapping one theme's private options onto another's.

### Corners, ranked

1. **Directives or content features owned by a theme.** Content then locks to that theme and a switch breaks pages, loudly or silently (WordPress plugin territory, https://make.wordpress.org/themes/handbook/review/required/; Hugo, https://discourse.gohugo.io/t/error-template-for-shortcode-alert-not-found/18389).
2. **Option choices kept only as values written into theme files.** The choice is lost the moment the files are replaced (WordPress theme mods, https://developer.wordpress.org/reference/functions/get_theme_mods/; Ghost, https://docs.ghost.org/themes/custom-settings).
3. **Owner customizations mixed into theme files with no separate layer.** Every switch becomes a manual port (WordPress Trac #38549, https://core.trac.wordpress.org/ticket/38549; Shopify custom code, https://community.shopify.com/t/does-everything-transfer-when-switching-over-your-theme-to-a-new-one/188078).
4. **Theme-declared menu slots or regions.** Assignments drop on switch (https://ms-studio.net/notes/painless-theme-switching-in-wordpress/; https://www.drupal.org/node/1117778).
5. **Content or routes naming theme templates.** (Ghost routes and custom templates, https://docs.ghost.org/themes/routing.)
6. **Themes requiring derived assets**, such as fixed image crops, that existing media lacks (https://learn.wordpress.org/tutorial/regenerate-thumbnails/).
7. **Themes that own structure, not only look.** The platform's answer becomes "you cannot switch" (Squarespace 7.1, https://forum.squarespace.com/topic/176995-how-to-change-theme/).
8. **No recorded theme identity.** Settings tied to a guessed name reset unexpectedly (https://forum.ghost.org/t/theme-updates-reset-design-branding/55121).
