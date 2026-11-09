Initiative: theme-garden

# Theme garden: the engine passes

Design: `../specs/2026-11-08-theme-garden-design.md` (approved by Geoff 2026-11-08, glw907/initiatives PR #174; binding)
Research: `../research/prior-art-theme-packaging.md`, `../research/prior-art-theme-switching.md`
Repo: `glw907/cairn-cms` (passes G1 and G2). Main checkout `/var/home/glw907/Projects/cairn-cms`.
Base: cairn-cms `main` once the cairn-setup run's P6 (`cairn-new-6`) has merged. Every path below is
the post-P6 path. Every `file:line` was read at `8332ea45c` (pre-P6) and is re-checked against `main`
by the conductor before G1 launches (pre-flight item 1).
Conductor: `conductor-cairn-cms`, the single conductor for cairn-setup and theme-garden (Geoff, 2026-11-08).
Load at start of every pass: `pass-core`, `cairn-pass`, `cairn-running-passes`; `cairn-judging-scope`
before any new surface; `cairn-writing-engine-code` for `src/lib/**`; `cairn-following-public-design`
for the chassis and `themes/**`; `standards:visual-fidelity` for G1's port (a theme port is
glance-indistinguishable); `standards:go-conventions` for `tool/**`; `standards:svelte-conventions`
and `standards:ts-conventions` for comments; `cairn-writing-docs` for docs.

The two rules every dispatch in this initiative carries are `pass-core` step 1's quoted samples
("Avoid over-engineering..." and "Deliver what was asked..."). Nothing below adds a feature the
design does not name. Steps 1 and 2 of the design's "Order of work" are G1 and G2. Steps 3 to 5 are
planned after G1 lands ("Later passes").

## Pre-flight

Each item is done and checked before the conductor launches G1, except where an item names G2.

1. **[session] The post-P6 re-check.** After P6 merges, the conductor runs `git -C
   /var/home/glw907/Projects/cairn-cms fetch origin` and reads every `file:line` this plan cites
   against `origin/main`, folds any drift into this file (path, line, or a mechanism P6 changed),
   and commits the fold to `glw907/initiatives` before launch. The P6-moved paths are
   `scripts/build/{bake-template,emit-template-dir}.mjs`, `scripts/build/template-repo/`,
   `scripts/build/site-config-path.json`, and the changed `scripts/build/pack-engine-template.mjs`;
   the comment at `src/lib/content/compose.ts:17-19`, which names the pre-P6 JSON path, is in the
   read. Check: `test -f scripts/build/emit-template-dir.mjs && test -f scripts/build/site-config-path.json
   && test ! -d packages/create-cairn-site/src` in the main checkout; the fold commit is on
   `origin/main` of `glw907/initiatives`; and `git -C /var/home/glw907/Projects/initiatives ls-files
   theme-garden/plans/` lists the three reviews, `2026-11-08-theme-garden-review-fold.md`, and
   `2026-11-08-theme-garden-fold-verification.md` (`claude-launch-guard` reads the `Reviewed:` line).
2. **[you] Rule on Decide G-1 and approve this plan** (its backlog edits, its estimate, and its
   standing answers) in the conductor's next packet. Check: `grep -cE '^Ruled: (yes|no)\b'
   /var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-08-theme-garden-plan.md` prints `1`.
3. **[you] Settings grant for the held files and, on a yes to G-1, the merges.** Run `python3 -I
   /var/home/glw907/Projects/initiatives/theme-garden/plans/add-theme-garden-grant.py` (add
   `--no-merge` on a no), then `claude-tooling-sync apply`, then commit
   `claude/.claude/settings.json` in `~/.dotfiles` so `check-drift` stays clean. The script is the one
   source of both lines' text. It edits only `autoMode.allow` in
   `~/.dotfiles/claude/.claude/settings.json`, writes through a temporary file and `os.replace`, and
   takes `--remove` for the record packet's undo. Check: `grep -c 'theme-garden-passes'
   ~/.claude/settings.json` prints `2` (`1` on a no), and item 4's probe proves the write.
4. **[session] Auto-mode probe, after item 3 and before G1.** A `claude --bg` probe session in the
   cairn-cms main checkout cuts a scratch worktree under `.claude/worktrees/`, cites G1 T1.6 as its
   task, and in it: edits one line in each held directory the grant names
   (`.claude/skills/cairn-following-public-design/references/public-design-system.md`, one file under
   `.claude/skills/cairn-following-admin-design/references/`, one under
   `.claude/skills/cairn-running-passes/references/`, and one case under
   `.claude/skills/cairn-writing-docs/evals/`), commits, and reverts the commit; runs `curl -fsS -o
   resolver.json https://www.designtokens.org/schemas/2025.10/resolver.json` in the scratch worktree
   (an untracked file, removed with it); runs `npm view ajv version`. It pushes nothing and removes
   the worktree. Check: the transcript shows no refusal. A refusal holds the launch and becomes a
   `[you]` grant like item 3 (`pass-core` "Pre-flight").
5. **[session] Conductor pre-launch checks** (`pass-core` "Execute"), before each pass: the main
   checkout is on `main`; `git -C /var/home/glw907/Projects/cairn-cms rev-list --count
   HEAD..origin/main` prints `0`; `git -C /var/home/glw907/Projects/cairn-cms check-ignore -q
   .claude/worktrees/x` succeeds; `pgrep -f '[t]heme-garden-<n>'` is empty; and no worktree of the
   pass shows a change the conductor did not author.
6. **[session] Boundary points.** The conductor, as cairn-setup's owner, reads the cairn-setup plan's
   "Alignment with the theme-garden initiative" and clears five things for G1:
   (a) the catalog entry shape gains `source`, and (b) the scaffold's target table moves from
   `src/theme/` to `src/site/`, both announced in the design's "Alignment with cairn-setup";
   (c) on the starter overlay (boundary point 5), G1 changes one sentence,
   `scripts/build/starter-overlay/src/content/posts/2026-11-06-add-a-page.md:16`, to name
   `src/site/site.config.yaml`, and repoints `scripts/build/starter-content.mjs:94-98`'s directive
   scan from `markdown-blocks.ts` to the chassis vocabulary, changing no starter content;
   (d) no open cairn-setup branch touches `examples/showcase/src/theme/`, which G1 untracks
   (`git -C /var/home/glw907/Projects/cairn-cms log --oneline origin/main..origin/<branch> --
   examples/showcase/src/theme` prints nothing for each open branch);
   (e) no `cairn` tool release is planned before the engine release that carries G1, since the
   scaffold fetches the engine's `latest` (`tool/internal/setup/scaffold/fetch.go:109-112`) and
   fails loud on a target the fetched template lacks (ROADMAP.md: the tool is tagged at the stable cut
   with the engine).
   Check: G1's PR `## Decisions` carries the conductor's one-line confirmation of (a) to (e).
