# Survey Pass 3 plan review: data integrity and failure risk

Target: `plans/2026-10-22-survey-pass-3-plan.md` at `cdc5d99`. Design: `specs/2026-10-21-survey-house-style-design.md`, "Pass 3". Lens: crash, concurrency, partial write, upgrade, restore, privacy. Verified against `~/.dotfiles/bin/.local/bin/model-review-notify`, `~/.dotfiles/upkeep/.config/systemd/user/model-review.{timer,service}`, `~/.local/bin/claude-tooling-sync` (`fetch_skill`, `update_skills`), `~/Projects/survey/scripts/release`, `~/.dotfiles/claude/.claude/settings.json`, `~/.claude/skills/approval-packet/SKILL.md`, `claude --help` (2.1.308), and the live process tree on pavilion.

Ranked by consequence.

## 1. The background session is likely killed when the timer's oneshot unit exits (blocker, correctness)

Location: plan:40 (launcher block), plan:44 (end-to-end test).

Defect: `model-review.service` is `Type=oneshot` with the default `KillMode=control-group`. When `model-review-notify` exits, systemd stops the unit and kills every process left in its cgroup. On pavilion today the `claude bg-pty-host` and `bg-spare` processes sit in the cgroup of the Ptyxis scope that spawned them (`/proc/<pid>/cgroup` shows `app.slice/ptyxis-spawn-...scope`), so a `claude --bg` started from the service at 00:15 on the 1st, with no terminal daemon running, would put its daemon in `model-review.service`'s cgroup and lose it the moment the launcher returns. The session would die before drafting, or partway through, with no packet and no report. The plan's end-to-end test runs the `claude` line by hand from a terminal, so it exercises the terminal scope and cannot catch this. The first real evidence would arrive on 2026-11-01.

Fold: launch through its own unit, `systemd-run --user --unit=survey-writing-$(date +%Y-%m) --collect claude --bg ...` (or set `KillMode=process` in `model-review.service`, which the dotfiles PR can carry). Then run the end-to-end test the way the timer runs it: `systemctl --user start` on a test unit, or the `systemd-run` line itself, not a bare terminal call. Accept: after the launcher exits, `claude agents --json` still lists the session as running.

## 2. A session waiting days on a packet has no recovery when it dies (major, correctness)

Location: plan:39 ("waits for the decision, and on approve runs the merge order").

Defect: the wait is a background Bash `approval-queue packet` call inside the session (approval-packet step 6). The daemon's sockets live under `/tmp/cc-daemon-1000/`, so a reboot (a Bluefin update, a power cut), a `claude respawn` after a Claude Code upgrade, or finding 1 ends the wait. Geoff's later approve then has nobody to act on it. The two PRs stay open, nothing gets released, and nothing says so. Next month's run then opens a second pair of PRs against a stale base (finding 3).

Fold: one sentence in `writing-prompt.txt` and the skill's "Releasing a change". Before sending, the session writes its two PR numbers and the packet id to `monthly/<YYYY-MM>/report.md` and pushes. Any later session that finds an approved, unacted packet runs the merge order from that file. The launcher (or `check-drift`) reports an open `survey-writing-*` PR older than 7 days. The plan's standing answers also need one for "the session died before acting on a decision".

## 3. Two runs in one month, or a run while last month's packet is open, collide (major, correctness)

Location: plan:40, plan:39.

Defect: nothing makes the run idempotent. The timer catches up a missed run (`Persistent=true`), anyone can start the service by hand, and finding 2 leaves stale sessions behind. Two sessions would write the same `monthly/<YYYY-MM>/` files at once and both propose a "minor". Both would compute the same next version from `package.json`. The second `scripts/release` then fails at `git tag -a` because the tag already exists, after its PR has merged, leaving a merged-but-unreleased Survey and a vendoring PR that points at the other run's tag. `--name` is a display name and does not stop a second session with the same name.

Fold: the launcher skips the launch, printing why, when `claude agents --json` lists a live `survey-writing-*` session, or `origin/main` of survey-notes already has `monthly/<YYYY-MM>/report.md`, or `gh pr list -R glw907/survey --search "head:survey-writing-"` returns an open PR. Three guard lines, no lock file.

## 4. "The month's corrections" reads the wrong month (major, correctness)

Location: plan:39 ("the month's files in `corrections/`").

Defect: the timer fires at 00:15 on the 1st, so the current month's corrections folder is empty. If the session reads it literally, the run whose whole job is to grade against corrections sees none, and silently proposes nothing every month.

Fold: say "every correction file dated after the previous `monthly/` folder's report commit (all of them on the first run)". A filename-prefix comparison against the previous folder's month does the same job.

## 5. Correction content can leak into the public Survey repo (major, correctness; partly OWNER FORK)

Location: plan:39 ("proposes Survey changes, each with a before-and-after example"), plan:29 (the Context section).

