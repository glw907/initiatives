# Theme garden plan review: contract and criteria lens

Target: `2026-11-08-theme-garden-plan.md` at glw907/initiatives `2065b92`. Binding design:
`../specs/2026-11-08-theme-garden-design.md`. Code read at cairn-cms `b29977baf` (main; only STATUS
differs from `8332ea45c`), pre-P6 paths. Reviewer: fresh context, contract and criteria lens.

Verdict: **fix before approval.** Two blockers: the theme CI job can't stop a release, and the
`/styleguide` retirement can't pass its own acceptance against today's code. Eleven majors are
criteria that pass with the feature missing or that leave a design rule with no failing test. No
finding needs Geoff. Every resolution below is a method or idiom call.

Severity: blocker, major, minor. Tag: `correctness` (affects correctness or a stated requirement)
or `optional`.

## Blockers

### B1. The `theme` CI job never gates a release (blocker, correctness)

Location: plan:429-436 (T2.5). Design: 246 ("passes the theme check in cairn-cms CI before a release
can cut") and 355-356 ("the release can't cut, because the check fails in CI").

Defect: the release waits only on the check runs named `test` and `e2e`
(`.github/workflows/publish.yml:44-47`, `NAMES="test"` / `"test e2e"`). T2.5 adds a separately named
`theme` job that runs only on pull requests touching six prefixes, so:

- It never runs on the release commit.
- `publish.yml`'s `ci-green` never waits on it.
- A PR outside those prefixes can still break a catalog theme and merge. Examples: a dependency
  bump, `src/lib/content/**`, `src/lib/components/**`, showcase routes, the lay-in or emit scripts.
  The `render` rule depends on the whole engine.

The acceptance is also vacuous on two counts:

- `.github/ci-green.json` lists workflow files, not jobs (`ci-green.json:2-7`), and `test.yml` is
  already in `expected`. So "names the job" is a no-op.
- `ci-green` judges workflow-run conclusions (`~/.local/bin/ci-green:2`), and a skipped job
  concludes success. "`ci-green` lists it" passes whether the theme check ran or not.

Fold: run `npm run check:theme` for every catalog entry as a step inside the existing `test` job
(`test.yml:11`), unconditionally on push and pull request, the way `check:package` runs there. Then
the release's existing wait covers it, and neither `publish.yml` nor `ci-green.json` changes. Replace
T2.5's acceptance with these three checks:

1. The step is in the `test` job and has no `if:` or path filter (`workflow-yaml.test.ts` already
   runs actionlint).
2. A scratch commit that breaks `themes/waymark` turns the `test` check run red on the PR, then is
   reverted.
3. The `test` check run's log on the head shows the `check:theme` step's verdict line for `waymark`.

If the job must stay separate for runtime, add `theme` to `publish.yml`'s `NAMES` (a release-path
edit; reclassify T2.5) and drop the path filter.

### B2. The `/styleguide` retirement collides with live dependents, and T2.6's grep can't pass (blocker, correctness)

Location: plan:390-391 (T2.3), plan:440-444 (T2.6), plan:466 (standing answer), plan:484-485
(escalable list).

Defect: `/styleguide` is load-bearing today. These depend on it:

- `e2e/site-visual.spec.ts:61-67` holds 10 of the 51 port baselines (`styleguide-*`).
- `e2e/public-theme-equivalence.spec.ts:52,243,264-265` covers the focus pages and the heading-lever
  probe. This is T1.5's port proof.
- `e2e/styleguide.spec.ts` is the only axe WCAG A/AA run over every directive in both schemes.
- Also: `e2e/islands.spec.ts:13,22`, `e2e/starter-outline-pin.spec.ts:40`, and
  `scripts/lab/theme-fixture-e2e/theme-fixture.spec.ts:15,45,158`.
- Also: `.github/workflows/design.yml:3-6,56` (the B2 design gate runs only the styleguide spec),
  `.github/workflows/create-site.yml:117`, and `scripts/checks/gate-table.json:169,180,185,218,277`.
- The site menu links it (`src/theme/site.config.yaml:9`).

So the standing answer "another spec or a baseline loads `/styleguide`: keep the route" fires every
time. Once it fires, T2.6's `git grep -n styleguide -- skills docs examples/showcase/src` can't print
nothing. It also can't print nothing even if the route goes:

