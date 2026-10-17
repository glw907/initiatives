# Self-hosting design

## Brief

Approving this design starts a plan that moves 907.life mail, photos, music, and passwords onto two Hetzner servers and Proton Pass, with backups in Cloudflare R2. The work runs unattended except for a short list of things only you can do.

Fastmail, PikaPods, and 1Password each hold household data on someone else's terms. The 165 masked addresses on fastmail.com also make leaving Fastmail slower every month. The research is done, and you answered every open question on 2026-10-17, so the plan can be written to run with few stops.

### What changes

- Mail for 907.life moves to Stalwart on a small Hetzner server in Germany, sending directly on port 25. Four mailboxes: yours, the second operator's, and two household members'.
- Immich moves from PikaPods to a second Hetzner server in Germany. photos.907.life keeps its name, and uploads over 100 MB start working.
- The same media server is ready for dubplate when dubplate's own build ships. musicbox retires.
- Proton Pass Family replaces 1Password for five people. Every new masked address ends in `m.907.life`.
- Every server backs up nightly to R2, locked against deletion. The mail server also gets Hetzner's daily images.
- A Cloudflare Worker watches every service. It alerts your desktops, and the second operator's phone, through ntfy.
- The second operator gets a browser terminal through Cloudflare Access, signed in with GitHub, and a runbook of copy-paste steps.

### If you approve

1. The session writes the pass plan and sends it to you as a packet.
2. You do the first-week actions in "What Geoff does". The port 25 request comes first, because mail waits on Hetzner's answer.
3. The plan builds the repo, the monitor, and the media server, then moves Immich.
4. The plan moves passwords to Proton Pass. You and the household move your own vaults with the steps the plan writes.
5. The plan builds the mail server and rehearses the migration. When the rehearsal passes, Claude proposes a cutover date and you confirm it.
6. Claude runs the cutover while you stay on call. The masked-address triage follows, at your pace.
7. Each irreversible step comes to you as its own packet: deleting musicbox, the PikaPods pod, and the Fastmail account.

### Worth knowing

This design reverses one earlier ruling. The 2026-10-17 brainstorm ruled out any off-site backup copy. Later that day you chose R2 for every backup and named Cloudflare core infrastructure, which settles it the other way.

### The rulings behind this design

Every ruling is listed with its date in "Rulings". The ones made after the pavilion handoff: OVH is out for business stability, both servers go to Hetzner in the EU, mail sends directly on port 25, backups go to R2 only, and the second operator gets full sudo and a browser terminal.

## Rulings

Geoff made these rulings in the brainstorm on pavilion and in the thinkpad-x1 session, all on 2026-10-17. The handoff file, [2026-10-17-brainstorm-decisions.md](2026-10-17-brainstorm-decisions.md), has the brainstorm's full list. This list adds the later rulings and replaces the handoff where the two disagree.

- **Scope.** Mail moves from Fastmail to Stalwart, Immich from PikaPods, dubplate to the new media server, and passwords from 1Password to Proton Pass. Hylki replaces Thunderbird. API-managed mail filters come in a later session. The order of the work doesn't matter much.
- **Hosting.** OVHcloud is ruled out because its business isn't steady enough. Both servers run on Hetzner Cloud in the EU. Geoff accepts the measured latency, about 200 ms from Anchorage. A monthly check watches Hetzner's US prices, and the servers move to the US when the trigger holds (see "Periodic work").
- **Cut line.** The keep and cut lists in the handoff stand as approved.
- **Mail delivery.** Stalwart sends directly on port 25, with no external relay. Geoff files Hetzner's port 25 limit request.
- **Backups.** Every restic backup goes to Cloudflare R2, with no USB drive. The mail server also gets Hetzner Backups. dubplate's separate R2 backup retires into the restic path. Cloudflare is core infrastructure, and any of its services may be used wherever it makes the initiative simpler.
- **Second operator.** Full sudo on both servers. Emergency access is a Cloudflare Access browser terminal, signed in with his GitHub account.
- **Alerts.** Urgent alerts reach both workstations as desktop notifications and the second operator's Android phone. Geoff has no smartphone.
- **Claude's authority on Hetzner.** Claude may create, rebuild, snapshot, and set rDNS and firewalls on resources labeled for this initiative. It may delete only drill servers it created. Deleting a production server or IP stays with Geoff.
- **Cutover.** Claude runs the mail cutover with Geoff on call. Geoff confirms the date.
- **Smaller calls**, on Claude's defaults:
  - Fastmail's Trash and Junk folders stay behind.
  - The alias subdomain is `m.907.life`.
  - All five Immich users stay.
  - photos.907.life goes DNS-only on a public IP.
  - `sudo -A` reads a pasted password from a dialog.
  - SSH stays open to the internet with keys only.
  - The Proton Pass desktop app is skipped.
  - No Proton Pass trial runs before 1Password is cancelled.

