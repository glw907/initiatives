Initiative: theme-garden

# Theme garden G3: Survey's cairn theme

Design: `../specs/2026-11-09-theme-garden-3-survey-design.md` (approved by Geoff 2026-11-09, Approval
Queue item 20261109T194535-695594; binding). Reference: `../reference/g3/` (glw907/initiatives
`733e0bb`).
Repo: `glw907/cairn-cms`, main checkout `/var/home/glw907/Projects/cairn-cms`. Every `file:line` was
read at `68eb92ecf`; the conductor re-checks them against `main` before launch (pre-flight item 1).
Conductor: `conductor-cairn-cms`. Executor: `cairn-cms-theme-garden-3`.
Load at start: `pass-core`, `cairn-pass`, `cairn-running-passes`; `cairn-following-public-design`
and `standards:visual-fidelity` for `themes/survey/`; `survey` for Survey's values and backlog;
`cairn-writing-engine-code` for `scripts/theme/**`; `standards:svelte-conventions` and
`standards:ts-conventions` for comments; `cairn-judging-scope` before any new surface.

The two rules every dispatch carries are `pass-core` step 1's quoted samples ("Avoid
over-engineering..." and "Deliver what was asked..."). Nothing below adds a feature the design does
not name.

## Pre-flight

No item needs Geoff. Each is done and checked before the conductor launches the executor.

1. **[session] The re-check.** Setup-tooling pass 3's T3.5 dependency sweep has merged (theme-garden
   launches hold during it). The conductor fetches cairn-cms, reads every `file:line` below against
   `origin/main`, folds any drift into this file, and commits the fold to `glw907/initiatives`.
   Check: the fold commit (or a "no drift" line under this item) is on `origin/main` of
   `glw907/initiatives`.
2. **[session] survey#10 is closed.** Check: `gh pr view 10 -R glw907/survey --json state -q .state`
   prints `CLOSED`. Done 2026-11-09.
3. **[session] The reference is committed.** Check: `git -C /var/home/glw907/Projects/initiatives
   ls-files theme-garden/reference/g3 | wc -l` prints 16. Done at `733e0bb`.
4. **[session] Survey's head.** Check: `git ls-remote https://github.com/glw907/survey main` starts
   with `79efb98`. If Survey moved, the conductor records the new commit here and the executor
   derives from it.
5. **[session] The pre-launch checks** in `pass-core` "Execute".

