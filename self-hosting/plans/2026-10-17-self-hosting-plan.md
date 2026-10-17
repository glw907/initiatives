Initiative: self-hosting

# Self-hosting pass plan

- **Design**: `self-hosting/specs/2026-10-17-self-hosting-design.md` in `glw907/initiatives`, as merged at `27a154d`. Every section binds this plan; "Rulings", "Claude's operating authority", "Irreversible steps", "What Geoff does", and "End-to-end check" bind it most. The fold record `self-hosting/research/2026-10-17-self-hosting-design-fold.md` says why each mechanism exists; read it before changing one. Where this plan and the design disagree, the design wins and the plan is fixed.
- **Rulings given at approval** (Geoff, 2026-10-17, design packet): the backup lock goes for good (`config`, `keys/`, and `data/` Indefinite, never an automatic `prune`, a cleanup packet past 200 GB), and if Hetzner refuses the port 25 request or 14 days pass with no answer, the mail passes pause and an options packet goes to Geoff. No relay is configured without a new ruling.
- **Risk class**: every pass that writes to the servers repo or to the workstation's secret paths is `auth-data`, and every pass but Pass W carries the `live-account` flag, because each touches the real Hetzner, Cloudflare, Fastmail, or PikaPods accounts. So every pass hands its PRs to Geoff in a packet, `auth-data` tasks run test-first, and each `auth-data` commit gets a `diff-reviewer` task-scope read. The classes come from the path maps below, not from a raised ruling.
- **Hosts**: unattended passes run on pavilion (no lid, no battery). Attended passes run wherever Geoff sits. thinkpad-x1 needs three per-host steps (the ntfy subscriber, the agent token, the key check), each listed where it falls, and STATUS carries each one until it is done.
- **STATUS**: `self-hosting/plans/STATUS.md` in `glw907/initiatives`, for the initiative's whole life. The work spans four repos and the calendar, and no repo's `docs/STATUS.md` owns it. Each session commits STATUS on its own hand-over branch and self-merges it, per `pass-core` "Ledgers".
- **Estimate and path**: the design names no path estimate, so this plan sets one: **2,950 path minutes** of clock work across nine passes, computed under "Path". Calendar waits (Hetzner's port 25 answer, the Immich week, the rehearsal's repeats, T+30, the triage) are not clock time and sit outside it.

## Privacy

`glw907/initiatives` and `glw907/workstation` are public. Household members appear in them by role only: the second operator, and household members A, B, and C. Real names, addresses, GitHub usernames, Unix usernames, IPs, and the ntfy topic names go only in the private `glw907/servers` repo, in `~/.local/secrets`, or in the age store. Before every commit to a public repo, the session runs `grep -n -i -F -f ~/.local/share/self-hosting/privacy-patterns.txt <changed files>`, which must print nothing. That file is local, one fixed string per line, never committed; Pass 0 creates it from the names Geoff confirms.

## Adapter facts for the servers repo

`glw907/servers` has no adapter skill until one is warranted, so these stand in for one.

- **Gate**: `bash scripts/check.sh`, run as `CAIRN_GATE_LANE=light cairn-run-gate 'bash scripts/check.sh'`. The container leg (`debian:13` under `podman`) and the Worker tests push it toward the light lane's cap, so Pass 1 measures its peak and records the lane here.
- **Fast lane**: the gate with `--changed`, which runs only the legs the diff touches. Pass 1 builds the flag.
- **Full-suite home**: CI (`.github/workflows/check.yml`) on every PR, watched with `ci-green <sha> --pr <n> --wait` as a background Bash task.
- **Worktree setup**: `npm ci --prefix cloudflare/monitor` once the Worker exists; nothing before.
- **Risk-class path map**: `auth-data` covers `secrets/**`, `base/**` (sshd, sudoers, users), `roles/backup/**`, `roles/cloudflared/**`, `scripts/{restore-drill,promote,archive}.sh`, `cloudflare/r2.sh`, and the monitor's heartbeat intake and token check. `runner` covers `scripts/check.sh` and `.github/workflows/**`. `ordinary` covers everything else, including `docs/**`. A path in two classes takes the higher.
- **Checklist globs**: `vps-conventions` for `base/**`, `roles/**`, `infra/**`, and `scripts/**`; `ts-conventions` and `cloudflare-workers-reviewer` for `cloudflare/**/*.ts`; `web-auth-security-reviewer` for the monitor's token check.
- **Close checklist**: CI green on the close head; one `gitleaks git` history scan; every live resource the pass created carries the `initiative=self-hosting` label (Hetzner) or the `servers-` name prefix (Cloudflare); the runbook's Claude infrastructure section lists every rule, token, and secret the pass added; the privacy grep runs on every public file the pass touched.

The workstation repo's adapter is `dotfiles-pass`, which wins for every PR there.

## Repos and sessions

