# User-level Claude Code configuration audit

Scope: the parts of the workstation's user-level Claude Code configuration that the core design spec
(`docs/specs/2026-11-20-core-design.md`) did not already rework. Out of scope: skills, the global
CLAUDE.md text, `permissions`, `hooks`, and `autoMode`. Each finding is graded only against Anthropic's
Claude Code docs. Docs citations name the saved copy in `docs/` beside this report, with its line, and
each page's URL is `https://code.claude.com/docs/en/<page>.md`. Claude Code 2.1.330 was installed when
the audit ran.

Paths are written from the home directory. `~/.dotfiles/claude/.claude/` is stowed into `~/.claude/`,
so a file such as `~/.claude/agents/x.md` lives at `~/.dotfiles/claude/.claude/agents/x.md`.

## 1. Short answer

These are the most important gaps, most important first.

1. **`instructions/` is not a load location, and nothing reaches it.** Claude Code loads CLAUDE.md
   files, `@path` imports, and `.claude/rules/`. It does not load a folder named `instructions/`.
   `instructions/ai-operational-rules.md` (71 lines) holds rules meant for every session (Bash
   state, wrangler `--name`, Git safety), but no CLAUDE.md, skill, rule, agent, or hook points to it.
   Those rules reach no session.
2. **Most of the Bluefin admin docs are unreachable.** CLAUDE.md points straight at 4 of the 13
   `docs/bluefin-admin/` leaves. Their index, `docs/bluefin-admin.md`, is named only by the
   `check-drift` script. A session can reach the other 9 leaves (about 240 lines) only by
   searching. The docs' home for "reference material Claude needs sometimes" is a skill with
   supporting files.
3. **Two procedure docs belong in skills.** `unattended-work-guards.md` is a 220-line procedure, and
   `web-content-method.md` is a 227-line method that a plugin's skills read from a user-level path.
   Two more docs, `fable-post-cutoff-system.md` (124 lines, partly superseded by its own note) and
   `oom-defense.md` (111 lines), are reached by nothing a session loads.
4. **Auto memory for the home directory is split in two.** `/home` is a symlink to `var/home`, so a
   session started from the home directory writes to one of two memory stores, depending on how
   the path is spelled (12 files and 17 files). The `claude-memory-write-check` hook tries to match
   the second spelling, but its pattern `/var"$HOME"` can never match, because `$HOME` already
   starts with `/var`.
5. **`site-implementer` has memory turned on, but no memory exists.** Its `memory: project` would
   write to `.claude/agent-memory/` inside a task worktree that it never commits, and no such
   folder exists in any repo. Line 78 tells it to read a `MEMORY.md` that has never existed.
6. **`voiceEnabled` is deprecated.** Line 398 of `settings.json` should be `"voice": {"enabled": true}`.
7. **Two settings are inert or undocumented.** `agentPushNotifEnabled: true` sends pushes to a phone,
   and the owner has none. `skipWorkflowUsageWarning` is not in the settings reference.
8. **The Vale rule's path glob is too broad.** `rules/vale.md:4` matches `**/styles/**`, so it also
   loads on CSS files under any `styles/` folder. One repo has such files.
9. **"Read-only" on two reviewer agents is prose only.** `prose-voice-reviewer` and
   `cairn-register-editor` call themselves read-only but carry Bash. The docs give a `PreToolUse`
   hook pattern that enforces read-only use.
10. **One doc points to a CLAUDE.md line that no longer exists.** `docs/engine-ui-mechanics.md:3`
    says "CLAUDE.md keeps a pointer to it". It doesn't: only the `site-pass` skill points to it.

These areas meet the docs: the output style, the MCP scopes, every `MEMORY.md` size, `skillOverrides`,
`env`, `model`, `modelSettings`, `worktree`, `tui`, the three rules' sizes, the subagent
descriptions, and the dotfiles repo's `settings.local.json`.

## 2. Findings by area

### 2.1 Subagents (`~/.claude/agents/`)

**What is there.** There are three files, 339 lines and 21.8 KB in all.

| Agent | Size | Model and effort | Tools | Other fields |
| - | - | - | - | - |
| `cairn-register-editor` | 182 lines, 11.6 KB | `claude-opus-5-5`, `medium` | Read, Grep, Glob, Bash | `skills: [writing-voice]` |
| `prose-voice-reviewer` | 73 lines, 5.1 KB | `claude-opus-5-5`, `medium` | Read, Grep, Glob, Bash | `skills: [writing-voice]`, `color` |
| `site-implementer` | 84 lines, 5.1 KB | `sonnet`, `medium` | Read, Write, Edit, Bash, Grep, Glob, Skill | `memory: project`, `color` |

