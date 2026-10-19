# drafter F2 plan fold

Target: `docs-system/plans/2026-10-19-drafter-f2-prompts-tracks-plan.md`, revised in place.
Review: `2026-10-19-drafter-f2-plan-review-mechanics.md` (3 blockers, 8 majors, 16 minors). Code
read at drafter `main` `6583012` and cairn-cms `main` `6a7909d38`. Probes ran in a detached drafter
worktree under the session scratchpad (`fold-probes/`), since removed.

- Design-changing findings: none. Every fold keeps the design's F2 scope, risk class `runner`, and
  acceptance rows. B1 moves the `introPlan` rule from a decode tag to a check, and the acceptance row
  ("a blueprint with no `introPlan` fails") still holds. M8 moves the known-anatomy check to the
  outline, which matches the row's wording ("a type naming an unknown anatomy fails") more closely.
- Path minutes: 310 (was 275), against the design's 200 and the 400 line. F2.0 grows from 10 to 25
  (the fixture sweep), F2.4 from 90 to 100 (the pair's length), and F2.7 from 60 to 70.
- Owner forks: none. m8 has one clearly correct answer, and the plan now takes it (below).
- Launch prompts: unchanged. Neither states a fact the fold changed.

Counts: 20 folded, 1 refused, 6 dropped as `optional`, 0 forks (27 findings).

## Blockers

- **B1, folded.** Verified: `Section`'s doc comment says the decoder doesn't require `Why` so a
  converted blueprint decodes (`internal/blueprint/blueprint.go`), and a required tag adds an error
  finding (`internal/plan/decode.go`, "missing required field"), which `ConvertPlan`, `install.go`,
  `seed.go`, and `Compare` treat as fatal. Resolution 10 was rewritten: the tags and both schemas
  stay. A check in `blueprintData`, beside `sections`, reports no `framing` or no `introPlan` as an
  error, and `judgment` gains the line for the convert report. F2.4's files and tests follow. Probe:
  a draft of the rule in `blueprintData` broke only `cmd/drafter` and `e2e` tests, all from fixtures
  that lack `introPlan`, and those went green after the M4 sweep.
- **B2, folded.** Verified: `changedSettings` reports a key of `now` missing from `was`
  (`internal/pipeline/fingerprint.go`), and the fingerprint's doc comment scopes it to what requests
  and costs depend on. Resolution 3 now keeps `require_prompts` out of the fingerprint, with the
  reason. F2.1's files exclude `fingerprint.go`, and its tests add a row showing that a
  `fingerprint.json` saved before F2 still resumes.
- **B3, folded.** Verified: `claude -p --output-format stream-json` on 2.1.302 prints "Error: When
  using --print, --output-format=stream-json requires --verbose" (rerun in this fold), and
  `~/.claude/skills/blueprint` links to the main checkout. The fold quotes the docs instead of
  assuming the flag's reach: the `user` setting source loads `~/.claude/skills/`
  (code.claude.com/docs/en/agent-sdk/claude-code-features, the `settingSources` table), so
  `--setting-sources project` leaves out the stale personal skill. `--bare` was considered and
  ruled out, since it "never reads OAuth credentials" (docs/en/headless) and the check runs on
  session tokens. F2.7's headless check is rewritten as four steps. Step 3 asserts that the skill
  under test loaded, through a sentence only F2.6's skill carries. This replaces the review's
  `system/init` `skills` idea, since the docs don't list a `skills` field on that event. Step 4
  scans Bash `command` strings as well as the Read, Glob, and Grep arguments.

## Majors

- **M1, folded.** F2.0's stub `prompts.js` now defines a placeholder `blueprint` seat. F2.1's
  preflight row names the stub. F2.3's "defines exactly `blueprint`" still holds.
- **M2, folded.** Verified: `layer.go` says that the environment and the flags "are never
  restricted", and that `fromEnv` reads an explicit key list (`env.go`). Resolution 3 names every
  channel. F2.1's files exclude `env.go`, its tests add the `DRAFTER_REQUIRE_PROMPTS=false` row, and
  the docs row reads "environment variable: none".
- **M3, folded.** Verified: `stepSeats` (`internal/pipeline/handle.go`) gives a blueprint page
  `blueprint` (plus Go-built consistency), and the other pages `draft`, the review seats, and the
  reader. Resolution 7 states the rule per page, names the seats, and passes `Module()`'s name to
  `moduleFor` (`start.go`, `filepath.Base(r.o.Config.Prompts)`).
- **M4, folded, at the root with m14 and m15.** Verified and probed: 11 tracked blueprint fixtures
  lack `introPlan`, and the inline blueprints in `cmd/drafter/read_test.go`, `e2e/blueprint_test.go`,
  and `e2e/setup_test.go` lack it too. With an `introPlan` added to all 14 and the draft rule in
  place, `go test -count=1 ./...` passed. F2.0 now carries the sweep, with the measured file set,
  and runs 25 minutes.
- **M5, folded, with m16 at the root.** Verified: the e2e `apiStub` returns 404 off its two paths
  (`e2e/page_test.go`). F2.1's non-dry and resume rows move to `fakeAPI` and `newBlueprintHarness`
  in `internal/pipeline`. The resume row names its fixture state and the project config it changes.
  It says the run directory's `config.json` is never read (`useCopies`, `resume.go`).
- **M6, folded.** Verified: `setupEnv` holds only `HOME`, `PATH`, and the git variables
  (`e2e/setup_test.go`), and `api_base_url` has an env variable (`env.go`'s list). F2.7's dry-run row
  starts the stub and sets `DRAFTER_API_BASE_URL` and a synthetic `DRAFTER_API_KEY` for that one
  call.
- **M7, folded.** Verified: `internal/scaffold/templates/outline.yaml` declares
  `anatomy: Reference page`. Resolution 9 and F2.4 change it to `Reference entry`, and a test
  checks every scaffolded type against `stock.Anatomies`.
- **M8, folded as option (b).** This isn't a fork. The acceptance row tests a type, and option (a)
  would turn F2.4's cairn acceptance into "unchanged" and let F2.7 pass on a type no blueprinted page
  uses. Verified: `pageType` runs only from `blueprintData` (`check.go`), cairn's one blueprint has
  the stock type `task guide`, and the baseline measured in this fold with the `6583012` binary is
  "0 errors, 54 warnings". Resolution 9 moves the check to an outline phase in `Project.Check`, once
  per declared type, and keeps it out of `CheckSource` (whose doc comment leaves outline-wide checks
  to the walk). F2.4's acceptance is 0 errors and 56 warnings. F2.7 names its fixture state.

## Minors

- **m1, folded.** Resolution 11 names `json:"bullets"` and `json:"joined"`, with no `omitempty`,
  and gives the reason from encoding/json.
- **m2, folded.** Verified: `slugger` and `slugOf` live in `internal/plan/slug.go`, and `Anchors`
  and `HeadingSlugs` don't fit the excerpt. Resolution 5 and F2.2's files now name `slug.go` and
  the one exported function.
- **m3, dropped (`optional`).**
- **m4, refused.** The blueprint read's own prompt doesn't carry the blueprint's `.md#` tokens. The
  blueprint goes in `Extra` (`internal/pipeline/blueprint.go`, `stageBlueprintRead`), and
  `fileBlocks` scans only `in.Prompt` (`internal/assemble/assemble.go`). For cairn's own draft
  seats, the count the review asks for needs a matrix and a module that this workstation doesn't
  name (cairn has no `drafter.local.toml`). That measuring costs more than the risk it removes: a
  few extra excerpt blocks, each labeled and under the size limit, in the designed `path#heading`
  form. F2.1's docs already document the form.
- **m5, folded.** Resolution 8 assigns each state to decode, a check error, or a check warning. The
  probes: `path.Match("docs/[a", "")` returns "syntax error in pattern"; the decoder errors on an
  empty string and on an empty required list (`internal/plan/decode.go`, `str` and `list`).
  Resolution 9 covers a register with no anatomies section, and resolution 4 covers a missing
  `prompts` path (`<path> (missing)`). F2.4 and F2.1 gain the rows.
- **m6, folded.** Resolution 9 decides known-ness by register from each page's own track. That is
  the register the stock read inlines. F2.4 adds the cross-track row.
- **m7, dropped (`optional`).**
- **m8, folded, not a fork.** A resume of a stock-module run refuses once the guard is set and
  `prompts` is unset, because `Validate(ScopeRun)` runs before the resume (`newRunner`). That is the
  guard's meaning, since a resume is a run, and no such cairn run exists. Resolution 3 says so.
  - Residual, recorded rather than built: a stock run resumed with `prompts` set in a local file
    passes `Validate` and still uses its run copy.
  - The one window for such a run is between the drafter merge and the cairn PR's merge, and only
    if someone runs a cairn read in it.
- **m9, folded.** Verified: `runRead`'s `len(handoffs) == 0` branch builds a bare `Summary`
  (`cmd/drafter/read.go`). Resolution 4 fills the two fields from `c.Module()`, and F2.1's report
  row covers that branch.
- **m10, dropped (`optional`).**
- **m11, dropped (`optional`).** M5's rewrite of the `drafter page` row says "before any spend"
  anyway, since that row had to be rewritten.
- **m12, dropped (`optional`).** Resolution 8 carries one sentence on `register.<track>` because the
  m5 rewrite touched that paragraph.
- **m13, dropped (`optional`).**
- **m14, folded at M4's root.** The estimate moved with the sweep.
- **m15, folded at M4's root.** F2.0 now carries two deliverables.
- **m16, folded at M5's root.**

Tally: 20 folded (B1 to B3, M1 to M8, m1, m2, m5, m6, m8, m9, m14, m15, m16), 1 refused (m4),
6 dropped (m3, m7, m10, m11, m12, m13).
