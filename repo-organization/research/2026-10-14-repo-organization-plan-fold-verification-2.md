# Repo organization plan: second fold verification

Target: the plan and its 19 launch prompts at `7f7e8fa`, read as the diff `657e621..7f7e8fa`
(round four's fold `19ca1cc` and the design errata `7f7e8fa`), against the first verification
read and the plan fold record's "Second round: fold verification" section. Reader: a fresh
`claude-opus-5-5` agent with no part in the reviews, the fold, or the first read, 2026-10-14, per
`spec-plan-review` "The verification read".

Counts: 0 blockers, 4 majors, 8 minors.

The first read's blocker closed. Of its eight majors, six closed fully, and two (M3 and M8)
closed in part, with the gaps below. No new contradiction in the merge order, and every launch
command delivers its prompt. One premise of this read's brief is stale: workstation#71 merged at
19:38Z today, and the app has since been rebuilt and restarted, so C0's live-fix check now
succeeds.

## Probes (read-only, pavilion, `scratchpad/plan-verify2/`)

- **The name check**, in a scratch repo with a bare `origin`, a `main`, and branches, with the
  names fed through `<(...)`:
  - The branch form `git log -p origin/main..HEAD | grep -wF -f <(names)` on a clean branch
    printed nothing and exited 1.
  - The same branch form printed the canary and exited 0 when one commit added the canary and a
    later one removed it. It did the same with the canary only in a commit message.
  - The history form `git log -p --all | grep -wF -f <(names)` exited 1 on a clean history and 0
    with the canary.
  - The old stdin form `grep -wF -f -` exited 1 with the canary present, so the first read's
    blocker is real and the fix closes it.
  - Two hazards the fold's probe didn't cover, both behind major M2:
    - When the name source fails or is partial, `<(false)` or a list missing the canary, GNU grep
      exits 1 on a canary branch, even with `pipefail`. That is a vacuous pass.
    - A blank line in the names makes GNU grep match every line and exit 0 on a clean branch.
  - In a Claude Code session, `grep` is a shell function that runs ugrep (`type grep`), and ugrep
    matches everything on an empty pattern file. The fold's probes and the sessions' checks run
    under ugrep, but a tool script runs GNU grep, so the two can disagree.
- **The live-fix check.**
  - `grep -rlq decideCards ~/.dotfiles/approval-queue/build/server` now exits 0, under both
    ugrep and GNU grep. The build's files carry mtime 11:38:21 AKDT. `gh pr view 71` reads
    `MERGED` at `2026-10-14T19:38:00Z` (merge `2d52695`), and `~/.dotfiles` is at that merge.
    So the planning session has already rebuilt, and the "fails on the current build" control
    can no longer be run on the live build.
  - As a negative control, `git grep decideCards 2149130 -- approval-queue` (pre-fix) finds
    nothing, and `25f9449` finds it in `src/lib/cards.ts` and the item page's server load. The
    same grep on a scratch `build/server` without the symbol exits 1. The grep discriminates.
  - The 7907 listener (pid 1161925) has cmdline `node /var/home/glw907/.dotfiles/approval-queue/build`.
    `ps -o lstart=` gives 11:38:28, after `cards.js`. `stat -c %Y /proc/<pid>` (1792006708) is
    after `cards.js` (1792006701). So C0's check passes today, and correctly.
  - The start-time half isn't reliable in general: across 188 of the user's processes, 37 have a
    `/proc/<pid>` mtime more than 60 seconds after their real start (field 22 of
    `/proc/<pid>/stat` plus `btime`). See M1.
- **G-p5's inputs.** drafter#37 (head `worktree-p5-pipeline`, "pass 5") merged at 19:37:44Z.
  cairn-cms#124 (head `drafter-pipeline`) merged at 19:37:58Z. `claude agents --json` lists
  `conductor-drafter` as `busy`/`working`, a `state` the first read didn't see. It counts as live
  under the new "state isn't `done`" predicate, which handles it correctly.
- **The rest.** `approval-queue:55` writes `doc.md` with a plain `cp`, so T1's file-to-`doc.md`
  hash compare is byte-sound. `delete_branch_on_merge` is false on ecxc-ski and workstation, so
  R3's branch match survives a merge. All 19 prompt files exist under the names the conductor
  prompt uses. The task sum re-adds to 3,070 and the path to 1,130.

## Majors

**M1. C0's "server started after the build" half reads `/proc/<pid>`'s mtime, which isn't the
process start time.** `correctness`. `plans/2026-10-14-repo-organization-plan.md:94`;
`conductor-prompt.txt:9`.
- Defect: a procfs directory's timestamp is set when its inode is instantiated, which can be the
  first lookup after the process started or a re-instantiation after cache eviction. The probe
  found 37 of 188 processes whose `/proc/<pid>` mtime is more than a minute after their real
  start. A pre-fix server that was never restarted can show a `/proc` mtime after the rebuild, so
  C0 passes while the old app is serving. The grep half checks only the disk, so it can't catch
  this. This half is the only guard against the first read's M1 failure, in which both design
  items go out against the unfixed app and Geoff's picks are dropped. It passes today because the
  server really did restart, so the defect is latent.
- Fix: compare the real start time. Use `ps -o lstart= -p <pid>` converted with `date -d`, or
  `btime + field22/CLK_TCK` from `/proc/<pid>/stat`, against `stat -c %Y
  build/server/chunks/cards.js`. Change the fold record's probe line to match.

**M2. The name check passes vacuously when its name source fails or comes back partial.**
`correctness`. `plan.md:56`; `conductor-prompt.txt:9`; every prompt's "run the plan's name
check" line.
- Defect: the patterns come from `<(gh repo list ...; ls ~/Projects ... minus scope.tsv)`.
  Process substitution swallows a failing `gh`, and `pipefail` doesn't see it.
  - Under GNU grep, which any tool script runs, an empty or partial list exits 1 on a diff that
    names a missed repo. The probe shows this.
  - The positive control plants "one outside name", so it passes on a partial list as long as
    that name survived. A failed `gh repo list` drops every GitHub-only name, and C0's
    irreversible public push then goes out unguarded.
  - A blank line in the list fails the check the other way: GNU grep exits 0 on every history, so
    the session stops with nothing to fix.
  - Sessions run ugrep through the `grep` function, which matches all on an empty list, so a
    session's result and a script's can differ.
- Fix: build the names into a temp file in a separate step that checks `gh`'s exit status, drops
  blank lines (`grep -v '^$'`), and asserts a nonzero count no smaller than `gh repo list glw907
  --limit 200 --json name --jq length` minus the in-scope count. Then run `command grep -wF -f
  <file>`, so GNU grep runs in both places. Plant the control's name from the GitHub half of the
  list.

**M3. G-p5's head name has no reachable trigger, and the PR half has no stop.** `correctness`.
`plan.md:66`; `conductor-prompt.txt:22`; `drafter-prompt.txt:6`;
`initiatives-drafter-prompt.txt:6`.
- Defect: the conductor writes `p5-head` "when pass 5 opens its drafter PR". That PR (drafter#37,
  head `worktree-p5-pipeline`) opened and merged before the conductor exists, so the event never
  fires for it. D1 and I11 read `p5-head` and stop when it's missing. The 72-hour stop covers
  only "PR half passes, session half fails". An unknown head leaves the PR half failing forever
  with no stop and no notify. That blocks the follow-up set and, through ruling 2, T1, PR 3, and
  C8. This is the residue of the first read's M8.
- Fix: name the head in the plan (`worktree-p5-pipeline`, drafter#37, merged 2026-10-14), or
  have C0 write `p5-head` from `gh pr list -R glw907/drafter --state all --search "pass 5 in:title"`.
  Extend the 72-hour stop to either half failing.

**M4. A missing `read` row still makes the tools exit nonzero on the thinkpad, so T1 step 1 can
fail.** `correctness`. `plan.md:54` against `:462-463`; `thinkpad-prompt.txt:8-9`.
- Defect: T1 step 0 now "reports a missing `read` row `absent`", but the shared rule at `:54` is
  unchanged: "An `edit` or `read` row whose path is missing makes a tool exit nonzero." Step 1's
  `refs check` and step 6's `e2e-check` are those tools. If `aksailingclub-legacy` isn't cloned on
  the thinkpad, which is likely for a legacy read-only repo, both exit nonzero, and check 1 has no
  baseline. The first read's M3 asked for a tool rule ("give the baseline tool a `--host
  thinkpad-x1` rule"), and the fold changed only the session's step.
- Fix: amend `:54` so that a missing `read` row is reported `absent` with exit 0 under `--host
  thinkpad-x1`, or under an `--absent-ok` list that step 0 writes. Add a fixture case to the
  tool's tests.

## Minors

**m1. The conductor's hand-over line keeps the old G-picks gate.** `correctness`.
`conductor-prompt.txt:28` against `plan.md:106`.
- Defect: it reads "until the G-picks PR has merged and ~/.dotfiles is pulled", the first read's
  M1 wording. The plan now says "once C0 has confirmed the G-picks fix is live". C0's gate runs
  first, so this is harmless in order, but the two texts disagree.
- Fix: "Hand over neither design item before C0's live-fix check has passed."

**m2. The side-branch figures weren't updated.** `correctness`. `plan.md:500`, `:504`.
- Defect: line 500 still reads "R0 30" and "765", and "The sweeps end at 910". With R0 at 40 and
  C0 at 30, those are 775 and 915. Line 504 still carries "W9 35", where `:498` and the task sum
  use 65 with the close. The conclusions hold.
- Fix: update the four figures.

**m3. The thinkpad prompt's step 4 keeps a superseded clone sentence.** `correctness`.
`thinkpad-prompt.txt:12`.
- Defect: "Clone drafter or approval-queue first if it's missing" duplicates step 0. Its position
  also leaves "Otherwise stop for Geoff before the restow" dangling after it.
- Fix: delete the clone sentence, so "Otherwise" follows the fast-forward condition.

**m4. Typo.** `prose`. `initiatives-drafter-prompt.txt:6`: "p5-head,," has a doubled comma.

**m5. The retirement log has no defined row for `doc_sha256`.** `correctness`. `plan.md:65`,
R0's outcome; `thinkpad-prompt.txt:8`.
- Defect: the log's columns are `stage`, `item`, `result`, and `time`, and R0 puts "both hashes"
  on the `archive` row. T1 must parse `doc_sha256` out of a free-form `result` cell on another
  machine.
- Fix: give it its own row, `archive	doc_sha256	<hex>	<time>`, and have T1 read it with `awk`
  on `$2=="doc_sha256"`.

**m6. T1 hashes the dry-run file at `origin/main`'s tip, which a later commit may change.**
`correctness`. `plan.md:64`; `thinkpad-prompt.txt:7-8`.
- Defect: any later commit to the dry-run file changes its tip hash, so T1 stops with no fault in
  the manifest. Such commits include a `refs apply` in I11 or PR 1's close, and a status edit.
- Fix: R0 also logs the commit sha of the approved file, and T1 hashes `git show
  <sha>:repo-organization/research/2026-10-14-retirement-dry-run.md` and extracts the manifest
  from that same blob.

**m7. The self-merge rule has no `auth-data` map for the no-adapter sweep repos.** `correctness`.
`plan.md:6`, `:423`.
- Defect: for dubplate, poplar, cairn-themes, and phonebook the path map is only `pass-core`'s
  `runner` definition. A `refs apply` rewrite in, say, poplar's
  `internal/backend/jmapsource/credentials.go` self-merges without Geoff, which is the case the
  first read's M7 was about.
- Fix: list each no-adapter repo's auth paths in the plan, or route any rewrite in a file whose
  path matches `auth|credential|secret|token` to Geoff.

**m8. The thinkpad launch carries no `--add-dir`.** `correctness`. `plan.md:555`.
- Defect: the session writes `~/.local/state/repo-organization/`, `~/.dotfiles` (restow, sync),
  drafter's install, and `~/.claude/projects/*/memory`. All of those lie outside its launch
  checkout, so a `--bg` session can sit blocked on permission prompts. The conductor's launch
  passes `--add-dir ~/Projects/initiatives --add-dir ~/.local/state`. This predates round four.
- Fix: add `--add-dir ~/.local/state --add-dir ~/.dotfiles --add-dir ~/Projects --add-dir
  ~/.claude/projects` before the `--`.

## Closure of the first read's blocker and majors

| First read | Closed? |
|---|---|
| B1 name check vacuous; C0 has no form | Yes, at `plan.md:56`, C0 (`:97`), and `conductor-prompt.txt:9`. Both forms probed correct. The name-source hazard is new (M2). |
| M1 merge doesn't make the fix live | Yes in intent, at `:61`, `:94`, and `:106`, and live today. The start-time half is unsound (M1), and one prompt line is stale (m1). |
| M2 G-picks PR unnamed | Yes: #71, head `design-decide-picks`, owner dotfiles-32, at `:61` and `:548`. Merged. |
| M3 T1 step 1 can't run | In part. Step 0 clones the `edit` rows, but the tool rule for a `read` row is unchanged (M4). |
| M4 thinkpad has no hash check | Yes, at `:64` and T1 step 0. Format and pinning gaps (m5, m6). |
| M5 W9 doesn't wait for PR 4 | Yes, at W9, merge order step 6, `conductor-prompt.txt:19`, and `workstation-drafter-prompt.txt:6`. |
| M6 D1 export unprobed | Yes, at R0 and `retire-prompt.txt`, with `--remote`, a stop on failed or empty, and `tar -t` per row. Probed in the fold. |
| M7 self-merge takes `auth-data` | Yes for adapter repos. No-adapter repos have no map (m7). |
| M8 live status undefined | In part. The predicate and the 72-hour stop are defined, but `p5-head` has no reachable trigger and the PR half has no stop (M3). |

The minors m1 to m16 all closed at their cited locations, with stale residue only in m2 and m3
above.

## Round four's own changes

- **Contradictions**: only the stale texts in m1 to m3. The design errata (`7f7e8fa`) match the
  plan: brief step 3 names #71 and the rebuild, check 3 uses `cmdline`, and check 5 uses the
  manifest's `cloudflare` rows. No `teardown.tsv` or "working directory" remains in the design.
- **Waits and gates against the merge order**: W9's session waits on the drafter PR and PR 4,
  which merge before it in step 6. R2 waits on W8's pushed store commit, and W8 waits on R1,
  which waits on R0. T1 waits on PR 2's log on `origin/main`, and PR 2 merges in step 3. R3 waits
  on the ecxc-ski fold commit, and ecxc-ski has no dependency on R3. None of these is circular.
  The one unsatisfiable wait is `p5-head` (M3).
- **Launch commands**: the conductor's template and the thinkpad command both put `--` before
  the `"$(cat ...)"` prompt, and every named file exists, so each delivers its prompt. The
  thinkpad command's missing add-dirs are m8.
