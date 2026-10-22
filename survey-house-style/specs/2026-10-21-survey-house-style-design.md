# Survey house style: design

## Brief

This makes Survey the one written house style for every house tool, published as a versioned package that each app follows through ordinary dependency updates.

Survey now exists in three places that have drifted apart: the approval queue's vendored copy, the 2026-10-07 spec, and its approved specimen. Bulwark webmail and the phonebook's UI both wait on it, and 907.life will take it in its rebuild.

### What changes

- A new `survey` repo holds Survey's tokens, principles, shared CSS, specimen, versions, and changelog.
- One token source generates three outputs: a drop-in daisyUI theme, a plain CSS-variable sheet, and a DESIGN.md that agents read first.
- A `survey` skill, an advisory edit hook, and two reviewer agents tie Survey into the workstation's Claude tooling, so an agent in any repo applies it without being briefed.
- Each app later moves to the package in its own pass, so all of them end up looking alike.

### If you approve

1. Pass A compares the approval queue, the spec, and the specimen. It then brings you every difference, and every rule it proposes to add, as a side-by-side render with a recommendation, in one sitting.
2. Pass B builds the `survey` repo from your rulings. You read the built specimen, and then it releases 1.0.0.
3. The approval queue, the phonebook, Bulwark, and 907.life each take 1.0.0 in a pass of their own.

### Rulings

Survey is published from a public repo to npm as `@glw907/survey`, with trusted publishing, the way cairn is (Geoff, 2026-10-21). Bulwark's theme waits until this work is complete, at the 1.0.0 release (Geoff, 2026-10-21).

### Worth knowing

The phonebook has no UI yet, so it adopts Survey fresh rather than converging. cairn-themes keeps its theme ports and gives up `survey-theme/`, its Survey spec, and its backlog items #1 and #2 to the new repo.

### Intent

