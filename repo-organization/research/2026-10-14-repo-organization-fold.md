# Repo organization design: fold record

Target: `repo-organization/specs/2026-10-14-repo-organization-design.md`, reviewed at `9da8e85` and
revised in place as commit `090cc92`, then revised again by the second round below
(uncommitted). Reviews folded:
`2026-10-14-repo-organization-review-mechanics.md` (32 findings),
`2026-10-14-repo-organization-review-contract.md` (19), and
`2026-10-14-repo-organization-review-integrity.md` (20).

Totals: 71 findings. 55 folded, 1 refused, 12 dropped as `optional`, and 3 owner forks. Within
folded findings, five proposed sub-mechanisms are refused, each with its reason: a GitHub CI for
`drafter`, two check-drift legs, a workstation CI check, and a resume journal. The mechanics
review's probe note about a concurrent session is refuted. Two findings
the reviewers raised as forks had one clearly correct answer and are taken (mechanics m10, m11).

## Verification

Each fold below rests on a read-only probe made on pavilion on 2026-10-14:

- `claude-tooling-sync` contains no "workflow" string (`grep -c` returns 0), so `verify` can't see
  `~/.claude/workflows`.
- `~/.claude/workflows -> ../.dotfiles/claude/.claude/workflows`, and `docs-page-chain.js` is its
  only file. A scratch stow probe with a real target `.claude` directory showed three things:
  deleting the package file leaves the folded link dangling, `stow -R` removes that link, and a
  real directory made in its place then holds an outside link and a later stowed file side by
  side.
- The workflow shells out to `cairn-docs-outline` (lines 783, 819, 1106).
  `tests/docs-page-chain-derivation.test.mjs:12,304` reads both agent files repo-relative.
  `~/Projects/drafter` has no `.github/`, and its `check:` target is `vet lint test`.
- `claude/.claude/CLAUDE.md` is 199 lines against `CLAUDE_MD_LINE_CAP` of 200.
- `git filter-repo` isn't installed, and Homebrew offers `git-filter-repo` 2.47.0. The manual
  (`Documentation/git-filter-repo.txt`) says "renames are NOT followed so you may need to specify
  multiple paths" and "It is a really bad idea to get in the habit of always specifying `--force`".
  Commit `27a7a16` renamed `review-desk` to `approval-queue`.
- `tests/approval-queue.test.sh:209` reads `claude/.claude/docs/voice/approval-brief.md`
  repo-relative. `bin/.local/bin/approval-queue:23` finds the app at `../../../approval-queue`
  from its own realpath. `src/lib/brief.ts` sets `REGISTER_PATH` to
  `~/.claude/docs/voice/approval-brief.md`.
- `aksailingclub-org/CLAUDE.md:196` says `aksailingclub-legacy` "serves the LIVE site today".
  Legacy carries `deploy.yml` plus the daily `sync-editors.yml` and `verify-secrets.yml` crons,
  and `secrets/values.age` with `registry.md`. D1 `59a1f106-...` is bound by both legacy wrangler
  configs and by `aksailingclub-org/wrangler.toml:50`.
- `cairn-cms/ROADMAP.md` is 3,851 lines with 284 top-level bullets. CI workflows and check
  scripts reference it.
- `cairn-scratch` and `ecxc-ski-agent-memory` aren't git repos, and `aksailingclub-sveltekit`'s
  gitfile points at no valid repository. `SECOND-WORKSTATION.md` says the 2026-10-12 handoff
  bundle, kept on R2, holds all six local-only directories.
- `log-issue/SKILL.md` carries `roadmap_path` and the `#project:slug` tag.
- The dotfiles memory directory holds only `MEMORY.md` and `MEMORY.md.tmp`, so
  `batched-docs-tool-initiative.md` isn't on pavilion.
- Two of the three dubplate specs checked differ from dubplate's same-named files, and the
  go-rewrite plan is identical.
- `CAIRN_SCRATCH_CF_TOKEN` is an account-owned token (`registry.md:249`), and the managed token
  lacks API-token management (`cloudflare-estate-inventory.md:26`).
