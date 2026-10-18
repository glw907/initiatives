# B2 plan review: mechanics and feasibility

Reviewer: `plan-reviewer`, at plan commit `b7c25f1`, against drafter `9915232`, cairn-cms `50dc211d9`,
dotfiles HEAD. Probes read-only. Verdict: does not run as written. 1 blocker, 10 majors (one owner
fork), 15 minors. Saved by the planning session from the agent's reply.

## Blocker

1. **B2.5 has no drafter config, so every read exits 2** (blocker, correctness). plan:172-181;
   `internal/config/validate.go:40`; cairn's `drafter.toml`. cairn's `prompts` and seat agent paths
   live only in the ignored `drafter.local.toml`, absent in the main checkout and in any new worktree.
   Probe: `drafter config` in cairn-cms prints `prompts = (unset)` and `prompts is not set`;
   `Validate(ScopeRun)` refuses every read. B1 handled it (B1 plan:519-523): copy
   `~/.config/drafter/cairn-cms.local.toml` to `<cairn wt>/drafter.local.toml`, `git check-ignore` it,
   confirm `drafter config --json` shows `prompts`. Fold: add those steps to B2.5's "Before it".

## Major

2. **B2.5 installs an unreviewed branch over the live workstation** (major, correctness).
   plan:175-177, Merge order plan:196-197. `make install` from the worktree overwrites
   `~/.local/bin/drafter`, re-links `~/.claude/workflows/docs-page-chain.js` (other cairn sessions run
   it), and links an unreviewed skill into user scope until the post-merge install; links dangle if
   the worktree goes first, and stay on the branch if the PR is declined. B1 ran "the worktree's own
   binary with `DRAFTER_PROMPTS` set ... never the installed `drafter`". Fold: run
   `<drafter wt>/drafter read` by path with `DRAFTER_PROMPTS=<drafter wt>/claude/.claude/workflows/docs-page-chain.js`;
   the installed binary is fine for `check` and `refs` (unchanged in B2). Expose only the skill: a
   temporary `ln -sfn <wt>/claude/.claude/skills/blueprint ~/.claude/skills/blueprint` removed after
   B2.5, or a copy in the format-test worktree's `.claude/skills/` if finding 8's `claude -p` route is
   taken.
3. **The pair tasks edit the same files** (major, correctness). plan:140-144, :154-155, :165-166.
   B2.3 and B2.4 both edit the `Makefile` install recipe (B2.4 also `check`); B2.2 and B2.3 both may
   edit `docs/blueprint-format.md`. pass-core "Pairs" requires disjoint files. Fold: B2.3 owns every
   `install` change, including the hook-script link and its `tests/install.test.sh` assertion; B2.4
   touches only the `check` target or runs after the pair merges; B2.2 documents `--since` in
   `--help` only.
4. **Resolution 6 moves the catalog's home** (major, correctness). plan:83-85 against plan:157-159.
   The catalog lives at `docs/blueprint-format.md:333` ("## The edit catalog"), held there by
   `internal/blueprint/catalog_test.go:13`. Architecture spec:256-257: "The format reference in
   drafter's docs is the format's one home. The schema, the edit catalog, and the checks follow it,
   and the blueprint skill points at it without copying its rules." Fold: the skill teaches when to
   use each row and links `docs/blueprint-format.md#the-edit-catalog`; drop "home moving to the
   skill" and B2.3's catalog-link edit to the format page.
5. **The byte-identity proof is attributed to tests that cannot give it** (major, correctness).
   plan:65-66, :145-148. `tests/drafter-prompts-parity.sh` compares Node and goja renders, never
   `9915232`'s text. The fake-API harness loads `internal/pipeline/testdata/module.js`, whose
   blueprint seat is `blueprint: () => "Read the blueprint below."` (line 18). Fold: before editing
   the module, capture a golden of the unscoped blueprint render from `9915232`'s real module (matrix
   case `install-widget/blueprint`) and assert equality; extend `cmd/drafter/read_test.go`'s
   `TestRealModuleRendersTheBlueprintSeat` to render with a scope; make `module.js`'s blueprint seat
   echo `c.scope` so a pipeline test proves the ids reach the context. Add `module.js` and the golden
   to B2.2's Files.
