# Review: drafter onboarding design, human-ergonomics lens

Target: `docs-system/specs/2026-10-18-drafter-onboarding-design.md` (branch
`docs-system-onboarding-design`, glw907/initiatives#18), read with the spec it amends,
`2026-10-17-blueprint-architecture-design.md`, and what a developer meets in drafter today
(`README.md`, `docs/setup.md`, `docs/configuration.md`, `docs/blueprint-format.md`, and the
blueprint skill under `claude/.claude/skills/blueprint/`). The one live project, cairn-cms
(`drafter.toml`, `blueprints/`, `docs/internal/docs-register.md`), served as the reference for
what a configured project looks like.

The goal under test (Geoff, 2026-10-18): "setting up the drafter system needs to be highly
ergonomic for a new developer on a new project." The house register is optional, and most
projects will use Microsoft or Google as they stand.

Line references without a path are to the onboarding spec. `arch:` is the architecture spec.

## Verdict

The design moves the right pieces off the workstation (stock prompts, `drafter init`, a stock
gate, a plugin), and making the register optional is the single largest ergonomic gain. It does
not yet meet its own goal. The path it describes ends at "a first accepted blueprint" (161), which
gives the developer no documentation, because drafting happens only in a nightly run that still
lives on this workstation and lands after O. It leaves "fewer required settings" (156-157)
unquantified against a configuration surface that today asks for about forty keys. And it never
says what happens to the developer's existing pages on the first night. Two blockers, eleven
majors, nine minors.

## Walkthrough: a stranger with a small Go CLI (README plus three docs pages)

Each step is what the design, read literally, asks of them. "Today" marks what the current docs
add on top, where F's "fewer required settings" does not say it goes away.

| # | Step | Kind | Where they stall |
|---|---|---|---|
| 1 | Hear of drafter, open the system overview | read | Overview does not exist yet (O). Spec does not say what it says first. |
| 2 | Install the drafter binary | install | Spec says "install" (25) and names no method. Today: Go toolchain, a checkout, `make install`, which also links cairn's chain pieces (README:27-31). |
| 3 | Install Claude Code | install, account | Assumed, never stated. A Claude subscription or API billing for Claude Code itself. |
| 4 | Install the plugin | install | Named (150), no command. |
| 5 | Install Vale and sync its Google or Microsoft package | install | Implied by the stock gate (145-146), never listed. A link checker too, unnamed. |
| 6 | Create a Claude Console org with prepaid credit | account | drafter cannot bill a subscription (setup.md:26). A second bill the developer did not expect. |
| 7 | Create a workspace, a key, copy `workspace_id` | account, 3 settings | setup.md:33-41. |
| 8 | Set a Console spend limit, check auto-reload is off | decision x2 | setup.md:69-91. Recommended, not required. |
| 9 | Choose a key source (`key_env` or `key_command`) | decision, setting | |
| 10 | Choose `page_cap`, `cycle_ceiling`, `billing_cycle_day` | decision x3, settings | No guidance on what a page costs until the overview exists. |
| 11 | Write a price table | settings | Today: `prices.date`, `source`, `batch_discount`, and five rates per model (configuration.md:146-179). Spec silent on whether F builds one in. |
| 12 | Write `drafter.local.toml` or the user config, add it to `.gitignore` | files x2 | drafter refuses a local file git does not ignore (configuration.md:69-71). |
| 13 | Run `drafter init` | command | Writes `drafter.toml`, outline, facts dir (143-144). Today `drafter.toml` also needs `prompts`, `gate.command`, and model, effort, `max_tokens` for each of eight seats. |
| 14 | Start a Claude Code session, run the onboarding skill | command | |
| 15 | Wait for the code audit | cost | Spends Claude Code time; size and cost not stated. |
| 16 | Review the facts the audit wrote | decision xN | "The developer rules on everything a person must decide" (35); whether that includes each fact is unsaid. A real repo yields dozens to hundreds. |
| 17 | Declare tracks: reader profile and standard for each | decision x(2 per track) | Jargon: track, reader profile, Diátaxis mode, page anatomy, Good Docs template (40-46). |
| 18 | Accept or decline a house register | decision | Offered once (86). Good. |
| 19 | Approve the outline | decision | Reasonable. Cost of drafting it is not shown here. |
| 20 | Get a blueprint per existing page | wait | 123-125. What happens to the four existing pages on the first night is unsaid. |
| 21 | Run `drafter read` to "accept" a blueprint | command, spend | "Accepted" (161) means the blueprint read, an API call, so steps 6-12 must all be complete. |
| 22 | Get a drafted page | blocked | Needs the nightly run (B4, after O), whose scheduler is a systemd user timer with a token in the age store (arch:88, arch:381-387). |

Count, as the design stands with "today" filling the gaps: 5 installs, 3 accounts (Claude Code,
Console org, workspace), about 12 user-layer settings plus 5 per model priced, about 27
project-layer keys unless F defaults them, 4 to 6 files the developer must know of
(`drafter.toml`, `drafter.local.toml` or user config, `.gitignore` entry, `outline.yaml`, the
facts dir, `drafted.lock`), and at least 9 product decisions before the first blueprint, plus one
per fact if facts need review. Roughly 15 jargon terms surface: blueprint, track, reader profile,
register, standard package, facts store, fact tag, seat, framing, scope, anatomy, lock,
write-back, escalation, style note.

The benchmark sets a much shorter path. The Good Docs Project quickstart template frames a
quickstart as the shortest path to a first success. Diátaxis's tutorial guidance asks for
"visible results early and often" and to "minimise explanation"
(https://diataxis.fr/tutorials/). clig.dev asks a tool to make the default the right thing for
most users, to prompt for missing input when stdin is a terminal, and to suggest the next command
(https://clig.dev/#arguments-and-flags, https://clig.dev/#interactivity,
https://clig.dev/#help). The first visible result in this design is a YAML file, and the first
page arrives on a night the developer cannot yet schedule.

## Mental-model test

Can the developer say in two sentences what drafter does and what they must keep doing? Not from
the spec. The Brief (9-15) describes the onboarding pieces, not the product. The overview needs to
open with something like this, and the spec should fix the text or its content:

> drafter keeps a structured plan for each docs page and a list of checked facts about your code,
> and each night it rewrites the pages whose plans or facts changed and opens a pull request.
> You (or your coding agent) keep the plans and facts current as you change the code, and you
> review the nightly pull request.

Everything else (tracks, standard package, register, seats, framing, anatomy) can stay behind
that model until a step needs it.

"Agents edit blueprints, never pages" fits a solo developer who works through Claude Code and is
happy to wait a night. It fits poorly when the developer wants a typo fixed now (the hook steers
their agent to the blueprint; a hand fix is redrafted overnight, see finding 11), and when a team
reviews docs as prose in pull requests (they see YAML diffs by day and auto-merged prose by
night, see finding 9).

## Findings, ranked by consequence

### 1. The path ends before any documentation exists, and the nightly run is still workstation-only

- Severity: blocker. Tag: `correctness`.
- Location: 24-26, 27-31, 159-162; arch:88, arch:381-387, arch:625.
- Defect: The goal is "gets drafter working" and the anti-goal is anything "that exists only on
  the machine that built drafter." The anti-goal list (27-31) omits the nightly runner: a systemd
  user timer, a repo registry, and a GitHub token in the age store, with `pavilion` as the default
  host. O's acceptance stops at "a first accepted blueprint" (161), and B4 lands after O (162). A
  developer who finishes onboarding has plans and no pages, and no supported way to get pages. On
  macOS or in CI there is no systemd at all.
- Fold: Add the nightly runner, its registry, its token store, and its notification to the
  anti-goal list. Move O's acceptance to "a first drafted page, reviewed in a pull request." Give
  that page a path that needs no scheduler: an on-demand command (`drafter nightly` run by hand,
  or a `drafter draft <blueprint>`) documented in the overview.
- **OWNER FORK** (how a new project schedules the run):
  (a) manual only at first, the developer runs one command when they want pages;
  (b) a GitHub Actions workflow template that `drafter init` writes, with the key as a repo secret;
  (c) a local scheduler per OS (systemd, launchd, cron) that drafter documents.
  Recommendation: (a) for O's acceptance plus (b) as the stock schedule in B4. A CI workflow is
  portable, needs no always-on machine, and keeps the token out of a workstation store. Keep the
  systemd timer as Geoff's own choice.

### 2. "Fewer required settings" is unquantified against about forty keys, and O's acceptance contradicts it

- Severity: blocker. Tag: `correctness`.
- Location: 156-157, 160-161; configuration.md:82-86, 146-179, 228-262.
- Defect: Today `drafter page` and `drafter read` require `workspace_id`, two caps, `gate.command`,
  `prompts`, and for each running seat a `model`, `effort`, `max_tokens`, and a five-rate price
  entry. cairn's `drafter.toml` runs to eight seat tables. O's acceptance says a fresh session
  reaches an accepted blueprint "with only the plugin, the overview, and a key" (160-161), but
  acceptance runs `drafter read`, which today needs the workspace id, both caps, and a price
  table. The spec never states the target, so F can pass while the developer still hand-copies
  rates from a pricing page.
- Fold: State F's bar as a testable sentence. Proposed: a committed `drafter.toml` needs no keys
  at all (stock prompts, stock gate, stock seat models and budgets, convention paths); the user
  layer needs only a key source and the two caps; drafter ships a dated price table for its stock
  models and warns when it is older than some age. `drafter init` asks for the caps interactively
  when stdin is a terminal (clig.dev, interactivity) and prints the next command.
- **OWNER FORK** (`workspace_id`): (a) keep it required, the safety check that a wrong key spends
  nothing; (b) make it recommended, with a warning on every run that lacks it; (c) have
  `drafter init` read it from the first API response and write it for the developer. Recommendation:
  (c). It keeps the guard and removes a Console copy step, though it trusts the first key used.

### 3. Existing pages are rewritten on the first night without the developer choosing it

- Severity: major. Tag: `correctness`.
- Location: 123-125; arch:361 ("New blueprint"); new-page.md:3, 47.
- Defect: The spec routes an existing page's first blueprint through the new-page procedure, with
  the page as a source. That procedure ends "the nightly run drafts the page," and the nightly run
  treats a new blueprint as a whole-page draft. The CLI developer's hand-written README and three
  pages are rewritten, all at once, on night one, at a few dollars each, in a voice they did not
  pick. The converter path seeds the lock with the page as it stands (arch:178-180); this path does
  not say it does.
- Fold: State what the onboarding does to existing pages, and have the skill show it with a cost
  before the outline is approved.
- **OWNER FORK**: (a) seed the lock, so existing prose stays until its blueprint next changes, as
  conversion does; (b) redraft everything into the chosen standard on the first night; (c) ask per
  page. Recommendation: (a) by default, with the skill offering (b) once, with its estimated cost.
  It matches what a newcomer expects of a tool they are trying out.

### 4. Two bills, and no number before the developer commits

- Severity: major. Tag: `correctness`.
- Location: 134-137; setup.md:26-28; arch:414-420.
- Defect: The overview "explains what each piece costs" (135), but the design names no figure and
  no point at which the developer sees one. Onboarding spends Claude Code time (the audit, the
  outline, a blueprint per page) and every later blueprint edit does too. Drafting spends API
  credits from a separate Console org that cannot use a Claude subscription. The only published
  figure, $3 to $4.50 per whole page, lives in the architecture spec, written for Geoff's $160
  cycle.
- Fold: The overview's cost section is a two-row table (Claude Code for onboarding and edits; API
  credits for drafting) with an order-of-magnitude figure for each. The skill prints a projected
  first-run cost (pages times a per-page estimate) before the developer approves the outline, and
  `drafter status` shows the same estimate for the next run.

### 5. Install is a word, not a step

- Severity: major. Tag: `correctness`.
- Location: 24-26, 145-146, 150-151, 171; README:15-31.
- Defect: "read the system overview, install, and run the onboarding skill" (25) names no install
  method. Today install needs Go and a checkout, and `make install` also links cairn's
  `docs-page-chain.js` and `cairn-docs-outline`. The stock gate needs Vale and its style package
  and an unnamed link checker. The plugin has no named install command. A Python developer without
  Go is stuck at step 2.
- Fold: O names one install line for the binary per platform (a release binary or Homebrew, with
  `go install` as the Go user's path), one line for the plugin, and the gate's tools. Add a check
  (`drafter config` or a `drafter doctor`) that reports a missing Vale, a missing style package,
  or a missing key, each with the command that fixes it. Move the chain links out of the user
  install into a dev-only target.

### 6. The doc-set model is over-ceremonious for a small project

- Severity: major. Tag: `correctness`.
- Location: 40-49.
- Defect: Before an outline, the developer declares tracks, each with a reader profile and a
  standard, over Diátaxis modes and Good Docs anatomies. That is four frameworks of vocabulary for
  a three-page CLI or a library with no docs. Diátaxis itself warns a tutorial to "ignore options
  and alternatives." The cost of the ceremony is a stalled first session and decisions the
  developer cannot make well yet.
- Fold: Default to one track inferred from the audit (a CLI or library is developer docs on
  Google). The skill asks one plain question, "who reads these docs: developers, end users, or
  both?", maps the answer to tracks, and never says "track" unless there are two. Diátaxis modes
  and anatomies are drafter's business, not the developer's.

### 7. The acceptance test is run by the person least like a new developer

- Severity: major. Tag: `correctness`.
- Location: 19, 159-161.
- Defect: drafter onboarding itself, from Geoff's sessions on this workstation, cannot detect a
  workstation dependency (dotfiles settings, `~/.claude` agents, a stocked age store) or a step
  that only the author understands. The acceptance has no ergonomic budget, so it passes however
  long or confusing the path is.
- Fold: Run O's acceptance in a clean environment (a fresh container or user account with no
  `~/.claude` and no dotfiles) on a repo drafter has never seen, such as a small synthetic Python
  library with no docs, from the overview alone. Give it a budget: a named count of commands,
  decisions, and settings, recorded at the gate. drafter onboarding itself can stay as the second
  project.

### 8. A large organization cannot "point at" its existing style guide

- Severity: major. Tag: `correctness`.
- Location: 68-71, 84-86, 87-91; configuration.md:268-286.
- Defect: The spec offers "the project points `register` at the house style guide it already
  keeps" (85), but the same section requires fixed section headings so the prompts can load them,
  and `drafter check` fails any rule without a row, evidence, and a dated owner's ruling (69-71,
  89-91). An organization's guide lives in Confluence or Google Docs and has none of that. Today
  `register.<track>` is a list of section names, not a path. "Only the owner adds a row" (91)
  assumes one owner.
- Fold: Say how an existing guide comes in. Proposed: the onboarding skill imports it, mapping its
  rules into the template's sections and citing the original; rules that only tighten need no
  record, per 88-89, so most of an org guide imports without rows. Name the owner as a role the
  project sets (a CODEOWNERS entry for the register file works).
- **OWNER FORK**: (a) import into the template as above, full checks; (b) a reference mode that
  passes the guide's text to the prompts with no structure and no row checks, a weaker guarantee;
  (c) both, with (b) as a stepping stone to (a). Recommendation: (a). It keeps one register
  contract and the import is work Claude does, not the developer.

### 9. The nightly auto-merge does not fit a team

- Severity: major. Tag: `correctness`.
- Location: 5 ("Everything else stands"); arch:381-387.
- Defect: The night's pull request merges itself when CI is green, and the architecture notes that
  cairn has no branch protection. Most team repos require a review, so the merge fails or needs a
  bypass token. A team that reviews docs as prose sees only YAML diffs by day, and prose reaches
  `main` with no person reading it.
- Fold: The onboarding skill asks how the night's pull request lands and records the answer.
- **OWNER FORK**: (a) auto-merge stays the default for every project; (b) a new project defaults to
  an open pull request that waits for review, and auto-merge is opt-in; (c) the skill asks.
  Recommendation: (b). A newcomer's first nights should be read, and it works under branch
  protection with no extra token scope.

### 10. No route for disagreeing with a finding when there is no register

- Severity: major. Tag: `correctness`.
- Location: 67-70, 75-80.
- Defect: The disputed-lint procedure (a misread line is a vocabulary fix; a disagreement is an
  override) lives in the house register (67-70), and most projects will have none. Seat findings
  that escalate a page or reject a blueprint have no "I disagree" path at all in either spec; the
  report lists them and the page waits.
- Fold: Move the disputed-finding procedure into the base. For a lint finding: add the word to the
  project's Vale vocabulary, or turn the rule off in the project's Vale config, with a comment. For
  a seat finding: record a page `constraints` entry the seats must respect, or mark the page
  `review: human`. The overview's day-two section names both.

### 11. A hand-fixed typo is rewritten overnight

- Severity: major. Tag: `correctness`.
- Location: 98-99; arch:303-345, arch:325.
- Defect: A style-only human edit adds a style note and its section is "redrafted in the
  register's voice that same night" (arch:325). A solo developer who fixes a typo or tightens a
  sentence by hand gets a different sentence the next morning and spends credits for it. That is
  the most common docs edit there is, and the design's first answer to it is surprise.
- Fold: The overview says plainly what a hand edit does.
- **OWNER FORK**: (a) as designed, every hand edit redrafts its section; (b) a style-only edit is
  accepted as the page (the lock records it and its style note still guards the section); only a
  meaning edit redrafts. Recommendation: (b) for new projects. It keeps a person's wording when
  the content is unchanged and spends nothing.

### 12. The blueprint skill still assumes a register

- Severity: major. Tag: `correctness`.
- Location: 75-80; new-page.md:7, new-page.md:36; format.md:189, 205.
- Defect: "A project with no register is complete, and nothing in drafter requires one" (78), but
  the new-page procedure says "Read the register entry for that type's introduction and ending"
  and "Read the register's introduction rules," and an outline type's `anatomy` names "the register
  entry." A register-less project's agent follows a dead pointer on its first new page.
- Fold: F repoints those lines at the base anatomies and the base introduction guidance (147-148),
  with "and the register's entry, if the project keeps one." Add a check in F's acceptance that the
  skill works in a project with no register.

### 13. Fact review has no stated scale or role

- Severity: major. Tag: `correctness`.
- Location: 35-39, 167-168.
- Defect: "The developer rules on everything a person must decide" (35) leaves open whether each
  audited fact needs the developer's yes. A real audit writes dozens to hundreds of bullets, each
  with a status tag from a six-value vocabulary (`[verified]`, `[candidate]`, `[docs-drift]`, and
  so on, plan-format.md:373-380). Reviewing them one by one is the most expensive step in the walk.
- Fold: State that facts are Claude's, verified mechanically for source existence (167-168) and by
  the fact read for truth, and that the developer spot-checks a sample the skill picks, not the
  whole store. Keep tag vocabulary out of the overview.

### 14. The overview-first gate runs against tutorial guidance

- Severity: minor. Tag: `correctness`.
- Location: 12-13, 134-137.
- Defect: The developer reads an explanation of three pieces, the blueprint rule, the nightly run,
  and costs before doing anything. Diátaxis separates explanation from tutorial and asks a tutorial
  to minimize explanation and deliver results early. The ruling is Geoff's; the risk is a long
  overview that nobody finishes, and a skill that fails when they skip it.
- Fold: Keep the overview, cap its opening at one screen (the two-sentence model, the two bills,
  the install lines), and make the skill restate the model and costs in a few lines at its start
  so a developer who skipped the page is not lost.

### 15. Jargon reaches the developer

- Severity: minor. Tag: `correctness`.
- Location: 9-15, 40-71, 113-121.
- Defect: The spec's own terms (track, standard package, register, tightening, override, corpus,
  tells, framing, seat, anatomy) are internal machinery. The overview and skill have no rule about
  which a developer must learn.
