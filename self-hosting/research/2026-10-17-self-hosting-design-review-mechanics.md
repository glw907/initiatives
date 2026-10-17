# Mechanics and feasibility review: self-hosting design spec

Target: `self-hosting/specs/2026-10-17-self-hosting-design.md` at commit faeb0b2. Reviewer: the `plan-reviewer` agent (Opus, medium effort), 2026-10-17. The reviewer read the spec, the handoff, and the stalwart, backups, immich, mail-cutover, proton-pass, and server-baseline briefs. It checked claims against official docs (WebFetch) and ran local probes with restic 0.19.1 and curl against the apt repositories. The dispatching session saved its reply here verbatim in substance.

**Verdict:** the design is sound in shape. One mechanism as written is broken (the restic retention policy against the R2 lock rules, which fails nightly from about day 15), and several first-week owner actions are missing that would each stop an unattended run. Everything else is fixable inside the plan.

## Blocker

### 1. The nightly `forget` and monthly `prune` fail under the 30-day lock rules
- Severity: blocker. Tag: correctness. Location: spec lines 324, 349-353, 524, 554.
- Defect: `forget --keep-within 14d --keep-weekly 8 ...` deletes daily snapshots aged 15 to 30 days, which the `snapshots/` lock refuses. Cloudflare's bucket-locks page: locks "prevent the deletion and overwriting of objects ... for a specified period", and "Rules apply to both new and existing objects". The backup timer exits non-zero every night from about day 15, so it raises a routine alert daily and never posts its success heartbeat. Separately, prune rewrites the index: a local probe showed one `forget` plus `prune` removed all 3 of 3 index files and added 1 ("index removed: 3 of 3, added: 1"; a no-op prune removed 0). Index files are written on every backup, so any prune that does work tries to delete index objects younger than 30 days and fails partway under a lock on `index/`.
- Fold: settle it in the spec, not the rehearsal. Set `--keep-within` to at least the lock period (for example 31d), so `forget` never targets a locked snapshot. Drop `index/` from the lock rules (the index is rebuildable from packs with `restic repair index`). Lock `data/`, `snapshots/`, `keys/`, and the root `config` object, which is currently uncovered and without which the repository cannot be opened. With keep-within at or above the lock period, every pack that becomes unused is older than 30 days, because the backup that created it is, so a prune that deletes only fully unused packs can work. The exception is leftover packs from an interrupted backup. Strike the "Not checked" item at line 554.

## Major

### 2. Age-based locks do not protect the bulk of the backup (OWNER FORK)
- Severity: major. Tag: correctness. Location: line 324.
- Defect: an `Age` rule protects an object only for 30 days after upload. After day 30 the first full photo backup, every older pack, `keys/`, and `config` are deletable by the server's own read/write token. "A compromised server can't delete or overwrite anything inside the retention window" is literally true but reads as "the history is safe", which it is not.
- Options: (a) recommended: an `Indefinite` lock on `data/`, `keys/`, and `config`, an Age lock on `snapshots/`, and no automatic prune. A lost snapshot file can be rebuilt from unreferenced trees with `restic recover`. Storage grows slowly (about 25 GB today at R2 rates, cents a month). Lock rules are editable through the API with an account-level token, so Geoff can lift a rule on purpose for a yearly prune. (b) Keep Age rules and accept that only the last 30 days are tamper-proof. (c) A longer Age period, which only moves the edge.
- Fold: whichever option, rewrite line 324 to state the real protection, and record the choice in `decisions.md`.

### 3. Immich's mail path after cutover is closed at both ends
- Severity: major. Tag: correctness. Location: lines 176 and 308.
- Defect: line 308 sends Immich mail through Stalwart on 587, but line 176 keeps 587 closed on the mail firewall. 465 is no workaround: Hetzner's FAQ says "we block ports 25 and 465 by default on all cloud servers", which includes the media server. Only 587 is open outbound.
- Fold: open 587 on `firewall-mail.json` (limited to the media server's two Primary IPs, or to all, which is standard), enable Stalwart's submission listener on 587, and say so at line 176.

### 4. The browser terminal needs the Unix username to equal the email prefix, and the feature is marked legacy
- Severity: major. Tag: correctness. Location: lines 170 and 183-186.
- Defect: Cloudflare's browser-rendering page says "user email prefixes must match their username on the server". `operator2` works only if the second operator's GitHub email starts with `operator2@`. The same holds for Geoff's row: `geoff` matches only if his GitHub email prefix is `geoff`. Cloudflare's GitHub IdP page does not say which GitHub email Access receives. The short-lived certificates page is titled "Short-lived certificates (legacy)" and says "Not recommended for new deployments". Its successor, Access for Infrastructure, is documented with the WARP client, and the pages read do not say it works with the browser-rendered terminal. sshd needs `PubkeyAuthentication yes` and `TrustedUserCAKeys /etc/ssh/ca.pub` "at the top of `/etc/ssh/sshd_config`, above all other directives", and the spec's cloud-init only adds a drop-in.
- Fold: name the Unix account from the second operator's real email prefix (the private `servers` repo's `host.env` can carry it; the public initiatives repo keeps the role). Confirm which email GitHub hands Access in pass 2. Write the sshd lines into `install.sh` in the order the docs require. Record the legacy status as a risk with a fallback: SSH with a key from his own machine.

