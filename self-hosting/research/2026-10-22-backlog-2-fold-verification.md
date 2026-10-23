# Backlog 2 plan: fold verification

Target: the folded plan `self-hosting/plans/2026-10-22-backlog-2-plan.md`, its executor prompt `2026-10-22-backlog-2-prompt.txt`, its conductor prompt `2026-10-22-backlog-2-conductor-prompt.txt`, and the design `self-hosting/specs/2026-10-22-backlog-2-design.md` with its amendment, all at initiatives `cf01972`. Checked against the fold record and the three reviews beside it, the servers repo at `e036a70`, Immich v3.3.4 source (fetched from `raw.githubusercontent.com/immich-app/immich/v3.3.4/server/src/`), Floccus `src/lib/adapters/WebDav.ts` (develop), and the local systemd.exec(5). Nothing ran live.

Counts: 0 blockers, 1 major, 12 minor (8 `correctness`, 4 `optional`).

## What holds

- **Every blocker and major closed at the location the fold cites.** Mechanics B1 is closed at plan:39 and :182, B2 at :81-82, :184-185, and :150, and B3 at :83-85. M1 to M13 close at T7, the standing answers, After merge step 3, T1, T4, T2, T5, and T6, as the fold table says. Contract F1 to F15 close at T5's fixture and cases, T1's acceptance, T2's stub and knobs, T3's fixture and cases, T6, T7, and T4's behavioral test. F10 was dropped as optional, and m13's fold now covers it. Data B1 and M1 to M6 close at T7, T2, T3, T1, and T10. M7 was refused on the live key read, which mechanics B1 also records.
- **Path arithmetic.** 55 + max(100, 120) + max(50, 35) + max(45, 60) + 120 + 50 = 455, which matches the plan (:162), the fold record, the conductor prompt (455, ceiling 800), and the executor's clock list (T1 55, T2 100, T3 50, T4 35, T5 120, T6 45, T7 60, T9 120, T10 50).
- **No two arms of a pair share a file.**
  - Pair 1: T2 has `servers-backup`, `tests/backup.test.sh`, and the golden file. T5 has `drill-remote.sh` and the two drill-remote tests.
  - Pair 2: T3 has `server-restore`, its test, and the golden file. T4 has the pod files, `dry-run.sh` and its test, the fakes, `harness/lib.sh`, `registry.md`, `immich/install.sh`, and `.gitleaksignore`. `tests/server-restore.test.sh` uses neither `fakes/ssh` nor `fakes/rclone`.
  - Pair 3: T6 has `restore-drill.sh`, `fakes/hcloud`, `render.sh`, and their tests. T7 has the health files, the golden file, `tick.test.ts`, and the Caddyfile.
  - Only `servers-backup`, `server-restore`, and `servers-health.service` are golden-pinned (`tests/orpheus-golden.test.sh:22,23,30`), one per pair. That matches plan:21 and T10's check.
- **The new mechanisms are correct as quoted.**
  - `POST /api/jobs` is `createJob`, which needs `JobCreate` plus admin and answers 204 (`job.controller.ts:32-43`). `backup-database` is `enum.ts:469`, and `asJobItem` maps it to `DatabaseBackup`.
  - `PUT /api/jobs/:name` goes through `QueueCommandDto` (`command`, `force`) to `runCommandLegacy`, then to `start()`, which maps `ThumbnailGeneration` and `VideoConversion` to QueueAll jobs carrying `force` (`job.controller.ts:45-57`, `queue.service.ts:191-256`).
  - `PUT /api/queues/:name` only reads `isPaused` (`queue.service.ts:159-170`).
  - The integrity names are `enum.ts:470-472`. They map to `Integrity*QueueAll` and `IntegrityChecksumFiles`, which run on `QueueName.IntegrityCheck`.
  - `streamForThumbnailJob` filters on `deletedAt` null and `visibility != hidden` at `:68-69` and drops the missing-row filter under `force`. `streamForVideoConversion` filters on `deletedAt` null only, so encoded video keeps every visibility, as T5 says.
  - Under `force`, `media.service.ts:90` queues every person. `AssetFileType` in v3.3.4 is fullsize, preview, thumbnail, sidecar, and encoded_video, so T5's queries cover every type.
  - The `.tmp`-then-rename is at `database-backup.service.ts:235-254`. `keepLastAmount: 14` is at `config.dto.ts:551`, and the default concurrency (3 and 1) at `:599-601`.
  - Floccus uploads `<file>.lock` with `<html><body>I am a lock file</body></html>` (`WebDav.ts:151-157`), refreshes it every minute (`:341`), and in a browser uploads to `.temp`, then moves it into place (`uploadBookmarkFile`, about `:416-428`).
  - systemd.exec(5): "Similar, StateDirectory=, LogsDirectory=, ... also exclude the specific directories from the effect of ProtectSystem=". The health unit runs as root, so `StateDirectoryMode=0700` gives a root-only directory.
  - `/data/`: `compose.yaml:15` mounts `${UPLOAD_LOCATION:?}:/data`. The drill's throwaway env sets `UPLOAD_LOCATION=/srv/immich/library` (`drill-remote.sh:105`), as the template does.
  - stalwart-cli `--stdin` rests on the mechanics review's live help read of 1.0.13, which is a probe. The patch shape matches the `--field` value at `drill-remote.sh:326`.
  - T2's probe quoting expands on orpheus to `sed -n "s/^IMMICH_PIKAPODS_API_KEY=\(.*\)/header = \"x-api-key: \1\"/p"` and `-d '{"name":"backup-database"}'`. `render.sh` writes `NAME=value` with no quotes, so the header carries the bare key.

