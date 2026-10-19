# Pass 2 (media server): pre-flight

Every step in Pass 2 that only Geoff or a household member can take. The "Before launch" items run in one sitting right after Geoff approves, and `servers-media` launches only once each is done and its check passes. The rest needs the pass's output, so it waits for one named sitting, "The media sitting", at M8. Commit this file beside the launch prompt as `self-hosting/plans/2026-10-19-pass2-preflight.md`, because the prompt names that path.

## Before launch

### 1. [you: the GitHub sign-in app for Access]

M4's `ssh-media.907.life` application admits a GitHub identity, and Access has no GitHub identity provider today: `bash scripts/dry-run.sh access-github-idp` read `FAIL Access has no GitHub identity provider` on 2026-10-19. This is the GitHub part of Pass 0's step 0.9. The Spamhaus key and the two test accounts aren't needed until the mail passes.

1. Geoff, at github.com: Settings, then Developer settings, then OAuth Apps, then New OAuth App.
   - Application name: `Wright Family Access`
   - Homepage URL: `https://907wrights.cloudflareaccess.com`
   - Authorization callback URL: `https://907wrights.cloudflareaccess.com/cdn-cgi/access/callback`
   - Register the application, click "Generate a new client secret", and keep the page open.
2. Claude (the conductor) cuts a short-lived workstation worktree and starts two dialogs, one at a time. Geoff pastes the Client ID into the first dialog and the client secret into the second.
   ```
   git -C /var/home/glw907/.dotfiles fetch origin
   git -C /var/home/glw907/.dotfiles worktree add .claude/worktrees/self-hosting-access-idp -b self-hosting-access-idp origin/main
   secret-receive ACCESS_GITHUB_CLIENT_ID --hint "GitHub OAuth app: Client ID" --values /var/home/glw907/.dotfiles/.claude/worktrees/self-hosting-access-idp/secrets/values.age --local /run/user/1000/self-hosting/secrets-access-idp
   secret-receive ACCESS_GITHUB_CLIENT_SECRET --hint "GitHub OAuth app: client secret" --values /var/home/glw907/.dotfiles/.claude/worktrees/self-hosting-access-idp/secrets/values.age --local /run/user/1000/self-hosting/secrets-access-idp
   ```
3. Claude decrypts the store back and compares hashes, adds both names to the workstation `secrets/registry.md` and the servers repo's `secrets/registry.md`, runs the privacy check, commits, pushes, and opens a draft PR. That PR is not merged in the sitting: it rides in Pass 2's close packet beside the pass's own workstation PR, and the overlay `/run/user/1000/self-hosting/secrets-access-idp` stays until it merges.
4. Claude adds the provider with `CF_ZT_TOKEN`, since `ws-servers` has no identity-provider scope (the estate inventory says to use `CF_ZT_TOKEN` for anything that touches Access identity providers): `POST /accounts/<id>/access/identity_providers` with `{"name": "GitHub", "type": "github", "config": {"client_id": …, "client_secret": …}}`, with the values read from the overlay `/run/user/1000/self-hosting/secrets-access-idp` and never printed.
5. Geoff, in the Zero Trust dashboard: open the GitHub login method and click Test, then sign in to GitHub when asked.

**Check:** a `GET` of `/accounts/<id>/access/identity_providers` with `CF_ZT_TOKEN` lists one row of `type: github`; Geoff's test page reports success with his GitHub identity; both names are present in the overlay and the draft PR's store (checked by name only). `bash scripts/dry-run.sh access-github-idp` should then pass. If it still fails, the likely cause is that `ws-servers` can't read the provider list (the estate inventory's 2026-10-10 note about an empty list). That is a defect in the dry run to log, and it doesn't block the launch.

### 2. [you: confirm the `Servers emergency` vault]

M8 stages the media server's emergency values for this vault. STATUS records only the `Workstation` vault from the 2026-10-19 key session, so the emergency vault may not exist yet.

1. In his own terminal, Geoff runs `pass-count --hashes` and signs in to Proton Pass in the browser when it asks.
2. If it prints `pass-count: no vault named Servers emergency to hash`, open pass.proton.me, create a vault named exactly `Servers emergency` (capital S, one space, lower-case e), and run `pass-count --hashes` again.
3. Don't share the vault yet. The second operator has no Proton account, so sharing stays owed.

**Check:** `pass-count --hashes` exits 0. An empty vault prints no lines, and an existing one prints one `<title><TAB><sha256>` line per item. Geoff reports the exit status, and Claude never runs the command.

### 3. [you: book the phone for the media sitting]

Geoff has no smartphone, so the M5 phone check needs a household member's phone. Geoff picks the member and a window of about 30 minutes, likely two to three days after launch, once M7 has closed. The phone needs the Immich app (iPhone or Android), the member's own Immich password, mobile data, and a video of at least 150 MB on it. A one-minute 4K clip is about that size, and the member can record one at the sitting.

**Check:** the member and the window are in STATUS.

### The conductor's own pre-launch checks (not Geoff)

- The pass-core "Execute" checks on `/var/home/glw907/Projects/servers`: fetched, on `main`, and `git rev-list --count HEAD..origin/main` prints 0.
- `git -C /var/home/glw907/.dotfiles diff --quiet -- secrets/values.age` is clean. It was clean on 2026-10-19.
- `bash scripts/dry-run.sh hcloud cf-ws-servers r2-media-rw r2-backups-ro pikapods-sftp immich-api fastmail-imap access-github-idp` passes.
- `monitor-subscribe` is running on pavilion: `systemctl --user is-active monitor-subscribe.service` prints `active`. It did on 2026-10-19, and the `secrets-foundation` overlay is gone, so STATUS's "step 2 on pavilion" owed line looks done; confirm and close it in the hand-over.
- The `pavilion-scripts` agent token expires 2027-01-19, well past the pass's end, so the token-expiry standing answer doesn't fire.

