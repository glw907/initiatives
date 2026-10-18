# drafter pass B2 plan: the blueprint skill, the hook, the scoped read, and the format test

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-b2-design.md`, approved by Geoff
on 2026-10-18 (glw907/initiatives#13, merge `068d1c0`). It builds the B2 row of
`specs/2026-10-17-blueprint-architecture-design.md` ("Claude infrastructure", "New"; "The pilot",
the format test) plus the scoped read Geoff moved forward from B3 on 2026-10-18. Facts below are
quoted at drafter `9915232`, cairn-cms `50dc211d9`, and dotfiles `HEAD` on 2026-10-18. Review fold:
`research/2026-10-18-drafter-b2-plan-fold.md`.

## Outcome

A live agent has the blueprint skill and a reminder hook, `drafter read --since <rev>` reads only
the sections a change touched, and the format test has run: a fresh headless Sonnet session at
medium effort, with only the skill, made five catalog tweaks to cairn's rotate blueprint, each
graded by `drafter check` and the scoped read on its first try. The bar is four of five. A miss
closes the pass with the result (standing answer 2).

- Risk class `runner` (a skill, a hook, a workflow prompt). `live-account`: API credit.
- Path estimate: 495 minutes. B2.1 (240) paired with B2.2 (140), with B2.3 (55) beside them in the
  pair's shadow, then B2.3's `check` line after the merge (5), B2.4 (155), Close (45), plus 50 for
  the dotfiles PR and the post-merge rows. The design's estimate is 300; 495 is 1.65x, inside
  standing answer 1 (proceed up to 780).
- Clock file: the drafter worktree's git dir, except B2.4, which runs with its shell `cd`'d into the
  cairn worktree and writes the clock in that worktree's git dir. A wait on Geoff removes it first.
- Pair subagents run on `sonnet` at `medium`, `description` `b2-blueprint-skill task <n>`.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-18):
  1. A plan between 600 and 780 path minutes proceeds; above 780 stops.
  2. A format test below four of five closes B2 with the result. The ergonomics pass becomes the
     next pass's design, and B3 waits on it. All five tweaks run regardless of earlier results.
  3. A scoped read that still raises findings on untouched content records them as bar defects in
     the PR and closes B2. drafter#43 stays open with that evidence.
  4. Live spend up to $10 runs without asking. The meter is `drafter spend --since 2026-10-18
     --json`, its `total` plus `open.worst`. Each live run sets `DRAFTER_PAGE_CAP` to the smaller of
     2 and 10 minus the meter; a cap under $1 stops for Geoff. Exit 3 with `cycle cap` or `spend
     limit`, or a page escalated on rule `cap`, stops for Geoff after `notify-send -u normal`. Any
     other exit 3 gets one `drafter read --resume <run-id>` with the same blueprint arguments and
     without `--since` (the run's state carries the scope); a second stops.
- Depends on, checked at launch:
  - One executor per worktree: `pgrep -f` on the two worktree paths this pass creates finds
    nothing, `claude agents --json` shows no session in drafter, cairn-cms, or dotfiles, and all
    three main checkouts are clean (`git status --porcelain`) and on their default branch. Existing
    clean worktrees of other passes (cairn's `repo-organization`, drafter's `agent-*`) do not block.
  - drafter `origin/main` at or after `9915232`; cairn-cms `origin/main` at or after `50dc211d9`
    (holds `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml` and `drafter.toml`'s
    `[seat.blueprint]`).
  - `DRAFTER_API_KEY` in `~/.local/secrets` (by name); `drafter spend --json` shows `open.count` 0.

## Design resolutions

1. **What "changed sections" means.** `drafter read --since <rev>` resolves `<rev>` to a SHA once
   and decodes each blueprint at that SHA and at the run's start commit. Each page comes out in one
   of three states:
   - **Scoped**: the changed section ids. A section is changed when its id is new or its YAML
     subtree differs after decode and re-marshal (so formatting alone never counts). A cited fact's
     bullet changed since `<rev>` marks every section that places or cites it (call 5).
   - **Whole**: a section removed, a change in the order of the ids both versions share, a level
     change, any change to a field outside `sections` (`argument`, `introduction`, `framing`,
     `orderReason`, `preconditions`, `exemplars`, `dispositions`, `constraints`, `review`; so a
     changed fact cited from `framing` also makes it whole), a change to the page's `outline.yaml`
     entry, or a blueprint absent or undecodable at `<rev>` (fail closed).
   - **Unchanged**: no API call for that page; drafter prints `nothing changed since <rev>` and
     writes no lock. A run whose every page is unchanged exits 0.

   An unresolvable `<rev>` exits 2. An added section is scoped, a deliberate departure from the
   architecture's "Scope of a redraft", which makes it whole: that rule decides what a redraft
   rewrites, and this one decides only which findings may block a read that sees the whole
   blueprint anyway. Facts at `<rev>` come from `git show` of the facts files parsed with the
   existing bullet parser (exported from `internal/plan` if needed). `SectionHashes` hashes page
   text, never blueprint sections, so the comparison is new code in `internal/blueprint`.
2. **How the prompt learns the scope.** The seat context already carries `scope` (header comment,
   `docs-page-chain.js:327`). drafter sets `scope` to a scoped page's ids, comma-separated, and
   leaves it empty for a whole read. `DRAFTER_SEATS.blueprint` passes `c.scope || undefined` to
   `blueprintPrompt(scope)`. With a scope, the prompt adds one paragraph: the listed sections
   changed; read the whole blueprint for context; return a blocking finding only when its location
   is a listed section, or when a listed section now fails another section's `requires`, or a
   failure item elsewhere now names a step that no longer exists; report anything else as
   non-blocking. With no scope the prompt is byte-identical to `9915232`'s, proved by a golden of
   that render; the parity test proves only that Node and goja agree. The consistency read stays
   whole: a conflict fails the tweak in the raw count and is classified like any finding. drafter
   prints each page's scope (ids, whole and why, or unchanged) on stdout and in `--json`.
3. **`--since` across a resume.** The run records the resolved since SHA once and each page's state
   and ids in that page's `work` struct, which `resume.go`'s `rehydrate` already decodes. Every
   decision that depends on the scope (the prompt and the lock rule) reads it from state on a
   resume, so `--resume` needs no `--since`. `--since` and `--resume` together is rejected in `RunE`
   through `usageError` (exit 2). The fields are additive with `omitempty` and `StateSchema` stays
   2, so an older state resumes as whole. `internal/pipeline/money.go` and `resume.go` stay
   untouched; if the state field forces a change to either, the line stops.
4. **What an accept writes.** A scoped accept never writes `drafted.lock` in B2; it prints one line
   saying so. B3 designs scoped lock acceptance with the default base. A whole read, including a
   `--since` read that came out whole, writes the lock as today.
5. **The skill's home and install.** `claude/.claude/skills/blueprint/SKILL.md` and
   `claude/.claude/skills/blueprint/new-page.md` in drafter. `make install` adds `install -d
   $(CLAUDE_DIR)/skills`, then `ln -sfn $(CURDIR)/claude/.claude/skills/blueprint
   $(CLAUDE_DIR)/skills/blueprint`, and adds `$(CLAUDE_DIR)/skills` to its symlink guard;
   `~/.claude/skills` is a real directory of per-skill links today. It also links
   `bin/.local/bin/drafter-page-hook` into `$(PREFIX)/bin` like `cairn-docs-outline`.
   `tests/install.test.sh` gains both assertions.
6. **The skill's content.** SKILL.md frontmatter `name: blueprint` and a `description` that triggers
   on changing documented behavior, a docs deficiency, a new docs page, `blueprints/`, and
   `drafter check` or `refs`. The body teaches the three cases from "How a change starts", when to
   use each row of the edit catalog with a link to `docs/blueprint-format.md#the-edit-catalog` (the
   format page stays the catalog's one home, per the architecture's "one home" rule and
   `catalog_test.go`), `drafter check` in the loop, `drafter refs` before a fact correction, the one
   prose exception, and that page prose is otherwise off limits. Every format rule is a link into
   `docs/blueprint-format.md` by heading, never a copy. `new-page.md` carries the new-page procedure
   from `pageInputsPrompt`, `planPrompt`, and `framingPrompt` (`docs-page-chain.js:997-1406`),
   restated for an agent writing a blueprint and an outline entry rather than a plan file. The
   chain's three prompts stay as they are (design, "Out of scope").
