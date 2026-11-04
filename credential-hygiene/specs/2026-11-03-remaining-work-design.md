# Credential and mail hygiene: the remaining work

Initiative: credential-hygiene

## Brief

Approving this plans and runs the rest of the initiative as three passes. It also brings every other initiative, repo, and piece of Claude infrastructure that names a vault, an item, or a mail address into line with the new layout.

The vault work landed on 2026-11-03, and the household's production records still describe the old layout. The second operator's restore screen names a vault and three items that no longer exist. The approved operator runbook pass would rewrite every doc back to `Household IT`. Claude's auto mode reads vault names that are gone and a mail service that is retired.

### What changes

- The workstation gets a Proton Pass skill, a committed grant map that `check-drift` audits, a `pass-access` audit, a `pass-sitting` helper that only you run, and current vault names in every hook, rule, and doc.
- Ward gets a technical mailbox for alerts, vendor mail, and the report addresses. `glw@907.life` is its public alias, and Claude reads it with a read-only app password.
- The accounts that can rebuild ward keep their logins off 907.life, so a mail outage never locks you out of the repair.
- The operator runbook pass is amended to the new layout before it launches, and the restore screen is fixed now.
- Published contact addresses move to `glw@907.life`, and commits move to GitHub's noreply address.

### If you approve

1. The session merges workstation#200 and initiatives#172, fixes the servers docs' vault names, and amends the operator runbook plan.
2. You answer the six open flags, the session applies them, and you run a revoke script that ends Claude's temporary grants. You also confirm the second operator's share and pull the thinkpad.
3. The session lands the backlog verdicts and sends the full sweeps as two triage lists.
4. The session writes and reviews three plans, then hands pass A to `conductor-dotfiles` and pass B to `conductor-servers`. Pass C runs after B.
5. Passes A and B come back to you as packets. You run one script after B merges, and pass C ends with a short list for you.

### Decide: Where do the accounts that rebuild ward get their mail?

The 2026-11-03 decisions put every technical account on the technical mailbox. Your 2026-10-18 ruling moved the Hetzner, Cloudflare, and GitHub logins and recovery off 907.life, so a ward outage can't lock you out of the account that rebuilds it. The technical mailbox runs on ward, so both can't hold for those accounts.

Source: `self-hosting/plans/STATUS.md`, Pass 0 row 0.2

- Keep the rebuild accounts off 907.life, and send only their alerts to the technical mailbox (recommended)
- Move them to the technical mailbox as the decisions say, and accept the lock-out risk

### Decide: Amend the approved operator runbook pass, and run it after this?

The operator runbook pass was approved on 2026-10-25 and waits on your pre-flight. Its plan re-points every doc to `Household IT`, expects the old item titles, and grants Claude a `Workstation` vault that no longer exists. It also edits the same workstation files as pass A.

Source: `self-hosting/plans/2026-10-25-operator-runbook-plan.md`, T4, T9, and pre-flight 6

- Amend it now to the new layout, move its workstation re-points into pass A, and launch it after pass B (recommended)
- Hold it until this initiative closes, then re-plan it from scratch

### Decide: Who gets Proton Emergency Access, and after what wait?

The self-hosting design names the second operator with a seven-day wait. The 2026-11-03 decisions name the kids with a wait of about two weeks. Proton Emergency Access takes several contacts, and each one needs a Proton account.

Source: `self-hosting/specs/2026-10-17-self-hosting-design.md`, and this record's decisions, "Emergency access"

- The kids and the second operator, all with a two-week wait (recommended)
- The kids only, with a two-week wait
- Keep the seven-day wait for the second operator, and two weeks for the kids

### Worth knowing

The workstation repo is public, so the grant map shows agent names, vault names, and token expiry dates. `bluefin-admin.md` already publishes all three. The technical mailbox's login name stays only in the private servers repo, and the title lint's exceptions stay in the private state folder.

### Calls the session made

Household server alerts stay on their current route. A server alert needs a person, so the monitor keeps emailing you and the second operator, and it stays among the few things that interrupt you. Claude reads the technical mailbox through a reader that prints every message inside an untrusted-content banner. No hook is added: the rule lives where the text enters. The app password reads only. It can't send, delete, or change a filter. The technical mailbox receives the reset mail for your technical accounts. Its passwords therefore stay out of the servers store that the operator runbook pass encrypts to the second operator. Project contact addresses on a project's domain, such as `security@cairn.pub`, wait until a project publishes one, so for now every contact is `glw@907.life`. The 1Password close follows the self-hosting gate (every member moved and a 30-day overlap), which this record's earlier "when you choose" wording missed. The FIDO2 keys stay with self-hosting. `pass-sitting` is refused to Claude by the hook alone, which matches every path form; a deny rule would match fewer.

