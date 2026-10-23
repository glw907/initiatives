# Servers backlog, second batch

## Brief

This pass clears twelve items from the servers backlog: the rebuild's fresh Immich dump, the two emergency screens the second operator still lacks, the pod's leftover tooling, and the bookmarks pass's follow-ups. It changes no live server until you approve its PR.

Geoff chose the scope in chat on 2026-10-22: STATUS next action 1b (#2, #4, #7, #8, #9, #11, #15) plus #24 to #28, which the bookmarks pass filed against the same files. #12 (Immich sign-in through Stalwart) and #13 (Bulwark) stay out as feature passes.

Initiative: self-hosting

Amended 2026-10-22 (Geoff, in chat): the nightly backup on orpheus also takes a fresh Immich dump before it counts and copies, reusing the rebuild's dump step (`POST /api/jobs` with `{"name":"backup-database"}`, then a wait for a dump newer than the call that passes `gunzip -t`). With that, the drill fails on any original (`library/` or `upload/`) with no database row; only the regenerated derived folders may hold orphans, reported as counts.

### Standing answers

| Situation | Answer |
|---|---|
| No cx33 stock for the orpheus drill | Use the fallback list #28 builds (cpx32 first). Before it lands, pass `--type cpx32`. |
| No stock of ward's drill type | Skip the ward drill and list #15's live proof under `## Not checked`; the tests still gate it. |
| `stalwart-cli` has no stdin or file form for a credential | Set the throwaway password through Stalwart's HTTP management API with a 0600 curl config file. If that has no form either, reword the test to claim what it checks, and record it in `## Decisions`. |
| A task passes twice its estimate | Extend once to four times, then stop. |
| The path passes twice the estimate (660 minutes) | Keep going up to 800, then stop and write STATUS. |
| Drill spend | Up to 5 EUR across both drills; each drill deletes its server on every exit. |

## Outcome

1. **A rebuild starts from a fresh dump (#2).** `servers-backup --pre-stop` on orpheus starts Immich's `backupDatabase` queue (`PUT /api/queues/backupDatabase`, listed by v3.3.4 on 2026-10-22) and waits, up to a fixed limit, for a dump newer than the call before it stops Immich. It refuses on a timeout, so `provision.sh rebuild` stops before any wipe. `--keep-stopped` leaves dubplate stopped instead of restarting it. dubplate has no unit on orpheus today, so that half is tested against fakes only.
2. **The backup's counts hold still (#26).** The nightly run stops the `webdav@*` units for the count and the copy, and a trap starts them again on every exit, as it already does for dubplate. `server-restore` starts each member's unit only after its directory exists, and reports a member it could not start instead of saying every service started.
3. **The emergency screens are whole (#4).** The runbook gains orpheus's commands under "Check a service and restart it" (Immich and the Floccus share) and a "Free disk space" screen for both servers: `df -h /`, the directories that grow (Immich's library and backups, Stalwart's data), what is safe to remove, and a stop line. Each command is read on the live servers first, read-only. `EMERGENCY.md` is re-rendered. This task goes first so the screens exist before the second operator's session on 2026-10-24.
4. **The pod's tooling retires (#7, #8).** `scripts/pod-pull.sh`, its test, and its fakes go, which makes #7 moot. The `pikapods-sftp` dry-run row goes; `immich-api` becomes `immich-orpheus`, same check. The variable `IMMICH_PIKAPODS_API_KEY` keeps its name, since renaming it touches the workstation store and orpheus's `backup.env`; that rename is filed for later.
5. **The restore checks trust the disk (#9).** `drill-remote.sh verify` compares every file under the restored library with the paths the database names, and fails on a file either side lacks, beyond the 208 orphan thumbnails ruled harmless (#10), which it counts and reports.
6. **Smaller fixes.** `render.sh` refuses a `WEBDAV_PASSWORD_*` that is not base64url (#24). `health.sh` checks every regular file in each share for ciphertext, skipping rclone's partial files, and sets `webdav_ok` false only on the second failing reading in a row (#25). The tick test gains a rejected fetch for `dav_ping`, and `server-restore`'s test reaches the malformed `webdav` entry (#27). `restore-drill.sh orpheus` tries cx33, then cpx32, then cx43 (#28). `verify_ward` stops passing the throwaway password on the command line (#15). The Caddyfile comment about `music.907.life` is corrected (#11).

## Files

`roles/backup/{servers-backup,server-restore}`, `roles/health/health.sh`, `secrets/render.sh`, `scripts/{drill-remote,restore-drill,dry-run}.sh`, `scripts/pod-pull.sh` (deleted), `roles/caddy/Caddyfile`, `cloudflare/monitor/test/tick.test.ts`, `docs/runbook.md`, `EMERGENCY.md`, `BACKLOG.md`, and the matching `tests/` files and fakes. The monitor Worker's source does not change, so it needs no deploy.

## Out of scope

#12, #13, #18, #22, #23 (dated or Geoff's own); renaming `IMMICH_PIKAPODS_API_KEY`; removing the `PIKAPODS_SFTP_*` names from the workstation store; the 17 stale agent worktrees in the servers checkout; running a production rebuild.

## End-to-end check

On the branch, `restore-drill.sh orpheus` passes with no `--type`, its verify reporting the disk-against-database comparison, and `restore-drill.sh ward` passes with the new password path. A live read of the `backupDatabase` queue on orpheus writes a dump newer than the call. After the merge, the conductor runs `scripts/apply.sh orpheus --apply`, then `--check`, and the next heartbeat carries `webdav_ok: true`.

## Risk class and estimate

`auth-data` (`roles/backup/**`, `secrets/**`, `scripts/{restore-drill,dry-run,pod-pull}.sh`) and `live-account` (the two drills). No pre-flight step needs Geoff: the drills, the read-only ssh probes, and `apply.sh` run on rules the workstation already holds. About 330 path minutes, from Pass 3's cutover running 1.25 times its plan.

Run: this session plans unattended once Geoff approves (`spec-plan-review` sets the review depth), then hands the plan to a fresh `conductor-servers`, which launches the executor `servers-backlog-2` and brings one packet with the PR.