7. **The hook.** `bin/.local/bin/drafter-page-hook`, bash and `jq`, the output shape of
   `~/.dotfiles/bin/.local/bin/claude-memory-write-check` but without `set -e`: every path ends in
   `exit 0`, and a missing `jq` exits 0 at once. It reads `tool_input.file_path` from the
   `PreToolUse` payload. For a path ending `.md`, it walks up to the first existing ancestor
   directory and takes `git -C <dir> rev-parse --show-prefix` plus the remainder as the repo-relative
   path, so a `/home/...` path matches though git reports `/var/home/...`. When `<top>/blueprints/`
   is a directory and `<top>/blueprints/<rel minus .md>.blueprint.yaml` exists, it prints
   `{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: <msg>}}` naming the
   blueprint's path, the blueprint skill, and the gate-demanded prose exception. Every other case
   exits 0 with no output. It reads the convention root only; a project that moved
   `blueprints.root` gets no reminder, which the architecture's "fires only in a repo with a
   `blueprints/` root" accepts.
8. **The settings entry.** The command `command -v drafter-page-hook >/dev/null &&
   drafter-page-hook || true`, timeout 10, appended to the existing `Write|Edit` `PreToolUse` group
   in `~/.dotfiles/claude/.claude/settings.json` (beside `claude-secret-guard`) through the
   `update-config` skill. Claude Code runs a hook command through `/bin/sh` (probed 2026-10-18), so
   a host without drafter installed, such as thinkpad-x1, gets a silent no-op. A
   `claude-tooling.md` "Layout" row names skills authored in drafter. It lands as a dotfiles PR
   merged after the drafter PR and its install. `claude-tooling-sync apply` then `verify` runs
   after that merge.
