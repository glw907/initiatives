# One front door for household IT

Initiative: `self-hosting`. Repos: `servers` (renamed here to `household-it`) and `workstation`.
Round in the renamed repo: `runbook-map`, two passes. One further pass runs in `workstation`.

Status: approved by Geoff on 2026-11-13 (Approval Queue item 20261113-230244-df1beb). The rename ran the same day: the repo is `glw907/household-it` at `~/Projects/household-it`, with a link at `~/Projects/servers`.

## Brief

This work renames the `servers` repo to `household-it`, splits its 819-line runbook into one page per system, and makes `README.md` the table of contents for every page. It then teaches Claude's tooling the new layout, so a session in any repo can find a household fact in two steps. Approving it approves a rename I run that day, two unattended passes in the renamed repo, and one pass in the workstation repo that ends with a short command for you.

Today the repo's README describes only the test gate. Everything else sits in `docs/runbook.md`, which mixes emergency screens, operator tasks, vendor links, and Claude's permission notes. GitHub, Proton, and the home network have no page at all. Twelve files in the workstation repo, 42 lines in all, point at the repo by its old name or path.

No pass here writes new operational content. Existing text moves to its new home, and each gap gets a stub that names what is missing. The operator pass you approved on 2026-10-25 fills the gaps afterward, writing into these pages.

### What changes

- The repo is `glw907/household-it` on GitHub and `~/Projects/household-it` on disk. Names already deployed keep the word `servers`: `/opt/servers` and `/var/lib/servers` on the hosts, the `servers-backup` and `servers-archive` buckets, the `servers-backup` unit, and the token names.
- `README.md` holds a table of the twelve systems, a list of jobs phrased as "I need to...", a list of failures, and a link to every other page in the repo. A page that the README does not link fails the gate.
- Each system has one page in `docs/systems/` with the same seven headings in the same order.
- `EMERGENCY.md` stays at the root and stays generated. Its screens move to the "When it breaks" section of each system page, and the rendered file reads the same as today, screen for screen.
- `docs/contributing.md` states where a file goes and how it is named, and carries a blank system page to copy.
- A new gate leg, `docs`, fails on a misplaced file, a bad name, a missing or misordered heading, an unlinked page, or a dead internal link.
- The repo gains a short `CLAUDE.md`. The workstation gains one `runbook` skill, which replaces the `household-infra` skill of the October design. Both point at the README and hold no facts.
- The workstation's skills, docs, scripts, secret registry, and one systemd unit name the new repo and its pages.

### If you approve

1. I clear the leftover worktrees in the repo, rename it on GitHub, move the folder, and leave a link at the old path. "The rename" below has every command. Nothing else changes that day, and old links and paths keep working.
2. I commit the plans' launch prompts and start the round. Pass 1 splits the runbook and rebuilds the README. Pass 2 adds the gate leg, the contributing page, and the repo's `CLAUDE.md`. Each lands on a green gate and an accepted review, with no packet.
3. The workstation pass follows. Its pull request changes `CLAUDE.md`. The new skill and three settings lines go live only through commands a session can't run, so it comes to you as one merge packet with one command block.
4. You get a report when the round ends.
5. The operator pass is then re-planned against the new pages and launches once its remaining pre-flight items pass.

### Decide: Whether the operator pass waits for this work

The operator pass is approved and has not launched. It waits on your billing facts and on its permission rules. Its design says the builder decides the file split, and it carries a `household-infra` skill. If it ran first, it would write its pages into the old layout and this work would move them a week later.

Source: `specs/2026-10-25-operator-runbook-design.md`, "The docs" and "The skill"; `plans/2026-10-25-operator-runbook-preflight.md`

- Run this work first. Amend the operator pass: its pages are the system pages here plus its start-here, overview, and accounts pages, and its skill is dropped because the `runbook` skill covers it (recommended)
- Run the operator pass first as approved, and reorganize after it lands

Ruled: Run this work first (Geoff, 2026-11-13, in the queue). The operator pass is amended as the first option says, and is re-planned after this work lands.

### Decide: Whether to remove the leftover worktrees

The repo holds 56 leftover worktrees and 57 local branches from earlier passes. A folder move breaks each worktree's link to the repo, and the clutter is why the busy check reads this repo as busy today. Fifty-five sit on branches already merged into `main`. Thirteen of those hold an untracked scratch file: a `scripts/__pycache__/` folder or a commit-message draft. The one unmerged branch is the open November review, which stays.

Source: `git worktree list` and `git branch --merged origin/main` in `~/Projects/servers`, 2026-11-13 ("Leftover worktrees" below lists the thirteen)

