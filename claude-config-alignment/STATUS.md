# Status

## Current state

- Geoff set the scope on 2026-11-20: align the workstation's Claude configuration with
  Anthropic's docs and well-cited community practice, and decide the rest afterward. His words
  are in `specs/2026-11-20-process-decisions.md` under "Alignment comes first".
- The first part is live. The core design
  (`~/Projects/cc-desk/docs/specs/2026-11-20-core-design.md`) rewrote the global `CLAUDE.md`, the
  permission rules, the auto-mode entries, and the hook registrations. It merged as pull request
  255 in `glw907/workstation` on 2026-11-20.
- The process pieces are inventoried in `research/2026-11-20-process/`, nine reports.
- The rest is audited in `research/2026-11-20-workstation/`, four reports: the 13 personal skills
  outside the process, the `standards` plugin, the remaining configuration, and community
  practice. Each was scanned for secrets and personal details. Their findings are subagents'
  reports, and only a handful were checked against the files.
- Geoff approved this record as pull request 180 on 2026-11-20, and it is active.
- The alignment spec is written: `specs/2026-11-20-alignment-spec.md`, with three text files
  beside it that hold the new global `CLAUDE.md`, the new process skill, and its reference. Three
  subagents checked the audits against the files they name before the spec used them. A builder
  check and two readers with no context read the spec, and their findings are in it.
- Geoff approved the spec on 2026-11-21 ("Approved."). He changed no recommendation, so the six
  under "What Geoff decides" stand as written. The spec merged as pull request 181 here.
- The first task, "Groundwork", is done. It merged as pull request 256 in `glw907/workstation`
  on 2026-11-21, and the settings are live. The probe passed on all five points: a background
  session under `/goal` edited a skill file, committed, pushed, and opened a draft pull request
  with no prompt, and a command behind an `ask` rule was refused. The evidence is on pull
  request 256.
- The second task, "The process skill", is done. It merged as pull request 258 in
  `glw907/workstation` on 2026-11-21. The skill `building-from-specs` is live, and a fresh
  session lists it. Its build took 98 minutes against 70 planned, with five fix rounds. Its 24
  evaluation sessions took 398 seconds in all, a median of 15.3 seconds each.
- The third task, "The switch", is done. It merged as pull request 259 on 2026-11-21, and the
  new global `CLAUDE.md` and settings are live. A merge command now stops at a permission
  prompt that only Geoff answers, and a background session is refused one outright.
  `approval-queue land` is retired. `gh pr merge --help` ran in Geoff's session after a
  38-second wait at the prompt. One of 259's done items stays open until it can run: the next
  approved pull request stopping at the prompt.
- The build session made one call the spec didn't name. `claude-tooling-sync` caps a skill's
  description at 500 characters and now lets `building-from-specs` alone run to 1,536, because
  the approved text is longer than 500.
- The workstation gate failed on `main` on pavilion after pull request 260 named
  `~/.local/zen`, a path only thinkpad-x1 has. Commit `3a2fe1c` marks the two lines, and the
  gate passes again.
- The companion `specs/2026-11-20-alignment-global-file.txt` is one bullet behind the live
  global file. Pull request 260 reworded the browser bullet while 259 was open, and the merge
  kept 260's wording.
- Geoff ruled on 2026-11-21: "Pull requests are all pre-approved." His session reads that as
  the pull requests of this spec's tasks, and each merge still stops at his permission prompt.
- "The plugin" is done. Pull request 22 in `glw907/standards` merged as `61f996a` on
  2026-11-21 with seven of its eight done items met. The sixth is unmet: `claude plugin eval
  plugins/standards` exits 1, because the `ts-conventions` case already on `main` fails two runs
  of three and one `brainstorming` run in three asks a compound question. The merge waited
  about 16 seconds at Geoff's prompt, which closes the open item on pull request 259. The
  user-scope plugin is at `61f996aa3eb3`, and a fresh session lists a description for each of
  the four `vale-*` skills with no budget warning in its debug log. The session and its
  branches are removed.
