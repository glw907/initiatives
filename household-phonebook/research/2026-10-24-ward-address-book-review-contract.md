# Ward address book design: contract and criteria review

Date: 2026-10-24. Lens: contract and criteria. Target:
`specs/2026-10-24-ward-address-book-design.md` at c3d4579 (cited as "spec"), read against the
2026-10-07 spec (`phonebook/docs/specs/2026-10-07-phonebook-design.md`, "base spec"), the plan's
Passes 2 and 3 (`phonebook/docs/plans/2026-10-07-phonebook-phases-0-2.md`, "plan"), the facts
record (`research/2026-10-24-ward-address-book-facts.md`), and `~/Projects/servers` at 9e25c9d.

Counts: 1 blocker, 9 major, 15 minor. Three findings are OWNER FORKs: M1 (export retention), M3
(handset rename), and m4 (probe accounts).

## Blocker

### B1. The reconcile cannot see a lost push or a group change

- **Severity:** blocker. **Tag:** `correctness`.
- **Location:** spec:116-126 (Push, Reconcile, State); spec:170 (unit diff cases).
- **Defect.** D1 keeps only the ETag it last saw (spec:125). The reconcile multigets only cards
  whose ward ETag differs from that record (spec:120-121). When a push is lost, the ward card
  and its ETag are unchanged, so the ETags match, the card is never fetched, and nothing tells
  the reconcile that D1 moved on. The same holds for two quick web edits: the second push uses
  the stale `If-Match`, gets 412 and stops (spec:117, :123-124), and the first push recorded its
  ETag, so the next reconcile also sees a match. A group rename or delete changes every
  member's `CATEGORIES` without a contact commit, so no push fires and the reconcile skips
  those cards too. The promise "a lost push ... is repaired within 15 minutes" (spec:122-123)
  fails in ordinary use, and the unit case "changed" (spec:170) can pass on a fixture where
  only the ward side changed.
- **Proposed fold.** The state row per contact holds the ETag and the SHA-256 of the card the
  Worker last wrote. The reconcile PUTs a card when it is missing on ward, when the ward ETag
  differs from the recorded one, or when the hash of the current render differs from the
  recorded hash. It then records the new ETag, or clears it if the response has none (whether
  Stalwart returns an ETag on PUT is unverified). This drops the multiget and the byte
  comparison against Stalwart's stored form, which would churn if Stalwart re-serializes cards
  (unverified). Unit cases: (a) a D1 edit with the ward ETag unchanged (the lost push), (b) a
  ward-side change with D1 unchanged, (c) a group rename, (d) unchanged. Each fails if the
  reconcile skips it. A mutation proof that drops the hash comparison fails (a) and (c).

## Major

### M1. The cutover's only backup is deleted in the same sitting (retention is an OWNER FORK)

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:163-164 against plan:1114 (cutover step 7).
- **Defect.** The spec names the step 1 export as the only way to undo the old book's deletion.
  The plan's cutover step 7 deletes "the directory exports" at the end of the same sitting, so
  as written, the delete and the loss of its backup land together. Ward's own backups may hold
  the old book, but their retention isn't cited, so that's unverified.
- **Proposed fold.** Cutover step 7 exempts the ward export by name. **OWNER FORK** on how long
  it stays: (a) 30 days under `~/.local/share/phonebook/exports/` at mode 0600, then deleted;
  (b) until Geoff confirms the new book in daily use, with no date; (c) moved to the age store as
  an encrypted blob and kept indefinitely. Recommendation: (a), since it bounds how long household
  data sits loose and covers any discovery lag.

### M2. The cutover drops ward-card data without review before an irreversible delete

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:153-157, :163-164; spec:184-185 (out of scope).
- **Defect.** The spec says the ward card supplies emails, the address, the organization, and the
  note, and that its photo is dropped. Nothing says what happens to anything else: a property
  outside the model (`BDAY`, `URL`, `X-` fields, a second `ADR`), a sixth email, a fourth `TEL`, a
  `TEL;TYPE=home` or a second `cell` (which of office, mobile, and other?), or `CATEGORIES` (which
  group?). The phone half of the seed lists every unmapped element by name and count (plan:1060-1062).
  The ward half has no such review, and the old book is deleted afterward. There is also no stated
  fixture showing that the number comparison runs `normalizeNumber` on ward's `+1 907-555-0123`
  form. Without it, every pair would land in review.