Transcripts show `cairn-register-editor` dispatched in 19 sessions, `prose-voice-reviewer` in 8, and
`site-implementer` in 2.

**What the docs say.**

- User scope is `~/.claude/agents/` (`sub-agents.md:163`).
- The `model` field accepts "`sonnet`, `opus`, `haiku`, `fable`, a full model ID such as
  `claude-opus-5-5`, or `inherit`" (`sub-agents.md:303`).
- The combined descriptions should stay under 15,000 tokens: "Those descriptions take up context, so
  keep them short" (`sub-agents.md:27`).
- For `skills` preload: "You can't preload skills that set `disable-model-invocation: true`"
  (`sub-agents.md:653`). The `writing-voice` skill doesn't set it.
- For `memory`, the project scope's location is "`.claude/agent-memory/<name-of-agent>/`"
  (`sub-agents.md:683`), and "`project` is the recommended default scope. It makes subagent
  knowledge shareable via version control" (`sub-agents.md:696`).
- For read-only enforcement: "For more dynamic control over tool usage, use `PreToolUse` hooks to
  validate operations before they execute" (`sub-agents.md:710`). The `permissionMode` field also
  takes `plan`, "Plan mode (read-only exploration)" (`sub-agents.md:304`, `:635`).
- A non-fork subagent gets the CLAUDE.md hierarchy unless `omitClaudeMd` is set
  (`sub-agents.md:1131`), but not the output style: "a subagent runs its own system prompt, so your
  output style doesn't shape its responses" (`sub-agents.md:1146`).

**Verdict: meets, with two shortfalls.** Every field the files use is documented. The descriptions
total about 1,000 characters, far under the warning limit. The preloaded skill can be preloaded.
Because the output style never reaches a subagent, preloading `writing-voice` is the documented way
to give these agents the voice. This finding comes from the docs, not from the files.

- **Shortfall: `site-implementer` memory.** At `agents/site-implementer.md:7`, `memory: project` is set,
  and line 78 says "read its `MEMORY.md` first". The agent runs in a worktree the dispatch gives it
  (line 11), and it commits "only the files the task lists" (line 36). Under project scope, its memory
  would sit in that worktree's `.claude/agent-memory/` folder, uncommitted, and the folder is lost
  when the worktree goes. No `agent-memory` folder exists in any repo under `~/Projects`, at any depth
  to 6. **Smallest change:** set `memory: user`, which writes to
  `~/.claude/agent-memory/site-implementer/` and survives a removed worktree. The other choice is to
  keep `project` and add `.claude/agent-memory/` to what a task may commit. The docs don't say how a
  worktree resolves the project scope. See section 4.
- **Shortfall: "read-only" without enforcement.** At `agents/prose-voice-reviewer.md:4` and
  `agents/cairn-register-editor.md:6`, each description says "Read-only", but `Bash` is in `tools`, so
  either agent can write. **Smallest change:** add a `hooks:` block with a `PreToolUse` Bash validator,
  as in the docs' read-only example (`sub-agents.md:710`). Another way is `permissionMode: plan`, if
  the agents' Bash calls (for example `tellgrader`) still run in plan mode. That wasn't tested.

### 2.2 `rules/` and `instructions/`

**What is there.**

| File | Size | Frontmatter | How it loads |
| - | - | - | - |
| `rules/cairn-family-ui.md` | 18 lines, 829 B | `paths: **/*.svelte` | user-level path rule |
| `rules/go.md` | 11 lines, 358 B | `paths: **/*.go` | user-level path rule |
| `rules/vale.md` | 20 lines, 893 B | `paths: **/.vale.ini`, `**/styles/**` | user-level path rule |
| `instructions/ai-operational-rules.md` | 71 lines | none | nothing loads it |
| `instructions/fastmail-api.md` | 67 lines | none | nothing loads it; it marks itself retired |

`~/.claude/rules` is a symlink into `~/.dotfiles`. Each rule's top heading appears in many session
transcripts (184, 76, and 32), which fits the rules loading on a matching file. That count can't tell
a rule load from a direct read of the file.

**What the docs say.**

- "Rules load into context every session or when matching files are opened. For task-specific
  instructions that don't need to be in context all the time, use skills instead"
  (`memory.md:174`).
