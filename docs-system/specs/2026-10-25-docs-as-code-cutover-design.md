# Docs-as-code cutover

Status: drafted 2026-10-25 for Geoff's approval. Initiative: `docs-system`. Repos: cairn-cms,
approval-queue, the workstation (`~/.dotfiles`), Survey, and drafter (deleted). Risk class: `runner`.
`live-account`: a scratch PR on `glw907/approval-queue` for the queue's end-to-end check, and the
morning `gh repo delete`. Nothing spends API credit.

Inputs, all in `research/`: the rulings (`2026-10-25-docs-as-code-rulings.md`, R1 to R16), the
retirement inventory (`2026-10-25-docs-system-retirement-inventory.md`, every path and order
constraint), the best-practice research (`2026-10-25-docs-as-code-best-practice.md`), and the
skills research (`2026-10-25-docs-skills-research.md`). A fresh plan review folded into this text on
2026-10-25. It replaces the cleanup program design, which was never approved.

## Brief

Tonight the docs system moves to standard docs-as-code. A cairn page is the maintained source,
changed in the same PR as the code. cairn's docs gate and a fresh fact-check against the code check
it, and you review it in the Approval Queue. There you edit the draft in place and add notes, as you
do now. Blueprints, the facts store, and drafter go (R1 to R3).

Three workstreams run side by side overnight. In cairn-cms, the run removes blueprints, facts,
briefs, and outlines with their gates, re-keys the options check, and rewrites the instructions. It
also adds a `cairn-docs` skill and a `docs-fact-checker` agent, built from Anthropic's guidance and
tested with evals. In the Approval Queue, one `docs` review replaces the blueprint, page, change, and
anchors kinds, written as if from scratch (R5, R7, R8). In the Claude infra, the run unlinks drafter
and rewrites every skill, agent, and doc that described the old system, to the same bar (R9 to
R12).

### What you'll find in the morning

- Merged cairn-cms and approval-queue PRs, each with a `## Decisions` section, and the new Approval
  Queue running.
- A `docs` review of one real cairn docs fix, made end to end with the new skill and agent.
- A `docs` review of the docs register's rewritten rulings, in a separate cairn PR, since that file
  records your rulings.
- One packet with the workstation and Survey PRs. It ends with two steps: you revoke the drafter
  API key, then the session deletes the drafter repo and clone.

### If you approve

1. The planning session merges `glw907/workstation#152`, this design, and the research records,
   writes the plans, launches the conductor, and closes. You have no pre-flight steps.
2. The run goes to its end without you.

### Standing answers

- **Merges.** A cairn-cms or approval-queue PR merges when its gate is green, the whole-branch
  review accepts it, its end-to-end check passes, and the residue read is clean. The gate is cairn's
  GitHub CI, and approval-queue's `tests/*.sh` plus `npm test`. A `cairn-run-gate` exit 75 is
  reissued until it prints `gate exit:`. The cairn PR merges only after the new queue is installed.
  The register PR, the workstation PR, and the Survey PR wait for you.
- **The residue read.** A fresh-context agent that hasn't seen the old system reads each
  workstream's result. It reports anything that names or serves blueprints, facts, drafter, the page
  chain, or the removed queue kinds, outside history records and product uses of the word "facts"
  (`site-facts.json`, `tool/internal/doctor/facts.go`). Each finding is fixed while its cause
  traces, with no round cap. A finding whose cause doesn't trace holds that PR for the morning
  packet.
- **Options re-keying.** A script places each `option-map.json` row at the reference section, on
  its root's page, that names the option. Ambiguous rows are judged by hand. A row with no such
  section becomes `pending <published-page>`, with `pendingCount` raised to match and a cairn
  BACKLOG item. `check-options.mjs` imports `headingAnchors` from `docs-links.mjs`, asserts that the
  anchor exists and that its section names the option, and stops reading outlines.
- **Accuracy corrections.** A facts-store entry or docs friction line that records a wrong claim
  still on a page becomes a cairn BACKLOG content item before its file is deleted.
- **Secrets and deletions.** R14 authorizes them, so they are not stops. The run executes
  `secret-set.sh DRAFTER_API_KEY --delete` against the dotfiles worktree's `secrets/values.age` and
  edits `secrets/registry.md` on the branch. `~/.local/secrets` regenerates with `sync.sh` after
  the morning merge. Each deletion lists its targets first. A step a permission layer refuses becomes
  a session step in the morning packet.