## Major

### V1. T9's orpheus drill restores a snapshot from before the merge, while the strict orphan rule and the "backup incomplete" stop assume the nightly fresh dump (correctness)

- **Location.** plan:88 (T5: "With the nightly fresh dump, none is expected"), plan:144 (T9), plan:184 (standing answer), plan:190 (stops); fold record:64 (m9 dropped: "Ruling 1's fresh nightly dump shrinks the window to seconds anyway").
- **Defect.**
  - T9 runs from the branch before Geoff approves the PR. T2's nightly dump step reaches orpheus only at After merge step 2. The snapshot T9 restores is still built the old way: Immich's 02:00 UTC dump, paired with the 03:00 files and a manifest whose `photos` and `videos` come from the live API at 03:00 (`servers-backup:160-161, 237`).
  - An upload, or a move to the trash, between 02:00 and 03:00 UTC falls in that window. That is 18:00 to 19:00 in Alaska, an evening hour for household phones. The drill then fails one of two ways:
    - At the existing exact count check (`drill-remote.sh:405-406`), which no standing answer covers.
    - If the changes cancel out, at T5's new "original with no row" or "missing original" verdict. The plan's row at :184 then calls this "a backup is incomplete", fails the drill, and stops for the conductor. That stop is also in the plan's stop list (:190).
  - The fold's reason for dropping mechanics m9, and data M3's window, holds only after the merge. For the drill this pass runs, the strict rule gives a false "incomplete backup" stop, with Geoff pulled in on a known artifact.
