# Backlog 2 plan review: contract and criteria

Target: `self-hosting/plans/2026-10-22-backlog-2-plan.md` at initiatives `f36b477`, against the design `self-hosting/specs/2026-10-22-backlog-2-design.md`. Code read: servers `main` at `e036a70`. Nothing was run live.

The question for each task: does its test name a fixture that would fail on the backlog item's defect, and can its acceptance pass vacuously? Findings are ranked by consequence.

Counts: 2 blocker, 13 major, 9 minor. One finding is a conditional OWNER FORK (F14).

## Blockers

### F1. T5's disk comparison passes vacuously under the existing fake (blocker, correctness)

Location: plan:25; `tests/drill-remote.test.sh` (the `docker` stub at about :100 only logs); `scripts/drill-remote.sh:397`.

Defect: #9 exists because a check passed with nothing to check. In `drill-remote.test.sh`, the `docker` stub logs and prints nothing, so the new `psql` query for `asset.originalPath`, `asset_file.path`, and `asset.encodedVideoPath` returns zero rows. With no database paths, nothing can be missing, and "fail on any database path with no file" passes. The same thing happens live if the query or the path mapping goes wrong. Immich stores container paths (for example `/data/library/...`), while the drill compares against the restored host tree. If the prefix mapping strips or misses every path, the script reports zero missing. The plan names no fixture paths, no prefix, and no guard for an empty result.

Fold: (a) The script fails when the query returns zero paths while `/server/statistics` reports `photos + videos > 0`. It also prints the count of paths it checked in its RESULT line. (b) Read one real path per column from orpheus's database first (read-only `psql ... limit 1` over ssh), so the fixture uses Immich v3.3.4's real container prefix. (c) The test's `docker exec ... psql` stub answers that query with fixture paths in that prefix, over a fixture tree where one named file is absent. Three cases: a missing file fails and names its path, an empty query result fails, and a complete tree passes with the checked count equal to the fixture's row count.

### F2. T1's acceptance contradicts T1's scope (blocker, correctness)

Location: plan:21; `docs/runbook.md:173` and `EMERGENCY.md:171` ("Who to call ... Lands with the runbook session (D5)").

Defect: The acceptance says `EMERGENCY.md` has no "land with" or "Lands with" stub line, but T1 writes only two screens. The "Who to call" stub sits in the rendered emergency part and stays, so the acceptance cannot pass unless the executor rewrites or deletes an out-of-scope stub. #4's third screen, "unban a client", is already written (runbook:46-64), so nothing in #4 needs that line gone.

Fold: Scope the acceptance to the two sections T1 rewrites. "Check a service and restart it" and "Free disk space" contain no "land" stub, and "Who to call" is byte-identical to `main`. In T10, mark #4 done and note that "unban" was already written.

## Major

### F3. T2's webdav restart under `--keep-stopped` is untested and can undo the rebuild's stop (major, correctness)

Location: plan:22; `hosts/orpheus/host.env` (`STOP_CMD='... --pre-stop && sudo systemctl stop "webdav@*.service"'`); `tests/backup.test.sh:302-304`.

Defect: The plan says the nightly run and `--keep-stopped` both stop every active `webdav@` unit and start them again through the EXIT trap. On the rebuild path, `STOP_CMD` has already stopped every instance before `--keep-stopped` runs. If the code starts the instances again, Floccus writes land after the final backup and before the wipe, and the backup misses them. The planned test, "webdav units stopped and restarted on success and on a failed restic step", does not say which mode it runs in. A test of the nightly run alone would pass while `--keep-stopped` restarts the shares.

Fold: Add a case where `--keep-stopped` runs after the units are already inactive. It asserts zero `systemctl start webdav@` lines and every instance still inactive. On the nightly run, the test asserts that the units started are exactly the units the run stopped.

### F4. T2's webdav test proves neither the enumeration nor the order (major, correctness)

Location: plan:22; the `systemctl` stub at `tests/backup.test.sh:45-62` (no `list-units` branch, `*) exit 0`).

