# Audit of `cairn-cms` and `dubplate` against the workstation process

Both repos still run the retired process, and the reshape replaces it. In that process a conductor
session ran each piece of work as a pass, executor sessions built it, and Geoff approved it from a
packet; `pass-core` and `standards:running-passes` were the skills that held it. Each repo's Claude
files still name those words: 24 lines in `cairn-cms` and 6 in `dubplate`. `dubplate`'s process
skill loads `pass-core`, which no longer exists. `cairn-cms`'s skill defers to
`standards:running-passes`, which the standards plugin removed on 2026-11-21. Most of each repo's
Claude files are product rules, and they stay.

The audit weighed nine tools. Three earn a place in `dubplate`: `govulncheck` and fuzz tests in its
gate, and `go test -race` in CI after one fix. The race run found no data race. It did expose an
ordering bug in `internal/serve` that a plain test run hides. The two community Go skills and two
plugins are declined. `claude-security` waits for Geoff's word, and `security-guidance` waits on his
budget call. Both public repos have GitHub's secret scanning, push protection, and Dependabot alerts
turned off.

This audit read `dubplate` at `907605c` on `master` and `cairn-cms` at `87869e61f` on `main`, both
idle (`claude-worktree-busy` exited 0 for each), on 2026-11-22. The workstation side is
`building-from-specs`, `cairn-pass`, `claude-infra`, `~/.claude/docs/claude-tooling.md`, and the
global `CLAUDE.md`. The Anthropic pages are the Claude Code docs for memory, skills, subagents,
hooks, settings, plugins, and worktrees, read on 2026-11-22.

The verdicts use five words: keep, shrink, replace, move to the workstation, and remove. A
trial's verdict is adopt or decline.

## What waits on Geoff

Three questions are his, because they are budget or scope. He answered them on 2026-11-22, and
`../../STATUS.md` quotes his answers. Everything else in this page is a
method call that each repo's spec settles. A later session writes those two specs from this
audit, `dubplate`'s first.

1. Should an automated security review spend usage? `security-guidance` would run an Opus review of
   the diff at the end of every turn that edits code. `claude-security` would run one whole-repo
   scan through the Workflow tool, which starts many subagents and asks to confirm its cost first. A
   yes is also Geoff's word to run that scan as the trial, and it adds the chosen review to the
   specs with its cost named. A no leaves both out, and the reviews `building-from-specs` already
   runs before a pull request is ready stay the only ones.
2. Should GitHub's free security features go on for both public repos? A yes has Geoff's session
   turn on secret scanning, push protection (which refuses a push that holds a known kind of key),
   and Dependabot alerts through `gh api`, and the `dubplate` spec adds a `dependabot.yml`. A no
   leaves them off, and the `gitleaks` scan in `dubplate`'s gate stays the only secret check.
3. Should the `figure-verifier` agent go with the `cairn-figure` skill? Both serve figures, the
   diagrams and screenshots on a `cairn-cms` docs page. Geoff ruled "You can remove cairn-figure" on
   2026-11-22, and standards pull request 25 removes the skill. A yes removes the agent in that same
   pull request. A no keeps it for a later figure.

## Findings both repos share

The retired process is everywhere the repos describe how work runs. `building-from-specs` says
what replaces it: "A spec is the approved design. A task is one independent piece of it that
ends in one pull request." It also says "no session plays the conductor." The words to remove
come from this search:

```bash
git grep -c -E 'pass-core|running-passes|conductor' -- CLAUDE.md .claude
```

In `cairn-cms` it finds lines in `CLAUDE.md` (2), `cairn-proving-setup` (5), `cairn-releasing` (5),
`cairn-running-passes` (7), `cairn-writing-docs` (4), and `cairn-writing-engine-code` (1). In
`dubplate` it finds `CLAUDE.md` lines 71 and 73 and four lines of `dubplate-pass`.

Each repo's `docs/STATUS.md` runs past the skill's limit. `building-from-specs` says "A repo's
`docs/STATUS.md` is written in the present tense and holds 60 lines or fewer." `dubplate`'s holds 61
lines and `cairn-cms`'s holds 74. Both carry resume pointers to conductor prompts. `cairn-cms`'s line
56 reads "round `checks` is running under `conductor-cairn-cms`", and `claude agents --json`
lists no such session.

