# Docs-as-code cutover

You sent back the batch 5 friction design: no converter, and both tools accept only the approved blueprint format. Since then you've gone further. Asked for an agent's honest view, I reported that blueprints are no easier than pages for an agent to use, and harder to maintain. You ruled to retire blueprints, the facts store, and drafter, and move to standard docs-as-code. You also ruled to rewrite the Approval Queue's docs review and the Claude infra as if written from scratch, and to build new skills on research and Anthropic's guidance.

This design is that cutover, run overnight in three parallel workstreams. In cairn, the run removes blueprints, facts, and their gates, re-keys the options check, and adds an eval-tested `cairn-docs` skill and `docs-fact-checker` agent. In the Approval Queue, one `docs` review replaces four kinds. You still edit in place and add notes, and you now see the PR's code diff too. In the infra, the run unlinks drafter and rewrites every skill and agent that described it. cairn and the Approval Queue merge overnight once their gate, review, end-to-end check, and a fresh residue read pass. The workstation and Survey PRs, and the register rulings rewrite, wait for you. In the morning you'll also find one real docs fix made end to end with the new tools. A fresh plan review found six blockers, all folded in, including restarting the queue's server so other projects' hand-overs keep working.

## What changed
- No converter, and nothing but the approved format: blueprints are gone altogether, so drafter and its converters, `check-plan`, and the YAML reader are all removed, as your note asks.
- The design is now the docs-as-code cutover you ruled on in chat, with the evidence and rulings in the initiative's research records.

## If you approve
1. [session] Merge glw907/workstation#152, which adds your research rule to pass-core.
2. [session] Merge this design and the five research records to initiatives.
3. [session] Write the plans, fixing the `docs` command's interface first, and launch conductor-approval-queue.

## Not checked
The skill's eval cases are new, so a first run may tune their assertions; the design lets the run fix and rerun them. The options re-keying is about 241 rows; a script places most, and any it can't becomes a pending row with a backlog item rather than a stop.

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-25-docs-as-code-cutover-design.md | approve | Every removal carries a path in the retirement inventory, the skills cite Anthropic's guidance in the skills research, and a fresh plan review's six blockers are folded in. | Two architecture calls are mine and reversible: `docs-fact-checker` lives in cairn so it works tonight, and the register rulings get a separate PR for you to read. |
| glw907/workstation#152 | approve | It adds three sentences to pass-core's design step with your ruling and the Anthropic citation, and the dotfiles gate passed. | It's the rule you gave in chat, for every repo. |
| step:1 | session | A merge can be reverted. | It's wording you gave. |
| step:2 | session | The records are read-only research and the design. | They're what the run plans from. |
| step:3 | session | The conductor runs under the design's standing answers. | The design lists what the run decides without you. |
