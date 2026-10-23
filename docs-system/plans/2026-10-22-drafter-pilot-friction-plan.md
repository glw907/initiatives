# drafter pilot-friction plan: markdown forms and the authoring fixes

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-22-drafter-pilot-friction-design.md`,
approved by Geoff on 2026-10-22 (glw907/initiatives#111, merge `c94cf2a`), with #42 and #43
deferred. Packet steps 1 (the merge) and 2 (the worktree cleanup) are done. This plan carries
step 3.

Path estimate: 505 minutes against the design's 420 (1.20x), inside the 840-minute standing
answer. The arithmetic is under "Path".

The planning session read drafter at `ed675bc` and cairn-cms at `0e01d37e3`. Lines move; the
executor finds each quoted symbol by name.

One `plan-reviewer` read (mechanics and feasibility) returned 2 blockers, 5 majors, and 7 minors,
all folded: the dry run reads the blueprint at HEAD and needs cairn's local prompts config, the
`:source` path rule, constraint tags in refs and the lock, drafted pages and id forms in refs, an
unknown id under `--fact`, the close estimate, the tests that encode the old track rule, the
fixture fence, the named pipeline test and doc section, SKILL.md's refs line, how a pair runs, and
the report states for `refs` and `--json`.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- drafter's main checkout is on `main`, `git status --porcelain` prints nothing, and
  `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`.
  `git check-ignore -q .claude/worktrees/x` exits 0.
- No live session other than the conductor works drafter (`claude agents --json`; rows whose
  `state` is `blocked` from before 2026-10-22 are stale and don't count).
- `go`, `golangci-lint`, and `gh` resolve, and `gh auth status` answers.
- `~/.config/drafter/cairn-cms.local.toml` exists (the close copies it into its scratch worktree).
- `DRAFTER_API_KEY` is set in the launching environment, checked by name only. Only the close's
  `drafter page --dry-run` reads it, through the free token-count endpoint.
- This plan and its two prompts are committed on initiatives `main`.

## Outcome

A markdown blueprint gains three forms: a `Code:` bullet with an optional `:source[...]` tag and
the fence below it, a `Figure:` bullet, and a `:::constraints` block. drafter maps them to `code`
and `figure` items, sends each `:source` file to the draft seat, and checks them. The `blueprint`
skill frames the reader from the outline's job and says who fixes a shared fact. `drafter check`
warns on exhaustive words, catches pointer drift and a wrong `track`, and checks one fact on
request. `drafter refs` takes several ids and lists briefs. `drafter outline` and `--version`
exist, and `drafter excerpt` serves vendor and long sources.

Risk class: `runner` (the skill's files). Every Go task is `ordinary`. No `live-account`: the
pass pushes one drafter branch and opens one PR.

## Scope guard

Every subagent prompt carries these two samples verbatim:

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary.
> Keep solutions simple and focused: - Scope: Don't add features, refactor code, or make
> "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up. A
> simple feature doesn't need extra configurability. ... - Defensive coding: Don't add error
> handling, fallbacks, or validation for scenarios that can't happen. Trust internal code and
> framework guarantees. Only validate at system boundaries (user input, external APIs). -
> Abstractions: Don't create helpers, utilities, or abstractions for one-time operations. Don't
> design for hypothetical future requirements. The right amount of complexity is the minimum
> needed for the current task."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)
>
> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself, and check
> in only when different readings of the request would lead to materially different work. If the
> request seems mistaken or a better approach exists, say so in a sentence and continue with the
> task as asked rather than quietly narrowing, widening, or transforming it. Finish the whole
> task, and stop short of actions that are clearly beyond what was asked."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)

## Shared rules

- The format doc has two copies that must stay byte-identical: `docs/blueprint-format.md` and
  `claude/.claude/skills/blueprint/format.md`. Edit one, copy it over the other.
- A pair runs as pass-core "Pairs" says: the session commits, launches both subagents in one
  message, merges each task branch into `worktree-pilot-friction`, runs `cmp` on the two format
  doc copies, and runs the gate.
- In a pair, each task edits only the format doc sections it names. If the merge still conflicts
  only in the format doc, the session resolves it by keeping both edits; a conflict in Go code
  stops the line.
- Fixtures are synthetic: no cairn path, fact id, or text in a test. The record's ids appear only
  in the PR body.
- Gate: `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` from the worktree, re-issued on exit 75.
  It wraps `make check` (vet, lint, the full suite), so the fast lane and the full-suite home are
  the same local run. drafter has no CI on PRs.
- Go follows `go-conventions` (read by path in a subagent: `/var/home/glw907/.claude/skills/go-conventions/SKILL.md`):
  stdlib assertions, table-driven tests, errors printed only in `main`.

## Tasks

### T0. Enter the worktree (5 min)

`EnterWorktree` with the name `pilot-friction`, from the drafter main checkout. Arm the API-drop
wake-up (`/loop` with no interval). Acceptance: `git branch --show-current` prints
`worktree-pilot-friction`, and the gate is green on the untouched tree.

### T1. The markdown forms and format.md's fixes (#47, #45) (150 min, runner)

Outcome: the three forms decode, project, and check as the design's "The markdown forms" says,
and the format doc teaches them. #45's three fixes land in the same file.

Files: `internal/blueprint/markdown.go`, `internal/blueprint/check.go` (the `markdown` method),
`internal/blueprint/refs.go` (`markdownRefs`), their tests (`markdown_test.go`,
`markdown_check_test.go`, `refs_test.go`), `internal/pipeline/snippets_test.go`, the fixture
`internal/blueprint/testdata/markdown/fix-a-widget.blueprint.md`, and both format doc copies.

- Decode: a bullet whose text opens `Code:` or `Figure:` (after the list marker) records its
  kind. `:source[<pointer>]` tags lift out of a line's text as `:fact` tags do, and a source
  resolves as a YAML item's `source` does (`resolveFile`, `SnippetBlocks`): from the page's
  directory, or from the repository root when it starts with `/`. Every example, in the format
  doc and the close, uses a `/`-rooted path; a `:source` on any
  other line is an error, as a misplaced `:fact` tag is. A fence directly under a `Code:` bullet,
  blank lines between allowed, attaches to it; a comment line directly above the fence is part
  of it. `:::constraints` joins `reader` and `row` as a directive, holding bullets with `:fact`
  tags allowed. Its tags join `Markdown.FactIDs`, `markdownRefs` (item id `constraints`), and so
  the lock's staleness, as the reader's do.
- `View`: a `Code:` bullet becomes kind `code` with `Source` and `Text`; a `Figure:` bullet kind
  `figure`. Item ids stay `<section id>.p<n>`. A `Figure:` bullet in the reader block is a reader
  line: its tags count toward the reader's facts, and it adds no section item.
- `CodeSources` on a `*Markdown` returns each `Code:` bullet's `:source`, in page order.
- Check errors: a fence with no `Code:` bullet above it; a second `:::constraints` block; a
  `:::constraints` block anywhere but between the reader block and the first heading. The fence
  error lives in `projectCheck.markdown`, not the decoder. The fixture's bare fence (the one that
  proves markup inside a fence is skipped) gets a `Code:` bullet above it.
- Format doc, the "Markdown blueprints" section: the forms, an example of each in the widget
  example, and the line "Code fences are skipped" replaced by the attachment rule. #45: the
  opening paragraph and "Layout" stop calling a blueprint one YAML file and show a `.blueprint.md`
  in the tree; the exit-2 line in "What `drafter check` checks" names both suffixes; the widget
  example's job line loses its trailing hinge ("Gets the reader ready, so no step fails for a
  missing role." becomes two plain statements or one without the `so` clause); and "Sections"
  says a task section may open with one lead-in line before its steps that ties the section to
  the task. "What the draft seat receives" names a markdown `Code:` bullet's `:source` beside a
  YAML `code` item's `source`.

Acceptance: the gate is green; tests cover each form decoding, a constraints tag in `refs` and
`FactIDs`, each new error firing at its line,
`CodeSources` returning the sources in order, and a markdown blueprint's draft request inlining a
`:source` file the way a YAML code item's does; the two format doc copies are identical (`cmp`).

### T2. The skill (#46, #44) (60 min, runner), pair with T3

Outcome: the `blueprint` skill frames the reader from the outline's job and teaches the new
forms, and it has a rule for parallel authors.

Files: `claude/.claude/skills/blueprint/new-page.md`, `SKILL.md`, `anatomies.md`,
`introductions.md` under the same directory. Not `format.md`.

- #46 in `new-page.md`: write the reader block from the outline entry's job and covers; a plan's
  worked example illustrates one case of that job and never narrows the reader. Cite Geoff's
  custom admin send-back (2026-10-22) as the reason, in one line.
- #44: one author owns each shared fact's correction. An author who finds a shared fact wrong
  fixes the bullet and says so in its report, and an author who sees another's fix re-verifies
  rather than reverting. Name the facts check the project runs, and say to install its
  dependencies first when it needs them (cairn's `check:facts` needs `npm ci`), as an example.
- The new forms: `anatomies.md` says where a task guide's code examples and a concept page's
  figure go, and `new-page.md`'s authoring steps say to write page-wide instructions in
  `:::constraints`, never in the reader block.

Acceptance: a fresh-context `prose-voice-reviewer` read of the diff returns no blocking finding;
each rule names the case it came from in one clause; no file restates the format doc.

### T3. Track and exhaustive-word checks (#40, #41) (75 min, ordinary), pair with T2

Outcome: a wrong `track` fails, and blueprint lines and fact bullets with unqualified exhaustive
words warn.

Files: `internal/blueprint/check.go` (`markdown`, `track`), `internal/plan/verify.go` only for the
fact-bullet warning, their tests, and the format doc's "Front matter" table and "What `drafter
check` checks" section.

- #40: when the outline declares no tracks, `track` is optional and a named track is an error
  ("the outline declares no tracks"). When it declares tracks, `track` stays required. These
  tests and fixtures encode the old rule and flip on purpose: `markdown_check_test.go`'s "any
  track name passes" and "a missing track key still fails" rows and its fixture near line 217,
  `internal/pipeline/editpass_test.go` near line 197, and `e2e/editpass_markdown_test.go` near
  line 14.
- #41: a warning, check name `exhaustive`, on a markdown blueprint's bullet, step, row, reader,
  and constraints lines, and on fact bullets in the store, for a whole word from a short list
  ("only", "every", "all", "no", "none", "never", "always", and a spelled-out or digit count
  before a plural noun). The message says the word claims a complete set and the fix says to
  check the source says so or to give examples. Words inside code spans don't count. The list is
  the executor's call; it is never an error.

Acceptance: the gate is green; table tests cover both track cases and each listed word, a word
inside a code span, and a line with none.

### T4. Pointer drift (#39) (60 min, ordinary), pair with T5

Outcome: a `path:lines` pointer whose anchor sits within the ±10-line window but off its cited
lines is a warning naming the line the anchor is on now, and a pointer skipped as commentary is
counted in the message that reports no block.

Files: `internal/plan/verify.go`, `internal/plan/facts.go` only for the commentary count, their
tests, and the format doc's "What verification skips" section.

Acceptance: the gate is green; tests cover an anchor on its cited lines (no finding), one inside
the window but off them (a warning with the new line), one outside the window (today's error), and
a parenthetical pointer counted in the message.

### T5. refs for several ids and briefs (#38) (75 min, ordinary), pair with T4

Outcome: `drafter refs <id>...` takes several ids and lists, for each, its blueprint lines, the
section each line sits in (the section a correction redrafts), each brief entry that cites it
(read from the brief at `BriefPath` for each page), and the drafted page that brief belongs to.
An id matches with or without its `f:` prefix, and a brief entry's ids may be a string or an
array. `--json` prints one array of objects, each the existing ref fields plus `id`, `section`,
and, for a brief hit, `brief`, `page`, and the sentence. The exit status keeps today's meaning per
id: it fails only when an id the store doesn't hold is named.

Files: `internal/blueprint/refs.go`, `cmd/drafter/refs.go`, their tests, the format doc's "Find
where a fact is used" sections, and the one line in `claude/.claude/skills/blueprint/SKILL.md`
that teaches `drafter refs` (T2 has landed by then, so this edit follows it).

Acceptance: the gate is green; tests cover two ids where only one has hits, an id without its
prefix, a brief entry with an array of ids, a brief found through a non-default
`blueprints.brief_path`, and an id with no references.

### T6. One-fact check, outline query, version, excerpt (#36, #37) (90 min, ordinary)

Outcome: `drafter check --fact <id>` (repeatable) checks only those facts' pointers through
`VerifyFacts`'s ids argument, resolving the `f:` prefix first, and reports an id the store
doesn't hold as an error. With `--fact`, the blueprint checks don't run. `outline --json` prints
the entry's YAML fields as a JSON object. `drafter outline <slug|path>` prints the outline entry as YAML, or
JSON with `--json`. `drafter --version` prints the build's module version, from the same
`debug.ReadBuildInfo` source `cmd/drafter/page.go` uses. `drafter excerpt` on a fact whose
sources are URLs prints each URL and its read date as a checklist and exits 0; on a prose-sourced
fact the warning says to verify it by hand or drop the claim where the project's rules exclude
prose sources; an excerpt over 200 lines prints its first 200 and a line naming the rest, unless
`--full`.

Files: `cmd/drafter/check.go`, `cmd/drafter/outline.go` (new), `cmd/drafter/root.go`,
`cmd/drafter/excerpt.go`, `internal/assemble/excerpt.go` only if the warning text lives there,
their tests, the format doc sections that name these commands (`docs/setup.md` too if it
lists commands), and the `SKILL.md` line that would name the one-fact check.

Acceptance: the gate is green; tests cover each command and flag above.

### C. Close (110 min)

1. Backlog: tick #36 to #41 and #44 to #47 with the PR number; move #42 and #43 to Medium with a
   line citing Geoff's deferral (2026-10-22).
2. The end-to-end check, in a scratch cairn worktree that is removed after, never pushed:
   `git -C /var/home/glw907/Projects/cairn-cms worktree add --detach <scratch dir> origin/main`,
   then `cp ~/.config/drafter/cairn-cms.local.toml <scratch dir>/drafter.local.toml` (cairn's
   `.gitignore` ignores it), and check `drafter config` there names `prompts` from
   `drafter.local.toml`. Rewrite `blueprints/docs/extend/add-a-custom-admin-screen.blueprint.md`
   to the new forms with `/`-rooted sources, drop its `track` line, and commit it on the detached
   HEAD, because `drafter page` reads the blueprint at HEAD. The worktree build of drafter (`go
   build -o <scratch>/drafter ./cmd/drafter`) then shows `check` reporting no error for that
   file; `refs` with two of its ids listing its lines, the cairn brief, and the page; and `page
   --dry-run` on it exiting 0 with a request size larger than the same run on a commit with the
   `:source` tags removed. T1's pipeline test is the direct proof of inlining; the size
   difference shows it on a real page. Record the outputs in the PR body, then remove the
   worktree.
3. Whole-branch `diff-reviewer` against the design and this plan, one batched fix chain, the gate
   again.
4. drafter `docs/STATUS.md`: the pass at PR-ready, and the next action (the next fifteen cairn
   blueprints start from the merged skill) for conductor-drafter to finish after the merge.
5. Open the PR on glw907/drafter from `worktree-pilot-friction` with `## Brief`, what landed, the
   end-to-end outputs, `## Decisions`, `## Planning misses`, the found-not-done list, and the
   score. Stop at PR-ready and message conductor-drafter.

