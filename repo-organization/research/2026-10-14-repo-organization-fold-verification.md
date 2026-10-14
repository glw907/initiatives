# Repo organization design: fold verification

Target: `repo-organization/specs/2026-10-14-repo-organization-design.md` at `090cc92` (cited as
`spec:N`), against the fold record `2026-10-14-repo-organization-fold.md` (cited as `fold:N`) and
the three reviews at `9da8e85`. This read had no part in the reviews or the fold. Every probe
below ran read-only on pavilion on 2026-10-14. The scratch probes are in this session's
`scratchpad/verify/`.

`node ~/.dotfiles/approval-queue/src/check-brief.ts design <spec>` exits 0.

Counts: 0 blocker, 6 major, 8 minor (14 findings).

## Closure of the reviews' blockers and majors

| Finding | Closed at | Verdict |
|---|---|---|
| Mechanics B1, integrity M4 (shared and name-matched Cloudflare ties) | `spec:193-195` | Closed |
| Mechanics B2 (cairn-cms ROADMAP) | Ruling 3, `spec:52`, `spec:117-119` | Closed as a fork |
| Mechanics B3 (moved tests read staying files) | `spec:170` | Closed. `drafter` has no `scripts/`, `tests/`, `bin/`, or `claude/` tree, so the unrelated-history merge can't collide |
| Mechanics M1, contract F1 (verify is blind to workflows) | `spec:172`, `spec:212` | Closed |
| Mechanics M2, contract F9, integrity m3 (folded stow link) | `spec:172`, `spec:162` | Closed. The fold's stow probe reproduces: the folded link dangles after the delete, `stow -R` removes it, and a real directory then holds the outside link beside a later stowed file |
| Mechanics M3, integrity M7, contract F8 (history extraction) | `spec:168` | Partial: findings 1 and 2 |
| Mechanics M4 (approval-queue test and layout) | `spec:174` | Closed |
| Mechanics M5, contract F10 (a live 7907 server) | `spec:176`, `spec:211` | Closed. The command's own header says one that leaves without a decision takes its item off the index, so withdrawal works |
| Mechanics M6, M8, integrity B2, M8, contract F2, F11, F12 (reference tool) | `spec:150-154`, `spec:209` | Partial: finding 3 |
| Mechanics M7 (dubplate collisions) | `spec:146` | Closed |
| Mechanics M9 (CLAUDE.md cap) | `spec:125` | Closed. `claude-context-budget:64` fails only on `-gt 200`, and the file is 199 lines |
| Mechanics M10, contract F3 (hook repo name) | `spec:121-123`, `spec:210` | Closed. `~/.dotfiles` has origin `glw907/workstation.git` |
| Mechanics M11, integrity m1, m4 (merge order) | `spec:156-162` | Closed, apart from finding 5 |
| Mechanics M12, integrity M3 (six local-only directories) | `spec:37`, `spec:192`, ruling 2 | Closed, apart from minor 11 |
| Mechanics M13, contract F6 (ROADMAP reach) | `spec:117-119`, `spec:214` | Closed |
| Contract F4 (retirement post-check) | `spec:194`, `spec:213` | Partial: finding 4 |
| Contract F5 (`scripts/check` passes on empty) | `spec:95` | Closed, but it can't build in the stated order: finding 5 |
| Contract F7 (map total) | `spec:146` | Partial: minor 9 |
| Contract F13 (rule and tooling checks) | `spec:133` | Closed by delegation to the plan |
| Integrity B1 (legacy is production) | Ruling 1, `spec:186` | Closed as a fork |
| Integrity M1 (copy-to-delete window) | `spec:148` | Closed |
| Integrity M2, contract F17 (worktree removal) | `spec:201` | Closed |
| Integrity M5 (thinkpad divergence) | `spec:197`, `spec:209` | Closed |
| Integrity M6 (age-store race) | `spec:196` | Partial: finding 6 |

