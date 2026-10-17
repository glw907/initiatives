# Self-hosting: brainstorm decisions and handoff

Initiative: self-hosting

This file holds the state of the 2026-10-17 brainstorm on pavilion, so another session can pick up the design. The research briefs in [../research/](../research/) carry the evidence and citations. Household members other than Geoff appear here by role, because this repo is public. The next session gets their names from Geoff or from the handoff message.

## Geoff's rulings

These came from Geoff in the brainstorm on 2026-10-17.

- Mail moves from Fastmail to Stalwart for 907.life. Stalwart serves four to five users. Two existing Fastmail mailboxes migrate (Geoff's and the second operator's), with contacts and calendars.
- Mail is the biggest risk in the initiative.
- Immich moves off PikaPods (photos.907.life), and PikaPods is retired once the migration is done.
- dubplate moves to the new media server, and `musicbox` is retired.
- Proton Pass replaces 1Password completely, for Geoff and for a third household member who also uses 1Password. Its browser integration is part of the reason. Geoff asked for the choice to be double-checked, and the password-manager comparison confirmed it. He has not yet ruled on the result.
- Flawless browser integration, and preferably OS integration, for passwords and masked addresses is critical. That includes macOS and iOS.
- Every new masked address goes on a third-level domain Geoff owns, as a Proton Pass custom alias domain. Geoff understands the triage of the 165 @fastmail.com masked addresses.
- Hylki replaces Thunderbird on the workstations.
- API-managed mail filters are wanted. They are new filters, not migrated ones, and they come in a later session after the migration.
- Backups: pavilion pulls to an external USB drive. The USB drive is the only backup copy, and an off-site copy is ruled out.
- The runbook lives in the new server repo. The second operator (he/him) follows step-by-step terminal commands. He must be able to restart services and restore from backup using the runbook alone. The runbook also catalogs the official documentation for every service, and it records every Claude infrastructure change the initiative makes.
- Two servers are fine. Geoff has no objection to two servers, but wants nothing over-engineered for a light family-and-friends setup.
- Priorities: low cost, stable, performs well.
- Load: about 5 light Immich users, about 10 dubplate listeners, 4 to 5 Stalwart users.
- Hetzner and Debian were defaults, not researched positions. Geoff wants the best option on evidence, with no single-vendor lens. OVH's API quality for Claude-managed operation matters as much as price.
- Order of the work doesn't matter much. Immich is easy; mail and passwords are hard.
- Reasoning effort is set to high for the planning.

## Claude's calls so far

These are recommendations from the research, not yet approved in a design.

- **Containers everywhere.** Docker Compose runs every service on both servers, and Stalwart uses host networking so it sees real client addresses.
- **OS:** Debian 13 on both servers ([server-os](../research/2026-10-17-server-os.md)). AlmaLinux 10 is the runner-up. Revisit bootc when AlmaLinux drops its "experimental" label.
- **Hosting:** the split, with mail on a Hetzner CX23 in nbg1 or hel1 and media on an OVHcloud VPS-2 2027 in US-WEST-OR (Hillsboro), for about $17 a month ([hosting](../research/2026-10-17-hosting.md), [ovhcloud-business](../research/2026-10-17-ovhcloud-business.md)). The reasons: Hetzner's API is mature and its firewall is stateful, which suits mail, where latency doesn't matter. OVH is 53 ms from Anchorage with unlimited traffic, which suits media. Two accounts mean losing one can't take everything. Every US OVH `/vps` endpoint is BETA. **Awaiting Geoff's yes.**
- **Outbound mail:** through a relay on port 587 from day one (Amazon SES or SMTP2GO). The port 25 request is only a fallback ([mail-cutover](../research/2026-10-17-mail-cutover.md)).
- **Mail cutover:** a rehearsal with a full copy and checked counts, then an MX switch with short TTLs. A date-limited imapsync catches late mail. Fastmail stays paid on the Individual plan as the rollback target, since the Basic plan has no API, IMAP, or DAV.
- **Stalwart:** a pinned version, cutting over on 1.0.1 or later if it has shipped by then. Backups use stop, copy, start on RocksDB. Change the 30-day Trash and Junk expunge before importing. Spamhaus needs a DQS key ([stalwart](../research/2026-10-17-stalwart.md)).
- **Immich:** restore from PikaPods' own daily database dump plus `UPLOAD_LOCATION`. Rehearse the Postgres 16 to 14 question. photos.907.life goes DNS-only behind Caddy, because Cloudflare's proxy caps uploads at 100 MB ([immich](../research/2026-10-17-immich.md)).
- **Backups:** each server writes a consistent export, and pavilion pulls it with rsync over a read-only forced-command key, then runs restic into a LUKS2 USB drive. A root system timer with `Persistent=true` runs the job ([backups](../research/2026-10-17-backups.md)).
- **Proton Pass on the workstations:** a `Workstation` vault holds only the age key and is read through a vault-scoped agent token. Browser extensions are installed by policy, `pass-cli` comes from Homebrew, and there is no desktop RPM at first ([proton-pass](../research/2026-10-17-proton-pass.md), [password-manager](../research/2026-10-17-password-manager.md)). Write an exit plan to point the alias subdomain at a Stalwart catch-all. Export aliases once a year.
- **The cut line against over-engineering,** proposed and awaiting Geoff:
  - Keep: SPF, DKIM, DMARC, and the relay; pinned versions; automatic security updates; the USB backup with one restore before go-live and a manual drill twice a year; the mail rehearsal and rollback; one runbook and one repo.
  - Cut or simplify: monitoring becomes one free uptime check plus a backup dead-man ping. Backup verification becomes a weekly integrity check. No Vandelay second mail layer. No DANE or DNSSEC. MTA-STS only if it is a one-time record. CI is linting only. A root-only key file replaces TPM-sealed credentials.

