# Local skills audit against Anthropic's skills docs

This audit grades 13 personal skills in `~/.dotfiles/claude/.claude/skills/` against two Anthropic
pages:

- **cc-skills**: the Claude Code skills page, saved at `docs/cc-skills.md`.
- **bp**: the Agent Skills best practices page, saved at `docs/agent-skills-best-practices.md`.

Both pages were fetched live on 2026-11-20, and each matched the saved copy. A citation such as
`cc:404` means line 404 of `docs/cc-skills.md`. A citation such as `bp:206` means line 206 of
`docs/agent-skills-best-practices.md`. Skill paths are relative to the skills folder. For example,
`mail-tend/SKILL.md:66` means `~/.dotfiles/claude/.claude/skills/mail-tend/SKILL.md`, line 66.

The 13 skills are claude-infra, engine-consult, google-sheets, log-project, mail-tend,
maintenance-mode, proton-pass, register-check, retire-project, runbook, survey, vps-conventions, and
writing-voice. The six process skills (pass-core, cairn-pass, site-pass, approval-packet, cc-desk,
and cc-desk-work) were not graded. Section 4 lists where the 13 depend on them.

## 1. Short answer

These are the ten gaps that matter most, most important first.

1. **Eight of the 13 skills depend on the process being replaced.** engine-consult is built
   entirely on the pass and the plan: its description, its two triggers, its header lines, and its
   mini-pass checklist (`engine-consult/SKILL.md:3`, `:17-41`, `:118`). claude-infra, mail-tend,
   maintenance-mode, and retire-project each send a step through `pass-core` or `approval-packet`.
   survey ships `writing/approval-brief.md`, a 437-line register for the Approval Queue, and its
   release steps call `approval-queue merge`. log-project ties its record to the pass. Section 4
   lists every line.
2. **Twelve skills have no evaluations, and the one that does, writing-voice, covers half the
   docs' test.** The docs ask for at least three evaluations, testing on Haiku, Sonnet, and Opus,
   and separate measures for triggering and output (bp:1172, bp:1173, cc:963). writing-voice has
   12 drafting tasks, but every drafting run used one model. Its run never tested whether Claude
   loads the skill unprompted. Its last results date from 2026-09-01, and the skill has changed
   since then.
3. **Five descriptions miss half of "what it does and when to use it" (cc:404, bp:203), or break
   the third-person rule (bp:206).** engine-consult and vps-conventions state only when to use the
   skill. proton-pass states only topics. claude-infra and survey speak in the second person
   ("when you keep pasting", "corrects your wording"). register-check opens in the imperative.
4. **Side-effect workflows have no invocation control (cc:565).** Claude can start
   retire-project's irreversible teardown on its own; the description's last trigger asks it to.
   survey's release procedure (`survey/SKILL.md:75-91`) loads with every UI task. mail-tend's
   re-sort, which moves and trashes mail, sits in a skill Claude loads automatically.
5. **register-check forks without `background: false`.** A forked skill runs in the background by
   default with a narrower tool set (cc:811, cc:822). This skill dispatches two agents, runs Vale,
   and must hand back one folded report.
6. **google-sheets sends Claude to a skill that settings turn off.** `google-sheets/SKILL.md:15-17`
   names `anthropic-skills:google-workspace`. `settings.json:362` sets that skill to `"off"`.
   Invoking a hidden skill by its full name "returns the `skillOverrides` error instead of running
   it" (cc:934).
7. **Every load pays for rarely needed text and facts that will go stale (cc:380, bp:576).**
   Examples are an 18-line quotation of prompting guidance in claude-infra (`:30-47`), the survey
   release procedure, and cairn-only drafting rules in writing-voice (`:84-88`). Facts tied to a
   version or a single run include a TypeScript 7 forecast (`maintenance-mode/SKILL.md:64`), a
   pinned model ID (`engine-consult/SKILL.md:77`), a section that deletes itself
   (`engine-consult/SKILL.md:135-139`), and a pinned clasp version
   (`google-sheets/references/apps-script.md:3`).
8. **survey's reference files break three structure rules.** Four files over 100 lines have no
   table of contents (bp:410). The files link onward to further files (bp:382). The skill's table
   still routes readers to `approval-brief.md` (`survey/SKILL.md:44`), although its own overlay
   says nothing reads that file (`:7`).
9. **Two rules that must hold every time are written only as instructions (cc:1228).** These are
   engine-consult's "blocking precondition" on the first dispatch (`:38-41`) and survey's rule to
   log every correction (`:54`).
10. **`claude-infra` contains the reserved word `claude` (bp:156).** Claude Code loads it, so this
    matters only if the skill is ever uploaded to claude.ai or the Skills API (cc:431).

## 2. The checklist

Each item quotes the docs sentence it rests on. C8, C27, and C28 apply to the collection as a
whole and are graded once, in section 3.0.