The fold record's own probe facts check out: `claude-tooling-sync` holds no "workflow" string,
`yq` is mikefarah v4.54.1 on Brewfile line 15, `git filter-repo` is absent, the six local-only
directories exist under `~/Projects`, and the managed token lacks API-token management
(`cloudflare-estate-inventory.md:26`).

## Findings

### 1. Pinning the fresh clone makes `git filter-repo` refuse to run without `--force`

- Severity: major. Tag: `correctness`. Location: `spec:168`.
- Defect: the extract runs "on a fresh clone of `glw907/workstation` from GitHub, pinned at an
  `origin/main` commit the map records, never with `--force`". Pinning a clone by `git reset
  --hard <sha>` or `git checkout <sha>` adds a HEAD reflog entry. filter-repo 2.47.0's freshness
  check aborts when any reflog holds more than one entry ("expected at most one entry in the
  reflog for %s", `git-filter-repo` source near line 3475). A scratch probe confirmed it: a
  clone reset to `HEAD~1` aborted with "Please operate on a fresh clone instead. If you want to
  proceed anyway, use --force", and a plain clone ran. As written, the step either stalls or
  invites the `--force` the spec bans.
- Fix: clone fresh with no later checkout or reset, and record the clone's `git rev-parse HEAD`
  in the map as the pinned commit. If a different commit is wanted, clone again rather than
  move the head.

### 2. The `git log --follow` history check compares commits whose hashes the extract rewrites

- Severity: major. Tag: `correctness`. Location: `spec:168`.
- Defect: "`git log --follow` on each moved file must reach the same first commit as in
  `workstation`". filter-repo rewrites every commit whose tree it prunes, so a hash comparison
  always fails. The scratch probe's `commit-map` shows old and new hashes differ wherever a
  tree changed. The check, as worded, can't pass on a correct extract, which on a
  `live-account` pass pushes the executor toward improvising or skipping it.
- Fix: compare through `.git/filter-repo/commit-map`, which filter-repo writes on every run:
  the first commit in the destination must map from the first commit in `workstation`. Author
  date plus subject is the fallback.

### 3. The reference tool matches references it never rewrites, so end-to-end check 1 can't pass

- Severity: major. Tag: `correctness`. Location: `spec:150`, `spec:154`, `spec:209`.
- Defect: the tool "edits only references that resolved to a moved `workstation` entry" (the
  173 docs rows), yet it also matches moved code paths, paths into retired repos, and links to a
  retired ROADMAP.md, and check 1 then fails on anything new. Nothing rewrites the other three
  classes, and two of them are large:
  - `cairn-cms` cites `~/Projects/cairn-scratch/` in at least nine record and history files
    (`docs/internal/record/2026-08-13-t5-task8-live-e2e.md` six times, `docs/HISTORY.md`, the
    `2026-09-08-polish-inputs` folds). All of them break once `cairn-scratch` is deleted.
  - Files that mention `ROADMAP` outside the ROADMAP itself: `dubplate` 105, `workstation` 64,
    `aksailingclub-org` 41, `poplar` 10, and others. Most are history docs, and a deleted
    ROADMAP has no new path to point at.
  - `registry.md:478-480` names `~/Projects/pings/scripts/`, and `bash/.bashrc:152` names
    `hugo-blog-template`.

  The baseline run happens before the deletions, so none of these is in it.
- Fix: give each class a disposition in the spec. Moved code paths get map rows and are
  rewritten. References into a retired repo or ROADMAP from a history file (`docs/superpowers/`,
  `docs/internal/record/`, `docs/internal/history/`, `HISTORY.md`) are reported as a
  `retired-target` class that check 1 lists but doesn't fail on. Under ruling 2's "yes", the
  `cairn-scratch` citations can name the tar archive's path instead. Live files (`registry.md`,
  `.bashrc`, skills) are hand-edited through the inventory's step 1 list.

### 4. End-to-end check 5's Cloudflare rerun passes vacuously after the deletions

- Severity: major. Tag: `correctness`. Location: `spec:193`, `spec:213`.
- Defect: step 2 derives Cloudflare ties "from each target's own files". Check 5 reruns that leg
  after the GitHub repos and local directories are gone, so it has no files to read and returns
  nothing whether or not the teardown ran. Contract F4 asked for a post-check that can fail, and
  this one can't. The known-ties fixture (`spec:194`) proves the pre-run, not the post-run.
- Fix: the pre-run writes every `sole-owner` resource with its kind and id to a committed TSV in
  this initiative's `research/`. Check 5 queries the Cloudflare API for each recorded id and
  fails on any that still resolve, and it fails if the TSV is empty, since `pings` and
  `cairn-scratch-b` are deployed today.

### 5. `scripts/check` rejects the first records, since `approval-queue` doesn't exist yet and two repos are private

- Severity: major. Tag: `correctness`. Location: `spec:95`, `spec:105`, `spec:106`, `spec:108`,
  `spec:158-159`.
- Defect: `scripts/check` fails on "a `repos` entry that isn't a `glw907` repo", and it runs in
  CI. The initiatives repo merges first (`spec:158`) with records that list `approval-queue`, but
  `gh repo view glw907/approval-queue` returns "Could not resolve to a Repository" today, and the
  repo is created only after the dry run (`spec:176`). The step cannot build in that order. Also,
  `cairn-themes` and `cairn-pub` are private, so a public repo's CI using its default
  `GITHUB_TOKEN` or no token gets a 404 for them and fails as well.
- Fix: check `repos` against a committed `repos.txt` allowlist that `scripts/check` validates
  locally against `gh repo list glw907` (which sees private repos), with CI checking only that
  every entry is in the allowlist. Or create `glw907/approval-queue` empty before the initiatives
  repo merges, and state how CI authenticates for private names.

### 6. The age-store gate waits on a dirty file no step resolves

- Severity: major. Tag: `correctness`. Location: `spec:196`, `spec:24`, `fold:57-58`.
- Defect: store edits run "only after both machines report `secrets/values.age` clean and at
  `origin/main`". On pavilion that file has been modified and uncommitted since 2026-10-13 22:29,
  and the fold record says it "isn't this pass's". No step and no "Geoff does by hand" line says
  who commits or discards it. Only Geoff can, since it may hold a real secret value. The
  retirement run would stall at step 5 after Geoff has confirmed the dry run. That makes this an
  unrecorded owner touchpoint.
- Fix: put "resolve the uncommitted `values.age` change on pavilion" first in the dry-run item's
  "Geoff does by hand" list (`spec:195`) and the brief's step 5 (`spec:24`). The plan checks the
  file before it asks for the dry-run confirmation, not after.

### 7. The three rulings never reach the approval queue as choices

- Severity: minor. Tag: `correctness`. Location: `spec:13`, `spec:16`, `spec:37`, `spec:52`,
  `spec:186`, `spec:188`, `fold:212-243`.
- Defect: the brief writes each ruling's recommended answer into the design and says "pending
  Geoff's ruling, see fold record" five times. The approval-brief register says "A choice only
  Geoff can make goes in a `### Decide:` block", and an approval returns only the `### Decide:`
  picks (`approval-brief.md:39`, `:83-85`). Geoff can rule on the evidence the fold record gives
  for each fork, but an approval in the queue records no answer to any of them. A click on
  approve without opening the fold record silently takes all three recommendations.
