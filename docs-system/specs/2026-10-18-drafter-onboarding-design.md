# Onboarding a new project to drafter

Status: designed with Geoff in chat, 2026-10-18; revised after four reviews
(`research/2026-10-18-drafter-onboarding-design-fold.md`); awaiting his approval. Initiative:
`docs-system`. It amends `2026-10-17-blueprint-architecture-design.md` ("arch") at the lines named
under "Changes to the architecture spec".

## Brief

Approving this makes setup for a new developer on a new project a first-class goal of drafter
(Geoff, 2026-10-18). A new project builds three things with Claude: a facts store from a code
audit, reader tracks on a published style standard, and an outline. The developer reads a short
system overview, installs drafter and its plugin, and runs an onboarding skill in Claude Code.
A house register stays optional, and introductions become part of drafter's base.

The order stands: change-read, F, B3, O, B4, B5. The reviews found that F was a list with no test,
so this revision gives each pass a fixture and a reason it fails today. It also moves work between
passes:

- F takes the outline's `tracks`, stock anatomies that replace the register pointers,
  an `init` whose output passes `drafter check`, fact verification ported from cairn's gate, a
  `drafter gate` command, and a guard that stops cairn from falling back to stock prompts.
- B3 writes the stock seat prompts and the brief's provenance check, because the
  handoff those prompts read is B3's to define, and it proves them on one synthetic page.
- O's bar rises: a fresh session in a clean environment, with no `~/.claude` and no dotfiles,
  onboards a synthetic repo and reaches a drafted page.

The cairn release waits at least one pass longer.

### Decide: existing pages keep their prose

Should onboarding keep each existing page's prose, by seeding its lock entry as conversion does,
and offer a priced full redraft once? Recommended: yes. Without a seed, the first run redrafts
every existing page whole, at $3 to $4.50 a page (arch 416), in a voice the developer never saw.
Yes builds a seeding command in F, and the skill asks the question once. No means each existing
page is redrafted whole on its first run.

### Decide: a stock price table

Should drafter ship a dated price table for its stock models, which the user layer can override,
while `page_cap`, `cycle_ceiling`, and `workspace_id` stay required and the skill asks for them?
Recommended: yes. Prices are published facts, and today a developer copies five rates per model
by hand (`docs/configuration.md:146-167`). Yes builds the table in F, and every run report shows
its date. No keeps prices as user settings that the skill helps fill.

### Decide: build only what has a consumer

Should the Microsoft package and the register kit (template, guide, and `init --register`) wait
for their first consumer, rather than being built in F to O? Recommended: yes. drafter's own docs
and the O fixture are developer docs on Google, so nothing in F to O would test either piece.
cairn's register split in B5 is the kit's first real consumer. Yes builds Google only and adds the
others when a project needs them. No builds both packages and the kit in F to O, untested.

## Goal and anti-goal

- Goal: a new developer on a new project gets drafter working through one documented path. They
  read the overview, install, and run the onboarding skill. Working means a drafted page.
- Anti-goal: a project needs a file, setting, agent, or tool that exists only on the machine that
  built drafter. Each such item has a pass that removes it:

| Workstation-only today | Source | Removed by |
|---|---|---|
| The prompts module | `prompts` is required (`internal/config/validate.go:40-41`); cairn's lives in an ignored local file (cairn `drafter.toml:1-3`) | F mechanism, B3 text |
| Seat system prompts from agent files | `systemPrompt` reads an agent path (`internal/assemble/assemble.go:165-170`) | B3: the stock module carries them |
| The docs gate | `gate.command` is required (`validate.go:37-38`) | F: `drafter gate` as the default |
| Fact and provenance checks | cairn's `check:facts`, `check:provenance` | F facts, B3 provenance |
| Skill and hook install | `make install` links them; the hook goes into dotfiles `settings.json` (arch 457-467) | O: the plugin |
| Installing drafter | Needs Go and a checkout; `make install` also links the docs page chain (`Makefile`) | O: release binaries |
| The page hook needs jq | `command -v jq ... \|\| exit 0` (`bin/.local/bin/drafter-page-hook:5`) | O: a `drafter` subcommand |
| drafter's own gate | `chain-test` reads agent definitions from a workstation checkout (`Makefile`) | O: `make check` runs without it |
| The nightly runner | A systemd timer, a registry, and an age-store token (arch 88, 381-389) | B4, whose design picks a portable scheduler; until then a new project drafts with `drafter page` |
| Figure pages | The docs page chain (arch 67, 491-493) | Not removed: a new project's figure pages are set aside until drafter takes figures |