- **The interim.** Until the workstation PR merges, the live `approval-packet` skill still describes
  the removed docs commands. The run accepts that, since no session queues docs overnight except
  the conductor.
- **Ceilings.** In path minutes: cairn 330, the Approval Queue 400, the infra 200, and the morning
  reviews 60. The workstreams run in parallel, so the path is about 460, against a 900-minute
  ceiling. A task past twice its estimate keeps going while each step fixes a traced cause. Past the
  ceiling, the conductor finishes the task in flight and stops.
- **Stops.** A finding the run can't settle inside these answers is escalated in its PR, and the
  run goes on with the independent work. It stops only on a cause it can't trace, or an irreversible
  act this design doesn't name. Then STATUS carries the question and `notify-send -u normal` tells
  you.

## The Approval Queue

One PR, with the interface fixed in the plan before any executor starts.

- `approval-queue docs <worktree> <owner/repo#n> <title> --description <file> [--notes <file>]
  [--replies <file>]`. The worktree must be clean and at the PR head. The screen shows the PR body
  and the code diff, then each changed `docs/**/*.md` page as an editable diff against the merge
  base.
- Notes are `{file, anchor: {quote, prefix?, suffix?}, body}`. Your edits commit to the worktree, as
  today.
- A resend shows Revision N and what changed since the head you sent back.
- The approve is refused if the PR head moved. The decision prints `{decision, pr, head, commit,
  calls, comments, threads}`. The session pushes and runs `gh pr merge --match-head-commit
  <commit>`.
- `notes`, `notes --check`, `collect`, `pending`, `withdraw`, and the waiting-item check cover the
  `docs` kind.
- Removed with no trace: the `blueprint`, `page`, `change`, and `anchors` commands and screens, YAML
  handling, fact-tag parsing, `approved --kind`'s blueprint default, and every fixture, test, type,
  comment, and README line that served them. Decided items of those kinds stay on disk, unlisted
  (R16).
- Packets, PR review, and triage keep their behavior.
- **Install**, holding `flock ~/.local/state/approval-queue/start.lock`:
  `git -C ~/Projects/approval-queue pull --ff-only`, then `npm ci && npm run build` in
  `approval-queue/`, then stop the running app (`pkill -f '^node
  /var/home/glw907/Projects/approval-queue/approval-queue/build'`). Then queue and withdraw one
  `triage` item to start the new app, and check that it answers.

## cairn-cms

