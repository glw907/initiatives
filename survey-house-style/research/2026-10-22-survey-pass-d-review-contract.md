# Survey Pass D review: contract and criteria lens

Spec: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `4827f40`. Scope: lines
15, 24, 37, 50, 62-64, 124-133 (the writing register), 165-172 (Pass D), 181 (cairn's docs), 211-212
(Pass D stops), 217 (Pass D risk and estimate), and 226 (the sittings). The rest was read for context
only. Line numbers below are the spec's at that commit.

The lens asks whether each promise is testable, whether each acceptance criterion names its fixture
and the reason it would fail, and whether any criterion can pass vacuously.

Totals: 2 blockers, 9 majors, 6 minors. Three findings carry an OWNER FORK.

## Blockers

### 1. drafter cannot inline a file under the project's own `node_modules` (blocker, correctness)

Location: spec:131, spec:171.

Defect: the drafter leg can't pass as written, for three reasons, all verified in drafter's source.

- `inline_files` reaches only files outside the repository. `repo.resolve` (`drafter/internal/assemble/files.go:132-158`) treats a path under the root as a repository path and refuses it unless git tracks it. `outOfRepo` also refuses any real path `within` the root. `node_modules/@glw907/survey/writing/...` is under the root and untracked, so it is never inlined, whatever `inline_files` says.
- `inline_files` entries must be absolute. `expand` (`files.go:64-77`) drops a relative entry silently, so `inline_files = ["node_modules/@glw907/survey/writing"]` does nothing and reports nothing.
- `register.<track>` is recorded and printed only (`drafter/docs/configuration.md:373-374`). The stock module never reads `registerSections` (`stock/prompts.js` has no reference to it), so naming Survey sections there inlines nothing on its own.

The dry run is also the wrong probe. `drafter page --dry-run` prints request sizes and cost, not content (`drafter/docs/setup.md:145-146`). A missing slug inlines as `no excerpt: no heading <slug>` and still exits 0, so "inlines a brief section by slug" passes vacuously even when the inlining fails. It also needs a handoff, caps, and a workspace ID that a scratch app doesn't have.

Proposed fold: OWNER FORK, since every working option either adds drafter scope or gives up a ruling.

- (a) A short drafter pass ahead of Pass D lets `inline_files` admit an untracked path inside the root, relative or absolute. Its test asserts that a known sentence from the section appears in the assembled request, and that a bogus slug yields `no excerpt`. Pass D's leg then runs a drafter command that prints the assembled request (or `--json` of it) and greps for that sentence.
- (b) The workstation installs each Survey version at a fixed path outside the repository, such as `~/.local/share/survey/<version>/writing`, and `inline_files` names that path. This breaks the per-repo version match that spec:108 promises.
- (c) A consuming project commits a copy of `writing/`. This is the copy drift that anti-goal spec:71 rules out.

Recommendation: (a). It is the only option that keeps the installed version authoritative. Either way, spec:131 should name which seat or prompt carries the section tokens, since the stock module ignores `register.<track>`.

### 2. The `glw907` takeover targets repos that cannot install an npm package, and linting code comments is a non-goal (blocker, correctness)

Location: spec:130, spec:181, against the non-goal at spec:64.

Defect: none of the five repos that copy `glw907` has a `package.json`: dubplate, poplar, and cairn-cms `tool/` are Go modules, and phonebook and cairn-themes have neither file. So `node_modules/@glw907/survey/vale/Survey` can't exist there, and spec:181's "drop their copied `glw907` style for the Vale pair" can't be done. In those repos `glw907` lints Go code comments (`[*.go] BasedOnStyles = glw907` in each `.vale.ini`). Spec:64 puts code comments out of scope, and global CLAUDE.md enforces the comment em-dash ban through that same style. A swap to "the Vale pair" would also add Google or Microsoft rules to Go comments, which changes behavior. The renamed checks break every `glw907.Judgment = warning` line and the `glw907.EmDash = NO` opt-out that the EmDash message names.

Proposed fold: OWNER FORK.

- (a) `glw907` stays out of Survey as the code-comment overlay, and Survey's Vale style covers prose only. It may start as a copy of the prose-relevant rules, and the ledger records which ones.
- (b) Survey absorbs `glw907`, and the Go repos fetch it as a zip from the Survey GitHub release, pinned to a tag through Vale's `Packages` URL form. This adds a release asset and a rename migration for each repo.

Recommendation: (a). It honors spec:64 and needs no Go-repo migration. Under either option, spec:181 should move the line about the four other repos out of the "cairn's docs" bullet and give it an owning pass, or drop it.

## Majors

### 3. The Pass D harvest ledger has no completeness check (major, correctness)

Location: spec:169.

Defect: Pass A's ledger is tied to a grep count (spec:139), but Pass D's has no count, so a ledger that skips rows passes. The sources are large and structured. `docs-register.md` alone has 1,220 lines with headed tells under two briefs (spec context: `docs-register.md:367`, `:550`) and two departure tables (`:1101-1120`).

Proposed fold: name a countable unit for each source and require the ledger's mapped count to equal the sum. The units are each `###` or `##` tell heading in both Tells sections, each table row under "Deviations from the base guides", each `##` in drafter's `stock/google-tells.md`, each `.yml` in `glw907` (seven), each rule heading in the admin design system's Voice section (`admin-design-system.md:1388`), and each numbered convention in the copy-edit research. Pin the copy-edit research to its file (`cairn-cms/docs/internal/design/2026-06-20-editor-copyedit-conventions-research.md`). Pin "poplar's tidy rules" to a file too (see finding 15).

### 4. The house-wide versus cairn-only sort can pass empty (major, correctness)

Location: spec:169, spec:211.

Defect: the standing answer marks any unclear row cairn-only without asking (spec:211). Nothing stops every row from being marked cairn-only, which would ship an empty register that passes every listed check. No row records why it got its mark.

Proposed fold: every row carries a reason. A cairn-only row names the cairn-specific noun it depends on (a track, a cairn name, a page anatomy, cairn tooling). A row with no such noun is house-wide by default, and a row whose reason is "unclear" goes to the sitting as one table with a default. The ledger reports the counts in each class in the PR body.

### 5. Widening a tightening house-wide is a voice change that reaches no ruling (major, OWNER FORK)

Location: spec:170, spec:128 (departures file).

Defect: cairn's register separates tightenings, which need no record, from overrides, which need Geoff's row (`docs-register.md:1083-1095`). Spec:170 sends only "new or widened departure[s]" to the sitting. Under cairn's own test, cairn's tightenings (the ban on question headings, the ban on staccato runs, the restricted imperatives) would widen to every house tool's docs and interface text with no ruling. They change the house voice as much as the override rows do. Spec:128's "departures file lists each change from the base" also leaves open whether tightenings count, which changes the sitting's size.

Proposed fold: adopt cairn's tightening/override test verbatim (Geoff, 2026-09-28) as the departures file's admission rule. Then OWNER FORK on tightenings:

- (a) They widen at Claude's call and are listed in `## Decisions`.
- (b) They reach the sitting as one table with a default, the way Pass A treats sub-threshold differences.

Recommendation: (b). It costs one table and keeps the voice a product call.

### 6. The Vale fixtures can pass without testing the rule (major, correctness)

Location: spec:130 ("Each Vale rule has a passing and a failing fixture"), spec:171 ("fails on a planted tell").

Defect: three gaps.

- Nothing checks that every rule has its pair. A missing pair passes.
- A failing fixture "fails" whenever any alert fires, including one from the Google or Microsoft base, so a broken Survey rule still looks covered.
- The scratch app's planted tell has the same hole: Microsoft or Google can catch it while `Survey` never loads, for example when the `Packages` path resolved to nothing.

Proposed fold: the fixture runner asserts that the failing fixture raises exactly `Survey.<Rule>` (from `vale --output=JSON`) and that the passing fixture raises zero `Survey.*` alerts. A gate check confirms that the count of `vale/Survey/*.yml` equals the count of fixture pairs. The scratch-app tell is one that only a `Survey` rule catches, and the assertion names that check. A second scratch-app assertion shows that the synced style's files match the tarball's.

### 7. The pack check does not cover the writing part (major, correctness)

Location: spec:188 (end-to-end pack leg), spec:167, spec:171.

Defect: the `npm pack --dry-run --json` list names DESIGN.md, the tokens, the outputs, the CSS, and the bin, but not `writing/`, `vale/Survey/`, the style sheet, or the skill source. Pass D's minor could ship without them while every listed leg stays green. The post-publish leg (spec:192) likewise checks only DESIGN.md and `survey-check`.

Proposed fold: Pass D extends both legs. The pack list must include each `writing/` brief, the departures file, the style sheet, `vale/Survey/*.yml`, and the skill source. The post-publish install reads one brief section and runs `vale sync` against the installed path.

### 8. The `survey-writing` skill's trigger and version match are untested (major, correctness)

Location: spec:132, spec:172.

Defect: two gaps.

- A user-scope skill is a single install, but repos pin different Survey versions. "Installs it from the installed package ... so the skill follows the version" doesn't say which repo's package is the source, so the version-match promise can't be tested.
- No acceptance covers the trigger. Pass C had should-trigger and should-not prompts (spec:162). Here three skills compete for the same prompts: `writing-voice`, Pass C's `survey`, and `survey-writing`. Spec:205's trigger stop exists, but Pass D names no prompts for it to act on.

Proposed fold: the skill body only routes to `node_modules/@glw907/survey/writing/` in the current repo, carries no rule text, and so has no version of its own. Its source is installed from a named path (a Survey checkout, or the newest published tarball), and the manifest records that version. Add Pass C's acceptance method. Use three should-trigger prompts (a house-tool empty state, a house tool's README, an error message) and three should-not prompts (a commit message, a 907.life page, a cairn published docs page before cairn converges). Run them in fresh headless sessions, and spec:205's answer applies.

