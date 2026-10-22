# Survey house style: design

## Brief

This makes Survey the one written house style for every house tool, published as a versioned npm package that each app follows through ordinary dependency updates.

Survey now exists in three places that have drifted apart: the approval queue's vendored copy, the 2026-10-07 spec, and its approved specimen. Bulwark webmail and the phonebook's UI both wait on it, and 907.life will take it in its rebuild.

### What changes

- A new public `survey` repo holds Survey's tokens, principles, shared CSS, specimen, and changelog, and publishes them to npm.
- One token source builds a drop-in daisyUI theme, a plain CSS-variable sheet, and a DESIGN.md that agents read first.
- A conformance check ships in the package and names the token to use in place of any stray value.
- A skill, an advisory hook, and four agent-definition lines point every agent at the Survey version its repo installed.
- Each app moves to the package later, in its own pass.

### If you approve

1. You do two pre-flight steps: check thinkpad-x1 for unpushed Survey work, and reserve the npm name with a placeholder.
2. Pass A compares the three versions and brings you the differences and proposed additions in one sitting.
3. Pass B builds the repo from your rulings. At its close you read the built specimen, link the trusted publisher on npmjs.com, and approve the merge. The release workflow then publishes.
4. Pass C adds the skill, the hook, and the agent lines to the workstation, and you approve its merge.
5. The approval queue, the phonebook, Bulwark, and 907.life each take the package in a pass of their own.

### Decide: release 1.0.0 directly, or a release candidate first

1.0.0 fixes the token names, and renaming one later costs a major release in every app. No app will have used the names before the cut. A candidate lets the approval queue try them first. Bulwark then waits one more pass.

Source: contract review F24, mechanics review 13, integrity review 2

- A candidate first: Pass B publishes `1.0.0-rc.1` under the `next` tag, the approval queue converges on that exact version, and a short release step at that pass's close promotes 1.0.0 with any names it changed. The other apps start from 1.0.0. (recommended)
- 1.0.0 directly: Pass B publishes 1.0.0 and every app can start then. A naming flaw the approval queue finds costs a major.

### Decide: what the trusted publisher may do

Since 2026-09-03, npm sets a new trusted publisher to staged publishing by default. CI uploads a version, and it goes live only when you approve it with 2FA. cairn's older link allows a direct publish.

Source: mechanics review 14; npm trusted publishers docs

- Direct publish: a GitHub release publishes hands-off, the way cairn's does, as your ruling names. (recommended)
- Staged only: `publish.yml` runs `npm stage publish` in place of cairn's `npm publish`. Each release, the first included, waits for your 2FA approval on npmjs.com or the CLI, and its post-publish check runs only after you approve.

### Decide: whether a visible Survey update needs a render read

A value change is a minor release, and the dependency sweep takes minors without asking. With no visual baselines in the approval queue, a palette change could reach it unseen. 907.life already needs a render read before any production deploy.

Source: integrity review 4

- Every minor or major bump of Survey in an app needs a full-page render in both schemes, read in the main loop, before merge. Pass C adds that line to `dependency-upgrade`. (recommended)
- Any visible value change is a major, and you approve each one. Majors stop meaning a breaking change.
- No added read. Apps follow minors unseen, except where a repo rule already requires one.

### Decide: how many renders Pass A's sitting carries

The three versions may differ on dozens of values, many too small to see. Each render costs build time and your attention.

Source: contract review F15, mechanics review 23

- Render what you can see: a difference at or above ΔE2000 2 for color, 2px for length, or 50ms for duration gets a side-by-side render. The rest sit in one table with a default, and you can pull any row into a render. Every proposed promotion is rendered. Pass A is estimated on this option. (recommended)
- Render every difference. Pass A's estimate then grows with a count nobody knows yet.
- One composite per rung: five renders, quickest to read, though small differences hide inside them.

### Worth knowing

