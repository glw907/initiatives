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

1. **[you] Settings grant (spec "Your steps" 5), with a widened scope.** The grant script the
   planning session writes and dry-runs adds one `autoMode` line carrying the marker
   `release-gate-and-process`. Pass B needs it to cover, until pass B's PR merges:
   - writes and commits in `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/release-process-b`
     and in the pair worktrees that session dispatches under
     `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/agent-*`, limited to
     `.claude/settings.json` (only the one PreToolUse entry for `gh release create` and the two
     allow rules in task B5), `.claude/hooks/release-cut-guard.mjs`,
     `.claude/agents/cairn-implementer.md`, `.claude/skills/cairn-releasing/**`, and
     `.claude/skills/cairn-running-passes/**`;
   - edits, commits, and a PR in a `~/.dotfiles` worktree on branch `release-process-b-ws`, limited
     to `claude/.claude/skills/pass-core/SKILL.md`, for task B8 only.
   The pair worktrees and the dotfiles worktree go beyond the spec's wording, which names only
   "pass B's worktree". Pairs run in `agent-*` worktrees (`pass-core` "Pairs"), and line 417 of
   `~/.dotfiles/claude/.claude/settings.json` clears a dotfiles skill edit only on approval "in the
   current session", which the executor never has.
   Check: `grep -c 'release-gate-and-process' ~/.claude/settings.json` prints `1`.
2. **[session, else you] GitHub environment and rulesets (spec "Your steps" 4).** No pass B task
   needs them to run. B3 names the `npm-publish` environment, and the `rc.4` cut depends on them.
   Check: `gh api repos/glw907/cairn-cms/environments/npm-publish/deployment-branch-policies --jq '.branch_policies[]|[.name,.type]'`
   prints `["v*","tag"]`.
3. **[you] npm sitting (spec "Your steps" 1).** Pass B uses no npm credential. The sitting closes
   #337 and binds the environment that B3's publish jobs name. Check: the spec's step 1 done-line.
4. **Conductor pre-launch checks (`pass-core` "Execute").** The main checkout is on `main`,
   `git -C /var/home/glw907/Projects/cairn-cms rev-list --count HEAD..origin/main` prints `0`, and
   `git -C /var/home/glw907/Projects/cairn-cms check-ignore -q .claude/worktrees/x` succeeds.
   No session has `release-process-b` checked out (`pgrep -f release-process-b` is empty).

