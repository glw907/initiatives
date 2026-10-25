# Ward address book design: data integrity and failure-risk review

Date: 2026-10-24. Lens: data integrity and failure risk. Target:
`specs/2026-10-24-ward-address-book-design.md` at `c3d4579` (cited as "spec:n"), amending
`phonebook/docs/specs/2026-10-07-phonebook-design.md` ("base:n"). Facts:
`research/2026-10-24-ward-address-book-facts.md` ("facts §n"). Stalwart source read at `v0.16.27`
(`aa47d8e`), the tag the facts cite. `servers` read at `9e25c9d`.

Counts: 1 blocker, 7 major, 10 minor (3 of them `optional`). One OWNER FORK, inside M5.

## Blocker

### B1. The reconcile cannot see a lost push, the case it exists to repair

- Severity: blocker. Tag: `correctness`. Location: spec:119-126.
- Defect: the reconcile multigets only "any card whose ETag differs from the one D1 last
  recorded" (spec:120-121), then "writes the differences". A push that never landed (cancelled
  at the 30-second `waitUntil` bound, spec:118, or failed on a 5xx) leaves ward's ETag equal to
  the one D1 recorded. The card is not fetched, so the run has nothing to compare against, and
  the stale card stays on ward indefinitely. Spec:122-123 claims "a lost push ... is repaired
  within 15 minutes", and the stated mechanism can't do it. The same thing happens when the
  reconcile's own PUT races a web edit and records the ETag of the pre-edit render.
- Comparing bodies would also be fragile. Stalwart stores the parsed card (`new_card.card =
  vcard`, `crates/dav/src/card/update.rs:201`, `:276`) and serves a re-serialization of it
  (`card.inner.card.write_to(...)`, `:157`). The bytes it returns are not the bytes the Worker
  sent, and a Stalwart upgrade can change that serializer. A text diff would then rewrite every
  card on every run, which churns every client's sync.
