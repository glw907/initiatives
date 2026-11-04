# Credential hygiene pass C: cleanup and the cross-repo edits

- **Initiative:** `credential-hygiene`.
- **Design:** `credential-hygiene/specs/2026-11-03-remaining-work-design.md`, "Pass C", approved
  2026-11-03 in Approval Queue item `20261103T202632-2969677`. Its three asks stand: the rebuild
  accounts keep their logins off 907.life; the operator runbook pass was amended and runs after
  pass B; Emergency Access goes to the kids and the second operator with a two-week wait.
- **Risk class:** `auth-data`. The design said `ordinary`; the plan review's ruling (finding S4)
  raised it, since T4 and T6 edit `auth-data` paths in their repos. Every PR the pass opens goes
  in its conductor's packet, and the pass merges nothing itself.
- **Estimate:** design 120 path minutes. Plan path **130** (see "Path"). Path ceiling **240**, the
  design's standing answer that a pass may overrun to twice its figure.
- **Conductor:** `conductor-initiatives`, Opus at `medium`, started by `conductor-servers` after
  pass B merges, with the committed prompt
  `credential-hygiene/plans/2026-11-03-pass-c-cleanup-plan-conductor-prompt.txt`. Pass B's
  conductor prompt carries that trigger. The conductor runs the pre-flight, launches the
  executor, sends the one packet, and acts on the decision ("After the decision").
- **Executor:** `initiatives-credential-hygiene-c`, Sonnet at `medium`, launched by the conductor
  from `~/Projects/initiatives` on `main`: `cd ~/Projects/initiatives && claude --bg --model
  sonnet --effort medium --name initiatives-credential-hygiene-c "$(cat
  credential-hygiene/plans/2026-11-03-pass-c-cleanup-plan-prompt.txt)"`. The prompt file sits
  beside this plan with `-prompt.txt` in place of `.md`, so `claude-launch-guard` finds this plan
  as its sibling. Pair subagents run Sonnet at `medium`. The executor ends at PR-ready and takes
  instructions from `conductor-initiatives` alone.
- **Private detail:** account names, item titles, addresses other than `glw@907.life`, the scan's
  patterns, and the contact list live in `~/.local/state/credential-hygiene/` (mode 700, never
  committed). This repo is public, so every committed file, the PR bodies, and the packet name
  them by path only.

## Brief

Approving this plan runs the last pass of credential hygiene: the session clears the old vault names from every live record, moves the published contacts to the public address, files the `Projects` items into folders, and ends with one packet that holds every PR and your list. Passes A and B build the new setup, and they leave behind records that still name the old vaults, contacts on the old login address, a fallback for the age key's old title, and the steps only you can take in Proton and at each provider.

### What changes

- The self-hosting and workstation-secrets records, and Claude's memory of Cathy and the second operator, describe the new vaults, Proton Pass, and ward's mail.
- The sailing club's two repos tell a session which vault and item hold the club's age key.
- Published contacts move to `glw@907.life` in each repo no other session is working in. Where a session is live, a backlog item in that repo carries the change.
- The workstation stops reading the age key's old title, once both machines run pass A.
- Claude puts the `Projects` items into one folder per project, under the editor grant it holds there.
- A private scan shows that no live file names a retired vault or an old restore-item title. It fails on the 2026-11-03 trees, so a pass means something.
- A real GitHub failure notice reaches the technical mailbox once you point GitHub's notification email there.
- You get a finished provider checklist, the Emergency Access steps, a draft estate letter, the mask moves, and the 1Password close steps.

### If you approve

1. Before launch, you pull pass A on thinkpad-x1 and run `check-drift` there.
2. After pass B merges, its conductor starts this pass's conductor, which launches the executor.
3. The executor builds everything and stops when its PRs are ready.
4. You get one packet with every PR (the records, the site's privacy page, fishwright's metadata, the workstation, and the two club repos) and your steps.
5. When you approve it, the conductor merges the PRs, reads the live privacy page, runs the alert check after your provider step, deletes the scratch repo, and closes the initiative's record.

### Worth knowing

The pass is `auth-data` because two of its tasks edit secret-handling paths: `ws-pass-key` and `.bashrc` in the workstation repo, the club's secret scripts, and the club's member-data folder. So nothing merges until you approve the packet. Two other writes may meet an auto mode refusal: Claude's project memory and two `CLAUDE.md` lines. The launch prompt names both as your instruction under the design approval, and if auto mode refuses one anyway, the exact edit joins your list. Emergency Access needs a paid Proton plan, so Cathy's setup depends on her plan.

### Planning guidance

