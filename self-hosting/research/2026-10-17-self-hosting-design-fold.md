# Self-hosting design: fold record (2026-10-17)

Target: `specs/2026-10-17-self-hosting-design.md`, revised in place from commit `e971705`. Inputs: the contract, mechanics, and data reviews of 2026-10-17, the ten research briefs, and the brainstorm handoff. Each finding was checked before it was folded. Optional findings were dropped unless they were near-free and removed ceremony. New machinery was folded only where a published practice runs it and it answers a stated defect, and the simplest mechanism won.

Several findings converge. Each convergent set folds once, at the root named below, and the other findings point to it.

| Root | Findings it carries |
|---|---|
| Lock rules and retention ("Backups") | mechanics 1 and 17, data B1, contract M14 and m5 |
| Drill host contract ("Drills") | contract M1, mechanics 5, data M14 |
| Immich mail on 587 | contract M2, mechanics 3 |
| Senders of 907.life | contract M3, data m21 |
| Watching the monitor | contract M4, mechanics 13, data M15 |
| Inbound probe on `probe.907.life` | contract M5, mechanics 8, data m14 |
| Rehearsal pass bar | contract M8, data M9, the imapsync part of data M8 |
| Owner actions ("What Geoff does") | contract M11, mechanics 9, the credential part of data M8, data m18 |
| Sweeps of every folder | contract M15, data M8 |
| Server-gone restore from R2 | contract M16, mechanics 12, data M11 |
| Server sudo | contract m7, mechanics 6 |
| Browser terminal username | contract m8, mechanics 4 |
| musicbox retirement | contract m9, data M19 |
| `server-restore` side directory | contract m13, data M13 |
| Media dump freshness | contract m14, data m7 |
| Immich rollback and upgrade dump | contract M7, data m8 and m9 |
| Stalwart in Docker details | mechanics 15, data m17 |
| Mail disk headroom | mechanics 18, data m22 |
| Archive encryption and lock wording | contract m2, mechanics 26, data m10 |
| Catalog link check | contract m15, mechanics 27 |
| Mail backup stop | data M1 and m2 |

## Counts

| Review | Folded | Refused or dropped | Owner fork |
|---|---|---|---|
| Contract (35 findings) | 33 | 1 | 1 |
| Mechanics (27 findings) | 23 | 3 | 1 |
| Data (47 findings) | 45 | 2 | 0 |

Five findings arrived marked OWNER FORK and were settled as method calls with one clearly correct answer: contract m1 and m2, data M3 and M17, and mechanics 21 (dropped as optional). Their reasons are in the rows below. Two forks remain, in the spec's "Rulings needed" and as `### Decide:` blocks in the brief.

## What was verified for this fold

