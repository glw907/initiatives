# Survey house style: design

## Brief

This makes Survey the one house style for every house tool, in how it looks and in how Claude writes, published as a versioned package that each repo pins and follows through ordinary dependency updates.

Survey's visual style now exists in three places that have drifted apart: the approval queue's vendored copy, the 2026-10-07 spec, and its approved specimen. Bulwark webmail and the phonebook's UI both wait on it, and 907.life will take it in its rebuild. The writing voice works well today, but it lives in a dozen workstation files with no version, no regular grade, and no easy path for your corrections.

### What changes

- A new public `survey` repo holds Survey's tokens, principles, shared CSS, specimen, writing packs, and changelog, and publishes them to npm.
- One token source builds a drop-in daisyUI theme, a plain CSS-variable sheet, and a DESIGN.md that agents read first.
- A conformance check ships in the package and names the token to use in place of any stray value.
- One `survey` skill, an advisory hook, and four agent-definition lines point every agent at the Survey version its repo installed.
- Survey is also the writing reference: one context pack for each kind of writing, from Go comments to blog posts, each built on its published standard first.
- The writing move is measured. Each context gets fixed eval tasks, today's system sets the baseline, and nothing switches until it matches.
- Every repo with prose pins one Survey version, through npm or a release zip, so a rollback is one line.
- Your corrections in chat, in the approval queue, and in the cairn editor reach a private ledger with no extra step from you.
- A monthly review grades each context and turns your corrections into examples and rules.
- Each app moves to the visual package later, in its own pass.

### If you approve

1. You do two pre-flight steps in this sitting: check thinkpad-x1 for unpushed Survey work, and reserve the npm name with a placeholder.
2. Pass A compares the three visual versions and brings you the differences and proposed additions in one sitting.
3. Pass B builds the repo from your rulings and publishes `1.0.0-rc.1`. At its close you read the built specimen, link the trusted publisher on npmjs.com, and approve the merge.
4. Pass C adds the skill, the hook, the agent lines, and the render rule to the workstation. You approve its merge. It runs beside Pass D.
5. Pass D records how today's writing system performs, moves the writing files into Survey word for word, and releases 1.1.0 once 1.0.0 is out. Its packet carries fourteen baseline drafts for a blind read.
6. The approval queue takes `1.0.0-rc.1` in its own pass, and that pass's close promotes 1.0.0.
7. Pass E points the workstation at Survey, then pins it in every other repo with prose. One packet carries every PR.
8. Pass F starts the correction ledger, the four channels, and the monthly writing review, and releases 1.2.0.
9. Pass G builds the house register. You rule the voice traits and every departure in one sitting.
10. Pass H fills the fourteen packs with examples and house flavor, weakest first. Each is a minor release that must beat its baseline.
11. The phonebook, Bulwark, 907.life, and cairn's docs each take Survey in a pass of their own.

### Decide: Whether drafter stops a run when a Survey section is missing

drafter can read Survey's packs today, because each repo commits its pinned copy and drafter inlines any tracked file. A section token whose heading has gone yields only a "no heading" note, and the run goes on. A Survey release that renamed a section would then draft with part of its context missing and look normal.

Source: drafter's `internal/assemble/section.go` and `files.go` at `568c262`

- A short drafter pass, about 40 minutes, makes a missing file or heading under a Survey path fail the run (recommended)
- No drafter change: each repo's gate checks that every section its prompts module names exists in its pinned copy

### Worth knowing

The work is eight passes and 3,200 minutes of estimates, plus 40 for drafter if you take that option. Five of the eight are writing passes, because your rulings ask for a measured move before any improvement, adoption in every repo, and a standing loop for corrections and grading. That is two passes fewer than the last draft: the baseline and the verbatim move share one pass, and the workstation cutover opens adoption. One ask recurs: a blind sample of six pieces each month, read on a page in Chromium. cairn-themes keeps its theme ports and gives up `survey-theme/`, its Survey spec, and its backlog items #1 and #2 to the new repo.

### Rulings

These rulings stand and are not reopened. Survey is published from a public repo to npm as `@glw907/survey`, with trusted publishing, the way cairn is. Bulwark's theme waits until this work is complete. Survey is agent-friendly from the ground up, joins the workstation's Claude tooling, is versioned with a changelog, follows established practice, and includes a drop-in daisyUI theme (Geoff, 2026-10-21).

Geoff took all four review recommendations on 2026-10-22. Pass B publishes `1.0.0-rc.1` under `next`. The approval queue converges on that exact version, and a short release step at that pass's close promotes 1.0.0 with any names it changed. The other apps and Bulwark start from 1.0.0. The trusted publisher allows a direct publish, as cairn's does. Every minor or major Survey bump in an app needs a full-page render in both schemes, read in the main loop before merge, and Pass C adds that line to `dependency-upgrade`. Pass A renders a difference at or above ΔE2000 2 for color, 2px for length, or 50ms for duration. The rest sit in one table with a default that Geoff can pull into a render, and every proposed promotion is rendered.

On the same day Geoff added the house writing register and its copy-editing rules to Survey. The register may sit over Google's or Microsoft's voice, and its corpus follows drafter's established shape. When this work is done, cairn uses the Survey register.

Geoff then ruled seven points on the writing part (2026-10-22):

1. **Base standard first, Survey flavor second.** Every writing context is first a good instance of its own published standard, and Survey adds house flavor only where the base leaves room. The contexts are Go, TypeScript, Svelte, and Python comments; commits and PR bodies; approval briefs; agent-facing files; developer docs; end-user docs, help dialogs, and interface text; and site content, blog posts included, with each site's content guide as its overlay. This replaces the non-goals that excluded code comments, commits, agent-facing files, and website content. The charter's "website content is the one personal voice" becomes: site content is a Survey context whose overlay is the site's own guide.
2. **Enough context for each context.** Each one gets a pack: the base standard as positive rules with reasons and links, canonical examples from the base's own corpus (license-checked), three to five tagged house examples per surface, Survey's flavor and any departure with its ruling, before-and-after tells with the after first, the checks, and a small eval set graded against the rubric. Geoff's approved writing is the richest source of house examples.
3. **Other projects use Survey as their writing reference.** Adoption is its own pass and covers every repo with prose, the Go repos without npm, the workstation, the phonebook, cairn, and its sites included. Repos without npm get a second channel: a versioned zip release asset that Vale loads by URL, plus the vendored-skills channel for the skill. The `glw907` tells move into Survey's packs. The Pass D fold's recommendations to keep `glw907` outside Survey and to govern only npm repos are superseded.
4. **Do not break what works.** The migration preserves behavior first: build each context's eval set and run it through today's system for a baseline, with a small sample shown to Geoff; move content into Survey verbatim and turn today's files into thin pointers; re-run the evals, and a context passes only if it matches its baseline, with no repo switching until its contexts pass; keep the old files until the new path has run cleanly, and pin Survey in each repo so rollback is one line. Improvements come after, each as its own minor that must beat its context's baseline without hurting any other.
5. **Corrections must be easy to take.** Three channels feed one ledger: chat (a `survey` skill route records before, after, context, and reason when Geoff corrects wording), the approval queue (a harvester reads his prose edits and comments), and notes he attaches to items. The ledger is private and never lands in the public repo; only distilled, sanitized results are published. A recurring distill step groups corrections by context and proposes examples, sharper rules, or Vale rules, each of which must beat its context's baseline. A generalization goes to Geoff as one packet, and an example taken directly from his correction ships without asking.
6. **A fourth channel: the cairn editor.** Geoff may have Claude draft a blog post, then correct it in the cairn editor. The intake asks nothing extra of him. Those corrections feed the site-content pack, and the private-ledger rule holds.
7. **Grade the writing periodically.** Each context is graded on its fixed eval tasks and on a sample of real writing shipped since the last run, scored with the rubric, `tellgrader`, and Vale, plus a small blind sample Geoff reads. Results go to a dated scorecard with a trend per context. A context that drops opens a backlog item, and the distill step works on the lowest-scoring contexts first. The design reuses the workstation's monthly reviews and stays the minimum that gives a trend Geoff can trust.

### Intent and goals

Every house tool should read as one family, and every piece of Claude's writing should read as one voice over its own standard. Where we hold every lever (the approval queue, the phonebook, 907.life's cairn layer), the tool carries Survey's felt craft. Where an app exposes only a few levers, such as Bulwark, it is still recognizably Survey. An agent working in any of these contexts applies Survey correctly without being briefed. Each app follows Survey as it improves, through a version bump and a changelog that says what to do. Claude's writing in any repo is a good instance of its published standard with one recognizable house flavor, and it gets better each month from Geoff's corrections without his doing anything extra.

None of the three existing visual versions is the reference. Each looks good, and each may change a little to match the principles this work writes down (Geoff, 2026-10-21).

The work has seven goals.

- One written house style: principles, tokens in light and dark, and per-context recipes.
- One context pack per kind of writing, each a good instance of its base standard first.
- A ladder of levers ranked by how much resemblance each carries, so a partial adopter knows what to take first.
- Releases under Semantic Versioning, each with a changelog entry that names the consumer's action.
- One pinned Survey version in every repo with prose, read by agents, drafter, and Vale alike.
- A grade per writing context with a trend Geoff can trust, and corrections that reach the packs with no extra step from him.
- Agent-friendly from the ground up: version-matched docs, role-named tokens, a conformance check with fix-naming messages, and upgrade steps an agent can carry out.

