Initiative: self-hosting

# Pass 0 checklist

Pass 0 runs attended, with Geoff present throughout, in the session `workstation-self-hosting-pass0`. Each row's full contract is its step in the plan's "Pass 0: attended access" (`2026-10-17-self-hosting-plan.md`); this page is the order and the ticks. Every credential arrives through `secret-receive NAME`, written into the workstation worktree `.claude/worktrees/self-hosting-pass0` per the plan's "Secrets in the age store". Nothing new goes into 1Password. The session ticks each row in STATUS as it closes, never here.

## Before the sitting

- [ ] The workstation main checkout is on `main`, pulled, and `git -C ~/.dotfiles diff --quiet -- secrets/values.age` passes.
- [ ] Geoff has both FIDO2 keys, his phone, and the card for the Proton purchase.
- [ ] The second operator can answer a message during the day (0.8 sends his asks).

## The steps

| Step | Geoff | Claude | Done when |
|---|---|---|---|
| 0.0 Servers repo (25) | Confirms the names, addresses, and usernames for the privacy patterns | Creates `glw907/servers` private, the README commit, the privacy check, and its self-merged PR | The check's five tests pass and `main` holds the PR |
| 0.1 Port 25 (10) | Files the request below in the Hetzner console | Records the filing date in STATUS | The date is in STATUS; the 14-day clock starts |
| 0.2 Recovery (20) | Checks five logins recover off 907.life; stores the 2FA backup codes offline | Keeps the five rows, never the addresses | Five rows ticked |
| 0.3 Tools (25) | Nothing | Installs `hcloud`, `shfmt`, `yamllint`, `imapsync`, and a pinned `pass-cli`; records each in the manifest | Each `--version` prints |
| 0.4 Hetzner (20) | Creates the project and a read-write token; invites the second operator | Stores `HCLOUD_TOKEN_SERVERS`; no `hcloud context` | An empty server list, and an SSH key created then deleted |
| 0.5 Cloudflare (45) | Creates each token from Claude's permission list | Creates the three empty buckets first, then stores each token and each R2 S3 pair | Each bucket is listed; 0.12 proves the scopes |
| 0.6 Proton (30) | Buys Pass Family, sets up two FIDO2 keys and the paper phrase, sends four Family invites and the Emergency Access invite | Drafts the invitations | Geoff confirms each |
| 0.7 PikaPods and Fastmail (25) | Enables SFTP and updates the admin login; creates an IMAP and a DAV app password; confirms the address list | Stores each; lists the pod over SFTP; drafts the address list from JMAP | Six directories listed; `docs/addresses.md` committed |
| 0.8 Household (30) | Sends the three drafted messages | Drafts them; checks Fastmail's docs on admin-made credentials | Sent; STATUS lists what is owed |
| 0.9 Access and test accounts (25) | Creates the GitHub OAuth app, the Spamhaus DQS key, and the Gmail and Outlook.com test accounts | Reads or records the Zero Trust team; stores each; adds the identity provider | Geoff's test sign-in through Access succeeds |
| 0.10 Permissions PR (105) | Approves and merges the workstation PR in the sitting | Builds it test-first; runs `claude-tooling-sync apply` after the merge | The gate passes and the `dontAsk` checks hold |
| 0.11 Recovery kit (20) | Writes the phrase and the age key by hand; types the key into `age-keygen -y` | Compares the printed recipient with the store's | Recipients match; the date is in STATUS |
| 0.12 Dry run (55) | Fixes any failing credential before the sitting ends | Builds the loader and `scripts/dry-run.sh` test-first, then runs it | The STATUS table passes every arrived credential |

The close: the session self-merges the STATUS hand-over, writes and commits Pass 1's executor prompt and the conductor prompt, and launches `conductor-servers`.

## The port 25 request

Geoff files this in the Hetzner console under Limits, "Request change", then "Limit increase" (Hetzner Cloud server FAQ: "In your request, you can tell us details about your use case"). Hetzner requires a month as a customer and a paid first invoice, and decides "on a case-by-case basis". The account has qualified since at least 2026-08-31. The text names the project Geoff creates in 0.4, so 0.1 can follow 0.4 if the console asks for one.

> I'm asking to unblock outbound ports 25 and 465 for one server in my project, to run my family's own mail server for the domain 907.life.
>
> It's personal mail for four people, a few hundred messages a month, moving from Fastmail. It sends no bulk, marketing, or newsletter mail, and relays for no one outside the household.
>
> The server will be a CX33 running Debian 13 and Stalwart, named mail.907.life. Before it sends any mail:
>
> - Its Primary IPv4 and IPv6 will have PTR records for mail.907.life, matching its EHLO name and its A and AAAA records.
> - 907.life will publish SPF, a DKIM key, and a DMARC policy, and I already collect DMARC reports for the domain.
> - I'll check the IP against Spamhaus and other blocklists, and replace it if it's listed.
> - Sending requires an authenticated login, and a monitor alerts me if the outbound queue holds a message for more than two hours.
>
> Thank you.

Each claim comes from the design: four mailboxes ("Rulings"), the CX33 and Stalwart ("Size", "Stalwart"), PTR and IPv4-only sending ("Delivery"), the records ("DNS"), the blocklist check ("IPs"), and the queue-age alert ("Alerts").
