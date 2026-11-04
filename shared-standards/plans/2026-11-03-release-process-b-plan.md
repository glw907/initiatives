# Pass B plan: release process and infra

Initiative: shared-standards
Spec: /var/home/glw907/Projects/initiatives/shared-standards/specs/2026-11-03-release-gate-and-process-design.md@d880b9e
Class: runner
Branch: release-process-b
Executor: cairn-cms-release-process-b (sonnet, medium)
Conductor: conductor-cairn-cms
Push target: glw907/cairn-cms, glw907/workstation

Base: `origin/main` at launch (`bb3c8d3a2` when written; every file:line below is at that commit).
Scope: the spec's "Pass B: release process and infra" section and the pass B rows of "Backlog
verdicts". Pass A runs beside this pass in a separate worktree; this plan never touches a pass A file.
Load at start: `cairn-pass`, `pass-core`, `cairn-running-passes`, `claude-infra`.

## Pre-flight

Each item is done and checked before the conductor launches the executor.

1. **[you] Settings grant (spec "Your steps" 5).** Run
   `bash ~/.local/state/cairn-agent-first/apply-release-process-grant.sh` (dry-run first with
   `--dry-run`). Its one `autoMode` line, marker `release-gate-and-process`, covers until pass B's
   PR merges:
   - edits and commits in the pass worktree
     `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/release-process-b` only, never a pair
     worktree under `.claude/worktrees/agent-*`, limited to `.claude/settings.json` (only the one
     PreToolUse entry for `gh release create` and the two allow rules in task B5),
     `.claude/hooks/release-cut-guard.mjs`, `.claude/agents/cairn-implementer.md`,
     `.claude/skills/cairn-releasing/**`, and `.claude/skills/cairn-running-passes/**`;
   - edits, commits, a push, and a PR in a `~/.dotfiles` worktree on branch `release-process-b-ws`,
     limited to `claude/.claude/skills/pass-core/SKILL.md`, for task B8 only. This one file goes
     beyond spec step 5's wording ("pass B's worktree"), because line 417 of
     `~/.dotfiles/claude/.claude/settings.json` clears a dotfiles skill edit only on approval "in
     the current session", which the executor never has (owed erratum E3 in the fold record).
   Pair subagents never write a `.claude/` file: they hand that content back, and the executor
   applies it in the pass worktree ("Handback" under "First act"; ruling 2 of the fold record).
   Before the run: `git -C ~/.dotfiles rev-list --count origin/main..main` prints `0` and
   `git -C ~/.dotfiles status --porcelain` prints nothing, since the script's `pull --ff-only` fails
   on a diverged checkout after its PR has merged (integrity I20).
   Check: `grep -c 'release-gate-and-process' ~/.claude/settings.json` prints `1`.
2. **[session, else you] GitHub environment and the `main` ruleset (spec "Your steps" 4, less
   the `release-tags` ruleset).** No pass B task needs them to run. B3 names the `npm-publish`
   environment, and the `rc.4` cut depends on it. Run the spec's environment `PUT`, its `v*` tag
   policy `POST`, and the `main` ruleset `POST` (its fourth command); skip the third command, the
   `release-tags` `POST`. That ruleset is posted in the `rc.4` run sheet right after the publish run succeeds and
   before promotion, so a `publish.yml` defect found before any package publishes is fixed on
   `main` and the unpublished tag and release are deleted and recut (ruling 4 of the fold record;
   owed erratum E1). Check: `gh api repos/glw907/cairn-cms/environments/npm-publish/deployment-branch-policies --jq '.branch_policies[]|[.name,.type]'`
   prints `["v*","tag"]`, and `gh api repos/glw907/cairn-cms/rulesets --jq '.[].name'` lists
   `pre-agent-first` and `main` and not `release-tags`.
3. **[you] npm sitting (spec "Your steps" 1).** Pass B uses no npm credential. The sitting closes
   #337 and binds the environment that B3's publish jobs name. Check: the spec's step 1 done-line.
4. **Conductor pre-launch checks (`pass-core` "Execute").** The main checkout is on `main`,
   `git -C /var/home/glw907/Projects/cairn-cms rev-list --count HEAD..origin/main` prints `0`, and
   `git -C /var/home/glw907/Projects/cairn-cms check-ignore -q .claude/worktrees/x` succeeds.
   No session has `release-process-b` checked out (`pgrep -f '[r]elease-process-b'` is empty; the
   bracket keeps `pgrep` from matching its own `bash -c` wrapper, mechanics 5).

