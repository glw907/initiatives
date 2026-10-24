# drafter stage-advance plan: each page moves on when its own result is back

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-24-friction-round-2-design.md`,
"The drafter pass (#82)", approved by Geoff on 2026-10-24 (glw907/initiatives#121, merge
`de9140d`), with the ask answered "Let it write that file". This plan carries step 3.

Path estimate: 170 minutes, inside the design's 400-minute standing ceiling.

One `plan-reviewer` read found no blocker. Its probe applied the change in a scratch copy: every
existing pipeline test passed unchanged, a T1-shaped test failed on the old `await` and passed on
the new one, and a resume with one page a stage ahead finished both. Its nine findings are
folded: an observable ordering proof, the skill sentence's section, the live check's artifact, the
merge-order cases, two more stale comments, where the fake's hook goes, a crash-count gotcha, the
sibling-hold fixture, and lower estimates.

The planning session read drafter at `a1fc918`, before drafter-batch-friction merged. That pass's
T5 changes `await` and `waitEnded` in `internal/pipeline/money.go` (a poll line and a `poll`
field). This pass builds on the merged version: the executor re-reads `money.go` after T0 and
keeps T5's printing as it is.

## Pre-flight

Nothing for Geoff. conductor-drafter checks each item just before launch:

- drafter-batch-friction's PR is merged, and the main checkout is pulled to it.
- Nothing about the workstation pass's `~/.dotfiles` PR holds the launch, merged, open, or not yet
  open. Only this PR's merge waits on it (see "Merge order").
- drafter's main checkout is on `main`, `git status --porcelain` prints nothing, and
  `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`.
- No live session other than the conductor works drafter (`claude agents --json`; the stale
  `drafter-blueprint-first-design` row in state `blocked` doesn't count).
- `go`, `golangci-lint`, and `gh` resolve, and `gh auth status` answers.
- This plan and its two prompts are committed on initiatives `main`.

## Outcome

In batch mode, `drafter page` and `drafter read` submit a page's next stage as soon as that page's
own batch is handled, while other pages' batches stay in flight. The blueprint skill tells a
session to name a findings path when it dispatches the fact-checker. drafter #42 and #43 close as
won't-do.

Risk class: `runner` (the skill line). The Go task is `ordinary`. No `live-account`, and no API
credit: the change is proven against the fake API.

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

- Gate: `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` from the worktree, re-issued on exit 75.
  It wraps `make check` (vet, lint, the full suite, `tests/install.test.sh`), the fast lane and
  the full-suite home. drafter has no CI on PRs.
- Go follows `go-conventions` (`/var/home/glw907/.claude/skills/go-conventions/SKILL.md`).
- Fixtures are synthetic. The repo is public: no private path, key, or account detail.
- `claude/.claude/skills/blueprint/SKILL.md` is a regular file. approval-queue's two passes also
  edit it, on other lines; a merge conflict there is resolved by keeping both sides.

## Tasks

### T0. Enter the worktree (5 min)

`EnterWorktree` with the name `stage-advance`, from the drafter main checkout. Arm the API-drop
wake-up (`/loop` with no interval). Acceptance: the branch is `worktree-stage-advance`, the gate
is green on the untouched tree, and `git log -1 --oneline` shows the batch-friction merge or later.

### T1. Advance each page on its own result (#82) (75 min, ordinary)

Outcome: a page whose batch is handled gets its next stage submitted while another page's batch is
still in flight.

Files: `internal/pipeline/money.go` (`await`), `internal/pipeline/pipeline.go` (`loop`, its doc
comment "loop runs waves"), `internal/pipeline/fake_test.go`, and a new or existing pipeline test
file.

- `await` returns once a pass over `r.inflight` has handled at least one ended batch, leaving the
  rest in flight. With none ended, it sleeps and polls again, as today. `loop` already skips a
  page with an open intent (`p.ps.Open() != nil`) and goes back to the top after `await`, so the
  handled page advances, submits, and the loop awaits again.
- Three doc comments stop describing waves: `loop`'s ("loop runs waves"), `await`'s ("until each
  has ended and been read"), and `releaseHeld`'s ("another wave can make progress").
- Unchanged: `submitUnit`'s count, reserve, record, and send order; the ledger; the intents;
  `releaseHeld`; sync mode; resume.
- The fake: `fakeAPI` gains a per-batch poll count (for example
  `pollsFor func(ids []string) int`, consulted before `pollsToEnd`), so one page's batch ends at
  the first poll and another's at the fifth. After batch-friction, `Get` and `List` both build
  their result through `batchOf` in `fake_test.go`; the hook goes there so the two agree.
- `Create` calls the fake's `crash` hook twice per call ("before" and "after"), so a test that
  crashes on the nth create counts in `onSubmit` or keys on the custom id, never on a call count.

Acceptance: the gate is green, and tests cover three cases. First, two pages where A's batches
end on the first poll and B's first batch ends on the fourth (`PagesInFlight` at its default):
in `onSubmit`, at A's second-stage create, the fake batch holding B's first request has not yet
reported ended (`polls <= pollsFor(B)`). `fakeAPI.calls` holds bare call names, so it can't show
this. The check reads false on the old `await` and true on the new one. Second, a run that
crashes at A's second-stage create while B's first batch is in flight, then resumes and finishes
both. Third, the sibling hold with B's fix batches late through `pollsFor`: A gates and is held
while B's batch is in flight, then B ends and `releaseHeld` regates A. Every existing pipeline test passes
unchanged, or the PR's `## Decisions` names each changed expectation and why the old one encoded
waves.