- `docs/internal/engine-rulings.md` has two historical hits, and a ruling must not be rewritten.
- `chassis/prose.css:149,681,683` and `chassis/composition.css:75` are on no task's file list.
- The menu entry in `site.config.yaml` is on no task's file list.

Retiring the route as written also deletes the axe gate over directives, with no replacement in the
check. A theme author would lose a check the house has today.

Fold (the builder's call, design 288-290): keep `/styleguide` through G2. Delete the T2.3 retirement
sentence, T2.3's `styleguide.spec.ts`, `styleguide/**`, and `.cairn-template.json` file entries, the
T2.6 grep, and the T2.6 chassis README line edits. Then file one `#initiative:theme-garden` backlog
item for a later retirement. Its scope: port the axe run to the viewer's conformance directives page,
move the 10 baselines, then retire. Updating the standing answer and the escalable list to match
saves roughly 30 to 45 minutes of T2.3 and T2.6 that would end in a revert anyway.

## Majors

### M1. `directive-styled` is either vacuous or fails Waymark (major, correctness)

Location: plan:416 (T2.4 rule), plan:117 (classes list). Design: 167-168, 304.

Defect: the rule passes a class when a rule in "the theme's compiled CSS" matches it. Today
Waymark's `theme.css` styles none of the nine blocks. The chassis's `prose.css` styles callout,
alert, cta, micro-cta, faq, pull-quote, and video (`grep -c` gives 17, 17, 12, 8, 16, 3, 10).
`banner` is styled only in `site.css`, and `icon`'s markup comes from `makeIcon`
(`markdown-blocks.ts:149`) with no class rule found. The chassis comes in through `theme.css`'s
import chain (`chassis/tokens.css:53` imports `prose.css`). That leaves two readings:

- **The compiled CSS includes the chassis.** Every chassis-importing theme passes, and T2.4's
  "unstyled directive class" break can only be built by inventing a class no sheet styles. The
  break test proves the code path, but the rule can never fail a real theme.
- **The compiled CSS excludes the chassis.** Waymark fails `check:theme -- themes/waymark`, which is
  T2.4's own acceptance.

Fold: settle this in "Calls settled here". A class is styled when a rule whose selector names it
appears in the compiled output of the theme's sheets, the chassis sheets they import, or `site.css`.
The chassis default counts, which matches the design's "default renderer" (164-166). The report
lists each class with the sheet that styled it, so "styled by chassis default" is visible. T2.2's
conformance directives page then proves Waymark's markup carries every class. The break test strips
one class's rules from a copied fixture's compiled CSS. Confirm `icon` has a styled class, or record
that its glyph markup is exempt with the reason.

### M2. The required token list omits the two roles the design adds (major, correctness)

Location: plan:287-289 (T1.5, contract data). Design: 183-186 ("Two more roles join the list:
`--cairn-eyebrow-case` and a scroll-cue role").

Defect: T1.5 reads the required names from the root keys of `e2e/fixtures/public-theme-computed.json`.
That file has 81 keys per state, captured before this pass, and they include neither new role nor
`--cairn-heading-case`. T1.5 also forbids updating that expectation, so the two roles can never reach
the list. The keys also include names a theme doesn't own (`color-scheme`, `--flow-space`, the
chassis-defaulted `--depth` and `--noise`). `tokens-required` would then demand these from every
theme, or fail on a property that isn't a token.

Fold: the contract list is the fixture's root keys, minus the names the chassis alone sets (listed in
the contract file with the reason), plus `--cairn-eyebrow-case` and `--cairn-scroll-cue`. Add a
T1.5 unit test that fails unless both roles are in `schema/cairn-theme-contract-1.json`. Make one of
T2.4's `tokens-required` breaks drop `--cairn-scroll-cue`.

### M3. "No console error" and `render` can pass on pages that never loaded (major, correctness)

Location: plan:397-398 (T2.3 last criterion), plan:414-415 (T2.4 `render`), plan:422-427 (T2.4
breaks).

Defect: the headless JSON carries `consoleErrors` but no HTTP status and no expected count. The
Waymark run passes in four cases where it should not:

- Zero pages run, because an empty or misparsed `--pages all` list "reports no console error".
- A route returns 404.
- The scratch build serves the wrong theme.
- A page renders the error page without logging.

T2.4's break list has no case for `render`. A `render` rule that never runs a page passes every
test.

