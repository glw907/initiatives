# Inventory of the old process's other skills

Read-only research for the process spec, 2026-11-20. It covers every skill of the old process
except `pass-core`. Each section of each skill gets a fate:

- **GOES**: it has no job under the new process.
- **CARRIES**: its content moves forward, into a new process skill or a repo's own files.
- **CONTROL**: it becomes, or already is, a permission rule, a hook, or a script. The line names which.

Every mechanism proposed as a new home is labelled **documented** (a Claude Code docs page
describes it), **assembled** (built from documented pieces), or **invented**. "Not stated" means
no file I read says it.

## Sources and short names

| Short name | File |
| --- | --- |
| DEC | `/var/home/glw907/Projects/cc-desk/docs/specs/2026-11-20-process-decisions.md` |
| CORE | `/var/home/glw907/Projects/cc-desk/docs/specs/2026-11-20-core-design.md` |
| CP | `/var/home/glw907/.claude/skills/cairn-pass/SKILL.md` (a link to `~/.dotfiles/claude/.claude/skills/cairn-pass`) |
| SP | `/var/home/glw907/.claude/skills/site-pass/SKILL.md` (a link into `~/.dotfiles`) |
| DP | `/var/home/glw907/.dotfiles/.claude/skills/dotfiles-pass/SKILL.md` (the dotfiles repo's project skill, primary checkout) |
| DBP | `/var/home/glw907/Projects/dubplate/.claude/skills/dubplate-pass/SKILL.md` (found while looking; not in the task's list) |
| RP | `/var/home/glw907/.claude/plugins/cache/glw907-standards/standards/741e7d52d6b5/skills/running-passes/SKILL.md` (the newest copy, and the one `installed_plugins.json` names) |
| CRP | `/var/home/glw907/Projects/cairn-cms/.claude/skills/cairn-running-passes/SKILL.md` |
| LP | `/var/home/glw907/Projects/cairn-cms/.claude/skills/cairn-running-passes/references/launch-prompts.md` |
| AP | `/var/home/glw907/.claude/skills/approval-packet/SKILL.md` |
| CD | `/var/home/glw907/.claude/skills/cc-desk/SKILL.md` |
| CDW | `/var/home/glw907/.claude/skills/cc-desk-work/SKILL.md` |
| CCM | `/var/home/glw907/Projects/cairn-cms/CLAUDE.md` |
| GCM | `/var/home/glw907/.claude/CLAUDE.md` |
| SET | `/var/home/glw907/.dotfiles/claude/.claude/settings.json` |
| VS | `/var/home/glw907/.dotfiles/claude/.claude/tooling/vendored-skills.json` |
| MEM | `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/memory.md` |
| SK | `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/cc-skills.md` |
| BP | `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/best-practices.md` |
| GOAL | `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/goal.md` |
| HK | `/var/home/glw907/.claude/jobs/ab2d5469/tmp/docs-fetch/hooks.md` |

Notes on the copies:

- `standards` has 13 cached versions. All carry `running-passes`; `741e7d52d6b5` is the newest
  (modified 2026-11-17) and is the installed path.
- `/var/home/glw907/Projects/cc-desk/skills/` holds two folders, `cc-desk/SKILL.md` and
  `cc-desk-work/SKILL.md`. `diff -q` against the installed copies under `~/.claude/skills/` found
  no difference. VS:109-125 vendors both from `glw907/cc-desk` and says "edit it in that repo only".
- No `dotfiles-pass` exists under `~/.claude/skills/`. The only copy outside the worktrees is DP.

## What the Claude Code docs say about homes

These are the citations the per-repo homes below rest on.

| Kind of content | Where the docs put it | Citation |
| --- | --- | --- |
| Facts every session needs: build, test, lint commands, conventions | Project `CLAUDE.md` | MEM:51, MEM:70, BP:136, BP:243 |
| The install command a fresh worktree needs | Project `CLAUDE.md`, or `.worktreeinclude` for small gitignored files, or `worktree.symlinkDirectories` | BP:586 |
| A recorded install and launch recipe | A per-project skill `.claude/skills/run-<name>/` written by `/run-skill-generator` | SK:66 |
| A check to run before each commit | A project skill named `verify`; Claude Code's commit instructions tell Claude to run it before each commit, except docs or tests changes (v2.1.286 or later) | SK:74-78 |
| A multi-step procedure | A skill | MEM:51, SK:11 |
| Instructions for one part of the codebase | A path-scoped rule in `.claude/rules/` with `paths` | MEM:90, MEM:196-211 |
| A skill that should load for certain files | Skill `paths` frontmatter | SK:418 |
| A rule with no exceptions | A hook, a deny rule, or a managed setting, not `CLAUDE.md` | MEM:36, BP:294 |
| A check enforced before the turn ends | A `Stop` hook | BP:157 |
| A review against the spec, skipping style | A subagent with a written review prompt | BP:262-268 |
| A reviewer that cannot edit | A custom subagent in `.claude/agents/` with `tools: Read, Grep, Glob` | BP:471 |
| What "done" means for an unattended run | A `/goal` condition with one measurable end state and a stated check | GOAL:54-66, BP:534-536 |
| What stops an unattended run | `--max-turns`, `--max-budget-usd`, a spend limit | BP:537 |
| Running setup when a background session makes its worktree | A `WorktreeCreate` hook; it replaces default git behavior, so it must also make the worktree | HK:57, HK:819 |

Two load facts matter for worktrees:

- A worktree session loads skills only up to the worktree root. With Claude Code v2.1.277 or
  later, a worktree with no `.claude/skills` at its root loads the main checkout's project skills
  (SK:183). A repo that commits `.claude/skills/` gets the branch's own copy.
- A path-scoped rule loads for a sibling worktree only when Claude starts in that worktree or
  moves there with `/cd` (MEM:218).

Not stated in the pages read: whether a path-scoped rule loads inside a review subagent, and
what `paths: []` does (907-life's rule uses it, see below).

## cairn-pass

**For:** the workstation overlay on a cairn-cms pass: the lane-aware gate wrapper, the CI watch,
and launch conventions (CP:4-7). **Loaded by:** a session planning, running, or closing a
cairn-cms pass, or a fresh session following a STATUS launch prompt (CP:5-6). It tells the session
to load `pass-core` and then CRP (CP:12-13).

| Section | Lines | Process or per-repo fact | Fate |
| --- | --- | --- | --- |
| Load order: `pass-core`, then CRP | CP:12-15 | Process | GOES |
| Cross-repo specs live in `~/Projects/initiatives/<id>/` | CP:16 | Process (workstation convention) | CARRIES, into the new process skill |
| "STATUS's next action names the plan; trust it" | CP:16-17 | Process | GOES: the timer starts free tasks from the spec (DEC:54-57) |
| Check `docs/internal/consultations/` for briefs first | CP:17-18 | Per-repo fact | CARRIES: CCM:19-20 already says each brief needs a verdict before work builds on it |
| Pair dispatch | CP:20-24 | Process | GOES: independent work becomes separate tasks the timer starts (DEC:54-57). Whether steps inside one task may still run as pairs is not stated |
| Gate: `cairn-run-gate '<string>'` | CP:26-27 | Per-repo fact plus a workstation script | Command: CARRIES to CCM. Wrapper: CONTROL (script `cairn-run-gate`; its four allow rules SET:57-60 are on CORE:507-510's list for the process spec) |
| Fast lane: `gate-tier.mjs --fast`, each leg through `CAIRN_GATE_LANE=<lane> cairn-run-gate` | CP:29-34 | Per-repo fact | CARRIES: CCM:28 and CRP:24 already hold `npm run lane:fast`. The lane names (light for Node-only and `make -C tool check`, never light for root `npm test`) are in CP only |
| Worktree setup: the launch's `.claude/worktrees/<name>`, then CRP's command | CP:36-37 | Per-repo fact | CARRIES: the command is already in CRP:17 |
| Full-suite home: CI on the draft PR; local full run only on `ci-green` exit 3; no gitleaks history scan owed | CP:41-42 | Per-repo fact | CARRIES to CCM (CRP:26 already says most of it) |
| CI watch: `ci-green <sha> --pr <n> --wait`, exit codes, approve a held run when the actor is `github-actions[bot]`, any other held run stops for Geoff | CP:44-49 | Per-repo fact plus logic | Command: CARRIES to CCM. Exit-code handling: CONTROL (script `ci-green`). The bot-approve rule: not stated whether it stays unattended. "Any other actor's held run stops the line for Geoff" becomes a "Couldn't finish" or "Held for you" entry; which one is not stated |
| "No task waits for CI before the next; a red stops the line" | CP:48-49 | Process | CARRIES, reworded for steps |
| Packet: `approval-packet` step 1 and `pass-core` "Close" | CP:51-52 | Process | GOES with `approval-packet` |

**Verdict:** delete whole. What it leaves behind: the lane rule for the fast lane (CP:30-34) and
the `ci-green` exit-4 rule (CP:45-47). Both belong either in CRP or in the scripts themselves.

## site-pass

**For:** the adapter for the four SvelteKit site repos (ecxc-ski, 907-life, aksailingclub-org,
cairn-pub): gate, fast lane, full-suite home, worktree setup, CI watch, risk-class path map,
checklist globs, close checklist (SP:3-8). **Loaded by:** "continue development", "next pass",
"finish pass", or a site roadmap (SP:6-7). Two sites route to it from a rule:
`ecxc-ski/.claude/rules/development-workflow.md:1-5` and
`907-life/.claude/rules/development-workflow.md:6-9`. `aksailingclub-org/CLAUDE.md:170` names it
too. Unlike CRP, these facts live outside the site repos, in the dotfiles copy.

| Section | Lines | Process or per-repo fact | Fate |
| --- | --- | --- | --- |
| Load `pass-core` first | SP:13 | Process | GOES |
| Plan, spec, archive, and architecture-doc paths come from the site's `CLAUDE.md` or STATUS | SP:14-16, SP:19 | Per-repo fact | CARRIES to each site `CLAUDE.md` (MEM:70) |
| Plan header carries a consultation-brief link or "no engine asks", plus "Sources consulted", from `engine-consult` | SP:16-18 | Process for every repo that builds on the engine | CARRIES: becomes a line every site spec carries. `engine-consult` already holds the protocol |
| Per-site table: gate, fast lane, full-suite home, worktree setup | SP:21-26 | Per-repo fact | CARRIES to each site `CLAUDE.md` (MEM:51, BP:136) |
| Pair dispatch | SP:28-32 | Process | GOES (as in cairn-pass) |
| Gate: `cairn-run-gate` on the light lane; `npm run check` must show 0 errors and 0 warnings | SP:34-35 | Per-repo fact plus workstation script | Command and the zero-warnings bar: CARRIES to each site `CLAUDE.md`. Wrapper: CONTROL (script) |
| Fast lane: check plus touched unit test files; no cairn-cms suite when no engine source is touched | SP:37-38 | Per-repo fact | CARRIES to each site `CLAUDE.md`, or a project `verify` skill (SK:74-78, documented) |
| Worktree setup: `npm ci`, then `npx svelte-kit sync`, and why | SP:40-42 | Per-repo fact | CARRIES to each site `CLAUDE.md` (BP:586, documented), or a `WorktreeCreate` hook (HK:57, assembled) |
| Full-suite home: local close run for three sites; aksailingclub-org has PR CI (ruling 11) | SP:46-48 | Per-repo fact, resting on a ruling | CARRIES to each site `CLAUDE.md`. How a site with no PR CI shows "green" at the sitting is not stated |
| Cross-repo specs live in `~/Projects/initiatives/<id>/` | SP:48-49 | Process | CARRIES, to the new process skill |
| CI watch: aksailingclub-org only, `gh pr checks <n> --watch --fail-fast` | SP:51-52 | Per-repo fact | CARRIES to `aksailingclub-org/CLAUDE.md`, which already names `ci.yml` as the PR gate (line 135) |
| Risk-class path map | SP:54-58 | Per-repo fact | CARRIES: path-scoped rules for the `auth-data` globs (MEM:196-211, documented). A script that reads the map to sort a pull request into "Read before merging" has no documented home: invented if built |
| Checklist globs: which reviewer for which paths | SP:60-64 | Per-repo fact | CARRIES: path-scoped rules or skill `paths` (SK:418, documented). Whether a rule reaches a review subagent is not stated |
| Close checklist: local close run, architecture-doc decisions, README and config comments, archive plan and spec with `git mv`, "Cairn backlog" list in the PR body, commit conventions | SP:66-78 | Mostly per-repo fact; the cairn-backlog hand-off is cross-repo process | CARRIES: the procedure to a site skill or `CLAUDE.md` (MEM:51); the checkable items into each task's goal (GOAL:54-66). Commit conventions already in GCM:56 |
| Following cairn-cms docs during the pass: fix the page on a `site-docs/<site>-<pass>` branch off cairn-cms `main`, merged under the docs gate before the site pass closes | SP:80-86 | Cross-repo process | CARRIES. Under the new process this is a second task in cairn-cms that the site task would build on. Not stated |
| When not to use | SP:88-90 | Process | GOES |

**Verdict:** delete whole once each site holds its own facts. It leaves behind the per-site table,
the risk map, the checklist globs, the close checklist, and the cross-repo docs rule.

## dotfiles-pass

**For:** the adapter for passes whose edits land in `~/.dotfiles` (DP:3-7). **Loaded by:** a
session planning, running, or closing such a pass (DP:5-6). It is a project skill of the dotfiles
repo, so a worktree of that repo loads the branch's copy (SK:183).

| Section | Lines | Process or per-repo fact | Fate |
| --- | --- | --- | --- |
| Load `pass-core` first | DP:12 | Process | GOES |
| Stow repo: a merge is live on the machine at once; a new `bin` script needs `stow -R bin` | DP:12-14 | Per-repo fact | CARRIES to a dotfiles `CLAUDE.md`. It matters most to the session that runs merges at the sitting (DEC:59-60) |
| Pair dispatch | DP:16-20 | Process | GOES |
| Gate: `bash scripts/gate.sh`, the light lane; a worktree session's Bash guard refuses the wrapped string | DP:22-25 | Per-repo fact plus a hook | Command: CARRIES to a dotfiles `CLAUDE.md` (also in GCM:55 today). Guard: CONTROL (hook `claude-launch-guard`, SET hooks) |
| Fast lane: `bash scripts/gate.sh --scope-changed` | DP:27-29 | Per-repo fact | CARRIES to a dotfiles `CLAUDE.md` or a `verify` skill (SK:74-78) |
| Worktree setup: none | DP:31 | Per-repo fact | CARRIES (one line, or nothing) |
| Full-suite home: the same command on the close head; no PR CI (ruling 11) | DP:35-36 | Per-repo fact, resting on a ruling | CARRIES to a dotfiles `CLAUDE.md` |
| Cross-repo docs in `~/Projects/initiatives/<id>/` | DP:38 | Process | CARRIES to the new process skill |
| CI watch: none | DP:40 | Per-repo fact | CARRIES (one line) |
| Risk-class path map | DP:42-48 | Per-repo fact | CARRIES to path-scoped rules (MEM:196-211) |
| "A wording-only edit to a `runner` path can land as a direct change" | DP:49-51 | Process | CARRIES only if the new process keeps direct changes. Not stated in DEC |
| Checklist globs: Python, Go, TS conventions skills by extension | DP:53-54 | Per-repo fact | CARRIES to path-scoped rules. GCM:65 shows the same pattern already in use (`rules/go.md`) |
| Close checklist: manifest record, `claude-tooling-sync verify`, one `gitleaks git` history scan, post-merge `stow -R bin` and `claude-tooling-sync apply`, writing voice | DP:56-62 | Per-repo fact | Pre-merge items: CARRIES into each task's goal. Post-merge steps: CARRIES to a dotfiles `CLAUDE.md`, or CONTROL (a script the merging session runs). The Vale and tellgrader nets are already CONTROL (PostToolUse hooks `vale-hook` and `tellgrader --hook` in SET) |

**Verdict:** delete whole once a dotfiles `CLAUDE.md` or a renamed repo skill holds the facts. No
`~/.dotfiles/CLAUDE.md` exists today, and CORE:71 says the core spec creates none. CORE:83-86 says
the stow steps and the dotfiles gate leave the global file for a narrower home in the third spec.

## dubplate-pass (found, not in the task list)

**For:** the dubplate adapter (DBP:3-7). **Loaded by:** a dubplate pass, or a fresh session
following a STATUS launch prompt; `dubplate/CLAUDE.md:71` names it. At 241 lines it holds far
more than the other adapters: per-repo conventions and lessons as well as process.

| Section | Lines | Fate |
| --- | --- | --- |
| Load `pass-core`; STATUS, plans, standing rules paths | DBP:12-14 | Load order GOES; paths CARRY to `dubplate/CLAUDE.md` |
| One executor per tree, with the production box rule (`5.78.148.42`, quiet-box check, read-only ssh in reviews) | DBP:18-24 | Busy check: CONTROL (script `claude-worktree-busy`, CORE:517). Box rule: per-repo fact, CARRIES to `dubplate/CLAUDE.md`; any part with no exceptions becomes a permission rule (BP:294) |
| Mutation proofs run, plan read against shipped code, plans just-in-time, planning-miss prevention, findings ranked | DBP:25-50 | Per-repo lessons: CARRY to a dubplate skill or `docs/standing-rules.md`. "Findings ranked" matches BP:268 |
| Concurrent passes, carried items, errata | DBP:31-41 | Process: GOES or CARRIES into the new process (task branches from an unmerged task, DEC:54-57) |
| Product touchpoints: corpus adjudication, the intake uploader sitting, the first-launch sitting | DBP:51-52 | CARRIES: these are Geoff's own sittings. Which group they land in is not stated |
| Dependency sweep once a round | DBP:53-59 | Per-repo fact: CARRIES as a task in each dubplate spec |
| Web review against the visual identity spec; pair subagent rules | DBP:60-66 | Review rule CARRIES; pairs GO |
| Conventions: Gate, Base, Setup, Test-first, Mutation proofs, Fixture states, Layering, No export ahead of a caller, Config keys, Skills, Commits | DBP:72-143 | Per-repo facts: CARRY to `dubplate/CLAUDE.md` (commands) and a dubplate skill or path rules (conventions) |
| Per-task review, Records (`pr-notes.md`), Clock, Dispatches, Stops (write to STATUS), Resume, Scope | DBP:133-186 | Process: Stops GOES (no session waits, DEC:100); Resume and Records GO or CARRY into the new process; Scope CARRIES (log-issue) |
| Adapter: gate, fast lane with `--base`, full-suite home (CI plus local `gate.sh --merge`), worktree setup, CI watch, risk map, checklist globs, close checklist | DBP:188-241 | Per-repo facts: CARRY to `dubplate/CLAUDE.md` (commands), path rules (risk map, globs), task goals (close items) |

## standards:running-passes

**For:** the generic lifecycle for any repo: design, plan, execute, gate, review, close (RP:3).
**Loaded by:** CRP names it as the holder of the lifecycle (CRP:8). The other adapters load
`pass-core` instead (CP:12, SP:13, DP:12, DBP:12). It ships in Geoff's `standards` plugin.

| Section | Lines | Fate |
| --- | --- | --- |
| A pass is one change, one session, one worktree, one PR; the repo guide wins | RP:8 | CARRIES, renamed: a task is one session, one worktree, one PR (DEC:54-55) |
| Risk classes | RP:12 | CARRIES: `auth-data` still decides which PRs are flagged (DEC:108) |
| Design: skip for a one-sentence change; settle seven items; backlog sweep; no extras | RP:16-28 | CARRIES as the spec's contents. Item 7 ("every step only the user can do") matches DEC:106 ("Secrets are gathered before the run starts") |
| Plan: task list with outcome, files, class, acceptance check, test, minutes; pre-flight list; pairs; path estimate; failing acceptance; `auth-data` test first; standing answers | RP:32-39 | Mostly CARRIES (the spec lists tasks with a goal each; "Estimates priced from measured minutes", DEC:134). Pairs GO. "A stop the plan writes carries a standing answer" GOES: no session waits on a question (DEC:100) |
| Execute: gates, pairs, judgment calls, scope, clock | RP:43-49 | Gates, scope, clock CARRY. Pairs GO. "Stop and ask only for..." (RP:47) GOES, replaced by the five controls (DEC:102-108) |
| Close: full suite, fresh whole-branch review, one fix chain, close checklist, PR brief, follow-ups | RP:53-58 | CARRIES. The review matches BP:262-268 (review against the spec, skip style) |
| Who merges: the repo's rule, else the maintainer | RP:60 | CONTROL: hook `claude-merge-guard` refuses `gh pr merge` today; Geoff approves at his sitting (DEC:59-60) |

**Verdict:** its content is the seed of the new process skill. The plugin copy can go once the new
skill exists. Who else uses the published plugin is not stated.

## cairn-running-passes (repo skill)

**For:** what a cairn-cms clone needs: worktree setup, fast lane, full-suite home, risk-class path
map, review checklists, close checklist (CRP:3). **Loaded by:** any session planning, running, or
closing an engine change (CRP:3); cairn-pass sends sessions to it (CP:12-15). It is committed, so
a cloud session gets it too (CCM:35).

| Section | Lines | Fate |
| --- | --- | --- |
| Lifecycle lives in `standards:running-passes` | CRP:8 | GOES: points at the new process skill instead |
| State in STATUS, BACKLOG, ROADMAP; plan deleted at close; cross-repo plans with the initiative | CRP:10 | Per-repo fact: CARRIES. Whether STATUS still holds "the next action" when the timer starts tasks is not stated |
| Set up a worktree: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync)` | CRP:14-20 | Per-repo fact: CARRIES to CCM (BP:586) or stays here. Could also feed a `WorktreeCreate` hook (HK:57, assembled) |
| Fast lane and full suite | CRP:24-26 | Per-repo fact: stays; CCM:28 already has the command |
| Risk classes, the `scripts/gate/` carve-out (Geoff, 2026-11-03), the harness-only fix rule, chassis tasks | CRP:28-43 | Map: CARRIES to path-scoped rules (MEM:196-211). The carve-out is a dated ruling; its fate waits on the standing-rules sort, which is only proposed (DEC:116-120) |
| Review checklists by path | CRP:45-47 | CARRIES to path rules or skill `paths` (SK:418) |
| Close checklist: live admin smoke on `auth-data`, docs, changelog and migration notes, `check:surface`, rulings, friction, docs-stage close (Geoff, 2026-10-07), no release | CRP:49-58 | Per-repo facts: CARRY into each task's goal. Several are already gates (`check:docs-gate`, `check:consumers-must`, `check:surface`): CONTROL (script). Docs-stage close writes to STATUS and is a dated ruling: waits on the sort |
| `references/admin-smoke-test.md` | CRP:62 | CARRIES (per-repo procedure) |
| `references/launch-prompts.md`: executor and conductor prompt fields | LP:1-31 | Conductor fields (LP:20-31) GO (DEC:78). Executor fields (LP:8-18: goal, checkout, setup, risk class, base, push target, held files, release scripts) CARRY into the task launch template |
| `references/pass-gate-tiers.md` | CRP:64 | CARRIES (per-repo fact behind the fast lane) |

**Verdict:** keep, rewritten. It is already the documented home for a repo procedure (SK:164). It
drops its lifecycle pointer and the conductor half of LP, and takes cairn-pass's two extras.

## approval-packet

**For:** writing one Approval Queue document, checking it, sending it, and acting on Geoff's
answer (AP:3-8). **Loaded by:** any session handing a PR, design, or plan to Geoff, or when
`pass-core` or "the approval-queue reminder hook" points to it (AP:5-8). CORE:539 found that hook
registered nowhere. GCM:12 says Geoff no longer reads the queue.

| Section | Lines | Fate |
| --- | --- | --- |
| A packet is one Markdown document, decision first | AP:13-16 | GOES. "Decision first" CARRIES into the sitting report |
| 1. Decide whether to send; `approval-queue land` for a PR with no call and no `auth-data` path | AP:18-24 | GOES. Its sorting idea CARRIES: no call and no `auth-data` maps to "Ready to merge"; a call or `auth-data` maps to "Read before merging" (DEC:108, DEC:123-124) |
| 2-4. Write, imitate the models, check the writing | AP:25-50 | Queue format GOES. Plain-words rules ("never counts", no made-up id, name a PR by what it does) CARRY into the report format |
| 5. `approval-queue check` and `send` | AP:51-58 | GOES |
| 6. Act on the answer: `approval-queue merge`, send-back threads | AP:59-68 | GOES. Merging moves to the session Geoff talks to (DEC:59-60) |
| 7. File follow-ups through `standards:log-issue` | AP:69-72 | CARRIES (RP:58 and CCM say the same) |
| Command forms | AP:75-78 | GOES |
| `references/model-close-packet.md`, `references/model-report.md` | AP:31-34 | GOES with the queue format |

Attached controls: `Bash(approval-queue *)` and `Bash(approval-queue merge *)` (SET:61-62) and the
auto-mode entry for `land` and `merge` (SET:417) are on CORE:507-513's list for the process spec.
`claude-merge-guard` says a merge "goes through `approval-queue`" (its docstring, line 2); CORE:515
leaves its text and rename to the process spec. It stays a CONTROL (hook) with a new exception path.

**Verdict:** delete whole. Nothing is left but the follow-up rule (already elsewhere) and the
plain-words rules for the report.

## cc-desk

**For:** the desk session: open from the brief, ask waiting questions one at a time, record
rulings in Geoff's words, answer merge questions and permission prompts, restart a stopped pass
(CD:3). **Loaded by:** the session `cc-desk` opens in Geoff's terminal, or any session where he
asks what is waiting (CD:3, CD:157-159).

| Section | Lines | Fate |
| --- | --- | --- |
| The brief, `<command>` prefix | CD:12-21 | GOES with the Go binary (DEC:58) |
| Times: Alaska time, never a UTC stamp | CD:23-29 | CARRIES into the sitting skill |
| The opening: one sentence when nothing waits; first question only | CD:31-78 | "Nothing waiting" sentence CARRIES. Questions one at a time GO: the sitting shows four groups and Geoff answers in one line (DEC:123-124, and the task's decided shape) |
| No ids: name a PR by what it does | CD:80-85 | CARRIES into the sitting report |
| A merge question: merge, fix again, close | CD:87-97 | GOES as a check-driven question. Whether "Read before merging" items take the same three answers is not stated |
| Record or ask; his words reach the record unchanged; `ruling record` | CD:99-128 | GOES with the binary. Whether his sitting answers are kept as a record is not stated |
| A wrong record, `--replaces` | CD:130-142 | GOES |
| Prompts and stopped passes | CD:144-153 | GOES: no prompt waits (DEC:100); a refused step is finished around and listed (DEC:105) |
| Outside the desk | CD:155-159 | GOES |

**Verdict:** delete whole. It leaves behind the time rule and the no-ids rule.

## cc-desk-work

**For:** how a session cc-desk launched reports a PR ready, files a follow-up, writes a question,
stops, and records a round's report (CDW:3). **Loaded by:** any session whose launch prompt names
it, and before any step where `pass-core` would send Geoff something (CDW:3). It overrides
`pass-core`'s hand-overs (CDW:19-27).

| Section | Lines | Fate |
| --- | --- | --- |
| Run command lines as the prompt prints them | CDW:12-17 | GOES (binary deleted, DEC:58) |
| Where `pass-core` sends Geoff something | CDW:19-29 | GOES. "Never ask Geoff in chat" CARRIES, matching DEC:100 |
| Report a PR ready: `--verdict accept/fix/escalate`, `--design inside/outside`, `--calls` | CDW:31-46 | Command GOES. The two honesty flags CARRY: an `outside` or `escalate` sends the PR to "Read before merging" |
| File a follow-up into `docs/follow-ups/` | CDW:48-53 | CARRIES as `standards:log-issue` into BACKLOG; the `docs/follow-ups/` form is cc-desk's own |
| Write a question, with a no-context reader test | CDW:55-86 | GOES: nothing asks Geoff between sittings (DEC:100). The reader test may CARRY into how a "Held for you" line is checked; not stated |
| Stop: `usage`, `irreversible`, `secret`, `auth_data`, `scope` | CDW:88-99 | GOES as a command. Each reason has a decided replacement (DEC:102-108): usage becomes a cap, CONTROL (`--max-turns` or `--max-budget-usd`, BP:537; the proposed caps in DEC:121-122 would be a script); irreversible becomes CONTROL (deny rules) plus a listed step; secret becomes a pre-run check; `auth_data` becomes decide, second review, flag; scope becomes "build what the goal covers, or end and say why" |
| Commit and push before you stop; a stop outside the five is not yours: take the choice, list it under `## Decisions` | CDW:101-103 | CARRIES as written |
| Conductor and design writer end with `session finish` | CDW:105-106 | GOES (DEC:78) |
| Record a report (conductor) with `calls` and `misses` | CDW:108-127 | GOES. "Calls" maps to the PR's `## Decisions`; "misses" has no named home |

**Verdict:** delete whole. It leaves behind commit-and-push before ending, the `## Decisions` rule,
and the two honesty flags.

## cc-desk repo `skills/`

`/var/home/glw907/Projects/cc-desk/skills/` holds `cc-desk/SKILL.md` and `cc-desk-work/SKILL.md`,
the source copies of the two skills above (VS:109-125). `scripts/gate.sh:4-5` runs a skills step
over `skills/*/SKILL.md` (under 160 lines, clean under Vale and tellgrader). DEC:133 says the new
process-skill text lands through a dotfiles pull request, so the new skills do not live here. When
both go, the two VS entries and the gate's skills step lose their subject.

## Per-repo facts and their homes

| Fact | cairn-cms | Sites | dotfiles | dubplate | Documented home |
| --- | --- | --- | --- | --- | --- |
| Gate command | CRP:24-26; CCM:28 | SP:21-26, SP:34-35 | DP:22-25; GCM:55 | DBP:190-191; `dubplate/CLAUDE.md:75-84` | Project `CLAUDE.md` (MEM:51, BP:136, BP:243) |
| Fast lane | CRP:24; CCM:28; CP:29-34 for lanes | SP:37-38 | DP:27-29 | DBP:193-198 | Project `CLAUDE.md`, or a project `verify` skill run before each commit (SK:74-78) |
| Worktree setup command | CRP:14-20 | SP:40-42 | DP:31 (none) | DBP:207-215 | Project `CLAUDE.md` (BP:586); a recorded `run-<name>` skill (SK:66); a `WorktreeCreate` hook (HK:57, assembled) |
| Full-suite home | CRP:26; CP:41-42 | SP:21-26, SP:46-48 | DP:35-36 | DBP:200-205 | Project `CLAUDE.md` |
| CI watch | CP:44-49 | SP:51-52 | DP:40 (none) | DBP:217-218 | Command in project `CLAUDE.md`; logic stays in script `ci-green` (CONTROL) |
| Risk-class path map | CRP:28-43 | SP:54-58 | DP:42-51 | DBP:220-224 | Path-scoped rules (MEM:196-211). A sorting script reading the map: no documented home |
| Checklist globs | CRP:45-47 | SP:60-64 | DP:53-54 | DBP:226-228 | Path-scoped rules or skill `paths` (SK:418) |
| Close checklist | CRP:49-58 | SP:66-78 | DP:56-62 | DBP:230-241 | A repo skill for the procedure (MEM:51, SK:11); checkable items in each task's `/goal` (GOAL:54-66) |

Workstation scripts and hooks the adapters rely on, all CONTROL already: `cairn-run-gate` (lanes,
exit 75 re-issue), `ci-green`, `claude-worktree-busy`, `claude-launch-guard` (refuses the wrapped
gate string in a worktree session, DP:23-24, DBP:76), `claude-merge-guard`. CORE:507-519 leaves
their rules and text to the process spec.

## What can be deleted, and what each leaves

| Skill | Delete whole? | What it leaves behind |
| --- | --- | --- |
| cairn-pass | Yes | Lane rule (CP:30-34) and `ci-green` exit-4 rule (CP:45-47), into CRP or the scripts |
| site-pass | Yes, after each site holds its facts | Per-site table, risk map, checklist globs, close checklist, cross-repo docs rule |
| dotfiles-pass | Yes, after a dotfiles `CLAUDE.md` or renamed repo skill holds its facts | Gate, fast lane, stow and post-merge steps, risk map, globs, close checklist |
| dubplate-pass | No; rewrite | Most of its 241 lines are dubplate conventions and lessons |
| standards:running-passes | Yes, once the new process skill exists | Its lifecycle is the seed of that skill |
| cairn-running-passes | No; rewrite | Keeps per-repo facts; drops the lifecycle pointer and LP's conductor half |
| approval-packet | Yes | Follow-up rule (already in RP:58, CCM); plain-words rules for the report |
| cc-desk | Yes | Alaska-time rule, no-ids rule |
| cc-desk-work | Yes | Commit and push before ending; `## Decisions` instead of a stop; the inside/outside and escalate flags |

## What each repo needs in its own files

**cairn-cms.** CCM:26-36 says "pass", hands each task to `cairn-implementer`, and dispatches the
reviewer before the PR. Those lines need the new words and the new shape: a background session per
task, a review against the spec. CRP keeps its facts and takes cairn-pass's lane and `ci-green`
rules. LP keeps only the executor fields. The `.claude/rules/` the CCM mentions (CCM:50) can take
the risk map and checklist globs.

**The site repos.** ecxc-ski, 907-life, and aksailingclub-org have a `CLAUDE.md`; cairn-pub has
none, only `.claude/settings.json`. Each needs its row of SP:21-26, its CI line, and its close
checklist in its own files, and its risk map and globs as path rules. The rules
`ecxc-ski/.claude/rules/development-workflow.md` and `907-life/.claude/rules/development-workflow.md`
route to `site-pass` and need rewriting or removal. 907-life's rule carries `paths: []` and a
`description:` field; MEM:249 says `paths` is the only field Claude Code reads, and what an empty
list does is not stated. `aksailingclub-org/CLAUDE.md:170` names both adapters. The four sites
share most facts; SK:172 allows a symlinked skill folder if one shared copy is wanted.

**dotfiles.** No `CLAUDE.md` exists. It needs one (or a renamed repo skill) with the gate, fast
lane, no setup, no CI, and the post-merge steps, plus path rules for its risk map and globs. The
GCM "Dotfiles Management" lines (GCM:52-61) would move there (CORE:83-86). The new process skills
themselves land here (DEC:133).

**dubplate.** `dubplate/CLAUDE.md:71-84` already holds the gate. The adapter facts (DBP:188-241)
and conventions (DBP:68-186) need a home in that `CLAUDE.md`, `docs/standing-rules.md`, path
rules, or a rewritten repo skill. The production box rule (DBP:23-24) needs its no-exception part
as permission rules.

**cc-desk.** No `CLAUDE.md`. The gate is `bash scripts/gate.sh` (README.md:36), and its Go legs
go when the Go goes (DEC:58). `skills/` loses both skills; VS:109-125 loses both entries. Its spec
work is exempt from the old process (DEC:11-13), and it is the first repo under the new one
(DEC:136-137), so it needs a `CLAUDE.md` with its gate before its first task.

## Gaps no file answers

- How a repo with no PR CI (three sites, dotfiles) shows "green" at the sitting (SP:46-47, DP:35-36).
- Where post-merge steps live for the session that runs merges (DP:58-60, CRP's main-checkout pull, RP:60).
- Whether `ci-green`'s bot-held run approval (CP:45-47) runs unattended.
- Whether steps inside one task still run as pairs.
- How a site task that must fix a cairn-cms page (SP:80-86) becomes a cairn-cms task.
- Whether a path rule reaches a review subagent.
- Whether STATUS still names a next action once the timer starts tasks.
