# Self-hosting design: second fold verification (2026-10-17)

Target: `specs/2026-10-17-self-hosting-design.md` at commit `7e1f6f4`, which folds the first verification and Geoff's chat rulings. I took no part in the folds, the reviews, or the first verification. I checked the spec text against the first verification, the fold record's "Verification round" and "Geoff's chat rulings" sections, the round-two diff (`git diff 1bf2f10 7e1f6f4`), and the briefs. I also ran one local restic probe and one doc check. Line numbers refer to the spec unless another file is named.

**Counts:** 0 blocker, 3 major, 12 minor. One minor carries an **OWNER FORK**.

**Verdict:** every blocker and major in the first verification closed in the spec text, not just in the record. B1's lock design is correct and consistent across the brief, "Lock rules", "Retention", "Rulings needed", "Risks", and the end-to-end check. The four-mailbox correction reached every section that counts accounts. It missed one consequence that it created: the household's contacts and calendars still have a live Fastmail copy after the final pass, and nothing carries changes made there. The sizing change reaches the right type, CX33, but one stated reason is wrong, and its overflow path takes the mail store out of the Hetzner images that the design counts as a defense. The media drill's `restic recover` proof can't run under the drill's own read-only token. Geoff can rule both `### Decide:` blocks on the brief as written. One option text in the port 25 block needs a correction (m9).

---

## 1. Did the first verification's blockers and majors close in the spec text?

| Finding | Closed? | Where, and what I checked |
|---|---|---|
| B1 backup locks | Yes | 426-430: Indefinite on `config`, `keys/`, `data/`; 30-day Age on `snapshots/`; none on `index/` and `locks/`. 446: nightly `forget --keep-within 35d ...`. 448: never automatic `prune`. 450 and 690: the cleanup at 200 GB is Geoff lifting the `data/` rule, then `prune`, `check`, and `r2.sh` restoring the rule. 434: `r2.sh` only adds rules. The brief (15, 31-36), "Rulings needed" (87), "Risks" (722), the alert table (542), and the end-to-end check (753) all agree. I re-derived the retention safety: a snapshot uploaded within 30 days is always within 35 days of the newest snapshot, so `forget` never reaches a locked file. Probe results on `recover` and `check` follow in M3 and m4. |
| M1 image drill | Yes | 498: dropped. The image path is tested in place on the real mail server before MX moves (row at 323). |
| M2 drill joins tunnel | Yes | 491: no `backup`, `health`, or `cloudflared`, and the script refuses all three. 492: no write, heartbeat, tunnel, or Spamhaus secret. 493: two firewall phases, with the closed one on before any service starts. 494: loopback checks. |
| M3 server-gone path | Yes | 485 and 500: `--hold` keeps the server behind the closed firewall, and `promote.sh` makes it production only when the old server is gone. 485 and 639: the second operator's path is "call Geoff", plus a read-only copy-out. 233: no Hetzner token for him. Mechanics gaps in `promote.sh` are m12. |
| M4 emergency vault | Yes | 564 and 680: Geoff's single FIDO2 session creates both vaults and the tokens, then shares the emergency vault. Claude stages values in `/dev/shm`. Drills read the age store until then. 584 matches. |
| M5 dubplate SMTP | Yes | 270 and 272: the Fastmail row names Immich and dubplate, and the Cloudflare row names `pings@907.life`. 337: cutover step 7. 412: Music. 624: the packet checks that no service still authenticates to Fastmail SMTP. |
| M6 owner inputs | Yes, mostly | Gmail and Outlook.com accounts: 671. Apple session: 681. Member C and the confirmations: 684. Yahoo is dropped with a reason (258). The A and B address question is moot now that their addresses exist. Round two left a few new gaps (m5). |
| M7 paper key | Yes, by ruling | 79 and 514: the ruling and the public-ciphertext fact are both stated. 673: the storage rule. |
| Minors m1-m11 | Yes | 493 (ACME), 434 (who lifts a rule), 601 (accident protection, `disable-protection` gate), 542-543 (alert thresholds), 549 (6-hour all-quiet), 545 (routine until cutover), 496 (10-message tolerance), 605 (the $40 ruling), 737-738 (cut-line calls), 83-88 (pointer). |

