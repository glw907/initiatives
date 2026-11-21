# Audit of the `standards` plugin against Anthropic's plugin, skill, and subagent docs

Date: 2026-11-20. Scope: the tracked files on `main` of the `standards` marketplace repo
(`~/Projects/standards`), the installed copy, and how the workstation's user settings enable it.
The marketplace's real name contains an account handle, so this report writes it as
`<owner>-standards`.

Sources, fetched 2026-11-20 (HTTP 200 for all six, saved in `docs/` beside this report). The
live skills and best-practices pages were byte-identical to the saved copies from earlier in
the session.

| Short name | URL | Saved file |
| --- | --- | --- |
| skills | https://code.claude.com/docs/en/skills.md | `docs/code-skills.md` |
| best-practices | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md | `docs/platform-agents-and-tools-agent-skills-best-practices.md` |
| sub-agents | https://code.claude.com/docs/en/sub-agents.md | `docs/code-sub-agents.md` |
| plugins | https://code.claude.com/docs/en/plugins.md | `docs/code-plugins.md` |
| plugins-reference | https://code.claude.com/docs/en/plugins-reference.md | `docs/code-plugins-reference.md` |
| marketplaces | https://code.claude.com/docs/en/plugin-marketplaces.md | `docs/code-plugin-marketplaces.md` |

Line numbers such as "skills L404" are line numbers in the saved file.

## 1. Short answer: the gaps that matter most

1. **Evaluations barely exist, and nothing runs them.** Three `claude plugin eval` cases cover
   3 of 28 skills and none of the 9 agents, and one of the three tests `running-passes`, which is
   being retired. CI never runs `claude plugin eval`. The docs say a plugin skill is evaluated
   with `claude plugin eval`, which "exits non-zero below a threshold so you can gate CI on it"
   (skills L972), and the authoring checklist asks for "At least three evaluations created"
   per skill (best-practices L1172).
2. **The plugin costs context in every session, and the skill listing is already overflowing.**
   It is enabled at user scope, so 27 model-invocable skill descriptions (about 8,800
   characters) and 9 agent descriptions (about 2,800 characters) sit in every session's context
   (plugins L51). In this session the listing dropped the descriptions of `vale-ci`, `vale-fix`,
   `vale-triage`, and `vale-vocab`. Their frontmatter is valid; the listing "drops descriptions
   starting with the skills you invoke least" when it passes its budget (skills L1234).
   `skillOverrides` cannot trim plugin skills (skills L951). Project-only parts (`cairn-figure`,
   `figure-verifier`, and the site content skills) load in every repo.
3. **The old process is still the plugin's routing.** `running-passes`, `spec-plan-review`,
   `plan-reviewer`, step 4 of `brainstorming`, the `diff-reviewer` description, and the
   `backlog-sweep` description send work to a "pass guide" and `standards:running-passes`. The
   plugin's own manifest and marketplace descriptions advertise "a short pass lifecycle". While
   the workstation's own process skills replace these, Claude sees two sets of triggers for the
   same moments. The docs ask for descriptions specific enough to pick one skill (best-practices
   L214) and one subagent (sub-agents L1320).
4. **The `brainstorming` visual companion runs its scripts by a path relative to the working
   directory.** `visual-companion.md:53` and six more lines run `bash scripts/start-server.sh`.
   The docs say to use `${CLAUDE_SKILL_DIR}` "to reference scripts or files bundled with the
   skill, regardless of the current working directory" (skills L495).
5. **`golang-spf13-cobra` pre-approves broad tools, including tools that may not exist.** Its
   `allowed-tools` grants Edit, Write, `Bash(git:*)`, Agent, WebFetch, and MCP tools from servers
   the plugin does not ship. The docs warn that "A skill can grant itself broad tool access"
   (skills L625) and say "Don't assume packages are available" (best-practices L1111).
6. **`go-ship` depends on an agent from another plugin without declaring it.** It dispatches
   `code-simplifier:code-simplifier` (`go-ship/SKILL.md:32`). `plugin.json` has a `dependencies`
   field for "Plugins that must be enabled for this one to work" (plugins-reference L213). The
   step also overlaps the bundled `/simplify`, which the skill itself names.
