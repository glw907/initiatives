## Incident first: I killed batch 5's live `drafter page` run

At 13:36 -08:00 I was checking that standing answer 3's `pgrep` pattern works, using fake processes in my scratchpad. To clean up I ran `pkill -f 'drafter page'`. That pattern also matched batch 5's real process, PID 1880344, running `drafter page --resume 20261025T211819Z-96ca1dc0 docs/extend/define-an-adapter-and-schema.md`, and terminated it. `/tmp/claude-1000/draft5b.log` shows `exit define-an-adapter-and-schema 143` and `stopping at define-an-adapter-and-schema`, with the page and its brief left modified in the batch 5 worktree. Seconds later a new runner was going (`bash -c /tmp/claude-1000/draft5b.sh > /tmp/claude-1000/draft5c.log`), so the batch 5 owner seems to have relaunched. I touched nothing else.

Please tell whoever owns batch 5 (RESUME.md: `/var/home/glw907/Projects/initiatives/docs-system/research/2026-10-25-extend-pages-batch-5/RESUME.md`) so they can confirm the resumed run is sound and record what the interruption cost. A review probe should never send a signal by pattern. Mine should have killed its own PIDs only.

---

# Review: drafter batch 4 friction plan (mechanics and feasibility)

I checked the plan against drafter `e41695f`, cairn-cms `origin/main` `75b6138`, and `pass-core`. To test the brief-sync questions I ran drafter's provenance checker on cairn's add-an-island page and brief, using a copy of drafter in my scratchpad.

These hold up: the path arithmetic (650 path minutes, 945 task total, 1.30x), branch naming (EnterWorktree makes `worktree-<name>`, as earlier passes show), the symlink targets, the cited symbols in `verify.go`, `money.go`, `resume.go`, `pipeline.go` and `check.go`, the three unlisted `docs/extend` pages, both anchorless facts in `arrange-the-admin-sidebar`, the brief path template, and file disjointness for every pair, generated outputs included. No golden test file pins the markdown-reading paragraph. The anchored `pgrep` pattern matches real `drafter page` runs (bare or by path) and skips a shell line that merely contains the words.

## Blocker

**1. `--commit` leaves the index-link edit uncommitted, so cairn's loop still trips `requireClean` (correctness).** Plan:364-367 (T5 #104) and :390-393 (its e2e).
- **Defect:** `internal/pipeline/check.go:330-360` (`indexLink`) runs `gate.index_link_command`. On cairn that is `cairn-docs-outline link`, which writes a link to each new page into the outline's index file (`bin/.local/bin/cairn-docs-outline:15-20`). `--commit` stages only the page, its brief and `drafted.lock`. After a new page's first draft the index change stays uncommitted, and the next run in the loop is refused, which is the batch 4 failure #104 exists to fix. Batch 6's nine pages are all new pages. The planned e2e can't catch this: the `testdata/cli` fixture sets no index-link command, so its "clean tree" check passes for the wrong reason. #104 is on standing answer 5's cannot-escalate list.
- **Fold:** commit every path the run changed. The run starts clean (`requireClean`), so `git status --porcelain` after `recordDrafted` lists exactly the run's own writes. The e2e fixture should set an `index_link_command` that edits a tracked file, and the test should assert that file is in the commit.

**2. The format doc's author part is over the 30,000-byte bar before T7 adds anything (correctness).** Plan:495-497.
- **Defect:** at HEAD, the sections the plan keeps in `docs/blueprint-format.md` measure 30,295 bytes: lines 1-224 = 11,284, lines 543-654 = 10,034, lines 701-823 = 8,977. T7 then adds six check rows, the `#decl` row, the drift hint, the `[external]` skip, the trailing-anchor form, globs and the notice syntax. So `wc -c` under 30000 can't pass unless the executor cuts content outside its scope. T7 can't be escalated, so this ends as a gate-failed ask to Geoff.
- **Fold:** either set the bar from the measured split (about 36,000), or move "The edit catalog" and "Check what you add" (about 2,500 bytes) to the reference part and still raise the bar to cover the new rows.

## Major

**3. The anchor-check loop skips the skill and gives a false hit (correctness).** Plan:506-508.
- **Defect 1:** `--exclude-dir=.claude` matches any directory named `.claude`, including `claude/.claude/`. So the skill's links are never checked, among them `new-page.md:11` `format.md#outlineyaml`, the one link the plan names. Verified: the same grep without the exclude finds it.
- **Defect 2:** `-e "format.md#items)"` is a substring match. It hits `plan-format.md#items)` at `docs/blueprint-format.md:340`, a line that moves into `blueprint-reference.md`, so the loop prints even when every link is right.
- **Minor error in the plan text:** the skill has no `format.md#items` link, contrary to plan:461.
- **Fold:** use `git grep -nE "(^|[(/])(blueprint-)?format\.md#$a\)"`. It searches tracked files only, which already leaves out `.claude/worktrees`.

