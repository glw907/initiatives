# Theme garden plan: fold verification read

Target: `2026-11-08-theme-garden-plan.md` at glw907/initiatives `2ae94f5`, with its launch files
(`-1-prompt.txt`, `-2-prompt.txt`, `-plan-conductor-prompt.txt`, `add-theme-garden-grant.py`),
against the three reviews, the fold record, and the approved design. Code read at cairn-cms
`b29977baf` (main, pre-P6; P6-moved files read at their current `packages/create-cairn-site/`
paths). Reader: fresh context, no part in the reviews or the fold, per `standards:spec-plan-review`
"The verification read". Probes re-run under `/var/home/glw907/.claude/jobs/64fd49ae/tmp/verify/`.

**Verdict: fold again before approval.** The blockers all closed. The fold introduced three
contradictions and an order that can't build, and left one major half-closed. All five fold into
task text without a design change. No owner fork is open, and Decide G-1 can be ruled on the
evidence given.

Counts: 0 blockers, 5 majors, 8 minors (2 tagged `optional`).

## What holds

- **Blockers closed at the cited location.** C-B1, I9, and M10 close at the "The check's CI home"
  row and T2.5 (plan:161, 560-572). `test.yml` installs Chromium early (`:52`), runs `npm run
  package` (`:59`), and installs the showcase later (`:115`), so two steps after that install have
  everything the render needs. `publish.yml:52-55` sets `NAMES="test"`, and `"test e2e"` for a
  stable. `ci-green.json` lists workflow files. C-B2, M2, and I15 close: the `/styleguide`
  retirement is gone from T2.3, T2.6, and the escalable list, and the 10 `styleguide-*` of the 51
  `site-visual` baselines are confirmed. I1 and M12 close at plan:151 and T1.5a. M1 and I12 close at
  plan:152 and T1.5a, where `PRUNED_SCRIPTS` (`bake-template.mjs:21`) and `rewriteDevScript` (`:124`)
  are confirmed.
- **Majors closed.** These close as the record says: M3, M4, M5, M6, M7 (with the gap in finding 2),
  M8, M9, M11, C-M1, C-M2 (with finding 3), C-M3, C-M4, C-M5, C-M6, C-M9, C-M10, C-M11, I4 (with
  finding 2), I5, I6, I7, I8, and I14. The partial closes are C-M7 (finding 1), C-M8 (finding 4), and
  I2 and I3 (finding 11).
- **Totals agree.** G1 adds to 975 (10 + 215 + max(130, 175) + 80 + 155 + 120 + 130 + 90), G2 to
  1,005 (max(75, 170) + max(270, 60) + 270 + 105 + 115 + 75), and the chain to 1,980. 1,980 × 0.32 =
  634, and the ceiling is 1,270. The plan, the fold record, and the conductor prompt (item 1) carry
  the same numbers. Pre-flight item numbers 1 to 7 match every reference in the plan, the three
  prompts, and the standing answers. No pair's Files overlap: Pair A, T1.2 and T1.4; Pair B, T2.1
  and T2.2; Pair C, T2.3 and T2.4a.
- **Probes re-run and confirmed.**
  - The DTCG probe gives default `new Ajv()` throwing `unknown format "uri-reference"`; typed
    `clamp()`, typed `em`, and `"#fff"` INVALID; untyped strings and the oklch object valid.
  - The resolver sha256 is `a5acd143...b1da977`.
  - Mechanics `p2.mjs`: `Ajv2020` rejects the draft-07 resolver, and draft-07 rejects 2020-12. All 8
    house schemas are 2020-12.
  - The `.gitignore` probe: an anchored root entry ignores only the showcase copy.
  - The grant script round trip: the copy is identical to the shipped script apart from `PATH`. Add,
    idempotent re-add, and `--remove` give a byte-identical restore, and the original equals the
    live dotfiles settings.
  - The footnote probe: hrefs match after the post-sanitize step (see finding 7 for what it also
    shows). The repo's `buildSanitizeSchema` keeps `dataFootnoteRef` and `dataFootnoteBackref`; it
    drops only the `className` tuple (`sanitize-schema.ts:28-33`).
- **G-1 is rulable.** The `auth-data` reach is as stated. A grep of `#theme/(cairn.config|site-config)`
  importers hits no `hooks.server.ts`, preview, `wrangler.*`, or other `auth-data` glob beyond the
  two named lines. `config.missing` lands in `nav-routes.ts` and `content-routes-settings.ts`, and
  T2.1 touches the sanitizer, but none of these is an `auth-data` path (`cairn-running-passes`
  "Risk classes"). The gates, the merge command, and the `MERGE_LINE` text agree. The cited ruling
  exists (cairn-setup plan "Decide 11", `:244`, `:274`).

