# Self-hosting: STATUS

Plan: `self-hosting/plans/2026-10-17-self-hosting-plan.md`. Design: `self-hosting/specs/2026-10-17-self-hosting-design.md`. Until `conductor-servers` launches, the Pass 0 session is this file's only writer; from then on, the conductor is.

## Current state

Planned, and nothing is built. Geoff approved the design and the pass plan on 2026-10-17. The plan merged in glw907/initiatives#10 as `c5f91d4`. No servers repo, account, token, or server exists yet.

Rulings at plan approval (Geoff, 2026-10-17, plan packet), each the recommended answer:
1. Claude tests the household members' mailboxes in C3, reading only its own test messages' headers.
2. The line is 3,515 path minutes and the ceiling 5,273. A task past twice its estimate extends once to four times, then stops.
3. Geoff turns a production server's protection off for Claude's rebuilds and the L6 image restore. The second operator's emergency screen tells him to turn it off, restore, and turn it back on.

## Next action

Geoff sits for Pass 0 with Claude, on whichever host he is at. Start it from the workstation checkout:

```
cd ~/.dotfiles && claude --model sonnet --effort medium --name workstation-self-hosting-pass0 "$(cat ~/Projects/initiatives/self-hosting/plans/2026-10-17-pass0-prompt.txt)"
```

The order and the port 25 request text are in `2026-10-17-pass0-checklist.md`. The port 25 request goes first among Geoff's steps, because mail waits on Hetzner's answer.

## Pass 0 rows

| Step | State |
|---|---|
| 0.0 Servers repo | done 2026-10-17: `glw907/servers` private, README and PR #1 (privacy check, patterns, empty registry) merged |
| 0.1 Port 25 | done 2026-10-17: filed and validated automatically; Hetzner unblocks ports 25 and 465 on all the account's Cloud Servers within minutes. No 14-day wait, so Pass 5's port 25 entry condition is met and the daily JMAP check and the options-packet standing answer are moot |
| 0.2 Recovery | not started |
| 0.3 Tools | not started |
| 0.4 Hetzner | token done 2026-10-17: `HCLOUD_TOKEN_SERVERS` stored (workstation PR #88, draft); empty server list and SSH key create/delete pass. Open: invite the second operator to the project |
| 0.5 Cloudflare | not started |
| 0.6 Proton | not started |
| 0.7 PikaPods and Fastmail | not started |
| 0.8 Household | not started |
| 0.9 Access and test accounts | not started |
| 0.10 Permissions PR | not started |
| 0.11 Recovery kit | not started |
| 0.12 Dry run | not started |

## Owed

- Musicbox: Geoff deleted the musicbox Hetzner project on 2026-10-17, before I3. The server, its 50 GB volume, and its old token are gone (token removed from the store in PR #88). Pass 3 I3 can no longer copy `/srv/music/library` or `/var/lib/dubplate` from it; the only possible copy is the R2 bucket `music-library`, whose contents I3 was already to read. The next plan revision rewrites I3, I4's musicbox packet, and the dubplate host-contract rows. Until then dubplate has no host.
- Design errata: the plan's fold record (`research/2026-10-17-self-hosting-plan-fold.md`) lists eleven for the next design revision. Ruling 3 settled items 7 and 11, so none waits on Geoff. Until that revision, the plan governs where the record names an erratum.
- thinkpad-x1 per-host steps: the servers repo clone, the ntfy subscriber, the agent token, and the W5 key check. Each is open until done on that host.
- Human steps: every row in the plan's "Human steps" table is open.

## Open decisions

None.

## Sessions

- Planner: session `26c03024` on pavilion. It wrote the plan and this file, and it ends after this hand-over merges.
