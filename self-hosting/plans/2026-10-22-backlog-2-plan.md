Initiative: self-hosting

# Servers backlog, second batch: plan

## Brief

This plan builds the approved design `self-hosting/specs/2026-10-22-backlog-2-design.md`, with its 2026-10-22 amendment (the nightly backup also takes a fresh Immich dump): twelve servers backlog items in one pass, on one servers branch, with one PR that comes back to Geoff through `conductor-servers`. The emergency screens go first, so they exist before the second operator's session on 2026-10-24. The planned path is 470 minutes, under the design's 660-minute extension point. The review fold and its verification read (`self-hosting/research/2026-10-22-backlog-2-plan-review-fold.md`) added the forced drill regeneration, the nightly dump, and the tests that keep each check from passing vacuously. Nothing here needs Geoff before launch.

## Entry

The servers main checkout is on `main`, clean, and level with `origin/main`. No other session executes in the servers repo (`claude agents --json`, `git status`). The design is approved.

## Pre-flight

None. Every live step runs on rules the workstation already holds: ssh to `orpheus.907.life` and `ward.907.life`, `scripts/restore-drill.sh`, and `scripts/apply.sh * --check`. The executor runs no `--apply`; the conductor applies orpheus and ward after Geoff approves the PR.

## Tasks

The branch is `backlog-2`, cut from `origin/main`. Every task is `auth-data` unless marked otherwise, runs test-first, and gets a `diff-reviewer` task-scope read while CI runs. Line numbers are from `main` at `e036a70`; follow the function if a line has moved.

A pair arm runs only its own tests. Each task that changes a file pinned in `tests/orpheus-golden.test.sh` (T2, T3, and T7, one per pair) updates that file's hash and the comment in the same commit, so no arm's gate goes red on another arm's change.

This plan corrects the design's Immich calls from Immich v3.3.4 source. `PUT /api/queues/<name>` only pauses or resumes a queue (`queue.controller.ts:44-57`, `queue.service.ts:159-170`), so this plan never uses it to start work.

- **T1. The emergency screens (55 min, `ordinary`, first).** BACKLOG #4. In `docs/runbook.md`, replace the orpheus stub under "Check a service and restart it" (`:38`) with orpheus's screen, each command in full:
  - Health: healthy means `sudo docker compose --project-directory /opt/immich --env-file /etc/immich/immich.env ps` lists four containers `running (healthy)`. `systemctl is-active immich.service` reads `active` even when every container has died, because the unit is `Type=oneshot` with `RemainAfterExit=yes`.
  - Restart: use only `sudo systemctl restart immich.service`, never a bare `docker compose up` or `down`, which runs without the env file. No restart between 03:00 and 03:30 UTC, when the nightly backup stops and starts the shares itself.
  - Each share: `systemctl is-active webdav@<name>.service` and `sudo systemctl restart webdav@<name>.service`.
  - dubplate has no unit on orpheus today; say so in one line.

  Replace the "Free disk space" stub (`:44`) with a screen for both servers. It runs `df -h /`, and `sudo du -sh` on orpheus's `/srv/immich/library/library`, `upload`, `backups`, `thumbs`, and `encoded-video` and on ward's `/var/lib/stalwart` (`roles/stalwart/install.sh:58`). It names the only things safe to remove:
  - Immich's dumps older than the newest three.
  - `sudo docker image prune` with no `-a`. A line says never use `-a`, which deletes Immich's own images whenever the stack is down.
  - `sudo journalctl --vacuum-size=200M`.

  Add a stop line at 90% use or anything outside that list; the `*.pre-restore` copies and `server-restore clear` are Geoff's call. In "Restore from backup with server-restore", add one line: restoring the share from an older snapshot rolls each member's Floccus bookmarks back, so each member checks their bookmarks before the next sync. In the operator guide's "Provision, apply, rebuild, and upgrade" (`:179`), add two lines: a rebuild runs outside 01:45 to 04:00 UTC, and after a rebuild that stopped before the wipe, `sudo systemctl start immich.service` and each `webdav@<name>.service` bring the server back. Read each health, status, `df`, and `du` command and its healthy output on the live servers over `ssh -o BatchMode=yes`, read-only, before writing it, and record each with a one-line output excerpt under the PR's `## Decisions`. Write the restart, prune, and vacuum commands from the unit files and man pages, never run them, and mark them `not run` in `## Decisions`. Re-render with `scripts/render-emergency.sh --write`; with no argument it only prints. *Test*: the render check in the gate passes. *Acceptance*: the "Check a service and restart it" and "Free disk space" sections of `EMERGENCY.md` hold no "land with" or "Lands with" line. "Who to call" is byte-identical to `main`, since its people and hours are Geoff's to write.