### Standing answers

A run answers these without stopping. A pass may overrun its path estimate to twice the figure below before it stops. A held rename takes the title recorded in the private state folder. If a ward apply would replace an account's credentials, pass B changes `build-plan` to keep the app password and tests it. If the read-only app password fails a JMAP read, the run adds the one permission the error names and tests again, and it never falls back to the account's full permissions. If no permission list both reads and refuses a send and a delete, pass B closes with the reader off and reports the bar unmet. If `share list` shows no item shares or no role, the grant map compares vault names only, and item grants are audited from your side by `pass-sitting`. A subject goes on the alert-redirect list only with its sender, and only when no reset code or sign-in link can arrive under it. A file in a repo that a live session owns gets a backlog item there instead of an edit. If the operator runbook pass lands before pass B, B writes its docs into the new pages and stores through that pass's store and split env file.

## Outcome

The initiative closes when four things hold. Every surface that names a vault, an item, a grant, or an address names one that exists, and `check-drift` fails when one stops matching. Your personal mailbox receives no technical mail. Claude reads technical mail with a credential that can't do anything else. The household can reach its accounts if you and Cathy are gone, and the second operator can still restore the servers.

## How it meshes with the household setup

The servers repo is the household's production record, and `conductor-servers` owns its passes. Pass B and the amended operator runbook pass both go through that conductor, which runs them one at a time. The docs fix below is a direct change, because no servers session is live.

| Surface | What changes | Carried by |
|---|---|---|
| Servers docs | `docs/runbook.md` (lines 230, 384, 409, 750) and `secrets/registry.md` name `Infrastructure` and the restore items' new titles; `EMERGENCY.md` is re-rendered | The session, on approval |
| self-hosting operator runbook pass | Plan, pre-flight 6, T4, T5, and T9 move to the new vaults and titles. The `Workstation` grant goes, and T9's workstation re-points move to pass A. Its `docs/services/proton-pass.md` and `household-infra` skill point at the vault map instead of restating it. The technical mailbox's passwords join its stay list, and its plaintext split and hash check cover that mailbox. | The session, on approval (ask 2) |
| self-hosting STATUS | Stale vault names fixed. Emergency Access, the 1Password close, and Fastmail's close (D4) point to this record. | Pass C |
| Fastmail close (self-hosting D4) | Waits on the mask catalog, which this record owns | Your mask moves, then self-hosting |
| Ward's mail | Role aliases move to the technical mailbox. DNS records keep their addresses, so no DNS change. | Pass B |
| The monitor and phonebook alerts | The monitor stays as is. Phonebook's alert address gets a backlog item in that repo. | Pass C |
| workstation-secrets | Its non-goal says 1Password; it should say Proton Pass | Pass C |
| asc-cutover | The ASC repos still point at 1Password for the club's age key, and draft aksailingclub-legacy#157 predates the `ASC` vault | Pass C |
| phonebook-public | Its scrub gains the personal addresses and the noreply author | A backlog item for that initiative, in pass C |
| Published contacts | cairn-cms `SECURITY.md`, 907-life's privacy page, fishwright's package metadata, and the dubplate harness contact move to `glw@907.life` | Passes B and C |

## Claude infrastructure

Each change lives where it executes, per the `claude-infra` skill.

