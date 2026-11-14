# What kinds of site do other ecosystems ask about? Research for cairn's setup question

Fetched live 2026-11-14 from public pages and APIs only. Counts marked "mine" were computed by me from fetched page data. Interpretation is labeled "My interpretation". Anything I could not confirm is in the Unverified list.

## 1. Comparison table

"Closed" means a fixed vocabulary the catalog owner controls. "Free" means authors type their own tags. Count is the number of values on the axis a visitor sees.

| Ecosystem | Axis | Closed or free | Count | The list | URL |
|---|---|---|---|---|---|
| WordPress.org themes | Subject (site purpose), max 3 per theme | Closed, curated by Theme Review Team | 9 | blog, e-commerce, education, entertainment, food-and-drink, holiday, news, photography, portfolio | https://api.wordpress.org/themes/info/1.2/?action=feature_list ; https://make.wordpress.org/themes/handbook/review/required/theme-tags/ |
| WordPress.com themes | Mixed: purpose plus industry | Closed | 19 (+All) | Blog, Portfolio, Business, Store, Art & Design, About, Real Estate, Health & Wellness, Authors & Writers, Newsletter, Education, Magazine, Music, Restaurant, Travel & Lifestyle, Fashion & Beauty, Community & Non-Profit, Podcast, Entertainment | https://wordpress.com/themes |
| Ghost themes | Publication type, one per theme | Closed | 8 (+Official) | Newsletter, Blog, News, Magazine, Podcast, Photography, Portfolio, Docs | https://ghost.org/themes/ |
| Astro themes | Category (multi-claim) | Closed | 8, of which 5 are purposes | Blog, Docs, E-commerce, Landing Page, Portfolio (purposes); Minimal, Official, Other (not purposes). Homepage cards show the same five purposes. | https://astro.build/themes/ |
| Hugo themes | Free-form tags, normalized by an allowlist | Closed in effect (see section 3) | 29 shown | blog, minimal, personal, dark, light, multilingual, portfolio, dark-mode, landing, docs, tailwind, company, popular, bootstrap, gallery, contact, archive, ecommerce, magazine, sass, podcast, book, light-mode, agency, hero, newsletter, two-column, api, church | https://themes.gohugo.io/tags/ |
| Zola themes | Free-form tags | Free | 41 tags on 49 themes (mine) | Blog(11), dark(9), Responsive(8), minimal(7), resume(6), Search(6), landing(4), SEO(4), documentation(2), portfolio(2), photography(1), podcast(1), many singletons; case duplicates such as "dark" and "dark-mode" | https://www.getzola.org/theme-tags/ |
| Jekyll (jekyllthemes.io, third-party; no official categories) | Purpose plus a tech-compat tag | Closed | 5 | Portfolio, Blog, Documentation, Business, GitHub Pages | https://jekyllthemes.io/ |
| Eleventy | None | n/a | 0 | One official starter (eleventy-base-blog), about 179 community starters ranked by Speedlify score | https://www.11ty.dev/docs/starter/ |
| Gatsby starters | Purpose tabs | Closed | 8 tabs | Popular, Headless CMS, Blog, Portfolio, Documentation, Boilerplate, E-commerce, Community (page may be stale) | https://www.gatsbyjs.com/starters/ |
| Vercel templates | "Use Case" facet, mixed purpose, function, tech | Closed | 25 | AI, Authentication, Backend, Blog, CDN, CMS, Cron, Documentation, Ecommerce, Edge Middleware, Experimentation, Feature Flags, Global Config, Marketing Sites, Microfrontends, Monorepos, Multi-Tenant Apps, Portfolio, Realtime Apps, SaaS, Security, Starter, Vercel Firewall, Virtual Event, Web3 | https://vercel.com/templates |
| Docusaurus showcase | Showcase tags, not site kinds | Closed | 10 | favorite, opensource, product, design, i18n, versioning, large, meta, personal, rtl | https://raw.githubusercontent.com/facebook/docusaurus/main/website/src/data/users.tsx |
| Webflow templates | Industry-led, multi-claim | Closed | 26 | Architecture & Design, Arts & Entertainment, Blog & Editorial, Community & Nonprofit, Documentation, Education, Environment, Food & Drink, Government, Hair & Beauty, Home Services, HR & Hiring, Launch & Coming Soon, Medical, Music & Audio, Personal, Portfolio & Agency, Professional Services, Real Estate, Retail & E-Commerce, Technology, Transportation, Travel, UI Kit, Weddings & Events, Wellness | https://webflow.com/templates/categories |
| Framer templates | Two-level, industry-led | Closed | 10 parents x 4 children = 40 | Portfolio, Software, Agency, Ecommerce, Services, Health, Publishing, Real Estate, Hospitality, Events (each with 4 children, for example Publishing: Blogs, Entertainment, Magazines, News) | https://www.framer.com/marketplace/templates/ |
| Squarespace templates | Two facets: Type and Topic | Closed | 9 Type + 19 Topic | Type: Online Store, Portfolio, Memberships, Blog, Scheduling, One Page, Courses, Services, Donations. Topic: Art & Design, Community & Non-Profits, Education, Entertainment, Events, Fashion, Fitness & Sports, Food, Health & Beauty, Home & Decor, Local Business, Media & Podcasts, Nature & Animals, Personal & CV, Photography, Professional Services, Real Estate & Properties, Restaurants, Travel, Weddings | https://www.squarespace.com/templates |
| Wix templates | Two facets: Type and Industry | Closed | 4 Type + 15 Industry | Type: One Page, eCommerce, Portfolio & CV, Blog. Industry: Business, Industrial, Health & Wellness, Events, Education, Communities, Fashion & Style, Beauty & Hair, Design, Photography, Music, Creative Arts, Video, Restaurants & Food, Travel & Tourism | https://www.wix.com/website/templates |
| Shopify themes (e-commerce only) | Industry, plus catalog size | Closed plus free-text "Other" | 20 industries, 4 catalog sizes | Art, Auto, Bags, Beauty, Clothing, Electronics, Entertainment, Food and drink, Garden, Hardware, Home, Jewelry and accessories, Kids, Office, Pets, Services, Shoes, Sports, Toys, Wellness | https://themes.shopify.com/themes |
| Carrd | Starting point (the kind picks the template) | Closed | 5 (+Blank) | Profile, Landing, Form, Portfolio, Sectioned | https://carrd.com/build |
| Blot | Subject | Closed | 5 | Writing, Art, Research, Photography, Design (21 templates; category not shown per template) | https://blot.im/templates |