- **Fix.**
  - Add a standing-answer row for T9 (or a line in T5's verdicts). When the drill's count mismatch or orphan and missing originals are all dated inside the window, the drill reports them as "the pre-merge dump-to-snapshot window", not as an incomplete backup. Dated inside the window means a file mtime, or an asset's `createdAt` or `deletedAt` in the restored database, later than the dump's timestamp, which is in its file name (`immich-db-backup-YYYYMMDDTHHMMSS-...`, `database-backup.service.ts:235`).
  - Record the window under `## Not checked` with the counts, close with `## Bar unmet: orpheus drill (pre-merge window)`, and set the post-merge drill as the proof.
  - Alternatively, run T9's orpheus drill only when the restored manifest's dump time and snapshot time show no activity in the window. That is weaker, because the drill must already be running to read them.
  - Either way, correct T5's sentence to "after the merge, none is expected".

## Minor

### V2. The executor prompt forbids every file deletion on orpheus and allows one probe call, but the plan's probe deletes a dump and its standing answer reruns the probe (correctness)

- **Location.** prompt.txt:13 ("The only write ... one `POST /api/jobs` `backup-database` call"), prompt.txt:15 ("No file on orpheus or ward is deleted"); plan:46 ("The job's cleanup then deletes the oldest of the 14 dumps"); plan:182 ("Fix a traced cause and rerun once").
- **Defect.** The authorized probe deletes a file on orpheus through Immich's `cleanupDatabaseBackups` (`database-backup.service.ts:104`). The probe row allows a second call, and the prompt allows one. A literal executor sees two rules it cannot both keep, and may stop.
- **Fix.** Add to the prompt's deletions line: "except the oldest Immich dump that the probe's own `backup-database` job removes (restic still holds it)". Change "one `POST /api/jobs`" to "the T2 probe, at most twice per the plan's probe row".

### V3. T1 says to read "every command" live, but the screen includes a restart, a prune, and a journal vacuum (correctness)

- **Location.** plan:36 ("Read every command and its healthy output on the live servers ... read-only").
- **Defect.** "Every command" covers `systemctl restart immich.service`, `docker image prune`, and `journalctl --vacuum-size`, which are writes or deletions. The prompt forbids them (prompt.txt:13 and :15), so the instruction contradicts itself, and the PR's `## Decisions` would have no excerpt for those lines.
- **Fix.** "Read each health, status, `df`, and `du` command live, read-only. Write the restart, prune, and vacuum commands from the unit files and man pages, never run them, and mark them `not run` in `## Decisions`."

### V4. `--keep-stopped` refuses on a `failed` webdav unit, which blocks a rebuild for a harmless state (correctness)

- **Location.** plan:44 ("refuse with `fail manifest` if any `webdav@` instance is not inactive"); `server-restore:201` (the filter it reuses: `$3 != "inactive"`).
- **Defect.** `STOP_CMD`'s `systemctl stop "webdav@*.service"` leaves a unit that had already failed in `failed`, not `inactive`. The reused filter counts `failed` as running, so a member whose rclone instance crashed earlier blocks `provision.sh rebuild` at the manifest step. That fails closed, but the cause is benign. The filter suits server-restore, which must also stop an `activating` unit. For the refusal, the question is only whether a unit can take writes.
- **Fix.** For the `--keep-stopped` refusal, refuse when the state is `active`, `activating`, `reloading`, or `deactivating`, and treat `failed` as stopped. Add one test case with a `failed` unit, which passes.

### V5. T3's `is-active` read right after `systemctl start` can still pass a unit that fails in namespace setup (correctness)

- **Location.** plan:63.
- **Defect.** For `Type=simple`, systemd reports the start done after fork. A namespace failure happens in the child just after, so an `is-active` read straight after the start can read `active` and flip to `failed` a moment later. The fakes cannot show this. The check can pass live in exactly the case it exists for.
- **Fix.** Read `is-active` after a short settle, for example up to five 1-second polls that require `active` on the last read, or read `ActiveState` and `NRestarts` after one second. Use `SERVERS_TEST` overrides for the wait.

### V6. The nightly dump step leaves `check_dump`'s existing failure cases unreachable, or reachable only through `fail dump` (correctness)

- **Location.** plan:42 and :47-52; `tests/backup.test.sh:148` and `:175-208` (the 27-hour-old, corrupt, stray-newer, future-dated, and no-dump cases on the nightly path).
- **Defect.** Once the curl-impl writes a fresh good dump on each nightly run, `check_dump` picks that dump, and these cases fail (also `:148`'s dump name). If a knob suppresses the fresh dump instead, the dump step refuses with `fail dump` first, and each case passes on `failed_step == dump` without running `check_dump`'s age, future, or corrupt branch. That is a vacuous pass.
- **Fix.** Name the move in T2: the five `check_dump` cases run on the `--keep-stopped` path, where `check_dump` still reads the existing dump after a `--pre-stop`. Alternatively, assert a `check_dump`-specific log line (for example "is 27 hours old" or "fails gunzip -t") as well as the step name. Update `:148` to the fresh dump's name.

### V7. The orpheus drill's `verify` now runs about 100 minutes on a silent ssh session and a single Bash call (correctness)

- **Location.** plan:81 (90-minute budget), plan:144 (T9); `restore-drill.sh:318` (`ssh_opts` has no `ServerAliveInterval`), `:336-338` (`remote` captures all output until the step exits); prompt.txt:13.
- **Defect.**
  - `remote verify` prints nothing until it returns. A connection idle for 90 minutes or more can be dropped by a NAT or stateful firewall on the path. A dropped connection fails `verify` and deletes the server, which wastes the drill.
  - The executor's Bash tool caps a foreground call at 10 minutes. The prompt's "one live script per Bash call" does not say to run the drill in the background. Earlier drills of 17 to 19 minutes show that sessions managed this, but with no written rule.
- **Fix.**
  - In T5 or T6, add `-o ServerAliveInterval=30 -o ServerAliveCountMax=6` to `ssh_opts`. This is a one-line change in T6's file.
  - In T9 and the prompt's live-steps line, run each drill with `run_in_background` and wait with Monitor.

### V8. The design still names the no-op endpoint and the 208 tolerance, and the executor is told to read it (correctness)

- **Location.** design:70 (Outcome 1, `PUT /api/queues/backupDatabase`), design:74 (Outcome 5, "beyond the 208 orphan thumbnails"), design:87 ("A live read of the `backupDatabase` queue"); fold record:123-130 (E1 to E4 owed, not applied); prompt.txt:4.
- **Defect.** The plan overrides both (plan:23, the amendment), so this is not a build contradiction. Still, the approved design that the executor and the conductor's packet cite names a call that does nothing and a tolerance the amendment replaced. The mechanics review asked for the Outcome 1 correction "in the same commit".
- **Fix.** Add dated erratum lines E1 and E2 under the amendment. They correct mechanism wording only and leave the approved scope unchanged.

### V9. Ward's credential path in the log is the executor's word, not the drill's (correctness)

- **Location.** plan:148 ("the ward credential path (`--stdin`)"), plan:95.
- **Defect.** `verify_ward` prints no RESULT line naming how it set the password, so T9's log entry for #15 reads the plan, not the run. Contract F21 asked that the entry name "the credential path the code took".
- **Fix.** T5: `verify_ward` prints `RESULT throwaway passwords set through stalwart-cli --stdin for N accounts`, and the ward test asserts it.

### V10. After merge step 7 can miss an alert that opened and cleared overnight (optional)

- **Location.** plan:174; `cloudflare/monitor/src/tick.ts:170` (cleared conditions are deleted).
- **Defect.** `SELECT id FROM conditions` in the morning shows only conditions still open. A `media_down` that opened at 03:15 and cleared by 03:30 has already sent its email and left no row.
- **Fix.** Also read `SELECT "check", count FROM probe_failures` right after the nightly run, or check the workstation alert log or the inbox for a `media_down` or `heartbeat_problem` notice dated that night.

### V11. T7's state write: temporary file location (optional)

- **Location.** plan:131.
- **Defect.** The unit sets `PrivateTmp=yes`, so a `mktemp` under `/tmp` sits on a different filesystem from `/var/lib/servers-health`. `mv` then copies, and the write is no longer atomic.
- **Fix.** Say "a temporary file in the state directory, then a rename".

### V12. Small line and edge nits in T5 (optional)

- The integrity no-op sits at `drill-remote.sh:432`, not `:431` (plan:82). The plan's "follow the function" covers it.
- `start()` throws "Job is already running" when the queue is active (`queue.service.ts:192-195`). A drill whose restored Immich has thumbnail work in flight at `serve` would fail the start. Treat a 400 whose body says "already running" as started, or poll until the queue is idle before the start.
- Under `force`, a person with no `faceAssetId` and no face left is skipped (`media.service.ts:94-98`). A non-empty `thumbnailPath` on such a person reads as "regeneration failed". It is rare; exclude persons with a null `faceAssetId` from the derived query.
- The drill-remote test needs a `SERVERS_TEST` override for the library root (for example `DRILL_REMOTE_LIBRARY`) so the fixture tree stands in for `/srv/immich/library`. Name it in T5.

### V13. The webdav window rests on two measured nights (optional)

- **Location.** plan:43; data M2 option (a) asked for recent durations, and contract F14 for the last seven.
- **Defect.** Two nights under a minute is thin evidence after an upload-heavy day. The risk is bounded: three 5-minute `dav_ping` failures need more than about 10 minutes.
- **Fix.** In T2, read the last seven `servers-backup` durations from orpheus's journal (read-only) and record them under `## Decisions`.

## Owed to the fold record

None of these changes the approved design's scope, so none is an owner fork. V1's fix adds one standing-answer row and changes a sentence in T5. V2, V3, and V8 are text in the prompt and the design. The rest are plan or test details.
