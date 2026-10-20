# Repo organization design: integrity and failure-risk review

Target: `repo-organization/specs/2026-10-14-repo-organization-design.md` at `9da8e85` (cited
below as `spec:N`). Lens: data integrity and failure risk. Each finding was checked against the live state
of pavilion on 2026-10-14, using read-only commands only.

Counts: 2 blockers, 8 majors, 10 minors (one of them over-ceremony).

## Blockers

### B1. Archiving `aksailingclub-legacy` freezes the live club site and strands the ASC secret store (OWNER FORK)

- Severity: blocker. Tag: `correctness`. Location: `spec:16`, `spec:162`, `spec:166`.
- Defect: `aksailingclub-legacy` is production. The `aksailingclub-org` CLAUDE.md
  ("The repo family") says it "serves the LIVE site today ... and stays authoritative until the
  cutover; it archives after the soak". `aksailingclub-org/docs/STATUS.md:16` says the apex cutover
  is still blocked. The repo's `.github/workflows/deploy.yml` deploys the Workers
  `aksailingclub-org` (the apex), `asc-ops`, `asc-handbook`, and `asc-uptime`. Its
  `sync-editors.yml` cron, "Daily Google Workspace Sync", ran successfully on 2026-10-12 and
  2026-10-13 and commits back to the repo. "Verify Secrets" ran on 2026-10-14. An archived repo
  runs no scheduled workflows and accepts no pushes, so the club's Workspace sync stops without
  notice and no fix can ship to the live site. The repo also holds the ASC project store
  (`secrets/values.age`, `secrets/registry.md`, `scripts/secrets/sync.sh`). Per
  `cloudflare-estate-inventory.md:93`, that store is the origin for the club's Stripe keys,
  Discord webhooks, Resend, Turnstile, and `CMS_BOT_PAT`. "With its local clone removed"
  (`spec:162`) takes away the only working copy from which those secrets can be rotated or synced.
  The rule at `spec:166` makes this worse. "The pass moves or tears down each tie before its repo
  goes, so no deployed resource outlives its source." Applied to legacy, that rule calls for
  tearing down the live apex, ops, handbook, and uptime Workers.
- Fold, OWNER FORK. Options:
  - (a) Take `aksailingclub-legacy` and its local clone out of this pass. The cutover pass's close
    archives it after the soak, as the ASC repo already plans. Recommended: this costs nothing now,
    and the archive belongs with the cutover.
  - (b) Archive now. First move the ASC store and `sync.sh` into `aksailingclub-org`, move the
    Workspace sync cron, and accept that the live site can't deploy until the cutover.
  - (c) Keep the GitHub repo unarchived and remove only the pavilion clone. Not recommended,
    because it still strands the store locally.

  Under any option, `spec:166` needs a carve-out: archive does not trigger teardown.

### B2. The rewrite scope reaches live transcripts, another session's checkout, binaries, and doubled paths

