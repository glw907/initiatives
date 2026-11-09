# Mechanics and feasibility review: theme-garden plan, initiatives commit `2065b92`

Reviewer: `standards:plan-reviewer` (Opus, medium), 2026-11-08. Saved by the planning session from
the agent's reply. Code read at cairn-cms `8332ea45c` (local main `b29977baf` contains it), post-P6
paths mapped back per P6 T6.4. Probe scripts: `/var/home/glw907/.claude/jobs/64fd49ae/tmp/{probe,dtcg,tw}`.

**Verdict: not ready to launch.** One blocker and ten majors, all foldable without changing the design.

## Checked and confirmed (no finding)

- Citations that hold: `package.json:5-9`, `emit-template-dir.mjs:82-88` and `:98-104`,
  `compose.ts:20`, `targets.go:22-23`, `runner_fakes_test.go:1312`, `signups/+page.server.ts:57`,
  `gate-table.json:66` and `:266`, `check-public-skill.mjs:422`, `tokens.css:75-88`,
  `prose.css:250-264`, `+page.svelte:66,86`, `archive/[page]/+page.svelte:25`,
  `(site)/+layout.svelte:67-68`, `+error.svelte:21-22`, `cairn.config.ts:259`, `report.ts:31-53`,
  `pipeline.ts:178`, `theme-fixture-copy.mjs:68-106`, chassis README 62/195/261,
  `retheme-by-tokens.md:52-56`, `checking-a-theme.md:114-116`, `test.yml:54`,
  `templates/waymark/package.json:24`.
- Fonts: the three Fontsource sheets reference 2 + 7 + 7 woff2 files, 283,828 bytes in total. The
  emit's marker strip skips binary files (`emit-template.mjs:80-89`).
- Tailwind 4.3.3 with daisyUI 5.7.50 compiles `@plugin "daisyui/theme"` and `@theme` from a file
  pulled in by `@import` (probe output carried the theme selector, `--color-accent`, `.bg-accent`,
  `.p-m`). The `cairn-tokens:start` fallback will not fire; keep or drop it.
- The DTCG schema download matches sha256 `a5acd143...` and bundles `format.json` and its
  sub-schemas under their own `$id`s.
- `add-theme-garden-grant.py` round-trips the dotfiles `settings.json` byte-identically; the two
  markers are distinct; item 3's `grep -c` prints 2 (1 on a no).
- `npm ci` runs `prepare`: npm docs list `preinstall ... prepare, postprepare`, which "run after the
  actual installation of modules into `node_modules`".
- G1's `auth-data` derivation from the two globs is right.

## Findings, ranked by consequence

1. **Blocker, correctness. Scaffolded sites inherit the showcase's lay-in scripts** (T1.5;
   `bake-template.mjs:21,113-114`). The bake copies the showcase's `scripts` verbatim, rewriting
   only `dev` and pruning `pretest:e2e`, `test:e2e`, `design:probe`. Once `predev`, `prebuild`,
   `precheck`, and `pretest:unit` run the lay-in, `templates/waymark` and every `cairn new` site call
   the repo-only `scripts/theme/lay-in.mjs`; `npm run build` and the Deploy button fail. The existing
   `predev`, `prebuild`, `precheck` already run `build:admin-css`, so the lay-in chains onto them.
   Fold: the bake gets a fail-loud rewrite that strips the lay-in from those four scripts (like
   `rewriteDevScript`); add `scripts/build/bake-template.mjs` to Files. Acceptance:
   `templates/waymark/package.json` holds no `lay-in`, and setup-matrix's `npm run build` is green.
2. **Major, correctness. The `/styleguide` retirement is dead on arrival.** Pinned by
   `site-visual.spec.ts:61-67` (10 `styleguide-*` baselines), `islands.spec.ts:13,22`,
   `starter-outline-pin.spec.ts:40`, the equivalence spec's `FOCUS_PAGES` and `focusCounts`,
   `design.yml:72` (`test:e2e -- styleguide`, the axe gate), and the showcase primary nav
   (`site.config.yaml:9`), so removing it changes every page baseline. T2.6's grep then cannot pass;
   prose.css and composition.css comments also hit it. Fold: settle "keep `/styleguide`" in Calls;
   drop the retirement from T2.3, T2.6, and the escalable list.