These are the two samples `pass-core` carries into every planning dispatch, quoted verbatim from its "Lifecycle" step 1. The plan follows them: it builds the one scan the design asks for and nothing beyond the design's rows.

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary.
> Keep solutions simple and focused: - Scope: Don't add features, refactor code, or make
> "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up. A
> simple feature doesn't need extra configurability. ... - Defensive coding: Don't add error
> handling, fallbacks, or validation for scenarios that can't happen. Trust internal code and
> framework guarantees. Only validate at system boundaries (user input, external APIs). -
> Abstractions: Don't create helpers, utilities, or abstractions for one-time operations. Don't
> design for hypothetical future requirements. The right amount of complexity is the minimum
> needed for the current task."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)
>
> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself, and check
> in only when different readings of the request would lead to materially different work. If the
> request seems mistaken or a better approach exists, say so in a sentence and continue with the
> task as asked rather than quietly narrowing, widening, or transforming it. Finish the whole
> task, and stop short of actions that are clearly beyond what was asked."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)

## Pre-flight

`conductor-initiatives` checks every row before the launch. Rows 2 and 3 are Geoff's. Row 2 was
foreseen in the design's text ("once thinkpad-x1 has pulled pass A") but not in its pre-flight
list, so it is added by the plan: carry it into pass A's closing packet as a `[you]` step, so it
needs no separate sitting.

| # | Item | Who, when | Check that shows it done |
|---|---|---|---|
| 1 | Pass A merged, and pavilion's workstation checkout pulled | conductor, before launch | `git -C ~/.dotfiles fetch origin && git -C ~/.dotfiles rev-list --count HEAD..origin/main` prints 0; `test -x ~/.local/bin/pass-sitting`; `ws-pass-key --status` reports the key found |
| 2 | thinkpad-x1 runs pass A: on thinkpad-x1, `git -C ~/.dotfiles pull --ff-only`, then `check-drift` | `[you]`, after pass A merges (added by the plan) | `check-drift` on thinkpad-x1 reports no drift, and Geoff's word with the commit it printed is recorded in this record's STATUS |
| 3 | Pass B's setup script run (pass B's set point) | `[you]`, after pass B merges | Pass B's STATUS records the reader's test read; `test -s ~/.local/state/credential-hygiene/provider-checklist.md` passes (pass B's T7 writes it) |
| 4 | The age key carries its held title. Pass A renames it; a rename refused there goes to pass A's closing packet as a `[you: run pass-sitting]` step, run in Ptyxis, never to this pass | conductor, before launch | The held title is the `newtitle` in `~/.local/state/credential-hygiene/decisions.json` for the age key's row in `ops.py`'s `HOLD_TITLE`. `claude-pass item list --vault-name "Age key" --output json`, piped through a filter that compares titles in a file and prints only `match` or `no match`, prints `match` for the held title and `no match` for the old one |
| 5 | Claude's temporary grants are gone (the design sitting's revoke) | conductor, before launch | `claude-pass vault list` names none of `Private`, `Cathy & Geoff`, `Family`, `Parents` |
| 6 | The initiatives checkout is on `main` and level with origin | conductor, before launch | `git -C ~/Projects/initiatives branch --show-current` prints `main`; `git -C ~/Projects/initiatives rev-list --count HEAD..origin/main` prints 0 |
| 7 | Both prompts are committed beside this plan | planning session | `credential-hygiene/plans/2026-11-03-pass-c-cleanup-plan-prompt.txt` and `-conductor-prompt.txt` are on `origin/main`, and the executor prompt carries what "Launch prompt" lists |

Permissions checked: each task's writes and credentials were read against `autoMode` and
`permissions` in `~/.claude/settings.json` on 2026-11-03. Nothing was probed, since the planner
writes only this file; the conductor reads them again after pass A, which edits the environment
text, and T2 opens with a probe. Pushes and PRs in glw907 repositories are routine under
the environment's source-control line, and the executor prompt names each push target:
`glw907/initiatives`, `glw907/workstation`, `glw907/aksailingclub-legacy`,
`glw907/aksailingclub-org`, `glw907/907-life`, `glw907/fishwright`, `glw907/cairn-cms`, and
`glw907/phonebook`. The executor merges nothing. The conductor merges each PR only on an approve
for its head, through `autoMode` allow 7's packet clause, counting `$defaults` as the first entry ("after an `approval-queue packet` call
naming that PR returned a decision whose part for it has verdict approve and that head"). A
backlog item lands on a default branch from a worktree cut from `origin/<default>`, the
`pass-core` "Direct changes" form. `claude-pass` runs `folder create` and `item move`
(`claude-pass:50-51`) under the environment's Proton Pass line; T2's probe checks auto mode
before the real calls, and standing answer 4 takes a refusal. Every `claude-pass` listing prints
titles only through a filter. No task reads a secret value: T4's test points `AGE_KEY_FILE` at a
missing path, and T2 reads notes from the state folder's `notes-tech.json`. `pass-sitting` is
refused to Claude by `claude-block-pass` in every form, so no task runs it, its help, or a dry
run. Two writes are not covered for a fresh session by any allow line: the dotfiles project memory
(T3) and two `CLAUDE.md` lines (T4). Allow 5 needs Geoff's approval in the same session, and
memory is excluded outright. The executor prompt names both edits as Geoff's instruction under the
design approval, and standing answer 3 takes a refusal. The workstation edits (`ws-pass-key`, its
test, `bash/.bashrc`) are worktree edits, not settings, hooks, or permission rules. The alert
check ("After the decision") uses the `gh` token, whose scopes include `repo`, `workflow`, and
`delete_repo` (`gh api -i user`, `X-OAuth-Scopes`, checked 2026-11-03): `gh repo create
--private`, `gh workflow run`, and `gh repo delete --yes` on the scratch repo alone. The delete is
an `[irreversible]` packet step, so Geoff's approve authorizes it. Its read goes through pass B's
reader, `scripts/tech-mail.sh`, under the allow rule pass B adds. The private state folder's new
files hold no secret value.

