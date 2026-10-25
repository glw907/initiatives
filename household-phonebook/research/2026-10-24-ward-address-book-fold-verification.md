# Ward address book design: fold verification

Date: 2026-10-24. Target: `specs/2026-10-24-ward-address-book-design.md` at `abed3e5` ("spec:n"),
against the fold record `research/2026-10-24-ward-address-book-fold.md` ("fold:n"), the three
reviews, the facts record, the base spec (`phonebook/docs/specs/2026-10-07-phonebook-design.md`,
"base:n"), the plan (`phonebook/docs/plans/2026-10-07-phonebook-phases-0-2.md`, "plan:n"),
`~/Projects/servers` at `9e25c9d`, the cached stalwart-cli schema, and Stalwart source at
`v0.16.27`. The verifier had no part in the fold. Read-only throughout.

Counts: 0 blockers, 2 majors, 21 minors (4 of them `optional`).

## Verdicts on the four asks

1. **Closures.** Every blocker and major in the three reviews closes at its cited spec location,
   with three exceptions. First, data M6 and contract m10: the refusal before the old book's delete
   points to a remedy that can't run (M1 below). Second, mechanics 6 is only half closed: `d-ward`
   keeps the account out of the 907.life set but gives it a ward.907.life address (m4). Third,
   mechanics 7: the permissions field the fold names isn't the field the schema exposes, and
   `build-plan` can't carry it yet (m3).
2. **Contradictions and order.** There's no contradiction with the seven owner rulings or with the
   base merge. Inside the spec, the import mapping and its test disagree on a home `TEL` (m10), and
   "test logins never read household data" clashes with the end-to-end flip (m12). On order, the
   step 4 remedy can't build after the seed (M1), and the split between Pass 2 and Pass 3 leaves the
   live parser proof for the new fields with no slot (m11). Also, the fold record still says the
   Workers tier is unrecorded, while the spec now cites it (m16).
3. **Mechanisms.** Each listed mechanism is checked here:
   - **`shareWith` replace: proven.** `JmapRights::acl_set` builds a new `Vec<AclGrant>` from the
     value (`crates/jmap/src/api/acl.rs:23-56`), and the set assigns it whole
     (`addressbook/set.rs:456-458`). `acl_validate` rejects `len > max_shares_per_item` and any id
     outside the Account registry (`acl.rs:242-262`). The "fails loudly" claim isn't supported by
     the stated read-back (M2).
   - **`disabledPermissions` values: partly proven.** `emailSend`, `imapAuthenticate`,
     `davCardGet`, `emailReceive`, and `pop3Authenticate` are in the `Permission` enum. But
     `x:UserAccount.permissions` is `x:Permissions`, a variant of `Inherit`, `Merge`, or `Replace`.
     Only `Merge` and `Replace` carry `x:PermissionsList` (m3).
   - **Writer off when unset: sound as design.** The unit zero-fetch case proves it. The `disabled`
     state collides with the one-hour flag (m6), and the kind of `WARD_BOOK_URL` is unstated (m13).
   - **The 401 stop's daily request: sound.** One failed login a day sits far below
     `authBanRate` 100 a day (facts §4). The stored trial time isn't named (m8).
   - **`d-ward` placement: proven for the 907.life set** (`servers/docs/addresses.md:38`). It's
     open for ward.907.life itself (m4).
   - **The `Blacklist` rename refusal: proven for one path only** (m5).
   - **The empty-D1 guard: sound.** It stalls if the household empties every ward-bound contact
     (m20, `optional`).
   - **The ETag re-read: proven as detection.** A card ETag is the archive's version hash
     (`crates/dav/src/common/mod.rs:107-111`). The remedy on refusal isn't buildable (M1).
   - **RFC 6350 quotes: correct.** Section 3.4 escapes comma, backslash, and newline always, and
     semicolon in compound fields (`ADR`; `ORG` is `component *(";" component)`). Section 3.2 folds
     at 75 octets with multi-octet characters kept contiguous. Section 6.2.2 gives `N` cardinality
     `*1`, section 6.4.1 makes `TEL` free-form text by default, and section 5.6 gives `TYPE` values.
     The spec omits CRLF line endings and the handling of a carriage return in a value (m9).

   The fold's other source checks hold. `preferences()` returns the only entry when there is one
   (`crates/groupware/src/contact/mod.rs:53-56`). The default book is created with one preferences
   entry for the owner (`crates/groupware/src/cache/mod.rs:328-375`). The session adds every
   `secondary_ids()` account with no subscription filter (`session.rs:59-91`;
   `access_token.rs:441-446`). The owner check (`card/update.rs:113-116`) and the delete check
   (`card/delete.rs:93-101`) match. PUT returns `with_etag_opt` on 204 and 201 (`:218`, `:300`).
   The restic retention (`servers-backup:220`) and Workers Paid
   (`self-hosting/specs/2026-10-17-self-hosting-design.md:80`) also hold.