**4. `brief --sync` never says how it recovers the page's raw text, and rewriting the JSON breaks the cairn diff check (correctness).** Plan:409-423 (T6 #109) and :537-540.
- **Defect 1:** `Check` finds sentences in `pageProse`, which strips fences, headings and comments and then runs `coverage.Normalize`. Normalize drops every `*`, `_` and backtick (`internal/coverage/normalize.go:14-22`). The uncovered runs therefore exist only in normalized form, and nothing maps them back to "the page's text as written, code spans kept". Cairn's briefs carry raw markdown, links included (sentence 93: ``[`hydrateIslands`](../reference/islands.md#…)``), and `extract` reads names from code spans. Building that map is the hardest part of T6 and the plan doesn't name a mechanism.
- **Defect 2:** cairn's brief is one line of JSON with no trailing newline, keys in the order `page`, `sentences`, `local`, and literal `<name>`. Go's `json.Marshal` on a map sorts the keys and escapes `<` as `<`. And `git diff` on a one-line file shows the whole line changed whatever the content, so "only that sentence's entry replaced" can't be read from it.
- **Probe result:** add-an-island has no unclassified page text today (10 findings, none of them unclassified), so after a one-sentence edit the "prints one sentence" check is reachable.
- **Fold:**
  - Name the mechanism: re-locate each normalized fragment in the raw page lines with a match that ignores whitespace and delimiters. Or keep the raw-to-normalized offset map while building `pageProse`.
  - Write nothing when nothing changed. When writing, keep the key order and use an encoder with `SetEscapeHTML(false)`.
  - Make the e2e compare with `diff <(git show HEAD:<brief> | jq -c '.sentences[]') <(jq -c '.sentences[]' <brief>)`.
  - Add `<` and an out-of-order key to the synthetic "byte for byte" fixture.
  - Check whether 90 minutes still covers T6.

**5. The new errors also fire in `drafter gate` and in `drafter page`'s stage-1 check, and the plan never says so (correctness).** Plan:183-192 (#89), :268-277 (#88), :278-291 (#106/#108).
- **Defect:**
  - `gateBlueprint` calls `p.Check([]string{bp})`, which is a named run (`cmd/drafter/gate.go:135`). So T3's inbound-anchor error and its page-drift warnings run inside every stock gate call.
  - The #89 check sits in `plan.Check`, which `CheckSource` also reaches (`internal/blueprint/check.go:144`). So a blueprint linking an unlisted page escalates at stage 1 of `drafter page` (`internal/pipeline/blueprint.go:84-111`).
  - On cairn `main`, about nine blueprints link the live unlisted pages `upgrade-cairn.md` and `choose-an-ai-posture.md`: architecture, build-the-public-routes, define-an-adapter-and-schema, scaffolded-site-files, debug-your-site, restrict-admin-access, add-a-second-sign-in-group, add-cairn-to-a-sveltekit-app, and using-claude-code-with-cairn.
  - Standing answer 8 covers the check totals only. Once the binary is installed, drafting any of those pages escalates until cairn marks the targets `managed: false`.
- **Fold:** state both paths in `## Decisions`. Either make the cairn `managed: false` follow-up a precondition of the install in standing answer 3, or report #89 as a warning in the `CheckSource` path. **OWNER FORK** on the severity variant: (a) an error everywhere, with the install gated on cairn's follow-up; (b) an error in `check`, a warning in `drafter page` and `gate`. I recommend (a). It keeps the approved "error" and costs only ordering.

**6. The inbound walk scans every tracked `.md` file, not just published pages, so history files raise errors (correctness).** Plan:270-277.
- **Defect:** the design says "other blueprints and published pages". The plan walks every tracked `.md` outside the blueprint root and facts directory, which in cairn is 1,376 files. That includes `CHANGELOG.md`, `SECURITY.md` and `docs/internal/record/2026-08-14-pass-d-task-13-production-gate.md`, all of which link page anchors. A historical link to an anchor someone dropped on purpose then fails every named check (exit 1).
- **Fold:** walk the blueprints plus the pages the outline lists or that sit in directories the outline covers.

