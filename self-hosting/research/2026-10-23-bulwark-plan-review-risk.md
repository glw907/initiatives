# Bulwark plan review: data integrity and failure risk

Target: `self-hosting/plans/2026-10-23-bulwark-plan.md` at `2bb9672`, read against the approved design
`self-hosting/specs/2026-10-21-bulwark-design.md`, the base plan's "Secrets in the age store", the servers
repo at `e036a70`, Bulwark 1.17.1 source, and Stalwart v0.16.27 source (`crates/http`, `crates/common`,
`crates/registry`). Live probes were read-only and carried no credentials.

Counts: 0 blocker, 4 major, 11 minor. Four findings are OWNER FORKs.

## Verified as the plan states

- `Http.usePermissiveCors` pushes `Access-Control-Allow-Origin: *`, allow-headers
  `Authorization, Content-Type, Accept, X-Requested-With`, and the method list, and nothing for
  credentials (Stalwart `crates/common/src/config/network.rs:403-427`). The headers are inserted on
  every response after it is built, error responses included (`crates/http/src/request.rs:869-875`).
  Bulwark's browser sends only `Authorization` and JSON, so the fixed list covers it.
- Probed: an `OPTIONS` preflight with `Origin: https://webmail.907.life` to `/jmap/session`,
  `/.well-known/jmap`, `/jmap/`, `/jmap/eventsource/`, `/jmap/upload/x/`, and `/jmap/download/a/b/c`
  on ward each answer 204 with no CORS header today. `/api/account` answers 404 on the public listener.
- `Http.useXForwarded` is global: when on, every connection's `Forwarded` or `X-Forwarded-For` sets
  the address (`request.rs:749-801`). Rejecting it is correct.
- `AllowedIp` short-circuits the auth, recipient, scan, loiter, and banned-path checks
  (`crates/common/src/network/security.rs:220-310`) and the HTTP rate limits
  (`crates/common/src/auth/rate_limit.rs:22, 70`).
- Bulwark's login budget is 5 failures per 15 minutes per client key with no global ceiling
  (`lib/auth/verify-budget.ts:16-17, 115`), held in process memory.
- With `JMAP_SERVER_URL` set, Bulwark is in the `env-managed` state and the setup wizard is off
  (`lib/setup/state.ts:23-34`). Migrations skip a read-only config dir (`lib/admin/migrate.ts:40, 79`).
- The image runs as uid 1001, `nextjs` (Bulwark `Dockerfile:51, 56`).
- Orpheus's addresses are Hetzner Primary IPs with delete protection, kept across a rebuild
  (`infra/provision.sh:14-21`), so the allowlist does not drift on a rebuild.

## Findings, ranked by consequence

### R1. The live changes have no back-out, and two of them cannot be backed out by deleting lines (major, correctness)

*Location*: plan:56-62 (T5), plan:74-80 (After merge), plan:86-97 (Standing answers).

*Defect*: T5 changes production before the owner approves the PR. It changes ward's Stalwart plan,
restarts Stalwart, adds DNS, starts Bulwark, and T8 deploys the monitor. The backlog-2 plan, the
nearest precedent, ran no `--apply` before approval (`2026-10-22-backlog-2-plan.md:15`). This plan
names no reversal if the owner rejects or reshapes the PR, and the obvious reversal does not work.
Deleting the plan lines leaves both ward changes in place. `AllowedIp` objects go in by `upsert`,
and the plan removes objects only through explicit `destroy` lines, as it already does for the
`pop3s` and `sieve` listeners (`roles/stalwart/plan.ndjson:3-4`). `Http` changes go in by `update`,
which merges, so `usePermissiveCors` stays true once the key is gone from line 13. The monitor would
keep probing a removed service and alerting on it.

*Fold*: add a `## Back out` section the conductor runs on a rejection. On ward, the plan carries
`"usePermissiveCors": false` explicitly and a `destroy` line for each `AllowedIp` address, then
`apply.sh ward --apply` (one restart). Add `webmail absent` to `cloudflare/dns/orpheus`, then
`dns.sh --apply`. Remove the `webmail.907.life` site from Caddy. Run `systemctl disable --now
bulwark.service` and delete `/etc/bulwark`. Redeploy the monitor from `main`. T4's test asserts that
the back-out lines produce a plan with neither the switch nor the addresses (a fixture-plan diff).
About 10 minutes in T4 and T7.

### R2. The live steps can apply someone else's unreviewed or reverted state (major, correctness)

*Location*: plan:20 (Entry), plan:56 (T5's order), plan:68 (T8's deploy).