Six things stay out of scope.

- Restyling the cairn admin. It keeps its own design system.
- Packaging Survey as a selectable cairn theme (cairn-themes S3, cairn's work).
- The terrain hero from elevation data.
- Building any app's visual convergence inside these passes, and cairn's move of its own docs register onto Survey's packs. Each is the app's own pass.
- Grading writing that people wrote. The system grades Claude's drafts, since the charter is "not a quality gate for human-written content".
- Replacing a base standard's own linter (gofmt and go vet, ESLint, ruff, commitlint, the brief check) or `tellgrader`. Survey's Vale rules sit beside them.

Four outcomes would mean the work failed: a style that only works where every lever exists, which leaves Bulwark-class apps generic; copies that drift, where an app can't tell which Survey it has or what changed since; rules an agent has to infer from CSS, or values it is free to invent; and a migration that changes writing that works before anyone has measured it.

### The shape of the work

Survey has two halves, a visual system and a writing system, and they share one repo, one version line, one release workflow, one set of channels, one agent-facing entry, and one map into the workstation's Claude tooling. The visual half is tokens, outputs, shared CSS, a specimen, and the conformance check. The writing half is the context packs, the Vale style, the evals, the correction ledger, and the monthly review. Both ship in `@glw907/survey`, both follow the changelog's rungs, and both reach an agent through the one `survey` skill and the files the package installs.

Eight passes build it. Each row names the pass, its outcome, the repos it edits, its highest risk class, and its estimate. The classes follow `pass-core`: `runner` for skills, agents, workflows, and gate tools, and the `live-account` flag for a run that creates a public repo or publishes to npm.

| Pass | Outcome | Repos | Class | Minutes |
|---|---|---|---|---|
| A | One ledger of visual rulings and an amended specimen | initiatives | `ordinary` | 210 |
| B | The public repo, the package, and `1.0.0-rc.1` on `next` | survey, cairn-themes | `runner`, `live-account` | 460 |
| C | The `survey` skill, the hook, the agent lines, and the render rule | ~/.dotfiles | `runner` | 160 |
| D | A baseline for every writing surface, the verbatim move, and 1.1.0 | survey | `runner`, `live-account` | 590 |
| E | The workstation and every repo with prose pinned to Survey | ~/.dotfiles, fourteen repos | `runner` | 460 |
| F | The private ledger, four correction channels, the monthly review, and 1.2.0 | survey, ~/.dotfiles, survey-ledger | `runner`, `live-account` | 380 |
| G | The house register: voice, departures, style sheet, Vale rules, licenses | survey, initiatives | `runner`, `live-account` | 300 |
| H | Fourteen full packs, each a minor that beats its baseline | survey | `runner`, `live-account` | 640 |

The order is A, B, then C beside D, the approval queue's own pass to 1.0.0, then E, F, G, and H in sequence. Pass D may start once Pass B merges and needs nothing from Pass C. Pass D's release waits for 1.0.0. Pass E needs 1.1.0. Pass F needs the vendored skill entry that Pass E lands. Pass G needs Pass D's packs and rules, and Pass H needs Pass G's voice file and departure rulings, since every pack's `flavor.md` reads them. The drafter pass, if taken, is 40 minutes in the drafter repo, `ordinary`, and runs before Pass G. The estimates sum to 3,200 minutes. The path is 3,040, with Pass C beside Pass D. No recent score covers theme or writing-system work, so the planner checks each figure against its plan.

### The lever ladder

An app adopts from the top down, as far as its theming surface allows. Palette carries the most resemblance and is the first rung: paper, ink, and water in light and dark, with the status colors. Shape comes next, meaning radii, 1px borders, no shadows, and the focus ring. Type is the third rung: Spectral, Karla, and Monaspace Neon, with a named system-font stack for apps that can't load web fonts. Motion is the fourth, and the signature details are the fifth (contour texture and rules, benchmark triangle, margin collar, index rail, the frame). Full-lever apps take all five rungs. Bulwark takes rungs one to three, because its theme filter strips `url()`.

### Token source and outputs

One DTCG 2025.10 file is the source, and Style Dictionary builds the three outputs from it. Style Dictionary 5.7.0 read DTCG 2025.10 colors, dimensions, durations, shadows, and cubic Béziers in the mechanics probe, though its docs say 2025.10 "does not have full support yet". The probe also showed it silently drops a group that uses `$extends` and ignores `$deprecated`.

- **Source.** A base group plus `light` and `dark` groups, filtered per platform. `$extends` is not used. Style Dictionary is pinned to an exact version. Each token is named for its role (`paper`, `ink`, `water`, `focus-ring`), never a raw value, and the build fails on a token without a `$description`. The focus ring aliases the primary color in 1.0.0, the role `theme-contrast` measures at 3:1.
- **daisyUI theme.** Light and dark `@plugin "daisyui/theme"` blocks and the `@theme` scale, imported in one line after `@plugin "daisyui" { themes: false; }`. The mechanics probe compiled this from a packed tarball under Tailwind 4.3.3 and daisyUI 5.7.50. The output keeps the names `theme-contrast` reads: `--color-muted`, `--cairn-{info,success,warning,error}-ink`, and `--color-primary` as the focus ring. It carries no `--cairn-code-*` roles, as the vendored core never did. It is the default recipe for a new house tool, since Geoff builds most tools on daisyUI.
- **CSS-variable sheet.** Light values in `:root`, dark under `@media (prefers-color-scheme: dark)` and under the dark `data-theme` value. It holds no `url(` and no `@import`, and a header comment names the package version.
- **DESIGN.md.** Google Labs' format: tokens in front matter, principles in prose, ending in "Do's and Don'ts". `@google/design.md` 0.4.0 is alpha and has no dark-scheme concept, and its contrast rule only warns (a 1.08:1 pair exited 0 in the probe). So the front matter holds the light set and a `components` list of the real pairs, the dark set lives in prose, the CLI is pinned exactly, and the gate fails on any `lint` error. `lint` checks structure only. Each principle is one imperative sentence a check or a reviewer can test, paired with its "Do's and Don'ts" entry.
- **Shared CSS.** The component overrides and signature details stay hand-written under the existing `site-*` and `--site-*` prefixes, each with its component and reason beside it (the DaisyUI-first rule).
- **Package shape.** `daisyui ^5` and `tailwindcss ^4` are peer dependencies, and the Fontsource fonts are dependencies. `exports` names each CSS file, DESIGN.md, and the token JSON. `bin` names `survey-check`. `files` leaves out `reference/`, `evals/`, and `tests/`.

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

Agents are Survey's main users, so every part of it is built to be read and checked by one (Geoff, 2026-10-21). The one `survey` skill is the agent-facing entry for both halves: it routes a visual task to the installed DESIGN.md and the one recipe that applies, and from Pass F it carries the corrections route. Writing tasks keep the `writing-voice` router under its own name, since renaming it would change its triggers and break `prose-voice-reviewer`'s `skills:` preload.

- **The docs travel with the version.** The npm package ships DESIGN.md, the token JSON, and from 1.1.0 the packs and the Vale style. An agent reads `node_modules/@glw907/survey/DESIGN.md` for the exact version installed. In a fresh worktree it runs `npm ci` first and never falls back to the GitHub copy.
- **Upgrades an agent can do.** Each changelog entry names the consumer's action as a concrete step, such as "replace `--survey-shade` with `--survey-paper-2`". A deprecated token stays as an alias until the next major.
- **A map for working on Survey itself.** The repo carries an `AGENTS.md` (the open agents.md format) with its build, gate, and release commands, beside DESIGN.md at the root.
- **No MCP server.** The skill and the shipped files carry the same content without a running service.

### Versioning and release

Survey follows Semantic Versioning 2.0.0. One policy covers tokens, the checker, and the writing part.

- **Tokens** follow Adobe Spectrum's token policy. Renaming or removing a token, or changing its type, is major, and it ships first as a deprecated alias in a minor. A new token, rule, or intentional value change is minor, and a fix with no visible change is a patch.
- **The checker** follows ESLint's README. A bug fix that reports more errors is minor, while an addition to the default rule set that may report new errors is major. A stricter check can also ship as a warning in a minor and become an error at the next major.
- **Writing** uses the `writing` rung. A changed tell, rule, or example is minor. Removing or renaming a pack, a surface, or a section slug is major. A new Vale rule, or a changed pattern, that can report new findings at `error` is major, or ships first as a `suggestion` in a minor. Raising a rule's level is major at `error` and minor below it, and each rule's failing fixture pins its level. A `suggestion` still reaches agents, since every house config sets `MinAlertLevel = suggestion` and `vale-hook` returns suggestions.
- **Changelog.** A hand-kept `CHANGELOG.md` in Keep a Changelog 1.1.0, with a `## [Unreleased]` section. Each entry names its rung (palette, shape, type, motion, signature, tooling, or writing) and the consumer's action, or "none". Changesets is not used: version 3.0.3 hard-codes headings that are not Keep a Changelog's, and its version PR adds a manual step per release.
- **Workflow.** `publish.yml` is copied from cairn's. It runs on a published GitHub release or a manual dispatch, never on a push, so no merge can publish. It pins npm 11 (npm 12.0.0 shipped without sigstore), passes `--provenance`, derives the dist-tag from the version (`next` for a prerelease), skips a version already published, and from 1.1.0 uploads `Survey.zip` to the release. `repository.url` matches the repo exactly, and the job runs Node 22.14 or later, as trusted publishing requires.
- **First publish.** npm cannot bind a trusted publisher to a package that does not exist. cairn's first publish was by hand for that reason (`cairn-cms/.github/workflows/publish.yml:92`). So Geoff publishes a `0.0.0` placeholder at pre-flight and deprecates it at once. The release candidate goes to `next`, so `latest` stays on the placeholder until 1.0.0, and the deprecation warns anyone who installs it bare. A new trusted-publisher link "must complete its first successful publish within 2 days". He makes the link in Pass B's close sitting, and the release runs the same day.
- **Rollback.** A bad version is deprecated and superseded by a patch, never unpublished. `AGENTS.md` says so in its release section. A consumer rolls back by moving its one pin.

### Channels and pins

A repo pins exactly one Survey version, and every reader in it uses that version (ruling 4). Visual consumers pin through npm alone. For the writing part, the packs have one source, `skills/survey/packs/` in the survey repo. That path matters because the vendored-skills channel copies only the files under a skill's path (`fetch_skill`, `~/.local/bin/claude-tooling-sync:397-421`). The build assembles a Vale style directory, `vale/Survey/`, from the Vale rules plus `packs/` and a `SHA256SUMS` file. The npm package and the release zip both carry that one directory.

- **Repos with npm.** The repo lists `@glw907/survey` in `package.json`, commits a copy of `vale/Survey/` under its `StylesPath`, and its gate fails when `diff -r` finds the copy differs from the installed package. Probed under Vale 3.24.0: the committed style raised `Survey.<Rule>` by name, the diff exited 0 in sync and 1 after one edit, and Vale exited 2 with the copy removed.
- **Repos without npm.** `.vale.ini` names the release asset in `Packages`, as `https://github.com/glw907/survey/releases/download/v<version>/Survey.zip`, and the repo commits what `vale sync` installs. Its gate downloads that zip and diffs it against the committed copy. Probes: `vale sync` installed a version-pinned GitHub release zip (`errata-ai/Google` at `v0.7.1`); a local zip kept a `packs/` folder inside the style directory, which Vale ignored while it raised the style's rule; the diff check exited 0 in sync and 1 after a local edit. A `.vale.ini` that names the zip but applies no style raised nothing and exited 0, so a pin alone adds no lint findings.
- **The workstation.** `vendored-skills.json` names the `survey` skill with its `branch` set to a release tag. `fetch_skill` makes three GitHub API calls with that field, and each accepted a tag in the probe. The dotfiles gate runs `sha256sum -c` over the vendored packs, so an edit made in place fails before it spreads.
- **Where a session reads a pack.** The `writing-voice` router reads the repo's committed `<StylesPath>/Survey/packs/` when the repo pins Survey, and `~/.claude/skills/survey/packs/` otherwise.
- **drafter.** drafter inlines any file git tracks inside the repo (`resolve` in `internal/assemble/files.go`), so it reads the committed copy with no change. The brief's drafter decision covers a missing section.
- **Rollback.** Change the one pin, then run `npm i`, `vale sync`, or `claude-tooling-sync update-skills survey`.

The vendored notes on `vale-ci` and `vale-fix` say not to run `vale sync` against a committed styles directory, and npm repos never do. A repo on the zip channel runs `vale sync` only when it moves its pin. It pins any other package on its `Packages` line by URL as well, so a sync never moves a style it didn't mean to.

### Writing contexts

Every kind of writing Claude does here is a context, and each starts from its published standard (ruling 1). A context has one pack. A surface is a kind of output inside it that gets its own examples and eval tasks, so `end-user` has three surfaces and most packs have one. Pass D moves each pack from the workstation file named here, word for word.

| Pack | Base standard | Base linter | Moved from | Surfaces |
|---|---|---|---|---|
| `go-comments` | Go Doc Comments, Effective Go | gofmt, go vet | `go-conventions`, its "Comments" section | Go comments |
| `ts-comments` | TSDoc | ESLint with jsdoc and tsdoc | `ts-conventions` | TypeScript comments |
| `svelte-comments` | TSDoc and the Svelte `@component` convention | ESLint with jsdoc and tsdoc | `svelte-conventions` | Svelte comments |
| `python-comments` | PEP 257, PEP 8 | ruff `D` | `python-conventions` | Python docstrings and comments |
| `commits-and-prs` | Conventional Commits and the git-commit canon | commitlint, optional | `voice/commit-and-pr.md` | commit messages, PR bodies |
| `approval-briefs` | inverted pyramid, Federal Plain Language Guidelines, NN/g | `check-brief.ts`, `packet --check` | `voice/approval-brief.md` | packets and briefs |
| `agent-facing` | Anthropic's Claude Code and prompting guidance | none | `voice/agent-facing.md` | skills, agents, CLAUDE.md |
| `dev-docs-go` | Google developer documentation style guide | Vale `Google` | `voice/technical-doc-go.md` | docs in Go repos |
| `dev-docs-web` | Google developer documentation style guide | Vale `Google` | `voice/technical-doc-web.md` | docs and changelogs in web repos |
| `end-user` | Microsoft Writing Style Guide | Vale `Microsoft` | `voice/editor.md` | end-user docs, help dialogs, interface text |
| `site-content` | the shared web-content method, under each site's content guide | the site's Vale config | `docs/web-content-method.md` | blog posts, pages, form copy |
| `core` | the audience-invariant tells | `tellgrader`, Vale `Survey` | the `writing-voice` output style and the `glw907` Vale style | every context, and replies |

That makes eleven packs, `core`, and fourteen surfaces. The `voice/` paths are under `~/.claude/docs/`. A house tool's interface text is the `end-user` context. A site's form copy, labels, and errors are `site-content`, under the site's own guide, so no site surface has two owners. Today's site-content base is the shared method, which cites no external standard. Pass D moves it as it is, and naming a published base for it is an improvement for Pass H that must beat its baseline. cairn's docs voice stays cairn's overlay above `dev-docs-web` and `end-user`, as the charter has it, until cairn's own convergence pass.

### Context packs

A context pack holds what a session needs to write well in one context (ruling 2). Pass D fills each pack with one file, `pack.md`, which is today's text byte for byte. Pass H then gives it the full shape, one pack at a time:

- `standard.md` holds the base standard as positive rules, each with its reason and a link. Anthropic's prompting guide says to "tell Claude what to do instead of what not to do" and to give the reason behind an instruction.
- `examples/base.md` holds canonical excerpts from the base's own corpus, each with its URL, license, and retrieval date.
- `examples/house.md` holds three to five house examples per surface in `<example>` tags, each naming its source. The same guide calls examples "one of the most reliable ways to steer Claude's output format, tone, and structure" and says "Include 3–5 examples for best results".
- `flavor.md` names `packs/core/voice.md` as its first read, then holds Survey's flavor where the base leaves room, and each departure with its ruling id.
- `tells.md` holds the before-and-after pairs, after first. The `glw907` comment tells land in the comment packs here (ruling 3).
- `checks.md` names the base linter's command and the Survey Vale rules that apply.

House examples come from Geoff's approved writing: merged docs, PR bodies and packets he approved (the approve verdicts in `decisions.jsonl`), his posts, and his public corrections. Each pack's eval set lives beside it in the survey repo at `evals/<pack>/` and never ships, since no consumer runs it. The router names each pack file directly, following Anthropic's skill guidance to "keep references one level deep from SKILL.md".

### Evals and the baseline

The move follows two published practices. Characterization testing records what a system does before a refactor: "The purpose of characterization testing is to document your system's actual behavior", so "We can run our tests and find out immediately whether we've changed behavior" (Michael Feathers). Anthropic's skill guidance calls the same loop evaluation-driven development: "Create evaluations BEFORE writing extensive documentation", "Establish baseline", then "Run evaluations, compare against baseline, and refine." Its skill-creator plugin sets the baseline for an existing skill as "the old version", snapshotted before any edit.

- **Tasks.** Each surface gets three fixed tasks, the number Anthropic's guide asks for ("Build three scenarios"), for 42 in all. The twelve tasks in `writing-voice/evals/evals.json` carry over where they fit. Each task names its facts, three or four assertions, and a 1 to 5 rubric on register fidelity, clarity, structure, and factual fidelity, the dimensions the September benchmark used.
- **Arms.** Each run is a fresh headless `claude -p` session in a scratch project. Output styles don't reach subagents ("Other subagents run their own system prompt, so styles don't change how they respond"), so a subagent harness can't measure the always-on part. Each arm loads its own style with `--settings '{"outputStyle":"<name>"}'` from the project's `.claude/output-styles/`. It runs with `--disable-slash-commands`, which removed the Skill tool in the probe while the style still applied. The prompt then names the exact files the arm reads. The baseline arm reads a snapshot of today's files at a recorded `~/.dotfiles` commit, and the candidate arm reads the pack files and pointer texts the new path would load.
- **Runs and graders.** Three runs per task, aggregated with skill-creator's `aggregate_benchmark` into a mean and standard deviation. Each draft is scored by `tellgrader` with its register profile, by Vale with the context's config, and by a fresh-context judge on the rubric and assertions. The judge also picks between the two arms blind, as the September benchmark's third layer did. The judge runs on one fixed model other than the drafting model, per Anthropic's note that it is "Generally best practice to use a different model to evaluate than the model used to generate the evaluated output".
- **Match.** A surface matches its baseline when its rubric mean and assertion pass rate sit no lower than the baseline mean minus one standard deviation, its tells per 1,000 words and Vale errors sit no higher than the baseline mean plus one, and the blind judge prefers the baseline in no more than 60% of pairs.
- **Beat.** An improvement beats its baseline when the rubric mean rises above the baseline mean plus one standard deviation, or the blind judge prefers it in at least 60% of pairs, with every other measure still matching. Every surface that reads a changed file must also match. A change inside one pack runs that pack's surfaces, and a change to `core`, a shared Vale rule, or the Survey Vale style runs all fourteen.
- **A fixed yardstick.** The judge model and the rubric stay fixed. Changing either re-runs the baseline, and the scorecard marks the break. An accepted improvement becomes its surface's new baseline, as skill-creator's iterations do. The thresholds are judgment calls set from the September benchmark's spreads.
- **Geoff's bar.** Pass D's packet carries one baseline draft per surface, blind, in skill-creator's review viewer, whose server mode saves "to feedback.json in the workspace". He marks each ship, edit, or reject. The record sets the bar and the judge's starting agreement with him. A surface he marks weak goes first in Pass H, and the move still only has to match.

### Corrections

Every correction lands in one private ledger with no extra step from Geoff (rulings 5 and 6).

- **The ledger.** A private repo, `glw907/survey-ledger`, cloned at `~/Projects/survey-ledger` on both hosts. Corrections arrive on either host and from GitHub, and the distill needs them in one place. The workstation already keeps private material in private GitHub repos (the phonebook, servers), and the initiatives repo is public. The approval queue's per-host state directory was the other candidate. Its monthly review accepts a split by host because each host's queue stands alone ("Queue state lives per host"), but corrections need to come together. Each correction is one JSON file named by its channel and source key. A second harvest, or the other host, writes the same file, and two sessions never touch one file. A record holds the channel, pack and surface, repo and its visibility, before, after, reason (Geoff's words, or none), source ref, time, and host.
- **Chat.** The `survey` skill's corrections route triggers when Geoff rewrites or corrects wording Claude wrote. The session applies his fix, writes the record, and commits and pushes the ledger. It asks him nothing, and records a reason only if he gave one.
- **The approval queue.** `survey-harvest queue`, a stdlib Python helper in `~/.dotfiles/bin`, finds decided items in `decisions.jsonl` whose line counts `comments`, or whose kind is a blueprint, a page, a change, or a send-back. It reads each item's `items/<id>/decision.json` for comments with their anchored quote, send-back notes, and triage row notes. Direct prose edits come from git: the blueprint and page screens commit each edit as `Edit <file> in review` (`approval-queue/src/lib/server/blueprint.ts:90`), so the parent blob is the before and the commit's blob the after. A script fits this step, since Anthropic's skill guide says to "Prefer scripts for deterministic operations". The script emits candidates, and the session keeps only those about wording and names each one's surface.
- **The cairn editor.** A cairn save commits with the editor as author and leaves the committer to the App: "the committer is omitted, so GitHub attributes the commit to the App" (`cairn-cms/src/lib/github/repo.ts`). On 907.life such a commit reads author `Geoff Wright <geoff-login@907.life>`, committer `cairn-cms[bot]`, subject `Publish posts: <id>`. The draft side has no reliable mark. Claude's co-author trailer is on 239 of 256 commits on 907.life's `main` and on code commits as much as content, so it can't say who drafted a page. The minimal marker is one trailer that `content-draft` adds to the draft commit, `Survey-Draft: site-content`, in the same final block as the co-author line. In the probe, a trailer in a paragraph of its own was not parsed. The harvester finds the draft with `git log --format='%H %(trailers:key=Survey-Draft,valueonly)' -- <path>`, then Geoff's later saves with `--committer='cairn-cms\[bot\]' --author=<his address> <draft>..<default>`, and diffs the two blobs. The probe returned his save and skipped a volunteer's. The draft must be reachable from the default branch, because publishing commits the entry there and deletes its `cairn/<concept>/<id>` pending branch (`src/lib/content/pending.ts`, `content-routes-entry-write.ts`). Geoff's addresses are seeded in the ledger from his own commit authorship. These corrections feed the `site-content` pack.
- **What gets published.** The ledger never lands in a public repo. An example ships only from a correction whose source repo is public. A correction from a private source stays in the ledger and informs generalizations, which reach Geoff in a packet anyway.

### The monthly writing review

The review grades every surface and then distills the month's corrections (rulings 5 and 7). It reuses the monthly model review's cadence and home: the `model-review.timer` (`OnCalendar=monthly`) and its unattended `claude -p` launcher, which already chains the servers review as its step 8 ("if ... prompt.txt exists, read it and follow it"). A step 9 chains this review the same way. Its prompt is `docs/writing-review/prompt.txt` in the survey repo. Like the decision review's log, `docs/writing-review/log.md` takes one line per month, quiet months included. `model-review-notify --dry-run` gives a safe trial run.

1. Harvest this host into the ledger: the approval queue, the cairn editor, and any blind-review `feedback.json` in `~/Downloads` that names one of the ledger's sample ids. Push.
2. If the ledger's origin already holds `scorecards/<YYYY-MM>.md`, stop. The other host ran this month.
3. Grade the fixed tasks for all fourteen surfaces at the workstation's pinned Survey version, three runs each, with the baseline's graders and judge.
4. Grade real writing: up to five Claude-written pieces per surface that shipped since the last run, from the repos that pin Survey. A Claude piece is one whose commit carries the co-author trailer. Sources are commit messages, merged PR bodies, comments added in merged diffs, changed docs and posts, and this host's packets. Score each with the rubric judge, `tellgrader`, and Vale.
5. Write the scorecard to the ledger: per surface, this month beside the three before it, with the fixed-task rubric mean and spread, assertion pass rate, tells per 1,000 words, Vale errors, the real-sample rubric mean, and the judge's agreement with Geoff.
6. Open a backlog item in the survey repo through `log-issue` for any surface whose fixed-task mean fell below last month's mean minus one standard deviation, or whose real-sample mean fell two months running. The item carries numbers, never quoted text.
7. Build the blind sample: six pieces, three from the fixed tasks and three real, with their sources hidden, as a static skill-creator viewer page in the ledger clone. Notify at normal urgency. Geoff marks each ship, edit, or reject, with an optional note, and the viewer downloads his `feedback.json`. The next run files it, and each note joins the ledger as a correction.
8. Distill. Group the month's new corrections by surface and take the lowest-scoring surfaces first. Propose examples taken straight from corrections, sharper rules, and Vale rules, and run each against its baseline. An example that beats it goes into a survey PR that the session merges and releases as a minor, with no packet (ruling 5). Generalizations that beat it go to Geoff as one packet through `approval-packet`, each one an ask.
9. Add the log line, commit, and hand over.

Each run drafts about 126 fixed-task pieces and grades up to 70 real ones. The fixed tasks, judge, and rubric keep the months comparable, and Geoff's six verdicts each month show whether the judge still agrees with him.

### The house register

Pass G builds the house flavor the 2026-10-22 rulings asked for: the register over Google and Microsoft, its departures, and the copy-editing rules. Its main source is cairn's `docs/internal/docs-register.md`, the most developed overlay on the workstation. Pass H then applies it pack by pack.

- **Voice and tone.** The voice stays fixed while the tone moves with the surface, as Mailchimp, Atlassian, and Shopify Polaris each set out. `packs/core/voice.md` states the voice as three to five traits in Mailchimp's "X but not Y" form ("smart but not snobbish"). It also holds a tone table that places each surface on Nielsen Norman Group's four tone dimensions: funny or serious, formal or casual, respectful or irreverent, enthusiastic or matter-of-fact. Every pack's `flavor.md` names `voice.md` as its first read, so the traits have one home.
- **Building on drafter's stock.** The Google packs hold the house deltas and cite drafter's `drafter:google-*.md` stock files for the base (`const drafterPrefix = "drafter:"`, `internal/assemble/section.go:13`). drafter has no Microsoft stock (`internal/blueprint/tracks.go:21` lists only `google`), so the `end-user` pack is written whole in Pass H. Its interface-text surface generalizes the Voice section of cairn's admin design system.
- **Departures.** A row is admitted by cairn's own test (`docs-register.md:1083-1095`, Geoff, 2026-09-28). An override of the base guide needs a row with its source and ruling, and a tightening does not. Each ruling id carries its source as a prefix (`cairn-2026-09-28-r3`, `survey-g-r1`), and a carried cairn ruling cites a GitHub permalink at the harvest commit. Once cairn converges, a cairn rule that departs from Survey is a row in cairn's own register with Geoff's ruling.
- **Corpus licensing.** Google's pages are CC BY 4.0, as drafter's corpus records. Microsoft's live pages read "All rights reserved", but the guide's public source repository, `MicrosoftDocs/microsoft-style-guide`, is CC BY 4.0 by its `LICENSE` and `ThirdPartyNotices` files, archived at `c6945c3` (2024-11-13). Microsoft excerpts are quoted only from that commit, each with its file permalink, the live page's URL, the license, and the retrieval date. Live text that differs is linked and paraphrased. Every other base corpus (the Go and Python standard libraries, the TSDoc and Svelte projects, Conventional Commits, Anthropic's docs) has its license read and recorded before Pass H quotes it. The package's `license` field becomes an SPDX expression that names CC-BY-4.0 for the corpora. `LICENSES.md` ships with the attribution and change notes CC BY 4.0 requires, and a lint fails on an excerpt without its URL, license, or date.
- **Copy-editing rules.** A style sheet, the editor's established tool for a house's mechanical choices, lists each rule with its source, such as the serial comma, sentence-case headings, and how dates, times, and numbers are written. Each row has a `vale:` field naming its Vale rule, or the reason none fits.
- **Survey's Vale rules.** The `Survey` style starts in Pass D as the seven `glw907` rules, unchanged. Pass G adds a rule for each departure and copy-editing rule Vale can express. Fixtures live in `tests/vale/`, outside the style directory, since Vale reads every `.yml` there as a rule.
- **Judgment layer.** Vale is the deterministic net. `prose-voice-reviewer` reads a house-tool draft against its pack, and `cairn-register-editor` reads cairn's drafts once cairn converges.

### The Claude-infra map

The writing work touches most of the workstation's writing tooling, and each piece keeps one home under the `claude-infra` rules. Anthropic's features overview sets the order of strength: "If a rule must hold every time, make it a hook rather than a prompt instruction", and "Put it in a skill if it's reference material Claude needs sometimes". CLAUDE.md carries only a fact that every turn needs. Every change here preserves behavior first (ruling 4), lands through a `~/.dotfiles` PR under `dotfiles-pass` at `runner` class, and reaches both hosts.

| Piece | Home | Change | Pass | Follows |
|---|---|---|---|---|
| `survey` skill | skill, authored in Pass C, then vendored from the survey repo at a release tag | gains `packs/` in D, is vendored in E, gains the corrections route in F | C, D, E, F | Claude Code skills |
| `writing-voice` skill | skill, authored | each router row names its pack path; name and description stay, so its triggers and `prose-voice-reviewer`'s `skills:` preload hold | E | Claude Code skills |
| `go`, `ts`, `svelte`, and `python-conventions` | skills | comment sections move word for word to the comment packs, and each skill names its pack; Go's code rules stay | E | Claude Code skills |
| the six registers in `~/.claude/docs/voice/` | docs | each becomes a relative symlink into the vendored pack, byte-identical by `cmp` | E | none |
| `~/.claude/docs/web-content-method.md` | docs | becomes a symlink into the `site-content` pack | E | none |
| the authoring charter | docs | the site-content line per ruling 1, the overlay paragraph, the table's rows, and the adoption steps name Survey | E | none |
| `claude-tooling.md`, `vendored-skills.json` | docs, manifest | the `survey` entry pinned by tag, with its rule of use: edit packs in the survey repo, never in place | E | Claude Code skills |
| dotfiles `scripts/check.sh` | gate | `sha256sum -c` over the vendored packs, and every symlink resolves | E | none |
| `prose-voice-reviewer` | agent | one line: in a repo that pins Survey, read its pinned packs | E | Claude Code subagents |
| global CLAUDE.md, "Writing voice" | CLAUDE.md | one sentence names Survey as the house writing reference | E, second to last | Claude Code memory |
| `writing-voice` output style | output style | becomes a relative symlink into `packs/core/` | E, last | Claude Code output styles |
| `content-draft` | skill | one line: add the `Survey-Draft` trailer to the draft commit | F | Claude Code skills |
| `survey-harvest` | `~/.dotfiles/bin` | new helper for the queue and cairn channels | F | Claude Code best practices |
| `docs/model-review/prompt.txt` | the monthly runner's prompt | step 9 chains the writing review | F | none |

Some pieces change nothing. `vale-hook` and `tellgrader --hook` run each repo's own config, which names Survey once the repo adopts it. `content-review`, `approval-packet`, and `pass-core` read the method and the brief register at paths that stay put. `cairn-register-editor`, `register-check`, and `cairn-docs-drafter` keep cairn's register until cairn's own convergence pass. Neither the distill step nor the grading needs a skill, since each runs from a committed prompt, as both monthly reviews already do.

The approval-brief register needs its path. The approval queue's gate reads its exemplars from `~/.claude/docs/voice/approval-brief.md` (`tests/approval-queue.test.sh:209`), and the brief check prints that path in each refusal (`approval-queue/src/lib/brief.ts:8`). A symlink keeps both working. A contract change now lands in Survey first, and an approval-queue PR can test against a survey checkout through the `REGISTER` variable the gate already reads.

The symlinks rest on two probes. A headless session loaded an output style through a relative symlink, and `stow` linked a package file that is itself a relative symlink, which resolved to its target. Claude Code "reads style files when it starts", so the style change reaches each session at its next start.

The visual guidance and the corrections route share the one `survey` skill, as ruling 5 names it. Anthropic's skill guide notes that Claude reads each description "to choose the right Skill from potentially 100+ available Skills", and one fewer description is one fewer chance of a collision. A correction is a different moment from drafting, which keeps the route clear of `writing-voice`.

### Pass A: visual harvest and rulings

Pass A turns the three versions into one ledger of rulings and an amended specimen. It is `ordinary`, works in the initiatives repo, merges its own PR, and runs about 210 minutes. It reads, at commits it records, the approval queue's four `src/lib/survey/` files, `src/app.css`, and `src/lib/components/frame/frame.css`, plus the 2026-10-07 spec and the approved specimen. If the thinkpad-x1 pre-flight step found Survey work, its archive branch joins as a fourth source. Pass A only reads the approval queue.

- **Ledger.** `initiatives/survey-house-style/research/<date>-harvest-ledger.md` holds one row per token or rule, with its source locations, rung, disposition (agreement, difference, forced, promote, or app-only), and ruling id. A grep count of the custom properties and rule selectors in the six approval-queue files and the approved specimen must equal the ledger's mapped count. The agreements become the draft principles.
- **Forced differences.** A difference that a rule settles, such as a value that fails contrast, is Claude's call. The sitting lists it without a render.
- **The sitting.** The remaining differences and every approval-queue rule Claude proposes to promote reach Geoff in one sitting in Chromium, rendered at the ruled threshold. Each render shows one panel per source that differs, with a recommendation. Geoff sees every addition before 1.0.0 fixes the token names. After the sitting, every difference and promote row carries a ruling id.
- **Specimen.** Pass A ends by writing `initiatives/survey-house-style/reference/<date>-amended-specimen.html`, committed and pushed with the ledger. Pass B cites both by commit and grades against that file.

### Pass B: the repo and the release candidate

Pass B creates the public `glw907/survey` repo and publishes `1.0.0-rc.1` from Pass A's rulings. It is `runner` for its workflow and gate scripts and `live-account` for the public repo and the publish, uses `pass-core`'s default classes with the gate, the fast lane, and CI on PRs as the full-suite home, and runs about 460 minutes.

- **Provenance.** The repo starts from a fresh copy, without history, of the two `survey-theme/reference/` files, the 2026-10-07 spec, and its review (`docs/research/2026-10-07-survey-spec-review.md`). Its first commit names the cairn-themes commit they came from. The core CSS starts from the approval queue's vendored copy at the commit Pass A recorded, since cairn-themes never committed a core. Each header there says it was copied from `dea9839` and must not be edited.
- **Build.** The token source and three outputs, the shared CSS, the living specimen, `survey-check` and its fixtures, the two consumer fixtures the end-to-end check names, `AGENTS.md`, `CHANGELOG.md`, a PR workflow that runs the gate, and `publish.yml`.
- **Trace.** Each ruling id in Pass A's ledger maps to a token path, a DESIGN.md rule, or an "app-only, not shipped" note.
- **Leaving cairn-themes.** Only after the new repo is pushed, one cairn-themes commit removes `survey-theme/`, the Survey spec and its review, and backlog items #1 and #2, and rewrites every live pointer the 2026-10-21 fold record lists. Afterwards, `grep -rni survey` there returns only theme-port mentions. Dated records elsewhere stay as written.
- **Close.** The packet carries the built specimen for Geoff's read in Chromium, as the 2026-10-07 spec required before any consumer took the core. In the same sitting he links the trusted publisher (repo `glw907/survey`, workflow `publish.yml`, direct publish allowed) and approves the merge. The session then creates the GitHub release and runs the post-publish check.

### Pass C: workstation visual tooling

Pass C lands Survey's visual guidance in the workstation's Claude tooling, in `~/.dotfiles` under `dotfiles-pass` and the `claude-infra` rules. It is `runner`, runs about 160 minutes, needs only Pass B's packed tarball, and may run beside Pass D.

- **Skill.** A user-scope `survey` skill routes by context (a cairn site, a SvelteKit and daisyUI tool, or a token-only app) to the installed DESIGN.md and the one recipe that applies. It forbids a value the tokens don't hold. The CLAUDE.md line from PR #131 names the skill. A skill reaches only sessions that hold the Skill tool, and the agents below do not.
- **Agent lines.** `site-implementer`, `cairn-implementer`, `visual-verifier`, and `daisyui-a11y-reviewer` list no Skill tool. Each gains one line: in a repo whose nearest `package.json` lists `@glw907/survey`, run `npm ci` if needed, read the installed DESIGN.md, and follow its rules. For the two reviewers the rule grade adds to the image grade, and a rule failure is STRUCTURAL.
- **Hook.** A stdlib Python PostToolUse hook, beside `vale-hook`, fires after an edit to a `.css`, `.svelte`, or `.html` file and filters by extension before Node starts. It finds the nearest `package.json` that lists `@glw907/survey` and runs only that repo's `node_modules/.bin/survey-check`, inside a 10-second timeout. When the package is listed but not installed, it emits one line: run `npm ci` to enable Survey checks. A missing or malformed manifest exits 0 silently. Findings cover only the changed lines and go back through `additionalContext` under `vale-hook`'s 9000-character cap. It always exits 0. In the servers repo it checks only hand-written CSS, since the copied sheet is written by the build step and never edited.
- **Render rule.** `dependency-upgrade` gains the ruled line: a minor or major `@glw907/survey` bump in an app needs a full-page render in both schemes, read in the main loop before merge.
- **Acceptance.** Hook tests on the `tests/test_vale_hook.py` pattern against a scratch app that installs the packed package: an off-token edit returns context naming the token, a non-dependent repo and a `.md` edit return nothing, a checker crash still exits 0, and the run stays inside the timeout. Three should-trigger prompts and two should-not prompts in fresh headless sessions check the skill's description, the skill-creator trigger method. One headless `site-implementer` dispatch in the scratch app must read the installed DESIGN.md before its first CSS edit. `claude-tooling-sync verify` exits 0.
- **Hosts.** After the merge, pavilion runs `git pull`, `stow -R claude bin`, `claude-tooling-sync apply`, and `claude-tooling-sync verify`. On thinkpad-x1, `check-drift` reports the clone behind origin and runs `verify`, and the session there runs the same four commands.

### Pass D: the writing baseline and the verbatim move

Pass D records how today's writing system behaves, then moves its files into Survey word for word and releases 1.1.0 (ruling 4). It works in the survey repo, is `runner` for the eval runner that becomes the check every writing minor must pass and `live-account` for its workflow change and release, and runs about 590 minutes. It may start once Pass B merges. Its PR merges only after the approval queue's pass has promoted 1.0.0, because the rulings define 1.0.0 as the release candidate that pass converged on, so the writing part can't join it.

- **Snapshot.** Copy today's files at a recorded `~/.dotfiles` commit into `evals/baseline/<commit>/`: the output style, the `writing-voice` skill, the six registers, the four conventions skills, the web-content method, and the `glw907` Vale style.
- **Tasks and harness.** Three fixed tasks per surface, 42 in all, each with its facts, assertions, and rubric. `evals/README.md` and one runner script launch both arms headless with the flags above, run `tellgrader` and Vale, dispatch the judge, and aggregate.
- **Baseline.** Three runs per task. The results land in `evals/results/<date>/` as `benchmark.json` and `benchmark.md`, the layout the September benchmark used. A planted draft full of known tells must score outside every band it should, which shows the graders can tell good from bad. skill-creator's analyst warns about "assertions that always pass regardless of skill".
- **Packs.** Each pack's `pack.md` is its source file from the snapshot, checked byte for byte with `cmp`. Go's pack takes only the "Comments" section of `go-conventions`. `packs/core/` takes the output style file whole, frontmatter included.
- **Vale.** The seven `glw907` rule files become `vale/Survey/` with their content and levels unchanged. The fixture runner asserts that each failing fixture raises exactly `Survey.<Rule>` in `vale --output=JSON` and each passing fixture raises no `Survey.*` alert. The gate fails unless the number of rule files equals the number of fixture pairs.
- **Skill and build.** Pass C's `survey` SKILL.md moves to `skills/survey/SKILL.md` unchanged, beside `packs/`. The build assembles `vale/Survey/` with `packs/` and `SHA256SUMS`, `files` adds it, and `publish.yml` uploads `Survey.zip` to the GitHub release.
- **Pointer texts.** The text each workstation file will hold after Pass E (the router rows and the conventions pointers) is written into `evals/candidate/`. These are the exact bytes Pass E lands.
- **Candidate run.** Every surface runs against its baseline. Pass E switches only the surfaces that match.
- **Scratch repos.** From a clean clone, an npm scratch app installs the packed tarball, commits its copy, and runs its gate. A scratch repo without npm syncs a locally served `Survey.zip` and runs the zip diff check. Each check fails after one edit to the copy.
- **Close.** The packet carries the `survey` PR and fourteen baseline drafts, one per surface, blind, in skill-creator's viewer for Geoff to read in Chromium. His verdicts file into the eval record. On approval the session merges, creates the 1.1.0 release, and runs the post-publish check, which syncs the real release URL.

### Pass E: adoption

Pass E pins Survey 1.1.0 in the workstation and then in every other repo with prose (rulings 3 and 4). It is `runner` for the gate checks it adds, runs about 460 minutes, lands the `~/.dotfiles` PR first under `dotfiles-pass`, then one PR per repo under that repo's adapter, and sends all of them to Geoff in one packet. A repo switches only when every surface it writes matched in Pass D.

- **The workstation.** One `~/.dotfiles` PR lands the Claude-infra map's changes in this order, each commit revertable alone: the vendored `survey` entry and its gate check, the register symlinks one per commit, the router and conventions pointers for surfaces that matched, the reviewer line, the charter and tooling docs, the CLAUDE.md line, and the output style last. It deletes nothing. Every register path keeps its bytes, the baseline snapshot keeps every old file, and each switch is one commit that reverts alone.
- **Workstation acceptance.** `cmp` shows every symlinked path byte-identical to the Pass D snapshot, and each pointer text byte-identical to its file in `evals/candidate/`. `sha256sum -c` passes over the vendored packs. `claude -p "/output-style"` in a fresh session lists `writing-voice` as current; the output-styles page says the command lists the styles "and marks the current one" and works in non-interactive mode. The approval queue's gate passes while it reads the symlinked brief register. The `writing-voice` description is unchanged, so its three should-trigger and two should-not prompts from Pass C's method run once as a check. `claude-tooling-sync verify` exits 0.
- **npm channel.** cairn-cms with its `tool/` directory, 907-life, ecxc-ski, aksailingclub-org, xcathletes-org, cairn-pub, and approval-queue, whose `package.json` sits in its `approval-queue/` app.
- **Zip channel.** poplar, dubplate, drafter, phonebook, cairn-themes, servers, and initiatives. fishwright joins if it holds prose.
- **Out.** aksailingclub-legacy, which the `asc-cutover` initiative archives. Any repo found to hold no prose is listed in the PR with its reason.
- **Each repo.** Add the pin, commit the copy, and add the diff check to the gate. A repo that applied `glw907` renames `BasedOnStyles = glw907` to `Survey` and each `glw907.<Rule>` override to `Survey.<Rule>`, then deletes its `glw907` copy. A repo with no Vale today gets a pin-only `.vale.ini` that applies no style. The project CLAUDE.md names its Survey pin beside its charter line.
- **Repo acceptance.** In each repo, Vale's findings on the full tree before and after match except for the rule-name prefix. The diff check passes clean and fails after a planted edit to the copy.
- **Hosts.** After the workstation merge, pavilion runs `git pull`, `stow -R claude bin`, `claude-tooling-sync apply`, and `claude-tooling-sync verify`, then restarts its Claude Code sessions. On thinkpad-x1, `check-drift` reports the clone behind origin, and the session there runs the same steps.

### Pass F: corrections and the monthly review

Pass F builds the four correction channels and the monthly writing review (rulings 5, 6, and 7), and releases 1.2.0 for the skill's new route. It is `runner` for the harvester script and the skill route and `live-account` for the private repo it creates and its release, works in the survey repo, `~/.dotfiles`, and the ledger, and runs about 380 minutes after Pass E.

- **Ledger.** The session creates the private `glw907/survey-ledger` repo with its layout (`corrections/`, `scorecards/`, `reviews/`, and the address list) and clones it on pavilion.
- **Corrections route.** The `survey` skill gains the route in the survey repo, released as 1.2.0, and the `~/.dotfiles` PR bumps the vendored tag.
- **Harvester.** `survey-harvest` in `~/.dotfiles/bin`, with tests against a fixture queue state directory and a scratch site repo built the way the probe built one.
- **Workstation lines.** The `content-draft` trailer line and the model review's step 9.
- **Review.** `docs/writing-review/prompt.txt` and `log.md` in the survey repo.
- **Acceptance.** The corrections route takes Pass C's trigger method. The should-trigger prompts are "No, say 'sign in' there", a sentence of Claude's pasted back rewritten, and "too formal, cut the second clause". The should-not prompts ask for a new draft and correct a line of code. A chat correction writes one record, and a second harvest writes nothing new. The harvester finds a planted comment, a planted note, and a planted in-review edit in the fixture, and the draft-and-save pair in the scratch repo. `model-review-notify --dry-run` against a scratch ledger writes a scorecard, a viewer page, and a log line, and commits locally only. A second run with that scorecard present harvests and stops.
- **Order and hosts.** The survey release goes first, then the `~/.dotfiles` PR, and both close in one packet. Both hosts clone the ledger and the survey repo, then run Pass C's four commands for the workstation PR.

### Pass G: the house register

Pass G builds the house register set out in "The house register" and releases it as a minor. It is `runner` and `live-account` for the content agents follow and its release, works in the survey repo and the initiatives repo, and runs about 300 minutes. The register changes the Survey Vale style that every surface's checks run, so its release must match the baseline on all fourteen surfaces.

- **Sources.** The ledger records each source at a commit: cairn's `docs-register.md` (both briefs, the departure tables, and the rulings behind them), the Voice section of cairn's `admin-design-system.md`, cairn's `docs/internal/design/2026-06-20-editor-copyedit-conventions-research.md`, poplar's retired tidy rules (`041eb329^:internal/tidytext/` and `docs/archive/specs/2026-05-08-claude-tidy-design.md`), drafter's `stock/` files, and the Pass D packs.
- **Ledger.** `initiatives/survey-house-style/research/<date>-writing-ledger.md` holds one row per countable unit: each `##` or `###` tell heading in both of cairn's Tells sections, each row under "Deviations from the base guides", each `##` in drafter's `stock/google-tells.md`, each rule heading in the admin Voice section, each `glw907` rule, and each numbered convention in the copy-edit research. The mapped count must equal their sum. Each row is house-wide, cairn-only, or owned elsewhere, and says why. An owned-elsewhere row names its owner's path (`tellgrader` or drafter's stock) and does not ship. A cairn-only row names the cairn noun it depends on: a track, a cairn name, a page anatomy, or cairn tooling. A row with no such noun is house-wide by default. The PR body reports the count in each class.
- **The sitting.** Geoff rules the voice traits, the tone table, and every override in one sitting, each override with the base guide's text beside the proposed rule. A cairn override marked house-wide comes with cairn's ruling as evidence. Tightenings widened from cairn sit in one table with a default of "widen", and rows whose mark was unclear join it with a default of "cairn-only". Geoff can pull any row into discussion. Afterwards every departure row carries a ruling id or a carried cairn ruling with its date. Each id maps to a pack section, a departures row, a style-sheet row, or a Vale rule, and a check counts both sides.
- **Build.** `packs/core/voice.md`, the departures file, the style sheet, `LICENSES.md`, and the new Vale rules with their fixtures.
- **drafter.** If the brief's drafter decision takes the first option, a drafter run in a scratch repo shows a known sentence from a pinned pack in the assembled request, and the same run fails once that heading is renamed.