## Who uses what

The repo is public, so household members appear by role. The real names live only in chat with Geoff and in the session's private memory.

| Role | Stalwart mailbox | Proton Pass | Devices |
|---|---|---|---|
| Geoff | yes, migrated | owner | Linux workstations, no smartphone |
| Second operator | yes, migrated | member | Linux, Android |
| Household member A | yes, new | member | macOS, iOS |
| Household member B | yes, new | member | macOS, iOS |
| Household member C | no | member | macOS, iOS |

Three of the five Proton Pass users are on Apple devices, so the Safari, macOS, and iOS setup gets written out step by step. Nothing in the design assumes a phone of Geoff's. That covers alerts, logins, and second factors.

## Architecture

Two Debian 13 servers in Hetzner's Falkenstein location (`fsn1`) carry the services. Cloudflare carries DNS, backups, monitoring, and the second operator's access. The workstations carry Claude, the repo, and the Proton Pass command line.

| Piece | Where | Runs |
|---|---|---|
| Mail server | Hetzner CX23 (2 vCPU, 4 GB, 40 GB), fsn1 | Stalwart in Docker on host networking, `cloudflared`, the health timer, the backup timer |
| Media server | Hetzner CX33 (4 vCPU, 8 GB, 80 GB), fsn1 | Immich in Docker Compose, Caddy, the dubplate host side, `cloudflared`, the health and backup timers |
| Backups | R2 buckets `servers-backup-mail`, `servers-backup-media`, `servers-archive` | restic repositories with bucket locks; cold archives |
| Monitor | Worker `servers-monitor` with a D1 database | cron probes, heartbeat intake, ntfy alerts, the daily inbound mail probe |
| MTA-STS | Worker on `mta-sts.907.life` | the static policy file |
| Operator access | Cloudflare Tunnel and Access | the browser terminal and admin pages, with GitHub sign-in |
| Workstations | thinkpad-x1, pavilion | the `servers` repo, `hcloud`, `wrangler`, `pass-cli`, the ntfy subscriber |

### Locations and types

Both servers go in fsn1, the closest EU site at a measured 193 ms minimum round trip. The fallbacks are nbg1 and then hel1. Hetzner's cost-optimized stock moves within hours, so `provision.sh` reads live availability and stops with a clear message instead of guessing. The media server is x86 rather than Arm, so dubplate's existing amd64 binary runs unchanged.

### IPs

Each server gets a Hetzner Primary IPv4 and IPv6. They are created before the server with auto-delete off and delete protection on, so a rebuild keeps the PTR records and the mail IP's reputation. Before the mail IP is attached, Claude checks it against Spamhaus, MXToolbox, and multirbl, and allocates a new one if it is listed.

### Cost

The servers and R2 come to about $20 a month. Proton Pass Family adds $59.88 a year:

- Mail server: $6.49, plus $0.60 for IPv4 and $1.30 for Hetzner Backups.
- Media server: $9.99, plus $0.60 for IPv4.
- R2: about $1.
- Proton Pass Family: $59.88 a year, about $5 a month.

Workers, D1, and Access for two people are expected to fit the account's current plan, and the foundation pass confirms it. These are 2026-10-17 prices, and the runbook links Hetzner's price page rather than copying the numbers.

## The servers repo

A new private repo, `glw907/servers`, holds provisioning, configuration, the runbook, and the Worker. It is added to `initiative.yaml` when it is created. The tree follows the server baseline brief's section 5, with these changes: no Hetzner volume, no USB backup, a `cloudflare/` directory, and push backups.

```
servers/
  README.md
  EMERGENCY.md              the runbook's emergency part, rendered at the root
  docs/
    runbook.md              emergency, operator, catalog, Claude infrastructure
    decisions.md            the rulings log
    restore-drill-log.md
  infra/
    project.env             names, types, locations, labels (no secrets)
    provision.sh            hcloud: primary IPs, firewalls, servers, rDNS; --check/--apply
    firewall-mail.json  firewall-media.json
  base/
    cloud-init.yaml         users, keys, sshd drop-in, hostname, nothing else
    keys/                   public keys only
    install.sh              apt packages, unattended-upgrades, chrony, journald, sudoers, Docker CE
  roles/
    stalwart/  immich/  caddy/  dubplate-host/  cloudflared/  backup/  health/
  hosts/
    mail/  media/           host.env and roles.txt
  secrets/
    templates/              bare NAME= rows, as dubplate does
    render.sh               fills from ~/.local/secrets, ships over ssh stdin
  cloudflare/
    monitor/                the Worker, its D1 schema, wrangler.jsonc
    mta-sts/                the policy Worker
    dns.sh                  publishes and checks the zone records Claude owns
    r2.sh                   buckets, lock rules, scoped tokens
  scripts/
    apply.sh                apply.sh HOST [--check|--apply]
    restore-drill.sh        builds a throwaway server, restores, verifies, destroys it
    check.sh                the repo gate
  .github/workflows/check.yml
```