Two PRs, cut from `origin/main` at or after `2b5549ea0` (#144 merged, and its session has ended).

- **Remove:** `blueprints/`, `drafter.toml` and its `.gitignore` line, `docs/internal/facts/`,
  `docs/internal/briefs/`, `briefs-rebuilt.json`, `docs/internal/outlines/`, `check-facts`,
  `check-provenance`, `migrate-fact-ids`, `verify-harvest`, and their fixtures, tests, and
  `package.json` scripts.
- **Change in the same commit:** `docs-gate.mjs`, `close-prebuilt.mjs`, `gate-table.json`, the
  `test.yml` comment, `check-leaks.mjs`, `docs-links.mjs`, the review page's plan pane, and
  `check-options.mjs` with `option-map.json` re-keyed.
- **Rewrite as standard docs-as-code:** `CLAUDE.md` (one line that docs change in the same PR as the
  code, plus the gate command), `CONTRIBUTING.md`, `docs/STATUS.md` (including #71's redraft, now
  done), `docs/internal/exemplars/README.md`, and the ROADMAP's stage 2b part 2 entries.
- **Records:** the friction log loses its 77 docs-system lines. BACKLOG closes the mechanics items
  and #71, and re-aims the content items at their pages. The Claude Code page run's unfiled friction
  (`research/2026-10-25-claude-code-page/RESUME.md`: cairn items 7, 8, 10, 25, 27 to 29, 31, 34, and
  47, and agent items 24, 43, and 48) is triaged. An item that survives the retired system is
  filed, and the rest is dropped with its reason in the PR. History stays.
- **The skill and agent**, built evaluation first:
  - `.claude/skills/cairn-docs/` holds a short decision tree for three cases: changing docs with
    code, fixing a deficiency, and writing a new page. Two references sit beside it: `new-page.md`
    and `review.md`. The skill routes to the register and to Survey's `technical-doc-web.md` and
    `editor.md`, and never copies them. It says where a correction lands (R12).
  - A path rule, `.claude/rules/docs.md` with `paths: docs/**`, points at the skill.
  - `.claude/agents/docs-fact-checker.md` checks a page's changed lines against the code at a
    commit. It has read-only tools, an over-firing guard, and JSON findings. It replaces the
    workstation `fact-checker`, and living in cairn lets it merge and run tonight.
- **The register PR.** The docs register's page-plan rule and blueprint rulings are rewritten in
  a separate PR and queued for you as a `docs` review.

## The Claude infra

One workstation PR and one Survey PR, both held, plus local unlinking.

- **Unlink and remove:**
  - drafter's bins, the `blueprint` skill link, the `docs-page-chain` workflow, the
    `cairn-docs-drafter` agent, the workstation `fact-checker`, and the settings hook.
  - `~/.config/drafter/`, and the drafter lines in `bootstrap.sh`, `SECOND-WORKSTATION.md`,
    `untracked-bin.txt`, and `scripts/gate.sh`.
  - `DRAFTER_API_KEY`, as the standing answer says.
  - The spend ledger is copied to `research/drafter-ledger.jsonl.gz` before `~/.local/state/drafter/`
    and `~/.local/share/drafter/` are deleted (R14).
- **Rewrite ground-up:**
  - `approval-packet`'s docs section, for the `docs` kind.
  - The facts lines in `cairn-implementer`, `site-implementer`, `cairn-pass`, and `site-pass`,
    which now say to fix the page.
  - `engine-consult`'s evidence base, which becomes the reference pages and the code.
  - `claude-tooling.md`, `retired-phrases.txt`, and `spec-plan-review`.
  - In Survey, the blueprint example in `approval-brief.md` and the blueprint lines in `BACKLOG.md`.
- **Unchanged after a residue check:** `cairn-register-editor`, `register-check`, `cairn-figure`,
  and `figure-verifier`.

## Shape

One conductor, `conductor-approval-queue`, launches from the approval-queue checkout after the
one-executor-per-worktree checks. The planning session (`approval-queue-fd`) closes once the
conductor confirms. The conductor runs three executors on `sonnet` at `medium`, all at once. The
plan fixes the `docs` interface first, so the cairn `review.md` and the `approval-packet` rewrite
code against it.

At the end, the conductor makes one real docs fix with the new skill and agent: the
rotate-the-github-app-key page says `/healthz` answers 200 on a failed check, when it answers 503.
No eval uses that case. The conductor then queues the morning packet, the fix's `docs` review, and
the register PR's `docs` review, each as a background command.

## End-to-end checks

- **The Approval Queue**, on a throwaway state directory, with the app built for a spare
  `APPROVAL_QUEUE_PORT` and `xdg-open` stubbed:
  - Copy one decided `page` item in and confirm it isn't listed.
  - Open a `docs` review of a scratch PR on `glw907/approval-queue` with two changed pages and a
    code change. In the browser, edit one page (wait 2 s for the save) and add a note.
  - Send it back, resend it, and confirm Revision 2 with its changes.
  - Move the head and confirm the approve is refused. Approve at the head (wait 7 s for the post)
    and check the decision JSON and the committed edit. Close the scratch PR.
  - Confirm the removed commands are gone, and that a packet, a `pr` item, and a triage item still
    render and decide.
- **cairn:**
  - The docs gate passes, and the residue grep finds nothing outside the allowlist.
  - Each of the four `cairn-docs` eval cases lists pass/fail assertions, graded by a fresh Opus
    reader, and the skill run passes more assertions than the run without it.
  - A trigger query routes when `claude -p --output-format stream-json` shows a `Skill` call to
    `cairn-docs`, and at least 18 of 20 route correctly.
  - `docs-fact-checker` finds all 5 false claims among 10 seeded claims, with at most one false
    positive, in each of three runs.
- **The infra:** `claude-tooling-sync verify` and `check-drift` are clean on the branch, no link
  dangles, and `command -v drafter` prints nothing.
- **The program:** the morning `docs` review of the `/healthz` fix.

## Later

- An external link check on a weekly schedule (lychee).
- Shortening the docs register toward Google's "short and useful".
- A hook that runs the docs gate when `docs/**` changes.
- TypeDoc-generated reference.
