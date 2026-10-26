# Docs improvement loop plan

Initiative: docs-system
Design: `docs-system/specs/2026-10-26-docs-improvement-loop-design.md`, approved by Geoff on
2026-10-26 (item 20261026T120231-3017499, merge `7a7e0ee`), with a cap of 120 sessions per run.
Risk class: `runner` (a skill, its evals, a path rule, and a timer-launched session).
`live-account`: the first real cycle (Close step 3) queues a triage item and may open and merge PRs
on glw907/cairn-cms. Eval trials push nothing and are denied `gh`, `ssh`, and `approval-queue`.
Repos: glw907/cairn-cms (branch `docs-improvement-loop`) and glw907/workstation, the `~/.dotfiles`
checkout (branch `docs-improvement-loop`).
Executor: `cairn-cms-docs-improvement-loop`, Sonnet at medium, from the cairn-cms main checkout,
under `conductor-cairn-cms`.
Path estimate: 275 minutes (T1 85, T2 50, T3 20, T4 35, T5 60, close 25). T3 and T4 are a pair.
A mechanics review folded into this text on 2026-10-26 (two blockers, twelve majors, eleven
minors, from probes against `claude -p` 2.x, a hard-linked install, and the queue's source).

## Pre-flight

None foreseen. The eval sessions run headless `claude -p` on the subscription, which works on
pavilion with `ANTHROPIC_API_KEY` unset (`apiKeySource: "none"` in every 2026-10-26 fixture run and
in the review's probe).

## Standing answers

- **The cap.** A `run` refuses to start more than 120 case sessions unless passed `--max`. Judge
  calls are reported beside the count and not counted, as in the design's budget. Geoff ruled 120.
- **An unstable seed case.** A seed that doesn't hold pass^3 on `main`, after harness faults and
  errors are excluded, moves to `capability` and is listed in `## Decisions`. The pass never edits
  `SKILL.md` to make a seed pass.
- **A false premise at the pin.** Drop the case and list it in `## Decisions`.
- **A harness fault** (a needed command denied, or `cairn-docs` missing from the session's skills).
  Fix the harness and rerun; it never counts against a case.
- **An errored session** (`is_error`, or a result `subtype` other than `success` or
  `error_max_turns`, such as a usage limit). Excluded from the rates, rerun once after the limit
  window, and reported if it errors again.
- **An API key in use.** The runner aborts the whole run on the first `init` whose `apiKeySource`
  isn't `none`, in the executor and in the cycle alike. That is a cause to trace, never a retry.
- **The control shows no drop.** Rerun it once with the stronger control (T5 step 3).
- **A "Workspace not trusted" refusal** from a background session in a worktree. Becomes a
  pre-launch packet item, and a planning miss.
- **An estimate overrun.** Up to twice the path (550 minutes), go on; past that, the clock stop.

## Decisions taken in planning

- **The cycle is a background session, not a waiting script.** The workstation already runs a
  monthly loop that waits on Geoff: `model-review-notify` (from `model-review.timer`, monthly,
  `Persistent=true`) launches `survey-writing-review` on pavilion only, which starts one
  `claude --bg` session in its own systemd scope, and that session sends its packet and waits
  (`~/.dotfiles/docs/model-review/writing-prompt.txt` step 6). The cycle copies that shape:
  `cairn-docs-cycle`, called from `model-review-notify` beside `survey-writing-review`, starts
  `claude --bg --name cairn-docs-cycle-<YYYY-MM>`. No new timer. The outcome, cadence, host, and
  catch-up are the design's.
- **Each fixture starts from a commit.** The overlay and the setup are committed as a fixture-base
  commit, so the session starts clean, `git status` shows nothing of the harness, and the graders
  diff from that commit.

## Tasks

### T1. The runner (85 minutes, runner)

Outcome: `node .claude/skills/cairn-docs/evals/run.mjs <ref> [<ref>] [--suite regression|capability|all]
[--case <id>] [--trials n] [--max]` runs the cases against one or two refs and prints the markdown
table the design names. Node with no dependencies, like `scripts/checks/*.mjs`. A suite run takes
far longer than ten minutes, so every caller starts it as a background command and waits for exit.

Fixtures:
- One worktree per case, arm, and trial at `.claude/worktrees/docs-eval-<run>-<case>-<arm>-<trial>`,
  detached at the case's pin.
- The overlay: delete the overlay paths (`.claude/skills/cairn-docs/` except `evals/`,
  `.claude/agents/docs-fact-checker.md`, every `.claude/rules/docs*.md`, `CLAUDE.md`), then extract
  them from the arm's ref with `git archive <ref> -- <paths>`, leaving `evals/` out. Record a hash of
  each arm's overlay set in the results.
- The setup runs if the case declares one; a declared setup that changes nothing aborts the trial.
- Commit the overlay and the setup as the fixture base.
- `node_modules`: one prepared install per pin at `.claude/worktrees/docs-eval-nm-<pin>` (on
  `/var/home`; `/tmp` is a different device and refuses hard links), reused only when its
  lockfile hash matches the pin's, copied into each fixture with `cp -al`.

Sessions:
- `claude -p --model sonnet --effort medium --output-format stream-json --verbose --permission-mode
  acceptEdits`, run with `ANTHROPIC_API_KEY` removed from the environment and
  `CAIRN_GATE_LANE=light`.
- `--allowedTools`: Read, Grep, Glob, Edit, Write, Skill, Agent, and `Bash(npm run check*)`,
  `Bash(node scripts/checks/*)`, `Bash(cairn-run-gate *)`, `Bash(git -C * diff *)`,
  `Bash(git -C * grep *)`, `Bash(git -C * show *)`, `Bash(git diff*)`, `Bash(git status*)`,
  `Bash(git log*)`, `Bash(git add *)`, `Bash(git commit *)`, `Bash(jq *)`, `Bash(mkdir *)`. The
  `:*` form means a space follows, so `check:*` would deny `check:docs-gate`.
- `--disallowedTools`: `Bash(approval-queue *)`, `Bash(gh *)`, `Bash(git push*)`, `Bash(ssh *)`,
  WebFetch, WebSearch. A deny wins over the user's allow rules in `~/.claude/settings.json`.
- A `cairn-run-gate` exit 75 means re-issue; the case prompt says so.
- Four sessions at a time.
- Each trial's stream-json is saved under `~/.local/state/cairn-docs-evals/<run>/`, and the table
  links to that copy. Claude Code deletes its own transcripts after 30 days.

Grading:
- `checks` run against the finished tree, diffed from the fixture base: a string present or absent
  under a path, a file changed, a named `npm run check:*` passing.
- A case that edits docs also checks from the transcript that the docs gate ran and
  `docs-fact-checker` was dispatched.
- `judge` assertions go to one blind `claude -p --model opus --effort medium --tools ""` call from
  a neutral temporary directory, with `--json-schema` for its verdicts. It gets the diff, the final
  reply, the tool-call log, and the assertions. `unknown` counts as not passed and flags the
  transcript for reading.
- Diagnostics, recorded beside the grade: whether `cairn-docs` loaded before the first `docs/`
  edit, any attempt at a denied command, the `~/.dotfiles` commit, and the overlay hash.
- A result's `permission_denials` naming a command the process needs marks a harness fault.
- Errors and API-key use follow the standing answers.

Output: the table (case, arm, pass rate, pass^k, errors, faults, saved transcripts) on stdout,
raw results beside the transcripts. Fixture worktrees are removed at the end.

Acceptance: `run main --case rename-item-label --trials 1` completes with zero harness faults and
prints its row. Test: a unit test over the grader, the overlay's delete-then-extract, and the pass^k
arithmetic with canned stream-json, in the repo's test runner.

### T2. The cases (50 minutes, runner)

Outcome: `.claude/skills/cairn-docs/evals/evals.json` in skill-creator's shape (`skill_name`,
`evals[]` with `id`, `prompt`, `expectations`), each case adding `suite`, `pin`, `setup`, `checks`,
optional `judge`, optional `readOnly`, and optional `agent`. Every case pins `663ac5aeb`. Prompt
templates may use `{repo}`, `{base}`, and `{commit}`, filled per trial.

- `regression`:
  - `rename-item-label`: the setup renames `ArrayField.itemLabel` to `itemTitle` in
    `src/lib/content/fields.ts` and its callers only. The admin toolkit's own `itemLabel`
    (`ListToolbar.svelte`, `Pagination.svelte`, `list-toolbar.ts`) is a different prop and stays.
    A check confirms the rename applied.
  - `rename-export`, `deficiency`, and `new-page-trap`, ported from
    `~/Projects/initiatives/docs-system/research/2026-10-25-cairn-docs-evals/cases.json` with
    their assertions, the `fixed` assertion, and the wrap-safe `deficiency` seed. The reviewer
    confirmed each premise at the pin.
  - `fact-checker-key`, run with `agent: docs-fact-checker` and no `--model`, so the agent's
    own model applies as in real use. Its setup writes and commits a seed page holding the ten
    claims in `fact-checker/key.json`, and the prompt names `{repo}`, `{base}`, `{commit}`, and the
    page. A wrong or imprecise verdict on a false claim's line counts as found, and one on a true
    claim's line counts as a false positive. It passes on five of five found and at most one false
    positive.
  - The ten near-miss queries (`triggers.json` 11 to 20), with `readOnly: true`: run with Edit,
    Write, and NotebookEdit denied. Each passes when no Skill call names `cairn-docs`, and each is
    a harness fault if the `init` event's skills list lacks `cairn-docs`.
- `capability`: `code-and-docs`.

Acceptance: every declared setup applies at the pin, and a schema check in the T1 test passes.

### T3. The rules and records (20 minutes, runner; pairs with T4)

- `.claude/rules/evals-docs-process.md` (named outside the overlay's `docs*.md` glob), `paths:` the
  docs-process files, saying the design's change rule in three sentences with the run command.
- One line in `SKILL.md`: when the docs process went wrong in a session, file a cairn BACKLOG item
  tagged `#docs-process` with the session id. `SKILL.md` stays under 500 lines.
- `evals/sources.md`: the four sources the design cites, plus the skills best-practices page and
  skill-creator, each last read 2026-10-26.
- `evals/history.md`: a header and the entry format.
- `evals/README.md`: a few lines on the directory and the one command.

Acceptance: the cairn fast lane passes.

### T4. The cycle (35 minutes, runner; pairs with T3)

- `.claude/skills/cairn-docs/evals/cycle-prompt.txt` in cairn-cms, the design's seven steps shaped
  like `~/.dotfiles/docs/model-review/writing-prompt.txt`:
  - Step 0: if `~/.local/state/cairn-docs-cycle/pending` names an id, run `approval-queue collect
    <id>` under `setsid -f`, act on it, and skip to step 7. A resume waits for the next monthly
    start.
  - The sample skips every eval worktree (`docs-eval-*`, `trig-*`, `docs-trigger-*`, `eval-*`,
    `format-test`) and reports "no qualifying session" when none is left.
  - Step 4 runs `run main --suite all` in the background.
  - The triage file carries a non-empty `headline` and `lede` and rows of `action`, `why`, and
    `proposed` (`approval-queue/src/lib/brief.ts`, `validateTriage`). The session writes the id to
    the `pending` file before it waits on `approval-queue triage glw907/cairn-cms "<title>" <file>`
    as a background command, and clears the file once the decision is acted on.
  - A "now" row's fix goes out as a PR under the change rule, which the session merges after CI and
    the eval table. The cycle's records (`history.md`, a dropped row's entry) land as a hand-over: a
    branch, a PR the session merges, and a pull of the main checkout (`pass-core` "Ledgers").
- `bin/.local/bin/cairn-docs-cycle` in `~/.dotfiles`, modeled on `survey-writing-review`: pull
  cairn-cms, unset `ANTHROPIC_API_KEY`, and start `claude --bg --model claude-opus-5-5 --effort
  medium --name cairn-docs-cycle-<YYYY-MM>` in a `systemd-run --user --scope`. `--dry-run` skips the
  pull and step 4 and tells the session to write the triage file and stop without queuing it.
  `CAIRN_DOCS_CYCLE_REPO` overrides the cairn checkout (default `~/Projects/cairn-cms`).
- `model-review-notify` calls it on pavilion beside `survey-writing-review`, its result never
  changing the script's exit status. `stow -R bin`, and the dotfiles gate.

Acceptance: `CAIRN_DOCS_CYCLE_REPO=<pass worktree> cairn-docs-cycle --dry-run` launches a session
that writes a valid triage file, with either a row citing a non-eval session since 2026-10-26 or
the "no qualifying session" outcome.

### T5. Acceptance runs (60 minutes, runner)

In order, each a background command under the cap:

1. `run main --suite all`, about 48 case sessions. Apply the unstable-seed standing answer.
2. `run 25fb80fa3 main --case rename-item-label --trials 5`, 10 sessions: the new rules at pass^5,
   the old rules' rate beside them.
3. A control branch cut from `main` that deletes `cairn-docs`'s `description:` line: `run <control>
   main --suite regression --trials 1`, about 30 sessions, shows the regression suite drop. If it
   doesn't, rerun with a stronger control that also removes the skill's name from both rules and
   from `CLAUDE.md`, keeping `.claude/skills/` present. Delete the branch after.
4. `run docs-improvement-loop main --suite regression`, about 30 sessions, since T3 edits `SKILL.md`
   and this PR falls under its own change rule.

Each run's table goes in the PR body, with every failing trial's transcript read before its row is
reported.

### Close (25 minutes)

1. Whole-branch `diff-reviewer` on each PR, one fix chain, then the conductor's packet with the
   cairn-cms PR and the workstation PR. Merge order: workstation first, so the launcher exists
   before `model-review-notify` next calls it, then cairn-cms.
2. The conductor pulls both main checkouts and runs `stow -R bin`.
3. The conductor launches the first real cycle from cairn's main checkout with `cairn-docs-cycle`
   (`live-account`). Geoff rules on its triage in the queue.

## End-to-end check

Close step 3: the first real cycle reads the qualifying sessions since 2026-10-26, runs the suites
on `main`, queues a triage, and acts on Geoff's ruling.
