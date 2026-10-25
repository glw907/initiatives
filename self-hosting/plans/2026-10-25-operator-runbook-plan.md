Initiative: self-hosting

# Operator runbook and succession: plan

Design: `self-hosting/specs/2026-10-25-operator-runbook-design.md` (approved by Geoff in chat, 2026-10-25). Risk class: `auth-data`, flagged `live-account`. Design estimate: 600 path minutes. Plan: 720 path minutes, 1,165 task minutes. Path ceiling: 1,200 (twice the design). Spend ceiling: none; the pass buys nothing, since a Cloudflare member, a Hetzner project member, and a GitHub successor cost nothing. Executor: `servers-operator-runbook`, under `conductor-servers`.

## Brief

This plan builds the approved design: a servers-only age store with the second operator's identity as a recipient, operator scripts that run from his Linux Mint machine with his own key, the runbook rebuilt around him (start here, an overview with figures, task pages, the emergency screens, upkeep checklists, accounts, a Claude Code page, and an appendix), BACKLOG #37, #38, #39, and #50, the vault references moved to `Household IT`, and a thin `household-infra` skill. One servers branch and one workstation branch, whose PRs come back to Geoff in one packet through `conductor-servers`. The path is 720 minutes, 120 over the design's line and under the 1,200 ceiling. Geoff's half of each grant runs in pre-flight. His half runs in a sitting after the merge, from a checklist the pass writes. One pre-flight item is new since the design: the permission rules in item 7. It holds the launch, and the design stage records it as a planning miss.

Facts found at planning that correct the design's wording without changing its outcome. Each one goes in the servers PR's `## Decisions` and in `docs/decisions.md`:

1. `scripts/dry-run.sh` reaches the servers only over HTTPS (the `immich-orpheus` and `webdav-*` rows). It never opens ssh. So the live route check is `dry-run.sh` plus `scripts/apply.sh orpheus --check` and `scripts/apply.sh ward --check`, all read-only.
2. `cloudflare/access.json` already lists `oliver@907.life` for both hosts (servers `2483cef`), so the Access work needs no change.
3. The Hetzner console project is named `self-hosting` (STATUS, Pass 5 item 6), not "servers".
4. `Servers emergency` no longer exists. Geoff moved every item and deleted the vault on 2026-10-25. The pass only re-points references.
5. Geoff's mailbox and WebDAV passwords stay out of the servers store. Geoff ruled on 2026-10-25 that "his own mail account should be enough for all management". Both renders can take a hash in place of the plaintext, verified from the pinned releases' source:
   - **Stalwart v0.16.27** stores a Password credential whose secret is already a complete hash (`$argon2`, `$2`, `$6$`, and others) as it is, and skips both the strength check and its own hashing (`crates/jmap/src/registry/mapping/principal.rs:134-154, 300-315`; `crates/directory/src/core/secret.rs` `is_password_hash`).
   - **rclone v1.75.2**: `--htpasswd` takes an Apache htpasswd file that "supports MD5, SHA1 and BCrypt ... Bcrypt is recommended" (`lib/http/auth.go:32-34`). Its tests sign in a bcrypt user (`lib/http/middleware_test.go:63-73`).

   One consumer can't use a hash. On ward, `roles/mail-filters/mail-filters:95-103` (the daily Sieve refresh) and `roles/stalwart/stalwart-jmap:39-42` sign in to Geoff's mailbox with the plaintext from `/etc/servers/stalwart.env`. So that plaintext moves to its own optional file, `/etc/servers/stalwart-geoff.env`, which only a workstation apply renders. An apply that lacks the name leaves the installed copy alone.