- The `~/.dotfiles` origin is `glw907/workstation.git`, and `yq` is mikefarah v4.54.1.

Facts the reviewers lacked, from the planning session: the `~/.dotfiles` branch switch the
reviewers saw was the planning session landing PR #68, and no other session works that checkout.
The dirty `secrets/values.age` predates this session and isn't this pass's, though the race it
creates is real. The `top-bar-tidy` worktree has no live session. Drafter pass 5 is live, and
this pass's drafter moves wait for its PRs to merge.

## Dispositions

Convergent findings fold once at a root, named R1 to R10, and each member points at its root.

### Roots

- **R1. Cloudflare ties and teardown.** Folded in "Repo retirement", steps 2 to 4. Ties come from
  each target's own files, never from names. Resources are resolved by id across every surviving
  repo and marked `sole-owner` or `shared-with`, and only `sole-owner` resources are torn down.
  The step lists the full set of resource kinds. The script sources its secrets and fails on any
  API error, and its known-ties fixture keeps it from passing on an empty result. The dry run
  lists shared resources and a "by hand" section.
- **R2. Reference tool scope and resolution.** Folded in "Migration of past work". One tool with
  check and apply modes covers one scope. The map is keyed on (repo, path), bare paths resolve
  against the containing repo, and the patterns cover old paths, new paths, moved code, retired
  repos, and retired ROADMAPs. The scope is git-tracked text read from pass worktrees, with named
  fixture exclusions, memory `*.md` only, a tar before the first write, temp-and-rename writes,
  realpath deduplication, and an idempotence check. The per-machine baseline and the
  goldens-after-extract order also land here.
- **R3. Thinkpad divergence.** Folded in "Repo retirement" step 6 and "End-to-end check" 1. The
  thinkpad script runs the refuse-on-dirty legs, prints a dry run, records its own baseline
  before it pulls, and rewrites its own memory.
- **R4. The drafter workflow link.** Folded in "Code leaving workstation", following the stow
  probe. The install runs after `stow -R claude`, makes a real directory, and uses `ln -sfn`. End
  to end check 4 asserts the realpath and a clean `~/.dotfiles`.
- **R5. History extraction.** Folded in "Code leaving workstation". The extract runs on a fresh
  GitHub clone at a pinned SHA, never with `--force`, and lists every historical path. The tip
  tree and `git log --follow` are checked before the push, and `git-filter-repo` is installed
  through the Brewfile.
- **R6. Merge and move order.** Folded in "Migration of past work", steps 1 to 5. The extracts
  merge before `workstation`'s deletions, and each machine restows and installs. The deletion PR
  stays a draft until every destination exists and the moved paths show no diff since the source
  commit. The queue moves after the dry run.
- **R7. ROADMAP retirement reach and count.** Folded in "Rules and tooling". It defines an entry
  as a top-level bullet or a `###` heading, requires the applied dispositions to equal each
  repo's count, and lists every consumer: `log-issue`, the `#project:` tags,
  `project-tracking.json`, seven skills, and `claude-memory-write-check`. `log-project` never
  creates a ROADMAP, and end-to-end check 6 asserts none remains.
- **R8. The SessionStart hook.** Folded in "Rules and tooling" and "End-to-end check" 2. The repo
  name comes from the `origin` basename through `--git-common-dir`. The YAML gains `summary:`, and
  `repos` takes GitHub names only (the records table is corrected). The hook names its output
  states and always exits 0, and its tests cover those states.
- **R9. Worktree removal.** Folded in "Worktrees and descriptions". It defines "merged" through a
  merged PR or an ancestor of `origin/main` after a fetch. Removal also requires the worktree to
  be unlocked, have no process, be clean under `--ignored`, and be untouched for a day. A branch
  that equals its base is treated as new. Pass 5's worktrees wait for its PRs to merge.
- **R10. Retired-target inventory and post-check.** Folded in "Repo retirement" steps 1, 5, and
  6, plus "End-to-end check" 5. The inventory reports each target's kind, the remote branches,
  issues, and releases of each GitHub repo, and the parent-repo PRs of each fork. Each target is
  worked in a fixed order, and a rerun treats a finished step as done. The post-check confirms
  the deletions.