| Repo | Main checkout | Pass worktree | Gate |
|---|---|---|---|
| `glw907/servers` (new, private) | `/var/home/glw907/Projects/servers` | `.claude/worktrees/<pass>` | above |
| `glw907/workstation` | `/var/home/glw907/.dotfiles` | `.claude/worktrees/self-hosting-<pass>` | `bash scripts/gate.sh` |
| `glw907/initiatives` | `/var/home/glw907/Projects/initiatives` | `.claude/worktrees/self-hosting` | `scripts/check` |
| `glw907/dubplate` | `/var/home/glw907/Projects/dubplate` | none planned | its own |

Executors are named `servers-<pass>` (`servers-foundation`, `servers-media`) and launched from the servers main checkout once it exists; Pass 0 and Pass W run from the workstation checkout as `workstation-self-hosting-pass0` and `workstation-self-hosting-proton`. A conductor, `conductor-servers`, owns every unattended pass's PRs and packets and launches the next pass when its entry condition holds. Each pass's executor prompt is written and committed by the session that closes the pass before it, because each depends on facts the earlier pass learns (IPs, versions, the GitHub email, the bucket names). The initiatives worktree at `.claude/worktrees/self-hosting` stays on its own branch; the main checkout there belongs to other sessions.

## Standing answers

From the design, applied in place of stopping:

| Situation | Answer |
|---|---|
| No EU location stocks a CX33 | Retry daily for seven days, then report a stall to Geoff (design, "Locations and types"). |
| A Primary IP is on a blocklist | Allocate a new one before attaching (design, "IPs"). |
| A rehearsal row fails twice on the same defect | Move that data type to its fallback and record it in `decisions.md` (design, "Rehearsal"). |
| Port 25 refused, or 14 days without an answer | Pause passes 5 and 6 and send an options packet (ruling at approval). |
| Disk alert at 80% on the mail server | Rescale to a CX43 within the $40 ceiling (design, "Size"). |
| Any purchase, new vendor account, or recurring total past $40 | Comes to Geoff (design, "Rulings"). |
| A deletion of a production server, IP, or bucket, or an account closure | Comes to Geoff as its own packet (design, "Irreversible steps"). |

Asked in this plan's packet, with the recommended answer filled in until Geoff rules:

| Situation | Recommended answer |
|---|---|
| A task passes twice its estimate | Rewrite `estimate=` once, to four times the original, and continue. Past four times, stop, write STATUS, run `notify-send -u normal`, and wait. |
| A pass's entry condition holds | `conductor-servers` launches the pass without asking. Every PR still waits for Geoff's approve, and every attended step waits for Geoff. |

## Dispatch note

Every pair dispatch carries the two samples `pass-core` "Lifecycle" step 1 quotes, verbatim, and anything beyond a task goes to its PR's "Found, not done" list, filed through `log-issue`. Pair arms are `general-purpose` subagents at `model: sonnet`, effort `medium`, with `description` `<pass> task <id>`, `isolation: "worktree"`, and the setup command first. An arm never touches a live account: provisioning, `--apply`, DNS writes, and token use run in the main loop only.

## Pass 0: attended access

Geoff is present throughout. The session is `workstation-self-hosting-pass0`, interactive, on whichever host Geoff sits at. Its numbered steps follow the design's "Pass 0: attended access" list; this section adds the Claude side of each and the order. Every credential arrives through `secret-receive NAME` and goes into the age store through `secret-set.sh` the same minute, listed in `secrets/registry.md` by name. Nothing new goes into 1Password.

### 0.1 Port 25 request first (10 min)

Claude drafts the limit request's text: the server's purpose, the household's scale, SPF, DKIM, DMARC, and PTR in place before sending. Geoff files it in the Hetzner console. STATUS records the filing date, which starts the 14-day clock. Acceptance: the date is in STATUS. Class `ordinary`.

### 0.2 Accounts and recovery (20 min)

Geoff checks that the Cloudflare, Hetzner, Proton, GitHub, and Fastmail logins recover through an address off 907.life, and stores 2FA backup codes offline. Claude keeps the checklist and records each as done in STATUS, never the addresses. Acceptance: five rows checked in STATUS. Class `ordinary`.

### 0.3 Tools (25 min)

Claude installs `hcloud`, `shfmt`, `yamllint`, and `imapsync` through Homebrew, and `pass-cli` from Proton's tap at a pinned version, and records each in its tier's manifest (`~/.claude/docs/bluefin-admin.md`). `wrangler` stays a dev dependency of each Worker, per the `wrangler` skill, never global. Vandelay waits for the mail pass. Acceptance: each `--version` prints; `check-drift` is clean. Class `ordinary`, in the Pass 0 workstation PR.

### 0.4 Hetzner (15 min)

Geoff creates the servers' project and a read-write API token in its console. Claude stores it as `HCLOUD_TOKEN_SERVERS`, writes a `hcloud context` that reads it from the environment, and runs `hcloud server list` against the empty project. Geoff invites the second operator to the project. Acceptance: the list returns empty with exit 0. Class `auth-data`.

### 0.5 Cloudflare tokens and the buckets (35 min)

