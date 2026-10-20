# Pass 3 (Immich cutover): pre-flight

Every step in Pass 3 that only Geoff or a household member can take, and the conductor's own checks before launch. Two items come before launch: Geoff's go with the window and the phone booked, and a dry run of his PikaPods sign-in. The rest waits for one named sitting, "The photos sitting", which is the upload-freeze window inside I1. `servers-photos` launches only once both "Before launch" items are done and every conductor check passes. Commit this file beside the launch prompt as `self-hosting/plans/2026-10-20-pass3-preflight.md`, because the prompt names that path.

What needs no step from Geoff: the pass creates no secret and touches no Proton Pass item, the lock, the probe, and the bucket listing use tokens already in the store, and every check in the sitting is read by the executor from the API, the journal, or DNS, never from Geoff's report.

## Before launch

### 1. [you: your go, the window, and the phone]

The window is the upload freeze. The executor needs about three hours of unattended work first (the lock, the bucket listing, the version check, and a review of the window's changes), so the window starts at least three hours after launch.

1. Pick a date and a start time for a window of about two hours. Keep it outside 01:30 to 04:00 UTC (17:30 to 20:00 in Anchorage until daylight time ends on 2026-11-01, then 16:30 to 19:00), because the server's nightly dump and backup run then.
2. Plan to be there for the first 15 minutes (S1 and S2) and the last 30 (S3 and S4). In between you can step away, but stay reachable, since a rollback needs you to start the pod again (R1).
3. Book a household member for the last 30 minutes. The phone needs the Immich app signed in to `https://photos.907.life` with the member's own account (Pass 2's sitting left it that way), mobile data, and the time to record a new one-minute 4K clip, which is about 150 MB. It must be new: the video from Pass 2's sitting is already in the library, and Immich refuses a duplicate.

**Check (the conductor):** STATUS records the window in UTC and Anchorage time and says that a household member is booked (by role, never by name, since the repo is public). The window starts at least three hours after the planned launch and stays out of the 01:30 to 04:00 UTC band.

### 2. [you: find the pod's Stop button]

PikaPods offers Claude no API, so stopping the pod at the freeze (S2) and starting it on a rollback (R1) are clicks in your dashboard. This dry run makes sure the sign-in works before the window depends on it. Your Proton account was re-created on 2026-10-18, so the PikaPods login may need finding first.

1. Sign in at <https://www.pikapods.com> with your own login.
2. Open the Immich pod's page and find its Stop and Start controls. Don't press either.
3. Note the pod's own address on that page (it ends in `pikapod.net`).

**Check (the conductor):** you say you reached the pod's page signed in. The conductor compares the address you noted with the target of the live `photos` CNAME that `cloudflare/dns.sh --check` lists (the next section); they must match.

### The conductor's own pre-launch checks (not Geoff)

Each identity, policy, and store the pass leans on is dry-run here, so nothing in the sitting fails on a sign-in or a missing name.

- The plan PR has merged and `/var/home/glw907/Projects/initiatives` is pulled; `test -f` passes on the plan, this file, and `self-hosting/plans/2026-10-20-pass3-prompt.txt`, since the executor reads them from that checkout.
- The pass-core "Execute" checks on `/var/home/glw907/Projects/servers`: fetched, on `main`, and `git rev-list --count HEAD..origin/main` prints 0. Its `.claude/worktrees/` is ignored.
- No other session is working the servers repo or orpheus: `claude agents --json` lists no `servers-*` executor, and no other pass plans an `apply.sh orpheus` before the cutover PR merges (an apply from `main` would drop `photos.907.life` from Caddy).
- `git -C /var/home/glw907/.dotfiles diff --quiet -- secrets/values.age` is clean.
- The lock's precondition holds: `origin/main:secrets/values.age` decrypts (to `/dev/shm`, under a trap) to a `RESTIC_PASSWORD_ORPHEUS` whose SHA-256 equals that of `/etc/servers/restic-password` on orpheus. Compare hashes only.
- `bash scripts/dry-run.sh hcloud cf-ws-servers r2-orpheus-rw r2-backups-ro r2-archive-rw pikapods-sftp immich-api` passes.
- The pod's API key can start the final dump. With the key in a curl config file, never an argument, `GET https://photos.907.life/api/api-keys/me` lists `all` or `job.create` among its permissions, and `GET /api/admin/database-backups` lists the pod's dumps. Note the newest dump's version in STATUS; the pod updates itself, and v3.3.4 came out on 2026-10-20.
- The `music-library` pair reads: an rclone S3 remote built from `MUSIC_R2_RO_ACCESS_KEY_ID` and `MUSIC_R2_RO_SECRET_ACCESS_KEY` in the environment lists the bucket's top level (`rclone lsf --max-depth 1`) and exits 0.
- `bash cloudflare/dns.sh --check` passes and lists `photos` as undeclared. A `GET /zones/<id>/dns_records?name=photos.907.life` with `CF_WS_SERVERS_TOKEN` shows one proxied CNAME, and its target matches the address Geoff noted in item 2.
- `bash cloudflare/r2.sh --check` passes, and a `GET` of `servers-backup-orpheus`'s lock configuration lists no rules.
- `servers-scratch-stale` exists and holds its one object under `snapshots/`, uploaded 2026-10-19 about 23:18 UTC.
- `ssh -o BatchMode=yes geoff@orpheus.907.life true` exits 0.
- `systemctl --user is-active monitor-subscribe.service` prints `active`, and the monitor's `/alerts` lists no open condition, so any condition during the pass belongs to it.
- The `pavilion-scripts` and `pavilion-claude` agent tokens expire in January 2027, well past day seven, so the token-expiry standing answer doesn't fire.

