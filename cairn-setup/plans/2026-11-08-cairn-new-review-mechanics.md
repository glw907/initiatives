# Review: cairn new plan and spec, mechanics and feasibility lens

Reviewer: `standards:plan-reviewer` (Opus, medium), 2026-11-08. Saved by the planning session from
the agent's reply, verbatim in content. Targets: `2026-11-08-cairn-new-plan.md`,
`../specs/2026-11-08-cairn-new-spec.md`, against the design, cairn-cms `d27ea60b0`, cairn-pub
`85c97cc`. Scratch probes: the planning session's scratchpad `pflagprobe/` and `rc4/`.

Verdict: not ready to launch; five blockers break the build, CI, or the live site as written.

## What holds (verified)

Every path-minute sum is right (P1 840, P2 450, P3 720, P4 285, P5 495, P6 450, P7 195 or 375,
chain 2,955), and so are the 0.41 median and the 3,685. Spec claims checked: transport (host pin,
15 s timeout, no redirects, nil RoundTripper falls back to `http.DefaultTransport`,
`transport.go:12-58`; production leaves `deps.transport` nil, so the HTTPS_PROXY premise holds);
npm tarball served from `registry.npmjs.org` (probed); `nacl/box.SealAnonymous` exists and matches
libsodium sealed boxes (pkg.go.dev); engine auth (`store.ts:90-94,208`, `auth-routes.ts:341-347`,
`:382-383`, `crypto.ts:68`, the 303 to `/admin/login`); site-facts serializer
(`internal.ts:665-676`); `claude plugin validate <path>` exists (probed); cairn-pub's pin and
loader arms (`loader.ts:24-28`).

## Blockers

**B1. T1.2's template bake never reaches the published engine, and moving the bake script breaks
CI** (correctness; plan:232-239, spec 2). `publish.yml:120` packs the engine with `npm pack
--ignore-scripts`, and `:196,239,322` publish with `--ignore-scripts`, so a root `prepack` never
runs on the release path and the released tarball has no `template/`. T1.2's listing test passes
locally only because a local `npm pack` runs prepack. Moving
`packages/create-cairn-site/scripts/bake-template.mjs` breaks every caller: `test.yml:85-89`,
`publish.yml:128`, `create-site.yml:62` (all `node scripts/bake-template.mjs` from
`packages/create-cairn-site`), `emit-template-dir.mjs:20`, `bake-template.test.mjs:14`,
`test/kit3-template-shape.test.mjs:18`. The root `.gitignore` has no `template/` entry (only
`packages/create-cairn-site/.gitignore:1`). Fold: an explicit bake step before `publish.yml:120`;
the listing test runs the exact release command (bake, then `npm pack --ignore-scripts`); add the
three workflows, the importer, both tests, and the root `.gitignore` to T1.2's files.

**B2. The e2e harness and T1.5's tests have no usable keyring seam** (correctness; spec 5, 13;
plan:89, 244-247, 319-324). T2.1 runs the real binary as a child, so it cannot call `MockInit`
(`keyring.go:22-26` offers only in-process package variables). `make -C tool check` runs `go test`
on Geoff's workstation, so the e2e would write the GNOME keyring or wait on an unlock prompt; CI
has no Secret Service, so every keyring call fails after the 2 s deadline with
`ErrKeyringUnavailable`. `TestKeyringLibraryOnlyInKeyringGo` (`keyring_test.go:308-345`) fails any
file other than `keyring.go`/`keyring_test.go` importing go-keyring, so T1.5's `setup_test.go`
cannot call `zkeyring.MockInit()`. Fold: spec 13 names a keyring backend the child honors (an
environment-selected in-memory or file backend, gated so a release build ignores it); T1.5 tests
go through the existing package-variable seam or keep `MockInit` in `keyring_test.go`; correct
plan line 89.

**B3. T6.4's deletion breaks shared sources and its grep cannot pass** (correctness;
plan:512-521). `packages/create-cairn-site/src/site-config-path.json` is read by
`src/tests/unit/site-config-path.test.ts:27`, `scripts/build/emit-tool-conditions.mjs:19`, the
`tool-conditions.yml:13,22` path filters, the reference in `src/lib/content/compose.ts:18`, and
`tool/internal/doctor/siteconfigpath.go`. `scripts/checks/transcript-blocks.mjs` resolves docs
markers against `packages/create-cairn-site/test/fixtures/transcripts/`; `is-it-working.md:23,48`
quote doctor transcripts there. `git grep 'packages/create-cairn-site/src'` hits 29 files today
(`BACKLOG.md`, `ROADMAP.md`, `scripts/gate/{gate,legs}.mjs`, `gate-table.json`, eight comment
sites under `tool/internal`); "Files: as named" names none. Fold: move `site-config-path.json` to a
neutral home in P1 or early P6; move the transcript corpus out of the wizard's tests or retarget
the gate; give T6.4 an explicit file list; scope the grep to exclude ledgers and records.

