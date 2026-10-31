# Agent-first pattern for cairn

You paused the docs series on PR 160 to work out what documentation an agent-first project should keep. This design is the answer. It started from Anthropic's guidance and the published research, then took a fresh review against that guidance, a builder check, and a backlog sweep. The review rated the first draft sound with changes, and this version carries them.

The design keeps human docs for editors, admins, and technical evaluators, at a high editorial bar and as few as the mission needs. Everything else moves into code, tests, and packaged skills, judged by how agents perform with it. Cairn-only tooling is committed to the repo, and craft that other repos share goes in one public plugin, so a second developer clones cairn and has the tooling in a local session. Old plans, research, retired names, and their machinery leave `main`, with no alias left behind and a git tag for reach.

The work is four passes. Technical pages are deleted only after an A/B eval of the finished end state on real tasks, and four end-to-end checks prove your success outcomes. Approving starts planning and resumes the series as you choose below. The session recommends finishing passes 3 and 4 now, rescoping pass 5, and holding the release so sites migrate once. Agent performance on cairn is unmeasured today, so the page removal stays conditional on the eval.

## If you approve
1. [session] Commit the design and this packet to the initiatives repo, and mark `shared-standards` active.
2. [session] Land the backlog verdicts the design lists, in one commit.
3. [session] Tell the series conductor your decision, or relaunch it from its ledger, and record the new sequence in `docs/STATUS.md`.
4. [session] Write the four plans under pass-core and send pass 1 to its conductor.

## Not checked
The plugin mechanism is proven from Anthropic's docs only, and pass 1's first task is a live spike of it. Eval session counts are unsized until the plan fixes the case list.

## Ask: How should the paused docs series resume?
Rule: owner-call
Part: glw907/initiatives:shared-standards/specs/2026-10-31-agent-first-pattern-design.md
Recommended: 1
Reason: Passes 3 and 4 produce human docs the design keeps, and pass 5's front door is where the evaluator set belongs.
Summary: The editors and admin passes finish either way. Pass 5 has drafted a front door for a page set this design changes, so the session recommends rescoping it to own the evaluator set.

Background: The series is on hold at your word. Pass 3 waits on your review, pass 4 was sent back with 14 questions open, and pass 5 stopped after drafting. The evaluator set is the README, `docs/why-cairn.md`, and an architecture page with the security model.

Facts: The human arms survive and the front door needs a new shape.
- Passes 3 and 4 cover the editors and admin arms (`docs/plans/2026-10-30-docs-finalization.md`)
- Pass 5 drafted the front door at 49bab03d3 and stopped (`~/.local/state/cairn-docs-final/ledger.md`)

Choices:
- Finish 3 and 4, rescope 5: the series closes with the evaluator set, and the rebuild starts after it [approve]
- Finish all three as planned: the series closes sooner, and the rebuild redoes the front door [approve]
- Hold the whole series: nothing resumes until the pattern lands, and editor and admin docs wait [hold]
- Send back: you change the design in your note [send-back]

## Ask: Hold the release until the rebuild lands?
Rule: owner-call
Part: none
Recommended: 1
Reason: Sites migrate once, and a release now would ship pages and skill names this design removes.
Summary: Holding means each site migrates once, to the final pattern. It also delays every site and keeps cairn.pub on its current pin for the length of four passes.

Background: Your sequence is docs, one release, then each site migrates once. The rebuild renames packaged skills and removes technical pages, which reach sites through the package.

Facts: Sites depend on the release, and none has migrated.
- No site migrates before the one release (`docs/STATUS.md`)
- cairn.pub pins `0.94.0-rc.1` (`docs/STATUS.md`)

Choices:
- Hold: one release carries the rebuild, and sites wait longer
- Release first: sites move sooner and migrate again for the rebuild

## Ask: How much process should a second developer get?
Rule: owner-call
Part: none
Recommended: 1
Reason: CI is the merge authority, and the pass lifecycle exists for your packet, queue, and conductor.
Summary: A second developer gets gates, `CONTRIBUTING.md`, skills, and review agents. The session recommends stopping there until a real second developer needs more, because porting `pass-core` is sizable work with no reader yet.

Background: You asked that a second developer can get all necessary tooling. `pass-core` is the planning and execution process your sessions follow, and most of it serves your approval flow.

Facts: The skill is tied to this workstation.
- The review counted 65 workstation references in `pass-core` (`/tmp/claude-1000/-var-home-glw907-Projects-cairn-cms/dfd46629-9c41-408e-81d1-2ba711475dee/scratchpad/design-anthropic-eval.md`)

Choices:
- Gates, skills, and agents only: the leanest result, and more can follow a real need
- Add a short portable lifecycle: a second developer gets a planning process, at the cost of one more thing to maintain

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| step:1 | session | A commit can be reverted. | The design is a record. |
| step:2 | session | The sweep's 19 items are 12 keep, 4 fold, and 3 reword, with no drops. | Approving the design approves the backlog edits. |
| step:3 | session | The conductor's loop stopped on purpose until you message. | Your decision here is that message. |
| step:4 | session | The design names the plans, their order, and their checks. | Planning follows pass-core. |