Defect: #26's defect is a sync between the manifest's count and the copy. The stub answers `list-units` with an empty exit 0. Code that enumerates units that way finds none, stops nothing, and starts nothing, and an assertion on "no error" passes. An assertion only that stop and start lines exist would also pass with the stop placed after `write_manifest`.

Fold: Give the stub a `list-units 'webdav@*'` branch fed from `FAKE_UNITS_DIR`. Make its `stop webdav@X` append one file to `srv/webdav/X`, standing for a write in flight that lands at the stop. The manifest's `webdav.X` must then equal the file count after the stop, so a count taken before the stop is off by one. In the log, the stop must come before `restic backup` and the start after it, on both the success path and the failed-restic path.

### F5. T2's corrupt-dump case is ambiguous, and the test knobs it needs are unnamed (major, correctness)

Location: plan:22; `tests/backup.test.sh:66-79` (curl-impl), :281-329 (the existing pre-stop cases), :293.

Defect: The plan says the poll waits for a newer `*.sql.gz` that passes `gunzip -t`, and it also lists "a corrupt new dump" as a test case. It does not say whether a failing `gunzip -t` is retried or ends the run. A dump caught mid-write fails `gunzip -t`, so failing at once would refuse real rebuilds by chance. Retrying until the deadline makes the corrupt case a timeout case. The criterion cannot be written until one of the two is chosen.

The fixtures need three things the plan does not name:

- A test-only deadline and poll interval under `SERVERS_TEST=1`, or every pre-stop case waits 10 minutes.
- A curl-impl branch that answers `PUT /api/queues/backupDatabase` and writes the new dump. Without it, today's curl-impl exits 22 on that URL, so every existing pre-stop case at :281-329 fails.
- A rewrite of :293, which counts total curl calls across both runs (2) and becomes 3.

Fold: A new dump that fails `gunzip -t` is retried until the deadline. At the deadline the run exits non-zero and Immich is still active. Name the `SERVERS_TEST` knobs and the curl-impl branch. Rewrite :293 to count the curl calls in the `--keep-stopped` run's own log, which must be zero. Add one ordering assertion: the statistics GET comes after the new dump appears, and `systemctl stop immich.service` comes after both.

### F6. T5's #15 test repeats the defect it is meant to fix (major, correctness)

Location: plan:25; `tests/drill-remote-ward.test.sh:120-123` (the `stalwart-cli` fake logs only `$1 $2 $3`) and :234.

Defect: #15 says the test that claims the password stays out of argv logs only three arguments. The plan's test still reads "asserts the password appears in no logged argument" and does not require full-argv logging. If the fix keeps `stalwart-cli` with some other form, or moves to curl, a fake that logs three words still passes whether or not the secret is in argv.

Fold: The `stalwart-cli` fake logs `$*` in full, and a curl fake, if the HTTP route is taken, logs `$*` plus the names of its `-K` files. The test makes two checks. The negative one: no throwaway password appears in any logged argv. The positive one: the API or CLI received the password through stdin or a 0600 file, read by the fake and compared. The temporary file is gone after `verify`.

### F7. T5's orphan threshold departs from the design (major, correctness)

Location: plan:25 ("fail only past 250"); design:28 ("fails on a file either side lacks, beyond the 208 orphan thumbnails ruled harmless").

Defect: The design tolerates only the ruled-harmless thumbnails. The plan tolerates 250 files without a row in any directory, originals included. An original in `library` or `upload` with no row is a photo the restored database does not know, which is the failure #9 is meant to catch. Thumbnails are not in the backup set either (`servers-backup:225-227` backs up library, upload, profile, and backups), and `verify` regenerates them on the drill host. The 208 orpheus orphans never reach a drill, so the threshold mostly applies to directories where it should be zero.

Fold: An orphan in `library` or `upload` fails at more than 0. Orphans in `thumbs` and `encoded-video` are counted and printed, and fail past 250. The test covers 250 (pass), 251 (fail), and one orphan original (fail).

### F8. T7 misstates today's behavior for large files (major, correctness)

Location: plan:27 ("skipping ... files past 10 MiB as today"); `roles/health/health.sh:82-85`; `tests/health.test.sh:148-150`.

