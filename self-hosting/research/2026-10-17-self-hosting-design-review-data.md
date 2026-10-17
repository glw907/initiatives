# Self-hosting design review: data integrity and failure risk (2026-10-17)

Target: `specs/2026-10-17-self-hosting-design.md` at commit faeb0b2 (branch `self-hosting`). Lens: what happens on a crash, a concurrent process, a partial write, an upgrade, or a restore, and whether an irreversible step can be reached before its safety copy is verified. Evidence comes from the ten research briefs dated 2026-10-17 and the brainstorm handoff. Line numbers refer to the design spec unless another file is named. A claim tagged **(from memory)** is not in any brief and must be checked before it changes the design.

The rulings are taken as decided. Where a ruling creates a risk, the finding names the risk and a mitigation that keeps the ruling.

**Counts:** 1 blocker, 19 major, 26 minor. Two findings carry an **OWNER FORK**.

**Research gap behind several findings.** No brief researched R2 bucket locks, restic on R2, or Hetzner Backups' lifecycle. The backups brief describes the pavilion pull that the R2 ruling replaced. Every backup claim in lines 318-375 that concerns R2 is unsourced, and so are the lock-prefix list, "a compromised server can't delete or overwrite anything," and the claim that the `locks/` exclusion is enough. The foundation pass should open with a short R2 and restic brief that covers bucket-lock semantics (prefix matching, whether overwrite is blocked, whether an account admin can remove a rule), token permission granularity, and restic's write and delete pattern per command.

---

## Blocker

### B1. The lock rules conflict with the retention policy, and prune can leave the repository silently inconsistent

- **Severity:** blocker. **Tag:** `correctness`.
- **Location:** lines 322-326 and 347-353.
- **Defect:**
  1. *Forget fails every night, deterministically.* The lock covers `snapshots/` for 30 days, but forget runs on every backup with `--keep-within 14d --keep-weekly 8 ...`. From day 15 on, forget tries to delete daily snapshot files that are 15 to 30 days old, and those files are locked. Forget errors on every run. If the backup script treats that as failure, the backup heartbeat (line 384) never posts, and a routine alert fires every night. The likely "fix" for that alert fatigue is loosening the lock. If the script ignores the error, real forget failures get ignored with it.
  2. *A partial prune can corrupt the repository.* Prune writes new index files, deletes the old index files, then deletes unused packs. With `index/` locked, the deletes of young index files are refused, but pack deletes for objects past 30 days succeed. That can leave index entries that point at packs which no longer exist. A later backup can then deduplicate against a blob that is gone, which writes a snapshot that cannot be fully restored, and nothing reports it at backup time. This is my inference from restic's prune order **(from memory)**, so it needs verifying. The rehearsal check at line 353 ("whether prune runs cleanly") would pass a prune that exits with errors and leaves this state, unless the rehearsal reads the data back afterwards.
  3. *The repository `config` object is unprotected.* restic's root `config` object (the repository ID, version, and chunker parameters) sits outside the four locked prefixes. A compromised server token can delete or overwrite it, and the repository then will not open **(from memory: restic refuses a repository without `config`)**.
- **Proposed fold:** Replace lines 322-326 and 349-353 with the following.
  - Lock `config`, `keys/`, and `data/` for 30 days. Losing any of these is unrecoverable.
  - Leave `index/`, `snapshots/`, and `locks/` unlocked. A deleted index is rebuilt with `restic repair index`, and deleted snapshots are recovered from the locked tree blobs with `restic recover` **(from memory; verify both in the rehearsal)**.
  - Set `--keep-within 35d`, longer than the lock plus a margin. In normal operation, forget and prune then never target a locked object.
  - Have the prune wrapper abort and alert on any refused delete, then run `restic check --read-data` right after every prune.
  - In the rehearsal, deliberately run a prune that meets refused deletes, then do a full `check --read-data` and a restore.
  - Record the result in `decisions.md`, as line 353 already says.

---

## Major

### M1. The nightly mail backup can store an inconsistent RocksDB copy and report it as good

