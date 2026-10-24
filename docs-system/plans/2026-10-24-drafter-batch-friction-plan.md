# drafter batch-friction plan: the store checks, the lint, and the authoring fixes

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-24-drafter-batch-friction-design.md`,
approved by Geoff on 2026-10-24 (glw907/initiatives#118, merge `80411c0`). Packet step 1 (the
merge) is done. This plan carries step 2.

Path estimate: 600 minutes, inside the design's 1000-minute standing ceiling. The design set the
ceiling and no estimate of its own; at twice an estimate, the ceiling implies 500, so the path is
1.20x. The arithmetic is under "Path". The last pass ran its 505-minute path in about 40 minutes
of wall clock, so the ceiling is a guard, not a forecast.

The planning session read drafter at `a1fc918` and cairn-cms at `origin/main` and
`origin/ebp3-configure-media`. Lines move; the executor finds each quoted symbol by name.

One `plan-reviewer` read (mechanics and feasibility) returned 1 blocker, 8 majors, and 13 minors,
all folded. Among them: the skill's `format.md`, `anatomies.md`, and `introductions.md` are
symlinks; T2 and T3 shared `ExhaustiveClaim`; two stated mechanisms would have made import cycles;
batch request counts don't move until a batch ends; the fallback config layer can set the key
source; and the close named a blueprint that isn't on cairn `main`. Two findings narrow the
design, and the PR's `## Decisions` records both. A crossLink to a `managed: false` page already
resolves in drafter: the record's two misfires were pages cairn's outline doesn't list. And
yaml.v3 reports a line, never a column, for #70.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- drafter's main checkout is on `main`, `git status --porcelain` prints nothing, and
  `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`.
  `git check-ignore -q .claude/worktrees/x` exits 0.
- No live session other than the conductor works drafter (`claude agents --json`). The
  `drafter-blueprint-first-design` row in state `blocked`, started before 2026-10-22, is stale and
  doesn't count. A session running `drafter page` in a cairn-cms worktree doesn't work drafter.
- `go`, `golangci-lint`, and `gh` resolve, and `gh auth status` answers.
- `~/.config/drafter/cairn-cms.local.toml` exists (the close reads it through the T6 fallback).
- `git -C /var/home/glw907/Projects/cairn-cms ls-remote origin ebp3-configure-media` prints a ref.
- `DRAFTER_API_KEY` is set in the launching environment, checked by name only. Only the close's
  one `drafter status` call reads it, a free batch lookup.
- This plan and its two prompts are committed on initiatives `main`.

## Outcome

`drafter check` warns on an anchorless line pointer and checks doc-comment anchors, dotted
pointers, route paths, and figure sources. The exhaustive lint drops `no` and `never`, skips
`:::constraints`, and reports every match at its own line. A named check skips the outline-wide
checks. `See` bullets with trailing text count as links, and a cross-page anchor resolves against
the target's blueprint. `:source[...]` takes one level of brackets, a second `:source` warns, and a
`Figure:` bullet takes a fence. `drafter refs` reads briefs of pages with no blueprint, lists
links into a page, and names each fact's source kind. `drafter page` prints batch status, and
`drafter status <run-id>` reports open batches. A worktree finds its local config under
`~/.config/drafter`, and an outline YAML error names its line. The `blueprint` skill carries #51
to #58, #75 to #77, and #80.

Risk class: `runner` (the skill's files). Every Go task is `ordinary`. T6 adds a config file that
can set the key source and money caps; it lives in the user config directory and has exactly the
user layer's exposure, so it adds no new reach and stays `ordinary` (pass-core: only Geoff's
ruling raises a class). No `live-account`: the pass pushes one drafter branch and opens one PR.

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

- In `claude/.claude/skills/blueprint/`, `format.md` is a symlink to `docs/blueprint-format.md`,
  and `anatomies.md` and `introductions.md` are symlinks into `stock/`. Edit the targets, never
  the links; `tests/install.test.sh` depends on them. The `stock/` files are also seat inputs
  embedded in the binary (`stock/stock.go`), so every link in them must resolve from `stock/`.
