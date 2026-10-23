# Backlog 2 plan review: data integrity and failure risk

Target: `self-hosting/plans/2026-10-22-backlog-2-plan.md` (initiatives `f36b477`), against the design `specs/2026-10-22-backlog-2-design.md` and the servers repo at `e036a70`. Read-only; nothing was run live.

Counts: 1 blocker, 7 major, 10 minor. Three findings are OWNER FORKs (M2, M3, M4).

## Blocker

### B1. The health state file cannot be written, so the debounce silently stops `webdav_ok` from ever going false

- Severity: blocker. Tag: `correctness`.
- Location: plan:27 (T7); `roles/health/systemd/servers-health.service` (`ProtectSystem=strict`, no `ReadWritePaths`); `roles/health/health.sh:76-89`.
- Defect: T7 keeps "one line of state in a root-only file under `/var/lib/servers`", but the health unit runs with `ProtectSystem=strict` and no writable path, so `/var/lib/servers` is read-only to it. Every write fails. Under the rule "false only when the previous run also failed", a state file that never records a failure means `webdav_ok` is never false: a plaintext bookmarks file or a dead rclone instance stops reaching the monitor. `health.sh` exits 0 by design and swallows the error. The unit tests run with `HEALTH_*` paths in a temp directory, and the after-merge check ("the next heartbeat carries `webdav_ok: true`") passes in this broken state. Nothing in the plan catches it.
- Fold: in T7, give the unit a writable state path (`StateDirectory=servers-health`, or `ReadWritePaths=/var/lib/servers`; prefer the separate `StateDirectory` so systemd does not take over the mode of the backup's directory). Write the file with tmp plus `mv`. If the state write fails, report `webdav_ok=false` at once, so the failure points toward an alert. Add that case to `tests/health.test.sh`, add the unit file to T8's golden pins, and add to "After merge": `systemctl cat servers-health.service` shows the writable path, and the state file exists after one timer run.

## Major

### M1. `--keep-stopped` goes through the same restart trap as the nightly run, so a share can come back up before the wipe

- Severity: major. Tag: `correctness`.
- Location: plan:22 (T2, "The nightly run and `--keep-stopped` stop every active `webdav@` unit ... and start them again after the restic backup, through the same EXIT trap"); `hosts/orpheus/host.env` (`STOP_CMD` already stops `webdav@*`); `infra/provision.sh:413-416` (checks only `SERVICE_UNIT=immich.service` before the wipe).
- Defect: on the rebuild path, any webdav unit running after the final backup takes Floccus writes that the wipe destroys. The plan's sentence is safe only if the executor reads "them" as "the units this run stopped" (none, because `STOP_CMD` stopped them all). A "start every member's unit" reading, or a unit that systemd restarts while in `activating`, restarts the share before the wipe, and `provision.sh` never checks webdav. This conflicts with the plan's own rule for dubplate ("`--keep-stopped` does not restart dubplate on exit").
- Fold: state in T2 that `--keep-stopped` never starts a webdav unit and refuses (fails `manifest`) when any `webdav@` unit is not `inactive`, reusing `server-restore`'s `webdav_units` filter (`server-restore:201`). Add a test: under `--keep-stopped`, an active webdav unit refuses, and no webdav unit is ever started.

### M2. The nightly webdav outage covers the whole restic backup, not the count and copy the design approved (OWNER FORK)

- Severity: major. Tag: `correctness` (it departs from the design and causes alert noise).
- Location: plan:22 (T2, "start them again after the restic backup"); design Outcome 2 ("stops the `webdav@*` units for the count and the copy ... as it already does for dubplate"); `roles/backup/systemd/servers-backup.service` (`TimeoutStartSec=12h`); `servers-backup:80` (`--retry-lock 30m`); `cloudflare/monitor/src/alerts.ts:14` (`MEDIA_PROBE_FAILURES = 3` at a 5-minute cron).
- Defect: the plan keeps the shares stopped through `rst backup`, which covers the whole Immich library and `/srv/music`. After a heavy upload day, or with a 30-minute lock wait, that runs well past 15 minutes. `dav_ping` then opens `media_down` after three 5-minute failures, and `health.sh:81`'s loopback 401 check fails for two readings in a row, so the new debounce still raises `webdav_ok` false. The result is routine alerts at night, and the shares are down for the household. The design's dubplate pattern (stop, copy to staging, restart, then back up the staging copy) does not drop in, because `server-restore` restores only `/srv/webdav` by path (`server-restore:55-63`; see M5 for the same gap with dubplate).
- Options:
  - (a) Keep the plan's shape: stop the shares through the backup. First read the recent `servers-backup` run durations from the journal (read-only). Accept this only if the longest run is well under 15 minutes, and record the reasoning in `## Decisions`.
  - (b) Follow the design: copy `/srv/webdav` to a staging directory while the shares are stopped, restart them within seconds, and teach `server-restore` to map the staging path back to `/srv/webdav`. This also fixes M5. It costs about 30 to 40 more minutes in T2 and T3.
  - (c) Keep the plan's shape, and also have the backup suppress the health 401 check while its own lock is held. The `dav_ping` noise remains.
- Recommendation: (a), gated on the measured durations. Fall back to (b) if any recent run took more than about 10 minutes.

### M3. The nightly snapshot pairs the 02:00 dump with 03:00 files, and T5's 250-file allowance hides the photos that fall between them (OWNER FORK)

- Severity: major. Tag: `correctness`.
- Location: plan:25 (T5, "fail only past 250"); `servers-backup:123-144` (nightly takes the newest dump, from Immich's 02:00 job); `scripts/drill-remote.sh:352-363` (the regeneration makes the drill's thumbnails fresh).
- Defect: a photo uploaded between 02:00 and 03:00 is in the snapshot's `upload/` or `library/` but has no row in the dump, so after a restore Immich does not show it. Phones commonly auto-upload overnight while charging. The 208 orphans #10 ruled harmless were production thumbnails. On the drill, `thumbs/` is regenerated from the database, so orphans there should be close to zero, and a flat allowance of 250 mostly forgives orphan originals, which is the class that matters. The new comparison would pass a backup that is missing up to 250 photos from the database.
- Fold (needed under either option): count orphans per directory. Allow them only under `thumbs/` and `encoded-video/` (derived files). Print orphans under `library/`, `upload/`, and `profile/` separately, with their count and first ten masked paths, and fail on them unless the owner picks (b) below.
- Options for the root cause:
  - (a) The nightly run also triggers `backupDatabase` and waits for the fresh dump, reusing T2's function, which closes the window. This is about 10 minutes more in T2, and dump time adds to the nightly run.
  - (b) Keep the skew, report orphan originals in the drill log as a known window, and file the window as a backlog item.
- Recommendation: (a). The code is already being written for `--pre-stop`, and it removes a recurring nightly loss window instead of documenting it.

### M4. A member the snapshot predates: the plan lets the executor choose, the criterion it names is wrong, and the safe answer is to keep the live directory (OWNER FORK)

- Severity: major. Tag: `correctness`.
- Location: plan:23 (T3, "create the empty directory ... and start it, or report it by name and exit non-zero, whichever the role's installer shows is safe"); `server-restore:222-228` (an older snapshot with no webdav key keeps the live `/srv/webdav`); `server-restore:262-268` (the swap moves the whole live `/srv/webdav` to `.pre-restore`).
- Defect: after the swap, a newer member's real bookmarks sit in `/srv/webdav.pre-restore/<name>`, and the plan's two options are to start that member on an empty directory or to leave them stopped. An empty share in front of a Floccus client with a sync cache can make the client read the server as "everything deleted". Floccus's mass-delete failsafe may stop that, but the plan should not depend on it. The installer cannot answer the question, because the risk is in the client's behavior, not the directory's owner or mode. It is a ruling, not a mechanic, and the plan has no stop for it. "Exit non-zero" after the swap also lands on `fail_after_swap`-style partial states that the script's messages don't describe.
- Options:
  - (a) Carry the member's live directory forward from `/srv/webdav.pre-restore/<name>` into the restored `/srv/webdav`, then start the member's unit. This matches the script's existing rule for a snapshot that predates the whole share (`:222-228`), and no data is lost.
  - (b) Leave the member's unit stopped, print their name and how to move the directory back by hand, end with exit 0 and a clear "not every service started" line, and add a runbook line.
  - (c) Create an empty directory and start the unit (the plan's first option).
- Recommendation: (a), and never (c). Also add a runbook note that restoring the share from any older snapshot rolls each member's Floccus back. Members should check before their next sync, because a client may treat removed items as deletions.

### M5. Dubplate's staging path is unrestorable, and `--keep-stopped` restarts dubplate inside the copy, not only in the trap

- Severity: major. Tag: `correctness` (latent until dubplate has a unit; the design tests it against fakes only).
- Location: `servers-backup:213-227` (backs up `$staging` = `/var/lib/servers/dubplate-staging` when the unit is active); `servers-backup:219` (`restart_dubplate` called directly after the rsync); `server-restore:55-63,235-237` (restores and requires `/var/lib/dubplate` by path).
- Defect: once dubplate runs on orpheus, every snapshot stores it under the staging path. Then `server-restore` aborts with "the snapshot holds no /var/lib/dubplate", and that abort blocks the whole restore, Immich included. That includes the restore right after a rebuild, which comes after the wipe. Separately, T2's "`--keep-stopped` does not restart dubplate on exit" leaves `:219` restarting it straight after the copy, so a T2 that edits only the trap still restarts dubplate before the wipe.
- Fold: in T2, `--keep-stopped` stops dubplate, skips the staging copy, backs up `/var/lib/dubplate` itself, and never calls `restart_dubplate`. Test that the restic arguments name `/var/lib/dubplate` under `--keep-stopped`. File the nightly staging-path restore gap under `## Found, not done` (or fold it in with M2 (b)).

### M6. Every-file ciphertext check: Floccus's own lock file is plaintext

- Severity: major. Tag: `correctness`.
- Location: plan:27 (T7, "check every regular file ... skipping rclone's partial files"); `health.sh:82-87`.
- Defect: Floccus's WebDAV adapter, as I recall its source, takes a lock by uploading `<file>.lock` with a small plaintext body, and removes the file when the sync ends. A client cut off mid-sync leaves the lock behind until a client breaks it. T2's nightly stop is exactly such a cut-off. Under T7's rule, the lock file is a non-envelope file, so a stale lock across two readings gives `webdav_ok=false` and a routine alert for a harmless state. Confidence is medium: confirm against the Floccus release the household runs.
- Fold: before writing T7, read Floccus's WebDAV adapter for every file it writes besides the bookmarks file, and skip those by exact name pattern (for example `*.xbel.lock`, and only when the body matches the lock marker). Add a test with a lock file present, and record the source line in `## Decisions`.

### M7. Whether the API key can start the queue is never checked, and a 403 has no standing answer

- Severity: major. Tag: `correctness`.
- Location: plan:22 (T2 live probe); plan:44 (the standing answer covers only "answers but no dump"); `servers-backup:113-120` (the key in `backup.env`, inherited from the pod, so its permission set is unknown).
- Defect: `PUT /api/queues/backupDatabase` needs a queue or job permission that a key scoped for `server.statistics` and `server.about` lacks. If the key is scoped, every rebuild after the merge refuses at `--pre-stop`. That fails closed, but it disables the rebuild path, and the T2 probe hits it with no answer in the plan. Fixing it means minting or rescoping a key and changing `backup.env` and the age store, which is a secret-store change and a stop.
- Fold: add a read-only first step to T2. Read the key's permissions (`GET /api/api-keys/me`, or the `api_key.permissions` row) before writing code. Add a standing answer: if the key lacks the permission, stop for the conductor, since a new key is a secret change, and list T2's live proof under `## Not checked`.

## Minor

### m1. The dump wait: in-progress files, which baseline to compare against, and a job queued behind the nightly job

- Severity: minor. Tag: `correctness`.
- Location: plan:22; design Outcome 1 ("a dump newer than the call").
- Defect: the plan compares against "the newest dump's mtime", while the design compares against the call time. If the 02:00 job is still running when `--pre-stop` calls, the nightly dump lands first and satisfies the plan's test. Immich is then stopped while the job the call queued is writing, which leaves a `.sql.gz.tmp` behind (it also gets backed up, and makes `health.sh:69`'s dump age read fresh). The plan also doesn't say what a failing `gunzip -t` means: still being written, so keep polling, or corrupt, so refuse. That is the "corrupt new dump" test, which has no stated outcome.
- Fold: compare against the call's epoch, as the design says. Accept only a `*.sql.gz` (Immich writes `.sql.gz.tmp` and renames it; confirm the shape from the live probe's listing) whose mtime is past the call, then `gunzip -t`. A rename-complete file that fails `gunzip -t` refuses at once. State both outcomes in the test list. Add "never between 01:45 and 04:00 UTC" to the rebuild runbook line, which also covers m6.