P-DEP is settled at plan time, so `withdraw` needs no probe. The npm trusted-publishers page
(<https://docs.npmjs.com/trusted-publishers>) says "OIDC authentication supports `npm publish`,
`npm stage publish`, and the dist-tag operations described above" and "Other npm commands such as
`install`, `view`, or `access` still require traditional authentication methods". `npm deprecate`
is not among the supported commands, so `withdraw` prints its commands and the workflow gains no
`withdraw` input.

Permissions checked: B1 to B4 write only tracked repo files inside the pass worktree or pair
worktrees and read the registry (`npm view`, registry fetch) and GitHub (`gh api` GET, `gh release
view`), which are reads auto mode allows. B5, B6, and B7 write `.claude/**`, which auto mode refused
as Self-Modification on 2026-11-02 and 2026-11-03 (`~/.local/state/claude-denials.jsonl`), so
pre-flight item 1 covers them. B7's probe runs harmless forms, and a refusal is its expected
result. B8 writes a dotfiles skill and pushes to glw907/workstation, covered by item 1 and the
push target above. No task publishes, cuts a release, dispatches a workflow, or touches a
credential. The post-merge hook probe is the conductor's step, covered by the user rule
`Bash(gh release create v* --target * --title *)` (`~/.dotfiles/claude/.claude/settings.json:40`),
and the hook decides before any permission check.

Reviewed: pending (three-lens plan review)

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

## Tasks

### B1. The two checks the scripts import (serial head)

- Outcome: `check-stable-source.mjs` exports `RULES`. Its CHANGELOG predicate (`:50`) also accepts
  `^Released \d{4}-\d{2}-\d{2}\.$`. A changed path in the ignore set (`scripts/gate/**`,
  `src/tests/**`, `packages/*/test/**`, `examples/showcase/e2e/**`) skips every check, status and
  mode included, before the checks at `:123-125` run (ruling 17). `close-prebuilt.mjs` checks
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
    `:123` or `:125`. A change to `src/lib/` or `docs/STATUS.md` still fails, as
    `check-stable-source.test.ts:79,123` already assert.
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
- Estimate: 50. Model: sonnet medium, executor inline (the head of the serial chain). Pair: none.

### B2. `preflight`, `bump`, `wait`, `notes` (pair with B3)

- Outcome: four scripts per the spec's "Release scripts" table. Each runs as
  `node scripts/release/<name>.mjs <version> [flags]`, exits 0 or 1, and ends with one `Next:` line.
  Each core is a pure function over a command runner, in the shape of `check-stable-source.mjs:31,95,146-150`.
  `PACKAGES` comes from `check-stable-source.mjs:19`. No shared helper module is added.
  - `preflight`: clean tree; `HEAD == origin/main`, printing the sha; the version absent from
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
    `## Unreleased` sits above a heading on the same numeric core. The date is injectable.
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
  - preflight: a dirty tree, `HEAD` behind `origin/main`, the version already in one package's
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
  - Real-tree check, in the pass worktree on a clean tree: `node scripts/release/bump.mjs 0.99.0-rc.4`
    leaves `git diff --name-only` listing exactly the eight files, and `npm run check:version` exits
    0. Then `git restore` those eight files. Paste the listing in the report.
  - wait: a fake fetch serving `gate` one step behind on one package polls until it matches. A
    fake that never matches times out naming each package and its tag value. Each request carries
    the no-cache option.
  - notes: a CHANGELOG fixture with `Consumers must: nothing.` and two actionable lines writes a file
    holding the section and exactly the two actionable lines.
- Estimate: 130. Model: sonnet medium. Pair: B3.

### B3. `publish.yml` hardened, and its pins (pair with B2)

- Outcome: the spec's "`publish.yml`" bullets, in full:
  - Top-level `permissions: contents: read`, with `id-token: write` only on the publish jobs and
    `promote`.
  - The publish jobs run only on `release: published`. The `inputs.promote == ''` path
    (`:31,100,154`) goes.
  - A `ci-green` job polls `GET /repos/{repo}/commits/{sha}/check-runs` until `test` completes
    (plus `e2e` for a stable), failing unless each concluded `success`, within 45 minutes. It gets
    `checks: read`, confirmed against GitHub's REST reference for that endpoint, with the URL cited
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
    sparse checkout of `scripts/gate/verdict.mjs` and `scripts/gate/record.mjs` and no install. It
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
- Files: `.github/workflows/publish.yml`, `src/tests/unit/workflow-yaml.test.ts`.
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
  - `verdict` checks out only the two `scripts/gate/` files, and its script contains no `${{`. The
    test reads the workflow only and never requires those files to exist, since pass A creates
    them.
  - `.github/ci-green.json` keeps `publish.yml` under `neverOnPullRequest`, and `:122-126` still
    passes.
- Estimate: 110. Model: sonnet medium. Pair: B2.

### B4. `status`, `verify`, `withdraw` (pair with B5)

- Outcome: three scripts per the spec's table, built like B2's.
  - `status <version>`: prints a JSON checklist and exits non-zero until every item holds. The
    items are the tag on origin (`git ls-remote --tags origin`), the release and its
    `isPrerelease` (`gh release view --json`), dist-tags by stage, `dist.attestations.provenance`
    on all three, and the CHANGELOG heading. A complete prerelease has `next` on all three and
    `create-cairn-site@latest` at the version, and `node scripts/gate/verdict.mjs <V>` exits 0. A
    complete stable has `latest` on all three and runs no verdict.
  - `verify <version>`: checks dist-tags and provenance on all three. For a stable it fetches each
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
  `src/tests/unit/fixtures/release-verify/`.
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
    missing provenance attestation fails.
  - withdraw: a candidate on `gate` only prints three `npm deprecate` lines and the `gate` removals.
    A promoted candidate, given `release-verify/promote-log.txt` (the shape `promote` prints), also
    prints `npm dist-tag add <pkg>@<previous> next` for each package and
    `create-cairn-site@<previous> latest`. A half-published candidate, with two of three on the
    registry, deprecates only those two. It runs no `npm` mutation.
- Estimate: 115. Model: sonnet medium. Pair: B5.

### B5. The stable-cut hook, the allow rules, and breaking-means-minor (pair with B4)

- Outcome:
  - The hook is `.claude/hooks/release-cut-guard.mjs`, a project-scope PreToolUse entry with matcher
    `Bash` in `.claude/settings.json`, run as `node "$CLAUDE_PROJECT_DIR/.claude/hooks/release-cut-guard.mjs"`.
    For a command holding `gh release create`, it applies the spec's four rules ("Claude infra",
    Hook): it denies a non-literal tag; it denies an `-rc` tag without `--prerelease`; and for a
    stable it denies a missing or non-40-hex `--target`, otherwise running
    `node scripts/checks/check-stable-source.mjs` in the input's `cwd` and denying unless it exits 0
    and `--target` equals its `sha:` line (`check-stable-source.mjs:158`). Any other literal tag
    gets no decision. The deny is `hookSpecificOutput.permissionDecision: "deny"` with
    `permissionDecisionReason`. Cite <https://code.claude.com/docs/en/hooks> in the file header and
    the commit message.
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
- Files: `.claude/settings.json`, `.claude/hooks/release-cut-guard.mjs`,
  `src/tests/unit/release-cut-guard.test.ts`, `scripts/checks/check-version.mjs`,
  `src/tests/unit/check-version.test.ts`.
