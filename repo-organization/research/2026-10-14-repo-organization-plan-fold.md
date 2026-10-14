# Repo organization plan: fold record

Target: `repo-organization/plans/2026-10-14-repo-organization-plan.md` and its launch prompts,
reviewed at `f2362ab` and revised as commit `657e621`, then revised again by the second round
below (uncommitted). Reviews folded:
`2026-10-14-repo-organization-plan-review-mechanics.md` (47 findings),
`2026-10-14-repo-organization-plan-review-contract.md` (52), and
`2026-10-14-repo-organization-plan-review-integrity.md` (24).

Totals: 123 findings. 105 folded, 14 dropped as `optional`, and 4 owner forks, all four ruled by
Geoff on 2026-10-14. No whole finding is refused. Three proposed parts of folded findings are
refused, each with its reason in its row. The launch prompts grow from 17 to 19:
`initiatives-drafter` and `workstation-drafter` carry the drafter follow-up.

New figures, after both rounds: path 1,130 minutes (was 875), task sum 3,070 (was 2,460). The
path is 1.35 times the design's 840 and under the 1,680 ceiling. If pass 5 lands after C7, the
follow-up chain adds up to 240, for 1,370. If a sweep repo beyond dubplate and poplar receives
docs, the main path can reach about 1,255. Both stay under the ceiling.

## Verification

Each fold rests on a read-only probe or a quoted source, run on pavilion on 2026-10-14:

- Isolation: The worktrees page, "How Claude Code enforces isolation", says: "The checks apply
  to the repository you launched Claude Code from. They also cover the main checkout a linked
  worktree is linked from." It also says: "None of them tracks which files a shell command
  writes, so a command that writes into the main checkout without running git there, such as `cp`
  or a shell redirect, isn't refused by them." The mechanics review's probe table on a real
  isolated session matches the page.
- The launch line: `claude --help` lists `--add-dir <directories...>`, a variadic flag.
- Filter-repo's version flag: In the 2.47.0 source, `print_my_version` (line 1752) prints a
  hash of the script, not a version.
- The secrets script: `secret-set.sh:33-36` hard-codes `RECIP`, `VALUES`, `LOCAL_SECRETS`, and
  `CACHE=/dev/shm/.age-key-$(id -u)`. `--delete` ends in `write_local "$NEW"`, and the script has
  a `--sync` mode. `sync.sh` declares `WORKER_SECRETS`.
- The queue command: `approval-queue` sets `id="$(date +%Y%m%dT%H%M%S)-$$"` and never prints
  it. Its EXIT trap removes `item.json` when no `decision.json` exists, and the `design` mode
  copies the brief to `doc.md`.
- R2's old wait: `gh api "repos/glw907/workstation/commits?path=secrets/values.age&sha=main"`
  already returns `b0084ec`, so a path-filtered commit list passes before W8 runs.
- Stow: No `.stowrc` exists in `~` or `~/.dotfiles`, and the installed version is stow 2.4.1.
- The agents list: `claude agents --json` rows carry `cwd`, `id`, `kind`, `name`, `pid`,
  `sessionId`, `startedAt`, `state`, and `status`.
- Pass-core rules: "Launch prompt" says a prompt "never says 'never merge' or 'end'
  outright". The self-merge paragraph lets only a pass whose highest class is `ordinary` merge
  its own PR.
- A deleted script: In a scratch probe, a running bash script whose file and symlink were
  deleted mid-run still printed its last line, so a waiting queue command needs no files on disk.

## Executor split

The mechanics review's M5 overturns the plan's isolation model. The guard covers only the launch
repo's main checkout, so an executor may run git in any other repo and write machine state by
shell. The relay through the conductor existed only for steps the old model ruled out, so it
goes:

- C1 (the local legs) moves into I8. The initiatives executor runs them itself, reading its
  worktree for its own repo's row.
