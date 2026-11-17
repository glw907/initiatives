---
kind: design
approve: I send the desk your answers, record the changes below in the events and round-two designs and their prompts, and write the planner prompt for the pass. Nothing launches on approve. The pass launches later, when its start line holds.
sendback: I answer each note and return the revised design. The designs you approved stay as they are until then.
---

# Approve the engine's fourth routing value, for content whose pages a site's code serves?

You held events until the engine has a routing value for content whose pages a site's code serves. This page is the design of that value and of the one engine pass that builds it. Under the value the engine knows the address of every event. It lists each one in the sitemap and offers it to the link picker, to `cairn:` links, and to the menu editor, and its catch-all route leaves the page to the site's route. I ran the code behind each claim, and the results are under "What I ran". Two findings differ from the page you approved. The pass is 200 design minutes where that page guessed 120, and the value replaces the `paths` key for events only. That key is a feature's list of the addresses it serves itself, and the contact page still needs it. Four questions are yours: the value's name, where the pass runs, whether the edit screen shows a full address for every kind, and the limits. With the recommended answers the pass joins the foundation round as its seventh pass and runs while pass 4 is on hold. Nothing launches on approve. The foundation conductor starts the pass after it has read pass 3, which is running now.

## What the value does

The engine gives each kind of content one of three routing values today. Posts are `dated`, pages are `page`, and `embedded` content, such as a fragment of text that a page includes, has no page. A kind with the fourth value has an address for each entry, and a route in the site's code serves the page.

The engine learns the address pattern from the `permalink` key that every kind already has. Left out, it defaults to `/events/:slug` for a kind called `events`. So the value needs no second key, and a site developer adds one line.

A site developer writes the routing line in `cairn.config.ts` and one route file, `events/[slug]`, whose loader is one call to the engine. If the route file is missing, the engine says so in one line that names the address, the kind, and what to change.

An editor finds events in the link picker and in the menu editor's list of pages. A `cairn:` link to an event resolves. The edit screen calls an event's identifier its address, and the button reads "Change address".

A visitor gets the same event pages as before, and a search engine finds each one in the sitemap.

The name is a word a site developer types beside `'dated'`, `'page'`, and `'embedded'`. It also appears in the engine's error lines and in the docs. Here is the config line under each candidate:

```ts
routing: 'custom',     // a custom route serves these pages
routing: 'site',       // the site serves these pages
routing: 'own-route',  // these pages have their own route
```

What should the fourth routing value be called?

:::question The value's name
- **`'custom'`**. It reads as "this kind has a custom route", the phrase SvelteKit developers and the cairn docs already use for a route a site writes itself. The error line reads `whose routing is 'custom'`. {recommended}
- **`'site'`**. It is the shortest and says who serves the page. Everything in `cairn.config.ts` belongs to the site, so the word tells a reader less than the other two.
- **`'own-route'`**. It says most exactly what is true. It would be the only value with a hyphen and two words, beside three single words.
:::

## What an editor sees for an event

Under `embedded` the admin calls an event's identifier its name, because the engine believes an event has no address. Under the new value the three labels change with no code change: the edit screen's heading reads "Address", its button reads "Change address", and the create dialog asks for an address.

One thing on that screen is wrong today for every kind but pages, and the new value makes it show on events. The edit screen prints a short address made of a slash and the entry's short name. A post reads `/my-post` when its page is at `/posts/my-post`. An event would read `/spring-regatta` when its page is at `/events/spring-regatta`. The rename dialog has the same fault in its sentence "The new address will be".

The menu editor's list of pages builds its addresses the same short way. There the fault isn't cosmetic: picking an event would put a dead link in the menu. The pass fixes that list whatever you answer here.

Should the edit screen and the rename dialog show the full address for every kind?

:::question The address on the edit screen
- **Show the full address for every kind.** An editor reads `/events/spring-regatta` on an event and `/posts/my-post` on a post, and the rename dialog names the full new address. This is 30 of the pass's 200 minutes. {recommended}
- **Leave the short address.** An editor reads `/spring-regatta` on an event, as a post reads `/my-post` today. The pass is 170 minutes, and the fault goes to the backlog as one item.
:::

## What the value replaces

The page you approved said the value "would also replace the `paths` key". It does for events, and it doesn't for the contact page.

`paths` was the list of addresses a feature serves itself, which the base's catch-all route reads so that it doesn't build those pages a second time. With the new value the engine leaves event pages out of the catch-all's list and out of the markdown twins without being told. The first `site-events` pass therefore needs no filter and no `paths` key, and the correction that moved the filter into that pass is withdrawn.

