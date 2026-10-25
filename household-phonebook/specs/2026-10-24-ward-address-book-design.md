# Phonebook and the ward address book: design

Date: 2026-10-24. Status: approved in chat by Geoff on 2026-10-24, before review; revised by the
three-lens review fold and its verification (`research/2026-10-24-ward-address-book-fold.md`),
then by Geoff's rulings on its two forks and his cutover change, 2026-10-24.
Amends `docs/specs/2026-10-07-phonebook-design.md` in `phonebook`. Facts:
`research/2026-10-24-ward-address-book-facts.md` (cited below as "facts §n"). Stalwart source is
cited at tag `v0.16.27`.

## Brief

The phonebook becomes the only place the household adds or edits a shared contact. Today the
Global Address Book sits in Geoff's account on ward, the Stalwart mail server, and both
mailbox holders can edit it. After this change, the phonebook Worker is the book's only writer,
and every User in the `servers` repo's `accounts.json` sees the book read-only unless its entry
opts out. A new account added there later gets read access at its first apply.

Approving this changes four things. In `phonebook`, a contact gains emails, a postal address, an
organization, and a note, and the Worker writes each contact to ward as a vCard. In `servers`, a
new contacts-only `phonebook` account owns the book and grants each member read access directly.
At cutover, the new book's entries come entirely from the phones, and the old book moves to a book
in the second operator's account, "Household list (old)", before it is deleted from Geoff's
account. The web app takes Survey from its tagged package.

Two consequences follow from the cutover. The new book starts with each contact's name, numbers,
and group from the phones; its emails, addresses, organizations, and notes start empty and are
filled in the web app. And once the old book leaves Geoff's account, his mail-filters
known-correspondent list loses its emails: about 4, on 4 of the 20 cards in the backup taken
before the 2026-10-22 cleanup, none of which is in his Personal book's backup. The second
operator's list keeps them through the moved book.

The probe (Pass 1) doesn't change. Pass 2 gains the ward writer, left off in production until the
cutover turns it on. Pass 3 gains the new fields and the ward half of the cutover, and a `servers`
task between them builds the account, the book, and the grants. Risk class `auth-data` with the
`live-account` flag: the work adds a credential and writes to a live mail server.

## Rulings this design carries

All Geoff, 2026-10-24, in chat.

1. The phonebook is the only way to add or edit an entry in the Global Address Book.
2. A contact carries phones, emails, a postal address, an organization, and a note. Photos are
   not kept.