### Pass H: the packs

Pass H gives all fourteen surfaces their full packs (ruling 2). It is `runner` and `live-account` for pack content agents follow and its releases, works in the survey repo, and runs about 640 minutes. It takes surfaces in order of the latest scorecard, lowest first, and Geoff's Pass D verdicts break ties. Each pack is its own minor release that must beat its surface's baseline without hurting any other (ruling 4), so the pass can close at any pack boundary and a later pass picks up the rest. Repos take each minor through `dependency-upgrade`, whose standing rule takes every minor and patch without asking.

- **Each pack.** Write `standard.md`, `examples/base.md` after its corpus license check, `examples/house.md` from Geoff's approved writing and the ledger's public corrections, `flavor.md` from Pass G's voice file and departure rulings, `tells.md` (the `glw907` comment tells land in the comment packs), and `checks.md`. Then run the pack's evals and release.
- **The prose packs.** The Google packs cite drafter's stock and hold deltas. The `end-user` pack is written whole, and its interface-text surface generalizes cairn's admin Voice section. The `site-content` pack may name a published base here, as an improvement that must beat its baseline.
- **A pack that can't beat its baseline.** It ships nothing that round, and the pass reports it at close.

### What each app's pass inherits

These constraints go into each app's own plan. None of them is built here.

