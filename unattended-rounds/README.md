# Unattended rounds

## Summary

This initiative makes the round the workstation's basic unit of work: one design, approved at one
sitting with Geoff, covering one to six passes that run back to back without him. It also cuts the
planning misses that stop a run.
Success is a round where every pass is merged, waiting on a call in a close packet, or parked with
one question when Geoff returns 12 to 24 hours later.

## Motivation

On 2026-11-11 Geoff asked to do detailed design work and come back 12 to 24 hours later to a
finished round. The job timelines show why that does not happen today. The median job's longest
working block is 1.1 hours. Sessions sat idle after a reply for 1,087 hours, waited on an approval
for 232, and waited on the weekly usage limit for 194. A session with nothing approved to start
next has nothing to do, and one stop holds everything behind it.

Planning misses cause many of the stops. 89 of the 668 pull requests merged since 2026-10-10
recorded about 220 misses. The three largest classes are a mechanism assumed and never probed, an
incomplete file list, and a permission block.

## Goals

- A round design approved at one sitting launches every pass in it with no further word from Geoff.
- A stop in one pass parks that pass. Every pass that shares no file with it still runs.
- A round reaches Geoff as a round report with the usage it spent and each planned-against-actual
  figure, plus a close packet where a call remains and one stop packet for each parked pass.
- The Approval Queue groups a round's packets and digest lines, and shows the round report.
- A wrong design is caught at the sitting or in its first pass, before a later pass builds on it.
- The three largest planning-miss classes each fall by half, counted per 100 merged pull requests.

## Non-goals

- Removing or weakening the Approval Queue, a review, a guard, or Geoff's approval of a design or
  an `auth-data` change.
- A standing model or effort change, which belongs to `monthly-model-review`.
- Faster gates and CI, which belong to `dev-speed`.
- Spending past the Max plan's weekly allowance, unless Geoff rules otherwise in the design.
- A file change during the `workstation-refinement` freeze that Geoff has not approved as an
  exception.

## Where the work lives

- `workstation`: `pass-core` and its references, the `approval-packet` skill, the `cairn-pass`
  adapter, the pass section of `CLAUDE.md`, `claude-launch-guard`, `claude-worktree-busy`,
  `pass-report`, and `unattended-work-guards.md`. The build changes no setting.
- `approval-queue`: the approve check, the fact file's fields, the `merge`, `land`, `report`, and
  `restart` commands, and the pages.
- `standards`: the `brainstorming` skill.
- The record stays on the local branch `unattended-rounds` and is not pushed, because it cites the
  unpublished `workstation-refinement` record. Queue commands for it run with
  `APPROVAL_QUEUE_PROJECTS=~/.local/state/unattended-rounds/projects`.

## Records

- Research: `research/2026-11-11-evidence.md` holds the timeline figures, the denial log, the
  planning-miss counts, the probes, and the Anthropic pages the design draws on.
- Design: `specs/2026-11-11-unattended-rounds-design.md`.
- Build design: `specs/2026-11-11-unattended-rounds-build-design.md`. Three rounds of one repo
  each, ten passes: `ur-queue`, `ur-ws`, and `ur-std`.
- 2026-11-11: proposed. The design went to Geoff's queue and was withdrawn the same day, after he
  asked whether the Approval Queue should work in rounds.
- 2026-11-11: Geoff ruled the round the workstation's basic unit, of one to six passes, unless
  Anthropic's guidance argued against it. The guidance check found no argument against it.
- 2026-11-11: Geoff asked whether brainstorming and planning were adjusted for the longer unit. The
  design gained four rules for a round's design step, and went back to his queue.
- 2026-11-11: Geoff asked whether `standards:brainstorming` follows Anthropic's guidance. The
  evidence file holds the read: four gaps, three of them for the build design.
- 2026-11-11: Geoff said in chat that the freeze can lift for this overhaul and that this month's
  extra credits go to it. The waiting packet recommended a pilot and no credits, so it was
  withdrawn. The design now records both rulings as decided for him, drops the pilot and its kit
  file, and names a build design as the next packet. His approval in the queue confirms the
  rulings.
- 2026-11-11: Geoff approved the design in the queue (packet `20261111T161236-2074074`), with no
  notes. He took every recommendation. A later round on a low weekly allowance finishes the pass in
  flight, starts nothing new, and waits for the reset. The overhaul runs both trials, Fable 5.2 at
  `high` for design and planning and a `/goal` line on each prompt, and reports them to the
  December model review. The freeze lifts for this overhaul alone, and the overhaul keeps going on
  this month's usage credits, capped by the monthly spend limit he sets.
- 2026-11-11: the queue had refused his approve many times before it took one. The evidence file
  holds the cause, and he asked for the fix as part of the overhaul.
- 2026-11-11: the build design was written and read by a fresh builder check. Before it was sent,
  Geoff said in chat that his weekly reset and two Fable resets replace the usage credits, that the
  week should run close to 100 percent before he resets, and that Fable 5.2 goes wherever it makes
  a real difference. The build design carries each statement as a ruling decided for him. Its three
  rounds start together, and it has no 85 percent stop for the overhaul.
- 2026-11-11: a second fresh reader read the rewritten build design. It puts three decisions to
  Geoff: what a one-pass round takes from the design rules, who writes the launch guard change,
  and whether the queue's approve and merge code merges itself.
- 2026-11-12: all ten passes are merged. Workstation#233 and #234 merged at 18:04Z on Geoff's
  approve of close packet 2, and the three conductors' reports say `Round state: ended`. His first
  approve of that packet was lost with no sign on the page (approval-queue backlog #71, fix
  deferred by him).
- 2026-11-12: the design sitting ended with three designs, and Geoff approved all three in the
  queue with no notes and every recommended answer: the queue rebuild (round `aq-rewrite`, six
  passes; a merged pull request stays on the front page seven days), the workstation rules (round
  `ws-documents`, four passes; he ruled it part of the overhaul the freeze was lifted for), and
  GitHub-flavored technical writing in Survey (round `survey-docs`, one pass). The approved files
  are under `specs/2026-11-12-*`, at commit 5f8f0e5 of this branch. The mockup he called solid is
  in `mockup/queue-mock/`.
- **Next:** after the weekly usage reset on 2026-11-13, 11pm Anchorage time, launch the two
  conductors from `plans/aq-rewrite-conductor-prompt.txt` and
  `plans/ws-documents-conductor-prompt.txt`. The workstation round's first pass fixes backlog #75
  and the queue round's first pass waits for it. The Survey pass starts from
  `plans/sv-s1-planning-prompt.txt` only after the queue switch has merged.
- **Still owed:** earlier revisions of standards#20's PR body hold a pasted transcript line with a
  folder name from `~/.claude`, and Geoff has not said whether to delete them. The round reports'
  counts in the evidence file are unchecked against the pull requests.