- **T2. Fresh dumps, and the backup holds the share still (110 min, pair with T5).** BACKLOG #2, the first half of #26, and the design's 2026-10-22 amendment. In `roles/backup/servers-backup`:
  - One dump step serves both `--pre-stop` and the nightly run. It records the call's epoch, then calls `POST /api/jobs` with the body `{"name":"backup-database"}` and `Content-Type: application/json`, expecting 204 (`job.controller.ts:32-43`; `ManualJobName.BackupDatabase`, `enum.ts:469`). The key comes from `backup.env` in a curl stdin config, the way `fetch_api` sends it (`:113-120`), never as an argument.
  - The step then polls `dump_dir` for a `*.sql.gz` that was not there before the call and whose mtime is past the call's epoch, so a stale file dated in the future cannot pass as fresh. Immich writes `<name>.sql.gz.tmp` and renames it into place (`database-backup.service.ts:235-254`), so a `*.sql.gz` is complete when it appears, and one that fails `gunzip -t` refuses at once. No such dump within 10 minutes refuses. The poll interval and deadline take test-only overrides under `SERVERS_TEST=1`, ignored otherwise.
  - `--pre-stop` runs the dump step, then reads the statistics and stops Immich. A refusal leaves Immich running, so `provision.sh rebuild` stops at "stop failed" before any wipe.
  - The nightly run takes the dump step after `unlock` and before `check_dump`, which then picks the fresh dump; a refusal is `fail dump`. With two dumps a day, Immich's `keepLastAmount` of 14 (default, `config.dto.ts:551`) keeps about seven days on disk, and restic keeps the rest. Record that under `## Decisions`.
  - Webdav, nightly: before `write_manifest`, record each `webdav@` instance that is not inactive (the filter `server-restore` uses at `:201`), then stop it; a failed stop is `fail webdav`. Start exactly the recorded units right after `run_backup`, before `forget` and the Sunday check, and from the EXIT trap on every other way out. The nightly runs of 2026-10-21 and 2026-10-22 took under a minute, so the 15-minute `dav_ping` alert cannot trip.
  - `--keep-stopped`: refuse with `fail manifest` if any `webdav@` instance is in a state other than `inactive` or `failed`, and never start one. `STOP_CMD` has stopped them all; a unit that had already crashed stays `failed` after the stop and takes no writes, so it must not block a rebuild. If dubplate's unit is active, stop it, skip the staging copy, and back up `/var/lib/dubplate` itself. Run neither restart: not `restart_dubplate` at `:219`, and not the trap.
  - Probe once (twice at most, under the probe row below), live, in the main loop after the arm returns, since an arm never touches a live account. Run exactly: `ssh -o BatchMode=yes geoff@orpheus.907.life 'sudo bash -c "date +%s; sed -n \"s/^IMMICH_PIKAPODS_API_KEY=\(.*\)/header = \\\"x-api-key: \1\\\"/p\" /etc/servers/backup.env | curl -sS -K - -o /dev/null -w \"%{http_code}\n\" -X POST -H \"Content-Type: application/json\" -d \"{\\\"name\\\":\\\"backup-database\\\"}\" http://127.0.0.1:2283/api/jobs"'`. It prints the call's epoch, then `204`. The key reaches curl only on stdin; the quoting was checked against shims on 2026-10-22.
  - After the probe, read `ssh -o BatchMode=yes geoff@orpheus.907.life sudo find /srv/immich/library/backups -maxdepth 1 -name '*.sql.gz' -newermt @<epoch>` until a dump appears, and run `sudo gunzip -t` on it the same way. The job's cleanup then deletes the oldest of the 14 dumps on disk; restic still holds it.
  - *Test* (`tests/backup.test.sh`): the curl-impl logs `$*`, answers `POST http://127.0.0.1:2283/api/jobs` only with that body and the key in the stdin config, and writes a new dump into the fixture. The count at `:293` becomes the number of curl calls in the `--keep-stopped` run's own log, which is zero. Dump cases:
    - A fresh dump: the statistics GET follows the dump, and `systemctl stop immich.service` follows both.
    - No dump by the deadline: non-zero, with Immich still active.
    - A dump dated before the call: ignored, so the wait times out.
    - A fresh dump that fails `gunzip -t`: refuses at once.
    - The nightly run's dump step, and its refusal as `fail dump`.
    - `check_dump`'s own cases (`:175-208`: 27 hours old, corrupt, a stray newer file, dated in the future, no dump) move to the `--keep-stopped` path, where `check_dump` still reads the dump `--pre-stop` left. Each asserts `check_dump`'s own log line ("hours old", "fails gunzip -t", "dated in the future", "no database dump") as well as the step name, so a dump-step refusal cannot pass them. The dump name at `:148` becomes the fresh dump's.

    For webdav, the `systemctl` stub gains `list-units 'webdav@*.service'`, fed from `FAKE_UNITS_DIR`, and its `stop webdav@X` adds one file to `srv/webdav/X`, so the manifest's count must equal the count after the stop. Webdav cases:
    - The log shows the stop before `restic backup` and the start after it, on success and on a failed restic step, and only the stopped units start.
    - A failed stop fails `webdav`, and the trap starts the others.
    - `--keep-stopped` with a unit active refuses; with a unit `failed`, it proceeds.
    - `--keep-stopped` logs no `systemctl start webdav@` and no dubplate start, and restic's arguments name `/var/lib/dubplate`.
  - *Acceptance*: the tests pass, and the live probe answered 204 with a dump newer than the call that passes `gunzip -t`.