### m2. The 10 MiB rule flips from failing to skipping

- Severity: minor. Tag: `correctness`.
- Location: plan:27 ("skipping ... files past 10 MiB as today"); `health.sh:84-86` (today a file past 10 MiB sets `webdav_ok=false`).
- Defect: the plan's wording turns a failing condition into a skip, so a large plaintext export passes.
- Fold: keep "a file past 10 MiB fails" (or have Geoff rule a change), and test it.

### m3. Edge cases in stopping the shares at night

- Severity: minor. Tag: `correctness`.
- Location: plan:22; `servers-backup:102-110`.
- Defect: the plan doesn't say what happens when one `systemctl stop webdav@x` fails, whether a unit that systemd is restarting (`activating`) counts as active, or whether the unit is recorded before the stop (as `dubplate_stopped=1` is set before `:217`). A kill between the stop and the record leaves a share down.
- Fold: record each unit before stopping it, and select units with `server-restore`'s non-inactive filter. Treat a failed stop as `fail webdav`, which the trap undoes. Add one test for that path.

### m4. The drill comparison can pass on an empty or misread query

- Severity: minor. Tag: `correctness`.
- Location: plan:25 (T5); `drill-remote.sh:394-397`.
- Defect: the database stores container paths (`/data/...` or `/usr/src/app/upload/...`), not `/srv/immich/library`. Also, `asset.encodedVideoPath` may have moved into `asset_file` by v3.x. A wrong prefix or column that yields zero rows reports "no database path missing", and that half of the check passes trivially.
- Fold: read `\d asset` and `\d asset_file` on the drill first, and run the query with `ON_ERROR_STOP`. Map paths by the container mount from `roles/immich/compose.yaml`, or run `find` inside the server container. Fail when the number of database paths is below `photos + videos`.