- R2 bucket locks with restic 0.19.1, live. A scratch bucket (`restic-lock-probe-20261017`, created and deleted on 2026-10-17) carried 5-minute Age rules on `config`, `keys/`, `data/`, and `snapshots/`. R2 refused DELETE and PUT on a locked object with `409 ObjectLockedByBucketPolicy` and allowed DELETE under `locks/`. restic retried a locked `forget` for the whole 5-minute test (its source sets a 15-minute retry window, `internal/global/global.go:615`, and treats only `AccessDenied` and missing objects as permanent). After expiry, `forget` and `prune` of old snapshots with a newer snapshot still locked finished with zero retries; `check --read-data` and a restore were clean. An Indefinite rule held until the Admin-scoped API token removed it. A killed backup left a lock that blocked `forget` and `prune` until `restic unlock`.
- restic source (v0.19.1). `prune` deletes unreferenced packs first and ignores errors ("keeping too many packs cannot damage the repository"), rewrites the index (fatal on error) before it removes repacked and unused packs (errors ignored). So a refused pack delete can't leave the index pointing at a missing pack, which answers data B1's corruption concern. `restore`, `snapshots`, `ls`, and `dump` honor `--no-lock`. `--retry-lock`, `recover`, and `repair index` exist. Backup exit status 3 means an incomplete snapshot.
- restic design reference. The repository is a `config` object plus `data`, `index`, `keys`, `locks`, and `snapshots`, and "All files in a repository are only written once and never modified afterwards."
- Cloudflare docs. Bucket locks: "prevent the deletion and overwriting of objects", prefix rules, Age and Indefinite types, "Rules apply to both new and existing objects". R2 tokens: Object Read & Write can "read, write, and list objects in specific buckets"; only Admin tokens "edit bucket configuration". Browser-rendered SSH: "user email prefixes must match their username on the server". Short-lived certificates: "Not recommended for new deployments", principal is "the user's email address prefix", trust lines "at the top of the file, above all other directives". Access for Infrastructure: documented only with the Cloudflare One client. Workers R2 API: `list()` with `prefix`, up to 1,000 results, `uploaded` dates.
- Hetzner docs and CLI. Backups FAQ: "Backups are bound to a single server and will automatically be deleted if you delete the server"; a backup can be converted to a snapshot; Hetzner recommends powering off for consistency and "cannot guarantee data consistency" otherwise. Firewall FAQ: rules are allow-only, and one outbound rule turns outbound to implicit deny. API tokens belong to one project. `hcloud` 1.70.1: server protection takes `delete` and `rebuild`, Primary IPs take `delete`, and firewall rules take `--direction out --destination-ips`.
- Debian 13. In a `debian:13` container, `sshd_config`'s first directive is `Include /etc/ssh/sshd_config.d/*.conf` (OpenSSH 10.0p2), so a `00-` drop-in meets Cloudflare's placement rule.
- Docker docs. `docker stop` waits 10 seconds by default before SIGKILL. `docker logs` works with the `journald` driver.
- ntfy docs. The default cache keeps messages 12 hours; subscribers fetch missed messages with `since=` or `poll=1`.
- Proton docs. The custom-domain page says nothing about Family members using the owner's domain.
- Workers Paid. cairn's own docs say a cairn site needs Workers Paid billed once per account, and 907.life is a cairn site on this account, so the account should already pay. The billing API refused the general token, so the foundation pass confirms.

Left unverified, each named in the spec's "Not checked" table with its pass and fallback: Email Sending delivery to `probe.907.life`, which email GitHub hands to Access, Family use of `m.907.life`, whether Fastmail tokens must be minted in the second operator's login, Apple profile password prompts, Hylki discovery, auto-ban treatment of TLS probes, auto mode and SSH allow rules, ntfy.sh's own retention, the `music-library` bucket's contents, DMARC Management's API, and the second operator's mailbox size. Also unverified and stated as such: whether Fastmail's JMAP exposes alias settings (handled by Geoff confirming the list), Cloudflare Email Sending's DKIM alignment for 907.life (handled by the pre-ramp `dmarc=pass` check), and Proton Pass item sharing (the password can go through the shared vault instead).

## Contract review