## Findings, ranked by consequence

### 1. major, correctness: T2.3 needs T2.4's files (fold-introduced, C-M7)

- Location: plan:500-502 and plan:513-514 (T2.3), plan:491 (Pair C), plan:530-546 (T2.4).
- Defect: T2.3's control page gains a "Run the check" action that runs `check.mjs`. Its smoke test
  fails unless the action's body validates against `schema/cairn-theme-check.schema.json`. Both
  files are T2.4 deliverables (T2.4 Files), and T2.4 runs after Pair C. T2.3 can't meet its own
  acceptance at its end, and its pair partner can't supply the files either. The pre-fold T2.3 had
  no check action (`050ffd9`, plan:377-398).
- Fold: move the action and its criterion to T2.4. The outcome gains "the viewer's control page
  gains a 'Run the check' action", Files gains `scripts/theme/viewer/**`, and the acceptance moves
  as written. Take about 20 minutes from T2.3 and add them to T2.4: Pair C becomes 250 and T2.4
  290, so G2 stays at 1,005 and the chain at 1,980. Only the two task lines change.

### 2. major, correctness: the doctor's new legacy path fails T1.1's and T1.6's greps (fold-introduced, I4 and M13)

- Location: plan:248-249 (T1.1 adds `src/theme/site.config.yaml` to `siteconfig.go:39-46`),
  plan:273 (the doctor test for that path), plan:277-282 (T1.1's grep), plan:423-425 (T1.6's grep).
- Defect: the fold's legacy entry and its test write the literal `src/theme/site.config.yaml` into
  `tool/internal/doctor/`. Both greps match `src/theme/(...|site\.config)` and exclude nothing under
  `tool/`, so each prints those lines, and neither acceptance can pass with correct edits. If the
  doctor test builds the path with `filepath.Join(..., "src", "theme", "site.config.yaml")`, T1.1's
  second grep (`'"theme", "site.config.yaml"' -- tool`) fails too. Two smaller gaps sit at the same
  spot:
  - `tool/internal/doctor/corpus_test.go:69` (a comment naming `src/theme/site.config.yaml`) hits
    T1.1's grep and is on no Files list.
  - `siteConfigPaths`' doc comment (`siteconfig.go:36-38`) says "four candidate paths" and "three
    legacy locations".
- Fold: both greps gain `':!tool/internal/doctor/siteconfig.go'` and the new doctor test's file.
  Say that the test writes the path as one string literal. T1.1's Files gain `corpus_test.go:69`
  and the doc comment's count.

### 3. major, correctness: the port's equivalence test conflicts with the token list and a judgment call (fold-introduced, M3 and C-M2)

- Location: plan:396-400 (the T1.5b equivalence test), plan:150 ("Required token names"),
  plan:537 (`tokens-required`), plan:551 (the scroll-cue break), plan:618-620 (judgment call).
- Defect: the T1.5b test fails unless every declaration in the generated `tokens/tokens.css` equals
  a declaration in `theme.css:104-273` at `origin/main`. Three conflicts and one gap follow.
  - The judgment call conflicts. It moves token-valued custom properties after line 273 into the
    tokens. `theme.css` declares color and size values there, such as `--cairn-cta-*`,
    `--cairn-shadow`, `--cairn-caption-tracking` (`:337-353`), and the dark `--color-card-border`
    (`:368`, `:384`). A moved property has no counterpart in 104-273, so the test fails.
  - The required token list conflicts. It adds `--cairn-eyebrow-case` and `--cairn-scroll-cue`, which
    today's `theme.css` doesn't declare. If `tokens-required` reads the theme's own declarations,
    Waymark fails it at T2.4 (plan:558) unless T1.5b adds both roles, and the equivalence test
    forbids adding them.
  - The other reading conflicts too. If `tokens-required` reads computed values, the chassis
    defaults from T1.3 always define both roles. The break "`--cairn-scroll-cue` missing under one
    option value" can then never fail, and the list contradicts its own exclusion of names "only the
    chassis sets".
  - The test runs one way only. A dropped declaration passes it, and only the baselines catch the
    loss.
- Fold: settle "defined" in the "Required token names" row. The recommendation is "declared by the
  theme's built sheets in each mode and option value". Then fix T1.5b's test in four steps:
  1. Make it run both ways over the moved set: every declaration in 104-273, plus each property the
     judgment call moves, appears in the generated output with the same value.
  2. Let the generated output add only those moved properties.
  3. Let it also add the two new roles, set to the chassis defaults (`uppercase` and the cue's on
     value).
  4. Have T1.5b's Waymark tokens declare both roles.

  The scroll-cue break then works under the declared reading.

### 4. major, correctness: the mode default sheet never meets an option sheet (C-M8 half-closed)

