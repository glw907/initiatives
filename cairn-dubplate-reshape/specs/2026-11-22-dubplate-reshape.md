# Spec: move `dubplate` onto `building-from-specs`

Status: draft for Geoff's approval (2026-11-22). The repo is `glw907/dubplate`, default branch `master`,
read at `907605c`.

Three tasks and two hand-overs move `dubplate` onto the workstation's process. The first task fixes the
shutdown race in `internal/serve`. The second rewrites the repo's Claude files and backlog so they name no
process but `building-from-specs`. The third adds `govulncheck`, three fuzz targets, the race detector in
CI, and a `dependabot.yml`. Geoff's session turns on GitHub's secret scanning, push protection, and
Dependabot alerts, and keeps `docs/STATUS.md`. Nothing a member or an operator sees changes.

## Intent

Geoff asked, on 2026-11-22: "does it make sence to start a project to reshape the cairn and dubplate
efforts to fit the workstation claude tooling?" The initiative record states success: "a task in either
repo launches, builds, and merges by that skill and the repo's short facts file, with no process text of
the repo's own in the way." He set the planning split: "I'd like a Fable planning effort. I can execute
with something lighter." He then ruled on models for this spec: "Perfect. Let's plan for that." (Opus at
high writes this spec and an Opus fresh reader checks it.)

His rulings this spec carries, quoted in the initiative's `STATUS.md`:

- "That matches." (2026-11-22). No automated security review now. GitHub's secret scanning, push
  protection, and Dependabot alerts go on, and `dubplate` gains a `dependabot.yml`. `claude-security`
  runs once on `dubplate` after the week resets, before any release that people outside the house sign
  in to. That run is outside this spec.
- The `internal/serve` shutdown fix lands before `-race` joins CI.

Goals:

- `CLAUDE.md` and `.claude/` name no process but `building-from-specs`, and `CLAUDE.md` is under 200
  lines, with the web and Python stack rules moved to rules that load only for their paths.
- One repo skill holds the facts a task session needs: gate, fast lane, worktree setup, CI watch, risk
  map, reviewers, and the coding conventions.
- The gate gains `govulncheck` and fuzz seeds, and CI gains the race detector and a timed fuzz run on
  each pull request that touches fuzzed code.
- BACKLOG carries the sweep's verdicts and the restart of the paused `structure` work as an item.

Non-goals: product work, the paused `structure` work itself, the plans in
`~/Projects/initiatives/dubplate-server/`, the workstation's process files, and the `claude-security`
run.

The work fails if a task session meets a refusal it can't route around, if any task changes what the
server does beyond the shutdown fix, if a pull request merges with a red check, or if the `structure`
work resumes under the old process.

## What happens when it goes wrong

- A refused `CLAUDE.md` commit. The 30-day denials log shows `[Undermining Oversight]` refusing a commit
  of a `.claude/CLAUDE.md` in another repo's worktree, and the probe didn't cover `CLAUDE.md`. Task 2
  then puts the whole new `CLAUDE.md` in its pull request under `## Before merge`, marks done item 4
  unmet, and finishes the rest. Geoff's session applies the text before the merge.
- A refused skill-folder rename. Task 2 writes the new skill beside the old one and puts
  `git rm -r .claude/skills/dubplate-pass` under `## Before merge`.
- A new Go advisory. Once task 3 lands, a vulnerability published against a module `dubplate` calls
  turns `govulncheck` red on every pull request until a dependency moves. That is the leg doing its job.
  The next session takes the bump through `standards:dependency-upgrade` as its first task.
- A fuzz crash. On a pull request, the `fuzz` check goes red and the crashing input is uploaded as an
  artifact. The session that owns the pull request fixes the traced cause, and the input joins the seed
  corpus under `testdata/fuzz`.
- A race found by the new CI step in a test outside this work. Task 3 fixes #133 or #143 if either
  fails. Any other failure goes to the backlog through `standards:log-issue`, and task 3 leaves its
  pull request in draft with the failure named, since a red check never goes ready.