- Fix: add `### Decide:` blocks for rulings 1 to 3 to the brief, each with a yes and a no option,
  the yes marked `(recommended)`, a one-line consequence, and `Source:` naming the fold record.
  Keep the "pending" notes or drop them once the blocks exist.

### 8. Per-target retirement order conflicts with the single store commit

- Severity: minor. Tag: `correctness`. Location: `spec:196`.
- Defect: "works each target in a fixed order: Cloudflare teardown, then registry and age-store
  entries, then the `gh` delete, then the local directory" reads as target by target. The same
  step puts every store edit in one commit with the `registry.md` edits. Both can't hold unless
  the order runs step by step across all targets.
- Fix: state the order as stages: every teardown, then one store and registry commit, then every
  `gh` delete, then every local removal. A rerun skips a finished stage.

### 9. The map's enumerated states omit the unplaced entry

- Severity: minor. Tag: `correctness`. Location: `spec:146`.
- Defect: every row must have a new path or `stays`, `leaves-with-pings`, or `deferred:<pass>`,
  but the script also "flags an entry the rule can't place". A flagged row satisfies none of the
  states, so either the row check fails or the flag gets coerced. Contract F7's planted
  unplaceable fixture was also not carried over.
- Fix: add a `flagged` state that blocks the copy step until Geoff's call replaces it, and a
  fixture entry that must come out `flagged`.