3. Read-only enforcement takes the most idiomatic Stalwart approach (Claude's call, below).
4. Every member created on Stalwart can see the book. Claude's reading under ruling 3: every
   `role: "User"` entry in `accounts.json` that doesn't set `"household": false`. An account made
   by hand in Stalwart's admin gets no grant; the repo is already the only writer of accounts.
5. Household members A and B are not people: they were two unused Fastmail logins. Ward has
   two people today, Geoff and the second operator. (The record fix belongs to
   `conductor-servers`.)
6. The design as a whole: approved.
7. The book keeps the name "Global Address Book".
8. A handset rename or delete may drop the web-only fields: "Accept, undo by hand." The change log
   records every field, and the operations guide names the undo. Revisit if the Pass 1 probe shows
   handset renames are routine.
9. "The old global address book should be moved into a book in [the second operator]'s account. The new entries
   should come entirely from the phone." The moved book is the second operator's only, with no
   share back to Geoff. His own imported 20-card copy is still deleted as `conductor-servers`
   scheduled, so after cutover he holds one copy, the moved one.

The moved book is named "Household list (old)" (Claude's proposal, accepted by Geoff on 2026-10-24),
so the second operator's client never shows two books called "Global Address Book". The move
signs in as the second operator with his stored machine credential, as the restore drill already
does (`servers/docs/restore-drill-log.md:162`, "a JMAP login works for each of 4 mailbox
accounts"); the cutover sitting tells him beforehand.

The Survey change follows the `survey-house-style` initiative (approved 2026-10-22), under which
`cairn-themes` gives up `survey-theme/` and each repo pins Survey by git tag.

## Where it runs

Nothing new is hosted. The phonebook Worker on Cloudflare stays the master, with D1 as the
store, and ward's Stalwart already serves the household's contacts to every mail client. The
Worker writes to ward over HTTPS, the same path the zone's monitor Worker already uses
(facts §5). If ward is down, the web app and the phones keep working and ward catches up at
the next reconcile. If Cloudflare is down, ward keeps serving the last cards it was given.
D1 is the only authority, so either side's restore ends with the next reconcile making ward
match D1.

## Ward: ownership and sharing

- **Owner.** A new User account `phonebook` on `d-ward` (login `phonebook@ward.907.life`,
  `mailbox: false`, `"household": false`, password `STALWART_PASSWORD_PHONEBOOK` from the age
  store). `d-ward` keeps it out of the 907.life accepted set (`servers/docs/addresses.md:38`, "There
  is no catch-all"). `mailbox: false` keeps it out of the status counts, drills, and mail-filters
  (facts §3). Its `permissions` (the schema's `x:Permissions` variant) is `{"@type": "Merge",
  "disabledPermissions": ...}`, the `x:PermissionsList` that removes mail access, including
  `emailSend`, `emailReceive`, and `imapAuthenticate`; the plan names the full set. `ward.907.life`
  is a local domain with an A record and no MX (`plan.ndjson:9`, `dig`), so RFC 5321's implicit MX
  would route `phonebook@ward.907.life` to ward: `emailReceive` is disabled for that reason, and
  `rcpt-check.sh` gains a row expecting refusal. If `emailReceive` doesn't gate RCPT, the address
  is recorded as accepted in `addresses.md`, with the reason. Only the Worker and `stalwart-apply`
  sign in as it.
- **Why a separate account and no group.** A member passes Stalwart's owner check on a collection
  its group owns (`card/update.rs:113-116`), and Stalwart creates a default book for any account it
  builds resources for when that account has none (`crates/groupware/src/cache/calcard.rs:112-124`).
  A member's discovery walks its groups' accounts, so a group would gain a default book every
  member could write. Grants go to each member instead.
- **The book.** `stalwart-apply`, as the `phonebook` login, reads its books with JMAP
  `AddressBook/get`, which creates the default book on first access, and keeps exactly one: that
  default, named "Global Address Book". A book with one preferences entry shows that entry's name
  to every account (`crates/groupware/src/contact/mod.rs:53-56`), so members see the same name.
  The Worker's `WARD_BOOK_URL` holds its href.
- **The grants.** `stalwart-apply` then sets the book's whole `shareWith` map to `{<id>: {mayRead:
  true}}` for every member under ruling 4, and reads it back. A set replaces the map
  (`crates/jmap/src/addressbook/set.rs:456-458`), so the write is idempotent and an entry removed
  from `accounts.json` loses its grant at the next apply. Stalwart accepts any account id in its
  registry and refuses more than `maxShares`, 10 by default (`crates/jmap/src/api/acl.rs:242-262`,
  facts §2), but it reports a refusal in the 200 response's `notUpdated`, leaving the old map in
  place (`set.rs:204-208`). So any `notUpdated` or `notCreated` entry fails the apply, and the
  read-back fails unless `shareWith`'s keys equal the member set exactly, each holding `mayRead`
  alone. `probe` and `probe2` set `"household": false`: test logins don't read household data,
  apart from the one end-to-end apply, which `probe2`'s restored flag ends. The admin account is
  `role: "Admin"` and is skipped.
- **Enforcement.** A member's create, update, or delete then gets 403 (facts §2).
- **Discovery.** A grant puts the owner in the member's `access_to` (`access_token.rs:76-120`),
  and the JMAP session lists every such account with the contacts capability
  (`crates/jmap/src/api/session.rs:59-91`), so mail-filters reads the book with no change.

### Probes before the ward task builds

Run on the probe domain: `probe` owns a probe book with at least two cards and grants `probe2`
read through `AddressBook/set` `shareWith`, the path `stalwart-apply` uses. Teardown removes the book's cards and the grant and checks nothing is
left. Nothing of Geoff's is read or written.

| Probe | Pass | Fallback |
| --- | --- | --- |
| A per-user read grant reaches the member | `probe2`'s `addressbook-home-set` lists the book, a multiget returns every card, the book shows the name the owner set, and `probe2`'s JMAP session lists `probe` with the contacts capability | Stop: the design returns to Geoff |
| A read-only member gets 403 | A create, an update, and a delete, each aimed at an existing card with its current ETag, all get 403, and the book's ETags are unchanged | Stop: the design returns to Geoff |
| Account ids match | The id `stalwart-cli query Account` gives for `probe2` is the id `shareWith` takes | `stalwart-apply` reads ids from the JMAP principal list instead |
| `If-None-Match: *` on create (facts 10) | 201, then 412 | The Worker creates without it, and the reconcile settles a race |

The facts' other open items: 6 (assisted discovery) is covered by cutover step 3's add-by-URL
fallback, 7 (the group's address) and 11 (membership timing) are moot without a group, 8 (the
login-name ban) is covered by the 401 stop, and 9 (the current share's ACE) is moot once the old
book is deleted.

## The phonebook: data model

The spec's `contacts` table gains these fields. Each is optional.

| Field | Shape | vCard 4.0 property |
| --- | --- | --- |
| Emails | Up to five, each an address and a label (home, work, other) | `EMAIL;TYPE=home`, `EMAIL;TYPE=work`, or `EMAIL` with no `TYPE` for other |
| Postal address | One: street, locality, region, postal code, country | `ADR` |
| Organization | Text | `ORG` |
| Note | Text, at most 2,000 characters | `NOTE` |

RFC 6350's `TYPE` grammar names `work` and `home` and, for `TEL` only, the telephone types
(section 5.6), so "other" carries none. The phone numbers and the group keep the spec's shapes. The office, mobile, and
other numbers are `TEL;TYPE=work`, `TEL;TYPE=cell`, and `TEL;TYPE=voice`, as the default text
value (RFC 6350 section 6.4.1, "By default, it is a single free-form text value"), so a feature code
like `*97` stays valid. A ten-digit North American number renders as `+1 907-555-0123`, the form
Geoff's cards already use (`servers/docs/cutover-log.md:107`). The group renders as `CATEGORIES`.
`FN` is the display name and `N` is omitted (cardinality `*1`, section 6.2.2), since the phonebook
keeps one display name. The vCard UID is the contact's ID, and its href is `<id>.vcf`.

Every text value is escaped per RFC 6350 section 3.4: a backslash, a comma, and a newline (as
`\n`) always, and a semicolon in the compound `ADR` and `ORG`. Lines fold at 75 octets per section
3.2, never inside a multi-octet character.

**The Blacklist stays off ward.** A blocked caller is not a household contact, and mail-filters
would count their email as a known correspondent. One function decides whether a contact belongs
on ward, and the push and the reconcile both call it: a contact in the `Blacklist` group does not.
Moving a contact into the Blacklist deletes its card; moving it out writes one. The predicate
matches the group by the name the phones use, so a `Blacklist` group a handset upload creates
behaves the same. The web app refuses to rename a group to or from `Blacklist` and to delete
`Blacklist`, each with a unit case.

**A handset upload changes only what a phone holds.** The merge in the 2026-10-07 spec reads
and writes only the name, the numbers, and the group, and its base and served rows hold only
those fields. A handset edit never clears or rewrites an email, an address, an organization, or a
note. A handset delete, and a handset rename (a delete and an add in the base merge), drop them
(ruling 8). The change log's before values carry every field, the new ones
included, so a dropped value can be restored by hand.

## The phonebook: writing to ward

- **Off until configured.** With `WARD_PASSWORD` or `WARD_BOOK_URL` unset, the push and the
  reconcile make no request and record `disabled`. Production stays unset until cutover step 2.
- **One at a time.** Ward requests in one invocation run serially, each with a 10-second
  `AbortSignal.timeout`. The first 401 ends the invocation's ward work.
- **Push.** After each web or handset commit that changes a contact, the Worker pushes that card
  with `ctx.waitUntil`: a PUT with `If-Match` on the ETag it last recorded, or a DELETE. The push is
  best-effort, bounded by `waitUntil`'s 30 seconds (facts §5). The seed loads outside the Worker,
  so it never pushes.
- **Reconcile.** A Cron Trigger at `*/15 * * * *` reads the book's hrefs and ETags (one PROPFIND,
  depth 1) before it reads D1, then renders every ward-bound contact. A card needs a PUT when it is
  missing, when ward's ETag differs from the recorded one (changed or restored on ward), or when the
  render's SHA-256 differs from the hash of the card last written (changed in D1, including a lost
  push or a group rename). A card D1 doesn't hold gets a DELETE. DELETEs go first, so a stray card
  holding a contact's UID is cleared before its create. Preconditions come from the run's own
  PROPFIND. There is no multiget: Stalwart stores a parsed card and re-serializes it on read
  (`card/update.rs:157`, `:201`), so its bytes never match the render. It is the authority: a lost
  push, a member's write that got through, or a restore on either side is repaired within 15
  minutes.
- **Statuses.** A PUT records the ETag its 201 or 204 carries (`card/update.rs:218`, `:300`). That
  ETag and the one a later PROPFIND reports are the same archive version hash
  (`crates/dav/src/common/mod.rs:107-125`), which the comparison relies on. If a PUT returns no
  ETag, the row keeps the hash with no ETag, and the next run adopts the PROPFIND's ETag when the
  hash matches, rather than writing again. A
  DELETE's 404 counts as done (`card/delete.rs:70-72`). A 412 is left to the next run, since it means
  either a lost precondition or a card Stalwart refuses (facts §6).
- **The empty guard.** A run that reads no ward-bound contacts while ward holds cards writes
  nothing and records `error`. The base spec guards uploads the same way.
- **State.** Each contact gains a ward row: the recorded ETag, the hash of the card last written,
  and the last write's status. Rows are upserts that skip a contact no longer present. One
  `ward_sync` row holds the last run's time, its result (`ok`, `partial` with the count of failed
  writes, `error`, or `disabled`), its error, and a separate stop field.
- **The 401 stop.** On a 401, the Worker sets the stop with the SHA-256 of the password it used.
  While stopped, the push makes no request and the reconcile makes one request a day. The stop
  clears when that request succeeds or the secret's hash differs. Stalwart bans a source after 100
  failed logins a day, for 24 hours on ward, and tracks the login name as well as the address
  (facts §4), so a retry loop would ban the Worker and could ban the monitor Worker's address with
  it. Only a run that clears the stop or a 401 writes the stop field.
- **What the app shows.** The Phones page gains a ward line: the last reconcile, its result, the
  contacts whose last write failed, and a stop in red. No `ok` run in an hour is flagged like a
  silent phone.
- **Logs.** A ward log line carries the contact ID, the method, the status, and for a 412 the
  error's precondition name (such as `SupportedAddressData`), never a card body or a header,
  following the spec's log rule.
- **The secret.** The Worker's `WARD_PASSWORD` is the same value as `STALWART_PASSWORD_PHONEBOOK`,
  set from the age store. A rotation goes ward first (`secret-set.sh`, then the ward render and
  `stalwart-apply`), and the Worker's secret last, which clears any stop.

## mail-filters

mail-filters reads every contacts account in each mailbox login's JMAP session (facts §7), and a
grant lists the `phonebook` account there (above), so the script doesn't change. After cutover step
5, the cutover checks, for every `mailbox: true` account, that an address held only in the new book
appears in that account's generated known-correspondent list.

## Cutover

The 2026-10-07 spec's cutover gains these steps.

1. The seed is the phone exports only, as the base cutover runs it. No card from the old book
   enters D1.
2. After the seed loads, the conductor sets `WARD_PASSWORD` and `WARD_BOOK_URL` in production and
   runs a reconcile. The tool checks that the book's set of UIDs equals D1's set of ward-bound
   contact IDs.
3. Each household client shows the new book through `addressbook-home-set` (facts §2), named by its
   owner path, with its card count and names shown. If a client doesn't list it, the book is added
   by URL.
4. The old book moves to the second operator's account. A cutover script signs in as `operator2` (the second operator's login),
   reading `STALWART_PASSWORD_OPERATOR2` from the age store without printing it, and stops at the
   first 401 so his login can't reach the auto-ban. It creates "Household list (old)" in his
   account with an extended MKCOL, which only the owner may do (`crates/dav/src/card/mkcol.rs:56`),
   and PUTs every card of Geoff's Global Address Book into it, which his read-write share on that
   book lets him read (`servers/docs/cutover-log.md:108`). UIDs need be unique only within a book
   (`card/update.rs:252-258`), so each card keeps its UID. The script records the source's ETags
   as it reads, then checks that the moved book's count and set of UIDs equal the source's. The
   second operator is told not to edit the old book during the minutes the copy runs.
5. After Geoff confirms, the script re-reads the source's ETags and refuses if any card was added,
   changed, or removed since the copy; on a refusal it copies again and re-checks. Only then is the
   source deleted as Geoff, with `STALWART_PASSWORD_GEOFF` read the same way, by its href, never by
   name; an owner passes the collection delete's check
   (`card/delete.rs:93-101`). The moved book is the backup, and ward's restic snapshots are the
   second copy (`roles/mail-backup/servers-backup:220`, `--keep-within 35d`).

## Testing

- **Unit.** Rendering a contact to vCard 4.0 and back for every field; an awkward name and note
  holding `&`, quotes, a backslash, a comma, a semicolon, a newline, and an accented character on a
  fold boundary; an empty field; and a non-North American number. Removing the newline escape
  fails a test. The reconcile's decisions: a D1 edit with ward's ETag unchanged (a lost push), a
  ward-side change with D1 unchanged, a group rename, a card D1 lacks, a Blacklist move each way,
  and an unchanged card; dropping the hash comparison fails the first and third. The empty guard.
  With the writer unconfigured, and while stopped, the push and the reconcile make zero fetches,
  apart from the stopped reconcile's daily request. A 401 on the first of several writes makes
  exactly one request. The stop releases on a successful daily request and on a changed hash.
  The move script stops at the first 401, and refuses the delete when a source ETag changed after
  the copy.
- **Merge.** The served row is recorded after the web adds an email; the upload edits a number on
  that contact. The number changes and the email, address, organization, and note stay. Letting
  the merge compare the new fields fails the test. A handset delete's change-log row holds the
  email.
- **Integration**, against a fake CardDAV server in the Workers test runtime, each leaving the
  `contacts` and `changes` tables untouched: a 412 gives `partial` with the ETag kept, and the flag
  rises after an hour of it; a 401 sets the stop with the hash and makes no further request; a 5xx
  or a timeout gives `partial` with the ETag kept; a push dropped after commit is repaired by the
  next run; a push and a reconcile interleaved end matching D1; and a web edit whose push fails
  still commits and returns its normal response.
- **Live, on the probe domain.** The probes above, then a reconcile of the probe book from a test
  D1 holding the unit fixtures, read back, which shows Stalwart's parser accepts the real output.
  It runs from the workstation against `probe`'s book, never through the production Worker: in
  the `servers` task for the Pass 2 fields, and again in Pass 3, before cutover step 2, with the
  full fixtures including `EMAIL`, `ADR`, `ORG`, and `NOTE`. The merge test and the Phones-page
  ward line land in Pass 3, once the fields and the UI exist.
- **End to end.** At cutover: a web edit appears in Geoff's GNOME Contacts within 15 minutes,
  a handset edit appears there after its upload, and a write from GNOME Contacts gets an error.
  `probe2`'s `household` flag is
  flipped for one apply: it reads every card and gets 403 on a write, and the flag is restored.

## Out of scope

- Geoff's Personal book, his mobile contacts, the second operator's own imported copy of the list
  (deleted by `conductor-servers`), the moved book once it lands, and any other book on ward.
- Photos and any vCard field not listed above.
- Importing the old book's cards or fields into D1. Writing to the household book from anything
  but the Worker, and reading ward back into D1. A change made on
  ward is overwritten, never imported.

## Survey

The UI takes Survey from its package, not from `cairn-themes`. Task 3.1 installs
`github:glw907/survey#v1.3.0` and follows `DESIGN.md`'s recipe for a plain app. The pinned tag in
`package.json` replaces Task 3.1's `check-core.sh` byte-identical check. The repo's CLAUDE.md
Survey section and the plan's Pass 3 dependency say the same. `.vale.ini` moves to the v1.3.0
overlay.

## Base spec and plan sections this amends

- Base spec "Data model": a contact gains the four fields, and D1 gains the ward rows and
  `ward_sync`. Its success criteria gain one: a web or handset change reaches ward within 15
  minutes.
- `phonebook` CLAUDE.md: the secrets invariant lists `WARD_PASSWORD`; the Survey section changes.
- Plan Task 2.1: the Worker entry exports `scheduled` as well as `fetch`.
- Plan Task 2.2: `BaseRow` and `ServedRow` carry only phone-held fields.
- Plan cutover step 4: `seed.ts` reads the phone exports only.

## Owed to the plan

- The full `disabledPermissions` set for `phonebook`, an `accounts.json` permissions field that
  `build-plan` passes through (it emits only `name`, `domainId`, `roles`, `credentials`, and
  `aliases` today, `build-plan:27-35`) with its unit case, and a check under that set that a
  submission login fails while CardDAV, JMAP contacts, an `AddressBook/set` of `shareWith`, and the
  principal lookup succeed. The `phonebook` row in `servers/docs/addresses.md`.
- In `stalwart-apply`, the book and grant step as one function called on all three paths
  (bootstrap, applied, and "nothing changed", `stalwart-apply:150-162`), like
  `ensure_certificate`, since flipping `household` leaves the plan hash unchanged. `--dry-run`
  prints the grant and writes nothing; a test covers an eleventh sharee and an unknown id.
- The probe sets its grant as `probe` through `AddressBook/set` `shareWith`, the path
  `stalwart-apply` uses.
- `disabled` shows as "ward sync off" and doesn't raise the one-hour flag, with a unit case.
- A PROPFIND failure records `error`, writes nothing, and ends the run; the first timeout ends the
  run's remaining writes without setting the stop; an integration case for a PROPFIND 5xx.
- The stop field holds the password hash and the last trial's time; a trial runs when that time is
  more than 24 hours old.
- The renderer normalizes CRLF and a lone CR to LF before escaping and emits CRLF line endings
  (RFC 6350 section 3.2); the unit note holds a CRLF.
- `WARD_BOOK_URL` and the ward login are Worker secrets, set by `wrangler secret put` at cutover
  step 2, so no deploy carries or resets them.
- Plan Task 2.1 adds `triggers.crons: ["*/15 * * * *"]` to `wrangler.jsonc`, and the D1 migrations
  for the ward rows (Pass 2) and the four fields (Pass 3) sit under their tasks.
- The secret's rows in `secrets/templates/ward/stalwart.env` and `secrets/registry.md`, and the
  ward render before `stalwart-apply`.
- None for the Workers tier: the account is on Workers Paid
  (`initiatives/self-hosting/specs/2026-10-17-self-hosting-design.md:80`, "The Cloudflare account
  is already on Workers Paid"), so a run's 10,000-subrequest limit covers the first fill.
- One line in the mail-server restore runbook (`servers/docs/runbook.md`): after a restore, run
  `stalwart-apply`, and delete the old book by href if it came back.
- The cutover task: the move script (the count it reports replaces a separate live count of the
  old book, which `cutover-log.md:107` put at 18 on 2026-10-22), a check that the second operator
  holds one old copy, the moved book, the synthetic contact the mail-filters check uses, and each
  host's client (pavilion's GNOME Online Accounts, and whether thinkpad-x1 has one).

## Estimate

About 315 path minutes added across three passes: the ward task in `servers` with its probes
(90), the vCard renderer, push, reconcile, and stop in Pass 2 (150), and the new fields and the
cutover's ward steps in Pass 3 (75, down from 90 since the ward-card import and its review are
gone and the move script is smaller). The plan sets the figures per task.

## Pre-flight

No new step needs Geoff before Pass 2. Claude generates `STALWART_PASSWORD_PHONEBOOK` with
`secret-set.sh`. The cutover sitting adds two of Geoff's acts: confirming the old book's
deletion, and checking his clients. The second operator holds off edits to the old book while it
is copied, and then checks that his client shows both "Global Address Book" and "Household list
(old)".