| ID | Item | Docs quote | Source |
| --- | --- | --- | --- |
| C1 | Frontmatter parses | "Claude Code reads the frontmatter only when the opening `---` is the file's first line." | cc:399 |
| C2 | `name` follows the rules | "Maximum 64 characters", "Must contain only lowercase letters, numbers, and hyphens", "Cannot contain XML tags", "Cannot contain reserved words: `anthropic`, `claude`" | bp:153-156 |
| C3 | `description` stays inside its limits | "Must be non-empty", "Maximum 1,024 characters", "Cannot contain XML tags". Also: "the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing" | bp:160-162, cc:404 |
| C4 | The description says what the skill does and when to use it | "What the skill does and when to use it." Also: "should include both what the Skill does and when to use it." | cc:404, bp:203 |
| C5 | The description is in the third person | "Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems." | bp:206 |
| C6 | The description is specific, with the key use case first | "Be specific and include key terms." Also: "Put the key use case first" | bp:213, cc:404 |
| C7 | Invocation flags fit the kind of skill | `disable-model-invocation: true`: "Use this for workflows with side effects or that you want to control timing". `user-invocable: false`: "Use this for background knowledge that isn't actionable as a command." | cc:565, cc:567 |
| C8 | Names follow one pattern | "Use consistent naming patterns to make Skills easier to reference and discuss." To avoid: "Inconsistent patterns within your skill collection" | bp:170, bp:192 |
| C9 | SKILL.md is under 500 lines | "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files." | cc:559 |
| C10 | The body is concise | "Keep the body itself concise." Also: "State what to do rather than narrating how or why". And: "Only add context Claude doesn't already have." | cc:380, bp:26 |
| C11 | Important instructions come first and hold for the whole task | "put the most important instructions near the top of `SKILL.md`." Also: "write guidance that should apply throughout a task as standing instructions rather than one-time steps" | cc:1230, cc:613 |
| C12 | No time-sensitive information | "Don't include information that will become outdated". Checklist: "No time-sensitive information (or in "old patterns" section)" | bp:576, bp:1152 |
| C13 | Terms stay consistent | "Choose one term and use it throughout the Skill" | bp:607 |
| C14 | Examples are concrete | "Examples are concrete, not abstract" | bp:1154 |
| C15 | Workflows have clear steps | "Break complex operations into clear, sequential steps." | bp:439 |
| C16 | Critical steps carry validation and feedback loops | "Validation/verification steps for critical operations". Also: "Run validator → fix errors → repeat" | bp:1167, bp:530 |
| C17 | Constants are justified | "Also justify and document configuration parameters to avoid "voodoo constants"" | bp:912 |
| C18 | SKILL.md says what each supporting file holds and when to load it | "Reference supporting files from `SKILL.md` so Claude knows what each file contains and when to load it" | cc:548 |
| C19 | References are one level deep | "Keep references one level deep from `SKILL.md`. All reference files should link directly from `SKILL.md`" | bp:382 |
| C20 | A reference over 100 lines has a table of contents | "For reference files longer than 100 lines, include a table of contents at the top." | bp:410 |
| C21 | Required packages are listed | "Required packages listed in instructions and verified as available" | bp:1164 |
| C22 | A rule that must hold every time lives in a hook | "move the rule into a hook". Also: "Claude Code runs that hook when its event occurs, such as before a file edit, whether or not Claude is following the skill." | cc:1228 |
| C23 | `context: fork` fits the skill | "The subagent doesn't see your conversation history, so the skill's instructions have to stand on their own." Also: "If your skill's steps depend on a tool outside that set, set `background: false` to keep the full tool set." | cc:805, cc:822 |
| C24 | At least three evaluations | "At least three evaluations created". Also: "Create evaluations BEFORE writing extensive documentation." | bp:1172, bp:750 |
| C25 | Tested on every model it runs on | "Test your Skill with all the models you plan to use it with." Checklist: "Tested with Haiku, Sonnet, and Opus" | bp:136, bp:1173 |
| C26 | Triggering and output are measured against a baseline | "measure separately whether Claude invokes it on the prompts it should, and whether the output matches what you expect when it does." | cc:963 |
| C27 | Forward-slash paths | "No Windows-style paths (all forward slashes)" | bp:1166 |
| C28 | MCP tools use fully qualified names | "If your Skill uses MCP (Model Context Protocol) tools, always use fully qualified tool names" | bp:1091 |

The docs do not cover these topics. The tables below mark them "not covered by the docs":

- A reference to a file outside the skill's own folder.
- One skill that depends on another skill.
- Personal data or an account identifier in a skill body.
- Dated provenance notes such as "(owner, 2026-10-28)". These record a ruling and are not
  date-conditional instructions.
- Local overlays on a vendored skill.

## 3. Grades per skill

### 3.0 Collection-level items, and the three standard evaluation fixes

| Item | Verdict | Detail |
| --- | --- | --- |
| C8 naming | Falls short (minor) | The 13 names mix three patterns: single nouns (`runbook`, `survey`), verb plus object (`log-project`, `retire-project`), and noun pairs (`engine-consult`, `register-check`, `mail-tend`, and the rest). None uses the gerund form that bp:170 suggests. Smallest change: none worth a rename now. Pick one pattern for new skills. |
| C27 forward slashes | Meets | No skill has a Windows path. |
| C28 MCP names | Not applicable | No skill calls an MCP tool by name. google-sheets names claude-in-chrome as a product, not as a tool. |
| Listing cost | Not checked | The 13 descriptions total about 4,645 characters, and the listing carries them on every turn. None of the 13 appears in `skillOverrides`, so all are "on" (cc:936). `/skill-doctor` reports what each costs and how often it is used (cc:955). This audit did not run it. |

The tables use three standard fixes for C24 to C26:

- **E1:** Add `evals/evals.json` with three realistic prompts the skill should handle and one it
  should not (bp:754, cc:989).
- **E2:** Run E1 on Haiku, Sonnet, and Opus (bp:1173).
- **E3:** Run each prompt in a fresh session, once with the skill on and once with it set to
  `"off"` in `skillOverrides` (cc:965, cc:969). Record whether Claude invoked the skill, and
  measure output quality separately.

### 3.1 claude-infra

