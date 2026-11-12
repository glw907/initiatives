# Rewrite the rules for what a session sends you to read

You are asked to approve a design for the workstation. It rewrites the rules a session follows when it puts something in front of you. Under the design, the session that did the work writes one document, checks it, and sends it to the rebuilt Approval Queue. The fact file, the separate writer, and the 3,800-word writing brief all go away.

If you approve, the work starts after the weekly usage reset on 2026-11-13. A short pass goes first. It fixes the busy check that a conductor runs before each launch, and it merges by itself with no packet for you. Three more passes run after the Approval Queue's rebuild has landed its fifth pass. Each of the three leaves its pull request open. You then get one close packet, in the old queue, that holds those three pull requests and the queue's switch, which is one pull request in the queue's repo. Your approve of that packet merges all four and switches the rules and the queue in one step. If you send this design back, nothing runs, and I revise it from your notes.

The design asks you two questions, and I recommend the first option in each. The first is whether this work is part of the overhaul you lifted the freeze for. The second is who adds the `Evidence:` line to the nine plans that the launch guard now refuses. Six more calls are already settled in the design. Two of them record your answers from 2026-11-12, and one reverses a ruling of yours from 2026-10-21. They are listed under "Decided for you".

## Deep dive

What is wrong with the rules today, what the design puts in their place, how the four passes run, and how the switch can fail.

### What is wrong today

The rules for sending you something are spread over the `approval-packet` skill, a 3,800-word writing brief that Survey owns, `pass-core` and four of its reference files, and a dozen other skills that each repeat a piece. A session fills in a fact file. A second writer turns the fact file into text under fixed headings. You called the resulting pages sloppy, and you suspected that the fixed forms cause the stilted writing.

### What replaces them

One skill, `approval-packet`, holds the whole job. It keeps its name and is rewritten to about 900 words. It says when to send you something, how to write it, how to check it, how to send it, and what to do with your answer. Beside it sit two model documents: the close packet and the round report that you accepted on 2026-11-12. The skill tells a session to imitate them.

One file, `written-for-people.md`, holds the writing process for anything a person reads. It is about 400 words and has four steps:

1. Write from the plain-language standard and the two model documents. The file also holds your corrections of 2026-11-12: no made-up ids, a plain question, a title that never counts, and an opening that is the whole page made small.
2. Run Vale.
3. Run `tellgrader --register docs` and fix every finding and warning.
4. Give the page, alone, to a reader with no context. The reader says what is being asked and what happens for each answer, and lists every term or claim it could not explain from the page.

Each kind of writing gets some of the steps:

| Writing | Steps |
| --- | --- |
| A queue document, a round report, a string on a queue page | All four |
| A pull request's opening, STATUS, a hand-over's last message | 1 to 3, and step 4 when it asks you for something |
| A reply or a question in chat | Step 1 |
| Writing that a repo already has rules for, such as cairn's documentation or a site's pages and posts | Those rules, unchanged |
| Any other README, doc page, pull request, issue, or release note in a public repo | 1 to 3, and step 4 for a page a visitor lands on first |
| A plan, a launch prompt, a note between sessions, or any other file only a session reads | None, in a public repo too |

A round report changes too. Its opening says whether anything waits for you. Then it says what behaves differently, what went wrong, what it cost, and what is left for later.

`pass-core` and its reference files lose their copies of the packet rules and point to the skill. Stale pieces are removed: the mentions of a `dotfiles-pass` adapter that does not exist, and the settings lines of finished initiatives. Four backlog items about the round rules are fixed in the same work.

### The four passes

All four passes run in the workstation repo. The longest chain is 410 minutes.

| Pass | What it produces | Minutes | Waits for |
| --- | --- | --- | --- |
| The busy-check fix | `claude-worktree-busy` no longer counts the session that runs it | 30 | Nothing. The first pass of the queue rebuild waits for it |
| The skill pass | The skill, its two model documents, the writing process, and the router row that points to it | 120 | The busy-check fix and the fifth pass of the queue rebuild |
| The `pass-core` pass | `pass-core` and its reference files | 120 | The skill pass |
| The settings pass | Settings, hooks, scripts, pointers, and removals | 140 | The `pass-core` pass |

