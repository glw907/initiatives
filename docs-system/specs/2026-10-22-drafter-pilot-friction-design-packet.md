# Drafter pilot-friction pass design

The docs-system initiative ran its extend blueprints pilot today: three cairn pages went from plans to blueprints you approved, and the authors' friction was filed to drafter's backlog as items #36 to #47. A blueprint is a page's plan in markdown, which an author agent writes and drafter drafts from. This design is the pass that fixes drafter's share before the other fifteen extend pages start.

The pass adds markdown forms for code examples, figures, and page-wide constraints, so a code example's model file reaches the drafter again. It teaches the skill to frame the reader from the outline's job, as your custom admin send-back asked. It adds checks for over-claiming words and drifted pointers, and widens `drafter refs` to show what a fact correction breaks. Approving merges the design and starts planning, then the pass runs unattended and comes back as one packet. There are no steps for you before it launches.

One question is open. The fifteen pages have prose plans only, so the two converter fixes, #42 and #43, never run on them. The session recommends deferring both, which keeps the pass near 420 minutes.

## If you approve
1. [session] Merge the initiatives PR that files this design and its packet.
2. [session] In drafter, clear the `reviewed-pages` worktree's stale lock and remove the 50 old worktrees, none of which holds uncommitted work. Branches merged into main are deleted. The parked `blueprint-first` branch and four agent branches with unmerged commits are kept.
3. [session] Write the plan under pass-core and hand the pass to conductor-drafter.

## Not checked
The pass's minutes are an estimate set from recent passes, which finished well under plan. How the new forms read to an author is what the next fifteen pages will show.

## Ask: Defer the converter fixes #42 and #43?
Rule: owner-call
Part: none
Recommended: 1
Reason: Neither converter runs on any page left in the round, and the authors of those pages gain nothing from them.
Summary: Both fixes improve the converters that start a blueprint from a YAML plan. The fifteen pages left have prose plans only, so neither converter runs on them.

Background: `convert plan` turns a YAML plan into a YAML blueprint, and `convert markdown` turns that into the markdown format. The pilot's three pages started that way. The rest of the round starts from a prose plan, which an author agent turns into a blueprint by hand.

Facts: Every cairn page with a YAML plan already has a blueprint.
- The fifteen pages left have a `.plan.md` and no `.plan.yaml` (`docs/internal/briefs/extend/` in cairn-cms at `0e01d37e3`)
- All eleven YAML plans in cairn have a blueprint (`blueprints/docs/` in cairn-cms at `0e01d37e3`)
- Eight YAML blueprints remain that `convert markdown` could later move to markdown (`blueprints/docs/` in cairn-cms)

Choices:
- Defer both: they stay in the backlog at Medium, and the pass runs about 420 minutes
- Keep both: they run as the pass's last tasks, adding about 150 minutes

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-22-drafter-pilot-friction-design.md | approve | It covers backlog #36 to #47, with the three new markdown forms set out in the design. | Each form follows the format's existing bullet-and-tag pattern, and every other call follows the record. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | No worktree holds uncommitted work, and only merged branches are deleted. | The STATUS launch prompt names this cleanup before dispatch. |
| step:3 | session | Planning runs under the design's standing answers. | The design lists what the run decides without you. |
