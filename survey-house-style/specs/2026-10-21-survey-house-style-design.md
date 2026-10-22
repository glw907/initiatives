# Survey house style: design

## Brief

This makes Survey the one house style for every house tool, in how it looks and in how Claude writes, published as a versioned package that each repo pins and follows through ordinary dependency updates.

Survey's visual style now exists in three places that have drifted apart: the approval queue's vendored copy, the 2026-10-07 spec, and its approved specimen. Bulwark webmail and the phonebook's UI both wait on it, and 907.life will take it in its rebuild. The writing voice works well today, but it lives in a dozen workstation files with no version, no regular grade, and no easy path for your corrections.

### What changes

- A new public `survey` repo holds Survey's tokens, principles, shared CSS, specimen, writing packs, and changelog, and publishes them to npm.
- One token source builds a drop-in daisyUI theme, a plain CSS-variable sheet, and a DESIGN.md that agents read first.
- A conformance check, built on stylelint, ships in the package and names the token to use in place of any stray value.
- One `survey` skill, preloaded by four agents, and an advisory hook point every agent at the Survey version its repo installed.
- Survey is also the writing reference: one context pack for each kind of writing, from Go comments to blog posts, each built on its published standard first.
- The writing move is measured. Each kind of writing gets fixed eval tasks, today's system sets the baseline, and nothing switches until it matches.
- Every repo with prose pins one Survey version, through npm or a release zip, so a rollback is one line.
- Your corrections in chat, in the approval queue, and in the cairn editor reach a private ledger with no extra step from you.
- A monthly review grades the writing and turns your corrections into examples and rules.
- Each app moves to the visual package later, in its own pass.

### If you approve

1. You do two pre-flight steps in this sitting: check thinkpad-x1 for unpushed Survey work, and reserve the npm name with a placeholder.
2. Pass A compares the three visual versions and brings you the differences and proposed additions in one sitting.
3. Pass B builds the repo and the `survey` skill from your rulings and publishes `1.0.0-rc.1`. At its close you read the built specimen, link the trusted publisher on npmjs.com, and approve the merge.
4. Pass D records how today's writing system performs, cairn's docs included, moves the writing files into Survey word for word, opens the private ledger, and releases 1.1.0 once 1.0.0 is out. Its packet carries fifteen baseline drafts for a blind read.
5. The approval queue takes `1.0.0-rc.1` in its own pass, and that pass's close promotes 1.0.0.
6. Pass G builds the house register and releases 1.2.0. You rule the voice traits and every departure in one sitting.
7. Pass E lands Survey on the workstation in one PR, with the output style last, then pins it in every other repo with prose except 907.life. cairn's docs move onto the Survey register in the same pass. One packet carries every PR.
8. Pass F starts the four correction channels and the monthly writing review, and releases 1.3.0.
9. Pass H fills the twelve packs with examples and house flavor, weakest first. Each is a minor release that must beat its baseline.
10. The phonebook, Bulwark, and 907.life's rebuild each take Survey in a pass of their own.

### Decide: How often the monthly review re-grades the fixed tasks

A full grade of the fixed tasks drafts 135 pieces and makes about 270 judge calls. In a month when the workstation's Survey version, the drafting model, and the judge are all unchanged, a re-grade measures only noise. Real writing and your six blind pieces are graded every month under either option.

Source: contract review finding 21, mechanics review o4, integrity review finding 20

- Re-grade only in a month when the Survey version, the drafting model, or the judge changed, and carry the last grade forward otherwise (recommended)
- Re-grade every month

### Decide: How the workstation takes new Survey releases

Repos take a Survey minor in their dependency sweeps. The workstation's output style, router, and packs follow a vendored tag instead, and nothing moves that tag after Pass F, so improvements would stop short of the writing you read most. Your standing rule sends every bump through `dependency-upgrade`, takes minors and patches by default, and asks you before a major. The first option keeps the asking and is a recorded exception to that route; the second follows the rule as written. Every option keeps `git revert` of the tag commit as the rollback.

Source: integrity review finding 9, mechanics review M3, the verification read's major 3

- The monthly review moves the tag to the newest minor or patch before it grades, as a gated `~/.dotfiles` commit with no packet, and a major goes to you in that month's packet (recommended)
- `dependency-upgrade` moves the tag in a workstation sweep, as it moves any repo's pin
- Each tag move comes to you in a packet

### Decide: Whether drafter stops a run when a Survey section is missing

drafter can read Survey's packs today, because each repo commits its pinned copy and drafter inlines any tracked file. A section token whose heading has gone yields only a "no heading" note, and the run goes on. A Survey release that renamed a section would then draft with part of its context missing and look normal.

Source: drafter's `internal/assemble/section.go` and `files.go` at `568c262`

- A short drafter pass, about 40 minutes, makes a missing file or heading under a Survey path fail the run (recommended)
- No drafter change: each repo's gate checks that every section its prompts module names exists in its pinned copy

### Worth knowing

The work is seven passes and 4,245 minutes of estimates, plus 40 for drafter if you take that option. Review raised the figure from 3,200: Pass H's twelve packs each carry their own eval run, the baseline gains a knockout arm, a reply surface, and two cairn surfaces, and Pass E now also carries the workstation's visual tooling and cairn's register move. Pass G now runs before Pass E, so cairn's docs have a ruled register to move onto. The passes run one after another, so the path equals the sum. One ask recurs: a blind sample of six pieces each month, read on a page in Chromium. An occasional second one is an `npm deprecate` line in a packet, since only your login can deprecate a version. cairn-themes keeps its theme ports and gives up `survey-theme/`, its Survey spec, and its backlog items #1 and #2 to the new repo.

### Rulings

These rulings stand and are not reopened. Survey is published from a public repo to npm as `@glw907/survey`, with trusted publishing, the way cairn is. Bulwark's theme waits until this work is complete. Survey is agent-friendly from the ground up, joins the workstation's Claude tooling, is versioned with a changelog, follows established practice, and includes a drop-in daisyUI theme (Geoff, 2026-10-21).

Geoff took all four review recommendations on 2026-10-22. Pass B publishes `1.0.0-rc.1` under `next`. The approval queue converges on that exact version, and a short release step at that pass's close promotes 1.0.0 with any names it changed. The other apps and Bulwark start from 1.0.0. The trusted publisher allows a direct publish, as cairn's does. Every minor or major Survey bump in an app needs a full-page render in both schemes, read in the main loop before merge, and the workstation pass (now Pass E) adds that line to `dependency-upgrade`. Pass A renders a difference at or above ΔE2000 2 for color, 2px for length, or 50ms for duration. The rest sit in one table with a default that Geoff can pull into a render, and every proposed promotion is rendered.

On the same day Geoff added the house writing register and its copy-editing rules to Survey. The register may sit over Google's or Microsoft's voice, and its corpus follows drafter's established shape. When this work is done, cairn uses the Survey register.

Geoff then ruled seven points on the writing part (2026-10-22):

1. **Base standard first, Survey flavor second.** Every writing context is first a good instance of its own published standard, and Survey adds house flavor only where the base leaves room. The contexts are Go, TypeScript, Svelte, and Python comments; commits and PR bodies; approval briefs; agent-facing files; developer docs; end-user docs, help dialogs, and interface text; and site content, blog posts included, with each site's content guide as its overlay. This replaces the non-goals that excluded code comments, commits, agent-facing files, and website content. The charter's "website content is the one personal voice" becomes: site content is a Survey context whose overlay is the site's own guide.
2. **Enough context for each context.** Each one gets a pack: the base standard as positive rules with reasons and links, canonical examples from the base's own corpus (license-checked), three to five tagged house examples per surface, Survey's flavor and any departure with its ruling, before-and-after tells with the after first, the checks, and a small eval set graded against the rubric. Geoff's approved writing is the richest source of house examples.
3. **Other projects use Survey as their writing reference.** Adoption is its own pass and covers every repo with prose, the Go repos without npm, the workstation, the phonebook, cairn, and its sites included. Repos without npm get a second channel: a versioned zip release asset that Vale loads by URL, plus the vendored-skills channel for the skill. The `glw907` tells move into Survey's packs. The Pass D fold's recommendations to keep `glw907` outside Survey and to govern only npm repos are superseded.
4. **Do not break what works.** The migration preserves behavior first: build each context's eval set and run it through today's system for a baseline, with a small sample shown to Geoff; move content into Survey verbatim and turn today's files into thin pointers; re-run the evals, and a context passes only if it matches its baseline, with no repo switching until its contexts pass; keep the old files until the new path has run cleanly, and pin Survey in each repo so rollback is one line. Improvements come after, each as its own minor that must beat its context's baseline without hurting any other.
5. **Corrections must be easy to take.** Three channels feed one ledger: chat (a `survey` skill route records before, after, context, and reason when Geoff corrects wording), the approval queue (a harvester reads his prose edits and comments), and notes he attaches to items. The ledger is private and never lands in the public repo; only distilled, sanitized results are published. A recurring distill step groups corrections by context and proposes examples, sharper rules, or Vale rules, each of which must beat its context's baseline. A generalization goes to Geoff as one packet, and an example taken directly from his correction ships without asking.
6. **A fourth channel: the cairn editor.** Geoff may have Claude draft a blog post, then correct it in the cairn editor. The intake asks nothing extra of him. Those corrections feed the site-content pack, and the private-ledger rule holds.
7. **Grade the writing periodically.** Each context is graded on its fixed eval tasks and on a sample of real writing shipped since the last run, scored with the rubric, `tellgrader`, and Vale, plus a small blind sample Geoff reads. Results go to a dated scorecard with a trend per context. A context that drops opens a backlog item, and the distill step works on the lowest-scoring contexts first. The design reuses the workstation's monthly reviews and stays the minimum that gives a trend Geoff can trust.

Four more rulings followed on 2026-10-22. First, Survey's design is as simple and clean as possible, so it is easy to maintain, use, and improve. Of two ways to close a gap, the simpler one wins; the smallest standard mechanism is preferred; detail the builder can settle is left out; and each thing is said once. Second, Survey does not ship as a Claude Code plugin. Its one audience is Geoff, and the workstation's manifests and `claude-tooling-sync` already install skills, hooks, and output styles on both hosts; a Survey plugin is a later item for the shared-standards initiative. Third, 907.life gets its full rebuild once cairn's docs are complete, so nothing here waits on it. The cairn-site recipe stays pending until that rebuild, 907.life adopts Survey in it, and its existing posts may still serve as site-content examples, read from the repo as it is. Fourth, cairn's docs move to the Survey register in Pass E as designed, during the ongoing cairn docs effort. The small risk to partly drafted pages is acceptable, and the move stays behind the baseline match.

