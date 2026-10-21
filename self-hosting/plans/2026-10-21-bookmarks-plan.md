Initiative: self-hosting

# Bookmarks pass plan

## Brief

The household's Floccus bookmark share went up on 2026-10-21 as a direct build, with Geoff's leave to skip the pull request and packet: one rclone instance per member on orpheus behind `dav.907.life`. Five accounts exist: Geoff, the second operator, and household members A, B, and C. This pass makes it part of the servers' routine. It moves the deploy into `apply.sh` and `render.sh`, then adds the share to the nightly backup, `server-restore`, the restore drill, the monitor, the health heartbeat, the credential dry run, the monthly review, and Pass 6's advisory watch. It waits for Pass 5's build to merge, because Pass 5 changes most of the same files and pins the hashes of orpheus's role list, secrets list, and backup scripts. The planned path is 230 minutes. Nothing here needs Geoff before launch.

## Inputs

- **Rulings (Geoff, 2026-10-21, in chat on pavilion)**: Floccus with its encryption on, on orpheus, one account for each of the five household members, all created at launch, Chrome and Firefox only. Stalwart is the identity store with no Kanidm; Immich's sign-in through Stalwart is servers BACKLOG #12 and is out of this pass. Each member keeps their own Floccus passphrase. The WebDAV passwords are server credentials in Geoff's age store, with copies in `Servers emergency`. The service joins the whole management routine, and the runbook carries every procedure. The servers repo's `docs/decisions.md` ("Rulings and decisions from the bookmarks work") records each one with its reason.
- **What exists (servers branch `bookmarks-phase1`, workstation branch `self-hosting-bookmarks`)**: `roles/webdav` (installer, `users.txt`, `webdav@.service`), the `dav.907.life` site in `roles/caddy/Caddyfile`, `dav` in `cloudflare/dns/orpheus` (published 2026-10-21), `scripts/webdav-deploy.sh` and its test, `tests/webdav.test.sh`, the runbook's "Bookmark sync" section, and the five `WEBDAV_PASSWORD_*` names in the workstation branch store and its registry.
- **Review findings this pass carries** (plan-reviewer, 2026-10-21): Floccus merges against its own cache, so a restored older file deletes newer bookmarks from every device (M2). It accepts a plaintext file when a passphrase is set (M3), so a check must assert that each `bookmarks.xbel` parses as JSON with `ciphertext` and `salt` keys. That check needs no passphrase. `httpOk` in `cloudflare/monitor/src/checks.ts` treats a 401 as down (M4). The drill and `server-restore` stop only immich and dubplate, and the webdav user needs a fixed id so restic's numeric owners match (M5; the role uses 2001). `--keep-stopped` doesn't stop webdav (m3).

## Entry

Pass 5's build PR (servers branch `pass5-mail`) and its workstation PR are merged, and `servers-mail` has stopped. Pass 5's date phase may run alongside, since it touches none of these files. `scripts/webdav-deploy.sh --check` passes from the phase-1 branch: the share is live on orpheus.

## Pre-flight

None. Every step runs on rules the workstation already holds: `scripts/apply.sh * --apply`, `scripts/restore-drill.sh`, `cloudflare/deploy.sh monitor`, `cloudflare/dns.sh --apply`, ssh to orpheus, and the `secret-set.sh` form. The executor names any classifier denial under `## Not checked`, and the conductor notifies.

## Tasks

The branch starts from `origin/main` after Pass 5's merge. Its first act merges `origin/bookmarks-phase1`, resolving any conflict by keeping both sides' content. Every task is `auth-data` unless marked otherwise, runs test-first, and gets a `diff-reviewer` task-scope read while CI runs.

