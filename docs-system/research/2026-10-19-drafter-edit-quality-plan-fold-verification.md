# Fold verification: drafter edit-quality plan

Target: `plans/2026-10-19-drafter-edit-quality-plan.md` as revised by
`research/2026-10-19-drafter-edit-quality-plan-fold.md`, from the three reviews
(`-review-mechanics.md` M, `-review-contract.md` C, `-review-integrity.md` I), against
`specs/2026-10-19-drafter-edit-quality-design.md`. Code read at drafter `main` `41939c3`
(read-only), cairn `50dc211d9`, skill-rules' harness, the ledger, and the installed Claude Code
2.1.302 binary. Probes ran under the job's tmp directory only. The verifier had no part in the fold.

Verdict: no blocker, three majors, twelve minors. The fold closes the review's blocker (C1) and
every major at the place it names, with three gaps. The plan writes the resume command in a form
drafter refuses. It puts the scope sentence in two different places. And nothing tests that the
real prompt's first cache block stays the same across scopes. The order builds, the path
arithmetic is right, and `money.go` and `resume.go` stay untouched under every task and every
fold proposed here.

## Findings, ranked

### 1. Major, correctness: the resume command fails in all three places the plan writes it

- Location: plan:59 (standing answer 4), plan:202 (Harness, orphans), plan:287 (EQ.1's outcome
  table, which ships in `SKILL.md`).
- Defect: each says `drafter read --resume <run-id>`. drafter refuses that form twice over. First,
  `read` needs at least one blueprint argument (`cmd/drafter/read.go:62-63`, "read needs at least
  one blueprint file"), and its help says "give the same blueprints again" (`read.go:48-49`).
  Second, the read loop and every harness read run with `--sync`, and `mode` is part of the run's
  configuration fingerprint (`internal/pipeline/fingerprint.go:18`). `checkConfig` refuses a
  resume whose mode changed (`resume.go:213-214`), and with no flag the mode is the stock
  `batch` (`internal/config/apply.go:22`; cairn's `drafter.toml` and the local file set no
  `mode`). A resume without `--sync` exits 2: "the configuration changed since the run started
  (mode)". drafter's own stop line prints the same broken form (`ResumeLine`,
  `internal/pipeline/pipeline.go:192`, printed at `cmd/drafter/page.go:225`), so a session that
  copies drafter's output fails as well. skill-rules' `read.sh` used the working form
  (`read --sync --json --resume "$RESUME" "$BP"`). The result: every exit-3 path in the loop
  exits 2, the orphan step can't settle an open intent, and the "`open.count` 0" dispatch gate
  then stalls the rerun.
- Fold: write `drafter read --sync --resume <run-id> <blueprint>` at all three places, and
  `<job>/bin/drafter read --sync --json --resume <run-id> <BP>` in the harness. EQ.1's acceptance
  checks that the table's resume row holds `--sync --resume` and the blueprint argument. For
  `ResumeLine`, EQ.3 already edits `pipeline.go`'s summary, so it can have `ResumeLine` add
  `--sync` when the run's mode is sync, plus the page paths, with one `cmd` row. That stays
  outside the two frozen files. If the planner rules that scope growth, file it through
  `log-issue` and have the skill row say not to copy drafter's printed line.

### 2. Major, correctness: the fold places the scope sentence in two different spots