The two repos and the workstation give three different gate commands. `cairn-pass` says
"**Gate**: `cairn-run-gate '<string>'` from the task's worktree." `cairn-cms`'s `CLAUDE.md` says
"After each task, run `npm run lane:fast -- --range <base>..HEAD`." `dubplate`'s `scripts/gate.sh`
and the initiatives repo's gate script both say "A worktree-isolated session's Bash guard
refuses `cairn-run-gate '<string>'`". The denials log, `~/.local/state/claude-denials.jsonl`,
holds no such refusal. Its two `cairn-run-gate` records are a `pkill` refused as "[Interfere With
Workloads]" and one call refused as "Classifier unavailable". No workstation hook refuses the
quoted form by name. Each spec settles one gate form for its repo and proves it from a task
session in a worktree.

Neither public repo has GitHub's free security features on. This command was run for each repo:

```bash
gh api repos/glw907/<repo> --jq '.security_and_analysis'
```

It prints `"status": "disabled"` for secret scanning, push protection, and Dependabot security
updates in both. `gh api repos/glw907/<repo>/vulnerability-alerts` answers 404, which means
Dependabot alerts are off. `cairn-cms` has `.github/dependabot.yml`, and `dubplate` has none.

## `dubplate`

| Piece | Verdict | What changes |
| --- | --- | --- |
| `CLAUDE.md` (220 lines) | Shrink | Drop "Build process" and the executor safety rail; get under 200 lines |
| `.claude/skills/dubplate-pass/` (241 lines) | Replace | A short repo skill of facts: gate, CI watch, risk map, checklists |
| `.claude/instructions/api-access.md` | Shrink | Keep the inventory, and drop the claim that anything loads it |
| `.claude/settings.json` | Keep | Allow rules only |
| `.claude/project-tracking.json` | Keep | `standards:log-issue` reads it |
| `docs/standing-rules.md` (128 lines) | Keep | Product rules and the gate's legs |
| `docs/STATUS.md` (61 lines) | Shrink | 60 lines or fewer, present tense, no conductor pointer or "Coordination" section |
| `scripts/gate.sh` and `scripts/check.sh` | Keep | Add `govulncheck` and the fuzz seeds; CI's full suite adds `-race` |
| `.github/workflows/check.yml` | Keep | Runs the same `scripts/check.sh` on every pull request |

`CLAUDE.md` is over the size the docs set. The memory page says to "target under 200 lines per
CLAUDE.md file. Longer files consume more context and reduce adherence." Line 71 reads "Process:
the `dubplate-pass` skill (`.claude/skills/dubplate-pass`), loading `pass-core`." Line 73 reads
"The design approval and the packet read are `pass-core`'s." The first safety rail tells "any
executor" to check a worktree before it touches it, and ends "STATUS records each running pass's
session name and id." `building-from-specs` now owns that check ("`claude-worktree-busy
<checkout>` exits 0") and says a task session leaves STATUS alone. The rest of the file holds
product rules: the Go bar, words, versions, refused features, and "Facts agents get wrong". Those
stay.

`dubplate-pass` is the adapter for the retired lifecycle. Line 12 reads "Load `pass-core` first;
it holds the lifecycle and the rules this adapter fills in." Its pair subagents, its stops in
`advisor.md`, and its resume through `EnterWorktree` describe the old flow. Its facts still
hold, and the new skill keeps them: the gate `bash scripts/gate.sh` with `--scope-changed` as the
fast lane and `--merge` for the `gitleaks` branch scan, the CI watch `gh pr checks <n> --watch
--fail-fast`, and the risk map. The map's sign-in and data paths are `internal/auth`,
`internal/serve`, `internal/webapp`, `internal/store/migrations`, `internal/intake`,
`cmd/dubplate-server`, `web/src/routes/login`, `web/src/routes/members`, and `systemd`. The
replacement stays in the repo. `claude-tooling.md` gives the rule: "the repo when only that repo
needs it, since committed files reach cloud sessions." No workstation skill is needed for `dubplate`.