Fold:

- Add `status` and `url` to the JSON. The Waymark criterion asserts that the entry count equals
  (starter routes + conformance routes, read from the composed content manifest) × 2 modes, every
  `status` is 200 except the 404 and error pages (which expect their own codes), and every
  `consoleErrors` is empty.
- Add two `render` breaks to T2.4: a fixture component that throws during SSR, and one that logs
  `console.error` on mount. Each must fail with exactly `render`.
- The `render` rule fails on a page count of zero.

### M4. The link order of `theme-options.css` and `overrides.css` is untested (major, correctness)

Location: plan:204-206 (T1.1 outcome), plan:217-225 (acceptance). Design: 260-264.

Defect: both files hold one header comment, so the visual baselines and every T1.1 test pass whether
the links exist, in what order, or not at all. That covers the (site) layout (`+layout.svelte:67-68`),
`+error.svelte:21-22`, and the preview's `stylesheets` (`cairn.config.ts:259`). The cascade order is
a design rule ("after the theme's sheets and before the owner's overrides", "links last") that setup
and a later switch rely on.

Fold: a Playwright assertion on `/`, the 404, and the preview frame. Write a sentinel into each file
in the test's copy, or read the `<link rel="stylesheet">` order: `theme.css` before `site.css`
before `theme-options.css` before `overrides.css`. A sentinel `--cairn-test` set in both files
resolves to the overrides value.

### M5. The color-mode default sheets have no test (major, correctness)

Location: plan:124 (call), plan:252-254 and 258-262 (T1.4). Design: 254, 260.

Defect: `modes/light.css` and `modes/dark.css` are built, listed in contract v1, and declared
not escalable. No criterion proves they do anything. Their semantics with a visitor's cookie are
also unstated: does an explicit toggle still override the pinned default?

Fold: settle the semantics in the call row. The mode sheet pins the no-cookie state, and a cookie
still wins. Add a T1.4 node or Playwright case on the options fixture:

- With `modes/dark.css` linked, no cookie, and the system set to light, the page reads the dark
  block's `--color-base-100`.
- With the cookie set to the light name, it reads the light value.
- The mirror case for `modes/light.css` under a dark system.

### M6. The catalog screenshots can't meet the 1440 by 960 limit as specified (major, correctness)

