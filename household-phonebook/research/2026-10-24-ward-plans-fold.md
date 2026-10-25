# Ward plans fold

Date: 2026-10-24. Fold agent for the two ward plans, working from the three plan reviews in this
folder (`2026-10-24-ward-plans-review-mechanics.md`, `-contract.md`, `-data.md`).

Targets:

- **P**: phonebook `docs/plans/2026-10-07-phonebook-phases-0-2.md`, branch `ward-plan` from
  `5005006`.
- **S**: `household-phonebook/plans/2026-10-24-ward-servers-plan.md`, from `f441968`.

Method: each finding was checked against source, a doc, or the live workstation before folding.
Optional findings were dropped. Where two or three lenses found the same thing, the fix went in
once at the root. Nothing was committed, and no live system was written.

Evidence read for this fold:

- Stalwart `v0.16.27` in `/tmp/stw-src/s`:
  - `crates/dav/src/card/delete.rs:76-99`: an account member may delete a container.
  - `crates/jmap/src/api/acl.rs:188-201` and `jmap-proto/src/object/addressbook.rs:295-312`: the
    read returns all four rights per sharee.
  - `crates/groupware/src/cache/mod.rs:333` and the cached schema: the default book is created
    only when `defaultHrefName` is set, and its default is `"default"`.
- RFC 4918 section 10.2: a depth-1 request applies "to the resource and its internal members only
  ("Depth: 1")".
- `pass-1-probe:docs/research/2026-10-24-probe-recovery-notes.md:66-67`: the Blacklist travels
  as the group `Blocklist`.
- Cloudflare "Local Data" page: `--persist-to` must be repeated on every local command.
- Node's TypeScript page: type stripping is on by default, file extensions are mandatory, and
  `paths` is unsupported. The workstation runs Node `v24.21.0`.
- Evolution Data Server `e-source-refresh.c`: `interval-minutes` defaults to 60.
- pavilion's Evolution Data Server source for GNOME Online Accounts:
  `ContactsUrl=.../dav/card/geoff%40907.life/`.
- servers `c358b0f`:
  - `accounts.json`: the DAV account name is `name@domain`.
  - `roles/mail-backup/server-restore`: a restore replaces the whole store.
  - `docs/runbook.md:285`: the upgrade rule.
  - `docs/cutover-log.md:106`: the GNOME Online Accounts account was added over D-Bus.
- `scripts/privacy-check.sh`: clean on both plans.

## Mechanics review

| Finding | Disposition |
| --- | --- |
| B1 | Folded, with contract M6. The fake answers PROPFIND with the collection's own response first, using Stalwart-form absolute hrefs (Task 2.10). `planReconcile` reads only `.vcf` children of the book path, after percent-decoding (Task 2.11). The client refuses a DELETE of the book URL. `check-book.ts` and `move-book.ts` read member hrefs by the same rule. There is a unit case and a mutation. |
| M1 | Folded. `Blocklist` is used in Tasks 2.9, 2.10, 2.11, and 3.2 and in cutover step 6. A "Spec changes this plan owns" note in P, and a "Design terms" line in S, say the design's `Blacklist` means the phones' `Blocklist`. Pass 1's own wording is left alone. |
| M2 | Ruling (below). Folded as an "Order" note under P's pass table and an opening line in the probe fold step. |
| M3 | Folded, with data M1. Cutover step 1 applies migrations remotely before deploying, then checks that none are pending. |
| M4 | Folded. `probe-run.sh` builds first, since `main` imports the generated Worker (Decision 4). It runs migrations, fixtures, and `wrangler dev` against one fresh `--persist-to` directory, quoting the Local Data page. S's T6 inherits this through the script. |
| M5 | Folded. Task 3.7 refuses a source outside `/dav/card/geoff@907.life/` after decoding, and its table test gives the source in both forms. Cutover step 10 names the encoded href. `list` prints the href for the conductor to check. |
| M6 | Folded, with data m1. The stop hashes `WARD_USER:WARD_PASSWORD` (Tasks 2.2, 2.10, 2.11), with a unit case where a changed login releases the stop. This is recorded as plan-owned in P's spec-changes list. |
| M7 | Folded. T4's read-back requires `mayRead` true and every other right false. The fake answers with the four-right shape. |
| M8 | Folded. A standing-answer table now follows the cutover sitting. Step 10 runs only after steps 6, 7, and 9 pass. The fallback when ward is out of reach: unset `WARD_PASSWORD`, finish the phone cutover, skip steps 10 and 11, and report. Pass 3's pre-step reads T6's result. |
| M9 | Folded. Step 9 proves the 15-minute bound on the server: the contact's `ward_cards` ETag in remote D1 changes. GNOME Contacts is checked against its 60-minute refresh default, which is quoted. Step 7 names the second-account fallback after `cutover-log.md:106`. |
| M10 | Folded elsewhere (planning session: scrub plus squash before push). Both plans pass `privacy-check.sh`. Cutover step 11 in P named the second operator's account; it now names him by role and entry id. |
| Minor 1 | Folded. Pass 2 ceiling is 10.5M and Pass 3 is 8.5M. The basis sentence now says each ceiling sits at the top of its range. |
| Minor 2 | Folded. T4 fails on zero books as well as two, with the cause cited. There is a test for each. |
| Minor 3 | Folded, with contract m9. |
| Minor 4 | Folded, with data m6. |
| Minor 5 | Folded. Steps 5 and 6 give every flag, and step 6 waits for the next quarter-hour tick. |
| Minor 6 | Folded, with contract m7. |
| Minor 7 | Folded. Under a one-way verdict the probe fold's removal list now also covers step 9's ward handset check and Task 3.5's dropped-field procedure. |
| Minor 8 | Folded. The `.ts` scripts run under `node`, importing only relative `.ts` paths, per the quoted Node docs. `belongs.ts` has no runtime import. |
| Minor 9 | Refused. Geoff is present at cutover step 7, which already asks about thinkpad-x1. A pre-flight item would hold the launch for an answer that only adds or drops one client check. |
| Minors 10 to 19 | Dropped (optional). |
| F1 | Ruling (below). Folded into S's Brief, Entry, Tasks intro, Part A close, "After merge", and Close. |

