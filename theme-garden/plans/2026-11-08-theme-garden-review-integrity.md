# Theme garden plan review: data integrity and failure risk

Target: `2026-11-08-theme-garden-plan.md` at glw907/initiatives `2065b92`, against the approved design
`../specs/2026-11-08-theme-garden-design.md`. Code read at cairn-cms `b29977baf` (main, one STATUS
commit past `8332ea45c`), pre-P6 paths. Lens: crash, concurrency, partial write, upgrade, restore;
lost or silently corrupted data. Probes ran under `/var/home/glw907/.claude/jobs/64fd49ae/tmp`.

Verdict: one blocker, eight majors, nine minors or optionals. The blocker and four of the majors
are one-line folds into task text the plan already has.

## Findings, ranked by consequence

### 1. blocker, correctness: which `.gitignore` takes `src/theme/` is unstated, and the natural one ships to every site

- Location: plan:127, plan:291-292 (T1.5 "`examples/showcase/src/theme/` is gitignored"), plan:299
  (Files: `.gitignore`).
- Defect: the emit copies the showcase's own `.gitignore` into the template.
  `templates/waymark/.gitignore` is `examples/showcase/.gitignore` byte for byte, plus the overlay's
  `!.dev.vars.example` (`emit-template-dir.mjs:38`, the `append` rule). An executor who adds
  `src/theme/` to `examples/showcase/.gitignore` (the obvious home) ships that ignore line to
  `templates/waymark/` and to every scaffold. The Go scaffold then commits the site to git
  (`scaffold` package doc, `targets.go:1-4`), and that commit leaves out `src/theme/`. The site
  deploys from GitHub with no theme. setup-matrix doesn't catch this, because it builds from the
  scaffold directory on disk and never from a clone (`setup-matrix.yml:128-156`). An unanchored
  `src/theme/` in the root `.gitignore` fails a different way. It ignores
  `templates/waymark/src/theme/`, so new files there (the woff2 fonts) never reach `git add`. CI's
  `check:template` then goes red, which costs a fix loop.
- Fold: T1.5 names the root `.gitignore` and the exact line `/examples/showcase/src/theme/`, anchored.
  Add a test to `emit-template.test.mjs`: run `git init` on the emitted tree, then `git add -A`, and
  fail unless `git ls-files src/theme` lists `cairn-theme.json` and `theme.css`.

### 2. major, correctness: the lay-in silently deletes edits made to the generated copy

- Location: plan:128 ("replaces `<siteDir>/src/theme/` wholesale"), plan:127, plan:290-291, plan:385-386
  (the viewer re-lays on a pick).