Defect: Today a file past 10 MiB reads `webdav_ok=false` without being parsed, and the test "a file past 10 MiB reads false without being parsed" pins that. If the executor follows "skipping ... as today", a large plaintext file passes the ciphertext check, and the existing test gets rewritten to match.

Fold: Change the plan text to "a file past 10 MiB reads false unparsed, as today" and keep the :148-150 case. Skip only `*.partial`.

### F9. T7's every-file check has no live fixture and could alert after the merge (major, correctness)

Location: plan:27; `tests/backup.test.sh:95` (its fixture already holds `bookmarks.xbel.bak` in a share).

Defect: The new rule makes every regular file except `*.partial` either the ciphertext envelope or a failure. Nobody has listed what Floccus and rclone actually leave in the live shares, such as backup copies, lock files, or other devices' files. If a legitimate non-envelope file exists, `webdav_ok` turns false at the first heartbeat after `apply`, and the plan finds out only in "After merge".

Fold: Before writing the check, list the live share files on orpheus by name and size only, read-only (`sudo find /srv/webdav -type f -printf '%P %s\n'`). Contents are never read. Build the test fixture from those names. The acceptance gains one line: every live file name either matches the envelope rule or is a named, intended exclusion.

### F10. T2 and T3 turn the gate red until T8 (major, optional)

Location: plan:28; `tests/orpheus-golden.test.sh:21-22`; `scripts/check.sh:213` (the tests leg runs on any `roles/` change).

Defect: T2 and T3 change two pinned files, so the golden test fails in their own gate run and in CI until T8. That breaks "runs test-first" and the per-task `diff-reviewer` beside a green CI. T8 also says the golden pins "health scripts", but `roles/health/health.sh` is not in the golden list (only `roles/health/install.sh`), so T7 changes no golden line. T8's acceptance (`check.sh` passes) also passes if every hash is refreshed without thought.

Fold: Each task updates the golden line for the file it changes, along with the comment. T8 becomes a check that the GOLDEN block's diff against `main` names only `roles/backup/servers-backup` and `roles/backup/server-restore`. This saves T8's separate run, about 10 minutes.

### F11. T3's behavior is left open, and its acceptance cannot hold for either choice (major, correctness)

Location: plan:23; `roles/webdav/install.sh:69`.

Defect: T3 lets the executor either create the directory and start the unit, or report the member and exit non-zero, "whichever the role's installer shows is safe". The acceptance then says both cases "fail closed", which contradicts the create-and-start branch. The installer already answers the question: `install -d -o webdav -g webdav -m 0700 "$root/srv/webdav/$name"` is what the role does on every apply, so creating the directory is safe. The plan text also gives uid 2001 and takes the mode "from install.sh", which is 0700. Tests run unprivileged, so a real `-o webdav` fails there without a seam.

Fold: Settle it in the plan: create the directory as the installer does, then start the unit. The test asserts that the directory exists with mode 0700, that the owner goes through a stubbed `install` or `chown` logged with `-o webdav`, and that the unit starts. "Fail closed" applies only to the malformed-entry case.

### F12. T3's fixture as written never reaches the code (major, correctness)

Location: plan:23 ("a member listed in `roles/webdav/users.txt` but absent from the snapshot"); `roles/backup/server-restore:201`; `tests/server-restore.test.sh:81-88`.

Defect: `server-restore` decides which instances to stop and start from `systemctl list-units 'webdav@*'`, which the test feeds through `FAKE_WEBDAV_ACTIVE`, and never reads `users.txt`. A fixture that adds a `users.txt` member without adding the running unit never puts that member in `stopped[]`. The case passes whether or not the fix exists.

Fold: The fixture adds `webdav@membera.service` to `FAKE_WEBDAV_ACTIVE` and leaves `srv/webdav/membera` out of the snapshot and its manifest. For the malformed case, assert the exact message at :231 ("the manifest's webdav entry '...' is malformed"). Also assert that the live share is unchanged (`LIVE`) and that the stopped units started again, so another abort path cannot satisfy the case.

### F13. Nothing tests the "never claim every service started" promise (major, correctness)

