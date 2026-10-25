# drafter batch 4 friction plan: the anchor ratchet, the new checks, and the drafting commands

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-25-batch-4-friction-design.md`,
approved by Geoff on 2026-10-25 (glw907/initiatives#138, merge `17746d6`). This plan carries the
design's drafter pass: drafter backlog #83 to #109 and the blueprint skill's line telling a
session to run `approval-queue pending` first. The approval-queue pass has a separate plan and
conductor.

Path estimate: 660 path minutes against the design's 500 (1.32x), inside the 1000-minute
standing ceiling and under twice the estimate. The arithmetic is under "Path". The last two
drafter passes ran 600- and 505-minute paths in about 35 minutes of wall clock each, so the
ceiling is a guard, not a forecast. The mechanics review's fold (2026-10-25) is recorded at
`~/Projects/initiatives/docs-system/research/2026-10-25-drafter-batch-4-friction-plan-fold.md`.

The planning session read drafter at `e41695fc89dcdca170bdd7bb5450efde4066367c`, cairn-cms at
`origin/main` (fetched 2026-10-25), and cairn-pub at `85c97cc`. Lines move; the executor finds
each quoted symbol by name.

Three findings bear on the design's wording, and the plan takes the reading each one forces:

- #102's "task-guide anatomy item 5" isn't in drafter. The skill's `anatomies.md` links
  `stock/anatomies.md`, whose task guide has three sections and no failure path
  (`stock/anatomies.md:58-63`). The item is cairn's register: `docs/internal/docs-register.md:791-793`
  ("5. Failure paths that point at the track's recovery surface ... `extend/debug-your-site.md`").
  Under the design's rule that cairn changes go to cairn's `BACKLOG.md`, the conductor files it
  there, and drafter #102 closes as moved. The planning session ruled this reading on 2026-10-25,
  and the PR's `## Decisions` records it.
- The workstation prompts module is a drafter file. `~/.claude/workflows/docs-page-chain.js` is
  a symlink to `/var/home/glw907/Projects/drafter/claude/.claude/workflows/docs-page-chain.js`,
  which drafter's `make install` writes (`Makefile`, `install` target), and cairn's local layer
  (`~/.config/drafter/cairn-cms.local.toml`, `prompts = "~/.claude/workflows/docs-page-chain.js"`)
  reads it. Its `bpMarkdownReading` (`docs-page-chain.js:2591`) is where cairn's notice line
  goes. This corrects the design's premise that the line needs a workstation backlog item: the
  design's "the drafter pass touches drafter only" covers the file, so T4 adds the sentence there
  beside the stock prompt's, and no workstation item is filed. The PR's `## Decisions` records it.
- The design's "`drafter page --commit` against a fake API server" runs in drafter's e2e harness
  (`e2e/draft_test.go`, `newDraftEnv` points `api_base_url` at an `httptest` stub), not in the
  cairn scratch worktree. A cairn page run needs cairn's prompts module, its npm docs gate, and a
  stub shaped to a real page. The other e2e legs run on cairn as designed. The PR's `## Decisions`
  records it.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- drafter's main checkout is on `main`, `git status --porcelain` prints nothing, and
  `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`.
  `git check-ignore -q .claude/worktrees/x` exits 0, and `.claude/worktrees/batch-4-friction`
  doesn't exist. The `docs-friction` and `sendback-revisions` worktrees are merged leftovers, not
  live work.