## Secrets the pass needs

Names checked on 2026-10-20 against `~/.local/secrets`, by name only. Every one is present, none comes from Geoff, and the pass creates none.

| Name | Task |
|---|---|
| `CLOUDFLARE_API_TOKEN` (`ws-admin`) | I1: `r2.sh` (the lock), the scratch bucket's deletion |
| `CF_WS_SERVERS_TOKEN` | I1: `dns.sh`, `deploy.sh monitor`, the D1 API |
| `CF_ORPHEUS_R2_BACKUP_RW_TOKEN`, `_KEY_ID`, `_SECRET` | I1: the lock checks with the server's own token |
| `CF_WS_R2_BACKUPS_RO_TOKEN`, `_KEY_ID`, `_SECRET` | I4: `restic snapshots` and `check --read-data` |
| `CF_WS_R2_ARCHIVE_RW_TOKEN`, `_KEY_ID`, `_SECRET` | I4: `archive.sh` |
| `RESTIC_PASSWORD_ORPHEUS` | I1's precondition, I4 |
| `IMMICH_PIKAPODS_API_KEY` | I1: the final dump and the statistics; it keeps working on orpheus after the restore |
| `PIKAPODS_SFTP_HOST`, `_USER`, `_PASSWORD` | I1: the delta pull |
| `MUSIC_R2_RO_ACCESS_KEY_ID`, `MUSIC_R2_RO_SECRET_ACCESS_KEY` | I3 |
| `HCLOUD_TOKEN_SERVERS` | I2: the snapshot, and the drill if the upgrade is a minor |

## The photos sitting

**When:** the window booked in item 1, once the executor has written `## Stop: the photos sitting` in its servers PR body. **Who:** Geoff, plus the household member with the phone for S3. **How long:** about two hours, with Geoff needed at the start and the end. The executor messages `conductor-servers` before each step, and the conductor relays it to Geoff and sends back his word that it is done.

### S1. [you: the freeze message] (I1, start of the window)

Send this to the household, in your own words if you like:

> I'm moving our photo server to its new home now. For the next two hours, please don't add photos: open the Immich app and turn backup off. Anything you take stays on your phone and backs up when you turn it on again. I'll tell you when it's done.

Then tell the conductor it's sent.

**Check (the executor):** none; the counts the executor reads at the dump are the record of the freeze.

### S2. [you: stop the pod] (I1, about 10 minutes in)

When the conductor says the final dump is downloaded, open the Immich pod's page at PikaPods and press Stop. Tell the conductor when the pod shows as stopped.

**Check (the executor):** `https://photos.907.life/api/server/ping` answers with a Cloudflare 52x error, and the pod's SFTP still lists its folders (PikaPods' own backup steps copy files from a stopped pod). While the pod is down, pavilion shows a routine "Media check failing" notice; it clears after the switch.

### S3. [household member: a large upload from outside the house] (I1, near the end)

When the conductor says photos are switched over:

1. Turn Wi-Fi off, so the phone uses mobile data.
2. Open the Immich app. It is still signed in to `https://photos.907.life`; change nothing.
3. Record a new one-minute 4K clip (about 150 MB). An older video won't do if it is already in the library. Select the clip in the app, upload that one item, and wait until it finishes.
4. Turn Wi-Fi back on.

**Check (the executor):** the Immich API lists, for that member, an asset of at least 150 MB created after the switch from the mobile app, and the stored original's SHA-1 equals the asset's recorded checksum. If the phone can't make the window, the switch stands: the executor proves a 150 MB upload from pavilion with the Immich CLI, and the phone's upload moves to day seven (the plan packet asks you to confirm this).

### S4. [you: the freeze-end message] (I1, end of the window)

When the conductor says the upload checked out, send:

> Photos have moved, and the app works as before with nothing to change. Please turn backup back on in the Immich app. If the app keeps asking you to sign in this week, or something looks missing, tell me.

**Check (the executor):** none. The sign-in question comes back at day seven, in the PikaPods packet.

### R1. [you: start the pod again] (only on a rollback, or a repeat of the window)

If the conductor says the cutover is rolling back or must repeat from the dump, open the pod's page at PikaPods and press Start, then tell the conductor. On a rollback, also send S4's message, since the photos are back where they were.

**Check (the executor):** the pod's own address answers `/api/server/ping`; after a rollback, `photos.907.life` resolves to Cloudflare again and answers through the pod.

## Day seven

Nothing from Geoff until the packet, with one exception: if the window took the CLI path because the phone couldn't come, a household member does S3's steps once before day seven, and the executor reads the upload in I4. The conductor relaunches `servers-photos` on day seven, counted from the switch, and the executor runs I4 on a new branch. Its PR carries the evidence rows for deleting the pod. The conductor sends one packet with that PR and the deletion ask, which asks Geoff to confirm that no one reported a sign-in loop. Once he approves, he deletes the pod in the PikaPods dashboard; `bash scripts/dry-run.sh pikapods-sftp` failing afterward is the check that it's gone.

## Owed, outside this pass

- The Immich admin login in `Servers emergency` (Geoff's own step, carried from Pass 2).
- The second operator's identity, Unix account, patterns lines, first sign-in on `ssh-orpheus.907.life`, and console password.
- servers BACKLOG #1 (`promote.sh` sets no hostname) matters only for a production rebuild, and this pass runs none.
- The `music-library` bucket and the music library itself move to dubplate's own pass, per Geoff's 2026-10-20 ruling; I3 only records what the bucket holds.