- **Proposed fold.** State the ward-to-contact mapping: `TEL` type to slot, overflow, `CATEGORIES`
  to group, more than one `ADR`. `seed.ts review` lists, for each ward card, every property and
  every value it drops, by name and count, and Geoff resolves the list before `apply`. Step 4's
  delete waits on two checks: every export card maps to a D1 contact, and the drop list is
  empty or confirmed. A seed unit test uses a synthetic card carrying each kind of overflow.
  The test fails if anything leaves the review unlisted.

### M3. A handset rename strips the web-only fields (OWNER FORK)

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:108-112 against base spec:134 (merge row "A handset rename").
- **Defect.** The spec says a merge "never clears or rewrites an email, an address, an
  organization, or a note". The base spec's merge makes a handset rename that is not case-only
  "a delete and an add", so the renamed contact is a new ID with none of those fields. The
  rule and the merge table disagree.
- **Proposed fold.** **OWNER FORK.** (a) Accept it and say so: a handset rename drops the
  web-only fields, the change log keeps them, and the operations guide names the undo. (b) Carry
  the web-only fields to the add when one upload deletes a contact and adds one that has an
  identical number. This is rename detection, which the earlier spec fold declined. Recommendation:
  (a). Renames on a handset are rare, the log keeps the values, and (b) adds merge logic to the
  correctness core. Either way, spec:109-110 is reworded to match, and a merge test pins the
  chosen behavior.

### M4. The merge test can pass vacuously

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:110-112, :171.
- **Defect.** "A phone's upload of a contact the web gave an email keeps the email" passes for a
  merge that never writes that contact, because an unchanged upload writes nothing. It also
  doesn't exercise the real risk: base and served rows that carry the new fields. A web-added
  email shows up in a served row but never in an upload, so a merge that compares those fields
  would read the email's absence as a handset clear.
- **Proposed fold.** The fixture's served row is recorded after the web adds the email. The
  upload edits a number on that same contact. The expected result is the number changed and the
  email, address, organization, and note intact. A mutation proof that lets the merge compare
  the new fields fails the test. The base and served rows hold only phone-held fields, a
  constraint the plan's Task 2.2 `BaseRow`/`ServedRow` types carry.

### M5. The awkward-name fixture tests XML characters, not vCard ones

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:168-169.
- **Defect.** `&` and quotes matter to the Yealink XML, but RFC 6350 escapes backslash, comma,
  semicolon, and newline, and it folds lines (from memory and unverified here; the RFC section
  should be quoted). The fixture includes a comma, but it has no backslash, semicolon, or
  newline, no multi-line note, and no long UTF-8 line that folds mid-character. An unescaped
  newline in a note or name can inject a property (for example `END:VCARD`). Stalwart parses
  strictly, so a bad render gets a 412 (facts §6), which M6 shows is silent.