### 9. The workstation routing scope is undefined (major, OWNER FORK)

Location: spec:132 ("house tools' interface text and house docs"), spec:172.

Defect: `writing-voice` rows 23-24 route developer docs in any Go or web repo to `technical-doc-go.md` or `technical-doc-web.md`, and row 29 routes end-user copy to `editor.md`. "House docs" doesn't say whether Survey's register now governs every repo's developer docs (drafter, poplar, dubplate) or only Survey-adopting apps. It also doesn't say whether `editor.md` and `technical-doc-web.md` are retired, kept, or reduced to pointers. A routing row with an unclear scope can't be checked by the trigger prompts in finding 8. Global CLAUDE.md's "Writing voice" section ("Cairn's docs voice is the named overlay") would go stale, and it isn't in the edit list.

Proposed fold: OWNER FORK.

- (a) The Survey register governs all developer and end-user prose in every repo Geoff owns. `editor.md` and `technical-doc-web.md` become pointers.
- (b) It governs only repos whose `package.json` lists `@glw907/survey`, and the workstation registers stay for the rest.

Recommendation: (b) for 1.x. It is checkable from the manifest and needs no repo without the package to change. Either way, add the CLAUDE.md "Writing voice" line and the charter's exact sentence (`authoring-charter.md:22`, "The workstation itself keeps no house lexicon of its own") to spec:172's edit list.