- **Bulwark.** The servers repo holds a `package.json` and lockfile that pin `@glw907/survey` exactly, and a build step copies the sheet into the theme bundle. `dependency-upgrade` measures every directory with a `package.json` (its step 1), and the pin then shows up in a sweep. Checking the live theme against the repo after a deploy or a restore is that pass's design.
- **Approval queue.** It builds and render-checks in a worktree, since the main checkout serves from `build/`. It swaps `main`'s build only when no item is pending, and keeps the old build until the new one serves. Each promoted rule leaves `app.css` in the commit that takes the package. Its four vendored headers change in that pass.
- **907.life.** Its rebuild's `engine-consult` settles how the chassis takes the package. The cairn-site recipe ships in 1.0.0 marked pending, and that pass fills it in a minor.
- **cairn's docs.** cairn's `docs-register.md` stays the authority for cairn until cairn's convergence pass merges, and no cairn surface reads Survey's packs in its place before then. That pass first diffs cairn's register from Pass G's harvest commit to its head, and carries each new row into Survey or keeps it cairn-only. It then shrinks the file to its cairn-only parts and points at cairn-cms's pinned packs. Every reader moves with it, across three repos. In drafter, `docs-page-chain.js` takes one `registerPath`, selects sections by exact heading, and pastes two scope rulings verbatim; it gains the pinned pack path as a second source. In `~/.dotfiles`, the `register-check` skill and the `cairn-register-editor`, `cairn-docs-drafter`, `prose-voice-reviewer`, `figure-verifier`, `cairn-implementer`, and `site-implementer` agents move. In cairn-cms, the `.tellgrader.json` profile and the `Cairn` Vale messages that cite "'Names' in docs/internal/docs-register.md" move. Every reader fails loudly when the pinned copy is absent and never falls back to cairn's old text.

