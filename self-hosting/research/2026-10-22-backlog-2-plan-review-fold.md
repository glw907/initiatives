# Backlog 2 plan review: the fold

Path after the fold: **455 minutes**, and **470** after the verification read's fixes (see "Verification read" below). That is above the design's 330-minute estimate and under its 660-minute extension point and its 800-minute ceiling. The growth comes from the forced drill regeneration and the real integrity jobs (T5 and T9), the nightly fresh dump (T2, from Geoff's 2026-10-22 ruling), and the tests that keep each check from passing vacuously.

Targets revised in place: the plan `self-hosting/plans/2026-10-22-backlog-2-plan.md`, the executor prompt `2026-10-22-backlog-2-prompt.txt`, the conductor prompt `2026-10-22-backlog-2-conductor-prompt.txt`, and the design `self-hosting/specs/2026-10-22-backlog-2-design.md`, which gains only the dated amendment line under its Brief. The fold read the reviews at initiatives `005efe2` and the code at servers `e036a70`.

Counts: 72 findings. 59 folded, 2 refused, 11 dropped as `optional`, and 0 owner forks. Five findings marked OWNER FORK were settled before the fold: mechanics B2 and M13, contract F14, and data M2, M3, and M4. They fold as settled and are not listed as forks.

## Probes the fold ran

Every mechanism the revision introduces is quoted from source or proven by a probe.

- **Immich v3.3.4 source**, fetched from `raw.githubusercontent.com/immich-app/immich/v3.3.4/server/src/`:
  - `job.controller.ts:32-43` is `POST /api/jobs` with `JobCreateDto`, "including various cleanup tasks, as well as creating a new database backup", answering 204.
  - `job.controller.ts:45-57` is `PUT /api/jobs/:name` with `QueueCommandDto`, which reaches `runCommandLegacy`.
  - `queue.controller.ts:44-57` is `PUT /api/queues/:name`, "Change the paused status of a specific queue". `queue.service.ts:159-170` acts only on `isPaused`.
  - `queue.service.ts:191-256`: `start()` maps `thumbnailGeneration`, `videoConversion`, and `backupDatabase` to jobs carrying `force`. It has no case for `integrityCheck`, which falls to "Invalid job name".
  - `job.service.ts` `asJobItem` maps `backup-database` to `DatabaseBackup`, and the three `integrity-*` names to their QueueAll jobs. `integrity.service.ts` runs those jobs on `QueueName.IntegrityCheck`.
  - `asset-job.repository.ts:64-86` and `:326-346`: without `force`, the jobs select only assets with no derived row. With `force`, they take every asset with `deletedAt` null, and thumbnails also skip `visibility` hidden. `media.service.ts:90` regenerates every person under `force`.
  - `database-backup.service.ts:235-254` writes `.sql.gz.tmp` and renames it. `cleanupDatabaseBackups` keeps `keepLastAmount`, whose default is 14 at `config.dto.ts:551`.
  - `config.dto.ts:599-601` sets the default concurrency: thumbnailGeneration 3, videoConversion 1.
- **Floccus** `src/lib/adapters/WebDav.ts` (develop):
  - `:146-157` uploads `<file>.lock` with the body `<html><body>I am a lock file</body></html>`, and `:341` refreshes it each minute.
  - `:416-428` uploads the bookmarks data to `<file>.temp`, then moves it into place.
- **systemd.exec(5)**, local man page: "If set to "strict" the entire file system hierarchy is mounted read-only ... Similar, StateDirectory=, LogsDirectory=, ... also exclude the specific directories from the effect of ProtectSystem=."
- **Probes**:
  - The T2 probe command's quoting was checked locally against `sudo` and `curl` shims and a fixture `backup.env`. The key reached curl only on stdin, and the argv was `-X POST -H Content-Type: application/json -d {"name":"backup-database"} http://127.0.0.1:2283/api/jobs`.
  - Two read-only D1 queries ran through the Cloudflare D1 query tool on `servers-monitor`. `SELECT server, received_at, json_extract(body, '$.webdav_ok') ... FROM heartbeats WHERE server = 'orpheus'` returned `webdav_ok` 1. `SELECT id, opened_at FROM conditions` returned an empty list.
- **Repo and settings**:
  - `~/.claude/settings.json` denies `Bash(hcloud * delete *)` and allows `Bash(scripts/apply.sh * --apply)`.
  - `.gitleaksignore` pins `tests/pod-pull.test.sh:...:47` by commit, and `tests/dry-run.test.sh:generic-api-key:111` by line, unpinned.
  - `roles/immich/compose.yaml:15` mounts `${UPLOAD_LOCATION}:/data`, and the four container names are in the same file.
  - `roles/stalwart/install.sh:58` creates `/var/lib/stalwart`.
  - `restore-drill.sh:99` says "restores need the same architecture"; cx33, cpx32, and cx43 are all x86.

## Mechanics review

| Id | Disposition | Where |
|---|---|---|
| B1 | Folded | T2 calls `POST /api/jobs` with `{"name":"backup-database"}` and expects 204. The probe row is replaced with a traced-cause read (queue statistics and `docker logs immich_server`). The design's Outcome 1 endpoint is owed erratum E1. |
| B2 | Folded (settled: option a) | T5 starts regeneration through `PUT /api/jobs/<name>` with `force` true and the integrity checks through `POST /api/jobs`, and keeps the full comparison. A new standing answer sets the 90-minute budget. The incomplete-backup row now separates originals from derived files. T9 adds a dated note correcting the earlier drill log lines. |
| B3 | Folded | T5 writes out the queries: the original paths plus sidecars and profile images, and the derived `asset_file` and person paths. The map is `^/data/`, the `.immich` markers are left out, and the fixture uses `/data/` paths. The tolerance follows ruling 1. #10's miscount is filed at T10. |
| M1 | Folded | T7 adds `StateDirectory=servers-health` and `StateDirectoryMode=0700`, keeps state at `/var/lib/servers-health/webdav`, and updates the unit's golden hash. After merge step 4 checks it live. |
| M2 | Folded | T7 skips a `*.lock` holding exactly Floccus's lock body and fails any other. The lock body was verified in Floccus source. |
| M3 | Folded | T7: past 10 MiB reads false unparsed, as today, and the existing test stays. |
| M4 | Folded | The leftover-server row never runs `hcloud server delete`. The executor messages the conductor, the conductor sends one `notify-send`, and Geoff deletes the server in the console. Both prompts carry this. The `--delete-drill` verb is not built (scope). |
| M5 | Folded | A classifier denial leaves the stops and follows the base plan's row: a standing-answer row in the plan, and the executor prompt's stops line. |
| M6 | Folded | After merge applies ward with `--check`, `--apply`, and `--check`. Both prompts mention it. |
| M7 | Folded | T1's acceptance covers only the two screens, with "Who to call" byte-identical to `main`. The command is `scripts/render-emergency.sh --write`. |
| M8 | Folded | T4's acceptance allows `.gitleaksignore`, and the executor never edits its commit-pinned lines. The fold also found that a T4 edit can shift the unpinned `tests/dry-run.test.sh:...:111` entry, and T4 now says to update only that entry. |
| M9 | Folded | Standing-answer row "The bar is out of reach", and `## Bar unmet` in the PR body and the executor prompt. |
| M10 | Folded | T2 records the units it stops and starts exactly those. `--keep-stopped` starts no webdav unit and runs neither dubplate restart. Both are tested. |
| M11 | Folded | T1 gives the compose command in full (`--project-directory /opt/immich --env-file /etc/immich/immich.env`, the form `server-restore:53` uses), restarts only through systemctl, and writes `docker image prune` without `-a`, with a never-`-a` line. |
| M12 | Folded | T5 pins `cli update Account "$id" --stdin` (stalwart-cli 1.0.13 has `--stdin`, per settled fact 6). The fake logs `$*` and saves stdin, and the help read is dropped. The design's HTTP-API standing answer is now moot; the row stays as written. |
| M13 | Folded (settled: same fallback) | T6: `--hold` with no `--type` walks the same list in the Primary IP's location. It prints that a non-cx33 promotion is a price change, which goes to Geoff by the base plan's purchase row. |
| m1 | Folded with ruling 4 | T3 finds members from the units (`FAKE_WEBDAV_ACTIVE` fixture) and reads `is-active` after each start. It carries the live directory forward, never creating an empty one, so no `install -o` fake is needed (`cp -a` as the test user). |
| m2 | Folded | T7 reads an absent, empty, or malformed state as "the previous reading passed", rewrites it, and tests it. |
| m3 | Folded | T6 tests a quote, a backslash, and a space, and refuses in the build loop before any install. A stored value cannot hold a newline. |
| m4 | Dropped (`optional`) | The substance lands through m13: each golden line is updated by the one task per pair that changes the file. |
| m5 | Folded | T4 names `tests/fakes/sshpass` (and `dry-run.sh:27`), `tests/harness/lib.sh:4`, `secrets/registry.md:20`, and `roles/immich/install.sh:11`. |
| m6 | Folded | T2 runs the probe in the main loop, writes it out in full (quoting proven against shims), and corrects the claim: cleanup deletes the oldest of the 14 dumps on disk, and restic holds it. |
| m7 | Dropped (`optional`) | |
| m8 | Folded | After merge step 5 gives the D1 query, probed read-only. |
| m9 | Dropped (`optional`) | Ruling 1's fresh nightly dump shrinks the window to seconds anyway. |
| m10 | Dropped (`optional`) | The order stays as the design fixed it. The late-stock case lands through data m5. |
| m11 | Folded | T6 adds `FAKE_HCLOUD_AVAIL_<type>`, which falls back to `FAKE_HCLOUD_AVAIL`. |
| m12 | Dropped (`optional`) | T9 is re-estimated anyway, to 120, because of B2. |
| m13 | Folded | T8 is removed. Each pinned-file task updates its own golden line, and T10 checks the golden diff names only the three files. |
| m14 | Dropped (`optional`) | |

## Contract review

| Id | Disposition | Where |
|---|---|---|
| F1 | Folded | T5 fails when there are fewer original paths than `photos + videos`, prints the checked count in the RESULT line, and uses `/data/` fixture paths, with cases for a missing file, an empty query, and a complete tree. The live read of one path per column is not needed: the mechanics review's live comparison established the `/data/` prefix. |
| F2 | Folded at M7 | T10 marks #4 done and notes that "unban a client" was already written. |
| F3 | Folded at M10 | |
| F4 | Folded | T2's `systemctl` stub gains a `list-units` branch, and `stop webdav@X` adds a file, so the manifest equals the count after the stop. The test asserts the order on success and on a failed restic step. |
| F5 | Folded | A fresh dump is complete on appearance (the `.tmp`-then-rename, verified), so a `gunzip -t` failure refuses at once, as data m1 proposed. Retrying until the deadline would only turn real corruption into a timeout. The `SERVERS_TEST` deadline and poll overrides, the curl-impl branch, the rewrite of `:293`, and the ordering assertions are named. |
| F6 | Folded at M12 | The ward test also checks the positive case: each saved stdin holds its password. |
| F7 | Folded with ruling 1 | An orphan original fails at more than 0, and derived orphans are counts only. This replaces the 250 threshold. |
| F8 | Folded at M3 | |
| F9 | Refused | Settled fact 6: `/srv/webdav` holds no files, so a live listing has nothing to read. The files Floccus writes (the bookmarks file, `.lock`, and `.temp`) come from its source (M2), and After merge step 5 reads `webdav_ok` live. |
| F10 | Dropped (`optional`) | Resolved by m13's fold. |
| F11 | Folded with ruling 4 | T3 carries the live directory forward instead of creating it, and "fails closed" applies only to the malformed and no-directory cases. |
| F12 | Folded | T3 uses the `FAKE_WEBDAV_ACTIVE` fixture, the exact abort message, the live share unchanged, and the stopped units restarted. |
| F13 | Folded | T3 adds a start-failure case, read through `is-active`. |
| F14 | Folded (settled by fact 5) | The nightly runs under a minute, and T2 restarts the units right after `run_backup`. After merge step 7 reads conditions and the backup journal the morning after the first nightly run. The measuring step is not added, since fact 5 already supplies it. |
| F15 | Folded, one part refused | Folded at M8, plus `immich_api` in the grep, a behavioral test (exactly one `immich-orpheus` PASS row, no `pikapods-sftp`), and sshpass (m5). Refused: removing the `PIKAPODS_SFTP_*` sentinel exports at `tests/dry-run.test.sh:108`. The unused sentinels are harmless, and removing them shifts the line the unpinned gitleaks entry names. |
| F16 | Folded | T2's curl-impl logs `$*` and requires the POST body and the key in the stdin config. |
| F17 | Folded | T6 walks type-major and adds the four named cases, plus `--hold` (ruling 3) and the no-second-create case (data m5). |
| F18 | Folded | T6 asserts that the variable is named, the value appears in no output or ssh log, and nothing is installed. A names-only check of the live values goes under `## Decisions`. |
| F19 | Folded | T7 adds the fail, pass, fail case, the `HEALTH_STATE` override, mode 600, and the tick case: it resolves, the count increments, and the third rejection opens `media_down`. |
| F20 | Folded | T1 records each command with an output excerpt under `## Decisions`, writes prune without `-a`, and sets a no-restart window from 03:00 to 03:30 UTC. |
| F21 | Folded | T9's log entry records the checked count (more than 0), the orphan counts by directory, the comparison mode, and the ward credential path. |
| F22 | Folded | T2 compares against the call's epoch, and the test has a dump dated before the call. |
| F23 | Dropped (`optional`) | |
| F24 | Dropped (`optional`) | |

## Data review

| Id | Disposition | Where |
|---|---|---|
| B1 | Folded at mechanics M1 | Also folded: a failed state write reports false at once, a temporary file and rename write the state, and After merge step 4 checks it. |
| M1 | Folded at mechanics M10 | Also folded: `--keep-stopped` refuses when any `webdav@` unit is not inactive, which covers `activating`. |
| M2 | Folded (settled by fact 5) | The units stop through the backup only, start again before forget and the Sunday check, and the window stays small. Options (b) and (c) are not needed. |
| M3 | Folded (settled by ruling 1) | T2 adds the nightly dump step, and T5 fails on an orphan original. The design amendment line records the ruling. |
| M4 | Folded (settled by ruling 4) | T3 carries the directory forward with `cp -a` from `.pre-restore`, never starts a member on an empty directory, and T1 adds a runbook line that a restore rolls Floccus back. The runbook line sits in T1, not T3, because T4 edits the runbook in T3's pair. |
| M5 | Folded | T2: under `--keep-stopped`, the backup stops dubplate, backs up `/var/lib/dubplate` itself, and runs neither restart, with a test. The nightly staging path gap is filed at T10. |
| M6 | Folded at mechanics M2 | |
| M7 | Refused | Settled fact 6: the key in `backup.env` is an admin key with `["all"]`, which `JobCreate` admits. |
| m1 | Folded at contract F5 and F22 | The rebuild time window lands in T1's operator-guide line. |
| m2 | Folded at mechanics M3 | |
| m3 | Folded | T2 records each unit before stopping it, uses the non-inactive filter, turns a failed stop into `fail webdav` undone by the trap, and tests it. |
| m4 | Folded at contract F1 and mechanics B3 | |
| m5 | Folded | T6's walk reads stock only, before any create, and never retries after a create call; tested. |
| m6 | Folded | T1's operator-guide lines name the rebuild window and the start commands after a rebuild that stopped. The line goes in the operator guide, not the second operator's screen, because a rebuild is Geoff's packet. |
| m7 | Folded at mechanics M11 | Also folded: `server-restore clear` and `*.pre-restore` are Geoff's call on the disk screen. |
| m8 | Folded at mechanics m3 | |
| m9 | Dropped (`optional`) | |
| m10 | Dropped (`optional`) | |

## Owed errata

None of these is edited into the design, which carries only the amendment line from ruling 1.

- **E1.** Design Outcome 1 names `PUT /api/queues/backupDatabase` with "listed by v3.3.4". In v3.3.4 that call only pauses or resumes a queue. The working call is `POST /api/jobs` with `{"name":"backup-database"}`, which the amendment line and the plan use.
- **E2.** Design Outcome 5 tolerates "the 208 orphan thumbnails ruled harmless (#10)". That count was 204 person thumbnails the cutover's comparison did not query, plus 4 true orphans. The amendment line replaces the tolerance itself.
- **E3.** The design's "Files" list lacks `roles/health/systemd/servers-health.service`, `tests/orpheus-golden.test.sh`, `tests/fakes/sshpass` (deleted), `tests/harness/lib.sh`, `secrets/registry.md`, `roles/immich/install.sh`, `docs/restore-drill-log.md`, and possibly one line of `.gitleaksignore`.
- **E4.** The design's "About 330 path minutes" is now 470 in the plan (455 at the fold, 470 after the verification read). The 660 and 800 limits are unchanged.

The base plan carries no erratum. Mechanics M5's conflict was in this plan, which now follows the base plan's denial row.

## Rulings

None. Every OWNER FORK in the three reviews was settled before the fold, and no new product or priority question came up.

## Verification read

The read is `2026-10-22-backlog-2-fold-verification.md`, against initiatives `cf01972`, with 1 major and 12 minor. 8 folded, 1 left as owed errata, and 4 `optional` dropped or folded at one line each. The path moves from 455 to 470 minutes: T2 is 110, T5 is 130, and T3 is 55.

New mechanisms, probed:
- **restic mtimes.** `restic restore` keeps file mtimes. A local probe backed up and restored a file dated `2026-10-20 02:00:05 UTC`, and the restored copy kept that time.
- **Upload mtimes.** Immich sets an uploaded original's mtime to the client's `fileModifiedAt` (`asset-media.service.ts:181`, v3.3.4). A file's own date therefore cannot place an upload in the window, and the window test uses counts and `deletedAt` instead.
- **Statistics scope.** The server statistics leave out trashed and hidden assets (`user.repository.ts` `getUserStats`: `asset.deletedAt is null`, `visibility != hidden`).
- **Type=simple start.** systemd.service(5): Type=simple counts a unit as started "immediately after fork(), and before ... execve()". The webdav unit has `RestartSec=5` (`roles/webdav/systemd/webdav@.service`).
- **ssh keepalive.** ssh_config(5) `ServerAliveInterval`: after the interval, "if no data has been received from the server", ssh sends a message requesting a response. `ServerAliveCountMax` defaults to 3.
- **Already running.** `queue.service.ts:192-195` throws `BadRequestException("Job is already running")` when the queue is active.

| Id | Disposition | Where |
|---|---|---|
| V1 | Folded | A new standing-answer row covers T9's pre-merge window, which is not an incomplete backup and not a stop. The row needs orphan originals only when the manifest counts more photos or videos than the restored database, and missing originals only on rows with `deletedAt` set or up to the number the manifest counts fewer. It ends in `## Bar unmet: orpheus drill (pre-merge window)`, and T10 files a post-merge drill. T5's verdict sentence now reads "after the merge, none is expected". A new T5 bullet, "Window evidence", keeps `verify` running past an asset-count mismatch so one run prints all the evidence, and adds a test case. The report's proposed dating by file mtime is replaced, because Immich resets upload mtimes (probe above); the dump's mtime still marks the window's start. T9 notes that the window row may apply. |
| V2 | Folded | The executor prompt allows the probe once, twice at most under the probe row, and allows the one dump Immich's retention removes. T2's probe bullet says the same. |
| V3 | Folded | T1 reads only the health, status, `df`, and `du` commands live, and marks the restart, prune, and vacuum commands `not run`. |
| V4 | Folded | `--keep-stopped` refuses only on a state other than `inactive` or `failed`. A test case with a `failed` unit proceeds. |
| V5 | Folded | T3 waits 2 seconds, then requires three `active` reads 1 second apart, with `SERVERS_TEST` overrides. A unit that fails sits in `activating` for `RestartSec=5`, which the reads catch. |
| V6 | Folded | T2 moves `check_dump`'s five cases to the `--keep-stopped` path, asserts `check_dump`'s own log lines, and renames the dump at `:148`. The fold also requires a fresh dump to be a file that was not there before the call, so a stale future-dated file cannot pass the wait. |
| V7 | Folded | T6 adds `-o ServerAliveInterval=30 -o ServerAliveCountMax=6` to `restore-drill.sh`'s `ssh_opts`. T9 and the executor prompt run each drill with `run_in_background` and wait with Monitor. |
| V8 | Left as owed errata E1 and E2 | The design keeps only its amendment line, per the coordinator's instruction. E1 and E2 above stand. |
| V9 | Folded | `verify_ward` prints a RESULT line naming `--stdin`, the ward test asserts it, and T9's log takes the credential path from that line. |
| V10 | Dropped (`optional`) | Cleared conditions leave no row, and the morning read is a backstop. The subscriber's own notice covers an alert that opened and cleared overnight. |
| V11 | Folded (one line) | T7: the temporary file lives in the state directory, because `PrivateTmp=yes` puts `/tmp` on another filesystem. |
| V12 | Folded in part (one line) | A 400 "Job is already running" counts as a started regeneration. Dropped: the line nit (`:431` against `:432`, which "follow the function" covers), the faceless-person exclusion (rare, and its count prints), and naming the library-root override, which is the executor's to choose. |
| V13 | Dropped (`optional`) | Settled fact 5 stands, and three 5-minute `dav_ping` failures need more than 10 minutes. |

## Next

The verification read ran and its findings are folded above. No further read is due unless a fold finding is a blocker, and none was.
