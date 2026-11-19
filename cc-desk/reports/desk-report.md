# The Desk and skills round has landed four of its six passes

The Desk and skills round builds the desk session that `cc-desk` opens, the two skills, the
page's report pages, and the check's repairs, then rehearses one run with nobody tending it.
Its first pass, which widens the records, landed as pull request 17. The page pass landed as pull request 19, the skills pass as pull request 18, and the desk pass as pull request 20. The check's repairs, pass 5, is planning. Nothing waits for Geoff yet.

## What waits for Geoff

Nothing yet.

## What behaves differently now

[Pull request 17](https://github.com/glw907/cc-desk/pull/17) gives questions, rulings, reports, rounds, and stops the fields the desk and the page show. The check keeps a log, and the new `brief` verb prints what waits, ordered by the planned minutes each question holds up. The new verbs are `brief`, `report add`, `report read`, `question add`, and `ruling record --replaces`.

[Pull request 19](https://github.com/glw907/cc-desk/pull/19) makes the status page show reports to read, each with one "Mark as read" form, and a waiting round's design. It also shows what each check chose and each pass's permission prompts and refused commands. The page's unit can write to the state folder and nothing else. Until the binary is installed from main after pass 5, a click on "Mark as read" fails, because the installed binary has no `report` verb.

[Pull request 18](https://github.com/glw907/cc-desk/pull/18) adds the two skills, `cc-desk` for the desk session and `cc-desk-work` for every session cc-desk launches, and `docs/guide.md`. The three launch prompts now name `cc-desk-work` in place of the Approval Queue rules. Live sessions given the desk skill opened correctly on all three test cases. The skills describe the desk that pass 3 builds, so the guide carries a caveat line until pass 3 proves each claim.

[Pull request 20](https://github.com/glw907/cc-desk/pull/20) makes `cc-desk` open the desk: an Opus session at high effort, on the brief, with no permission prompt. A typed answer there becomes a ruling, a replacement before a pass starts takes effect, and a merge answer is carried out by the check. A replaced pass whose session had already finished now relaunches; the live run found that gap. It was proven live in the scratch repo.

## What went wrong

Nothing yet. One judgment at the start: `claude-worktree-busy` on the main checkout exited 1
on the interactive session that launched this conductor. That session ran only a watch for the
first planner, so the conductor didn't count it as a stop.

A stray job named `close-desk-records-round` appeared in the cc-desk checkout at 11:46 as a
failed launch with no prompt. Auto mode refused the conductor's `claude stop` on it. Geoff then
told the conductor to stop it, and the second `claude stop` ran: `stopped d5647ebf`.

Pass 1 made nine method calls through the advisor, none of them for Geoff, and had one planning miss: `[mechanism]` the plan said every refusal exits 1, and the code exits 2. Its first body read `Calls: 9 under Decisions` and held no test output, so the conductor sent it back for a body fix before landing.

Pass 2 parked at planning: its plan priced 170 minutes against 75, past twice the estimate. The planner found work the round hadn't priced: the `question add` and `report add` command lines pass 1 left to it, three new fixture folders, and a live script that checks three fresh sessions. The conductor asked at about 14:25, and Geoff's answer came just before the ruling's commit at 15:01: "Raise to 105 (Recommended)". The ruling is under `## Rulings` in the pass's plan, and the executor launched as planned. This is an `[estimate]` planning miss.

Pass 4 had two planning misses: `[mechanism]` the plan named an old shape for Kit's route matchers, and `[check]` its bundle check matched comment text. Its first body left out the gate check's exact wording and the gate's output, and its misses had no tags. The conductor sent it back once for a body fix, as it had with pass 1. The pass made no calls for Geoff and had no red CI run.

Pass 2's closing review escalated one point: the skills and the guide state behaviors that only pass 3 builds. The executor kept them, with a caveat line and `docs/follow-ups/desk-skills-review-notes.md` listing each claim for pass 3. A review short of accept can't land on its own, so the conductor asked Geoff at 15:56. He answered "Land it (Recommended)", and the pass landed at 18:07. The two hours of waiting held up pass 3. Pass 3 parked at planning: its plan priced 255 minutes against 100. The planner priced every clause of done items 3 to 5, and a plan review found six places where the code doesn't work as the plan first said, which raised the count from 210. The conductor asked at about 19:05, and Geoff's answer came just before the ruling's commit at 20:50: "Raise to 140 (Recommended)". The ruling is under `## Rulings` in the pass's plan. This is an `[estimate]` planning miss.

After PR 18, Geoff gave two standing answers so later stops don't wait on him: 26 lets a review that escalates land when the advisor settled each point, and 27 approves ahead of time the tag, dotfiles, install, and real-release steps. Both are in the round plan at `81afc1d`.

Both estimate stops were preventable, as Geoff pointed out. The three stops cost about 58, 131, and 120 minutes of the round's clock. The round plan priced each pass from its outline, and every planner that priced the evidence clause by clause came out about twice as high (pass 1: 120 against 209; pass 2: 75 against 170; pass 4: 90 against 170; pass 3: 100 against 255). Pass 1's path showed the pattern before passes 2 and 3 were planned, and the conductor didn't ask for a standing answer then. Pass 2's review escalation was foreseeable too, since the design orders the skills before the desk they describe. Geoff then gave standing answer 28: the conductor raises an estimate itself when the plan parks only over its estimate and its scope matches the design. `docs/follow-ups/round-estimates-priced-from-evidence.md` (at `af5ea47`) proposes the fix in cc-desk itself, an estimate rule on the release and a miss signal in the brief after a round's first pass, and in `pass-core`'s round and planner references.

A Fable review of the failures (kept with the round's records) disagrees with the conductor on the first cause. In nine PRs with both figures, plan paths added to 1,405 minutes and measured time to 355, so the round's estimates were near the truth and the plan paths were the wrong number to stop on. It traces the stops to `round.md` "Parking at planning", to the landing test reading the review's word in place of open findings and calls, and to the round plan replacing "starts once that pass's PR is ready, whatever its verdict". It also finds that cc-desk as built would repeat them: `pass ready` has no line for an `escalate` verdict, a merge question holds every pass behind it, and standing answers have no record.

Pass 3 had five planning misses besides its estimate: three `[mechanism]` (the start tests' file, a finished session's relaunch, and the branch the merge fixture pushes), one `[stale-fact]` (the link handler refuses when `cc-desk` is not on `PATH`), and one `[ambiguous]`. Auto mode refused one `rm` of a file in the real state folder during cleanup, and the file was left alone. Its first review read `fix`, and a fresh read accepted the folded branch.

Pass 2 also had two `[file-list]` misses: the CI workflow wasn't in task 3's file list, and the review-notes follow-up was new at close.

## What it cost

| Pass | Planned minutes | Taken minutes |
| --- | --- | --- |
| 1, the records | 120 | 107 |
| 2, the skills | 75, raised to 105 by Geoff | about 140 to ready, planning included, then about 130 waiting for Geoff |
| 3, the desk | 100, raised to 140 by Geoff (plan path 255) | about 144 to ready, then landed at once |
| 4, the page | 90 (plan path 170) | about 90, planning included |

Weekly usage before the round: 5 percent, 8 percent after three passes, and 10 percent after four, with the reset on Nov 20 at 11 pm Alaska time.

## What is left for later

- `designed-round-with-no-questions-reads-nothing.md`, from pass 1.
- `desk-fixture-connection-dropped.md`, new from pass 4, and `blocked-session-reads-as-unreadable-stop.md`, reworded by pass 4.
- `desk-skills-review-notes.md`, new from pass 2, for pass 3 to clear.
- From pass 3: `desk-open-review-notes.md`, `closed-pass-leaves-its-worktree.md`, `close-answer-failed-stop-can-be-replaced.md`, and `exec-failure-after-register-leaves-entry.md`.
- `round-estimates-priced-from-evidence.md`, from the conductor, for the Move design.
