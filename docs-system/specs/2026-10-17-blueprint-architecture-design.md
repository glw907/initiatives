# The blueprint architecture design

Status: designed with Geoff in chat, 2026-10-17. Approved by Geoff, 2026-10-17, with two review
fixes folded (the coordinated-change case in detection, and clearing `origin: human` ahead of the
lock). This
spec reshapes sub-projects 2 to 4 of the docs system and changes three rulings of the drafter
pipeline design (`2026-10-12-drafter-pipeline-design.md`), listed under "Changes to earlier
rulings". Everything in that spec that this one doesn't change still stands.

Erratum, 2026-10-18: the onboarding design (`2026-10-18-drafter-onboarding-design.md`), approved by
Geoff the same day, amends this spec. Its "Changes to the architecture spec" table names the lines
it supersedes (85 to 552) and calls 8, 21, and 22; read it before relying on those lines.

## Brief

Approving this makes a page's blueprint the only place an agent changes documentation. Agents edit
blueprints as they work. Overnight, drafter turns the changes into finished pages and merges them,
and you read a report in the morning.

Today a page is planned, drafted, and reviewed in one long run that someone has to start. Between
runs, docs drift, and the monthly drift routine catches only a sample. drafter's back half is
built, but it has never run on a real page. Both real pages stopped at the chain's plan read.

### What changes

- The page plan becomes the blueprint: a durable YAML file per page holding everything the page
  must say. Each blueprint lives under `blueprints/`, at a path that mirrors its page.
- Live agents fix blueprints directly and never edit page prose. `docs-fix` issues are dropped.
- People may still edit pages. The nightly run writes the meaning of each human edit back into
  the blueprint and redrafts that passage in the house voice.
- A nightly run redrafts each changed section, re-reads the whole page for coherence, merges what
  passes, and sends a report.
- Style-only human edits collect into a list of candidate register rules for you to rule on.
- The format changes so small edits stay local: no fact restated in prose, no section named by its
  heading, and an item kind for each common edit.
- A new blueprint skill teaches agents the edits, and a hook reminds an agent that's about to edit
  a page's prose to change the blueprint instead.
- cairn's waiting stage 2b drafting moves to this path. Its 11 plans become the first blueprints,
  and the blueprint pilot replaces the old drafter pilot.

## Why

Geoff's goal is high-quality documentation that is exceptionally easy for agents to maintain. His
hypothesis has three parts. A structured blueprint is much easier for an agent to change correctly
than prose. Keeping docs current becomes a side effect of ordinary work. Moving all prose work onto
the API credits uses money that otherwise expires each month (the pipeline spec's "Why" gives the
figures).

Agents should be able to tweak blueprints as they work (Geoff, 2026-10-17). An agent that changes
a feature updates the facts and the blueprint in the same session. An agent that notices a weak
example, a missing failure case, or a wrong claim while reading the docs fixes the blueprint on
the spot. Either way, the prose follows overnight.

### Goals

- Every published page has exactly one blueprint, and the blueprint is the source of truth for
  what the page says.
- An agent can make a typical small change to a blueprint correctly on its first attempt, checked
  offline in seconds.
  Erratum (Geoff, 2026-10-19): this goal splits into `drafter check` green on the first try and the
  read accepting the change in the same session within three reads; see
  `specs/2026-10-19-drafter-edit-quality-design.md`.
- A changed blueprint becomes a reviewed, merged page by the next morning, with no human step
  unless something failed.
- A person can edit a page directly, and their meaning survives in the house voice.
- The nightly run spends API credits, never interactive Claude Code time.

### Non-goals

- Detecting code changes that no agent recorded in a blueprint. The pass rule covers that, and the
  monthly drift routine stays as the backstop.
- Keeping a human's exact wording. Geoff, 2026-10-17: "meaning is enough; rewrite it in the
  register's voice."
- Figure pages and figure-bearing sections. They stay on the chain, as the pipeline spec rules.
- Changing the register without Geoff's ruling. Style candidates are proposals only.

### Anti-goals

The design has failed, even if it technically works, when any of these happens:

- A bad page reaches `main` because the review gate was weaker than a person's read.
- A person's edit disappears, or its point is buried in a subordinate clause after a redraft.
- Agents find blueprints harder to change than prose, and start editing pages again.
- Credits run out mid-cycle, so pages that changed late in the cycle wait for the next one.

