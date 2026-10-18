# drafter B2 plan review: contract and criteria

Target: `docs-system/plans/2026-10-18-drafter-b2-blueprint-skill-plan.md` at `b7c25f1` (branch
`docs-system-b2-plan`). Read against the approved design (`specs/2026-10-18-drafter-b2-design.md`),
the architecture's "The pilot", "Claude infrastructure", and "Scope of a redraft", drafter `9915232`,
cairn-cms `50dc211d9`, and B1's record (drafter#46, drafter#43). Line numbers are the plan's.

Verdict: the plan's shape is sound, but the format test as written can report four of five without
having measured what the pilot asks. The scoped read has no negative control, the grader can be
reached by the agent under test, the scope the read used is never recorded, and the byte-identity
promise has no fixture that could fail. Four findings are majors; one is an owner fork.

## Findings, ranked by consequence

### 1. The scoped read has no negative control, so five `ok`s cannot tell "the format is easy" from "the scoped read is lenient"

- Severity: **major**. Tag: `correctness`.
- Location: plan:107-123 (resolution 9), plan:172-181 (B2.5 acceptance).
- Defect: the only live use of the scoped read is the five tweaks, and a tweak passes when the read
  answers `ok`. Resolution 2 changes the prompt so that most findings become non-blocking. If that
  paragraph makes the read too lenient, every tweak passes, and nothing in the plan would show it.
  B2.2's fake-API test (plan:145) proves only that the paragraph and ids reach the prompt. It never
  shows that the model still blocks on a real defect inside the scope. The B2.5 bar is the only
  evidence, and a lenient read passes it trivially.