- Severity: blocker. Tag: `correctness`. Location: `spec:136`.
- Defect: "Applies the map across every repo, `~/.claude`, and the auto-memory files" sets no file
  filter, no write mode, no idempotence, and no deduplication. The live state shows five ways
  this corrupts data:
  1. `~/.claude` holds 89 session transcripts (`projects/*/*.jsonl`) that mention
     `docs/{specs,plans,research}`, plus `history.jsonl`, `file-history/` (rewind backups), `plugins/`,
     `sessions/`, and `.credentials.json`. Concurrent sessions append to these files, so an
     in-place rewrite loses writes and alters history that tools replay.
  2. `~/.claude/{docs,agents,workflows,instructions,output-styles,tooling,CLAUDE.md}` are stow
     symlinks into the `~/.dotfiles` main checkout, and another session is driving that checkout
     right now. During this review it switched from `roadmap-decide-bug` to `main`, and
     `secrets/values.age` is dirty, with changes this pass didn't author. A rewrite through
     `~/.claude` writes uncommitted edits into that session's working tree on whatever branch it
     holds, which breaks the one-executor rule.
  3. `~/Projects/workstation` is a symlink to `~/.dotfiles`, and the memory dirs exist under both
     `-home-glw907` and `-var-home-glw907`. A walk that follows symlinks, or that iterates over
     `~/Projects/*` and also `~/.dotfiles`, visits workstation twice. Single-repo docs keep the same
     relative tail (`docs/plans/x.md`) at their destination, so a rewrite that matches
     that tail isn't idempotent. A second visit, or a rerun after a crash, prefixes the path again,
     for example `~/Projects/dubplate/` twice.
  4. Nothing excludes binaries (`secrets/values.age`, PNG captures), `node_modules/`, `build/`,
     `.svelte-kit/`, lockfiles, `.git/`, `dubplate/_salvage/`, or other repos' test fixtures and
     testdata. Drafter `e2e/testdata` and the approval-queue `src/lib/fixtures/*.md` embed real
     paths, and rewriting them changes what the tests assert.
  5. `MEMORY.md.tmp` sits beside `MEMORY.md` in the dotfiles memory dir: the memory system writes
     through temp files, so the rewrite can race it.
- Fold: define the scope as an allowlist that the script and the reference checker share.
  - For each repo, take `git ls-files` in a pass worktree on a pass branch, never the main
    checkout. Keep text files only (`git grep -I`). Exclude lockfiles, `_salvage/`, and every
    fixture, testdata, or golden path the plan doesn't name for regeneration.
  - Reach the stowed `~/.claude` content only through the dotfiles pass worktree, never through
    the symlinks.
  - Rewrite memory only in `~/.claude/projects/*/memory/*.md`, excluding `*.tmp`. Write each file
    through a temp file and a rename, and tar those dirs before the first write.
  - Never touch transcripts, `history.jsonl`, `file-history/`, `plugins/`, or `sessions/`.
  - Dedupe by `realpath`, and match only whole old path tokens with their repo anchor.
  - Add a gate: a second run of the rewrite makes zero changes.

## Majors

### M1. Edits made during the copy-to-delete window are lost

- Severity: major. Tag: `correctness`. Location: `spec:134`, `spec:138-142`, `spec:148-152`.
- Defect: docs move by copying at a named source commit, and `workstation` deletes them later,
  when its PR merges last. Code moves by extracting at some commit and deleting later. Between the
  two, any session can commit to the workstation copy: a plan's status line, a drafter workflow
  fix, or an approval-queue change (the last six workstation merges all touched the approval
  queue). The deletion then drops those edits from the tip, and nothing compares the deleted
  content to the copy, so the loss is silent. The copy in the destination repo is now stale, and
  nobody knows.
- Fold: the workstation deletion PR carries a check, in CI or a pre-merge script, that
  `git diff <named source SHA> origin/main -- <every moved path>` is empty. It fails, naming the
  paths, when the diff isn't empty, and the pass re-copies or re-extracts those paths. Record the
  freeze in workstation's STATUS for the window.

### M2. "Merged and clean" isn't a safe test for removing a worktree

- Severity: major. Tag: `correctness`. Location: `spec:136` (final sentence), `spec:172`.
- Defect: `drafter` has 21 `agent-*` worktrees and a **locked** `p5-pipeline`, and `workstation`
  has `top-bar-tidy`. An agent worktree that was just created, before its first commit, counts as
  both merged (branch equals base) and clean, so the rule removes it from under a running agent.
  `git worktree remove` also deletes ignored files without asking. The rewrite only "skips stale
  worktrees", so active worktrees under each repo's `.claude/worktrees/` are inside its scan.
- Fold: before removing a worktree, the pass requires all of the following.
  - The worktree isn't locked, and `pgrep -f <path>` comes back empty.
  - No file under it was modified in the last N days.
  - `git status --ignored` lists nothing.

  Every worktree a session didn't create goes to the dry-run item. The rewrite skips every
  `.claude/worktrees/` path, active or stale.