## The components

| Component | Job | Lives in |
|---|---|---|
| drafter | Validates blueprints, drafts and redrafts pages and sections, reviews them, writes human edits back, runs the nightly cycle, and reports | `glw907/drafter`, general to any project |
| Blueprint | One page's durable source of truth | `blueprints/` in each project |
| Documentation standard | The base style guide a track follows, such as the Google developer documentation style guide or the Microsoft Writing Style Guide | Named in project config, carried by the prompts module, the Vale package, and the exemplars |
| House register | The project's recorded departures from the standard, each with its provenance and Geoff's ruling | A file in the project (cairn: `docs/internal/docs-register.md`) |
| Skills | Teach a live agent the procedures: change a blueprint, write a new one, check it | Shipped with drafter; placement follows `claude-infra` |
| Nightly routine | Runs `drafter nightly` over each participating repo | A systemd user timer and a repo registry (sub-project 2) |

The skills hold procedures only. The blueprint format's rules live in drafter's schema and its
format reference, and the voice rules live in the standard and the register. A skill points at
them, so a rule never has two homes.

## Blueprints

A blueprint is the page plan made durable. It takes in three things that are separate today: the
plan (`<page>.plan.yaml`), the framing record (`<page>.framing.md`), and the page inputs the chain's
first step produces (the job, page type, exemplar sources, register sections, and claim
inventory). drafter builds a page's handoff from its blueprint, so the handoff becomes an internal
structure that no planner writes.

The format starts from plan format v1's fields, reshaped as "Fitting the format to its jobs"
describes, and adds what a durable file needs:

- A required, stable `id` on every section. Headings change; section-scoped work keys on the id.
- A `framing` block for the introduction's readers and background reasoning, which the framing
  record holds today.
- The page's job, type, exemplar sources, and register sections, which the page inputs hold today.
- The `origin` mark and `styleNotes`, described under "Human edits".
- An optional `review: human`, for a page that must never merge unread. cairn's front door is the
  case: its pages are drafted one section per read with a reader between sections, never end to
  end in an autonomous run.

The claim inventory is a one-time planning record of what an old page claimed. In a durable file,
the items and dispositions carry the same information, so it folds into them.

It is a new format with its own version, `version: 1`, and its own schema,
`schema/blueprint.schema.json`. `check-plan` becomes `drafter check`. A converter turns a v1 plan
and its framing record into a blueprint.

### Layout

Every blueprint lives under one root, `blueprints/`, at the repository root, beside `docs/`. A
page's blueprint sits at the page's path relative to the repository root, under that root, with
`.md` replaced by `.blueprint.yaml`. The project-level files sit at the top of the root.

```
README.md
docs/
  extend/rotate-the-github-app-key.md
blueprints/
  outline.yaml                                       the doc set's pages, order, jobs, and types
  facts/                                             the shared facts store
    extend.md
  drafted.lock                                       what drafter last wrote for each page
  README.blueprint.yaml                              blueprint for README.md
  docs/extend/rotate-the-github-app-key.blueprint.yaml
  docs/extend/rotate-the-github-app-key.brief.json   drafter's sentence-to-fact brief
```

The layout follows the convention of keeping test files in a tree that mirrors the source tree.
It has four properties the design relies on:

- One path rule takes any page to its blueprint and back, with no setting and no search.
- The published docs tree stays free of YAML, so no site build has to learn to skip it.
- The nightly run asks two questions, and each is one diff: `git diff -- blueprints/` for
  blueprint changes and `git diff -- <pages>` for human edits.
- A page outside `docs/`, such as the root README, still has a blueprint, at the same depth as
  the page.

The `.blueprint.yaml` suffix makes each blueprint identify itself, so an editor can attach the
schema by glob and a tool can tell a blueprint from `outline.yaml`.

Facts stay a shared store. Many pages cite one fact, and the consistency read depends on there
being one copy. A fact bullet keeps its v1 format.

`drafted.lock` is written only by drafter, in the spirit of a package lockfile. For each page it
records the commit drafter last wrote the page in, the hashes of the page and its blueprint at that
commit, one hash per section, and the blueprint hash the blueprint read last accepted. It lives
apart from the blueprints so that a redraft never changes a blueprint. A blueprint that changed
on every redraft would set off a new redraft every night.