P-DEP is settled at plan time, so `withdraw` needs no probe. The npm trusted-publishers page
(<https://docs.npmjs.com/trusted-publishers>) says "OIDC authentication supports `npm publish`,
`npm stage publish`, and the dist-tag operations described above" and "Other npm commands such as
`install`, `view`, or `access` still require traditional authentication methods". `npm deprecate`
is not among the supported commands, so `withdraw` prints its commands and the workflow gains no
`withdraw` input.

Permissions checked: B1 to B4 write only tracked repo files inside the pass worktree or pair
worktrees and read the registry (`npm view`, registry fetch) and GitHub (`gh api` GET, `gh release
view`), which are reads auto mode allows. B3's actionlint case runs `go run` of a pinned module,
a build of public source with no credential. B5, B6, and B7 carry `.claude/**` content, which auto
mode refused as Self-Modification on 2026-11-02 and 2026-11-03
(`~/.local/state/claude-denials.jsonl`). Their pair subagents write none of it: they hand it back,
and the executor writes it in the pass worktree, which pre-flight item 1 covers. B7's probe runs harmless forms, and a refusal is its expected
result. B8 writes a dotfiles skill and pushes to glw907/workstation, covered by item 1 and the
push target above. No task publishes, cuts a release, dispatches a workflow, or touches a
credential. The post-merge hook probe is the conductor's step, covered by the user rule
`Bash(gh release create v* --target * --title *)` (`~/.dotfiles/claude/.claude/settings.json:40`),
and the hook decides before any permission check.

Reviewed: three-lens plan review (contract, mechanics, integrity), folded per 2026-11-03-release-plans-fold.md

## First act

`EnterWorktree` with the branch `release-process-b`, then the setup command in the new worktree:

```sh
npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync) && npm --prefix packages/create-cairn-site run prepack
```

Then arm the API-drop wake-up (`/loop` with no interval) and the lid-switch hold per
`~/.claude/docs/unattended-work-guards.md`. Write the session name and id into `docs/STATUS.md`
under a `## Pass B (release-process-b)` block. This block holds every stop, and B9 removes it.

Each task writes `.pass-task-clock` at the worktree root at its start and removes it at its end.
Each task's gate is `CAIRN_GATE_LANE=<lane> cairn-run-gate 'npm run lane:fast -- --range <base>..HEAD'`
with `timeout: 600000`, re-issued on exit 75. A pair's subagents run `npm run lane:fast` themselves.
Pair dispatch: `cairn-implementer`, `isolation: "worktree"`, `description: "release-process-b task B<n>"`.
Each dispatch quotes the task block verbatim, since the implementer does not read the plan.
Each accepted-task or pair report to the conductor names the CI verdict on that head
(`ci-green <sha> --pr <n>`), or `pending` with the run id (mechanics 6).

**Handback (B5, B6, B7; ruling 2 of the fold record).** A pair subagent never writes under
`.claude/`. For each `.claude/` file in its task's list, it writes the full intended content to
`<its worktree>/handback/B<n>/<path with the leading .claude/ replaced by dot-claude/>`, leaves
`handback/` untracked, and commits every other file of its task. A test that reads a `.claude/`
file (B5's hook and settings test) is committed and runs red in the pair worktree for that missing
file only; the report says so. After merging the pair, the executor copies each handback file to
its `.claude/` path in the pass worktree, commits them as `Apply B<n>'s .claude files`, and runs
the fast lane there, which must pass. About 10 minutes for the pass.

## Tasks

### B1. The two checks the scripts import (serial head)

- Outcome: `check-stable-source.mjs` exports `RULES`. Its CHANGELOG predicate (`:50`) also accepts
  `^Released \d{4}-\d{2}-\d{2}\.$`. A changed path in the ignore set skips every check, status and mode
  included, before the checks at `:123-125` run (ruling 17). The set is the spec's four globs
  (`scripts/gate/**`, `src/tests/**`, `packages/*/test/**`, `examples/showcase/e2e/**`) plus the
  inert paths that ship in no package (`docs/STATUS.md`, `BACKLOG.md`, `ROADMAP.md`,
  `docs/internal/**`), so the conductor's STATUS and backlog commits after `rc.4` do not block the
  stable (ruling 3 of the fold record, by ruling 17's own principle; owed erratum E2). `.github/**`,
  `scripts/build/**`, and `package.json` stay checked. The root `files` list ships `docs/admin`,
  `docs/editors`, `docs/why-cairn.md`, and `docs/architecture.md`, never `docs/STATUS.md` or
  `docs/internal`. `close-prebuilt.mjs` checks
  `node_modules/.bin/svelte-package` and `examples/showcase/node_modules` before `buildDist`
  (`:143`) and exits 1 printing `npm ci` and `npm ci --prefix examples/showcase` (#346). That
  check is exported for `preflight`.
- Files: `scripts/checks/check-stable-source.mjs`, `scripts/checks/close-prebuilt.mjs`,
  `src/tests/unit/check-stable-source.test.ts`, `src/tests/unit/close-prebuilt.test.ts`, and new
  fixture files under `scripts/checks/fixtures/stable-source/` if a case needs one.
- Class: runner.
- Acceptance (each fails on main):
  - A stable diff that adds `Released 2026-11-04.` under the heading returns `ok`. Main fails it
    at `:50`, which allows only a heading or a size marker. `Released Nov 4.` still fails.
  - A diff that changes `scripts/gate/legs.mjs`, adds `src/tests/unit/gate-x.test.ts` (status
    `A`), and changes `examples/showcase/e2e/golden-path.spec.ts` returns `ok`. Main fails each at
    `:123` or `:125`. A change to `src/lib/` still fails, as `check-stable-source.test.ts:79`
    asserts. The test at `:123` ("fails a docs/STATUS.md change") flips: a `docs/STATUS.md`,
    `BACKLOG.md`, `ROADMAP.md`, or `docs/internal/x.md` change returns `ok`, and a change to
    `.github/workflows/publish.yml`, `scripts/build/build-guidance-hashes.mjs`, or `package.json`
    still fails.
  - A derived-inputs test builds the shipped inputs: each package's `files` (root `package.json`,
    `packages/cairn-cms-dev/package.json`, `packages/create-cairn-site/package.json`), `src/lib/**`
    and `packages/cairn-cms-dev/src/**` behind `dist`, and the bake's inputs (`examples/showcase`
    less `examples/showcase/.cairn-template.json`'s `exclude`, `skills/`, `claude/`, per
    `bake-template.mjs:185-215`). It asserts no ignored glob matches an input. The same function,
    given an ignore set that adds `examples/showcase/src/**`, must report a collision, so the test
    can fail.
  - `runClose` with the svelte-package binary absent returns 1, never calls `build`, and prints both
    `npm ci` commands. Main calls `build` first (`close-prebuilt.mjs:143`).
- Test: the two existing test files, extended.
- Estimate: 60. Model: sonnet medium, executor inline (the head of the serial chain). Pair: none.

### B2. `preflight`, `bump`, `wait`, `notes` (pair with B3)

- Outcome: four scripts per the spec's "Release scripts" table. Each runs as
  `node scripts/release/<name>.mjs <version> [flags]`, exits 0 or 1, and ends with one `Next:` line.
  Each core is a pure function over a command runner, in the shape of `check-stable-source.mjs:31,95,146-150`.
  `PACKAGES` comes from `check-stable-source.mjs:19`. No shared helper module is added.
  - `preflight`: clean tree; `HEAD` equals `git ls-remote origin refs/heads/main`, printing the
    sha, so a stale local `origin/main` cannot pass (contract 19); the version absent from
    `npm view <pkg> versions --json` on all three; both installs present through B1's export; a
    non-empty `## Unreleased`, which `--stable` skips.
  - `bump`: computes the eight files `check-stable-source.mjs:43-67` allows in memory, then checks
    them and writes. The manifests are the root, `packages/cairn-cms-dev`, and
    `packages/create-cairn-site`. The lockfile `version` lines are edited directly, with no
    `npm install`. The template pins and `VERSION` come from `npm run emit:template` through the
    runner (`package.json` `emit:template`; `emit-template-dir.mjs:204-206` derives the caret spec).
    The CHANGELOG heading is renamed in place with `Released YYYY-MM-DD.` under it, replacing an
    existing `Released` line. The MIGRATION-NOTES heading and its `(./CHANGELOG.md#<slug>)`
    anchors are renamed, following `4644cd35b`'s eight-file stat. It refuses a dirty tree, naming
    `git restore`. It is a no-op on a tree already at the version. It refuses while
    `## Unreleased` sits above a heading on the same numeric core. The date is injectable. If `npm run
    emit:template` fails after the manifests are written, `bump` restores every file it wrote and
    exits 1 naming the emit failure (integrity I22).
  - `wait <version> <tag>`: polls `https://registry.npmjs.org/<pkg>` with `cache: 'no-store'` until
    `dist-tags[<tag>]` equals the version on all three, for up to 10 minutes. On timeout it names
    each package and what its tag holds (#347).
  - `notes`: writes the version's CHANGELOG section plus every `Consumers must:` line other than
    `nothing.`, using `LINE` (`check-consumers-must.mjs:22`), to a notes file. It leaves a marked
    place for the summary paragraph the session writes.
- Files: `scripts/release/{preflight,bump,wait,notes}.mjs`,
  `src/tests/unit/release-{preflight,bump,wait,notes}.test.ts`, and fixture trees under
  `src/tests/unit/fixtures/release-bump/`.
- Class: runner.
- Acceptance (no script exists on main, so each import fails there first; each case below is a
  named fixture):
  - preflight: a dirty tree, `HEAD` behind the faked `ls-remote` answer, the version already in one package's
    `versions`, a missing install, and an empty `## Unreleased` each exit 1 naming the cause. With
    `--stable` the empty window passes. A clean fake exits 0 and prints the sha and a `Next:` line.
  - bump: the `release-bump/rc3` fixture (the eight files at `0.99.0-rc.3` shape) bumped to
    `0.99.0-rc.4` changes exactly those eight files: heading, `Released` line, anchors
    `#0990-rc3` to `#0990-rc4`, three manifests, and the lockfile lines. The fake runner records
    `npm run emit:template` after the manifests are written. A second run writes nothing. A dirty
    fake is refused with `git restore` in the message. An `## Unreleased` over `## 0.99.0-rc.3` is
    refused. Round trip: the fixture bumped from `rc.4` to `0.99.0` yields a diff that
    `checkStableSource`, with a fake runner serving that diff, returns `ok` for. That case needs
    B1's `Released` predicate and fails without it.
  - Real-tree check, in the pass worktree on a clean tree at B's launch-time base (before any
    rebase onto a `main` that carries pass A's `## Unreleased`, where `bump` rightly refuses;
    contract 20): `node scripts/release/bump.mjs 0.99.0-rc.4` leaves `git diff --name-only`
    listing exactly the eight files, and `npm run check:version` exits 0. Then `git restore` those
    eight files, and `git status --porcelain` prints nothing (integrity I22). Paste both outputs in
    the report.
  - An emit failure injected through the fake runner leaves the fixture tree unchanged.
  - wait: a fake fetch serving `gate` one step behind on one package polls until it matches. A
    fake that never matches times out naming each package and its tag value. Each request carries
    the no-cache option.
  - notes: a CHANGELOG fixture with `Consumers must: nothing.` and two actionable lines writes a file
    holding the section and exactly the two actionable lines.
- Estimate: 140. Model: sonnet medium. Pair: B3.

### B3. `publish.yml` hardened, and its pins (pair with B2)

- Outcome: the spec's "`publish.yml`" bullets, in full:
  - Top-level `permissions: contents: read`, with `id-token: write` only on the publish jobs and
    `promote`.
  - The publish jobs run only on `release: published`. The `inputs.promote == ''` path
    (`:31,100,154`) goes.
  - A `ci-green` job polls `GET /repos/{repo}/commits/{sha}/check-runs?check_name=<name>&filter=latest`
    until `test` completes (plus `e2e` for a stable), failing unless each concluded `success`,
    within 45 minutes. GitHub's reference says of `filter`: "latest returns the most recent check
    runs" (<https://docs.github.com/en/rest/checks/runs#list-check-runs-for-a-git-reference>), so
    a rerun `test` is judged by its newest run; the job still takes the highest `id` per name
    (integrity I23). It gets `checks: read`, confirmed against that reference, with the URL cited
    in a comment.
  - `build` has no `id-token` and needs `ci-green`. It fails unless `GITHUB_REF_NAME` is `v` plus
    the version in each of the three manifests. It runs the bounded `npm ci`, `npm run
    check:package`, and `npm pack --ignore-scripts` at the root and in `packages/cairn-cms-dev`. It
    runs the create-cairn-site bake and pack as `:209-210` do and uploads the three tarballs as one
    artifact.
  - `publish`, `publish-dev`, and `publish-create-site` each set `environment: npm-publish` and
    `id-token: write` and need `build`. They download the artifact and run
    `npm publish <tgz> --ignore-scripts --access public --tag "$TAG" --provenance`. They keep the
    already-published guards (`:83-86,126-129`) and the create-cairn-site guards (`:179-205`). A
    publish job may check out the repo to read manifests, but never installs.
  - `verdict` has no `id-token` and runs on dispatch with `GH_TOKEN: ${{ github.token }}`. It does a
    sparse checkout of `scripts/gate/verdict.mjs` and `scripts/gate/record.mjs` with
    `sparse-checkout-cone-mode: false`, since cone mode is the default ("Default: true") and treats
    patterns as directories; actions/checkout's own single-file example sets it false (README,
    `sparse-checkout: README.md` with `sparse-checkout-cone-mode: false`). It runs a sha-pinned
    `actions/setup-node` (node 24) and no install (mechanics 8). It
    checks `GITHUB_REF_NAME == v$PROMOTE_VERSION`, then runs `node scripts/gate/verdict.mjs "$PROMOTE_VERSION"`.
  - `promote` needs `verdict` and sets `environment: npm-publish` and `id-token: write`. It prints
    each package's dist-tags before moving them and keeps its body (`:234-254`).
  - Every third-party `uses:` is pinned by a 40-hex commit sha with the tag in a trailing comment,
    resolved with `gh api repos/<action>/git/ref/tags/<tag>`. An annotated tag is dereferenced
    through `git/tags/<sha>` to its commit, and `gh api repos/<action>/commits/<sha>` must answer.
    This covers checkout, setup-node, upload-artifact, and download-artifact. Local
    `./.github/actions/*` stay as they are.
  - npm is pinned to `npm@11.21.1`, or the newest 11.x that `npm view npm@11 version` lists at task
    time. The WATCH at `:42-45` stays, reworded for the exact pin.
  - The header comment (`:9-13`) describes release-only publishing and the tag-ref promote dispatch
    (`gh workflow run publish.yml --ref v<V> -f promote=<V>`).
  - actionlint, pinned, over every workflow (ruling 4 of the fold record): `workflow-yaml.test.ts`
    runs `go run github.com/rhysd/actionlint/cmd/actionlint@v1.7.12` at the repo root and requires
    exit 0. Probed 2026-11-03 (Go 1.27.3): on main it builds in about 5 s, passes
    `publish.yml`, and fails the set on one finding, `create-site.yml:230` SC2034 (`for i in
    $(seq 1 60)`, `i` unused), which B3 fixes by renaming the variable to `_`. GitHub's Ubuntu
    24.04 runner lists Go only under its cached tools, not on `PATH`, so `test.yml`'s `test` job
    gains a sha-pinned `actions/setup-go` step (`go-version: '1.26.x'`, as `tool.yml:76`) before
    its Vitest steps. actionlint calls the runner's shellcheck (0.9.0 on that image), so a local
    shellcheck may differ; a CI-only finding is fixed like any red. The test fails, never skips,
    when `go` is absent.
- Files: `.github/workflows/publish.yml`, `.github/workflows/test.yml` (the setup-go step only),
  `.github/workflows/create-site.yml` (the SC2034 rename only), `src/tests/unit/workflow-yaml.test.ts`
  (owed erratum E4: the spec's pass B files name only `publish.yml`).
- Class: runner.
- Acceptance (each fails on main's `publish.yml`):
  - The test at `workflow-yaml.test.ts:244-248` is replaced by one asserting each publish job's
    `if` admits only `github.event_name == 'release'`. Main's `:31` admits a bare dispatch.
  - A new test asserts the top-level permissions hold no `id-token`, and that exactly the jobs
    `publish`, `publish-dev`, `publish-create-site`, and `promote` hold `id-token: write` with
    `environment: npm-publish`. Main's `:25-27` grant it workflow-wide.
  - A new test asserts `build` needs `ci-green`, each publish job needs `build`, `promote` needs
    `verdict`, no job holding `id-token` runs `npm ci` or `bounded-install`, and each publish step
    passes `--ignore-scripts` with a tarball argument.
  - A new test asserts every `uses:` that does not start with `./` matches `@[0-9a-f]{40}`. Main's
    `@v7` (`:35-36`) fails.
  - The pin test at `:262-268` asserts the exact pin and the install count the new shape has.
  - The promote stub-npm tests (`:270-323`) still pass against the new `promote` body, and gain one
    assertion that the dist-tags print before the first `dist-tag add`.
  - `verdict` checks out only the two `scripts/gate/` files with `sparse-checkout-cone-mode: false`,
    runs a sha-pinned `setup-node`, and its script contains no `${{`. The test reads the workflow
    only and never requires those files to exist, since pass A creates them (pass A's T5 tests
    their imports).
  - Executable steps, in the shape of the promote stub-npm tests (`:270-323`), because
    `publish.yml` never runs on a pull request (contract 3): `ci-green`'s script body under a
    stubbed `gh api` passes on `test` in progress then success, fails on failure, fails on a stable
    with no `e2e`, takes the newest of a failed run and a successful rerun of `test`, and fails at
    its deadline (an injected short bound); `build`'s ref check fails when one of the three
    manifests disagrees with `GITHUB_REF_NAME`.
  - The actionlint case above exits 0.
  - `.github/ci-green.json` keeps `publish.yml` under `neverOnPullRequest`, and `:122-126` still
    passes.
- Estimate: 145. Model: sonnet medium. Pair: B2.

### B4. `status`, `verify`, `withdraw` (pair with B5)

- Outcome: three scripts per the spec's table, built like B2's.
  - `status <version>`: prints a JSON checklist and exits non-zero until every item holds. The
    items are the tag on origin (`git ls-remote --tags origin`), the release and its
    `isPrerelease` (`gh release view --json`), dist-tags by stage, `dist.attestations.provenance`
    on all three, and the CHANGELOG heading. A complete prerelease has `next` on all three and
    `create-cairn-site@latest` at the version, and `node scripts/gate/verdict.mjs <V>` exits 0. A
    complete stable has `latest` on all three and runs no verdict.
  - `verify <version> [--tag <t>]`: checks that `<t>` holds the version on all three, `<t>`
    defaulting to `gate` for a prerelease and `latest` for a stable (rc.4 step 6 runs it after
    `wait … gate`, before promotion; contract 10), and checks provenance on all three. For a stable it fetches each
    package's tarballs for the final candidate (the version `next` held before the stable, or
    `--from <candidate>`) and the stable, diffs each file, and applies B1's exported `RULES` by file
    kind. `guidance-hashes.json` is checked through `node scripts/build/build-guidance-hashes.mjs
    --check` on the stable tree. Any other differing line fails.
  - `withdraw <version>`: prints the `npm deprecate` and `npm dist-tag` commands for a failed
    candidate. For a promoted one it also prints the dist-tag moves back to the values the promote
    run printed before moving, read from `gh run view <id> --log` given `--promote-run <id>`. For a
    half-published one it deprecates only the published half. It prints only, per P-DEP above.
- Files: `scripts/release/{status,verify,withdraw}.mjs`,
  `src/tests/unit/release-{status,verify,withdraw}.test.ts`, and fixtures under
  `src/tests/unit/fixtures/release-verify/` (the two `cairn-cms-dev` tarballs included).
- Class: runner.
- Acceptance (no script exists on main; named fixtures):
  - status: fakes for each missing item (no tag, `isPrerelease` false on a prerelease, `next`
    behind on one package, no provenance on one, no heading, verdict exit 1) each exit non-zero and
    name the item in the JSON. A complete prerelease fake and a complete stable fake exit 0. The
    stable fake never runs `verdict.mjs`.
  - verify: `release-verify/rc2-rc3.json` holds, per package, the differing paths and their
    differing lines, captured once from the real `0.99.0-rc.2` and `0.99.0-rc.3` tarballs (`npm pack
    <pkg>@<v>` into a scratch dir, read-only). The compare function fails it, naming a source path.
    A synthetic pair that differs only in the manifest `version`, template pins, `VERSION`, the
    CHANGELOG heading and `Released` line, and a MIGRATION-NOTES heading and anchor passes. A
    missing provenance attestation fails. The full fetch, extract, and per-file diff path runs once
    on real tarballs: `@glw907/cairn-cms-dev`'s `0.99.0-rc.2` and `0.99.0-rc.3` tarballs (30 files,
    129,632 bytes unpacked each) are committed as fixtures and served through an injected fetch,
    and the test asserts the result the compare function gives them (contract 16). A prerelease on
    `gate` passes the tag check, one with `gate` behind on one package fails, and a stable checks
    `latest`.
  - withdraw: a candidate on `gate` only prints three `npm deprecate` lines and the `gate` removals.
    A promoted candidate, given `release-verify/promote-log.txt` (the shape `promote` prints), also
    prints `npm dist-tag add <pkg>@<previous> next` for each package and
    `create-cairn-site@<previous> latest`. A half-published candidate, with two of three on the
    registry, deprecates only those two. It runs no `npm` mutation.
- Estimate: 130. Model: sonnet medium. Pair: B5.

### B5. The stable-cut hook, the allow rules, and breaking-means-minor (pair with B4)

- Outcome:
  - The hook is `.claude/hooks/release-cut-guard.mjs`, a project-scope PreToolUse entry with matcher
    `Bash` in `.claude/settings.json`, run as `node "$CLAUDE_PROJECT_DIR/.claude/hooks/release-cut-guard.mjs"`.
    For a command matching `gh\s+release\s+create`, it applies the spec's four rules ("Claude
    infra", Hook), with the spec's two patterns verbatim (mechanics 4): it denies a non-literal tag;
    it denies a tag matching `^v\d+\.\d+\.\d+-` without `--prerelease` (any hyphen, so the
    post-merge probe tag `v9.9.9-hookprobe` is denied); and for a tag matching `^v\d+\.\d+\.\d+$`
    it denies a missing or non-40-hex `--target`, otherwise running
    `node scripts/checks/check-stable-source.mjs` from `git -C <input cwd> rev-parse --show-toplevel`
    (contract 18) and denying unless it exits 0 and `--target` equals its `sha:` line
    (`check-stable-source.mjs:158`). Any other literal tag gets no decision, and a passing stable
    gets no decision, never an explicit allow, so the permission system still decides (contract 2).
    Flag forms (contract 17; `gh release create --help` lists `-p, --prerelease`): `-p` and
    `--prerelease` count, `--prerelease=false` does not, and `--target=<sha>` is read like
    `--target <sha>`. The deny is `hookSpecificOutput.permissionDecision: "deny"` with
    `permissionDecisionReason`.
  - The hook fails closed (contract 2, integrity I7). The hooks reference says "Exit code 1
    without valid JSON output is a non-blocking error unless the hook is one whose failure blocks
    the action ... If your hook is meant to enforce a policy, use `exit 2`", and documents a
    command hook field `onFailure`, "Whether the action that triggered the hook goes ahead when
    the hook fails: `"continue"` or `"block"`" (Claude Code v2.1.295 or later; this host runs
    2.1.318). So the entry sets `"onFailure": "block"`, and the hook wraps its body so any
    exception on a command matching `gh\s+release\s+create` (malformed stdin JSON, a missing or
    crashing check script, an unparsable `sha:` line) emits a deny naming the error. The entry also
    sets `"if": "Bash(gh release create *)"` (the reference: "The hook command only runs if the
    tool call matches the pattern"), so node does not spawn on every Bash call; since the
    reference calls `if` "best-effort", the in-hook match stays. Cite
    <https://code.claude.com/docs/en/hooks> in the file header and the commit message.
  - The two allow rules go in the project's `permissions.allow`: `Bash(node scripts/release/*)` and
    `Bash(gh workflow run publish.yml --ref v* -f promote=*)`. Cite
    <https://code.claude.com/docs/en/permissions>. Nothing else in `.claude/settings.json` changes.
  - `check-version.mjs`, in the `bump === 'patch'` branch (`:204-211`), fails when the entry body
    holds an actionable `Consumers must:` line. Use `isActionable`
    (`check-consumers-must.mjs:30-36`). That module imports `unreleasedWindow` from this one
    (`check-consumers-must.mjs:10`); the cycle is safe because neither binding is read at module
    initialization. Confirm both CLIs run. `RULE` (`:13`) and the header (`:1-7`) are rewritten
    for the rule as it now stands: a minor for a new subsystem or a breaking change, a marker on
    every minor or major, and no README reference.
- Files: `.claude/settings.json` and `.claude/hooks/release-cut-guard.mjs` (handback, applied by
  the executor), `src/tests/unit/release-cut-guard.test.ts`, `scripts/checks/check-version.mjs`,
  `src/tests/unit/check-version.test.ts`.
- Class: runner.
- Acceptance (each fails on main):
  - Hook tests spawn `node .claude/hooks/release-cut-guard.mjs` with hook JSON on stdin. The stable
    cases set `cwd` to a temp dir holding a stub `scripts/checks/check-stable-source.mjs` that
    prints `sha: <40 hex>` and exits by an environment variable. The cases are the spec's list: an
    rc tag without `--prerelease` is denied, and with it (or `-p`) gets no decision; an rc tag
    with `--prerelease=false` is denied; a stable whose check exits 1 is denied; a stable with a
    different `--target` is denied; a stable with no `--target`, or `--target "$SHA"`, is denied;
    `--target=<the sha>` reads like `--target <the sha>`; a passing stable gets no decision; and
    `gh release create "$TAG" ...` is denied. The spec's probe command, `gh release create
    v9.9.9-hookprobe --repo glw907/hookprobe-absent --target main --title x --notes x`, is denied.
    Fail-closed cases, each a stable tag: the check script absent, the check script crashing,
    garbage stdout from the check, and malformed stdin JSON are each denied. A `cwd` one directory
    below the stub repo's root still finds the check. `gh  release  create` with doubled spaces is
    matched. A command without `gh release create` gets no decision. Main has no hook file.
  - The same test parses `.claude/settings.json` and asserts one PreToolUse entry whose command
    names the hook file, with `onFailure: "block"` and `if: "Bash(gh release create *)"`, and both
    allow rules. These cases run red in the pair worktree until the executor applies the
    handback.
  - check-version: a fixture with a stable on top, `0.99.1` over `0.99.0` with
    `Consumers must: run x.`, fails. Main returns `ok` at `:211`. An rc row, `0.99.1-rc.1` over
    `0.99.0` with a breaking line, fails. The same patch with `Consumers must: nothing.` passes.
    The live `npm run check:version` on the branch still exits 0.
- Estimate: 100. Model: sonnet medium. Pair: B4.

### B6. The two skills and the roadmap line (pair with B7)

- Outcome:
  - `cairn-releasing` (`.claude/skills/cairn-releasing/SKILL.md`, 313 lines) is rewritten around
    B2 and B4's commands. It keeps four judgment calls: warranted (`:20-32`), size (`:101-121`,
    now with breaking-means-minor), the notes prose, and failure triage. It carries the #349
    standing rule (a pass that changes `scripts/gate/` ends with one run against the current `gate`
    candidate, through `--cli` when it also changes the setup tool), a pointer to the ruling 10
    carve-out, and the rule that every `--target` is the literal sha the cut printed. It records
    the topical changelog grouping as a house departure from Keep a Changelog's six types, citing
    <https://keepachangelog.com/en/1.1.0/>, with Geoff's ruling of 2026-11-03. It adds a fixed
    retrospective paragraph for the stable's release commit: candidate count, friction filed,
    fixed before the stable, and the backlog numbers of the rest, replacing `:301-305`. "Gate the
    candidate" describes pass A's behavior from the spec: headless by default, `--headed`, an
    unknown page fails the leg with a screenshot and controls file, a lock refuses a second run,
    and `verdict.mjs` reads the table. A candidate's gate failure reruns `--all`, never a group,
    since `verdict.mjs` without `--file` needs one run id across all four rows (integrity I24).
    Promote is `gh workflow run publish.yml --ref v<V> -f promote=<V>`.
    The hand-edit steps go: `npm version` (`:127`), the per-package bumps (`:57-60`), and the
    one-shot `npm view` checks (`:230-235,262-267`). The rc.4 sequence's order (spec "The rc.4
    sequence" 1-8) is the procedure's spine, written generically. The frontmatter keeps
    `disable-model-invocation: true`.
  - `cairn-running-passes` (`.claude/skills/cairn-running-passes/SKILL.md`):
    - `runner` (`:31`) gains `scripts/release/**`.
    - Ruling 10's carve-out goes under "Risk classes": a `scripts/gate/` change that only follows a
      third-party page lands as a direct change after the fast lane and a dry run, provided
      `evaluateLeg`, the prompt answers, and teardown are untouched.
    - A harness-only fix after the final candidate writes no `CHANGELOG.md` line and records itself
      in its PR or commit body.
    - "References" (`:51`) links a new `references/launch-prompts.md`. That page lists the executor
      and conductor prompt fields `pass-core` "Launch prompt" names, restating no rule.
  - `ROADMAP.md:176` carries breaking-means-minor until 1.0.
  - Cite <https://code.claude.com/docs/en/skills> in the commit message (`claude-infra` step 5).
- Files: `.claude/skills/cairn-releasing/SKILL.md`, `.claude/skills/cairn-running-passes/SKILL.md`,
  and `.claude/skills/cairn-running-passes/references/launch-prompts.md` (handback, applied by the
  executor), and `ROADMAP.md` (written by the subagent).
- Class: runner.
- Acceptance (each grep fails on main's text):
  - `grep -o 'node scripts/release/[a-z]*' .claude/skills/cairn-releasing/SKILL.md | sort -u | wc -l`
    prints `7` (main: 0; `grep -c` would count lines, mechanics 20 and contract 15).
  - `grep -n 'npm version' .claude/skills/cairn-releasing/SKILL.md` is empty (main: `:127`).
  - `grep -n 'promote=' .claude/skills/cairn-releasing/SKILL.md` shows `--ref v` on every hit
    (main: `:224` has none).
  - The skill names `--headed`, the lock, `verdict.mjs`, the #349 rule, and the retrospective
    paragraph.
  - `grep -n 'scripts/release' .claude/skills/cairn-running-passes/SKILL.md` hits the `runner`
    line.
  - `references/launch-prompts.md` exists and holds no sentence that `pass-core` states, as read
    by the B9 reviewer.
  - `ROADMAP.md:176` area states the minor rule.
  - Every command and flag the skill names from B2 or B4's scripts exists there; a reviewer greps
    each. Pass A's flags (`--headed`, `--cli`, `--record-file`, the lock, `verdict.mjs`) are absent
    from pass B's tree, so the `rc.4` run sheet's step 0 greps them against merged `main`.
  - The skill states that a candidate's gate failure reruns `--all`.
- Test: none (prose). The fast lane's docs legs and `check` pass.
- Estimate: 105. Model: sonnet medium. Pair: B7.

### B7. Probe P-WT and land the command-form rule in the implementer (pair with B6)

- Outcome: P-WT is settled, and the rule lands where the source executes. The pair subagent is
  itself the worktree-isolated subagent the spec asks for. It runs each form PR #193's `## Tooling`
  lists, once:
  1. `cd <its worktree> && git status`
  2. `git status && git log -1 --oneline`
  3. `echo "$(git rev-parse HEAD)"`
  4. A heredoc whose body holds a git word: `cat <<'EOF'` with the line `git commit -m x`, then `EOF`
  5. `git -C /var/home/glw907/Projects/cairn-cms/.claude/worktrees/release-process-b status`
  It records each refusal text verbatim and reads `~/.local/state/claude-denials.jsonl` for a new
  entry from its session. The source is one of three: a named workstation hook (its name in the
  text), the auto-mode classifier (a `[Reason]` entry in the denials log), or Claude Code's
  built-in worktree isolation. It then writes the command-form rule (which forms to use, which to
  avoid, and the source) for `.claude/agents/cairn-implementer.md`, under "Workflow" or a short new
  section, as a handback file: the full agent file with the rule added.
- Files: `.claude/agents/cairn-implementer.md` (handback, applied by the executor). The probe
  record goes in the subagent's report, and B9 copies it into the PR's `## Tooling`.
- Class: runner.
- Acceptance: the report quotes each of the five forms with its outcome (refused, with the text,
  or ran). The agent file's rule names only forms the probe saw refused (main has no such rule).
  If no form is refused, the agent file is unchanged and the record says "not reproduced". That
  is a recorded result of the probe, not an escalation (ruling 1 of the fold record).
- Test: none (agent prose).
- Estimate: 35. Model: sonnet medium. Pair: B6.

### B8. The workstation PR (serial, conditional)

- Outcome: if B7 names a source that is workstation-wide (Claude Code's built-in isolation, the
  classifier, or a hook under `~/.dotfiles`), the same command-form rule lands in
  `claude/.claude/skills/pass-core/SKILL.md` "Pairs", which every repo's pairs read. Otherwise
  there is no workstation PR, and the PR body says so.
- How: `git -C /var/home/glw907/.dotfiles fetch origin`, then
  `git -C /var/home/glw907/.dotfiles worktree add /var/home/glw907/.dotfiles/.claude/worktrees/release-process-b-ws -b release-process-b-ws origin/main`,
  edited by absolute path. Then `bash scripts/gate.sh` in that worktree (run there with its path as
  the working directory of a single command, never through `EnterWorktree`). Commit the one file,
  push to glw907/workstation, and `gh pr create -R glw907/workstation`. The commit and PR body cite
  <https://code.claude.com/docs/en/skills> and B7's record.
- Files: `/var/home/glw907/.dotfiles/claude/.claude/skills/pass-core/SKILL.md`.
- Class: runner (workstation).
- Acceptance: `bash scripts/gate.sh` exits 0 in the dotfiles worktree. The PR diff is that one
  file. Pass B's PR body links the workstation PR. Both hosts (`pavilion`, `thinkpad-x1`) get the
  change through the stowed dotfiles after merge. No host needs a prerequisite.
- Estimate: 15. Model: sonnet medium, executor inline. Pair: none.

### B9. Close (serial tail)

See `## Close`. Estimate: 50.

## Path

| Step | Lane 1 | Lane 2 | Path minutes |
|---|---|---|---|
| Head | B1: 60 | | 60 |
| Pair round 1 | B2: 140 | B3: 145 | 145 |
| Pair round 2 | B4: 130 | B5: 100 | 130 |
| Pair round 3 | B6: 105 | B7: 35 | 105 |
| Serial tail | B8: 15, handback applies: 10, B9 close: 50, fix rounds: 95 | | 170 |
| **Path** | | | **610** |

Work sum (pairs counted once each): 730 plus the handback applies, close, and fix rounds. The
spec's Estimate gives pass B a 520 path (scripts 245 in lane 1; workflow, checks, and hook 240,
then skills and infra 135 in lane 2; close 50; fix rounds 95). The plan as drafted was 555: B1
moves the checks to the head, because `bump`'s round-trip test, `verify`, and `preflight` import
them, and B8 is a priced task. The review fold adds 55 (2026-11-03-release-plans-fold.md): the
widened ignore set, `ci-green`'s executable tests and actionlint, `verify`'s tag and real-tarball
cases, the hook's fail-closed cases, and the handback applies. Pass B runs beside pass A's 900, so
the round's path is pass A's 900 plus `rc.4`'s 205, or 1,105, against the 1,240 ceiling. Pass B's
own line is the same 1,035 as pass A's (1,240 less `rc.4`'s 205; mechanics 12).

## Stops and standing answers

| Stop or call | Standing answer (source) |
|---|---|
| Spend | Inside the round's 1,240 path minutes and pass B's 1,035, a failure with a traced cause gets a fix, and the run goes on. Each fix is listed in `## Decisions`. A cause that returns after its fix gets one structural fix. If it returns again, the run stops, since no pass B item is on the spec's escalation list (spec "Standing answers", Spend and "Items the run may escalate"; ruling 1 of the fold record). |
| Clock stop (a task past twice its estimate) | The executor writes the stop to its STATUS block and reports to the conductor. Inside the Spend answer, with the cause traced and pass B under 1,035, the conductor resets `estimate=` to twice the original and the task resumes. Otherwise the conductor asks Geoff (`pass-core` "Clock stop", applying the Spend answer). |
| A refused `.claude` or dotfiles write despite the grant | Pair subagents write no `.claude` file ("Handback"). If the executor's handback write in the pass worktree, or B8's dotfiles write, is refused, it skips that write, and the conductor's packet carries it as a `[you]` step with the exact command (spec "Standing answers"). |
| Fast lane red on an unrelated test, or "Cannot connect to the server in 60 seconds" | Apply the rerun rule in `cairn-writing-engine-code` `references/durable-gotchas.md`. |
| CI red on the draft PR | Fix forward on a traced cause. A `test` flake reruns once, and the retry is listed in the PR body. |
| A pair merge conflict | Files are disjoint by plan, so a conflict means a task wrote outside its list. Revert the stray edit, merge, and record it in `## Decisions`. |
| A newer npm 11.x patch at B3 time | Pin the newest 11.x (dependency rule: take every patch) and record it. Never 12.x (the WATCH). |
| An action tag resolves to an annotated tag | Dereference it to the commit sha and verify with `gh api repos/<a>/commits/<sha>`. |
| GitHub's REST reference names a scope other than `checks: read` | Use the scope the reference names, cite it, and record it. |
| The check-version and check-consumers-must import cycle breaks a CLI | Keep `check-version.mjs` free of the import, and test the line with the `LINE` shape reproduced against the test cases in `check-consumers-must.test.ts`. Record it. |
| P-WT reproduces nothing | Land no rule, record "not reproduced" as the probe's result, and B8 opens no PR. This is a result, not an escalation. |
| A whole-branch review `fix` verdict | One batched fix chain, with each finding quoted verbatim as its acceptance, then the gate. A second review runs only on a blocker (`running-passes` "Close"). |
| The post-merge hook probe returns gh's missing-repo error instead of the deny (conductor) | Confirm that `.claude/settings.json` on `main` holds the entry, and rerun the probe once from a session started after the pull. If it still fails, it is a traced defect, fixed on `main` by a small PR before `rc.4`'s step 5. The `rc.4` release carries `--prerelease` and is unaffected. |

**Escalation.** Pass B escalates nothing. The spec's standing answers name exactly three items the
run may escalate, all pass A's, and "Anything past them stops" (ruling 1 of the fold record). Every
pass B item is required before `rc.4`, `verify`'s stable tarball comparison included, since ruling
17's ignore set leans on it. B7's "not reproduced" is a recorded result of the probe (the P-WT
row).

## Close

1. **Full suite.** CI on the draft PR is the full-suite home: `ci-green <sha> --pr <n> --wait` as a
   background Bash task from the pass worktree, re-issued on 75. Exit 4 with the repo's
   `github-actions[bot]` as actor runs the approve command it prints. `publish.yml` never runs on a
   PR (`.github/ci-green.json` `neverOnPullRequest`), so B3's tests are its proof until `rc.4`.
2. **Whole-branch review.** `standards:diff-reviewer` at whole-branch scope against the spec's
   "Pass B" section and this plan. The `cairn-running-passes` path map selects no checklist
   reviewer for pass B's paths: no `.svelte` or SvelteKit hook code, no Worker, D1, or `wrangler.*`,
   no `auth-data` path, no markup, and no `tool/**`. The dispatch says so, and adds the spec's
   `publish.yml` bullets, the hook's four rules, and its fail-closed handling as acceptance. If a workstation PR exists, the
   same reviewer reads it in a second dispatch.
3. **Audit the infra (`claude-infra` step 6).** Run `/skill-doctor` on `cairn-releasing` and
   `cairn-running-passes` where the session can invoke it, and `claude-tooling-sync verify`. Where a
   background session cannot run one, record that in `## Tooling`.
4. **Docs dimension.** No published page under `docs/admin/`, `docs/editors/`, or
   `docs/why-cairn.md` describes the release process or `check:version` (grep at `bb3c8d3a2`), so
   no page changes and `check:docs-gate` is not triggered. Repoint any inbound reference to a
   removed instruction: grep `docs/`, `skills/`, `claude/`, `README.md`, `CONTRIBUTING.md`, and
   `CLAUDE.md` for `promote=` and `npm version`.
5. **CHANGELOG and MIGRATION-NOTES.** Pass B writes neither (spec "Pass B", Files). The PR body
   carries `## Changelog lines for the fold`: the consumer-visible lines (breaking means a minor
   from these candidates on; publishing from a GitHub release only, with provenance verified),
   each with `Consumers must: nothing.`. The conductor adds them when it folds `## Unreleased`
   at `rc.4` step 2.
6. **Backlog edits.** Pass B's PR does not edit `BACKLOG.md`, since pass A's items sit on
   adjacent lines (#349 and #348 at `BACKLOG.md:9-12`, then #347, #346, and #345 at `:13-18`, then
   #341 at `:19`), and two branches closing neighbors conflict at the second merge. The PR body's
   `## Backlog edits for the conductor` lists the edits the spec's verdicts assign to pass B, which
   the conductor lands in the fold commit:
   - close #345, #346, #347, and #205 to `## Done`, each with the commit that closed it;
   - #349: the standing-rule half has landed in `cairn-releasing`, and the item closes once pass
     A's rehearsal also lands.
   New friction found in the pass goes in the same section as full `/standards:log-issue` text.
7. **STATUS.** Remove the `## Pass B (release-process-b)` block, so the PR's net diff to
   `docs/STATUS.md` is empty. The conductor's hand-over writes STATUS after both passes merge.
8. **PR body.** It opens with `## Brief` per `~/.claude/docs/voice/approval-brief.md`: what
   approving changes (release-only publishing, the hook, breaking-means-minor, the scripts) and the
   one `[you]` step, removing the grant's `autoMode` line after merge. `### Worth knowing` names
   the departure from the spec's pre-flight step 4 timing: the `release-tags` ruleset is posted at
   `rc.4` step 6a, after the first publish succeeds, not at pre-flight (owed erratum E1). Then come what landed, the
   workstation PR link or "none", `## Decisions`, `## Planning misses`, and `## Changelog lines for
   the fold`. Then `## Backlog edits for the conductor` and `## Tooling`: each skill, agent, gate,
   or hook that failed, misled, or was missing, with its fix or backlog number, and B7's P-WT
   record verbatim. Last come the score rows (Gates on the critical path, Work and review with this
   plan's 610 beside the actual, CI waits on the path, Fix rounds and reds, Close, Total) from
   `cairn-run-gate --records <toplevel> release-process-b`, and every CI retry.
9. **Hand-over.** Mark the PR ready and report PR-ready to `conductor-cairn-cms`. Never run
   `approval-queue` and never merge. The `claude-approval-queue-reminder` hook fires on
   `gh pr create`, and the executor passes over it.

## After merge: the rc.4 run sheet (the conductor's)

Listed so the packet carries it (mechanics 7, contract 7). It follows spec "The rc.4 sequence",
with the changes the plans and the fold make, each marked. Inputs: pass A's PR body section
`## rc.4 inputs`. The spec's rules hold: gate runs go through `run_in_background`, and `<sha>` is
the literal sha step 3 prints.

0. After both PRs merge, pull the main checkout, then start a fresh conductor session there, so
   the project's new hook and allow rules load (B5). Run the spec's hook probe:
   `gh release create v9.9.9-hookprobe --repo glw907/hookprobe-absent --target main --title x
   --notes x`, with no `--prerelease`, must return the hook's deny text (the post-merge probe row
   above covers a failure). Then the `[you]` removal of the grant line. Then grep each pass A flag
   `cairn-releasing` names against `main`: `for f in --headed --cli --record-file; do grep -c -- "$f" scripts/gate/gate.mjs; done`
   prints no `0`, `test -f scripts/gate/verdict.mjs`, and `grep -c flock
   scripts/gate/run-gate.sh` is at least 1 (contract 15). Pre-flight items 2 and 3 are checked
   again here.
1. `node scripts/release/preflight.mjs 0.99.0-rc.4`.
2. Fold `## Unreleased` into the `## 0.99.0-rc.3` section of `CHANGELOG.md` and
   `MIGRATION-NOTES.md`, adding pass B's `## Changelog lines for the fold`, and make pass A's and
   pass B's `## Backlog edits` in the same commit. Commit it on its own.
3. `node scripts/release/bump.mjs 0.99.0-rc.4`, `node scripts/build/build-guidance-hashes.mjs`, and
   `npm run check:close`. Commit the cut, push `main` by fast-forward, and print `git rev-parse
   HEAD`, which is `<sha>`.
4. Wait for `test` on `<sha>` as the spec writes it. Standing answer "CI on the cut commit": a
   `test` failure reruns once; a real red is fixed on `main` before any tag exists.
5. `node scripts/release/notes.mjs 0.99.0-rc.4`, write the summary, then `gh release create
   v0.99.0-rc.4 --prerelease --target <sha> --title "..." --notes-file <file>`, which the hook
   checks.
6. Watch the `publish.yml` release run as the spec writes it, then `node scripts/release/wait.mjs
   0.99.0-rc.4 gate`, then `node scripts/release/verify.mjs 0.99.0-rc.4` (its tag defaults to
   `gate` for a prerelease, B4).
   - Changed by the fold (ruling 4; owed erratum E1). If `ci-green`, `build`, or a publish job
     fails before any package reaches the registry (`wait` shows none on `gate`), fix the cause on
     `main` by a small PR, delete the unpublished release and its tag with `gh release delete
     v0.99.0-rc.4 --cleanup-tag --yes` (`gh release delete --help`: "--cleanup-tag Delete the
     specified tag in addition to its release"), and recut from step 3 (`bump` is a no-op on a tree
     already at the version; the new `<sha>` is the fix's). If auto mode refuses the delete, it is
     a `[you]` step. If any package published, the spec's P-PROV path holds: `withdraw` prints the
     deprecation of the published half, and the fix goes forward to `rc.5`.
6a. Added by the fold (ruling 4). Once step 6 passes, before any gate run or promotion, post the
   `release-tags` ruleset with the spec's pre-flight step 4 `POST` (the `{"name":"release-tags",...}`
   body). Check: `gh api repos/glw907/cairn-cms/rulesets --jq '.[].name'` lists `release-tags`. On an
   auto-mode refusal, it is a `[you]` step, and promotion waits for it.
7. Changed by the plans (pass A seed D4): the registration read goes through
   `bash scripts/gate/run-gate.sh --smoke`, not a sourced-secret `curl`. Its info line must read
   `cairn-build` count 1, the uuid from pass A's `## rc.4 inputs`, a token-id match, and probe
   count 0. Then `bash scripts/gate/run-gate.sh --all --version 0.99.0-rc.4`, plus `--headed` if
   pass A's inputs say `rc.4` gates headed (S11), in the background with the Monitor until-loop on
   the run dir's `exit` file or a free lock. A failure reruns `--all`, never a group, since
   `verdict.mjs` without `--file` needs one run id across all four rows (integrity I24). After the
   deciding run, the End-to-end "gate" bullet is checked and recorded: its `driver.log` holds no
   `answered "Paste your Workers Builds deploy token"`; A2 and B1 each logged exactly one
   `trigger build token:` line, equal to the rehearsal's uuid; no `teardown left:` line printed
   (contract 8 floor); and a fresh `--smoke` info line again reads count 1, a token-id match, and
   probe count 0 (integrity I10).
8. Promote as the spec's step 8 writes it, after `node scripts/gate/verdict.mjs 0.99.0-rc.4` exits
   0. Standing answer "Promotion" (P-ENV): if the trusted publisher refuses the dist-tag change from
   the environment, `verdict.mjs` must exit 0 first, then Geoff runs the four `npm dist-tag add`
   commands as a `[you]` step, and the record reads "promoted by hand under P-ENV" with the run id.
   Then `node scripts/release/wait.mjs 0.99.0-rc.4 next`, and `node scripts/release/status.mjs
   0.99.0-rc.4` exits 0.
9. The End-to-end "promotion" bullet is checked and recorded, then Geoff's real install (spec step
   9).
