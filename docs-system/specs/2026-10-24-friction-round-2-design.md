# Friction round 2: the last of the extend friction log

Status: drafted 2026-10-24 for Geoff's approval. Initiative: `docs-system`. Input: the pilot and
batch 2 and 3 friction records (`research/2026-10-22-extend-blueprints-pilot-friction.md`,
`research/2026-10-22-extend-blueprints-batch-2-friction.md`) and the backlogs they filed.

## Brief

Approving this clears the rest of the extend friction log from the tooling repos before the next
cairn docs pass. It is two passes in two repos. A drafter pass lets each page in a run move
through its stages on its own, and a workstation pass fixes how fact-check findings are saved,
`ci-green`'s red on a held run, and the missing checks for word sweeps. With drafter-batch-friction
running now and approval-queue's two passes taking every approval-queue item, nothing in the log is
left without an owner.

### What changes

- In a multi-page `drafter page` run, a page whose result is back goes on to its next stage at
  once. Today it waits for the slowest page in the run, as Content model's redraft waited 79
  minutes on the sidebar's draft (drafter #82).
- The fact-checker agent writes its findings array to the path the dispatch names, so a session
  stops parsing transcripts to save it (workstation #31).
- `ci-green` reports a run held for a bot-pushed commit as held, not red, and prints the command
  that releases it (workstation #32).
- `tellgrader` warns on the empty "own" (Survey #1) and on the dangling remnant a scripted removal
  leaves, such as "no X of its." (Survey #2).
- A short word-sweep method page holds the two checks a sweep needs before any gate: the remnant
  scan, and a `git diff --numstat` that lists every file whose added and deleted counts differ
  (record item 61).
- The batch author prompt gets its four fixes (record items 56 to 59).

### If you approve

1. The planning session merges the initiatives PR carrying this design, closes drafter #42 and #43
   as won't-do, and files the three items no backlog holds yet.
2. It plans the workstation pass and hands it to `conductor-dotfiles`. It plans the drafter pass
   and hands it to `conductor-drafter`, which launches it after drafter-batch-friction merges.
3. Each pass comes back to you as one packet with its PR. You have no pre-flight steps.

### Decide: Let the fact-checker write one file?

The fact-checker agent is read-only by rule: it never runs a command that writes. Its findings come
back inside the handback the harness wraps, and one run in eight added prose after the array, so
saving it verbatim has meant a transcript parser (pilot item 23, batch 2 item 18). The agent could
instead write its array to one path the dispatch names, under the findings store, and check that it
parses. Every other write stays forbidden, and a dispatch that names no path gets today's reply.

Source: `~/.dotfiles/claude/.claude/agents/fact-checker.md`; the batch session's
`save_findings.py` in `research/2026-10-23-extend-blueprints-batch-2-handoff/tools/`.

- Let it write that one file, checked with `jq` before it hands back (recommended)
- Keep it read-only, and ship `save_findings.py` as a workstation tool that parses the transcript

### Standing answers

The two runs decide four things without you, each set here.

- The drafter pass stops at 400 path minutes and the workstation pass at 660; below that each
  launches and runs without you.
- Neither pass spends API credit. #82 is proven against the fake batch server. Its live run is the
  next cairn docs pass's first multi-page `drafter page`, and the drafter STATUS says to watch
  that run's first stage times.
- Both passes are `runner`, so each comes to you as a packet: the workstation pass for the agent
  and gate tools, the drafter pass for its one line in the blueprint skill (#31's save rule).
- A review finding that a smaller change can satisfy takes it and lists it in the PR's
  `## Decisions`. Only a finding that needs a different design stops.

## The drafter pass (#82)

`loop` in `internal/pipeline/pipeline.go` runs waves. It advances every running page with no open
intent, submits every staged request, then calls `await` in `internal/pipeline/money.go`, which
returns only when every batch in flight has ended and been handled. A fast page's next stage waits
for the slowest.

The change: `await` returns as soon as it has handled at least one ended batch, with the rest still
in flight. `loop` then advances only the pages with no open intent, which already skips a page
whose batch is in flight, submits what they stage, and awaits again. When no batch has ended, it
sleeps as today. `submitUnit`'s reserve-and-record order, the ledger, the intents, and resume stay
as they are. A resumed run reattaches to its in-flight batches and runs the same loop.

What could break: a page's gate runs while a sibling's draft is in the tree half a stage behind.
The sibling-red hold (#23, `internal/pipeline/check.go`) already holds a page whose gate red names
another page in the run, and the pass adds a test with one page gating while a sibling's draft is
written. Sync mode sends one request at a time and is unchanged.

The check: a fake-server test with two pages, where page A's batch ends at once and page B's ends
late. Page A's second stage is submitted before page B's first batch ends, and the record's stage
times show it. A resume mid-run, with one page a stage ahead, finishes both.

The pass also carries #31's one line in `claude/.claude/skills/blueprint/SKILL.md` (see the
workstation pass), which is why it is `runner`. Under the read-only answer it carries none.

Out of scope: #42 and #43, closed. #29 (refuse a resume on another build) stays in the backlog.

## The workstation pass

Files in `~/.dotfiles` unless named.

- **#31.** `claude/.claude/agents/fact-checker.md`: when the dispatch names a findings path, the
  agent writes its array there with one heredoc, runs `jq -e 'type == "array"'` on it, and hands
  back the path and the verdict counts. That write is its only one. With no path, the reply is the
  array, as today. The blueprint skill's "Save the array verbatim to ..." line in drafter's
  `SKILL.md` becomes "name that path in the dispatch; the agent writes it there". That line rides
  in the drafter pass's PR, at approval-queue-ea's request (2026-10-24), and touches none of the
  lines approval-queue's pass 1 edits in the same file; whichever merges second rebases.
  Under the other answer, the pass ships `save_findings.py` instead, rewritten as a
  `python3 -I` tool in `bin/.local/bin/` that takes the findings path as an argument.
- **#32.** `bin/.local/bin/ci-green` and `ci-green-lib.mjs`: a run whose status is
  `action_required` reads as held, never red. The output names the run and prints
  `gh api -X POST repos/<owner>/<repo>/actions/runs/<id>/approve`. It takes a new exit code, 4
  (`held`), since a held run never clears by waiting: pending's 75 would loop until the
  60-minute unavailable verdict. A red elsewhere on the commit still wins, as red wins over
  pending today.
- **Survey #1 and #2.** `tellgrader` (`claude/.claude/skills/writing-voice/evals/tellgrader`)
  gains two warn-level lexical checks: a possessive followed by "own" (`'s own`, `its own`, `their
  own`), and "of" or "on", then "its" or "their", then punctuation or a function word. Each
  reports the line, and neither fails a gate. `writing-voice.md` adds the empty "own" to its tells
  and says a contrast keeps it ("declares its own role names, or uses the default pair"). The
  Survey backlog items close with the PR number.
- **Record item 61.** A word-sweep method page in `claude/.claude/docs/`, placed by the
  `claude-infra` skill's rules, with the two pre-gate checks and the PR #137 slice method. A cairn
  backlog item asks `gate-tier.mjs` to refuse exit 0 when it prints no legs, since the emptied file
  passed the fast lane silently.
- **Record items 56 to 59.** `research/2026-10-23-extend-blueprints-batch-2-handoff/author-template.txt`
  in initiatives: "a fence with no `Code:` bullet" for "bare code fences", which of "raise the
  fixture" and a concrete snippet wins (the snippet, with the fixture raised as a note), the
  retired-name warning generated per page, and the credential line naming its facts by plan. The
  next docs pass copies this template.

The check: `tellgrader --register docs` warns on a scratch copy of a sent-back blueprint from
before cairn-cms PR #137 and on a sentence with a remnant, and passes the contrast example.
`ci-green` on a fixture of an `action_required` run prints held and the command. A fact-checker
dispatch with a path writes a file that `jq` accepts.

## Later

- #29, a resume refused on another build, if a run is ever resumed across an install.
- A `tellgrader` error level for the remnant scan, once its false-positive rate is known.
