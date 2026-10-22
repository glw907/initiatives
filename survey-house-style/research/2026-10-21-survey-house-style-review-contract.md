# Survey house style spec: contract and criteria review

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `044b527` (branch `survey-house-style`). Lens: is every promise testable, does each criterion name its fixture and its failure reason, and can any criterion pass vacuously. Line numbers refer to the spec at that commit.

Evidence read: the spec; the 2026-10-07 Survey spec (Verification, lines 153-169); the vendored core `approval-queue/src/lib/survey/` plus `src/app.css` and `src/lib/components/frame/frame.css`; the approved specimen; `~/.claude/docs/claude-tooling.md`; the agent definitions in `~/.dotfiles/claude/.claude/agents/`; `vale-hook`; the PostToolUse block in the tracked `settings.json`.

Summary: 4 blockers, 9 majors, 9 minors. One owner fork (F15).

## Blockers

### F1. The `survey` skill never reaches the implementer subagents. Blocker, correctness

Location: spec:89, spec:13, spec:33.

Defect: the spec says that user scope "reaches implementer and reviewer subagents as well as the main loop." It does not. `site-implementer.md:4` and `cairn-implementer.md:4` declare `tools: Read, Write, Edit, Bash, Grep, Glob`. That list has no Skill tool, and neither file has a `skills:` preload, so neither agent can load a user-scope skill. The same holds for `visual-verifier` and `daisyui-a11y-reviewer`, which is why they need their one-line edits (spec:90). The agents that write the UI get no Survey context, and no criterion would catch it. The intent "an agent in any of these contexts should apply Survey correctly without being briefed" (spec:32) fails for the agents that do most UI work.

Fold: add `site-implementer` and `cairn-implementer` to the agent edits, with the same one line as the reviewers (read the installed `node_modules/@glw907/survey/DESIGN.md` when the repo depends on Survey), or preload the skill through `skills:` frontmatter. Add this criterion: a headless dispatch of `site-implementer` in a fixture repo that depends on Survey reads the installed DESIGN.md before its first CSS edit. It fails if the transcript shows no such Read.

### F2. `survey-check` has no fixtures, and its scope lets the main literal channel pass vacuously. Blocker, correctness

Location: spec:78, spec:88.

Defect: the check "flags a color, radius, shadow, or duration literal that no token holds." Three gaps follow from that wording.

1. **Literals that match a token pass.** A hard-coded value that equals a token's value is never flagged, for example `#f4efe6` typed in place of `var(--paper)`. That copy is exactly the drift the anti-goals name (spec:53-54). It goes stale silently at the next value change, which the policy classes as minor and which `dependency-upgrade` takes by default.
2. **Utility classes are out of scope.** The default recipe is daisyUI with Tailwind (spec:65), and that stack carries literals in class names: `bg-[#fff]`, `rounded-[3px]`, `shadow-lg`, `duration-300`. A scanner of CSS declarations passes every one of them, so the check is green on the stack it targets most.
3. **The exemptions are undefined.** The real core needs exemptions, but the spec defines none. `frame.css:9` defines `--bar-shadow` from `rgb()` literals. `frame.css:295` uses `#000` inside a mask gradient. `app.css:71` sets `transition: none !important` under reduced motion. `transparent`, `currentColor`, `0`, `none`, and `inherit` appear throughout. Without a defined exemption set, the check is either noisy enough that agents learn to ignore it or loose enough to pass anything.

Fold: give `survey-check` its own acceptance with named fixtures in the package's test suite:

- **Positive.** A `.css`, a `.svelte` `<style>` block, an inline `style=""`, and a Tailwind arbitrary-value class, each carrying an off-token literal. Each must exit non-zero with `file:line`, the literal, and a named token.
- **Matched literal.** A literal equal to a token value is flagged, with a message naming that exact token.
- **Negative.** Token use, the exempt keywords, the package's own token sheets, and `prefers-reduced-motion` resets all pass.
- **Message shape.** The message names the token, or says "no token fits; see DESIGN.md §X" when none is near. It is never empty.

State the nearest-token rule for an off-token literal (nearest by role, or by ΔE within one role family) so that "names the token to use" is testable.

### F3. Contrast thresholds from the 2026-10-07 spec were dropped. Blocker, correctness

Location: spec:108, spec:65.

Defect: the end-to-end check says only that `theme-contrast` "passes in both schemes." The prior spec's acceptance (lines 155-160) named WCAG AA at 4.5:1 for every measured pair, 3:1 for the focus ring, both sRGB and display-p3, and the audit config whose `public.stylesheets` imports Tailwind, `cairn-public.css`, and the core. Without the config, "passes" can mean the audit measured nothing, for example a config that does not import the package's outputs. The focus ring is a token in rung two (spec:58) and loses its 3:1 bar.

