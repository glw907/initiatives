# Survey Pass 3 plan: review fold

Target: `plans/2026-10-22-survey-pass-3-plan.md`, reviewed at initiatives `cdc5d99`, reviews at `02bbd1c`. Folded in place, uncommitted. Reviews: `research/2026-10-22-survey-pass-3-review-contract.md` (C), `-review-integrity.md` (I), `-review-mechanics.md` (M).

Path after the fold and the verification: 40 + 10 + 55 + 30 = 135 minutes, under the 150 stop. The design's 100 grows by the vendor fetch (already counted at 110), the separate launcher script and its systemd test (+10 on task 3), the release and correction acceptance checks (+5 on task 1), the close's `gitleaks git` scan (+5 on task 4), and the release section's clone and worktree steps from the verification (+5 on task 1).

Counts (reviews): 44 folded (convergent findings counted under each review, fixed once at the root), 2 refused, 2 owner forks (both ruled by Geoff, 2026-10-22), 16 `optional` findings dropped. C-M4 and I-10 moved from refused to folded after the verification's B1. The verification's own 12 findings are under "Verification".

## Probes run for the fold

- **A scope survives a oneshot's exit.** On pavilion, `systemd-run --user --wait -p Type=oneshot` ran two launchers. The control, `setsid nohup sleep 611 &`, was killed when the unit exited (no `sleep 611` afterwards). The fix, `systemd-run --user --scope --collect --unit=fold-probe-keep bash -c "setsid nohup sleep 612 &"`, left `sleep 612` alive in `/user.slice/user-1000.slice/user@1000.service/app.slice/fold-probe-keep.scope`, and `systemctl --user is-active fold-probe-keep.scope` printed `active`. Killing the child let the scope collect (`inactive`). Any process the `claude --bg` client spawns inside the scope, the supervisor included, lives there.
- **Background sessions don't prompt on reads outside the working directory.** The permission-modes doc: "The prompt doesn't appear in non-interactive `-p` runs or background sessions; reads there run as before."
- **Background sessions isolate themselves.** The agent-view doc: "When you dispatch a background session from agent view or start one with `claude --bg`, the session starts in your working directory. Before editing files, Claude moves the session into an isolated git worktree under `.claude/worktrees/`." It skips that when "The write is outside the working directory", so writes to `~/Projects/survey-notes` and the dotfiles worktree go where written. `~/.claude/settings.json` sets no `worktree.bgIsolation`.
- **A background session starts in the default mode.** The agent-view doc: "with `claude --bg`: the new session starts the way a new `claude` session in that directory would"; `~/.claude/settings.json:130` sets `"defaultMode": "auto"`.
- **Exact Bash rules.** The permissions doc: "A rule with no `*` matches one exact command"; `Bash(npm run build)` matches `npm run build` and not `npm run build --watch`.
- **`claude-tooling-sync apply` is the close step.** `~/.local/bin/claude-tooling-sync:7` ("~/.claude/settings.json is generated, not stowed"), `apply_settings` (:120-135) writes tracked keys over live ones. The `dotfiles-pass` close checklist: "`claude-tooling-sync apply` when it touched `claude/.claude/settings.json`" and "run one `gitleaks git` branch-history scan at close". Today's `verify` red is one `autoMode.allow` line: the tracked text from `42420d7` (2026-10-22 17:18, "Let an approval-queue approve clear any PR's merge") against the older live text (file written 13:55), so `apply` brings the live file current.
- **`fetch_skill` never prunes.** `claude-tooling-sync:396-421` runs `mkdir(exist_ok=True)` and writes each upstream file; nothing removes the rest.
- **`tellgrader` exit 0 is vacuous here.** `--help`: "0 when no finding gates ... Only trailing-hinge-run and appositive-stack gate, and only under the docs-register profile." Run on the two task-1 files today it exits 0 with findings in `writing-voice.md` (`contrast-frame` 2, among others), so the criterion compares counts against the pre-edit baseline instead of asking for zero.
- **`--add-dir` parsing** (not folded, kept for the record). commander 12.1.0 in a scratch probe: `--add-dir /a --add-dir /b "PROMPT"` swallows the prompt as a third directory; the `=` form does not.
- **`notify-send -u normal`** is the existing unattended hand-over signal (`docs/model-review/prompt.txt` step 7), so the new stale-PR and blocked-release lines reuse it.
- **The Survey worktree branch** follows `EnterWorktree`'s `worktree-<name>` pattern (`worktree-survey-pass-2` in `~/Projects/survey`), so the vendor fetch names `worktree-survey-pass-3`.

