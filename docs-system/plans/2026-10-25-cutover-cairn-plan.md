# Docs-as-code cutover: cairn-cms

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-25-docs-as-code-cutover-design.md`,
"cairn-cms", approved by Geoff 2026-10-25 (Approval Queue item 20261025T215556-1865163). Rulings
R1 to R16: `research/2026-10-25-docs-as-code-rulings.md`. Paths and order:
`research/2026-10-25-docs-system-retirement-inventory.md`. Skill and agent grounds:
`research/2026-10-25-docs-skills-research.md` and `research/2026-10-25-docs-as-code-best-practice.md`.
The `docs` review's interface: `plans/2026-10-25-cutover-contract.md` (the contract).

Executor: `cairn-cms-docs-cutover`, `sonnet` at `medium`, under `conductor-approval-queue`. Repo:
glw907/cairn-cms. Two PRs: the main PR (branch `docs-cutover`) and the register PR (branch
`docs-register`). Risk class `runner` (`scripts/checks/**`, `.github/workflows/**`, the skill and
agent), not `live-account`.

Path estimate: 350 path minutes against the design's 330. The arithmetic is under "Path".

Read at cairn `origin/main` `2b5549ea0` (#144 merged). The main checkout is 76 commits behind and
Geoff's interactive session `cairn-cms-ae` sits idle in it, so no one pulls or edits it; both
worktrees are cut from `origin/main` with `git worktree add` (contract planning note 13). Line
numbers are at `2b5549ea0`; find each symbol by name.

## Pre-flight

Empty: nothing for Geoff. The conductor checks these before launch:

- `git -C /var/home/glw907/Projects/cairn-cms fetch origin` succeeds, and `git -C
  /var/home/glw907/Projects/cairn-cms merge-base --is-ancestor 2b5549ea0 origin/main` exits 0.
- `pgrep -af '[/]Projects/cairn-cms/.claude/worktrees/docs-(cutover|register)'` prints nothing,
  and no row in `claude agents --json` other than `cairn-cms-ae` (and, at T0, this session's own
  row, matched by name) has its `cwd` under the cairn-cms checkout.
- `git -C /var/home/glw907/Projects/cairn-cms check-ignore -q .claude/worktrees/x` exits 0.
- `node`, `npm`, `jq`, `gh`, `cairn-run-gate`, `ci-green`, and `claude` resolve; `gh auth status`
  answers.
- `mkdir -p /var/home/glw907/.local/state/cairn-docs-cutover` has run.
- The contract, this plan, and its prompt are on initiatives `main`.

## Scope guard

Every subagent prompt carries these two samples verbatim, and extras go in "Found, not done":

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

## Outcome

- **The main PR.** Blueprints, the facts store, briefs, outlines, and their gates are gone in one
  commit with the gate changes and the re-keyed options check. The instructions read as standard
  docs-as-code. The records are triaged. A `cairn-docs` skill, a `docs/**` path rule, and a
  `docs-fact-checker` agent, built evaluation first, pass the design's eval bar.
- **The register PR.** `docs/internal/docs-register.md`'s page-plan rule (both briefs) and its
  blueprint rulings and sources lines, rewritten, ready for the conductor to queue as a `docs`
  review.

## Calls the plan makes

1. **Worktrees.** T0 runs `git -C /var/home/glw907/Projects/cairn-cms worktree add -b docs-cutover
   .claude/worktrees/docs-cutover origin/main` and the same for `docs-register`, then
   `EnterWorktree` with `path` set to the `docs-cutover` worktree. That is the session's only
   `EnterWorktree`; the register worktree is worked by absolute path and `git -C`.
2. **One commit for the retirement.** The pair's two branches are squashed into one commit on
   `docs-cutover`: "Retire blueprints, the facts store, and their gates; re-key the options check"
   (inventory order 2 and 3).
3. **The re-keyed option map.** A row is `docs/reference/<page>.md#<anchor>`, `exclude <reason>`,
   or `pending <slug>` naming a published page. `check-options.mjs` imports `headingAnchors` from
   `docs-links.mjs`, fails a row whose page or anchor does not exist, and fails a row whose section
   (the heading's text through the line before the next heading of the same or higher level) does
   not name the option's last path segment in inline code. It reads no facts and no outlines. The
   re-keying script is a one-off run from
   `/var/home/glw907/.local/state/cairn-docs-cutover/rekey/`, never committed; its counts and every
   hand-judged row go in `## Decisions`.
4. **Evals live outside the tree.** Every eval definition, seeded page, answer key, run output, and
   grade sits under `/var/home/glw907/.local/state/cairn-docs-cutover/evals/`. An eval run greps its
   worktree, so an answer key in the tree would leak into the run. The conductor copies the folder
   into `research/2026-10-25-cairn-docs-evals/` at its hand-over.
5. **Eval runs.** Each run is a headless session in its own scratch worktree under
   `.claude/worktrees/eval-<case>-<base|skill>`, cut from the commit named in T5, set up with the
   adapter's setup command, and run as:

   ```
   cd <scratch worktree> && claude -p "$(cat <case prompt file>)" --model sonnet --effort medium \
     --output-format stream-json --verbose --permission-mode acceptEdits --max-turns 80 \
     --allowedTools "Read Grep Glob Edit Write Skill Agent Bash(git diff:*) Bash(git status:*) Bash(git log:*) Bash(git grep:*) Bash(git show:*) Bash(git add:*) Bash(git commit:*) Bash(npm run:*) Bash(node:*) Bash(grep:*) Bash(ls:*) Bash(find:*) Bash(cairn-run-gate:*)" \
     --disallowedTools "Agent(fact-checker) Agent(cairn-docs-drafter)" \
     > <evals>/runs/<case>-<base|skill>/run.jsonl
   ```

   Each case prompt ends: "Work on this branch only. Commit when done. Do not push, open a PR, or
   run approval-queue; end by saying what you would send for review." After a run, save
   `git -C <scratch> diff <cut commit>..HEAD` as `diff.patch` (for `deficiency`, `<setup
   commit>..HEAD`), since the scratch worktree is cut from the `docs-cutover` head and a diff
   against `origin/main` would carry the whole retirement; the final `result` text as
   `reply.md`, and the tool calls (`jq -c 'select(.type=="assistant") | .message.content[]? |
   select(.type=="tool_use") | {name, input}'`) as `tools.jsonl`. Then remove the worktree and its
   branch.
6. **The trigger test** waits for `test ! -e /var/home/glw907/.claude/skills/blueprint` (the infra
   executor removes that link early), so the retired skill cannot compete for the queries. Until it
   is gone, do other work. If it is still there when nothing else remains (a permission layer may
   refuse the infra executor's `rm`), run the queries anyway, count a route to `blueprint` as a
   miss, and record that in `## Decisions`; the test never waits past that point.
8. **The live tree still carries the retired agents.** `~/.claude/agents` links into the dotfiles
   main checkout, so `fact-checker`, `cairn-docs-drafter`, and the old facts rules in the live
   `cairn-implementer` and `cairn-pass` stay live until the workstation PR merges in the morning (a
   departure from the design's "unlink and remove", forced by that PR being held for Geoff).
   Every eval run, trigger query, and fact-checker run passes
   `--disallowedTools "Agent(fact-checker) Agent(cairn-docs-drafter)"` (merged with any other
   entries in that flag), and the stale `cairn-pass` and `cairn-implementer` text is a known
   confound, named in the eval summary and in `## Decisions`.
7. **The skill's sources.** The skill routes to `docs/internal/docs-register.md`'s track and brief
   sections and to Survey's `~/.claude/docs/voice/technical-doc-web.md` and
   `~/.claude/docs/voice/editor.md` by path and section, and quotes none of them (R12). It cites
   Anthropic's guidance where a rule rests on it (R11): the skills best-practices page
   (<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>), the memory
   page (<https://code.claude.com/docs/en/memory>), and Claude Code best practices
   (<https://code.claude.com/docs/en/best-practices>). The register for its prose is
   `~/.claude/docs/voice/agent-facing.md`.
8. **The register PR's edits are Geoff's to rule on**, so the main PR never touches
   `docs/internal/docs-register.md`, and the main PR's residue read allows that file.

## Names

- STATUS: `docs-cutover-status.md` in `/var/home/glw907/Projects/cairn-cms/.git/worktrees/docs-cutover/`,
  never committed, beside `pass-task-clock`.
- State: `/var/home/glw907/.local/state/cairn-docs-cutover/` (`rekey/`, `evals/`,
  `register-review/`).
- Setup (cairn-pass): `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync)`.
- Fast lane: `node scripts/checks/gate-tier.mjs --fast --range origin/main..HEAD` prints the legs;
  each runs through `cairn-run-gate` per cairn-pass. The docs gate: `cairn-run-gate 'npm run check:docs-gate'`.
- CI watch: `ci-green <sha> --pr <n> --wait` as a background Bash task, re-issued on 75.

## Tasks

### T0. Launch, worktrees, baseline (20 min), by the session

Risk: `runner`, no edit.

1. One-executor checks (pre-flight's two), then call 1's worktrees and `EnterWorktree`. Write
   STATUS (base commit, session name and id). Arm the API-drop wake-up (`/loop` with no interval)
   per `~/.claude/docs/unattended-work-guards.md`; pavilion has no lid.
2. Setup in both worktrees. Baseline: the docs gate in `docs-cutover`.

Acceptance: the docs gate is green at the base (a red reruns once per the durable-gotchas rule; a
second red at the same leg is a stop, standing answer 8); STATUS is written.

### The pair: A beside B, while the session runs T1 and T3

Each subagent runs setup in its own worktree first, works only on its files, runs its fast-lane
legs and the docs gate, commits, and never pushes. Each prompt carries the scope guard, calls 2
and 3 quoted, the inventory's cairn-cms section by path, and
`/var/home/glw907/.claude/skills/ts-conventions/SKILL.md` by path. Descriptions `docs-cutover task
A` and `docs-cutover task B`.

- **A:** `scripts/checks/check-options.mjs`, `docs/internal/option-map.json`,
  `src/tests/unit/check-options.test.ts`.
- **B:** everything the design's "Remove" and "Change in the same commit" lists name except A's
  files, plus `package.json` and `.gitignore`.

#### A. Re-key the options check (75 min), `sonnet` at `medium`

Risk: `runner`. Outcome: call 3 holds.

- Write the re-keying script in the `rekey/` folder. For each `f:` row, place it at the section of
  a reference page that names the option's last segment in inline code, preferring the page of a
  root that reaches the option (`reference-coverage.mjs` maps subpaths to pages). One candidate is
  placed; two or more are judged by hand from the section text; none becomes `pending <slug>` for
  the published page that should document it. Raise `pendingCount` to the pending rows. `exclude`
  rows stay.
- Rewrite `check-options.mjs` per call 3; drop `loadFactIndex`, `OUTLINES_DIR`, `FACTS_DIR`, the
  fact row kind, and the header's fact wording.
- Tests: an anchor row passes; a missing page, a missing anchor, and a section that does not name
  the option each fail with a message naming the row; `pending` above `pendingCount` fails; an `f:`
  row fails as unknown.
- Report: the counts placed, hand-judged (each row and its reason), and pending (each row), for
  `## Decisions` and one cairn BACKLOG item listing the pending rows ("Document these options").
- Acceptance: `npm run check:options` exits 0; `jq '[.rows[] | select(startswith("f:"))] | length'
  docs/internal/option-map.json` prints 0.

#### B. Remove the retired system and change the gates (75 min), `sonnet` at `medium`

Risk: `runner`. Outcome: the design's lists, done.

- Delete: `blueprints/`, `drafter.toml` and `.gitignore`'s `drafter.local.toml` line,
  `docs/internal/facts/`, `docs/internal/briefs/`, `docs/internal/briefs-rebuilt.json`,
  `docs/internal/outlines/`, `scripts/checks/{check-facts,check-provenance,migrate-fact-ids}.mjs`,
  `scripts/oneshot/verify-harvest.mjs`, their fixtures (`scripts/checks/fixtures/{facts,provenance}/`)
  and tests (`src/tests/unit/{check-facts,check-provenance,verify-harvest}.test.ts`), and the
  `check:facts` and `check:provenance` scripts.
- Change: `docs-gate.mjs` (no facts or provenance step, no `--brief`; its header and test),
  `close-prebuilt.mjs`, `gate-table.json`, the `test.yml` comment at line 135, `check-leaks.mjs`
  (the T3 tier's briefs, outlines, and facts, the `blueprints/` and retired-path skips, the fact-id
  and facts-container patterns, and its test), `docs-links.mjs` (the outline branch and its header
  lines, and its test), and `scripts/docs-review/embed.mjs` (the plan pane and `planPathFor`, and
  `docs-review-embed.test.ts`). `gate-tier.test.ts` loses its retired legs.
- Acceptance: the fast lane's legs and the docs gate are green; `git grep -n -E
  'check-facts|check-provenance|migrate-fact-ids|verify-harvest|docs/internal/(facts|briefs|outlines)|blueprints/|drafter'
  -- scripts src/tests package.json .github .gitignore` prints nothing.

### T1. The evals, written first (30 min), by the session during the pair

Risk: `runner`. Outcome: the eval set exists before any skill text (skills research, principle 9;
the best-practices page: "Create evaluations BEFORE writing extensive documentation").

Write under `evals/`:

1. `cases.json`, four cases, each `{id, prompt, setup, assertions}`, with 4 to 6 assertions each.
   An assertion is pass/fail and checkable from `diff.patch`, `reply.md`, or `tools.jsonl` alone.
   The `/healthz` claim on `rotate-the-github-app-key.md` is in no case (it is the morning's real
   fix).
   - `code-and-docs`: "Fix BACKLOG #74: media replace leaves the content manifest's mediaRefs on the
     old hash." Seeds: the code fix rewrites `runtime.manifestPath` on replace; every docs page that
     describes replace's commits is updated in the same branch, or the reply shows the grep that
     found none; a `CHANGELOG.md` `## Unreleased` entry; the docs gate was run and passed; nothing
     under `docs/internal/facts` or `blueprints/` is created.
   - `rename-export`: rename one exported option that `docs/reference/` names (the session picks one
     with two to four doc mentions and writes its old and new names into the prompt). Seeds: every
     `docs/` and `README.md` mention repointed (`git grep` of the old name in `docs/` is empty);
     `CHANGELOG.md` and `docs/extend/migration-notes.md` carry a `Consumers must:` line;
     `npm run check:surface -- --update` ran; the docs gate passed.
   - `new-page-trap`: "Add a page to the extend track on rotating the session secret." cairn has no
     session secret (no `SESSION_SECRET` or `sessionSecret` in `src/`). Seeds: the run searched the
     code for it; it created no page; the reply says the product has no such secret, citing the
     search; it names `docs/extend/rotate-the-github-app-key.md` as the nearest real procedure.
   - `deficiency`: the setup commits one false sentence into `docs/extend/turn-on-tidy.md` (the
     session writes it from code it read, with the true statement and its `file:line` in the
     answer key); the prompt is a reader's report that the page "doesn't match what happens" at
     that step, without the answer. Seeds: the sentence now says what the code shows; the diff
     touches no other sentence; the reply cites the `file:line`; the docs gate passed.
2. `triggers.json`: the 20 queries under "The trigger queries", each `{query, should_trigger}`.
3. `fact-checker/`: `seed.md`, a new section of 10 claims for `docs/extend/configure-media.md`, 5
   true and 5 false, each false one contradicting a named line of code; `key.json`, `[{n, claim,
   true, source}]`, every `source` read at the base commit.

Acceptance: each file parses (`jq empty`); every assertion names what it reads.

### T3. The records (40 min), by the session during the pair

Risk: `ordinary`. Files: `BACKLOG.md`, `docs/internal/docs-friction-log.md`. Outcome: the design's
"Records".

- **Accuracy corrections first** (standing answer 3): read `docs/internal/facts/*.md` and the
  friction log at the base for an entry that records a wrong or disputed claim; when the claim is
  still on a page (`git grep` the page), file a BACKLOG content item naming the page, the sentence,
  and what the code shows (`file:line`).
- **The friction log** loses its docs-system lines (the inventory counts 77): the facts, briefs,
  blueprint, drafter, outline, and provenance entries. Engine and content entries stay.
- **BACKLOG**: tick each mechanics item the inventory lists as moot (#2 to #4, #7, #8, #18, #19,
  #21, #23, #25, #26, #28 to #30, #35 to #38, #51, #53, #54, #60, #61, #65, #66, #72, and #76),
  each with "Dropped: the docs-as-code cutover retired the system it served", after reading each
  to confirm; close #71 ("the redraft is done; blueprints retire"); re-aim each content item (#5,
  #6, #9 to #13, #17, #33, #40, #43, #44, #62, #69) at its page, removing fact ids and blueprint
  references. An item the inventory miscounted is judged by its text.
- **The RESUME friction** (`~/Projects/initiatives/docs-system/research/2026-10-25-claude-code-page/RESUME.md`,
  "Friction"): cairn items 7, 8, 10, 25, 27, 28, 29, 31, 34, 47 and agent items 24, 43, 48. Ground
  each in the code at the base, then file it through `log-issue` in cairn's `BACKLOG.md` or drop it
  with its reason in the PR. The planner's reading, for the session to confirm or overturn: file 7
  (arm lists, now without `verify-harvest`), 8, 27, 29, and 34; drop 10 (cairn-pass's setup already
  installs both), 25 (BACKLOG #73 carries it), 28 (its outline is deleted; T2's gate shows whether a
  link needs fixing now), and 31 (check whether the branch fix reached `main`); file 47 as a
  register question for Geoff; drop 24 (the agent retires), and fold 43 and 48 into
  `docs-fact-checker` (T5) and drop them as filed.
- Acceptance: the friction log holds no docs-system line; each ticked item carries its reason;
  the PR's record of the triage lists every RESUME item with its verdict.

### T2. Merge the pair and squash (15 min), by the session

Risk: `runner`. Merge A, then B, into `docs-cutover` as call 2's one commit (`git merge --squash`
each, then one commit), on top of T3's commit (T1 writes no file in the repo). Run the fast lane and the docs gate. Push and open the main PR as a draft
(`gh pr create -R glw907/cairn-cms --draft`), then start the CI watch in the background.

Acceptance: the docs gate is green; the CI watch is running.

### T4. The instructions (30 min), by the session

Risk: `ordinary`, except the shipped skill. Outcome: the design's "Rewrite as standard
docs-as-code", plus the unlisted residue (contract planning note 11).

- `CLAUDE.md`: the "Facts container" bullet becomes one line: docs change in the same PR as the
  code, checked by `npm run check:docs-gate`. Nothing else in that section names the retired
  system.
- `CONTRIBUTING.md`, `docs/STATUS.md` (#71's redraft done; the next action is no longer a
  blueprint stage), `docs/internal/exemplars/README.md`, `docs/internal/README.md`,
  `docs/internal/docs-maintenance.md` (the gate's steps and the facts paragraph),
  `docs/internal/pass-gate-tiers.md`, and `ROADMAP.md`'s stage 2b part 2 entries and fact lines.
- The shipped `cairn-extend` skill (`skills/cairn-extend/SKILL.md` and
  `templates/waymark/.claude/skills/cairn-extend/SKILL.md`) links the facts file; point it at the
  published extend pages and `docs/reference/` instead, keep both copies identical, run
  `npm run check:public-skill`, and add a `CHANGELOG.md` `## Unreleased` line (no consumer action).
- Acceptance: the docs gate is green; `git grep -n -i -E 'blueprint|drafter|facts (container|store)|docs/internal/(facts|briefs|outlines)|check:(facts|provenance)|page chain'`
  over these files prints nothing.

### T5. The skill and the agent, evaluation first (130 min), by the session

Risk: `runner`. Outcome: the design's "The skill and agent", passing the eval bar.

1. **Baseline (30).** Cut four scratch worktrees from the current `docs-cutover` head (no skill, no
   rule, no agent yet) and run the four cases per call 5, `base` condition. For `deficiency`, the
   setup commit goes in first. Runs may go two at a time, each docs gate through `cairn-run-gate`.
2. **Write (40).** In `docs-cutover`, per call 7:
   - `.claude/skills/cairn-docs/SKILL.md`, under 150 lines. Frontmatter `name: cairn-docs` and a
     third-person description that leads with the use case and names the near misses, for example:
     "Changes cairn-cms documentation the docs-as-code way: pages under docs/ change in the same PR
     as the code, pass the docs gate and a fresh fact-check, and go to Geoff as a docs review. Use
     when code changes documented behavior, when a docs page is wrong or missing something, when
     writing, splitting, or restructuring a page, or when queueing or answering a docs review. Not
     for CHANGELOG entries, code comments, specs, plans, or site content." The body: one decision
     tree with the three cases (changing docs with code, fixing a deficiency, a new page); for
     each, the steps and the check to run (grep the docs for a changed symbol; verify a claim in
     the code before writing it; the docs gate, fixed and rerun until it exits 0; the fact-check in
     a fresh context; the review). Where a correction lands (R12): Geoff's in-place edit is final; a
     wording correction goes through the `survey` skill; a cairn voice change is a PR to
     `docs/internal/docs-register.md`; a base-standard change is a PR to Survey.
   - `references/new-page.md`: the premise test (does the product have it; does a page already own
     it), the track and Diátaxis type, the outline, and the introduction's questions, each routed
     to its register section.
   - `references/review.md`: dispatching `docs-fact-checker`, the findings-to-notes rule, the
     description, the `approval-queue docs` command, and what to do on each decision, from the
     contract's sections of those names, with one worked notes example. It names the Approval
     Queue README's "The docs kind" section as the authority.
   - `.claude/rules/docs.md`: frontmatter `paths: ["docs/**"]`, then two lines: load the
     `cairn-docs` skill before changing a page, and the register is
     `docs/internal/docs-register.md`.
   - `.claude/agents/docs-fact-checker.md`: frontmatter `name`, a description ("Checks the changed
     lines of cairn-cms docs pages against the code at a commit and returns JSON findings. Use after
     a docs change and before its review, in a context that did not write it."), `tools: Read,
     Grep, Glob, Bash`, `model: claude-opus-5-5`, `effort: medium`. The body: the dispatch names the
     repository, the base, the commit, and the pages; read each page's added and changed lines
     (`git diff <base> <commit> -- <page>`); list the claims in them; settle each in the code at the
     commit (`git grep <pattern> <commit>`, `git show <commit>:<path>`); the verdicts `holds`,
     `wrong`, `imprecise`, `unsupported`. The over-firing guard: report `wrong` or `imprecise` only
     with the `file:line` that contradicts the claim; a claim about a vendor's behavior that no repo
     code settles is `unsupported`, never `wrong` (RESUME agent item 43); wording, style, and claims
     outside the changed lines are out of scope. `line` is the 1-based line in the page at the
     commit (agent item 48). The reply is one JSON array in the contract's finding shape, written to
     a findings path when the dispatch names one (`mkdir -p`, a quoted heredoc, `jq -e 'type ==
     "array"'`) and replied as the path and counts. It cites the sub-agents page
     (<https://code.claude.com/docs/en/sub-agents>) and the best-practices page's "A fresh context
     improves code review". It never edits.
   - Commit: "Add the cairn-docs skill, its path rule, and the docs-fact-checker agent".
3. **With the skill (30).** The four cases again, `skill` condition, from the new head.
4. **Grade (10).** One grader per case: Agent tool, `subagent_type: general-purpose`, `model:
   opus`, description `docs-cutover grade <case>`, the prompt under "The grader prompt", with the
   two runs labeled Run 1 and Run 2 in an order the session sets by coin flip and records in the
   grades folder. Bar: the `skill` total of passed assertions over the four cases is greater than
   the `base` total.
5. **Triggers (10).** After call 6's wait, from the `docs-cutover` worktree, for each query:

   ```
   claude -p "<query>" --model sonnet --effort medium --output-format stream-json --verbose \
     --max-turns 2 --disallowedTools "Bash Edit Write NotebookEdit Agent Agent(fact-checker) Agent(cairn-docs-drafter)" \
     | jq -c 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Skill") | .input'
   ```

   A query routes when its output holds a `Skill` call whose `skill` is `cairn-docs` and
   `should_trigger` is true, or holds none and `should_trigger` is false. Bar: at least 18 of 20.
6. **The fact-checker (10).** Cut a scratch worktree from the head, commit `seed.md`'s section into
   `docs/extend/configure-media.md`, and run three times:
   `cd <scratch> && claude -p --agent docs-fact-checker "Repository: <scratch>. Base: <head>. Commit: <seed commit>. Pages: docs/extend/configure-media.md. Findings path: <evals>/fact-checker/run-<n>.json." --output-format json --disallowedTools "Agent(fact-checker) Agent(cairn-docs-drafter)"`.
   Confirm `--agent` in `claude --help` first; if it is absent, dispatch the agent through the Agent
   tool with `subagent_type: docs-fact-checker` from the session instead, and record which in
   `## Decisions`.
   Score each run against `key.json`: a false claim found means its element's verdict is `wrong` or
   `imprecise`; a false positive is a true claim given `wrong` or `imprecise`. Bar, in each of the
   three runs: all 5 false claims found and at most 1 false positive.
7. **Iterate.** A miss changes the skill or agent at its cause, then reruns only the affected
   measure; a fix aimed at one query or one seeded claim rather than its cause is out ("avoid
   fiddly overfitty changes", skill-creator). An assertion found faulty is fixed and rerun on both
   conditions, recorded in `## Decisions`.

Acceptance: the three bars hold, with every run's output, grade, and score saved under `evals/`
and summarized in a `summary.md` there.

### T6. The register PR (30 min), by the session in `docs-register`

Risk: `ordinary`. Files: `docs/internal/docs-register.md` only.

- Rewrite the page-plan rule in both briefs ("A page is drafted from its committed page plan",
  developer and editor) as a docs-as-code rule: a page's outline (its job, its sections in order
  with the one sentence each, and its hand-offs) is written before the prose and rides in the PR,
  with the premise test first; no plan file, fact ids, or brief. Rewrite "The rulings behind the
  briefs" entries and the "Sources" lines that cite blueprints or the page plan, and each other line
  that names blueprints, facts, briefs, or outlines as tools (not as history). Keep each ruling's
  date and owner; a superseded ruling says so and names the 2026-10-25 docs-as-code rulings.
- Gate (Vale and the docs gate), commit, push, open the PR (`gh pr create -R glw907/cairn-cms`),
  start its CI watch.
- Write the review inputs under `register-review/`: `description.md` (a background paragraph:
  the rulings retired blueprints and facts, and this file recorded rules built on them; then a
  summary of what each rewritten rule now says) and `notes.json` in the contract's shape: one
  `info` note per rewritten rule, quoting its new first sentence, with `was` and `now`; one
  `decide` note on where a new page's outline lives, with the choices "In the PR description" and
  "In the page's first commit message", each with its `done`; one `question` note for RESUME item
  47 (the Waymark name) if T3 filed it there. Run `approval-queue notes --check
  /var/home/glw907/Projects/cairn-cms/.claude/worktrees/docs-register <notes.json>` only after the
  conductor reports the new queue installed; until then validate the JSON shape with `jq`.
- Leave the worktree in place, clean at the PR head; the conductor queues the review from it.

Acceptance: the register PR's CI is green; the review inputs exist; the worktree is clean at the PR
head.

### CT. Close: review, residue read, PR-ready (50 min), by the session

Risk: `runner`.

1. CI green on the main PR's head (`ci-green`; a red stops the line and is fixed forward). List
   every retried test from its output in the PR body.
2. **The close review.** `diff-reviewer` at whole-branch scope against the design, the contract,
   and this plan, with the checklists cairn-pass's globs load (`ts-conventions` for the scripts).
   One batched fix chain quoting each finding verbatim as acceptance, then the gate. A second
   review only on a blocker.
3. **The residue read** (below), on the main PR's head. Fix each traced finding and rerun until
   clean (no round cap; standing answer 2).
4. **The main PR body.** `## Brief` per `~/.claude/docs/voice/approval-brief.md`; what landed; the
   eval results (each bar, with the numbers); the RESUME triage table; the residue verdict;
   `## Decisions` (at least: the re-keying counts and hand-judged rows, the eval model and
   conditions, each assertion fixed, the skill's line count, the RESUME verdicts that differ from
   the planner's reading, and call 8: the retired agents leave the live tree only when the
   workstation PR merges, a departure from the design's "unlink and remove" forced by that held
   PR, with the stale `cairn-pass` text named as a known eval confound); `## Planning misses`; the score; "Found, not done" with BACKLOG numbers
   (including the pending options item).
   No `## Before merge`: the PR is safe under a plain merge and pull.
5. Mark the main PR ready; leave the register PR as is (it waits for Geoff's `docs` review).
   Write `READY <main pr> <head> REGISTER <register pr> <head>` in STATUS and send
   `conductor-approval-queue` one message: both PRs and heads, the register review's input paths,
   the eval numbers, the review and residue verdicts, every clock overrun, and every departure from
   the plan. Never merge.

## The trigger queries

Should trigger (`cairn-docs`):

1. "I renamed createMediaRoute's maxBytes option to maxUploadBytes. Update everything that has to change with it."
2. "Add a docs page explaining how to add a custom field type to the admin."
3. "docs/extend/turn-on-tidy.md says the tidy key is optional, but the code throws without it. Fix the page."
4. "Write the reference entry for defineFieldset's new collapsed option."
5. "The extend track has no page on running a site locally with wrangler dev. Draft one."
6. "Before I merge this branch that changes how drafts publish, make sure the docs match the code."
7. "Check the content-model page against the code and correct anything that's wrong."
8. "Geoff sent back the docs review on PR 152 with three comments. Address them and send it back to him."
9. "Restructure the extend track's index so its pages are grouped by task."
10. "A reader says the code sample on the add-an-island page doesn't compile. Fix the docs."

Should not trigger (near misses):

11. "Add a CHANGELOG entry under Unreleased for the media replace fix."
12. "Write the homepage copy for the new about section on 907.life."
13. "Write the design spec for the next engine pass."
14. "Add a TSDoc comment to createAuthGuard explaining what it returns."
15. "Fix the failing unit test in src/tests/unit/check-options.test.ts."
16. "Write a pass plan for the media replace bug."
17. "Draft the PR description for this branch."
18. "Update the Survey repo's README with the new theme tokens."
19. "Refactor src/lib/delivery/site-resolver.ts to remove the duplicated cache lookup. No behavior changes."
20. "Write the commit message for the staged changes."

## The grader prompt

```
You grade two runs of the same task against a fixed list of assertions. You did not run either and
do not know how they differ. Judge only what the evidence shows.

Task given to both runs: <case prompt>
Assertions, each pass or fail: <numbered list from cases.json>

Run 1: <evals>/runs/<case>-<X>/ (diff.patch, reply.md, tools.jsonl)
Run 2: <evals>/runs/<case>-<Y>/ (diff.patch, reply.md, tools.jsonl)
The repository at the run's base is /var/home/glw907/Projects/cairn-cms/.claude/worktrees/docs-cutover;
read code there only to settle whether a run's claim is true.

Read only. For each run and each assertion, give pass or fail and one line of evidence (a diff
hunk, a reply sentence, or a tool call). An assertion the evidence cannot settle is fail. Do not
prefer the longer run, the more confident reply, or a run that did more than the task asked.

Reply with one JSON object and nothing else:
{"run1": [{"n": 1, "pass": true, "evidence": "..."}], "run2": [...]}
```

## The residue read

After the close review's fix chain. Agent tool, `subagent_type: general-purpose`, `model: opus`,
description `docs-cutover residue read`, with `<head>` filled in:

```
You are reading one repository for leftovers of a retired system. You have not seen that system and
need not understand it; report what names it or serves it.

Repository: /var/home/glw907/Projects/cairn-cms/.claude/worktrees/docs-cutover at commit <head>.
Read only. Never edit and never run a command that writes. Search with git grep at <head>.

The retired system: docs "blueprints" (page plans, *.blueprint.md and *.blueprint.yaml, a
blueprints/ folder, drafted.lock, outline.yaml); a "facts store" or "facts container" under
docs/internal/facts with fact ids like f:abc123 and :fact[...] tags; "briefs" and "outlines" under
docs/internal/briefs and docs/internal/outlines, and page plans (*.plan.md, *.plan.yaml); the
check:facts and check:provenance gates; a tool named "drafter" (drafter.toml); a "docs page chain"
workflow; and Approval Queue "blueprint", "page", "change", and "anchors" reviews.

What replaced it: pages under docs/ are the source, changed in the same PR as the code, checked by
the docs gate and a docs-fact-checker agent, and reviewed as one "docs" review. See CLAUDE.md,
.claude/skills/cairn-docs/, and .claude/agents/docs-fact-checker.md.

Report every place outside the allowed list that names or serves anything retired: code, tests,
fixtures, scripts, CI config, package.json, CLAUDE.md, CONTRIBUTING.md, skills (including
skills/cairn-extend and templates/), published pages, internal docs, ROADMAP.md, docs/STATUS.md, and
open BACKLOG.md items.

Allowed, do not report:
- History: docs/internal/record/**, docs/internal/history/**, docs/HISTORY.md, docs/specs/**,
  docs/plans/**, docs/research/**, any file whose name starts with a date (YYYY-MM-DD), CHANGELOG.md
  sections for released versions, BACKLOG.md items marked [x], and git history.
- docs/internal/docs-register.md: a separate PR rewrites it.
- Product uses of "facts": site-facts.json, tool/internal/doctor/facts.go, docs/reference/site-facts.md,
  and the site facts the cairn-manifest command writes.
- The daisyUI "Blueprint" MCP server and its links, and the word in vendored Vale styles and the
  admin spellcheck dictionary.

Reply with one JSON array and nothing else:
[{"path": "...", "line": 12, "text": "<the line>", "why": "<what retired thing it names or serves>"}]
An empty array means clean.
```

## Merge order (the conductor's)

1. The Approval Queue PR merges and installs first (its plan's "Merge and install").
2. Then the main PR: `gh pr merge <n> -R glw907/cairn-cms --merge --match-head-commit <head>`, once
   the design's bar holds (CI green, review accepted, the eval bars met, the residue read clean)
   and the queue's install is done.
3. The register PR waits for Geoff's `docs` review; the conductor queues it after the install.
4. The main checkout stays as it is while `cairn-cms-ae` is listed; the conductor reports it stale.

## Path

T0 20 + pair (A 75, B 75; the session's T1 30 and T3 40 run inside it) 75 + T2 15 + T4 30 + T5 130
+ T6 30 + CT 50 = 350 path minutes, 1.06 times the design's 330. The task sum is 445.

## Models

- Executor: `cairn-cms-docs-cutover` on `sonnet` at `medium`.
- A and B: Agent-tool subagents with `subagent_type: cairn-implementer` (`sonnet` at `medium`; it
  runs the setup and the fast lane, commits, and never pushes).
- Eval runs and trigger queries: `claude -p` on `sonnet` at `medium`, the model that does
  cairn's docs work in passes. The fact-checker runs on its frontmatter's `claude-opus-5-5`.
- Graders, the close review, and the residue read: `claude-opus-5-5`.
- Conductor: `conductor-approval-queue` on `claude-opus-5-5` at `medium`.

## Standing answers

From the design, made concrete for cairn-cms, applied in place of stopping:

1. **Merges.** The conductor merges the main PR when cairn's GitHub CI is green on its head, the
   whole-branch review accepts it, T5's three bars and the docs gate pass, the residue read is
   clean, and the new Approval Queue is installed. A `cairn-run-gate` exit 75 is reissued until it
   prints `gate exit:`. The register PR waits for Geoff. The executor never merges.
2. **The residue read.** Each finding is fixed while its cause traces, with no round cap. A finding
   whose cause doesn't trace holds the main PR for the morning packet: the executor reports it and
   still marks the PR ready, and the conductor raises it as a `gate-failed` ask instead of merging.
3. **Accuracy corrections.** A facts entry or friction line that records a wrong claim still on a
   page becomes a cairn BACKLOG content item before its file is deleted (T3, before T2's commit).
4. **Options re-keying.** The script places each row; ambiguous rows are judged by hand; a row with
   no section becomes `pending <slug>`, `pendingCount` rises to match, and one BACKLOG item lists
   them. None of these stops the run.
5. **Evals.** A first run may show an assertion is faulty; fix it, rerun both conditions, and record
   it. A bar still unmet after a traced fix to the skill or agent gets one structural fix (rewrite
   the unit the patches missed); if it is still unmet, the PR reports it in its Brief and the
   conductor raises it as a `gate-failed` ask; the rest of the work goes on.
6. **The interim.** The live `blueprint` skill and `approval-packet` text describe the old system
   until the workstation PR merges; nothing here waits on that except call 6's trigger test.
7. **Ceilings.** This plan's path is 350 against the design's 330 and the run's 900-minute
   ceiling. A task past twice its estimate keeps going while each step fixes a traced cause; the
   clock-stop hook's "wait for Geoff" line is answered here: write the minutes to STATUS, rewrite
   `start=` to now, run no `notify-send`.
8. **Stops.** A finding these answers can't settle is escalated in the PR and the run goes on with
   independent work. The executor stops only on a cause it can't trace or an irreversible act this
   plan doesn't name: it removes the clock file, writes the question in STATUS, and messages
   `conductor-approval-queue`. It never runs `notify-send` and never asks Geoff.
9. **Other repos.** A workstation, Survey, or approval-queue follow-up goes to that repo's
   `BACKLOG.md` through `log-issue`, never into its tree.
10. **CI.** A red stops the line; the fix goes forward or the commit reverts. A retry that passed is
    flake evidence, listed in the PR, not green.