- **Proposed fold.** The round-trip fixture adds `\`, `;`, a newline inside the note and the
  name, and an accented character placed on a fold boundary. It quotes the RFC 6350 escaping and
  folding rules with section numbers. Mutation proof: removing the newline escape fails a test.
  The live probe-book reconcile (spec:175-176) renders the same fixture set, so Stalwart's
  parser accepts the real output, including `+1 907-555-0123` and `*97` as `TEL` values.

### M6. A 412 means two things, and "succeeded" is undefined

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:123-124, :132-134.
- **Defect.** Stalwart sends 412 for a failed `If-Match` and also for invalid vCard input and a
  UID conflict (facts §6, `card/update.rs:91-101`, `:176-186`). "A 412 on any write is left to the
  next run" turns a renderer bug into a permanent, silent skip. The Phones page flag fires when
  "a reconcile hasn't succeeded in an hour", but the spec never says whether a run with failed
  writes counts as a success, so the flag can stay quiet forever.
- **Proposed fold.** `ward_sync.result` is one of `ok`, `partial` (with the count of failed
  writes), `stopped` (401), or `error`. Only `ok` counts as success for the one-hour flag. The
  log line records the 412's body category, for example `SupportedAddressData`, and never the
  body itself. An integration case with a 412 on every run proves the flag rises after an hour.

### M7. The mail-filters check passes vacuously and runs at the wrong time

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:143-147.
- **Defect.** "A household-book address appears in the generated known-correspondent list" is
  true today: the old Global Address Book sits in Geoff's own account, and his Personal book
  (179 cards) and sent mail feed the same list (`mail-filters:224-235`). The ward task runs
  before Pass 3, when the new book is still empty, so the check passes through the old book or
  fails on the empty one. Either way it proves nothing about the new account.
- **Proposed fold.** Use an address present only in the new book, such as a synthetic contact
  seeded for the check, or a household address found nowhere in Personal or Sent. Run the check
  after cutover step 4, once the old book is gone, for every `mailbox: true` account, since the
  second operator's list is affected too (see m11). The check fails if that address is missing.

### M8. The integration criteria name no expected state and no timeout

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:172-174.
- **Defect.** "Each leave D1 untouched and the state row correct" contradicts itself, since the
  state row is in D1, as is the 401 stop's record (spec:127-128). "Correct" names no value, so
  the criterion cannot fail. "A timeout" has no bound: the spec sets no per-request timeout, so a
  hung ward holds the push until `waitUntil`'s 30 seconds and the reconcile until the 15-minute
  scheduled limit (facts §5).
- **Proposed fold.** State a per-request timeout, for example `AbortSignal.timeout(10_000)`. Each
  case names its expected `ward_sync` row and per-contact state: a 412 gives `partial` with the
  ETag kept, a 401 gives `stopped` with the hash recorded and zero further fetches, and a 5xx or
  timeout gives `partial` or `error` with the ETag kept. Every case leaves the `contacts` and
  `changes` tables unchanged.

### M9. Pass 2 ships the cron before the ward account exists

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:21-23 (ordering), :119, :137-139.
- **Defect.** Pass 2 adds the writer, and its close deploys it (plan:921-937). The `servers` task
  that creates the `phonebook` account comes after Pass 2. Once deployed, the cron signs in as an
  account that does not exist, gets a 401, and counts as a failed login against the shared
  egress address (facts §4). The spec also does not say what an unset `WARD_PASSWORD` does.
- **Proposed fold.** With no `WARD_PASSWORD` or no book URL set, the reconcile and the push make
  no request and record `disabled`, and a unit test proves zero fetches. The secret goes in at the
  `servers` task's close. Alternatively, reorder the work so the `servers` task runs before Pass
  2's deploy. The first option needs no change to the plan's ordering.

### M10. The end-to-end test account is never removed

- **Severity:** major. **Tag:** `correctness`.
- **Location:** spec:179-180.
- **Defect.** `build-plan` only upserts (`roles/stalwart/build-plan:27-35`), so deleting an entry
  from `accounts.json` leaves the live account and its read access to the household book in
  place. The new account also needs a password variable in the rendered env, or `build-plan`
  fails (`build-plan:14-22`). Each apply with a changed plan also restarts the live mail server
  (`stalwart-apply:154-155`), which happens twice for the add and the remove.
- **Proposed fold.** Use the existing `probe2` account (`role: "User"`, `d-probe`) as the member
  for the end-to-end check, and drop the add-and-remove step. If m4 rules that probe accounts are
  not members, the check flips `probe2`'s `household` flag for one apply, then restores it. That
  costs one restart and leaves no account behind.

## Minor

### m1. The push cannot fire on the seed

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:116 against plan:1104-1105.
- **Defect.** The seed lands as `seed.sql` through `wrangler d1 execute`, so it never runs
  through the Worker and no push fires. Cutover step 2 already relies on a reconcile (spec:158).
- **Proposed fold.** Drop "or seed" from spec:116.

### m2. Two probe pass criteria can pass on empty data, and the grant read-back is loose

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:66-68, :80-81.
- **Defect.** If the probe book is empty, a multiget that returns zero cards passes probe 1. In
  probe 2, an update or delete aimed at a missing href can return 404 or 412 instead of 403.
  Also, an account with no grant at all gets 403 too, so a 403 alone does not prove a read-only
  grant. For the grant itself, "reads it back" never says what a correct read looks like.
- **Proposed fold.** Probe 1: the book holds at least two cards, and the multiget returns all of
  them. Probe 2: the same member that passed probe 1 aims each write at an existing card with its
  current ETag, and the book's ETags are unchanged afterward. The read-back fails on any sharee
  other than `household` and on any right other than `mayRead`.

### m3. Probe 11 is moot (over-ceremony)

- **Severity:** minor. **Tag:** `optional`.
- **Location:** spec:82.
- **Defect.** `stalwart-apply` restarts Stalwart whenever the plan's hash changes
  (`stalwart-apply:154-158`), and a membership change does change it. Every repo-driven
  membership change therefore starts from a fresh server, and the probe measures nothing the
  runbook could act on. The probe adds a step to a live-account task.
- **Proposed fold.** Drop the row, and say why in one line.

### m4. The probe accounts become household members (OWNER FORK)

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:61-64 against `roles/stalwart/accounts.json` (`a-test`, `a-test2`, both
  `role: "User"`).
- **Defect.** The rule makes `probe` and `probe2` members, so test logins that drills and
  sessions use can read every household contact. The spec never mentions them.
- **Proposed fold.** **OWNER FORK.** (a) Probe accounts set `"household": false`. (b) They stay
  members, which matches ruling 4 literally. Recommendation: (a). Test credentials should not
  read household data, and M10 can flip `probe2` for one check.

### m5. The facts record's unconfirmed items 6 to 9 have no disposition

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:78-84 against facts:117-132.
- **Defect.** The probe table carries items 1 to 5, 10, and 11. Items 6 (assisted discovery), 7
  (whether the group's address accepts mail), 8 (the login-name ban), and 9 (the current share's
  ACE) are silently dropped. Item 7 has consequences: a group address that accepts and expands
  mail would be a new household-wide recipient.
- **Proposed fold.** One line for each: 6 is covered by cutover step 3's add-by-URL fallback, 8
  by the 401 stop, and 9 is moot because the old book is deleted. Item 7 joins the probe table,
  and its fallback is an inbound rule that rejects mail to `household@ward.907.life`.

### m6. The group's roles and permissions are unstated

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:59-64; facts §1 (a Group needs `roles` and `permissions`).
- **Defect.** The spec does not say what roles or permissions the Group carries. Whether a member
  inherits them is unverified, so membership might widen a user's permissions beyond the share.
- **Proposed fold.** Name the values. Probe 1 also checks that a member's
  `current-user-privilege-set` on its own home, and its own permissions, are unchanged by joining.

### m7. Ruling 4 and the stated behavior disagree

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:12-13, :34 against :62, :69-71.
- **Defect.** Ruling 4 says "every member created on Stalwart", and the Brief says "every
  Stalwart user". The behavior covers only `role: "User"` entries in `accounts.json` without
  `household: false`, and it excludes accounts made by hand.
- **Proposed fold.** Restate the behavior in the Brief as "every `User` in `accounts.json`
  unless it opts out", and record that this is Claude's reading of ruling 4 under ruling 3's
  idiom call.

### m8. Nobody is named to create the book, and the Worker has no way to find it

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:52-55, :119.
- **Defect.** Stalwart auto-creates a default book when an account is first accessed (facts §3),
  so the `phonebook` account may end up holding two books. The spec doesn't say who creates
  "Global Address Book", or how the Worker learns its href.
- **Proposed fold.** `stalwart-apply` creates the named book. The Worker reads its URL from a
  `WARD_BOOK_URL` var. The ward task records the href and leaves the default book empty and
  unshared.

### m9. Delete guard for an empty D1

- **Severity:** minor. **Tag:** `optional`.
- **Location:** spec:121-122.
- **Defect.** If D1 reads back zero contacts, from a binding mistake or a bad restore, the
  reconcile deletes every card. The household book is then empty in every client and in
  mail-filters for up to 15 minutes after D1 recovers. The base spec guards phone uploads for
  the same reason (base spec:145-148).
- **Proposed fold.** If D1 holds no contacts while ward holds cards, the reconcile writes nothing
  and records `error`. One unit case covers it.

### m10. The cutover's checks are counts, and the old book stays writable

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:18, :153-163.
- **Defect.** "Card count equals D1's non-Blacklist count" can pass when the wrong set of cards
  lands. "18 cards" is a figure from 2026-10-22, and the book can change before Pass 3. The
  second operator holds read-write on the old book (`servers/docs/cutover-log.md:108`), so an
  edit made between the export and the delete is lost. Also, the export runs "as Geoff", but no
  step says how the tool gets his password without crossing the session.
- **Proposed fold.** The check compares the set of card UIDs against D1's set of non-Blacklist
  contact IDs. The export records its own count and does not compare it against 18. The
  household's freeze on handset edits extends to the old book. The tool reads
  `STALWART_PASSWORD_GEOFF` from the age store without printing it, per the plan's Global
  constraints (plan:87-91).

### m11. The mail-filters fallback misses the second operator and needs a code path

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:143-147.
- **Defect.** mail-filters builds a list for each `mailbox: true` account (`mail-filters:531`).
  The spec covers only Geoff's session. The fallback login also cannot use `setup`, which looks
  for `.mailbox` accounts only (`mail-filters:100`).
- **Proposed fold.** The probe and the fallback cover every mailbox account's session. The
  fallback looks up the `phonebook` entry by name, without the `.mailbox` filter, and the spec
  says so.

### m12. The amendment lists none of the base sections it changes

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:3-5, :88, :125, :137.
- **Defect.** The base spec's "Contacts follow the T54W's contact format" and "D1 holds six
  tables" (base spec:96-101) become false. The success criteria (base spec:15-20) gain no ward
  criterion. `CLAUDE.md`'s secrets invariant does not list `WARD_PASSWORD`. Plan Task 2.1's
  entry exports only `fetch` (plan:594), and a cron needs `scheduled`.
- **Proposed fold.** Add a short "Base spec and plan sections this amends" list that names each
  item, so the plan fold applies it.

### m13. The Survey section sits outside the rulings and conflicts with Task 3.1

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:15 ("three things"), :189-194.
- **Defect.** The switch from a copied core to `github:glw907/survey#v1.3.0` has no ruling in
  the list, and it is not one of the "three things" the Brief names. Task 3.1's acceptance needs a
  byte-identical copy checked by `scripts/check-core.sh` (plan:964-966). `CLAUDE.md`'s "copy-on-
  create" rule and the plan's "blocked on Survey S1" both contradict it. The tag `v1.3.0` and
  `DESIGN.md`'s "Plain app" recipe exist (`~/Projects/survey`, `DESIGN.md:186`).