SKILL.md: 91 lines (83 in the body). No supporting files. Description: 387 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Falls short | `:2`: the name contains the reserved word `claude` (bp:156). Claude Code loads it anyway. This matters only for an upload (cc:431). Smallest change: rename the skill to a name like `tooling-changes` if it is ever uploaded. |
| C3 | Meets | |
| C4 | Meets | "Covers where a rule lives and how to land it" (`:7-8`) gives what the skill does, but at the end. |
| C5 | Falls short | `:5-6` "when you keep pasting". Smallest change: drop that sentence. |
| C6 | Falls short | `:5-7` copies the docs' general sentence about when to create a skill (cc:11). That sentence is not a trigger for this skill, and it spends listing budget. Smallest change: replace it with "Also use when deciding whether a procedure should become a skill." |
| C7 | Meets | Claude must load this skill on its own when it changes tooling. |
| C9 | Meets | |
| C10 | Falls short | `:30-47` quotes 18 lines of Anthropic's prompting guidance, which Claude already has (bp:26). Smallest change: keep the two URLs and one sentence, "Make only the change asked for, at the scope intended." |
| C11 | Meets | The procedure comes first. |
| C12 | Falls short (minor) | `:40-46` quotes a page written for one model version ("Prompting Claude Opus 5"). It will go stale with the next model. Smallest change: covered by the C10 cut. |
| C13 | Meets | |
| C14 | Meets | The Vale plugin example at `:71-73` is concrete. |
| C15 | Meets | Six numbered steps (`:16-51`). |
| C16 | Meets | `claude-tooling-sync verify` (`:28`) and the audit step (`:50`). |
| C17 | Not applicable | |
| C18 | Not covered by the docs | The layout and inventory live outside the skill folder, in `~/.claude/docs/claude-tooling.md` (`:14`). |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | Names `claude-tooling-sync`. |
| C22 | Meets | The skill itself teaches the hook-first rule (`:22-26`). |
| C23 | Not applicable | |
| C24 | Falls short | No evaluations. Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | No credential-like value. |

### 3.2 engine-consult

SKILL.md: 139 lines (136 in the body). No supporting files. Description: 370 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Falls short | `:3` gives only when to use the skill. Smallest change: open with "Runs the consultation between a cairn-consuming site and the engine before the site builds against an engine surface." |
| C5 | Meets | |
| C6 | Meets | Names repos and trigger phrases. |
| C7 | Meets | Claude must start it on its own while authoring. |
| C9 | Meets | |
| C10 | Falls short | `:11-13` narrates the history the skill replaced ("so the site paid for the workaround and the engine paid again"). cc:380 says to state what to do. Smallest change: cut `:11-13`. |
| C11 | Meets | "When it fires" comes first. |
| C12 | Falls short | `:77` pins the model ID `claude-opus-5-5`. `:135-139` is a one-time section that asks to delete itself. Smallest change: say "an Opus subagent" at `:77`, and move the first-run note into the rulings ledger. |
| C13 | Meets | |
| C14 | Meets | Templates at `:26-30` and `:56-63`. |
| C15 | Meets | The checklist at `:107-127`. |
| C16 | Meets | The backstop at `:38-41`. |
| C17 | Not applicable | |
| C18 | Not covered by the docs | Every reference sits in another repo: an agent definition (`:72`, `:78`), a ledger (`:80`), and another repo's release skill (`:124`). |
| C19 | Not covered by the docs | `:124` sends Claude to a second skill's SKILL.md. |
| C20 | Not applicable | |
| C21 | Meets | |
| C22 | Falls short | `:41` "The check is a blocking precondition on the first dispatch" holds only by instruction. Smallest change: have the repo's plan check, or a hook before the first agent dispatch, refuse a plan header that has no consultation line. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | No credential-like value. |

### 3.3 google-sheets

SKILL.md: 77 lines (74 in the body). References: `apps-script.md` 55 lines, `trigger-tests.md` 57
lines, `sheet-design.md` 92 lines. Description: 446 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | "Use when..." then "Covers...". |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Meets | Writes happen on the owner's request, and the risky deletes are denied in settings (`settings.json:161`, `:167-169`). |
| C9 | Meets | |
| C10 | Falls short (minor) | `:25` "The 2026-11-02 attendance mockup skipped this and came out a mess." narrates why. Smallest change: cut that sentence. |
| C11 | Meets | |
| C12 | Falls short (minor) | `references/apps-script.md:3` pins "clasp 3.4.1". Smallest change: write "Tested with clasp 3.4.1", so a reader knows the version is a record and not a requirement. |
| C13 | Meets | |
| C14 | Meets | `references/trigger-tests.md` has worked handlers. |
| C15 | Meets | Setup at `:36-48` and testing at `:52-65`. |
| C16 | Meets | Read back, diff, and restore (`:54-61`). |
| C17 | Not applicable | |
| C18 | Meets | Each reference is named with its use (`:23`, `:50`, `:71`). |
| C18, a second look | Falls short | `:15-17` sends Claude to the `anthropic-skills:google-workspace` skill, and `settings.json:362` turns that skill off. Invoking it by full name returns an error (cc:934). Smallest change: copy the few facts this skill needs into a new `references/sheets-api.md`, or change the override to `"name-only"`. |
| C19 | Meets | |
| C20 | Meets | Every reference is under 100 lines. |
| C21 | Meets | `gws` and `clasp` are named, with a version. |
| C22 | Meets | The deletes are denied in settings rather than left to the skill. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | Contains an email address at `SKILL.md:8`. Contains a credential-like value (a Cloud project number) at `SKILL.md:44`. |