*Defect*: Entry checks that `servers-backlog-2` has merged, not that its own After-merge applies
have run. Backlog-2's conductor applies orpheus and ward after approval
(`2026-10-22-backlog-2-plan.md:174`). If those applies have not run, T5's `apply.sh orpheus --apply`
and `ward --apply` land backlog-2's changes as a side effect, outside that pass's checks. The reverse
case is a stale branch. `dns.sh --apply` replaces the whole record set of every name and type any
file declares (`cloudflare/dns.sh:11-13`). A branch cut before a later `main` change to `mx`, `m`, or
`ward` would revert mail DNS. The ward plan and the monitor Worker behave the same way. The window
also runs past T5. Until the owner merges, ward and orpheus run branch `bulwark`. Any later `--apply`
from `main` by another session removes the webmail Caddy site and leaves Bulwark orphaned behind no
proxy.

*Fold*: (1) Entry adds `scripts/apply.sh orpheus --check` and `scripts/apply.sh ward --check` from
`main`, each with nothing to converge, and `cloudflare/dns.sh --check` clean. (2) T5 runs
`git fetch && git merge --ff-only origin/main` (or a rebase before the first push) immediately
before the live steps. Each `--check` may list only the pass's own changes: the `webmail` CNAME, the
two `Http` and `AllowedIp` rows, the bulwark role, and the Caddy site. Any other row stops the pass.
T8's deploy gets the same rule. (3) T9's `## STATUS lines` records "orpheus, ward, DNS, and the
monitor run branch `bulwark` until merge; no `--apply` from `main` until then", so the conductor holds
other sessions. About 5 minutes.

### R3. The CORS switch lets any web page get a household's address banned for a day (major, correctness, OWNER FORK)

*Location*: plan:11 (Brief fact 1), plan:54 (T4).

*Defect*: fact 1 says another site "can reach ward only with credentials it already has, as curl
can today". That covers what a hostile page can read, but not whose address it spends. Today a
cross-origin `fetch` carrying an `Authorization` header needs a preflight, and ward's preflight
answers 204 with no `Access-Control-Allow-Origin`. The browser therefore never sends the real
request (probed above). After the switch, any page a household member opens can fire wrong-password
JMAP requests from that member's browser. Stalwart counts each one against the browser's address:
100 failures a day per address or per login by default
(`crates/registry/src/schema/structs_impl.rs:35589-35592`), banned for `authBanPeriod` 86400000 ms,
which is 24 hours (`plan.ndjson:6`). The ban blocks every protocol for that address, so it locks out
every device behind it: phones, mail clients, and the webmail. Stalwart's OAuth token endpoint takes
no password grant (`crates/http/src/auth/oauth/token.rs:69-237`), so this review found no existing
simple-request path that spends the allowance. The switch opens it.

*Options*:
- (a) Accept it. Record it in `## Decisions` and `docs/decisions.md` beside fact 1, and add a line
  to the runbook's "Unban a client from Stalwart's auto-ban" naming this cause. No build cost.
- (b) Accept it and shorten `authBanPeriod`, for example to one hour, so a hostile page costs an
  hour rather than a day. That weakens the ban for every client.
- (c) Avoid browser-direct JMAP by serving ward's JMAP same-origin through Caddy on orpheus. Every
  request then comes from orpheus, which R4's allowlist exempts, so Stalwart's auth ban stops
  applying to webmail traffic. Bulwark has no proxy mode for this (the session URLs are rewritten
  only for its own server, `lib/jmap/client.ts:1387`). It is a design change.

*Recommendation*: (a). The attack needs a targeted page and buys a recoverable day-long outage. The
unban procedure already exists and is on the emergency screens. Fold it as a named, accepted risk,
not a fact that reads as no risk.

### R4. The orpheus allowlist removes the auth limits a recorded decision relies on, for every service on orpheus (major, correctness, OWNER FORK)

*Location*: plan:12 (Brief fact 2), plan:54 (T4); servers `docs/decisions.md:109`.

*Defect*: `is_auth_fail2banned` keys on the address and on the login. For an allowed address it
checks neither and counts nothing (`security.rs:295-310`). It also skips the authenticated HTTP rate
limit (`rate_limit.rs:22`). Two consequences follow, and the plan names neither:
- `docs/decisions.md:109` accepts that the admin account can sign in over public JMAP because "the
  auto-ban and the authenticated rate limit apply". Through Bulwark, neither applies to any account,
  the admin's included. Bulwark's own budget is per exact client address with no global ceiling
  (`verify-budget.ts:115`). Any IPv6 /64 holds 2^64 such addresses, so one attacker gets an unbounded
  rate.
- The exemption covers the address, not Bulwark. Every service on orpheus gets ban-free,
  rate-free password guessing against ward and ban-free RCPT probing: Immich, the webdav instances,
  dubplate, and cloudflared. A compromise of any of them inherits it.