Rebuild is the path that converges the OS, and `apply.sh` converges configuration. Cloud-init stays small and rarely changes. A host is reproduced from the repo and the R2 backups alone.

Secrets follow dubplate's pattern. Templates hold bare `NAME=` rows, and `render.sh` resolves them from `~/.local/secrets`, then streams the result over SSH to a root-owned 0600 file. Every new long-lived secret starts in the workstation age store through `secret-set.sh` and is listed in `secrets/registry.md`.

The gate (`scripts/check.sh`, run by CI too):

- `shellcheck`, `shfmt -d`, `yamllint`, and `jq empty`.
- `cloud-init schema` on each rendered file.
- In a `debian:13` container: `sshd -t`, `visudo -cf`, `apt-get -s install` for every package list, `docker compose config`, and `systemd-analyze verify`.
- `gitleaks`, and Vale on `docs/`.
- The Worker's own type check and tests.

CI is linting and these container checks only, per the cut line.

## Base host

Both servers share one base, from the server baseline brief:

- **OS:** Debian 13 from Hetzner's `debian-13` image.
- **Patching:** `unattended-upgrades` with an automatic reboot at 12:00 UTC when one is required, and `needrestart` in automatic mode.
- **Time and logs:** `chrony`, and persistent journald capped at 500 MB and one month.
- **Firewall:** the Hetzner Cloud Firewall is the one enforced firewall. Every Docker port binds to loopback unless a service needs the public interface.
- **SSH:** keys only. Root login is off, `PermitRootLogin no` lands after cloud-init creates the users, and there is no fail2ban.

Two users have shell access. `geoff` holds Geoff's key and the workstation key Claude uses. `operator2` belongs to the second operator. Both have full sudo, by Geoff's ruling. `operator2` signs in through the browser terminal and has no long-lived key. It has a password for the Hetzner web console only, since sshd refuses passwords.

Docker CE comes from Docker's own Debian repository on both servers, with its origin added to unattended-upgrades. Log rotation is set in `daemon.json` before the first container starts.

### Inbound ports

The mail server opens 22, 25, 80, 443, 465, 993, and ICMP. Port 587 stays closed unless a client needs STARTTLS. The media server opens 22, 80, 443, and ICMP.

## Access

Geoff and Claude reach the servers with SSH keys. The second operator reaches them through Cloudflare:

1. `cloudflared` on each server holds an outbound-only tunnel.
2. Access publishes a browser-rendered SSH terminal at `ssh-mail.907.life` and `ssh-media.907.life`.
3. An Access policy admits only the second operator's GitHub identity and Geoff's.
4. The terminal signs `operator2` in with Access short-lived certificates, so no key lives on his machine.

He can open it from his Linux machine or his phone.

Admin pages sit behind the same Access login: Stalwart's web admin on the mail server, and Immich's admin pages through the tunnel. Stalwart's `/admin` also stays loopback-only on the public listener, and the admin account is limited to loopback, as the Stalwart brief recommends.

If Cloudflare is down, Geoff and Claude still reach both servers over SSH. The second operator also becomes a member of the Hetzner Cloud project. That gives him the web console and the mail server's backup images when nothing else answers.

## Mail

### Stalwart

Stalwart runs at a pinned version, the newest 0.16.x at build time. If 1.0 has shipped by cutover, it runs 1.0.1 or later. The official image runs in Docker on host networking, so auto-ban and the logs see real client addresses. Logging goes to the console so `docker logs` and journald carry it. That avoids the image's unwritable default log file.

Configuration is a `config.json` plus an NDJSON plan applied with `stalwart-cli apply` against a loopback listener. All four stores are RocksDB on the local disk. Before any import, the plan sets auto-ban ban periods and adds `dmarc-reports@` and `tls-reports@` to the report addresses. It also pins `exim4`, `postfix`, and `sendmail` to priority -1 in apt, because a Debian MTA package stops Stalwart for good through the unit's `Conflicts=`. Claude reads the spam-filter rule updates and applies them on purpose, never automatically.

### Size

Geoff's mailbox measured 5.14 GiB across 35,576 messages (read-only JMAP, 2026-10-17). The second operator's mailbox is still unmeasured. Four mailboxes fit the 40 GB disk with room for the warm backup copy. The health timer alerts at 80% full.

