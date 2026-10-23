# Backlog 2 plan review: mechanics and feasibility

Target: `self-hosting/plans/2026-10-22-backlog-2-plan.md` at initiatives `f36b477`, against the design `self-hosting/specs/2026-10-22-backlog-2-design.md` and servers `main` at `e036a70`. Lens: does every mechanism behave as stated, checked against source, upstream code at the pinned tag, and read-only live probes.

Evidence base:
- Immich source at tag `v3.3.4`: `server/src/controllers/queue.controller.ts`, `job.controller.ts`, `dtos/queue.dto.ts`, `services/queue.service.ts`, `services/media.service.ts`, `repositories/asset-job.repository.ts`, `services/database-backup.service.ts`, `enum.ts`.
- Floccus `src/lib/adapters/WebDav.ts` (develop).
- systemd.exec(5).
- Read-only reads on orpheus and ward over `ssh -o BatchMode=yes`: SELECTs only, `find`, `du`, `df`, `ls`, `systemctl show`/`cat`, `docker compose ps`, and `journalctl`.
- Read-only `hcloud server-type describe`.
- A names-only pattern check of the five `WEBDAV_PASSWORD_*` store values. No value was printed.

Counts: 3 blockers, 13 major, 14 minor.

## Blockers

### B1. T2 starts Immich's dump through an endpoint that does nothing in v3.3.4 (correctness)

**Location:** plan line 22 (T2) and line 44 (the standing answer); design line 24.

**Defect.** In v3.3.4, `PUT /api/queues/:name` is `updateQueue`, described as "Change the paused status of a specific queue", and its body is `QueueUpdateDto` (`{isPaused?: boolean}`) (`queue.controller.ts:44-58`, `queue.dto.ts:19-23`). `QueueService.update` acts only when `isPaused` is true or false (`queue.service.ts:159-170`). A body of `{"command":"start"}` loses its unknown key under the zod object schema and returns 200 with the queue's status, so no backup runs.

Two endpoints do start a backup:
- `POST /api/jobs` with `{"name":"backup-database"}`. Its description reads "Run a specific job ... as well as creating a new database backup", it answers 204, and it needs `JobCreate` plus admin (`job.controller.ts:32-43`, `enum.ts:469` `ManualJobName.BackupDatabase = 'backup-database'`).
- The deprecated `PUT /api/jobs/backupDatabase` with `{"command":"start"}` (`job.controller.ts:45-57`, `runCommandLegacy`).

The cutover log also records the final pod dump as made "with the `backup-database` job". The key in `backup.env` is `server-migration`, with permissions `{all}`, and its owner is an admin (live SELECT), so the auth side holds.

**Consequence.** As written, `--pre-stop` would always time out, and every `provision.sh rebuild` would refuse at `stop failed`. The plan's standing answer cannot trace the cause. It says "read the container's log", but the no-op logs nothing at the default level: `runCommandLegacy` logs only at debug, and `update` does not log. The rerun-once rule then ships the defect with the live probe under `## Not checked`.

**Fold.** Pin `POST /api/jobs` with `{"name":"backup-database"}` and `-H 'Content-Type: application/json'`, expecting 204, with the key still on curl's stdin config. Correct the design's Outcome 1 wording in the same commit. Replace the standing-answer row with: "no dump within 10 minutes: read `GET /api/queues/backupDatabase` statistics and `docker logs immich_server --since <call time>`; a 204 with no job is a traced cause; fix and rerun."

Two facts the implementation can rely on:
- Immich writes `<name>.sql.gz.tmp` and renames it into place (`database-backup.service.ts:235-254`), so a polled `*.sql.gz` is complete when it appears. `gunzip -t` stays as a check against corruption.
- The default dump takes about 38 MB on orpheus, so 10 minutes leaves wide margin.

### B2. T5's comparison fails every orpheus drill, and the standing answer then reads it as an incomplete backup (correctness, OWNER FORK)

**Location:** plan line 25 (T5), line 46 (standing answer), and line 29 (T9); `scripts/drill-remote.sh:356-381` (`regenerate`) and `:431`.

**Defect.** The backup excludes `thumbs/` and `encoded-video/` (`servers-backup:224-228`). The drill's `regenerate()` is meant to rebuild them, but it rebuilds nothing, for two reasons:
- It calls the same no-op `PUT /queues/NAME {"command":"start",...}` as B1.
- Even a working start with `force:false` would queue nothing. `streamForThumbnailJob` with `force:false` selects only assets whose `asset_file` thumbnail or preview row is missing (`asset-job.repository.ts:64-86`), and `streamForVideoConversion` only videos with no `encoded_video` row (`:326-346`). A restored database already holds every row.

