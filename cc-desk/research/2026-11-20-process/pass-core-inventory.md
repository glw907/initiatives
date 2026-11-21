# pass-core inventory for the new process skill

Read on 2026-11-20, as files only. Every reference below is relative to
`/var/home/glw907/.claude/skills/pass-core/`: `SKILL.md`, or a file under `references/`
(`advisor.md`, `conductor.md`, `desk.md`, `executor.md`, `planner.md`, `planning-samples.md`,
`ready.md`, `round.md`, `round-run.md`). 1,082 lines in all. "decisions" means
`/var/home/glw907/Projects/cc-desk/docs/specs/2026-11-20-process-decisions.md`.

Fates:

- **GOES**: serves the old machinery (conductor, planner, plan, pre-flight list, score, queue
  document, estimate comparison, desk).
- **CARRIES**: states something Geoff wants from the work itself. The sentence goes into the new
  skill, often reshaped.
- **CONTROL**: better held by a permission rule, a hook, a script, or agent frontmatter. The
  mechanism is named and labelled documented (a Claude Code docs page), assembled, or invented.

Where a "why" cell says "not stated", the file gives no reason.

## Headline findings

1. About two thirds of the 1,082 lines are GOES. All of `conductor.md` (56), `desk.md` (153),
   and nearly all of `round-run.md` "Order table", "Queue rules", "Report" STATUS copy, "Clock",
   "Resuming", both "Miss tags" tables, "Score", "Pre-flight", "Launch", and "The conductor's
   open case" serve the conductor, the planner, the queue, or the score.
2. The CARRIES core is small and clusters in six places: `advisor.md` "What the answer allows"
   (L46-55) and "Acceptance items" (L62-82), `round.md` "Design rules" (L46-68) and "Planner
   rules" (L70-84), `SKILL.md` "Close" (L125-151), and `round-run.md` "Evidence" (L102-113) and
   "Report" parts 1 to 5 (L128-135). The merged list at the end is 34 items in 93 lines of rule
   text plus 6 headings.
3. Most CONTROL items are already half-built as scripts or hooks that exist today:
   `claude-merge-guard` is a PreToolUse hook (`/var/home/glw907/.claude/settings.json:233`),
   `claude-denied-log` is a PermissionDenied hook (`settings.json:194-203`), and
   `cairn-run-gate`, `claude-worktree-busy`, and `round-watch` are in `~/.local/bin`. The timer
   script inherits almost all of `round-run.md` "The order table" (L43-61) as code, including
   the rule decided for the new process: a task branches from its parent's branch when the
   parent is unmerged (`round-run.md:56-58`).
4. Of the 12 standing answers, 2 CARRY (2, 12), 1 CARRIES with a CONTROL (3), 5 become CONTROL
   in the timer script (4, 5, 6, 7, 11), and 4 GO (1, 8, 9, 10). Their replacement for "What
   always stops" is the decided five-stops table (decisions L98-108).
5. Three rules exist only because of the queue and must be re-decided, not carried: "every PR's
   base is the default branch" (`executor.md:24-25`, `round.md:102-103`, `round-run.md:80`),
   "a PR with no call lands" (`SKILL.md:28`, `SKILL.md:133`), and "a pass waiting for a close
   packet holds every later landing" (`round.md:35-37`, `advisor.md:104-107`). The first two
   conflict with decided lines: tasks branch from unmerged parents, and no session merges
   without Geoff (decisions L59-60).
6. The files leave several things unstated that the new spec must settle. These are method
   calls, so they are Claude's (global CLAUDE.md "Process proportionality"): the PR base for a
   task stacked on an unmerged parent; what happens to dependents when Geoff overturns a flagged
   choice at his sitting (the old answer is `advisor.md:115-119`, a conductor relaunch); how
   Geoff sends a PR back (old: `round-run.md:84-85`, a `## Rulings` line and relaunch); and
   whether a task session writes STATUS at all.

