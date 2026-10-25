# Ward plans review: contract and criteria

Date: 2026-10-24. Lens: contract and criteria. Every acceptance check must be testable, name its
fixture and the reason it would fail, and be unable to pass vacuously, and every promise in the
design must map to a check.

Targets:

- **P** = phonebook `docs/plans/2026-10-07-phonebook-phases-0-2.md` at `5005006` (branch
  `ward-plan`), the diff from `origin/main` read in context. Pass 1 is out of scope. Line numbers
  are the file at `5005006`.
- **S** = `household-phonebook/plans/2026-10-24-ward-servers-plan.md` at `f441968`.
- **D** = `household-phonebook/specs/2026-10-24-ward-address-book-design.md`, the design both
  plans implement.

Checked against: servers `c358b0f` (read-only), the cached stalwart-cli schema, and the Survey
tag. All 90 `disabledPermissions` names in S:192-214 are members of the schema's `Permission`
enum (661 names), and the count is exactly 90. `v1.3.0^{}` resolves to `21194176a79c...`, as
P:1253 states.

Counts: 0 blocker, 6 major, 16 minor (13 `correctness`, 3 `optional`). One owner fork, inside
m10.

## Promise map

| Design promise | Where the plans check it | Verdict |
| --- | --- | --- |
| Writer off until configured (D:179-180) | P:1075-1076, P:1116, Pass 2 close P:1204-1206, cutover P:1501-1502 | Mapped; m1 |
| One at a time, first 401 ends the work (D:181-182) | P:1085-1087 | Mapped; m15 |
| 401 stop, daily trial, release (D:210-215, D:338-339) | P:1116-1120, P:1140-1141 | **M2** |
| Reconcile decisions, hash and ETag (D:187-196) | P:1121-1135 | Mapped; **M6**, m3, m4 |
| Empty guard (D:204-205) | P:1128-1129 | Mapped |
| Blacklist rule (D:162-168) | P:1044-1046, P:1089, P:1133, P:1304-1305 | Mapped |
| Field-scope merge (D:170-175, D:274-277) | P:958-960, P:1437-1440 | **M1** |
| Per-user grants and read-back (D:104-114, D:329-332) | S:256-268, S:270-290 | **M3** |
| Credential cannot send (D:322-327) | S:279-284 | **M5** |
| Move to the second operator's account (D:245-259, D:272-273) | P:1449-1491, P:1539-1547 | **M4**, m2 |
| mail-filters sees the new book (D:228-231) | P:1548-1553, S:153 | Mapped; m9 |
| Live probe-book reconcile, twice (D:284-289) | S:294-301, P:1511-1516 | Mapped; m13 |
| End to end (D:290-293) | P:1533-1538, S:339-351 | Mapped; m7 |
| Ruling 8's revisit trigger (D:53-54) | None | m10 |

## Major

### M1. The field-scope merge test runs only against the pure merge, so the commit path can clear web-only fields unseen

- Severity: major. Tag: `correctness`.
- Location: P:1418-1419 (tests are `test/unit/merge.test.ts` and `test/integration/db.test.ts`),
  P:1437-1440.
- Defect: D:171-173 promises "A handset edit never clears or rewrites an email, an address, an
  organization, or a note." Clearing would happen in the commit, not in `mergeUpload`. Task 2.8's
  commit writes D1 (P:984-985), and Task 2.2 never fixes how `fields` is stored (P:712-725). If the
  contact row holds its fields as one JSON value, an UPDATE written from `PhoneFields` drops all
  four web-only fields on every handset edit, not only on the rename or delete that ruling 8
  accepts. A unit test on `mergeUpload` passes anyway, because it never reads D1. "A handset
  delete's change-log row holds the email" (P:1440) is a commit-path property too, since change rows
  are written beside the commit (P:724-725), so a unit test of the merge cannot assert it.
- Proposed fold: in Task 3.6, run the design's merge case end to end through Task 2.8's upload
  path, and add `test/integration/prov-upload.test.ts` to the task's Files. Seed a contact, have
  the web add an email, record a served row, and PUT an upload that edits a number. Then read the
  D1 row and assert that the number changed and the email, address, organization, and note are
  unchanged. Add the handset-delete case there, reading the `changes` row. Keep the existing
  mutation ("letting the merge compare the new fields fails the test"), and add one more: an
  UPDATE that writes the whole fields value fails the test.

### M2. A daily trial answered 401 has no test that it records its time, so a stuck stop can retry every 15 minutes into the auto-ban

