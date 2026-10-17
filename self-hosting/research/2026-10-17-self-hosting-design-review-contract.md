# Self-hosting design review: contract and criteria lens (2026-10-17)

Target: `specs/2026-10-17-self-hosting-design.md` at commit `faeb0b2` (branch `self-hosting`). Lens: is every promise testable, does each criterion name its fixture and its failure reason, can any criterion pass vacuously, which promises have no criterion, which owner actions are missing from "What Geoff does", and are the rollback and abort conditions concrete. Geoff's rulings of 2026-10-17 are taken as decided.

Evidence read: the spec, the brainstorm handoff, and the research briefs (mail-cutover, backups, stalwart, immich, proton-pass, and server-baseline and hosting by search). Two facts come from the workstation: `~/Projects/907-life/wrangler.toml` declares two Cloudflare `send_email` bindings, a contact form to `geoff@907.life` and an unrestricted `EMAIL` binding for cairn magic links, and `src/theme/cairn.config.ts:74` sends as `noreply@907.life`. Claims marked "from memory" are not verified against a primary source in this review.

Counts: 0 blockers, 19 major, 16 minor. Four findings are OWNER FORKs.

## Major

### M1. The restore drill and `restore-drill.sh --keep` can impersonate production (correctness)

Location: spec:141, spec:362, spec:366, spec:384, spec:437.

Defect: a drill server is built "from the repo and the R2 backups alone" (spec:146), so it gets the `backup` and `health` roles and a restored Stalwart. The spec never says what a drill host must not do. A restored mail store carries its outbound queue, its ACME account, and its DKIM keys (stalwart brief section 3: "Everything lives in that directory"). Port 25 follows the account (mail-cutover brief section 1), so once the limit request is approved, a drill host can send its queued mail again. A drill host that runs the health timer posts heartbeats with the production server's token, which can hide a dead production server from the monitor. A drill host that runs the backup timer writes snapshots into the production bucket, or runs `forget` against it.

Fold: add a "drill host contract" to the Drills section. A drill host gets no `backup` or `health` role, no production heartbeat or R2 write token (read-only restore token only), a firewall with outbound 25, 465, and 587 closed, and Stalwart started with its queue and ACME off. Add a gate check: `restore-drill.sh` refuses to start if the rendered secrets for a `purpose=drill` host contain a heartbeat or write token.

### M2. Immich cannot reach Stalwart after mail moves (correctness)

Location: spec:176, spec:308.

Defect: spec:308 has Immich send "through Stalwart on port 587", but spec:176 keeps 587 closed on the mail server. The fallback, 465, is blocked outbound on every Hetzner Cloud server until a limit request is approved (server-baseline brief line 50, immich brief section 6). The limit request is described as account-scoped, but whether its approval lifts 465 for the media server is not stated anywhere. As written, album invites and password-reset mail from Immich fail on the day mail moves, and no criterion would notice.

Fold: open 587 in `firewall-mail.json` with the media server's IPv4 and IPv6 as the only source, and add an Immich send test, "Immich's SMTP test sends to a household mailbox and the message arrives", to the mail cutover checks and the T+30 list.

### M3. The DMARC and SPF ramp ignores Cloudflare's 907.life senders (correctness)

Location: spec:217, spec:219, spec:266, spec:269, spec:542.

Defect: the 907.life site sends mail as `noreply@907.life` through Cloudflare Email Sending (magic links and the contact form; see `907-life/wrangler.toml`), and the monitor's inbound probe would add a third Cloudflare sender (spec:385). The `p=reject` trigger is "once the reports show only Stalwart passing" (spec:219). That can never hold while Cloudflare sends legitimately. So the end-to-end item "DMARC at `p=reject`" either never passes, or someone moves to reject without checking that Cloudflare's mail is aligned. Then magic-link login mail could be rejected by receivers, and Stalwart could reject the monitor's own probe, which raises a false urgent alert. The spec has no sender inventory.

Fold: add a "Senders of 907.life" table: Stalwart, Cloudflare Email Sending (site and monitor), and Fastmail until T+30. Change the reject and quarantine triggers to "every source in the inventory passes aligned DKIM in 14 consecutive days of aggregate reports, and no unlisted source sends more than N messages". Add a check before each step: a magic-link mail from the 907.life site and a monitor probe both show `dmarc=pass` at Gmail and at Stalwart.

