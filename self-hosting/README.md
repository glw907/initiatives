# Self-hosting

## Summary

This initiative would move Geoff's mail, photos, and music onto servers he runs himself, and his passwords and masked email onto Proton Pass. Two Debian 13 servers run every service in containers: a small one for Stalwart and 907.life mail, and a second for Immich and dubplate, which moves off `musicbox`. Pavilion pulls backups from both onto a USB drive, and one runbook in a new server repo covers every service. Success means Fastmail, PikaPods, and 1Password are cancelled, and the second operator can restart a service or restore a backup from the runbook alone.

## Motivation

Fastmail, PikaPods, and 1Password each hold part of the household's data on someone else's terms. The 1Password-and-Fastmail pairing made 165 masked addresses on fastmail.com, a domain Geoff can't take with him, so leaving Fastmail means changing each one by hand. Proton Pass's browser integration is part of why Geoff is moving off 1Password. Its custom alias domains put every future masked address on a domain he owns.

## Goals

- Mail for 907.life runs on Stalwart for four to five users. The two existing mailboxes (Geoff's and the second operator's), their contacts, and their calendars are migrated, and Fastmail is cancelled.
- The servers are sized for about 5 light Immich users and about 10 dubplate listeners (Geoff, 2026-10-17).
- No live masked address ends in fastmail.com. Every new masked address is a Proton Pass alias on a third-level domain Geoff owns.
- Immich runs on the media server with its full library, faces, and albums, and the PikaPods pod is retired.
- dubplate runs on the media server, and `musicbox` is retired.
- Proton Pass replaces 1Password on both workstations, including the age-key fetch, `sudo -A`, the browser integration, and the guard hooks, and 1Password is uninstalled.
- A third household member moves from 1Password to Proton Pass as well, on the household's Proton Pass plan (Geoff, 2026-10-17).
- Hylki replaces Thunderbird as the desktop mail client, and poplar points at Stalwart's JMAP endpoint.
- Pavilion backs both servers up to an encrypted USB drive on a timer, and a restore has been tested.
- One runbook in the server repo lets the second operator restart services and restore from backup, and it catalogs the official documentation for every service.
- The runbook records every Claude infrastructure change this initiative makes, including permission rules, guard hooks, secret access, and which sessions may reach the servers. It stays current as those change (Geoff, 2026-10-17).
- Mail filters can be managed through Stalwart's API. The filters themselves are written in a later session, after the migration.

## Non-goals

- An off-site backup copy. The USB drive on pavilion is the only backup, by Geoff's ruling of 2026-10-17.
- Migrating Fastmail's existing filters. The new filters start from scratch.
- dubplate's own build, which stays with the dubplate-server initiative.
- Poplar features beyond pointing it at the new account.
- Mail for any domain other than 907.life.

## Where the work lives

- A new server repo, to be created once the design is approved: provisioning, configuration, and the runbook for both servers.
- `workstation`: the 1Password-to-Proton-Pass move (`secret-receive`, `secret-set.sh`, `sync.sh`, `claude-sudo-setup`, the guard hooks, browser policies, layered packages), the backup timer on pavilion, the Hylki switch, and retiring Thunderbird.
- `dubplate`: the deploy target moves from `musicbox` to the media server.
- `poplar`: the account moves from Fastmail to Stalwart.

## Records

- Brainstorm state, rulings, open questions, and next steps: [specs/2026-10-17-brainstorm-decisions.md](specs/2026-10-17-brainstorm-decisions.md).
- Research: the per-area briefs in [research/](research/).

Status: proposed (2026-10-17), research complete; the design waits on Geoff's answers to the open questions.
