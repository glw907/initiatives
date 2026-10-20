# Self-hosting design: fold verification (2026-10-17)

Target: `specs/2026-10-17-self-hosting-design.md` at commit `1bf2f10`, the fold of the contract, mechanics, and data reviews. I took no part in the fold or the reviews. I checked the spec text itself, not the fold record's claims, against the three reviews, the handoff, and the briefs. I spot-checked the new mechanisms against official docs. I also ran one local restic probe. Line numbers refer to the spec unless another file is named.

**Counts:** 1 blocker, 7 major, 11 minor. Three findings carry an **OWNER FORK**, and one of those is major.

**Verdict:** the fold closed nearly every review finding where the record says it did. The blocker is new. It sits in the protection claim behind the first "Decide" block, so Geoff would make the fork's main choice on a false premise. The majors are drill and restore paths that break the drill contract or can't run, one vault with no way to be written, one missing 907.life sender, and owner inputs that are still gathered late.

---

## 1. Did each blocker and major close where the fold record says?

Contract and mechanics findings closed in the spec text at the cited locations, apart from the gaps below. Data findings closed the same way, with the same exceptions.

| Finding | Closed in the spec? | Note |
|---|---|---|
| mechanics 1 / data B1 (retention vs locks) | Yes, 420-441 | keep-within 35d, `index/` and `locks/` unlocked, `config` locked. Verified safe: restic measures `--keep-within` "within the specified duration of the latest snapshot" ([forget docs](https://restic.readthedocs.io/en/stable/060_forget.html)), and the latest snapshot is never newer than now, so retention can't reach a snapshot inside the lock. The spec's wording at 440 ("counts from a snapshot's start time") is loose but errs on the safe side. |
| mechanics 2 / data M18 (Age locks and old history) | **Rewritten wrongly** | See B1 below. The fork exists, but its premise is false. |
| contract M1 / mechanics 5 / data M14 (drill impersonates production) | Partly | Mail ports are closed. ACME was dropped without a word (m1). `cloudflared` isn't excluded (M2), and the image-based drill breaks the contract outright (M1). |
| contract M16 / mechanics 12 / data M11 (server gone) | Partly | The R2 path is named. Promoting a `--keep` server, and the second operator rendering its secrets, are unspecified (M3). |
| contract M11 / mechanics 9 (owner actions) | Mostly | The Apple test devices, the names of the A and B addresses, and the Workers Paid pre-approval are still missing (M6, m8). |
| contract M3 / data m21 (senders) | Mostly | dubplate's Fastmail SMTP sender is missing (M5). |
| All other contract M2-M19, mechanics 3, 4, 6-13, data M1-M20 | Yes | Checked line by line: 211/243/331, 259-269, 503-539, 304-319, 255, 459-466, 333-349, 571-577, 604-614, 726-740, 589, 273, 205, 412, 490-491. |

## 2. Contradictions and order of work

- The "Rulings" section is unchanged by the fold (`diff` of the section shows only the heading that follows it). No fold text overrides a ruling. One contradiction with the "Cut line" ruling predates the fold and is still unflagged (m10).
- New contradictions: 15/31/428 against restic's deduplication (B1), 428 against 494 on who lifts a lock (m2), 255 against the owner list at 657 on Yahoo (M6), and 481-486 against 490 (M1).
- Order of work: pass 2 needs the `Servers emergency` vault, which nothing creates before pass 4, and nothing can write (M4). Pass 1 locks `config` and `keys/` before pass 2 runs `restic init`, so any re-init during build needs a lock lift (m2).

## 3. Were the new mechanisms sourced or probed?

| Mechanism | Spec | My check |
|---|---|---|
| R2 prefix rules, Age and Indefinite, existing objects covered | 420-436 | Confirmed: "Rules apply to both new and existing objects", and "the strictest (longest) retention requirement takes precedence" ([bucket locks](https://developers.cloudflare.com/r2/buckets/bucket-locks/)). The docs don't say when Age is counted from. The fold's probe supports "from upload". Also: "A bucket cannot be emptied while any bucket lock rules are configured" (same page), which bears on m2. |
| Age lock protects "any backup from the last 30 days" | 15, 31, 428 | **Refuted.** See B1. |
| Hetzner firewall outbound semantics | 485 | Confirmed: "If you define one or more outbound rules, the outbound direction also changes to implicit" deny, and rules are allow-only ([firewall FAQ](https://docs.hetzner.com/cloud/firewalls/faq/)). The FAQ also says traffic to Hetzner's DNS resolvers always passes. Port 443 stays open outbound, which matters for M1, M2, and m1. |
| Browser terminal: email prefix equals Unix username | 224 | Confirmed: "For SSH and VNC, user email prefixes must match their username on the server" ([browser rendering](https://developers.cloudflare.com/cloudflare-one/applications/non-http/browser-rendering/)). The same rule binds Geoff's own row at 219. It works only if his GitHub email prefix is `geoff`, and the spec doesn't say so. |
| Hetzner Backups die with their server | 477 | Confirmed: "Backups are bound to a single server and will automatically be deleted if you delete the server", and "we cannot guarantee data consistency" for a running server ([backups FAQ](https://docs.hetzner.com/cloud/servers/backups-snapshots/faq/)). |
| Delete protection as "the real boundary" | 589 | Overstated (m3). |

The fold record's unverified list matches the spec's "Not checked" table, except for the Proton item-sharing caveat at 363 (folded into M4).

---

## Blocker

### B1. Under Age locks, a compromised server can make every backup unrestorable, the last 30 days included

- **Severity:** blocker. **Tag:** `correctness`. **Location:** spec:15, spec:31, spec:35, spec:83, spec:428, spec:514, spec:704.
- **Defect:** restic deduplicates, so "for modified files, only modified Blobs have to be saved in a subsequent backup" ([restic references](https://restic.readthedocs.io/en/stable/100_references.html)). Yesterday's snapshot therefore depends on packs uploaded months ago: the first full upload of the photo library, and RocksDB's rarely compacted bottom-level files. A 30-day Age rule on `data/` leaves those old packs deletable by the server's own token. Deleting them breaks every snapshot that references them, including every snapshot inside the window.
  - **Local probe (restic 0.19.1, 2026-10-17):** I backed up one 3 MB file, then added a 1 MB file and backed up again. Next I deleted only the packs that existed after the first backup. `restore latest` then restored "976.562 KiB / 3.815 MiB" and lost the first file, and `check --read-data` reported "repository contains errors".
  - **The Worker can't see it.** The daily check reads only `snapshots/`, `config`, and `keys/` (514), so it never notices a deleted pack.
  - **False statements.** "No server can delete … any backup from the last 30 days" (15), "though never the last 30" (31), "the Worker reports a deleted backup within a day" (35, 83), and "the last 30 days are still there to restore from" (428) are all false under the recommended option. The Decide block asks Geoff to pick that option on those grounds.
- **Proposed fix:** rewrite the fork honestly, and change the recommendation.
- **OWNER FORK: how deep the backup lock goes.**
  - (a) **Recommended.** Indefinite rules on `config`, `keys/`, and `data/`. A 30-day Age rule on `snapshots/`. Nightly `forget --keep-within 35d …` stays, and nothing prunes automatically. No server can destroy backed-up data. A snapshot file deleted by an attacker after 30 days can be rebuilt from the locked trees with `restic recover`, and the pre-go-live drill should prove that once. Storage grows by each day's new packs. Photos add little, because originals never change. Mail could add the most, because compaction rewrites files. The mail rehearsal measures the daily growth with `restic stats --mode raw-data`. A yearly cleanup, or one past a set storage line, comes to Geoff as a packet: lift the rule, prune, restore the rule. This is mechanics finding 2's option (a), which the fold replaced with a variant that also drops `forget`.
  - (b) Keep the 30-day Age rules, and say what they buy: "a compromised server can't delete anything uploaded in the last 30 days, but after that it can make every backup unrestorable". Add a Worker check that lists `data/` daily and alerts on any pack deleted outside the monthly prune night. This option detects the attack but can't prevent it.
  - Either way, fix lines 15, 31-36, 82-84, 428, and 704 to match, and record the choice in `decisions.md`.

---

## Major

### M1. The mail drill from a Hetzner image boots a full copy of production

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:490, against spec:481-486.
- **Defect:** "The mail drill also starts Stalwart once from a Hetzner backup image." A drill can't restore that image over production. It has to turn the backup into a snapshot and create a new server from it, and that server is a byte copy of production:
  - the backup timer, holding the production bucket's write token;
  - the health timer, posting heartbeats with the production token;
  - `cloudflared`, holding the production tunnel token;
  - Stalwart's queue and ACME account.
  
  `firewall-drill.json` allows outbound 443, so the timers and the tunnel all reach Cloudflare. The four drill limits at 483-486 can't hold for this drill, and the duplicate heartbeat can hide a dead production server, which is exactly what contract M1 warned of.
- **Proposed fix:** create the image drill server with a firewall that allows no outbound traffic except DNS. With 443 closed, R2, the heartbeat Worker, and the tunnel are all unreachable. Say that its checks run over loopback only. Write down that the drill tests a different path from the runbook's in-place console restore at 626.

### M2. A drill server built from R2 can join the production tunnel

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:483-486, spec:159-161, spec:217.
- **Defect:** the drill contract leaves out the `backup` and `health` roles but not `cloudflared`, and the mail and media hosts both carry it (110, 217). Outbound 443 is open. A drill that renders the tunnel token registers as a second connector of the production tunnel, and Cloudflare spreads connections across connectors. The second operator's browser terminal, or Stalwart's admin page, can then land on a throwaway server that is about to be destroyed.
- **Proposed fix:** add "no `cloudflared` role and no tunnel token" to the drill contract. Make `restore-drill.sh` refuse a drill role list that contains `backup`, `health`, or `cloudflared`. This is a fixed list, not the refused secret-inspection gate.

### M3. The "server gone" path can't make a production server, and the second operator can't run it

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:477, spec:481-486, spec:181, spec:552, spec:627.
- **Defect:** `restore-drill.sh --keep` builds a server under the drill rules and keeps it, so the spec never says how the kept server becomes production:
  - Its label stays `purpose=drill`, which the authority rules let Claude delete (66, 589), and it has no delete protection.
  - It keeps `firewall-drill.json` (inbound 22 only, no 25), and it has no `backup` or `health` role, no tunnel, and read-only R2 tokens.
  
  The second operator runs the path "from any Linux machine with the repo and the emergency vault's tokens" (477). But production secrets render only from `~/.local/secrets` on Geoff's workstations (181). The emergency vault holds no write token, tunnel token, heartbeat token, or Spamhaus key (552). And `base/keys/` holds only Geoff's and Claude's keys, so he can't SSH into the result either.
- **Proposed fix:**
  - Give `--keep` a promote step: the production label, firewall, roles, and delete protection.
  - Pick one source for production secrets and name it: either each host's rendered secret files in its restic backup, which restic already encrypts, or a per-host secrets item in the emergency vault.
  - Either make the path runnable by him with those secrets, or change the runbook screen at 627 to "call Geoff" and say so in "Access".

### M4. The `Servers emergency` vault has no creator, no sharing step, and no write path, and pass 2 needs it

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:552, spec:572, spec:484, spec:682, spec:641-673.
- **Defect:**
  - Nothing says who creates `Servers emergency` or shares it with the second operator.
  - "The media pass fills the media entries", but the Proton brief rules that Claude "should never call `pass-cli` directly" (proton-pass brief, line 83), and Claude's only token is an agent scoped to `Workstation`.
  - Step 4's "Claude creates the `Workstation` vault and the agent tokens" needs a full user session, meaning Geoff's web login with a FIDO2 touch. "What Geoff does" lists only the renewal (673).
  - Pass 2's drill uses "the emergency vault's read-only R2 tokens" (484), but Proton is set up in pass 4, which "can run alongside pass 2 or 3" (682).
  - 363 also relies on item sharing from Geoff's account, which the fold record lists as unverified.
- **Proposed fix:**
  - Add to "What Geoff does": create the `Workstation` vault, the per-host agent tokens, and `Servers emergency`, and share the last with the second operator. That's one FIDO2 session in the passwords pass.
  - Name the write path, either a scoped agent token with editor role on `Servers emergency` only, or Geoff pasting values Claude stages through `secret-receive`.
  - Order the work so that pass 4's vault step runs before pass 2's drill, or let the pass 2 drill read the read-only tokens from `~/.local/secrets` and move the vault test to the pass 5 drill.

### M5. dubplate sends 907.life mail through Fastmail SMTP, and the T+30 removal breaks it

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:259-269, spec:353, spec:408, spec:612.
- **Defect:** dubplate's identity design rules "The estate uses Fastmail on port 587 with STARTTLS" for its magic links (`dubplate/docs/specs/2026-09-08-rung-5-identity-auth.md`, Fork 2 ruling). The age store holds `DUBPLATE_SMTP_PASSWORD`.
  - "Senders of 907.life" leaves dubplate out.
  - Cutover step 7 repoints Immich but not dubplate.
  - The Fastmail packet's evidence row (612) doesn't check for any SMTP client still on Fastmail.
  
  If dubplate 0.8 is live by T+30, removing 907.life from Fastmail silently breaks member sign-in. The same dubplate spec also names a pings Worker that sends as `pings@907.life` through Cloudflare. The Cloudflare row covers its authentication, but it should be listed.
- **Proposed fix:** add dubplate (via Fastmail, then Stalwart on 587 from the media server's IPs, which the firewall already allows) and the pings Worker to the senders table. Add "repoint dubplate's SMTP to Stalwart, if it is deployed" to the cutover steps. Add "no service authenticates to Fastmail SMTP" to the 612 evidence row.

### M6. Owner and household inputs that will stop execution are still missing or late

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:641-673, against spec:255, spec:313, spec:575-576, spec:352.
- **Defect:** the minimal-attendance goal still has gaps that will stop a run:
  - **Rehearsal devices.** The "Clients" row (313) needs one iOS and one macOS device for the profile test. Geoff has neither, and the later list (665) lends only a phone for Immich. The mail rehearsal stops here. Contract M11 named this item, and the fold record claims M11 is closed.
  - **Address names.** The addresses for household members A and B (contract M11 item 4) are never asked for, though T+30 creates them (352).
  - **Yahoo.** 255 sends to Yahoo, but owner item 10 names only Gmail and Outlook.com. If a household member's account stands in, that person, not Geoff, has to report where the mail landed. That's a household ask with no date.
  - **Household asks.** Member C's own 1Password move (575) and every member's autofill and top-ten confirmation (576) aren't in the owner list or the household-message list.
  - **Emergency vault.** The FIDO2 vault session is missing (M4).
- **Proposed fix:**
  - Add to the first week: name A's and B's addresses; name who owns each test inbox, Yahoo included; and book one session with a household member's iPhone and Mac for the rehearsal.
  - Add to "Later": member C's vault move, and the members' confirmations, each as a message Claude drafts.

### M7. **OWNER FORK:** the age key on paper is a single key to every workstation secret, and the ciphertext is public

- **Severity:** major. **Tag:** `correctness`. **Location:** spec:504, spec:659, spec:719.
- **Defect:** the fold settled data M3 as a method call. `glw907/workstation` (the dotfiles repo) is **public** (`gh repo view`: `"visibility":"PUBLIC"`), and its `secrets/values.age` holds `CLOUDFLARE_API_TOKEN` (full account access), `HCLOUD_TOKEN`, the GitHub App key, and every restic password and token this design adds. With the age key on paper, anyone who reads the printed kit, or a print spool, can decrypt every one of them from GitHub. The spec says only "the dotfiles repo's encrypted secret store" and never mentions that the ciphertext is public. The Proton recovery phrase on the same sheet may already grant comparable reach, but that's unverified. Where Geoff's root secrets live physically is a security-posture call, so it belongs to Geoff.
- **Options:**
  - (a) The age key on paper as written. The kit becomes a "keys to everything" document and is stored to that standard.
  - (b) A passphrase-wrapped copy: `age -p` encrypts the identity to a passphrase Geoff memorizes, and only the wrapped key is printed.
  - (c) Proton only, accepting that losing Proton loses the archives and every restic password.
- **Recommendation:** (a), on the condition that the spec states the public-ciphertext fact and the kit's storage rule. Choose (b) if the kit lives anywhere a guest or a burglar could read it.

---

## Minor

### m1. The drill dropped "ACME off"

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:485.
- **Defect:** contract M1 and data M14 asked for ACME off on a drill. The fold record answers the queue part ("pausing the queue is unneeded") but drops ACME without saying why. Outbound 443 is open, so a restored Stalwart places orders with the production ACME account. Validation then fails, because DNS and inbound 443 point elsewhere, and failed validations count against Let's Encrypt's per-account, per-hostname limit while production may be renewing.
- **Proposed fix:** start drill Stalwart with ACME disabled (Stalwart serves its stored certificate), or block outbound 443 except to R2's endpoint.

### m2. Who may lift a lock rule is unstated, and the locks land before `restic init`

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:428, spec:494, spec:586, spec:632, spec:679.
- **Defect:** 428 says "Geoff, or Claude with the account's Admin token" removes an Indefinite rule. 494 says the archive lock "stays until Geoff lifts it". `cloudflare/r2.sh --apply` is a standing allow rule and manages "lock rules" (170), so an unattended run can remove one. Pass 1 also sets the rules before pass 2's `restic init`. Since "a bucket cannot be emptied while any bucket lock rules are configured", every re-init during the build then needs a lift.
- **Proposed fix:**
  - State that `r2.sh` only adds rules.
  - Make lifting a rule on `servers-backup-*` or `servers-archive` a Geoff packet: the runbook step at 632, run by Geoff or approved by him.
  - Set the backup buckets' rules in pass 2, after `init` and the first verified backup.

### m3. Delete protection is not a boundary against the token that holds it

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:589.
- **Defect:** "So the real boundary is outside the scripts." But the same project token that creates servers can turn protection off. The deny rules match raw command text, and a script that Claude edits and then runs under the `provision.sh --apply` allow rule isn't raw command text. Protection turns an accidental delete into two deliberate API calls. That's worth having, but it's not what 589 claims.
- **Proposed fix:** reword 589 to say that, and add `disable-protection` to the strings `check.sh` rejects in `infra/` and `scripts/`. That's one grep in the existing gate.

### m4. Two routine alerts will fire on normal operation

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:532, spec:533.
- **Defect:**
  - "The snapshot count drops" fires whenever nightly `forget` ages out a weekly or monthly snapshot on the same night it drops a daily, which happens every few weeks under the retention flags at 440.
  - "A mailbox's count … drops more than 2% in a day" fires when someone clears out old mail. Data M17's proposal said "that no user action explains", and the spec dropped that qualifier.
- **Proposed fix:** alert when a `snapshots/` object uploaded in the last 35 days disappears. Retention never removes one of those, so the signal is exact. Raise the mailbox threshold, or include the day's Trash moves in the heartbeat.

### m5. The all-quiet check gives a false alarm after a workstation has been off

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:539.
- **Defect:** the all-quiet message is posted once a day, and ntfy's default cache keeps 12 hours. Suppose a laptop is off when the message is posted and boots more than 12 hours later. `since=` can't return the message, so the subscriber's 26-hour check fires. On a laptop, that happens every few days.
- **Proposed fix:** post the all-quiet every 6 hours, or start the 26-hour clock at subscriber start.

### m6. The inbound probe alerts urgently before cutover

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:279, spec:508, spec:526.
- **Defect:** the probe is enabled "from the day the mail server exists". During the rehearsal Stalwart is reimported and restarted repeatedly, so an unconfirmed probe sends an urgent alert to the second operator's phone for a server that isn't in production yet.
- **Proposed fix:** route probe failures to the routine topic until cutover day.

### m7. The mail drill's exact count match is flaky by design

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:462, spec:488.
- **Defect:** the manifest counts are read before the stop (step 2), so mail that arrives or is deleted before the stop makes the restored store differ from the manifest. Then "restored counts equal the snapshot's manifest" fails a good drill.
- **Proposed fix:** allow a small stated tolerance, or read the counts from the stopped copy after restore on the drill and compare with the following night's manifest.

### m8. **OWNER FORK:** what counts as a purchase needs a number

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:136, spec:593.
- **Defect:** the definition is sound and follows from the authority ruling. But "inside this design's budget" has no ceiling, and option (a) of B1 adds storage that grows. Contract m1 also recommended pre-approving Workers Paid if the foundation check finds the account on Free. The fold dropped that, so the foundation pass can still stop to ask for a purchase.
- **Options:**
  - (a) A monthly ceiling, with Workers Paid pre-approved.
  - (b) As written, with any surprise a stop.
- **Recommendation:** (a). Claude's billable resources stay under $30 a month in total, and Workers Paid at $5 a month is pre-approved if needed.

### m9. **OWNER FORK:** household members A and B wait about a month for mail

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:11, spec:344, spec:720.
- **Defect:** when two household members get their addresses is something the household sees, so it's a product and priority call. The spec records it under "Contestable calls" rather than as a ruling.
- **Options:**
  - (a) After T+30, as written.
  - (b) On cutover day, with their addresses created as free aliases on Geoff's Fastmail first, so a rollback delivers their mail to Geoff instead of bouncing it. That's one more Fastmail web-UI step for Geoff.
- **Recommendation:** (a), unless either member is waiting on the address. The approval should name it as one line Geoff can overrule.

### m10. Two cut-line items are exceeded without a flag

- **Severity:** minor. **Tag:** `correctness`. **Location:** spec:113, spec:191, spec:284, against the Rulings "Cut line".
- **Defect:** the approved cut says "MTA-STS only if it is a one-time record" and "CI is linting only". The design runs an MTA-STS Worker with a `testing` to `enforce` change, and CI runs container checks. 191 says "per the cut line", which isn't accurate. Both predate the fold, but neither is in "Contestable calls".
- **Proposed fix:** add both to "Contestable calls" with their one-line reasons.

### m11. Readability: duplicated asks and an evidence paragraph

- **Severity:** minor. **Tag:** `optional`. **Location:** spec:29-45, spec:78-87, spec:761.
- **Defect:** the two `### Decide:` blocks and "## Rulings needed" state the same two forks twice, with different detail. 761 is a single sentence of about 130 words that repeats the fold record's verification list. The rest of the growth from 561 to 761 lines is load-bearing: the rehearsal table, the rollback table, "Irreversible steps", and the senders table.
- **Proposed fix:** keep the Decide blocks as the asks, and cut "Rulings needed" to one line that points to them. Replace 761 with a link to the fold record.

---

## Judgments asked for

- **Household members A and B after T+30:** an owner call, but a small one (m9).
- **The age key on paper:** an owner call. The public ciphertext makes it more than a method call (M7).
- **What counts as a purchase:** a method call in shape, but it needs a budget number, and that is Geoff's (m8).
- **The archive bucket's lock:** acceptable as a method call. Everything is age-encrypted, and the rule can be lifted. The real gap is who lifts it (m2).
- **Can Geoff rule the forks on this evidence?** Not the backup lock: its premise is false (B1). The port 25 fork, yes: options, cost, and trigger are all stated.
- **Minimal attendance:** close, but not yet complete (M4, M6, m8).
