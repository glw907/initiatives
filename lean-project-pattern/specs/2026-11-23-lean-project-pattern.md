# Spec: the lean project pattern, piloted on dubplate

Status: proposed, waiting for Geoff's approval. Three repos are read: `glw907/dubplate` on `master` at
`95f8592`, `glw907/workstation` on `main` at `0b2589bb`, and `glw907/standards` on `main` at `5f18621`.

Three tasks set one pattern for how a project holds its rules, decisions, and build order. Task 1
pilots it on dubplate: a shorter `CLAUDE.md`, a `docs/decisions/` folder of records, and four new
gate checks against bloat. Task 2 writes the pattern into the `building-from-specs` skill. Task 3
teaches `standards:diff-reviewer` to block code that is more general than it needs to be, and code
that breaks an accepted decision record. Tasks 1 and 3 run side by side, and task 2 waits for task 1.
Nothing a dubplate member or operator sees changes.

## Intent

Geoff's words, 2026-11-23:

- "It doesn't matter how I currently do it. What matters is how I should do it."
- "Note that our principle audience for this system is local agents. So we need a system that's
  battle-tested for agentative development."
- "It should be lean, and effective at producing clean, streamlined, and well-architected code that
  doesn't leave a bunch of technical debt."
- "I want to avoid a system that layers patches and workarounds."
- "My expecience is that agentive development to sometime lead to bloated and overengineered code,
  and tends not to have good judgement about when to refector."
- "And will this new process help claude code determine the most logical and efficient build
  order?"
- "I don't want to testing out novel ideas. I just want the best practices that produces
  clean/well-architected code."
- "yes, write the spec"

### Goals

- dubplate's `CLAUDE.md` holds only what an agent can't learn from the code.
- Every binding decision in dubplate lives in one record with a status, and a change of mind is a new
  record.
- A rule a tool can check is a gate check, and its prose is deleted.
- A spec orders its tasks by one documented shape, so the build order follows from the spec.
- A refactor has one trigger and one form, so it is neither skipped nor folded into feature work.
- Review blocks an abstraction nothing needs.

### Non-goals

- Moving cairn-cms, phonebook, or the other repos onto the pattern. Each moves in a later spec.
- Refactoring dubplate's 12 over-complex functions or clearing its 241 unused-export warnings.
- A product document, a feature list, an architecture map, or any other file that isn't documented
  practice. Geoff ruled out novel pieces.
- Changing how a task launches, merges, or reports. PR #271 and the merge-tiers spec own those.

### Failure, even if it works

- A rule lives in two places after the change, such as a record and a `CLAUDE.md` line.
- A new check fails on today's code, so the first task after the pilot meets a red gate it didn't
  cause.
- A record restates code instead of a decision, so the folder grows into a second copy of the code.
- The reviewer blocks an abstraction the criteria asked for.

## What happens when it goes wrong

| What goes wrong | What follows | Limit |
| --- | --- | --- |
| A new check flags code the task didn't write | The task lists the finding as a named exclusion, the way the 12 complex functions are listed, and the pull request names it | One exclusion per finding, never a path-wide one |
| A record's content is disputed in review | The record is marked `Proposed`, which binds nothing, and the pull request lists it under `## For Geoff` | None |
| The reviewer eval scores under 0.8 | Task 3 revises the bar's wording and reruns, inside its time clause | `--max-cost-usd 6` per run |
| A task runs long | Its `/goal` time clause ends it | Twice its planned minutes |
| `CLAUDE.md` grows past 200 lines later | The new gate check fails | 200 lines |

## Approaches

1. **Keep the prose rules and add documents.** Leave dubplate's rules in `CLAUDE.md` and
   `docs/standing-rules.md`, and add an architecture page and a decisions folder beside them. It is the
   smallest change, but it layers new files over the old ones, which Geoff ruled out.
2. **Anthropic's long-running harness.** A JSON feature list that sessions mark as passing, a progress
   file, and an initializer session. Anthropic's engineering post describes it, but it is one team's
   harness for one kind of run, and Geoff asked for mainstream practice. Dropped on 2026-11-23, with
   computed dependency links between features and a per-document trigger table.
3. **Mainstream pieces only (the pick).** A short `CLAUDE.md`, decision records with a status, rules
   turned into checks, Spec Kit's task order, a walking skeleton, `/simplify`, Tidy First, and a review
   bar from Google's guide. Each piece has a published source, listed below. Few controlled studies of
   agentic development exist, so "mainstream" here means documented and widely used, not measured.

