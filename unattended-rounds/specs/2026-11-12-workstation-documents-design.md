# Teach every session to write the one document the new queue shows

Initiative: unattended-rounds

## Brief

Rewrite the workstation's rules for putting something in front of you, so that a session writes one document, checks it the way the document you found useful was checked, and sends it to the rebuilt Approval Queue. Approving runs a round of three passes on the workstation and then switches both the rules and the queue in one step.

Today those rules are spread over the `approval-packet` skill, a 3,800-word writing brief that Survey owns, `pass-core` and four of its reference files, and a dozen other skills that each repeat a piece. A session fills in a fact file, a second writer turns it into text under fixed headings, and you get the pages you called sloppy. This design puts the whole job in one skill with two model documents beside it, the close packet and the round report you accepted on 2026-11-12. It also writes down, in one short file, the process that produced them, and applies it to everything a session writes for you. After the switch, improving what you read means editing that skill or that file and nothing else.

### What changes

- One skill, `approval-packet`, says when to send you something, how to write it, how to check it, and what to do with your answer. It replaces the fact file, the separate writer, and the writing brief.
- One file, `written-for-people.md`, is the writing process for anything a person reads. Most of that is what you read: a queue document, a string on a queue page, a pull request's opening, STATUS, a session's last message, a question in chat. Its four steps are the plain-language standard with the two models, Vale, `tellgrader`, and a reader with no context who says what is being asked and what they couldn't follow. It also covers a file in a public repo that a person might open. You asked for both on 2026-11-12.
- A round report says in its opening whether anything waits for you, then what behaves differently, what went wrong, what it cost, and what is left for later.
- `pass-core` and its references lose their copies of the packet rules and point to the skill. `pass-core` gets shorter.
- Stale pieces are removed: the mentions of a `dotfiles-pass` adapter that doesn't exist, and the settings lines of finished initiatives.
- Four backlog items about the round rules are fixed on the way through.

### If you approve

1. The round starts after the Approval Queue round has landed its fifth pass, because the new skill names commands that pass builds.
2. Three passes each end with a pull request left open. Nothing merges, because a skill that describes the new queue must not be live before the new queue is.
3. The conductor sends you one close packet, in the old queue, with the three workstation pull requests and the queue's switch.
4. On your approve the conductor merges all four, pulls `~/.dotfiles`, restarts the queue, and sends the round report as the new queue's first document.
5. On thinkpad-x1, the next session to start pulls both repos and runs `approval-queue restart`, as the workstation's STATUS will say.

### Decide: Is this round part of the overhaul the freeze was lifted for

The workstation is under a freeze until 2026-12-11 that allows removals only, lifted for the unattended-rounds overhaul alone. This round removes more than it adds, but it does add text: the rewritten skill and its two model documents. I found no written definition of what the overhaul covers, so the call is yours.

- Yes. It finishes the overhaul, and it runs once the queue round's fifth pass lands (recommended)
- No. Hold both switches until 2026-12-11; the queue round still builds its first five passes and waits

### Decide: Who adds the `Evidence:` line to the nine plans the launch guard now refuses

Nine plans in other repos lack only that line. Each belongs to a pass that hasn't run yet.

- The session that next launches each plan adds it, since the guard's refusal names the missing line (recommended)
- This round adds all nine now, in six repos other than the workstation

### Decide: Do plans and launch prompts in a public repo get the writing checks

You said the process covers files in public repos that a person might read. Ten of your repos are public, the workstation and the queue among them, and each holds the plans and launch prompts its sessions write for one another. A README, a doc page, a pull request, an issue, and a release note get the checks either way.

- No. A plan or a prompt is written for the session that runs it, and a visitor has the pull request and the docs (recommended)
- Yes. Every plan and prompt committed to a public repo goes through the standard, Vale, and `tellgrader`

### Worth knowing