### M4. The monitor criterion proves delivery, never detection (correctness)

Location: spec:379-394, spec:547.

Defect: "The monitor has delivered a test alert of each priority to each subscriber" passes even if no probe ever fires on a real failure. It also does not say what counts as "delivered": with Do Not Disturb on, a normal-urgency `notify-send` goes only to the tray. Nothing watches the watcher either. If the Worker's cron stops, the ntfy topic changes, or a workstation's subscriber service dies, every alert goes silent, and the calm-desktop rule means silence looks like health.

Fold: replace spec:547 with fault-injection criteria, each with its fixture and expected result:
- stop Stalwart on the mail host, and an urgent alert arrives within 10 minutes (two probes);
- stop the media health timer, and a routine "missing heartbeat" alert arrives within the stated threshold (see m8);
- hold a backup timer, and the 36-hour alert fires (simulated by backdating the D1 row);
- make the inbound probe fail (send it to a nonexistent local part), and an urgent alert arrives.

For each one, the criterion is a critical banner seen on both workstations (urgent) and a notification on the second operator's phone. Add a dead-man for the monitor: it posts one daily "all quiet" message on the routine topic, and the workstation subscriber alerts when none has arrived in 26 hours. `check-drift` checks that the subscriber unit is active.

### M5. The inbound probe, the main defense against silent mail loss, has no fallback and no pre-cutover behavior (correctness)

Location: spec:385, spec:255, spec:522, spec:556, spec:561.

Defect: the daily inbound probe is named as a defense against silent RocksDB corruption (spec:522), and it gates cutover (spec:255). It depends on an item in "Not checked": whether Cloudflare Email Sending can deliver to its own domain (spec:556). The fallback is "the design changes if a check fails" (spec:561), which leaves the executor to redesign mid-pass. The probe also follows MX. Before cutover, MX points at Fastmail, so a probe sent during the rehearsal and the first weeks lands at Fastmail and fails at Stalwart, which would raise a false urgent alert. The spec sets no deadline after which a missing arrival counts as a failure.

Fold: name the fallback now. The Stalwart brief's section 9 offers one: a daily JMAP query on the mail host for a DMARC aggregate report from Google or Microsoft in the last 48 hours. State that before cutover the probe either targets Stalwart by direct SMTP connection from outside, or stays off. Define a failure as "no arrival confirmed by the health timer within 60 minutes of the send".

### M6. Mail cutover rollback has no triggers, no owner, and no deadline (correctness)

Location: spec:251-259, spec:264.

Defect: "A failed check pushes an urgent alert to Geoff. Rollback is a reverse MX switch" does not say which failed checks force a rollback, who decides, or how long fixing forward may run first. The local-delivery check (spec:255) is a different kind of check: a failure there is expected and the sweeps handle it, so it should never trigger a rollback, but nothing says so. "T+30, if clean" (spec:264) is undefined. The reverse imapsync (spec:259) needs a Fastmail credential with IMAP write access for both accounts, which nobody front-loads (see M11).

Fold: add a rollback table:

| Check | On failure |
|---|---|
| Inbound from outside | Fix forward for 30 minutes, then roll back without waiting for Geoff |
| Outbound auth to Gmail and Outlook.com | Fix forward, no rollback, since Fastmail can't send for 907.life after the switch either way |
| Local delivery from inside Fastmail | Expected; record it and rely on the sweeps |
| Any client unable to read mail | Fix forward |

Name Claude as the person who decides a rollback within the window. Define "clean" at T+30: no rollback happened, the last three sweeps copied zero new messages, DMARC reports pass per M3, and no household member has reported missing mail. Include Sent in the reverse sync.

### M7. The Immich cutover has no rollback and no "week of watching" criteria (correctness)

Location: spec:304-307, spec:500.

Defect: the move has a stopped pod as its safety net, but the spec names no rollback trigger or path. The path would be: restart the pod, revert photos.907.life to the proxied CNAME, and copy back any uploads made in the meantime. The spec also does not say what the week must show before the irreversible pod deletion comes to Geoff. The patch upgrade at spec:305 skips the dump and snapshot that the Immich brief requires, because downgrades are not supported "even within the same minor version".