- Geoff asked on 2026-11-21 for the follow-up to be planned: "look at current online and
  anthropic success patterns. Brainstorming is especially critical, so we'll need to know what
  works best with the current models, and aligns will with our local development patterns."
  The research is done and saved in `research/2026-11-21-brainstorming-followup/`. Its
  `README.md` is the short form. Four Sonnet researchers read Anthropic's pages, the upstream
  skill, and other published interview patterns, a second agent refetched every source, and
  one Opus reader compared the local skill with local practice. A second Opus reader then read
  Geoff's typed messages in 41 past brainstorming sessions (`past-sessions.md`), and Geoff's
  session ran five trials of the evaluation command (`evaluation-trials.md`).
- The follow-up spec is written at `specs/2026-11-21-brainstorming-spec.md`, with three files
  beside it: the new skill text, the script that writes the test cases, and a check for the
  mock-up page. On Fable 5.2 the rewrite passed all 17 cases in two full runs. The current
  skill passed 4 of the 13 brainstorming cases, and so did a session with no plugin. Three
  fresh readers checked the spec in two rounds, and their findings are in it. A background
  session in auto mode then ran the 13 brainstorming cases on the final text, and all 13
  passed.
- Geoff approved the follow-up spec on 2026-11-21 ("Approved."). He changed no recommendation,
  so the three under "What Geoff decides" stand: the skill and tests aim at his four
  corrections, a brainstorm does a few outside lookups before the approaches, and the task may
  start four full suite runs.
- The follow-up's build task, "The brainstorming skill and its tests", is done. Pull request 23
  in `glw907/standards` merged as `b6dbe0d` on 2026-11-22 with all 14 goal items met and a green
  `validate` check. Its review returned accept with three optional notes, which the pull
  request lists under `## For Geoff`. The session took 70 minutes against 164 planned, and the
  suite passed twice in a row, 17 of 17 cases each time, for about 27 dollars a run. The
  session, its worktree, and its branches are removed.
- The brainstorming spec's four workstation edits are commit `de25be6` in `glw907/workstation`.
  Their done items are posted on pull request 23. The user-scope plugin is at `b6dbe0db3b70`, a
  fresh session lists the new description for `standards:brainstorming`, and the mock-up
  server's screen shows "Connected" in its header and no logo.
- The plugin's session met a new stop. The `/goal` checker answered "not met" 11 times in about
  two minutes over the item marked unmet, then marked the goal failed, and the session sat
  blocked on a question nobody was reading. Geoff's session stopped it. The row is in cc-desk's
  lessons file, commit `c353960`.
- "Survey" is done. Pull request 13 in `glw907/survey` merged as `30cd337` on 2026-11-21 with
  all six done items met, reviewed with an accept and no blocking finding. It took 71 minutes
  against 70 planned. The session and its branches are removed.
- Survey 2.0.0 is released, tagged at `885adb1`. Geoff's session chose the version by the
  changelog's rule that a removed rule is a major, because the release removes
  `writing/approval-brief.md`. The workstation still vendors `v1.7.0` until the last task.
- "Configuration cleanup" is done. Pull request 262 in `glw907/workstation` merged as `9796bf9`
  on 2026-11-21, reviewed with an accept and no open finding. It took 11 minutes against 125
  planned. Both after-merge checks are posted on the pull request: a `.yml` under `styles/`
  loads the Vale rule and a `.css` file loads none, and a task-shaped request calls the
  `bluefin-admin` skill. A plain question about a doc was answered by search without the skill.
  Commit `1773529` drops the retired instructions folder from one auto-mode allow entry, and
  `claude-tooling-sync verify` passes. The session and its branches are removed.