## SKILL.md (180 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 1-6 | Frontmatter: name and trigger. | Not stated. | GOES (new skill gets its own) |
| 10-12 | The repo adapter supplies gate, lanes, CI watch, worktree setup, path map, close checklist, and wins on conflict. | Not stated. | CARRIES as "the repo names its gate and close checklist"; the adapter skills are outside this inventory |
| 14-16 | Load `standards:running-passes`, then a role reference. | Not stated. | GOES |
| 18-22 | "Until cc-desk runs" overrides every line that sends Geoff a document. | Geoff stopped reading the queue and the desk on 2026-11-17 (L20). | GOES |
| 24-25 | Rule 1: a question or report is written in his terminal session; nothing runs `approval-queue send`. | Same. | GOES |
| 26-27 | Rule 2: a background session writes its report, or a stopping question, under "Open decisions" in STATUS with a recommendation, then ends. | Same. | CARRIES reshaped: what is left, with a recommendation, then end. The STATUS location GOES (the page reads files) |
| 28 | Rule 3: a PR with no call lands per `approval-packet` step 1. | Same. | GOES. Conflicts with decisions L59-60 |
| 29-32 | Rule 4: a PR needing approval waits; once his terminal message approves it by number, that session runs `## Before merge` steps and check, removes the section, lands with `approval-queue land`, withdraws any queue document. | Same. | CARRIES (he approves in words, the session he talks to merges, Before-merge runs first). `approval-queue land` GOES |
| 34-38 | Every design is a round of one to six passes; planner and conductor reading lists. | Not stated. | GOES |
| 40-41 | Step 1 Design: Opus at `high` brainstorms; one-sentence diff skips steps 2 to 4. | Not stated. | CARRIES the model line (see Models); the skip is "Direct changes" |
| 42-43 | Step 2 Spec, with every mechanism quoted from source or probed. | Not stated. | CARRIES (matches decisions L43-44, every mechanism labelled) |
| 43-46 | Step 3 Review by class; a finding that changes the approved design goes back to Geoff as one batched question at the sitting, or through the advisor when unattended. | Not stated. | CARRIES (batched question at the sitting). The advisor branch GOES |
| 47 | Step 4 Plan, opening with `## Pre-flight`. | Not stated. | GOES |
| 48-49 | Steps 5, 6: pointers. | - | GOES |
| 51-59 | Review by class: `ordinary` none before code; `runner` and `auth-data` one plan-reviewer read before code. At close one whole-branch `standards:diff-reviewer`, plus `standards:web-auth-security-reviewer` for `auth-data`. | Not stated. | Before-code column GOES (no plan). At-close column CARRIES |
| 61 | No review runs on a commit while CI runs. | Not stated. | CARRIES (low weight; cut first) |
| 63-71 | Direct changes: lands on the default branch with no design, PR, review, or packet when the request fully specifies it, the diff fits one sentence, no `auth-data` path, no new public surface, and a `runner` path changes wording only. | Geoff, 2026-10-17 (L66). Global CLAUDE.md "Process proportionality" points here. | CARRIES |
| 73-75 | At his request naming the command, one `permissions.allow` rule for a gate or test command; the reply quotes it. A second rule, an `autoMode` entry, or a deny change is full work. | Not stated. | CARRIES; also CONTROL: settings writes are refused by permission rules (documented: permissions page, per decisions L151-153) |
| 77-82 | Run the gate, commit named files, push to default; if another session is live in the main checkout, commit in a worktree cut from `origin/<default>` and push `HEAD:<default>`. Where a push deploys, full-page render read of each touched page. A finding past one sentence makes it full work. | Not stated. | CARRIES |
| 86-87 | Design authorship `claude-opus-5-5` at `high`; other Opus work, reviewers too, at `medium`; reviewers take model from frontmatter. | Not stated. | CONTROL for reviewers (agent frontmatter, documented); CARRIES for spec authorship |
| 88-89 | Conductor, executor, pairs: `sonnet` at `medium`, or Opus where judgment; a red traced to executor reasoning moves the next pass to `high`. | Not stated. | CONTROL: the timer script's `claude --bg --model --effort` line (assembled). The "red moves to high" rule GOES with the score |
| 90-92 | `xhigh`/`max` only where a gain is measured; unsettled decision re-runs at `xhigh` then one `fable` dispatch; `haiku` reads, never decides; `low` for mechanical subagents, never Fable. | Not stated. | CARRIES (short); cut first |
| 94-97 | One session executes, named `<project>-<pass>`; a relaunch keeps the name. | Geoff, 2026-10-12 (L97). | CONTROL: the timer script passes `--name` (documented flag of `claude --bg`, assembled) |
| 99-103 | A session goes on past an open question, takes the advisor's choice, lists it for Geoff at close; stops only for "What always stops". | Geoff, 2026-11-14 (L102). | CARRIES (the core of the new test). The stop list is replaced by decisions L98-108 |
| 105-107 | A mid-run question to Geoff is a planning miss in `## Planning misses`; fix waits for the monthly prune. | Not stated. | GOES (no mid-run questions exist now) |
| 107-109 | A question first goes through the advisor; under a conductor the executor writes a stop and ends; the conductor sends a `decide` document. | Not stated. | GOES |
| 111-113 | Pairs: pointer to executor reference. | Memory `pairs-by-default.md`: Geoff, 2026-10-10, serial execution wastes clock on an idle machine. | GOES as a process rule: the timer starting every free task serves the same reason. Whether steps inside a task still pair is a method call |
| 115-118 | Gates run through `cairn-run-gate`; CI carries whole suites off the critical path. | Not stated. | CARRIES (gate must pass, CI carries the suites); CONTROL: `cairn-run-gate` (existing script, assembled) |
| 120-123 | A round of two or more passes has a conductor. | Not stated. | GOES (decisions L78) |
| 127-128 | Close: `running-passes` "Close"; `standards:visual-verifier` on rendered UI in a site or cairn admin; adapter close checklist; STATUS updated. | Not stated. | CARRIES (visual verifier, close checklist). STATUS update: unstated in the new process |
| 128-130 | PR body opens with a paragraph per `written-for-people.md`, then what landed, each `auth-data` verdict, `## Decisions`, `## Planning misses`, and the score. | Not stated. | CARRIES the paragraph, what landed, `auth-data` verdict, Decisions. Planning misses and score GO |
| 130-131 | Follow-ups through `approval-packet` step 7. | Not stated. | GOES (L169-170 already names `standards:log-issue`) |
| 133 | The hand-over is `approval-packet`; its step 1 says when a pass sends nothing and lands; an adapter line saying every PR waits yields to it. | Not stated. | GOES. Conflicts with decisions L59-60 |
| 135-136 | A PR merges only once checks are green and the whole-branch review is accepted with no open finding, by `approval-queue land`. | Not stated. | CARRIES the condition. `approval-queue land` GOES |
| 136-137 | `claude-merge-guard` denies every GitHub CLI merge stage. | Not stated. | CONTROL: PreToolUse hook, exists (`settings.json:233`), documented mechanism. Needs a carve-out for the session Geoff talks to |
| 139-141 | A PR is safe under plain merge then pull; else `## Before merge` with exact commands in order and the one check; the merging session runs both. | Not stated. | CARRIES |
| 143-146 | The merger pulls the main checkout `--ff-only` only when on default, no uncommitted change in a merged file, no live session; else reports stale and never forces. | Not stated. | CARRIES; better CONTROL in a merge script (assembled) |
| 148-151 | Then removes the worktree and branch with no force; dirty, unmerged, or live leaves it with one report line. An executor that merges its own PR leaves via `ExitWorktree`. | Not stated. | CARRIES (cleanup, never force); better CONTROL in the same script. The self-merge clause GOES |
| 153-155 | Score: pointer. | - | GOES |
| 159-161 | STATUS is present tense, 60 lines or fewer: state, next action, open decisions. Initiatives via `/log-project`, backlog `BACKLOG.md`. A cited commit id survives a merge. Git and PR bodies are the history. | Not stated. | CARRIES |
| 163-165 | A hand-over (STATUS, launch prompt, research records) takes no PR and no packet; gate, then commit to default as a direct change. | Geoff, 2026-10-11 and 2026-10-31 (L164). | CARRIES |
| 169-170 | A grant authorizes a mechanism or boundary, never more work. Work found mid-task is filed through `standards:log-issue` and listed in the PR body. | Not stated. | CARRIES |
| 174-175 | A launch prompt lives in a committed file, launched as `"$(cat <file>)"`. | Not stated. | CONTROL: the timer script reads the task's committed goal file (assembled) |
| 179-180 | Pre-flight holds every Geoff-only step and permission. | Not stated. | GOES as a list. The surviving rule is decided: secrets gathered before the run (decisions L106) |

