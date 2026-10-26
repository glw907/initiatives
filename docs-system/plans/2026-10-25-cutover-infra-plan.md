# Docs-as-code cutover: the Claude infra

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-25-docs-as-code-cutover-design.md`, "The
Claude infra", approved by Geoff 2026-10-25 (Approval Queue item 20261025T215556-1865163). Rulings
R9 to R14: `research/2026-10-25-docs-as-code-rulings.md`. Paths and order:
`research/2026-10-25-docs-system-retirement-inventory.md`, "drafter" and "Workstation". The `docs`
review's interface, which the `approval-packet` rewrite points at:
`plans/2026-10-25-cutover-contract.md` (the contract).

Executor: `dotfiles-docs-cutover`, `sonnet` at `medium`, under `conductor-approval-queue`. Repos:
glw907/workstation (`/var/home/glw907/.dotfiles`, worktree `.claude/worktrees/docs-cutover`,
branch `worktree-docs-cutover`) and glw907/survey (`/var/home/glw907/Projects/survey`, worktree
`.claude/worktrees/docs-cutover`, branch `docs-cutover`), plus local unlinking and deletions, and
one record PR on glw907/initiatives. Adapter: `dotfiles-pass`. Risk class `runner`, with one
`auth-data` task (T3, `secrets/**`; contract planning note 15). Not `live-account` overnight; the
morning `gh repo delete` is the conductor's, after Geoff's approval.

Path estimate: 175 path minutes against the design's 200. The arithmetic is under "Path".

Read at dotfiles `main` (clean, level with `origin/main`) and Survey `origin/main`. Survey's main
checkout is one commit ahead with another session's unpushed FRICTION entry (`df76ee7`); this plan
never touches that checkout (contract planning note 13).

## Pre-flight

Empty: nothing for Geoff. The conductor checks these before launch:

- `~/.dotfiles` is on `main`, `git status --porcelain` prints nothing, and `git rev-list --count
  HEAD..origin/main` prints 0 after `git fetch origin`; `git check-ignore -q .claude/worktrees/x`
  exits 0 in `~/.dotfiles`, `~/Projects/survey`, and `~/Projects/initiatives`.
- No row in `claude agents --json` other than the conductor (and, at T0, this session's own row,
  matched by name) has its `cwd` under `~/.dotfiles` or `~/Projects/survey`; `pgrep -af
  '[/](\.dotfiles|Projects/survey)/.claude/worktrees/docs-cutover'` prints nothing.
- `~/.local/bin/drafter` and `~/.claude/skills/blueprint` still exist (T1 lists them), and no
  process runs drafter (`pgrep -af '[d]rafter'` prints nothing).
- `gh auth status` answers; `node`, `npm`, `jq`, `stow`, `gzip`, `gitleaks`, `cairn-run-gate`,
  `claude-tooling-sync`, and `check-drift` resolve.
- `mkdir -p /var/home/glw907/.local/state/dotfiles-docs-cutover` has run.
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

- drafter is gone from the machine: no bin, link, workflow, skill link, config, or state, with the
  spend ledger kept in the initiative. `command -v drafter` prints nothing and no link dangles.
- **The workstation PR** (held for Geoff): every skill, agent, hook, doc, and setup file reads as
  if written for docs-as-code (R9, R10); `DRAFTER_API_KEY` leaves the store and the registry; the
  vendored Survey skill carries the Survey PR's text.
- **The Survey PR** (held for Geoff): the blueprint-era and drafter-named examples in
  `approval-brief.md` and the blueprint lines in `BACKLOG.md` rewritten (R12), with a patch
  version.
- The `/var/home/glw907/Projects/initiatives/docs-system/research/drafter-ledger.jsonl.gz` record,
  merged.

## Calls the plan makes

1. **Order.** Local unlinking (T1) runs first and early, because cairn's trigger test waits for the
   `blueprint` skill link to go. The rewording sits in the held PR; the design's "interim"
   standing answer accepts the live skills naming retired commands until it merges (inventory
   order 4 and 5 hold inside the PR: rewording before deletion, unlinking before the clone goes).
2. **The workspace id.** Before deleting `~/.config/drafter/`, T1 writes `DRAFTER_WORKSPACE
   <workspace_id>` (from `config.toml`'s `workspace_id` line) into STATUS. The conductor's
   key-revoke step needs it. It is not a secret, but it stays out of commits.
3. **The vendored Survey copy** changes only through Survey's "Releasing a change"
   (`/var/home/glw907/.claude/skills/survey/SKILL.md`), step 2: the workstation PR vendors the
   pushed Survey branch and carries a `## Before merge` for steps 3 to 5 (contract planning note 10).
   The version is 1.5.1 (Survey's `package.json` reads 1.5.0).
4. **Dated provenance stays.** A rule that serves the current system may keep a dated incident
   citation that names a retired thing (`plan-reviewer`'s B3c line, `design-refinement`'s
   approval-queue#4 headline): that is history. A rule that serves the retired system is rewritten
   or removed.
5. **The daisyUI "Blueprint" MCP server** (`daisyui-blueprint*`, `DAISYUI_BLUEPRINT_*`, "the
   licensed Blueprint server") is a product, not residue.

## Names

- STATUS: `docs-cutover-status.md` in `/var/home/glw907/.dotfiles/.git/worktrees/docs-cutover/`,
  never committed, beside `pass-task-clock`.
- `WT` = `/var/home/glw907/.dotfiles/.claude/worktrees/docs-cutover`; `SV` =
  `/var/home/glw907/Projects/survey/.claude/worktrees/docs-cutover`. Prompts and commands write
  both out in full.
- Gate: `bash scripts/gate.sh` from `WT` (the wrapper; a worktree-isolated session's guard refuses
  the wrapped string). Survey's gate: `scripts/gate` from `SV` after `npm ci`.

## Tasks

### T0. Launch, worktrees, baselines (15 min), by the session

Risk: `runner`, no edit.

1. One-executor checks (pre-flight's second line). `EnterWorktree` with the name `docs-cutover`
   from `~/.dotfiles`. Then `git -C /var/home/glw907/Projects/survey fetch origin && git -C
   /var/home/glw907/Projects/survey worktree add -b docs-cutover .claude/worktrees/docs-cutover
   origin/main`. Write STATUS (base commits, session name and id). Arm the API-drop wake-up (`/loop`
   with no interval) per `~/.claude/docs/unattended-work-guards.md`; pavilion has no lid.
2. Baselines: the dotfiles gate; `npm ci` and `scripts/gate` in `SV`.

Acceptance: both gates green; STATUS written.

### T1. Unlink and delete locally, keep the ledger (30 min), by the session, during the pair

Risk: `runner`. Outcome: the design's "Unlink and remove" on the machine and R14's ledger copy.

1. Call 2's workspace line into STATUS.
2. **The ledger.** `git -C /var/home/glw907/Projects/initiatives fetch origin && git -C
   /var/home/glw907/Projects/initiatives worktree add -b drafter-ledger
   .claude/worktrees/drafter-ledger origin/main`. Write `gzip -9 -c
   /var/home/glw907/.local/state/drafter/ledger.jsonl >
   <that worktree>/docs-system/research/drafter-ledger.jsonl.gz`. Check `zcat <gz> | sha256sum`
   equals `sha256sum /var/home/glw907/.local/state/drafter/ledger.jsonl` and the line counts match.
   Commit ("Keep drafter's spend ledger"), push, `gh pr create -R glw907/initiatives`, and merge it
   yourself with `gh pr merge <n> -R glw907/initiatives --merge` (a record changes no behavior;
   `pass-core` "Ledgers"). Remove that worktree. The initiatives main checkout is the conductor's
   to pull.
3. **The dry-run list.** Print and save to STATUS, for each target, `ls -ld` and `du -sh`:
   `/var/home/glw907/.local/bin/drafter`, `/var/home/glw907/.local/bin/cairn-docs-outline`,
   `/var/home/glw907/.local/bin/drafter-page-hook`,
   `/var/home/glw907/.claude/workflows/docs-page-chain.js`,
   `/var/home/glw907/.claude/skills/blueprint`, `/var/home/glw907/.config/drafter/`,
   `/var/home/glw907/.local/state/drafter/`, `/var/home/glw907/.local/share/drafter/`. Save `find
   /var/home/glw907/.claude /var/home/glw907/.local/bin -maxdepth 3 -xtype l` (dangling links before)
   too.
4. **Delete** exactly those targets (`rm` for the file and the links, `rm -rf` for the three
   directories), only after step 2's check passed. Then `rmdir /var/home/glw907/.claude/workflows`
   if it is empty (the install made it; the workstation keeps no workflow).
5. Check: `command -v drafter cairn-docs-outline drafter-page-hook` prints nothing; the dangling-link
   find prints nothing that was not in the saved list; `test ! -e
   /var/home/glw907/.claude/skills/blueprint`. Write `UNLINKED <time>` in STATUS.

Acceptance: step 5's checks hold, and the ledger PR is merged. A step a permission layer refuses
becomes a `[session]` step for the conductor's morning packet (standing answer 4), written in
STATUS as `MORNING <exact command>`.

### The pair: A beside B

Each subagent works only on its files in its own worktree (no setup command), runs the dotfiles
gate, commits, and never pushes. Each prompt carries the scope guard, calls 4 and 5 quoted, the
contract's path, and `/var/home/glw907/.claude/docs/voice/agent-facing.md` by path (the register
for skills and agents). Descriptions `docs-cutover task A`, `docs-cutover task B`.

#### A. Skills and agents (60 min), `sonnet` at `medium`

Risk: `runner`. Files: `claude/.claude/skills/{approval-packet,cairn-pass,site-pass,engine-consult,spec-plan-review}/SKILL.md`,
`claude/.claude/agents/{cairn-implementer,site-implementer,fact-checker,cairn-docs-drafter}.md`,
and a residue check of `claude/.claude/agents/{cairn-register-editor,figure-verifier,plan-reviewer}.md`
and `claude/.claude/skills/{register-check,cairn-figure,design-refinement}/SKILL.md`.

- `approval-packet`: "Blueprints and pages" becomes "Docs reviews", written for the `docs` kind: a
  docs PR is never a packet part; it is a separate `approval-queue docs <worktree> <owner/repo#n>
  <title> --description <file> [--notes <file>] [--replies <file>]` item; the description rule; the
  notes come from the repo's fact-check (cairn: the `cairn-docs` skill's `references/review.md`);
  the decision and the steps after it, from the contract's "The decision" and "The session's steps
  after the decision"; the Approval Queue README's "The docs kind" as the authority. Under 25 lines.
- `cairn-implementer`, `site-implementer`: "The facts container" sections become one rule each: a
  task that changes documented behavior fixes the page in the same commit (cairn: the `cairn-docs`
  skill; a site: cairn's fix rule, a `site-docs/<site>-<pass>` branch, per cairn's `CLAUDE.md`).
- `cairn-pass` close checklist's documentation bullet and `site-pass` line 77: the same rule; the
  friction-log triage stays for engine and content entries.
- `engine-consult`: the evidence base becomes the reference pages (`docs/reference/`) and the code
  at the commit; the dispute line cites a page or a `file:line`.
- `spec-plan-review` line 8: published docs pages are the docs review's (`cairn-docs` and
  `docs-fact-checker` in cairn).
- Delete `fact-checker.md` (replaced by cairn's `docs-fact-checker`) and `cairn-docs-drafter.md`.
- The residue check: the listed unchanged files stay unchanged unless one names or serves a retired
  thing outside call 4; report each file's result.
- Acceptance: the dotfiles gate is green; `git -C <A's worktree> grep -n -i -E
  'blueprint|drafter|facts (container|store)|docs/internal/facts|page chain|approval-queue (page|change|blueprint|anchors|approved)'
  -- claude/.claude/skills claude/.claude/agents ':!claude/.claude/skills/survey'` prints only
  call 4 and call 5 lines, each named in the report.

#### B. Machine files, docs, and ledgers (40 min), `sonnet` at `medium`

Risk: `runner` (`settings.json`, `scripts/**`, `claude/.claude/tooling/**`). Files:
`claude/.claude/settings.json`, `claude/.claude/docs/claude-tooling.md`,
`claude/.claude/tooling/retired-phrases.txt`, `bluefin/{bootstrap.sh,SECOND-WORKSTATION.md,untracked-bin.txt}`,
`scripts/gate.sh`, `docs/STATUS.md`, `BACKLOG.md`.

- `settings.json`: the `drafter-page-hook` PreToolUse entry goes; the repository-visibility line
  drops `drafter`.
- `claude-tooling.md`: the project-repo skill and workflow rows, the model-pin lines for
  `docs-page-chain.js`, `fact-checker`, and `cairn-docs-drafter`, and the "Workflows" section's
  drafter text; the project-skill row names cairn-cms's `.claude/skills/cairn-docs` and
  `.claude/agents/docs-fact-checker.md` as project scope, owned by that repo.
- `retired-phrases.txt`: the `docs-page-chain.js` entry (AW-20) goes with the file it guarded.
- `bootstrap.sh`: no drafter clone or install; `SECOND-WORKSTATION.md`: no drafter state line, clone,
  or install step (dated "found during" notes in its table stay, call 4); `untracked-bin.txt`: no
  `drafter`; `scripts/gate.sh`: no `DRAFTER_BIN`.
- `docs/STATUS.md`: the "Drafter" section becomes a docs-system line pointing at the initiative
  record.
- `BACKLOG.md`: each open item that only the retired system had (#36, the facts-store tellgrader
  exclusion, and any other B finds) is ticked with "Dropped: the docs-as-code cutover retired the
  system it served"; #37 is re-aimed at `cairn-register-editor` and cairn's `docs-fact-checker`.
- Acceptance: the dotfiles gate is green; `bash -n bluefin/bootstrap.sh scripts/gate.sh`; `jq empty
  claude/.claude/settings.json`; `git grep -n -i drafter -- claude/.claude/settings.json bluefin
  scripts docs/STATUS.md` prints only call 4 lines.

### T3. The secret (15 min), by the session after T1

Risk: `auth-data` (`secrets/**`). Outcome: `DRAFTER_API_KEY` out of the store and the registry on
the branch; `~/.local/secrets` untouched until the morning `sync.sh --local`.

1. `bash /var/home/glw907/.dotfiles/.claude/worktrees/docs-cutover/scripts/secrets/secret-set.sh
   DRAFTER_API_KEY --delete --values
   /var/home/glw907/.dotfiles/.claude/worktrees/docs-cutover/secrets/values.age --local
   "$XDG_RUNTIME_DIR/docs-cutover-secrets.check"`. The `--local` path keeps the live file as it is.
2. Check `grep -c '^export DRAFTER_API_KEY=' "$XDG_RUNTIME_DIR/docs-cutover-secrets.check"` prints
   0 and another name you know is in the store is present (name only, never a value), then `rm -f`
   the check file. Never print a value.
3. `secrets/registry.md`: remove the `DRAFTER_API_KEY` table row and its section.
4. Commit `secrets/values.age` and `secrets/registry.md` alone. Run a task-scope `diff-reviewer` on
   the commit (`auth-data`); a `fix` is fixed and read again.

If the age key cannot be fetched without a person (a `ws-pass-key` or `claude-pass` prompt, or a
refusal), stop the task, write `MORNING secret-set.sh DRAFTER_API_KEY --delete` with the exact
step-1 command in STATUS, do step 3 alone, and go on (standing answer 4).

Acceptance: the diff-reviewer accepts; `git -C <WT> grep -c DRAFTER_API_KEY -- secrets/registry.md`
prints 0 (or the morning line is in STATUS).

### T4. The Survey PR and its vendoring (30 min), by the session

Risk: `runner` (the vendored skill). Outcome: R12's cleanup in Survey, and the workstation PR
carrying it per call 3.

1. In `SV`: `skills/survey/writing/approval-brief.md`'s exemplars that name drafter or its parts
   (the packet with two asks, the routine-only packet, the gate-failed packet, its revision, the
   triage list, and the PR-brief before and after about YAML page plans and `drafter check-plan`)
   take a neutral subject of the same shape: the same number of exemplars, parts, asks, steps, and
   fences, since the Approval Queue's register test counts them (`tests/approval-queue.test.sh`
   expects at least 6 exemplars and 3 packet exemplars plus revisions). `BACKLOG.md`'s blueprint
   lines become docs-page lines or are dropped with a reason. `npm version 1.5.1
   --no-git-tag-version` and a dated `CHANGELOG.md` entry.
2. Gates: `scripts/gate` in `SV`; then the register test against the branch's file:
   `REGISTER=/var/home/glw907/Projects/survey/.claude/worktrees/docs-cutover/skills/survey/writing/approval-brief.md
   bash /var/home/glw907/Projects/approval-queue/tests/approval-queue.test.sh` (it reads the
   approval-queue main checkout and writes only to `mktemp`).
3. Commit, push `docs-cutover` to glw907/survey, open the PR.
4. Vendor it into `WT` per call 3: `S=$(mktemp -d); mkdir "$S/home"; ln -s
   /var/home/glw907/.dotfiles/.claude/worktrees/docs-cutover "$S/home/.dotfiles"`; `rm -rf
   <WT>/claude/.claude/skills/survey`; set the `survey` entry's `branch` in
   `<WT>/claude/.claude/tooling/vendored-skills.json` to `docs-cutover`, run
   `<WT>/bin/.local/bin/claude-tooling-sync update-skills --home "$S/home" survey`, then set
   `branch` to `v1.5.1`. Check `diff -r <SV>/skills/survey <WT>/claude/.claude/skills/survey`
   prints nothing. Commit.

Acceptance: both gates and the register test pass; the diff check is empty.

### CT. Close: gates, checks, residue read, PRs ready (65 min), by the session

Risk: `runner`.

1. Merge A, then B, into `worktree-docs-cutover` (T1, T3, and T4 commits are already on it); run
   the dotfiles gate on the head; run `gitleaks git` over the branch history (the adapter's close
   step).
2. **The design's infra check, on the branch.**
   - `claude-tooling-sync lint --root /var/home/glw907/.dotfiles/.claude/worktrees/docs-cutover`
     exits 0.
   - `claude-tooling-sync verify` against the branch: a scratch home with `.dotfiles` linked to
     `WT` and `stow -d <WT> -t "$S/home" claude bin`, then `claude-tooling-sync verify --home
     "$S/home" --projects-root /var/home/glw907/Projects` exits 0.
   - `check-drift` on the live machine; each finding that only the merge clears is listed in the
     PR with the branch line that clears it, and becomes the morning packet's check after the merge.
   - `command -v drafter` prints nothing; no link dangles under `/var/home/glw907/.claude` or
     `/var/home/glw907/.local/bin` (T1's find).
3. **The close review.** `diff-reviewer` at whole-branch scope on the workstation PR against the
   design, the contract, and this plan (the adapter's globs: none of `*.py`, `*.go`, `*.ts` change,
   so no extra checklist), and once on the Survey PR. One batched fix chain quoting each finding
   verbatim, then the gates. A second review only on a blocker.
4. **The residue read** (below). Fix each traced finding and rerun until clean (no round cap;
   standing answer 2).
5. **The PRs.** Push `worktree-docs-cutover` to glw907/workstation and open the PR. Its body:
   `## Brief` per `~/.claude/docs/voice/approval-brief.md`; what landed; the dry-run list and what
   was deleted; the ledger PR; `## Before merge` with call 3's steps written out (merge the Survey
   PR; release `1.5.1` from a fresh clone, `R=$(mktemp -d); gh repo clone glw907/survey
   "$R/survey"`, `npm ci` and `scripts/release 1.5.1` in it; then the check `git -C "$R/survey" diff
   --quiet <vendored commit> v1.5.1 -- skills/survey`), plus, if T3 deferred, the secret step;
   `## After merge` (pull `~/.dotfiles`, `stow -R claude bin`, `claude-tooling-sync apply`, `bash
   /var/home/glw907/.dotfiles/scripts/secrets/sync.sh --local`, then `check-drift` and
   `claude-tooling-sync verify` clean); `## Decisions` (at least: the retired agents
   `fact-checker` and `cairn-docs-drafter`, and the old facts rules in `cairn-implementer` and
   `cairn-pass`, leave the live tree only when this PR merges, because `~/.claude/agents` and
   `~/.claude/skills` link into the dotfiles main checkout; a departure from the design's "unlink
   and remove", forced by the held PR); `## Planning misses`; the score; "Found, not
   done" (at least: thinkpad-x1's drafter install, contract planning note 12) with BACKLOG numbers.
   The Survey PR's body: `## Brief`, what changed, the register-test result.
6. Mark both ready, write `READY workstation#<n> <head> survey#<m> <head>` and each `MORNING` line
   in STATUS, and send `conductor-approval-queue` one message: both PRs and heads, the ledger PR,
   the workspace line, every `MORNING` step, the checks' results, the review and residue verdicts,
   every clock overrun, and every departure from the plan. Never merge.

## The residue read

After the close review's fix chain. Agent tool, `subagent_type: general-purpose`, `model: opus`,
description `docs-cutover residue read`, with the heads filled in:

```
You are reading two repositories and one machine for leftovers of a retired system. You have not
seen that system and need not understand it; report what names it or serves it.

Read only. Never edit, never delete, never run a command that writes.
- The workstation branch: /var/home/glw907/.dotfiles/.claude/worktrees/docs-cutover at <head>.
- The Survey branch: /var/home/glw907/Projects/survey/.claude/worktrees/docs-cutover at <head>.
- The machine: the entries of /var/home/glw907/.claude/skills, /var/home/glw907/.claude/workflows
  (it may be gone), and /var/home/glw907/.local/bin, and whether any link there dangles.

The retired system: docs "blueprints" (page plans, *.blueprint.md and *.blueprint.yaml) and a
"blueprint" skill; a "facts store" or "facts container" (docs/internal/facts, fact ids like f:abc123,
"file a facts bullet"); page briefs, outlines, and page plans; a tool named "drafter" with its bins
(drafter, cairn-docs-outline, drafter-page-hook), config, state, and DRAFTER_API_KEY; a
"docs-page-chain" workflow; agents named "fact-checker" (the workstation one) and
"cairn-docs-drafter"; and Approval Queue "blueprint", "page", "change", "anchors", and "approved"
commands.

What replaced it: cairn-cms pages are the source, changed with the code, checked by cairn's docs gate
and its docs-fact-checker agent, guided by its cairn-docs skill, and reviewed as one "docs" review
(approval-queue docs ...).

Report every place outside the allowed list that names or serves anything retired: skills, agents,
hooks, settings, CLAUDE.md files, docs, setup scripts, manifests, open BACKLOG.md items, and the
Survey writing files.

Allowed, do not report:
- History: in the workstation, docs/plans/**, docs/specs/**, docs/research/**, docs/record/**,
  docs/model-review/**, claude/.claude/docs/record/**; in Survey, CHANGELOG.md entries for released
  versions and FRICTION.md; BACKLOG.md items marked [x]; git history.
- A dated incident citation (a date and what happened) inside a rule that serves the current system.
- The daisyUI "Blueprint" MCP server: daisyui-blueprint, DAISYUI_BLUEPRINT_*, "the licensed
  Blueprint server".
- The vendored copy claude/.claude/skills/survey, if it matches the Survey branch exactly.

Reply with one JSON array and nothing else:
[{"where": "<path or machine entry>", "line": 12, "text": "<the line>", "why": "<what retired thing it names or serves>"}]
An empty array means clean.
```

## Path

T0 15 + pair (A 60, B 40; the session's T1 30 and T3 15 run inside it) 60 + T4 30 + CT 65 = 170,
rounded to 175 for the ledger PR's merge wait. The task sum is 255. The design set 200.

## Models

- Executor: `dotfiles-docs-cutover` on `sonnet` at `medium`.
- A and B: Agent-tool subagents (`general-purpose`) on `sonnet` at `medium`.
- The close review, T3's task read, and the residue read: `claude-opus-5-5`.
- Conductor: `conductor-approval-queue` on `claude-opus-5-5` at `medium`.

## Standing answers

From the design, made concrete for the workstation and Survey, applied in place of stopping:

1. **No merge overnight.** The workstation PR, the Survey PR, and their `## Before merge` wait for
   Geoff's packet. The only merge this executor makes is the initiatives ledger record (T1).
2. **The residue read.** Each finding is fixed while its cause traces, with no round cap. A finding
   whose cause doesn't trace is reported in the PR, the PR still goes ready, and the conductor
   raises it as a `gate-failed` ask.
3. **Secrets and deletions.** R14 authorizes them; they are not stops. Each deletion lists its
   targets first (T1 step 3), and only the listed targets go. `~/.local/secrets` regenerates with
   `sync.sh --local` after the morning merge.
4. **Refused steps.** A step a permission layer refuses becomes a `MORNING` line in STATUS and a
   `[session]` step in the morning packet; the run goes on.
5. **The interim.** Until the workstation PR merges, the live `approval-packet` skill describes the
   removed docs commands; no session queues docs overnight but the conductor, which reads the
   contract.
6. **Ceilings.** This plan's path is 175 against the design's 200 and the run's 900-minute
   ceiling. A task past twice its estimate keeps going while each step fixes a traced cause; the
   clock-stop hook's "wait for Geoff" line is answered here: write the minutes to STATUS, rewrite
   `start=` to now, run no `notify-send`.
7. **Stops.** A finding these answers can't settle is escalated in the PR and the run goes on with
   independent work. The executor stops only on a cause it can't trace or an irreversible act this
   plan doesn't name (deleting anything not on T1's list is one): it removes the clock file, writes
   the question in STATUS, and messages `conductor-approval-queue`. It never runs `notify-send` and
   never asks Geoff.
8. **Other repos.** A cairn-cms or approval-queue follow-up goes to that repo's `BACKLOG.md`
   through `log-issue`, never into its tree.
9. **The drafter repo and clone** are not touched overnight: they go in the morning, after Geoff
   approves the packet, by the conductor.
