# Operator runbook and succession: design

## Brief

This pass makes the servers repo enough for the second operator to run all of the household's IT if Geoff is gone for good and can't be reached. It rewrites the runbook around him, gives him the account access he lacks today, makes the operator scripts run from his own Linux machine, and turns the monthly review into checklists a person can follow. A thin skill lets Geoff's other Claude projects learn the infrastructure from the same pages.

Geoff set the goal in chat on 2026-10-25, prompted by the phonebook work: "I've been hit by a bus and he can't call me. He need to be able to pickup any household IT operation without claude code." Two read-only recon reports that day (the Cloudflare account, live, and the repo's docs against what he can reach) showed that most of the gap is access, not prose.

Status: approved by Geoff in chat, 2026-10-25 ("Design approved.").

Initiative: self-hosting. Risk class: `auth-data`, flagged `live-account` (it grants account seats, adds an operator key, and touches `cloudflare/access.json` and the secret store's recipients). Estimate: 600 path minutes, set from the servers backlog second batch (495 actual against 470 planned), a pass of similar breadth; Bulwark and mail filters ran at about half their plans, so this line is not padded further. End-to-end check: below, under "The check".

### His role in the Cloudflare account

Geoff ruled Super Administrator on 2026-10-25, with two-factor enforced on the account. Only that role can manage billing, the domain registration, and members, and on the bus day nobody else could grant them. The narrower Administrator role would leave the registrar and billing out of his reach.

### How he reaches the server secrets

The scripts read `~/.local/secrets`, rendered from `~/.dotfiles/secrets/values.age`. That file is Geoff's whole workstation store, holding every project's secrets, not only the servers'. Today he could reach it only through the paper recovery kit or Emergency Access to Geoff's `Workstation` vault after its 7-day wait, and either route opens everything.

Geoff approved the split on 2026-10-25. The servers' secrets move into a servers-only age store, committed encrypted in the servers repo. Its recipients are Geoff's workstation key and an age identity of his own, whose private key sits in his Proton Pass. He can then start on day one, and rotate a secret himself, with no access to anything outside the household. The workstation renders the servers names from the new store instead of `values.age`, and the paper kit stays as the last-resort route. The builder sets the store's write path and moves `scripts/lib/secrets.sh` and every script that loads secrets onto it. The reason is least privilege, and it's what makes his own key a small exposure.

## Who it's for

The reader is the second operator on the day Geoff is permanently unavailable. He has the servers repo with write access, root through the browser terminal on both servers, Admin on `Servers emergency`, and Emergency Access to Geoff's Proton account. He is comfortable on a command line but isn't a professional operator, and he doesn't speak Cloudflare. Claude Code may not be in his toolkit, so nothing he needs may depend on it.

Two things matter most (Geoff): he can get started quickly and find what he's looking for, and he has a very strong overview of all the infrastructure. He must be able to keep everything running the way Geoff runs it now, not a reduced caretaker version.

The secondary goal is that Geoff's other Claude projects stop rediscovering the household infrastructure.

## Scope

In scope:

- Everything the household depends on: both servers and their services (Stalwart, Bulwark, Immich, the bookmark share, mail filters), 907.life and its subdomains, the Cloudflare pieces (DNS, the monitor and MTA-STS Workers, Access, the two tunnels, R2, Email Sending), Proton Pass and the alias domains, GitHub, and the accounts behind them.
- Music (dubplate) and the phonebook as they stand: one paragraph each saying what exists and which repo owns it. The pass that deploys each one writes its operator pages when it deploys.
- The access work under "Access".
- BACKLOG #37 (Access and tunnel operator section), #38 (Cloudflare or tunnel down), #39 (single redirects), and #50 (operator keys installed by `apply.sh`).

Out of scope:

- The club sites, cairn, the 907.life website, and Geoff's other projects. The overview lists each by name with a link to the repo that documents it (Geoff: "they can document themselves").
- Paying the bills. They keep getting paid. The docs list each service billed to Geoff's card, with the amount and renewal date (Geoff).
- Cleaning up the Cloudflare account's leftovers (the Fastmail DKIM records, the expired service token, the phonebook probe). The overview notes the ones he will see; a backlog item takes the rest.

Anti-goal: a runbook so long or so scattered that he can't find the one thing he needs.

## The docs

Geoff ruled that reorganizing is the builder's call. The builder keeps this shape and decides the file split.

- **Start here.** One short page, linked from the top of `README.md`. It says what the household runs and what to do in the first hour of the bus day, in order: which accounts to check and recover, how to reach the keys, which alerts to watch, and where to look next.
- **The overview.** The strongest page in the repo. It covers what runs where, how a request reaches a service, how mail flows, which accounts hold what, and who pays. It carries the figures and lists the non-household projects.
- **Task pages,** grouped by what he's trying to do: emergencies, routine upkeep, changes, and accounts. Each service also has one page, reachable from the overview, that says what it is, where it runs, what depends on it, how to check it, upgrade it, and restore it, and where its official docs live. Headings name the task ("Renew the domain", "A tunnel is down").
- **The emergency screens** keep their form: copy-paste commands, expected output, and a stop line. A stop line no longer says "call Geoff". It names the next screen, or says what is safe to leave until he has read further. `EMERGENCY.md` is still rendered from them, and the gate still fails on drift.
- **A Claude Code page** says how to set up and use Claude Code as an assistant on this repo, if he wants one. No other page depends on it (Geoff).
- **An appendix for Geoff and Claude** takes the Claude infrastructure section and the pass-history shorthand, out of his path.

Concepts come before links (Geoff). Each Cloudflare or mail concept he meets, such as a zone, a Worker, a tunnel, an Access application, or an MX record, gets a few plain sentences where it first appears: what it is, and what it does for the household. Then a link goes to the vendor's page for how-to detail, or to a stable explainer like Wikipedia for depth. The docs never copy vendor documentation, and they never link a blog post or another page likely to move. Pointing out keeps the pages short (Geoff).

Register (my call, contestable): the operator pages use Survey's editor register (`skills/survey/writing/editor.md`, the Microsoft Writing Style Guide), since the reader isn't a developer. The appendix keeps the Google developer register the repo uses today. `.vale.ini` adds the Microsoft package for the operator globs.

Figures (my call): a few Mermaid diagrams, which GitHub renders and which diff as text. Each answers one question he'll have and sits on the page that needs it. The builder starts from four: what runs where, how a request reaches a service, how mail flows in and out, and which account holds what.

## Access

- **Cloudflare:** a member seat for him in account `glw907`, in the role decided above, with two-factor enforced on the account.
- **Hetzner:** a seat in the servers project, the invite STATUS lists as owed. The builder checks whether a project member can do everything the runbook asks, including the console and images, and documents what stays with the account owner.
- **GitHub:** Geoff names him as his account successor, if GitHub's successor feature covers this, and he keeps write on the servers repo. The builder confirms the feature and lists what a successor can and can't take over.
- **His ssh key** goes into `base/keys/`, and `apply.sh` installs every key there (#50), so a Cloudflare outage doesn't lock him out (#38).
- **The server secrets,** by the route decided above.
- **One household vault.** A new general-purpose Proton Pass vault holds every shared household secret, and `Servers emergency` moves into it and retires (Geoff, 2026-10-25). Both operators hold it as Admin, and Claude reaches it through `claude-pass`, so one vault serves both people and Claude Code. Geoff named it `Household IT`, since other family members use Proton Pass and `Household` would read as theirs. It holds no personal item of Geoff's: his mailbox password, Proton login, and the age key stay in `Workstation` (Geoff, 2026-10-25).
- **His own address is enough.** Every seat, invite, recovery address, and admin role he gets uses `oliver@907.life` or his Proton address, so nothing he manages needs Geoff's mailbox (Geoff: "his own mail account should be enough for all management"). The builder checks each account's recovery and notification addresses against this. The builder moves the items, updates every doc that names `Servers emergency`, and re-points Claude's vault grant.
- **The accounts page** lists every account the household runs on: who holds access, how it's recovered, whether it bills Geoff's card, the amount, and the renewal date. That covers Cloudflare (with the domain registration), Hetzner, Proton, GitHub, and any others the builder finds.

Every grant is a live change. He sits after the merge (Geoff, 2026-10-25), so the plan splits each grant: Geoff's half (sending an invite, naming a successor, enforcing two-factor) goes in pre-flight or the pass, and his half (accepting, enrolling two-factor, sending his ssh and age public keys) goes on a sitting checklist the pass writes. Until that sitting, his key isn't in the store or `base/keys/`, and the docs say so on the start-here page.

## His machine

The operator scripts (`apply.sh`, `provision.sh`, `dns.sh`, `access.sh`, the drill and restore tools) assume a Bluefin workstation and Geoff's ssh keys today. They must run from an ordinary Linux machine (his is Linux Mint) with his own key and the age key, after installing the tools the runbook lists. The builder chooses between making the scripts portable and shipping a container that carries the tools, and documents the one install path.

## Upkeep

Every duty in `docs/monthly-review/prompt.txt` becomes a checklist he can follow by hand: upgrades, restore drills, DKIM and password rotation, R2 cleanup, the credential dry run, and the yearly items. The checklists become the source, and the monthly-review prompt reads them, so the Claude session and the person do the same job from one list.

The workstation-only pieces stay where they are (my call). `monitor-subscribe` raises desktop popups on Geoff's machines, but the email alerts already reach him at `oliver.907.life@proton.me`, so the runbook tells him those emails are the alerts and maps each one to its screen. Nothing gets installed on his machine beyond the operator tools.

## The skill

My call: a thin `household-infra` skill in the workstation's Claude tooling, for Geoff's other projects (Geoff: "If that's not useful, we don't have to build it"). It says what the household infrastructure is, when it matters (a new Worker on 907.life, a DNS change, a service that sends mail), and which runbook pages to read. It carries no copy of the infrastructure. `~/.claude/docs/cloudflare-estate-inventory.md` keeps the workstation-only facts (token scopes, how Claude reaches each secret), and the skill points there for those. It lands through `claude-infra` and its manifest.

## The check

A fresh-context agent gets only the repo at the branch head and a list of what the second operator holds. It must answer a fixed set of bus-day questions from the docs alone, each with the page it found the answer on. The questions include: what to do first, where the age key is, how to renew 907.life, a tunnel is down, Immich is down, and the monthly checklist. Separately, the operator scripts run once from a Linux Mint container: the test suite against fakes, then one live, read-only `dry-run.sh` that decrypts the servers store with his identity and reaches both servers and the Cloudflare and Hetzner APIs. That live run happens in his sitting after the merge, so the branch merges before anyone has walked his route end to end. The pass proves the same run with a throwaway identity added to a scratch copy of the store, and his sitting repeats it for real.

## Left to the builder

The file split and page names, the figures beyond the first four, the portability method, the checklist format, and the exact wording of the bus-day questions.