9. **The format test's protocol.** In `~/Projects/cairn-cms/.claude/worktrees/format-test` (branch
   `format-test` from `origin/main` at SHA `<base>`, never pushed):
   - Live reads run `<drafter wt>/drafter read --sync` by path with
     `DRAFTER_PROMPTS=<drafter wt>/claude/.claude/workflows/docs-page-chain.js`, never a branch
     install over the workstation. The installed `drafter` serves `check` and `refs`, which B2 does
     not change. The skill is exposed for the test only, as `ln -sfn <drafter
     wt>/claude/.claude/skills/blueprint ~/.claude/skills/blueprint`, removed when B2.4 ends.
   - Each tweak is a fresh headless session from the format-test worktree: `claude -p --model
     sonnet --effort medium --permission-mode acceptEdits --output-format stream-json --verbose
     --allowedTools "Bash(git *) Bash(drafter *)" --disallowedTools "Bash(drafter read *)
     Bash(git push *)"` (deny beats allow headless, probed 2026-10-18). The prompt is the tweak's
     request and "use the blueprint skill", nothing else.
   - Each prompt names behavior in a developer's words and carries no section id, item id, fact id,
     item kind, field name, or drafter command. The executor picks the content from cairn's code
     before dispatch, so the tweak's facts are true, and the prompt goes verbatim into the row.
   - Before each tweak: `git reset --hard <base>`, so every tweak starts from rotate as merged and
     any lock a prior whole read wrote is gone. Record the cairn and drafter main checkouts' status.
   - After each tweak: exactly one new commit (`git rev-list --count <base>..HEAD` is 1), no
     upstream, both main checkouts unchanged; any other outcome is a protocol breach and a miss. The
     transcript must show a `Skill` call naming `blueprint` and no read under
     `~/Projects/initiatives` or of `docs-page-chain.js`; otherwise a breach and a miss.
   - Grade: `drafter check` on the commit, then, only when it passes, `<drafter wt>/drafter read
     --sync --since <base> <blueprint>`. A tweak passes when `drafter check` is green and the read
     exits 0 with zero blocking findings. The bar is the raw count of passes. Each finding is
     classified blueprint gap or bar defect, as B1 did, and a count excluding tweaks failed only by
     bar defects is reported for diagnosis only.
   - The five tweaks, each from the edit catalog and each aimed at a section with no open finding in
     B1's round 6 (`delete-the-old-key`, `roll-back-to-the-old-key`, and the key generation and push
     steps are out):
     1. Add a worked example to a section that has none.
     2. Correct a fact the blueprint places. The executor picks the fact with `drafter refs` first
        and checks its citing sections against the round-6 list; the skill, not the prompt, should
        send the agent to `drafter refs`.
     3. Add a failure and its handler to a step that can fail.
     4. Add a caveat that rests on an existing fact.
     5. Add a section.
   - One seeded control, run by the executor and outside the bar: a commit to a clean section whose
     step relies on state no earlier step produces, with `requires` silent. A scoped read is
     expected to block in that section; an `ok` is recorded as a bar defect (a lenient scope).