- C4a and C4b (the extracts) move into D1 and A1. Each receiving executor makes its own extract
  in the state directory.
- C5 (the local retirement stage) becomes R3 in the retire session, after a new R0 that writes
  and verifies the archive before any destructive stage.
- The conductor keeps C0, C2, C6, C7, C8, and a new C9 that runs the drafter follow-up. Its sum
  falls from 235 to 170.

Two checks the reviews called unrunnable are runnable under the probe. I8's `git -C ~/.dotfiles`
targets another repo, so it stays in I8. W8's check on its own main checkout becomes a sha256 read
by path. The clock file is written with a Bash redirect, and the "watch 2x by hand" fallback and
its "Later" item are removed.

## Deviations from the design, and errata owed

The plan narrows or reorders these design mechanisms. The planning session applied the three owed errata (2, 5, and 8) to the design on 2026-10-14, in the commit after `19ca1cc`; the rest stand as recorded deviations:

1. **The memory scope.** The design's `~/.claude/projects/*/memory/*.md` glob reads memory
   directories of repos outside the scope list. The plan builds the directories from `scope.tsv`
   instead, to obey the rule that no step reads or names an outside repo (mechanics M8, contract
   M2, integrity M8).
2. **Check 3's mechanism (erratum owed).** The design checks for "a server whose working directory
   is under `~/Projects/approval-queue`". The command starts the server with `setsid -f node
   "$app/build"` and no `cd`, so the server's working directory is the caller's. The plan checks
   `/proc/<pid>/cmdline` for the build path instead. The design's check 3 sentence owes an
   erratum (mechanics M15).
3. **Workstation's deletions in two PRs.** Design merge order step 4 has `workstation`'s deletions
   merge last. Under ruling 2 the drafter half moves to a follow-up workstation PR, which merges
   after the drafter PR and after the main set. The order's intent, that no file goes without a
   home, holds within each set.
4. **The thinkpad cleanup's reach.** The design's step 6 has the thinkpad script report "the
   remote-less directories it holds". The plan limits it to the manifest's `retire` rows, which
   already name all six. The hard scope rule decides this, so it isn't a fork (contract M2,
   mechanics M9).
5. **A new prerequisite (erratum owed).** The design's brief lists one prerequisite PR, the
   `auth-data` store PR (#69). Ruling 1 adds a second, the G-picks fix, before any design item
   goes out. The brief's "If you approve" list owes an erratum naming it.
6. **The archive's contents.** Under ruling 3 the archive also holds a D1 export of each scratch
   and staging database. The design says only that the pass destroys scratch and staging data.
7. **Self-merge for ordinary sweep PRs.** pass-core lets only an `ordinary` pass merge its own PR,
   and this pass is `auth-data` at its highest. Ruling 4 lets the conductor merge a sweep PR
   whose diff touches no `runner` or `auth-data` path, on a green home, with one batched triage
   item to Geoff. The ruling's text named a task-scope review accept. The plan uses pass-core's own
   bar instead, an accepted whole-branch review with an empty "Found, not done" list, and sends a
   PR with a non-empty list to Geoff.
8. **The teardown list (erratum owed).** The design names `teardown.tsv`, and its check 5
   queries "each id in `teardown.tsv`". The plan replaces the file with `retire-manifest.tsv`,
   whose `cloudflare` rows serve that role. The check 5 sentence owes an erratum.
9. **The queue repo's first commit.** The design creates `glw907/approval-queue` empty. The plan
   creates it with one README commit, so the extract can arrive by PR.
10. **Check 2's mechanism.** The design opens a session in `drafter`. The plan runs the hook
   script from that directory, since a session can't be opened headlessly.

## Dispositions

Convergent findings fold once, at a root, and each member row points at its root.

### Roots

- **P1. The executor split.** Recorded in "Executor split" above, and in the plan's "How the work
  splits".
- **P2. G-p5.** The session half matches `conductor-drafter` or `drafter-p` followed by a digit,
  in live states only. The conductor's own row serves as a positive control, and a nonzero exit
  fails the check. The pass's own `*-repo-organization*` names never match.
- **P3. Queue items and decisions.** `items.tsv` gains `state` and `doc_sha256` columns. Ids are
  found by title, and every open row is re-handed after a restart. Wait loops fail once an item
  vanishes. A reader confirms the title, takes the newest row for it, and checks one `choices`
  entry per Decide block. Rejects have stated paths, including one for an executor that has
  already stopped.
- **P4. The retirement manifest.** I8 writes `retire-manifest.tsv` with an `expect` column and
  embeds it in the dry-run doc, and the conductor hashes the approved `doc.md`. R0 to R3, W8, and
  the thinkpad script act only on the manifest. Each destructive step rechecks its rows against
  the inventory at act time.
- **P5. The archive (R0).** The archive goes under `/var/home`, never on tmpfs. R0 writes it with
  no-clobber, checks `tar -c`'s exit, runs `tar -df`, and syncs. It logs the sha256 and runs
  before any destructive stage, and a rerun never rewrites it. Under ruling 3 it also holds the
  D1 exports.
- **P6. Scope hygiene.** One canary harness, owned by I3, replaces the mode-000 fixture.
  `scope.tsv`'s 26 rows are pinned, and a missing row path is handled. Memory directories come
  from the scope list, and outside binders are reported without a name. Agents rows are filtered
  to in-scope `cwd`s. A name check runs at every PR's close and before C0's push.
- **P7. The reference tool.** The baseline key is normalized, and rewritten paths resolve against
  the map. The symlink fixtures now pin what they claim, and the other cases gain positive
  controls.
- **P8. Per-row pins and the draft check.** Each map row carries a `pin`, read from `verify.txt`
  for a code row. The draft check compares blobs and counts rows, and a code-row hit stops for a
  cherry-pick rather than a re-copy.
- **P9. W8's store edit.** Four overrides make the test hermetic, under a temp `HOME` with a
  generated key and a failing stub `op`. The session merges `origin/main` just before the store
  commit, and a before-merge diff guards the binary file. C6 and T1 run `--sync`. Deny rules
  guard survivors' secrets, and a dirty store is never discarded.
- **P10. The end-to-end tool (I10).** One tool runs the six checks with a `--host` flag, so both
  machines run the same commands. Each check has a fixture that fails on a planted violation and
  on an empty input list.
- **P11. Merge order and waits.** W7 waits on every receiver's merge, and every S, A, and D task
  receives its own map rows. Every restow passes `-d` and `-t`. Stops go to `stops.log`, and
  STATUS waits for C8.

### Mechanics review

| Finding | Disposition |
|---|---|
| B1 the launch line swallows the prompt | Folded: `--` before the prompt in the conductor's launch line and Geoff's thinkpad command. |
| B2 G-p5 fails on the pass's own drafter executor | Folded, P2. |
| M1 R2's wait passes at once | Folded in R2: the `compare/main...worktree-repo-organization` file list. |
| M2 W7's draft check can't pass when W7 runs | Folded, P11. The path is re-derived. |
| M3 W8's override can overwrite `~/.local/secrets` | Folded, P9. |
| M4 a W8 acceptance step is refused | Folded in W8: a sha256 read by path. |
| M5 the isolation model is wrong | Folded, P1. |
| M6 tools run from a worktree under edit | Folded, P1 and "Tools from a fixed copy". |
| M7 C5 can delete ecxc-ski-agent-memory early | Folded in R3 and S-ecxc-ski. |
| M8 the memory glob reaches outside the scope | Folded, P6. Deviation 1. |
| M9 thinkpad-cleanup implies a `~/Projects` scan | Folded in I6: `retire` rows only. Deviation 4. |
| M10 W4's acceptance can't pass | Folded: `brew list --versions`. |
| M11 queue items vanish on restart | Folded, P3. |
| M12 G-p5 gates PR 1 | Owner fork, ruled (b): ruling 2. |
| M13 the STATUS line dirties `~/.dotfiles` | Folded, P11 (`stops.log`). |
| M14 `teardown.tsv` isn't on origin | Folded, P4: the manifest is read from the approved `doc.md`. |
| M15 check 3 tests the wrong thing | Folded in I10. Deviation 2, erratum owed. |
| m1 the path is understated | Folded: the path is re-derived at 1,120. |
| m2 the pull rule blocks on the conductor | Folded in C6 and the conductor prompt. |
| m3 `stow` has no stow directory | Folded: `stow -d ~/.dotfiles -t ~`. |
| m4 no push targets in the conductor prompt | Folded. |
| m5 "never merge" wording | Folded although tagged `optional`, because pass-core's "Launch prompt" rule forbids that wording and "end" outright. Every prompt now says the conductor merges and names the session's last message. |
| m6 the workstation prompt points at a missing list | Folded: the list is inlined. |
| m7 A1's setup runs too early | Folded: `npm ci` after the extract merges. |
| m8 no reject path | Folded, P3. |
| m9 decisions trusted without checks | Folded, P3. |
| m10 check 3's withdrawal has no mechanism | Folded in I10: TERM to the waiting command. |
| m11 T1 pulls rows it shouldn't | Folded: `edit` rows only. |
| m12 T1 doesn't exclude `.claude/worktrees/` | Folded although tagged `optional`, because pass-core "Execute" requires the exclusion. |
| m13 one pin for everything | Folded, P8. |
| m14 Cloudflare scope gaps | Folded in R1: a pre-flight per kind, with 403 counted as failure. |
| m15 paired tasks may share `scripts/test.sh` | Dropped, `optional`. The plan states the glob and the harness owner anyway, since P6 needed an owner. |
| m16 mode 000 doesn't prove "never named" | Folded, P6. |
| m17 the queue repo isn't empty | Dropped, `optional`. |
| m18 W8's class against the design | Dropped, `optional`. |
| m19 I5 and I6 classes | Dropped, `optional`. |
| m20 S-dubplate pre-states a ruling | Folded although tagged `optional`: the old row stated a ruling Geoff hadn't made, so it read as a false fact to the executor. |
| m21 `gh repo delete` needs `--yes` | Folded. |
| m22 the thinkpad's secrets aren't regenerated | Folded with integrity M4 (P9): T1 runs `--sync`. |
| m23 the `pgrep` before-merge step | Folded: the step guards nothing, as the deleted-script probe shows, and its slot now carries P9's store diff. |
| m24 the three-sweeps cap | Dropped, `optional`. |
| m25 most of C1's relay | Folded, P1. |
| m26 the conductor prompt points at "Merge order" | Dropped, `optional`. |
| m27 the conductor's own launch line | Dropped, `optional`. |
| m28 `gh repo list` defaults to 30 | Folded although tagged `optional`: the name check builds its outside list from that call, and a 30-repo cap could miss a name. |
| m29 the initiatives prompt bans git in clones | Dropped, `optional`. P1 rewrote that line anyway. |
| m30 a PR rejected after its executor ended | Folded, P3. |

### Contract review

| Finding | Disposition |
|---|---|
| B1 the dropped Decide picks | Owner fork, ruled (a): ruling 1. The acceptance half is folded, P3. |
| M1 mode 000 doesn't prove "never read" | Folded, P6. The `strace` leg is refused: it isn't portable to CI, and the output canary already answers the measured risk, a leaked name. |
| M2 three inputs cross the scope list | Folded, P6. Its fork has one answer under the hard rule: deviation 4. |
| M3 the "no outside name" rule has no check | Folded, P6 (the name check). |
| M4 nothing pins `scope.tsv` | Folded, P6. |
| M5 sole-owner has only negative tests | Folded in I5: three positive and empty-list cases. |
| M6 the post-queries lack a positive control | Folded in R1, R2, and I10. |
| M7 G-p5 passes on an error | Folded, P2. |
| M8 the baseline key isn't normalized | Folded, P7. |
| M9 `refs check` reads unmerged destinations | Folded, P7. |
| M10 ecxc-ski-agent-memory deleted first | Folded with mechanics M7. |
| M11 manifest lines nobody removes | Folded in W8, with the `git grep -nw` acceptance. |
| M12 only two docs receivers | Folded, P11. |
| M13 two checks in isolated sessions | Folded for W8 (a sha256 read). The I8 half is refused: the M5 probe shows `git -C ~/.dotfiles` runs from the initiatives session, since only its own main checkout is guarded. |
| M14 Review Focus 2 isn't hermetic | Folded, P9. |
| M15 Review Focus 3 pins nothing | Folded, P7. |
| M16 Review Focus 5 needs `--follow` | Folded in I6: `--follow --diff-filter=A` and a pure `git mv`. |
| M17 the worktree rules have no positive case | Folded in I6. |
| M18 I4's idempotence case is vacuous | Folded, P7. |
| M19 the records equation is wrong | Folded in I9. |
| M20 W3's grep lets the executor pick the set | Folded in W3. |
| M21 C5's acceptance reads deleted state | Folded, P5, and in R3's logged verdicts. |
| M22 no executable end-to-end checks | Folded, P10. |
| M23 nothing proves the code rows | Folded in I3. |
| M24 the applied count has no measurement | Folded in W5 and the sweeps. |
| M25 the queue id has no capture | Folded, P3. |
| m1 counts lack a cross-check | Folded in I7. |
| m2 the Decide count | Folded in I3 and I9. |
| m3 W4's acceptance | Folded. |
| m4 the path figure | Folded: the path is re-derived. |
| m5 C0's acceptance | Folded. |
| m6 `--repos` has only a failing case | Folded in I1. |
| m7 I2 doesn't count records | Folded. |
| m8 W2's exit codes | Folded. |
| m9 the `deferred` state reads the live machine | Folded in I3 (stubbed list and STATUS). |
| m10 C6's porcelain check misses ignored files | Folded in C6. |
| m11 the memory fold has no acceptance | Folded in C6 and T1. |
| m12 W8 starts from a stale base | Folded, P9. |
| m13 Review Focus 1's checksum | Folded. |
| m14 the draft check's fixtures | Folded, P8. |
| m15 a ROADMAP gains entries | Folded in "Shared interfaces" and the sweep prompts. |
| m16 the app's choice labels | Folded in I7 and "Shared interfaces". |
| m17 `WORKSTATION_DIR` tests may skip | Folded in D1. |
| m18 C2 counts a later item | Folded: C2's acceptance is per item. |
| m19 the thinkpad store check has no evidence | Folded in I8 as a Decide block, which relies on ruling 1. |
| m20 a stale thinkpad checkout | Folded in I10's check 6. |
| m21 Review Focus 4 misses deploy workflows | Folded in I5 and Review Focus 4. |
| m22 one shared harness | Dropped, `optional`. M1's fold already builds one. |
| O1 sixteen PR reads | Owner fork, ruled (a): ruling 4. |
| O2 the retire session's cold start | Dropped, `optional`. |
| O3 PR 3's size | Dropped, `optional`. |
| O4 inline Review Focus | Dropped, `optional`. |

### Integrity review

| Finding | Disposition |
|---|---|
| B1 G-p5 matches the pass's own executor | Folded, P2, with mechanics B2. |
| B2 a rerun can overwrite the only backup | Folded, P5. |
| M1 the approved dry run is prose and unhashed | Folded, P4. |
| M2 no act-time recheck | Folded, P4: R1 per id, R3 per target. |
| M3 Access apps and DNS have no sole-owner rule | Folded in I5 (the hostname rule and its fixture) and R1 (the stage order). |
| M4 W8's stale base | Folded, P9. |
| M5 W8's test can clobber live secrets | Folded, P9, with mechanics M3. |
| M6 the thinkpad deletes differing copies | Folded in I6 and T1: compared with `expect`, and refused or archived. |
| M7 ecxc-ski-agent-memory deleted first | Folded with mechanics M7. |
| M8 memory and account reads reach outside the scope | Folded, P6. |
| M9 tools run from a worktree under edit | Folded, P1, with mechanics M6. |
| M10 a code change after the extract pin is lost | Folded, P8. |
| M11 the thinkpad pull can leave a conflicted tree | Folded in T1: `--ff-only`, and the restow runs only on three fast-forwards. |
| m1 an R1 rerun wedges | Folded in R1 (`already-absent`) and the per-item push. |
| m2 duplicate queue titles | Folded, P3. |
| m3 worktree removal outside `edit` rows | Folded in I6: the sixth rule. |
| m4 retiring a survivor's secret | Folded, P9 (deny rules). |
| m5 destinations exist but may differ | Folded, P8 (blob compare). |
| m6 C0 publishes unscanned history | Folded in C0. |
| m7 `teardown.tsv` names no branch | Folded, P4 (superseded by the manifest). |
| m8 memory rewrites race live sessions | Dropped, `optional`. |
| m9 scratch and staging D1 data | Owner fork, ruled (b): ruling 3. |
| m10 neither machine rechecks `values.age` | Folded in T1, step 4. |
| m11 R2 waits on W8 | Dropped, `optional`. |

## Second round: fold verification

Source: `2026-10-14-repo-organization-plan-fold-verification.md`, reading commit `657e621` (25
findings: 1 blocker, 8 majors, 16 minors). Dispositions: 25 folded. One proposed part is refused:
m15's bucket emptying. No finding is dropped.

Probes for this round, run on pavilion on 2026-10-14 in the session scratchpad:

- The name check, in a scratch repo with a bare `origin` and a branch. The old form,
  `git log -p origin/main..HEAD | grep -wF -f -`, exited 1 with a planted canary in the branch, so
  it can't catch anything. The new branch form, `git log -p origin/main..HEAD | grep -wF -f
  <(names)`, printed the canary and exited 0. On a clean branch it printed nothing and exited 1.
  The history form, `git log -p --all | grep -wF -f <(names)`, exited 1 on a clean history. It
  exited 0 on a canary that one commit added and a later one removed, and on a canary only in a
  commit message. The diff form, `git diff origin/main...HEAD`, missed both of those cases, so
  the plan uses the `git log -p` forms.
- The live fix, for C0's acceptance. The current build under `~/.dotfiles/approval-queue/build/
  server` has 0 files holding `decideCards`, which predates the fix. A scratch build of #71's
  commit `25f9449` (`npm ci && npm run build`) put `decideCards` in 4 files under `build/server`,
  among them `chunks/cards.js`. The 7907 listener's `/proc/<pid>/cmdline` reads `node
  /var/home/glw907/.dotfiles/approval-queue/build`, and `stat -c %Y /proc/<pid>` (1791999169) is
  at or after `build/server/chunks/cards.js`'s mtime (1791999168). So the check fails today and
  passes only after a rebuild and a restart. It needs no browser and no Host header.
- The D1 export, for ruling 3. `npx --yes wrangler@4 d1 export cairn-scratch-b-auth --remote
  --output <scratch>/probe.sql`, with the managed token sourced in the same command, exited 0 and
  wrote 41 lines with 5 `CREATE TABLE` statements and no virtual table. The file was shredded
  after counting. Cloudflare's import and export page says "A running export will block other
  database requests" and "Export is not supported for virtual tables, including databases with
  virtual tables". No global `wrangler` is installed, so R0 uses `npx`.
- R2's wait. `gh api repos/glw907/workstation/compare/main...design-decide-picks --jq
  '.commits[].commit.message'` returns each commit's message, so R2 can match W8's fixed subject
  rather than the capped `files` list.

| Finding | Disposition |
|---|---|
| B1 the name check is vacuous, and C0 has no form | Folded in "Shared interfaces" (the out-of-scope names entry), C0, and the conductor prompt. Patterns come through `<(...)`, a PR uses `git log -p origin/main..HEAD`, and C0 uses `git log -p --all`. Each must exit 1 clean, and a planted positive control must exit 0. Probed as above. |
| M1 merging the G-picks PR doesn't put the fix live | Folded in "Shared interfaces" (G-picks), C0, C2, and the conductor prompt. The planning session rebuilds and restarts after #71 merges, and C0 checks the build for `decideCards` and the server's start time against it. Probed as above. The reviewer's approve-a-fixture probe is replaced by this check, which needs no Decide from Geoff. |
| M2 the G-picks PR has no author or number | Folded: workstation#71, head `design-decide-picks`, owned by the planning session (dotfiles-32). |
| M3 T1's first step can't run | Folded in T1 and the thinkpad prompt: step 0 clones missing `edit` rows, a missing `read` row is `absent`, and a fresh clone's baseline comes from the clone. |
| M4 the thinkpad's manifest has no hash check | Folded: R0 logs `doc_sha256`, T1's step 0 compares the committed dry-run file with it, and P4's sentence now matches. |
| M5 W9 doesn't wait for PR 4 | Folded in W9, merge order step 6, the conductor prompt, and the W9 prompt. |
| M6 the D1 export is unprobed | Folded in R0 and the retire prompt: `--remote`, a stop on a failed or empty export before R1, and one listed `.sql` per D1 row. Probed as above. |
| M7 self-merge can take an `auth-data` diff | Folded in the sweep section, the conductor prompt, and every sweep prompt's last message. |
| M8 G-p5's live status is undefined | Folded: live means `state` isn't `done`, `p5-head` in the state directory carries the head name to D1 and I11, and a 72-hour stop goes to `stops.log` and Geoff. |
| m1 deviation 7 understates ruling 4 | Folded in deviation 7, the sweep section, and the conductor prompt. The executor's whole-branch accept with an empty "Found, not done" list serves as the review, and a PR with a non-empty list goes to Geoff. The conductor's PR hand-over line excludes self-merged PRs. |
| m2 the reader check is missing from two prompts | Folded in the workstation, dubplate, and poplar prompts. |
| m3 three departures and an erratum are unrecorded | Folded: deviations 8 to 10 and erratum 3 below. |
| m4 the path's assumptions are unstated | Folded in "Path" and the conductor prompt: the three-slot packing and the receiver assumption, with the 1,255 and 1,370 cases. |
| m5 W9's close has no minutes | Folded: a 30-minute close. |
| m6 R2's wait | Folded: W8's store commit gets a fixed subject and is pushed at once, and R2 matches it in `.commits[].commit.message`. |
| m7 the queue clone's timing | Folded in C2: created and cloned first, as its first acceptance. |
| m8 the session table cell | Folded. |
| m9 touchpoint 1 names a merged PR | Folded. |
| m10 standing answers leave out ruling 3 | Folded in the conductor prompt. |
| m11 R3 could remove C9's worktrees | Folded in "Shared interfaces" (the manifest leaves them out), R3, and the retire prompt. |
| m12 W9's session launches too early | Folded with M5. |
| m13 T1 has no clock file and pulls its own checkout | Folded in T1 and the thinkpad prompt. |
| m14 R3 can't recognize the fold commit | Folded: the fixed subject `S-ecxc-ski fold ecxc-ski-agent-memory`, set in S-ecxc-ski and matched in R3. |
| m15 a non-empty R2 bucket | Folded in I8 (each bucket's object count in the dry run) and R1 (a stop for Geoff). Emptying a bucket is refused: no sole-owner bucket holding objects is known, and emptying is unprobed data destruction that Geoff can rule on when the dry run shows a count. |
| m16 a failed wait has no resume | Folded in "Shared interfaces": the loop re-reads the newest open row on each pass. |

## Estimate

The first round re-derived the path to 1,120 minutes, against the old 875, and the task sum to
3,020, against 2,460. The second round adds 10 to the path (C0's live check +5, T1's step 0 +5)
and 50 to the sum (those two, R0's exports +10, and W9's close +30), for 1,130 and 3,070.

- Two corrections come first. C6 was carried at 30 in the path table against its stated 45, and
  the old chain left out the roughly 215 minutes of sweeps, three at a time, between PR 1's merge
  and the workstation merge. The new chain runs through I9 and those sweeps rather than through
  the retire stages, which now finish beside it.
- The rest comes from the folds on the chain: the scope harness (I3, +15), the reference tool and
  inventory cases (Pair B, +30), the worktree and extract tests (Pair C, +30), and the local legs
  moved into I8 (+30).
- Off the chain, the archive, R1's per-id checks, W8's hermetic test, the end-to-end tool, and the
  drafter follow-up raise the task sum.
- Moving the relay out of the conductor cuts its sum from 235 to 170. It doesn't shorten the path,
  because the relay steps were waits on the critical chain either way.

The G-picks PR (#71) and its rebuild sit outside both figures, as workstation#69 did. The path stays under the 1,680
ceiling, so nothing stops for Geoff.

## Rulings

Geoff ruled "I'm approving all recommendations" in chat on 2026-10-14. The plan and prompts carry
each answer as "(Geoff, 2026-10-14)".

1. **Should a small workstation PR fix the dropped Decide-picks bug before any design item goes
   out?** Ruled: yes, option (a) (Geoff, 2026-10-14).
   - The G-picks PR is workstation#71 (head `design-decide-picks`), a prerequisite like
     workstation#69, owned by the planning session, read by Geoff, with its estimate outside the
     pass. After it merges, the planning session rebuilds the app and restarts the 7907 server.
   - C0 gates on the merge and on the fix being live, and C2 hands over neither the
     migration-calls item nor the dry-run item before that. So I9 and the whole retirement wait
     on it.
   - Every design decision's reader checks one `choices` entry per Decide block. The thinkpad
     store confirmation rides in the dry run as a Decide block.
   - The options not taken were (b), carrying each call as a triage row, and (c), Geoff typing
     his picks in a reject note.
2. **Should the drafter rows be marked `deferred:p5` and moved in a follow-up, so the pass doesn't
   wait on drafter pass 5?** Ruled: yes, option (b) (Geoff, 2026-10-14). The follow-up set is
   D1, I11 (initiatives PR 4), W9 (a workstation follow-up PR), and C9. No main-set PR waits on
   pass 5. The thinkpad leg runs after the follow-up merges, so check 4 runs once on each
   machine, and the cost is two more PR reads. Deviation 3 records the split.
3. **Should the scratch and staging D1 data be exported into the archive before teardown?** Ruled:
   yes (Geoff, 2026-10-14). R0 adds a `wrangler d1 export --remote` of each D1 database in the teardown
   rows to the one archive, verified before any destructive stage. Deviation 6.
4. **Should the `ordinary` sweep PRs merge themselves, as pass-core allows an `ordinary` change?**
   Ruled: yes, option (a) (Geoff, 2026-10-14).
   - A sweep PR whose diff touches no `runner` or `auth-data` path is merged by the conductor, in
     merge order, on a green full-suite home and an accepted whole-branch review with an empty
     "Found, not done" list. That is pass-core's bar, which replaces the task-scope review the
     ruling's text named (deviation 7).
   - Geoff gets one batched triage item naming what merged.
   - This cuts about nine PR reads. Deviation 7.
