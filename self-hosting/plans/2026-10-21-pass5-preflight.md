# Pass 5 (ward): pre-flight

Every step in Pass 5 that only Geoff or the second operator can take, and the conductor's own checks before launch. Five items hold launch and are done in the sitting where Geoff approves the plan. Items 6 and 7 hold the sitting days, not the launch, and item 8 is done in the plan sitting but holds nothing. The rest waits for "The sitting days" inside L6, the cutover-date packet at L8, and Pass 6's entry. `servers-mail` launches only once every item marked "holds launch" is done and every conductor check passes. The prompt names this file's path, `self-hosting/plans/2026-10-21-pass5-preflight.md`.

What needs no step from Geoff: the second operator's Fastmail credentials are already stored (workstation branch `self-hosting-fastmail-members`, 2026-10-20), the pass generates every Stalwart, restic, and tunnel secret itself, it writes ward's emergency values into `Servers emergency` through `claude-pass`, and the executor reads every rehearsal check from the API, DNS, IMAP, JMAP, or the journal. A person's word is the evidence in three places only, where Claude can't sign in or can't see the device: Geoff's for landing at Outlook.com (R1) and for Hylki's discovery (R4), and the second operator's for the device side of the Clients and Android rows (R3).

## Checked tonight (2026-10-21, read-only)

| Check | Result |
|---|---|
| `bash scripts/dry-run.sh r2-ward-rw r2-backups-ro r2-archive-rw fastmail- spamhaus test-` | the three R2 rows and Geoff's three Fastmail rows pass; `spamhaus-dqs`, `test-gmail`, and `test-outlook` read OWED |
| The second operator's credentials, decrypted from the branch's store to `/dev/shm` under a trap | IMAP login lists mailboxes; CardDAV and CalDAV answer 207; the JMAP session is his account, with mail, contacts, masked email, and submission, plus a second contacts-only account |
| Sizes and masks over JMAP, each mailbox with its own token | Geoff 5.16 GiB, 35,687 messages; the second operator 2.77 GiB, 25,227; masks 168, 1, 20 and 99, 1, 2 (enabled, disabled, deleted) |
| 907.life DNS from 1.1.1.1 | apex MX is Fastmail's two hosts at TTL 300; SPF ends `?all`; DMARC `p=none` with one `rua` (Geoff's own mailbox), so DMARC Management is off; no `_mta-sts`, TLS-RPT, `ward`, `mail`, or `probe` records yet |
| Hetzner server types | no EU location stocks a CX33 (`fsn1`, `nbg1`, `hel1` all `available: false`), and no CX type at all; L2 waits under the standing answer |
| Outbound port 25 from pavilion (about 06:40 UTC) | Fastmail's and Google's inbound MX hosts each answer `220`, so the direct SMTP sends run from pavilion |
| The free DQS page | <https://www.spamhaus.com/data-access/free-data-query-service/> says the service is "for non-commercial users only" and also offers a separate 30-day trial |
| Names in `~/.local/secrets` | every name Pass 5 reads at launch is present except the six this sitting adds (the table below) |
| The workstation permission rules | every live call is covered in its exact form except those `2026-10-21-pass5-rules.md` adds |

## Before launch

### 1. [you: ask for the Pass 5 permission rules, and type the deny lines] (holds launch)

The rules are written out in `self-hosting/plans/2026-10-21-pass5-rules.md`, in two halves. The workstation's auto mode lets a session add an allow rule only when you ask for it in that session, so the planner could not land them. It never lets a session change a deny rule, so the deny half is yours to type.

1. Tell the conductor, in your own words: "Add the Pass 5 permission rules from the pre-flight." It opens the worktree `/var/home/glw907/.dotfiles/.claude/worktrees/self-hosting-pass5-rules` and adds the allow half.
2. When it says the allow half is in, open `claude/.claude/settings.json` in that worktree with micro and add the four deny lines from the rules file's "The deny half", after the last `npx wrangler` deny rule. Save, and tell the conductor.
3. If the conductor reports that the classifier refused any part of its edit, make that part by hand the same way.
4. Merge the workstation PR it opens (branch `self-hosting-pass5-rules`) when the packet brings it.
5. If the conductor reports that `claude-tooling-sync apply` was refused after the merge, run `claude-tooling-sync apply` yourself in a terminal.