- **Tag:** `correctness`. **Location:** lines 338-345.
- **Defect:** RocksDB is consistent only after a clean shutdown (Stalwart brief, line 27). Three things in the four-step recipe can break that without anyone seeing it:
  - `docker stop` sends SIGKILL after 10 seconds by default **(from memory)**. A slow flush then leaves a crashed database in the staging copy.
  - If step 2's stop or delta rsync fails, step 4 still runs restic over the warm, inconsistent copy.
  - If the script dies between the stop and the start, mail stays down until someone acts.
- **Fold:**
  - Stop with an explicit grace period (`docker stop -t 120`, or `stop_grace_period` in compose), and require exit status 0, not 137.
  - Write a `CONSISTENT` marker only after a successful stopped delta pass. restic refuses to run without the marker, and the backup heartbeat reports "inconsistent" instead of success.
  - Use a `trap` that always restarts Stalwart, and hold an inhibitor (`systemd-inhibit` plus a lock that unattended-upgrades respects) across the stop window.
  - Take `VERSION` from the running image digest, not from the config.

### M2. The age-key move has no proof step, and a cached key can hide a broken Proton path

- **Tag:** `correctness`. **Location:** lines 420-430.
- **Defect:** Line 426 adds the age key to Proton Pass, but nothing proves that the key read through `ws-pass-key` is byte-identical to the one in 1Password. Today's scripts cache the key in `/dev/shm/.age-key-$UID` until reboot (proton-pass brief, line 9). Any test run on a host that still holds a key fetched by `op` passes even if the Proton read is broken. After line 430 uninstalls 1Password, the first reboot exposes the failure, and every age-store secret is unreadable on that host. The other workstation is never named as tested.
- **Fold:** Add a gate before step 7, run on each host separately:
  1. Remove the cache.
  2. Fetch the key through `ws-pass-key` only.
  3. `age -d` every file in the store, and compare each result with the plaintext in `~/.local/secrets`.
  4. Grep the dotfiles for remaining `op ` calls.

  Uninstall 1Password only after both hosts pass. Make the gate a precondition of the 1Password packet (see M5).

### M3. The 1Password export is encrypted with the key it contains, and the key has no offline copy

- **Tag:** `correctness`. **OWNER FORK.** **Location:** lines 374, 402-407, and 426.
- **Defect:** The age-encrypted 1PUX goes into `servers-archive` (line 374). It is presumably encrypted to the workstation age key, and the plaintext export holds that same key. If Proton Pass loses the key (account lockout, lost FIDO2 keys with no recovery phrase, or a bad import), the archived rollback copy cannot be opened. Unless the planner writes the age-store originals into the emergency vault too, the restic passwords live only on the servers and in Proton (line 407). If both servers are lost and Proton is lost, the backups cannot be read. The proton-pass brief (line 127) relied on a recovery file on the LUKS drive, and the no-USB ruling removed that drive.
- **Fold:** Encrypt the 1PUX archive to a second, passphrase-based age recipient (scrypt) whose passphrase sits on paper with the Proton recovery phrase.
- **OWNER FORK:** where do the age key and restic passwords live offline?
  - (a) Proton only. This is the status quo of the design.
  - (b) A sealed paper copy of the age key and both restic passwords in the printed recovery kit the proton-pass brief describes (line 122). **Recommended:** it costs one sheet of paper and closes a total-loss path.
  - (c) An encrypted file on a USB stick in the kit. This fits the letter of the no-USB-backup ruling, because it holds keys, not backups, but the owner should rule on it.

### M4. Changes made in 1Password after the export are lost when 1Password is cancelled

- **Tag:** `correctness`. **Location:** lines 426-430.
- **Defect:** The export is a point in time. Step 7 allows a 30-day overlap, and steps 5 and 6 re-enroll passkeys while household member C migrates later. Any login created or changed in 1Password after its export (the passkey re-enrollment flow invites exactly this) is never carried to Proton.
- **Fold:** Declare 1Password read-only from the moment of each export, and say so in the household message. Before cancelling, take a second `op item list` with `updatedAt` and diff it against the export listing. Re-carry any item changed since. Apply the same rule to household member C's vault.