3. **Major, correctness. Waymark's values do not fit typed DTCG tokens, and the equivalence test
   compares strings.** Probe (ajv 8.20.0 on the bundled `format.json`): a `clamp()` `dimension` is
   invalid, as are `vw` and `em` units; a `color-mix()` color is invalid; an untyped string `$value`
   is valid. Waymark has 14 fluid `clamp()` values, `--tracking-*` in `em`, and
   `--color-card-border: color-mix(...)`. The equivalence spec reads `getPropertyValue(name).trim()`,
   the minified token text (`oklch(46% .013 72)`); a build writing `oklch(0.46 ...)` fails it. Fold: a
   Calls row: fluid and composite values are untyped string tokens (schema-valid) or stay
   hand-written, and `tokens-schema` accepts that form; the build writes oklch lightness as a percent
   at the source's precision. Acceptance: the generated blocks equal today's declarations value for
   value.
4. **Major, correctness. ajv setup.** A default `new Ajv()` throws `unknown format "uri-reference"`
   on `resolver.json`; `validateFormats: false` or `strict: false` compiles it. The house schemas are
   draft 2020-12 (`schema/*.json`); Ajv's draft-07 class rejects a 2020-12 schema and `ajv/dist/2020`
   rejects the draft-07 DTCG schema (probe `p2.mjs`). Fold: DTCG validation uses `new Ajv({
   validateFormats: false })`; the manifest and check-output schemas are draft-07 or compiled by a
   second `Ajv2020` instance; rewrite the standing answer.
5. **Major, correctness. `starter-content.mjs` reads the file T1.2 removes**
   (`scripts/build/starter-content.mjs:94-98`): `engineDirectiveNames` regex-scans
   `examples/showcase/src/theme/markdown-blocks.ts` and throws on none. `starter-overlay.test.mjs`
   runs in `test:emit`, so Pair A goes red; the file is cairn-setup's starter tooling (boundary point
   5). Fold: T1.2 repoints it to `classes.json` or the vocabulary module; pre-flight item 6 clears it.
6. **Major, correctness. `reskin-fixture.mjs` regexes the blocks T1.5 moves**
   (`scripts/lab/reskin-fixture.mjs:31,60,114,165`). After the blocks move to `tokens/tokens.css`,
   `test:reskin` finds nothing and `design.yml` goes red. Fold: add it to T1.5's Files, pointed at
   `tokens/tokens.css`.
7. **Major, correctness. T1.1's file list misses files that pin the moved paths.**
   `packages/cairn-cms-dev/src/fake-github.ts:494` (`SEED_SITE_CONFIG_PATH`) and its tests
   (`handle.test.ts:290`, `repository.test.ts:19`, `fake-github.test.ts:158`; a published package,
   so a CHANGELOG line); `tool/internal/doctor/siteconfig_test.go:19` (`filepath.Join(...,"src","theme",...)`,
   invisible to the grep); Go tests `siteconfigpath_test.go:8,23-26`, `cmd/cairn/doctor_test.go:49`,
   `doctor/report_test.go:38`, `scaffold/scaffold_test.go:46,59`; showcase tests
   `e2e/nav-from-config.spec.ts:12`, `e2e/vocabulary-admin.spec.ts:67`,
   `src/tests/unit/showcase-pages-singular.test.ts:16`; `scripts/checks/check-symbols-allowlist.mjs:38,51,60`
   (`runner`); doc comments `src/lib/content/types.ts:175,456`. Fold: list them in T1.1, add about 30
   minutes.
8. **Major, correctness. A foreseeable boundary stop.**
   `scripts/build/starter-overlay/src/content/posts/2026-11-06-add-a-page.md:16` tells editors to edit
   `src/theme/site.config.yaml`; boundary point 5 says the garden never writes the overlay; item 6
   clears only points 1 and 2; T1.1's grep hits the line. Fold: item 6 also clears this sentence and
   finding 5's edit.