- "Personal skills" is done. Pull request 263 in `glw907/workstation` merged as `7c1022a` on
  2026-11-21 under Geoff's ruling that pull requests are pre-approved. Its review returned
  escalate with one blocking finding and nine others, and Geoff has the blocking one as a
  question: the `paths:` key on `vps-conventions` keeps that skill out of the list until a
  session opens a matching file. The checkout is pulled and restowed, `claude-tooling-sync
  verify` passes, and the after-merge checks are posted on the pull request. The worktree and
  both branches are removed.
- That task's session is removed. `claude rm 1ba4a94a` failed while the background service
  was down and worked once the next background launch had started it. The row is in cc-desk's
  lessons file, commit `8d29338`.
- Commit `f37b3b9` in `glw907/workstation` fixes the one line of the old process that pull
  request 263 left in `claude-infra`: work beyond the request goes to the backlog through
  `standards:log-issue`.
- "Memory stores" is done. Geoff kept three of the 11 files in the `/home` store, and they are
  in the `/var/home` store, whose index has 20 lines for 20 files. Commit `39f36df` in
  `glw907/workstation` adds `cd -P .` to the `claude` function, and the gate passed before it.
  The `/home` store's folder is gone. A print-mode session started from `/home/glw907` and one
  from `/var/home/glw907` each named `~/.claude/projects/-var-home-glw907/memory/`. The search
  for the retired words over the store prints nothing.