## What a new project builds

The developer rules on the decisions; Claude does the reading and the drafting.

1. **The facts store.** The audit inventories the code's surfaces (commands, settings, public API,
   error messages) as facts, each with an anchored source. Behavior claims are filed per page by
   the new-page procedure's fact step, so every fact has a page that cites it. Facts are Claude's
   work. The developer reviews none of them one by one; mechanical verification checks each source,
   and the fact seat reads each fact a draft places.
2. **The tracks.** `outline.yaml` gains an optional `tracks` list. Each entry has a name, a reader
   profile, a standard (`google` until a second package exists), path globs that assign pages, and
   an optional `register` path. `drafter check` errors when a managed page matches no track or two,
   or when a track names a standard drafter doesn't ship. The change is additive to outline v1,
   which today refuses the key (`schema/outline.schema.json`, `additionalProperties: false`).
   Diátaxis modes and Good Docs anatomies stay drafter's business: a type's `anatomy` names a stock
   anatomy, one Good Docs template, which carries its mode. cairn's four tracks are one project's
   tracks on this base.
3. **The outline.** Claude proposes the doc set from the inventory: each track's surfaces, the tasks
   the code supports, and the concepts a reader needs. The developer approves it as a committed
   file. A generated reference (godoc, Sphinx, `--help`) is listed `managed: false`.

### The standard package

Every track writes to a standard package (Geoff, 2026-10-18). A project with no register configures
none of this: drafter supplies the package for the standard each track names. An API seat sees only
what drafter puts in its prompt and has no web access, so each part names its channel.

| Part | Stock package | Reaches a seat as | Built in | A register adds |
|---|---|---|---|---|
| Description | The standard, its audience, its source | An embedded block | B3 | The project's tracks and scope |
| Rules | The published guide, never copied | The reviewer rubric below, plus model knowledge | B3 | Override rows and tightenings, each citing its source |
| Linter | Vale with the standard's package, pinned by release URL | The gate's output | F | Project styles |
| Corpus | Curated outside pages, each cited, with its license recorded | An embedded block | B3 | The project's exemplars |
| Names | Project terms from the audit, as Vale vocabulary | The gate's output | O (the skill writes it) | Words to use and avoid, with reasons |
| Tells | Patterns every standard rules out, with before-and-after pairs | An embedded block | B3 | House patterns |
| Reviewer rubric | Short paraphrased rules, each citing the guide's URL and section | The editor seat's prompt | B3 | The house checklist |

Vale pins a package only by URL: "To hold a package at a known version, give the release URL in
place of the name" (docs.vale.sh/keys/packages). The corpus embeds a page in full only under a
license that permits it, with attribution; any other page is a short attributed excerpt. A
project's page joins its corpus when a person approved the pull request that merged it.

### The house register, optional

Most projects use the Google or Microsoft guide as it stands (Geoff, 2026-10-18). A register is
for a writer or an organization with a house style. Nothing in drafter requires one: anatomies,
introductions, and every rule the stock prompts rely on live in drafter's base. The kit below
(template, guide, `init --register`) is built in the pass the third fork names.

- **Bringing a guide.** The onboarding skill imports an existing guide into the register template
  and cites the original. A tightening (it forbids only a form the guide permits or is silent on)
  needs no record, so most of a house guide imports as is. An override (it forbids a form the guide
  recommends, or permits one it forbids) becomes a row the owner rules on. A guide in Confluence or
  at a URL can't reach a seat, so a pointer alone is never enough.
- **The row grammar.** An override row is a table row with the base rule and its URL with a
  retrieval date, what the project does instead, the evidence, and the owner's ruling with a date.
  `drafter check` fails a row missing any of these. Whether a rule departs from the guide with no
  row is a judgment, so the editor seat owns it through the rubric, not the check.
