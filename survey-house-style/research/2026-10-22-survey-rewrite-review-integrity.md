# Survey rewrite review: data integrity and failure risk

Spec: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `ad97b5f`, the synthesis rewrite. Lens: what happens on a crash, a concurrent process, a partial write, an upgrade, a restore, or a second host, and whether data can be lost or silently corrupted. Line numbers are the spec's at `ad97b5f` unless a file is named. Rulings are taken as settled; no finding reopens one. Earlier integrity findings already folded (drafter inline, `vale sync` over vendored styles, provenance, corpus licensing, PR order) are not repeated.

Evidence read for this review: `~/.local/bin/claude-tooling-sync:397-437` (`fetch_skill`, `update_skills`), `~/.dotfiles/claude/.claude/tooling/vendored-skills.json`, `~/.dotfiles/bin/.local/bin/model-review-notify`, `~/.dotfiles/upkeep/.config/systemd/user/model-review.timer`, `~/.dotfiles/bin/.local/bin/check-drift`, `~/.dotfiles/claude/.claude/settings.json` (SessionStart, `outputStyle`), the `dependency-upgrade` SKILL.md, `cairn-cms/.github/workflows/publish.yml`, `approval-queue/src/lib/server/items.ts`, and the live queue state directory (item ids such as `20261013T124307-75201`; no pruning code).

Verdict: not ready. Two blockers, eight majors, nine minors, two optional, and one OWNER FORK (finding 9).

## Findings, ranked by consequence

### 1. Blocker, correctness: private text can reach the public repo and npm, and npm cannot take it back

Location: L209, L221, L231, L235, L244, L333, L374.

Defect: The publication rule at L231 covers corrections only, and only by the source repo's visibility. Five other paths carry private text into public places with no check:

- House examples come from "PR bodies and packets he approved (the approve verdicts in `decisions.jsonl`)" (L209, L374). Packets cover private repos (servers, phonebook), and a packet's text lives only in local queue state, so even a packet about a public repo publishes words that were never public. `house.md` ships in the npm tarball.
- Geoff's Pass D blind verdicts "file into the eval record" (L221, L333). The eval record is `evals/` in the public survey repo, and skill-creator's viewer saves free-text notes beside each verdict.
- A distill PR (L244) is opened and merged in the public survey repo by an unattended session. Its body and commit message will naturally cite the correction, its reason, and its source ref.
- `docs/writing-review/log.md` (L235) is in the public survey repo and takes a line a month with no stated content limit (the restructure record said counts only, the spec does not).
- A chat correction's "repo and its visibility" (L227) is written by the session that heard it. A correction about a reply, or in a repo the session misjudges, has no reliable visibility.

npm allows unpublish only within 72 hours and only without dependents, and mirrors keep copies. A leak through the package is effectively permanent.