Every house tool should read as one family. Where we hold every lever (the approval queue, the phonebook, 907.life's cairn layer), the tool should also carry Survey's felt craft. Where an app exposes only a few levers, such as Bulwark, it should still be recognizably Survey. An agent working in any of these contexts should apply Survey correctly without being briefed. Each app should be able to follow Survey as it improves, through a version bump and a changelog that says what to do.

None of the three existing versions is the reference. Each looks good, and each may change a little to match the principles this work writes down (Geoff, 2026-10-21).

### Goals

- One written house style: principles, tokens in light and dark, and per-context recipes.
- A ladder of levers ranked by how much resemblance each carries, so a partial adopter knows what to take first.
- Releases under Semantic Versioning, each with a changelog entry that names the consumer's action.
- Agent-friendly from the ground up: version-matched docs, role-named tokens, a conformance check with fix-naming errors, and upgrade steps an agent can carry out.

### Non-goals

- Restyling the cairn admin. It keeps its own design system.
- Packaging Survey as a selectable cairn theme (cairn-themes S3, cairn's work).
- The terrain hero from elevation data.
- Building any consumer's convergence inside Pass A or Pass B.

### Anti-goals

- A style that only works where every lever exists, which leaves Bulwark-class apps generic.
- Copies that drift, where an app can't tell which Survey it has or what changed since.
- Rules an agent has to infer from CSS, or values it is free to invent.

### The lever ladder

An app adopts from the top down, as far as its theming surface allows. Palette carries the most resemblance and is the first rung: paper, ink, and water in light and dark, with the status colors. Shape comes next, meaning radii, 1px borders, no shadows, and the focus ring. Type is the third rung: Spectral, Karla, and Monaspace Neon, with a named system-font stack for apps that can't load web fonts. Motion is the fourth, and the signature details are the fifth (contour texture and rules, benchmark triangle, margin collar, index rail, the frame). Full-lever apps take all five rungs. Bulwark takes rungs one to three, because its theme filter strips `url()`.

### Decided parts of the how

These are Claude's calls under the architecture rule, each from published practice.

- **Token source.** One file in the DTCG 2025.10 format (W3C Design Tokens Community Group, first stable release), with light and dark sets. Style Dictionary, which reads DTCG natively, builds the outputs.
- **Outputs.** A drop-in daisyUI 5 theme: the light and dark `@plugin "daisyui/theme"` blocks and the `@theme` scale, which any daisyUI project imports in one line after activating the plugin. It is the default recipe for a new house tool, since Geoff builds most tools on daisyUI (Geoff, 2026-10-21). A plain CSS-variable sheet with light and dark sets for token-only apps. A DESIGN.md in Google Labs' format, tokens in front matter and principles in prose, ending in its "Do's and Don'ts" section. The DESIGN.md CLI's `lint` runs in the gate, including its WCAG contrast rule, beside the existing `theme-contrast` check.
- **Shared CSS.** The component overrides and signature details stay hand-written CSS in the package, under the existing `site-*` and `--site-*` prefixes, with each override's component and reason recorded beside it (the DaisyUI-first rule).
- **Versioning.** Semantic Versioning 2.0.0, following Adobe Spectrum's token policy. Renaming or removing a token, or changing its type, is major, and it ships first as a deprecated alias in a minor release. A new token, rule, or intentional value change is minor. A fix with no visible change is a patch. Changesets writes each change's entry, and the changelog follows Keep a Changelog 1.1.0. Each entry names its rung and the consumer's action, if any.
- **Following updates.** The SvelteKit apps take the package as a dependency, so the `dependency-upgrade` skill carries every bump: minors and patches by default, majors only with Geoff's yes. Bulwark's theme bundle is built from the CSS-variable sheet at a pinned version kept in the servers repo, and the same skill bumps it. 907.life's cairn layer imports the package; the rebuild's `engine-consult` settles how the chassis takes it.
- **Agent entry.** A `survey` skill in the workstation repo routes by context: a cairn site, a SvelteKit and daisyUI tool, or a token-only app. It points at the package's DESIGN.md and the one recipe that applies, and it forbids a value the tokens don't hold. The CLAUDE.md line from PR #131 points at the skill.

### Agent-friendly by construction

Agents are Survey's main users, so every part of it is built to be read and checked by one (Geoff, 2026-10-21).

- **The docs travel with the version.** The npm package ships DESIGN.md and the token JSON, so an agent in a consumer repo reads `node_modules/@glw907/survey/DESIGN.md` for the exact version installed, never a newer page.
- **Names carry meaning.** Tokens are named for their role (`paper`, `ink`, `water`, `focus-ring`), never for a raw value. Each one carries a DTCG `$description` that says when to use it.
- **Rules are short and checkable.** Each principle in DESIGN.md is one imperative sentence that a check or a reviewer can test, paired with its "Do's and Don'ts" entry.
- **A conformance check.** The package ships a `survey-check` command that a consumer's gate runs. It flags a color, radius, shadow, or duration literal that no token holds, and its message names the token to use instead, following the self-healing error pattern from the Chrome DevTools MCP design principles.
- **Upgrades an agent can do.** Each changelog entry names the consumer's action as a concrete step, such as "replace `--survey-shade` with `--survey-paper-2`". A deprecated token stays as an alias until the next major.
- **A map for working on Survey itself.** The repo carries an `AGENTS.md` (the open agents.md format) with its build, gate, and release commands, beside DESIGN.md at the root.

An MCP server is left out. The skill and the shipped files carry the same content without a running service.

### Claude infrastructure

Survey joins the workstation's Claude tooling under the `claude-infra` rules (Geoff, 2026-10-21). Each rule takes the strongest home Anthropic's features overview names: a hook for what must hold every time, a skill for reference material needed sometimes, and CLAUDE.md for a fact that applies every turn.

- **Hook.** An advisory PostToolUse hook runs `survey-check` on a CSS, Svelte, or HTML file just edited in a repo that depends on Survey. Its findings come back to the session as context, the way `vale-hook` and the tellgrader hook already work. It never blocks.
- **Skill.** The `survey` skill sits at user scope in the workstation repo, so it reaches implementer and reviewer subagents as well as the main loop. Its description triggers on UI work in a house tool. Its body routes to the context's recipe and to the installed DESIGN.md.
- **Agent definitions.** `visual-verifier` and `daisyui-a11y-reviewer` each gain one line: in a repo that depends on Survey, read the installed DESIGN.md and grade against its rules.
- **CLAUDE.md.** The line from PR #131 names the `survey` skill in place of the backlog item.
- **Manifests.** The skill and the hook get their manifest entries, `claude-tooling-sync verify` passes, and `check-drift` covers them. The change lands as a workstation PR whose commits cite the Anthropic pages it follows.

### Pass A: harvest and rulings

Pass A reads the approval queue's `src/lib/survey/`, `src/app.css`, and `src/lib/components/frame/frame.css`, the 2026-10-07 spec, and the approved specimen. It sorts everything into rungs and into agreements and differences, and it decides which of the approval queue's newer rules are Survey and which belong to the app alone. That sort includes the focus ring, fields, key hints, toast, float shadow, frame, scrollbars, and the motion tokens. The agreements become the draft principles. Each difference reaches Geoff as one ruling in a single sitting: two renders side by side in Chromium, with a recommendation. The same sitting carries each approval-queue rule Claude proposes to promote into Survey, rendered in the specimen. Geoff sees every addition before 1.0.0 fixes the token names (Claude's call).

Pass A starts by looking for cairn-themes commit `dea9839` on thinkpad-x1. No branch on pavilion holds it, and a copy there would be a fourth version. Pass A ends by writing the amended specimen as a new dated reference in `reference/`. Pass B grades against that file.

### Pass B: the repo and 1.0.0

Pass B creates the repo, moves `survey-theme/` and the Survey spec out of cairn-themes, builds the token source and the three outputs from Pass A's rulings, ports the living specimen, sets up Changesets and the release workflow, and writes the skill. Geoff reads the built specimen in Chromium before 1.0.0 is published, as the 2026-10-07 spec required before any consumer took the core. The skill lands as its own workstation change after PR #131 merges.

Three of Claude's calls shape Pass B. Contrast runs through cairn's audit (`theme-contrast`), with `@glw907/cairn-cms` as a dev dependency, as the 2026-10-07 spec set up. Fonts stay Fontsource dependencies. The cairn-site recipe ships in 1.0.0 marked pending, and 907.life's rebuild fills it in a minor release once its `engine-consult` settles how the chassis takes the package.

### End-to-end check

From a clean clone, the build produces all three outputs, and DESIGN.md `lint` and `theme-contrast` both pass in both schemes. The specimen, built from the package, is screenshotted at 320, 390, 768, 1440, and 2560px in both schemes. A fresh-context `visual-verifier` then grades it against the approved specimen as amended by the rulings, with no STRUCTURAL finding. A plain HTML page that loads only the CSS-variable sheet shows the palette, shape, and fallback type in both schemes.

### Risk and estimate

Both passes are `ordinary`. Pass B is `live-account`, since it creates a GitHub repo and publishes to npm. The estimate is 180 path minutes for Pass A and 420 for Pass B. No recent score covers theme work, so the planner checks these figures against the plan.

### Pre-flight

- [you: approve the npm trusted-publishing link for `@glw907/survey` on npmjs.com]

### Left to the builder

The token names, Style Dictionary's configuration, the specimen's harness, the skill's wording, and the CSS-variable sheet's prefix are all left to the builder. So is how the recipes split between the skill and DESIGN.md.

### Sources

- DESIGN.md format: <https://github.com/google-labs-code/design.md>
- DTCG Format Module 2025.10: <https://www.w3.org/community/reports/design-tokens/CG-FINAL-format-20251028/>
- Style Dictionary and DTCG: <https://styledictionary.com/info/dtcg/>
- Adobe Spectrum tokens versioning: <https://classic.yarnpkg.com/en/package/@adobe/spectrum-tokens>
- Breaking changes in tokens: <https://designtokens.substack.com/p/how-to-manage-breaking-changes-in>
- Primer primitives: <https://github.com/primer/primitives>
- Semantic Versioning 2.0.0: <https://semver.org/>
- Keep a Changelog 1.1.0: <https://keepachangelog.com/en/1.1.0/>
- AGENTS.md: <https://agents.md/>
- Claude Code features overview: <https://code.claude.com/docs/en/features-overview>
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Claude Code hooks: <https://code.claude.com/docs/en/hooks>
- Chrome DevTools MCP design principles (self-healing errors): <https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/design-principles.md>