Fold: add the rollback triggers: a restore failure, integrity-page errors, or a failed large upload. Add the rollback steps. Set the week's pass bar: zero integrity errors, a nightly backup each night, uploads from at least two household phones, and no client re-login loops. Put "manual dump plus Hetzner snapshot" before the patch upgrade.

### M8. The rehearsal's pass bar is undefined, contacts and calendars go unchecked, and the loop has no exit (correctness)

Location: spec:239-247, spec:520.

Defect:
- Step 2 compares only mail. The 188 contacts, the shared contacts account, and the calendars (the mail-cutover brief asks for a spot check of recurring events and time zones) have no check.
- Fastmail stays live during the rehearsal, so exact count equality fails on any new mail. Trash and Junk stay behind, so totals differ by design. The comparison needs a fixture: counts read from Vandelay's `inspect` on the archive, or Fastmail counts at the export timestamp, excluding Trash and Junk.
- "A sample of bodies" has no size and no method.
- "Claude repeats the rehearsal until it is clean" has no bound and no fallback. The brief's fallback is imapsync, which the spec never names.
- The rehearsal's own test mail and client state stay in the real mailboxes before the final pass.

Fold: write the bar as a table. Per mailbox, total and unread counts equal the archive's counts, excluding Trash and Junk. `$flagged` and `$answered` are equal. `receivedAt` matches on 50 messages drawn across the date range. The SHA-256 of the raw blob matches on 20 bodies, or a header-normalized diff where Stalwart adds headers. The contact count is equal. The event count per calendar is equal, and three recurring events and one cross-time-zone event are spot-checked. After two failed rehearsals on the same defect, switch the affected data type to imapsync (mail) or `.ics` and vCard import, and record it in `decisions.md`. Reset the rehearsal accounts before the final pass, or list the test messages to delete.

### M9. The outbound authentication test has unowned fixtures and can pass when mail is dropped (correctness)

Location: spec:207, spec:244.

Defect: "a test send goes to Gmail, Outlook.com, Yahoo, and mail-tester. Each must show SPF, DKIM, and DMARC passing". Nobody owns test mailboxes at those three providers, and reading their headers needs a login. Microsoft's documented failure mode is a silent drop (mail-cutover brief section 1), so "show passing" has no message to read when the risk is real. The mail-cutover brief's post-cutover test also checks inbox placement, which the spec drops.

Fold: name the fixtures, with an owner action in M11 for Geoff to create or name the Gmail, Outlook.com, and Yahoo test accounts and hand their app passwords over with `secret-receive`. Change the criterion to: "arrives in the inbox (not Junk) within 15 minutes, and the received headers show `spf=pass`, `dkim=pass` with `d=907.life`, `dmarc=pass`, and TLS". A missing message counts as a failure and starts the delisting flow.

### M10. Restore drills have no pass bar, and the backups record nothing to compare against (correctness)

Location: spec:340-345, spec:357-366, spec:546.

Defect: "Both servers pass a restore drill from R2" (spec:546) never says what "pass" means. The backups brief's verification compares against "the pre-disaster numbers the runbook records", but the mail backup writes only a `VERSION` file (spec:343), and the media backup writes nothing. A drill therefore has no fixture to compare with, and "Stalwart started" would pass it.

Fold: each backup run writes a manifest beside the data. For mail: per-account message counts read over JMAP before the stop, plus the version. For media: asset counts from `/api/server/statistics`, plus the dump file name and the Immich version. The drill passes when `restic check` is clean, the restored counts equal the manifest, and the per-service checks pass. For mail, a JMAP login works and the DKIM selector matches. For media, the integrity page shows zero errors, the SHA-256 of three sampled originals matches, and a shared link opens.

### M11. Owner actions that execution will block on are missing from "What Geoff does" (correctness)

Location: spec:472-492.

Defect: the goal is minimal attendance, but these steps need Geoff, a household member, or a web console, and none is listed. Mechanisms marked (fm) are from memory and need a quick check.