### Delivery

Outbound mail goes directly on port 25, over IPv4 only. Stalwart's IP strategy is `ipv4_only`, so a missing or wrong IPv6 PTR can't cost delivery. PTR records match `mail.907.life` on both addresses. Inbound works on IPv4 and IPv6 from day one. Before cutover, a test send goes to Gmail, Outlook.com, Yahoo, and mail-tester. Each must show SPF, DKIM, and DMARC passing on 907.life with TLS.

If Microsoft refuses the IP, Claude follows Hetzner's documented delisting flow. If delisting fails, Claude moves the server to a fresh Primary IP. A relay appears in the runbook only as a last-resort note. Nothing configures one.

### DNS

Claude is the only writer to the 907.life zone, through `cloudflare/dns.sh` with a scoped token. Stalwart's generated `dnsZoneFile` is the source for the mail records:

- `mail.907.life` A and AAAA, DNS-only, matching PTR and the EHLO name.
- One MX, `10 mail.907.life`, set at cutover and never mixed with Fastmail's.
- SPF, before cutover: Fastmail's include plus the server's IPv4 and `~all`. After the rollback window: the server alone and `-all`. The existing `cf-bounce` records stay untouched.
- A new DKIM selector (RSA 2048, plus Ed25519 if Stalwart signs with both), published days before cutover. DKIM rotation is manual and yearly. The `fm1` to `fm3` CNAMEs stay until Fastmail closes.
- DMARC at `p=none` through cutover. Aggregate reports go to Cloudflare DMARC Management and to `dmarc-reports@907.life`, so Stalwart keeps a copy if the dashboard's reports can't be read through the API. After 30 clean days it moves to `p=quarantine`, then to `p=reject` once the reports show only Stalwart passing. The ramp uses RFC 9989's `t=y` test flag.
- TLS-RPT to `tls-reports@907.life`.
- MTA-STS, served by the `mta-sts` Worker. It starts in `testing` with a one-day max age while both MX hosts are listed, and moves to `enforce` after Fastmail's MX is gone.
- Client discovery SRV records, plus Cloudflare redirect rules that send the apex's `/.well-known/caldav`, `carddav`, and `jmap` paths to the mail server.
- No DNSSEC and no DANE, per the cut line.

### Migration

Vandelay copies each Fastmail account into a SQLite archive, then into Stalwart:

- Mail and contacts go over JMAP, using `--account-id` rather than `--account-name`.
- Calendars go over CalDAV with the DAV app password.
- Fastmail's Trash and Junk stay behind. The rehearsal settles whether Vandelay can skip them, or whether they're emptied in Stalwart right after the import.
- The two new mailboxes start empty.
- Every 907.life address Fastmail accepts gets created in Stalwart before the MX switch.

The Vandelay archives go to `servers-archive` in R2 as the cold copy, in place of Fastmail's one-folder-at-a-time ZIP export.

### Rehearsal

The rehearsal runs on the real mail server while MX still points at Fastmail:

1. Import full copies of both mailboxes, their contacts, and their calendars.
2. Compare each mailbox's total and unread counts over JMAP, the `$flagged` and `$answered` counts, `receivedAt` on a sample of old messages, and a sample of bodies.
3. Connect Hylki and poplar, and install the Apple configuration profiles on one Apple device.
4. Send the authentication tests above, and deliver test mail inbound over a direct SMTP connection.
5. Run a restore drill from R2.

Claude repeats the rehearsal until it is clean, then proposes a cutover date. Geoff confirms the date. That confirmation is the one planned stop before cutover.

### Cutover

Claude runs cutover day, with Geoff on call:

1. Run a final Vandelay pass.
2. Switch MX to `mail.907.life` through the API.
3. Run the inbound probe from outside, and a send from inside Fastmail, which catches Fastmail delivering locally to a domain it hosts.
4. Point Hylki and poplar at Stalwart.
5. Send each household member their setup step: a configuration profile for each Apple user, and a short guide for the second operator's Android client.

A failed check pushes an urgent alert to Geoff. Rollback is a reverse MX switch, and the TTL is already 300 seconds. Mail that reached Stalwart in the meantime is copied back to Fastmail with a reverse imapsync.

### After cutover

- **T+1, T+3, and T+7:** date-scoped imapsync sweeps of Fastmail's Inbox. A daily sweep then continues until the masked-mail forward is live.
- **T+30, if clean:**
  - Drop Fastmail's SPF include and move SPF to `-all`.
  - Remove 907.life from Fastmail, then set the masked-mail forward to Stalwart.
  - Remove the second operator's Fastmail user and downgrade to Individual.
  - Move MTA-STS to `enforce` and DMARC to `p=quarantine`.
