# Pass foundation-7: routing

Initiative: theme-garden
Round: foundation
Pass: 7 of 7, `foundation-7` (routing), class `ordinary`, base `79d326bed`, branch `foundation-7`

Design: `~/Projects/initiatives/theme-garden/specs/2026-11-17-routing-design.md` ("Method calls
you can skip", "The pass", "Acceptance", "Every place that reads the routing value", "Standing
answers", "Rulings"). Approved by Geoff in queue document `20261117-080523-be1fbe` (2026-11-17).
Where a section describes an option he didn't pick, the section's `Ruled:` line wins: the value is
`'custom'`, the admin shows the full address for every kind, and the pass is the foundation
round's seventh. Earlier passes in this round: pass 1 (PR #256), pass 2 (PR #257), and pass 3
(PR #258, merged as `79d326bed`). None of their bodies carries an `[advisor]` line this pass
builds on.

Outcome: A kind can take a fourth routing value, `'custom'`, for content whose pages a site's code
serves. The engine resolves each address and lists it in the sitemap. It offers the address to the
link picker, to `cairn:` links, and to the menu editor, and it leaves the page to the site's route.
The admin shows the full address of an entry of any kind.

Planned path: 255 minutes against the design's 200 (parking ceiling 400, the design's "The
limits"). See "Path".

Scope premise (`cairn-judging-scope`): the value serves a site that writes its own route for a
kind, which is the developer's job the scope charter names, and the engine adds only the seam:
one routing value, one resolved flag, one resolver method, and one loader. The address pattern is
the `permalink` key every kind already has, so no second key does the same work. The admin change
fixes an address the screen prints wrong today for every kind but pages. It adds no actor, no
subsystem, and no option. `grep -n "^## " docs/internal/engine-rulings.md | grep -i "routing\|routable\|catch-all"`
prints nothing at the base, so no ruling stands in the way, and Task 8 adds the one the design
asks for. The premise holds.

## Pre-flight

Permissions checked: read `~/.local/state/claude-denials.jsonl` on 2026-11-17. The log holds 123
rows, from 2026-11-01T00:55:05Z to 2026-11-17T17:41:25Z, all inside the 30-day window, 46 of them
naming cairn-cms. Nine rows are new since foundation-3's plan. Three touch this pass's commands: two
`git stash drop stash@{0}` refusals in cairn-cms worktrees (2026-11-17, Destructive or Unwanted
Actions), and a `git commit -qam` chained after `pgrep` in the main checkout (2026-11-17, the same
class). The rest are other repos or "Classifier unavailable". Rows that touch this pass, with the
form to use instead:

| Refused form (date, class) | This pass uses |
| --- | --- |
| The setup command piped to `tail` and chained with `ls` (2026-11-14, Destructive or Unwanted Actions) | The setup command alone and bare: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync)` |
| `pkill -f 'lane:fast'`, `kill <pid>` of test runs (Interfere With Workloads, 2026-11-01 and 2026-11-15) | Never kill a process. A server a script starts is stopped by that script, or by `TaskStop` |
| `git stash drop stash@{0}` (2026-11-17, twice) | No stash at all. Task 4's throwaway edits are undone by `git restore examples/showcase` and an `rm` of each file it named |
| `git commit -qam` chained after `pgrep` (2026-11-17) | `git add <named files>` then `git commit -m`, each alone; never `-a` |
| `rm` of a path the classifier can't bound (Unverifiable Deletion Scope, 2026-11-03) | `rm` names each file Task 4 created, by its full relative path, never a glob or a folder; `rm -rf` only for the showcase `node_modules` and lockfile the durable gotcha names |
| `claude stop` chained with other commands (2026-11-10, 2026-11-13, 2026-11-16) | `claude stop <id>` alone, only for a job this session launched |
| `git push origin HEAD:main` (Modify Shared Resources) | Push only `foundation-7`: `git push -u origin foundation-7` |
| `git push origin --delete <branch>`, `git reset --hard` in a shared checkout (Git Destructive) | No remote branch is deleted, and no `git reset --hard`. Set work aside with a WIP commit |
| `gh pr merge` chained with `gh pr view` (Merge Without Review) | Never `gh pr merge`. `conductor-foundation` lands the PR |
| Edits to `settings.json` (Self-Modification) | The pass writes no Claude settings file |
| Classifier unavailable (transient) | Retry the same command once, bare and alone |

Reviewed: the class is `ordinary`, which `pass-core` "Plan review lens" gives no plan read. The
assignment says to write and review, so the plan had one `standards:plan-reviewer` read on
2026-11-17 (Opus, medium). See "Review folded". The close runs one whole-branch
`standards:diff-reviewer` (Task 10).

Evidence: the mechanism table and the recorded searches below.

Geoff steps: none. The pass needs no credential, no secret, no sign-in, and no permission rule.
Values the run needs: none from any store. Writes read against auto mode: files in the pass
worktree, commits and a push to `foundation-7`, and one draft PR. Task 4 writes files under
`examples/showcase/` and undoes them before its commit. No write to Claude's settings or a
credential file, and no publish, deploy, version bump, or workflow dispatch. The launch runs from
the main checkout, which sessions have opened before, so no workspace trust prompt.

## Mechanism table

Read at `79d326bed`.

| Mechanism | Probe or source | Result |
| --- | --- | --- |
| The routing value | `src/lib/content/types.ts:123` `routing?: 'dated' \| 'page' \| 'embedded';`. `RoutingRule` at `:368-373`: `routable` ("Routable as a standalone URL: the entries get a public page and a sitemap entry. An embedded concept is not.") and `dated` | The union gains `'custom'`. `RoutingRule` gains `siteServed: boolean`. The `routable` comment says it means "has an address", and `siteServed` says "the catch-all route serves it" (Task 1) |
| The table of values | `src/lib/content/concepts.ts:38-41` `ROUTING_SHORTHANDS` typed `Record<'dated' \| 'page' \| 'embedded', RoutingRule>`; `:59` defaults to `page`; `:61` throws ``cairn: concept "${id}" routing "${routing}" must be one of dated, page, embedded``; `:232-234` the rule that fragments are `embedded` | The table gains `custom: { routable: true, dated: false, siteServed: false }`, and the other three rows gain `siteServed: true` for `dated` and `page` and `false` for `embedded`. The error line lists four values. The fragments rule doesn't change |
| Which rows are site-served | The design's prompt reads "the shorthand table gains `{ routable: true, dated: false, siteServed: true }`" | `siteServed` there names the custom row, and the flag's meaning is "a site's own route serves it". The executor names the flag `siteServed` and sets it `true` for `custom` only, `false` for the three others. The prompt's row is the custom row (Decisions 1) |
| The address of an entry | `src/lib/content/url-policy.ts` `resolvePermalink(descriptor, { id, slug, date? })` replaces `:slug`, `:year`, `:month`, and `:day`, and throws on a missing date or an unknown token. `src/lib/content/identity.ts:50-59` `entryIdentity(descriptor, path, frontmatter)` returns `{ id, slug, date, permalink }` and throws on a malformed date | The edit screen's address and the menu list's address both come from `resolvePermalink`, the one rule the public site already uses |
| The resolver | `src/lib/delivery/site-resolver.ts:28-47` `UntypedSiteResolver` (`byPermalink`, `paths`, `concept`, `all`, `routable`); `:55` `TypedSiteResolver<A> extends Omit<UntypedSiteResolver, 'concept'>`; `buildSiteResolver` at `:98-145`, with `paths()` at `:129` listing every key of `byPath`; `routable(id)` at `:141` reads `true` for an unknown id | `UntypedSiteResolver` gains `siteServed(id: string): boolean`, which `TypedSiteResolver` inherits, so one member covers "both resolvers". `buildSiteResolver` keeps every routable entry in `byPath` and filters site-served kinds out of `paths()` only. `siteServed` reads `false` for an unknown id, since no route serves a kind the config doesn't declare (Decisions 2) |
| The public routes | `src/lib/delivery/public-routes.ts:243` `entryLoad` (404 on a `byPermalink` miss); `:253` `entries()` returns `site.paths()`; `:268` `markdownEntries` derives from `entries()`; `:288` `markdownLoad` (404 on a miss or `noindex`); `:297` returns four functions; interface at `:313-317` | `entries()` and `markdownEntries()` drop the event through `paths()` with no code of their own. `entryLoad` throws a plain `Error` for a site-served entry. `markdownLoad` answers 404 for one. `conceptEntryLoad(concept, { url })` is the fifth function (Task 3) |
| A plain `Error` at build | `examples/showcase/vite.config.ts:52-78`, the prerender block: `handleHttpError: ({ message }) => { throw new Error(message); }`, and `handleUnseenRoutes` allows only `/(site)/archive/[page]`. The Kit config moved here in commit `0a5a68833`; `svelte.config.js` no longer exists | A page that links to a site-served event while no route serves it makes the prerenderer request the address through the catch-all, whose `entryLoad` throws. The build fails, and Task 4 confirms the owner's line is in its output (Decisions 9) |
| Route order | The design's build at `a85986dbc` and the SvelteKit docs ("Advanced routing", "Sorting"): a route with one parameter sorts ahead of a rest route | `events/[slug]` wins over `[...path]` for `/events/spring-regatta`. Task 4 proves it; if SvelteKit sends the address to the catch-all, the pass parks (standing answer 2) |
| The preview | `src/lib/sveltekit/preview.ts:38` imports the `SiteResolver` type; `:269` filters link targets by `routing.routable` | A new interface member breaks no code there, and `custom` is routable, so the preview's link targets hold the event with no change to the file (item 7) |
| The link picker | `src/lib/sveltekit/content-routes-entry-read.ts`, the link targets filter on `routing.routable` | No change in code; events are offered (item 7) |
| The edit screen's data | `content-routes-entry-read.ts:76` `slug: string`; `:97` `routable: boolean`; the advisory block at about `:410-433` calls `entryIdentity` inside a try, only when `manifest !== null`; the return at about `:470` sets `slug: slugFromId(id, datePrefix)` and `routable: concept.routing.routable` | `EditData` gains `permalink: string \| null`, from its own `entryIdentity` call in a try, independent of the manifest. It's `null` for a kind that isn't routable or when the identity throws (Task 5) |
| The edit screen | `src/lib/admin/EditPage.svelte:1338` the rename flash ``The address is now ${data.slug}.``; `:2532` the legend; `:2534` ``data.routable ? `/${data.slug}` : data.slug``; `:2735-2742` `<RenameDialog ... slug={data.slug} routable={data.routable} />` | `:2534` prints `data.permalink ?? (data.routable ? `/${data.slug}` : data.slug)`. The flash prints `data.permalink ?? data.slug`. The dialog gets `permalink={data.permalink}` |
| The rename dialog | `src/lib/admin/RenameDialog.svelte` props `conceptId`, `id`, `singular`, `slug`, `routable = true`, `trigger`, `onsubmitting`; about `:100-101` "The new address will be `<code>{nextSlug}</code>`." | A `permalink: string \| null` prop. With a permalink that ends in `/${slug}`, the dialog shows it with that last segment swapped for `nextSlug`; otherwise it shows `nextSlug` as today. A `// WATCH:` comment names the limit (Decisions 4) |
| Permalink patterns in the repo | `git grep -n "permalink:" -- src examples templates themes sets` | Only `/posts/:slug` (the reproduction fixture) and the default patterns (`/<id>/:slug`, and `/:slug` for pages). Every pattern ends in `:slug`, and a rename changes only the slug |
| The menu list | `src/lib/sveltekit/nav-routes.ts:63-77` `pageOptions` keeps `routing.routable && !routing.dated` and builds each address at `:70` as ``url: `/${f.id}` `` inside a per-concept try that returns `[]` | `:70` becomes `url: resolvePermalink(c, { id: f.id, slug: f.id })`. Events join because `custom` is routable and not dated. A throw stays inside the per-concept try. For pages (`/:slug`) the address is unchanged, so `/admin/nav` shows the same list (Task 6) |
| Reproduction fixtures | `src/lib/reproductions/fixtures.ts:36-37` `routing: { routable: true, dated: true }`, `permalink: '/posts/:slug'`; `stories/support.ts` `editPageProps` at about `:170-200` sets `slug` and `routable: true` (`:186`, `:228`) | Each `RoutingRule` literal gains `siteServed: false`. `editPageProps` gains `permalink: `/posts/${slug}``. The `editor/details-panel` story feeds the live figure at `docs/editors/write-in-the-editor.md:261-265`; its caption and the table row at `:273` stay true |
| Hand-built routing records | `git grep -c "routable: \(true\|false\), dated:" -- src` counts 54 lines in 33 files (the design counted 57 in 35 at `a85986dbc`) | Every literal gains the flag. `npm run check` is the true list (Decisions 6) |
| Hand-built edit data | `git grep -c "fragmentTargets:" -- src/tests src/lib/reproductions` counts 24 lines in 16 files, 9 in `EditPage.test.ts` | Each `EditData` literal gains `permalink`. Some hits may be another shape; `npm run check` is the true list |
| Admin visual baselines | `examples/showcase/e2e/admin-visual.spec.ts:120-175` shoot `/admin/posts/2026-06-hello` with Details closed; the `EIGHT_SCREENS` `edit-page` entry (`:590-640`) has no step that opens it. `EditPage.svelte:1087` `detailsOpen = $state(false)` | No baseline shows the address, so none should change. CI confirms; the pass regenerates no baseline |
| The parity harness | foundation-2's Task 0 (`git show f9a53ba30^:docs/internal/plans/2026-11-16-foundation-2-menus-plan.md`, "Task 0"): `serve.mjs`, `pages.txt`, `shoot.mjs`, `compare.mjs`, `hash.mjs`, `shoot-admin.mjs` | Reused, with `shoot-admin.mjs` shooting three edit-screen states (Task 0) |
| The engine a showcase build sees | `cairn-writing-engine-code` `references/durable-gotchas.md:115-130`: a worktree's `examples/showcase/node_modules` can link to the main checkout's engine | Tasks 0, 4, and 9 run `npm run package` and `readlink -f examples/showcase/node_modules/@glw907/cairn-cms`, which must resolve inside the worktree; otherwise the gotcha's reinstall runs |
| The surface snapshot | `scripts/checks/api-surface.md:86` ``- `RoutingRule`: { routable: boolean; dated: boolean }``; `grep -rn conceptEntryLoad src/lib scripts/checks/api-surface.md` prints nothing | `npm run check:surface -- --update` rewrites the file. The pass edits no check script |
| Backlog stamps | `grep -c "(swept 2026-11-17)" BACKLOG.md` prints `0`; 211 lines carry a `swept` stamp, one per line | Task 8 stamps the 43 listed ids on their item lines (Decisions 7) |

### Recorded searches

| Search at `79d326bed` | Hits | Use |
| --- | --- | --- |
| `grep -rn -i "embedded'\|'embedded\|routing:\|routing value\|'dated'\|Change address\|new address will be" docs/admin docs/editors docs/why-cairn.md skills/` | 7 | Only `skills/cairn-extending-a-site/references/content-model.md:64` and `:124-127` change. The editor pages stay true; `docs/editors/when-something-goes-wrong.md:58` already shows `/posts/hello` |
| `grep -rn -i "routing\|catch-all\|entryLoad\|markdownEntries\|createPublicRoutes" docs/admin docs/why-cairn.md` | 3, all in `tripwire.md` | Unrelated; no admin page changes |
| `grep -rn -i "address" docs/editors/*.md`, read hit by hit | media and editor pages | None changes: each names the address in words, and the one shown address is a post's full address |
| `git grep -n "entryLoad\|markdownLoad\|createPublicRoutes" -- skills` | `public-routes.md` | Gains the custom route file, the `conceptEntryLoad` section, the twin note, and a "Build failures" row (Task 8) |
| `grep -n "^## " docs/internal/engine-rulings.md \| grep -i "routing\|routable\|catch-all"` | 0 | No ruling to read; Task 8 adds one |
| `git grep -ln "SiteResolver" -- src/tests` | 20 files | Type-only users; a hand-built resolver double that fails to compile gains `siteServed` |

## Rulings and standing answers

The twelve standing answers in `round-run.md` hold, with the foundation design's 13 to 20 and this
design's 1 to 5. The ones this pass can meet:

- Design 1: the plan comes out over 400 path minutes. It parks. 255 planned.
- Design 2: Task 4 shows SvelteKit sending an event's address to the catch-all. The pass parks.
- Design 3: a task needs `src/lib/sveltekit/preview.ts` or another `auth-data` file changed. The
  pass parks. The mechanism table shows `preview.ts` needs no change.
- Design 4: the flag breaks a published type another package reads. The changelog gains a
  `Consumers must:` line, and the PR flags it. The design found no such reader, and Task 8
  re-checks with `npm run check:surface`.
- Design 5: a name breaks an engine naming ruling. The ruling's name wins, flagged, except
  `'custom'`, which never changes.
- 14: a needed `src/lib/**` file outside the row parks the pass. The row is `src/lib/content/**`,
  `src/lib/delivery/**`, `src/lib/sveltekit/**` (never `preview.ts`), `src/lib/admin/**`, and
  `src/lib/reproductions/**`.
- 15: a pixel or public-output difference is fixed at its cause, never by a new baseline. The
  showcase has no custom kind, so its public output can't move.
- 18: plan against the files as merged. Done at `79d326bed`, main after PR #258.
- 19: a needed change under `.github/**`, `scripts/release/**`, or `.claude/settings*` is left
  alone and recorded for the round's `merge` document. See "Held paths".

The run's ceilings are the round's: the chain is 960 path minutes, the round stops new launches
past 1,920, and the usage stop is 85 percent of the weekly allowance. Retries go on while each
fixes a traced cause, as `planner.md` "Stops" says. Past the 255-minute plan the run goes on: the
ceiling parks a plan, never a run in progress.

The class is `ordinary`. Whether the PR lands or joins the round's `merge` packet is
`conductor-foundation`'s reading of the land test in `round-run.md`. Every other stop goes
through `advisor.md`. The ones foreseen:

| Stop | Answer |
| --- | --- |
| A task needs a `src/lib/**` file outside the row | Park the pass (standing answer 14). Write `## Stop` to STATUS on the branch and end |
| A task needs `preview.ts` or an `auth-data` path | Park the pass (design standing answer 3) |
| Task 4's build writes the event page from the catch-all, or writes no page | Park the pass (design standing answer 2) |
| Task 4's route-removed build fails with no `cairn:` line in its output | Amend item 11's evidence with the output, flag it in the PR (standing answer 12), and go on |
| The showcase's public output differs from the base | Trace it to its cause and fix it (standing answer 15) |
| A visual baseline fails in CI | The same; never regenerate a baseline in this pass |
| A CI job this pass didn't touch fails | Re-run once; a repeat goes to the advisor, and a real regression is fixed at cause |
| The whole-branch review asks for work outside the row | `standards:log-issue`, listed in the PR body |
| A theme or set file would change | Stop that edit. The pass changes nothing under `themes/` or `sets/<kind>/` |

## Acceptance

Every pass:

- CI is green on the head commit, and the whole-branch review is accepted with no open finding.
  - Task 10: `ci-green <sha> --pr <n> --wait` exit 0 on the head commit, and the
    `standards:diff-reviewer` whole-branch verdict `accept`, quoted in the PR.
- The built showcase, the Waymark demo, and the Pennant demo show no visitor-visible change. A
  fresh `standards:visual-verifier` compares each of the home page, a post, a plain page, and the
  archive at the five widths with the same page built from the pass's base commit, and returns no
  difference.
  - Tasks 0 and 9: 60 base/head screenshot pairs, the pixel compare's count, and the three
    verifiers' verdicts quoted in the PR.
- The showcase's built public output (every prerendered page, the feeds, the sitemap, and
  `robots.txt`) equals the base commit's, file for file, once hashed asset names are replaced
  with a fixed token. The PR lists any file that differs, with the reason.
  - Tasks 0 and 9: the normalized hash list diff, pasted in the PR.