7. **Some skills and agents carry dated history and project anecdotes.** Examples:
   `figure-verifier` names dated rulings in its description, `visual-verifier.md:33` cites a
   dated miss, and `design-refinement`, `visual-fidelity`, and `plan-reviewer` tell stories of
   past rounds. The docs say "Don't include information that will become outdated"
   (best-practices L576). The README says "Anything in it works in any repository".
8. **Two descriptions are long or hold the wrong content.** `go-architecture-reader` (506
   characters) and `diff-reviewer` (488) carry process rules and scope mechanics in the
   description, and `diff-reviewer` has no "use when" trigger. The docs say to "keep them short"
   and "move detail into each subagent's system prompt" (sub-agents L27).
9. **The reference check has a blind spot.** `scripts/check-references.mjs:21` skips every file
   named `SKILL.md`, so `daisyui/colors/SKILL.md` (146 lines, a reference file in practice) has no
   contents list and still passes. The docs ask for a table of contents in "reference files
   longer than 100 lines" (best-practices L410).

What already meets the docs: the layout, both manifests, and the marketplace entry validate.
`claude plugin validate` passes on the plugin and on the marketplace, with only the
missing-`version` warning, which the repo accepts on purpose. Every SKILL.md is under 500 lines.
Names and description lengths meet the limits, and every agent sets `tools`, `model`, and
`effort`.

## 2. Checklist from the docs

Each item gives the rule, the sentence it rests on, and its source.

### Skills

| # | Item | Quote | Source |
| --- | --- | --- | --- |
| S1 | Frontmatter fields: all optional in Claude Code; only `description` recommended | "All fields are optional. Only `description` is recommended so Claude knows when to use the skill." | skills L397 |
| S2 | Unknown fields are ignored silently | "Claude Code ignores a field it doesn't recognize without reporting an error." | skills L397 |
| S3 | `name`: at most 64 characters, lowercase letters, numbers, hyphens, no reserved words | "Maximum 64 characters", "Must contain only lowercase letters, numbers, and hyphens", "Cannot contain reserved words: `anthropic`, `claude`" | best-practices L153-156 |
| S4 | `description`: non-empty, at most 1,024 characters on the API side | "Maximum 1,024 characters", "Should describe what the Skill does and when to use it" | best-practices L161-163 |
| S5 | Listing cap and key use case first | "Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing" | skills L404 |
| S6 | Third person | "**Always write in third person**. The description is injected into the system prompt" | best-practices L205-206 |
| S7 | What and when, with key terms | "Include both what the Skill does and specific triggers/contexts for when to use it." | best-practices L212 |
| S8 | Naming pattern | "Consider using **gerund form** (verb + -ing) for Skill names" (a suggestion, not a rule) | best-practices L170 |
| S9 | SKILL.md length | "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files." | skills L559; best-practices L257 |
| S10 | Concise body | "Once a skill loads, its content stays in context across turns, so every line is a recurring token cost." | skills L380 |
| S11 | Important rules near the top (compaction keeps the first 5,000 tokens) | "put the most important instructions near the top of `SKILL.md`"; re-attach keeps "the first 5,000 tokens of each" | skills L1230, L617 |
| S12 | Reference files linked from SKILL.md, one level deep | "Keep references one level deep from `SKILL.md`." | best-practices L382; skills L548 |
| S13 | Contents list in long references | "For reference files longer than 100 lines, include a table of contents at the top." | best-practices L410 |
| S14 | Bundled scripts by variable path | `${CLAUDE_SKILL_DIR}`: "Use this in bash injection commands to reference scripts or files bundled with the skill, regardless of the current working directory." | skills L495; `${CLAUDE_PLUGIN_ROOT}` at L497 |
| S15 | No assumed packages or tools | "Don't assume packages are available" | best-practices L1111 |
| S16 | Fully qualified MCP tool names | "always use fully qualified tool names to avoid "tool not found" errors" | best-practices L1091 |
| S17 | Invocation control for side effects | `disable-model-invocation: true`: "Use this for workflows with side effects or that you want to control timing" | skills L565 |
| S18 | Background knowledge | `user-invocable: false`: "Use this for background knowledge that isn't actionable as a command." | skills L567 |
| S19 | `allowed-tools` grants without prompting | "A skill can grant itself broad tool access, so review the `allowed-tools` of skills" | skills L623-625 |
| S20 | No time-sensitive content | "Don't include information that will become outdated" | best-practices L576 |
| S21 | Consistent terminology | "Choose one term and use it throughout the Skill" | best-practices L607 |
| S22 | Rules that must always hold go in hooks | "Claude skipped a rule that must hold every time: move the rule into a hook" | skills L1228 |
| S23 | Evaluations, built first, with a baseline | "Create evaluations BEFORE writing extensive documentation." "Build three scenarios" | best-practices L750-756 |
| S24 | Plugin skills are evaluated with `claude plugin eval` | "For a skill that ships in a plugin, `claude plugin eval` runs each prompt in an isolated session with and without the plugin ... and exits non-zero below a threshold so you can gate CI on it" | skills L972 |
| S25 | Two eval formats are not interchangeable | "the skill-creator plugin below runs a similar loop with its own `evals/evals.json` format. The two formats aren't interchangeable." | skills L972 |
| S26 | Test with every model in use | "Tested with Haiku, Sonnet, and Opus" | best-practices L1173 |
| S27 | Listing budget | "if you have many skills, Claude Code drops some descriptions to fit the listing's character budget" | skills L1234 |