The contact page is different. `/contact` is one entry of the pages kind, and routing is set for a whole kind. The engine can't hand one page of a kind to the site's code. So `paths` stays in the design of the contact-form pass, as site code, in the same way the base already treats the home page. Nothing else in the feature contract goes away.

One result of the value is new, and I state it here with no question. An event page has no markdown twin, the `.md` copy of a page that the engine serves beside it. A visitor who asks for `/events/spring-regatta.md` gets a 404. The twin is the catch-all's work, and the catch-all no longer serves events. A feature that wants a twin writes a route for one.

## Where the pass runs

The pass can't run beside the foundation round as a round by itself. The foundation conductor checks the main checkout before each launch, and a second pass at work there would end its launches. That leaves the two placements the desk named.

One fact is newer than the desk's question. You put pass 4 of the foundation round on hold until the brainstorm on updating a site is complete, and passes 5 and 6 wait with it. Pass 3 is running. After it the conductor has nothing to launch.

Joining the foundation round uses that wait. The conductor runs this pass next, after pass 3. The pass needs nothing from passes 4 to 6, and they need nothing from it. While pass 4 is on hold, the pass lands with no document for you unless its review leaves a call. The costs are these:

- It is the first exception to the limit of six passes in a round, and the brainstorm may ask you for another.
- The round's design total goes from 760 minutes to 960, and the point where the conductor stops new launches moves from 1,520 to 1,920. With the short address those figures are 930 and 1,860.
- A live conductor takes a new row in its order table, through the desk.
- The round's report carries an engine change that has nothing to do with site layers.

If the hold ends before the conductor receives your answer, the pass runs after whichever pass is then in flight. It then joins the merge document you already expect for passes 4 to 6.

A round of one pass keeps the foundation round as you approved it. The pass waits for that round to close, which today means waiting for the brainstorm and then for passes 4, 5, and 6. It has a planner and an executor and no conductor. The `site-events` round starts one pass later than under the first option.

Under either option the `site-events` round gains one line in its start line: the value is on `origin/main`.

Where should the engine pass run?

:::question Where the pass runs
- **Join the foundation round as its seventh pass.** The conductor runs it after pass 3, while pass 4 is on hold. Events can start as soon as the foundation round closes. {recommended}
- **Run it as a round of one pass** between the foundation round and `site-events`. The foundation round is unchanged. The pass starts when that round closes, and `site-events` starts one pass later.
:::

## The limits

The pass is 200 design minutes. Passes 1 and 2 of the foundation round planned at about 1.6 times their design minutes, which would put this plan near 320. A plan over twice its design minutes parks: the planner stops before any code is written, and you get a `decide` document. That line is 400 here. If you leave the short address, the pass is 170 minutes and the line is 340.

The usage stop depends on where the pass runs. Inside the foundation round it follows that round's rule. You lifted the 85 percent stop for that round until the weekly reset on November 20 at 11 PM Alaska time, and the stop is 85 percent again after it. As a round of one, the pass stops at 85 percent. At the stop, nothing new launches and work in flight finishes its task. The week stood at 47 percent when I sent this.

Where should the limits sit for this pass?

:::question The limits
- **The standard limits.** A plan over twice the pass's design minutes parks, and the usage stop is the one this section names for the placement you pick. {recommended}
- **A higher plan ceiling of 500 minutes.** A plan between 400 and 500 goes ahead, and the pull request says so. A plan over 500 parks. The usage stop is the same.
:::

:::decide

## Method calls you can skip

Each of these is mine to make, with its reason. The planner takes each as a ruling when you approve.

