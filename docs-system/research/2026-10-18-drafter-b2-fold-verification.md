# drafter B2 plan: fold verification

Reader: a fresh-context verifier that took no part in the fold. Target:
`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md` at initiatives `cc8930a` (branch
`docs-system-b2-plan`), against the fold record, the three reviews, the approved design, drafter
`9915232`, cairn-cms `50dc211d9`, and dotfiles HEAD. The six rulings were taken as settled. Line
numbers are the plan's unless a file is named.

Verdict: every blocker and major from the three reviews closes at the location the fold record
cites. The tasks can build: B2.1 and B2.2 touch disjoint files, and B2.3's files are disjoint from
both. The path arithmetic holds at 495, and nothing changes the approved design beyond the ruled
departures. The fold did add one mechanism that fails when probed. A headless session cannot read
the format page that the skill now links for every rule. It also left two gaps of major
consequence: the end-to-end check may never fire the hook, and a mixed run cannot resume. Counts:
0 blockers, 3 majors, 8 minors (2 of them optional).

## Probes run (read-only, about $0.02)

- **Headless reads outside the working directory are denied.** A `claude -p --model haiku
  --permission-mode acceptEdits --allowedTools "Bash(git *) Bash(drafter *)"` session in a scratch
  directory asked to Read `~/Projects/drafter/docs/blueprint-format.md`. The read appeared in
  `permission_denials` with the message "Claude requested permissions to read from ... but you
  haven't granted it yet". The user `settings.json` has no Read allow rule.
- **The Skill tool needs no grant headless.** The same session's `Skill` call for `writing-voice`
  ran ("Launching skill"), and the stream shows `{"name":"Skill","input":{"skill":"..."}}`, which
  is the transcript evidence resolution 9 relies on.
- **A trailing variadic flag swallows the prompt.** With the prompt as the last argument after
  `--disallowedTools "..."`, `claude -p` exited 1 with "Input must be provided either through stdin
  or as a prompt argument". With the prompt on stdin, it ran.
- **PreToolUse `additionalContext` is observable.** A `--settings` PreToolUse `Write|Edit` hook
  that printed `hookSpecificOutput.additionalContext` produced a `hook_response` event carrying it
  under `--include-hook-events`, and the model reported receiving it. The fold had probed only a
  `UserPromptSubmit` hook. The no-op guard `command -v zz-absent >/dev/null && zz-absent || true`
  ran in the same hook without error.
- `claude --help` (2.1.302) documents the space-separated rule list with a space inside the parens
  (`"Bash(git *) Edit"`), as well as `--effort medium`, `--include-hook-events`, and `--add-dir`.
- GNU `realpath` resolves a dangling link with exit 0, so `tests/install.test.sh`'s `under_repo`
  passes for a link whose target does not exist yet.

## Findings, ranked by consequence

### 1. The test agent cannot read the format page that the skill links for every rule (major, correctness)

Location: plan:100-110 (resolution 6), plan:138-142 (the `claude -p` line), plan:201-211 (B2.2
acceptance).

Defect: the fold made every format rule in the skill a link into drafter's
`docs/blueprint-format.md` (M4), and made each tweak a headless `claude -p` session in the cairn
worktree (ruling 6). The probe shows that such a session is denied any Read outside its working
directory. The test agent therefore gets SKILL.md and nothing it links to: the catalog, the item
kinds, and `requires` and `produces` all sit behind a denied read. The format test would then grade
a skill stripped of its reference. Misses would land on the format when the cause is the harness,
and the result would not measure what the design asks. A second, related gap: the plan never says
what form the link takes. The skill loads from `~/.claude/skills/blueprint`, a symlink, so a
relative link such as `../../../../docs/blueprint-format.md` resolves textually to the wrong place.
B2.2's grep checks only the anchors, not whether the path resolves.

Fold: in resolution 9, add `--add-dir <the directory holding the linked format page>` to the
`claude -p` line, and count reads there as the skill's own (as C3 intended). In resolution 6, name
the link form, either an absolute workstation path to the drafter checkout's format page or the
form the probe below proves. In B2.4's "Before it", add one probe of about $0.01: a headless
session in the format-test worktree, with the exact flags, invokes the skill and reads one linked
heading, and the stream shows no `permission_denials`.

### 2. The end-to-end check may never fire the hook it is meant to prove (major, correctness)

Location: plan:271-276 (Merge order row 3); design "End-to-end check".