## Open questions for Geoff

1. Hosting: the split (recommended), or all OVH.
2. The cut line above.
3. A one-week Proton Pass trial for each family member before 1Password is cancelled. Which devices does the fourth Stalwart user mostly use: Apple, Android, or both?
4. Whether to open the tail-guard narrowing as its own workstation PR. The patch is described under "Current state".
5. Smaller calls that default to Claude's pick unless Geoff objects:
   - Billing: monthly through the cutover, then the 12-month term.
   - The alias subdomain: something short, such as `m.907.life`.
   - Keep all five Immich users.
   - Import Fastmail's Trash and Junk or not.
   - `sudo -A`: a zenity paste dialog or a silent token read (the Proton Pass brief recommends the dialog).
   - Accept a public IP for photos.907.life.
   - Geoff enables SFTP on the PikaPods pod and pauses uploads for a short cutover window.
   - Relay choice: SES or SMTP2GO.
   - How much Claude may do through the OVH and Hetzner APIs without asking. The recommendation: listed routes only, with ordering and termination staying with Geoff.

## Current state

- The initiative record is `status: proposed`. All the research briefs are written. No server, account, DNS record, or relay has been created. Nothing runs on any host for this initiative.
- Workstation PRs merged on 2026-10-17:
  - #81 adds `IMMICH_PIKAPODS_API_KEY` to the age store and the registry.
  - #83 allows `WebSearch` and `WebFetch`.
  - #84 adds 28 allow rules for routine read-only commands.

  A workstation that pulls these needs `sync.sh --local` and `claude-tooling-sync apply`.
- Not landed: a narrowing of `claude-tail-guard`. It exempts `gh pr checks` without `--watch` and any guarded command run with `--help` or `-h`, and the hook's 38 tests pass with it. The auto-mode classifier blocked the gate as self-modification, because guard hooks are outside the standing allow-rule permission. The patch exists only in pavilion's session scratchpad. Re-create it from this description if Geoff approves.
- The 1Password item "immich" for photos.907.life has stale credentials: the server rejected its admin email and password. Geoff should update it.
- The OVHcloud FY26 annual results come out on 2026-10-20. Re-read the business brief's verdict against them before ordering.

## Next steps

1. Get Geoff's answers to the open questions.
2. Write the design at `specs/2026-10-17-self-hosting-design.md` from the briefs and these rulings. Use the `writing-voice` standard and run the builder check (`superpowers:brainstorming`).
3. Send the design to Geoff through Design & PR Approvals.
4. After approval, create the server repo (proposed name `servers`), add it to `initiative.yaml`, and write the pass plan with `superpowers:writing-plans`. The plan's first tasks are the low-risk ones: provision and harden the media server, then rehearse the Immich restore and the backup restore.
