# Debian 13 server baseline on Hetzner Cloud, provisioned from code (2026-10-17)

Scope: the shared base and the repo shape for two servers, a mail box (Stalwart) and a media box (Immich in Docker, dubplate as a systemd binary). Stalwart, Immich, and backup internals belong to other briefs. Claims carry a link. "Unverified" marks anything I could not confirm from a primary source.

Method note: prices, server-type availability, and image data below come from a read-only call to the Hetzner Cloud API with the existing token (GET only, nothing created). Docs were fetched from the official sites. I could not SSH anywhere, so the contents of the Hetzner Debian image are unverified.

## 1. Debian 13 status

- The current release is 13.7, published 2026-09-12. Debian 13.0 shipped on 2025-08-09. Support runs three years of full support to 2028-08-09, then LTS to 2030-06-30 ([Debian trixie page](https://www.debian.org/releases/trixie/), [Debian news](https://www.debian.org/News/)). Point releases landed roughly every two months (13.4 in March, 13.5 in May, 13.6 in July, 13.7 in September).
- Hetzner offers an image named `debian-13` for x86 and arm (API image list, `os_version` 13, base image dated 2025-08-18, not deprecated). The image's creation date is from August 2025, so expect the first `apt full-upgrade` to pull a large delta (inference).
- Versions in trixie that matter here (Debian source tracker): systemd 257.13, OpenSSH 10.0p1, Linux 6.12, nftables 1.1.3, cloud-init 25.1.4, fail2ban 1.1.0, needrestart 3.11, restic 0.18.0, Debian's docker.io 26.1.5, docker-compose 2.26.1, Caddy 2.6.2, rclone 1.60.1 ([release notes, what's new](https://www.debian.org/releases/trixie/release-notes/whats-new.en.html), [sources.debian.org](https://sources.debian.org/)).
- Server-relevant trixie changes, from the [release notes issues page](https://www.debian.org/releases/trixie/release-notes/issues.en.html):
  - `/tmp` is a tmpfs by default, sized up to 50% of RAM, and `/tmp` and `/var/tmp` are cleaned regularly. Mask `tmp.mount` to revert. On the 8 GB media box this means a large ffmpeg or upload scratch file in `/tmp` spends RAM. dubplate stages under `/srv/music/staging`, so it is not exposed; check any Immich or script scratch use.
  - OpenSSH no longer reads `~/.pam_environment` and rejects DSA keys outright (9.8 and later). Irrelevant to ed25519 keys.
  - `last`, `lastb`, and `lastlog` are replaced by 2038-safe tools. Do not script against `/var/log/lastlog`.
  - All architectures except i386 use 64-bit `time_t`.
- sshd on trixie: `PermitRootLogin` defaults to `prohibit-password`, `PerSourcePenalties` is on by default (15 s minimum, 10 min maximum penalty), and `Include /etc/ssh/sshd_config.d/*.conf` sits at the top with first-value-wins, so a drop-in named `10-*.conf` beats the packaged file ([sshd_config(5) for trixie](https://manpages.debian.org/trixie/openssh-server/sshd_config.5.en.html), [OpenSSH 9.8 notes](https://www.openssh.org/txt/release-9.8)). The built-in penalties cover most of what fail2ban does for sshd.
- apt sources in deb822 format (`/etc/apt/sources.list.d/debian.sources`) is the trixie installer default as I understand it. Unverified for the Hetzner image; the scripts should not assume either form and should write only to `sources.list.d/*.sources` for third-party repos, which is also the format Docker's install page now uses ([Docker on Debian](https://docs.docker.com/engine/install/debian/)).
- nftables: Debian ships the `nftables` package, and `iptables` is a nft-backed compatibility layer. Docker works only with `iptables-nft` or `iptables-legacy` and states that rules made with `nft` are not supported alongside Docker ([Docker on Debian](https://docs.docker.com/engine/install/debian/)). Whether the Hetzner image has any host firewall active is unverified; assume none.

## 2. Provision-from-code options

Evidence from dubplate today: `scripts/provision.sh` does check-before-create with `hcloud` for the SSH key, firewall, volume, and server; `cloud-init/user-data.yaml` does first-boot only; `scripts/deploy.sh` is a 444-line idempotent `--check`/`--apply` script that renders `/etc/dubplate/server.env` from a template plus the workstation age store and pipes it over SSH without touching local disk; the gate runs shellcheck. `hcloud` is not installed on this workstation right now (the script says `brew install hcloud`); the current release is v1.70.1 ([hcloud releases](https://github.com/hetznercloud/cli/releases)).

| Option | For | Against |
|---|---|---|
| cloud-init alone | One file, no tools | Runs once at first boot, never converges a live box (the vps-conventions rule). Drift is invisible. |
| cloud-init plus idempotent shell and hcloud | Already built and gated in dubplate. Plain files, reviewable diffs, `--check` mode. No new tool to upgrade. | Hand-rolled idempotence; grows clumsy past about 1,000 lines. |
| Ansible | Native `--check --diff`, mature idempotent modules | A Python tool and inventory for two hosts. Another dependency track. |
| OpenTofu with the hcloud provider (v1.70.0, [provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)) | Declarative servers, firewalls, primary IPs; `plan` shows drift | State file holds user-data and IDs and must live somewhere that is itself backed up, which defeats "restorable from the repo alone." Importing musicbox adds work. Does not configure the OS. |
| NixOS | Whole-host declarative | Out of scope: Geoff chose Debian. |

Recommendation: cloud-init for the 30 lines that must exist before SSH works, plus idempotent `bash` scripts for everything else, plus `hcloud` for infrastructure. The new piece is a rule: **rebuild is the converge path for the OS, and `apply.sh` is the converge path for config.** `hcloud server rebuild` accepts `--user-data-from-file` ([CLI manual](https://github.com/hetznercloud/cli/blob/main/docs/reference/manual/hcloud_server_rebuild.md)), so a rebuild plus `apply.sh` plus a restore reproduces a host from the repo and the backup alone. The cloud-init file stays tiny and rarely changes, so the "package added to cloud-init never reaches live boxes" trap shrinks to almost nothing. If the scripts pass roughly 1,000 lines, move the host configuration (not the hcloud part) to Ansible; the tree below does not block that.

## 3. Security baseline

**Accounts and SSH.**
- Users: `geoff` (full sudo) and `operator2` (own ed25519 key, restricted sudo). Public keys live in the repo (public keys are safe to commit). No shared key.
- The second operator's sudoers file lists exact commands only: `systemctl restart|status` for named units, `journalctl`, and a `server-restore` wrapper from the repo. This gives him the emergency actions without a general root shell. Geoff decides whether the second operator gets full sudo instead (see questions).
- Root: `PermitRootLogin no` after cloud-init has made the two users. The recovery path for a lost user is Hetzner rescue mode ([rescue system](https://docs.hetzner.com/cloud/servers/getting-started/rescue-system/)).
- sshd drop-in `10-hardening.conf`: `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, `PermitRootLogin no`, `AllowGroups ssh-users`, `MaxAuthTries 3`, `X11Forwarding no`. Check with `sshd -t` in a `debian:13` container in CI.
- Always attach an SSH key at create. dubplate hit Hetzner's forced-expiry root password when a server was created without a key; the `chage` guard in its cloud-init was the fix. Carry it over.
- A backup account for pavilion's pull: a `backup` user with a `restrict,command=` key, defined once the backups brief fixes the mechanism. The base only reserves the account.

**Firewall: Hetzner Cloud Firewall is the enforced layer; no host firewall on the media box.**
- The Cloud Firewall is free, denies all inbound once attached, allows all outbound, holds up to 500 rules, and attaches by label ([Firewalls overview](https://docs.hetzner.com/cloud/firewalls/overview/)). It is enforced outside the VM (my understanding; the docs page does not say so), which means Docker's iptables rules cannot bypass it.
- Docker is the problem on the media box: published ports bypass ufw and firewalld, and Docker's nftables backend is experimental since 29.0.0 with no `DOCKER-USER` chain ([packet filtering](https://docs.docker.com/engine/network/packet-filtering-firewalls/), [nftables](https://docs.docker.com/engine/network/firewall-nftables/)). Two layers on that box would mean two rule sets to keep in step and a lockout risk. Rule: the Cloud Firewall decides what the internet reaches, and every Docker `ports:` line binds `127.0.0.1` (Immich's stock compose publishes `2283:2283` on all interfaces, [docker-compose.yml](https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml)).
- Mail box inbound: 22, 25, 80 (ACME HTTP-01, unless Stalwart uses DNS-01), 443, 465, 587, 993, ICMP. Add 4190 only if a client needs ManageSieve. Media box: 22, 80, 443, ICMP.
- SSH from anywhere with keys only. dubplate restricted tcp/22 to `FIREWALL_SSH_CIDRS` and documented an API workaround for a rotated home IP. For a household where the second operator also connects, an IP allowlist is a lockout risk larger than the scanning noise it removes, and sshd's built-in penalties handle the noise. Contestable; the allowlist is one line to add back.
- Outbound 25 and 465 are blocked on every Cloud server until a limit request, available "once you have been with us for a month and paid your first invoice"; 587 is open ([Servers FAQ](https://docs.hetzner.com/cloud/servers/faq/)). The account is old enough. The request is made in the console ([limits page](https://console.hetzner.com/limits), login required). File it first, since the response time is unknown and Stalwart cannot deliver to other MTAs without it.

**Patching.**
- `unattended-upgrades` 2.12 is in trixie. Its default origins already include the stable pocket and the security pocket, so point-release fixes install automatically too. `Automatic-Reboot` defaults to false and `Automatic-Reboot-Time` is commented out ([50unattended-upgrades.Debian](https://sources.debian.org/data/main/u/unattended-upgrades/2.12/data/50unattended-upgrades.Debian), [UnattendedUpgrades wiki](https://wiki.debian.org/UnattendedUpgrades)). `20auto-upgrades` enables the daily run.
- Drop-in `52unattended-upgrades-local`: `Automatic-Reboot "true"`, `Automatic-Reboot-WithUsers "false"`, `Automatic-Reboot-Time "12:00"` (UTC; about 04:00 Alaska time, off-hours for both users). Reboot only happens when `/run/reboot-required` exists.
- `needrestart` 3.11: in non-interactive runs an interactive setting falls back to list-only ([man page](https://manpages.debian.org/trixie/needrestart/needrestart.1.en.html)), so set automatic mode (`$nrconf{restart} = 'a'`) so services pick up library updates without a reboot. Which services to exclude is a choice for the mail box; a Stalwart restart is a seconds-long SMTP deferral, which senders retry.
- Add Docker's repo origin to the allowed origins on the media box if Docker CE is chosen, otherwise Docker never auto-updates.

**Other items.**
- fail2ban 1.1.0 is available. Stalwart has built-in auto-ban for auth failures, relay and RCPT probing, loitering, and port scanning, covering IMAP, JMAP, SMTP, and ManageSieve, with default thresholds per day and bans that stay until deleted unless a period is set ([auto-ban](https://stalw.art/docs/server/auto-ban)). Recommendation: no fail2ban on the mail box (one banning system, one place to unban), none on the media box (key-only SSH plus sshd penalties; Caddy and Immich auth have their own limits).
- Time sync: use `chrony` (4.6.1 in trixie) on both. Hetzner documents NTP servers `ntp1.hetzner.de`, `ntp2.hetzner.com`, `ntp3.hetzner.net` on its dedicated-server page ([NTP](https://docs.hetzner.com/robot/dedicated-server/security/ntp-servers)); whether Cloud images preconfigure them is unverified. Mail needs correct time for DKIM and TLS.
- journald: drop-in with `Storage=persistent`, `SystemMaxUse=500M`, `MaxRetentionSec=1month` ([journald.conf(5)](https://manpages.debian.org/trixie/systemd/journald.conf.5.en.html)). Do not rely on `/var/log/syslog`.
- AppArmor is the Debian default. Install `apparmor` and `apparmor-utils` explicitly if absent (unverified for the image). No SELinux relabel reboot, which removes the `power_state` reboot dance dubplate needed on AlmaLinux. Stalwart and dubplate run unconfined under systemd sandboxing unless a profile is written; systemd hardening (`NoNewPrivileges`, `ProtectSystem=strict`) does the work.
- Minimal packages: `unattended-upgrades apt-listchanges needrestart chrony apparmor sudo curl ca-certificates jq rsync` plus per-role extras. Remove nothing; verify packages exist before they enter a first-boot script with `podman run --rm debian:13 apt-cache policy <pkg>`.

**What carries over from `vps-conventions`.** Directory lifetimes (RuntimeDirectory vs StateDirectory), per-unit hardening, pre-created `ReadWritePaths`, path-unit backstop timers, "cloud-init runs once", idempotent deploys with `--check`, `systemd-analyze verify` in the gate, and pin-and-checksum for anything piped to a root shell. **What changes:** `dnf`/`dnf-automatic` becomes `apt`/`unattended-upgrades`; SELinux, `restorecon`, `var_lib_t` and the autorelabel reboot disappear; EPEL and RPM Fusion disappear because `ffmpeg` and `flac` are in Debian main (rclone 1.60.1 there is old; dubplate needs it for R2, so pin an upstream build or accept it); the "prove the package exists" container check uses `debian:13`; `tmp.mount` is a new thing to know. The skill's description names AlmaLinux and should gain a Debian line.

## 4. Docker on Debian 13 (media box only)

- Debian's `docker.io` is 26.1.5 and Docker's current engine tag is 29.9.1 ([moby releases](https://github.com/moby/moby/releases)). Docker's own apt repo lists "Debian Trixie 13 (stable)" as supported and uses a deb822 `docker.sources` file ([install page](https://docs.docker.com/engine/install/debian/)). Immich requires the Docker Compose plugin and publishes 6 GB RAM minimum, 8 GB recommended ([requirements](https://docs.immich.app/install/requirements/)).
- Recommendation: Docker's official repo (docker-ce, containerd.io, compose plugin), pinned to the repo with the origin added to unattended-upgrades. Reasons: Immich tracks current Docker and its support answers assume it; the stock Debian package is three majors behind and has no nftables backend. Counter-argument for Debian's package: Debian's security team backports fixes and nothing outside Debian's archive is trusted. Both are defensible; this is a method call, flagged as contestable.
- Rootless Docker: not recommended. It needs `uidmap`, subordinate ID ranges, and lingering, and does not start at boot without `loginctl enable-linger` ([rootless](https://docs.docker.com/engine/security/rootless/)). For a single-purpose host whose containers are Immich's stock set, the added moving parts cost more than they protect. Constrain with loopback binds, `no-new-privileges`, and a non-root container user where the image allows.
- Log rotation: the `json-file` driver defaults to unlimited size ([json-file](https://docs.docker.com/engine/logging/drivers/json-file/)). Set `/etc/docker/daemon.json` with `log-driver json-file`, `max-size 10m`, `max-file 3` before the first container starts (it applies only to new containers).
- After any compose network change, force-recreate (the dubplate lesson from 2026-09-01 in vps-conventions).
- Mail box: no Docker. Run Stalwart as a native binary under a hardened systemd unit (the Stalwart brief decides the install route). One fewer daemon and no firewall-bypass class of bug on the highest-risk host.
- Proxy: Caddy 2.6.2 in trixie is old; use Caddy's own apt repo for 2.11.x ([install](https://caddyserver.com/docs/install)) or the Docker image, and let it hold TLS on the media box. Cloudflare's free and Pro proxy limits uploads to 100 MB ([413 article](https://developers.cloudflare.com/support/troubleshooting/http-status-codes/4xx-client-error/error-413/)). photos.907.life is a proxied record today, and the 92 videos include files that may exceed that. Plan on a DNS-only record for the Immich host (finding for the Immich brief; the firewall then opens 80 and 443 to the world).

## 5. Server repo structure

Proposed name `servers`. Principles: shared base, per-host roles, one runbook, no secrets, everything checked by CI.

```
servers/
  README.md                 what this is; links the runbook; how to start
  docs/
    runbook.md              Part 1 emergency (the second operator), Part 2 operator, Part 3 catalog
    restore-drill-log.md    dated results of every restore drill
    decisions.md            short ruling log (why Debian, why no fail2ban, why this location)
  infra/
    project.env             names, server types, locations (non-secret)
    firewall-mail.json
    firewall-media.json
    provision.sh            check-before-create via hcloud; --check/--apply; protection on
  base/
    cloud-init.yaml         users, keys, sshd drop-in, hostname; nothing else
    keys/                   geoff.pub, operator2.pub, pavilion-backup.pub
    install.sh              idempotent: apt packages, unattended-upgrades, chrony, journald, sudoers
    files/                  etc/ssh/sshd_config.d/10-hardening.conf and friends
  roles/
    stalwart/               unit, install.sh, config templates
    docker/                 daemon.json, install.sh
    immich/                 compose.yml, .env.tmpl, install.sh
    dubplate/               host-side only: user, dirs, volume mount; the binary deploys from dubplate's own deploy.sh
    caddy/                  Caddyfile
    health/                 heartbeat script and timer
  hosts/
    mail/    host.env  cloud-init.yaml (base + host extras)  roles.txt
    media/   host.env  cloud-init.yaml  roles.txt
  secrets/
    templates/              *.env.tmpl with bare NAME= rows, as dubplate does
    render.sh               resolves rows from ~/.local/secrets, ships over ssh stdin to install -m 0600
  monitor/
    worker/                 Cloudflare Worker cron probe and wrangler.jsonc
  scripts/
    apply.sh                apply.sh HOST [--check|--apply]: rsync base+roles, run install.sh remotely
    check.sh                the repo gate
    restore-drill.sh        scripted drill against a throwaway server
  .github/workflows/check.yml
```

**Runbook.** One file, three parts, in this order:
1. **Emergency (the second operator).** Copy-paste commands only, one screen per task: log in, "is it up?", restart Stalwart, restart Immich, restart dubplate, what to do when the disk is full, restore from backup (plug in the USB drive, unlock, one command), and who to call. Plain numbered steps, expected output after each step, and a stop line ("if this does not match, stop and call Geoff"). Put `EMERGENCY.md` at the repo root as a rendered copy of Part 1 so it survives a runbook restructure, and print it. A runbook that lives only on a server that is down helps no one.
2. **Operator (Geoff).** Provision, apply, rebuild, rotate a key, add a user, upgrade Debian, upgrade Immich or Stalwart, DNS and rDNS, the restore drill, and a change checklist.
3. **Catalog.** Official docs per service (section 8).

**Secrets.** Nothing in git except public keys and `bare NAME=` templates. Mirror dubplate's mechanism: `render.sh` sources `~/.local/secrets` (exported from the workstation age store), fills the template in memory, and streams it through `ssh host 'install -m 0600 -o root ...'`; a `--check` mode compares and prints only "differs." The age key's source moves from 1Password to Proton Pass in the initiative, but the interface (`~/.local/secrets`) stays, so this repo does not change when that happens. `HCLOUD_TOKEN` is already in the store. New long-lived secrets (Stalwart admin credential, any restic repo password stays on pavilion) go through `secret-set.sh`, not loose files.

**CI checks** (the gate and the GitHub workflow run the same `check.sh`):
- `shellcheck` and `shfmt -d` on all scripts; `yamllint`; `jq empty` on firewall JSON.
- `cloud-init schema -c file --annotate` on each rendered cloud-init ([cloud-init CLI](https://docs.cloud-init.io/en/latest/reference/cli.html)). The docs do not document exit codes for `schema`; verify the non-zero-on-error behavior once locally before relying on it.
- In a `debian:13` container: `sshd -t` on the drop-ins, `apt-get -s install` for every package list, `systemd-analyze verify` on units (with the caveat in vps-conventions about missing binaries), `visudo -cf` on sudoers files, `docker compose config` on the Immich compose file.
- `gitleaks` over the tree; Vale on `docs/` with the repo voice.
- Scheduled weekly, non-blocking: a link check of the catalog (lychee) and a `hcloud` drift report (`provision.sh --check`).

## 6. Monitoring for a household

- **External probe.** A Cloudflare Worker with a cron trigger, in `monitor/`. Free plan: five cron triggers per account, 10 ms CPU per cron run, 50 subrequests ([limits](https://developers.cloudflare.com/workers/platform/limits/)). It does an HTTPS fetch of each service and a TCP `connect()` to 993 and 587 on the mail box. Workers cannot open outbound TCP on port 25 and cannot connect to Cloudflare IP ranges ([TCP sockets](https://developers.cloudflare.com/workers/runtime-apis/tcp-sockets/)), so port 25 is not probed from outside; probe 587 and 993 and let Stalwart's own logs speak for 25. Whether `connect()` is allowed on the Free plan is not stated on the docs page; unverified. Fallback: UptimeRobot's free plan has 50 monitors at 5-minute intervals ([pricing](https://uptimerobot.com/pricing/)), with port monitors on the free tier unverified.
- **Dead-man switch.** Each server runs a `health.timer` every 15 minutes: disk below 80%, no failed units, no pending reboot older than two days, last unattended-upgrade within 3 days. It pings healthchecks.io on success and `/fail` on a problem. The free Hobbyist plan has 20 checks ([pricing](https://healthchecks.io/pricing/)). The same service holds a check for pavilion's backup timer, which is how a stale backup becomes an alert (pavilion is not always on, so use a generous grace period). No SMART exists on a VM; disk-full, journal errors, and the filesystem read-only flag are the equivalents.
- **Routing.** Never route a mail-outage alert through the mail server. Use push via ntfy (the Android, iOS, and F-Droid apps are listed on the [ntfy docs](https://docs.ntfy.sh/); topic names are public, so use an unguessable one, or self-host later). Calm-desktop mapping: mail unreachable for two consecutive checks is the only urgent-priority alert; media down, disk above 80%, and certificate expiring in 14 days are default priority with no sound; backup-stale and pending-reboot are a weekly digest and a normal-urgency desktop notification on pavilion. Who receives each is a question below.

## 7. Hetzner specifics (prices from the Cloud API for this account, USD, net, as of 2026-10-17)

Hetzner raised cloud prices on 2026-04-01 and again on 2026-06-15 for new orders and rescales, and the new price list is on the [price adjustment page](https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/). The picture changed a lot from the CX22/CPX21 era.

| Type | Spec | Price/mo | Where it is orderable today |
|---|---|---|---|
| cx23 | 2 vCPU, 4 GB, 40 GB | $6.49 | `hel1` only (fsn1, nbg1 show unavailable) |
| cx33 | 4 vCPU, 8 GB, 80 GB | $9.99 | unavailable in all EU locations |
| cax21 (Arm) | 4 vCPU, 8 GB, 80 GB | $12.49 | unavailable in all EU locations |
| cpx22 (EU) | 2 vCPU, 4 GB, 80 GB | $22.99 | fsn1, nbg1, hel1 |
| cpx32 (EU) | 4 vCPU, 8 GB, 160 GB | $41.99 | fsn1, nbg1, hel1 |
| cpx11 (US) | 2 vCPU, 2 GB, 40 GB | $20.49 | ash, hil |
| cpx21 (US) | 3 vCPU, 4 GB, 80 GB | $37.49 | ash, hil |
| cpx31 (US) | 4 vCPU, 8 GB, 160 GB | $73.49 | ash, hil |

- The old CX22 is now `cx23`. Availability flags are live capacity, so they will change; `provision.sh` must read `hcloud server-type list` and fail with a clear message rather than assume. The datacenters endpoint was removed in June 2026 ([API changelog](https://docs.hetzner.cloud/changelog)), so use `--location`.
- The US locations carry only the shared CPX line (and CCX dedicated), at three to six times the EU price for the same RAM, and include 1 to 3 TB of traffic against 20 TB in the EU. EU locations are fsn1, nbg1, hel1; the US ones are ash (Ashburn) and hil (Hillsboro) ([locations](https://docs.hetzner.com/cloud/general/locations/)).
- IPv4 is $0.60/mo per primary IP ([Primary IPs](https://docs.hetzner.com/cloud/servers/primary-ips/overview/)); IPv6 is free. Volumes are $0.0767/GB/mo (10 GB to 10 TB, one server at a time, not included in server backups or snapshots, [Volumes](https://docs.hetzner.com/cloud/volumes/overview/)). Server backups are 20% of the server price, seven rolling daily slots; snapshots are $0.0199/GB/mo, never auto-deleted ([Backups and snapshots](https://docs.hetzner.com/cloud/servers/backups-snapshots/overview/)).

Monthly cost for plausible pairings (server plus IPv4, plus a 100 GB media volume at $7.67):

| Pairing | Mail | Media | Total |
|---|---|---|---|
| All EU | cx23 hel1, $7.09 | cpx32, $42.59 | about $57 |
| Mixed | cx23 hel1, $7.09 | cpx31 hil, $74.09 | about $89 |
| All US | cpx11, $21.09 | cpx31, $74.09 | about $103 |

musicbox's current price is not shown by the API call (the price list applies to new orders); treat the budget jump as real.

- **Latency** from Alaska to Helsinki versus Hillsboro is a guess I cannot source: Helsinki is probably several times the round-trip of Hillsboro. IMAP/JMAP and a photo grid tolerate it; interactive music browsing in dubplate may not. Test with a short-lived server before committing. Unverified.
- **Primary IPs that outlive the server.** The API shows musicbox's primary IPs have `auto_delete: true`, so deleting the server deletes the IP. Create each IP first with `hcloud primary-ip create --type ipv4 --auto-delete=false --enable-protection delete --location ...`, attach it with `server create --primary-ipv4`, and `server rebuild` keeps the server and its IPs anyway ([CLI manual](https://github.com/hetznercloud/cli/blob/main/docs/reference/manual/hcloud_primary-ip_create.md)). A standalone IP also lets Geoff check it against blocklists before use and roll to another if it is listed (advice, not a Hetzner feature).
- **rDNS.** Set per IP, from the API or `hcloud primary-ip set-rdns --hostname mail.907.life <ip>` (IPv6 with `--ip`). Hetzner wants the name to resolve forward to the same IP, allows one PTR per IP, and ignores PTR records in your own zone ([rDNS](https://docs.hetzner.com/dns-console/dns/general/reverse-dns/)). Set both IPv4 and IPv6 and match the HELO name.
- **Backups and snapshots versus the USB drive.** Hetzner Backups cost $1.30/mo on cx23 and $8.40/mo on cpx32. They skip volumes. For the mail box (no volume) they are a daily second copy with a whole-server restore for about $1.30. For the media box they would cover only the OS disk, which the repo already rebuilds, so skip them there; take a manual snapshot before an OS or Immich major upgrade ($0.0199/GB for a few days). The mail case is a real finding against "USB is the only copy": between pavilion pulls, new mail exists only on the mail box, and pavilion is not always on. See questions.
- **Volumes** make sense for the media data: they survive `server rebuild` and carry delete protection. Immich's database stays on local NVMe (my reading of Immich's guidance against network-backed databases; the Immich brief owns that). Local disks (160 GB) would also hold 19 GB of photos plus 6.6 GB of music; the volume is for lifetime, not capacity.

## 8. Documentation catalog

Every URL below returned HTTP 200 on 2026-10-17 from `curl -L`, except where marked. Pages behind anti-bot checks are listed as "unverifiable by curl."

**Debian 13**
- Release notes: https://www.debian.org/releases/trixie/release-notes/
- Debian Administrator's Handbook: https://www.debian.org/doc/manuals/debian-handbook/
- Debian Reference: https://www.debian.org/doc/manuals/debian-reference/
- Security information and FAQ: https://www.debian.org/security/ and https://www.debian.org/security/faq
- Unattended upgrades: https://wiki.debian.org/UnattendedUpgrades (unverifiable by curl: anti-bot challenge; fetched by the research tool)
- Debian man pages for trixie: https://manpages.debian.org/trixie/ (sshd_config, journald.conf, needrestart pages verified)
- The old "Securing Debian Manual" URLs now return 404; use the Handbook's security chapter.

**Hetzner Cloud**
- Docs: https://docs.hetzner.com/cloud/
- Servers FAQ (port 25/465 block): https://docs.hetzner.com/cloud/servers/faq/
- Firewalls: https://docs.hetzner.com/cloud/firewalls/overview/
- Primary IPs: https://docs.hetzner.com/cloud/servers/primary-ips/overview/
- Reverse DNS: https://docs.hetzner.com/dns-console/dns/general/reverse-dns/
- Backups and snapshots: https://docs.hetzner.com/cloud/servers/backups-snapshots/overview/
- Volumes: https://docs.hetzner.com/cloud/volumes/overview/
- Rescue system: https://docs.hetzner.com/cloud/servers/getting-started/rescue-system/
- Price adjustment: https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/
- API reference and changelog: https://docs.hetzner.cloud/reference/cloud and https://docs.hetzner.cloud/changelog
- API token: https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/
- `hcloud` CLI: https://github.com/hetznercloud/cli
- Limit requests: https://console.hetzner.com/limits (returns 200 but needs a login; no public doc page found, the FAQ above describes the process)
- Cloud config tutorial: https://community.hetzner.com/tutorials/basic-cloud-config
- Terraform provider (reference only): https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

**Docker**
- Install on Debian: https://docs.docker.com/engine/install/debian/
- Packet filtering and firewalls: https://docs.docker.com/engine/network/packet-filtering-firewalls/
- nftables: https://docs.docker.com/engine/network/firewall-nftables/
- json-file logging: https://docs.docker.com/engine/logging/drivers/json-file/
- Rootless: https://docs.docker.com/engine/security/rootless/
- Compose: https://docs.docker.com/compose/

**Others**
- Caddy: https://caddyserver.com/docs/ and https://caddyserver.com/docs/install
- restic: https://restic.readthedocs.io/en/stable/ (scripting: https://restic.readthedocs.io/en/stable/075_scripting.html)
- Stalwart: https://stalw.art/docs/ (auto-ban: https://stalw.art/docs/server/auto-ban; docker install: https://stalw.art/docs/install/platform/docker/)
- Immich: https://docs.immich.app/overview/quick-start/ (requirements: https://docs.immich.app/install/requirements/; backup and restore: https://docs.immich.app/administration/backup-and-restore/; upgrading: https://docs.immich.app/install/upgrading/; reverse proxy: https://docs.immich.app/administration/reverse-proxy/)
- Proton Pass: https://proton.me/pass and https://proton.me/support/pass; `pass-cli`: https://protonpass.github.io/pass-cli/ and https://github.com/protonpass/pass-cli. The `commands/run/` guess returned 404; read the overview's navigation for current paths. I did not verify the pass-cli claims in the context file (agent-reason, personal access tokens); that is another brief's job.
- Cloudflare DNS: https://developers.cloudflare.com/dns/ (records: https://developers.cloudflare.com/dns/manage-dns-records/; API: https://developers.cloudflare.com/api/resources/dns/); Workers cron: https://developers.cloudflare.com/workers/configuration/cron-triggers/
- Fastmail export ("Download all your data"): https://www.fastmail.help/hc/en-us/articles/360060590573. Mail exports are one folder at a time and capped at 4 GB each; contacts export as vCard, CSV, or LDIF; calendars as .ics (per the search summary of that article and its sibling pages). Contacts: https://www.fastmail.help/hc/en-us/articles/1500000280061
- Hylki: https://hylki.app/ and https://github.com/hyprlab/hylki (formerly Vireo, Rust and libadwaita; IMAP, POP3, JMAP per [OMG Ubuntu](https://www.omgubuntu.co.uk/2026/10/hylki-email-client-for-gnome))
- cloud-init: https://docs.cloud-init.io/en/latest/ (CLI: https://docs.cloud-init.io/en/latest/reference/cli.html). The old readthedocs howto path for schema validation is a 404.
- Monitoring: https://healthchecks.io/docs/ , https://docs.ntfy.sh/ , https://uptimerobot.com/pricing/

## Recommendation

1. Debian 13.7 on both, image `debian-13`. Use cloud-init for users, keys, sshd, and nothing else; use idempotent scripts plus `hcloud` for the rest. Rebuild is the OS converge path.
2. Cloud Firewall is the single enforced firewall on both hosts. Docker binds loopback only. Key-only SSH from anywhere, `geoff` and `operator2` as separate users, root login off.
3. `unattended-upgrades` with automatic reboot at 12:00 UTC, `needrestart` in automatic mode, `chrony`, persistent journald with a cap. No fail2ban.
4. Docker CE from Docker's repo on the media box only; no Docker on the mail box; no rootless.
5. Explicit primary IPs created first with auto-delete off and delete protection, rDNS set for IPv4 and IPv6, blocklist check before attach. File the port-25/465 limit request now.
6. Hetzner Backups on the mail box (about $1.30/mo) as a second daily copy; none on the media box. Volume for media data with delete protection.
7. Worker cron probe plus healthchecks.io plus ntfy push, with only mail-unreachable at urgent priority.
8. One `servers` repo with the tree above; runbook Part 1 is the second operator's emergency card, mirrored to `EMERGENCY.md`.

## Risks

- **Price and capacity.** Cost-optimized EU types are nearly sold out (cx33 and the Arm plans show unavailable everywhere; cx23 only in hel1), and US prices are three to six times higher. A plan built on cx33 at $9.99 may not be orderable on provisioning day.
- **Mail IP reputation and the port-25 limit request.** Unknown turnaround and a new IP's deliverability are the largest external dependencies. A fallback is a smarthost on 587 for outbound, which weakens "self-hosted."
- **Single copy of recent mail.** Between pavilion pulls, new mail exists only on the mail box.
- **Cloudflare proxy upload cap** (100 MB) on a proxied Immich host.
- **Unverified image contents:** which packages, which NTP, which sources format the Hetzner Debian image ships. A throwaway server for an hour answers all of them for a few cents; do it as the first provisioning step.
- **Lockout.** Key-only SSH and a mistaken sshd drop-in can lock the box. `sshd -t` in CI, apply SSH changes with a second session open, and keep rescue mode in the runbook.
- **Docker nftables** is experimental; stay on the default iptables-nft backend until it is not.
- **Doc drift.** Hetzner repriced twice in 2026; the runbook should link the price page rather than copy numbers.

## Open questions for Geoff (product, taste, budget)

1. **Location and budget.** All EU is about $57/mo, mixed about $89, all US about $103, against musicbox today. Latency from Alaska to Helsinki is the trade. Which budget and which location for the media box, and is the mail box fine in Helsinki?
2. **the second operator's access.** Restricted sudo (restart services, restore) or full sudo? And does the second operator run the emergency steps from his own machine, or from a shared terminal?
3. **Hetzner Backups on the mail box** at about $1.30/mo, given the "no off-site" ruling: acceptable as an on-platform second copy, or does the USB-only ruling cover it?
4. **Alerts.** Where does a urgent-priority push go (Geoff's phone only, or the second operator's too), and are you willing to use a public ntfy.sh topic with an unguessable name, or would you rather self-host?
5. **SSH exposure.** SSH open to the internet with keys only (recommended), or an IP allowlist with a documented API escape hatch like dubplate's?
6. **Immich host DNS.** Accept a DNS-only (grey cloud) record for photos.907.life so large video uploads work, losing Cloudflare's proxy in front of the server?