Location: plan:388-390 (headless saves "a full-page PNG"), plan:429-431 (T2.5). Design: 347 ("1440
by 960 (3:2), light and dark, plus one at 390 wide").

Defect: a full-page capture at 1440 is as tall as the page, not 960. `paths-required` checks
presence only. No criterion reads the dimensions.

Fold: headless mode gains `--viewport-only` (or `--clip <h>`), and T2.5 captures with it. The check
gains a `screenshots` rule (or extends `paths-required`) that reads each PNG's IHDR and fails unless
the two catalog shots are 1440 by 960 and the third is 390 wide. Add one break test: a 1440 by 1000
PNG.

### M7. "The check runs in the viewer on demand" has no task (major, correctness)

Location: plan:377-398 (T2.3). Design: 54 (goal: "get a machine-readable verdict from the check"),
311.

Defect: the viewer has no check entry point. The control page lists pages, themes, options, modes,
and widths only.

Fold: add a `--check` flag to `theme:view`, and a control-page action, that runs `check.mjs` on the
loaded theme directory and shows or prints its `--json` output. Acceptance: the smoke test fetches
the control page's check endpoint for the options fixture and fails unless the body validates
against `schema/cairn-theme-check.schema.json`. If that's judged out of reach, write the design
reading into "Calls settled here": `npm run check:theme -- <dir>` beside the viewer satisfies "in the
viewer".

### M8. The viewer injects option sheets instead of taking setup's path (major, correctness)

Location: plan:388-389 ("with the option sheet linked after the theme's sheets"). Design: 260-261,
277-278.

Defect: setup writes `src/site/theme-options.css` from the chosen `options/<key>/<value>.css`
sheets plus the mode sheet, and the chassis links it (T1.1). The viewer, and through it the check's
`render` rule, links the option sheet some other way. The proof then covers a cascade position no
site will have, and a bug in the `theme-options.css` link (M4) or in the concatenation stays
invisible.

Fold: for each combination, the viewer writes the scratch site's `src/site/theme-options.css` by
concatenating the chosen option sheets and the mode sheet, exactly as design step 5 says. Build once
per option combination, or serve the file dynamically in dev. Then the T2.3 accent-PNGs-differ test
proves the setup path.

### M9. The conformance set's hostile cases are never asserted present (major, correctness)

Location: plan:362-373 (T2.2). Design: 320-332.

Defect: T2.2's tests check hot-linked images, leakage into `templates/`, and manifest agreement. An
empty set passes all three. The hidden draft is the worst gap: nothing asserts that the draft stays
hidden. A theme or chassis change that lists drafts in the archive or the feeds would pass.

Fold: commit `scripts/theme/conformance/cases.json`, mapping each design case to its file or files.
`conformance.test.mjs` fails on a missing case and on a file no case names. Its archive case asserts
at least 3 pages with a last page shorter than the page size. Add to the `render` rule, or as a
T2.3 headless assertion, that the draft's route returns 404 and its title appears in neither the
archive pages nor the feeds. Extend the asset test to protocol-relative `//` URLs and raw-HTML `img`
and `source`.

### M10. Live edit and token rebuild can be absent and still pass (major, correctness)

Location: plan:385-386 (T2.3 outcome), plan:394-398 (acceptance), plan:483-485 (escalable). Design:
282.

Defect: the escalation list lets these be dropped through the conductor, which is fine. But no
criterion fails when they are silently missing. The interactive smoke test only lists routes. The
option, mode, and width controls are equally unproven.

Fold: extend the interactive smoke test:

1. Edit a token in the copied options fixture's `tokens/tokens.json`.
2. Poll the served page's CSS until `--color-accent` changes, with a bounded wait. Fail on timeout.
3. Assert the control page lists the fixture's option values and the five widths.

If a dispatch escalates these behaviors, the criterion is removed with the escalation, never left
passing on nothing.

### M11. Moving `theme-names.test.ts` drops the block-name check (major, correctness)

Location: plan:272-276 (T1.3). Today: `src/theme/theme-names.test.ts:30-31` fails when `theme.css`'s
daisyUI `name:` values drift from `theme-names.ts`.

Defect: after G1, the daisyUI blocks live in generated `tokens/tokens.css`, while `theme-names.ts`
and the cookie regex come from the manifest's `colorModes`. The new generator test checks only that
the generator writes the names it is fed. Nothing checks that the built blocks carry the manifest's
names. A mismatch silently breaks the toggle and the no-flash script.

Fold: either the tokens build takes the block `name:` values from the manifest's `colorModes` (one
source, and the call row says so), or the check gains a `color-mode-names` rule with a break test
that renames the dark block in the fixture. A one-line T1.5 assertion that `themes/waymark`'s built
blocks are named `cairn` and `cairn-dark` covers the port.

## Minors

### m1. T1.0's count can't reach 7 (minor, correctness)

Location: plan:198-199. `grep -c '#initiative:theme-garden' BACKLOG.md` prints 1 today (#361,
`BACKLOG.md:11`). The verdict table retags #376, #377, #378, #380, and #387, for a total of 6. #379
goes to Done and #388 keeps `#initiative:cairn-setup`.

Fold: "is exactly 6, and `grep -E '^- \[ \] \*\*#(361|376|377|378|380|387)\*\*'` lines all carry the
tag".

### m2. "No baseline regenerated" has no command (minor, correctness)

Location: plan:301-303. Fold: add `git diff --exit-code origin/main...HEAD --
'examples/showcase/e2e/*-snapshots/' examples/showcase/e2e/fixtures/public-theme-computed.json`.
Without it the criterion is a reading of CI's green, and an executor who regenerated on CI (the
`update_snapshots` dispatch input, `e2e.yml:11-14`) also gets green. Also correct "51 baselines at
five widths": the set holds a sixth width (`site-article-light-1920`) and 10 styleguide shots.

### m3. The port proof isn't "in the viewer" (minor, correctness)