Counts per value where I could verify them (mine unless noted):

- WordPress.org (API per tag; total directory 8773): blog 7482, portfolio 4289, e-commerce 3433, news 2102, photography 1535, entertainment 1245, education 967, food-and-drink 574, holiday 111.
- Ghost (261 themes, one category each): Magazine 97, Blog 86, Portfolio 25, News 21, Newsletter 13, Podcast 7, Docs 7, Photography 5.
- Astro (approximate, pages times 18 plus last page; about 1466 themes): blog 815, landing-page 802, minimal 596, other 567, portfolio 501, ecommerce 158, docs 118.
- Hugo (about 323 themes, counted from tag pages): blog 241, minimal 190, personal 126, portfolio 53, landing 41, docs 34, company 31, gallery 27, ecommerce 5, magazine 5, podcast 4.
- Webflow (stated on the page, counts overlap): Portfolio & Agency 7370, Technology 6235, Professional Services 2748, Retail & E-Commerce 1163, Blog & Editorial 989, Architecture & Design 902, Wellness 815, Home Services 748, Food & Drink 684, Medical 549, Real Estate 532, Education 447, Personal 397, Travel 357, Environment 339, Hair & Beauty 315, Community & Nonprofit 279, Transportation 206, UI Kit 191, Arts & Entertainment 184, Weddings & Events 181, Music & Audio 138, HR & Hiring 136, Documentation 86, Launch & Coming Soon 56, Government 53.

## 2. Frequency of purpose-type kinds across ecosystems

Fifteen catalogs carry a kind or purpose axis: WordPress.org, WordPress.com, Ghost, Astro, Hugo, Zola, jekyllthemes.io, Gatsby, Vercel, Webflow, Framer, Squarespace, Wix, Carrd, Blot. Excluded: Shopify (e-commerce only), Eleventy (no categories), Docusaurus (tags are not site kinds). Counts are my tallies from the lists in section 1.

