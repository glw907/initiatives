# Drafter pass B2: the blueprint skill, the hook, the scoped read, and the format test

Status: designed 2026-10-18, awaiting Geoff's approval. Initiative: `docs-system`. Builds the B2 row
of the blueprint design's build sequence (`2026-10-17-blueprint-architecture-design.md`, "Claude
infrastructure" and "The pilot"), with one piece of B3 moved forward by Geoff's ruling below.

## Brief

Approving this lets B2 be planned and built without you until its PR. B2 gives live agents the
blueprint skill and a hook that reminds them not to edit page prose. It adds a read that looks only
at the sections a change touched. Then it runs the format test: a fresh Sonnet agent makes five
small edits to cairn's rotate blueprint with only the skill to help.

The scoped read is new to this pass. On 2026-10-18 you ruled that B2 builds it rather than grading
the format test against a baseline. The whole-page read never converged on the rotate blueprint
(drafter#43), so a tweak would otherwise fail on findings it didn't cause. The nightly run needs
the scoped read anyway, and it is #43's convergence rule.

## Outcome

1. **The blueprint skill.** `claude/.claude/skills/blueprint/SKILL.md` in the drafter repo teaches
   when to change a blueprint, the edit catalog, `drafter check` and `drafter refs`, the one prose
   exception, and that page prose is otherwise off limits. Its reference file `new-page.md` carries
   the new-page procedure, built from the guidance in the chain's `pageInputsPrompt`, `planPrompt`,
   and `framingPrompt`. The skill points at `docs/blueprint-format.md` for every format rule and
   copies none. `make install` links it into `~/.claude/skills/blueprint`. The dotfiles'
   `claude-tooling.md` layout table gains the row, and `claude-tooling-sync verify` stays clean.
2. **The hook.** `drafter-page-hook`, in the drafter repo's `bin/.local/bin/` and linked by
   `make install` like `cairn-docs-outline`, runs as a user-scope `PreToolUse` hook on `Edit` and
   `Write`. When the target sits in a repo with a `blueprints/` root and the path rule finds a
   blueprint for it, the hook adds context naming the blueprint, the skill, and the prose exception.
   Otherwise it prints nothing. It never blocks. `claude-memory-write-check` is the working precedent
   for the `additionalContext` output. The hook lands in the tracked dotfiles `settings.json`
   through `update-config` and reaches the live file through `claude-tooling-sync apply`.
3. **The scoped read.** `drafter read --since <rev>` compares each blueprint's section hashes at
   `<rev>` with the working tree and sends the blueprint read only the changed section ids. The
   read sees the whole blueprint but returns blocking findings only located in those sections or
   caused by them. The prompt edit is in `blueprintPrompt` in `docs-page-chain.js`. With no
   `--since`, the read is unchanged.
4. **The format test.** In a throwaway cairn worktree, a fresh agent on `sonnet` at `medium` with the
   blueprint skill and nothing else makes five tweaks from the edit catalog, one commit each: add an
   example, correct a fact, add a failure and its handler, add a caveat, and add a section. A tweak
   passes when `drafter check` is green and `drafter read --since <parent>` answers `ok`, both on
   the agent's first try. The bar is four of five. The result, with each finding classified as
   blueprint gap or bar defect as B1 did, goes into the PR. The tweaks never merge to cairn.

## Out of scope

The chain's front-half prompts stay in place until the chain retires, so the new-page guidance has
two copies for that time. The default base for a read (the lock's accepted hash), the nightly run,
section redrafts, the write-back seat, and any ergonomics fix the format test calls for are later
passes.

## End-to-end check

On a fresh session, an `Edit` to `docs/extend/rotate-the-github-app-key.md` in cairn-cms returns the
hook's context naming the blueprint, and an `Edit` to a page with no blueprint returns nothing. The
format test then runs end to end as Outcome 4 describes.

## Shape

- Risk class `runner`: a skill, a hook, and a workflow prompt. No task touches
  `internal/pipeline/money.go` or `resume.go`; a change to either stops the line.
- `live-account`: yes, for API credit. Budget $10; B1 spent $1.53 on seven reads.
- Repos: `glw907/drafter` (skill, hook script, scoped read, install), `glw907/dotfiles` (the
  settings entry and the layout row), and a cairn-cms throwaway worktree for the test.
- Estimate: 300 path minutes, set from B1's actual of about 240 minutes against a 780-minute plan.

## Standing answers

The planner applies these in place of stopping.

- A plan between 600 and 780 path minutes proceeds, and the hand-over says why. Above 780 stops.
- A format test below four of five closes B2 with the result. The ergonomics pass becomes the next
  pass's design, and B3 waits on it.
- A scoped read that still raises findings on untouched content records them as bar defects in the
  PR and closes B2. #43 stays open with that evidence.