7. **[session] G2's launch point.** G2 launches stacked on G1's branch once G1 is PR-ready with an
   accepted whole-branch review, merges `origin/theme-garden-1` first, and rebases onto `main` after
   G1 merges (the cairn-setup run's P2 and P3 pattern). Check: G1's PR shows the accepted review.

Permissions checked: each task's writes and credentials were read against auto mode for a `claude
--bg` executor. Every executor and pair writes only tracked files in its own worktree, runs `npm`,
`node --test`, `npx vitest`, Playwright Chromium, `make -C tool check`, `go test`, `npm run
lane:fast`, `wrangler dev` locally for the admin smoke (a D1 row inserted into the local database),
installs one devDependency from the public registry (`ajv`), fetches one public schema with `curl`
(item 4), pushes its branch to `glw907/cairn-cms`, and opens a PR. No task reads `~/.local/secrets`,
calls a live provider account, publishes, tags, or dispatches a workflow. The held files are the
`.claude/skills/cairn-*` files T1.6 and T2.6 name; auto mode refused `.claude/**` edits as
Self-Modification on 2026-11-02 and 2026-11-03 (cairn release-process-b plan), so item 3 grants
them and item 4 proves the write in each held directory in a background session. Pair subagents
never write a held file; they hand the content back and the executor writes it. No task edits
`.claude/settings.json`, hooks, or permission rules. Screenshots are Playwright Chromium PNGs, not a
terminal capture.

Reviewed: three lenses (`2026-11-08-theme-garden-review-mechanics.md`,
`2026-11-08-theme-garden-review-contract.md`, `2026-11-08-theme-garden-review-integrity.md`), folded
per `2026-11-08-theme-garden-review-fold.md`, with a verification read in
`2026-11-08-theme-garden-fold-verification.md` (G1 is `auth-data`, so `standards:spec-plan-review`
keeps the full set).

## Rulings before launch

### Decide G-1: the conductor merges G1 and G2 without waiting on Geoff

G1 is `auth-data` and G2 is `runner`, so by default each goes to Geoff as a packet that holds the
next step. Geoff ruled for the cairn-setup run that the conductor merges such passes itself once its
gates hold, and holds one record packet for the end ("You should be striving to avoid a long series
of obviously acceptable PRs", 2026-11-08, cairn-setup Decide 11 as amended). G1's `auth-data` reach
is two lines: a test fake's constant (`tool/internal/setup/runner_fakes_test.go:1312`) and a comment
(`examples/showcase/src/routes/admin/signups/+page.server.ts:57`). **Recommendation: yes. The
conductor merges G1, then G2, each with `gh pr merge <n> -R glw907/cairn-cms --merge
--match-head-commit <head>` once these gates hold on that head:** CI green; the whole-branch
`standards:diff-reviewer` folded with no open finding and no `escalate`; for G1, the
`standards:web-auth-security-reviewer` read folded with no open finding and the live admin smoke
passed; `npm run check:docs-gate` green on the head. The conductor posts a gate record on the PR
(one line per gate with its evidence), merges, and sends one record packet after G2 merges, with
each pass as a routine row and the held-file edits in their own row. A record Geoff sends back
becomes a fix-forward in the next garden pass, never a revert. No keeps a packet per pass, each
holding the next. Depends: pre-flight item 3, "Stops and standing answers".

Ruled:

## Calls settled here

The design leaves these to Claude ("Claude's call") or to the builder ("Left to the builder"). Each
is settled from the code, and the executor builds it as written.

| Item | Call | Why |
| --- | --- | --- |
| The site-owned directory | `src/site/`, reached as `#site/*`, holding `cairn.config.ts`, `site-config.ts`, `site.config.yaml`, `theme-options.css`, and `overrides.css` | The design's name; `#theme/*` and `#chassis/*` are already subpath imports (`examples/showcase/package.json:5-9`) |
| Sites on the old layout | A hard break, disclosed: an engine from G1 on reads only `src/site/site.config.yaml`, and `CHANGELOG.md` and `MIGRATION-NOTES.md` carry a `Consumers must:` line per action. The nav, settings, and vocabulary loads emit `config.missing` (`warn`, `scope`, `path`) when the file is absent, so the break is diagnosable; the doctor still finds `src/theme/site.config.yaml` as a legacy path | Sites are rebuilt, not migrated (Geoff's standing ruling), and cairn is pre-1.0 with the break disclosed. Today an absent file degrades silently: the nav load returns an empty tree (`src/lib/sveltekit/nav-routes.ts:91-96`) and the tidy load keeps the defaults (`content-routes-settings.ts:247-250`), both with no record, against the repo rule that a diagnosable path emits an event (cairn-cms CLAUDE.md "Diagnosing a running site"). `config.invalid` already carries `scope` for the same loads (`src/lib/log/events.ts:35`) |
| The directive vocabulary | The chassis owns it in `src/chassis/directives/`: each block's name, fields, slots, preview, and field meaning (the banner's expiry), with a default `build` that emits Waymark's markup. A theme passes a partial map of `build` functions with the same signature; an unknown key throws. Islands stay with the theme | The design's call; today `markdown-blocks.ts` mixes vocabulary and markup in one `defineBlock` per block (`examples/showcase/src/theme/markdown-blocks.ts:41-82`) |
| The documented class list | `src/chassis/directives/classes.json`, one entry per block (its root class; `icon`'s is `cairn-icon`), the one source G2's check reads and the docs point at | Engine ruling `read-from-the-source-rule` |
| What "styled" means | A class is styled when a rule whose selector names it appears in the compiled output of the theme's sheets, including the chassis sheets they import, or `site.css`. The chassis default counts, and the check's report names the sheet that styled each class | The design's chassis default renderer (design 164-166). Today the chassis's `prose.css` styles seven blocks, `site.css` styles `banner`, and `prose.css:554-593` styles `.cairn-icon`; a reading that excluded the chassis would fail Waymark |
| The hand-written rules | They stay in `theme.css`. The tokens build writes `tokens/tokens.css` (the two daisyUI blocks and the `@theme` scale), which `theme.css` imports right after the chassis and font imports, where the blocks sit today (`theme.css:90-104`) | Keeps today's cascade order; the equivalence test proves it. This inverts the split the design allows (design 153-154 names the hand-written rules as the imported part, and its table row has `theme.css` hold the generated blocks); the effect is the same and the token values still come only from the build. A design erratum is owed (fold record) |
| CSS imports from a theme | Stay relative (`../chassis/tokens.css`); `#chassis` is the TypeScript and Svelte seam | `scripts/checks/check-chassis-boundary.mjs:5-6` documents relative CSS imports as the seam |
| The tokens build | `scripts/theme/build-tokens.mjs <themeDir> [--check]`, dependency-free apart from `ajv`, on the model of Survey's `scripts/build` (157 lines, `--check` exits 1 when stale). It reads the daisyUI block `name:` values from the manifest's `colorModes`, so the blocks, `theme-names.ts`, and the cookie regex share one source | The design names Survey's build as the precedent; one source for the names replaces the drift check `theme-names.test.ts:30-31` makes today |
| Token validation | The DTCG 2025.10 resolver schema, vendored at `schema/dtcg/2025.10/resolver.json` (it bundles the format schema under its `$id`s), compiled by `new Ajv({ validateFormats: false })` (draft-07). The house schemas (`schema/*.json`, draft 2020-12) compile in a second instance from `ajv/dist/2020` | Probed 2026-11-08 (fold probe `tmp/fold/dtcg/p.mjs`, mechanics `tmp/probe/p2.mjs`): `resolver.json` (sha256 `a5acd143...`) makes a default `new Ajv()` throw `unknown format "uri-reference"`; `ajv/dist/2020` rejects the draft-07 schema and the draft-07 class rejects a 2020-12 schema |
| Token values | Plain colors are DTCG color objects (`colorSpace`, `components`). Fluid values (`clamp()`), `em` and `vw` dimensions, and composite values (`color-mix()`) are untyped string tokens, which the format schema accepts. The build writes each declaration with the same value text as today's (`oklch(45% 0.1 248)`, lightness as a percent at the source's precision) | Fold probe: a `$type: dimension` `clamp()` value, an `em` dimension, and a `$type: color` `"#fff"` fail the format schema; an untyped string `$value` and an oklch color object pass. The equivalence spec compares the computed text (`getPropertyValue(name).trim()`). Survey's `tokens.json` uses hex strings, so G3's derived copy converts them |
| Option sheets | Each `options/<key>/<value>.css` holds only the custom properties that value changes, under the selectors that reach the light block, the dark block by explicit choice, and the dark block by system preference | Proven on G1's fixture theme by computed values in all three states |
| Color-mode default sheets | The build also writes `modes/light.css` and `modes/dark.css`. A mode sheet pins the no-cookie state; a visitor's cookie still wins. Contract v1 lists `modes/`, so step 4 only concatenates built CSS | Design "Setup" 5: setup copies built CSS only; settling the path and the semantics now keeps the contract fixed |
| Fonts | Waymark ships every woff2 file its three `@fontsource-variable/*/index.css` sheets name (about 284 KB), with their `@font-face` rules in `fonts/fonts.css`; the three devDependencies leave the showcase and the template | Same files, same render; under the 400 KB limit (measured 2026-11-08) |
| Theme tests | A theme's own `*.test.ts` files are contract paths and lay in with it | They test the theme's components, as today (`theme/banner-component.test.ts`) |
| The contract's paths | Contract v1 lists the design's table plus `tokens/tokens.css`, `modes/`, `fonts/fonts.css`, and `*.test.ts`, and the theme-directory page names each | They extend the design's table (design 135-147), which the design allows; one list keeps the check and the page in step |
| Required token names | The keys of `states.<state>.root` in `examples/showcase/e2e/fixtures/public-theme-computed.json`, minus the names only the chassis sets (`color-scheme`, `--flow-space`, `--depth`, `--noise`, each listed in the contract file with its reason), plus `--cairn-eyebrow-case` and `--cairn-scroll-cue` | The fixture holds 81 keys per state, captured before the two roles existed, and T1.5b may not update it; the design adds both roles to the list (design 183-186) |
| The showcase's `src/theme/` | Generated and disposable. The root `.gitignore` carries `/examples/showcase/src/theme/`, anchored, so neither the template nor any site ignores its own `src/theme/`. The copy is laid in from `themes/waymark/` by the root `prepare` (after `npm run package`), the showcase's `predev`, `prebuild`, `precheck`, and `pretest:unit`, and the fast lane's first step; the chassis README and the theme-directory page say to edit `themes/waymark/` | The design: generated, no longer committed. `examples/showcase/.gitignore` is copied into `templates/waymark/` (`emit-template-dir.mjs:38-39`), and the scaffold commits a site to git, so an entry there would leave every site's theme out of its repo. Root `prepare` runs in every `npm ci`, the setup command's first step, and every CI job (`.github/workflows/test.yml:54`), so no held setup command or workflow changes |
| The template's scripts | The bake strips the lay-in from the showcase's `predev`, `prebuild`, `precheck`, and `pretest:unit`, fail-loud like `rewriteDevScript`, leaving each in its template form | The bake copies the showcase's scripts verbatim apart from its named prunes (`bake-template.mjs:21,148`), and `scripts/theme/lay-in.mjs` exists only in cairn-cms |
| The lay-in step | `scripts/theme/lay-in.mjs <themeDir> <siteDir>`: replaces `<siteDir>/src/theme/` wholesale with the theme minus `screenshots/`, then writes the generated names. It refuses when `<themeDir>` lacks `cairn-theme.json`, when `<siteDir>` lacks `package.json`, or when `<themeDir>` and `<siteDir>/src/theme` overlap in either direction. The emit and the pack call it; the Go scaffold extracts the composed tree and lays nothing in | One code path into every channel (design "Catalog and hosting"). The refusals catch swapped arguments and a `--theme` that names the copy itself; the copy is disposable, so no edit-preserving machinery is added |
| The generated names | `src/theme/theme-names.ts` from the manifest's `colorModes`, and the cookie regex line in `src/app.html` between two marker comments, rewritten fail-loud and byte-identical to the committed line | The design: generated from the manifest; a theme never edits outside its directory. An install that rewrote the tracked `app.html` would leave every fresh worktree dirty |
| The lock | Not written in G1 or G2. Step 4's setup pass writes `theme-lock.json` with the owner's answers | The design puts the lock under "Setup" |
| The port proof | G1 proves the port by the 51 committed `site-visual.spec.ts` baselines and the equivalence fixture, unchanged, in place of the viewer the design names (design 370-371) | The viewer arrives in G2. The baselines are pixel-exact at five widths, and the 10 `/styleguide` baselines pin every directive under Waymark |
| The viewer | `scripts/theme/viewer.mjs`, grown from `scripts/lab/theme-fixture-copy.mjs`'s `makeShowcaseCopy` (a showcase copy with `node_modules` linked, per process, under the ignored `.cairn-theme-fixture-<pid>/` prefix), with the `.cairn-template.json` exclusions applied and the starter overlay plus the conformance set as its content. Every server binds to a port from an environment variable or port 0 | Reuses a working copy-and-link helper whose per-pid directories and stale sweep (`theme-fixture-copy.mjs:13,41-51`) keep parallel `node --test` files apart; reads themes only through `templates/catalog.json`, a manifest, or a `--theme <dir>` path |
| Options in the viewer | For each option combination the viewer writes the scratch site's `src/site/theme-options.css` by concatenating the chosen option sheets, as setup's step 5 does, and builds once per combination; it sets the color mode by the theme cookie | The proof then covers the cascade position a site has |
| `/styleguide` | Stays in the showcase through G2. The viewer's conformance directives page is the place to see every directive under a theme. T2.6 files one `#initiative:theme-garden` item for a later retirement: port the axe run to the viewer's directives page, move the 10 baselines, then retire the route | The design leaves the retirement to the builder (design 288-290). Today the route holds 10 of the 51 port baselines (`site-visual.spec.ts:61-67`), the equivalence spec's focus pages, the only axe run over every directive (`e2e/styleguide.spec.ts`, run by `design.yml:72`), and a primary-menu entry (`site.config.yaml:9`) |
| The check | A node script first, `scripts/theme/check.mjs` (`npm run check:theme`); its `--json` output has a schema, `schema/cairn-theme-check.schema.json`, like the tool's other JSON outputs. `--rules <ids>` limits a run to named rules, and `--catalog` checks every `templates/catalog.json` entry. The viewer's control page runs it on the loaded theme on demand | Setup never runs it; the viewer and CI are node. Only the `render` rule builds a site, so the static rules' tests skip it |
| The check's CI home | Two steps in the existing `test` job of `.github/workflows/test.yml`, after the showcase install, with no `if:`: `npm run test:theme` and `npm run check:theme -- --catalog`. `publish.yml`'s `ci-green` waits on the `test` check run for every release (`publish.yml:44-47`), so a catalog theme that fails the check cannot cut, and neither `publish.yml` nor `.github/ci-green.json` changes | The design: "A catalog theme passes the theme check in cairn-cms CI before a release can cut." A separate path-filtered job would never run on the release commit, and `ci-green.json` lists workflow files, not jobs (`ci-green.json:2-16`). The render costs one showcase build (13 s on CI, e2e run `npm --prefix examples/showcase run build`, 2026-11-09) plus the page loads, inside a job that ran 8 to 26 minutes against `timeout-minutes: 35` |
| The conformance set | `scripts/theme/conformance/`, mirroring `src/content/**` and `static/**`, hand-written against the CommonMark 0.31.2 section list, with no new dependency | The design allows seeding from `commonmark-spec`; hand-written pages avoid a dependency for a one-time list |
| The contract data | `schema/cairn-theme-contract-1.json`: required paths, allowed paths, generated paths, and the required token names. The check reads it; the theme-directory page explains it | One source; it ships with the engine like the manifest schema |
| The schema URL | `$schema` names `https://cairn.pub/schemas/cairn-theme/1.json`, with a `// WATCH:` beside the constant; publishing it moves to the cairn.pub rebuild, since cairn.pub is rebuilt from scratch (cairn-setup P7, dropped 2026-11-08) | The design fixes the URL scheme (design 193-194); the check never fetches; the URL serves editors once cairn.pub serves it |
| The pass split | G1: the contract and Waymark's port. G2: the conformance set, the viewer, the check, and CI. G2 stacks on G1 | G1 changes what a site gets; G2 builds the tools that prove it. Each is one coherent PR |

## Backlog verdicts (scoped sweep, cairn-cms `BACKLOG.md` at `8332ea45c`)

The scope is the items tagged `#initiative:theme-garden`, the items filed from builder A's friction
list (`../../907-rebuild/plans/2026-11-08-friction-builder-A.md`), and the items naming a file the
passes change. Approving this plan approves these edits; G1's T1.0 lands them on its branch.

| Item | Verdict | Where, or why |
| --- | --- | --- |
| #361 theme packaging path and the generated cookie regex | fold | G1 (the whole pass), and T1.6 records its scope verdict in `engine-rulings.md`. The brand-color prompt it names retires with the wizard in P6; the option questions are step 4 |
| #376 what the chassis owns and which selector an override takes | fold, retag `#initiative:theme-garden` | G1 T1.6: `retheme-by-tokens.md:52-56` gives each key's home as "the block"; the rewrite names the chassis-owned namespaces and each key's literal selector, and a comment at `cairn-public.css`'s `:root, [data-theme]` default says why the engine needs `[data-theme]` |
| #377 the scaffold's `test:unit` runs `svelte-kit sync` first | fold, retag | G1 T1.5a writes the showcase's `pretest:unit` (lay-in, then `svelte-kit sync`); the bake strips the lay-in and keeps the sync (`templates/waymark/package.json:24`) |
| #378 `--cairn-eyebrow-case` and a scroll-cue switch | fold, retag | G1 T1.3 (`tokens.css:75-88`, `prose.css:250-264`, the three eyebrow sites) |
| #379 theme checks' `/styleguide` references | done | `62e66dfb5`, merged in PR #202 (`a55cf548e`): `checking-a-theme.md:114-116` names the every-element post |
| #380 `cairn-audit` prints what it measured | fold, retag | G2 T2.4a (`src/lib/audit/report.ts:31-53` prints counts only); the check needs the list |
| #387 a footnote links to an id the page lacks | keep, taken as a priced task, retag | G2 T2.1. It is outside the lines the passes rewrite (`src/lib/render/pipeline.ts:178`, `sanitize-schema.ts`), but the design's GFM conformance page needs footnotes. The conductor confirms no cairn-setup pass has taken it |
| #388 the template's site config still describes the trail demo | keep, `*(swept 2026-11-08)*` | The garden moves the file and never changes the starter content; T1.6 repoints the item's path to `src/site/site.config.yaml` |

Builder A's items map to #361 (2, 4), #376 (3, 10), #377 (7), #378 (5, 9), #379 (6), and #380 (8).
Item 1, the engine's and scaffold's different `latest`, is setup's and is not filed here. A full sweep
is not due: of 97 open items, none was filed more than 90 days ago (oldest #64, 2026-10-25).

## The design's estimate

The design carried no estimate, so the planner set one from recent scores, for Geoff to approve with
this plan. Actual against planned path, from the merged PRs' score rows: #201 cairn-new-1 about 240
of 1,190 (0.20), #188 cleanup pass 8 246 of 839 (0.29), #193 setup-fix 210 of 665 (0.32), #186 p2-p4
235 of 580 (0.41), #195 release gate A about 480 of 900 (0.53); #202 was not clocked. **Factor:
0.32**, the median.

Sized top-down from those actuals: G1 is like #186 (a broad move with visual baselines, about 235
actual), G2 like #188 (new tooling with tests, about 246), so about 481 actual minutes. Divided by
0.32, the estimate is **1,500 path minutes**. After the review fold, the plan's chain is 1,980 (G1
975, G2 1,005), 1.32 of it, under the twice-estimate line (3,000). The fold added the files and
guards the reviews found (the bake rewrite, the readers of the generated copy, the protected-path
waits, the check's acceptance cases) and removed the `/styleguide` retirement. Expected actual on the
chain: about 634 minutes.

## Passes

| Pass | Slug | Class | Path minutes | Merge |
| --- | --- | --- | --- | --- |
| G1 | `theme-garden-1` the contract and Waymark's port | `auth-data` (T1.1), with `runner` edits | 975 | the conductor, on a yes to G-1 |
| G2 | `theme-garden-2` conformance set, viewer, check, and CI | `runner` | 1,005 | the conductor, on a yes to G-1 |

G1's class comes from two paths in T1.1: `tool/internal/setup/runner_fakes_test.go` (the
`tool/internal/setup/{loopback,signin,runner}*` glob) and `examples/showcase/src/routes/admin/signups/`
(`**/admin/signups/**`). Its `runner` edits are `scripts/checks/**`. G2's class comes from
`.github/workflows/test.yml`.