### Subagents

| # | Item | Quote | Source |
| --- | --- | --- | --- |
| A1 | Required fields | "Only `name` and `description` are required." | sub-agents L290 |
| A2 | Field set | `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills`, `initialPrompt`, `memory`, `background`, `omitClaudeMd`, `effort`, `isolation`, `color`, and more | sub-agents L297-317 |
| A3 | Fields a plugin agent cannot use | "plugin subagents don't support the `hooks`, `mcpServers`, or `permissionMode` frontmatter fields." | sub-agents L236 |
| A4 | Description drives delegation | `description`: "When Claude should delegate to this subagent"; "Claude uses each subagent's description to decide when to delegate tasks." | sub-agents L300, L25 |
| A5 | Short descriptions | "Those descriptions take up context, so keep them short ... move detail into each subagent's system prompt" | sub-agents L27 |
| A6 | One subagent per description | "Make each description specific enough to route to the right subagent" | sub-agents L1320 |
| A7 | Limit tools | "**Limit tool access:** grant only necessary permissions for security and focus" | sub-agents L1321 |
| A8 | Allowlist or denylist | "use the `tools` field as an allowlist or the `disallowedTools` field as a denylist" | sub-agents L474 |
| A9 | Model | accepts an alias, "a full model ID such as `claude-opus-5-5`", or `inherit`; the per-invocation parameter wins over the definition | sub-agents L303, L357-361 |
| A10 | Effort | "On another model, that level doesn't apply. To choose its level, set the `effort` field." | sub-agents L440 |
| A11 | What a subagent is for | "Use one when a side task would flood your main conversation ... Define a custom subagent when you keep spawning the same kind of worker with the same instructions." | sub-agents L9 |
| A12 | Focused design | "**Design focused subagents:** each subagent should excel at one specific task" | sub-agents L1319 |
| A13 | `omitClaudeMd` | "Use it for subagents that take everything they need from the delegation prompt" | sub-agents L312 |
| A14 | Delegation evals | "`claude plugin eval` runs each prompt with and without the plugin and scores the results." | sub-agents L872 |

### Plugin and marketplace

