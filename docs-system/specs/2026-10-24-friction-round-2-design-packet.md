# Friction round 2 design

The extend docs work logged its friction in three records, and their items went to five backlogs. The drafter-batch-friction pass is running now on drafter's share, and the approval-queue session has taken every approval-queue item across its two passes. This design covers the rest, so the next cairn docs pass starts with the friction log clear in every tooling repo.

It is two passes. The drafter pass lets each page in a multi-page run move on as soon as its own result is back, instead of waiting for the slowest page (#82). It also closes the converter fixes, #42 and #43, as you chose. The workstation pass changes four things. The fact-checker saves its own findings. `ci-green` reports a run held for a bot's commit as held, with the command that releases it. `tellgrader` warns on the empty "own" and on the remnant a scripted sweep leaves. A word-sweep method page holds the pre-gate checks. It also fixes the batch author prompt. Neither pass spends API credit, and both come back to you as packets. One question is open: whether the fact-checker may write the one file that holds its findings. The session recommends yes.

## If you approve
1. [session] Merge the initiatives PR that files this design and its packet, close drafter #42 and #43 as won't-do, and file the three record items no backlog holds.
2. [session] Plan the workstation pass and hand it to conductor-dotfiles.
3. [session] Plan the drafter pass and hand it to conductor-drafter, which launches it after drafter-batch-friction merges.

## Not checked
#82's change is proven only against the fake batch server. Its first live run is the next docs pass's first multi-page `drafter page`, and drafter's STATUS will say to watch its stage times.

## Ask: Let the fact-checker write the one file that holds its findings?
Rule: owner-call
Part: none
Recommended: 1
Reason: Writing the array to a named path removes the transcript parser and the trailing-prose failure, and the agent still never writes anywhere else.
Summary: The fact-checker is read-only by rule, so a session saves its findings by parsing the handback out of a transcript. Letting it write that one file ends the parsing.

Background: The fact-checker agent reads a blueprint or page and returns a JSON array of findings, which the session saves to the approval queue's findings store. The harness wraps the agent's reply, and one run in eight added prose after the array, so the batch session wrote a transcript parser to save it.

Facts: The agent's rule today forbids any command that writes.
- "never run a command that writes. Your final reply is the findings JSON and nothing else" (`~/.dotfiles/claude/.claude/agents/fact-checker.md:13-14`)
- One run in eight appended prose after the array (`research/2026-10-22-extend-blueprints-pilot-friction.md item 23`)
- Saving the array needed a transcript parser (`research/2026-10-23-extend-blueprints-batch-2-handoff/tools/save_findings.py`)

Choices:
- Let it write that file: the dispatch names a path, the agent writes the array there and checks it with jq, and the skill's save line changes in the drafter PR
- Keep it read-only: the pass ships the transcript parser as a workstation tool instead

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-24-friction-round-2-design.md | approve | It covers every friction-log item not held by drafter-batch-friction or the approval-queue passes. | The approval-queue session confirmed its scope, and the two plans touch no file its passes edit except one non-overlapping line of the blueprint skill. |
| step:1 | session | A merge and a backlog edit can be reverted. | Closing #42 and #43 is your 2026-10-24 call. |
| step:2 | session | No session works ~/.dotfiles now. | Planning runs under the design's standing answers. |
| step:3 | session | The drafter pass waits for drafter-batch-friction's merge. | One executor per worktree. |