### M5. The irreversible steps have no written preconditions

- **Tag:** `correctness`. **Location:** lines 27, 306-307, 316, 442, and 492.
- **Defect:** Each deletion "comes to Geoff as its own packet," but the design never says what evidence the packet must carry. So the musicbox, PikaPods, Fastmail, and 1Password packets can be sent before the safety copy is verified. For example, nothing requires a verified restic snapshot of the real (post-cutover) photo library before the PikaPods pod is deleted. The pass 2 drill runs on rehearsal data.
- **Fold:** Add a table of preconditions per irreversible step. Each packet cites the evidence for every row.
  - **PikaPods pod:**
    - The final dump is in `servers-archive` and a download and decrypt round trip succeeds.
    - The first post-cutover media snapshot passes `restic check --read-data`.
    - A full Immich integrity check (checksums, not a sample) is clean.
    - The live counts match the pod's counts.
  - **musicbox:** see M19.
  - **Fastmail:**
    - The Vandelay archives for both accounts pass `vandelay inspect` and their counts match.
    - A final Vandelay pass has run right before closure.
    - The masked-address map with triage status is archived (see m11).
    - The second operator's masks are resolved (see M6).
  - **1Password:** the M2 gate, the M4 diff, and the importer's ignored list resolved.

### M6. Removing the second operator's Fastmail user at T+30 deletes his data and masks without a packet

- **Tag:** `correctness`. **Location:** lines 264-268, and mail-cutover brief open question 5.
- **Defect:** Line 267 removes the second operator's Fastmail user as a routine T+30 step. That deletes his mailbox at Fastmail and any @fastmail.com masked addresses or Fastmail-only logins he holds. The triage (lines 280-290) covers only the 165 masks on Geoff's account, and the brief's question about the second operator's masks was never answered. Line 266 ("Remove 907.life from Fastmail") is also a one-way step: it ends rollback and kills the three @907.life masked addresses that Fastmail hosts (mail-cutover brief, line 81). The design lists it as routine.
- **Fold:**
  - Make each T+30 removal a packet with preconditions.
  - Inventory the second operator's masks and Fastmail-dependent logins in the first week, and add them to the triage.
  - Name the three @907.life masked addresses and any catch-all in the Stalwart address inventory (line 233).

### M7. A rollback strands the two new mailboxes

- **Tag:** `correctness`. **Location:** lines 232-233 and 257-259.
- **Defect:** Household members A and B get new Stalwart mailboxes, and their Apple profiles go out on cutover day (line 257). Those addresses do not exist at Fastmail. During a rollback, mail to them bounces with a permanent 5xx, or lands in a catch-all if one exists, so senders' mail is lost.
- **Fold:** Pick one:
  - Create A's and B's addresses as aliases on Geoff's Fastmail account before cutover.
  - Recommended: delay A and B onboarding until the T+30 rollback window closes. Their mailboxes start empty, so waiting costs nothing.

  Either way, add "new mailboxes during rollback" to the rollback paragraph at line 259.

### M8. The imapsync paths are not rehearsed, lack credentials, and sweep only one folder

- **Tag:** `correctness`. **Location:** lines 255-263 and 482.
- **Defect:**
  - The delta sweeps and the rollback (lines 259 and 263) use imapsync. The rehearsal (lines 239-245) tests only Vandelay. The mail-cutover brief (line 71) cites an unresolved report of imapsync losing bodies into Stalwart.
  - imapsync needs an IMAP-scoped Fastmail app password for each account. Line 482 hands over only an API token and a DAV app password for the second operator, and nothing for Geoff.
  - The sweeps cover "Fastmail's Inbox" without naming the accounts. Mail that a Fastmail rule files elsewhere, or that is delivered locally inside Fastmail and filed, is never swept.