Fold: restate the thresholds and the color spaces, name the audit config file in the repo, and add a non-vacuity guard: the audit report must list at least N measured pairs, including `focus-ring` against both `paper` values. It fails on zero pairs or on a missing pair.

### F4. No release-artifact check, so the version-matched-docs promise is untested. Blocker, correctness

Location: spec:75, spec:102, spec:108.

Defect: the spec's main agent promise is that the npm tarball ships DESIGN.md and the token JSON at the installed version. Nothing checks it. The end-to-end check runs from a clean clone of the repo, not from an installed package. A `files` field that omits DESIGN.md or the `bin` entry for `survey-check` would pass every stated criterion and ship broken.

Fold: add two criteria.

- **Pack check, in the gate.** `npm pack --dry-run --json` lists `DESIGN.md`, the token JSON, the three outputs, the shared CSS, and the `survey-check` bin. It fails on any missing path.
- **Post-publish check, in Pass B's close.** In a scratch directory, `npm i @glw907/survey@1.0.0`, then read `node_modules/@glw907/survey/DESIGN.md`, run `npx survey-check` against the F2 positive fixture (it must exit non-zero), and confirm `npm view` shows provenance from trusted publishing.

## Majors

### F5. The default recipe, the one-line daisyUI import, has no consumer fixture. Major, correctness

Location: spec:65, spec:108.

Defect: the spec says the daisyUI theme imports "in one line after activating the plugin" into any daisyUI project. Only the specimen is tested, and the specimen is Survey's own harness. If the specimen carries its own CSS or inline values, the visual grade passes without proving the package outputs work. The plain-HTML criterion has the same hole.

Fold: add a fixture app under `fixtures/daisyui-consumer/`: a minimal SvelteKit + Tailwind 4 + daisyUI 5 app whose only Survey input is the one-line import. It builds, and a computed-style probe reads `--color-base-100`, `--radius-box`, and the font family in both `data-theme` values against the token source. Run `survey-check` on the specimen's own source as proof that it consumes only package outputs.

### F6. The plain-HTML criterion has no grader and does not test Bulwark's actual constraint. Major, correctness

Location: spec:108, spec:58, spec:68.

Defect: "shows the palette, shape, and fallback type in both schemes" names no fixture path, no observer, and no failure condition. The reason this page exists is that Bulwark's theme filter strips `url()` (spec:58), but nothing asserts that the CSS-variable sheet is free of `url()`.

Fold: name the page (`fixtures/token-only.html`) and assert three things.

- The built sheet contains zero `url(` and zero `@import`. A grep in the gate fails on any match.
- A computed-style probe in both schemes matches the token source for rungs one to three.
- The resolved font family is the named system stack when the web fonts are absent.

Drop "shows" in favor of those measured values.

### F7. The versioning policy is prose with nothing enforcing it. Major, correctness

Location: spec:67, spec:79.

Defect: the spec makes three rules ("renaming or removing is major," "ships first as a deprecated alias in a minor," "an alias stays until the next major"), and nothing checks any of them. Changesets lets the author pick the bump. A rename tagged minor would reach every app by default through `dependency-upgrade` (spec:68) and break each one.

Fold: add a gate script that diffs the built token JSON against the last published version's JSON (`npm view` or the git tag). It fails when:

- a token is removed or renamed without an existing deprecated alias, unless the pending changeset is major;
- a `$type` changes in a non-major;
- an alias added in an earlier minor is removed outside a major.

Use DTCG's `$deprecated` for aliases, and have `survey-check` warn on a deprecated token with its replacement named. That warning makes the "upgrades an agent can do" promise executable.

### F8. New `survey-check` rules can break consumer gates on a minor bump. Major, correctness

Location: spec:67, spec:78.

Defect: the policy covers tokens (after Spectrum) but says nothing about the checker. A minor release that adds a rule, or widens the scan to `.svelte` class names, turns consumer gates red on a bump that `dependency-upgrade` takes without asking.

Fold: adopt ESLint's semver policy for the linter. A change that can make previously passing code fail is major, or it ships as a warning in a minor and is promoted to an error in the next major. Add this to the versioning bullet.

### F9. Changelog entries are required to name a rung and an action, with no enforcement or vocabulary. Major, correctness

Location: spec:67, spec:79.

Defect: "Each entry names its rung and the consumer's action, if any." Changesets does not validate free text, so the requirement passes vacuously on an entry like "Tweak colors." The rung field also has no value for changes that are not on a rung, such as checker, build, or docs changes.

