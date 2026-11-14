---
kind: report
---

# The runbook is now twelve system pages, and the gate pass has not started

Pass 1 of round `runbook-map` is merged. The household runbook is split into twelve system pages behind a README table of contents, and `EMERGENCY.md` now renders from those pages. Pass 2, the gate leg that keeps the layout, has not launched, because an interactive session is open in the `household-it` checkout and the busy check refuses to launch there. Nothing is waiting on a decision from Geoff. The round needs its conductor relaunched once that session closes.

## What is waiting

No document is open. One condition holds the round. `claude-worktree-busy` exits 1 for `~/Projects/household-it` because an interactive session named `household-it-bd` has its working directory there. Standing answer 6 ends launches in a repo while that holds. Relaunch `conductor-household-it` from the prompt named at the end of this report after that session closes. The conductor then reads the weekly usage again before it starts pass 2.

## What behaves differently now

The docs in `household-it` are laid out for a second operator and for an agent that has to find an answer fast (glw907/household-it#36, merge `8ad5d05`).

- `docs/runbook.md` is gone. Twelve pages under `docs/systems/` replace it: servers, mail, photos, bookmarks, backups, cloudflare, monitoring, telephony, network, github, proton, and workstations. Each has the same seven headings.
- Every other doc moved into `docs/guides/`, `docs/prompts/`, `docs/records/`, or `docs/reference/`, and each shows as a rename in git.
- The README is the table of contents. It has a systems table and an "I need to..." list, and its title is `# Household IT`.
- `EMERGENCY.md` renders from the pages through `scripts/emergency-screens.txt`. Its diff is one line, the sentence that names its source.
- The github, proton, and network pages are stubs that say so and name their backlog item (#67, #68, #69). The telephony page says no dial-tone procedure exists (#51).
- No operating sentence was added or reworded. The line check printed ten lines, and each one is dropped or changed on purpose and listed in the pull request.

The finding test passed: a fresh reader answered all ten questions correctly from the README and at most two more files, except for two questions that took three and were ruled acceptable.

## What went wrong

Planning misses, by tag:

- **[design-gap]** The folder move dropped Claude Code's workspace trust, so the first launch was refused until Geoff accepted the trust prompt at the new path. A design that moves a repo folder carries that step in its pre-flight (initiatives `1f5b58b`).
- **[mechanism]** The finding test's cap of two files after the README didn't fit question 6 (the alert list lives in code) or question 7 (no procedure exists). Each read three files and gave the right answer. The pass stopped, and Geoff ruled that the cap doesn't bind those two (decide document `20261114-011807-5ec2dc`).
- **[mechanism]** `tests/apply.test.sh` reads stdin through its fake `ssh`, so the full gate hangs when its stdin is an open pipe. It hung for about an hour under the background runner. The executor reran it with `< /dev/null` and the gate printed `gate: ok`.
- **[estimate]** The plan's path came to 340 minutes against 270 in the design. It stayed under the park line.

The whole-branch review found three faults: one script defect, one stray sentence, and one incomplete backlog item. One fix round cleared them, and the second read accepted with no open findings.

One loose end belongs to the workstation. `~/.dotfiles/docs/model-review/prompt.txt:67` still points at the old `servers` path for the monthly prompt. That gap predates this round. Pass 3 must fix it before the December model review.

## What it cost

Pass 1 was planned at 270 minutes, and its plan came to 340. Pass 2 is planned at 150. Weekly usage read 81 percent before the first launch and 84 percent after pass 1, against the 85 percent ceiling. The next launch needs a fresh reading, and the figure may sit at or over the ceiling until the Nov 13, 11pm reset.

## What is left for later

Still to do in this round:

- Pass 2, `gate`: the `docs` leg of the gate (`scripts/check-docs.sh`), `docs/contributing.md`, and the rules in `CLAUDE.md`. Its planner prompt is committed.
- Pass 3, `agents`, in the `workstation` repo: the `runbook` skill, which doesn't exist yet, and the fix to the model-review path. It launches only after pass 2 lands, and only if `~/.dotfiles` is free. It sends its own merge packet, with a command block for Geoff to run.
- The laptop's folder move, and the operator pass, which is re-planned against the new pages once its pre-flight items 5 and 7 pass.

Backlog items filed by pass 1:

- #67 to #69: write the github, proton, and network pages.
- #71: fill the remaining "Not written yet" sections on the other pages.
- #72: fix the three `EMERGENCY.md` screen lines that name old paths.
- #73: fix the cross-references and sentences the move left stale.
- #74: retitle the job headings that don't start with a verb.
- #75: carry the link check's "unverifiable by curl" rule into `docs/contributing.md`.
- #70: decide whether the phonebook guide belongs in the phonebook repo.

Not yet filed: the `tests/apply.test.sh` stdin hang. It goes through `standards:log-issue` into the `household-it` backlog once the checkout is free.

Resume from: /var/home/glw907/Projects/initiatives/self-hosting/plans/2026-11-13-runbook-map-conductor-prompt.txt