### M3. Local deletions go beyond Geoff's no-backup ruling (OWNER FORK)

- Severity: major. Tag: `correctness`. Location: `spec:37`, `spec:160-161`.
- Defect: the ruling covers three local-only repos (`healthy-diet`, `pings`, `personal-styles`).
  Three more directories also have no recoverable copy:
  - `cairn-scratch` (2.7 MB) isn't a git repo. It holds `2026-08-16-capture`,
    `diagram-gate-before-after`, and `t4d-task7`, and about 10 cairn-cms records cite it as
    evidence (`docs/internal/record/2026-08-13-t4d-task7-live-proof.md`, among others).
  - `ecxc-ski-agent-memory` isn't a git repo either. It has a fold step, but no check that the
    fold is complete before deletion.
  - `aksailingclub-sveltekit` (129 MB) is a worktree of legacy whose `.git` gitfile points at a
    pruned entry. Every `git` command fails in it, so the inventory's checks for unpushed work,
    stashes, and dirty files can't see anything newer than `origin/sveltekit`.

  The inventory script assumes every target is a git repo.
- Fold, OWNER FORK. Options:
  - (a) Tar these three directories to one archive outside `~/Projects` before deletion.
    Recommended: about 130 MB, a minute of work, and it keeps the cited evidence.
  - (b) Extend the no-backup ruling to them explicitly in the dry-run item.

  Either way, the inventory handles non-git directories by listing their files and mtimes, and
  reports a broken gitfile as "cannot inspect" rather than "clean".

### M4. Matching ties by repo name binds the wrong resources and misses others

- Severity: major. Tag: `correctness`. Location: `spec:166-167`.
- Defect: names don't map one to one between repos and Cloudflare resources.
  - The Worker `aksailingclub-org` is deployed from `aksailingclub-legacy`, not from the
    `aksailingclub-org` repo.
  - The `asc-staging` Worker and the `asc-staging` D1 database belong to the retired SvelteKit
    shell, and neither name contains `aksailingclub-sveltekit`.
  - `CAIRN_SCRATCH_CF_TOKEN` is an account-owned Cloudflare API token. The managed token has no
    API-token management permission (`cloudflare-estate-inventory.md:26`), so the pass can't revoke
    it, and the steps under "If you approve" (`spec:18-24`) give Geoff no task for it.
  - The `pings` and `cairn-scratch-b` Workers are still live (confirmed with a GET on the account's
    Worker scripts), along with the registry's `PINGS_ADMIN_TOKEN`, whose "Used by" points into
    the repo being deleted.
- Fold: the inventory derives ties from each repo's own files: every `wrangler.*` `name` and
  binding, every workflow's deploy targets and Actions secrets, and the registry's "Used by" and
  "Rotate at" lines that point into the repo. It doesn't infer ties from names. The dry-run item
  gets a "Geoff does by hand" section, starting with the dashboard revocation of the
  scratch-site token.

### M5. Thinkpad divergence: deletions without inspection and memory left unrewritten

- Severity: major. Tag: `correctness`. Location: `spec:168`, `spec:178-180`.
- Defect: the inventory runs on pavilion. The thinkpad script "performs the same local cleanup"
  without running the unpushed-branch, stash, and dirty-tree checks against the thinkpad's own
  clones, which may hold work pavilion never saw. The thinkpad's
  `~/.claude/projects/*/memory/` files are machine-local, and the plan runs the rewrite only on
  pavilion, so the end-to-end check at `spec:180` fails there, or passes only against pavilion's
  baseline. Unpushed thinkpad commits that touch moved paths come back as modify/delete
  conflicts, or recreate files under `docs/` after the deletion PR merges.
- Fold: the thinkpad script first runs the inventory's refuse-on-dirty checks on every repo
  (`git status`, `git log @{u}..`, `git stash list`) and stops on any hit. It records its own
  pre-migration reference baseline before pulling, and it runs the memory rewrite locally.
  Workstation CI fails when a new file lands at a path the migration map vacated.