Defect: the design asks that "an `Edit` to `docs/extend/rotate-the-github-app-key.md` ... returns
the hook's context". Row 3 instead asks a session to "fix a real gap on the rotate page" with no
skill named, which merges in C15's trigger test. If the skill triggers, which is the outcome
everyone wants, the agent edits the blueprint and never issues an Edit or Write on the `.md`. The
PreToolUse hook then never runs, and the stream holds no `hook_response`. The row would read as a
hook failure, or it would prove nothing. The row also names no `--permission-mode`.

Fold: split the row. (a) The hook check is a session told to make a named one-line edit to the
rotate page's `.md` file. Its stream must show a `hook_response` carrying the blueprint path. A
second session makes the same kind of edit on `migration-notes.md` and must show none. (b) The
trigger check is a separate session with the "fix a real gap" prompt, recording whether `Skill`
named `blueprint` (a miss goes to the backlog). Name `--permission-mode acceptEdits` for all three
sessions and the `--add-dir` from finding 1. Everything still runs in the throwaway worktree.

### 3. A run that mixes unchanged and changed pages cannot resume (major, correctness)

Location: plan:63-64 (resolution 1, unchanged), plan:83-89 (resolution 3), plan:38-39 (standing
answer 4); `cmd/drafter/read.go:82-96`; `internal/pipeline/resume.go:154-170`.

Defect: an unchanged page makes no API call, so it never enters the run's state. On a resume,
standing answer 4 passes "the same blueprint arguments", and `blueprintHandoffs` builds a handoff
for every argument. `rehydrate` then fails on the unchanged page's handoff with "page X is not in
run R" (`resume.go:164-166`). This contradicts resolution 3's claim that "`--resume` needs no
`--since`". The rule that `resume.go` stays untouched rules out a fix there. The format test reads
one blueprint, so B2.4 does not hit this, but B3's nightly run will.

Fold: in resolution 3, on `--resume` `runRead` keeps only the blueprint arguments whose page key
the loaded state holds, and prints `unchanged (not in run)` for the rest. The change is in
`cmd/drafter/read.go` only. Add a B2.1 acceptance row: a two-page `--since` run, one page
unchanged and one scoped, stopped and resumed with both arguments, exits 0 and writes no lock.

### 4. Standing answer 4's resume names the installed binary, which drops the scope (minor, correctness)

Location: plan:38-39 against plan:133-136.

Defect: standing answer 4 says `drafter read --resume <run-id>`. During B2.4 the installed
`drafter` is `9915232`. Its `work` struct has no scope fields, so it decodes the state without
them. It renders the unscoped prompt, and its `recordAccepted` writes the lock as a whole accept.
The tweak would be graded on a whole read while the row says scoped.

Fold: add "with the binary and `DRAFTER_PROMPTS` the run started with (in B2.4,
`<drafter wt>/drafter`)" to standing answer 4.

### 5. The tweak's prompt must go on stdin (minor, correctness)

Location: plan:138-142.

Defect: `--disallowedTools <tools...>` is variadic and comes last in the plan's command. A prompt
given as the next argument is taken as a tool name, and the session exits 1 (probed).

Fold: "the prompt goes on stdin" (`printf '%s' "$prompt" | claude -p ...`), or place it before
the flags.

### 6. `Bash(drafter *)` lets the test agent draft pages and spend outside the cap (minor, correctness)

Location: plan:140-141.

Defect: the deny list covers only `drafter read`. `drafter page` and `drafter convert` remain
allowed. `drafter page` writes page prose, which is off limits, and spends credit at the user
config's `page_cap = 10`, since the agent's environment does not set `DRAFTER_PAGE_CAP`.

Fold: add `Bash(drafter page *) Bash(drafter convert *)` to `--disallowedTools`. This uses the
same proven mechanism.

### 7. An agent that leaves the tree dirty turns the read into exit 2, and no rule covers that (minor, correctness)

Location: plan:148-151; `internal/pipeline/start.go:88` (`requireClean` counts untracked files).

Defect: the after-tweak checks require one commit and clean main checkouts, but not a clean
format-test worktree. A stray untracked or uncommitted file makes `drafter read` exit 2. That exit
is neither a breach nor a standing-answer case.

Fold: add `git status --porcelain` empty in the format-test worktree to the after-tweak checks.
Any other outcome is a breach and a miss, and the row records the files.

### 8. The format page's `drafter read` section becomes false for a scoped accept (minor, correctness)

Location: plan:90-92 (resolution 4), plan:183 ("documented in `read`'s `--help` only");
`docs/blueprint-format.md:355-364`.