| Finding | Disposition |
|---|---|
| M1 drill impersonates production | Folded at the drill root: "Drills" (no `backup` or `health` role, read-only tokens, `firewall-drill.json`). The proposed gate that inspects rendered secrets is refused as machinery; a drill host's fixed role list does the job. |
| M2 Immich can't reach Stalwart | Folded: "Inbound ports" (587 to the media server only), "Stalwart" (submission listener), "Cutover" step 7. |
| M3 DMARC ignores Cloudflare senders | Folded: new "Senders of 907.life" with the ramp triggers and the pre-step check. |
| M4 monitor proves delivery, not detection | Folded: "Alerts" table, "Watching the monitor", fault-injection line in "End-to-end check". The `check-drift` unit check is refused; the 26-hour all-quiet check covers the subscriber. |
| M5 inbound probe fallback and pre-cutover | Folded: `probe.907.life`, 60-minute failure, named fallback in "Monitoring". |
| M6 rollback triggers | Folded: rollback table, Claude decides, "clean" defined at T+30, Sent in the reverse sync. Corrected: the outbound row's rationale was wrong; Fastmail's SPF and DKIM stay valid until T+30, so clients send through Fastmail meanwhile. |
| M7 Immich rollback and week bar | Folded: "Photos" rollback paragraph, week bar, dump plus snapshot before the patch upgrade (step 7). |
| M8 rehearsal pass bar | Folded: rehearsal table, two-failure fallback, test-message cleanup. |
| M9 outbound test fixtures | Folded: "Delivery" and "What Geoff does" item 10. Claude reads results where it can sign in; Geoff looks elsewhere. |
| M10 drill pass bar and manifests | Folded: manifests in "Media" and "Mail" backup steps, bar in "Drills". |
| M11 missing owner actions | Folded at the owner root: "What Geoff does" first-week items 3 and 6 to 10 and later items. |
| M12 Claude reading personal vaults | Folded: "Migration order" step 3, a Geoff-run count script. |
| M13 promises without criteria | Folded: new lines in "End-to-end check". |
| M14 lock test and `config` | Folded at the lock root: `config` and `keys/` Indefinite; the token test is an end-to-end line. |
| M15 sweeps read only Inbox | Folded: "After cutover", every folder but Trash and Junk, counts logged. |
| M16 Hetzner image dies with server | Folded at the restore root; verified in Hetzner's FAQ. |
| M17 port 25 refusal | Owner fork: "Rulings needed" 2. |
| M18 profile credentials | Folded, simpler than proposed: profiles carry no password; passwords go through Proton Pass. The device test is a rehearsal row. |
| M19 vacuous end-to-end items | Folded: rewritten lines with fixtures. |
| m1 what counts as a purchase | Folded as a method call: defined in "Claude's operating authority". Not a fork, because the authority ruling already lets Claude create billable servers; Workers Paid should already be paid. |
| m2 archive lock and plaintext | Folded as a method call: every object age-encrypted by `scripts/archive.sh`; Indefinite "until Geoff lifts it" (verified liftable). Not a fork; the reviewer called encryption a method call itself. |
| m3 monitor thresholds | Folded: "Alerts" table. |
| m4 fallbacks for "Not checked" | Folded: the "Not checked" table. |
| m5 prune fallback | Folded at the lock root; the design no longer needs a fallback. |
| m6 test of the authority guards | Refused: a stubbed-`hcloud` harness is new machinery. Hetzner's API-side delete protection plus deny rules make the boundary independent of the scripts. |
| m7 server sudo | Folded at the sudo root: "Base host". |
| m8 principal mapping | Folded at the username root, differently: the browser terminal requires prefix equals username, so the account is named after the prefix ("Access"). |
| m9 musicbox preconditions | Folded at the musicbox root: "Irreversible steps". |
| m10 `m.907.life` for family | Folded: promise narrowed to Geoff's addresses; fallback in "Not checked". |
| m11 final-pass state gap | Folded: one-hour cutover window with Fastmail clients closed. |
| m12 Proton verification numbers | Folded: "Migration order" steps 3 and 8. |
| m13 in-place restore loss | Folded at the restore root. |
| m14 dump freshness | Folded: "Media, at 03:00". |
| m15 weekly link check (optional) | Folded: moved into the monthly review; removes ceremony. |
| m16 drill listed twice (optional) | Folded: the rehearsal row points to "Drills"; removes duplication. |

## Mechanics review

