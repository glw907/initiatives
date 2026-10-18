# Review: drafter onboarding design, contract and criteria lens

Target: `specs/2026-10-18-drafter-onboarding-design.md` (branch `docs-system-onboarding-design`,
glw907/initiatives#18), read against `specs/2026-10-17-blueprint-architecture-design.md` (cited
as "arch"), drafter at `f7d9034`, and cairn-cms at its current `main`. Reviewer: fresh context,
read-only. Line numbers refer to the onboarding spec unless marked "arch".

## Verdict

The design is sound in direction, but as a contract it isn't testable yet. Neither the goal nor F
has an acceptance criterion. O's criterion can pass on a trivial repo, and it can also fail for a
reason onboarding doesn't own (drafter#43). The line "Everything else in that spec stands" (4-5)
is false in at least seven places. Three of those are correctness defects that would surface in
F's first task: a TOML key collision, `types[].anatomy` still pointing into a register, and tracks
with no schema home. Of the four calls, 1 and 3 are sound with gaps, 2 has a correctness gap (lock
seeding), and 4 is fine.

Counts: 3 blockers, 9 majors, 7 minors. 4 owner forks.

## Findings, ranked by consequence

### 1. Blocker, correctness: F and the goal have no acceptance criterion

Location: 24-26 (goal), 156-157 (F).

Defect: The goal ("one documented path ... nothing they need lives only on Geoff's workstation")
names no fixture and no test. F lists five deliverables. It has no done-condition, no fixture,
and no failure reason. "Fewer required settings" (157) has no target. The anti-goal (27-31) is
the best raw material in the spec, because it lists the five workstation-only items. But no pass
says which item it removes or how the removal gets proven.

Proposed fold: Turn the anti-goal list into a table with one row per workstation-only item. Give
each row the item, the pass that removes it (F or O), the check, and why the check would fail
today. Then add an F criterion along these lines. With `HOME` set to an empty directory (no
`~/.claude`, no dotfiles, no `~/.local/bin` apart from the built `drafter`), `drafter init`,
`drafter check`, the stock gate, and `drafter read` succeed on a named synthetic fixture repo
under `tests/` with no `prompts`, no `gate.command`, and no `seat.*.agent` set. It fails today
because `prompts` and `gate.command` are required to run (`docs/configuration.md:84`). Name the
settings F stops requiring (see finding 6).

### 2. Blocker, correctness: O's criterion passes vacuously and can fail for a reason outside O

Location: 159-161.

Defect: "A fresh session in a new repo ... reaches a first accepted blueprint" has three holes.
(a) No fixture is named, so a one-file repo with a one-section concept page meets it. (b) "Fresh"
isn't pinned. The session that builds O knows drafter, and drafter as "the first new project" is
neither new nor unknown to its builder. (c) Acceptance depends on the blueprint read converging.
On the real project, that hasn't happened yet: B1's milestone missed with six fix verdicts, B2's
format test went 0 of 5, and drafter#43 is open. So O can also fail on a read-convergence problem
that onboarding doesn't own. The criterion also doesn't test the three things onboarding promises,
which are an audited facts store, tracks on a standard, and an approved outline.

Proposed fold: Name two fixtures.

- A synthetic public fixture repo of stated minimum shape. One example: a small CLI with at least
  five commands, an existing README, and no docs directory.
- drafter itself, as the real-world case.

The criterion runs in an isolated `HOME` with the plugin, the drafter binary, Vale, the overview
URL, and a key, and an agent that has no access to the initiatives repo. It passes when all of
these hold:

1. `drafter init` wrote its files.
2. The facts store holds at least N facts, every one passing fact verification.
3. `outline.yaml` declares at least one track with a standard and at least M pages, and the
   developer approved it in the transcript.
4. One task-type page's blueprint passes `drafter check` and reaches `accepted`.
5. No tool call touches a path outside the fixture and the isolated `HOME`, which the transcript
   grep checks.