- Go tasks T1 to T6 leave `docs/blueprint-format.md` untouched and list each rule they change in
  their commit message under a `Format doc:` line. T7 writes every such rule into the doc. This
  keeps the pairs free of doc conflicts.
- `docs/configuration.md`, `docs/setup.md`, and `README.md` are edited only by the tasks that name
  them: `configuration.md` by T2 and T6, `setup.md` by T6, `README.md` by T4 (the `refs` usage)
  and T5 (a `status` section). T4 and T5 touch different sections of `README.md`; a merge that
  conflicts there takes both edits.
- A pair runs as pass-core "Pairs" says: the session commits, launches both subagents in one
  message, merges each task branch into `worktree-batch-friction`, and runs the gate. A mechanical
  conflict (imports, adjacent additions, `README.md` sections) is resolved by keeping both sides
  and re-running the gate. Only a semantic conflict in Go code stops the line.
- Fixtures are synthetic: no cairn path, fact id, or text in a test. The record's ids appear only
  in the PR body.
- Gate: `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` from the worktree, re-issued on exit 75.
  It wraps `make check` (vet, lint, the full suite, `tests/install.test.sh`), so the fast lane and
  the full-suite home are the same local run. drafter has no CI on PRs.
- Go follows `go-conventions` (read by path in a subagent:
  `/var/home/glw907/.claude/skills/go-conventions/SKILL.md`): stdlib assertions, table-driven
  tests, errors printed only in `main`.

## Tasks

### T0. Enter the worktree (5 min)

`EnterWorktree` with the name `batch-friction`, from the drafter main checkout. Arm the API-drop
wake-up (`/loop` with no interval). Acceptance: `git branch --show-current` prints
`worktree-batch-friction`, and the gate is green on the untouched tree.

### T1. The decoder (#61, #50, #49) and the figure-source check (60 min, ordinary)

Outcome: a `:source[...]` path may hold one level of brackets, a second `:source` on one bullet
warns, a `Figure:` bullet takes a fence, and a figure's source is checked for existence.

Files: `internal/blueprint/markdown.go` (`sourceTag`, `MDLine`, the fence handling, `View`),
`internal/blueprint/check.go` for the fence rule, `internal/plan/check.go` (`codeSource` and the
item-kind switch that calls it), and their tests.

- #61: `sourceTag` (today `` `\s*:source\[([^\]\s]+)\]` ``) becomes
  `` `\s*:source\[((?:[^\[\]\s]|\[[^\[\]\s]*\])+)\]` ``, which reads `[token]` and `[...path]`
  segments one level deep and still splits two tags on a line. RE2 can't match brackets to any
  depth; a nested `[[opt]]` stays out of scope and is stated in the format doc's rule.
- #50: a bullet with a second `:source` tag keeps the first and gets a warning naming the dropped
  path. The decoder's `add` makes errors only today, so it gains a warning path, or the warning
  is raised in `projectCheck.markdown` from the raw line; the executor picks the smaller.
- #49: the decoder keeps a fence's lines today only to skip them. A fence directly below a
  `Figure:` bullet attaches to it as one below `Code:` does, and its body goes in a new `MDLine`
  field. The "fence with no `Code:` bullet above it" error accepts either label. `View` appends
  the fence body to the figure item's text.
- The figure-source check: `codeSource` in `internal/plan/check.go` checks a `code` item's source
  exists; a `figure` item with a `Source` takes the same check.

Acceptance: the gate is green; tests cover a `[token]` and a `[...rest]` source, two tags on one
line, a second tag's warning, a `Figure:` bullet with a `repro` fence decoding to a figure item
that carries the fence, a missing figure source erroring, and a bare fence still erroring.

### T2. The check lints (#48, #62, #63, #64, #65, #74) (120 min, ordinary), pair with T3

Outcome: the lint and link checks stop the misfires the batches logged, and the length warning
exists.

Files: `internal/plan/exhaustive.go`, `internal/blueprint/check.go` (`Check`, `exhaustive`,
`blueprintData`), `internal/plan/check.go` (`CheckOptions`, `link`), `internal/plan/check_test.go`
or a new test file, `internal/blueprint/markdown.go` only for `seeLink`, `cmd/drafter/check.go`
(`projectFor`), `internal/config/sources.go` (`settingKeys`), `internal/config/layer.go`
(`allowedIn`), `docs/configuration.md`, and their tests. Never `internal/plan/verify.go`.

