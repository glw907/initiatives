# Docs layout plan fold

Target: `repo-organization/plans/2026-10-19-docs-layout-plan.md` at `5982a17`, reviewed by three
lenses because the pass touches `auth-data` paths: contract (`...-review-contract.md`, C1 to C13),
mechanics (`...-review-mechanics.md`, M1 to M27), and integrity (`...-review-integrity.md`, I1 to
I17). The planning session folded them itself rather than through a separate fold agent. It had
already built T1's script while the lenses ran, and most folds land in that script and its test,
which the session probed directly. That departure from `spec-plan-review` is recorded here.

No finding changes the approved design's outcome, files, scope, or end-to-end check, so nothing
returns to Geoff before launch. The five owner forks the lenses raised each have one answer the
design text or `pass-core` already settles. Each is recorded below with its reason, and the
packet names the two that are contestable.

## Owner forks, settled

- **C3, M15: line-level pins (folded).** The design says a record "keeps" its past path. Keeping
  only the pinned lines does that and rewrites the roughly 300 unpinned citations those files
  also hold. The design names the migration map, the retirement log, and the manifest as
  whole-file records, and they stay whole-file. Not a fork: one reading meets the outcome better
  and both meet the text.
- **M1: `runner` and `auth-data` paths touched only by the script (folded, contestable).** The
  design's risk-class line names its `runner` parts: the workstation PR and cairn-cms's
  `scripts/checks/`. It calls the docs moves `ordinary`. A scripted citation rewrite in a repo's
  `.claude/`, `Makefile`, migrations, or `src/admin-club/` changes only a path token, and T1's
  reproduction proof shows it: rerunning the script on the base reproduces the rewrite commit
  byte for byte. So those PRs stay `ordinary`. A hand edit in a `runner` or `auth-data` path
  takes its class and goes to the packet. The packet lists every self-merging PR as a routine row
  before any merges, so Geoff can stop one. This also answers I17 and C13 (the `diff-reviewer`
  reads on comment-only diffs become the reproduction proof).
- **M9: the clock stop (folded toward `pass-core`).** The design records no overrun answer, so the
  plan grants none: a clock stop writes STATUS, runs `notify-send -u normal`, and waits for Geoff,
  as `pass-core` "Clock stop" says. The estimates carry their own margin. The clock file lives in
  this session's initiatives worktree git dir, which is where `claude-clock-stop` reads it. The
  path-ceiling answer stays, since it ends in a packet rather than waiting.
- **M14: the B3c wait (folded).** Every task that doesn't need B3c's merge now runs before the
  wait, including the cairn-cms and drafter branches, which are rebuilt on the new `main` once B3c
  lands. The wait itself is a Monitor with no deadline and no question to Geoff. That keeps the
  prompt's one packet and loses no work to the wait.
- **I7: fact bullets put B3c's pages back in drafter's draft scope (folded as a packet item).**
  Eleven bullets in cairn-cms's `docs/internal/facts/` cite the old path, and the facts check
  needs each `Source:` to resolve, so they must change. T8 measures the effect with drafter's
  page-scope dry run before and after the rebuild, and the cairn-cms ask in the packet states the
  pages and sections that would redraft. The cairn-cms PR goes to Geoff anyway, so he rules it
  there. A rename-aware `FactChanged` goes to drafter's BACKLOG as option (b).

## Findings folded

- **I1 (blocker): the pin detector missed about 42 shapes.** The script now detects live, on any
  old-path line holding a 7-to-40-hex token with a digit and a letter. The TSV's `pin` rows are
  regenerated from it and only document the result. A `follow` row turns detection off for a
  file whose hex tokens aren't commits (drafter's round-2 snapshot). The fixture covers
  `at HEAD 27b254ac`, `(main, 4365ac34)`, and a replayable `git diff bd7525d d3ffc29`. The live
  survey keeps 340 lines across 307 files. The session read all 92 kept lines outside the plain
  `at <id>` and 40-hex shapes. A few hold a hex token that isn't a commit (a session id, a
  workflow run id, a `/tmp` path, a dubplate findings JSON). Each only leaves one line
  unrewritten, the safe direction.
- **I2: a rerun could rewrite moved records.** The TSV is matched at the old path and the new one,
  and the fixture's no-op second apply covers a moved record.
- **I3, M6, C1: the workstation guard can't see the folder return.** It gains a tracked-file check
  (`git ls-files docs/superpowers` prints nothing). Its content arm keeps the history pathspecs,
  since the pinned records legitimately cite the old path there. T5 plants a tracked file under
  the old folder, requires the gate to fail, and reverts. T6 does the same for cairn-cms's guard,
  and the end-to-end check repeats both plants.
- **I4, C5: crash and anchored links.** Apply refuses a dirty tree. It plans every change before
  writing anything, writes each file through a temp file and a rename, and runs in two phases:
  the moves, then a commit of pure renames, then `--finish`. A new `--links BASE` mode prints each
  relative link that resolved at the base and no longer resolves, and it gates every repo. The
  fixture covers anchors, titles, reference definitions, and `href` with an anchor.