- Class: runner.
- Acceptance (each fails on main):
  - Hook tests spawn `node .claude/hooks/release-cut-guard.mjs` with hook JSON on stdin. The stable
    cases set `cwd` to a temp dir holding a stub `scripts/checks/check-stable-source.mjs` that
    prints `sha: <40 hex>` and exits by an environment variable. The cases are the spec's list: an
    rc tag without `--prerelease` is denied, and with it gets no decision; a stable whose check
    exits 1 is denied; a stable with a different `--target` is denied; a stable with no `--target`,
    or `--target "$SHA"`, is denied; a passing stable gets an allow or no decision; and
    `gh release create "$TAG" ...` is denied. A command without `gh release create` gets no
    decision. Main has no hook file.
  - The same test parses `.claude/settings.json` and asserts one PreToolUse entry whose command
    names the hook file, and both allow rules.
  - check-version: a fixture with a stable on top, `0.99.1` over `0.99.0` with
    `Consumers must: run x.`, fails. Main returns `ok` at `:211`. An rc row, `0.99.1-rc.1` over
    `0.99.0` with a breaking line, fails. The same patch with `Consumers must: nothing.` passes.
    The live `npm run check:version` on the branch still exits 0.
- Estimate: 80. Model: sonnet medium. Pair: B4.

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
    and `verdict.mjs` reads the table. Promote is `gh workflow run publish.yml --ref v<V> -f promote=<V>`.
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
  `.claude/skills/cairn-running-passes/references/launch-prompts.md`, `ROADMAP.md`.
- Class: runner.
- Acceptance (each grep fails on main's text):
  - `grep -c 'node scripts/release/' .claude/skills/cairn-releasing/SKILL.md` counts all seven
    script names (main: 0).
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
  - Every command and flag the skill names exists in B2 or B4's scripts. A reviewer greps each.
- Test: none (prose). The fast lane's docs legs and `check` pass.
- Estimate: 100. Model: sonnet medium. Pair: B7.

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
  built-in worktree isolation. It then adds the command-form rule (which forms to use, which to
  avoid, and the source) to `.claude/agents/cairn-implementer.md` under "Workflow" or a short
  new section.
- Files: `.claude/agents/cairn-implementer.md`. The probe record goes in the subagent's report,
  and B9 copies it into the PR's `## Tooling`.
- Class: runner.
- Acceptance: the report quotes each of the five forms with its outcome (refused, with the text,
  or ran). The agent file's rule names only forms the probe saw refused (main has no such rule).
  If no form is refused, the agent file is unchanged and the record says "not reproduced". That
  is an allowed escalation.
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
| Head | B1: 50 | | 50 |
| Pair round 1 | B2: 130 | B3: 110 | 130 |
| Pair round 2 | B4: 115 | B5: 80 | 115 |
| Pair round 3 | B6: 100 | B7: 35 | 100 |
| Serial tail | B8: 15, B9 close: 50, fix rounds: 95 | | 160 |
| **Path** | | | **555** |

Work sum (pairs counted once each): 635 plus close and fix rounds. The spec's Estimate gives pass B
a 520 path (scripts 245 in lane 1; workflow, checks, and hook 240, then skills and infra 135 in
lane 2; close 50; fix rounds 95). This plan's 555 is 6.7 percent over it. Two causes: B1 moves the
checks to the head, because `bump`'s round-trip test, `verify`, and `preflight` import them, and
B8 is a priced task. Pass B runs beside pass A's 700, so the round's path stays at 900 against
the 1,240 ceiling.

## Stops and standing answers

| Stop or call | Standing answer (source) |
|---|---|
| Spend | Inside the round's 1,240 path minutes, a failure with a traced cause gets a fix, and the run goes on. Each fix is listed in `## Decisions`. A cause that returns after its fix gets one structural fix, then escalation in the PR (spec "Standing answers", Spend). |
| Clock stop (a task past twice its estimate) | The executor writes the stop to its STATUS block and reports to the conductor. Inside the Spend answer, with the cause traced and the round under 1,240, the conductor resets `estimate=` to twice the original and the task resumes. Otherwise the conductor asks Geoff (`pass-core` "Clock stop", applying the Spend answer). |
| A refused `.claude` or dotfiles write despite the grant | In a pair worktree, the executor redoes that file's edit in the pass worktree after merging the pair. If refused there too, it skips that write, and the conductor's packet carries it as a `[you]` step with the exact command (spec "Standing answers"). |
| Fast lane red on an unrelated test, or "Cannot connect to the server in 60 seconds" | Apply the rerun rule in `cairn-writing-engine-code` `references/durable-gotchas.md`. |
| CI red on the draft PR | Fix forward on a traced cause. A `test` flake reruns once, and the retry is listed in the PR body. |
| A pair merge conflict | Files are disjoint by plan, so a conflict means a task wrote outside its list. Revert the stray edit, merge, and record it in `## Decisions`. |
| A newer npm 11.x patch at B3 time | Pin the newest 11.x (dependency rule: take every patch) and record it. Never 12.x (the WATCH). |
| An action tag resolves to an annotated tag | Dereference it to the commit sha and verify with `gh api repos/<a>/commits/<sha>`. |
| GitHub's REST reference names a scope other than `checks: read` | Use the scope the reference names, cite it, and record it. |
| The check-version and check-consumers-must import cycle breaks a CLI | Keep `check-version.mjs` free of the import, and test the line with the `LINE` shape reproduced against the test cases in `check-consumers-must.test.ts`. Record it. |
| P-WT reproduces nothing | Land no rule, record "not reproduced", and B8 opens no PR. |
| A whole-branch review `fix` verdict | One batched fix chain, with each finding quoted verbatim as its acceptance, then the gate. A second review runs only on a blocker (`running-passes` "Close"). |
| The post-merge hook probe returns gh's missing-repo error instead of the deny (conductor) | Confirm that `.claude/settings.json` on `main` holds the entry, and rerun the probe once from a session started after the pull. If it still fails, it is a traced defect, fixed on `main` by a small PR before `rc.4`'s step 5. The `rc.4` release carries `--prerelease` and is unaffected. |

**Items the run may escalate without breaking the outcome** (`rc.4` promoted through the hardened
`promote`): B7's rule and B8's PR; `verify`'s stable tarball comparison (`rc.4` uses only dist-tags
and provenance); `status`'s stable branch; `withdraw`'s promote-log parsing (it may print the
moves with the previous values left for the operator); and `references/launch-prompts.md`. Every
other item is required before `rc.4`: B1, `preflight`, `bump`, `wait`, `notes`, B3, B5, and
`cairn-releasing`. An escalated item goes to `BACKLOG.md` through the conductor (see Close).