- The address pattern is the `permalink` key. Every kind has it, with a default, and the engine already checks it. A second key for the same fact would be a piece that does no work.
- The resolved rule gains one flag. A kind's routing resolves to a small record, `RoutingRule`, which holds `routable` and `dated`. About forty lines in the engine ask "does this kind have an address?" and read `routable`. Four ask "does the catch-all serve it?" The new flag, `siteServed`, answers the second question. `routable` keeps the first meaning, and its doc comment says so. The table that builds these records is closed, so no site can make a kind that is `siteServed` with no address.
- The catch-all lists what it serves. `entries()` and `markdownEntries()` return the pages the catch-all serves, and its loader refuses a site-served address with a line for the owner. The engine already follows this rule for pages hidden from search engines: a comment on `markdownLoad` says the list and the loader "agree by construction". Without the refusal, a site that set the value and forgot the route would show events through the article template, and nobody would be told.
- The site's route gets one engine call. `createPublicRoutes` returns a fifth function, `conceptEntryLoad`. The site's `events/[slug]` route calls it with the kind's id and gets the same typed data the catch-all's loader returns. The code that finds an entry and answers 404 then stays in the engine. Site code is copied into every site and ages there, and the function that builds this data isn't an engine export, so a site couldn't write the lookup well in any case.
- Sorting is unchanged. The engine sorts a kind that isn't dated by title. The events feature orders its list by its date fields, as its design says. A site-served value for dated content can be added later as a fifth value with no change to this one.
- The preview is left alone. The share-link preview shows an event in the article template until the events layer gives it a view. The page you approved gives the first `site-events` pass the job of confirming what the preview and the draft switch do for an event. This pass changes neither, and `src/lib/sveltekit/preview.ts` is not in its files.
- The change is additive. No site has to change a line, so the changelog entry carries no `Consumers must:` line. The desk's reading of your note on rebuilt sites isn't needed here, and no choice in this design turns on it.
- This pass lands before the structure round. That round reorders `src/lib` and splits the edit screen. This pass is small, and two approved rounds wait on it. The structure round then moves files that already hold the value. `cairn-structure-design` had no draft in the queue when I sent this, so I had no draft to compare this design with.
- Pass 5 of the foundation round shares `src/lib/delivery/` with this pass.** Passes run one at a time, so whichever runs second reads the other's merged code.
- Under the first placement, the conductor commits the files I write. It is the one session that commits in the initiative record while it runs. I write the planner prompt and the edits to the designs and leave them uncommitted, and the conductor commits each by path before it launches the pass.

## The pass

**Outcome.** A kind can take the fourth routing value. The engine resolves its addresses, lists them in the sitemap, offers them to the link picker, to `cairn:` links, and to the menu editor, and leaves the pages to the site's route. The admin shows the full address of an entry of any kind.

**Initiative.** `theme-garden`.

**Class.** `ordinary`. The folder `scripts/checks/**` belongs to the `runner` class, and the pass changes one file there, the surface snapshot `api-surface.md`. The command `npm run check:surface -- --update` writes that file, and the pass edits no check script. Pass 2 of the foundation round changed the same file as an `ordinary` pass. The pass touches no `auth-data` file.

**Files.** `src/lib/content/**` (the type, the table of routing values, and the error line that lists them), `src/lib/delivery/**` (the resolver and the public routes), `src/lib/sveltekit/**` (the menu editor's list of pages and the edit screen's data, and never `preview.ts`), `src/lib/admin/**` (the edit screen and the rename dialog), `src/lib/reproductions/**` (fixtures), `src/tests/**`, `scripts/checks/api-surface.md`, `skills/cairn-extending-a-site/references/content-model.md` and `public-routes.md`, `docs/internal/engine-rulings.md`, `CHANGELOG.md`, and `MIGRATION-NOTES.md`.

**Out of scope.** The events feature and its route. Any change to `examples/showcase/**` or `templates/waymark/**` that is committed. A markdown twin for a site-served page. The preview's view of an event. A dated site-served value. Backlog #496, the home-page check copied into five route files.

**Design minutes.**

| Work | Minutes |
| --- | --- |
| The type, the table of routing values, and the error line | 15 |
| The 57 hand-built routing records in 35 test files and the reproduction fixtures, which stop compiling when the record gains a field | 15 |
| The resolver and its tests | 20 |
| The public routes: the two lists, the refusal, the new loader, and their tests | 30 |
| The full address on the edit screen and in the rename dialog | 40 |
| The menu editor's list of pages | 10 |
| The sitemap test, and one test that drives every reader from one config | 20 |
| A build of the showcase with an events kind and route, run once and thrown away | 20 |
| The two skill references, the changelog, the migration notes, the snapshot, and the ruling | 30 |
| Total | 200 |

The page you approved guessed 120, "the size of foundation pass 2". That guess didn't count the admin's addresses, the test records, or the build.

**How it fails.**

