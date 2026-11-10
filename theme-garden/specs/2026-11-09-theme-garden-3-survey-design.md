# Theme garden G3: Survey's cairn theme

Initiative: theme-garden. Design step 3 of `2026-11-08-theme-garden-design.md` ("Order of work").
Brainstormed with Geoff on 2026-11-09 in session `cairn-cms-theme-garden-3-design`.

## Brief

G3 builds Survey as cairn's second house theme, in `themes/survey/`, to match the approved
specimen and five mockup screens Geoff approved today. Approving it sends the plan to
`conductor-cairn-cms`. One executor builds the theme without you, and a fresh-context grader
compares each page against the reference until it passes. You then get one read before merge:
the build's renders beside the mockups.

### What changes

- `themes/survey/` holds Survey's cairn theme: a derived copy of Survey's tokens, two options, four components, the directive styling, and self-hosted fonts.
- Survey stays out of `templates/catalog.json` until design step 4, and CI checks it by its directory.
- Backlog #412 is fixed in the engine's tokens build, since Survey's map-detail option hits it.
- A weekly advisory workflow reports when Survey's `tokens.json` changes after the commit the theme was built from.
- The naive builder's glw907/survey#10 closes with a pointer to this pass.
- Backlog items #361, #376, #377, #378, and #380 are marked done; their work landed in G1 and G2.

### If you approve

1. The design session closes glw907/survey#10 with a comment naming this design.
2. The design session writes the plan, has it reviewed, and hands it to `conductor-cairn-cms`.
3. The conductor launches G3 after setup-tooling pass 3's T3.5 dependency sweep, since theme-garden launches hold during it.
4. The executor builds, the grader loop passes, and the conductor sends you one packet with the renders beside the mockups.

### Worth knowing

The approved home layout comes from cairn: the newest post set apart, then the archive by year. Your
option 2 home (plain rows only) would need an engine change, and you chose the cairn layout dressed
in Survey. Trace, the quieter map-detail option, is subtle at a glance by design, so its setup label
says what it changes.

### Decisions from the brainstorm

Geoff ruled each of these on 2026-11-09, in this order.

- The pages the 2026-10-07 references leave out are mocked up and approved before any build. The
  mockups join the specimen as the reference the build is graded against.
- The home page keeps cairn's layout (mockup A), dressed in Survey.
- The post page, the nine directives, the phone width, the archive page, and the 404 page read as
  Survey, as mocked up.
- Survey offers two options: map detail and ink.
- Ink offers water blue (the default) and revision purple. Glacier teal is out because it reads like
  the note alert, and vegetation green is out because green is the success color.
- Trace drops the right things, though the difference is subtle at a glance.
- The collar carries the site name and the footer links only.
- The index rail stays out of the cairn theme.
- Geoff reads once, at the end, before merge. There is no mid-build sitting.

### Calls made here

Claude's calls, each from the code, the contract, or a recorded rule. Each is open to reversal in
your decision note.

- Survey's hex colors become DTCG color objects (`colorSpace: "srgb"`, `components`, and `hex`),
  which the format schema accepts and `build-tokens.mjs` already writes as `color(srgb ...)`.
- The derived `tokens.json` carries none of Survey's `text-step-1` to `text-step-13` interface
  sizes. Its sizes are the chassis names (`--text-step--2` to `--text-step-5`), and Survey is not
  renamed. The drift check compares Survey's whole `tokens.json`, so the names don't matter to it.
- Values Survey lacks are written in `themes/survey/tokens/` and filed in Survey's `BACKLOG.md` as
  gaps, per the `survey` skill. These are the reading scale, the measure, the CTA keys, the scroll
  cue, and revision purple as a second ink.
- Spectral's Vietnamese and Cyrillic Extended files are dropped. Survey's full set is 426 KB, over
  the check's 400 KB per pairing, and dropping them saves 58 KB, which leaves about 370 KB.
- The daisyUI theme names are `survey` and `survey-dark`, the names Survey already uses.
- The inline icon directive renders small and muted in the text's color, a recorded departure from
  Survey's "reading text carries no icons".