- **Fold:**
  - Add a rehearsal step: run a date-scoped imapsync sweep into Stalwart with a body compare, and a reverse sync into a scratch Fastmail folder.
  - Add IMAP app passwords for both accounts to the first-week list.
  - Sweep all folders except Trash and Junk by date, in both accounts.

### M9. The rehearsal does not verify contacts or calendars, and drops the shared address book

- **Tag:** `correctness`. **Location:** lines 229-242.
- **Defect:** Line 242 checks only mail counts. The 188 contacts and every calendar (with recurring events and time zones, which the mail-cutover brief flags at line 79) could arrive partly lost with no check catching it. The brief also names a contacts-only shared account on the token (lines 15 and 77) that the design never mentions.
- **Fold:**
  - Add per-address-book contact counts and per-calendar event counts to rehearsal step 2, plus a spot check of three recurring events and one event outside the household's time zone.
  - Name the shared contacts account in the migration list.
  - Archive each calendar's `.ics` and a vCard export with the Vandelay archives as fallbacks.

### M10. The workstation sync clients are not in the migration

- **Tag:** `correctness`. **Location:** line 274.
- **Defect:** `~/.dotfiles/contacts/.config/vdirsyncer/config` runs a two-way CardDAV pair (`collections = ["from a", "from b"]`) against `carddav.fastmail.com` on a user timer.
  - Left alone, it keeps syncing edits into Fastmail after cutover, so the two stores drift apart.
  - Repointed at Stalwart with the old `status_path`, it can treat every item as remotely deleted or new. That can delete local contacts or duplicate all of them into Stalwart.

  Thunderbird retirement (line 274) also does not check for Local Folders or local address books that exist on no server.
- **Fold:**
  - Add a workstation-clients step: stop the vdirsyncer timer before the final Vandelay pass, then repoint it at Stalwart with a fresh status directory after a one-way first sync, or retire it.
  - Inventory Thunderbird's Local Folders and local address books, and import them, before Thunderbird retires.

### M11. "Server gone entirely" points the mail restore at Hetzner images, which may go with the server

- **Tag:** `correctness`. **Location:** lines 359-362.
- **Defect:** Hetzner Backups belong to the server and are deleted when it is deleted. They can be kept only by converting one to a snapshot first **(from memory, so check the Hetzner Backups page)**. In the case line 359 names (a server deleted by accident, by a compromised account, or by Hetzner), the images are probably gone. A Hetzner image is also taken from a running server, so its RocksDB copy is crash-consistent at best **(from memory)**.
- **Fold:**
  - Make the restic path (`restore-drill.sh --keep`) the "server gone" route for both servers.
  - Keep the Hetzner image for "server exists but broken."
  - Have the drill test the image path once, starting Stalwart from a restored image.

### M12. Claude's rebuild authority can wipe production data

- **Tag:** `correctness`. **Location:** lines 48, 146, and 436.
- **Defect:** The ruling lets Claude rebuild labeled resources, and rebuild is "the path that converges the OS." `hcloud server rebuild` wipes the disk. On the mail server that loses everything since the last backup, up to a day of accepted mail that senders will not resend. On the media server it loses every upload since the last backup. The guard at line 436 refuses only deletes, not rebuilds.
- **Fold:** This keeps the ruling. `provision.sh` refuses a production rebuild unless:
  - a stopped backup (M1) finished within the last 30 minutes and its heartbeat recorded success;
  - a Hetzner snapshot was taken in the same run;
  - and, for the mail server, Stalwart is still stopped, so nothing arrives in between.

  Apply the same guard to the Hetzner US move (line 510) and to every upgrade at line 511.

### M13. `server-restore` restores in place, with no copy to undo it

- **Tag:** `correctness`. **Location:** lines 357-359.
- **Defect:** The second operator runs `server-restore` alone. It stops the service and restores over the live data. Three things can go wrong:
  - A failed or interrupted restore (an R2 timeout, or a full disk) leaves the data half-overwritten.
  - Picking the wrong snapshot destroys newer data.
  - A restore made "to fix" a fault loses all mail since the snapshot.

  Nothing preserves the state before the restore.