| Case | What happens |
| --- | --- |
| A kind has the value and the site has no route for it | The catch-all's loader throws one line that starts `cairn:`, names the address and the kind, and says to add the route or change the routing. A page that links to the event fails the build with that line. With no link, a visitor to the address gets a 500 and the line is in the log |
| The site's route is at a different address than `permalink` gives | Every page under that route answers 404, because the engine finds no entry at the address. The showcase build in the acceptance list proves a matching pair |
| The site's route names a kind that doesn't have the value | The new loader throws one line for the owner that names the kind and its routing |
| A visitor asks for an event that doesn't exist | 404 |
| A visitor asks for `/events/spring-regatta.md` | 404 |
| Two entries of different kinds resolve to one address | The engine's existing check refuses the build, and it now covers the new kind |
| A config names a routing value the engine doesn't have | The existing error line, which now lists four values |

The value adds no limit. One existing limit now counts event pages: a sitemap may list 50,000 addresses, and the engine refuses to build a longer one.

**The published surface.** A site developer writes one line in the kind's config:

```ts
routing: 'custom',
```

and one loader in the site's route file:

```ts
export const load = (event) => routes.conceptEntryLoad('events', event);
```

Four published types change, and the surface snapshot gains each:

| Type | Today | After the pass |
| --- | --- | --- |
| `ConceptConfig.routing` | `'dated' \| 'page' \| 'embedded'` | The fourth value joins the three |
| `RoutingRule` | `{ routable: boolean; dated: boolean }` | Gains `siteServed: boolean` |
| `PublicRoutes` | `entryLoad`, `entries`, `markdownEntries`, `markdownLoad` | Gains `conceptEntryLoad` |
| The two site resolvers | `byPermalink`, `paths`, `concept`, `all`, `routable` | Gain `siteServed(id)` |

The edit screen's data gains the entry's address. Routing is part of the adapter schema, the first item on the 1.0 readiness list in `ROADMAP.md`. A new value in the list breaks no config that exists.

## Acceptance

Each item names its check. "Today" is the check run once, at commit `a85986dbc` on `foundation-3`, with its output. The examples use `'custom'`, and the planner swaps in the name you pick.

1. `ConceptConfig.routing` accepts the fourth value. Today: `grep -n "routing?:" src/lib/content/types.ts` prints `123:  routing?: 'dated' | 'page' | 'embedded';`.
2. The surface snapshot shows the four changes in the table under "The published surface". Today: `grep -o 'routing?: [^;]*;' scripts/checks/api-surface.md` prints `routing?: "dated" | "page" | "embedded";`. A grep for ``RoutingRule` `` prints ``86:- `RoutingRule`: { routable: boolean; dated: boolean }``. `grep -rn conceptEntryLoad src/lib scripts/checks/api-surface.md` prints nothing.
3. A unit test gives the resolver a kind `events` with the value and one entry, `spring-regatta`. `byPermalink('/events/spring-regatta')` returns the entry, `paths()` leaves it out, and `siteServed('events')` is true. Today, under `embedded`: `paths()` is `["about"]` and `byPermalink` returns null.
4. With the same config, a `cairn:events/spring-regatta` link resolves to `/events/spring-regatta`, and the sitemap holds `https://example.org/events/spring-regatta`. Today, under `embedded`: the link throws `cairn: link target "cairn:events/spring-regatta" not found. Fix or remove the body link.`, and the sitemap holds only `https://example.org/about`.
5. `entries()` and `markdownEntries()` leave the event out. `entryLoad` at the event's address throws one line that starts `cairn:` and names the address, the kind, and the change to make. `markdownLoad` at `/events/spring-regatta.md` answers 404. Today, under `page`: `paths()` is `["about","events/spring-regatta"]`, so the catch-all builds the event page.
6. `conceptEntryLoad('events', event)` returns the entry's data at an event's address, answers 404 at `/events/no-such-event`, and throws a line for the owner when the kind it names has another routing value.
7. The editor's link picker lists the event, and the preview's link targets hold it. Today both lists keep only kinds whose `routable` is true, which leaves an `embedded` event out.
8. The menu editor's list of pages offers the event at `/events/spring-regatta`. Today: ``grep -nF 'url: `/${f.id}`' src/lib/sveltekit/nav-routes.ts`` prints line 70, which builds the address as a slash and the entry's id.
9. A component test shows `/events/spring-regatta` under "Address" on an event's edit screen and `/posts/<short name>` on a post's, and the rename dialog names the full new address. Today: ``grep -nF 'data.routable ? `/${data.slug}`' src/lib/admin/EditPage.svelte`` prints line 2534. This item falls away if you leave the short address.
10. One integration test builds one config with a kind under each of the four values and checks every reader in one place: the resolver, the catch-all's two lists, the sitemap, the link targets, the menu editor's list, and the admin's labels.
11. The showcase is built once with an events kind under the value and an `events/[slug]` route that calls the new loader. The build writes `events/spring-regatta.html` from the site's route, the sitemap holds its address, and no `.md` twin exists for it. With the route file removed and a link to the event on a page, the build fails with the owner's line. The changes are thrown away, and the pull request carries each command and its output. Today, with the kind under `page` and a filter in site code: the build wrote `examples/showcase/.svelte-kit/cloudflare/events/spring-regatta.html`, the sitemap held `<loc>https://showcase.test/events/spring-regatta</loc>`, and the count of event twins was 0.
12. Both skill references name the fourth value and show the route file. Today: `grep -n "embedded" skills/cairn-extending-a-site/references/content-model.md` prints one line, 64, on fragments.
13. `CHANGELOG.md` has the entry under `## Unreleased`. `MIGRATION-NOTES.md` says no site has to change. `docs/internal/engine-rulings.md` holds a ruling on what `routable` means and on the rule that the catch-all lists what it serves.
14. The pull request's opening follows `~/.claude/docs/voice/written-for-people.md`, and the two skill references follow the repo's docs rules.