Location: plan:23; `roles/backup/server-restore:182-185` and :315.

Defect: `start_stopped` ignores each `systemctl start` exit status, and the script then prints "Done. Services are started again." both unconditionally. The design promises the script "reports a member it could not start". Neither planned case makes a start fail.

Fold: Add a case where the fake `systemctl start` fails for one named unit. The output names that unit, lacks "Services are started again", and the exit is non-zero.

### F14. The nightly webdav stop can raise routine alerts every night (major, correctness; conditional OWNER FORK)

Location: plan:22; `cloudflare/monitor/src/alerts.ts:14` and :91-93 (`dav_ping`, threshold 3); `cloudflare/monitor/wrangler.*` (cron `*/5`); `roles/health/systemd/servers-health.timer` (15 minutes).

Defect: While T2 holds the instances stopped for the count and the restic copy, `dav.907.life/geoff/` answers 502. If that window passes about 10 to 15 minutes, `dav_ping` fails three ticks in a row and sends a routine `media_down` email. A window past about 30 minutes also beats T7's two-reading rule. Either way the nightly run would send the routine email #25 is meant to stop. No criterion measures the window, and "After merge" checks one heartbeat, not the first nightly run.

Fold: In T2, read the last seven nightly durations of `servers-backup.service` from orpheus's journal (read-only) and record them under `## Decisions`. "After merge" gains one item: on the morning after the first nightly run, the monitor shows no `media_down:dav_ping` and no `heartbeat_problem` for orpheus `webdav`.

OWNER FORK, only if the measured window exceeds 10 minutes:

- (a) Accept a nightly routine alert.
- (b) Stop the shares only for the count, and copy `/srv/webdav` through a staging rsync as dubplate does.
- (c) Mute `dav_ping` from 03:00 to 03:30 UTC.

Recommendation: (b). It holds the count still without a long outage and reuses a pattern the script already has.

### F15. T4's acceptance grep cannot pass without a harmful edit, and it misses a half-rename (major, correctness)

Location: plan:24; `.gitleaksignore:2`; `scripts/dry-run.sh:520-521`; `tests/dry-run.test.sh:52`, :108.

Defect: `git grep 'pod-pull\|pikapods-sftp\|immich-api'` hits `.gitleaksignore:2`, which is a commit-pinned fingerprint for `tests/pod-pull.test.sh`. `gitleaks git` scans history and still needs it. Passing the acceptance literally means deleting the line, and the next full-history scan then flags the old commit. The grep also cannot see `NEEDS_immich_api` or `check_immich_api`, which use underscores. "Lists `immich-orpheus`" can be met by a listing alone.

Fold: Exempt `.gitleaksignore` in the acceptance and keep its line. Add `immich_api` to the grep. Make the test behavioral: `run_dry` output has exactly one `| immich-orpheus | PASS |` row and zero `pikapods-sftp` rows. Remove the `PIKAPODS_SFTP_*` exports from the test's environment (:108). Also check `tests/fakes/sshpass`, which only the removed row uses (it also appears in `tests/harness/lib.sh`), and retire it if nothing else needs it.

## Minor

### F16. The PUT's key handling is untested as written (minor, correctness)

Location: `tests/backup.test.sh:73`.

Defect: The curl-impl logs only `curl $url`, so "never an argument" cannot fail for the new PUT. The live probe exercises the API, not the script's own request, so it cannot catch a wrong method or body in the script either.

Fold: The curl-impl logs `$*`. For the queue URL it requires `-X PUT` and the body `{"command":"start"}`, and it requires the key in the stdin config. The secret-sweep at :161-162 then covers argv for real. Record the probe's exact request in the PR, so the two can be compared.

### F17. T6's stock test needs a fake the plan does not name, and its cases are thin (minor, correctness)

Location: plan:26; `tests/fakes/hcloud:6` (`FAKE_HCLOUD_AVAIL` stocks every type at once); `scripts/restore-drill.sh:247-257`, :278-283.

Defect: "The fake reporting no cx33 stock" needs per-type availability, which the fake does not have. The plan text "tries cx33, then cpx32, then cx43, in each location" can be read type-major or location-major. The `--hold` path, which builds beside the Primary IP at :279-282, has no stated fallback behavior.