### M6. Deleting entries races the dirty age store

- Severity: major. Tag: `correctness`. Location: `spec:166` (age-registry ties).
- Defect: tearing down `PINGS_ADMIN_TOKEN` and `CAIRN_SCRATCH_CF_TOKEN` rewrites the whole
  encrypted `secrets/values.age`. That file is already modified and uncommitted in the
  `~/.dotfiles` main checkout by another session. Decrypting, editing, and re-encrypting from
  either session drops the other session's change, and git can't merge the binary. The same is
  true against the thinkpad's copy.
- Fold: the plan runs store deletions only after both machines report `values.age` clean and at
  `origin/main`. They run from the pass worktree in one commit with the `registry.md` edits, and
  the thinkpad pulls before any later store write.

### M7. `git filter-repo` extraction lacks a pinned source, a verification step, and a contention check

- Severity: major. Tag: `correctness`. Location: `spec:148-152`.
- Defect: "A throwaway clone of `workstation`" doesn't say what it clones. A local clone of
  `~/.dotfiles` takes whatever branch the concurrent session holds; this checkout switched branches
  during the review. Nothing forbids `--force`, which is filter-repo's only guard against
  rewriting a non-fresh repo such as the real checkout. Nothing verifies the extract before it's
  pushed to `drafter`, or to the new public `approval-queue` repo, which can't be force-pushed
  without rewriting public history again. `drafter` has 21 agent worktrees and a locked
  `p5-pipeline`, so an unrelated-history merge lands under active work.
- Fold:
  - Clone fresh from the GitHub origin at a pinned `origin/main` SHA, recorded in the migration
    map. Never pass `--force`.
  - Before pushing, check that the extract's tip tree equals `git ls-tree <SHA> -- <paths>` and
    that each moved file's commit count matches `git log --follow` in the source.
  - Run the one-executor check on `drafter` before the merge.

### M8. The reference checker resolves ambiguous paths and misses some of the moves

- Severity: major. Tag: `correctness`. Location: `spec:132`, `spec:136`.
- Defect: `cairn-cms`, `dubplate`, and the other repos have their own `docs/`. A
  bare `docs/...` there can mean the repo's own file or a workstation file, and a map
  keyed on the relative path can't tell them apart. The spec doesn't say which base the checker
  resolves against, so it can pass a reference that points at the wrong repo's file. The checker
  only matches `docs/`. It misses the moved code paths (`approval-queue/`,
  `docs-page-chain.js`, `scripts/drafter-gate.sh`) and references into deleted directories
  (`~/Projects/pings/scripts/...` in `registry.md:478-480`, the `cairn-scratch/` citations).
  References appear in three forms: bare, `~/.dotfiles/docs/...` (46 hits), and
  `/var/home/glw907/.dotfiles/...` (6 hits).
- Fold: key the map on (source repo, path). The checker resolves bare paths against the repo that
  contains them, and resolves the absolute and `~` forms literally. Extend its patterns to the
  moved code paths and to `~/Projects/<retired repo>/`.

## Minors

### m1. The merge order isn't enforced

- Severity: minor. Tag: `correctness`. Location: `spec:138-142`.
- Defect: a slip that merges the workstation deletion first leaves docs only in history, and an
  early reference fix leaves links dangling.
- Fold: the workstation deletion PR stays a draft until a script confirms that every destination
  path in the map exists on that repo's `origin/main`.

### m2. Retirement has no resume journal after a crash

- Severity: minor. Tag: `correctness`. Location: `spec:164-168`.
- Defect: after a partial run, rerunning the inventory against an already deleted repo fails,
  and a deletion that ran before its teardown orphans the resource.
- Fold: the script runs in a fixed order for each repo: Cloudflare teardown, then registry, then
  `gh` delete or archive, then local `rm`. It journals each step to a TSV in this initiative's
  `research/` and resumes from the journal.