## Contract review

| Finding | Disposition |
| --- | --- |
| M1 | Folded. Task 3.6's merge test runs end to end through Task 2.8's upload path in `prov-upload.test.ts`, reading the D1 row and the `changes` row. A whole-row UPDATE is a second mutation. |
| M2 | Folded. The first 401 writes its own time as the trial time. Task 2.11 adds the 25-hour-old trial meeting a 401: one fetch, the trial time becomes now, and zero fetches 15 minutes later, with a mutation. |
| M3 | Folded. T4 tests a read-back missing one member. |
| M4 | Folded. Task 3.7 has one table test for every `delete` refusal, each asserting no DELETE in the request log, plus a success row. |
| M5 | Folded. T5 step 4 runs curl with `-v` and passes only on a quoted SMTP 5xx. A transport failure is a step failure, and step 2 serves as the control. |
| M6 | Folded, with mechanics B1. |
| m1 | Folded. Each variable is unset in turn in a table test, plus an empty-string row. |
| m2 | Folded. The test now counts exactly one request in total. |
| m3 | Folded. A stray href holding a contact's UID must be deleted before that contact's PUT. |
| m4 | Folded. The fake holds the reconcile's PROPFIND while a push lands. The stale `If-Match` gets 412, and the next run ends `ok`. |
| m5 | Folded. Task 3.2 has one integration case per action. |
| m6 | Folded. Step 6's count must be nonzero and equal the seed's contacts outside `Blocklist`. |
| m7 | Folded, with mechanics minor 6 and M9. The write targets an existing card in the book under `phonebook`'s path. The evidence is that its `ward_cards` ETag is unchanged after the next `ok` reconcile. |
| m8 | Folded. One hand-written golden card is compared byte for byte (Task 2.9). |
| m9 | Folded, with mechanics minor 3. `setup` puts a unique `example.com` `EMAIL` on the first card and prints it, and the fake test covers it. |
| m10 | Ruling (below). Folded into the probe fold step. |
| m11 | Folded. S's "Design terms" note says the conductor's read-only checks also sign in as `phonebook`, and Part B's PR records it. The design file is not edited. |
| m12 | Folded. `test/scripts/probe-run.test.sh` uses PATH stubs to record argv and output. It asserts the password is in neither and that no `.dev.vars` exists. |
| m13, m14, m16 | Dropped (optional). |
| m15 | Folded. The fake hangs the first of three PUTs: one write is attempted, the result is `partial`, and the stop is untouched. |

## Data review