- Remove the 55 merged worktrees and every merged branch, scratch files included, and keep the November review (recommended)
- Remove only the 42 clean ones, and leave the thirteen for you to look at

Ruled: Remove all 55 (Geoff, 2026-11-13, in the queue). Done: the repo holds its main checkout and the November review's worktree.

### Worth knowing

The initiatives repo is public, so this record names the second operator by role only. The two pages a person in the household reads, `EMERGENCY.md` and the phone guide, keep their words. Only their paths and the links into them change.

## Who it is for

Three readers, in the order the layout serves them.

- **The second operator**, on a day you can't be reached. He opens the repo on GitHub and sees the README. He needs the emergency screens first and an overview second.
- **A Claude session in another repo**: cairn asking for a DNS record, the phonebook asking how mail reaches ward. It needs the right page in two steps, without reading 800 lines.
- **A Claude session that has just changed a system** and must record it. It needs to know which page, which heading, and what the gate will check.

Your goal for the first is unchanged from October. Your instruction for the other two, on 2026-11-13: "I'm trusting you to develop a system that will allow agents to find what they need quickly. And this effort needs to be well-reflected across all of our claude infrastructure."

## Scope

Your ruling of 2026-10-25 holds: the runbook covers household services only.

In scope:

- The twelve systems in the table below.
- Account-level facts for Cloudflare and GitHub: who owns the account, how sign-in and two-factor work, where the recovery codes are, and what it bills. The pages get the headings now and the facts from the operator pass.
- One line each for the club sites, the cairn sites, the phonebook, and dubplate, naming the repo that documents them.
- Every reference to the repo's name or path in the workstation's live tooling and in the live files of the initiatives repo. The phonebook and dubplate repos name it only in dated files.

Out of scope:

- New operational content. Backlog items #37, #38, #39, #50, and #51 keep their place with the operator pass.
- Deployed names that contain `servers`.
- Dated plans, specs, research notes, and logs in any repo. They keep the old name, because they record what was true that day. GitHub redirects their links.
- The Microsoft register for operator pages, the Mermaid figures, access grants, script portability, and the upkeep checklists. All belong to the operator pass.
- A hook. The gate leg catches what a hook would, without firing on edits that need no doc.

Anti-goals: a second map that can drift from the README, a skill that copies facts, and a rename that leaves a session prompting for a path it used to reach.

## The layout

### Where a file goes

| Path | Holds | Name |
| --- | --- | --- |
| `README.md` | The table of contents | fixed |
| `EMERGENCY.md` | The generated emergency screens | fixed |
| `BACKLOG.md`, `CLAUDE.md` | The backlog; rules for a Claude session in the repo | fixed |
| `docs/systems/<system>.md` | One system, seven headings | the system's name |
| `docs/guides/<topic>.md` | A how-to guide for one reader or one job that crosses systems, such as the phone guide | the topic |
| `docs/reference/<table>.md` | A table people look things up in: addresses, accounts, secrets, decisions | the table |
| `docs/records/<date>-<topic>.md` | A dated record, never rewritten after its day | `YYYY-MM-DD-` and the topic |
| `docs/prompts/<name>.txt` | A launch prompt a session is started from | the job |
| `docs/contributing.md` | The rules on this page, and the gate | fixed |

Names are lowercase with hyphens. A living page has no date in its name, and a record always has one. A log that grows by dated entries, such as the restore-drill log, is a living page in `docs/reference/`.

Nothing else sits in `docs/`, and the four fixed files are the only Markdown at the root. A `README.md` beside code, such as `cloudflare/monitor/README.md`, stays where it is and is linked from its system page.

### The twelve systems

| Page | Covers | Code |
| --- | --- | --- |
| `servers.md` | orpheus and ward: Hetzner, Debian, Docker, Caddy, provision, apply, rebuild | `base/`, `hosts/`, `infra/`, `roles/caddy/`, `roles/dubplate-host/` |
| `mail.md` | Stalwart on ward, filters, the technical mailbox, Bulwark webmail, the MX switch | `roles/stalwart/`, `roles/mail-filters/`, `roles/bulwark/` |
| `photos.md` | Immich on orpheus | `roles/immich/` |
| `bookmarks.md` | The bookmark share and its sync | `roles/webdav/` |
| `backups.md` | Nightly backups, R2 buckets and locks, the archive, restore, the drill | `roles/backup/`, `roles/mail-backup/` |
| `cloudflare.md` | The account, the zone, DNS, redirects, Workers, Access, the tunnels | `cloudflare/`, `roles/cloudflared/` |
| `monitoring.md` | The monitor Worker, the host health checks, alert mail, the workstation popups | `cloudflare/monitor/`, `roles/health/` |
| `telephony.md` | voip.ms and the two Yealink phones | none |
| `network.md` | The home router. A stub | none |
| `github.md` | The account, this repo, the successor. A stub | `.github/` |
| `proton.md` | Proton Pass vaults, the alias domains, Emergency Access. A stub | none |
| `workstations.md` | Three paragraphs and a link to the `workstation` repo | none |