Location: plan:301-303 against design 370-371 ("glance-indistinguishable in the viewer at all five
widths"). The viewer arrives in G2, so G1 substitutes pixel baselines on five pages. That's stronger
on those pages but doesn't cover the conformance pages. Fold: record the substitution as a row in
"Calls settled here". Add to T2.3 one headless Waymark run over the conformance directives page,
read by `standards:visual-verifier` against the same page rendered on `main` under `makeShowcaseCopy`.
It isn't an owner fork, since the method is Claude's.

### m4. T2.4's break list misses several stated rules (minor, correctness)

Location: plan:422-427. Add one break each:

- A manifest option with no resolver modifier: the design's "or the reverse", 299-300. Today only
  the resolver-to-manifest direction is tested.
- A required token missing under one option value only (design 302).
- An invalid `tokens.json` (`tokens-schema`).
- An audit scope that measures nothing (`audit` on `measured nothing`).
- A component with `<img src="https://...">` (the `external-host` component branch).
- A pairing over 400 KB (design 348).

### m5. T1.3's scroll-cue assertion names no page with a `pre` (minor, correctness)

Location: plan:276-278. The home page has no code block, so the assertion would find no element or
pass on nothing. Fold: name `/posts/the-reading-surface` and assert that the `pre` exists before
reading `background-image`.

### m6. "Never fetches" is untested (minor, optional)

Location: design 192. Fold: a T2.4 test runs the check with `NODE_OPTIONS=--network-family-autoselection-attempt-timeout`
or a stubbed `fetch` that throws, or asserts that `check*.mjs` loads schemas only by path through
`ajv.addSchema`.

### m7. The package check doesn't prove the new schema files ship (minor, optional)

Location: plan:121,135. `scripts/checks/check-package-files.mjs:73-79` requires only top-level
`*.schema.json`. `schema/cairn-theme-contract-1.json` and `schema/dtcg/2025.10/resolver.json` pass
unverified, even though the check and later outside themes read them from the package. Fold: name
`.schema.json` for the contract file, or extend `requiredDocsPaths` to `schema/**/*.json`.

### m8. The schema-URL follow-up is prose only (minor, optional)

Location: plan:136, 501-502. Per cairn-cms CLAUDE.md "Conditional follow-ups", a milestone trigger
belongs in `ROADMAP.md` or as a `WATCH:` line beside the `$schema` constant. Fold: T1.4 writes the
`WATCH:`.

### m9. The P6 re-check misses one comment (minor, optional)

Location: `src/lib/content/compose.ts:17-19`. The comment names
`packages/create-cairn-site/src/site-config-path.json`. Add it to pre-flight item 1's drift read if
P6 doesn't repoint it.

## Over-ceremony

### o1. T1.1's red-first scaffold test already exists (minor, optional; about 15 minutes)

Location: plan:218-219. `TestAMissingAnchorFailsNamingTheFileAndLeavesNothing`
(`tool/internal/setup/scaffold/scaffold_test.go:373-383`) already fails with "the template has no
%s" for `targets.SiteConfig` and `targets.CairnConfig` when `templates/waymark` lacks them. Fold:
change `targets.go:22-23` first and cite that test as the committed red. Drop the new test.

### o2. The T1.7 review fan-out exceeds the change (minor, optional; tokens for two agents)

Location: plan:331-336. `standards:go-conventions` is a skill, not a reviewer, and the Go change is
two string literals and a test constant. Fold: load it while editing T1.1. Drop it as a close step.

### o3. The pre-flight probe checks more than it needs to (minor, optional; small)

Location: plan:45-52. `curl` of a public schema and `npm view` aren't the auto-mode risk recorded at
plan:73-76; the `.claude/**` edit is. Fold: keep the held-file edit and its revert, and drop the
other two commands, or keep them only if there's a recorded refusal for them.

## Calls settled here, checked against the design

No call needs Geoff (no OWNER FORK). Contradictions and silent extensions to record:

- **The `tokens/tokens.css` split** (plan:118). It inverts design 153-154 (hand-written rules may
  move to an imported sheet, while `theme.css` is "the built base sheet"). The two are equivalent in
  effect. Record that the generated part, not the hand-written part, is the imported sheet.
- **Contract v1 paths.** `modes/`, `tokens/tokens.css`, `fonts/fonts.css`, and `*.test.ts`
  (plan:124-126) extend the design's table (135-147). That's allowed, but T1.5's contract file must
  list them, and the theme-directory page must name them. They aren't on T1.6's list explicitly.
- **The `/styleguide` retirement** (plan:132). Within the builder's latitude, but B2 shows the
  timing is wrong.
- **The port proof by baselines** (m3) and **the option-sheet injection** (M8). Both are unrecorded
  departures from the design's wording.