Defect: `glw907/survey` is public (`gh api repos/glw907/survey` reports `public`), and `glw907/workstation` is public too. A correction's Before, After, and Context quote Geoff's chat from any repo, including the private ones (servers, phonebook, mail). The natural before-and-after example for a proposal is the correction itself, copied into a public `SKILL.md`, register file, CHANGELOG, or PR body. Nothing in the plan forbids that. A second path: if the survey-notes clone fails on thinkpad-x1 (offline, auth), plan:29 does not say what happens next. An improvising session could write the file into its current repo, which might be public.

Fold (correctness part): one rule in `writing-prompt.txt` and the skill. Public artifacts (Survey files, both PR bodies, CHANGELOG) never quote a correction file, its Context, a private repo's name, a path, or a person. Examples there are written fresh to show the same pattern. The packet may cite correction file names, since the queue is local. And in `## Corrections`: if the clone or the write fails, say so and stop; never write the file anywhere else.

OWNER FORK: what a correction file may contain at all. Its contents sit on GitHub as a private repo, a third-party store outside the "audience: Geoff only" list in the settings `environment`.
- (a) Anything, verbatim.
- (b) Verbatim Before, After, and Reason, with Context trimmed to the surrounding sentence and never containing a secret, a token, mail content, or third-party personal data.
- (c) Corrections from sessions in private repos are skipped.

Recommendation: (b).

## 6. The push allow rule also allows a force push (major, correctness)

Location: plan:15.

Defect: `Bash(git -C /var/home/glw907/Projects/survey-notes push:*)` is a prefix rule, so it matches `push --force` and `push -f origin main`. An allow rule runs the command without the auto-mode classifier, which would otherwise block a force push. `settings.json` has no deny rule for force pushes. A session whose `pull --rebase` hit trouble could force push and erase the other host's corrections without a prompt. A private repo on GitHub Free may not support branch protection to backstop it.

Fold: exact rules with no wildcard: `Bash(git -C /var/home/glw907/Projects/survey-notes push)` and `Bash(git -C /var/home/glw907/Projects/survey-notes pull --rebase)`. The skill uses exactly those strings. The pre-flight check still counts 2.

## 7. Unpushed and diverged corrections are missed silently (major, correctness)

Location: plan:29 (the write sequence), plan:40 (`git -C ~/Projects/survey-notes pull --ff-only`), plan:66.

Defect:
- A commit that lands without its push (session killed between the two, offline, the standing answer at plan:66) stays local until that host's next correction. thinkpad-x1 may go weeks without one, and pavilion's monthly run never sees those corrections.
- On pavilion, one local unpushed correction plus any thinkpad push makes the branches diverge. The launcher's `pull --ff-only` then refuses. The script has no `-e`, so it launches anyway on a stale tree and never says the data is incomplete.
- The plan gives no failure handling for a `pull --rebase` that fails (for example, a tracked file left modified), only for a prompt.

Fold:
- The launcher runs `git -C ~/Projects/survey-notes pull --rebase && git -C ... push`, and prints a line naming the failure on refusal.
- The `## Corrections` step says a failed pull or push leaves the commit local and goes on, since the next correction's push carries it.
- One line in `check-drift` (or the dotfiles drift check) reports survey-notes ahead of `origin/main`. That catches the quiet-host case on both machines.

## 8. With proposals, the monthly folder is never committed before the wait (major, correctness)

Location: plan:39 ("With no proposal it commits the folder... With proposals it follows... up to the packet").

Defect: only the no-proposal branch commits and pushes `monthly/<YYYY-MM>/`. With proposals, the drafts and `report.md` sit uncommitted in pavilion's shared survey-notes checkout through a days-long wait. A death in that window (findings 1 and 2) loses the baseline for the next comparison. That next run also compares against a folder that was never pushed.

Fold: commit, pull with rebase, and push the folder first, in both branches, before any proposal work.

## 9. The writing run is skipped whenever the audit or the review fails (minor, correctness)

Location: plan:40 ("a block after the review session"); `model-review-notify:29-32` and `:40-43` both `exit 1`.

Defect: a block placed after the review never runs when the prompt audit or the review session fails, and no catch-up follows, since the timer has already fired. The plan's "leaves the review's exit status alone" also needs the script to save the review's status and `exit` with it at the end. Otherwise the last command's status (the `echo` or `claude --bg`) becomes the unit's result.

Fold: change the review's `exit 1` to `review_status=1`, run the writing block, then `exit "$review_status"`. Or state that a failed review skips the writing month on purpose.

## 10. The writing session works in the primary Survey checkout (minor, correctness)

Location: plan:40 ("from `~/Projects/survey`", no `-w`).

Defect: the session branches, commits, and waits in the primary checkout of `~/Projects/survey`, which is also the launch checkout of every attended Survey pass. That breaks "one executor per worktree". `scripts/release` needs that checkout on a clean `main` at `origin/main` (`release:10-13`), so a session parked on its proposal branch for days blocks any other release there. Survey-notes' `.vale.ini` reads `StylesPath` from that checkout's working tree (plan:37), so whatever branch it holds changes the Vale results the month-to-month comparison depends on. The launcher's `pull --ff-only` also fails silently once the checkout is off `main`.

