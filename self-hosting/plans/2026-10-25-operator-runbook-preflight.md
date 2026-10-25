# Operator runbook pass: pre-flight

The pre-flight items of `self-hosting/plans/2026-10-25-operator-runbook-plan.md`, and their state. Geoff approved the plan on 2026-10-25 (Approval Queue item `20261025T113157-1523801`). He chose to take his steps later, so the launch waits on them. The second operator appears here only by role, because this repo is public.

## State on 2026-10-25

| Item | Owner | State |
|---|---|---|
| Geoff's Cloudflare two-factor | Geoff | **Off.** `GET /accounts/{id}/members` reads `two_factor_authentication_enabled: false` for Geoff, the account's only member. Enforcement would lock him out, so item 2 waits until it reads true. My Profile, then Authentication; backup codes go in `Workstation`. |
| 1. Cloudflare seat | Geoff | Not started. Invite his Proton address as Super Administrator. |
| 2. Two-factor enforcement | Claude, then Geoff on a 403 | Waits on Geoff's own two-factor. Members' state read 2026-10-25 (one member, above). |
| 3. Hetzner seat | Geoff | Not started. Project `self-hosting`, Security, Members, Admin. |
| 4. GitHub successor | Geoff | Not started. |
| 5. Billing and renewal facts | Geoff, and Claude for Hetzner | Not started. |
| 6. Claude's vault route | Claude | Done 2026-10-25: `claude-pass` lists `Household IT` and `Workstation`. Proton rate-limits logins after about four in quick succession; space calls about two minutes apart. |
| 7. Permission rules | Claude drafts, Geoff approves in a separate packet | Not started. It follows items 1 to 5 in the packet's order. |

`Household IT` is shared with the second operator as Admin, and `Servers emergency` is deleted. On 2026-10-25 a paced run began renaming the vault's items with category prefixes, each with a note naming its store variable, and moved both Fastmail logins and a duplicate Yealink entry to Trash. Its result is recorded below once it ends.

## Next

When Geoff says a step is done, the session that picks this up checks it as the plan's pre-flight says and updates the table. After items 1 to 6 pass, it drafts item 7's rules change and sends it as a separate packet. After that merges, it sends the plan to `conductor-servers`, which launches `servers-operator-runbook`.