- The race step's time. It adds about nine minutes or more to every pull request's CI wait. Its limit
  is the job's 75 minutes.

## What idles, and how the paused work restarts

The `structure` round stays paused, as Geoff asked on 2026-11-20. Its resume prompt in
`dubplate-server/plans/2026-11-17-structure/` stays untouched. Hand-over 1 removes the `docs/STATUS.md`
pointer to it, so no session resumes it under the old process. Task 2 files one BACKLOG item to restart
it: write a spec under `building-from-specs` for the third piece, `structure-doctor`, scoped from
`structure-doctor-planner-prompt.txt`, carrying items #123, #124, #143, #144, #147, and #156. No other
`dubplate` session runs while these tasks run. cc-desk has never acted on `dubplate`
(`research/2026-11-22-spec-inputs/desk.md`).

## Approaches

For the old skill, the audit weighed a workstation skill against a repo skill. The repo skill wins:
`claude-tooling.md` says a skill lives in "the repo when only that repo needs it, since committed files
reach cloud sessions." The new skill is `.claude/skills/dubplate-build/`, a name with no retired word.

For the race detector, three places were weighed. Adding `-race` to `make test` puts a run of over ten
minutes in every local gate. A second CI job repeats the setup of `rclone`, `libxml2`, Chromium, the wheel,
and the XSD. A step after the gate in the existing job reuses that setup and leaves the local gate as it
is. The pick is the step, through a new `make test-race` target.

For the timed fuzz run, a `make` target alone runs only when someone remembers it. A weekly schedule
runs with nobody watching, and its failure sends Geoff an email between sittings, against his calm
desktop rule. The pick is a new workflow, `.github/workflows/fuzz.yml`, on any pull request that touches
a fuzz target or a fuzzed package, plus a longer `make fuzz` run in each milestone's first task, beside
the dependency sweep. The pull request trigger also matters because the task session can't start a
workflow by hand: auto mode refused `gh workflow run` as "[Auto-Mode Bypass]" in the denials log.

For `govulncheck`, two installs were weighed. A `go install` at a pinned version in CI leaves the
local gate on whatever binary the host has: pavilion's comes from Homebrew, and the `Brewfile` doesn't
list it. A `tool golang.org/x/vuln/cmd/govulncheck` line in `go.mod`, run as `go tool govulncheck`,
pins one version for every host and for CI. `deadcode` is pinned that way today (`go.mod:44`,
`scripts/check.sh:850`). The pick is the `go.mod` tool line at v1.10.0, the newest release
(`go list -m -versions golang.org/x/vuln`).

For the `CLAUDE.md` size, the cuts in task 2 save about 20 lines of the 21 needed. Moving the web and
Python stack rules (`CLAUDE.md` lines 102 to 121 and 132 to 145) to `.claude/rules/web.md` and
`.claude/rules/python.md`, each with a `paths:` list, saves about 33 more. Claude Code loads a rule with
`paths` only when a session reads a matching file. The Go, shell, systemd, and Cloudflare rules stay in
`CLAUDE.md`, since most sessions work in Go.

## Mechanisms and their sources

| Mechanism | Label | Source |
| --- | --- | --- |
| A `--bg` task session edits `.claude/skills/`, `agents/`, `rules/`, and `hooks/` in its worktree | Documented, probed | The probe below |
| `go test -fuzz`, seed corpora, `testdata/fuzz` | Documented | <https://go.dev/doc/security/fuzz/> |
| `govulncheck`, the race detector, fuzzing as the Go team's checks | Documented | <https://go.dev/doc/security/best-practices> |
| Fuzz workflow on `pull_request` with `paths` | Documented | <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax> (`on.<event>.paths`) |
| `go tool` running a tool pinned by a `tool` line in `go.mod` | Documented, in use | <https://go.dev/doc/modules/managing-dependencies#tools>; `go.mod:44` pins `deadcode` this way |
| Path-scoped rules in `.claude/rules/` | Documented | <https://code.claude.com/docs/en/memory>: a rule with `paths` frontmatter loads when Claude reads a matching file |
| `dependabot.yml` version updates, grouped, monthly | Documented | <https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference> (`groups`, `schedule.interval`) |
| Secret scanning, push protection, alerts | Documented | <https://docs.github.com/en/rest/repos/repos> (`PUT /repos/{owner}/{repo}/vulnerability-alerts`; `PATCH /repos/{owner}/{repo}` with `security_and_analysis`) |
| `Serve` closes its listener when it returns, even after `Shutdown` | Documented | `$GOROOT/src/net/http/server.go`, `Server.Serve`: `l = &onceCloseListener{Listener: l}; defer l.Close()` before `trackListener` |