- Proposed fold: each contact's ward row holds the ETag from the Worker's last successful write
  (Stalwart returns one on both 201 and 204, `update.rs:218`, `:300`) and the SHA-256 of the
  card it sent. A card needs a PUT when ward's ETag differs from the recorded one (changed or
  restored on ward), or when the D1 render's hash differs from the recorded hash (changed in D1
  since). That covers every case the spec lists, and the multiget is no longer needed. The
  reconcile takes `If-Match` (and the DELETE's precondition) from its own PROPFIND, never from
  D1's row. It runs the PROPFIND before it reads D1, so a card a push created mid-run is in D1
  by the time the run reads it. ETags are content hashes
  (`format!("\"{}\"", self.version.hash()...)`, `crates/dav/src/common/mod.rs:108-110`), so an
  upgrade that changes the archive format triggers a single full rewrite, which is harmless. Add
  one integration test: a push dropped after D1 commits is repaired by the next run.

## Major

### M1. The writer ships in Pass 2, before the account, the book, or the seed exist

- Severity: major. Tag: `correctness`. Location: spec:21-23, spec:116-118, spec:158.
- Defect: Pass 2 "gains the ward writer", and the `servers` task that builds the account comes
  after it (spec:21-23). From then on, every D1 commit pushes and the cron reconciles. Until the
  account exists, every request gets a 401. That trips the stop, and under M2 the stop never
  releases, because the password does not change when the account is created. Once the account
  exists, the first reconcile writes whatever D1 holds (development rows, a partial seed) into the
  book every household client reads. mail-filters then reads those emails as known
  correspondents. Cutover step 2 (spec:158) assumes the book fills only after the seed loads.
- Proposed fold: the writer stays off until cutover step 2 turns it on, through one flag
  (an `enabled` column on `ward_sync`, set by the cutover tool). With the flag off, push and
  reconcile return before any request. The live test (spec:175-176) targets the probe book
  through the same configured book URL.

### M2. The 401 stop can deadlock: it releases only when the Worker's secret changes

- Severity: major. Tag: `correctness`. Location: spec:127-131, spec:137-139.
- Defect: the stop holds "until the secret's hash differs" (spec:128). Several 401s are fixed on
  ward, not in the Worker, so they never release:
  - A rotation done Worker-first. The new password gets a 401 and the stop records its hash,
    then ward takes the same value and nothing changes on the Worker side. The spec says
    "changing both" (spec:138) and gives no order.
  - A ward restore to a snapshot from before a rotation, or from before the `phonebook` account
    existed. `server-restore` swaps in the whole store
    (`roles/mail-backup/server-restore`, step 5) and does not re-run `stalwart-apply`.
  - A `stalwart-apply` run that fails before it sets the password.
  - M1's pre-account window.
- Proposed fold: (1) the runbook sets the rotation order: ward first (`stalwart-apply`), then the
  Worker secret. (2) The Phones page's ward line gets a "Retry ward" action, behind Access, that
  clears the stop and allows one request. A second 401 sets the stop again. This adds one
  request per press, which stays far below the ban rate.

### M3. A burst of parallel 401s can trip the 24-hour auto-ban before the stop is recorded

- Severity: major. Tag: `correctness`. Location: spec:116-118, spec:127-131; facts §4.
- Defect: the stop is recorded after a 401, but the spec lets requests run in parallel. The seed
  is a D1 commit (spec:116 lists "seed"), so it pushes every contact at once. A handset upload
  that changes many contacts does the same, and so does a reconcile's PUT loop. With a wrong
  password, all of them fail together. Ward's `authBanRate` is 100 a day with a 24-hour ban
  (`roles/stalwart/plan.ndjson:6`; facts §4). Tracking keys on the login name as well as the
  source (facts §4). So one seed of 100 or more contacts can ban the `phonebook` login and a
  Cloudflare egress address that the monitor Worker may share (facts §4,
  `cloudflare/monitor/src/checks.ts:19`). Then a false `mail_down` alert fires.
- Proposed fold: (1) the seed does not push, and cutover step 2's reconcile fills the book.
  (2) Ward requests in one invocation run one at a time, and the first 401 ends the invocation's
  ward work. (3) The reconcile's PROPFIND precedes its writes, so a bad password costs one
  failed login per run. Add a unit test: a 401 on the first of N writes makes exactly one
  request.

### M4. Permanent 412s are retried forever and never surface

- Severity: major. Tag: `correctness`. Location: spec:123-124.
- Defect: "A 412 on any write is left to the next run." Stalwart answers 412 for an `If-Match`
  failure, and also for problems the next run won't fix:
  - A card the strict parser rejects (`SupportedAddressData`, `update.rs:82-103`).
  - A card over the size limit (`MaxResourceSize`, `:76-81`).
  - A UID change (`NoUidConflict`, `:176-186`).
  - A UID that already exists at another href in the book (`assert_is_unique_uid`,
    `:252-258`).

  A Stalwart upgrade that tightens the parser turns a working card into a permanent 412. The
  contact then stays stale or missing on ward and in mail-filters. Each run "fails" it quietly,
  and the ward line still reports success.
- Proposed fold: if a contact gets a 412 on two runs in a row, the run records a per-contact error
  and the ward line shows it. The reconcile sends its DELETEs before its PUTs, so a stray card
  that holds a contact's UID at another href is cleared before the create. The live probe PUTs the
  awkward-name card from the unit set (spec:168-169) through the strict parser.

### M5. A handset rename or delete discards the fields the phone never held

- Severity: major. Tag: `correctness`. Location: spec:108-112; base:111, base:134.
- Defect: spec:110-111 keeps "a handset delete still deletes the whole contact". The base merge
  turns a handset rename into "a delete and an add" (base:134). So renaming a contact on a
  kitchen phone deletes its emails, address, organization, and note. The added contact has only
  the phone fields. Ward drops the card and creates one under a new UID, and the email leaves
  mail-filters. The base change log stores "before and after values" (base:111), but nothing
  says the new fields are in it, so the undo by hand from the log (base:183) may not restore them.
- Proposed fold (`correctness`, needed in every case): the change log's before values carry
  every contact field, the new ones included. Add a merge test: a handset delete's log row
  restores the email.
- **OWNER FORK** on the rename:
  - (a) Accept it as designed. A rename on a handset drops the web-only fields, and Geoff
    restores them by hand from the change log. This leaves the reviewed merge untouched.
  - (b) In one upload, a deleted base contact plus an added entry with the same non-empty numbers
    count as a rename. The contact keeps its ID and its web-only fields. This adds one merge
    rule and its tests in `auth-data` code.

  Recommendation: (a) with the log fold. Handset renames are rare, the loss is visible in the
  changes view, and the fold makes it recoverable. Choose (b) if the probe shows renames are
  routine on the handsets.

### M6. The old book can change between the export and its deletion, and both books share one name

- Severity: major. Tag: `correctness`. Location: spec:153-164, spec:54.
- Defect: step 1 exports the old book, and step 4 deletes it later, in the cutover sitting. The
  old book stays read-write for both mailbox holders until then (`docs/cutover-log.md:108`: "shared
  read-write with the second operator over a WebDAV ACL"). A card added or edited in that window
  is in neither the seed nor the export, so the deletion loses it silently. The new book also
  takes the same display name (spec:54), so between steps 2 and 4 every client lists two books
  called "Global Address Book". The count check (step 3) and the deletion (step 4) can each land
  on the wrong one.
- Proposed fold: just before step 4 deletes, the tool re-reads the old book's ETags. It refuses
  if any card was added, changed, or removed since the export, and the cutover re-runs the union
  for those cards. The tool deletes by the old book's href under Geoff's account path, never by
  name. Step 3 names the book by its owner path.

### M7. A household-book address can still fall silently out of mail-filters after the one-time check

- Severity: major. Tag: `correctness`. Location: spec:141-147; facts §2, §7.
- Defect: spec:146-147 checks the known-correspondent list once, in the ward task. After that,
  the book drops out without a signal whenever Geoff's session stops listing the `phonebook`
  account. RFC 9670 lists an account only if "the user is subscribed to at least one record"
  (facts §2), so a client that unsubscribes the shared book removes it. Three other paths do the
  same:
  - An upgrade changes session listing.
  - A ward restore predates the grant.
  - The reconcile empties the book (m7).

  mail-filters reads whatever accounts the session lists (`roles/mail-filters/mail-filters:224-229`).
  It accepts an empty correspondents file ("may be empty", `roles/mail-filters/render.sh:13`)
  and renders without complaint at its daily 05:15 refresh
  (`roles/mail-filters/systemd/mail-filters-refresh.timer`). Two more gaps:
  - The fallback reads the book "with that login" (spec:145). `setup` accepts only
    `mailbox: true` accounts (`mail-filters`, the `select(.name == $n and .mailbox)` in
    `setup`), so the fallback is new code.
  - That fallback's 401s count against the same login name as the Worker's (facts §4). It sits
    outside the Worker's stop.
- Proposed fold: `correspondents` fails when the `phonebook` account is missing from the session,
  or when it returns zero cards (or, under the fallback, when the `phonebook` read fails). The
  render then fails, the installed script stays, and the refresh's existing "install failed"
  path reports it. This is a standing check, not a one-time one.

## Minor

### m1. Cutover mapping can drop ward values silently, and the number format differs

- Severity: minor. Tag: `correctness`. Location: spec:92-102, spec:153-157.
- Defect: ruling 2 keeps a fixed field set and three number slots. Some values on the 18 cards
  have nowhere to go:
  - A `TEL;TYPE=home` or fax number, or a second cell number.
  - A second `ADR`.
  - A sixth email.
  - The structured `N` (spec:101 leaves `N` empty, which changes last-name sort in clients).

  These vanish without review. Only the photo drop is named (spec:157). Ward numbers are
  `+1 907-555-0123` (`docs/cutover-log.md:107`), while D1 stores the voip.ms caller-ID format
  (base:98). A raw comparison sends every matched pair to the review as a number conflict.
- Proposed fold: the cutover tool parses ward numbers into D1's format before the same-name
  comparison. The one review lists, per card, every value that won't map, so Geoff sees the loss
  before the seed. The export stays the backup.

### m2. The Blacklist rule is keyed by name and stated only for the reconcile

- Severity: minor. Tag: `correctness`. Location: spec:104-106.
- Defect: "The reconcile treats a contact in `Blacklist` as absent." The push path (spec:116-118)
  isn't told, so a contact moved into the Blacklist from a phone is pushed, not deleted, until the
  next run. Groups can be renamed in the web app (base:137). A renamed Blacklist group sends
  blocked callers to ward and makes their emails known correspondents, the opposite of the intent.
- Proposed fold: one function decides whether a contact belongs on ward, and push and reconcile
  both call it. The function is keyed to the group the phones treat as the blacklist, and the web
  app refuses to rename that group.

### m3. Overlapping runs and a shared state row can clear a 401 stop

- Severity: minor. Tag: `correctness`. Location: spec:119, spec:125-128, spec:158.
- Defect: a run may take up to 15 minutes (facts §5), as long as the cron interval, and cutover
  step 2's manual run can overlap a cron run. Writes are idempotent renders, so overlap is safe for
  cards. But `ward_sync` holds "the last run's time, its result, and its error" in one row. If
  the 401 stop is a result value, a run that started earlier and finishes later overwrites it
  with "ok". The next run then spends another failed login. A run that records an ETag for a
  contact deleted mid-run could also fail its batch on a foreign key.
- Proposed fold: the stop is its own field, set by a 401 and cleared only by M2's release rule.
  ETag rows are upserts that skip a contact no longer present.

### m4. The reconcile has no guard against an empty or truncated D1 read

- Severity: minor. Tag: `correctness`. Location: spec:121-122.
- Defect: "a DELETE for a card D1 doesn't hold". A D1 query bug, a migration fault, or a read of
  the wrong database returns no rows. The run then deletes every card, and every client and
  mail-filters syncs the deletion. The base spec guards handset uploads against exactly this shape
  (base:145-148). D1 still holds the data, but the household's books stay empty until the fault
  is found.
- Proposed fold: a run that reads zero non-Blacklist contacts while ward holds cards writes
  nothing and records an error. That one check is enough. A percentage threshold is not needed,
  because a deliberate bulk delete happens in the web app.

### m5. Which collection is "the book" is undefined

- Severity: minor. Tag: `correctness`. Location: spec:52-55, spec:65-68.
- Defect: Stalwart "automatically creates a default address book when an account is accessed and
  no address books currently exist" (facts §3). The first sign-in, by the Worker or by
  `stalwart-apply`'s grant step, creates one. The spec doesn't say whether the named book is that
  default renamed or a second one. With two books, the Worker or the grant could target the wrong
  one, and members' clients could show an extra empty book.
- Proposed fold: `stalwart-apply` makes sure the account holds exactly one book, at a fixed
  href, named "Global Address Book", by renaming the default. The Worker's target is that href,
  as configuration, never looked up by name.

### m6. A ward restore has no runbook step for this design

- Severity: minor. Tag: `correctness`. Location: spec:44-48.
- Defect: "either side's restore ends with the next reconcile making ward match D1" (spec:47-48)
  holds for the `phonebook` book only. A ward restore to a snapshot from before cutover step 4
  brings back the old, read-write "Global Address Book" in Geoff's account. mail-filters reads it
  (it is Geoff's own account), and clients show two books again. A restore to a snapshot from
  before the account trips M2's stop. The mail-server restore runbook (`docs/runbook.md:181-207`)
  ends at the mailbox counts.
- Proposed fold: add one line to that runbook. After a restore, run `stalwart-apply`, delete the
  old book again by href if it came back, and release the ward stop from the Phones page.

### m7. Probe 2 tests only cards, not the collection

- Severity: minor. Tag: `optional`. Location: spec:81.
- Defect: a client's "remove address book" sends `DELETE` or `PROPPATCH` to the shared collection
  itself. `Read` maps to `Read` and `ReadItems` only (`crates/dav/src/common/acl.rs:325-328`), so
  403 is expected, but nothing checks it live.
- Proposed fold: probe 2 adds a member's DELETE and PROPPATCH on the collection, with 403 as the
  expected result.

### m8. Over-ceremony: probe 10 and its fallback guard nothing the reconcile doesn't

- Severity: minor. Tag: `optional`. Location: spec:84, spec:116-117.
- Defect: under B1's fold, a create that lands on an existing card overwrites it with the D1
  render, which the reconcile would write anyway. D1 is the authority, and ward changes are
  overwritten by design (spec:186-187). `If-None-Match: *` and the probe that confirms it buy
  nothing.
- Proposed fold: creates are plain PUTs. Drop probe 10 and facts list item 10.

### m9. "Cannot be undone except from that file" overstates the risk

- Severity: minor. Tag: `optional`. Location: spec:164.
- Defect: ward's nightly restic snapshots keep the old book within their retention
  (`--keep-within 35d --keep-weekly 8 --keep-monthly 12 --keep-yearly 5`,
  `roles/mail-backup/servers-backup:220`). The export is one workstation copy.
- Proposed fold: name the restic snapshot as the second copy. Copying the export elsewhere isn't
  needed.

### m10. The tests miss the races and failure paths above

- Severity: minor. Tag: `correctness`. Location: spec:166-180.
- Defect: the integration list covers a 412, a 401, a 5xx, and a timeout, each one alone. It
  doesn't cover the paths this review found:
  - A lost push repaired (B1).
  - A push interleaved with a reconcile.
  - A burst costing one failed login (M3).
  - A persistent 412 surfacing (M4).
  - A stop released after a ward-side fix (M2).
- Proposed fold: one test case per fold above, in the existing fake-CardDAV harness.

## Checked and sound

- **D1 Time Travel.** Recorded ETags and hashes roll back, every card then mismatches, and the
  reconcile rewrites ward to match D1, as spec:47-48 says. A rolled-back stop costs at most one
  failed login.
- **Two pushes of one contact.** `If-Match` on the recorded ETag makes the late one 412
  (`update.rs:134-166`). The reconcile then settles it, given B1's fold.
- **Crash or cancel mid-write.** Each card is one PUT committed in one batch (`update.rs:204-215`),
  so a cancel leaves a whole old or a whole new card. A mismatch in the ETag row is caught by the
  next run's ETag compare.
- **The backup band.** Stalwart stops between 03:30 and a few minutes past (`servers-backup`, the
  `stop` step). At most one or two runs fail, below the one-hour flag (spec:133-134).
- **Ownership by a separate account.** The facts' reason holds in source: the owner check skips
  ACLs for a member (`update.rs:113-116`, `:225-232`).