Each task block below is what a pair dispatch quotes verbatim. Every task writes `.pass-task-clock`
at its start (`pass-core` "Clock stop"), commits, and runs `npm run lane:fast -- --range
<base>..HEAD` at its end. A task that edits a protected path (`scripts/checks/gate-table.json`,
`.github/workflows/`; `pass-gate-tiers.md` "Protected paths") waits for CI green on its own commit,
and its estimate carries the wait. An `auth-data` task commits its failing test first, then the
change. No pass bumps a version or publishes (`cairn-running-passes` "No release").

### G1 `theme-garden-1`: the contract and Waymark's port (`auth-data`)

Outcome: a site's own files live in `src/site/`; the chassis owns the directive vocabulary and two
new roles; Waymark lives in `themes/waymark/` as tokens, a resolver, and a manifest, and reaches the
showcase, the committed template, and the engine tarball through one lay-in step; and the public
pages render exactly as before.

**T1.0 Ledgers** (10 min, `ordinary`). Outcome: the approved backlog edits in "Backlog verdicts"
land on the branch. Files: `BACKLOG.md`. Acceptance: `grep -c '#initiative:theme-garden' BACKLOG.md`
prints exactly `6`, and each of the lines `grep -E '^- \[ \] \*\*#(361|376|377|378|380|387)\*\*'
BACKLOG.md` prints carries the tag; #379 sits under `## Done` as `done: 62e66dfb5`; #388 carries
`*(swept 2026-11-08)*`.