The probe ran on 2026-11-22 in a scratch repo under the session's scratchpad, with four `.claude/`
files committed:

```bash
claude --bg --name reshape-probe --model sonnet --effort medium --permission-mode auto \
  --settings '{"permissions":{"denyInsteadOfPrompting":true},"worktree":{"baseRef":"fresh"}}' \
  "/goal In this repo, append the line 'Line two.' to each of these four files: .claude/skills/probe/SKILL.md, .claude/agents/probe-agent.md, .claude/rules/probe.md, and .claude/hooks/probe.sh. Use the Edit tool for each. Then commit ..."
```

Its worktree's `git show --stat HEAD` printed `52a3d06 Add line two to the probe files` and
`4 files changed, 4 insertions(+)`, one line in each file. Its report read "All four edits were made
and committed. Nothing was refused." The probe didn't cover deleting or renaming a skill folder. Task 2
says what it does if that is refused.

## Assumptions

- The gate form is `bash scripts/gate.sh` with its flags, run from the worktree root. `gate.sh`'s
  comment claims a worktree session's Bash guard refuses `cairn-run-gate '<string>'`, and the 30-day
  denials log holds no such refusal. The wrapper's real reason is that it builds the gate string from a
  fixed flag set. Proof today, from Claude Code in the main checkout: `bash scripts/gate.sh
  --scope-changed --dry-run` printed `gate.sh: lane=light` and `gate exit: 0`. Tasks 1 and 2 each prove
  it from a task session's worktree, and each quotes its `gate exit: 0` line.
- CI on a public repo runs today: the last eight `check` runs succeeded, each job about 6 to 7 minutes
  (`gh run list --repo glw907/dubplate --workflow check.yml`). All eight were on one pull request's
  branch, `structure-keys`.

## Files

The file list comes from `research/2026-11-22-spec-inputs/search-dubplate.md`, which lists every hit.

- Strict words (`pass-core|running-passes|conductor|executor|approval[- ]packet|approval[- ]queue|
  cairn-implementer|launch-prompts|pair subagent`): 21 hits. Task 2 removes the 8 in `dubplate-pass`,
  the 3 in `CLAUDE.md`, and the 1 in `api-access.md`. Hand-over 1 removes the 5 in `docs/STATUS.md`.
  The 1 in `docs/standing-rules.md:123` and the 3 in `scripts/check.sh:126,807,808` name words the
  citation leg refuses and stay.
- The word "pass": 63 hits, sorted in `triage-dubplate.md` as process 43 and ordinary 20. Task 2 takes
  the process hits in `CLAUDE.md` (48, 62, 151, 212), `docs/standing-rules.md` (10, 17, 18, 24, 39, 127),
  and the skill. Task 3 takes `scripts/check.sh:31,799`. Hand-over 1 takes `docs/STATUS.md`. The 20
  ordinary hits stay.

Each task's files:

- Task 1: `internal/serve/server.go`, `internal/serve/server_test.go`.
- Task 2: `CLAUDE.md`, `.claude/skills/dubplate-pass/` (removed), `.claude/skills/dubplate-build/SKILL.md`
  (new), `.claude/rules/web.md` (new), `.claude/rules/python.md` (new),
  `.claude/instructions/api-access.md`, `docs/standing-rules.md`, `scripts/gate.sh` (its header comment
  only), `BACKLOG.md`.
