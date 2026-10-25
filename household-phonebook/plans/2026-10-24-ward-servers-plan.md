Initiative: household-phonebook

# Ward address book, servers half: plan

## Brief

This plan builds the `servers` half of the approved design
`household-phonebook/specs/2026-10-24-ward-address-book-design.md` (head `b7e8990`, its fold in
`research/2026-10-24-ward-address-book-fold.md`): the probes on the probe domain, a contacts-only
`phonebook` account on `d-ward` that owns the Global Address Book, a per-member read grant that
`stalwart-apply` sets and reads back on every run, the account's secret, and the records. The
phonebook half is Passes 2 and 3 of `phonebook`'s `docs/plans/2026-10-07-phonebook-phases-0-2.md`.

Both parts run under the servers repo's adapter, which is the base plan's "Adapter facts for the
servers repo" (`self-hosting/plans/2026-10-17-self-hosting-plan.md`), and their conductor is
`conductor-servers`. The plan runs as two passes:

- **Part A, the probes** (T1, T2, and its close). The executor is `servers-ward-probes`, on
  servers branch `ward-probes`. It needs nothing from phonebook and runs before phonebook Pass 2
  starts; it may run now, beside phonebook Pass 1. Its T2 verdict gates phonebook Pass 2: a failed
  probe 1 or 2 returns the design to Geoff before any ward code is written.
