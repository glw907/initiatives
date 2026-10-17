# Self-hosting design

## Brief

Approving this design starts a plan that moves 907.life mail, photos, music, and passwords onto two Hetzner servers and Proton Pass, with backups in Cloudflare R2. The work runs unattended after one attended first pass, in which you and Claude gather every credential the later passes need.

Fastmail, PikaPods, and 1Password each hold household data on someone else's terms. The 165 masked addresses on fastmail.com also make leaving Fastmail slower every month. The research is done, you answered the research questions on 2026-10-17, and three reviews and two verification reads have tested the design since, so the plan can be written to run with few stops.

### What changes

- Mail for 907.life moves to Stalwart on a small Hetzner server in the EU, sending directly on port 25. All four Fastmail mailboxes migrate: yours, the second operator's, and household members A's and B's.
- Immich moves from PikaPods to a second Hetzner server in the EU. photos.907.life keeps its name, and uploads over 100 MB start working.
- The same media server is ready for dubplate when dubplate's own build ships. musicbox retires.
- Proton Pass Family covers five people and replaces 1Password for the three who use it. Your new masked addresses end in `m.907.life`.
- Every server backs up nightly to R2. Under the recommended lock, no server can destroy what it has backed up, even if an attacker takes it over. The mail server also gets Hetzner's daily images.
- A Cloudflare Worker watches every service and the backups in R2. It alerts your desktops, and the second operator's phone, through ntfy, and an all-quiet message every 6 hours proves the alert path still works.
- The second operator gets a browser terminal through Cloudflare Access, signed in with GitHub, and a runbook of copy-paste steps.

### If you approve

1. The session writes the pass plan and sends it to you as a packet.
2. You and Claude run Pass 0 together: every account and credential, the permission rules, and a dry run of every token. The port 25 request comes first, because mail waits on Hetzner's answer. Your own move to Proton Pass starts here and runs alongside the server passes.
3. The plan builds the repo, the monitor, and the media server, then moves Immich.
4. The second operator and household member C move off 1Password with steps the plan writes. 1Password is cancelled after all three users have moved.
5. The plan builds the mail server and rehearses the migration. When the rehearsal passes, Claude proposes a cutover date and you confirm it.
6. Claude runs the cutover while you stay on call. The masked-address triage follows, at your pace.
7. Each irreversible step comes to you as its own packet, carrying the evidence listed in "Irreversible steps": deleting musicbox and the PikaPods pod, closing Fastmail, and cancelling 1Password.

### Decide: How deep the backup lock goes

R2 bucket locks stop a server from deleting its own backups. restic stores each piece of data once, so last night's backup still depends on packs uploaded months ago, starting with the first full copy of the photo library. A lock that covers only the last 30 days of uploads leaves those old packs open: a server taken over by an attacker could delete them and make every backup unrestorable, the newest included. Locking the packs for good closes that, at the cost of storage that keeps growing and a cleanup that needs you.

Source: the fold verification's finding B1, confirmed by a local restic probe on 2026-10-17.

- Lock the backed-up data for good, and never prune automatically. No server can destroy its backups. Storage grows by each day's new data, a rough and unmeasured 15 to 40 GB a year, about $0.25 to $0.60 a month more each year. A cleanup comes to you as a packet when the buckets pass 200 GB. (recommended)
- Lock only the last 30 days of uploads, and prune monthly. Storage stays near today's size and nothing needs you, but an attacker on a server can delete any pack older than 30 days and break every backup. A daily check of the packs would report that afterward, not prevent it.

### Decide: If Hetzner refuses or stalls port 25

Mail can't cut over until Hetzner lifts the port 25 block, and your ruling sends mail directly with no relay. The design pauses the mail passes and comes back to you if the answer is no. Deciding now only matters if that happens.

Source: the contract review's finding M17.

- Pause the mail passes, and send you an options packet after a refusal or 14 days with no answer. (recommended)
- Pre-approve a relay on port 587, SMTP2GO's free tier or Amazon SES, for a refusal, a stall, or a lasting Microsoft block. You'd still create the relay account; Claude does the rest.

### Worth knowing

This design reverses one earlier ruling. The 2026-10-17 brainstorm ruled out any off-site backup copy. Later that day you chose R2 for every backup and named Cloudflare core infrastructure, which settles it the other way. The backup lock was settled by probes against a scratch R2 bucket and a local restic repository, not left to the rehearsal.

### The rulings behind this design

Every ruling is listed with its date in "Rulings". The ones made after the pavilion handoff: OVH is out for business stability, both servers go to Hetzner in the EU, mail sends directly on port 25, backups go to R2 only, and the second operator gets full sudo and a browser terminal. Later rulings in chat added a $40 monthly spend ceiling, the age key on paper, four migrating mailboxes, and an attended Pass 0 that starts your own move to Proton Pass.

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
- **Later the same day, in chat (2026-10-17):**
  - **Spend ceiling.** Claude may run recurring services up to $40 a month in total across Hetzner, R2, and Cloudflare without asking. Any one-time purchase, any new vendor account, and anything that would take the recurring total past $40 comes to Geoff.
  - **The age key on paper.** The workstation age key goes on paper in the recovery kit, kept locked up at home.
  - **Workers Paid.** The Cloudflare account is already on Workers Paid.
  - **Pass 0.** A new first pass, "Attended access", runs with Geoff present throughout. It gathers every account and API credential the later passes need, lands the Claude infrastructure changes, and ends with a dry run proving every token works.
  - **Geoff's Proton move.** It starts in Pass 0 and runs alongside the server passes: his account and FIDO2 keys, his 1Password import, the `Workstation` and `Servers emergency` vaults and agent tokens, and the workstation security PR. New credentials from Pass 0 go into Proton Pass, never 1Password.
  - **Three 1Password users.** Geoff, the second operator, and household member C use 1Password today. The second operator creates his Proton account in Pass 0 and handles his own migration. Household member C uses no masked addresses, so their move is a plain vault import with written macOS and iOS steps, later. 1Password is cancelled only after all three have moved. Household members A and B join Proton Pass without a 1Password vault.
  - **Four mailboxes migrate.** Fastmail has four users today, Geoff, the second operator, and household members A and B, each a separate login with their own mailbox and contacts, and perhaps calendars. All four move to Stalwart.

## Rulings needed

Two questions are open, and the brief's two `### Decide:` blocks carry them with their choices. The backup lock matters more, because it fixes what the backups promise.

1. **How deep the backup lock goes.** The recommended answer is the design in "Backups". The other answer moves `data/` to a 30-day rule, adds a monthly `prune`, and adds a daily listing of `data/` that reports deleted packs.
2. **If Hetzner refuses or stalls port 25.** The recommended answer adds a 14-day follow-up and an options packet. The other answer adds a relay route for a refusal, a stall, or a lasting Microsoft block. Geoff still creates the relay account, and the relay joins "Senders of 907.life".

## Who uses what

The repo is public, so household members appear by role. The real names live only in chat with Geoff and in the session's private memory. Their addresses are known to the session too, and they go only in the private `servers` repo, never in this one.

| Role | Stalwart mailbox | Proton Pass | Devices |
|---|---|---|---|
| Geoff | yes, migrated | owner | Linux workstations, no smartphone |
| Second operator | yes, migrated | member | Linux, Android |
| Household member A | yes, migrated | member | macOS, iOS |
| Household member B | yes, migrated | member | macOS, iOS |
| Household member C | no | member | macOS, iOS |

Three of the five Proton Pass users are on Apple devices, so the Safari, macOS, and iOS setup gets written out step by step. Nothing in the design assumes a phone of Geoff's. That covers alerts, logins, and second factors. Tests that need a phone, such as the large Immich upload, borrow a household member's.

## Architecture

Two Debian 13 servers in Hetzner's EU locations carry the services. Cloudflare carries DNS, backups, monitoring, and the second operator's access. The workstations carry Claude, the repo, and the Proton Pass command line.

| Piece | Where | Runs |
|---|---|---|
| Mail server | Hetzner CX33 (4 vCPU, 8 GB, 80 GB), EU | Stalwart in Docker on host networking, `cloudflared`, the health timer, the backup timer |
| Media server | Hetzner CX33 (4 vCPU, 8 GB, 80 GB), EU | Immich in Docker Compose, Caddy, the dubplate host side, `cloudflared`, the health and backup timers |
| Backups | R2 buckets `servers-backup-mail`, `servers-backup-media`, `servers-archive` | restic repositories with bucket locks; cold archives |
| Monitor | Worker `servers-monitor` with a D1 database | cron probes, heartbeat intake, the R2 snapshot check, ntfy alerts, the daily inbound mail probe |
| MTA-STS | Worker on `mta-sts.907.life` | the static policy file |
| Operator access | Cloudflare Tunnel and Access | the browser terminal and Stalwart's admin page, with GitHub sign-in |
| Workstations | thinkpad-x1, pavilion | the `servers` repo, `hcloud`, `wrangler`, `pass-cli`, the ntfy subscriber |

Both servers live in a Hetzner project of their own. Hetzner API tokens belong to one project, so Claude's token reaches nothing else on the account, musicbox included.