**7. A pull right after the merge puts the new skill live while the old binary stays installed (correctness).** Plan:573-579 (standing answer 3) and :608-611.
- **Defect:** `~/.claude/skills/blueprint` and `~/.claude/workflows/docs-page-chain.js` are symlinks into the drafter main checkout. The pull that follows the merge makes the skill tell sessions to run `drafter page --commit`, `drafter brief --sync` and `drafter outline` with no slug. Meanwhile `~/.local/bin/drafter` stays old until batch 5 finishes. Batch 5 is live; it relaunched today.
- **Fold:** pull the main checkout under the same condition as the install. Until then STATUS reports the checkout as stale, which `pass-core` "Close" allows.

**8. The conductor prompt doesn't name `glw907/cairn-cms` as a push target (correctness).** Conductor prompt line 15.
- **Defect:** `log-issue` step 6 pushes the backlog commit straight to cairn's default branch. `pass-core` "Execute" says auto mode blocks a push to a repository the prompt doesn't name. The conductor would stall at its last step, unattended.
- **Fold:** add "Push target for the cairn-cms backlog commit: glw907/cairn-cms, `git push origin HEAD:main` from the worktree."

## Minor

**9. Extending `formLabel` as written contradicts the notice rules (correctness).** Plan:331-334, `internal/blueprint/markdown.go:300-314,392`.
- **Defect:** the label branch strips the label from `Text`, parses `:source`, and sets `formAt` so a following fence attaches. `isForm` uses the same regex. All three contradict "keeps its label in Text, takes no :source".
- **Fold:** use a separate `noticeLabel` regex with its own branch.

**10. The plan never says how T5's e2e gets a second blueprint (correctness).** Plan:390-393.
- **Defect:** `testdata/cli` holds one blueprint. The stub answers by schema with canned page, brief and coverage answers made for `count-items`.
- **Fold:** name the fixture: a copy of `count-items` under a second slug, listed in the outline, so the canned answers fit.

**11. The planted-line proof in the close relies on the exit code (correctness).** Plan:534-536.
- **Defect:** the named check already exits 1 on the anchorless error, so the exit code proves nothing about the added line.
- **Fold:** grep for the unlisted-target message at the added line's number.

**12. T4's risk class is understated (correctness).**
- **Defect:** T4 edits `claude/.claude/workflows/docs-page-chain.js` and `stock/prompts.js`, both prompt modules that live drafting reads, and the workflow file is `runner` under `pass-core`. The plan marks T4 `ordinary`. The pass is `runner` either way, but `diff-reviewer` re-derives each task's class.
- **Fold:** mark T4 `runner`.

**13. One gate leg reads state another session can change (optional).**
- **Defect:** `chain-test` reads agent definitions from `~/Projects/workstation` (`tests/docs-page-chain-derivation.test.mjs:16`). The plan doesn't say what happens if another session changes them mid-pass.
- **Fold:** a red in `docs-page-chain-derivation` traced to a workstation change gets one rerun after `git -C ~/Projects/workstation log -1`, and is recorded.

**14. T4's file list doesn't name the chain test (optional).**
- **Fold:** list `tests/docs-page-chain-blueprint.test.mjs` (the chain module's text assertion, line 310) in T4's files.

**15. Two smaller points about the design (optional).**
- `verifySymbol`'s new range "from the declaration line" also drops decorator lines (`docStart` includes them). State that cairn's `resolveSymbol` does the same, or keep decorators.
- The #102 move to cairn drops a deliverable the design names: "loosens the task-guide anatomy's item 5". The packet carries it as a routine row, which is fine. If Geoff would see it as a scope change, it is a pre-launch question (**OWNER FORK**, low stakes). I recommend keeping it as the packet row, since it follows the design's own rule that cairn changes go to cairn's backlog.

**16. The pair dispatch names no effort (optional).**
- **Defect:** executor prompt line 8 names the model but not the effort, and CLAUDE.md says every dispatch names both.
- **Fold:** add `effort: medium`.

## Over-ceremony

**17. `prose-voice-reviewer` runs twice on the same files (optional).** Plan:510-512 and :545.
- **Defect:** T7's acceptance runs it on the two docs and the skill diff, and step C.3 runs it again on the same files. That is about 10-15 minutes and one Opus read.
- **Fold:** keep only C.3's run.

**18. T0 is a five-minute task with a single deliverable (optional).** Plan:145-149.
- **Fold:** fold it into the start of the T1/T2 pair, as `pass-core` step 4 asks. No path change.