- **Part B, the account** (T3 to T7). The executor is `servers-ward-address-book`, on servers
  branch `ward-address-book`, stacked on `ward-probes`, and workstation branch
  `ward-address-book`. It starts once phonebook Pass 2 has merged, since T6 runs Pass 2's Worker
  code. Part A's PR waits for Part B, and Geoff gets one packet for both parts and the
  workstation PR through `conductor-servers` (the planning session's ruling on the mechanics
  review's F1). They merge before phonebook Pass 3's cutover sitting.

Risk class `auth-data` with the `live-account` flag: Part A signs in to live test mailboxes, and
Part B adds a credential and writes to a live mail server. The planned path is 245 minutes
against the design's 90: Part A 75 and Part B 170. The difference is the two passes' closes (15
and 30), T1 on the path now that the split leaves it no pair (35), the live checks the design's
review fold added, the submission, recipient, session, and read-back checks in T5 (35), and the
plan review's added test cases (10), none of which the design's figure carried. This plan alone
exceeds twice its share; across the initiative's three passes the path is 485 minutes against
the design's 315, under twice.

## Entry

Part A:

- No other executor works the worktree `.claude/worktrees/ward-probes` or its branch (`pgrep -f`,
  `git status`, `claude agents --json`).
- The servers main checkout is on `main`, clean, and level with `origin/main`.

Part B:

- Phonebook Pass 2 has merged to phonebook `main`; `conductor-phonebook` says so to
  `conductor-servers`. Part A's close is done and `ward-probes` is pushed.
- No other executor works the worktree `.claude/worktrees/ward-address-book` or either branch,
  and no other pass holds a ward hold line in STATUS.
- The servers main checkout is on `main`, clean, and level with `origin/main`.
  `git -C ~/.dotfiles diff --quiet -- secrets/values.age` passes.

Part A's executor is launched from the servers main checkout. Part B's is launched from there with
`--add-dir` for `/var/home/glw907/Projects/phonebook` and `/var/home/glw907/.dotfiles`, as the
base plan's "Repos and sessions" sets out for a pass that edits more than one repo.

## Pre-flight

None for either part. The design's pre-flight says no new step needs Geoff before Pass 2, and
Claude generates
`STALWART_PASSWORD_PHONEBOOK` with `secret-set.sh` in its worktree form. The live steps run on
rules the workstation already holds: `scripts/apply.sh ward --apply` and `--check`, ssh to ward
under the 2026-10-22 server rule, and the `secret-set.sh` worktree form. The test mailbox
passwords are `STALWART_PASSWORD_TEST` and `STALWART_PASSWORD_TEST2` (`docs/runbook.md:727`).

## Facts this plan relies on

Each was read at planning, from servers `main` at `c358b0f` unless marked.

- `build-plan` emits only `@type`, `name`, `domainId`, `roles`, `credentials`, and `aliases` for an
  account (`roles/stalwart/build-plan:27-35`). So `household` never reaches the plan, flipping it
  leaves `stalwart-apply`'s plan hash unchanged (`stalwart-apply:108`, `:154`), and the grant step
  must run on the "nothing changed" path too.
- `stalwart-apply` has three exits after the plan applies: bootstrap (`:141-152`), applied and
  restarted (`:154-158`), and nothing changed (`:159-162`). Each calls `ensure_certificate`
  first.
- The cached stalwart-cli schema the design names
  (`~/.cache/stalwart-cli/0nOZo9UpoZXYT375r_fM03-cN7dbh2AlhkvWPkpstqs/schema-Pzykh-dZ4p6qVJ7wVulQvyF7-1aRB8fI6GcjdJMWK2Q.json`):
  `x:Permissions` has the variants `Inherit`, `Merge` ("Permissions are combined with inherited
  permissions"), and `Replace`, the last two holding `x:PermissionsList`. Its
  `disabledPermissions` is "List of permissions that are explicitly disabled, even if they would
  be inherited through other roles or groups. This takes precedence over enabled permissions", a
  set of the `Permission` enum, which holds 661 names.
- `plan.ndjson` writes a set as a map of `true`, as in `"bind":{"127.0.0.1:8080":true}` (`:2`) and
  `subjectAlternativeNames` (`:9`).
- `mail-filters` selects mailbox accounts only (`roles/mail-filters/mail-filters:100`, `:531`), and
  `correspondents` reads every account the session lists with the contacts capability (`:223-229`).
  `stalwart-status` counts mailbox accounts only (`roles/stalwart/stalwart-status:60`).
- `scripts/rcpt-check.sh` asks port 25 for each address in a list file, never sends `DATA`, and
  prints each reply code (`:1-11`).
- The design's Stalwart facts at `v0.16.27`: a `shareWith` set replaces the map
  (`crates/jmap/src/addressbook/set.rs:456-458`); a refusal lands in the 200 response's
  `notUpdated` (`set.rs:204-208`); `acl_validate` accepts any account id and refuses more than
  `maxShares`, 10 by default (`crates/jmap/src/api/acl.rs:242-262`); "Stalwart automatically
  creates a default address book when an account is accessed and no address books currently exist
  for it" (<https://stalw.art/docs/collaboration/contact/>).

## Tasks

Part A's servers worktree is `.claude/worktrees/ward-probes` on branch `ward-probes`. Part B's is
`.claude/worktrees/ward-address-book` on branch `ward-address-book`, and its workstation worktree is
`~/.dotfiles/.claude/worktrees/ward-address-book` on branch `ward-address-book`. Part B's servers
branch is cut from `origin/ward-probes`; the others from `origin/main`. Every task is `auth-data`
with the `live-account` flag unless marked, runs test-first, and gets a `diff-reviewer` task-scope
read while CI runs. A secret store, a push of the workstation branch, and anything that touches ward
run in the main loop; an arm never reaches ward. Every live ward step runs outside 03:20 to 04:00
UTC, the backup band `stalwart-apply` refuses (`:44-48`). STATUS is the conductor's: the executor
sends `conductor-servers` STATUS lines and never edits STATUS. The public initiatives repo names
household members by role only, so this plan names the second operator's entry by its id,
`a-operator2`.

### Part A: the probes

- **T1. The book probe tool (35 min).** `scripts/ward-book-check.sh` loads the
  store's names with `secrets_load` (`scripts/lib/secrets.sh:12`) and runs
  `scripts/ward-book-check.py` with `python3 -I`, as `webmail-check.sh` wraps its driver. The
  driver is stdlib only. It signs in to `https://mail.907.life` as an `accounts.json` entry, by
  name, with that entry's password variable read from the environment, never printed and never
  passed as an argument. Requests run one at a time, and the first 401 ends the run. It prints
  hrefs, display names, counts, ids, and status codes, never a card body. A book is always named
  by its full URL in the phonebook plan's "Book's form" (`https://mail.907.life` plus Stalwart's
  percent-encoded href with its trailing slash); the tool prints books that way and refuses a
  path-only book argument, with a test for each. Its verbs:
  - `home ACCOUNT`: each book in the account's `addressbook-home-set`, with its URL, display
    name, and card count.
  - `setup`: as `probe`, create the book "Ward probe" through JMAP `AddressBook/set` when it is
    absent; PUT two synthetic cards, the first one twice with `If-None-Match: *`, the first carrying
    one `EMAIL` at an `example.com` address used nowhere else, which `setup` prints; set the book's
    `shareWith` to `{<probe2's id>: {mayRead: true}}` through `AddressBook/set`, the path
    `stalwart-apply` uses, taking the id from `probe2`'s JMAP session. Print the book's URL, the id
    used, and the two create statuses.
  - `read ACCOUNT HREF`: as a sharee, the home set lists the book with the owner's display name,
    an `addressbook-multiget` returns every card, and the session lists the owner's account with
    `urn:ietf:params:jmap:contacts`.
  - `write ACCOUNT HREF`: as a sharee, a create of a new card, and an update and a delete of an
    existing card with its current ETag. Print each status, then re-read the book's ETags and the
    new href.
  - `session ACCOUNT OWNER`: `listed` or `not listed` for the owner's account in the account's
    session with the contacts capability.
  - `principals ACCOUNT`: the count a JMAP `Principal/query` returns to that login.
  - `teardown`: as `probe`, delete every card in "Ward probe", set `shareWith` to `{}`, and read
    back no card and an empty map. `destroy`: as `probe`, destroy "Ward probe" and read back its
    absence.

  *Test* (`tests/ward-book-check.test.sh`, against a stdlib fake server in `tests/fakes/`, as
  `tests/fakes/smtp-server.py` serves `rcpt-check.test.sh`): each verb's output on canned
  answers; `setup` puts the printed `EMAIL` on the first card; `write` reports a pass only when
  all three answers are 403 and no ETag moved; a 401
  ends the run after one request; the fake's request log holds no password outside the
  `Authorization` header, and no spawned argument holds one. *Acceptance*: the tests pass, and
  the gate's shell and Python legs are clean.

- **T2. The probes (25 min, main loop, after T1).** On the probe domain only; nothing of
  Geoff's is read or written. First record `home probe` and `home probe2`. Then `setup`, and:

  | Probe | Run | Pass | Fallback |
  | --- | --- | --- | --- |
  | A per-user read grant reaches the member | `read probe2 <url>`; then `ssh -o BatchMode=yes geoff@ward.907.life sudo mail-filters correspondents probe2` piped to `grep -c -F` on the first synthetic card's address | The book is listed under the name `probe` set, the multiget returns both cards, the session lists `probe` with the contacts capability, and the count is 1 | Stop: the design returns to Geoff |
  | A read-only member gets 403 | `write probe2 <url>` | All three answer 403, and the book's ETags are unchanged | Stop: the design returns to Geoff |
  | Account ids match | On ward, read-only, `stalwart-cli query Account --json` in the `cli_as` form `stalwart-apply` uses (`:80-84`), the admin password read from `/etc/servers/stalwart.env` as data and never printed | Its id for `probe2` equals the id `setup` used | Part B's T4 reads ids from the JMAP principal list instead |
  | `If-None-Match: *` on create | `setup`'s two creates | 201, then 412 | Phonebook Task 2.10 creates without it, and the reconcile settles a race |

  Then `teardown`. `home probe` and `home probe2` match their first records, apart from the empty
  "Ward probe" book in `probe`'s list, which T6 and phonebook cutover step 5 reuse; that step
  destroys it. *Acceptance*: the table's results go in `docs/decisions.md` and the PR's
  `## Decisions`, and at T2's end, before the close, the executor sends `conductor-servers` one
  line with the four results for `conductor-phonebook`, whose Pass 2 pre-step reads them.

- **Part A close (15 min).** One whole-branch `diff-reviewer` over `ward-probes`, the fix chain
  if it finds anything, the gate, and the base plan's close checklist, the privacy check included.
  The PR body carries `## Brief`, `## Decisions` (T2's table and the "Ward probe" URL),
  `## Not checked`, the score, and `## STATUS lines`. The PR opens as a draft and waits for Part
  B's packet. Nothing is installed on ward, so it has no "After merge" step beyond the merge.

**Part A path**: T1 35, T2 25, and the close 15: 75 minutes. **Token ceiling**: 1.2M. One arm with
its review (0.5M), the main loop's live probes (0.3M), the close (0.3M), and the conductor (0.1M).

### Part B: the account

- **T3. The account, its secret, and the records (35 min).** In the main loop
  first: generate `STALWART_PASSWORD_PHONEBOOK` as 40 random alphanumerics, the form the
  workstation registry records for the other Stalwart passwords, and store it with
  `secret-set.sh` into the workstation worktree's `secrets/values.age` and the overlay
  `$XDG_RUNTIME_DIR/self-hosting/secrets-ward-address-book`, per the base plan's "Secrets in the age
  store" (decrypt back and compare hashes, commit, push, open the workstation PR as a draft). The
  workstation `secrets/registry.md` gains the name in its table and a section beside
  `STALWART_PASSWORD_GEOFF / _OPERATOR2 / _TEST / _TEST2`: it grants sign-in to the household
  book's owner, which has no mail access; it is read by `roles/stalwart` and, as `WARD_PASSWORD`,
  by the phonebook Worker; rotate ward first, then the Worker's secret. The arm:
  - `roles/stalwart/accounts.json` gains `{"id": "a-phonebook", "name": "phonebook", "login":
    "phonebook@ward.907.life", "domain": "d-ward", "role": "User", "password":
    "STALWART_PASSWORD_PHONEBOOK", "mailbox": false, "household": false, "aliases": [],
    "permissions": {"@type": "Merge", "disabledPermissions": {...}}}`. `probe` and `probe2` gain
    `"household": false`.
  - `disabledPermissions` holds these 90 names from the schema's `Permission` enum, each as a key
    with the value `true`:
    - Mail delivery and sending: `emailSend`, `emailReceive`, `calendarAlarmsSend`,
      `calendarSchedulingSend`, `calendarSchedulingReceive`.
    - IMAP, all 28: `imapAuthenticate`, `imapAclGet`, `imapAclSet`, `imapMyRights`,
      `imapListRights`, `imapAppend`, `imapCapability`, `imapId`, `imapCopy`, `imapMove`,
      `imapCreate`, `imapDelete`, `imapEnable`, `imapExpunge`, `imapFetch`, `imapIdle`, `imapList`,
      `imapLsub`, `imapNamespace`, `imapRename`, `imapSearch`, `imapSort`, `imapSelect`,
      `imapExamine`, `imapStatus`, `imapStore`, `imapSubscribe`, `imapThread`.
    - POP3, all 6: `pop3Authenticate`, `pop3List`, `pop3Uidl`, `pop3Stat`, `pop3Retr`, `pop3Dele`.
    - ManageSieve, all 9: `sieveAuthenticate`, `sieveListScripts`, `sieveSetActive`,
      `sieveGetScript`, `sievePutScript`, `sieveDeleteScript`, `sieveRenameScript`,
      `sieveCheckScript`, `sieveHaveSpace`.
    - JMAP mail, 42: `jmapMailboxGet`, `jmapMailboxChanges`, `jmapMailboxQuery`,
      `jmapMailboxQueryChanges`, `jmapMailboxCreate`, `jmapMailboxUpdate`, `jmapMailboxDestroy`,
      `jmapThreadGet`, `jmapThreadChanges`, `jmapEmailGet`, `jmapEmailChanges`, `jmapEmailQuery`,
      `jmapEmailQueryChanges`, `jmapEmailCreate`, `jmapEmailUpdate`, `jmapEmailDestroy`,
      `jmapEmailCopy`, `jmapEmailImport`, `jmapEmailParse`, `jmapEmailSubmissionGet`,
      `jmapEmailSubmissionChanges`, `jmapEmailSubmissionQuery`, `jmapEmailSubmissionQueryChanges`,
      `jmapEmailSubmissionCreate`, `jmapEmailSubmissionUpdate`, `jmapEmailSubmissionDestroy`,
      `jmapSearchSnippetGet`, `jmapIdentityGet`, `jmapIdentityChanges`, `jmapIdentityCreate`,
      `jmapIdentityUpdate`, `jmapIdentityDestroy`, `jmapVacationResponseGet`,
      `jmapVacationResponseCreate`, `jmapVacationResponseUpdate`, `jmapVacationResponseDestroy`,
      `jmapSieveScriptGet`, `jmapSieveScriptQuery`, `jmapSieveScriptValidate`,
      `jmapSieveScriptCreate`, `jmapSieveScriptUpdate`, `jmapSieveScriptDestroy`.

    Everything else stays as the `User` role grants it, notably `authenticate`, the `davCard*`,
    `davPrincipal*`, `jmapAddressBook*`, `jmapContactCard*`, and `jmapPrincipal*` families,
    `davSyncCollection`, and `jmapCoreEcho`, which the Worker and T4 need.
  - `build-plan` copies an entry's `permissions` into its `Account` value verbatim when the entry
    has one, and still emits none of `household`, `mailbox`, or `login`.
  - `secrets/templates/ward/stalwart.env` gains `STALWART_PASSWORD_PHONEBOOK=`; the servers
    `secrets/registry.md` gains its row (read by `roles/stalwart` on ward, and by the phonebook
    Worker as `WARD_PASSWORD`); the runbook's secrets table (`docs/runbook.md:727`) gains it.
  - `docs/addresses.md` gains a section for ward's service logins with one row:
    `phonebook@ward.907.life`, the phonebook Worker's contacts-only login, `mailbox: false`, mail
    access disabled, not in the accepted set. Beside the line at `:79`: "`rcpt-check.sh` expects 5xx
    for `phonebook@ward.907.life`". `ward.907.life` has an A record and no MX, so RFC 5321's
    implicit MX routes that address to ward; `emailReceive` is disabled for that reason (design,
    "Owner"). The "Expected accepted set" block does not change.
  - `docs/runbook.md`: one line at the end of "Restore the mail server from backup with
    server-restore" and of "Restore the mail server from a Hetzner image": after the restore, run
    `sudo stalwart-apply`; if Geoff's old Global Address Book came back in his account, follow the
    phonebook operations guide's old-book procedure, whose `move-book.ts copy` and `delete` keep
    the only copy, since a snapshot from before the move holds no moved book
    (`roles/mail-backup/server-restore` restores the whole store). One line after the upgrade rule
    (`:285`): after a Stalwart upgrade, rerun the `phonebook` login's submission check and
    `rcpt-check.sh` on `phonebook@ward.907.life`, each expecting a 5xx, since `disabledPermissions`
    is a deny list and a new permission is granted until it is listed.

  *Test* (`tests/stalwart.test.sh`): the `phonebook` upsert carries a `permissions` object equal to
  the entry's, on `#d-ward` with the `User` role, and its `disabledPermissions` holds exactly the
  90 names; no upsert carries `household`, `mailbox`, or `login`; an entry without `permissions`
  emits none; removing `probe2`'s `household` leaves `build-plan`'s output byte-identical.
  `tests/mail-filters.test.sh`: `refresh` never names `phonebook`, and `correspondents` reads a
  second session account that offers the contacts capability (`tests/fakes/curl-jmap`'s
  `contacts` key). *Acceptance*: tests pass, the existing accepted-set test still passes, and the
  pushed workstation blob decrypts to the stored hash.

- **T4. The book and its grants in `stalwart-apply` (50 min, after T3).** One function,
  `ensure_household_book`, called right after `ensure_certificate` on all three paths (`:149`,
  `:157`, `:160`):
  - It signs in as `phonebook@ward.907.life` with `STALWART_PASSWORD_PHONEBOOK` from the env file,
    the password reaching curl as a stdin config line as `stalwart-jmap` sends it (`:45`). It reads
    the account's books with `AddressBook/get`, which creates the default on first access. It
    keeps exactly one: with none or more than one it fails, naming the count, and destroys nothing.
    None means the default book was not created, which happens only when the config's
    `defaultHrefName` is unset (`crates/groupware/src/cache/mod.rs:333`; the schema's default is
    `"default"`). It
    names that book "Global Address Book" through `AddressBook/set` when its name differs.
  - Members are the `accounts.json` entries with `role` `User` and no `"household": false`: today
    `a-geoff` and `a-operator2`. Their ids come from `stalwart-cli query Account --json` in the
    `cli_as` form, matched on name and domain, or from the JMAP principal list if T2's probe 3
    took its fallback.
  - It sets the book's whole `shareWith` map to `{<id>: {mayRead: true}}` for every member through
    `AddressBook/set`. Any `notUpdated` or `notCreated` entry fails the apply. It then reads the map
    back with `AddressBook/get` and fails unless its keys equal the member ids exactly and each
    holds `mayRead` true and every other right false, since the read returns all four rights per
    sharee (`crates/jmap/src/api/acl.rs:188-201`, `jmap-proto/src/object/addressbook.rs:304-309`).
    It prints the member names and the count.
  - `--dry-run` prints the members and the map it would set, and sends no `AddressBook/get` (which
    would create a book) and no `AddressBook/set`.

  *Test* (`tests/stalwart.test.sh`, the stub `stalwart-cli` and `tests/fakes/curl-jmap` extended for
  `AddressBook/get` and `/set`): the step runs on each of the three paths; the members leave out the
  `Admin` entry and every `"household": false` entry; the set carries the whole map; an eleventh
  sharee answered `notUpdated`, as `maxShares` refuses, fails the apply; an unknown id answered
  `notUpdated` fails it; with `AddressBook/get` answering the four-right shape, a read-back with an
  extra key, with `mayWrite` true, or missing one member (only `a-geoff`'s id) fails it; no book and
  two books fail it; `--dry-run` sends neither method. *Acceptance*: tests pass.

- **T5. Live: the account, the book, and the checks (35 min, main loop).** Before step 1, send
  `conductor-servers` the hold line for STATUS: "ward runs branch `ward-address-book` until it
  merges".
  1. `scripts/apply.sh ward --check`, then `--apply`. The output carries `stalwart-apply: applied
     and restarted` and the grant step's line naming two members.
  2. `ward-book-check.sh home phonebook` lists one book, "Global Address Book", with 0 cards. Its
     URL goes under `## Decisions`; phonebook cutover step 6 reads it again.
  3. `ward-book-check.sh session` for `geoff` and for the second operator's entry against
     `phonebook` prints `listed`, and for `probe2` prints `not listed`.
  4. The credential cannot send: `printf 'user = "phonebook@ward.907.life:%s"\n'
     "$STALWART_PASSWORD_PHONEBOOK" | curl -sS -K - --ssl-reqd --url smtp://mail.907.life:587
     --mail-from phonebook@ward.907.life --mail-rcpt probe@probe.907.life --upload-file FILE`, the
     form the mail-filters plan's T7 used, with a synthetic message whose Message-ID is recorded
     with `scripts/mail-test-ids.sh add`, run as `curl -v ... 2>&1 | grep -E '^< [0-9]{3}'`, so
     only the server's reply lines show and no client line, `AUTH PLAIN` with its base64
     credential among them, reaches the terminal or the record. The pass is an SMTP 5xx reply at
     AUTH, MAIL FROM, or RCPT, quoted under `## Decisions`, and `stalwart-jmap find probe
     <Message-ID>` on ward prints nothing. A curl failure with no SMTP reply (resolve, connect, or TLS) is a
     step failure, not a pass. Step 2's CardDAV read with the same password is the control that
     the credential itself works.
  5. Under the same permission set the contacts paths work: step 2's CardDAV read, the apply's
     JMAP `AddressBook/get`, `shareWith` set, and read-back, and `ward-book-check.sh principals
     phonebook` returning at least the two members.
  6. `scripts/rcpt-check.sh mail.907.life` on a list holding `phonebook@ward.907.life` answers 5xx.
  7. `ssh -o BatchMode=yes geoff@ward.907.life sudo stalwart-apply` prints `nothing changed`, and
     its grant step's read-back passes again.

  *Acceptance*: each step's excerpt goes under `## Decisions`, passwords and IPs masked.

- **T6. The probe book reconcile (20 min, main loop).** The design's live test with the Pass 2
  fields: "a reconcile of the probe book from a test D1 holding the unit fixtures, read back, which
  shows Stalwart's parser accepts the real output". Cut a phonebook worktree from `origin/main`
  with `git -C /var/home/glw907/Projects/phonebook worktree add .claude/worktrees/ward-live
  origin/main`, run `npm ci` there, then `scripts/ward/probe-run.sh --book <"Ward probe" URL>
  --login probe@probe.907.life --password-name STALWART_PASSWORD_TEST` (phonebook Task 2.12). It
  ends with `ward_sync` at `ok`, every fixture card read back with 200, and the book emptied.
  Remove the worktree. *Acceptance*: the run's counts go under `## Decisions`.

- **T7. Close (30 min).** One whole-branch `diff-reviewer` over the servers branch and the
  workstation branch, then one batched fix chain quoting its findings verbatim. A fix to a file
  ward installs (`roles/stalwart/**`) re-applies ward from the branch and reruns T5's steps that
  cover it. Then the gate and the base plan's close checklist; the privacy check runs on every
  public file and PR body the pass touched. The servers PR body carries `## Brief`,
  `## After merge` (below), `## Decisions` (the book's URL, the permission set, and T5's and
  T6's excerpts), `## Not checked`, `## Found, not done`, the score, and `## STATUS
  lines`, which the executor sends to `conductor-servers`.

**Part B path**: T3 35, T4 50, T5 35, T6 20, and T7 30: 170 minutes.

**Token ceiling**: 3.5M. Two arms with Opus reviewers (1.3M), the main loop's live work and the
secret store (0.8M), the close (1M), and the conductor (0.4M).

## After merge (Part B)

The conductor runs these after Geoff approves:

1. Merge the workstation PR, then Part A's PR, then Part B's PR, retargeted to `main`. Pull both
   checkouts, run `sync.sh --local`, and remove the pass overlay, so `STALWART_PASSWORD_PHONEBOOK`
   is in `~/.local/secrets` for the phonebook cutover.
2. On ward, the installed `/opt/servers` tree equals `main`'s files, by the comparison the Bulwark
   plan's Entry sets out; on a mismatch, apply ward from `main` and rerun T5's steps 2 and 7. Then
   clear the hold line.
3. Delete T5's test message, if one landed, by its Message-ID, as the mail-filters plan's "After
   merge" step 2 does: `scripts/mail-test-ids.sh list`, `stalwart-jmap find`, then
   `scripts/ward-mail-delete.sh probe`.
4. Tell `conductor-phonebook` that the servers half has merged, which opens phonebook Pass 3's
   cutover sitting.

If Geoff rejects the PR, the conductor backs the live change out: on a branch from `main`,
`plan.ndjson` carries a `destroy` line for the `phonebook` Account, the form the `pop3s` and
`sieve` listeners took (`roles/stalwart/plan.ndjson:3-4`), and ward is applied from that branch,
then from `main`. `ward-book-check.sh home phonebook` then fails to sign in. The back-out
branch's PR goes to Geoff in the rejection's packet.

## At the phonebook cutover

`conductor-phonebook` asks for this after its cutover step 6, once the book holds the seeded
cards. It is the design's end-to-end grant check, "`probe2`'s `household` flag is flipped for one
apply". `conductor-servers` runs it (15 minutes), holding a ward hold line for its length:

1. On a short branch from `main`, remove `probe2`'s `"household": false` and apply ward from it.
   The grant step names three members.
2. `ward-book-check.sh read probe2 <the household book's URL>` returns every card, as many as
   phonebook's `check-book.ts compare` counted, and the session lists `phonebook`.
3. `ward-book-check.sh write probe2 <url>` gets 403 on each write, and no ETag moves.
4. Apply ward from `main`: the grant step names two members and its read-back passes. Delete the
   branch unmerged, clear the hold line, and send `conductor-phonebook` the result.

## Standing answers

| Situation | Answer |
|---|---|
| Probe 1 or 2 fails | Run `teardown`, write the evidence to the PR's `## Decisions`, and stop for `conductor-servers`, who tells `conductor-phonebook` to hold Pass 2: the design returns to Geoff, so this stop has no standing answer. |
| Probe 3's ids differ | T4 takes the JMAP principal list, and the arm's dispatch says so; record it. |
| Probe 4 answers other than 201, then 412 | Record it and relay it; phonebook Task 2.10 takes the fallback. Not a stop. |
| The apply refuses the `permissions` object | Read the refusal, fix a traced cause (an empty `enabledPermissions` map is the first to try), rerun once, and record it. An untraced refusal stops. |
| T5 step 4 is accepted: a message lands, or MAIL FROM and RCPT both answer 250 | Stop: the credential can send mail. Delete the message per "After merge" step 3 first. |
| `rcpt-check.sh` answers 250 for `phonebook@ward.907.life` | The design's fallback: `docs/addresses.md` records the address as accepted, with the reason (`emailReceive` does not gate RCPT). Not a stop. |
| T6 fails: a 412 (Stalwart refuses the render) or a defect in the phonebook script | Record the precondition name or the error under `## Not checked`, and send `conductor-servers` one line for `conductor-phonebook`. Phonebook Pass 3 fixes it, and its cutover step 5 is the binding live run. Not a stop. |
| A T5 step fails | Fix a traced cause and rerun that step. A cause the session cannot trace stops. |
| A stop after T5's first live write | Keep the live state, and send `conductor-servers` ward's state; the hold line stays. Back out only on a rejection, per "After merge". |
| A stop during the cutover's `probe2` flip | Apply ward from `main` first: the grant step's whole-map set removes `probe2`, and its read-back must name two members. Then send the state. |
| A live step meets the 03:20 to 04:00 UTC band | Wait until 04:00 and rerun it. |
| The auto-mode classifier denies a live call | The base plan's row: never retried; record the command and the site, continue, list it under `## Not checked`, and send `conductor-servers` one message. |

Stops: each part's token ceiling (1.2M and 3.5M), the clock stop, a cause the session cannot trace,
a secret only Geoff has, a failed probe 1 or 2, and a credential that can send mail. Each stop sends
`conductor-servers` one message with the state.

## Close

The base plan's "Adapter facts for the servers repo" and its close checklist stand for both
parts. Part A's PR, Part B's PR, and the workstation PR go to Geoff in one packet through
`conductor-servers`, and they merge before phonebook Pass 3's cutover sitting.

Design terms:

- The design's "the ward login" Worker secret is `WARD_USER` (phonebook plan Task 2.10).
- The design's `Blacklist` group is the phones' `Blocklist` group.
- The design says only the Worker and `stalwart-apply` sign in as `phonebook`. The conductor's
  read-only checks do too (`ward-book-check.sh home` and `principals`, phonebook's `check-book.ts
  compare`), each stopping at its first 401; they write nothing. Part B's PR records this under
  `## Decisions`.