Reviewed: standards:plan-reviewer, 2026-11-03 (3 blockers, 4 should-fix, 7 nits, all folded)

## Standing answers

The run answers these without stopping.

1. **A live session in a target repo.** The task takes the backlog route ("Live sessions").
2. **An edit pass A or B already landed.** When a task's acceptance check already passes before
   its edit, the session skips the edit and records it under `## Decisions`.
3. **Auto mode refuses a memory or `CLAUDE.md` edit.** The session writes the exact edit (file,
   old line, new line) to `~/.local/state/credential-hygiene/held-edits.md`, the packet gains a
   `[you]` step that applies it, and the refusal goes under `## Planning misses`. The session never
   routes around a refusal.
4. **Auto mode or `claude-pass` refuses T2's probe or a real call.** The session stops calling,
   and the packet gains a `[you: Projects folders]` step: the folder creates as clicks in the
   Proton Pass web app, and the moves as
   `~/.local/state/credential-hygiene/projects-moves.jsonl` when `pass-sitting`'s `move` operation
   takes a folder, else as clicks. Geoff runs that file in Ptyxis, not through `!`: `pass-sitting
   <file>` for the dry run, then `pass-sitting --apply <file>`. The calls that already ran stay, and T2's check reads what remains.
5. **An item in `Projects` serves no single project.** It goes in a folder named `Shared`, and
   `## Decisions` lists each such item by its row number in the state folder's map.
6. **#157 conflicts with `master`.** The session resolves conflicts inside the PR's seven files.
   If `master` rewrote a script the PR edits, it closes #157 with a comment that links a fresh PR
   from `master` with the same scope.
7. **A gate red that also fails on the unmodified default branch.** The session files a backlog
   item there, and the PR goes in the packet as a `gate-failed` ask. The line goes on.
8. **The scan finds a live hit outside the worklist.** In a repo no session owns, a one-line
   rename joins that repo's PR for this pass. Anything larger, or any hit in a repo a session
   owns, takes the backlog route, and an allowlist row names the backlog item. The packet lists
   each such row.
9. **A conflict in self-hosting's STATUS with `conductor-servers`.** The session keeps both sides'
   content with the new names, and the conductor tells `conductor-servers` once the merge lands.
10. **thinkpad-x1's pull is unconfirmed when T6 starts.** T6 still opens its PR, with a
    `## Before merge` section: Geoff pulls thinkpad-x1 and `check-drift` reports no drift there.
    The packet raises that section as its ask.