- **Who writes a ruling.** The project owner, a role the project sets (CODEOWNERS on the register
  path works). Both skills forbid writing a ruling, and the nightly run's edit allowlist excludes
  the register.
- **Loading.** A register keeps the package's fixed headings. A seat gets a section by an excerpt
  form F adds (`path#heading`). Today the assembler inlines a tracked file whole
  (`internal/assemble/assemble.go:128-140`), and cairn's register is 90,601 bytes.
- **Never in a register:** copies of base rules, a rule for one page (that goes in `constraints`),
  or history (that goes in the commit message).

### Introductions and background

Introductions were a weak spot on the pages drafted so far, so drafter's base carries how they're
handled (Geoff, 2026-10-18).

- **Every page opens with an introduction and ends with the closing its type calls for.** The
  introduction is reasoned fresh for each page. It answers who arrives, what they already know,
  and why they're reading (Google's technical writing course). It also says what the page covers
  and doesn't (Google), and whether the reader is studying or working (Diátaxis). A Good Docs
  template gives the sections and their order and never supplies the introduction's wording.
  cairn's register section "The introduction" generalizes into this base. Until B5, cairn's
  override module is the only reader of cairn's copy.
- **The blueprint plans it.** `framing.introPlan` becomes required, with a warning, not an error,
  on a converted blueprint (today `framing` is optional, `docs/blueprint-format.md:70`). The outline
  entry's `covers` and out-of-scope list win over the blueprint's `introduction` when they differ.
- **Background a reader lacks** is a link to a concept page, or a `sentence` or `reason` item in
  the section that needs it, citing its facts. `framing`'s background part stays the planner's note
  and is never drafted as content. The edit catalog gains that row.

### Existing pages

An existing page gets its first blueprint from the new-page procedure, with the page as a source,
so onboarding doesn't wait for the write-back seat. The procedure alone writes no lock entry, and an
entry with only `accepted` "is a page not drafted yet" (`internal/blueprint/blueprint.go:169-173`),
so the first run would draft it whole. The first fork above decides this.

## The onboarding skill

A Claude Code session running the skill drives onboarding (Geoff, 2026-10-18). The developer
reads the overview first. Its opening fits on one screen, with the model in two sentences: drafter
keeps a plan for each page and a list of checked facts, and drafts the pages whose plans or facts
changed. The developer keeps the plans and facts current and reviews the pull request. It then
gives the requirements (Claude Code, a Claude Console org with prepaid credit, Vale), the install
lines, and the two bills: Claude Code time for onboarding and edits, and API credit for drafting.
Later sections cover what a hand edit does, how to dispute a finding (a lint finding becomes a
vocabulary entry or a rule turned off with a comment; a seat finding becomes a page `constraints`
entry or `review: human`), and how to stop (delete `blueprints/` and `drafter.toml`, uninstall the
plugin, and the pages stay).

The skill follows Anthropic's skill guidance: a phase checklist, one reference file per phase, and
a default for every question.

1. Inventory: subagents, one per surface, return sourced fact rows.
2. Tracks: one plain question ("who reads these docs: developers, end users, or both?"). The default
   is one track on Google, and the word "track" appears only when there are two.
3. Register: offered once; the default is none.
4. Outline: proposed, then edited and approved as a committed file. Before approval the skill shows
   the first run's projected cost (pages times a per-page figure).
5. Blueprints: one per page through new-page, with existing pages handled as the first fork rules.
6. Check and read: `drafter check`, then `drafter read` with its cost shown, capped at two rounds.
   After two, the skill hands the findings to the developer and stops.
7. First page: `drafter page` drafts one page through the stock gate.

Each phase is one commit, and a new session resumes from `git log` and the committed files, never
from chat. The developer's vocabulary is blueprint, fact, outline, and register if they chose one;
every other term stays in the reference pages. The skill sets `disable-model-invocation: true`,
and it stops and reports when `drafter` is missing or rejects a flag, never skipping a check.

## Passes

Each pass's risk class and estimate are set when it's planned. Fixtures are synthetic, since the
drafter repo is public.

### F, foundations