- **T3. server-restore after an older snapshot (55 min, pair with T4).** The second half of #26 and the restore half of #27. In `roles/backup/server-restore`, after the swap, take each stopped `webdav@<name>` unit whose `/srv/webdav/<name>` the snapshot lacks, and carry the member's live directory forward with `cp -a /srv/webdav.pre-restore/<name> /srv/webdav/<name>`. That keeps the owner and mode and leaves the `.pre-restore` copy whole. Print the member's name. The script already applies this rule to a snapshot that predates the whole share (`:222-228`). A member with no directory on either side stays stopped and is named. Never start a member on an empty directory.

  After starting, wait 2 seconds, then read each started unit with `systemctl is-active` three times, 1 second apart, and count it started only when all three read `active`. The webdav unit is `Type=simple`, which systemd counts as started "immediately after fork(), and before ... execve()" (systemd.service(5)), so a namespace failure lands just after `systemctl start` returns 0. A failed unit then sits in `activating` for its `RestartSec=5` (`roles/webdav/systemd/webdav@.service`), which the three reads catch. The waits take `SERVERS_TEST=1` overrides. "Done. Services are started again." prints only when every unit is active; otherwise the script names each unit that is not active and exits non-zero. Members come from the running units (`webdav_units`, `:201`), not from `users.txt`. *Test* (`tests/server-restore.test.sh`):
  - `FAKE_WEBDAV_ACTIVE` gains `webdav@memberc.service`, and `srv/webdav/memberc` is live but absent from the snapshot and its manifest. After the restore it holds the live files, and the unit started.
  - A unit with no directory on either side stays stopped and is named; the exit is non-zero, with no "Services are started again".
  - A unit whose start fails, or that is not active after its start, is named; the exit is non-zero, with no "started again" line.
  - The manifest entry `"webdav":{"Bad!":1}` reaches the abort at `:231` with its exact message, the live share is unchanged, and the stopped units start again.

  *Acceptance*: all four cases pass.

