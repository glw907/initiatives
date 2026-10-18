# Self-hosting: STATUS

Plan: `self-hosting/plans/2026-10-17-self-hosting-plan.md`. Design: `self-hosting/specs/2026-10-17-self-hosting-design.md`. Until `conductor-servers` launches, the Pass 0 session is this file's only writer; from then on, the conductor is.

## Current state

Planned, and nothing is built. Geoff approved the design and the pass plan on 2026-10-17. The plan merged in glw907/initiatives#10 as `c5f91d4`. No servers repo, account, token, or server exists yet.

Rulings at plan approval (Geoff, 2026-10-17, plan packet), each the recommended answer:
1. Claude tests the household members' mailboxes in C3, reading only its own test messages' headers.
2. The line is 3,515 path minutes and the ceiling 5,273. A task past twice its estimate extends once to four times, then stops.
3. Geoff turns a production server's protection off for Claude's rebuilds and the L6 image restore. The second operator's emergency screen tells him to turn it off, restore, and turn it back on.

Rulings during Pass 0 (Geoff, 2026-10-18):
- Geoff migrates to Proton first; the other household members follow only after his migration and once the new system is up. The Family and Emergency Access invites, and members A, B, and C's asks, wait for that.
- Chromium becomes Geoff's daily browser as part of his Proton move. Pass W lands it: CLAUDE.md's "Browsers" line changes when the switch happens, and W3 decides how Claude's browser automation, which also drives Chromium, stays out of the profile that holds an unlocked Proton Pass (likely a separate Chromium profile, with the extension installed per profile rather than by a browser-wide policy).

## Next action

Geoff sits for Pass 0 with Claude, on whichever host he is at. Start it from the workstation checkout:

```
cd ~/.dotfiles && claude --model sonnet --effort medium --name workstation-self-hosting-pass0 "$(cat ~/Projects/initiatives/self-hosting/plans/2026-10-17-pass0-prompt.txt)"
```

The order and the port 25 request text are in `2026-10-17-pass0-checklist.md`. The port 25 request goes first among Geoff's steps, because mail waits on Hetzner's answer.

## Resume note (2026-10-18, second sitting)

Geoff continues Pass 0 in a fresh session with the launch prompt above, unchanged. State to pick up:

- Stored in workstation PR #88 (draft, branch `self-hosting-pass0`, worktree `~/.dotfiles/.claude/worktrees/self-hosting-pass0`): `HCLOUD_TOKEN_SERVERS`, the five Cloudflare tokens and their R2 S3 pairs, and the PikaPods SFTP host, user, and password. Store with `VALUES=<that worktree>/secrets/values.age`. The branch is behind workstation `main`; merge `origin/main` and resolve `values.age` by re-encrypting, never by taking one side, before the hand-over.
- The servers branch `pass0-patterns` (worktree `~/Projects/servers/.claude/worktrees/pass0-privacy`) adds two private patterns and is unmerged; run the privacy check with `PRIVACY_PATTERNS` pointing at its `privacy/patterns.txt` until it lands.
- This branch (`self-hosting-pass0-status`) merges `origin/main` before the hand-over PR.
- Next is 0.9, waiting on Geoff: the GitHub OAuth app `servers-access` (homepage `https://907.life`, callback in the 0.9 row), the Spamhaus DQS key, and the Gmail and Outlook.com test accounts. Each value arrives through `secret-receive`; then Claude adds the GitHub identity provider with `CF_ZT_TOKEN` and Geoff signs in once through Access. Then 0.10, 0.11 (waits on 0.6), and 0.12.
- Workstation change landed the same sitting (workstation#93, merged): Firefox and Thunderbird retired, Chromium daily in Geoff's own profile (`Geoff`), Claude's browser extension alone in `Default`, Proton Pass alone in Geoff's profile, both installed by hand, and Kagi set by Chromium policy. Hylki is the mail client, with GNOME Contacts and Calendar through Online Accounts. Pass W's W3 takes this as given: no browser-wide extension policy, and no 1Password extension anywhere. Firefox's RPM leaves at the next reboot; backups are in `~/.local/state/browser-mail-retire-2026-10-18/`.
- Retire the old session before launching: the Pass 0 session `009a2597` on pavilion holds the worktrees above and ends at this hand-over.

## Pass 0 rows

| Step | State |
|---|---|
| 0.0 Servers repo | done 2026-10-17: `glw907/servers` private, README and PR #1 (privacy check, patterns, empty registry) merged |
| 0.1 Port 25 | done 2026-10-17: filed and validated automatically; Hetzner unblocks ports 25 and 465 on all the account's Cloud Servers within minutes. No 14-day wait, so Pass 5's port 25 entry condition is met and the daily JMAP check and the options-packet standing answer are moot |
| 0.2 Recovery | done 2026-10-18: Cloudflare done 2026-10-18 (recovery address off 907.life). Hetzner done 2026-10-18: login, main contact, and invoice addresses all moved off 907.life, so a mail outage on the Hetzner server can't lock Geoff out of the account that rebuilds it. Geoff ruled 2026-10-18 that one general recovery address, off 907.life, serves every account, so no per-account address is asked for. GitHub done 2026-10-18 (a verified address off 907.life receives resets). 2FA backup codes for Cloudflare, Hetzner, and GitHub stored offline 2026-10-18. Fastmail done 2026-10-18 (recovery address set off 907.life). Fastmail's 2FA backup codes are in the offline set too. Proton takes the address as its recovery address in 0.6 |
| 0.3 Tools | done 2026-10-17: `hcloud` 1.70.1, `shfmt` 3.14.1, `yamllint` 1.38.0, `imapsync` 2.314, `proton-pass-cli` 2.4.2 (pinned) installed and in the Brewfile (workstation PR #88). `pass-cli` is homebrew-core's `proton-pass-cli`, not a Proton tap, and its version was read from brew, never by running it. `check-drift` is clean once the PR merges |
| 0.4 Hetzner | token done 2026-10-17: `HCLOUD_TOKEN_SERVERS` stored (workstation PR #88, draft); empty server list and SSH key create/delete pass. Deferred by Geoff 2026-10-18: the second operator's project invite waits until he has his accounts set up (0.8 asks for his GitHub account) |
| 0.5 Cloudflare | done 2026-10-18. Buckets created 2026-10-17: `servers-backup-mail`, `servers-backup-media`, `servers-archive`, empty, no lock rules. Geoff ruled 2026-10-18 that tokens follow the workstation API token scheme (`~/.claude/docs/cloudflare-estate-inventory.md`, workstation branch `cf-token-scheme`), which replaces the plan's eight tokens with five: `ws-servers` (DNS, Workers, Access and Tunnel in one), `ws-r2-archive-rw`, `ws-r2-backups-ro` (one restore token for both buckets), `mail-r2-backup-rw`, `media-r2-backup-rw`. Scopes and readers are in the servers repo's `docs/runbook.md` and `secrets/registry.md` (branch `pass0-tokens`). Done 2026-10-18: Claude minted the five as account-owned tokens through the API with Geoff's two temporary token-management tokens, stored each (and each R2 S3 pair) in workstation PR #88, and confirmed the pushed store decrypts to the same hashes. Smoke tests pass: each R2 token lists its own bucket and is refused another, the restore token reads both, and `ws-servers` reads 907.life DNS and is refused another zone's DNS and R2. `ws-servers` carries Workers Admin, since its scripts create and delete Workers. Both temporary tokens are deleted and verified refused. Estate cleanup the same day: three tokens renamed to the scheme, and the dead musicbox R2 write token on `music-library` deleted on Geoff's go |
| 0.6 Proton | deferred by Geoff 2026-10-18 until the rest of the setup is in place; the Family and Emergency Access invites follow his own account setup. 0.11's recovery kit waits on it (the Proton phrase) |
| 0.7 PikaPods and Fastmail | done 2026-10-18. SFTP done 2026-10-18: credentials stored (workstation PR #88), and the listing shows the six directories the design names under `photos/`, the newest backup from 2026-10-17. Fastmail: Geoff ruled 2026-10-18 to reuse the existing `FASTMAIL_DAV_PASSWORD` (an app password covering IMAP, SMTP, CalDAV, CardDAV) for the migration instead of two new app passwords; the address list comes from the existing `FASTMAIL_API_TOKEN`. The Immich API key stored 2026-10-17 (`IMMICH_PIKAPODS_API_KEY`) is an admin key and reaches the database-backup endpoint, so no new key was made; Geoff may delete an unused January key. The pod's admin login stays as it is (Geoff). The confirmed address list is committed in the servers repo's `docs/addresses.md`: four user mailboxes and one alias; two unused identities dropped; the site's send-only From address recorded for the DNS cutover |
| 0.8 Household | in progress. Geoff sent the second operator's message 2026-10-18 (Fastmail API token and one app password, GitHub username and email, ntfy app, Proton account, masked addresses). Owed from him: each of those; his Fastmail credentials arrive in an attended sitting through `secret-receive`. Geoff deferred household members A, B, and C on 2026-10-18 until the new system is up and ready, so their Fastmail credentials and the Proton note wait; the Fastmail admin-credential check waits with them |
| 0.9 Access and test accounts | in progress. The account's one Zero Trust organization was the sailing club's; on Geoff's go 2026-10-18 Claude renamed it "Wright Family" and moved its team domain to `907wrights.cloudflareaccess.com` (every other setting read back unchanged). The GitHub OAuth callback is `https://907wrights.cloudflareaccess.com/cdn-cgi/access/callback`. The club's Google sign-in fails until that callback is added to its Google OAuth client; Geoff deferred the fix 2026-10-18, since he is its only user. Open: Geoff creates the GitHub OAuth app, the Spamhaus DQS key, and the Gmail and Outlook.com test accounts; Claude stores each and adds the GitHub identity provider |
| 0.10 Permissions PR | not started |
| 0.11 Recovery kit | not started |
| 0.12 Dry run | not started |

## Owed

- Musicbox: Geoff deleted the musicbox Hetzner project on 2026-10-17, before I3. The server, its 50 GB volume, and its old token are gone (token removed from the store in PR #88). Pass 3 I3 can no longer copy `/srv/music/library` or `/var/lib/dubplate` from it; the only possible copy is the R2 bucket `music-library`, whose contents I3 was already to read. The next plan revision rewrites I3, I4's musicbox packet, and the dubplate host-contract rows. Until then dubplate has no host.
- Design errata: the plan's fold record (`research/2026-10-17-self-hosting-plan-fold.md`) lists eleven for the next design revision. Ruling 3 settled items 7 and 11, so none waits on Geoff. Until that revision, the plan governs where the record names an erratum.
- thinkpad-x1 per-host steps: the servers repo clone, the ntfy subscriber, the agent token, and the W5 key check. Each is open until done on that host.
- Human steps: every row in the plan's "Human steps" table is open.
- Plan amendments from the 2026-10-18 token ruling, for the next plan revision: 0.5's token list becomes the five above; 0.12's dry run proves `ws-servers` once per job (a DNS write and a refused write on another zone, the probe Worker, a test tunnel), and the one restore token reads both buckets and is refused a write on each; the close checklist's "`servers-` name prefix (Cloudflare)" holds for buckets and Workers, and tokens are checked against the runbook's credentials table instead.
- Plan amendment from the 2026-10-18 Fastmail ruling: 0.7 creates no Fastmail app passwords, and 0.8's ask to household members A and B shrinks to one app password covering IMAP and DAV plus the API token.
- Fastmail login rename: JMAP shows Geoff's Fastmail login is an @907.life address, so per the design's "Irreversible steps" the Fastmail packet renames it before 907.life is removed from the account.
- Members A and B's Fastmail credentials (deferred 2026-10-18): the migration rehearsals for their mailboxes, and their 0.12 dry-run rows, wait until Geoff asks them.
- Estate-wide follow-up, outside this initiative: the `ci-deploy` token for the five site repos and Workers Builds, and retiring `CF_ZT_TOKEN`, per the scheme's table.

## Open decisions

- Pass W scope (asked 2026-10-18): whether Proton Drive, VPN, or the Mail and Calendar desktop apps join Pass W as one install task. Recommended: none unless Geoff names them; Pass W stays as planned.
- Kagi homepage (asked 2026-10-18): Chromium's policy locks it; Geoff may want it as a changeable default (`HomepageLocation` moves to a recommended policy).

## Sessions

- Planner: session `26c03024` on pavilion. It wrote the plan and this file, and it ends after this hand-over merges.