Per-bucket R2 tokens can only name buckets that exist, so Claude first creates the three buckets with its own token: `servers-backup-mail`, `servers-backup-media`, and `servers-archive`, empty, with no lock rules yet. Pass 1 adds the archive's lock and the passes after it add the others. If the dashboard turns out to accept a bucket name before the bucket exists, Claude still creates them here, since nothing is lost. Claude then lists the exact permission set for each token Geoff creates: DNS edit on 907.life; Object Read & Write on each backup bucket (two tokens, one per server); Object Read on each backup bucket (two restore tokens); Object Read & Write on `servers-archive` (workstation only); and a Workers deploy token scoped to the account's Workers Scripts, D1, and Workers Routes. Claude stores each and records its scope in STATUS for the runbook. Acceptance: each bucket appears in `r2 bucket list`; each token passes Cloudflare's token-verify endpoint. Class `auth-data`.

### 0.6 Geoff's Proton start (30 min, Geoff's time)

Geoff buys Proton Pass Family (a purchase, so his), sets up his account with two FIDO2 keys and the paper recovery phrase, and invites the four members. From here on every new credential goes into Proton Pass. Claude's part is the checklist and the drafted invitations. Acceptance: Geoff confirms the account, two keys, and four invites sent. Class `ordinary`.

### 0.7 PikaPods and Fastmail (25 min)

Geoff enables SFTP on the pod and updates the stale admin login; Claude stores the SFTP credentials and the Immich API key and lists the pod's directories over SFTP. In his own Fastmail login Geoff creates an IMAP and a DAV app password. Claude checks over JMAP, read-only, whether Geoff's login is an @907.life address, reads the plan if the API shows it, and drafts the list of 907.life addresses Fastmail accepts from what JMAP shows, for Geoff to confirm or extend. Acceptance: the SFTP listing returns the six directories the design names; the address list is confirmed and stored in the private repo once it exists (STATUS holds a pointer until then, never the list). Class `auth-data`.

### 0.8 Household and second operator (30 min, much of it later)

Claude drafts three messages: one to household members A and B, each asking them to create, with Geoff's help, a Fastmail API token (read access to mail, contacts, and masked email), a DAV app password, and an IMAP app password; one to household member C about the coming Proton move; and one to the second operator listing the design's five asks (the Fastmail credentials, his GitHub username and its email, the ntfy app, a Proton account with a Proton Mail address and the two invites, and his masked addresses and Fastmail-only logins). Geoff sends them. Whether a Fastmail admin can create these credentials for another user is checked here, against Fastmail's documentation, and recorded. Members' credentials can arrive any time before Pass 5; STATUS tracks each. Acceptance: the messages are sent; STATUS lists the credentials still owed. Class `ordinary`.

### 0.9 Access, Spamhaus, test accounts (25 min)

Claude reads the Access team name and gives Geoff the GitHub OAuth callback URL; Geoff creates the OAuth app in GitHub's settings, and Claude stores the client id and secret. Geoff signs up for a free Spamhaus DQS key, and creates a Gmail and an Outlook.com test account. Claude stores each. Acceptance: the GitHub identity provider is added to Access through the API and its test sign-in succeeds for Geoff. Class `auth-data`.

### 0.10 The permissions PR (60 min)

A workstation PR, on `self-hosting-pass0`, lands the design's "Claude's operating authority" rules in `claude/.claude/settings.json`: allow rules for `infra/provision.sh --apply`, `scripts/apply.sh <host> --apply`, `scripts/restore-drill.sh`, `cloudflare/dns.sh --apply`, `cloudflare/r2.sh --apply`, `cloudflare/deploy.sh monitor|mta-sts`, and SSH as `geoff` to the two server names; deny rules for raw `hcloud * delete` and `hcloud * disable-protection`. The tools from 0.3 ride in the same PR. Whether auto mode keeps an SSH allow rule is tested here, with a throwaway `ssh -o BatchMode=yes geoff@<name> true` against a name that doesn't resolve yet, reading whether the classifier or the rule decided; if auto mode drops it, the rule names each SSH command the scripts run instead (design, "Not checked"). Geoff approves and merges it in this session; Claude runs `claude-tooling-sync apply`. Acceptance: the gate passes; a denied `hcloud server delete x` is refused by the rule, not the classifier. Class `runner` and `auth-data` (the guard hooks), test-first for the deny rules.

### 0.11 Recovery kit and privacy file (15 min)

Geoff writes the Proton recovery phrase and the workstation age key by hand and locks the kit up at home. Claude never prints the age key: Geoff reads it from 1Password himself. Claude writes `~/.local/share/self-hosting/privacy-patterns.txt` with the names, addresses, and usernames Geoff confirms. Acceptance: Geoff confirms the kit; the patterns file exists, mode 0600. Class `ordinary`.

### 0.12 The dry run (20 min)

