# Repo organization plan review: data integrity and failure risk

Target: `repo-organization/plans/2026-10-14-repo-organization-plan.md` and its launch prompts, at
commit `f2362ab`. Lens: crash or interruption at each step, concurrent sessions, partial writes,
merge-order slips, reruns after failure, and divergent thinkpad clones. The question each finding
answers is whether data can be lost or silently corrupted, or whether the pass can wedge.

Counts: 2 blocker, 11 major, 11 minor (24 findings). One owner fork (m9).

## Probes (read-only, pavilion, 2026-10-14)

- `claude agents --json` today lists `conductor-drafter` and `drafter-p5-cairn`, both `busy`. Each
  row carries `name`, `status`, and `state`.
- `gh pr list -R glw907/cairn-cms --head drafter-pipeline` returns PR #124 (open). drafter has no
  PR yet; `worktree-p5-pipeline` exists only as a local, locked worktree branch.
- `scripts/secrets/secret-set.sh:33-36` hard-codes `RECIP`, `VALUES`, `LOCAL_SECRETS`, and
  `CACHE` (`/dev/shm/.age-key-$(id -u)`). `--delete` re-encrypts `VALUES` and then calls
  `write_local "$NEW"` (line 136), which overwrites `~/.local/secrets` from the edited store.
  `~/.dotfiles` has no `.gitattributes`.
- The queue command copies a design brief into `items/<id>/doc.md` at hand-over
  (`bin/.local/bin/approval-queue:55`), so the approved doc is a snapshot. A decided item is a 404
  in the app, so Geoff can't re-decide it. The command's `EXIT` trap removes `item.json` when the
  command leaves without a decision (line 20), so a killed hand-over drops its item and a rerun
  makes a new id.
- `/tmp` is `tmpfs`; `/var/home` is btrfs. The three tar targets total about 132 MB, all readable.
- Retirement targets on pavilion: `displaywidth` has an `origin`; `personal-styles`,
  `healthy-diet`, and `pings` are git repos with no remote; `cairn-scratch` and
  `ecxc-ski-agent-memory` are plain dirs; `aksailingclub-sveltekit`'s gitfile points at a missing
  `aksailingclub-legacy/.git/worktrees/` entry. `cairn-scratch-b`, `kit`, `jrnl-md`, and
  `hugo-blog-template` have no local directory.
- `~/.claude/projects/*/memory` matches 8 directories, 3 of them for project paths outside the
  pass's candidate repo list (counted, not named).
- The estate inventory lists Access apps (ASC Staging and others) that live only in the account,
  never in a wrangler config, and `asc-staging` as a D1 database.
- `registry.md` mentions `pings` inside sections for other secrets (lines 243 and 313), not only
  in `PINGS_ADMIN_TOKEN`'s own section.
- The initiatives history holds no repo name outside the candidate list beyond placeholders
  (counted, not named).

## Blockers

### B1. G-p5 matches the pass's own drafter executor, so it can never pass again

- Severity: blocker. Tag: `correctness`.
- Location: `plans/2026-10-14-repo-organization-plan.md:57`; `drafter-prompt.txt:6`;
  `conductor-prompt.txt:22`.