| # | Item | Quote | Source |
| --- | --- | --- | --- |
| P1 | Manifest location | "Save the manifest at `.claude-plugin/plugin.json` under the plugin root. Put every other plugin file at the plugin root" | plugins-reference L34 |
| P2 | Required manifest key | "`name` is the only required key." Use kebab-case. | plugins-reference L120, L166 |
| P3 | Version | "Setting it keeps users on that version until you change it" | plugins-reference L129, L189 |
| P4 | Validator | "`claude plugin validate` is the authoritative check for a manifest." A missing `version` is a warning; "Pass `--strict` to turn warnings into failures in CI" | plugins-reference L101, L110 |
| P5 | Default layout | `skills/` "One `<name>/SKILL.md` per skill"; `agents/`; `bin/` "Files here are on the Bash tool's `PATH`" | plugins-reference L615-626 |
| P6 | No root CLAUDE.md | "A `CLAUDE.md` at the plugin root isn't loaded as context" | plugins-reference L660 |
| P7 | Evals directory | `experimental.evals`: directory for eval cases "when it isn't the default `evals/`" | plugins-reference L160 |
| P8 | Dependencies | "Plugins that must be enabled for this one to work." | plugins-reference L213 |
| P9 | Marketplace required fields | "The file requires a `name`, an `owner`, and a `plugins` array." Each entry "needs a `name` and a `source`." | marketplaces L48-50 |
| P10 | Entry name equals manifest name | "Keep the two names the same." | marketplaces L149 |
| P11 | Validate after every edit | "run `claude plugin validate ./my-marketplace` in your shell after every edit" | marketplaces L187 |
| P12 | Context cost of an enabled plugin | "for each skill, agent, and command that Claude can invoke on its own, the name and description are in Claude's context on every turn" | plugins L51 |
| P13 | Install scope | User scope: "enabled for you in every project on this computer"; project scope through the committed `.claude/settings.json` | plugins L103-104 |
| P14 | Footprint check | "Run `/skill-doctor` to see what each of your skills costs and how often it gets used" | skills L955 |

## 3. Plugin and marketplace layout

| Item | Docs rule | This repo | Verdict |
| --- | --- | --- | --- |
| Marketplace file | `.claude-plugin/marketplace.json` with `name`, `owner`, `plugins` (P9) | Present with all three | Meets |
| Marketplace entry | `name`, `source`, `description` (P9, marketplaces L125) | `standards`, `./plugins/standards`, description | Meets |
| Entry name and manifest name | Same (P10) | Both `standards` | Meets |
| Manifest | `.claude-plugin/plugin.json`, `name` kebab-case (P1, P2) | Present; `name`, `description`, `author`, `license`, `repository` | Meets |
| `version` | Optional; setting it pins users (P3) | Absent on purpose (`scripts/validate-warnings.mjs:2`); the install records the commit SHA as the version | Meets; the validator's one warning is expected |
| `dependencies` | Declare plugins this one needs (P8) | Absent, though `go-ship` needs `code-simplifier` | Gap (see section 4) |
| `network.hosts` | Optional; listing only (plugins-reference L145) | Absent; the validator notes "Hosts not declared" | Not a gap |
| Skills directory | `skills/<name>/SKILL.md` (P5) | 28 skills; four extra `SKILL.md` files under `daisyui/` act as references and do not load as skills (the validator lists only `standards:daisyui`) | Meets; naming the nested files `SKILL.md` invites confusion and slips past the reference check |
| Agents directory | `agents/*.md` (P5) | 9 agents | Meets |
| `bin/` | On `PATH` while enabled (P5) | `kitty-headless-shot` | Meets. The same row says claude.ai and Cowork don't install a plugin with `bin/` |
| Root `CLAUDE.md` | Not loaded (P6) | None | Meets |
| Hooks | Optional; the place for rules that must always hold (S22) | None | Not covered as a requirement; see section 4 for the conventions skills |
| Evals directory | Default `evals/` (P7) | `plugins/standards/evals/` with 3 cases | Present, thin (section 5) |
| Validation in CI | Validate after every edit (P4, P11) | `.github/workflows/validate.yml` runs `claude plugin validate` on the plugin and the marketplace on every pull request and push to `main` | Meets. CI pins Claude Code 2.1.316; this machine runs 2.1.330 |
| `--strict` | Suggested for CI (P4) | Not used; `validate-warnings.mjs` fails on any warning except the missing version | Meets the intent |
| Installed copy | Not covered by the docs | `~/.claude/plugins/cache/<owner>-standards/standards/741e7d52d6b5/` is identical to `plugins/standards/` on `main` at 741e7d5 (only a runtime `.in_use/` directory differs) | Matches `main` |
| How it is enabled | User scope enables it everywhere (P13) | `~/.dotfiles/claude/.claude/settings.json`: `enabledPlugins` has `standards@<owner>-standards: true`; `extraKnownMarketplaces` adds the marketplace from GitHub with `autoUpdate: true` | User scope, auto-updating |
| Other installs | Not covered by the pages read | `installed_plugins.json` also records project-scope installs in several cairn-cms worktrees at five older commits; the cache holds 13 version directories | Not verified which copy those sessions load (section 8) |