## Tasks

### B2.1: the scoped comparison, `drafter read --since`, and the scoped prompt (240 min), paired with B2.2

- Outcome: resolutions 1 through 4.
- Risk class: `runner`.
- Files: `internal/blueprint/` (a new file and its test), `internal/plan/facts.go` (only to export
  the bullet parser), `cmd/drafter/read.go` and its test, `internal/pipeline/pipeline.go`
  (Options), `start.go`, `work.go`, `blueprint.go`, `internal/pipeline/testdata/module.js` (its
  blueprint seat echoes `c.scope`), a golden of the unscoped blueprint prompt captured from
  `9915232`'s module before any edit, `claude/.claude/workflows/docs-page-chain.js`
  (`blueprintPrompt`, `DRAFTER_SEATS.blueprint`, the header comment),
  `tests/fixtures/drafter/matrix.json`. The flag is documented in `read`'s `--help` only.
- Acceptance:
  - A table test in `internal/blueprint`: unchanged, reformatted (unchanged), an item edit, a new
    section (scoped), a removed section, a reorder, a level change, a field outside `sections`, an
    outline entry change, a blueprint undecodable at `<rev>` (each whole), and a fact bullet change
    that marks its citing sections.
  - The unscoped render equals the `9915232` golden; `TestRealModuleRendersTheBlueprintSeat` also
    renders with a scope and finds the paragraph and the ids; a fake-API pipeline test shows the ids
    reach the context.
  - An unchanged page makes no API call and prints `nothing changed since <rev>`; an unresolvable
    `<rev>` exits 2; `--since` with `--resume` exits 2; each page's scope prints on stdout and in
    `--json`.
  - Through `runRead`: a scoped accept writes no lock and prints its line; a whole `--since` accept
    writes the lock; a resumed scoped run keeps its scope and writes no lock.
  - The parity test passes with the new scoped matrix case. `git diff --stat 9915232 --
    internal/pipeline/money.go internal/pipeline/resume.go` is empty.
- Test: `make check`.

### B2.2: the blueprint skill and the install (140 min), paired with B2.1

- Outcome: resolutions 5 and 6.
- Risk class: `runner`.
- Files: `claude/.claude/skills/blueprint/SKILL.md`, `claude/.claude/skills/blueprint/new-page.md`,
  `Makefile` (`install` only), `tests/install.test.sh`.
- Acceptance: `make install` with a scratch `HOME` and `CLAUDE_DIR` links the skill and the hook
  script; every link from the skill into `docs/blueprint-format.md` names an existing heading
  (grep); `vale --config ~/Projects/cairn-cms/.vale.ini` on both skill files reports 0 errors in 2
  files. The "link, never copy" rule goes to the Close `diff-reviewer`.
- Test: `make check`.

### B2.3: the hook script (55 min), run by the session beside the pair

- Outcome: resolution 7.
- Risk class: `runner`.
- Files: `bin/.local/bin/drafter-page-hook`, `tests/page-hook.test.sh`; after the pair merges, the
  `Makefile` `check` target gains the test (5 min, on the path).