### 3.4 log-project

SKILL.md: 109 lines (103 in the body). No supporting files. Description: 220 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | "Create, update, close, or report on an initiative record... Use when..." |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Meets | It confirms with the user before writing (`:49-54`). |
| C9 | Meets | |
| C10 | Meets | |
| C11 | Meets | |
| C12 | Meets | |
| C13 | Falls short (minor) | The name says "project", while the body and description say "initiative" throughout. Smallest change: none needed in the body. The description already leads with "initiative record". |
| C14 | Meets | The confirm template at `:51-54` and the YAML at `:62-71`. |
| C15 | Meets | Steps 1 to 6. |
| C16 | Meets | `scripts/check` before commit (`:95`). |
| C17 | Not applicable | |
| C18 | Not applicable | |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | |
| C22 | Not applicable | |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | Contains an account identifier (a GitHub owner name) at `:12`, `:45`, and `:67`. |

### 3.5 mail-tend

SKILL.md: 127 lines (124 in the body). No supporting files. Description: 474 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | "Use when..." with quoted phrases, then "Covers...". |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Falls short (judgment) | Section 4 (`:85-108`) moves and trashes stored mail, which is a side-effect workflow (cc:565). The ask at `:95-97` guards it today. Smallest change: move section 4 into its own skill with `disable-model-invocation: true`. Keep diagnosis and data edits model-invoked. |
| C9 | Meets | |
| C10 | Meets | Mostly operational facts Claude cannot know. |
| C11 | Meets | "Read before you change anything" comes first (`:23`). |
| C12 | Meets | The version quirk at `:120` states the version it applies to, inside "Known snags". |
| C13 | Falls short | "plan" means the move plan at `:76`, `:95-104`, and `:114`, but means a pass plan at `:52` ("no plan of yours moved them"). Smallest change: write "no change of yours" at `:52`. |
| C14 | Meets | The sample ask at `:96-97`. |
| C15 | Meets | |
| C16 | Meets | The hash check (`:80-81`), `--check` (`:79`), and `undo` (`:108`). |
| C17 | Meets | The 20-move threshold (`:95`) and the 24-hour expiry (`:104`) are stated as policy and script behavior. |
| C18 | Not covered by the docs | The rule set and references live in another repo (`:9-11`, `:121`). |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | `jq` and the repo scripts are named. |
| C22 | Meets | The classifier and exact allow rules enforce `:88-90` (`settings.json:140-143`). |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | Contains an account identifier and host name (an ssh login) at `:27`, `:33`, and `:99`. Contains an email address at `:59`. |

### 3.6 maintenance-mode

SKILL.md: 76 lines (73 in the body). No supporting files. Description: 345 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | "Puts a finished production project in maintenance mode... Use when..." |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Meets | |
| C9 | Meets | |
| C10 | Falls short (minor) | `:64` is one line of over 600 characters that mixes a rule with a version forecast. Smallest change: see C12. |
| C11 | Meets | |
| C12 | Falls short | `:64` "TypeScript 7.0 has no stable programmatic API, expected in 7.1... SvelteKit is aiming at 7.1" will go stale. Smallest change: cut that sentence. The line already says to read `<repo>.blocked` and what the framework targets. |
| C13 | Meets | |
| C14 | Meets | |
| C15 | Meets | "Enter maintenance mode" has steps 1 to 4. |
| C16 | Meets | `--dry-run` (`:49`) and `--status` (`:31`). |
| C17 | Meets | "seven days old" (`:21`) is a stated policy. |
| C18 | Not applicable | |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | |
| C22 | Meets | The timer and its gate are code. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | Contains an account identifier (a GitHub owner name) at `:43`. |

### 3.7 proton-pass

SKILL.md: 93 lines (90 in the body). No supporting files. Description: 369 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Falls short (minor) | `:3` lists topics and when to use the skill, but never what the skill holds. Smallest change: add "Holds the vault map, the naming rules, and the claude-pass procedures," which `:10-11` already says. |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Meets | Bulk edits are the owner's, and a hook blocks them (`:81-82`). |
| C9 | Meets | |
| C10 | Meets | |
| C11 | Meets | The authoritative-record rule comes first. |
| C12 | Meets | |
| C13 | Meets | |
| C14 | Meets | The template field at `:56-57`. |
| C15 | Meets | |
| C16 | Meets | "check it, then trash the old one" (`:59`). |
| C17 | Meets | The 25-minute wait and 150-second spacing (`:63-64`) are tied to the observed throttle. |
| C18 | Not covered by the docs | The agent and token facts live in `~/.claude/docs/bluefin-admin/secrets.md` (`:10`). |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | |
| C22 | Meets | `claude-block-pass` enforces `:9` and `:82`. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | Names household members in the vault table (`:20-29`). Names private alias domains at `:92-93`. Neither is a credential. |

### 3.8 register-check