## 2. The four-mailbox correction

These sections now count four accounts and agree with each other: "What changes" (11), "Rulings" (81), "Who uses what" (98-99), "Size" (252), "Migration" (297-299), "Rehearsal" (307), cutover step 6 (336), rollback (348), sweeps (353), the T+30 packet (357 and 624), triage (379-381), owner items 6-8 (661-668), order of work (701), the end-to-end check (745), and "Not checked" (767 and 773-774). I found no leftover sentence that assumes two migrated mailboxes or new empty ones. The removed "New mailboxes after T+30" call and its cutover paragraph are gone cleanly.

The correction still missed these:

- The contacts and calendars of all four accounts stay live at Fastmail after the final pass, and nothing carries changes made there (M2). Before round two, only the second operator had this exposure. Now two iOS and macOS households do, and their devices keep the Fastmail account until T+30.
- The sizing reason is wrong, and the overflow path weakens a defense (m1, M1).
- Smaller gaps: owner and household asks (m5), the order of the Fastmail packet (m6), per-account rehearsal samples (m7), and Claude's reach into two more people's mail (m8).

**Sizing judgment.** The spec's own rule is three copies at 1.5 times raw mail, which is 4.5 times raw, kept under the 80% alert:

- **CX23 (40 GB, alert at 32 GB).** Geoff's 5.14 GiB (5.52 GB) is about 24.8 GB, plus roughly 4 to 5 GB for the OS, Docker, and the journal: about 29 to 30 GB. That fits, so "Geoff's mailbox alone rules out a CX23" (252) is false. The pre-round-two rule, "a CX23 if the two mailboxes total 6 GB or less", allowed it too. The conclusion still stands, because three more real mailboxes exist and any non-trivial size pushes past 6 GB.
- **CX33 (80 GB, alert at 64 GB).** 12 GB raw is 54 GB, plus about 5 GB, for 59 GB. The 12 GB threshold is sound arithmetic.
- **Headroom.** Geoff's mailbox already takes 5.5 GB of the 12, which leaves about 6.5 GB for the other three. The overflow path is plausible, not remote, so its consequences matter (M1).

## 3. Contradictions, order of work, owner timing

- No section contradicts "Rulings". Line 7, "you answered every open question", sits beside two open questions (m10).
- 233 says the second operator holds "no production secret", but the vault shared with him holds the restic passwords and the admin credentials (562). 489 says a drill server never holds production's secrets, but the restored data carries Stalwart's DKIM and ACME keys (m11).
- **Order of work:** the media drill's `recover` proof can't run under the token the drill is given (M3). Pass 5 doesn't say when the mail bucket's lock rules land, and rehearsal re-imports get locked in for good (m3).
- **Owner timing:** sharing each Stalwart password through Proton, the T+30 device removal, and the plan-tier check aren't in "What Geoff does" (m5).

## 4. The brief and the `### Decide:` blocks

- **Backup lock (29-36):** accurate to the body (426-450 and 87). The growth range is labeled "rough and unmeasured", which is honest. It leaves out the largest unmeasured term (m3), and that changes how often the cleanup comes to Geoff, not which option to pick. It reads well on a phone.
- **Port 25 (38-45):** the recommended option matches the body. The relay option's trigger is narrower than "Rulings needed" 2 at 88, and pre-approving it doesn't remove a stop, because a relay signup is a new vendor account that Geoff makes (m9).
- **"The rulings behind this design" (53):** leaves out the four chat rulings, including the scope correction (m10).

## 5. Claims stated as verified that aren't

- "Geoff's mailbox alone rules out a CX23" is presented as a measured consequence and is arithmetically false (m1).
- "The media drill also proves `restic recover` once" (432, 498, 758) is presented as a plan the drill can carry out. The probe shows it can't under the drill's token (M3).
- 480 says read-only commands use `--no-lock` "so read-only tokens work". The drill's own `restic check` needs it too. I confirmed it works, but the spec doesn't name it (m4).

---

## Major