A page is named for what the household calls the system, never for a code folder. Its name matches its README row. Every folder under `roles/` appears in the Code column of exactly one page, and `roles/dubplate-host/` gets one line on `servers.md` that points to the dubplate repo.

### The seven headings

Every system page has these `##` headings, in this order, and no others at that level.

1. **What it is.** Two or three sentences, and the one-line pointers to other repos where they apply.
2. **Where it lives.** Hosts, addresses, accounts, and the code folder.
3. **Access.** Who can get in and how, with each credential by its store name and its Proton Pass item name. Never a value.
4. **Routine jobs.** Each job is a `###` heading that starts with a verb: "Deploy a Worker".
5. **When it breaks.** Each failure is a `###` heading that states what the reader sees or needs: "A server is gone", "Callers report bad audio". The ones written for the second operator also render into `EMERGENCY.md`.
6. **What watches it.** The checks, the alerts, and where each alert arrives.
7. **Vendor docs.** The links, which `scripts/check-links.sh` reads.

A section with nothing to say yet holds one line: `Not written yet.` and the backlog item that will fill it. The gate accepts that line and rejects an empty section. Pass 1 cites an open item where one covers the gap and files one where none does, which today means GitHub, Proton, and the network.

One fact has one home. A page that needs a fact from another page links to its heading. The credentials table and "Secrets this pass adds" merge into `docs/reference/secrets.md`, and each page's "Access" section links to its rows. Claude's permission rules move to the repo's `CLAUDE.md`.

### The README

The README opens with one sentence on what the repo is and one line sending a reader with a problem to `EMERGENCY.md`. Then:

- **Systems.** The table above, each name a link, with a third column that says in a few words what the system does for the household.
- **I need to...** A list of jobs, each a link to a heading: restore a server, add a mail filter, add a DNS record, deploy a Worker, rotate a token, add a phone. It takes every `###` under "Routine jobs".
- **Something is wrong.** The same for every `###` under "When it breaks".
- **Everything else.** The guides, the reference tables, the records, and the prompts, one link each, and `docs/contributing.md`.

The gate description that fills the README today moves to `docs/contributing.md`.

### Where today's files go

| Today | After |
| --- | --- |
| `docs/runbook.md`, "Emergency screens" | "When it breaks" on `servers.md`, `mail.md`, and `backups.md` |
| `docs/runbook.md`, "Operator guide" | "Routine jobs" on the page of each section's system, and "When it breaks" for the parts that answer a failure |
| `docs/runbook.md`, "Service catalog" | "Vendor docs" on each page |
| `docs/runbook.md`, "Claude infrastructure" | `CLAUDE.md` for the permission notes, `docs/reference/secrets.md` for the tables, `cloudflare.md` for token rotation |
| `docs/addresses.md`, `docs/decisions.md` | `docs/reference/` |
| `secrets/registry.md` | Stays beside the store code it describes. `docs/reference/secrets.md` links to it |
| `docs/phonebook.md` | `docs/guides/phonebook-operations.md`, linked from `telephony.md` and `cloudflare.md` |
| `docs/cutover-log.md` | `docs/records/`, under the date of its last entry |
| `docs/restore-drill-log.md` | `docs/reference/restore-drill-log.md` |
| `docs/monthly-review/log.md` | `docs/reference/monthly-review-log.md` |
| `docs/household/phones.md`, `linux-mail-client.md` | `docs/guides/` |
| `docs/household/2026-11-13-phone-audio-investigation.md` | `docs/records/` |
| `docs/household/router-setup-prompt.txt` | `docs/prompts/router-setup.txt` |
| `docs/monthly-review/prompt.txt` | `docs/prompts/monthly-review.txt` |

The phonebook guide is 432 lines on running the phonebook Worker, written for you and Claude. It stays in this repo for now, unchanged. Pass 1 files a backlog item that asks whether it belongs in the phonebook repo.

The operator pass's three extra pages have homes here too: its start-here and overview pages go in `docs/guides/`, and its accounts page is `docs/reference/accounts.md`.