First-week additions:
1. Create the GitHub OAuth app for the Cloudflare Access GitHub login method. GitHub has no API to create OAuth apps (fm). Hand over the client secret with `secret-receive`.
2. Create Fastmail app passwords with IMAP access for both migrated mailboxes. The post-cutover sweeps and the reverse sync need them (spec:259, spec:263). Confirm Geoff's own DAV app password exists for the CalDAV import (spec:230). Today only the second operator's credentials are listed (spec:482).
3. The second operator's Fastmail API token: Fastmail tokens are per user (fm), so he may have to create it while signed in himself. If so, it becomes his action.
4. Name the addresses for household members A and B, and confirm the inventory of every 907.life address Fastmail accepts (aliases, `postmaster@`, catch-all). Fastmail's JMAP doesn't expose alias or catch-all configuration (fm).
5. Create or name the Gmail, Outlook.com, and Yahoo test accounts (M9). Outlook.com signup may require a phone (fm), and Geoff has none.
6. Have FIDO2 keys on hand: two, per spec:402. Buying them is a purchase.
7. Create the Hetzner API token for the `Servers emergency` vault (spec:407). Hetzner Cloud API tokens are created in the console (fm).
8. The second operator creates his Proton account with a Proton Mail address. Emergency Access requires both parties to have one (proton-pass brief line 121). He then accepts the Family invite and the Emergency Access request.
9. Ask whether the second operator has his own masked addresses or Fastmail-only registrations (mail-cutover brief open question 5).

Later additions, each when its pass reaches it:
- Add `m.907.life` as a custom domain in the Proton Pass web app and hand over the values from the Info tab (spec:278). Verify `geoff@907.life` as the default mailbox with the code Proton sends.
- Approve the 1Password approval prompt for the single `op` read session (spec:425).
- A household phone for the photos-new client test, and for the >100 MB upload at cutover and in the end-to-end check (spec:306, spec:544). Geoff has no smartphone.
- An Apple device from household member A or B for the rehearsal's profile install (spec:243).
- Household members A, B, and C accept their Proton invites and install the extension. C exports their own 1Password vault (spec:429). A and B install their profiles at cutover (spec:257).
- In Fastmail's web UI at T+30: remove 907.life, remove the second operator's user, downgrade the plan, and create the masked-mail forward rule with SRS (spec:266-267). Fastmail exposes no Sieve or admin API (mail-cutover brief, "Fastmail JMAP session").
- A scheduled session with the second operator for the runbook criterion (spec:548).
- Recurring every 3 months: renew the Proton agent tokens through a web login with a FIDO2 touch (proton-pass brief, "Token expiry"). Add this to "Periodic work".

Fold: add each item to "What Geoff does", tagged by who acts. List the household-member asks as messages Claude drafts, as spec:488 already does for the upload pause.

### M12. The Proton import check has Claude reading Geoff's personal vaults (correctness)

Location: spec:426, spec:406.

Defect: "Claude checks the counts ... and spot-checks TOTP codes and attachments" after the import. The counts come from `pass-cli item list` on the imported vaults (proton-pass brief, "Import"), and the TOTP spot check compares live codes. The same brief sets the boundary that "Claude ... should never see a personal vault", and the spec's own Vaults section gives Claude only `Workstation`. The check as written either breaks that boundary or cannot run.

Fold: make the check a Geoff-run script launched in his own throwaway `pass-cli` session. It prints only per-vault, per-category counts, which Claude compares against the 1Password listing. Make the five TOTP checks and the two attachment opens Geoff's steps, and list them under "Export and import 1Password".

### M13. Promises with no end-to-end criterion (correctness)

Location: spec:537-548 against spec:11-17, spec:274, spec:278, spec:324, spec:345.

Defect: these promises appear in "What changes" or the body but not in "End-to-end check":
- Proton Pass replacing 1Password for five people. The fixture would be each member signed in, the counts matched, and every passkey site in the pre-cancel list re-enrolled.
- Every new masked address ending in `m.907.life`. The fixture would be an alias created at a real service, its verification mail arriving in Stalwart, and a reply through the reverse alias passing DMARC.
- Hylki replacing Thunderbird, with mail, contacts, and calendars (spec:274).
- Backups locked against deletion (see M14).
- Hetzner Backups enabled on the mail server, with a restorable image listed.
- MTA-STS at `enforce`, and TLS-RPT reports arriving at `tls-reports@`.
- The workstation wiring: `sync.sh` and `secret-set.sh` working through the agent token, and `check-drift` reporting the token's expiry.