Users can also change their own password through Bulwark's Stalwart passthrough
(`lib/stalwart/jmap-passthrough.ts:49`). Stalwart's minimum strength then becomes the only floor on a
password that has no ban in front of it.

*Options*:
- (a) Keep the allowlist and record the compensating control: generated high-entropy passwords
  (base plan L3) and a raised `Authentication.passwordMinStrength`, set in `plan.ndjson` and checked
  in T4's test. Amend `decisions.md:109` to say the auto-ban no longer covers the webmail path.
- (b) Drop the allowlist and accept that a run of wrong passwords bans orpheus for 24 hours,
  breaking webmail for both users and orpheus's own submission on port 587.
- (c) Narrow the exposure with a custom Caddy build that has a rate limiter. The plan rejected this
  (fact 3), and it would key on addresses the same way.

*Recommendation*: (a), since the passwords are generated. Make the decisions amendment and the
strength floor part of T4, about 10 minutes.

### R5. A session-secret mount that fails is silent, and nothing tests the secret is used (minor, correctness)

*Location*: plan:30 (T1 acceptance), plan:58 (T5 step 2).

*Defect*: Bulwark resolves the secret from the environment, then `SESSION_SECRET_FILE`, then
config. Failing all three, it generates a random one into the state dir
(`lib/auth/session-secret.ts:25-41, 52-67`). `readFileEnv` swallows a read error (`lib/read-file-env.ts`).
So a wrong owner, a wrong path, or a missing mount leaves Bulwark running on a random secret held in
tmpfs. Every restart then signs everyone out, and the rotation steps T7 writes do nothing. T1's
acceptance proves only that the workstation blob decrypts.

*Fold*: T5 step 2 adds two checks. `journalctl` for the container shows no
"Generated a session secret in the admin state dir" line (`instrumentation.node.ts:24-29`). A
sign-in survives `systemctl restart bulwark.service`. About 3 minutes.

### R6. uid 1001 on the host is the next operator account (minor, correctness; also over-ceremony)

*Location*: plan:30 (T1).

*Defect*: `roles/cloudflared/operators.sh:70` creates each operator with a bare
`useradd --create-home`. `base/cloud-init.yaml` creates the admin first, as uid 1000, so the first
operator line in `hosts/orpheus/operators.txt` (empty today) takes uid 1001. The secret file would
then belong to that operator by name, and the next cleanup or `chown` would be done on a misread.
Teaching `render.sh` numeric owners also widens a shared `auth-data` tool, with its own test, for
one row.

*Fold*: the bulwark `install.sh` creates a system user `bulwark` with `--uid 1001 --user-group`,
as the webdav and stalwart roles pin theirs (`roles/webdav/install.sh:52`,
`roles/stalwart/install.sh:56`). It refuses when uid 1001 already belongs to another name. The
`secrets.txt` row names `bulwark`, and `render.sh` stays as it is. The role must run before
`render.sh` can `install -o bulwark`, so `apply.sh` gets a role-first step, or the user moves into
`base/install.sh`. This saves about 15 minutes of T1.

### R7. A missing secret turns its bind-mount source into a directory (minor, correctness)

*Location*: plan:32-34 (T2).

*Defect*: the plan wants the role "safe to rerun" after Immich's pattern, and that pattern runs
`docker compose up -d` from `install.sh` when its gate file exists
(`roles/immich/install.sh:21-25`). A short-syntax bind mount whose source is absent makes Docker
create the source as an empty root-owned directory. The next `render.sh` then fails on
`install ... /etc/bulwark/session-secret`, and every later `apply.sh orpheus --apply` stops there.
Separately, `install` writes a new inode on each render (checked locally). A single-file bind mount
keeps the old inode until the container is recreated, so a rotation applied without the restart
step changes nothing until some later restart.

*Fold*: `install.sh` gates compose on `[ -f /etc/bulwark/session-secret ]`, as Immich does. The
compose file mounts the directory `/etc/bulwark` read-only in long syntax with
`bind: {create_host_path: false}`, and `SESSION_SECRET_FILE` names the file inside it. T2's test
asserts both. About 5 minutes.

### R8. T5's ward apply restarts the production mail server, and the plan does not say so (minor, optional)

*Location*: plan:54 ("If `stalwart-apply` needs a reload"), plan:56.

*Defect*: `stalwart-apply` restarts Stalwart whenever the plan's hash changes
(`roles/stalwart/stalwart-apply:146-150`), so T4's change restarts ward. That costs seconds of
refused SMTP, which senders retry, and dropped IMAP sessions. The script refuses inside 03:20 to
04:00 UTC (`stalwart-apply:44-47`), so a T5 started in that band stops at `roles/stalwart/install.sh
failed`. The conditional in T4 reads as if a restart might not happen.