## Changes to the designs you approved

Your approve covers each change in this section. I edit no file before it.

**Design minutes.** No pass of `site-events` or `site-basics` changes its minutes. The first `site-events` pass stays at 270, its round at 420, and its launch stop at 840, as the page you approved set them. The filter it loses carried no minutes, and the four acceptance items it gains are checks on a showcase it already builds. The contact-form pass keeps its figure. The foundation round's total changes only under the first placement, as that question says.

<details>
<summary>The events design, <code>specs/2026-11-14-events-design.md</code></summary>

Lines 139 to 141 read:

> The events kind uses `embedded` routing, so the engine's catch-all route and the sitemap leave it alone and the set's `/events/[slug]` route is the only page for an event. The admin then calls an event's identifier its name. Event pages are absent from the sitemap in this round.

They become:

> The events kind uses `custom` routing. The engine knows each event's address, lists it in the sitemap, and offers it to the link picker, to `cairn:` links, and to the menu editor. Its catch-all route leaves the page to the feature's `/events/[slug]` route, whose loader is `conceptEntryLoad('events', event)`. The admin calls an event's identifier its address. An event page has no markdown twin.

Line 485, "Event pages in the sitemap.", leaves the list of what is out of scope.

</details>

<details>
<summary>The round-two design, <code>specs/2026-11-15-round-two-design.md</code></summary>

**Lines 195 to 203, what a feature tells the site.** The sentence on `paths` opens:

> `paths` lists the addresses the feature serves itself,

That clause becomes:

> `paths` lists single addresses the feature serves itself that belong to a kind the catch-all serves, such as `/contact`,

The rest of the sentence stands, and one sentence follows it:

> A feature that serves every page of a kind sets that kind's routing to `custom` and needs no `paths` entry.

The sentence "`site-events-1` adds `homeSections`, `site-basics-2` adds `paths`, and `site-basics-3` adds `tagHref`." stands.

**Lines 229 to 231, an events link in the menu.** They read:

> The events layer adds no menu link. The organization set's primary menu holds one, and a developer who runs `cairn add events` on another kind is told the address to link.

One sentence is added:

> The menu editor's list of pages offers `/events` typed by hand and each event by name.

**Lines 241 to 243, the contact route.** They stand. `/contact` is named in `paths`.

**The `site-events-1` row, line 346.** The row stands, and its minutes are the 270 you approved on the later page.

**The `site-events-1` acceptance list, lines 400 to 432.** Four items join it:

> - The sitemap of the built showcase lists the address of each event entry.
> - The editor's link picker lists an event, and a `cairn:` link to an event in a page's body resolves in the built page.
> - The menu editor's list of pages offers an event at its full address.
> - The events kind's routing is `custom`, the feature holds no `paths` entry, and the base's catch-all route file holds no filter for events.

**The shared assumption at line 619.** It reads:

> The catch-all route can leave out a feature's address | `createPublicRoutes().entries()` returns every entry's path (`src/lib/delivery/public-routes.ts` line 253), and the route file calls it at line 10 | Unproven. The base's route file must filter by `paths` in site code

It becomes:

> The catch-all route can leave out one address of a kind it serves | `createPublicRoutes().entries()` returns the path of every entry the catch-all serves, and the route file calls it | Proven for a whole kind by the routing pass. Unproven for one address: the base's route file must filter by `paths` in site code, and `site-basics-2` proves it

