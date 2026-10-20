# Repo organization plan: fold verification

Target: `repo-organization/plans/2026-10-14-repo-organization-plan.md` and its 19 launch prompts at
`657e621`, read against the fold record
`2026-10-14-repo-organization-plan-fold.md`, the three plan reviews, the design, and `pass-core`.
Reader: a fresh `claude-opus-5-5` agent with no part in the reviews or the fold, 2026-10-14, per
`spec-plan-review` "The verification read".

Counts: 1 blocker, 8 majors, 16 minors.

## Probes and quotes checked (read-only, pavilion)

- The plan's name check form, `git diff origin/main...HEAD | grep -wF -f -`, in a scratch repo
  (`scratchpad/plan-verify/g`) with a planted canary in the diff: it printed nothing and exited 1,
  both with the names piped in and without. The form `grep -wF -f <(names)` caught the canary.
- `bin/.local/bin/approval-queue`: line 71 builds only `if [ ! -e "$app/build/index.js" ]`, and
  line 70 starts a server only when none answers on 7907. Line 77 confirms `setsid -f node
  "$app/build"` with no `cd` (deviation 2 is accurate). `ebb4877` places the dropped-picks bug in
  the app ("either the design page renders no Decide cards or its approve omits them").
- `secret-set.sh:33-36` hard-codes `RECIP`, `VALUES`, `LOCAL_SECRETS`, and `CACHE`, and `--sync`
  regenerates `~/.local/secrets` with no edit (line 26). The fold record's claims hold.
- The worktrees page, "How Claude Code enforces isolation": both quotes in the fold record are
  verbatim. The page also confirms the `worktree-<name>` branch name, which R2's and W8's
  `gh api` reads assume. `~/.dotfiles` has 31 `worktree-*` branches in that shape.
- `claude --help` lists `--bg`, `-n, --name`, and variadic `--add-dir <directories...>`. `gh repo
  create` has `--add-readme`, `--source`, and `--push`. `gh pr checks` has `--watch` and
  `--fail-fast`. git is 2.56.0, and `git clone` has `--revision`.
- `claude agents --json`: the distinct `{status, state}` pairs are `busy/blocked`, `idle/done`, and
  `busy/null` (interactive). `conductor-drafter`, `drafter-p5-cairn`, and `drafter-p5-pipeline` are
  listed now.