### m5. A fallback drill could create a second server, or lose track of the first

- Severity: minor. Tag: `correctness` (cost, and a stray server).
- Location: plan:26 (T6); `scripts/restore-drill.sh:281-300` (one `drill_id`, one EXIT-trap delete).
- Defect: if the fallback retries after a failed `hc server create` (Hetzner can create the server and still fail the call), the next type reuses `drill_name`, or overwrites `drill_id` and orphans the first server.
- Fold: fall back only on `pick_location` finding no stock, before any create. Never retry after a create call. Test that a create failure does not try the next type.

### m6. A rebuild that dies after the stop leaves everything stopped, and the emergency screens don't say so

- Severity: minor. Tag: `correctness`.
- Location: plan:21 (T1); `infra/provision.sh:397-416`; `servers-backup:61-62` (`--pre-stop` holds the lock through its 10-minute wait, and a 03:00 nightly under `flock -n` then fails as a unit).
- Defect: a timeout, an ssh drop, or the nightly taking the lock between `STOP_CMD` and `BACKUP_KEEP_STOPPED_CMD` aborts the rebuild with Immich, every share, and (after T2) dubplate stopped. Nothing tells the operator how to bring them back.
- Fold: in T1's "Check a service and restart it", add one line: after a stopped rebuild, run `systemctl start immich.service 'webdav@*.service'` and dubplate's unit. Add the rebuild time-window line from m1 to the operator guide.