Lines 623 to 627 stand. The filter they name is the one for `/contact`.

**Lines 656 to 657.** "`site-events` is 390 path minutes and stops new launches past 780." becomes "`site-events` is 420 path minutes and stops new launches past 840.", which records the page you approved today.

**The start line, lines 665 to 672.** "Lines 1, 2, and 4 aren't true today." becomes "Lines 1, 2, 4, and 5 aren't true today.", and a fifth line joins the four:

> 5. `git show origin/main:src/lib/content/types.ts` holds the routing value `'custom'`.

**Standing answer 15.** It stands, and it now covers the contact page's filter only.

**The correction of today's earlier page.** The page that listed corrections for the planners said: "Event pages collide with the catch-all route. The design builds the filter that prevents it in the `site-basics` round, after the event pages already exist. The filter moves to the first `site-events` pass." That correction is withdrawn. The engine prevents the collision, and the filter for `/contact` is built in `site-basics-2`, where the design first put it.

</details>

<details>
<summary>The prompts in <code>plans/</code></summary>

**`2026-11-15-site-events-1-planner-prompt.txt`.**

- Line 7: "Planned path: 240 minutes." becomes "Planned path: 270 minutes.", which records the page you approved today.
- Line 18 gains two sentences after "drop the other two.": "The events kind's routing is `custom`, where the events design says `embedded`. The event route's loader is `conceptEntryLoad('events', event)` from the object `createPublicRoutes` returns, and the feature writes no filter for the catch-all route and no `paths` entry."
- Line 22: "The design was read against `6499871a8`, before the Pennant and foundation rounds merged (standing answer 19)." gains "The routing design was read against `a85986dbc`."
- Line 24 stands. A task that needs a file under `src/lib/**` still parks the pass.
- The reading list gains `specs/2026-11-17-routing-design.md`, after the events design.

**`2026-11-15-site-events-conductor-prompt.txt`.**

- Line 11: the path minutes of pass 1 go from 240 to 270.
- Line 14: "The chain is 390 path minutes, and the round stops new launches past 780." becomes "The chain is 420 path minutes, and the round stops new launches past 840."
- Line 24 gains: "The routing value must be on `origin/main`, as line 5 of the start line says."

**`2026-11-15-site-basics-2-planner-prompt.txt`.** Line 18 stands. One sentence is clearer: "Today `createPublicRoutes().entries()` returns every entry's path" becomes "`createPublicRoutes().entries()` returns the path of every entry the catch-all serves, `/contact` among them".

**`2026-11-15-foundation-conductor-prompt.txt`**, under the first placement only. The order table gains a row, and the sentence after it changes:

> | 7 `routing` | plans/2026-11-17-foundation-7-planner-prompt.txt | none | 200 | no |

> Pass 7 runs next after the pass in flight when this row arrives, ahead of pass 4 while pass 4 is on hold. Its worktree is cut from `origin/main`. The chain is 960 path minutes, and the round stops new launches past 1,920.

Under the second placement that prompt changes in one place. Its round report names the routing pass's planner prompt as the next launch, and that pass's closing step names the `site-events` conductor prompt.

</details>

## Every place that reads the routing value

Twenty engine files read the value or the record it resolves to. This table says what each does with the new one.

<details>
<summary>The table</summary>