- #48: `exhaustiveWord` loses `no` and `never`. `exhaustive` stops reading the `:::constraints`
  block.
- #62: add `ExhaustiveClaims(text) []string`, every match on the line, and keep
  `ExhaustiveClaim` as the wrapper returning the first, so `verify.go:176` compiles unchanged.
  The blueprint lint reports each match as its own finding. Fact bullets stay first-match this
  pass; the PR's `## Decisions` says so. A `:::row` block's lines are scanned from the row's
  opening line plus one up to its `:::`, as the reader block is today, so each part's finding sits
  on its own line. No decoder change.
- #63: on a named check, `Check` skips `outlineChecks()` as it already skips `pairing` and
  `convention`, and runs `pageType` for each named page alone. A crossLink finding filed under a
  named blueprint stays, since it is that page's.
- #64: a new setting, `check.sentence_words`, an integer, default 0 (off), allowed in the project
  and local layers. It reaches the check through a `Project` field set in `projectFor`. When set,
  each sentence of a markdown blueprint's bullets, steps, row lines, and reader and constraints
  lines over that many words gets a `sentence-length` warning naming the count. Fact bullets are
  never checked. A code span counts as one word. `docs/configuration.md` documents the key.
- #65: the first half needs no change. A crossLink to a `managed: false` page already resolves
  (`loadOutline` adds every page to the outline's paths and slugs), and a test pins it. The
  record's misfires came from pages cairn's outline doesn't list, which goes in the PR's
  found-not-done list as a cairn-cms item. The second half: `CheckOptions` gains an anchors hook
  (for example `Anchors func(rel string) (map[string]bool, bool)`) that `blueprintData` fills
  from a target page's blueprint headings. `link` checks a `page.md#anchor` against that set when
  the target has a blueprint, and against the published page only when it has none. The hook
  avoids an import of `internal/blueprint` from `internal/plan`, which would be a cycle.
- #74: `seeLink` already accepts an `#anchor`; it gains trailing text after the link's closing
  parenthesis, so `See [text](target#a) for the X case.` is a link item.

Acceptance: the gate is green; tests cover a line with three matches (three findings), a row part
on its own line, `no` and `never` passing, a constraints line passing, a named check skipping an
outline types fault on a type no named page uses, the same check unnamed reporting it, the length
warning off by default and firing at a limit, a `managed: false` crossLink resolving, an anchor
a target's blueprint adds, and a `See` bullet with trailing text and an anchor.

### T3. The store checks (#59, #79, #60, #71, #72) (120 min, ordinary), pair with T2

Outcome: an anchorless line pointer warns, the skipped pointer shapes are checked, a tag note's
code spans are pinned as commentary, and a `node_modules` pointer excerpts.

Files: `internal/plan/verify.go`, `internal/plan/facts.go` if the pointer parse lives there,
`internal/plan` for the ported nested resolver, `internal/assemble/excerpt.go`, and their tests.
Never `internal/plan/exhaustive.go` or `internal/blueprint/check.go`.

- #59 and #79: in the line verifier, a `path:N` or `path:N-M` pointer with no anchor is a warning:
  "pointer %q has no anchor, so drift can't be detected", fix "add the symbol on those lines in
  backticks and parentheses after the pointer". Keep `anchorWindow` and its error unchanged:
  `verify.go`'s header says the window matches cairn's `check-facts.mjs`, so a store that gate
  passes raises no drafter error. The existing off-the-cited-lines warning already reads the
  span exactly.
- Pilot record item 6: `sourcePointers` reads a pointer at parenthesis depth 1 as it does at
  depth 0; bracket depth stays skipped, and `pointerAnchorRe` is unchanged. A pointer written
  `` `a.ts:1-9` (`Name`: prose) `` keeps no anchor, as today, so it still warns.
- #60: a `#name` anchor check reads the declaration with its doc comment above it. A dotted
  `#Outer.inner` pointer is verified instead of skipped. `internal/assemble` imports
  `internal/plan`, so verify.go can't call excerpt.go's resolver: port the nested resolver into
  `internal/plan` beside `declarationSpan`, or move it there and have `internal/assemble` call
  it; the executor picks the smaller diff. A route path (`[`, `]`, `(`, `)`, `+`) is checked:
  `strictPathRe` widens to `pathCharsRe`'s alphabet, the one `drafter excerpt` uses. `verify.go`'s
  header comment says these paths are now checked here and skipped by cairn's `POINTER_RE`.
- #71: no behavior change. A test pins that a code span inside a tag note (``[verified: ran `x`
  ...]``) is not read as a pointer.
