---
page: Debug your site
type: troubleshooting
track: extend
exemplar: operators/github-pages-troubleshoot-domains
---

# Debug your site

:::reader
**Who reads it.** A developer who builds a cairn site and has working knowledge of SvelteKit server code (hooks, loads, and form actions), the site's Wrangler config, and whichever cairn seams the site uses. They need no introduction to logging or JSON.

**Why they arrive:**
- A `cairn health` errors check failed.
- The site misbehaves under the development server or in production.
- A failure path in an extend guide sent them here.
- They are building a query, alert, or records of their own.

**What the page does for them.** This page matches a symptom on a cairn site to the log event or error behind it, then to what to do: usually a code or config change, sometimes nothing, and for a record that reports no fault, a query that allows for when it fires. Failures that leave no record are matched by what you see instead, and each of those ends in a change to your code or config.

**What it leaves to other pages:**
- Symptoms an operator resolves without a code change, which belong to the admin track's troubleshooting page (not yet published).
- The full event table with every event's fields, which lives in the log events reference.
- Configuring cairn-audit for a whole site, which lives in Run cairn-audit on your site.
- An error that began with an engine upgrade, which lives in Upgrade cairn and the migration notes.
:::

## Read the structured logs

*Shows the reader what a log record looks like and that its event names are stable, so every row after it makes sense.*

- Every engine record is one JSON object with a `level`, `event`, and `timestamp` envelope, and each row on this page names the `event` to find. :fact[rkj7tn]
- Event names follow the pattern `area[.subject].verb_phrase`, such as `content.field_unmarked`, so you can read the area and the action straight from a name. :fact[eywrq8]
- Renaming an `event` is a breaking change, so a query or alert keyed on an event name rests on a stable contract. :fact[rkj7tn]

### Find the records

*Gets the reader to a place where they can see the records, and tells them what an empty result means.*