- Location: plan:354-356 (EQ.5 outcome: block 3 is "the scope sentence, the blueprint, its outline
  entry, the change block"), plan:376-377 (EQ.5 pipeline acceptance: "the scope sentence opening
  the third block"), against plan:363-364 (EQ.5 files: `stageBlueprintRead` "prepends the scope
  sentence to the change text") and plan:422-423 (EQ.4: "the change block opens by naming the
  sections it touched"). The fold record's M1 says "opens the change block".
- Defect: `stageBlueprintRead` appends `p.w.Change` after `BlueprintBlock`
  (`internal/pipeline/blueprint.go:141-147`). Prepending the sentence to the change text therefore
  puts it after the blueprint and the outline entry, not at the head of block 3. EQ.4 (pair B)
  writes the prompt's account of where the sentence sits. EQ.5 (pair A) writes the wire and the
  test that pins it. As folded, either the acceptance test pins a placement the files text
  doesn't build, or the prompt describes the request wrongly.
- Fold: put the sentence at the head of the change block, as M1, EQ.4, and the files text already
  do. EQ.5's outcome then reads: "then the blueprint, its outline entry, the change block opened
  by the scope sentence, and the answer contract". Its pipeline acceptance reads: "the change
  block, opened by the scope sentence, sits in the third block after `=== end outline entry ===`".

### 3. Major, correctness (vacuous pass): nothing tests the real prompt's first block for stability across scopes

- Location: plan:434-439 (EQ.4 acceptance), plan:376-379 (EQ.5 pipeline acceptance), plan:422-424.
- Defect: departure 3 rests on the rendered prompt being the same bytes for every change read.
  Two problems keep that from being tested:
  - EQ.4 replaces only the `These sections changed:` want. The existing page-scope assertion
    still requires the page-form sentence in the prompt (`cmd/drafter/read_test.go:261`,
    `!strings.Contains(pageOnly, "No section's own content changed")` fails the test), and no
    criterion says it goes. So EQ.4 can pass with the page form left in the prompt. Block 1
    would then differ between a page-level change read and a section-level one.
  - EQ.5's "first block byte-identical for two change reads with different scopes" runs on the
    pipeline harness, which loads the fake module `internal/pipeline/testdata/module.js`
    (`harness_test.go:157`). That module's blueprint seat renders `"\nScope: " + c.scope`
    (`module.js:18`), so the test fails as written unless the module changes, and the module
    isn't in EQ.5's files. Once the module changes, the test proves the assembler's split and
    nothing about the shipped prompt.
- Fold: EQ.4's acceptance adds two rows. The renders with `Scope: "page"` and
  `Scope: "intro,steps"` must be byte-identical. And `pageOnly`'s want flips to "lacks 'No
  section's own content changed'". This is the property the cache rests on, tested on the real
  module. EQ.5's files add `internal/pipeline/testdata/module.js` (the blueprint seat drops its
  scope line). Its acceptance moves the scope-line checks in `TestScopeReachesTheBlueprintPrompt`
  and `TestOutlineOnlyChangeRendersTheChangeRead` to the change block, and says the
  byte-identity row proves the assembler's split only.

### 4. Minor, correctness: the cache pair can stop the line on a false zero, and it doesn't name which ledger line to read

- Location: plan:487-490 (EQ.7 step 4).
- Defect: the loop probe (step 2) runs p6's prompt, and the pair commits `ref6`, which is p6's
  reference edit. Both cached blocks can match a read the probe made minutes earlier. Step 3 makes
  no read, and an entry lives five minutes from the start of the request that wrote or read it
  (`prompt-caching.md:148`). When the pair starts inside that window, its first read shows
  `cache_write_5m` 0 and `cache_read` above 0, and "a zero stops the line" fires on a cache that
  is working. Each read also settles two ledger lines, and the consistency seat's line always
  shows 0 cache tokens. #49's ledger shows the pair: `seat":"consistency"`, 6,397 input tokens,
  and `seat":"blueprint"`, 59,361.
- Fold: read the `blueprint` seat's settle line. The first read passes when
  `cache_write_5m + cache_read > 0`, and the second when `cache_read > 0`. Or wait five minutes
  after step 2's last read before the pair starts.

### 5. Minor, correctness: resolving `--since` from the Bash command fails on a shell variable

- Location: plan:198-199 (Harness), plan:517-518 (EQ.8).
- Defect: a session may write `--since "$BASE"` or `--since $(git ...)`. `git rev-parse` of that
  literal text fails, so a valid read is graded as a wrong-base breach. `state.json` records no
  since revision (`internal/run/state.go:21-29`).
