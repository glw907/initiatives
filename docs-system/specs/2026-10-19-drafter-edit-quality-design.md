# drafter edit-quality pass: the read loop, a reviewer-grade bar, and two mechanical warnings

Status: designed 2026-10-19 from the Fable analysis
(`research/2026-10-19-drafter-edit-quality-analysis.md`) and Geoff's rulings on it; awaiting his
approval. Initiative: `docs-system`. Pass slug `edit-quality`. It runs after F1 and before F2.

## Brief

Approving this changes how drafter judges a blueprint edit, then measures it on the same 21 runs.
The skill-rules pass (glw907/drafter#49) scored 12 of 21 on first-try acceptance. The analysis
found the format sound (21 of 21 edits passed `drafter check`) and the misses in editorial
judgment: link and removal edits passed 6 of 6, caution and section edits 0 of 6. Two misses were
judge variance, prompt 4 asked for something the facts can't support, and the skill's own caution
rule forced a looping handler. Written rules didn't help, because a second fresh read catches what
the author believes it did right.

You ruled on 2026-10-19 that the goal splits in two: `drafter check` green on the first try,
offline, and the read accepting the edit in the author's own session. The read loop is the skill's
default when a key is set. The change read blocks only at reviewer grade, register rules stay out
of blueprint reads, and this lands as a small pass after F1. The reads spend your monthly API
credit, and the fixes run on session tokens with local checks.

## Outcome

1. **The skill's read loop.** `SKILL.md` gains a "Read" step after "Check". It runs
   `drafter check` first, then `drafter read --since <base>` when a key is set. The session fixes
   every blocking finding and any Nits it chooses in one batch, runs `drafter check`, and reads
   again. The last read comes after the last change. After three reads the session commits with the
   open findings in the commit message; the read never blocks the commit, and the nightly read is
   the backstop. With no key, it skips the reads and says so.
2. **Two skill defects fixed.** A caution with no handler a fact supplies becomes the catalog's
   "Add a caveat" row, never a `failure` with an invented handler, and "Check what you add" loses
   that line. A decline rule: when a request conflicts with a fact, or asks for content a section
   already carries, the session makes the smaller edit the catalog allows and says why.
3. **Two `drafter check` warnings.** A failure handler that is only a fact, a lead-in, or a link
   back to the step that failed; and a claim or example that cites no fact. Each warns with a fix
   message and never fails the check. A warning that fires falsely on cairn's blueprints is dropped.
4. **A reviewer-grade change read.** In `blueprintPrompt`, a change-read finding blocks only when
   the change makes the page wrong or leaves the reader stuck: a claim past its fact, invented
   output, a handler that loops or dead-ends, a state no step supplies, a missing step. Order, pace,
   heading form, placement, and a restating `use` come back as "Nit:" and never block. The whole
   read keeps today's bar. House register rules apply in neither blueprint read; the editor seat
   applies them to prose.
5. **Cache order.** The blueprint read's request puts the facts and the register ahead of the
   blueprint and the diff, with a cache breakpoint after them. The ledger reports the second read's
   cost and latency.
6. **A fixed test base.** On the `format-test` branch only, the executor fixes the base
   blueprint's recurring "Already present:" items until the whole read accepts it, and names each
   fix in the PR body for `conductor-drafter` to file in cairn's backlog.
7. **The rerun.** The same seven prompts, three runs each, against the fixed base. Prompt 4 stays
   as the decline test.

## Measures

| Measure | Bar |
|---|---|
| `drafter check` green on the first commit | 21 of 21 |
| Accepted within two reads | 19 of 21 |
| Accepted within three reads | 20 of 21 |
| Commits carrying a change no read saw | 0 of 21 |
| First-try acceptance per edit shape, reads per edit, minutes waiting, spend | Reported |
| Declines on prompt 4 | Counted; a pass when the smaller edit is accepted and the report names why |
| Judge agreement: three misses read twice more | Reported |
| Controls | Both bite; both positive controls accept |

## Out of scope

Moving the read prompt into a stock prompt file, which F2 does and will carry this rule into. A
nightly repair seat (B4 decides). Vale on blueprints: the analysis's probe found 112 of 152 findings
were style noise on planning text, and none of the real misses. Changes to cairn's `main`.

## End-to-end check

The rerun, recorded as #49 recorded it: per run, each read's findings, blocking or Nit, the round
it closed in, and the rule each falls under.

## Shape

- Risk class `runner` (the skill, `drafter check`, the read prompt, the assembler).
  `live-account`: API credit, budget $40 of the $200 monthly credit. Skill-rules spent $15.37;
  this run adds second and third reads, the base's whole reads, and the agreement reads.
- Repos: `glw907/drafter`, plus a throwaway cairn-cms worktree for the test.
- Estimate: 180 path minutes.

## Standing answers

- A plan up to 360 path minutes proceeds.
- A rerun below its bar closes the pass with the result, and the packet asks what's next.
- A base the whole read still blocks after three fix rounds is recorded, and the test runs on it.

## Changes to the architecture spec

The goal "An agent can make a typical small change to a blueprint correctly on its first attempt,
checked offline in seconds" becomes "An agent can make a typical small change to a blueprint with
`drafter check` green on its first attempt, in seconds and offline, and the blueprint read accepts
the change in the same session, within three reads, with no human step" (Geoff, 2026-10-19). The
spec carries an erratum line pointing here.

## Erratum

2026-10-19, planning session: outcome 1's "the nightly read is the backstop" is out of the skill
until B4 builds the nightly read; the skill reports open findings to the user instead. The plan's
reviews also found three mechanics the design didn't name (a read needs a committed tree, `drafter
read` must print its findings, and the cache breakpoint runs through `internal/batch` and `Worst`);
the plan records each as a method-call departure.