- Defect: after G1, `examples/showcase/src/theme/` is a generated, ignored copy, but everything still
  points people and agents at it:
  - Vite and svelte-check errors name it.
  - Two years of skills, docs, and habit name it.
  - The viewer's scratch tree shows its own path in error overlays.

  An edit there survives until the next root `npm install`/`npm ci` (`prepare`) or the next showcase
  `dev`, `build`, `check`, or `test:unit`. Then it's gone without a word, and git can't recover it
  because the path is ignored. `git checkout` also overwrites ignored files without warning. The
  lay-in has no wrong-directory or overlap guard either. A `--theme <dir>` that points at
  `<site>/src/theme` (an easy mistake with the viewer, since that's where the files appear) deletes
  the source before it copies. Swapped positional arguments write a showcase tree into a theme
  directory.
- Fold, one task-text paragraph in T1.5. The lay-in writes a stamp outside the copied tree, for
  example `<siteDir>/.cairn/theme-lay-in.json`. `.cairn/` is already ignored and excluded from the
  template, so the template's bytes don't change. The stamp holds the source path and a sha256 per
  file. Before it removes anything, the lay-in compares the target to the stamp. On drift it refuses:
  it names each drifted file, says "edit `themes/<id>/` instead", and exits nonzero. `--force`
  discards the drift. It also refuses in three other cases:
  - the theme directory and `<siteDir>/src/theme` overlap in either direction;
  - `<siteDir>` lacks `package.json` and `svelte.config.js`;
  - the target is a symlink.

  Add one acceptance test per refusal, beside the plan's stale-file test (plan:306).

### 3. major, correctness: root checks read the generated copy, which goes stale after an edit to `themes/waymark/`

- Location: plan:296-298 (only `gate-table.json:266` and `check-public-skill.mjs:422` are repointed).
- Defect: these readers of `examples/showcase/src/theme` run from the root with no lay-in first:
  - `scripts/checks/check-invisible-craft.mjs:58,87`
  - `scripts/checks/check-public-skill.mjs:346,444,464`
  - `scripts/lab/reskin-fixture.mjs:31,132`
  - `scripts/checks/check-public-scope.mjs:46-47` and `scripts/checks/public-scope.config.json:3-4`
  - `scripts/lab/theme-fixture-copy.mjs:94`, which copies the showcase, theme included

  In CI the copy is fresh, because `npm ci` runs `prepare`. In a worktree it dates from setup. An
  executor edits `themes/waymark/theme.css` and runs the fast lane, which `gate-table.json:266`
  routes through these gates once `themes/` is added. The gates pass or fail on the old theme. That
  makes the pass's own evidence wrong, and G1 T1.5 and every G2 task meet this case.

  The port also moves the palette out of `theme.css` and into `tokens/tokens.css`. But
  `check-invisible-craft.mjs:87` names only `theme.css` as a CSS file and a palette site, so
  `gap-scale`, `motion-band`, and `token-colors` quietly stop seeing the values that moved.
- Fold: T1.5 adds these files to its Files list. Each reader reads `themes/waymark/` directly where
  it audits theme source (craft, scope, reskin). Where it needs a built site (the public-skill
  tailwind compile), it calls `layIn` first. `CSS_FILES` gains `tokens/tokens.css`. The acceptance
  gains one line: after a `themes/waymark/theme.css` edit with no lay-in, `check:invisible-craft`
  sees the edit.

### 4. major, correctness: `cairn doctor` loses existing sites' config path

- Location: plan:210-212 (T1.1 regenerates `tool/internal/doctor/site-config-path.json`).
- Defect: `tool/internal/doctor/siteconfig.go:39-46` looks up the canonical path first, then three
  legacy paths. `src/theme/site.config.yaml` isn't among the legacy paths, because today it is the
  canonical one. Once T1.1 changes the canonical path, doctor reports "site config not found"
  (`check_siteconfig.go:39`) for every site scaffolded so far, the 907 rebuild's builder-A site
  among them. The result degrades to unchecked rather than failing, but it is a false report.
- Fold: T1.1 adds `"src/theme/site.config.yaml"` to the legacy list, with a doctor test case.

### 5. major, correctness: version skew between the tool and the engine breaks `cairn new`

- Location: plan:213 (`targets.go:22-23` move), plan:127 ("no held setup command or workflow changes").
- Defect: the scaffold fetches the engine's `latest` dist-tag (`tool/internal/setup/scaffold/fetch.go:109-112`).
  It substitutes the fixed targets fail-loud (`substitute.go:120,139`). A `cairn` binary built after
  G1 that fetches a pre-G1 engine (today's `latest`) fails at "expected to find
  src/site/site.config.yaml". A pre-G1 binary that fetches a post-G1 engine fails the same way at
  `src/theme/...`. Nothing is corrupted, but `cairn new` breaks for whichever side releases first.
  The in-repo tests can't see it, because setup-matrix packs the engine from the same commit.
- Fold, Claude's call: either one works. (a) Each moved target resolves `src/site/<f>` and then
  `src/theme/<f>`, with a `// WATCH:` to drop the fallback once `latest` carries G1. (b) A line in
  T1.6's CHANGELOG and MIGRATION-NOTES says the tool and the engine release together, plus a
  release-gate check in `cairn-releasing` that the tool's targets exist in the engine tarball it
  will fetch. Recommend (a): it's two lines and needs no release discipline.

### 6. major, correctness: in-flight branches that edit `examples/showcase/src/theme/` lose their changes on merge

- Location: plan:58-62 (pre-flight item 6 checks only the catalog shape and the target table),
  plan:307 (`git ls-files` empty is checked once, at T1.5).
- Defect: G1 untracks the tree, so every other branch or worktree that merges `main` gets the files
  deleted. The same conductor runs cairn-setup lanes. If one of them has committed an edit under
  `examples/showcase/src/theme/` (a Waymark tweak for the starter, say), the merge hits a
  modify/delete conflict. "Keep ours" re-tracks the file in the ignored path, and the next lay-in
  overwrites it. The change never reaches `themes/waymark/`, and nothing fails. The reverse also
  happens: once a file is re-tracked there, later `git ls-files` checks are never rerun.
- Fold: pre-flight item 6 adds a third check. The conductor confirms that no open cairn-setup
  branch touches `examples/showcase/src/theme/` (`git log origin/main..<branch> --
  examples/showcase/src/theme` is empty for each). T1.5 adds a standing gate in `test:emit` or a
  check script that fails when `git ls-files examples/showcase/src/theme` prints anything. Recommend
  `git mv` from `examples/showcase/src/theme/` to `themes/waymark/` (optional) so that blame and
  `--follow` survive the move.

### 7. major, correctness: the footnote fix's acceptance doesn't rule out weakening clobber protection, and the obvious fix doesn't work

- Location: plan:354-360 (T2.1).
- Probe (`tmp/fn.mjs`, run with the repo's unified, remark-gfm, remark-rehype, rehype-sanitize
  defaults). With remark-rehype's default prefix, the href is `#user-content-fn-1` and the id is
  `user-content-user-content-fn-1`, prefixed twice, which is #387. With remark-rehype's
  `clobberPrefix: ''`, the href is `#fn-1` and the id is `user-content-fn-1`, which still doesn't
  match. The textbook one-option fix doesn't close #387. The fixes that do close it are these:
  - drop `id` from the sanitize schema's `clobber` list, or exempt ids from it (both weaken
    DOM-clobbering protection);
  - skip the prefix for an id that already starts with `user-content-` (keeps the namespace, but an
    author's raw `id="user-content-fn-1"` can take over a footnote anchor);
  - rewrite hrefs after the sanitize step.

  The plan's two tests (the footnote link matches, and a raw `<p id="x">` keeps its prefix) pass
  under the first of these, if the exemption is keyed to footnote ids.
- Fold: T2.1 names the mechanism. Keep `clobber` as it is. Set remark-rehype `clobberPrefix: ''`.
  Then add a post-sanitize step that prefixes `href="#…"` on `a[data-footnote-ref]` and
  `a[data-footnote-backref]` only, before `rehypeSinkGuard`. Extend the acceptance to fail in three
  cases:
  - a raw `<a name="x">` or `<p id="fn-1">` renders without the prefix;
  - the sanitize schema's `clobber` list differs from `defaultSchema.clobber`;
  - a raw `<a href="#fn-1">` outside a footnote is rewritten.

### 8. major, correctness: an unmigrated site's admin shows an empty menu without logging anything. OWNER FORK on the upgrade path

- Location: plan:211, plan:322-324 (disclosed as a `Consumers must:` line).
- What holds: writes fail closed. A nav save or settings save on a missing file throws
  `404 Site config not found` (`src/lib/sveltekit/nav-routes.ts:156-157`,
  `content-routes-settings.ts:305-306`). No commit lands at the wrong path, and nothing is
  overwritten. The path isn't configurable (`compose.ts:20,59`).
- Defect: the read degrades silently. The nav load swallows a missing file and returns an empty
  tree (`nav-routes.ts:91-96`), and tidy conventions fall back to their defaults
  (`content-routes-settings.ts:247-250`). Both log nothing. After a pin bump, an editor sees an
  empty menu with no error and reads it as lost data. The operator has no log event to find,
  against the repo rule that a diagnosable path emits one.
- Fold (correctness, both options): when `readFile` returns null on these loads, emit a `config.missing`
  record (`scope`, `path`), and add it to `log-events.md`.
- OWNER FORK: should engines from G1 on support sites still on the old layout?
  - (a) A hard break, disclosed, as the plan has it.
  - (b) For one minor version, the engine reads `src/theme/site.config.yaml` when `src/site/` is
    absent, with a `WATCH:`.

  Recommendation: (a). Sites are rebuilt rather than migrated (memory "sites rebuild, not
  migrate"), and the plan is pre-1.0 with the break disclosed. The log event makes (a) diagnosable.

### 9. major, correctness: the path-filtered theme job lets a release cut on a theme that fails the check

- Location: plan:429-436 (T2.5).
- Defect: the design requires "a catalog theme passes the theme check in cairn-cms CI before a
  release can cut" (design:246). The job runs only on PRs that touch six prefixes. A change to
  `src/lib/public/` (`cairn-public.css`), `src/lib/content/`, `scripts/build/`, or
  `examples/showcase/src/routes/(site)/` can break a theme's render without running the check, and
  `publish.yml` never runs it. The plan also says `.github/ci-green.json` "names the job", but that
  file lists workflows, not jobs (`.github/ci-green.json:2-16`). And GitHub Actions has no native
  path filter at job level.
- Fold: run the theme job unconditionally on `push` to `main` and in `publish.yml`'s pre-publish
  checks. On PRs, take the path filter as an optimization, or drop it, since it's one catalog theme.
  State how the filter is implemented and what `ci-green.json` lists: the workflow, if the job lives
  in `test.yml`.

### 10. minor, correctness: the lay-in isn't atomic, and the showcase now runs it from five hooks

- Location: plan:127, plan:290-291.
- Defect: `prepare`, `predev`, `prebuild`, `precheck`, and `pretest:unit` each `rm -rf` and then
  copy. Two of them running together in one checkout race on the copy. Examples: `npm run check`
  while `vitest` runs, or a `prebuild` while `vite dev` is serving. One process reads a half-copied
  tree, and the result is a spurious ENOENT or a dev-server crash. A kill partway through leaves a
  partial tree, which the next hook repairs.
- Fold: the lay-in copies into a sibling `src/.theme-<pid>/`, renames the old tree aside, renames
  the new one in, and then removes the old one.

### 11. minor, correctness: every install rewrites the tracked `app.html`

- Location: plan:129, plan:270-272 (T1.3), plan:290.
- Defect: the showcase's `src/app.html` is tracked, and the lay-in rewrites its cookie-regex line on
  every `npm ci`. If the generated text differs in any byte from the committed text (whitespace, or
  the order of the names), every fresh worktree comes up dirty. That trips the workstation's
  "warm uncommitted changes you did not author" stop on every dispatch.
- Fold: T1.3's acceptance adds an idempotence case: a lay-in on a clean checkout leaves `git status
  --porcelain` empty. CI also runs `git diff --exit-code` after install.

### 12. minor, correctness: the bake has to rewrite the showcase's new hooks, and T1.5 doesn't list the bake

- Location: plan:149, plan:299-300.
- Defect: `bake-template.mjs:21,148` prunes scripts by name, but `predev`, `prebuild`, and
  `precheck` stay. With the lay-in prepended (`node ../../scripts/theme/lay-in.mjs …`), they ship
  into `templates/waymark/package.json`. setup-matrix's build catches it (`setup-matrix.yml:156`),
  at the cost of one CI loop.
- Fold: add `scripts/build/bake-template.mjs` to T1.5's Files, with a rewrite rule that turns each
  hook back into its template form. The emit test fails when any emitted script names `lay-in`.

### 13. minor, correctness: the viewer's scratch directory is fixed, and its tests run in parallel

- Location: plan:378-379, plan:394-398, plan:414-415.
- Defect: the plan puts the scratch tree at a fixed `.cairn-theme-viewer/` but builds it "through
  `makeShowcaseCopy`". That helper makes `.cairn-theme-fixture-<pid>/` and sweeps any copy whose
  process is dead (`theme-fixture-copy.mjs:13,41-51,80-82`). `node --test` runs test files in
  parallel. `viewer.test.mjs` and the check tests' `render` rule both build scratch sites and serve
  on default ports, so a fixed directory or port races, deletes another run's tree mid-build, or
  fails flakily. A crash leaves a fixed directory behind for the next run to trip on.
- Fold: keep per-pid directories under one ignored prefix, using `makeShowcaseCopy` as written.
  Bind every server to port 0, or to an environment variable as `THEME_FIXTURE_PORT` does. Drop the
  separate `.cairn-theme-viewer/` name, or define it as that prefix.

### 14. minor, correctness: stale `tokens.css` isn't caught in CI between G1 and G2

- Location: plan:245-263 (T1.4 adds `--check`), plan:429-434 (CI only arrives with T2.5).
- Defect: while G1 is on `main` without G2, an edit to `tokens.json` without a rebuild lays in a
  stale `tokens.css`, and no gate catches it.
- Fold: T1.5 adds `node scripts/theme/build-tokens.mjs themes/waymark --check` to `check:template` or
  `test:emit`.

### 15. minor, correctness: retiring `/styleguide` breaks a CI workflow that the plan doesn't list

- Location: plan:391-393 (T2.3 Files), plan:466.
- Defect: `.github/workflows/design.yml:72` runs `test:e2e -- styleguide`. With the route and its
  spec gone, that step finds no tests, and design.yml is a required workflow
  (`ci-green.json:4`). The standing answer at plan:466 covers "a spec or a baseline", not a workflow.
- Fold: T2.3's Files gain `.github/workflows/design.yml`, which makes T2.3 a `runner` edit. Replace
  the step with the viewer's headless conformance-directive run, or remove it.

### 16. minor, optional: the grant script writes `settings.json` in place, with no dry run and no undo

- Location: plan:39-44; `add-theme-garden-grant.py:63-65`.
- Defect: `open(PATH, "w")` truncates the file before the dump. A crash or interrupt in between
  leaves the dotfiles settings empty, and `claude-tooling-sync apply` would then publish that. The
  workstation rule asks for a dry run before a destructive operation. The two lines have no removal
  path, though the text promises G2's close removes them. Nothing says the dotfiles edit gets
  committed, so `check-drift` will flag it. The 2-space round trip is exact: probed, `json.dumps`
  reproduces the file byte for byte.
- Fold: write to a temp file in the same directory, then `os.replace`. Print the lines to be added
  and exit unless `--apply` is passed. Add `--remove` for G2's close. Pre-flight item 3 commits the
  dotfiles change.

### 17. minor, optional: the emit's text passes never see the theme files

- Location: plan:293 (the theme is laid in after the bake).
- Defect: `stripMarkedBlocksInTree` runs in the bake, and the lay-in runs after it. A
  `cairn-template:exclude` marker in a `themes/` file would therefore ship. None exists today (the
  marker files are `cairn.config.ts` and `site.config.yaml`, which move to `src/site/`).
  `findTemplateViolations` decodes the woff2 files as utf8 (`emit-template-dir.mjs` `scannedFiles`
  walks all of `src/`). That's harmless, but it's a regex scan over binary data.
- Fold: the theme check's `paths-unlisted`, or a `test:emit` case, fails on that marker under
  `themes/`. Skip binary files in `scannedFiles`.

### 18. minor, optional (over-ceremony, the largest saving): every break-one check test runs a full render

- Location: plan:414-415, plan:422-427.
- Cost: twelve break-one cases, each copying the fixture and running `render`, which is a Vite build
  plus Chromium, add about 12 builds to each `node --test` run, in CI and in each pair's fast lane.
  At 30-60 s each, that's roughly 6-12 minutes of every lane run, plus the tokens spent reading the
  output.
- Fold: static-rule cases run with `--rules <id>` or `--skip render`. One test runs `render` on the
  unbroken fixture, and one breaks it with a component that throws.

### 19. minor, optional (over-ceremony): T1.5's restore proof reinstalls everything

- Location: plan:307-308.
- Fold: prove the restore with `rm -rf examples/showcase/src/theme && npm run prepare`, which runs
  the same hook. The full `npm ci` adds a reinstall of the root and dist for no extra coverage.

## Checked and found sound

- The Go extractor's limits hold with fonts: 16 MiB per file and 128 MiB total
  (`tool/internal/setup/scaffold/fetch.go:32-33`). The fonts come to about 284 KB. Links and `.git`
  segments are refused rather than skipped (`extract.go:44-50,66-67`), so a symlinked font fails
  loudly.
- npm's packlist drops `.gitignore`. The pack already renames the root one
  (`pack-engine-template.mjs:34`). The per-entry loop has to keep that rename for each `template/<id>/`,
  and `check-package-files.mjs:383-387` checks it for Waymark.
- `--ignore-scripts`: no CI install uses it (`grep` across `.github/`). Each `--ignore-scripts` is
  on an `npm pack` or `npm publish`, which run after an explicit pack step. The standing answer at
  plan:464 covers a future case.
- `rmSync` with `recursive` deletes the `node_modules` symlink in a scratch copy without following it.