## advisor.md (146 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 3-5 | Read on a question the plan, design, and standing answers don't settle; only "What always stops" holds a pass. | Geoff, 2026-11-14 (L4-5). | CARRIES (go on, flag at close) |
| 5-7 | The advisor is Claude Code's advisor tool, a Fable reader of the transcript with no tools. | Docs URL cited (L6). | Documented. Whether task sessions keep it is a method call; one line at most |
| 7-9 | A parked pass parks every pass on it, so consult on every open question. | Geoff, 2026-11-12 (L8-9). | CARRIES the aim (decide rather than stop); the parking chain GOES |
| 13-16 | Who launches with `--advisor fable`; the conductor without. | Long transcript cost (L15-16). | CONTROL (launch line in timer script) or GOES |
| 18-21 | Claude Code drops the advisor from a background session with no error; fall back to one Fable Agent call. | Observed behavior, undated (L18). | CONTROL if kept: the timer script or a SessionStart check. Else GOES |
| 25-27 | Before a choice, read Geoff's rulings: plan `## Rulings`, design, earlier PRs' `## Decisions` and `## Calls for Geoff`, any dated rule naming the subject. | Not stated. | CARRIES |
| 28-29 | Write the question, what you tried, the choices; call the advisor once per question. | Not stated. | GOES with the advisor; the "what you tried, choices" shape CARRIES in the "couldn't finish" note |
| 31-33 | The session never answers itself; an `[advisor]` line reports only a real tool or dispatch return; a dispatch prompt quotes each ruling. | Not stated. | CARRIES the honesty rule if the advisor stays; else GOES |
| 33-36 | An advisor-answered question is no planning miss; an unmet acceptance check is one. | Not stated. | GOES |
| 38-41 | Planner writes `[advisor]` lines under `## Decisions`, marks `Call:`; executor copies them to `## Calls for Geoff` and counts `Calls:`. A task left after a second auto-mode refusal is a line there and counts. | Not stated. | CARRIES reshaped: every choice Geoff must see goes under one PR heading; a refused step is listed. `Calls:` count becomes what the page sorts on (CONTROL, page reads PR body) |
| 43-44 | An `[advisor]` line in an earlier PR is never a ruling; Geoff hasn't read it. | Stated in line. | CARRIES |
| 50 | Row 1: a ruling, the design, or a standing answer settles it: go on, record under `## Decisions` opening `[advisor]` and quoting the source. | Not stated. | CARRIES |
| 51 | Row 2: method or architecture call: take the choice, record it. | Global CLAUDE.md: method and architecture are Claude's (2026-09-24, 09-26). | CARRIES |
| 52 | Row 3: product, taste, or priority call with no precedent: take the choice, go on, raise under `## Calls for Geoff` with option taken, option passed over, and what reversing undoes. | Geoff, 2026-11-12, then default for all 2026-11-14 (L57-58). | CARRIES ("Read before merging") |
| 53 | Row 4: acceptance check unmeetable, shared assumption false, or code contradicts the design: nearest reading, go on, raise. | Not stated. | CARRIES |
| 54 | Row 5: advisor can't choose: take the option a later commit undoes most cheaply, go on, raise. | Not stated. | CARRIES |
| 55 | Row 6: a question that always stops: stop. | - | GOES (replaced by decisions L98-108) |
| 57-60 | A pass takes as many flagged choices as it meets; the round report counts them so a thin design shows. | Rulings above. | CARRIES "no limit on flagged choices"; the count GOES (score) |
| 64-65 | An acceptance item has an outcome (what Geoff would see) and a check (command or screenshot); approval fixes the outcome. | Not stated. | CARRIES |
| 67-69 | Check unmeetable, outcome meetable: use a check that shows the same outcome, flag it, keep item verbatim with amended check and reason. | Not stated. | CARRIES |
| 70-73 | Outcome unmeetable or items contradict: build the nearest reading, flag, keep item verbatim, quote it as the ruling departed from. | Not stated. | CARRIES |
| 74-75 | No session drops an item; an unmet one stays marked unmet with the reason. | Not stated. | CARRIES |
| 77-81 | The designing session runs every check once on today's code, records command and output, shows it stable (no clock, temp path, random id) and failing today for the reason the work fixes. | Geoff, 2026-11-14 (L78). | CARRIES (spec author) |
| 81-82 | A planner reruns each check on the code earlier passes left. | Not stated. | GOES (no planner) |
| 88 | Always stops: spend past path or usage ceiling. | Not stated. | CONTROL: a cap in the timer script ends work and asks nothing (decided L104; the numbers are proposed L121-122). Assembled |
| 89 | Always stops: an irreversible or destructive act. | Global CLAUDE.md "Judgment calls". | CONTROL: permission deny rules (documented); the session finishes the rest and lists it (decided L105) |
| 90 | Always stops: a secret, or a step only Geoff can do. | Same. | CARRIES as "gathered before the run starts" (decided L106) |
| 91 | Always stops: any question in an `auth-data` task. | Same. | CARRIES reshaped: the session decides, a second session reviews, the PR is flagged (decided L108) |
| 92-93 | Always stops: work beyond approved scope (more outcomes, another repo, an excluded path); a decision the design reserves for Geoff by name counts. | Same. | CARRIES: build what the goal covers or end and say why (decided L107); a reserved decision is "Held for you" |
| 96-98 | Machine limits in standing answers 4-7 and 11 end launches and ask nothing. | Not stated. | CONTROL (timer script) |
| 98-100 | A choice departing from one of Geoff's rulings quotes it. A closing review short of `accept` on an `auth-data` finding stops. | Not stated. | CARRIES the quote rule. The stop GOES; it becomes a "Read before merging" PR |
| 104-107 | A flagged choice makes the pass wait for a close packet while its chain runs on; no later pass lands before the close packet. | Not stated. | GOES |
| 110-111 | The conductor turns each `[advisor]` call into a close-document question. | Not stated. | GOES |
| 112-114 | A later pass reads the `[advisor]` lines of every PR it depends on and names any flagged choice it builds on under `## Decisions`. | "So the packet shows what an overturn undoes" (L113-114). | CARRIES (stacked tasks make this more important) |
| 115-119 | When Geoff overturns a choice, the conductor appends a ruling and relaunches executors in merge order; each merges its parent's branch first. | Not stated. | GOES as written. The new path is not stated in decisions |
| 121-122 | The round report counts `[advisor]` lines and reversals. | Not stated. | GOES |
| 126-142 | The conductor's open case: one Fable dispatch, or the desk by `SendMessage` with a 600-second sleep. | Geoff, 2026-11-12 (L126-127). | GOES |
| 144-146 | The dispatch never decides whether a PR lands or merges, what an approval covers, the usage ceiling, the relaunch limit, or the busy check. | Not stated. | CARRIES as "no session decides a merge or a limit"; CONTROL for merge (merge guard) and limits (timer script) |

## conductor.md (56 lines)

Everything here serves the conductor, which the decisions remove (decisions L78). Line items
worth keeping elsewhere:

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 8-14 | Launch or message the conductor; stall written to STATUS. | Not stated. | GOES |
| 16-17 | A planner launches its executor; a failed launch parks. | Not stated. | GOES |
| 25-29 | Name check; no `/loop`, no Monitor; wait by `notify_when_idle` and `round-watch`; lid-switch hold. | A notice can fail to arrive (2026-11-14, L26). | GOES. Lid-switch hold becomes CONTROL (systemd-inhibit in the timer script, assembled) |
| 31-33 | Relay rulings quoting the source; a message never stands in for Geoff's approve, so cannot authorize a merge, purchase, or scope change. | Not stated. | CARRIES the second sentence |
| 36-40 | On a stop, one `decide` document; launch the next independent pass while one is parked. | Not stated. | GOES. "Launch independent work while one is stopped" is the decided test (decisions L89-90), held by the timer script (CONTROL) |
| 42 | Messages from `desk`. | Not stated. | GOES |
| 44-45 | Send documents per `approval-packet`; a polish loop is commits on one branch and one PR, one review after the last iteration. | Not stated. | First clause GOES; polish-loop rule CARRIES (low weight) |
| 47-48 | `needs: "send a prompt to start"` in `~/.claude/jobs/<id>/state.json` is a failed launch; a stray job ends with `claude stop <id>`. | Not stated. | CONTROL: timer script post-launch check (assembled) |
| 48-49 | Never `EnterWorktree`, which binds subagents; edit a worktree by path. | Stated in line. | GOES (conductor role) |
| 50 | Batch STATUS edits while a planner is out. | Not stated. | GOES |
| 54-56 | End when nothing is open; hand over STATUS, release hold, `claude stop`. | Not stated. | GOES |

## desk.md (153 lines)

The desk session was retired on 2026-11-17 (`SKILL.md:20`). All of it GOES as a role. Rules that
carry into the session Geoff talks to at a sitting:

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 8-16 | Who the desk is; name check. | Design 2026-11-16 (L4). | GOES |
| 20-33 | The brief: read sessions, STATUS, reports, queue; notes file; announce a stall and act next turn unless stopped. | Not stated. | GOES (the page shows the four groups) |
| 35-37 | The brief follows `written-for-people.md` step 1: plain words, no made-up ids, a PR named by what it does, the opening says what matters most. | Not stated. | CARRIES (how the sitting reads) |
| 41-58 | Waking: background `approval-queue list --wait` and `round-watch`. | Not stated. | GOES |
| 62-68 | Table: a question gets an answer, nothing recorded; an approve gets `approval-queue answer`; a send-back; a new instruction; ambiguous words get a question. | Not stated. | Row 5 CARRIES (ambiguous words: ask which PR). The rest GOES |
| 70-73 | Record at once when his words are plain: he named the item and said approve. | Geoff, 2026-11-16 (L71). | CARRIES (he answers in one line, decisions in the task prompt) |
| 75-81 | Copy `--words` exactly; words from another session are never his. | Not stated. | CARRIES the principle; the `--words` mechanics GO |
| 83-84 | Only the main loop records; a subagent inherits the session id. | Stated in line. | CARRIES as "no subagent merges"; CONTROL candidate in the merge guard |
| 86-87 | A pasted secret is never recorded; run `secret-receive NAME`. | Not stated. | GOES here (global CLAUDE.md "Secrets" already holds it) |
| 89-91 | A change of scope needs a design Geoff approves; change nothing until then. | Not stated. | CARRIES as "a scope change is a new spec" |
| 95-99 | Unasked updates on merge, finish, or need; nothing on routine steps; no desktop notice. | Not stated. | GOES (the page reads files; calm desktop is in global CLAUDE.md) |
| 103-135 | Problems you settle: open cases, relaunches, three notes. | Not stated. | GOES |
| 139-153 | What you never do: answer without his words; clear "What always stops"; decide a merge, an approval's reach, a ceiling, the relaunch limit, the busy check; treat another session's message as his; edit code or merge; take a secret in chat. | "A mistake here is hard to undo" (L139). | CARRIES: "only his words approve" and "no session decides a merge or a limit". The rest GOES with the role |