### End-to-end check

A packed tarball, not the repo checkout, has to pass every leg.

- From a clean clone, the commands `AGENTS.md` names build all three outputs, and `lint`, the contrast check, and the `survey-check` fixtures pass.
- `npm pack --dry-run --json` lists DESIGN.md, the token JSON, the three outputs, the shared CSS, and the `survey-check` bin, and no `reference/` file.
- `fixtures/daisyui-consumer/` installs the tarball into a minimal Tailwind 4 and daisyUI 5 build whose only Survey input is the one-line import. A computed-style probe in both themes reads `--color-base-100`, `--radius-box`, and the font family against the token source, and `survey-check` fails on a planted literal there.
- `fixtures/token-only.html` loads only the CSS-variable sheet. The sheet holds zero `url(` and zero `@import`. A computed-style probe in both schemes matches rungs one to three, and the font family resolves to the system stack with the web fonts absent.
- The specimen, built from package outputs only (`survey-check` passes on its source), is screenshotted at 320, 390, 768, 1440, and 2560px in both schemes. A fresh-context `visual-verifier` grades it against `initiatives/survey-house-style/reference/<date>-amended-specimen.html` at the commit Pass B cites, with no STRUCTURAL finding.
- After the publish, in a scratch directory, `npm i @glw907/survey@<version>` installs, the installed DESIGN.md reads, `npx survey-check` fails on a positive fixture, and `npm view @glw907/survey@<version> dist.attestations` shows provenance.
- From 1.1.0 on, the pack list also holds `vale/Survey/` with every rule file, `packs/`, and `SHA256SUMS`, and no `evals/` or `tests/` file. The release carries `Survey.zip`, and `diff -r` finds its `Survey/styles/Survey/` equal to the package's `vale/Survey/`.
- After 1.1.0 publishes, a scratch repo without npm pins the release URL, `vale sync` installs the style, a planted tell raises its `Survey.<Rule>` by name, and the zip diff check passes. A scratch npm app installs the package, and its diff check passes. The vendored skill fetched at the tag passes `sha256sum -c`.
- Before Pass E switches a surface, its candidate run matches its baseline. After Pass E, every symlinked path is byte-identical to the Pass D snapshot, and a fresh headless session lists `writing-voice` as its current style.
- After Pass F, a planted chat correction, approval-queue comment, and cairn draft-and-save pair each reach the ledger once, and a dry-run review writes a scorecard with a row for each of the fourteen surfaces.