- **Later:** DMARC moves to `p=reject` after clean reports.
- **When triage ends:** Fastmail closes on the exit rule in "Masked email", and the `fm*` CNAMEs go with it.

### Clients

On the workstations, Hylki replaces Thunderbird. Thunderbird retires only after Hylki reads mail, contacts, and calendars from Stalwart. poplar's account moves to Stalwart's JMAP endpoint. The Apple users get one signed-in `.mobileconfig` each, carrying the mail, CalDAV, and CardDAV accounts. Claude writes these profiles. Stalwart doesn't generate them.

## Masked email

Proton Pass custom domain `m.907.life` holds every new masked address. It gets its own MX, verification, SPF, DKIM, and DMARC records, with the values copied from the Pass Info tab. Its default mailbox is `geoff@907.life`. Delivery follows 907.life's MX, so the mailbox works before and after cutover with no change. Aliases are disabled during triage, never deleted, because Proton cannot recover a deleted alias. A yearly export of the alias list goes to `servers-archive`.

### Triage

The 165 @fastmail.com masked addresses move one service at a time:

1. Claude snapshots every masked address over JMAP into an age-encrypted file outside git.
2. Claude adds message counts and sender domains for the last year, and joins the list against the Proton Pass logins after the import.
3. Each address gets a tier: critical (banks, government, health, utilities, domain and hosting, account recovery), active, dormant, or never used.
4. Geoff works the list at his own pace: create the alias inline in the service's form, change the address at the service, confirm the verification mail arrives, then disable the Fastmail mask. No bulk path exists, so this is the one long stretch of human work in the initiative. Critical services go first, and can start before cutover.
5. Claude recounts from the API each week and reports what is left.

Fastmail closes when no enabled mask and no forwarded masked mail has appeared for 30 days. The research budgets about three months of Fastmail in total.

## Photos

Immich runs the official Docker Compose files on the media server, pinned to an exact v3 tag, with Caddy in front on 80 and 443. Ports bind to loopback, and `IMMICH_TRUSTED_PROXIES` names Caddy. ML is capped at 3 GB and 2 CPUs, and job concurrency is 1. A 2 GB swap file goes in. Caddy comes from Caddy's own apt repository.

### Migration

Immich's own dump plus `UPLOAD_LOCATION`:

1. Geoff enables SFTP on the PikaPods pod and hands the credentials over with `secret-receive`.
2. Claude downloads the newest dump through `GET /admin/database-backups/{filename}` with the stored API key, and copies `library`, `upload`, `profile`, `backups`, `thumbs`, and `encoded-video` over SFTP.
3. On the media server, under the temporary DNS-only name `photos-new.907.life`, Claude restores at the pod's exact version. It tries the stock Postgres 14 image first and a `16-vectorchord` tag if the load fails.
4. Claude verifies against the live counts: 3,724 photos, 92 videos, 155 people, 1 album, 3 shared links, and 5 users. It also checks the integrity page, the existing API key, and SMTP (Fastmail on 587 until mail moves).
5. Cutover: Geoff asks the household to pause uploads for a short window. Claude takes a final dump, stops the pod, copies the delta, restores again, and switches photos.907.life from the proxied CNAME to DNS-only A and AAAA records.
6. Claude confirms the certificate and a large upload, then upgrades to the current v3 patch.
7. The pod stays stopped for a week. Deleting it is an irreversible step that comes to Geoff.

After mail moves, Immich sends through Stalwart on port 587.

## Music

The media server carries dubplate's host side: the `music` user, `/srv/music/library`, `/srv/music/staging`, `/var/lib/dubplate`, and a Caddy site for `music.907.life` with dubplate's trusted-proxy rows. dubplate itself deploys with its own `deploy.sh` once its 0.8 release is ready. That build belongs to the dubplate-server initiative. dubplate keeps its systemd unit, which makes it the one service not in a container. This design changes only dubplate's deploy target.

### Retiring musicbox

Claude copies musicbox's `/srv/music/library` (6.6 GB) and `/var/lib/dubplate` into the media restic repository, and verifies the copy against checksums. It also reads what the existing `music-library` R2 bucket holds. Deleting musicbox's server, volume, firewall, and IPs, and the `music-library` bucket, then comes to Geoff as an irreversible step.

## Backups

Each server backs itself up to its own R2 bucket with restic. Each server holds an R2 token scoped to its one bucket, plus its own restic password, both in root-only files.

### Lock rules

Bucket lock rules cover the `data/`, `index/`, `snapshots/`, and `keys/` prefixes with a 30-day retention. The `locks/` prefix stays outside the rules, because restic deletes its lock files on every run. A compromised server can't delete or overwrite anything inside the retention window.

