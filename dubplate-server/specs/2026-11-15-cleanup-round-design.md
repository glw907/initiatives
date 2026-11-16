# dubplate moves to rounds, and the first round clears the review's findings

Initiative: `dubplate-server`. Round: `cleanup`. Repo: dubplate (`glw907/dubplate`, default branch `master`).
Written 2026-11-15 against dubplate `acc4089`. Status: awaiting Geoff's approval.

## Brief

The remaining work to 0.8 is regrouped into eight rounds, and the 17-rung ladder is retired from every
live document. This design is the first of the eight. Round `cleanup` has five passes: PR checks and the
re-shaped planning documents, a faster gate, and the whole-repo review's findings in the store, the web
app, and the ops and auth code. It adds no feature and deploys nothing. Three passes land on their checks
and reviews. The web and ops passes touch sign-in code, so they wait for one close packet at the end.

## Why

The 2026-11-10 review found that the gate took about a third of each feature pass's clock, that the repo
has no PR checks, and that three bugs and a long list of cuts sit in code the next features build on.
Geoff approved that series the same day. Since then the workstation moved to rounds, and dubplate's
ledgers still describe a ladder of rungs, a cap of three passes at once, and a launch prompt for one
pass. A conductor can't run from those documents.

PR checks come first for a reason the probes found. The queue lands a PR when no check fails, and a
dubplate PR has no checks, so today a landing would rest on the executor's local gate alone.

## Decided by Geoff

- "I'd like to organize the next round of development for dubplate", and "I'd like it to be closer to
  completion."
- "We don't need rungs anymore."
- "We should bring dubplate fully into the new round-based method of development." Later: "When we're
  done, I want to have the dubplate planning fully re-shaped for the round-based development pattern."
- "I'm not going to use the tool until it reached the 0.8 make, so rounds can be structured in whatever
  way gets us to that point more efficiently." No round is shaped around an early deploy.
- The beets migrator goes: "yes, use the folder-admit command". An album that fails the gate is reported
  and left out.
- "You can move all three": lifecycle hooks, the `owner-queue` and `contributor-picks` custody policies,
  and smart playlists move to after 0.8. `strict` stays the default policy.
- The review's pass series, approved 2026-11-10 (dubplate `docs/STATUS.md`).

## Goals

1. Every remaining piece of work to 0.8 sits in a named round, and BACKLOG, STATUS, `CLAUDE.md`, the
   standing rules, and the `dubplate-pass` adapter describe rounds and nothing else.
2. A dubplate PR carries a check that runs the gate, so "no check fails" means something.
3. The gate costs less of a pass's clock, and each leg reports its time.
4. The three bugs the review found are fixed, each with a test that fails on the old code.
5. The store, web, and ops code enter the feature rounds without the review's findings.

## Non-goals

- No feature, no schema migration, no new config key, and no deploy. The box is not touched.
- The engine cleanup (matcher, MusicBrainz, tag I/O, the harness). It needs `make derive` and the beets
  venv, which live in the main checkout, so it is round two.
- `deploy.sh`, `provision.sh`, and unit hardening (review findings G9, G10, G13). Nothing can prove them
  without writing to the box, so they go to the launch round.
