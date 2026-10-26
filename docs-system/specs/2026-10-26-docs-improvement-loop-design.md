# Docs improvement loop

Status: drafted 2026-10-26 for Geoff's approval. Initiative: `docs-system`. Repos: cairn-cms and
the workstation (`~/.dotfiles`). The Approval Queue is used as it stands. Eval runs use headless
`claude -p` sessions on the subscription, and nothing spends API credit.

Inputs: the skills research (`research/2026-10-25-docs-skills-research.md`), the first evals
(`research/2026-10-25-cairn-docs-evals/`), and glw907/cairn-cms#148, whose fixture eval this
design generalizes.

## Brief

The docs-as-code system (the `cairn-docs` skill, the `docs-fact-checker` agent, and the docs path
rules) shipped with one round of evals and no way to get better. This design adds a loop. Each
month a session reads a sample of real cairn sessions, finds where the docs process first went
wrong in each, and sends you the failures as a triage list. You rule on each in about ten minutes.
Every failure you confirm becomes an eval case first, then a fix, and a fix merges only when the
evals show it helps without breaking anything else.

The method follows Anthropic's evals guidance and the error-analysis practice of Hamel Husain and
Shreya Shankar. Evals come from failures found in real sessions, not imagined ones. Each run is
graded on its outcome, by deterministic checks wherever possible, and every failing run's transcript
is read before its score counts. One set of cases guards against regressions, and a second holds the
cases the system still fails.

## Why

Two things went wrong with the first evals, and both are failures the published guidance warns
against. The overnight trigger queries described changes that don't exist in the repo, so a session
that searched, found nothing, and stopped was scored as a miss. Husain's rule is to write evals for
"errors you discover, not errors you imagine." The same queries ran read-only and counted only
whether the skill loaded, so they graded the path rather than the outcome. The score misled twice
on 2026-10-26, and both times only reading the transcripts showed it. Anthropic's guide says not to
trust scores "until someone reads transcripts."

