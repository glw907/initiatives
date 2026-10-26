# Docs-as-code rulings

Geoff's rulings of 2026-10-25 that end the generated-docs system. The evidence behind them is in
`2026-10-25-blueprint-format-review.md`. They supersede
`specs/2026-10-25-docs-system-cleanup-program-design.md`, which was never approved.

1. Blueprints retire as a concept. The docs move to industry-standard docs-as-code, with the
   published Markdown pages as the maintained source.
2. The facts store retires. Docs stay true through code samples included from tested source,
   generated reference, and a fact-check against the code at review time.
3. drafter is removed entirely; no part stays as a standalone check.
4. Tonight's overnight effort has three workstreams: remove drafter; rewrite the Approval Queue so
   Geoff can just review draft docs; clean up the Claude infra to use the new standard system.
5. In the Approval Queue, packets, PR review, and triage stay as they are. The `blueprint`, `page`,
   `change`, and `anchors` kinds collapse into one docs review: a docs PR's draft pages, read and
   edited in place, with fact-check findings as notes beside the lines. Approving it merges the PR.
6. `glw907/workstation#152` (research filed items in code before fixing them) stands.
7. The current review workflow, editing the draft doc in place and adding notes, works well and
   stays. The new docs review keeps it and drops only what served blueprints and facts.
8. The Approval Queue's code must read as if written ground-up for its purpose: no residue of the
   removed kinds (names, branches, types, fixtures, comments, docs, or compat shims), with the
   docs review designed as a first-class kind, not a page kind with parts cut away.
9. The same bar holds for the Claude infra cleanup: skills, agents, hooks, CLAUDE.md files, and
   workstation docs read as if written ground-up for docs-as-code, with no residue of blueprints,
   facts, drafter, or the page chain. A fresh-context residue read gates each workstream's merge.
10. The new system gets a new, useful set of skills tailored to it, replacing the blueprint-era
    skills rather than adapting them.
11. Every new skill rests on research and Anthropic's guidance, cited in its design.
12. Maintaining the Survey register stays key: the writing register in `glw907/survey`
    (`skills/survey/writing/`) and its corrections log. The new docs skills route to it (with
    cairn's docs register as the recorded overlay), never copy it, and the cleanup removes only
    blueprint-era residue from it, in the Survey repo.
13. The drafter repo is deleted on GitHub and locally, not archived (Geoff, irreversible by his
    choice).
14. drafter's spend ledger is copied into this initiative; its runs, smoke, and spike state (347 MB)
    are deleted. `DRAFTER_API_KEY` leaves the secrets and the registry, and Geoff revokes the key
    and its Console workspace in the morning.
15. cairn-cms#144 merges as is tonight; the cleanup deletes its blueprint, brief, and facts files
    on main afterwards.
16. The Approval Queue keeps the 45 decided blueprint, page, and change items as data on disk; the
    board no longer lists or renders them.