### 10. The briefs copy drafter's stock and the output style's tells, which invites drift (major, correctness)

Location: spec:128, spec:169.

Defect: the Google brief "in drafter's stock shape" carries its own description, tells, rubric, and corpus, and so do drafter's `stock/google-*.md`. The authoring charter assigns audience-invariant tells to the output style and `tellgrader` (`authoring-charter.md:23`). A cairn tell harvested into Survey can duplicate one of those. That leaves two or three homes for one rule, which is anti-goal spec:71.

Proposed fold: add an "owned elsewhere" disposition to the Pass D ledger, giving the owner's path, so the row is not shipped. Decide in the spec whether Survey's Google brief cites `drafter:google-*.md` for the base and holds only house deltas, or replaces drafter's stock for house projects. Recommendation: cite the stock files and hold deltas only. The Microsoft brief has no stock counterpart (drafter's `stock/` is Google-only), so it is written new and needs its own fixture: each corpus excerpt's URL, license, and retrieval date, checked by a lint.

### 11. The rulings sitting has no closing invariant (major, correctness)

Location: spec:170.

Defect: Pass A closes on "every difference and promote row carries a ruling id" (spec:141). Pass D has no matching condition, so a departure that ships without a ruling passes. Nothing traces a ruling to where it lands in `writing/` or `vale/Survey/`, the way Pass B's trace does (spec:150).

