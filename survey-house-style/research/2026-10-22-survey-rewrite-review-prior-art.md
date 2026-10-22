# Survey house style rewrite: prior-art review

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `ad97b5f` (cited below as `spec:<line>`). This review compares the design with what published design systems, docs-as-code writing teams, and Claude Code practice do. Geoff's rulings (spec:49-65) stand; where a ruling departs from common practice, this review says so and proposes only a better way to carry it out.

Every claim about another system was checked against a primary page on 2026-10-22, except where a line says it was not checked. The contract review on this branch (`2026-10-22-survey-rewrite-review-contract.md`) already covers the eval statistics in depth. Finding 2 here adds only the external evidence and cross-references it.

## Where Survey stands against practice

Survey matches or leads established practice in five places: version-matched agent docs inside the package, a baseline taken before any writing change, base-standard-first packs with license-checked corpora, a private correction ledger, and token deprecation through `$deprecated` aliases. It falls behind in three places. First, it delivers guidance to agents through the mechanism that published evals show fails most often, and it rests that choice on a premise the Claude Code docs contradict. Second, its eval method departs from published eval statistics and LLM-judge practice. Third, it has no mechanical check that a token release follows the semver policy it adopts. It is heavier than practice in two places: a hand-built style linter where stylelint plugins are the norm, and a custom distribution path for the Claude-facing parts where Claude Code now ships plugins that carry skills, hooks, and output styles together.

## Findings, ranked by consequence

### 1. Agents get Survey guidance through skill triggering and prose lines, and the spec's reason for that is wrong. Major, correctness

Location: spec:14, spec:145, spec:313-314, spec:340, and the Claude-infra map at spec:263-288.

What Survey does: a user-scope `survey` skill is the agent entry point. Four agent definitions get a prose line telling them to read the installed DESIGN.md, because, in the spec's words, "A skill reaches only sessions that hold the Skill tool, and the agents below do not" (spec:313).

What others do and what the docs say:

- Claude Code's subagent docs say the `skills` frontmatter field preloads a skill into a subagent: "The full skill content is injected, not only the description", and "To preload Skills into context, use the `skills` field rather than listing `Skill` here" (<https://code.claude.com/docs/en/sub-agents>). A subagent with no Skill tool still gets a preloaded skill. The premise at spec:313 is wrong. `prose-voice-reviewer` already uses this preload (spec:145).
- The same page says a non-fork subagent loads "every level of the CLAUDE.md hierarchy the main conversation loads, including `~/.claude/CLAUDE.md`, project rules ...". Path-scoped rules (`.claude/rules/*.md` with a `paths:` field) load "when Claude uses the Read, Write, or Edit tool on a matching file", and user-level rules in `~/.claude/rules/` apply in every project (<https://code.claude.com/docs/en/memory>). A rule scoped to `**/*.{css,svelte,html}` therefore reaches the main loop and every implementer at the moment it touches a style file, with no description match involved.
- Vercel's Next.js agent evals measured these mechanisms against each other: the baseline with no docs passed 53%, a skill under default behavior 53%, a skill with explicit instructions 79%, and a compressed docs index in AGENTS.md 100%. "the skill was never invoked" in 56% of cases. Vercel advises framework authors to "consider providing an `AGENTS.md` snippet that users can add to their projects" (<https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals>). This is a first-party result on one framework, but no published result points the other way for reference material an agent must apply every time.
- Cursor has the same pattern: "Auto Attached" rules that are "auto-attached when a matching file is in context" (<https://cursor.com/docs/context/rules>).

Why it matters: the intent at spec:69 is that "An agent working in any of these contexts applies Survey correctly without being briefed." The design meets that intent only when a description matches, or when a prose line in an agent body is followed. That is the weakest of the three mechanisms Claude Code offers. The same gap affects the writing half. The always-on `core` reaches only the main loop through the output style (spec:216, spec:277), but the implementers write two Survey contexts, code comments and commit messages, and receive neither the style nor a skill.

Fold:

1. Strike the premise at spec:313. Give the four agents `skills: [survey]` in frontmatter, in place of the prose line or beside it. Keep the headless `site-implementer` acceptance at spec:317, since it tests the result whatever the mechanism.
2. Add one user-level rule, `~/.claude/rules/survey-visual.md`, with `paths: ["**/*.css", "**/*.svelte", "**/*.html"]`. Its body says: when the nearest `package.json` lists `@glw907/survey`, read `node_modules/@glw907/survey/DESIGN.md` before the first edit, and never invent a value. This is Vercel's "snippet" in Claude Code's own path-scoped form. It reaches subagents through the CLAUDE.md hierarchy. The skill stays the entry point for the recipes. Pass C's acceptance runs the same headless dispatch with the Skill tool absent.
3. For the writing half, record as a Pass H candidate (it changes behavior, so ruling 4's beat rule applies) one path-scoped user rule per comment pack (`**/*.go` to `go-comments`, and so on). These reach the implementers that write comments today without any pack guidance. Before relying on `@` imports inside a rule file, probe them: the memory page documents imports for CLAUDE.md, not for rule files.

### 2. The eval method departs from published eval statistics and LLM-judge practice. Major, correctness

Location: spec:215-220, spec:241-242, spec:247. Cross-reference: contract review findings 1, 2, 6, 8, and 16.

What Survey does: the judge scores a 1-to-5 rubric. A surface "matches" when its mean is at or above the baseline mean minus one standard deviation over three runs of three tasks, and "beats" on a 60% blind preference over nine pairs.

What others do:

- Anthropic's eval-statistics paper recommends reporting "the SEM ... alongside each calculated eval score", "clustering standard errors on the unit of randomization", "a paired-differences test" because both arms answer the same questions, and a power analysis to size the eval (<https://www.anthropic.com/research/statistical-approach-to-model-evals>). Survey compares unpaired means against a draft-level standard deviation and sizes nothing.
- Zheng et al. name "position, verbosity, and self-enhancement biases" as judge limits (<https://arxiv.org/abs/2306.05685>). The standard mitigation is to judge each pair in both orders and score a disagreement as a tie. The spec says only "blind" (spec:217).
- Practitioner guidance on LLM judges says "If your evaluations consist of a bunch of metrics that LLMs score on a 1-5 scale ... you're doing it wrong", and recommends binary pass or fail calls checked against an expert, with true-positive and true-negative rates reported separately (<https://hamel.dev/blog/posts/llm-judge/>). Claude Code's own `claude plugin eval` follows this: an `llm` grader passes when "A judge model votes PASS on the rubric in at least two of three votes" (<https://code.claude.com/docs/en/plugin-evals>).
- The spec's own choice of a different judge model (spec:217) matches published self-preference findings and should stay.

Fold: replace the Likert means with binary per-criterion graders, each decided by a two-of-three judge vote. Compare arms by paired per-task differences with a standard error clustered on the task. Judge every preference pair in both orders, with ties allowed. Size the runs per task from a power calculation for the smallest regression ruling 4 should catch, and record that figure. Report the judge's agreement with Geoff as true-positive and true-negative rates, cumulative across months, not as a monthly percentage. The contract review's folds for the thresholds carry the rest.

### 3. Nothing mechanically enforces the token semver policy. Major, correctness

Location: spec:152-162, especially spec:156 and spec:159.

What Survey does: it adopts Spectrum's token policy (a rename or removal is major and ships first as a deprecated alias in a minor). The changelog is written by hand, and no step compares one release's tokens with the last.

What others do:

- Spectrum ships `@adobe/token-diff-generator`, which "compares token sets and reports added, deleted, renamed, deprecated, and updated tokens", plus a changeset generator driven by that diff (<https://opensource.adobe.com/spectrum-design-data/tools/>).
- Google Labs' `design.md` CLI has a `diff` command that "compares two DESIGN.md files and reports token-level changes" and "exits with code 1 when regressions are detected" (<https://github.com/google-labs-code/design.md>). Survey already pins this CLI at 0.4.0 (spec:124), the current npm version.
- Primer and Spectrum both version with Changesets (`.changeset/` in `primer/primitives`; "Changesets for automated versioning and releasing" in Spectrum design data). Survey's reasons for declining Changesets (spec:159) are sound for one package with Keep a Changelog headings. The loss is the per-change prompt that makes an author state the bump.

Why it matters: the rulings require a versioned style with a changelog that follows established practice (spec:51). A token removed in a minor reaches every app through `dependency-upgrade`'s standing rule to take minors without asking (spec:372), and then the only safeguard is the render read.

Fold: add a release-gate step in Pass B. It builds the token JSON at the last published version (from npm) and at HEAD, diffs them by token path and type, and fails when (a) a removed or retyped token appears in a release that is not major, (b) a renamed token has no `$deprecated` alias, or (c) a changed token has no line under `## [Unreleased]` naming it. Run `design.md diff` beside it as a second check on the agent-facing file. This keeps the hand-kept Keep a Changelog file and gives Spectrum's mechanism without Changesets.

### 4. `survey-check` is a custom linter where design systems ship stylelint plugins. Major, optional

Location: spec:132-141, spec:126 (`bin`), spec:157 (the ESLint-modelled policy).

What Survey does: it writes a standalone checker that parses `.css`, Svelte `<style>` blocks, inline `style=""`, and Tailwind arbitrary values, with its own ignore-comment syntax modelled on stylelint's.

What others do: Primer ships `@primer/stylelint-config`, whose rules `primer/colors`, `primer/spacing`, `primer/borders`, `primer/box-shadow`, and `primer/typography` each "enforce the use of" its variables (<https://github.com/primer/stylelint-config>). Polaris ships `@shopify/stylelint-polaris`, "a configuration of Stylelint rules that promote adoption of the Polaris design system" (<https://polaris.shopify.com/tools>). Atlassian ships a stylelint plugin whose rules "will come with fixers where possible" (<https://unpkg.com/@atlaskit/stylelint-design-system@5.1.4/README.md>). Mozilla's `use-design-tokens` rule autofixes hex colors to tokens (<https://firefox-source-docs.mozilla.org/code-quality/lint/linters/stylelint-plugin-mozilla/rules/use-design-tokens/color.html>). With `postcss-html`, stylelint lints "`<style>` tags and `<div style="*">`" in HTML-like files, Svelte included (<https://github.com/ota-meshi/postcss-html>).

Why it matters: three of the four surfaces at spec:136 come free with stylelint, and so do its disable comments with reasons, severity levels, editor integration, `--fix`, and JSON output for the hook. A custom parser is a public API under the ESLint-style semver policy at spec:157. It is new code to maintain for every CSS syntax edge case.

Fold: build `survey-check` as a stylelint plugin plus a shareable config (exported as `@glw907/survey/stylelint`). The fix-naming messages and the nearest-token logic live in the rules. The `survey-check` bin stays as a thin wrapper that runs stylelint with the config and adds the one surface stylelint can't see, a scan of Tailwind class strings for arbitrary values. The ignore comment becomes stylelint's own `/* stylelint-disable-next-line survey/no-literal -- reason */`, which the spec already models. The fixtures at spec:140 carry over unchanged.

### 5. OWNER FORK: ship the Claude-facing parts as a Claude Code plugin, or keep the vendored skill. Major, optional

Location: spec:166-173, spec:263-288, spec:315.

What Survey does: the skill is vendored through `vendored-skills.json` at a tag. The hook lives in `~/.dotfiles` beside `vale-hook`. The output style and registers become symlinks into the vendored copy, checked by `sha256sum -c`. Each piece reaches both hosts through stow.

What others do:

- A Claude Code plugin carries skills, agents, hooks, MCP servers, and output styles in one versioned unit. Its `version` field "keeps users on that version until you change it", and a plugin output style can set `force-for-plugin` (<https://code.claude.com/docs/en/plugins-reference>, <https://code.claude.com/docs/en/output-styles>).
- Design systems now ship their agent surface the same way: Adobe publishes `@adobe/design-data-skill`, a "Claude Code skill for tokens and component schemas", and an MCP server with a Claude Code skill (<https://opensource.adobe.com/spectrum-design-data/tools/>). Atlassian generates an `atlassian-design-system` skill from its llms.txt content and publishes it through `@atlassian/skills` (<https://atlassian.design/llms.txt>).

The constraint: `${CLAUDE_PLUGIN_ROOT}` "changes when the plugin updates" (plugins reference). The approval queue's gate and brief check read the brief register at a fixed path (spec:284), and ruling 4's byte-identity checks rely on stable paths. A plugin would break both unless a stable symlink stays.

Options:

- **(a) Keep the vendored skill as designed.** It is the workstation's existing channel and fits the manifest rules.
- **(b) Survey ships a plugin from its own repo, as its own marketplace.** The skill, the PostToolUse `survey-check` hook, and the `writing-voice` output style ship together, pinned by version. Fixed-path consumers keep a symlink into the plugin data directory. This is one home instead of three.
- **(c) Keep (a) through the verbatim move (Passes D and E), and evaluate (b) in Pass F, when the skill gains its corrections route and is re-released anyway.**

Recommendation: (c). Ruling 4 weighs against changing the delivery channel during the measured move. Once the move has passed, a plugin removes the symlink and stow layer and the separate hook install.

### 6. The trigger tests are a quarter of the size skill-creator prescribes. Minor, correctness

Location: spec:317 (three should-trigger and two should-not prompts), spec:340, spec:357, spec:424.

What others do: skill-creator, which the spec cites as its method, says to "Create 20 eval queries", 8 to 10 that should trigger and 8 to 10 that should not, where "the most valuable ones are the near-misses". It "splits the eval set into 60% train and 40% held-out test" and iterates with `scripts.run_loop` (<https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md>).

Why it matters: the corrections route (spec:357) fires on chat that looks like many other requests, so its near-misses decide its precision. Five prompts with one rewording (spec:424) is the method's smallest form, not the method itself.

Fold: use skill-creator's 20-query set with near-misses and its held-out split for the `survey` skill in Pass C and for the corrections route in Pass F. Keep the "reword once, then escalate" answer.

### 7. Learning from edits: measure edit distance and infer a preference at intake. Minor, optional

Location: spec:223-231, spec:241, spec:244.

What others do: PRELUDE and CIPHER (Gao et al., NeurIPS 2024) learn from user edits without fine-tuning. CIPHER "infer[s] the user preference for a given context based on user edits", "retrieves inferred preferences from the k-closest contexts", and is scored by "the lowest edit distance cost" (<https://www.microsoft.com/en-us/research/publication/aligning-llm-agents-by-learning-latent-preference-from-user-edits/>). No public writing team (Mailchimp, GOV.UK, Google) documents a systematic capture of editor corrections. Google's "What's new" page logs guidance changes as dated rows, some with reasons (<https://developers.google.com/style/whats-new>). Survey's ledger is ahead of the style-guide field here.

Fold: two cheap additions. (a) At intake, store a one-line inferred preference beside each before-and-after pair, so the monthly distill groups preferences rather than raw diffs. (b) Add a per-surface edit-distance column to the scorecard: normalized character edit distance between Claude's draft and what Geoff kept, over the month's harvested corrections. It needs no judge and is grounded in Geoff's own behavior. It is the direct measure of ruling 5's promise that his corrections reduce over time, and it answers part of the contract review's finding 8.

### 8. Claude Code's auto memory also records chat corrections. Minor, optional

Location: spec:228.

What Claude Code does: auto memory holds "notes Claude writes itself based on your corrections and preferences", per repository, and loads into every session (<https://code.claude.com/docs/en/memory>).

Why it matters: a wording correction in chat can land in two places, the Survey ledger and that repo's auto memory. The memory copy then applies a local rule that no eval measured and that may conflict with the pack. That is a quiet form of the "copies that drift" failure at spec:92.

Fold: the corrections route's text in the `survey` skill states that a wording correction goes to the ledger and not to auto memory. Pass F's acceptance checks that a planted chat correction writes no auto-memory line.

### 9. `claude plugin eval` now covers part of the custom harness. Minor, optional

Location: spec:216-217, spec:325.

What exists: `claude plugin eval` runs cases with `regex`, `tool_used`, `llm`, and `baseline` graders, three runs per arm by default, with a with-plugin and no-plugin arm, an HTML and JSON report, and a CI exit code (<https://code.claude.com/docs/en/plugin-evals>). Its troubleshooting section lists "plugin eval is currently in early access", so availability is not assured. Its arms are with and without the plugin, not an old version against a new one.

Fold: no change to Pass D's two-arm runner. If finding 5 goes to (b) or (c), Pass F evaluates moving the deterministic graders (tells as `regex`, Vale through a file grader) and the trigger checks into a plugin eval suite. That would let CI gate a Survey release without the custom runner for those parts.

### 10. Upgrades rely on an agent reading the changelog; others ship codemods or autofix. Minor, optional

Location: spec:148.

What others do: Polaris ships `@shopify/polaris-migrator`, whose codemods swap hard-coded values for tokens and leave a `polaris-migrator:` comment where a person must decide (<https://polaris.shopify.com/version-guides/migrating-from-v11-to-v12>). Atlassian lists "a codemod CLI for migrations" in its llms.txt.

Fold: once finding 4 lands, `survey-check --fix` rewrites a deprecated token name to its `$deprecated` target, and a literal that equals exactly one token value to that token. Both rewrites are deterministic. The changelog step for the agent stays for everything else.

### 11. The light and dark structure is a house convention where DTCG 2025.10 has a standard one. Minor, optional

Location: spec:119-121.

What others do: DTCG 2025.10 adds resolvers. In Terrazzo's words, "Resolvers are a DTCG standard", used for "light/dark mode", with a `theme` modifier whose `contexts` map each mode to its token files (<https://terrazzo.app/docs/guides/resolvers/>). Primer keeps one file per mode (`light.high-contrast.json5` and others in `primer/primitives`). Style Dictionary says 2025.10 "does not have full support yet" (<https://styledictionary.com/info/dtcg/>), and the mechanics probe found it silently drops `$extends`.

Fold: author `base`, `light`, and `dark` as separate set files with a resolver document beside them, and have the Style Dictionary config read the sets. The source is then standard, the per-platform filter becomes a build detail, and Terrazzo (2.10.0) remains a drop-in fallback if Style Dictionary drops something else.

### 12. Token-level usage metadata for agents. Minor, optional

Location: spec:121 (`$description` required), spec:124.

What others do: Primer adds `org.primer.llm` metadata per token, with `usage` ("Max 3 items") and `rules` ("Include MUST/SHOULD/Do NOT guidance"), and generates an agent-facing `DESIGN_TOKENS_SPEC.md` from it. A hand-written `DESIGN_TOKENS_GUIDE.md` holds a pairing matrix ("MUST pair", "NEVER use") (`primer/primitives`, `contributor-docs/agents/token-authoring.md` and `DESIGN_TOKENS_GUIDE.md`).

Fold: add `$extensions["pub.survey"]` (or the builder's chosen key) with `usage` and `pairsWith` to the token source. Generate DESIGN.md's token sections and its `components` pair list from that metadata, so the prose agents read can't drift from the tokens. The contrast audit can then read the same pair list.

### 13. Vale packages can carry config and vocabulary. Minor, optional

Location: spec:166-175.

What Vale says: a package "holds a style, a configuration file, or both". A bundled `.vale.ini` "is read before your own", and a package "can carry a vocabulary" (Vale 3.25.0 or later). For synced output, Vale says "most projects ignore it" (<https://docs.vale.sh/keys/packages>). Survey's committed copy departs from that, for a stated reason: drafter inlines only tracked files (spec:172). That reason holds.

Fold: from Pass G, once the house register adds a vocabulary, ship it inside `Survey.zip` and the npm `vale/` directory, so each repo's accept list follows its pin. Record the Vale 3.25 floor in the zip channel's notes, since the probes ran on 3.24.0.

### 14. The "X but not Y" form is one device inside Mailchimp's traits, not their form. Minor, optional

Location: spec:253.

What Mailchimp does: four traits, "We are plainspoken", "We are genuine", "We are translators", "Our humor is dry". The "but not" contrasts ("weird but not inappropriate, smart but not snobbish") sit inside the humor trait (<https://styleguide.mailchimp.com/voice-and-tone/>).

Fold: state each trait as a short name with a paragraph, and use "but not" contrasts inside it where they sharpen the trait. The NN/g tone table stays as written.

## Where Survey is ahead or matches, and should keep its approach

- **Version-matched docs in the package, and no MCP server** (spec:147, spec:150). Primer, Carbon, Atlassian, and Adobe each ship an MCP server. Primer's documented setup runs `npx @primer/mcp@latest` (<https://primer.style/product/getting-started/foundations/mcp>), which serves the newest guidance whatever version the repo installed. Carbon's is hosted and gated by access request (<https://carbondesignsystem.com/developing/carbon-mcp/overview/>). Reading `node_modules/@glw907/survey/DESIGN.md` gives the exact installed version, which is what Vercel's codemod reconstructs by downloading version-matched docs. Keep it. Finding 1 changes only how agents are pointed at the file.
- **Baseline before any writing change** (spec:213, spec:62). Characterization testing and Anthropic's evaluation-driven development are the right frame, and no published writing system measures a style-guide migration at all. Keep it, with finding 2's statistics.
- **Base standard first, with license-checked corpora** (spec:256). Pinning Microsoft excerpts to the CC BY 4.0 source repository at a fixed commit is more careful than any published house guide that builds on Microsoft's. Anthropic's own `brand-guidelines` skill inlines hex values and fonts in SKILL.md with no versioning (<https://raw.githubusercontent.com/anthropics/skills/main/skills/brand-guidelines/SKILL.md>). Survey's rule that the skill holds no values and routes to the installed file is stronger.
- **The private ledger and its four channels** (spec:223-231). See finding 7. This is novel, and the edit-based learning literature supports it.
- **Deprecated aliases through `$deprecated`** (spec:138, spec:148). This matches Primer's documented practice exactly: "`$deprecated` contains the new token path", with the alias's `$value` pointing at it.
- **Fix-naming checker messages and an `AGENTS.md` for the repo** (spec:134, spec:149). Primer's `primer/primitives` carries an AGENTS.md with its mandatory gate commands. Claude Code reads AGENTS.md when no CLAUDE.md is present (<https://code.claude.com/docs/en/memory>). Keep both.
- **A zip channel pinned by release URL** (spec:169). This is the form Vale's docs recommend where "a new rule arriving unexpectedly would be disruptive".
- **The advisory PostToolUse hook** (spec:315). This follows Claude Code's guidance that "something that has to happen every time" belongs in a hook (<https://code.claude.com/docs/en/output-styles>).

## Sources not verified

- Whether `@atlaskit/eslint-plugin-design-system`'s `ensure-design-token-usage` rule autofixes. The README excerpt was cut off, so finding 4 cites Atlassian's stylelint plugin instead.
- The 65% position-consistency figure for MT-Bench judges circulates only in secondary posts, so finding 2 cites only the abstract's naming of position bias.
- Grafana's Vale distribution is by container image (`make grafana/vale`, <https://github.com/grafana/writers-toolkit/tree/main/vale>). Elastic's `vale-rules` installs by script. Neither changes a finding.