- The drift check is a weekly `schedule` workflow, modeled on `tsgo.yml`'s advisory job. It goes red
  when glw907/survey's `tokens.json` on `main` differs from the manifest's `derivedFrom` commit.
  Survey is public, so it needs no token. It goes under `neverOnPullRequest` in
  `.github/ci-green.json`, beside `tsgo.yml`, which `workflow-yaml.test.ts` requires.
- Survey joins the catalog in design step 4, not here. With two catalog entries, the scaffold
  harness (`tool/internal/setup/scaffold/harness_test.go:70`) fails on an unchosen theme, and
  agent-mode `cairn new` refuses without `--site-theme` (`agentview/view.go:73-78`). Step 4 owns
  that setup change and the tool's gate, and the setup-tooling run's proving rounds stay unchanged
  meanwhile. This reverses the call in the brainstorm playback, after the builder check.

### Estimate

**800 path minutes.** G1 took about 175 actual minutes of a 1,015 plan, and G2 about 345 of 1,025.
G3 is one theme directory plus a grader loop, so it should be about G2's size, roughly 250 actual
minutes. Divided by the recent median factor of 0.32, that gives 800, with the stop line at 1,600.
This figure excludes your read.

### Pre-flight

No `[you]` item is foreseen. G3 reads no secret and edits no held `.claude/**` file. It pushes
only the G3 branch and opens one PR.

1. `[session]` The conductor's pre-launch checks (`pass-core` "Execute"), after setup-tooling pass 3's T3.5 sweep merges.
2. `[session]` The design session has closed glw907/survey#10 (`gh pr view 10 -R glw907/survey --json state` prints `CLOSED`).
3. `[session]` The reference set is committed under `theme-garden/reference/g3/` before launch.

### Standing answers

- A mockup device cairn's markup can't reach from theme CSS: build the nearest form, record it in
  the PR's `## Decisions`, and show it in your read. This never stops the run.
- A token pair under WCAG AA: tune it within its hue, record the old and new values, and file the
  gap in Survey's backlog.
- Fonts still over 400 KB after the two subsets go: drop the next non-Latin subset and record it.
- A grader finding that returns after one structural fix: escalate that item in the PR and go on.
- Clock stop, path ceiling, reds, and found items: as in the G1 and G2 plan's "Stops and standing
  answers".

### Backlog verdicts

This is the scoped sweep of cairn-cms `BACKLOG.md` at `feb993934`. Its scope is the
`#initiative:theme-garden` items and the items naming a file G3 changes.

| Item | Verdict | Why |
| --- | --- | --- |
| #412 an option sheet over an unlayered token loses with no cookie | fold | Survey's map-detail option changes values the build writes unlayered, so G3 hits it |
| #361 packaging path and generated cookie regex | done | G1 (`64cbe711d`); ruling `scope-verdict-361` in `engine-rulings.md` |
| #376 what the chassis owns and which selector | done | G1 rewrote `retheme-by-tokens.md` ("What the chassis owns") |
| #377 scaffold `test:unit` runs `svelte-kit sync` | done | `templates/waymark/package.json:25` |
| #378 eyebrow case and scroll-cue switch | done | `--cairn-eyebrow-case` and `--cairn-scroll-cue` in the chassis `tokens.css` |
| #380 `cairn-audit` prints what it measured | done | `src/lib/audit/report.ts:31-33` |
| #410, #413, #415, #416, #417, #418, #419, #388 | keep | None is met by G3. #419 waits for a font option, which Survey doesn't offer |

## The work

G3 is design step 3. Its outcome is that `node scripts/theme/check.mjs themes/survey` passes, and
a fresh-context `standards:visual-verifier` passes every reference page at 320, 390, 768, 1440, and
2560 pixels. The grader covers light and dark and all four option combinations, and Geoff approves
the renders.

### The reference

The reference lives in `theme-garden/reference/g3/`. `approved/` holds the two 2026-10-07 pages from
cairn-themes `c19e7ac`. `mockups/` holds the five screens approved today, with their full-page
1440px renders in `renders/`. In `home.html`, mockup A is approved and mockup B was declined.
`inks.html` approves water blue and revision purple only. Geoff's collar ruling came after the
mockups, so the files were edited to match it: no mockup shows the "Contour interval" line.