- #72: `drafter excerpt` and the `no-excerpt` check read a pointer under `node_modules` from disk
  when the file exists. The excerpt's label is "read from disk: untracked", which must not begin
  "no excerpt:", the prefix `noExcerpt` counts as missing.

Acceptance: the gate is green; tests cover an anchorless range (warning), an anchored one in place
(no finding), a pointer at parenthesis depth 1 read, a doc-comment anchor, a dotted pointer
verified and one whose inner name is missing, a `+page.ts` route path under a `[token]` directory,
a tag-note code span, and a `node_modules` excerpt that `noExcerpt` doesn't count.

### T4. refs (#66, #67, #68, #78) (90 min, ordinary), pair with T5

Outcome: `drafter refs` reads every brief, lists links into a page, and names each fact's source
kind.

Files: `internal/blueprint/refs.go`, `cmd/drafter/refs.go`, `README.md` (the `refs` usage), and
their tests.

- #67 and #78: `RefHits` reads the brief of every outline page with a brief file, not only pages
  with a blueprint, so a published page's brief citations count before its blueprint exists. The
  `(example)` label on a plain bullet becomes `(bullet)`, the word `format.md` uses; a row keeps
  `(row)` if it has its own label, and otherwise also reads `(bullet)`.
- #66: `drafter refs --page <path|slug>` lists each blueprint `See` or link item and each outline
  `crossLinks` entry whose target is that page, with file and line. `Args` changes so `--page`
  runs with no ids; `--page` together with ids is a usage error (exit 2). `--json` prints an array
  of `{file, line, kind}`. It exits 0 with no hits, and 1 when the outline lists no such page.
- #68: each fact in `drafter refs` output carries its source kinds: `code` for a `Source:` pointer
  that is a repository path, `url` for a URL (read from the bullet's raw text, since `Fact.Sources`
  leaves URLs out), and `prose` for a pointer under `facts.prose_sources` or to a `.md` file. A
  fact with several kinds prints them all, comma-separated. `facts.prose_sources` reaches `refs`
  the way `check` gets its project settings. Plain output prints the kinds after the id, and
  `--json` adds `source_kinds`.

Acceptance: the gate is green; tests cover a brief hit on a page with no blueprint, `--page` with a
link item and a crossLink, `--page` with an id (usage error), an unknown page, and each source
kind, including a fact with two.

### T5. Batch status (#81) (120 min, ordinary), pair with T4

Outcome: a polling `drafter page` or `drafter read` prints each batch's status as it waits, and
`drafter status <run-id>` reports each open batch.

Files: `internal/batch/types.go` (`Batch`), `internal/batch/calls.go` (`batchOf`),
`internal/run/state.go` (the intent beside `BatchID`), `internal/pipeline/money.go` (`await`,
`waitEnded`), `cmd/drafter/status.go` (new), `cmd/drafter/root.go`, `README.md` (a `status`
section), and their tests. Never `internal/pipeline/fingerprint.go`.

- `Batch` gains `Status` (the API's `processing_status`) and request counts (processing,
  succeeded, errored, canceled, expired). `batchOf` fills them. The API moves requests out of
  `processing` only when the whole batch ends, so mid-batch the useful facts are the status and
  the age.