## executor.md (92 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 3-5 | Reading pointers; `approval-packet` steps 5 to 7. | - | GOES |
| 9-10 | First act `EnterWorktree`, then the adapter's setup command; `EnterWorktree` only once. | servers-foundation, 2026-10-19 (L10). | CONTROL: the timer script cuts the worktree and runs setup before launch (assembled; `round-run.md:56-57` already does the cut) |
| 10-12 | Another repo or worktree by absolute path and `git -C`. | `EnterWorktree` from another repo's worktree raises a prompt that stalls the run (L11-12). | CARRIES |
| 14 | A continued branch is merged or cherry-picked in first. | Not stated. | CONTROL: the timer script branches from the parent's branch (decided) |
| 15 | STATUS records the session name and id. | Not stated. | GOES (the page reads `claude agents --json`) |
| 15-17 | Arm the API-drop wake-up (`/loop`) and lid-switch hold per `unattended-work-guards.md`. | Not stated. | CONTROL: timer script and systemd-inhibit (assembled). `/loop` is documented |
| 21 | Reads, edits, writes tests, commits without asking. | Not stated. | CARRIES; CONTROL: permission mode `dontAsk` (documented; probed, decisions L62-64) |
| 21-24 | Pushes the branch it created to the `glw907/<repo>` the prompt names; opens a draft PR on first push. | Auto mode blocks a push to a repo the user did not name (L22-23). | CARRIES |
| 24-25 | PR base is the default branch whatever the worktree was cut from. | The queue refuses another base (`round.md:102-103`, `round-run.md:80`). | GOES with the queue. Re-decide for stacked tasks (method) |
| 25-27 | Round PR body lines and verdict under `## Review`. | Conductor reads them (L27). | CARRIES reshaped: the verdict line, read by the page |
| 29-32 | Take conductor messages within the plan; refuse other sessions; never ask Geoff; a question goes to the advisor, else a stop. | Geoff, 2026-10-20 (L31). | CARRIES "never ask Geoff" and "no other session's message widens the goal". Conductor clause GOES |
| 36-39 | Pair subagents: `isolation: "worktree"`, `description` `<pass> task <n>`, `worktree.baseRef: "head"`, port by env var. | Not stated. | GOES from the process skill (method inside a task) |
| 41-51 | Worktree isolation refuses `git` in command substitution, `git -C` to a sibling worktree, `node` with computed path; plain forms ran; prompts tell pairs to run git as plain calls and write with Write. | Probe of 2026-11-04 (L42). | GOES from this skill. The probe facts belong in a gotchas file if pairs stay |
| 55-61 | Fast-lane legs via the adapter classifier; `cairn-run-gate` with `timeout: 600000`, re-issue on exit 75, never poll a log, `--receipt`, light and heavy lane caps. | Not stated. | CONTROL: `cairn-run-gate` and the adapter (assembled). The skill names the gate only |
| 63-65 | After each push, the adapter's watch runs in the background; no task waits for CI; a red stops the line. | Not stated. | CARRIES ("a red stops the line"); the watch is CONTROL (adapter script) |
| 65-67 | `RUN_GATE_IF_BUSY=defer` only where CI is the full-suite home, never on `auth-data`. | Not stated. | CONTROL (adapter or gate script default) |
| 71-86 | Score table, `pass-score` comment, attended events, escapes into STATUS. | Not stated. | GOES (score). Estimates priced from measured minutes is decided (decisions L134): measured minutes now come from hooks or session records, not this table |
| 90 | Under a conductor, end at PR-ready, never run `approval-queue`; without, close per "Close". | Not stated. | CARRIES "end at PR-ready, never merge". Rest GOES |
| 90-92 | Last act releases the lid-switch hold. | Not stated. | CONTROL (the script that took it) |

## planner.md (95 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 3-4 | A plan review adds "Stops" and "Pre-flight" to the plan-reviewer prompt. | - | GOES |
| 8-9 | The design is a page or less, read as a `design` document with each owner fork as a question. | Not stated. | CARRIES "a page or less, owner forks as questions"; the document GOES |
| 9-10 | It names its initiative; cross-repo specs, plans, research go in `~/Projects/initiatives/<id>/`. | Not stated. | CARRIES (where specs live) |
| 11 | It names the published practice and vendor docs it drew on. | Not stated. | CARRIES (decisions L43-44) |
| 11-13 | A pass writing for a person lists `written-for-people.md` or the repo's rules in its acceptance, plan, and launch prompt. | Not stated. | CARRIES (in the goal) |
| 14-15 | After a pass misses its bar, the next design reads its final artifacts against the code and traces each wrong claim. | Not stated. | CARRIES |
| 17-20 | A design adding a project, service, or infrastructure names where it runs and why, weighing Cloudflare against orpheus and ward; never defaults to the host at hand. | Geoff, 2026-10-22 (L20). | CARRIES, but it is design content, not process; first cut |
| 22-25 | Every design runs the scoped `standards:backlog-sweep`, never a due full sweep; lists verdicts; approval approves the edits; a backlog pass lists each drop with its reason. | Geoff, 2026-10-27 and 2026-10-25 (L24-25). | CARRIES |
| 27-29 | Estimate in path minutes from recent scores; a plan over twice the estimate parks; the path sets the stop, never the sum. | Geoff, 2026-10-12 (L29). | Estimate CARRIES reshaped ("priced from measured minutes", decisions L134). The park GOES; the cap is CONTROL (timer script, proposed decisions L121) |
| 29-33 | A test never cuts a release candidate; a run needing a published build publishes a `dev` snapshot under a test dist-tag. | Geoff, 2026-11-09 (L30); changesets docs cited. | CARRIES, but belongs in `cairn-releasing`; first cut |
| 37-39 | The design's approval asks how to answer each foreseeable stop; answers are standing approvals; the rest go to the advisor. | Geoff, 2026-11-14 (L39). | GOES (standing-answer machinery) |
| 41-46 | No count cap stops the line; each retry fixes a traced cause inside the ceiling; a returning cause gets one structural fix; if it returns again, escalate in the PR and go on; untraced causes are flagged and the run goes on. | Geoff, 2026-10-19 (L41). | CARRIES |
| 50-52 | `## Pre-flight` with `Permissions checked:`, `Reviewed:`, `Evidence:`. | Geoff, 2026-11-01 (L51). | GOES |
| 54-57 | Each Geoff step names its check; foreseen ones go in the design's packet; one the plan adds is a planning miss. | Not stated. | CARRIES "each owner step names the check that shows it done, and is done before launch" (decisions L106). Rest GOES |
| 58 | Every value the run needs is looked up in the stores first. | Not stated. | GOES here (global CLAUDE.md "Secrets" holds it) |
| 59-62 | Each write is read against auto mode; a settings, credential, or new-surface write gets a `[you]` item or a probed path; merges' steps settled before launch. | Not stated. | CONTROL: permission rules refuse it, the session lists it (decided L105). The "read writes against the mode" check CARRIES into spec writing |
| 63 | A bulk Proton Pass edit is a `[you]` step through `pass-sitting`. | Not stated. | GOES here (global CLAUDE.md "Secrets" and `proton-pass` hold it) |
| 64-65 | An open `[you]` item at an armed launch is checked at arm time. | Pass 5, 2026-10-31 (L65). | GOES |
| 66-67 | A launch in a never-opened directory lists the workspace trust prompt. | 2026-11-10 (L67). | CONTROL: timer script pre-launch check (assembled) |
| 68-69 | A workstation-config pass states what each host gets; reboot or `check-drift` has a standing answer. | Not stated. | CARRIES in the dotfiles adapter, not the core skill |
| 73-76 | Unattended planning; initiative record written once. | Not stated. | GOES |
| 78-82 | Launch only when pre-flight is done, the main checkout is on default and level with origin; add `.claude/worktrees/` to `info/exclude`. | Not stated. | CONTROL: timer script (assembled) |
| 84-90 | Launch line; prompt before variadic `--add-dir`; `state.json` failed-launch check. | Not stated. | CONTROL: timer script (assembled from documented `claude --bg`) |
| 92-95 | Prompt carries goal, scope, plan path, checkout, push target; says to merge on approval, never "never merge" or "end"; names the conductor. | Not stated. | Goal, scope, checkout, push target CARRIES (the goal file). The rest GOES |