Fold: add a lint over `.changeset/*.md`. It requires a `Rung:` value from `palette | shape | type | motion | signature | tooling`, and an `Action:` line that is either `none` or names concrete tokens and selectors, matching the pattern "replace `X` with `Y`". It fails in CI when either is missing.

### F10. Pass A's sitting has no inventory, so "every difference" cannot be checked. Major, correctness

Location: spec:96, spec:18.

Defect: the spec says that "each difference reaches Geoff" and that "Geoff sees every addition before 1.0.0." Completeness needs a closed list to compare against, and the spec names none. A difference that Pass A missed simply never appears, and the sitting still looks complete. The sort list ("focus ring, fields, key hints, toast, float shadow, frame, scrollbars, motion tokens") is open-ended ("includes").

Fold: Pass A's first output is a harvest ledger at `survey-house-style/research/`. It holds one row per rule or token across the three sources, with columns for source locations, rung, disposition (agreement, difference, promote, app-only), and ruling id. The acceptance has two parts: every selector and custom property in the three named approval-queue files and the specimen maps to a row (a script counts them), and every row marked difference or promote has a ruling id after the sitting.

### F11. Rulings are not traced into Pass B. Major, correctness

Location: spec:19, spec:98, spec:108.

Defect: Pass B "builds from your rulings," and the visual-verifier grades against "the approved specimen as amended by the rulings." The only artifact Pass A hands over is the amended specimen. If a ruling changes a value or rule the specimen does not render, such as a scrollbar, motion, or a field state, the visual grade cannot catch its omission.

Fold: Pass B's acceptance includes a trace: each ruling id in the F10 ledger maps to a token path, a DESIGN.md rule, or an explicit "app-only, not shipped" note. Name the amended specimen's exact path in the end-to-end check (spec:108), so the reference cannot be an older file.

### F12. The `dea9839` probe has no outcome branch. Major, correctness

Location: spec:98.

Defect: Pass A "starts by looking for" `dea9839` on thinkpad-x1, and the spec does not say what happens if the commit is found, found and different, or not found. "A copy there would be a fourth version" leaves open whether a found copy joins the harvest or gets discarded. Reaching thinkpad-x1 from pavilion also means ssh, which the recent auto-mode commit (`473ae89`) records as unreliable.

Fold: state the outcomes. If the commit is found, it joins the harvest as a fourth source with its own column. If it is absent, record that and continue with three. If the host is unreachable, stop and ask, which counts as a pre-flight item, not a mid-run question. Add "thinkpad-x1 reachable" to the pre-flight list.

### F13. The hook's contract is unspecified: trigger, binary, and output. Major, correctness

Location: spec:88.

Defect: "a repo that depends on Survey" has no detection rule. Bulwark's servers repo pins a built bundle (spec:68) rather than an npm dependency, and 907.life takes Survey through cairn. The spec also leaves open which `survey-check` binary runs. Only the consumer's `node_modules/.bin` copy matches the installed version, and a global copy would break the version-match promise. There is no fixture either, so "never blocks" and "findings come back as context" are untested.

Fold: specify these points.

- Detection is `@glw907/survey` in the nearest `package.json`, or a `.survey-version` file for bundle consumers.
- The hook runs the repo-local binary. When that binary is absent, it says nothing and exits 0.
- Output goes through `additionalContext` with exit 0, the `vale-hook` mechanism, under its 9000-character cap.

Add hook tests:

- An edit with an off-token literal in a dependent fixture emits context naming the token.
- The same edit in a non-dependent fixture emits nothing.
- A `.md` edit emits nothing.
- A crash in the checker still exits 0.
- The run finishes inside the timeout.

### F14. Bulwark's pinned bundle is invisible to `dependency-upgrade`. Major, correctness

Location: spec:68.

Defect: the spec says "the same skill bumps it," but the skill finds work by reading package manifests. A bundle built at a pinned version and committed to the servers repo appears in no manifest the skill reads, so "are we current" reports Bulwark as current forever.

Fold: record the pin in a machine-readable file in the servers repo (`.survey-version`, or a `package.json` dev dependency used only for the build script). Add one line to the `dependency-upgrade` skill's inventory that names it. Add a criterion for Bulwark's own pass: a staged bump to a fake newer version shows up in the skill's sweep.

## Owner fork

### F15. Pass A's per-difference render ceremony is sized to an unknown count. Major, optional. OWNER FORK

Location: spec:18, spec:96, spec:112.