## Secrets Pass 2 needs

Names were checked on 2026-10-19 against the workstation `secrets/registry.md` and `~/.local/secrets`, by name only.

| Name | State | Task |
|---|---|---|
| `HCLOUD_TOKEN_SERVERS` | present | M1, M4, M7 |
| `CF_WS_SERVERS_TOKEN` | present | M4 (`access.sh`, `dns.sh`), M8 (`deploy.sh`) |
| `CF_ZT_TOKEN` | present | Pre-flight item 1 (the identity provider) |
| `CLOUDFLARE_API_TOKEN` (`ws-admin`) | present | M8: creates and deletes `servers-scratch-stale`, since `ws-servers` has no R2 scope |
| `CF_MEDIA_R2_BACKUP_RW_TOKEN`, `_KEY_ID`, `_SECRET` | present | M6, rendered to media |
| `CF_WS_R2_BACKUPS_RO_TOKEN`, `_KEY_ID`, `_SECRET` | present | M7 drill; staged for the emergency vault in M8 |
| `HEARTBEAT_TOKEN_MEDIA` | present | M3 health timer, M8 |
| `MONITOR_READ_TOKEN` | present | M8 (`monitor-subscribe` reads it) |
| `PIKAPODS_SFTP_HOST`, `_USER`, `_PASSWORD` | present | M5 `pod-pull.sh` |
| `IMMICH_PIKAPODS_API_KEY` | present | M5 dump download and statistics |
| `FASTMAIL_DAV_PASSWORD` | present | M5's SMTP check, only if the restored Immich config carries no working SMTP credential (see below) |
| `ACCESS_GITHUB_CLIENT_ID`, `ACCESS_GITHUB_CLIENT_SECRET` | **from Geoff**, item 1 | M4 |
| The tunnel token for media | generated in M4 | Rendered to media |
| Media's restic password | generated in M6 | Stored and pushed before `restic init` |
| Immich's database password, if the role sets one | generated in M3 or M5 | Rendered to media |

Item 1 brings in the only values that must come from Geoff. The pass generates the rest into its own worktree and overlay.

## Steps that need the pass's output

What moved, or now runs without Geoff:

- The GitHub identity provider and the vault check are done before launch (items 1 and 2), not in the pass.
- The 150 MB upload: the executor proves it against `photos-new.907.life` with the Immich CLI from pavilion before the sitting, so the phone step only proves the mobile client.
- No step depends on Geoff reporting a result. The executor reads the evidence for each step itself: the media server's journal and the Access audit log for the terminal, the Immich API for the phone's upload, and a hash file for the vault copy.

What stays goes into one sitting.

## The media sitting

**When:** after M7's drill closes and M8's emergency values are staged. The executor writes `## Stop: the media sitting` in its servers PR body with these steps and the staged file's path, then goes on with M8's monitor steps. The conductor brings the stop to Geoff for the window booked in item 3. **Who:** Geoff, plus the household member with the phone for S2. **How long:** about 30 minutes.

### S1. [you: open the media server's browser terminal] (M4)

1. In Chromium, open `https://ssh-media.907.life`, choose GitHub, and sign in.
2. In the terminal that opens, run `sudo -n true`. It prints nothing.
3. Run `exit` and close the tab.

**Check (the executor):** the media server's journal shows a certificate login for Geoff's account and a `sudo` entry for `true` at the sitting's time, and the Access audit log shows Geoff's GitHub identity allowed on `ssh-media.907.life`.

### S2. [household member: photos-new on a phone] (M5)

1. In the Immich app, turn backup off, then sign out.
2. At the sign-in screen, set the server URL to `https://photos-new.907.life` and sign in with the member's own Immich email and password.
3. Check that the timeline shows the member's photos up to the rehearsal's dump date.
4. Turn Wi-Fi off. Pick a video of at least 150 MB, or record a one-minute 4K clip, and upload that one item from the app. Wait for the upload to finish.
5. Sign out, set the server URL back to `https://photos.907.life`, sign in, and turn backup back on.

The rehearsal server is wiped at I1, so the test video never reaches the household's library from there. It is still on the phone, and normal backup to `photos.907.life` takes it.

**Check (the executor):** the Immich API on `photos-new` lists an asset of at least 150 MB for that member, created during the sitting, and the stored original's checksum matches the asset's recorded checksum.

### S3. [you: copy the emergency values] (M8)

The staged file holds one `TITLE<TAB>VALUE` line per value. Expect media's restic password, the read-only restore token's key ID and secret, and the Immich admin login. The second operator's console password stays owed until he has an account.

1. In his own terminal, Geoff runs `cat <the path in the stop>`.
2. For each line, he creates a Login item in the `Servers emergency` vault titled exactly `TITLE`, with `VALUE` pasted into the password field and nothing else in it.
3. He runs `pass-count --hashes > /dev/shm/servers-emergency-hashes.txt` and signs in when asked.

**Check (the executor):** every staged title appears in the hash file with the SHA-256 of its staged value. On a mismatch, the executor names the title in the PR body and Geoff pastes that one again. When every hash matches, the executor removes the staged file and the hash file.

## Owed, outside this pass

None of these blocks Pass 2's close. Each stays in STATUS.

- The second operator's GitHub username and email. When they arrive, his identity joins the Access policy, and his Unix account and `privacy/patterns.txt` lines follow. Then come his first Access sign-in, his read access to the servers repo (deferred from F1), his console password in the emergency vault, and sharing `Servers emergency` with him once he has a Proton account.
- thinkpad-x1's F6b and F6c.