### Stops and standing answers

Each stop the run can foresee has an answer here, grouped by the pass that meets it first. The run asks Geoff only where an item says it stops. Three answers hold everywhere: a task clock stop with a traced cause resumes once at twice its estimate, and each pass runs to 1.5 times its path estimate and stops past that; repeated STRUCTURAL findings proceed on a traced cause, per `pass-core`'s loop guard, and a cause that returns after its structural fix is escalated in the PR; unrelated drift at close is noted in the PR and left.

**Pre-flight and Pass A.**

- The thinkpad-x1 check shows nothing: the vendored copy is the S1 core verbatim, and Pass A runs on three sources without asking.
- The 2-day link window lapses: the session writes STATUS and waits, and Geoff recreates the link at his next sitting.

**Pass B.**

- Contrast moves a ruled value: tune lightness within the hue family, record the old value and its ratios in the token's `$description`, and list it in the PR's `## Decisions`.
- A ruling separates the focus ring from primary: ship it aliased in 1.0.0 and record the split for a minor. The audit measures only primary as the focus ring.
- Geoff's specimen read sends changes back: a change inside the ruled scope is fixed in Pass B before the cut. One outside it is a design change and stops.
- The publish fails: fix the workflow or the link and re-run the same release; the already-published guard allows it. Never bump the version to retry.
- The post-publish check fails after a good publish: deprecate that version and cut a patch through the same workflow, without asking.
- The cairn-themes grep finds a pointer the fold record does not list: rewrite a live pointer, leave a dated record as written, and list both in `## Decisions`.

