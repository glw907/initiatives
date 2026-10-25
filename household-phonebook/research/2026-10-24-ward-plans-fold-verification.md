# Ward plans fold verification

Date: 2026-10-24. A fresh-context verification read of the two folded plans. The reader had no
part in writing or folding them. Read-only: no commit, and no live system touched.

Targets:

- **P**: phonebook `docs/plans/2026-10-07-phonebook-phases-0-2.md` at `2acf47b` (branch
  `ward-plan`). Scope is the ward amendment, the diff from `origin/main`. Pass 1 is out of scope.
- **S**: `household-phonebook/plans/2026-10-24-ward-servers-plan.md` at `e44bcda`.
- Against the fold record `research/2026-10-24-ward-plans-fold.md`, the three reviews, and the
  design `specs/2026-10-24-ward-address-book-design.md`.

Evidence read: Stalwart `v0.16.27` (`crates/groupware/src/lib.rs:30-60` `RFC_3986`,
`cache/calcard.rs:48-57` and `:140-152`, `cache/mod.rs:333`, `config` `:111-114`,
`jmap-proto` `addressbook.rs:295-312`, `jmap/src/api/acl.rs:177-201`); the Cloudflare Scheduled
Handler and Local Data pages; pavilion's GOA `accounts.conf` and EDS source (key names only);
`~/.local/secrets` (names only); servers `c358b0f` `accounts.json`, `build-plan`,
`scripts/privacy-check.sh`, and `privacy/patterns.txt` (shape only); phonebook `pass-1-probe` and
`origin/main` trees; the branch history of both worktrees.

## Counts

| Severity | Correctness | Optional |
| --- | --- | --- |
| Blocker | 0 | 0 |
| Major | 5 | 0 |
| Minor | 4 | 4 |

## Findings

### Major

**V1. The reconcile drops Pass 1's own plan edits, and Pass 1's conductor never sees the Order
note.** `correctness`. P:62-64, P:614-617, P:1665-1685.

- Defect: the Order note calls `pass-1-probe`'s copy "the pre-amendment copy", but that branch has
  edited its copy (`git diff 7d03184 pass-1-probe -- docs/superpowers/plans/`, 43 lines). The
  edits are PV-9 in the ceilings paragraph, PV-2 (`probe-puts.sh`), PV-11, the
  `static.auto_provision.custom.protect` renames, the T54W admin guide sourcing, and the line-key
  probe step. Two of them carry Geoff's 2026-10-07 line-key ruling: the probe fold's "carries the
  line-key findings into the Pass 4 outline", and Pass 4's line-key item. None of these is in P.
  P has no `linekey`, `PV-`, or `probe-puts` anywhere. A reconcile that takes "`main`'s copy",
  which is what the note invites, drops Geoff's ruling from the plan. The edits also overlap two
  amended hunks: the token-ceilings paragraph (P:44-51) and the probe fold step (P:616-634). Both
  will conflict. The note also lives only on `ward-plan`. Pass 1's conductor works from
  `pass-1-probe`'s copy and STATUS, which carry no Order line, so following its own copy it runs
  the probe fold there.