## planning-samples.md (22 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 3-4 | Every planning dispatch cites this file. | Not stated. | GOES as a dispatch rule |
| 6-15 | Anthropic quote: avoid over-engineering, scope, defensive coding, abstractions. | Source URL (L15). | CARRIES as a cited source (documented) |
| 17-22 | Anthropic quote: deliver what was asked, make routine judgment calls yourself, finish the whole task. | Source URL (L22). | CARRIES; it is the documented basis for "decide, don't idle" |

## ready.md (44 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 7-10 | A round is ready to run when its design reaches Geoff; ground cleared the day the packet goes. | Geoff, 2026-11-14 (L8). | CARRIES reshaped: an approved spec can start at once |
| 12-16 | Start line: a state a command reads, never a merged PR. | A pass can merge every PR before its closing steps (L14-15). | CONTROL: the timer script decides "free" from file state (assembled) |
| 17-23 | Launch checks run early and recorded; a check waiting on something outside says so. | Not stated. | CONTROL (timer script runs them); recording GOES |
| 24-27 | A prompt names a command by the skill section that owns it, never copies flags; a command line it must carry is probed with `--help` that day. | Not stated. | CARRIES |
| 28-31 | Side work found is placed before the packet: a task, or a backlog item. | Not stated. | CARRIES |
| 35-38 | A pass that removes or renames a command, flag, or document kind searches `~/.dotfiles/claude`, each repo's `.claude/` and `skills/`, and initiative prompts; the plan lists every hit; no landing while one is open. | Not stated. | CARRIES; CONTROL candidate: a grep check in the dotfiles gate (assembled). Directly relevant to the rename task |
| 42-44 | A due full sweep runs as its own session and document, holding no launch. | Geoff, 2026-11-14 (L43). | CARRIES reshaped: a due full sweep is its own task |

## round.md (140 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 6-10 | A round covers 1-6 passes, run one at a time; one approval approves unattended planning. | Not stated. | GOES ("one at a time" conflicts with the decided timer) |
| 16-17 | A round id. | Not stated. | GOES (a spec has a name) |
| 18-19 | A pass table: outcome, acceptance list, files, class, path minutes, depends on, shares a file with. | Not stated. | CARRIES as the spec's task list |
| 20-21 | Shared assumptions, each with a probe and output or quoted source. | Not stated. | CARRIES |
| 22-23 | The order table with planner prompts and a mark on PRs that wait for Geoff. | Not stated. | GOES |
| 24 | The merge order. | Not stated. | CARRIES (Geoff merges stacks in order) |
| 25 | The usage ceiling, 85 percent weekly. | Not stated. | CONTROL: timer script (proposed decisions L121-122) |
| 26-27 | The twelve standing answers hold; the design adds or replaces. | Not stated. | GOES (see the 12 below) |
| 29-30 | A pass sharing a file with an unmerged pass depends on it. | A pass cut from default would conflict at merge (L30). | CARRIES (the spec marks it; the timer branches from it) |
| 31-33 | Sharing only `BACKLOG.md` and `docs/STATUS.md` is order, not building on. | Not stated. | CARRIES reshaped: not a dependency |
| 34-35 | The pass on the least-proven assumption runs first. | A wrong assumption costs one pass, not the round (L35). | CARRIES |
| 35-37 | A pass waiting for a close packet holds later landings; no-call passes first. | Not stated. | GOES |
| 37-38 | The longest chain holds about 600 planned path minutes. | Not stated. | GOES: decisions L92-93 withdraw the arbitrary hour figure and send gap length to the 1.2 work |
| 40-44 | Commit planner prompts and one conductor prompt with the planner launch line; each pass planned just before it runs. | Not stated. | GOES |
| 51-55 | Rule 1: each pass has an acceptance list, each item able to fail; played back at the sitting with a mockup for anything he will look at; approval fixes outcomes; checks run before the packet; no item dropped. | "A wrong design costs more in a round" (L48-49). | CARRIES (the goal) |
| 56-57 | Rule 2: shared assumptions with probe or source; else not ready. | Same. | CARRIES |
| 58-61 | Rule 3: one fresh Opus reader with no context checks the design (builder check): can every pass be planned, could an item pass on a wrong result, can each be met, could it launch on approve. | Same. | CARRIES |
| 62-64 | Rule 4: each PR shows evidence per item; the closing reviewer checks each item against it; unmeetable items amended and flagged. | Same. | CARRIES (the core of the new review) |
| 66-68 | A one-pass round takes "The acceptance list and its evidence in the PR". | Geoff, 2026-11-11 (L67). | CARRIES (quote) |
| 75-76 | Planner rule 1: a mechanism table; each row a probe with output or a quoted source; no "expected". | "Largest classes of planning miss" (L73). | CARRIES (into the spec) |
| 77-79 | Planner rule 2: file list from searches with hit counts; every hit listed or dismissed. | Same. | CARRIES |
| 80-83 | Planner rule 3: `Permissions checked:` from 30 days of `~/.local/state/claude-denials.jsonl`, with date range, classes, counts, and an alternative for each refused command. | Same. | CARRIES reshaped (the spec reads the denials log); the log is CONTROL already (PermissionDenied hook `claude-denied-log`, `settings.json:194-203`, documented) |
| 84 | Planner rule 4: no stop says "ask Geoff". | Same. | CARRIES as "no goal says ask Geoff" |
| 88-90 | A plan inside a round starts at Lifecycle step 4. | - | GOES |
| 92-93 | Work by path; `EnterWorktree` belongs to the executor. | Not stated. | GOES |
| 94-95 | Verify each change site against the code as earlier passes left it. | "The design's line numbers have moved" (L95). | CARRIES |
| 96 | Plan header lines. | - | GOES |
| 97-98 | Copy every acceptance item verbatim under `## Acceptance`, mapped to its task and its evidence. | Not stated. | CARRIES |
| 99-100 | Read `[advisor]` lines of PRs depended on; name flagged choices built on. | `advisor.md` "In a round". | CARRIES |
| 101 | One plan-reviewer read. | Not stated. | GOES |
| 102-103 | PR base is the default branch; the queue refuses others. | Stated in line. | GOES with the queue; re-decide |
| 105-106 | Commit the plan and prompt, push, launch checks, launch. | - | GOES |
| 108-124 | Ten miss tags for `## Planning misses`, counted by `pass-report`. | Stated (L110-111). | GOES. Failures are recorded by hooks now (decided L57) |
| 126-133 | Park at planning on twice the estimate or an always-stop; anything else goes to the advisor. | Geoff, 2026-11-14 (L133). | GOES |
| 135-140 | To park: commit plan, push, draft PR holding the plan with the stop; end; never ask in chat, never `notify-send`. | The conductor reads the stop from the draft PR (L137-138). | "Never ask in chat, never `notify-send`" CARRIES. The rest GOES |

