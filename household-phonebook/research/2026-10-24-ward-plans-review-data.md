# Ward plans review: data integrity and failure risk

Date: 2026-10-24. Lens: data integrity and failure risk, in the order the plans run things.

Targets:

- **P**: `phonebook` `docs/plans/2026-10-07-phonebook-phases-0-2.md` at `5005006` (branch `ward-plan`),
  the changes from `origin/main` read in context. Pass 1 is out of scope. Line numbers are the
  file at `5005006`.
- **S**: `household-phonebook/plans/2026-10-24-ward-servers-plan.md` at `f441968`.
- Both implement `household-phonebook/specs/2026-10-24-ward-address-book-design.md` (**D**).
  Ward config read at servers `c358b0f`: `roles/stalwart/stalwart-apply`,
  `roles/stalwart/build-plan`, `roles/mail-backup/server-restore`, `secrets/render.sh`,
  `scripts/drill-remote.sh`, and `docs/runbook.md`.

Counts: 0 blockers, 4 majors, 11 minors (9 `correctness`, 2 `optional`), and no owner forks.

## Majors

### M1. Pass 3 never applies migration 0002 to the remote database before the deploy

- Severity: major. Tag: `correctness`. Location: P:1499-1502 (cutover step 1), P:1414 (Task
  3.6), compared with P:1194 (Pass 2 close).