- **B1. The share joins apply and render (45 min).** Add `webdav` to `hosts/orpheus/roles.txt`, before `caddy`, with `backup` still last. Add one `secrets/templates/orpheus/webdav-<name>.env` per member (Pass 5's per-host layout), with literal `RCLONE_USER` and `RCLONE_ADDR` rows and `RCLONE_PASS=@WEBDAV_PASSWORD_<NAME>`. Add a matching row in `hosts/orpheus/secrets.txt` (`/etc/webdav/<name>.env 0600 root`). Retire `scripts/webdav-deploy.sh` and its test, then point the runbook's "Deploy or change the share" at `apply.sh`. Update the orpheus golden test's hashes and its comment (`tests/orpheus-golden.test.sh`). Then run `scripts/apply.sh orpheus --check`, then `scripts/apply.sh orpheus --apply`, outside 02:30 to 04:00 UTC. *Test*: `render.sh orpheus` against the fakes writes the five env files with each password and reports a missing name by name; `apply.sh orpheus --check` lists the role. *Acceptance*: the gate passes, `apply.sh orpheus --check` exits 0 after the apply, and `scripts/webdav-deploy.sh --check`, run from the phase-1 branch before its deletion lands, prints only `ok` lines.
- **B2. Backup and server-restore (45 min, pair with B4).** Add `/srv/webdav` to `servers-backup`'s set (`roles/backup/servers-backup:215`) and each member's file count to its manifest (`:148-160`). Add it to `server-restore`'s `data_dirs` (`:52`), and stop and start every `webdav@` unit around the swap (`:195`). Add the units to orpheus's `STOP_CMD` in `hosts/orpheus/host.env`, so a rebuild's final backup holds no write in flight. *Test*: the backup and server-restore tests gain the directory, the manifest counts, and the unit stop and start, including the interrupt path. *Acceptance*: after the next nightly run, the snapshot lists `/srv/webdav/geoff/bookmarks.xbel` once Geoff's first sync has run, the manifest carries the counts, and `restic check` passes.
- **B3. The restore drill (40 min, after B2).** Allow `webdav` in orpheus's drill role list. On the drill host, check each member's count against the manifest, check that each instance answers 401 over loopback with no login, and check that each file parses as JSON with `ciphertext` and `salt`. Then run `scripts/restore-drill.sh orpheus` and record it in `docs/restore-drill-log.md`. *Test*: the drill test refuses a plaintext fixture file and a count mismatch. *Acceptance*: the drill passes with the webdav rows and its server is gone.
- **B4. Monitor and health (50 min, pair with B2).** In `cloudflare/monitor`, give `httpOk` an expected-status form and add a `dav_ping` check that wants 401 from `https://dav.907.life/geoff/`. That touches `types.ts` CheckName, `config.json` (on), the media list in `alerts.ts:91`, and the `test/tick.test.ts` fixture. Add a heartbeat field, `webdav_ok`, that `health.sh` sets false when any listed member's instance doesn't answer 401 on its loopback port, or when any present `bookmarks.xbel` isn't ciphertext JSON. `heartbeat.ts` validates the field, and the monitor raises a non-urgent condition on false. Then `cloudflare/deploy.sh monitor`. *Class*: `auth-data` for `heartbeat.ts` and its tests (`web-auth-security-reviewer` reads them), `ordinary` for the rest. *Test*: a 401 passes `dav_ping` and a 200 or 502 fails it; a heartbeat with `webdav_ok: false` opens one condition and a repeat opens none; `health.sh` against fixtures flags a plaintext file and a silent port. *Acceptance*: `npm test` and the gate pass; after the deploy, `/alerts` shows no condition, and the next heartbeat row carries `webdav_ok: true`.
- **B5. The catalog, the review, and the advisory watch (25 min, `ordinary` except `dry-run.sh`).** In `scripts/dry-run.sh`, add a `webdav-` row per member. It reads the member's share with its login from a curl config on stdin and wants 200, and with no login wants 401. In `docs/monthly-review/prompt.txt` step 2, add rclone to the release notes it reads, with the pin in `roles/webdav/install.sh`. In step 5, add a yearly reminder (October) to rotate the WebDAV passwords. Amend Pass 6's C6 in the initiatives plan so the advisory watch also reads `rclone/rclone`, the pinned upstream release outside `unattended-upgrades`. Drop the runbook's "Still to join the routine" paragraph, and add the credentials-table rows. *Acceptance*: `scripts/dry-run.sh webdav-` passes all five members; the privacy check passes on the initiatives diff.
- **B6. The workstation store (15 min).** Fetch and test-merge `origin/main` into `self-hosting-bookmarks`. On a `values.age` conflict, follow the base plan's "A conflict in `values.age`" rule and check all five hashes. Mark its PR ready. After the merge, run `sync.sh --local`, then remove `/run/user/1000/self-hosting/secrets-bookmarks`. *Acceptance*: `~/.local/secrets` holds the five names, with hashes equal to the store's; the overlay is gone.

**Path**: B1 45, then the B2 and B4 pair at 50, then B3 40, then B5 25, then B6 15, plus close 55: 230 minutes.

## Standing answers

| Situation | Answer |
|---|---|
| A member hasn't synced yet, so their directory is empty | The counts and the ciphertext check pass on an empty directory. B2's acceptance waits only on Geoff's file. |
| `bookmarks.xbel` is plaintext on orpheus | A finding, never a fix the session makes: the file is the member's data. Name the member in the PR body by neutral id, and the runbook's setup step is the remedy. |
| Pass 5's merge reshaped a file this plan names by line | Follow the function, not the line number, and record it under `## Decisions`. |
| A heartbeat field change would break a running server's post | The Worker accepts a heartbeat without `webdav_ok` (ward's), and only orpheus sends it. |

Stops: the path ceiling (twice 230), a deletion of member data, a secret only Geoff has, a design change.

## Close

The adapter facts in the base plan's "Adapter facts for the servers repo" stand. One whole-branch `diff-reviewer` runs, then the close checklist, and one packet goes to Geoff through `conductor-servers`. It carries both PRs, the drill result, and the score.