- Cloudflare's D1 import and export page: every example is `npx wrangler d1 export <database_name>
  --remote --output=./database.sql`, and "Export is not supported for virtual tables, including
  databases with virtual tables."
- `~/Projects/initiatives` has no remote. `~/Projects/approval-queue` doesn't exist yet. Nine
  sweep repos plus workstation have a ROADMAP.md, and drafter and initiatives have none, which
  matches I7's ten. `docs/` holds 281 tracked files, and `approval-queue/` holds 60.

## Blocker

**B1. The name check is vacuous as written, and C0's form of it has no defined command.**
`correctness`. `plans/2026-10-14-repo-organization-plan.md:56`, `:97`; every prompt's "run the
plan's name check" line (for example `initiatives-prompt.txt:9`, `conductor-prompt.txt:9`).
- Defect: `grep -wF -f -` reads its patterns from stdin. Stdin is the diff, so the grep consumes
  the diff as patterns and then reads an empty input. It prints nothing on any diff, and the probe
  shows this. This check is the only executable guard for the hard rule that no public repo names
  an outside repo. C0 publishes the whole initiatives history, and that can't be undone. Also,
  C0 runs the check "over the local initiatives history" before any `origin/main` exists, so the
  plan's `origin/main...HEAD` form can't run there at all. The fold took the contract review's
  M3 command verbatim, and no probe covers it.
- Fix: define the check as `git diff origin/main...HEAD | grep -wF -f <(outside_names)` and require
  exit 1 with empty output. A positive control plants one outside name in a scratch diff and must
  exit 0. For C0, scan the whole history with `git log -p --all | grep -wF -f <(outside_names)`.
  Tell the fold's P6 and the conductor prompt's C0 line about both forms.

## Majors

**M1. Merging and pulling the G-picks PR doesn't put the fix live.** `correctness`. `plan.md:61`,
`:94`, `:106`; `conductor-prompt.txt:9`, `:28`; fold record `:308-316`.
- Defect: ruling 1's gate is "the G-picks PR has merged and `~/.dotfiles` is pulled". The bug
  lives in the app. The 7907 server keeps serving the old `build/` until someone stops it, and a
  restart still skips the build, because `build/index.js` exists (`approval-queue:70-71`). So
  both design items go out against the unfixed app. Their approves come back with no `choices`,
  the readers' Decide-count check stops I9 and the retire session, and the pass wedges on
  Geoff's picks again.
- Fix: before C2 hands over either design item, the conductor runs `npm ci && npm run build` in
  `~/.dotfiles/approval-queue`. It then restarts the 7907 server, which drops no open item,
  since items live in the state directory and the waiting commands keep polling. A probe then
  confirms the fix is live: a fixture design brief with one Decide block, approved, must return
  one `choices` entry. Put that as C0's or C2's acceptance.

**M2. The G-picks PR has no author, no number, and no prompt.** `correctness`. `plan.md:61`, `:94`,
`:545`; `conductor-prompt.txt:9` ("the G-picks PR the plan names").
- Defect: C0's gate runs `gh pr view` on a PR the plan never names, and no session is told to
  write it. All 19 prompts cover pass sessions only. The conductor would sit on its until-loop
  with nothing to poll. The fold record and the plan say only "a prerequisite like
  workstation#69".
- Fix: name the owner (the planning session, as for #69) and the head branch, and have C0 find the
  PR by head (`gh pr list -R glw907/workstation --head <branch> --state merged`). Alternatively,
  record the number in the plan once the PR opens.

**M3. T1's first step can't run on the thinkpad.** `correctness`. `plan.md:54`, `:460`, `:463`;
`thinkpad-prompt.txt:6`, `:9`.
- Defect: "An `edit` or `read` row whose path is missing makes a tool exit nonzero". Step 1
  runs `refs check` over the thinkpad's main checkouts before any pull, and only step 4 says
  "Clone drafter or approval-queue first if it's missing". `~/Projects/approval-queue` can't
  exist on the thinkpad before the pass, and any other unclone edit row, or the
  `aksailingclub-legacy` read row, fails the same way. So T1 stops at step 1, and check 1 of the
  thinkpad's six can't be baselined.
- Fix: T1 step 0 clones every missing `edit` row at its `origin/main` (a fresh clone has nothing
  to baseline against, so its baseline is taken from the clone). Give the baseline tool a
  `--host thinkpad-x1` rule: a missing `read` row reports `absent`.

**M4. The thinkpad's manifest has no hash check, though the plan says it does.** `correctness`.
`plan.md:64` against `:227`; `thinkpad-prompt.txt:5`.
- Defect: P4 says "R0 to R3, W8, and the thinkpad script extract the manifest from `doc.md`,
  check the hash". `doc.md` and `items.tsv` live only in pavilion's state directory. The thinkpad
  prompt reads the committed dry-run file on `origin/main` and checks nothing. So the thinkpad's
  destructive step has no binding to the snapshot Geoff approved, and the plan contradicts
  itself about it.
- Fix: R0 writes the approved `doc_sha256` into the committed retirement log (PR 2). T1 checks
  that the committed dry-run file's sha256 equals that logged value before `thinkpad-cleanup` runs,
  and stops for Geoff on a mismatch. Then align P4's sentence.

**M5. W9's draft check can't pass before initiatives PR 4 merges, and W9 doesn't wait for it.**
`correctness`. `plan.md:453`, `:526`, `:537`; `workstation-drafter-prompt.txt:6`, `:9`;
`conductor-prompt.txt:19`.
- Defect: W9 runs W7's draft check over the `deferred:p5` rows. The check requires every
  destination path on its repo's `origin/main`, and part of those rows go to initiatives through
  I11. W9 waits only on the drafter and main workstation merges. Merge order step 6 merges PR 4
  between drafter and the W9 PR, so W9's acceptance at PR-ready fails whenever PR 4 is still
  waiting on Geoff. This repeats the mechanics review's M2 in the new follow-up set.
- Fix: W9, and its launch in the conductor prompt, wait on both the drafter merge and the PR 4
  merge, the way W7 waits on every receiver.

**M6. Ruling 3's D1 export is an unprobed mechanism with no acceptance.** `correctness`.
`plan.md:64`, `:283-284`; fold record `:93-94`, `:324-326`.
- Defect: the fold record's Verification section has no probe for `wrangler d1 export`, and
  three things are left out:
  - The `--remote` flag, which every documented example carries. Without it the export can read
    a local database.
  - The documented refusal on any database with virtual tables, FTS5 included.
  - The token scope that export needs, which R1's per-kind pre-flight doesn't cover, since that
    pre-flight runs after R0.
  R0's acceptance counts tar members for the three directories only, so an empty or missing
  export passes, and R1 then deletes the only copy.
- Fix: R0 runs `wrangler d1 export <name> --remote --output <tmp>/<id>.sql` per D1 manifest row.
  Its acceptance requires one non-empty export per D1 row, each listed by `tar -t`. A database
  whose export fails, the virtual-table case included, stops for Geoff before R1. Add a
  read-only probe of the command against one teardown database to the fold record.

**M7. The self-merge rule lets an `auth-data` sweep diff merge without Geoff.** `correctness`.
`plan.md:421`; every sweep prompt `:20` ("whether any runner path is in its diff");
`conductor-prompt.txt:32`.
- Defect: the rule merges a sweep PR "whose diff touches no `runner` path". The sweep's
  `refs apply` can rewrite a path in a file the adapters class `auth-data`: `wrangler.*`,
  `src/hooks.server.ts`, or `migrations/**` (`site-pass:46-50`), or cairn-cms's list
  (`cairn-pass:48-52`). Ruling 4 rests on pass-core's `ordinary` exception, which an
  `auth-data` diff doesn't meet.
- Fix: write the rule as "touches no `runner` or `auth-data` path under the repo's adapter map,
  or under pass-core's `runner` definition for a repo with no adapter". Have each sweep's last
  message report both classes.

**M8. G-p5's "live status" is undefined, and its wait has no stop.** `correctness`.
`plan.md:66`, `:42`; `conductor-prompt.txt:22`; `drafter-prompt.txt:6`;
`initiatives-drafter-prompt.txt:6`.
- Defect: the agents list carries `idle/done` rows beside `busy/blocked` ones, and the plan
  doesn't say which count as live. An idle `conductor-drafter` that pass-core keeps alive while
  it owns a later pass blocks the follow-up for good if idle counts, and with it T1, PR 3, and
  C8, since ruling 2 puts the thinkpad leg after the follow-up. If idle doesn't count, the
  check passes while pass 5's sessions are still listed. D1 and I11 must recheck the PR half
  too, but nothing gives them pass 5's drafter head name.
- Fix: state the live predicate as any row whose `state` isn't `done`. Have the conductor write
  the drafter head name into the state directory when it learns it, and point D1 and I11 at that
  file. Add a stop: when the PR half passes and the session half still fails after a set time,
  log a line in `stops.log` and notify Geoff.

## Minors

**m1. Deviation 7 understates ruling 4's departure, and no one runs its review.** `correctness`.
Fold record `:95-98`; `plan.md:421`; `conductor-prompt.txt:29`, `:32`.
- Defect: pass-core's exception also requires "an accepted whole-branch review, when its 'Found,
  not done' list is empty". The ruling uses a task-scope `diff-reviewer` accept and is silent on
  a non-empty list, and deviation 7 records neither change. The sweep prompts run a
  whole-branch review, and no session is told to run the task-scope one. `conductor-prompt.txt:29`
  also hands "each PR at PR-ready" to the queue, which conflicts with line 32's exception.
- Fix: add both changes to deviation 7. State that the executor's whole-branch accept serves as
  the review. Say that a self-merged PR's "Found, not done" items ride in the batched triage
  item, and that line 29 excludes self-merged PRs.

**m2. Ruling 1's reader check is missing from two prompts.** `correctness`.
`workstation-prompt.txt:35`; `dubplate-prompt.txt:9`; `poplar-prompt.txt:9`.
- Defect: W6 and W8 read the dry-run decision, but the workstation prompt drops the "one `choices`
  entry per Decide block" check. The dubplate and poplar prompts say "apply Geoff's map-calls
  decision" with no title or lookup, though I9 has already written the calls into the map.
- Fix: add the check to the workstation prompt's decisions line. In the two sweep prompts, say
  "apply the map's `collision-*` state as I9 wrote it".

**m3. The deviations list leaves three departures out, and an erratum is owed.** `correctness`.
Fold record `:69-98`; design `:200`, `:220`, `:96`, `:217`.
- Defect: the plan replaces the design's `teardown.tsv` with `retire-manifest.tsv`. Design check 5
  still names `teardown.tsv`, and that sentence now owes an erratum. The plan also creates
  `glw907/approval-queue` with a README commit, where the design says "empty" (mechanics m17,
  dropped). And check 2 runs the hook script rather than opening a session. None of the three is
  recorded.
- Fix: add them as deviations 8 to 10, and make the check 5 erratum the third owed erratum.

**m4. The path figure rests on two unstated assumptions.** `correctness`. `plan.md:486`, `:499`.
- Defect: the 215-minute sweep window is the best packing of 640 minutes on three slots. A
  greedy launch in the table's order with dubplate and poplar first runs about 240. The figure
  also assumes that dubplate, poplar, and approval-queue are W7's only receivers. If I3's
  per-repo counts name another sweep repo, W7 and the W close (125 minutes) start after that
  repo's merge, so the main path could reach about 1,245. Both stay under 1,680, so nothing stops.
- Fix: state the packing (dubplate, aksailingclub-org, and phonebook; poplar, cairn-cms, and
  ecxc-ski; then the other four) in the conductor prompt. Name the receiver assumption beside the
  1,330 figure.

**m5. W9's close has no minutes.** `correctness`. `plan.md:453`, `:503`.
- Defect: W9 lists a gate, a name check, and a review as its close, but the task sum carries W9
  at 35 with no close figure, where D1 carries a separate 30.
- Fix: add a close figure. About 30 brings the follow-up to 250 and the task sum to 3,050.

**m6. R2's wait depends on an unstated push and an uncapped file list.** `correctness`.
`retire-prompt.txt:13`; `workstation-prompt.txt:19-29`.
- Defect: the workstation prompt never says to push after W8's store commit, and R2 can see that
  commit only on GitHub. The compare endpoint also caps `files` at 300 entries, and W7's
  deletions (281 tracked files) plus W6's (about 65) can push `secrets/values.age` past the cap if
  W7 lands first.
- Fix: push the store commit at once, and have R2 match the store commit's subject through
  `compare/...` `.commits[].commit.message`, which isn't capped the same way.

**m7. C2 sets no time for the approval-queue clone, which I8's legs need.** `correctness`.
`plan.md:109`, `:241`.
- Defect: `approval-queue` is an `edit` row, so I8's local legs exit nonzero if
  `~/Projects/approval-queue` doesn't exist yet.
- Fix: C2 creates and clones it right after C0, and that becomes C2's first acceptance.

**m8. The session table says the conductor commits to no repo, but C8 commits.** `correctness`.
`plan.md:29` against `:127`.
- Defect: C8 commits the record's status line and the STATUS hand-overs.
- Fix: change the table cell to "STATUS and record hand-overs only, per pass-core Ledgers".

**m9. Touchpoint 1 asks Geoff to merge workstation#69, which has already merged.** `correctness`.
`plan.md:545`.
- Defect: #69 merged as `b0084ec` before this plan was written.
- Fix: drop it, and leave the G-picks read.

**m10. The conductor's standing answers leave out ruling 3.** `correctness`.
`conductor-prompt.txt:38`.
- Defect: the archive line names three directories and no D1 exports.
- Fix: add "and a D1 export of each teardown database (Geoff, 2026-10-14)".

**m11. R3 could remove the worktrees that C9 reserves.** `correctness`. `plan.md:309` against
`:131`.
- Defect: R3 removes "only those the tool marks removable". Nothing excludes cairn-cms's
  `drafter-pipeline` and `p5-scratch` worktrees or drafter's `agent-*` worktrees, which ruling
  2 leaves to C9 after G-p5.
- Fix: I8's manifest leaves those worktrees out, and R3 refuses them by name.

**m12. The conductor launches W9's session before W9's prerequisites.** `correctness`.
`conductor-prompt.txt:19` against `workstation-drafter-prompt.txt:6`.
- Defect: the conductor launches the session after the main workstation merge, but the session
  also needs the drafter merge (and PR 4's, per M5) and stops if it's missing.
- Fix: launch it after all three merges.

**m13. T1 has no clock file, and it pulls its own live checkout.** `correctness`.
`thinkpad-prompt.txt:1`, `:9`.
- Defect: T1 runs 110 minutes with no `pass-task-clock`. Its step 4 also pulls
  `~/Projects/initiatives`, the checkout of the live T1 session, against pass-core's "no live
  session" pull rule.
- Fix: write the clock file in the T1 worktree's git dir. Exempt T1's own checkout as the
  conductor's is exempt, or pull it before T1 starts, as Geoff's first command already does.

**m14. R3 can't recognize "the ecxc-ski PR's fold commit".** `correctness`.
`retire-prompt.txt:14`; `ecxc-ski-prompt.txt:9`.
- Defect: no subject or marker identifies the fold commit.
- Fix: have S-ecxc-ski give the commit a fixed subject (`S-ecxc-ski fold ecxc-ski-agent-memory`),
  and have R3 match it through `gh api` on the branch.

**m15. R1 has no step for a non-empty R2 bucket.** `correctness`. `plan.md:289-293`.
- Defect: the API refuses to delete a bucket that holds objects, and R1's "any other API error
  stops the stage" then stops with no remedy. This predates the fold.
- Fix: list each bucket's object count in the dry run, and empty a `sole-owner` bucket first,
  with a logged count.

**m16. A failed decision wait has no stated way to resume.** `correctness`. `plan.md:59`.
- Defect: after a wait fails on a vanished `item.json` and the conductor re-hands the item, the
  plan doesn't say whether the waiting session re-reads `items.tsv` or must be relaunched.
- Fix: the wait loop re-reads the newest open row for its title on each pass, and fails only
  when no open row exists.

## Closure of the review blockers and majors

Each item below closed at the location the fold record cites, unless its row says otherwise.

| Review finding | Closed? |
|---|---|
| Mechanics B1 (the launch `--`) | Yes, at `conductor-prompt.txt:12` and `plan.md:552`. |
| Mechanics B2, integrity B1, contract M7 (G-p5) | Mostly, at `plan.md:66`, with the gap in M8 above. |
| Mechanics M1 (R2's wait) | Yes, at `plan.md:300` and `retire-prompt.txt:13`, with m6 above. |
| Mechanics M2 (W7's waits) | Yes for W7, but it recurs in W9 (M5 above). |
| Mechanics M3 and M4, contract M14, integrity M4 and M5 (W8) | Yes, at `plan.md:368-375` and `:559`. |
| Mechanics M5 and M6, integrity M9 (isolation, tools) | Yes, at `plan.md:25` and `:57`. The quotes are verbatim. |
| Mechanics M7, contract M10, integrity M7 (ecxc-ski-agent-memory) | Yes, at `plan.md:307` and `:429`, with m14 above. |
| Mechanics M8, contract M2, integrity M8 (scope reads) | Yes, at `plan.md:55-56` and `:204`. |
| Mechanics M9 (thinkpad scan) | Yes, at `plan.md:227`. |
| Mechanics M10 (filter-repo version) | Yes, at `plan.md:324`. |
| Mechanics M11, contract M25 (queue ids) | Yes, at `plan.md:59`, with m16 above. |
| Mechanics M13 (STATUS) | Yes, at `plan.md:68`. |
| Mechanics M14, integrity M1 (manifest) | Yes on pavilion. On the thinkpad, no (M4 above). |
| Mechanics M15 (check 3) | Yes, at `plan.md:256`. Deviation 2 is accurate. |
| Contract B1 (Decide picks) | The route is ruled, but the fix's gate doesn't make it live (M1 and M2 above). |
| Contract M1 and M3 (scope harness, name check) | The harness yes (`plan.md:158`). The name check no (B1 above). |
| Contract M4 to M6, M8, M9, M11 to M13, M15 to M24 | Yes, at the cited tasks. |
| Integrity B2 (archive) | Yes for the directories (`plan.md:283`). The D1 half is open (M6 above). |
| Integrity M2, M3, M6, M10, M11 | Yes, at R1, R3, I5, I6, P8, and T1. |

## Path recomputed

From the plan's own figures, the chain is C0 25, I1 85, Pair A 115, Pair B 160, Pair C 100,
Pair D 90, I9 70, I close 45, merge 5, sweeps 215, merge 5, C6 50, C7 20, T1 110, and C8 25. That
sums to **1,120**, and the plan agrees. The retire chain reaches 765 and the sweeps end at 910,
which also agree. The task sum re-adds to **3,020**: conductor 170, initiatives 1,040, retire
195, workstation 520, queue 125, sweeps 640, follow-up 220, and thinkpad 110. The 1,330 figure
holds as stated. With m4 and m5 the figures read about 1,145 to 1,245 for the main path and
3,050 for the sum, all under the 1,680 ceiling.

## Rulings applied

- Ruling 1 is in the plan at `:60-61`, `:94`, `:106`, and `:244`, and in the conductor,
  initiatives, and retire prompts. It's missing from the workstation prompt (m2), and its gate
  doesn't make the fix live (M1).
- Ruling 2 is consistent across the plan, the conductor prompt, the three follow-up prompts, and
  the workstation prompt's line 9.
- Ruling 3 is in the plan, but the conductor's standing answers leave it out (m10), and its
  mechanism is open (M6).
- Ruling 4 is in the plan, the conductor prompt, and all ten sweep prompts. Its scope (M7) and
  its deviation record (m1) are open.

## Owed errata

Both errata the fold names are accurate. Check 3's design sentence is wrong, as
`approval-queue:77` shows. The brief's "If you approve" list names only #69. A third erratum is
owed for design check 5's `teardown.tsv` (m3).