- **Fold:**
  - For the mail and database restores, restore into the staging directory, verify there, then swap the directories and keep the old one as `*.pre-restore` until Geoff or Claude clears it.
  - For Immich originals, an in-place `restic restore` is acceptable, because originals never change.
  - Have the script print the snapshot time and the age of the live data, and require typing `RESTORE` to continue.
  - Check disk headroom first (see m22).

### M14. A restore drill can send real mail from the throwaway server

- **Tag:** `correctness`. **Location:** lines 141 and 364-366.
- **Defect:** A restored Stalwart carries its outbound queue, its scheduled jobs (DMARC and TLS reports, Sieve vacation replies), and its ACME settings. On a drill server in the same Hetzner project, it can redeliver queued mail to outside recipients (duplicates, from an IP with no matching PTR) and send reports. The port 25 unblock follows the account, per the mail-cutover brief (line 21). Repeated rehearsal drills can also use up the certificate authority's duplicate-certificate limit for `mail.907.life` **(from memory)**.
- **Fold:** Have `restore-drill.sh` attach a drill firewall that blocks outbound 25, 465, and 587, start Stalwart with ACME off, and verify through loopback JMAP only.

### M15. The monitor itself is unwatched, and missed alerts are never repeated

- **Tag:** `correctness`. **Location:** lines 379-394.
- **Defect:**
  - If the Worker's cron stops (a broken deploy, a D1 error, a plan limit), nothing alerts, and silence looks like health.
  - ntfy's public server keeps messages for a limited window **(from memory: about 12 hours on ntfy.sh)**. A routine alert sent while both workstations are off is lost, and Geoff has no phone.
  - The design sends each alert once. A condition that persists after a missed alert stays unannounced.
  - The subscriber service can die without anyone noticing.
- **Fold:**
  - The Worker re-posts every unresolved condition every 6 hours.
  - The Worker posts a daily "all clear" on the routine topic. Each workstation's subscriber raises a local notification if none arrives in 26 hours, which watches the Worker, ntfy, and the subscriber together.
  - On startup, the subscriber fetches `since=` the last message it saw, or reads a status endpoint on the Worker.
  - Optionally, add an independent free dead-man (healthchecks.io) that the Worker pings.

### M16. Outbound mail can fail for days with no alert

- **Tag:** `correctness`. **Location:** lines 381-385.
- **Defect:** Every probe checks inbound mail or liveness. A port 25 block coming back, a Microsoft block, or a DKIM regression (the Stalwart brief, line 7, cites a 0.16.25 bug that sent mail unsigned) leaves mail queued or refused while every probe passes. Users find out only from bounces days later. The Stalwart brief (line 117) recommended monitoring queue size, and the design dropped it.
- **Fold:**
  - Add queue depth and the oldest queued message's age to the health heartbeat, and send a routine alert at 2 hours old and an urgent one at 12.
  - Optionally, add a daily outbound probe: Stalwart sends to an Email Routing address on another Cloudflare zone, and the Worker's email handler confirms it arrived with `dkim=pass`.

### M17. Nothing detects silent mail-store corruption, and the listed defense goes stale

- **Tag:** `correctness`. **OWNER FORK.** **Location:** line 522, and handoff line 44 (the cut-line item "No Vandelay second mail layer").
- **Defect:** Line 522 lists "the Vandelay archives" as a defense against silent RocksDB corruption. Those are one-time migration archives, so they protect nothing received after cutover. In the case the Stalwart brief cites (line 125), "every one of that user's backups already held the fault." Retention depth helps only if someone notices within 12 months, and nothing is set up to notice. The daily inbound probe catches only a total inbound failure. It does not catch a store that quietly drops or hides messages.
- **Fold (keeps the cut line):** The mail health timer records per-mailbox `totalEmails` over JMAP every night. The Worker alerts on any drop of more than 2% that no user action explains, or on a mailbox that stops changing. The twice-yearly drill starts the restored copy and compares those counts.
- **OWNER FORK:** re-admit Vandelay as a weekly logical layer?
  - (a) Keep the cut, and rely on count monitoring plus retention.
  - (b) A weekly Vandelay archive to R2 for the two migrated accounts. It is independent of Stalwart's schema and survives a bad upgrade or corruption, per the Stalwart brief (line 39).

  **Recommendation:** (a) now, and revisit (b) at the 1.0 upgrade. Weigh (b) against the ruling that mail is the biggest risk.