### Mechanics review

| Finding | Disposition |
|---|---|
| B1 shared and live Cloudflare resources | Folded, R1. The archive carve-out is moot under ruling 1. |
| B2 cairn-cms ROADMAP uncounted | Owner fork, ruling 3. The reference sweep is folded into R2 under any answer. |
| B3 moved tests read staying files; drafter has no CI | Folded in "Code leaving workstation": the helper moves, `WORKSTATION_DIR` resolves the agent files, and the legs join `drafter`'s local `make check`. A new GitHub CI is refused as new machinery, because both gates are local today. |
| M1 `verify` never checks workflows | Folded, R4. The "verify still tracks it" claim is removed, and check 4 asserts the realpath directly. |
| M2 folded stow link dangles | Folded, R4. The proposed check-drift dangling-link leg is refused: the order plus check 4 close the defect, and no measured defect remains for the leg to answer. |
| M3 renames dropped; filter-repo absent | Folded, R5. |
| M4 approval-queue test, CI, and layout | Folded in "Code leaving workstation": the layout is kept, `REGISTER` has a default, and the gate is local. |
| M5 a live 7907 server masks check 3 | Folded in "End-to-end check" 3 and in the leftover cleanup. |
| M6 bare paths are ambiguous; fixtures; goldens | Folded, R2. |
| M7 dubplate collisions | Folded in "Migration of past work" as the collision state. |
| M8 the baseline is per machine; transcripts in scope | Folded, R2 and R3. |
| M9 CLAUDE.md at 199 of 200 lines | Folded in "Rules and tooling": the change is one line, with lines moved to the archive if needed. |
| M10 the hook can't name the repo | Folded, R8. |
| M11 the order covers docs only | Folded, R6. |
| M12 six local-only directories, two not git | Folded in the brief's "Worth knowing" (count corrected, bundle stated) and R10. The backup question is ruling 2. |
| M13 ROADMAP reaches past three skills | Folded, R7. |
| m1 workstation and secret ties; resource kinds | Folded, R1 and R10, including the known-ties fixture. |
| m2 fork PRs live in the parent | Folded, R10. |
| m3 the cairn-run-gate test goes vacuous | Folded in "Code leaving workstation". |
| m4 `drafter-gate.sh` meaning | Dropped, `optional`. |
| m5 worktree scale and locks | Folded, R9. |
| m6 archive order and retired-repo triage | Dropped, `optional`. The archive half is moot under ruling 1. |
| m7 check-drift "behind" needs the network | Folded in "Rules and tooling" (`git ls-remote` with a timeout). |
| m8 memory index line and thinkpad copy | Folded in "Rules and tooling", together with integrity m6. |
| m9 remove the `delete_repo` scope | Dropped, `optional`. |
| m10 approval-queue visibility | Taken, not a fork: public. The extract's history is already public in `workstation`, so private hides nothing. Folded in the brief and "Code leaving workstation". |
| m11 runner against auth-data | Taken, not a fork: `runner` stays, and no ruling to raise the class is needed. With R1 and ruling 1, the only Cloudflare data destroyed is scratch and staging data (`asc-staging`, `cairn-scratch-b-auth`), listed by id in a dry run Geoff confirms. Recorded in "Scope". |
| m12 `#NN` autolinks | Dropped, `optional`. |
| m13 "about 41 paths" | Dropped, `optional`. |
| m14 `scripts/check` states | Folded in "The initiatives repo", with contract F5. |
| m15 first commit to an empty repo | Dropped, `optional`. |
| m16 design length | Dropped, `optional`. |
| Probe note: another session in `~/.dotfiles` | Refused: the planning session made that switch (fact 1), and no other session works the checkout. The one-executor checks stand regardless. |

### Contract review