The work grows from two passes and 600 path minutes to three passes and 830. The reviews found that the release, the conformance check, and the workstation tooling each needed their own acceptance. The phonebook has no UI yet and adopts Survey fresh. cairn-themes keeps its theme ports and gives up `survey-theme/`, its Survey spec, and its backlog items #1 and #2 to the new repo.

### Rulings

These rulings stand and are not reopened. Survey is published from a public repo to npm as `@glw907/survey`, with trusted publishing, the way cairn is. Bulwark's theme waits until this work is complete. Survey is agent-friendly from the ground up, joins the workstation's Claude tooling, is versioned with a changelog, follows established practice, and includes a drop-in daisyUI theme (Geoff, 2026-10-21).

### Intent

Every house tool should read as one family. Where we hold every lever (the approval queue, the phonebook, 907.life's cairn layer), the tool should also carry Survey's felt craft. Where an app exposes only a few levers, such as Bulwark, it should still be recognizably Survey. An agent working in any of these contexts should apply Survey correctly without being briefed. Each app should be able to follow Survey as it improves, through a version bump and a changelog that says what to do.

None of the three existing versions is the reference. Each looks good, and each may change a little to match the principles this work writes down (Geoff, 2026-10-21).

### Goals

The work has four goals.

- One written house style: principles, tokens in light and dark, and per-context recipes.
- A ladder of levers ranked by how much resemblance each carries, so a partial adopter knows what to take first.
- Releases under Semantic Versioning, each with a changelog entry that names the consumer's action.
- Agent-friendly from the ground up: version-matched docs, role-named tokens, a conformance check with fix-naming messages, and upgrade steps an agent can carry out.

### Non-goals

Four things stay out of scope.

- Restyling the cairn admin. It keeps its own design system.
- Packaging Survey as a selectable cairn theme (cairn-themes S3, cairn's work).
- The terrain hero from elevation data.
- Building any app's convergence inside Passes A to C.

### Anti-goals

Three outcomes would mean the work failed.

- A style that only works where every lever exists, which leaves Bulwark-class apps generic.
- Copies that drift, where an app can't tell which Survey it has or what changed since.
- Rules an agent has to infer from CSS, or values it is free to invent.

### The lever ladder

An app adopts from the top down, as far as its theming surface allows. Palette carries the most resemblance and is the first rung: paper, ink, and water in light and dark, with the status colors. Shape comes next, meaning radii, 1px borders, no shadows, and the focus ring. Type is the third rung: Spectral, Karla, and Monaspace Neon, with a named system-font stack for apps that can't load web fonts. Motion is the fourth, and the signature details are the fifth (contour texture and rules, benchmark triangle, margin collar, index rail, the frame). Full-lever apps take all five rungs. Bulwark takes rungs one to three, because its theme filter strips `url()`.

### Token source and outputs

One DTCG 2025.10 file is the source, and Style Dictionary builds the three outputs from it. Style Dictionary 5.7.0 read DTCG 2025.10 colors, dimensions, durations, shadows, and cubic Béziers in the mechanics probe, though its docs say 2025.10 "does not have full support yet". The probe also showed it silently drops a group that uses `$extends` and ignores `$deprecated`.

- **Source.** A base group plus `light` and `dark` groups, filtered per platform. `$extends` is not used. Style Dictionary is pinned to an exact version. Each token is named for its role (`paper`, `ink`, `water`, `focus-ring`), never a raw value, and the build fails on a token without a `$description`. The focus ring aliases the primary color in 1.0.0, the role `theme-contrast` measures at 3:1.
- **daisyUI theme.** Light and dark `@plugin "daisyui/theme"` blocks and the `@theme` scale, imported in one line after `@plugin "daisyui" { themes: false; }`. The mechanics probe compiled this from a packed tarball under Tailwind 4.3.3 and daisyUI 5.7.50. The output keeps the names `theme-contrast` reads: `--color-muted`, `--cairn-{info,success,warning,error}-ink`, and `--color-primary` as the focus ring. It carries no `--cairn-code-*` roles, as the vendored core never did. It is the default recipe for a new house tool, since Geoff builds most tools on daisyUI.
- **CSS-variable sheet.** Light values in `:root`, dark under `@media (prefers-color-scheme: dark)` and under the dark `data-theme` value. It holds no `url(` and no `@import`, and a header comment names the package version.
- **DESIGN.md.** Google Labs' format: tokens in front matter, principles in prose, ending in "Do's and Don'ts". `@google/design.md` 0.4.0 is alpha and has no dark-scheme concept, and its contrast rule only warns (a 1.08:1 pair exited 0 in the probe). So the front matter holds the light set and a `components` list of the real pairs, the dark set lives in prose, the CLI is pinned exactly, and the gate fails on any `lint` error. `lint` checks structure only.
- **Shared CSS.** The component overrides and signature details stay hand-written under the existing `site-*` and `--site-*` prefixes, each with its component and reason beside it (the DaisyUI-first rule).
- **Package shape.** `daisyui ^5` and `tailwindcss ^4` are peer dependencies, and the Fontsource fonts are dependencies. `exports` names each CSS file, DESIGN.md, and the token JSON. `bin` names `survey-check`. `files` leaves out `reference/`.

### Contrast

`npx cairn-audit --rule theme-contrast --fail-on advisory` is the contrast check of record. Its public-scope findings are advisory, and only `--fail-on advisory` makes them exit 1 (`cairn-cms/src/lib/audit/bin.ts:5-7`). A committed `cairn-audit.config.json` imports Tailwind, `cairn-public.css`, and the built daisyUI output, with `@glw907/cairn-cms` as a dev dependency, as the 2026-10-07 spec set up. Every measured pair meets WCAG AA at 4.5:1 and the focus ring meets 3:1, in both schemes and in sRGB and display-p3. To show the audit measures something, a planted low-contrast value in a scratch copy must make it exit 1.

### The conformance check

The package ships `survey-check` for an app's gate to run. Its messages name the fix, following the self-healing error pattern in the Chrome DevTools MCP design principles.

- **Surfaces.** `.css` files, Svelte `<style>` blocks, inline `style=""`, Tailwind arbitrary values such as `bg-[#fff]`, and the stock utilities that set a shadow or a duration.
- **Literals.** It flags every color, radius, shadow, and duration literal outside the package's own sheets, including one equal to a token's value. The message gives `file:line`, the literal, and the matching token. When none matches, it names the nearest token of the same type (ΔE2000 for color, absolute difference otherwise), or says "no token fits" and names the DESIGN.md section.
- **Names.** A deprecated Survey token is a warning that names its replacement, read from `$deprecated` in the shipped token source. An unknown name under Survey's token prefix or `--site-*` is an error. The `--site-*` set is read from the shipped shared CSS.
- **Exemptions.** `transparent`, `currentColor`, `inherit`, `0`, `none`, and declarations inside a `prefers-reduced-motion` block pass. A `survey-check-ignore -- <reason>` comment on the line before covers the rest, modelled on stylelint's disable comments and their reason after two hyphens. The approval queue's `frame.css` mask gradient (line 295) and bar shadow (line 9) are the cases that need it.
- **Fixtures.** The package's tests hold one flagged literal per category on each surface, a literal equal to a token value, a deprecated alias, an unknown name, an ignore comment, and a clean file. Each flagged fixture exits non-zero with the message shape above, and the clean file exits 0.
- **On a cairn site.** cairn-audit's literal rules stay the gate of record. 907.life's `engine-consult` decides whether `survey-check` also runs there.

### Agent-friendly by construction

Agents are Survey's main users, so every part of it is built to be read and checked by one (Geoff, 2026-10-21).

- **The docs travel with the version.** The npm package ships DESIGN.md and the token JSON. An agent reads `node_modules/@glw907/survey/DESIGN.md` for the exact version installed. In a fresh worktree it runs `npm ci` first and never falls back to the GitHub copy.
- **Rules are short and checkable.** Each principle in DESIGN.md is one imperative sentence that a check or a reviewer can test, paired with its "Do's and Don'ts" entry.
- **Upgrades an agent can do.** Each changelog entry names the consumer's action as a concrete step, such as "replace `--survey-shade` with `--survey-paper-2`". A deprecated token stays as an alias until the next major.
- **A map for working on Survey itself.** The repo carries an `AGENTS.md` (the open agents.md format) with its build, gate, and release commands, beside DESIGN.md at the root.

An MCP server is left out. The skill and the shipped files carry the same content without a running service.

### Versioning and release

Survey follows Semantic Versioning 2.0.0, with Adobe Spectrum's token policy and ESLint's linter policy. Renaming or removing a token, or changing its type, is major, and it ships first as a deprecated alias in a minor. A new token, rule, or intentional value change is minor, and a fix with no visible change is a patch. For `survey-check`, ESLint's README is the model: a bug fix that reports more errors is minor, while an addition to the default rule set that may report new errors is major. A stricter check can also ship as a warning in a minor and become an error at the next major.

- **Changelog.** A hand-kept `CHANGELOG.md` in Keep a Changelog 1.1.0, with a `## [Unreleased]` section. Each entry names its rung (palette, shape, type, motion, signature, or tooling) and the consumer's action, or "none". Changesets is not used: version 3.0.3 hard-codes headings that are not Keep a Changelog's, and its version PR adds a manual step per release.
- **Workflow.** `publish.yml` is copied from cairn's. It runs on a published GitHub release or a manual dispatch, never on a push. No merge can publish. It pins npm 11 (npm 12.0.0 shipped without sigstore), passes `--provenance`, derives the dist-tag from the version (`next` for a prerelease), and skips a version already published. `repository.url` matches the repo exactly, and the job runs Node 22.14 or later, as trusted publishing requires.
- **First publish.** npm cannot bind a trusted publisher to a package that does not exist. cairn's first publish was by hand for that reason (`cairn-cms/.github/workflows/publish.yml:92`). So Geoff publishes a `0.0.0` placeholder at pre-flight and deprecates it at once. A release candidate goes to `next`, so `latest` stays on the placeholder until the first stable version, and the deprecation warns anyone who installs it bare. A new trusted-publisher link "must complete its first successful publish within 2 days". He makes the link in Pass B's close sitting, and the release runs the same day.
- **Rollback.** A bad version is deprecated and superseded by a patch, never unpublished. `AGENTS.md` says so in its release section.

### Pass A: harvest and rulings

Pass A turns the three versions into one ledger of rulings and an amended specimen. It reads, at commits it records, the approval queue's four `src/lib/survey/` files, `src/app.css`, and `src/lib/components/frame/frame.css`, plus the 2026-10-07 spec and the approved specimen. If the thinkpad-x1 pre-flight step found Survey work, its archive branch joins as a fourth source. Pass A only reads the approval queue.

- **Ledger.** `initiatives/survey-house-style/research/<date>-harvest-ledger.md` holds one row per token or rule, with its source locations, rung, disposition (agreement, difference, forced, promote, or app-only), and ruling id. A grep count of the custom properties and rule selectors in the named files must equal the ledger's mapped count. The agreements become the draft principles.
- **Forced differences.** A difference that a rule settles, such as a value that fails contrast, is Claude's call. The sitting lists it without a render.
- **The sitting.** The remaining differences and every approval-queue rule Claude proposes to promote reach Geoff in one sitting in Chromium, rendered as the brief's render decision sets. Each render shows one panel per source that differs, with a recommendation. Geoff sees every addition before 1.0.0 fixes the token names. After the sitting, every difference and promote row carries a ruling id.
- **Specimen.** Pass A ends by writing `initiatives/survey-house-style/reference/<date>-amended-specimen.html`, committed and pushed with the ledger. Pass B cites both by commit and grades against that file.

### Pass B: the repo and the release

Pass B creates the public `glw907/survey` repo and publishes the package from Pass A's rulings.

- **Provenance.** The repo starts from a fresh copy, without history, of the two `survey-theme/reference/` files, the 2026-10-07 spec, and its review (`docs/research/2026-10-07-survey-spec-review.md`). Its first commit names the cairn-themes commit they came from. The core CSS starts from the approval queue's vendored copy at the commit Pass A recorded, since cairn-themes never committed a core. Each header there says it was copied from `dea9839` and must not be edited.
- **Build.** The token source and three outputs, the shared CSS, the living specimen, `survey-check` and its fixtures, the two fixtures below, `AGENTS.md`, `CHANGELOG.md`, and `publish.yml`.
- **Trace.** Each ruling id in Pass A's ledger maps to a token path, a DESIGN.md rule, or an "app-only, not shipped" note.
- **Leaving cairn-themes.** Only after the new repo is pushed, one cairn-themes commit removes `survey-theme/`, the Survey spec and its review, and backlog items #1 and #2, and rewrites every live pointer the fold record lists. Afterwards, `grep -rni survey` there returns only theme-port mentions. Dated records elsewhere stay as written.
- **Close.** The packet carries the built specimen for Geoff's read in Chromium, as the 2026-10-07 spec required before any consumer took the core. In the same sitting he links the trusted publisher (repo `glw907/survey`, workflow `publish.yml`, the allowed action he decided) and approves the merge. The session then creates the GitHub release and runs the post-publish check.

### Pass C: workstation tooling

Pass C lands Survey in the workstation's Claude tooling, in `~/.dotfiles` under `dotfiles-pass` and the `claude-infra` rules. Each rule takes the strongest home Anthropic's features overview names: a hook for what must hold every time, a skill for reference needed sometimes, and CLAUDE.md for a fact every turn needs.

- **Skill.** A user-scope `survey` skill routes by context (a cairn site, a SvelteKit and daisyUI tool, or a token-only app) to the installed DESIGN.md and the one recipe that applies. It forbids a value the tokens don't hold. The CLAUDE.md line from PR #131 names the skill. A skill reaches only sessions that hold the Skill tool, and the agents below do not.
- **Agent lines.** `site-implementer`, `cairn-implementer`, `visual-verifier`, and `daisyui-a11y-reviewer` list no Skill tool. Each gains one line: in a repo whose nearest `package.json` lists `@glw907/survey`, run `npm ci` if needed, read the installed DESIGN.md, and follow its rules. For the two reviewers the rule grade adds to the image grade, and a rule failure is STRUCTURAL.
- **Hook.** A stdlib Python PostToolUse hook, beside `vale-hook`, fires after an edit to a `.css`, `.svelte`, or `.html` file and filters by extension before Node starts. It finds the nearest `package.json` that lists `@glw907/survey` and runs only that repo's `node_modules/.bin/survey-check`, inside a 10-second timeout. When the package is listed but not installed, it emits one line: run `npm ci` to enable Survey checks. A missing or malformed manifest exits 0 silently. Findings cover only the changed lines and go back through `additionalContext` under `vale-hook`'s 9000-character cap. It always exits 0. In the servers repo it checks only hand-written CSS, since the copied sheet is written by the build step and never edited.
- **Render line.** If the brief's render decision takes the first option, `dependency-upgrade` gains its one line.
- **Acceptance.** Hook tests on the `tests/test_vale_hook.py` pattern against a scratch app that installs the packed package: an off-token edit returns context naming the token, a non-dependent repo and a `.md` edit return nothing, a checker crash still exits 0, and the run stays inside the timeout. Three should-trigger prompts and two should-not prompts in fresh headless sessions check the skill's description, the skill-creator trigger method. One headless `site-implementer` dispatch in the scratch app must read the installed DESIGN.md before its first CSS edit. `claude-tooling-sync verify` exits 0.
- **Hosts.** After the merge, pavilion runs `git pull`, `stow -R claude bin`, `claude-tooling-sync apply`, and `claude-tooling-sync verify`. On thinkpad-x1, `check-drift` reports the clone behind origin and runs `verify`, and the session there runs the same four commands.

### What each app's pass inherits

These constraints go into each app's own plan. None of them is built here.

- **Bulwark.** The servers repo holds a `package.json` and lockfile that pin `@glw907/survey` exactly, and a build step copies the sheet into the theme bundle. `dependency-upgrade` measures every directory with a `package.json` (its step 1), and the pin then shows up in a sweep. Checking the live theme against the repo after a deploy or a restore is that pass's design.
- **Approval queue.** It builds and render-checks in a worktree, since the main checkout serves from `build/`. It swaps `main`'s build only when no item is pending, and keeps the old build until the new one serves. Each promoted rule leaves `app.css` in the commit that takes the package.
- **907.life.** Its rebuild's `engine-consult` settles how the chassis takes the package. The cairn-site recipe ships in 1.0.0 marked pending, and that pass fills it in a minor.

### End-to-end check

A packed tarball, not the repo checkout, has to pass every leg.

- From a clean clone, the commands `AGENTS.md` names build all three outputs, and `lint`, the contrast check, and the `survey-check` fixtures pass.
- `npm pack --dry-run --json` lists DESIGN.md, the token JSON, the three outputs, the shared CSS, and the `survey-check` bin, and no `reference/` file.
- `fixtures/daisyui-consumer/` installs the tarball into a minimal Tailwind 4 and daisyUI 5 build whose only Survey input is the one-line import. A computed-style probe in both themes reads `--color-base-100`, `--radius-box`, and the font family against the token source, and `survey-check` fails on a planted literal there.
- `fixtures/token-only.html` loads only the CSS-variable sheet. The sheet holds zero `url(` and zero `@import`. A computed-style probe in both schemes matches rungs one to three, and the font family resolves to the system stack with the web fonts absent.
- The specimen, built from package outputs only (`survey-check` passes on its source), is screenshotted at 320, 390, 768, 1440, and 2560px in both schemes. A fresh-context `visual-verifier` grades it against the amended specimen at `reference/<date>-amended-specimen.html` with no STRUCTURAL finding.
- After the publish, in a scratch directory, `npm i @glw907/survey@<version>` installs, the installed DESIGN.md reads, `npx survey-check` fails on a positive fixture, and `npm view @glw907/survey@<version> dist.attestations` shows provenance.

### Stops and standing answers

Each stop the run can foresee has an answer here. The run asks Geoff only where an item says it stops.

- **Contrast moves a ruled value.** Tune lightness within the hue family, record the old value and its ratios in the token's `$description`, and list it in the PR's `## Decisions`.
- **A ruling separates the focus ring from primary.** Ship it aliased in 1.0.0 and record the split for a minor. The audit measures only primary as the focus ring.
- **Repeated STRUCTURAL findings.** Each round proceeds on a traced cause, per `pass-core`'s loop guard. A cause that returns after its structural fix is escalated in the PR.
- **Geoff's specimen read sends changes back.** A change inside the ruled scope is fixed in Pass B before the cut. One outside it is a design change and stops.
- **The publish fails.** Fix the workflow or the link and re-run the same release; the already-published guard allows it. Never bump the version to retry.
- **The post-publish check fails after a good publish.** Deprecate that version and cut a patch through the same workflow, without asking.
- **The `site-implementer` dispatch skips DESIGN.md.** Reword the agent line once and re-run. If it still skips, escalate in the PR.
- **A trigger prompt misses.** A should-trigger miss and a should-not miss get the same answer: reword the description once, re-run, then escalate.
- **The cairn-themes grep finds a pointer the fold record does not list.** Rewrite a live pointer, leave a dated record as written, and list both in `## Decisions`.
- **The 2-day link window lapses.** The session writes STATUS and waits, and Geoff recreates the link at his next sitting.
- **PR #131 is still open at Pass C.** Pass C's branch stacks on #131's.
- **Over the estimate.** A task clock stop with a traced cause resumes once at twice its estimate. Each pass runs to 1.5 times its path estimate, and stops past that.
- **What may escalate.** The nearest-token wording, a COSMETIC specimen finding, a trigger miss after one rewording, and the `site-implementer` dispatch after one rewording. The contrast bar, the pack and fixture checks, provenance, and the hook's exit 0 never escalate.
- **Unrelated drift at close.** Note it in the PR and leave it.

### Risk and estimate

Pass A is `ordinary` and merges its own PR in the initiatives repo. Pass B is `runner`, for its workflow and gate scripts, and `live-account`, since it creates a public repo and publishes to npm. With no Survey adapter yet, Pass B uses `pass-core`'s default classes, and its plan names the gate, the fast lane, and CI on PRs as the full-suite home. As a `live-account` plan it takes the three-lens review and a verification read. Pass C is `runner` under `dotfiles-pass`. Passes B and C each close through a conductor and a packet. The estimates are 210 path minutes for Pass A, 460 for Pass B, and 160 for Pass C. No recent score covers theme work. The planner checks these figures against each plan.

### Pre-flight

Geoff does two steps in the sitting where he approves this design, since neither needs a pass's output.

- [you: on thinkpad-x1, in `~/Projects/cairn-themes`, run `git status --short`, `git stash list`, `git log origin/main..main --oneline`, and `git branch -a --contains dea9839`. An error from the last command means the commit is absent. Survey work is any path under `survey-theme/`, or any commit or stash that touches one. If there is any, commit it to a new `archive/thinkpad-x1-survey` branch and push it, then `git switch main && git reset --hard origin/main`. Check: `git ls-remote origin archive/thinkpad-x1-survey` prints a line, or nothing was found.]
- [you: run `npm login` with 2FA. In the placeholder directory the session that sends this design stages (its `package.json` carries `"publishConfig": {"access": "public"}`, and its README says it is a placeholder), run `npm publish --access public`, then `npm deprecate @glw907/survey@0.0.0 "Placeholder; install 1.0.0 or later"`. Set "Require two-factor authentication and disallow tokens" on the package. Check: from a logged-out shell, `npm view @glw907/survey version` prints `0.0.0`, and `npm access get status @glw907/survey` reads `public`.]

Two more sittings follow: Pass A's rulings, and Pass B's close (the specimen read, the trusted-publisher link, and the merge approval). Pass C closes on a merge packet. If thinkpad-x1 shows nothing, the vendored copy is the S1 core verbatim and Pass A runs on three sources without asking.

### Left to the builder

The token names, Style Dictionary's configuration, the specimen's harness, the skill's wording, and the CSS-variable sheet's prefix are all left to the builder. So is how the recipes split between the skill and DESIGN.md.

### Sources

The design follows these published sources.

- DESIGN.md format: <https://github.com/google-labs-code/design.md>
- DTCG Format Module 2025.10: <https://www.w3.org/community/reports/design-tokens/CG-FINAL-format-20251028/>
- Style Dictionary and DTCG: <https://styledictionary.com/info/dtcg/>
- Adobe Spectrum tokens versioning: <https://classic.yarnpkg.com/en/package/@adobe/spectrum-tokens>
- Breaking changes in tokens: <https://designtokens.substack.com/p/how-to-manage-breaking-changes-in>
- ESLint semantic versioning policy: <https://github.com/eslint/eslint#semantic-versioning-policy>
- stylelint, ignoring code: <https://stylelint.io/user-guide/ignore-code>
- npm trusted publishers: <https://docs.npmjs.com/trusted-publishers>
- Semantic Versioning 2.0.0: <https://semver.org/>
- Keep a Changelog 1.1.0: <https://keepachangelog.com/en/1.1.0/>
- AGENTS.md: <https://agents.md/>
- Claude Code features overview: <https://code.claude.com/docs/en/features-overview>
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Claude Code hooks: <https://code.claude.com/docs/en/hooks>
- Chrome DevTools MCP design principles (self-healing errors): <https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/design-principles.md>
