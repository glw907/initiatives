# Events for organization sites

Initiative: theme-garden. Round: `events`. Status: approved by Geoff (2026-11-14, queue document `20261115-055827-bbcf02`).
Read against cairn-cms at `4ebfb0e9e`, before any Pennant pass merged.

## Brief

A club's editor adds an event as a markdown entry with a date, a time, and a place. The site
lists what is coming up, gives each event a page, and serves one calendar feed a member subscribes
to in Google Calendar or Apple Calendar. A weekly practice is one entry with a repeat rule, and a
cancelled or moved night is one line on that entry.

The engine gains one export, a calendar feed builder. Everything else is site code the
organization content set carries: the events content kind, the function that turns entries into
dated occurrences, the routes, and the sample events. Pennant gains a "Coming up" section on its
home page and the events look.

Three passes, 480 path minutes in a row. Pass 1 starts on approve and runs beside the Pennant
round. Passes 2 and 3 start when Pennant's last pass has an accepted review, and build on its
branch.

## Why

Geoff, 2026-11-14: "some basic native events calendar functionaly might be helpful", "I don't want
to end up building something complex or too specific", "a subcribe iCal/Google link would be
critical", "Both ecxc-ski and the sailing club will be customers", and "some version of repeating
events would make this much more broadly useful". The aim he set is "the solution that resolves
the largest cases while still be small and streamlined from an engine stanpoint."

A read of about 40 small organizations' public pages (`research/club-sites-survey-2026-11-14.md`
and the events addendum in this session) found weekly repeats on 28, monthly repeats by position
("second Friday") on 9, every-two-weeks on none, and a multi-session course listed as one item
with a date range on all 5 that had one. Five of 41 offered a subscribe link. Weekly series nearly
always carry a season end. The visible exceptions are a cancelled night, a moved night, a changed
place, and a one-line note.

Tools that store one record per date (Wix, The Events Calendar, Wild Apricot) draw the known
complaints: deleting one date deletes the series, and a bulk edit wipes per-date edits. This
design stores a series once and its exceptions beside it.

## Decided by Geoff

- Events are the round after Pennant ("That works.", 2026-11-14, and the approved amendment
  `20261115-043946-a5b754`).
- A content set may carry code, reviewed as code before it publishes ("That works.", 2026-11-14).
- Engine and theme work live in one round.
- Repeats are in, in the smallest form that covers the largest cases.
- A subscribe link for iCal and Google is required.
- "Duplicate this entry" is backlog #487, judged apart from this round.

Open for the packet: the look, the cap at two repeat patterns, the reversal of two engine rulings,
how long a cancelled date stays visible, and whether this round runs before Survey. Each has a
`Ruled:` line under "Rulings" once he answers.

## Goals

1. An editor adds, edits, cancels, and moves events in the ordinary entry form, with no new field
   kind.
2. One feed address works in Google Calendar and Apple Calendar.
3. The engine's share is one stateless function with no knowledge of repeats.
4. A site built on any theme of the organization kind gets working events pages. Pennant makes
   them look like Pennant.

## Non-goals

- A month grid.
- Sign-up, registration, fees, or capacity. The sailing club keeps those in its own database.
- Importing a feed or a spreadsheet.
- A feed per event, or a download button per event.
- A time field kind, a repeat field kind, or an events concept in the engine.
- Every-two-weeks, yearly, or count-limited repeats, and repeats with no end date.
- `cairn new` installing the set. The tool still reads only the packed catalog.
- An engine release. A release is cut when ecxc-ski or the sailing club needs the builder.

## Anti-goals

- An event shown on the wrong day or at the wrong hour in a subscriber's calendar.
- A cancelled night that still looks live on the site or in the feed.
- A blog site whose admin gains an empty Events section.
- A repeat rule so general that the entry form needs explaining.

## What an editor writes

An event is one file under `src/content/events/`. Its fields, all existing kinds:

| Field | Kind | Rule |
| --- | --- | --- |
| `title` | text | required |
| `date` | date | required; the only day, or the day a series starts |
| `endDate` | date | optional; a course or a weekend, all day in the feed. Not with `repeats` |
| `time`, `endTime` | text, pattern `^([01]\d|2[0-3]):[0-5]\d$` | optional; no `time` means all day |
| `place` | text | optional |
| `summary` | textarea | optional; one or two lines for lists and the feed |
| `repeats` | object | optional; see below |
| `changes` | array of flat objects | optional; see below |

`repeats` holds `pattern` (`weekly` or `monthly`), `weekdays` (multiselect, used by `weekly`),
`week` (`1`, `2`, `3`, `4`, or `last`) and `weekday` (used by `monthly`), and `until` (date,
required). A weekly rule yields every listed weekday from `date` through `until`. A monthly rule
yields one day a month by position. `date` is where the series starts, never an extra occurrence:
the first night is the first day the rule yields on or after it.

An event with an `endDate` runs all day on each of its days in the feed, and its `time`, if set,
shows on the site as the daily start. A timed event with no `endTime` has no end in the feed.

`changes` is a list of rows, each `date` (which occurrence), `cancelled` (boolean), `newDate`,
`time`, `place`, and `note`. The row's label in the form is its date.

The concept's `refine` (`src/lib/content/types.ts:96-112`) refuses, with an error on the named
field: an `endTime` at or before `time` on a one-day event; an `endDate` before `date`; `repeats`
with `endDate`; a `weekly` rule with no weekday; a `monthly` rule missing `week` or `weekday`; an
`until` before `date` or more than 366 days after it (at most 367 occurrences); a change whose `date` the rule doesn't
yield; and two changes for one date.

## What a visitor sees

- **`/events`.** Coming events, soonest first, grouped by month. A series appears on each of its
  dates here. Each item shows the day, the time, the place, and the summary. A cancelled date
  shows struck through with "Cancelled" and its note. A moved date shows at its new day with
  "Moved from" and the old day. Above the list are two links, "Subscribe in Google Calendar" and
  "Subscribe in another calendar" (a `webcal:` link). With nothing coming, the page says so in one
  line and keeps the links.