| Finding | Disposition |
|---|---|
| 1 retention vs locks (blocker) | Folded at the lock root, adjusted after the probe: `snapshots/` stays locked, since retention at 35 days never reaches it; keep-within is 35 days, not 31, to cover a slow backup. |
| 2 Age locks don't protect old history | Owner fork: "Rulings needed" 1. The spec's protection statement is rewritten either way. |
| 3 Immich mail path | Folded at the 587 root. |
| 4 browser terminal username, legacy | Folded at the username root; legacy status and fallback in "Access" and "Risks". Partly refuted: Debian 13 includes `sshd_config.d` as its first directive, so a `00-` drop-in meets the placement rule and `install.sh` needn't edit `sshd_config`. |
| 5 drill can send mail | Folded at the drill root. Corrected: Hetzner firewalls are allow-only, so the drill firewall allows 53, 80, 123, and 443 outbound instead of denying mail ports; pausing the queue is unneeded. |
| 6 unattended root | Folded at the sudo root. |
| 7 Spamhaus DQS | Folded: "Stalwart" and "What Geoff does" item 9. |
| 8 probe before cutover | Folded at the probe root. |
| 9 first-week actions | Folded at the owner root. Workers Paid: no cost change, see the verification list. |
| 10 permission rules don't bound Claude | Folded: `cloudflare/deploy.sh`, Hetzner delete protection, deny rules for raw delete and disable-protection, the servers' own Hetzner project, the SSH rule tested in the PR. A PreToolUse hook is replaced by plain deny rules. |
| 11 Claude isn't the only DNS writer | Folded: "DNS". |
| 12 Hetzner image dies with server | Folded at the restore root; verified. |
| 13 nothing watches the monitor | Folded at the monitor root, with the all-quiet message instead of a `check-drift` endpoint. |
| 14 Postgres 16 into 14 | Folded: "Photos" step 3. |
| 15 Stalwart in Docker | Folded: `journald` driver (verified), UID 2000, pinned `stalwart-cli`, apt-pin reason restated, `restart: always`. |
| 16 apt origins | Folded: "Base host". |
| 17 lock behavior can't be seen in a pass | Folded: settled by the live probe during this fold. |
| 18 disk headroom | Folded at the disk root: measure first, CX33 if over 6 GB raw, Vandelay on a workstation. |
| 19 Primary IPs tied to location | Folded: "Locations and types". |
| 20 Caddy certificate too early | Folded: "Photos" step 5. |
| 21 Hetzner role (optional) | Dropped as optional. Delete protection now covers an accidental console delete. |
| 22 Fastmail login on 907.life | Folded: first-week check in "After cutover". |
| 23 DMARC `t=y` caveat (optional) | Dropped as optional. |
| 24 pass ordering (optional) | Folded where near-free and it removes a wait: `m.907.life` moves to pass 4, the emergency vault's filling is assigned, the two dotfiles PRs land in turn. The dubplate "absent" state is dropped. |
| 25 auto-ban and loopback (optional) | Dropped as optional. |
| 26 "indefinite" wording (optional) | Folded at the archive root; verified liftable. |
| 27 ceremony (optional) | Folded, all three remove ceremony: Immich's admin pages leave Access, the link check moves to the monthly review, and the `ntfy` item leaves "Not checked". |

## Data review