## 4. Skills and agents

Counts: lines are the SKILL.md or agent file line count; "Desc" is the description's character
count after folding YAML line breaks. No description is near 1,024 or 1,536 characters, and every
name meets S3, so those columns are omitted. "Eval" says whether a `claude plugin eval` case
exists. Line numbers are in the file named in the row unless another file is given.

### Skills

| Skill | Lines | Desc | Eval | Shortfall against the checklist (file:line) | Smallest change that meets the docs |
| --- | --- | --- | --- | --- | --- |
| backlog-sweep | 75 | 435 | No | S21, A6-style routing: description L5-6 ties it to "every pass design" and "the project's pass guide" | Drop the process clause from the description |
| brainstorming | 332 | 272 | No | S14: `visual-companion.md:53,80,89,96,105,113,306` run `bash scripts/...` relative to the working directory. Routing: L32-33 and L297-298 send planning to `standards:running-passes` | Prefix the commands with `${CLAUDE_SKILL_DIR}/`; point step 4 at the replacement process |
| bubbletea-design | 271 | 283 | No | S7: the description opens "Use when" and never says what the skill provides | Open with one clause on what it gives |
| cairn-figure | 125 | 268 | No | S6: "you are deciding" (description, L3). P12: one project's skill in a user-scope plugin | Third person; move it to that project's own plugin or skills |
| content-draft | 64 | 364 | No | None found | None |
| content-review | 54 | 377 | No | None found (`context: fork` is a documented field) | None |
| daisyui | 114 | 115 | No | S13: `daisyui/colors/SKILL.md` is 146 lines with no contents list. The body (L14-18) says to use the skill on all HTML and Tailwind work "Even if the user does not request this skill", which is wider than its description | Add a contents list to `colors/SKILL.md` |
| dependency-upgrade | 136 | 479 | No | None against the docs | None |
| design-refinement | 322 | 371 | No | S11: 3,506 words, close to the 5,000-token re-attach limit. S20: anecdotes from past work (L80, L183, and the "observed to cost a real round" list from L309) | Move the anecdotes and anti-patterns to a reference file |
| elm-conventions | 464 | 340 | No | S9 met, but 36 lines under the cap | None now |
| go-conventions | 267 | 416 | Yes | None found | None |
| go-ship | 54 | 150 | No | S15 and P8: L32 dispatches `code-simplifier:code-simplifier` from another plugin with no fallback. `disable-model-invocation: true` meets S17 and explains why it is missing from the skill listing | Declare the dependency, or fall back to the bundled `/simplify` |
| golang-spf13-cobra | 183 | 484 | No (skill-creator format only) | S19, S15: `allowed-tools` (L25) pre-approves Edit, Write, `Bash(git:*)`, Agent, WebFetch, and MCP tools from servers the plugin doesn't ship. S25: `evals/evals.json` (19 cases) is skill-creator format and nothing runs it | Cut `allowed-tools` to read-only tools, or remove it |
| log-issue | 229 | 398 | No | None against the docs (the dated lines are sample backlog entries) | None |
| python-conventions | 124 | 327 | No | None found | None |
| receiving-code-review | 205 | 234 | No | S7: the description opens "Use when" and says little about what the skill does | Lead with what it does |
| running-passes | 60 | 233 | Yes | Old process (section 6). Its triggers overlap `spec-plan-review` ("writing or reviewing a plan") and `brainstorming` | Retire it, or set `disable-model-invocation: true` until it is retired |
| spec-plan-review | 62 | 420 | No | Old process; "pass plan" in the description (L4) | Same as `running-passes` |
| svelte-check | 39 | 414 | No | None against the docs | None |
| svelte-conventions | 76 | 366 | No | None found | None |
| ts-conventions | 116 | 331 | Yes | None found | None |
| tui-visual-verify | 109 | 442 | No | None against the docs (the `bin/` helper and its distrobox need are stated in the skill and the README) | None |
| vale-ci | 75 | 192 | No | Description dropped from this session's listing (S27); frontmatter is valid | Trim the listing (gap 2), not this file |
| vale-fix | 125 | 243 | No | Same as `vale-ci` | Same |
| vale-setup | 75 | 201 | No | None found | None |
| vale-triage | 64 | 215 | No | Same as `vale-ci` | Same |
| vale-vocab | 64 | 203 | No | Same as `vale-ci` | Same |
| visual-fidelity | 130 | 372 | No | S20: L81-116 tell the history of one past job | Move the history out, or cut it |