- Fold: add one seeded control to B2.5, run by the executor and not by the test agent. Commit a
  change to a clean section that carries a defect the bar names and `drafter check` cannot catch.
  The reader-state case fits: a step whose prose relies on state no earlier step produces, with
  `requires` left silent. Expect `fix` with a blocking finding in that section. If the read answers
  `ok`, the scoped read is lenient: record that as a bar defect and do not count the five tweaks
  against the bar. This costs one read (about $0.25 at B1's rate) and about 10 minutes. A second,
  optional control shows the scope is honored: confirm that at least one tweak's read reports B1's
  round-6 open findings (for example `s-delete`) as non-blocking. That evidence is the drafter#43
  comment the Close already asks for (plan:190), so state it as that comment's content.

### 2. The agent under test can reach the grader, so "first try" can pass vacuously

- Severity: **major**. Tag: `correctness`.
- Location: plan:110-113.
- Defect: the agent is `general-purpose` with every tool, and in a cairn worktree drafter resolves
  its key from the configuration (`internal/key/key.go:26`, `key_command` or `key_env`). Nothing
  stops the agent from running `drafter read` itself, reading the findings, fixing them, and then
  committing. The executor's read would then be a second try that looks like a first. The plan says
  the agent "may run `drafter check` itself", which is right because the skill teaches check in
  the loop. But it is silent on `drafter read`, and the run state would not show it unless someone
  looked.
- Fold: in each prompt, add one protocol line that is not help: "Do not run `drafter read`." After
  each tweak, the executor confirms that `drafter spend --since <tweak start> --json` rose by
  nothing before its own read, and that `<state dir>/runs` gained no run. A tweak whose agent ran
  the read is recorded as a protocol breach and fails. Also say that "first try" means the agent's
  first commit, judged with no feedback from the read. Self-iteration on `drafter check` is
  allowed.

### 3. Nothing proves the agent used the skill, or used only the skill

- Severity: **major**. Tag: `correctness`.
- Location: plan:110-113, 175-180.
- Defect: the pilot's condition is "only the skill as help". The plan controls the prompt, but not
  what the agent loads or reads. A general-purpose agent can open the architecture spec in
  `~/Projects/initiatives`, B1's PR, or the chain's prompts, and pass on knowledge the skill does
  not carry. It can also skip the Skill call and pass anyway. Either way, a pass would not measure
  the skill. B2.5's row records neither.
- Fold: add two columns to each B2.5 row, both filled from the subagent's transcript, which the
  executor already holds. The first records whether the `blueprint` skill was invoked. The second
  lists every file read outside the skill, the files it links, and the worktree. A tweak that never
  loaded the skill, or that read the architecture spec, the plan, or B1's record, is marked
  "protocol breach" and fails. This adds no runs, just reading the transcript the executor has.

### 4. The tweak prompts are written by the grader and are not recorded, so they can leak the answer

- Severity: **major**. Tag: `correctness`.
- Location: plan:119-122.
- Defect: the executor picks each tweak's content from cairn's code and writes it "as the request a
  developer would make". Nothing in the plan prevents a prompt from naming the section id, the item
  kind, the fact id, or the YAML shape. A prompt like that does the format work the test is meant
  to measure. Tweak 2's own line, "with `drafter refs` on its id" (plan:117), reads as an
  instruction that could go into the prompt verbatim. Whether to run `drafter refs` before a fact
  correction is exactly what the skill must teach (resolution 6, plan:85).
- Fold: state that each prompt names behavior in a developer's words and carries no section id,
  item id, fact id, item kind, field name, or drafter command. Put each prompt verbatim in its B2.5
  row so the reviewer and Geoff can check it. Reword plan:117 to "Correct a fact the blueprint
  places (the skill should send the agent to `drafter refs`)", and add a column recording whether
  the agent ran `refs` before editing.

### 5. **OWNER FORK**: does a tweak failed only by findings classified "bar defect" count against the four-of-five bar?

- Severity: **major**. Tag: `correctness`.
- Location: plan:16-17, 123, 178-179; design Outcome 4 and standing answer 3.
- Defect: the design says a tweak passes when the read "answers `ok`". The plan also has the
  executor classify each finding as blueprint gap or bar defect, and standing answer 3 handles
  findings on untouched content. It never says whether the rate uses the raw verdict or a verdict
  adjusted by the classification. B1's record shows why this matters: `s-delete`, unchanged since
  conversion, first drew a blocking finding at round 6. A scoped tweak to a clean section can draw a
  fresh finding the tweak did not cause. The executor wrote the prompts, picked the targets, and
  does the classifying, so an adjusted rate is graded by the same hand that set the test.
- Options:
  - (a) Raw only. The bar is the raw `ok` count. The classification is reported beside it and never
    changes the count. This is simple and cannot be gamed. It may send a sound format to an
    ergonomics pass over a read defect.
  - (b) Adjusted. A tweak whose every blocking finding is a bar defect counts as a pass, and the
    PR shows both rates. This is truer to "is the format too heavy", but the grader is the
    classifier.
  - (c) Raw for the decision, adjusted for the diagnosis. Raw decides standing answer 2. When raw is
    under four but adjusted reaches four, the next pass's design starts with the read, not the
    format.
- Recommendation: (c). It keeps the bar mechanical and stops a read defect from being blamed on
  the format. The plan should write it into resolution 9 either way.

### 6. The pass/fail rule for one tweak, and the per-row record, are not defined tightly enough to grade

- Severity: **minor**. Tag: `correctness`.
- Location: plan:111-114, 178-180.
- Defect: B2.5 records "the scoped read's verdict and blocking count" but never states the pass
  rule. It is implied: `drafter check` exits 0, and `drafter read` exits 0 (accepted) with zero
  blocking findings. The row also omits the scope the read actually used. If B2.1 or B2.2 computes
  the scope wrong, or the agent's commit touched a page-level field, the read silently goes whole.
  The row would still look like a scoped result, and the drafter#43 evidence would then be wrong.
- Fold: state the pass rule in those words, and say a tweak whose `drafter check` fails does not
  run the read and fails. Add "scope used (ids, or whole and why)" and "files the commit touched"
  to the row. drafter should print the computed scope to stdout or `--json`, so the executor can
  record it without reading state files. Make that print part of B2.2's acceptance.

### 7. `HEAD~1` and the revert rule disagree with "each tweak starts from rotate as merged"

- Severity: **minor**. Tag: `correctness`.
- Location: plan:113-115.
- Defect: only a failing tweak is reverted, so after a passing tweak 1, tweak 2 starts from rotate
  plus tweak 1, not "rotate as merged". `--since HEAD~1` is also wrong when the agent makes more
  than one commit, or makes none.
- Fold: before each dispatch, record the base SHA (`origin/main`'s rotate). Grade with `--since
  <base>` on the agent's final commit, require exactly one commit (record a breach otherwise), and
  `git reset --hard <base>` before every tweak, pass or fail.

### 8. Resolution 1 departs from "Scope of a redraft" while citing it, and misses moved sections

- Severity: **major**. Tag: `correctness`.
- Location: plan:49-57, 132-134 (B2.1 acceptance).
- Defect: resolution 1 says it makes structural change whole "as the architecture's 'Scope of a
  redraft'" does. That section names "a section added, removed, or moved, a level changed" as
  whole. The plan makes an added section scoped (a new id is "changed"), which tweak 5 depends on.
  It has no rule for a reordered section: each subtree is identical, so the comparison reports
  nothing changed. A level change shows up only as a scoped subtree diff. A reorder is the change
  most likely to break `requires` ordering in other sections, and under this rule it reads as
  nothing at all.
- Fold: say that a read's scope deliberately differs from a redraft's for an added section, with
  the reason (a read sees the whole blueprint anyway; only blocking is scoped), and keep tweak 5
  scoped. Make a change in section order, and a level change, whole. Add both rows to B2.1's table
  test: a reorder (whole) and a level change (whole).

### 9. An empty change set silently becomes a whole read

- Severity: **major**. Tag: `correctness`.
- Location: plan:58-60 (resolution 2), plan:145-148 (B2.2 acceptance).
- Defect: resolution 2 sets `scope` to the changed ids "and leaves it empty otherwise". An empty
  `scope` renders the unscoped prompt. So `--since <rev>` against a blueprint unchanged since
  `<rev>` (B2.1's "unchanged" row) sends a full-price whole read, which on rotate fails for the
  reason this pass exists to avoid (drafter#43). That is also the case for every unchanged
  blueprint named alongside a changed one. B2.2's acceptance tests no such case.
- Fold: define it. Either a blueprint with no changed sections since `<rev>` is skipped and
  reported as unchanged, with no API call, or the read refuses with exit 2. The first fits the
  nightly run. Add the case to B2.2's acceptance.

### 10. "Byte-identical to `9915232`'s" has no fixture that could fail

- Severity: **major**. Tag: `correctness`.
- Location: plan:63-66, 146.
- Defect: `tests/drafter-prompts-parity.sh` renders every matrix case in Node and in goja from the
  same current module and compares the two (its header comment). It proves the two renderers agree,
  not that the unscoped prompt is unchanged since `9915232`. An accidental edit to
  `blueprintPrompt()`'s unscoped text passes parity and the new matrix case alike. Resolution 2's
  claim that parity "proves" byte-identity is false.
- Fold: in B2.2, commit a golden of the unscoped blueprint prompt rendered at `9915232`, under
  `internal/pipeline/testdata` or with the fixtures. Add a Go test that renders the seat with an
  empty context and requires equality. Reword resolution 2 so parity proves only Node/goja agreement
  for the new scoped case.

### 11. The scope paragraph asks the read to judge a change it is never shown

- Severity: **minor**. Tag: `correctness`.
- Location: plan:60-64.
- Defect: the paragraph allows a blocking finding outside the listed sections "when a listed
  section's change breaks another section". The prompt carries only the current blueprint and the
  ids, not the earlier version, so the model cannot tell what changed. That clause becomes a
  judgment call that can either relax the scope (any cross-section finding touching a listed
  section) or tighten it inconsistently between runs. It is a source of noise in a five-sample test.
- Fold: either append the listed sections as they stood at `<rev>` (or their YAML diff) after the
  blueprint, or narrow the clause to what the read can see: "a listed section now fails another
  section's `requires`, or a failure item in another section now names a step that no longer
  exists". Make the B2.2 fake-API test assert whichever is chosen.

### 12. The consistency read is not scoped, and the plan does not say how its result grades a tweak

- Severity: **minor**. Tag: `correctness`.
- Location: plan:107-123; `internal/pipeline/blueprint.go:108-174`.
- Defect: `drafter read` also sends the consistency read when the project has a facts store, and a
  conflict escalates the page. Resolution 2 scopes only the blueprint seat. A pre-existing
  consistency conflict on an untouched section would fail a tweak. Neither the plan nor standing
  answer 3 says this is expected or how it is classified.
- Fold: one sentence in resolution 2: the consistency read stays whole, and a conflict on an
  untouched section is recorded under standing answer 3 as a bar defect, with the tweak's raw
  verdict unchanged (or per the owner fork in finding 5).

### 13. The `cmp` check on the installed skill always passes

- Severity: **minor**. Tag: `correctness`.
- Location: plan:175-177.
- Defect: `make install` links the skill directory with `ln -sfn` (resolution 5), so the installed
  `SKILL.md` is the worktree's file and `cmp` against itself always passes. "The skill loads live"
  names no check.
- Fold: replace both with `readlink -f ~/.claude/skills/blueprint` equal to the worktree's
  `claude/.claude/skills/blueprint`. Finding 3's transcript column then shows the skill loading,
  so drop "loads live" as a separate step.

### 14. The design's end-to-end check lost its negative half and has no observable

- Severity: **minor**. Tag: `correctness`.
- Location: plan:200-201; design "End-to-end check".
- Defect: the design asks for both halves: the rotate page gets the context, and a page with no
  blueprint gets nothing. The plan keeps only the first. It also does not say how a `claude -p`
  session shows that it "receives the hook's context", or where the edit lands, since editing
  `docs/extend/rotate-the-github-app-key.md` in cairn's main checkout would dirty it. The check
  also falls after the executor's prompt ends (plan:192) with no owner named.
- Fold: run the check in a throwaway cairn worktree. Use `claude -p --output-format stream-json
  --verbose` (or `--debug hooks`) and grep for the hook's `additionalContext` text, once for rotate
  and once for `docs/extend/migration-notes.md`, expecting it to be absent. Name the
  `conductor-drafter` session as the runner, and remove the worktree afterward.

### 15. The skill's trigger description is promised but never exercised

- Severity: **minor**. Tag: `correctness`.
- Location: plan:80-82 (resolution 6), plan:110-111.
- Defect: resolution 6 promises a description that triggers on a docs deficiency, a behavior
  change, and so on. Every format-test prompt names the skill, so triggering is never tested, and
  no other criterion tests it. Naming the skill in the prompt is right for the pilot, which
  measures the format, so the gap belongs elsewhere.
- Fold: add one prompt to the end-to-end check (finding 14): a `claude -p` session in the
  throwaway cairn worktree asked to "fix the rotate page's handling of <a real gap>", with no skill
  named, and check that the transcript shows the `blueprint` skill invoked. This is a single run
  with no API spend from drafter.

### 16. B2.3's "grep finds no restated rule" is a manual judgment presented as a mechanical one

- Severity: **minor**. Tag: `optional`.
- Location: plan:156-159.
- Defect: "`grep` finds no format rule restated … (the executor checks each rule-shaped sentence
  against the format page)" is the author grading their own prose, and grep plays no part in it.
  "`skill-creator` review raises no blocking issue" has the same weakness: skill-creator is an
  authoring tool with no defined blocking tier. Neither can fail on a fixture, and the real test
  of the skill is B2.5.
- Fold: keep the vale gate and the `make install` assertion. Replace the other two with one
  fresh-context check from the `diff-reviewer` already scheduled at Close (plan:187). Give it the
  rule "every format rule is a link by heading, never a copy" from resolution 6. That drops a
  separate skill-creator dispatch, saving about 10-15 minutes and its tokens.

### 17. B2.4's acceptance leaves the output shape and the missing-`jq` case untested

- Severity: **minor**. Tag: `correctness`.
- Location: plan:96-101, 167-169.
- Defect: resolution 7 promises valid `hookSpecificOutput` JSON and a silent exit 0 when `jq` is
  missing. The four test cases and "prints the context" do not check that the output parses, that
  `hookEventName` is `PreToolUse`, or the missing-`jq` path. A hook that prints malformed JSON
  passes "prints the context". Claude Code treats bad hook output as an error.
- Fold: in `tests/page-hook.test.sh`, pipe the managed-page output through `jq -e
  '.hookSpecificOutput.hookEventName == "PreToolUse" and (.hookSpecificOutput.additionalContext |
  contains("rotate-the-github-app-key.blueprint.yaml"))'`. Add a fifth case that runs the hook with
  a `PATH` holding no `jq` and expects exit 0 with empty output.

### 18. B2.2's lock acceptance names one branch of a two-branch rule

- Severity: **minor**. Tag: `correctness`.
- Location: plan:71-74, 147-148.
- Defect: "writes the lock only under resolution 4's condition" can pass with a test of only the
  no-write branch, which is the one rotate exercises.
- Fold: name both rows: `<rev>` blob equal to the lock's accepted blob writes the new blob, and
  unequal writes nothing and prints the one line (assert its text).

## Checked and sound

- The format test's agent configuration matches the pilot: `model: sonnet`, `effort: medium`, a
  fresh subagent per tweak with no prior tweak in context, and four of five as the bar. The fifth
  tweak (a caveat) extends the architecture's four-item list in the way the design approved.
- Grading on the scoped read instead of the whole read is Geoff's 2026-10-18 ruling (design,
  Brief), so it is not a departure from the pilot.
- The hook's path rule (plan:93-94) maps `docs/extend/rotate-the-github-app-key.md` onto
  `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml`, which exists at `50dc211d9`.
- The resume acceptance (`--since` with `--resume` exits 2; a resumed run keeps its scope) is
  concrete and can fail.

## Outside this lens, noted once

The format-test worktree will not hold cairn's ignored `drafter.local.toml` (`drafter.toml:2-3`),
which carries the key and the prompts module. The executor's `drafter read` there needs it copied
in, or the user config must cover it. That is a mechanics question for the mechanics reviewer.
