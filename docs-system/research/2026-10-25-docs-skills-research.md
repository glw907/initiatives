# Docs skills research

Read-only, 2026-10-25, by a fresh-context agent, for rulings 10 to 12 of
`2026-10-25-docs-as-code-rulings.md`.

## Principles (Anthropic guidance)

1. Skill or CLAUDE.md: "Create a skill when you keep pasting the same instructions, checklist, or
   multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather
   than a fact." <https://code.claude.com/docs/en/skills>. CLAUDE.md: "target under 200 lines".
   <https://code.claude.com/docs/en/memory>
2. CLAUDE.md test per line: "Would removing this cause Claude to make mistakes?"; exclude "Detailed
   API documentation (link to docs instead)"; "Unlike CLAUDE.md instructions which are advisory,
   hooks are deterministic." <https://code.claude.com/docs/en/best-practices>
3. Path-scoped rules with `paths:` load only when Claude works on matching files (memory page).
4. Descriptions say "both what the Skill does and when to use it", in third person, 1,024
   characters at most; Claude Code truncates description plus `when_to_use` at 1,536; "Put the key
   use case first". Skill-creator: Claude tends to "undertrigger", so make descriptions "a little
   bit 'pushy'".
   <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>
5. `SKILL.md` under 500 lines; references one level deep; a reference over 100 lines gets a table
   of contents. Separate files, not separate skills, for rarely co-used contexts.
   <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills>
6. "The context window is a public good"; "Only add context Claude doesn't already have."
7. "Match the level of specificity to the task's fragility."
8. Examples beat descriptions; "Run validator → fix errors → repeat."
9. Evaluation first: "Create evaluations BEFORE writing extensive documentation"; three scenarios,
   a baseline, minimal instructions; test with a fresh instance on "actual tasks". Skill-creator:
   run each case with and without the skill; 20 trigger queries where "the most valuable
   [negatives] are the near-misses"; avoid "fiddly overfitty changes".
10. Writer/Reviewer: "A fresh context improves code review"; tell reviewers to "flag only gaps that
    affect correctness or the stated requirements".
11. Subagents: make one "when you keep spawning the same kind of worker with the same
    instructions"; `tools` is an allowlist; `skills:` preloads.
    <https://code.claude.com/docs/en/sub-agents>
12. House register (Survey `writing/agent-facing.md`): "Give the reason with the rule". The skills
    page says "State what to do rather than narrating how or why"; follow Survey, one clause of
    reason per rule.

Research (preprints, moderate): agents touch code about 4.7 times more often than docs first, with
"no explicit documentation-based validation sequence" (arXiv 2608.20195); README maintenance as a
"surgical documentation update" (arXiv 2603.00489). Vendor guidance (weak): proposal, then human
review, with claims checked against code.

## Recommended set

1. Skill `cairn-docs`, in cairn's `.claude/skills/`, replacing `blueprint`. A decision tree for
   changing docs with code, fixing a deficiency, and a new page or restructure; references
   `new-page.md` (premise test, track and type, outline, introduction questions) and `review.md`
   (queue commands, notes JSON). Routes to the register's track sections and Survey's
   `technical-doc-web.md` and `editor.md`, never copies them. States where a correction lands:
   Geoff's in-place edit is final; a wording correction goes through the `survey` skill; a cairn
   voice change is a PR to `docs-register.md`; a base change is a PR to Survey.
2. Path rule `.claude/rules/docs.md` with `paths: docs/**`, pointing at `cairn-docs` and the
   register.
3. CLAUDE.md: one line that docs change in the same PR as the code, plus the gate command.
4. Agent `docs-fact-checker` (rework of `fact-checker`): checks changed or new page lines against
   the code at a commit; JSON findings; read-only tools; over-firing guard.
5. Keep `cairn-figure`, `figure-verifier`, `cairn-register-editor`, and `register-check` (audit for
   residue only).
6. Optional: a hook that runs the docs gate when `docs/**` changes.

## Evals

- `cairn-docs`, with and without the skill, Sonnet and Opus: cairn BACKLOG #74 (`mediaRefs` stale);
  renaming an export named in `docs/reference`; "add a page on rotating a session secret" (the
  near-duplicate trap); a planted false sentence in `turn-on-tidy.md`.
- Trigger evals: 20 queries, with near-miss negatives (CHANGELOG, site content, a plan or spec, a
  code comment).
- `docs-fact-checker`: 5 true and 5 false seeded claims on one page, three runs; recall and false
  positives.

## Avoid

Copying register text; a body over 500 lines (the old `reference.md` is 662); historical narrative
in instructions; many options instead of one default; vague or first-person descriptions;
self-review in the writing session; reviewers with no over-firing guard; overfitting to evals;
relying on CLAUDE.md for must-run gates.