The brief stays a drafter output, kept beside its blueprint because the project's gate reads it
(cairn's `check:provenance`).

The defaults are the convention, and drafter settings may move them for a project mid-migration.
`drafter check` warns when a project departs from the convention.

### Managed pages

`outline.yaml` lists every page in the doc set. A page marked `managed: false` has no blueprint,
and drafter never drafts it. That covers a historical record whose text must not change, such as
cairn's `docs/extend/migration-notes.md` and `CHANGELOG.md`. Every other page is managed.

### Bootstrapping

An existing page gets its first blueprint in one of two ways.

1. A page with a v1 plan is converted. The converter writes the blueprint from the plan and the
   framing record, and seeds the page's lock entry with the page as it stands. Conversion costs
   nothing. A converted page first gets redrafted when its blueprint next changes.
2. A page with no plan, or only a markdown plan, is bootstrapped by the write-back seat, which
   reads the whole page into a new blueprint. Bootstrapping spends credits. It runs one arm at a
   time, inside the nightly cap, and the report shows how far it has reached.

The rule that every managed page has a blueprint is a warning until the project sets
`blueprints.required = true`. A project turns it on once bootstrapping is complete, and then CI
refuses a managed page with no blueprint.

### `drafter check`

`drafter check` validates every blueprint in the project, or the ones it is given, offline. It runs
the plan checks (decode, ids, reader-state, recovery, links, facts) and adds these:

- Every managed page has exactly one blueprint, and every blueprint has a page or is new.
- Every section id is unique within its blueprint.
- `drafted.lock` parses, and every page it names exists.

It must run in a few seconds over a whole project, since agents run it in their loop. Each project
adds it to its own gate, so CI refuses a broken blueprint.

`drafter status` prints what the next nightly run would do, and spends nothing. It lists blueprint
changes, human edits, conflicts, and orphans.

`drafter refs <fact-id>` lists every blueprint item, on every page, that places or cites a fact.
An agent that corrects a fact runs it to find each placement whose `use` it must re-read.

### Fitting the format to its jobs

Geoff asked that the blueprint format suit its tasks well (2026-10-17). Plan format v1 was designed
for one job: a planner writing a whole plan in one sitting, for one drafting run. A blueprint
serves seven jobs, and each job needs something different from the format.

| Job | Done by | Needs from the format |
|---|---|---|
| A small edit | A live agent, often Sonnet, mid-task | One obvious place for each change, no fact restated in prose, and a fast check that names the fix |
| A new page | An agent using the blueprint skill | The page type's anatomy and a complete structure to fill in |
| Drafting | drafter's draft seat | What to say, in what order, and why |
| The blueprint read | drafter's blueprint read seat | Explicit steps, state, and failures |
| Write-back | drafter's write-back seat | Stable ids, and a schema an edit can target |
| Change detection | drafter | Sections whose content stands alone |
| Review | Geoff, in a pull request diff | Diffs that read as a change of meaning |

cairn's real plan for `rotate-the-github-app-key` shows where v1 falls short of those needs. It runs
to 857 lines and 100 items: 30 fact placements, 24 links, 14 steps, 12 failures, 9 sentences,
7 handoffs, 3 code blocks, and 1 reason. Its size is acceptable. Its redundancy and its
cross-references are not. The blueprint format makes six changes.

1. A placement's `use` names scope only. The rotate plan's `use` fields restate each fact's
   content ("the site's Worker reads the key as the secret `GITHUB_APP_PRIVATE_KEY_B64`"), so a
   corrected fact leaves a stale paraphrase behind in every page that places it. A blueprint's
   `use` says which part of the fact the placement carries, starting with "Only" or "Omit", and
   drafter puts the fact's own text in front of the drafter. The blueprint read reports a `use`
   that restates its fact.
2. Prose fields name other sections by id, never by heading. The rotate plan's prose sends
   content elsewhere by heading ("the status codes wait for Verify the new key"). A heading rename
   breaks those references without any error, and they tie one section's change to another's
   text. A blueprint refers to another section by id, in a syntax `drafter check` resolves.
3. Each section carries its own reason. The rotate plan's `orderReason` is one paragraph that
   explains every section's place, so changing one section means editing a page-level paragraph.
   A blueprint gives each section a short `why`, and keeps a page-level reason only for the order
   as a whole.
4. Durable fields describe the page as it is now. The rotate plan's `orderReason` narrates the
   planning session's moves against an older outline ("merges the outline's encode and push
   covers", "a departure from the anatomy's verification-last slot"). That history goes stale
   the day the outline changes. It belongs in the commit message. `friction` is a run's report,
   so it moves to the friction log. `constraints` holds only rules specific to the page, never a
   copy of a register rule.
5. Every common edit maps to one item kind. "Add a better example" is Geoff's own named case, and
   v1 has a kind for a code block but none for a worked example in prose. The blueprint format adds
   an `example` kind and checks the edit catalog below against the kinds.
6. The page type comes from a declared list. v1 takes `type` as free text. In a blueprint, the
   type must be one that `outline.yaml` declares, and each declared type names the register
   anatomy it follows. A new page then starts from its type's anatomy.

The format reference in drafter's docs is the format's one home. The schema, the edit catalog,
and the checks follow it, and the blueprint skill points at it without copying its rules.

### The edit catalog

The catalog lists the edits a live agent makes most often and the blueprint change each one
takes. The blueprint skill teaches it, the format is tested against it, and the pilot's
format test draws its tweaks from it.

| The agent wants to | It changes |
|---|---|
| Record changed behavior | The fact bullet, then each placement `drafter refs` lists whose `use` no longer fits |
| Add an example | An `example` item, or a `code` item for a code block, in the section |
| Correct a claim | The fact behind it, or the `sentence` item when the claim is an inference |
| Add a failure case | A `failure` item with its handler, and `canFail` on the step that causes it |
| Add a caveat | A `sentence` item with `mode: claim`, citing the facts it rests on |
| Add a link | A `link` item in the section that needs it |
| Remove a claim | The item goes, or a `dispositions` entry with `cut` and a reason |
| Add or move a section | The section list, which redrafts the whole page |
| Start a new page | An `outline.yaml` entry and a whole blueprint, from the blueprint skill's new-page procedure |
| Follow a rename the gate demands | The fact bullets, the blueprint, and the page edit the gate names (the one prose exception) |

## How a change starts

An agent always changes a blueprint first (Geoff, 2026-10-17). There are three cases.

1. A change to documented behavior. The agent files or updates the fact, updates the blueprint
   items that cite it, runs `drafter check`, and commits all three with the code. cairn's pass rule,
   "a change is not done until its docs match", becomes "until its blueprints match".
2. A deficiency noticed while reading. The agent fixes the blueprint: it adds an example item,
   corrects a claim, adds a failure item and its handler, or adds a link.
3. A new page. The agent adds the page to `outline.yaml` and writes its blueprint with the
   planning skill. The nightly run drafts the page.

An agent never edits page prose, with one exception (Geoff, 2026-10-17). A project's CI gate can
fail a code change whose pages still name something the change renamed or removed. cairn's
`check:symbols`, `check:reference`, and link checks do. In that pull request, the agent may make
only the page edits the gate demands, such as a renamed symbol or a moved link or anchor. It also
changes the blueprint to match. The page edit and the blueprint change reach `main` in one pull
request's merge, so the nightly run reads them as one coordinated change, never as a conflict (see
"The nightly run"). It writes back the page edits as human edits and restates the section in the
house voice. Any other prose edit by an agent breaks the rule, and the nightly run also treats it
as a human edit.