Defect: every difference gets its own side-by-side render in one sitting. Three sources that "each may change a little" (spec:34) can differ on dozens of values, many of them below what anyone can see (a 1-2% lightness shift, a 0.05rem radius). Rendering each one costs builder clock (the 180-minute estimate likely does not cover 40 renders) and Geoff's attention, and it buries the rulings that matter. A "two renders" format (spec:96) also cannot show a three-way difference.

Options:

- (a) Keep a render for every difference, as written.
- (b) Render only differences above a perceptual threshold (for example ΔE2000 ≥ 2 for color, ≥ 2px for length, ≥ 50ms for duration), and put the rest in one routine table with a default "take the principle-consistent value." Geoff can pull any row into a render.
- (c) Group differences by rung and render one composite per rung.

Recommendation: (b). It keeps "Geoff sees every addition," since every promoted rule still gets a render, and it bounds the sitting. The threshold is a taste call, so it is Geoff's to make.

## Minors

### F16. Risk classes contradict each other. Minor, correctness

Location: spec:112.

Defect: "Both passes are `ordinary`. Pass B is `live-account`."

Fold: "Pass A is `ordinary`; Pass B is `live-account`."

### F17. The claim that DESIGN.md `lint` passes "in both schemes" may be vacuous. Minor, correctness

Location: spec:65, spec:108.

Defect: the Google Labs format keeps tokens in a single front-matter block. Whether `lint` evaluates a dark set at all is unverified. If it does not, "passes in both schemes" passes on light alone. `theme-contrast` and the DESIGN.md WCAG rule also overlap, and the spec does not say which one rules on a disagreement.

Fold: make Pass B's first task a probe that confirms how `lint` sees dark tokens, and if it does not, scope the lint claim to light. Name `theme-contrast` as the contrast check of record.

### F18. Agent-friendly promises lack mechanical checks that cost little. Minor, correctness

Location: spec:76-77, spec:80.

Defect: three promises are checkable but have no criterion.

- "Each token carries a `$description`."
- "One imperative sentence ... paired with its Do's and Don'ts entry."
- AGENTS.md carries runnable "build, gate, and release commands."

Fold: three gate assertions.

- The build fails on a token without `$description`.
- A script checks that each principle has a matching Do/Don't entry.
- The commands in AGENTS.md run from a clean clone; the release command runs as `--dry-run`.

### F19. "Role-named, never raw value" has no check. Minor, optional

Location: spec:76.

Fold: the build rejects token names that match `#[0-9a-f]|^\d|px$`. The goals also call for tagging each token with its rung (`$extensions.survey.rung`), so that the Bulwark build and the F9 lint can take rungs one to three mechanically.

### F20. The skill's trigger promise is untested. Minor, correctness

Location: spec:89.

Defect: "Its description triggers on UI work in a house tool" has no eval.

Fold: run three should-trigger prompts (a daisyUI component edit in the phonebook, a theme tweak in the approval queue, a Bulwark CSS change) and two should-not prompts (Go CLI work, a docs edit) in fresh headless sessions, the skill-creator trigger method. The check fails on any miss.

### F21. The agent edits have no detection rule or check. Minor, correctness

Location: spec:90.

Defect: "In a repo that depends on Survey" needs the same detection rule as F13. "Grade against its rules" is a new mode for `visual-verifier`, which today grades against reference images.

Fold: reuse F13's rule. State that the rule grading is additive to the image grade, and that a rule failure is reported as STRUCTURAL.

### F22. The manifests bullet is partly inaccurate and partly ceremony. Minor, optional

Location: spec:92.

Defect: per `claude-tooling.md:12`, an authored skill's manifest is its own directory, and hooks live in the tracked `settings.json`. Neither has a separate "manifest entry." "Commits cite the Anthropic pages" costs effort and gates nothing.

Fold: replace the bullet with "the skill directory and the `settings.json` hook entry land together; `claude-tooling-sync verify` exits 0," and drop the citation requirement. That saves a few minutes and some tokens per commit.

### F23. The dependency on PR #131 has no fallback. Minor, optional

Location: spec:69, spec:91, spec:102.

Defect: the skill lands "after PR #131 merges," and the spec does not say what happens if #131 is still open at Pass B's close.

Fold: state that the skill PR carries the CLAUDE.md line itself if #131 has not merged by then.

### F24. A 1.0.0 with no release candidate fixes token names before any consumer has tried them. Minor, optional

Location: spec:19-20, spec:96.

Defect: the approval queue's convergence is the first real consumer, and it runs after 1.0.0. A naming flaw it finds then costs a major release.

Fold: publish `1.0.0-rc.N` first and let the approval-queue pass take the release candidate before the final cut. Because this changes release sequencing, it can be raised with Geoff as a one-line question if he prefers.