**T1.1 The site's files move to `src/site/`** (215 min, `auth-data`, test first, protected path).
Outcome: `cairn.config.ts`, `site-config.ts`, and `site.config.yaml` move from
`examples/showcase/src/theme/` to `examples/showcase/src/site/`, reached through a new `#site/*`
import; `src/site/theme-options.css` and `src/site/overrides.css` exist, each holding one header
comment, and the (site) layout (`routes/(site)/+layout.svelte:67-68`), `routes/+error.svelte:21-22`,
and the preview's `stylesheets` (`cairn.config.ts:259`) link them after the theme's sheets, options
before overrides; `cairn.config.ts` imports the theme's pieces through `#theme/*`; every importer
repoints (`src/chassis/{content,feed,entry-data,cairn.server,public-routes}.ts`, the routes and tests
that import `#theme/cairn.config.js` or `#theme/site-config.js`); `vite.config.ts`'s `configModule`
names the new path; the engine's `DEFAULT_SITE_CONFIG_PATH` (`src/lib/content/compose.ts:20`), its
doc comments at `src/lib/content/types.ts:175,456`, and `scripts/build/site-config-path.json` name
`src/site/site.config.yaml`, and `scripts/build/emit-tool-conditions.mjs` regenerates
`tool/internal/doctor/site-config-path.json`; the doctor's legacy list
(`tool/internal/doctor/siteconfig.go:39-46`) gains `src/theme/site.config.yaml`; the nav, settings,
and vocabulary loads emit `config.missing` (`warn`, `scope`, `path`) when the site config is absent,
added to `src/lib/log/events.ts` and to the `cairn-extending-a-site` skill's
`references/log-events.md`; the scaffold's targets (`tool/internal/setup/scaffold/targets.go:22-23`)
and the runner fake (`tool/internal/setup/runner_fakes_test.go:1312`) name the new paths; the bake's
site README text (`scripts/build/bake-template.mjs:50-53`) and CLAUDE.md text (`:169-171`, which also
names `#site/*`) describe `src/site/`; the comment at `routes/admin/signups/+page.server.ts:57` names
the new path; the starter overlay sentence pre-flight item 6 (c) cleared names the new path;
`scripts/checks/gate-table.json:66` repoints; `templates/waymark/` is regenerated. Files: those
named, plus the files that pin the old paths: `packages/cairn-cms-dev/src/fake-github.ts:494`
(`SEED_SITE_CONFIG_PATH`) and its tests (`handle.test.ts:290`, `repository.test.ts:19`,
`fake-github.test.ts:158`); the Go tests `tool/internal/doctor/siteconfig_test.go:19` (a
`filepath.Join` the string grep cannot see), `siteconfigpath_test.go:8,23-26`,
`tool/cmd/cairn/doctor_test.go:49`, `tool/internal/doctor/report_test.go:38`, and
`tool/internal/setup/scaffold/scaffold_test.go:46,59`; the showcase tests
`e2e/nav-from-config.spec.ts:12`, `e2e/vocabulary-admin.spec.ts:67`, and
`src/tests/unit/showcase-pages-singular.test.ts:16`; `scripts/build/bake-template.test.mjs`; and
`scripts/checks/check-symbols-allowlist.mjs:38,51,60`. Acceptance, with the tests committed first
and red: the targets change in `targets.go` lands first, and the existing
`TestAMissingAnchorFailsNamingTheFileAndLeavesNothing` (`scaffold_test.go:373-383`) fails with "the
template has no src/site/..." until the template is regenerated; `src/tests/unit/site-config-path.test.ts`
pins compose's default to the JSON; a node test in `scripts/build/emit-template.test.mjs` fails when
the emitted tree carries any of the three files under `src/theme/`; a unit test whose backend returns
no site config for the nav load fails unless one `config.missing` record with `scope: 'nav'` and the
path is emitted; a doctor test finds a site whose config sits at `src/theme/site.config.yaml`; a
showcase unit test reads `routes/(site)/+layout.svelte` and `routes/+error.svelte` and fails unless
their stylesheet links run theme, site, theme-options, overrides in that order, and fails unless the
preview's `stylesheets` lists the same four in that order. Then `make -C tool check`, `npm run
check:template`, `test:emit`, and the showcase's `npm run check` and `npm run build` pass; `git grep
-nE 'src/theme/(cairn\.config|site-config|site\.config)' -- . ':!docs/' ':!skills/' ':!.claude/'
':!claude/' ':!templates/waymark/.claude/' ':!src/tests/unit/fixtures/' ':!CHANGELOG.md'
':!MIGRATION-NOTES.md' ':!BACKLOG.md' ':!ROADMAP.md'` prints nothing (T1.6 owns the excluded doc
paths; the fixtures are historical release records); and `git grep -n '"theme", "site.config.yaml"'
-- tool` prints nothing.

**Pair A: T1.2 and T1.4**

**T1.2 The directive vocabulary moves to the chassis** (130 min, `ordinary`). Outcome:
`examples/showcase/src/chassis/directives/` holds the nine blocks' vocabulary and a default `build`
each (the markup `markdown-blocks.ts` emits today), the class list `classes.json`, and the function
that composes the registered blocks from a theme's renderer map, throwing on a key outside the
vocabulary; the theme supplies `src/theme/directives/renderers.ts` (empty for Waymark) and keeps its
islands under `src/theme/directives/islands/`; `markdown-blocks.ts` leaves the theme; the chassis
README's "What lives here" table names the new seam, which `check:chassis-boundary` reads;
`scripts/checks/check-public-skill.mjs:422` loads the vocabulary from its new module; and
`scripts/build/starter-content.mjs:94-98`'s `engineDirectiveNames` reads the names from
`classes.json` (pre-flight item 6 (c)). Files: `examples/showcase/src/chassis/directives/**`,
`examples/showcase/src/chassis/README.md`,
`examples/showcase/src/theme/{markdown-blocks.ts,directives/**,islands/**}`,
`examples/showcase/src/site/cairn.config.ts` (its `blocks` import), `scripts/checks/check-public-skill.mjs`,
`scripts/build/starter-content.mjs`. Acceptance: unit tests fail when an unknown renderer key does
not throw with the key named, when a `callout` renderer replaces anything but callout's `build`, and
when the nine vocabulary names differ from `classes.json`'s; the existing directive and banner tests
pass unchanged; `npm run check:chassis-boundary`, `npm run check:public-skill`, and `test:emit`
(which runs `starter-overlay.test.mjs`) pass.

**T1.4 The schemas and the tokens build** (175 min, `ordinary`). Outcome:
`schema/cairn-theme-1.schema.json`, the manifest schema (the design's fields; `id` matches
`^[a-z][a-z0-9-]{1,31}$`; `description` at most 60 characters; `contract` is `1`; zero to four
options, each with two to eight values and a `default` among them; `fonts` with SPDX licenses and
woff2 files; `additionalProperties: false`), stating that an option key is a contract, with a `//
WATCH:` beside the `$schema` URL constant for its publication; the vendored
`schema/dtcg/2025.10/resolver.json` with its source URL, sha256, and license line in
`schema/dtcg/README.md`; `ajv` as a root devDependency at its newest production version, set up as
"Token validation" says; `scripts/theme/build-tokens.mjs` validates `tokens/tokens.json` and
`tokens/resolver.json` and writes `tokens/tokens.css` (block names from the manifest's
`colorModes`), one `options/<key>/<value>.css` per option value, and `modes/{light,dark}.css`, with
`--check` exiting 1 when any is stale; and a fixture theme, `scripts/theme/fixtures/options-theme/`,
with one `accent` option of two values and a `site.css` carrying Waymark's banner rules. Files:
`schema/**`, `scripts/theme/build-tokens.mjs`, `scripts/theme/build-tokens.test.mjs`,
`scripts/theme/fixtures/options-theme/**`, `package.json`, `package-lock.json`. Acceptance (node
tests): the fixture's files validate, and a color `$value` of `"#fff"` fails with the token's path
named, while an untyped `clamp()` string passes; the manifest schema rejects a 61-character
description, the id `Waymark`, five options, an option with one value, and a `default` outside its
values, and accepts the fixture's manifest; `--check` exits 1 after a token edit and 0 after a
rebuild; renaming the fixture manifest's dark `colorModes` entry renames the built dark block; a
compiled fixture page reads a different `--color-accent` under each accent value in the light,
dark-explicit, and dark-system states; with `modes/dark.css` linked, no cookie, and a light system,
the page reads the dark block's `--color-base-100`, and with the cookie set to the light name it
reads the light value; the mirror case holds for `modes/light.css` under a dark system. The
`test:emit` list (root `package.json`) gains the new test file.

**T1.3 Two chassis roles and the generated names** (80 min, `ordinary`). Outcome:
`--cairn-eyebrow-case` (default `uppercase`) and an `eyebrow-case` utility beside `heading-case`
(`src/chassis/tokens.css:75-88`), applied in place of `uppercase` at
`routes/(site)/+page.svelte:66,86` and `routes/(site)/archive/[page]/+page.svelte:25`; a
`--cairn-scroll-cue` role whose `none` turns off the gradient at `src/chassis/prose.css:250-264`; and
`scripts/theme/theme-names.mjs`, which writes `src/theme/theme-names.ts` from a manifest's
`colorModes` and rewrites the cookie regex line between two marker comments in `src/app.html`,
throwing when a marker is missing. `theme-names.test.ts` moves to the generator. Files: those named,
`examples/showcase/src/app.html`, `examples/showcase/src/theme/theme-names{.ts,.test.ts}`,
`scripts/theme/theme-names.test.mjs`, root `package.json` (`test:emit`). Acceptance: a node test
feeds the names `survey` and `survey-dark` and fails unless both files name them, fails unless a
missing marker throws, and fails unless running the generator on the committed showcase `app.html`
with Waymark's names leaves it byte-identical; a Playwright assertion reads `text-transform:
uppercase` on the home eyebrow and `none` after `page.addStyleTag` sets `--cairn-eyebrow-case: none`
on `:root`, and on `/posts/the-reading-surface` asserts a `pre` exists, then reads its
`background-image` before and after `--cairn-scroll-cue: none`; `theme-toggle.spec.ts` passes.

**T1.5a Waymark moves to `themes/` and the lay-in** (155 min, `ordinary`, protected path).
Outcome: Waymark's files move with `git mv` from `examples/showcase/src/theme/` to
`themes/waymark/` (blame follows), unchanged apart from the fonts; `themes/waymark/cairn-theme.json`
holds the copy deck's description, contract `1`, `colorModes` `cairn` and `cairn-dark`, no options,
the three font families with OFL-1.1 and their files, and the three screenshot paths G2 fills;
`fonts/` and `fonts/fonts.css` replace the three `@fontsource-variable/*` devDependencies, which
leave the showcase and the template; `scripts/theme/lay-in.mjs` lays a theme into a site as "The
lay-in step" says, refusals included; the root `prepare`, the showcase's `predev`, `prebuild`,
`precheck`, and `pretest:unit`, and `scripts/checks/fast-lane.mjs` (once, before its gates) run it;
the root `.gitignore` carries `/examples/showcase/src/theme/` and the tree is untracked; the bake
strips the lay-in from the template's scripts ("The template's scripts"); `.cairn-template.json`
excludes `src/theme`; `composeTemplate` (`scripts/build/emit-template-dir.mjs:82-88`) takes a theme
id and lays it in after the bake; `packEngineTemplate` writes `template/<id>/` for each
`templates/catalog.json` entry, keeping the `.gitignore` rename per entry
(`pack-engine-template.mjs:4-5`); each entry gains `"source": "engine"`; `readTree`
(`scripts/build/emit-template-dir.mjs:98-104`) compares bytes, since fonts are binary;
`scripts/checks/gate-table.json:266` adds the `themes/` prefix beside `examples/showcase/src/theme/`,
and the `showcase` bucket gains `themes/`; the chassis README says the showcase's `src/theme/` is
generated; and `templates/waymark/` is regenerated. Files: those named, root and showcase
`package.json`, `examples/showcase/package-lock.json`, `scripts/build/bake-template{,.test}.mjs`,
`scripts/build/{emit-template,pack-engine-template}*.mjs`, `scripts/theme/lay-in{,.test}.mjs`,
`templates/catalog.json`, `templates/waymark/**`. Acceptance: CI on the head passes
`site-visual.spec.ts` (51 baselines: five pages at five widths in two modes, plus
`site-article-light-1920`) and `public-theme-equivalence.spec.ts`, and `git diff --exit-code
origin/main...HEAD -- 'examples/showcase/e2e/*-snapshots/'
examples/showcase/e2e/fixtures/public-theme-computed.json` exits 0; `npm run check:template` passes;
`pack-engine-template.test.mjs` fails unless `template/waymark/src/theme/cairn-theme.json` exists,
`template/waymark/src/theme/screenshots` does not, and every catalog entry carries `source`; an emit
test runs `git init` and `git add -A` on the emitted tree and fails unless `git ls-files src/theme`
lists `cairn-theme.json` and `theme.css`; an emit test fails when any script in the emitted
`package.json` names `lay-in`; a `test:emit` test fails when `git ls-files examples/showcase/src/theme`
prints anything; lay-in tests fail unless a stale file in the target's `src/theme/` is gone after a
lay-in, and unless each refusal (no manifest, no `package.json`, overlap either way) exits nonzero
with the reason named; `npm run lane:fast` prints the lay-in line before its first gate; and in the
worktree, `rm -rf examples/showcase/src/theme && npm run prepare` restores it and leaves `git status
--porcelain` empty.

**T1.5b Waymark's tokens** (120 min, `ordinary`). Outcome: `themes/waymark/tokens/tokens.json` and
`tokens/resolver.json` hold today's values from `theme.css:104-273` in the forms "Token values"
names, with the generated `tokens/tokens.css`, which `theme.css` imports in place of its inline
blocks (the hand-written rules stay); `schema/cairn-theme-contract-1.json` lists the required,
allowed, and generated paths ("The contract's paths") and the required token names ("Required token
names"); `scripts/lab/reskin-fixture.mjs:31,60,114,165` reads the blocks from `tokens/tokens.css`;
and `scripts/checks/check-invisible-craft.mjs:87`'s `CSS_FILES` adds
`examples/showcase/src/theme/tokens/tokens.css`, so `gap-scale`, `motion-band`, and `token-colors`
keep seeing the values that moved. Files: `themes/waymark/{theme.css,tokens/**}`,
`schema/cairn-theme-contract-1.json`, `scripts/lab/reskin-fixture.mjs`,
`scripts/checks/check-invisible-craft.mjs`, `scripts/theme/build-tokens.test.mjs`,
`templates/waymark/**`. Acceptance: a node test fails unless every declaration in Waymark's
generated `tokens/tokens.css` equals the same property's declaration in `theme.css:104-273` at
`origin/main`, name for name and value for value after whitespace normalization, and unless the
built blocks are named `cairn` and `cairn-dark`; a node test fails unless `build-tokens.mjs
themes/waymark --check` exits 0; a unit test fails unless both new roles are in the contract file's
token names; CI on the head passes `site-visual.spec.ts` and `public-theme-equivalence.spec.ts` with
the same `git diff --exit-code` command exiting 0; `npm run test:reskin` and `npm run
check:invisible-craft` pass.

**T1.6 Docs, rulings, and records** (130 min, `ordinary`, held files). Outcome: every page and held
file that names a moved file points at `src/site/`: `skills/**`, `docs/admin/**`,
`.claude/skills/cairn-following-public-design/references/public-design-system.md`,
`.claude/skills/cairn-following-admin-design/references/admin-design-system.md`,
`.claude/skills/cairn-running-passes/references/pass-gate-tiers.md`,
`.claude/skills/cairn-writing-docs/references/docs-register.md`, and the
`.claude/skills/cairn-writing-docs/evals/` cases that name a moved file; `theme-directory.md` becomes
the contract v1 page (`src/site/` against `src/theme/`, `themes/<id>/`, every contract path including
`tokens/tokens.css`, `modes/`, `fonts/fonts.css`, and `*.test.ts`, the manifest, the directive seam,
the contract data file, and that the showcase's `src/theme/` is generated from `themes/waymark/`);
`retheme-by-tokens.md` carries #376 and editing tokens through `tokens.json` and the build;
`cairn-public.css` gains #376's comment; `prose-code.md` and `prose-tables-and-figures.md` name the
scroll-cue role; `docs/internal/engine-rulings.md` gains the #361 entry (the design's "Scope verdict
on BACKLOG #361"); `CHANGELOG.md` `## Unreleased` and `MIGRATION-NOTES.md` carry the move with one
`Consumers must:` line per consumer action (move the three files and their imports, link
`theme-options.css` and `overrides.css`, the `DEFAULT_SITE_CONFIG_PATH` change, and the eyebrow
role), the `config.missing` event, and the dev package's seed path; #388's path repoints; and
`templates/waymark/` is regenerated, since its `.claude/skills/` derive from `skills/`. The executor
writes the held files itself. Acceptance: `git grep -nE
'src/theme/(cairn\.config|site-config|site\.config)' -- . ':!CHANGELOG.md' ':!MIGRATION-NOTES.md'
':!docs/internal/' ':!src/tests/unit/fixtures/' ':!BACKLOG.md' ':!ROADMAP.md'` prints nothing; `npm
run check:docs-gate`, `check:vale`, `check:rulings-format`, `check:consumers-must`, `check:comments`,
`check:template`, and `test:emit` pass; `register-check`'s findings on the two rewritten pages are
closed; `docs-fact-checker` returns no open finding.

**T1.7 Close** (90 min). The whole-branch `standards:diff-reviewer`;
`standards:web-auth-security-reviewer` on T1.1's commits; `standards:svelte-reviewer` and
`standards:daisyui-a11y-reviewer` on the markup and CSS; the `standards:go-conventions` skill on the
Go change; `standards:visual-verifier` on `main`'s and the head's renders of the home, an article,
archive page 2, and the 404 at the five widths, with the executor reading the full-page renders
itself; the live admin smoke (`cairn-running-passes` "Close checklist"), which also opens the
settings screen to prove the moved `site.config.yaml` reads; the PR body (`## Brief`, what landed,
`## Decisions` with the conductor's boundary confirmation, `## Planning misses` from this plan's
section, the score). PR-ready.

Path: T1.0 10 + T1.1 215 + Pair A 175 + T1.3 80 + T1.5a 155 + T1.5b 120 + T1.6 130 + T1.7 90 =
**975**.

### G2 `theme-garden-2`: the conformance set, the viewer, the check, and CI (`runner`)

Outcome: a theme author, person or agent, renders any standard page under any theme, option, mode,
and width, and runs one check that returns a JSON verdict; CI runs the check on every catalog theme
in the job every release waits on; Waymark passes and has its catalog screenshots.

The executor's first act after setup is `git merge origin/theme-garden-1`; after G1 merges it
rebases onto `main` and reruns the fast lane. G2's node tests that build a showcase copy
(`conformance`, `viewer`, `check`) run as `npm run test:theme`, which T2.2 adds to the root
`package.json` and T2.3 and T2.4 extend; each task also runs its own file with `node --test`.

**Pair B: T2.1 and T2.2**

**T2.1 Footnote links match their ids** (75 min, `ordinary`, test first). Outcome: a footnote
reference's `href` names its definition's `id`, and its backref's `href` names the reference's `id`,
after the sanitize step, with the sanitize schema's `clobber` list and prefix unchanged. The
mechanism: `remark-rehype` takes `clobberPrefix: ''`, and a step right after `rehypeSanitize`
prefixes the in-page `href` of `a[data-footnote-ref]` and `a[data-footnote-backref]` only, with the
schema's `clobberPrefix`. Files: `src/lib/render/{pipeline,sanitize-schema}.ts`, a test under
`src/tests/unit/`, `CHANGELOG.md`. Acceptance: the test, committed first and red, renders `[^1]` with
its definition and fails unless the reference's `href` equals `#` plus the definition's `id` and the
backref's `href` equals `#` plus the reference's `id`; fails unless raw `<p id="x">`, `<p
id="fn-1">`, and `<a name="x">` still render with the prefix; fails unless a raw `<a href="#fn-1">`
outside a footnote keeps its `href`; and fails unless `buildSanitizeSchema`'s `clobber` and
`clobberPrefix` equal `defaultSchema`'s. `standards:web-auth-security-reviewer` reads the commit,
since it touches the sanitizer; #387 moves to `## Done`. (Fold probe `tmp/fold/fn/probe.mjs`: with
`clobberPrefix: ''` and the post-sanitize step, the reference reads `#user-content-fn-1` against the
definition's `user-content-fn-1`, and the plain link keeps `#fn-1`.)

**T2.2 The conformance set** (170 min, `ordinary`). Outcome: `scripts/theme/conformance/` holds the
design's hostile cases (three or more archive pages with a short last page; a child page; the 404,
the error page, and the feeds; many topics; long titles and unbroken strings; a post with no title;
posts with no image and image-only posts; a draft that stays hidden; non-ASCII and right-to-left
text; every directive empty, long, and nested; the fragments) and one page per markdown layer
(CommonMark blocks, CommonMark inlines, GFM with tables, task lists, strikethrough, extended
autolinks, and footnotes, cairn's directives, and the raw HTML the sanitizer keeps with one tag it
strips), with its own committed content manifest and every asset shipped. Files:
`scripts/theme/conformance/**`, `scripts/theme/conformance.test.mjs`, root `package.json`
(`test:theme`). Acceptance: the test fails unless each hostile case and each layer page is present,
asserted by a property of the content (the post count gives at least three archive pages and a last
page shorter than the page size; a page has a parent; a post sets `draft: true`; a post has no
title; one has no image and one holds only an image; each of the nine directives appears empty,
long, and nested; right-to-left text appears; and so on, one assertion per case); fails when any
markdown image, raw `img`, or raw `source` names an `http://`, `https://`, or `//` URL; fails when a
file of the set appears under `templates/` or `scripts/build/starter-overlay/`; and fails when the
set's manifest disagrees with its content (`cairn-manifest`'s check). T2.3's headless run prerenders
every page.

**Pair C: T2.3 and T2.4a**

**T2.3 The viewer** (270 min, `ordinary`). Outcome: `scripts/theme/viewer.mjs` (`npm run theme:view
-- [--theme <id|dir>]`) composes a scratch site through `makeShowcaseCopy`
(`scripts/lab/theme-fixture-copy.mjs:68-106`), applies `.cairn-template.json`'s exclusions, replaces
`src/content` with the starter overlay plus the conformance set (regenerating the content manifest),
and lays the theme in with `lay-in.mjs`, writing `src/site/theme-options.css` as "Options in the
viewer" says. It finds themes only through `templates/catalog.json` and each manifest, or a `--theme
<dir>` path. Interactive mode runs `vite dev` on the scratch site and serves a control page: the
page list (every starter and conformance route), a theme picker, each option's values, the color
mode, the five widths in an iframe, and a "Run the check" action that runs `check.mjs` on the loaded
theme and shows its `--json` output. A pick lays the theme in again; an edit under the theme
directory copies across, and an edit under `tokens/` reruns the tokens build first. Headless mode
(`--headless --pages <list|all> --widths <list> --modes <list> --option <key>=<value>
[--viewport-only]`) builds once per option combination, serves the prerendered output, and for each
combination loads the page in Playwright Chromium with the mode set, saves a full-page PNG (or the
viewport alone under `--viewport-only`), and prints a JSON list (`page`, `url`, `status`, `theme`,
`options`, `mode`, `width`, `file`, `consoleErrors`). Ports come from environment variables or port
0. Files: `scripts/theme/viewer*.mjs`, `scripts/theme/viewer/**`, root `package.json`. Acceptance: a
node test runs headless on the options fixture for one conformance page at 390 and 1440, both modes,
and both accent values, and fails unless it writes 8 PNGs that its JSON names and the two accent
values' PNGs differ; a smoke test starts interactive mode on a copied options fixture and fails
unless the control page lists every conformance route, the fixture's two accent values, and the five
widths, unless the check action's body validates against `schema/cairn-theme-check.schema.json`, and
unless an edit to the copy's `tokens/tokens.json` accent changes the served page's `--color-accent`
within a bounded wait (a timeout fails); a headless run over every page under Waymark at 1440 fails
unless its entry count equals the composed manifest's starter and conformance routes times two
modes, every `status` is 200 except the 404 and error pages (which return their own codes), every
`consoleErrors` is empty, and the draft's route returns 404 with its title absent from every archive
page and feed. A behavior escalated under "Stops and standing answers" takes its criterion with it.

**T2.4a `cairn-audit` prints what it measured** (60 min, `ordinary`). Outcome: `AuditReport` gains
a `measured` list (rule, file, daisyUI theme blocks) filled by `theme-contrast` and
`theme-conformance`; `formatReport` (`src/lib/audit/report.ts:31-53`) prints it, and prints
`measured nothing` when the list is empty. Files: `src/lib/audit/**`, a test, `CHANGELOG.md`.
Acceptance: a unit test over a fixture sheet with two named blocks fails unless both names and the
file are listed; a run whose scope holds no theme sheet fails unless the output says `measured
nothing`; `npm run check:surface` shows no unintended change.

**T2.4 The theme check** (270 min, `ordinary`). Outcome: `scripts/theme/check.mjs <themeDir>
[--json] [--rules <ids>]` and `check.mjs --catalog` (`npm run check:theme`) return a verdict and
print one line per theme (`check:theme: <id> pass` or `fail`); `--catalog` fails when the catalog
names no theme or an entry's directory is missing; `--json` prints each failure with `file`, `rule`,
and `message`, valid against `schema/cairn-theme-check.schema.json`. The rules, one id each:
`manifest-schema`; `contract-version`; `tokens-schema`; `resolver-options` (every modifier has a
manifest option and every context a value, and the reverse); `paths-required`; `paths-unlisted`;
`tokens-stale` (the build's `--check`); `tokens-required` (every contract token name defined in each
mode and option value); `render` (T2.3's headless run over every starter and conformance page, each
option value, both modes, at 1440, failing on a build error, a non-200 other than the 404 and error
pages, a console error, or zero pages run); `directive-styled` (every class in `classes.json` styled
as "What 'styled' means" says, the report naming the sheet); `audit` (`cairn-audit`'s
`theme-contrast`, `theme-conformance`, and `public-literals` at blocking tier, printing the measured
list, failing on any finding or on `measured nothing`); `fonts` (every file under `fonts/` named by
a manifest font with an SPDX license, woff2 only, at most 400 KB per font pairing); `external-host`
(a URL with a scheme or `//` in a CSS `url()` or `@import`, or a `src` or `href` in a component).
Files: `scripts/theme/check*.mjs`, `schema/cairn-theme-check.schema.json`, root `package.json`.
Acceptance: tests copy the options fixture and break one thing each, running with `--rules` set to
every rule but `render` (drop a required path, add an unlisted file, a 61-character description,
contract `2`, an invalid `tokens.json`, a resolver context with no manifest value, a manifest option
with no resolver modifier, a token edit without a rebuild, a required token missing in dark,
`--cairn-scroll-cue` missing under one option value only, the banner rules removed from the
fixture's `site.css`, a color literal in `theme.css`, an audit scope that measures nothing, a `.ttf`
font, a font with no license, a pairing over 400 KB, an `@import
url(https://fonts.googleapis.com/...)`, a component with `<img src="https://...">`), and each fails
unless the check reports exactly that rule; the `render` rule's own tests run on the fixture with a
one-page list: the unbroken fixture passes, a fixture component that throws during SSR fails with
exactly `render`, and one that logs `console.error` on mount fails with exactly `render`; a
`--catalog` test over an empty catalog fails; `npm run check:theme -- themes/waymark` passes.

**T2.5 Screenshots and CI** (105 min, `runner`, protected path). Outcome:
`themes/waymark/screenshots/` holds the three PNGs from headless mode under `--viewport-only` (1440
by 960 light and dark, and 390 wide light), named in its manifest, and the check's `paths-required`
covers them; the `test` job in `.github/workflows/test.yml` gains, after the showcase install
(`npm ci --prefix examples/showcase`), two steps with no `if:`: `npm run test:theme` and `npm run
check:theme -- --catalog` ("The check's CI home"). Files: those named,
`src/tests/unit/workflow-yaml.test.ts`, a test under `scripts/theme/`. Acceptance:
`workflow-yaml.test.ts` fails unless `test.yml`'s `test` job runs `check:theme -- --catalog` and
`test:theme` in steps with no `if:`, each after the showcase install, and unless `publish.yml`'s
`ci-green` step sets `NAMES` to include `test` for both a candidate and a stable; a node test reads
each screenshot's PNG IHDR and fails unless the two catalog shots are 1440 by 960 and the third is
390 wide; the `test` check run on the head passes and its log shows `check:theme: waymark pass`; the
PR records the head's `test` job duration.

**T2.6 Docs** (115 min, `ordinary`, held files). Outcome: `checking-a-theme.md` is rewritten around
`check:theme`, its rule ids, the viewer, and the check action on the control page; `theme-starter.md`
and `theme-directory.md` name the viewer, the screenshots, and the check; `CHANGELOG.md` and
`MIGRATION-NOTES.md` carry the footnote fix and the audit's measured list;
`.claude/skills/cairn-running-passes/references/pass-gate-tiers.md` names the `themes/` trigger; and
one `#initiative:theme-garden` backlog item, filed through `standards:log-issue`, scopes the later
`/styleguide` retirement ("`/styleguide`" in "Calls settled here"). Acceptance: `check:docs-gate`,
`check:vale`, `check:comments`, and `check:consumers-must` pass; `grep -c
'#initiative:theme-garden' BACKLOG.md` is one more than before the task; `register-check` and
`docs-fact-checker` return no open finding.

**T2.7 Close** (75 min). The whole-branch `standards:diff-reviewer` with the runner checklist;
`standards:svelte-reviewer` on any Svelte the viewer adds; the PR body (`## Brief`, what landed,
`## Decisions`, `## Planning misses`, the score). PR-ready.

Path: Pair B 170 + Pair C 270 + T2.4 270 + T2.5 105 + T2.6 115 + T2.7 75 = **1,005**.

Chain: G1 975 + G2 1,005 = **1,980**.

## Stops and standing answers

Approved with this plan; each is applied in place of stopping.

| Stop | Standing answer |
| --- | --- |
| Clock stop: a task past twice its estimate | With the cause traced and the rest in scope, reset `start=` once with `estimate=` the remaining work and record it in `## Decisions`. On a second stop on the same task, the conductor splits the rest into a follow-up task in the same pass, or replaces the unit the fixes keep missing, and records the call. It asks only for a cause it cannot trace |
| Path ceiling | Go on while the cause is traced and the chain's actual minutes stay under 1,270 (twice the expected 634); record the overrun in the score. Past that, or on an untraced cause, the conductor asks with the trace and a recommendation |
| A port baseline or equivalence key differs (T1.5a, T1.5b) | Fix forward from the traced cause. Regenerating a baseline or updating the equivalence expectation is never the answer for the port. Not escalable |
| The port's bar stays unmet after a structural fix fails | G1 holds short of PR-ready and the conductor asks Geoff with the trace, since the bar is the design's. G2's T2.1 and T2.2, which need no port, may still run stacked on G1's branch; the rest of G2 waits |
| The import of `tokens/tokens.css` moves a computed value | The build writes the generated blocks into `theme.css` between `/* cairn-tokens:start */` and `/* cairn-tokens:end */`, fail-loud on a missing marker, and `tokens/tokens.css` leaves the contract. Record it. (Tailwind 4.3.3 with daisyUI 5.7.50 compiles `@plugin "daisyui/theme"` from an imported file; mechanics probe `tmp/tw`) |
| The vendored schema fails to compile under "Token validation"'s setup | The conductor asks; no other ajv option is tried unrecorded |
| A CI job installs with `--ignore-scripts`, so `prepare` does not lay the showcase theme in | Add `npm run theme:lay-in` to that job before its first read (a `runner` edit), and record it |
| A showcase-only route fails the viewer's build under the standard content | Add it to the viewer's exclusions and record it |
| The `test` job's run on the head comes within 5 minutes of its `timeout-minutes` (T2.5) | Raise `timeout-minutes` to 45 in the same commit, and record the measured durations |
| A conformance case the engine renders wrong (an engine bug like #387) | Fix it in the pass when the fix is in a file the pass changes; otherwise file it `#initiative:theme-garden`, drop the case from the set with a `WATCH:` line in `conformance.test.mjs`, and list it in the PR |
| A task would change a cairn-setup boundary point beyond pre-flight item 6's five | The executor writes the change to STATUS and waits for the conductor's reply |
| A held-file edit is refused | The executor writes STATUS and waits; the conductor brings Geoff the grant as a `[you]` step |
| A red on the fast lane or CI | Fix forward or revert the commit. A known trap (`durable-gotchas.md`) reruns once. A red traced to executor reasoning moves the next task to `high` |
| A merge gate in G-1 fails | No merge; fix forward and rerun the gate. A finding that would change the design, or an `escalate`, stops: the conductor asks |
| A review round finds a blocker after the fix chain | One more review on that blocker only |
| A found item outside the task | `standards:log-issue`, tagged `#initiative:theme-garden`, listed in the PR |

