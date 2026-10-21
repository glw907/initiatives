# Pass 5 plan review: data integrity and failure risk

The data-integrity and failure-risk lens read the amended Passes 5 and 6 of `self-hosting/plans/2026-10-17-self-hosting-plan.md` and the plan's "Secrets in the age store", "Human steps", and "Standing answers". It also read the Pass 5 pre-flight, rules file, executor prompt, and conductor prompt, all at commit `9a25e94` on branch `pass5-plan`, against the design's "Mail", "Backups", "Claude's operating authority", and "Irreversible steps" and the servers repo at `origin/main` (`a8c1b1c`). The question was what a crash, a concurrent process, a partial write, a relaunch, or a restore does to the mailboxes, the buckets, DNS, the Hetzner project, and the age store. The findings run from most to least consequence.

## Findings

### 1. major, correctness: L4's SPF declaration makes `dns.sh` own the whole apex TXT set

- **Location**: `self-hosting/plans/2026-10-17-self-hosting-plan.md:306` (L4), and the same task in the executor prompt.
- **Defect**: The `dns.sh` header on `origin/main` says "Each declared name and type owns its whole record set: --apply replaces that set". So declaring `@ TXT "v=spf1 ..."` in `cloudflare/dns/ward` makes the script own every TXT record at the apex. That set holds every domain-verification string and any other TXT record there, not just SPF. On `--apply`, each undeclared apex TXT record is deleted from the live zone. The pre-flight read only says "SPF ends `?all`" and never lists the rest of the set. In the same way, "SPF with Fastmail's include plus the server and `~all`" drops any other mechanism the live SPF carries today. The `.well-known` redirect rules carry a related risk. `dns.sh` has no redirect code yet, and on Cloudflare, writing a zone's redirect phase entrypoint with PUT replaces every rule in it, including any rule the 907.life site already depends on.
- **Fold**: Make L4 start with a read of the live apex TXT set and the live SPF value. Declare every apex TXT record verbatim in the ward file and change only the SPF value, keeping every existing mechanism. Change the acceptance to "the apex TXT set after `--apply` differs from the pre-apply listing only in the SPF value". The redirect code adds each rule through the entrypoint's `rules` endpoint (POST), never a PUT of the entrypoint. Its test should show that a pre-existing rule survives.

### 2. major, correctness: `archive.sh` deletes the Vandelay archive L5 must keep, and can't hold a 5 GiB file in its work directory

- **Location**: `plan.md:307` (L5: "the local archives stay until C1 ends"), the executor prompt line 31, the rules file line 45.
- **Defect**: On `origin/main`, `scripts/archive.sh` ends with `rm -f "$file"` once the round trip passes. If it runs on the SQLite archive itself, it deletes the archive that the import into Stalwart, the C1 final pass, and C1's count rows against `vandelay inspect` all need. Three more problems follow:
  - **Work directory too small**: The script stages `up.age` and a decrypted `plain` copy in `mktemp -d "${XDG_RUNTIME_DIR:-/dev/shm}"`, which on pavilion is a 1.6 GB tmpfs. Geoff's archive is roughly 5 GiB, so the encrypt step fails with ENOSPC. An unattended executor's likely fix is to edit an `auth-data` script mid-task, possibly moving plaintext staging to disk.
  - **Possibly incomplete copy**: If Vandelay keeps SQLite in WAL mode, copying the main file alone misses committed pages. The round trip compares that same file, so a partial cold copy passes. That copy sits under an Indefinite lock and can never be replaced.