Each check names the anti-goal row it catches. Make O depend explicitly on the change-read pass
having met its bar. If that bar is still missed, O's criterion should read "passes `drafter
check` and the read's blocking findings are all on lines the onboarding wrote", not "accepted".

### 3. Blocker, correctness: the `register` setting collides with the existing `[register]` table

Location: 84-85 ("the project points `register` at the house style guide it already keeps").

Defect: drafter already has `register` as a table: `register.<track>` is a list of register
sections per track (`internal/config/file.go:34`, `map[string][]string`, and
`docs/configuration.md:274-281`). A scalar `register = "path"` can't coexist with it in TOML, and
strict decoding rejects it. The spec doesn't name the change, and it doesn't say whether
`register.<track>` survives. That matters because, under the fixed-heading model (69-71), section
lists per track look redundant.

Proposed fold: Add a "Changes to the architecture spec and the built format" table (see finding 4)
with a row that renames or reshapes the setting. For example, `register.path` plus whatever
replaces `register.<track>`. Say what cairn's existing `register.*` keys map to during the window
from F to B5.

### 4. Major, correctness: the amendment contradicts the architecture spec in places it doesn't name

Location: 4-5 ("Everything else in that spec stands").

Defect: Each row below is a statement in arch, or in the built format, that this design changes
without saying so.

| Arch or format says | Onboarding says | Consequence if left unnamed |
|---|---|---|
| Documentation standard is "named in project config" (arch 85) | Each track declares its standard in `outline.yaml` (42-44) | F builds one home and the docs describe the other |
| House register: "the project's recorded departures ... Geoff's ruling" as a standing component (arch 86) | Optional, and absent in most projects (75-80) | Seats and the report assume a register exists (rows below) |
| A blueprint carries "register sections" (arch 98, 108). The built format moved them to `register.<track>` (`docs/blueprint-format.md:81-83`) | Prompts load fixed sections by name (69-71) | Two mechanisms for picking sections, and no rule for a project with no register |
| "each declared type names the register anatomy it follows" (arch 252-254, `schema/outline.schema.json` `anatomy` description, `docs/blueprint-format.md:205`) | "the page anatomies ... live in drafter's base, never in a register" (79-80) | `drafter check` keeps resolving anatomies against a register a project may not have. Also unsaid: where a project-specific anatomy, such as cairn's Symptom row, lives |
| Style notes collect into "candidate register rules" in every morning report, "only Geoff promotes" (arch 29, 342-344, 431-432). A note stays "until Geoff promotes it into the register or rejects it" (arch 339-340) | Promotion "is the project's choice, never a step drafter prompts" (98-99) | Direct conflict: the report's style-candidate section is drafter prompting. With no register, notes never clear and pile up forever |
| A redraft is "in the house voice" or "register's voice" (arch 26, 325). The register editor "reads each note as a known failure of the house voice" (arch 333). `cairn-register-editor` "already serves as the editor seat's system prompt" (arch 494-495) | The editor seat grades the package's reviewer rubric (65) | The stock editor seat's prompt and inputs are unnamed for a project with no register |
| Bootstrapping an unplanned page is the write-back seat's job, and sub-project 4 becomes that (arch 182-184, 519-520) | The new-page procedure does it during onboarding (call 2, 123-125) | Arch's Bootstrapping section and sub-project line stay authoritative to a later planner |
| The skill installs by `make install` into `~/.claude/skills/`. The hook goes into the tracked `settings.json` (arch 457-459, 467). Public-plugin packaging "stays in sub-project 5" (arch 499-501) | A plugin in O (call 3, 150-151) | See finding 8 |
| B5 is the migrations (B1 plan, "Build sequence") | B5 also splits cairn's register into base and overlay (162-163) | B5 gains unestimated scope silently |

Proposed fold: Replace "Everything else in that spec stands" with a "Changes to the architecture
spec" table holding these rows, each with its new reading. That's the same device arch itself uses
for the pipeline spec (arch 503-512). For the style-note row, see owner fork A.

### 5. Major, correctness: tracks have no home in `outline.yaml` and pages have no track

Location: 42-44.

Defect: "The project declares its tracks in `outline.yaml`, each with a reader profile and the
published style standard." `schema/outline.schema.json` has no `tracks` key, and a page entry has
no track field. Today a page's track is implicit (cairn uses path prefixes, and drafter's
`register.<track>` keys on a name). Without a page-to-track link, drafter can't pick a page's
standard package, so F's stock prompts can't load the right one. That's a format change with a
schema version question attached (`version: 1`).

Proposed fold: State the schema change. Add `tracks` (name, reader profile, standard, optional
register) and a page field `track` or a path-prefix rule. Say whether it's `version: 2` or an
additive v1 change. Add a `drafter check` row: every managed page resolves to exactly one track.

### 6. Major, correctness: "only ... a key" conflicts with drafter's required money settings

Location: 160-161, 157 ("fewer required settings").

Defect: drafter refuses to run without `workspace_id`, `page_cap`, `cycle_ceiling`, and a
`prices.models` entry for each seat's model (`docs/configuration.md:83-86, 98-103`). The pipeline
spec made that refusal deliberate: drafter "never spends against an amount you didn't choose"
(`docs/configuration.md` on caps). O's criterion says a new developer needs only the plugin, the
overview, and a key. Either F defaults the caps and prices, which reverses a pipeline-spec safety
ruling without naming it, or the criterion is wrong.

**OWNER FORK B.** Option 1: keep the caps and workspace required, and have the onboarding skill ask
for them (with a recommended starting value) and write them to the user layer. Option 2: ship
defaults for the caps and a stock price table, so a key alone runs. Recommendation: Option 1 for
the caps and the workspace, which are safety rulings, and a stock dated price table (only prices
are mechanical). Then correct O's criterion to "a key, a workspace, and two caps the skill asks
for".

### 7. Major, correctness: an existing page onboarded through the new-page procedure has no lock entry

Location: 123-125, call 2 (169-170).

Defect: arch's converter seeds `drafted.lock` with the page as it stands, so a converted page isn't
redrafted until its blueprint changes (arch 179-181, call 15). The new-page procedure writes a
blueprint and no lock entry. The nightly run would then classify the page as "New blueprint" (arch
361) and draft it whole. That overwrites a working human-written page and spends credits, for
every page onboarding touched. Call 2 is sound otherwise, since the session can see the page, but
this side effect is unaddressed.

Proposed fold: Have call 2 also say: "the onboarding skill seeds the page's lock entry with the
page as it stands, as the converter does (a `drafter` command, not a hand edit)". Add a `drafter
status` check to O's criterion: an onboarded existing page shows as unchanged.

### 8. Major, correctness: the plugin and `make install` both install the hook and the skill on this workstation

Location: call 3 (171), 150-151.

Defect: After O, the workstation would have the blueprint skill and the page hook from the plugin,
plus `make install`'s skill symlink and the `settings.json` hook from arch 467. Two
`PreToolUse` hooks would fire the reminder twice, and two skills with one name would be ambiguous.
`claude-tooling-sync verify` would also see a component with two homes, which the workstation's
"one home and one manifest" rule forbids. The phrase "make install stays for development" doesn't
say which install path this workstation uses.

Proposed fold: Have call 3 also say that O moves this workstation onto the plugin, removes the
`settings.json` hook entry and the `make install` skill link, and updates the `claude-tooling`
manifest. `make install` keeps only the binary. Alternatively, a development flag installs the
plugin from the working tree. Add the hook's single firing to O's criterion.

### 9. Major, correctness: the stock gate drops provenance, and its tools aren't in the install path

Location: 145-146, 29-30.

Defect: The anti-goal names `check:facts` and `check:provenance` as workstation-bound. The stock
gate lists `drafter check`, Vale, and a link check. Fact verification replaces `check:facts`, but
nothing replaces `check:provenance`, the brief-to-fact check that arch keeps the brief for (arch
163-164). A new project would then draft pages whose sentences nobody ties to facts. Separately,
Vale and the link checker are runtime dependencies that O's "only the plugin, the overview, and a
key" leaves out.

Proposed fold: Add brief provenance to the stock gate, or call it out as dropped for stock projects
with a reason. List the gate's external tools (Vale and its package sync, the link checker) in the
install path, and require them in O's isolated-`HOME` fixture.

### 10. Major, correctness: the goal can't hold for figure pages

Location: 24-26 vs. arch 67 and 491-493.

Defect: Figure pages stay on the docs page chain, which lives at
`~/.claude/workflows/docs-page-chain.js` with `cairn-docs-outline` and `cairn-docs-drafter`. The
anti-goal names those as workstation-only. A new project with a figure page therefore needs
something that exists only on this machine, which breaks the goal as written.

Proposed fold: Add a scope line. A new project's figure pages are unsupported (`figure: true`
pages are set aside) until drafter takes figures on. Restate the goal as "every non-figure page".

### 11. Major, correctness: "drafter check fails a rule with no row" isn't mechanically checkable

Location: 69-71.

Defect: Telling an override from a tightening is a judgment ("forbids a form the guide
recommends"). cairn's own register treats a missing row as "a blocking finding against the
register" for a reviewer, not a script. `drafter check` can verify row shape (base rule, instead,
evidence, ruling with a date), but not that every override has a row. As written, the promise
either can't be built or gets built as a keyword heuristic that passes vacuously.

Proposed fold: Split the promise. `drafter check` fails a row missing a column or a dated ruling.
The reviewer rubric (or the editor seat on the register itself) owns "a rule that departs from the
guide with no row". Name a fixture: a template register with one override row missing its ruling
must fail.

### 12. Major, correctness: B3 is "built on the stock pieces" but its pilot exercises only cairn's overrides

Location: 158, 156-157 ("cairn keeps its overrides").

Defect: B3's pilot is cairn's stage 2b pages, which run on cairn's prompts module and gate. So the
stock prompts and the stock gate F builds don't draft a single page until O. The ordering
rationale ("so B3 builds on those rather than on cairn's own", 18) gets no evidence from B3.

Proposed fold: Add to B3's acceptance one synthetic-fixture page drafted end to end with stock
prompts and the stock gate. Or state plainly that the stock drafting path is first proven in O,
and accept that risk.

### 13. Major, optional (over-ceremony): the standard package's breadth before a consumer exists

Location: 51-65, 94-96, 147-149.

Defect: F and O together promise seven parts times two standards: curated outside corpora,
before-and-after tells, two rubrics, Vale vocabulary from the audit, a register template, a guide
page with worked examples, and `drafter init --register`. In this build order, the Microsoft
package has no consumer. drafter's overview is Google, and cairn keeps its overrides until B5.
The register template and its guide have no consumer before B5 either. Neither can be tested
against real use, and building them is the largest clock and token cost in the design that no
criterion pays for.

**OWNER FORK C.** Option 1: build both stock packages and the register kit in F and O as written.
Option 2: build the Google package in F (drafter's own consumer), and defer the Microsoft package
and the register template, guide, and `--register` to the pass that first has a consumer (B5 for
the register, through cairn's split). Recommendation: Option 2. It removes two untestable
deliverables, and the parts deferred are additive.

### 14. Minor, correctness: call 1 is sound as a floor, but it's both understated and over-trusted

Location: 38-39, call 1 (167-168).

Defect: (a) cairn's `check:facts` checks more than "source exists": the bullet grammar, a unique
`f:` id, a vocabulary tag, and `path:line` resolution (`scripts/checks/check-facts.mjs:1-40`). If
F ports only existence, it drops checks cairn relies on. (b) The spec doesn't say what tag an
audit-written fact gets. arch requires a new fact to carry a pending tag until the fact read
confirms it (arch 319-323). If onboarding writes `[verified]` on the session's word, that's a
silent decision that skips the fact read the call itself names.

Proposed fold: Define fact verification as cairn's `check:facts` contract (grammar, id, tag, and
resolving source), generalized. State that audit facts land pending until a fact read confirms
them, or that the onboarding session runs the fact read before marking them verified.

### 15. Minor, correctness: one register per project, or one per track or standard?

Location: 53-71, 84.

Defect: cairn's register overlays two standards across four tracks, with a brief per track. The
package's fixed headings (Description through Reviewer rubric) are written per standard. The spec
doesn't say whether a project has one register with sections per track, or one per standard.
That decides the template and the prompt loader.

Proposed fold: State the cardinality, with a recommended reading of one register file holding one
package-shaped block per standard it overlays, and record it as a call.

### 16. Minor, correctness: "accepted pages join its corpus" leaves the mechanism unstated

Location: 67.

Defect: Is it automatic, or curated by the owner? Automatic admission feeds a mediocre accepted
page back as an exemplar, a loop that pushes quality toward the mean. This is a silent decision.

**OWNER FORK D.** Option 1: automatic on acceptance. Option 2: the owner promotes a page to the
corpus, the same way a style note gets promoted. Recommendation: Option 2, which is consistent
with every other promotion in both specs.

### 17. Minor, correctness: an outside corpus in a public repo

Location: 62 ("a small, curated set of excellent outside pages, each cited").

Defect: drafter is public. Copying third-party pages into it raises a licensing question that
"each cited" doesn't settle. The rules row avoids it ("the published guide itself, never copied"),
but the corpus row doesn't.

Proposed fold: State that the stock corpus is links plus short attributed excerpts, or pages under
a license that permits redistribution, and record each page's license.

### 18. Minor, optional: the introduction rule's "never grows into an unplanned section" has no checker

Location: 117-119.

Defect: No seat or check is assigned. The blueprint read checks the plan (113-116). Who catches an
unplanned background section in a drafted page? Probably the coherence read or the reader seat,
but the spec leaves it unnamed.

Proposed fold: Name the seat. One clause is enough.

### 19. Minor, optional: the introduction guidance gets two homes from F to B5

Location: 111-112, 162-163.

Defect: F generalizes cairn's "The introduction" into drafter's base, while cairn's register keeps
its copy until B5. That's two homes for one rule, which arch's own principle forbids (arch 90-92).
It's harmless while cairn overrides its prompts, but the drift risk isn't named.

Proposed fold: Have F's stock text cite cairn's register section as its source until B5 removes
cairn's copy, and add the removal to B5's scope line.

## Owner forks, collected

- **A** (finding 4, the style-note row): What happens to style-note candidates when a project has
  no register? Option 1: the morning report still lists them, as "patterns you may want to rule
  on", and a note clears when the owner rejects it or after N accepted redrafts without a
  regression. Option 2: with no register, write-back records no style notes, and a style-only edit
  becomes a redraft guard alone. Recommendation: Option 1. It keeps the regression guard arch
  relies on (arch 332), and it reconciles line 99 by framing the list as information, not a
  prompt to act.
- **B** (finding 6): required caps and workspace versus "only a key". Recommendation: keep them
  required, and have the skill ask.
- **C** (finding 13): build both stock packages and the register kit now, or defer to their first
  consumer. Recommendation: defer.
- **D** (finding 16): corpus admission automatic or owner-promoted. Recommendation: owner-promoted.

## The four calls

1. Fact verification checks existence only. It's sound as a mechanical floor, but it should match
   cairn's full `check:facts` contract, and it needs the pending-tag rule (finding 14).
2. An existing page's first blueprint comes from the new-page procedure. It's sound, and it avoids
   blocking on B4. It's missing lock seeding (finding 7) and a statement of scope: does onboarding
   blueprint every existing page, or one? The cost moves from API credits to interactive session
   time, which is worth one line.
3. The plugin ships in O and `make install` stays. It's sound, but it needs the de-duplication and
   manifest step (finding 8), and a statement of how the Go binary reaches a new machine, since a
   plugin doesn't obviously carry it.
4. Risk class and estimate get set at planning. That's fine. The brief's "about one pass longer"
   for the cairn release (19-20) is the only schedule claim, and it rests on F's unsized scope
   (the packet's "Not checked" admits this). Restate it as "at least one pass".

## Decided silently (beyond the calls)

- Tracks move to `outline.yaml`, and pages need a track link (finding 5).
- The `register` setting changes shape (finding 3).
- `types[].anatomy` stops naming a register entry, and project-specific anatomies have no stated
  home (finding 4).
- Figure pages are out of reach for new projects (finding 10).
- Provenance drops from the stock gate (finding 9).
- Audit facts' status tag (finding 14).
- Corpus admission (finding 16).
- B5's added scope (finding 4, last row).
- How the binary, Vale, and the link checker are installed (findings 2, 9, and call 3).