6. **Resolution 1 leaves input states unnamed, and one silently widens the read** (major,
   correctness). plan:49-57, :131-134. An empty change set leaves `scope` empty, so the prompt is the
   whole read (#43's failure mode). The page-level list omits `argument`, `preconditions`,
   `dispositions`, `review` (`internal/blueprint/blueprint.go:20-31`). A per-section subtree
   comparison can't see a reorder. Unresolvable `<rev>`, a blueprint that fails decode at `<rev>`, an
   outline absent at `<rev>`, a fact cited from `framing` are unnamed. Fold: any field outside
   `sections` changed -> whole; order of shared ids changed -> whole; empty change set -> no API call,
   print "nothing changed since <rev>", exit 0, no lock write; unresolvable `<rev>` or undecodable
   blueprint at `<rev>` -> exit 2. Add each to B2.1's table.
7. **OWNER FORK: an added section, scoped or whole?** (major, correctness). plan:51-54, :120. The
   plan cites "Scope of a redraft" (spec:398-400: "a section added, removed, or moved, a level
   changed, or a change to the argument, the introduction, the framing, or the page's outline entry")
   yet scopes a new section. Options: (a) the read's own rule, stated as a departure: new section
   scoped to its id; move, level change, removal, page-level change whole. (b) follow the redraft
   rule: tweak 5 reads whole and probably fails on old findings. Recommend (a); the prompt's "a listed
   section's change breaks another section" clause covers the neighbours.
8. **Nothing proves the agent used the skill, and it isn't fresh** (major, correctness). plan:107-113,
   :176-177. `cmp` of the installed `SKILL.md` against the worktree's compares a symlink with its
   target. An Agent-tool subagent loads the main session's CLAUDE.md hierarchy and git status
   (sub-agents doc, "What loads at startup"). Fold: run each tweak as `claude -p --model sonnet
   --effort medium --output-format stream-json --verbose` from the format-test worktree; grep the
   stream for a `Skill` call naming `blueprint`; a tweak with none is recorded as not testing the
   skill. Drop the `cmp`.
9. **Tweak base and reset contradict, risking a false pass** (major, correctness). plan:112-114.
   `--since HEAD~1` assumes one commit; two commits leave part of the change unscoped, so its findings
   go non-blocking. "Each tweak starts from rotate as merged" is false after a kept passing tweak.
   Fold: `base=$(git rev-parse HEAD)` before each dispatch, grade with `--since $base`, `git reset
   --hard <origin/main sha>` before every tweak.
10. **The hook's path rule fails under `/home`** (major, correctness). plan:91-95. `/home` links to
    `var/home`; `--show-toplevel` returns `/var/home/...`, so stripping leaves the path unchanged and
    the hook never fires. `claude-memory-write-check` handles both forms. Fold:
    `rel=$(git -C "$dir" rev-parse --show-prefix)$(basename "$path")`; add a `/home/...` test case.
11. **The end-to-end check names no evidence and edits cairn's main checkout** (major, correctness).
    plan:200-201. `additionalContext` "doesn't appear as a chat message" (hooks doc). Fold: `claude -p
    --output-format stream-json --verbose --include-hook-events` (in `claude --help`) in a throwaway
    cairn worktree, or with Edit denied (PreToolUse fires before the permission check); grep the
    stream for the context string; `migration-notes.md` shows none.

## Minor

12. **`vale` passes on zero files** (correctness). plan:159. drafter has no `.vale.ini`; `vale
    docs/blueprint-format.md` prints "0 errors ... in 0 files". With `--config
    ~/Projects/cairn-cms/.vale.ini`, 2 errors in 1 file. Fold: name the config; require "in 2 files".
13. **B2.1 can't read facts at `<rev>` from `internal/blueprint` alone** (correctness). plan:131;
    `internal/plan/facts.go:131`. `plan.LoadFacts` reads a directory; `extractBullets` is unexported.
    Fold: `git archive <rev> <facts.dir>` into a temp dir and `LoadFacts` there, compare `Fact.Text`
    by id; or export a bytes parser and add `internal/plan` to Files.
14. **B2.2's Files list is incomplete** (correctness). plan:140-144. Also `internal/pipeline/pipeline.go`
    (Options), `start.go` (`addPages`), `work.go`, `testdata/module.js`. Fold: keep `since` and the
    scope in the `work` struct, which `resume.go`'s `rehydrate` decodes, so `resume.go` stays
    untouched; `omitempty`; `StateSchema = 2` unchanged.
15. **`--since` with `--resume` may exit 1** (correctness). plan:69, :146. Cobra's
    `MarkFlagsMutuallyExclusive` error goes through `ValidateFlagGroups` (cobra `command.go:1010`), not
    FlagErrorFunc; `main.go:38` exits 1. Fold: reject the pair in `RunE` via `usageError`.
16. **Non-blocking findings on an `ok` read never reach `record.json`** (correctness).
    `internal/pipeline/blueprint.go:158` records findings only on `fix`. Fold: read them from
    `<run dir>/<page>/responses/*.json`, or record on every verdict.
17. **The consistency seat isn't scoped** (correctness). plan:112-113, 178-179. Fold: a consistency
    conflict fails the tweak and is classified like any finding.
18. **Resolution 4 doesn't cover a `--since` read that came out whole** (correctness). plan:71-74.
    Fold: the condition applies only with a non-empty scope; a whole read writes the lock as today.
19. **The plain-HOME install test fails without `install -d`** (correctness). plan:76-79. Fold:
    `install -d $(CLAUDE_DIR)/skills` before the link.
20. **Join the existing `Write|Edit` group** (optional). plan:102-103. dotfiles `settings.json` has a
    `"Write|Edit"` PreToolUse group (`claude-secret-guard`, `claude-memory-write-check`). Fold: append.
21. **Guard a missing `jq` and a missing directory** (correctness). plan:96-97, 100-101. `set -euo
    pipefail` exits 127 without `jq`; `git -C` exits 128 on a Write into a new directory; both show a
    hook-error notice. Fold: `command -v jq >/dev/null || exit 0`, `|| exit 0` on git; test the
    new-directory case.
22. **B2.5's clock and batch waits** (optional). plan:24-25, :172. `claude-clock-stop` finds the clock
    from the hook's `cwd`. Fold: `cd` into the cairn worktree for B2.5; optionally `--sync`, about
    $0.44 a read, about $2.2 for five, no batch waits.
23. **Process form** (optional). plan:127-170. No per-task risk-class line; B2.1 is a single
    deliverable only B2.2 uses. Fold: fold B2.1 into B2.2 at 210 minutes (path unchanged at 420); add
    class lines.
24. **The launch `pgrep` matches itself** (optional). plan:40. Fold: rely on `claude agents --json`
    and `git status`, or filter `$$`.
25. **Tweak 2 may have no fitting target** (correctness). plan:118. A fact edit scopes every citing
    section; avoid the round-6 sections (`delete-the-old-key`, `roll-back-to-the-old-key`, key
    generation and push steps). Fold: pick the fact with `drafter refs` first and check its citing
    sections against the round-6 table.
26. **Standing answer 3 is ambiguous mid-test** (correctness). plan:31-32. Fold: all five run, and the
    result closes B2.
27. **Line citation off** (optional). plan:88. `framingPrompt` runs 1318 to before `applyFraming` at
    1407; the span is `997-1406`.

## Verified as stated

`docs-page-chain.js:327` and the `scope || undefined` adapters; `SectionHashes` hashes page text;
`~/.claude/skills` is a real directory of per-skill links; rotate's `drafted.lock` entry has no
`accepted`; `migration-notes.md` and the rotate page exist and only rotate has a blueprint; `drafter
spend --json` fields and the `cycle cap`/`spend limit` strings; `scripts/drafter-gate.sh` and exit 75;
`claude-tooling-sync verify` flags only a personal skill shadowing a project skill, so no collision;
the path sums to 420; PreToolUse hooks fire inside subagents; symlinked skill directories work; cairn
has no commit hooks.