| Place | What it does today | Under the new value |
| --- | --- | --- |
| `content/types.ts`, the `routing` key and `RoutingRule` | Lists three values and two flags | Changes: a fourth value and a third flag |
| `content/concepts.ts`, the table of values | Builds each record | Changes: a fourth row, with an address, not dated, site-served |
| `content/concepts.ts`, the error for an unknown value | Lists three names | Changes: lists four |
| `content/concepts.ts`, the rule that fragments are `embedded` | Refuses any other value for fragments | No change |
| `content/identity.ts` | Reads `dated` to cut a date from the short name | No change. An event's file has no date prefix |
| `content/advisories.ts` | Warns when two entries hold one address | No change in code. The warning now covers events |
| `delivery/content-index.ts` | Sorts dated kinds by date and the rest by title | No change |
| `delivery/site-resolver.ts`, the address index | Holds every kind that has an address | No change in code. Events join it, and so does the check for two entries at one address |
| `delivery/site-resolver.ts`, `paths()` | Lists every address in the index | Changes: lists the pages the catch-all serves |
| `delivery/site-resolver.ts`, `all()` and `routable(id)` | Answer for kinds with an address | No change in code. Events are included. `siteServed(id)` is new |
| `delivery/site-resolver.ts`, the `cairn:` link resolver | Resolves a link to a kind with an address | No change in code. A link to an event resolves |
| `delivery/views.ts`, the sitemap | Lists every kind with an address | No change in code. Events are listed |
| `delivery/public-routes.ts` | Lists and serves every address | Changes, as "Method calls" says |
| `sveltekit/content-routes-entry-read.ts`, the link picker's targets | Keeps kinds with an address | No change in code. Events are offered |
| `sveltekit/preview.ts`, the preview's link targets | The same filter | No change, and the file isn't touched |
| `sveltekit/content-routes-entry-read.ts`, the edit screen's data | Sends `routable` and the short name | Changes: sends the entry's address too |
| `sveltekit/content-routes-list.ts` and `content-routes-shared.ts` | Choose "address" or "name" in labels and error lines | No change in code. Events read "address" |
| `sveltekit/content-routes-entry-destructive.ts` and the create action | Read `dated` for the date in a name | No change |
| `sveltekit/nav-routes.ts`, the menu editor's list of pages | Lists kinds with an address that aren't dated, each at a slash and its id | Changes: each at its real address. Events are listed |
| `admin/EditPage.svelte` and `admin/RenameDialog.svelte` | Print the short address | Change, if you pick the full address |
| `admin/ConceptList.svelte` | Labels the field in the create dialog | No change in code. It reads "Address" |
| `reproductions/**` | Hand-built records for stories | Change: each gains the flag |

</details>

## What I ran

The survey and the page you approved read the code and ran nothing. I cloned the repo and ran these at `a85986dbc`.

- **A unit probe of the two values that exist.** Under `embedded`, an event is absent from the catch-all's list, from `byPermalink`, and from the sitemap, and a `cairn:` link to it throws. Under `page`, all four work and the catch-all also builds the event's page. Acceptance items 3 to 5 carry the output. Both pages' claims about `embedded` hold.
- **A build of the showcase** with an events kind, a filter in site code, and `events/[slug]` beside the catch-all route. SvelteKit sent the event's address to the site's route, and the build wrote the page once. The SvelteKit docs give the rule: a route with one parameter sorts ahead of a rest route, and a rest parameter has the lowest priority.
- **The acceptance checks**, each once, as the list shows.
- **The scoped backlog sweep**, by a fresh reader, as the section below says.

I couldn't run the value itself, because the pass hasn't built it. The showcase build stands in for it, with `page` and a filter doing by hand what the value does by rule. I didn't confirm what the preview or the draft switch show for an event. That stays with the first `site-events` pass.

## Start line

The pass launches when each of these reads true. The placement you pick settles which list applies.

As the foundation round's seventh pass:

1. This document is answered "approve". Not true today.
2. `plans/2026-11-17-foundation-7-planner-prompt.txt` is committed in the initiative record. Not true today. I write it on approve, and the conductor commits it.
3. The conductor's checks before each launch pass, as its prompt and `round-run.md` list them. `claude agents --json` shows no executor of the round at work. The conductor reads this on the day. It isn't true today, because pass 3 is running.

As a round of one pass:

1. This document is answered "approve". Not true today.
2. `docs/STATUS.md` on `origin/main` holds a line that reports the foundation round closed. Not true today.
3. `claude agents --json` holds no row named `conductor-foundation` or `cairn-cms-foundation-*`. Not true today.
4. The planner's launch checks in `planner.md` pass that day.

Against the other rounds in the repo, the order is the foundation round, this pass, `site-events`, and `site-basics`. The structure round comes after this pass.

<details>
<summary>The launch checks, run when I sent this</summary>

| Check | Command | Result |
| --- | --- | --- |
| Weekly usage | `claude -p "/usage" --model haiku < /dev/null` | `Current week (all models): 47% used · resets Nov 20, 10:59pm (America/Anchorage)`, read at 08:03 UTC on November 17 |
| Live sessions | `claude agents --json` | `conductor-foundation` busy, `cairn-cms-foundation-3` busy in its worktree, `cairn-cms-foundation-3-plan` idle. `cairn-structure-design` and `cairn-layering-design` are designing sessions and hold no worktree |
| Open pull requests | `gh pr list -R glw907/cairn-cms` | One, a draft: the site record, pass 3 of the foundation round |
| Launch flags | `claude --help` | Lists `--bg`, `--model`, `--effort`, and `--name`, and no `--advisor`, which is accepted all the same: the foundation round's planners launched with the same line. Version `2.1.326` |
| The main checkout | not run | My rules keep me out of that checkout while the round is live. The conductor runs the check before its launch, or the planner does in a round of one |

