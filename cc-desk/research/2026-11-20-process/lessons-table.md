# The lessons table the process spec owes

Draft. One line for every data row in
`/var/home/glw907/Projects/cc-desk/docs/follow-ups/desk-round-lessons.md` (rows on lines 11 to
38, 28 rows). The process spec owes this table: `docs/specs/2026-11-20-process-decisions.md:130-132`.
Row numbers below count the data rows in file order; "L" gives the line in that file.

Short names for sources:

- `lessons` = `cc-desk/docs/follow-ups/desk-round-lessons.md`
- `decisions` = `cc-desk/docs/specs/2026-11-20-process-decisions.md`
- `core` = `cc-desk/docs/specs/2026-11-20-core-design.md`
- `fable` = `~/Projects/initiatives/cc-desk/reports/desk-failure-review.md`
- `pricing` = `cc-desk/docs/follow-ups/round-estimates-priced-from-evidence.md`
- `leftover` = `cc-desk/docs/follow-ups/leftover-live-session-parks-a-pass.md`

## How the labels are set

A label is set only from what the files say. Where the files cite no docs page for a piece, the
label says so, and the spec must read the page before it keeps the label
(`decisions:151-154` asks a session that leans on a page to read it again).

| Piece the answers use | Label | What the files say |
| --- | --- | --- |
| A fresh session builds from the spec under `/goal`; a subagent reviews the diff against the spec | Documented | `core:614` cites the best-practices page and the `/goal` page |
| `/goal` inside a `claude --bg` session; a `dontAsk` session that meets a refused command carries on and ends `done` | Probed, not cited | `decisions:62-64` records two probes on 2.1.329. No docs quote for `--bg` or `dontAsk` is in the files |
| `permissions.denyInsteadOfPrompting` | Documented | `core:523` |
| A `PreToolUse` hook; `onFailure: block`; `async` | Documented | `core:608`, `core:610` |
| Deny rules | Documented | `core:607`, `core:609`. A deny rule "isn't a security boundary" (`core:262-265`) |
| The timer script that starts free tasks, with the branch-from-parent rule | Assembled | Bash and systemd are Geoff's chosen pieces (`decisions:40-42`, `decisions:55-56`). The dependency logic is ours |
| A cap that ends a session and asks nothing | Not stated | `decisions:104` decides the behaviour. No file names the mechanism that ends the session |
| The page that only reads files, and its four groups | Assembled for the page, invented for the groups | `decisions:45-46`, `decisions:123-124`. `core:524-525`: a list of refused steps held for Geoff "would be new" and is labelled invented |
| `claude agents --json`, `claude-worktree-busy` | Not stated | Named in `lessons:27`, `lessons:34` and the global `CLAUDE.md`. No docs page is cited |

Status of the four groups: `decisions:123-124` lists them as proposed. The user request relayed
into this run says "And those four groups look correct." The spec should record that ruling with
its date.

## The table

"Cause now" says whether the row's cause survives the new process. "Gone (X)" names what left with
it: the conductor, the plan, the forecast comparison, the queue document, or the Go.

