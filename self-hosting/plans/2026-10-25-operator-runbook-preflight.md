# Operator runbook pass: pre-flight

The pre-flight items of `self-hosting/plans/2026-10-25-operator-runbook-plan.md`, and their state. Geoff approved the plan on 2026-10-25 (Approval Queue item `20261025T113157-1523801`). He chose to take his steps later, so the launch waits on them. The second operator appears here only by role, because this repo is public.

## State on 2026-10-25

| Item | Owner | State |
|---|---|---|
| Geoff's Cloudflare two-factor | Geoff | **Off.** `GET /accounts/{id}/members` reads `two_factor_authentication_enabled: false` for Geoff, the account's only member. Enforcement would lock him out, so item 2 waits until it reads true. My Profile, then Authentication; the backup codes go in the Cloudflare login's Proton Pass item (`Workstation` no longer exists, amendment item 1). |
| 1. Cloudflare seat | Geoff | Not started. Invite his Proton address as Super Administrator. |
| 2. Two-factor enforcement | Claude, then Geoff on a 403 | Waits on Geoff's own two-factor. Members' state read 2026-10-25 (one member, above). |
| 3. Hetzner seat | Geoff | Not started. Project `self-hosting`, Security, Members, Admin. |
| 4. GitHub successor | Geoff | Not started. |
| 5. Billing and renewal facts | Geoff, and Claude for Hetzner | Not started. |
| 6. Claude's vault route | Claude | Done 2026-10-25, owed again after the 2026-11-03 reorganization: the check is now `claude-pass item list --vault-name Infrastructure`. Proton rate-limits logins after about four in quick succession; space calls about two minutes apart. |
| 7. Permission rules | Claude drafts, Geoff approves in a separate packet | Not started. It follows items 1 to 5 in the packet's order. |

`Household IT` is shared with the second operator as Admin, and `Servers emergency` is deleted. On 2026-10-25 the vault's eight items were renamed with category prefixes (Backups, Mail, Bookmarks share, Spamhaus, Phone), each with a note naming its store variable, and both Fastmail logins and a duplicate Yealink entry went to Trash. A final list read back all eight active titles and the three trashed items.

## Amendment, 2026-11-03

The plan carries a dated amendment from the credential-hygiene design (`credential-hygiene/specs/2026-11-03-remaining-work-design.md`), which Geoff approved in Approval Queue item `20261103T202632-2969677`. `Household IT` is now `Infrastructure`, its items carry the 2026-11-03 naming scheme, and `Workstation` is gone. The 2026-10-25 paragraph above records the state on that day. This pass launches after credential-hygiene's pass B merges.

## Next

When Geoff says a step is done, the session that picks this up checks it as the plan's pre-flight says and updates the table. After items 1 to 6 pass, it drafts item 7's rules change and sends it as a separate packet. After that merges, it sends the plan to `conductor-servers`, which launches `servers-operator-runbook`.

## The sitting's record

The sitting started on 2026-11-07, after credential-hygiene's pass B merged. `conductor-servers` checks each item as Geoff finishes it.

| Item | State on 2026-11-07 |
|---|---|
| Geoff's Cloudflare two-factor | **On.** Off at the start (`GET /accounts/{id}/members`: one member, Geoff, `accepted`, Super Administrator, `two_factor_authentication_enabled: false`); the same read later on 2026-11-07 shows `true`. Geoff has no smartphone, so the method is Mobile App Authentication (plain TOTP) through Proton Pass. Geoff first saved the recovery codes on the `Cloudflare` item in `Infrastructure`, then moved them to his personal vault, so Claude's agents can't read them. The `Cloudflare` login item itself stays in `Infrastructure`. |
| 1. Cloudflare seat | **Passes.** Geoff sent the invite after enforcement was on. `GET /accounts/{id}/members` lists two members: Geoff (`accepted`) and a `pending` Super Administrator whose address matches an entry in `cloudflare/monitor/config.json`'s `alert_to` (compared in a script, never printed). He hasn't accepted yet. Enforcement will ask him to enroll in two-factor when he does. If the invite expires before he accepts, Geoff re-sends it in the post-merge sitting (standing answer). |
| 2. Two-factor enforcement | **Passes.** The documented `PUT /accounts/{id}` (the whole object from the first GET, only `settings.enforce_twofactor` set to `true`) answered 403, code 9109, "Unauthorized to access requested resource". A second GET matched the first in every field, `enforce_twofactor` still `false`. Geoff turned it on in the dashboard. **Passes:** a third GET reads `enforce_twofactor: true`, and the other 11 fields match the first GET. Cloudflare's docs note that turning enforcement off again takes a support ticket and 1 to 2 business days. |
| 3. Hetzner seat | Open. |
| 4. GitHub successor | Open. |
| 5. Billing and renewal facts | Hetzner amounts read by Claude (below). Geoff's columns open. |
| 6. Claude's vault route | **Passes.** `claude-pass --status` prints `path=proton host=pavilion`. The first `item list --vault-name Infrastructure` hit Proton's login throttle. A retry five minutes later answered with the vault's titles (read, not recorded here). The `pavilion-claude` token expires 2027-01-20. |
| 7. Permission rules | Drafted after items 1 to 5 pass, as its own packet. |

### Hetzner amounts (item 5, Claude's half)

Read 2026-11-07 from `HCLOUD_TOKEN_SERVERS` (`GET /servers`, `/primary_ips`, `/images?type=snapshot`, `/pricing`). The project bills in USD, with a VAT rate of 0.

| Resource | Monthly (USD) |
|---|---|
| orpheus, cx33, nbg1 | 9.99 |
| ward, cax21, fsn1 | 12.49 |
| ward's backups (20% of the server) | 2.50 |
| Two primary IPv4 addresses (0.60 each; the two IPv6 are free) | 1.20 |
| Snapshot `pre-change orpheus`, 2026-10-21, 29.2 GB at 0.0199/GB | 0.58 |
| **Total** | **26.76** |

The project has no volumes, floating IPs, or load balancers. Found, not done: the 2026-10-21 orpheus snapshot costs 0.58 a month and may no longer be needed. Geoff decides whether to delete it.