**Check (the conductor):** after the merge, `claude-tooling-sync apply` has run, `jq` finds each new rule in `~/.claude/settings.json`, and the `dontAsk` proof in the rules file passes.

### 2. [you: a Spamhaus DQS key] (holds launch)

Spamhaus answers queries from Hetzner's resolvers with an error code, so Stalwart's blocklist checks and L2's address check need a free Data Query Service key.

1. In Chromium, open <https://www.spamhaus.com/data-access/free-data-query-service/>. The free service is for non-commercial users, which a household mail server is. Choose the free service's sign-up, not the 30-day trial, whose key would lapse near cutover.
2. Register with your general recovery address (the one off 907.life), and say it is for a household mail server.
3. Confirm the address from the welcome email, sign in to the Customer Portal, and find your DQS key under the DQS product.
4. Tell the conductor you have it. It opens a dialog with `secret-receive SPAMHAUS_DQS_KEY --values /var/home/glw907/.dotfiles/.claude/worktrees/self-hosting-fastmail-members/secrets/values.age --local /run/user/1000/self-hosting/secrets-fastmail-members`; paste the key there.
5. Save the portal login in your Proton Pass.

**Check (the conductor):** `bash scripts/dry-run.sh spamhaus-dqs` passes (the test point answers `127.0.0.2`, never a `127.255.255.x` error).

### 3. [you: a Gmail test account] (holds launch)

The delivery tests send to it and read its headers over IMAP, which needs an app password, and Google issues one only to an account with 2-Step Verification.

1. In Chromium, open <https://accounts.google.com/signup> and create a personal account with a plain name, such as "Servers Test".
2. If Google asks for a phone number, use one that can take a single text: the second operator's or a household member's phone, with them beside you. Skip the recovery phone where Google lets you.
3. Open <https://myaccount.google.com/security>, choose 2-Step Verification, and add an authenticator app as the second step: choose "Can't scan it?" and type the key into GNOME Authenticator on pavilion. If Google turns 2-Step Verification on only with a phone, keep the borrowed number until step 4 is done, then remove it; the authenticator stays as the second step.
4. Open <https://myaccount.google.com/apppasswords>, name the password "servers", and create it. It shows once.
5. Tell the conductor. It opens two dialogs in turn: `TEST_GMAIL_ADDRESS` (the address) and `TEST_GMAIL_PASSWORD` (the app password, typed without spaces), each with the same `--values` and `--local` as item 2.
6. Save the account's own password and its authenticator entry in your Proton Pass.

**Check (the conductor):** `bash scripts/dry-run.sh test-gmail` passes.

### 4. [you: an Outlook.com test account] (holds launch)

Microsoft is the receiver with a record of refusing Hetzner ranges, so the design tests it. Outlook.com no longer takes IMAP with a password (Microsoft support, "Outlook and other apps are unable to connect to Outlook.com when using Basic authentication"), so Claude stores only the address, and you read and send there in the web app during the sitting days.

1. In Chromium, open <https://signup.live.com>, choose to get a new email address, and create an `@outlook.com` address. Solve the puzzle. If it asks for a phone, use the same borrowed phone as item 3.
2. Sign in once at <https://outlook.live.com> and leave the session signed in.
3. Tell the conductor. It opens one dialog, `TEST_OUTLOOK_ADDRESS`, with the same flags as item 2.
4. Save the password in your Proton Pass.

**Check (the conductor):** the name is in the overlay by name; the `test-outlook` row reads OWED until L1 changes it to need the address alone.

### 5. [you: merge the credentials PR] (holds launch)

The conductor commits items 2 to 4 onto the workstation branch that already holds the second operator's two Fastmail credentials (`self-hosting-fastmail-members`), test-merges `origin/main` into it, opens it as one PR, and brings it to you. Merging it in this sitting keeps Pass 5's own workstation branch free of a `values.age` conflict, since it then starts from a `main` that has every name.

1. Merge it when the packet brings it.