- A deployed Worker's records reach Workers Logs only when its Wrangler config sets `observability.enabled` to `true`, so an empty log on a site without that setting proves nothing until you turn it on. :fact[prb2os]
- The scaffold's `wrangler.jsonc` already sets `observability.enabled`, so a scaffolded site has the setting unless someone removed it. :fact[prb2os]
- Workers Logs shows a Worker's structured logs in the Cloudflare dashboard. :fact[gzs6b8]
- See [Workers Logs](https://developers.cloudflare.com/workers/observability/logs/workers-logs/).
- `npx wrangler tail` streams a Worker's logs live while you reproduce the problem. :fact[gzs6b8]
- See [`wrangler tail`](https://developers.cloudflare.com/workers/wrangler/commands/#tail).
- `cairn logs <site>` reads that site's structured records from Cloudflare Workers Observability, and a Worker with observability off answers with zero entries rather than an error. :fact[q9ylqa]
- `cairn health` has an `errors` check that passes while the window holds at most `--error-threshold` engine error records (default 5) and fails above it, over a `--since` window that defaults to 24h. :fact[vg5zt8]
- A failed `errors` check is the cue to read the window's records with `cairn logs` and match each one to its row on this page. :fact[vg5zt8] :fact[q9ylqa]

:::row
**Symptom.** `cairn logs <site>` returns zero entries, or Workers Logs shows no records, for a site that is misbehaving.
**Cause.** The Worker's Wrangler config does not set `observability.enabled` to `true`, so its structured records go nowhere. `cairn doctor` confirms it by raising `config.observability-off` from its `config.observability` check.
**Fix.** This is a config change: set `observability.enabled` to `true` in `wrangler.jsonc` and redeploy, then reproduce the problem and read `cairn logs` or Workers Logs again. :fact[txgoyy] :fact[prb2os] :fact[q9ylqa]
:::

- A script or program that runs `cairn logs` or `cairn health` reads the CLI's contract from `cairn help agents`: exit codes and precedence, stdout as payload, stderr as diagnostics, and the schema URLs. `go install` installs no docs tree. :fact[vi9xh0]

### Record redaction

*Explains the marker values a reader may see inside a record, so they do not mistake them for logged data.*

- Every engine record passes through the same redaction a site's records take, so some values in a record are the redactor's markers rather than the logged data. :fact[avc1a2]
- Redaction walks three levels deep into plain objects and arrays, and a key at level four or deeper is left as written. :fact[avc1a2]
- A repeated reference reads `'<repeated>'` in the record. :fact[avc1a2]
- A throwing getter in a call's fields never throws out of the log call; the record carries `fields: '<unserializable>'` instead. :fact[avc1a2]
- See [`createLogger` in the log reference](../reference/log.md#createlogger).

## Content field events

*Introduces the events a concept's fieldset logs, each pointing at one field declaration the site controls.*

- A concept's fieldset logs these events while the engine builds the tag index or validates a save, and each points at one field declaration. :fact[gy2h7p]

### `content.field_unmarked`

*Helps the reader whose tag pages are empty find the missing `taxonomy: true` marker.*

- A concept that declares a multiselect named `tags`, `freetags`, or `categories` but marks no field `taxonomy: true` gets an empty tag index, and the engine logs `content.field_unmarked` as a warning. :fact[lbeeak]

:::row
**Symptom.** The site's tag pages and tag index are empty although entries carry tags, and the log holds `content.field_unmarked`.
**Cause.** The tag index reads only the field marked `taxonomy: true`; no field name stands in as a default.
**Fix.** This is a code change: add `taxonomy: true` to the concept's actual tag field. :fact[lbeeak]
:::

### `content.field_behavior_failed`

*Helps the reader whose save accepted a bad value find the validator that threw.*

- When a field's `behavior.validate()` throws during a save, the engine treats the field as valid, saves the value, and logs `content.field_behavior_failed` as a warning. :fact[qdfs37]

:::row
**Symptom.** A save accepts a value the field's validator should have refused, and the log holds `content.field_behavior_failed`.
**Cause.** The field's `behavior.validate()` threw; the engine catches the throw rather than failing the whole save, so the bad value lands.
**Fix.** This is a code change to the validator of the field the record's `field` and `owner` name, at the exception its `error` carries. :fact[qdfs37]
:::

## Public route events

*Introduces the one event a public route factory logs and when it appears.*

- A public route factory checks its media wiring once, when it is built, so its event appears once and not on each request. :fact[twqb0s]

### `media.resolver_absent`

*Helps the reader whose public pages show literal `media:` tokens find the missing `resolveMedia`.*

- Public images render as literal `media:` tokens when a public route factory is built with media on but no `resolveMedia`, and the engine logs `media.resolver_absent` once, at construction. :fact[twqb0s]

:::row
**Symptom.** Public pages show literal `media:` tokens where images belong, and the log holds one `media.resolver_absent` warning from when the factory was built.
**Cause.** The factory was built with `assetsEnabled: true` (the site's media-on flag, `runtime.resolvedAssets.enabled`) but no `resolveMedia` function was passed to it, so every `media:` reference has nothing to resolve against.
**Fix.** This is a code change: pass the site's `resolveMedia` to the public route factory. :fact[twqb0s]
:::

- See [`PublicRoutesConfig` in the delivery reference](../reference/delivery.md#publicroutesconfig).

## Admin action events

*Lays out the order of checks a wrapped admin action runs, so the first event a request logs places it at the check that stopped it.*

- `createSectionAction` runs its checks in a fixed order before the handler, and the event a request logs places it at the check that stopped or degraded it. :fact[1b3ye3]
- First, `createAdminAction` checks the session, then runs a double-submit CSRF check that logs `admin.action.csrf_refused` and throws `error(403)`. Both throw rather than answering `fail()`. :fact[1b3ye3]
- Second, the rate limit runs when one is configured; it is the one check that degrades to open. :fact[1b3ye3]
- Third, the access-map check logs `admin.action.misconfigured` and answers `fail(500)` when no access map is attached. :fact[1b3ye3]
- Fourth and fifth, the two authorization checks answer `fail(403)` when the action has no access rule, or the role is not admitted, or an owner-only action meets a non-owner. :fact[1b3ye3]
- Sixth, the database-binding check logs `admin.action.misconfigured` and answers `fail(500)` when `resolveDb` returns nothing; it runs last so a refused session's attempt audits as a denial, not a config fault. :fact[1b3ye3]
- See [`createSectionAction` in the SvelteKit reference](../reference/sveltekit.md#createsectionaction).

### `admin.action.session_absent`

*Helps the reader whose custom-screen form submissions are lost tell a one-off lapsed session from a route mounted outside `/admin`.*

- A wrapped action logs `admin.action.session_absent` and stops at its session check when no hook resolved an editor for the route: a route outside `/admin`, or a public admin path such as `/admin/login`. On a gated admin path the guard redirects a missing or expired session to `/admin/login` itself and writes no record. :fact[v1jj2k] :fact[u78zg6]

:::row
**Symptom.** No submission of a wrapped action takes effect, and the log holds `admin.action.session_absent` for each one.
**Cause.** The action's route is outside `/admin`, so the guard, which covers the whole `/admin` subtree, never resolves a session for it. A request with no `cairnEditor` stops at `createAdminAction`'s session check, the first check the wrapper runs.
**Fix.** This is a code change: mount the route under `/admin`, where the guard resolves the editor's session before the action runs. :fact[u78zg6] :fact[2sd4if] :fact[v1jj2k]
:::

### `admin.action.rate_limit_absent` and `admin.action.rate_limit_failed`

*Helps the reader whose rate-limited action never refuses a burst find whether the binding or the limiter call is at fault.*

- The rate-limit check is the one check that degrades to open, so both events report an action that ran with no limit. :fact[1b3ye3] :fact[i1dayf]
- An over-limit call logs `admin.action.rate_limited` and answers `fail(429)`; that is the limit working, not a fault. :fact[1b3ye3]

:::row
**Symptom.** A rate-limited action never refuses a burst, and the log holds `admin.action.rate_limit_absent`.
**Cause.** The configured rate limit's binding resolved to nothing, so the check degraded to open.
**Fix.** This is a code or config change that makes the rate limit's binding resolve. :fact[1b3ye3] :fact[i1dayf]
:::

:::row
**Symptom.** A rate-limited action never refuses a burst, and the log holds `admin.action.rate_limit_failed`.
**Cause.** The site's `key()` call or the limiter's `limit()` call threw, so the check degraded to open; the record carries the `error` field.
**Fix.** This is a code change to `key()` or to the limiter, wherever the throw began. :fact[1b3ye3] :fact[i1dayf]
:::

### `admin.action.misconfigured`

*Helps the reader whose custom-screen action answers a generic 500 tell a missing access map from an unbound database.*

- `createSectionAction` answers `fail(500)` and logs `admin.action.misconfigured` when the action has no access map attached or its database binding does not resolve, and the record's `reason` names which. :fact[nup3og]
- The `reason` is `access_map_not_attached` when `event.locals.cairnAccess` was never set because a site hook set `locals.cairnEditor` without it, and `db_not_bound` when `config.resolveDb` returns null or undefined. :fact[nup3og]

:::row
**Symptom.** A custom screen's form action answers a generic 500, and the log holds `admin.action.misconfigured` with `reason: 'access_map_not_attached'`.
**Cause.** The route sits outside the coverage of the guard and the dev backend's handle, and a site hook there set `locals.cairnEditor` without `locals.cairnAccess`. Each of those handles sets `locals.cairnAccess` to `runtime.access ?? {}` on every admin path it covers, right after it sets `locals.cairnEditor`, and a site declares its access map once, as the adapter's `access` member.
**Fix.** This is a code change: that hook also attaches the adapter's access map to `locals.cairnAccess`, or the route goes behind the guard, which attaches it on every admin path it covers. :fact[nup3og] :fact[u78zg6] :fact[iwf4nu]
:::

- See [Upgrade cairn: when your range crosses the one-declaration change](upgrade-cairn.md#when-your-range-crosses-the-one-declaration-change).

:::row
**Symptom.** A custom screen's form action answers a generic 500, and the log holds `admin.action.misconfigured` with `reason: 'db_not_bound'`.
**Cause.** `config.resolveDb` returned null or undefined.
**Fix.** For `reason: 'db_not_bound'`, this is a code or config change that makes `resolveDb` return the binding. :fact[nup3og]
:::

### `auth.access.refused`

*Helps the reader whose editor is refused on a custom screen decide whether the access map is working or needs a change.*

- `createSectionAction` refuses a session the access map does not admit with `fail(403)`, and it audits and logs the refusal as `auth.access.refused`. :fact[xbjxit]
- The refusal's default message, `You do not have access to this action.`, names no gate, so the record is where you learn which check refused. :fact[xbjxit]
- The record's `reason` names the check that refused: `no_rule` when the map has no rule for the target, `shadowed` when a dynamic route segment hides the matching rule behind a deeper key, and `role` for every other refusal. :fact[m2rk]

:::row
**Symptom.** A custom screen's form action answers that the editor does not have access to the action, and the log holds `auth.access.refused`.
**Cause.** The access map has no rule for the action's target, or its rule does not admit the editor's role, or the action is owner-only and the editor is not the owner.
**Fix.** A refusal of a session the map should not admit is the map working. For one it should admit, this is a code change to the access map or to the action's target. :fact[xbjxit] :fact[1b3ye3]
:::

- See [Restrict admin access: resolve a refusal](restrict-admin-access.md#resolve-a-refusal).

### `admin.action.unaudited`

*Helps the reader whose handler skips its audit call find the path that returns without `ctx.audit`.*

- A `createAdminAction` route that returns without calling `ctx.audit` throws `UnauditedActionError` in development and logs `admin.action.unaudited` at error in production. :fact[07efts]

:::row
**Symptom.** Under the development server the action throws `UnauditedActionError`; in production it completes, leaves no audit record, and the log holds `admin.action.unaudited`.
**Cause.** The handler returned on a path that never called `ctx.audit` and didn't return `fail()`, which is exempt because a rejected request changed nothing. Production logs instead of throwing because a redirect or error response mid-request would be worse than a gap in the audit trail.
**Fix.** This is a code change in the handler: call `ctx.audit` on every successful path before it returns. :fact[07efts]
:::

- See [`createAdminAction` in the SvelteKit reference](../reference/sveltekit.md#createadminaction).

### `audit.sink.call_failed`

*Helps the reader whose action succeeded but left no audit row find the failure in the site's own sink.*

- The site's `event.locals.cairnAuditSink` threw or rejected after the action completed, so the action's result stands and only its audit record was lost. :fact[r3l7eq]

:::row
**Symptom.** An action succeeded but its audit row is missing, and the log holds `audit.sink.call_failed`.
**Cause.** The site's own audit sink threw synchronously or returned a rejected promise when `ctx.audit` called it.
**Fix.** This is a code change to the site's sink, at the failure the record's `error` names. :fact[r3l7eq]
:::

- `audit.sink.call_failed` omits the record's `detail`, because `admin.action.audited` logged the full record one line earlier. :fact[yauo4m]
- A site on the packaged `createD1AuditSink` reads `audit.sink.write_failed` instead, since that sink catches its own failures before `audit.sink.call_failed` fires. :fact[r3l7eq]
- `audit.sink.write_failed` carries the whole truncated record, because it is the only surviving trace of a row the packaged sink failed to write. :fact[yauo4m]
- The `actor` on an `audit.sink.write_failed` record need not be an editor's email when site code calls the sink directly with its own domain events, so a query filtered on editor addresses can miss it. :fact[k085q0]
- See [`createD1AuditSink` in the SvelteKit reference](../reference/sveltekit.md#created1auditsink).

## Site config events

*Introduces the events logged when the committed site config or the access map is wrong.*

- The engine logs these events when the committed site config fails to parse or validate, and when a declared access map leaves a concept or a fixed engine screen without a rule. :fact[8fyoha] :fact[8ciz2s]

### `config.invalid`

*Helps the reader whose admin screens load empty or save with generic copy find the broken committed config.*

- When the committed site config fails to parse or validate, the admin shows an empty list or generic copy while the `config.invalid` record's `error` carries the parser's real message. :fact[8fyoha]

:::row
**Symptom.** The nav editor or the tag-vocabulary screen loads empty, or a settings or vocabulary save answers generic copy, and the log holds `config.invalid`.
**Cause.** The committed config the record's `scope` names fails to parse or validate; the two loads degrade to an empty result and the two saves answer `fail(500)`.
**Fix.** This is a config change: correct the committed config the record's `scope` names, using the message in `error`, and commit it. :fact[8fyoha]
:::

### `config.access_unmapped`

*Helps the reader decide whether an unmapped-screen warning needs a change, and warns that a query scoped to a request window can miss it.*

- The engine checks the access map once, at composition, so `config.access_unmapped` appears at most once per isolate, on a cold start, and a query scoped to a live request window can miss it. :fact[mou1li]

:::row
**Symptom.** A cold start logs one `config.access_unmapped` warning whose `unmapped` field lists concept ids or fixed engine screens.
**Cause.** The adapter's access map declares at least one screen-id key but leaves the listed concepts or fixed screens (`media`, `vocabulary`, `nav`, `settings`) with no screen-id key; an href key never counts as coverage. A map of route keys alone logs nothing, and the check never throws once its shape checks pass.
**Fix.** For a map meant to be exhaustive, this is a code change that adds a screen-id rule for each target `unmapped` names. A map not meant to be exhaustive needs no change. :fact[8ciz2s]
:::

- See [Restrict admin access: make the map exhaustive](restrict-admin-access.md#make-the-map-exhaustive).

## `event.platform` is undefined

*Helps the reader whose code finds no Worker bindings through `event.platform` move to `cloudflare:workers`.*

- Under `@sveltejs/adapter-cloudflare` 8, `event.platform` is undefined everywhere, so code that reads the Worker env through it finds no bindings and no engine record names the failure. :fact[swjwxb]

:::row
**Symptom.** Code that reads a binding or variable through `event.platform` gets undefined under `vite dev`, `wrangler dev`, and in production.
**Cause.** The adapter's worker passes no `platform` to a request.
**Fix.** This is a code change: read the env through `import { env } from 'cloudflare:workers'`, which returns a `wrangler.jsonc` `vars` value under `vite dev` (through the adapter's platform proxy) and under `wrangler dev` alike, with no `process.env` fallback needed. :fact[swjwxb]
:::

## Date-dependent output

*Introduces the date failures that change output with no source change and leave no engine record.*

- Output that reads the clock or the host's time zone can change between days and between machines with no change to the source, and no engine record names it. :fact[ogz5eu] :fact[2r6juw]

### A visual baseline changes every day

*Helps the reader whose visual baseline drifts daily replace the live clock with a pinned date.*

- A visual-regression baseline that renders a component reading `Date.now()` drifts daily with no source change, because the component reads the live clock. :fact[ogz5eu]

:::row
**Symptom.** A visual-regression baseline fails each day although the source has not changed.
**Cause.** A component or route the test renders reads `Date.now()`.
**Fix.** This is a code change: add a site-owned fixed-today reader that takes `CAIRN_FIXED_TODAY` from the Worker env through `cloudflare:workers` and never calls `Date.now()` directly. :fact[ogz5eu] :fact[swjwxb]
:::

### `CAIRN_FIXED_TODAY` yields `Invalid Date`

*Helps the reader whose pinned date renders as `Invalid Date` fix the value.*

- `new Date(env.CAIRN_FIXED_TODAY)` returns `Invalid Date` without throwing when the value is malformed. :fact[yomgrm]

:::row
**Symptom.** The site shows `Invalid Date` where the pinned date belongs.
**Cause.** The `CAIRN_FIXED_TODAY` value is malformed, and the `Date` constructor does not throw on it.
**Fix.** This is a config change: write the value as an explicit instant such as `2026-08-29T00:00:00Z`. :fact[yomgrm]
:::

### A date differs between machines

*Helps the reader whose dates differ by a day between machines format them in a fixed zone.*

- Formatting without a `timeZone` option uses the host's time zone, so one instant can format as different days on different machines. :fact[2r6juw]

:::row
**Symptom.** A baseline or test passes on one machine and fails on another, with dates a day apart.
**Cause.** `Date`'s local-time accessors and `toLocale*String` without a `timeZone` option read the host's zone. A date-only pin also parses as UTC midnight and formats as the previous local day on a machine west of UTC.
**Fix.** This is a code change: format in UTC or one fixed zone, and keep the pin an explicit instant. :fact[2r6juw] :fact[yomgrm]
:::

- See [`toLocaleDateString` on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleDateString).

## The `site-facts.json` check was skipped

*Helps the reader who sees a skipped-check build warning find the adapter error behind it.*

- When the build cannot derive the site facts from the adapter, it reports the `site-facts.json` check as skipped rather than stale and warns once, naming the check and the derivation's error, then continues. :fact[vs9g9e]

:::row
**Symptom.** The build log carries one warning that the `site-facts.json` check was skipped, with an error message in parentheses, and the build succeeds.
**Cause.** The adapter threw for a reason unrelated to the facts, so the build could not compare the committed file with the adapter.
**Fix.** This is a code change in the adapter at the error the warning names; the next build then runs the comparison, and the file is unchecked until it does. :fact[vs9g9e]
:::

- See [Site facts: who writes it and who verifies it](../reference/site-facts.md#who-writes-it-and-who-verifies-it).

## Session and commit records

*Tells the reader building a query or alert that these records report no fault but can be miscounted.*

- These records report no fault, yet a query or alert built on them miscounts unless it allows for when each fires and which field it carries; none needs a code change. :fact[vih1k1] :fact[vq634h] :fact[vq8cta]

### `auth.session.destroyed`

*Shows the reader why a sign-out alert counts fewer records than sign-outs.*

- Sign-out logs `auth.session.destroyed` only when the deleted session row was still live, so a stale cookie or an expired row leaves no record. :fact[vih1k1]

:::row
**Symptom.** An alert on `auth.session.destroyed` counts fewer records than sign-outs.
**Cause.** The record fires only for a live row; a stale cookie or an already-expired row is deleted with no record.
**Fix.** No fix is needed; allow for it in the query. The alert counts live sign-outs only, and its record carries the deleted row's `email`. :fact[vih1k1]
:::

### `auth.channel.session.destroyed`

*Shows the reader how to query an auth channel's sign-outs, which key on a different field.*

- An auth channel logs `auth.channel.session.destroyed` on three paths, only for a live row, and the record carries a `correlationId` in place of the roster subject. :fact[vq634h]
- The three paths are the channel's logout, a confirm clearing the session row an incoming cookie named, and `resolveSubject` revoking a session the site's `verify` hook refused. :fact[vq634h]

:::row
**Symptom.** A query for a channel member's sign-outs by subject finds nothing, or counts fewer records than expected.
**Cause.** The record carries only a `correlationId`, never the roster subject, and an expired row is deleted with no record.
**Fix.** No fix is needed; allow for it in the query, which correlates these records by `correlationId`. :fact[vq634h]
:::

- See [Add a second sign-in group](add-a-second-sign-in-group.md).

### `commit.succeeded` and `commit.failed`

*Shows the reader which field a commit query must filter on for each surface.*

- A commit record carries `concept` for an entry commit and `scope` for a nav, settings, vocabulary, or media commit, never both. :fact[vq8cta]

:::row
**Symptom.** A query on `concept` misses commits to the nav, settings, vocabulary, or media surfaces.
**Cause.** Those commits carry `scope` in place of `concept`.
**Fix.** No fix is needed; allow for it in the query: filter entry commits on `concept` and the other surfaces on `scope`, so a site concept named `media` or `nav` cannot be confused with those surfaces. :fact[vq8cta]
:::

## Site records with `createLogger`

*Shows the reader who writes their own events how `createLogger` gives them the engine's record shape and redaction.*

- The `/log` subpath exports `createLogger`, so a site's own events share the engine's record shape and redaction, while the engine's own `log` instance is exported from no subpath. :fact[eywrq8]
- `createLogger`'s `redactKeys` option unions a site's names with the default redacted keys and cannot narrow them, and a site's records take the redaction described under Record redaction. :fact[avc1a2]
- See [Record redaction](#record-redaction).
- See [`createLogger` in the log reference](../reference/log.md#createlogger).

## See also

*Points the reader to the pages behind these rows and the pages that cover what this one leaves out.*

- The following pages cover the full event table, upgrade breakage, and the seams this page's events come from.
- See [Log events reference](../reference/log-events.md).
- See [Upgrade cairn](upgrade-cairn.md).
- See [Migration notes](migration-notes.md).
- See [Run cairn-audit on your site](run-cairn-audit-on-your-site.md).
- See [Add a custom admin screen](add-a-custom-admin-screen.md).