| Finding | Disposition |
|---|---|
| B1 locks vs retention, prune consistency, `config` | Folded at the lock root. The corruption scenario is refuted by restic's source order. The proposed prune wrapper that aborts on a refused delete, and `check --read-data` after every prune, are refused: restic already treats a refused pack delete as harmless, the probe showed prune clean, and the weekly 10% check stays. |
| M1 inconsistent mail copy | Folded: "Mail, at 03:30" (grace period, clean exit, stop on first failure, trap, image digest). The `CONSISTENT` marker is refused, since stop-on-failure ordering does the same. The inhibitor is refused, since the reboot window (12:00 UTC) can't meet the 03:30 backup. |
| M2 age-key move unproven | Folded: "Migration order" step 5. |
| M3 1Password export and the offline key | Folded as a method call: the age key goes on paper in the existing kit, archives are encrypted to it. Not a fork: option (b) costs one line on a sheet that already holds the Proton phrase, and (c) cuts against the no-USB ruling. Listed in "Contestable calls". |
| M4 1Password changes after export | Folded: steps 3 and 8. |
| M5 irreversible-step preconditions | Folded: new "Irreversible steps". |
| M6 second operator's Fastmail user | Folded: "Irreversible steps" Fastmail row, triage includes his masks, the three @907.life masks in the address inventory. |
| M7 rollback strands new mailboxes | Folded: A and B start after T+30. Listed in "Contestable calls". |
| M8 imapsync paths | Folded at the rehearsal, owner, and sweep roots. |
| M9 contacts and calendars | Folded at the rehearsal root; the shared account is named. Extra `.ics` and vCard archives are refused; the fallback path imports them only when needed. |
| M10 workstation sync clients | Folded: "Cutover" steps 1 and 5, "Clients". |
| M11 server-gone restore | Folded at the restore root; the mail drill also starts from an image once. |
| M12 rebuild wipes data | Folded: rebuild order in "Claude's operating authority". |
| M13 in-place restore | Folded at the restore root. |
| M14 drill sends mail | Folded at the drill root. |
| M15 monitor unwatched | Folded at the monitor root, with the 12-hour repeat and `since=`. The extra healthchecks.io dead-man is dropped. |
| M16 outbound failure undetected | Folded: queue depth and oldest-message age in the heartbeat and "Alerts". The optional outbound probe is dropped. |
| M17 silent store corruption | Folded: nightly per-mailbox counts and the 2% alert; "Risks" no longer counts the migration archives as a defense. The fork to re-admit a weekly Vandelay layer is declined as a fork: the cut line that excluded it is an approved ruling. "Risks" names the 1.0 upgrade as the moment to revisit it. |
| M18 30-day window | Folded: the Worker's daily R2 check, which also replaces the backup success heartbeat. |
| M19 musicbox copy | Folded at the musicbox root. Corrected: musicbox serves nothing (dubplate is installed and disabled), so later changes can't be lost. |
| M20 upgrades untested | Folded: minor and major Stalwart and Immich upgrades run on a drill copy first. |
| m1 Trash expunge | Folded: rehearsal row. |
| m2 shutdown SIGKILL | Folded at the stop root; Docker's 10-second default verified. |
| m3 Docker majors | Folded: apt pin, majors in the monthly review. |
| m4 lock hygiene | Folded: `flock`, `restic unlock`, `--retry-lock` (verified). |
| m5 read-only tokens and locks | Folded: `--no-lock` (verified in source); drills use the emergency tokens. |
| m6 partial backups | Folded: exit 3 counts as failure; failed checks alert. |
| m7 dump freshness | Folded at the dump root. |
| m8 Immich rollback | Folded at the Immich root. |
| m9 pod self-update | Folded: version from the dump's file name, Postgres data wiped first. |
| m10 archive encryption | Folded at the archive root. |
| m11 masked map dies | Folded: archived before Fastmail closes. |
| m12 disabled-mask hits | Folded: triage step 5. |
| m13 emptying Trash | Folded: "Migration". |
| m14 probe edge cases | Folded at the probe root. |
| m15 probes and auto-ban | Folded as a "Not checked" row with a fallback. |
| m16 DNS drift | Folded with a simpler mechanism: every `dns.sh --apply` ends with a `--check` against public resolvers. The hourly Worker check is refused as machinery. |
| m17 `Conflicts=` rationale | Folded at the Docker root. |
| m18 Emergency Access needs Proton Mail | Folded: "Geoff's account" and owner item 7. |
| m19 second operator's restore path | Folded: repo read access, `--keep` re-attaches the IPs. |
| m20 US move final copy | Folded: "Periodic work". |
| m21 `p=reject` and other senders | Folded at the senders root. |
| m22 disk headroom | Folded at the disk root. |
| m23 catch-all | Folded: "Migration" address inventory. |
| m24 masked list backup (optional) | Dropped as optional; the reviewer judged it acceptable. |
| m25 monitor beyond the cut line (optional) | Refused: the alert ruling and the Cloudflare ruling postdate the cut line, and a hosted checker can't run the inbound probe. Recorded in "Contestable calls". |
| m26 shredding tmpfs (optional) | Folded: removes ceremony; the archive round trip comes first. |