- No live session other than the conductor works drafter (`claude agents --json`). The
  `drafter-blueprint-first-design` row in state `blocked` is stale and doesn't count. The planning
  session (`drafter-ce`, interactive, cwd the drafter checkout) counts only if it still edits
  drafter; it edits nothing after the hand-off. A session running `drafter page` in a cairn-cms
  worktree (batch 5's `drafter page --whole docs/extend/configure-media.md` today) doesn't work
  drafter.
- `go`, `golangci-lint`, `gh`, `node`, and `cairn-run-gate` resolve, and `gh auth status` answers.
- `git -C /var/home/glw907/Projects/cairn-cms fetch origin` succeeds, and
  `git -C /var/home/glw907/Projects/cairn-cms cat-file -e origin/main:blueprints/docs/extend/arrange-the-admin-sidebar.blueprint.md`
  exits 0 (the close's e2e names that blueprint).
- This plan and its two prompts are committed on initiatives `main`.

No API key is needed: nothing in this pass calls the API. The e2e harness carries a test
`DRAFTER_API_KEY` and config under a temporary `XDG_CONFIG_HOME`.

## Outcome

A named `drafter check` verifies the facts its blueprints cite, and an anchorless line pointer
among them is an error whose message names the anchor to paste. The unnamed run, `--fact`, and
`drafter gate` keep that a warning. The store check reads a `#decl` anchor from the declaration
lines only, gives a drifted anchor a line that holds the whole anchor, skips a missing path on an
`[external]` fact, and reads `` (`symbol`: more text) `` as an anchor.

New checks: three procedure warnings, stale backticked names in `covers`, links into anchors a
named blueprint dropped, and a drafted page whose links, steps, or snippets drifted from its
blueprint. A link to a page in a directory the outline covers but doesn't list is an error. The
exhaustive lint skips bold and quoted spans, and a fact-cited line settles a count.

`facts.prose_sources` takes globs, and `facts.id_command` names the project's id command.
`drafter outline` with no slug prints the outline. `drafter refs --out-of-scope <slug>` lists the
entries that route a topic to a slug, and a missing blueprint's error uses `.blueprint.md`. A
notice is a `- Kind: ...` bullet.

`drafter page --commit` commits each run's accepted output. A red-tree stop names the gate log
and prints its failing lines. A create of unknown outcome holds no other page.
`drafter brief --sync` carries citations across a page edit, and a `no-claim` sentence may carry
a numeral or name the page's code shows.

The format doc splits into an author part and a reference part, and the `blueprint` skill carries
#98 to #101, #103, the `--commit` loop, `brief --sync`, and `approval-queue pending`.

Risk class: `runner` (the skill's files, and T4's prompt modules). T4 and T7 are `runner`: T4
edits `claude/.claude/workflows/docs-page-chain.js` and `stock/prompts.js`, which live drafting
reads. The other Go tasks are `ordinary`. No `live-account`: the pass pushes one drafter branch
and opens one PR.

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

- No session or subagent in this pass sends a signal by pattern (`pkill -f`, `killall`, `kill`
  on a `pgrep` result). A test or probe kills only PIDs it started itself. Batch 5's live
  `drafter page` run shares this machine, and a review probe's `pkill -f 'drafter page'` killed it
  once on 2026-10-25.
- In `claude/.claude/skills/blueprint/`, `format.md` is a symlink to `docs/blueprint-format.md`,
  and `anatomies.md` and `introductions.md` are symlinks into `stock/`. Edit the targets, never
  the links; `tests/install.test.sh:49-51` checks them.
- Go tasks T1 to T6 leave `README.md` and `docs/blueprint-format.md` untouched and list each rule
  or usage they change in their commit message under a `Docs:` line. T7 writes every such line
  into the docs. This keeps the pairs free of doc conflicts.
- `docs/configuration.md` is T4's alone among the Go tasks, since
  `internal/config/docs_test.go` (`TestConfigurationDocNamesEverySetting`) fails on an
  undocumented key. T7 may change its links into moved anchors after T4 has merged.
- A pair runs as pass-core "Pairs" says: the session commits, launches both subagents in one
  message, merges each task branch into `worktree-batch-4-friction`, and runs the gate. A
  mechanical conflict (imports, adjacent additions in a test file) is resolved by keeping both
  sides and re-running the gate. Only a semantic conflict in Go code stops the line.
- Fixtures are synthetic: no cairn path, fact id, or text in a test. cairn names appear only in
  the PR body.
- Gate: `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` from the worktree, re-issued on exit 75.
  It wraps `make check` (vet, lint, the full suite, `chain-test`, `prompts-parity`,
  `install-test`, `hook-test`), so the fast lane and the full-suite home are the same local run.
  drafter has no CI on PRs.
- Go follows `go-conventions` (read by path in a subagent:
  `/var/home/glw907/.claude/skills/go-conventions/SKILL.md`): stdlib assertions, table-driven
  tests, errors printed only in `main`, no new dependency.

## Tasks

The first pair opens with the worktree (5 min, on the path, per pass-core step 4): `EnterWorktree`
with the name `batch-4-friction`, from the drafter main checkout, and arm the API-drop wake-up
(`/loop` with no interval). Before launching T1 and T2, `git branch --show-current` prints
`worktree-batch-4-friction`, and the gate is green on the untouched tree.

### T1. The blueprint lints and the unlisted-link error (#86, #87, #89, #90, part of #96) (135 min, ordinary), pair with T2

Outcome: the procedure rules, stale `covers` names, and links to unlisted pages are caught, the
exhaustive lint stops its batch 4 misfires, and a missing blueprint's error names the markdown
suffix.

Files: `internal/blueprint/markdown.go` (`MDLine`, the bullet branch that sets it),
`internal/blueprint/check.go` (`markdown`, `prose`, `pairing`, and a new covers check),
`internal/plan/exhaustive.go`, `internal/plan/check.go` (`link`), `internal/plan/outline.go` only
for a helper `link` needs, and their tests. Never `internal/plan/verify.go`,
`cmd/drafter/check.go`, or `internal/blueprint/refs.go`.

- #86: `MDLine` gains a field that records a numbered step (the `\d+[.)]` branch of
  `listMarker`), since today a bullet and a step decode alike (`markdown.go:80-90`). The markdown
  check adds three warnings under the check name `procedure`, each naming its rule from Google's
  procedures guidance (<https://developers.google.com/style/procedures>), on markdown blueprints
  only:
  - an imperative bullet outside a step list: a plain bullet (not numbered, not `Code:`,
    `Figure:`, or a `See` link) whose first word is a verb from a fixed list in the code;
  - one action per step: a numbered step where ` and ` is followed by a verb from that list;
  - the condition before the instruction: a numbered step that opens with such a verb and has
    `if`, `unless`, or `when` after it, outside code spans.
  The verb list is a short fixed set of the commands docs steps use (add, run, set, open,
  create, install, edit, delete, remove, select, enter, copy, write, call, import, configure,
  deploy, restart, commit, push, change, replace, move, rename, use, check, verify, declare,
  register, wire, mount, pass, start, stop). They are warnings because each is a heuristic.
- #87: `ExhaustiveClaims` skips a bold span (`**...**`) and a quoted span (`"..."` or `“...”`) as
  it skips a code span (`exhaustive.go:39`). In the blueprint's `prose` check
  (`check.go:285-325`), a line that carries a `:fact` tag drops its count claims (`three radius
  keys`); `only`, `every`, `all`, `none`, and `always` still warn there. `verify.go`'s call to
  `ExhaustiveClaim` (`verify.go:176`) compiles unchanged and gets the span skips. No suppression
  marker: that waits in "Later".
- #89: in `link` (`internal/plan/check.go:336`), a target that exists on disk, ends `.md`, sits
  in a directory that holds at least one page the outline lists, isn't named `README.md`, and
  isn't listed by the outline is an error: "target %s is in a directory the outline covers, but
  the outline doesn't list it, so it may be a renamed or retired page", fix "link the page's
  current path, or list the page in the outline (managed: false for a page drafter doesn't
  own)". It runs before the `Anchors` hook branch, and only when `c.opts.Outline` is set, so the
  check runs in named and unnamed runs. On cairn `main` the outline lists pages under
  `docs/extend` and `docs/claude-code`, and `docs/extend` holds `choose-an-ai-posture.md`,
  `share-a-draft-preview.md`, and `upgrade-cairn.md` unlisted; links into `docs/reference` stay
  unflagged. This replaces the rename command. Because `link` sits in `plan.Check`, the error also
  fires in `drafter gate` (`gateBlueprint` runs `p.Check([]string{bp})`, `cmd/drafter/gate.go:135`)
  and in `drafter page`'s stage 1 (`CheckSource` reaches `plan.Check`,
  `internal/blueprint/check.go:144`; `doBlueprintCheck` stops on an error,
  `internal/pipeline/blueprint.go:99-111`). It stays an error in all three, as the design says;
  the PR's `## Decisions` states both paths, and standing answer 3 holds the install until cairn's
  outline lists the targets its blueprints link. On cairn `origin/main` (`75b6138`) nine
  blueprints link an unlisted page: `upgrade-cairn.md` from architecture,
  add-a-second-sign-in-group, add-cairn-to-a-sveltekit-app, debug-your-site,
  restrict-admin-access, scaffolded-site-files, and claude-code/using-claude-code-with-cairn;
  `choose-an-ai-posture.md` from build-the-public-routes, define-an-adapter-and-schema, and
  scaffolded-site-files. No blueprint links `share-a-draft-preview.md`.
- #90: each backticked span with no whitespace in an outline entry's `covers` that occurs in no
  tracked file outside the blueprint root and outside `.md` files warns, check `covers`, at the
  entry's line. Search all names in one pass over the tracked files (one `git ls-files` read or
  one `git grep -F` with every name), never one search per name. The unnamed run checks every
  outline page; a named run checks the named pages' entries.
- #96, the suffix: `pairing`'s missing-blueprint message (`check.go:557`) names
  `<page>.blueprint.md`, since `BlueprintPath` falls back to the retired `.blueprint.yaml` when no
  file exists.