- The three rulings of BACKLOG #92. They stay the `intake` round's first questions.
- The workstation findings X1 to X6 and the `CLAUDE.md` size budget (#109, #128), which belong to the
  `workstation-refinement` initiative.

## Anti-goals

- A cleanup that changes what a member sees or what the API answers, beyond the changes this design
  names.
- A check that passes in CI by skipping a leg quietly.
- A cut inside the review's "Leave alone" list.
- An edit to a frozen spec or an archived plan to rename a rung. Old documents keep their words.

## Calls made here

These are Claude's calls, made under the method-and-architecture rule. Each is open to a note.

1. **Eight rounds replace the ladder.** The list is under "The rounds to 0.8". Each later round gets
   its design when the round before it closes, and that design sets its passes.
2. **Round one is cut to five passes.** The review named six. The engine cleanup moves to its own round
   because a conductor works in worktrees and that pass can't. The gate work splits in two, so that PR
   checks exist before any other pass lands.
3. **The private deploy of streamer slices 3 and 5 is dropped.** The review proposed it so a track could
   play early. Geoff's ruling removes the need, so the streamer's slices run in whatever order their
   round's design finds cheapest.
4. **Tags.** `#rung:<name>` becomes `#round:<id>`, mapped by the table under "The rounds to 0.8".
   `#pass:<slug>` stays for an item a designed pass has taken.
5. **One bridge table survives.** BACKLOG keeps the table that maps old rung numbers and names to
   rounds, under "Old names", so a reader of a frozen spec can find where its rung went.
6. **The dependency sweep runs once a round**, as the first task of the round's first pass. The adapter
   says so. This answers finding G14, whose trouble was a sweep inside every pass's branch.
7. **CI becomes the full-suite home** once pass 1's workflow is green. The local close keeps one
   `gate.sh --merge` run for the branch-history secret scan.
8. **The uncalled job operations leave the API document too.** `internal/ops/opshttp/openapi.yaml` lists
   three backup-job operations and a catalog operation that no page calls. Production always answers
   "unavailable" for the jobs. Pass 5
   deletes the handlers and the document's entries together, so the document matches the server. They
   return with the first page that starts a job (BACKLOG #52).
9. **The cap of three passes at once goes.** A round runs its passes one at a time.
10. **Settings changes ride the close packet.** Finding G18 asks for allow rules in
    `.claude/settings.json`. No executor edits settings, so the round's close packet carries the rules
    and the merging session adds them on approve.
11. **Pass 3 is `auth-data` and waits.** The builder check found that finding S2 forces changes under
    `cmd/dubplate-server`. Passes 1 and 2 land, and passes 3 to 5 share the close packet.
12. **`doctor.go` moves to pass 3**, so `config.Lookup` and `config.KeyError` are never exported ahead
    of a caller.
13. **The old prompt files are archived, not edited.** Finding G19 says they call a command that is
    gone. Their passes landed, so they move to `docs/archive/plans/` as written.
14. **`deadcode` runs as a Go tool and stays a warning.** A `tool` line in `go.mod` pins it, so the CI
    job needs no new install step. It reports unreachable functions where the awk leg matched names,
    so its findings differ, and gating on them is a later call.
15. **An operator is `local:<user>` in every audit.** The jobs audit already writes that form, and it
    can't be mistaken for a member's address. No store is live, so no stored row changes.
16. **The web surface gets one new package beside `internal/serve`**, as finding O10 asks. Pass 5 names
    it and adds it to the adapter's `auth-data` list.

## Scope

In: the five passes below, in dubplate. The record (this design, the prompts, the round report) lives
in `~/Projects/initiatives/dubplate-server/`.

Out: `_salvage/`, `corpus/`, `tools/`, `internal/engine/{matcher,musicbrainz,tagio,tag}`,
`internal/harness`, `internal/intake`, `internal/subsonic`, `internal/opensubsonic`,
`internal/engine/store/migrations`, `systemd/`, `cloud-init/`, `scripts/deploy.sh`,
`scripts/provision.sh`, `.claude/settings.json`, `~/.dotfiles`, the standards plugin, and `pass-core`.

## How it fails

- **A hosted runner can't carry a leg.** The gate needs xmllint at libxml 2.15.4, the Unidecode wheel,
  the Subsonic XSD, rclone, Playwright's Chromium, and `systemd-analyze`. Standing answer 13 covers a
  leg that can't run there.
- **A cleanup changes behavior.** Each code pass proves "unchanged" with the tests that existed before
  it, which it may delete only where the review names them. The web pass compares all 190 rendered
  captures before and after.
- **A pass outgrows its estimate.** A plan whose path is over twice the pass's figure parks. The round
  starts nothing new past 1,200 minutes.
- **The weekly allowance runs short.** It read 42 percent on 2026-11-15. The conductor reads it before
  each launch and starts nothing at 85 percent or more.
- **A cut removes something a later round wanted.** Every deletion is of code with no production caller
  today, named by finding. Git holds the rest.

## Passes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `cleanup-ci` | PR checks run the gate; the planning documents describe rounds | `.github/workflows/**` (new), `.claude/skills/dubplate-pass/SKILL.md`, `CLAUDE.md`, `docs/standing-rules.md`, `BACKLOG.md`, the four prompt files of landed passes under `docs/plans/` (moved to `docs/archive/plans/`), `go.mod`, `go.sum`, `web/package.json`, `web/package-lock.json` (sweep), and `scripts/check.sh` for the one named input of standing answer 13 | `runner` | 100 | none | 2 (`scripts/check.sh` if CI needs a change there), every pass (`BACKLOG.md`) |
| 2 `cleanup-gate` | The gate reports each leg's time and runs in less of it | `scripts/check.sh`, `scripts/gate.sh`, `scripts/vale-comments.sh`, `Makefile`, `.gitleaks.toml`, `web/scripts/rendered/**`, the rendered Go test, and `go.mod` with `go.sum` for the `deadcode` tool line | `runner` | 130 | 1 | 1 (`scripts/check.sh`, `go.mod`), 4 (`web/scripts/rendered`) |
| 3 `cleanup-store` | The restore bug is fixed and the store and config seams are cut down | `internal/engine/store/**` except `migrations/`, `internal/backup/**`, `internal/settings/**`, `internal/config/**`, `internal/atomicfile/**`, and three `cmd/dubplate-server` files: `serve.go`, `serve_store_test.go`, and `doctor.go` | `auth-data` | 130 | 2 | 5 (`cmd/dubplate-server`) |
| 4 `cleanup-web` | The two admin pages share one shell and one transport | `web/src/**`, and `web/scripts/rendered/**` where an assertion names markup the pass changes | `auth-data` | 100 | 3 | 2 (`web/scripts/rendered`) |
| 5 `cleanup-ops` | The add-member bug is fixed and the ops, auth, and serve code is cut down | `internal/{ops,auth,serve,identity,notify}/**`, `cmd/dubplate-server/**` | `auth-data` | 140 | 3, 4 | 3 (`cmd/dubplate-server`) |

The chain is 600 path minutes. `docs/STATUS.md` is the conductor's in every pass.

Pass 3 is `auth-data`. Finding S2 drops `ServeOptions.Backup`, which `cmd/dubplate-server/serve.go:490`
sets, and `IsPreMigrateCopy`, which `serve_store_test.go:37` calls, so the pass changes files on an
`auth-data` path. It also moves `doctor.go` onto `config.KeyError`, which gives the new names a
production caller in the pass that adds them. Pass 5 owns every other file under `cmd/dubplate-server`.

## What each merge changes

Nothing deploys in this round. Pass 1's merge turns on a GitHub Actions workflow in a public repo: it
runs on `pull_request`, holds no secret, and asks for read-only contents. Pass 3's merge changes the
JSON of a restore's intent record, which is free today because no store is live. Pass 4's merge
changes what a member sees in the ways its acceptance list names. Pass 5's merge removes three
backup-job operations and the catalog operation from `/api/v1` and its document.

## Acceptance

Each item names what Geoff would see or run, and "Today" is the result on `acc4089`, run on 2026-11-15.
Two items apply to every pass: the PR's check is green on its head, and `bash scripts/gate.sh --merge`
exits 0 on the close head.

### Pass 1, `cleanup-ci`

1. The pass's PR shows a check that ran `scripts/check.sh` and passed, and the run's log prints the
   name of every leg it ran. The PR body lists those legs beside the legs of a local full run, and
   names any leg left out under standing answer 13. Today: `ls .github` prints "No such file or
   directory", and `gh pr list --state open` is empty.
2. The check can fail. The PR body links two runs that ended red, each on a throwaway commit that is
   reverted before the PR is ready: one breaks a Go test and one breaks a type in `web/src`. Today: no
   run exists.
3. The workflow file pins every action by commit id, declares `permissions: contents: read`, and
   triggers on `pull_request` only. Today: no file.
4. No line above BACKLOG's `## Done` heading carries `#rung:`. Today: 40 lines do. The two entries
   under "Done" (lines 612 and 614) keep their words, as do the four source notes in `IDEAS.md` that
   say "rung".
5. `grep -c 'rung' CLAUDE.md docs/STATUS.md .claude/skills/dubplate-pass/SKILL.md` prints 0 for each,
   and the closing reviewer confirms that none of the three describes a ladder under another word.
   Today: 8, 3, and 3. The conductor makes the STATUS edit.
6. BACKLOG has a "Rounds to 0.8" section holding the eight rounds of this design in order, an "Old
   names" table, and no "Path to 0.8" heading. The PR body carries a table of every retagged item with
   its old and new tags, and the reviewer checks it against the mapping under "The rounds to 0.8". An
   item with two tags has both mapped. Today: `grep -c '^## Path to 0.8' BACKLOG.md` prints 1.
7. The adapter no longer says "Up to three dubplate passes run at once", names `claude-worktree-busy` in
   its one-executor rule, names a CI watch command, and says the dependency sweep runs once a round.
   It also holds every heading under "Conventions every task follows" that appears in both
   `docs/archive/plans/2026-10-11-admin-api-1.md` and `docs/archive/plans/2026-10-12-intake-1.md`
   (finding G15 counts 18), with its text. Today: `grep -c 'Up to three' SKILL.md` prints 1,
   `grep -c 'worktree-busy'` prints 0, and the CI watch line reads "None".
8. `docs/standing-rules.md` names the round or the pass that now holds each duty it gave a rung, and
   its text on the full-suite home names CI. The reviewer reads each changed line, since a blanket
   rename would pass a count. Today: `grep -c rung docs/standing-rules.md` prints 9.
9. `grep -rn review-desk docs/plans | wc -l` prints 0, because the four prompt files of the landed
   `admin-api-1` and `intake-1` passes moved to `docs/archive/plans/` with `git mv`, unedited. Today:
   3 lines, in two of those files.
10. `wc -c CLAUDE.md` prints 13,705 or less, and the reviewer confirms that every fact the file lost
    was about the ladder. Today: 13,705.
11. The backlog verdicts under "Backlog verdicts" are applied. A folded item carries the `#pass:` tag
    of the pass that takes it. A duplicate is removed and the surviving item names its number. A
    reworded item has the new text. Each `keep` item is stamped `*(swept 2026-11-15)*`.
12. The dependency sweep ran: the PR body carries the output of each "what is outdated" command the
    `dependency-upgrade` skill names, and lists what moved or says nothing did.

### Pass 2, `cleanup-gate`

1. A full gate run prints one elapsed-time line per leg and a total. Today:
   `grep -n -iE 'elapsed|SECONDS|date \+%s' scripts/check.sh` prints nothing.
2. The PR body carries the per-leg times of a full run on the pass's base and of a full run on the
   close head, both on pavilion. The total is lower, and every leg named in the first run is named in
   the second, apart from the awk leg that item 8 replaces. Today: no per-leg figure exists; the
   review measured 10,224 s over 20 runs in `admin-api-1`.
3. The rendered leg writes 190 captures that match the base commit's 190 with no pixel tolerance,
   opens 38 browser contexts where it opened 190, and its elapsed line on pavilion reads under 130 s.
   Today: about 257 s by the test's own comment, and `web/scripts/rendered/run.ts:6082` still says
   "150 captures".
4. `bash scripts/gate.sh --reduced --dry-run` exits 0 and prints the reduced scope. Today: exit 2 and
   the usage line.
5. `.gitleaks.toml` excludes `web/node_modules`, `web/rendered-captures`, and `tools/venv/.venv`, and a
   planted fake secret in a tracked file still fails the leg (run once, recorded, removed). Today:
   `grep -n -iE 'node_modules|rendered-captures|venv' .gitleaks.toml` prints nothing.
6. A scoped run whose change set holds one Go file runs vet, golangci-lint, and the Go tests, runs no
   `svelte-check` and no static web gate, and reports the light lane. Today: it builds the web app
   twice and queues on the heavy lane (BACKLOG #34).
7. A scoped run's Vale leg reads only changed Go files, and the full form still reads every Go file: a
   planted comment fault in a file the branch doesn't change fails `gate.sh --merge` (run once,
   recorded, removed). Today: `vale-comments.sh` reads every Go file on every form.
8. The exported-unused leg runs `go tool deadcode ./...`, pinned by a `tool` line in `go.mod`, and the
   awk block is gone. The leg stays a warning, as it is today, and prints what `deadcode` reports with
   no filter. Today: `grep -c awk scripts/check.sh` prints 5.
9. The check from pass 1 is green on this PR with no change to which legs it runs.

### Pass 3, `cleanup-store`

1. A `--from-file` restore syncs the `staging/` directory before the intent record names the stage.
   The PR names the call by file and line, and the reviewer confirms the order. A test proves it only
   where a seam the store's tests already use can observe the sync; the pass adds no test-only seam
   to production code. Today: `store/restore.go:403` syncs the file only.
2. One package prunes pre-migrate copies: `grep -rn IsPreMigrateCopy internal cmd --include='*.go'`
   prints nothing, and `Handle.PrunePreMigrateCopies` has a production caller. Today: four files
   match, one of them `cmd/dubplate-server/serve_store_test.go`.
3. `config.Lookup` and `config.KeyError` exist with tests, `Threshold` carries `Floor` and `Ceiling`,
   and `doctor.go` reads keys from `config.KeyError`: `grep -c 'strings.Cut(line, ": ")'
   cmd/dubplate-server/doctor.go` prints 0. Today: none of the three exists, and the count is 1.
4. No refusal drops its cause. Each of the 35 sites that format a cause with `%v` wraps it with `%w`,
   continuation lines included, and the PR names any refusal site it removes. Today: 35 of 46 sites.
5. `grep -c 'ruled, conductor' internal/config/*.go` prints 0 for each file, and no error text says
   "arrives at rung". Today: 15 trailers and one error line (`config.go:322`).
6. `git diff --stat origin/master -- internal/engine/store/migrations` prints nothing.
7. The settings accessor no longer holds its mutex across a database read, and its tests pass under
   `go test -race`. Today: `internal/settings/accessor.go:88-112` does.
8. Every test the pass deletes is named in the PR with the review finding that names it. No other
   test is deleted, and the reviewer confirms that no kept test lost an assertion.
9. The security reviewer returns accept.

### Pass 4, `cleanup-web`

1. The 190 rendered captures of the close head are compared with the 190 of the pass's base commit,
   with no pixel tolerance. The PR lists every capture that differs and why, and each difference falls
   under items 2 to 4. Today: the two sets are identical by definition.
2. A network failure shows the same alert style on the sign-in page and the admin pages: the style
   Geoff picks in the design packet, or `alert-warning` if his approval carries no pick. The pass adds
   a capture of that state on the sign-in page and on the members page, and the PR states the new
   capture count. Today: `alert-error` on sign-in, `alert-warning` on the admin pages, and no capture
   of either.
3. No control pairs `btn-sm` with `min-h-11`, and the rendered harness asserts that every button on
   every captured page is at least 44 px tall at 320 and 390 px. Today: eight sites pair them, and no
   such assertion exists.
4. `grep -rn 'opacity-70' web/src | wc -l` and `grep -rn 'text-\[13px\]' web/src | wc -l` print 0. The
   PR names the token that replaced each value and the line of the visual identity spec that names
   it. Today: 4 and 2.
5. `web/src` calls `fetch` at one site, in `lib/api`, under no other name. Today: 2 sites.
6. `routes/members/+page.svelte` and `routes/server-settings/+page.svelte` are both shorter, and the
   Svelte reviewer confirms that the status machine, the load, and the re-authentication alert each
   exist once. Today: 450 and 371 lines.
7. `SENT_MOMENT_TEXT` is gone. Today: `lib/copy/deck.ts:84`.
8. The Svelte and accessibility reviewers and the security reviewer each return accept.

### Pass 5, `cleanup-ops`

1. Adding a member answers success with the member whenever the write committed. A test that makes
   the old second read fail passes, and fails on the base commit. Today: `ops/admin/members.go:39`
   re-reads and answers 500.
2. A signed-in member who is not an admin and posts a malformed body to an admin operation gets the
   privilege refusal. Today: the body is decoded first (`opshttp.go:121-124`).
3. A roster change made through the web writes the caller's address to its audit row, and an operator
   is `local:<user>` in the jobs, roster, and settings audits. Today: the address is always empty,
   and the roster and settings audits write the bare `<user>`.
4. `internal/ops/unavailable.go` and `internal/ops/catalog.go` are gone. `openapi.yaml` no longer lists
   `catalog`, `start_backup`, `job_status`, or `cancel_job`, and the document test passes. Today: both
   files exist, the document lists all four, and `contract_test.go` is 1,020 lines.
5. `grep -rn 'func (.*) WriteHeader' internal/serve` prints nothing: no type wraps the response writer
   to capture a status. Today: one, `statusCapture` at `serve.go:275`.
6. `cmd/dubplate-server/web.go` is under 250 lines. The handler logic and `serve`'s `document.go`,
   `csp.go`, and `branding.go` live in one new package beside `internal/serve` (finding O10), and the
   adapter's `auth-data` list names that package. Today: 860 lines.
7. The process-citation leg, run in its warning form, reports no line under `internal/serve`,
   `internal/auth`, `internal/ops`, or `cmd/dubplate-server`. Today: 12, 11, and 10 lines in `serve`,
   `auth`, and `cmd/dubplate-server`. The leg starts to gate in round `engine`, which clears the
   engine packages' lines.
8. The security reviewer returns accept. Every sign-in, session, and roster test that existed on the
   base commit still exists and passes, apart from tests the review names, and the reviewer confirms
   that no kept test lost an assertion.

## Shared assumptions

| Assumption | Probe or source | Result |
| --- | --- | --- |
| A PR with no checks lands | Read of `approval-queue/cli/land.ts`: it refuses a failing check and polls pending ones; an empty rollup has neither | True, so pass 1 goes first |
| Actions can run on the repo | `gh api repos/glw907/dubplate/actions/permissions` | `{"enabled":true,"allowed_actions":"all"}`; the repo is `PUBLIC` |
| The session can push a workflow file | `gh auth status` | Token scopes include `workflow` |
| The pinned tools are current | `xmllint --version`, `rclone version`, `golangci-lint --version`, `vale --version`, `gitleaks version` | libxml 21504, rclone 1.75.2, golangci-lint 2.15.0, vale 3.27.0, gitleaks 8.30.1 |
| libxml2 is held | `brew list --pinned` | It was not pinned on pavilion. Pinned on 2026-11-15, so the XML goldens can't drift mid-round |
| A planner can launch | `claude --help` | Lists `--bg`, `--model`, `--effort`, `--name`; `--advisor` is accepted (cairn planners, 2026-11-15) |
| Skill edits in a repo aren't refused | Read of `~/.local/state/claude-denials.jsonl`, 2026-11-01 to 2026-11-15, 73 rows | No row names dubplate or `.github/workflows`; one names `.claude/skills` in another repo, which pass 1's planner reads before it plans |
| Estimates | `dev-speed/research/score-backfill.json` | `admin-api-1` planned 695 and took 475; `intake-1` planned 725 and took 570 |
| The review still describes the code | The backlog sweep's read of today's tree | Recorded under "Backlog verdicts" |

## Order

Passes run one at a time and merge in this order.

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 `cleanup-ci` | `plans/2026-11-15-cleanup-1-planner-prompt.txt` | none | 100 | no |
| 2 `cleanup-gate` | `plans/2026-11-15-cleanup-2-planner-prompt.txt` | 1 | 130 | no |
| 3 `cleanup-store` | `plans/2026-11-15-cleanup-3-planner-prompt.txt` | 2 | 130 | yes |
| 4 `cleanup-web` | `plans/2026-11-15-cleanup-4-planner-prompt.txt` | 3 | 100 | yes |
| 5 `cleanup-ops` | `plans/2026-11-15-cleanup-5-planner-prompt.txt` | 3, 4 | 140 | yes |

Pass 1 rests on the least-proven assumption, that a hosted runner can carry the gate, so it runs first.
The two passes that land come ahead of the three that wait. A worktree is cut from `origin/master` while every
earlier pass has landed, and from the branch of the pass before it once one is waiting.

## Start line

The first planner launches when each of these reads true.

1. Geoff's approve is recorded: this design's "Rulings" section carries a `Ruled:` line with the queue
   id.
2. `git -C ~/Projects/dubplate rev-list --count HEAD..origin/master` prints 0 after a fetch, and the
   checkout is on `master`.
3. `claude-worktree-busy ~/Projects/dubplate` exits 0.
4. `claude agents --json` shows no dubplate session but the conductor.
5. `gh pr list --state open` in dubplate is empty.
6. Weekly usage reads under 85 percent.

No other round is approved or running in dubplate.

| Check | Command | Output on 2026-11-15 |
| --- | --- | --- |
| Level with the remote | `git fetch && git rev-list --count HEAD..origin/master` | `0`; the one unpushed commit, `acc4089`, was pushed |
| Free checkout | `claude-worktree-busy ~/Projects/dubplate` | exit 0 |
| Live sessions | `claude agents --json` | one dubplate row, the designing session, which ends at the hand-off |
| Open PRs | `gh pr list --state open` | empty |
| Usage | `claude -p "/usage" --model haiku < /dev/null` | "Current week (all models): 42% used" |
| Launch flags | `claude --help` | as under "Shared assumptions" |
| Worktrees ignored | `git check-ignore -q .claude/worktrees/x` | the conductor runs this before the first cut and appends to `info/exclude` if it fails |

## Steps for Geoff

Nothing before launch. At the end, `[you: read the close packet]`, which holds the store, web, and ops PRs,
the before-and-after captures, the security verdicts, and the settings rules of call 10.

## Standing answers

The twelve in `round-run.md` hold. This design adds:

13. A gate leg can't run on the hosted runner. The planner first tries to install the pinned tool in
    the workflow. If that fails, `check.sh` gains one input that leaves out a leg by name, the workflow sets it, the
    job's name says which leg is missing, the local gate stays that leg's home, and the PR flags the amended item. No leg is skipped
    through a tool-presence test.
14. A plan's path is over twice its pass's figure. The pass parks (`round.md`). The round starts
    nothing new past 1,200 minutes.
15. A task needs a file outside its pass's row. A call site forced by a changed signature is taken and
    listed under `## Decisions`. Anything else is filed in BACKLOG and left.
16. A cut would touch the review's "Leave alone" list, a migration, or a frozen spec. It is left, and
    the PR says so.
17. A review finding no longer matches the code. The planner drops it, names it under
    `## Planning misses` with `[stale-fact]`, and goes on.
18. A cleanup changes a rendered capture or an API answer this design doesn't name. It is fixed at its
    cause, never accepted as the new baseline.
19. The CI check is red for a cause outside the pass, such as a runner image change. The executor fixes
    the workflow in its branch, lists the fix under `## Decisions`, and goes on.
20. Geoff's approval carries no pick for the network-failure alert. Pass 4 uses `alert-warning`.

## Rulings

Ruled: approved by Geoff on 2026-11-16 through the Approval Queue, document `20261116-000308-88f4d3`.

- The round list: "Use these eight rounds, in this order".
- The network-failure alert: "Warning on every page". Pass 4 uses `alert-warning` on the sign-in page
  and the admin pages.

## Backlog verdicts

A scoped sweep read every open item that names a file in the five passes against `acc4089`. Approving
this design approves these edits, which pass 1 makes. BACKLOG has 111 open items and none carries a
sweep stamp.

| Item | Verdict | Reason |
| --- | --- | --- |
| #97 PR checks | fold, pass 1 | `.github/` is absent |
| #70 the "Gate legs" text in the standing rules | fold, pass 1 | It cites rungs and an old leg time |
| #108 method findings | reword | G14, G15, and G19 fold into pass 1. G18 rides the close packet (call 10). G16 and G17 stay with `workstation-refinement` |
| #104 gate timing, the rendered leg, gitleaks, scoping, Vale | fold, pass 2 | All six findings still match the code |
| #34 light lane for a scoped run | fold, pass 2 | Same change as finding G5. The pass measures golangci-lint under the light cap first |
| #105 `--reduced`, duplicate pipelines, the awk leg | reword | Folds into pass 2, with the `--fresh` flag. The `.golangci.yml` clause stays open |
| #64 photo checks | reword | The `check.sh` header line folds into pass 2. The `tools/photos` part stays |
| #67 citation leg misses one pattern | fold, pass 2 | One pattern added at `check.sh:781` |
| #69 "boundary gate" wording | fold, pass 2 | Wording at `check.sh:60` and `:622` |
| #116 the staging directory sync | fold, pass 3 | `store/restore.go` syncs the file only |
| #117, #118, #119 store and config findings | fold, pass 3 | Still match |
| #26 the earlier "To file" bundle | reword | Its store parts are #117 and #118. The settings accessor holding its mutex across a database read folds into pass 3. Two comment items stay |
| #78 doctor's address normalizer | duplicate of #118 | Two copies beside `identity.NormalizeAddress` |
| #120 web findings | fold, pass 4 | Still match |
| #19 the faded hint text | fold, pass 4 | Same change as finding W7 |
| #121, #122, #123, #124 ops, auth, and serve findings | fold, pass 5 | Still match |
| #125 `cmd` and ops tests, the citation leg | reword | The test cuts fold into pass 5. Making the citation leg gate moves to round `engine`: about 125 of the 189 lines it would fail on are in engine packages |
| #66 architecture umbrella | reword | Its doctor clause was fixed in `4de73e7`. The rest stays |
| #16 username equal to an address | reword | The function it names is gone. The gap is now at `auth/roster.go:462` |
| #30, #33, #35 harness items | duplicate of #114 | Round `engine` takes them there |
| #15, #57 | reword | Line numbers moved |
| #80 Save is solid only when the form changed | keep | It changes what a member sees, which this round doesn't do. Round `library` |
| #128 the `CLAUDE.md` size budget | keep | It belongs to `workstation-refinement`. Pass 1 only holds the file at its size |
| #127 the re-plan sitting | done | Geoff's rulings of 2026-11-15 answer its three parts: the folder-admit command replaces the migrator, no private deploy, and the three candidates sit after 0.8 |
| #13, #14, #18, #20, #24, #52, #54, #72 to #77, #79, #81 to #83, #96, #103, #106, #107 | keep | None is in a line a pass rewrites. #106 and #107 are round `launch` |

Items that name no file in the five passes got no verdict here. The full sweep that is due covers
them.

One review finding was already fixed: doctor's chain of twelve flag tests (`4de73e7`). The sweep read
and confirmed the gate findings G1 to G6, G8, G11, and G12, the store findings except S3 and S8, the
ops findings O1, O2, and O6, and the web findings W3 and W6 to W8. The rest it took from the review
unread, so standing answer 17 covers a finding that turns out stale.

## The rounds to 0.8

Each round is one design. Rounds run one at a time, in this order, and a later design may regroup its
passes.

| Round | What a member or the build gains | Takes |
| --- | --- | --- |
| 1 `cleanup` | PR checks, a faster gate, and the review's store, web, and ops findings | This design |
| 2 `engine` | The review's matcher, MusicBrainz, tag I/O, and harness findings, after which the process-citation leg gates. One pass, in the main checkout | BACKLOG #110 to #115, and the citation part of #125 |
| 3 `intake` | A member uploads an album and sees its verdict: the match probe, the uploader page, and resume. Ends in Geoff's uploader sitting | `intake-2` and `intake-3`; #92's three rulings open the design; #126 |
| 4 `catalog` | An accepted album enters the library: collection writes, the admission pipeline, the catalog, and the folder-admit command that brings in music already on disk | The old `admin-api-2`, `pipeline`, and `migration` |
| 5 `playback` | A client signs in and plays a track: streamer slices 3 to 6 | The old `streamer`, first part |
| 6 `queue` | An admin settles a held album: the decision queue under `strict`, streamer slices 7 and 8 without smart playlists, and the built-ins without lifecycle hooks | The old `queues`, `builtins`, and the rest of `streamer` |
| 7 `library` | A member browses the library on the web: the album page, the grid and list, filtering, and buy links | The old `library-web-1` |
| 8 `launch` | 0.8.0 on the box: deploy and hardening fixes, the whole-system pass, the first launch with Geoff's sitting, and the clean-up after it | The old `integration`, `cutover`, and `closeout`; #106, #107 |

`catalog` needs `intake`'s accepted state. `playback`, `queue`, and `library` each need the catalog,
and `queue` comes before streamer slice 7, which reads it. `engine` depends on nothing after `cleanup`.

Tag mapping for pass 1: `#rung:intake` to `#round:intake`; `#rung:admin-api` and `#rung:pipeline` to
`#round:catalog`; `#rung:streamer` to `#round:playback`, or `#round:queue` where the item names slice 7
or 8; `#rung:integration` and `#rung:cutover` to `#round:launch`. `#pass:gate-1` becomes the slug of the
pass that takes the item (`cleanup-ci` or `cleanup-gate`), or `#round:launch` for #106 and #107.
`#pass:web-shell-1` becomes `#pass:cleanup-web`. `#pass:cleanup-engine` becomes `#round:engine`.

## Estimate

600 path minutes across five passes, with new launches ending at 1,200. The two feature passes on
record took 68 and 79 percent of their plans' paths, and the review found plans running 1.45 times
their designs, so each figure here is the review's size for the pass with that ratio already in it.

## Practice and sources

- `pass-core` `references/round.md`, `ready.md`, and `round-run.md` for the round's shape.
- GitHub's guidance on hardening Actions: pin an action to a full commit id and grant the token the
  least permission (<https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions>).
- The whole-repo review, dubplate `docs/research/2026-11-10-whole-repo-review.md`.
- The theme-garden `foundation` design, for the document's form.

## Later

After 0.8: lifecycle hooks, the `owner-queue` and `contributor-picks` custody policies, smart
playlists, the paired local client (0.9), and the format ladder (1.0). A full backlog sweep is due and
runs as a separate session with its own document.