- Defect: the Pass 2 close says "Apply migrations remotely, deploy". Cutover step 1 says only
  "Close the code: ... Deploy." Task 3.6 adds `migrations/0002_contact_fields.sql`, and nothing in
  Pass 3 runs `wrangler d1 migrations apply phonebook --remote`. Tests apply migrations through
  `applyD1Migrations` (Decision 5), so the gate passes, but production then runs code that reads
  and writes columns the remote schema lacks. Every contact query fails. The failure first shows
  at step 4, when `seed.sql`, written against the migration schema (Task 3.4, "Consumes ... the
  migration schema"), fails to apply. By then the household is under the handset-edit freeze, and
  no step names the recovery.
- Proposed fold: cutover step 1 reads "Apply migrations remotely (`wrangler d1 migrations apply
  phonebook --remote`), then deploy." The migration goes first because an added optional column
  is safe for the Pass 2 code still serving. Then add one check: `wrangler d1 migrations list
  phonebook --remote` shows no pending migration.

### M2. The restore runbook line can delete the only copy of the old book

- Severity: major. Tag: `correctness`. Location: S:230-233 (T3, the `docs/runbook.md` lines); D:351-352
  ("Owed to the plan").
- Defect: the new line says "after the restore, run `sudo stalwart-apply`, and if Geoff's old
  Global Address Book came back in his account, Claude deletes it by its href". `server-restore`
  swaps in the whole store (`roles/mail-backup/server-restore:21`, step 5). A snapshot from before
  cutover step 10 holds the old book in Geoff's account and no "Household list (old)" in the
  second operator's account. The old book "comes back" in that case too, so the line deletes the
  only live copy. The restic snapshots then hold the only copy, and only for `--keep-within 35d`
  (D:259). The same holds for a Hetzner image from before the move.
- Proposed fold: change the line to this. "If the old book came back in Geoff's account, run
  `move-book.ts list`. Delete the old book by href only when 'Household list (old)' is present
  with the old book's UID set. Otherwise run `move-book.ts copy` first, then `delete`." The
  script's own refusals already guard the delete. Point the runbook at the phonebook operations
  guide for the commands.

### M3. Deleting the source rests on a UID-set check alone, so a lossy round trip goes unseen

- Severity: major. Tag: `correctness`. Location: P:1473-1486 (Task 3.7 `copy` and `delete`); D:250-258.
- Defect: `copy` GETs each source card and PUTs it into the moved book. It "checks that the moved
  book's count and UID set equal the source's", and `delete` re-checks ETags and the UID set. No
  check compares content. Stalwart stores a parsed card and re-serializes it on read
  (`card/update.rs:157`, `:201`, cited at P:1125-1126), so the PUT side parses the GET's output
  again. Any property that doesn't survive that second parse (a `PHOTO`, an `X-` property, a
  parameter Stalwart normalizes) is lost without a signal. Then the source is deleted. This is the
  only irreversible delete of real household data in either plan, and after 35 days restic holds
  no copy either.
- Proposed fold: after the copy, GET each moved card. Compare the SHA-256 of each body with the
  same UID's source body, since both are Stalwart serializations. `copy` reports the UIDs that
  differ, and `delete` refuses unless none differ or the conductor passes `--accept <uid>...`
  after Geoff has seen the list. Add one unit case where a fake server alters one property.

### M4. The design names the second operator in the public initiatives repo

- Severity: major. Tag: `correctness`. Location: D:56 (ruling 9, "into a book in [the second operator]'s
  account"), D:245 ("signs in as `operator2` (the second operator's login)"); compare S:108-110 ("The public initiatives repo names
  household members by role only").
- Defect: `glw907/initiatives` is public (`gh repo view`: `PUBLIC`). Both plans build on a
  design that names a household member. Commit `4be9b1c` introduced the name, and no remote branch
  holds it yet (`git branch -r --contains 4be9b1c` is empty), so it can still be kept out of
  public history. Neither plan's privacy check covers this repo: S's close checks "every public
  file and PR body the pass touched" in servers, and P lives in a private repo. P:1550 names the
  login `operator2` (the second operator's login), which is fine in the private phonebook repo.
- Proposed fold: before the `phonebook-ward` branch is pushed, rewrite D:56 as "into a book in
  [the second operator]'s account" and D:245 as "signs in as the second operator (`a-operator2`)".
  Fold the change into `4be9b1c` with a local fixup rebase, which needs no force push because
  nothing has been pushed. Also grep this folder's `research/` for the name before the push.

## Minors

### m1. The 401 stop keys on the password hash, so a wrong `WARD_USER` stalls the cutover for 24 hours

- Severity: minor. Tag: `correctness`. Location: P:1085-1087, P:1116-1120 (the stop); P:1517-1524
  (cutover step 6).
- Defect: the stop clears when "the secret's hash differs". A 401 at step 6 caused by a wrong
  `WARD_USER` stores the hash of a password that was correct. Fixing the user leaves that hash
  unchanged, so the writer waits up to a day for its daily trial in the middle of the sitting.
- Proposed fold: hash `WARD_USER` and `WARD_PASSWORD` together (SHA-256 of `user:password`), so
  any credential change clears the stop. The rule's unit case covers a changed user.

### m2. Step 6 has no standing answer when the first fill fails, and the ops guide has no "turn the writer off"

- Severity: minor. Tag: `correctness`. Location: P:1517-1524; P:1399-1403 (Task 3.5 ward procedures).
- Defect: if step 6's reconcile isn't `ok` or `check-book.ts compare` exits non-zero, nothing
  says what to do. After cutover, a writer defect has no named stop either. Ward is a projection
  of D1, so no data is lost, but the procedure is missing.
- Proposed fold: one line in step 6: "On a failure, `wrangler secret delete WARD_PASSWORD`. The
  writer returns to `disabled`, the old book still stands, and the sitting continues without
  steps 10 and 11." Task 3.5 gains the same procedure as "Turn the ward writer off".

### m3. Piped `wrangler secret put` values need `printf '%s'`

- Severity: minor. Tag: `correctness`. Location: P:1517-1522.
- Defect: "each value piped". An `echo`, or a here-string, adds a newline. A newline in the
  password gives a 401 and sets the stop. A newline in the URL fails the PROPFIND.
- Proposed fold: name the form, `printf '%s' "$value" | npx wrangler secret put NAME`. Step 6's
  `ok` check already catches a bad value.

### m4. Rotation doesn't say where the Worker's new value comes from

- Severity: minor. Tag: `correctness`. Location: P:1399-1402; D:222-224; S:183-184.
- Defect: "ward first ..., the Worker's `WARD_PASSWORD` last". Under the base plan's "Secrets in
  the age store", a new value sits in a worktree overlay until its workstation PR merges and
  `sync.sh --local` runs. A Worker put from `~/.local/secrets` before then sends the old value.
  The stop then holds that hash, and nothing changes until someone puts the value again.
- Proposed fold: the procedure names the source. The Worker's value comes from the same overlay
  `render.sh` read, or the Worker step waits until after the merge and `sync.sh --local`. Then the
  Phones page's ward line shows `ok`.

### m5. `probe-run.sh` passes the whole process environment to `wrangler dev`

- Severity: minor. Tag: `correctness`. Location: P:1169-1177 (Task 2.12).
- Defect: `CLOUDFLARE_INCLUDE_PROCESS_ENV=true` makes every environment variable a binding. If
  the shell has sourced `~/.local/secrets`, that includes every secret in it. The test checks
  only spawned arguments. It never checks what `wrangler dev` prints at startup, and that output
  includes a bindings table. Unverified: whether that table masks process-environment values.
- Proposed fold: start `wrangler dev` under `env -i` with only `PATH`, `HOME`, the three `WARD_*`
  values, and `CLOUDFLARE_INCLUDE_PROCESS_ENV`. Discard its output or send it to a 0600 file
  under `~/.local/share/phonebook/ward/`. Extend the test to assert that the password never
  appears in captured output.

### m6. `probe-run.sh` reconciles any book under `/dav/card/`, and a reconcile deletes cards

- Severity: minor. Tag: `correctness`. Location: P:1182-1183, P:1155-1157.
- Defect: a reconcile DELETEs every card the local D1 lacks, and the script ends by deleting the
  fixture cards. The only guard is the `https://mail.907.life/dav/card/` prefix. With a login
  that can write the target, a slip in `--book` or `--login` would empty a real book, such as the
  household book or, before step 10, Geoff's old one through the second operator's read-write
  share.
- Proposed fold: `probe-run.sh` refuses any book outside `/dav/card/probe/` and any login other
  than `probe@probe.907.life`. `check-book.ts` only reads, so it keeps the wider prefix.

### m7. A re-run of `copy` can overwrite the second operator's edits to the moved book

- Severity: minor. Tag: `correctness`. Location: P:1476-1480, P:1546-1547.
- Defect: on a refusal, step 10 runs `copy` again. `copy` "removes any moved card the source
  lacks" and re-PUTs changed cards. The second operator has just been asked to check his client,
  which shows the moved book, so an edit or an add he makes there before the delete is undone
  without a word.
- Proposed fold: `copy` records each moved card's ETag after writing it. A re-run refuses to
  overwrite or remove a moved card whose ETag has changed since then, and names the UID. Also
  tell him not to edit either book until the delete is done.

### m8. A stop during the `probe2` household flip leaves a test login reading household data, with no named recovery

- Severity: minor. Tag: `correctness`. Location: S:341-351 ("At the phonebook cutover"); S:365
  (standing answer "A stop after T5's first live write").
- Defect: steps 1 to 4 grant `probe2` read access and then remove it. A crash or stop between
  them leaves `probe2`, whose password the test tooling uses, with read access to the household
  book. The only remaining signal is the hold line.
- Proposed fold: one standing answer: "A stop during the flip: apply ward from `main` first. The
  grant step's whole-map set removes `probe2`, and its read-back must name two members. Then send
  the state."

### m9. Stalwart upgrades don't re-check the deny-list or the read-only enforcement

- Severity: minor. Tag: `correctness`. Location: S:190-218 (T3, `disabledPermissions` as a deny-list);
  servers `docs/runbook.md:285` (the upgrade rule).
- Defect: `Merge` with a list of 90 disabled names fails open. An upgrade that adds a mail or
  submission permission grants it to `phonebook` without a signal, and an upgrade that changes
  ACL checks could let members write. A member's write is then overwritten by the reconcile, and
  the member loses that edit silently. The upgrade rule checks only mailbox counts on the drill
  copy.
- Proposed fold: add one line to the runbook's upgrade rule. After a Stalwart upgrade, rerun S
  T5 steps 4 and 6 (send refused, RCPT refused), and diff the new schema's `Permission` enum
  against the 661 names recorded at planning. Any new mail-family name goes into the set. The
  member-403 check stays at the cutover, since it needs the `probe2` flip.

### m10. A 412 or 5xx row write should touch only the status column

- Severity: minor. Tag: `optional`. Location: P:1083-1084, P:1130-1131.
- Defect: "records the status and keeps the ETag". An implementation that upserts the whole row
  from its in-memory view can overwrite a concurrent push's newer ETag and hash. The hash rule
  repairs this at the next run, so nothing is lost, but each clobber costs a needless PUT.
- Proposed fold: state the rule "a 412 or 5xx updates the status column only", and add a unit
  case in `db/ward.ts`.

### m11. Step 10's wait on the other conductor's deletion adds a cross-session dependency with no safety value

- Severity: minor. Tag: `optional` (over-ceremony). Location: P:1544-1546.
- Defect: "if it is still there, ask `conductor-servers` to finish it before step 11". An extra
  copy in the second operator's account is redundant, never a risk. Step 11, mail-filters, doesn't
  depend on it, so the wait adds coordination and no protection.
- Proposed fold: record whether his own imported copy is still present, and hand its deletion to
  `conductor-servers` as a note, not a gate.

## Checked and sound

These were traced and need no fold:

- **The reconcile's read order.** It runs the PROPFIND before it reads D1 (P:1121). Every commit
  lands in D1 before its push (P:1088), so a card the reconcile sees on ward is already in its D1
  read, and the reconcile can't DELETE a card that was just pushed. A write that loses an
  `If-Match` race either gets 412 or leaves the row's hash out of step with the render, and the
  next run repairs both.
- **The writer's off state across deploys.** All three values are secrets set by `wrangler
  secret put` (P:1517-1522), and there is no `secrets.required` block (P:686-689), so a deploy
  neither carries nor wipes them. `wardConfig` is null while any one is unset (P:1063), so a stop
  partway through step 6's three puts stays `disabled`. The Pass 2 close checks `wrangler secret
  list` and `disabled` (P:1204-1206).
- **`stalwart-apply` partial runs.** The plan hash is written before `ensure_certificate`
  (`stalwart-apply:156-157`), and S T4 calls the book step on all three paths. So a book step
  that fails after a restart runs again on the next "nothing changed" apply. The step sets the
  whole `shareWith` map in one call and reads it back, so a partial grant can't stand.
  `build-plan` names a missing password and prints nothing (`build-plan:14-22`), and `render.sh`
  fails on an unset name, so an apply from a host that lacks `STALWART_PASSWORD_PHONEBOOK` stops
  and never sets an empty password.
- **A ward restore.** `stalwart-apply` re-applies every account and its credentials on every run
  (`stalwart-apply:109`), the stop's daily trial releases a restore-induced 401, and a changed
  ETag re-PUTs every card. Only the old-book half needs M2.
- **`values.age` conflicts and value drift.** The base plan's "Secrets in the age store" covers
  merging a binary conflict without regenerating a value, and cutover step 6's `ok` check would
  catch a value that differs between ward and the Worker.
- **Household data at rest.** Fixtures are synthetic (P:1017-1018). The move record holds ETags
  and UIDs only, is 0600, and is deleted at step 12. Every tool prints counts, hrefs, and IDs,
  never a body. The `## Decisions` excerpts mask passwords and IPs.
- **The probe teardown.** It runs on the probe domain only, sets `shareWith` to `{}` and reads
  it back, and the standing answer runs `teardown` on a failed probe. The empty "Ward probe" book
  that remains is destroyed at cutover step 5.