| # | L | Stop, in six words | Cause now | Tool side | Text side (sentence the process skill carries) | Label |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 11 | Pass 2 parks on its estimate | Gone (forecast comparison, plan). No plan path is compared with an estimate. | Timer script applies the cap from measured minutes: no new task past twice its planned minutes (`decisions:121`, proposed). | "A task never stops for its size. A cap ends it from measured minutes, and the session writes what is left." | Behaviour decided (`decisions:104`); cap mechanism not stated |
| 2 | 12 | Review escalates, next pass waits behind | Gone (queue document, conductor's landing test, plan's override line). The risk that a spec orders a task behind a merge is still present. | Timer script starts a dependent from its parent's branch (decided). The page sorts the result into a group. | "A task that builds on another starts from that task's branch once its pull request is open. A spec never makes a task wait for a merge." and "The review sorts a result by what it found, never by a verdict word: green checks, no open gap that affects correctness, and no call for Geoff put it under Ready to merge." | Assembled (timer); invented (groups) |
| 3 | 13 | Pass 3 parks on its estimate | Gone, as row 1. | As row 1. | As row 1. | As row 1 |
| 4 | 14 | Overnight park on a failing proviso | Gone (conductor; no mid-gap question exists, `decisions:100`). Still present: a stop condition can be foreseen and still end work overnight. The new process names no clock cutoff, only the minute and usage caps (`decisions:121-122`). | Not answered. What would answer it: at each sitting, the session Geoff talks to reads the forecast (kept, `decisions:47`) against each cap and tells him which tasks a cap will end before his next sitting, so he can raise it then. | "A session never waits for a ruling. When a rule's condition fails, the session ends, names the condition, and says what is left." and "At each sitting, the forecast is read against every cap, and any cap that will end work before the next sitting is shown to Geoff then." | Assembled (forecast is Claude Code's, `decisions:47`); the check against caps is invented |
| 5 | 15 | Leftover live session blocks a run | Gone (Go: the check and its live scripts; conductor's watch). Still present: a task whose tests start sessions can leave one running. | Timer script records every session it starts. The page lists sessions no record names (`fable:57`). Hooks record each session's end. | "A session that starts other sessions stops each one before it ends, pass or fail. A session it can't trace to its own run it leaves alone and names in its report." | Hooks documented; ownership record assembled |
| 6 | 16 | Own test sessions block the run | Gone (Go live script; relaunch prompt). Still present in kind, as row 5. | As row 5. | As row 5. | As row 5 |
| 7 | 17 | Finished session idles waiting on CI | Gone (conductor, relaunch). Still present: a session can sit after its work is done, and the page would read it as working. Who reads CI after a session ends is not stated. | A hook records the session's end and its report; the page shows a task by its recorded state, and flags a session idle past a set time. `dontAsk` or `denyInsteadOfPrompting` keeps a session from blocking on a prompt (the 4 h blocked executor). | "When the work is done or a cap is reached, the session writes its report and ends in the same turn. If the goal needs green CI, it waits on CI before the report, never after." | Hooks and `denyInsteadOfPrompting` documented; idle flag invented |
| 8 | 18 | Goal line changed to fit result | Gone in part (plan, 350-minute stop, conductor). Still present: a session can change a criterion or a test to match what it built, and a review can cite a stale commit. | A check (in the Stop-time report step or the timer script) compares the review's commit with the pull request head and moves a mismatch to Read before merging. | "The goal is fixed for the run. A session that finds a goal line wrong doesn't edit the goal or a test to match. It applies the finding to every path that shares the rule, names the line in its report, and the pull request goes under Read before merging." and "The review names the commit it read. A product commit after it needs a new review before the session ends." | Review documented; commit check assembled |
| 9 | 19 | Conductor's question blocks watched review | Gone (conductor). | `dontAsk` mode (probed, `decisions:62-64`) or `denyInsteadOfPrompting` (documented, `core:523`). A deny rule on the question tool would close the text route; the files don't say whether that is documented. | "A session never asks Geoff a question. It decides, records the call in its report, and goes on." | Documented for prompts; the question-tool deny is not stated |
| 10 | 20 | Evidence cited from wrong window | Gone (Go live script; queue body tags and `## Score`). Still present: evidence that doesn't prove the goal line it cites. | The reviewer checks each goal line's evidence (documented review). The report template holds evidence as fields (row 21). | "Every claim that something works, in a report or a closed follow-up, quotes the check that proves it, run on the final commit, in the environment where it will run, inside the window the claim names." | Documented (review); template assembled |
| 11 | 21 | Test runs fill the real state | Gone (Go state folder and its releases). Still present in kind: a task's tests could write into the files the page reads. | The page reads one named folder; tests write elsewhere. | "A task's tests never write to the folders the page reads. A task that must touch a real account removes what its runs added before it ends and lists what it couldn't remove." | Assembled |
| 12 | 22 | Tooling sync re-escapes the manifest | Still present. `claude-tooling-sync` on `origin/main` writes the manifest with `json.dump(manifest, f, indent=2)` (line 494) and `settings.json` with `json.dumps(merged, indent=2)` (line 137), both without `ensure_ascii=False`. | Not answered by the new process. It is a bug in a dotfiles tool. What answers it: `ensure_ascii=False` at those two lines, landed as a direct change. | None needed. | Not a process mechanism |
| 13 | 23 | Live-run task priced from outline | Gone (forecast comparison; the Go's check period and idle rule). Still present: any task that drives slow mechanisms (CI, timers) can be priced low. Estimates are to be "priced from measured minutes" (`decisions:134`); where those minutes come from is not stated. | Hooks record start and end times per session, so measured minutes exist to price from. | "A task's estimate comes from the measured minutes of like tasks plus the waits of everything it drives (CI, timers, idle limits), never from an outline." | Hooks documented; pricing assembled |
| 14 | 24 | Conductor writes in a live worktree | Gone (conductor, planner). Still present in kind: the session Geoff talks to runs merges and could touch a branch whose session is live. | `claude-worktree-busy` before any write (global `CLAUDE.md`, "One executor per worktree"). The merge step reads the task's recorded end state first. | "Only a task's own session writes on its branch while it runs. The session Geoff talks to merges a branch only after that task's session has ended." | Assembled |
| 15 | 25 | Private repo's CI hits billing | Still present. Nothing in the new process as described reads a repo's visibility or CI billing. The pre-run step exists only for secrets (`decisions:106`). | Not answered. What would answer it: the timer script, before a spec's first task, checks `gh repo view --json visibility` for each repo whose CI a task needs and records a refusal on the page. | "Before a spec's run starts, each repo whose CI a task needs is confirmed able to run CI, alongside gathering the secrets. A CI run that starts no job is read from its annotation, never fixed as a failing test." | Assembled |
| 16 | 26 | Spec reaches launch missing a field | Gone (plan, planner, `claude-launch-guard`'s plan checks, `core:517`). Still present in kind: the timer script will read fields from the spec. | A spec check the timer script runs, refusing a spec with a missing field and writing why to the page. | "A spec carries every field the timer script reads, and the spec check runs before Geoff approves it." | Assembled |
| 17 | 27 | Start condition refuses its own launch | Gone (Move start line, conductor). Still present: a busy check can hit a session the run itself means to stop, and wait forever. | The timer script writes what each task waits on to a file the page reads, so a start that can never fire is visible at the sitting. | "A spec's start conditions are tested against the day's live sessions before approval." | Assembled |
| 18 | 28 | Spec overtaken by another repo's work | Gone in part (no conductor owns a project). Still present: a spec that moves another repo's work can be overtaken by sessions there. | The page lists live sessions per repo. | "A spec that changes another repo's work names the sessions working there and reads that repo's STATUS on the day it is approved." | Assembled |
| 19 | 29 | API key bills the empty account | Gone (Go `cc-desk` binary and the desk). Still present: the timer script starts `claude`; if its environment ever holds `ANTHROPIC_API_KEY` (for example from sourcing `~/.local/secrets` to gather secrets), every session bills the key. The systemd unit's environment is not stated. | Timer script starts each session with `ANTHROPIC_API_KEY` unset. | "A step Geoff will run is rehearsed from his login shell (`bash -lic`), never a job's shell." | Assembled |
| 20 | 30 | Terminal link fixed only by belief | Gone (Go handler). Whether the new page keeps an "open in a terminal" link is not stated. Still present: a claim closed without proof. | None. | As row 10 (merged sentence). | Assembled |
| 21 | 31 | Two report bodies sent back | Gone (queue document, `pass ready`, conductor reading prose). Still present in kind: the page sorts reports into four groups, so a report's shape matters. The report format is not stated. | A Stop-time check refuses to end a session whose report is missing a field (a Stop hook would be the documented piece; the files don't cite one). | "Every task ends with one report in the template. Its group is a field the page reads, not prose." | Assembled if a Stop hook is documented; not stated in the files |
| 22 | 32 | Live waits left out of price | Gone, as row 13. The proposed planner flag at twice the figure would bring back a size stop, so it is dropped. | As row 13. | As row 13. | As row 13 |
| 23 | 33 | Spec names a blocked fixture command | Gone in part (the fixture tested the Go). Still present: a spec or step can name a command Claude Code blocks. | None beyond the session's own run. | "A spec names no command for a session to run until it has been run once in Claude Code." | Assembled |
| 24 | 34 | Stale branch blocks the next launch | Gone (Go `internal/launch/worktree.go`, conductor, relaunch counting). Still present: the timer script makes branches and worktrees, and a branch left from a failed start would refuse the next one. | Timer script gives each start a fresh branch name, or deletes a branch whose tip `origin/main` already holds; a start that fails on something the script left is cleaned and tried again. | "A task's last act is its report; nothing it leaves behind may stop the next start." | Assembled |
| 25 | 35 | Live session found by name search | Gone (conductor). Still present: the timer script must know whether a task's session is live. How it knows is not stated. | Timer script reads the record it wrote at launch (session id, worktree), never a search by name or model flag. | "Whether a session is running is read from the record written at its launch, never from a search by name." | Assembled |
| 26 | 36 | Design defends Go against constraint | Gone (Go deleted, `decisions:58`). Still present: any design session can test only its additions against a constraint. | None. | "A design session that hears a constraint from Geoff tests what already exists against it and shows him the result before it designs additions. A concern he repeats hasn't been answered, so the session stops designing and asks what it missed." | Invented (a house rule; no docs page) |
| 27 | 37 | Undocumented mechanism proposed before docs | Answered by Geoff's ruling (`decisions:43-44`). Still present as a habit to guard. | None. | "A design session reads Anthropic's docs page for a mechanism before it proposes one, and labels each option documented, assembled, or invented." | Invented (Geoff's rule) |
| 28 | 38 | Replacement planned under the old process | Gone once the old skills are deleted. Not landed yet: dotfiles PR 253 ("Exempt cc-desk's spec work from the pass process") is still OPEN, and the global `CLAUDE.md` on `origin/main` carries no exemption. | None. | "A session designing a replacement for a process asks, before it plans, whether that process should govern the build." | Invented |

## Gaps the rows expose

The new process as described in `decisions` leaves these open. Each touches more than one row.

1. **Who reads CI after a session ends.** Not stated. "Ready to merge" needs green checks, and the
   page only reads files. Rows 2, 7, 15.
2. **Whether a task session folds the review's findings or only reports them.** Not stated. It
   decides whether a result lands in "Ready to merge" or "Read before merging". Rows 2, 8, 10.
3. **How a cap ends a session.** `decisions:104` decides the behaviour; no file names the
   mechanism. Rows 1, 3, 4, 13, 22.
4. **When a dependent may start.** "Branches from that task's branch" is decided. Whether that
   means once the pull request opens, once the session ends, or once the review passes is not
   stated. Nor is what a dependent does when its parent lands in "Couldn't finish". Rows 2, 4, 7.
5. **Where measured minutes come from.** `decisions:134` needs them; the source is not stated.
   Rows 13, 22.
6. **How the timer script knows a session is live.** Not stated. The old answers lean on
   `claude agents --json` (`lessons:27`, `lessons:34`), which no file ties to a docs page. Rows 5,
   17, 24, 25.
7. **The merge path.** `claude-merge-guard` refuses `gh pr merge` and points sessions at
   `approval-queue` (`core:231-234`); `core:515-516` leaves its text and rename to this spec. The
   session Geoff talks to cannot run merges until that changes. Rows 2, 14.
8. **The timer's environment.** Whether the systemd unit sees `ANTHROPIC_API_KEY` is not stated.
   Row 19.

## Rows grouped by what answers them

- **Timer script:** 1, 2, 3, 4 (with the sitting check), 5, 6, 15, 16, 17, 19, 24, 25.
- **Hooks:** 5, 6, 7, 13, 21, 22.
- **Permission rules and mode:** 7 (the blocked executor), 9.
- **The page:** 2, 4, 5, 6, 7, 8, 11, 17, 18.
- **The review step:** 2, 8, 10.
- **Process text only:** 10, 14, 18, 20, 23, 26, 27, 28.
- **Not answered by the new process:** 4 (the overnight cap; needs the sitting check above), 12 (a
  dotfiles tool bug; needs `ensure_ascii=False`), 15 (no CI-visibility check; needs a pre-run
  check).
- **Cause gone with the conductor:** 4, 5, 7, 9, 14, 17, 18, 24, 25.
- **Cause gone with the plan or the forecast comparison:** 1, 3, 13, 16, 22.
- **Cause gone with the queue document or `pass ready`:** 2, 10, 21.
- **Cause gone with the Go:** 5, 6, 10, 11, 19, 20, 23, 24, 26.

## Sentences the process skill would carry

Duplicates merged. The rows each answers are in brackets.

1. A task never stops for its size. A cap ends it from measured minutes, and the session writes what is left. [1, 3, 22]
2. A task's estimate comes from the measured minutes of like tasks plus the waits of everything it drives (CI, timers, idle limits), never from an outline. [13, 22]
3. A task that builds on another starts from that task's branch once its pull request is open. A spec never makes a task wait for a merge. [2]
4. The review sorts a result by what it found, never by a verdict word: green checks, no open gap that affects correctness, and no call for Geoff put it under Ready to merge. [2]
5. A session never asks Geoff a question and never waits for a ruling. It decides, records the call in its report, and goes on. [4, 9]
6. When a rule's condition fails, the session ends, names the condition, and says what is left. [4]
7. At each sitting, the forecast is read against every cap, and any cap that will end work before the next sitting is shown to Geoff then. [4]
8. A session that starts other sessions stops each one before it ends, pass or fail. A session it can't trace to its own run it leaves alone and names in its report. [5, 6]
9. When the work is done or a cap is reached, the session writes its report and ends in the same turn. If the goal needs green CI, it waits on CI before the report, never after. [7, 24]
10. The goal is fixed for the run. A session that finds a goal line wrong doesn't edit the goal or a test to match. It applies the finding to every path that shares the rule, names the line in its report, and the pull request goes under Read before merging. [8]
11. The review names the commit it read. A product commit after it needs a new review before the session ends. [8]
12. Every claim that something works, in a report or a closed follow-up, quotes the check that proves it, run on the final commit, in the environment where it will run, inside the window the claim names. [10, 20]
13. A task's tests never write to the folders the page reads. A task that must touch a real account removes what its runs added before it ends and lists what it couldn't remove. [11]
14. Only a task's own session writes on its branch while it runs. The session Geoff talks to merges a branch only after that task's session has ended. [14]
15. Before a spec's run starts, each repo whose CI a task needs is confirmed able to run CI, alongside gathering the secrets. A CI run that starts no job is read from its annotation, never fixed as a failing test. [15]
16. A spec carries every field the timer script reads, and the spec check runs before Geoff approves it. [16]
17. A spec's start conditions are tested against the day's live sessions before approval. [17]
18. A spec that changes another repo's work names the sessions working there and reads that repo's STATUS on the day it is approved. [18]
19. A step Geoff will run is rehearsed from his login shell (`bash -lic`), never a job's shell. [19]
20. Every task ends with one report in the template. Its group is a field the page reads, not prose. [21]
21. A spec names no command for a session to run until it has been run once in Claude Code. [23]
22. Whether a session is running is read from the record written at its launch, never from a search by name. [25]
23. A design session that hears a constraint from Geoff tests what already exists against it and shows him the result before it designs additions. A concern he repeats hasn't been answered, so the session stops designing and asks what it missed. [26]
24. A design session reads Anthropic's docs page for a mechanism before it proposes one, and labels each option documented, assembled, or invented. [27]
25. A session designing a replacement for a process asks, before it plans, whether that process should govern the build. [28]

Sentences 23 to 25 govern design sessions, when Geoff is present. The rest govern task sessions
and the timer script.