4. **Owner forks.** Fork 1 can be ruled as written, though contract M1's third option was dropped
   without a word (m18, `optional`). Fork 2 can be ruled, but data M5 tied option (b) to how often
   renames happen on the handsets, and the Pass 1 probe that measures it hasn't run. The fork
   should carry the revisit trigger (m17).

## Majors

### M1. The refusal before the old book's delete names a remedy that can't run

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:242-245 (cutover step 4) against plan:1104-1105 (base cutover step 4).
- **Defect.** If a card changed since the export, the tool refuses, and "those cards go back
  through the union". The union is `seed.ts`, whose `apply` runs once, onto a master "confirmed
  empty". By step 4 the seed is live in D1, the phones have polled it, and the web app may hold
  edits, so there is no union left to re-enter. The old book stays read-write for the second
  operator the whole time (`servers/docs/cutover-log.md:108`). The step that guards the
  irreversible delete therefore has no way forward on its likeliest failure. The re-read and the
  collection DELETE also leave a short window open (m21).
- **Proposed fold.** First, extend the household's handset freeze (base cutover step 4) to the old
  book, from the export to the delete, and tell the second operator so. Second, on a refusal, the
  tool prints each changed card's property diff against the export. Geoff applies the diffs in the
  web app, so the change log carries his actor. The tool then takes a fresh export, which replaces
  the old one under the retention ruling, and re-runs the check before it deletes.

### M2. The grant read-back can't catch a missing grant, so "fails the apply loudly" is unsupported

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:104-110 ("The grants"), spec:311-313 (owed read-back rule).
- **Defect.** JMAP `/set` reports a rejected update in `notUpdated` inside a 200 response.
  `acl_validate`'s `MaxSharesExceeded` and `InvalidAccountId` come back that way
  (`addressbook/set.rs:204-208`, `acl.rs:268-277`). The owed read-back fails only "on any sharee
  outside the member set or any right but `mayRead`". After a rejected set, the book keeps its
  previous map, a subset of the members, so the read-back passes. An eleventh member, or a bad id
  from the id probe's fallback, then leaves a new member with no grant, silently, which breaks
  ruling 4.
- **Proposed fold.** The grant step treats any `notUpdated` or `notCreated` entry as a failure.
  The read-back requires `shareWith`'s key set to equal the member set exactly, each key holding
  `mayRead` alone. A `--dry-run` test, or a probe row, covers an eleventh sharee and an unknown id.

## Minors

### m1. The grant step must run on every `stalwart-apply` path

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:310-311.
- **Defect.** "Called on both the bootstrap and the normal branch after the final restart". But
  `household` isn't in `build-plan`'s output (`build-plan:27-35`), so flipping it leaves the plan
  hash unchanged, and `stalwart-apply` takes the "nothing changed" path (`stalwart-apply:159-162`),
  where nothing restarts. Read literally, an opt-out never revokes its grant, and the end-to-end
  flip of `probe2` (spec:278-279) never takes effect.
- **Proposed fold.** "Called on all three paths, like `ensure_certificate`, whether or not the plan
  changed."

### m2. The probe sets its grant "by hand", not the way `stalwart-apply` will

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:118-119, spec:126, spec:309-310.
- **Defect.** The probe doesn't say who sets the grant or how. Only the owner setting it through
  JMAP `AddressBook/set` as a non-admin User proves the path the design uses. That path covers the
  owner's right to share (`set.rs:194-195` applies to sharees, but the owner's role permissions
  still gate the method) and the id format, which the third probe row tests. The owed submission
  check confirms CardDAV and JMAP contacts under the disabled set, but not that `AddressBook/set`
  with `shareWith`, and the fallback's principal lookup, still succeed.
- **Proposed fold.** The probe sets the grant as `probe` through `AddressBook/set` `shareWith`. The
  owed check adds a `shareWith` set and the principal lookup under `phonebook`'s disabled set.

### m3. The permissions field is a variant, and `build-plan` can't emit it

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:91-92, spec:309; fold:44-45.
- **Defect.** The schema types `x:UserAccount.permissions` as `x:Permissions`, a variant of
  `Inherit`, `Merge` ("combined with inherited"), or `Replace`. Only the last two hold
  `disabledPermissions`, so the fold's "`x:UserAccount.permissions` takes `x:PermissionsList`"
  skips a level. Also, `build-plan` emits only `name`, `domainId`, `roles`, `credentials`, and
  `aliases` (`build-plan:27-35`), and nothing reads a permissions entry from `accounts.json`.
