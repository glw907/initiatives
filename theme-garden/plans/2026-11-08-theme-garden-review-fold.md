# Theme garden plan: review fold record

Target: `2026-11-08-theme-garden-plan.md` at glw907/initiatives `050ffd9`. Reviews folded:
`2026-11-08-theme-garden-review-mechanics.md` (M), `2026-11-08-theme-garden-review-contract.md` (C),
`2026-11-08-theme-garden-review-integrity.md` (I). Code read at cairn-cms `b29977baf` (contains
`8332ea45c`), pre-P6 paths mapped to post-P6 per cairn-setup P6 T6.4. Fold agent: Opus, 2026-11-08,
per `standards:spec-plan-review` "The fold" and `standards:receiving-code-review`. Each finding was
checked against the code before its disposition.

**Totals: 68 findings. Folded 60 (I2 and I3 in part), refused 8, owner fork 0.** The verification
fold at the end adds 13 dispositions. The integrity review's owner fork (I8)
had one correct answer under Geoff's recorded rulings and is taken in the plan, not left open.

Revised with the plan: `2026-11-08-theme-garden-1-prompt.txt`, `-2-prompt.txt`,
`-plan-conductor-prompt.txt`, `add-theme-garden-grant.py`.

## Convergent findings, folded once at the root

| Root | Findings | Where the revision carries it |
| --- | --- | --- |
| The theme check's CI home and release gating | C-B1, I9, M10 | "Calls settled here" row "The check's CI home"; T2.5 |
| Keeping `/styleguide` | C-B2, M2, I15 | Calls row "`/styleguide`"; T2.3, T2.6, standing answers, escalable list |
| The `.gitignore` location | I1, M12 | Calls row "The showcase's `src/theme/`"; T1.5a |
| The bake ships the lay-in to sites | M1, I12 | Calls row "The template's scripts"; T1.5a |
| The T1.1 file list and greps | M7, M9 | T1.1 Files and acceptance; T1.6 grep |
| The doctor's legacy path | M13, I4 | T1.1 |
| The footnote fix's clobber protection | I7 | T2.1 (the contract lens raised no separate footnote finding) |

## The CI home, decided

Read: `publish.yml:44-47` (`ci-green` polls check runs named `test`, plus `e2e` for a stable, on the
released commit), `.github/ci-green.json:2-16` (workflow files by trigger class, not jobs; `test.yml`
already in `expected`), `.github/workflows/test.yml` (one `test` job, push to `main` and every PR,
`paths-ignore: ['tool/**']` only, showcase installed at the end, Chromium installed early,
`timeout-minutes: 35`). The simplest mechanism a release cannot bypass is two unconditional steps in
the `test` job after the showcase install: the release already waits on that check run, and nothing in
`publish.yml` or `ci-green.json` changes. A separate path-filtered workflow would never run on the
release commit and would need a `publish.yml` edit. Acceptance that fails when the check does not
run: a `workflow-yaml.test.ts` pin (the file already pins `test.yml` steps, lines 134-200) that the
steps exist with no `if:` after the showcase install and that `publish.yml` waits on `test`; the
check's `--catalog` mode failing on zero themes; and the head's log line `check:theme: waymark pass`.
The contract lens's "scratch commit that turns CI red, then revert" is not taken: it costs a CI round
and proves what the break tests plus the pin already prove.