Pass 7, copied from the design:

1. `ConceptConfig.routing` accepts the fourth value. Today: `grep -n "routing?:" src/lib/content/types.ts` prints `123:  routing?: 'dated' | 'page' | 'embedded';`.
   - Task 1: the same grep at the head prints `'dated' | 'page' | 'embedded' | 'custom'`, pasted
     in the PR; a `content-concepts.test.ts` case resolves `routing: 'custom'` to
     `{ routable: true, dated: false, siteServed: true }` and the unknown-value case's line lists
     four values.
2. The surface snapshot shows the four changes in the table under "The published surface". Today: `grep -o 'routing?: [^;]*;' scripts/checks/api-surface.md` prints `routing?: "dated" | "page" | "embedded";`. A grep for ``RoutingRule` `` prints ``86:- `RoutingRule`: { routable: boolean; dated: boolean }``. `grep -rn conceptEntryLoad src/lib scripts/checks/api-surface.md` prints nothing.
   - Task 8: after `npm run check:surface -- --update`, the three greps at the head, pasted in the
     PR: the union with `"custom"`, `RoutingRule` with `siteServed: boolean`, and
     `conceptEntryLoad` in `public-routes.ts` and the snapshot, with `siteServed` on the resolver.
     `npm run check:surface` exits 0.
3. A unit test gives the resolver a kind `events` with the value and one entry, `spring-regatta`. `byPermalink('/events/spring-regatta')` returns the entry, `paths()` leaves it out, and `siteServed('events')` is true. Today, under `embedded`: `paths()` is `["about"]` and `byPermalink` returns null.
   - Task 2: a `delivery-site-resolver.test.ts` case with exactly that config and those three
     assertions, plus `siteServed('pages')` false and `siteServed('nope')` false.
4. With the same config, a `cairn:events/spring-regatta` link resolves to `/events/spring-regatta`, and the sitemap holds `https://example.org/events/spring-regatta`. Today, under `embedded`: the link throws `cairn: link target "cairn:events/spring-regatta" not found. Fix or remove the body link.`, and the sitemap holds only `https://example.org/about`.
   - Task 3: a `resolve-links.test.ts` case and a `delivery-sitemap.test.ts` case over the same
     config.