Proposed fold: after the sitting, every departure row carries a ruling id or a carried-over cairn ruling (with its date). Each id maps to a brief section, a departures-file row, a style-sheet row, or a Vale rule, and a check counts them.

## Minors

### 12. A rule Vale "can't express" is self-certified (minor, correctness)

Location: spec:130 ("a rule for each copy-editing rule Vale can check"), spec:212.

Defect: Claude decides both what Vale can check and what goes unbuilt, so "can't express" absorbs any rule.

Proposed fold: each style-sheet row carries a `vale:` field that names either the rule or the reason none fits (it needs parsing beyond a token or regex, or it depends on scope Vale can't see). The PR lists the reasons.

### 13. The style sheet has no machine-readable shape, yet code is meant to read it (minor, correctness)

Location: spec:129.

Defect: "the tidy features in poplar and cairn read the same sheet" promises a code consumer but names no format. poplar is a Go module with no `node_modules`, so the "installed package" route doesn't reach it either. Tidy adoption is a non-goal (spec:62), so this sentence promises something nothing here tests.

Proposed fold: name the format, such as one YAML or JSON file with a schema and a schema check in the gate, so a later tidy adoption doesn't force a major. Or cut the sentence to "a later pass may read it".

### 14. The Vale `Packages` local path needs a stated sync and ignore contract (minor, correctness)

Location: spec:130.

Defect: `vale sync` copies the style into `StylesPath`. If the copy is committed, it drifts from `node_modules`. If it is ignored, CI must run `npm ci` and then `vale sync` before linting. The spec says neither, so "the style moves with the npm version" is untested.

Proposed fold: the synced `Survey` directory is gitignored, and the scratch app's CI-equivalent script runs `npm ci && vale sync && vale` from a clean clone. Finding 6's file-match assertion covers the rest.

### 15. Two harvest sources are unpinned (minor, correctness)

Location: spec:169.

Defect: "poplar's tidy rules" names no file. poplar's tidytext is an LLM rewrite (`internal/tidytext/`, `BuildPrompt`), so its rules live in a prompt or config, and the ledger can't cite a commit for them. "cairn's 2026-06-20 copy-edit research" matches six files in `cairn-cms/docs/internal/design/`.

Proposed fold: name each source file and record each at a commit, as Pass A does (spec:137).

### 16. Pass D is missing stop answers (minor, correctness)

Location: spec:194-213.

Defect: there is no standing answer for any of these:

- Geoff rejects a proposed house-wide departure (does the row stay cairn-only or drop?).
- The `Packages` local path doesn't load.
- The drafter leg fails (finding 1).

Spec:210's escalation list also doesn't say whether Pass D's fixture and pack legs may escalate.

Proposed fold: add three answers. A rejected widening stays cairn-only and is recorded. A `Packages` failure stops the pass, since it is a design change. A drafter failure follows whatever finding 1 decides. Add the Vale fixtures and the pack leg to the never-escalate list.

### 17. Pass D's ceremony and estimate need a check (minor, optional)

Location: spec:217, spec:226.

Defect: Pass D is classed `live-account` for a minor release through a workflow that Pass B has already proved. That brings the three-lens review and a verification read, on top of a sitting and a merge packet, for what is mostly text. The workstation PR lives in `~/.dotfiles`, but no line names `dotfiles-pass` as its adapter, and nothing says it merges only after the minor publishes, which the skill install needs. The 320 minutes cover two briefs, a style sheet, a Vale style with fixtures, a skill, a scratch app, a sitting, a release, and a second-repo PR, with no breakdown. They also leave out finding 1's drafter work if (a) is taken.

Proposed fold: scope `live-account` to the release task alone, and confirm against `pass-core` that the class can apply per task. Name `dotfiles-pass` for the workstation PR and order it after the publish. Have the planner check the 320 figure against the task list, plus any drafter pass.