### 10. Check mode on the thinkpad contradicts "never its main checkout"

- Severity: minor. Tag: `correctness`. Location: `spec:152`, `spec:197`, `spec:209`.
- Defect: the scope is "read from each repo's pass worktree, never its main checkout". The
  thinkpad has no pass worktrees, and its baseline and check 1 run against its own clones.
- Fix: limit the "never the main checkout" rule to apply mode, and state that check mode reads
  main checkouts on the thinkpad.

### 11. "Exist only on pavilion" conflicts with a bundle built on the thinkpad

- Severity: minor. Tag: `correctness`. Location: `spec:37`, `spec:197`.
- Defect: `SECOND-WORKSTATION.md` "The handoff bundle" says thinkpad-x1 built the 2026-10-12
  bundle holding all six directories, and step 6 runs the same cleanup on the thinkpad. The
  thinkpad may still hold copies, so "exist only on pavilion" may be false. That changes what
  ruling 2's tar would protect.
- Fix: say "have no remote" rather than "exist only on pavilion", and have the thinkpad script's
  dry run report which of the six it holds.

### 12. Scope's class argument overstates what the pass destroys

- Severity: minor. Tag: `correctness`. Location: `spec:54`, `fold:144`.
- Defect: "The only data it destroys is scratch and staging data" is true of Cloudflare data
  only. The pass also deletes three local repos with no backup and ten GitHub repos with their
  issues and releases. The argument for `runner` over `auth-data` rests on this sentence.
- Fix: "The only Cloudflare data it destroys is scratch and staging data, …".

### 13. Contract F14 was a marked owner fork and was dropped without a stated reason

- Severity: minor. Tag: `optional`. Location: `fold:169`.
- Defect: F14 (triage items for repos being deleted, and batching the small ones) was marked
  OWNER FORK and concerns Geoff's own queue time. The fold dropped it as `optional` but didn't
  say it isn't a fork. As a result, `healthy-diet`, which has no remote and is deleted in the
  same pass, still gets a triage item and a ROADMAP deletion commit.
- Fix: record in the fold why F14 is not a fork (the approved design already set one item per
  repo), or skip triage for repos in the deletion set, with any keeper entry riding in the
  dry-run item.

### 14. The fold record calls the revision uncommitted

- Severity: minor. Tag: `optional`. Location: `fold:3-4`.
- Defect: "revised in place (uncommitted)" is stale. The revision is commit `090cc92`.
- Fix: cite `090cc92`.

## Rulings

Geoff can rule each of the three forks on the evidence the fold record gives. Each states the
facts, a recommendation, and what each answer builds. Two gaps sit beside them. Finding 6 is an
owner touchpoint missing from the brief. Finding 3 changes what ruling 2's "yes" can offer: the
tar is also the only place the `cairn-scratch` citations could still point. The two forks the
fold took itself (mechanics m10 and m11) each have one clear answer and show in the brief and
Scope, which the skill allows.