## Mechanisms and their sources

| Mechanism | Label | Source |
| --- | --- | --- |
| `CLAUDE.md` under 200 lines | documented | Anthropic's memory guide (<https://code.claude.com/docs/en/memory>) sets a target of under 200 lines per file and says longer files "reduce adherence". |
| No overview or history in `CLAUDE.md` | studied | "Evaluating AGENTS.md" (<https://arxiv.org/abs/2602.11988>): context files "[do] not generally improve task success rates, while increasing inference cost by over 20% on average", and repository overviews were not helpful. |
| Decision records with a status, superseded never edited | documented | Nygard's format via <https://adr.github.io>; Thoughtworks rates lightweight ADRs "Adopt" (<https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records>); Fowler, <https://www.martinfowler.com/bliki/ArchitectureDecisionRecord.html>. |
| `docs/decisions/` as the path | documented | MADR's default folder, via <https://adr.github.io>. |
| Accepted records bind an agent, proposed ones inform, superseded ones are history | documented | O'Reilly Radar, "Coding agents love decision records" (<https://oreilly.com/radar/coding-agents-love-decision-records/>). |
| Task order: setup, foundation, then one phase per feature by priority, parallel-safe tasks marked | documented | Spec Kit (<https://github.github.com/spec-kit/>) and Microsoft's Spec Kit module (<https://learn.microsoft.com/en-us/training/modules/spec-driven-development-github-spec-kit-enterprise-developers/7-generate-implementation-tasks-file>). |
| A new project's first task is a walking skeleton | documented | Cockburn, via <https://henricodolfing.com/2018/04/start-your-project-with-walking-skeleton.html> and *97 Things Every Software Architect Should Know*, ch. 60 (<https://oreilly.com/library/view/97-things-every/9780596800611/ch60.html>). |
| Riskiest task first | in use | `references/writing-a-spec.md`: "The task that rests on the least-proven assumption goes first." |
| `/simplify` before review | probed | Built into Claude Code (<https://code.claude.com/docs/en/commands>). Probe below. |
| A tidy goes in a separate commit; a larger refactor is a separate task | documented | Beck, *Tidy First?* (<https://www.oreilly.com/library/view/tidy-first/9781098151232>). |
| Review blocks code "more generic than it needs to be" | documented | Google's code review guide (<https://google.github.io/eng-practices/review/reviewer/looking-for.html>). |
| dupl, gocognit, forbidigo in golangci-lint | probed | `golangci-lint` 2.15.0, the version CI pins. Probes below. |
| `deadcode -test` | probed | `go tool deadcode -h`: "-test  include implicit test packages and executables". Probe below. |
| Existing findings listed as named exclusions | probed | golangci-lint's `linters.exclusions.rules`. Probe below. |

The probes, run on 2026-11-23:

- On dubplate at `95f8592`, a scratch golangci-lint config enabled dupl (threshold 150), gocognit
  (min-complexity 30), and forbidigo (`^time\.(Now|Since|Until)$` and `^exec\.Command$`), excluded
  `_test.go` files, and excluded forbidigo's clock matches under `cmd/`, `tools/`, and
  `internal/harness/`. With no other exclusion it printed `27 issues: forbidigo: 15, gocognit: 12`.
  All 15 forbidigo hits are `time.Now` or `time.Since` under `cmd/dubplate-server` and
  `tools/close-evidence`; they printed only before the path exclusion matched, because the scratch
  config sat outside the repo. With the path exclusion in effect and one exclusion per complex
  function, it printed `0 issues.` and exited 0. dupl alone printed no finding.
- The 12 functions over 30: `cmd/dubplate-server/doctor.go` `newDoctorCmd` (35),
  `internal/engine/matcher/assign.go` `findPath` (36), `internal/engine/tagio/container.go`
  `parseBlocks` (43), `internal/harness/analysis/album_info.go` `CheckAlbumInfoLedger` (35),
  `internal/harness/conform/case.go` `gradeCaseDefault` (34),
  `internal/harness/subsonic/fixture/manifest.go` `(*Library).check` (31),
  `internal/harness/subsonic/grade/assignment.go` `(*assignment).problems` (40),
  `internal/harness/subsonic/session/session.go` `(*Session).validate` (45),
  `internal/harness/subsonic/xmlrule/project.go` `(*schema).project` (50),
  `internal/intake/accept.go` `(*submissions).commitVerdict` (37), `internal/intake/gate/zip.go`
  `walkZIP` (31), `internal/store/swap.go` `(leaf).swapPlan` (31). Each exclusion matches its path
  and the text ``func `<name>` ``.
- `go tool deadcode -test ./...` printed nothing and exited 0. `go tool deadcode ./...`, the leg
  `scripts/check.sh` runs as a warning today, printed 241 lines: matcher 92, conform 70, musicbrainz
  37, analysis 31, and 11 elsewhere. The engine was built ahead of intake, its caller.
- `/simplify` ran twice headless with `claude -p ... --model sonnet --permission-mode acceptEdits`. On
  a scratch repo's uncommitted diff it removed a one-implementation interface. On a scratch repo with
  a committed `feature` branch it was told "/simplify the committed changes on this branch against
  main, then commit your fixes". It removed the `Maxer` interface, its implementation, and an unused
  `verbose` option, and committed that separately as `Replace Maxer interface with a Max
  function`.
- `claude plugin eval ./plugins/standards --case 'diff-reviewer-*' --runs 1` ran in
  `~/Projects/standards`. With `--model claude-fable-5-2` it scored 0 on an API error: "You've hit your
  Fable limit · resets Nov 27, 11pm (America/Anchorage)". With `--model claude-opus-5-5` it exited 0,
  `diff-reviewer-unmet-criterion` scored 1, and the run cost 0.19 dollars.

## Assumptions

- **The new checks pass on today's code, given the listed exclusions.** Task 1 and every later task
  rest on it. The golangci-lint probe above printed `0 issues.`; the `deadcode -test` probe printed
  nothing.
- **A task session can edit `building-from-specs` in a workstation worktree.** Task 2 rests on it.
  PR #271's branch, `worktree-task-chains`, edits `SKILL.md` and `references/writing-a-spec.md` from
  a task session. The denials log's `[Self-Modification]` refusals in the last 30 days all target a
  `settings.json`, a `stow` run, or a `git worktree add` under a repo's `.claude/`, never a skill file.
- **The reviewer reads a decision record from its working tree.** Task 3 rests on it. The agent has
  Read, Grep, Glob, and Bash and sets `omitClaudeMd: true`, so it learns of `docs/decisions/` only
  from its definition. Task 3's second eval case proves the read.

## Files

| Search, run 2026-11-23 | Hits | Disposition |
| --- | --- | --- |
| dubplate: `git grep -c standing-rules` | 20 files | `CLAUDE.md` (3) and `.claude/skills/dubplate-build/SKILL.md` (3) change in task 1. `BACKLOG.md` (3) hits are all in `## Done` items (#136, #134, #70) and stay. `docs/archive/plans/` (10 files), `docs/plans/2026-11-20-structure-{base,keys}-prompt.txt` (2, for merged PRs #18 and #19), `docs/research/` (4), and `docs/specs/2026-10-11-dubplate-alignment-design.md` (1) are frozen records and stay as written. |
| dubplate: `git grep -c -E '^\*\*(Two standing bars\|Words\|Versions\|Build for 0\.8\|Current dependencies)' -- CLAUDE.md` | 5 | All become records in task 1. |
| dubplate: `git grep -c -E '^## Refused features' -- CLAUDE.md` | 1 | Becomes a record in task 1. |
| dubplate: `git grep -c _salvage -- CLAUDE.md` | 1 | Deleted in task 1; STATUS says `_salvage` left the tree in PR #18. |
| dubplate: `git grep -c -i 'screenshot read in the main loop'` | 1, `CLAUDE.md` | Moves to the dubplate-build skill in task 1. |
| dubplate: `golangci-lint linters -c .golangci.yml`, enabled list | 8 linters, none of dupl, gocognit, forbidigo | `.golangci.yml` changes in task 1. |
| dubplate: `git grep -c 'deadcode -test' -- scripts/check.sh` | 0 | `scripts/check.sh` changes in task 1. |
| workstation: `git grep -n -E '/simplify\|[Tt]idy\|walking skeleton\|docs/decisions\|Spec Kit\|parallel' -- claude/.claude/skills/building-from-specs` | 1 | The hit is in `evals/results/2026-11-22/.../write-two-sources.md`, an eval transcript, and stays. `SKILL.md` and `references/writing-a-spec.md` change in task 2, and `references/repo-files.md` is new. |
| workstation: open pull requests touching `building-from-specs` | 1, PR #271 | Task 2 waits for it. |
| standards: `grep -c -E 'caller\|docs/decisions' plugins/standards/agents/diff-reviewer.md` | 0 | Changes in task 3. |
| standards: `ls plugins/standards/evals \| grep -c '^diff-reviewer-'` | 1 | Two cases are added in task 3. |
| standards: open pull requests | 1, PR #25 | It touches `figure-verifier.md` and `cairn-figure/SKILL.md`, not task 3's files. |

## Commands against the denials log

Read against `~/.local/state/claude-denials.jsonl`, the 30 days to 2026-11-23. No task merges
(`[Merge Without Review]` refused `gh pr merge` on 2026-11-10 and two commands that fed one), and no
task edits a `settings.json` (`[Self-Modification]`, eleven times). `stow -R claude` was refused once
on 2026-11-01; task 2 adds a file inside an existing skill directory, which the skill's one link
already covers, so no restow runs. Every other command is `golangci-lint`, `go tool deadcode`,
`go test`, `make`, `bash scripts/gate.sh`, `claude plugin eval`, `git`, `gh pr create`, and
`gh pr checks --watch`, none refused.

## Before tasks 1 and 3: Geoff's session

1. Land the backlog sweep's edits, below, directly on each default branch.
2. Run the launch checks in `building-from-specs` "Launching a task" for both repos. On 2026-11-23,
   `claude agents --json` listed 7 sessions, 2 of them busy, under the limit of 4 working sessions.
3. Launch tasks 1 and 3 together. They share no repo and no file.

## Task 1: pilot the pattern on dubplate

The task rewrites `CLAUDE.md`, moves its binding rules and `docs/standing-rules.md` into decision
records, and adds the checks. It changes no Go code outside `.golangci.yml` and `scripts/check.sh`.
Each rule ends with one home: the rule and its reason in a record, the steps that carry it out in the
dubplate-build skill, and a pointer from the skill to the record by number.

**`CLAUDE.md`** keeps one sentence on what the repo holds and where the pings Worker lives, then the
ledgers, the `dubplate-build` pointer, the gate, the stack rules, the two facts that are no decision
(failure pings are POST to `/fail`, and the env template's row forms), and the safety rails. It gains
one paragraph that says three things: accepted records in `docs/decisions/` bind every change; before
editing, list the folder and read each accepted record whose title touches the work; a change of mind
is a new record that supersedes the old one. It drops the product pitch, the initiative history and
`_salvage`, the "Reviewers" section, and every rule that becomes a record.

**`docs/decisions/`** holds Nygard records, numbered from 0001, each with a title, `## Status`,
`## Context`, `## Decision`, and `## Consequences`, and no other field. Status is one of `Proposed`,
`Accepted`, `Deprecated`, or `Superseded by NNNN`, where NNNN names a record in the folder. A record
that governs particular packages or paths names them in its decision. Each record's context cites
where the rule came from: Geoff's ruling and its date, a spec's path, or the commit that first wrote
the line (`git log -S`). A consequence names the check that holds the rule, when one does. All 15
are `Accepted`, since each restates a rule already in force.

1. `0001-record-architecture-decisions`: this folder, the statuses, and that an agent treats accepted
   records as binding, proposed ones as context, and superseded ones as history.
2. `0002-exemplary-go` (Geoff, 2026-09-02): the bar, "idiomatic, architecturally beautiful Go". Its
   consequences name the golangci-lint set, the four new checks, and the reviewer's `fix` verdict on
   awkward but working code.
3. `0003-build-for-0-8`: the forward-hooks and prior-art lists, and "nothing is exported ahead of a
   caller", where a caller is production code. Its consequences say the `deadcode -test` leg holds
   the floor (no code or test reaches the export) and review holds the rest.
4. `0004-current-dependencies` (Geoff, 2026-10-04): the policy, keeping its wording that the first
   task of each milestone's first spec runs the sweep, and the libxml2 pin. The bump steps go to the
   skill.
5. `0005-versions`, `0006-words` (including "the group" and "a member"), `0007-refused-features`
   (the group-scale principles).
6. `0008-album-is-the-verdict-unit`, `0009-state-under-var-lib`, `0010-configuration-homes`
   (settings, collections, and no site-specific value, path, or identity default outside
   `internal/config`, held by the import test in `internal/settings`), `0011-table-ownership` (held
   by the store's ownership list), `0012-id-type`, `0013-health-checks-live-with-their-fact`,
   `0014-clock-reaches-packages-as-now` (held by forbidigo), `0015-reject-wording-is-contract`.

**`docs/standing-rules.md`** is deleted. "Build for 0.8" and "Current dependencies" become records 3
and 4. "Gate legs" repeats `scripts/check.sh`'s header and goes, except three parts that move to the
dubplate-build skill's "Gate" section: the workstation prerequisites, the two import-graph tests, and
the process-citation scope. The libxml2 bump steps move there too.

**The dubplate-build skill** points its three `standing-rules.md` references at the records or the
"Gate" section. Its "Conventions" bullets on exports and copy words become one-line pointers to
records 0003 and 0006, and its "Dependency sweep" bullet keeps the steps and cites 0004 for the
policy. The `*.go` reviewer line cites 0002 in place of quoting the bar. "Reviewers by path" takes
`CLAUDE.md`'s "Reviewers" section: no reference screenshots and no visual-fidelity chain (Geoff,
2026-09-24), every user-path page rendered and read, and the `intake` uploader as Geoff's design
review.

**`.golangci.yml`** enables dupl (threshold 150), gocognit (min-complexity 30), and forbidigo with
the two patterns and `analyze-types: true`, as probed. Its exclusions skip `_test.go` for all three,
skip forbidigo's matches under `cmd/`, `tools/`, and `internal/harness/` only when the text matches
`time\.`, and name the 12 complex functions, one rule each with path and function, under a comment
saying the list only shrinks. No other exclusion rule exists.

**`scripts/check.sh`** gains three failing legs, each documented in the header, and each runs in every
form, `--reduced` included: `go tool deadcode -test ./...` prints nothing; `CLAUDE.md` is 200 lines
or fewer; every record carries a `## Status` heading whose next non-blank line is one of the four
statuses, and a `Superseded by NNNN` names a record that exists. The warning leg for `deadcode ./...`
stays.

Done when:

1. `golangci-lint linters -c .golangci.yml` lists `dupl`, `gocognit`, and `forbidigo` under "Enabled
   by your configuration linters". Today it lists none of the three. `grep -c -E 'threshold: 150|min-complexity: 30|analyze-types: true' .golangci.yml`
   prints `3`.
2. `golangci-lint run ./...` exits 0 from the worktree root. In `.golangci.yml`, the exclusion rules
   naming gocognit number 13 (the `_test.go` rule and the 12 functions), each function rule carries
   both `path:` and `text:`, and every forbidigo path rule carries `text: time\.`.
3. Each new check fails on a planted change that is never committed, and the pull request quotes the
   failing line with the leg's name:
   - a function at complexity 31 in `internal/serve`;
   - a block copied inside `internal/serve` and just over dupl's 150-token threshold;
   - `time.Now` in `internal/serve`, and `exec.Command` in `cmd/dubplate-server`;
   - an exported function in `internal/serve` that no code or test calls;
   - a 201-line `CLAUDE.md`, under both `scripts/check.sh` and `scripts/check.sh --reduced`;
   - a record with no status, one with `Approved`, and one with `Superseded by 0099`, under both
     forms.
   A 200-line `CLAUDE.md` passes the length leg.
4. `test -e docs/standing-rules.md` exits 0 today, and 1 after.
5. `git grep -c standing-rules -- CLAUDE.md .claude/` prints two lines today, and nothing after.
6. `ls docs/decisions/` prints nothing today (the folder is absent), and after it prints exactly the
   15 names above, each ending in `.md`. Every record passes the status leg.
7. Each of these prints a count today and nothing after:
   `git grep -c -E '^\*\*(Two standing bars|Words|Versions|Build for 0\.8|Current dependencies)' -- CLAUDE.md`
   (5), and `git grep -c -E` with `'^## (Refused features|Facts agents get wrong|Reviewers)'` (3),
   `_salvage`, `site-specific`, `verdict unit`, `/var/lib/dubplate`, `id\.Parse`, `doctor\.go`,
   `reads the clock`, and `rendered and read`, each against `CLAUDE.md` (1 today, `doctor\.go` 2).
8. `git grep -c -E 'docs/decisions|supersede' -- CLAUDE.md` prints nothing today, and 2 or more after.
9. `git grep -c -i 'screenshot read in the main loop' -- .claude/skills/dubplate-build/SKILL.md`
   prints nothing today, and 1 after. `git grep -c -F` with `No export ahead of a caller`,
   `architecturally beautiful`, and `Copy says` against the same file prints 1 today, and nothing
   after.
10. `bash scripts/gate.sh` passes from the worktree root, and the pull request quotes its
    `gate exit: 0` line.
11. CI's `check` passes. `gh pr checks <n>` lists `check` as `pass`.

The reviewer reads the records for two things the counts can't show: a record that restates code
rather than a decision, and a rule sentence left both in a record and in `CLAUDE.md` or the skill.

Reviewers: `standards:diff-reviewer`. Minutes: 153 (work 60, local gates 29, CI wait 49, review 15),
from task-report's dubplate medians for 2026-10-24 to 2026-11-23. Time clause: 306 minutes. Model:
Opus at medium. Waits for: nothing.

## After task 1: Geoff's session

`docs/STATUS.md` says `docs/decisions/` exists and that `intake-2`'s spec cites the records it builds
on, and stays at 60 lines or fewer. `wc -l < docs/STATUS.md` prints `48` today.

## Task 2: write the pattern into `building-from-specs`

All three files are in `claude/.claude/skills/building-from-specs/`. The task launches after PR #271
merges, and uses its words: a task "builds on" a parent, and a task that builds on nothing runs at
once beside the others.

**`SKILL.md`**, "A session at work", gains two rules. A tidy of code the task touches, such as a
rename, an extracted function, or removed dead code, goes in a separate commit and changes no
behavior (Beck, *Tidy First?*). A refactor larger than that never rides a feature task: it goes to
the backlog through `standards:log-issue` as a task that changes no behavior, and the item names the
failing check or the review finding that calls for it. "Gates and review" gains one step before the
review dispatch: the session runs the built-in `simplify` skill on the commit range the review reads
(`<parent-sha>..HEAD` for a task built on another, else the branch against the default branch), and
`simplify` commits its fixes separately. The opening paragraph gains one line that points at
`references/repo-files.md`.

**`references/writing-a-spec.md`**, at the tasks bullet, says a spec's tasks run setup first, then
the foundation every feature needs, then one phase per feature in priority order (Spec Kit). A task
that builds on nothing is Spec Kit's parallel mark, so no separate mark is added. A new project's
first task is a walking skeleton: the thinnest build that carries one function end to end through
every major part. Among tasks free to go next, the one resting on the least-proven assumption goes
first. A decision that binds later work becomes a record in the repo's `docs/decisions/`, in the task
that first builds on it. Each rule carries its source URL from this spec's table.

**`references/repo-files.md`** is new. It lists the files every repo carries and what each holds,
sized by the repo: `CLAUDE.md` under 200 lines with no overview or history; the README; `BACKLOG.md`;
the gate; `docs/STATUS.md` by pointer to "Records"; and `docs/decisions/`, which appears with its
first record. It says a rule a tool can check becomes a gate check and its prose goes; that a check
adopted on existing code lists each finding as a named exclusion and the list only shrinks; and that
a Go repo takes the four checks task 1 proved (dupl, gocognit, forbidigo, `deadcode -test`). A repo in
another language takes its ecosystem's equivalents, named in that repo's spec. It points at dubplate
as the worked example, and cites the memory guide and the AGENTS.md study for the `CLAUDE.md` rule.

Done when (paths below are relative to `claude/.claude/skills/building-from-specs/`):

1. In `SKILL.md`, `grep -c -F` prints `0` today and 1 or more after for each of `simplify`,
   `Tidy First`, `repo-files.md`, and `log-issue`.
2. `awk '/^## A session at work/,/^## In place of a question/' SKILL.md | grep -c -E 'refactor'`
   prints `0` today, and 1 or more after.
3. `awk '/^## Gates and review/,/^## The pull request/' SKILL.md | grep -n -E 'simplify|diff-reviewer'`
   shows `simplify` on an earlier line than the first `diff-reviewer`, and names `<parent-sha>`.
4. In `references/writing-a-spec.md`, `grep -c -F` prints `0` today and 1 or more after for each of
   `walking skeleton`, `Spec Kit`, `least-proven`, `docs/decisions`, `github.github.com/spec-kit`, and
   `walking-skeleton`.
5. `test -f references/repo-files.md` exits 1 today, and 0 after. In it, `grep -c -F` prints 1 or
   more for each of `200 lines`, `exclusion`, `deadcode -test`, `gocognit`, `dupl`, `forbidigo`,
   `dubplate`, `code.claude.com/docs/en/memory`, and `arxiv.org/abs/2602.11988`.
6. `bash scripts/gate.sh` passes from the worktree root.
7. The pull request says the spec-writing eval's recorded `guideHash` goes stale with this change,
   per backlog #114, and that the rerun waits for #114.

Reviewers: `standards:diff-reviewer`. Minutes: 50 (work 30, local gates 4, review 16), from
task-report's workstation medians. Time clause: 100 minutes. Model: Opus at medium. Waits for: task 1
merged, PR #271 merged, and no other open pull request touching `building-from-specs`.
`gh pr list -R glw907/workstation --state open --json number,files` answers the last. If Geoff closes
#271 unmerged, task 2 uses today's "Waits for" wording and runs `simplify` against the default branch.

## Task 3: teach `standards:diff-reviewer` the two bars

`plugins/standards/agents/diff-reviewer.md`, "The bar", gains two bullets.

- Code more general than the task needs blocks: a new exported name, interface, option, parameter,
  or layer that no code outside its own tests calls, or an interface with one implementation and no
  stated need for a second, unless the criteria ask for it. The bullet quotes Google's "more generic
  than it needs to be".
- When the repo has `docs/decisions/`, the reviewer reads every `Accepted` record there, and a change
  against one blocks, with the record cited as the finding's reason. A `Proposed` record is context,
  and a `Superseded` one is history and binds nothing.

The existing line "A different-but-valid approach is not a finding" stays.

Two eval cases are new under `plugins/standards/evals/`, each with an `agent-dispatched` grader like
`diff-reviewer-unmet-criterion` carries, so a main session that answers without dispatching the
reviewer fails. In each, the planted diff meets its criteria in every other respect.

- `diff-reviewer-unneeded-generality`: a diff adds an interface with one implementation and an
  option nothing reads, and also an interface with two used implementations. Graders pass when the
  verdict is not `accept`, when a blocking finding names the first interface and the option, and
  when no finding flags the second interface.
- `diff-reviewer-breaks-a-record`: a scaffold writes an accepted record and a superseded one into the
  case's working tree, and the brief names neither. The diff breaks the accepted one and departs from
  the superseded one. Graders pass when the verdict is not `accept`, when a blocking finding gives the
  accepted record as its reason, and when no finding treats the superseded record as binding.

The cases are committed before the bar changes. At that commit, the eval command in done item 4 runs
on the two new cases. A case that already scores 0.8 or above shows today's reviewer meets that bar,
so its bullet is not added and the pull request says so.

Done when:

1. In `plugins/standards/agents/diff-reviewer.md`, `grep -c -F` prints `0` today and 1 after for each
   of `generic than it needs to be`, `docs/decisions`, and `Superseded`, unless done item 3 dropped
   that bullet. `grep -c -F 'A different-but-valid approach is not a finding'` prints 1 today and
   after.
2. `ls plugins/standards/evals | grep -c '^diff-reviewer-'` prints `1` today, and `3` after. Each new
   case's grader list includes `agent-dispatched`.
3. On the commit that adds the cases and leaves the agent unchanged, the eval in item 4 with `--case`
   naming each new case scores under 0.8 for it. The pull request quotes both scores.
4. On the final commit this command exits 0 with every case at 0.8 or above, and the pull request
   quotes its scores and cost:
   `claude plugin eval ./plugins/standards --case 'diff-reviewer-*' --runs 6 --ablation none
   --threshold 0.8 --model claude-opus-5-5 --judge-model claude-sonnet-5-5 --scaffold --trust-plugin
   --no-publish -j 1 --max-cost-usd 6 --output-dir plugins/standards/evals/results`. With `--runs 1`
   on today's one case it exited 0, scored 1, and cost 0.19 dollars.
5. CI's `validate` check passes. It checks structure, so items 3 and 4 carry the behavior.

Reviewers: `standards:diff-reviewer`, reading the diff that changes it, from the plugin version
installed at launch. Minutes: 52 (work 20, eval runs 20, CI wait 2, review 10), from task-report's
standards medians and the probe's run time. Time clause: 104 minutes. Model: Opus at medium. Waits for:
nothing; it runs beside task 1.

## After tasks 2 and 3: Geoff's session

After task 2, the session pulls the workstation's main checkout; the skill's link carries the new
file. After task 3, the plugin auto-updates from `main`, and a session restart loads the new
definition.

## Merge order

Tasks 1 and 3 merge in either order. Task 2 merges last.

## Backlog sweep

Scoped sweeps ran on 2026-11-23 on each backlog, for the items that name a file a task changes or
concern its subject. Nothing folds.

| Repo | Item | Verdict | Reason |
| --- | --- | --- | --- |
| dubplate | #88 | reword | Its clause on dead exports is stale: `reject.All` has a caller in `internal/intake/rejectcodes_test.go:184`, `Blocking` is read in `reject_test.go:45`, `staging.ErrLinuxOnly` is used in `staging_other.go`, and `Param` and `Canonical` are gone. `deadcode -test` prints nothing. |
| workstation | #114 | keep | The runner fixes sit outside task 2's files. Task 2's pull request carries the stale `guideHash`. |
| workstation | #115 | keep | A separate spec, waiting on the spec-writing test. |
| workstation | #116 | keep | The "Models" text is untouched by task 2. |
| workstation | #117 | keep | The launch block is outside task 2's lines; land it with #118. |
| workstation | #118 | keep | The fix is a sentence in "Launching a task", which task 2 does not rewrite. |

The reword of #88 drops the clause "the dead exports (`reject.All`, `Reason.Blocking`, `Param`,
`Canonical`, `staging.ErrLinuxOnly`, the `Route` exports) find callers or go" and keeps the rest. Each
`keep` gains ` *(swept 2026-11-23)*`. The standards backlog's one open item, #2, names vale-setup and
is out of scope.

## For Geoff, outside the tasks

- Rolling the pattern out to cairn-cms, phonebook, and the other repos takes one spec each, after
  task 2 merges.
- dubplate's 12 complex functions and its 241 warnings from `deadcode ./...` stay. A refactor task
  for either comes from a failing check or a review finding, under the rule task 2 adds.
- Fable is at its usage limit until 2026-11-27 at 11 p.m. Alaska time, so the three tasks and this
  spec's fresh reader run on Opus.

## Calls Claude made

- This spec was written on Opus 5.5, not Fable, in the session that ran the design discussion.
- The pattern drops the JSON feature list, computed dependency links, the per-document trigger
  table, and an architecture read at each milestone's end, as not mainstream.
- Existing complexity findings are listed as named exclusions rather than run through
  `--new-from-merge-base`, so the check reads the same on a branch, on `master`, and in CI's shallow
  checkout.
- The clock ban exempts `cmd/` and `tools/`, which wire `time.Now` into packages, and
  `internal/harness/`, which `CLAUDE.md` already exempts.
- The decisions record set is 15, one per binding rule in the current `CLAUDE.md` and
  `docs/standing-rules.md`. The two operational facts stay in `CLAUDE.md`, since they are no decision.
- The accepted-records check lives in the reviewer agent, not in the task brief, so it has one home.
- Task 3 runs beside task 1, because it shares no repo or file and its eval writes the records it needs.
- Each task builds on Opus at medium, since each writes rules other agents follow.
- Records carry no field for the code they cover, since Nygard's format has none. An agent lists the
  folder and reads the records whose titles touch its work. The reviewer reads every accepted record,
  which at 15 short files costs little.
- Record 0003 keeps "production caller" as the rule. `deadcode -test` holds only the floor, since it
  counts a test as a caller, and the reviewer holds the rest.
- The rule "one milestone is one spec" was dropped. Spec Kit's unit is a feature, not a milestone, and
  dubplate's dependency record says a milestone can hold several specs.
- Task 2 uses PR #271's "builds on" in place of a separate parallel mark, so the skill keeps one way to
  say which tasks run side by side.
- `CLAUDE.md`'s "Reviewers" section moves to the dubplate-build skill as procedure, not a record, so
  the count stays at 15.
- Task 3 commits its eval cases before the bar changes, so each bullet earns its place by failing
  today's reviewer first.