Runtime, priced: the showcase build took 13 s on CI (e2e run, step "npm --prefix examples/showcase
run build", 2026-11-09). The catalog `render` is one build for Waymark (no options) plus the page
loads at one width in two modes. `test.yml` runs took 8 to 26 minutes over the last eight runs
(`gh run list -w test.yml`), so a standing answer raises the timeout to 45 if the head comes within
5 minutes of 35. Only the `render` rule's own three tests render (one page each); every other break
test runs `--rules` without `render` (I18).

## Mechanics review (M)

| # | Sev | Disposition | Note |
| --- | --- | --- | --- |
| M1 | blocker | folded | Verified `bake-template.mjs:21,148` prunes by name only and showcase `predev`/`prebuild`/`precheck` run `build:admin-css`. Calls row "The template's scripts"; T1.5a emit test fails on any `lay-in` in the emitted scripts |
| M2 | major | folded | Root C-B2 |
| M3 | major | folded | Fold probe `tmp/fold/dtcg/p.mjs` against the vendored schema: `$type: dimension` `clamp()`, `em` dimension, and `"#fff"` color fail; untyped string and oklch color object pass. Calls row "Token values"; T1.5b declaration-equality test |
| M4 | major | folded | Re-ran mechanics `tmp/probe/p2.mjs`: `ajv/dist/2020` rejects the draft-07 resolver; draft-07 class rejects a 2020-12 schema; fold probe: default `new Ajv()` throws `unknown format "uri-reference"`. House schemas are 2020-12 (8 of 8). Calls row "Token validation"; standing answer rewritten |
| M5 | major | folded | Verified `starter-content.mjs:94-98` reads `markdown-blocks.ts`. T1.2; pre-flight item 6 (c) |
| M6 | major | folded | Verified `reskin-fixture.mjs:31` reads `theme.css`. T1.5b |
| M7 | major | folded | Ran T1.1's grep at `b29977baf`: every listed hit confirmed, plus the `filepath.Join` at `siteconfig_test.go:19`. Pre-P6 `packages/create-cairn-site/src` and `create-site.yml` hits retire in P6 T6.4. T1.1 Files, +30 min |
| M8 | major | folded | Pre-flight item 6 (c) |
| M9 | major | folded | T1.1 grep gains `:!templates/waymark/.claude/` and `:!src/tests/unit/fixtures/`; T1.6 grep gains the fixtures, `BACKLOG.md`, `ROADMAP.md`; T1.6 regenerates the template |
| M10 | major | folded | Root C-B1; the mechanism differs from M10's (steps in `test`, not a new `theme.yml`), for the gating reason above |
| M11 | major | folded | The conductor prompt was committed at `050ffd9`; revised here for the new items |
| M12 | major | folded | Root I1 |
| M13 | minor | folded | Root I4 |
| M14 | minor | folded | Standing answer "The port's bar stays unmet" |
| M15 | minor | folded | Verified `gate-table.json:313-319` lists itself and `.github/workflows/`. Priced +15 min on T1.1 and T1.5a; T2.5 carries its wait; the passes intro states the rule |
| M16 | minor | folded | Pre-flight item 4 edits one file in each held directory; the `curl` writes into the scratch worktree, so `$CLAUDE_JOB_DIR` is not needed |
| M17 | minor | folded | Pre-flight item 1's check lists the review, fold, and verification files |
| M18 | minor | folded | T1.1 names `:50-53` as README text and `:169-171` as CLAUDE.md text; the token names are `states.<state>.root` keys (verified: 81 per state). The design's line 3 is the design's own text and is not edited here |
| M19 | optional | folded | Trivially free: the same `gate-table.json` edit in T1.5a adds `themes/` to the `showcase` bucket |
| M20 | optional | refused | The design fixes `https://cairn.pub/schemas/<name>/<contract>.json` (design 193-194) |
| M21 | optional | folded | Trivially free: a fact in "Later passes" (verified `root.go:235`) |
| M22 | optional | refused | Optional; folding T1.0 into T1.1 saves one clock file and renumbers nothing useful |

## Contract review (C)

| # | Sev | Disposition | Note |
| --- | --- | --- | --- |
| B1 | blocker | folded | See "The CI home, decided" |
| B2 | blocker | folded | Verified the 10 `styleguide-*` baselines (51 total), `design.yml:72`, and `site.config.yaml:9`. Calls row keeps the route; T2.3 loses the retirement and its files; T2.6 loses the grep and files the later-retirement item; the standing answer and the escalable entry go |
| M1 | major | folded | Verified chassis `prose.css` styles seven blocks, `site.css` the banner, `prose.css:554-593` `.cairn-icon`. Calls row "What 'styled' means"; T2.4's break removes the banner rules from the fixture's `site.css`, a break a real theme can make |
| M2 | major | folded | Calls row "Required token names"; T1.5b unit test; T2.4 break on `--cairn-scroll-cue` |
| M3 | major | folded | T2.3 JSON gains `url` and `status`; the Waymark run asserts the count and statuses; `render` fails on zero pages; two `render` breaks in T2.4 |
| M4 | major | folded | Folded as a static showcase unit test on the link order in both pages and the preview's `stylesheets`, not a Playwright read: production asset names are `[name].[hash][extname]` (`@sveltejs/kit/src/exports/vite/build/index.js:245`), but two header-only sheets give a computed-value sentinel nothing to read, and the source order is what the rule fixes |
| M5 | major | folded | Calls row "Color-mode default sheets" settles the semantics; T1.4 cases |
| M6 | major | folded | Headless `--viewport-only`; T2.5 reads each PNG's IHDR. No new check rule: the size is a design limit, not one of the check's listed failures (design 294-309) |
| M7 | major | folded | Control-page "Run the check" action; the smoke test validates its body against the check schema |
| M8 | major | folded | Calls row "Options in the viewer" |
| M9 | major | folded | Direct per-case assertions in `conformance.test.mjs` instead of a `cases.json` map (no second list to keep in step); draft-hidden assertion in T2.3's Waymark run; the asset test covers `//`, raw `img`, and `source` |
| M10 | major | folded | T2.3 smoke test: the token edit polls `--color-accent` with a bounded wait; options and widths listed; an escalated item takes its criterion |
| M11 | major | folded | The tokens build takes block names from `colorModes` (Calls row "The tokens build"); T1.4 rename test; T1.5b asserts `cairn` and `cairn-dark` |
| m1 | minor | folded | Verified `grep -c` prints 1 today; T1.0 expects exactly 6 |
| m2 | minor | folded | T1.5a and T1.5b carry the `git diff --exit-code` command; the count is corrected (verified 51 including `site-article-light-1920`) |
| m3 | minor | folded | Calls row "The port proof" records the substitution. The extra `visual-verifier` read on a conformance page is not added: with `/styleguide` kept, its 10 baselines pin every directive under Waymark |
| m4 | minor | folded | All six breaks added to T2.4, cheap under `--rules` |
| m5 | minor | folded | T1.3 names `/posts/the-reading-surface` (verified the only post with a fence) and asserts the `pre` exists |
| m6 | optional | refused | Optional; the check loads schemas by path from the package by construction |
| m7 | optional | refused | Optional; no outside consumer reads the contract file from the package in G1 or G2 |
| m8 | optional | folded | Trivially free: T1.4 writes the `// WATCH:` |
| m9 | optional | folded | Trivially free: pre-flight item 1 names `compose.ts:17-19` (verified it names the pre-P6 JSON path) |
| o1 | optional | folded | Verified `TestAMissingAnchorFailsNamingTheFileAndLeavesNothing` (`scaffold_test.go:373-383`) fails "the template has no %s" for `SiteConfig` and `CairnConfig`. T1.1 cites it as the red; the new scaffold test is dropped (-15 min) |
| o2 | optional | refused | The house close checklist loads `standards:go-conventions` for `tool/**` (`cairn-running-passes/SKILL.md:47`); T1.7 now names it as a skill, not a reviewer |
| o3 | optional | refused | The `curl` and `npm view` are T1.4's real network steps and cost seconds; the held-file part folds through M16 |
| C1 | note | folded | The `tokens/tokens.css` split is recorded in its Calls row. Owed erratum below |
| C2 | note | folded | Calls row "The contract's paths"; T1.6 names each path on the theme-directory page |

The lens's other two Calls notes (the port proof, the option-sheet injection) are m3 and M8.

## Integrity review (I)

| # | Sev | Disposition | Note |
| --- | --- | --- | --- |
| I1 | blocker | folded | Verified `templates/waymark/.gitignore` equals the showcase's plus `!.dev.vars.example`. Fold probe `tmp/fold/gi`: a root `/examples/showcase/src/theme/` ignores only the showcase copy and `git add -A` still takes `templates/waymark/src/theme/`. T1.5a emit test runs `git init` and `git add -A` |
| I2 | major | folded in part, refused in part | Folded as the simpler guard: the lay-in refuses a theme dir without `cairn-theme.json`, a site dir without `package.json` (not `svelte.config.js`, which the showcase lacks, `test.yml` comment at the first `npm run check`), and an overlap either way; the copy is documented as generated in the chassis README and the theme-directory page. The hash stamp and `--force` are refused: new machinery with no named team running it and no measured loss, and the copy is disposable by design. Refused half: the silent loss of an edit to the generated copy is accepted, not closed, because the copy is disposable and documented as generated |
| I3 | major | folded in part, refused in part | Verified the readers (`check-invisible-craft.mjs:58,87`, `check-public-skill.mjs:346,422,444,464`, `reskin-fixture.mjs:31,132`, `check-public-scope.mjs:46-47`). The import-chain readers keep reading the laid-in copy, since `theme.css`'s relative `../chassis/` import resolves only there; the fast lane lays in once first (T1.5a), and `CSS_FILES` gains `tokens/tokens.css` (T1.5b). Refused half: reading `themes/waymark/` directly, and the criterion that a standalone `check:invisible-craft` sees an edit with no lay-in; the import-chain readers cannot resolve `../chassis/` from `themes/waymark/`, and the fast lane, the showcase hooks, and CI's `prepare` all lay in first |
| I4 | major | folded | Verified `siteconfig.go:39-46`. T1.1 adds the legacy path and a doctor test |
| I5 | major | folded | Folded as pre-flight item 6 (e), not code. Verified `fetch.go:109-112` defaults to `latest`. The tool is unreleased and is tagged at the stable cut with the engine (ROADMAP.md, "the tool is tagged at the stable cut"), so the skew needs a tool release ahead of the engine's; the dist-tag mismatch class is builder A item 1, already setup's. The two-path fallback is refused: it weakens the fail-loud substitution for a case the release order prevents |
| I6 | major | folded | Pre-flight item 6 (d); T1.5a's `test:emit` test fails when the path is tracked; T1.5a uses `git mv` |
| I7 | major | folded | Fold probe `tmp/fold/fn/probe.mjs` with the repo's `unified`, `remark-gfm`, `remark-rehype`, `rehype-raw`, and `rehype-sanitize`: default gives `#user-content-fn-1` against `user-content-user-content-fn-1` (#387); `clobberPrefix: ''` alone gives `#fn-1` against `user-content-fn-1`; `clobberPrefix: ''` plus a post-sanitize prefix on `a[data-footnote-ref]` and `a[data-footnote-backref]` matches both directions, keeps raw `id`/`name` prefixed, and leaves a plain `#fn-1` link alone. `defaultSchema.clobber` is `ariaDescribedBy, ariaLabelledBy, id, name`. T2.1 names the mechanism and the four failing cases |
| I8 | major | folded | OWNER FORK taken as (a): sites are rebuilt, not migrated (Geoff's recorded ruling), cairn is pre-1.0, and the break is disclosed through `Consumers must:` lines. Recorded in Calls row "Sites on the old layout". `config.missing` folded after verifying the silent degrade at `nav-routes.ts:91-96` and `content-routes-settings.ts:247-250` and the repo rule (cairn-cms CLAUDE.md: "A pass that adds a diagnosable code path gives it an event in the vocabulary"); `config.invalid` already carries `scope` (`events.ts:35`, `log-events.md:74`). T1.1, +20 min. Neither file is an `auth-data` path (`cairn-running-passes/SKILL.md:30`) |
| I9 | major | folded | Root C-B1 |
| I10 | minor | refused | The hooks run serially in a lane and each task has its own worktree; a partial tree is repaired by the next hook, as the finding notes |
| I11 | minor | folded | T1.3 byte-identity test on the committed `app.html`; T1.5a's restore check asserts `git status --porcelain` is empty |
| I12 | minor | folded | Root M1 |
| I13 | minor | folded | Calls row "The viewer": `makeShowcaseCopy`'s per-pid prefix, already ignored (`.gitignore:31-32`), and env or port-0 binds; the fixed `.cairn-theme-viewer/` and its `.gitignore` edit are dropped |
| I14 | minor | folded | T1.5b test runs `build-tokens.mjs themes/waymark --check` inside `test:emit` |
| I15 | minor | folded | Root C-B2: with the route kept, `design.yml` keeps its spec |
| I16 | optional | folded | Partly, trivially free: temp file and `os.replace` (rename(2): "If newpath already exists, it will be atomically replaced"), `--remove` for the record packet's step, and a dotfiles commit in item 3. Probed on a copy (`tmp/fold/grant`): add, idempotent re-add, `--remove` restores the file byte-identical, `--no-merge` adds one line. The dry-run flag is not added: the script only appends or removes its own two marked lines |
| I17 | optional | refused | Optional; no marker exists under `themes/` |
| I18 | optional | folded | `--rules`; only the `render` rule's three tests render, on one page |
| I19 | optional | folded | Trivially free: `npm run prepare` in T1.5a |

## Owed erratum (the design is not edited)

- Design "What a theme directory holds", the `theme.css` row, and lines 153-154: the plan puts the
  generated daisyUI blocks and `@theme` scale in an imported `tokens/tokens.css` and keeps the
  hand-written rules in `theme.css`, the inverse of the split the design permits. The effect and
  the rule "the token values come only from the build" hold. The erratum names `tokens/tokens.css`
  as the built part of the base sheet.
- Design "Order of work" step 2: "Its renders before and after must be glance-indistinguishable in
  the viewer at all five widths." G1 lands the port before G2 builds the viewer, and proves it by
  the 51 committed `site-visual` baselines and the equivalence fixture, unchanged (plan Calls row
  "The port proof"). The erratum names the baselines as the port's proof and the viewer as the
  proof for later themes.

## Rulings

None open. Decide G-1 is the plan's own ask, unchanged by this fold.

## Estimate after the fold (superseded by the verification fold below)

G1 775 to 975 (T1.1 +65, Pair A +25, T1.3 +5, T1.5 split into T1.5a 155 and T1.5b 120 for +95,
T1.6 +10). G2 855 to 1,005 (Pair B +20, Pair C +60, T2.4 +60, T2.5 +15, T2.6 -5). Chain 1,980, 1.32
of the 1,500 estimate, under the 3,000 line; expected actual about 634; path ceiling 1,270.

## Verification fold

Source: `2026-11-08-theme-garden-fold-verification.md` (fresh agent, against `2ae94f5`): 0 blockers,
5 majors, 8 minors (2 optional). Applied on the coordinator's instruction. Each finding was checked
against the code before its disposition.

| # | Sev | Disposition | Where the revision carries it |
| --- | --- | --- | --- |
| V1 | major | folded | The "Run the check" action and its schema-validating smoke criterion move from T2.3 to T2.4, whose Files gain `scripts/theme/viewer/**`; T2.3 250 min, T2.4 290 min, so Pair C needs no T2.4 file. Calls row "The check" says T2.4 adds the action |
| V2 | major | folded | Verified `siteconfig.go:36-38` ("four candidate paths", "three legacy locations") and `corpus_test.go:69`. Both greps exclude `tool/internal/doctor/siteconfig.go` and `siteconfig_test.go`, which hold the legacy path on purpose; the doctor test writes it as one string literal, so the `"theme", "site.config.yaml"` grep still covers `siteconfig_test.go:19`. T1.1 Files gain `corpus_test.go:69` and the doc comment's counts (five and four) |
| V3 | major | folded | Verified the post-273 color and size properties (`theme.css` `--cairn-shadow`, `--cairn-cta-*`, `--cairn-caption-tracking`, and the dark `--color-card-border`). Calls row "Required token names" settles "defined" as declared by the theme's built sheets, not computed: Waymark passes once T1.5b declares both roles at the chassis defaults, and the scroll-cue break still fails, since a chassis default no longer counts. T1.5b's equivalence test is two-way over `theme.css:104-273` plus each moved property (a recorded list) plus the two roles, failing on a missing, changed, or extra declaration |
| V4 | major | folded | Calls row "Option sheets" adds the selectors the mode sheets pin; "Options in the viewer" concatenates the option sheets and then the mode sheet, as design "Setup" step 5 does, one build per option combination and mode, no cookie. T1.4 gains the composed case (the second accent sheet with `modes/dark.css`, no cookie, light system, reads the second accent's dark value; +10 min); T2.3's headless test checks the written file ends with the mode sheet. M8 is now fully closed |
| V5 | major | folded | T1.5b (renamed "Waymark's tokens and the contract", +30 min) completes `scripts/theme/fixtures/options-theme/` to contract v1 with its files listed, and `contract.test.mjs` checks both Waymark and the fixture against the contract file and the required token names before G2. T2.4's acceptance opens with "the unbroken options fixture passes every rule" |
| V6 | minor | folded | Calls row "The contract's paths": `screenshots/` allowed, not required, and `paths-required` covers each manifest-named file; T1.5a's manifest names no screenshot; T2.5 names its three PNGs in the manifest. The full check then passes Waymark at T2.4 and at T2.5 |
| V7 | minor | owed | The raw `id="fn-1"` sharing the footnote definition's prefixed id under T2.1's mechanism is accepted as a residual: GitHub's renderer gives the identical output, only trusted editors write raw HTML, and the clash stays inside the `user-content-` namespace. Not added to T2.1 |
| V8 | minor | folded | Verified `admin-mount.md:22,42`, `tidy-and-ai-posture.md:96`, and `check-chassis-boundary.test.ts:40`. Both greps also match `#theme/(cairn\.config|site-config)` and exclude the boundary test's literal |
| V9 | minor | folded | Verified `site-config-path.test.ts:24-30` already pins the default. T1.1 cites it as the existing pin, with the JSON edit committed first as its red |
| V10 | minor | folded | The plan's intro maps design steps 1 and 2 to the passes as they are split; "Owed erratum" gains the port-proof substitution |
| V11 | minor | folded | I2 and I3 now read "folded in part, refused in part", each with its refused half's reason. The optional `pre` scripts are not added |
| V12 | optional | refused | Optional; the coordinator directed the two optional findings skipped |
| V13 | optional | refused | Optional; skipped as V12 |

Also folded on the coordinator's instruction: the conductor prompt's packet list gains item 4, the
I8 hard break for old-layout sites as its own visible routine row (the former item 4 is now 5).

Totals: 13 verification findings. Folded 10, owed 1, refused 2.

## Estimate after the verification fold

G1 975 to 1,015 (Pair A 175 to 185 through T1.4's composed case; T1.5b 120 to 150 through the
fixture's completion). G2 stays 1,005 (Pair C 270 to 250, T2.4 270 to 290). Chain 2,020, 1.35 of the
1,500 estimate, under the 3,000 line; expected actual about 646; path ceiling 1,290.