- Geoff ruled on 2026-11-21 to drop the `paths:` key from `vps-conventions` ("you can drop the
  vps-conventions"). Commit `7f5cbdf` in `glw907/workstation` removes its four lines, and the
  skill is back in a session's list. That closes the blocking finding on pull request 263.
- The `~/.dotfiles` main checkout is level with `origin/main` at `ac87235`, and the gate
  passes on that commit. The busy check exits 0 there. Two uncommitted files from another
  session are still there: `google-workspace.md` under `claude/.claude/docs/bluefin-admin/` and
  `bin/.local/bin/sheet-revision`.
- Geoff kept two of the four habits pull request 262 listed ("The first two.", 2026-11-21):
  source `~/.local/secrets` in the same command, and give `wrangler secret put` a `--name`.
  Commit `ea609c0` in `glw907/workstation` adds them to the global file's "Secrets" section,
  because a section of their own put the file over its 120-line cap. The companion
  `specs/2026-11-20-alignment-global-file.txt` is a record of the switch and lacks them.
- The workstation gate failed once on `tests/test_cleanroom_live.py`, in
  `test_a_run_past_cap_min_ends_as_stopped_time`, and passed on the next run with no change to
  the test. Two evaluation runs were going at the time. It is item 112 in the workstation
  backlog, commit `0c1cf61`.
- "Retiring the old process" is done, and with it every task of the alignment spec. Its first
  pull request, 264 in `glw907/workstation`, merged as `4fa6f48` on 2026-11-22. The build
  session ran on Opus at high effort and took 38 minutes against 160 planned. The reviewer
  returned fix on `1f00abe` and accept on `33f7c79`. The three after-merge items are posted on
  the pull request: `task-report --help` runs, no link in `~/.local/bin` dangles, and a fresh
  session in `~/Projects/cairn-cms` called `cairn-pass` and `building-from-specs`.
- Pull request 264 leaves two notes for Geoff. `cairn-pass` doesn't name the cairn-cms process
  skill, because that skill's name holds a retired word. The weekly usage check sits only in
  `unattended-work-guards.md` and not in `building-from-specs` "Launching a task". It also
  filed workstation backlog item 113, a Vale config line that names a deleted skill.
- The second pull request is 265 in `glw907/workstation`, merged as `edae735` on 2026-11-22.
  Geoff's session built it as six commits. A fresh `standards:diff-reviewer` returned accept
  with no blocking finding, and the gate exited 0 on its last commit, `ae19668`. The `cc-desk`
  and `cc-desk-work` skills are gone, the survey skill is at 2.0.0, the gate fails on any of
  the ten retired words, and the `PreToolUse` hooks name `claude-git-guard`.
- The settings are applied. `claude-tooling-sync apply` changed one line of the live
  `settings.json`, the hook's command, and `verify` exits 0. Commit `ac87235` then removes
  `claude-merge-guard` and its test. It also drops the script's name from the gate's `pytest`
  path pattern and from the `dotfiles-pass` skill, and three open backlog items now name
  `claude-git-guard`. All six done items hold on `ac87235`, and the evidence is posted on pull
  request 265. The worktree and the branches are removed.
- One change in pull request 265 is outside the spec's table. Survey 2.0.0's description is
  515 characters, over the lint's 500, and `claude-tooling-sync` now lets it run to 1,536,
  because that text is what the survey evaluations tested. The reviewer read it as correct.
- The workstation repo runs no CI on pull requests, so a pull request there shows no checks.
  The gate on the branch's last commit is the only full run.
- Geoff ruled late on 2026-11-21: "Unless there are major issues, you can do all the merges."
  The three merges of 2026-11-22 ran under it, and each stopped at his permission prompt.
- Weekly usage is 62 percent for all models and 97 percent for Fable at 16:51 on 2026-11-22,
  near the end of task 2. It was 56 and 85 at 15:39, 48 and 70 at 14:35, and 43 and 63 at
  12:26. The week
  resets on Nov 27 at 11pm Anchorage.
  `claude -p "/usage" --model haiku < /dev/null` prints both figures.

## Next action

Every task of the alignment spec and of the brainstorming spec has merged. The launch prompt
`plans/2026-11-21-side-by-side-prompt.txt` is finished, and no task session is running.

Geoff approved the spec for the spec-writing test on 2026-11-22. Asked whether the spend is
all right (about 110 dollars planned, 170 at most), he typed: "The spend is OK. Continue." His
session reads those words as his approval of the spec, since the spend was the one question
the spec left him. The spec is `specs/2026-11-22-spec-writing-test-spec.md`, and its trial runs
are in `research/2026-11-22-spec-writing-test/`. Nothing is built.

Geoff ruled on length the same day: "I'll go with Anthropic's guidance on the subject."
Anthropic's pages and four community sources give no number and size a spec by its change. The
spec matches: the guide's length rule states no number, and the test keeps 1,200 words as its
pass mark. The sources are in the spec under "How long a spec may be".

The launch prompt `plans/2026-11-22-spec-writing-evaluation-prompt.txt` is finished. Geoff's
session worked from `plans/2026-11-22-spec-writing-test-build-prompt.txt` until he asked it to
get ready to be cleared. The close-out prompt `plans/2026-11-22-close-out-prompt.txt` is
finished: its five steps are done, and no session it launched is running.

The checks under the spec's "Before launch" pass on 2026-11-22. `claude-worktree-busy
~/.dotfiles` exits 0, and the session `dotfiles-5e` has ended. Its three uncommitted files are
still in that checkout and stay untouched. The two backlog edits that approval covers are
landed in the workstation repo as commit `e81bf69`: item 113 carries a stamp and item 94 is
under Done.

Task 1 is done. Pull request 266 in `glw907/workstation`, "Add the spec-writing test and record
its first baseline", merged as `05a1ec6` on 2026-11-22 after Geoff typed "merge 266, and launch
task 2." The build session ran on Opus at `high` (his ruling: "Keep it on Opus."), started at
12:29, and finished at 14:25 with its goal met. The checkout is pulled, `claude-tooling-sync
verify` exits 0, no link under `~/.claude/skills` or `~/.local/bin` dangles, and the session,
its worktree, and both branches are removed.

- The baseline ran all 16 cases on Fable at `high`, and each ended `finished`. All 16 trap
  checks passed. All six writing cases failed the length check, with specs of 3,671 to 4,285
  words against the pass mark of 1,200. The folder is
  `claude/.claude/skills/building-from-specs/evals/results/2026-11-22/spec-writing-baseline/`.
- A fresh `standards:diff-reviewer` on Opus at `high` escalated on the first read, and a third
  read of the whole branch accepted the last commit, `456f9a9`, with no blocking finding.
- The test sessions spent 37.04 of the 40 dollars.
- The pull request asked whether to pay about 34 dollars for a new baseline that fixes the
  grading gaps in workstation backlog item 114 before task 2. Both sessions recommended no,
  and Geoff's words launch task 2 on the test as it stands. Item 114 lands with the next full
  run after task 2.
- The pull request changed two files outside task 1's list: `scripts/check.sh` (one
  `shellcheck` exclusion for the 16 proof scripts) and `BACKLOG.md` (item 114).

Task 2 is done. Pull request 267 in `glw907/workstation`, "The spec guide carries a length rule,
and the six length checks still fail", merged as `9dd4f13` on 2026-11-22 after Geoff typed
"approved, 267". It was marked ready at 17:04 on commit `4a6836e`. The session `spec-writing-test-2` (id `7247711a`) ran
on Opus at `high` from 14:36, and its test sessions on Fable at `high` spent 110.10 of the 130
dollars.

- The guide's length rule is the spec's text 1 reworded twice, and the pull request quotes it.
  The specs shrank from 3,671 to 4,285 words in the baseline to 1,719 to 2,199 in the final
  pair, still over the 1,200 mark.
- The summary of both final runs prints 32 rows with guide hash `3a6fd5d`, which matches `git
  hash-object` of the guide, and exits 1. All 12 length checks fail, and four reader trap
  checks fail: `read-uncovered-edge` in both runs, `read-missing-file` and `read-wrong-path` in
  run 2. Every writing case's trap, nothing-built, and guide-read checks pass. Done item 1 is
  unmet, which the spec allows.
- The reviewer returned fix on `2fff338` and accept on `4a6836e`, with no finding open. The
  gate exits 0, and gitleaks finds no leak in the branch's 8 commits.
- `claude-tooling-sync verify` exits 1 on one key: the live `model` is `opus` and the tracked
  one is `fable`. The live file changed at 15:50:42, four seconds after the session
  `initiatives-16` started. Geoff ruled on 2026-11-22: "Opus is fine for this." Pull request
  268 makes the tracked default `opus`.
- The session ended `blocked`. The `/goal` checker refused its stop four times on done item 1,
  the stop of 2026-11-21 returning. The auto-mode classifier refused `claude stop 7247711a`
  twice, and it ran once Geoff gave the go-ahead. The row is in cc-desk's lessons file, commit
  `68a6dfc`.
- After the merge the checkout is pulled, and `claude rm` removed the session, its worktree,
  and its local branch. GitHub had already deleted the remote branch. The merge added no
  script or skill and changed no setting, so nothing was restowed or applied. No link under
  `~/.local/bin` or `~/.claude/skills` dangles, and `claude-tooling-sync verify` fails only on
  the `model` key.
- `/skill-doctor` lists 77 skills. Never used: the 17 `cloudflare` skills, the five that pull
  request 24 removes, `go-ship` (removed by pull request 28 in standards, after Geoff said
  "Remove go-ship." on 2026-11-22, merged as `5f18621` after "approved, 28"), `content-draft`, `cairn-figure`, and 10 skills synced from
  claude.ai, which it suggests turning off in `/skills` or on claude.ai. Geoff hasn't ruled on
  those 10.

The monthly review rework is item 115 in the workstation backlog, commit `e8d9035`. Geoff
asked for it on 2026-11-22: "Probably we should do a broader consideration of the monthly
review process in light of the process changes, complete with research into best practice."
The work is a spec of its own, written after task 2 has merged, so that the review is designed
around the test as built. It runs monthly: Geoff answered on 2026-11-22, "I assume the
monthly review should run ... monthly?" The item records it in workstation commit `734d57c`.

The work after task 2 is the reshape of cairn-cms and dubplate to the workstation's process,
which this record lists as a non-goal. Geoff ruled on 2026-11-22 that it comes before the
monthly review rework ("The reshape first.") and agreed to how it runs ("Perfect."): a new
initiative record, steered from the initiatives repo by a fresh session with a launch prompt,
with each task launched from its repo's main checkout, and dubplate first. He added on
2026-11-22 who plans and who builds: "Note for the reshap for for cairn and dubplate, I'd
like a Fable planning effort. I can execute with something lighter." So the launch prompt
puts the audit and each spec on Fable, and each task's build on a lighter model. He then said
to start the planning without waiting for task 2: "Once you're done you can prep to clear, and
we'll get started on the cairn and dubplate planning. Should I run those as two separate
efforts, or together?" Claude answered: one planning effort with one audit of both repos,
then a spec and a build for each, dubplate first. The record is `cairn-dubplate-reshape/`.
Geoff approved it as pull request 182 in `glw907/initiatives` ("Approved."), it merged as
`369afb2`, and the record is active. Its launch prompt is
`cairn-dubplate-reshape/plans/2026-11-22-planning-prompt.txt`. Fable read 85 percent of the week at 15:39, so Claude proposed a split: the
audit of both repos on Opus as soon as pavilion has a free slot, and the two specs on Fable
after the reset on Nov 27. Geoff answered: "Split is fine." The launch prompt says which
steps each session does. He also asked whether any Anthropic or community skill is missing for
those two projects. The reshape's audit answers that with a trial for each candidate. The
candidates from the official marketplace are `security-guidance` and `claude-security` for
the sign-in, data, and upload code, and `claude-code-setup` and `claude-md-management` as
one-time second readers of each repo's Claude files.

Geoff then asked which skills to remove, and on 2026-11-22 he gave the go-ahead: "You can
clean up skills while we wait on task 2." and "Add new useful skills, and remove skills that
we don't need." The evidence is a count of `Skill` calls in the 7,485 session transcripts of
the 30 days to 2026-11-22. The work has two parts.

The first part is pull request 24 in `glw907/standards`, merged as `01c86da` on 2026-11-22
after task 2's session ended. Asked "Do you approve pull request 24?", Geoff answered on
2026-11-22: "Approved, and take a closer look at the content-draft issue and propose a
solution." `~/Projects/standards` is pulled, and the worktree and both branches are removed.
The user-scope plugin is updated with the second part. It removes `vale-ci`, `vale-fix`, `vale-triage`, `vale-vocab`, and `svelte-check`,
none of which was called, and adds `svelte-core-bestpractices` from `sveltejs/ai-tools` at
commit `f9d22f2f7f7c` (MIT), because the plugin has no skill for writing Svelte code. Its CI
check passes on the last commit, `0cfaf11`, and a fresh `standards:diff-reviewer` accepted
that commit with no blocking finding. `vale-setup` stays with its one call, `content-review` stays as the check `content-draft`
hands off to, and `cairn-figure` is the reshape's.

The second part is pull request 268 in `glw907/workstation`, "The skill lists match the
standards plugin, and only Cloudflare's docs server remains", merged as `77c686c` on
2026-11-22 after Geoff typed "approved, 26, 268, 27". A fresh `standards:diff-reviewer` on
Opus at `high` accepted `e0dc05f` with no blocking finding. One wording commit came after the
review, `298a386`, which has the laptop's setup list uninstall the `cloudflare` plugin. The
gate exits 0 on it and gitleaks finds no leak. After the merge the checkout is pulled, the
worktree and branch are removed, the standards plugin is updated to `6c089e0`, and
`claude-tooling-sync apply` added the `cloudflare-docs` server. `claude-tooling-sync verify`
exits 0, `claude mcp get cloudflare-docs` reports it connected, and the `cloudflare` plugin is
uninstalled on pavilion. The Cloudflare OAuth grant may still be listed in the dashboard. The
pull request drops the four Vale entries from `vendored-skills.json`, adds the Svelte entry, fixes
`rules/vale.md` and `claude-tooling.md`, and removes the `cloudflare` plugin. That plugin
lists 18 skills and none was called, but its documentation server was called 17 times, so
a docs-only server moves to `mcp-servers.json` at user scope. A count of real calls finds
17 to the plugin's `docs` tool and none to `execute` or `search`, so the new entry is
Cloudflare's docs server, `docs.mcp.cloudflare.com`, which needs no sign-in. The same pull
request has `site-pass` run `content-review` from the task session, and defines `$E` in the
two eval READMEs, where `run_evals` paths did not resolve.

The review found that `vale-setup` still offers Vale's `fix` and `triage` skills at
`SKILL.md:11-12` and `:67`, which pull request 24 removed. It is item 2 in the standards
backlog, landed through pull request 27 there, merged as `6c089e0`, because standards `main`
takes pull requests only.

Three community skills are passed over for now. `svelte-code-writer`, read in full, runs
`npx @sveltejs/mcp` with no pinned version. `golang-security` and `golang-database` from
`samber/cc-skills-golang` fit dubplate, so the reshape reads and weighs them. The first
opens by telling its reader to fan out five subagents, which the workstation's rules don't
allow without Geoff's word. In the two project repos, `cairn-running-passes` and
`dubplate-pass` are the reshape's to replace or shrink.

Geoff also asked what he should use to write good Go. Dubplate's gate and CI lack three
checks that <https://go.dev/doc/security/best-practices> recommends: `go test -race`,
`govulncheck`, and a fuzz test for its upload and audio parsers. A search of its `Makefile`,
`scripts/check.sh`, and `.github/workflows/check.yml` on 2026-11-22 finds none. The reshape's
audit of dubplate weighs adding each. `govulncheck` is not installed on pavilion.

The count of 73 `content-draft` calls and no `content-review` call does not show site content
drafted without its check. Every one of the 73 comes from one prompt in the test for cairn's
docs skill, "Write the homepage copy for the new about section on 907.life.", which checks
that the docs skill stays out. No site has a content commit since 2026-08-22. The closer look
on 2026-11-22 still finds three weak points:

- `content-draft` ends by offering the check. In 64 of the 73 test sessions the offer was the
  last thing said, and nobody was there to accept it.
- `content-review` runs `vale <file>` for banned words. No site has a `.vale.ini`, and none
  ever had one, so Vale reads no file: in ecxc-ski it prints "0 errors, 0 warnings and 0
  suggestions in 0 files" and exits 0. The only Vale styles on pavilion are Google and
  Microsoft.
- `site-pass` names `standards:content-review` for `src/content/**`, but the task reviewer,
  `standards:diff-reviewer`, has no Skill tool and no web search, and the check asks for both.

ecxc-ski's `.claude/rules/content.md` also points at `~/.claude/docs/web-content-method.md`
and `prose-guard`, and neither exists. Only ecxc-ski has a `docs/content-guide.md`.

Claude proposed four fixes and asked "Do you want all four, with a spec for item 3?" Geoff
answered on 2026-11-22: "Yes." Nothing is built. The spec for items 1 and 3 is written at
`specs/2026-11-22-content-check-spec.md`, with its trial files in
`research/2026-11-22-content-check/`. A fresh reader checked it and Claude fixed what it
found. The worst finding was that pavilion's Vale config in the home folder could add file
types and accepted words to the check, so the script now runs Vale with `--no-global`. Geoff
approved it on 2026-11-22: "approved".

The three checks under its "Before launch" pass on 2026-11-22. Pull request 24 has merged, one
other session was working, and the week read 62 percent for all models. In the trial, a clone
at `01c86da` with the trial files and the skill's new step 2, a Sonnet session called
`content-vale.sh` at its full path under the clone, and its transcript shows `11 errors, 1
warning and 0 suggestions in 1 file.` The task `content-check` is done. Its pull request, 26 in
`glw907/standards`, "content-review ships a banned-word Vale style, and content-draft runs it",
was marked ready at 17:22 on commit `0188d12` and merged as `5271225` after Geoff typed
"approved, 26, 268, 27". `claude rm` removed its session, worktree, and branch. The session launched at 17:16 from
`~/Projects/standards` (id `41356b88`), on Opus at `high`, and Geoff's session stopped it after
its report. Every goal item is met, the `validate` check passes, and a fresh
`standards:diff-reviewer` accepted with no open finding. On a fresh clone, Geoff's session
reran the style test, the three counts in item 3, and the `pivotal` change, and each matched. Its goal lists the
six done items and the eight commands word for word, and ends "or stop after 90 minutes". It
also counts as met when the pull request is ready and lists each unmet item, the change cc-desk's
lessons file calls for.

1. `content-draft` runs `content-review` on the file it drafted and reports the result, in
   place of offering to. This is in the `standards` plugin and joins item 3's spec, because
   it changes what a skill does.
2. `site-pass` has the task session run `content-review` on each changed content file before
   its pull request is ready, and quote the result there. The reviewer agent stays as it is.
   This joins the workstation pull request that waits for task 2.
3. The plugin ships a small Vale style built from the method's banned-word list.
   `content-review` runs Vale with that config and fails when Vale reads no file, so no site
   needs a Vale config. This one gets a short spec, and Geoff approves it before any launch.
4. ecxc-ski's content rule loses its dead pointers. It lands directly after item 3 merges.

All four are done. Item 4 landed in ecxc-ski as commit `05281c6`, which also rewords backlog
item 27 there. The same stale pointers remain in ecxc-ski's `docs/content-guide.md`, at lines
5, 16, 253, and 258 to 259, and they are its backlog item 43.

A draft of the style, run on 2026-11-22 over all 111 content files in the four sites, flags
26 places: 21 in aksailingclub-org, 5 in 907-life, and none in ecxc-ski or cairn-pub. The
method's two samples come out as it says they should, the clean one with no finding and the
other with 11 errors and 1 warning.

He also has the notes the last three pull requests left, listed under "Open decisions".

## Open decisions

- The rulings file owes Geoff one question about where cc-desk's scheduled check-ins come
  against the rewrite of Move. It is about later work and is not asked until that work starts.
- The parked questions are listed in the rulings file under "Parked until the workstation is
  aligned". None is asked until a spec needs its answer.
- Geoff ruled on 2026-11-21 that spec writing is tested after the workstation is aligned:
  "Let's follow best practices and test once we have the environment fully set up." The
  environment is now set up, and on 2026-11-22 he said to go ahead. He approved the spec for
  that test the same day.
- Geoff ruled on 2026-11-22, while the spec was designed: the test covers the written spec
  and leaves out the design conversation; specs are written on Fable at `high` ("Let's go with
  the Anthropic recomendation."); no run compares against a session with no guide; and a long
  spec for a small change is a failure ("Yes, that's too long for a small change").
- Pull request 23 left three optional review notes. `.gitignore:4` matches session files only
  at the top of a case folder, `scripts/run-evals.sh` works only from the repo root, and
  `BACKLOG.md` lost its `## Low` heading.
- Pull request 264's two notes and pull request 265's description limit for the survey skill
  are under "Current state". Each stands unless Geoff objects.
- Geoff asked on 2026-11-21 for Chromium to be trimmed to what development work needs. It is
  item 109 in the workstation backlog and is no part of this spec.
- The `claude auto-mode critique` of the first settings change said the entry for build
  sessions doesn't say what shows that Geoff approved a spec. Geoff hasn't ruled on it. The
  critique run after the switch returned no feedback, twice.
- Pull request 13 left two things for a later look: `DESIGN.md` in `glw907/survey` still says
  "the approval queue" in four places (its backlog item 10), and the survey skill's description
  ends on a clause that addresses Claude.
- "The plugin" added `BACKLOG.md` and `.claude/project-tracking.json` to the public `standards`
  repo, outside its task's table. They stay unless Geoff objects.