**Check (the conductor):** after the merge it pulls the workstation checkout, runs `/var/home/glw907/.dotfiles/scripts/secrets/sync.sh --local`, removes the overlay, and finds `FASTMAIL_OPERATOR2_API_TOKEN`, `FASTMAIL_OPERATOR2_PASSWORD`, `SPAMHAUS_DQS_KEY`, `TEST_GMAIL_ADDRESS`, `TEST_GMAIL_PASSWORD`, and `TEST_OUTLOOK_ADDRESS` in `~/.local/secrets` by name; `git -C /var/home/glw907/.dotfiles diff --quiet -- secrets/values.age` is clean.

### 6. [you: find the protection switch and the Rebuild tab] (holds the sitting days)

The rehearsal's image-restore row (L6) is your console work: protection off, restore last night's backup image in place, protection back on. This dry run on orpheus makes sure you can find the controls before R2 needs them, and gives the runbook's emergency screen its real labels. Orpheus has no backups, so the restore control on a backup isn't there to find; you read that label in R2.

1. Sign in at <https://console.hetzner.cloud>, open the `servers` project, and open orpheus.
2. Find where its delete and rebuild protection show and switch. Don't press.
3. Find the Rebuild tab and its image list. Don't press.
4. Tell the conductor the exact label of each control and where it sits.

**Check (the conductor):** STATUS records the protection and Rebuild labels, and the executor prompt's L6 runbook step takes them.

### 7. [second operator: name his mail apps] (holds the sitting days)

The rehearsal's Clients and Android rows test the apps he will use, and his steps are written for them.

1. Ask him which app he uses for mail, contacts, and calendars on Android, and which on Linux.
2. Ask him to keep about 30 minutes free for one session with his phone and his Linux machine once ward is up. The conductor books the time when the executor reaches the sitting days.

**Check (the conductor):** STATUS records the app names and that the session is agreed in principle (by role, never by name).

### 8. [you: count A's and B's masks, then revoke A's two Migration entries] (done in the plan sitting, holds nothing)

Household member A's app password and API token were made on 2026-10-20, stored, then deleted from the branch when the mail scope changed. The entries still work at Fastmail. Before they go, read how many masks A and B hold, since their 907.life addresses stop at cutover and their Fastmail users go at T+30.

1. Open household member A's Fastmail settings the way you did on 2026-10-20 when you made the entries.
2. Open the Masked Email list and read the count of enabled masks.
3. Do the same for household member B.
4. Back in A's settings, under Privacy & Security, open the list of app passwords and API tokens, and revoke both entries named "Migration".
5. Tell the conductor the two counts.

**Check:** you see no "Migration" entry left in that list. The conductor records the two counts in STATUS, by role, for L8's drafted message and C5's packet. Claude has no check on the revocation, because the values were deleted.

### The conductor's own pre-launch checks (not Geoff)

Each identity, policy, and store the pass leans on is dry-run here, so no rehearsal row fails on a sign-in or a missing name. `scripts/dry-run.sh` isn't executable until L1, so these runs keep `bash scripts/dry-run.sh`, which is read-only; a refusal here is the conductor's to run by hand.

- Pass 3's cutover PR (servers, branch `pass3-photos`) has merged, and its body records the stale-snapshot probe done with ward's D1 rows and `kv` keys deleted, or escalated before it wrote any row. No D1 call: the PR body and I1's acceptance are the evidence.
- The plan PR has merged and `/var/home/glw907/Projects/initiatives` is pulled; `test -f` passes on the plan, this file, the rules file, and `self-hosting/plans/2026-10-21-pass5-prompt.txt`.
- The `pass-core` "Execute" checks on `/var/home/glw907/Projects/servers`: fetched, on `main`, `git rev-list --count HEAD..origin/main` prints 0, `.claude/worktrees/` ignored.
- No other session works ward or the servers worktree `mail`: `claude agents --json` lists no `servers-mail` and no other executor whose prompt names ward. Pass 3's week phase (`servers-photos`) may run alongside.
- `git -C /var/home/glw907/.dotfiles diff --quiet -- secrets/values.age` is clean, and the workstation checkout is on `main` with `HEAD..origin/main` at 0.
- `bash scripts/dry-run.sh hcloud cf-ws-servers r2-ward-rw r2-backups-ro fastmail- spamhaus test-gmail` passes every row, and `TEST_OUTLOOK_ADDRESS` is present by name. `r2-archive-rw` stays out: each run leaves an object the Indefinite lock won't let it delete, and L5's round trip proves the same scope.
- pavilion still reaches port 25 outside, as on 2026-10-21: `curl --max-time 15 -v smtp://in1-smtp.messagingengine.com:25` and `curl --max-time 15 -v smtp://gmail-smtp-in.l.google.com:25` each show a `220` greeting.
- The rules proof from item 1 passed after the last `claude-tooling-sync apply`.
- `systemctl --user is-active monitor-subscribe.service` prints `active`, and `/alerts` lists no open ward condition.
- `servers-backup-ward` holds no lock rules (`bash cloudflare/r2.sh --check` passes with ward disabled in `cloudflare/r2.json`).
- CX33 stock, read from the server-types API, goes into STATUS with the time; none is fine, since L2 waits under the standing answer.
- The `pavilion-scripts` and `pavilion-claude` agent tokens expire about 2027-01-19 and 2027-01-20, past Pass 6's T+30, so the token-expiry answer doesn't fire.
- pavilion has at least 30 GB free under `/var/home` for the Vandelay archives and `archive.sh`'s disk work directory (333 GB on 2026-10-21).