The drill log agrees: the full orpheus drills took 9 to 10 minutes, and "queues idle" came at once.

Live orpheus holds 7,553 thumbnail, preview, and fullsize `asset_file` paths and 33 `encoded_video` paths. On a drill host, every one of those paths would have no file. T5 fails on "any database path with no file", and the standing answer at line 46 calls that "a backup is incomplete" and stops the run. The diagnosis is wrong, and the stop is spent for nothing.

The same no-op hides the integrity check. `PUT /queues/integrityCheck {"command":"start","force":true}` at `drill-remote.sh:431` never starts a job; integrity runs through `POST /api/jobs` with `integrity-missing-files` and similar names (`enum.ts:470-475`). That is the root cause of BACKLOG #9: the counters "showed zero ... before, during, and after a forced run" because no run happened. The drill's RESULT lines "derived files regenerated" and "integrity report shows zero errors" have been false in every logged drill.

**Fold (OWNER FORK, scope).**
- **(a) Recommended. Fix the drill's starts inside T5 and keep the full comparison.**
  - Regenerate through `PUT /api/jobs/thumbnailGeneration` and `/videoConversion` with `{"command":"start","force":true}`, since every derived file is missing on a drill.
  - Start the integrity jobs through `POST /api/jobs` (`integrity-missing-files`, `integrity-untracked-files`, `integrity-checksum-mismatch`).
  - Then compare all four directories.
  - Cost: drill time for about 3,800 forced thumbnails and 33 transcodes, unmeasured. It must fit `queue_bound` (45 minutes); raise T9 above 60 minutes, or measure on the first drill.
- **(b) Narrow the comparison and file the fix.** Compare originals and sidecars strictly (`asset.originalPath`, `asset_file` of type `sidecar`) against `library/` and `upload/`, plus `user.profileImagePath` against `profile/`. Report derived directories as counts only. File the regenerate and integrity defect, and correct the false RESULT lines now.

Either way, amend the line 46 standing answer: missing originals or sidecars mean an incomplete backup; missing derived files mean the regeneration failed.

### B3. T5's database query names a column v3.3.4 lacks, and omits the paths and prefix the comparison needs (correctness)

**Location:** plan line 25.

**Defect.**
- `asset.encodedVideoPath` does not exist. A live `information_schema` read shows `asset` has only `originalPath`; encoded video sits in `asset_file` with `type='encoded_video'`, beside `thumbnail`, `preview`, `fullsize`, and `sidecar`. Under `ON_ERROR_STOP=1`, the query errors and `verify` fails on every live drill. The test's fake psql would pass anyway.
- Database paths are container paths under `/data/`, because the compose file mounts `${UPLOAD_LOCATION}:/data`. All rows read `/data/...`, with no other prefix. Unless the comparison maps `/data/` to `/srv/immich/library/`, every path reads as missing. A test written with host paths in the fake psql passes vacuously.
- The query also omits `person."thumbnailPath"` (204 face thumbnails under `thumbs/`) and `"user"."profileImagePath"`. It does not exclude the six `.immich` marker files either.

A live comparison on orpheus settles what #10's ruling rests on. It used the four plan tables plus person and user paths, mapped the prefix, and excluded markers. Result: 11,634 database paths, 11,638 files, 0 database paths without a file, and 4 files without a row (2 shapes under `thumbs/`). The "208 orphan thumbnails" of #10 are 204 person thumbnails the cutover's comparison didn't query, plus 4 true orphans. The 250 allowance is therefore pegged to a miscount.

**Fold.** Write the query out in the plan:

```sql
select "originalPath" from asset;
select path from asset_file;
select "thumbnailPath" from person where "thumbnailPath" <> '';
select "profileImagePath" from "user" where "profileImagePath" <> '';
```

Map `^/data/` to the restored upload root, and exclude `.immich` files. Name the fixture: the fake psql must return `/data/...` paths, so a missing prefix map fails the test. Set the orphan allowance from evidence: 4 today, so a small number such as 25, or report-only. Record under `## Found, not done` that #10's premise was a miscount, so Geoff sees it.

## Major

### M1. T7's state file cannot be written under the health unit's `ProtectSystem=strict` (correctness)