**Pass C.**

- PR #131 is still open: Pass C's branch stacks on #131's.
- The `site-implementer` dispatch skips DESIGN.md: reword the agent line once and re-run. If it still skips, escalate in the PR.
- A trigger prompt misses, in this pass or any later one: a should-trigger miss and a should-not miss get the same answer. Reword the description once, re-run, then escalate.

**Pass D.**

- 1.0.0 is not out when the PR is ready: the session writes STATUS and waits. It never cuts a writing release candidate.
- A surface misses its baseline: it keeps today's route, and Pass E leaves it unswitched. The run traces the cause, makes one structural fix, and runs again. A surface that still misses is escalated in the PR while the rest go on.
- A live file changed after the snapshot: carry the change into its pack, re-run that surface's baseline at the new commit, run its candidate again, and list it in `## Decisions`.
- The graders don't discriminate: if the planted bad draft lands inside a band, rewrite that surface's assertions once and re-run. Then escalate.
- A surface's spread is too wide to compare: when one standard deviation exceeds one rubric point, add up to two runs per task. If it is still wide, the surface's verdict is marked low-confidence in the PR or scorecard.

**Pass E.**

- A `cmp` check fails: fix the pack, never the workstation file, and cut a patch.
- The output-style check fails: revert that commit, keep the old file in place, and escalate. Everything earlier in the workstation PR stands.
- A repo holds no prose: leave it out and list it with the reason.
- A repo's Vale findings differ by more than the rule names: trace the cause. If it isn't the rename, that repo doesn't switch, and the PR escalates it.