- The slugger, checked against cairn as the design asks: no double count, so no code change.
  drafter's markdown decoder takes the H1 as no section and seeds the slugger with the front
  matter's `page` (`markdown.go:274-279`, `markdown.go:321`, `plan/slug.go:62-72`). A published
  cairn page opens with that H1 and carries no front matter (`docs/extend/add-an-island.md:1`),
  and cairn.pub renders the whole page through cairn's pipeline, whose `rehypeSlug` counts the
  H1, then strips the H1's HTML (`cairn-pub/src/lib/docs/loader.ts:47-54`). The title counts once
  on both sides. A test pins it: front matter `page: X`, `# X`, and `## X` give the section the
  id `x-1`.

Acceptance: the gate is green; tests cover each procedure warning firing and a step that passes
all three, a numbered step decoded with the new field, a bold label and a quoted name passing the
exhaustive lint, a fact-tagged count passing while a fact-tagged `only` still warns, an unlisted
`.md` target in a covered directory erroring, the same target listed `managed: false` passing, a
`README.md` and a target in an uncovered directory passing, a `covers` name that resolves and one
that doesn't, the missing-blueprint message, and the slug pin.

### T2. The anchor ratchet and the store fixes (#84, #85, #92, #93, #94) (90 min, ordinary), pair with T1

Outcome: a named check fails on an anchorless pointer in the facts it cites and names the anchor;
the store check's span, hint, external, and anchor-form fixes land.

Files: `internal/plan/verify.go`, `cmd/drafter/check.go` (`runCheck`), and their tests. Never
`internal/plan/exhaustive.go`, `internal/plan/check.go`, or `internal/blueprint/`.

- #84: today a named check verifies no fact pointer; the store runs only when nothing is named
  (`cmd/drafter/check.go:226`). `runCheck` collects the ids each named blueprint cites with
  `p.Cited(rel)` (`internal/blueprint/cited.go:17`, the call `drafter gate` makes at
  `gate.go:139`) and, when any are cited, calls `plan.VerifyFacts(p.FactsDir, p.Root, ids)` and
  prints its `facts store:` line. A nil id list means the whole store (`check.go:263`), so no
  call is made when nothing is cited. The anchorless finding (`verify.go:390-392`) moves from the
  check name `store` to `anchorless`, and on a named run `runCheck` raises each `anchorless`
  finding to an error. The unnamed run, `drafter check --fact`, and `drafter gate`
  (`gate.go:146`) keep it a warning, so a page run never stops on it. The message names the
  suggested anchor: the name a declaration on the cited lines declares (a line `goColumn0Re` or
  `tsColumn0Re` matches), else the first `anchorWordRe` match on the first cited line, as "add
  (`<name>`) after the pointer". The warning and the error share the message.
- #85: `verifySymbol` checks the anchor against the declaration lines only, not from `docStart`
  (`verify.go:612`, `verify.go:417-431`). The range starts at the first line of the run of
  decorator lines (`@...`) directly above the declaration, or at the declaration line when there
  is none, and stops before any comment line above them; today's `docStart` walks up over `//`,
  `/*`, `*`, and `@` lines alike (`verify.go:651-660`). cairn's `check:facts` matches this: its
  range "starts at the declaration itself, after any doc comment"
  (`scripts/checks/check-facts.mjs`, the `resolveSymbolDeclaration` comment), and its start is
  the node's `getStart`, which in TypeScript 6.0.3 (cairn's version) includes decorators (a probe:
  `/** doc */`, `@dec()`, `export class Foo {}` starts at line 2; a decorated method likewise).
  The excerpt keeps the doc comment unchanged (`internal/assemble/excerpt.go:249-264`).
- #92: the drifted-anchor hint (`verify.go:399-410`) names the first line in the window that
  holds every anchor word, or says that no single line holds the whole anchor. Today it names
  each word's nearest line, which re-points a fact wrong.
- #93: in `VerifyFacts`' pointer loop, a fact whose tag is `external` skips a pointer whose file
  doesn't exist and counts it skipped; a pointer to an existing file is checked as today.
- #94: `pointerAnchorRe` (`verify.go:34`, today `` ^\s*\(`([^`]*)`\) ``) also reads
  `` (`symbol`: more text) ``: the code span, a colon, and text up to the closing parenthesis.
  cairn's `POINTER_RE` reads that form as no anchor, so drafter only adds checks there.

Acceptance: the gate is green; tests cover a named check of a blueprint citing an anchorless fact
(exit 1, the `anchorless` error, the suggested name), the unnamed run on the same project (a
warning), `--fact` on it (a warning), a named check citing no fact (no store line), a JSDoc-only
anchor word failing a `#decl` pointer, an anchor word on a decorator line above the declaration
passing, the hint naming the line with every word and the no-line
message, an `[external]` fact with a missing vendor path (skipped, no finding), and an anchor with
trailing text read and checked.

### T3. Inbound anchors and drafted-page drift (#88 named-run half, #106, #108) (120 min, ordinary), pair with T4

Outcome: a named run reports links into anchors its blueprint dropped, and a drafted page whose
links, steps, or snippets drifted from its blueprint warns.

Files: `internal/blueprint/inbound.go` (new), `internal/blueprint/drift.go` (new),
`internal/blueprint/check.go` (`Check` calls the two only), `internal/plan/pagelinks.go` for an
exported link walk, and their tests. Never `internal/blueprint/markdown.go`,
`internal/blueprint/refs.go`, or `internal/config`.

- #88: on a named run, for each named blueprint and its page P, the anchors are the blueprint's
  heading slugs (the set `check.go:175-186` builds). The check walks every other blueprint's link
  items and inline `[text](target#anchor)` links (resolving targets as `PageRefs` does at
  `refs.go:131-139`), and every tracked `.md` file outside the blueprint root and the facts
  directory except P's file, read with goldmark as `CheckPageLinks` reads a page
  (`plan/pagelinks.go:28`). Export the walk from `internal/plan` rather than copy it. A link to
  `P#a` whose `a` the blueprint lacks is reported, check `links`, at the linking file and line:
  "links #%s on %s, which the page's blueprint no longer has", fix "repoint the link, or keep the
  heading". It is an error when the linking file is another blueprint or a page in a directory
  the outline covers (T1's #89 notion: a directory holding at least one listed page), because
  each such link turns the docs gate red when P is drafted (the batch 4 theme stop). From any
  other tracked `.md` file it is a warning with the same message: on cairn that set is 1,376
  files, and it holds history that links page anchors on purpose (`CHANGELOG.md:1199`, `:1327`,
  `:2891`, and `docs/internal/record/`) beside published pages drafter doesn't own
  (`docs/reference/sveltekit.md` and five other reference pages link `../extend/*.md#...`), so a
  warning keeps both visible without failing every named run on a record. Because `Check` runs in
  `drafter gate` (`cmd/drafter/gate.go:135`), the error and the `page-drift` warnings below also
  run there; the PR's `## Decisions` states that.
- #106 and #108: for each checked markdown blueprint whose page has a `drafted.lock` entry with a
  page (`e.Page != ""`), the check compares the page on disk with the blueprint and warns, check
  `page-drift`:
  - a link target the blueprint names (a `See` item or an inline link), resolved from the page's
    directory, that the page doesn't link: "the page doesn't link %s, which its blueprint names;
    redraft it with drafter page";
  - in each section matched by heading slug, the page's top-level ordered list items against the
    blueprint's numbered steps (T1's field): a different count warns with both counts, and steps
    whose first code span appears in the page's steps out of the blueprint's order warn;
  - in each section, the identifiers (`[A-Za-z_][A-Za-z0-9_]{2,}`) of the blueprint's `Code:`
    fences against the page's fenced code: names one side has and the other lacks warn, up to
    five named.
  The unnamed run checks every drafted page; a named run checks the named pages. YAML blueprints
  are skipped. They are warnings, since a redraft may reword a step.