The planner's launch line is `claude --bg --model claude-opus-5-5 --effort high --advisor fable --name <session> "$(cat <prompt>)"`. The session is `cairn-cms-foundation-7-plan` in the round, or `cairn-cms-routing-plan` in a round of one.

</details>

## Standing answers

The twelve in `round-run.md` apply, and the eight the foundation design adds when the pass runs in that round. This design adds five.

1. The plan comes out over the ceiling you pick under "The limits". The pass parks, and you get one `decide` document.
2. The build in acceptance item 11 shows SvelteKit sending an event's address to the catch-all route. The pass parks. The design rests on that rule, and my build and the SvelteKit docs both show it.
3. A task needs `src/lib/sveltekit/preview.ts` or another `auth-data` file changed. The pass parks, and its class isn't raised without your ruling.
4. The record's new field breaks a published type some other package reads. The planner flags it, and the changelog entry gains a `Consumers must:` line. I found no such reader.
5. A name in this design breaks an engine naming ruling. The planner picks the name the ruling gives and flags the change. The value's name is yours and doesn't change.

No step in the pass is one only you can do. The pass needs no secret, no sign-in, and no setting changed.

## Backlog verdicts

A fresh reader swept the backlog at `a85986dbc` for items that name a file this pass changes. Of 171 open items, 41 are in scope. All 41 are `keep`, and none folds into the pass.

<details>
<summary>The 41 items</summary>

#298, #378, #410, #412, #413, #415, #416, #417, #419, #480, #481, #482, #483, #484, #485, #487, #488, #490, #495, #496, #497, #498, #499, #500, #501, #502, #539, #541, #542, #543, #544, #545, #546, #547, #548, #549, #550, #552, #553, #554, #555, #556, and #557. Each is real and none lives in lines the pass rewrites. No item covers the short address on the edit screen or the menu editor's list, so if you leave the short address, the pass files one.

</details>

## Later

- A site-served value for dated content, when a feature needs one.
- A markdown twin for a site-served page, as a route the feature writes.
- A check that a site has a route for each kind under the value, in `cairn doctor`. Today the missing route shows at build or at the first visit.
- Backlog #496, the home-page check copied into five route files.

## Where I differ from the page you approved

- It priced the pass at about 120 design minutes. I price it at 200, for the reasons under "Design minutes".
- It said the value replaces the `paths` key. It replaces it for events and not for `/contact`.
- It didn't say an event loses its markdown twin, or that the menu editor and the edit screen print a wrong address for any kind but pages.

## What I read

`cairn-cms` at `a85986dbc` on `foundation-3` and at `604b4596d` on `main`, fetched just before I sent this. The SvelteKit docs on advanced routing, under "Sorting" and "Matching", and on the build option `handleEntryGeneratorMismatch`. The three approved designs in `theme-garden/specs/`, the prompts in `theme-garden/plans/`, the survey at `~/.local/state/desk/reviews/2026-11-17-cairn-architecture-survey.md`, and the queue pages on the feature contract, on the hold on pass 4, and on the seventh foundation pass you sent back. This design is kept, uncommitted, at `~/Projects/initiatives/theme-garden/specs/2026-11-17-routing-design.md`.

## Rulings

Geoff approved this design in queue document `20261117-080523-be1fbe`, 2026-11-17. Each `Ruled:`
line quotes his answer there.

1. The name of the value.
   Ruled: "'custom'".
2. The address an editor sees.
   Ruled: "Show the full address for every kind". Acceptance item 9 stands, and the pass is 200
   design minutes.
3. Where the pass runs.
   Ruled: "Join the foundation round as its seventh pass". The pass is `foundation-7`, and the
   first list under "Start line" applies.
4. The limits.
   Ruled: "The standard limits". A plan over 400 path minutes parks, and the usage stop is the
   foundation round's.

Two facts changed between the day this design was sent and the day it was approved. Pass 3 of
the foundation round became `auth-data` and waits for the round's `merge` document, so the land
test in `round-run.md` now holds this pass for that document too, where "Where the pass runs"
says it lands with no document. Pass 3's branch moved from `a85986dbc` to `389df42fc`, a change
to two pages under `docs/admin/` only. The desk has both facts.