SKILL.md: 83 lines (79 in the body). No supporting files. Description: 277 characters. Sets
`context: fork`.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | |
| C5 | Falls short (minor) | `:3` opens with the imperative "Run". Smallest change: "Runs". |
| C6 | Meets | |
| C7 | Meets | Edits happen only when `apply` is `yes`. |
| C9 | Meets | |
| C10 | Meets | |
| C11 | Meets | |
| C12 | Meets | |
| C13 | Meets | |
| C14 | Meets | |
| C15 | Meets | Four gates, then a fold. |
| C16 | Meets | Cheapest first, and error-tier findings are fixed before agents run (`:25`). |
| C17 | Not applicable | |
| C18 | Not covered by the docs | `:75` points to a path inside one repo's `.claude/skills/`. The path resolves only when the fork runs in that repo. |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | Vale and `tellgrader`. |
| C22 | Not applicable | |
| C23 | Falls short | The fork runs in the background by default (cc:811), with the narrower background tool set (cc:822). This skill dispatches two agents (`:34`, `:39`), runs shell tools, and must hand back one folded report (`:65-71`). Smallest change: add `background: false`. Optional: add `argument-hint` (cc:406) for the three arguments described in prose at `:12-16`. No `agent` field means `general-purpose` (cc:867), which fits. |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | No credential-like value. |

### 3.9 retire-project

SKILL.md: 73 lines (70 in the body). No supporting files. Description: 311 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Falls short | The skill is irreversible (`:8`), which is the docs' own case for `disable-model-invocation: true` (cc:565). The description also asks Claude to start it on its own, "when an initiative closing leaves a project with no use" (`:3`). Smallest change: add `disable-model-invocation: true`, or drop that last trigger clause. The approval stop at `:38-42` stays either way. |
| C9 | Meets | |
| C10 | Meets | |
| C11 | Meets | The irreversibility rule comes first. |
| C12 | Meets | |
| C13 | Meets | |
| C14 | Meets | The parked-domain records at `:53`. |
| C15 | Meets | Five ordered steps. |
| C16 | Meets | A restore test (`:33-35`), `rclone check`, a rerun of the inventory before each delete (`:46`), and an empty inventory at close (`:61`). |
| C17 | Not applicable | |
| C18 | Not applicable | |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | `age`, `rclone`, and `gh`. |
| C22 | Meets | A human approval stop sits between the archive and the teardown. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | No credential-like value. |

### 3.10 runbook

SKILL.md: 26 lines (23 in the body). No supporting files. Description: 393 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | "Use before..." and "Routes to the household-it repo's README." |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Meets | |
| C9 | Meets | |
| C10 | Meets | A pure router that holds no facts (`:9`). |
| C11 | Meets | |
| C12 | Meets | |
| C13 | Meets | |
| C14 | Not applicable | |
| C15 | Meets | |
| C16 | Meets | The repo gate (`:25-26`). |
| C17 | Not applicable | |
| C18 | Not covered by the docs | Every target is in another repo. |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | |
| C22 | Not applicable | |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. Of the 13, this skill's trigger matters most to test, since it must win over Claude's memory. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | No credential-like value. |

### 3.11 survey (vendored)

SKILL.md: 91 lines (88 in the body). References in `writing/`: `agent-facing.md` 102 lines,
`approval-brief.md` 437, `authoring-charter.md` 90, `commit-and-pr.md` 113, `editor.md` 99,
`technical-doc-go.md` 96, `technical-doc-web.md` 102, and `writing-voice.md` 64. Description: 315
characters.

The survey repo owns this skill, and the workstation vendors it (see the appendix). Each smallest change
below lands in that repo, or in the local overlay.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | |
| C5 | Falls short | `:3` "when [the owner] corrects your wording". Smallest change: "corrects Claude's wording". |
| C6 | Meets | |
| C7 | Falls short | "Releasing a change" (`:75-91`) is a maintainer workflow with side effects, and it loads with every UI task. Smallest change: move it to `references/releasing.md`, or to its own skill with `disable-model-invocation: true` (cc:565). |
| C9 | Meets | |
| C10 | Falls short | The 17 long release lines load with every UI task (cc:380). Smallest change: the same move as C7. |
| C11 | Meets | |
| C12 | Meets | |
| C13 | Meets | |
| C14 | Meets | |
| C15 | Meets | |
| C16 | Meets | `diff -r` (`:85`) and the before-merge check (`:88`). |
| C17 | Not applicable | |
| C18 | Falls short | `:44` routes readers to `approval-brief.md`. The overlay at `:7` says "nothing reads writing/approval-brief.md". The register also serves the Approval Queue, which is being replaced. Smallest change: drop row `:44` upstream. |
| C19 | Falls short (minor) | The register files link onward. For example, `writing/agent-facing.md:12` and `:18` point to `~/.claude/docs/authoring-charter.md` and to `writing-voice/evals/tellgrader/MEASURES.md`, two levels from SKILL.md (bp:380). Smallest change: mark those links as citations, not as reading steps. |
| C20 | Falls short | `agent-facing.md` (102 lines), `commit-and-pr.md` (113), `technical-doc-web.md` (102), and `approval-brief.md` (437) have no table of contents. Smallest change: add a contents list to the first three, and delete the fourth. |
| C21 | Meets | `npm`, `gh`, and `git`. |
| C22 | Falls short | `:54` "log it before going on" must hold on every correction, but only an instruction holds it (cc:1228). Smallest change: a reminder hook on each user message. The docs do not cover how a hook would detect a correction. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | Contains absolute home paths with an account name at `:56`, `:64-67`, `:71`, `:80`, and `:89`. Contains an account identifier (a GitHub owner name) at `:12`, `:71`, `:87`, and `:88`. `writing/commit-and-pr.md:99` holds an email address in a commit example. |

### 3.12 vps-conventions