5. `entries()` and `markdownEntries()` leave the event out. `entryLoad` at the event's address throws one line that starts `cairn:` and names the address, the kind, and the change to make. `markdownLoad` at `/events/spring-regatta.md` answers 404. Today, under `page`: `paths()` is `["about","events/spring-regatta"]`, so the catch-all builds the event page.
   - Task 3: `public-routes.test.ts` and `public-routes-markdown.test.ts` cases; the thrown value
     is an `Error` (not an `HttpError`) whose message matches the line in Task 3.
6. `conceptEntryLoad('events', event)` returns the entry's data at an event's address, answers 404 at `/events/no-such-event`, and throws a line for the owner when the kind it names has another routing value.
   - Task 3: three `public-routes.test.ts` cases, plus a fourth for a `pages` entry's address
     asked through `conceptEntryLoad('events', …)`, which answers 404.
7. The editor's link picker lists the event, and the preview's link targets hold it. Today both lists keep only kinds whose `routable` is true, which leaves an `embedded` event out.
   - Task 7: the integration test asserts the event in `EditData.linkTargets` from the entry read,
     and in the preview's link targets through `loadPreview`, with `preview.ts` unchanged.
8. The menu editor's list of pages offers the event at `/events/spring-regatta`. Today: ``grep -nF 'url: `/${f.id}`' src/lib/sveltekit/nav-routes.ts`` prints line 70, which builds the address as a slash and the entry's id.
   - Task 6: a `nav-routes-load.test.ts` case asserts `{ label: 'spring-regatta', url: '/events/spring-regatta' }`
     beside `{ label: 'about', url: '/about' }`; the grep at the head prints nothing, pasted in the PR.