### M1. A Volume for the mail store takes the mail out of Hetzner's images

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:252, spec:767, against spec:15, spec:323, spec:484, spec:603, spec:638, spec:721, spec:752.
- **Defect:** past about 12 GB of raw mail, "a Hetzner Volume carries the mail store". Hetzner Volumes are "excluded from server snapshots and backups" (Immich brief, line 78, citing Hetzner's Volumes docs). Several parts of the design rest on the mail store being in those images:
  - the brief's "The mail server also gets Hetzner's daily images" (15);
  - the "Image restore" rehearsal row (323), which would then pass with the store absent from the image;
  - the broken-server restore path (484) and its runbook screen (638);
  - the rebuild order's "takes a Hetzner snapshot" (603);
  - "Risks", which names the Hetzner images as a defense against silent store corruption (721);
  - the end-to-end line "Hetzner Backups list a restorable image" (752).

  The trigger is likely. Geoff's mailbox already takes 5.5 GB of the 12 GB, and three more real mailboxes remain. Section 2 has the arithmetic.
- **Proposed fix:** make the overflow path a rescale to a larger cost-optimized type with a bigger local disk, such as CX43, so the store stays local and inside the images. Check the price against the $40 ceiling in the mail pass; it's a method call inside the spend ruling. If a Volume is chosen anyway, the spec must say that the images then hold no mail. Also drop or rewrite 15, 323, 484, 638, 721, and 752 for that case, and say where the staging copy and the side-by-side restore live.

### M2. After the final pass, nothing carries contacts and calendar changes made at Fastmail, and T+30 deletes them

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:331-337, spec:348, spec:353, spec:365, spec:624, spec:703.
- **Defect:** the final Vandelay pass (332) is the last copy of contacts and calendars. Every later carry is mail only: the sweeps are imapsync (353), and the rollback is a reverse imapsync (348). Meanwhile live Fastmail DAV clients remain:
  - **Household members A and B.** Their Fastmail accounts "come off their devices at T+30" (336). Until then, an event or contact saved to a Fastmail calendar or address book on iOS or macOS stays at Fastmail. If Fastmail is still the default account, that's every new item.
  - **The second operator.** He gets "a short guide for his Android client" (336). Nothing says his Fastmail DAV sync stops.
  - **Geoff.** Cutover step 5 repoints Hylki and poplar, but Thunderbird retires only in pass 7 (365, 703). Nothing at cutover repoints it or closes it. If Thunderbird is still the daily client, it also shows no new mail after the MX switch.

  At T+30, removing the three users deletes their Fastmail data. The packet's evidence, "the Vandelay archives cover all four accounts" (624), is satisfied by the pre-cutover archive, so changes made after cutover are lost with no check that would notice. A rollback likewise carries no DAV changes back. This exposure is new in round two for A and B, who had empty accounts before.
- **Proposed fix:**
  - At cutover step 6, have each device turn off the Fastmail account's Contacts and Calendars, and make Stalwart the default account for mail, contacts, and calendars. The account can stay for rollback. Claude drafts the steps.
  - At step 5, close Thunderbird or repoint it at Stalwart, and say which client Geoff reads mail in from cutover day.
  - At T+7, and again in the T+30 packet's evidence, run a Vandelay DAV and JMAP-contacts export of each Fastmail account. Compare its counts and change dates with the cutover archive, and carry any differences.

### M3. The media drill can't prove `restic recover` under the drill's read-only token

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:432, spec:492, spec:498, spec:758.
- **Defect:** the drill renders only "the restic password and the read-only R2 token" (492), yet "the media drill also proves `restic recover` once" (498), and the end-to-end check requires that "the media drill rebuilt a deleted snapshot with `restic recover`" (758). I probed restic 0.19.1 on 2026-10-17 against a read-only local repository:
  - `restic check --no-lock` ran and returned "no errors were found";
  - `restic recover`, `restic repair index`, and both again with `--no-lock`, each failed with "unable to create lock in backend: ... permission denied". They ignore `--no-lock` and need write access to `locks/`, and `recover` also writes a snapshot and `repair index` writes index files.

  The proof also needs a snapshot file deleted first. In the production bucket that's either refused, for one under 30 days, or destroys a real history entry. An executor faces three bad choices: hand the drill a write token, which breaks 492; run `recover` against production; or stop.
- **Proposed fix:** prove `recover` on a copy. During the restore phase, the drill server copies the media repository's objects into a local directory with the read-only token. The proof then deletes `snapshots/` and `index/` there and runs `repair index` and `recover` twice locally. The fold's runbook note covers the second run. If the drill server's disk can't hold both the copy and the restore, say that the proof runs as a separate drill pass. Either way, it never touches the production bucket.

---

## Minor

### m1. The stated reason for CX33 is false

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:252.
- **Defect:** under the spec's own 4.5-times rule, Geoff's 5.52 GB needs about 30 GB on a 40 GB disk, which is inside the 80% line (section 2). The conclusion is right for four mailboxes.
- **Proposed fix:** "Geoff's mailbox alone would fill a CX23 to about 75%, leaving no room for the other three, so the mail server is a CX33."

### m2. Both servers now depend on a type that was sold out on the day it was measured

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:110-111, spec:122.
- **Defect:** the hosting brief (line 91) found CX33 "sold out in every EU location" on 2026-10-17. Round two moved the mail server from CX23, which was orderable that day, to CX33. `provision.sh` stops with a message, but the spec names a location fallback and no type fallback, so both server passes can stall waiting for stock.
- **Proposed fix:** name a type fallback inside the ceiling, such as CAX21 (Arm, 80 GB, $12.49) for mail, since Stalwart publishes arm64 images. Media stays x86 for dubplate. Name a retry window before the pass reports a stall.

### m3. The growth estimate leaves out the largest term, and rehearsal imports get locked in

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:35, spec:450, spec:701.
- **Defect:**
  - All four Stalwart stores are RocksDB (241), so compaction writes new SST files nightly, and restic deduplicates rewritten compressed blocks poorly. With 6 to 12 GB of mail, this term could rival or exceed the whole 15 to 40 GB range. That brings the 200 GB cleanup packet sooner. It doesn't change the Decide choice, because cost stays a few dollars a month.
  - Pass 5 doesn't say when the mail bucket's rules land. If they land at the "first verified backup", every rehearsal re-import adds new packs that stay locked forever.
- **Proposed fix:**
  - Say the range excludes mail compaction.
  - Have the rehearsal week measure `restic stats --mode raw-data` growth on the mail server, and put the figure in the cutover packet.
  - Land the mail bucket's rules after the last rehearsal import, before cutover. Name that step in pass 5, as pass 2 does for media.

### m4. Three small restic points under the locks

- **Severity:** minor. **Tag:** `correctness` (third item `optional`). **Location:** spec:480, spec:496, spec:643.
- **Defect and fix:**
  - The drill's `restic check` takes an exclusive lock unless it gets `--no-lock`, and the read-only token can't write one. The probe confirms that `check --no-lock` works. Name it.
  - `restic key passwd` deletes the old key file, which the Indefinite rule on `keys/` refuses. "Rotating a key" (643) for a restic password then needs Geoff's lift. Say so in the runbook step.
  - Optional: restic's retry backend re-PUTs a pack whose first upload committed but returned an error. Under the `data/` rule, that overwrite is refused and retried for 15 minutes, so a rare nightly backup fails. Note it in the runbook as a known transient.

### m5. Owner and household asks that round two created are missing

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:367, spec:336, spec:357, spec:662-668, spec:675-691.
- **Defect:**
  - "Each member's password reaches them in their own Proton Pass, shared from Geoff's account" (367), and Claude never calls `pass-cli`. So Geoff shares four Stalwart passwords, the second operator's included, and "What Geoff does" doesn't list it. It's needed before cutover step 6.
  - Removing the Fastmail account from the household's devices at T+30 (336) is a household ask. It has no drafted message, and it has to happen before SPF moves to `-all` and DMARC to `quarantine` the same day.
  - "Which Fastmail plan the account is on" is a first-week check (774), but no owner item asks for it, and it likely needs Geoff's admin view.
  - Items 7 and 8 don't name the API-token scopes: mail and contacts read for Vandelay, and Masked Email read for the check at 381. A wrong scope means asking a household member again.
- **Proposed fix:** add the Proton share to "Later" for the mail pass, the device-removal message to the T+30 line, the plan check to item 6, and the scopes to items 7 and 8.

### m6. The Fastmail packet removes the domain before the users whose logins are on it

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:357, spec:361, spec:624, spec:687.
- **Defect:** the order reads "remove 907.life, remove the three other users". The other three logins are almost certainly @907.life addresses, and 361 checks only Geoff's. A domain removal will likely refuse, or orphan logins, while users still sign in on it. That's unverified for Fastmail.
- **Proposed fix:** order it as remove the three users, rename Geoff's login if needed, then remove 907.life and downgrade, in all three places.

### m7. Rehearsal samples and clients don't scale to four accounts

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:313-314, spec:318.
- **Defect:** "50 messages" for dates and "20 messages" for bodies don't say per account, so a draw weighted to Geoff's 35,576 messages could leave a small household mailbox unchecked. The "Clients" row tests iOS and macOS but not the second operator's Android client, which cutover step 6 depends on.
- **Proposed fix:** draw the samples per account, and add one Android row with mail, contacts, and calendar.

### m8. **OWNER FORK:** Claude's reach into two more people's mail

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:297, spec:381-382, against spec:583.
- **Defect:** the passwords section keeps Claude out of personal vaults by having Geoff run a count script (583). The mail path gives Claude full Fastmail tokens for household members A and B. Triage step 2 has Claude add "message counts and sender domains for the last year" for their masks, which shows which services they use. The second operator lists his own masks instead (381). Whether that's acceptable for two household members is their consent and Geoff's call.
- **Options:**
  - (a) As written, with the drafted message to A and B saying plainly what the tooling copies and reads, and that the tokens die at T+30.
  - (b) Treat A and B like the second operator: they list their own masks, and Claude's reads of their accounts are limited to migration and counts.
- **Recommendation:** (a), with the message wording, unless either member would object.

### m9. The port 25 relay option is mis-stated

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:45, spec:88.
- **Defect:** the Decide option pre-approves a relay "for that case only", meaning a refusal or a stall. "Rulings needed" 2 also lists "a lasting Microsoft block". A relay account is a new vendor account, which the spend ruling (78) and the captcha rule (258) give to Geoff, so pre-approval still stops for him at setup. A relay is also a new 907.life sender for the senders table.
- **Proposed fix:** align the trigger in both places. Add to the option: "you'd still create the account; Claude does the rest".

### m10. Brief wording

- **Severity:** minor. **Tag:** `optional`. **Location:** spec:5, spec:7, spec:53.
- **Defect:**
  - "You answered every open question on 2026-10-17" (7) sits two lines above two open questions.
  - "The rulings behind this design" (53) leaves out the chat rulings, the four-mailbox scope correction included.
  - "A short list" (5) is 13 first-week items and 18 later ones.
- **Proposed fix:** "you answered the research questions on 2026-10-17". Add "four mailboxes migrate, a $40 monthly ceiling, and the age key on paper" to 53. Call the list "a list, front-loaded into the first week".

### m11. Two "no production secret" claims are overstated

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:233, spec:489.
- **Defect:** the second operator holds the restic passwords and the admin credentials (562). The drill server holds the restored DKIM and ACME keys.
- **Proposed fix:** at 233, "no secret that renders a server's configuration". At 489, "never holds a credential to an outside production service".

### m12. `promote.sh` mechanics the plan must carry

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:500.
- **Defect:** Hetzner assigns a Primary IP only while the server is powered off, only in the IP's own location, and only to a server holding no Primary IP of that type ([Primary IP FAQ](https://docs.hetzner.com/cloud/servers/primary-ips/faq/)). A changed IPv6 also needs manual network configuration. So a `--hold` drill server must be built in the production IPs' location, and `promote.sh` must power it off, unassign the drill IPs, and assign the production ones. Promotion should also turn on Hetzner Backups for mail and set the host name that EHLO uses.
- **Proposed fix:** one sentence each in "Drills": `--hold` pins the location, and `promote.sh` performs those steps.

---

## Judgments asked for

- **Can Geoff rule the forks on the brief?** Yes. The lock block is now true to the body. The port 25 block needs m9's one-line correction.
- **The CX23 to CX33 change:** sound in outcome, wrong in one stated reason (m1). Its overflow path needs M1's fix before it's safe.
- **Minimal attendance:** close. m5's four items and M2's device steps are the remaining household touches the plan would otherwise discover on cutover day.
