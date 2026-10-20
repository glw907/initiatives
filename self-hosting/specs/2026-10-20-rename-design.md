# Rename pass: orpheus and ward

## Brief

This pass renames the media server to orpheus in place and sets the mail server's name to ward before Pass 5 builds it, with fresh backup buckets under the new names.

Geoff approved this design in chat on 2026-10-20 ("A clean rename for everything. We can regen backup buckets."). The pass runs after Pass 2 merges and before Pass 5.

Initiative: self-hosting

## Outcome

The media server is **orpheus** and the mail server is **ward**, in every identifier: Hetzner names, hostnames, DNS, the tunnel and Access app, the monitor's heartbeat keys, R2 buckets, secret names, the repo, and the docs. `media`, `mail`, and `music` stay as service names, each a CNAME to its machine. Geoff ruled the theme on 2026-10-20 (Venture Bros.: Orpheus, and Watch and Ward of the Guild), replacing the earlier bragi and gna.

## What changes

1. **Repo.** Each host's identity takes the new name: `hosts/orpheus` and `hosts/ward`, the firewall files, `provision.sh`'s host list and Primary IP names, `project.env`'s hostnames, the restore drill's server names, `apply.sh` and `promote.sh` targets, the monitor's source, config, and tests, the secret templates, the runbook, `EMERGENCY.md`, and the decisions log. About 25 files.
2. **Hetzner, in place.** `hcloud` renames the server, its two Primary IPs, and its firewall; `hostnamectl` sets the box's hostname; the PTR records become `orpheus.907.life`. Scripts change before the live rename, since `provision.sh` and `promote.sh` look resources up by name.
3. **DNS.** `orpheus` holds the A and AAAA records. `media` and `music` become CNAMEs to orpheus. Mail's MX, its PTR, its HELO, and the MTA-STS policy name `ward.907.life` directly, since an MX target cannot be a CNAME (RFC 2181 section 10.3). `mail` becomes a CNAME to ward when Pass 5 builds it. `music` gets no certificate request until dubplate arrives with its own host records.
4. **Browser terminal.** A tunnel cannot be renamed, so the pass creates `servers-orpheus` with a new token, an `ssh-orpheus.907.life` Access app (GitHub identity, `geoff@907.life`), and a new short-lived certificate key in `hosts/orpheus/ca.pub`. The old `ssh-media` tunnel and app stay up until a sign-in through the new one is proven, so the box is never without a way in. Then the old tunnel, app, and DNS row are deleted.
5. **Monitor.** The heartbeat keys and tokens become `orpheus` and `ward` in three steps: the Worker accepts both keys, the box switches its health env, then the old key and token are dropped. No false down alert fires in between.
6. **Backups, regenerated.** New buckets `servers-backup-orpheus` and `servers-backup-ward` with the same lifecycle rules, new bucket-scoped R2 tokens, and a new restic repository with a new password, so snapshots carry the `orpheus` host tag from the first one. The read-only restore token is re-scoped to the new buckets. The new repository takes a backup and passes a restore drill before the old buckets and tokens are deleted. The old buckets hold only rehearsal data, which the cutover wipes anyway.
7. **Secrets.** Every host-named secret takes the new name through `secret-set.sh` (for example `RESTIC_PASSWORD_ORPHEUS`, `TUNNEL_TOKEN_ORPHEUS`, `HEARTBEAT_TOKEN_ORPHEUS`, `CF_ORPHEUS_R2_BACKUP_RW_*`, and the ward equivalents), with the registry rows in both repos changing in the same commit. The old names are deleted from the store once nothing reads them. The `Servers emergency` vault's items are replaced with the new restic password and restore-token pair through `claude-pass`, and each is read back by hash.

## Out of scope

Building ward (Pass 5 builds it under this name), installing dubplate, the floccus WebDAV sync, and the Immich admin login for the emergency vault (Geoff's own step).

## End-to-end check

- Sign in at `ssh-orpheus.907.life` with GitHub and run `sudo -n true`.
- `photos-new` loads.
- orpheus's heartbeat stays green through the switch, with no down alert.
- A backup lands in `servers-backup-orpheus`, the snapshot check passes, and a restore drill passes.
- `media.907.life` and `music.907.life` resolve through orpheus, and the MTA-STS policy names `ward.907.life`.
- No identifier named `media` or `mail` remains for a machine, by a repo grep with an allowlist for the service names.

## Risk class and estimate

`auth-data` and `live-account`: it touches Access, the tunnel, secrets, and the live server. About 340 path minutes.