**Judgment calls the run can plausibly meet, with answers:** file and function names under
`scripts/theme/` and `src/chassis/directives/` (choose and record); the check's rule ids (kebab case,
as listed, a rename recorded); the renderer type's name in the chassis; which hand-written custom
properties in `theme.css` after line 273 are token values (move a property into the tokens when it
is a color, size, space, radius, or motion value, else leave it); the viewer's ports (environment
variables, as `THEME_FIXTURE_PORT` does, or port 0); a CommonMark construct the sanitizer strips (the
conformance page shows the stripped form and says so).

**Items the run may escalate without breaking its outcome** (after a structural fix fails): the
viewer's live token rebuild; the interactive theme picker (headless mode and one theme per run
remain); the scroll-cue lines on the two prose pages. An escalated item drops its acceptance
criterion with it, never leaving the criterion passing on nothing. **Not escalable**: the
`src/site/` move, the chassis vocabulary, the generated names, the port's unchanged baselines, the
schemas and the tokens build, the check's rules, headless mode's PNGs and JSON, and the check's two
steps in the `test` job.

## Later passes, not planned here

- **G3, Survey's design pass** (design step 3), planned after G1 merges, with Geoff in the loop
  under `standards:visual-fidelity`; the conductor schedules the sitting through a packet. Two facts
  for its planner: Survey's `tokens.json` stores colors as hex strings, which the DTCG 2025.10 format
  schema rejects, so the derived copy converts them; and its `text-step-1` to `text-step-12` collide
  with the chassis reading scale (builder A item 3).