- Fold: Name the developer's vocabulary in the spec: blueprint, fact, outline, nightly run, and
  register only if they choose one. Every other term stays in reference pages and agent prompts.

### 16. Leaving, or pausing, is undocumented

- Severity: minor. Tag: `correctness`.
- Location: 22-31 (no exit in the goal); arch:169-173.
- Defect: A trial user's first question after "how do I start" is "how do I stop." Pages are plain
  Markdown, so leaving is cheap, but nothing says so.
- Fold: The overview ends with "stop using drafter": remove the schedule, delete `blueprints/` and
  `drafter.toml`, uninstall the plugin; the pages stay as they are. Pausing one page is
  `managed: false` in the outline.

### 17. The amended spec still names Geoff where a project owner belongs

- Severity: minor. Tag: `correctness`.
- Location: 5; arch:340-345, arch:429-437.
- Defect: "Everything else in that spec stands" (5) imports "the report leads with what needs
  Geoff," "only Geoff promotes a candidate," and a desktop notification under the calm desktop
  rule. A new project inherits roles and a notification channel that do not exist for it.
- Fold: Amend those to "the project owner" and make the pull request body the only stock report
  channel, with the desktop notification as a local option.

### 18. Generated reference and other doc toolchains are not addressed

- Severity: minor. Tag: `optional`.
- Location: 40-49.
- Defect: The Python library's API reference comes from docstrings (Sphinx, mkdocstrings) and the
  Go CLI's from `--help` or godoc. Diátaxis's reference mode suggests drafter should write those
  pages; it should not. Projects on reStructuredText or a site generator's nav file also meet a
  Markdown-only assumption.