Scope: the stock-prompt mechanism (an embedded default module through `prompts.Load`, which takes
bytes, `internal/prompts/prompts.go:49`; embedded package blocks; the `path#heading` excerpt);
defaults for `gate.command`, `prompts`, and each stock seat's model, effort, and `max_tokens`; the
price table if the second fork says yes; `drafter init`; `drafter gate --page`; fact verification;
`tracks`; stock anatomies and the introduction guidance as reference pages; the `framing.introPlan`
rule; the lock-seeding command if the first fork says yes; and a committed setting with which a
project refuses the stock fallback. `drafter config` and every run report name the module's source
and hash, and the run directory keeps the module's bytes so a resume after an upgrade uses the same
prompts.

Fact verification ports cairn's `check:facts` contract: bullet grammar, a unique id, the tag
vocabulary, and a source that resolves, whether `path`, `path:line[-line]`, or `path#Symbol`, with
a quoted anchor whose tokens fall within ten lines. It proves the source exists and carries the
anchor, not that the claim is true. Pointer forms it doesn't support are skipped and counted. The
`Source:` grammar is published in the format page, which today doesn't document it.

`drafter gate --page` checks only that page's own blueprint, the facts it cites, Vale on the page,
and internal links. It confirms Vale and the pinned package are present before any spend. The
blueprint skill's new-page steps 1 and 4 and `drafter check`'s anatomy fix text stop naming a
register (`new-page.md:7`, `:36`; `internal/blueprint/check.go:221`).

Acceptance, on a fixture repo with no register and one non-cairn track, run with `HOME` set to a
directory holding only the drafter binary and Vale:

| Check | Fails today because |
|---|---|
| `drafter init` then `drafter check` exits 0 | No `init`; an empty facts dir and `pages: []` each exit 2 (`internal/plan/facts.go:124-126`) |
| `drafter config` resolves with only a key source, `workspace_id`, and two caps in the user layer | `gate.command`, `prompts`, and seat settings are required (`validate.go:37-67`) |
| Fact fixtures with a moved line, a missing anchor, and a duplicate id each fail | No check resolves a fact's `Sources`, which `internal/plan/facts.go:45-49` only parses |
| Over cairn's 1,748 facts, verification raises nothing `check:facts` doesn't | New code; cairn's store uses dotted symbol pointers, a basename shorthand, and a `docs/internal/record/` exception (`check-facts.mjs` header) |
| cairn's committed config with no local file refuses to run | It would fall back to stock prompts silently |
| A type naming an unknown anatomy fails; a blueprint with no `introPlan` fails | The check tests only a non-empty name (`check.go:219-221`); `framing` is optional |
| A headless new-page session on the fixture opens no register path | new-page sends the agent to a register (`new-page.md:7`) |

### B3 additions