- Fold: rewrite the note to say that `pass-1-probe`'s plan edits are carried into `docs/plans/` on
  the reconcile. Neither copy wins wholesale. Conflicts are expected at the ceilings paragraph and
  at the probe fold step, and the reconciled probe fold keeps both the ward items and the line-key
  carry. Before Pass 1 closes, send `conductor-phonebook` the Order line (or add it to
  `pass-1-probe`'s STATUS), so that the probe fold waits for `ward-plan`'s merge.

**V2. Percent-decoding is one-sided, so the member filter matches nothing and the book-URL DELETE
refusal never fires against the real, encoded URL.** `correctness`. P:1076-1079, P:1107-1108,
P:1148-1151, P:1239-1240, P:1547.

- Defect: Stalwart percent-encodes the account name in every DAV href, and its `RFC_3986` set
  includes `@` (`groupware/src/lib.rs:30-60`; `cache/calcard.rs:48-57` builds
  `/dav/card/<encoded name>/`). `WARD_BOOK_URL` is copied from that href (P:1598-1599), so it holds
  `phonebook%40ward.907.life`. Two rules decode only one side:
  - The filter keeps "after percent-decoding, a direct child of `WARD_BOOK_URL`'s path". It
    decodes the member href but not the book path.
  - The client refuses "a DELETE whose URL, percent-decoded, equals the book URL". The book URL is
    compared as stored.

  Taken literally, no member ever matches. Every run then sees an empty book, PUTs each card as a
  create (a 412 under `If-None-Match: *`), and records `partial` forever. `check-book.ts compare`,
  which reads by the same rule, sees zero cards at step 6. The refusal is inert for the one URL it
  guards. A trailing slash (`.../default` against `.../default/`) also slips past an equality test.
  The fake gives the form as `/dav/card/<account>/<book>/<id>.vcf` without saying `%40`. A fake that
  serves a literal `@` passes every test against code that fails in production.
- Fold: decode both sides and normalize one trailing slash before any comparison, in the filter,
  the refusal, and the scripts' prefix checks. The fake serves Stalwart's encoded form
  (`/dav/card/probe%40probe.907.life/<book>/<id>.vcf`), citing `lib.rs`'s `RFC_3986`. The unit
  cases for the filter, for the collection's own href, and for the refusal use an encoded
  `WARD_BOOK_URL`, with one row giving the DELETE URL without its trailing slash.

**V3. The form of the book argument is undefined: a Stalwart href is a path, and the tools
disagree on what they accept.** `correctness`. S:124, S:130, S:290-291; P:1193-1197,
P:1235-1239, P:1592-1593, P:1598-1600.

- Defect: the hrefs Stalwart returns, and the ones T1's `home` and `setup` print, are absolute
  paths (`/dav/card/...`). Step 6 sets `WARD_BOOK_URL` to "that href". A bare path is not a URL the
  Worker's `fetch` accepts, since a Worker has no base URL. `check-book.ts` "refuses a book
  outside `https://mail.907.life/dav/card/`", so a path is refused at step 6. `probe-run.sh`
  compares a path prefix, and T6 and step 5 hand it `<"Ward probe" href>`. The design has the same
  gap ("`WARD_BOOK_URL` holds its href", D:103). Neither plan says whether `--book` and
  `WARD_BOOK_URL` hold a path or a full URL.
- Fold: T1's `home` and `setup` print the full URL, `https://mail.907.life` plus the href. P says
  that `WARD_BOOK_URL` and every `--book` argument are that full URL. `wardConfig` treats a value
  that does not start with `https://` as unset, and both scripts refuse one. Each gets a unit case.

**V4. T5 step 4's `curl -v` prints the `phonebook` password in base64.** `correctness`.
S:294-302.

- Defect: contract M5's fold adds `-v` so that the SMTP reply can be quoted. curl's verbose mode
  echoes every client command, `> AUTH PLAIN <base64 of the login and password>` included. That
  puts `STALWART_PASSWORD_PHONEBOOK` in the main loop's output, and possibly in the excerpt "quoted
  under `## Decisions`". This breaks T1's and the design's "never printed" rule and P's "no real
  credential passes through a session" constraint (P:123-127). The step's "passwords masked" note
  applies to the record, not to the terminal.
- Fold: keep only the server's replies, with `-v 2>&1 | grep -E '^< [0-9]{3}'`. Or write
  `--trace-ascii` to a 0600 file and read only its `<` reply lines, deleting the file afterwards.
  Either way, the step says that no client line is shown.

**V5. The privacy check does not cover the second operator's bare first name, and the unpushed
history still holds it.** `correctness`. Fold record :39 and :124-125; S:110-112.

- Defect: the current text is clean. A whole-word search for the name finds nothing in S, P, or
  the fold record, and `privacy-check.sh` passes on all three, on the reviews, and on the design.
  But `privacy/patterns.txt` holds only the full name and the mail address, not the bare first
  name or the login. So "`scripts/privacy-check.sh`: clean on both plans" proves less than it
  claims. On branch `phonebook-ward` (8 commits ahead of `origin/main`, public repo), commit
  `4be9b1c` adds the first name three times, and `e44bcda`'s removal lines carry it again. The
  fold defers the squash to the planning session. Nothing has been pushed yet, so the risk is
  still open. The phonebook branch (`5005006`, `2acf47b`) holds it once each, but that repo is
  private.
- Fold: add the bare first name and the login form to `privacy/patterns.txt`. Squash or rewrite
  `phonebook-ward` before the push, as ruled. Run `privacy-check.sh` over the output of
  `git log -p origin/main..HEAD`, not only over the files.

### Minor

**V6. The "ward unreachable" row is incomplete.** `correctness`. P:1657, P:1661, P:1647-1649.

- Defect: "the ward bar is out of reach" is undefined, and it reads as "ward cannot be reached".
  The row names the steps to finish (8, 9's phone checks, and 12) and to skip (10 and 11). It
  says nothing of steps 5 to 7 and 9's ward checks when ward drops before or during them. It
  names no re-entry: who later runs steps 5 to 7, 9's ward checks, 10, and 11, and in what
  sitting. Step 12 still records "the Worker's three ward secrets" after one is deleted. Step 6's
  row also ends with the writer `disabled`, but it does not skip step 11, which waits for an `ok`
  reconcile that never comes.
- Fold: rename the row "Ward cannot be reached". Name each skipped step, including step 7's
  client check, the `probe2` request, and 9's ward checks. Add a STATUS line that names the
  follow-up sitting and its steps. Step 12 records the secrets that remain set. Step 6's
  final-failure branch also skips steps 7's ward checks, 9's ward checks, 10, and 11.

**V7. Step 6's expected count has no source.** `correctness`. P:1606-1608 against P:1425-1430.

- Defect: the count "equals the seed's contacts outside `Blocklist`, from step 4's review". Task
  3.4's `review.txt` lists conflicts, unmapped numbers, `ZZ Probe ` names, and unmapped
  attributes, and prints no count. Counting from D1 would be circular with `compare`.
- Fold: `seed.ts apply` prints the seeded contact count outside `Blocklist`, Task 3.4 gets a unit
  case for it, and step 4 records the count.

**V8. Step 6 says "UIDs", but `check-book.ts` compares hrefs.** `correctness`. P:1196-1197,
P:1606.

- Defect: `compare` PROPFINDs only. It compares hrefs (`<id>.vcf`) with D1's IDs and never reads
  a card's `UID`.
- Fold: write "the book's member hrefs, `<id>.vcf`, equal ...". If UIDs matter here, add a
  multiget to `compare`.

**V9. The global constraint and `CLAUDE.md` say `WARD_PASSWORD` never appears in D1, but the stop
stores a SHA-256 of it there.** `correctness`. P:116-117, P:765-766; `CLAUDE.md` secrets
invariant.

- Defect: the design endorses the hash (D:210). The invariant as written still reads as broken,
  and a pass-end security reviewer will flag it.
- Fold: add "apart from the stop field's SHA-256 of `WARD_USER:WARD_PASSWORD` (Task 2.2)" to both
  lines.

**V10. A child href without `.vcf` is never repaired and never shows in `compare`.** `optional`.
P:1148-1151.

- Fold: plan a DELETE for any direct child, and drop the `.vcf` test. The collection's own
  response is already excluded by the direct-child rule.

**V11. Step 9's GNOME check can take up to an hour.** `optional`. P:1624-1626.

- Defect: mechanics M9 asked for a check after a manual refresh. The fold quotes the 60-minute
  default and stops there.
- Fold: name a manual refresh in the sitting, or accept the wait and say so.

**V12. Under the one-way verdict, the probe fold's removal list leaves the segment plan and the
path minutes stale.** `optional`. P:640-649, P:623-630.

- Defect: Pass 1's step 9 counts on `pass-1-probe` read 7 of 10, below R1's 4 of 5. If the gate
  goes one-way, Task 2.9 loses its pair (Task 2.7), and segment C and the 140/185 path change.
  The list removes the tasks but does not re-segment.
- Fold: add "re-segment C and restate Pass 2's ward path" to the one-way list.

**V13. A continuation line under Owner sittings item 3 has lost its indent.** `optional`. P:286.

- Defect: "checks that his client" starts at column 0. It renders as a lazy continuation of the
  list item, but the source reads as broken.

## 1. Did each blocker and major close at the cited location?

| Finding | Where it closed | Verdict |
| --- | --- | --- |
| Mechanics B1 | P:1076-1079 (fake), P:1107-1108 (refusal), P:1146-1151 and 1161-1166 (filter, unit and mutation), P:1239-1240, P:1547 | Closed in substance; the decode is one-sided (V2) |
| Mechanics M1 | P:1060-1062, 1114, 1162, 1364-1365, 1608; P:363-364; S:401 | Closed; evidence verified at `recovery-notes.md:66-67` |
| Mechanics M2 | P:62-64, P:616-617 | Partly; V1 |
| Mechanics M3 / data M1 | P:1579-1581 | Closed |
| Mechanics M4 | P:1212-1218; S:316-317 | Closed |
| Mechanics M5 | P:1555-1559, 1564-1565, 1631-1632 | Closed |
| Mechanics M6 / data m1 | P:766, 1109-1112, 1143-1144; P:365-366 | Closed, consistent across Tasks 2.2, 2.10, 2.11, 3.5 and step 6's row |
| Mechanics M7 | S:270-272, S:281-282 | Closed; verified |
| Mechanics M8 | P:1629, P:1652-1661, P:1286-1287 | Closed, with gaps (V6) |
| Mechanics M9 | P:1622-1628, P:1611-1613 | Closed (V11 optional) |
| Mechanics M10 / data M4 | P:1641-1643 (role and entry id) | Text clean; history open (V5) |
| Contract M1 | P:1502-1507 | Closed |
| Contract M2 | P:1109-1110, P:1141-1145, P:1175-1178 | Closed |
| Contract M3 | S:282 | Closed |
| Contract M4 | P:1561-1567 | Closed |
| Contract M5 | S:298-302 | Closed, but introduces V4 |
| Contract M6 | as mechanics B1 | Closed (V2) |
| Data M2 | S:234-239; P:1466-1468 | Closed |
| Data M3 | P:1547-1553, P:1564 | Closed in the narrower form recorded |

## 2. Contradictions and build order

- Within P: `WARD_BOOK_URL` and `--book` have no agreed form (V3). Step 6 says UIDs where
  `compare` reads hrefs (V8). The invariant wording conflicts with the stop field (V9).
- P against S: consistent. The terms (`WARD_USER`, `Blocklist`), T6 against Pass 3's pre-step,
  "At the phonebook cutover" against step 7, the hand-offs (T2 line, Pass 2 merge, Part B merge,
  After merge step 4), and the secret names all agree. The path total of 140 + 100 + 245 = 485
  matches.
- Against the design: the four recorded refinements stand, and nothing else changes an outcome.
  The design's "holds its href" carries the same gap as V3.
- Order: the cross-repo sequence holds. Part A runs before Pass 2, Pass 2 merges before Part B,
  Part B merges before the cutover, and `STALWART_PASSWORD_PHONEBOOK` reaches `~/.local/secrets`
  at S's After merge step 1, before step 6 reads it. The `ward-plan`-first reconcile can build,
  but it must carry Pass 1's plan edits, and it needs a way to reach Pass 1's conductor (V1).

## 3. New mechanisms: quoted or proven

| Mechanism | Status |
| --- | --- |
| The child-`.vcf` href filter | The concept is proven (RFC 4918 section 10.2; `card/delete.rs:76-99`). The decoding is under-specified (V2). |
| The book-URL DELETE refusal | Present. Inert as written against the encoded URL (V2). |
| `user:password` stop hash | Consistent across Tasks 2.2, 2.10, and 2.11, Task 3.5, and step 6's row, with a unit case. Recorded as plan-owned (P:365-366). |
| Remote migration step | `wrangler d1 migrations apply phonebook --remote` before the deploy, then `migrations list --remote`. Ordered correctly. |
| Four-key rights read-back | Proven. `AddressBookRight::all_rights` holds four rights (`addressbook.rs:304-312`), `rights()` emits each (`acl.rs:188-201`), and `mayRead` maps to `Read` and `ReadItems` only (`:299`), so a `{mayRead: true}` set reads back with the other three false. |
| `%40` owner prefix | Proven on pavilion. GOA has `CardDavUri=` and EDS has `ContactsUrl=`, both `.../dav/card/geoff%40907.life/`. Stalwart's `RFC_3986` encodes `@`. |
| Default book only with `defaultHrefName` | Proven (`cache/mod.rs:333`; config `:113`). |
| `probe-run.sh` build and `--persist-to` | The build is justified by Decision 4. The Local Data quote matches the page. `/cdn-cgi/local/scheduled` needs no flag, per the Scheduled Handler page. |
| Cutover standing-answer table and the "ward unreachable" path | Present. Gaps in V6 and V7. |
| T5 step 4 SMTP 5xx check | Sound as a test. Leaks the credential through `-v` (V4). |

## 4. Household names

S, P, and the fold record hold no household member's name: a whole-word search finds none, and
`privacy-check.sh` passes. The second operator appears by role and as entry `a-operator2`. The
only name-like token is `Pat Lee` (P:953), a synthetic merge-test name that predates the
amendment. The open item is the history and the pattern list's coverage (V5).