- Defect: G-p5 requires that `claude agents --json` list "no row whose `name` starts with
  `drafter-`". The pass launches `drafter-repo-organization`, which starts with `drafter-`. D1's
  first act rechecks G-p5 and stops if it fails, so D1 stops on itself. Every later G-p5 check
  (C5's cairn-cms worktree removals, I9's drafter rows, W7's drafter rows) also fails while that
  session exists. The check also never reads `status`, so a listed but finished pass 5 row keeps it
  failing if the listing keeps ended sessions.
- Proposed fold: define the session half of G-p5 as no row whose `name` equals `conductor-drafter`
  or matches `^drafter-p[0-9]` (pass 5's own names), filtered to live states. Add a plan line
  saying the pass's own `*-repo-organization` names are excluded by construction. Keep the two PR
  checks as written. The drafter head is still unpushed today, so the conductor checks the head
  name when pass 5 opens its drafter PR.

### B2. A rerun of C5 can overwrite the only backup with a partial copy

- Severity: blocker. Tag: `correctness`.
- Location: `plan.md:114-122`; `conductor-prompt.txt:24`; design `:195`.
- Defect: C5 writes the tar, then removes directories, and checks `tar -tf` only in its acceptance,
  after the removals. Four things can go wrong:
  - A crash after the tar and after part of an `rm -rf` (an API drop wakes the conductor through
    `/loop`) leads to a rerun that re-tars the partial source over the good archive. This is the
    one copy Geoff ruled must survive, and it's lost silently.
  - `tar -tf` lists names even when `tar -c` exited 2 on a read error, so a short archive passes.
  - The archive path is "the path the approved dry run names" with no constraint. The obvious
    choices, `/tmp` and the session scratchpad, are `tmpfs` here and vanish at reboot.
  - C5 logs nothing per item, so a rerun can't tell which removals finished.
- Proposed fold:
  - I8 names a path under `/var/home` outside `~/Projects` and outside
    `~/.local/state/repo-organization/`, which the pass treats as scratch. I8 rejects `/tmp` and
    `/dev/shm`.
  - C5 creates the archive with no-clobber (refusing if the file exists), requires `tar -c` exit 0,
    then `tar -df` against the sources exit 0, then `sync`. It records the sha256 in a C5 row of
    the retirement log. Only then does any `rm` run.
  - A rerun that finds a logged, verified archive skips the tar and never rewrites it.
  - Each removal appends a `local` row to the log.
  - Move the `tar -tf` and `tar -df` checks from acceptance into the step order, before the first
    removal.

## Major

### M1. The approved dry run is prose, unhashed, and parsed by hand into deletions

- Severity: major. Tag: `correctness`.
- Location: `plan.md:236-243`, `260`, `116-119`; `retire-prompt.txt:5`; `conductor-prompt.txt:24`.
- Defect: `doc.md` is a snapshot (good), but only the Cloudflare half has a machine list
  (`teardown.tsv`). The GitHub deletions, descriptions, retired secrets, local directories, and
  worktree calls must be read out of a design brief by an LLM session in R2, W8, and C5. A misread
  of a markdown list deletes the wrong repo or directory, with no mechanical cross-check. Nothing
  records the approved snapshot's hash, and every executor holds `--add-dir ~/.local/state`, so
  nothing detects a later write to `doc.md`. A cross-check also has a weak anchor:
  `teardown.tsv` "on origin" names no branch, and PR 1's branch keeps moving through I9.
- Proposed fold:
  - I8 writes one `retire-manifest.tsv` with columns `stage`, `kind`, `id`, `action`, and
    `expect`, covering every Cloudflare id, repo delete, description, secret name, directory, and
    worktree. `expect` holds the fact the act-time recheck compares, such as HEAD, newest mtime,
    or file count. `teardown.tsv` is that file's `cloudflare` rows.
  - I8 embeds the manifest verbatim in the dry-run doc as a fenced block, so the approved
    snapshot carries it.
  - When the approve arrives, the conductor writes the sha256 of `doc.md` into `items.tsv`.
  - R1, R2, W8, and C5 each extract the manifest from `doc.md`, check the hash, and act only on
    its rows. A hash mismatch stops the session for Geoff.

### M2. Nothing rechecks the inventory at act time

- Severity: major. Tag: `correctness`.
- Location: `plan.md:203`, `262-266`, `114-122`.
- Defect: sharing and local state are resolved at C1, while R1 and C5 act after Geoff's approval,
  hours or days later, with passes running in parallel. Three things can change in that window:
  - A surviving repo binds a resource marked `sole-owner`. The aksailingclub-org cutover is the
    live candidate.
  - A git target gains a commit or stash.
  - A plain dir gains a file.

  C5 rechecks worktrees only. R1 deletes from the list as approved.
- Proposed fold: R1 reruns the inventory's network leg for each id right before its delete, and
  stops for Geoff on any id no longer `sole-owner`. C5 reruns the local leg per target and
  compares it with the manifest's `expect` column, refusing and listing any changed target. Both
  stay cheap, since they cover single ids.

### M3. Access apps and DNS records have no sole-owner rule and no teardown order

- Severity: major. Tag: `correctness`.
- Location: `plan.md:203`, `264`; design `:200`.
- Defect: the sole-owner test is "no in-scope config names it and no deployed Worker outside the
  targets binds it". An Access app, a DNS record, or a custom domain is never bound by a Worker,
  and Access apps live only in the account (estate inventory), so the test passes on them
  vacuously. Deleting an Access app whose hostname list covers a surviving host exposes that host
  publicly. R1 also states no order inside the stage. A crash after an Access app's delete and
  before its Worker's delete leaves the target Worker public until the rerun, and the rerun can
  wedge (m1).
- Proposed fold: for each Access app, DNS record, route, and custom domain, define sole-owner by
  hostname. Every hostname it covers must resolve to target Workers only, with an exact match and
  no wildcard covering a surviving host. Order R1 inside the stage: routes and custom domains,
  then Workers, then D1, KV, and R2, then DNS records, then Access apps last. Add an I5 fixture: an
  Access app whose domain list includes one surviving hostname must come out `shared-with`.

### M4. The W8 store edit starts from a stale base and regenerates live secrets from it

- Severity: major. Tag: `correctness`.
- Location: `plan.md:325-334`; `secret-set.sh:34`, `136`.
- Defect: the workstation worktree branches at C0, and W8 runs late in the pass. Two harms follow
  if `origin/main`'s `values.age` changes in between (any `secret-receive` by any session in a long
  pass):
  - `--delete` through the override calls `write_local` from the worktree's older store, so
    `~/.local/secrets` silently loses the newer secret on pavilion.
  - The branch and `main` both change a binary file with no merge driver, so the merge conflicts.
    The easy resolution, taking either side, drops the retirement or the new secret.

  The same applies if a `secret-receive` dirties the main checkout's `values.age` mid-pass. C6's
  pull then refuses, and the tempting `git checkout -- secrets/values.age` destroys the only copy
  of that secret.
- Proposed fold:
  - Just before the store commit, W8 merges `origin/main` into the worktree and requires
    `git diff <merge-base> origin/main -- secrets/` to be empty.
  - Add a workstation `## Before merge` step: `git diff <store commit>^ origin/main --
    secrets/values.age` is empty, or W8 redoes the deletes on the new base.
  - After the merge and pull, C6 runs `secret-set.sh --sync` from the main checkout.
  - Add a standing rule in the conductor and thinkpad prompts: a dirty `values.age` is never
    discarded or overwritten. It is re-applied with `secret-set.sh` and Geoff is notified.

### M5. W8's test-first override test can clobber the real `~/.local/secrets` and key cache

- Severity: major. Tag: `correctness`.
- Location: `plan.md:328`, `334`, `510`; `secret-set.sh:33-36`, `93`.
- Defect: the plan adds only a store-path override, but a `--delete` test "against a temporary
  store and recipient" also needs:
  - A test recipient, but `RECIP` is hard-coded.
  - A test identity in `CACHE`, which is the real tmpfs key path keyed by uid and not by `HOME`.
  - A safe `LOCAL_SECRETS`, which `write_local` always overwrites.

  A test written to the plan's text either overwrites the real cached age key or writes fixture
  values over `~/.local/secrets`, or both. Every later `source ~/.local/secrets` then has no real
  `CLOUDFLARE_API_TOKEN`, so R1 and the inventory fail. Recovery needs a 1Password unlock and a
  `--sync`. Review Focus 2 asserts only that the fixture main store stays byte-identical.
- Proposed fold: the override covers `VALUES`, `LOCAL_SECRETS`, `CACHE`, and `RECIP` as four env
  vars with today's defaults, all in W8's first commit. The test sets all four to temp paths.
  Review Focus 2 also asserts that the real `~/.local/secrets` mtime and the real `CACHE` mtime
  are unchanged after the test.

### M6. The thinkpad deletes remote-less copies that may differ from pavilion's, with no tar

- Severity: major. Tag: `correctness`.
- Location: `plan.md:225`, `412-416`; `thinkpad-prompt.txt:3`, `7`.
- Defect: on the thinkpad, `pings`, `healthy-diet`, and `personal-styles` have no remote, and
  neither do the three tar targets, so the thinkpad copy may be the only copy of any work done
  there. "Refuses a target with unpushed or uncommitted work" is undefined for a repo with no
  upstream. Under one reading every branch counts as unpushed, so cleanup refuses everything and
  check 5 fails. Under the other, a branch with no upstream reads as clean, and thinkpad-only
  commits are deleted. Plain dirs have no unpushed state at all. Geoff's tar ruling covers
  pavilion's three copies only, and the thinkpad run goes from dry run to removal with no pause.
  The thinkpad also acts on `scope.tsv` retire rows, not on the approved manifest.
- Proposed fold: `thinkpad-cleanup` reads the approved manifest (M1) from the committed dry-run
  doc and compares each remote-less target with pavilion's `expect` facts: HEAD and branch tips
  for git targets, and a content hash or newest mtime plus file count for plain dirs. An identical
  target is removed. A differing target is refused and listed for Geoff, never removed. A
  differing tar target is added to a thinkpad tar under the B2 rules before any removal. Add an I6
  fixture: a remote-less repo with one extra commit must be refused.

### M7. C5 can delete `ecxc-ski-agent-memory` before S-ecxc-ski folds it

- Severity: major. Tag: `correctness`.
- Location: `plan.md:401`, `114-119`; `ecxc-ski-prompt.txt:8`.
- Defect: C5 runs after R2's stage, which follows the dry-run approval. S-ecxc-ski launches only
  after PR 1 merges, and PR 1 waits on I9, which waits on all eleven decisions. C5 can therefore
  run first. The fold then reads a missing folder and may report "nothing to fold". The tar holds
  the data, but nothing points the fold at it.
- Proposed fold: C5 removes `ecxc-ski-agent-memory` only after the ecxc-ski PR's fold commit is
  pushed (checked through `gh api`), or S-ecxc-ski reads the folder from the verified archive by
  path. Either way, S-ecxc-ski stops if neither source exists.

### M8. Memory-file and account reads reach outside the scope list

- Severity: major. Tag: `correctness`.
- Location: `plan.md:52`, `188`, `126`, `203`, `236`; `thinkpad-prompt.txt:10`.
- Defect: the scope list is the only list of repos, but three reads bypass it:
  - The memory scope is the bare glob `~/.claude/projects/*/memory/*.md`, which on pavilion takes
    3 project directories outside the candidate list. `refs apply` and its pre-write tar read and
    can rewrite memory that belongs to a repo the pass must never read.
  - I5's account-wide Worker read is right for sharing, but I8 then lists "every shared resource
    left in place" in a committed, public brief. A `shared-with` naming a Worker outside the list
    can name the excluded repo.
  - I3's one-executor check through `claude agents --json` sees every session's `cwd`.

  The mode-`000` fixture tests only the directory read and none of these three paths.
- Proposed fold:
  - Map each memory directory's project slug back to a repo and keep only `edit` and `read` rows,
    in `refs` and in its tar.
  - The inventory reports sharing outside the scope list as `shared-out-of-scope` with no name, in
    every committed or handed-over file.
  - I3 filters `claude agents` rows to `cwd`s under in-scope checkouts before using them.
  - Extend Review Focus 3 or 4 with a fixture memory directory for an out-of-scope slug: apply
    must neither read nor tar it.

### M9. The conductor runs the tools from a worktree an executor is still editing

- Severity: major. Tag: `correctness`.
- Location: `plan.md:95`, `110`; `conductor-prompt.txt:24`.
- Defect: C1, C4a, and C4b run the tools "by path from its worktree until PR 1 merges". The
  initiatives executor keeps editing, merging pairs into, and committing that worktree through I9.
  An inventory run mid-edit can mark resources `sole-owner` from a half-written resolver, and I8's
  check (every teardown id is `sole-owner` in the inventory output) reads that same output, so
  the check can't catch it. This breaks the global rule against reading a file's current state
  while another agent edits it.
- Proposed fold: the conductor runs each tool from `git -C <worktree> archive <pushed sha>`
  unpacked into `~/.local/state/repo-organization/tools-<sha>/`, with the sha taken from the
  pushed branch through `gh api`. Each output records that sha, and I8 rejects inventory output
  whose sha isn't an ancestor of its own head.

### M10. A code change between the extract pin and W6's deletion is lost

- Severity: major. Tag: `correctness`.
- Location: `plan.md:110`, `56`, `342`.
- Defect: the map header records one pinned commit (I3's start), and the extracts pin their own
  later commits. W7's draft check diffs "`<pinned commit>` origin/main over every moved path".
  Applied to code rows with I3's pin, the check fails falsely on legitimate changes the extract
  already carried, and its remedy ("re-copied by its destination's session") doesn't apply to
  history-carrying code. Applied to code rows with no pin at all, a queue fix merged to
  `workstation` after C4b goes uncaught, and W6 deletes it. The fold record measured that the last
  six `workstation` merges touched the queue.
- Proposed fold: each map row carries its own `pin` column, I3's commit for docs and C4a's or
  C4b's for code. The draft check diffs per row from its pin. A non-empty diff on a code row stops
  for a cherry-pick into drafter or approval-queue, never a re-copy. Add the hit to the draft
  check's fixture.

### M11. The thinkpad pull can leave a conflicted tree that stow then links into `~/.claude`

- Severity: major. Tag: `correctness`.
- Location: `thinkpad-prompt.txt:9`; `plan.md:416`.
- Defect: step 4 guards only against uncommitted changes in files the merge touches. A thinkpad
  main checkout with an unpushed local commit (likely on a laptop) is pulled as a merge. It
  produces a merge commit, or on a modify/delete of a moved doc it stops mid-merge with conflict
  markers. The step then runs `stow -R bin claude` from that tree. If `~/.dotfiles` is
  mid-conflict, a skill or `CLAUDE.md` with conflict markers goes live in `~/.claude`.
- Proposed fold: pull with `git pull --ff-only`. A repo that can't fast-forward is reported stale
  and left untouched. Run stow and both installs only if `~/.dotfiles`, drafter, and
  approval-queue all fast-forwarded. Otherwise stop for Geoff before stow.

## Minor

### m1. An R1 rerun after a crash between a delete and its log row wedges the stage

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:264`; `retire-prompt.txt:14-15`.
- Defect: the log is appended after the act, and "any API error stops the stage". A crash after a
  successful delete and before its row means the rerun gets a 404, which stops the stage for good.
  No data is lost, but the line stalls.
- Proposed fold: on a 404 from a delete whose GET also returns 404, log the row `already-absent`
  and go on. Push the log after each item rather than each stage, since W8 and C5 read it from
  GitHub.

### m2. Duplicate queue titles make "find its id under the title" ambiguous

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:53`, `103`; `retire-prompt.txt:5`; every sweep prompt's step 1.
- Defect: a killed hand-over loses its item (the `EXIT` trap) and a rerun makes a new id under the
  same title, as does a reject and resubmit. A session reading the first row may act on a stale
  approve, or wait forever on a dropped id.
- Proposed fold: each `items.tsv` row carries a state (`open`, `decided`, `superseded`), and the
  conductor marks the older row `superseded` when it resubmits. Readers take the newest
  non-superseded row per title and refuse when there is more than one.

### m3. C5's worktree removal isn't limited to `edit`-role repos

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:119`, `224`.
- Defect: the worktree listing covers "every worktree in scope", including `aksailingclub-legacy`
  (`read`). A `git worktree remove` there writes legacy's `.git`, which the pass must never edit.
- Proposed fold: the removable rules add a sixth condition, that the worktree belongs to an `edit`
  row. A legacy worktree goes into the dry-run list as "left for the cutover".

### m4. W8 has no guard against retiring a secret that a survivor uses

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:329`.
- Defect: the inventory finds secrets whose "Used by" points into a target. `registry.md` names
  `pings` in other secrets' sections too, and a careless parse could list `CLOUDFLARE_API_TOKEN`.
  Geoff's approval is the only guard, and the cost of a wrong delete lands mid-pass.
- Proposed fold: W8 refuses any name whose registry "Used by" names a non-target, any name in
  `sync.sh`'s `WORKER_SECRETS`, and a fixed deny list (`CLOUDFLARE_API_TOKEN`, `CF_ZT_TOKEN`, the
  GitHub App keys). It stops for Geoff on a hit.

### m5. The draft check proves destinations exist, not that they hold the source content

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:342`.
- Defect: a truncated or wrong copy in dubplate, poplar, or initiatives passes, and W7 then deletes
  the source and points every reference at the bad copy. History keeps the original, so the cost
  is silent drift rather than loss.
- Proposed fold: for every row not in a `collision-*` state, compare the destination blob on its
  `origin/main` (through `gh api`) with the source blob at the row's pin.

### m6. C0 makes initiatives public without a scan of its history

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:86`.
- Defect: the history is clean today (probe), but C0 has no check, and the repo becomes public
  before any executor's guard applies.
- Proposed fold: C0 runs `gitleaks git` and the scope-name check (no repo name outside the
  candidate list) over the local history before `gh repo create --public`.

### m7. `teardown.tsv` "on origin" names no branch

- Severity: minor. Tag: `correctness`.
- Location: `retire-prompt.txt:5`.
- Defect: before PR 1 merges, the file lives on a branch that I9 keeps pushing to.
- Proposed fold: superseded by M1. If M1 isn't taken, compare against the branch head recorded at
  the dry-run hand-over.

### m8. Memory rewrites race live sessions

- Severity: minor. Tag: `optional`.
- Location: `plan.md:126`; `thinkpad-prompt.txt:10`.
- Defect: temp-and-rename protects the file, but a session that writes a memory file between the
  tool's read and its rename loses its update.
- Proposed fold: run C6's and T1's apply only once `claude agents --json` shows no other live
  session, or skip any file whose mtime changed since the read and rerun.

### m9. OWNER FORK: export scratch and staging D1 and R2 data before teardown

- Severity: minor. Tag: `optional`.
- Location: `plan.md:262-266`; design `:55`.
- Defect: D1 Time Travel ends when the database is deleted, and an R2 bucket must be emptied
  first, so R1 destroys `asc-staging` and `cairn-scratch-b-auth` data irreversibly. The design
  rules that this data is scratch and staging, so this is a choice about taste and risk.
- Options:
  - (a) Delete as designed.
  - (b) Run `wrangler d1 export` for each D1 id into the B2 archive first, which takes a few
    minutes and adds no new tool.
- Recommendation: (b), since the archive already exists and cairn-cms records cite scratch
  evidence.

### m10. Neither machine rechecks `values.age` right before its pull

- Severity: minor. Tag: `correctness`.
- Location: `plan.md:237`, `416`; `thinkpad-prompt.txt:9`.
- Defect: Geoff's by-hand check on the thinkpad happens at dry-run time, possibly days before T1.
  A thinkpad `secret-receive` in between dirties the store again, and nothing at T1 says to keep
  it.
- Proposed fold: T1's step 4 starts with `git -C ~/.dotfiles status --porcelain secrets/`. A
  non-empty result stops for Geoff, under M4's never-discard rule.

### m11. Over-ceremony: R2 waits on W8's store commit for no integrity gain

- Severity: minor. Tag: `optional`.
- Location: `plan.md:270`; `retire-prompt.txt:11`, `16`.
- Defect: no GitHub deletion depends on the age-store commit, and the store commit on an unmerged
  branch protects nothing R2 touches. The wait threads R2 and C5 behind W8 (60 minutes plus any
  1Password wait) and adds a cross-session poll. The design's stage order asks for the wait, so
  dropping it is contestable.
- Proposed fold: let R2 follow R1 directly and keep W8 after R1. The design's order then holds
  for the Cloudflare stage, which is the only one the store edit depends on. Record the departure
  in the plan header. The saving is off the critical path, so it's worth taking only if it costs
  no review round.

## Checked and sound

- The approved doc is a copy taken at hand-over, and a decided item can't be re-decided in the app.
  So Geoff's approval binds one fixed text (M1 adds the hash that makes it checkable).
- Design integrity findings M1 (copy-to-delete window), M6 (age-store race, via workstation#69,
  now merged at `b7807f0`), M7 (filter-repo on a fresh pinned clone without `--force`, with
  commit-map verification), m3 (install through a folded link, Review Focus 1), and m4 (queue moved
  after the dry run, plus the before-merge `pgrep` step) are carried into tasks with tests.
- GitHub deletes precede local removals, so each remote-backed local clone survives until after
  its remote is gone. A rerun of `rm` on an already-removed directory is harmless once C5 logs
  per item (B2).
- The merge order is enforced at the one irreversible point: the workstation PR's Before merge
  steps confirm the drafter and approval-queue merges and rerun the draft check.
