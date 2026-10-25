# Ward address book design: review fold

Date: 2026-10-24. Target: `specs/2026-10-24-ward-address-book-design.md`, revised in place from
the version the three lenses read (`c3d4579`). Reviews: `research/2026-10-24-ward-address-book-review-{contract,mechanics,data}.md`.
Each finding was checked against Stalwart source at `v0.16.27`, `~/Projects/servers` at
`9e25c9d`, the cached stalwart-cli schema, RFC 6350, and the Cloudflare Workers limits page before
it was folded. Rules: `optional` findings are dropped; `correctness` findings fold root-first where
lenses converge; a finding is refused only when its fix costs more than the risk it removes.

Counts for the three reviews: 54 folded, 3 refused, 8 dropped as `optional`, 2 owner forks (one
of them shared by two findings). The verification read's 23 findings are dispositioned in the
last section: 19 folded (10 in the spec body, 8 in the spec's "Owed to the plan", 1 in this
record), 4 dropped as `optional`.

## Rulings for Geoff

Both forks are ruled (Geoff, 2026-10-24, in chat), and the spec's `### Decide:` blocks are gone.
The rulings are spec rulings 8 and 9.

1. **Export retention (contract M1): moot.** Geoff changed the cutover instead: "The old global
   address book should be moved into a book in [the second operator]'s account. The new entries should come
   entirely from the phone." No export exists to keep. The moved book is the backup, and ward's
   restic snapshots are the second copy (`roles/mail-backup/servers-backup:220`).
2. **Handset rename or delete (contract M3, data M5, verification m17): "Accept, undo by hand."**
   The change log carries every field, the operations guide names the undo, and the revisit
   trigger stays: revisit if the Pass 1 probe shows handset renames are routine.

## Source checks behind the fold

- No group: a default book is created for any account whose resources are built with none
  (`crates/groupware/src/cache/calcard.rs:112-124`), and a group member passes the owner check
  (`crates/dav/src/card/update.rs:113-116`, `is_member` at `crates/common/src/auth/access_token.rs:476-480`).
- Per-user grants: a direct grant adds the owner to the sharee's `access_to`
  (`access_token.rs:76-120`), `secondary_ids` chains `access_to` (`:443-448`), and the session
  lists each secondary account with every capability (`crates/jmap/src/api/session.rs:59-91`),
  regardless of subscription. `acl_validate` accepts any Account id and enforces `maxShares`
  (`crates/jmap/src/api/acl.rs:242-262`). A `shareWith` set replaces the map
  (`crates/jmap/src/addressbook/set.rs:456-458`).
- Book name: a book with one preferences entry shows it to every account
  (`crates/groupware/src/contact/mod.rs:53-56`).
- PUT returns an ETag on 201 and 204 (`card/update.rs:218`, `:300`); a missing card's DELETE is 404
  (`card/delete.rs:70-72`); Stalwart re-serializes the parsed card on read (`card/update.rs:157`,
  `:201`).
- `disabledPermissions` is on `x:PermissionsList`, which `x:UserAccount.permissions` takes, and
  the `Permission` enum holds `emailSend`, `imapAuthenticate`, and `davCardGet` (the schema).
- mail-filters' `setup` selects `.mailbox` accounts only (`roles/mail-filters/mail-filters:100`);
  `correspondents` reads every session account with the contacts capability (`:224-229`).
- RFC 6350: escaping (section 3.4), folding at 75 octets with multi-octet characters contiguous
  (3.2), `N` cardinality `*1` (6.2.2), `TEL` defaults to free-form text (6.4.1), `TYPE` grammar
  (5.6).
- Workers Free allows 50 subrequests per invocation, Paid 10,000 (Workers limits page). The
  account is on Workers Paid (`self-hosting/specs/2026-10-17-self-hosting-design.md:80`), cited by
  the coordinator after the fold.

## Contract review