This replaces the pavilion pull. With R2 as the destination, the pull's reason disappears: servers holding no write credential. Bucket locks cover that risk instead. Backups also no longer stop while pavilion is off.

### Media, at 03:00

Immich writes its own database dump at 02:00. The media timer then runs `restic backup` over:

- Immich's `library`, `upload`, `profile`, and `backups` directories.
- `/srv/music`.
- dubplate's state.

Thumbnails and transcodes are skipped, because jobs regenerate them. dubplate's state is copied while dubplate is stopped for a few seconds, until dubplate offers a local snapshot command. That request goes to dubplate's backlog.

### Mail, at 03:30

1. rsync the live data directory to a staging copy.
2. Stop Stalwart, rsync the delta, and start it again.
3. Write a `VERSION` file beside the copy.
4. Run `restic backup` over the copy.

The stop lasts seconds, and sending servers retry. Hetzner Backups add seven daily whole-server images on top of this.

### Retention

- Every run: `forget --keep-within 14d --keep-weekly 8 --keep-monthly 12 --keep-yearly 5`.
- Monthly: `prune`.
- Weekly: `restic check --read-data-subset=10%`, the cut line's integrity check.

Whether prune runs cleanly under the lock rules is unverified. The backup rehearsal tests it. If prune fails, the rehearsal shortens the retention or moves prune to a schedule that only touches objects past the window. The decision gets recorded in `decisions.md`.

### Restore

Each server carries `server-restore`. It stops the service, restores a chosen snapshot from R2, runs the service's own checks, and starts the service. For Immich it uses the documented command-line database restore.

The second operator runs it from the browser terminal. If a server is gone entirely, two paths exist:

- **Mail:** a Hetzner backup image, restored from the console.
- **Media:** `scripts/restore-drill.sh --keep`, run from any Linux machine with the repo and the emergency vault's tokens.

### Drills

Each server gets one full restore onto a throwaway server before go-live. After that, a manual drill runs twice a year and after any Immich or Stalwart major upgrade. Results go in `docs/restore-drill-log.md`.

### Archive

`servers-archive` holds the cold copies, under an indefinite lock:

- The Fastmail Vandelay archives.
- The final PikaPods dump.
- The age-encrypted 1Password export.
- The yearly Proton alias export.

## Monitoring

The `servers-monitor` Worker runs every five minutes and keeps its state in D1:

- **Probes:**
  - HTTPS on `photos.907.life/api/server/ping`, Stalwart's `/healthz/live`, and `music.907.life` once dubplate runs.
  - TCP connects to the mail server's 993 and 465. Workers can't open port 25.
- **Heartbeats:** each server's health timer posts every 15 minutes with a per-server token. It reports disk below 80%, no failed units, no reboot pending more than two days, a recent unattended-upgrade, and certificates good for 14 more days. Each backup timer posts after a successful run.
- **Daily inbound probe:** the Worker sends a message to a probe mailbox on Stalwart through Cloudflare Email Sending, which already serves 907.life's `cf-bounce` records. The mail server's health timer confirms arrival over JMAP. That proves the whole inbound path through port 25 from outside.

### Alerts

The Worker posts to two ntfy topics with unguessable names:

- **Urgent topic:** used only when mail fails two probes in a row or the inbound probe fails. Both workstations and the second operator's phone subscribe to it.
- **Routine topic:** media down, a missing heartbeat, a backup older than 36 hours, a disk over 80%, or a certificate inside 14 days. Only the workstations subscribe.

Each workstation runs a user service that subscribes and calls `notify-send`. Urgent maps to critical and routine to normal, per the calm-desktop rule. No alert travels by email through Stalwart.

## Passwords

Proton Pass Family covers Geoff, the second operator, and household members A, B, and C.

### Geoff's account

Two FIDO2 keys as the second factor, never a phone. A paper recovery phrase. Emergency Access set up for the second operator.

### Vaults

- **`Workstation`** holds only the age key. Scripts read it through a 3-month agent token per host, and every read carries a reason.
- **`Servers emergency`** is shared with the second operator. It holds the restic passwords, read-only R2 restore tokens, a Hetzner API token for rebuilds, `operator2`'s console password, and the Stalwart and Immich admin credentials.

### Workstation wiring

The workstation changes follow the mapping table in the Proton Pass brief, section 3:

- `secret-receive --pass` and the `ws-pass-key` helper for `secret-set.sh` and `sync.sh`.
- The zenity paste dialog for `claude-sudo-setup`.
- `claude-block-pass` in place of `claude-block-op`, and the Proton token pattern in `claude-secret-guard`.
- `check-drift` gains the `pass-cli` version and the token expiry.
- `pass-cli` from Proton's Homebrew tap, pinned.
- Browser policies install the Proton Pass extension in Chromium and Firefox and turn off the built-in password managers.