### Locations and types

Both servers are CX33s, x86 with 4 vCPUs, 8 GB, and an 80 GB local disk at $9.99 a month. The location order is fsn1, nbg1, then hel1. The hosting brief measured minimum round trips of 203 to 226 ms from Anchorage across the three, a difference that doesn't matter for mail or photos. Hetzner's cost-optimized stock moves within hours. A live read on 2026-10-17 at 22:27 UTC (`hcloud server-type list`) showed the CX33 orderable in hel1 only, the CX23 in all three, and the CX43 and CAX21 nowhere, though the hosting brief found CAX21 in fsn1 that morning. So `provision.sh` reads live availability, takes the first location in order that has the type, and stops with a clear message instead of guessing. If no EU location has it, the pass retries daily for seven days, then reports a stall to Geoff. A Primary IP belongs to one location and can't move, so the script settles the location before it creates anything. The media server stays x86, so dubplate's existing amd64 binary runs on it unchanged.

### IPs

Each server gets a Hetzner Primary IPv4 and IPv6. They are created before the server with auto-delete off and delete protection on, so a rebuild keeps the PTR records and the mail IP's reputation. Before the mail IP is attached, Claude checks it against Spamhaus, MXToolbox, and multirbl, and allocates a new one if it is listed.

### Cost

The servers and R2 come to about $24 a month, inside Geoff's $40 ceiling. Proton Pass Family adds $59.88 a year:

- Mail server: $9.99, plus $0.60 for IPv4 and about $2 for Hetzner Backups. A CX43 instead costs $18.49 plus about $3.70 for backups.
- Media server: $9.99, plus $0.60 for IPv4.
- R2: about $1 at first, growing with the backups (see "Retention"). R2 charges $0.015 per GB-month past the first 10 GB.
- Proton Pass Family: $59.88 a year, about $5 a month.

The account is already on Workers Paid, which Geoff confirmed, and Workers, D1, Email Sending, and Access for two people are expected to fit within it. These are 2026-10-17 prices, and the runbook links Hetzner's price page rather than copying the numbers.

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
    firewall-drill-restore.json  firewall-drill-closed.json
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
    deploy.sh               deploy.sh monitor|mta-sts
    dns.sh                  publishes and checks the zone records the repo declares
    r2.sh                   buckets, lock rules, scoped tokens
  scripts/
    apply.sh                apply.sh HOST [--check|--apply]
    restore-drill.sh        builds a throwaway server, restores, verifies, destroys it
    promote.sh              makes a drill server that passed into production
    archive.sh              age-encrypts and uploads one file to servers-archive
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

CI runs the linting and these container checks. The cut line said linting only, so the container checks are listed in "Contestable calls". The gate also fails if `disable-protection` appears anywhere in `infra/` or `scripts/`. The second operator gets read access to the repo, so the runbook is always in reach.

## Base host

Both servers share one base, from the server baseline brief:

- **OS:** Debian 13 from Hetzner's `debian-13` image.
- **Patching:** `unattended-upgrades` with an automatic reboot at 12:00 UTC when one is required, and `needrestart` in automatic mode.
- **Time and logs:** `chrony`, and persistent journald capped at 500 MB and one month.
- **Firewall:** the Hetzner Cloud Firewall is the one enforced firewall. Every Docker port binds to loopback unless a service needs the public interface.
- **SSH:** keys only. Root login is off, `PermitRootLogin no` lands after cloud-init creates the users, and there is no fail2ban.

Two users have shell access, and both have full sudo, by Geoff's ruling. `geoff` holds Geoff's key and the workstation key Claude uses. Its sudo needs no password, because the SSH key is the factor and unattended runs can't answer a prompt; `apply.sh --check` proves it with `sudo -n true`. The second operator's account has no long-lived key and signs in through the browser terminal. Its password works for sudo and for the Hetzner web console, while sshd refuses passwords. This spec calls that account `operator2`. Its real name is his email prefix (see "Access"), and it lives only in the private repo.

