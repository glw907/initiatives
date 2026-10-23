# Survey Pass 3 plan review: contract and criteria

Target: `plans/2026-10-22-survey-pass-3-plan.md` at initiatives `cdc5d99`, against the design's "Pass 3", Brief, and Standing answers. Verified against `~/Projects/survey` (`061d9a4`), `~/.dotfiles` (`0b98943`), `tellgrader --help` and its source, `claude --help`, `claude daemon --help`, and the `model-review` user units.

Verdict: the plan covers every Pass 3 promise in shape, and its scope additions (the "Releasing a change" section, the line-10 fix, the `prompt.txt` sentence) are each justified. One blocker: the monthly step's production launch path is likely to kill its own session, and the end-to-end test can't see that. Six majors are criteria that pass vacuously or a promise with no test.

## Blocker

### B1. The background session launched from the systemd oneshot probably dies when the unit exits, and the hand-run test can't detect it

- Severity: blocker. Tag: correctness.
- Location: plan:40 (the launcher block), plan:44 (the end-to-end test).
- Defect: `model-review.service` is `Type=oneshot` with the default `KillMode=control-group` (`~/.dotfiles/upkeep/.config/systemd/user/model-review.service`). `claude daemon --help` says: "Service install is disabled in this version: the daemon runs on demand and exits when the last client disconnects." Today's daemon is `claude daemon run --origin transient`, living in a Ptyxis scope's cgroup. At 00:15 on 2026-11-01, with no terminal-spawned daemon running, `claude --bg` from the unit would spawn the daemon inside `model-review.service`'s cgroup. When the script's last line returns, systemd kills that cgroup, and the session waiting on the packet dies with it. The launch itself succeeds, so the standing answer "fails to launch" (plan:63) never fires. The end-to-end test runs the `claude` line by hand from an executor session, where a daemon is already running, so it passes whether or not the real path works. It also never runs the script's own block (the guard, the two pulls, the prompt assembly); only `bash -n` touches it.
- Proposed fold: make the session independent of the unit's cgroup, then test the real script under systemd.
  1. Add `KillMode=process` to `model-review.service` (add the unit to task 3's Files; `upkeep/` is in the dotfiles map), or launch the writing review through `systemd-run --user --unit=survey-writing-<YYYY-MM> --collect` so it gets its own unit. Either way, add a probe: with `claude daemon status` showing no daemon (run it on a host or at a moment with no live background session, or name that the probe needs one), start a trivial `claude --bg` from `systemd-run --user --wait -p Type=oneshot`, and check that `claude agents --json` still lists it after the unit exits.
  2. Replace the hand-run with the real script. Run `model-review-notify --dry-run` under `systemd-run --user --wait`, with a `BASH_FUNC_claude%%` stub (or an equivalent shim) that answers the two `-p` calls and passes `--bg` through to the real binary. That way the model review isn't spent. Accept: the unit exits 0, and `claude agents --json` lists `survey-writing-<YYYY-MM>` after the unit has exited.
  3. Add a standing answer: if the probe shows the session dies and neither fix holds, the launcher block ships with `## Decisions` naming that the first real run is attended.

## Major

### M1. The end-to-end criterion checks file counts, not the report, so comparison, corrections, and proposals pass vacuously

- Severity: major. Tag: correctness.
- Location: plan:44 (end-to-end test), plan:39 (report contents).
- Defect: the accept is "ten drafts and `report.md` in a local commit." An empty `report.md` passes. In the first run there is no previous month and `corrections/` is empty, so the design's "compares them with last month's drafts and with the month's corrections" is never exercised. The "proposes Survey changes, each with a before-and-after example, in one packet" path is also never exercised: the dry run stops before any PR, and with no corrections and no history there is likely nothing to propose. None of the four outputs the design promises has a criterion that could fail.
- Proposed fold: fix the report's shape in `writing-prompt.txt` and assert it. The report must have one `## <nn>-<kind>` section per sample, each giving the Vale alert count and the `tellgrader` finding count, plus `## Previous month`, `## Corrections`, and `## Proposals`. The last three must each say "none" with a reason when empty, and each proposal must carry `Before:` and `After:` lines. Accept: `ls monthly/2026-10/[0-9][0-9]-*.md | wc -l` prints 10, and `grep -c '^## '` on `report.md` prints 13. The test fails if the session skips a sample or a leg.
- OWNER FORK (budget versus coverage) on exercising the comparison and corrections legs before 2026-11-01:
  - (a) Accept them as unexercised. `## Decisions` names 2026-11-01 as their first test, and the conductor reads that report. This adds no cost.
  - (b) Run a second, fixture session against a scratch clone seeded with `monthly/2026-09/` and one correction file. The launcher would then need to pass the notes path into the prompt. This costs one more Opus 5.5 medium session of ten drafts.
  - (c) Run only the fixture session (b) and skip the October baseline, so the first comparison lands in December.
  - Recommendation: (a), with the section assertions above, because the November run is cheap to read and the legs are prompt text, not code.

### M2. The monthly window is off by a month

- Severity: major. Tag: correctness.
- Location: plan:39 ("the month's files in `corrections/`", `monthly/<YYYY-MM>/`), plan:40 (`--name survey-writing-$(date +%Y-%m)`).
- Defect: the timer fires on the 1st (`OnCalendar=monthly`, next run 2026-11-01 00:15). At that moment `date +%Y-%m` is `2026-11`, so "the month's corrections" means files dated November, of which there are none. October's corrections, the ones this review exists to read, are never read. The folder and the session would also be named for the month just starting.
- Proposed fold: define the window in the prompt as every correction file whose name sorts after the previous `monthly/` folder's run, or simply the previous calendar month (`date -d 'last month' +%Y-%m`). Name the folder and the session the same way. The end-to-end test's folder then follows from that rule rather than from today's date.

### M3. "Releasing a change" leaves out steps the unattended monthly session needs to finish a release

- Severity: major. Tag: correctness.
- Location: plan:31, used by plan:39.
- Defect: the section lists the PR, `scripts/release`, the vendoring PR, the before-merge diff, the merge, the pull, and `stow -R claude`. It leaves out steps that a session running with nobody present would hit:
  - the version bump (`npm version <v> --no-git-tag-version`) and the dated `CHANGELOG.md` entry, without which `scripts/release:14-16` refuses;
  - `npm ci` before the release, which the `scripts/release` header requires;
  - the `PREMERGE_DONE=<n>` prefix that `claude-merge-guard` requires on the workstation merge;
  - `-R glw907/<repo>` and `--match-head-commit <head>` from the decision (approval-packet step 7);
  - the post-stow check that the output style still loads;
  - the rollback, which is pinning the previous tag.

  Pass 2 and this plan's own "Merge order" (plan:53-54) carry these steps. The skill section the monthly session follows does not.
- Proposed fold: write the section as the plan's merge order, generalized to `<version>`, with each of the steps above. Accept: `grep -c -E 'npm version|npm ci|PREMERGE_DONE|match-head-commit|output-style' skills/survey/SKILL.md` prints at least 5.

### M4. The monthly session works in the main Survey checkout

- Severity: major. Tag: correctness.
- Location: plan:40.
- Defect: the launch is `claude --bg ... from ~/Projects/survey`, with no `-w`. When the session makes proposals, it branches and edits in `~/Projects/survey`'s main checkout, which collides with any pass working there (CLAUDE.md "One executor per worktree"). It also leaves the checkout off `main` for the next `pull --ff-only`. The model review it sits beside uses `-w model-review-<YYYY-MM>`.
- Proposed fold: launch with `-w survey-writing-<YYYY-MM>`, after checking that `--bg` accepts `-w`. Have "Releasing a change" say that the vendoring happens in a `~/.dotfiles` worktree, as plan:31 already implies.

### M5. Nothing tests that a chat correction actually produces a pushed file

- Severity: major. Tag: correctness.
- Location: plan:28-36 (task 1), plan:51-55 (merge order).
- Defect: the design promises that "the output style names this step, so it runs without his asking." The plan's acceptance checks only the diff's file list and gates. No criterion shows that a correction made in chat creates `corrections/<date>T<time>-<host>.md` with its frontmatter and four sections, quotes the reason, commits, and pushes. A paragraph that never triggers passes every criterion.
- Proposed fold: add a merge-order step after the stow. From `/tmp`, the conductor runs `claude -p` with a scripted correction: a sentence, a rewrite, and a stated reason. It then checks four things:
  - exactly one new file matches `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}-pavilion\.md$`;
  - the file holds `date`, `host`, `repo`, and `audience` and the four headings;
  - Reason quotes the scripted reason;
  - `git -C ~/Projects/survey-notes log origin/main -1` names it.

  A second scripted correction with no reason must produce "not stated." After that, the conductor runs `git rm` on both files in a commit, so the November review doesn't read fixtures as real corrections. Add a standing answer for a failure: file it through `log-issue` and report in STATUS.

### M6. The tellgrader criterion can't fail

- Severity: major. Tag: correctness.
- Location: plan:36.
- Defect: `tellgrader --help` says it exits 2 only "when a finding gates", and "only trailing-hinge-run and appositive-stack gate, and only under the docs-register profile". `--register agent` on two files in a repo with no `.tellgrader.json` exits 0 whatever it finds. So "exits 0" is vacuous.
- Proposed fold: assert on the JSON. Either `tellgrader --register agent <files> | jq -s '[.[].findings[]] | length'` prints 0, or each remaining finding is listed in the Survey PR's `## Decisions` with its disposition.

## Minor

### m1. The writing paragraph's criterion doesn't check what the paragraph says

- Severity: minor. Tag: correctness. Location: plan:32, plan:36.
- Defect: "adds one paragraph and removes nothing" passes for any paragraph.
- Fold: add `grep -c 'Corrections' skills/survey/writing/writing-voice.md` prints 1, and check that the added paragraph names the `survey` skill.

### m2. Task 1 never checks the description trigger or the line-10 fix

- Severity: minor. Tag: correctness. Location: plan:30, plan:33, plan:36.
- Fold: `head -4 skills/survey/SKILL.md | grep -c -i 'correct'` prints at least 1, and `grep -c glw907 skills/survey/writing/technical-doc-go.md` prints 0. Line 10 is the only hit today.

### m3. The PR-body sample takes the wrong tellgrader register

- Severity: minor. Tag: correctness. Location: plan:39.
- Defect: the PR body is mapped to `docs`, but its register file is `commit-and-pr.md`, and `tellgrader`'s `commit` register is the one that bans the em dash (`scan.go` `emDashBanned`). CLAUDE.md says commits and PRs go without it. Grading the PR body as `docs` hides that tell.
- Fold: map the PR body to `commit`.

### m4. Nothing checks the prompt file's content

- Severity: minor. Tag: correctness. Location: plan:39, plan:44.
- Fold: `grep -c -- '--register' docs/model-review/writing-prompt.txt` prints 10, each sample line names an existing file under `claude/.claude/skills/survey/writing/`, and `git diff origin/main -- docs/model-review/prompt.txt` adds one sentence.

### m5. A failed audit or model review skips the writing review

- Severity: minor. Tag: correctness. Location: plan:40, `model-review-notify:29-32,40-44`.
- Defect: both earlier steps end with `exit 1`, so a block placed "after the review session" never runs when either one fails. The plan says the block "leaves the review's exit status alone" but doesn't say whether the block should run after a failed review.
- OWNER FORK:
  - (a) Run the writing review regardless. Save the review's status, run the block, and exit with the saved status.
  - (b) Keep it coupled, so a bad month skips both.
  - Recommendation: (a). The two reviews share nothing but the timer.

### m6. The dry-run sentence doesn't fit the writing session

- Severity: minor. Tag: correctness. Location: plan:40.
- Defect: the sentence the launcher appends says "commit on your branch and stop." The writing session commits on `survey-notes` `main` and must also send no packet.
- Fold: give the writing session its own sentence: "Dry run: commit in survey-notes and stop. Do not push, open a PR, or send a packet."

### m7. "A repeated finding" is undefined

- Severity: minor. Tag: correctness. Location: plan:39.
- Defect: the term gates whether a proposal is made at all, so a vague reading either never proposes or always proposes.
- Fold: define it, for example as the same rule or tell in two consecutive months, or in three or more samples in one month.

### m8. A packet can't approve one proposal and reject another

- Severity: minor. Tag: optional. Location: plan:39.
- Defect: one Survey PR carries every proposal, one commit per change. A packet part is a PR, so Geoff's verdict covers all the proposals at once.
- OWNER FORK:
  - (a) Keep one PR. A reject's note names the proposals to drop, and the session reverts those commits and sends a new packet.
  - (b) Open one PR per proposal, which means more parts and possibly several releases a month.
  - Recommendation: (a), stated in the prompt.

### m9. "Cloned on both hosts" is satisfied only by a lazy clone that nothing checks

- Severity: minor. Tag: correctness. Location: plan:29, plan:51-55.
- Defect: the clone command isn't named. thinkpad-x1 also needs its `~/.dotfiles` pull and `stow -R claude` before it has v1.2.0, and no record says so.
- Fold: name the clone command (`gh repo clone glw907/survey-notes /var/home/glw907/Projects/survey-notes`). Add a STATUS line in the merge order: thinkpad-x1 takes v1.2.0 on its next pull and stow, and the first correction there clones the notes repo.

### m10. The push rule isn't live during the pass

- Severity: minor. Tag: correctness. Location: plan:15, plan:37, plan:44.
- Defect: the `permissions.allow` rule takes effect only after the workstation PR merges. Task 2's first push to `main` and task 3's baseline push run under the auto-mode classifier alone, and plan:66's standing answer covers only correction pushes.
- Fold: widen plan:66 to "any `survey-notes` push the pass makes." If a push is refused, the executor records it and the conductor pushes after the merge.

### m11. The merge-order check doesn't show that 1.2.0's content arrived

- Severity: minor. Tag: correctness. Location: plan:54.
- Defect: `/output-style` listing `writing-voice (current)` was Pass 2's check, and it passes on v1.1.0 too.
- Fold: also check that `grep -c Corrections ~/.claude/output-styles/writing-voice.md ~/.claude/skills/survey/SKILL.md` shows at least 1 in each file.

### m12. The notes README restates the correction format

- Severity: minor. Tag: optional (over-ceremony, small). Location: plan:37.
- Defect: the README states the file name, format, and monthly layout that the skill and the prompt already own. That gives the format two homes that will drift.
- Fold: have the README say what the repo holds and point to the `survey` skill's "Corrections" section and to `docs/model-review/writing-prompt.txt`.

### m13. The initiative record at close

- Severity: minor. Tag: optional. Location: plan:55.
- Defect: `initiative.yaml` `repos` lacks `survey` as well as `survey-notes`. Setting `status: done` closes the record while the design's step 4 adoptions (the approval queue, the phonebook, Bulwark, and 907.life) are still ahead.
- Fold: add both repos.
- OWNER FORK on status:
  - (a) Mark it `done`, with each adoption tracked under its own record.
  - (b) Keep it `active` until the adoptions land.
  - Recommendation: (a). The design scopes the initiative to three passes, and each adoption is "a pass of their own."

### m14. Two corrections on one host in the same second collide

- Severity: minor. Tag: optional. Location: plan:29.
- Fold: if the name exists, append `-2`.

### m15. The Vale criterion doesn't say which exit statuses count as a pass

- Severity: minor. Tag: optional. Location: plan:37.
- Fold: say "exits 0 or 1 (alerts), not 2 (a runtime or config error)."

### m16. The plan doesn't say which autoMode line clears each instruction edit

- Severity: minor. Tag: optional. Confidence: low. Location: plan:28-44.
- Defect: these edits are instruction text: the output-style paragraph, the skill's push-without-asking step, and the unattended prompt `docs/model-review/writing-prompt.txt`. `settings.json:352` clears only skill files under `claude/.claude/skills/` in a dotfiles worktree. Nothing names a clearance for the Survey worktree's `skills/survey/**` or for the dotfiles `docs/model-review/`.
- Fold: add a standing answer: if the classifier blocks one of these edits, record it and stop that task for the conductor.

## Coverage against the design's Pass 3

| Promise | Where | State |
| --- | --- | --- |
| Private `survey-notes`, one file per correction named by date, time, and host | Task 2, task 1 | Covered; behavior untested (M5) |
| Cloned on both hosts | Task 1 (lazy clone) | Partial (m9) |
| The skill writes before, after, context, and reason, then commits and pushes | Task 1 | Covered; untested (M5) |
| The output style names the step | Task 1 | Covered; criterion vacuous (m1) |
| Ships as v1.2.0 through `claude-tooling-sync update-skills survey` | Tasks 1 and 3, merge order | Covered (m11) |
| A monthly step on pavilion only | Task 3 launcher | Covered; launch path at risk (B1) |
| Ten fixed samples across the main kinds | Task 3 prompt | Covered (m3, m4) |
| Vale and `tellgrader` | Task 2 `.vale.ini`, task 3 | Covered |
| Compared with last month and the month's corrections | Task 3 report | Vacuous in test (M1); off by a month (M2) |
| Proposals with before-and-after examples, in one packet | Task 3 | Untested (M1); release steps incomplete (M3, M4) |
| An approved change is a Survey minor | Task 3 | Covered, given M3's fold |

Beyond the design: the "Releasing a change" section (needed by the monthly step), the `technical-doc-go.md:10` fix (deferred from survey#2 to "a 1.2 edit", confirmed in that PR body), and the `prompt.txt` sentence. Each is small and justified. Over-ceremony is limited to m12, which costs a few minutes and a future drift.
