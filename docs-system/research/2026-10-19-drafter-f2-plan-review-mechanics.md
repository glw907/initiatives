# drafter F2 plan review: mechanics and feasibility

Target: `docs-system/plans/2026-10-19-drafter-f2-prompts-tracks-plan.md` at initiatives `679441d`
(branch `plan-drafter-f2`). Code read at drafter `main` `6583012` and cairn-cms `main` `6a7909d38`.
Probes ran in a detached drafter worktree under the session scratchpad (`review-probes/`), since
removed. Plan line numbers are the plan file's own.

Counts: 3 blockers, 8 majors, 16 minors.

## Blockers

### B1. Resolution 10's `plan:"required"` tags make the decoder fail, which breaks convert, seed, install, and `--since` scoping (correctness)

Location: plan:174-181 (resolution 10), plan:251 and plan:263-264 (F2.4).

Defect: the plan says decode "still succeeds", pointing at "the comment on required fields" in
`blueprint.go`. The comment says the opposite. `Section.Why` is deliberately *not* tagged required:
"A check requires a Why; the decoder does not, so a converted blueprint decodes"
(`internal/blueprint/blueprint.go`, the `Section` doc comment). A `plan:"required"` tag is enforced
by the decoder, which emits an error-severity finding (`internal/plan/decode.go:193-194`,
`missing required field %q`, added through `d.add`, which sets `SeverityError` at `decode.go:48-50`).
Every caller that treats a decode finding as fatal then breaks:

- `ConvertPlan` fails on any finding: "The blueprint it returns decodes without a finding, or
  ConvertPlan fails" (`internal/blueprint/convert.go`, the `len(findings) > 0` check after
  `marshalNode`). So `drafter convert` with no framing record stops writing a blueprint.
- `install.go:86-88` and `seed.go:99-101` refuse when `len(findings) > 0`.
- `Compare` returns `whole` when the earlier revision has a decode error (`since.go:56-58`). Every
  base blueprint that has no `introPlan` turns a scoped change read into a whole read.
- `blueprintData` returns early on `plan.HasError(findings)` (`check.go`, before `plan.Check`), so a
  missing framing hides every other check on the file.