- **Proposed fold.** State `{"@type": "Merge", "disabledPermissions": {...}}`. Add to "Owed to the
  plan" an `accounts.json` permissions field that `build-plan` passes through, with its unit case.

### m4. `d-ward` gives the account a deliverable ward.907.life address

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:87-90.
- **Defect.** `d-ward` is a local Stalwart domain (`plan.ndjson:9`), and `ward.907.life` has A and
  AAAA records but no MX, so RFC 5321's implicit MX routes `phonebook@ward.907.life` to ward. The
  spec's quote ("There is no catch-all") covers 907.life only. An inbox nobody reads, which
  `mailbox: false` hides from the counts, collects whatever reaches it. Mechanics 6 also asked to
  record the account in `addresses.md`, and the owed list omits that.
- **Proposed fold.** Put `emailReceive` in the disabled set, and add a `rcpt-check.sh` row that
  expects refusal for `phonebook@ward.907.life`. If the probe shows `emailReceive` doesn't gate
  RCPT, record the address as accepted, with the reason. Add the `addresses.md` row to the owed
  list.

### m5. The `Blacklist` rename refusal covers one path of four

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:158-162; base:137.
- **Defect.** The predicate is keyed to the group, and only renaming away from `Blacklist` is
  refused. Three other paths remain:
  - Deleting the `Blacklist` group in the web app leaves its contacts in no group, which makes them
    ward-bound.
  - Renaming another group to `Blacklist` takes its contacts off ward.
  - A handset upload naming `Blacklist` when the master lacks it creates the group (base:137).
- **Proposed fold.** The web app refuses to rename a group to or from `Blacklist`, and to delete
  `Blacklist`. The predicate matches the group by name, the name the phones use, so the
  handset-created case behaves the same. One unit case covers each path.

### m6. `disabled` raises the one-hour flag from the Pass 2 deploy to cutover

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:173-174, spec:206-208.
- **Defect.** "No `ok` run in an hour is flagged". Every run records `disabled` until cutover
  step 2, so the Phones page flags ward for the whole interval and teaches the household to ignore
  the flag.
- **Proposed fold.** `disabled` shows as "ward sync off" and doesn't raise the flag. A unit case
  covers it.

### m7. A failed PROPFIND, and serial timeouts, are unhandled

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:175-176, spec:181-185,
  spec:267-271.
- **Defect.** The reconcile takes its preconditions from its own PROPFIND, but nothing says what a
  5xx, a timeout, or a 403 on the PROPFIND does. The integration list gives `partial` for a 5xx or
  a timeout, which only fits per-card writes. When ward hangs, serial requests with a 10-second
  timeout each can outlast the 15-minute scheduled limit on a first fill of about 90 or more cards.
- **Proposed fold.** A PROPFIND failure records `error`, writes nothing, and ends the run. The
  first timeout ends the run's remaining writes, as a 401 does, without setting the stop. The
  integration list adds a PROPFIND 5xx case.

### m8. The stop's daily trial needs a stored time

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:196-205.
- **Defect.** "One request a day" needs the time of the last trial, but `ward_sync` names only the
  run time, result, error, and stop field. The run time advances every 15 minutes, so it can't
  serve.
- **Proposed fold.** The stop field holds the password hash and the last trial's time. A trial
  runs when that time is more than 24 hours old.

### m9. Line endings and carriage returns aren't specified

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:154-156, spec:251-254.
- **Defect.** RFC 6350 section 3.2 delimits content lines with CRLF. A browser submits a textarea's
  newlines as CRLF, so a note arrives holding CR. Escaping only LF as `\n` leaves a bare CR in the
  value, which a strict parser may read as a line break, the injection the M5 fold exists to stop.
- **Proposed fold.** Normalize CRLF and a lone CR to LF before escaping, and emit CRLF line
  endings. The unit case puts a CRLF in the note.

### m10. The import mapping and its test disagree

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:232-235 against spec:260-262.
- **Defect.** Step 1 maps "any other `TEL`" to the other slot, so a home `TEL` maps. The unit case
  lists "a home `TEL`" as an overflow drop. Step 1 also doesn't say how `ADR`'s post-office-box and
  extended components, which the data model doesn't hold, or a ward `EMAIL`'s `TYPE` map to the
  home, work, and other labels.
- **Proposed fold.** Choose one reading. With step 1 as written, the unit case uses a second home
  `TEL` after an other. Add "`ADR` components 1 and 2 go to the drop list" and "`EMAIL;TYPE=home`
  and `work` map to their labels; anything else is other."

### m11. The Pass 2 and Pass 3 split leaves the new fields unproven against Stalwart

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:23-25, spec:273-275,
  spec:326-330.