**B4. Tasks commit tests that stay red until a later task lands** (correctness; plan:181-183,
321, 364, 494, 223-227). Rule: `running-passes` "Do not start the next task on a red". T2.1's
goldens fail until T2.2 and T2.3; paired with T2.2, they are written without the command, so they
prove nothing. T3.1's placeholder golden fails through T3.2; T3.1 adds five requires before
anything imports them and `tidy-check` (`go mod tidy` plus `git diff --exit-code`) removes them.
T6.1 fails until T6.2. T1.4 adds `spine.Step` constants, breaking
`TestStepConstantsMatchNodeRecordSteps` (`step_test.go:80-108`, Go set must equal the JS literal
set); `step_test.go` is not in T1.4's files. Plan:180 "every task commits once" contradicts the
auth-data test-first commit. Fold: a failing test lands with its fix or carries a skip guard the
later task removes; e2e goldens move to T2.3; each require lands with its first importer; T1.4
updates `step_test.go` or puts setup steps in their own type outside `allSteps`.

**B5. On a yes to Decide 4, P7 breaks live cairn.pub at merge** (correctness; plan:535-539). T7.4
ports the loader but keeps the pin at `0.94.0-rc.1`; P7 merges itself and `main` deploys, so the
loader reads arms the installed package lacks. The published `0.99.0-rc.4` tarball already ships
`docs/admin` (11 files) and `docs/editors` (8) (probed). Fold: T7.4 moves the pin to `0.99.0-rc.4`
in the same PR and tests against it; the packed-`main` tarball is an extra test.

## Major

**M1. "Main stays releasable" is false from P1** (correctness; OWNER FORK; plan:174-178). T1.9
puts `deploy.yml` in `templates/waymark` and limits `check.yml` to `pull_request`; the wizard bakes
this template, so an engine release between P1 and P6 ships wizard sites that fail Actions on
every push (no `CLOUDFLARE_API_TOKEN`) and have no push CI, and `scaffold.mjs:253` "runs on every
push" becomes untrue. P2 publishes `docs/admin/setup-reference.md` (in the engine's `files`,
rendered by cairn.pub) and the help-agents setup contract for a hidden command; a tool tag ships a
working hidden `cairn new`. `latest` is `0.98.0`, with no `template/`, so a shipped `cairn new`
fails its fetch. Options: (a) freeze engine and tool releases from P1 to P6 (conflicts with
rebuild-driven releases); (b) keep setup-only files out of shipped surfaces until P6, for example a
setup overlay the wizard's bake skips. Recommendation (b). Either way, add to "Before the first
release": an engine carrying `template/` is `latest` before the tool shows `cairn new`.

**M2. The autoMode grant's premise is false and unproved** (correctness; plan:36-52, 166-168). The
grant says changes take effect only after Geoff merges, but P4 (T4.3) and P5 (T5.6, T5.7) are
`ordinary` and merge themselves; `pass-core` says `runner` covers skills, agents, workflows, so P5
is at least `runner`. The check is a grep only; `pass-core` asks for a path a `claude --bg` probe
proved. Fold: reclassify P5 (and P4 if the template's `.claude` counts) to `runner` with packets;
add a probe item that writes and reverts one held file in a worktree.

**M3. Harness `GIT_CONFIG_COUNT` collides with the production push** (correctness; spec 7, 13).
Both set `GIT_CONFIG_COUNT`/`KEY_0`/`VALUE_0`; the last writer wins, and the #352 scrub may strip
the harness's entries. Fold: production appends after inherited entries; ADR-0003 records it; the
harness self-test proves both reach git.

**M4. `--plan <file>` and `--plan --json` cannot both parse** (correctness; spec 11, plan:326).
Probed pflag v1.0.10: as a string flag, `--plan --json` sets plan to `"--json"`; with
`NoOptDefVal`, `--plan plan.json` sets plan to `"-"` and strands `plan.json`. Fold: name the dry run
`--dry-run --json`, or require `--plan=<file>`; record that the design's literal syntax is
unparseable.

**M5. S1 is not runnable as written** (correctness; plan:55-60, 203-212, 565-570; spec 12). Item 4
runs a script that exists only in the P1 worktree, whose path is unknown at pre-flight; nobody
commits the recordings; writing into a live executor's worktree breaks one-executor-per-worktree.
The port probe and a missing-scope 403 each need another consent. Unrecordable on known state:
email-onboarding POST (Email Sending already on for `carin-test.org`, `test-accounts.md:69`), "zone
pending" (none pending), the Worker-secret PUT and Decide 3's run read (both need a real Actions
deploy; the recorder predates `deploy.yml`). The recorder's first live run is the sitting
(`pass-core` asks for a tested script), with no crash-cleanup answer and no latency timing against
the 15 s timeout. Fold: exact directory and command; the recorder writes outside the worktree and
the executor copies and commits; a dry run against `test/fake-server.mjs` that T1.0 runs; a
`--cleanup <run-id>` the standing answers name; list unrecordable routes; record latency; include
one real Actions deploy with the minted key (probes its scope for `d1 migrations apply --remote`
and deploy). Better: run S1 before launch as a throwaway probe, settling the three probe branches
and Decide 3's facts before approval; same sitting cost.