### Migration order

The order matters, because the age key lives in 1Password today:

1. Geoff buys the plan, sets up his account, and invites the four members.
2. Claude takes a count listing from 1Password and lists every login that holds a passkey. The `op` reads happen once, in one session.
3. Geoff exports 1PUX to `/dev/shm` and imports it in the extension. Claude checks the counts and the importer's ignored list, and spot-checks TOTP codes and attachments. It then encrypts the export into `servers-archive` and shreds the plaintext.
4. Claude creates the `Workstation` vault and the agent tokens, then lands the workstation PR with tests against a scratch store.
5. Geoff re-enrolls each passkey site by site. Passkeys aren't in any 1Password export.
6. Household member C moves their own 1Password vault with the same steps, written for macOS.
7. 1Password is uninstalled from both workstations. The subscription is cancelled after a 30-day overlap, once every member confirms.

## Claude's operating authority

Unattended runs need permission rules, because the auto-mode classifier blocks a raw `hcloud server create` as a production deploy. The rules name the repo's scripts, not the raw tools:

- `infra/provision.sh --apply` and `scripts/apply.sh <host> --apply`. Both refuse to delete anything except a server labeled `purpose=drill`.
- `scripts/restore-drill.sh`, which creates and destroys its own labeled server.
- `cloudflare/dns.sh --apply`, limited to the records the repo declares.
- `cloudflare/r2.sh --apply` and `wrangler deploy` from `cloudflare/`.
- SSH as `geoff` to the two servers by name.

Deleting a production server, IP, or bucket stays with Geoff. So do Fastmail, PikaPods, and 1Password account closures, and every purchase. The rules land in a workstation PR that Geoff approves before the first unattended run.

The runbook's Claude infrastructure section records each of these:

- Every permission rule and guard hook.
- Every secret name and where it's read.
- Which sessions may reach the servers.
- Every Cloudflare token and its scope.

It is updated in the same PR as any change to them.

## The runbook

`docs/runbook.md` has four parts, and `EMERGENCY.md` at the repo root renders the first.

1. **Emergency, for the second operator.** One screen per task, copy-paste commands, the expected output after each, and a stop line:
   - Open the browser terminal.
   - Check whether a service is up, and restart Stalwart, Immich, or dubplate.
   - Free disk space.
   - Unban a client from Stalwart's auto-ban.
   - Restore from backup with `server-restore`.
   - Restore the mail server from a Hetzner image.
   - Who to call.
2. **Operator, for Geoff and Claude.**
   - Provision, apply, rebuild, and upgrade Debian, Stalwart, and Immich.
   - DNS and rDNS, rotating a key, adding a user, the restore drill, and Stalwart's recovery mode.
   - The change checklist and the move to Hetzner US.
3. **Catalog.** The official documentation for every service, from the server baseline brief's section 8, plus Cloudflare Tunnel, Access, R2 bucket locks, and DMARC Management. A weekly link check keeps it current.
4. **Claude infrastructure**, as described in "Claude's operating authority".

## What Geoff does

These are the steps only Geoff, or the people he asks, can take. The plan front-loads them so the runs don't stop.

**First week:**

1. File Hetzner's port 25 limit request in the console. Mail waits on the answer.
2. Make sure the Cloudflare, Hetzner, Proton, GitHub, and Fastmail logins recover through an address that isn't on 907.life. Store their 2FA backup codes offline.
3. Buy Proton Pass Family and invite the four members.
4. Enable SFTP on the PikaPods pod and hand its credentials over with `secret-receive`. Update the stale "immich" admin login while you're there.
5. Create a Fastmail API token and a DAV app password for the second operator's mailbox, and hand both over with `secret-receive`.
6. Invite the second operator to the Hetzner Cloud project. Ask him to install the ntfy app on his phone and confirm his GitHub username.
7. Approve the workstation PR that adds Claude's permission rules.

**Later, each when the plan reaches it:**

- Ask the household to pause photo uploads for the Immich cutover window. Claude drafts the message.
- Export and import 1Password, then re-enroll passkeys.
- Confirm the mail cutover date.
- Work the masked-address list.
- Approve each irreversible step: musicbox, the PikaPods pod, Fastmail, and cancelling 1Password.

## Order of work

The plan splits the work into passes in this order. Each pass merges through the normal packet flow.