- Severity: major. Tag: `correctness`.
- Location: P:1116-1120 (the criterion), P:1140-1141 (the only tests).
- Defect: the criterion says the trial "records the trial's time on a 401". The tests listed
  are "the stop releases on a successful trial and on a changed hash" and zero fetches "apart from
  the daily trial". No case covers a failed trial. Suppose an implementation never writes the
  trial time on a failing trial. Both listed tests still pass, yet every tick then retries: 96
  failed logins a day. D:212-215 names the cost: Stalwart bans after 100 a day and "could ban the
  monitor Worker's address with it". The plan also never says what trial time the first 401 writes
  (D:338-339 asks for "the last trial's time").
- Proposed fold: add an integration case to Task 2.11. Set the stop with a trial time 25 hours old
  and have the fake answer the trial's PROPFIND 401. Assert one fetch, a stop whose trial time is
  now, and zero fetches on a second run 15 minutes later. Add the mutation "not writing the trial
  time on a 401 fails a test". State that the first 401 writes its own time as the trial time.

### M3. The grant read-back has no test for a missing member, the failure it exists to catch

- Severity: major. Tag: `correctness`.
- Location: S:257-259 (the criterion), S:266-267 (the tests).
- Defect: D:110-112 requires the read-back to fail "unless `shareWith`'s keys equal the member set
  exactly". The tests cover "a read-back with an extra key or with `mayWrite`". Consider an
  implementation that checks only that each key read back is a member holding `mayRead` alone.
  It passes both tests and accepts a map that silently dropped `a-operator2`. The fold
  verification's M2 raised this exact gap ("read-back can't catch a missing grant"). T5's live
  session check (S:277-278) catches it once, at this apply, but not on any later apply, which is
  where the read-back is the only net.
- Proposed fold: add to T4's test list: "a read-back missing one member fails it". Name the
  fixture as `tests/fakes/curl-jmap` answering `AddressBook/get` with only `a-geoff`'s id.

### M4. The move script's delete guards are tested for one of five refusals, and no test asserts the DELETE is never sent

- Severity: major. Tag: `correctness`.
- Location: P:1481-1489.
- Defect: the delete is the cutover's one irreversible act against Geoff's data. D:254-257: the
  script "refuses if any card was added, changed, or removed since the copy". The criteria add a
  refusal when the moved book's UID set differs, and one for a source outside `/dav/card/geoff/`.
  The tests cover only "the refusal when a source ETag changed after the copy". An implementation
  that compares the ETags of the recorded hrefs alone passes that test, then misses a card added
  to the source after the copy and deletes it unmoved. None of the refusal tests asserts that the
  fake received no DELETE, so a refusal that prints and then deletes anyway also passes.
- Proposed fold: give Task 3.7 one table test against the fake CardDAV server. Its rows: a source
  card added, changed, and removed after the copy; a moved book whose UID set differs from the
  record; and a `--source` outside `/dav/card/geoff/`. Each row asserts a nonzero exit, the UIDs or
  the href named, and no DELETE in the fake's request log. Add one success row: the source DELETE
  is the last request, and a GET of the source afterward answers 404.

### M5. The live "cannot send" check passes on any curl failure, including one that never reached SMTP

- Severity: major. Tag: `correctness`.
- Location: S:279-284.
- Defect: the pass condition is "It fails at AUTH, MAIL FROM, or RCPT, and `stalwart-jmap find`
  prints nothing." Several faults make curl exit nonzero and leave the mailbox empty with no
  permission involved: a TLS or connect error, a missing `FILE`, or a typo in the URL. The check
  then reports that the permission set blocks sending without having tested it. This is the
  design's only live proof of the owed "submission login fails" (D:326-327), and the standing
  answer treats a credential that can send as a stop (S:361).
- Proposed fold: run curl with `-v` and record the SMTP reply code at the stage that failed. The
  pass condition becomes an SMTP 5xx reply (or 535 at AUTH) quoted in `## Decisions`. A curl
  transport exit (6, 7, 26, 35, or 60) is a step failure, not a pass. Step 2's CardDAV read with
  the same password is already the control that the credential itself works, so say so in step
  4.

### M6. No fixture models the PROPFIND depth-1 self-response, so the reconcile's "delete what D1 lacks" is untested against the collection's own href

- Severity: major. Tag: `correctness`.
- Location: P:1121-1124 ("An href D1 does not hold as a ward-bound contact gets a DELETE"),
  P:1057-1058 (the fake), P:1178-1181 (`check-book.ts`).