Claude makes one read-only call with every token and app password gathered: Hetzner, each Cloudflare token, PikaPods SFTP and the Immich API key, Geoff's Fastmail JMAP, IMAP, and DAV, the Spamhaus key, and each member's credentials that have arrived. A credential that fails is fixed with Geoff before the pass ends. Acceptance: a table in STATUS, one row per credential, all passing, with the owed ones named. Class `auth-data`.

Pass 0 closes by self-merging its STATUS hand-over and writing Pass 1's executor prompt and the conductor prompt.

**Pass 0 path: 310 minutes** (0.1 through 0.12 in order; Geoff's own steps run inside them).

## Pass W: the Proton workstation wiring

Runs alongside passes 1 to 3, after Pass 0's permissions PR merges, because both edit `claude/.claude/settings.json` and the guard hooks. Session `workstation-self-hosting-proton`, unattended, then attended for the key check on each host. Class `auth-data`. No `live-account` flag: the tests run against a scratch store and a scratch `pass-cli` session directory, never Geoff's account. The design's "Workstation wiring" list and the Proton brief's section 3 are the contract.

- **W1. `ws-pass-key` and the age-key path (90 min).** A helper that reads the agent token from GNOME Keyring, logs in to an isolated session directory under `$XDG_RUNTIME_DIR`, reads the `Workstation` vault's one item with a reason naming the script and host, and caches into `/dev/shm` as today. `secret-set.sh` and `sync.sh` call it in place of `op`. Test-first against a fake `pass-cli` on `PATH` that records its arguments: the reason is set, the session directory is never the default, the cache clears on exit. Acceptance: the tests pass; `grep -rn '\bop\b' scripts/secrets bin/.local/bin` finds no live call.
- **W2. `secret-receive --pass` and the sudo dialog (60 min, pair with W1).** `secret-receive --pass` runs a web login into a throwaway tmpfs session and logs out on exit. `claude-sudo-setup` raises a zenity hidden-entry dialog in place of the `op` read. Acceptance: tests for both pass against the fake `pass-cli` and a stubbed `zenity`.
- **W3. Guards, drift, browsers (60 min).** `claude-block-pass` replaces `claude-block-op` and blocks `pass-cli`, `secret-tool lookup`, `keyctl print|pipe|read`, and reads of the session directory from Claude's Bash; `claude-secret-guard` learns the Proton token pattern; `check-drift` reports the `pass-cli` version and the agent token's expiry; browser policies install the Proton Pass extension in Chromium and Firefox and turn off the built-in managers. Acceptance: the guard tests refuse each pattern and pass a harmless lookalike; the policies validate.
- **W4. The PR (30 min).** One workstation PR, gate green, sent to Geoff in a packet with the install steps Geoff runs.
- **W5. The key check, per host (20 min each, attended).** After Geoff creates the vaults and agent tokens in one FIDO2 session and stores each host's token: Claude clears the cached age key, fetches it through `ws-pass-key` alone, decrypts the age store, and compares the result with `~/.local/secrets` (a hash comparison, never printing a value). pavilion first, then thinkpad-x1 when Geoff is there. Acceptance: hashes match on both; STATUS records each host's date.

Geoff's import (the one `op` read session, the 1PUX export, the count script, five TOTP codes and two attachments, then `scripts/archive.sh` once Pass 1 lands it) runs in an attended session whenever Geoff picks; the design's "Migration order" steps 2, 3, and 6 are its contract. The count script lands in W3's PR.

**Pass W path: 200 minutes** (W1 and W2 as a pair at 90, then W3, W4, and W5 on pavilion).

## Pass 1: foundation

Entry: Pass 0's dry run passed for Hetzner, Cloudflare, and the archive token. Session `servers-foundation`.

- **F1. The repo and its gate (75 min).** Claude creates `glw907/servers` as private, gives the second operator read access once his GitHub username is known, and lays down the design's tree with empty roles. `scripts/check.sh` runs `shellcheck`, `shfmt -d`, `yamllint`, `jq empty`, `gitleaks`, and Vale on `docs/`; the `debian:13` container leg (under `podman`) runs `sshd -t`, `visudo -cf`, `apt-get -s install`, `docker compose config`, `systemd-analyze verify`, and `cloud-init schema` on what exists; it fails on any `disable-protection` in `infra/` or `scripts/`; `--changed` limits it to the legs the diff touches. CI runs the same script. `docs/decisions.md` opens with the design's rulings and the two given at approval. A PR to `glw907/initiatives` adds `servers` to `initiative.yaml` and runs `scripts/index` and `scripts/check --repos`. Acceptance: the gate passes on the skeleton and fails on a planted `disable-protection`; CI is green; the gate's measured peak is recorded in this plan's adapter facts. Class `runner`.
- **F2. `r2.sh` and `archive.sh` (75 min).** `r2.sh --check|--apply` declares each bucket's lock rules as the design's table gives them and only ever adds a rule; it adds the archive's Indefinite rule now. `archive.sh` age-encrypts to the workstation key, refuses a file without the age header, uploads, downloads, decrypts, and compares before the local plaintext is removed. Test-first: `archive.sh` refuses a plaintext file and a failed round trip leaves the plaintext in place. A probe against a scratch bucket (`servers-scratch-<date>`, deleted after) confirms the rule shape before it touches `servers-archive`. Acceptance: deleting an object in `servers-archive` returns `409 ObjectLockedByBucketPolicy`; the round trip passes on a test file. Class `auth-data`.
- **F3. The monitor Worker (150 min, pair with F4).** `cloudflare/monitor`: a five-minute cron, D1 state, per-check enable flags (all off), heartbeat intake with a per-server token compared in constant time, the daily R2 snapshot listing through bindings, the inbound-probe send through Email Sending (off until Pass 5), two ntfy topics, the 12-hour repeat of open conditions, the six-hour all-quiet, and the design's alert table as data. The arm builds and tests; the deploy runs in the main loop after the merge. Vitest with Miniflare covers each alert row, the repeat, the all-quiet, and a heartbeat with a wrong token. Acceptance: the tests pass; `deploy.sh monitor` deploys; the all-quiet reaches the routine topic. Class `auth-data` for the heartbeat intake, `ordinary` for the rest.
- **F4. The MTA-STS Worker and `deploy.sh` (45 min, pair with F3).** A static policy Worker for `mta-sts.907.life`, its mode and MX list from one config, deployed now in `testing` but not yet referenced by any `_mta-sts` record (that lands in Pass 5, when `mail.907.life` exists). Acceptance: `curl https://mta-sts.907.life/.well-known/mta-sts.txt` returns the policy. Class `ordinary`.
- **F5. `dns.sh` (60 min).** Declares the 907.life records the repo owns, with the DMARC value copying Cloudflare's `rua`; `--check` reads public resolvers and reports every undeclared record without deleting it; `--apply` writes only declared records and ends with `--check`. In this pass it declares only the `mta-sts` host record; every mail record waits for Pass 5. Acceptance: `--check` against today's zone lists the site's, `cf-bounce`, and the Workers' records as undeclared and changes nothing; a dry `--apply` shows one record. Class `ordinary`, with `live-account` on the zone.
- **F6. The ntfy subscriber (45 min).** In the workstation repo: a user service that subscribes to both topics, maps urgent to `notify-send -u critical` and routine to normal, fetches missed messages with `since=` on start, records the all-quiet silently, and raises a local notification after 26 hours without one. The topic names come from `~/.local/secrets`. ntfy.sh's retention is probed by reading a message back after 13 hours, and the result goes in the runbook (design, "Not checked"). Acceptance: on pavilion, a test post to each topic shows the right urgency, and a stopped all-quiet raises the 26-hour notice under a shortened test interval. thinkpad-x1's install is a STATUS item. Class `ordinary`.
- **F7. The runbook's first form (45 min).** `docs/runbook.md` with its four parts: emergency screens stubbed per service as each lands; the operator part; the catalog from the server baseline brief's section 8 plus Cloudflare Tunnel, Access, R2 bucket locks, and DMARC Management; and the Claude infrastructure section listing every rule, token, and secret from Pass 0 and this pass. `EMERGENCY.md` renders the first part. Acceptance: Vale passes; every catalog link answers 200. Class `ordinary`.
- **F8. The monthly review (20 min).** `docs/monthly-review/prompt.txt` and `log.md` in the servers repo, carrying the design's "Periodic work" list; one line in the workstation's `docs/model-review/prompt.txt` runs it after the model review, in the same session. This settles the design's placement call. Acceptance: both files exist; the workstation line names the absolute path. Class `ordinary`.

**Pass 1 path: 470 minutes** (F1, F2, the F3 and F4 pair at 150, F5, F6, F7, F8).

## Pass 2: media server

Entry: Pass 1 merged. Session `servers-media`. The dubplate host contract comes from the dubplate repo's deploy docs, read at the start.

- **M1. `provision.sh` and the firewalls (90 min).** `infra/project.env`, the four firewall files, and `provision.sh --check|--apply`: reads live availability, takes the first location in the design's order that stocks the type, creates Primary IPv4 and IPv6 with auto-delete off and delete protection on, attaches the firewall, creates the server with cloud-init and the `initiative=self-hosting` and role labels, sets rDNS, and turns on delete protection. A production rebuild refuses unless the service is stopped, a backup ran, and a snapshot exists in the same run. Tests run against a fake `hcloud` on `PATH`. Acceptance: tests pass; `--check` against the live project prints the plan and changes nothing. Class `runner`, `live-account`.
- **M2. The base host (90 min, pair with M1).** `base/cloud-init.yaml` (users, keys, the sshd drop-ins with `00-cloudflare-ca.conf` first, hostname), `base/install.sh` (packages, unattended-upgrades with the four origins and the 12:00 UTC reboot, `needrestart` automatic, chrony, journald capped, Docker CE held to its major, the MTA pins at -1, the journald log driver, the 120-second stop grace), and the sudoers file. Acceptance: the container leg passes `sshd -t`, `visudo -cf`, `cloud-init schema`, and `systemd-analyze verify`; a planted directive before the CA lines fails a check the gate runs. Class `auth-data`, test-first.
- **M3. Roles and `apply.sh` (120 min).** `roles/{immich,caddy,dubplate-host,cloudflared,health}`, `secrets/templates` and `render.sh` (dubplate's pattern), and `scripts/apply.sh HOST --check|--apply`, which proves `sudo -n true` and converges the role list. Immich pins an exact v3 tag with the ML caps, job concurrency 1, loopback ports, `IMMICH_TRUSTED_PROXIES`, and a 2 GB swap file. The health timer posts every 15 minutes with the design's fields. Acceptance: `docker compose config` and `systemd-analyze verify` pass in the container; `render.sh` writes nothing to disk on the workstation. Class `auth-data` for `secrets/**` and `cloudflared`, `ordinary` for the rest.
- **M4. Provision and access (60 min).** Provision `media`, apply, confirm which email GitHub hands to Access for the second operator, create his account under that prefix, and publish `ssh-media.907.life` with the Access policy admitting the two GitHub identities. Acceptance: Geoff's SSH and `sudo -n true` work; the Access terminal opens for Geoff's identity on a temporary account named for his prefix, removed after; the second operator's own first sign-in is a STATUS item for his next session with Geoff. Class `auth-data`, `live-account`.
- **M5. Immich rehearsal (90 min).** Download the newest dump through the admin API and copy the six directories over SFTP; restore at the pod's exact version on Postgres 16 with VectorChord under `photos-new.907.life`; check the counts against `/api/server/statistics`, the integrity page, the API key, and SMTP through Fastmail. The household-phone check waits for Geoff to lend a phone and is a STATUS item. Acceptance: counts equal the pod's, zero integrity errors. Class `ordinary`, `live-account`.
- **M6. The media backup (90 min).** `roles/backup` for media: the 03:00 unit under `flock` with `restic unlock` and `--retry-lock 30m`, the dump age and `gunzip -t` checks, the manifest, the backup set, exit 3 as failure, nightly `forget`, weekly `check --read-data-subset=10%`, never `prune`. Probe whether an uncompressed dump deduplicates better and record the answer. After the first verified backup, `r2.sh --apply` adds media's lock rules. Test-first for the stop-on-failure order. Acceptance: with the server's own token, deleting a pack in `data/` fails, overwriting `config` fails, changing the lock rules fails, and deleting a file in `locks/` succeeds. Class `auth-data`, `live-account`.
- **M7. Restore and the media drill (90 min).** `server-restore`, `scripts/restore-drill.sh` with its fixed role list and two firewalls, and `scripts/promote.sh`. Run the media drill to the design's bar, including the `restic recover` proof on a local copy with `rclone`. Acceptance: the drill passes and `docs/restore-drill-log.md` records it; the script refuses a role list that names `backup`, `health`, or `cloudflared`. Class `auth-data`, `live-account`.
- **M8. Monitor on, and the stage (30 min).** Enable media's heartbeat and probe checks; inject the media fault (health timer stopped, routine within 45 minutes) and point the snapshot check at a scratch bucket two days stale (routine). Stage the emergency values in a 0600 file under `/dev/shm` for Geoff to copy into `Servers emergency`, then remove it. Acceptance: both alerts reached the routine topic; Geoff confirms the copy. Class `ordinary`.

**Pass 2 path: 570 minutes** (the M1 and M2 pair at 90, then M3 to M8).

## Pass 3: Immich cutover and musicbox

Entry: Pass 2 merged, a household phone available, and Geoff's go for the upload freeze. Session `servers-photos`.

- **I1. The cutover (90 min, attended for the freeze).** Claude drafts the freeze message; Geoff sends it. Final dump, pod stopped, version read from the dump's file name, rehearsal data wiped, delta copied, restored, counts checked against the pod's at the freeze; then the DNS switch to DNS-only A and AAAA and the Caddy site at the same moment. Certificate confirmed; a household phone uploads a video of at least 150 MB from outside the house, with a matching checksum. The rollback in the design's "Photos" applies on any failure. Acceptance: counts match, zero integrity errors, the upload's checksum matches. Class `ordinary`, `live-account`.
- **I2. The upgrade (30 min).** Manual dump and Hetzner snapshot, then the current v3 patch. Acceptance: the integrity page and counts hold after it. Class `ordinary`.
- **I3. musicbox (60 min, pair-free, main loop).** Copy `/srv/music/library` and `/var/lib/dubplate` to the media server; let the nightly backup take them; restore from restic to a scratch directory and compare SHA-256 sums with musicbox. Find dubplate's rclone crypt passwords and read what `music-library` holds. Acceptance: every sum matches; the bucket's contents are recorded in `decisions.md`. Class `ordinary`, `live-account`.
- **I4. The week, then two packets (20 min of clock).** After seven days with zero integrity errors, a backup every night, a phone upload, and no sign-in loop: the PikaPods packet and the musicbox packet, each with the evidence "Irreversible steps" lists. The final pod dump goes to `servers-archive` through `archive.sh` first. Acceptance: both packets sent, carrying every evidence row. Class `ordinary`.

**Pass 3 path: 200 minutes.**

## Pass 4: passwords

Entry: Pass W's key check passed on pavilion, and Geoff's import done. Runs alongside Pass 2 or 3. Session `servers-passwords`.

- **P1. Guides (75 min).** The second operator's importer steps; household member C's macOS and iOS import steps; members A's and B's Proton setup on macOS, iOS, and Safari. They live in the private repo's `docs/household/`. Acceptance: each guide is a numbered list a member can follow without Claude; Vale passes.
- **P2. `m.907.life` (45 min).** Once Geoff adds the domain and hands over the Info tab's values, `dns.sh` declares its MX, verification, SPF, DKIM, and DMARC records and applies them; Geoff verifies `geoff@907.life` as the default mailbox. Check whether Family members can use the domain and record it. Acceptance: Proton shows the domain verified; a test alias receives mail at Fastmail today. Class `ordinary`, `live-account`.
- **P3. Triage's start (60 min).** Snapshot every masked address over JMAP into an age-encrypted file outside git; add Geoff's counts and sender domains for the last year; join against the Proton Pass logins through a count-only export Geoff runs; tier each address; give Geoff the critical tier. Acceptance: the tiered list exists, encrypted; the weekly recount job is written for Pass 7. Class `auth-data` (it handles every mask).
- **P4. The 1Password packet (30 min of clock, after the overlap).** When all three users have moved and confirmed, the per-host check passed on both, and 30 days have passed, Claude compares a fresh listing of Geoff's 1Password with his export's change dates, re-carries any change, and sends the cancellation packet. 1Password is uninstalled from both workstations through a workstation PR in the same packet. Acceptance: the packet carries every evidence row. Class `ordinary`.

**Pass 4 path: 210 minutes.**

## Pass 5: mail server

Entry: Hetzner approved port 25, Pass 2 merged, and all four mailboxes' credentials passed the dry run. If the port 25 answer is a refusal or 14 days pass without one, the pass does not start: the conductor sends the options packet. Session `servers-mail`.

- **L1. Measure and check (30 min).** Read the other three mailboxes' sizes over JMAP, read-only; check A's and B's masked addresses with `MaskedEmail/get` alone. Record the sizes in `decisions.md` against the design's 12 GB line. Acceptance: four sizes recorded; the masks counted. Class `ordinary`.
- **L2. Provision mail (45 min).** `provision.sh` for `mail`: the CX33, the Primary IPs checked against Spamhaus, MXToolbox, and multirbl before attaching, PTR to `mail.907.life`, Hetzner Backups on. Acceptance: PTR resolves on both addresses; no listing. Class `runner`, `live-account`.
- **L3. Stalwart and the mail backup (150 min).** `roles/stalwart`: the pinned version, host networking, console logging, UID 2000, `stalwart-cli` pinned by hash, `config.json` plus the NDJSON plan (auto-ban, report addresses, DQS through a `File` secret, the 587 listener for media's addresses, `ipv4_only`, RocksDB stores), loopback-only admin, `restart: always`. `roles/backup` for mail at 03:30 with the design's six steps and the trap. `ssh-mail.907.life` and the admin page behind Access. Test-first for the backup's stop-on-failure order. Acceptance: `/healthz/live` answers; a JMAP login works; a backup run produces a snapshot whose manifest carries the image digest and counts. Class `auth-data`, `live-account`.
- **L4. DNS preparation (45 min).** `dns.sh` declares and applies `mail.907.life` A and AAAA, `probe.907.life` MX, SPF with Fastmail's include plus the server and `~all`, the new DKIM selector, DMARC at `p=none` with both `rua` targets, TLS-RPT, the `_mta-sts` record for the `testing` policy listing both MX hosts, the SRV records, and the `.well-known` redirect rules. MX stays on Fastmail. Acceptance: `--check` passes against public resolvers and Fastmail's MX is untouched. Class `ordinary`, `live-account`.
- **L5. The rehearsal import (120 min).** Install Vandelay; copy each of the four accounts into its SQLite archive, then into Stalwart by `--account-id`; calendars over CalDAV; Trash and Junk left out or emptied by role after a count check; every accepted 907.life address created, from the list Geoff confirmed. Archives go to `servers-archive` through `archive.sh`. Acceptance: `vandelay inspect` counts per account recorded. Class `auth-data` (it carries every member's mail).
- **L6. The rehearsal checks (150 min per round).** Every row of the design's rehearsal table, repeated until all pass. The client rows need people: one session with a household member's iPhone and Mac for the profile test, and the second operator for Android; the sending row needs Geoff to report where test mail landed in an account Claude can't read. Each is a STATUS item with what Claude has ready. Claude writes the `.mobileconfig` profiles and the Android guide here. Acceptance: every row passes in one round; the image restore booted. Class `ordinary`, `live-account`.
- **L7. Lock, monitor, stage (45 min).** After the last rehearsal import, `r2.sh --apply` adds mail's lock rules, checked with the server's own token as M6 does. Enable the mail checks on the routine topic and the daily inbound probe; if Email Sending can't reach `probe.907.life`, switch to the DMARC-report fallback. Run the mail drill. Stage the emergency values for Geoff. Acceptance: the lock checks pass; the probe arrives; the drill passes and the log records it. Class `auth-data`, `live-account`.
- **L8. The date (15 min).** Delete the rehearsal's test messages; propose a cutover date to Geoff in a packet with the backup growth figure. That confirmation is the one planned stop before cutover. Class `ordinary`.

**Pass 5 path: 600 minutes** for one rehearsal round (L1 to L8 in order; L4 and L5 both write to live accounts, so neither runs as a pair arm); each extra round adds 150.

## Pass 6: mail cutover

Entry: Geoff confirmed the date. Session `servers-cutover`, with Geoff on call.

- **C1. The window (90 min).** The design's seven cutover steps, the failed-check table, and Claude's rollback authority inside the window. Members' Stalwart passwords are shared through Proton Pass before it opens. Acceptance: the inbound probe from outside, a send from inside Fastmail, Hylki and poplar on Stalwart, Immich's test mail through Stalwart, and dubplate's if it is deployed. Class `auth-data`, `live-account`.
- **C2. Alerts go live (30 min).** Move the mail conditions to the urgent topic; inject Stalwart stopped (urgent within 10 minutes) and a probe to a missing address (urgent). Acceptance: both arrived as critical banners on pavilion and on the second operator's phone. Class `ordinary`.
- **C3. Sweeps and checks (60 min of clock across 30 days).** The T+1, T+3, and T+7 imapsync sweeps, the T+7 contacts and calendar check, and the daily sweep after. Acceptance: each sweep's per-folder log is in the drill log's sibling, `docs/cutover-log.md`. Class `ordinary`.
- **C4. T+30 (45 min).** If clean by the design's definition: the drafted household message, SPF to `-all`, MTA-STS to `enforce`, DMARC to `p=quarantine`, and the Fastmail packet. Acceptance: the packet carries every evidence row. Class `ordinary`, `live-account`.

**Pass 6 path: 225 minutes.**

## Pass 7: wind-down

Session `servers-wind-down`, in pieces as each condition arrives.

- **D1. Triage support (30 min to set up).** The weekly recount, reporting what's left and any mail to a disabled mask. Class `ordinary`.
- **D2. Hylki replaces Thunderbird (90 min).** A workstation PR: install Hylki through its tier, import any Local Folders and local address books, retire the `thunderbird` stow package and its manifest rows. Thunderbird goes only after Hylki reads mail, contacts, and calendars from Stalwart. Acceptance: those three reads pass; `check-drift` is clean. Class `ordinary`.
- **D3. DMARC to reject (15 min).** When 14 days of reports allow it. Class `ordinary`, `live-account`.
- **D4. Fastmail's close (30 min).** When the exit rule has held 30 days: a final Vandelay pass, the archives through `vandelay inspect`, the final mask list archived, and the close packet. Class `ordinary`.
- **D5. The second operator's session (60 min, attended).** Geoff sits with him while he restarts a service and runs a restore from the runbook and the emergency vault alone. Each stumble becomes a runbook fix in the same PR. Class `ordinary`.
- **D6. Done (30 min).** Walk the design's "End-to-end check" and record each row's evidence in the record; move the initiative to `done`. Class `ordinary`.

**Pass 7 path: 255 minutes.**

## Path

The passes run in sequence except Pass W and Pass 4, which run alongside the server passes and so count once, at the longer of the two branches they sit beside:

| Branch | Minutes |
|---|---|
| Pass 0 | 310 |
| Pass 1 | 470 |
| Pass 2 | 570 |
| Pass 3 | 200 |
| Pass 5 (one round) | 600 |
| Pass 6 | 225 |
| Pass 7 | 255 |
| Hand-overs, eight packets at 40 | 320 |
| **Path** | **2,950** |

Pass W (200) and Pass 4 (210) run in parallel with passes 1 to 3 and add nothing to the path. The sum over every pass is 3,360. Each extra rehearsal round adds 150.

## Not checked

| Item | Checked in | If it fails |
|---|---|---|
| Whether R2 lets a token name a bucket that doesn't exist yet | Pass 0, 0.5 | The buckets are created first either way |
| Whether auto mode keeps an SSH allow rule | Pass 0, 0.10 | Name each SSH command |
| The gate's memory peak with the container leg | Pass 1, F1 | Move the container leg to the heavy lane |
| Whether `podman` runs the `debian:13` checks rootless on Bluefin | Pass 1, F1 | Run them in CI only, and say so in the adapter facts |
| The rest | the design's "Not checked" table | its named fallbacks |