Acceptance: the gate is green; tests cover a published page and a sibling blueprint each linking
an anchor the named blueprint dropped (an error apiece), a top-level `CHANGELOG.md` linking it (a
warning), P's file skipped, an anchor
the blueprint keeps passing, the unnamed run not running the inbound walk, a drafted page missing
a blueprint link, a page with one step more, steps out of order, a snippet with a swapped
identifier, a page with no lock entry skipped, and a matching page passing.

### T4. Globs, the outline and refs gaps, `facts.id_command`, and notices (#95, #105, the rest of #96, #100, #91) (115 min, runner), pair with T3

Outcome: `facts.prose_sources` takes globs, the outline and refs commands fill their gaps, the id
command is a setting, and a notice bullet decodes and drafts as a notice.

Files: `internal/assemble/files.go` (`openRepo`, `repo.prose`), `internal/assemble/excerpt.go`
(the prose case), `internal/blueprint/refs.go` (`SourceKinds`, and the out-of-scope lookup),
`internal/config` (`sources.go` `settingKeys`, `file.go`, `config.go`, `apply.go`, `layer.go`,
`validate.go`), `docs/configuration.md`, `cmd/drafter/outline.go`, `cmd/drafter/refs.go`,
`internal/blueprint/markdown.go` (`formLabel`, the label branch, `View`), `stock/prompts.js`
(`markdownReading`), `stock/edit_test.go` where it pins prompt text,
`claude/.claude/workflows/docs-page-chain.js` (`bpMarkdownReading` only),
`tests/docs-page-chain-blueprint.test.mjs` (the chain module's markdown-reading assertions near
line 307), and their tests. Never
`internal/blueprint/check.go`, `inbound.go`, `drift.go`, or `internal/plan`.

- #105: each `facts.prose_sources` entry is a `path.Match` pattern; an entry with no metacharacter
  matches itself, as today. `*` doesn't cross a `/`, and there is no `**`; the PR's `## Decisions`
  says so. The assembler's prose test (`files.go:48`, `excerpt.go:135-136`) and `SourceKinds`
  (`refs.go:194`) use the same match. Config validation rejects an entry `path.Match` reports as
  malformed, naming it.
- #95: no new rule. A line pointer into a listed prose file already excerpts
  (`excerpt.go:135-136`, `docs/blueprint-format.md:696-699`); a test pins it for a README a glob
  matches. A bare path to a listed file stays `no excerpt: prose`, as the format doc says; the
  PR's `## Decisions` records that.
- #100: `facts.id_command`, a string, unset by default, allowed in the project and local layers
  like `facts.prose_sources`. drafter stores it and `drafter config` shows it; nothing runs it.
  `docs/configuration.md` gets its row and says the skill tells an author to run it.
- #96, the commands: `drafter outline` with no argument prints every page's entry as one YAML list
  (`--json`: an array), and `Args` takes zero or one. `drafter refs --out-of-scope <slug>` lists
  each outline entry whose `outOfScope` line names the slug as a whole word, as
  `<outline>:<line>: <page path>: <line text>` (`--json`: an array of `{file, line, page,
  text}`). It exits 0 with or without hits, 1 when the outline lists no such slug, and 2 when
  given with fact ids or `--page`.
- #91: a new `noticeLabel` regex (`^(Note|Tip|Important|Warning|Caution):\s`, GitHub's alert
  set) gets its own branch in the bullet decoder, beside the `formLabel` branch
  (`markdown.go:300-314`), not an extension of `formLabel`: that branch strips the label from
  `Text`, reads `:source`, and sets `formAt` so a following fence attaches, and `isForm`
  (`markdown.go:387-392`) shares the regex. The notice branch sets `Kind` `notice`, keeps its
  label in `Text` so the draft sees it, reads no `:source` (a `:source` there gets the existing
  stray-tag warning, `markdown.go:250`), and leaves `formAt` alone. `View` maps it to an
  `example` item as a plain bullet, so the plan checks are unchanged. `markdownReading` in `stock/prompts.js:288-298`
  gains one sentence: a bullet that opens with a notice kind and a colon is a notice, written as a
  GitHub alert, `> [!KIND]` and then its text on the quoted lines below. The chain module's
  `bpMarkdownReading` (`claude/.claude/workflows/docs-page-chain.js:2591-2602`), which cairn drafts
  through, gains the same sentence. `prompts-parity` renders that module in Node and in goja, so
  both renders change together; no golden pins the paragraph's text.

Acceptance: the gate is green (it runs `prompts-parity` and `chain-test`); tests cover a glob
entry matching a README two directories down, an exact entry still matching, a malformed pattern
refused, `SourceKinds` naming `prose` for a glob match, `facts.id_command` read from each allowed
layer and shown by `drafter config`, `outline` with no argument (YAML and JSON), `refs
--out-of-scope` with a hit, with none, with an unknown slug, and with an id (usage error), each
notice kind decoding with its label kept, a `Note:` bullet's `:source` ignored, and the stock
prompt and the chain module's `bpMarkdownReading` each carrying the notice sentence.

### T5. `drafter page`: `--commit`, the red-tree message, and a recovery that holds no page (#104, #88 drafting half, #83) (165 min, ordinary), pair with T6

Outcome: a loop of `drafter page --commit` runs, a red-tree stop names its cause, and a create of
unknown outcome no longer holds every page.

Files: `cmd/drafter/page.go` (the flag, the help text, the `runPage` switch),
`cmd/drafter/pagebp.go` (after `recordDrafted`), `internal/pipeline/pipeline.go` (`releaseHeld`,
the stop line at `pipeline.go:432`), `internal/pipeline/check.go` (`runGate`),
`internal/pipeline/money.go` (`flight`, `recover`, `findBatch`, `waitEnded`, `await`),
`internal/pipeline/resume.go` (`reattach`), a new test in `e2e/`, and their tests. Never
`cmd/drafter/root.go` or `internal/provenance`.