### 5. A mail restore drill can send real mail
- Severity: major. Tag: correctness. Location: lines 141, 245, 366.
- Defect: the restored RocksDB directory carries Stalwart's outbound queue and the DKIM keys. The port 25 limit follows the account ("the block follows the account that owns the project"). Once approved, a drill server in the same project can deliver the queued messages again, signed as 907.life, from an IP with no PTR: duplicate mail to real recipients and a reputation hit. The drill server also attempts ACME for `mail.907.life`.
- Fold: `restore-drill.sh` attaches a drill firewall with outbound rules denying 25, 465, and 587 (Hetzner Cloud Firewalls take outbound rules), and starts Stalwart with the queue paused or emptied before checks. Name both as proof steps in the drill.

### 6. How Claude gets root on the servers unattended is unspecified
- Severity: major. Tag: correctness. Location: lines 55, 170, 440.
- Defect: `apply.sh`, `server-restore`, and backups need root over SSH as `geoff`. The `sudo -A` ruling at line 55 is about workstation sudo. If server sudo prompts for a password, every unattended apply stops at the first `sudo`.
- Fold: state the server sudoers policy in "Base host", for example `geoff` NOPASSWD (the SSH key is the factor) and `operator2` with password sudo, the same password as his console login. Put both under `visudo -cf` in the gate.

### 7. Stalwart's Spamhaus DNSBL checks fail from Hetzner without a DQS key
- Severity: major. Tag: correctness. Location: missing from "Stalwart", line 199.
- Defect: the mail-cutover brief cites Spamhaus's notice that queries from Hetzner and public resolvers get the error answer 127.255.255.254, and says Stalwart "needs a free DQS key or its own recursive resolver". The handoff lists it too. The spec dropped it. The result is either no DNSBL protection or every message scored as listed, depending on how Stalwart reads the code (unverified).
- Fold: add a free Spamhaus DQS key to "What Geoff does" (a signup) and to the Stalwart plan as a `File` secret, or run a local `unbound`. The DQS key is less to operate.

### 8. The daily inbound probe cannot pass before cutover
- Severity: major. Tag: correctness. Location: lines 385, 391, 498.
- Defect: the monitor is built in pass 1. A probe mailbox on 907.life follows 907.life's MX, which points at Fastmail until cutover. The probe either alerts urgently every day for weeks, or has to be disabled, and then the rehearsal never tests it.
- Fold: give the probe its own subdomain (for example `probe.907.life`) with MX `mail.907.life` from the day the mail server exists, so it works through the rehearsal and needs no change at cutover. Add a per-target enabled state in D1 so probes for services that do not exist yet stay silent.