11. **Pass A left a held rename for this pass** (its test-account answer: a file in a live
    session's repo held the rename). The packet's `[you: pass A's carry-overs]` step gives Geoff
    `~/.local/state/credential-hygiene/pass-a-carryovers.jsonl` for it, run in Ptyxis as step 6
    spells out. With none, the step drops.
12. **Geoff sets the close-record step to skip.** The record stays `active`, and its STATUS names
    each step still owed.
13. **No GitHub failure notice reaches the technical mailbox within 15 minutes.** The conductor
    checks GitHub's Actions notification setting (email, failed workflows) and the provider
    checklist's GitHub row. It reruns the job once after a fix it can trace, and otherwise records
    end-to-end check 3's live half as unmet in STATUS. The scratch repo is deleted either way.
14. **The path passes 240 minutes.** That is the ceiling: the executor writes STATUS and waits,
    and the conductor asks Geoff.

## Live sessions

At each task's start, before any edit, the session checks the target repo by its real path
(`realpath`). The workstation repo has two paths, `~/.dotfiles` and the symlink
`~/Projects/workstation`, and its worktrees also sit under `~/Projects/workstation-wt/`; the check
matches all three. A repo is live when either of these holds:

- `claude agents --json` lists a row whose `cwd` resolves to the repo or a path under it, whose
  `state` is not `done`, and whose `name` is not `initiatives-credential-hygiene-c` or
  `conductor-initiatives`.
- `git -C <repo> status --short` on the main checkout shows a tracked change this session did not
  make.

A process check adds nothing these miss: `pgrep -f` matches this session's command lines too,
and every Claude session shows in `claude agents`.

A live repo gets no edit, and the change takes the backlog route instead:

1. Draft the item in that repo's `BACKLOG.md` format, through `standards:log-issue`, naming the
   file, the line, and the new text. An item in a public repo names no private detail.
2. If the repo's conductor (`conductor-<repo>`) is live, send it the item by `SendMessage` and ask
   it to file it, then take its reply naming the item's number.
3. Otherwise commit the item from a worktree cut from `origin/<default>` and push it with
   `git push origin HEAD:<default>`. On a non-fast-forward, fetch, rebase, renumber, and push
   again.
4. If the conductor holds or refuses the message, or sends no reply within 10 minutes, write the
   item under "Owed backlog items" in this record's STATUS and go on.

At planning time (2026-11-03) `claude agents --json` listed live sessions in `cairn-cms` (its
conductor and several executors) and `phonebook` (`conductor-phonebook` and two executors). No
session was live in the workstation repo, `servers`, `907-life`, `fishwright`, `dubplate`,
`aksailingclub-legacy`, or `aksailingclub-org`, and each main checkout was clean.

| Repo | Path | Edit | Class there | Gate | Expected route |
|---|---|---|---|---|---|
| initiatives | `~/Projects/initiatives` | records (T3) | `ordinary` | `scripts/index`, then `bash scripts/gate.sh` (`scripts/check` and every `*.test.sh`) | edit |
| workstation | `~/.dotfiles` | `ws-pass-key`, its test, `bash/.bashrc` (T6) | `auth-data` | `bash scripts/gate.sh` | edit |
| aksailingclub-legacy | `~/Projects/aksailingclub-legacy`, default `master` | #157 (T4) | `auth-data` (`scripts/secrets/**`) | `bash -n` and T4's test | edit |
| aksailingclub-org | `~/Projects/aksailingclub-org` | `data/membershipworks/README.md`, `CLAUDE.md` (T4) | `auth-data` (`data/membershipworks/**`) | `npm run check`; CI on the PR | edit |
| 907-life | `~/Projects/907-life` | `static/privacy.html` (T5) | `ordinary` | `npm run check && npm test && npm run build` | edit |
| fishwright | `~/Projects/fishwright` | `pyproject.toml` (T5) | `ordinary` | `uv run pytest` | edit |
| cairn-cms | `~/Projects/cairn-cms` | `SECURITY.md` (T5) | `ordinary` | the `cairn-pass` gate; CI on the PR | backlog route |
| phonebook | `~/Projects/phonebook` | two backlog items (T5) | `ordinary` | none | backlog route, always |
| dotfiles memory | `~/.claude/projects/-var-home-glw907--dotfiles/memory/` | two entries and their index line (T3) | not a repo | none | edit |

A site worktree runs `npm ci` and `npx svelte-kit sync` before its gate, per `site-pass`. Work in
another repo goes by absolute path and `git -C`, in a worktree the session adds under that repo's
`.claude/worktrees/`; the session calls `EnterWorktree` only once, in the initiatives repo.

## Tasks

### T1. A private scan that fails on the 2026-11-03 trees (20 min)

- **Outcome:** `~/.local/state/credential-hygiene/scan/` holds the scan.
  - `patterns.txt` has one regular expression per line, each anchored to a vault context. A
    retired vault name matches only beside a vault word or flag: `Workstation` followed by
    `vault`, `--vault-name "Workstation"`, `vault "Workstation"`, or a backticked `Workstation`
    in a list of vault names. `Servers emergency` and `Household IT` match the same way. The
    restore items' old titles come from `decisions.json`, and the age key's old title is the last
    line. No line is a bare `Workstation`.
  - `fixtures/negative.txt` holds lines that must not match, such as the workstation repo, the
    `workstation-secrets` record, `SECOND-WORKSTATION.md`, and a host called a workstation.
    `fixtures/positive.txt` holds one line per pattern that must match.
  - `allow.txt` has the history allowlist: path globs for dated specs, plans, packets,
    `research/**`, `HISTORY.md`, archives, status archives, and decision logs, plus `path:line`
    rows for a line that records a dated past event, each with its reason.
  - `scan.py` (stdlib, run as `python3 -I`) finds every repo under `~/Projects` and `~/.dotfiles`,
    keeps one per `realpath` of `git rev-parse --git-common-dir`, so a symlink or a sibling
    worktree such as `~/Projects/workstation` or `~/Projects/workstation-wt` never counts twice,
    and runs `git grep -nE` over each at a rev. `--rev <name>=<rev>` sets one repo's rev, where
    `<name>` is the basename of the repo's main checkout after `realpath` (`.dotfiles` for the
    workstation repo, which also answers to `workstation`) and `<rev>` is any commit-ish `git
    rev-parse` resolves there. A repo with no `--rev` scans `origin/<default>`, where `<default>`
    comes from `git symbolic-ref refs/remotes/origin/HEAD`. The scan also reads
    `~/.claude/projects/*/memory/*.md` as plain files. It drops allowlisted hits, prints
    `path:line` and the pattern's number for each one left (never the line's text, since a memory
    line can carry personal detail), and exits 1 on any hit. `--only <path>...` limits a run to
    named files, and `--self-test` runs both fixtures.
  - The contact list is separate: `~/.local/state/credential-hygiene/contacts.txt` holds the old
    contact addresses T5 replaces. End-to-end check 4 never reads it.