| Kind (synonyms merged) | Catalogs carrying it, of 15 | Which |
|---|---|---|
| Portfolio (Portfolio, Portfolio & Agency, Portfolio & CV) | 14 | all except Blot |
| Blog / writing (Blog, Blog & Editorial, Writing, Publishing > Blogs) | 14 | all except Carrd |
| E-commerce / store (e-commerce, Store, Ecommerce, Online Store, Retail & E-Commerce) | 9 | WP.org, WP.com, Astro, Hugo, Gatsby, Vercel, Webflow, Framer, Squarespace, Wix |
| Landing / one page / marketing (Landing Page, One Page, Marketing Sites, Launch & Coming Soon, Landing) | 8 | Astro, Hugo, Zola, Vercel, Webflow, Squarespace, Wix, Carrd |
| Personal / CV / resume / profile (About, Personal, Personal & CV, Profile, resume, Portfolio > Resume) | 8 | WP.com, Hugo, Zola, Webflow, Framer, Squarespace, Wix, Carrd |
| Documentation (Docs, Documentation) | 8 | Ghost, Astro, Hugo, Zola, Jekyll, Gatsby, Vercel, Webflow |
| Business / company / agency / services (Business, company, Professional Services, Local Business) | 7 | WP.com, Hugo, Jekyll, Webflow, Framer, Squarespace, Wix |
| News / magazine / newsletter / podcast (publication) | 7 | WP.org, WP.com, Ghost, Hugo, Zola, Framer, Squarespace |
| Photography (Photography, photoblogging) | 7 | WP.org, Ghost, Zola, Framer, Squarespace, Wix, Blot |
| Education | 6 | WP.org, WP.com, Webflow, Framer, Squarespace, Wix |
| Restaurant / food | 6 | WP.org, WP.com, Webflow, Framer, Squarespace, Wix |
| Music | 5 | WP.com, Webflow, Framer, Squarespace, Wix |
| Travel | 5 | WP.com, Webflow, Framer, Squarespace, Wix |
| Community / non-profit | 5 | WP.com, Webflow, Squarespace, Wix (Communities), Hugo (church, 1 theme) |
| Events / weddings | 4 | Webflow, Framer, Squarespace, Wix |
| Real estate | 4 | WP.com, Webflow, Framer, Squarespace |

Reading the table: the first two kinds, portfolio and blog, appear almost everywhere. The next tier (store, landing, personal, docs, business, publication, photography) appears in about half. Everything below that is an industry vertical that appears only in the industry-led catalogs (WordPress.com, Webflow, Framer, Squarespace, Wix). Documentation is carried mostly by the developer-tool ecosystems (Ghost, Astro, Hugo, Zola, Jekyll, Gatsby, Vercel) and, among the industry-led catalogs, only by Webflow.

## 3. History findings

**WordPress.org rebuilt a failing subject list into 9 values (2015 to 2016).**

- 2015: https://make.wordpress.org/themes/2015/07/27/theme-directory-tagsfilters/ . Only three subject tags existed (Photoblogging, Holiday, Seasonal). Quote: "No one is using these tags to find themes, but I believe it's because our subject tags leave a lot to be desired." Same post: the tags "need some major work", and subject tags are "the biggest point we need to focus on". A survey said people use the tag filter most.
- 2014 precursor: a ticket proposed 17 subjects (Personal Blog, Magazine, Portfolio, Photography, Film and TV, Business, Travel, Technology, Political, Charity, Nightlife, Events, Restaurants & Cafes, Music / Bands / DJs, Wedding, WooCommerce, Miscellaneous). Quote: "a list of subjects that are actually relevant to the real world of 2014 WordPress Themes"; good free themes are "very difficult to find". Source: https://lists.wordpress.org/pipermail/wp-trac/2014-March/211460.html
- Aug 2015 proposal: "This is a proposal for complete overhaul of 'subject' tags", pointing to a June 2015 survey. The 9-value list is already in it. Source: https://lists.wordpress.org/pipermail/wp-meta/2015-August/007357.html
- 24 May 2016: https://make.wordpress.org/themes/2016/05/24/new-theme-tags-have-arrived/ . Nine subject tags added, photoblogging and seasonal removed. Quote: "The changes were the result of user and theme author surveys with exhaustive discussions". Authors were told to remove retired tags from style.css.
- WP Tavern, on the 4.6 admin change: the Subject section will be "completely revamped" and replaced with "a new list of general theme categories"; reason given: "The WordPress theme landscape has changed so much over the years". Source: https://wptavern.com/wordpress-4-6-to-update-theme-filter-tags-in-the-admin
- Meta ticket #1187 (https://meta.trac.wordpress.org/ticket/1187) and core ticket #33407 (https://core.trac.wordpress.org/ticket/33407) returned 403 to me. I did not read them.
- Result as of today: the list is still the same 9 values, ten years later (API feature_list). Subject tags are capped at 3 per theme. I found no source stating the reason for the cap.