Fold: launch with `-w survey-writing-<YYYY-MM>`, as the review session does (`model-review-notify:41`). `scripts/release` then runs in the primary checkout after `git switch main && git pull --ff-only`. Pointing `StylesPath` at the release's `Survey.zip` would pin it fully, but that goes beyond this pass. Recording the Survey commit in `report.md` is enough.

## 11. The vendor `cmp` check misses stale extra files (minor, correctness)

Location: plan:44 ("`cmp` shows each vendored file equals the Survey branch's copy"), plan:45.

Defect: `fetch_skill` (`claude-tooling-sync`, around line 398) runs `mkdir(exist_ok=True)` and writes the upstream files, but never removes a file that upstream deleted or renamed. A monthly proposal that renames a register file would leave the old copy vendored and stowed under `~/.claude/skills/survey/writing/`, still linkable, while the per-file `cmp` passes.

Fold: make the accept check `diff -r <survey-branch>/skills/survey claude/.claude/skills/survey` (both directions), and have "Releasing a change" remove the vendored directory before `update-skills`. Fixing `fetch_skill` to prune belongs to the backlog, not this pass.

## 12. A partial release has no standing answer (minor, correctness)

Location: plan:53; `scripts/release:20-29`.

Defect: the release pushes the tag, then runs `gh release create`. If the second step fails, a rerun dies at `git tag -a` because the tag already exists. The vendoring check still passes against the bare tag, so the workstation PR merges with no `Survey.zip`.

Fold: one standing answer. If the tag exists without a release, run `gh release create` by hand with the same notes and asset, then go on. The same answer covers the monthly session.

## 13. A correction that is written but never staged is orphaned (minor, optional)

Location: plan:29 (`git add <file>`).

Defect: a session killed between writing the file and `git add` leaves it untracked. Later corrections stage only their own file, so the orphan never commits on its own. The pavilion monthly run would see it locally, while thinkpad-x1's orphans never reach the run. Two sessions on one host in the same second would collide on one filename. The Write tool then refuses, since the file exists unread, which at least avoids a silent overwrite.

Fold: stage `corrections/` rather than the one file. If the name exists, add `-2`.

## 14. thinkpad-x1 runs the old skill until its dotfiles are pulled (minor, optional)

Location: plan:54.

Defect: the merge order pulls and restows only pavilion. thinkpad-x1 keeps v1.1.0, with no `## Corrections` section and no output-style paragraph, until someone pulls there, and its corrections go unlogged in the meantime. It will also lack `~/Projects/survey-notes` until the first correction clones it.

Fold: one routine row in the hand-over. On thinkpad-x1, pull `~/.dotfiles`, run `stow -R claude`, and clone survey-notes.

## 15. The executor's dotfiles worktree may fail to attach the planner's branch (minor, correctness)

Location: plan:15, plan:26.

Defect: the planner commits on `survey-pass-3` in its own dotfiles worktree. If that worktree still exists, the executor's `git worktree add .claude/worktrees/survey-pass-3 survey-pass-3` fails with "already checked out". If the planner pushed without keeping a local branch, the command needs `-b` or `--track origin/survey-pass-3`.

Fold: the planner removes its worktree after the push. The executor runs `git -C ~/.dotfiles fetch && git -C ~/.dotfiles worktree add .claude/worktrees/survey-pass-3 -B survey-pass-3 origin/survey-pass-3`.

## 16. The private repo is missing from the auto-mode visibility list (minor, optional; OWNER FORK)

Location: `settings.json:343` (not touched by the plan).

Defect: the classifier's visibility list, dated 2026-10-17, names neither `survey` (public) nor `survey-notes` (private). The classifier is the one check that would flag a session copying correction text into a public repo (finding 5). Editing `autoMode` needs Geoff's ask in the session, the same as the push rule.

OWNER FORK:
- (a) Add both names during the same pre-flight ask.
- (b) Leave the list alone and rely on finding 5's prompt rule.

Recommendation: (a). It is one line in the same sitting.

## Over-ceremony

- **Duplicated format text (minor, optional; cost: small, plus ongoing drift).** survey-notes' `README.md` (plan:37) restates the correction format that `SKILL.md` owns, so the two copies will drift. Fold: the README links to the skill section instead.
- **Full-scale end-to-end test (minor, optional; cost: about ten Opus drafts plus a report, a few minutes of path and a moderate token spend).** The test is worth keeping, because it is also the baseline, but it should run on the systemd path (finding 1), or it spends its tokens without testing the one risk that matters. If the path is fixed, keeping the test is fine.
- No other ceremony is out of proportion. The `## Before merge` tag-diff check is cheap and catches real drift (`v1.1.0` is `061d9a4` while the vendored commit is `0576b29`, so only a content diff, not a SHA compare, can show they match).