- Task 3: `go.mod`, `go.sum`, `scripts/check.sh`, `Makefile`, `.github/workflows/check.yml`,
  `.github/workflows/fuzz.yml` (new), `.github/dependabot.yml` (new), `internal/engine/tagio/fuzz_test.go` (new),
  `internal/intake/gate/fuzz_test.go` (new), `docs/standing-rules.md`, `.claude/skills/dubplate-build/SKILL.md`.
- Hand-overs: `docs/STATUS.md`.

## Commands against the denials log

Read against `worktrees-and-denials.md`, the 30 days to 2026-11-22. No task merges (`[Merge Without
Review]` refused `gh pr merge`), deletes a remote branch (`[Git Destructive]` refused `git push origin
--delete`), or starts a workflow (`[Auto-Mode Bypass]` refused `gh workflow run`). Geoff's session does
the first two by `building-from-specs` "Merging", and the fuzz workflow's pull request trigger replaces
the third. `[Self-Modification]` refused an edit under a `cairn-cms` worktree's `.claude/skills/`. The
probe in "Mechanisms and their sources" shows that edit allowed from a `--bg` task session. Every other
command is `go test`, `make`, `bash scripts/gate.sh`, `git`, `gh pr create`, `gh pr checks --watch`, and
`gh run view`, none refused.

## Before task 1: Geoff's session

Geoff's session does these in order, and the launch prompt carries them.

1. Hand-over 1, committed directly to `master`. `docs/STATUS.md` drops the round-report block's resume
   pointer and the "Coordination" section, says the three reshape tasks run now and the `structure`
   work waits for them, keeps "Open decisions", and stays at 60 lines or fewer in the present tense.
   - `wc -l < docs/STATUS.md` prints `61` today, and 60 or less after.
   - `git grep -n -i -E 'pass-core|running-passes|conductor|executor|approval[- ]packet|pair subagent|^## Coordination' -- docs/STATUS.md | wc -l`
     prints `6` today, and `0` after.
2. The GitHub settings, through `gh api`. Each was read today; the writes are GitHub's documented
   endpoints and run for the first time here, each followed by its check.

   ```bash
   gh api -X PUT repos/glw907/dubplate/vulnerability-alerts
   gh api -X PATCH repos/glw907/dubplate \
     -f 'security_and_analysis[secret_scanning][status]=enabled' \
     -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
   ```

   - `gh api repos/glw907/dubplate/vulnerability-alerts >/dev/null; echo $?` prints `1` today (404), and
     `0` after.
   - `gh api repos/glw907/dubplate --jq '[.security_and_analysis.secret_scanning.status,
     .security_and_analysis.secret_scanning_push_protection.status] | join(" ")'` prints
     `disabled disabled` today, and `enabled enabled` after.

   Dependabot security updates stay off; Geoff's ruling didn't include them.

## Task 1: fix the shutdown race in `internal/serve`

`serveUntilDone` (`internal/serve/server.go:151`) starts one `srv.Serve` goroutine per listener, takes
the first error, calls `srv.Shutdown`, and returns without waiting for the other goroutines. A `Serve`
that registers its listener after `Shutdown` closes that listener only as it returns, so the address can
still be bound when `serveUntilDone` returns. The fix waits for every `Serve` goroutine before returning
through a `sync.WaitGroup` that each `Serve` goroutine marks done, waited on after `Shutdown` on both
the failure path and the `ctx.Done` path. It returns the first error as today. Draining the error
channel instead must count the value the `select` already took, or it hangs. The test's promise stays: "every address it bound is free the moment it returns."

Done when:

1. The race test passes 1,000 times under the detector.
   `go test -race -count=1000 -run '^TestServeUntilDoneShutsDownWhenOneServeFails$' ./internal/serve/`
   Today, three runs at `-count=200` printed `FAIL` with 8, 7, and 7 failures, each `still bound after
   the failure path`. After, it prints `ok`.