9. A component test shows `/events/spring-regatta` under "Address" on an event's edit screen and `/posts/<short name>` on a post's, and the rename dialog names the full new address. Today: ``grep -nF 'data.routable ? `/${data.slug}`' src/lib/admin/EditPage.svelte`` prints line 2534. This item falls away if you leave the short address.
   - Task 5: `EditPage.test.ts` cases for the event and the post, and a `RenameDialog.test.ts`
     case typing a new short name and finding the full new address; Task 9's admin shots, graded
     by a fresh `standards:visual-verifier`.
10. One integration test builds one config with a kind under each of the four values and checks every reader in one place: the resolver, the catch-all's two lists, the sitemap, the link targets, the menu editor's list, and the admin's labels.
    - Task 7: `src/tests/integration/routing-values.test.ts`.
11. The showcase is built once with an events kind under the value and an `events/[slug]` route that calls the new loader. The build writes `events/spring-regatta.html` from the site's route, the sitemap holds its address, and no `.md` twin exists for it. With the route file removed and a link to the event on a page, the build fails with the owner's line. The changes are thrown away, and the pull request carries each command and its output. Today, with the kind under `page` and a filter in site code: the build wrote `examples/showcase/.svelte-kit/cloudflare/events/spring-regatta.html`, the sitemap held `<loc>https://showcase.test/events/spring-regatta</loc>`, and the count of event twins was 0.
    - Task 4: each command and its output in the PR, and `git status --porcelain examples/showcase`
      empty after the revert.