| Finding | Disposition |
|---|---|
| F1 E2E 4 vacuous | Folded, R4 (converges with mechanics M1). |
| F2 the checker is blind to new paths | Folded, R2, with the planted missing-path fixture. |
| F3 hook repo mapping and silent missing clone | Folded, R8. Integrity m8 asked for silence on a missing clone, which conflicts. The one-line notice wins because it answers the defect F3 measured, and the hook still exits 0. |
| F4 no retirement post-check; vacuous inventory | Folded, R1 (fail on error, known-ties fixture) and R10 (end-to-end check 5). |
| F5 `scripts/check` passes on empty | Folded in "The initiatives repo". |
| F6 no ROADMAP check; "entry" undefined | Folded, R7. The re-estimate for cairn-cms's size goes with ruling 3. |
| F7 the map's total is never checked | Folded in "Migration of past work" (one row per entry, every row placed). |
| F8 history has no check | Folded, R5. |
| F9 the install writes into `workstation` | Folded, R4. |
| F10 E2E 3 blocks and names no fixture | Folded in "End-to-end check" 3 (committed fixture brief, then withdrawal). |
| F11 thinkpad baseline and memory | Folded, R3. |
| F12 historical fixtures and goldens | Folded, R2. |
| F13 rule and tooling promises have no check | Folded in "Rules and tooling" (one acceptance check per change, with failing fixtures) and in end-to-end check 6 (descriptions). The plan owns the individual checks. |
| F14 triage for retiring repos | Dropped, `optional`, and not a fork: the approved design already set one triage item per repo, so the question has an answer. Under ruling 1, legacy's ROADMAP leaves the pass anyway, and `healthy-diet`'s holds one entry. |
| F15 estimate breakdown | Dropped, `optional`. |
| F16 deferred plans have no tracker | Folded in "Migration of past work" (`deferred:<pass>` rows plus a backlog item). |
| F17 "merged" undefined | Folded, R9. |
| F18 status history untested | Dropped, `optional`. |
| F19 the thinkpad cleanup has no dry run | Folded, R3. |

### Integrity review