Docker CE comes from Docker's own Debian repository on both servers. Every container logs through Docker's `journald` driver. One journald cap then covers all logs, and `docker logs` still works (Docker's logging docs). Docker kills a container 10 seconds after asking it to stop, so each container that holds a database gets a 120-second grace period. Apt preferences hold Docker to its current major version. unattended-upgrades takes its patches, while a major upgrade restarts every container and waits for the monthly review.

unattended-upgrades also takes Debian's security origin plus three vendor origins: Docker (`Origin: Docker`), Caddy (`Origin: cloudsmith/caddy/stable`), and cloudflared, whose repository serves the `any` suite rather than `trixie`.

### Inbound ports

The mail server opens 22, 25, 80, 443, 465, 993, and ICMP to everyone, and 587 to the media server's two addresses only, for Immich's mail. The media server opens 22, 80, 443, and ICMP.

## Access

Geoff and Claude reach the servers with SSH keys. The second operator reaches them through Cloudflare:

1. `cloudflared` on each server holds an outbound-only tunnel.
2. Access publishes a browser-rendered SSH terminal at `ssh-mail.907.life` and `ssh-media.907.life`.
3. An Access policy admits only the second operator's GitHub identity and Geoff's. Geoff's is there for Stalwart's admin page; he reaches the servers over SSH, so the terminal's username rule doesn't matter for him. Geoff creates the GitHub OAuth app that Access signs in through. Cloudflare's GitHub guide has it made in GitHub's own settings, so Claude can't create it.
4. The terminal signs the second operator in with Access short-lived certificates, so no key lives on his machine.

He can open it from his Linux machine or his phone.

Two Cloudflare details shape this. The browser terminal requires each person's email prefix to match their Unix username, so his account is named after the prefix of the email GitHub hands to Access; the media pass confirms which address that is before it creates the account. The sshd trust lines (`TrustedUserCAKeys` and `PubkeyAuthentication yes`) must come before every other directive. Debian 13's `sshd_config` includes `sshd_config.d/*.conf` as its first directive (checked in a `debian:13` container), so a drop-in named `00-cloudflare-ca.conf` meets that rule.

Cloudflare marks short-lived certificates as legacy and "not recommended for new deployments". Their successor, Access for Infrastructure, needs the Cloudflare One client and doesn't offer the browser terminal. The design uses the legacy path on purpose and names the fallback in "Risks".

Stalwart's web admin sits behind the same Access login. Stalwart's `/admin` also stays loopback-only on the public listener, and the admin account is limited to loopback, as the Stalwart brief recommends. Immich's admin pages stay on photos.907.life behind Immich's own login, since the hostname is public anyway.

If Cloudflare is down, Geoff and Claude still reach both servers over SSH. The second operator also becomes a member of the servers' Hetzner project. That gives him the console and the mail server's backup images when nothing else answers. He holds no Hetzner API token and no secret that renders a server's configuration, so rebuilding a deleted server isn't his job (see "Restore").

## Mail

### Stalwart

Stalwart runs at a pinned version, the newest 0.16.x at build time. If 1.0 has shipped by cutover, it runs 1.0.1 or later. The official image runs in Docker on host networking, so auto-ban and the logs see real client addresses. Logging goes to the console, which the `journald` driver carries. That avoids the image's unwritable default log file. The image runs as UID 2000, so the data directory is owned by `2000:2000`. `stalwart-cli` is installed at a pinned version, checked against its hash.

Configuration is a `config.json` plus an NDJSON plan applied with `stalwart-cli apply` against a loopback listener. All four stores are RocksDB on the local disk. Before any import, the plan:

- Sets auto-ban ban periods.
- Adds `dmarc-reports@` and `tls-reports@` to the report addresses.
- Points the DNSBL checks at Spamhaus through a free DQS key, held as a `File` secret. Spamhaus answers queries from Hetzner's resolvers with an error code, so the checks are useless without one.
- Opens the submission listener on 587 for Immich.

`install.sh` pins `exim4`, `postfix`, and `sendmail` to priority -1 in apt. In Docker the risk is that an installed MTA takes port 25 and the container can't bind it on restart, so the container also runs with `restart: always`. Claude reads the spam-filter rule updates and applies them on purpose, never automatically.

### Size

Geoff's mailbox measured 5.14 GiB across 35,576 messages (read-only JMAP, 2026-10-17). The other three are unmeasured. The disk holds the live store, the backup's staging copy, and room for a side-by-side restore, each at roughly 1.5 times the raw mail, plus about 5 GB for the system. Geoff's mailbox alone would fill a CX23's 40 GB disk to about 75%, leaving no room for the other three, so the mail server is a CX33. A CX33 holds about 12 GB of raw mail across all four mailboxes under the 80% alert. The mail pass measures the other three before it provisions anything. If the four total more than about 12 GB, the mail server is a CX43 instead (8 vCPUs, 16 GB, 160 GB, $18.49), keeping the store on local disk and so inside Hetzner's backup images and snapshots; a Hetzner Volume would fall outside them. Either type keeps the recurring total well under the $40 ceiling. Vandelay runs on a workstation, so its archives never take server disk. The health timer alerts at 80% full.

### Delivery

Outbound mail goes directly on port 25, over IPv4 only. Stalwart's IP strategy is `ipv4_only`, so a missing or wrong IPv6 PTR can't cost delivery. PTR records match `mail.907.life` on both addresses. Inbound works on IPv4 and IPv6 from day one.

The outbound test sends to a Gmail and an Outlook.com test account, and to mail-tester. Geoff creates the two test accounts, because signup captchas stop Claude. Yahoo is left out: its published rules match Google's, and Microsoft is the receiver with a documented record of refusing Hetzner ranges. Each message must reach the inbox, not Junk, within 15 minutes, and its headers must show `spf=pass`, `dkim=pass` with `d=907.life`, `dmarc=pass`, and TLS. Claude reads the results where it can sign in; elsewhere Geoff opens the message and reports where it landed. A missing message is a failure, because Microsoft's documented failure is a silent drop.

If Microsoft refuses the IP, Claude follows Hetzner's documented delisting flow. If delisting fails, Claude moves the server to a fresh Primary IP. A relay appears in the runbook only as a last-resort note, and "Rulings needed" holds the open question of when one may be configured.

### Senders of 907.life

These systems send as 907.life, and DMARC must pass for each before the policy tightens:

| Sender | Sends | Authenticates with | Until |
|---|---|---|---|
| Stalwart | household mail | the new DKIM selector, the server's IPv4 in SPF | always |
| Cloudflare Email Sending | the 907.life site's sign-in links and contact form, the monitor's daily probe, and dubplate's pings Worker (`pings@907.life`) | Cloudflare's signing for 907.life and the `cf-bounce` return path | always |
| Fastmail | household mail until cutover, and SMTP for Immich and, once deployed, dubplate | the `fm*` DKIM keys and Fastmail's SPF include | T+30 |

Immich and dubplate send through Fastmail's SMTP on 587 today; dubplate's identity design names Fastmail for its sign-in links. Both move to Stalwart's submission listener on 587, which the mail firewall opens to the media server, before 907.life leaves Fastmail. A dubplate deploy that lands after cutover points at Stalwart from the start.

DMARC moves to `p=quarantine`, and later to `p=reject`, only when 14 consecutive days of aggregate reports show every listed sender passing aligned and no unlisted source sending. Before each step, a sign-in mail from the site and a monitor probe must both show `dmarc=pass` at Gmail.

### DNS

Claude writes the 907.life records the repo declares, through `cloudflare/dns.sh` with a scoped token. Other writers exist: Cloudflare DMARC Management adds its own `rua` to the DMARC record, and Workers custom domains create their own records. So `dns.sh` declares the DMARC value with Cloudflare's `rua` copied in, and reports any record it doesn't declare (the site's, `cf-bounce`, the Workers') without ever deleting one. Every `--apply` ends with a `--check` against public resolvers, so a dropped MX shows at once.

Stalwart's generated `dnsZoneFile` is the source for the mail records:

- `mail.907.life` A and AAAA, DNS-only, matching PTR and the EHLO name.
- One MX, `10 mail.907.life`, set at cutover and never mixed with Fastmail's.
- `probe.907.life` MX `10 mail.907.life`, from the day the mail server exists, for the monitor's probe.
- SPF, before cutover: Fastmail's include plus the server's IPv4 and `~all`. After the rollback window: the server alone and `-all`, still covering Cloudflare's `cf-bounce` return path, which has records of its own that stay untouched.
- A new DKIM selector (RSA 2048, plus Ed25519 if Stalwart signs with both), published days before cutover. DKIM rotation is manual and yearly. The `fm1` to `fm3` CNAMEs stay until Fastmail closes.
- DMARC at `p=none` through cutover. Aggregate reports go to Cloudflare DMARC Management and to `dmarc-reports@907.life`, so Stalwart keeps a copy if the dashboard's reports can't be read through the API. The ramp follows "Senders of 907.life" and uses RFC 9989's `t=y` test flag.
- TLS-RPT to `tls-reports@907.life`.
- MTA-STS, served by the `mta-sts` Worker. It starts in `testing` with a one-day max age while both MX hosts are listed, and moves to `enforce` after Fastmail's MX is gone.
- Client discovery SRV records, plus Cloudflare redirect rules that send the apex's `/.well-known/caldav`, `carddav`, and `jmap` paths to the mail server.
- No DNSSEC and no DANE, per the cut line.

### Migration

Vandelay, run on a workstation, copies each Fastmail account into a SQLite archive, then into Stalwart:

- All four accounts move: Geoff's, the second operator's, and household members A's and B's. Each needs its own Fastmail API token, DAV app password, and IMAP app password, because each is a separate login.
- Migration runs on each member's credentials, but Claude reads only counts and metadata for verification, never message content; the body check compares hashes. A member's masked addresses are checked with `MaskedEmail/get` alone. This is the mail side of the rule that Claude never reads a personal vault.
- Mail and contacts go over JMAP, using `--account-id` rather than `--account-name`. Geoff's token also reaches a shared, contacts-only account, which moves with his.
- Calendars go over CalDAV, with a DAV app password for each account.
- Fastmail's Trash and Junk stay behind. If Vandelay can't skip them, Claude empties them in Stalwart by mailbox role right after the import, first checking that the count matches the archive's. The final Vandelay pass would bring them back, so the step repeats after it.
- Every 907.life address Fastmail accepts gets created in Stalwart before the MX switch: aliases, `postmaster@`, any catch-all, and the three @907.life masked addresses Fastmail hosts. Geoff confirms the list, because Fastmail's JMAP doesn't show alias settings.

The Vandelay archives go to `servers-archive` in R2 as the cold copy, in place of Fastmail's one-folder-at-a-time ZIP export.

### Rehearsal

The rehearsal runs on the real mail server while MX still points at Fastmail. It imports full copies of all four mailboxes, their contacts, and their calendars, then checks each row:

| Check | Passes when |
|---|---|
| Mail counts | Per mailbox, total and unread equal the archive's counts from `vandelay inspect`, Trash and Junk excluded |
| Flags | `$flagged` and `$answered` counts are equal |
| Dates | `receivedAt` matches on 50 messages per account, drawn across its date range |
| Bodies | The SHA-256 of the raw message matches on 20 messages per account, after removing any header Stalwart adds |
| Contacts | The count per address book is equal, the shared account included |
| Calendars | The event count per calendar is equal, and three recurring events and one event in another time zone match |
| Late mail | A date-scoped imapsync sweep into Stalwart passes the body check, and a reverse sync into a scratch Fastmail folder works |
| Clients | Hylki and poplar read mail, contacts, and calendars. A test account's profile installs on one iOS and one macOS device, and mail, an event, and a contact sync both ways |
| Android | The second operator's Android client reads mail, contacts, and calendars from a test account |
| Sending | The outbound test in "Delivery" passes |
| Receiving | Test mail arrives by direct SMTP connection, and the monitor's probe arrives |
| Trash expiry | An old message moved to Trash, then a maintenance run, shows whether expiry counts from the move or from the received date, and `expungeTrashAfter` is set from the result |
| Restore | The mail server's pre-go-live drill in "Drills" passes |
| Backup growth | `restic stats --mode raw-data` over the rehearsal week gives the mail repository's daily growth, which goes in the cutover packet |
| Image restore | Last night's Hetzner backup image, restored in place from the console, boots and Stalwart starts |

Claude repeats the rehearsal until every row passes. After two failed rehearsals on the same defect, that data type moves to its fallback, imapsync for mail or `.ics` and vCard import for calendars and contacts, and `decisions.md` records the switch. Before the final pass, Claude deletes the rehearsal's test messages from the real mailboxes. Then Claude proposes a cutover date. Geoff confirms the date. That confirmation is the one planned stop before cutover.

### Cutover

Claude runs cutover day, with Geoff on call. Steps 1 to 5 run in one window of about an hour, and Claude's drafted message asks the household to leave Fastmail clients closed during it, so no flag or move is lost between the final pass and the switch.

1. Stop the workstation `vdirsyncer` timer, which syncs contacts two ways with Fastmail.
2. Run a final Vandelay pass.
3. Switch MX to `mail.907.life` through the API.
4. Run the inbound probe from outside, and a send from inside Fastmail, which catches Fastmail delivering locally to a domain it hosts.
5. Point Hylki and poplar at Stalwart, and repoint Thunderbird at Stalwart for mail, contacts, and calendars until it retires in the wind-down, so nothing on the workstations still writes to Fastmail. `vdirsyncer` either moves to Stalwart with a fresh status directory after a one-way first sync, or retires if nothing reads its local copy.
6. Send the second operator a short guide for his Android client, and household members A and B their configuration profiles. On every device, the steps turn off Contacts and Calendars on the Fastmail account and make Stalwart the default for mail, contacts, and calendars. The Fastmail account stays for rollback until T+30.
7. Point Immich's SMTP, and dubplate's if it is deployed, at Stalwart on 587, and send a test mail from each to a household mailbox.

Failed checks lead here:

| Check that fails | Response |
|---|---|
| Inbound from outside | Fix forward for 30 minutes, then Claude reverses the MX without waiting for Geoff |
| Outbound delivery or authentication | No MX rollback. Clients send through Fastmail's SMTP until it's fixed, since Fastmail's SPF and DKIM stay valid until T+30 |
| Local delivery inside Fastmail | Expected; the sweeps carry that mail |
| A client can't read mail | Fix forward |

Claude decides a rollback inside the window and tells Geoff. Rollback is a reverse MX switch, and the TTL is already 300 seconds. Mail that reached Stalwart in the meantime, Sent included, is copied back to all four Fastmail accounts with a reverse imapsync. Every household address still exists at Fastmail, so a rollback strands no one.


### After cutover

- **T+7:** a Vandelay export of each Fastmail account's contacts and calendars, compared with the cutover archive by count and change date. Any difference is carried to Stalwart, and the same check repeats for the T+30 packet.
- **T+1, T+3, and T+7:** date-scoped imapsync sweeps of every Fastmail folder except Trash and Junk, in all four accounts. Each sweep logs the messages it copied per folder. A daily sweep then continues until the masked-mail forward is live.
- **T+30, if clean.** Clean means no rollback happened, the last three sweeps copied nothing, the reports pass for every sender in "Senders of 907.life", and no household member has reported missing mail. Then:
  - Ask the household, with a drafted message, to remove the Fastmail account from their devices.
  - Drop Fastmail's SPF include and move SPF to `-all`.
  - Move MTA-STS to `enforce` and DMARC to `p=quarantine`.
  - Send Geoff the Fastmail packet in "Irreversible steps": remove the three users other than Geoff, rename Geoff's login if it's on 907.life, then remove 907.life and downgrade to Individual. Which plan the account is on today is unverified; the mail-cutover brief lists Individual and Duo, and four users need more than either. After that, Geoff sets the masked-mail forward to Stalwart.
- **Later:** DMARC moves to `p=reject` once the reports allow it.
- **When triage ends:** Fastmail closes through its own packet, and the `fm*` CNAMEs go with it.

In Pass 0 Claude checks whether Geoff's Fastmail login is an @907.life address. If it is, the login is renamed before the domain removal.

### Clients

On the workstations, Hylki replaces Thunderbird. Thunderbird retires only after Hylki reads mail, contacts, and calendars from Stalwart, and after any Thunderbird Local Folders and local address books are imported. poplar's account moves to Stalwart's JMAP endpoint.

Each Apple user gets one `.mobileconfig` carrying the mail, CalDAV, and CardDAV accounts. Claude writes these profiles. Stalwart doesn't generate them. A profile carries no password, so it can travel by any channel; the device asks for the password on install, which the rehearsal confirms on both iOS and macOS. Each member's password reaches them in their own Proton Pass, shared from Geoff's account.

## Masked email

Proton Pass custom domain `m.907.life` holds Geoff's new masked addresses. Geoff adds the domain in the Proton Pass web app as part of his own Proton move, so the critical-tier triage can start before mail moves. It gets its own MX, verification, SPF, DKIM, and DMARC records, with the values copied from the Pass Info tab. Its default mailbox is `geoff@907.life`. Delivery follows 907.life's MX, so the mailbox works before and after cutover with no change.

Proton's docs don't say whether Family members can use the owner's custom domain. If they can't, members keep Proton's own alias domains, which is their own choice to make.

Aliases are disabled during triage, never deleted, because Proton can't recover a deleted alias. A yearly export of the alias list goes to `servers-archive`.

### Triage

The 165 @fastmail.com masked addresses move one service at a time, along with any the other three users hold:

1. Claude snapshots every masked address over JMAP into an age-encrypted file outside git. The second operator lists his own masked addresses and Fastmail-only logins in Pass 0. Whether household members A and B have any is unknown; Claude checks over each one's API token in the mail pass.
2. For Geoff's masks, Claude adds message counts and sender domains for the last year, and joins the list against the Proton Pass logins after the import. Other members' masks get `MaskedEmail/get` alone.
3. Each address gets a tier: critical (banks, government, health, utilities, domain and hosting, account recovery), active, dormant, or never used.
4. Geoff works the list at his own pace: create the alias inline in the service's form, change the address at the service, confirm the verification mail arrives, then disable the Fastmail mask. No bulk path exists, so this is the one long stretch of human work in the initiative. Critical services go first.
5. Claude recounts from the API each week and reports what is left. Mail to a disabled mask gets its own line, because it marks a service that was missed.

Fastmail closes when no enabled mask and no forwarded masked mail has appeared for 30 days, read from each mask's `lastMessageAt`. The research budgets about three months of Fastmail in total. The final mask list, with its triage status, goes to `servers-archive` before Fastmail closes.

## Photos

Immich runs the official Docker Compose files on the media server, pinned to an exact v3 tag, with Caddy in front on 80 and 443. Ports bind to loopback, and `IMMICH_TRUSTED_PROXIES` names Caddy. ML is capped at 3 GB and 2 CPUs, and job concurrency is 1. A 2 GB swap file goes in. Caddy comes from Caddy's own apt repository.

### Migration

Immich's own dump plus `UPLOAD_LOCATION`:

1. Geoff enables SFTP on the PikaPods pod and hands the credentials over with `secret-receive`.
2. Claude downloads the newest dump through `GET /admin/database-backups/{filename}` with the stored API key, and copies `library`, `upload`, `profile`, `backups`, `thumbs`, and `encoded-video` over SFTP.
3. On the media server, under the temporary DNS-only name `photos-new.907.life`, Claude restores at the pod's exact version onto Postgres 16 with VectorChord, matching the pod's Postgres 16. PostgreSQL doesn't promise that a dump loads into an older major version.
4. Claude verifies against the pod's live counts from `/api/server/statistics`, which were 3,724 photos, 92 videos, 155 people, 1 album, 3 shared links, and 5 users on 2026-10-17. It also checks the integrity page, the existing API key, and SMTP (Fastmail on 587 until mail moves), and a household phone connects to `photos-new`.
5. Cutover: Geoff asks the household to pause uploads for a short window. Claude takes a final dump and stops the pod. It reads the version from the dump's file name, since the pod updates itself. It wipes the rehearsal's Postgres data, copies the delta, restores again, and checks the counts against the pod's at the freeze. Then it switches photos.907.life from the proxied CNAME to DNS-only A and AAAA records, and adds the photos.907.life site to Caddy at the same moment, so Caddy doesn't fail certificate checks against PikaPods.
6. Claude confirms the certificate and a household phone's upload of a video of at least 150 MB from outside the house, with a matching checksum.
7. Before the upgrade to the current v3 patch, Claude takes a manual dump and a Hetzner snapshot, because Immich supports no downgrade.
8. The pod stays stopped for a week. Deleting it is an irreversible step that comes to Geoff.

A failed restore, integrity errors, or a failed large upload rolls the move back: photos.907.life returns to the proxied CNAME, the pod restarts, and any uploads made since the freeze are copied back to it. The week passes with zero integrity errors, a backup every night, uploads from at least one household phone, and no client stuck in a sign-in loop.

After mail moves, Immich sends through Stalwart on port 587.

## Music

The media server carries dubplate's host side: the `music` user, `/srv/music/library`, `/srv/music/staging`, `/var/lib/dubplate`, and a Caddy site for `music.907.life` with dubplate's trusted-proxy rows. dubplate itself deploys with its own `deploy.sh` once its 0.8 release is ready. That build belongs to the dubplate-server initiative. dubplate keeps its systemd unit, which makes it the one service not in a container. This design changes only dubplate's deploy target and, from cutover, its SMTP server (see "Senders of 907.life").

### Retiring musicbox

musicbox still runs, with dubplate installed and disabled, so it serves nothing and its state doesn't change. Claude copies its `/srv/music/library` (6.6 GB) and `/var/lib/dubplate` into `/srv/music` on the media server, where the nightly backup takes them into restic. The copy is checked by restoring it from restic into a scratch directory and comparing SHA-256 sums against musicbox. Claude also reads what the existing `music-library` R2 bucket holds, which needs its rclone crypt passwords; the media pass finds where dubplate keeps them. Deleting musicbox's server, volume, firewall, and IPs, and the `music-library` bucket, then comes to Geoff as an irreversible step.

## Backups

Each server backs itself up to its own R2 bucket with restic. Each server holds an R2 Object Read & Write token scoped to its one bucket, plus its own restic password, both in root-only files. An Object token can read and write objects but can't change a bucket's lock rules; Cloudflare gives "edit bucket configuration" only to Admin tokens.

### Lock rules

A restic repository is a `config` object plus the `keys/`, `data/`, `index/`, `snapshots/`, and `locks/` prefixes, and restic writes each file once and never modifies it. restic also stores each piece of data once. Every snapshot, the newest included, therefore depends on packs uploaded as far back as the first backup, such as the first full copy of the photo library. Each server's bucket carries these rules:

| Objects | Rule | Why |
|---|---|---|
| `config`, `keys/`, and `data/` | Indefinite | The repository can't be opened without the first two, and `data/` holds every backed-up byte. |
| `snapshots/` | 30 days from upload | A deleted snapshot file can be rebuilt from the locked data with `restic recover`, and nightly `forget` needs to remove old ones. |
| `index/` and `locks/` | none | `restic repair index` rebuilds the index from the packs. restic deletes its lock files on every run. |

So a server taken over by an attacker can't destroy anything it has backed up. It can delete snapshot files older than 30 days, and the index, and both come back from the locked packs. A local probe on 2026-10-17 deleted every snapshot and index file from a test repository. `restic repair index` and then `restic recover` rebuilt a snapshot that restored every file. The first `recover` run failed with "nodes are not ordered or duplicate" and the second succeeded, so the runbook says to run it again on that error, and the media drill proves `recover` once.

The rules land after `restic init` and the first verified backup on media, and after the last rehearsal import on mail, before cutover, because R2 can't empty a bucket while any rule is set, and rebuilding a repository during the build would otherwise need a rule lifted. `cloudflare/r2.sh` only adds rules. Only Geoff lifts one, by hand, and never as part of an unattended run.

Probes on 2026-10-17 checked the mechanics:

- Against a scratch R2 bucket, R2 refused deletes and overwrites of locked objects with `409 ObjectLockedByBucketPolicy`, and allowed deletes under `locks/`.
- restic treats that refusal as a temporary error and retries it for 15 minutes before giving up. A `forget` that reached a locked snapshot would stall for that long every night and then fail, so retention never reaches one.
- An Indefinite rule held until an Admin token removed it.
- A backup killed partway left a lock that blocked the exclusive `forget` until `restic unlock` removed it.
- In a local repository, deleting only the packs from a first backup left the second backup restoring one file of two, which is why `data/` needs the Indefinite rule.

### Retention

- Nightly, after each backup: `forget --keep-within 35d --keep-weekly 8 --keep-monthly 12 --keep-yearly 5`. It removes only snapshot files. 35 days covers the 30-day rule on `snapshots/` plus 5 days for a slow backup, because `--keep-within` counts from the newest snapshot and the rule counts from upload.
- Weekly: `restic check --read-data-subset=10%`, the cut line's integrity check.
- Never automatically: `prune`. Data from forgotten snapshots stays in the locked packs.

Storage therefore grows by each day's new data. Nobody has measured the rate, and the estimate below leaves out mail. Immich's nightly dump is gzipped, about 38.6 MB, and the backups brief notes that one changed row shifts a whole gzipped stream, so restic deduplicates it poorly. The dumps alone could add about 14 GB a year. New photos add an unmeasured amount on top. Stalwart's RocksDB files, which compaction rewrites, could add as much again; the rehearsal week measures that figure. A rough 15 to 40 GB a year costs about $0.25 to $0.60 a month more each year, at R2's $0.015 per GB-month. The media pass checks whether an uncompressed dump deduplicates better, and the monthly review tracks growth with `restic stats --mode raw-data`. When the backup buckets pass 200 GB together, a cleanup comes to Geoff as a packet: he lifts the `data/` rule, Claude runs `prune` and `restic check`, and `r2.sh` puts the rule back.

One unit runs the nightly and weekly jobs in order under `flock`. It runs `restic unlock` first, which removes only stale locks, and passes `--retry-lock 30m`. A backup that exits with status 3, a snapshot with unreadable files, counts as a failure. The health heartbeat carries each job's result.

### Media, at 03:00

Immich writes its own database dump at 02:00. The media timer first checks that the newest dump is under 26 hours old and passes `gunzip -t`, and fails otherwise. It then writes a manifest of asset counts from `/api/server/statistics`, the dump's file name, and the Immich version, and runs `restic backup` over:

- Immich's `library`, `upload`, `profile`, and `backups` directories.
- `/srv/music`.
- dubplate's state.
- The manifest.

Thumbnails and transcodes are skipped, because jobs regenerate them. dubplate's state is copied while dubplate is stopped for a few seconds, until dubplate offers a local snapshot command. That request goes to dubplate's backlog.

### Mail, at 03:30

The script stops at the first failing step, so restic never stores a copy from a failed stop:

1. rsync the live data directory to a staging copy.
2. Read each mailbox's message count over JMAP, Trash and Junk excluded.
3. Stop Stalwart with a 120-second grace period, and go on only if it exits cleanly rather than being killed. A trap restarts Stalwart if the script dies from here on.
4. rsync the delta, and start Stalwart again.
5. Write a manifest beside the copy: the running image's digest and the counts from step 2.
6. Run `restic backup` over the copy and the manifest.

The stop lasts seconds, and sending servers retry. Hetzner Backups add seven daily whole-server images on top of this.

### Restore

Each server carries `server-restore`. It prints the chosen snapshot's time and the age of the live data, says what a restore would lose, and asks for `RESTORE` to be typed before it changes anything. It checks for disk room, stops the service, and restores into a side directory. It runs the service's own checks there, then swaps the directories and keeps the old one as `*.pre-restore` until Geoff or Claude clears it. Immich originals never change, so they restore in place. For Immich's database it uses the documented command-line restore. Read-only commands use restic's `--no-lock`, which `restore`, `snapshots`, `ls`, and `dump` accept in restic's source, so read-only tokens work.

The second operator runs it from the browser terminal. Two other paths cover worse cases:

- **A server that exists but is broken:** for mail, a Hetzner backup image restored in place from the console. The image is taken from the running server, which Hetzner says can't guarantee consistency, so Stalwart starts from it as after a power cut.
- **A server that is gone:** Hetzner deletes a server's backup images with it, so only R2 is left. Claude or Geoff rebuilds from a workstation: `restore-drill.sh --hold` restores onto a new server, and `scripts/promote.sh` makes that server production (see "Drills"). The second operator can't do this alone, because production secrets render only from Geoff's workstations. His runbook screen for a deleted server says to call Geoff. It also shows how to copy any backup to his own machine with a read-only token and `--no-lock`, so the household's data is never out of reach.

### Drills

A drill server must never act as production or hold a credential to an outside production service. `restore-drill.sh` builds it in the servers' project, labeled `purpose=drill`:

- Its role list is fixed, with no `backup`, `health`, or `cloudflared`, so it never writes to a bucket, posts a heartbeat, or joins the production tunnel. The script refuses to run if any of the three is in the list.
- It renders only what a restore needs: the restic password and the read-only R2 token. No write token, heartbeat token, tunnel token, or Spamhaus key reaches it.
- It runs behind two firewalls in turn. While it restores, with every service stopped, `firewall-drill-restore.json` allows outbound 53, 80, 123, and 443. Before any service starts, `firewall-drill-closed.json` allows outbound DNS only. Hetzner's rules allow traffic and drop the rest once any outbound rule exists, so a restored Stalwart can't send its queue or place an ACME order.
- Checks run over loopback.

A drill passes when `restic check --no-lock` is clean, since the read-only token can't write a lock, and the restored counts match the snapshot's manifest: exactly for media, and within 10 messages per mailbox for mail, since mail can arrive between the count and the stop. For mail, a JMAP login works and the DKIM selector matches. For media, the integrity page shows zero errors, the SHA-256 of three sampled originals matches, and a shared link opens.

Each server gets one drill before go-live. The media drill also proves `restic recover` once, on a copy: during the restore phase it copies the repository's objects to local disk with the read-only token, using `rclone` from Debian's archive, then deletes the copy's `snapshots/` and `index/` and runs `repair index` and `recover` there. `recover` and `repair index` need to write locks, so they can't run against the bucket with that token, and the proof never touches the production bucket. If the disk can't hold both the copy and the restore, the proof runs as its own drill. A server built from a Hetzner image would carry every production secret, so the image path is tested in place on the real mail server during the rehearsal, before MX moves, when nothing depends on it yet. After that, a drill runs twice a year. Before any Stalwart or Immich minor or major upgrade, the upgrade runs on a drill copy of the previous night's backup first, and production follows only if the counts still match. Results go in `docs/restore-drill-log.md`.

`restore-drill.sh` destroys the drill server at the end unless it runs with `--hold`, which builds it in the production Primary IPs' location and leaves it running behind the closed firewall. Promotion is a separate, deliberate step: `scripts/promote.sh HOST SERVER` takes a held drill server that passed and sets the production label and firewall, and turns on delete protection. It powers the server off, unassigns the drill's IPs, and assigns the production Primary IPs, since Hetzner assigns one only to a powered-off server in its own location that holds none of that type. Then it applies the full role list, renders the production secrets from `~/.local/secrets`, sets the host name, and turns on Hetzner Backups for mail. Whether the IPv6 address needs manual network configuration afterwards is unverified, and the first promotion checks it. Claude runs it from a workstation, and only when the production server it replaces is already gone. Replacing a production server that still exists stays with Geoff.

### Archive

`servers-archive` holds the cold copies, under an Indefinite lock that stays until Geoff lifts it:

- The Fastmail Vandelay archives.
- The final PikaPods dump.
- The 1Password export.
- The yearly Proton alias export.
- The final masked-address list, with its triage status.

`scripts/archive.sh` age-encrypts every file to the workstation age key before upload, refuses a file that doesn't start with the age header, and downloads and decrypts the upload before the local plaintext is removed. One plaintext upload could never be deleted, so the check matters.

The workstation age key also goes on paper in the recovery kit, beside the Proton recovery phrase, so every restic password and token survives losing Proton Pass. The age store's ciphertext, `secrets/values.age`, sits in the public `glw907/workstation` repo. The paper key alone therefore decrypts every workstation secret, the full-account Cloudflare token included. By Geoff's ruling the kit is kept locked up at home. The key is written out by hand rather than printed, and the kit is never photographed or scanned.

## Monitoring

The `servers-monitor` Worker runs every five minutes and keeps its state in D1. Each check is enabled when its service goes live, so nothing alerts for a server that doesn't exist yet.

- **Probes:**
  - HTTPS on `photos.907.life/api/server/ping`, Stalwart's `/healthz/live`, and `music.907.life` once dubplate runs.
  - TLS connections to the mail server's 993 and 465. Workers can't open port 25.
- **Heartbeats:** each server's health timer posts every 15 minutes with a per-server token. It reports disk use, failed units, a reboot pending more than two days, the last unattended-upgrade run, certificates good for 14 more days, the last backup and check results, and the media dump's age. The mail server adds the outbound queue's depth and its oldest message's age, and once a night the per-mailbox counts.
- **Backups in R2:** once a day the Worker lists each restic bucket's `snapshots/` objects through an R2 binding, and reads the `config` and `keys/` objects. The packs need no check, because nothing can delete them. A server can't fake this check, since it reads R2 directly. It replaces a backup success heartbeat.
- **Daily inbound probe:** the Worker sends a message to `probe@probe.907.life` through Cloudflare Email Sending. `probe.907.life` points its MX at the mail server, so the probe works through the rehearsal and needs no change at cutover. The mail server's health timer searches every mailbox, Junk included, over JMAP and reports the arrival. That proves the whole inbound path through port 25 from outside.

If Email Sending can't deliver to `probe.907.life`, the fallback is the Stalwart brief's: the health timer confirms that a DMARC aggregate report from Google or Microsoft arrived in the last 48 hours.

### Alerts

The Worker posts to two ntfy topics with unguessable names. Both workstations and the second operator's phone subscribe to the urgent topic; only the workstations subscribe to the routine one.

| Condition | Topic |
|---|---|
| Stalwart's `/healthz/live` or a TLS probe fails twice in a row | urgent |
| The inbound probe isn't confirmed within 60 minutes, including when the mail server can't report | urgent |
| The oldest queued outbound message is over 12 hours old | urgent |
| The oldest queued outbound message is over 2 hours old | routine |
| Media or music fails three probes in a row | routine |
| A heartbeat is missing for 45 minutes | routine |
| A heartbeat reports a problem: disk over 80%, a failed unit, a reboot pending two days, a certificate inside 14 days, a failed backup or check, or a media dump over 26 hours old | routine |
| The newest snapshot is over 36 hours old, a snapshot uploaded in the last 35 days disappears, or `config` or `keys/` changes. Retention never removes a snapshot that young. | routine |
| A mailbox's count, Trash and Junk excluded, drops more than 10% in a day | routine |

Until cutover day, every mail condition goes to the routine topic, because the mail server isn't in production yet and the rehearsal restarts it often. The Worker repeats every open condition every 12 hours, so a workstation that was off still hears about it. Each workstation runs a user service that subscribes and calls `notify-send`. Urgent maps to critical, which shows through Do Not Disturb, and routine to normal, per the calm-desktop rule. No alert travels by email through Stalwart.

### Watching the monitor

Silence must not pass for health. The Worker posts an all-quiet message to the routine topic every 6 hours. The subscriber records it without showing anything, and raises a local notification if none has arrived in 26 hours. That one check covers the Worker's cron, ntfy, and the subscriber itself. On start, the subscriber fetches the messages it missed with ntfy's `since=` parameter. ntfy's default server keeps messages for 12 hours, so a workstation that wakes after a long night still finds a recent all-quiet. ntfy.sh's own setting is unverified, and the 12-hour repeat covers a longer gap.

## Passwords

Proton Pass Family covers Geoff, the second operator, and household members A, B, and C.

### Geoff's account

Two FIDO2 keys as the second factor, never a phone. A paper recovery phrase in the printed recovery kit. Emergency Access set up for the second operator, which requires both people to have a Proton Mail address, so he gets one and keeps his own recovery off 907.life.

### Vaults

- **`Workstation`** holds only the age key. Scripts read it through a 3-month agent token per host, and every read carries a reason.
- **`Servers emergency`** is shared with the second operator. It holds the restic passwords, the read-only R2 restore tokens, `operator2`'s console password, and the Stalwart and Immich admin credentials.

Geoff creates both vaults and the agent tokens in one web-login session with a FIDO2 touch, during Pass 0, and shares `Servers emergency` with the second operator once his Proton account exists. Claude never calls `pass-cli`, so it can't fill the emergency vault itself. It stages the values in a 0600 file under `/dev/shm`, Geoff copies each into the vault, and Claude removes the file. That happens after the media pass and again after the mail pass. Until then, the drills read the same read-only tokens from the age store.

### Workstation wiring

The workstation changes follow the mapping table in the Proton Pass brief, section 3:

- `secret-receive --pass` and the `ws-pass-key` helper for `secret-set.sh` and `sync.sh`.
- The zenity paste dialog for `claude-sudo-setup`.
- `claude-block-pass` in place of `claude-block-op`, and the Proton token pattern in `claude-secret-guard`.
- `check-drift` gains the `pass-cli` version and the token expiry.
- `pass-cli` from Proton's Homebrew tap, pinned.
- Browser policies install the Proton Pass extension in Chromium and Firefox and turn off the built-in password managers.

### Migration order

Three people use 1Password today: Geoff, the second operator, and household member C. Household members A and B join Proton Pass with no 1Password vault to move. The order matters, because the age key lives in 1Password today.

Geoff's move starts in Pass 0 and runs alongside the server passes:

1. Geoff buys the plan, sets up his account with two FIDO2 keys and the paper recovery phrase, and invites the four members. From here on, every new credential goes into Proton Pass, never 1Password.
2. Claude takes a count listing from 1Password and lists every login that holds a passkey. The `op` reads happen once, in one session Geoff approves.
3. Geoff exports 1PUX to `/dev/shm` and imports it in the extension. From the export on, his 1Password is read-only. Geoff runs a count script in his own `pass-cli` session, which prints only per-vault, per-category counts, so Claude never reads a personal vault. Claude compares them with the 1Password listing and records the importer's ignored list. Geoff checks five TOTP codes and opens two attachments. Claude then archives the export through `scripts/archive.sh` and removes the plaintext.
4. In one FIDO2 session Geoff creates the vaults and one agent token per host, and stores each host's token in its keyring with the command the workstation security PR provides. Claude lands that PR (`secret-receive`, `secret-set.sh` and `sync.sh`, the sudo dialog, the guard hooks, and the browser policies) with tests against a scratch store.
5. On each host in turn, Claude clears the cached age key, fetches it through `ws-pass-key` alone, decrypts the age store, and compares the result with `~/.local/secrets`. It also searches the dotfiles for any remaining `op` call. A cached key could otherwise hide a broken Proton path until the next reboot.
6. Geoff re-enrolls each passkey site by site. Passkeys aren't in any 1Password export.

The other two move later, in the passwords pass:

7. The second operator, who created his Proton account in Pass 0, moves his own 1Password data. He's highly technical, so he gets the importer's steps and does the rest himself.
8. Household member C uses no masked addresses, so their move is a plain vault import, with steps written for macOS and iOS.
9. Before cancelling, Claude compares a fresh listing of Geoff's 1Password with his export's change dates and re-carries anything changed since. The second operator and household member C each confirm that autofill works and that their ten most-used logins are present.
10. 1Password is uninstalled from both workstations once step 5 has passed on both. The subscription is cancelled after all three users have moved and a 30-day overlap, through the 1Password packet.

## Claude's operating authority

Unattended runs need permission rules, because the auto-mode classifier blocks a raw `hcloud server create` as a production deploy. The rules name the repo's scripts, not the raw tools:

- `infra/provision.sh --apply` and `scripts/apply.sh <host> --apply`.
- `scripts/restore-drill.sh`, which creates and destroys its own labeled server.
- `cloudflare/dns.sh --apply`, limited to the records the repo declares.
- `cloudflare/r2.sh --apply`, and `cloudflare/deploy.sh monitor|mta-sts`. A rule can't limit `wrangler deploy` to one directory, and a bare rule would reach the site Workers too.
- SSH as `geoff` to the two servers by name. Whether auto mode keeps an SSH allow rule is unverified, and the permission PR tests it.

Production servers and Primary IPs carry Hetzner delete protection, and the API refuses a delete while it is on. The same project token can turn protection off, so this guards against an accident, not against a deliberate misuse of the token: a delete takes two API calls instead of one. Deny rules block raw `hcloud ... delete` and `hcloud ... disable-protection`, and the gate fails if a script in the repo contains `disable-protection`. The servers' own Hetzner project keeps the token away from everything else.

A rebuild wipes the disk, so `provision.sh` rebuilds a production server only after it stops the service, runs a backup, and takes a Hetzner snapshot in the same run. The move to Hetzner US and every upgrade follow the same order.

Deleting a production server, IP, or bucket stays with Geoff. So do Fastmail, PikaPods, and 1Password account closures, and every purchase outside the spend ruling. By that ruling, Claude may run recurring services up to $40 a month in total across Hetzner, R2, and Cloudflare without asking. Any one-time purchase, any new vendor account, and anything that would take the recurring total past $40 comes to Geoff. The rules and guard hooks land in a workstation PR that Geoff approves and merges in Pass 0, before the first unattended run. That PR and the Proton workstation security PR both edit the dotfiles, so they land one after the other.

The runbook's Claude infrastructure section records each of these:

- Every permission rule, deny rule, and guard hook.
- Every secret name and where it's read.
- Which sessions may reach the servers.
- Every Cloudflare token and its scope.

It is updated in the same PR as any change to them.

## Irreversible steps

Each comes to Geoff as its own packet, and each packet cites its evidence for every row:

| Step | Evidence the packet carries |
|---|---|
| Delete the PikaPods pod | The final dump is in `servers-archive` and passed its decrypt round trip. The first media snapshot after cutover passes `restic check --read-data`. The integrity page shows zero errors, the counts match the pod's at the freeze, and the week in "Photos" passed. |
| Delete musicbox and the `music-library` bucket | The library copy restored from restic matches musicbox's SHA-256 sums. No DNS record, tunnel, or Access application points at musicbox. |
| Remove the three other users and 907.life from Fastmail, and downgrade | T+30 is clean. The T+30 contacts and calendar check found nothing left to carry. No service still authenticates to Fastmail's SMTP: Immich and dubplate send through Stalwart. Every masked address and Fastmail-only login on the three accounts has moved, and the Vandelay archives cover all four accounts. The three @907.life masked addresses exist in Stalwart. Removing the domain ends the rollback path. |
| Close Fastmail | The exit rule in "Masked email" has held for 30 days. A final Vandelay pass ran, and the archives pass `vandelay inspect` with matching counts. The final mask list is archived. |
| Cancel 1Password | All three users, Geoff, the second operator, and household member C, have moved and confirmed. The key check in "Passwords" passed on both hosts. Geoff's changes since his export were re-carried, and his ignored list is resolved. |

## The runbook

`docs/runbook.md` has four parts, and `EMERGENCY.md` at the repo root renders the first.

1. **Emergency, for the second operator.** One screen per task, copy-paste commands, the expected output after each, and a stop line:
   - Open the browser terminal.
   - Check whether a service is up, and restart Stalwart, Immich, or dubplate.
   - Free disk space.
   - Unban a client from Stalwart's auto-ban.
   - Restore from backup with `server-restore`, including how to choose a snapshot and what mail since that snapshot is lost.
   - Restore the mail server from a Hetzner image, while the server still exists.
   - If a server is gone: call Geoff, and copy any backup to your own machine with the read-only token if he can't be reached.
   - Who to call.
2. **Operator, for Geoff and Claude.**
   - Provision, apply, rebuild, and upgrade Debian, Docker, Stalwart, and Immich.
   - DNS and rDNS, rotating a key, adding a user, the restore drill, and Stalwart's recovery mode. Changing a restic password removes the old key file, which the `keys/` rule refuses, so that step needs Geoff to lift the rule.
   - Geoff's steps to lift a bucket's lock rule by hand, and Claude's to put it back.
   - Promoting a rebuilt server with `promote.sh`.
   - The change checklist and the move to Hetzner US.
3. **Catalog.** The official documentation for every service, from the server baseline brief's section 8, plus Cloudflare Tunnel, Access, R2 bucket locks, and DMARC Management. The monthly review checks its links.
4. **Claude infrastructure**, as described in "Claude's operating authority".

## What Geoff does

These are the steps only Geoff, or the people he asks, can take. Claude drafts every message to the household.

### Pass 0: attended access

Geoff is present throughout. The pass gathers everything the later passes need, so they run unattended, and new credentials go into Proton Pass, never 1Password:

1. File Hetzner's port 25 limit request in the console. Mail waits on the answer.
2. Make sure the Cloudflare, Hetzner, Proton, GitHub, and Fastmail logins recover through an address that isn't on 907.life. Store their 2FA backup codes offline.
3. Create a Hetzner project for the servers, with an API token made in its console for Claude.
4. Create the scoped Cloudflare tokens Claude lists: DNS for 907.life, one R2 Object Read & Write token per backup bucket, the read-only R2 restore tokens, and the Workers deploy token. Claude's own token can't create tokens.
5. Start your Proton move: buy Proton Pass Family, invite the four members, and set up your account (see "Migration order").
6. Enable SFTP on the PikaPods pod. Update the stale "immich" admin login while you're there.
7. In your own Fastmail login, create an IMAP app password and a DAV app password. Confirm the list of 907.life addresses Fastmail accepts, including any catch-all, and which plan the account is on.
8. Arrange with household members A and B for each to create, in their own Fastmail login, an API token with read access to mail, contacts, and masked email, a DAV app password, and an IMAP app password. Whether a Fastmail admin can create these for another user is unverified, so plan on each member doing it with your help.
9. Invite the second operator to the Hetzner project, and send him Claude's drafted message. It asks him to:
   - Create the same Fastmail token and two app passwords in his own login.
   - Confirm his GitHub username and the email on it.
   - Install the ntfy app on his phone.
   - Create a Proton account with a Proton Mail address, and accept the Family and Emergency Access invites.
   - List his own masked addresses and Fastmail-only logins.
10. Create the GitHub OAuth app for Cloudflare Access, using the callback URL Claude gives you.
11. Sign up for a free Spamhaus DQS key.
12. Create a Gmail and an Outlook.com test account for the delivery tests. Signup captchas stop Claude.
13. Approve and merge the workstation PR with Claude's permission rules and guard hooks.
14. Make the recovery kit, per your ruling: the Proton recovery phrase, and the workstation age key written by hand. Keep it locked up at home, never photographed or scanned, because the key decrypts every workstation secret.

Every credential reaches Claude through `secret-receive`. The pass ends with a dry run: Claude makes one read-only call with each token and app password and reports any that fail, so no later pass stops for a credential.

### Geoff's Proton move, alongside the server passes

- Approve the one `op` read session.
- Export and import 1Password, run the count script, check five TOTP codes and two attachments.
- One FIDO2 session: create the `Workstation` and `Servers emergency` vaults and the agent tokens, share `Servers emergency` with the second operator, and store each host's token.
- Approve the workstation security PR.
- Re-enroll passkeys.
- Add `m.907.life` as a custom domain in the Proton Pass web app, hand over the Info tab's values, and verify `geoff@907.life` as the default mailbox with the code Proton sends.

### Later, each when the plan reaches it

- Lend the plan a household phone for the `photos-new` check and the large upload.
- Copy the staged emergency values into `Servers emergency` after the media pass, and again after the mail pass.
- Arrange one session with a household member's iPhone and Mac for the mail rehearsal's profile test.
- Ask the household to pause photo uploads for the Immich cutover window, and to close Fastmail clients for the mail cutover window.
- Send household member C the drafted steps for their 1Password import, and ask the second operator and member C to confirm autofill and their ten most-used logins.
- Before cutover, share each member's Stalwart password with them through Proton Pass.
- Confirm the mail cutover date.
- Ask household members A and B to install their configuration profiles on cutover day, and every member to turn off Fastmail contacts and calendars on their devices, with Claude's drafted steps.
- At T+30, ask the household to remove the Fastmail account from their devices. Then, in Fastmail's web settings, which have no API: remove the three other users, rename your login if it's on 907.life, remove 907.life, downgrade, and create the masked-mail forward with SRS.
- Work the masked-address list.
- Sit with the second operator for one session while he restarts a service and runs a restore from the runbook.
- Approve each irreversible step in "Irreversible steps", including each backup cleanup, where you lift the `data/` rule yourself.
- Every three months, renew the Proton agent tokens through a web login with a FIDO2 touch.

## Order of work

The plan splits the work into passes in this order. Each pass merges through the normal packet flow.

0. **Attended access.** Everything in "Pass 0" above, with Geoff present, ending in the token dry run. Geoff's own Proton move starts here and runs alongside passes 1 to 5.
1. **Foundation.** The `servers` repo and its gate, the R2 buckets and the archive's lock, and the monitor and MTA-STS Workers. The Access tunnel setup lands with the first server.
2. **Media server.** Provision, harden, install Docker, Caddy, and Immich, and run the Immich rehearsal under `photos-new`. Set up the backup, add the lock rules after the first verified backup, check them with the server's own token, and run the media drill.
3. **Immich cutover and musicbox.** The upload freeze, the move, and a week of watching. The musicbox library copy.
4. **Passwords.** The second operator's and household member C's moves, the members' Proton setup, the start of critical-tier triage on `m.907.life`, and the 1Password packet once all three users have moved. This can run alongside pass 2 or 3.
5. **Mail server.** Measure the three unmeasured mailboxes and check A's and B's accounts for masked addresses, then provision, Stalwart, and DNS preparation. The rehearsal, the client and authentication tests, the mail drill, and then the mail bucket's lock rules after the last rehearsal import. Needs the port 25 approval.
6. **Mail cutover.** On the confirmed date, then the sweeps, the contacts and calendar check, and the T+30 steps.
7. **Wind-down.** Masked-address triage support, Hylki in place of Thunderbird, and the irreversible retirements, each as its own packet.

## Periodic work

A monthly servers review runs in the same session as the monthly model review, from a second committed prompt in the `servers` repo. Where that prompt lives is a placement call the plan settles. The review covers:

- **Hetzner US.** Read US prices and availability. Recommend the move when both servers would cost no more than $10 a month above the EU pair. A move is a rebuild from the repo plus a restore, from a backup taken with Stalwart stopped. The mail server gets new IPs, new PTR records, and a fresh sending reputation, so mail moves on a quiet weekday with the same checks as cutover. The old servers stay stopped for a week, and deleting them comes to Geoff.
- **Upgrades.** Read the Stalwart, Immich, Docker, and Debian release notes and apply the upgrades that matter, after a snapshot and a fresh backup. Minor and major Stalwart and Immich upgrades go through a drill copy first.
- **Health.** Summarize the backup checks and the backup buckets' growth, the blocklist results for the mail IP, and the DMARC reports, and check the catalog's links.

Every three months Geoff renews the Proton agent tokens. Twice a year the review adds a restore drill. Once a year it adds the Proton alias export and the DKIM rotation.

## Risks

- **Microsoft distrusts Hetzner IP ranges.** Direct send depends on a clean IP. The blocklist check, aligned SPF, DKIM, and DMARC, the test sends, the delisting flow, and a fresh Primary IP are the mitigations. The queue-age alert catches a silent block within hours. A relay is the last resort, and "Rulings needed" asks when one may be configured.
- **Hetzner may refuse or delay the port 25 request.** Mail can't cut over until it's approved. "Rulings needed" holds the fallback.
- **Vandelay is five months old.** A silent loss of flags, dates, or bodies would show only in the rehearsal's checks, so the rehearsal checks all three.
- **Stalwart churns.** A weekly patch train is still fixing data-path bugs, and 1.0 brings a schema decision. The version is pinned, every upgrade follows a stopped backup, and minor and major upgrades run on a drill copy first.
- **The mail store can corrupt silently.** It happened to one 0.16 user, whose backups all held the fault by the time anyone noticed. The nightly count check, the daily inbound probe, retention depth, and the Hetzner images are the defenses. The Vandelay migration archives protect only mail from before cutover. The cut line left out a recurring Vandelay layer; the 1.0 upgrade is the moment to revisit that.
- **Backup storage grows.** Nothing prunes automatically under the recommended lock, so the buckets grow by each day's new data at a rate nobody has measured. The monthly review tracks it, and a cleanup packet comes to Geoff at 200 GB. Under the other answer, storage stays small, but a server taken over by an attacker can break every backup.
- **One Cloudflare account holds DNS, backups, monitoring, and operator access.** Account recovery that never runs through 907.life, and offline 2FA codes, are the mitigations. SSH and the Hetzner console work without Cloudflare.
- **The browser terminal rests on a legacy Cloudflare feature.** If Cloudflare retires short-lived certificates, the second operator gets an SSH key on his own machine, and the runbook's first screen changes.
- **Spam filtering starts weak.** Stalwart's filter will be weaker than Fastmail's for the first weeks, while its classifier trains.
- **The masked-address triage can miss a recovery address.** A miss could cost that account after Fastmail closes. Critical services go first, mail to disabled masks is reported, and the 30-day quiet rule guards the close.

## Contestable calls

These are method calls Claude made. Each is flagged because a reasonable reviewer could choose the other way.

- **Stalwart in Docker.** The Stalwart brief preferred a native binary. Docker on host networking keeps one way of running services for the second operator. The logging gap has a documented fix.
- **Push backups.** Servers write to R2 instead of pavilion pulling. Bucket locks replace the no-credential rule, and backups stop depending on pavilion being on.
- **Vandelay archives as the cold copy of Fastmail.** They replace Fastmail's ZIP export, which is 36 manual downloads.
- **A browser terminal for the second operator.** It trades a dependency on Cloudflare and GitHub for no SSH setup on his machine. SSH and the console remain the fallback.
- **A Worker monitor instead of a hosted uptime check.** The cut line named one free uptime check and a dead-man ping. The later alert ruling, with urgent alerts to the second operator's phone, and the inbound mail probe need more than a hosted checker offers, and Cloudflare is core infrastructure by ruling.
- **An MTA-STS Worker.** The cut line allowed MTA-STS only as a one-time record. The policy needs a web host and a `testing` to `enforce` change, and a static Worker is the smallest host that doesn't depend on the mail server.
- **Container checks in CI.** The cut line said linting only. `sshd -t`, `visudo -cf`, and `systemd-analyze verify` in a `debian:13` container catch the mistakes that lock a server out, for seconds of CI time.

## End-to-end check

The initiative is done when all of these hold:

- Fastmail, PikaPods, and 1Password are cancelled, and musicbox is deleted, each through its packet in "Irreversible steps".
- Each of the four mailboxes sends to and receives from the Gmail and Outlook.com test accounts, passing the checks in "Delivery".
- DMARC is at `p=reject`, and the last 14 days of reports show every sender in "Senders of 907.life" passing.
- MTA-STS is at `enforce`, and TLS-RPT reports are arriving at `tls-reports@`.
- No enabled Fastmail mask has a `lastMessageAt` in the last 30 days, and every disabled mask with mail in that window has been reviewed.
- A masked address on `m.907.life`, created at a real service, delivers its verification mail to Stalwart, and a reply through its reverse alias passes DMARC.
- Immich's counts equal the pod's at the freeze, the integrity page shows zero errors, and a household phone uploaded a video of at least 150 MB from outside the house with a matching checksum.
- `apply.sh media --check` passes the dubplate host contract: the `music` user, its directories, the Caddy site, and the trusted-proxy rows.
- Each server passed a drill from R2 against the bar in "Drills", and the drill log records it. The mail server's Hetzner Backups list a restorable image.
- With a server's own token, deleting a pack in `data/`, overwriting `config`, and changing the lock rules each fail, and deleting a file in `locks/` succeeds.
- Each injected fault reached its subscribers: Stalwart stopped (urgent, within 10 minutes), the inbound probe sent to a missing address (urgent), the media health timer stopped (routine, within 45 minutes), and the snapshot check pointed at a scratch bucket whose newest snapshot is two days old (routine). Urgent alerts showed as critical banners on both workstations and arrived on the second operator's phone.
- Every Proton Pass member is signed in, the import counts match, each member confirmed autofill, and every site on the passkey list is re-enrolled.
- On both workstations, `sync.sh` and `secret-set.sh` work through the agent token with the cache cleared, and `check-drift` reports the token's expiry.
- Hylki reads mail, contacts, and calendars from Stalwart, and Thunderbird is gone.
- The media drill rebuilt deleted snapshot and index files on a local copy with `restic recover`, and the mail rehearsal booted the server from a Hetzner image.
- Pass 0's dry run reached every service with every token and app password.
- The second operator has restarted a service and run a restore, using only the runbook and the emergency vault.

## Not checked

Each item is checked in the pass that needs it, and each has a fallback named now:

| Item | Checked in | If it fails |
|---|---|---|
| The sizes of the second operator's, A's, and B's mailboxes | Mail | A CX43 past about 12 GB of raw mail; if no CX43 is in stock within the seven-day retry, the pass reports to Geoff |
| Whether the `music-library` bucket holds the whole library | Media | The restic copy from musicbox is the record either way |
| Whether DMARC Management's reports are readable through the API | Mail | Read `dmarc-reports@` over JMAP |
| Whether Email Sending delivers to `probe.907.life` | Mail | The DMARC-report check in "Monitoring" |
| Which email GitHub hands to Access | Media | The second operator's Unix name follows whatever it is |
| Whether Family members can use `m.907.life` | Passwords | Members use Proton's own alias domains |
| Whether a Fastmail admin can create tokens and app passwords for another user | Pass 0 | Each member creates their own, arranged by Geoff |
| Which Fastmail plan the account is on today | Pass 0 | The T+30 packet names the plan Geoff downgrades from |
| Apple profile details for Stalwart, including the password prompt | Mail rehearsal | Manual account setup on each device |
| Hylki's service discovery | Mail rehearsal | Manual server settings |
| Whether five-minute TLS probes count as loitering for auto-ban | Mail rehearsal | Drop the 993 and 465 probes; `/healthz/live` and the inbound probe remain |
| Whether auto mode keeps an SSH allow rule | Foundation | Name each SSH command the scripts run |
| How long ntfy.sh keeps messages | Foundation | The 12-hour repeat covers a gap |
| Whether an uncompressed Immich dump deduplicates better | Media | Keep the gzipped dump and its growth |

The fold record, [2026-10-17-self-hosting-design-fold.md](../research/2026-10-17-self-hosting-design-fold.md), lists what was checked for this revision and how.