### How `EMERGENCY.md` is built

Today `scripts/render-emergency.sh` copies one section of the runbook. After pass 1 it reads `scripts/emergency-screens.txt`, a list of screens in order, each a page and a heading. It prints the same title and opening paragraph as today, then each listed screen from its system page.

The list holds the 9 screens the file has now, in the same order, so the rendered file differs from today's in one line: the sentence that names its source. Lines such as "check Stalwart above" and "the person named on the last screen" stay true. A failure procedure that isn't on the list, such as "Callers report bad audio", stays on its system page and out of `EMERGENCY.md`.

The gate's `emergency` leg still fails when the file and the render differ. It runs on a change to any system page or to the list, and it fails when the list names a heading that doesn't exist.

## How an agent finds things

Four layers, each with one job.

1. **The README is the only map.** No other file is a table of contents.
2. **The repo's `CLAUDE.md`** loads for a session inside the repo. It says: start at the README; a change to a system updates that system's page in the same pull request; follow `docs/contributing.md`; run `bash scripts/check.sh`. It also holds the permission notes from the old runbook, which pass 1 moves there. It has no table of systems.
3. **The `runbook` skill** loads in any repo on this workstation. Its description names two moments. One is a question about household infrastructure: a DNS record, a mail route, a server, a backup, a phone, an account. The other is a session that has changed one of those systems or was asked to document it. Its body gives the repo's path, says to read the README and follow its links, and for a change points at `docs/contributing.md` and the gate. It names no host, address, or credential.
4. **The `docs` gate leg** catches a page the first three missed.

The skills that hold procedures keep them. `mail-tend`, `vps-conventions`, `proton-pass`, and `maintenance-mode` change only their links, which now go to a system page and heading. The global `CLAUDE.md` swaps its two lines about `~/Projects/servers` for the new path and one clause naming the skill.

`~/.claude/docs/cloudflare-estate-inventory.md` keeps the workstation-only Cloudflare facts, and `cloudflare.md` links to it by path.

## The rename

The rename runs first and alone, because every later step then uses one name. Two facts make it safe by itself.

GitHub redirects the old name. Its documentation says: "all `git clone`, `git fetch`, or `git push` operations targeting the previous location will continue to function as if made on the new location", and warns against reusing the old name for a new repo, which would end the redirect.

A link at `~/Projects/servers` that points to the new folder keeps every old path working, the two permission rules included.

The commands are in `self-hosting/tools/rename-to-household-it.sh`. Run bare, it prints each command and changes nothing. The session that acts on your approval runs it from `~/Projects/initiatives` with `--run`, and with `--remove-scratch` if you choose the first worktree option. It stops at the first command that fails.

1. **It checks first.** Nobody is in the repo (`claude-worktree-busy`), the main checkout is on `main` with no uncommitted change, and it is level with GitHub.
2. **It clears the leftover worktrees.** A worktree goes only when its commit is already in `origin/main` and it has no change to a tracked file. `git branch -d` then removes each merged branch and refuses an unmerged one.
3. **It renames.** `gh repo rename household-it`, `git remote set-url`, `mv` the folder, `ln -s` at the old path, and `git worktree repair` with the November review's path.
4. **It copies Claude's memory for the repo** to the new project key. Session history stays under the old key.
5. **It edits the `repos:` line** of five initiative records, whose check reads `gh repo list`.
6. **It checks the result.** `gh repo view glw907/household-it` answers. `git ls-remote` on the old address answers through the redirect. The collaborator count is still 2, and the November review's pull request is still open.

The print-only run on 2026-11-13 ended with these lines, after 42 `worktree remove` lines and the branch deletions:

```text
worktrees: 42 to remove, 13 kept, plus the November review
+ gh repo rename household-it --repo glw907/servers --yes
+ git -C ~/Projects/servers remote set-url origin https://github.com/glw907/household-it.git
+ mv ~/Projects/servers ~/Projects/household-it
+ ln -s household-it ~/Projects/servers
+ git -C ~/Projects/household-it worktree repair ~/Projects/servers/.claude/worktrees/servers-review-2026-11
+ mkdir -p ~/.claude/projects/-var-home-glw907-Projects-household-it
+ cp -r ~/.claude/projects/-var-home-glw907-Projects-servers/memory ~/.claude/projects/-var-home-glw907-Projects-household-it/
+ sed -i -E '/^repos:/s/\bservers\b/household-it/' <five initiative.yaml files>
dry run: nothing changed
```