| Finding | Disposition |
|---|---|
| B1 archiving legacy freezes the live site | Owner fork, ruling 1. The teardown carve-out is folded, R1. |
| B2 rewrite scope reaches transcripts and binaries | Folded, R2. The premise that another session drives the checkout is wrong (fact 1), but the rule to work in a pass worktree and never through the symlinks stands. |
| M1 edits lost in the copy-to-delete window | Folded, R6 (the deletion PR's diff check). It answers a measured risk: the last six `workstation` merges touched the queue. |
| M2 merged and clean isn't safe | Folded, R9. |
| M3 deletions beyond the no-backup ruling | Owner fork, ruling 2. The non-git handling is folded, R10. |
| M4 name-matched ties | Folded, R1, with the "by hand" token revocation added to the brief. |
| M5 thinkpad divergence | Folded, R3. The proposed CI check on vacated paths is refused: `workstation` has no CI, and the reference tool's post-run plus the draft-PR check already catch a recreated path. |
| M6 the age store race | Folded in "Repo retirement" step 5. The dirty `values.age` isn't this pass's (fact 1), but the race is real. |
| M7 filter-repo source, verification, contention | Folded, R5. The `drafter` contention is handled by the pass 5 gate in "Scope". |
| M8 ambiguous paths; moved code missed | Folded, R2. |
| m1 merge order isn't enforced | Folded, R6. |
| m2 no resume after a crash | Folded in part, R10 (fixed order, rerun-safe). The journal TSV is refused: a rerun-safe order already covers resumption at lower cost. |
| m3 the install writes into `workstation` | Folded, R4. |
| m4 the queue moves while in use | Folded, R6, and in "Rules and tooling" (bootstrap installs both repos). The check-drift leg for a hook's missing command is refused as new machinery with no measured defect past the move window, which the order closes. |
| m5 GitHub-only branches | Folded, R10. |
| m6 memory file not on pavilion | Folded in "Rules and tooling" (take it from the thinkpad, or record it as lost). |
| m7 goldens mask drift | Refused: only the goldens whose path the map changes regenerate, and the PR diff shows each one. A scripted diff filter costs more than the risk it removes. |
| m8 the hook must fail soft | Dropped, `optional`. Its exit-0 half is in R8 anyway. |
| m9 folded memory in public repos | Dropped, `optional`. |
| m10 one tool rather than two | Folded as R2's mechanism, because R2's shared scope needs it, and the reviewer estimates it saves 20 to 30 path minutes. |

## Second round: fold verification

Source: `2026-10-14-repo-organization-fold-verification.md`, reading commit `090cc92` (14
findings: 6 major, 8 minor). Dispositions: 12 folded, 1 refused, 1 dropped as `optional`.

Probes for this round, run on pavilion on 2026-10-14:

- filter-repo 2.47.0's source (`git-filter-repo`, near line 3475) walks `.git/logs` and aborts
  with "expected at most one entry in the reflog for %s". Near line 4782 it writes
  `.git/filter-repo/commit-map` with an `old new` header. A scratch probe confirmed three
  outcomes: a plain clone runs, a clone reset to `HEAD~1` aborts with "Please operate on a fresh
  clone instead", and `git clone --revision=<sha>` (git 2.56.0) runs. The commit-map maps each
  old hash to its new one, and to zeros for a pruned commit.
- `gh repo view glw907/approval-queue` fails with "Could not resolve to a Repository".
  `cairn-pub`, `xcathletes-org`, `cairn-themes`, and `phonebook` are private.
- 16 `cairn-cms/docs` files cite `cairn-scratch/`. Outside the ROADMAP itself, `ROADMAP` appears
  in 105 tracked files in `dubplate`, 64 in `workstation`, 41 in `aksailingclub-org`, and 10 in
  `poplar`.
- `secrets/values.age` is modified in the `~/.dotfiles` main checkout (last commit 2026-10-13
  18:57), and `secrets/registry.md` has no `DRAFTER_API_KEY` line.

| Finding | Disposition |
|---|---|
| 1 pinning moves HEAD, so filter-repo refuses | Folded in "Code leaving workstation": the clone never moves HEAD, and it pins with `git clone --revision=<sha>` or records `HEAD`. Probed as above. |
| 2 `--follow` compares rewritten hashes | Folded in "Code leaving workstation": first commits are compared through `.git/filter-repo/commit-map`. Probed as above. |
| 3 unrewritten classes fail check 1 | Folded in "Migration of past work": moved code paths get map rows and are rewritten, history-file references to retired targets fall into a `retired-target` class that is listed and never fails, and live-file references are inventory ties edited by hand. Check 1 now excludes that class. Naming the tar path in the `cairn-scratch` citations is refused, because a local tar path resolves for no reader and the edit churns 16 history files. |
| 4 the Cloudflare post-check is vacuous | Folded in "Repo retirement" step 2 (`teardown.tsv` with kind and id) and end-to-end check 5 (query each id; fail on an empty file). |
| 5 `scripts/check` against missing and private repos | Folded in "The initiatives repo" and merge order step 1: CI skips the `repos` state, `scripts/check --repos` runs locally under Geoff's `gh` login, and `glw907/approval-queue` is created empty before the initiatives repo merges. The proposed `repos.txt` allowlist is refused, since it is a second list that can drift from GitHub. |
| 6 the age-store gate has no resolver | Folded, by the coordinator's direction, in the brief's "If you approve" step 2 and "Repo retirement" steps 4 and 5. A separate small `auth-data` PR in `workstation` commits the uncommitted `values.age` change with its `DRAFTER_API_KEY` registry entry, Geoff reads it before the pass starts, and the pass checks it has merged before it asks for the dry-run confirmation. |
| 7 the rulings never reach the queue as choices | Refused: Geoff ruled "yes to all" on 2026-10-14, so no choice is left open. The spec states each ruling with its date, and the brief adds no `### Decide:` block for them. |
| 8 the per-target order conflicts with one store commit | Folded in "Repo retirement" step 5: the order runs in stages across every target. |
| 9 the map omits the unplaced state | Folded in "Migration of past work": a `flagged` state blocks the copy, and a fixture entry must come out `flagged`. |
| 10 check mode on the thinkpad has no pass worktrees | Folded in "Migration of past work": the main-checkout ban applies to apply mode only. |
| 11 "only on pavilion" conflicts with the thinkpad bundle | Folded in the brief's "Worth knowing" ("have no remote") and "Repo retirement" step 6 (the thinkpad dry run lists the directories it holds). |
| 12 the class argument overstates | Folded in "Scope": "The only Cloudflare data it destroys". The same wording is fixed in mechanics m11's row above. |
| 13 F14 dropped without saying why it isn't a fork | Dropped, `optional`. The reason is now recorded in F14's row. |
| 14 the record calls the revision uncommitted | Folded in this record's header. |

## Estimate

The design estimate stays at 840 path minutes. Most folds pin down how the existing tasks run
(the inventory, the reference tool, the extracts, the end-to-end checks) and add little path
time. The scope they add is the ROADMAP consumer sweep, the helper move, the deletion-PR check,
and the retirement post-check. The recommended rulings remove about as much: legacy's archive and
store handling, cairn-cms's 284-entry triage (never in the 840, which counted about 80 entries),
and a second scanner (20 to 30 minutes). The net change sits well inside the recommended
ceiling. Under the "no" answer to ruling 3, the plan must re-estimate from cairn-cms's size before
it goes to Geoff.

## Rulings

Geoff ruled "yes to all" on 2026-10-14, through the planning session. The spec states each
answer with that date, and the brief carries no `### Decide:` block for them.

Answers: 1, yes. 2, yes. 3, yes.


1. **Should `aksailingclub-legacy` leave this pass, to be archived by the club's cutover pass
   after the soak?** Ruled: yes (Geoff, 2026-10-14). Recommendation was yes. Legacy deploys the live apex, `asc-ops`,
   `asc-handbook`, and `asc-uptime` Workers. It runs the daily Workspace sync, and it holds the
   ASC secret store. You agreed to archive it without knowing it was production.
   - Yes builds: the pass leaves legacy's GitHub repo, local clone, ROADMAP, and ASC store
     untouched, and the `aksailingclub-org` cutover plan keeps the archive step. This is the
     answer written into the spec.
   - No builds: before archiving, the pass moves the ASC store and `scripts/secrets/sync.sh` into
     `aksailingclub-org` and moves the Workspace sync cron. It also triages legacy's ROADMAP
     before the archive. The live site can't deploy a fix until the cutover, and the estimate
     grows.
2. **Should the pass save `cairn-scratch`, `ecxc-ski-agent-memory`, and `aksailingclub-sveltekit`
   to one tar archive outside `~/Projects` before it deletes them?** Ruled: yes (Geoff, 2026-10-14). Recommendation was yes. None of
   the three is a working git repo, about ten cairn-cms records cite `cairn-scratch` as evidence,
   and the archive is about 130 MB. Your no-backup ruling named only `healthy-diet`, `pings`, and
   `personal-styles`.
   - Yes builds: one tar step before the deletions, with its path in the dry-run item. This is
     the answer written into the spec.
   - No builds: the dry-run item names all three as unrecoverable, and the pass deletes them like
     the other three. Only the 2026-10-12 handoff bundle would still hold older copies.
3. **Should `cairn-cms`'s ROADMAP retire in its own follow-on pass under the `repo-organization`
   record, rather than in this one?** Ruled: yes (Geoff, 2026-10-14). Recommendation was yes. It holds 284 entries in 3,851 lines.
   Its "Toward 1.0" section is cited by CI workflows, check scripts, and the `cairn-release`
   skill, and it calls itself a pass dimension.
   - Yes builds: this pass retires the other ROADMAPs, about 80 entries, and leaves cairn-cms's
     file and its references in place. The follow-on pass re-homes "Toward 1.0" and rewires
     `cairn-pass` and `cairn-release`. This is the answer written into the spec.
   - No builds: this pass triages all 284 entries, moves "Toward 1.0" to a record or
     `docs/internal/`, and rewires the cairn CI and skills. The plan re-estimates first, and the
     design estimate grows well past 840 minutes.