- Location: plan:158 ("Options in the viewer"), plan:145-146 ("Option sheets", "Color-mode
  default sheets"), plan:325-328 (the T1.4 cases). Design 260-261 (theme-options.css concatenates
  "the chosen `options/<key>/<value>.css` sheets and the color-mode default").
- Defect: C-M8 asked the viewer to concatenate the option sheets and the mode sheet, as setup does.
  The row the fold record cites concatenates only the option sheets and sets the mode by cookie. The
  combination setup will write is therefore never built.
  - The interaction is real. An option sheet targets three states: the light block, dark by explicit
    choice, and dark by system preference. A dark mode sheet pins dark in a fourth state, with no
    cookie under a light system.
  - In that state, the option's light-selector values apply over the pinned dark block. The
    visitor gets the light accent on a dark page.
  - T1.4 tests the option sheets and the mode sheets apart, never together, and contract v1
    freezes both shapes in G1.
- Fold:
  - "Option sheets" adds the pinned states: each value also writes its dark values under the
    selector the dark mode sheet pins, and its light values under the one the light sheet pins.
    Alternatively the mode sheet goes last in the concatenation and carries the option-specific
    values; the builder picks one and records it.
  - T1.4 gains a case: the fixture's second accent sheet concatenated with `modes/dark.css`, no
    cookie, and a light system reads the dark accent value.
  - "Options in the viewer" concatenates the mode sheet as design step 5 does, when a default mode
    is chosen.
  - The fold record changes M8 to "folded in part" until this lands.

### 5. major, correctness: no task brings the options fixture up to contract v1 (pre-existing, widened by the fold)

- Location: plan:316-317 (T1.4 creates `scripts/theme/fixtures/options-theme/`), plan:388-390
  (T1.5b writes contract v1), plan:510-516 (T2.3 renders the fixture headless and interactive),
  plan:547-558 (T2.4 breaks it).
- Defect: T1.4 builds the fixture as an accent option and a `site.css`, before the lay-in (T1.5a)
  and before contract v1 (T1.5b). The fold's G2 criteria then require it to be a complete theme that
  passes every rule but `render` unbroken. That means four components, `directives/renderers.ts`,
  `icons.ts`, `fonts/` with licenses, a manifest that validates, and screenshots, if they're
  required. It also has to render every conformance page. These are the SSR-throw and
  `console.error` breaks, the banner-rules break, and "the unbroken fixture passes". No G2 task
  lists the fixture's files, and no criterion checks the fixture against contract v1. The first
  T2.4 test to run finds out.
- Fold: T1.5b's Files gain `scripts/theme/fixtures/options-theme/**`, and its outcome gains "the
  fixture becomes a complete contract v1 theme (Waymark's components, icons, and one licensed woff2
  file, with the accent option)". T2.4's acceptance gains "the unbroken fixture passes every rule".
  Price it at about 30 minutes on T1.5b.

### 6. minor, correctness: Waymark's screenshots meet `paths-required` one task late (pre-existing)