B3 keeps its scope (the B1 plan's "Build sequence") and adds two pieces: the stock seat prompts,
written against the context B3 defines, and the brief's provenance check in the stock gate. The
chain's prompts can't be generalized as they stand: `registerSectionsFor` throws on any track but
cairn's (`docs-page-chain.js:630-655`), and the draft prompt names cairn's exemplar and scripts.

Acceptance adds two checks. `drafter check-prompts` renders every stock seat against the F fixture,
and no rendered prompt names a path the fixture lacks or a cairn-only name. One fixture page drafts
end to end on stock prompts and the stock gate. Both fail today: no stock module exists, and
`drafter page` takes only a handoff.

### O, onboarding

Scope: the onboarding skill, the overview, the plugin (the blueprint and onboarding skills, the
format page as a real file with a contents list and the shared item reference inside it, and the
hook as a `drafter` subcommand), release binaries plus `go install`, and drafter onboarding itself.
On this workstation the plugin replaces `make install`'s skill link and the `settings.json` hook,
the `claude-tooling` manifest follows, development loads the checkout with `claude --plugin-dir`,
and `make install` keeps the binary with the chain links behind a separate target. A plugin's
`bin/` files "are on the Bash tool's `PATH` while the plugin is enabled"
(code.claude.com/docs/en/plugins-reference); skills are namespaced as `<plugin>:<skill>`.

O's design starts once a whole blueprint read has accepted a cairn blueprint in B3, which B3's
drafting needs anyway. The whole read failed six rounds on cairn's first blueprint (drafter#43).

Acceptance: a fresh Claude Code session in a clean account or container, with no `~/.claude` and
no dotfiles, given only the plugin, a release binary, Vale, the overview's URL, a key, and the
money settings, onboards a synthetic small CLI repo (five or more commands, a README, two
hand-written pages, no docs tooling). The session has no access to the initiatives repo. It passes
when:

1. `init`'s files exist, every fact passes verification, and the outline has a track and was
   approved in the transcript.
2. Each existing page is handled as the first fork rules (with yes, `drafter status` shows it
   unchanged).
3. One new task page's blueprint is accepted within two read rounds, and `drafter page` drafts it
   through the stock gate.
4. The hook's context appears once on an attempted page edit, the format page loads headless, and
   no tool call touches a path outside the repo and `HOME`.
5. The gate records the installs, settings, and decisions the path took, and fails on any setting
   outside F's list.

It fails today: no plugin, skill, overview, or `init` exists. drafter itself is then onboarded as
the real-world case.

## Changes to the architecture spec

This replaces "everything else stands". Each row names arch's lines and the new reading.

| Arch | Now |
|---|---|
| 85: the standard is "named in project config" | Each track names it in `outline.yaml` |
| 86: the house register is a standing component with Geoff's ruling | Optional; rulings are the project owner's |
| 88: the nightly routine is a systemd timer and registry | Geoff's stays; B4's design picks a portable scheduler for other projects |
| 98, 108: a blueprint carries register sections | Sections load by fixed heading from the register a track names; `register.<track>` stays for cairn's module until B5 |
| 179-184, 519-520: a page with no plan is bootstrapped by the write-back seat | The new-page procedure during onboarding, lock handled as the first fork rules |
| 252-254: each type names a register anatomy | It names a stock anatomy, or a register entry when the project keeps one |
| 325, 332-333, 494-495: redraft "in the register's voice"; `cairn-register-editor` is the editor seat's prompt | The track's standard plus its register, if any; the stock editor grades the reviewer rubric, and cairn's agent serves only cairn's module |
| 339-344, 429-437, call 8: Geoff promotes style notes; the report leads with Geoff; a desktop notification | The project owner. Style candidates stay in the report as information. The pull request body is the stock channel; the notification is a local option |
| 548-552: merging starts off until the pilot criteria hold | Per project: `nightly.merge` defaults off, and the owner turns it on |
| 457-467, calls 21-22: `make install` links the skill; the hook goes into `settings.json` | The plugin, in O |
| 469-472, 499-501: the stock module and the plugin wait for sub-project 5 | F and B3 build the module; O ships the plugin |
| B1 plan "Build sequence", B5 | F and O join the order; B5 also splits cairn's register into base and overlay |

## Calls made in this design

1. Fact verification is cairn's `check:facts` contract, generalized. An audit fact lands
   `[verified]` with an anchored source, as cairn's agents file facts today. Arch's pending tag
   (319-323) is for a fact taken from a human edit, which no agent has read against the code.
2. The audit inventories surfaces, and behavior facts are filed per page. This reads Geoff's "a
   facts store by code audit" as a staged audit, so one session has a bounded job and no fact goes
   uncited. It is the most contestable call here.
3. Tracks live in `outline.yaml` with path globs, additively to v1. A type's anatomy carries its
   Diátaxis mode, so there is no `mode` field.
4. The prompt mechanism lands in F and the prompt text in B3, where the handoff is defined.
5. The rules part reaches a seat as a paraphrased, cited rubric, which keeps "never copied" and
   gives the editor a fixed list (B2's reads gave one defect different severities).
6. Bringing a house guide means importing it into the template; a pointer can't reach a seat.
7. The register check is structural, and the departure judgment belongs to the editor seat.
8. A page joins the corpus when a person approved its merge, so the corpus doesn't drift toward
   the mean.
9. `workspace_id` and both caps stay required (pipeline spec, "Caps": drafter "never spends against
   a default the user didn't choose"), and the skill asks for them.
10. O's bar is a drafted page in a clean environment, after B3 has made a whole read accept.
11. The plugin replaces `make install`'s skill and hook on this workstation.