**Location:** plan line 27; `roles/health/systemd/servers-health.service`.

**Defect.** The unit sets `ProtectSystem=strict` with no `ReadWritePaths=` or `StateDirectory=`. systemd.exec(5) says: "If set to "strict" the entire file system hierarchy is mounted read-only, except for the API file system subtrees /dev/, /proc/ and /sys/", and that `StateDirectory=` and related settings "exclude the specific directories from the effect of ProtectSystem=". A write to `/var/lib/servers/...` therefore fails with EROFS in production. The health tests run without systemd and would pass.

**Fold.** Add `StateDirectory=servers-health` and `StateDirectoryMode=0700` to the unit, and keep the state at `/var/lib/servers-health/webdav`. List the unit in T7's files, update its golden hash at `tests/orpheus-golden.test.sh:30` in T8, and see M6 for ward.

### M2. Floccus writes a plaintext lock file beside the bookmarks, so T7's every-file check raises false alerts (correctness)

**Location:** plan line 27; design line 29.

**Defect.** Floccus's WebDAV adapter uploads `<bookmark_file>.lock` holding `<html><body>I am a lock file</body></html>` and refreshes it every minute during a sync (`WebDav.ts:84, 146-157, 341`). An interrupted sync leaves it behind until the 15-minute override. Its upload temp file is `<file>.temp` (`:87`), which carries the envelope.

A check of "every regular file except `*.partial`" therefore sets `webdav_ok=false` on any reading that lands mid-sync. A leftover lock fails every reading, so the two-in-a-row rule then alerts.

**Fold.** Skip a `*.lock` file whose whole content is that exact lock body, and fail any other `*.lock`. Add a test case for each. The shares are empty today (live `find`: five directories, no files), so nothing live contradicts this yet.

### M3. "Skipping files past 10 MiB as today" misreads today's code and would open a bypass (correctness)

**Location:** plan line 27; `roles/health/health.sh:84-85`.

**Defect.** Today a file past 10 MiB sets `webdav_ok=false`: it is not read, and it fails. Turning that into a skip lets a plaintext file pass by being padded past 10 MiB.

**Fold.** Keep "past 10 MiB fails", and name it in T7's test list.

### M4. The standing answer for a leftover drill server runs a command the deny rules block (correctness)

**Location:** plan line 47.

**Defect.** `~/.claude/settings.json` carries `DENY Bash(hcloud * delete *)`, so `hcloud server delete drill-...` is refused, whatever the drill's labels say. `restore-drill.sh` deletes only inside its own EXIT trap (`:209`) and has no cleanup verb.

**Fold.** Replace the row with: "the conductor sends `notify-send -u normal` with the server name and id; Geoff deletes it in the console. Record it in STATUS and `## Not checked`; this is the only Geoff step the run can meet." Alternatively, add a `restore-drill.sh --delete-drill NAME` that the existing `restore-drill.sh *` allow rule covers, with the label checks the trap already makes. That is scope; it could be filed instead.

### M5. The Stops list turns a classifier denial into a stop, which the base plan's standing answer forbids (correctness)

**Location:** plan line 49; base plan "Standing answers", the row on a classifier denial.

**Defect.** The base plan says a denied command is "never retried. The session records the command ... continues other work, and names it in its PR's 'Not checked'". The plan lists "a classifier denial of a live call" among its stops.

Two live writes could plausibly be denied: T2's production probe on orpheus (a job start over ssh with sudo) and the T9 drills.

**Fold.** Drop it from Stops and cite the base plan row. Name which outcomes survive a denial: T2's probe goes to `## Not checked`, and a denied drill follows the M9 bar answer.

### M6. Ward does run a file this pass changes, so "ward is not applied" leaves drift (correctness)

**Location:** plan line 36; `hosts/ward/roles.txt`.

**Defect.** Ward installs the `health` role, so T7's `health.sh` change, and the unit change in M1, put ward's `/usr/local/sbin/servers-health` behind the repo. The next `apply.sh ward --check` or `check-drift` shows drift. Behavior on ward is unchanged, because the webdav block is orpheus-only.

**Fold.** Add to `## After merge`: `scripts/apply.sh ward --check` (expect only the health files), then `scripts/apply.sh ward --apply`, then `scripts/apply.sh ward --check`, outside 03:20 to 04:00 UTC. Both forms are allowed by `Bash(scripts/apply.sh * --check)` and `Bash(scripts/apply.sh * --apply)`. Alternatively, record ward's drift as standing until the next ward pass. Name whichever answer applies, and add it to the reversible-drift standing answer.

