# drafter pass B2 plan: the blueprint skill, the hook, the scoped read, and the format test

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-b2-design.md`, approved by Geoff
on 2026-10-18 (glw907/initiatives#13, merge `068d1c0`). It builds the B2 row of
`specs/2026-10-17-blueprint-architecture-design.md` ("Claude infrastructure", "New"; "The pilot",
the format test) plus the scoped read Geoff moved forward from B3 on 2026-10-18. Facts below are
quoted at drafter `9915232`, cairn-cms `50dc211d9`, and dotfiles `HEAD` on 2026-10-18.

## Outcome

A live agent has the blueprint skill and a reminder hook, `drafter read --since <rev>` reads only
the sections a change touched, and the format test has run: a fresh Sonnet agent at medium effort,
with only the skill, made five catalog tweaks to cairn's rotate blueprint, each graded by `drafter
check` and the scoped read on its first try. The bar is four of five. A miss closes the pass with
the result (standing answer 2).

- Risk class `runner` (a skill, a hook, a workflow prompt). `live-account`: API credit.
- Path estimate: 420 minutes. B2.1 (60), then B2.2 and B2.3 as a pair (150, B2.2's figure) with
  B2.4 (45) beside them in the pair's shadow, then B2.5 (120, not counting batch waits), Close (45),
  plus 45 for the dotfiles PR and the post-merge rows. The design's estimate is 300; 420 is 1.4x,
  inside standing answer 1 (proceed up to 780).
- Clock file: the drafter worktree's git dir, except B2.5, which writes it in the cairn worktree's
  git dir. A wait on Geoff removes it first.
- Pair subagents run on `sonnet` at `medium`, `description` `b2-blueprint-skill task <n>`.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-18):
  1. A plan between 600 and 780 path minutes proceeds; above 780 stops.
  2. A format test below four of five closes B2 with the result. The ergonomics pass becomes the
     next pass's design, and B3 waits on it.
  3. A scoped read that still raises findings on untouched content records them as bar defects in
     the PR and closes B2. drafter#43 stays open with that evidence.
  4. Live spend up to $10 runs without asking. The meter is `drafter spend --since 2026-10-18
     --json`, its `total` plus `open.worst`. Each live run sets `DRAFTER_PAGE_CAP` to the smaller of
     2 and 10 minus the meter; a cap under $1 stops for Geoff. Exit 3 with `cycle cap` or `spend
     limit`, or a page escalated on rule `cap`, stops for Geoff after `notify-send -u normal`. Any
     other exit 3 gets one `drafter read --resume <run-id>` with the same arguments; a second stops.
- Depends on, checked at launch:
  - One executor per worktree: no session works drafter, cairn-cms, or dotfiles (`claude agents
    --json`, `pgrep -af 'drafter|cairn-cms|dotfiles'`); all three main checkouts are clean and on
    their default branch; no worktree named `b2-blueprint-skill` or `format-test` exists.
  - drafter `origin/main` at or after `9915232`; cairn-cms `origin/main` at or after `50dc211d9`
    (holds `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml` and `drafter.toml`'s
    `[seat.blueprint]`).
  - `DRAFTER_API_KEY` in `~/.local/secrets` (by name); `drafter spend --json` shows `open.count` 0.

## Design resolutions

1. **What "changed sections" means.** `drafter read --since <rev>` decodes the blueprint at `<rev>`
   and at the run's start commit. A section is changed when its id is new or its YAML subtree
   differs after decode and re-marshal (so formatting alone never counts). A section removed since
   `<rev>`, or any change to a page-level field (`framing`, `orderReason`, `constraints`, the
   introduction, exemplars) or to the page's `outline.yaml` entry, makes the read whole, as the
   architecture's "Scope of a redraft" makes a structural change whole. A blueprint absent at
   `<rev>` reads whole. A cited fact's bullet changed since `<rev>` marks every section that
   places or cites it (call 5). `internal/blueprint/hash.go`'s `SectionHashes` hashes page text,
   never blueprint sections, so the comparison is new code in `internal/blueprint`.
2. **How the prompt learns the scope.** The seat context already carries `scope` (header comment,
   `docs-page-chain.js:327`). drafter sets `scope` to the changed section ids, comma-separated,
   for a scoped read, and leaves it empty otherwise. `DRAFTER_SEATS.blueprint` passes `c.scope ||
   undefined` to `blueprintPrompt(scope)`. With a scope, the prompt adds one paragraph: the listed
   sections changed; read the whole blueprint for context; return a blocking finding only when its
   location is a listed section, or when a listed section's change breaks another section (a
   `requires` it no longer meets, a failure it now causes); report anything else as non-blocking.
   With no scope the prompt is byte-identical to today's, which `tests/drafter-prompts-parity.sh`
   proves with a new matrix case for the scoped render.
3. **`--since` across a resume.** The run's state records the since rev and the computed scope, so
   `--resume` reads the same scope without `--since`. `--since` and `--resume` together is a usage
   error. `internal/pipeline/money.go` and `resume.go` stay untouched; if the state field forces a
   change to either, the line stops.
4. **What a scoped accept writes.** A scoped accept records the blueprint in `drafted.lock` only when
   the blueprint's blob at `<rev>` equals the lock's accepted blob for the page, since only then has
   every unchanged section been read before. Otherwise it accepts, writes nothing, and prints one
   line saying why. Rotate has no accepted blob, so the format test writes no lock.
5. **The skill's home and install.** `claude/.claude/skills/blueprint/SKILL.md` and
   `claude/.claude/skills/blueprint/new-page.md` in drafter. `make install` adds `ln -sfn
   $(CURDIR)/claude/.claude/skills/blueprint $(CLAUDE_DIR)/skills/blueprint` and adds
   `$(CLAUDE_DIR)/skills` to its symlink guard; `~/.claude/skills` is a real directory of per-skill
   links today. `tests/install.test.sh` gains the assertion.
6. **The skill's content.** SKILL.md frontmatter `name: blueprint` and a `description` that triggers
   on changing documented behavior, a docs deficiency, a new docs page, `blueprints/`, and
   `drafter check` or `refs`. The body teaches the three cases from "How a change starts", the edit
   catalog table (copied from the architecture spec, its one home moving to the skill, with
   `docs/blueprint-format.md` linking to it), `drafter check` in the loop, `drafter refs` before a
   fact correction, the one prose exception, and that page prose is otherwise off limits. Every
   format rule is a link into `docs/blueprint-format.md` by heading, never a copy. `new-page.md`
   carries the new-page procedure from `pageInputsPrompt`, `planPrompt`, and `framingPrompt`
   (`docs-page-chain.js:997-1455`), restated for an agent writing a blueprint and an outline entry
   rather than a plan file. The chain's three prompts stay as they are (design, "Out of scope").
7. **The hook.** `bin/.local/bin/drafter-page-hook`, bash and `jq`, the shape of
   `~/.dotfiles/bin/.local/bin/claude-memory-write-check`. It reads `tool_input.file_path` from the
   `PreToolUse` payload. For a path ending `.md`, it finds the repo top with `git -C <dir>
   rev-parse --show-toplevel`; when `<top>/blueprints/` is a directory and
   `<top>/blueprints/<rel minus .md>.blueprint.yaml` exists, it prints
   `{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: <msg>}}` naming the
   blueprint's path, the blueprint skill, and the gate-demanded prose exception. Every other case
   exits 0 with no output, including a missing `jq` or a path outside a repo. It reads the
   convention root only; a project that moved `blueprints.root` gets no reminder, which the
   architecture's "fires only in a repo with a `blueprints/` root" accepts. `make install` links it
   into `$(PREFIX)/bin` like `cairn-docs-outline`. `tests/page-hook.test.sh` covers a managed page,
   an unmanaged page, a non-`.md` file, and a non-repo path, and joins `make check`.
8. **The settings entry.** A `PreToolUse` entry with matcher `Edit|Write` and command
   `drafter-page-hook`, timeout 10, added to `~/.dotfiles/claude/.claude/settings.json` through the
   `update-config` skill, and a `claude-tooling.md` "Layout" row for skills authored in drafter. It
   lands as a dotfiles PR merged after the drafter PR and its install, so the command exists before
   the entry calls it. `claude-tooling-sync apply` then `verify` runs after that merge.
9. **The format test's protocol.** In `~/Projects/cairn-cms/.claude/worktrees/format-test` (branch
   `format-test` from `origin/main`, never pushed), the executor dispatches one Agent-tool subagent,
   `subagent_type: general-purpose`, `model: sonnet`, `effort: medium`, per tweak, five in sequence.
   Each prompt names the worktree, one tweak, and "use the blueprint skill", and nothing else: no
   format page, no plan, no prior tweak. The agent may run `drafter check` itself, and commits its
   change. Its commit is its first try. The executor then runs `drafter check` and `drafter read
   --since HEAD~1 <blueprint>` on that commit and records both. A failing tweak is reverted before
   the next, so each tweak starts from rotate as merged. The five tweaks, each from the edit catalog
   and each aimed at a section with no open finding in B1's round 6:
   1. Add a worked example to a section that has none.
   2. Correct a fact the blueprint places, with `drafter refs` on its id.
   3. Add a failure and its handler to a step that can fail.
   4. Add a caveat that rests on an existing fact.
   5. Add a section.
   The executor picks the concrete content for each from cairn's code before dispatch, so the
   tweak's facts are true, and writes it into the prompt as the request a developer would make.
   Each finding of a failing read is classified blueprint gap or bar defect, as B1 did.

## Tasks

### B2.1: the scoped-section comparison (60 min)

- Outcome: `internal/blueprint` reports a blueprint's changed sections between two versions, or that
  the change is whole, per resolution 1.
- Files: `internal/blueprint/` (a new file and its test).
- Acceptance: a table test covers an unchanged blueprint, a reformatted one (no change), an item
  edit, a new section, a removed section (whole), a page-level field (whole), an outline entry
  change (whole), and a fact bullet change that marks its citing sections.
- Gate: `make check`.

### B2.2: `drafter read --since` and the scoped prompt (150 min), paired with B2.3

- Outcome: resolutions 2, 3, and 4.
- Files: `cmd/drafter/read.go` and its test, the run state's struct in `internal/run` or
  `internal/pipeline` (not `money.go` or `resume.go`), `internal/pipeline/blueprint.go`,
  `claude/.claude/workflows/docs-page-chain.js` (`blueprintPrompt`, `DRAFTER_SEATS.blueprint`, the
  header comment), `tests/fixtures/drafter/matrix.json`, `docs/blueprint-format.md` or the read's
  `--help` for the flag.
- Acceptance: a fake-API test shows a scoped read's prompt carries the scope paragraph and the ids;
  a whole read's prompt is byte-identical to `9915232`'s; `--since` with `--resume` exits 2;
  a resumed scoped run keeps its scope; a scoped accept writes the lock only under resolution 4's
  condition. The parity test passes with the new matrix case.
- Gate: `make check`.

### B2.3: the blueprint skill and its install (150 min), paired with B2.2

- Outcome: resolutions 5 and 6.
- Files: `claude/.claude/skills/blueprint/SKILL.md`, `claude/.claude/skills/blueprint/new-page.md`,
  `Makefile` (`install`), `tests/install.test.sh`, `docs/blueprint-format.md` (the catalog link).
- Acceptance: `make install` with a scratch `CLAUDE_DIR` links the skill; Anthropic's
  `skill-creator` review of the skill raises no blocking issue; `grep` finds no format rule
  restated in the skill that `docs/blueprint-format.md` already holds (the executor checks each
  rule-shaped sentence against the format page). `vale` on both files is clean at error level.
- Gate: `make check`.

### B2.4: the hook script (45 min), run by the session beside the pair

- Outcome: resolution 7.
- Files: `bin/.local/bin/drafter-page-hook`, `tests/page-hook.test.sh`, `Makefile` (`install`,
  `check`).
- Acceptance: the four test cases; against cairn's main checkout, piping a payload for
  `docs/extend/rotate-the-github-app-key.md` prints the context and one for `docs/extend/migration-notes.md`
  prints nothing.
- Gate: `make check`.

### B2.5: install from the worktree and run the format test (120 min plus batch waits)

- Outcome: resolution 9, run live; the result table in the PR body.
- Before it: `make install` from the drafter worktree, so `drafter` on `PATH`, the skill, and the
  hook script are this branch's. The skill loads live; `cmp` the installed `SKILL.md` against the
  worktree's.
- Acceptance: five rows, each with the tweak, the agent's commit, `drafter check`'s result, the
  scoped read's verdict and blocking count, its cost, and each finding classified. The pass rate
  against the bar. The format-test worktree is removed after the table is recorded.
- Live spend: inside standing answer 4.

### Close

- The drafter gate (`DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh`, re-issued on exit 75) on the
  close head; drafter has no CI, so this is the full-suite home.
- Whole-branch `diff-reviewer`; one fix chain; the gate again.
- The dotfiles PR (resolution 8) from a worktree of `~/.dotfiles`, its own gate `scripts/check.sh`.
- PR bodies open with `## Brief`. The drafter PR body carries the format-test table, the classified
  findings, a comment on drafter#43 with the scoped read's evidence, and the score. Follow-ups go to
  `BACKLOG.md` through `log-issue`.
- The executor's prompt ends at PR-ready. `conductor-drafter` sends one packet for both PRs.

## Merge order

1. glw907/drafter (B2), then `make -C ~/Projects/drafter install` from the main checkout, which
   re-links the skill and the hook script from the worktree path to the main checkout.
2. glw907/dotfiles (the settings entry and the layout row), then `claude-tooling-sync apply` and
   `claude-tooling-sync verify`.
3. The end-to-end check from the design: a fresh `claude -p` session in cairn-cms that edits
   `docs/extend/rotate-the-github-app-key.md` receives the hook's context.

## Later

- Default `--since` to the lock's accepted blob (B3, with the nightly run).
- The hook reading `blueprints.root` from `drafter.toml`.
- The chain's front-half prompts pointing at `new-page.md`, or retiring with the chain.