### m3. The `drafter` install link writes into the workstation tree

- Severity: minor. Tag: `correctness`. Location: `spec:150`.
- Defect: `~/.claude/workflows` is a folded stow symlink to
  `~/.dotfiles/claude/.claude/workflows`. Linking `docs-page-chain.js` there creates an untracked
  file inside the workstation repo, which can be committed by mistake, conflict on restow, or
  confuse `claude-tooling-sync verify`.
- Fold: unfold that directory (`stow --no-folding`), or have the manifest name a link target
  outside the repo.

### m4. The approval queue moves while the pass relies on it

- Severity: minor. Tag: `correctness`. Location: `spec:22-23`, `spec:152`.
- Defect: the triage and dry-run items need the queue. A server already on port 7907 keeps
  serving from the deleted `~/.dotfiles/approval-queue/build`. Between restowing `workstation`
  and installing the new repo, on the thinkpad or on a restore, the `settings.json` hook calls a
  command that's no longer there.
- Fold: move the queue after Geoff confirms the dry run, and restart the server. Have
  `bluefin/bootstrap.sh` clone and install `drafter` and `approval-queue`, not only
  `initiatives`. `check-drift` warns when a command named in a hook is missing.

### m5. GitHub-only repos lose their branches unseen

- Severity: minor. Tag: `correctness`. Location: `spec:166`.
- Defect: `kit`, `displaywidth`, `jrnl-md`, `hugo-blog-template`, and `cairn-scratch-b` have no
  local clone, so "unpushed branches and stashes" finds nothing. `displaywidth` carries branches
  (`add-overrides`, `ignore-ansi`), and `kit` was pushed on 2026-10-13. Issues, releases, and
  Actions secrets go with each repo.
- Fold: for each repo, the inventory lists remote branches that aren't in the upstream, along
  with open issues and releases, and the dry-run item shows them.

### m6. The memory file to fold isn't on pavilion

- Severity: minor. Tag: `correctness`. Location: `spec:121`.
- Defect: `batched-docs-tool-initiative.md` is listed in the dotfiles `MEMORY.md`, but the file
  doesn't exist in any `~/.claude/projects/*/memory/` on pavilion. Only `MEMORY.md` and
  `MEMORY.md.tmp` are there. The fold-then-delete step has no source on this host.
- Fold: name the host that holds the file, or record that it's already lost. Delete the file only
  after the drafter record's commit contains its facts.

### m7. Regenerating goldens can mask unrelated drift

- Severity: minor. Tag: `correctness`. Location: `spec:136`.
- Defect: a full regeneration accepts every difference, not only the path substitutions.
- Fold: the gate requires that each changed golden line differ from the old one only by a mapped
  path pair (a scripted diff filter).

### m8. The SessionStart initiative print must fail soft

- Severity: minor. Tag: `optional`. Location: `spec:113`.
- Defect: a missing clone (on a restore, or before bootstrap runs) or a malformed YAML file
  shouldn't break session start.
- Fold: the hook prints nothing and exits 0, and `check-drift` reports the problem instead.

### m9. Folded memory lands in public repos

- Severity: minor. Tag: `optional`. Location: `spec:121`, `spec:161`.
- Defect: `ecxc-ski`, `drafter`, and `initiatives` are all public. Agent memory was written as
  private notes.
- Fold: give the folded facts one read for private content before the commit.

### m10. Over-ceremony: two tools scan the same scope separately

- Severity: minor. Tag: `optional`. Location: `spec:136`.
- Defect: the rewrite script and the reference checker each define what to scan. Building and
  testing two scanners costs time and tokens, and the two can drift. B2 then depends on both
  scopes staying identical.
- Fold: build one tool with `--check` and `--apply` modes over one allowlist. This saves an
  estimated 20 to 30 path minutes and closes the scope-drift risk.