## round-run.md (154 lines)

| Lines | What it tells a session | Why, if stated | Fate |
| --- | --- | --- | --- |
| 3-4 | The round design and order table win. | - | GOES |
| 6-8 | Executor enters the worktree once and merges no PR; one-pass round sends its own `decide`. | Not stated. | "Merges no PR" CARRIES. Rest GOES |
| 46-49 | Before each launch, read weekly usage via `claude -p "/usage" --model haiku`. | Not stated. | CONTROL: timer script (assembled) |
| 50-51 | Main checkout on default and level, `--ff-only` pull. | Not stated. | CONTROL: timer script |
| 52 | Write the report. | Not stated. | GOES |
| 53-54 | `claude stop <id>` for finished sessions; a refusal is reported, never retried. | Not stated. | CONTROL: timer script |
| 55 | `claude-worktree-busy <checkout>`. | Global CLAUDE.md "One executor per worktree" (2026-07-14). | CONTROL: timer script, existing tool |
| 56-58 | `git worktree add .claude/worktrees/<pass> -b <branch> origin/<base>`; base is default, or the parent's branch when the parent waits. | Not stated. | CONTROL: timer script. This is the decided stacking rule |
| 59 | Launch the planner. | - | GOES (launch the task session instead) |
| 61 | A pass that builds on another starts once that PR is ready, whatever its verdict. | Not stated. | CONTROL: the timer's "free" test (assembled). Matches decisions "nothing waits for a merge" |
| 65-66 | Read the PR, checks, and verdict; a pass never counts finished on its last message. | Not stated. | CARRIES |
| 68-71 | Land when ready, `accept, open findings 0`, green, every item listed, not marked, nothing earlier waiting, step 1 lets it. | Not stated. | GOES as landing. Reshaped: this is the "Ready to merge" test (CONTROL: the page sorts by PR state) |
| 72-74 | Wait for a close packet on calls, open finding, short verdict, mark, earlier waiter. | Not stated. | Reshaped: "Read before merging" |
| 75 | Park on a `## Stop` or plan-only draft. | Not stated. | Reshaped: "Couldn't finish" |
| 76 | Relaunch otherwise. | Answer 11. | CONTROL (timer script) |
| 80 | Every PR's base is default; `merge` and `land` refuse others. | Queue. | GOES; re-decide |
| 81-83 | One close packet per round; calls, verdicts, Before-merge as questions; a red PR is never sent. | Not stated. | GOES. "A PR with a red check is never ready to merge" CARRIES |
| 84-85 | A note asking a change goes under `## Rulings`; executor relaunches. | Not stated. | GOES; new send-back path not stated |
| 86 | A pass resuming after the packet lands or gets its own. | Not stated. | GOES |
| 87-88 | `approval-queue send` and `collect` in the background. | Not stated. | GOES |
| 92-98 | A stop: commit and push, open draft PR, write the stop (question, tried, choices) under `## Stop` in STATUS on the branch, push, end; never ask in chat, never `notify-send`. | Not stated. | CARRIES reshaped as "couldn't finish": commit, push, draft PR, what is left with a recommendation, end. STATUS-on-branch location is a method call |
| 100 | Stop background commands with `TaskStop`, never `kill` or `pkill`. | Not stated. | CARRIES (low weight); CONTROL candidate: PreToolUse deny on `pkill` (documented) |
| 104-105 | PR body lines `Round:`, `Pass:`, `Review: <verdict>, open findings <n>`, `Calls:` with `## Calls for Geoff`. | Not stated. | `Review:` and the calls heading CARRY (the page reads them). `Round:` and `Pass:` reshape to spec and task names |
| 107-108 | `## Acceptance` lists each item verbatim with its evidence. | Not stated. | CARRIES |
| 110-113 | The closing `standards:diff-reviewer` checks each item against its evidence; an unfixed finding becomes a call; a `fix` verdict gets one second fresh read; short of `accept`, the PR is ready with that verdict. | Not stated. | CARRIES |
| 117-119 | Miss tags. | - | GOES |
| 123-126 | Round report document rewritten before each launch; sent once. | Not stated. | GOES |
| 128-135 | Report parts: title says what is true now; first paragraph is the whole report small, ending on whether anything waits; what behaves differently; what went wrong; what it cost; what is left as backlog items named by what they do. | Not stated. | CARRIES (how a report reads) |
| 137-141 | Copy the report head into a STATUS block, commit by path, push; undo on failed push. | Not stated. | GOES (the page reads files) |
| 145-147 | The clock and its pauses. | Not stated. | GOES as a round clock; CONTROL if the per-task cap is adopted (proposed) |
| 151-154 | Resume from a report file; take each pass's state from its PR and branch, never the report; recover answers. | Not stated. | "State from the PR and branch, never a report" CARRIES. Rest GOES |

## The 12 standing answers (`round-run.md:12-41`)

`round.md:26` says these twelve "hold in every round". Each one separately:

1. > "A pass stops on a question `advisor.md` "What always stops" lists. The executor follows
   > "Stops". The conductor waits for the PR's checks, sends one `decide` document, ends the
   > pass's sessions, and launches the next pass `conductor.md` "Run" names." (L12-14)

   Why: not stated. Fate: **GOES**. Replaced by the decided five-stops table (decisions
   L102-108), which never stops on a question. The "launch the next independent task" half is
   CONTROL in the timer script.

2. > "Auto mode refuses a command. The session uses the alternative its plan names, once. After a
   > second refusal it flags the task and goes on. No session edits a setting to get past one."
   > (L15-16)

   Why: not stated. Fate: **CARRIES**, with a CONTROL behind it: permission rules refuse the
   command (documented), and a `dontAsk` background session carries on past a refusal and ends
   `done` (probe, decisions L62-64). The `claude-denied-log` hook records it
   (`settings.json:194-203`). "Its plan names" reshapes to "the goal names, or the session
   picks".

3. > "A task needs a setting, hook, auto-mode entry, or permission rule changed. That is never an
   > executor task. The close packet carries the commands and their check, and Geoff's approve
   > lets the merging session run them (Geoff, 2026-11-14). A pass that can't finish without them
   > parks." (L17-19)

   Why: Geoff, 2026-11-14. Fate: **CARRIES** (the commands and their check go in the PR, and the
   session Geoff talks to runs them on his approve; that is "Held for you") plus **CONTROL**
   (permission rules refuse writes to settings files; documented). "Parks" reshapes to "finishes
   the rest and lists it" (decisions L105).

4. > "The weekly usage reads 85 percent or more before a launch, or the figure can't be read.
   > The conductor finishes the pass in flight, starts nothing new, writes the report, and waits
   > for the reset." (L20-22)

   Why: not stated. Fate: **CONTROL**: the timer script reads usage before each start and
   starts nothing at 85 percent or when the figure can't be read (assembled). The 85 percent cap
   is proposed, not ruled (decisions L121-122).

5. > "A pass's parent is parked. A pass whose "Depends on" entry for it reads `(order)`, as in
   > `2 (order)`, runs past it as `conductor.md` "Run" says; an unmarked entry builds on it, and
   > that pass waits." (L23-25)

   Why: not stated. Fate: **CONTROL**: the timer script's "free" test. A task whose parent
   couldn't finish waits; a task with only an order mark, or no link, starts. This is the
   decided failure test "one stopped task held up work that didn't depend on it" (decisions
   L89-90).