After the script, the same session adds one line on the rename to `self-hosting/plans/STATUS.md`. The other lines in the two STATUS files that name the repo are dated history and stay. `907-rebuild/tools/automode-allow.py:17` holds the text of the auto-mode rule, so pass 3's command block changes it together with `settings.json`. It runs `scripts/index` and `scripts/check`, then `bash scripts/check.sh` in the new folder, and commits.

To undo the rename, run `gh repo rename servers --repo glw907/household-it`, remove the link, move the folder back, and reset the remote.

The laptop has a separate clone. Step 3 less the `gh` line, and step 4, run there in the first session that opens on it. The workstation pass adds that note to the workstation's STATUS.

## Passes

| Pass | Repo | Outcome | Files | Class | Path minutes | Depends on |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `pages` | household-it | The runbook split into twelve system pages, every other doc in its folder, the README as the table of contents, `EMERGENCY.md` rendered from the pages, and the old name gone from living files | `README.md`, `EMERGENCY.md`, `CLAUDE.md` (new, permission notes only), `docs/**`, `scripts/render-emergency.sh`, `scripts/emergency-screens.txt` (new), `scripts/check-links.sh`, `scripts/check.sh` (the leg table), `scripts/restore-drill.sh`, `scripts/drill-remote.sh`, `tests/check.test.sh`, `tests/stalwart.test.sh`, `.gitignore`, `.claude/project-tracking.json`, `BACKLOG.md` | ordinary | 270 | the rename |
| 2 `gate` | household-it | The `docs` leg and its tests, `docs/contributing.md` with the blank page, and the rules in the repo's `CLAUDE.md` | `scripts/check-docs.sh` (new), `scripts/check.sh`, `tests/check-docs.test.sh` (new), `tests/check.test.sh`, `docs/contributing.md`, `CLAUDE.md`, `README.md` | ordinary | 150 | 1 |
| 3 `agents` | workstation | The `runbook` skill, and every live reference moved to the new name and pages | `claude/.claude/CLAUDE.md`, `claude/.claude/skills/{runbook,mail-tend,maintenance-mode,proton-pass,vps-conventions}/**`, `claude/.claude/docs/**`, `secrets/registry.md`, `systemd/.config/systemd/user/monitor-subscribe.service`, `bluefin/Brewfile`, `docs/model-review/prompt.txt`, `BACKLOG.md` | runner | 150 | 2 |

Passes 1 and 2 are the round `runbook-map`, and they share `README.md`, `CLAUDE.md`, `scripts/check.sh`, and `tests/check.test.sh`. Merge order is 1, then 2. The chain is 420 path minutes. Pass 3 is a one-pass round in the workstation repo, launched after pass 2 lands, and its pull request waits for you.

Pass 1 runs first for the reason `round.md` gives: it rests on the least-proven assumption, that 819 lines sort into twelve pages and seven headings with nothing left over.

The estimates come from the servers backlog second batch, which took 495 path minutes against 470 planned for work of similar breadth. Pass 1 is a little over half of it: text moves and seven small script and test edits.

### Acceptance

Every pass: the repo's gate passes (`bash scripts/check.sh` in household-it, `bash scripts/gate.sh` in workstation).

Pass 1, `pages`:

1. `ls docs/systems` prints exactly the twelve file names in "The twelve systems", and `docs/runbook.md` doesn't exist.
2. `grep -n '^## ' docs/systems/<page>.md` prints the seven headings in order, for each page, and nothing else.
3. No sentence is lost. A script in the pull request takes each line of `docs/runbook.md` at the base commit that holds prose: not blank, not a heading, not a code-fence marker, not a table rule. It prints each one that matches no whole line in `README.md`, `CLAUDE.md`, or a file under `docs/`. The pull request lists every printed line with its reason under "Lines changed in the move". A line printed and not listed fails the item.
4. Every section lands on the right page. The pull request carries a table with one row for each `##` and `###` heading of the old runbook: the page and heading it moved to. The whole-branch reviewer checks each row against "Where today's files go" and "The twelve systems".
5. Every other moved file is unchanged apart from links and the repo's name: `git diff -M --stat main...HEAD` shows each as a rename, and the pull request quotes the changed lines of any below 100%.
6. `git diff main...HEAD -- EMERGENCY.md` shows one changed line, the sentence that names the file's source. `scripts/render-emergency.sh | diff - EMERGENCY.md` prints nothing.
7. Every file under `docs/` appears as a link target in `README.md`. Every link in `README.md` resolves to a file and, where it names one, a heading in that file. Every `###` under "Routine jobs" and "When it breaks" is a README link. A script in the pull request checks all three and prints nothing.
8. `scripts/check-links.sh` checks the same set of addresses as at the base commit: the sorted lists match.
9. The README's title is `# Household IT`. `grep -rnwE 'servers' README.md CLAUDE.md docs --exclude-dir=records` prints only lines that mean the two machines or a deployed name, and the pull request lists each. In `BACKLOG.md` the open items that cite `docs/runbook.md`, `docs/addresses.md`, or `docs/decisions.md` (#66, #60, #55) cite the new path.
10. A fresh Sonnet reader, given the repo and no other context, answers the ten questions under "The finding test". The plan holds an answer key, written from the runbook at the base commit before any text moves. Each answer names the page and heading it came from and matches the key, and the reader opens at most two files after the README. A question whose page is a stub is answered with "not written yet" and the backlog item.
11. `git diff --stat main...HEAD` lists no file under `base/`, `cloudflare/`, `hosts/`, `infra/`, `privacy/`, `roles/`, `secrets/`, or `tools/`.