### M18. The 30-day lock gives a compromised server a quiet window to erase older history

- **Tag:** `correctness`. **Location:** lines 320-326.
- **Defect:** Each server's token can delete objects. The lock stops it for only 30 days. An attacker who keeps a foothold (or a buggy prune) can wait out the window, then delete every monthly and yearly snapshot. The server's own heartbeat would keep reporting success. R2 tokens have no "write but never delete" scope **(from memory)**, so the lock is the only guard.
- **Fold:** Each day the Worker lists each bucket's `snapshots/` through a read-only binding. It alerts on a drop in the snapshot count, a missing monthly snapshot, a newest snapshot older than 36 hours, or a change in the `config` or `keys/` objects. This checks the backup independently of the server's own report, and it turns the 30-day window into a detection deadline.

### M19. The musicbox copy can miss later changes, and its state is copied live

- **Tag:** `correctness`. **Location:** line 316.
- **Defect:**
  - musicbox keeps serving listeners until dubplate 0.8 ships, so library additions and member or state changes made after the copy are lost when the server is deleted.
  - `/var/lib/dubplate` is copied while dubplate runs, which gives an inconsistent database copy, unlike the stopped copy line 336 uses on the media server.
  - "Copies into the media restic repository" skips the hop: the data must first land in `/srv/music` on the media server.
  - Reading the `music-library` bucket needs its rclone crypt passwords. Line 316 does not say where those come from.
- **Fold:** Run the final copy with dubplate stopped on musicbox, right before the deletion packet. Verify by restoring from restic into a scratch directory and comparing SHA-256 sums against musicbox. Record where the crypt passwords come from.

### M20. Stalwart and Immich major upgrades go to production before any test

- **Tag:** `correctness`. **Location:** lines 366, 511, and 521.
- **Defect:** Line 366 runs a drill after a major upgrade. Stalwart 1.0 brings a schema decision and has no documented downgrade (Stalwart brief, line 13). Immich supports no downgrade at all (Immich brief, line 13). Rolling back means restoring, which loses all mail and uploads since the backup. The Stalwart brief recommended testing on a scratch server first (line 144).
- **Fold:**
  - Before any major or minor upgrade, `restore-drill.sh` builds a copy from last night's backup with outbound blocked (M14). The upgrade runs there first, and the counts are checked.
  - Only then does production run, after a stopped backup.
  - The runbook states that a rollback loses everything since that backup.

---

## Minor

1. **m1. The Trash expunge may delete old mail at once.** `correctness`, lines 199 and 231. The handoff's "change the 30-day Trash and Junk expunge before importing" step is dropped. Whether Stalwart counts the 30 days from the received date or from the move date is unverified (Stalwart brief, line 128). If it counts from the received date, a user who deletes an old message loses it at the next nightly run, and undelete is Enterprise-only. **Fold:** in the rehearsal, move an old message to Trash, run maintenance, and set `expungeTrashAfter` from the result.

2. **m2. An unattended reboot can SIGKILL Postgres and Stalwart.** `correctness`, lines 165 and 172. Set `stop_grace_period: 60s` or more for Stalwart and Postgres. Docker's default 10-second stop timeout applies at shutdown too **(from memory)**.

3. **m3. Docker CE upgrades unattended across major versions.** `correctness`, line 172. Every daemon upgrade restarts every container, and Docker's stable channel ships major versions **(from memory)**. **Fold:** pin the Docker major version with apt preferences, so unattended-upgrades takes patches only. Take majors in the monthly review.