- **Files:** the files above, private.
- **Class:** `ordinary`.
- **Acceptance:** `python3 -I ~/.local/state/credential-hygiene/scan/scan.py --self-test` exits 0, and exits 1 when a scratch copy
  of the negative fixture gains a line that a pattern matches. `python3 -I ~/.local/state/credential-hygiene/scan/scan.py --rev
  .dotfiles=ad1756a --rev servers=e235ae1 --rev initiatives=2cbbe82` exits 1 and lists at least
  `bin/.local/bin/claude-pass`, `EMERGENCY.md`, and `self-hosting/plans/STATUS.md`, and lists
  the workstation repo once. A rerun with a scratch allowlist row covering every hit exits 0.
- **Test:** those runs, saved as `scan/baseline.txt`. A run on today's `origin/<default>` trees is
  saved as `scan/worklist.txt`: the live hits T3 to T6 clear.

### T2. The `Projects` folders (60 min, in the background from the start)

- **Outcome:** each `Projects` item sits in one folder per project. The map,
  `~/.local/state/credential-hygiene/projects-folders.tsv`, comes from each item's `For` and
  `Used by` note lines in `notes-tech.json` (standing answer 5 for an item with no single
  project). A script in the state folder makes every call through `claude-pass`, 150 seconds
  apart, since Proton throttles the agent's logins after about four quick calls
  (`bluefin-admin.md:358-360`). The session runs it with `run_in_background` while T1, T3, and
  pair B go on. It waits 150 seconds before its first call, so it never meets the conductor's
  pre-flight calls.
  1. **Probe** with the first real folder, so the probe leaves nothing behind, since
     `claude-pass` refuses `folder delete`: create a scratch item in `Projects`, create the first
     project folder, move the scratch item into it with `claude-pass item move
     --from-vault-name Projects --to-folder-id <id>`, then trash the scratch item. A refusal ends
     the script with a marker line, and standing answer 4 takes it.
  2. Create each remaining folder with `claude-pass folder create`, inside `Projects` only. The
     pass-cli docs say a move's target folder "must belong to the source vault".
  3. Move each item into its folder with the same `item move` form.
  4. List the vault once more, titles and folder ids only, into a file for the check.
- **Files:** the map, the script, and its output files, private.
- **Calls:** four for the probe, one folder create per project, one move per item (ten items
  today), and two listings: about 22 calls, about 55 minutes of spacing.
- **Class:** `ordinary`.
- **Acceptance:** a check compares the last listing with the map. It exits 1 on an item missing
  from the map, a map item not in the listing, an item outside its mapped folder, or an item in
  `Projects` left at the top level. The listing shows no scratch item.
- **Test:** the check passes on the listing, and fails on a copy of the map with one row
  changed.

### T3. Records and memory (20 min)