**M6. Cited lines say something else; two engine facts misstated** (correctness; spec 2, 3, 6, 7,
9, 10). `scaffold.mjs:249-260` is README prose (restore near `:48`); `repo.mjs:254-282` (cited
twice) is the Git Data push (422 handling `:68`); `bootstrap.mjs:179-226` is out of range (134
lines; seed `:87-120`); `api.mjs:501`, `:511` list by `name` and list all records;
`substitute.mjs:280-291` is the AI-posture block, not `createGithubApp`. The seed is three
statements (owner insert with role `'owner'`, a `DELETE`, a token insert), and the stored hash is
lowercase hex (`bootstrap.mjs:94`, `crypto.ts:106`), not "two statements" and base64url. Decide 2's
premise that the owner "can never use that link" is contradicted by `rebindToken`
(`auth-routes.ts:372-376`). Fold: recite each line; correct Decide 2's premise before the packet.

**M7. T1.1's fixture move misses CI and gate triggers** (correctness; plan:192-201).
`tool.yml:17,33` and `gate-table.json:68` (`toolInputs`) name the old fixtures path; the grep
`-- tool packages` cannot see them. Fold: add both files, widen the grep to the tree minus history
files, class T1.1 `runner`.

**M8. Command tree and copy pins missing from file lists** (correctness; plan:326-346).
`TestEveryActionCoverage` (`coverage_test.go:47+`) pins the command set and flags: add `cairn new`
(T2.2) and `cairn new status` (T2.3); T2.3 regenerates `flags.json`. The help-agents text is
`agentsPage` in `messages.go:197` (T2.2's file), not `help_agents.go`. `cmd/copylist/main.go:26-28`
collects only health, doctor, spine, and `cmd/cairn`, so setup and `newview` strings never reach
`copy.golden.md`. Fold: add these files; give a P2 or P3 task `tool/cmd/copylist`.

**M9. Direct-require count and paired module edits collide** (correctness; plan:285-287, 359-364,
381-384). `purity_test.go:184` holds `otherDirectRequires = 6`. T3.5 (Fang) lists neither
`go.mod`/`go.sum` nor `purity_test.go`, while T3.3 may touch them; Fang's styled help may break
`cmd/mangen`, unlisted. Fold: each require lands with its first importer; T3.5 owns its module
lines and runs after T3.3, or the pair is re-cut.

**M10. The CI e2e hits the opening checks** (correctness; spec 8, 13). CI Linux has no `DISPLAY`
or `WAYLAND_DISPLAY`, so the no-display stop fires unless `$BROWSER` overrides it; Node 24 needs
`setup-node` in tool.yml's job (T2.1 omits tool.yml); fixed port 49152 blocks parallel tests; the
HTTPS-wait host is not among the proxy's hosts. Fold: state each in spec 13; add tool.yml to T2.1.

**M11. P5's docs cannot pass their own gates** (correctness; plan:438-482). The pages describe
P6's launcher, so a fresh fact-checker cannot return no finding at P5. `transcript-blocks.mjs`
fails on a fixture neither quoted nor declared unconsumed; the rebuild drops the wizard transcript
quotes and no task records `cairn new` transcripts. T5.1 to T5.4 and T5.7 lack Files, class, and
test fields; T5.4's pages need `docs/admin/README.md` entries, which T5.3 owns. Fold: fill each
task's fields; add a transcript capture and README update; give P6 the launcher sentences or give
the fact-checker a stated deferral list.

**M12. Naming and branch gaps** (correctness; spec 3, 7, 9). App names are unique across GitHub;
the wizard let the user edit the name (`chapter.mjs:264`); `cairn new` has no answer for a taken
`cairn-<base>`. OWNER FORK: (a) login-qualified name, (b) the owner edits the name in the tab and
the slug is read back, (c) random suffix; recommendation (b). With `auto_init: false` there is no
default branch until the first push: `git init -b` the reported `default_branch`, and add a spec 9
row for `deploy.yml`'s branch filter. A private-name 422 at approval 3 changes the base after the
Cloudflare checks ran, so rerun them. `account_id` has no anchor in the template's
`wrangler.jsonc`.

**M13. The answer matrix cannot `npm install` an unpublished engine pin** (correctness;
plan:261-272). The exact pin is not on the registry, and the template also depends on
`@glw907/cairn-cms-dev`. Fold: state the local-tarball override (the `create-site.yml` pattern) for
both packages.

**M14. T6.1's mechanism is unstated** (correctness; plan:491-494). `npm create cairn-site` always
resolves from the registry. Fold: install both tarballs into a temp directory and run
`node_modules/.bin/create-cairn-site`, or `npm exec --package=<tgz> --package=<tgz>`; say how a
`node --test` file reaches the Go harness.

**M15. Every new site's health reads UNKNOWN** (correctness; OWNER FORK; plan:624-627).
`check_deploy.go:193` returns Unknown with no Builds triggers. Options: (a) file and accept at ship;
(b) fix in P6 so the deploy check passes for Actions-deployed sites. Recommendation (b).

**M16. Risk classes do not fit the real risk** (correctness; OWNER FORK; plan:251-300). T1.6,
T1.7, T1.8, and T1.10 are `ordinary` by the path map, so none writes its failing test first; only
Geoff raises a class. Recommendation: raise T1.8 and T1.10, and add `tool/internal/setup/**` and
the provider OAuth files to the `auth-data` map. Mark T1.0 `live-account` and run the admin smoke
anyway, since Decide 1 rests on an unbound row confirming through GET-then-POST.

**M17. T1.0's estimate is far too low** (optional; plan:203). A second, Node implementation of the
whole write sequence at 75 minutes against 150 for each Go half. Fold: 180 or more, or narrow it to
the spike scripts' coverage.

## Minor

1. "Every task commits once" contradicts the test-first commit (plan:180-183); fold into B4.
2. The executor prompt does not require each accepted-task report to name the CI verdict on that
   head (plan:180).
3. The closes (T5.8, T6.5) do not rerun `check:docs-gate` after the last docs edit.
4. T4.3 names no source for the template's `.claude/settings.json`; `.claude` is excluded from the
   showcase emit (`.cairn-template.json`), and `templates/waymark/.claude` is the guidance tree
   with a MANIFEST; check how they interact.
5. `node --test tool/scripts/record-fixtures/` runs in neither the fast lane nor CI.
6. T1.8's pages live in the initiatives repo; give the absolute path.
7. S1 uses `carin-test.org`, shared with the release-gate legs; name what other sessions change
   there and the rerun rule.
8. No docs search is named before the S1 probes; RFC 8252 section 7.3 and Cloudflare's OAuth docs
   may settle the loopback-port question.
9. The spec drops the design's minted short-lived tokens (end of spec 6) without a Decide; list it
   in the packet.
10. Pre-flight item 1's check validates only the id's shape; say S1 first proves the redirect and
    scopes.
11. No general standing answer for the success bar becoming unreachable.
12. T6.3's `npm publish --dry-run` may be refused under auto mode; probe or note it.
13. T4.2's `register-check` "no open finding" and T5.6's "names no flag the reference lacks" have
    no stated check.
14. Over-ceremony: "The design's estimate" (plan:543-553) sets its own bar from guessed actuals and
    compares the plan to it; name it self-set in the packet or cut it.

## Pair disjointness

Pairs A to D in P1, the P4 pair, and T6.3 with T6.4 are disjoint as listed, though the lists are
incomplete (B1, B3, M7 add files; T6.3 and T6.4 may both need root `package.json` scripts). T3.3
with T3.5 is unsafe (M9). The P5 pairs cannot be checked (M11). T2.1 with T2.2 is disjoint but its
proof is empty until T2.2 and T2.3 exist (B4).