| Finding | Disposition |
| --- | --- |
| M1 | Folded, with mechanics M3. |
| M2 | Folded. S's restore line now points to the phonebook operations guide's old-book procedure. That procedure is added to Task 3.5, and `move-book.ts`'s refusals keep the only copy. |
| M3 | Folded in a narrower form. `copy` compares each moved card's body hash with its source's, and `delete` refuses on any difference, with a table-test row for it. No `--accept` flag was added: on a mismatch the old book stays and Geoff sees the UIDs in the sitting. The flag would add machinery for a case the sitting already handles. |
| M4 | Folded elsewhere (planning session). Both plans were checked as under mechanics M10. |
| m1 | Folded, with mechanics M6. |
| m2 | Folded. Step 6's standing answer covers this, and Task 3.5 gains "Turning the writer off". |
| m3 | Folded. Step 6 pipes each value with `printf '%s'`. |
| m4 | Folded. In the rotation procedure the Worker's value comes from `~/.local/secrets` only after the workstation PR merges and `sync.sh --local` runs. |
| m5 | Folded. `wrangler dev` starts under `env -i` with only the names it needs, its output goes to a 0600 file that is deleted at the end, and the test checks the captured output. |
| m6 | Folded. `probe-run.sh` accepts only the `probe` login and that account's home. `check-book.ts` keeps the wider prefix, since it only reads. |
| m7 | Partly folded. The second operator holds off edits to both books until the delete (owner sitting 3, step 10). Refused: the moved-card ETag record. He is asked to hold off, and the moved book is a copy whose source still exists until the delete, so the mechanism costs more than the risk it removes. |
| m8 | Folded. S has a standing answer: apply ward from `main` first, and the read-back must name two members. |
| m9 | Partly folded. A runbook line after `:285` reruns the send and RCPT checks after a Stalwart upgrade. Refused: the diff against the 661 permission names, which needs a stored list and a diff step. The two live checks cover the mail permissions the deny list exists for. |
| m10, m11 | Dropped (optional). |

## Planning-session rulings

Each ruling below has one clearly correct answer, so none is a fork for Geoff.

- **Mechanics F1: one packet.** Part B's servers branch stacks on `ward-probes`. Part A's PR opens
  as a draft and waits, and Geoff gets one packet holding Part A's PR, Part B's PR, and the
  workstation PR. Phonebook Pass 2 still waits only on Part A's T2 verdict line, not on a merge.
- **Contract m10: option (a).** The probe fold records whether the T54W's edit screen changes a
  name in place. Ruling 8 goes back to Geoff before Pass 3 only if it does.
- **Mechanics M2: merge order.** `ward-plan` merges to `main` first. `pass-1-probe`, which is
  finishing now, is then reconciled onto `main`, and the probe fold runs on `main`'s copy of the
  plan.
- **Data M4 and mechanics M10: privacy.** The planning session handles this (scrub plus squash
  before push). This fold checked both plans and fixed the one name in P.
- **Mechanics M1: `Blocklist`.** The probe found the name. It is folded everywhere the ward parts
  of the plans used `Blacklist`, and a note maps the design's term onto it.

## Path and ceilings after the fold

| Plan | Path minutes | Ceiling |
| --- | --- | --- |
| Phonebook Pass 2 | 140 (185 if Task 2.9 outlasts 2.7) | 10.5M |
| Phonebook Pass 3 | 100 (140 if Task 3.7 outlasts 3.4) | 8.5M |
| Servers Part A | 75 | 1.2M |
| Servers Part B | 170 | 3.5M |

The total is 485 path minutes against the design's 315, under twice.

## Effect on the approved design

None of the folds changes the design's outcome. Four refine its terms or tighten a check:

- The stop hashes the login with the password, so a corrected login clears it.
- `Blacklist` means the phones' `Blocklist`.
- The conductor's read-only checks sign in as `phonebook`.
- The move's delete also refuses a card whose body changed in the copy.

One standing answer is worth Geoff's notice. If the ward bar is out of reach in the cutover
sitting, the phones cut over without the writer, and the old book stays in place untouched.

## Verification read

Source: `2026-10-24-ward-plans-fold-verification.md` (P at `2acf47b`, S at `e44bcda`). It was
folded under the same rules. New evidence: Stalwart `crates/groupware/src/lib.rs:30-60` (`RFC_3986`
includes `@`) and `cache/calcard.rs:48-57` (the base path percent-encodes the owner's account
name), so every DAV href carries `%40`; and `git diff 7d03184 origin/pass-1-probe`, which shows
Pass 1's plan edits at 33 insertions and 10 deletions.