Permissions checked: each task's writes and credentials were read against auto mode for a `claude
--bg` executor. The executor and its pairs write only tracked files in their own worktrees, run
`npm`, `node --test`, `npx vitest`, Playwright Chromium, `npm run theme:view`, `npm run check:theme`,
and `npm run lane:fast`, and run `npm pack` for three public `@fontsource` packages into a scratch
directory under `$CLAUDE_JOB_DIR/tmp` (T3.3). They read glw907/survey's `tokens.json` from the local
clone at `/var/home/glw907/Projects/survey` by `git -C ... show 79efb98:tokens.json`, never writing
it. The executor pushes `theme-garden-3` to `glw907/cairn-cms` and opens a PR. No task reads
`~/.local/secrets`, calls a provider account, publishes, tags, dispatches a workflow, or edits a
`.claude/**` file, `settings.json`, or a hook. Survey's backlog items go to the conductor in the PR
body, and the conductor commits them to glw907/survey `main` after merge, per the `survey` skill.

Reviewed: `2026-11-09-theme-garden-3-review.md` (`standards:plan-reviewer`, mechanics and
feasibility; `runner` class, so `standards:spec-plan-review` takes one lens). All three blockers and
all eight fixes are folded into this file, and the notes are taken except the
per-task CI line on non-runner tasks.

## Calls settled here

- **The #412 fix** (probed in `probes/412-selectors.mjs`). `optionCss` in `scripts/theme/build-tokens.mjs`
  (lines 343 to 348) writes the light selector as `:where(:root),:root:has(...),[data-theme="<light>"]`
  and the explicit dark selector as `:root:has(...),[data-theme="<dark>"]`. Against `tokens.css`'s
  unlayered `:root` and `:root[data-theme="<dark>"]` rules, `:where(:root)` (0,0,0) and
  `[data-theme]` (0,1,0) both lose. The fix writes `:root` and `:root[data-theme="<name>"]`, which
  tie the base rules on specificity and win on order, since the page shell links the option sheet
  after the theme sheet (`examples/showcase/src/routes/(site)/+layout.svelte:69-71`). The probe
  read the right value in all six states (system light or dark, by no cookie, a light cookie, or a
  dark cookie). The `:where(:root)` form read the base value with no cookie on a light system and
  under a dark cookie in both. The contract reader finds an option's light rule by that prefix
  (`scripts/theme/theme-contract.mjs:109`, `k.startsWith(':where(:root)')`), so it changes with the
  build: it matches `k.startsWith(':root,')`, which keeps it apart from the published `:root` rule.
  The mode pin `html:root:not([data-theme])` (0,2,1, `build-tokens.mjs:394`) still outranks every
  option rule, and Waymark has no `options/`, so its sheets and the showcase equivalence fixture
  don't change. A site override of an optioned token on plain `:root` used to beat
  `[data-theme="<name>"]` by order and now loses to `:root[data-theme="<name>"]` under a cookie, so
  such an override must be written on `:root,:root[data-theme]`.
- **Trace by tokens.** An option changes token values only, so Survey's map details read theme
  tokens that the `map-detail` modifier sets: `survey-rule-style` (`dashed` or `solid`),
  `survey-rule-color`, `survey-mark` (the triangle's `display`, `inline-block` or `none`), and
  `survey-year-color`. They are untyped tokens, as `cairn-eyebrow-case` is in Waymark's
  `tokens.json:33`, and they need the #412 fix, since they live in `base` and are written on
  `:root`. `resolve()` reads only an option context's `light` and `dark` groups
  (`build-tokens.mjs:180-184`), and a flat context builds an empty sheet with no error, so each
  `map-detail` context holds `light` and `dark` groups carrying the same values.
- **The reading scale** is the design's. Survey's `text-step-1` to `-5` names carry these reading
  values, and Survey's `text-step-6` to `-13` and `text-step-inline-code` are left out: `text-step--2` 0.74rem, `--1` 0.86rem, `0` 1.0625rem, `1`
  1.2rem, `2` 1.4rem, `3` 1.6rem, `4` 2rem, `5` `clamp(2rem, ...)` to 2.6rem; measure about 42rem.
- **Fonts** come from the `@fontsource` packages Survey's `theme/fonts.css` imports (Spectral 400,
  400 italic, 500, 600; Karla Variable with its italic; Monaspace Neon 400), with Spectral's
  `vietnamese` and `cyrillic-ext` files left out. Each manifest font names its package page as
  `source`, as Waymark's manifest does.
- **Not in the catalog.** `templates/catalog.json` is unchanged; CI checks the theme by directory.
- **The drift script** is `scripts/theme/drift.mjs <themeDir> <path>`. It reads the manifest's
  `derivedFrom` (`repository` `https://github.com/glw907/survey`, `commit`), fetches `<path>` at that
  commit and at `main` from `raw.githubusercontent.com`, and exits 1 naming each changed top-level
  key path when they differ. It exports a function that takes a `fetch`, so its test injects one.
- **Which pages the grader reads.** The viewer's routes against the mockups: `/` against
  `home.html` (mockup A) and the specimen's masthead and collar; the starter post
  `2026-11-01-every-element-on-this-site.md` (headings, a table, lists, a quote; its route from the
  viewer's page list) against `post.html`; `/directives` (conformance) against
  `directives.html`; `/archive/2` and a missing route against `phone-archive-404.html`. Trace is
  graded against `map-detail.html`, and revision purple against `inks.html`.

## Backlog verdicts (scoped sweep, cairn-cms `BACKLOG.md` at `feb993934`)

T3.1 lands these on the branch. #361, #376, #377, #378, and #380 move to `## Done`, each citing the
evidence in the design's table. #412 is retagged `#initiative:theme-garden` and moves to `## Done`. #410, #413, #415, #416, #417, #418, #419, and #388 keep.

## Estimate

Design: 800 path minutes, stop line 1,600. This plan's path is 910 (1.14 of the estimate). Expected
actual is about 290 minutes at the 0.32 factor.

## The pass

| Pass | Slug | Class | Path minutes | Merge |
| --- | --- | --- | --- | --- |
| G3 | `theme-garden-3` Survey's cairn theme | `runner` | 910 | the conductor, on Geoff's approve in the end packet |

The class comes from `.github/workflows/test.yml` and `.github/workflows/survey-drift.yml`. Every
task writes `.pass-task-clock` at its start, commits, and runs `npm run lane:fast -- --range
<base>..HEAD` at its end. A task that edits `.github/workflows/` or `.github/ci-green.json` waits for
CI green on its own commit, and its estimate carries the wait. No task bumps a version or publishes.

**Pair A: T3.1 and T3.3**

**T3.1 Option sheets win over unlayered tokens (#412)** (65 min, test first). Outcome: an option
value of a base token reads correctly in all six states, by the selectors in "Calls settled here",
and the contract reader still finds each option's light values. Files:
`scripts/theme/{build-tokens.mjs,theme-contract.mjs}`, their tests, the options fixture under
`scripts/theme/fixtures/options-theme/` (a base token named outside the Tailwind namespaces at
`build-tokens.mjs:62`, such as `opts-rule-style`, with no `pub.cairn` mark, which the `accent`
modifier changes in both its `light` and `dark` groups; and its rebuilt sheets), `BACKLOG.md` (the
"Backlog verdicts" edits), `CHANGELOG.md`. Acceptance: the extended "option and mode sheets read the
right values in every state" test (`build-tokens.test.mjs:406`), committed first and red, reads the
fixture token under each accent value in the six states and fails unless each reads the option's
value; the composed-sheet loop (`build-tokens.test.mjs:459-480`) covers the token through the mode
pin; a contract test fails unless an option's light-only token counts as declared; the existing
cases pass; `node scripts/theme/build-tokens.mjs themes/waymark --check` passes with no change.
`git grep -n 'where(:root)' -- scripts docs skills BACKLOG.md` finds no stale reference after the
commit.

**T3.3 Fonts** (40 min). Outcome: `themes/survey/fonts/` holds Survey's woff2 files and
`fonts/fonts.css`. Files: `themes/survey/fonts/**` only. The pair returns the manifest's `fonts`
entries (each `OFL-1.1`, with its package page as `source`) as text in its report, and T3.2 writes
them. Acceptance: the total is under 400 KB and the report states it; no file is `.ttf`; T3.2 runs
the `fonts` and `external-host` rules.

**T3.2 Tokens, resolver, and manifest** (120 min, after T3.1 and T3.3). Outcome: `themes/survey/` holds
`cairn-theme.json` (id `survey`, name `Survey`, `colorModes` `survey` and `survey-dark`, the two
options with the design's labels and defaults, `derivedFrom`), `tokens/tokens.json` derived from
Survey's `tokens.json` at `79efb98` with hex colors as DTCG color objects, `tokens/resolver.json`
with the mode and the `map-detail` and `ink` modifiers, and the built `tokens/tokens.css`,
`options/*/*.css`, and `modes/*.css`. Ink values: water blue `#1c5a8c` / `#f1f7fc` light and
`#7fb5e4` / `#0b2236` dark; revision purple `#6a3d8a` / `#f7f2fb` light and `#c3a2e0` / `#1e1029`
dark. Files: `themes/survey/{cairn-theme.json,tokens/**,options/**,modes/**}`. Acceptance: `check.mjs
themes/survey --rules manifest-schema,contract-version,tokens-schema,resolver-options,tokens-stale,tokens-required`
passes, and so does `--rules fonts,external-host` with T3.3's entries in the manifest; a scratch
comparison (not committed) of every derived color against Survey's hex prints no difference, and
its output goes in the PR; `text-step-1` to `-5` carry the plan's reading values, and
`text-step-6` to `-13` and `text-step-inline-code` are absent.

**Pair B: T3.4 and T3.7**

**T3.4 Components** (150 min, after T3.2 and T3.3). Outcome: Survey's `SiteHeader`, `SiteFooter`,
`EntryRow`, `ArticleView`, `icons.ts`, and `directives/renderers.ts` as the design's "The theme"
says, starting from Waymark's files as the worked example. `renderers.ts` keeps the chassis
defaults and replaces one only where `directives.html` needs different markup. The layout imports
`#theme/theme.css` and `#theme/site.css` (`examples/showcase/src/routes/(site)/+layout.svelte:21-22`),
so T3.4 also writes a stub `theme.css` (Waymark's import header: the chassis, `tokens/tokens.css`,
`fonts/fonts.css`) and an empty `site.css`; T3.5 owns their content. The viewer needs `npm run
package` and the showcase install in the worktree first (`cairn-running-passes` setup). Files:
`themes/survey/{components/**,directives/**,icons.ts,theme.css,site.css}`. Acceptance: `npm run theme:view --
--theme themes/survey --headless --pages / --widths 1440 --modes light` returns status 200 with no
console error; `standards:svelte-reviewer` reads the components and its findings are fixed or
answered in the PR.

**T3.7 The drift workflow** (60 min, `runner`, waits for CI on its commit). Outcome:
`scripts/theme/drift.mjs` as "Calls settled here" says, and `.github/workflows/survey-drift.yml`
running it weekly (`schedule`) and on `workflow_dispatch`, read-only `contents` permission, a
`timeout-minutes` on its job (`workflow-yaml.test.ts:95`), listed under `neverOnPullRequest` in
`.github/ci-green.json`. The test runs under `test:theme`'s glob (`package.json:87`). Files: those three, plus
`scripts/theme/drift.test.mjs`. Acceptance: the test passes `drift.mjs` a fake fetch and fails
unless equal bodies exit 0 and differing bodies exit 1 naming the changed key path;
`src/tests/unit/workflow-yaml.test.ts` passes. The workflow is not dispatched.

**T3.5 theme.css and site.css** (180 min, after T3.4). Outcome: the page frame, the route classes
(`.lead`, `.index__head`, `.index__year`, `.pagination`, the error page), the prose, and every
directive class in `examples/showcase/src/chassis/directives/classes.json` styled to the mockups,
with Trace and the ink set only through tokens. Files: `themes/survey/{theme.css,site.css}`.
Acceptance: `check.mjs themes/survey` passes every rule, including `render` (every page, both
modes, every option value), `directive-styled`, and `audit`.

**T3.6 The CI step** (45 min, `runner`, waits for CI on its commit). Outcome: the `test` job in
`.github/workflows/test.yml` runs `node scripts/theme/check.mjs themes/survey` right after its
`check:theme -- --catalog` step. The job's limit is 45 minutes (`test.yml:15`); the last green main
run took about 25, and Survey's `render` builds four option combinations in two modes. T3.6 times
the step locally and, when the measured job would come within 5 minutes of the limit, raises
`timeout-minutes` in the same commit and records both numbers. Files: `.github/workflows/test.yml`.
Acceptance: CI's `test` job is green on the commit, its log shows `check:theme: survey pass`, and
the task's report names the CI verdict on its head.

**T3.8 The grader loop** (240 min). Outcome: a fresh-context `standards:visual-verifier` grades
PASS on every page in "Which pages the grader reads". Renders, with round `<N>`:
`npm run theme:view -- --theme themes/survey --headless --pages <the five routes> --widths
320,390,768,1440,2560 --modes light,dark --out $CLAUDE_JOB_DIR/tmp/g3-review/r<N>/default` for the
default options, then for each other combination (`--option map-detail=trace`, `--option
ink=revision-purple`, and both together) the same command with `--widths 390,1440` and its own
`--out`. Each round gives the verifier the reference and the render as separate labeled images, by
page and width. On FAIL, the executor or a fix subagent works the list, and a new verifier grades
the fixed state. The loop ends on a fresh PASS. A finding graded COSMETIC and Low on a delta round is fixed once and
never starts another round. `standards:daisyui-a11y-reviewer` then reads the
theme. The executor reads the final renders itself. Files: any under `themes/survey/`. Acceptance:
the last verifier's PASS report and the a11y verdict are in the PR body, and the PR lists every
device graded IMPROVED or recorded under the design's first standing answer. Renders and reports
stay out of the repo: they go to `$CLAUDE_JOB_DIR/tmp/g3-review/` in the executor's job directory.

**T3.9 Docs and harvest** (40 min). Outcome: `CHANGELOG.md` under `## Unreleased` names the #412
fix and Survey's theme directory; `MIGRATION-NOTES.md` says the option sheet selectors changed and that a site override of an
optioned token must now be written on `:root,:root[data-theme]` to win under a cookie;
`skills/cairn-styling-public-pages/references/theme-directory.md` names `themes/survey/` beside
Waymark only if it lists theme directories. Survey gaps (the reading scale, the measure, the CTA keys,
the scroll cue, revision purple, and any found in T3.2 to T3.8) are listed in the PR body's
`## Survey backlog` section in the `survey` skill's item form. Chassis friction is filed in
`BACKLOG.md` through `standards:log-issue`, tagged `#initiative:theme-garden`. Acceptance: `npm run
check:docs-gate` passes on the head.

**Close** (70 min). The viewer's headless mode makes `themes/survey/screenshots/` (the home page at
1440 in light and dark and at 390 in light), named in the manifest, from the graded theme.
`standards:diff-reviewer` reads the whole branch against the design and this plan; its findings are
fixed or answered, and `npm run check:docs-gate` reruns after the last docs edit. The PR goes
ready. The executor puts Geoff's read set in
`$CLAUDE_JOB_DIR/tmp/g3-review/read/`: each reference page's render at 1440 and 390, light and dark,
with the default options, plus Trace and revision purple at 1440 light, each named for the mockup it
answers. It sends the conductor the PR number, the head, the CI verdict on that head, and that
directory's absolute path. The conductor commits the read set to glw907/initiatives under
`theme-garden/reference/g3/build/` and links it in its packet.

Path: 65 + 120 + 150 + 180 + 45 + 240 + 40 + 70 = 910.

## Stops and standing answers

Approved with the design; each is applied in place of stopping.

| Stop | Standing answer |
| --- | --- |
| Clock stop: a task past twice its estimate | With the cause traced and the rest in scope, reset `start=` once with `estimate=` the remaining work and record it in `## Decisions`. On a second stop on the same task, the conductor splits the rest into a follow-up task or replaces the unit the fixes keep missing, and records the call |
| Path ceiling | Go on while the cause is traced and actual minutes stay under 580 (twice the expected 290); record the overrun in the score. Past that, or on an untraced cause, the conductor asks with the trace and a recommendation |
| A mockup device cairn's markup can't reach from theme CSS | Build the nearest form, record it in `## Decisions`, and show it in Geoff's read |
| A token pair under WCAG AA | Tune it within its hue, record the old and new values, and list the gap under `## Survey backlog` |
| Fonts over 400 KB after the two subsets go | Drop the next non-Latin Spectral subset and record it |
| A grader finding that returns after one structural fix | Escalate that item in the PR and go on |
| T3.1's fix breaks a Waymark or showcase value | Fix forward from the traced cause; regenerating a baseline is never the answer. Not escalable |
| A red on the fast lane or CI | Fix forward or revert. A known trap (`durable-gotchas.md`) reruns once. A red traced to executor reasoning moves the next task to `high` |
| A found item outside the task | `standards:log-issue`, tagged `#initiative:theme-garden`, listed in the PR |

**Items the run may escalate** after a structural fix fails: a single directive's styling detail,
the 404 page's contour run, and the phone nav's wrap past three items. **Not escalable**: the #412
fix, the check passing on `themes/survey`, the two options, both modes, the grader's PASS on the
home and post pages, and the CI step.

## Planning misses at design

None recorded. The builder check's catalog finding was answered in the design before approval.