- **B1** (reconcile can't see a lost push or a group change): folded, converged with mechanics 2
  and data B1. Ward row holds the ETag and the hash of the card last written; PUT on either
  difference; no multiget. Spec: "Reconcile", "State", Testing unit.
- **M1** (export deleted in the same sitting): exemption folded (Cutover step 4, amends list);
  retention is owner fork 1.
- **M2** (ward-card data dropped without review): folded. Cutover step 1 states the mapping and
  the drop list; step 4 refuses on an unresolved card; a synthetic overflow unit case.
- **M3** (handset rename strips web-only fields): owner fork 2. The data-model paragraph is
  reworded to match the base merge either way.
- **M4** (merge test vacuous): folded. Testing "Merge"; base and served rows hold only phone-held
  fields (data model, amends list for Task 2.2).
- **M5** (fixture tests XML, not vCard): folded with RFC 6350 sections quoted. Data model
  escaping paragraph, Testing unit, live probe-book reconcile.
- **M6** (412 means two things; "succeeded" undefined): folded. `ward_sync` result values, only
  `ok` clears the one-hour flag, the 412 precondition name in the log, an integration case.
- **M7** (mail-filters check vacuous and early): folded. The check moves after cutover step 4,
  uses an address only in the new book, and runs for every mailbox account (mail-filters
  section; synthetic contact owed to the plan).
- **M8** (integration criteria): folded. A 10-second per-request timeout; each case names its
  `ward_sync` and ward-row state and leaves `contacts` and `changes` untouched.
- **M9** (cron ships before the account): folded, converged with data M1 and mechanics 3. Unset
  configuration means `disabled` and zero requests; production is configured at cutover step 2.
- **M10** (end-to-end test account never removed): folded. `probe2`'s `household` flag flips for
  one apply and is restored.
- **m1** (push can't fire on the seed): folded. "Push" drops the seed.
- **m2** (probe criteria pass on empty data; loose read-back): folded. Probe table criteria; the
  read-back rule is owed to the plan.
- **m3**: dropped, `optional`. (The membership-timing probe is gone anyway with the group.)
- **m4** (probe accounts become members): folded as direction ruled, not a fork. `probe` and
  `probe2` set `"household": false` (Ward: "The grants").
- **m5** (facts items 6 to 9 undispositioned): folded. One line under the probe table.
- **m6** (group roles and permissions unstated): refused: moot, the group is gone (mechanics 1).
- **m7** (ruling 4 and behavior disagree): folded. Brief and ruling 4 state Claude's reading.
- **m8** (nobody creates the book): folded. Ward: "The book"; `WARD_BOOK_URL`.
- **m9**: dropped, `optional`. (Data m4, a `correctness` finding, folds the same guard.)
- **m10** (cutover checks are counts; old book writable): folded. UID-set check (step 2), the
  export records its own count (step 1), the ETag re-read before delete replaces a freeze (step 4,
  from data M6), the password from the age store (step 1).
- **m11** (fallback misses the second operator): folded. The fallback is removed, since source
  shows a grant lists the owner account in every sharee's session; the check covers every mailbox
  account.
- **m12** (amended base sections unlisted): folded. "Base spec and plan sections this amends".
- **m13** (Survey outside the rulings): folded. Provenance line (the `survey-house-style`
  initiative, approved 2026-10-22), the Brief's fourth change, and the pinned tag replacing
  `check-core.sh`.
- **m14** (no zero-fetch test): folded. Testing unit (unconfigured and stopped) and the
  integration case for a failed push on a web edit.
- **m15** (three vCard renderings ambiguous): folded. `N` omitted, other email with no `TYPE`,
  `TEL` as the default text value.
- **m16**: dropped, `optional`.

## Mechanics review

- **1** (group yields a writable shared book): folded as directed. Per-user `mayRead` grants,
  `"household": false` opt-out, no Group, no `memberGroupIds`, no group address. Ward section.
- **2** (reconcile can't repair a lost push): folded with contract B1.
- **3** (nothing keeps production off the live book): folded. "Off until configured"; the live
  test runs from the workstation against `probe`'s book.
- **4** (Worker-first rotation deadlocks the stop): folded. Rotation order in "The secret". In
  place of a Phones-page retry, the stopped reconcile makes one request a day (data M2).
- **5** (book creation unspecified): folded. Ward: "The book", by JMAP.
- **6** (`d-907` gives a live inbox): folded. `phonebook` on `d-ward`.
- **7** (credential can send mail): folded. `disabledPermissions` on the account; the full set and
  the submission check are owed to the plan.
- **8** (share step has no place in `stalwart-apply`): folded. Owed to the plan; the id match is a
  probe row.
- **9** (secret plumbing missing): folded. Owed to the plan.
- **10** (seed doesn't push): folded with contract m1.
- **11** (import mapping unspecified): folded with contract M2.
- **12** (push status handling): folded. "Statuses" (404 counts as done), the Blacklist move each
  way, the per-request timeout, and the integration wording.
- **13** (Workers tier assumed): folded. The spec cites Workers Paid, so a run's 10,000
  subrequests cover the first fill and nothing is owed.
- **14** (inventory unchecked live): folded as owed to the plan's cutover task, with no live read
  now. The second operator's own copy is out of scope; the cutover confirms it is gone before the
  mail-filters check.
- **15** (assisted discovery unprobed): refused: cutover step 3's add-by-URL fallback covers either
  setting, so the reading changes nothing.
- **16** (probe accounts get the book): folded as directed. `"household": false` on both, with the
  reason in the spec.
- **17** (probe setup and teardown unnamed): folded. The probes use `probe` and `probe2` with a
  hand-set grant, so no account is created; teardown is named.
- **18** (vCard details): folded. No `TYPE` for other email, escaping for `ADR` and `ORG` (commas
  everywhere, which covers `CATEGORIES`), and "names shown" in cutover step 3.
- **19** (export can ban Geoff's login): folded. Cutover step 1 stops at the first 401.
- **20** (hosts unnamed): folded. Owed to the plan's cutover task.
- **21**: dropped, `optional`. Its source claim was checked independently and carries contract
  m11.
- **22**: dropped, `optional`.

## Data review

- **B1** (reconcile can't see a lost push): folded with contract B1, including the PROPFIND before
  the D1 read and preconditions from the run's own PROPFIND.
- **M1** (writer ships before the account): folded with contract M9, by unset configuration
  rather than a new `enabled` column, which is one mechanism instead of two.
- **M2** (stop can deadlock): folded. Rotation order, plus release by one request a day while
  stopped, chosen over a Phones-page button: it covers every ward-side fix with no new
  `auth-data` surface and costs at most one failed login a day.
- **M3** (parallel 401 burst): folded. "One at a time", the first 401 ends the invocation, the
  seed doesn't push, and the unit case of one request.
- **M4** (permanent 412s silent): folded. Each ward row's last write status, the failed contacts
  on the ward line, no `ok` for an hour flagged, and DELETEs before PUTs.
- **M5** (rename or delete discards web-only fields): the change-log fold and its merge test are
  folded (data model, Testing "Merge"); the rename question is owner fork 2.
- **M6** (old book changes between export and delete; two same-named books): folded. Cutover
  step 4 re-reads ETags and deletes by href; step 3 names the book by owner path.
- **M7** (standing mail-filters check): refused. Source shows a grant lists the owner account in
  the session regardless of subscription, the restore path is covered by the runbook line (m6),
  and the empty-book path by the empty guard (m4); a per-account check in mail-filters, whose
  accounts include non-members, costs more than the upgrade-only path that remains. Its fallback
  gap is moot, since the fallback is removed.
- **m1** (mapping drops values; number format): folded with contract M2.
- **m2** (Blacklist rule by name, reconcile only): folded. One shared predicate, and the web app
  refuses to rename the `Blacklist` group.
- **m3** (overlapping runs clear the stop): folded. A separate stop field and upserts that skip
  absent contacts.
- **m4** (empty D1 read): folded. "The empty guard".
- **m5** (which collection is the book): folded with contract m8.
- **m6** (ward restore runbook): folded. Owed to the plan; the daily request releases the stop.
- **m7**: dropped, `optional`.
- **m8**: dropped, `optional`.
- **m9**: dropped, `optional`. Its restic fact, checked at `servers-backup:220`, is context for
  owner fork 1.
- **m10** (tests miss the races): folded. Testing unit and integration cases.

## Verification read

Source: `research/2026-10-24-ward-address-book-fold-verification.md`, read against the spec at
`abed3e5`. Each finding was checked before folding. New checks behind these folds: `set.rs:204-208`
puts an `acl_validate` refusal in `notUpdated`, and `acl.rs:266-277` maps both refusals to
`invalidProperties`; the schema types `x:UserAccount.permissions` as `x:Permissions` (`Inherit`,
`Merge`, or `Replace`, the last two holding `x:PermissionsList`) and lists `emailReceive` in
`Permission`; `dig` finds an A record and no MX for `ward.907.life`, a local domain at
`plan.ndjson:9`; `stalwart-apply:150-162` shows the "nothing changed" path; and a card's ETag is
`"<archive version hash>"` on both write and read (`crates/dav/src/common/mod.rs:107-125`).

- **M1** (refusal before the delete has no remedy): folded. Cutover step 4: the freeze covers the
  old book from export to delete, and on a refusal the tool prints each card's diff, Geoff applies
  it in the web app, and the tool re-exports and re-checks.
- **M2** (read-back can't catch a missing grant): folded. Ward: "The grants": any `notUpdated` or
  `notCreated` fails the apply, and `shareWith` must equal the member set exactly with `mayRead`
  alone; the eleventh-sharee and unknown-id test is in "Owed to the plan".
- **m1** (grant step on every path): folded. "Owed to the plan", the `stalwart-apply` bullet.
- **m2** (probe grant set by hand): folded. The probe preamble names `AddressBook/set` as `probe`;
  the owed permissions check adds the `shareWith` set and the principal lookup.
- **m3** (permissions is a variant; `build-plan` can't emit it): folded. Ward: "Owner" states the
  `Merge` variant; the `build-plan` passthrough is owed to the plan.
- **m4** (`d-ward` gives a deliverable address): folded. Ward: "Owner" disables `emailReceive`, adds
  the `rcpt-check.sh` row, and names the fallback; the `addresses.md` row is owed to the plan.
- **m5** (Blacklist refusal covers one path): folded. Data model: the predicate matches by name, and
  the web app refuses a rename to or from `Blacklist` and its delete.
- **m6** (`disabled` raises the flag): folded. "Owed to the plan".
- **m7** (PROPFIND failure and serial timeouts): folded. "Owed to the plan".
- **m8** (trial time unstored): folded. "Owed to the plan".
- **m9** (line endings and CR): folded. "Owed to the plan", with RFC 6350 section 3.2 as its
  source.
- **m10** (mapping and test disagree): folded. Cutover step 1 maps `EMAIL` types and drops `ADR`
  components 1 and 2; the unit case uses a home `TEL` after an other.
- **m11** (new fields unproven against Stalwart): folded. Testing "Live" runs again in Pass 3 before
  cutover step 2, and names Pass 3 for the merge test and the ward line.
- **m12** (test logins against the flip): folded. Ward: "The grants", reworded.
- **m13** (kind of `WARD_BOOK_URL`): folded. "Owed to the plan": both are Worker secrets set at
  cutover step 2.
- **m14** (cron trigger and migrations unlisted): folded. "Owed to the plan".
- **m15** (ETag match uncited; missing ETag): folded. Writing to ward: "Statuses".
- **m16** (fold record stale on the tier): folded. This record's source checks and mechanics 13.
- **m17** (fork 2 lacks its revisit trigger): folded. The Brief's second `### Decide:` block and
  ruling 2 above carry the trigger and option (b)'s 60-minute figure.
- **m18**: dropped, `optional`.
- **m19**: dropped, `optional`.
- **m20**: dropped, `optional`.
- **m21**: dropped, `optional`. M1's freeze closes the window in practice.

## Geoff's rulings and the cutover change

Applied to the spec at `20ae25d`. Follow-ups from Geoff: the moved book is the second operator's
only, with no share back to Geoff, and his own imported 20-card copy is still deleted as
`conductor-servers` scheduled, so he ends with one copy.

Checks behind the change:
- Only an owner may MKCOL a book (`crates/dav/src/card/mkcol.rs:56`, `is_member`), and the
  request's properties carry the display name (`:108`). The second operator holds read-write on
  the old book (`servers/docs/cutover-log.md:108`), so his login reads the source and writes his
  own book.
- UID uniqueness is checked within the parent book only (`card/update.rs:252-258`, the parent's
  `document_id`), so moved cards keep their UIDs.
- An owner passes the collection delete's ACL check (`card/delete.rs:93-101`), so the source is
  deleted as Geoff.
- The emails the old book feeds into Geoff's known-correspondent list, counted read-only from
  `~/.local/state/contacts-backup-20261022/global.xml` with no address printed: 4 distinct
  addresses on 4 of its 20 cards, and none of the 4 in `personal.xml` from the same backup. The
  backup predates the 2026-10-22 cleanup (20 cards to 18), so the spec says "about 4". Sent mail
  was not checked, so some may stay on his list through it.

What changed in the spec:
- Brief: the four changes and the two consequences (the new book starts with phone fields only;
  Geoff's list loses about 4 emails, the second operator's keeps them); both `### Decide:` blocks
  removed.
- Rulings 8 and 9 added, with the moved book's name, "Household list (old)", recorded as Claude's
  call and contestable.
- Cutover: step 1 is the phone-only seed; steps 4 and 5 are the move, verify, re-read, and delete
  by href. The ward-card import mapping, the drop-list review, the ward number normalization, and
  M1's handset freeze over the old book are removed; the second operator is told not to edit
  during the copy.
- Testing: the ward-import overflow case is replaced by the move script's 401 stop and its refusal
  on a changed ETag. Out of scope, amends list, "Owed to the plan", estimate (330 to 315, Pass 3
  from 90 to 75), and pre-flight updated.

Earlier dispositions this supersedes:
- Contract M2, mechanics 11, data m1 (the ward-card mapping and review), and verification m10
  (the mapping's test): moot, since no ward card enters D1.
- Contract M1: moot, as ruling 1 above says.
- Contract m10, data M6, and verification M1 (export, re-read, freeze, re-export): replaced by
  cutover steps 4 and 5. The re-read of the source's ETags and the delete by href carry over.
- Mechanics 14 (live count of the old book): the move script's count replaces it.
- Mechanics 19 (stop at the first 401): carried over to the move script, for the second
  operator's login.