The reference is the specification, per `standards:visual-fidelity`. A device a mockup shows is
built, and the grader grades against the mockup, not the plan. The mockups set every page at
desktop and phone width. The tablet and 2560 widths follow by the same rules, and a defect there is
graded IMPROVED when fixed.

### The theme

`themes/survey/` follows contract 1 (`schema/cairn-theme-contract-1.json`) and starts from Waymark's
port as the worked example. It is not a copy of the naive build.

- **Tokens.** `tokens/tokens.json` derives from glw907/survey `tokens.json` at `79efb98`. The colors
  and inks are exact. It adds a reading scale (17px body; headings in Spectral 500 at the mockups'
  sizes; the home title at 2.6rem desktop and 2rem phone), the measure, and the 67 required names.
  `tokens/resolver.json` carries the color mode plus the two option modifiers.
- **Options.** `map-detail` takes `survey-sheet` (default, "Survey sheet: map details throughout") or
  `trace` ("Trace: contour lines in the header only"). Trace hides the benchmark triangles, makes
  the dashed contour rules solid `base-300` hairlines, and sets the year headings in ink. `ink` takes
  `water-blue` (default: `#1c5a8c` light, `#7fb5e4` dark) or `revision-purple` (`#6a3d8a` light, `#c3a2e0`
  dark, with content colors `#f7f2fb` and `#1e1029`). The ink sets the primary color, links,
  buttons, and the focus ring. Both inks measure 6.2:1 or better on the page grounds.
- **Components.** `SiteHeader` has the benchmark triangle, the wordmark in Karla 700, the contour
  texture, and the nav with the current page underlined 6px below in contour brown. It keeps the
  light and dark toggle, and the nav wraps under the wordmark past three items. `SiteFooter` is
  the collar: the site name and the footer menu on `base-200`. `EntryRow` is a date column with a
  Spectral title and no excerpt, under a dashed contour rule. `ArticleView` is shown in `post.html`;
  its related list is marked with triangles.
- **Route classes.** The home and archive markup is cairn's. `theme.css` restyles its classes
  (`.lead`, `.index__head`, `.index__year`, `.pagination`, the error page) to match mockups A and
  `phone-archive-404.html`. The 404 number is Spectral, with a triangle under a faint contour run.
- **Directives.** The chassis default renderers stay. Survey styles their documented classes to
  match `directives.html`, and replaces a renderer only where markup must change.
- **Manifest.** `derivedFrom` records glw907/survey at `79efb98`. `description` stays within 60
  characters. The screenshots are the home page in light and dark at 1440 and the phone home.

### The engine and CI

- #412: the tokens build writes option values so that an option sheet wins over the base value in
  all four cookie states. The fixture theme gains a case over an unlayered token.
- `templates/catalog.json` is unchanged. The `test` job in `.github/workflows/test.yml` gains one
  step after `check:theme -- --catalog`: `node scripts/theme/check.mjs themes/survey`. Design step 4
  adds the catalog entry, the setup questions, and the matrix's theme coverage, and then removes
  this step.
- Docs: no published page lists the catalog's themes, and `checking-a-theme.md:58` stays true
  with Waymark first. `CHANGELOG.md` and `MIGRATION-NOTES.md` gain their entries.
- The drift workflow lands as `.github/workflows/survey-drift.yml`, a protected path, so its task
  waits for CI on that commit.

### Harvest

Each Survey gap found goes to Survey's `BACKLOG.md`, and each chassis friction to cairn-cms's,
tagged `#initiative:theme-garden`. Survey's backlog sits outside the executor's worktree, so the
executor lists its items in the PR and the conductor commits them after merge.

### Class and review

The class is `runner`, from the workflow. Everything else is ordinary. The close review runs
`standards:diff-reviewer` on the whole branch, `standards:daisyui-a11y-reviewer` on the theme, and the
`standards:visual-verifier` loop. The conductor's packet carries the renders for Geoff's read.

### Out of scope

The setup option questions and the lock (design step 4), a release, the index rail, a font
option, a terrain hero, and any change to cairn's route markup.
