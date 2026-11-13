---
kind: report
---

# Approvals are now one document each, and the new queue is live

Both machines' rules now hand work to you as one written document, and the new Approval Queue that shows those documents has replaced the old one on port 7907. Your approval of the close packet merged all four pull requests in order, both repos are pulled, and `approval-queue restart` ran clean on pavilion. The old queue's files are saved in `archive-2026-11.tar.gz`. Nothing is waiting for you. thinkpad-x1 still runs the old queue until its next session pulls both repos and runs `approval-queue restart`.

## What behaves differently now

**Every hand-over is a document you read.** A session that needs your decision writes one Markdown document, runs `approval-queue check` on it, and sends it with `approval-queue send`. A close, a design, a stopped pass, and a round report are four kinds of that one document. The fact file, the separate writer, and the old `packet` command are gone. The `approval-packet` skill now describes the new steps, and its two models are the accepted close packet and the accepted round report.

**Writing for you follows a stated process.** The new `written-for-people.md` sets four steps for every page you read: write from the published standards, run Vale, run `tellgrader`, and give the page to a reader who has no context. Vale now reads queue documents and knows your name and the two words the models use.

**The pass rules read one way.** `pass-core` closes a pass with a document instead of a packet, counts a wait as the time from sending a document to your answer, and keeps a round's resume line in STATUS. The executor loads a marked part of the skill, so it stays under its word limit. `claude-pass-load` counts the new skill where it counted the old brief.

**Waits and reports come from the new queue's log.** `pass-report` reads the archive, says so when it cannot read it, and counts one wait for each pull request in each round of a document.

**The queue's app was swapped.** The old app, its bash command, and their tests are deleted. The seven retired subcommands print one line that names the skill and exit 1. `restart` refuses while an old item is undecided, and it archives the old state only after the new server answers.

**The live model is tracked.** The live settings chose `opus` at `high` effort, which you kept when you approved the close packet. The tracked file now says the same, so `claude-tooling-sync verify` no longer flags the model.

## What went wrong

**A planner launched while the checkout was busy.** I started the planner for the reports pass once while `claude-worktree-busy` exited 1. My command chain didn't stop on the exit code. The cause was an uncommitted `bluefin/Brewfile` edit made by someone else, not a session. The planner ran for seconds, changed nothing, and I stopped it. After you said you were done, the check exited 0 and I relaunched it. I now gate each launch on that exit code.

**The planner for the writing pass stopped early and was relaunched once.** Nothing was lost.

**The queue's temporary space filled.** Other sessions had left directories in `/tmp`, so every command failed for a while. Another session cleared them. I wrote nothing large there, and the gates ran with `TMPDIR` on the disk volume. One test that checks your home path has to run under `/tmp`, so it ran there alone and passed.

**Plans were wrong 9 times across the three workstation passes (2, 5, and 2).** The design for the writing pass left out four files and left one item's meaning open. The design for the pass-rules pass named a vendored file this repo can't edit, gave no place for a merge step between two pull requests, put a waiting question in a document that takes no answer, and had two stale figures. The reports pass found the design wrong about an adapter that already existed, and its rehearsal port was taken. None stopped a pass.

The reports pull request merged with four review notes open, among them a late `undo` that drops one wait and three Python files `ruff format` would change. They are in its description.

## What it cost

| Pass | Planned (min) | Taken (min) |
| --- | --- | --- |
| Rules and tooling base | 33 | 21 |
| Writing process and Vale | 137 | 24 |
| Pass rules and skill | 190 | 24 |
| Reports and the queue's log | 155 | not measured |
| Queue switch pass (A6) | 75 | about 30 on the path |

The five earlier passes on the new queue's app (A1 to A5) were planned at 580 minutes. A4 stopped once and A5 wasn't measured, so I give no total. Weekly usage went from 63% to 77% across both rounds, and Fable usage from 4% to 10%. The week resets tonight at 11 PM Anchorage time.

## What is left for later

- Survey's backlog item 8: remove the retired `writing/approval-brief.md` and fix the vendored `commit-and-pr.md` that still names it, at Survey's next release. You chose to leave both there.
- Backlog 86: a `## Before merge` step has no place between two pull requests of one document.
- Backlog 87: the vendored `survey/SKILL.md` still runs `approval-queue merge --premerge-done`.
- Queue backlog 73 to 76: `merge` and `## Before merge`, four accessibility points on the refused-answer path, a note that loses its place across a return, and look changes that need your approval.
- Live `autoMode` still differs from the tracked file. The live copy has the old packet wording and the cairn run-sheet lines other sessions own. `claude-tooling-sync apply` brings in the new wording and removes those lines, so it waits for a moment when that is safe.
- A few mentions of "packet" remain in the conductor's STATUS, `mail-tend`, and `claude/.claude/CLAUDE.md`.
- The finished A5 session (4957d346) is still listed, because ending it needs a person.

To switch thinkpad-x1, pull `~/.dotfiles` and `~/Projects/approval-queue`, then run `approval-queue restart`.

Resume from: ~/Projects/initiatives/.claude/worktrees/unattended-rounds/unattended-rounds/plans/ws-documents-conductor-prompt.txt