The busy-check fix goes first because both conductors, this round's and the queue rebuild's, run `claude-worktree-busy` before every launch. Today the command counts the session that runs it and exits 1 every time (workstation backlog #75). After the fix it exits 0 when no other session or process is in the path, and it still exits 1 and names a second session that is there. Both conductors start from this record's directory, outside either checkout, so the fault does not catch the launch of the fix itself. The fix has nothing for you to decide. It lands with `approval-queue land` after its gate run and an accepted whole-branch review.

The other three passes are held back. From the skill pass on, each pass's branch is cut from the one before it, and no pull request merges before the close packet. A skill that describes the new queue must not be live before the new queue is. The skill pass waits for the fifth pass of the queue rebuild because the new skill names commands that pass builds.

The skill pass includes an end-to-end check. A fresh `sonnet` session gets the skill and the diff of one merged pull request, workstation #231, and nothing else. It writes a close document. A second fresh reader gets the document alone and writes down the question and what each option causes. The closing reviewer compares that answer with the pull request. The executor edits neither the document nor the reader's answer.

The settings pass edits `settings.json` and the launch guard's neighbors, which you asked to see before they merge. The close packet is where you see them. The round adds no permission rule. The settings pass also takes two backlog items: `pass-report` names any repo whose listing of merged pull requests came back full at 300 (#76), and `docs/STATUS.md` is cut from 140 lines to 60 or fewer (#73). Backlog #82, a launch guard that tells a plan from other files, is left out. The guard changed on 2026-11-12, and a second change waits until the nine refused plans are sorted.

### The switch

After your approve of the close packet, the conductor does these steps in order. It stops at the first step that fails and tells you in chat.

1. It checks that the old queue has no undecided item except this packet, and no session waiting on one.
2. It merges the three workstation pull requests in order, then the queue's switch.
3. It pulls `~/.dotfiles` and `~/Projects/approval-queue`.
4. It runs `approval-queue restart`, which archives the old state only after the new server answers.
5. It checks the round report and sends it as the new queue's first document.

The conductor switches pavilion. On thinkpad-x1, the next session to start pulls both repos and runs `approval-queue restart`, because the workstation's STATUS will tell it to. You type nothing on either host.

### What the round leaves alone

Survey still ships `approval-brief.md`, and this round cannot delete a file that another repo owns. The workstation stops reading its copy at the switch, and a backlog item in Survey asks for the file's removal at the next release. Skills in five other repos (cairn-cms, dubplate, poplar, ecxc-ski, and servers) mention the old packet commands. Each repo gets a backlog item and no edit. An old command answers with one line that names the `approval-packet` skill.

### How the design was reviewed

A fresh Opus reader read this design and the queue design against the queue's code and the workstation's skills. It returned fifteen findings. Each was folded in as Claude's call, and none needed your answer.

## Your calls

Each question has two options, and the first option is the recommended one in both.

### Is this round part of the overhaul the freeze was lifted for?

Context: The workstation is under a freeze until 2026-12-11 that allows removals only. On 2026-11-11 you lifted it "for this overhaul alone". This round removes more than it adds, but it does add the rewritten skill, two model documents, one writing-process file, and one bug fix. I found no written definition of what the overhaul covers.

Risk: If you answer yes, the round adds files during a freeze on the strength of a ruling that does not name it. If you answer no, both switches hold until 2026-12-11. The queue round still builds its first five passes and then waits, and you keep the old queue and the old packets for a month.

Recommendation: Yes. The round finishes the overhaul. It runs once the queue round's fifth pass lands, and both switch together.

### Who adds the `Evidence:` line to the nine plans the launch guard now refuses?

Context: Nine plans in other repos lack only that line. Each belongs to a pass that has not run yet.

Risk: If each plan waits for its next launch, the guard refuses that launch once, and the session must add the line before it launches. If this round adds all nine now, it edits plans in six repos other than the workstation, and that makes it a cross-repo round.

Recommendation: The session that next launches each plan adds the line. The guard's refusal names the missing line, and nothing changes in the six repos until then.

## Decided for you

### Does one writing process cover everything written for you?

Context: The design puts the four steps in one short file, `written-for-people.md`, and the file says which steps each kind of writing gets. The `approval-packet` skill points to the file and carries no copy.

Why: You asked for this in chat on 2026-11-12, and answered "Please do." when asked whether to add it. If the steps stayed inside the packet skill, a pull request's opening, STATUS, and a chat question would have no written process.

### Do plans and launch prompts in a public repo get the writing checks?

Context: No. A plan or a launch prompt is written for the session that runs it, and it gets none of the four steps, in a public repo too. A README, a doc page, a pull request, an issue, and a release note in a public repo get the checks either way. Ten of your repos are public, the workstation and the queue among them.

Why: On 2026-11-12 you said that a file only a session reads can be written however works, and that the process also applies to items in public repos that might have human readers. Asked whether plans and launch prompts there get the checks, with "no" recommended, you answered "That's correct."

### Who checks a document before you see it?

Context: The session that did the work writes the document. A fresh `sonnet` reader with no context then says what is being asked and what it could not follow. The reader runs twice at most. This replaces the separate writer that drafts from a fact file today.

Why: The separate writer and its fact file are the form you suspected of causing the stilted writing.

### Does a packet still put background before the summary?

Context: No. The decision comes first. The house departure of 2026-10-21, background before the summary, is withdrawn. This reverses a ruling of yours, so say so in a note if you want it kept.

Why: The opening you accepted on 2026-11-12 puts the decision first. If the departure stayed, the two model documents would need rewriting against it.

### What happens if the new queue won't start at the switch?

Context: The conductor reverts all four merges, newest first, pulls both repos, and tells you in chat. `approval-queue restart` keeps the old server and the old state, so the old queue keeps working with the old skills.

Why: If the conductor left the merges in place and only reported, the skills would describe a queue that is not running.

### Where does the fix to the busy check go?

Context: Into this round, as a short pass that goes first and merges without a packet. `claude-worktree-busy` stops counting the session that runs it, so a conductor's check before each launch is exact. Both conductors start outside the checkouts until the fix lands.

Why: The initiative record says workstation backlog #75 runs before the next round with a conductor. A separate round before these two would mean one more design packet for you, for a fix of a few lines.

## Not checked

- No source measures whether a model document changes what a session writes. The skill pass's end-to-end check is the only measure this round takes, and it covers one pull request.
- Nobody has checked whether the old queue accepts one packet that names pull requests of two repos. The conductor checks before its first launch and plans two packets if the old queue does not.
- Vale has not read this design, because its house config does not cover this folder. `tellgrader` under the docs register reports nothing.
- The edits made after the fresh reader's review were not read by a second fresh reader. The single writing process and the public-repo rule are among them.