### 9. First-week owner actions are missing, so passes 2 and 5 stop
- Severity: major. Tag: correctness. Location: lines 476-484 against 183, 229-230, 259, 263, 385.
- Missing: a GitHub OAuth app for the Access identity provider (Cloudflare's GitHub IdP page has Geoff create it under Settings > Developer settings > OAuth Apps with callback `https://<team>.cloudflareaccess.com/cdn-cgi/access/callback`, then hand over the client ID and secret). A DAV app password for Geoff's own account (his calendars go over CalDAV too; the brief says the stored token "does not expose calendars"). IMAP app passwords for both mailboxes (the T+1/3/7 imapsync sweeps need them, and the reverse imapsync rollback needs write scope). The Spamhaus DQS signup (finding 7). A check of the Cloudflare Workers plan: the Email Service page says "sending to arbitrary recipients requires Workers Paid", and the service is Beta; on Free, the cost line gains $5 a month.
- Also: the second operator's Fastmail API token at line 482 is probably minted in his own Fastmail login, not Geoff's (unverified). Say who creates it.
- Fold: add these to the first-week list.

### 10. The permission rules do not bound what Claude can do
- Severity: major. Tag: correctness. Location: lines 434-442.
- Defect: the auto-mode docs say "Actions matching your allow ... rules resolve immediately", and file edits in the working directory are auto-approved, so Claude can edit `provision.sh` and then run it under the same rule. The "refuse to delete except `purpose=drill`" guard sits in code Claude itself edits. Hetzner API tokens are project-wide, so labels are not enforced server side; if musicbox shares the project, the token reaches it. "`wrangler deploy` from `cloudflare/`" cannot be a Bash rule, because rules match command text, not the working directory, and `Bash(wrangler deploy*)` would allow deploying any Worker on the account, including the site Workers.
- Fold: wrap the deploy as `cloudflare/deploy.sh monitor|mta-sts`. Turn on Hetzner delete and rebuild protection on production servers and Primary IPs so the API refuses a delete. Put the servers in their own Hetzner project. Add a PreToolUse deny for raw `hcloud ... delete` and for `DELETE` calls to `api.hetzner.cloud`. Record in the runbook that the real boundary is the API protection plus the deny rule, not the script. Separately, a `Bash(ssh mail *)` rule may count as broad arbitrary execution and be dropped on entering auto mode (the docs list blanket `Bash(*)`, wildcard interpreters, package-manager run commands, and Agent rules; unverified for ssh). Test it in the PR.

### 11. "Claude is the only writer to the zone" is false
- Severity: major. Tag: correctness. Location: lines 213 and 219.
- Defect: Cloudflare's DMARC Management page says that if a DMARC record exists, Cloudflare "will add another `rua` ... entry to it". Workers custom domains (`mta-sts.907.life`, the apex site) create their own records. `dns.sh --apply` either strips Cloudflare's `rua` or fights it every run.
- Fold: `dns.sh` declares the DMARC value with Cloudflare's `rua` included verbatim, and treats records it does not declare (Worker custom domains, `cf-bounce`, the site's) as foreign: `--check` reports them and never deletes them. Rewrite line 213 as "the only writer of the records the repo declares".

### 12. "Server gone" for mail relies on Hetzner backup images that may die with the server (unverified)
- Severity: major. Tag: correctness. Location: lines 191 and 359-362.
- Defect: from recollection, Hetzner's API binds backup images to their server (`bound_to`) and deletes them with it. The pages fetched neither confirm nor deny this. The FAQ advises to "create a Snapshot before deleting the server". If the recollection holds, the second operator's emergency path disappears in exactly the case it exists for.
- Fold: make `restore-drill.sh --keep` from R2 the "gone entirely" path for both servers. Keep the Hetzner image for the case where the server exists and needs rolling back. Confirm the binding in pass 5.

### 13. Nothing watches the monitor
- Severity: major. Tag: correctness. Location: lines 379-394.
- Defect: if the Worker's cron stops, a deploy breaks it, or ntfy.sh drops posts, every alert goes silent with no sign. Mail is the stated top risk, and this is its only alarm.
- Fold: the workstations' `check-drift` reads the Worker's last-run time (from a small endpoint or D1 over the API) and raises a normal-urgency notice past 30 minutes. No new service.

## Minor

### 14. Postgres 16 dump into Postgres 14 first is unsupported
- Severity: minor. Tag: correctness. Location: line 302.
- Defect: the pg_dump docs say "it is not guaranteed that pg_dump's output can be loaded into a server of an older major version ... may require manual editing". The source is 16.10; Immich accepts 14 up to but excluding 20.
- Fold: restore straight onto a `16-vectorchord` image and drop the try-14-first step.

### 15. Stalwart-in-Docker details
- Severity: minor. Tag: correctness. Location: lines 197 and 199.
- Defect: Docker's docs confirm logs go to stdout, but journald sees them only with the `journald` log driver, while `daemon.json` sets json-file rotation. `Conflicts=` lives in the native unit, which the container does not use; the real hazard is a host MTA grabbing port 25 so the container fails to bind on restart. Host networking is not covered by Stalwart's Docker page (unverified). Bind mounts must be owned by UID 2000. How `stalwart-cli` reaches the host is unsaid.
- Fold: use the `journald` driver everywhere (`docker logs` still works, one cap covers all logs), restate why the apt pin is there, `chown 2000:2000` the data directory, and install a pinned, hash-checked `stalwart-cli`.

### 16. Not every apt repository gets automatic upgrades
- Severity: minor. Tag: correctness. Location: lines 172 and 294.
- Defect: Docker's origin is confirmed (Release: `Origin: Docker`, `Label: Docker CE`, `Suite: trixie`). Caddy's (`Origin: cloudsmith/caddy/stable`) and cloudflared's are not in the allowed origins, though both face the internet. cloudflared's apt repository serves the `any` suite (200); `trixie` returned HTML instead of a Release file.
- Fold: add both origins, and use `any` for cloudflared.

### 17. The lock-and-prune rehearsal cannot see 30-day behavior in a pass
- Severity: minor. Tag: correctness. Location: lines 353 and 499.
- Fold: after finding 1, test against a scratch bucket with a 1-day Age rule. The fixture is a snapshot older than one day being forgotten, plus a prune that does real work.