A person may edit a blueprint or a page (Geoff, 2026-10-17). A blueprint edit takes the same path
as an agent's.

## Human edits

A page whose hash differs from `drafted.lock` has been edited by hand. The nightly run diffs it
against the version drafter last committed (`git show <lock commit>:<page>`), maps each hunk to a
section by its heading, and sends the hunks to a write-back seat. The seat sorts each edit into one
of three kinds.

| Kind | Example | What the write-back does |
|---|---|---|
| Meaning | A corrected command, a new caveat, a better example | Changes the blueprint's items to carry the new meaning, each with `origin: human` |
| Style | A clunky sentence rewritten with the same content (Geoff: a human "might be fixing awkward writing") | Adds a `styleNotes` entry to the section with the old and new wording |
| Both | A rewrite that also adds a point | Does both |

When the seat can't tell meaning from style, it records the edit as both. Losing a meaning costs
more than an extra check.

A meaning edit that states a new fact is confirmed against the code before it drafts (Geoff,
2026-10-17). The write-back files the fact with a pending tag that names the edit's commit. That
night's fact read checks it against the code. A confirmed fact is retagged `[verified]` with its
source, and the page drafts. A fact the read can't confirm sets the page aside. The report then
quotes the edit and says what the read couldn't find.

The edited section is then redrafted in the register's voice that same night. Geoff, 2026-10-17,
ruled that meaning is enough, but the thing the person edited needs special attention. The review
gives it that in two ways.