SKILL.md: 105 lines (102 in the body). No supporting files. Description: 461 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Falls short | `:3` is three "Use when" sentences and never says what the skill holds. Smallest change: open with "Holds the judgment calls for systemd units, cloud-init, and deploy scripts on a RHEL-family VPS," which `:8-11` already says. |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Falls short (minor) | This is background knowledge, and `/vps-conventions` is not a meaningful command (cc:567). Smallest change: add `user-invocable: false`. |
| C9 | Meets | |
| C10 | Meets | `:8-9` sets the scope ("Not a general sysadmin reference"). |
| C11 | Meets | |
| C12 | Meets | |
| C13 | Meets | |
| C14 | Meets | The common-mistakes table at `:97-105`. |
| C15 | Not applicable | Rules, not a workflow. |
| C16 | Meets | `systemd-analyze verify` (`:91`). |
| C17 | Meets | |
| C18 | Not applicable | |
| C19 | Not applicable | |
| C20 | Not applicable | |
| C21 | Meets | `podman` for the package check (`:64`). |
| C22 | Meets | The gate enforces unit checks. |
| C23 | Not applicable | |
| C24 | Falls short | Smallest change: E1. |
| C25 | Falls short | Smallest change: E2. |
| C26 | Falls short | Smallest change: E3. |
| Values | Not covered by the docs | No credential-like value. |

### 3.13 writing-voice

SKILL.md: 112 lines (109 in the body). The `evals/` folder holds 47 files. The ones Claude might
read are `README.md` (51 lines), `evals.json` (186), `tellgrader/MEASURES.md` (286),
`research/2026-09-01-ai-tell-evidence-base.md` (548), and three dated result folders, each with a
`benchmark.json` (1,225 lines), a `benchmark.md`, and a `notes.md`. The rest is the `tellgrader`
Go source and its test data. Description: 277 characters.

| Item | Verdict | Where, and the smallest change |
| --- | --- | --- |
| C1 | Meets | |
| C2 | Meets | |
| C3 | Meets | |
| C4 | Meets | "Use when... to load the audience's external standard... The on-demand router..." |
| C5 | Meets | |
| C6 | Meets | |
| C7 | Meets | |
| C9 | Meets | |
| C10 | Falls short | `:84-88` covers only the cairn front door, yet loads for every prose task. `:14-17` explains why exemplars work, which cc:380 says not to narrate. Smallest change: move `:84-88` into `cairn-writing-docs`, which `:82` already names, and cut the sentence at `:15-16`. |
| C11 | Meets | The routing table comes early. |
| C12 | Meets | The benchmark citations at `:67-69` and `:74-75` are provenance, not date-conditional rules. |
| C13 | Meets | |
| C14 | Meets | |
| C15 | Meets | |
| C16 | Meets | Vale and `tellgrader` run on save (`:101-109`). |
| C17 | Not applicable | |
| C18 | Not covered by the docs | Every routed file is outside this folder. Six are in `~/.claude/docs/voice/`, and five of those link into survey's `writing/` folder. The others are in cairn-cms (`:26-28`, `:100`). |
| C19 | Falls short (minor) | The routed register files link onward, the same issue as survey C19. |
| C20 | Falls short | The routed files `agent-facing.md`, `commit-and-pr.md`, and `technical-doc-web.md` are over 100 lines with no table of contents. The fix is upstream in survey. |
| C21 | Meets | `tellgrader` and Vale are named, with their locations. |
| C22 | Meets | The save hooks carry the deterministic checks. |
| C23 | Not applicable | |
| C24 | Meets | `evals/evals.json` holds 12 drafting tasks, each with four assertions. `README.md` describes the with-skill and bare runs. |
| C25 | Falls short | `results/2026-09-01/notes.md:3`: "Both arms drafted on Sonnet; judges ran on Opus". Smallest change: rerun both arms on Haiku and Opus. |
| C26 | Falls short | The with-skill arm reads SKILL.md directly (`evals/README.md:24-26`), so the eval never measures whether Claude loads the skill unprompted. The latest results also date from 2026-09-01, before later edits such as the ruling at `:42`. Smallest change: add trigger prompts (E3), and rerun the corpus. |
| Values | Not covered by the docs | No credential-like value in SKILL.md or `evals/README.md`. The research and benchmark files were not scanned in full (section 6). |

## 4. Dependencies on the six process skills

Each row is a place where one of the 13 names a process skill, the pass, a plan in the pass sense,
a packet, or the Approval Queue. Uses of "plan" that mean something else are left out, such as
mail-tend's move plan.