- **Proposed fold.** Record the provenance of the Survey change, or move it to its own direct
  change. Name what replaces the `check-core.sh` criterion, for example a pinned lockfile entry
  that `npm run check` verifies.

### m14. The stop and the down-ward promises have no zero-fetch test

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:45-46, :127-131, :170-171.
- **Defect.** "Makes no more ward requests" covers the push too, but the unit criterion doesn't
  count fetches. "If ward is down, the web app and the phones keep working" has no test.
- **Proposed fold.** The stop test asserts zero fetches from both the push and the reconcile
  while stopped. One integration case fails the push on a web edit and proves the action still
  commits and returns its normal response.

### m15. Three vCard renderings are ambiguous

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** spec:92, :100-101.
- **Defect.** "`N` is left empty" could mean an omitted `N` or `N:;;;;`. The email label "other"
  has no standard `EMAIL` `TYPE` value (from memory, unverified). The `TEL` value type for
  `+1 907-555-0123` and `*97` (URI or `VALUE=text`) is unstated, and Stalwart's strict parser
  decides whether a card is accepted.
- **Proposed fold.** Name each rendering. Check them in the M5 live reconcile, which is the
  evidence that Stalwart accepts them.

### m16. The end-to-end GNOME criteria can fail for the client's reasons

- **Severity:** minor. **Tag:** `optional`.
- **Location:** spec:177-178.
- **Defect.** "Within 15 minutes in GNOME Contacts" depends on the client's refresh interval
  (unverified), not only on the Worker. "A write from GNOME Contacts gets an error" is
  ill-defined, because an offline-capable client may keep the edit locally and show no error.
- **Proposed fold.** Time the web-edit check on ward, with a multiget as Geoff, and then confirm
  it in GNOME after a manual refresh. For the write check, the criterion is that the card's ETag
  on ward is unchanged after the attempt.