### m7. The orpheus screen: what to restart with, and what "healthy" means

- Severity: minor. Tag: `correctness`.
- Location: plan:21 (T1, "the restart command"); `roles/immich` unit (`Type=oneshot`, `RemainAfterExit=yes`, `--env-file /etc/immich/immich.env`).
- Defect: `active (exited)` reads healthy even when every container has died. A bare `docker compose up` or `down` in `/opt/immich` runs without the env file, so it interpolates empty paths. `docker image prune -a` while the stack is down removes Immich's images.
- Fold: on the screen, healthy means the containers in `docker compose --env-file /etc/immich/immich.env ps` are up and healthy, or the loopback ping answers, not `is-active` alone. Restart only through `systemctl restart immich.service`. Write `docker image prune` without `-a`. List `server-restore clear` (the `.pre-restore` copies) under the stop line, not as safe to remove.

### m8. Where the render check goes

- Severity: minor. Tag: `correctness`.
- Location: plan:26 (T6); `secrets/render.sh:64-109` (the build loop) and `:119-123` (the install loop).
- Defect: if the check goes in the install loop, a refusal can leave some env files already replaced.
- Fold: put the base64url check in the build loop, so a refusal installs nothing, and add a test assertion that no file was written.

### m9. Optional: uploads that land between the fresh dump and the stop

- Severity: minor. Tag: `optional`.
- Location: plan:22; `servers-backup:174-184`.
- Defect: Immich keeps taking uploads between the new dump and `systemctl stop`. Those files go into the final backup with no database row, which is M3's window shrunk to seconds.
- Fold: after the stop, count files under `library/` and `upload/` newer than the dump, print them in the `--keep-stopped` output, and list them in the rebuild summary.

### m10. Over-ceremony: diff-reviewer reads on the ordinary tasks

- Severity: minor. Tag: `optional`.
- Location: plan:19 ("Every task ... gets a `diff-reviewer` task-scope read").
- Defect: `pass-core` asks for task-scope reads on `auth-data` tasks. The plan's sentence also covers T1 (docs), T5, T7, and T8 (a hash bump), which is about four extra reviewer dispatches: roughly 15 to 25 minutes of clock time and a reviewer context each. The T10 whole-branch read covers them.
- Fold: limit task-scope reads to T2, T3, T4, and T6. Keep T5 only if the reviewer is asked about m4's query, since it decides whether the drill can pass falsely.