Fold: Add a per-type variable to the fake, such as `FAKE_HCLOUD_AVAIL_cx33`. State type-major order. Add these cases:

- cx33 and cpx32 both out: the drill takes cx43.
- All three types out: exit 3, naming each type.
- `--type cx33` pinned with none in stock: exit 3, and cpx32 is never described.
- Ward with no stock: cpx32 is never described.

State whether `--hold` falls back.

### F18. T6's render refusal criterion is incomplete, and live values are not pre-checked (minor, correctness)

Location: plan:26; `tests/render.test.sh:191-204`.

Defect: The case "refuses a value with a quote and a newline" does not assert that nothing was installed, that the message names the variable, or that the value stays out of the output and the ssh log. Nothing confirms that the five live store values pass `^[A-Za-z0-9_-]+$` before "After merge" runs `apply --apply`.

Fold: Add those three assertions. Before the PR, run a name-only local check that each `WEBDAV_PASSWORD_*` in the age store matches the regex (`ok` or `bad` per name, never a value), and record the result under `## Not checked` or `## Decisions`.

### F19. T7's health and tick cases miss a reset and the tick's own outcome (minor, correctness)

Location: plan:27; `cloudflare/monitor/test/tick.test.ts:335`, :809.

Defect: The two-reading test covers fail-true then fail-false. It does not cover the sequence fail, pass, fail. That sequence should read true; a counter that never resets reads false and still passes the planned case. It also lacks a state-path override for an unprivileged test and a check of the state file's mode. The tick case for a rejected fetch does not say whether `tick` resolves. :809 shows a rejection that throws for `stalwart_live`.

Fold: Add the reset case, a `HEALTH_STATE` override, and a mode check (600). The tick case asserts that `tick` resolves, the `dav_ping` failure count increments, and the third rejection raises `media_down`.

### F20. T1's live-match criterion leaves no evidence, and one command is unsafe in its common form (minor, correctness)

Location: plan:21.

Defect: "Each command was run once live and its output matches the screen" leaves nothing for the reviewer to check. "`docker image prune`" is safe only without `-a`. With `-a` and Immich stopped, it deletes Immich's images, and the restart then needs a pull. The orpheus restart screen gives no quiet window, but the 03:00 UTC backup will now stop the shares and dubplate.

Fold: Record each command with a one-line output excerpt in the PR (`## Decisions` or a collapsed block). Write the prune as `docker image prune` with no `-a`, and add a line that says never to use `-a`. Give orpheus a no-restart window around 03:00 UTC, as ward's screen has.

### F21. T9's acceptance does not tie the live drill to the new code paths (minor, correctness)

Location: plan:29.

Defect: "Both pass" holds even if the comparison checked zero paths (see F1) or the ward drill took the old argv path.

Fold: The drill log records the RESULT line with the checked path count greater than 0 and the orphan counts per directory. The ward entry names the credential path the code took (stdin, file, or HTTP API).

### F22. T2's dump-freshness rule differs from the design (minor, correctness)

Location: plan:22 ("records the newest dump's mtime ... polls for a newer"); design:24 ("a dump newer than the call").

Defect: A dump that finishes between the mtime read and the PUT, such as the 02:00 nightly running late, satisfies the plan's rule without being the dump the call asked for.

Fold: Compare against the time of the call, as the design says, and give the test one case: a dump dated between the recorded mtime and the call does not satisfy the wait.

### F23. T7's Caddyfile fix has no acceptance (minor, optional)

Location: plan:27; `roles/caddy/Caddyfile:8-9`.

Fold: The acceptance becomes: `grep -c 'no DNS record' roles/caddy/Caddyfile` is 0, and the comment names `cloudflare/dns/orpheus`.

### F24. Over-ceremony is low (minor, optional)

The only waste found is T8 as its own task. F10 folds it into T2 and T3 and leaves a one-line check, saving about 10 clock minutes and one gate run. The per-task `diff-reviewer` reads and the T2 live probe each answer a real risk, so this review does not cut them.