- Location: plan:353 (T1.5a's manifest names "the three screenshot paths G2 fills"), plan:558
  (T2.4: `check:theme -- themes/waymark` passes), plan:561-563 (T2.5: "the check's
  `paths-required` covers them", with no file named).
- Defect: if `paths-required` reads the manifest's screenshot paths or a required `screenshots/`
  entry, Waymark fails T2.4's acceptance until T2.5 writes the PNGs. If it doesn't, T2.5 has to edit
  the contract file or `check.mjs`, and neither is in T2.5's Files.
- Fold: say that `paths-required` checks each manifest-named file from T2.4 on, and that T2.4's
  Waymark acceptance runs `--rules` without `paths-required`. T2.5 then runs the full check. Or
  move T2.5's screenshot capture ahead of T2.4's last criterion.

### 7. minor, correctness: the footnote fix gives a raw `id="fn-1"` the footnote's own id

- Location: plan:456-470 (T2.1), fold record I7.
- Defect: the probe's own output, re-run, shows two elements with the same id under the chosen
  mechanism. A raw `<p id="fn-1">` renders as `id="user-content-fn-1"`, and the footnote definition
  renders as the same `id="user-content-fn-1"`. So the footnote reference can jump to the author's
  element. The default renders that definition as `user-content-user-content-fn-1`, so today the two
  can't collide.
  - The fold record says the mechanism "keeps raw `id`/`name` prefixed". That's true, but it doesn't
    report this.
  - T2.1's acceptance checks only that the prefix holds, so it passes over the collision.
  - Impact is low. Only trusted editors can do this, the clash stays inside the `user-content-`
    namespace, and GitHub renders the same way.
- Fold: record it in T2.1 as an accepted residual, citing GitHub's identical output. Or add a
  criterion that a rendered document carries no duplicate `id`. No mechanism change is needed.

### 8. minor, correctness: the greps miss the `#theme/*` import specifiers

- Location: plan:277-282 and plan:423-425.
- Defect: both greps match `src/theme/(...)` and miss the moved import specifiers.
  `skills/cairn-building-admin-screens/references/admin-mount.md:22,42` and
  `skills/cairn-extending-a-site/references/tidy-and-ai-posture.md:96` teach
  `import ... from '#theme/cairn.config.js'`. These are packaged skills, and they ship to every
  site through `templates/waymark/.claude/skills/`. After G1 they'd be false, with nothing to catch
  them.
- Fold: both greps also match `'#theme/(cairn\.config|site-config)'`, excluding
  `src/tests/unit/check-chassis-boundary.test.ts:40` (a literal under test) and the history files
  the greps already exclude.

### 9. minor, correctness: T1.1 cites as new a red test that already exists

- Location: plan:269-270.
- Defect: `src/tests/unit/site-config-path.test.ts:24-30` already pins `DEFAULT_SITE_CONFIG_PATH`
  to the JSON. P6 T6.4 repoints it to `scripts/build/site-config-path.json`. It goes red only when
  the JSON changes first.
- Fold: cite it as the existing pin, with the JSON edit committed first as its red.

### 10. minor, correctness: the record names only one erratum, and plan:20 misstates the pass mapping

- Location: plan:20-21, plan:156 ("The port proof"), fold record "Owed erratum". Design 365-372.
- Defect: plan:20 says design steps 1 and 2 "are G1 and G2". In fact G1 carries step 2 (the port)
  and part of step 1, and G2 carries the rest of step 1. The port lands before the check and the
  viewer that design step 2 says prove it ("glance-indistinguishable in the viewer"). The Calls row
  records that substitution, so it isn't silent. But the record lists only the `tokens/tokens.css`
  split as an owed erratum, and a reader of the design alone wouldn't learn that the port's proof
  changed.
- Fold: rewrite plan:20 to the real mapping. Add the port-proof substitution to "Owed erratum", or
  make it a line in the conductor's design part. No other revision changes the design's meaning:
  - the `/styleguide`, check-home, `styled`, and options rows sit within "Left to the builder" or
    the design's own words;
  - `config.missing` follows the repo rule.

### 11. minor, correctness: two partial folds are recorded as "folded"

- Location: fold record I2 and I3. Plan:153 and plan:390-392.
- Defect:
  - I2's defect, the silent loss of an edit to the generated copy, is accepted, not closed. The
    stamp and `--force` are refused, with reasons.
  - I3's ask to read `themes/waymark/` directly, and its criterion "after a `themes/waymark/theme.css`
    edit with no lay-in, `check:invisible-craft` sees the edit", aren't taken. A standalone `npm run
    check:invisible-craft` or `check:public-skill` in a worktree still reads a stale copy. Only the
    fast lane lays in first.

  Both refusals are defensible, but the record reads as a full close.
- Fold: change both dispositions to "folded in part, refused in part", with the refused half's
  one-line reason. Optionally add the lay-in to those two scripts' npm entries as `pre` scripts,
  which costs one line each.

### 12. minor, optional: the fold folded optional findings

- Location: fold record M19, M21, m8, m9, o1, I16, I18, and I19.
- Defect: the skill says "The fold ... drops every `optional` finding." These folds are cheap, but
  two add surface the reviews didn't need to block on: the check's `--rules` flag, and the grant
  script's `--remove`. Both are harmless, and the grant behavior is proven by the re-run probe.
- Fold: none needed. Note the departure in the record ("optional, taken as free").

### 13. minor, optional: CI runtime is priced on part of what runs

- Location: fold record "The CI home, decided" and plan:161.
- Defect: the price counts the catalog render and the `render` rule's three tests. `npm run
  test:theme` runs in the same `test` job and also covers the viewer's tests: two accent builds, an
  interactive `vite dev` smoke, and the all-pages Waymark headless run. The standing answer at
  plan:607 absorbs an overrun.
- Fold: one sentence in the record naming the viewer tests in the estimate.

## Owner forks

None open. The fold took I8 as (a). The skill allows that for a question with one clearly correct
answer, and Geoff's "sites rebuild, not migrate" ruling plus the disclosure lines support it.
Because the answer is a hard break for any pinned consumer site, the conductor's packet item 2
should carry it as a visible routine row ("Sites on the old layout: hard break, disclosed").

## Decide G-1

Rulable on the evidence given. It states what it is, the prior ruling it extends, the `auth-data`
reach (verified), each merge gate, the exact merge command, what a no builds, and its dependency.
The grant script's `MERGE_LINE` restates the same gates and branches, word for word in substance.