1. **Foundation.** The `servers` repo and its gate, the permission-rule PR, the R2 buckets and locks, and the monitor and MTA-STS Workers. The Access tunnel setup lands with the first server.
2. **Media server.** Provision, harden, install Docker, Caddy, and Immich, and run the Immich rehearsal under `photos-new`. Set up the backup and its lock-and-prune test, and a full restore drill.
3. **Immich cutover and musicbox.** The upload freeze, the move, and a week of watching. The musicbox library copy into restic.
4. **Passwords.** The Proton Pass migration and the workstation PR. This can run alongside pass 2 or 3.
5. **Mail server.** Provision, Stalwart, DNS preparation, and the `m.907.life` domain. The rehearsal, the client and authentication tests, and a restore drill. Needs the port 25 approval.
6. **Mail cutover.** On the confirmed date, then the sweeps and the T+30 steps.
7. **Wind-down.** Masked-address triage support, Hylki in place of Thunderbird, and the irreversible retirements, each as its own packet.

## Periodic work

A monthly servers review runs in the same session as the monthly model review, from a second committed prompt in the `servers` repo. Where that prompt lives is a placement call the plan settles. The review covers:

- **Hetzner US.** Read US prices and availability. Recommend the move when both servers would cost no more than $10 a month above the EU pair. A move is a rebuild from the repo plus a restore. The mail server gets new IPs, new PTR records, and a fresh sending reputation, so mail moves on a quiet weekday with the same checks as cutover.
- **Upgrades.** Read the Stalwart, Immich, and Debian release notes and apply the upgrades that matter, after a snapshot and a fresh backup.
- **Health.** Summarize the backup checks, the blocklist results for the mail IP, and the DMARC reports.

Twice a year the review adds a restore drill. Once a year it adds the Proton alias export and the DKIM rotation.

## Risks

- **Microsoft distrusts Hetzner IP ranges.** Direct send depends on a clean IP. The blocklist check, aligned SPF, DKIM, and DMARC, the test sends, the delisting flow, and a fresh Primary IP are the mitigations. A relay is the last resort, and adding one would need Geoff's ruling.
- **Hetzner may refuse or delay the port 25 request.** Mail can't cut over until it's approved. A refusal comes back to Geoff with options.
- **Vandelay is five months old.** A silent loss of flags, dates, or bodies would show only in the rehearsal's checks, so the rehearsal checks all three.
- **Stalwart churns.** A weekly patch train is still fixing data-path bugs, and 1.0 brings a schema decision. The version is pinned, and every upgrade follows a stopped backup.
- **RocksDB corruption can be silent.** It happened to one 0.16 user. The retention depth, the Hetzner images, the Vandelay archives, and the daily inbound probe are the defenses.
- **One Cloudflare account holds DNS, backups, monitoring, and operator access.** Account recovery that never runs through 907.life, and offline 2FA codes, are the mitigations. SSH and the Hetzner console work without Cloudflare.
- **Bucket locks and prune may conflict.** The backup rehearsal tests it.
- **Spam filtering starts weak.** Stalwart's filter will be weaker than Fastmail's for the first weeks, while its classifier trains.
- **The masked-address triage can miss a recovery address.** A miss could cost that account after Fastmail closes. Critical services go first, and the 30-day quiet rule guards the close.

## Contestable calls

These are method calls Claude made. Each is flagged because a reasonable reviewer could choose the other way.

- **Stalwart in Docker.** The Stalwart brief preferred a native binary. Docker on host networking keeps one way of running services for the second operator. The logging gap has a documented fix.
- **Push backups.** Servers write to R2 instead of pavilion pulling. Bucket locks replace the no-credential rule, and backups stop depending on pavilion being on.
- **Vandelay archives as the cold copy of Fastmail.** They replace Fastmail's ZIP export, which is 36 manual downloads.
- **A browser terminal for the second operator.** It trades a dependency on Cloudflare and GitHub for no SSH setup on his machine. SSH and the console remain the fallback.

## End-to-end check

The initiative is done when all of these hold:

- Fastmail, PikaPods, and 1Password are cancelled. musicbox is deleted.
- Four mailboxes send and receive at 907.life, with DMARC at `p=reject` and clean reports.
- No enabled Fastmail mask has received mail for 30 days.
- Immich serves the full library at photos.907.life, and a phone upload over 100 MB succeeds.
- The media server is ready for dubplate's deploy.
- Both servers pass a restore drill from R2, and the drill log records it.
- The monitor has delivered a test alert of each priority to each subscriber.
- The second operator has restarted a service and run a restore, using only the runbook.

## Not checked

- The second operator's mailbox size.
- Whether the `music-library` bucket holds the whole library.
- How bucket locks interact with restic's prune.
- Whether DMARC Management's reports are readable through the API.
- Whether Cloudflare Email Sending can deliver to an address on the same domain.
- Whether the ntfy CLI installs from Homebrew.
- Apple profile details for Stalwart.
- Hylki's service discovery.

Each one is checked in the pass that needs it, and the design changes if a check fails.