- Defect: a depth-1 PROPFIND returns the collection itself as one of its responses. The criterion
  sends a DELETE to every href that D1 does not hold, and nothing excludes the collection's own
  href or limits the set to `<id>.vcf` members. As owner, the `phonebook` login passes the
  collection-delete check (`card/delete.rs:93-101`, D:257-258), so a reconcile can delete the
  household book itself. "DELETEs go first" means that happens before any PUT. Suppose the fake
  CardDAV server lists only cards, the natural shortcut. Then every unit and integration case
  passes, and `check-book.ts compare` passes its unit test but always fails live. The first net is
  then S T6, whose failure "is not a stop" (S:363), or the cutover sitting's step 5.
- Proposed fold: in Task 2.10's Files entry for `test/helpers/fake-carddav.ts`, require PROPFIND
  depth 1 to return the collection's own response first, with absolute hrefs in Stalwart's form
  (`/dav/card/<account>/<book>/<id>.vcf`). In Task 2.11, add the unit case "the collection's own
  href is never planned as a DELETE" and the mutation "dropping the member-href filter fails it".
  Task 2.12's `check-book` unit test reads the same fixture shape.

## Minor

### m1. "Unconfigured" is tested only with every variable unset

- Severity: minor. Tag: `correctness`. Location: P:1063-1065, P:1075-1076, P:1116.
- Defect: `wardConfig` is null when any of the three variables is unset or empty. A test with all
  three unset passes an implementation that checks only one. Cutover step 6 sets the three
  variables one `secret put` at a time (P:1518-1519), so a cron tick between two puts can run with
  the configuration half set.
- Fold: a table test with each variable unset in turn, the others set, and a fourth row with one
  set to `""`. Each row asserts zero fetches and `disabled`.

### m2. The move script's 401 test counts "exactly one request after a 401", which contradicts "no further request"

- Severity: minor. Tag: `correctness`. Location: P:1470-1472.
- Defect: "the first 401 ends the script with no further request ... A test counts exactly one
  request after a 401." Read literally, the test allows one extra request.
- Fold: "A test whose first request answers 401 counts exactly one request in total."

### m3. "DELETEs run before PUTs" has no case

- Severity: minor. Tag: `correctness`. Location: P:1124; D:191-192.
- Defect: the order exists so that "a stray card holding a contact's UID is cleared before its
  create" (D:191-192). No unit case asserts the order. Reversed, the create meets the stray card's
  UID (`card/update.rs:252-258`) and fails for one run.
- Fold: a `planReconcile` case with a stray href holding a contact's UID asserts that the DELETE
  comes before that contact's PUT.

### m4. "A push and a reconcile interleaved" names no interleaving point

- Severity: minor. Tag: `correctness`. Location: P:1140.
- Defect: if the test runs them in sequence, it passes without any interleaving.
- Fold: the fake holds the reconcile's PROPFIND response while a push PUT lands, then releases it.
  Assert the reconcile's stale `If-Match` gets 412 and `partial`, and that the next run ends `ok`
  with ward matching D1.

### m5. No test proves that a web action pushes at all

- Severity: minor. Tag: `correctness`. Location: P:1299-1304.
- Defect: the only push test on the web side is the failure case. If one action, say delete or a
  group move, never calls `pushContacts`, the reconcile still delivers the change within 15
  minutes. The cutover's end-to-end check ("within 15 minutes", P:1536-1537) then passes too,
  even though D:183 promises a push after each web commit.
- Fold: one integration case per action (add, edit, delete, group move, group rename) asserting
  that the fake received the expected PUT or DELETE.

### m6. Cutover step 6's set comparison passes at zero equals zero

- Severity: minor. Tag: `correctness`. Location: P:1523-1524.
- Defect: suppose the seed applied nothing. Then `check-book.ts compare` exits 0, the reconcile
  reads `ok` (the empty guard fires only when ward holds cards), and the client check in step 7
  matches an empty web app.
- Fold: step 6 also requires the count that `compare` prints to be nonzero and to equal the seed's
  contacts outside `Blacklist`, read from `seed.sql`'s review.

### m7. "A write from GNOME Contacts gets an error" names neither the book nor server-side evidence

- Severity: minor. Tag: `correctness`. Location: P:1537-1538.
- Defect: until step 10, Geoff's client shows two books named "Global Address Book", the old one
  writable, and a new contact may default to his Personal book. GNOME Contacts can also show an
  edit locally from its cache. The check can therefore fail falsely, or pass on client behaviour
  alone.
- Fold: edit an existing card in the book listed under `phonebook`'s path, then confirm with
  `check-book.ts` or a PROPFIND that the card's ETag is unchanged.

### m8. The vCard round trip goes through a parser the same hand writes