Fold: add one line per promise to "End-to-end check", each with its fixture.

### M14. The bucket lock guarantee has no test, and restic's `config` object sits outside the rules (correctness)

Location: spec:15, spec:324.

Defect: "A compromised server can't delete or overwrite anything inside the retention window" is the reason push replaces pull, but no criterion tests it. The lock rules list `data/`, `index/`, `snapshots/`, and `keys/`. A restic repository also has a root `config` object (fm, from restic's repository layout). Deleting or overwriting it makes the repository unopenable while every locked pack survives. The spec also never states that a server's bucket-scoped object token cannot change the lock rules.

Fold: add a `config` lock rule. Add a backup-rehearsal criterion: with the server's own token, deleting a pack in `data/`, overwriting `config`, and deleting the lock rule each fail, while deleting a file in `locks/` succeeds.

### M15. Post-cutover sweeps read only Fastmail's Inbox (correctness)

Location: spec:263.

Defect: the sweeps are "date-scoped imapsync sweeps of Fastmail's Inbox". Fastmail's existing filing rules stay at Fastmail. API-managed filters are new work for a later session (Rulings, spec:41), so late mail that a Fastmail rule files into a folder is never copied. The "daily sweep ... until the masked-mail forward is live" has the same gap.

Fold: sweep every mailbox except Trash and Junk with a `SINCE` date scope. The criterion: each sweep logs the number of messages copied per folder, and "clean" in M6 reads that log.

### M16. A Hetzner image cannot restore a deleted mail server, and mail has no restic path (correctness)

Location: spec:359-362, spec:463.

Defect: for the case where "a server is gone entirely", mail's only path is "a Hetzner backup image, restored from the console". Hetzner Backups belong to their server and are deleted with it (fm; check Hetzner's Backups doc). Only snapshots outlive a server. A deleted server, through an operator mistake or an account compromise, is exactly the "gone entirely" case. Media has `restore-drill.sh --keep`, while mail has nothing from R2.

Fold: give mail the same `restore-drill.sh --keep` path from R2, with the Primary IP re-attached. Keep the Hetzner image as the first path while the server exists. The pre-go-live mail drill exercises the R2 path.

### M17. **OWNER FORK**: what happens if Hetzner refuses or stalls the port 25 request (correctness)

Location: spec:478, spec:519.

Defect: the whole mail half waits on Hetzner's answer, and a refusal "comes back to Geoff with options". That stop is not front-loaded. The ruling sets direct send and says a relay needs Geoff's ruling (spec:518). The case where Microsoft refuses both the delisting and a fresh IP ends at the same unruled stop.

Options:
- (a) Status quo: a refusal or no answer within 14 days pauses passes 5 to 7, and Claude sends an options packet.
- (b) Pre-rule a relay on 587 (SMTP2GO free tier, or SES) as the fallback only on refusal or a lasting Microsoft block, configured then and not before.
- (c) Pre-rule a move of the mail server to a provider with port 25 open (OVH is ruled out for the business, so this means another vendor).

Recommendation: (a), with a fixed 14-day follow-up date and a named fallback for the Microsoft-only case. It keeps the ruling intact and costs one stop that may never happen. Choose (b) if Geoff values the mail timeline over the "no relay" principle.

### M18. The mobileconfig profiles carry passwords, and the spec names no delivery channel (correctness)

Location: spec:257, spec:274.

Defect: each Apple user gets "one signed-in `.mobileconfig`" that carries their mail, CalDAV, and CardDAV accounts. That means a credential-bearing file, but spec:257 says only "Send each household member their setup step". Household members A and B have new, empty mailboxes, so sending the profile to the mailbox it configures can't work. Sending it to an outside address puts a password in third-party mail. The workstation rule says secrets never travel loose. Nothing checks that the profile works on iOS and on macOS, which differ.

Fold: deliver the profiles through a Proton Pass item shared with each member: a file attachment, or the password with a password-less profile. State the criterion: on one iOS and one macOS device, the profile installs, and mail, a calendar event, and a contact sync both ways.

