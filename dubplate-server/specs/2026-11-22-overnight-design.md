# Approve an overnight run on `dubplate`: the health checks move, and the gate's friction goes?

Initiative: `dubplate-server`. Repo: `dubplate` (`glw907/dubplate`, default branch `master`). Written 2026-11-22
against `fff37fe`. Status: approved by Geoff on 2026-11-22 ("Approve and launch").

Two sessions start together from `master` tonight and work while you are away. The first finishes the structure
work. It moves the eleven health checks out of the command folder (`cmd/dubplate-server`), each to the package
that knows the fact, by the design you approved on 2026-11-17. The second fixes what gets in a builder's way: a
timing test that turns CI red with no code change, a lint lock that fails when two gates run at once, the
workstation's `DUBPLATE_*` names reaching the gate's tests, and two stale pins. **Nothing deploys. Nothing a member
or an operator sees changes, with one exception: a write that waits on another process's lock now ends at its
deadline, which Geoff accepted.** I put the first task at 300 minutes and the second at
240. They change no file in common, so neither waits for the other, and neither waits for you. Each ends in a
separate pull request. In the morning you approve the two by number, the fixes first. Geoff answered both questions on 2026-11-22.

**Is this enough work for tonight?** Answered on 2026-11-22: two tasks, launched tonight. Geoff chose "Two is
enough (Recommended)".

**Do you accept that a write under lock contention ends at its deadline?** Answered on 2026-11-22: yes. Geoff
chose "Accept it (Recommended)". Today a write waits out the busy timeout, 15 seconds by default, and then
answers "busy". On the new driver it stops when its deadline passes, so under contention a member or an operator
sees the busy answer sooner, and an operator whose busy timeout is set over 30 seconds sees "context deadline
exceeded" at 30 seconds.

## What you asked for

<!-- vale Vale.Spelling = NO -->

> I'd like to prepare for an overnight run on dubplate, but before I do that I'd like to clear any backlog items
> that might be in the way of effective development.

<!-- vale Vale.Spelling = YES -->

> What's the next logical item that would fit in a ~10 hour window?

> And when planning, note that I'm not sitting at my computer all the time, so any manual PR approval effectively
> stops development. So you'll need to come up with a plan that solves that issue.

You approved this friction set: #144, #133, #143, #105, #176, #175, and #172.

The run has three goals:

- The `structure` milestone ends. Every health check sits with its fact, and the command folder only connects
  the parts.
- A builder's gate fails only for a reason in that builder's change.
- No approval stops work overnight. Both pull requests are waiting when you sit down.

It leaves these alone:

- Anything a person sees: the rows `doctor` prints, the help text, the settings, and the pages.
- The rest of #123, #124, and #156, and #152, #132, and pull request #23 from Dependabot.
- The server. Nothing deploys, and no session connects to it.

The run has failed if a line `doctor` prints changes, if a test is dropped or a goal edited to make a move pass,
if one task changes a file on the other's list, or if a session waits on a question or merges.

## Approaches

| Approach | Planned minutes | What stops it |
| --- | --- | --- |
| The health-check move alone | 300 | Nothing, and half the window stays empty. |
| Both tasks, one after the other | 540 | The second starts from `master`, so it waits for you to merge the first. |
| Both tasks in one session and one pull request | 540 | A red check on a pin holds the move, and one review reads sign-in code beside dependency bumps. |
| Both tasks at once, on files that don't overlap | 540, about 300 on the clock | Their gates share one machine and take turns. |

I picked the last. The cost is the shared machine, and "What goes wrong" gives its numbers.

## What both tasks rest on

- `master` is green. `git diff --stat 4fd388d fff37fe` names only `BACKLOG.md` and `docs/STATUS.md`, and the full
  gate passed on `4fd388d`.
- The two file lists don't overlap. "Files" gives the searches.
- CI can run: `gh repo view glw907/dubplate --json visibility` prints `PUBLIC`.
- Neither task needs a secret, and neither connects to the server.
- `claude-worktree-busy /var/home/glw907/Projects/dubplate` exits 0 today. Pavilion has two working sessions, so
  the two launches make four. The launching session checks both again at launch.
- The workstation's shell holds 16 `DUBPLATE_*` names, real SMTP and R2 credentials among them, and
  `cmd/dubplate-server/restore_test.go:38` and `backup_test.go:81` pass `os.Environ()` to the processes they
  start. So every bare `go test` or `go run` either session runs follows `unset ${!DUBPLATE_@}` in the same Bash
  call.

## Move the health checks

Session name `structure-doctor`. Planned at 300 minutes, with the time clause at 600. It waits for nothing. It
builds on Sonnet at high effort. Its paths are sign-in and data paths under the `dubplate-build` skill's risk map,
so it works test-first and may not defer a gate.

The design is the `structure-doctor` section of
`/var/home/glw907/Projects/initiatives/dubplate-server/specs/2026-11-17-structure-design.md`, with its sections
"The end shape", "Calls made here", and "Proof that nothing changed". The proof kit and its README are in
`/var/home/glw907/Projects/initiatives/dubplate-server/plans/2026-11-17-structure/`. That design counted the code
before the first two moves. Where a number differs, this page's number holds.