- Severity: minor. Tag: `correctness`. Location: P:1040-1043, P:1434-1436.
- Defect: a renderer and a test-only parser that share one escaping bug (an unescaped comma or
  semicolon, say) round-trip cleanly. Only the newline escape carries a mutation. The live run
  shows that Stalwart accepts a card, not that the card follows RFC 6350 section 3.4.
- Fold: one golden card, the awkward contact's exact expected CRLF text written from section 3.4
  and section 3.2, compared byte for byte.

### m9. Probe 1's mail-filters count depends on a synthetic email that T1 never puts on the card

- Severity: minor. Tag: `correctness`. Location: S:123-126, S:153.
- Defect: the pass condition is "the count is 1" on "the first synthetic card's address", but
  `setup` only says it PUTs "two synthetic cards". If the cards carry no `EMAIL`, the count is 0,
  and a failed probe 1 sends the design back to Geoff (S:357). `correspondents` reads
  `ContactCard` `emails` (`roles/mail-filters/mail-filters:224-226`).
- Fold: `setup` puts one `EMAIL` at an `example.com` address on the first card, prints that
  address, and its fake test covers it.

### m10. Ruling 8's revisit trigger has no hook

- Severity: minor. Tag: `correctness`. Location: P:604-620 (the probe fold); D:53-54.
- Defect: D:53-54 rules "Revisit if the Pass 1 probe shows handset renames are routine." The
  probe fold, which the diff amends, never reads that question, so the trigger cannot fire.
  "Routine" is also not something the probe measures: every handset name edit is a delete and an
  add in the base merge (D:173), and the probe's edits are scripted.
- **OWNER FORK** (what "routine" means):
  - (a) The probe fold records whether the T54W edit screen changes a name in place, which would
    make renames easy and likely common. If it does, ruling 8 goes back to Geoff before Pass 3.
  - (b) Drop the trigger, and let the ops guide's undo (P:1399-1400) stand.
  - (c) Revisit after a month of use, judged from the change log's rename count.
  - **Recommendation: (a).** It adds one clause to the probe fold and asks Geoff only if the
    evidence points that way.

### m11. "Only the Worker and `stalwart-apply` sign in as it" is false under both plans

- Severity: minor. Tag: `correctness`. Location: D:92-93; S:275, S:287; P:1158-1159,
  P:1517-1518.
- Defect: `ward-book-check.sh home phonebook`, `principals phonebook`, and `check-book.ts
  compare` all sign in as `phonebook`. A close reviewer holding the design's sentence will flag
  these tools, or a later reader will trust a claim that is false.
- Fold: S records under `## Decisions` that the conductor's read-only tools also sign in as
  `phonebook`, each stopping at the first 401. The design's sentence gains "and the conductor's
  read-only check tools".

### m12. `probe-run.sh`'s password-handling criterion has no test file or fixture

- Severity: minor. Tag: `correctness`. Location: P:1151-1152, P:1165-1168.
- Defect: "a test greps each script's spawned commands for it", but the Files list holds only
  `test/unit/check-book.test.ts`, and the gate runs only `shellcheck` on the shell script.
- Fold: name a test, for example a PATH stub for `wrangler` and `curl` that records argv. Assert
  that the password is in no argv and that no `.dev.vars` file exists.

### m13. T6's acceptance only records counts, so it cannot fail

- Severity: minor. Tag: `optional`. Location: S:300-301, S:363.
- Defect: "the run's counts go under `## Decisions`" is a recording step. The pass condition
  (`ok`, every card answering 200, an empty book) appears only as narration.
- Fold: state T6's pass condition as its acceptance, and point a miss to the S:363 standing
  answer.

### m14. T5 step 5 restates steps 1, 2, and 7

- Severity: minor. Tag: `optional` (over-ceremony). Location: S:285-287.
- Defect: only `principals phonebook` is new in step 5. The rest repeats checks that already
  passed.
- Fold: step 5 becomes the `principals` check alone.

### m15. "The first timeout ends the run's remaining writes" has no case

- Severity: minor. Tag: `correctness`. Location: P:1129-1131; D:336-337.
- Defect: the integration list has "a 5xx or a timeout gives `partial`", but no case shows the
  writes after the first timeout being skipped. Serial 10-second timeouts scale with the number of
  writes.
- Fold: the fake hangs the first of three PUTs. Assert one write attempted, `partial`, and the
  stop field untouched.

### m16. T4 never tests the rename of a book whose name differs

- Severity: minor. Tag: `optional`. Location: S:251, S:263-268.
- Defect: "names that book 'Global Address Book' ... when its name differs" has no case. T5 step
  2 checks the name live once.
- Fold: one case where `AddressBook/get` answers another name and a `/set` carrying the name
  follows, and one where the name already matches and no `/set` is sent.