- Every review seat reads the human-origin items as a checklist. The redraft must carry each
  one's point with real weight. A point reduced to a clause, a parenthetical, or a footnote
  fails, and so does a missing one. The finding is blocking.
- A style note guards against regression. drafter checks mechanically that the old wording doesn't
  come back, and the register editor reads each note as a known failure of the house voice.

An `origin: human` mark clears when a redraft carrying it is accepted, so blueprints don't fill
with old marks. The clearing goes into the page's own commit, before its lock entry records the
blueprint hash. The lock then matches the cleared blueprint, and clearing a mark never sets off
the next night's redraft. A night whose pull request doesn't merge leaves the marks on `main`
untouched. A style note stays until Geoff promotes it into the register or rejects
it, so it keeps guarding the section in the meantime.

The report collects every new style note as a candidate register rule, grouped by the pattern it
shows. Over time the notes show where the register or the drafting prompt keeps failing. Only
Geoff promotes a candidate, since the register records his rulings.

## The nightly run

`drafter nightly` runs for each repo in the registry. It works on a branch of a fresh worktree
from the head of `main`, takes the existing run and worktree locks, and stops before any spend if
the cycle ceiling or the nightly cap can't cover its first stage.

1. Detect. Compare each page and blueprint with `drafted.lock`, and sort every page into one of
   these cases:
   - Blueprint changed.
   - Page edited by hand.
   - Both changed in one first-parent commit on `main`, which is one pull request's merge (a
     coordinated change). The page's hunks go to the write-back seat against the blueprint as
     committed, and the page then redrafts like a changed blueprint. The prose exception always
     lands this way, and so does a person who edits a page and its blueprint together.
   - Both changed in different first-parent commits (a conflict).
   - New blueprint.
   - Page with no blueprint, or blueprint with no page (an orphan).
   - Unchanged.

   A change to a fact bullet counts as a change to every section that cites it. A change to a
   page's entry in `outline.yaml` counts as a change to the page.
2. Set aside. Leave each conflict, orphan, figure-bearing section, and `review: human` page
   untouched, and list it in the report.
3. Write back. Run the write-back seat on every human edit, apply its blueprint changes, and run
   `drafter check`. A blueprint that fails the check sets the page aside.
4. Read the blueprint. Run the blueprint read on every changed blueprint, scoped to its changed
   sections, along with the consistency read. The blueprint read takes over from the chain's plan
   read: the reader-state, recovery, and completeness reads that stopped both real pilot pages. A
   finding sets the page aside with the finding in the report. An accepted blueprint hash goes into
   the lock, so an unchanged blueprint is never read twice.