9. **Major, correctness. The acceptance greps cannot pass even with correct edits.** T1.1's grep also
   prints `templates/waymark/.claude/skills/**` (`:!skills/` is root-anchored; these regenerate from
   `skills/`, which T1.6 edits later) and the historical release fixtures
   `src/tests/unit/fixtures/gate-pages/release-body-v0.99.0-rc.3.md` and
   `fixtures/release-verify/rc2-rc3.json`. T1.6's grep also hits those fixtures and six `BACKLOG.md`
   lines. Fold: T1.1 adds `':!templates/waymark/.claude/'` and `':!src/tests/unit/fixtures/'`; T1.6
   adds `':!src/tests/unit/fixtures/'`, `':!BACKLOG.md'`, `':!ROADMAP.md'`.
10. **Major, correctness. The CI job mechanism does not exist as written.** `.github/ci-green.json`
    lists workflow files (`expected`, `judgedWhenPresent`), not jobs; `test.yml` has no `paths:`
    filter and a job cannot take one. Fold: a new `.github/workflows/theme.yml` with
    `pull_request.paths` (including itself), under `judgedWhenPresent` like `setup-matrix.yml`.
    Acceptance: `ci-green <head> --pr <n>` exits 0 with a `theme` run.
11. **Major, correctness (hand-over). No conductor prompt is committed** at `2065b92`. Fold: commit
    it with the merge order, pre-flight items 1, 5, 6, 7 as checks, the G-1 gate record and merge
    command, and the record packet's contents. (Planner note: written after `2065b92`, uncommitted
    when the review ran.)
12. **Major, correctness (cheap). The `.gitignore` entry must go in the root file.**
    `examples/showcase/.gitignore` is copied into `templates/waymark` and every site; an entry there
    makes every site ignore its `src/theme/`. Fold: the root `.gitignore`, anchored
    `/examples/showcase/src/theme/`.
13. **Minor, correctness. The doctor stops finding pre-garden site configs**
    (`tool/internal/doctor/siteconfig.go:39-46`). Fold: T1.1 adds `src/theme/site.config.yaml` to the
    legacy list.
14. **Minor, correctness. The unreachable-bar answer is missing.** If the port's baselines cannot be
    met, say that G2's T2.1 and T2.2 still run and the run closes with the bar reported unmet.
15. **Minor, correctness. Protected-path waits are unpriced.** T1.1 and T1.5 edit
    `scripts/checks/gate-table.json`, a protected path, so each commit waits for CI green
    (`pass-gate-tiers.md` "Protected paths"). Fold: price the wait or batch the edits in one commit.
16. **Minor, correctness. Item 4's probe is incomplete.** Add one edit each under
    `cairn-following-admin-design/references/`, `cairn-running-passes/references/`, and
    `cairn-writing-docs/evals/`; `$CLAUDE_JOB_DIR` may be unset in a `claude --bg` session, so use
    an absolute scratch path.
17. **Minor, correctness. The `Reviewed:` line names files not yet committed.** Commit them before
    launch; `claude-launch-guard` reads the line.
18. **Minor, correctness. Wording and citations.** `bake-template.mjs:50-53` is the site README text;
    only `:169-171` is the CLAUDE.md text. The token names are the keys of `states.<state>.root` in
    `public-theme-computed.json`, not its root keys. Design line 3 still reads "proposed... Not yet
    approved."
19. **Minor, optional. `themes/` falls in no gate bucket**, so every fast-lane run on it selects every
    static check. Add it to the showcase bucket in T1.5's `gate-table` edit.
20. **Minor, optional. Two schema URL schemes.** Existing `$id`s are
    `https://cairn.pub/schema/<name>.schema.json`; the plan uses
    `https://cairn.pub/schemas/cairn-theme/1.json`. Pick one and record why.
21. **Minor, optional. A fact for step 4:** `cairn` already has a persistent `--theme dark|light` flag
    (`tool/cmd/cairn/root.go:235`), which collides with `cairn new --theme <id>`. Add to "Later passes".
22. **Minor, optional (over-ceremony).** T1.0 is a 10-minute single-deliverable task; fold it into
    T1.1's first commit.

**Estimate:** findings 1 and 5 to 8 add roughly 60 to 90 path minutes, under the 3,000 line. **No
owner fork.**