### M19. Vacuous or fixture-less end-to-end items (correctness)

Location: spec:542-545.

Defect:
- "The media server is ready for dubplate's deploy" (spec:545) has no test. Fixture: dubplate's `deploy.sh --check` against the media host passes, or a listed contract (user, directories, Caddy site, trusted-proxy rows) is verified by `apply.sh --check`.
- "Immich serves the full library" (spec:544) has no reference count. The 2026-10-17 figures go stale as the library grows. Fixture: the counts from the pod's `/api/server/statistics` at the freeze equal the new server's, and the integrity page shows zero errors.
- "A phone upload over 100 MB succeeds" names no file or path. Fixture: a single video of at least 150 MB, uploaded from the mobile app on a network outside the house, appears with a matching checksum.
- "With DMARC at `p=reject` and clean reports" (spec:542): "clean" is undefined (see M3). "Four mailboxes send and receive" names no fixture. Fixture: each mailbox sends to and receives from the M9 test accounts.
- "No enabled Fastmail mask has received mail for 30 days" (spec:543) passes vacuously if masks are disabled wholesale. Mail to a disabled mask goes to Trash, which is the missed-service signal the mail-cutover brief describes. It also drops "no forwarded masked mail" from the exit rule at spec:290. Fixture: `MaskedEmail/get` `lastMessageAt` over the 30-day window, and every disabled mask with mail in the window is reviewed.

Fold: rewrite each line with its fixture, as above.

## Minor

### m1. **OWNER FORK**: what counts as a purchase (correctness)

Location: spec:48, spec:105, spec:442.

Defect: "every purchase" stays with Geoff, yet Claude creates servers, Primary IPs, and Hetzner Backups (spec:48), all of which bill. If Workers, D1, or Access doesn't fit the current plan (spec:105), the foundation pass stops for a purchase. Options: (a) "purchase" means a new account, subscription, or plan tier, and usage-billed resources inside the stated budget are Claude's; (b) every billable resource asks first. Recommendation: (a), plus pre-approval of Workers Paid ($5 a month) if the foundation check needs it.

### m2. **OWNER FORK**: the indefinite lock on `servers-archive`, and plaintext archives (correctness)

Location: spec:370-375.

Defect: the Vandelay archives (all household mail) and the PikaPods dump are not said to be encrypted before upload, unlike the 1Password export. "Indefinite lock" means they can never be deleted. Options: (a) an indefinite lock with every object age-encrypted; (b) a fixed lock, for example 5 years, with encryption. Recommendation: (a). Encryption is a method call that should hold either way, and the criterion is that every object in `servers-archive` starts with the age header.

### m3. Thresholds the monitor needs are unstated (correctness)

Location: spec:381-392.

Defect: the spec doesn't define a missing heartbeat (how many 15-minute intervals) or how many failed probes make media "down". The heartbeat's other failure fields (a failed unit, a reboot pending more than two days, a stale unattended-upgrade) map to no alert. The weekly `restic check` and the monthly `prune` report to nothing. Fold: add a threshold column: heartbeat missing for 45 minutes, media failing three probes, every heartbeat-reported failure on routine, and a failed check or prune on routine.

### m4. Items in "Not checked" have no named fallback (correctness)

Location: spec:550-561.

Defect: "the design changes if a check fails" makes each item a possible mid-pass stop. Fold: name each fallback now. The second operator's mailbox is too large: add a Hetzner Volume (stalwart brief section 4). The `ntfy` CLI is missing from Homebrew: the upstream binary pinned by checksum, or a `curl` stream. Hylki doesn't discover the server: manual server settings. The Apple profile fields: test on device per M18. The DMARC API: read `dmarc-reports@` over JMAP. The inbound probe: see M5.

### m5. Prune under the lock rules has no pass bar, and its fallback is not a real restic mode (correctness)

Location: spec:353.

Defect: "moves prune to a schedule that only touches objects past the window" has no restic mechanism behind it, since prune repacks by content rather than by age (fm). Fold: the rehearsal bar is that `prune` exits 0 and `restic check` is clean afterwards on a repository holding objects younger than the window. If it fails, the named fallback is no prune, with storage growth accepted, which is about $1 a month (spec:102). Record that in `decisions.md`.