- "Rules without `paths` frontmatter are loaded at launch" (`memory.md:190`), and a path rule loads on
  a Read, Write, or Edit of a matching file (`memory.md:211`).
- "To load shared rules without that approval, keep them in `~/.claude/rules/`" (`memory.md:263`).
- The only documented ways in are CLAUDE.md files, `@path` imports (`memory.md:104`), and
  `.claude/rules/`. No docs page names an `instructions/` folder.

**Verdict for `rules/`: meets, with one shortfall.** All three rules are small and path-scoped, which is
the documented use.

- **Shortfall: `rules/vale.md:4` is too broad.** `"**/styles/**"` also matches site stylesheets. One
  repo under `~/Projects` has CSS files under a `styles/` folder, and opening one loads the Vale rule.
  **Smallest change:** replace `"**/styles/**"` with `"**/styles/**/*.yml"` (Vale rules are YAML) and,
  if vocabularies matter, `"**/styles/config/vocabularies/**"`.
- The backlog and branch clauses in `cairn-family-ui.md` and `vale.md` are left for the process spec.

**Verdict for `instructions/`: falls short, and the docs don't cover the folder.** Nothing live points
to `ai-operational-rules.md`. Its only mentions are in dated records and research files, and the
2026-11-01 prompt audit already reported "Nothing imports them". `fastmail-api.md` is reached only
from `docs/bluefin-admin/email.md:6`, as a record of a retired service. `docs/claude-tooling.md:18`
still lists `instructions/` as a live layer "linked from consumer CLAUDE.md files", and no consumer
CLAUDE.md links to it.