Survey still ships `approval-brief.md`, and this round can't delete a file another repo owns. The workstation stops reading its copy at the switch, and a backlog item in Survey asks for the file's removal at the next release. Until then the copy sits unused. Skills in five other repos mention the old packet commands; each gets a backlog item, and the old commands answer with a line that names the skill.

### The skill

`approval-packet` keeps its name, because "packet" is your word for a thing sent for approval. Its body is rewritten whole, to about 900 words, in this order.

1. **Whether to send.** A pass with nothing for you to decide lands its pull request with `approval-queue land` and one plain sentence. Anything that needs your decision is a document. A round's report is a document of kind `report`. Nothing is asked in chat that belongs in the queue.
2. **Write the document.** The session that did the work writes it. The title names what changed or what is asked, and never counts. The first paragraph is the whole page made small. Each question is asked where the reader meets it, with its options and a recommendation. Detail follows under headings a reader can navigate by. Reasons live in the text. No id appears that the session made up, and a pull request is named by what it does.
3. **Follow the models.** `references/model-close-packet.md` and `references/model-report.md` are the two documents you accepted. The skill says to imitate them, and gives the header and the two marks from the queue's README in a dozen lines.
4. **Check it.** Follow `written-for-people.md`, all four steps.
5. **Send and wait.** `approval-queue check`, then `send` as a background command.
6. **Act on the answer.** On approve, `approval-queue merge <id>`, then pull the checkout. On send-back, answer each note in its thread with `reply`, fix forward, and `send --returns`. The session writes no change marks; the queue shows what changed.
7. **File follow-ups.** As today.

The house departure of 2026-10-21, background before the summary, is withdrawn, because the opening you accepted puts the decision first. That reverses a ruling of yours, so say so in a note if you want it kept.

### The writing process when a person is the reader

`claude/.claude/docs/voice/written-for-people.md`, about 400 words. The `writing-voice` router gets one row, "anything Geoff reads from a session", that points to it, and one sentence sending every public-repo file through steps 1 to 3, and `approval-packet` points to it and carries no copy.

1. **Write from the standard and the models.** When you are the reader, the standards are the ones named today: the Federal Plain Language Guidelines, Nielsen Norman Group on web writing, and Google's rules for headings. The two model documents show them applied. The file also holds your corrections of 2026-11-12, which now sit in a memory file: no made-up ids, a plain question, a title that never counts, an opening that is the whole page made small. For a reader of a public repo, the standard is the one the router already names for that file, such as Google's guide for developer docs.
2. **Run Vale.** Today the house config lints no file of this kind. D1 adds queue documents and this file's folder to its scope.
3. **Run `tellgrader --register docs`** and fix every finding and warning.
4. **Give the page, alone, to a reader with no context** (`sonnet` at `medium`). The reader says what is being asked, what happens for each answer, and lists every term or claim they couldn't explain from the page. Fix what the reader missed, and run the reader once more if the fix changed a question.

What each kind of writing gets:

| Writing | Steps |
| --- | --- |
| A queue document, a round report, a string on a queue page | All four |
| A pull request's opening, STATUS, a hand-over's last message | 1 to 3; step 4 when it asks you for something |
| A reply or a question in chat | Step 1 |
| A README, doc page, pull request, issue, or release note in a public repo | 1 to 3, under the standard the router names; step 4 for a page a visitor lands on first |
| A plan or a launch prompt committed to a public repo | Your answer to the third question |
| A plan, a prompt, a note between sessions, or any other file only a session reads, in a private repo or outside one | None |

A reader per chat message would cost more than it buys, so chat follows the standard and the models alone. A file that only a session reads is written however is quickest and clearest for that session. The allowance stops at a public repo, where a person may open any file, and both halves of that rule are yours, from 2026-11-12. The file lists the public repos by reading `gh repo list`, never from memory. The agent-facing register still covers skills and `CLAUDE.md`.

### The report

`round-run.md` now tells a conductor to fill report fields. It will instead describe the document, in the order you set:

1. A title that says what is true now, and a first paragraph that is the whole report made small and ends by saying whether anything waits for you. Anything that does is a question in the report's first section.
2. What behaves differently now.
3. What went wrong.
4. What it cost: minutes planned and taken, and weekly usage before and after.
5. What is left for later, as backlog items named by what they do.

### Text on a queue page

A string the queue shows is held to all four steps of `written-for-people.md`. The queue repo's rules file, which the queue round adds, says so and names the file.

### The round

Round `ws-documents`, in `glw907/workstation`. Every pass is class `runner`. Each pass's branch is cut from the one before, and no pull request merges until the close packet.

| Pass | Outcome | Minutes | Waits for |
| --- | --- | --- | --- |
| D1 | The skill, its two models, the writing process, and the router row | 120 | Queue pass A5 |
| D2 | `pass-core` and its references | 120 | D1 |
| D3 | Settings, hooks, scripts, pointers, and removals | 120 | D2 |

The longest chain is 360 minutes.

**Pass D1. The skill, its two models, the writing process, and the router row.** 120 minutes.

- `approval-packet/SKILL.md` is rewritten as above and is under 1,000 words.
- The two model documents are in `references/`, in the new form, and `approval-queue check` accepts each. Their source is `mockup/model-close-packet.md` and `mockup/model-report.md` in this record. Only the markup changes: with the header, the marks, and the old HTML buttons stripped from both sides, a word diff against the source prints nothing.
- `written-for-people.md` exists as described above, and `vale` run on a model document reports one file linted.
- End-to-end check: a fresh `sonnet` session is given the skill and the diff of one merged pull request, workstation #231, and nothing else. It writes a close document. `approval-queue check` accepts it, and `tellgrader --register docs` prints no finding and no warning. A second fresh reader, given the document alone, writes down the question and what each option causes. The closing reviewer compares that with the pull request and judges it right or wrong. The executor edits neither the document nor the reader's answer.
- `writing-voice` has the one row for anything you read, pointing to `written-for-people.md`, and no row names `approval-brief.md`.
- The workstation's copy of `approval-brief.md` is left in place and nothing loads it. A backlog item is filed in Survey for its removal, and workstation #79 is closed as moot.

Files: `claude/.claude/skills/approval-packet/`, `claude/.claude/docs/voice/written-for-people.md`, `vale/.config/vale/.vale.ini`, `claude/.claude/skills/writing-voice/SKILL.md`, `claude/.claude/skills/survey/SKILL.md`, `claude/.claude/docs/authoring-charter.md`, `BACKLOG.md`.

**Pass D2. `pass-core` and its references.** 120 minutes. Waits for D1.