- Fold: add C1's equivalent check. When the argument isn't a literal revision, the read counts if
  the saved request's `=== blueprint diff ===` block equals `git diff <base''> <read head> -- <BP>`.

### 6. Minor, correctness: the env-file fallback drops the push guard and the no-key branch

- Location: plan:183-185.
- Defect: the fallback copies the wrapper over `~/.local/bin/drafter`. That restores the binary,
  prompt, and caps (I8), but the `GIT_CONFIG_*` push guard and the no-key probe's unset live only
  in the env file. A session's Bash commands also get both keys from `~/.bashrc:198`, which
  sources `~/.local/secrets`. So without the env file, the no-key probe can't unset
  `DRAFTER_API_KEY`, and nothing blocks a push.
- Fold: if the env-file route fails its re-probe, stop for Geoff rather than run the 21 on the
  fallback. Or state that the fallback runs with only `--disallowedTools` and the post-check
  `ls-remote` as the push guard, and no no-key probe.

### 7. Minor, correctness: `drafter spend --json` lists no per-run open intents

- Location: plan:201-203 (Harness, orphans).
- Defect: the JSON holds only `open.count` and `open.worst` (`cmd/drafter/spend.go:54-59`), so
  "each of its runs with open intents" has no source in that output.
- Fold: find the runs from `ledger.jsonl` reserve lines that have no settle, matched by `run_id`,
  or from each new `state.json`'s intents with an empty `Settlement`. Keep `open.count` 0 as the
  gate.

### 8. Minor, correctness: `drafter_version` can't tell builds apart

- Location: plan:197, and the fold's C8 row.
- Defect: `version()` returns `"dev"` for every local `go build` (`cmd/drafter/page.go:166-171`).
  Recording it proves nothing about which binary ran.
- Fold: record `state.json`'s `inputs` hash for the prompts module and compare it with the copy in
  `<job>/bin`, hashed the same way (`hashFile` in `internal/pipeline/record.go:163`). The
  cached-parts field in the saved request already identifies the new binary, so the
  `drafter_version` column can go.

### 9. Minor, correctness: EQ.6's premise greps can pass vacuously