- #104: `drafter page` already takes several blueprints in one run (`page.go:31`); the batch 4
  failure was a shell loop of one run per page that met `requireClean` (`start.go:94-107`) on the
  second page. `--commit` makes one commit after `recordDrafted` writes the lock
  (`pagebp.go:192`), when the run didn't stop and isn't a dry run: each accepted page, its brief
  (`blueprint.BriefPath`), `drafted.lock`, and each file the index-link command wrote for an
  accepted page, only the paths that changed, with the subject
  `Draft pages with drafter page` and one accepted page path per body line. One commit keeps page,
  brief, and lock together, which `warnMovedInputs` (`pagebp.go:237-260`) says the next run needs.
  A failed commit exits 2 with git's message and leaves the files written. `--commit` with handoff
  files is a usage error, as `--whole` is (`page.go:115-123`). A `--resume` run that finishes
  commits the same way. The help text's "and never commits" (`page.go:34`) becomes "and commits
  only with --commit".
  The index-link files matter on cairn: its local layer sets `gate.index_link_command` to
  `cairn-docs-outline link`, which writes a link to each new page into the outline's index file,
  and `indexLink` (`internal/pipeline/check.go:331-399`) records each file it changed in the page's
  work record as `IndexPost`. Without them the next run in a loop meets `requireClean` again on
  every new page. `PageResult` in `pipeline.Summary` (`pipeline.go:161`) gains the sorted keys of
  an accepted page's `IndexPost`, and the commit takes them. The work record survives a resume, so
  a `--resume` run commits them too, where `git status --porcelain` would not do: only `begin`
  calls `requireClean` (`start.go:135`), so a resumed tree may hold changes that aren't the run's.
- #88, the drafting half: when `releaseHeld` halts with `StopTreeRed` (`pipeline.go:466-467`),
  the stop output names each held page's latest gate log (`gate-N.log`, `check.go:190`) and prints
  the first lines of each failing section that names no page of the run (up to 20 lines, as
  `excerpt` cuts at `check.go:214-224`), beside the existing `stopped: ...` line.