Notes across all skills:

- **S8 (naming).** Only `brainstorming` and `running-passes` use a gerund. The docs only
  suggest this, so it is not counted as a gap.
- **S18.** The five `*-conventions` skills, `daisyui`, and `bubbletea-design` are background
  knowledge, so they fit `user-invocable: false`. That setting hides them from the `/` menu but
  keeps their descriptions in context, so it saves no context.
- **S22.** The five conventions skills say "Mandatory rules" and "Every Go file ... must
  conform". The docs put a rule that must hold every time in a hook. The parts a script can check
  (comment shape, lint config) could go to hooks or the repo gates.
- **S26.** No record shows a test on Haiku, Sonnet, and Opus.

### Agents

Every agent sets `name`, `description`, `tools` (Read, Grep, Glob, Bash; `plan-reviewer` adds
WebFetch), `model: claude-opus-5-5` (a full ID, which A9 allows), and `effort` (`medium`;
`web-auth-security-reviewer` uses `high`). None uses the fields a plugin agent cannot use (A3).

| Agent | Lines | Desc | Shortfall (file:line) | Smallest change |
| --- | --- | --- | --- | --- |
| cloudflare-workers-reviewer | 67 | 274 | None found | None |
| daisyui-a11y-reviewer | 87 | 226 | None found | None |
| diff-reviewer | 68 | 488 | A4, A5: the description (L3) gives scope mechanics and "the project's pass guide" but no "use when". A7: the description says "Read-only" but the agent has Bash; read-only is only an instruction | Lead with "Use after a task's commit, or on the whole branch at close"; move the scope detail to the body |
| figure-verifier | 98 | 293 | S20, P12: the description names one project's docs and dated rulings; L17 links a dated record | Move it to that project; drop the date from the description |
| go-architecture-reader | 84 | 506 | A5: the longest description, with a process rule ("never as a standing step at a pass's merge") | Cut the description to what and when; move the rule to the body |
| plan-reviewer | 104 | 226 | Old process: "pass plan" (L3, L10). S20: L88-92 tell of a past review that "ran five rounds" | Retarget the description to the replacement process; cut the anecdote |
| svelte-reviewer | 69 | 224 | None found | None |
| visual-verifier | 41 | 316 | A7: "Read-only plus rendering" with Bash. S20: L33 cites a dated miss. "visual-fidelity pass" in the description | Drop the date; say "Use after a visual-fidelity task" |
| web-auth-security-reviewer | 86 | 269 | None found | None |

All 9 agents' descriptions together are about 2,800 characters, far under the 15,000-token
warning (A5). No agent has a `claude plugin eval` case for delegation (A14).

## 5. Evals and tests

What is there:

- **`plugins/standards/evals/`** holds three `claude plugin eval` cases. Each has a `prompt.md`
  (front matter `max_turns: 8`, `timeout_seconds: 300`, `tags`) and two graders: `criteria.md`
  (`type: llm`, a PASS and FAIL rubric) and `skill-fired.md` (`type: tool_used`, `tool: Skill`,
  `input_match: <skill>`). The cases are `go-conventions-wrap-and-write`,
  `ts-conventions-contract-comment`, and `running-passes-pairs-and-merge`.