- **Smallest change:** move both files to `docs/record/`, delete the `docs/claude-tooling.md:18`
  row, and move each still-true line of `ai-operational-rules.md` to its documented home:
  - a rule that must hold every time goes in a hook (`features-overview.md:189`, "Put guardrails in
    hooks");
  - a fact every session needs goes in CLAUDE.md;
  - a Wrangler or `gh` procedure goes in a skill.

  Its Bash-state claims were not checked against the current Bash tool (see section 4).

### 2.3 Output style and `outputStyle`

**What is there.**

- `~/.claude/output-styles/writing-voice.md` is a symlink to `skills/survey/writing/writing-voice.md`,
  64 lines and 3.7 KB.
- Its frontmatter has `name: writing-voice`, a description, and `keep-coding-instructions: true`.
- `settings.json:350` sets `"outputStyle": "writing-voice"`.

**What the docs say.**

- "To make a style your default across projects, set `outputStyle` in `~/.claude/settings.json`"
  (`output-styles.md:112`).
- The user location is "`~/.claude/output-styles`" (`output-styles.md:126`).
- "Set `keep-coding-instructions: true` if you're changing how Claude communicates but still want it
  coding the same way" (`output-styles.md:134`).
- Without that field, a custom style drops Claude Code's built-in engineering instructions
  (`output-styles.md:191`).
- "Other subagents run their own system prompt, so styles don't change how they respond"
  (`output-styles.md:193`).
- An output style costs context on "Every request" (`features-overview.md:226`).
- Use a style "if it's about the response itself and you might want it off again"
  (`features-overview.md:124`).

**Verdict: meets.** The location, the name match, and `keep-coding-instructions` are all correct. The
style is about prose, which fits the docs' use for a style. It costs about 900 tokens on every
request. The style and CLAUDE.md both carry "name the audience and load its standard through the
`writing-voice` skill". The core spec keeps that duplicate on purpose, because the style doesn't reach
subagents. The docs don't cover a style file stored inside a skill folder, or a style and a skill that
share one name.

### 2.4 `docs/` (3,416 lines including 7 symlinked voice files; 2,377 lines of real files)

**How a session reaches each file.**

| Reached from | Files |
| - | - |
| A CLAUDE.md pointer | `bluefin-admin/browsers.md`, `bluefin-admin/secrets.md`, `bluefin-admin/software-tiers.md`, `bluefin-admin/calm-desktop.md`, `cloudflare-estate-inventory.md` (which routes to the 4 `cloudflare-estate/` leaves), `test-accounts.md`, `unattended-work-guards.md` |
| A skill | `claude-tooling.md` (claude-infra), `engine-ui-mechanics.md` (site-pass), `word-sweep.md` and `authoring-charter.md` (writing-voice, survey), `voice/*` (writing-voice, survey, pass-core, approval-packet; these are symlinks into `skills/survey/writing/`), `unattended-work-guards.md` (pass-core, approval-packet), `bluefin-admin/secrets.md` (proton-pass) |
| A plugin skill, by a user-level path | `web-content-method.md` (the standards plugin's content skills) |
| A script only | `bluefin-admin.md` (check-drift), `claude-md-archive.md` (claude-context-budget), `bluefin-admin/etc-drift.md` (cleanroom) |
| Another doc only | `bluefin-admin/{command-map,email,etc-drift,gsettings,phone-checks,selinux,terminal-capture,tmp,update-cadence}.md` (from the index, which no session-loaded file names), `oom-defense.md` (from etc-drift), `fable-post-cutoff-system.md` (from the archive) |
| Nothing | `record/2026-09-19-docs-infra-audit.md`, `record/2026-09-28-claude-infra-audit.md` (462 lines, archive by design) |

No hook output names a doc. `bluefin-admin/google-workspace.md` was skipped, because another
session is editing it.

**What the docs say.**

- "Put it in a skill if it's reference material Claude needs sometimes (API docs, style guides)"
  (`features-overview.md:108`).
- When "You paste the same playbook or multi-step procedure into chat for the third time", capture it
  as a skill (`features-overview.md:62`).
- "If an entry is a multi-step procedure or only matters for one part of the codebase, move it to a
  skill or a path-scoped rule instead" (`memory.md:51`).
- Skills hold supporting files that "Claude access[es] ... only when needed" (`code-skills.md:537`),
  and a plugin skill reaches bundled files through `${CLAUDE_PLUGIN_ROOT}` (`code-skills.md:497`).

**Verdict: falls short in four places.** A plain `docs/` folder isn't a Claude Code feature. A doc
works only when something a session loads points to it.

- **Bluefin admin.** At `docs/bluefin-admin.md` (34 lines) plus 13 leaves (about 440 lines), 9 leaves
  sit behind an index that no session-loaded file names. **Smallest change:** make
  `skills/bluefin-admin/SKILL.md` from the index, with the leaves as supporting files. That turns the 4
  CLAUDE.md leaf pointers into one skill description. Even smaller: add one CLAUDE.md pointer to
  `docs/bluefin-admin.md`, though the CLAUDE.md text belongs to the core spec.
- **`docs/unattended-work-guards.md` (220 lines).** This is a procedure, reached from a CLAUDE.md
  pointer and two skills. **Smallest change:** make it a skill, so that its description triggers the
  procedure. Then the CLAUDE.md line can go (`memory.md:51`).
- **`docs/web-content-method.md` (227 lines).** The standards plugin's `content-draft` and
  `content-review` skills read it from `~/.claude/docs/`, outside the plugin, so the plugin breaks on
  any machine without this dotfiles tree. **Smallest change:** move it into the plugin as a supporting
  file and reference it through `${CLAUDE_PLUGIN_ROOT}`.
- **Orphans.** `docs/fable-post-cutoff-system.md` (124 lines) says itself that `pass-core` "Models"
  superseded its seat policy. `docs/oom-defense.md` (111 lines) is a 2026-09-03 research report.
  **Smallest change:** move both to `docs/record/`. If a live rule survives in the Fable doc, it
  goes into `pass-core`.
- **Stale line.** `docs/engine-ui-mechanics.md:3` says "CLAUDE.md keeps a pointer to it", and
  CLAUDE.md has none. **Smallest change:** say that the `site-pass` skill points here.
- `docs/claude-tooling.md`, `docs/word-sweep.md`, and `docs/engine-ui-mechanics.md` work through their
  skills. Moving each into its skill's folder would match `code-skills.md:535`, but that isn't
  needed for them to work.

### 2.5 `tooling/` and `gather-dotfiles.sh`

| File | Size | What it does | Documented home |
| - | - | - | - |
| `tooling/mcp-servers.json` | 22 lines | User-scope MCP manifest (playwright, svelte). `claude-tooling-sync apply` writes it into `~/.claude.json`, and `verify` checks it. | Not covered by the docs. User scope lives in `~/.claude.json` (`mcp.md:760`, `settings.md:65`), and the docs give no declarative user-scope file. Only project scope has one, `.mcp.json`. |
| `tooling/automode-initiatives.json` | 1 line, `{}` | Maps `autoMode.allow` entry prefixes to initiatives for `claude-tooling-sync`'s staleness report (`bin/.local/bin/claude-tooling-sync:229`). | Not covered by the docs. It is empty, so every entry without an initiative path in its text reports "unknown record". The autoMode entries themselves are left for the process spec. |
| `tooling/vendored-skills.json` | 128 lines | Source, commit, and license for 12 skills: 9 in the standards plugin, 3 of the owner's own. | Partly native: plugins and marketplaces with `autoUpdate` (`extraKnownMarketplaces`) are the documented way to take third-party skills. |
| `tooling/retired-phrases.txt` | 137 lines, 109 non-blank | A phrase list that `scripts/check-claude-refs.py` fails on, in the dotfiles gate. | Not covered by the docs. The nearest native check is `/doctor prompt-audit` (`memory.md:96`). |
| `gather-dotfiles.sh` | 56 lines | A SessionStart hook that prints the host line and the initiatives for the repo. | Meets: "Claude Code adds a SessionStart hook's plain-text stdout to Claude's context" (`hooks.md:1372`). It is the only hook script kept in `~/.claude/` and not in `~/.local/bin/`, which the docs don't cover. |

**Verdict: not covered by the docs, apart from the hook.** No change is needed for the docs' sake. If
`automode-initiatives.json` is meant to hold a mapping, filling it is part of the process spec's
autoMode work.

### 2.6 In-scope `settings.json` keys

`~/.claude/settings.json` is generated from `~/.dotfiles/claude/.claude/settings.json`, and the live
copy matches it for every key below. The line numbers are the dotfiles copy's.

| Key (line) | Value | Docs | Verdict |
| - | - | - | - |
| `env` (3) | `CLAUDE_CODE_SUBAGENT_MODEL=sonnet`, `CLAUDE_CODE_SUBAGENT_EFFORT=medium` | Both are documented (`env-vars.md:416`, `:418`), and the effort variable needs v2.1.315, which is older than the installed version. The model variable comes third in precedence, after the per-invocation `model` and the definition's `model` (`sub-agents.md:356`). "Setting `CLAUDE_CODE_SUBAGENT_MODEL` by itself doesn't change the model the built-in Explore and Plan subagents run on" (`sub-agents.md:365`). | Meets. Sensible next to CLAUDE.md's rule that every dispatch names a model. |
| `worktree` (7) | `baseRef: head` | "`head` branches from your current local `HEAD`, so unpushed commits and feature-branch state are present in the worktree" (`settings-reference.md:4775`). The default is `fresh`. | Meets. |
| `model` (10) | `fable` | `fable` is a documented alias (`env-vars.md:149`). On v2.1.321 and later it "resolves to Fable 5.2" (`model-config.md:1168`). | Meets. |
| `modelSettings` (399) | entries for `claude-opus-5-5`, `claude-fable-5-2`, and `claude-sonnet-5-5`, each with `autoCompactWindow` 200000; the first two also set `effortLevel` high | "Claude Code writes each entry under the model's canonical name, such as `claude-opus-5-5`" (`settings-reference.md:677`). `autoCompactWindow` takes a value of at least 100000. | Meets. The keys match the canonical names that the aliases resolve to. |
| `enabledPlugins` (321) | 6 plugins, all `true` | Documented (`settings-reference.md:4245`). | Meets. |
| `extraKnownMarketplaces` (329) | 3 GitHub marketplaces, one with `autoUpdate` | Documented (`settings-reference.md:4274`). | Meets. |
| `skillOverrides` (351) | 10 `anthropic-skills:*` set to `name-only`, and `google-workspace` set to `off` | "Overrides don't apply to plugin skills, which you manage through `/plugin`" (`settings-reference.md:3866`). The `anthropic-skills:*` skills aren't plugin skills: they are claude.ai skills synced to `~/.claude/skills/synced/` (`code-skills.md:173`). | Meets. This audit's own skill listing shows the 10 entries with no description, and `google-workspace` absent. That settles the open check in the core spec. |
| `tui` (364) | `fullscreen` | Valid (`settings-reference.md:3311`). | Meets. |
| `autoMemoryEnabled` (365) | `true` | "`true`: the same as unset" (`settings-reference.md:2378`). | Meets. The line is redundant: dropping it changes nothing. |
| `skipWorkflowUsageWarning` (366) | `true` | Not in the settings reference or the env-vars page. The workflows page says the first-launch prompt's "Yes records consent in your user settings" (`workflows.md:173`), which this key probably is. | Not covered by the docs. Keeping it in the source file follows `settings.md:280`: a key that Claude Code writes to a generated file is lost unless it's set "in the tool that generates the file". |
| `agentPushNotifEnabled` (367) | `true` | "Allow Claude to send a push notification to your phone when it decides one is worth sending" (`settings-reference.md:4877`). | Falls short in sense, not in syntax: the owner has no smartphone, so the key does nothing. **Smallest change:** delete line 367. |
| `voiceEnabled` (398) | `true` | "Deprecated since v2.1.92, when the `voice` object replaced it. ... new configurations should set `voice.enabled`" (`settings-reference.md:3408`). | Falls short. **Smallest change:** replace line 398 with `"voice": {"enabled": true},`. |

One caution applies to every key in this table. `/model`, `/config`, `/tui`, `/voice`, and `/memory` all
write to `~/.claude/settings.json`. Those changes last only until the next `claude-tooling-sync apply`
(`settings.md:280`). `verify` reports the drift, so this is a known cost of the generated file, not a
defect.

### 2.7 MCP servers

**What is there.**

- `claude mcp list` (it ran without a prompt) shows four servers: a claude.ai Docs connector, the
  cloudflare plugin's server, `svelte` (HTTP, user scope), and `playwright` (stdio, pinned
  `@playwright/mcp@0.0.85`, user scope). All four are connected.
- `~/.claude.json` holds `playwright` and `svelte` at user scope.
- One project has a local-scope server (a licensed DaisyUI Blueprint server).
- One site repo's `.mcp.json` also defines `svelte`.

**What the docs say.**

- User scope "works well for personal utility servers, development tools, or services you frequently
  use across different projects" (`mcp.md:833`).
- Local scope is for "servers with credentials you don't want in version control" (`mcp.md:768`).
- "When the same server is defined in more than one place, Claude Code connects to it once, using the
  definition from the highest-precedence source" (`mcp.md:842`), and duplicates across the three
  scopes match by name (`mcp.md:850`).
- Tool search is on by default (`mcp.md:431`), so idle servers cost little context.

**Verdict: meets.** Both user-scope servers are cross-project development tools. The licensed
server is local, which matches the docs' credentials guidance. The `svelte` entry duplicated in one
repo's `.mcp.json` resolves to the project entry, by name. That is harmless, and it keeps the repo
working for a collaborator without the user-scope entry.

### 2.8 Auto memory

**What is there.**

- `~/.claude/projects/` has 264 `memory/` folders. Of those, 249 are empty. Most of the empty ones
  belong to throwaway probe sessions in temp folders.
- 15 folders hold 123 files and about 2,550 lines.
- The largest `MEMORY.md` is 21 lines and 2.6 KB. The largest topic file is 73 lines.
- Every topic file is listed in its index, and every index entry points to a file that exists.
- Every topic file starts with frontmatter.
- No file carries a `modified` field.
- One folder holds a leftover `.tmp` file.
- Three indexes were sampled, and each uses one link line per memory.
- The content is preferences, rulings, and workstation and project facts. It isn't quoted here.

**What the docs say.**

- The folder is `~/.claude/projects/<project>/memory/`. "The `<project>` path is derived from the git
  repository ... Outside a git repo, the project root is used instead" (`memory.md:516`).
- "`MEMORY.md` # Index, one line per memory" (`memory.md:536`).
- "the first 200 lines or 25KB of `MEMORY.md`, whichever comes first, load at session start"
  (`memory.md:550`).
- Auto memory "skips anything your CLAUDE.md files already say" (`memory.md:487`).
- "When Claude writes a memory file that begins with YAML frontmatter, Claude Code records the write
  time in a `modified` frontmatter field" (`memory.md:564`).

**Verdict: meets on size and shape, with one shortfall.** Every index is under a tenth of the limit.
The workstation's own `claude-context-budget` budget (`MEMORY_INDEX_BUDGET`, 1500) is stricter than
the docs.

- **Shortfall: the home directory has two memory stores.** The home directory isn't a git repo, so
  the store's name comes from the path string. A session started from `/home/<user>` and one started
  from `/var/home/<user>` write to different stores (12 files and 17 files). Each sees only its own
  memories. **Smallest change:** merge the two stores' topic files and indexes into the
  `/var/home` store, and start sessions from one spelling. For example, the shell's `claude` wrapper
  can `cd -P .` first.
- **A related bug in a helper.** At `bin/.local/bin/claude-memory-write-check:7` and `:8`, the second
  pattern `/var"$HOME"/...` expands to `/var/var/home/...` because `$HOME` is already
  `/var/home/<user>`. A memory write through the `/home` spelling skips the routing reminder.
  **Smallest change:** use `"${HOME#/var}"` in place of `/var"$HOME"` on both lines.
- The 249 empty folders aren't covered by the docs. They cost nothing at load time.

### 2.9 `claude-*` helpers (`~/.dotfiles/bin/.local/bin/`)

| Helper | What it does | What calls it |
| - | - | - |
| `claude-askpass` | Sudo askpass that reads a tmpfs cache | CLAUDE.md; `claude-sudo-setup`, `secret-receive` |
| `claude-awake-holder` | Holds the machine awake while a session is active | `claude-awake-touch` |
| `claude-awake-touch` | Hook that renews the awake lease | `settings.json` PreToolUse `*` and UserPromptSubmit |
| `claude-block-pass` | PreToolUse guard that keeps Bash away from Proton Pass key paths | `settings.json`; proton-pass skill |
| `claude-context-budget` | Size budgets for context-loaded files, and skill word caps | `settings.json` PostToolUse; `scripts/check.sh` |
| `claude-denied-log` | Logs auto-mode denials to a private JSONL file | `settings.json` PermissionDenied |
| `claude-launch-guard` | Denies a `claude --bg` pass launch that skipped its checks | `settings.json` (left for the process spec) |
| `claude-memory-write-check` | Adds a routing reminder to a memory write | `settings.json` PreToolUse Write\|Edit (path bug in 2.8) |
| `claude-merge-guard` | Guards against Git and gh slips | `settings.json`; pass-core (left for the process spec) |
| `claude-notify` | Notification hook wrapper that keeps a single desktop bubble | `settings.json` Notification |
| `claude-pass` | Runs one `pass-cli` command as Claude's own agent | CLAUDE.md; 3 skills; `settings.json` allow rules; 6 scripts |
| `claude-pass-load` | Counts the words each pass role loads | `scripts/check.sh` only |
| `claude-secret-guard` | Denies writes of secret-shaped material | `settings.json` (Bash and Write\|Edit) |
| `claude-sudo-clear` | Shreds the sudo cache | The `claude` shell wrapper in `.bashrc:179`, after exit; `claude-sudo-setup`; `secret-set.sh` |
| `claude-sudo-setup` | Asks for the sudo password and caches it | CLAUDE.md; `claude-askpass`; `scripts/check.sh` |
| `claude-tail-guard` | Denies a gate or CI watch piped to `tail` or `head` | `settings.json` |
| `claude-tierguard` | Allows `rpm-ostree install` only for listed packages | `settings.json` |
| `claude-tooling-sync` | Applies and verifies the settings, MCP, and vendored-skill manifests | 3 skills; `check-drift`, `check.sh`, `workstation-sync` |
| `claude-worktree-busy` | Says whether a worktree is in use | CLAUDE.md; `site-implementer`; 3 skills; `check.sh` (left for the process spec) |

**Verdict: not covered by the docs, and nothing is orphaned.** Every helper has a live caller.
`claude-pass-load` runs only in the gate, by design. `claude-sudo-clear` runs only when the session
was started through the interactive shell wrapper, so a session started any other way leaves the
cache. The docs' hook for this is `SessionEnd`, "When a session terminates" (`hooks.md:65`).

### 2.10 The dotfiles repo's own project config

**What is there.**

- `~/.dotfiles/.claude/settings.local.json` (184 B) holds 3 `WebFetch(domain:...)` allow rules, and
  a global git exclude keeps it out of Git.
- `project-tracking.json` (97 B) holds backlog settings for the owner's own log-issue tooling.
- One tracked skill, `skills/dotfiles-pass/SKILL.md` (62 lines).
- `.claude/worktrees/`, ignored by Git, holds 27 worktrees: 20 subagent `agent-*` worktrees dated
  2026-11-07 to 2026-11-13 and 7 named ones. One worktree has changes that aren't committed.
- There is no `~/.dotfiles/CLAUDE.md`, no `.claude/rules/`, no `.claude/settings.json`, and no
  `.mcp.json`.

**What the docs say.**

- `settings.local.json` is the local, personal project file (`settings.md:27` and the scope table
  there).
- "Claude Code runs a periodic sweep that removes worktrees that Claude created for subagents and
  background sessions once they are older than your `cleanupPeriodDays` setting" (`worktrees.md:146`).
  The default is 30 days (`settings-reference.md:5569`), and a worktree that "still holds work" stays
  (`worktrees.md:150`).

**Verdict: meets.** The core spec already ruled that `settings.local.json` stays and that no
`~/.dotfiles/CLAUDE.md` is made, so this audit doesn't revisit either. The agent worktrees are under
30 days old. The sweep keeps any that hold commits, which then need `git worktree remove` by hand
(`worktrees.md:164`). `project-tracking.json` isn't a Claude Code file, and the docs don't cover it.

## 3. Done by hand where Claude Code now has a native feature

| By hand | Native feature | Overlap |
| - | - | - |
| `claude-context-budget` line and word budgets on CLAUDE.md, rules, and `MEMORY.md` | "If one of your instruction files is over the recommended length, you see a warning at startup ... You also see a warning when files that are each within that length add up past a combined limit" (`memory.md:626`); near-limit reminders for `MEMORY.md` (`memory.md:552`); `/skill-doctor` for skill cost (`code-skills.md:955`) | Partial. The hand budgets are stricter and block at write time. The native ones only warn. |
| `scripts/check-claude-refs.py` and `retired-phrases.txt` | `/doctor prompt-audit` looks for "instructions written for older models, references to files or commands that don't exist, and files that contradict each other" (`memory.md:96`), across "the rules, skills, commands, subagents, and output styles under `.claude/` and `~/.claude/`" (`memory.md:98`) | Partial. The phrase gate is deterministic, while the audit is a model's read. The audit would also catch the `instructions/` and `engine-ui-mechanics.md` findings above. |
| `claude-sudo-clear` run by the shell wrapper after `claude` exits | A `SessionEnd` hook (`hooks.md:65`) | Full for the trigger. Note that one session's end would clear the cache for every other session too, just as the wrapper does now. |
| The dispatching session sets up `site-implementer`'s worktree and runs `npm ci` | The subagent field `isolation: worktree` (`sub-agents.md:314`), with `.worktreeinclude` or a `WorktreeCreate` hook for setup (`worktrees.md:7`) | Partial. Native isolation branches "by default from your default branch", and `worktree.baseRef` changes that. |
| `claude-worktree-busy` before entering a worktree | "While an agent is running, Claude Code holds a `git worktree lock` on its worktree" (`worktrees.md:160`) | Partial. The lock covers only worktrees that Claude Code made. The helper is left for the process spec. |
| `claude-memory-write-check` reminds Claude not to store what CLAUDE.md says | Auto memory "skips anything your CLAUDE.md files already say" (`memory.md:487`) | Partial. The hook also routes initiative state and repo facts, which the native rule doesn't. |
| `vendored-skills.json` with `update-skills` re-fetches | Plugin marketplaces with `autoUpdate` in `extraKnownMarketplaces` (`settings-reference.md:4274`) | Partial. Nine of the twelve entries already live in the standards plugin. |

## 4. Not checked or not verified

- Whether `memory: project` in a subagent resolves to the main checkout or to the worktree when the
  subagent runs in a worktree. The docs don't say. The finding in 2.1 rests on no folder existing
  anywhere.
- Whether `permissionMode: plan` lets the reviewers' `tellgrader` Bash calls run.
- Whether the three rules load through the rule mechanism, apart from direct reads. The transcript
  counts in 2.2 can't separate the two. A Cowork session would skip the symlinked `~/.claude/rules`
  and `~/.claude/CLAUDE.md` (`memory.md:140`). Cowork use wasn't checked.
- Why no memory file carries `modified`. The files may predate the feature, or they may have been
  written through a path the feature doesn't cover.
- Whether any memory repeats CLAUDE.md. Only three indexes were sampled, and no topic file was read.
- The exact meaning of `skipWorkflowUsageWarning`, which is undocumented.
- Whether Remote Control is ever used. That is the only path through which `agentPushNotifEnabled`
  acts.
- Whether `ai-operational-rules.md`'s Bash-state claims still match the Bash tool.
- `docs/bluefin-admin/google-workspace.md`, which was skipped because another session is editing it.
- Out of scope by the brief: skills, `permissions`, `hooks`, `autoMode`, and the global CLAUDE.md
  text.
- No credential-like value turned up in the files read. The scan covered `agents/`, `rules/`,
  `instructions/`, `docs/`, `tooling/`, `gather-dotfiles.sh`, and the dotfiles `.claude/` JSON files.
- Docs pages: beyond the pages named in the brief, this audit fetched the public pages
  `settings-reference`, `env-vars`, `workflows`, `worktrees`, and `model-config`, because `settings`
  and `sub-agents` defer to them. `hooks.md` is a copy of the same public page that another session
  saved. No URL or query carried any private content.