`.claude/instructions/` is not a place Claude Code reads. The memory page lists what loads at
start (`CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/`, and `CLAUDE.local.md`), and the folder
is not among them. `api-access.md` still works, because `CLAUDE.md` line 131 points at it ("See
`.claude/instructions/api-access.md`") and a session reads it on demand. Seventeen `dubplate` plans
name a sibling file, `.claude/instructions/simplifier-brief.md`, that the folder no longer holds.
Those plans are history and stay as written.

`docs/standing-rules.md` keeps one line the reshape changes. It lists "ruling, fold, pass, and
conductor tags" among the comment words the gate refuses. The rule still serves, and it holds no
process instruction.

`dubplate`'s paused work stays as it is. STATUS records that the structure round is paused after
two of its three passes (Geoff, 2026-11-20). Its resume prompt lives in
`initiatives/dubplate-server/plans/2026-11-17-structure/`, which the planning prompt puts out of
this work's reach. That round must stay paused while the first reshape task runs.

## `cairn-cms`

| Piece | Verdict | What changes |
| --- | --- | --- |
| `CLAUDE.md` (114 lines) | Shrink | Replace lines 26 and 47's pass wording with `building-from-specs` |
| `.claude/settings.json`, `worktree.baseRef` | Remove | The user settings already set it |
| `.claude/settings.json`, the rest | Keep | Marketplace, plugin, allow rules, the release hook |
| `.claude/hooks/release-cut-guard.mjs` (448 lines) | Keep | No change |
| `.claude/rules/` (5 files) | Keep | Path-scoped, the documented form |
| `cairn-running-passes` (64 lines, 3 references) | Replace | A short repo skill of checklists, its gate facts merged with `cairn-pass` |
| `cairn-releasing` (383 lines) | Shrink | Drop the `standards:running-passes` "Close" pointer and pass wording |
| `cairn-proving-setup` (102 lines) | Shrink | Drop conductor and executor wording |
| `cairn-writing-docs` | Shrink | Drop the `approval-packet` steps in `references/review.md` and `evals/cycle-prompt.txt` |
| `cairn-judging-scope`, `cairn-writing-engine-code`, `cairn-following-admin-design`, `cairn-following-public-design` | Keep | Product skills; one stray word in `durable-gotchas.md` |
| `cairn-implementer` agent | Remove | The task session builds; no pair subagent |
| `engine-triage`, `docs-fact-checker` agents | Keep | Product work |
| `docs/STATUS.md` (74 lines) | Shrink | 60 lines or fewer; drop the conductor pointers and the "checks-2 executor" section |
| Gate (`npm run lane:fast`) and CI | Keep | Settle one gate form with `cairn-pass` |
| `cairn-pass` (workstation) | Shrink | One gate form; its CI watch stays |

`cairn-running-passes` defers to a skill that is gone. Its line 8 reads "The
`standards:running-passes` skill holds the lifecycle (design, plan, execute, close)." Standards
commit `b187695` removed that skill on 2026-11-21. Of its three references, `launch-prompts.md`
(30 lines) repeats what `building-from-specs` "Launching a task" now owns, and goes.
`admin-smoke-test.md` (286 lines) is a product checklist and stays. `pass-gate-tiers.md` (233
lines) and `cairn-pass` describe the same gate in different words, and the spec gives them one
home. `claude-tooling.md` puts a skill only one repo needs in that repo. `building-from-specs`
names `cairn-pass` as `cairn-cms`'s facts file, and changing that line is a workstation process
change, which the initiative record (`../../README.md`) puts out of scope. The `cairn-cms` spec decides which facts sit in
`cairn-pass` and which in the repo skill, and the repo skill takes a name without a retired word.

`cairn-releasing` keeps its procedure. Line 53 points at "`standards:running-passes` "Close"",
which is gone. `cairn-writing-docs/references/review.md` line 4 says "The `approval-packet` skill
owns the document, its check, its send," and no such skill exists. Line 51 says "Under a
conductor, the conductor sends it."

The `worktree.baseRef` line repeats a user setting. `.claude/settings.json` line 11 sets
`"worktree": { "baseRef": "head" }`. `claude-tooling.md` line 55 says the same value "in the
tracked `settings.json` applies in every repo". The settings page gives precedence as managed,
then command line, then local, then project, then user. A task launch's `--settings` value sets
`baseRef` to `fresh` on the command line, so it wins either way. The line does nothing and can
go. A change to `settings.json` is Geoff's session's, so the spec names it in a separate section.

The release guard stays as written. Its comment says "The hook has no `if` filter, so it reads
every Bash call that names `release`." The hooks page says an `if` rule runs "when any
subcommand of the Bash input matches". The guard reads into `bash -c` strings, `eval`, `ssh`,
here-documents, and `xargs`, where an `if` rule would never see a `gh release create`. A filter would
save a process spawn and weaken the guard.

`cairn-implementer` belongs to the retired pairing. `building-from-specs` has the task session
build, and a fresh `standards:diff-reviewer` review it: "A fresh session builds each task under
`/goal`." No step in the skill dispatches an implementer.

## Tool trials

| Tool | Verdict | Why |
| --- | --- | --- |
| `govulncheck` | Adopt | Clean today, and it catches what nothing else in the gate does |
| Fuzz tests for the parsers | Adopt | Both trial targets pass; the seeds run in every `go test` |
| `go test -race` | Adopt, after one fix | No data race; it exposed an ordering bug in `internal/serve` |
| `golang-security` (`samber`) | Decline | Its checks already hold in `dubplate` |
| `golang-database` (`samber`) | Decline | Its rules conflict with `dubplate`'s SQLite design |
| `security-guidance` plugin | Pattern layer declined; review layers wait on Geoff | Pattern layer is noise; review layers spend usage every turn |
| `claude-security` plugin | Not run, pending Geoff's word | It runs only as a Workflow |
| `claude-code-setup` plugin | Decline | Its picks for these repos are installed |
| `claude-md-management` plugin | Decline | Partly stale, and weaker than the docs it summarizes |

### `govulncheck`

Homebrew carries the tool (`govulncheck 1.10.0 homebrew/core`), and the software tiers put command-line
tools there. It was installed with `brew install govulncheck` and run on `dubplate`:

```console
$ govulncheck ./...
=== Symbol Results ===

No vulnerabilities found.

Your code is affected by 0 vulnerabilities.
This scan also found 0 vulnerabilities in packages you import and 1
vulnerability in modules you require, but your code doesn't appear to call these
vulnerabilities.
exit=0
```

The one module finding, from `govulncheck -show verbose ./...`, is GO-2026-5932: "The
golang.org/x/crypto/openpgp package is unmaintained, unsafe by design, and has known security
issues", found in `golang.org/x/crypto@v0.58.0`. `dubplate` doesn't import that package. The scan
is cheap and exits 0, so it fits the gate and CI. A future finding in called code fails the
gate, which is the point. CI would install it at a pinned version, like the other tools in
`check.yml`.

### Fuzz tests

`dubplate` has no `func Fuzz` today. Two trial targets were written in a `git archive` copy of
`907605c` outside the repo, and both are in `trials/`. `FuzzParseBounded` feeds arbitrary bytes
to `tagio.ParseBounded`, `tagio.Read`, and `tagio.Sniff`, seeded with `testdata/golden.flac`. It
checks that a refusal returns the zero `Container` and that the frame region never runs past the
file. `FuzzValidPath` feeds arbitrary bytes to `gate.ValidPath`.

```console
$ go test -run '^$' -fuzz '^FuzzParseBounded$' -fuzztime 120s ./internal/engine/tagio/
fuzz: elapsed: 2m1s, execs: 302688 (0/sec), new interesting: 75 (total: 79)
PASS
ok  	github.com/glw907/dubplate/internal/engine/tagio	121.076s
$ go test -run '^$' -fuzz '^FuzzValidPath$' -fuzztime 60s ./internal/intake/gate/
fuzz: elapsed: 1m0s, execs: 11158696 (0/sec), new interesting: 99 (total: 106)
PASS
ok  	github.com/glw907/dubplate/internal/intake/gate	60.130s
```

Neither found a failure. The FLAC target ran slowly: about 2,500 inputs a second, because
`ParseBounded` takes a path and each input is written to a file first. Its rate fell to zero
after 81 seconds, when the race run below took the CPU. A plain `go test` runs each target's
seed inputs as an ordinary test, so the targets cost the gate almost nothing. A timed fuzz run
belongs outside the gate. The spec decides where, and whether the parser gains a reader entry
point for speed. The zip walker, `gate.WalkZIP`, takes an `*os.Root` and is the third parser
worth a target.

### `go test -race`

`dubplate`'s `Makefile` runs `test: go test ./...` with no `-race`, and CI runs the same target.
The trial command was:

```bash
go test -race -count=1 ./...
```

It ran for 10 minutes 33 seconds of wall time, used 1,354 seconds of CPU, and peaked at about 935 MB
of memory. It reported no data race (`grep -c 'DATA RACE'` prints `0`). Two packages failed:

```console
panic: test timed out after 10m0s
	running tests:
		TestWholeCorpusGradesTheCorrectedVerdictsInDefaultMode (3m30s)
FAIL	github.com/glw907/dubplate/internal/harness/conform	600.612s
--- FAIL: TestServeUntilDoneShutsDownWhenOneServeFails (0.00s)
    server_test.go:397: 127.0.0.2:38625 still bound after the failure path, want the shutdown to have released it: listen tcp 127.0.0.2:38625: bind: address already in use
FAIL	github.com/glw907/dubplate/internal/serve	2.367s
exit=1
```

The `conform` failure is time. Under the detector the package runs past `go test`'s 10-minute
limit for one test binary. Without it the package passes in 38 seconds (`go test -count=1
./internal/harness/conform/` prints `ok ... 37.739s`), so the detector slows it more than
fifteen times.

The `serve` failure is a real bug, which the detector's scheduling exposes. The test passes
alone. Under the detector it failed 3 times in one run of 50 and 2 times in a second, and never
in 50 runs without it:

```console
$ go test -race -count=50 -run '^TestServeUntilDoneShutsDownWhenOneServeFails$' ./internal/serve/
--- FAIL: TestServeUntilDoneShutsDownWhenOneServeFails (0.00s)
    server_test.go:397: 127.0.0.2:38699 still bound after the failure path, ...
FAIL
$ go test -count=50 -run '^TestServeUntilDoneShutsDownWhenOneServeFails$' ./internal/serve/
ok  	github.com/glw907/dubplate/internal/serve	0.006s
```

`serveUntilDone` (`internal/serve/server.go:151`) starts one `srv.Serve` goroutine for each
listener, waits for the first error, and calls `srv.Shutdown`. Its comment says "Shutdown closes
the listeners it is still serving". It returns without waiting for the other goroutines. When
`Shutdown` runs before a second `Serve` has registered its listener, `Shutdown` can't close that
listener. That `Serve` closes it only as it returns, after `serveUntilDone` has returned. The
test's promise, "every address it bound is free the moment it returns", then fails. The fix is
product work in `internal/serve`. It goes to `dubplate`'s backlog, and it lands before `-race`
joins the gate.

The verdict is adopt, in two parts. The `serve` fix comes first. Then the race run goes into
CI's full suite with a `-timeout` long enough for `conform`, and the fast lane stays as it is.
The spec chooses the timeout.

### `golang-security`

The skill, `samber/cc-skills-golang` at `d68d80aec298` (MIT), was read in full. Its frontmatter
sets `paths: **/*.go`, so it loads on any Go file. Its allowed tools include `Agent`, `WebFetch`,
and `EnterWorktree`. Its orchestration mode says "Fan out the five ... sub-agents", and this
trial did not follow it. It installs tools with `go get -tool ...@latest`, which changes `go.mod` outside
`standards:dependency-upgrade`.

Its checklist was applied to `dubplate` by search instead. `dubplate` already sets server timeouts
(`internal/serve/server.go:91-92`) and body limits (`http.MaxBytesReader` in
`internal/auth/handlers.go:512` and `internal/ops/opshttp/opshttp.go:165`). It sends
`nosniff`, `Referrer-Policy`, HSTS, and CSP headers (`internal/serve/doc.go:13-16`), and compares
tokens with `subtle.ConstantTimeCompare` (`internal/auth/token.go:300`). It uses no `math/rand`
outside tests and opens uploads through `os.Root` (`internal/intake/gate/file.go:26`). Every
`exec.CommandContext` outside tests passes separate arguments with no shell. The checklist finds
nothing new. Its three useful checks, `-race`, `govulncheck`, and fuzzing, are adopted earlier
directly.

### `golang-database`

The skill, read in full at the same commit, assumes a different database. It pushes `sqlx` or
`pgx`, says "never hand-rolled ... migration SQL" and "Never create or modify database schemas",
sizes connection pools for Postgres, and uses a subagent in review mode. `dubplate` uses SQLite
through `modernc.org/sqlite` and `database/sql`, writes its migrations by hand
(`internal/store/migrate`), and keeps one writer (`SetMaxOpenConns(1)` at
`internal/store/conn.go:85` and `:132`). Following the skill would undo that design.

### `security-guidance`

The plugin (version 2.0.21, official marketplace) was read through its README, `hooks.json`, and
`patterns.py`. It has three layers. A regular-expression reminder fires on Edit and Write. A diff review runs
on Stop with the newest Opus, and an agentic review runs on `git commit` and `git push`. The two
review layers spend usage on every turn that edits code. It reads project rules from
`.claude/claude-security-guidance.md` and turns off by environment variable, such as
`ENABLE_STOP_REVIEW=0`.

The regular-expression layer was trialed by running its `SECURITY_PATTERNS` over each repo's tracked files
(`trials/sg_patterns.py`). In `dubplate` it flags 4 files: `check.yml`, a test that runs `sh -c`,
`innerHTML` in `web/scripts/rendered/run.ts`, and a research note. In `cairn-cms` it flags 23: 11
workflow files, `innerHTML` in 5 test files, `child_process` in 4 scripts and tests, and
`new Function` in 2 files where the word sits in a comment. Every code hit checked is a false
positive or test code. The review layers duplicate the `standards:diff-reviewer` and
`standards:web-auth-security-reviewer` reads that `building-from-specs` already requires before
a pull request is ready, so they would spend usage every turn for reviews the flow already
runs. That is Geoff's budget call.

### `claude-security`

The plugin (version 0.12.0) was read in full. A scan runs only through its
`claude-security:scan` Workflow, and its text says that "when the Workflow tool is
unavailable the scan job stops". It writes a `CLAUDE-SECURITY-<timestamp>/` folder into the repo
and asks the user to confirm the cost before it starts. The workstation runs the Workflow tool
only on Geoff's word, so this trial waits for it.

### `claude-code-setup`

The plugin only reads and recommends. This trial read its skill and references. Its first step
looks for manifests and frameworks, and in both repos it finds `go.mod` or `package.json`, with
Svelte, SvelteKit, and Playwright. Its tables map a Go project to `gopls-lsp` and a `gofmt` hook
on Edit, a TypeScript project to `typescript-lsp`, and a frontend with UI tests to the Playwright
server. `claude plugin list` shows `gopls-lsp@claude-plugins-official` and
`typescript-lsp@claude-plugins-official` installed, and the Playwright server is in use. No hook
formats Go on edit, but `dubplate`'s fast lane runs `gofmt -l` (`scripts/check.sh:655`) and
`.golangci.yml` enables `gofmt` and `goimports`, so the gate catches what the hook would. The
plugin adds nothing `claude-infra` doesn't already cover.

### `claude-md-management`

The plugin was read in full: the `claude-md-improver` rubric and the `/revise-claude-md`
command. It names the local file `.claude.local.md`, and the memory page names it
`CLAUDE.local.md`. Its tip about a "`#` key shortcut" appears nowhere on the memory page. Its
rubric doesn't weigh the 200-line target, or the page's rule that a multi-step procedure belongs
in a skill or a path-scoped rule. The memory page and `claude-infra` are the better reader.

## Good Go on this workstation

Geoff asked which skills, tools, or patterns would help write good Go. The workstation already
has the main ones. `standards:go-conventions` was called in 182 session transcripts in the
30 days to 2026-11-22. `standards:go-architecture-reader` grades one package on request. The `gopls-lsp`
plugin gives sessions the `LSP` tool for Go. What `dubplate` lacked were the three checks the Go
team recommends (<https://go.dev/doc/security/best-practices>), and this audit adopts them.

## For the workstation backlog

These are gaps outside the two repos. The initiative record says they go to the workstation backlog, not
into a spec.

- `installed_plugins.json` still holds project-scope records for older `standards` versions.
  Sessions started on 2026-11-22 load the current plugin, so nothing breaks today.
- `cairn-pass` and the two `gate.sh` comments disagree on whether `cairn-run-gate '<string>'` is
  refused in a worktree session.
- The `figure-verifier` agent grades figures for the cairn docs register, and nothing in
  `cairn-cms` dispatches it. Geoff ruled on 2026-11-22: "You can remove cairn-figure." Standards
  pull request 25 removes that skill. The ruling didn't name the agent.

## Evidence files

The `trials/` folder holds the outputs as run, with home paths shortened to `~`:
`govulncheck.txt`, `race.txt`, `conform-plain.txt`, `serve-stress.txt`, `fuzz.txt`, the two fuzz
targets, and `sg_patterns.py`.