4. **m4. restic lock hygiene.** `correctness`, lines 347-351. A reboot or OOM during a run leaves a stale lock in `locks/`, and the monthly prune can collide with the nightly backup. **Fold:** one unit sequences backup, forget, check, and prune under `flock`, runs `restic unlock` (stale locks only) before each run, and passes `--retry-lock` (the flag name is unverified for the installed version, per the backups brief, line 160).

5. **m5. Read-only restore tokens cannot create restic lock files.** `correctness`, lines 362 and 407. restic writes to `locks/` even for `snapshots` and `restore` **(from memory)**, so the emergency tokens fail unless the commands pass `--no-lock`. **Fold:** the runbook commands carry `--no-lock`, and the drill uses exactly the emergency-vault tokens.

6. **m6. Partial backups and failed checks must alert.** `correctness`, lines 351 and 384. restic exit code 3 (snapshot made but some files unreadable) must count as failure. A failed weekly `restic check` must post a routine alert, not wait for the monthly summary.

7. **m7. Immich dump freshness is never checked.** `correctness`, lines 330-332. If Immich's 02:00 dump job stops (a setting reset by an upgrade, or a failed job), restic keeps backing up 14 old dumps, and the backup still reports success. **Fold:** before the 03:00 run, assert that the newest dump is under 26 hours old and passes `gunzip -t`.

8. **m8. Immich has no rollback, and upgrades with no fresh dump.** `correctness`, lines 304-306. Write the rollback: point DNS back at the proxied CNAME and restart the pod. Uploads made in the meantime are copied back with immich-go or by hand. Take a manual dump before line 306's patch upgrade (Immich brief, line 13).

9. **m9. The pod can update itself between rehearsal and cutover.** `correctness`, line 302. The pod moved from v3.2.4 to v3.3.1 on its own (Immich brief, line 7). **Fold:** read the restore version from the final dump's filename (`...-v3.3.1-pg16.10.sql.gz`), never from the rehearsal record. Before the final restore, wipe the Postgres data directory left by the rehearsal instance, since the Immich brief (line 33) warns against restoring over a database that already ran.

10. **m10. Archive uploads have no encryption check.** `correctness`, lines 235 and 370-375. The Vandelay archives (all household mail in SQLite) go to an indefinitely locked bucket with no encryption stated, and one mistaken plaintext upload of the 1PUX can never be deleted. **Fold:** the archive uploader age-encrypts every file, refuses any input that lacks the `age-encryption.org/v1` header, and confirms a download-and-decrypt round trip before the local plaintext is removed.

11. **m11. The masked-address map dies with Fastmail.** `correctness`, lines 284 and 290. After closure, nobody can look up which service used which mask. **Fold:** archive the final snapshot, with triage status, to `servers-archive` before Fastmail closes.

12. **m12. The weekly recount should count mail to disabled masks.** `correctness`, line 288. A hit on a disabled mask means a missed service (mail-cutover brief, line 105). Make that its own line in the report.

13. **m13. Emptying Trash after import is a bulk delete on production.** `correctness`, line 231. If Vandelay cannot skip Trash and Junk, empty them by mailbox role, and first assert that the count equals the archive's Trash and Junk counts. The final Vandelay pass re-imports them (upsert), so the step repeats after that pass.

14. **m14. The inbound probe has edge cases.** `correctness`, lines 385 and 391.
    - A missing confirmation (mail server down) must count as a probe failure, not only as a missing heartbeat, which is routine.
    - Search every mailbox, Junk included.
    - Make sure the probe's sender passes DMARC once `p=reject` lands, or the probe starts failing for the wrong reason.

15. **m15. Five-minute TCP probes may trip auto-ban.** `correctness`, line 383. 576 bare connects a day from shared Cloudflare egress IPs could cross the "150 loitering connections" threshold (Stalwart brief, line 96). The ban would also block legitimate mail from those IPs. That reading of what counts as loitering is unverified. **Fold:** have the probes complete a TLS handshake and log out, or allowlist Cloudflare's egress ranges in auto-ban.