- Location: plan:460-461 and plan:465.
- Defect: most premises check that something is absent ("no worked example", "no editor-view
  section", "no link"). A grep with a wrong pattern passes on any tree, so "`premises.sh` passes on
  the commit" proves nothing.
- Fold: before the first fix, show that each grep bites. It must fail on a seeded violating line,
  or on the prompt's reference edit where one exists (`ref6`, `ref7`), with the result recorded in
  `<job>`.

### 10. Minor, correctness: case 2's new text leads sessions into the new `handler` warning

- Location: plan:264-268 (EQ.1 case 2) against plan:295-297 (the `handler` row).
- Defect: "A `failure` is for a symptom with a handler the facts supply" reads naturally as
  "`handledBy` names a `fact` item", and that is the pattern the new warning flags
  (`x-check-threw` → `rec-health-failed` is EQ.2's own required hit). The same bullet also adds
  "with a `link` to the recovery section" to the "Add a caveat" row. That row names `sentence`
  alone (`docs/blueprint-format.md:431`), so the skill would carry a format rule the format page
  lacks, which Close's link-not-copy rule forbids.
- Fold: say the handler is a step or a handoff that gives the reader a next action and cites the
  fact, with a link to the format page's `handler` row. Either add `link` to the catalog row in
  EQ.1, or drop the clause from the skill.

### 11. Minor, correctness: two figures and one item kind are wrong

- Location: plan:47 and fold:30; plan:124-125.
- Defect: #49 left 22 streams, with 22 `"apiKeySource":"none"` lines (counted in the old job
  directory), not 25. Departure 11 calls `x-editor` "the section already carrying the content",
  but it's a `failure` item (cairn blueprint line 724-725). EQ.8:541 gets it right.
- Fold: write 22, and "the item".

### 12. Minor, optional: the cycle-cap row says "commit" when nothing is left to commit

- Location: plan:285-286.
- Defect: the session commits before every read, so the tree is already committed at a stop.
- Fold: "stop reading; when blocking findings are open, add the empty commit that lists them, as
  after the third read; report the stop to the user".

### 13. Minor, optional: `page_cap` 2 is close to a resume's worst case

- Location: plan:52 and plan:165.
- Defect: a read reserves about $1.54 today (from `ledger.jsonl`: consistency 0.666, blueprint
  0.878). The `Worst` change adds about 0.065. A resume settles each lost sync intent at its worst
  case and sends it again (`settleLost`, `resume.go`), and the page total accumulates per run. A
  resume after a single lost blueprint send fits under $2. A resume after both seats were lost
  doesn't: it escalates on `cap`, which is a Geoff stop.
- Fold: accept and say so, or set `DRAFTER_PAGE_CAP=4` for the wrapper and let the cycle ceiling
  carry the bound.

### 14. Minor, optional: the push guard doesn't cover a push to a direct URL

- Location: plan:182-183.
- Defect: probed on git 2.56. A push to `origin` exits 128 under the `GIT_CONFIG_*` guard, but
  `git push ../remote.git HEAD:refs/heads/t2` exits 0.
- Fold: none needed beyond the post-check `ls-remote`. Note the gap in the packet.

### 15. Minor, optional: `CLAUDE_ENV_FILE` is stated, not cited

- Location: plan:178-179. The fold's M11 says the mechanisms it added are quoted, but this one
  isn't, and #49's `tweak.sh` didn't use it.
- Proven here: the installed binary reads `CLAUDE_ENV_FILE` from the process environment, loads
  the file's text as the session-environment script ("Session environment loaded from
  CLAUDE_ENV_FILE"), runs it ahead of Bash commands, and caches it for the session. Writing the
  file before launch therefore works, and the loop probe confirms it live.
- Fold: cite it, and add that the file is read once per session.

## Mechanisms checked, with evidence

- **Two cache breakpoints.** The quotes match `prompt-caching.md`: line 9 (exact bytes; a byte at
  N invalidates breakpoints at N and later), line 127 (at most 4 breakpoints), line 135 (512
  tokens on Opus 5.5, with the doc's own "check the prompt caching docs" caveat, which EQ.7's
  live pair covers), and line 144 (1.25× for a 5-minute write). Block 1 is stable apart from
  the prompt. The blueprint read sends no `Facts` to `Build`, so there are no excerpt blocks
  (`stageBlueprintRead` builds `Input` without `Facts`, `blueprint.go:153`). The blueprint seat
  has no `inputs`, so there are no command blocks (cairn `drafter.toml` `[seat.blueprint]`).
  The system prompt and schema are per seat. The facts block varies with `placedFacts`, which is
  why it gets its own breakpoint. The prompt is the remaining variable (findings 2 and 3). Usage
  already parses the per-TTL write fields (`request.go:80-92`).
- **Empty commit plus exit-3 resume.** `checkPosition` (`resume.go:94-108`) takes `HEAD` as the
  recorded head or a descendant. An empty commit is a descendant and leaves the tree unchanged,
  so the "no read saw" comparison holds. The mechanism is sound. Only the command text is wrong
  (finding 1).
- **`DRAFTER_CYCLE_CEILING` and `DRAFTER_PAGE_CAP`.** Both are float env keys
  (`internal/config/env.go:84-85`). The env layer loads after the local file (`load.go:49-53`),
  so it beats `drafter.local.toml`. `Reserve` checks the page cap and then the cycle ceiling
  against settled plus open totals (`ledger.go:125-131`). `ErrCycleCap` halts with
  `StopCycleCap = "cycle cap"`, which exits 3 (`money.go:124-126`, `pipeline.go:23`). A resume
  reads the caps fresh (`resume.go:30-31`). `B` = cycle `total` + `open.worst` matches
  `cycleTotal`'s settled-plus-open measure.
- **`env -u ANTHROPIC_API_KEY` with `apiKeySource` "none".** `~/.bashrc:160-163` already starts
  interactive `claude` this way, for this reason. An executor's Bash commands re-source
  `~/.bashrc:198`, so a bare `claude -p` from a script can inherit the key, and the `-u` is
  needed. The assertion is post hoc, so at most one session can bill before the round halts.
  Acceptable as written.
- **Pinned binary and prompt.** `prompts` is an env key (`env.go:46`). The module is
  self-contained (no imports; `REGISTER` falls back to a repo-relative path). The run copies the
  module at start, so resume uses the run's own copy (`resume.go:30-31`). The wrapper's exports
  override `read.sh`'s own `DRAFTER_PROMPTS` and `DRAFTER_PAGE_CAP`. `make check` builds `./drafter`
  through `prompts-parity: build`, so EQ.0's `<DWT>/drafter` exists.
- **No-key probe.** The key is resolved before any run starts (`read.go:131`), so "creates no run
  directory" holds. The error names the variable ("key_env variable DRAFTER_API_KEY is unset",
  `internal/key/key.go:31`).