2. The package passes plain. `go test -count=1 ./internal/serve/` prints `ok` today and after.
3. `bash scripts/gate.sh` passes from the task's worktree root, and the pull request quotes its
   `gate exit: 0` line. This is the gate-form proof. The old `dubplate-pass` skill is still in place
   while this task runs; the task reads its gate, worktree setup, and CI watch lines and none of its
   process.
4. CI's `check` passes on the pull request. `gh pr checks <n>` lists `check` as `pass`.

Reviewers: `standards:diff-reviewer` and `standards:web-auth-security-reviewer` (`internal/serve` is a
sign-in and data path). Minutes: 135 (work 25, local gates 34, CI wait 61, review 15). Time clause: 270
minutes. Model: Sonnet at high. Waits for: hand-over 1 and the settings.

## Task 2: rewrite the Claude files and the backlog

Rename `.claude/skills/dubplate-pass/` to `.claude/skills/dubplate-build/` with `git mv`, then rewrite
`SKILL.md` as a short skill of facts in the agent-facing register
(`~/.claude/docs/voice/agent-facing.md`).

It keeps, from the old skill, reworded to tasks and specs: the gate, fast lane, `--base` rule, `--merge`
branch scan, and full-suite home; the harness `go vet -tags oracle` line; worktree setup, with
`npx svelte-kit sync` after `npm ci --prefix web` (#154); the CI watch; the risk map, with
`internal/ops/**` joining the sign-in and data paths (#157); the reviewers by path; and the conventions
(test-first on sign-in and data work, mutation proofs run, fixture states, layering, no export ahead of a
caller, config keys, skills and the visual identity spec, errata, the four planning-miss checks a spec
closes, ranked findings, the dependency sweep as the first task of each milestone's first spec, and
Geoff's three product sittings). It drops what `building-from-specs` now owns: the executor check,
concurrent passes, pair subagents, per-task review, commits, records, clock, dispatches, stops, resume,
scope, and the close checklist. Its description triggers on building, resuming, or reviewing a task in
`dubplate`. If the rename is refused, the session writes the new skill beside the old one and puts
`git rm -r .claude/skills/dubplate-pass` under `## Before merge`.

`CLAUDE.md` drops "Build process", cuts "Gate" to a pointer to the skill and `docs/standing-rules.md`,
rewords lines 48, 62, and 151 to tasks, specs, and milestones, and closes #128. Its first safety rail,
the executor check at lines 207 to 211, becomes one rail naming the workstation's check: before a
session enters a worktree, it runs `claude-worktree-busy <path>`. The web stack rule (lines 102 to 121)
moves to `.claude/rules/web.md` with `paths: ["web/**"]`, and the Python stack rule (lines 132 to 144)
moves to `.claude/rules/python.md` with `paths` naming the files that bullet lists. Each moved rule's
text stays word for word apart from process words.
`api-access.md` line 14 drops "check for live executors". `docs/standing-rules.md` rewords its process
lines (10, 17, 18, 24, 39) to specs and tasks, fixes line 55's `make check` list to the six targets
`Makefile:154` runs (#136), and line 127 says the leg runs `go tool deadcode`, which it does today
(`scripts/check.sh:850`). `scripts/gate.sh`'s header drops the Bash-guard claim and keeps the fixed-flag
reason.

`BACKLOG.md` takes the sweep's verdicts (below), renames "Rounds to 0.8" to "Milestones to 0.8" with
"round" reworded to "milestone" in that section, and files two items: the `structure-doctor` restart
(tagged `#milestone:structure`) and the full sweep that is due. The restart item lists #123, #124,
#143, #144, #147, and #156, less any that task 3 closes first. BACKLOG line 39, which explains the
tags, names `#milestone:<name>`.

Done when:

1. The old process words are gone.
   `git grep -n -i -E 'pass-core|running-passes|conductor|executor|approval[- ]packet|pair subagent' -- CLAUDE.md .claude | wc -l`
   prints `12` today, and `0` after.
2. The process phrases are gone.
   `git grep -n -i -E '#pass:|#round:|dubplate-pass|pass plan|pass end|by the pass|the pass that|running pass' -- CLAUDE.md .claude docs/standing-rules.md | wc -l`
   prints `13` today, and `0` after.
3. `docs/standing-rules.md` keeps one "pass", in the citation leg's word list.
   `git grep -n -w -i -E 'pass(es)?' -- docs/standing-rules.md | wc -l` prints `7` today, and `1` after.
4. `wc -l < CLAUDE.md` prints `220` today, and 199 or less after. Unmet with a `## Before merge` step if
   the `CLAUDE.md` commit was refused.
5. `test -d .claude/skills/dubplate-pass; echo $?` prints `0` today, and `1` after. Unmet with a
   `## Before merge` step if the rename was refused.
6. `grep -c 'internal/ops/\*\*' .claude/skills/dubplate-build/SKILL.md` and
   `grep -c 'svelte-kit sync' .claude/skills/dubplate-build/SKILL.md` each print at least `1` after (the
   old skill prints `0` for each today).
7. `head -4 .claude/rules/web.md` shows a `paths:` line naming `web/**`, and
   `grep -c '^paths:' .claude/rules/python.md` prints `1`. Neither file exists today.
8. `grep -c 'Bash guard' scripts/gate.sh` prints `1` today, and `0` after.
9. No process tag is left. `grep -c -E '#(pass|round):' BACKLOG.md` prints `69` today, and `0` after.
   `grep -c '#milestone:' BACKLOG.md` prints `0` today, and at least `41` after.
   `grep -c '#milestone:structure' BACKLOG.md` prints at least `2` after (`#round:structure` prints `1`
   today).
10. `grep -c '^## Milestones to 0.8$' BACKLOG.md` prints `0` today, and `1` after.
    `sed -n '/^## Milestones to 0.8/,/^## Open/p' BACKLOG.md | grep -c -w -i -E 'rounds?'` prints `0`
    after (the old section prints `10` today).
11. `grep -c 'conductor-dubplate' BACKLOG.md` prints `1` today (#170), and `0` after.
12. The gate passes and CI's `check` passes, as in task 1, and the pull request quotes the gate's
    `gate exit: 0` line.

Reviewers: `standards:diff-reviewer`. Minutes: 150 (work 40, local gates 34, CI wait 61, review 15).
Time clause: 300 minutes. Model: Sonnet at high. Waits for: hand-over 1. It shares no file with task 1,
so the two may run at once.

## Task 3: add the Go team's checks

Add, by the Go team's practice and the house pin rule:

- A `go tool govulncheck ./...` leg in `scripts/check.sh` for every form but `--reduced`, pinned by
  `go get -tool golang.org/x/vuln/cmd/govulncheck@v1.10.0`, which adds the `tool` line to `go.mod`
  beside `deadcode`'s. CI needs no new install step. `docs/standing-rules.md` lists it among the gate
  legs and with `deadcode` as a tool pinned in `go.mod`. The leg needs the network, and it fails when
  the network is down; the house rule is that a check gates or doesn't exist.
- Three fuzz targets. `FuzzParseBounded` (`internal/engine/tagio`) and `FuzzValidPath`
  (`internal/intake/gate`) start from the trial files `research/2026-11-22-audit/trials/*_fuzz_test.go.txt`.
  `FuzzWalkZIP` writes each input to a file under `t.TempDir()`, opens it with `os.OpenRoot`, and walks
  it with `zipPolicy()` from `zip_test.go:92` and with `separateTracks` both false and true. It checks
  that the walk never panics, that a successful walk keeps only members whose path `ValidPath` accepts,
  and that `Total` equals the sum of their sizes. Its seeds are archives built with `archive/zip` in the
  test: one valid FLAC member, a `../` member, and an empty archive. The seeds run in every `go test`.
- `make fuzz`, which runs each target for `FUZZTIME` (default `30s`), one target per `go test -fuzz`
  call, since `go test` fuzzes one target at a time.
- `.github/workflows/fuzz.yml`, with one job whose id is `fuzz`, on `pull_request` with `paths` covering
  `internal/engine/tagio/**`, `internal/intake/gate/**`, the workflow, and the `Makefile`. It runs
  `make fuzz FUZZTIME=1m`, and on failure uploads each `testdata/fuzz` folder with
  `actions/upload-artifact` pinned by SHA at its newest release. It has no schedule.
- `make test-race`, running `go test -race -count=1 -timeout 30m ./...`, and a CI step after the gate,
  "Run the race detector", with the job's `timeout-minutes` raised from 45 to 75. The numbers come from
  two runs. The audit's whole-module race run hit Go's default 10-minute limit in
  `internal/harness/conform`, and the next-slowest package, `cmd/dubplate-server`, took 297 seconds.
  On 2026-11-22, `go test -race -count=1 -timeout 60m -p 4 ./internal/harness/conform/` printed
  `ok ... 540.348s` on pavilion, at 121 percent of one core. The package runs mostly on one core, so the
  runner's 4 vCPU don't shorten it, and 30 minutes leaves room for a slower core. The step adds roughly the conform
  time to each pull request's CI wait.
- `.github/dependabot.yml`, watching the `github-actions` ecosystem at `/`, monthly, with every update
  grouped into one pull request and a comment naming why the scope is narrow. The milestone dependency
  sweep already covers `go.mod`, `web/package.json`, `tools/venv/requirements.txt`, and the pinned
  binaries, and it never covers the three `uses:` actions `check.yml` pins by SHA. Each Dependabot pull
  request goes through `standards:dependency-upgrade`.
- `scripts/check.sh` lines 31 and 799 reword "pass" to "task" and "session".
- The repo skill's full-suite line names the race step and the fuzz workflow. Its dependency-sweep
  convention gains two lines: the milestone's first task also runs `make fuzz FUZZTIME=10m`, and takes
  any open Dependabot pull request through `standards:dependency-upgrade`.

If #133 (`TestBusyTimeout`) or #143 (`TestDoctorBoundaryProbe_TrustedLoopbackEndToEnd`) fails under the
race step, the task fixes its traced cause and closes the item. A test is never skipped under `-race`.

Done when:

1. `go test -list '^Fuzz' ./internal/engine/tagio/ ./internal/intake/gate/` lists no target today, and
   lists `FuzzParseBounded`, `FuzzValidPath`, and `FuzzWalkZIP` after.
2. `make fuzz FUZZTIME=30s` prints `No rule to make target 'fuzz'` today, and exits 0 after.
3. `grep -c govulncheck scripts/check.sh go.mod docs/standing-rules.md` prints `0` for each today, and
   at least `1` for each after.
4. `grep -c -- '-race' Makefile .github/workflows/check.yml` prints `0` for each today, and at least `1`
   for each after.
5. The gate passes from the worktree, and its log shows the `govulncheck` leg passing.
6. On the pull request, `gh pr checks <n>` lists `check` and `fuzz` as `pass` (the pull request touches
   both fuzzed packages, so the `paths` filter starts `fuzz`), and
   `gh run view <id> --repo glw907/dubplate --json jobs --jq '.jobs[].steps[] | select(.name=="Run the race detector") | .conclusion'`
   prints `success`. The same query for "Run the gate" printed `success` on run `44846000826` today.
7. `test -f .github/dependabot.yml; echo $?` prints `1` today, and `0` after.
   `grep -c 'package-ecosystem' .github/dependabot.yml` prints `1`, and
   `grep -c 'package-ecosystem: github-actions' .github/dependabot.yml` prints `1`.

Reviewers: `standards:diff-reviewer`. Minutes: 225 (work 80, local gates 45, CI wait 85, review 15).
Time clause: 450 minutes. Model: Opus at medium, since a race failure may need a traced fix. Waits for:
tasks 1 and 2 merged.

## After task 3: Geoff's session

Hand-over 2, committed directly: `docs/STATUS.md` says the reshape is done and names the
`structure-doctor` restart item by number. Then
`gh api repos/glw907/dubplate/contents/.github/dependabot.yml --jq .name` prints `dependabot.yml`
(today: `Not Found (HTTP 404)`).

## Merge order

Hand-over 1 and the settings, then tasks 1 and 2 in either order, then task 3, then hand-over 2.

## Backlog sweep

The scoped `standards:backlog-sweep` verdicts, from `research/2026-11-22-spec-inputs/sweep-dubplate.md`.
Approving this spec approves these edits, which task 2 makes.

| Item | Verdict | Edit |
| --- | --- | --- |
| #128 Trim `CLAUDE.md` | Fold | Task 2 |
| #136 Three gate texts | Fold | Task 2 (`standing-rules.md:55`, the skill's `scripts/checks/` path) |
| #154 Worktree needs `svelte-kit sync` | Fold | Task 2 |
| #157 Risk map omits `internal/ops/**` | Fold | Task 2 |
| #108 Adapter changes G14 to G19 | Done | Move to Done |
| #109 Workstation changes X1 to X6 | Drop | Move to Won't do |
| #170 Unenforced "must not be nil" | Reword | "Ruled kept as is for `structure-base` by `conductor-dubplate`, 2026-11-20." becomes "`structure-base` (PR #18) kept them as is." |
| #158, #105, #135, #168, #156, #164, #152, #107, #143, #133 | Keep | None; task 3 may close #143 or #133 |
| 56 items with only a process tag | Reword | Drop `#pass:cleanup-*`, `#pass:structure-keys`, `#round:engine`, and `#pass:structure-doctor`; rename every other `#round:<name>` to `#milestone:<name>` |

A full sweep is due (23 open items carry no recent stamp). Task 2 files it as an item and runs none.

## For Geoff, outside the tasks

Two leftover worktrees are his session's to look at, and no task touches them:
`.claude/worktrees/agent-a828799e8800f0243` (its tip is merged, and it holds 23 modified files) and
`~/.claude/jobs/5452379b/tmp/base-tree`. With `govulncheck` pinned in `go.mod`, the `Brewfile` needs no
line for it.

## Calls Claude made

1. The repo skill is named `dubplate-build`.
2. The race detector runs as a CI step after the gate, through `make test-race`, and the local gate stays
   as it is.
3. The timed fuzz run is a workflow on pull requests touching fuzzed code, plus a 10-minute run in each
   milestone's first task. No schedule, so nothing fails between sittings.
4. `govulncheck` is pinned by a `tool` line in `go.mod` and run as `go tool govulncheck`.
5. `FuzzWalkZIP` joins the two trial targets. `ParseBounded` gains no reader entry point, since the
   seeds cost the gate little.
6. The BACKLOG tag for a milestone is `#milestone:<name>`, as the sweep proposed.
7. The restart of `structure-doctor` is a BACKLOG item for a later spec, not a task here.
8. History in frozen documents (plans, archived specs, provenance in items) stays as written.
9. Tasks 1 and 2 may run at once; they share no file.
10. The GitHub settings writes run in Geoff's session before task 1, so alerts cover the work.
11. `dependabot.yml` watches only the GitHub Actions pins, since the milestone sweep covers every other
    dependency. Geoff's ruling named the file and not its scope.
12. The web and Python stack rules move to path-scoped rules, so `CLAUDE.md` fits under 200 lines.
13. The executor safety rail becomes a `claude-worktree-busy` rail rather than going away.
14. Tasks 1 and 2 run on Sonnet at high, and task 3 on Opus at medium. Each task's reviewers run on Opus
    at high, by `building-from-specs` "Models".
15. One Opus fresh reader checks this spec for both a builder's questions and plain reading. It read the
    draft on 2026-11-22, and its findings are folded in.