6. `scripts/apply.sh:52`, `secrets/render.sh:136`, `infra/project.env:14` (`SSH_USER=geoff`), and the ward mail helpers all ssh as `geoff`. His Unix account is `oliver`.
7. ward-probes (draft glw907/servers#22) runs in its own worktree. It adds `scripts/ward-book-check.{py,sh}`, `tests/fakes/ward-book-server.py`, and `tests/ward-book-check.test.sh`, and appends to `BACKLOG.md` and `docs/decisions.md`. Its later Part B edits `docs/runbook.md` and `roles/stalwart`. This pass doesn't wait for #22. The restructure lands first, and Part B rebases onto the new pages and adopts `SERVERS_SSH_USER`.

### Planning guidance carried from pass-core

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused: - Scope: Don't add features, refactor code, or make "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up. A simple feature doesn't need extra configurability. ... - Defensive coding: Don't add error handling, fallbacks, or validation for scenarios that can't happen. Trust internal code and framework guarantees. Only validate at system boundaries (user input, external APIs). - Abstractions: Don't create helpers, utilities, or abstractions for one-time operations. Don't design for hypothetical future requirements. The right amount of complexity is the minimum needed for the current task."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)
>
> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself, and check in only when different readings of the request would lead to materially different work. If the request seems mistaken or a better approach exists, say so in a sentence and continue with the task as asked rather than quietly narrowing, widening, or transforming it. Finish the whole task, and stop short of actions that are clearly beyond what was asked."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)

Extras go under "Later" and are never built.

## Calls this plan makes

The design leaves these to the builder. A reviewer may contest any of them.

- **Invite address.** The Cloudflare and Hetzner invites go to `oliver.907.life@proton.me`, not `oliver@907.life`. Those two accounts are the ones that rebuild 907.life's mail, and Geoff's 2026-10-18 recovery ruling keeps their logins off 907.life. GitHub keeps `oliver@907.life`, because the Access policy matches it.
- **His age key's home.** His age private key goes in his own Proton Pass vault, not `Household IT`, so that Claude and Geoff can't read it.
- **Which names move to the servers store.** A name moves when a host render, a servers Worker, or a servers script reads it, unless it opens one of Geoff's own accounts. These stay only in the workstation store:
  - `CLOUDFLARE_API_TOKEN` (the broad `ws-admin`, which every project uses), `CF_ZT_TOKEN`, and the `FASTMAIL_*` names (they retire when Fastmail closes).
  - Geoff's personal logins, `STALWART_PASSWORD_GEOFF` and `WEBDAV_PASSWORD_GEOFF`. The servers store holds their hashes instead, as `STALWART_PASSWORD_HASH_GEOFF` and `WEBDAV_HTPASSWD_GEOFF`.

  His `dry-run.sh` shows the `webdav-geoff` row and the rows that need the broad token as OWED. He loses no operation by that: the share and the mailbox run from the hashes, and as Stalwart admin he can reset Geoff's password. A ward he rebuilds lacks `stalwart-geoff.env`, so Geoff's daily Sieve refresh and `stalwart-jmap geoff` stop until someone resets that password. The one script that needs the broad token is `cloudflare/r2.sh`, and for it the runbook has him make his own token as Super Administrator. `IMMICH_PIKAPODS_API_KEY` and `ACCESS_GITHUB_CLIENT_*` are service credentials for the household, not Geoff's own logins, so they move.
- **Every WebDAV member signs in through htpasswd.** The systemd template serves all three members. A per-member exception would need a credential file that only Geoff's instance has, so the switch is uniform. The plaintexts of the other two members stay in the servers store for `dry-run.sh` and their Proton Pass copies.
- **Portable scripts, not a container.** The scripts are bash plus standard tools, so the pass removes the Bluefin and `geoff` assumptions and keeps one apt list. A gate leg runs the harness in a Linux Mint image, so portability can't quietly regress.
- **Key layout.** Keys move to `base/keys/<unix name>/<machine>.pub`. `apply.sh` keeps each account's `authorized_keys` equal to that account's directory. An account with no directory is left as it is.

## Entry

- The plan is approved and every pre-flight item is done and checked.
- No other executor works the worktree `.claude/worktrees/operator-runbook` or the branch `operator-runbook` (`pgrep -f`, `git status`, `claude agents --json`). The ward-probes executor may be live in `.claude/worktrees/ward-probes`. This pass never touches that worktree or its branch.
- The servers main checkout is on `main`, clean, and level with `origin/main`. `git -C ~/.dotfiles diff --quiet -- secrets/values.age` passes.

## Pre-flight

Only Geoff can do these, except where an item says otherwise. Each item's check runs before launch. The values go in `self-hosting/plans/2026-10-25-operator-runbook-preflight.md` under "The sitting's record", the way `2026-10-21-pass5-preflight.md` did it. Amounts and dates go in that file, with no secret values.

1. **Cloudflare seat.** In Manage Account > Members, invite `oliver.907.life@proton.me` as Super Administrator. Claude can't send the invite, because no standing token has member write: `ws-admin`'s scopes in `~/.claude/docs/cloudflare-estate-inventory.md` include none, and rule 6 limits temporary tokens to token management. *Check*: with `CLOUDFLARE_API_TOKEN`, `GET /accounts/120c269ad6d3dfbe6d63a0bb53758ca0/members` lists him as pending with role Super Administrator (names and states only).
2. **Two-factor on the account.** Claude tries this first: `PATCH /accounts/{id}` with `settings.enforce_twofactor: true`, using `CLOUDFLARE_API_TOKEN`. If that answers 403, Geoff turns on two-factor enforcement in the dashboard. *Check*: `GET /accounts/{id}` shows `enforce_twofactor: true`.
3. **Hetzner seat.** In the console, open project `self-hosting` > Security > Members and invite `oliver.907.life@proton.me` as Admin. Hetzner has no member API. *Check*: Geoff confirms in the sitting, and the record names the role.
4. **GitHub successor.** In Settings > Account > Successor settings, name `owright907`. *Check*: Geoff confirms, and the record says the invite is pending.
5. **Billing and renewal facts.** For each account, record the amount, the card or payer, the renewal date, and whether it auto-renews. Geoff reads Cloudflare's subscriptions; 907.life's registration (expiry, auto-renew, and renewal price, under Domain Registration); Proton (the Pass Family plan); GitHub, if it's a paid plan; and any other household account billed to his card. He names those last ones himself, and candidates to ask about are Spamhaus DQS, PikaPods, and Fastmail until it closes. Claude reads the rest by API. Hetzner's monthly amounts come from `HCLOUD_TOKEN_SERVERS` (`GET /pricing` and the project's servers, Primary IPs, and backups). The GitHub plan name comes from `gh api user --jq .plan.name`. *Check*: every row of the record's table is filled.
6. **Claude's vault route.** If the agent's login fails, Geoff renews it as `bluefin-admin.md` "Secrets" describes: a fresh `pass-cli agent create pavilion-claude --expiration 3m` in a throwaway session, then `secret-tool store --label "Proton Pass claude agent" service proton-pass-agent-claude host pavilion`. *Check*: `claude-pass --status` prints `path=proton`, and `claude-pass item list --vault-name "Household IT"` answers (the conductor reads titles only).
7. **Permission rules** (new since the design). Geoff merges a workstation change that adds two allow rules. The first allows `scripts/store.sh` under `/var/home/glw907/Projects/servers/.claude/worktrees/*/` and never in the main checkout. The second allows `tests/mint/route-check.sh` in the same worktrees. Both are drafted in this plan's pre-flight file, with a stub proof in a `dontAsk` session, the way Pass 5's rules file did it. *Check*: both rules are in `~/.claude/settings.json`, and the stub proof passed.

`Household IT` is already shared with the second operator as Admin, so that grant needs nothing.

## Standing answers

| Situation | Answer |
|---|---|
| No official Linux Mint 22 image exists, or it won't run under rootless podman | Use `ubuntu:24.04`, which is Mint 22's base. Record it under `## Decisions`. His sitting still runs on real Mint. |
| A script needs a tool that Mint's apt doesn't carry (for example `hcloud`) | Install the pinned upstream release, add it to the one tool list, and record it. |
| `claude-pass` stops logging in mid-pass | Send `conductor-servers` one message. The conductor asks Geoff to renew the token per pre-flight 6. Keep going with the other work, and run the vault check at T11 instead. If it still fails then, list the check under `## Not checked`. |
| The vault check finds a design-named shared item missing from `Household IT`, or a personal item of Geoff's in it | Never move, create, or delete an item. Record the title under `## Decisions` and in the packet. |
| `dry-run.sh` in the route check shows OWED rows for names that stay in the workstation store (`webdav-geoff`, the broad-token rows, Fastmail) | Expected. List them on the sitting checklist, with what each one costs him. A FAIL row gets traced and fixed. |
| After merge, Geoff's mailbox or share stops accepting his password | Re-apply that host from the merge's first parent. Its templates read the plaintext names, which still sit in the workstation store, so the old login comes back. Then trace the cause. |
| A name both projects read turns up in the workstation-wide grep | It moves to the servers store, and the workstation renders it from there, the way `MONITOR_READ_TOKEN` is handled. |
| `sync.sh --local` finds a name in both stores | It fails and names the name. Delete that name from the workstation worktree's `values.age` with `secret-set.sh --delete --values <worktree path>`. |
| The auto-mode classifier denies a live read, `podman run`, or an image pull | Never retry it. Record the command and the site, carry on, list it under `## Not checked`, and send the conductor one message. The sitting covers a denied route check. |
| The Hetzner docs show that a project Admin can't do a step the runbook needs (the console, rescue, images, protection, billing) | Write down what stays with the account owner, on the accounts page and as a packet item. It isn't a stop. |
| GitHub's successor feature doesn't cover something the design expects | Write down what a successor can and can't take over. It isn't a stop. |
| The Microsoft Vale package floods the operator pages | Fix the errors, per `vale-fix`. A rule switched off needs its reason in `.vale.ini`. |
| A bus-day question still fails after two fix rounds | Escalate that question in the PR and continue to close. This is the one escalation this plan allows. |
| #22 merges into `main` before this pass closes | Merge `origin/main`, then resolve the `BACKLOG.md` and `docs/decisions.md` appends by keeping both. |
| A pair's files overlap | Run the two tasks in sequence and record it. |
| A task hits its clock stop | The conductor extends it once, to twice its estimate, as long as the path stays under 1,200 minutes. Past that, it asks Geoff. |

Stops: the 1,200-minute path ceiling; a cause the session can't trace; a secret only Geoff has; any write to account membership, settings, or billing at Cloudflare, Hetzner, GitHub, or Proton outside pre-flight; any Proton Pass item write; a change to the workstation main checkout's `values.age`; and any `--apply`. Each stop sends `conductor-servers` one message.

## Tasks

The servers worktree is `.claude/worktrees/operator-runbook` on branch `operator-runbook`. The workstation worktree is `~/.dotfiles/.claude/worktrees/self-hosting-operator-runbook` on branch `self-hosting-operator-runbook`. Both are cut from `origin/main`. `auth-data` tasks run test-first and get a task-scope `diff-reviewer` read while CI runs. Store writes, live reads, and `claude-pass` run in the main loop. One arm at a time works the workstation worktree, by absolute path. The executor sends STATUS lines to the conductor and never edits STATUS. Gates: servers `CAIRN_GATE_LANE=light cairn-run-gate 'bash scripts/check.sh --changed'` (the full gate at close), workstation `bash scripts/gate.sh`, and CI watched with `ci-green <sha> --pr <n> --wait`. The executor runs no `--apply`.

- **T1. The servers store (100 min, `auth-data`, pair with T2).**
  - *Outcome*: a servers-only age store committed encrypted, its writer, and the loader moved onto it.
  - *Files*: `secrets/servers.age`; `secrets/recipients.txt` (Geoff's workstation public key, the `RECIP` in the workstation `secret-set.sh`; his own line arrives at the sitting); `scripts/store.sh`; `scripts/lib/secrets.sh`; `secrets/registry.md`; `tests/store.test.sh`; `tests/secrets-lib.test.sh`.
  - *`store.sh`*: `set NAME` takes the value on stdin, never argv. `set-hash NAME --sha512-crypt|--bcrypt [--user U]` also reads the plaintext on stdin, but stores only its hash, with `U:` in front for an htpasswd line. The hash tools must exist on both Bluefin and Mint and must read the value from stdin; one candidate pair is `openssl passwd -6 -stdin` and `htpasswd -B -i`. Its other verbs are `delete NAME`, `names` (names only), and `rekey`, which re-encrypts to `recipients.txt`. It reads the identity from `SERVERS_AGE_IDENTITY`. With that unset, it uses the workstation cache `/dev/shm/.age-key-$UID` when that exists, and otherwise `~/.config/servers/age-identity.txt`. Plaintext lives only in pipes or `/dev/shm`. Every write checks that its output decrypts and drops no name.
  - *`secrets_load`*: loads the overlays, then `~/.local/secrets`, then the store, and the store wins. A missing store or identity fails, naming the file.
  - *Main loop*: copy the moving names (the "Calls" rule; `secrets/registry.md` lists them) from the decrypted workstation store into the worktree's store, never printing a value. Then confirm each name's hash is the same in both.
  - *Test*: with a throwaway identity, the tests cover these cases. A round trip keeps every name. `set-hash` stores a hash that verifies against its input and never stores the input. A value given on argv is refused. A write that would drop a name is refused. `rekey` adds a recipient that can then decrypt. The store wins over `~/.local/secrets`. A missing identity fails and names the file. No value appears in any output.
  - *Acceptance*: the tests pass, and the main loop's hash comparison matches for every moved name.

- **T2. His machine and his keys (120 min, `auth-data`, pair with T1).**
  - *Outcome*: the operator scripts run from a stock Linux Mint machine as `oliver`. BACKLOG #50 is done.
  - *ssh user*: one variable, `SERVERS_SSH_USER` (default `geoff`), replaces every hard-coded `geoff@` in `scripts/apply.sh`, `secrets/render.sh`, `scripts/ward-mail-{sort,delete}.sh`, and `scripts/mail-filters.sh`. `infra/project.env`'s `SSH_USER` follows it. The cutover-only `import-window.sh`, `imap-sweep.sh`, and `vandelay-run.sh` stay as they are, and their headers say why.
  - *Keys*: they move to `base/keys/<unix name>/<machine>.pub`. `geoff/` holds the two existing keys, and cloud-init still inlines them (`tests/base.test.sh` follows the move). After the roles run, `apply.sh` sets each existing account's `authorized_keys` to equal its directory (`geoff` and each `hosts/HOST/operators.txt` name). An account with no directory is left untouched. If `geoff`'s set would come out empty, the apply refuses.
  - *ssh errors*: `apply.sh` prints ssh's own error (an unknown host key, a refused key) in place of "needs passwordless sudo" (`apply.sh:63`).
  - *Tool list*: one list, `tools/mint-packages.txt`, that both the new gate leg `mint` and the install page read. The leg is in `scripts/check.sh`, built from `tests/mint/Containerfile`, and runs `tests/harness/run.sh` in the image. It's selected on `scripts/`, `secrets/`, `infra/`, `base/`, `tests/`, `cloudflare/*.sh`, and `tools/mint-packages.txt`.
  - *Route check*: `tests/mint/route-check.sh` is the live wrapper for T4.
  - *Test*: `tests/apply.test.sh` covers these cases. With `SERVERS_SSH_USER=oliver`, every ssh call targets `oliver@`. The key sync writes each directory's keys and leaves `oliver` alone when he has no directory. An empty `geoff` set refuses. A refused key prints ssh's message. The `mint` leg passes locally.
  - *Acceptance*: the tests and the full gate pass, and `git grep -n 'geoff@' -- scripts secrets infra` hits only the three cutover tools and comments.

- **T3. The workstation renders the servers names (90 min, `auth-data`, workstation, pair with T3b).**
  - *Outcome*: the workstation keeps working after the split.
  - *Hash tools*: the T1 hash tools go in the workstation's manifest, the Brewfile or the layered list.
  - *Files*: `scripts/secrets/sync.sh` and `scripts/secrets/secret-set.sh`. Both of `~/.local/secrets`' writers render `values.age` together with `${SERVERS_STORE:-$HOME/Projects/servers/secrets/servers.age}`, so a `secret-set` can't drop the servers names. A name found in both stores fails the run. A missing servers store fails and names the path. Also `bin/.local/bin/secret-receive` (a `--servers REPO` route that pipes the dialog value into `REPO/scripts/store.sh set NAME`), `secrets/registry.md` (a pointer section for the moved names), `bluefin/SECOND-WORKSTATION.md` (clone the servers repo before the first sync), and their tests.
  - *Main loop, after the arm*: delete each moved name from the worktree's `values.age` with `secret-set.sh --delete --values <worktree>/secrets/values.age --local /run/user/1000/self-hosting/secrets-operator-runbook`. Each delete's own check refuses a drop of any other name.
  - *Test*: in the workstation tests, a merged render holds both sets, a duplicate name fails, a missing servers store fails, and a `secret-set` of an unrelated name keeps the servers names.
  - *Acceptance*: the workstation gate passes. After the deletions, the rendered overlay plus the servers worktree store hold every name the old `~/.local/secrets` held (names compared, no values).

- **T3b. Geoff's logins render from hashes (90 min, `auth-data`, pair with T3).**
  - *Outcome*: no plaintext of Geoff's own logins sits in the servers store (Brief fact 5).
  - *Stalwart*: `roles/stalwart/accounts.json` gives Geoff's entry a `secret_hash` field naming `STALWART_PASSWORD_HASH_GEOFF`, and `roles/stalwart/build-plan` sends that field's value when it's present, else `password` as today. `secrets/templates/ward/stalwart.env` carries the hash name in place of the plaintext name.
  - *The optional file*: a new template, `stalwart-geoff.env`, carries `STALWART_PASSWORD_GEOFF` to `/etc/servers/stalwart-geoff.env`, marked optional in `hosts/ward/secrets.txt`. `secrets/render.sh` skips an optional row whose names are unset, keeps the installed file, and prints one line saying so. `roles/mail-filters/mail-filters` and `roles/stalwart/stalwart-jmap` read the plaintext from the new file.
  - *WebDAV*: each member's htpasswd line (`WEBDAV_HTPASSWD_<NAME>`, bcrypt) renders to `/etc/webdav/<name>.htpasswd`, 0600 root. `roles/webdav/systemd/webdav@.service` loads it with `LoadCredential=htpasswd:/etc/webdav/%i.htpasswd` and runs `--htpasswd %d/htpasswd`. `RCLONE_PASS` and `RCLONE_USER` leave the env files. The golden hashes and `tests/apply.test.sh` counts follow.
  - *Main loop*: pipe each plaintext from `~/.local/secrets` into `store.sh set-hash`, without printing it. That covers Geoff's mailbox (SHA-512 crypt) and each member's WebDAV login (bcrypt).
  - *Test*: `tests/stalwart.test.sh`: the plan for Geoff carries a `$6$` secret, and the plan never holds his plaintext. `tests/render.test.sh`: an optional row with unset names keeps the installed file and prints the skip line, and a required row still refuses. `tests/webdav.test.sh`: the unit loads the credential, and no env file holds `RCLONE_PASS`. The ward drill's `.password` use stays a name lookup only.
  - *Acceptance*: tests pass, and `store.sh names` lists neither `STALWART_PASSWORD_GEOFF` nor `WEBDAV_PASSWORD_GEOFF`.

- **T4. The route proof and the vault check (60 min, `auth-data`, main loop, pair with T5).**
  - *Route proof*: make a throwaway age identity in `/dev/shm`. Make a scratch copy of the store, rekeyed to `recipients.txt` plus the throwaway, in `/dev/shm`, never committed. Then, through `tests/mint/route-check.sh` in the Mint image with Geoff's ssh agent socket mounted, run the harness, then `dry-run.sh`, `apply.sh orpheus --check`, and `apply.sh ward --check`. All three use the throwaway identity alone and `SERVERS_SSH_USER=geoff`. Shred the identity and the scratch store afterwards.
  - *Vault check*: `claude-pass vault list` shows no `Servers emergency`. `claude-pass item list` gives titles only for `Household IT` and `Workstation`, which the main loop compares with the design. Every shared household item, the restore kit included, is in `Household IT`. Geoff's mailbox password, Proton login, Floccus passphrase, Yahoo login, WebDAV login, and the age key are in `Workstation`.
  - *Test*: the route check's own refusal case: with no identity, it exits non-zero before any network call.
  - *Acceptance*: the `dry-run.sh` table has no FAIL, only the expected OWED rows. Both `--check` runs exit 0. The title list is recorded in `## Decisions`, which the docs tasks use for item names.

- **T5. The skeleton, Start here, and the emergency screens (120 min, `runner`, pair with T4).**
  - *Pages*: create every page with its headings, so the later arms fill files that don't overlap. `docs/start-here.md` (linked from the top of `README.md`), `docs/overview.md`, `docs/emergency.md`, `docs/changes.md`, `docs/upkeep.md`, `docs/accounts.md`, `docs/your-machine.md`, `docs/claude-code.md`, `docs/appendix.md`, and `docs/services/{stalwart,immich,bulwark,bookmarks,mail-filters,monitor,backups,cloudflare,proton-pass}.md`. `docs/runbook.md` is retired.
  - *Moves*: each section moves to its page. The Claude infrastructure section and the pass-history shorthand go to the appendix. `scripts/render-emergency.sh` reads `docs/emergency.md`. `scripts/check.sh`'s emergency and Vale legs follow, and Vale syncs the Microsoft package as well. `.vale.ini` applies Microsoft to every operator page and `EMERGENCY.md`, and Google to `docs/appendix.md`.
  - *Link check*: a new gate check fails on a relative link in `docs/` or `README.md` that doesn't resolve.
  - *Re-pointing*: every `docs/runbook.md` reference outside `docs/cutover-log.md` and dated plans, including `docs/monthly-review/prompt.txt` and the `mail-tend` skill. The skill is a workstation file, and the main loop edits it.
  - *Start here*: the first hour, in order (accounts, keys, alerts, next pages), and the note that until the sitting his key isn't in the store or in `base/keys/`.
  - *Emergency screens*: every stop line names the next screen or what's safe to leave, never "call Geoff". The pass adds #38's "Cloudflare or a tunnel is down" screen: direct ssh as `oliver@<host>.907.life` with his key, the two hosts' ed25519 fingerprints (read from pavilion's `known_hosts`), and the Hetzner console as the last resort. "Who to call" goes away. All of this is in the Microsoft register (`~/.claude/skills/survey/writing/editor.md`).
  - *Test*: the link check fails on a planted broken link, and the emergency render still fails on drift.
  - *Acceptance*: the full gate passes, and `git grep -n 'call Geoff\|Servers emergency\|docs/runbook.md'` hits only history.

- **T6. The overview and service pages (150 min, `ordinary`, pair with T7).**
  - *Overview*: what runs where, how a request reaches a service, how mail flows, which account holds what, and who pays. It carries four Mermaid figures, one per question in the design. It also has one paragraph each on music and on the phonebook, naming the repo that owns it; the non-household projects by name with repo links (907-life, aksailingclub-org, cairn-pub, cairn-cms, ecxc, xcathletes, and the unclear eudaimonia Worker and workstation-backup R2); and the leftovers he'll see (the fm1 to fm3 DKIM CNAMEs, `_atproto`, the expired service token, the phonebook probe and Access apps, the undeclared `music-library` bucket, and the cf-bounce records that only `tests/dns.test.sh` holds).
  - *Service pages*: what the service is, where it runs, what depends on it, and how to check, upgrade, and restore it, with official links. Each concept gets its few plain sentences where it first appears, then a vendor or Wikipedia link.
  - *Test*: each figure renders once with a pinned `@mermaid-js/mermaid-cli`, and the main loop reads each PNG. Vale and the link check pass.
  - *Acceptance*: every overview row links to its service page.

- **T7. The change pages, your machine, and Claude Code (120 min, `ordinary`, pair with T6).**
  - *`docs/changes.md`*: provision, apply, rebuild, upgrade, DNS, deploying a Worker, R2, mail filters, and bookmark members. BACKLOG #37 (the two tunnels, the three Access apps, adding or removing a person, a tunnel that is down) and #39 (the single redirects in `cloudflare/redirects/`).
  - *`docs/your-machine.md`*: the one install path on Mint (`tools/mint-packages.txt`, the pinned extras), where the identity file lives, `SERVERS_SSH_USER=oliver`, and how to rotate a secret with `store.sh`.
  - *`docs/claude-code.md`*: optional, and no other page depends on it.
  - *Test*: Vale and the link check pass.
  - *Acceptance*: each command on these pages is one T2 or T4 ran, or is marked "not run" in `## Decisions`.

- **T8. Upkeep, accounts, and the sitting checklist (120 min, `ordinary`, pair with T9).**
  - *`docs/upkeep.md`*: a checklist for every duty in `docs/monthly-review/prompt.txt` (upgrades, drills, DKIM and password rotation, R2 cleanup, the credential dry run, the yearly items). The prompt now reads the checklist and keeps only the session mechanics. The email alerts reach him at `oliver.907.life@proton.me`, and each one maps to its screen.
  - *`docs/accounts.md`*: every account (Cloudflare with the registration, Hetzner, Proton, GitHub, and the others pre-flight 5 named), with who holds access, how it's recovered, whether it bills Geoff's card, the amount, and the renewal date from the pre-flight record. Also what a Hetzner project Admin and a GitHub successor can and can't do, read from the vendors' docs; a check that each of his seats uses only his own addresses; and a reusable "Add an operator" section with Geoff's half and the new operator's half.
  - *Sitting checklist*: the PR body's `## Sitting checklist`, which the conductor commits after the merge as `self-hosting/plans/2026-10-25-operator-runbook-sitting.md`. His steps:
    1. Accept the Cloudflare and Hetzner invites and enroll two-factor for each.
    2. Accept the GitHub successor invite.
    3. Install the tools per `docs/your-machine.md`.
    4. Run `age-keygen` and save the private key in his own vault.
    5. Send his age and ssh public keys.
  - *Claude's half in the sitting*: add his recipient line and `store.sh rekey`; add `base/keys/oliver/<machine>.pub`; commit to `main`; apply both hosts. Then, from his Mint machine, he runs `dry-run.sh`, `apply.sh orpheus --check`, `apply.sh ward --check`, and `ssh oliver@orpheus.907.life`.
  - *Test*: Vale and the link check pass.
  - *Acceptance*: no row of the accounts table is blank, and an unknown says where to read it.

- **T9. The skill and the vault references (75 min, `runner`, workstation, pair with T8).**
  - *Skill*: `claude/.claude/skills/household-infra/SKILL.md` through `claude-infra`. It says what the household infrastructure is, when it matters, and which servers pages to read, and it points at the estate inventory for token scopes. It carries no copy of the infrastructure.
  - *Vault references*: re-point every "Servers emergency" to "Household IT" in `pass-count`'s default and `tests/pass-count.test.sh`, `claude-pass`'s comments and test fixtures (`tests/claude-pass.test.sh`, `tests/test_claude_block_pass.py`), `secrets/registry.md`, `bluefin/THINKPAD-PROTON.md`, `bluefin/SECOND-WORKSTATION.md`, `claude/.claude/docs/bluefin-admin.md`, `claude/.claude/docs/cloudflare-estate-inventory.md`, and the environment prose in `claude/.claude/settings.json`. `bluefin-admin.md` notes that thinkpad-x1 still owes its agent.
  - *Test*: the re-pointed tests pass, and `claude-tooling-sync lint --root <worktree>` passes.
  - *Acceptance*: the workstation gate passes, `claude-tooling-sync verify` passes after stow, and `git grep -n 'Servers emergency'` in either repo hits only history.

- **T10. The bus-day check (60 min, `ordinary`, alone).**
  - *Setup*: a fresh-context `general-purpose` agent (Opus, `medium`) gets only the servers repo at the branch head and a file listing what he holds after the sitting.
  - *Questions*:
    1. What do I do first?
    2. Where is the age key, and how do I use it?
    3. How do I renew 907.life, and when is it due?
    4. The browser terminal won't open, or a tunnel is down.
    5. Immich is down.
    6. What's on the monthly checklist?
    7. Mail isn't arriving.
    8. Cloudflare itself is down.
    9. Who bills what?
    10. How do I add a DNS record?
    11. How do I restore the photos from backup?
    12. How do I rotate a WebDAV password?
  - *Grading*: each answer must cite the page it came from. An answer fails when it depends on Claude Code, on Geoff, or on access he lacks.
  - *Fixes*: fix the pages, then rerun only the questions that failed. The loop guard is two rounds.
  - *Acceptance*: all twelve pass, with the transcript excerpt under `## Decisions`.

- **T11. Close (60 min).**
  - *Review*: one whole-branch `diff-reviewer` over both branches, then one batched fix chain that quotes the findings verbatim, then the full gate on both repos.
  - *Closeout*: the base plan's close checklist. Re-run T4's vault check if it was deferred. Mark BACKLOG #37, #38, #39, and #50 done with the PR number.
  - *Filed through `log-issue`*: the Cloudflare leftovers cleanup (the T6 list); declaring `music-library` and the cf-bounce records; and thinkpad-x1's `thinkpad-claude` agent (workstation).
  - *PR bodies*: `## Brief`, `## Before merge` (the merge order below), `## After merge`, `## Decisions`, `## Not checked`, `## Found, not done`, `## Sitting checklist`, the score, and `## STATUS lines`.

**Path**: the T1 and T2 pair at 120, the T3 and T3b pair at 90, the T4 and T5 pair at 120, the T6 and T7 pair at 150, the T8 and T9 pair at 120, T10 at 60, and T11 at 60, for 720 minutes. The task sum is 1,165.

## Before merge

1. Merge the servers PR first, so the store exists on the servers `main` that `sync.sh` reads.
2. Pull the servers checkout on pavilion and thinkpad-x1.
3. Merge the workstation PR.

The check that shows these ran: on each host, `sync.sh --local` succeeds, and `~/.local/secrets` lists every name it listed before (names only).

## After merge

The conductor runs these after Geoff approves:

1. On both hosts, outside 03:00 to 04:00 UTC, run `scripts/apply.sh orpheus --apply` and then `scripts/apply.sh ward --apply`. Then confirm over ssh that `~geoff/.ssh/authorized_keys` equals `base/keys/geoff/*.pub` on each host.
   - The `dry-run.sh webdav-` rows all pass, so every member's Floccus login works through htpasswd.
   - On ward, `sudo stalwart-jmap geoff` reads counts, so Geoff's login survives the hash.
   - The next `mail-filters-refresh.service` run ends ok.

   On a failure, take the standing answer for "After merge, Geoff's mailbox or share stops accepting his password".
2. On pavilion, run `scripts/dry-run.sh` with arguments; it shows the same rows as before the pass. Run `cloudflare/deploy.sh monitor --check`, or a monitor deploy, to confirm the Worker secrets still load from the store.
3. Stow the claude package, then run `claude-tooling-sync verify` and `check-drift`.
4. Commit the sitting checklist to initiatives, and add the sitting as STATUS's next action.
5. Tell ward-probes' conductor thread that Part B rebases onto the new pages.

## Close

The base plan's "Adapter facts for the servers repo" and its close checklist stand. The workstation PR follows the workstation gate. Both PRs go to Geoff in one packet through `conductor-servers`, per `approval-packet`.

## Later

These aren't built:

- A container image for his machine
- A tool-check command
- The Cloudflare-services takeover drill (#51)
- Moving `CF_ZT_TOKEN` and the broad token into the scheme's `ci-deploy` split
- Automated billing reads
- Ward's helpers signing in to Geoff's mailbox through the admin account, so that `stalwart-geoff.env` could go away