Pass 2, `gate`:

1. `bash scripts/check.sh --leg docs` passes on the branch. A test plants each of these faults in a copy of the tree, one at a time, and the leg fails on each and names the file:
   - a page in `docs/` outside the five folders, other than `contributing.md`
   - a Markdown file at the root other than the four fixed ones
   - a name with a capital letter or a `_`
   - a record without a date, and a living page with one
   - a system page missing a heading, one with two headings swapped, and one with an eighth `##` heading
   - a section with nothing under its heading
   - a `docs/` page the README doesn't link, and a system page with no README row
   - a README link to a missing file, and a relative link to a missing heading
   - a `roles/` folder that no system page names
2. The leg ignores a `## ` line inside a code fence: a test shows `docs/contributing.md`, with the blank page in a fence, passes.
3. A test copies the blank page from `docs/contributing.md` to `docs/systems/printing.md`, adds the README row, and the leg passes.
4. A fresh Sonnet session in a worktree cut for the test, given the repo and the one instruction "add a page for the household printer", produces a branch on which the gate passes. The page is in `docs/systems/`, has a README row and seven headings, and states no fact the instruction didn't give: each section holds `Not written yet.` or words from the instruction.
5. `CLAUDE.md` is 40 lines or fewer, and `grep -c 'docs/systems' CLAUDE.md` prints 0.
6. `README.md` no longer describes the gate's legs, and `docs/contributing.md` does.
7. `tests/check.test.sh` shows that a change to a system page plans the `vale`, `emergency`, and `docs` legs, and that a change to `README.md` or `scripts/emergency-screens.txt` plans the `docs` and `emergency` legs.

Pass 3, `agents`:

1. `grep -rnE 'servers repo|servers/scripts|Projects/servers|glw907/servers' claude bin systemd bluefin secrets docs/model-review` prints only the three lines of `claude/.claude/settings.json` that the packet's command changes. The same search on 2026-11-13 printed 42 lines in 12 files.
2. `claude-tooling-sync verify` passes, and `claude/.claude/skills/runbook/SKILL.md` exists.
3. The skill's `SKILL.md` is 40 lines or fewer and is the skill's only file. `grep -nwiE 'orpheus|ward|hetzner|voip|907\.life|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' SKILL.md` prints nothing.
4. The skill loads when it should. Before the merge, the skill is copied into three scratch folders as a project skill. In a fresh session in each, questions 1, 2, 4, 5, and 6 of "The finding test" are each asked twice. Every run loads the skill and gets an answer that names a page under `docs/systems/` or `docs/reference/`. Each of three unrelated questions the plan names (a Svelte question, a Go question, a question about a club site's content) doesn't load it. The transcripts are the evidence.
5. The merge packet carries one command block for you. It edits lines 86, 88, and 431 of the tracked `claude/.claude/settings.json` to the new path and name, runs `claude-tooling-sync apply` and `stow -R claude`, and removes the link at `~/Projects/servers`. Its check, run from `~`: `/var/home/glw907/Projects/household-it/scripts/tech-mail.sh` runs with no prompt, a session in `~/Projects/phonebook` loads the skill on question 1, and `git -C ~/Projects/household-it worktree list` shows no worktree as prunable.
6. `claude/.claude/CLAUDE.md` has no more lines than it has today.
7. Every link from a workstation skill or doc into the repo names a file that exists there, and a heading that exists in it: a script in the pull request prints nothing. The pull request also lists each line that mentions "runbook" in prose, with the page it now means.

### The finding test

1. How do I add a DNS record to 907.life?
2. Which server holds the mail, and how does mail reach it?
3. A message was filed in the wrong folder. Where is the procedure?
4. Where are the backups kept, and how is a server restored?
5. Which credential deploys a Worker, and what is it called in the store?
6. What alerts exist, and where do they arrive?
7. A phone has no dial tone. What do I check?
8. Who owns the GitHub account, and who takes it over?
9. Where are the Proton Pass recovery details?
10. What do I do first if a server is gone?

Questions 8 and 9 land on stubs today. The operator pass turns their answers into facts and reruns the test with its bus-day questions.

## Shared assumptions

| Assumption | Probe or source |
| --- | --- |
| The name `household-it` is free. | `gh repo view glw907/household-it` answered "Could not resolve to a Repository" (2026-11-13). |
| Git and web traffic follow a rename. | GitHub Docs, "Renaming a repository", quoted under "The rename". The page does not mention API calls or pull requests by name, so the checks after the rename read both. |
| Nothing outside GitHub's redirect depends on the repo's address. | 0 webhooks, 0 deploy keys, 0 Actions secrets, no Pages site (`gh api repos/glw907/servers/{hooks,keys,actions/secrets}`). `.github/workflows/check.yml` doesn't name the repo. The hosts hold no clone: `scripts/apply.sh:99` sends a tar over ssh to `/opt/servers`. |
| No session is live in either repo's main checkout. | `claude agents --json` on 2026-11-13 lists none under `~/Projects/servers`. `conductor-workstation` is idle in an initiatives worktree; the workstation pass launches only after `claude-worktree-busy ~/.dotfiles` exits 0. |
| The runbook's four parts and the other docs are all the prose there is. | `find docs -type f` lists 12 files; the three `README.md` files beside code stay in place. |
| Five files read a doc by path. | The runbook: `scripts/render-emergency.sh:15`, `scripts/check-links.sh:23`, and the `emergency` leg at `scripts/check.sh:220`, pinned by `tests/check.test.sh:28`. Other docs: `tests/stalwart.test.sh:121` reads `docs/addresses.md`, and `scripts/restore-drill.sh:154` writes `docs/restore-drill-log.md`. Pass 1's plan reruns `grep -rn 'docs/' scripts tests` and records the count. `.vale.ini` globs `docs/**/*.md`, which covers the new folders unchanged. |
| The workstation's live references are known. | `grep -rnE 'servers repo\|servers/scripts\|Projects/servers\|glw907/servers'` on 2026-11-13 printed 42 lines in 12 files: `claude/.claude/CLAUDE.md` (2), `settings.json` (3 of its 5 hits name the repo, at lines 86, 88, and 431), the skills `mail-tend`, `proton-pass`, and `vps-conventions`, three docs, `secrets/registry.md` (24), one systemd unit, `bluefin/Brewfile`, and `docs/model-review/prompt.txt`. Pass 3's plan reruns the search, and reads `maintenance-mode` and the Cloudflare inventory for prose mentions the pattern misses. |
| A session can't edit `settings.json` or link a new skill. | `~/.local/state/claude-denials.jsonl`, 2026-10-14 to 2026-11-13: eight refusals tagged `[Self-Modification]` or unexplained, each an edit to `settings.json` or a `stow` of `claude`. `~/.claude/settings.json` is generated from the tracked file by `claude-tooling-sync apply`, and each skill under `~/.claude/skills/` is a separate link that `stow` makes. Standing answer 3 of `round-run.md` covers it. |
| The second operator's access survives. | A rename keeps collaborators. The check after the rename reads the count, which is 2 today. |

## How it fails

- A sentence fits no page. It goes to the page of the system it names most, and the pull request lists it. It is never cut silently.
- A section belongs to two systems, as the MX switch belongs to mail and Cloudflare. It lives on the page whose operator would look for it first, and the other page links to it.
- A system page passes 250 lines. Pass 1 leaves it whole and files a backlog item. Splitting a system is a design call.
- The link at the old path outlives its use. Pass 3's packet removes it, and its check runs with the link gone.
- Auto mode's DNS rule names `github.com/glw907/servers`. Between the rename and pass 3's command, a session that publishes DNS from the repo may be refused. Neither pass here publishes DNS. A DNS change that can't wait goes to you as one `decide` document with the command.
- A session on the laptop opens before the laptop's folder moves. The skill's path fails plainly, and the workstation STATUS says what to run.

## Standing answers

The twelve in `round-run.md` hold. This work adds five.

1. The busy check exits 1 before the rename, or a session is live in the repo. Nothing is renamed, and the session reports it.
2. `gh repo rename` is refused, by GitHub or by auto mode. The session stops before the folder moves and sends one `decide` document with the command for you to run.
3. Pass 1's line check prints a line with no home. The line goes where "How it fails" says, with a row in the pull request.
4. A fix to the text of a moved section comes up in pass 1. It is filed through `standards:log-issue`. Pass 1 moves text and never edits it, apart from links and the repo's name.
5. Pass 3 finds a reference this design didn't list. A live file is updated and listed in the pull request. A dated record is left alone.

## Backlog sweep

The scoped sweep read the 39 open items of the servers backlog at `0a0130e`. Nothing folds: each candidate needs new content, a code change outside these files, or a date. Eight items carry no sweep stamp, which is under the fifteen that would make a full sweep due.

| Item | Verdict | Reason |
| --- | --- | --- |
| #37 Access and tunnel section | keep | Operator pass. Lands on `cloudflare.md`. |
| #38 Screen for Cloudflare or a tunnel down | keep | Operator pass. A new screen on `cloudflare.md`. |
| #39 Document the single redirects | keep | Operator pass. New prose on `cloudflare.md`. |
| #50 Install operator keys from `apply.sh` | keep | Operator pass. A code change. |
| #51 Second operator takes over Cloudflare and the phonebook | keep | Needs new screens, and waits on the phonebook. |
| #66 Remove `mx-switch.sh fastmail` | reword | Not before 2026-11-21. Its `docs/runbook.md:307-309` citation becomes `docs/systems/mail.md`. |
| #60 Finish the lockout cleanup | reword | Live work. Its `docs/decisions.md` citation takes the new path. |
| #55 RCPT acceptance for the phonebook address | reword | A Stalwart decision. Its `docs/addresses.md` citation takes the new path. |
| #52 `ward-book-check.sh` and its runbook entry | keep | A script change and new content. |
| #61 Keep gitleaks out of nested worktrees | keep | `scripts/check.sh:129`, outside the leg table pass 1 edits. |
| #30 Rename `IMMICH_PIKAPODS_API_KEY` | keep | Needs an apply on orpheus and a store change. |
| #29 Video metadata on orpheus | keep | The doc half is written. The rest is a production write that is yours to call. |

Pass 1 lands the three rewordings and the stamps.

## Claude's calls

Each is reversible in the pass that builds it.

- The rename runs before the passes, bridged by GitHub's redirect and a link at the old path.
- The work is a two-pass round and a one-pass round, because a round is one repo.
- The gate leg gets a separate pass, so the split and the rules that judge it are reviewed apart.
- Guides for one reader or one job go in `docs/guides/`, the phonebook guide among them.
- Pages are named for the system, never for a code folder.
- `EMERGENCY.md` is rendered from an ordered list of screens, so it reads as it does today.
- Pass 1 creates the repo's `CLAUDE.md` with the permission notes alone, and pass 2 adds the rules.
- The skill is named `runbook`.
- `secrets/registry.md` stays in place, and Vale's vocabulary folder keeps its name `Servers`.
- Session history for the repo stays under its old key. Only the memory folder is copied.

## Not checked

The laptop's clone and its leftover worktrees were not read. Whether auto mode allows `gh repo rename` is not known, and standing answer 2 covers a refusal. Whether `gh` follows the redirect for a write under the old name wasn't tried, so the rename resets the remote at once. Nobody has yet tried sorting the runbook's lines into seven headings, which is why pass 1 runs first and carries the line check.

## Practice drawn on

GitHub Docs, "Renaming a repository" and "About READMEs". Google's developer documentation style guide, which the repo's Vale config already applies, for headings that name a task. Diátaxis (<https://diataxis.fr>) for keeping how-to pages, reference tables, and records apart. The house records this extends are the 2026-10-25 operator runbook design and its plan.

## Owner steps

None before the work starts. At the end, the workstation pass's merge packet carries one command block: it edits three lines of `settings.json`, applies the settings, links the new skill, and removes the link at the old path. A session can't do the first three itself.

## Planning misses

- **The trust prompt at the new path (2026-11-13).** Claude Code keeps a folder's trust by its path, so moving `~/Projects/servers` to `~/Projects/household-it` left the repo untrusted and the conductor's launch was refused. Geoff had to open `claude` in the folder and accept the prompt before the round could start. The design's rename section and its "How it fails" list should have named this as a step for Geoff, to run straight after the move. Any later design that moves or renames a repo folder carries that step in its pre-flight.