### 18. Disk headroom on the CX23 is thin
- Severity: minor. Tag: correctness. Location: line 203.
- Defect: the guesses come to about 29 of 40 GB, near the 80% alert: 5.14 GiB times the brief's guessed 1.5x index overhead, plus the second mailbox, doubled for the warm copy, plus OS and images. Where Vandelay's SQLite archives sit while being built is unsaid.
- Fold: measure the second mailbox first in pass 5, as a gate to rescale or add a Volume. Run Vandelay on a workstation.

### 19. Primary IPs are tied to a location
- Severity: minor. Tag: correctness. Location: lines 90-94.
- Defect: if `provision.sh` falls back to nbg1, an IP already created in fsn1 cannot attach.
- Fold: choose the location first, then create and check the IPs.

### 20. Caddy will try for the photos.907.life certificate too early
- Severity: minor. Tag: correctness. Location: line 304.
- Defect: with `photos.907.life` in the Caddyfile before the DNS flip, Caddy fails validation against PikaPods and backs off (Let's Encrypt limits failed validations).
- Fold: add the site block when the DNS switches.

### 21. Hetzner project role for the second operator (OWNER FORK)
- Severity: minor. Tag: optional. Location: line 191.
- Defect: the Hetzner FAQ says a Member "can create, modify and delete all resources in the project", and a Restricted member cannot create or delete servers or delete backups.
- Options: (a) Restricted, recommended if it still allows the console and rebuild (unverified); (b) Member.

### 22. The Fastmail domain removal at T+30 may hit the login name (unverified)
- Severity: minor. Tag: correctness. Location: line 266.
- Defect: if Geoff's Fastmail login is on 907.life, Fastmail may refuse to remove the domain until the login is renamed.
- Fold: check it in the first week.

### 23. The DMARC `t=y` ramp
- Severity: minor. Tag: optional. Location: line 219.
- Defect: RFC 9989 exists and drops `pct`, but receivers not yet on RFC 9989 ignore `t=y` and apply `p=quarantine` in full.
- Fold: state it, or accept it knowingly.

### 24. Pass ordering
- Severity: minor. Tag: optional. Location: lines 498-504.
- Points: the permission-rules PR (pass 1) and the Proton workstation PR (pass 4) both edit the dotfiles repo, so serialize them per the one-executor-per-worktree rule. Moving the `m.907.life` setup to pass 4 (Proton already bought) lets the critical-tier triage start earlier, as line 287 wants. Filling the `Servers emergency` vault is not assigned to a pass. The backup script needs an "absent" state for dubplate until 0.8 ships.

### 25. Auto-ban could lock out the admin tunnel
- Severity: minor. Tag: optional. Location: line 189.
- Defect: admin traffic through the tunnel reaches Stalwart from 127.0.0.1, so auto-ban could ban loopback and close the tunnel path.
- Fold: put loopback on Stalwart's never-ban list.

### 26. The archive bucket's indefinite lock holds the 1Password export
- Severity: minor. Tag: optional. Location: lines 370-375.
- Defect: the export is a full credential dump, and "indefinite" is reversible by an account-level token.
- Fold: say "until Geoff lifts the rule".

### 27. Ceremony to cut or confirm
- Severity: minor. Tag: optional. Location: lines 189 and 469.
- Points: putting Immich's admin pages behind Access (line 189) adds a hostname and protects nothing, because `/admin` stays reachable on the public DNS-only `photos.907.life`; cut it. The weekly link check on the catalog (line 469) is cheap but unrequested; fold it into the monthly review. The ntfy item at lines 557 and 561 is checked: Homebrew carries `ntfy` 2.31.1 with an x86_64 Linux bottle; strike it.

## Confirmed against docs or probes

Workers TCP sockets ("Workers cannot create outbound connections on port 25"; 465 and 993 allowed with `secureTransport: "on"`; Cloudflare IP ranges blocked, and `mail.907.life` is DNS-only). R2 lock semantics (prefix rules, Age and Indefinite types, existing objects covered, API endpoint). restic prune's index rewrite (local probe). Hetzner's 25/465 block and open 587. Hetzner project roles. Docker's repository origin. Stalwart's official image (exact `vX.Y.Z` tags, volumes `/etc/stalwart` and `/var/lib/stalwart`, console logging, UID 2000). Cloudflare Email Sending is Beta and needs Workers Paid for arbitrary recipients. DMARC Management appends a `rua`. RFC 9989 exists and drops `pct`.

## Still unverified

Email Sending to a recipient on the same domain. Stalwart on host networking. Hetzner backup images surviving server deletion. Whether the Restricted role allows the console and rebuild. Which GitHub email Access receives. Vandelay's flags and dates (left to the rehearsal, which is fine).