16. **m16. DNS drift goes unseen.** `correctness`, line 213. A bad `dns.sh --apply` that drops the MX passes every TCP probe, because the probes connect by hostname, and is caught only by the next daily inbound probe. **Fold:** the Worker checks MX, SPF, DKIM, and DMARC hourly over DNS-over-HTTPS against the repo's declared values.

17. **m17. The `Conflicts=` rationale does not hold under Docker.** `correctness`, line 199. The `Conflicts=` hazard belongs to the native unit. In Docker with host networking, an installed MTA instead takes port 25, and the container fails to bind. Keep the apt pins, set `restart: always`, and have the health timer check that port 25 is owned by Stalwart.

18. **m18. The second operator's Proton account may not support Emergency Access.** `correctness`, line 402. Emergency Access needs a Proton Mail address on both sides (proton-pass brief, line 121). Give him one, and keep his Proton recovery off 907.life (proton-pass brief, line 127).

19. **m19. The second operator's media restore path needs repo access and the old IP.** `correctness`, line 362. He needs read access to the private `servers` repo. `--keep` should reattach the surviving Primary IPs, so DNS, which only Claude writes, needs no change.

20. **m20. The Hetzner US move has no final-copy rule.** `correctness`, line 510. Take the final backup with Stalwart stopped, and keep the old server stopped (not deleted) for 7 days, deleted through a packet. This mirrors the PikaPods rule.

21. **m21. DMARC `p=reject` can drop the household's other mail.** `correctness`, line 219. Before `p=reject`, list every legitimate 907.life sender in the reports, including Cloudflare Email Sending (`cf-bounce`) and any site that sends magic-link mail, and confirm that each one is DKIM-aligned. Otherwise their mail is rejected.

22. **m22. Mail-server disk headroom is not computed.** `correctness`, line 203. The live store, the staging copy, a side-by-side restore (M13), and the Vandelay archives (if Vandelay runs on the server) can exceed 40 GB. The Stalwart brief (line 47) sets the ceiling at about 10 GB of raw mail. **Fold:** measure the second operator's mailbox before provisioning, run Vandelay on a workstation, and add a disk-full guard to the backup and restore scripts.

23. **m23. Name the catch-all explicitly.** `correctness`, line 233. If Fastmail runs a catch-all on 907.life, Stalwart must too, or mail to any other address is refused permanently after the switch.

24. **m24. Workstation scratch state for the masked list has no backup.** `optional`, line 284. The snapshot lives only on one workstation until m11 archives it. That is acceptable while Fastmail's API can rebuild it.

25. **m25. Over-ceremony: the monitor goes beyond the approved cut line.** `optional`, lines 377-394 against handoff line 44. The approved cut line says "one free uptime check plus a backup dead-man ping." The design builds a Worker with D1, two topics, and a mail probe through Email Sending, while line 43 says the cut line "stands as approved." Either record why the alert ruling needs more, or start from a hosted checker with ntfy delivery and add only the inbound probe. The second choice also settles part of M15, since the checker is a third party.

26. **m26. Over-ceremony: shredding a tmpfs file.** `optional`, line 426. Running `shred` on `/dev/shm` does nothing extra. Use `rm`, after m10's round trip.

---

## Verified against the briefs, no finding

- MX is never mixed between Fastmail and Stalwart (line 216), and the final Vandelay pass runs before the switch. This matches the mail-cutover brief's warning about upsert reverting a live account (line 89).
- The PikaPods dump plus `UPLOAD_LOCATION` restore at the pod's version, with counts and the integrity page (which checks checksums, per the Immich brief, line 142), is sound once m9 is folded.
- Masked addresses are disabled, never deleted (line 278), which matches Proton's "cannot be recovered" (proton-pass brief, line 112).
- The order "database first, then files" holds for media: the dump runs at 02:00 and restic at 03:00 (Immich brief, line 136).
- Primary IPs are created first, with auto-delete off and delete protection on (line 94), which matches the baseline brief (line 170).