**Pass F and the monthly run.**

- A ledger push conflicts: pull with rebase and push again. Records never share a file.
- A correction comes from a private source: it stays in the ledger and informs only generalizations.
- The other host already wrote this month's scorecard: harvest, push, and stop.
- The monthly run hits a usage limit: finish the harvest, grade each fixed task once instead of three times, and mark the scorecard partial.
- A distill proposal doesn't beat its baseline: drop it, and keep its corrections for the next run.

**Pass G.**

- A cairn rule's house-wide or cairn-only mark is unclear: it joins the sitting's table with a default of cairn-only, and a later minor can widen it.
- Geoff rejects a house-wide row: the row stays cairn-only, and the ledger records his ruling.
- The sitting leaves most rows cairn-only: ship what is ruled house-wide, however little, and report the counts at close.
- A copy-editing rule Vale can't express: its `vale:` field names the reason, it stays in the style sheet, and the PR lists it.
- The drafter leg fails: the rest of Pass G runs, the close reports the leg unmet, and the drafter fix becomes a pass of its own.

**Pass H.**

- A pack can't beat its baseline: ship nothing for it that round and report it at close.
- A surface has fewer than three house examples: Claude drafts the rest, marks each one drafted, runs it past `prose-voice-reviewer`, and shows it in the packet.
- A source's license can't be confirmed: quote nothing from it, link and paraphrase instead, and list it in `## Decisions`.

**What may escalate.** The nearest-token wording, a COSMETIC specimen finding, a trigger miss after one rewording, the `site-implementer` dispatch after one rewording, a surface that misses its baseline after one structural fix, a repo whose findings differ, the output-style switch, and Pass G's drafter leg. The contrast bar, the pack and fixture checks, provenance, the hook's exit 0, the Vale fixtures and style diff, the `cmp` checks, the private-ledger rule, and the corpus license fields never escalate.

### Risk and estimate

Pass A is `ordinary` and merges its own PR in the initiatives repo. Every other pass closes through a conductor and a packet. With no Survey adapter yet, Passes B, D, F, G, and H use `pass-core`'s default classes in the survey repo, and each plan names the gate, the fast lane, and CI on PRs as the full-suite home. Passes C and E use `dotfiles-pass` for their workstation PRs, and Pass E runs each other repo under its own adapter. Every `live-account` plan takes the three-lens review and a verification read.

| Pass | Minutes | Breakdown |
|---|---|---|
| A | 210 | as folded on 2026-10-21 |
| B | 460 | as folded on 2026-10-21 |
| C | 160 | as folded on 2026-10-21 |
| D | 590 | snapshot 20, tasks and rubrics 120, harness 60, baseline runs 70, packs 40, Vale rules 30, skill 15, build and zip 50, candidate runs 80, scratch repos 40, packet and blind sample 20, release 45 |
| E | 460 | vendored entry and check 30, symlinks 30, pointers and reviewer 45, docs 30, CLAUDE.md and style 15, workstation acceptance 30, hosts 20, inventory 20, seven npm repos 105, seven zip repos 105, findings checks 30 |
| F | 380 | ledger 20, route and trigger checks 50, harvester and tests 90, trailer line 10, review prompt 70, step 9 10, dry run 60, release and hosts 70 |
| G | 300 | sources ledger 75, sitting 40, voice file, departures, and style sheet 60, Vale rules and fixtures 50, licensing 20, match run 30, release 25 |
| H | 640 | eight code and workflow packs at 45, six prose packs at 40, releases and close 40 |

The estimates sum to 3,200 minutes, and the path is 3,040 with Pass C beside Pass D. If Geoff takes the drafter option, a 40-minute drafter pass runs before Pass G. It is `ordinary` under `pass-core`'s defaults and merges its own PR.

### Pre-flight and sittings

Geoff does two steps in the sitting where he approves this design, since neither needs a pass's output.

- [you: on thinkpad-x1, in `~/Projects/cairn-themes`, run `git status --short`, `git stash list`, `git log origin/main..main --oneline`, and `git branch -a --contains dea9839`. An error from the last command means the commit is absent. Survey work is any path under `survey-theme/`, or any commit or stash that touches one. If there is any, commit it to a new `archive/thinkpad-x1-survey` branch and push it, then `git switch main && git reset --hard origin/main`. Check: `git ls-remote origin archive/thinkpad-x1-survey` prints a line, or nothing was found.]
- [you: run `npm login` with 2FA. In the placeholder directory the session that sends this design stages (its `package.json` carries `"publishConfig": {"access": "public"}`, and its README says it is a placeholder), run `npm publish --access public`, then `npm deprecate @glw907/survey@0.0.0 "Placeholder; install 1.0.0 or later"`. Set "Require two-factor authentication and disallow tokens" on the package. Check: from a logged-out shell, `npm view @glw907/survey version` prints `0.0.0`, and `npm access get status @glw907/survey` reads `public`.]

Three more sittings follow: Pass A's rulings, Pass B's close (the specimen read, the trusted-publisher link, and the merge approval), and Pass G's voice and departure rulings. Pass D's blind read of fourteen baseline drafts rides on its close packet. Passes C, D, E, F, and H close on a merge packet each, and Pass F's monthly review adds one packet a month when it has generalizations to propose. The blind sample page arrives each month at normal urgency and asks for six verdicts. Pass F's host steps on thinkpad-x1 (cloning the ledger and the survey repo) are a session's, not Geoff's.

### Left to the builder

The token names, Style Dictionary's configuration, the specimen's harness, the skill's wording, and the CSS-variable sheet's prefix are all left to the builder. So is how the recipes split between the skill and DESIGN.md. On the writing side, the builder words the eval tasks and the router rows, picks the judge model once and records it, and sets the ledger record's exact field names and the scorecard's layout.

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
- Google developer documentation style guide: <https://developers.google.com/style>
- Microsoft Writing Style Guide: <https://learn.microsoft.com/style-guide/welcome/>
- Microsoft Writing Style Guide source and its CC BY 4.0 license (archived): <https://github.com/MicrosoftDocs/microsoft-style-guide>
- Mailchimp content style guide, voice and tone: <https://styleguide.mailchimp.com/voice-and-tone/>
- Atlassian design system, voice and tone principles: <https://atlassian.design/content/voice-and-tone-principles>
- Shopify Polaris, voice and tone: <https://polaris.shopify.com/content/voice-and-tone>
- Nielsen Norman Group, the four dimensions of tone of voice: <https://www.nngroup.com/articles/tone-of-voice-dimensions/>
- Anthropic, Claude prompting best practices: <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>
- Anthropic, skill authoring best practices (evaluation-driven development): <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>
- Anthropic, define success criteria and build evaluations: <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Anthropic's skill-creator plugin (snapshot baselines, `aggregate_benchmark`, the review viewer): `claude-plugins-official/plugins/skill-creator/skills/skill-creator/SKILL.md`
- Michael Feathers, characterization testing: <https://michaelfeathers.silvrback.com/characterization-testing>
- Git trailers: <https://git-scm.com/docs/git-interpret-trailers>
- The authoring charter: `~/.claude/docs/authoring-charter.md`
- drafter's prompts module and register settings: `drafter/docs/prompts-module.md`, `drafter/docs/configuration.md`
- Claude Code features overview: <https://code.claude.com/docs/en/features-overview>
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Claude Code output styles: <https://code.claude.com/docs/en/output-styles>
- Claude Code hooks: <https://code.claude.com/docs/en/hooks>
- Chrome DevTools MCP design principles (self-healing errors): <https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/design-principles.md>