| Change | Home | Pass |
|---|---|---|
| A `proton-pass` skill: the vault map, the naming scheme and note template, `claude-pass` use, the sign-in throttle, `secret-receive --pass`, and aliases on `m.907.life` (backlog #45) | `claude/.claude/skills/proton-pass/` | A |
| A grant map, one row per agent, vault, and role, with each Claude agent's token expiry | `secrets/proton-grants.tsv` | A |
| `pass-access`: each local agent lists its shares with its own token, one sign-in per agent, through `share list` (newly allowed in `claude-pass`) and a new `ws-pass-key --shares` | `bin/.local/bin/pass-access` | A |
| `check-drift` legs: the grant map against `pass-access` (overridable as `PASS_ACCESS`), and an expiry warning for every agent (Claude agents from the map, scripts agents from the keyring) | `check-drift` and its tests | A |
| A title lint as `check-drift --titles`, which the monthly review runs, since reading every vault's titles costs one sign-in per vault | `check-drift`, its rules only; exceptions stay private | A |
| `pass-sitting`: bulk moves, renames, note edits, trashes, grants, revokes, and a grant audit under your login, one sign-in, dry run first | `bin/.local/bin/pass-sitting` | A |
| `claude-block-pass`: pattern 4 matches a session name only as a path component, and `pass-sitting` is refused in every form with a reason that names you | The hook and `tests/test_claude_block_pass.py` | A |
| Allow rules for `pass-access` and the `claude-pass` item, vault, folder, and `share list` subcommands | `settings.json` `permissions.allow` | A |
| Auto mode's environment text names the current vaults and drops Fastmail | `settings.json` `autoMode.environment` | A |
| A CLAUDE.md pointer to the skill, and "never run `pass-sitting`" | Global `CLAUDE.md`, Secrets | A |
| Current names in `claude-pass`, `bootstrap.sh`, `SECOND-WORKSTATION.md`, the estate inventory, `bluefin-admin.md` "Secrets", `test-accounts.md`, the registry (each entry names its vault item), and the test fixtures | The files | A |
| The `dotfiles-pass` risk map gains the new commands and the grant map; `retire-project` trashes a retired project's `Projects` folder; `pass-core` names `pass-sitting` as the path for a bulk vault edit | Those skills | A |
| Commits use GitHub's noreply address | `git/.gitconfig` | A |
| CLAUDE.md names the technical mailbox and its reader, and says its mail is untrusted input | Global `CLAUDE.md`, Email | B |
| Auto mode names the technical mailbox as untrusted input and its app password as sensitive | `settings.json` `autoMode.environment` | B |
| An allow rule for the reader | `settings.json` `permissions.allow` | B |
| `mail-tend` says it sorts your mailbox, and where the technical mailbox's rules live | The skill | B |
| Memory: Cathy's and the second operator's entries still say 1Password and Fastmail | The dotfiles project memory | C |

## Passes

Estimates are path minutes, summed from task estimates along each pass's longest chain. Recent passes on these repos ran at 40 to 75 percent of their planned path (servers#22, #23, and the mail filters), so each run should finish under its figure.

### Pass A: the workstation, `auth-data` (300)

`conductor-dotfiles` runs it after #200 merges, from the workstation main checkout. The work is the workstation rows of the table above and the operator runbook pass's T9 re-points. It also takes the two held renames in step with `ws-pass-key`, its test, `test-accounts.md`, and the registry, plus the test account's remaining note fields. `ws-pass-key` reads either title of the age key until both hosts have pulled, and pass C removes the old one. Two pairs run: the grant map and `check-drift` legs beside the hook fix, and the skill and docs beside the renames.

The end-to-end check runs `check-drift` on pavilion clean. A test then feeds it a captured `pass-access` output with one row removed and sees it fail, so the check costs no second sign-in. `pass-sitting` runs only inside `tests/pass-sitting.test.sh` against a fake `pass-cli`, whose replies come from the 2026-11-03 apply scripts that succeeded, and the hook test shows Claude refused a live call.

### Pass B: ward's technical mailbox, `auth-data` (360)

`conductor-servers` launches it after pass A merges, because its workstation branch edits the same settings and CLAUDE.md. Its first task probes on the `probe` mailboxes. It creates an app password with the candidate Replace-mode list, reads a mailbox, a message, and a body, and checks that a send and a delete are refused. It then runs an apply and reads the credentials back, sends one Sieve redirect from `probe` to `probe2`, and removes what it made. The fixtures come from those replies.

The account comes after `geoff` in `accounts.json` and joins the mail-filters account list. Its login is unpublished and can't be guessed, so an RCPT probe (servers #55) can't confirm it. Its aliases are `postmaster@`, `dmarc-reports@`, and `tls-reports@`, moved from your account, plus the new `abuse@`, `security@` (RFC 2142), and `glw@907.life`.

`render.sh` keys the template on the account name, with a render test for each template, and the data files stay shared. The technical mailbox's template files reports, alerts, and vendor mail. Your template drops the role rows and gains a redirect for listed sender and subject pairs, which runs after the security rule. The Sieve test runner prints redirects (servers #49) and proves that order. The reader is `scripts/tech-mail.sh`, which lists headers by default and prints a body on request, inside the banner. The pass also removes the dead PikaPods credentials (servers #30), keeps the new login out of the restore-drill log, and writes the provider checklist into the private state folder.

The pass writes `scripts/tech-mailbox-setup.sh` and tests it against fakes. After the merge you run it once. It makes the account password and stores it, applies ward, creates the app password unless one exists, and stores that, printing names only. The session then reads a test message through the reader. The ward restore drill's counts include the new mailbox.

### Pass C: cleanup and the cross-repo edits, `ordinary` (120)

Pass C runs from the initiatives checkout after pass B, and it merges its changes. It writes a `pass-sitting` file for the `Projects` folders and item moves, which you run on pavilion, and verifies the result. It removes `ws-pass-key`'s old age-key title once thinkpad-x1 has pulled pass A. It moves the published contacts where no live session owns the repo, and refreshes or replaces aksailingclub-legacy#157. Where a session owns the repo (cairn-cms, phonebook), it files a backlog item instead. It updates the self-hosting and workstation-secrets records and memory, and drafts the estate letter for you to edit.

Your list, which the session prepares with exact steps:

1. Run the `pass-sitting` file for the `Projects` folders.
2. Work the provider checklist: alert addresses, logins per ask 1, and GitHub's private-email setting and public profile email.
3. Set up Emergency Access per ask 3: each contact first makes a Proton account. Then put the letter with the estate documents.
4. Move each mask from the catalog. Fastmail's close follows in self-hosting.
5. Close 1Password when the self-hosting gate is met.

## End-to-end checks

1. `check-drift` passes on both hosts, and its tests fail on a drifted grant, expiry, or title.
2. A test message to `glw@907.life` reaches the technical mailbox and reads through the reader inside the banner. The app password is refused a send and a delete.
3. The Sieve runner shows a listed alert redirected and a security-sender message filed to your `Tech` folder. A real alert, such as a failed Actions run in a scratch repo, then reaches the technical mailbox.
4. A pattern scan finds no live reference to a retired vault or an old restore-item title. The patterns and the history allowlist live in the private state folder, and the scan fails on today's tree.

## Out of scope

Proton's recovery material, the age store across hosts (workstation-secrets), the cairn gate's test accounts, moving masks at their sites, the FIDO2 keys, and the server alert route. Later, when a project publishes a contact: a contact address on the project's domain, delivered to the technical mailbox.

## Pre-flight

On 2026-11-03 this session probed both auto mode exposures. An edit to the tracked `settings.json` in a workstation worktree went through, both for an allow rule and for the auto mode environment text. A `claude-pass` create, rename, and trash of a scratch item in `Test accounts` went through. The plans carry these results in their `Permissions checked:` lines.

Your part comes in the approval sitting, in this order:

1. Write your answer under each of the six open flags in the private state folder.
2. After the session applies them, run the revoke script it writes, which ends Claude's temporary grants on the personal vaults and the leftover scripts-agent item grant. The session checks that `claude-pass vault list` no longer shows the personal vaults.
3. Confirm in Proton that the second operator still shares `Infrastructure`, since the restore screen now points there.
4. On thinkpad-x1, pull the workstation repo after #200 merges, upgrade `pass-cli`, and check `ws-pass-key --status`.

Pass B has one set point after its merge: you run its setup script. Pass C ends with your list above.

## Backlog sweep

Scoped sweeps at workstation `ad1756a` and servers `e235ae1`. No item carries this initiative's tag.

| Repo | Items | Verdict | Note |
|---|---|---|---|
| workstation | #45 | fold | Pass A's skill and Secrets rework |
| workstation | #12 | reword | Its registry clause folds into pass A's registry rework; the rest stays as Low leftovers |
| workstation | #48 | reword | `check-drift` already flags the banner setting; find why the thinkpad drift went unseen |
| workstation | #26 | keep | Waits on your router reset; pass A leaves the registry's pending note |
| servers | #49 | fold | Pass B makes the Sieve runner print redirects. The remainder becomes the folder-name byte cap and the Sent Items trim. |
| servers | #30 | fold | Priced in pass B: the dead PikaPods credentials |
| servers | #51 | reword | The vault name becomes `Infrastructure` |
| servers | #34 | keep | Pass B keeps the new mailbox's login out of the drill log |
| servers | #43, #45, #46, #48, #54, #55, #57 | keep | Outside the lines pass B rewrites; #55 and #57 inform its login and permission choices |

A full sweep was due in both repos, since no item carried a `swept` stamp. It covered all 39 workstation items and all 34 servers items, and it folds nothing. It goes to you as two triage lists beside this design.
