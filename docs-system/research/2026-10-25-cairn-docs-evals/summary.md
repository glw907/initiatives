# cairn-docs eval summary

Run 2026-10-25 and 2026-10-26 by `cairn-cms-docs-cutover`. Evals live outside the tree (plan call 4); the conductor copies this folder into `research/2026-10-25-cairn-docs-evals/`.

## Conditions

- Model for the case runs and the trigger queries: `sonnet` at `medium`, headless `claude -p`, per plan call 5. Each run is in a scratch worktree.
- `base`: cut from `d7c7eeda6` (the `docs-cutover` head before the skill, rule, and agent). `skill`: cut from `b6011508f` (with them).
- Graders: `general-purpose` on `opus`, blind to the condition, with Run 1 and Run 2 set by coin flip (`grades/order.json`).
- Known confound (plan call 8): the live `~/.claude` tree still carries the old `cairn-pass`, `cairn-implementer`, `fact-checker`, and `cairn-docs-drafter` until the workstation PR merges. `Agent(fact-checker)` and `Agent(cairn-docs-drafter)` were disallowed in every run. The stale `cairn-pass` text (it tells a session to file facts) loads in both conditions.
- The live `blueprint` skill link was still present at trigger-test time, so the queries ran with it competing. No query routed to it.

## Bar 1: the skill beats the base

| Case | Base | Skill | Of |
| --- | --- | --- | --- |
| `code-and-docs` | 4 | 5 | 6 |
| `rename-export` | 4 | 6 | 6 |
| `new-page-trap` | 5 | 5 | 5 |
| `deficiency` | 3 | 5 | 5 |
| Total | 16 | 21 | 22 |

Met: 21 is greater than 16.

- The skill was invoked (a `Skill` call to `cairn-docs`) in three of the four skill runs: `rename-export`, `new-page-trap`, and `deficiency`. In `code-and-docs` it was not, and that run still passed the docs gate.
- Both `code-and-docs` runs missed assertion 3: `docs/extend/architecture.md:157` says a media replace "neither changes the content manifest", which the fix makes false, and neither run edited it. The skill run's reply said no page described the behavior. That is a real finding for the skill's step 1 (search the behavior's words), left as is.
- `new-page-trap` passed 5 of 5 in both conditions. The base model already refuses the nonexistent session secret, so the case does not separate the conditions.

## Assertions found faulty

1. `rename-export` assertion 3 required a `Consumers must:` line in `docs/extend/migration-notes.md`. That page distills the lines into bold action bullets and never repeats the phrase, so no correct run could pass. Fixed in `cases.json` (see its `fixed` field) to require the `Consumers must:` line in `CHANGELOG.md` and a rename entry in `migration-notes.md`. Both conditions were regraded (`grades/rename-export.json`; first pass kept in `grades/rename-export-first-pass.json`). The runs themselves were not repeated, since the assertion does not change what a run does.
2. The `deficiency` setup never applied its seed in the first runs. The sentence wraps across two lines in the page and the exact-string replace missed. The grader noticed that the page already read 24,000. Those runs and their grade are void (`runs/void-deficiency-*`, `grades/void-deficiency.json`). The setup now matches across the wrap and aborts if it does not apply. Both conditions were rerun and regraded.

## Bar 2: triggers, at least 18 of 20

19 of 20 route correctly (`triggers-score.json`). The miss is query 1, "I renamed createMediaRoute's maxBytes option to maxUploadBytes. Update everything that has to change with it.", which called no skill. No change made for it (one query is not a cause). Near-miss routes: `content-draft` (12), `cairn-pass` and `pass-core` (13, 16), `survey` (18), none to `cairn-docs`.

## Bar 3: the fact-checker, in each of three runs all 5 false claims and at most 1 false positive

Met in all three runs (`fact-checker/score.json`): 5 of 5 false claims found, 0 false positives on the 5 true ones. Runs used `claude -p --agent docs-fact-checker` (the flag exists), with `--allowedTools "Read Grep Glob Bash"` added so the headless session could run the agent's read commands. Runs 1 and 2 also marked the seed section's intro sentence ("fills every field you leave out") `imprecise`; it is not a keyed claim and the code supports the finding (`bucketBinding` is required, not filled), so it is not scored.

## Cost

The four-case runs cost about $5 in API spend by their `result` records, plus the three fact-checker runs at about $0.40 each, the 20 trigger queries, and the Opus graders.