### M7. T1's acceptance is unreachable, and its render command lacks `--write` (correctness)

**Location:** plan line 21; `docs/runbook.md:173`; `scripts/render-emergency.sh:20`.

**Defect.**
- `EMERGENCY.md:171` (from `runbook.md:173`, "Who to call") reads "Lands with the runbook session (D5)", and T1 doesn't touch it. Its content (people, call order, hours) is a value only Geoff holds.
- `scripts/render-emergency.sh` with no argument only prints; `--write` rewrites `EMERGENCY.md`.

**Fold.** Narrow the acceptance to the "Check a service" and "Free disk space" screens, or move "Who to call" into T1 with a design-time ask, since only Geoff knows it. The first is cheaper. Write the command out in full as `scripts/render-emergency.sh --write`.

### M8. T4's acceptance grep cannot pass without breaking the close's `gitleaks git` scan (correctness)

**Location:** plan line 24; `.gitleaksignore:2`.

**Defect.** `.gitleaksignore:2` is the fingerprint `9137b6a...:tests/pod-pull.test.sh:generic-api-key:47`. It must stay for the history scan in the close checklist, yet `git grep -n 'pod-pull\|pikapods-sftp\|immich-api'` hits it.

**Fold.** Make the acceptance read "hits only `docs/cutover-log.md`, `BACKLOG.md`, and `.gitleaksignore`", and tell the executor never to edit `.gitleaksignore`.

### M9. No standing answer covers the success bar becoming unreachable mid-run (correctness)

**Location:** plan lines 38-49.

**Defect.** The bar is both drills passing plus the live dump probe. Once the orpheus drill fails (B2 makes this likely as written) or a probe is denied, the plan says "stop for the conductor". It doesn't say which items still run or that the run closes and reports the bar unmet.

**Fold.** Add a row: "Bar out of reach (an orpheus drill fails on a cause traced and recorded, or the probe is denied): still run the ward drill, since its #15 password-path evidence is independent. Skip any orpheus drill rerun whose cause is traced. Close with `## Bar unmet: <item>`."

### M10. Under `--keep-stopped`, T2's webdav handling must leave units stopped, and dubplate restarts at two sites (correctness)

**Location:** plan line 22; `hosts/orpheus/host.env` (STOP_CMD); `servers-backup:212-222`.

**Defect.**
- STOP_CMD already runs `systemctl stop "webdav@*.service"` before `--keep-stopped`. If T2 restarts the units "after the restic backup" by unit pattern, a member can sync between the final snapshot and the wipe, and that write is lost.
- `copy_dubplate` restarts dubplate inline at `:219`, not only in the EXIT trap. Changing only the trap still restarts it.

**Fold.** Pin three rules:
- The nightly run records the units it stopped and restarts exactly those, in the trap and after the backup.
- `--keep-stopped` starts no webdav unit.
- `--keep-stopped` skips both dubplate restart sites.

The test fixture needs an active `webdav@` unit for the nightly cases and none under `--keep-stopped`, with a check that no `systemctl start webdav@` is logged.

### M11. Two of T1's emergency commands fail or mislead as described (correctness)

**Location:** plan line 21.

**Defect.**
- Live: `docker compose ps` in `/opt/immich` fails with "required variable IMMICH_DB_PASSWORD is missing a value" (and the same for `UPLOAD_LOCATION` and `DB_DATA_LOCATION`). `geoff` is not in the `docker` group. The command that works is `sudo docker compose --env-file /etc/immich/immich.env ps`, which shows four containers "running healthy". The unit's own form is `ExecStart=/usr/bin/docker compose --env-file /etc/immich/immich.env up -d`.
- `docker image prune` removes only dangling images. On orpheus the space sits in the tagged v3.3.3 images (about 3.6 GB, not dangling), so prune frees nearly nothing.
- `docker image prune -a` would delete the current v3.3.4 images whenever Immich is stopped, because `ExecStop` is `compose down`, which removes the containers. A restart would then need a registry pull.

**Fold.** Write each command in full in the plan. Let the disk screen run `sudo docker image prune -a` only when `systemctl is-active immich.service` prints `active`, or name the v3.3.3 tags explicitly with `docker image rm`.

### M12. T5's ward proof can pass vacuously, and its open question is already answered (correctness, and over-ceremony)