5. Draft. Redraft each changed section, or the whole page when its structure changed (see "Scope
   of a redraft"). Each page runs the pipeline spec's stages, with every seat narrowed to the
   changed sections. A section redraft then gets one whole-page coherence read.
6. Commit. Commit each accepted page with its brief, its blueprint write-backs, and its lock
   entry, one commit per page. An escalated page is restored, and its record keeps the draft.
7. Merge. Rebase on `main`, and run the project gate over the whole tree. Then open one pull
   request for the night and merge it when CI is green (Geoff, 2026-10-17: "merge itself and send
   a report"). A page whose blueprint or text changed on `main` during the run drops out of the
   merge as a conflict. A red CI leaves the pull request open and puts it at the top of the
   report. The run pushes and merges with a fine-grained GitHub token. The token is limited to the
   registry's repos, with write access to contents and pull requests only. It is kept in the age
   store and used by nothing but the timer (Geoff, 2026-10-17). cairn's `main` has no branch
   protection today, and its repo has auto-merge off, so the run merges through the API once CI
   reports green.
8. Report. See "The morning report".

### Scope of a redraft

A section redraft is the default (Geoff, 2026-10-17). The draft seat gets the whole current page
and the changed sections' blueprint, and rewrites only those sections. drafter refuses an answer
that changes text outside them. The brief updates for the sentences that changed.

The whole page is redrafted when the page's structure changes: a section added, removed, or moved,
a level changed, or a change to the argument, the introduction, the framing, or the page's outline
entry. A new page is always drafted whole. Geoff ruled "whole page when the outline changes"; this
spec reads "outline" as the page's structure and its entry in the doc set's outline.

After a section redraft, the whole page gets one coherence read with the new section marked
(Geoff, 2026-10-17). The read checks transitions, repetition, and the argument's flow across the
page. It may propose edits anywhere on the page. One edit-contract redraft applies them, followed
by the gate and coverage checks. A second coherence finding escalates the page.

A register change triggers no redraft by itself. The new rules apply the next time each page is
redrafted for its own reasons. A manual `drafter nightly --all <path>` redrafts a set of pages on
purpose, inside the same caps.

### Budget

The run spends inside the pipeline spec's caps and adds a nightly cap (`nightly_cap`, user and
local layers only, since it is money), so one heavy night can't use up the cycle. Geoff's cycle
ceiling is $160 a month. A spike page cost $3 to $4.50 drafted whole, which covers roughly 35 to
50 whole pages a cycle. Section redrafts cost less, and the pilot measures by how much.

When a night's budget can't cover every page, the run spends it in this order:

1. Write-backs, which are cheap and preserve a person's intent.
2. Pages whose blueprint changed earliest.
3. New pages.

Work left over carries to the next night and shows in the report.

### The morning report

The report leads with what needs Geoff and then lists what happened. Its first section, needs you,
lists conflicts, escalations with their stop rule and finding, a red CI, and a budget stop. The
remaining sections cover the pages merged (each with its pull request link and the sections that
changed), the human edits written back, the new style-note candidates, the work carried over, and
the night's spend.

The report is the night's pull request body, so it sits beside the diff it describes. A night
that needs Geoff also sends a desktop notification at normal urgency, following the calm desktop
rule. A night with nothing to do writes a one-line report to the state directory and sends no
notification.

## Claude infrastructure

Geoff asked which skills to build and how the Claude infrastructure should change (2026-10-17).
Each piece below follows the `claude-infra` skill: the strongest home that fits, one home per
rule, a manifest entry, and `claude-tooling-sync verify`. Anthropic's features overview
(<https://code.claude.com/docs/en/features-overview>) sets the order of homes: "If a rule must
hold every time, make it a hook rather than a prompt instruction," and "Put it in a skill if it's
reference material Claude needs sometimes".

### New

The blueprint skill is the main new piece. It teaches a live agent when to change a blueprint
(a behavior change, a deficiency noticed while reading, a new page), the edit catalog, `drafter
check` and `drafter refs`, the one prose exception, and that page prose is otherwise off limits.
A reference file inside it carries the new-page procedure. That procedure replaces the chain's
front half (page inputs, plan, and framing), so the guidance in the chain's `pageInputsPrompt`,
`planPrompt`, and `framingPrompt` moves into it instead of being lost. The skill is user scope,
since every docs repo shares it, and it lives in the drafter repo beside the docs page chain.
drafter's `make install` links it into `~/.claude/skills/`, and `claude-tooling.md`'s layout table
gains the row. A skill on disk reaches the implementer subagents, which is where most behavior
changes happen. The planned `docs-fix` skill is dropped.

A user-scope `PreToolUse` hook on `Edit` and `Write` reminds Claude when it is about to edit a
managed page. It fires only in a repo with a `blueprints/` root and only for a page that has a
blueprint, and it names the blueprint and the prose exception. It advises and never blocks. A
block would also stop the gate-demanded edits the exception allows, and a stray prose edit is
safe anyway, since the nightly run restates it from the blueprint. The hook lands through the
`update-config` skill into the tracked `settings.json`.

drafter's three new seats (write-back, blueprint read, and coherence read) need system prompts.
They are API prompts, not Claude Code agents, so they don't go under `~/.claude/agents/`. Like the
existing seats, they live in the project's prompts module and its seat settings, and drafter's
stock module carries generic versions (sub-project 5).

The nightly run's GitHub token gets an entry in `secrets/registry.md` and goes into the age store
through `secret-set.sh`. The drafter API key's missing registry entry (from pass 5's "Found, not
done" list) is added at the same time.

### Changed

| Piece | Change |
|---|---|
| `cairn-pass` and `site-pass` close checklists | "Docs match" becomes "blueprints match": `drafter check` is green, and every changed behavior has its fact and blueprint update in the pass |
| `cairn-implementer` and `site-implementer` | One line: a documented behavior change goes to the fact and the blueprint through the blueprint skill, never to page prose |
| cairn-cms `CLAUDE.md` and `docs/internal/docs-maintenance.md` | The pass rule becomes the blueprint rule, and the maintenance layers gain the nightly run |
| The monthly drift routine | Its confirmed findings become fact and blueprint fixes in a pull request, in place of a report |
| `approval-packet` | While merging is off, each night's pull request is a hand-over and goes out as a packet. Once merging is on, a night sends a packet only when it needs Geoff |
| `writing-voice` router | A row for blueprint prose fields: the agent-facing register, which describes content and intent and isn't graded as published prose |

### Retired

The docs page chain loses its front half to the blueprint skill and its back half to drafter. It
stays only for figure pages, with `cairn-docs-outline`, until drafter takes on figures, and then
it retires. `cairn-docs-drafter` stays for those figure pages, and its drafting guidance moves into
the draft seat's prompt. `register-check` and `cairn-register-editor` don't change. The register
editor's definition already serves as the editor seat's system prompt.

### Later

A procedure for turning style candidates into register amendments waits until real candidates
exist. Its shape depends on what the first ones look like. Packaging the blueprint skill and
drafter as a public plugin stays in sub-project 5.

## Changes to earlier rulings

| Earlier | Now | Source |
|---|---|---|
| drafter never commits; the planning session commits what it accepts | The nightly run commits and merges | Geoff, 2026-10-17 |
| Doc problems become `docs-fix` GitHub issues (sub-project 2) | Agents fix the blueprint directly; there is no issue queue | Geoff, 2026-10-17 |
| The page plan, written fresh for each drafting run | The blueprint: durable, edited in small steps, and the source of truth | Geoff, 2026-10-17 |
| Rework pages stay on the chain | Redrafting existing pages, by section or whole, is drafter's core job | Follows from the nightly run |
| cairn's pass rule: docs match the change | Blueprints match the change | Follows from the blueprint rule |
| The drafter pilot: five pages through `drafter page` from the chain's handoff | The blueprint pilot below, starting from stage 2b's 11 plans | Geoff, 2026-10-17 |

The sub-projects change with them:

- Sub-project 2 becomes the nightly run: detection, write-back, section redraft, the coherence
  read, the merge, the report, the timer, and the registry. It drops issue capture.
- Sub-project 3's rollout ships the blueprint skill in place of the `docs-fix` skill.
- Sub-project 4's bootstrapping becomes the write-back seat run on a page that has no blueprint.
  The same seat that reads a human edit can read a whole existing page.

The monthly drift routine stays. Its confirmed findings become blueprint edits.

## The pilot

cairn's stage 2b part 2 is the pilot (Geoff, 2026-10-17). Its 11 finished plans convert into
cairn's first blueprints, and their pages draft through the blueprint path. The cairn release
waits on the docs, so the build is on the release's critical path. The chain's front half gets no
further fixes. Its plan read's job moves to the blueprint read.

Three risks could disprove the hypothesis. The pilot must retire each before the nightly run
merges unattended.

The blueprint read may be too hard to pass. Both real pages escalated at the chain's plan read,
on gaps a reader would hit: a missing deploy step, failures with no step where they occur, and
recovery routes named before diagnosis (drafter#37, drafter#38). In this design that read runs on
every changed blueprint. The pilot's first milestone is one real cairn blueprint, converted from
`rotate-the-github-app-key`'s plan, passing `drafter check` and the blueprint read and reaching
`accepted`, run by hand.

The format may be too heavy for small edits. That plan runs to about 850 lines, and it was
designed to be written in one sitting. The pilot gives a fresh agent a set of typical tweaks (add
an example, correct a fact, add a failure and its handler, add a section) with only the skill as
help. The test agent runs on Sonnet at medium effort, which is how most live agents run. The bar
is four of five tweaks passing `drafter check` and the blueprint read on the first try. A lower
rate sends the format back for an ergonomics pass before rollout.

The review gate may be too weak for unread merges. The nightly run starts with merging switched
off (`nightly.merge = false`). It opens the pull request and reports, and Geoff reads the pages.
Merging turns on once the pipeline spec's pilot criteria hold for nightly-run pages: at least three
accepted pages that Geoff accepts after ordinary fixes, an empty `faults` list on every escalation,
and spend inside the caps.

## Calls made in this design

Geoff should check these calls while reading. Each is a method or architecture choice, not one
he made.

1. The blueprint absorbs the plan, the framing record, and the page inputs. The handoff becomes
   internal.
2. The layout mirrors repository-root paths (`blueprints/docs/extend/x.blueprint.yaml`), so the
   root README has a blueprint too. The chat sketch dropped the `docs/` level, and the self-naming
   `.blueprint.yaml` suffix is new here.
3. Facts stay a shared store under `blueprints/facts/`, and `drafted.lock` stays apart from the
   blueprints.
4. Every section gets a stable `id`.
5. A fact change or an outline-entry change counts as a blueprint change. A register change
   doesn't.
6. A page edited by hand and changed in its blueprint since the last run is a conflict for the
   whole page, never resolved by guessing, unless both changes arrived in one first-parent commit
   on `main`. That case is one coordinated change, which keeps the prose exception out of the
   conflict list. Section-level conflict handling can come later.
7. An uncertain write-back records the edit as both meaning and style.
8. `origin: human` clears in the accepted page's commit, ahead of its lock entry. A style note
   stays until Geoff rules on it.
9. The blueprint read runs nightly on the API, scoped to changed sections, and its acceptance is
   cached in the lock.
10. The nightly run uses one pull request, auto-merged on green CI, with per-page commits. Merging
    starts switched off until the pilot criteria hold.
11. A `review: human` blueprint flag keeps cairn's front door out of autonomous merges.
12. A nightly cap, with the spending order above.
13. cairn moves to the convention: `docs/internal/briefs/` and `docs/internal/facts/` move under
    `blueprints/`, as a cairn pass of its own. drafter settings carry the old paths until then.
14. The blueprint rule warns until a project sets `blueprints.required = true`.
15. Conversion seeds the lock with each page as it stands, at no cost. A converted page gets
    redrafted only when its blueprint changes.
16. Historical pages are `managed: false` in the outline. cairn's arm READMEs and front door are
    managed, with `review: human`.
17. The report is the night's pull request body, with a notification only when a night needs
    Geoff.
18. The format test's bar is four of five tweaks on the first try, by a Sonnet agent at medium
    effort.
19. The six format changes under "Fitting the format to its jobs", including the new `example`
    kind and per-section `why`.
20. `drafter refs` as a new command.
21. One blueprint skill with a new-page reference file, not two skills. It lives in the drafter
    repo and is installed by `make install`.
22. The managed-page hook advises and never blocks.
23. The new seats' prompts live with the project's prompts module, not under `~/.claude/agents/`.

## Left to the builder

- The blueprint schema's exact field names, and how each v1 plan field and handoff input maps
  onto it.
- `drafted.lock`'s format.
- The write-back seat's prompt and answer schema, and how a blueprint edit is expressed and
  applied (the edit contract, extended to YAML, is the obvious start).
- How a hunk maps to a section when a person renames or moves a heading.
- The mechanical test for returning old wording: exact match, or a similarity measure.
- The coherence read's seat, prompt, and edit limit within the one redraft.
- How the nightly run splits a red CI, and whether it retries without the failing page.
- The converter from v1 plans and framing records, and whether `check-plan` stays as an alias
  for a release.
- The report's exact layout within the pull request body.
- The pending fact tag's exact form, and how `check:facts` and `check:provenance` treat a
  pending fact for the one night it exists.
- What stays of `drafter page`'s handoff file and `--workflow-run` input, and when the chain's
  `backHalf` hook goes, now that blueprints feed drafter directly.
- The order of passes, the risk class of each, and the order the 11 stage 2b pages run in. Code
  that holds the GitHub token or decides a merge is a candidate for `auth-data`, which only Geoff
  can rule.

## Open items

- Which workstation runs the timer. The laptop sleeps, so the desktop, `pavilion`, is the default
  pick.