## Verification round (2026-10-17)

A fresh agent read the folded spec at commit `1bf2f10` and wrote [2026-10-17-self-hosting-design-fold-verification.md](2026-10-17-self-hosting-design-fold-verification.md): 1 blocker, 7 major, 11 minor. Each finding was checked before it was folded, and the dispatching session gave direction on B1, M1 to M7, m2, m8, and m11. This round supersedes the first round's lock design: the rows above for mechanics 1 and 2, data B1, and data M18 describe a 30-day `data/` rule that this round replaces.

Checks made in this round:

- B1 reproduced locally with restic 0.19.1: after deleting only the packs from a first backup, `restore latest` restored 976.562 KiB of 3.815 MiB, and `check --read-data` reported "repository contains errors". The first round's live R2 probe never tested this, because it deleted only packs no snapshot used.
- `restic recover` after deleting every snapshot and index file: `repair index` rebuilt the index, the first `recover` failed with "nodes are not ordered or duplicate", and a second run saved a snapshot that restored both files.
- `gh repo view glw907/workstation`: `"visibility":"PUBLIC"`, and `secrets/values.age` is tracked there.
- dubplate's identity design (`dubplate/docs/superpowers/specs/2026-09-08-rung-5-identity-auth.md`, Fork 2) names Fastmail on 587, and the same spec names `pings@907.life` sending through Cloudflare.
- R2 pricing: $0.015 per GB-month, 10 GB a month free, no egress charge (Cloudflare's R2 pricing page). The growth estimate uses the Immich brief's 38.6 MB dump and the backups brief's note that gzipped dumps deduplicate poorly; the rest is unmeasured, and the spec says so.

| Finding | Disposition |
|---|---|
| B1 Age locks leave old packs deletable | Folded: `config`, `keys/`, and `data/` Indefinite, `snapshots/` 30 days, nightly `forget`, no automatic prune, growth estimate, a cleanup packet at 200 GB ("Lock rules", "Retention"). Every claim that the last 30 days were safe is rewritten, in "What changes", the lock `### Decide:` block, "Rulings needed", and "Risks". The recommendation flips to the Indefinite design. |
| M1 image drill boots a production copy | Folded differently from the proposed fix: the copy is dropped altogether, because a server made from an image holds every production secret on disk even behind a closed firewall. The image path is tested in place on the real mail server during the rehearsal, before MX moves (new rehearsal row). |
| M2 drill joins the tunnel | Folded: no `cloudflared` role, and `restore-drill.sh` refuses a role list holding `backup`, `health`, or `cloudflared`. The drill renders only the restic password and the read-only token. |
| M3 server-gone path can't make production | Folded: `--keep` is gone. `restore-drill.sh --hold` keeps a passed drill server behind the closed firewall, and `scripts/promote.sh` makes it production; Claude runs it only when the old server is already gone. The second operator's real path is written plainly: call Geoff, and copy any backup out with a read-only token. The Hetzner token leaves the emergency vault. |
| M4 emergency vault has no creator | Folded: Geoff's one FIDO2 session in the passwords pass creates both vaults and the agent tokens and shares `Servers emergency`. Claude stages values in a tmpfs file for Geoff to copy in. The drills read the read-only tokens from the age store until then. |
| M5 dubplate's Fastmail SMTP | Folded: senders text and table (Immich, dubplate, the pings Worker), cutover step 7, the Fastmail packet's evidence row, and "Music". |
| M6 late owner inputs | Folded: A's and B's addresses live only in the private `servers` repo; the Apple session is Geoff's to arrange; Geoff creates the two test accounts. Yahoo is dropped on evidence: its published rules match Google's (mail-cutover brief, section 1), and Microsoft is the documented problem receiver. Member C's vault move and the members' confirmations are drafted messages in "Later". |
| M7 the paper key and public ciphertext (owner fork) | Folded as a contestable call, by the dispatching session's direction, which raises it with Geoff in chat. The spec states the public-ciphertext fact and the storage rule (handwritten, sealed, locked away, never photographed or scanned) and names the passphrase-wrapped alternative. |
| m1 drill ACME | Folded: the closed firewall goes on before any service starts, which stops ACME without relying on an unverified Stalwart setting. |
| m2 who lifts a lock | Folded: `r2.sh` only adds rules, only Geoff lifts one, by hand, and the backup buckets' rules land after `init` and the first verified backup. |
| m3 delete protection overstated | Folded: reworded as accident protection, and the gate fails on `disable-protection` in the repo's scripts. |
| m4 alerts on normal operation | Folded: the snapshot alert fires only when a snapshot younger than 35 days disappears; the mailbox threshold is 10%. |
| m5 all-quiet false alarm | Folded: every 6 hours. |
| m6 urgent alerts before cutover | Folded: every mail condition goes to the routine topic until cutover day. |
| m7 drill count race | Folded: within 10 messages per mailbox for mail. |
| m8 purchase ceiling (owner fork) | Folded as a placeholder, by direction: "[CEILING: Geoff sets this]" in "Claude's operating authority". Workers Paid is back as a confirm-in-foundation item that comes to Geoff as a purchase if the account is on Free. Owed: the dispatching session fills the ceiling. |
| m9 A and B wait a month (owner fork) | Not raised as a `### Decide:` block: the packet's asks stay at two, and the dispatching session gave no direction. It stays in "Contestable calls" as one line Geoff can overrule. Owed: the dispatching session may raise it in chat. |
| m10 cut-line items | Folded: the MTA-STS Worker and the CI container checks are in "Contestable calls", and "per the cut line" is corrected. |
| m11 duplicated asks (optional) | Folded, since it removes duplication: "Rulings needed" is a pointer with one line per fork, and the evidence paragraph is a link to this record. |

Counts for this round: 19 findings, 17 folded, 2 left to the dispatching session (m8's ceiling value and m9), 0 refused outright.

## Geoff's chat rulings (2026-10-17)

Geoff ruled on the open owner calls in chat, and the spec's "Rulings" section now records them with the date.

- Spend ceiling: recurring services up to $40 a month in total across Hetzner, R2, and Cloudflare; any one-time purchase, new vendor account, or recurring total past $40 comes to him. This replaces the `[CEILING]` placeholder in "Claude's operating authority" and closes verification m8.
- The age key on paper, kept locked up at home. It leaves "Contestable calls" and closes verification M7.
- Workers Paid is already on the account. The confirm-in-foundation item and the conditional cost line are gone.
- Four mailboxes migrate. Household members A and B have their own Fastmail logins today, so they're migrated accounts, not new mailboxes. Consequences carried through the spec:
  - "What changes", "Who uses what", "Migration", the rehearsal's import, the sweeps, and the reverse imapsync all cover four accounts.
  - A and B each need a Fastmail API token, DAV app password, and IMAP app password. Whether a Fastmail admin can create them for another user is unverified, so it's an owner action Geoff arranges with each member, handed over through `secret-receive` (owner item 7, and a "Not checked" row).
  - Their client move at cutover is the configuration profile (cutover step 6). A rollback no longer strands anyone, so the "New mailboxes after T+30" contestable call and the matching cutover paragraph are gone, and verification m9 is moot.
  - The T+30 packet removes three users, not one, before the downgrade to Individual. The account's current plan is unverified (the mail-cutover brief lists Individual and Duo, and four users need more), and a "Not checked" row covers it.
  - Geoff's 5.14 GiB alone rules out a CX23, so the mail server is a CX33 (cost now about $24 a month). The mail pass measures the other three mailboxes before provisioning, and a Hetzner Volume carries the store past about 12 GB of raw mail.
  - The triage stays Geoff's 165 masks plus any the others hold. The second operator lists his own in the first week; Claude checks A's and B's over their API tokens in the mail pass.

tellgrader (`--register docs --profile docs-register`) exits 0 on the spec, and the brief parser accepts it.