### Intent and goals

Every house tool should read as one family, and every piece of Claude's writing should read as one voice over its own standard. Where we hold every lever (the approval queue, the phonebook, 907.life's cairn layer), the tool carries Survey's felt craft. Where an app exposes only a few levers, such as Bulwark, it is still recognizably Survey. An agent working in any of these contexts applies Survey correctly without being briefed. Each app follows Survey as it improves, through a version bump and a changelog that says what to do. Claude's writing in any repo is a good instance of its published standard with one recognizable house flavor, and it gets better each month from Geoff's corrections without his doing anything extra.

None of the three existing visual versions is the reference. Each looks good, and each may change a little to match the principles this work writes down (Geoff, 2026-10-21).

The work has seven goals.

- One written house style: principles, tokens in light and dark, and per-context recipes.
- One context pack per kind of writing, each a good instance of its base standard first.
- A ladder of levers ranked by how much resemblance each carries, so a partial adopter knows what to take first.
- Releases under Semantic Versioning, each with a changelog entry that names the consumer's action.
- One pinned Survey version in every repo with prose, read by agents, drafter, and Vale alike.
- A grade per writing surface with a trend Geoff can trust, and corrections that reach the packs with no extra step from him.
- Agent-friendly from the ground up: version-matched docs, role-named tokens, a conformance check with fix-naming messages, and upgrade steps an agent can carry out.

Six things stay out of scope.