- **Setup's theme and option questions and the lock** (design step 4), once the catalog holds two
  themes, through the boundary protocol: before a task changes a boundary point, it messages the
  cairn-setup planner or `conductor-cairn-cms` and waits for the reply. A fact for its planner:
  `cairn` already has a persistent `--theme dark|light` flag (`tool/cmd/cairn/root.go:235`), which
  collides with the design's `cairn new --theme <id>`.
- **Acceptance** (design step 5): Geoff's Waymark build, its teardown, and a Survey build, on the
  first release or candidate carrying both themes.
- **The schema URL**: the cairn.pub rebuild publishes `https://cairn.pub/schemas/cairn-theme/1.json`
  and the check-output schema; the initiative record carries it, and T1.4's `// WATCH:` marks it in
  the code.
- **The `/styleguide` retirement**: the backlog item T2.6 files.

## Planning misses at design

The design was approved (initiatives PR #174) without three things `pass-core` asks a design to
carry: the scoped backlog sweep with a verdict per item, an estimate in path minutes, and the
pre-flight list. This plan supplies all three, and the held-file grant (pre-flight item 3) is an item
the design did not foresee, so it rides the conductor's next packet before the first executor
launches. The design stage missed them because its packet carried a design part with nothing that
checks it for those three. The fix that generalizes: `approval-packet` step 3 gains the rule that a
design part carries its sweep verdicts, its path-minute estimate, and its pre-flight list, or the
packet is unfinished staff work and is not sent. The planning session opens it as a dotfiles PR and
names it in its hand-over. G1's PR copies this entry into its `## Planning misses`.