Defect: the format page says that when the run ends, "the accepted blueprints' blob ids go into
the `accepted` field of `drafted.lock`". After B2, a scoped accept writes nothing. M3 moved the
docs to `--help` to keep the pair disjoint, but the M4 fold took B2.2 off the format page. B2.1 can
now own that file without touching B2.2's.

Fold: add `docs/blueprint-format.md` ("What `drafter read` does with a blueprint" only) to B2.1's
Files, with one sentence on `--since` and the no-lock rule.

### 9. B2.2's hook-link assertion must tolerate a missing target (minor, optional)

Location: plan:205-208.

Defect: B2.2 links `bin/.local/bin/drafter-page-hook`, but B2.3 creates that file in another tree.
`under_repo` passes on the dangling link (probed). A `test -x` or `test -e` assertion would fail
B2.2's `make check` until the merge.

Fold: state that the hook-link assertion uses `under_repo`.

### 10. The cairn-checkout half of B2.3's acceptance must stay out of the test file (minor, optional)

Location: plan:223-225.

Defect: as written, "Against cairn's main checkout ..." could land in `tests/page-hook.test.sh`.
That would make `make check` depend on `~/Projects/cairn-cms` and put a private path in a public
repo. drafter's CLAUDE.md requires synthetic fixtures.

Fold: mark it a one-off executor check recorded in the PR. The test file uses a synthetic repo.

## Checked and sound

- Mechanics 1 (config copy) closes at plan:232-235. Mechanics 2 (no branch install) closes at
  plan:133-137. Mechanics 3 (disjoint files) closes at plan:177-218. Mechanics 4 (catalog home)
  closes at plan:102-106. Mechanics 5 (golden) closes at plan:179-190. Mechanics 6 (three states)
  closes at plan:52-66. Mechanics 8 (headless and `Skill` evidence) closes at plan:138-151.
  Mechanics 9 (`<base>`) closes at plan:146-154. Mechanics 10 (`--show-prefix`) closes at
  plan:113-116. Mechanics 11 (worktree and observable) closes at plan:271-276, apart from
  finding 2.
- Contract 1 (seeded control) closes at plan:167-169. Contract 2 (deny rule) and contract 3
  (`Skill` call and reads) close at plan:140-151. Contract 4 (prompt rules) closes at plan:143-145
  and :161-163. Contract 5 was ruled (plan:154-156). Contract 8, 9, and 10 close with the
  mechanics folds.
- Integrity 1 and 13 close at plan:83-89 and :195-196 (`work` is decoded by `rehydrate` from
  `PageState.Work`, as `work.go:83` and `resume.go:168` show; `StateSchema` is 2 at
  `internal/run/state.go:15`). Integrity 2 closes at plan:38-39 (but see finding 4). Integrity 3
  and 4 close at plan:90-92 and :146-147. Integrity 5 closes at plan:266-268. Integrity 6 was
  ruled and is now probed for PreToolUse too. Integrity 7 and 8 close at plan:148-151 and
  :271-276.
- The cited source holds: `usageError` maps to exit 2 (`cmd/drafter/main.go:28`). The seat context
  has `Scope` (`internal/prompts/context.go:55`). `blueprintPrompt()` takes no argument today
  (`docs-page-chain.js:2260`), and `DRAFTER_SEATS.blueprint` ignores the context (:2345).
  `module.js:18` is the static blueprint seat. The install symlink guard loop is in the
  `Makefile`. The `Write|Edit` group holds `claude-secret-guard` and `claude-memory-write-check`
  (dotfiles `settings.json`). Hooks are invoked by bare name, so `~/.local/bin` is on the hook
  `PATH`. `jq` is at `/home/linuxbrew/.linuxbrew/bin`, so a `PATH` without `jq` is easy to build.
  No `~/Projects/*/.claude/skills/blueprint` exists, so `verify`'s collision check stays clean.
- Path: 240 (the pair, with B2.3's 55 in its shadow) + 5 + 155 + 45 + 50 = 495, and 495 / 300 =
  1.65. Both match plan:21-24. The fold record's "420 to 495" (fold:141) is stale, since the parts
  it lists sum to 445 before the 50. It is cosmetic and leaves the plan unchanged.
- Design: Outcome 3's "section hashes ... with the working tree" becomes "the run's start commit".
  These are equivalent because `read` requires a clean tree. Outcome 3's "or caused by them" is
  narrowed to what the read can see (C11). That narrowing is in scope, not a change. "`--since
  <parent>`" equals `<base>` under the one-commit rule. The added-section departure and the
  no-lock rule are the ruled forks. Nothing else departs from the approved design.