## Dispositions

### Contract review

- **C-B1** (blocker, the session dies with the oneshot): folded, the root of C-B1, I-1, and M-1. The launch moves into `bin/.local/bin/survey-writing-review`, which runs `claude --bg` inside `systemd-run --user --scope --collect` (probed above). The end-to-end test runs that script under `systemd-run --user --wait -p Type=oneshot` and asserts `claude agents --json` lists the session after the unit exits; the launch standing answer now covers a session that dies and names the first real run as attended. The separate script is the smallest unit the timer path can test without spending the model review; the `BASH_FUNC_claude%%` stub was refused as more machinery than a script. The no-daemon case is the probe's, since the executor's own supervisor is running during the test.
- **C-M1** (report criteria vacuous): folded in task 3, prompt step 3 (the report's shape) and the end-to-end accept (`grep -c '^## '` prints 13). Its fork was taken as (a), below.
- **C-M2** (month window): folded, the root of C-M2, I-4, and M-5. The folder and session keep the run month; the corrections read are every file no earlier `report.md` lists, so a failed month never drops one and no date arithmetic is needed.
- **C-M3** (release section incomplete): folded in task 1's "Releasing a change" and its `grep -c -E` accept.
- **C-M4** (main checkout): folded after the verification (V-B1, V-M2). The release runs from a fresh clone and the vendoring from its own dotfiles worktree, both named in "Releasing a change". The `-w` flag itself stays out, for the reason first given here: a `--bg` session moves itself into a worktree before editing (probe above), so `-w` adds nothing; its writes to survey-notes and the dotfiles worktree are outside the working directory and stay where written.
- **C-M5** (no correction test): folded as merge-order step 3 and the smoke-test standing answer.
- **C-M6** (tellgrader can't fail): folded in task 1's accept as a count against the pre-edit baseline, since the files already carry findings (probe above); zero would fail on day one.
- **C-m1**: folded (`grep -c 'Corrections'` prints 1).
- **C-m2**: folded (description trigger and `glw907` count).
- **C-m3**: folded (PR body grades as `commit`).
- **C-m4**: folded in task 3's accept, widened to named skills for the two samples M-16 gave a skill.
- **C-m5** (failed review skips the writing month): folded, the root of C-m5, I-9, and M-9; taken as (a), below.
- **C-m6**: folded (the writing session's own dry-run sentence).
- **C-m7**: folded (prompt step 5 defines a repeated finding).
- **C-m8**: dropped, `optional`.
- **C-m9** (clone command, thinkpad-x1): folded, with M-4, as task 1's clone command and merge-order step 4.
- **C-m10** (push rule not live during the pass): folded, the push standing answer now covers any push the pass makes.
- **C-m11**: folded in merge-order step 2's `grep -c Corrections`.
- **C-m12**: dropped, `optional`.
- **C-m13**: dropped, `optional`, its status fork with it; the plan's `status: done` follows the design's three-pass scope.
- **C-m14**: dropped, `optional`.
- **C-m15**: dropped, `optional`.
- **C-m16**: dropped, `optional`.

### Integrity review

- **I-1**: folded at C-B1.
- **I-2** (a session dies during the packet wait): folded in part. Prompt step 6 writes both PR numbers and the packet file into `report.md` and pushes before the wait, prompt step 1 has next month's run find open review PRs and notify, and a standing answer names the case. Refused in part: the `check-drift` report of PRs older than seven days is new machinery with no measured defect, and next month's step 1 already surfaces them.
- **I-3** (two runs collide): folded in part through prompt step 1 (no new proposals while last month's PRs are open), which covers the stale-session case. The three launcher guards were refused: `OnCalendar=monthly` with `Persistent=true` fires once per period, and a second same-month start is a person at the keyboard.
- **I-4**: folded at C-M2.
- **I-5** (correction text leaking to public repos): the correctness part folded as task 1's public-artifact rule (shared by prompt step 5) and the clone-or-write failure line. The content question is Ruling 1.
- **I-6** (push rule allows force push): folded as a planner action in Pre-flight. The exact rules match the commands the skill writes out.
- **I-7** (unpushed and diverged corrections): folded in part. The launcher runs `pull --rebase && push` on survey-notes and prints any refusal, and task 1 says a failed pull or push leaves the commit local and goes on. The `check-drift` ahead-of-origin line was refused as new machinery; the launcher's push on pavilion and the next correction's push on either host carry a stranded commit.
- **I-8**: folded (prompt step 4 commits and pushes the folder before any proposal work).
- **I-9**: folded at C-m5.
- **I-10** (primary checkout): folded with C-M4 after the verification; its side note folded as `report.md` naming the Survey commit Vale ran against.
- **I-11**: folded (vendor fetch step 3 removes the directory; step 5 is `diff -r`); the `fetch_skill` prune goes to "Later".
- **I-12**: folded as the tag-without-release standing answer.
- **I-13**: dropped, `optional`.
- **I-14**: dropped, `optional`; the same need is folded through C-m9.
- **I-15** (executor's worktree add fails): folded, the root of I-15 and M-6. The executor reuses the planner's worktree and checks `status -sb`.
- **I-16**: dropped, `optional`, its visibility-list fork with it.
- **I-over-ceremony, README format**: dropped, `optional`.
- **I-over-ceremony, end-to-end cost**: dropped, `optional`; the test now runs on the systemd path anyway.

### Mechanics review

- **M-1**: folded at C-B1.
- **M-2** (`--add-dir`): refused. The permission-modes doc says the outside-read prompt does not appear in background sessions (probe above).
- **M-3** (`claude-tooling-sync apply`): folded in merge-order step 2 and the thinkpad-x1 row; `verify` exits 0 is the check.
- **M-4**: folded with C-m9.
- **M-5**: folded at C-M2.
- **M-6**: folded at I-15.
- **M-7**: owner fork, Ruling 2. Its `-w` part was refused as C-M4; its fallback (c) is folded as the blocked-release standing answer, whichever way the ruling goes.
- **M-8** (repeated commands not written out): folded as the vendor fetch block, named once and reused, and task 1's commit and clone commands.
- **M-9**: folded at C-m5, with `--dry-run` skipping the new pulls as the script header says of the review's.
- **M-10** (`--permission-mode auto`): refused. A `--bg` session starts as a new session in that directory would, and `defaultMode` is `auto` (probe above).
- **M-11**: folded in the end-to-end test (the id from `claude agents --json`, the Monitor wait with a 40-minute timeout, `claude logs`, `claude stop`). A launched systemd unit doesn't print the id to the executor, hence `claude agents`.
- **M-12**: the tellgrader half folded at C-M6; the `readlink` half folded as a check inside `<dwt>`.
- **M-13** (STATUS.md dirties the release): folded as task 1's `.gitignore` line, which keeps `scripts/release:12` clean without moving STATUS.
- **M-14**: folded in task 4 (`gitleaks git`).
- **M-15**: folded (a failed pull or push stays local in task 1; the monthly session stages only its folder in prompt step 4).
- **M-16**: folded (`ts-conventions`, `go-conventions`).
- **M-17**: dropped, `optional`.
- **M-18**: folded (the 500-character cap in task 1's accept).
- **M-19**: dropped, `optional`.
- **M-20**: dropped, `optional`.
- **M-21**: dropped, `optional`; C-M5's smoke test covers the same ground.
- **M-22**: dropped, `optional`.

## Rulings

1. **Should a correction file's Context be trimmed to the surrounding sentence, and never hold a secret, a token, mail content, or a third party's personal data?** (I-5.) **Ruled yes (Geoff, 2026-10-22).** Before, After, and Reason stay verbatim, which is what the monthly review grades; the files sit in a private GitHub repo, a third-party store outside the "audience: Geoff only" list in `autoMode.environment`. Built: one rule line in task 1's `## Corrections` section and a `grep -c 'surrounding sentence'` criterion. The review's third option, skipping corrections made in private repos, was not offered: it drops a large share of the corrections the review exists to read. No settings rule is involved.
2. **Should this pass add an `autoMode` allow line letting the monthly writing session run `scripts/release` in `glw907/survey` after an `approval-queue packet` approve naming the Survey PR?** (M-7.) **Ruled no (Geoff, 2026-10-22).** The release path had two obstacles, and the verification (V-M3) noted the ruling was first framed on one. Worktree isolation, the one the session would certainly hit, is fixed without a rule: the release runs from a fresh clone (V-B1). The classifier's public-surface consent has no measured block, and the widened standing answer turns a real block, from either cause, into a notified, recorded stop that becomes the evidence. Built: nothing beyond that standing answer.

## Forks taken

- **C-M1's coverage fork: (a).** The comparison and corrections legs stay unexercised until 2026-11-01, with the report's shape asserted now. A fixture session (b) or a fixture-only run (c) is scope beyond the approved 100-minute design, and the legs are prompt text the November report shows.
- **C-m5's coupling fork: (a), run the writing review regardless.** The two reviews share only the timer, and the integrity and mechanics reviews flagged the same defect as correctness.
- **`claude-tooling-sync apply` rewriting the live `autoMode`.** It is the adapter's documented close step, and the only differing line is older than the tracked text Geoff committed in `42420d7`, so it isn't a new settings rule.

## Verification

Read: `research/2026-10-22-survey-pass-3-fold-verification.md` (1 blocker, 3 major, 8 minor: 5 correctness, 3 optional). Probes for this round:

- **A fresh clone satisfies `scripts/release`.** `gh repo clone glw907/survey` into the scratchpad gave branch `main`, an empty `git status --porcelain`, and `HEAD` equal to `origin/main` after a fetch, the checks at `scripts/release:10-13`. `npm ci` and `scripts/gate` then ran (`gate: ok`), and the tree stayed clean (`node_modules` is ignored). The probe stopped before tagging. The clone was removed afterwards.
- **Isolation doesn't reach the clone.** The worktrees doc, "How Claude Code enforces isolation": "The checks apply to the repository you launched Claude Code from. They also cover the main checkout a linked worktree is linked from." A fresh clone in a temporary directory is neither, and its path is verifiably outside the main checkout. `~/.dotfiles` is a different repository, so `git -C ~/.dotfiles worktree add` is outside the checks too.
- **A Monitor can't hold a packet wait.** The Monitor tool: "Every monitor expires after `timeout_ms` (default 5 minutes, at most 30 minutes): it is killed." A days-long `approval-queue packet` under a Monitor would be killed at expiry. The Pass 2 conductor's transcript shows its packet sent at 01:25 UTC and the release at 01:26, so it gives no evidence that a long background-Bash wait survives the idle stop either.

Dispositions:

- **V-B1** (isolation blocks the release from the main checkout): folded. "Releasing a change" and merge-order step 1 release from a fresh clone (`R=$(mktemp -d); gh repo clone glw907/survey "$R/survey"`, then `npm ci` and `scripts/release` there), and the `## Before merge` diff runs in `$R/survey`. The blocked-release standing answer now covers worktree isolation as well as the classifier. Chosen over `ExitWorktree` because it is probed, needs no claim about a background session's worktree state after exit, and leaves the main checkout untouched; the conductor still pulls `~/Projects/survey` after the release.
- **V-M1** (no PATH in the launcher): folded. The script exports `model-review-notify:10`'s PATH first; task 3's accept greps for it.
- **V-M2** (no dotfiles worktree for the monthly vendoring PR): folded. "Releasing a change" opens the workstation step with `git -C /var/home/glw907/.dotfiles fetch -q origin && git -C /var/home/glw907/.dotfiles worktree add .claude/worktrees/survey-<version> -b survey-<version> origin/main` and removes the worktree after the merge.
- **V-M3** (Ruling 2's premise): folded. Geoff has ruled no; Ruling 2 now names both obstacles, and the standing answer stays as the fallback.
- **V-m1** (prompt pushes not written out): folded in prompt steps 4 and 6.
- **V-m2** (`add <file>` against `corrections/<file>`): folded (`add corrections/<file>`).
- **V-m3** (heading count): folded. The report opens with a `# ` title and a plain `Survey commit:` line, and only the 13 sections use `## `.
- **V-m4** (idle stop during the packet wait): folded in part. The Monitor fix was refused: a monitor is killed at its expiry, which would end the wait it was meant to protect (probe above). The death standing answer now names the idle stop, and the workstation PR's `## Decisions` records it as untested until the first month with a proposal. Next month's step 1 still surfaces the open PRs.
- **V-m5**: dropped, `optional`.
- **V-m6** (audit failure and the review): folded. An audit failure skips the review, a review failure doesn't stop anything else, and the writing block runs in both cases.
- **V-m7**: dropped, `optional`.
- **V-m8**: dropped, `optional`.

Path: task 1 goes from 35 to 40 for the longer release section, so the path is 135.