- **Defect.** The renderer, push, and reconcile land in Pass 2. The four fields land in Pass 3. The
  live reconcile of the probe book runs in the `servers` task between them. It can't render
  `EMAIL`, `ADR`, `ORG`, or `NOTE` if those don't exist yet, so the first time Stalwart parses them
  is cutover step 2, against the live book. Two more items have no pass: the ward line on the
  Phones page, which is UI work, and the merge test, which needs a web-added email.
- **Proposed fold.** The live probe-book reconcile runs again in Pass 3, before cutover step 2,
  with the full fixtures. Name the pass for the ward line (Pass 3) and for the merge test.

### m12. "Test logins never read household data" against the end-to-end flip

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:109-110 against spec:278-279.
- **Proposed fold.** "Test logins don't read household data, apart from the one end-to-end apply,
  which `probe2`'s restored flag ends."

### m13. The kind of `WARD_BOOK_URL`, and the login it pairs with, are unstated

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:103, spec:173-174, spec:236-237.
- **Defect.** If `WARD_BOOK_URL` is a `wrangler.jsonc` var, it's committed and goes live with a
  deploy, not at cutover step 2. A deploy also resets dashboard-set vars. The sign-in name
  (`phonebook@ward.907.life`) has no named setting.
- **Proposed fold.** Make both `WARD_BOOK_URL` and the login Worker secrets, set by
  `wrangler secret put` at step 2, so no deploy carries them. Or make them committed vars and name
  the deploy that enables the writer.

### m14. The amends list misses the cron trigger and the migration

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:297-305.
- **Proposed fold.** Add `wrangler.jsonc` `triggers.crons: ["*/15 * * * *"]` under Task 2.1. Add the
  D1 migrations for the ward rows (Pass 2) and the four fields (Pass 3) under their tasks.

### m15. The reconcile's reliance on matching ETags isn't cited, and a missing ETag is unhandled

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:191.
- **Defect.** The design holds only if the ETag a PUT returns equals the one the next PROPFIND
  reports. It does: both are `"<archive version hash>"` (`crates/dav/src/common/mod.rs:107-125`).
  The spec doesn't cite that, though. `with_etag_opt` (`card/update.rs:218`, `:300`) also allows a
  response with no ETag, and recording none would make every run PUT the card again.
- **Proposed fold.** Cite `common/mod.rs:107-125`. If a PUT returns no ETag, record the hash with
  no ETag, and let the next run adopt the PROPFIND's ETag when the hash matches.

### m16. The fold record is stale on the Workers tier

- **Severity:** minor. **Tag:** `correctness`. **Location:** fold:51-52, fold:127-128.
- **Defect.** The record says "The account's tier is not recorded anywhere read" and "Owed to the
  plan: record the tier". The spec, at spec:316-318, cites Workers Paid from the self-hosting spec
  and owes nothing.
- **Proposed fold.** Update both lines to match the spec.

### m17. Fork 2 needs the probe's evidence on rename frequency

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:41-53.
- **Defect.** Data M5 recommends (a) "Choose (b) if the probe shows renames are routine on the
  handsets". Pass 1, which measures that, hasn't run (`phonebook/docs/STATUS.md`), and the fork
  dropped the condition. Geoff can rule (a) now, but he can't see what would reverse it. Option (b)
  also carries no estimate.
- **Proposed fold.** Add a line: "Revisit if the Pass 1 probe shows handset renames are routine."
  Give (b) a figure in minutes.

### m18. Fork 1 dropped an option without saying why

- **Severity:** minor. **Tag:** `optional`. **Location:** spec:28-39.
- **Defect.** Contract M1 offered a third option: an encrypted blob in the age store, kept
  indefinitely. The fork lists two.
- **Proposed fold.** Add one clause on why the third option was dropped, or restore it.

### m19. Members' sessions list the `phonebook` account with mail capabilities

- **Severity:** minor. **Tag:** `optional`. **Location:** spec:112-114, spec:239-241.
- **Defect.** The session gives each secondary account the member's own capability set
  (`session.rs:84-89`), so Hylki or another JMAP mail client may show an empty "phonebook"
  account. Step 3 checks address books only.
- **Proposed fold.** Step 3 also notes whether each mail client lists a `phonebook` account.

### m20. The empty guard stalls if the household empties ward-bound contacts

- **Severity:** minor. **Tag:** `optional`. **Location:** spec:194-195.
- **Defect.** If every contact is deleted, or moved into `Blacklist`, every run records `error`
  and ward keeps the stale cards.
- **Proposed fold.** Name the operations-guide step: one confirmed, manual reconcile from the
  workstation that bypasses the guard.

### m21. A window remains between the ETag re-read and the delete

- **Severity:** minor. **Tag:** `optional`. **Location:** spec:242-246.
- **Defect.** An edit made between the re-read and the collection DELETE is lost. M1's freeze
  closes the window in practice.
- **Proposed fold.** None beyond M1's freeze.