| File:line | What it depends on |
| --- | --- |
| `claude-infra/SKILL.md:5` | The description lists "the pass process" as a trigger. |
| `claude-infra/SKILL.md:29` | "every plan or executing dispatch". |
| `claude-infra/SKILL.md:48-49` | Lands a change through a pull request "unless it meets `pass-core` "Direct changes"". |
| `claude-infra/SKILL.md:78` | "Plans... are checked by the two save hooks". |
| `engine-consult/SKILL.md:3` | The description triggers on "authoring a pass plan" and on "when a pass starts on a committed plan". |
| `engine-consult/SKILL.md:8-9` | "The pre-pass exchange"; "before the pass builds". |
| `engine-consult/SKILL.md:17-21` | Enumeration runs "whenever a site pass's plan is authored" and writes to "the plan header". |
| `engine-consult/SKILL.md:23-36` | The plan header's consultation and sources lines. |
| `engine-consult/SKILL.md:38-41` | The "Pass-start backstop", a precondition on the first implementer dispatch. |
| `engine-consult/SKILL.md:45-46` | "Any repo whose pass builds against the engine... wherever the plan is authored". |
| `engine-consult/SKILL.md:51-53`, `:59`, `:80`, `:82` | One brief per consulting pass, linked from the site plan; triage by "the planning session". |
| `engine-consult/SKILL.md:89-93`, `:101-105` | Mini engine pass now, or a queued engine pass. |
| `engine-consult/SKILL.md:107-127` | "Cross-repo mini-pass checklist". |
| `engine-consult/SKILL.md:118` | "The lean pass loop per `cairn-pass`". |
| `engine-consult/SKILL.md:131` | "mid-pass discovery". |
| `log-project/SKILL.md:100-102` | "A pass writes its record once, when the planner commits the design, plan, and prompts". |
| `mail-tend/SKILL.md:52` | "no plan of yours moved them". |
| `mail-tend/SKILL.md:66` | A deletion or access change "goes to [the owner] in a packet instead (`approval-packet`)". |
| `mail-tend/SKILL.md:78` | Pushes a data edit to `main` under "`pass-core` "Direct changes"". |
| `mail-tend/SKILL.md:121` | Cites a decisions anchor named for "the mail-filters pass". This is a link only. |
| `maintenance-mode/SKILL.md:62` | "Run a normal pass through `pass-core`". |
| `maintenance-mode/SKILL.md:64-65` | "can't see a pass in a worktree, so that pass rebases". |
| `retire-project/SKILL.md:40` | "Send the dry run as a document through `approval-packet`". |
| `survey/SKILL.md:7` | The overlay names `writing/approval-brief.md`. |
| `survey/SKILL.md:44` | Routes "The brief that opens a design, plan, or PR for approval" to `approval-brief.md`. |
| `survey/SKILL.md:86` | "After approval, merge the Survey PR: `approval-queue merge <id>`". |
| `survey/SKILL.md:88` | "merge it with `approval-queue merge --premerge-done ...`". |
| `survey/writing/approval-brief.md` (whole file, 437 lines) | "Register: the approval-queue brief" (`:1`). The reader decides "in the Approval Queue" (`:3`). Packet rules, the `approval-queue` command, and its hook appear at `:104`, `:137-139`, `:171`, `:200`, `:279`, `:283`, and `:434`. |
| `survey/writing/commit-and-pr.md:33` | "the approval packet (`approval-packet`) is the hand-over". |
| `survey/writing/agent-facing.md:87-88` | An exemplar that says "When a pass adds a diagnosable code path... in the same pass". This is example text, a weak tie. |
| `survey/writing/authoring-charter.md:85` | "The cutover landed (plan 07)". This is history only. |

Five of the 13 have no such dependency: google-sheets, proton-pass, register-check, runbook, and
vps-conventions. writing-voice names "plan, spec" only as kinds of prose (`:3`), and it routes
"Anything [the owner] reads" to `written-for-people.md`, not to `approval-brief.md` (`:33`).

Settings carry three adjacent ties. The six skills' replacement should account for them:

- `settings.json:56` allows `Bash(approval-queue *)`.
- `settings.json:386` lets auto mode clear skill edits "when they implement a task of a pass plan
  [the owner] approved".
- `settings.json:390` lets auto mode clear `approval-queue merge <id>`, the command survey's
  release steps use.

## 5. What Claude Code now does natively