## Secrets the pass needs

Checked on 2026-10-21 against `~/.local/secrets`, by name only.

| Name | Task | State |
|---|---|---|
| `HCLOUD_TOKEN_SERVERS` | L2, L7 (the drill) | present |
| `CF_WS_SERVERS_TOKEN` | L3 (`access.sh`), L4 (`dns.sh`), L7 (`deploy.sh monitor`) | present |
| `CF_WARD_R2_BACKUP_RW_TOKEN`, `_KEY_ID`, `_SECRET` | L3 (rendered to ward; L8's `restic stats` runs on ward with it) | present |
| `CF_WS_R2_BACKUPS_RO_*` | L7 (the drill) | present |
| `CF_WS_R2_ARCHIVE_RW_*` | L5 (`archive.sh`), C1, C5 | present |
| `HEARTBEAT_TOKEN_WARD` | L3 (rendered to ward) | present |
| `MONITOR_READ_TOKEN` | L7 (reading `/alerts`) | present |
| `FASTMAIL_API_TOKEN`, `FASTMAIL_DAV_PASSWORD` | L1, L5, L6 | present |
| `FASTMAIL_OPERATOR2_API_TOKEN`, `FASTMAIL_OPERATOR2_PASSWORD` | L1, L5, L6 | on branch `self-hosting-fastmail-members`; item 5 |
| `SPAMHAUS_DQS_KEY` | L2, L3 (a `File` secret on ward) | item 2 |
| `TEST_GMAIL_ADDRESS`, `TEST_GMAIL_PASSWORD` | L6 | item 3 |
| `TEST_OUTLOOK_ADDRESS` | L6 | item 4 |

The pass creates `RESTIC_PASSWORD_WARD`, `TUNNEL_TOKEN_WARD`, `STALWART_ADMIN_PASSWORD`, `STALWART_PASSWORD_GEOFF`, `STALWART_PASSWORD_OPERATOR2`, `STALWART_PASSWORD_TEST`, and `STALWART_PASSWORD_TEST2` in its own workstation worktree. The second operator's two Fastmail credentials can write and send, beyond the design's read-only ask; Geoff kept them for the masked-address work. Pass 5 uses them read-only, and its one Fastmail write, the rehearsal's reverse sync, goes into a scratch folder in Geoff's account alone.

## The sitting days

**When:** after L6's server-side rows pass and the morning after ward's first Hetzner backup, once the executor writes `## Stop: the sitting days` in its servers PR body. The conductor books item 7's session then. **Who:** Geoff for R0, R1, R2, and R4, the second operator for R3, each at their own time inside the sitting days. The executor messages `conductor-servers` before each step, and the conductor relays it and sends back the word that it is done. R2 comes first on its day, before any test send that day, and never between 03:20 and 04:00 UTC.

No rehearsal message goes to either 907.life mailbox. Apex MX still points at Fastmail, so it would land in the real Fastmail mailbox; those sends wait for C3, after the switch.

### R0. [you: two Access sign-ins] (L3's acceptance)

1. In Chromium, open <https://ssh-ward.907.life> and sign in through Access as you do for orpheus. Wait for the terminal prompt, then close the tab.
2. Open the Stalwart admin page link the conductor gives you, sign in through Access, and wait for Stalwart's sign-in page. Don't sign in to Stalwart.
3. Tell the conductor the time of each.

**Check (the executor):** ward's journal shows the SSH login through the tunnel, and Stalwart's log shows the admin page's request, each at the time you gave.

### R1. [you: Outlook.com] (L6, the Sending and Receiving rows)

1. In the Outlook.com test account, send one message to the test account's `probe.907.life` address, which the conductor gives you, with the subject it gives you.
2. For each message ward sent to the Outlook.com account, say where it is: in the Inbox, in Junk, or not there after 15 minutes from the conductor's send time. For one that arrived, say how long it took.
3. Open each one that arrived, choose the "..." menu, then View, then View message details, and copy the `Authentication-Results` line into your reply.

**Check (the executor):** your message is in the test account, found by subject token, with `spf=pass` and `dkim=pass` for outlook.com. Landing and the authentication results at Outlook.com rest on your report, as the design allows where Claude can't sign in. "Not there after 15 minutes" fails the Sending row, since Microsoft's documented failure is a silent drop.

### R2. [you: the image restore] (L6, the Image restore row)

1. When the conductor says the image is ready, open ward in the Hetzner console and turn its protection off, with the controls you found in item 6.
2. Open ward's Backups tab, and tell the conductor the exact label of the restore control beside last night's backup, for the runbook.
3. Restore the backup image the conductor names onto ward in place. Wait until the console shows the server running, then tell the conductor.
4. When the conductor says Stalwart is up, turn protection back on.

**Check (the executor):** `/healthz/live` answers, a JMAP login works for the test account, `scripts/apply.sh ward --check` is clean (or `--apply` clears the drift it shows), and the API reads `delete` and `rebuild` protection both true. If the console reports an error at step 3, stop there and tell the conductor; the runbook's screen says the same.

### R3. [second operator: his apps] (L6, the Clients and Android rows)

1. In the booked session, add the test account to the Android and Linux apps he named, following the steps the executor wrote, with the password the conductor gives him for the test account only.
2. Read the test messages, then send one message, add one contact, and add one event from each app.
3. Say whether the message, contact, and event the executor added show in each app.
4. Remove the test account from both apps.

**Check (the executor):** the sent message, the contact, and the event appear in the test account over JMAP. Whether the executor's items show in his apps rests on his report, which is the evidence for the device side of the two rows.

### R4. [you: Hylki] (L6, the Clients row)

1. In Hylki on pavilion, add an account with the test account's address and the password the conductor gives you, and let Hylki discover the server.
2. Tell the conductor whether discovery found Stalwart for mail, contacts, and calendars, and what it showed if it didn't.
3. Read the test messages, and leave the account in place until the executor says the row has passed. Then remove it.

**Check (the executor):** Stalwart's log shows Hylki's logins for the test account at that time, and JMAP shows the test account unchanged by the read. Discovery rests on your report; if it failed, the executor writes the manual settings into the steps (the standing answer) and you add the account with them.

## Later, outside the sitting days

- **L8:** the cutover-date packet, with the drafted message to household members A and B (their 907.life addresses stop at cutover, their Fastmail mailboxes go unarchived at T+30, any masks you counted in item 8 stop with them, and any outside login or recovery address on their 907.life address should move before cutover). Geoff confirms the date and sends the message himself.
- **Pass 6's entry:** the second operator signs in to Proton Pass and `Servers emergency` is shared with him, which carries his Stalwart password from L7; his address is in the monitor's `alert_to` and a routine test alert reached it; Geoff has sent the L8 message.

## Owed, outside this pass

- The second operator's GitHub identity, Unix account, patterns lines, Hetzner invite, and first sign-in on `ssh-orpheus.907.life`; his address in the monitor's `alert_to`, which is now Pass 6's entry.
- The Immich admin login in `Servers emergency` (Geoff, carried from Pass 2).
- servers BACKLOG #1 (`promote.sh` sets no hostname) matters only for a production rebuild; the image restore in R2 is a console rebuild that keeps the hostname, and the drill never promotes.