**Hugo tightened a free-form tag system into an allowlist (2023 to 2025).**

- The tag builder normalizes author tags through a fixed map. Source: https://raw.githubusercontent.com/gohugoio/hugoThemesSiteBuilder/main/pkg/buildcmd/build.go . `goodTags` holds 31 entries (agency, api, archive, blog, book, bootstrap, church, company, dark, dark mode, ecommerce, education, gallery, green, hero, light, light mode, magazine, multilingual, newsletter, personal, pink, podcast, portfolio, sass, tailwind, two-column, and aliases). Anything else is matched by substring (blog, contact, bootstrap, docs/document, landing, "one" to landing, minimal, "product" to ecommerce) and otherwise dropped (`return ""`).
- Aliases merge synonyms: business to company, archives to archive, tailwindcss to tailwind, white to light.
- The site's tag index shows only tags with at least 3 themes (`where $tags "Count" ">=" 3` in https://raw.githubusercontent.com/gohugoio/hugoThemesSite/master/layouts/_partials/listtags.html). That is why 29 tags display. Resolves my earlier open question.
- Commit trail: "Fix tags, rebuild cache" 2023-09-01 (fixes issue #345, "Missing filter tags on website": "The filter tags seem to have disappeared ... Only `All` remains", https://github.com/gohugoio/hugoThemesSiteBuilder/issues/345); "Adjust the tag filter" 2025-04-13; "Adjust tag list" 2025-04-17; "Add a 'popular' tag" 2025-04-17 (https://github.com/gohugoio/hugoThemesSiteBuilder/commit/b549b1eaa9df95b7eecd984f66018c3847247e88 and neighbors). Commit messages give no reason beyond the titles. I found no written rationale for the allowlist.
- The README says tags are free-form in theme.toml (`tags = ["blog", "company"]`): https://github.com/gohugoio/hugoThemesSiteBuilder . The allowlist is therefore applied by the site builder, not by authors.

**Ghost users ask for multi-select.** Forum thread https://forum.ghost.org/t/theme-marketplace-suggestions-to-improve-theme-filtering/62992 : the category tabs "act as the only real way to narrow things down", and a theme can sit in only one category though it fits several; the poster proposes a multi-select Type filter. No staff reply shown.

**Zola's free-form tags sprawled.** No complaint found. The data shows it: 41 tags on 49 themes, with case duplicates ("dark" 9 beside "dark-mode" 3). https://www.getzola.org/theme-tags/

**Webflow copy error.** The Environment category's description duplicates Education's, visible at https://webflow.com/templates/categories (a sign of a long list maintained by hand).

**Shopify added per-preset listings to merchandise by industry and catalog size.** Quote: "Each preset now has its own theme card and listing page", "greater opportunity to merchandise themes to specific industries and catalog sizes". Source: https://shopify.dev/changelog/improved-theme-discovery-and-merchandising-on-the-shopify-theme-store . Presets are developer-defined theme styles, and "Shopify does not overwrite content values with a theme style": https://www.shopify.com/partners/blog/shopify-theme-styles-and-presets .

## 4. Onboarding questions (does the kind pick starting content?)

- Squarespace Blueprint: a new site starts by asking you to "answer a few questions about your goals, industry, and brand personality"; the answers produce "tailored design recommendations" and starter pages and sections. The exact questions are not listed. https://www.squarespace.com/blog/starting-a-website-with-squarespace-blueprint
- Carrd: the starting point (Profile, Landing, Form, Portfolio, Sectioned, or Blank) is the template, so the kind chosen fixes the starting content. https://carrd.com/build
- Wix mobile flow: "After choosing from several options that help pinpoint what your site is about, Wix builds the site." Options not listed. https://support.wix.com/en/article/creating-a-new-site-from-your-phone
- WordPress.com: a third-party flow recording lists the steps as sign-up, domain, plan, select goals, select category, select template (pageflows.com, secondary: https://pageflows.com/post/desktop-web/onboarding/wordpress/). Labels not confirmed. A 2018 secondary post says the older flow asked blog, website, or portfolio: https://www.goodreads.com/author_blog_posts/16557768-updated-signup-and-site-creation-on-mobile-devices
- Framer help article shows use-case choices "Build startup site, Launch landing page, Start company blog"; the source does not say whether they appear at signup (https://www.framer.com/ja/help/articles/creating-a-framer-account/, secondary via search summary).

## 5. What the evidence says about list length

Facts first, then my interpretation.

Facts:

- Lists that are purpose-only and closed are short: Carrd 5, Blot 5, jekyllthemes.io 5, Astro 5 purposes (8 with non-purposes), Ghost 8, Gatsby 8, WordPress.org 9.
- Industry-led catalogs run longer: Wix 15 industries plus 4 types, WordPress.com 19, Squarespace 19 topics plus 9 types, Shopify 20, Webflow 26, Framer 40 (two-level, 10 parents).
- Free-form or loosely governed systems sprawl: Zola 41 tags on 49 themes with case duplicates; Hugo's builder maintains a 31-entry allowlist with aliases and hides tags with fewer than 3 themes.
- The only list I found with a documented survey process, WordPress.org's, settled on 9 purpose values and has kept them for ten years.
- On WordPress.org, "blog" is on 7482 of 8773 themes (mine, about 85 percent) and "portfolio" on 4289 (about 49 percent), with a cap of 3 subjects per theme. Astro's per-category counts sum to 3557 against about 1466 themes, so themes claim about 2.4 categories each (mine).
- Kinds appearing in 14 of 15 catalogs: portfolio and blog. Next tier at 7 to 9 of 15: store (9), docs (8), landing (8), personal (8), business (7), publication (7), photography (7).

My interpretation (not from a source):

- A purpose-only list of 5 to 9 values is the range where independent catalogs converge. Both the WordPress.org survey outcome and the short lists elsewhere point there.
- The values that earn a place are the ones that change what a site's content looks like: blog, portfolio, docs, landing, personal, publication. The industry verticals (restaurant, medical, real estate) change theme styling and copy, not content structure, and appear only in catalogs that sell templates by industry.
- For cairn specifically, e-commerce is out of scope per the project charter, so the e-commerce row (9 of 15) would not carry over.
- Multi-claim is a known pressure: WordPress.org capped subjects at 3, Ghost users ask for multi-select, and Astro themes claim several categories. A single-answer setup question would force a primary kind, which is what Carrd does.
- Mixing axes (purpose with style or tech, as in Hugo, Zola, Vercel, Astro's Minimal) was the sprawl pattern. Keeping one axis is the cleaner design.

## 6. Unverified

- Webflow, Framer, Ghost, and Micro.blog onboarding questions: nothing found. Framer use-case list is from a help-page search summary only.
- WordPress.com onboarding option labels, and the wp-calypso goals enum: not found.
- Wix onboarding option list: only the support page's general wording.
- Squarespace Blueprint exact questions, and whether the answer fixes starting pages.
- Bear Blog and Micro.blog: no category or kind system found.
- WordPress.org Meta #1187 and core #33407 discussions: 403, not read. Reason for the cap of 3 subject tags: not found.
- Hugo: any written rationale for the allowlist or tag-count threshold: none found.
- Gatsby starters page may be stale; no counts shown. Vercel use-case facet counts not shown.
- Astro submission form options and any per-theme category limit: the form moved to portal.astro.build and I did not read it. Astro counts are approximate.
- Jekyll counts are from listing pages, pagination not verified; jekyllthemes.org was unreachable. No official Jekyll categories exist at jekyllrb.com or pages.github.com.
- Docusaurus and VitePress theme or template catalogs: Docusaurus showcase tags read (not site kinds); VitePress not checked for categories.
- Whether each Shopify preset has its own demo store.
- Shopify and Astro numeric counts and the Hugo tag counts were computed by me from page data and may drift as catalogs change.