- **`skills/golang-spf13-cobra/evals/evals.json`** holds 19 cases in the skill-creator format
  (prompt, trap, assertions), vendored with the skill.
- **`tests/`** has two shell tests that prove the repo's own checks fail on seeded bad input:
  `scan-test.sh` (for `scripts/scan.sh`) and `check-skill-lines-test.sh` (for
  `scripts/check-skill-lines.sh`).
- **`scripts/`** has `scan.sh` (gitleaks plus a pattern scan of files and history),
  `check-skill-lines.sh` (the 500-line cap, plus word caps on three files),
  `check-references.mjs` (contents lists in references over 100 lines, and nesting depth), and
  `validate-warnings.mjs` (validator output with only the missing-`version` warning allowed).

How they run: `validate.yml` runs the validator, the scan, both shell tests, the line check, and
the reference check on every pull request and every push to `main`. Nothing in the tracked files
runs `claude plugin eval` or the skill-creator loop, and no eval results are recorded. Run during
this audit (read-only): `check-skill-lines.sh` and `check-references.mjs` exit 0, and
`claude plugin validate` passes on the plugin and the marketplace, with the one expected warning.

Against the docs:

- The grader shapes match what the skills page describes: an eval case with a "`tool_used:
  Skill` grader" to measure triggering (skills L1213), plus a rubric for output. That part
  follows the docs.
- The docs expect the eval to run and gate: `claude plugin eval` "exits non-zero below a
  threshold so you can gate CI on it" (skills L972). Here it never runs.
- The docs expect coverage per skill: "Build three scenarios" (best-practices L756) and "At least
  three evaluations created" (L1172). Here 3 cases cover 3 of 28 skills, one case each.
- The docs say to build evals before writing (best-practices L750). No eval exists for 25 skills.
- The cobra file uses the other format. The docs say "The two formats aren't interchangeable"
  (skills L972), so `claude plugin eval` will not run it.
- Delegation evals for agents are documented (sub-agents L872). There are none.
- The structural checks (`tests/`, `scripts/`) are sound and go beyond what the docs require.
  The reference check skips files named `SKILL.md` (`scripts/check-references.mjs:21`), which
  lets `daisyui/colors/SKILL.md` through.

## 6. Old process words

Process sense only. Hits where "pass" means "succeeds" (for example "the test passes"), or that
appear in the 60 vendored daisyUI component files, are left out.

Manifests and README:

- `.claude-plugin/marketplace.json:9`, `plugins/standards/.claude-plugin/plugin.json:3`: "a short
  pass lifecycle"
- `README.md:3`: "closing a pass of work"

Skills being replaced (graded in section 4):

- `skills/running-passes/SKILL.md:2,3,6,8,12,43,56,57` (L57: "fix rounds", "a later pass")
- `skills/spec-plan-review/SKILL.md:4` ("a pass plan")
- `skills/brainstorming/SKILL.md:32-33`, `:257` ("the repository's pass guide"), `:281` ("round
  of questions"), `:297-298`

Other skills:

- `skills/backlog-sweep/SKILL.md:5,6,19,20,24,39,47,55,56,72,74`
- `skills/dependency-upgrade/SKILL.md:9,28,71,72,73,74,119,136`
- `skills/log-issue/SKILL.md:46,48,96,99,186`
- `skills/elm-conventions/SKILL.md:34,462`; `skills/elm-conventions/references/checklists.md:45,51,70`
- `skills/design-refinement/SKILL.md`: its own sense of "round" (one review cycle) and "pass"
  (one whole-surface edit), at L36, 40, 48, 56 ("the rounds-and-passes machinery"), 59, 61, 62,
  80, 92, 103, 106-110, 119, 139, 166, 171 (heading "rounds, not a pass"), 173-176, 180-183,
  188-190, 198, 207, 209, 224, 232, 236, 250, 252, 255, 259, 273, 279, 309
- `skills/visual-fidelity/SKILL.md:81,84,97,114,115,116`
- `skills/content-draft/references/web-content-method.md:43,156` (editing passes)
- `skills/go-ship/SKILL.md:12` ("in one pass")

Agents:

- `agents/diff-reviewer.md:3,21,23,38` ("pass guide")
- `agents/plan-reviewer.md:3,10` ("pass plan"), `:53,62,63,72` ("a pass"), `:88,90,91,92`
  ("rounds")
- `agents/go-architecture-reader.md:3,17`
- `agents/figure-verifier.md:18` ("a pass worktree")
- `agents/visual-verifier.md:3` ("visual-fidelity pass")

Evals, scripts, and tests:

- `evals/running-passes-pairs-and-merge/prompt.md:4,6`; `graders/skill-fired.md:4,6`
- `scripts/check-skill-lines.sh:8` ("pass process design")

## 7. Overlap with Claude Code built-ins and official Anthropic plugins

| Plugin part | Built-in or official part | Docs line | Overlap |
| --- | --- | --- | --- |
| `go-ship` step 2 | Bundled `/simplify`; the `code-simplifier` agent from another plugin | The skill names the bundled `/simplify` itself (`go-ship/SKILL.md:34`); bundled skills listed at skills L26 | Direct. The step adds only a project-skill check |
| `diff-reviewer` | Bundled `/code-review` | "bundled skills like `/debug` and `/code-review`" (skills L15) | Partial. `diff-reviewer` grades against acceptance criteria and returns a verdict; `/code-review` hunts bugs |
| `tui-visual-verify` | Bundled `/run` and `/verify` | "`/run` and `/verify` work without setup. They infer the launch from your project type (CLI, server, TUI, browser-driven)" (skills L64) | Partial. `tui-visual-verify` adds a painted-terminal capture and a fresh-context grade |
| `golang-spf13-cobra/evals/evals.json` | Official `skill-creator` plugin | "the skill-creator plugin below runs a similar loop with its own `evals/evals.json` format" (skills L972, L976) | The file is that plugin's input; nothing here runs it |
| `web-auth-security-reviewer` | Bundled `/security-review` | Not on the pages read; seen in this session's skill listing | Partial; not verified against docs |
| `brainstorming`, `receiving-code-review` | Vendored from a third-party plugin (`THIRD-PARTY-NOTICES:127,133`) | Not covered by the docs read | Whether that plugin is in an Anthropic marketplace was not checked |
| `svelte-check`, `svelte-reviewer` | Plugins can ship LSP servers (`.lsp.json`, plugins-reference L615-626) | The docs read name no official Svelte LSP plugin | Not verified |

## 8. Not checked, or not verifiable

- **Pages not read.** The plugin-evals page (https://code.claude.com/docs/en/plugin-evals),
  which defines the eval case and grader format, is linked from the skills page but was not on
  the allowed list. So this report does not confirm that the three cases match the current
  format, beyond the `tool_used: Skill` grader that the skills page names. The manifest-,
  marketplace-, loading-, and components-reference subpages were not read either, including the
  rule for which copy wins when a user-scope and a project-scope install differ.
- **Not run.** `claude plugin eval`: it sends the plugin and prompts to the model and starts
  sessions, which the brief ruled out. `tests/*.sh`: they write seeded trees to a temp directory.
  Only read-only checks were run.
- **Inferred, not proven.** That the four Vale descriptions were dropped because the listing
  went over budget. The docs give this as the only reason a description drops, the frontmatter
  is valid, and other skills in the session also lost descriptions. `/skill-doctor` or
  `claude --debug` would confirm it.
- **Not measured.** Token counts. The compaction risk for `design-refinement` is estimated from
  its word count.
- **Not read line by line.** The 60 daisyUI component files, the bodies of most reference files,
  and the technical accuracy of any skill's advice. This audit grades form against the docs, not
  whether a Go or Svelte rule is right.
- **Not verified.** Testing on several models (S26); which plugin version the older project-scope
  installs load; whether the vendored skills track their upstreams.
- **Not covered by the docs.** A word cap on a skill (`check-skill-lines.sh`), secret scanning of
  a plugin repo, and whether a plugin should set `version` for a single-user marketplace, beyond
  what P3 says.