- **`/events/<slug>`.** One event: when, where, the repeat in words ("Tuesdays and Thursdays until
  March 25"), its coming dates with their changes, and the entry's body.
- **The home page, on Pennant.** A "Coming up" section with the next three distinct events. A
  series appears once here, at its next date. The section is absent when nothing is coming.
- **`/events.ics`.** The feed.

A date drops off the lists when its day has passed in the site's time zone. Pages are prerendered,
so a small script on the page hides passed items the way the banner hides after its expiry
(`templates/waymark/src/chassis/directives/banner-expiry.ts`), and the admin docs tell a developer
to schedule a daily rebuild. The list function takes `now` as an argument.

The script does more than hide. On `/events`, when it has hidden every item it shows the one-line
empty state, which is in the HTML from the build. The home section's HTML holds up to six events;
the script shows the first three whose day hasn't passed and hides the whole section when none is
left.

The events kind uses `embedded` routing, so the engine's catch-all route and the sitemap leave it
alone and the set's `/events/[slug]` route is the only page for an event. The admin then calls an
event's identifier its name. Event pages are absent from the sitemap in this round.

The mock-up is `research/pennant-mockups/events-1.html`. Its wording is placeholder.

## The feed

`buildICalendarResponse(calendar)` joins `/delivery`. It takes a calendar name, a product id, an
optional `stamp` instant that defaults to the build time, and a list of events. Each event has a `uid`, a `start`, and a `summary`, with optional `end`,
`location`, `description`, `url`, and `status: 'cancelled'`. A start is either a date (an all-day
event) or a UTC instant (a timed one). An all-day `end` is the last day, inclusive, and the
builder writes the exclusive `DTEND` the format wants. The function does no time zone math and knows nothing of
repeats. It returns a `text/calendar; charset=utf-8` response, as `buildRssResponse` does for RSS
(`src/lib/delivery/responses.ts:14`).

It writes RFC 5545: `CRLF` line ends, lines folded at 75 octets on a character boundary, text
escaped (`\\`, `\;`, `\,`, `\n`), one `VEVENT` per event, `VERSION:2.0`, the `PRODID`, a `DTSTAMP` on every event from `stamp`, timed
events as UTC with a `Z`, all-day events as `VALUE=DATE` with an exclusive end, and
`STATUS:CANCELLED` for a cancelled event. It writes no `RRULE`, `RECURRENCE-ID`, or `SEQUENCE`.

The site code hands it one event per occurrence. Each occurrence's instant is computed from its
wall time on its date, never by adding weeks to the first, so a series keeps its hour across a
clock change. An occurrence's `uid` is the entry id, the original date, and the site's host, so a moved night keeps its identity. A cancelled occurrence
stays in the feed with `STATUS:CANCELLED` and a summary that opens "Cancelled:", since some
calendars ignore the status line.

The site's time zone is one constant in the set's events module, an IANA name. The module turns a
date and a wall time into a UTC instant with `Intl.DateTimeFormat`. A bad zone name throws at
build.

## Calls made here

Method and architecture calls. Geoff can overrule any in a note.

1. **The export is a response helper.** `delivery-exports.test.ts` holds that raw feed builders
   stay behind response helpers, so the public name is `buildICalendarResponse` and the string
   builder is not exported.
2. **The builder takes instants.** Zone conversion is site code, which keeps a zone database and
   its edge cases out of the engine's contract.
3. **A site-owned import point.** The site's `src/site/` gains one small file, `set.ts`, that
   exports a record of extra concepts, a list of admin sidebar entries for them, and a function
   returning extra home lists, all empty by default. `cairn.config.ts` spreads the concepts into
   `content` and the entries into `navLayout`, and the home route merges the lists into the
   `lists` object Pennant pass 2 adds. A set replaces that one file. A blog site's admin shows
   nothing new. The template is generated from `examples/showcase`, and the demo composes over a
   showcase copy, so the file and the two edits are written in the showcase.
4. **A set names its code.** `cairn-set.json` gains an optional `code` list of paths. The archive
   check refuses a set file outside `src/content/`, `static/`, and `src/site/site.config.yaml`
   unless `code` lists it, and refuses a listed path that resolves outside `src/site/` and
   `src/routes/`, a path with `..` included. The demo build reads the list from the set's
   `cairn-set.json` and copies the listed files into the composed site. The schema stays `cairn-set-1`, since
   an optional key breaks no reader.
5. **Events views belong to the set.** The list, the event page, and the feed route are the
   set's route files. They use daisyUI role utilities and the chassis tokens, so they take any
   theme's colors, and they carry class hooks (`cairn-events`, `cairn-event`, `cairn-event-date`)
   a theme may style. The theme contract gains no required component.
6. **The set's logic is tested in the engine suite.** A unit test under `src/tests/unit/` imports
   the set's occurrences module by path.
7. **Two releases wait for Geoff together.** The set's 1.1.0 is the first set release with code,
   and Pennant's 1.1.0 is a look. Pass 3's worktree is cut from pass 2's branch, and both PRs
   reach him in one close document.
8. **No Google account check.** How Google draws a cancelled feed event can't be verified here:
   the workstation has no test Google account. The "Cancelled:" summary covers either behavior.
9. **The event page prerenders when reached.** A site with no events has no event page to
   build, and the template fails a build on a prerenderable route nothing reached. The event
   route sets `prerender = 'auto'`. Pass 2's planner probes that a site with zero events builds;
   standing answer 21 holds the fallback.
10. **Sample dates go stale.** The samples run through 2027. After that the demo shows the empty
   state until a set release renews them. Tests pass `now`, so no test depends on the build date.
11. **Docs.** The builder's contract is its doc comment and a section in the
   `cairn-extending-a-site` skill. Editors get one page, `docs/editors/events.md`, which says it
   applies to a site with events. Admins get the scheduled rebuild and the time zone constant.

## Scope

The scope reviewer (`engine-triage`, twice) accepts the events kind for organization sites as
site code, the occurrences function and the per-date changes as site code, and the feed builder
as a `/delivery` export without `sequence`. It declines a time field and declines shipping events
code in every template. Call 3 keeps to that: the template gains an empty import point, never
events code.

Two standing rulings change, and both are Geoff's to reverse on purpose. `ical-builder`
(`docs/internal/engine-rulings.md:294`, decline, 2026-08-05) reopens "on: Deliberate reopening of
the fixed-concepts model by an events-content decision." The August decisions doc says the events
brainstorm "reopens the standing no-events-concept ruling deliberately or not at all." Pass 1
writes the ledger entry from his ruling.

The sailing club's ratified design keeps its events in D1 with registration and fees. This round
doesn't touch that. The club can adopt the feed builder alone.

## How it fails

| Case | Result |
| --- | --- |
| Time not `HH:MM` | The field's pattern error at save |
| `endTime` at or before `time`, `endDate` before `date` | `refine` error on the later field |
| `until` missing, before `date`, or over 366 days out | `refine` error on `until` |
| A change for a date the rule doesn't yield, or two for one date | `refine` error on `changes` |
| A non-draft event that fails these at build | The build fails, naming the entry |
| A bad time zone name | The build fails with the zone's name |
| A feed line over 75 octets | Folded, never cut inside a character |
| No events, or none coming | `/events` says so; the home section is absent; the feed is a valid empty calendar |
| A site whose events are all deleted | The build passes, and `/events` shows the empty state |
| A set file outside the allowed paths, or unlisted code | The archive check fails before any write |
| A set with code built over a site with no `set.ts` | The demo build fails, naming the file |

## Passes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `events-1` feed | `buildICalendarResponse` under `/delivery`, the rulings entry, the skill section | `src/lib/delivery/{icalendar,responses,index}.ts`, `src/tests/unit/delivery-*.test.ts`, `scripts/checks/api-surface.md`, `docs/internal/engine-rulings.md`, `skills/cairn-extending-a-site/**`, `CHANGELOG.md`, `MIGRATION-NOTES.md` | per the path map | 90 | none | 2 (`CHANGELOG.md`, `MIGRATION-NOTES.md`) |
| `events-2` set | The import point, sets that carry code, and events in the organization set | `examples/showcase/src/site/{set.ts,cairn.config.ts}`, `examples/showcase/src/routes/(site)/+page.server.ts`, the regenerated `templates/waymark/**`, `scripts/theme/viewer/site.mjs`, `scripts/catalog/{archive,demo,index}.mjs` with their tests, `schema/cairn-set-1.schema.json`, `sets/organization/**`, `src/tests/unit/set-organization-events.test.ts`, `docs/internal/theme-catalog.md`, `docs/editors/events.md`, `docs/admin/**`, `CHANGELOG.md`, `MIGRATION-NOTES.md` | per the path map, `live-account` | 240 | 1 | 1 |
| `events-3` pennant | "Coming up" on the home page and the events look | `themes/pennant/**` | per the path map, `live-account` | 150 | 2 | none |

### What each merge publishes

The catalog workflow publishes each theme and set version the bucket doesn't list, and a
published release is permanent (`docs/internal/theme-catalog.md`, "How a release is published").

- Pass 1 publishes nothing.
- Pass 2 publishes the organization set 1.1.0.
- Pass 3 publishes Pennant 1.1.0 and redeploys `demo-pennant.cairn.pub`, which then shows events.

No pass bumps the engine version or publishes to npm. The set and the theme keep the `engine`
range Pennant call 15 set, which admits only a release later than `0.99.0-rc.4`.

## Acceptance

Every pass also meets these two: the fast lane and CI are green on the head commit, and each
page written for a person follows the repo's docs register (`cairn-writing-docs`).

### Pass 1, feed

1. A unit test builds a feed of four events (timed, all-day, multi-day, cancelled) with a fixed
   `stamp` and compares it byte for byte with a fixture written by hand from RFC 5545, never
   generated by the code. The fixture has `CRLF` line ends, `VERSION:2.0`, the `PRODID`, a
   `DTSTAMP` in every event, a `Z` on every timed start, `STATUS:CANCELLED` on the cancelled
   event, and for a three-day event starting 2027-06-11 the line `DTEND;VALUE=DATE:20270614`.
2. A test feeds a summary of 60 two-byte characters. Every physical line is at or under 75
   octets and decodes as UTF-8 by itself under a fatal decoder, and the summary equals the
   input after unfolding.
3. A test holds that a comma, a semicolon, a backslash, and a newline in a summary appear on the
   wire as `\,`, `\;`, `\\`, and `\n`.
4. The fixture parses with a published iCalendar parser run as a one-off check, with its output in
   the PR, and the parser reports four events and no error.
5. `npm run check:tiers`, `check:surface`, `check:options`, and `check:package` pass, and
   `api-surface.md` lists `buildICalendarResponse` with its two types and no other new name.
6. `delivery-entry-boundary.test.ts` and `delivery-dist-spawn.test.ts` pass unchanged.
7. `docs/internal/engine-rulings.md` carries the reversal with Geoff's ruling quoted.

### Pass 2, set

1. A unit test gives the occurrences function a weekly Tuesday and Thursday rule from 2027-01-05
   to 2027-03-25 and gets 24 dates, the first 2027-01-05 and the last 2027-03-25.
2. A test gives it "last Friday" monthly from 2027-01-01 to 2027-06-30 and gets 2027-01-29,
   02-26, 03-26, 04-30, 05-28, 06-25.
3. A test holds that 18:30 in `America/Anchorage` is `03:30Z` the next day on 2027-01-14 and
   `02:30Z` on 2027-07-14.
4. A test cancels one date and moves another with a new time and place: the cancelled one is
   flagged and keeps its date, the moved one sits at its new date with the new time and place and
   is gone from its old date, and both keep the `uid` of their original date.
5. One test per row of the "How it fails" table from the first row to the sixth shows the named
   error on the named field or entry, each case in a row with its own assertion.
6. A test builds a set archive with an unlisted `.ts` file and gets the archive error, one with a
   listed path under `src/lib/` and gets the path error, and one with the listed path
   `src/site/../lib/x.ts` and gets the path error.
7. The proving demo's `/events.ics` answers 200 with a content type that starts `text/calendar`
   and holds one `VEVENT` per sample occurrence, the count stated in the PR. `/events` and one
   event page render at 320, 390, 768, 1440, and 2560 with no horizontal scroll, read by a fresh grader.
8. A site composed with the starter overlay, with no set, shows no Events section in the admin
   and no `/events` route. A test or a screenshot shows it.
9. `/events` rendered with `now` set after every sample event shows the one-line empty state and
   both subscribe links. A browser test loads the built page from before that date with the clock
   set after it, and sees the empty state, no event item, and both links.
10. The sample events are the society's: a monthly map night, a summer field-day series with one
    cancelled date and one moved date, and one two-day course. Each invented name is searched, and the searches are
    in the PR.
11. A test builds a weekly 18:30 series in `America/Anchorage` across 2027-03-14 and gets `03:30Z`
    for each night before it and `02:30Z` for each night after. The test passes under `TZ=UTC` and
    under `TZ=Asia/Tokyo`.
12. A site composed with the set and with every event file removed builds, and its `/events`
    shows the empty state.

### Pass 3, pennant

1. The home page shows "Coming up" with three items when the set has events, and the section is
   absent from the page's HTML when `now` is past every event. A browser test loads the built home
   page with the clock set past the first event and sees three items, the fourth event among
   them, and with the clock past every event sees no "Coming up" heading.
2. A series with two dates inside the next three shows once, and the section still shows three
   distinct events.
3. A fresh grader compares `/events`, an event page, and the home section with
   `events-1.html` at the five widths, in all five color sets, light and dark, and passes layout,
   type, color, and spacing.
4. The theme check passes, contrast included, for every color set in both modes.
5. A cancelled item's "Cancelled" label reaches 4.5:1 in every set and mode.
6. `demo-pennant.cairn.pub/events.ics` answers 200 after the merge with a content type that
   starts `text/calendar` and at least one `VEVENT`, and the demo's release marker reads 1.1.0.

## Shared assumptions

| Assumption | Source or probe |
| --- | --- |
| Node's `Intl` turns a wall time in a named zone into a UTC instant and refuses a bad zone | Probe, 2026-11-14: 18:30 Anchorage gave `2027-01-15T03:30:00.000Z` and `2027-07-15T02:30:00.000Z`; `Alaska/Nowhere` gave `RangeError: Invalid time zone specified` |
| Raw feed builders stay behind response helpers | `src/tests/unit/delivery-exports.test.ts`: `for (const name of ['buildRssFeed', 'buildJsonFeed', 'buildSitemap', 'buildRobots']) expect(name in barrel).toBe(false)` |
| The demo build copies only a set's content and static files | `scripts/theme/viewer/site.mjs:155-161`: `cpSync(path.join(set, 'src/content'), content, …)` and `cpSync(path.join(set, 'static'), …)` |
| A set archive already carries every file in the set | `scripts/catalog/archive.mjs:242`: `const entries = walk(setDir, 'set')` |
| The set schema refuses an unknown key | `schema/cairn-set-1.schema.json:7`: `"additionalProperties": false` |
| A concept takes cross-field rules and arrays of flat objects | `src/lib/content/types.ts:96-112` (`refine`); `src/lib/content/fields.ts:174` ("Holds only leaves") and `:216` ("a leaf, or a flat object of leaves") |
| The home route hands a theme one `lists` object | The Pennant design's amendment, approved as `20261115-043946-a5b754`. Not in the code at `4ebfb0e9e`; the start line covers it |
| A run publishes only versions the bucket doesn't list | `docs/internal/theme-catalog.md`: "For each theme and set whose version the bucket's `index.json` doesn't list" |

Pass 2 alone rests on one unproven mechanism: that spreading an imported record into
`defineAdapter`'s `content` keeps `site.concept('events')` typed. Its planner probes it first, and
standing answer 14 says what happens when it doesn't.

## Order

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 `feed` | `plans/2026-11-14-events-1-planner-prompt.txt` | none | 90 | no |
| 2 `set` | `plans/2026-11-14-events-2-planner-prompt.txt` | 1 | 240 | yes |
| 3 `pennant` | `plans/2026-11-14-events-3-planner-prompt.txt` | 2 | 150 | yes |

Merge order is 1, 2, 3. Pass 1 lands on review. Passes 2 and 3 go to Geoff in one close document,
after Pennant's.

Pass 1 runs beside the Pennant round. It shares only `CHANGELOG.md` and `MIGRATION-NOTES.md` with
Pennant's passes, and whichever merges second takes `main` in first. Pass 2's worktree is cut from
Pennant pass 4's branch, with `origin/main` merged in for pass 1's export, and pass 3's from pass
2's, so the whole chain builds before any of the
three waiting merges. A send-back on Pennant's look is then rework for pass 3.
The usage ceiling is 85 percent of the weekly allowance. The round stops new launches past 960
minutes.

## Start line

Pass 1's planner launches on approve, when these read true:

1. The design's "Rulings" carry all five `Ruled:` lines, with ruling 3 a yes.
2. `claude agents --json` lists no session named `cairn-cms-events-*`.

Pass 2's planner launches when these read true:

3. Pass 1 has merged.
4. `git show origin/pennant-3:sets/organization/cairn-set.json`, or the same on `origin/main`,
   prints version `1.0.0`.
5. Pennant pass 4's PR carries an accepted whole-branch review, and `conductor-pennant` has said
   so by message or has sent its close document.

The round runs beside `tui-language`, which works only under `tool/`. No events pass opens `tool/`.

Launch checks run 2026-11-14:

| Check | Output |
| --- | --- |
| `claude -p "/usage" --model haiku` | `Current week (all models): 25% used` |
| `git rev-list --count HEAD..origin/main` | `0` |
| `claude --help`, for the launch line's flags | `--bg`, `--effort`, and `--name` are listed. `--advisor` is not; `cairn-cms-pennant-1-plan` was launched with it today and is running |
| `claude agents --json` | No `cairn-cms-events-*` session: line 2 is met |
| Lines 4 and 5 | Not met: `sets/` holds only `kinds.json`, and Pennant pass 1 is in planning |

Pass 1 starts on approve. Passes 2 and 3 wait for Pennant's last pass to pass its review, and
`conductor-events` holds until `conductor-pennant` reports it.

## Steps for Geoff

- None before the round. Pennant's demo Worker, its domain, and the `ci-cairn-demos` scope were
  done on 2026-11-14, and events add no Worker.
- `[you: at the end]` The close document for passes 2 and 3, then the round report.

## Standing answers

The twelve in `round-run.md` hold. This design adds:

13. An engine release is cut before pass 1 merges. Pass 2 raises the set's `engine` floor to the
    first release that carries the builder, and flags it.
14. The concept spread in call 3 loses the concept's types. The pass parks. A set that carries a
    whole `cairn.config.ts` would overwrite the access block and the literals setup matches, so
    it is never the fallback.
15. The publish job asks for a new Waymark version because the template changed. The pass parks:
    an unplanned permanent release is Geoff's.
16. The code after Pennant has no `lists` object on the home route. Pass 2 parks.
17. A 403 from a Cloudflare token. The pass parks. Never widen a token and never try another
    credential.
18. A reviewer or a planner wants a month grid, sign-up, an import, a per-event download, or a
    third repeat pattern. It is filed through `standards:log-issue` and never built.
19. The parser check in pass 1's item 4 needs a package the repo doesn't have. It runs with `npx`
    in the scratchpad and adds no dependency.
20. A mock-up detail fails contrast in a color set. The value is tuned within its hue, and the
    PR lists the old and new values.
21. A site with zero events fails to build under `prerender = 'auto'`. The set drops the event
    page: each event's body shows on `/events` under its item, with an anchor per event, and the
    planner flags it.
22. Pennant's pass 4 is sent back after pass 3 built on it. Pass 3 takes the revised branch in and
    regrades.

## Rulings

Each `Ruled:` line quotes Geoff's answer in queue document `20261115-055827-bbcf02`, 2026-11-14.

1. The look in `events-1.html`.
   Ruled: "Build to the mock-up".
2. The cap at two repeat patterns.
   Ruled: "Two, as a recorded ruling". A third pattern needs Geoff to reopen it.
3. The reversal of `ical-builder` and the no-events ruling, in this narrow form.
   Ruled: yes, "Reverse it in this narrow form". The engine gains the feed builder and nothing else.
4. How long a cancelled date stays on the lists.
   Ruled: "Show it struck through until the day passes".
5. Events before Survey, or after.
   Ruled: "Events first, then Survey".

## Backlog verdicts

A scoped sweep read 21 open items at `4ebfb0e9e`. None folds: no item lives in lines the round
rewrites. Twenty stay as they are and gain the sweep stamp. One is reworded:

- #416 (retire `/styleguide`): "10 of the 51 baselines" becomes "the baselines in
  `site-visual.spec.ts`", since the count was not rechecked.

Thirteen open items carry no sweep stamp, under the 15 that make a full sweep due.

## Estimate

480 path minutes: 90, 240, 150. Pass 2 is the largest because it changes what a set is and writes
the events code. No cairn-cms round on this design process has reported yet, so the figures rest
on Pennant's plan sizes for like work and are checked against Pennant's scores when it reports.

## Practice and sources

- RFC 5545, Internet Calendaring and Scheduling (iCalendar), sections 3.1 (folding), 3.3.11
  (text), 3.6.1 (`VEVENT`), 3.8.1.11 (`STATUS`).
- Google Calendar Help, "Subscribe to someone's Google Calendar" and "Use a link to add a public
  calendar": an added feed can take up to a day to refresh.
- Squarespace's events help, which tells editors to duplicate an event in place of a repeat.
- The club-sites survey in this record.
- `aksailingclub-org/docs/2026-08-22-events-redesign-design.md`, for what a club with
  registration keeps in its own database.

## Out of scope and later

- #487, start a new entry from an existing one.
- `cairn new` reading the hosted catalog and installing a set's code.
- Event pages in the sitemap.
- An engine release carrying the builder, cut when a customer site needs it.
- ecxc-ski's and the sailing club's moves to the shared pieces, each a site pass with its own
  consultation.
- A month grid, if two or more sites ask.