6. > "The busy check exits 1. Launches end in that repo, and the report says so." (L26)

   Why: global CLAUDE.md "One executor per worktree" (2026-07-14). Fate: **CONTROL**: the timer
   script runs `claude-worktree-busy` (existing tool) and skips that repo; the hook or page
   records it.

7. > "The round passes twice its planned minutes ("Clock"). The pass in flight finishes, nothing
   > new starts, and the conductor writes the report." (L27-28)

   Why: not stated. Fate: **CONTROL**: the timer script. Note the scope differs: this answer
   caps the round, while the proposal caps each task ("no new task past twice its planned
   minutes", decisions L121). The proposal is not ruled.

8. > "A plan can't go ahead as designed. The planner flags the advisor's choice, or parks as
   > `round.md` says." (L29-30)

   Why: not stated. Fate: **GOES** (no planner). Its intent is covered by the CARRIES judgment
   rules: decide, flag, go on.

9. > "Geoff answers a `decide` document while the round runs. The conductor appends his ruling
   > under `## Rulings` in the pass's plan, commits and pushes it, and relaunches the pass once
   > the one in flight finishes. The PR takes the question under `## Planning misses` and the
   > ruling under `## Decisions`. Passes that depended on it follow in order." (L31-34)

   Why: not stated. Fate: **GOES**. No question reaches him between sittings (decisions L100).
   How his answer at a sitting restarts a "Couldn't finish" or "Held for you" task is not
   stated in the decisions.

10. > "The conductor's session dies or the machine restarts. STATUS names the conductor prompt
    > and each open document, and any session can relaunch it to resume ("Resuming")." (L35-36)

    Why: not stated. Fate: **GOES** (no conductor). A systemd timer runs again after a restart
    without help; whether it needs `Persistent=` is a systemd question, not stated here.

11. > "An executor goes idle with its pass unfinished and no stop in STATUS, or a planner goes
    > idle with no executor and no draft PR. The conductor relaunches it from its prompt, twice
    > at most. A third idle parks the pass, or ends launches where no PR can be opened." (L37-39)

    Why: not stated. Fate: **CONTROL**: the timer script relaunches an idle task session at
    most twice, then counts it "Couldn't finish" (assembled). This guards the decided failure
    "a session sat idle over something it could have decided" (decisions L89).

12. > "An acceptance item can't be met as written, or a shared assumption proves false. The
    > session amends and flags it (`advisor.md` "Acceptance items")." (L40-41)

    Why: not stated. Fate: **CARRIES**.

## CONTROL items, by mechanism

| Mechanism | Label | What it holds | Source lines |
| --- | --- | --- | --- |
| Permission deny and ask rules | documented | Irreversible or destructive steps; writes to settings, hooks, auto mode | `advisor.md:89`, `round-run.md:15-19`, `planner.md:59-62`, `SKILL.md:73-75` |
| Permission mode `dontAsk` for task sessions | documented, probed | Sessions work without asking and carry on past a refusal | `executor.md:21`, decisions L62-64 |
| PreToolUse hook `claude-merge-guard` | documented hook, existing script | No merge outside the session Geoff talks to; no subagent merges | `SKILL.md:136-137`, `desk.md:83-84` |
| PermissionDenied hook `claude-denied-log` | documented hook, existing script | Records every refusal; spec writers read the log | `round.md:80-83` |
| Agent frontmatter | documented | Reviewer model and effort | `SKILL.md:86-87` |
| Timer script (Bash, systemd) | assembled | Free test from dependencies; branch from unmerged parent; busy check; level checkout; usage cap; minutes cap; launch line with `--name`, `--model`, `--effort`; failed-launch check; workspace trust; `info/exclude`; idle relaunch twice; lid-switch hold; `claude stop` | `round-run.md:20-28, 37-39, 46-61`; `planner.md:66-67, 78-90`; `executor.md:9-17`; `conductor.md:47-48`; `SKILL.md:94-97, 174-175` |
| Merge script (run by the sitting session) | assembled | Before-merge steps, `--ff-only` pull rules, worktree and branch removal with no force | `SKILL.md:139-151` |
| `cairn-run-gate` and adapter scripts | assembled, existing | Gate legs, lanes, receipts, CI watch, defer rule | `executor.md:55-67` |
| Page reading PR bodies | assembled | Sorting into the four groups from `Review:`, calls heading, draft state, checks | `round-run.md:65-76, 104-105` |
| Dotfiles gate grep | assembled, candidate | Old command or document-kind names after a rename | `ready.md:35-38` |

## CARRIES, as the new skill would hold them

Merged and ordered. Written in the new words. Wrapped at 100 characters. Source lines follow each
item in brackets, which the skill itself would drop.

```
## The spec
1. A spec names the published practice and vendor docs it draws on. It labels each mechanism
   documented, assembled, or invented, with a probe and its output or a quoted source; nothing
   says "expected". [SKILL 42-43; planner 11; round 75-76]
2. It lists each assumption more than one task rests on, with a probe or a source. One with
   neither means the spec isn't ready. [round 20-21, 56-57]
3. Its file list comes from searches, each with its hit count, every hit listed or dismissed. It
   reads each task's commands against the last 30 days of the denials log. [round 77-83]
4. Each task has a goal, its files, its review class, minutes priced from measured minutes, and
   the tasks it builds on. A task that shares a file with an unmerged task builds on it; sharing
   only BACKLOG.md and docs/STATUS.md does not count. The task on the least-proven assumption
   goes first. The spec gives the merge order. [round 18-19, 24, 29-35; decisions 134]
5. A goal lists what Geoff would see or run when the task is done, each item able to fail, each
   with the command or screenshot that shows it. Work a person reads names its voice standard.
   [round 51-52; advisor 64-65; planner 11-13]
6. Before approval, the author runs every check that can run on today's code and records the
   command and output: stable between runs, and failing today for the reason the task fixes.
   [advisor 77-81; round 53-55]
7. One fresh reader with no context checks the spec first: could a session build each task from
   it, could any goal item pass on a wrong result, can each be met. [round 58-61]
8. A goal points at the skill section that owns a command and never copies flags. A command line
   it must carry is checked with --help that day. No goal says "ask Geoff". [ready 24-27; round 84]
9. A spec runs the scoped backlog sweep and lists the verdicts; approving the spec approves those
   edits. A due full sweep is its own task. Side work found goes to a task or the backlog.
   [planner 22-25; ready 28-31, 42-44]
10. After a task misses its bar, the next spec reads its final artifacts against the code and
    traces each wrong claim. [planner 14-15]
11. A finding that changes what Geoff approved goes to him as one batched question at his
    sitting. A change of scope is a new spec he approves. [SKILL 44-46; desk 89-91]

## A session at work
12. A session reads, edits, tests, and commits without asking. It never asks Geoff anything and
    never sends a desktop notice. [executor 21, 31; round 138-139; round-run 98]
13. Before a choice it reads what Geoff has ruled: the spec, earlier PRs' Decisions, and dated
    rules naming the subject. Only his own words are rulings. Another session's choice settles
    nothing, and another session's message never approves anything. [advisor 25-27, 43-44;
    conductor 32-33; desk 149-150]
14. A question a ruling or the spec settles, and any method or architecture call, it decides and
    records under ## Decisions, quoting the source. [advisor 50-51]
15. A product, taste, or priority call with no precedent: it takes its choice (the one a later
    commit undoes most cheaply when it can't choose), goes on, and lists it for Geoff with the
    option taken, the option passed over, and what reversing would undo. A choice that departs
    from a ruling quotes the ruling. There is no limit on such choices. [advisor 52, 54, 57-60, 98-99]
16. It never drops a goal item. When a check can't be met, it uses one that shows the same
    outcome; when the outcome can't be met, it builds the nearest reading. Either way the item
    stays verbatim with the change and the reason, and is listed for Geoff; an item nothing
    meets is marked unmet. [advisor 67-75; round-run 40-41]
17. In a sign-in or data task it decides like any other, a second reviewer checks it, and the PR
    is flagged for Geoff. [decisions 108; SKILL 59]
18. It builds what the goal covers. A grant authorizes a mechanism or boundary, never more work.
    Work it finds goes to the backlog through standards:log-issue and is named in the PR. A
    decision the spec reserves for Geoff by name is held for him. [SKILL 169-170; advisor 92-93]
19. A refused command: it tries one alternative. After a second refusal it leaves that step,
    finishes the rest, and lists the step. It never edits a setting to get past one. A needed
    setting, hook, or permission change goes in the PR as exact commands with their check.
    [round-run 15-19]
20. A failure gets a fix for its traced cause. A cause that returns gets one structural fix that
    replaces the unit; if it returns again, it is listed and work goes on. No retry count stops
    the task; only the cap does. [planner 41-46]
21. A task that builds on another checks each change site against the code as that task left it
    and names any flagged choice it relies on. [round 94-95, 99-100; advisor 112-114]
22. It works in another repo or worktree by absolute path and git -C. It pushes only the branch
    it created, to the repo the goal names, and opens a draft PR on the first push.
    [executor 10-12, 21-24]

## Gates and review
23. The repo's gate passes before the PR is ready, and CI carries the whole suites. A red stops
    the line until it is fixed. A PR with a red check is never ready to merge.
    [SKILL 117-118; executor 63-65; round-run 83]
24. A fresh reviewer checks the whole branch against the goal, each item against its evidence:
    standards:diff-reviewer, plus standards:web-auth-security-reviewer on sign-in or data work and
    standards:visual-verifier on rendered UI. A fix verdict gets one second read by a fresh
    reviewer. An unfixed finding is listed for Geoff, and a verdict short of accept leaves the PR
    ready with that verdict. [SKILL 57-59, 127; round 62-63; round-run 110-113]
25. A task is finished by its PR, checks, and review verdict, never by its last message; take its
    state from the PR and branch, never from a report. [round-run 65-66, 152-153]

## The PR and the report
26. The PR body opens with one plain paragraph (written-for-people.md), then what landed, each
    goal item verbatim with its evidence, the review verdict and open-finding count, any
    sign-in or data verdict, ## Decisions, and the choices Geoff must see under one heading.
    [SKILL 128-130; round-run 104-108; round 66-68]
27. A PR is safe under a plain merge and pull. If not, ## Before merge gives the exact commands in
    order and the one check that shows they ran. [SKILL 139-141]
28. A session that can't finish, or hits its cap, commits and pushes, opens the draft PR, writes
    what is left (what it tried, the choices it sees, its recommendation), and ends.
    [round-run 94-98; SKILL 26-27]
29. A report's title says what is true now. Its first paragraph is the whole report made small,
    ending on whether anything waits for Geoff. Then: what behaves differently, what went wrong,
    what it cost, and what is left, as backlog items named by what they do. [round-run 128-135]

## At the sitting
30. Only Geoff's typed words approve a merge, naming what he approves; words that could mean two
    things get one question. Only the session he talks to merges, never a subagent and never a
    task session. A PR is ready to merge only when checks are green and the review is accepted
    with no open finding. [SKILL 29-31, 135-136; desk 70-73, 83-84; round-run 6-8]
31. The merging session runs any ## Before merge commands and their check first. Then it pulls
    the main checkout --ff-only only if it is on the default branch, has no uncommitted change in
    a merged file, and has no live session; otherwise it reports it stale and never forces. It
    removes the worktree and branch with no force flag, leaving a dirty, unmerged, or live one
    with a line. [SKILL 30-31, 141-151]

## Attended work
32. A direct change lands on the default branch with no spec, PR, or review when Geoff's request
    fully specifies it, the diff fits one sentence, it touches no sign-in or data path, adds no
    public surface, schema, command, or setting, and changes wording only in a runner path. The
    session runs the gate, commits the named files, and pushes; with another session live in
    the main checkout it commits from a worktree cut from origin. Where a push deploys, it reads
    each touched page's full render. At his request naming the command, it may add one allow
    rule for a gate or test command and quote it. (Geoff, 2026-10-17) [SKILL 65-82]
33. docs/STATUS.md is present tense, 60 lines or fewer. The backlog is BACKLOG.md and
    initiatives are /log-project records. A cited commit id must survive a merge. A STATUS
    hand-over commits directly as a direct change. [SKILL 159-165]
34. Spec authorship runs on Opus at high. xhigh and max are used only where a gain is measured,
    and haiku reads but never decides. [SKILL 86-92]
```

Line count (measured with a script): the block above is 115 lines with the bracketed sources.
Dropping the brackets and rewrapping at 100 characters gives 93 lines of rule text plus 6
headings, 99 in all, before frontmatter and an intro. So it does not fit 100 lines as is.

### What to cut first to fit 100 lines with frontmatter and a short intro

In this order, each with where it goes instead:

1. Item 34 (models): the timer script's launch line and agent frontmatter hold it (CONTROL).
2. Item 31 after its first sentence: a merge script holds the pull and cleanup rules (CONTROL).
3. Item 32 (direct changes): it is attended work, not the background process; it can live in a
   reference file or in the global CLAUDE.md line that already points at it.
4. Item 33 (ledgers): a project CLAUDE.md or the repo adapter already owns STATUS and the backlog.
5. Item 3's denials-log clause and item 8's `--help` clause: spec-writing detail for a
   spec-writing reference file, read on demand.
6. Item 9's backlog sweep and item 10's miss trace: move to the spec-writing reference.
7. Already cut from the list as design content, not process: infrastructure placement
   (`planner.md:17-20`), the snapshot-not-RC rule (`planner.md:29-33`, belongs in
   `cairn-releasing`), "no review on a commit while CI runs" (`SKILL.md:61`), the polish-loop
   rule (`conductor.md:44-45`), and "`TaskStop`, never `kill`" (`round-run.md:100`).

A natural split is two files: the skill body with items 12 to 31 (the session and the sitting,
56 lines measured), and one reference for writing a spec with items 1 to 11 (25 lines). Items 32
to 34 are 12 lines.

## Not stated in the files, for the spec to settle

These are method calls (Claude's), listed so the spec doesn't fill them by accident:

- The PR base for a task branched from an unmerged parent. The old rule (default branch) exists
  only because the queue refused other bases (`round.md:102-103`, `round-run.md:80`).
- What happens to stacked tasks when Geoff overturns a flagged choice at his sitting. Old:
  `advisor.md:115-119`.
- How Geoff sends a PR back, and how a "Couldn't finish" or "Held for you" task restarts after
  his answer. Old: `round-run.md:31-34, 84-85`.
- Whether task sessions keep the advisor tool. It is documented (`advisor.md:5-6`) but silently
  dropped from background sessions when a check fails (`advisor.md:18-21`).
- Whether steps inside a task still run as pairs. The reason for pairs (idle clock, memory
  `pairs-by-default.md`, Geoff 2026-10-10) is now served by the timer starting every free task.
- Where a "couldn't finish" note lives: the old place was `## Stop` in STATUS on the branch
  (`round-run.md:96-97`); the page could read the draft PR body instead.

## Notes on the decisions file

- The four sitting groups are marked "proposed" (decisions L123-124). The relayed request for
  this run says "And those four groups look correct", which reads as Geoff's approval of them.
- The budget caps (twice planned minutes, 85 percent weekly) are proposed and not ruled
  (decisions L121-122). The old standing answer 7 caps a round, the proposal caps each task.