- The intent gains an optional `poll` field (last status, counts, time seen) with `omitempty`.
  `LoadState` checks only the schema number, and the fingerprint reads only config, so a state
  file written by today's build loads and resumes unchanged. Only `await` writes `poll`; it prints
  on the first poll of an intent and then only on a change:
  `batch <id> (<page>): <status>, waiting since <created time>`, with the counts once the batch
  ends. `waitEnded` runs inside the adoption loop over candidate batches that may belong to other
  runs, so it prints the same line and writes nothing.
- `drafter status <run-id>` reads the run's state from `<state_dir>/runs/<run.Repo(root)>/<run-id>/`
  without taking `run.lock`, since the run may be live. It calls `Get` with the configured key for
  each intent whose batch has not been read, and prints its status, age, and counts. A missing run
  directory, a malformed state, or a wrong schema exits 2, as `cmd/drafter/main.go` defines exit
  2. An API error prints its type and message (billing, rate limit, authentication) and also
  exits 2, since drafter could not answer. A run with no open batch prints "no open batch" and
  exits 0. `--json` prints one object per batch.
- The poll line's first print and `drafter status` both name `--sync` once, as the way to run
  attended without a batch wait.

Acceptance: the gate is green; tests against the fake batch server cover a first poll printing, a
second and third unchanged poll printing nothing, the end printing with counts, a state file
without `poll` loading and resuming, and `drafter status` on an open batch, an ended run, a
missing run, and an API error.

### T6. Config fallback and the outline YAML error (#69, #70) (45 min, ordinary)

Outcome: a worktree with no `drafter.local.toml` reads the user-scope copy, and an outline parse
error names its line.

Files: `internal/config/load.go` (`Load`, `readProject`), `internal/config/layer.go`,
`internal/config/validate.go` (`RefusedStock`), `cmd/drafter/outline.go`, `cmd/drafter/pagebp.go`,
`cmd/drafter/read.go`, `docs/configuration.md`, `docs/setup.md`, and their tests.

- #69: when the project has a `drafter.toml` and no `drafter.local.toml`, `Load` reads
  `<UserConfigDir>/drafter/<repo>.local.toml` as the local layer. `<repo>` comes from the rule
  `run.Repo` already uses (`internal/run/id.go`): the base name of the main checkout, from
  `git rev-parse --path-format=absolute --git-common-dir`. Reuse that function or its rule; a git
  failure or a root outside git means no fallback and no error. The layer carries the `inLocal`
  bit, so it may set the keys a `drafter.local.toml` may (the key source, `api_base_url`,
  `workspace_id`, and the caps) and ranks above the user config, as `drafter.local.toml` does.
  The git-ignore check doesn't apply, since the file is outside the repository. Its label in
  `drafter config` is its path. `readLayer` resolves a relative path in it from
  `~/.config/drafter`, and `docs/configuration.md` says so. `RefusedStock`'s text names both
  paths it looked at; the e2e tests match it with `strings.Contains`, so the addition is safe.
- #70: the three sites that call `DecodeOutline` directly (`cmd/drafter/outline.go`,
  `pagebp.go`, `read.go`) print the first error finding's `file:line: message` instead of "is
  malformed" alone. `pagebp.go` discards the findings today (`o, _ :=`) and stops discarding them.
  yaml.v3 reports a line and no column; the PR's `## Decisions` says so.

Acceptance: the gate is green; tests cover a real `git worktree add` of a sandbox repo, under a
sandboxed `XDG_CONFIG_HOME`, reading the fallback named for the main checkout; a project
`drafter.local.toml` winning over it; a non-git root reading no fallback; the error naming both
paths; and an outline YAML error carrying its line at each of the three sites.

### T7. The skill and the format doc (#51 to #58, #75 to #77, #80) (120 min, runner)

Outcome: the skill carries the batches' fixes, and the format doc states every rule T1 to T6
changed.

Files: `claude/.claude/skills/blueprint/SKILL.md` and `new-page.md`; the symlink targets
`docs/blueprint-format.md`, `stock/introductions.md`, and `stock/anatomies.md`. The review steps
#53 to #55 name live in `SKILL.md`'s review section; there is no `review.md`.