12. Both skill references name the fourth value and show the route file. Today: `grep -n "embedded" skills/cairn-extending-a-site/references/content-model.md` prints one line, 64, on fragments.
    - Task 8: `grep -n "custom" skills/cairn-extending-a-site/references/content-model.md skills/cairn-extending-a-site/references/public-routes.md`
      pasted in the PR, with the route file shown in both.
13. `CHANGELOG.md` has the entry under `## Unreleased`. `MIGRATION-NOTES.md` says no site has to change. `docs/internal/engine-rulings.md` holds a ruling on what `routable` means and on the rule that the catch-all lists what it serves.
    - Task 8: the three edits; `grep -n "^## scope-verdict-routing" docs/internal/engine-rulings.md` prints one line.
14. The pull request's opening follows `~/.claude/docs/voice/written-for-people.md`, and the two skill references follow the repo's docs rules.
    - Tasks 8 and 11: the skill pages pass `npm run check:docs-gate` and the save hooks; the PR
      opening is drafted against the guide's steps 1 to 3.

## Skills the executor loads

`cairn-pass`, `pass-core` (`references/executor.md`, `references/round-run.md`,
`references/advisor.md`), `cairn-running-passes`, `cairn-judging-scope`,
`cairn-writing-engine-code`, `standards:ts-conventions` (comments in `.ts`),
`standards:svelte-conventions` (Task 5's components), `cairn-following-admin-design` (Task 5),
and `cairn-writing-docs` (Task 8's skill references follow its register). Voice:
`~/.claude/docs/voice/written-for-people.md` for the PR opening.

## Tasks

The worktree is `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/foundation-7`. After each
task, run the fast lane: the legs `node scripts/checks/gate-tier.mjs --fast --range 79d326bed..HEAD`
prints, each through `cairn-run-gate` with `CAIRN_GATE_LANE=<lane>` lifted onto the call.

Order: Task 0, then Task 1. Tasks 2 and 5 run as a pair once Task 1 lands, then Tasks 3 and 6.
Task 4 runs alone once Task 3 lands, since it needs the loader and can park the pass. Tasks 7 and
8 run as a pair, then Tasks 9, 10, and 11. Tasks 0, 4, 9, 10, and 11 are the executor's own. Each
pair task goes to a `cairn-implementer` (Sonnet, medium) in its own worktree, which pays its own
setup. At each join the executor merges the first task, then the second, and runs the fast lane on
the joined branch before the next step. Push once Task 1 lands, which opens the draft PR, and push
after each join.

The test config, used by Tasks 2, 3, and 7: a `pages` kind (`routing: 'page'`) with one entry,
`about`, and an `events` kind (`routing: 'custom'`) with one entry, `spring-regatta`, both on
the default permalink, and the site origin `https://example.org`. Task 7 adds a dated `posts`
kind and the `fragments` kind (`embedded`). Each test builds it from the helpers its file already
uses.

### Task 0: base build (30 min)

Before any edit, run the setup command bare, then `npm run package`, then
`readlink -f examples/showcase/node_modules/@glw907/cairn-cms`, which must resolve inside this
worktree. If it doesn't, run the durable gotcha's reinstall (`rm -rf examples/showcase/node_modules examples/showcase/package-lock.json`,
`npm --prefix examples/showcase install`, `git checkout -- examples/showcase/package-lock.json`),
each alone, and check again.

Build the base outputs into `$CLAUDE_JOB_DIR/tmp/parity/base/` as foundation-2's Task 0 did (its
plan is `git show f9a53ba30^:docs/internal/plans/2026-11-16-foundation-2-menus-plan.md`, "Task 0"):
the showcase build copied from `examples/showcase/.svelte-kit/cloudflare`, the Waymark demo
through `scripts/catalog/demo.mjs`, and the Pennant demo through a `buildDemo` call over
`sets/organization`. Write `serve.mjs`, `pages.txt` (12 URLs), `shoot.mjs` at 320, 390, 768, 1440,
and 2560, `compare.mjs`, and `hash.mjs` over the acceptance item's public set, with its
normalization, exactly as that task says. Run `hash.mjs` on `parity/base/showcase` into
`parity/base/showcase.hashes`, and shoot the 60 public pages into `parity/base/shots/`.

Write `shoot-admin.mjs <out>` from that plan's text: it runs `VITE_CAIRN_E2E=1 npm run build` in
`examples/showcase`, spawns
`npx wrangler dev --ip 127.0.0.1 --port 4291 --inspector-port 4292 --var CAIRN_DEV_BACKEND:1 --var PUBLIC_ORIGIN:http://127.0.0.1:4291`,
waits for `http://127.0.0.1:4291/`, shoots, and stops the child in a `finally`. Light theme, through
the `cairn-admin-theme` cookie set to `cairn-admin`. It shoots three states at 1440 and 390: a
post's edit screen (`/admin/posts/2026-06-hello`) with the Details panel open, a page's edit
screen (`/admin/pages/about`) with Details open, and the post's rename dialog open from its
**Change address** button. Open the panel and the dialog through their buttons by role and name.
A shot of a sign-in page means the server is wrong. Save into `parity/base/admin/`.

### Task 1: the type, the table, and the records (25 min)

1. `src/lib/content/types.ts`: the union gains `'custom'`, and its doc comment names the four
   values in one line each. `custom`: the kind has an address, the engine lists it, and a route
   the site writes serves the page. `RoutingRule` gains `siteServed: boolean` with a one-line doc
   comment: "A site's own route serves the entries' pages; the catch-all route leaves them alone."
   The `routable` comment becomes: "The entries have a public address, listed in the sitemap and
   offered to links and menus. An embedded concept has none."
2. `src/lib/content/concepts.ts`: `ROUTING_SHORTHANDS` takes the key type
   `'dated' | 'page' | 'embedded' | 'custom'` and gains
   `custom: { routable: true, dated: false, siteServed: true }`; the other rows gain
   `siteServed: false`. The error line becomes
   ``cairn: concept "${id}" routing "${routing}" must be one of dated, page, embedded, custom``.
3. Every hand-built `RoutingRule` literal under `src/lib/reproductions/**` and `src/tests/**`
   gains `siteServed: false`. Run `npm run check` to find each one. Record the count in the
   commit message beside the design's 57 in 35.
4. `src/tests/unit/content-concepts.test.ts`: a case for `routing: 'custom'`, and the
   unknown-value case's expected line updated.

### Task 2: the resolver (pair with Task 5, 20 min)

`src/lib/delivery/site-resolver.ts`: `UntypedSiteResolver` gains
`siteServed(id: string): boolean` with a one-line doc comment ("Whether a site's own route serves
this concept's pages, so the catch-all leaves them alone. An unknown id reads false."). Keep a map
beside `routableById`. `paths()` lists only entries whose concept isn't site-served; `byPath`,
`all()`, and `routable` don't change, so the duplicate-address check covers events. Update the
`paths()` member comment: "Every permalink the catch-all route serves". Add acceptance item 3's
case to `src/tests/unit/delivery-site-resolver.test.ts`. Fix any hand-built resolver double
`npm run check` names.

### Task 3: the public routes (pair with Task 6, 30 min)

`src/lib/delivery/public-routes.ts`:

1. `entryLoad`: after a hit, when `site.siteServed(entry.concept)`, throw
   `new Error(`cairn: "${event.url.pathname}" belongs to concept "${entry.concept}", whose routing is custom, so the catch-all route doesn't serve it. Add a route at that address that calls conceptEntryLoad('${entry.concept}', event), or change the concept's routing.`)`.
   The concept names its field `concept`; the executor uses the field the entry carries.
2. `markdownLoad`: a site-served entry answers 404 as a miss does. Its doc comment says the twin
   and the catch-all agree by construction for site-served pages too.
3. `conceptEntryLoad(concept: string, event: { url: URL }): Promise<EntryData<S>>`. When
   `!site.siteServed(concept)`, throw
   `new Error(`cairn: conceptEntryLoad('${concept}') needs a concept whose routing is custom; "${concept}" ${known ? `has routing ${value}` : 'is not declared'}. Serve it from the catch-all route, or set its routing to custom.`)`,
   reading the value through `site` or the config the factory already holds; if neither carries
   the routing name, say "isn't custom" without the value. Otherwise `byPermalink`; a miss, or an
   entry of another concept, answers 404 as `entryLoad` does; a hit returns `composeEntryData`
   through the same cast and comment.
4. `PublicRoutes` gains the member with a doc comment, and the interface comment's first
   paragraph names it. The return carries five functions.
5. Tests: acceptance items 4, 5, and 6 in `public-routes.test.ts`,
   `public-routes-markdown.test.ts`, `resolve-links.test.ts`, and `delivery-sitemap.test.ts`,
   with the test config.

### Task 4: the throwaway showcase build (25 min)

The executor runs this in the pass worktree once Task 3 is merged and the fast lane is green.
Every command and its output goes to `$CLAUDE_JOB_DIR/tmp/task4.log` for the PR.

1. `npm run package`, then the readlink check from Task 0.
2. In `examples/showcase/src/site/cairn.config.ts`, add an `events` kind beside `pages`: `dir:
   'src/content/events'`, `routing: 'custom'`, the default permalink, and the pages kind's
   fieldset. Write `examples/showcase/src/content/events/spring-regatta.md` with the frontmatter
   the fieldset requires and one paragraph. Add the line
   `See the [spring regatta](cairn:events/spring-regatta).` to
   `examples/showcase/src/content/pages/about.md`.
3. Write `examples/showcase/src/routes/(site)/events/[slug]/+page.server.ts` beside the catch-all,
   copied from `(site)/[...path]/+page.server.ts`: the same imports, `prerender = true`,
   `entries` from `site.concept('events')?.all().map((e) => ({ slug: e.slug })) ?? []` (or the
   field the summary carries), and `load` returning
   `withReferences(await routes.conceptEntryLoad('events', { url }))`. Write a `+page.svelte`
   that renders the catch-all page's component with the data, copied from
   `(site)/[...path]/+page.svelte`.
4. If the build refuses a stale `src/content/.cairn/index.json`, run
   `npm --prefix examples/showcase run cairn:manifest` and log it.
5. `npm --prefix examples/showcase run build`. Then log
   `ls examples/showcase/.svelte-kit/cloudflare/events/spring-regatta.html`,
   `grep -c "<loc>https://showcase.test/events/spring-regatta</loc>" examples/showcase/.svelte-kit/cloudflare/sitemap.xml`,
   and `find examples/showcase/.svelte-kit/cloudflare -path "*events*" -name "*.md" | wc -l`
   (expect `0`). Confirm the page came from the site's route: the `+page.svelte` at step 3 adds
   `data-route="events"` on its root element, and `grep -c 'data-route="events"'` on the page
   prints `1`. A page with no marker, or no page, parks the pass (standing answer 2).
6. Remove the two route files with `rm` by their full paths and build again. The build must fail,
   and `grep -n "cairn: \"/events/spring-regatta\"" <the build output>` must find the owner's
   line. Log the exit code and the line.
7. Revert: `git restore examples/showcase`, then `rm` each new file by its full path
   (`examples/showcase/src/content/events/spring-regatta.md`, and the route files if step 6 left
   any). `git status --porcelain examples/showcase` must print nothing; log it. No `git clean`, no
   stash.
8. Rebuild the showcase once more so the next task starts from the pass's own engine and files.

### Task 5: the address on the edit screen (pair with Task 2, 40 min)

1. `src/lib/sveltekit/content-routes-entry-read.ts`: `EditData` gains
   `permalink: string | null` with a doc comment ("The entry's public address, resolved from its
   concept's permalink pattern; null for a concept with no address, or when the entry's identity
   can't be read."). Compute it with its own `entryIdentity(concept, path, parsed.frontmatter)`
   call in a try, outside the manifest-gated advisory block, and only when
   `concept.routing.routable`. Update the `slug` member's comment: the rename dialog's prefill.
2. `src/lib/admin/EditPage.svelte`: `:2534` prints
   `data.permalink ?? (data.routable ? `/${data.slug}` : data.slug)`; the rename flash at `:1338`
   prints `data.permalink ?? data.slug`; the `RenameDialog` gets `permalink={data.permalink}`.
3. `src/lib/admin/RenameDialog.svelte`: a `permalink?: string | null` prop with a typed doc
   comment. A `$derived` new address: when `permalink` ends with `/${slug}`, the permalink with
   that last segment swapped for `/${nextSlug}`; otherwise `nextSlug`. The line reads "The new
   address will be `<code>{newAddress}</code>`." Add
   `// WATCH: the swap assumes the permalink pattern ends in :slug, as every pattern in the repo does; a pattern with :slug mid-path needs the server to build the new address.`
4. `src/lib/reproductions/stories/support.ts` `editPageProps` gains
   `permalink: `/posts/${slug}``, and each hand-built `EditData` that `npm run check` names gains
   `permalink`.
5. Tests: acceptance item 9's cases in `src/tests/component/EditPage.test.ts` (an event at
   `/events/spring-regatta`, a post at `/posts/<short name>`) and `RenameDialog.test.ts` (type a
   new short name, find the full new address), plus a case in
   `src/tests/integration/content-routes-entry-write.test.ts` or the file that tests the entry
   read, asserting `permalink` for a post, a page, and a fragment (`null`).

### Task 6: the menu list (pair with Task 3, 10 min)

`src/lib/sveltekit/nav-routes.ts:70` builds each address with
`resolvePermalink(c, { id: f.id, slug: f.id })`, imported from `../content/url-policy.js`. The
`pageOptions` comment says it lists every concept with an address that isn't dated, at its real
address. Add acceptance item 8's case to `src/tests/unit/nav-routes-load.test.ts`.

### Task 7: one test of every reader (pair with Task 8, 20 min)

`src/tests/integration/routing-values.test.ts` builds one config with `posts` (`dated`), `pages`
(`page`), `fragments` (`embedded`), and `events` (`custom`), one entry each, and asserts in one
place: `byPermalink` and `siteServed` for each; `entries()` and `markdownEntries()` hold the post
and the page only; the sitemap holds the post, the page, and the event; `EditData.linkTargets`
and the preview's link targets hold the post, the page, and the event; the menu list holds the
page and the event at their addresses; and the admin's label reads "address" for the three
routable kinds and "name" for the fragment, through the helper `content-routes-list.ts` or
`content-routes-shared.ts` exports to the routes. Acceptance items 7 and 10.

### Task 8: docs, changelog, ruling, snapshot, backlog (pair with Task 7, 35 min)

1. `skills/cairn-extending-a-site/references/content-model.md`: the routing values at `:64` and
   `:124-127` name `custom`, with the route file
   `src/routes/(site)/events/[slug]/+page.server.ts` as Task 4 wrote it, and a note that a custom
   page has no markdown twin.
2. `skills/cairn-extending-a-site/references/public-routes.md`: a `conceptEntryLoad` section with
   the same route file, the twin note, and a "Build failures" row for the `entryLoad` line. Keep
   this pass's lines apart from pass 3's.
3. `CHANGELOG.md` under `## Unreleased`: one entry for the value, the flag, the method, the
   loader, and the full address in the admin. No `Consumers must:` line unless design standing
   answer 4 applies. Keep it apart from pass 3's lines.
4. `MIGRATION-NOTES.md`: this release's section says no site has to change, and that a hand-built
   `RoutingRule` in a site's tests gains `siteServed`. Keep it apart from pass 3's lines.
5. `docs/internal/engine-rulings.md`: one entry at the end,
   `## scope-verdict-routing-custom: routable means a kind has an address, and the catch-all lists what it serves  (accept, 2026-11-17, routing design, queue 20261117-080523-be1fbe)`,
   with **Verdict**, **Shape**, and **Reopens on** lines in the form of the entries above it.
   Reopens on: a need for a dated site-served kind, or for a site-served page's markdown twin.
6. `npm run check:surface -- --update`, then `npm run check:surface`.
7. `BACKLOG.md`: each of the 43 listed ids gains ` *(swept 2026-11-17)*` at the end of its item
   line, replacing an older `*(swept <date>)*` stamp on that line, and nothing else changes. The
   ids and their lines at the base: #298:294, #378:459, #410:185, #412:164, #413:167, #415:170,
   #416:173, #417:176, #419:182, #480:114, #481:111, #482:108, #483:105, #484:102, #485:99,
   #487:97, #488:94, #490:54, #495:52, #496:50, #497:48, #498:46, #499:44, #500:42, #501:40,
   #502:38, #539:34, #541:383, #542:380, #543:377, #544:374, #545:372, #546:11, #547:13, #548:15,
   #549:17, #550:19, #552:23, #553:25, #554:27, #555:29, #556:31, and #557:9. Ids #495 to #502 also
   appear as Go-tool items at `:1678-1692`; those stay unstamped. Check each line holds its id
   before editing. Proof: `git diff --stat BACKLOG.md` shows 43 lines changed each way, and
   `grep -c "(swept 2026-11-17)" BACKLOG.md` prints `43`.
8. `npm run check:docs-gate`.

### Task 9: head build and parity (30 min)

`npm run package`, the readlink check, then build the head outputs into
`$CLAUDE_JOB_DIR/tmp/parity/head/` with the same scripts and arguments as Task 0. Run
`compare.mjs base head` and diff the two hash lists; paste both in the PR. A difference is traced
and fixed at its cause. Run `shoot-admin.mjs parity/head/admin`.

Dispatch three fresh `standards:visual-verifier` reads (Sonnet, medium), one per site, each given
its 20 base and 20 head shots as separate labeled blocks and the rule: no visitor-visible
difference. Dispatch one more for the admin, given the six base and six head shots and the
expected change: the post's Address shows `/posts/<short name>` where the base showed
`/<short name>`, the dialog names the full new address, and the page's screen is unchanged. Quote
each verdict in the PR.

### Task 10: whole-branch review (15 min)

Dispatch `standards:diff-reviewer` at whole-branch scope (its frontmatter model, effort medium) on
`79d326bed..HEAD`, given this plan, the design, and acceptance items 1 to 14. Fold each finding
or file it through `standards:log-issue`, run the fast lane, push, and start the CI watch.

### Task 11: hand over (10 min)

Delete this plan and the executor prompt in one commit. Write the PR body: an opening paragraph
per the voice guide, what landed, each acceptance item with its evidence, Task 4's log, the
parity and verifier results, `## Held paths`, `## Decisions`, `## Planning misses`, and the
score. Run `approval-packet` as its step 1 directs, and send the final report to
`conductor-foundation`.

## Held paths

None is foreseen. A change under `.github/**`, `scripts/release/**`, or `.claude/settings*` is
recorded in the PR's `## Held paths` for the round's `merge` document, and the rest of the pass
goes on.

## Decisions

1. `[design-gap]` The prompt gives the shorthand row as
   `{ routable: true, dated: false, siteServed: true }`. That is the custom row: the flag means a
   site's own route serves the page, so it's `true` for `custom` and `false` for the other three.
   The design's "Method calls" says the same ("The new flag, `siteServed`, answers" whether the
   catch-all serves the kind; "Four ask 'does the catch-all serve it?'"), read as its negation.
2. `siteServed(id)` reads `false` for an unknown id, where `routable(id)` reads `true`.
   `conceptEntryLoad` needs an unknown id to throw the owner's line, and no route serves a kind
   the config doesn't declare.
3. "Both resolvers" is one interface member: `TypedSiteResolver` extends
   `Omit<UntypedSiteResolver, 'concept'>`, so it inherits `siteServed`.
4. `[design-gap]` The edit data gains one field, `permalink`. The rename dialog builds the new
   address by swapping the permalink's last `/<slug>` segment for the new short name. Every
   pattern in the repo ends in `:slug`, and a rename changes only the slug, so the swap is exact
   today. A `// WATCH:` comment marks the case where it isn't. A second field, or a server round
   trip per keystroke, is surface the design doesn't name.
5. `permalink` is `null` for a kind with no address, and when `entryIdentity` throws (a malformed
   date the editor may be on the screen to fix). The screen then prints what it prints today. That
   is the existing branch, kept, and the edit screen still opens.
6. `[estimate]` 54 hand-built routing records in 33 files at `79d326bed`, against the design's 57
   in 35 at `a85986dbc`. `npm run check` is the list.
7. `[design-gap]` The design says 41 backlog items and lists 43 ids. Task 8 stamps the 43 listed.
   Ids #495 to #502 appear twice in `BACKLOG.md`; the stamp goes on the theme-garden copies at
   `:38-52`, which name files this pass changes, and the Go-tool copies at `:1678-1692` stay as
   they are.
8. The admin visual baselines shoot the edit screen with Details closed, so the address change
   moves none of them. Task 9's admin shots are the evidence for the open panel.
9. `entryLoad` throws a plain `Error`, as the design says. The showcase's
   `handleHttpError` throws on every HTTP error, and a plain `Error` from a load fails the
   prerender too, so the route-removed build fails either way; Task 4 confirms the line's text is
   in the output.
10. `conceptEntryLoad` answers 404 for an entry of another concept at the address, so a site's
    route can never serve a page under the wrong kind.

## Path

| Task | Minutes |
| --- | --- |
| 0 base builds, scripts, public and admin shots, hash | 30 |
| 1 type, table, error line, records | 25 |
| 2 and 5, as a pair (Task 5 sets it), with the join | 45 |
| 3 and 6, as a pair (Task 3 sets it), with the join | 35 |
| 4 throwaway showcase build and revert | 25 |
| 7 and 8, as a pair (Task 8 sets it), with the join | 40 |
| 9 head build, parity, four verifiers | 30 |
| 10 whole-branch review and folds | 15 |
| 11 delete, hand over (CI off the path) | 10 |
| Path (pairs overlap) | 255 |

Each `cairn-implementer` worktree pays its own setup, which the task minutes carry.

## Planning misses

- `[design-gap]` The shorthand row's flag value, the rename dialog's new address, and the backlog
  count (Decisions 1, 4, and 7).
- `[file-list]` The Kit config the design cited as `svelte.config.js` lives in
  `examples/showcase/vite.config.ts`; no file outside the row is needed.
- `[estimate]` 255 against 200: the parity builds and the admin shots every pass owes, which the
  design's minutes leave out.

## Review folded

Filled after the `standards:plan-reviewer` read.