### m6. The authority guards have no test (correctness)

Location: spec:436-437.

Defect: "Both refuse to delete anything except a server labeled `purpose=drill`" is a safety promise with no criterion. Fold: `check.sh` runs `provision.sh` against a stubbed `hcloud` and asserts that it refuses to delete a production-labeled server, IP, or firewall, and that `restore-drill.sh` deletes only the server ID it created.

### m7. Server sudo for `geoff` is unstated (correctness)

Location: spec:170, spec:440.

Defect: `geoff` has no password, so unattended `apply.sh` runs need passwordless sudo on the servers. The spec doesn't say so, and if sudoers asks for a password the run stops. The spec also doesn't say how `operator2` authenticates to sudo. Fold: state "`geoff` NOPASSWD, `operator2` with his console password", and add `sudo -n true` as an `apply.sh --check` probe.

### m8. Access short-lived certificates need a principal mapping (correctness)

Location: spec:185.

Defect: Access short-lived certificates use the identity's email local part as the principal (fm), and that won't be `operator2`. The GitHub login method also needs a verified email on his account. Fold: an `AuthorizedPrincipalsFile` mapping his email to `operator2`. Criterion: he opens `ssh-mail.907.life`, lands as `operator2`, and `sudo -v` works.

### m9. Retiring musicbox has no precondition list (correctness)

Location: spec:13, spec:316.

Defect: the spec never says what musicbox serves today. dubplate's history shows `music.907.life` and `inbox.907.life` behind a tunnel and an Access app on that box. Deleting it without removing those leaves dangling DNS and Access state, or cuts a live service before dubplate 0.8 deploys to the media server. Fold: the deletion packet carries a checklist: no DNS record, tunnel, or Access application resolves to musicbox, the library checksum matches, and whatever musicbox serves now has a home or Geoff accepts the gap.

### m10. The `m.907.life` promise may not hold for family members (correctness)

Location: spec:14, spec:278.

Defect: "Every new masked address ends in `m.907.life`" is a five-person promise, but a custom alias domain may belong only to the Proton account that added it (fm). Fold: check whether Family members can use Geoff's custom domain. If not, narrow the promise to Geoff's aliases, or rule how members get one.

### m11. The final Vandelay pass leaves a state gap before clients move (correctness)

Location: spec:253-256.

Defect: flags and moves made in Fastmail between the final pass and step 4 are lost, and the sweeps copy only new mail. Fold: ask the household to stop using Fastmail clients from the final pass until step 4. Or run steps 1 to 4 inside one short window and state its length.

### m12. Proton migration verification numbers dropped from the brief (correctness)

Location: spec:426, spec:430.

Defect: the brief's fixture is five TOTP items, two attachments, and per-vault per-category counts. The spec says only "spot-checks". "Once every member confirms" doesn't say what they confirm. Fold: restore the numbers, and define the confirmation as autofill working in Safari on iOS and macOS, plus the member's 10 most-used logins present.

### m13. Server-restore in place drops mail received after the snapshot (correctness)

Location: spec:357.

Defect: an in-place `server-restore` on the mail server rolls the store back to the snapshot and loses everything that arrived since. The emergency screen needs that warning. Fold: the runbook screen states the loss window, and Claude keeps a pre-restore copy of the current data directory.

### m14. Immich dump freshness isn't guarded (correctness)

Location: spec:330.

Defect: the media backup assumes the 02:00 dump exists. If Immich's dump job fails, restic keeps backing up a stale dump without complaint. Fold: the media timer fails, and posts no success, if the newest dump is older than 26 hours.

### m15. Over-ceremony: the weekly catalog link check has no owner (optional)

Location: spec:469.

Defect: "A weekly link check keeps it current" names no timer, workflow, or session, and a weekly cadence is more than a doc catalog needs. Fold: drop the weekly check, or move it into the monthly servers review (spec:508).

### m16. Over-ceremony: the mail rehearsal and the pre-go-live drills list the same drill twice (optional)

Location: spec:245, spec:366, spec:502.

Defect: the mail restore drill appears as rehearsal step 5, in Drills, and in pass 5, which leaves room to read it as two drills. Fold: in the rehearsal, say "the pre-go-live restore drill in Drills".