- **Path arithmetic.** EQ.0 35 + pair A 60 (max of 40, 60, 45) + pair B 40 (max of 35, 35, 40) +
  EQ.7 65 + EQ.8 120 + Close 30 = 350, with 10 minutes of slack under 360. The task sum is
  35+45+40+60+35+35+40+65+120+30 = 505. The fold's deltas add up: 295+15+10+5+15+10 = 350. EQ.8's
  120 is plausible, since #49's sessions averaged about half a minute of stream time.
- **`money.go` and `resume.go` untouched.** No task lists either file. The new `Message` field
  needs neither: every `batch.Message` literal is keyed (`assemble.go:100`,
  `handle.go:267,311,386`, `smoke.go:249`), neither file reads `Message.Text`, and `saveRequest`
  marshals the whole `Request`, so an exported field rides along (`money.go:169-181`). `Worst`'s
  signature is unchanged (`money.go:97`, `dry.go:36`). Finding 1's `ResumeLine` fix lives in
  `pipeline.go`. EQ.5's `git diff --stat` gate holds.
- **Order.** No docs test ties the check table to the code (`internal/blueprint/docs_test.go`
  checks schema fields and item kinds only), so EQ.1 and EQ.2 can merge in either order. The
  catalog fixture test fails only on errors (`postmerge_test.go:69-71`), so the new warning can't
  break it. EQ.6 uses EQ.2's merged build after pair A, as ordered. The only interim oddity: after
  pair A and before pair B, a request carries the scope sentence twice. That's harmless, since no
  live read runs between the pairs.
- **The reviews' blocker and majors.** C1 closed (plan:516-518, :480, :198). C2 closed
  (plan:491-495). C3, M2, and I16 closed (plan:487-490; see finding 4). C4 closed (plan:416-418,
  :292-294, :304-305). C5 closed (plan:536-542). C6 closed (departures 7 and 12). C7 closed in
  part, as recorded. C8 closed (see finding 8). C9 closed (plan:336-339). M1 closed in substance
  (see findings 2 and 3). M3 closed (see finding 1). M4 closed. I1 and I2 closed (see finding 1
  for the command). I3, I4, I5, I6, and I7 closed. I6's "drop `--add-dir` for the skill" was not
  taken, and the halt-on-change covers it.

## Counts

| Severity | Count |
|---|---|
| Blocker | 0 |
| Major | 3 (findings 1-3) |
| Minor | 12 (findings 4-15; 12-15 optional) |