- #83: the blocking candidate wait goes. Today `recover` calls `findBatch`, which calls
  `waitEnded` on each untracked candidate until it ends (`money.go:249-306`), and nothing else
  advances. Instead, `recover` (a create that returned `batch.ErrMaybeSent`) and `reattach` (a
  resumed intent with no batch id, `resume.go:477-484`) list the candidates once, as today, and
  add a search flight that holds the candidate ids. `await` polls a search flight's candidates in
  the same pass as the in-flight batches, one `Get` per candidate per pass, and writes nothing to
  state for them, since a candidate may belong to another run (`waitEnded`'s comment). It reads an
  ended candidate's results. One carrying the intent's custom_ids is adopted: `BatchID` and
  `Created` are set and saved, and it becomes an ordinary flight. When every candidate has ended
  with no match, `recover`'s path voids and resends under the `.maybesent` budget as today
  (`money.go:239-243`), and `reattach`'s path voids (`resume.go:482-484`). A failed `List` or
  `Get` keeps today's `pollFailed` path. The `adoption search` poll line stays. Write the tests
  first.

Acceptance: the gate is green; an e2e test runs the built binary through `newDraftEnv` (its stub
via `api_base_url`) as `page --sync --commit` on one blueprint, then on a second in a new run,
and both exit 0, each leaving one new commit holding its page, brief, `drafted.lock`, and the
index file, and a clean tree. The fixture: `e2e/testdata/cli` holds one blueprint
(`blueprints/docs/count-items.blueprint.yaml`), so the test copies it under a second slug, lists
the copy in the copied project's `outline.yaml`, and sets `gate.index_link_command` in the copied
project's `drafter.toml` to a shell line that appends `{page}` to a tracked index file; it then
asserts that file is in each commit. The stub's canned answers fit the copy, since it is the same
blueprint; where an answer names the first page's path, the test sets it per run with
`e.stub.setAnswer`, as `e2e/draft_rows_test.go` does. Unit tests cover `--commit` with a handoff file (exit 2), a stopped run (no commit),
a red tree outside the run naming its log and printing its failing lines, and, against the fake
batch server, a create of unknown outcome whose candidate stays `in_progress` while a sibling's
batch ends: the sibling's next stage submits before the candidate ends, then the candidate is
adopted when it ends carrying the ids; a variant that ends without them voids and resends; and a
resumed intent with no batch id searching the same way.

### T6. `drafter brief --sync` and the provenance fixes (#109, #107, the #91 alert marker) (140 min, ordinary), pair with T5

Outcome: a page edit's brief is rebuilt with every unchanged sentence's citation kept, and the
provenance check stops two misfires.

Files: `internal/provenance/provenance.go` (`Check`'s no-claim branch, `pageProse`),
`internal/provenance/sync.go` (new), `cmd/drafter/brief.go` (new), `cmd/drafter/root.go` (its
registration), and their tests. Never `cmd/drafter/page.go` or `internal/pipeline`.

- #109: `drafter brief --sync <page>` reads the page and its brief (`blueprint.BriefPath`,
  `brief.go:13`, with the project's `blueprints.brief_path`). A brief sentence is
  `{"text", "id"}`, where the id is its citation (`provenance.go:69-72`). Each brief sentence
  whose text still stands on the page, located as `Check` locates it (through
  `coverage.Normalize`, longest first, `provenance.go:137-160`), keeps its entry as written. Each
  run of page prose no kept sentence covers (the `\x00`-split fragments `Check` already reports as
  unclassified, `provenance.go:167-172`, kept when `hasContent` holds) is split at sentence ends (a
  word ending in `.`, `?`, or `!`, the rule `longSentences` uses at
  `internal/blueprint/check.go:330-349`) and at each raw line that opens a list item or follows a
  blank line, into new entries whose id is `null`. A split piece `hasContent` rejects (a bare `2.`
  list number) is dropped, and a leading list or quote marker is trimmed, as `Check` trims its
  fragments with `strings.Trim(fragment, "-*+>|# \t\n")`. A null id is unclassified to `Check`
  (`provenance.go:237`), so it fails until the author tags it. Entries come out in page order.
  - Recovering the text as written: matching runs in `Normalize` space, which drops every `*`,
    `_`, and backtick (`internal/coverage/normalize.go:14-22`), while cairn's briefs carry the raw
    markdown (`` `build()` ``, links). `pageProse` becomes a wrapper over a new
    `pageProseMap(markdown) (prose string, raw []int)` that blanks each stripped region (front
    matter, fences, comments, details tags, images, headings) with spaces of the same length,
    newlines kept, so the blanked text stays offset-aligned with the page, then normalizes rune by
    rune, recording each kept rune's byte offset in the page. A test asserts `pageProse` is
    unchanged on every provenance fixture, so `Check` keeps its behavior. A normalized span
    `[i, j)` maps to the page's bytes `raw[i]` to `raw[j-1]`, widened outward over adjacent `*`,
    `_`, and backtick characters, with each whitespace run collapsed to one space (cairn's brief
    texts are one line each).
  - Preserving the brief's form: cairn's brief is one line of JSON, no trailing newline, keys in
    the order `page`, `sentences`, `local`, with a literal `<name>`. When no entry changed, sync
    writes nothing. Otherwise it splices: a `json.Decoder` walks the top-level object and takes the
    `sentences` value's byte span from `InputOffset`; each kept entry's `json.RawMessage` is copied
    verbatim, each new entry is encoded from a struct with fields in the order `text`, `id`
    through a `json.Encoder` with `SetEscapeHTML(false)` and its trailing newline trimmed, and the
    entries are joined with `,` inside `[` and `]` and written back between the bytes before and
    after the span. A probe of that splice on cairn's
    `docs/internal/briefs/extend/add-an-island.json` (132 sentences) rebuilt the file byte for
    byte, and a new entry came out as `{"text":"a <name> b","id":null}` once the struct fixed the
    key order. A pretty-printed brief's `sentences` array comes out compact; the PR's
    `## Decisions` says so.
  The brief is written with `internal/atomicfile`. Each new entry prints as
  `<page>:<line>: untagged: <text>`. Exit 0 when
  no sentence needs a tag, 1 when any does, 2 when it can't run (no page, no brief, or a brief
  `Check` can't decode); `brief` without `--sync` is a usage error. The design's "changed
  sentences get new ids" reads as a null id, since a sentence's id is its citation; the PR's
  `## Decisions` says so.
- #107: `Check`'s no-claim branch (`provenance.go:127-133`) skips a `numeral` or `name` token
  whose value appears in a fenced code block on the page.
- #91: `pageProse` (`provenance.go:312-323`) drops a GitHub alert marker line (`> [!NOTE]`,
  `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]`), so a notice's marker is never
  unclassified page text. The notice's text stays prose the brief classifies.

Acceptance: the gate is green; tests cover a sync after one sentence changed (every other
entry's id kept, one null entry printed, exit 1), a sync with nothing changed (exit 0, brief byte
for byte, on a synthetic one-line brief with no trailing newline, a literal `<` in a sentence, and
its keys out of alphabetical order), a sync after one change leaving every kept entry's bytes and
the other top-level keys unchanged, a new sentence whose page text has a code span and a bold span
coming out with both delimiters, a numbered step's `2.` not becoming an entry, `pageProse`
unchanged across the existing fixtures, a removed sentence dropped, an added list item split into two sentences, no brief
(exit 2), `brief` alone (exit 2), a `no-claim` sentence naming a numeral and a code name from the
page's snippet passing while one naming a numeral the page's code lacks still fails, and a page
with a `> [!CAUTION]` notice passing with its text classified.

### T7. The format doc split and the skill (#97 to #101, #103, the `pending` line, every `Docs:` line) (115 min, runner)

Outcome: an author reads one part of the format doc whole, and the skill carries batch 4's
authoring fixes and the new commands.

Files: `docs/blueprint-format.md` (the author part), `docs/blueprint-reference.md` (new, the
reference part), `claude/.claude/skills/blueprint/SKILL.md` and `new-page.md`, a new symlink
`claude/.claude/skills/blueprint/reference.md` to `../../../../docs/blueprint-reference.md`,
`README.md`, `docs/handoff.md`, `docs/configuration.md` (links into moved anchors only),
`tests/install.test.sh` (a check for the new link beside lines 49-51), and the tests that read the
format doc (`internal/blueprint/docs_test.go`, `internal/blueprint/catalog_test.go`,
`cmd/drafter/init_test.go`), each pointed at the file that now holds what it reads. Never
`stock/anatomies.md` and never `claude/.claude/workflows/docs-page-chain.js`.

- #97: the skill's `format.md` links the published doc, so the published doc splits. The author
  part keeps the name `docs/blueprint-format.md` and these sections: Version and stability,
  Layout, Markdown blueprints with its subsections, What `drafter check` checks with Find where a
  fact is used, The facts store with its subsections, The edit catalog, and Check what you add.
  The reference part takes Write prose fields as blocks, Top-level fields, Items, `outline.yaml`
  with Anatomies and tracks, `drafted.lock`, See what a read sees, Look up a page's outline entry,
  What `drafter read` does, What `drafter page` does, and The brief. Each opens with one line
  linking the other. The anchors `#markdown-blueprints` and `#the-facts-store` stay in the author
  part, so the GitHub URLs in `stock/anatomies.md:20`, `stock/introductions.md:101`, and
  `internal/scaffold/templates/facts-README.md:21` hold. Every link into a moved anchor changes in
  the same commit, the skill's `format.md#outlineyaml` (`new-page.md:11`) among them (it becomes
  `reference.md#outlineyaml`). The skill has no `format.md#items` link.
- From the commits' `Docs:` lines: the check table's new rows (`procedure`, `covers`,
  `anchorless` with the named-run error, `page-drift`, the inbound-anchor error, the unlisted-link
  error), the exhaustive row's span skips and fact-settled counts, the `Source:` grammar table's
  `#decl` row (the anchor checks the declaration lines; the excerpt keeps the doc comment), the
  drift hint, the `[external]` skip, the anchor with trailing text, `facts.prose_sources` globs,
  the notice syntax (`- Caution: ...` and the five kinds), and, in the reference part and
  `README.md`, `drafter page --commit`, `drafter brief --sync`, `drafter outline` with no slug,
  and `drafter refs --out-of-scope`.