| In the skill | Native feature | Docs line |
| --- | --- | --- |
| The claude-infra description (`:5-7`) restates the docs' rule for when to create a skill. | The rule is the docs' own sentence. | cc:11 |
| The claude-infra audit step (`:50-51`) runs `/doctor prompt-audit`, `/skill-doctor`, and `skill-creator`, without restating them. | Built in. This is a model for the other skills. | cc:52, cc:955, cc:976 |
| claude-infra defers settings mechanics to `update-config` (`:20-21`). | Built-in skill. Already used correctly. | not covered by the docs (the skill appears in the session's skill list) |
| register-check describes three arguments in prose (`:12-16`). | `argument-hint`, named `arguments`, and `$ARGUMENTS`. When no placeholder takes the arguments, Claude Code appends them as `ARGUMENTS: <value>`, so today's prose works. | cc:406, cc:407, cc:489 |
| survey runs four git commands "exactly as written, so the allow rules match" (`:62-67`), with rules at `settings.json:36-37`. mail-tend says the same of its sort script (`:87-88`). | `allowed-tools` grants tools for the turn that invokes the skill. `${CLAUDE_SKILL_DIR}` in both places lets a bundled script run with no prompt. The docs do not cover how this interacts with auto mode. | cc:410, cc:500 |
| survey's correction log (`:54`) and engine-consult's backstop (`:41`) are must-hold rules written as instructions. | A hook runs "whether or not Claude is following the skill". | cc:1228 |
| writing-voice's eval corpus uses `evals/evals.json` and aggregates with skill-creator's script (`evals/README.md:47-51`). | The skill-creator plugin stores test cases in `evals/evals.json` and runs the with-and-without comparison. | cc:976, cc:989 |
| No skill records a with-and-without trigger test. | Set a personal skill to `"off"` in `skillOverrides` for the baseline. | cc:965, cc:969 |
| vps-conventions triggers on "systemd units", "cloud-init user-data", and "deploy scripts" in prose (`:3`). | `paths` activates a skill on matching files, such as `**/*.service`, `**/*.timer`, and `**/user-data.yaml`. | cc:418 |
| `claude-tooling-sync verify` checks that each vendored skill folder has a SKILL.md (`vendored-skills.json`, `_doc`). | `claude plugin validate` finds frontmatter that doesn't parse. The docs' own example, `claude plugin validate ~/.claude/skills`, reads none of these skills on this machine, because each entry is a Stow symlink. Validating the real folder, `~/.dotfiles/claude/.claude/skills`, passed. | cc:1215 |
| claude-infra and writing-voice route agent-facing writing through a register (`writing-voice/SKILL.md:31`). | "You don't need special system prompts or a "writing skills" skill to get Claude to help create Skills." This covers creating skills, not the house voice for them. | bp:796 |

## 6. What was not checked or could not be verified

- No evaluation or trigger test was run. Running one would need fresh sessions, and this audit was
  read-only. `/skill-doctor` was not run, so listing cost and use counts are unknown.
- The sub-agents docs page was not fetched. So the exact background tool set (cc:822), and whether
  it covers the Agent tool and Bash for register-check, is unverified.
- The audit did not check whether `CLAUDE_CODE_SUBAGENT_MODEL` and `CLAUDE_CODE_SUBAGENT_EFFORT` in
  `settings.json` `env` apply to a forked skill. The docs page does not say.
- References outside a skill's folder, in other repos, were not opened. Their existence and line
  counts are unverified.
- `writing-voice/evals/research/`, the three `benchmark.json` files, `tellgrader/MEASURES.md`, and
  the Go source were not read in full, so they were not scanned for values either. The scan for
  credential-like values covered every SKILL.md, the google-sheets references, survey's
  `writing/`, and `writing-voice/evals/README.md` and `evals.json`.
- The `skillOverrides` keys use full synced names, such as `anthropic-skills:docs`. The docs say
  user settings match "against skill names only" (cc:949) and that a synced skill's full name
  carries the `anthropic-skills:` prefix (cc:458). This session's skill list showed those skills
  with no description, and `google-workspace` absent, which is consistent with the overrides
  working. The audit did not test this further.
- Em dashes in skill bodies (two in register-check at `:41` and `:55`, eight in vps-conventions)
  break a house rule, not a docs item. They were not graded.
- Line counts come from `wc -l`. Description lengths count the folded YAML text after whitespace
  is joined.

## Appendix: the two settings files

### `~/.dotfiles/claude/.claude/settings.json`

The skill-related keys:

- **`skillOverrides`** (`:351-363`) sets ten skills synced from claude.ai to `"name-only"`: docs,
  pptx, xlsx, computer-use, docx, built-in-browser, chrome-browser, pdf, morning, and
  skill-creator. A `"name-only"` skill is listed to Claude by name only, without its description,
  and stays in the `/` menu (cc:925-930). The key also sets `anthropic-skills:google-workspace` to
  `"off"`, which hides it from Claude and the menu and makes a full-name invocation return an error
  (cc:934). None of the 13 personal skills is listed, so all 13 are `"on"` (cc:936). Plugin skills,
  such as the `standards:` ones, are not affected by this key (cc:951).
- **`outputStyle`** (`:350`) is `"writing-voice"`. The source of this output style is
  `survey/writing/writing-voice.md`, per the survey entry's `_why` in `vendored-skills.json`. The
  writing-voice skill describes it as "the always-on audience-invariant core"
  (`writing-voice/SKILL.md:110`).
- **`enabledPlugins`** (`:321`) turns on six plugins, among them `standards`, which carries the
  vendored skills marked `"home": "standards"`. **`extraKnownMarketplaces`** (`:329`) adds three
  marketplaces.
- **`permissions`** holds no `Skill(...)` rule. It holds exact Bash rules that two skills rely on:
  survey's correction-log git commands (`:36-37`), clasp commands for google-sheets (`:19-30`, with
  deletes denied at `:161` and `:167-169`), and mail-tend's sort script (`:140-143`). It also allows
  `Bash(approval-queue *)` (`:56`).
- **`autoMode.allow`** has two entries about skill files. `:386` clears edits to skill files in a
  dotfiles worktree that implement an approved pass plan. `:388` clears edits, commits, pull
  requests, and merges of CLAUDE.md, docs, and skill or agent files that the owner approved in the
  current session. `:390` clears `approval-queue merge <id>`.
- **`env`** sets the default subagent model to Sonnet at medium effort.
- These keys are absent: `skillListingBudgetFraction`, `disableSkillShellExecution`,
  `syncClaudeAiSkills`, and `SLASH_COMMAND_TOOL_CHAR_BUDGET`.

### `~/.dotfiles/claude/.claude/tooling/vendored-skills.json`

This is the manifest for third-party and separately maintained skills that the workstation copies
in rather than writes. Each entry records a GitHub source, the path in it, a branch or tag, the
commit taken, the license, and the install date, with an optional `_why`.

Its `_doc` says how the entries are used:

- `claude-tooling-sync update-skills` refetches an entry.
- `verify` checks that each folder exists and has a SKILL.md.
- An optional `description` overrides the skill's frontmatter description.
- An optional `note` lands as a marked paragraph after the frontmatter.
- `apply-overlays` writes both, and `lint` fails on drift.
- An entry with `"home": "standards"` lives in the standards plugin, not under
  `claude/.claude/skills`.

It lists 12 skills:

- **Kept in the standards plugin:** daisyui, golang-spf13-cobra, vale-ci, vale-fix, vale-setup,
  vale-triage, vale-vocab, brainstorming, and receiving-code-review.
- **Vendored into the skills folder:** survey, cc-desk, and cc-desk-work.

Of the 13 audited skills, only survey is vendored. Its `note` is the overlay at
`survey/SKILL.md:6-8`. Its `_why` says to edit its files only in the survey repo. The other 12
audited skills are authored on the workstation and are not in the manifest. cc-desk and
cc-desk-work, two of the six process skills being replaced, are vendored here too.