- **T4. Retire the pod's tooling (35 min, pair with T3).** BACKLOG #7 and #8.
  - Delete `scripts/pod-pull.sh`, `tests/pod-pull.test.sh`, and any fake behavior only they use; grep `tests/fakes/ssh` and `tests/fakes/rclone` before removing a branch.
  - Remove the `pikapods-sftp` row from `scripts/dry-run.sh` (`:499-518`, `:628`). If grep shows that only the SFTP row uses `tests/fakes/sshpass`, delete it too, with `sshpass` in `dry-run.sh`'s tool check (`:27`) and the comment at `tests/harness/lib.sh:4`.
  - Rename the `immich-api` row to `immich-orpheus`, `NEEDS_immich_api` and `check_immich_api` included. The check stays the same, and a comment says that `photos.907.life` is orpheus. Keep the variable `IMMICH_PIKAPODS_API_KEY`.
  - Fix `secrets/registry.md:20`, the comment at `roles/immich/install.sh:11`, and every runbook, monthly-review, and comment reference the grep finds outside `docs/cutover-log.md`, which is history.
  - Never edit `.gitleaksignore`'s commit-pinned lines; the history scan needs them. If an edit moves the `WEBDAV_PASSWORD_*` sentinel line of `tests/dry-run.test.sh` (now `:111`), update only the unpinned `tests/dry-run.test.sh:generic-api-key:<n>` entry, so the gate's `gitleaks dir` leg still passes.

  *Test*: `tests/dry-run.test.sh` output holds exactly one `immich-orpheus` PASS row and no `pikapods-sftp` row. *Acceptance*: `git grep -n 'pod-pull\|pikapods-sftp\|immich-api\|immich_api'` hits only `docs/cutover-log.md`, `BACKLOG.md`, and `.gitleaksignore`.