- The skill (`SKILL.md`, `new-page.md`):
  - #98: a run in a scratchpad is recorded in the fact's tag note (`[verified: ran ...]`), never
    as a `:source` on a scratchpad path and never as a blueprint line. A script in the repository
    keeps its `:source`, as `new-page.md:26` says today.
  - #99: name each value by its identifier, never by the metaphor a code comment uses for it.
  - #100: mint each new fact id with the command `facts.id_command` names, which `drafter config`
    shows.
  - #101: name a file in the reader's site by its path in a code span, never by a relative link
    into the repository's templates, which breaks on the published site.
  - #103: the fact-edit rule (`SKILL.md` "Edit", `new-page.md` step 2) allows an exact in-place
    substitution by any tool; it still forbids an append or a second bullet.
  - Check: a named `drafter check` verifies the facts its blueprints cite and fails on an
    anchorless pointer, and its message names the anchor to paste; the unnamed run still runs the
    whole store and the outline-wide checks.
  - Review: run `approval-queue pending` first, and take over each decision it lists with
    `approval-queue collect <id>` before queueing anything new. The approval-queue pass's plan
    (`2026-10-25-approval-queue-batch-4-friction-plan.md` beside this one, its #44 section)
    fixes both names.
  - Draft: pass several blueprints to one `drafter page` run, or loop one run per blueprint with
    `--commit`. Page prose: after a hand edit to an accepted page, run `drafter brief --sync
    <page>` and tag each sentence it prints.
- #102: no change in drafter. The skill's anatomy has no item 5 (`stock/anatomies.md:58-63`); the
  conductor files the cairn register item.

Acceptance: the gate is green (it runs `tests/install.test.sh`); `test -L` holds for the skill's
`format.md`, `reference.md`, `anatomies.md`, and `introductions.md`; `wc -c <
docs/blueprint-format.md` prints under 35000. The bar comes from a measured split at `e41695f`:
the sections the author part keeps measure 30,295 bytes (lines 1-224: 11,284; 543-654: 10,034;
701-823: 8,977, of which the edit catalog and Check what you add are 3,357), and the reference
part's sections 36,778. T7's additions come to about 3,600 bytes: six check-table rows at the
table's measured 192 bytes a row, the `#decl` grammar row at 202, the exhaustive row's change, the
drift hint, the `[external]` skip, the trailing-anchor form, the globs, the notice syntax with an
example, and the two linking lines. That gives about 33,900, under the bar with about 1,100 to
spare, and the doc is still half its 67,073 bytes today. This loop, run from
`claude/.claude/skills/blueprint`, prints nothing:

```bash
for f in *.md; do d=$(dirname "$(readlink -f "$f")"); grep -o '](\([^)#]*\)' "$f" | sed 's/^](//' | grep -v '^https\?:' | while read -r p; do [ -z "$p" ] || test -e "$d/$p" || echo "$f: $p"; done; done
```

and this one, run from the worktree root, prints nothing:

```bash
for a in $(grep -o '^#\+ .*' docs/blueprint-reference.md | sed 's/^#* //' | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9 -]//g; s/ /-/g'); do git grep -nE "(^|[(/])(blueprint-)?format\.md#$a\)" -- ':!BACKLOG.md'; done
```

`git grep` searches tracked files only, so `.claude/worktrees` stays out while the skill under
`claude/.claude/` is searched, and the anchored pattern skips `plan-format.md#items)`
(`docs/blueprint-format.md:340`). Probed at `e41695f`: the pattern with `outlineyaml` finds
`new-page.md:11`, and with `items` finds nothing.

Each rule names its case in one clause, and no skill file restates the format doc; C.3's
`prose-voice-reviewer` read checks both.

### C. Close (120 min)

1. Backlog: tick #83 to #101 and #103 to #109 with the PR number. #102 closes as moved to
   cairn-cms, naming `docs/internal/docs-register.md` item 5. File through `log-issue` in
   drafter's `BACKLOG.md`: the ratchet's second step (the unnamed run fails on an anchorless
   pointer too), blocked on cairn's anchoring item and tagged `#initiative:docs-system`; and each
   found-not-done item worth doing.
2. The end-to-end check, in a scratch cairn worktree that is never committed or pushed and is
   removed after. No API call is made: `check`, `refs`, and `brief` call none.
   - `git -C /var/home/glw907/Projects/cairn-cms fetch origin`, then
     `git -C /var/home/glw907/Projects/cairn-cms worktree add --detach <scratch>/cairn origin/main`,
     with `<scratch>` the session scratchpad.
   - `go build -o <scratch>/drafter ./cmd/drafter` from the pass worktree. Every command below
     runs as `<scratch>/drafter` from `<scratch>/cairn`.
   - `drafter check blueprints/docs/extend/arrange-the-admin-sidebar.blueprint.md` exits 1 with an
     `anchorless` error naming a suggested anchor for at least one of `f:brfitv` and `f:u844pc`
     (the planner's probe found both anchorless on `main`; if neither prints, any anchorless fact
     the blueprint cites, named in the PR).
   - `drafter check` with no name prints the same fact's finding as a warning. Record its error
     and warning totals and its count of `anchorless` warnings for the cairn follow-up.
   - Add the line `- See [Share a draft preview](share-a-draft-preview.md).` under a section of
     the scratch copy of `arrange-the-admin-sidebar.blueprint.md`, noting its line number N; the
     named check's output carries the unlisted-target message at
     `arrange-the-admin-sidebar.blueprint.md:N` (grep the output for `:N:` and "the outline doesn't
     list it"; the exit code proves nothing here, since the anchorless error already exits 1).
     `git -C <scratch>/cairn checkout -- .` reverts it.
   - Change one sentence of `docs/extend/add-an-island.md` in the scratch worktree and run
     `drafter brief --sync docs/extend/add-an-island.md`: it exits 1 and prints that one sentence.
     The brief is one line of JSON, so `git diff` shows the whole line changed; compare entries
     instead:
     `diff <(git -C <scratch>/cairn show HEAD:docs/internal/briefs/extend/add-an-island.json | jq -c '.sentences[]') <(jq -c '.sentences[]' <scratch>/cairn/docs/internal/briefs/extend/add-an-island.json)`
     shows only that sentence's entry replaced by one or more entries with a null id. The page has
     no unclassified text today (the reviewer's probe: 10 findings, none unclassified), so the
     printed sentence is the edit's alone. Revert.
   - `drafter page --commit` against a fake server is T5's e2e test in drafter's harness; record
     its name and result.
   - Record the outputs in the PR body, then
     `git -C /var/home/glw907/Projects/cairn-cms worktree remove <scratch>/cairn`.
3. Whole-branch `diff-reviewer` against the design and this plan, and `prose-voice-reviewer` on
   `docs/blueprint-format.md`, `docs/blueprint-reference.md`, and the skill diff. One batched fix
   chain quoting each finding verbatim, then the gate again.
4. drafter `docs/STATUS.md`: the pass at PR-ready, and the next action (the conductor's packet, the
   merge order, the pull and install under standing answer 3, and the hand-over) for conductor-drafter to
   finish after the merge.
5. Open the PR on glw907/drafter from `worktree-batch-4-friction` with `## Brief`, what landed, the
   end-to-end outputs, `## Decisions` (at least: the null id for `brief --sync`, `path.Match`
   globs with no `**`, `--commit` as one commit per run, the `--commit` e2e in drafter's harness,
   the inbound-anchor finding as an error from blueprints and covered-directory pages and a
   warning from other files, counts alone settled by a fact tag, the `README.md`
   exemption in the unlisted-link error, the unlisted-link error also firing in `drafter gate` and
   in `drafter page`'s stage 1 (with the install held on cairn's outline, standing answer 3), the
   inbound-anchor error and `page-drift` warnings running in `drafter gate`, the `#decl` range
   keeping decorators as cairn's `resolveSymbolDeclaration` does, `--commit` taking the index-link
   files, `brief --sync` writing a changed `sentences` array compact, a bare path to a prose source
   staying unexcerpted, the slugger probe with no change, #102 moved to cairn's backlog, and the
   notice sentence in the chain module as a drafter file), `## Planning misses`, the
   found-not-done list,
   and the score. Stop at PR-ready and message conductor-drafter.

## Path

Worktree entry 5 + pair (T1 135, T2 90) 135 + pair (T3 120, T4 115) 120 + pair (T5 165, T6 140)
165 + T7 115 + C 120 = 660 minutes. T1 and T3 run in that order because T3 reads T1's
numbered-step field. T4 runs after T1 because both edit `internal/blueprint/markdown.go`. The task
sum is 1005. The fold moved T5 from 150 to 165 (the index-link files and the e2e fixture), T6 from
90 to 140 (the offset-aligned prose map and the splice writer), and T7 from 120 to 115 (its own
voice read dropped for C.3's).

## Standing answers

1. A clock stop writes its minutes to STATUS, rewrites `start=`, and carries on while the actual
   path stays under 1000 minutes. Past 1000 the executor stops and the conductor asks Geoff.
2. No API credit: never `make smoke` or `make live`, and `drafter page` only with `--dry-run` or
   against a fake server (T5's e2e harness). The cairn scratch runs `check`, `refs`, and `brief`
   alone.
3. The pull and the install: after the merge, the main checkout's pull and `make install` to
   `~/.local/bin/drafter` wait for the same three conditions, checked together:
   - `pgrep -af '^(\S*/)?drafter page'` prints nothing (a read only; nothing signals what it
     lists). The anchored pattern keeps `pgrep` from matching a shell whose command line merely
     contains the words.
   - `/var/home/glw907/Projects/initiatives/docs-system/research/2026-10-25-extend-pages-batch-5/RESUME.md`
     says batch 5's drafting is done.
   - cairn's outline on `origin/main` lists `docs/extend/upgrade-cairn.md` and
     `docs/extend/choose-an-ai-posture.md` (`git -C /var/home/glw907/Projects/cairn-cms show
     origin/main:blueprints/outline.yaml | grep -E 'path: docs/extend/(upgrade-cairn|choose-an-ai-posture)\.md'`
     prints both), since the unlisted-link error otherwise stops `drafter page` at stage 1 on the
     nine blueprints T1 names. cairn-cms BACKLOG #56 carries `choose-an-ai-posture` as a
     `managed: false` entry and is open on `origin/main` (`75b6138`); `upgrade-cairn` has no item
     yet, and the hand-over appends it to #56.
   The pull waits because `~/.claude/skills/blueprint` and `~/.claude/workflows/docs-page-chain.js`
   are symlinks into the main checkout: a pull alone puts a skill naming `drafter page --commit`,
   `drafter brief --sync`, and `drafter outline` with no slug before sessions still running the
   old binary. Until all three hold, STATUS's next action says the main checkout is stale and the
   pull and install wait, naming which condition is unmet; pass-core "Close" allows a stale
   checkout so reported. The session that finds them met pulls, runs `make install`, and checks
   `drafter --version`. The pass itself never runs `make install`.
4. A review finding that a design form could satisfy with a smaller change takes that change and
   lists it in `## Decisions`. Only a finding that needs a different form stops.
5. A cause that returns after its fix gets one structural fix, then escalates in the PR body. These
   can be escalated that way without breaking the outcome: T5's #83 (today's blocking wait stays),
   T1's #86 and #90, T3's step-order and snippet comparisons, and T6's #107. T2's #84, T1's #89,
   T5's #104, T6's #109, and T7 cannot. If one of those still fails after its structural fix, the
   remaining tasks and the close still run, and the PR reports the item unmet in its Brief; the
   conductor's packet raises it as a `gate-failed` ask.
6. The merge waits for the approval-queue PR that adds `approval-queue pending`, since the skill
   names it. If Geoff approves this PR first, the conductor holds the merge and says so in STATUS.
   If that PR closes unmerged, the conductor pushes one commit removing the skill's `pending`
   sentence, runs the gate, and sends a new packet for the changed head.
7. If the approval-queue pass names its commands differently from the skill's line, the conductor
   sends the executor the names before PR-ready, or after it pushes one commit with them and runs
   the gate before the packet.
8. cairn's unnamed check reporting more errors after this pass (the unlisted-link error) is
   expected, not a stop: the PR records the totals, and the conductor's cairn follow-up lists the
   pages to mark `managed: false`.
9. Cross-repo backlog items are filed from a worktree when another session is live in that
   checkout (`claude agents --json`), never by racing it.

## Merge order and hand-over

One PR, merged after the approval-queue PR that adds `approval-queue pending` (standing answer 6;
conductor-approval-queue owns that PR and messages conductor-drafter when it merges, per its plan's
"Merge order and hand-over" step 3). That plan names the pre-pass decisions `pending` lists on the
live state (batch 4's P12 page items) as conductor-drafter's. They are cairn page approvals, so
taking one over is not this pass's work: the conductor records them, with the `pending` output, in
drafter's STATUS hand-over for the session that owns cairn's pages. conductor-drafter sends one packet (the PR, its
`## Decisions`, and the end-to-end outputs), merges on Geoff's approve with `--match-head-commit`,
and pulls the main checkout and installs only under standing answer 3, checking `drafter
--version` answers when it does; until then STATUS reports the checkout stale.

Then it files the follow-ups through `log-issue`, each tagged `#initiative:docs-system`:

- cairn-cms `BACKLOG.md` (from a worktree when a session is live in the cairn-cms checkout, as one
  is today):
  - anchor the remaining anchorless pointers, with the count the e2e recorded, after which
    drafter's ratchet second step makes the unnamed run fail too;
  - set `facts.prose_sources` to globs for the template READMEs in `drafter.toml`
    (`path.Match` form, such as `templates/*/README.md` and `templates/*/src/*/README.md`);
  - set `facts.id_command = "node scripts/checks/check-facts.mjs --mint"` in `drafter.toml`;
  - loosen `docs/internal/docs-register.md`'s task-guide item 5 so a feature with no log event
    points at the checks that settle it (drafter #102);
  - and append to cairn #56 the unlisted `docs/extend` pages the unlisted-link error names:
    `upgrade-cairn.md` (linked by seven blueprints) and `share-a-draft-preview.md` (linked by
    none today) beside the `choose-an-ai-posture` entry #56 already carries, noting that drafter's
    install waits on the first two.
  The push target for that backlog commit is glw907/cairn-cms, `git push origin HEAD:main` from
  the worktree.

Then it lands the drafter STATUS hand-over on a branch, gated, and merged by itself. It pulls the
main checkout only under standing answer 3; otherwise the merged STATUS says the checkout is stale
and which condition the pull and install wait on.