*Fold*: T4 states that the ward apply restarts Stalwart once. T5 says "not between 03:20 and 04:00
UTC". One line.

### R9. Nothing confirms the allowlisted address is the one ward sees (minor, optional)

*Location*: plan:54, plan:60 (T5 step 4).

*Defect*: T5 step 4 shows only that no ban happened, and two clean sign-ins never approach the
allowance. If Bulwark's container reached ward from an address other than the two in DNS, the
allowlist would miss with no signal. That could be an IPv6 source other than the DNS address, or
Docker's IPv4 masquerade.

*Fold*: after the T5 sign-ins, read ward's journal for the session request's `RemoteIp`
(read-only), mask it, and confirm it equals one allowlisted address. No wrong-password probe is
needed. About 3 minutes.

### R10. Bulwark's defaults send household data to third parties the plan does not name (minor, OWNER FORK)

*Location*: plan:35 (T2 env list).

*Defect*: the design keeps telemetry and settings sync off in a privacy posture. Three more defaults
leave the estate:
- `/api/translate` sends message text to the public MyMemory API unless `LIBRETRANSLATE_URL` is set
  (`.env.example:455-461`). No policy switch turns the feature off.
- Web push registers ward's push subscription at `notifications.relay.bulwarkmail.org`
  (`.env.example:465-470`, `lib/web-push.ts`).
- The update check calls upstream periodically (`BULWARK_UPDATE_CHECK`).

*Options*:
- (a) Set `BULWARK_UPDATE_CHECK=off`, since the monthly review already carries upgrades. Record
  translate and push as accepted, used only when a member clicks.
- (b) Also block translate and the relay at Caddy (`respond /api/translate* 404`) and say so in the
  runbook.

*Recommendation*: (a) with the translate route blocked at Caddy. Mail text leaving to a public
translation API is the one outbound flow a household would not expect.

### R11. Every sign-in is remembered for 30 days with the password inside the cookie (minor, OWNER FORK)

*Location*: plan:35 (T2 env list).

*Defect*: with a session secret set and no "Remember me" box, Bulwark remembers every sign-in
(`.env.example:342-344`). It keeps the mailbox password, AES-GCM encrypted under the session secret
(`lib/auth/crypto.ts:38-50`), in a 30-day cookie (`lib/auth/session-cookie.ts:2`). A sign-in on a
borrowed machine stays live for a month.

*Options*:
- (a) Set `LOGIN_SHOW_REMEMBER_ME=true` so a member chooses.
- (b) Keep the default.

*Recommendation*: (a). It costs one variable.

### R12. Test-mailbox sessions stay in Claude's browser profile (minor, optional)

*Location*: plan:59 (T5 step 3).

*Defect*: under R11's default, T5's two sign-ins leave 30-day cookies holding the test mailboxes'
passwords in Claude's Chromium profile.

*Fold*: T5 signs both test mailboxes out at the end of step 3. One line.

### R13. No memory cap beside Immich's database (minor, optional)

*Location*: plan:33, plan:92 (the `mem_limit` standing answer).

*Defect*: `mem_limit` applies only when free memory reads under 2 GB. A Node leak with no cap
competes with Immich's Postgres for orpheus's memory, and the kernel's OOM killer may pick the
database.

*Fold*: always set `mem_limit: 768m`, matching Immich's ML container (`roles/immich/compose.yaml:39`
caps at 3g). Keep the under-1 GB stop. One line.

### R14. An upgrade with a config migration is skipped silently (minor, optional)

*Location*: plan:66 (T7's upgrade steps).

*Defect*: with a read-only config dir, Bulwark skips its config migrations
(`lib/admin/migrate.ts:40, 79`). A release that migrates `policy.json` or `config.json` runs on the
old shape with no error, which can drop the theme policy without a sign.

*Fold*: the runbook's upgrade step reads the release notes for a migration. On one, it runs the new
image once against a writable copy of `roles/bulwark/config`, diffs, and commits the result before
`apply.sh orpheus --apply`. Two sentences.

### R15. The tests do not pin the env-managed state or the impersonation feature off (minor, optional)

*Location*: plan:37 (T2's test).

*Defect*: an empty or misspelled `JMAP_SERVER_URL` moves Bulwark to `bootstrap` and serves the setup
wizard on the public name. A token in the logs still gates it (`lib/setup/state.ts`,
`instrumentation.node.ts:36-50`). The impersonation feature grants sign-in as any mailbox once its
three variables are set (`.env.example`, "Stalwart Impersonation").

*Fold*: T2's test asserts `JMAP_SERVER_URL` is non-empty and that no `BULWARK_JWT_AUTH_*` or
`BULWARK_STALWART_MASTER_*` name appears. T5 step 2 adds `/setup` returning 404 or a redirect, never
200. About 2 minutes.