- **I13: rename detection.** The two-phase apply gives three commits per repo: the pure renames,
  the scripted rewrite, then the hand edits.
- **M4: merging `main` into a move branch conflicts.** A branch whose default moved is rebuilt
  rather than merged: reset to `origin/<default>`, rerun the script, cherry-pick the hand-edit
  commit, gate, and `git push --force-with-lease`.
- **M5, I5, I9, C10, M20: windows between merges.** No PR merges before the packet decision.
  Every PR is built and gated first, and the sweep merges them after Geoff decides, cairn-cms,
  then drafter, then workstation, then the rest. That closes the hook-noise window, the
  cross-repo citations that point ahead, and the window in which sessions on old skills recreate
  the folder. If Geoff holds cairn-cms or workstation, every PR holds with it, and the packet says
  so. After the workstation merge the session runs tellgrader's `make install` from the merged
  worktree, and the hand-over lists the pulls owed on both hosts.
- **M2: drafts can't merge.** `gh pr ready <n>` precedes each merge.
- **M3, I6, I15: the B3c condition.** B3c counts as done when glw907/drafter has a merged or
  closed PR from `worktree-b3c-pilot`, glw907/cairn-cms has one from `b3c-pilot-pages`, and no
  `drafter-b3c-pilot` session is listed. Before T8, the session sends `conductor-drafter` a hold
  note asking it to launch nothing into cairn-cms or drafter until the sweep ends. Each merge in
  the sweep fetches first and passes `--match-head-commit`.
- **M7, C2: the idiom fixture.** Its TSV row is dropped, so the script rewrites it to the new path
  and rule 4's test keeps passing. The guard against the old folder is the new tracked-file rule.
  `check-idioms.mjs:467` and `:494` and `check-idioms.test.ts:254` are hand items T6 names.
- **M8, I10, C11: cairn-pub's build comparison.** Dropped. Its one change is a hand-edited comment.
- **M10, C12: T8 and the gates.** The tasks are split, and the end-to-end gate rerun covers only
  repos whose default branch moved after their PR's gate. The path is recounted below.
- **M11, C4: counts.** The plan carries the per-repo dry-run table and the hand lines by file.
- **M12: close review.** One whole-branch `diff-reviewer` read per hand-edit commit set:
  workstation, cairn-cms, and one dispatch that covers the small hand commits elsewhere. Scripted
  commits are covered by the reproduction proof, `--check`, and `--links`.
- **M13: the drafter checkout.** cairn-cms and drafter merge back to back. The drafter checkout's
  pull is a hand-over item, sent to `conductor-drafter`, which holds that checkout.
- **M16, I14: cairn-cms check edits.** The two loose briefs join every skip list by name.
  `check-leaks.mjs`'s ban becomes `(?:internal|specs|plans|research|archive)/`, with a test for a
  `docs/specs/` link in a public page. `docs-links.mjs` skips by top-level path, not by basename.
- **M17: tellscan's `.tellgrader.json`.** T5 reads its test and either rewrites the glob or adds a
  `record` row.
- **M18, M19: aksailingclub-legacy.** It is `live-account`: its merge redeploys the club site, and
  the session watches the deploy run. Its `info/exclude` gets `.claude/worktrees/`.
- **M21: cairn-pub.** Named as a hand edit.
- **M22, I11: records.** cairn-cms `CHANGELOG.md` and the three harvest records
  (`docs/internal/record/harvest/{README.md,relink.json,residue.txt}`) are whole-file records.
- **M23: drafter snapshots.** `make check` only, regenerating only on a red.
- **M24: escalation.** The wording says the outcome is partly met.
- **M27: guards.** The session arms the API-drop wake-up. pavilion is a desktop, so no lid hold.
- **I8: dubplate's ignored note.** The note isn't on pavilion. The hand edit ignores it by
  basename at any depth, so it stays ignored wherever it sits on thinkpad-x1, and the hand-over
  tells Geoff where it now lands.
- **I16: index locks.** The script runs git with `GIT_OPTIONAL_LOCKS=0`.
- **C6: the end-to-end check reads stale checkouts.** It runs against a fresh detached worktree of
  each `origin/<default>`.
- **C7: `--check` described two ways.** One description now.
- **C8: fixture cases.** Covered, as listed under I1 and I4.
- **C9: the packet grows.** It now holds two asks, workstation and cairn-cms, as the design said.
  drafter rides as a routine row tied to cairn-cms, and the self-merging PRs are routine rows.

## Refused

- **I12: the `blob/main` URL in `cairn-cms/docs/reference/public-css.md:120`.** The published
  versions already carry `blob/main/docs/superpowers/...`, and no edit today changes their text.
  The script's rewrite is right for every future version. `## Decisions` in the cairn-cms PR
  records the 404 on older versions' pages.
- **M25: limit `--check` to the literal path.** It already is. Already-broken relative tokens are
  left as written and aren't reported.
- **M26: treat applied migrations as records.** Moot after M1: the migrations' comment rewrites
  are scripted and proven, so xcathletes-org stays `ordinary`.
- **I5's deferral of foreign citations.** Replaced by the single sweep, which merges every repo
  only after cairn-cms and workstation are approved.