- **T5. The drill trusts the disk, and the throwaway password leaves argv (130 min, `ordinary`, pair with T2).** BACKLOG #9 and #15, and the design's 2026-10-22 amendment. In `scripts/drill-remote.sh`:
  - *Regeneration runs.* Today `regenerate` (`:356-381`) calls `PUT /api/queues/<name>`, which only pauses or resumes, so no logged drill regenerated anything. Start `thumbnailGeneration` and `videoConversion` through `PUT /api/jobs/<name>` with `{"command":"start","force":true}` (`job.controller.ts:45-57`, which reaches `QueueService.start` at `queue.service.ts:191-256`). The job needs `force`: without it the job takes only assets that have no thumbnail row (`asset-job.repository.ts:64-86`), and a restored database has every row. One 90-minute budget covers both queues, in place of `queue_bound`'s 45 minutes each. A 400 whose body reads "Job is already running" (`queue.service.ts:192-195`) counts as started.
  - *The integrity checks run.* Replace the no-op at `:431` with `POST /api/jobs` for `integrity-missing-files`, `integrity-untracked-files`, and `integrity-checksum-mismatch` (`enum.ts:470-472`, mapped in `job.service.ts`'s `asJobItem`). Each runs on the `integrityCheck` queue (`integrity.service.ts`). The poll and the summary read stay.
  - *The originals query.* After the integrity report, the existing psql call (`:397`, `ON_ERROR_STOP=1`) reads `select "originalPath" from asset`, `select path from asset_file where type = 'sidecar'`, and `select "profileImagePath" from "user" where "profileImagePath" <> ''`.
  - *The derived query.* It reads the other `asset_file` paths of assets with `"deletedAt" is null`; for `thumbnail`, `preview`, and `fullsize`, it also requires a `visibility` that is not `hidden`. The forced job skips the rest (`asset-job.repository.ts:68-69`), so their count is printed. It also reads `select "thumbnailPath" from person where "thumbnailPath" <> ''`, since the forced job regenerates every person (`media.service.ts:90`). `asset` has no `encodedVideoPath` in v3.3.4.
  - *Paths.* Database paths are container paths under `/data/`, because the compose file mounts the upload root there (`roles/immich/compose.yaml:15`). Map `^/data/` to `/srv/immich/library/`, and fail on any path outside it. List the regular files under `library`, `upload`, `profile`, `thumbs`, and `encoded-video`, leaving out the `.immich` markers.
  - *Verdicts.*
    - A missing original fails, as "backup incomplete".
    - A file under `library`, `upload`, or `profile` with no row fails. After the merge, with the nightly fresh dump, none is expected. Before it, a snapshot pairs Immich's 02:00 UTC dump with the 03:00 files and counts, so T9's drill can meet the window (standing answers).
    - A missing derived path fails, as "regeneration failed".
    - Files under `thumbs` or `encoded-video` with no row are counted and printed only.
    - Fewer original paths than `photos + videos` fails, so an empty or misread query cannot pass.

    The RESULT line prints the number of paths checked and each directory's orphan count. Missing and orphan paths print their count and the first ten with ids masked, as the integrity block already does.
  - *Window evidence.* The orpheus `verify` no longer stops at the asset-count check (`:405-406`). It records a mismatch, runs on through the disk comparison, and fails at the end, so one run prints all of it. It prints the restored dump's mtime and the manifest's `created_at` (restic restores file mtimes, probed 2026-10-22), the photos and videos the manifest counts minus those the restored database counts, and how many missing originals have `deletedAt` set in the restored database. A file's own mtime cannot date an upload, because Immich sets an uploaded original's mtime to the client's `fileModifiedAt` (`asset-media.service.ts:181`), and the server statistics leave out trashed and hidden assets (`user.repository.ts`, `getUserStats`).
  - *Budget.* If the 90 minutes pass with the queues still busy and no failed jobs, the drill compares originals strictly and says so in a RESULT line. It reports missing derived paths, and integrity rows under `thumbs` or `encoded-video`, as counts only. Failed jobs still fail.
  - *verify_ward.* Set the password with `cli update Account "$id" --stdin`, fed `{"credentials":{"0":{"@type":"Password","secret":"..."}}}`, the same value the `--field credentials=` form passes at `:326`. The review read stalwart-cli 1.0.13 live: pinned at `roles/stalwart/install.sh:14`, it lists `--stdin` ("Read JSON patch from stdin") and `--file`. The first ward drill confirms the patch shape, and a refusal fails verify. `verify_ward` prints `RESULT throwaway passwords set through stalwart-cli --stdin for N accounts`.
  - *Test*: in `tests/drill-remote.test.sh`, the docker/psql stub answers the queries with `/data/...` fixture paths over a fixture tree, so a missing prefix map fails. Cases:
    - A missing original fails and names the path.
    - A missing derived file fails as regeneration.
    - An orphan original fails.
    - Orphans under `thumbs` are counted, and the drill passes.
    - An empty query fails.
    - A complete tree passes, with the checked count equal to the fixture's rows.
    - A run past a test budget with busy queues takes the counts-only path.
    - An asset-count mismatch still runs the disk comparison and prints the window evidence, then fails.

    The curl fake asserts the two `PUT .../api/jobs/<name>` starts with `force` true and the three integrity `POST .../api/jobs` calls. In `tests/drill-remote-ward.test.sh`, the `stalwart-cli` fake logs `$*` in full and saves stdin to a file. No throwaway password appears in any logged argument, each saved stdin holds its account's password, and the output holds the `--stdin` RESULT line.
  - *Acceptance*: tests pass; T9's drills prove both live.

- **T6. Drill fallback and the render check (45 min).** BACKLOG #28 and #24. `scripts/restore-drill.sh orpheus` with no `--type` walks the types in order, all x86: cx33 in each location of `LOCATIONS`, then cpx32 in each, then cx43. It names the type and location it took; when none has stock, it exits 3 and names each type. `--type` pins one type with no fallback. Ward keeps `WARD_SERVER_TYPE`, with no fallback. `ssh_opts` (`:318`) gains `-o ServerAliveInterval=30 -o ServerAliveCountMax=6`, so the orpheus `verify`, silent for up to 90 minutes of regeneration, keeps its connection (ssh_config(5): the interval after which, "if no data has been received from the server", ssh sends a message requesting a response).

  With no `--type`, `--hold` walks the same list in the Primary IP's location, where it must build (`:279-282`), and prints the type taken. When that type is not cx33, it also prints that promoting it changes the production server's price, which comes to Geoff under the base plan's purchase row.

  The walk reads stock only (`server-type describe`), before any create. A failed `server create` is never retried with another type, so the existing trap still covers the one server; a late stock refusal goes under `## Not checked`.

  In `secrets/render.sh`, the build loop (`:64-109`) refuses a `WEBDAV_PASSWORD_*` value for a `webdav-*.env` template that is not base64url (`^[A-Za-z0-9_-]+$`). It names the variable, never the value, and refuses before any install (`:119-123`). *Test*: `tests/fakes/hcloud` gains per-type stock, `FAKE_HCLOUD_AVAIL_<type>`, which falls back to `FAKE_HCLOUD_AVAIL`. In `tests/restore-drill.test.sh`:
  - With no cx33, the drill takes cpx32; with cx33 and cpx32 both out, it takes cx43.
  - With all three out, it exits 3 and names each type.
  - `--type cx33` with no cx33 stock exits 3, and cpx32 is never described.
  - Ward with no stock never describes another type.
  - `--hold` with no cx33 in the Primary IP's location takes cpx32 there.
  - A failed create makes no second create.

  In `tests/render.test.sh`, a quote, a backslash, and a space each refuse. The message names the variable, the value appears in no output and no ssh log, and nothing is installed. A stored value cannot hold a newline (`scripts/lib/secrets.sh:21-38`). Before the PR, a names-only check confirms that each live `WEBDAV_PASSWORD_*` matches the pattern. It prints `ok` or `bad` per name, never a value, and its result goes under `## Decisions`; the review found all five base64url. *Acceptance*: tests pass.

- **T7. Health and the small fixes (60 min, `ordinary`, pair with T6).** BACKLOG #25, the tick half of #27, and #11. In `roles/health/health.sh` (`:72-89`), check every regular file under each member's directory:
  - A file past 10 MiB reads false unparsed, as today (`:84-85`), and its test at `tests/health.test.sh:148-150` stays.
  - rclone's `*.partial` files are skipped.
  - A `*.lock` file whose whole content is Floccus's lock body, `<html><body>I am a lock file</body></html>`, is skipped. Floccus uploads it and refreshes it each minute of a sync (`src/lib/adapters/WebDav.ts:146-157, 341`). Any other `*.lock` fails.
  - Every other file must be the ciphertext envelope. Floccus's `.temp` upload carries the same data (`WebDav.ts:416-428`).

  `webdav_ok` turns false only when the previous reading also failed:
  - One line of state lives at `/var/lib/servers-health/webdav`, which `HEALTH_STATE` overrides for tests. A temporary file in the state directory and a rename write it with mode 0600; the unit's `PrivateTmp=yes` puts `/tmp` on another filesystem.
  - An absent, empty, or malformed state reads as "the previous reading passed" and is rewritten.
  - A state write that fails reports false at once.
  - `roles/health/systemd/servers-health.service` gains `StateDirectory=servers-health` and `StateDirectoryMode=0700`, since the unit's `ProtectSystem=strict` leaves every other path read-only. systemd.exec(5) says: "Similar, StateDirectory=, LogsDirectory=, ... also exclude the specific directories from the effect of ProtectSystem=". Update the unit's golden hash.

  In `cloudflare/monitor/test/tick.test.ts`, add a rejected fetch (timeout) for `dav_ping` beside the 401, 200, 502, and 503 cases (`:335`): `tick` resolves, the `dav_ping` failure count increments, and the third rejection opens `media_down`. In `roles/caddy/Caddyfile:8-9`, say that `music.907.life` has its DNS record (`cloudflare/dns/orpheus:4`) and only the Caddy site is not imported. *Test*: `tests/health.test.sh` covers:
  - a plaintext file under another name, and a partial file ignored;
  - a lock file with Floccus's body ignored, and one with other content failing;
  - one failing reading staying true and a second turning false, and fail, pass, fail reading true;
  - an absent, empty, or malformed state; an unwritable state path reading false at once; and the state file's mode 600.

  *Acceptance*: tests and `npm test` in `cloudflare/monitor` pass. No Worker source changes, so no deploy.

- **T9. Two drills (120 min, `live-account`).** From the branch, run `scripts/restore-drill.sh orpheus` with no `--type`, then `scripts/restore-drill.sh ward`, never between 02:30 and 04:00 UTC. The orpheus drill now forces regeneration for about 3,800 assets (3,724 photos and 93 videos at the 2026-10-21 cutover) and 204 people. Immich's default concurrency is 3 for thumbnails and 1 for video (`config.dto.ts:599-601`), and the drill runs real integrity jobs. It takes longer than the 9 to 10 minutes logged so far; the regeneration budget is 90 minutes. Run each drill with the Bash tool's `run_in_background` and wait with Monitor; the orpheus drill outlasts a foreground call. This drill restores a snapshot built before the merge, so the pre-merge window row may apply. Record both drills in `docs/restore-drill-log.md`:
  - the type and location taken;
  - the RESULT line, with the number of database paths checked (more than 0) and each directory's orphan count;
  - which comparison ran, strict or budget, and the regeneration minutes;
  - the ward credential path, from `verify_ward`'s RESULT line;
  - for orpheus, the window evidence when the window row applied.

  Add one dated note above the earlier orpheus entries: their "derived files regenerated" and "integrity report shows zero errors" lines came from starts that were no-ops. *Acceptance*: both pass, and both servers are gone (`hcloud server list` shows no `drill-`). A stock refusal follows the standing answers.

- **T10. Close (50 min).** One whole-branch `diff-reviewer`, then one batched fix chain quoting its findings verbatim. The golden block's diff against `main` names only `roles/backup/servers-backup`, `roles/backup/server-restore`, and `roles/health/systemd/servers-health.service`, and the comment names this pass. Run the gate again (`bash scripts/check.sh`). Mark each item done in `BACKLOG.md` with the PR number; for #4, note that "unban a client" was already written. File these through `log-issue`:
  - the deferred `IMMICH_PIKAPODS_API_KEY` rename, and the stale `PIKAPODS_SFTP_*` store names (workstation).
  - the nightly dubplate staging path, which `server-restore` cannot restore. The backup stores `/var/lib/servers/dubplate-staging`, and the restore requires `/var/lib/dubplate` (`server-restore:55-63, 235-237`). It stays latent until dubplate has a unit.
  - #10's premise: its "208 orphan thumbnails" were 204 person thumbnails the cutover's comparison did not query, plus 4 true orphans.
  - under the budget answer, the regeneration fix.
  - under the pre-merge window row, an orpheus drill after the merge as #9's proof.

  The PR body carries `## Brief`, `## After merge` (below), `## Decisions`, `## Not checked`, `## Found, not done`, `## Bar unmet` when that answer applied, the score, and `## STATUS lines`.

T8, the golden-hash task, is folded into T2, T3, T7, and T10.

**Path**: T1 55, then the T2 and T5 pair at 130, then the T3 and T4 pair at 55, then the T6 and T7 pair at 60, then T9 120 and T10 50: 470 minutes.

## After merge

The conductor runs these after Geoff approves, outside 02:30 to 04:00 UTC:

1. Pull the servers checkout.
2. Run `scripts/apply.sh orpheus --check`, then `scripts/apply.sh orpheus --apply`, then `--check` again.
3. Do the same for ward. Ward installs the `health` role, so its health script and unit change. Its behavior does not, because the webdav block is orpheus-only.
4. On orpheus, `ssh -o BatchMode=yes geoff@orpheus.907.life systemctl cat servers-health.service` shows `StateDirectory=servers-health`. After the next timer run, `ssh -o BatchMode=yes geoff@orpheus.907.life sudo test -f /var/lib/servers-health/webdav` succeeds.
5. Read the heartbeat with the Cloudflare D1 query tool on the `servers-monitor` database: `SELECT received_at, json_extract(body, '$.webdav_ok') AS webdav_ok FROM heartbeats WHERE server = 'orpheus'`. It shows a `received_at` after the apply and `webdav_ok` 1; this query was probed read-only on 2026-10-22.
6. Run `scripts/dry-run.sh immich-orpheus`.
7. The morning after the first nightly run (03:00 UTC), `SELECT id FROM conditions` on the same database lists no `media_down` row and no `heartbeat_problem` row for orpheus. `ssh -o BatchMode=yes geoff@orpheus.907.life journalctl -u servers-backup.service --since today` shows the dump step and `ok`.

## Standing answers

The design's table applies, plus these.

| Situation | Answer |
|---|---|
| The `backup-database` call answers 204 but no dump appears within 10 minutes on the live probe | Read `GET /api/queues/backupDatabase` statistics and `sudo docker logs immich_server --since <call time>`. Fix a traced cause and rerun once. Otherwise list T2's live proof under `## Not checked`; the code still refuses a rebuild without a fresh dump. |
| A pair's files turn out to overlap | Run the two tasks in sequence and record it under `## Decisions`. |
| T9's pre-merge orpheus drill fails only on the window between the 02:00 UTC dump and the 03:00 snapshot: an asset-count difference, orphan originals only when the manifest counts more photos or videos than the restored database, and missing originals only on rows with `deletedAt` set or up to the number the manifest counts fewer | Not an incomplete backup and not a stop. Record the window evidence and counts under `## Not checked`, close with `## Bar unmet: orpheus drill (pre-merge window)`, and T10 files a post-merge orpheus drill as #9's proof. Anything outside that pattern follows the next row. |
| The disk comparison finds a missing original, or an original with no row, on the drill, outside the window row above | A finding: a backup is incomplete. Record the count and the first ten paths with ids masked, fail the drill, and stop for the conductor. A missing derived file means regeneration failed: a drill defect to trace, not a backup finding. |
| Forced regeneration passes its 90-minute budget on the drill | The drill takes the budget comparison: originals strict, derived folders as counts only. The log entry says so, and T10 files the regeneration fix in `BACKLOG.md` (settled at the plan review, 2026-10-22). |
| `restore-drill.sh` leaves a server behind | Never run `hcloud server delete`; the deny rule `Bash(hcloud * delete *)` refuses it. Record the server's name and id under `## Not checked`, send conductor-servers one message, and continue. The conductor sends one `notify-send -u normal` with the name and id, and Geoff deletes it in the console. |
| The auto-mode classifier denies a live call | The base plan's row: never retried. Record the command and the site, continue other work, and list it under `## Not checked`; the conductor notifies once. A denied T2 probe leaves the code's refusal standing, and a denied drill follows the next row. |
| The bar is out of reach (an orpheus drill fails on a cause traced and recorded, or a probe or drill is denied) | Still run the ward drill, since #15's evidence is independent. Skip any orpheus rerun whose cause is traced, and close with `## Bar unmet: <item>`. |

Stops: the path ceiling in the design (800 minutes), a backup that a drill shows incomplete, a cause the session cannot trace, a secret only Geoff has.

## Close

The adapter facts in the base plan's "Adapter facts for the servers repo" stand, with its close checklist. The pass's PR goes to Geoff in one packet through `conductor-servers`.