- `pass-core/SKILL.md` "Close" says in one paragraph that hand-over is the `approval-packet` skill, and keeps only what is about passes: who merges, the pull after a merge, and worktree removal. The file is under 1,350 words, from 1,484, and the closing reviewer lists each rule the old text held and where it now lives, so that a cut can't pass as a move.
- `round-run.md` describes the report as above, says where the report file lives, what the round's clock counts, and how a relaunched conductor resumes (backlog #78). It stays under 1,500 words.
- `round.md` draws the order table among what a design adds, says that `BACKLOG.md` and `docs/STATUS.md` count as shared files, states the rule that a pass waiting on a close packet holds later landings, and asks for every class in the denial log (backlog #81).
- `conductor.md` no longer has a planner run `notify-send`; a stalled hand-off parks the pass as `round.md` says (backlog #77).
- The land rule appears in one file, and the fact file and the call cap appear in none. A grep for `facts.json`, `approval-queue snapshot`, `decidedForYou`, and `approval-queue packet` under `claude/.claude/skills/` and `claude/.claude/docs/` prints only lines in the unused copy of `approval-brief.md`.
- `claude-pass-load` counts the new skill in place of the four headings of `approval-brief.md`, and the executor's load stays at or under its 9,000-word limit. The room comes from the packet text leaving `pass-core` and from `round-run.md`'s report fields; if it can't be found, the executor reads steps 5 to 7 of the skill only, and the skill marks them.

Files: `claude/.claude/skills/pass-core/`, `claude/.claude/skills/cairn-pass/SKILL.md`, `claude/.claude/skills/site-pass/SKILL.md`, `bin/.local/bin/claude-pass-load`, `claude/.claude/docs/unattended-work-guards.md`, `claude/.claude/docs/voice/commit-and-pr.md`.

**Pass D3. Settings, hooks, scripts, pointers, and removals.** 120 minutes. Waits for D2.

- `settings.json`: the reminder hook's text names `send`; the auto-mode wording on merges names `approval-queue merge` and `land` and nothing retired; the lines for finished initiatives are gone. No allow rule is added, because `Bash(approval-queue *)` covers the nine commands.
- `claude-merge-guard` names the new commands in its refusal, and its tests pass.
- `pass-report` reads decisions from the new store, and its monthly table still prints for October from the archive or says that month predates the store.
- The global `CLAUDE.md` describes your touchpoints in the new words and has no more words than it has today.
- `mail-tend`, `retire-project`, the `survey-writing-review` script, and the two model-review prompts point to the skill or drop their mention.
- No file mentions a `dotfiles-pass` adapter except the list of adapters, which is corrected.
- Each stale mention of an old packet command in cairn-cms, dubplate, poplar, ecxc-ski, and servers has a backlog item in that repo. Nothing in those repos is edited.
- `bash scripts/gate.sh` and `claude-tooling-sync verify` pass.
- Rehearsal: with the three branches checked out in a scratch copy of `~/.dotfiles` and the queue's switch branch built on a spare port and a copy of the state directory, a fresh `sonnet` session follows the new skill to `check`, `send`, and `merge` one test document against `gh` stubs.

Files: `claude/.claude/settings.json`, `claude/.claude/CLAUDE.md`, `bin/.local/bin/claude-merge-guard`, `bin/.local/bin/pass-report`, `claude/.claude/skills/mail-tend/`, `claude/.claude/skills/retire-project/`, `bin/.local/bin/survey-writing-review`, `docs/model-review/`, `tests/`, `BACKLOG.md`, `docs/STATUS.md`.

What each host gets: both hosts read the same skills and settings after a pull. The queue's server and its state are per host. pavilion is switched by the conductor. thinkpad-x1 is switched by the next session that starts there, from the STATUS line.

### The switch

The conductor of this round does it, after your approve, in this order. It stops at the first step that fails and tells you in chat, since the queue may be the thing that is down.

1. Check that the old queue has no undecided item but this packet and no session waiting on one.
2. `approval-queue merge` on the packet, with the old command: the three workstation pull requests in order, then the queue's switch.
3. Pull `~/.dotfiles` and `~/Projects/approval-queue`.
4. `approval-queue restart`. It archives the old state only after the new server answers.
5. `approval-queue check` on the round report, then `send`.

### What the passes share

| Assumption | Proof |
| --- | --- |
| The nine commands exist as the queue design names them | Queue pass A5 landed; D1's first task runs `node next/cli` with `check` on the two models |
| `Bash(approval-queue *)` allows every new command | `settings.json` line 61 |
| The old `merge` can merge pull requests of two repos in one packet | `approval-packet` step 2: `prs` are `owner/repo#n`; the conductor confirms with `packet --check` before the round's first launch |
| Nothing but the files in the inventory reads the old form | `research/2026-11-12-ui-machinery-inventory.md`, section 9; D2's grep |
| The freeze admits this round | Your answer to the first question |

### Standing answers

The twelve in `round-run.md` hold. One is added.

| Stop | Answer |
| --- | --- |
| A file in the inventory turns out to need a rule changed, where the design says wording only | The pass makes no rule change, files a backlog item, and says so in `## Decisions` |

### Pre-flight

- Permissions checked: no new rule. D3 edits `settings.json` and the launch-guard's neighbors, which you asked to see before they merge; the close packet is where you see them.
- Reviewed: one `standards:plan-reviewer` read per plan.
- [you: nothing] before the round. After it, on thinkpad-x1, nothing you type; the session there does the switch.

### Backlog sweep

| Item | Verdict |
| --- | --- |
| #79 carry two passages into Survey | Moot; closed by D1 |
| #81 four round rules | Done by D2 |
| #78 three run details | Done by D2 |
| #77 `notify-send` in the hand-off | Done by D2 |
| #80 "round" in a `site-pass` heading | Done by D2, one word |
| #23 Vale lints no `docs/voice/` file | Keep; the register it names is no longer loaded, and the item is reworded to say so |
| #38 an edit made in a vendored copy | Keep; this round shows the cost again and doesn't build the check |
| #50 a queue decision reaching the classifier | Keep open until the first merge after the switch passes with no refusal |
| #75, #82, #73 | Keep; untouched |

### Out of scope

- The queue's code, which is the other design.
- Deleting `approval-brief.md` in Survey.
- Editing skills in other repos.
- A lint for vendored copies (#38).
- PR descriptions written for an outside developer. You settled that they should be; `commit-and-pr.md` already asks for it, and D2 only removes its packet lines.

## Technical notes

### Prompts

`plans/ws-d<n>-planning-prompt.txt` for each pass and `plans/ws-documents-conductor-prompt.txt`, committed with this design.

### Models

| Role | Model and effort |
| --- | --- |
| Planner | `claude-opus-5-5` at `high` |
| Executor, D1 and D2 | `claude-opus-5-5` at `medium`; rule text is judgment |
| Executor, D3 | `sonnet` at `medium` |
| Cold reader | `sonnet` at `medium`, no context |
| Conductor | `sonnet` at `medium` |

### How each mechanism fails

| Mechanism | Failure | What happens |
| --- | --- | --- |
| Cold reader | Misstates the question twice | The session sends anyway and says so in the document's last section; two rounds is the cap |
| Vale or `tellgrader` | Not installed on the host | The skill says to stop and report, never to skip |
| The switch, step 1 | Another session is waiting on an old item | The conductor waits up to 60 minutes, then tells you which |
| The switch, step 4 | The new server fails to start | `restart` keeps the old server and the old state. The conductor reverts all four merges, newest first, pulls both repos, and reports in chat |
| A skill in another repo | Calls `approval-queue packet` | One line naming the `approval-packet` skill, exit 1 |

### Claude's calls

These are mine.

- Keeping the skill's name and the word "packet".
- Dropping the separate writer in favor of the cold reader.
- A `sonnet` cold reader, capped at two rounds.
- Withdrawing the background-first departure.
- Which of the four steps each kind of writing gets, and the file's name.
- Leaving Survey's file and the other repos' skills to backlog items.
- Holding all three pull requests for one packet.
- The conductor reverting all four merges if the new server won't start.
- thinkpad-x1 switched by its next session.

### Left to the builder

- The exact wording of the skill, within the seven steps.
- Which `pass-core` sentences go to make room.
- How `pass-report` reads the archive.

### Sources

| Change | Anthropic page |
| --- | --- |
| Two model documents in the skill, in place of a rule list | Best practices: name a pattern to follow, code.claude.com/docs/en/best-practices |
| A reader with no context before sending | Best practices: a fresh reviewer |
| The end-to-end check judged on evidence the executor can't edit | Best practices: evidence |
| The report and the round's state in files and git | "Effective harnesses for long-running agents", anthropic.com/engineering, 2025-11-26 |
| The queue repo's rules loaded by path | Skills, code.claude.com/docs/en/skills |

No source measures whether a model document changes what a session writes. D1's end-to-end check is the only measure this round takes, on one pull request.