- **Outcome:**
  - `self-hosting/plans/STATUS.md`: every live line names the current vaults (`Infrastructure`,
    `Age key`). The line on Claude's agents points to the workstation's grant map
    (`secrets/proton-grants.tsv`) instead of listing grants. The Emergency Access lines (line 15
    and the 0.6 row today) point to this record and carry ask 3: the kids and the second operator,
    with a 14-day wait. The D4 line says Fastmail's close follows Geoff's mask moves from the
    catalog this record owns. The 1Password close names the self-hosting gate (every member moved
    and a 30-day overlap, the plan's P4) and the matching step of Geoff's list. A line that
    records a dated past event keeps its old name and gets an allowlist row in T1's `allow.txt`.
  - `workstation-secrets/README.md`: the non-goal reads "Replacing age or Proton Pass as the
    store."
  - The dotfiles project memory: the entries for Cathy and the second operator, and Cathy's index
    line in `MEMORY.md`, say Proton Pass and ward's mail in place of 1Password and Fastmail. The
    facts come from self-hosting's STATUS, such as whether Cathy has moved yet. Only those lines
    change.
- **Files:** the two record files and the three memory files.
- **Class:** `ordinary`.
- **Acceptance:** `python3 -I ~/.local/state/credential-hygiene/scan/scan.py --only <the five paths>` exits 0. In
  `self-hosting/plans/STATUS.md`, the D4 line, each Emergency Access line, and the 1Password close
  line each name `credential-hygiene`, checked line by line with `grep -n` on each line's
  anchor (`D4`, `Emergency Access`, `1Password`), not by a file-wide count, which reads 2 today.
  `grep -n -i "1password\|fastmail"` on the two memory entries prints only lines that state a past
  move. `scripts/index` runs, then `bash scripts/gate.sh` passes.
- **Test:** the checks above; the scan run fails before the edit, on the worklist's lines.

### T4. The club's age-key pointers (25 min, pair B with T5)

- **Outcome:** draft `aksailingclub-legacy#157` (branch `remove-1password-fallback`) is rebased on
  `master` (`e402c42` today). Every line that names the club's key item names the `ASC` vault and
  the item's current title from `final.tsv`, since the 2026-11-03 triage renamed it. The recovery
  step says Claude restores the key through `claude-pass` per the `proton-pass` skill, writing the
  key file at mode 600 and never printing it. The scripts still call no password manager. The PR
  body's brief is updated, and the PR leaves draft. In `aksailingclub-org`, a new PR changes
  `data/membershipworks/README.md:6` to name the `ASC` vault instead of 1Password, and points
  `CLAUDE.md:167` at `bluefin-admin.md`'s current heading, "Secrets: installing, receiving, and
  Proton Pass" (`bluefin-admin.md:326`).
- **Files:** #157's seven files; the org's `data/membershipworks/README.md` and `CLAUDE.md`.
- **Class:** `auth-data` in both repos.
- **Test first:** in a scratch copy of the legacy worktree, run `scripts/secrets/sync.sh` with
  `AGE_KEY_FILE` set to a missing path and no `op` on `PATH`. The check expects a non-zero exit
  and a message that names `ASC` and the current title. On `master` it fails, since the script
  reports a missing 1Password CLI. The before and after outputs go in the PR body.
- **Acceptance:** that check passes on the PR head. `bash -n` passes on both scripts.
  `git grep -n -i -E "1password|op item|op signin"` on the legacy head prints nothing outside
  history paths. `git grep -n 1Password -- data/membershipworks CLAUDE.md` on the org head prints
  nothing, and the org PR's CI is green. `standards:diff-reviewer` at task scope returns `accept`
  on each PR.

### T5. Published contacts and the backlog items (30 min, pair B with T4)

- **Outcome:** the contact line moves to `glw@907.life` in `907-life`'s `static/privacy.html`
  (the `mailto` and its text), in `fishwright`'s `pyproject.toml` (`authors` email), and in
  `cairn-cms`'s `SECURITY.md` (line 10), each repo through a PR there or the backlog route. In
  `phonebook`, which the design sends to the backlog in any case, two items: the alert address in
  `scripts/cloudflare/service-token.sh` (`NOTIFY_EMAIL`) and the live Cloudflare notification move
  to the technical mailbox; and the `phonebook-public` scrub gains Geoff's personal addresses and
  the noreply commit author, tagged `#initiative:phonebook-public`. The old addresses come from
  T1's `contacts.txt`.
- **Files:** `907-life/static/privacy.html`, `fishwright/pyproject.toml`, `cairn-cms/SECURITY.md`
  or its backlog item, and `phonebook/BACKLOG.md` (through the backlog route).
- **Class:** `ordinary`.
- **Acceptance:** on each PR head, the edited file holds `glw@907.life` and none of the addresses
  in `contacts.txt`. 907-life's gate passes. `uv run pytest` passes in fishwright. Each backlog
  item has its number, from the repo's `BACKLOG.md` on origin or from the conductor's reply. The
  live page's read comes after the merge ("After the decision").
- **Test:** the checks above. A grep for the old addresses fails on each file before its edit.

### T6. The workstation PR (25 min, pair C with T7)

- **Outcome:** `ws-pass-key` reads only the age key's held title. `tests/ws-pass-key.test.sh`
  gains a case where the vault holds only the old title, and `ws-pass-key` must fail with a
  message that names the held title. In `bash/.bashrc`, `DUBPLATE_HARNESS_CONTACT` becomes
  `glw@907.life`. That variable is the dubplate harness contact, and line 208 sets it today.
- **Files:** `bin/.local/bin/ws-pass-key`, `tests/ws-pass-key.test.sh`, `bash/.bashrc`.
- **Class:** `auth-data`, by the `dotfiles-pass` path map.
- **Test first:** add the old-title case and run `bash tests/ws-pass-key.test.sh`. It fails on
  pass A's two-title code, and then the edit lands.
- **Acceptance:** the test passes and `bash scripts/gate.sh` passes. `grep -c '^export
  DUBPLATE_HARNESS_CONTACT="glw@907.life"$' bash/.bashrc` prints 1. `python3 -I ~/.local/state/credential-hygiene/scan/scan.py --only
  bin/.local/bin/ws-pass-key tests/ws-pass-key.test.sh bash/.bashrc` exits 0. One `gitleaks git` branch-history scan is clean, per the `dotfiles-pass`
  close checklist. `standards:diff-reviewer` at task scope returns `accept`. Standing answer 10
  covers an unconfirmed pull.

### T7. Geoff's list, prepared (35 min, pair C with T6)

- **Outcome:** five private files hold the exact steps, so Geoff looks nothing up.
  - `provider-checklist.md`, which pass B wrote, gains on each row the settings URL, the click
    path, and the check that shows the row done. The rows cover alert addresses, logins per ask
    1, and GitHub's private-email setting and public profile email. The GitHub row also points
    GitHub's notification email at the technical mailbox and turns on email for failed Actions
    runs, since the alert check depends on it.
  - `mask-catalog.md` gains a destination on every "Move" row, per ask 1 and the checklist. The
    rebuild accounts keep their logins off 907.life, a technical account takes the address the
    checklist names, and a personal one takes a Proton alias on `m.907.life`, made by the
    `proton-pass` skill's alias steps.
  - `emergency-access.md` gives Proton's click path from
    <https://proton.me/support/emergency-access>, for Geoff and for Cathy. Proton offers waits of
    30, 14, and 7 days, and ask 3's two weeks is 14. The contacts are the kids and the second
    operator, each of whom first makes a Proton account. Emergency Access needs a paid plan, so
    Cathy's part says to check her plan first. The check is each contact's state in the Emergency
    Access settings.
  - `estate-letter.md` is a draft for Geoff to edit, written to the Federal Plain Language
    Guidelines for the family. It explains what Emergency Access is, how to request it, the wait,
    what each vault holds in one sentence each, and that the second operator restores the
    servers. It holds no password or other secret.
  - `onepassword-close.md` lists each member's move date from self-hosting's STATUS and the date
    30 days after the last move. It names the open flag's item to copy first, and says that
    self-hosting's P4 packet carries the cancellation.
- **Files:** those five, private.
- **Class:** `ordinary`.
- **Acceptance:** a count of checklist rows that lack a URL, a click path, or a check prints 0.
  Every catalog "Move" row has a destination, and a grep finds no rebuild-account row whose
  destination is on 907.life. Each vault in the decisions table appears by name in the letter,
  and `tellgrader` on the letter reports no real finding. `emergency-access.md` names the 14-day
  wait and cites the support URL.
- **Test:** the checks above, each run once on a copy with one gap planted, where it must fail.

### T8. Close, to PR-ready (25 min)

1. Wait for T2's script to finish and run its check.
2. Run `python3 -I ~/.local/state/credential-hygiene/scan/scan.py` once, with one `--rev <repo>=<PR head>` per
   open PR, so each PR's head stands in for its repo's default branch and every other repo scans
   `origin/<default>`. It exits 0, which is end-to-end check 4 on the pass's heads. Standing
   answer 8 takes any hit left in a repo a session owns.
3. One whole-branch `standards:diff-reviewer` reads the initiatives branch against the design and
   this plan, plus each cross-repo PR's diff (`gh pr diff`), with the security read every
   `auth-data` diff gets. One batched fix chain follows, then the gates again.
4. The initiatives PR body carries the brief, what landed, each `auth-data` verdict,
   `## Decisions`, `## Planning misses`, and the score, with the path's 130 minutes beside the
   actual. Its `## Geoff's list` section gives each `[you]` step from "After the decision" with
   its private file's path and its check, for the conductor's packet. It names no account detail.
5. Write STATUS (each PR, the scan's result, T2's check, any held edit) and report PR-ready to
   `conductor-initiatives`. The executor never runs `approval-queue`.

## After the decision (conductor)

The conductor sends one packet for every PR the pass opened, per `approval-packet`, with the
`diff-reviewer` verdicts in each row and any ask standing answers 7 and 10 raise. The packet file
names no account detail and points at private files by path. Its `## If you approve` runs:

1. `[session]` Merge each PR with `--match-head-commit`: the initiatives PR, 907-life, fishwright,
   the workstation PR, then the two club PRs. Pull each checkout per `pass-core` "Close". If
   `conductor-servers` is live, tell it that self-hosting's STATUS changed on `main`.
2. `[session]` After 907-life's `deploy.yml` run on the merge goes green (`gh run watch`), fetch
   the live `https://907.life/privacy.html` and read a full-page screenshot in the main loop. It
   shows `glw@907.life`.
3. `[you: provider checklist]` Work each row of `provider-checklist.md`, the GitHub row first.
4. `[session]` The alert check, end-to-end check 3's live half. Create the private scratch repo
   `glw907/tech-alert-probe-c` with one `workflow_dispatch` job that exits 1, and run it once with
   `gh workflow run`. Within 15 minutes, `scripts/tech-mail.sh list` from the servers checkout
   shows GitHub's failure notice inside the reader's banner (standing answer 13 otherwise).
5. `[irreversible]` Delete the scratch repo with `gh repo delete glw907/tech-alert-probe-c --yes`.
6. `[you: pass A's carry-overs]` In Ptyxis, not through `!` (pass A's ruling), run `pass-sitting
   ~/.local/state/credential-hygiene/pass-a-carryovers.jsonl` to read the dry run, then
   `pass-sitting --apply ~/.local/state/credential-hygiene/pass-a-carryovers.jsonl` and sign in
   once when asked (standing answer 11). Drops when none remain.
7. `[you: Emergency Access]` Follow `emergency-access.md`, then edit the letter and put it with
   the estate documents.
8. `[you: mask moves]` Work the catalog's "Move" rows. Fastmail's close follows in self-hosting,
   D4.
9. `[you: 1Password close]` When `onepassword-close.md`'s date has passed, approve self-hosting's
   P4 packet.
10. `[session]` Close the record per `log-project` step 5: `initiative.yaml` takes `status: done`,
    the README takes a dated `Status: done` line, and STATUS becomes present tense, naming where
    each open item now lives (mask moves in self-hosting D4, the 1Password close in P4). Run
    `scripts/index`, then `bash scripts/gate.sh`, commit and push the hand-over to `main` per `pass-core`
    "Ledgers", rerun `python3 -I ~/.local/state/credential-hygiene/scan/scan.py` with no `--rev` on the merged trees, and record its exit in STATUS.
11. `[irreversible]` Shred the triage exports no open step needs, listed by name in the packet.
    `mask-catalog.md`, `mask-links.json`, `fastmail-masks.json`, and `onepassword.jsonl` stay until
    D4 and P4 close.

A held edit from standing answer 3 and a folder step from standing answer 4 join the list as
`[you]` steps. The conductor runs `approval-queue packet --check credential-hygiene <file>` until
it passes, sends it in the background, and acts on the decision per `approval-packet` step 7. Its
work after the decision is off the path, since the executor's clock stops at PR-ready.

## Path

| Step | Tasks | Minutes on the path |
|---|---|---|
| 1 | T2 in the background (60), beside T1 (20), T3 (20), and pair B: T4 (25) and T5 (30) | 70 |
| 2 | pair C: T6 (25) and T7 (35) | 35 |
| 3 | T8 | 25 |
| | **Path** | **130** |

T2 runs alone on `claude-pass` and touches no file the other tasks write, so its 60 minutes of
spaced calls sit beside the 70-minute chain of T1, T3, and pair B. Each pair's files are disjoint.
A pair subagent commits in its worktree and never pushes; the session merges, runs the
fast lane, pushes, and opens each cross-repo PR. The sum over all tasks is 235 and sets nothing.

## Launch prompt

The planning session writes and commits
`credential-hygiene/plans/2026-11-03-pass-c-cleanup-plan-prompt.txt` (pre-flight 7). It carries:

- The goal, this plan's path, and the checkout (`~/Projects/initiatives`, `main`).
- The first acts: `EnterWorktree`, then the API-drop wake-up (`/loop` with no interval) per
  `~/.claude/docs/unattended-work-guards.md`.
- `conductor-initiatives` as the one session whose messages it takes as instructions.
- Each push target as `glw907/<repo>`, as "Permissions checked" lists them.
- The end: stop at PR-ready and report to the conductor. Merge nothing, and never run
  `approval-queue`.
- The two self-modifying edits as Geoff's instruction under Approval Queue item
  `20261103T202632-2969677`: the memory lines (the design's "Claude infrastructure" memory row)
  and the `CLAUDE.md` lines in T4 (the design's "refreshes or replaces aksailingclub-legacy#157").
  It names each file and says the facts come from self-hosting's STATUS. It carries no personal
  detail, since the file is committed to a public repo.
- The rules that bind every task: never run `pass-sitting` in any form; no secret value in the
  transcript, a screenshot, or a committed file; account detail stays in the private state folder.

The conductor prompt, `credential-hygiene/plans/2026-11-03-pass-c-cleanup-plan-conductor-prompt.txt`,
is the planning session's to write.