| Finding | Disposition |
| --- | --- |
| V1 | Ruling (below) and folded. P's "Order" note and its probe fold step now describe the reversed order. The lines the rebase must keep are listed below. `pass-1-probe` is not edited here. |
| V2 | Folded. P's new "Book's form" global constraint says every URL or href comparison decodes both sides and drops one trailing slash. The member filter (Task 2.11), the DELETE refusal (Task 2.10), and the scripts' prefix checks (Tasks 2.12 and 3.7) cite it. The fake serves the encoded form, citing `RFC_3986`. Unit cases use an encoded `WARD_BOOK_URL`, plus a refusal row with no trailing slash. |
| V3 | Folded. `WARD_BOOK_URL` and every `--book` hold the full URL, `https://mail.907.life` plus Stalwart's encoded href. The form is defined once, in P's "Book's form" constraint. S's T1 prints and takes books in that form and refuses a path. `wardConfig` treats a value without `https://` as unset, and the scripts refuse one. Each has a unit case. Cutover steps 5 and 6, T6, and S's cutover check use the URL. |
| V4 | Folded. T5 step 4 pipes `curl -v` through `grep -E '^< [0-9]{3}'`, so only server reply lines show, and the step says no client line is shown. |
| V5 | Refused in part. `privacy/patterns.txt` lives in the private servers repo, and that repo legitimately holds the second operator's login in `accounts.json`. Adding his bare first name there would fail servers' own check. The history half is the planning session's squash before push. The current text of both plans and this record passes the check. |
| V6 | Folded. The row is renamed "Ward cannot be reached, or a ward step cannot pass". It names every skipped step, adds a STATUS line naming a follow-up sitting and its steps, and step 12 records only the secrets still set. Step 6's final failure now points to that row. |
| V7 | Folded. `seed.ts apply` prints the seeded count outside `Blocklist` (Task 3.4, with a unit case). Step 4 records it, and step 6 compares against it. |
| V8 | Folded. Step 6 now reads "member hrefs, `<id>.vcf`". |
| V9 | Folded. The exception for the stop field's SHA-256 is added to P's global constraint and to the repo `CLAUDE.md` secrets invariant. |
| V10, V11, V12 | Dropped (optional). |
| V13 | Folded (an indent fix under Owner sittings item 3). |

Path minutes and ceilings are unchanged: the folds add unit cases inside existing tasks.

### Planning-session rulings (verification read)

- **V1: reverse the merge order.** `pass-1-probe` merges to `main` first, rebased onto `main`'s
  `docs/` layout with its plan edits carried from `docs/superpowers/plans/` into `docs/plans/`.
  Then `ward-plan` rebases onto that `main`, keeping Pass 1's lines beside the ward amendment, and
  the probe fold runs on the result.
- **V5: refused in part,** as recorded above.

### Lines the `ward-plan` rebase must keep

The source is `git -C /var/home/glw907/Projects/phonebook show
origin/pass-1-probe:docs/superpowers/plans/2026-10-07-phonebook-phases-0-2.md` at `d043ad0`.
Line numbers are in that file. Each item is an insertion against `7d03184`, the base it shares
with `main`, and replaces the lines noted.

1. **41-42 (PV-9)**, the token-ceilings paragraph. It replaces "the next segment boundary." with
   that phrase followed by "Pass 1's ceiling equals its estimate, so the 80% check-in at its close
   boundary is expected (PV-9)." This conflicts with the ward edit to the same paragraph. Keep
   both: the ward sentences come before "At 80%", and PV-9's sentence ends the paragraph.
2. **122**, "The phones": `custom.protect` becomes `static.auto_provision.custom.protect`.
3. **328-329 (PV-2)**, Task 1.2 Files: adds `probe/scripts/probe-puts.sh`.
4. **339-341 (PV-2)**, Task 1.2 Interfaces: the `probe-puts.sh [--local]` bullet.
5. **367-370 (PV-2, PV-11)**, Task 1.2 acceptance: the `probe-puts.sh` prefix bullet and the
   `.gitignore` `*.sql` bullet.
6. **451-452**, the runbook's pre-probe record: adds "every `linekey.N.type`, `.value`, and
   `.label` the phone holds".
7. **477-483**, question 5: the `static.auto_provision.custom.protect` rename, and the "Line keys
   (Geoff, 2026-10-07 ...)" probe step.
8. **488-491**, the runbook's sourcing: the T54W administrator guide for firmware 96.86, and the
   "secondary source, probe to confirm" rule. It replaces the "Yealink V85 admin guide" sentence.
9. **512-513 (PV-2)**, sitting step 3: "through `probe/scripts/probe-puts.sh`, never a raw body".
10. **577**, the probe fold step: "It carries the line-key findings into the Pass 4 outline
    unchanged." This conflicts with the ward edit, which rewraps the paragraph. Keep the sentence
    after "the largest upload delay for the V-12 bound." and before "If question 4 shows".
11. **1157-1161**, Pass 4 outline: the "Line keys (Geoff, 2026-10-07)" bullet, placed before
    "Whether deploys move to CI."

`main`'s copy differs from `7d03184`'s only in three `docs/superpowers/` path citations. Those
are taken as on `main`.