## Path

T0 5 + T1 150 + pair (T2 60, T3 75) 75 + pair (T4 60, T5 75) 75 + T6 90 + C 110 = 505
minutes. The task sum is 625. The design's estimate was 420, so the path is 1.20x.

## Standing answers

1. A clock stop writes its minutes to STATUS, rewrites `start=`, and carries on while the actual
   path stays under 840 minutes. Past 840 the executor stops and the conductor asks Geoff.
2. No API credit: never `make smoke`, and `drafter page` only with `--dry-run`. If the dry run
   can't run (a key or a config the scratch worktree lacks), the close records why and relies on
   T1's inlining test.
3. A review finding that a design form could satisfy with a smaller change takes that change and
   lists it in `## Decisions`. Only a finding that needs a different form stops.
4. A format-doc-only merge conflict in a pair is resolved by the session keeping both edits.
5. A cause that returns after its fix gets one structural fix, then escalates in the PR body. Any
   of T4, T5, or T6 can be escalated that way without breaking the outcome; T1 and T2 cannot.

## Merge order and hand-over

One PR. conductor-drafter sends one packet (the PR, its `## Decisions`, and the end-to-end
outputs), merges on Geoff's approve with `--match-head-commit`, pulls the main checkout, runs
`make install` in it so `~/.local/bin/drafter` is the merged build, files
one cairn-cms backlog item through `log-issue` ("Move the three pilot blueprints to the markdown
forms and drop `track: extend`", tagged `#initiative:docs-system`), and lands the STATUS
hand-over.