The slowest task of this kind took 245 measured minutes (the `engine` rewrite, pull request #17). The two
earlier structure moves took 142 and 110. I plan 300: the 245, plus 55 for gates that queue behind the other
session.

Reviewers: `standards:diff-reviewer` and `standards:web-auth-security-reviewer` on the whole branch, one fresh
`standards:go-architecture-reader` on `cmd/dubplate-server` and one on `internal/id`, each on Opus at high, and the
`go-conventions` skill for every Go file.

In the table, "start" is the commit the worktree starts from, and "today" is `fff37fe`. The block after the table
holds each command the table names.

| Done item | Check | Today, and when it holds |
| --- | --- | --- |
| What a person sees is unchanged | `structure-proof.sh` on the base and head binaries the block below builds | Today the last line is `everything: lines=2510 sha256=7b996b43…`, the same on two runs. Holds when both binaries print the same seven lines. |
| Every setting's declaration is unchanged | The kit's registry dump test as its README gives it, run after the `unset` at start and at head | Today `registry dump: 56 lines, sha256 b8a59fba…`. The same at head. |
| The task stayed in its files | `git diff --name-only <start>..HEAD` | Lists no file outside this task's list under "Files". |
| The migration files are unchanged | `(cd internal/store/migrations && sha256sum -- *.sql) \| sha256sum` | Six files, `ffc4e9db…`. The same at head. |
| No test was dropped | The test-name list at start and at head, compared with `comm -23` | 1,924 names today. Each name gone at head is in the pull request with what it tested. |
| The command folder works out no status | `grep -rnE 'status string, failed bool' --include=*.go cmd \| grep -v _test.go` | 12 lines today: the 11 status functions and `storeRow` at `cmd/dubplate-server/store.go:33`, whose results begin the same way. 0 to pass. |
| The table's install logic has left the folder | `grep -rnE '^func (\([^)]*\) )?[A-Za-z]*nidecode[A-Za-z]*\(' --include=*.go cmd/dubplate-server`, leaving out tests | 11 functions today. 3 to pass: `newUnidecodeCmd`, `newUnidecodeInstallCmd`, and `runUnidecodeInstall`. |
| The backup hook is gone | `grep -rn bindBackup --include=*.go internal cmd`, leaving out tests, and `grep -rnE '\br\.[a-zA-Z]+ = func' internal/ops/local/*_test.go` | 4 lines and 1 line today. 0 and 0 to pass. |
| No folder variable exists for tests to overwrite | The variable search | Prints five names today: `featuresProbeTimeout`, `geteuid`, `operatorVerbWriteWait`, `osUserLookupID`, `unidecodeClient`. Nothing to pass. |
| The administrator's address is parsed in one place | `grep -rn 'mail\.ParseAddress' --include=*.go cmd internal`, leaving out tests | 4 lines today, one at `cmd/dubplate-server/store.go:58`. 3 to pass, none under `cmd`. |
| The moved probe reads no clock | The clock check | Today the test prints `--- PASS: TestNothingReadsTheClock`, the second search prints nothing, and the third prints line 356. Holds when the test passes, the second search prints a line, and the third prints nothing, or the file is gone. |
| The two probe tests can't hang (#144) | The probe-test run | Today it exits 1 with `panic: test timed out after 45s`. Holds when the log holds two `--- PASS` lines and no `test timed out` line. |
| The two probe tests hold their port (#143) | `grep -rn 'freePort(' --include=*.go cmd internal`, and the 20-run | 3 lines today, and the 20 runs pass. Holds when the search prints nothing and the log holds 40 `--- PASS` lines. |
| No comment names the settings' old home (#172) | `grep -rn 'cmd/dubplate-server/auth.go' --include=*.go cmd internal` | 3 lines today. 0 to pass. |
| The repo's rules state where a health check lives | `grep -n -i 'health check' CLAUDE.md` | Prints nothing today. Holds when it prints the design's rule 4, between the rules for an id and for the time. |
| The folder's size is reported | `ls cmd/dubplate-server/*.go \| grep -v _test.go \| xargs cat \| wc -l` | 3,774 today. The design's mark is under 3,000. It is a result of the moves and never a target, so at 3,000 or more the pull request gives the count for each file. |
| The packages read well | The two architecture reads | "Sound with nits" or better on each. `internal/id` is graded, and edited only for a finding of its read. |
| The merge gate passes | `bash scripts/gate.sh --merge`, as `dubplate-build` "Gate" and "Full-suite home" give it | Exits 0 on the final commit. |
| The review accepts | The two whole-branch reviews | Each returns accept for the final commit. |
| CI is green and the pull request is ready | `gh pr checks <n>`, as `dubplate-build` "CI watch" gives it | Every check passes. The body carries this task's backlog edits from "Backlog verdicts", word for word. |

```bash
# Each Bash call that runs go test or go run starts with this line
unset ${!DUBPLATE_@}

# The two trees and binaries, outside the worktree. T holds for one Bash call, so note its path.
T=$(mktemp -d)
mkdir "$T/base" "$T/head"
git archive <start> | tar -x -C "$T/base"
git archive HEAD | tar -x -C "$T/head"
(cd "$T/base" && go build -o "$T/dubplate-base" ./cmd/dubplate-server)
(cd "$T/head" && go build -o "$T/dubplate-head" ./cmd/dubplate-server)

# The test-name list
grep -rhoE '^func (Test|Fuzz|Benchmark|Example)[A-Za-z0-9_]*' --include=*_test.go cmd internal | sort

# The variable search: each package variable a test in the folder assigns
for v in $(go doc -cmd -u -all ./cmd/dubplate-server | awk '/^VARIABLES/{f=1;next} /^(FUNCTIONS|TYPES)/{f=0} f && /^var /{print $2}'); do
  grep -qE "^[[:space:]]*$v[[:space:]]*=[^=]" cmd/dubplate-server/*_test.go && echo "$v"
done

# The clock check
go test ./internal/harness/conform -run '^TestNothingReadsTheClock$' -count=1 -v
grep -rn '\.Deadline()' --include=*.go internal/serve | grep -v _test.go
grep -nE 'time\.(Now|Since|Until)' cmd/dubplate-server/doctorprobe.go 2>/dev/null

# The probe-test run, in the head tree, whose web/build holds only the placeholder
(cd "$T/head" && go test ./cmd/dubplate-server -run 'TestDoctorBoundaryProbe_(TrustedLoopback)?EndToEnd$' \
  -count=1 -timeout 45s -v) > "$T/probe.log" 2>&1
grep -c '^--- PASS' "$T/probe.log"

# The 20-run, in the worktree
go test ./cmd/dubplate-server -run 'TestDoctorBoundaryProbe_(TrustedLoopback)?EndToEnd$' -count=20 -v \
  > "$T/probe20.log" 2>&1
grep -c '^--- PASS' "$T/probe20.log"
```

The eleven status functions move like this. Each lands in a `doctor.go` in its package, and the `doctor` command
keeps the row names, their order, and the printing.

| Function today | File today | Package |
| --- | --- | --- |
| `storeRowStatus`, with `storeRow` | `store.go` | `internal/store` |
| `authStoreRowStatus`, `membersRowStatus`, with `adminEmailRowStatus` | `doctor.go` | `internal/auth` |
| `backupRemoteRowStatus`, `backupFeaturesStatus` | `backup.go` | `internal/backup` |
| `clientIPRowStatus`, `bindAddrsRowStatus`, `boundaryProbeRowStatus` | `doctorprobe.go` | `internal/serve` |
| `webRowStatus` | `doctorprobe.go` | `internal/webapp` |
| `musicVolumeRowStatus` | `doctor.go` | `internal/intake` |
| `unidecodeRowStatus` | `unidecode.go` | `internal/engine/matcher/unidecode` |

The builder also holds to these:

- Start every Bash call that runs `go test` or `go run` with `unset ${!DUBPLATE_@}`, and start each
  `bash scripts/gate.sh` call the same way, since this branch's `scripts/check.sh` lacks #176's unset.
- Fix the two probe tests first. They are `TestDoctorBoundaryProbe_EndToEnd` and
  `TestDoctorBoundaryProbe_TrustedLoopbackEndToEnd`, at `cmd/dubplate-server/doctorprobe_test.go:386` and `:742`.
  They run the `serve` verb, so they stay in `cmd/dubplate-server`. The cause of #144: each poll loop's early exit
  reads `served` (`:422` and `:775`), so the cleanup's `<-served` (`:400` and `:754`; the backlog cites the
  first as `:398`) blocks forever after that `Fatalf`. Keep the error the loop received and skip the cleanup's
  read. For #143, hold the listener that picks the port instead of releasing it.
- Then move one package for each commit and rerun the proof kit after each, as the design says. Each status
  function keeps its sentence to the letter. Add no row type, no list of checks outside the command, and no
  `doctor` package.
- The install logic moves into `internal/engine/matcher/unidecode`. Three functions stay in the command:
  `newUnidecodeCmd`, `newUnidecodeInstallCmd`, and `runUnidecodeInstall`, which keeps only the read of
  `DUBPLATE_STATE_DIR` and passes the state folder in. The engine gains no import of the settings packages.
- The five package variables become fields:
  - `featuresProbeTimeout`: a field of the remote probe's options in `internal/backup`, which the command fills
    with 10 seconds.
  - `geteuid`: a field of the options of `internal/auth`'s store check and of the table installer, each
    filled with `os.Geteuid` by the command.
  - `unidecodeClient`: a field of the table installer's options, filled by the command with a client whose
    timeout is 30 seconds.
  - `operatorVerbWriteWait` and `osUserLookupID`: they stay in the command, as fields of one struct that the
    member and settings verbs are built from. `main.go` fills it with 30 seconds and `user.LookupId`, and a test
    builds the verbs with values of its choosing.
- The boundary probe's client in `internal/serve` takes its deadline from its context. The caller bounds the
  context with `context.WithTimeout(ctx, probeResponseBound)`, and the client calls `ctx.Deadline()` and passes
  the result to `conn.SetDeadline`. That reads no clock: the check refuses only `time.Now`, `time.Since`, and
  `time.Until` (`internal/harness/conform/arch_test.go:71`), and `TestNothingReadsTheClock` walks every non-test
  file under `internal` but the harness, so it covers `internal/serve`. The pattern is assembled from
  `go doc context.Context`, "Deadline returns the time when work done on behalf of this context should be
  canceled", and `go doc net.Conn`, "A deadline is an absolute time after which I/O operations fail instead of
  blocking." The timeout's length doesn't change.
- Code that moves into `backup`, `store`, or `webapp` comes under the gate's wide search for citations, which
  this task can't change. Rewrite the three at `cmd/dubplate-server/backup.go:283`, `:292`, and `:294` as they
  move.
- For the administrator's address, export the parse that `internal/config/config.go:254-267` holds and call it.
  Before the copy goes, a test pins that both give the same answer for addresses the copy accepts and for
  addresses it refuses, with case included. Don't read the loaded value instead: the store row prints even when
  another setting fails to load.
- In `internal/config/keys.go` change the comment at line 68 and no declaration. The comment at
  `scripts/deploy.sh:303-311` names `unidecodeLeafPerm` and `checkUnidecodeOwner` in
  `cmd/dubplate-server/unidecode.go`, and follows the two to their new file.
- Add design rule 4 to `CLAUDE.md` once it is true, in "Facts agents get wrong", between the rule for an id
  (line 166) and the rule for the time (line 168), in the words of the design: "A health check lives in the
  package that knows the fact, in its `doctor.go`. The `doctor` command gains one line that places the row."
- Record each new test failing at the start commit in the pull request. For the searches, the "today" column is
  that record.
- An architecture finding that asks for a change in behavior goes in the pull request and isn't built.

<details>
<summary>Launch command for this task</summary>

```bash
cd /var/home/glw907/Projects/dubplate
claude --bg --name structure-doctor --model sonnet --effort high --permission-mode auto \
  --settings '{"permissions":{"denyInsteadOfPrompting":true},"worktree":{"baseRef":"fresh"}}' \
  "$(cat <<'GOAL'
/goal Build the task "Move the health checks" of the spec at /var/home/glw907/Projects/initiatives/dubplate-server/specs/2026-11-22-overnight-design.md in the dubplate repo, under the building-from-specs and dubplate-build skills. Before the first edit, read that section, "Files", "What goes wrong", and "Calls I made", then the approved design the section names. Every go test, go run, and gate call runs after unset ${!DUBPLATE_@} in the same Bash call. The task is done when all of these hold on the branch's final commit and the pull request quotes each check's output: (1) structure-proof.sh prints the same seven lines for a binary built from git archive of the start commit and one built from git archive of HEAD; (2) the registry dump line is the same at both; (3) git diff --name-only from the start commit lists no file outside this task's list in "Files"; (4) the six migration files hash the same; (5) every test name present at the start is present at head or is listed in the pull request with what it tested; (6) no non-test file under cmd holds a function whose results begin "status string, failed bool"; (7) cmd/dubplate-server holds three non-test functions named for the unidecode table: newUnidecodeCmd, newUnidecodeInstallCmd, and runUnidecodeInstall; (8) bindBackup is gone and no test in internal/ops/local assigns a function to a runner field; (9) the spec's variable search prints no name; (10) mail.ParseAddress has three non-test call sites, none under cmd; (11) TestNothingReadsTheClock prints its --- PASS line, a non-test file in internal/serve calls Deadline() on the probe's context, and cmd/dubplate-server/doctorprobe.go is gone or reads no clock; (12) the spec's probe-test run of the two TestDoctorBoundaryProbe end-to-end tests, in a tree whose web/build holds only the placeholder, prints two --- PASS lines and no "test timed out" line; (13) freePort is gone and the spec's 20-run prints 40 --- PASS lines; (14) no Go file names cmd/dubplate-server/auth.go; (15) CLAUDE.md states the design's rule 4, between the rules for an id and for the time; (16) the pull request gives the non-test line count of cmd/dubplate-server, with a count per file when it is 3,000 or more; (17) a fresh standards:go-architecture-reader grades cmd/dubplate-server and internal/id "sound with nits" or better; (18) bash scripts/gate.sh --merge exits 0; (19) standards:diff-reviewer and standards:web-auth-security-reviewer each accept the whole branch at its final commit; (20) every CI check on the pull request passes, the pull request is marked ready, and its body carries this task's backlog edits from the spec's "Backlog verdicts", word for word; or stop after 600 minutes.
GOAL
)"
```

</details>

## Fix the gate's friction

Session name `dev-friction`. Planned at 240 minutes, with the time clause at 480. It waits for nothing. It builds
on Sonnet at high effort. Its files are gate scripts, pins, and two store tests. The store's driver is on the data
path, so `standards:web-auth-security-reviewer` reads it.

Two gate tasks took 80 and 108 measured minutes: pull request #12, a pass over the gate and its docs, and #13, a
rework of the gate. Two small fixes took 32 and 14 (#22 and #20). I plan 240: 108 for the driver and its survey,
100 for the four small fixes, and 32 for gates that queue.

Reviewers: `standards:diff-reviewer` on the whole branch, `standards:web-auth-security-reviewer` on the driver
bump and the store tests, each on Opus at high, and the `go-conventions` skill for the Go files.

| Done item | Check | Today, and when it holds |
| --- | --- | --- |
| The store's driver is at the probed version (#129) | `grep -nE 'modernc.org/(sqlite\|libc) ' go.mod` | Today `modernc.org/sqlite v1.60.1` and `modernc.org/libc v1.77.1`. Holds at `v1.63.0` and `v1.80.1`. |
| The deadline test states what the new driver does | After the `unset`, `go test ./internal/store -run TestUpdateDeadline -count=1 -v` | On `v1.63.0` today: `write_test.go:601: operation returned before the 400ms deadline` and `write_test.go:605: update: begin write: context deadline exceeded, want ErrBusy`. Holds when it passes and the rewritten case holds the assertion below. |
| The busy-timeout test passes under load (#133) | The load run | Printed 33 and 26 today, each of 48. Holds when two runs each print `0`, and the pull request quotes both counts. |
| Two lint runs wait for each other (#105) | `grep -n -A1 '^run:' .golangci.yml`, the two-run check, and `golangci-lint config verify` | Today the search prints nothing and one run ends `Error: parallel golangci-lint is running`, exit 3. Holds when the search prints `allow-serial-runners: true` under `run:`, both runs print `0 issues.`, and the verify exits 0. |
| The gate drops the workstation's setting names (#176) | The trace check | Prints 0 today. 1 or more to pass, and the dry run still exits 0. |
| The certificate bundle is current (#175) | `grep -n '^certifi==' tools/venv/requirements.txt` and `git diff --stat <start>..HEAD -- tools/venv` | Today `5:certifi==2026.7.22`. Holds at `2026.11.20` or newer, with one line changed in one file. |
| The bumps have their survey | `ls docs/research/*-dependency-sweep.md` | The newest today is dated 2026-10-12. Holds when one dated on the build day covers both bumps, in the form of `docs/research/2026-10-12-dependency-sweep.md`. |
| The task stayed in its files | `git diff --name-only <start>..HEAD` | Lists no file outside this task's list under "Files". |
| The merge gate passes | `bash scripts/gate.sh --merge`, as `dubplate-build` "Gate" and "Full-suite home" give it | Exits 0 on the final commit. |
| The review accepts | The two reviews | Each returns accept for the final commit. |
| CI is green and the pull request is ready | `gh pr checks <n>`, as `dubplate-build` "CI watch" gives it | Every check passes, the race detector's step among them. The body carries this task's backlog edits from "Backlog verdicts", word for word. |

```bash
# Each Bash call that runs go test or go run starts with this line
unset ${!DUBPLATE_@}
T=$(mktemp -d)

# Before the load run and the two-run check: exits 0 only when no heavy gate holds the machine
flock -n "/tmp/cairn-gate-$(id -u)/machine.lock" true

# The load run
go test -c -o "$T/store.test" ./internal/store
seq 48 | xargs -P 48 -I{} sh -c '"$0" -test.run "^TestBusyTimeout\$" -test.count=15 >/dev/null 2>&1 || echo fail' "$T/store.test" | wc -l

# The two-run check: two lint runs at once, each with an empty cache
for n in a b; do (GOLANGCI_LINT_CACHE="$(mktemp -d)" golangci-lint run ./... > "$T/lint-$n.log" 2>&1; echo "run $n exit $?" >> "$T/lint-$n.log") & done; wait

# The trace check
env -i PATH="$PATH" HOME="$HOME" DUBPLATE_NOT_A_SETTING=1 bash -x scripts/check.sh --dry-run 2>&1 | grep -c 'unset .*DUBPLATE_NOT_A_SETTING'

# The certificate bundle, after the venv is built as tools/venv/README.md says
uv pip compile --python tools/venv/.venv/bin/python tools/venv/requirements.in -o tools/venv/requirements.txt --upgrade-package certifi
```

The rewritten case of `TestUpdateDeadline`, in place of "shorter than the busy timeout waits the busy timeout",
asserts both bounds this way. `assertNotBefore` checks only the lower one.

```go
done := make(chan error, 1)
go func() {
	done <- h.Update(deadline(t, 100*time.Millisecond), func(context.Context, *Tx) error { return nil })
}()
timer := time.NewTimer(busy)
defer timer.Stop()
select {
case err = <-done:
case <-timer.C:
	t.Errorf("update still waiting at the %s busy timeout, want it ended by its 100ms deadline", busy)
	err = <-done
}
if !errors.Is(err, context.DeadlineExceeded) {
	t.Errorf("update: %v, want context.DeadlineExceeded", err)
}
```

The builder also holds to these:

- Start every Bash call that runs `go test` or `go run` with `unset ${!DUBPLATE_@}`.
- Take the driver first, through the "one package" mode of `standards:dependency-upgrade`, with no sweep of every
  outdated module. This task makes two pins: `modernc.org/sqlite v1.63.0`, with the `modernc.org/libc v1.80.1`
  its `go.mod` names, and `certifi`. The driver is the least proven step. Its commit carries the rewritten case
  and the corrected comment at `internal/store/write.go:51-54`, so that no commit is red.
- `check.sh` classes `go.mod`, `go.sum`, `.golangci.yml`, and itself as gate machinery
  (`scripts/check.sh:94-95`), so a scoped run that sees one of them runs full. Make those three changes first, the
  driver, the lint key, and the unset, then pass `--base` the commit that ends them, as `dubplate-build`
  "Fast lane" says.
- On the new driver a write returns the context's error once its deadline passes while it waits on a lock. Keep
  that error. No caller changes: `internal/intake/seam.go:130` and `internal/ops/admin/admin.go:121` already
  answer a busy store and a passed deadline with the same words. The operator verbs (`member.go:99`, `:166`, and
  `:202`, and `settings.go:45`, in `cmd/dubplate-server`) print the raw error under a 30-second deadline, so with
  a busy timeout over 30 seconds an operator now sees "context deadline exceeded". The pull request says so.
- The survey reads the release notes from `v1.60.1` to `v1.63.0` against the eight files that import the driver,
  the change to `Tx.Commit` in `v1.61.1` among them. The pull request flags the bump for Geoff as data work.
- If the bump fails a test outside this task's files, take the bump back out with the rewritten case and the
  `write.go` comment, mark its two items unmet with the failure, and finish the rest.
- For the busy-timeout test, release the holder on a signal, and give each case a separate database or roll back
  in a cleanup. The load run printed 33 and 26 of 48 today, and the failure is
  `conn_test.go:400: operation returned before the 300ms deadline`, from the helper `assertNotBefore` racing a
  timer against the operation. Fix the helper for all its callers. The helper can't read the clock:
  `TestEngineNeverReadsTheClock` refuses `time.Now`, `time.Since`, and `time.Until` in every file under
  `internal/store`, tests included. One measure that reads none: when the operation returns first,
  `timer.Stop()` tells whether the timer had already expired (`go doc time.Timer.Stop`: "It returns true if the
  call stops the timer, false if the timer has already expired or been stopped.").
- `allow-serial-runners: true` goes under a `run:` key in `.golangci.yml`. `golangci-lint config verify` 2.15
  rejects it at the top level.
- The line `unset ${!DUBPLATE_@}` goes in `scripts/check.sh` directly after `set -euo pipefail` (line 2), before
  the script reads its flags.
- The certificate bundle holds TLS roots only, so it needs no `make derive`.

<details>
<summary>Launch command for this task</summary>

```bash
cd /var/home/glw907/Projects/dubplate
claude --bg --name dev-friction --model sonnet --effort high --permission-mode auto \
  --settings '{"permissions":{"denyInsteadOfPrompting":true},"worktree":{"baseRef":"fresh"}}' \
  "$(cat <<'GOAL'
/goal Build the task "Fix the gate's friction" of the spec at /var/home/glw907/Projects/initiatives/dubplate-server/specs/2026-11-22-overnight-design.md in the dubplate repo, under the building-from-specs and dubplate-build skills. Before the first edit, read that section, "Files", "What goes wrong", and "Calls I made". Every go test and go run runs after unset ${!DUBPLATE_@} in the same Bash call. The task is done when all of these hold on the branch's final commit and the pull request quotes each check's output: (1) go.mod names modernc.org/sqlite v1.63.0 and modernc.org/libc v1.80.1; (2) TestUpdateDeadline passes, and its rewritten case asserts, as the spec's Go block gives it, that a write whose deadline passes while it waits on a lock returns an error matching context.DeadlineExceeded before the busy timeout; (3) the spec's load run of TestBusyTimeout, 48 at once with 15 counts each, prints 0 on two runs; (4) .golangci.yml sets allow-serial-runners: true under run:, two lint runs started together with empty caches both print "0 issues.", and golangci-lint config verify exits 0; (5) the spec's trace check of scripts/check.sh --dry-run prints 1 or more and the dry run exits 0; (6) tools/venv/requirements.txt pins certifi at 2026.11.20 or newer with no other line changed; (7) a dependency survey dated on the build day under docs/research covers both bumps, in the form of the 2026-10-12 survey; (8) git diff --name-only from the start commit lists no file outside this task's list in "Files"; (9) bash scripts/gate.sh --merge exits 0; (10) standards:diff-reviewer accepts the whole branch and standards:web-auth-security-reviewer accepts the driver bump and the store tests, at the final commit; (11) every CI check on the pull request passes, the pull request is marked ready, and its body carries this task's backlog edits from the spec's "Backlog verdicts", word for word; or stop after 480 minutes.
GOAL
)"
```

</details>

## Files

The health-check task changes these and no others:

- `cmd/dubplate-server/**`
- A new `doctor.go` and its test in `internal/auth`, `internal/backup`, `internal/serve`, `internal/store`,
  `internal/webapp`, and `internal/intake`, and the rest of `internal/serve/**`
- `internal/engine/matcher/unidecode/**`
- `internal/ops/local/local.go` and `internal/ops/local/helpers_test.go`
- `internal/config/config.go` with one test file beside it, and comments in `internal/config/keys.go` and
  `internal/config/keys_test.go`
- `internal/id/**`, only for a finding of the architecture read
- One comment in `scripts/deploy.sh`, and one rule in `CLAUDE.md`

The gate-friction task changes these and no others:

- `go.mod` and `go.sum`
- `internal/store/conn_test.go`, `internal/store/write_test.go`, and `internal/store/write.go`
- `.golangci.yml`, `scripts/check.sh`, and `tools/venv/requirements.txt`
- One new `docs/research/<date>-dependency-sweep.md`

Both tasks change files in the package `internal/store`, but no file is on both lists.

<details>
<summary>The searches behind the two lists</summary>

Each ran in `/var/home/glw907/Projects/dubplate` at `fff37fe`.

1. The names that move:
   `grep -rlwE 'backupRemoteRowStatus|backupFeaturesStatus|unidecodeRowStatus|musicVolumeRowStatus|membersRowStatus|authStoreRowStatus|storeRowStatus|clientIPRowStatus|webRowStatus|bindAddrsRowStatus|boundaryProbeRowStatus|featuresProbeTimeout|geteuid|operatorVerbWriteWait|osUserLookupID|unidecodeClient|adminAddress|bindBackup|freePort|checkDirWritable|probeResponseBound' --include=*.go cmd internal`.
   22 files. 16 are in `cmd/dubplate-server` and change. `internal/ops/local/local.go` and `helpers_test.go`
   change. `internal/store/inspect.go`, `leaf.go`, `leaf_test.go`, and `open.go` are dismissed: they hold a
   `geteuid` that belongs to the store and stays.
2. The install logic's callers:
   `grep -rlE 'newUnidecodeCmd|installUnidecode|checkUnidecodeOwner|unidecodeLeafPerm' --include=*.go --include=*.sh cmd internal scripts`.
   4 files. `cmd/dubplate-server/main.go`, `unidecode.go`, and `unidecode_test.go` change, and `scripts/deploy.sh`
   changes one comment.
3. The stale comments: `grep -rn 'cmd/dubplate-server/auth.go' --include=*.go cmd internal`. 3 lines, at
   `internal/config/config.go:12`, `keys.go:68`, and `keys_test.go:41`. All change.
4. The files that import the driver: `grep -rl 'modernc.org/sqlite' --include=*.go .`. 8 files, all in
   `internal/store`. `write_test.go`, `conn_test.go`, and `write.go` change. `conn.go`, `driver_test.go`,
   `migrate.go`, `migrate_test.go`, and `open.go` only build against the new version.
5. The timing helper: `grep -rn 'assertNotBefore' --include=*.go cmd internal`. 5 lines, 4 in
   `internal/store/conn_test.go` and 1 in `write_test.go`. All are in the gate-friction task's files.
6. The certificate pin: `grep -rn 'certifi'` over the repo's text, script, and Go files. 6 lines.
   `tools/venv/requirements.txt:5` changes. The other 5 are the word "certificate" in `internal/notify` and are
   dismissed.
7. The setting names in the gate: `grep -n 'DUBPLATE_' scripts/check.sh scripts/gate.sh Makefile .github/workflows/*.yml`.
   1 line, a comment at `scripts/check.sh:736`. No gate script reads one of the names, so the unset is new text.

</details>

## What goes wrong

| What happens | The number | What the session does |
| --- | --- | --- |
| A task runs long | No new step after 480 minutes for the health checks and 380 for the gate fixes. The time clauses are 600 and 480 | Past its cutoff it starts no step. A fix verdict that arrives after the cutoff goes under `## For Geoff`. At the time clause it commits, pushes, writes what is left in its draft pull request, and ends. |
| Both worktrees lint at once | Exit 3, `Error: parallel golangci-lint is running`, until #105 is in `master` | It runs the gate again. This is no fault in its code. |
| Both gates want the machine | One heavy gate at a time. A full gate takes 28.5 minutes at the median, and past pull requests lost 7 minutes each to the lock | It issues the gate again on exit 75, as `dubplate-build` "Gate" says. Only the gate-friction task may defer. |
| One session's load slows the other's tests | The load run starts 48 processes, and each lint run in the two-run check starts with an empty cache | The gate-friction task runs those two only when the `flock -n` line exits 0. A session whose gate fails on `TestBusyTimeout` reruns that gate once. |
| CI on the health-check branch fails on the known flake | `TestBusyTimeout`, `database is locked`, until #133's fix is in `master` | It reruns the failed job once with `gh run rerun <id> --failed`, and quotes the flake in the pull request. It never edits the other task's files. |
| The gate reprints an old result | It does so whenever no tracked file changed | After changing only untracked files, it runs `bash scripts/gate.sh --fresh`. |
| A new worktree fails its first gate | `make web: web/node_modules absent` | It follows `dubplate-build` "Worktree setup" before the first gate. |
| A probe test hangs | 10 minutes in the gate's `go test ./...`, Go's default, and 45 seconds in this page's probe-test run, until #144 is fixed | It passes `-timeout` and lets the run end. It never ends a process itself, which is refused. |
| A test command is piped to `head` or `tail` | A hook refuses it | It sends the output to a file and reads the file. |
| A command is refused | 152 refusals in 22 days, 53 of them `Classifier unavailable`, which pass on a second try | It follows `building-from-specs` "In place of a question". |
| The new driver breaks a test elsewhere | Today the whole Go suite differs by one known test | The gate-friction task takes the bump out and marks its items unmet. |

## Mechanisms and their sources

| Mechanism | Label | Source |
| --- | --- | --- |
| Two sessions, each in a separate worktree from `master` | Documented | `building-from-specs` "Launching a task". Its flags are in `claude --help`, version 2.1.330. |
| Lint runs that wait | Documented | `golangci-lint run --help`, 2.15.0: "Allow multiple golangci-lint instances running, but serialize them around a lock. If false (default) - golangci-lint exits with an error if it fails to acquire file lock on start." |
| A test server on a port it holds | Documented | `go doc net.Listen`: "a port number is automatically chosen." |
| Unsetting names by prefix | Documented | `man bash`, `${!prefix@}`: "Expands to the names of variables whose names begin with prefix". Run with one such name set, it printed `+ unset DUBPLATE_NOT_A_SETTING` and then counted 0 left. |
| One pin raised in a compiled list | Documented | `uv pip compile --help`: "Allow upgrades for a specific package, ignoring pinned versions in any existing output file." Rehearsed in a copy, it changed line 5 alone, to `certifi==2026.11.20`. |
| The driver bump | Documented | `standards:dependency-upgrade` owns the steps. Probed: in two fresh copies, `go test ./... -count=1` at `v1.60.1` and at `v1.63.0` with `modernc.org/libc v1.80.1` gave failure lists that differ by `TestUpdateDeadline/shorter_than_the_busy_timeout_waits_the_busy_timeout` alone. |
| The busy-timeout test's fix | Assembled | The load run in that task's section, and CI run 43815685425, where both of its cases got `database is locked` at `BeginTx`. |

## Commands and the refusal log

I read each task's commands against `/var/home/glw907/.local/state/claude-denials.jsonl`. It holds 152 rows, the
first dated 2026-11-01 and the last 2026-11-23. No row refuses the gate, `go build`, `go get`, `go mod`,
`golangci-lint`, `git archive`, `uv`, or the proof kit. The rows a task could meet refuse four things: a scripted
rewrite inside another session's worktree, ending a gate or test process, a download chained to another command,
and a push to the default branch or a merge. A task edits only the worktree it was given, lets a hung test end by
its timeout, pushes only the branch it made, and never merges.

## The morning

1. Approve the gate-friction pull request by number. It goes first because it is the smaller read, and every
   later worktree wants its lint and gate fixes.
2. Approve the health-check pull request by number. You can do both in one sitting.
3. The session you are talking to merges the first. It then runs `gh pr update-branch` on the second, waits for
   CI on the result, and merges it when CI is green. The second needs no rebase by hand, because no file is on
   both lists. It does need that one CI run, which is the first to try the moved checks on the new driver. If that
   run is red, the session doesn't merge. It tells you, and on your word it launches a fresh session on that
   branch with the failure in its goal.
4. The same session makes the backlog edits each pull request lists, and updates `docs/STATUS.md`.

If one pull request goes back, the other still merges.

## Calls I made

- Two tasks at once from `master`, with their pull requests waiting for one sitting. A series would stall at
  the first merge.
- Both tasks build on Sonnet at high effort, and their reviewers run on Opus at high. You said on 2026-11-22: "I
  can execute with something lighter."
- No task session edits `BACKLOG.md`. Closed items move to the top of its "Done" section, so two branches would
  conflict there. Each pull request carries its backlog edits as the exact text under "Backlog verdicts", and a
  new item a session finds goes in its pull request too.
- No task session edits `docs/STATUS.md`.
- The gate fixes merge first.
- #152 stays out. Its fix is read through `cmd/dubplate-server/rendered_test.go`, in the other task's folder.
- #129 is in, pinned at `v1.63.0`, the version I probed and verified today, and not the newest on the build day.
  The backlog names `v1.62.1`, which doesn't exist. `v1.63.0` came out on 2026-11-22.
- A write that passes its deadline while waiting on a lock keeps the context's error. Mapping it to the busy
  error would hide which limit ended the wait.
- The certificate bundle goes to the newest version, `2026.11.20` today. The backlog names `2026.10.23`.
- #133's fix also covers the helper `assertNotBefore`, which caused today's failures under load.
- #176 is fixed in `scripts/check.sh` alone. A bare `go test` outside the gate still passes the names on, and
  two of the four tests that do it are in the other task's folder tonight.
- The search for the install logic covers `cmd/dubplate-server`. The design's covered all of `cmd` and counted
  two functions in `cmd/harness`, which this move leaves alone.
- The search for status functions matches `status string, failed bool` without the parentheses, so it also
  catches `storeRow`, whose results continue past those two.
- The health-check task exports one function from `internal/config/config.go` and adds its test. The design's
  file list names that file.
- The comment at `internal/config/keys.go:68` changes. The repo's rule against editing that file protects its
  declarations.
- The repeated reads of the store's wait setting in the command folder stay in #124. The design's backlog table
  counted them in this round, and its `structure-doctor` section never names them.
- Pull request #23, from Dependabot, stays as it is. It changes two workflow files and collides with neither task.
- The minutes: 300 and 240.

## Backlog verdicts

The scoped sweep read 36 items against `fff37fe`. Approving this page approves these edits.

| Item | Verdict | What changes |
| --- | --- | --- |
| #173, #143, #144, #147, #172 | Fold into the health-check task | Each closes. |
| #123 | Fold in part | The backup hook leaves the item. The rest stays. |
| #124 | Fold in part | The probes and the install logic leave the item. One shape for the commands' wiring stays, and the repeated reads of the store's wait setting are added to its text. |
| #156 | Fold in part | The three citations in `cmd/dubplate-server/backup.go` leave the item. The other sites stay. |
| #105, #133, #175 | Fold into the gate-friction task | Each closes. |
| #129 | Fold into the gate-friction task | It closes, at `v1.63.0`. |
| #176 | Fold in part | The gate's unset leaves the item. What stays: a bare `go test` still passes the names to child commands. |
| #18, #63, #66, #96 | Reword | The new text is below. |
| #15, #73, #88, #125, #137, #140, #166 | Keep | The line numbers each cites are corrected. |
| #37, #38, #74, #89, #106, #107, #130, #132, #149, #152, #158, #159 | Keep | Nothing but the sweep's date. |

<details>
<summary>The four reworded items</summary>

- #18: "The members add form's username `pattern` (`web/src/routes/members/+page.svelte:354`) has no row that
  trips it in the browser. `run.ts` covers the server's `duplicate_username`, `missing_username`, and
  `invalid_username` refusals and never submits a value the pattern itself refuses. Add one row that types such
  a name and asserts the browser's validity message and that no request leaves."
- #63: "The serve unit ships no failure alert. `d1e93e9` dropped the estate-only `OnFailure=` line, and
  `docs/server-runbook.md:42-44` still tells an operator to delete a line that is no longer there. Ship a
  generic, opt-in failure hook with packaging (#98), and correct the runbook paragraph."
- #66: "Three test binaries install the transliterator through a `TestMain` shim (`internal/engine/matcher`,
  `internal/engine/tag`, and `internal/harness/conform`) instead of production wiring. Retire the shims when #24
  gives the transliterator a production installer."
- #96, one clause: "`SetTransliterator` (`internal/engine/matcher/translit.go:20`) has no production caller yet
  (#159), so 'installed once' is the target and today's code doesn't do it."

</details>

<details>
<summary>The backlog edits each pull request carries</summary>

The session that merges applies these to `BACKLOG.md`. A closed item leaves `## Open` and goes to the top of
`## Done` in the text given. An item that stays open has its lines in `## Open` replaced by the text given.

The health-check pull request closes five items:

```markdown
- [x] #173 Restart the `structure` milestone's third piece, `structure-doctor`: write a spec under
  `building-from-specs`, scoped from `structure-doctor-planner-prompt.txt` in
  `~/Projects/initiatives/dubplate-server/plans/2026-11-17-structure/`. The spec carries #123, #124, #143,
  #144, #147, and #156, less any the reshape's task 3 closes first. Paused 2026-11-20 and resumed only under
  `building-from-specs`. #improvement #arch #milestone:structure (2026-11-22) *(swept 2026-11-22)* *(2026-11-22 → 2026-11-23)*
- [x] #172 Three comments (one in a test) still name `cmd/dubplate-server/auth.go` as the home of the auth settings, which moved to `internal/auth/config.go` in `structure-keys` (PR #19): `internal/config/config.go:12`, `internal/config/keys.go:68`, and `internal/config/keys_test.go:41`. `internal/notify/notify.go:119`'s "(auth.go)" is go-mail's file and stays. #docs (2026-11-20) *(swept 2026-11-22)* *(2026-11-20 → 2026-11-23)*
- [x] #147 One copy of a value parser is left from #118's normalizer copies: `adminAddress` (`cmd/dubplate-server/store.go:299`), `doctor`'s parse of `DUBPLATE_ADMIN_EMAIL`, repeats the `mail.ParseAddress` and lowercase step the config load runs. It reads the one parse instead. Found by `cleanup-store`'s whole-branch review (PR #14) #arch #config *(swept 2026-11-20)* *(2026-11-16 → 2026-11-23)*
- [x] #144 Both serve-backed doctor probe tests (`cmd/dubplate-server/doctorprobe_test.go:398` and `:754`) drain `served` in the poll loop's early-exit case, so the cleanup's `<-served` blocks forever after that `Fatalf` (seen when the web build is missing). Record the received error and skip the cleanup read. Found by `cleanup-store`'s T7 (PR #14) #bug #test *(swept 2026-11-22)* *(2026-11-16 → 2026-11-23)*
- [x] #143 `TestDoctorBoundaryProbe_TrustedLoopbackEndToEnd` failed once in CI and passed on rerun: `freePort` (`cmd/dubplate-server/doctorprobe_test.go:359`) reserves a port then releases it, so the route answered 200 before the store existed and `denyUnidecodeNetwork` fired. Hold the listener or retry on bind. Found by `cleanup-store` (PR #14) #bug #test *(swept 2026-11-22)* *(2026-11-16 → 2026-11-23)*
```

It replaces three items that stay open:

```markdown
- [ ] #123 `auth` and `serve` trims, residue after `cleanup-ops` and the health-check move: `statusCapture` and the
  job runner's backup hook are gone. Still open: surface ahead of a caller, the doubled request check, hand-rolled
  stdlib, and the rest of the smaller items. Findings O3, O8, O9, and O14,
  `docs/research/2026-11-10-whole-repo-review.md`, 2026-11-10 #arch *(swept 2026-11-22)*
- [ ] #124 Move library code out of `cmd/dubplate-server`, residue after the health-check move: the web surface,
  every setting, the probes, and the table install logic have left the command folder. Still open: one cobra
  wiring shape for the commands, and the verbs that read the store's wait setting again with
  `store.BusyTimeout(environ)` after `loadConfig` (`grep -rn 'store.BusyTimeout(environ)' --include=*.go cmd`,
  leaving out tests). Takes #66's doctor items. Findings O11 and O13,
  `docs/research/2026-11-10-whole-repo-review.md`, 2026-11-10 #arch *(swept 2026-11-22)*
- [ ] #156 Process tags in the guarded packages, and `webapp` exports only tests use. Round `engine` (PR #17) cleared
  the engine and harness tags and added a wide citation pattern that skips `cmd/dubplate-server`,
  `internal/serve`, `internal/auth`, and `internal/intake`, which held 53 matching lines on 2026-11-16. Clearing
  them lets the skip go. The health-check move cleared the three in `cmd/dubplate-server/backup.go`. Known sites:
  "(review m5)" at `internal/auth/config.go:99` and `:110` (moved there by `structure-keys`, PR #19, and left as
  written), "(spec:938-944)" at `internal/serve/serve.go:296` and `serve_test.go:74`, "R20" and "R-M" at
  `internal/serve/server_test.go:132`, `:227`, and `freebind_other.go:11`, and "R-5cii12" at
  `cmd/dubplate-server/web_test.go:253` and `:460`. `webapp.StylesheetHrefs` and `ThemeCookieName` have only `cmd`
  test callers outside `internal/webapp`, and `DocumentCSP` one doc link more. Found by `cleanup-ops` T5 and T6,
  2026-11-16 #arch #test *(swept 2026-11-22)*
```

The gate-friction pull request closes four items:

```markdown
- [x] #175 Take certifi 2026.10.23 in `tools/venv/requirements.txt` (pinned 2026.7.22). Dependabot alert #1 (critical, 2026-11-23): the pinned certifi bundles emSign root CAs whose intermediate keys are compromised, first patched in 2026.10.18. TLS roots only, so it needs no `make derive`. Split from #132 by the 2026-11-22 sweep #security #infra (2026-11-22) *(2026-11-22 → 2026-11-23)*
- [x] #133 `TestBusyTimeout` (`internal/store/conn_test.go:364,385`) failed once on a GitHub runner (run 43815685425, head `dd52636`, whose tree equals the green run on `2b9672a`): both subtests got `database is locked (5) (SQLITE_BUSY)` at `BeginTx`. It is timing-dependent and now gates every PR, so it can turn the check red with no code change. Make it wait on a signal, not a clock. Found by `cleanup-ci` (PR #12) #bug #store (2026-11-16) *(swept 2026-11-22)* *(2026-11-16 → 2026-11-23)*
- [x] #129 Take `modernc.org/sqlite` v1.62.0 (held at v1.60.1 with `modernc.org/libc` v1.77.1). `TestUpdateDeadline/shorter_than_the_busy_timeout_waits_the_busy_timeout` fails on every run at `internal/store/write_test.go:601,605` ("operation returned before the 400ms deadline"; "update: begin write: context deadline exceeded, want ErrBusy"): v1.61.0 stops a statement waiting under `busy_timeout` once its context is done and returns the context's error, which reverses the premise of the test's "Measured: SQLite's busy handler does not stop for the driver's interrupt" comment (v1.61.1 does the same for `Tx.Commit`). The bump rewrites that subtest for the new contract, checks what `Update` maps a deadline hit while waiting on a lock to, and takes v1.62.1 (2026-11-13) with the `modernc.org/libc` pin its `go.mod` names. Found by the `cleanup-ci` dependency sweep #bug #infra (2026-11-16) *(swept 2026-11-22)* *(2026-11-16 → 2026-11-23)*
- [x] #105 Add `run: allow-serial-runners: true` to `.golangci.yml`: golangci-lint 2.15.0 exits with an error when another run holds its lock, so two worktrees' gates linting at once fail instead of waiting. The rest of the old item landed in PR #13. Finding G8, `docs/research/2026-11-10-whole-repo-review.md` #gate *(swept 2026-11-22)* *(2026-11-10 → 2026-11-23)*
```

It replaces one item that stays open:

```markdown
- [ ] #176 A bare `go test` outside the gate passes the workstation's `DUBPLATE_*` exports (16 names on
  2026-11-22, among them `DUBPLATE_MAGIC_LINK_SECRET` and `DUBPLATE_SMTP_PASSWORD`) to tests that hand
  `os.Environ()` to child verbs (`cmd/dubplate-server/backup_test.go:81`, `restore_test.go:38`,
  `internal/backup/job_test.go:907`, `internal/ops/local/process_test.go:135`). `scripts/check.sh` unsets every
  such name since 2026-11-23, so the gate no longer passes them. Have each of those tests build its child's
  environment from the names it sets. Found by the 2026-11-22 sweep #test #security (2026-11-22) *(swept 2026-11-22)*
```

</details>