- Restyling the cairn admin. It keeps its own design system.
- Packaging Survey as a selectable cairn theme (cairn-themes S3, cairn's work).
- The terrain hero from elevation data.
- Building any app's visual convergence inside these passes. Each is the app's own pass, and 907.life's is its rebuild.
- Grading writing that people wrote. The system grades Claude's drafts, since the charter is "not a quality gate for human-written content".
- Replacing a base standard's own linter (gofmt and go vet, ESLint, ruff, commitlint, the brief check) or `tellgrader`. Survey's Vale rules sit beside them.

Four outcomes would mean the work failed: a style that only works where every lever exists, which leaves Bulwark-class apps generic; copies that drift, where an app can't tell which Survey it has or what changed since; rules an agent has to infer from CSS, or values it is free to invent; and a migration that changes writing that works before anyone has measured it.

### The shape of the work

Survey has two halves, a visual system and a writing system, and they share one repo, one version line, one release workflow, one set of channels, and one `survey` skill. The visual half is tokens, outputs, shared CSS, a specimen, and the conformance check. The writing half is the context packs, the Vale style, the evals, the correction ledger, and the monthly review.

Seven passes build it. Each row names the pass, its outcome, the repos it edits, its highest risk class, and its estimate. The classes follow `pass-core`: `runner` for skills, agents, workflows, and gate tools, and the `live-account` flag for a run that creates a repo or publishes to npm. The letters keep their earlier meaning. There is no Pass C: its workstation tooling now lands in Pass E's one workstation PR.

| Pass | Outcome | Repos | Class | Minutes |
|---|---|---|---|---|
| A | One ledger of visual rulings and an amended specimen | initiatives | `ordinary` | 210 |
| B | The public repo, the package, the `survey` skill, and `1.0.0-rc.1` | survey, cairn-themes | `runner`, `live-account` | 520 |
| D | A baseline for every writing surface and for cairn's docs, the verbatim move, the ledger, and 1.1.0 | survey, survey-ledger | `runner`, `live-account` | 720 |
| G | The house register: voice, departures, style sheet, Vale rules, licenses, and 1.2.0 | survey, initiatives | `runner`, `live-account` | 360 |
| E | The workstation and every repo with prose pinned to Survey, and cairn's docs on the Survey register | ~/.dotfiles, thirteen repos | `runner`, `live-account` | 870 |
| F | Four correction channels, the monthly review, and 1.3.0 | survey, ~/.dotfiles, survey-ledger | `runner`, `live-account` | 485 |
| H | Twelve full packs, each a minor that beats its baseline | survey | `runner`, `live-account` | 1,080 |

The order is A, B, D, the approval queue's own pass to 1.0.0, then G, E, F, and H. Pass D may start once Pass B merges, and its release waits for 1.0.0. Pass G needs only Pass D's packs and rules, and its match runs against Pass D's stored baselines. Pass E needs Pass G's 1.2.0, since cairn's docs move onto the register Pass G rules. Pass F needs the vendored skill that Pass E lands, and Pass H follows it. The drafter pass, if taken, is 40 minutes in the drafter repo, `ordinary`, and runs before Pass G. No recent score covers theme or writing-system work, so each planner checks its figure against its plan.

### The lever ladder

An app adopts from the top down, as far as its theming surface allows. Palette carries the most resemblance and is the first rung: paper, ink, and water in light and dark, with the status colors. Shape comes next, meaning radii, 1px borders, no shadows, and the focus ring. Type is the third rung: Spectral, Karla, and Monaspace Neon, with a named system-font stack for apps that can't load web fonts. Motion is the fourth, and the signature details are the fifth (contour texture and rules, benchmark triangle, margin collar, index rail, the frame). Full-lever apps take all five rungs. Bulwark takes rungs one to three, because its theme filter strips `url()`.

### Token source and outputs

One DTCG 2025.10 file is the source, and Style Dictionary builds the three outputs from it. Style Dictionary 5.7.0 read DTCG 2025.10 colors, dimensions, durations, shadows, and cubic Béziers in the mechanics probe, though its docs say 2025.10 "does not have full support yet". The probe also showed it silently drops a group that uses `$extends` and ignores `$deprecated`.

- **Source.** A base group plus `light` and `dark` groups, filtered per platform. `$extends` is not used. Style Dictionary is pinned to an exact version. Each token is named for its role (`paper`, `ink`, `water`, `focus-ring`), never a raw value, and the build fails on a token without a `$description`. The focus ring aliases the primary color in 1.0.0, the role `theme-contrast` measures at 3:1.
- **daisyUI theme.** Light and dark `@plugin "daisyui/theme"` blocks and the `@theme` scale, imported in one line after `@plugin "daisyui" { themes: false; }`. The mechanics probe compiled this from a packed tarball under Tailwind 4.3.3 and daisyUI 5.7.50. The output keeps the names `theme-contrast` reads: `--color-muted`, `--cairn-{info,success,warning,error}-ink`, and `--color-primary` as the focus ring. It is the default recipe for a new house tool, since Geoff builds most tools on daisyUI.
- **CSS-variable sheet.** Light values in `:root`, dark under `@media (prefers-color-scheme: dark)` and under the dark `data-theme` value. It holds no `url(` and no `@import`, and a header comment names the package version.
- **DESIGN.md.** Google Labs' format: tokens in front matter, principles in prose, ending in "Do's and Don'ts". `@google/design.md` 0.4.0 is alpha, has no dark-scheme concept, and only warns on contrast (a 1.08:1 pair exited 0 in the probe). So the front matter holds the light set and a `components` list of the real pairs, the dark set lives in prose, the CLI is pinned exactly, and the gate fails on any `lint` error. Each principle is one imperative sentence a check or a reviewer can test, paired with its "Do's and Don'ts" entry.
- **Shared CSS.** The component overrides and signature details stay hand-written under the existing `site-*` and `--site-*` prefixes, each with its component and reason beside it (the DaisyUI-first rule).
- **Package shape.** `daisyui ^5` and `tailwindcss ^4` are peer dependencies; the Fontsource fonts, stylelint, and `postcss-html` are dependencies. `exports` names each CSS file, DESIGN.md, the token JSON, and the stylelint config. `bin` names `survey-check`. `files` adds `skills/survey/` from 1.1.0 and leaves out `reference/`, `evals/`, and `tests/`.

### Contrast

`npx cairn-audit --rule theme-contrast --fail-on advisory` is the contrast check of record. Its public-scope findings are advisory, and only `--fail-on advisory` makes them exit 1 (`cairn-cms/src/lib/audit/bin.ts:5-7`). A committed `cairn-audit.config.json` imports Tailwind, `cairn-public.css`, and the built daisyUI output, with `@glw907/cairn-cms` as a dev dependency, as the 2026-10-07 spec set up. Every measured pair meets WCAG AA at 4.5:1 and the focus ring meets 3:1, in both schemes and in sRGB and display-p3. To show the audit measures something, a planted low-contrast value in a scratch copy must make it exit 1.

### The conformance check

`survey-check` is a thin wrapper over stylelint with Survey's plugin and shared config, which is how Primer, Polaris, Atlassian, and Mozilla ship token linting. Its messages name the fix, following the self-healing error pattern in the Chrome DevTools MCP design principles. Probe (2026-10-22, stylelint 17.16.0 and `postcss-html` 2.0.0): a plugin rule flagged a hex literal in a Svelte `<style>` block and in an inline `style=""`, honored a `stylelint-disable-next-line` comment with its reason, and exited 2 with JSON findings.

- **Surfaces.** `.css` files, and Svelte and HTML `<style>` blocks and inline `style=""` through `postcss-html`. The wrapper adds the one surface stylelint can't parse: Tailwind class strings, for arbitrary values such as `bg-[#fff]` and the stock utilities that set a shadow or a duration.
- **Literals.** It flags every color, radius, shadow, and duration literal outside the package's own sheets, including one equal to a token's value. The message gives `file:line`, the literal, and the matching token. When none matches, it names the nearest token of the same type (ΔE2000 for color, absolute difference otherwise), or says "no token fits" and names the DESIGN.md section.
- **Names.** A deprecated Survey token is a warning that names its replacement, read from `$deprecated` in the shipped token source. An unknown name under Survey's token prefix or `--site-*` is an error.
- **Exemptions.** `transparent`, `currentColor`, `inherit`, `0`, `none`, and declarations inside a `prefers-reduced-motion` block pass. stylelint's own `/* stylelint-disable-next-line survey/<rule> -- <reason> */` covers the rest. The approval queue's `frame.css` mask gradient (line 295) and bar shadow (line 9) are the cases that need it.
- **Fixtures.** One flagged literal per category on each surface, a literal equal to a token value, a deprecated alias, an unknown name, a disable comment, and a clean file. Each flagged fixture exits non-zero with the message shape above, and the clean file exits 0.
- **On a cairn site.** cairn-audit's literal rules stay the gate of record, and each site's own convergence pass decides whether `survey-check` also runs there.

### Agent-friendly by construction

Agents are Survey's main users, so every part of it is built to be read and checked by one (Geoff, 2026-10-21). The `survey` skill is the agent-facing entry. It routes a visual task to the installed DESIGN.md and the one recipe that applies, holds the packs, and from Pass F carries the corrections route. Writing tasks keep the `writing-voice` router under its own name, since renaming it would change its triggers and break `prose-voice-reviewer`'s `skills:` preload.

- **Agents get the skill without a trigger.** `site-implementer`, `cairn-implementer`, `visual-verifier`, and `daisyui-a11y-reviewer` list `survey` in their `skills:` frontmatter. Claude Code's subagent docs say "The full skill content is injected, not only the description", and the field works without the Skill tool in `tools`. For the two reviewers the rule grade adds to the image grade, and a rule failure is STRUCTURAL. The main loop finds the skill by its description, and the hook catches what it misses.
- **The docs travel with the version.** The npm package ships DESIGN.md, the token JSON, and from 1.1.0 the skill directory with its packs and Vale rules. An agent reads `node_modules/@glw907/survey/DESIGN.md` for the exact version installed. In a fresh worktree it runs `npm ci` first and never falls back to the GitHub copy.
- **Upgrades an agent can do.** Each changelog entry names the consumer's action as a concrete step, such as "replace `--survey-shade` with `--survey-paper-2`". A deprecated token stays as an alias until the next major.
- **A map for working on Survey itself.** The repo carries an `AGENTS.md` (the open agents.md format) with its build, gate, and release commands.
- **No MCP server.** The skill and the shipped files carry the same content without a running service.

### Versioning and release

Survey follows Semantic Versioning 2.0.0. One policy covers tokens, the checker, and the writing part.

- **Tokens** follow Adobe Spectrum's token policy. Renaming or removing a token, or changing its type, is major, and it ships first as a deprecated alias in a minor. A new token, rule, or intentional value change is minor, and a fix with no visible change is a patch.
- **The checker** follows ESLint's README. A bug fix that reports more errors is minor, while an addition to the default rule set that may report new errors is major. A stricter check can also ship as a warning in a minor and become an error at the next major.
- **Writing** uses the `writing` rung. A changed tell, rule, or example is minor. Removing or renaming a pack, a surface, or a section heading is major. A new Vale rule, or a changed pattern, that can report new findings at `error` is major, or ships first as a `suggestion` in a minor. Raising a rule's level is major at `error` and minor below it, and each rule's failing fixture pins its level. A `suggestion` still reaches agents, since every house config sets `MinAlertLevel = suggestion` and `vale-hook` returns suggestions.
- **Changelog.** A hand-kept `CHANGELOG.md` in Keep a Changelog 1.1.0, with a `## [Unreleased]` section. Each entry names its rung (palette, shape, type, motion, signature, tooling, or writing) and the consumer's action, or "none". Changesets is not used: version 3.0.3 hard-codes headings that are not Keep a Changelog's, and its version PR adds a manual step per release.
- **Release gate.** Before tagging, the release step compares the token JSON with that of the newest published version that ships one, by path and type. It is skipped for prereleases and for 1.0.0, whose promotion may change names under the rulings. It fails when a token is removed or retyped outside a major, when a renamed token has no `$deprecated` alias, or when a changed token has no line under `## [Unreleased]`. It also fails when the version is already on npm, so two sessions can't both claim one number. This is Spectrum's token-diff step without Changesets.
- **Release.** The session creates each GitHub release with `gh release create`, attaching `Survey.zip` from 1.1.0, so every asset is in place before the release becomes immutable. Immutable releases are on for the repo before its first release; GitHub's docs say attached files "are protected from modification or deletion". `publish.yml` is copied from cairn's: it runs on a published release or a manual dispatch, never on a push, and keeps cairn's `contents: read`. It pins npm 11 (npm 12.0.0 shipped without sigstore), passes `--provenance`, derives the dist-tag from the version (`next` for a prerelease), and skips a version already published so a fixed workflow can re-run. Its publish job refuses any ref but `main` or a tag on `main`. `repository.url` matches the repo exactly, and the job runs Node 22.14 or later, as trusted publishing requires.
- **First publish.** npm cannot bind a trusted publisher to a package that does not exist, which is why cairn's first publish was by hand (`cairn-cms/.github/workflows/publish.yml:92`). So Geoff publishes a `0.0.0` placeholder at pre-flight and deprecates it at once. The release candidate goes to `next`, so `latest` stays on the placeholder until 1.0.0. A new trusted-publisher link "must complete its first successful publish within 2 days", so he makes the link in Pass B's close sitting and the release runs the same day.
- **Rollback.** A bad version is superseded by a patch the session publishes, never unpublished. Its `npm deprecate` line goes to Geoff in the next packet: trusted publishing covers `npm publish` and dist-tag operations only, and the package disallows tokens. A consumer rolls back by moving its one pin.

### Channels and pins

A repo pins exactly one Survey version, and every reader in it uses that version (ruling 4). Visual consumers pin through npm alone. The writing part lives in one directory, `skills/survey/` in the survey repo: `SKILL.md`, `packs/`, the Vale rules, and a committed `SHA256SUMS` that the survey gate regenerates and diffs. That one directory is the vendored skill (the vendored-skills channel copies only files under a skill's path, `fetch_skill` in `~/.local/bin/claude-tooling-sync:397-421`), the Vale style, the npm package's `skills/survey/`, and the release's `Survey.zip`. Probe (2026-10-22, Vale 3.24.0): a style directory holding `SKILL.md`, `SHA256SUMS`, and `packs/` raised its rule by name and ignored the other files.

One checksum check serves every committed copy: `sha256sum -c --strict` from the copy's directory, a check that the directory holds no file the list omits, and a check that the directory's `VERSION` file, which `SHA256SUMS` lists, names the version the repo pins (the version in a zip repo's URL, or the workstation's tag). In the probe, an extra file passed `sha256sum -c` alone and failed the second check. The survey gate checks that `VERSION` matches `package.json`.

- **Repos with npm.** The repo lists `@glw907/survey` in `package.json`, as a devDependency where only writing uses it. It commits a copy of `skills/survey/` as `<StylesPath>/Survey/`, and its gate fails when `diff -r` finds the copy differs from the installed package. Probed under Vale 3.24.0: the committed style raised `Survey.<Rule>` by name, and the diff exited 0 in sync and 1 after one edit.
- **Repos without npm.** `.vale.ini` names the release asset in `Packages` as `https://github.com/glw907/survey/releases/download/v<version>/Survey.zip`, the repo commits what `vale sync` installs, and its gate runs the checksum check offline. Immutable releases keep the bytes behind a pinned URL fixed. Probes: `vale sync` installed a version-pinned GitHub release zip (`errata-ai/Google` at `v0.7.1`), and a `.vale.ini` that names the zip but applies no style raised nothing and exited 0, so a pin alone adds no findings.
- **The workstation.** `vendored-skills.json` names the `survey` skill with its `branch` set to a release tag. `fetch_skill` accepted a tag in the probe. It now builds each vendored skill in a temporary directory on the same filesystem, outside the stow package, applies overlays there, swaps it in with `mv -T --exchange`, and removes the old copy, so a failed fetch changes nothing and a removed file goes. Probe (2026-10-22, coreutils 9.10): `mv -T --exchange` swapped two non-empty directories on tmpfs and on the home btrfs, and without `-T` it failed. The dotfiles gate runs the checksum check over the vendored copy.
- **Where a session reads a pack.** The `writing-voice` router reads the repo's committed `<StylesPath>/Survey/packs/` when the repo pins Survey, and `~/.claude/skills/survey/packs/` otherwise.
- **drafter.** drafter inlines any file git tracks inside the repo (`resolve` in `internal/assemble/files.go`), so it reads the committed copy with no change. The brief's drafter decision covers a missing section.
- **Taking a release.** `dependency-upgrade` gains a Survey step. In an npm repo it refreshes the committed copy from the installed package after the update. In a zip repo it moves the URL to the new version and runs `vale sync`. The workstation follows the brief's decision.
- **Rollback.** A repo moves its one pin back through the same step. The workstation reverts its tag commit with `git revert`, which is offline and leaves no stale files, since vendored files are committed.

The vendored notes on `vale-ci` and `vale-fix` say not to run `vale sync` against a committed styles directory, and npm repos never do. A zip repo runs it only when it moves its pin, and pins any other package on its `Packages` line by URL as well, so a sync never moves a style it didn't mean to.

### Writing contexts

Every kind of writing Claude does here is a context, and each starts from its published standard (ruling 1). A context has one pack. A surface is a kind of output inside it that gets its own eval tasks, so `end-user` has three surfaces and most packs have one. Pass D moves each pack from the workstation file named here, word for word.

| Pack | Base standard | Base linter | Moved from | Surfaces |
|---|---|---|---|---|
| `go-comments` | Go Doc Comments, Effective Go | gofmt, go vet | `go-conventions`, its "Comments" section | Go comments |
| `ts-comments` | TSDoc | ESLint with jsdoc and tsdoc | `ts-conventions`, its body | TypeScript comments |
| `svelte-comments` | TSDoc and the Svelte `@component` convention | ESLint with jsdoc and tsdoc | `svelte-conventions`, its body | Svelte comments |
| `python-comments` | PEP 257, PEP 8 | ruff `D` | `python-conventions`, its body | Python docstrings and comments |
| `commits-and-prs` | Conventional Commits and the git-commit canon | commitlint, optional | `voice/commit-and-pr.md` | commit messages, PR bodies |
| `approval-briefs` | inverted pyramid, Federal Plain Language Guidelines, NN/g | `check-brief.ts`, `packet --check` | `voice/approval-brief.md` | packets and briefs |
| `agent-facing` | Anthropic's Claude Code and prompting guidance | none | `voice/agent-facing.md` | skills, agents, CLAUDE.md |
| `dev-docs-go` | Google developer documentation style guide | Vale `Google` | `voice/technical-doc-go.md` | docs in Go repos |
| `dev-docs-web` | Google developer documentation style guide | Vale `Google` | `voice/technical-doc-web.md` | docs and changelogs in web repos |
| `end-user` | Microsoft Writing Style Guide | Vale `Microsoft` | `voice/editor.md` | end-user docs, help dialogs, interface text |
| `site-content` | the shared web-content method, under each site's content guide | the site's Vale config | `docs/web-content-method.md` | one surface: blog posts, pages, and form copy |
| `core` | the audience-invariant tells | `tellgrader`, Vale `Survey` | the `writing-voice` output style and the `glw907` Vale style | replies, and every context |

That makes eleven packs, `core`, and fifteen surfaces. The `voice/` paths are under `~/.claude/docs/`, and a conventions skill's body is everything below its frontmatter. A house tool's interface text is the `end-user` context. A site's form copy, labels, and errors belong to `site-content` under the site's own guide, so no site surface has two owners. Today's site-content base is the shared method, which cites no external standard. Naming a published base for it is an improvement for Pass H that must beat its baseline. As the charter has it, cairn's docs voice is cairn's overlay above `dev-docs-web` and `end-user`, and Pass E's cairn step moves it onto Survey's packs.

### Context packs

A context pack holds what a session needs to write well in one context (ruling 2), in one file, `pack.md`. Every pointer, symlink, and router row names that file, so it never moves. Pass D fills it with today's text byte for byte. Pass H then gives it the full shape as sections, in this order, and keeps every heading the file already has, since removing one is major.

- **Standard.** The base standard as positive rules, each with its reason and a link. Anthropic's prompting guide says to "tell Claude what to do instead of what not to do" and to give the reason behind an instruction.
- **Base examples.** Canonical excerpts from the base's own corpus, each with its URL, license, and retrieval date.
- **House examples.** Three to five per surface in `<example>` tags. The same guide calls examples "one of the most reliable ways to steer Claude's output format, tone, and structure" and says "Include 3–5 examples for best results".
- **Flavor.** Survey's flavor where the base leaves room, and each departure with its ruling id. Its first line points at `packs/core/voice.md`, so the voice traits have one home.
- **Tells.** The before-and-after pairs, after first. The `glw907` comment tells land in the comment packs here (ruling 3).
- **Checks.** The base linter's command and the Survey Vale rules that apply.

The `core` pack's `pack.md` is the output style itself and keeps its frontmatter. House examples come from Geoff's approved writing in public repos: merged docs, PR bodies he approved (the approve verdicts in `decisions.jsonl` lead to them), his posts, and his corrections. Survey publishes only text that is already public. Each house example is either sourced or marked `drafted`. A sourced example names a GitHub permalink (a file at a commit, or a merged PR), and the survey gate checks with `gh repo view --json visibility` at release time that the repo is public; a source it can't resolve counts as private. A `drafted` example is one Claude wrote in the public repo, so it needs no source, and the gate passes it only when it carries no ledger id, so a private correction can't be relabelled to get through. Each pack's eval set lives in the survey repo at `evals/<pack>/` and never ships.

### Evals

The move follows two published practices. Characterization testing records what a system does before a refactor: "The purpose of characterization testing is to document your system's actual behavior" (Michael Feathers). Anthropic's skill guidance calls the same loop evaluation-driven development: "Create evaluations BEFORE writing extensive documentation", "Establish baseline", then "Run evaluations, compare against baseline, and refine." Anthropic's eval-statistics guidance adds the method: because both arms answer the same questions, compare them by "a paired-differences test".

- **Tasks.** Each surface gets three fixed tasks, the number Anthropic's guide asks for ("Build three scenarios"), for 45 in all. The twelve tasks in `writing-voice/evals/evals.json` carry over where they fit, eval 7 among them for replies. Each task names its facts and three or four assertions. The rubric's four dimensions (register fidelity, clarity, structure, and factual fidelity, from the September benchmark) are the judge's criteria.
- **Arms.** Each draft is a fresh `claude -p` in a scratch project, run with `--model <the pinned drafting model> --setting-sources project --permission-mode acceptEdits --settings '{"outputStyle":"<arm>"}' --output-format stream-json`. The arm's skills sit in the project's `.claude/skills/` and its style in `.claude/output-styles/`, and the prompt is the task alone, so each arm routes as a real session would. The baseline arm holds the snapshot, with the global CLAUDE.md's "Writing voice" section as its project CLAUDE.md. The candidate arm holds the files the new path loads. The runner copies each arm's files into its project and rewrites the `~/.claude/` prefix in those copies to the project's `.claude/` path, since the router names absolute paths, and the pack-read measure matches that project path. No Read in any arm's transcript may land outside its project. Before each batch, `claude -p "/output-style"` in each arm's project must list `- <arm> (current):`. Probe (2026-10-22): under `--setting-sources project`, a project skill triggered on a natural prompt, the transcript showed its Read of the pack file, and a `--settings` style applied. The runner runs four sessions at a time.
- **Graders.** For each draft, `tellgrader` counts tells, Vale counts errors with the context's config, and the transcript shows whether the session read its pack or the file it replaces. For each pair, made of a candidate draft and the baseline draft of the same task and run, a judge on one fixed model other than the drafting model reads both blind against the rubric, marks each draft's assertions, and picks one. It judges every pair twice with the positions swapped, and a split or a stated tie counts as a tie, the standard answer to the position bias Zheng et al. name.
- **The decision.** Each of five measures is compared pair by pair: preference, assertions passed, tells, Vale errors, and pack reads. A surface misses when the baseline is better on any measure by a one-sided sign test at α = 0.05 over the pairs that differ; at nine such pairs that takes eight. It matches when it misses on none. An improvement beats when it is better on one measure named before the run, by the same test, and matches on the rest. A first miss reruns with two fresh runs per task, and only a repeat miss counts, tested on the fresh pairs alone (six of six at six pairs).
- **Knockout.** Pass D also drafts a knockout arm with no style and no pack, September's bare arm, and the decision must miss on it for every surface, on the four content measures (a knockout reads no pack by design). This is the check that the rule can fail. A surface where the knockout matches gets five runs per task, then its assertions are rewritten once, and if it still matches it is reported as non-discriminating. Such a surface still switches in Pass E, since the move is verbatim, and the PR names it.
- **Stored drafts.** Baseline drafts are kept, not only their scores, stored by Survey version, and every comparison re-judges them in the same batch as the new drafts. Judge drift between batches cancels, and a revert is compared with the version it restores. An accepted improvement's drafts become its surface's baseline.
- **Breaks.** Each run records the drafting model, the judge model, the Claude Code version, and the Survey version. A new drafting model redrafts the stored baseline from its files before any comparison. A new judge or rubric marks a break in the scorecard.
- **Geoff's read.** Pass D's packet carries one baseline draft per surface, blind, in skill-creator's review viewer in static mode, which downloads `feedback.json`. Geoff marks each piece ship, edit, or reject as the first word of its note. The judge marks the same pieces from the same instructions, and its agreement with him is reported cumulatively, with its count, never as a monthly figure. His verdicts and notes go to the ledger, and the public eval record keeps counts. A surface he marks weak goes first in Pass H.

### Corrections

Every correction lands in one private ledger with no extra step from Geoff (rulings 5 and 6).

- **The ledger.** A private repo, `glw907/survey-ledger`, cloned at `~/Projects/survey-ledger` on both hosts, since corrections arrive on either host and the distill needs them in one place. The workstation already keeps private material in private GitHub repos, and the initiatives repo is public. Each correction is one JSON file, created once and never rewritten; a reclassification is a new record naming the one it supersedes. Keys name their origin, so two writers never collide: `queue-<host>-<item id>-<n>`, `cairn-<repo>-<save sha>`, and `chat-<session id>-<n>`. A record holds the channel, pack and surface, repo, before, after, reason (Geoff's words, or none), source ref, time, and host.
- **Chat.** The `survey` skill's corrections route triggers when Geoff rewrites or corrects wording Claude wrote. The session applies his fix, writes the record, commits, and pushes. Offline, the commit waits for the next harvest's push. It asks him nothing, and records a reason only if he gave one.
- **The approval queue.** `survey-ledger harvest` reads decided items in `decisions.jsonl` whose line counts `comments`, whose kind is a blueprint, a page, or a change, or whose verdict is `send-back`. From each item's `items/<id>/decision.json` it takes comments with their anchored quote, send-back notes, and triage row notes. Direct prose edits come from git: the blueprint and page screens commit each edit as `Edit <file> in review` (`approval-queue/src/lib/server/blueprint.ts:90`), so the parent blob is the before and the commit's blob the after. The harvester fetches `refs/pull/<n>/head` for each item's PR, which GitHub keeps after a branch is deleted. It emits candidates, and the session keeps only those about wording and names each one's surface.
- **The cairn editor.** `content-draft` commits a Claude draft to the site's default branch with `draft: true` and `git commit --trailer 'Survey-Draft: site-content'`, never through a squash merge, since cairn reads drafts from the default branch and a squash can drop the trailer. A cairn save commits with the editor as author and the App as committer ("the committer is omitted, so GitHub attributes the commit to the App", `cairn-cms/src/lib/github/repo.ts`). The harvester finds drafts by the trailer, then walks later commits to that path: it takes each save whose author is one of Geoff's addresses and whose committer is `cairn-cms[bot]`, diffs it against its own parent, and stops at the first commit by anyone else. Geoff's addresses are seeded in the ledger from his commit authorship. These corrections feed the `site-content` pack.
- **What gets published.** The ledger never lands in a public repo. An example ships only under the public-permalink rule in "Context packs", so a chat correction or a correction from a private repo informs generalizations, which reach Geoff in a packet anyway. Distill PRs and commits cite ledger record ids, never quoted text.

### The monthly writing review

The review grades every surface and then distills the corrections (rulings 5 and 7). It reuses the monthly model review's cadence: `model-review.timer` (`OnCalendar=monthly`) runs on both hosts, its launcher already chains the servers review as step 8, and a step 9 runs `survey-ledger review`. That command launches the prompt at `docs/writing-review/prompt.txt` in the survey repo headless, and takes `--dry-run`, `--ledger <dir>`, and `--surfaces <list>` for a trial on a scratch ledger.

1. Harvest this host's channels into the ledger, including any blind-review `feedback*.json` in `~/Downloads` that names a ledger sample id, and push. On any host but pavilion, stop here, so one host grades.
2. If `reviews/<YYYY-MM>.md` is complete, stop.
3. Move the workstation's Survey tag as the brief's decision says, then grade the fixed tasks as it says, at that pin, against each surface's stored baseline.
4. Grade real writing: up to five Claude-written pieces per surface that shipped since the last run, drawn at random from the repos that pin Survey with the seed recorded. A Claude piece is one whose commit carries the co-author trailer, and it is graded at that commit, before any edit of Geoff's. Score each with `tellgrader`, Vale, and the judge's ship, edit, or reject. Replies leave no commit, so the reply surface has none.
5. Write the scorecard: per surface, this month beside the three before it, with the five measures against the baseline, the real-sample figures where a surface has three or more pieces, and the judge's cumulative agreement with Geoff.
6. Open a backlog item in the survey repo through `log-issue` for any surface that misses its baseline, unless the scorecard is partial. The item carries numbers, never quoted text.
7. Build the blind sample: six pieces, three from the fixed tasks and three real, sources hidden, as a static viewer page in the ledger clone. Notify at normal urgency. Each of Geoff's notes joins the ledger as a correction.
8. Distill every correction no review record has consumed, lowest-scoring surfaces first. Each correction becomes a probe kept in the ledger: a short task from its context that would reproduce the wording he corrected, with one assertion that the draft avoids it. An example beats when its probes pass more often than under the baseline, by the same sign test at five runs per probe, and the fixed tasks match. A beating example goes into a survey PR that the session merges and releases as a minor, with no packet (ruling 5). Sharper rules and Vale rules that beat go to Geoff as one packet through `approval-packet`, each one an ask.
9. Write `reviews/<YYYY-MM>.md`: the correction ids consumed, each proposal and its outcome, and one log line. Commit, push, and hand over.

### The house register

Pass G builds the house flavor the 2026-10-22 rulings asked for: the register over Google and Microsoft, its departures, and the copy-editing rules. Its main source is cairn's `docs/internal/docs-register.md`, the most developed overlay on the workstation. Pass H then applies it pack by pack.

- **Voice and tone.** The voice stays fixed while the tone moves with the surface, as Mailchimp, Atlassian, and Shopify Polaris each set out. `packs/core/voice.md` states the voice as three to five traits in Mailchimp's "X but not Y" form ("smart but not snobbish"). It also holds a tone table that places each surface on Nielsen Norman Group's four tone dimensions: funny or serious, formal or casual, respectful or irreverent, enthusiastic or matter-of-fact.
- **Building on drafter's stock.** The Google packs hold the house deltas and cite drafter's `drafter:google-*.md` stock files for the base (`const drafterPrefix = "drafter:"`, `internal/assemble/section.go:13`). drafter has no Microsoft stock (`internal/blueprint/tracks.go:21` lists only `google`), so the `end-user` pack is written whole in Pass H. Its interface-text surface generalizes the Voice section of cairn's admin design system.
- **Departures.** A row is admitted by cairn's own test (`docs-register.md:1083-1095`, Geoff, 2026-09-28). An override of the base guide needs a row with its source and ruling, and a tightening does not. Each ruling id carries its source as a prefix (`cairn-2026-09-28-r3`, `survey-g-r1`), and a carried cairn ruling cites a GitHub permalink at the harvest commit. Once cairn converges in Pass E, a cairn rule that departs from Survey is a row in cairn's own register with Geoff's ruling.
- **Corpus licensing.** Google's pages are CC BY 4.0, as drafter's corpus records. Microsoft's live pages read "All rights reserved", but the guide's public source repository, `MicrosoftDocs/microsoft-style-guide`, is CC BY 4.0 by its `LICENSE` and `ThirdPartyNotices` files, archived at `c6945c3` (2024-11-13). Microsoft excerpts are quoted only from that commit, each with its file permalink, the live page's URL, the license, and the retrieval date; live text that differs is linked and paraphrased. Every other base corpus has its license read and recorded before Pass H quotes it. The package's `license` field becomes an SPDX expression that names CC-BY-4.0 for the corpora, `LICENSES.md` ships the attribution CC BY 4.0 requires, and a lint fails on an excerpt without its URL, license, or date.
- **Copy-editing rules.** A style sheet, the editor's established tool for a house's mechanical choices, lists each rule with its source, such as the serial comma, sentence-case headings, and how dates, times, and numbers are written. Each row names its Vale rule, or the reason none fits.
- **Survey's Vale rules.** The `Survey` style starts in Pass D as the seven `glw907` rules, unchanged. Pass G adds a rule for each departure and copy-editing rule Vale can express, at `suggestion`, since it ships in a minor. Fixtures live in `tests/vale/`, outside the style directory, since Vale reads every `.yml` there as a rule.
- **Judgment layer.** Vale is the deterministic net. `prose-voice-reviewer` reads a house-tool draft against its pack, and `cairn-register-editor` reads cairn's drafts once cairn converges in Pass E.

### The Claude-infra map

The writing work touches most of the workstation's writing tooling, and each piece keeps one home under the `claude-infra` rules. Anthropic's features overview sets the order of strength: "If a rule must hold every time, make it a hook rather than a prompt instruction", and "Put it in a skill if it's reference material Claude needs sometimes". CLAUDE.md carries only a fact that every turn needs. The workstation takes Survey in two `~/.dotfiles` PRs under `dotfiles-pass` at `runner` class: Pass E's, which lands everything that exists at 1.2.0 along with cairn's reader moves, and Pass F's, which adds the correction channels.

| Piece | Home | Change | Pass |
|---|---|---|---|
| `survey` skill | the survey repo's `skills/survey/`, vendored by release tag | written in B, gains packs in D, vendored in E, gains the corrections route in F | B, D, E, F |
| `claude-tooling-sync` | `~/.local/bin` | `fetch_skill` writes to a temporary sibling and renames it into place | E |
| `vendored-skills.json`, `claude-tooling.md` | manifest, docs | the `survey` entry pinned by tag, with its rule: edit packs in the survey repo, never in place | E |
| dotfiles `scripts/check.sh` | gate | the checksum check over the vendored skill, and each of the seven links checked with `readlink` against its recorded target | E |
| Survey hook | `~/.dotfiles` hooks, beside `vale-hook` | new advisory PostToolUse hook | E |
| four agents | agents | `skills: [survey]` in `site-implementer`, `cairn-implementer`, `visual-verifier`, and `daisyui-a11y-reviewer` | E |
| `dependency-upgrade` | skill | the ruled render line and the Survey step from "Channels and pins" | E |
| the six registers in `~/.claude/docs/voice/` | docs | each becomes a relative symlink to its vendored `pack.md` | E |
| `~/.claude/docs/web-content-method.md` | docs | becomes a relative symlink to the `site-content` pack | E |
| `writing-voice` skill | skill | each router row names its pack path; name and description stay | E |
| `go`, `ts`, `svelte`, and `python-conventions` | skills | the comment text moves to the packs and each skill names its pack; Go's code rules stay | E |
| `prose-voice-reviewer` | agent | one line: in a repo that pins Survey, read its pinned packs | E |
| the authoring charter | docs | the site-content line per ruling 1, the overlay paragraph, the table's rows, and the adoption steps name Survey | E |
| cairn's readers in `~/.dotfiles` | skill and agents | `register-check`, `cairn-register-editor`, `cairn-docs-drafter`, `figure-verifier`, `cairn-implementer`, and `site-implementer` read cairn's shrunken register and cairn-cms's pinned packs (Pass E's cairn step) | E, before the CLAUDE.md line |
| global CLAUDE.md, "Writing voice" | CLAUDE.md | one sentence names Survey as the house writing reference | E, second to last |
| `writing-voice` output style | output style | becomes a relative symlink to `packs/core/pack.md` | E, last |
| `content-draft` | skill | commits the draft with the `Survey-Draft` trailer | F |
| `survey-ledger` | `~/.dotfiles/bin` | new stdlib Python helper: `harvest` and `review` | F |
| `check-drift` | `~/.dotfiles/bin` | checks the ledger clone the way it checks the initiatives clone, and reports a ledger with no review record for last month | F |
| `docs/model-review/prompt.txt` | the monthly runner's prompt | step 9 runs `survey-ledger review` | F |

One workstation PR in Pass E, in place of a visual PR beside Pass D and a writing PR after it, means the skill is written once in the survey repo and vendored once, the hosts roll out once, and the output style still lands last. Some pieces change nothing. `vale-hook` and `tellgrader --hook` run each repo's own config, which names Survey once the repo adopts it. `content-review`, `approval-packet`, and `pass-core` read the method and the brief register at paths that stay put. Neither the distill nor the grading needs a skill, since each runs from a committed prompt, as both monthly reviews already do.

The approval-brief register needs its path. The approval queue's gate reads its exemplars from `~/.claude/docs/voice/approval-brief.md` (`tests/approval-queue.test.sh:209`), needs at least six of them and exactly three packets, and the brief check prints that path in each refusal (`approval-queue/src/lib/brief.ts:8`). A symlink keeps both working. A contract change now lands in Survey first, and an approval-queue PR can test against a survey checkout through the `REGISTER` variable the gate already reads.

The symlinks rest on two probes. A headless session loaded an output style through a relative symlink, and `stow` linked a package file that is itself a relative symlink. Claude Code "reads style files when it starts", so the style change reaches each session at its next start. The visual guidance and the corrections route share the one `survey` skill, as ruling 5 names it; Anthropic's skill guide notes that Claude reads each description "to choose the right Skill from potentially 100+ available Skills", and one fewer description is one fewer chance of a collision.

### Pass A: visual harvest and rulings

Pass A turns the three versions into one ledger of rulings and an amended specimen. It is `ordinary`, works in the initiatives repo, merges its own PR, and runs about 210 minutes. It reads, at commits it records, the approval queue's four `src/lib/survey/` files, `src/app.css`, and `src/lib/components/frame/frame.css`, plus the 2026-10-07 spec and the approved specimen. If the thinkpad-x1 pre-flight step found Survey work, its archive branch joins as a fourth source. Pass A only reads the approval queue.

- **Ledger.** `initiatives/survey-house-style/research/<date>-harvest-ledger.md` holds one row per token or rule, with its source locations, rung, disposition (agreement, difference, forced, promote, or app-only), and ruling id. A grep count of the custom properties and rule selectors in the six approval-queue files and the approved specimen must equal the ledger's mapped count. The agreements become the draft principles.
- **Forced differences.** A difference that a rule settles, such as a value that fails contrast, is Claude's call, listed in the sitting without a render.
- **The sitting.** The remaining differences and every approval-queue rule Claude proposes to promote reach Geoff in one sitting in Chromium, rendered at the ruled threshold, one panel per source that differs, with a recommendation. Afterwards every difference and promote row carries a ruling id.
- **Specimen.** Pass A ends by writing `initiatives/survey-house-style/reference/<date>-amended-specimen.html`, committed and pushed with the ledger. Pass B cites both by commit and grades against that file.

### Pass B: the repo and the release candidate

Pass B creates the public `glw907/survey` repo and publishes `1.0.0-rc.1` from Pass A's rulings. It is `runner` for its workflow and gate scripts and `live-account` for the public repo and the publish, and runs about 520 minutes.

- **Provenance.** The repo starts from a fresh copy, without history, of the two `survey-theme/reference/` files, the 2026-10-07 spec, and its review (`docs/research/2026-10-07-survey-spec-review.md`). Its first commit names the cairn-themes commit they came from. The core CSS starts from the approval queue's vendored copy at the commit Pass A recorded, since cairn-themes never committed a core.
- **Build.** The token source and three outputs, the shared CSS, the living specimen, `survey-check` with its stylelint plugin and fixtures, the two consumer fixtures the end-to-end check names, `skills/survey/SKILL.md` with the visual routes, `AGENTS.md`, `CHANGELOG.md`, the release gate, a PR workflow that runs the gate, and `publish.yml`. The session turns on immutable releases before the first release.
- **Trace.** Each ruling id in Pass A's ledger maps to a token path, a DESIGN.md rule, or an "app-only, not shipped" note.
- **Leaving cairn-themes.** Only after the new repo is pushed, one cairn-themes commit removes `survey-theme/`, the Survey spec and its review, and backlog items #1 and #2, and rewrites every live pointer the 2026-10-21 fold record lists. Afterwards, `grep -rni survey` there returns only theme-port mentions. Dated records elsewhere stay as written.
- **Close.** The packet carries the built specimen for Geoff's read in Chromium, as the 2026-10-07 spec required before any consumer took the core. In the same sitting he links the trusted publisher (repo `glw907/survey`, workflow `publish.yml`, direct publish allowed) and approves the merge. The session then creates the GitHub release and runs the post-publish check.

### Pass D: the writing baseline and the verbatim move

Pass D records how today's writing system behaves, then moves its files into Survey word for word and releases 1.1.0 (ruling 4). It works in the survey repo and creates the ledger, is `runner` for the eval runner that becomes the check every writing minor must pass, is `live-account` for the private repo and the release, and runs about 690 minutes. It may start once Pass B merges. Its PR merges only after the approval queue's pass has promoted 1.0.0, because the rulings define 1.0.0 as the release candidate that pass converged on.

- **Snapshot.** Copy today's files at a recorded `~/.dotfiles` commit into `evals/baseline/<commit>/`: the output style, the `writing-voice` skill, the six registers, the four conventions skills, the web-content method, and the global CLAUDE.md's "Writing voice" section. The `glw907` Vale style comes from poplar at a recorded commit, since `~/.dotfiles` holds no copy and the five repo copies are identical. This snapshot is the kept copy ruling 4 asks for.
- **Tasks and runner.** Three fixed tasks per surface, 45 in all, and one runner script that launches the arms, runs the graders and the judge, and applies the sign tests. `evals/README.md` names the drafting and judge models and the reason for each.
- **Baseline.** Three runs per task for the baseline and knockout arms. The results land in `evals/results/<date>/` as `benchmark.json` and `benchmark.md`, the layout the September benchmark used, with each surface's run time.
- **Packs.** Each pack's `pack.md` is its source from the snapshot, checked byte for byte with `cmp` against the whole file, the conventions skill's body, or Go's "Comments" section. `packs/core/pack.md` is the output style file whole, frontmatter included.
- **Vale.** The seven `glw907` rule files move into `skills/survey/` with their content and levels unchanged. The fixture runner asserts that each failing fixture raises exactly `Survey.<Rule>` in `vale --output=JSON` and each passing fixture raises no `Survey.*` alert. The gate fails unless the number of rule files equals the number of fixture pairs.
- **Skill directory.** `skills/survey/` gains `packs/`, the rules, `VERSION`, and `SHA256SUMS`. `files` adds it, and the release attaches it as `Survey.zip`.
- **Pointer texts.** The text each workstation file will hold after Pass E (the router rows and the conventions pointers) is written into `evals/candidate/`. These are the exact bytes Pass E lands.
- **Candidate run.** Every surface runs against its baseline. Pass E switches only the surfaces that match.
- **cairn's docs.** Two cairn surfaces join the baseline run: three `dev-docs-web` tasks and three `end-user` docs tasks, drafted in a cairn-cms arm whose project carries cairn's register and its readers at a recorded cairn-cms commit, with the knockout beside them. They are not Survey surfaces, they leave the monthly review, and Pass E's cairn step is measured against them.
- **Ledger.** The session creates the private `glw907/survey-ledger` repo with its layout (`corrections/`, `scorecards/`, `reviews/`, and the address list) and clones it on pavilion, since Geoff's blind verdicts are its first private record.
- **Scratch repos.** From a clean clone, an npm scratch app installs the packed tarball, commits its copy, and runs its gate. A scratch repo without npm syncs a locally served `Survey.zip` and runs the checksum check. Each check fails after one edit to the copy.
- **Close.** The packet carries the `survey` PR and fifteen baseline drafts, one per surface, for Geoff's blind read in Chromium. On approval the session merges, creates the 1.1.0 release, and runs the post-publish check, which syncs the real release URL.

### Pass G: the house register

Pass G builds the house register set out in "The house register" and releases it as 1.2.0, before Pass E. It is `runner` and `live-account` for the content agents follow and its release, works in the survey repo and the initiatives repo, and runs about 360 minutes. The register changes the Vale style that every surface's checks run, so its release must match on all fifteen surfaces.

- **Sources.** The ledger records each source at a commit: cairn's `docs-register.md` (both briefs, the departure tables, and the rulings behind them), the Voice section of cairn's `admin-design-system.md`, cairn's `docs/internal/design/2026-06-20-editor-copyedit-conventions-research.md`, poplar's retired tidy rules (`041eb329^:internal/tidytext/` and `docs/archive/specs/2026-05-08-claude-tidy-design.md`), drafter's `stock/` files, and the Pass D packs.
- **Ledger.** `initiatives/survey-house-style/research/<date>-writing-ledger.md` holds one row per countable unit: each `##` or `###` tell heading in both of cairn's Tells sections, each row under "Deviations from the base guides", each `##` in drafter's `stock/google-tells.md`, each rule heading in the admin Voice section, each `glw907` rule, and each numbered convention in the copy-edit research. The mapped count must equal their sum. Each row is house-wide, cairn-only, or owned elsewhere, and says why. An owned-elsewhere row names its owner (`tellgrader` or drafter's stock) and does not ship. A cairn-only row names the cairn noun it depends on: a track, a cairn name, a page anatomy, or cairn tooling. A row with no such noun is house-wide by default.
- **The sitting.** Geoff rules the voice traits, the tone table, and every override in one sitting, each override with the base guide's text beside the proposed rule. A cairn override marked house-wide comes with cairn's ruling as evidence. Tightenings widened from cairn sit in one table with a default of "widen", and rows whose mark was unclear join it with a default of "cairn-only". Geoff can pull any row into discussion. Afterwards each ruling id maps to a pack section, a departures row, a style-sheet row, or a Vale rule, and a check counts both sides.
- **Build.** `packs/core/voice.md`, the departures file, the style sheet, `LICENSES.md`, and the new Vale rules with their fixtures.
- **drafter.** If the brief's drafter decision takes the first option, a drafter run in a scratch repo shows a known sentence from a pinned pack in the assembled request, and the same run fails once that heading is renamed.

### Pass E: adoption

Pass E lands the newest Survey release, 1.2.0 or later, on the workstation, pins it in every other repo with prose, and moves cairn's docs onto the Survey register (rulings 3 and 4, and Geoff's cairn ruling). It is `runner` for the workstation tooling and gate checks it adds and `live-account` for any Survey minor its stops release, and runs about 870 minutes. It lands the `~/.dotfiles` PR first under `dotfiles-pass`, then one PR per repo under that repo's adapter, and sends all of them to Geoff in one packet. A repo switches only when every surface it writes matched in Pass D and in Pass G's release run, and every repo pins the newest release at its PR.

- **The workstation.** One `~/.dotfiles` PR lands Pass E's rows of the Claude-infra map in this order, one commit each: the `fetch_skill` change, the vendored `survey` entry and its checks, the hook, the agent preloads, the `dependency-upgrade` lines, the register symlinks one per commit, the router and conventions pointers for surfaces that matched, the reviewer line, the charter and tooling docs, the CLAUDE.md line, and the output style last. Revert in reverse order. Before each symlink commit, the file at `HEAD` must equal its pack byte for byte. A file edited since the snapshot has its change carried into a Survey minor through Pass D's stop answer (re-baseline that surface and run its candidate), and the release and tag move come before its link lands.
- **The hook.** A stdlib Python PostToolUse hook, after an edit to a `.css`, `.svelte`, or `.html` file, runs the `survey-check` of the nearest repo whose `package.json` lists `@glw907/survey` on the changed lines, returns its findings as `additionalContext`, says "run `npm ci`" when the package is listed but not installed, and always exits 0.
- **Workstation acceptance.** Hook tests on the `tests/test_vale_hook.py` pattern against a scratch app that installs the packed package: an off-token edit returns context naming the token, a non-dependent repo and a `.md` edit return nothing, a checker crash still exits 0, and the run stays inside the timeout. skill-creator's trigger set for the `survey` skill: twenty queries, half that should trigger and half near-misses that should not, with its 40% held-out split. One headless `site-implementer` dispatch in the scratch app reads the installed DESIGN.md before its first CSS edit. Every link's `readlink` equals its recorded target, and the checksum check passes. `claude -p "/output-style"` in a fresh session lists `- writing-voice (current):`. The approval queue's gate passes while it reads the symlinked brief register. `claude-tooling-sync verify` exits 0.
- **npm channel.** cairn-cms with its `tool/` directory, ecxc-ski, aksailingclub-org, xcathletes-org, cairn-pub, and approval-queue, whose `package.json` sits in its `approval-queue/` app. The approval queue's bump from 1.0.0 is a minor, so its PR builds in a worktree and takes the ruled full-page render in both schemes.
- **Zip channel.** poplar, dubplate, drafter, phonebook, cairn-themes, servers, and initiatives. fishwright joins if it holds prose.
- **Out.** 907-life, which adopts Survey in its rebuild, and aksailingclub-legacy, which the `asc-cutover` initiative archives. Any repo found to hold no prose is listed in the PR with its reason.
- **Each repo.** Add the pin, commit the copy, add the copy check to the gate, and exclude the copy from the repo's other markdown checks, since its packs hold deliberate tells. A repo that applied `glw907` renames `BasedOnStyles = glw907` to `Survey` and each `glw907.<Rule>` override to `Survey.<Rule>`, then deletes its `glw907` copy. A repo with no Vale today gets a pin-only `.vale.ini` that applies no style. The project CLAUDE.md names its Survey pin beside its charter line.
- **Repo acceptance.** In each repo, every gate's findings on the full tree before and after match, except for Vale's rule-name prefix. The copy check passes clean and fails after a planted edit.
- **cairn's docs.** Pass E's cairn-cms task first diffs cairn's register from Pass G's harvest commit to its head and keeps each new row cairn-only, which a later minor can widen. It then shrinks `docs-register.md` to its cairn-only parts and points it at cairn-cms's pinned packs. Every reader moves with it, across three repos. In drafter, `docs-page-chain.js` takes one `registerPath`, selects sections by exact heading, and pastes two scope rulings verbatim; it gains the pinned pack path as a second source. In `~/.dotfiles`, the readers in the Claude-infra map's cairn row move in the workstation PR before the CLAUDE.md line. In cairn-cms, the `.tellgrader.json` profile and the `Cairn` Vale messages that cite "'Names' in docs/internal/docs-register.md" move. The drafter and cairn-cms changes ride in those repos' Pass E PRs. Every reader fails loudly when the pinned copy is absent and never falls back to cairn's old text. cairn switches only when both cairn surfaces from Pass D match.
- **Hosts.** After the workstation merge, pavilion runs `git pull`, `stow -R claude bin`, `claude-tooling-sync apply`, and `claude-tooling-sync verify`, then restarts its Claude Code sessions. On thinkpad-x1, `check-drift` reports the clone behind origin, and the session there runs the same steps.

### Pass F: corrections and the monthly review

Pass F builds the four correction channels and the monthly writing review (rulings 5, 6, and 7), and releases 1.3.0 for the skill's new route. It is `runner` for the helper and the skill route and `live-account` for its release, works in the survey repo, `~/.dotfiles`, and the ledger, and runs about 485 minutes after Pass E.

- **Corrections route.** The `survey` skill gains the route in the survey repo, released as 1.3.0, and the `~/.dotfiles` PR moves the vendored tag. Its trigger set follows skill-creator's twenty-query method, with near-misses such as a request for a new draft and a correction to a line of code.
- **Helper.** `survey-ledger` in `~/.dotfiles/bin`, with `harvest` and `review`, tested against a fixture queue state directory and a scratch site repo.
- **Workstation lines.** The `content-draft` commit, the `check-drift` ledger check, and the model review's step 9.
- **Review.** `docs/writing-review/prompt.txt` in the survey repo.
- **Acceptance.** A chat correction writes one record, and a second harvest writes nothing new. The harvester finds a planted comment, a planted note, a planted in-review edit on a squash-merged and deleted branch, and the draft-and-save pair in the scratch repo. It writes no wording record for a comment about code, a send-back note about a missing test, a volunteer's save, a save after an intervening volunteer edit, or a save on a page with no `Survey-Draft` trailer. `survey-ledger review --dry-run --ledger <scratch> --surfaces <one>` on a scratch ledger seeded with a prior scorecard writes a scorecard, a viewer page, and a review record, prints the `log-issue` item for the seeded drop with numbers and no quoted text, takes the lowest-scoring surface first, and turns a planted correction into a probe, a verdict in the review record, and a scratch PR. A planted private-source correction appears in no proposed example. A second run with that review record present harvests and stops, and a run that reports a host other than pavilion harvests and stops.
- **Order and hosts.** The survey release goes first, then the `~/.dotfiles` PR, and both close in one packet. Both hosts clone the ledger, then run Pass E's host steps.

### Pass H: the packs

Pass H gives all twelve packs their full shape (ruling 2). It is `runner` and `live-account` for pack content agents follow and its releases, works in the survey repo, and runs about 1,080 minutes. It takes packs in order of the latest scorecard, lowest first, or Pass D's baseline when no scorecard exists yet, and Geoff's Pass D verdicts break ties. Each pack is its own minor release that must beat its surfaces' baseline without hurting any other (ruling 4), so the pass can close at any pack boundary and a later pass picks up the rest. A change to `core` runs all fifteen surfaces.

- **Each pack.** Write its sections into `pack.md` as "Context packs" sets out, base examples after the corpus license check and house examples under the public-permalink rule. Then run the pack's evals and release.
- **The prose packs.** The Google packs cite drafter's stock and hold deltas. The `end-user` pack is written whole, and its interface-text surface generalizes cairn's admin Voice section. The `site-content` pack may name a published base here, as an improvement that must beat its baseline, and may draw house examples from 907.life's existing posts.
- **The approval-briefs pack.** Its PR runs the approval queue's gate with `REGISTER` set to the survey checkout before it merges.

### What each app's pass inherits

These constraints go into each app's own plan. None of them is built here.

- **Bulwark.** The servers repo holds a `package.json` and lockfile that pin `@glw907/survey` exactly, and a build step copies the sheet into the theme bundle. `dependency-upgrade` measures every directory with a `package.json` (its step 1), so the pin shows up in a sweep. Checking the live theme against the repo after a deploy or a restore is that pass's design.
- **Approval queue.** It builds and render-checks in a worktree, since the main checkout serves from `build/`. It swaps `main`'s build only when no item is pending, and keeps the old build until the new one serves. Each promoted rule leaves `app.css` in the commit that takes the package. Its four vendored headers change in that pass.
- **907.life.** Its rebuild, after cairn's docs are complete, settles through `engine-consult` how the chassis takes the package. The cairn-site recipe ships in 1.0.0 marked pending, and the rebuild fills it in a minor.

### End-to-end check

A packed tarball, not the repo checkout, has to pass every leg.

- From a clean clone, the commands `AGENTS.md` names build all three outputs, and `lint`, the contrast check, the release gate, and the `survey-check` fixtures pass.
- `npm pack --dry-run --json` lists DESIGN.md, the token JSON, the three outputs, the shared CSS, the stylelint config, and the `survey-check` bin, and no `reference/` file.
- `fixtures/daisyui-consumer/` installs the tarball into a minimal Tailwind 4 and daisyUI 5 build whose only Survey input is the one-line import. A computed-style probe in both themes reads `--color-base-100`, `--radius-box`, and the font family against the token source, and `survey-check` fails on a planted literal there.
- `fixtures/token-only.html` loads only the CSS-variable sheet, which holds zero `url(` and zero `@import`. A computed-style probe in both schemes matches rungs one to three, and the font family resolves to the system stack with the web fonts absent.
- The specimen, built from package outputs only, is screenshotted at 320, 390, 768, 1440, and 2560px in both schemes. A fresh-context `visual-verifier` grades it against the amended specimen at the commit Pass B cites, with no STRUCTURAL finding.
- After the publish, in a scratch directory, `npm i @glw907/survey@<version>` installs, the installed DESIGN.md reads, `npx survey-check` fails on a positive fixture, and `npm view @glw907/survey@<version> dist.attestations` shows provenance.
- From 1.1.0 on, the pack list also holds `skills/survey/` and no `evals/` or `tests/` file. The release carries `Survey.zip`, a scratch repo without npm pins its URL, `vale sync` installs it, a planted tell raises its `Survey.<Rule>` by name, and the checksum check passes. The vendored skill fetched at the tag passes the same check.
- The writing legs are the acceptance lists of Passes D, E, and F: the knockout misses and every switched surface matches, every link resolves to its target with `writing-voice` current, and each channel's planted correction reaches the ledger once.

### Stops and standing answers

Each stop the run can foresee has an answer here, grouped by the pass that meets it first. The run asks Geoff only where an item says it stops. Three answers hold everywhere: a task clock stop with a traced cause resumes once at twice its estimate, and each pass runs to 1.5 times its path estimate and stops past that; repeated STRUCTURAL findings proceed on a traced cause, per `pass-core`'s loop guard, and a cause that returns after its structural fix is escalated in the PR; unrelated drift at close is noted in the PR and left.

**Pre-flight and Pass A.**

- The thinkpad-x1 check shows nothing: the vendored copy is the S1 core verbatim, and Pass A runs on three sources without asking.
- The 2-day link window lapses: the session writes STATUS and waits, and Geoff recreates the link at his next sitting.

**Pass B.**

- Contrast moves a ruled value: tune lightness within the hue family, record the old value and its ratios in the token's `$description`, and list it in the PR's `## Decisions`.
- A ruling separates the focus ring from primary: ship it aliased in 1.0.0 and record the split for a minor. The audit measures only primary as the focus ring.
- Geoff's specimen read sends changes back: a change inside the ruled scope is fixed in Pass B before the cut. One outside it is a design change and stops.
- The publish fails: fix the workflow or the link, then re-run the same version by dispatching the workflow from `main`; the already-published guard allows it. Never bump the version to retry.
- The post-publish check fails after a good publish: cut a patch through the same workflow without asking, and put the `npm deprecate` line for the bad version in the next packet.
- The cairn-themes grep finds a pointer the fold record does not list: rewrite a live pointer, leave a dated record as written, and list both in `## Decisions`.

**Pass D and every eval run.**

- 1.0.0 is not out when the PR is ready: the session writes STATUS and waits. It never cuts a writing release candidate.
- A surface misses: it reruns with two fresh runs per task, and only a repeat miss counts. A repeat miss keeps that surface on today's route, Pass E leaves it unswitched, and the run traces the cause and makes one structural fix. A surface that still misses is escalated in the PR while the rest go on.
- The knockout matches on a surface: five runs per task, then one rewrite of its assertions, then the surface is reported as non-discriminating in the PR.
- A live file changed after the snapshot: carry the change into its pack, re-run that surface's baseline at the new commit, run its candidate again, and list it in `## Decisions`.
- An arm's `/output-style` check fails: the batch does not run, and the session fixes the arm's project before any draft.

**Pass E.**

- PR #131 is still open: the workstation branch stacks on #131's.
- A file at `HEAD` differs from its pack before its link: carry the change into a Survey minor through Pass D's stop answer, release it, move the tag, then link. Never edit the workstation file to match.
- A cairn surface repeat-misses: cairn keeps its register and readers, its pin still lands, and the PR escalates it.
- A cairn page is mid-draft at the switch: it finishes on the register its chain started with, the risk Geoff accepted, and the PR lists it.
- The output-style check fails: revert that commit, keep the old file in place, and escalate. Everything earlier in the workstation PR stands.
- The `site-implementer` dispatch skips DESIGN.md, or a trigger query misses, in this pass or any later one: reword once, re-run, then escalate.
- A repo holds no prose: leave it out and list it with the reason.
- A repo's Vale findings differ by more than the rule names: trace the cause. If it isn't the rename, that repo doesn't switch, and the PR escalates it.

**Pass F and the monthly run.**

- A ledger push conflicts: pull with rebase and push again. Records are created once and never share a file.
- A correction comes from a private source or from chat: it stays in the ledger and informs only generalizations.
- The monthly run hits a usage limit: finish the harvest, grade each fixed task once instead of three times, and mark the scorecard partial.
- A distill proposal doesn't beat its baseline: drop it, and its corrections stay unconsumed for the next run.
- A host has no ledger clone: `check-drift` reports it, and that host's chat route writes nothing until a session clones it.
- The tag move fails the dotfiles gate: leave the tag, grade at the old pin, and put the failure in the review record.
- Pavilion misses a month: `check-drift` reports the missing review record, and the next run consumes the corrections.

**Pass G.**

- A cairn rule's house-wide or cairn-only mark is unclear: it joins the sitting's table with a default of cairn-only, and a later minor can widen it.
- Geoff rejects a house-wide row: the row stays cairn-only, and the ledger records his ruling.
- The sitting leaves most rows cairn-only: ship what is ruled house-wide, however little, and report the counts at close.
- A copy-editing rule Vale can't express: its row names the reason, it stays in the style sheet, and the PR lists it.
- The release repeat-misses on a surface: trace it to the rule or row that caused it, drop that one from the release, and report it at close. A repeat miss with no traced cause is reported, and the release proceeds.
- The drafter leg fails: the rest of Pass G runs, the close reports the leg unmet, and the drafter fix becomes a pass of its own.

**Pass H.**

- A pack can't beat its baseline: ship nothing for it that round and report it at close.
- A surface has fewer than three house examples: Claude drafts the rest, marks each one drafted, runs it past `prose-voice-reviewer`, and shows it in the packet.
- A source's license can't be confirmed: quote nothing from it, link and paraphrase instead, and list it in `## Decisions`.

**What may escalate.** The nearest-token wording, a COSMETIC specimen finding, a trigger miss after one rewording, the `site-implementer` dispatch after one rewording, a surface that repeat-misses after one structural fix, a non-discriminating surface, a cairn surface that repeat-misses, a repo whose findings differ, the output-style switch, and Pass G's drafter leg. The contrast bar, the pack and fixture checks, the release gate, provenance, the hook's exit 0, the Vale fixtures and the copy checks, the `cmp` checks, the public-permalink rule, the private-ledger rule, and the corpus license fields never escalate.

### Risk and estimate

Pass A is `ordinary` and merges its own PR in the initiatives repo. Every other pass closes through a conductor and a packet. With no Survey adapter yet, Passes B, D, F, G, and H use `pass-core`'s default classes in the survey repo, and each plan names the gate, the fast lane, and CI on PRs as the full-suite home. Pass E uses `dotfiles-pass` for its workstation PR and runs each other repo under its own adapter, as does Pass F's workstation PR; Pass E carries `live-account` because a stop can release a Survey minor. Every `live-account` plan takes the three-lens review and a verification read. Eval figures assume four sessions at a time and about ten minutes per surface run; Pass D measures the real figure, and later plans cut their estimates from it.

| Pass | Minutes | Breakdown |
|---|---|---|
| A | 210 | as folded on 2026-10-21 |
| B | 520 | as folded on 2026-10-21 (460), skill 20, release gate 30, release settings 10 |
| D | 720 | snapshot 20, 45 tasks and assertions 135, runner 90, baseline and knockout runs 130, cairn surfaces 30, packs 40, Vale rules 30, skill directory and checksums 30, candidate runs 90, ledger 15, scratch repos 40, packet and blind sample 25, release 45 |
| G | 360 | sources ledger 75, sitting 40, voice file, departures, and style sheet 60, Vale rules and fixtures 50, licensing 20, all-surface match run 90, release 25 |
| E | 870 | `fetch_skill` 30, vendored entry and checks 30, hook and tests 70, preloads and `dependency-upgrade` 30, trigger set and dispatch 40, symlinks 40, pointers and reviewer 45, docs 30, CLAUDE.md and style 15, workstation acceptance 30, hosts 20, inventory 20, six npm repos 120, approval-queue render 30, seven zip repos 140, findings checks 30, cairn's docs 150 |
| F | 485 | route and trigger set 70, helper and tests 140, `content-draft` and `check-drift` 30, review prompt 90, step 9 5, dry run 90, release and hosts 60 |
| H | 1,080 | twelve packs at 80 (50 writing, 30 evals and release), end-user's extra surfaces 20, core's all-surface run 60, close 40 |

The estimates sum to 4,245 minutes, and with the passes in sequence the path is the same. If Geoff takes the drafter option, a 40-minute drafter pass runs before Pass G. It is `ordinary` under `pass-core`'s defaults and merges its own PR.

### Pre-flight and sittings

Geoff does two steps in the sitting where he approves this design, since neither needs a pass's output.

- [you: on thinkpad-x1, in `~/Projects/cairn-themes`, run `git status --short`, `git stash list`, `git log origin/main..main --oneline`, and `git branch -a --contains dea9839`. An error from the last command means the commit is absent. Survey work is any path under `survey-theme/`, or any commit or stash that touches one. If there is any, commit it to a new `archive/thinkpad-x1-survey` branch and push it, then `git switch main && git reset --hard origin/main`. Check: `git ls-remote origin archive/thinkpad-x1-survey` prints a line, or nothing was found.]
- [you: run `npm login` with 2FA. In the placeholder directory the session that sends this design stages (its `package.json` carries `"files": ["README.md"]` and `"publishConfig": {"access": "public"}`, and its README says it is a placeholder), run `npm pack --dry-run` and confirm it lists only `package.json` and `README.md`. Then run `npm publish --access public` and `npm deprecate @glw907/survey@0.0.0 "Placeholder; install 1.0.0 or later"`. Set "Require two-factor authentication and disallow tokens" on the package. Check: from a logged-out shell, `npm view @glw907/survey version` prints `0.0.0`, and `npm access get status @glw907/survey` reads `public`.]

Three more sittings follow: Pass A's rulings, Pass B's close (the specimen read, the trusted-publisher link, and the merge approval), and Pass G's voice and departure rulings. Pass D's blind read of fifteen baseline drafts rides on its close packet. Passes D, E, F, and H close on a merge packet each, and the monthly review adds one packet a month when it has generalizations to propose. A packet that follows a superseding patch carries its `npm deprecate` line as a `[you: ...]` step. The blind sample page arrives each month at normal urgency and asks for six verdicts. Pass F's host steps on thinkpad-x1 are a session's, not Geoff's.

### Later

Two items are recorded here and not built. A Survey Claude Code plugin belongs to the shared-standards initiative (`~/Projects/initiatives/shared-standards`), per Geoff's 2026-10-22 ruling. Path-scoped rules that bring each comment pack to implementers editing a matching file are a candidate improvement, which would have to beat its baseline like any other.

### Left to the builder

The token names, Style Dictionary's configuration, the specimen's harness, the skill's wording, the CSS-variable sheet's prefix, and how the recipes split between the skill and DESIGN.md are the builder's. So are the hook's timeout, output cap, extension pre-filter, and any per-repo carve-out, the stylelint rule names, the release gate's diff script, the eval tasks' wording and the router rows, the judge model (picked once and recorded), the ledger record's field names, and the scorecard's layout.

### Sources

The design follows these published sources.

- DESIGN.md format: <https://github.com/google-labs-code/design.md>
- DTCG Format Module 2025.10: <https://www.w3.org/community/reports/design-tokens/CG-FINAL-format-20251028/>
- Style Dictionary and DTCG: <https://styledictionary.com/info/dtcg/>
- Adobe Spectrum tokens versioning: <https://classic.yarnpkg.com/en/package/@adobe/spectrum-tokens>
- Adobe Spectrum design data tools (token diff): <https://opensource.adobe.com/spectrum-design-data/tools/>
- Breaking changes in tokens: <https://designtokens.substack.com/p/how-to-manage-breaking-changes-in>
- ESLint semantic versioning policy: <https://github.com/eslint/eslint#semantic-versioning-policy>
- stylelint, ignoring code: <https://stylelint.io/user-guide/ignore-code>
- Primer's stylelint config: <https://github.com/primer/stylelint-config>
- postcss-html: <https://github.com/ota-meshi/postcss-html>
- npm trusted publishers: <https://docs.npmjs.com/trusted-publishers>
- GitHub immutable releases: <https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/immutable-releases>
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
- Anthropic, a statistical approach to model evaluations: <https://www.anthropic.com/research/statistical-approach-to-model-evals>
- Anthropic, define success criteria and build evaluations: <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Zheng et al., judging LLM-as-a-judge: <https://arxiv.org/abs/2306.05685>
- Anthropic's skill-creator plugin (snapshot baselines, trigger evals, the review viewer): `claude-plugins-official/plugins/skill-creator/skills/skill-creator/SKILL.md`
- Michael Feathers, characterization testing: <https://michaelfeathers.silvrback.com/characterization-testing>
- Git trailers: <https://git-scm.com/docs/git-interpret-trailers>
- The authoring charter: `~/.claude/docs/authoring-charter.md`
- drafter's prompts module and register settings: `drafter/docs/prompts-module.md`, `drafter/docs/configuration.md`
- Claude Code features overview: <https://code.claude.com/docs/en/features-overview>
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Claude Code subagents (preloading skills): <https://code.claude.com/docs/en/sub-agents>
- Claude Code output styles: <https://code.claude.com/docs/en/output-styles>
- Claude Code hooks: <https://code.claude.com/docs/en/hooks>
- Chrome DevTools MCP design principles (self-healing errors): <https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/design-principles.md>