### T2. The skill line and the backlog (#31's line, #42, #43) (15 min, runner)

Outcome: the skill tells a session to name a findings path, and the converter items close.

Files: `claude/.claude/skills/blueprint/SKILL.md`, `BACKLOG.md`.

- In the `## Fact-check` section (line 30, one long line), the sentence "Save the array verbatim to
  `${XDG_STATE_HOME:-$HOME/.local/state}/approval-queue/findings/<repo>/<file path with / as __>/<commit>.json`."
  becomes: name that path in the dispatch, and the agent writes the array there and checks it.
  Keep the path as written. Nothing else in the file changes.
- `BACKLOG.md`: #42 and #43 move to Done as won't-do, citing Geoff's 2026-10-24 ruling (every new
  page starts from a prose plan; the legacy YAML blueprints convert by hand when next touched).
  #82 ticks with the PR number.

Acceptance: the gate is green; `git diff --word-diff` on `SKILL.md` touches one sentence.

### C. Close (60 min)

1. Whole-branch `diff-reviewer` against the design and this plan, one batched fix chain, the gate
   again.
2. drafter `docs/STATUS.md`: the pass at PR-ready, and a line in the next action: the next cairn
   docs pass's first multi-page `drafter page` is #82's live check. Read that run's `state.json`:
   each page's `intents[].time` (submit) and `created`, and T5's `poll.seen`. A page whose next
   submit waited for a sibling's batch to end is an escape.
3. Open the PR on glw907/drafter from `worktree-stage-advance` with `## Brief`, what landed, the
   test evidence (T1's ordering check, false before and true after), `## Decisions` (including
   that the proof is the fake, not record times), `## Planning misses`, the found-not-done list
   (at least: `recover` → `findBatch` → `waitEnded` can still hold every page on one untracked
   batch after a create whose outcome is unknown), and the score. Stop at PR-ready and message conductor-drafter.

## Path

T0 5 + T1 75 + T2 15 + C 60 = 155 minutes, written as 170 for the gate reruns. No pairs: T2 is one sentence and a backlog edit.

## Standing answers

1. A clock stop writes its minutes to STATUS, rewrites `start=`, and carries on while the actual
   path stays under 400 minutes. Past 400 the executor stops and the conductor asks Geoff.
2. No API credit: never `make smoke` or `make live`, `drafter page` only with `--dry-run`, and no
   `make install`.
3. A review finding that a smaller change can satisfy takes it and lists it in `## Decisions`.
   Only a finding that needs a different design stops.
4. A cause that returns after its fix gets one structural fix. T1 can't be escalated; if it still
   fails, the executor stops and the conductor asks Geoff.

## Merge order and hand-over

One PR, merged after the workstation pass's `~/.dotfiles` PR. If Geoff approves this PR first, the
conductor holds the merge until that one merges, and says so in STATUS. If that PR closes
unmerged, the conductor asks Geoff once whether to drop T2's skill line and merge the rest; the
recommendation is to ask, since dropping the line changes what he approved. conductor-drafter sends one
packet, merges on Geoff's approve with `--match-head-commit`, pulls the main checkout, runs
`make install` there (under batch-friction's standing answer 5 if run
`20261024T080412Z-13b5d021` is still open), and lands the STATUS hand-over.