Probe: with the two tags changed as written, `go test ./internal/blueprint/ ./cmd/drafter/ ./e2e/`
fails 30 tests in 3 packages. Among them: `TestConvertPlanFraming` ("the converted blueprint does not
decode: line 14: framing: missing required field \"introPlan\""),
`TestConvertPlanHonoursTheBlueprintSettings`, every `TestCompare` row (kind `whole`, "absent or
undecodable at the earlier revision"), `TestReadSince`, `TestSchemasMatchGoTypes`, and
`TestSetupFromNothing`.

Proposed fold: leave both tags as they are, so the schemas don't change. Add a check-level rule in
`projectCheck`, beside the `sections()` rule for `why`: no `framing`, or an empty or absent
`framing.introPlan`, is an error with the `framing` check. `ConvertPlan`'s `judgment` list gains the
`introPlan` line for the convert report. Rewrite resolution 10 and F2.4's tests to match ("the check
reports it; decode, convert, seed, and Compare are unchanged").

### B2. Adding `require_prompts` to the fingerprint breaks the resume of every run started before F2 (correctness)

Location: plan:90-91 (resolution 3, "It joins the `drafter config` rows and the fingerprint"),
plan:220-224 (F2.1's files list leaves out `fingerprint.go`).

Defect: `checkConfig` compares the run's saved fingerprint with the current one through
`changedSettings` (`internal/pipeline/resume.go:213`). `changedSettings` lists every key of `now`
that is missing from `was` (`internal/pipeline/fingerprint.go:50-52`, `!ok || prior != v`). A run
saved before F2 has no `require_prompts` key, so after the upgrade every resume fails with "the
configuration changed since the run started (require_prompts)". That breaks the design's own
requirement, "a resume after an upgrade uses the same prompts". The setting also changes neither
requests nor cost, which is the fingerprint's stated scope (`fingerprint.go:13-15`).

Proposed fold: keep `require_prompts` out of the fingerprint. It is a start-time gate that
`Validate` enforces, and a resume already re-runs `Validate`. Replace "and the fingerprint" in
resolution 3 with "never the fingerprint: it changes no request". Add a test that a pre-F2
`fingerprint.json` still resumes.

### B3. F2.7's headless check, as written, either errors at launch or tests the pre-F2 skill, and it misses Bash reads (correctness)

Location: plan:372-377.

Defects:

1. The plan runs `claude -p ... --output-format stream-json` with no `--verbose`. Probe with Claude
   Code 2.1.302: `Error: When using --print, --output-format=stream-json requires --verbose`.
2. The personal skill shadows the one under test. `~/.claude/skills/blueprint` links to
   `~/Projects/drafter/claude/.claude/skills/blueprint`, the main checkout (checked with `ls -la`).
   Until the merge's `make install`, that is the pre-F2 skill. The skills docs give the precedence:
   "Enterprise over personal, and personal over project. With `deploy` in both `~/.claude/skills/`
   and the project's `.claude/skills/`, `/deploy` runs the personal one"
   (<https://code.claude.com/docs/en/skills>, "Resolve skills that share a name"). A copy in the
   fixture or in an `--add-dir` loses to the old skill, so the check reads the wrong skill and passes
   or fails for the wrong reason.
3. The assertion covers only Read, Glob, and Grep paths. A `cat` or `ls` through the Bash tool
   opens a register path and goes unseen.

Proposed fold: run `claude -p --verbose --output-format stream-json --setting-sources project`
from a temp copy of the fixture. Put the worktree's `claude/.claude/skills/blueprint`, with its links
dereferenced (`cp -rL`), under the copy's `.claude/skills/`. Assert from the stream's `system/init`
event that `blueprint` is among `skills` and that the loaded SKILL.md is the worktree's (for example,
grep the first tool result for a sentence F2.6 adds). Scan Bash `command` strings as well as the
Read, Glob, and Grep path arguments, or pass `--allowedTools` without Bash. Record the exact command
in the PR body.

## Majors

### M1. F2.1's "`drafter read` on the stock module passes the preflight" can't pass in pair A, because F2.0's stub is `{}` (correctness)

Location: plan:211 (`prompts.js` returns `{}`), plan:240-241 (F2.1 test), plan:285 (F2.3, which
writes the builder, runs after pair A merges).

Defect: under resolution 7, a read run needs a `blueprint` seat. The stub defines none, so the
preflight refuses `drafter read` until F2.3 lands in pair B. F2.1's acceptance (`make check` green)
then can't hold.

Proposed fold: F2.0's stub returns `{ blueprint: (c) => "stock blueprint read placeholder" }`, and
F2.3 replaces it. F2.3's test that the module "defines exactly `blueprint`" still holds.

### M2. `require_prompts` can be overridden from the environment unless the plan rules out an env variable (correctness)

Location: plan:86-88 (resolution 3, "only a committed `drafter.toml` can set it"), plan:220
(`env.go` "as needed").

Defect: `allowedIn` restricts file layers only: "The environment and the flags are not file layers
and are never restricted" (`internal/config/layer.go:20-21`). The env layer sits above the project
layer. If F2.1 adds `DRAFTER_REQUIRE_PROMPTS`, which `env.go`'s pattern and the plan's "as needed"
both invite, then `DRAFTER_REQUIRE_PROMPTS=false` turns off cairn's committed guard. The checklist
item "every privileged field names every channel that may set it" is unmet. The channels are the
user, project, and local files, env, flag, and the stock `stock.toml`.

Proposed fold: resolution 3 names every channel. The project file sets it. Neither the user nor the
local file can (refused by `checkAllowed`). It has no env variable and no flag, and `stock.toml`
leaves it unset. `configuration.md`'s row reads "Environment variable: None." Add a test that
`DRAFTER_REQUIRE_PROMPTS=false` changes nothing.

### M3. Resolution 7's seat rule, as worded, makes every `drafter read` on the stock module fail (correctness)

Location: plan:138-140.

Defect: "the `p.render` seats of `steps.go` that `cfg.Seats` lists, plus `blueprint` when a page has
a blueprint". `cfg.Seats` always lists `draft` and, by default, the read seats, so the rule asks a
read run for `draft`, `structure`, and the rest. A blueprint page renders only `blueprint`: "blueprint
marks a page whose plan is a blueprint, which stage 1 reads and stops at"
(`internal/pipeline/page.go`, the `page.blueprint` field). The consistency and coverage prompts are
built in Go (`assemble.ConsistencyPrompt`, `coverage.Prompt`), not by the module.

Proposed fold: make the rule per page. A blueprint page needs `blueprint`. Any other page needs
`draft`, plus each of `structure`, `editor`, `fact`, and `reader` that `p.runs` reports. Name these
seats explicitly instead of saying "the `p.render` seats". Also pass `Module()`'s name to
`moduleFor`: with `prompts` unset, `filepath.Base(r.o.Config.Prompts)` (`start.go:293`) is `"."`.

### M4. Pair A is not file-disjoint: the `introPlan` rule breaks fixtures that F2.1 shares, and F2.4's files list leaves them out (correctness)

Location: plan:251-255 (F2.4 files), plan:220-224 (F2.1 files), plan:36-37 (pairing).

Defect: none of the 11 tracked blueprint fixtures carries `introPlan` (`git ls-files` with
`grep -L introPlan`). The inline YAML in `e2e/setup_test.go`'s `setupBlueprint`,
`internal/blueprint/since_test.go`, and the `cmd/drafter` tests lacks it too. The pipeline's
blueprint check runs `CheckSource` (`internal/pipeline/blueprint.go:81`, `doBlueprintCheck`). So
even the check-level rule from B1 turns `internal/pipeline/testdata/project`'s two blueprints into
escalations, and that fixture is F2.1's to test against. It also breaks `cmd/drafter` read and gate
tests (F2.1's `read.go`/`read_test.go`) and `e2e/setup_test.go` (F2.7's file). F2.4 can't get
`make check` green without editing files its partner owns.

Proposed fold: put the fixture sweep in F2.0 by the session. Add an `introPlan` to every tracked
fixture and inline blueprint, which is valid today since the field is optional. Then commit before
pair A. F2.4 then adds only the rule and its red fixtures. This also makes F2.0 a two-deliverable
task (see m15).

### M5. F2.1's non-dry-run and resume tests name a harness that can't run them (correctness)

Location: plan:232-237.

Defect: the e2e `apiStub` "answers the two free calls a dry run makes", `GET /v1/models` and
`POST /v1/messages/count_tokens`, and returns 404 for every other path (`e2e/page_test.go:28-59`). A
non-dry run then fails at its first submission, and no stub reply yields the stopped, resumable run
that the resume test needs. The proof doesn't name the fixture state it requires.

Proposed fold: write both tests against `internal/pipeline`'s scripted `fakeAPI`
(`internal/pipeline/fake_test.go:41-89`), as `resume_test.go` does. Name the state: a run that
stopped after stage 1 was submitted, with `state.Inputs["prompts"]` holding the stock hash. Then the
project's `drafter.toml` points `prompts` at a different file (not the run directory's
`config.json`, which a resume never reads), and the resume reports the run copy's hash. Keep the
e2e stub for the dry-run rows only.

### M6. F2.7's "`drafter read --dry-run` exits 0" has no key and no API in `setupEnv` (correctness)

Location: plan:367.

Defect: `runRead` resolves the key before the run (`cmd/drafter/read.go`, `key.Resolve(c)`).
`key_env = "DRAFTER_API_KEY"` is set in the user layer, but `setupEnv`'s environment holds only
`HOME`, `PATH`, and the git variables (`e2e/setup_test.go:48-55`), so `key.Resolve` fails:
"key_env variable DRAFTER_API_KEY is unset" (`internal/key/key.go:30-32`). A dry run also calls
`CheckWorkspace` (`start.go:131`, `GET /v1/models`) and `CountTokens` (`internal/pipeline/dry.go:32`)
against `api_base_url`, which defaults to the real API.

Proposed fold: start `newAPIStub(t)` in `TestSetupFromNothing`, and add
`DRAFTER_API_BASE_URL=<stub>` and `DRAFTER_API_KEY=<synthetic>` to the environment of that one call
only. The `require_prompts` row needs neither, since `Validate` refuses first. Assert
`stub.submitted()` is empty.

### M7. `drafter init`'s outline names `Reference page`, which the stock list doesn't hold (correctness)

Location: plan:156-159 (resolution 9's stock names), with no task that touches `internal/scaffold`.

Defect: `internal/scaffold/templates/outline.yaml` declares `reference` with `anatomy: Reference
page`. The stock list says `Reference entry`. A new project's first reference blueprint gets an
unknown-anatomy warning, and an error once it declares tracks. That is the new developer's path the
onboarding design guards.

Proposed fold: F2.4 changes the template to `Reference entry`, the name cairn's register uses too,
and adds a test that every scaffolded type's anatomy is in `stock.Anatomies`. List
`internal/scaffold/templates/outline.yaml` in F2.4's files.

### M8. F2.4's cairn acceptance expects warnings the check can't produce (correctness)

Location: plan:166-168 and plan:266-268; also plan:368 (F2.7's unknown-anatomy row).

Defect: `pageType` runs only from `blueprintData`, so only for a page that has a blueprint
(`internal/blueprint/check.go:139`). cairn has one blueprint, `rotate-the-github-app-key`, and its
type is `task guide`, a stock name. Its pages of type `tutorial milestone` and `symptom row` have no
blueprints. So the check as resolved yields no new cairn warning, and the acceptance's "exactly the
unknown-anatomy warnings for `Tutorial milestone` and `Symptom row`" can't be met. Measured baseline
with the `6583012` binary on cairn `main`: "0 errors, 54 warnings", none about anatomy. The same
mechanism decides F2.7's row: the unknown anatomy has to sit on the type of a page that has a
blueprint, or the test passes vacuously.

Proposed fold: choose one. (a) Keep the check per blueprint. Then F2.4's acceptance becomes "cairn's
check is unchanged: 0 errors, 54 warnings". (b) Move the known-anatomy check to the outline, once
per declared type. Then cairn gets two warnings, the acceptance stands, and the check covers types
with no blueprint yet. I recommend (b), since a type declaration is an outline fact. Either way, F2.7
names its fixture state: it changes the `task guide` type's anatomy, the type of the page with the
blueprint.

## Minors

### m1. `Scope.Bullets` and `Scope.Joined` must not carry `omitempty` (correctness)

Location: plan:194-196 and plan:201-202.

Defect: a scoped page's `Scope` persists in `state.json` (the page's `Work`, unmarshalled in
`rehydrate`, `resume.go:173`). Probe: `[]string{}` under a tag with `omitempty` round-trips to
`nil`, and under a tag without it round-trips to non-nil. With `omitempty`, a resumed scoped page
reads as pre-F2 and silently falls back to today's rule. That fails closed, but the fix is lost.
`Facts` already avoids this with `json:"facts"`. The fields also appear in `drafter read --json`
through `PageResult.Scope`.

Proposed fold: name the tags (`json:"bullets"`, `json:"joined"`, no `omitempty`) and add a
`state.json` round-trip row. Note the new JSON summary keys in `docs/`.

### m2. The slug rule lives in `internal/plan/slug.go`, and no exported function gives what the excerpt needs (correctness)

Location: plan:114-115 and plan:274-276.

Defect: `pagelinks.go` holds no slug function. The github-slugger port is `slugger` and `slugOf` in
`internal/plan/slug.go`. The exported `Anchors` returns deduplicated anchors, `<a id>` ids included,
with no level or position. `HeadingSlugs(title, headings)` takes a title first, which shifts the
`-1` numbering. The excerpt needs each heading's level, its line, and its slug from one slugger.

Proposed fold: F2.2's files list `internal/plan/slug.go`. The task adds one exported function, for
example `Headings(src) []Heading{Level, Line, Slug}`, built from `Anchors`'s walk and slugger, and
`Anchors` is refactored onto it.

### m3. Resolution 5's size rationale is wrong, and the plan ignores the existing `excerpt` vocabulary (optional)

Location: plan:118-119 and plan:112-113.

Defect: `sizeLimit` is `256 << 10`, which is 262,144 bytes (`internal/assemble/files.go:18`), so
cairn's 90,601-byte register already inlines whole. `excerpt.go` already emits `excerpt` blocks with
`no excerpt: <form>` bodies, and a `path#name` form that names a code declaration, for fact sources.
The new prompt-token form reuses the kind and the `#` sigil with a different meaning.

Proposed fold: drop the register sentence and keep the over-limit test with a synthetic large file.
State that the prompt-token `#slug` form is Markdown-only and separate from the fact-source
`path#Symbol` form, with distinct labels. Key the dedupe on token, not `t.real`
(`files.go:187`), so a file token and an excerpt token of the same file both inline.

### m4. The `#slug` form silently changes cairn's request bytes wherever a rendered prompt carries a repo-relative `path.md#anchor` (correctness)

Location: plan:110-116.

Defect: today such a token never resolves: it isn't a tracked path, and `trackedRel` trims only
`.:;!?`. After F2.2 it inlines a section. The draft prompts that cairn's module renders embed the
plan's items, link targets among them. That adds input tokens and cost to cairn's runs, with no
note.

Proposed fold: before merge, run `drafter check-prompts` (or the parity matrix) over cairn's module
and count the rendered `.md#` tokens. Record the count in the PR body and document the form in
`prompts-module.md`.

### m5. Several absent, empty, and malformed states have no named report (correctness)

Location: plan:93-96, plan:146-154, plan:160-164.

Defect: these states are unnamed:

- a `prompts` path that doesn't exist, when `Sources()` hashes it for the row;
- a track glob `path.Match` rejects (`ErrBadPattern` surfaces only at match time);
- `tracks: []`;
- an empty `reader`;
- a duplicate track `name` (a decode error or a check error?);
- a register with no `## The page anatomies` heading, or with that heading and no entries;
- a glob that matches no page.

Proposed fold: name each one's severity and message in resolutions 4 and 8 and add a row to F2.4's
tests. The prompts row could read `<path> (missing)`.

### m6. Resolution 9's anatomy rule disagrees with resolution 6's token choice (correctness)

Location: plan:161-163 and plan:126-130.

Defect: an anatomy counts as known when "an entry in a register the outline's tracks name". That is
any track's register. The stock read takes the page's own track's register. A page in a track with
no register, whose type names another track's register entry, passes the check. Its read then
inlines `no excerpt: no heading <slug>` from `drafter:anatomies.md`.

Proposed fold: decide known-ness by the page's own track, or, under M8 (b), require every page of a
register-only type to match a track that names that register.

### m7. The new fix text still names a register, against the design's wording, and `blueprint-format.md` keeps the old sentence (optional)

Location: plan:170-172; F2.4's docs item at plan:254-255.

Defect: the design says `check.go`'s fix text "stop[s] naming a register". The plan's text says a
register entry needs a track that names the register. `docs/blueprint-format.md:205` ("The
`anatomy` names the register entry") and `:482-484` are what the skill's `format.md` link serves.

Proposed fold: record the conditional mention as a departure in the PR body, or word the fix as
"name a stock anatomy (…), or declare a track whose register holds the entry". F2.4 rewrites
`blueprint-format.md:205`.

### m8. A stock-module run started before cairn sets the guard can't resume after it — OWNER FORK (correctness)

Location: plan:86-91 and plan:407-411.

Defect: `newRunner` runs `Validate(ScopeRun)` on the current config before the resume
(`start.go:36`). Once `require_prompts = true` lands, a run that started on the stock module
refuses to resume, though its run copy exists.

Options: (a) refuse: the guard means cairn never runs stock prompts, and a resume is a run.
(b) exempt resume: the module was fixed at start. Recommendation: (a), named in resolution 3, since
no such cairn run exists today: cairn's reads already fail on `prompts`.

### m9. The early-return summary in `runRead` prints no `prompts:` line (correctness)

Location: plan:96-104 ("every run report").

Defect: when every page is unchanged, `runRead` writes `pipeline.Summary{Pages: skipped}` without a
runner (`cmd/drafter/read.go`, the `len(handoffs) == 0` branch), so the summary has no module
fields.

Proposed fold: fill the two fields from `c.Module()` in that branch, or say that this path reports
no module because no prompt was rendered.

### m10. The stock builder can read `c.page` directly (optional)

Location: plan:126-127.

Defect: `pageJSON` already returns the resolved entry whose `path` is the page's
(`internal/pipeline/steps.go:52-64`). That is `c.page`, so the builder needs no
`DRAFTER_HOST.resolved.pages` search. Also, `entryJSON`'s new fields need the outline's types and
tracks, so its signature changes (`cmd/drafter/read.go`, `entryJSON(p blueprint.Page)`).

Proposed fold: use `c.page.anatomy` and `c.page.register`, and note the signature change in F2.3.

### m11. "Refuses before any request" is false as worded (optional)

Location: plan:240.

Defect: `begin` calls `CheckWorkspace` (`GET /v1/models`) at `start.go:131`, before `loadModules`
at `start.go:181`. It also creates the run directory and writes the input copies (`copyInputs`,
`start.go:170`) before the refusal, so the refused run leaves a directory with no `state.json`.
That is today's behavior for any module load error.

Proposed fold: write "before any spend (`stub.submitted()` is empty)" and name the leftover
directory as expected. The ordering itself checks out: `loadModules` runs inside `newRunner`, before
`loop` (`pipeline.go:164-172`), and on resume before `settleOpen` (`resume.go:78-85`).

### m12. The plan doesn't say how `register.<track>` relates to the outline's tracks (optional)

Location: plan:146-154.

Defect: `drafter.toml` already has a per-track register-sections map (`config.Register`,
`configuration.md`, "Facts and registers"). The onboarding design keeps it "for cairn's module
until B5". The plan never mentions it, and the two "track" names can drift apart.

Proposed fold: one sentence in resolution 8: the config's `register.<track>` stays as it is and is
not matched to the outline's track names.

### m13. F2.5's replay by hand is ceremony a five-minute program replaces (optional)

Location: plan:328-331.

Defect: computing `Joined` and `Bullets` by hand from `git show` and `drafter refs` across four
conflicts is slow and error-prone. `drafter refs` lists citations; it doesn't diff revisions.

Proposed fold: a throwaway `go run` in the scratchpad that calls the new `blueprint.Compare` on
`git show <rev>:<blueprint>`, the outline entry, and `plan.LoadFacts` at each revision, then prints
`Bullets`, `Joined`, and the `untouched` verdict for each saved conflict. Paste the output.

### m14. F2.4's 90 minutes undercounts the fixture churn (optional)

Location: plan:35-40 and plan:247.

Defect: the path arithmetic checks out: 10 + 90 + 75 + 60 + 30 + 10 = 275 ≤ 400. Both shadow tasks
fit (F2.2 50 ≤ 90; F2.6 40 ≤ 75). But the B1 probe broke 30 tests across 3 packages. Without M4's
fold, F2.4 runs past twice its estimate.

Proposed fold: with M4 adopted, F2.0 becomes 20 minutes, and the path becomes 285, still inside
400.

### m15. F2.0 is a single-deliverable task (optional)

Location: plan:207-214.

Defect: the checklist folds a single-deliverable task into a neighbor. F2.0 is justified as the
pre-pair API freeze, but it carries one deliverable.

Proposed fold: merge it with M4's fixture sweep, "F2.0: the stock skeleton and the `introPlan`
fixture sweep (20 min)".

### m16. The resume test's wording invites a vacuous proof (correctness)

Location: plan:235-237.

Defect: "swaps the run's recorded config" can be read as editing the run directory's
`config.json`, which a resume never reads: `useCopies` reads only `state.Inputs` and
`fingerprint.json`. That test passes whatever the report does.

Proposed fold: covered by M5's fold, which names the project config.

## Claims verified as stated

- Resume uses the run copy with no `resume.go` edit. `copyInputs` writes the module as `prompts.js`
  and records `state.Inputs["prompts"]` (`start.go:209-216`), and `useCopies` reads it back with a
  hash check (`resume.go:121-137`). This holds once `copyInputs` and `loadModules` call `Module()`.
- `loadModules` runs before any spend, on start and on resume (cited in m11).
- `drafter:<name>#<slug>` survives tokenizing: `tokens` splits on whitespace and `` `'"()[]<>, ``
  only (`files.go:104-116`). Neither `drafter:` nor `#` currently resolves, so the new forms don't
  collide.
- New fields on `run.Input` and `blueprint.Scope` are safe for state loading. `LoadState` is a plain
  `json.Unmarshal` with schema 2 (`internal/run/state.go:116-129`), which ignores unknown keys.
  m1's `omitempty` hazard is the one condition.
- #12 is computable in `Compare`. `bulletChanged` over `citedFacts` of both revisions gives
  `Bullets`, and the `citedFacts(cb)` minus `citedFacts(ob)` set difference gives `Joined`
  (`since.go:136-144` and `since.go:242-250`). The saved run `20261019T011248Z-60cf77b3` has scope
  facts `["f:ogokfy", "f:vg42j3"]`, as the evidence states. All four run directories and all five
  cairn commits exist.
- The stock package adds no import cycle: `config`, `assemble`, and `blueprint` import `stock`, and
  `stock` imports nothing internal. Pair file sets are otherwise disjoint: F2.4 adds
  `stock.Anatomies` and F2.2 only reads `stock.Files`. In pair B, F2.3 (stock files and `read.go`)
  and F2.5 (`since.go` and `pipeline/blueprint.go`) don't overlap.
- The link arithmetic is right: `anatomies.md -> ../../../../stock/anatomies.md` matches the
  `format.md -> ../../../../docs/blueprint-format.md` precedent that `tests/install.test.sh:49`
  checks.
- Good Docs templates `v1.6.0` has `concept`, `how-to`, `tutorial`, `reference`, and
  `troubleshooting` (GitLab tree API at ref `v1.6.0`).
- The register section `## The page anatomies` (cairn `docs/internal/docs-register.md:752-823`)
  ends at `## The four tracks`, as the excerpt rule expects. Its entries are bold-lead bullets
  (`**Concept page**`, `**Tutorial milestone**:`, `**Symptom row**`, and others).
- cairn's blueprint carries `introPlan` (`rotate-the-github-app-key.blueprint.yaml:196`), and cairn
  has no `drafter.local.toml`.
- The risk class `runner` fits. No money or ledger path changes. F2.5 changes when a change read
  accepts, and that decision is covered by its fail-closed rows.