- Fold: The audit detects generated reference and the outline marks it `managed: false`. The
  overview states the Markdown requirement.

### 19. `drafter init` should hand off, not just write files

- Severity: minor. Tag: `optional`.
- Location: 143-144.
- Defect: `init` writes files and stops. clig.dev asks a command to suggest what to run next.
- Fold: `init` prints the next step ("open Claude Code here and run the onboarding skill") and,
  when settings are missing, which ones and where they go.

### 20. Claude Code is an unstated prerequisite for the whole team

- Severity: minor. Tag: `optional`.
- Location: 129-132, 150-151.
- Defect: Onboarding, every blueprint edit, and the page hook assume Claude Code. A teammate on
  another editor or agent edits pages by hand, which works through write-back, but nobody tells
  them.
- Fold: The overview's requirements line names Claude Code, and its day-two section says a
  teammate without it just edits pages and the nightly run takes the meaning back.

### 21. The stock corpus should link outside pages, not copy them

- Severity: minor. Tag: `optional`.
- Location: 62.
- Defect: "A small, curated set of excellent outside pages" in a stock package that ships in a
  public repo raises copyright and staleness questions if the pages are copied.
- Fold: The stock corpus holds citations and short excerpts with their source, fetched when a seat
  needs them.

### 22. The standard-package table is internal detail in a design for newcomers

- Severity: minor. Tag: `optional`.
- Location: 51-71.
- Defect: Seven parts with a two-column contrast is the right engineering record, but it reads as
  setup the developer must do. For a register-less project every cell in the stock column is
  drafter's work.
- Fold: Add one sentence above the table: "A project without a register configures none of this;
  drafter supplies the stock package for the standard each track names."

## Summary of owner forks

| Finding | Question | Recommendation |
|---|---|---|
| 1 | How a new project schedules the run | Manual command for O, GitHub Actions template as stock in B4 |
| 2 | `workspace_id`: required, warned, or captured by `init` | `init` captures it from the first response |
| 3 | Existing pages on the first night | Seed the lock; offer a priced redraft once |
| 8 | An organization's existing style guide | Import into the template, done by the skill |
| 9 | Nightly pull request merge default | Open for review by default; auto-merge opt-in |
| 11 | Style-only hand edits | Accept as the page; redraft only meaning edits |