- **Fold**: L5 archives a copy, never the working archive. Take the copy with `sqlite3 SRC ".backup DEST"` (or `VACUUM INTO`) after Vandelay has exited, then check it with `PRAGMA integrity_check` and `vandelay inspect`. Then run `archive.sh` on the copy, which it is free to delete. Before L5 runs on real data, give `archive.sh` a disk-backed work directory under `~/.local/state/self-hosting/` (0700, which matches the design's "outside every repo"), test-first, as part of L5.

### 3. major, correctness: the C1 final pass can't reconcile mail that was deleted, moved, or reflagged at Fastmail after the rehearsal import

- **Location**: `plan.md:307` (L5's idempotence test), `plan.md:318` (C1).
- **Defect**: The rehearsal import lands in Geoff's and the second operator's real Stalwart accounts, which persist to cutover. Both of them keep deleting, filing, and flagging mail at Fastmail during the rehearsal week and the time before cutover. L5 tests only whether re-importing the same archive duplicates. It never tests whether a second Vandelay pass propagates a source-side delete, move, or flag change. If it doesn't, the C1 count and flag rows run against "the final archive's `vandelay inspect`" and will fail every time: Stalwart holds deleted messages again and duplicates moved ones. The cutover then stops before the switch with no recovery path, and the next try fails the same way. There is a second hazard. A Vandelay run that spans the 03:30 stop (a 7.93 GiB import takes hours) loses its connection partway, and nothing says whether a rerun after a partial import duplicates.
- **Fold**: Extend L5's test. Use the test account as the source, with a second Stalwart test account as the target. Run a pass, then delete one message, move one, and flag one at the source. Run a second pass and record what Stalwart shows. Also kill one run partway and rerun it. Then write C1's answer into Pass 6 now. Two candidates:
  - If Vandelay syncs deletes and moves, C1 needs no extra step.
  - If it doesn't, the final pass reconciles by Message-ID. A message in a Stalwart account whose Message-ID is absent from the final archive is destroyed, with counts read before and after. That makes it a named, planned deletion in Pass 6's deletions list.
  
  Separately, the executor prompt should say a Vandelay run into ward starts only when it can finish before 03:20 UTC, or after 04:00.

### 4. major, correctness: rehearsal test mail sent from outside lands in the real Fastmail mailboxes, including the second operator's

- **Location**: pre-flight R1 (lines 145 to 151), `plan.md:127` (Human steps, "At Outlook.com, send one message to each mailbox"), the rules file line 53 (`curl --url smtps://smtp.gmail.com:465 *`), the executor prompt line 14.
- **Defect**: During the rehearsal, the apex MX still points at Fastmail. A message from Outlook.com or the Gmail test account to either 907.life mailbox therefore goes to Fastmail, not ward. R1's check ("your two messages are in Stalwart, found by subject token") fails unless a sweep has carried them across. Meanwhile each test message sits in the second operator's live Fastmail inbox. The pass must never write to or delete from that inbox (prompt line 14), and L8's cleanup reaches Stalwart only. The C1 final Vandelay pass then brings those messages into Stalwart after L8 has cleaned up, so test mail survives the migration. The design's Receiving row needs only a direct SMTP connection.
- **Fold**: Point every external rehearsal send at the Stalwart test account through an address on `probe.907.life`, whose MX is ward from L4. The alternative is a direct SMTP delivery from pavilion to ward on port 25 (the design's "direct SMTP connection"). Change R1 step 1 and the Human steps row to match, and keep the two-mailbox sends for C3, after cutover.

### 5. major, correctness: a relaunched executor can regenerate a stored secret, orphaning the restic repository's password

- **Location**: the executor prompt lines 20 to 22 and 37, the conductor prompt line 31 ("relaunch the stopped executor with the same line"), `plan.md:62` to `65`.
- **Defect**: The build phase is expected to be relaunched, after the CX33 wait and after any `## Stop`. On `main`, `secret-set.sh` silently replaces an existing name ("Replace any existing line for NAME"). The overlay `/run/user/1000/self-hosting/secrets-mail` is on tmpfs, so a reboot during a multi-day wait empties it. A fresh session that finds `RESTIC_PASSWORD_WARD`, `TUNNEL_TOKEN_WARD`, or a `STALWART_PASSWORD_*` missing from the loader will generate and store a new one. After `restic init`, that replaces the only store entry for the repository's key, which then survives only in the branch's `values.age` history. The next render then breaks ward's backups and Stalwart logins without any error at store time.
- **Fold**: Add to the executor prompt: "On any start, first rebuild the overlay from the branch store (`sync.sh --values <branch values.age> --local <overlay>`), and never generate a name already present in the branch store or in `~/.local/secrets`; a name you think needs replacing is a stop." Optionally, a later workstation PR could make `secret-set.sh` refuse to overwrite without `--replace`. That one is `optional`.

### 6. major, correctness: the in-place image restore (R2) erases test messages already in L6's Message-ID list, so L8's acceptance can't hold

- **Location**: `plan.md:308` (L6), `plan.md:310` (L8), pre-flight R2 (lines 153 to 159).
- **Defect**: R2 restores *last night's* image after L6's server-side rows have passed. Every test message L6 sent or delivered on that day exists in the list but no longer in Stalwart. L8's acceptance ("each mailbox's count difference equals its list length") then cannot hold. An unattended Sonnet executor facing that mismatch may widen the deletion, for example by searching for the fixed header token, which is outside "exact Message-ID". The restore also silently rolls back anything `scripts/apply.sh ward --apply` rendered or installed since the image.
- **Fold**: Run R2 before L6's message-sending rows, or after them with a fresh image. Change L8's acceptance to: "for each listed Message-ID, destroy the copies found; the count difference equals the number found, and listed-but-absent IDs are reported, never searched for another way". After R2, run `scripts/apply.sh ward --check`, then `--apply` if it shows drift. Add to the conductor's R2 relay that the console steps happen outside 03:20 to 04:00 UTC, so the rebuild never wipes the disk mid-backup.

### 7. major, correctness: the allow rule lets an unattended `imap-sweep.sh rollback` write the whole Stalwart store back into live Fastmail accounts during the rehearsal

- **Location**: the rules file line 46 (`Bash(scripts/imap-sweep.sh *)`), `plan.md:308` (the wrapper's verbs), the executor prompt line 14.
- **Defect**: L6 builds a `rollback` verb (Stalwart to Fastmail, every account, the second operator's included) and the Pass 5 rule allows it. The prompt's "never write to his Fastmail account" is the only guard. A rollback run while MX is still on Fastmail would copy the rehearsal store into both production Fastmail mailboxes. Whether imapsync's duplicate detection holds up against headers Stalwart has rewritten is unchecked. Pass 5 doesn't need the verb.
- **Fold**: Have the wrapper's `rollback` refuse unless the apex MX, read from a public resolver, is ward. Test that refusal. Narrow the Pass 5 rule to `scripts/imap-sweep.sh sweep *`, `rehearse *`, and `rehearse-clean`.

### 8. major, correctness: the L6 Message-ID list has no named location and must survive into a new session a week later

- **Location**: `plan.md:308` ("an age-encrypted list outside git"), the executor prompt line 33.
- **Defect**: L8 runs in the date phase, a fresh session after the rehearsal week. The list's path is never named. Every path the prompt uses for transient files is tmpfs: `/dev/shm`, the runtime directory, and the overlays. If the list is lost, L8 cannot delete by exact Message-ID, the one deletion form the design and the prompt allow, and the executor improvises or stops.
- **Fold**: Name the path, `~/.local/state/self-hosting/mail-test-ids.age` (0600, persistent), and have the build phase's PR body record its entry count and SHA-256. L8 refuses to run, and stops, if the file is missing or its hash differs.

### 9. major, correctness: the credentials branch can carry a `values.age` conflict into Geoff's merge

- **Location**: the conductor prompt lines 11 and 12, pre-flight item 5 (lines 66 to 72), `plan.md:67`.
- **Defect**: `self-hosting-fastmail-members` was cut on 2026-10-20 and gains four more stores in the sitting. The plan's conflict rule says to test-merge `origin/main` before the packet, take main's file in a merge commit, and re-store the branch's names. The conductor's sitting steps never apply it. Meanwhile Pass 3's week phase, and Pass W or Pass 4, may land `values.age` on `main` in between. An unresolved binary conflict leaves the branch unmergeable. If someone settles it by picking a side, every entry on the other side is lost.
- **Fold**: In the conductor prompt's step 2, before the push, add: "fetch and test-merge `origin/main`; on a `values.age` conflict follow the plan's 'A conflict in `values.age`' rule and check every name's hash".

### 10. major, correctness: L3 changes the orpheus-only backup and health roles with no check that orpheus is unchanged

- **Location**: `plan.md:305` (L3: `roles/backup` for ward, `secrets/templates/health.env` per host), `plan.md:299` (Pass 5 never runs `apply.sh orpheus`).
- **Defect**: On `origin/main`, `roles/backup/servers-backup` is "The nightly backup for the media server" (the Immich dump check and dubplate copy), and its installer hardcodes the 03:00 timer. `health.env` hardcodes the orpheus heartbeat. L3 has to make both host-aware, yet Pass 5 never applies orpheus. So the first time orpheus runs the changed backup is some later apply, untested against the photo library's only restic path. The heartbeat would catch a failed run the next day, but not a backup that runs and silently covers less.
- **Fold**: Add an L3 test that renders orpheus's installed files (script, units, rendered env names) on `main` and on the branch, and asserts they're byte-identical or lists each intended difference. Add `scripts/apply.sh orpheus --check` to the build PR's `## After merge`.

### 11. major, correctness: the T+30 removal of the second operator's Fastmail user rests on a cold archive weeks out of date

- **Location**: `plan.md:322` (C5: "the Vandelay archives cover the two migrated accounts"), `plan.md:318` (C1), `plan.md:333` (D4).
- **Defect**: The only `archive.sh` step is in L5, during the rehearsal. C1's final Vandelay pass isn't archived. D4's final pass at Fastmail's close can cover only Geoff, because C5 has already removed the second operator's user. So the cold copy of his account in `servers-archive` predates the rehearsal week, and the C5 evidence row overstates it. Stalwart and restic still hold his later mail, so this is not data loss, but the irreversible step's evidence is wrong.
- **Fold**: C1 archives each final Vandelay archive through the copy-then-`archive.sh` path from finding 2. C5 runs one last Vandelay pass of the second operator's account before the packet and archives it. The packet then names both archive objects' keys and timestamps.

### 12. minor, correctness: the Trash-expiry row isn't confined to the test account

- **Location**: `plan.md:308` (L6 runs every rehearsal row, including Trash expiry).
- **Defect**: "An old message moved to Trash, then a maintenance run" can run in Geoff's or the second operator's real Stalwart account, permanently destroying a migrated message. Whether the final pass restores it is the unknown from finding 3. Either way, it is a deletion outside the prompt's list.
- **Fold**: Run the row in the test account on a message imported with an old `receivedAt`.

### 13. minor, correctness: `rehearse-clean` deletes a Fastmail folder by name alone

- **Location**: `plan.md:308` (the wrapper), `plan.md:310` (L8).
- **Defect**: IMAP DELETE removes a folder and everything in it, in Geoff's production account. Nothing stops `rehearse` from writing into, or `rehearse-clean` from deleting, a folder of that name that already existed.
- **Fold**: `rehearse` refuses if the folder exists before its first run without the wrapper's own marker (a file under `~/.local/state/self-hosting/`). `rehearse-clean` refuses unless the folder's message count equals the count `rehearse` logged. Test both refusals.

### 14. minor, correctness: the Spamhaus re-allocation loop has no cap, and the listed IP keeps its name

- **Location**: `plan.md:304` (L2), the executor prompt line 47.
- **Defect**: `provision.sh` finds Primary IPs by name and creates them with delete protection that only Geoff removes. A listed address that keeps `ward`'s IPv4 name would be attached again by a rerun. A run of listed addresses (a policy list over a range) would allocate protected IPs without limit, each one a recurring charge and an irreversible packet.
- **Fold**: Rename the listed IP (for example, with a `-listed` suffix plus a label) before allocating the fresh one, and test that a rerun skips it. Stop after three listed allocations.

### 15. minor, correctness: L8's `restic stats` with the read-only token needs `--no-lock`

- **Location**: `plan.md:310`, the pre-flight's secrets table (`CF_WS_R2_BACKUPS_RO_*` for L8).
- **Defect**: `restic stats` takes a lock by default. The read-only token can't write one, so the call fails. The design names `--no-lock` for read-only work.
- **Fold**: Write the call as `restic stats --mode raw-data --no-lock`.

### 16. minor, correctness: C5's evidence leaves the design's mask row for household members A and B unaddressed

- **Location**: `plan.md:322`, against the design's "Irreversible steps" row ("Every masked address and Fastmail-only login on the three accounts has moved").
- **Defect**: The ruling waives the archive for A and B, but the C5 packet doesn't say that the mask and Fastmail-only-login half of the row is waived for them too. It also has no count of their masks, since their tokens are gone. Their addresses may also be the recovery address for outside accounts, which stops working at cutover.
- **Fold**: C5's packet states the waiver under the 2026-10-20 ruling. The L8 drafted message asks A and B to move any login or recovery address that uses their 907.life address before cutover.

### 17. minor, optional: household member A's live credentials have no deadline

- **Location**: pre-flight item 8 (lines 94 to 101), "holds nothing".
- **Defect**: Two credentials that can write and send stay live at Fastmail indefinitely. Their ciphertext also stays in the public branch history.
- **Fold**: Make item 8 hold the credentials PR's merge, so the revocation happens in the same sitting.

### 18. minor, optional (over-ceremony): the `r2-archive-rw` dry-run row leaves a permanent object every run

- **Location**: the pre-flight's conductor checks (line 112), `plan.md:303` (L1's acceptance).
- **Defect**: The row writes `dry-run/probe-*` into `servers-archive`, whose Indefinite lock refuses the delete (the script accepts the 409). The pre-flight already ran it. The conductor's check and L1's acceptance each add one more undeletable object, for no new evidence, since `archive.sh`'s own round trip in L5 proves the same scope.
- **Fold**: Drop `r2-archive-rw` from the conductor's check and from L1's acceptance run.

### 19. minor, optional (over-ceremony): L1 measures the mailboxes a second time

- **Location**: `plan.md:303` ("read both mailboxes' sizes and mask counts again").
- **Defect**: The same figures were read the night before, with the same tokens, and are already recorded at `plan.md:290` and in the pre-flight. Re-reading them costs about 10 minutes of the 60-minute task, plus the tokens to read two mailboxes' worth of sizes, and changes no decision.
- **Fold**: Have L1 copy the recorded 2026-10-21 figures into `decisions.md`, and take L1 down to 50 minutes.

### 20. minor, optional (over-ceremony): pre-flight items 6 and 7 hold the launch but are needed only at the rehearsal sitting

- **Location**: pre-flight lines 74 to 92.
- **Defect**: The console labels and the second operator's app names are first used in L6's sitting, at least a week after launch. Making them hold the launch adds calendar delay and gives the rehearsal nothing it wouldn't otherwise have. Item 6 run on orpheus, which has no backups, can't show the restore control's real label anyway.
- **Fold**: Mark items 6 and 7 "holds the rehearsal sitting". The conductor brings them before writing R2 and R3.

**Count**: 0 blockers, 11 major, 9 minor.
