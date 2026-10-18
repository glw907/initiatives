# Review: drafter onboarding design, agent-ergonomics lens

Target: `docs-system/specs/2026-10-18-drafter-onboarding-design.md` (branch
`docs-system-onboarding-design`, glw907/initiatives#18), read against the blueprint architecture it
amends, the change-read design, drafter at `f7d9034` (skill, format page, prompts module, `drafter
check` code), B2's format test (glw907/drafter#47), and drafter#43. Reviewer: adversarial, agent
ergonomics. Read-only except this file.

Three agents are in view:

- **A1**, a live implementer (Sonnet, medium) that changed a feature and has no docs context.
- **A2**, the onboarding skill's Claude Code session.
- **A3**, drafter's API seats (draft, blueprint read, editor, write-back) on the stock package with
  no house register.

Line numbers without a file name are in the onboarding spec.

## Verdict

The design sets the right goal, and its stock-package idea is sound. It is not yet buildable as an
agent path. Two things block it. First, the O pass's acceptance test ("a first accepted blueprint")
can't be reached by the steps the spec lists, and evidence says the whole read it depends on doesn't
converge. Second, every seat prompt that exists today assumes a register file and cairn's tracks,
and the spec names no mechanism that replaces them. Most major findings come from one gap: the spec
lists what ships but never maps each package part to the agent that consumes it, the file or
channel it reaches that agent through, and what happens when the part is absent.

## Findings, ranked by consequence

### 1. The O acceptance test can't be reached by the listed steps, and the read it needs doesn't converge

- Severity: **blocker**. Tag: `correctness`.
- Location: lines 129-132, 159-161; `docs-system/specs/2026-10-18-drafter-change-read-design.md:39`; drafter#43.
- Defect: O is accepted when "a fresh session in a new repo ... reaches a first accepted blueprint".
  "Accepted" means the blueprint read returned ok (architecture spec, step 4 of the nightly run, and
  the lock's `accepted` field). The skill's mechanical steps are listed as `drafter init`, `drafter
  check`, and fact verification (line 131). `drafter read` isn't among them, and neither is a budget
  or key step for an interactive session. A new blueprint has no `--since` base, so the change read
  doesn't apply ("The read is whole only when the blueprint is absent ... at `<rev>`"). The read
  then runs whole, and the whole read is the one drafter#43 recorded failing six rounds running on
  cairn's first blueprint (7, 5, 5, 2, 3, then 4 blocking findings, some seeded by the previous
  fix). Nothing in the spec or the change-read pass gives the whole read a convergence rule. A2 will
  loop read, fix, read, spending API money inside an interactive session with no stop rule. The
  alternative is to stop at `drafter check` green and never reach the acceptance bar.
- Fold: name `drafter read <blueprint>` as an onboarding step, with its spend shown before it runs
  and a cap of two rounds. After the cap, the skill hands the findings to the developer and stops.
  Then pick one:
  - **OWNER FORK.**
    - (a) Make O's bar "check green and the whole read ok within two rounds", and require a
      whole-read convergence rule (drafter#43) before O starts.
    - (b) Make O's bar "check green, plus one whole read whose findings the developer has triaged".
    - (c) Keep the bar and accept unbounded rounds.
  - Recommendation: (a). The bar then measures what a new user meets, and #43 stays a
    precondition rather than a surprise inside O.

### 2. The stock prompts have no specified behavior when no register exists

- Severity: **blocker**. Tag: `correctness`.
- Location: lines 77-80, 141-142; `claude/.claude/workflows/docs-page-chain.js:616`, `:630-651`,
  `:655`, `:853-858`, `:1530-1535`, `:1543`, `:1553-1558`, `:2299-2301`, `:1795`.
- Defect: line 78 says "A project with no register is complete, and nothing in drafter requires one".
  Line 141 says the stock prompts are "generalized from the chain's seat prompts". Every seat prompt
  that exists today depends on a register and on cairn:
  - `registerSectionsFor` throws on any track but cairn's six (`:640`). The module runs that check
    for every page at load (`:655`).
  - `draftPrompt` makes voice come "only from the register's drafting brief and its primary
    exemplar, docs/extend/choose-an-ai-posture.md" (`:1533-1534`). It names
    `scripts/checks/check-provenance.mjs` (`:1558`) and `Cairn.Names` (`:857`).
  - `blueprintPrompt` tells the seat to read "## The page anatomies" of `${REGISTER}` (`:2299`).
    drafter's assembler inlines only tracked files (`internal/assemble/files.go:127-145`). So in a
    register-less repo the path silently inlines nothing. The assembler's note then tells the seat
    "If ... you could not make a check because something is not inlined, say so as a finding"
    (`internal/assemble/assemble.go:59`). The anatomy check is "the second half of the same check"
    as the introduction check, so every register-less blueprint read is likely to draw a finding
    that the project can't fix.

  The spec gives F no inventory of these dependencies and no test that the generalization is
  complete.
- Fold: add a table to "What drafter ships stock" with one row per seat (draft, blueprint read,
  consistency, editor, fact read, write-back, coherence) and one column per package part (rules,
  corpus, names, tells, rubric, anatomies, introduction guidance). Each cell names the source file
  or embedded asset and the behavior when the part is absent. Add an F acceptance check:
  `drafter check-prompts` renders every stock seat against a fixture project with no register and
  one non-cairn track, and fails when a rendered prompt names a path the project doesn't hold or a
  cairn-only name.

### 3. The stock package has no channel to reach the API seats

- Severity: **major**. Tag: `correctness`.
- Location: lines 57-65, 141-149; `internal/assemble/files.go:30-56`, `:127-152`;
  `docs/configuration.md:142-144`.
- Defect: an API seat sees only what drafter inlines: tracked repo files, plus out-of-repo paths in
  `inline_files`, which is a user- and local-layer setting only. The stock package is "built into
  the binary" (line 141), so no prompt path can reach it today. Three parts are worse off:
  - **Rules**: "The published guide itself, never copied." An API seat has no web access, so it
    gets the Google or Microsoft guide by name only and grades from memory. B2 already showed one
    defect changing severity between reads. Grading against an unseen rule set makes that worse.
  - **Corpus**: "excellent outside pages, each cited". To be imitated, those pages must be inlined
    whole (the chain says "read each in full"), and that means copying third-party pages into
    drafter's public repo or binary. Copying needs a license check per page; for example, check
    whether a source repo publishes under CC BY 4.0 before you embed its pages.
  - **"Or another" standard** (line 44): with no stock package, A3 has nothing at all.
- Fold:
  - Specify an embedded-asset channel: drafter appends the stock package's files as named blocks,
    the way it appends the facts block. Make the reviewer rubric the only rules text a seat sees,
    each item citing the guide's URL and section.
  - Allow only Google and Microsoft until a third package exists, and have `drafter check` error on
    a track that names a standard drafter doesn't ship.
  - **OWNER FORK** on the rules text.
    - (a) Name only: the seat relies on model knowledge plus Vale.
    - (b) A rubric of short, cited rule statements, paraphrased, never copied.
    - (c) Quoted excerpts under the guide's license.
    - Recommendation: (b). It fits "never copied" and gives the editor a fixed list, which
      reduces the severity drift B2 measured.

### 4. Page types and anatomies still resolve to a register that may not exist

- Severity: **major**. Tag: `correctness`.
- Location: lines 40-46, 147-148; `docs/blueprint-format.md:205-206`, `:81-83`;
  `internal/blueprint/check.go:221`; `internal/blueprint/blueprint.go:125-126`;
  `claude/.claude/skills/blueprint/new-page.md:53`, `:82`.
- Defect: these places all still point at the register:
  - The format page says a type's `anatomy` "names the register entry the type follows".
  - `drafter check`'s fix text says "set anatomy to the name of a register anatomy entry, such as
    Task guide".
  - Register sections come from `register.<track>` settings.
  - new-page step 1 says "Read the register entry for that type's introduction and ending". Step 4
    says "Read the register's introduction rules".

  In a register-less project, A1 and A2 follow the procedure into a file that doesn't exist. The fix
  message sends them to it too. The spec moves anatomies and introduction guidance into drafter's
  base (lines 79, 147-148) but never retargets `anatomy`, the check, or the skill. A Sonnet agent
  at medium effort meeting a missing file in step 1 will either invent an anatomy or stop.
- Fold:
  - Say that `anatomy` names a stock anatomy id from drafter's base list, or a register entry when
    a register is configured.
  - Have `drafter check` validate the name against that list. Today it checks only that the field
    isn't empty.
  - Retarget the fix message and new-page steps 1 and 4 to the base reference, and list them as F
    deliverables.

### 5. Tracks, Diátaxis modes, Good Docs templates, page types, and anatomies have no defined mapping

- Severity: **major**. Tag: `correctness`.
- Location: lines 40-46; `docs/blueprint-format.md:194-225`; `docs/configuration.md:274-281`.
- Defect: the spec stacks five taxonomies: reader tracks, Diátaxis modes "inside each" track, Good
  Docs templates for anatomies, the outline's `types`, and each type's `anatomy`. It doesn't say
  which one an agent writes into `type`, whether a mode is a field, or where a page's track lives.
  The spec says tracks are declared in `outline.yaml`, but the format page's outline schema has no
  track field. drafter's config keys tracks as `register.<track>`, and the chain derives them from
  `docs/<arm>/` paths. A2 must propose tracks and an outline, and A1's new-page step 1 says "Pick
  its page type". Neither can be done consistently when the spec gives three homes for a track and
  no rule for which taxonomy is the type.
- Fold: specify the outline schema in this spec:
  - A `tracks` list, each entry with `name`, `reader`, and `standard`.
  - A `track` field on each page entry.
  - Each `types` entry gains a `mode` (one of the four Diátaxis values) and an `anatomy` (a stock
    anatomy id, which is a Good Docs template).

  `register.<track>` then keys on the declared track name, and `drafter check` errors on an
  undeclared track.

### 6. Existing pages bootstrapped through new-page will be redrafted whole, overnight, at full cost

- Severity: **major**. Tag: `correctness`.
- Location: lines 123-125, 169-170; architecture spec lines 175-188, 361.
- Defect: line 124 gives an existing page its first blueprint "the same way, with the page itself as
  a source". The spec doesn't say whether the lock is seeded with the page as it stands, which the
  converter does. Without a seed, detection classes the page as "New blueprint". New pages are
  "always drafted whole", so the first night redrafts every existing page in the doc set. That
  replaces working human prose and spends roughly $3 to $4.50 a page against a $160 cycle. A
  40-page project would use up the cycle in one night.

  The amendment also contradicts the architecture's "Bootstrapping" item 2 (the write-back seat
  bootstraps a page with no plan), but it claims "Everything else in that spec stands" (line 5).
  An agent reading both specs gets two procedures.
- Fold: have the onboarding skill seed each existing page's lock entry at commit, with a `drafter`
  subcommand (the converter's seeding, exposed), and amend architecture item 2 explicitly.
  - **OWNER FORK.**
    - (a) Seed the lock, so existing pages keep their prose until their blueprint next changes.
    - (b) Redraft all existing pages into the standard's voice, spread across nights inside the
      cap.
    - (c) Ask per project during onboarding.
  - Recommendation: (a) as the default, with (b) offered once in the interview, since it's a
    budget and voice choice.

### 7. Fact verification as specified can't catch a hallucinated fact, and the source grammar is undefined

- Severity: **major**. Tag: `correctness`.
- Location: lines 38-39, 145, 167-168; `docs/plan-format.md:366-381`;
  `cairn-cms/scripts/checks/check-facts.mjs:39-55`.
- Defect: Call 1 limits drafter's check to "a cited source exists". An audit agent's typical error
  is a real file with a wrong claim, or a line range that drifted, and an existence check passes
  both. cairn's gate today is stronger than what the spec promises to generalize ("which cairn's
  gates do today"). It resolves `path:line` and `path#Symbol`, and it checks a quoted anchor's
  identifiers inside a ±10-line window. That check caught two drifted citations in cairn's real
  store.

  drafter's documented fact grammar (`plan-format.md`, "Facts files") specifies the id and the
  trailing tag but no `Source:` syntax. drafter parses the `Source:` marker internally
  (`internal/plan/facts.go:260`), but nothing documents it. A2 is told to write "each fact with its
  source" against an unpublished grammar. It then tags its own output `[verified]`, the only taggable
  state new-page allows, so the tag certifies nothing. The fact read (Call 1's other half) runs only
  when a page drafts, so audited facts no page places are never read.
- Fold: publish the `Source:` grammar in the format page: `path`, `path:line[-line]`, or
  `path#Symbol`, with an optional backticked anchor. Port cairn's anchored-window check as drafter's
  stock fact verification, and require an anchor on every fact the onboarding audit files. State in
  Call 1 that the check proves the source exists and carries the anchor, not that the claim is true.

### 8. The whole-codebase audit before the outline is the costliest and most drift-prone order

- Severity: **major**. Tag: `correctness`. **OWNER FORK.**
- Location: lines 35-49, 129-131; `claude/.claude/skills/blueprint/new-page.md:57-66`.
- Defect: the three pieces run audit, then tracks, then outline. An audit with no outline doesn't
  know which facts any page will need. For a repo of any size, it either overruns one session's
  context or files facts no page will cite. Those facts then sit `[verified]` and unread (finding 7)
  while the code moves. New-page step 2 already traces every claim of a page to code and files the
  missing facts, so the up-front audit duplicates it.
- Options:
  - (a) Keep the order as Geoff stated it.
  - (b) Run a surface inventory first: commands, config keys, public API, and error messages, each
    with a source and no claims. Propose tracks and the outline from it, and file facts per page
    during each blueprint's step 2.
  - (c) Run (b), plus a full audit only of reference surfaces such as a CLI or config reference,
    where every surface item is a fact.
- Recommendation: (b), or (c) for a project with reference pages. Either keeps every fact tied to
  a page that cites it, and gives one session a bounded job.

### 9. The onboarding skill is unspecified as an agent procedure

- Severity: **major**. Tag: `correctness`.
- Location: lines 127-137, 150, 159-161.
- Defect: the spec names the skill but gives none of what a Claude Code session needs to follow it
  across a real repo:
  - **Phases and outputs.** Which files each phase writes and commits.
  - **Stop points.** Where the developer must rule before the next phase.
  - **Defaults.** One per decision: track count, standard, register yes or no, and outline
    approval.
  - **Resumable state.** The O bar itself requires "a fresh session". The audit (finding 8) and one
    blueprint per existing page (finding 6) won't fit one context window.
  - **Delegation.** When to dispatch subagents for the audit.

  Anthropic's skill guidance asks for exactly these: "For particularly complex workflows, provide a
  checklist that Claude can copy into its response and check off". It also says to keep SKILL.md
  "under 500 lines" and split phases into reference files, and to avoid "offering too many options"
  by providing a default
  (<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>). The
  prompting guidance for multi-window work says "Use git for state tracking" and to keep progress in
  "structured formats"
  (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>).
- Fold: add a short "The onboarding skill" section to this spec:
  - A phase checklist (inventory, tracks, outline, facts per page, blueprints, check, first read),
    each phase one commit.
  - A default for every question: one track; Google for developer docs, Microsoft for end-user
    docs; no register; outline approved as a committed file the developer edits.
  - The rule that the session resumes from `git log` and the committed files, never from chat.
  - One reference file per phase.
  - Subagents for the inventory, one per surface, each returning sourced rows.

### 10. "Point `register` at the house style guide it already keeps" contradicts the register's fixed headings and row check

- Severity: **major**. Tag: `correctness`.
- Location: lines 67-71 against 84-85.
- Defect: drafter's prompts "load each section by name" from fixed headings, and `drafter check`
  "fails a rule with no row or a row missing its evidence or ruling". An organization's existing
  style guide has neither the headings nor the rows. A project that takes the line 84 path fails
  `drafter check` at once, and its seats load nothing. A2 offers this choice in the interview, so it
  will hit the contradiction on the first project with a house guide. The spec also never defines
  the grammar that tells `drafter check` what a "rule" and a "row" are in Markdown, so A1 can't
  predict that check's errors.
- Fold:
  - Make "bring one" mean the template wraps the existing guide: fixed headings, with the house
    guide linked or included under Rules. The row check then applies only to the template's
    overrides table.
  - Define that table's columns (base rule, instead, evidence, ruling, date) as the grammar the
    check parses.

### 11. `drafter init`'s empty facts directory makes `drafter check` exit 2

- Severity: **major**. Tag: `correctness`.
- Location: lines 143-144; `internal/plan/facts.go:111-125`;
  `docs/blueprint-format.md:280-284`; `docs/configuration.md:270-272`.
- Defect: `facts.dir` defaults on when `<root>/facts` exists. A facts directory holding no `.md`
  file other than `README.md` is a "can't run" state with exit 2. So `drafter init` followed by
  `drafter check` fails before the developer has done anything. The first error A2 meets is "the
  command can't run", which reads as a broken install rather than a next step.
- Fold: either `drafter init` writes a facts file with a header and no bullets, or an empty store
  becomes valid (zero facts, with a warning). List the choice as an F acceptance case: init, then
  check, exits 0.

### 12. "Background" now straddles a planning record and page content, with no item kind

- Severity: **major**. Tag: `correctness`.
- Location: lines 113-119; `docs/blueprint-format.md:94-109`.
- Defect: line 118 lets background a reader lacks be "a short passage in `framing`'s background
  part that cites its facts". `framing` is defined as the framing record's descriptive parts, a
  planning record the seats grade the introduction against. It isn't content the draft seat places
  in a section. A1 adding background can't tell whether the draft will render it, or where. The
  architecture's rule "an item kind for each common edit" is broken for this edit, and the edit
  catalog has no row for it.
- Fold: a background passage is a `sentence` (`mode: claim`) or `reason` item in the section that
  needs it, citing its facts. `framing.background` stays the planner's note of what the page rests
  on. Add an edit-catalog row: "Add background a reader lacks: a link to the concept page, or a
  `sentence` item citing its facts".

### 13. Key steps depend on the agent remembering to run a command

- Severity: **major**. Tag: `correctness`.
- Location: lines 145-146, 150; `claude/.claude/skills/blueprint/SKILL.md:16`; glw907/drafter#47
  ("never ran `drafter refs`; it searched with grep"); change-read design Outcome 3.
- Defect: the only fix the change-read pass plans for the refs miss is more skill text, the same
  kind of instruction that already failed. Three things depend on recall:
  - `drafter refs` on a fact change.
  - `drafter check` after an edit.
  - The skill firing at all after a code change: the hook fires only on page edits, and A1 has no
    docs context.

  Anthropic's features overview, which the architecture already cites, says "If a rule must hold
  every time, make it a hook rather than a prompt instruction". The spec adds a stock gate and a
  plugin but uses neither to force these steps.
- Fold:
  - (i) The stock gate's `drafter check`, run against a base revision, adds a warning per changed
    fact bullet that lists its `refs` placements. The output then carries the lookup the agent
    forgot.
  - (ii) The plugin ships a `PostToolUse` hook on `Edit|Write` of `*.blueprint.yaml` and facts
    files. It runs `drafter check <file>` and returns the findings as context.
  - (iii) **OWNER FORK** (the architecture lists this detection as a non-goal): `drafter check
    --since` could warn when a diff touches a file that a fact's `Source:` cites but no fact or
    blueprint changed.
    - Options: off, warning, or error.
    - Recommendation: a warning. Sources are machine-readable once finding 7 lands, so this costs
      little and gives A1 its trigger.

### 14. The skill's format reference isn't reliably loadable, and its item reference is two hops deep through a broken link

- Severity: **major**. Tag: `correctness`.
- Location: line 150; `claude/.claude/skills/blueprint/format.md` (a symlink to
  `../../../../docs/blueprint-format.md`); `docs/blueprint-format.md:7`, `:154`; BACKLOG #2.
- Defect:
  - B2's headless session was denied the format page, and the change-read design closes that
    backlog item with no change. Nightly or CI agents run headless.
  - Packaging the skill as a plugin (line 150) puts a symlink that points outside the skill tree
    into a plugin. Plugin paths must resolve inside the plugin root (Claude Code plugins reference,
    "Containment and existence"), so the reference may not survive install.
  - The format page sends the agent on to `plan-format.md` for the shared item kinds ("The plan
    format's item reference describes the kinds it shares"). From the skill directory, that link
    resolves to `claude/.claude/skills/blueprint/plan-format.md`, which doesn't exist. The
    item-field detail A1 needs most is a dead link two levels down.

  Anthropic's guidance: "Keep references one level deep from SKILL.md", and "For reference files
  longer than 100 lines, include a table of contents at the top". The format page runs 365 lines
  and has neither.
- Fold:
  - Ship the format page into the plugin as a real file, generated from `docs/blueprint-format.md`,
    with `make check` failing on drift.
  - Move the shared item-kind reference into the format page so it is self-contained.
  - Add a contents list at its top.
  - Make headless loading an O acceptance case.

### 15. The plugin doesn't deliver the `drafter` binary, and the skill is silent when it's missing or stale

- Severity: **minor**. Tag: `correctness`.
- Location: lines 24-26, 150, 160-161; `claude/.claude/skills/blueprint/SKILL.md:16`, `:33`.
- Defect: "one install covers them on any machine", but the skill's every check calls a Go binary
  the plugin doesn't carry. When it's absent, A1 gets "command not found" and, at medium effort,
  likely skips the check or greps, as B2's agent did for refs. The plugin and the binary also update
  independently, so the skill can document a flag the installed binary lacks (`--since` today).
- Fold: the skill says "If `drafter` isn't on PATH or rejects a flag, stop and report it; never
  skip the check." `drafter init` records a minimum version that `drafter check` enforces. The
  overview's install step installs both.

### 16. The introduction plan the spec relies on is optional in the format

- Severity: **minor**. Tag: `correctness`.
- Location: lines 107-116; `docs/blueprint-format.md:70`.
- Defect: "The blueprint plans it" through `framing`, but `framing` is `required: no`. The smallest
  valid blueprint A1 or A2 writes omits it, `drafter check` passes, and the stock draft prompt (F)
  has no intro plan to draft from. The introduction's promise also has three homes (the outline's
  `covers` and `outOfScope`, the blueprint's `introduction`, and `framing.introPlan`), which an
  agent must keep in step by hand.
- Fold: `drafter check` errors on a blueprint with no `framing.introPlan` unless it's converted (lock
  seeded), which gets a warning. Note that `introduction.covers` and `notCovered` restate the
  outline entry, and either derive them or say which home wins.

### 17. The onboarding skill should be user-invoked only, and the blueprint skill's description isn't third person

- Severity: **minor**. Tag: `optional`.
- Location: line 150; `claude/.claude/skills/blueprint/SKILL.md:3`.
- Defect: a long, interviewing, money-spending skill that the model can invoke will fire on any
  mention of drafter or docs setup. The blueprint skill's description is imperative ("Change a
  documentation page ..."). Anthropic: "Always write in third person. The description is injected
  into the system prompt".
- Fold: give the onboarding skill `disable-model-invocation: true`. Reword the blueprint
  description as "Changes a documentation page by changing its blueprint. Use when ...".

### 18. No fact-id scheme or facts-file layout for agents filing facts

- Severity: **minor**. Tag: `optional`.
- Location: lines 38-39, 143-144; `claude/.claude/skills/blueprint/new-page.md:62`.
- Defect: cairn mints opaque ids (`f:xxxxxx`, `check-facts.mjs --mint`), and drafter has no mint
  command. A2 filing hundreds of facts will invent semantic ids, which collide or go stale when the
  claim changes. Nothing says which file a fact goes in (per track, per surface, or per page).
- Fold: add `drafter facts mint`, or have `drafter init` declare the id prefix, and name the file
  rule (one file per track) in the format page.

### 19. Context cost is unbudgeted and grows with the doc set

- Severity: **minor**. Tag: `optional`.
- Location: lines 141-149; `claude/.claude/skills/blueprint/new-page.md:55`.
- Defect: A1's read today is SKILL.md (521 words), the format page (3,338), `plan-format.md` (4,051),
  the blueprint (cairn's runs to about 850 lines), and the facts file, before any edit. The stock
  package adds an anatomies page and the introduction guidance. New-page says "read the outline
  whole", which grows with every page. Nobody has measured this against Sonnet at medium.
- Fold: set a read budget for the small-edit path (SKILL.md plus the format page's one linked
  section plus the blueprint). Have `drafter refs` and `drafter check` print the item context A1
  needs, and replace "read the outline whole" with "read the entries `drafter outline --neighbors
  <slug>` prints", or keep the outline small enough to read.

### 20. The page hook silently does nothing on a machine without jq

- Severity: **minor**. Tag: `correctness`.
- Location: line 150; `bin/.local/bin/drafter-page-hook:5`.
- Defect: `command -v jq ... || exit 0`. On "any machine", the reminder that keeps A1 off page prose
  can vanish with no sign, and the plugin's promise isn't kept.
- Fold: the plugin's hook avoids jq (a `drafter hook page` subcommand reading stdin), or the O
  acceptance run uses a machine image without jq.

### 21. "Reasoned fresh, never from a template" sits beside "Good Docs templates"

- Severity: **minor**. Tag: `optional`.
- Location: lines 41-42, 108-109.
- Defect: A1 and A3 meet a Good Docs template that includes an overview paragraph, next to a rule
  that the introduction is never filled from a template. Sonnet will resolve the tension one way on
  one page and the other way on the next.
- Fold: one sentence: "A template gives the page's sections and their order; it never supplies the
  introduction's wording."

### 22. Two install paths for the same skill (over-ceremony)

- Severity: **minor**. Tag: `optional`.
- Location: line 171 (Call 3).
- Defect: keeping `make install`'s symlinks beside the plugin means two copies of the skill can be
  live on Geoff's machine, and the one he tests isn't the one a new developer gets. That is how the
  symlink defect in finding 14 survived B2.
- Fold: development loads the plugin from the checkout with `claude --plugin-dir`, and `make
  install` stops linking the skill once O lands.

## What holds up

- A stock package per standard, with a register as an optional overlay, is the right shape for A3.
  Findings 2 and 3 are about wiring it, not the idea.
- Moving introductions into the base, with the blueprint planning them, fixes a real gap.
- Making drafter onboard itself as the first new project is a sound end-to-end test, provided its
  bar (finding 1) can be met.