Fold: State one rule for every published byte from the writing loop: Survey publishes only text that is already public, at a permalink. Each house example and each correction-derived example carries a `source:` permalink to a public repo at a commit, and the survey gate verifies it (the permalink's repo is public by `gh repo view --json visibility`, checked at release time, never read from the record, and the quoted text is present at that commit). An unknown or missing source counts as private. Reasons, comments, send-back notes, and queue-only packet text never ship. Geoff's Pass D verdicts and notes go to the ledger; the public eval record keeps counts. Distill PRs and commits cite opaque ledger record ids only. `log.md` holds numbers only, and the gate greps it and every changed pack file against a denylist (private repo names, host names, the ledger's address list). Add the check to "never escalate" at L463.

### 2. Blocker, correctness: both hosts run the monthly review, and the guard comes hours too late

Location: L238, L241, L244, L445, L160.

Evidence: `model-review.timer` is `OnCalendar=monthly`, `Persistent=true`, `RandomizedDelaySec=1h`, and the same unit is stowed on both hosts. `model-review-notify` has no host check (the restructure record also noted this).

Defect: Both hosts fire within an hour of each other on the 1st, or on wake. The step 2 guard checks for `scorecards/<YYYY-MM>.md` on origin, but that file is written at step 5, after about 126 fixed-task drafts and up to 70 graded pieces. So the second host passes the guard and runs everything:

- Both write the same `scorecards/<YYYY-MM>.md`. The standing answer "Records never share a file" (L443) is false for scorecards, and an unattended rebase conflict stops the run with the ledger half-pushed.
- Both distill the same corrections and each opens a survey PR that bumps to the same next version. The first publishes it. The second merges, its release runs, and the "skips a version already published" guard (L160, mirrored from cairn's `publish.yml`) exits 0. `main` then claims a version whose content differs from what npm holds, and nothing fails.
- The month's usage is spent twice, and Geoff gets two blind-sample pages.

Fold: Claim the month before step 3. The run commits `scorecards/<YYYY-MM>.claim` (host, time) and pushes. git rejects a non-fast-forward push, so exactly one host wins; the loser harvests, pushes, and stops. A claim older than 24 hours with no scorecard may be taken over, and the taker records it. Separately, the release step checks that the version in `package.json` is not already on npm before it tags, and fails loudly if it is; the publish guard's silent skip stays only for re-running a release whose tag already exists. Rewrite L443 and L445 to match.

### 3. Major, correctness: Pass E's symlinks can silently revert edits made after the Pass D snapshot

Location: L324, L339, L340, L430, L436.

Evidence: `~/.claude/docs/voice/approval-brief.md` was last modified 2026-10-21 and is edited often, since the approval queue's contract lives in it.

Defect: Pass D snapshots the files at one `~/.dotfiles` commit, and its stop (L430) covers a change during Pass D. Pass E runs after the approval queue's pass and Pass D's release, which can be weeks later. Pass E replaces each live file with a symlink, and its acceptance compares the link against the Pass D snapshot (L340), not against the file it replaces. Any edit made between the snapshot and the cutover is dropped by the symlink commit and the check passes. The same holds for the conventions skills' comment sections.

Fold: Two guards. From Pass D's close until Pass E's merge, the dotfiles gate fails when any snapshotted file's hash differs from the snapshot's `SHA256SUMS` (a freeze, with the message "carry this into Survey first"). And Pass E checks each file at `HEAD` immediately before its symlink commit against the pack bytes; a mismatch stops that symlink, the change goes to a Survey patch, and the vendored tag moves before the link lands. Add the stop beside L436.

### 4. Major, correctness: the vendored channel is non-atomic, never removes stale files, and has no checksum file to check

Location: L166, L170, L173, L274, L398.

Evidence: `fetch_skill` (`claude-tooling-sync:397-422`) fetches the file list, then writes each file with its own `gh api` call into the live directory, which is stowed, so running sessions read it at once. It never deletes a file the new tree lacks. `SHA256SUMS` is produced by the build into `vale/Survey/` (L166), and `fetch_skill` copies only files committed under `skills/survey/`.

Defect: Four failures follow.

- A network error halfway through leaves a directory that is part old version and part new, live on that host until someone notices.
- A release that renames or removes a pack file (major, but also a rollback from a minor that added one) leaves the old file in place. A symlink pointing at the old path keeps resolving to stale bytes.
- `sha256sum -c` checks only the files it lists, so stale files pass.
- If `SHA256SUMS` is a build output, the vendored copy has none, and the check at L170 and L274 has nothing to run against.

Fold: The survey repo commits `skills/survey/SHA256SUMS`, and its gate regenerates and diffs it; the build copies it into `vale/Survey/`. For the `survey` entry, `fetch_skill` fetches into a temporary sibling, verifies `SHA256SUMS`, then renames it over the old directory. The dotfiles gate fails on any file under the vendored path that `SHA256SUMS` does not list. This is new `claude-tooling-sync` code; add it to Pass E's estimate (about 30 minutes with tests). The workstation's rollback at L173 becomes `git revert` of the tag-bump commit, which is atomic, offline, and leaves no stale files, since vendored files are committed.

### 5. Major, correctness: a register or style path can stop being a link, or dangle at runtime, without any signal

Location: L270, L271, L274, L277, L286.

Evidence: `settings.json:327` sets `"outputStyle": "writing-voice"`. The SessionStart hook runs only `gather-dotfiles.sh`. `check-drift` has no Claude-tooling or output-style section.

Defect: The gate checks that "every symlink resolves". It cannot see a path that was a link and is now a regular file. That happens when an editor or an agent's write tool replaces the link instead of writing through it, which is the natural act of a session that "fixes" `approval-brief.md` in place. The pack stays untouched, so `sha256sum -c` passes, the path silently forks from Survey, and later releases never reach it. At runtime, a dangling style link (a half-finished fetch from finding 4, or a checkout of another branch) is only caught at the next gate run on that host. Claude Code reads the style at session start, and an unresolved style most likely falls back to the default with no error (not probed). Every session on that host would then write without the voice.

Fold: The gate asserts each of the seven paths is a symlink whose `readlink` equals its recorded target, not only that links resolve. `gather-dotfiles.sh` gains one cheap check: if `~/.claude/output-styles/writing-voice.md` does not resolve, or its target's hash is not in the vendored `SHA256SUMS`, print a one-line warning into the session context. Pass E probes the fallback once (a session with the link removed) and records what Claude Code does.

### 6. Major, correctness: the cairn editor harvest attributes other people's and bots' edits to Geoff

Location: L230, L357, L400.

Defect: The harvester diffs "the two blobs": the draft blob against Geoff's later save. Over the range `<draft>..<default>` the file can also change in commits by a volunteer, a later Claude edit, a scripted migration, or a cairn cascade such as a slug rename that rewrites links in other entries under the editor's identity. The diff from draft to Geoff's save includes all of them, so a volunteer's sentence becomes Geoff's correction and can ship as a house example. Two further gaps: the draft's reachability depends on how the draft commit lands. A squash merge rewrites its SHA and may push the trailer out of the final trailer block, and a draft on a `cairn/<concept>/<id>` pending branch is deleted at publish. Either case finds nothing and loses the correction silently.

Fold: Diff each of Geoff's saves against its own parent (`<save>^:<path>`), never against the draft. Take a save only while every commit to that path since the draft is Claude's draft or Geoff's save. Stop pairing at the first commit by anyone else. Take a save only when it touches that entry's one path and its subject names that entry's id. Record the draft at draft time instead of finding it later: `content-draft` writes a ledger record (repo, path, blob SHA, commit) as well as the trailer, so the pairing survives squash, rebase, and branch deletion. Add fixtures to L357 for an intervening volunteer edit, a cascade commit, and a squash-merged draft.

### 7. Major, correctness: the baseline can drift down, and a model change reads as a Survey regression

Location: L216, L218, L219, L220, L239, L242.

Defect:

- "An accepted improvement becomes its surface's new baseline" (L220), and "match" allows one standard deviation below the baseline mean (L218). A change that beats on blind preference but sits lower on the rubric can pass, and the next change is judged against it. Over a year of monthly distills, the floor can fall several deviations with every step passing.
- The drafting model is not pinned in the arms (L216), and the monthly model review changes the workstation's models. A stored baseline from one model compared with a candidate on another measures the model. Step 6 then opens backlog items for drops Survey did not cause, and a "beat" can be the model's.
- A rollback patch (L162) is judged against the bad version's baseline and may fail to match it.

Fold: Keep the Pass D baseline as a fixed floor. Every change must match both the rolling baseline and the Pass D one. Record the drafting model and Claude Code version in every `benchmark.json`. A match or beat always runs the baseline arm in the same run as the candidate (paired), never against stored numbers from another model. Key baselines by Survey version, so a revert patch is judged against the version it restores. The scorecard marks a drafting-model change as a break, like a judge change.

### 8. Major, correctness: the rollback path needs Geoff's 2FA, but the standing answers assume a session can do it

Location: L162, L417, L487, L244.

Defect: Pre-flight sets "Require two-factor authentication and disallow tokens" (L487). Trusted publishing covers `npm publish` only, so `npm deprecate` and `npm dist-tag` then need Geoff's interactive 2FA login. Yet Pass B's stop (L417) says "deprecate that version and cut a patch ... without asking", and the rollback rule (L162) starts with deprecation. An unattended monthly run that ships a bad example cannot deprecate it. The `next` tag also stays on `1.0.0-rc.1` after 1.0.0 unless someone moves it.

Fold: The session publishes the superseding patch, which it can do through the workflow, and hands deprecation to Geoff as a `[you: npm deprecate @glw907/survey@<v> "<reason>; use <patch>"]` line in the next packet. Rewrite L417 and L162 to say so. The approval queue's promotion step adds `[you: npm dist-tag rm @glw907/survey next]`, or moves `next` to 1.0.0.

### 9. Major, correctness, OWNER FORK: the workstation never takes a Survey minor, so improvements skip the always-on surface

Location: L170, L372, L239, L244.

Evidence: `dependency-upgrade` names no vendored skill and no `vendored-skills.json` tag. Its sweeps cover package manifests.

Defect: Pass H (L372) relies on `dependency-upgrade` to carry each minor into repos, and the monthly distill releases minors. The workstation, where the output style, the router, and most replies live, moves only when a session bumps the vendored tag by hand. Pass F does this once, for 1.2.0. After that the workstation stays behind, step 3 keeps grading the old pin, and the loop's improvements never reach the always-on surface. Nothing reports that the workstation is behind.

**OWNER FORK** (how the always-on surface follows Survey):

- (a) The monthly run, after its release, bumps the vendored tag in a `~/.dotfiles` direct change after the gate, with `git revert` as the rollback (finding 4). `check-drift` warns when the vendored tag trails the latest release.
- (b) The vendored tag moves only through a packet, so Geoff sees every change to always-on writing before it lands.
- (c) `dependency-upgrade` learns vendored tags, and the workstation takes Survey in the same sweeps as every repo.

Recommendation: (c) with the `check-drift` warning from (a). Ruling 5 already ships examples without asking, and the sweep is the workstation's single path for taking a version, so a third path is not needed. Either way, step 3 states which version it grades and the scorecard names it.

### 10. Major, correctness: the distill has no record of what it consumed, so a crash or a stop loses or repeats a month

Location: L237-L245, L446, L447.

Defect: Step 8 takes "the month's new corrections", and L447 keeps a failed proposal's corrections "for the next run", but nothing records which corrections a run consumed. If the run dies after step 5 writes the scorecard, the other host and the next retry both stop at the step 2 guard, and that month's distill never runs. Whether its corrections count as "new" next month depends on an undefined rule. The usage-limit answer (L446) marks the scorecard partial but says nothing about steps 6 to 8. Because the review is chained after the model review's prompt audit, which exits 1 on failure before the review session starts (`model-review-notify`), a failed audit also skips the writing review with no log line.

Fold: Each run writes `reviews/<YYYY-MM>.md` listing the correction ids it consumed, the proposals made, and each outcome. The distill's input is every correction in no review record, not "this month's". The step 2 guard tests for a completed review record, not the scorecard alone, so a run that died after step 5 resumes at step 6. `check-drift` warns when the previous month has no completed review record. That catches a skipped month whatever the cause.

### 11. Minor, correctness: ledger record keys and rewrites are not safe for two writers

Location: L227, L229, L443.

Defect: "A second harvest, or the other host, writes the same file" holds only if the bytes are the same. The harvester's candidates are deterministic, but the session's step that "keeps only those about wording and names each one's surface" is a model judgment, so a second run can write different bytes to the same path and turn a clean rebase into a modify/modify conflict. Queue item ids are timestamp-and-PID (`20261013T124307-75201`) and are unique only per host. Chat corrections have no natural source key. A chat session and the monthly run on one host also share one ledger checkout and its index.

Fold: Records are create-only: a writer skips a path that exists, and a reclassification is a new record that names the one it supersedes. Keys are `queue-<host>-<item id>-<n>`, `cairn-<repo>-<save sha>`, and `chat-<session id>-<n>`. Every ledger write commits by path (`git commit -- <file>`) and retries once on `index.lock`.

### 12. Minor, correctness: in-review edits can become unreachable before the monthly harvest

Location: L229.

Defect: `Edit <file> in review` commits sit on a PR branch. After a squash merge and branch deletion, the harvest a month later may not find them in a fresh clone, so the correction is lost without a trace.

Fold: The harvester fetches `refs/pull/<n>/head` for each decided item's PR (GitHub keeps it after branch deletion), and the fixture at L357 includes a squash-merged, deleted branch.

### 13. Minor, correctness: a chat correction on a host without a ledger clone, or offline, is lost or stranded

Location: L227, L228, L358.

Defect: The chat route "commits and pushes" and asks nothing. On a host without the clone (a restore, a fresh host, or thinkpad-x1 before Pass F's host step), the write fails, and the session asks nothing about it. Offline, the commit stays local, and the grading host on the other machine never sees it.

Fold: With no clone, the route writes to `~/.local/state/survey/spool/` and says one line. The next run's step 1 drains the spool. `check-drift` gains a ledger section modeled on `check_initiatives`: missing clone, ahead of origin, or behind.

### 14. Minor, correctness: the release zip is mutable, and the zip gate depends on the network

Location: L160, L169, L398, L416.

Defect: A GitHub release asset can be deleted or replaced after publish, unlike an npm version, and every zip-channel repo then syncs different bytes under the same URL. The zip diff check downloads on every gate run, so a GitHub outage or an offline laptop fails seven repos' gates. cairn's gate is offline by design. And a re-run after npm succeeded but the zip upload failed: if the already-published guard skips the whole job, the zip never uploads.

Fold: Turn on GitHub's immutable releases for the survey repo before the first release. Each zip-channel repo commits the zip's SHA-256 beside its pin, and its gate compares the committed copy against that hash offline, downloading only when the pin moves. The workflow's guard skips only the `npm publish` step, and the zip upload uses `--clobber` before immutability locks it (or uploads before publishing).

### 15. Minor, correctness: `workflow_dispatch` can publish from any branch

Location: L160.

Evidence: cairn's `publish.yml` takes `workflow_dispatch` with no ref guard.

Defect: A manual dispatch, or an unattended session that reaches for one, publishes whatever version an unmerged branch carries, and npm keeps it.

Fold: The publish job requires `github.ref == 'refs/heads/main'` or a tag whose commit is on `main`, and fails otherwise.

### 16. Minor, correctness: the placeholder publish has no content check before an irreversible step

Location: L487.

Defect: `npm publish` sends every file in the directory that is not ignored. The directory is staged by a session, and a stray scratch file goes to the registry under Geoff's name.

Fold: The staged `package.json` sets `"files": ["README.md"]`, and Geoff runs `npm pack --dry-run` first. Add a check: it lists only `package.json` and `README.md`.

### 17. Minor, correctness: the eval harness does not prove the arm's style applied

Location: L216, L326.

Defect: The arms depend on `--settings '{"outputStyle":...}'` and `--disable-slash-commands`, as probed on one Claude Code version. If an upgrade changes either flag, both arms may run the default style. "Match" then passes for every surface, and the planted bad draft (L326) tests the graders, not the arms.

Fold: Each run first runs `claude -p "/output-style"` in the arm's scratch project and fails unless the arm's style is listed as current. Record the Claude Code version in `benchmark.json`.

### 18. Minor, correctness: "each commit revertable alone" is not true for the vendored entry

Location: L339.

Defect: The symlinks depend on the vendored `survey` entry, so reverting that first commit alone leaves every link dangling.

Fold: Say "revert in reverse order". The gate's link check (finding 5) fails a revert that breaks a link.

### 19. Minor, correctness: the dry run has no named way to point at a scratch ledger

Location: L235, L357.

Defect: `model-review-notify --dry-run` today only tells the session not to push or open a PR. Step 1 harvests into the real ledger and pushes, and nothing names how the run finds a scratch ledger. A dry run can then write test records into the real ledger.

Fold: The prompt reads the ledger path from `SURVEY_LEDGER_DIR`, defaulting to `~/Projects/survey-ledger`. The dry run sets it to a scratch clone with no push remote.

### 20. Minor, optional: the fixed tasks re-run every month even when nothing changed

Location: L239, L247.

Defect: About 126 drafts a month measure only noise when neither the pinned Survey version nor the drafting model changed. That is over-ceremony against "the minimum that gives a trend" (ruling 7).

Fold: Step 3 runs only when the pinned version, the drafting model, or the judge changed since the last scorecard, and otherwise carries the last figures forward, marked as carried. Real-sample grading and the blind six still run every month.

### 21. Minor, optional: writing-only minors trigger the ruled render in every npm app

Location: L316, L372, L244.

Defect: The ruled render line fires on every minor Survey bump in an app. Pass H's fourteen pack minors, plus a minor from most monthly distills, would each ask seven npm apps for a full-page render in both schemes, although a writing-only release changes no CSS.

Fold, within the ruling: apps take Survey in `dependency-upgrade`'s regular sweeps, never per release, so one render covers every minor since the last sweep. The changelog's `writing` rung tells the reader the render is a confirmation, not a hunt.

## Notes, no fold needed

- Two hosts writing distinct correction files is sound once finding 11's create-only rule holds, and a private GitHub repo is a reasonable restore point for the ledger.
- The Pass D `cmp` and verbatim checks, and the "never bump to retry" publish rule, are correct as written.
- The approval queue never prunes `items/`, so a host that sleeps through a month loses no queue corrections.