## Close

1. **Full suite.** CI on the draft PR is the full-suite home: `ci-green <sha> --pr <n> --wait` as a
   background Bash task from the pass worktree, re-issued on 75. Exit 4 with the repo's
   `github-actions[bot]` as actor runs the approve command it prints. `publish.yml` never runs on a
   PR (`.github/ci-green.json` `neverOnPullRequest`), so B3's tests are its proof until `rc.4`.
2. **Whole-branch review.** `standards:diff-reviewer` at whole-branch scope against the spec's
   "Pass B" section and this plan. The `cairn-running-passes` path map selects no checklist
   reviewer for pass B's paths: no `.svelte` or SvelteKit hook code, no Worker, D1, or `wrangler.*`,
   no `auth-data` path, no markup, and no `tool/**`. The dispatch says so, and adds the spec's
   `publish.yml` bullets and the hook's four rules as acceptance. If a workstation PR exists, the
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
   one `[you]` step, removing the grant's `autoMode` line after merge. Then come what landed, the
   workstation PR link or "none", `## Decisions`, `## Planning misses`, and `## Changelog lines for
   the fold`. Then `## Backlog edits for the conductor` and `## Tooling`: each skill, agent, gate,
   or hook that failed, misled, or was missing, with its fix or backlog number, and B7's P-WT
   record verbatim. Last come the score rows (Gates on the critical path, Work and review with this
   plan's 555 beside the actual, CI waits on the path, Fix rounds and reds, Close, Total) from
   `cairn-run-gate --records <toplevel> release-process-b`, and every CI retry.
9. **Hand-over.** Mark the PR ready and report PR-ready to `conductor-cairn-cms`. Never run
   `approval-queue` and never merge. The `claude-approval-queue-reminder` hook fires on
   `gh pr create`, and the executor passes over it.

**After merge (the conductor's, listed so the packet carries it).** Pull the main checkout, then run
the spec's hook probe: `gh release create v9.9.9-hookprobe --repo glw907/hookprobe-absent --target
main --title x --notes x`, with no `--prerelease`, must return the hook's deny text. Then the
`[you]` removal of the grant line. Then the `rc.4` sequence, after pass A also merges.
