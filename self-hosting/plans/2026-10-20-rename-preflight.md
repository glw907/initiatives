# Rename pass (orpheus and ward): pre-flight

Every step in the rename pass that only Geoff can take, and the conductor's own checks before launch. There are two: a temporary Cloudflare token before launch, and one sign-in after the box switch. `servers-rename` launches only once the "Before launch" item is done and its check passes. Commit this file beside the launch prompt as `self-hosting/plans/2026-10-20-rename-preflight.md`, because the prompt names that path.

What needs no step from Geoff: the emergency vault goes through Claude's own Proton Pass agent (`claude-pass`, workstation#114, editor on `Servers emergency`), and the new Access application admits the same GitHub identity, `geoff@907.life`, that Pass 2's sitting proved on `ssh-media.907.life`. The SSH permission rules stay as they are during the pass: the executor reaches orpheus as `geoff@media.907.life`, which resolves to orpheus throughout, and its workstation PR swaps the rules to orpheus and ward for the passes after it.

## Before launch

### 1. [you: a temporary token-management token]

The pass mints `orpheus-r2-backup-rw` and `ward-r2-backup-rw`, re-scopes `ws-r2-backups-ro`, and later deletes `media-r2-backup-rw` and `mail-r2-backup-rw`. No standing token can manage tokens (the estate inventory's token scheme, rule 6, which also says why: `ws-admin` deliberately can't extend itself). All five tokens are account-owned, so only the account-level token is needed.

1. Geoff, at <https://dash.cloudflare.com/?to=/:account/api-tokens&permissionGroupKeys=%5B%7B%22key%22%3A%22account_api_tokens%22%2C%22type%22%3A%22edit%22%7D%5D&name=tmp-account-tokens>: create the token `tmp-account-tokens` with Account API Tokens Edit and nothing else. Set its TTL to start today and end two days after the launch date. Rule 6 says "ending tomorrow"; the pass needs the token at R3 and again at R14, after the backup and the drill, so the window is a day longer. Copy the value and keep the page open.
2. The conductor starts one dialog, and Geoff pastes the value into it:
   ```
   secret-receive CF_TMP_ACCOUNT_TOKENS_TOKEN --hint "Cloudflare tmp-account-tokens value" --values /dev/shm/tmp-setup-1000.age --local /run/user/1000/self-hosting/secrets-tmp-setup
   ```
   The value stays in the RAM-only scratch store and its overlay, which the servers loader reads, and never enters the age store or a commit.

**Check (the conductor, before launch):** with the value read from the overlay and never printed, and the account id from the servers repo's `infra/project.env`:
- `GET /accounts/<id>/tokens/verify` answers `"status": "active"`. A `9109 Invalid access token` here means the TTL's start date is wrong (the inventory's 2026-10-18 note); Geoff corrects it.
- `GET /accounts/<id>/tokens?per_page=50` succeeds and lists `media-r2-backup-rw`, `mail-r2-backup-rw`, and `ws-r2-backups-ro`.
- `GET /accounts/<id>/tokens/permission_groups` succeeds.

### The conductor's own pre-launch checks (not Geoff)