- Acceptance: the test covers a managed page (output passes `jq -e '.hookSpecificOutput.hookEventName
  == "PreToolUse" and (.hookSpecificOutput.additionalContext |
  contains("rotate-the-github-app-key.blueprint.yaml"))'`), the same page by its `/home/...` path,
  an unmanaged page, a non-`.md` file, a non-repo path, a new file in a missing directory, a
  malformed payload, and a `PATH` without `jq`; every case after the first two exits 0 with no
  output. Against cairn's main checkout, a payload for `docs/extend/rotate-the-github-app-key.md`
  prints the context and one for `docs/extend/migration-notes.md` prints nothing.
- Test: `make check`.

### B2.4: the format test (155 min)

- Outcome: resolution 9, run live; the result table in the PR body.
- Risk class: `runner`, `live-account`.
- Before it, in order: `make -C <drafter wt> build`; create the format-test worktree and record
  `<base>`; copy `~/.config/drafter/cairn-cms.local.toml` to `<cairn wt>/drafter.local.toml`,
  confirm `git -C <cairn wt> check-ignore drafter.local.toml`, and confirm `<drafter wt>/drafter
  config --json` run in the cairn worktree exits 0 and shows `prompts`; link the skill (resolution
  9) and confirm `readlink -f ~/.claude/skills/blueprint` is the worktree's skill directory. Check
  the spend meter before every dispatch.
- Acceptance: five rows and the control row, each appended as it is recorded to
  `<drafter wt git dir>/b2-format-test.md` with the tweak's patch (`git show`) beside it. A row
  holds the verbatim prompt, whether the skill fired, whether `refs` ran before the edit (tweak 2),
  files read outside the worktree and the skill, files the commit touched, `drafter check`'s
  result, the scope used (ids, or whole and why), the read's verdict, blocking count, and cost, and
  every finding classified, non-blocking ones included (from `<run dir>/<page>/responses/*.json`).
  Then the raw pass count against the bar and the diagnostic count. At the end, remove the skill
  link, `git worktree remove` the format-test worktree, and `git branch -D format-test`.
- Live spend: inside standing answer 4.

### Close

- The drafter gate (`DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh`, re-issued on exit 75) on the
  close head; drafter has no CI, so this is the full-suite home.
- Whole-branch `diff-reviewer`, told the rule "every format rule in the skill is a link by heading,
  never a copy"; one fix chain; the gate again.
- The dotfiles PR (resolution 8) from a worktree of `~/.dotfiles`, its own gate `scripts/check.sh`.
- PR bodies open with `## Brief`. The drafter PR body carries the format-test table and patches,
  the classified findings, a comment on drafter#43 with the scoped read's evidence (round-6
  findings reported non-blocking, and the control), and the score. Follow-ups go to `BACKLOG.md`
  through `log-issue`.
- The executor's prompt ends at PR-ready. `conductor-drafter` sends one packet for both PRs and runs
  the merge order.

## Merge order

`conductor-drafter` runs these rows.

1. glw907/drafter (B2), then `git -C ~/Projects/drafter pull --ff-only && make -C ~/Projects/drafter
   install`, then `test -e` on `~/.claude/skills/blueprint`, `~/.local/bin/drafter-page-hook`, and
   `~/.claude/workflows/docs-page-chain.js`. Remove the drafter worktree only after this.
2. glw907/dotfiles (the settings entry and the layout row), then `claude-tooling-sync apply` and
   `claude-tooling-sync verify`.
3. The end-to-end check from the design, in a throwaway cairn worktree removed afterward: a fresh
   `claude -p --output-format stream-json --verbose --include-hook-events` session asked to fix a
   real gap on the rotate page, with no skill named. Its stream shows a `hook_response` carrying the
   blueprint's path, and whether the `blueprint` skill fired is recorded (a miss goes to the
   backlog). A second session editing `docs/extend/migration-notes.md` shows no such context.
   `git -C ~/Projects/cairn-cms status --porcelain` is empty at the end.

## Later

- Default `--since` to the lock's accepted blob, with scoped lock acceptance (B3, with the nightly
  run).
- The hook reading `blueprints.root` from `drafter.toml`.
- The chain's front-half prompts pointing at `new-page.md`, or retiring with the chain.