Sources: [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
(Anthropic), [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
(Anthropic), [LLM Evals FAQ](https://hamel.dev/blog/posts/evals-faq/) (Husain and Shankar),
[Evaluating Skills](https://blog.langchain.com/evaluating-skills) (LangChain).

## Goals

- Real failures in the docs process are found each month, without waiting for someone to notice.
- A change to the skill, the agent, or the rules merges only with before-and-after numbers that
  show it fixes its target and keeps the regression set whole.
- A model change is measured before anyone relies on it.
- Geoff spends about ten minutes a month.

## Non-goals

- A general eval framework for every workstation skill. The runner may be reused later, but this
  pass builds it for cairn's docs process only.
- Eval runs in CI. They need a signed-in Claude session and cost real tokens.
- An observability product (Langfuse or similar), a dashboard, or a new Approval Queue item kind.

## Anti-goals

- **Overfitting.** A change that passes its new case and nothing else, or one that grows the skill
  by a sentence per failure. The skill research quotes skill-creator's warning against "fiddly
  overfitty changes."
- **A loop that only adds text.** A cycle can end with a removal, or with no change.
- **Numbers without transcripts.** A score is reported only after its failing runs were read.
- **More of Geoff's time.** Anything the session can decide, it decides.

## The eval set

It lives beside the skill in cairn-cms, at `.claude/skills/cairn-docs/evals/`, in the shape
skill-creator uses (`evals.json` with an `id`, a `prompt`, and expectations per case), extended
with the fields below. Only `SKILL.md` loads into a session, so the directory costs no context.

- **A fixture per case.** A case names a pinned cairn commit and a setup script that makes the
  change the prompt describes, such as today's `itemLabel` to `itemTitle` rename in `src/lib`, or
  a false sentence seeded into a page. A pinned commit keeps the fixture from rotting as cairn
  changes. A setup that doesn't apply aborts the run, which fixes the void `deficiency` run from
  the first evals.
- **The docs process under test is overlaid.** The runner checks out the pinned commit, then copies
  the docs-process files from the ref under test: `.claude/skills/cairn-docs/`,
  `.claude/agents/docs-fact-checker.md`, `.claude/rules/docs*.md`, and `CLAUDE.md`. Two refs give
  an A/B comparison over identical fixtures.
- **Outcome graders first.** A case's checks run against the finished tree: a string that must or
  must not appear under `docs/`, a page that must change, and the docs gate's `check:options` and
  `check:reference:signatures` where the case touches the public surface. A fresh Opus judge,
  blind to the arm, grades only what a check can't settle, using the first evals' assertions. The
  judge has an "unknown" answer, per Anthropic's guide. A page that changed without the gate or the
  fact-check is unverified, so a case that edits docs also checks from the transcript that the docs
  gate ran and `docs-fact-checker` was dispatched. Whether the skill loaded before the first docs
  edit is recorded as a diagnostic, not as part of the grade.
- **Two suites.** `regression` cases should pass every time. `capability` cases are ones the
  system still fails. A capability case that passes every trial in
  two cycles in a row moves to `regression`.
- **Trials.** Three per case per arm, reported as the pass rate and pass^3 (every trial passed).
  Consistency is what a docs process needs, so pass^3 is the headline.
- **Sessions like real ones.** Sonnet at medium effort, with Read, Edit, Write, and the Bash
  commands a docs change needs (the gate, `git diff`, `git status`), in a worktree under
  `.claude/worktrees/docs-eval-*`. They can't push, call `gh`, or write outside the worktree. The
  name prefix lets the monthly sample skip eval sessions. They load the live `~/.claude` tree as a
  real session does. Both arms of a comparison run in the same pass, so the shared tree cancels out,
  and each result records the `~/.dotfiles` commit so cycles can be compared.
- **Subscription only.** The runner and the cycle unset `ANTHROPIC_API_KEY` before starting any
  session. `~/.local/secrets` exports it, and a session that sees it bills the API.

Seed cases, all from failures or checks that were real:

- `regression`: the `itemLabel` rename fixture from glw907/cairn-cms#148; the first evals'
  `rename-export`, `deficiency`, and `new-page-trap`; the fact-checker key (five false claims and
  five true ones, run with `--agent docs-fact-checker`); and the ten near-miss queries that must not
  load the skill (CHANGELOG entry, homepage copy, design spec, TSDoc comment, failing test, pass
  plan, PR description, Survey README, refactor, commit message), which are cheap and read-only.
- `capability`: `code-and-docs`, which both arms missed in the first evals
  (`docs/extend/architecture.md:157` still claimed a media replace leaves the manifest alone).
- Dropped: the overnight should-trigger queries whose premise is false at the pinned commit. A
  query stays only if the change it describes exists in its fixture.

One command runs a suite: `.claude/skills/cairn-docs/evals/run <ref> [<ref>] [--suite ...]
[--trials n]`. It prints a markdown table (case, arm, pass rate, pass^3, a link to each failing
transcript) and writes the raw results under `~/.local/state/cairn-docs-evals/`, outside the tree.

## The change rule

A new path rule in cairn-cms on the docs-process files says that a change to them runs both suites
on `main` and on the branch, and puts the table in the PR. The PR merges when the regression suite
does not drop, its target capability case improves, and every failing run's transcript was read. A
drop means a regression case's pass rate on the branch is below `main`'s in the same run, and stays
below after both arms rerun that case for three more trials. One noisy trial doesn't block a merge.
`SKILL.md` stays under 500 lines, per Anthropic's skill guidance. These PRs are ordinary class and
merge themselves after CI. The next cycle's history line reports them to Geoff.

## The monthly cycle

A systemd user timer on pavilion fires on the first of each month, with `Persistent=true` so a
month missed while pavilion was off runs at the next login. The Approval Queue is local to
pavilion, which is where Geoff ruled on the cutover. The timer starts a script, not a long-lived
Claude session. The script runs a headless session for steps 1 to 5, queues the triage item, and
waits on `approval-queue triage` for as long as the ruling takes. A shell process can wait for
days; a `claude -p` turn can't. When the decision arrives, the script runs a second headless session
for steps 6 and 7. It stores the item id first, so a script killed by a reboot finds the waiting
item at its next start and resumes with `approval-queue collect <id>`. The prompts are committed
beside the evals. The timer, the script, and their guards live in `~/.dotfiles`, per
`~/.claude/docs/unattended-work-guards.md`. The cycle:

1. **Samples real sessions.** It takes the cairn-cms transcripts since the last cycle whose sessions
   edited `docs/` or the documented code (`src/lib`, `packages`, `templates`, `tool/cmd`,
   `tool/internal`), skipping `docs-eval-*` worktrees, up to 30. It adds Geoff's docs-review
   comments since the last cycle and every cairn BACKLOG item tagged `#docs-process`.
2. **Finds the first failure in each.** It notes where the docs process first went wrong, since a
   later error often follows from it, then groups the notes into failure modes with a count and up
   to two pieces of evidence each (a transcript line or a review comment, quoted in a sentence).
3. **Checks the guidance.** It rereads the sources listed in `evals/sources.md` and notes any change
   that bears on the skill. The file records the date each source was last read.
4. **Runs both suites on `main`** with the current default models, so model drift and a saturated
   capability suite show up.
5. **Queues one `triage` item.** Each row is a failure mode, a guidance change, or a graduation, with
   the evidence in its reason and a proposed call: now, defer, or drop. Then it runs `notify-send`
   once at normal urgency.
6. **Acts on the decision.** For a "now" row it first writes a capability case that reproduces the
   failure and fails on `main`, then makes the smallest change that passes it, under the change
   rule. A "defer" row becomes a cairn BACKLOG item. A "drop" row is logged as not a failure, so the
   next cycle doesn't raise it again.
7. **Writes one history entry** in `evals/history.md`: the date, the models, the sample size, both
   suites' scores, and each row with its call and outcome.

A model upgrade doesn't wait for the month. When the default model changes, the next session that
notices (the cycle, or a change PR) runs both suites on `main` first and reports the difference.

## Catching misfires between cycles

One line in `SKILL.md`: when the docs process went wrong in a session (a page left stale, the gate
skipped, the fact-check not run), file a cairn BACKLOG item tagged `#docs-process` with the session
id. This is Anthropic's "ask it to self-reflect" advice, and the cycle reads these items as input.
It doesn't replace the transcript sample.

## Budget

A change PR runs about 15 cases × 3 trials × 2 arms, roughly 90 Sonnet sessions, most of them
short. A month's cycle runs one arm, roughly 45. The runner refuses a run over 120 sessions unless
it is passed `--max`. None of it spends API credit.

## The Approval Queue

The `triage` item fits as it stands: a row carries an action, a reason, and a proposed call, and
Geoff can change the call and add a note. If the first cycle shows that the rows need a link to
their evidence, a small queue change adds one then. Nothing in the queue changes in this pass.

## Left to the builder

- The runner's language and structure, within cairn's tooling conventions.
- How fixtures share `node_modules` so the gate checks don't run `npm ci` per trial.
- The check format inside `evals.json`.
- The timer's exact unit, lock, and guard wiring.
- Porting the first evals' assertions and the fact-checker key into the new format.

## Acceptance

- `run main` holds every regression case at pass^3. A seed case that doesn't moves to
  `capability`; this pass doesn't change the skill to make it pass. `code-and-docs` starts in
  `capability`.
- `run 25fb80fa3 main --trials 5` on the rename fixture (the rules before and after #148) scores
  the new rules at pass^5 and reports the old rules' rate beside it.
- A seeded control (a branch that deletes the skill's description) drops the regression suite.
- One dry cycle runs end to end on the sessions since 2026-10-26 and queues a triage item, which
  Geoff rules on.