- Pass 2 has merged: glw907/servers#5 with workstation#109 and #110, and pavilion has run `sync.sh --local`. The `secrets-media` and `secrets-access-idp` overlays are gone, so the names they held now come from `~/.local/secrets`. workstation#113 (an executor takes its conductor's messages) and #114 (`claude-pass`) have merged and been stowed.
- The pass-core "Execute" checks on `/var/home/glw907/Projects/servers`: fetched, on `main`, and `git rev-list --count HEAD..origin/main` prints 0. The same for `/var/home/glw907/Projects/initiatives`, where `test -f` passes on the plan, this file, and the prompt under `self-hosting/plans/`, since the executor reads them from that checkout.
- A live inventory, by name only, matches what the plan expects to find: `hcloud server`, `primary-ip`, `firewall`, `image` (snapshots, with labels), and `ssh-key` lists show `media`, `media-ipv4`, `media-ipv6`, and `firewall-media`, and no `orpheus`, `ward`, `mail`, `mail-ipv4`, or `firewall-mail`; Cloudflare lists one tunnel `servers-media`, one Access application `ssh-media.907.life`, the DNS rows in the servers repo's `cloudflare/dns/media`, the Worker secrets `MONITOR_READ_TOKEN`, `HEARTBEAT_TOKEN_MAIL`, and `HEARTBEAT_TOKEN_MEDIA`, the R2 buckets `servers-backup-media`, `servers-backup-mail`, and `servers-archive`, and no account token named for orpheus or ward (item 1's list); and the monitor's D1 `kv` keys matching `%media%` are at most the two R10 deletes, while those matching `%mail%` are service keys such as `findings:mailbox`. Anything else is a finding to resolve before launch.
- `git -C /var/home/glw907/.dotfiles diff --quiet -- secrets/values.age` is clean.
- Neither old backup bucket carries a lock rule (`bash cloudflare/r2.sh --check` reports both disabled, and a `GET` of each bucket's lock configuration lists no rules), and Pass 3 has not launched. Pass 3's I1 locks the media bucket, after which it could never be deleted.
- `bash scripts/dry-run.sh hcloud cf-ws-servers r2-media-rw r2-mail-rw r2-backups-ro access-github-idp` passes.
- `claude-pass --status` prints `path=proton`, and `claude-pass vault list` (with a reason) lists `Servers emergency`.
- `systemctl --user is-active monitor-subscribe.service` prints `active`, and the monitor's `/alerts` lists no open condition for media, so any condition during the switch belongs to the pass.
- `ssh -o BatchMode=yes geoff@media.907.life true` exits 0, which proves the `known_hosts` entry and the allow rule the executor starts from.
- The `pavilion-scripts` and `pavilion-claude` agent tokens expire in January 2027, well past the pass's end, so the token-expiry standing answer doesn't fire.

## Secrets the pass needs

Names checked on 2026-10-20 against the workstation `secrets/registry.md` and the Pass 2 branch, by name only.

| Name | State | Task |
|---|---|---|
| `HCLOUD_TOKEN_SERVERS` | present | R5, R8 |
| `CF_WS_SERVERS_TOKEN` | present | R4, R5, R6, R7, R10, R11, R12 (`deploy.sh`, `dns.sh`, `access.sh`, Worker secrets, D1) |
| `CLOUDFLARE_API_TOKEN` (`ws-admin`) | present | R3 (bucket create and config), R13 (bucket delete) |
| `CF_TMP_ACCOUNT_TOKENS_TOKEN` | **from Geoff**, item 1 | R3, R14 |
| `CF_MEDIA_R2_BACKUP_RW_*`, `CF_MAIL_R2_BACKUP_RW_*` | present | R3 (policies copied), R13 (old bucket emptied); deleted in R15 |
| `CF_WS_R2_BACKUPS_RO_*` | present | R8 drill, R9 vault read-back; re-scoped in place |
| `RESTIC_PASSWORD_MEDIA`, `TUNNEL_TOKEN_MEDIA`, `HEARTBEAT_TOKEN_MEDIA`, `HEARTBEAT_TOKEN_MAIL` | present after Pass 2's merge | the transition; deleted in R15 |
| `MONITOR_READ_TOKEN` | present | R4 to R10 (`deploy.sh` puts it; `/alerts` reads) |
| `IMMICH_DB_PASSWORD`, `IMMICH_PIKAPODS_API_KEY` | present | R7's render, unchanged |
| `CF_ORPHEUS_R2_BACKUP_RW_*`, `CF_WARD_R2_BACKUP_RW_*` | minted in R3 | rendered to orpheus; ward's waits for Pass 5 |
| `RESTIC_PASSWORD_ORPHEUS`, `HEARTBEAT_TOKEN_ORPHEUS`, `HEARTBEAT_TOKEN_WARD` | generated in R3 | R7, R4 |
| `TUNNEL_TOKEN_ORPHEUS` | created in R6 | R7 |

Item 1 brings in the only value that must come from Geoff.

## The orpheus sitting

**When:** after R7's box switch passes its checks. The executor writes `## Stop: the orpheus sitting` in its servers PR body and goes on with the backup drill and the other tasks; the conductor brings the stop to Geoff. **Who:** Geoff. **How long:** about 5 minutes.

The identity part is dry-run already: the GitHub identity provider passes `dry-run.sh access-github-idp` (a pre-launch check above), and the new application copies the old one's policy, which Geoff's own sign-in proved in Pass 2's sitting.

### S1. [you: open orpheus's browser terminal] (R7, R11)

1. In Chromium, open `https://ssh-orpheus.907.life`, choose GitHub, and sign in.
2. In the terminal that opens, run `sudo -n true`. It prints nothing.
3. Run `exit` and close the tab.

**Check (the executor):** orpheus's journal shows a certificate login for `geoff`, signed by the new application's CA, and a `sudo` entry for `true` at the sitting's time, and the Access audit log shows Geoff's GitHub identity allowed on `ssh-orpheus.907.life`. Until both show, the old tunnel and its application stay up.

## Owed, outside this pass

- The Immich admin login for the emergency vault (Geoff's own step, carried from Pass 2).
- The second operator's identity, account, and first sign-in, now on `ssh-orpheus.907.life`.
- thinkpad-x1's `sync.sh --local` and stow at its next pull, so its store and rules match.