- From the commits' `Format doc:` lines: the new `sentence-length` and anchorless-pointer rows in
  "What `drafter check` checks", the `exhaustive` row without `no`, `never`, or constraints, the
  `See` bullet's trailing text, `:source` brackets one level deep, the `Figure:` fence, tag-note
  code spans as commentary (#71), and `refs --page` and source kinds.
- #80: that table marks which rows apply to a markdown blueprint and which are YAML-only.
- #75: `stock/anatomies.md`'s `../docs/blueprint-format.md` resolves from `stock/` and breaks only
  through the skill symlink; it becomes the GitHub URL `stock/introductions.md` already uses,
  which resolves from both. `introductions.md`'s link stays. The PR's `## Decisions` records why
  neither becomes `format.md`. `format.md` says a `:fact` tag on a `Code:` bullet counts as a
  citation.
- #56: a table in a markdown blueprint is a GFM pipe table under a lead-in bullet that carries the
  table's `:fact` tags. The decoder keeps a pipe table as text that reaches the draft request, and
  a tag on a table line is an error today, so the doc names that form and adds none. Also: a
  command and its output as two `Code:` bullets, when `Code:` may omit `:source`, `:::row`
  outside symptom pages, and explanation bullets before a lead-in.
- #57: one sentence in `stock/introductions.md` and `new-page.md` says how the reader block's
  background differs from `:::constraints` (reader-facing framing against drafter-facing
  instruction), and the two agree. A change to `stock/introductions.md` changes what seats
  receive after install; no golden inlines it.
- #51: a premise step before step 1 of `new-page.md`: who has work the scaffold, tutorial, or a
  reference page doesn't cover; when the case is weak, write a fold recommendation and file it.
- #52: a folded section whose target page has no blueprint takes a whole-page blueprint, queued
  with notes pointing at the section.
- #53: run the project's register editor (cairn's is `cairn-register-editor`) and apply its
  rewrites before the fact-check and before queueing.
- #54: trace an engine-intent question through code, specs, and history before raising it; send
  Geoff only product, taste, and scope.
- #55: a settle step's fix line meets the exhaustive-word rule, and a finding that returns twice
  takes a structural rewrite.
- #58: how an exemplar name resolves (the local config's `inline_files`, and the T6 fallback),
  the project's mint command for new ids, that a fact correction is an exact in-place
  substitution with the Edit tool and never an append (#80), and to find facts by grepping each
  id the plan cites.
- #76: a recipe for a generated example: name the script or command that produced it with a
  `:source` on the script, so a fact-checker can rerun it.
- #77: when a page's `covers` narrows, reword the neighbors' `outOfScope` lines that route to it.

Acceptance: the gate is green (it runs `tests/install.test.sh`); `test -L` holds for the skill's
`format.md`, `anatomies.md`, and `introductions.md`; this loop, run from
`claude/.claude/skills/blueprint`, prints nothing:

```bash
for f in *.md; do d=$(dirname "$(readlink -f "$f")"); grep -o '](\([^)#]*\)' "$f" | sed 's/^](//' | grep -v '^https\?:' | while read -r p; do [ -z "$p" ] || test -e "$d/$p" || echo "$f: $p"; done; done
```

and a fresh-context `prose-voice-reviewer` read of the diff returns no blocking finding; each
rule names its case in one clause; no skill file restates the format doc.

### C. Close (120 min)

1. Backlog: tick #48 to #81 except #73 with the PR number, and #73 as superseded by #81. #42,
   #43, and #82 stay open.
2. The end-to-end check, in a scratch cairn worktree that is removed after, never pushed. The
   design's blueprint, configure-media, is on `origin/ebp3-configure-media` only, not on cairn
   `main`:
   - `git -C /var/home/glw907/Projects/cairn-cms fetch origin` and
     `git -C /var/home/glw907/Projects/cairn-cms worktree add --detach <scratch dir> origin/ebp3-configure-media`.
   - `go build -o <scratch>/drafter ./cmd/drafter` from the pass worktree. Every command below
     runs as `<scratch>/drafter` from `<scratch dir>`.
   - `drafter config` names `prompts` from `~/.config/drafter/cairn-cms.local.toml`: the T6
     fallback, with no `drafter.local.toml` in the worktree.
   - `drafter check blueprints/docs/extend/configure-media.blueprint.md` prints no
     outline-wide finding and no `exhaustive` finding on a `:::constraints` line. Its own
     crossLink to `docs/reference/sveltekit.md` may still warn; that finding is the page's.
   - `drafter check --fact f:aj5c4z --fact f:sz71ur --fact f:7ak73t --fact f:9ro4u5 --fact
     f:n07oiu --fact f:hkh101` prints the "has no anchor" warning for each of the six. Another
     warning on a fact doesn't count toward it.
   - `drafter refs --page configure-media` lists the outline crossLinks into the page.
   - `drafter status 20261024T080412Z-13b5d021` reports that run's batches. `run.Repo` resolves
     to `cairn-cms` from the scratch worktree, so it never enters the live run's worktree.
   - The design's bracketed-route `:source` has no live fixture, since configure-media has no
     bracketed source; T1's test stands in, and the PR says so.
   - Record the outputs in the PR body, then `git worktree remove` the scratch worktree.
3. Whole-branch `diff-reviewer` against the design and this plan, one batched fix chain, the gate
   again.
4. drafter `docs/STATUS.md`: the pass at PR-ready, and the next action (the last nine extend
   pages start from the merged skill; #82 is the next drafter pass) for conductor-drafter to
   finish after the merge.
5. Open the PR on glw907/drafter from `worktree-batch-friction` with `## Brief`, what landed, the
   end-to-end outputs, `## Decisions` (at least: fact bullets first-match, #65's first half, the
   #75 links, yaml.v3's line-only error, the `:source` bracket depth), `## Planning misses`, the
   found-not-done list (at least the cairn outline's unlisted pages), and the score. Stop at
   PR-ready and message conductor-drafter.

## Path

T0 5 + T1 60 + pair (T2 120, T3 120) 120 + pair (T4 90, T5 120) 120 + T6 55 + T7 120 + C 120 =
600 minutes. T6 rises to 55 for the worktree fixture and the third call site, and the close to 120
for the scratch steps. The task sum is 810.

## Standing answers

1. A clock stop writes its minutes to STATUS, rewrites `start=`, and carries on while the actual
   path stays under 1000 minutes. Past 1000 the executor stops and the conductor asks Geoff.
2. No API credit: never `make smoke` or `make live`, and `drafter page` only with `--dry-run`. The
   one live call is the close's `drafter status`, a free lookup. If it can't run (no key, or the
   run directory is gone), the close records why and relies on T5's fake-server tests.
3. A review finding that a design form could satisfy with a smaller change takes that change and
   lists it in `## Decisions`. Only a finding that needs a different form stops.
4. A cause that returns after its fix gets one structural fix, then escalates in the PR body. Any
   item in T3's #60, T4's #68, T2's #65 anchors hook, or T7's #56 can be escalated that way
   without breaking the outcome. T1, T2's #48 and #63, T5, and T6 cannot. If one of those still
   fails after its structural fix, the remaining tasks and the close still run, and the PR
   reports the item unmet in its Brief; the conductor's packet raises it as a `gate-failed` ask.
5. The install waits for the live run. The pass never runs `make install`. After the merge, the
   conductor checks run `20261024T080412Z-13b5d021` with the merged build's `drafter status`. While
   a batch is open it skips the install and writes "install waits on run
   20261024T080412Z-13b5d021" into STATUS's next action. The install is on this host (pavilion);
   thinkpad-x1 picks the build up at its next pull and `make install`, which STATUS says.

## Merge order and hand-over

One PR. conductor-drafter sends one packet (the PR, its `## Decisions`, and the end-to-end
outputs), merges on Geoff's approve with `--match-head-commit`, pulls the main checkout, and runs
`make install` there under standing answer 5, so `~/.local/bin/drafter` and the skill link are
the merged build. It files one cairn-cms backlog item through `log-issue`: "Set
`check.sentence_words = 26` in `drafter.toml`, and list `docs/reference/sveltekit.md` and
`choose-an-ai-posture` in the outline as `managed: false`", tagged `#initiative:docs-system`. It
appends to cairn-cms #38 one line naming drafter's rule: a tag note's code spans are commentary,
never pointers. Then it lands the STATUS hand-over.