**Location:** plan line 25; `tests/drill-remote-ward.test.sh:120-123`.

**Defect.**
- The fake `stalwart-cli` logs only `$1 $2 $3` (the defect #15 names). "Asserts the password appears in no logged argument" proves nothing unless the fake logs `$*`.
- `stalwart-cli` 1.0.13 is the version pinned at `roles/stalwart/install.sh:14` and installed on ward. Its `update` help, read live, lists `--json <JSON>`, `--file <PATH> Read JSON patch from a file`, and `--stdin Read JSON patch from stdin`.

**Fold.** Pin `cli update Account "$id" --stdin`, fed `{"credentials":{"0":{"@type":"Password","secret":"..."}}}`, and name the fixture: the fake logs every argument and writes stdin to a separate file that the test reads. Drop the help read and the HTTP-API branch of the design's standing answer; the first drill confirms the patch shape. This saves an ssh round and a branch.

### M13. T6's fallback says nothing about `--hold`, the recovery path, and cx33 is out of stock everywhere today (correctness, OWNER FORK)

**Location:** plan line 26; `scripts/restore-drill.sh:278-285`.

**Defect.** A live read shows cx33 with `available:false` in fsn1, nbg1, and hel1, and cpx32 available in all three. `--hold` builds in the Primary IP's location with `SERVER_TYPE`. As written, the recovery path itself (`--hold`, then `promote.sh`) fails on stock unless the operator knows to pass `--type`.

**Fold (OWNER FORK).**
- **(a) Recommended.** `--hold` with no `--type` walks the same list within the Primary IP's location and prints the type taken, so promote makes a non-cx33 production server, which can be rescaled later.
- **(b)** `--hold` stays pinned, and the runbook's "If a server is gone" screen says to pass `--type cpx32`.

## Minor

### m1. T3: pin the safe answer, and name the fixture by unit state rather than `users.txt` (correctness)

**Location:** plan line 23.

**Defect.**
- `server-restore` learns members from the running units (`webdav_units`, `:201`), not from `users.txt`.
- The installer (`roles/webdav/install.sh:69`) and `drill-remote.sh:508` both create a missing member directory with `install -d -o webdav -g webdav -m 0700`. So "create" is the safe answer, and the either/or can go.
- The test runs as a non-root user, so `install -o webdav` needs a fake.
- The webdav unit is `Type=simple`, so `systemctl start` returns 0 even when the namespace setup fails. Any "could not start" report needs an `is-active` read, not the exit code.

**Fold.** The fixture is `FAKE_WEBDAV_ACTIVE` including `webdav@memberc.service`, with no `srv/webdav/memberc` in the snapshot. The malformed fixture is `"webdav":{"Bad!":1}`. Pin "create the directory, then start".

### m2. T7: absent, empty, and malformed state files have no named behavior (correctness)

**Fold.** An absent, empty, or malformed state file reads as "previous reading passed" and is rewritten. Test all three.

### m3. T6's newline case cannot reach `render.sh` through `secrets_load` (correctness)

**Location:** plan line 26; `scripts/lib/secrets.sh:21-38`.

**Defect.** `secrets_load` reads the store line by line, so a stored value cannot contain a newline. The proposed test case cannot be built through the store.

**Fold.** Test a quote, a backslash, and a space as separate cases. Refuse in pass 1, before any `install` runs. A names-only check showed all five live `WEBDAV_PASSWORD_*` values are base64url, 43 characters each, so the first live render will not refuse.

### m4. T8 misdescribes the golden file and invites arm collisions (optional)

**Location:** plan line 28.

**Defect.** `health.sh` is not pinned in the golden file; `servers-health.service` is, and changes with M1. A pair arm that runs the full gate sees the golden test fail, and two arms could both edit `tests/orpheus-golden.test.sh`.

**Fold.** Tell arms to run only their own tests and leave the golden file to T8.

### m5. T4 misses three references (correctness)

**Defect.** T4 does not name `tests/fakes/sshpass` (used only by the SFTP row), the comment at `tests/harness/lib.sh:4`, `secrets/registry.md:20` ("used by `scripts/pod-pull.sh`"), or `roles/immich/install.sh:11`.

**Fold.** Name these.

### m6. T2's live probe needs a home and an accurate claim (correctness)

**Defect.**
- The probe is a production write, and the Dispatch note keeps arms off live accounts, so it must run in the main loop. Write it in full, with the key read under sudo into a curl stdin config.
- "Changes nothing a restore depends on" is imprecise. Orpheus holds exactly 14 dumps, and `keepLastAmount` is 14, so the job's cleanup deletes the oldest on-disk dump (20261012, v3.2.4). Restic still holds it.

**Fold.** Name the main-loop home, write the command out, and correct the claim.

### m7. Two count caps stop on their own (optional)

**Location:** design line 18 ("extend once to four times, then stop") and plan line 44 ("rerun once ... second miss").

**Defect.** Both caps stop the line with no traced-cause clause, which `pass-core` "Lifecycle" step 1 requires.

**Fold.** Add "unless the cause is traced and the fix is structural" to each.

### m8. The after-merge heartbeat read has no command (correctness)

**Location:** plan line 36.

**Defect.** "Read the next heartbeat for `webdav_ok: true`" names no command. The body lives in the monitor's D1 database, and `journalctl` shows only the HTTP code.

**Fold.** Write the exact query, in full.

### m9. The disk comparison has a known race (optional)

**Defect.** An asset deleted after the 02:00 dump and before the 03:00 snapshot shows as a database path with no file.

**Fold.** Before the line 46 answer calls a backup incomplete, check whether each missing id's asset carries `deletedAt` in the restored database, and compare the dump's time with the snapshot's.

### m10. The fallback order puts the costlier type first, and misses a late stock failure (optional)

**Location:** plan line 26.

**Defect.** Live prices are cpx32 at 0.0673 EUR/h and cx43 at 0.0296 EUR/h, so the order puts the dearer type first. The design fixed this order, and the cost difference is trivial. Separately, `server create` can fail for stock after `describe` reported the type available, and the fallback doesn't cover that.

**Fold.** Keep the order, and add the second case to the fallback or under `## Not checked`.

### m11. T6's test needs per-type stock in the fake (correctness)

**Location:** `tests/fakes/hcloud:288-290`.

**Defect.** The fake's `server-type describe` ignores the type: one `FAKE_HCLOUD_AVAIL` covers every type. "No cx33 but cpx32" cannot be expressed.

**Fold.** Name the fixture change, for example `FAKE_HCLOUD_AVAIL_cx33=""`.

### m12. The T5 and T9 path times assume the drill's 10-minute baseline (optional)

**Defect.** Under B2 option (a), forced regeneration adds unmeasured time to each orpheus drill.

**Fold.** Re-estimate T9 to 90 minutes, or take the time from the first drill.

### m13. T8 is a single-deliverable task (over-ceremony)

**Location:** plan line 28 (15 minutes).

**Fold.** Merge the hash update into T10's gate run, or into the last pair. This saves one dispatch and one diff-reviewer read.

### m14. T1's disk screen omits orpheus's real space users (optional)

**Defect.** `journalctl --vacuum-size=200M` is a no-op on both hosts (journals are 8 MB). On orpheus the space goes to `/srv/immich/quarantine-cutover` (1.3 GB), `/srv/immich/postgres.before-attempt-1` (447 MB), `/srv/immich/pod-pull` (37 MB), and the v3.3.3 images. Deleting the first three is Geoff's call. Disk use is 49% on orpheus and 29% on ward.

**Fold.** The screen names them as "call Geoff" items, and the run files their removal.

## Checked and holding

- The line references `servers-backup:102-109`, `server-restore:231`, `drill-remote.sh:397`, `dry-run.sh:499-518` and `:628`, `health.sh:72-89`, `tick.test.ts:335`, `Caddyfile:8-9`, and `restore-drill.sh:249-285` all match `e036a70`.
- The path arithmetic sums to 330 minutes. The pairs share no file, apart from the golden file (m4).
- `immich.service` is `Type=oneshot` with `RemainAfterExit=yes`, and reads `active (exited)`. dubplate has no unit on orpheus. The dump directory is `/srv/immich/library/backups`.
- The key in `backup.env` is an admin key with `{all}`.
- T2's ordering works: the dump wait comes before the cache write, so `load_pre_stop`'s 600-second window holds.
- The nightly backup takes 20 to 41 seconds and the health timer runs every 15 minutes, so a webdav stop overlaps at most one reading.
- `music CNAME` exists in `cloudflare/dns/orpheus:4`.
- `claude agents --json` exists.
- The allow rules cover `scripts/restore-drill.sh *`, `scripts/apply.sh * --check` and `--apply`, and ssh to both hosts. cax21 is in stock in all three locations.
