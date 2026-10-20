# Plan review, mechanics and feasibility lens: drafter acceptance plan

The `plan-reviewer` agent's reply, saved by the planning session. Target:
`docs-system/plans/2026-10-19-drafter-acceptance-plan.md` at `70ecab5`. Code checked: drafter main
`6b110ad`, cairn-cms main `517158fae`. Host: pavilion. Scratch probes were in the planning session's
scratchpad (a regexp probe, a leak probe, a binary built from main, and a shared clone).

**Verdict:** 1 blocker and 8 majors, all cheap to fold. Finding 6's drafter half cannot hold the case
it was traced from. A resume as written can break the $50 ceiling. The rest are gaps in mechanisms
and in standing answers.

## Verified as stated

- **Finding 3, request bytes.** A separate Answer value that renders today's `readSchema()` and
  contract keeps the blueprint-read bytes identical. `Build` (assemble.go:70-120) reads the Answer
  only through `answerSchema`, the note condition (:86), `inputBlocks` (:123-170) and
  `commandBlocks` (commands.go:27). Neither golden carries a seat `inputs` block. One catch on the
  commands gate, below (M4).
- **Finding 7.** `build` attaches `draftingBlocks` only when `len(hist)==0` (steps.go:109-120). The
  redraft exchange is created with no History: `p.w.Ex = &exchange{Kind: exRedraft, Findings: fs}`
  (steps.go:520). `stageExchange` passes `ex.History` (steps.go:261). So the redraft's first turn
  does carry the blocks.
- **Finding 9.** resume.go has no switch on step names or exchange kinds. The only kind path is
  `p.gateStep(ctx, p.w.PendingGate)` at resume.go:351. `fingerprint.go:14-15` says the caps are read
  fresh on resume.
- **#25 in recordDrafted.** `recordReads` writes `lock.Pages[r.Path] = e` first. `recordDrafted`
  then reads `prior := lock.Pages[r.Path]` and passes `prior.Accepted` to `DraftedEntry`
  (pagebp.go:192-200). So fixing the `scopedAccept` exclusion in `recordReads` (bar.go:80) carries
  into the drafted entry with no other code change; only the comment at pagebp.go:179-182 needs
  updating.
- **Meter.** `drafter spend --since 2026-10-19 --json` has keys `rows`, `total`, `open`. Live today:
  total 86.0216, open `{count 1, worst 0.99695}`, matching the plan. `DRAFTER_PAGE_CAP` is read by
  env.go:84 and only lowers the cap (`putCap`, apply.go:96), so `min(10, …)` is safe.
- **Flags.** Built from main, `page --help` lists dry-run, json, resume, sync, whole, workflow-run.
  `read --help` lists dry-run, json, resume, since, sync. `check-prompts` has `--matrix`. "up to date
  with drafted.lock" is draftscope.go:19.
- **Arithmetic.** 30+150+45+20+45+45+75+90+45+60 = 605. Build segment = max(150, 75, 90, 60+45) =
  150.
- **File disjointness.** A1 and A2 are disjoint, and stay so after the M4 file additions. C1
  (scripts/checks, tests, `drafter.toml`, BACKLOG.md), C2 (facts) and C3 (blueprints) are disjoint.
- **Finding 6's facts.** The old `failure_pattern` matches 0 lines in both gate-4 logs; the probe
  confirms it.
- **Other.** Finding 8's T3 claim holds: scanning `blueprints/` as T3 gives 0 findings. `drafter
  check` passes (0 errors, lock mismatch only a warning) after a committed blueprint edit, probed in
  the clone.

## Blocker

**B1** (correctness). Location: Run rules, plan:659-662 (resume commands); R1 rereads, :563-566; R5
reads, :640-641.

- **Defect:** the caps are read fresh on resume (fingerprint.go:14-15, `Page: r.cfg.PageCap` at
  money.go:45). `ACC page --resume <id> --json` and `ACC read --resume <id> --sync --json` carry no
  `DRAFTER_PAGE_CAP`. A resume therefore runs at the user layer's `page_cap = 10`, whatever `left/N`
  the meter allows, which can pass the $50 hard ceiling. The rereads are also described ("the same
  command … only those blueprints' paths") rather than written out, so N, and so the cap, is never
  recomputed.
- **Fold:** write each in full with the env var, e.g. `DRAFTER_PAGE_CAP=<min(10, left/N)>
  /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --resume <id> --json`,
  where N is the run's unfinished pages. Same for the read resume, and for the R1/R5 reread with
  `--since <BASE> --sync --json <paths>`. Also fix "Every read in this pass passes `--since <BASE>`"
  (:565): `--since` and `--resume` are mutually exclusive (read.go:72-74), so except resumes.

## Major

**M1** (correctness). Location: plan:104-114 (finding 6) and A1's #23 bullet, :348-351, :377-380.

- **Defect:** A1's rule ("treat an unparsed red as foreign when its tail names … another page … and
  names neither this page nor its brief") cannot fire on the traced case. `Tail` is the last 60 lines
  (`tailLines = 60`, run.go:22, :225). The gate-4 logs are 217 lines and the sibling line is line 50,
  so the tail names no sibling page and the rule falls to "stays own".
- A whole-log scan fails too. Both logs name this page in check:snippets' opted-out listings
  (security-model 2 hits, add-a-second 5). So the A1 test "tail copied in shape from B3c's gate-4
  log" passes only on a fixture that differs from the real log.
- C1's `failure_pattern` is the half that works: the candidate `^  \S+:[0-9]+  \[[a-z-]+\]  `
  matched exactly line 50 in both logs. Once parsed, the existing `ForPage` already holds the page.
- **Fold:** make #23's drafter deliverable a pipeline test that parses a full-length synthetic log
  with cairn's new pattern and holds the page. Either drop the unparsed-tail rule, or keep it and add
  a test row stating its limit (a log that also names this page stays own).

**M2** (correctness). Location: A1 snippet bullet, :352, :381-384; finding 7, :119-121.

- **Defect 1, the tracked-only guard:** `fileBlock` (files.go:221-236) does no tracked check; that
  lives in `repo.resolve` / `trackedRel` (files.go:127-164). It is also unexported, and
  `draftingBlocks` is in package pipeline.
- **Defect 2, the "not inlined" row:** today an untracked token is skipped silently, so "an
  untracked … file gets fileBlock's 'not inlined' line" asserts behavior nothing has. An implementer
  who trusts the plan could send an ignored local file's contents to the API.
- **Defect 3, file list:** A1's list omits `internal/assemble/files.go`.
- **Defect 4, directory sources:** scaffolded-site-files has directory sources
  (`../../templates/waymark`, `…/src/routes`). `fileBlock` returns `("", false)` for these, and that
  case is untested.
- **Fold:** add an exported assemble helper that resolves through `repo.resolve` (tracked, symlink
  within root) and returns a "not inlined: untracked" block, never contents. Add files.go to A1. Add
  test rows for an untracked file (no contents sent) and a directory source (nothing added).

**M3** (correctness). Location: R1-R5 fact fixes, :562-569, :640-642; Check 3, :682-685; Close 2-3.

- **Defect:** a fact edited after a page is accepted breaks that page's "up to date with
  drafted.lock". `pageScopeFor` rebuilds the facts the entry's draft saw (draftscope.go:121-124).
- It also leaves earlier R1-accepted blueprints that cite the fact unread. `skipRead` compares only
  the blueprint blob (draftscope.go:111-113), so the edited fact is never read for them.
- Shared facts are common: `f:qlgggh` is cited by six pages' dispositions and `f:hwffph` by six
  (factsheet-cairn §6).
- **Fold:** before any post-C4 fact edit, run `ACC refs f:<id>`. Prefer a blueprint-side fix when an
  accepted or R1-accepted page cites the fact. Otherwise reread every citing blueprint, and rerun or
  report each accepted citer inside the budget. Make this a standing answer and list it in
  `## Decisions`.

**M4** (correctness). Location: A1 kind bullet, :333-336; files, :324-326.

- **Defect:** `commandBlocks` runs seat `inputs` only for `AnswerDraft`/`AnswerRead`
  (commands.go:27). A new blueprint-read Answer value silently drops `[seat.blueprint] inputs`; no
  golden carries them, so nothing would catch it. If the split goes the other way (a new review
  value), cairn's review seats lose `vale` and the round-2 diff.
- Also: `TestSchemasKeepToStructuredOutputLimits` iterates a fixed Answer list (schema_test.go:65),
  and `internal/smoke/shapes.go:49` names AnswerRead for the blueprint seat.
- **Fold:** name commands.go:27, schema_test.go:65 and shapes.go in A1. Add a test row: a blueprint
  seat with an `inputs` command still carries its command block.

**M5** (correctness, OWNER FORK at close). Location: C3 acceptance, :500-501; C1 `--range
BASE..HEAD`, :453-454; Close 4, :704-707.

- **Defect:** the fast lane for `blueprints/**` or facts runs tree-mode `check:provenance` and
  `check:docs-gate` (factsheet-cairn §10). The live briefs of the seven still cite edited facts with
  names the fixes remove. Probe hits:
  - scaffolded's brief: `LICENSE` and `.dev.vars.example` under `f:qlgggh`, `.dev.vars.example`
    under `f:nls26c`;
  - security-model's brief: `clone` under `f:keuj8l`;
  - restrict and security-model briefs: `tidy` under `f:cvv6to`;
  - add-a-second's brief: `.dev.vars.example` under `f:nls26c`.
- So C3's "line 1 green" is likely unreachable until the reruns. At close, any escalated page keeps
  its live brief, and CI's whole-tree docs gate (test.yml:144) goes red.
- **Fold:** standing answer: before the reruns, a tree-mode red confined to the seven pages' live
  briefs is expected; record it, don't stop. Run C1's lane before C2/C3 commit, or with an explicit
  path range.
- **OWNER FORK for an escalated page at close:**
  - (a) hand-fix its live sentence and brief to the fixed fact. It is not a drafted page, so Check
    3's rule doesn't bar it. **Recommended.**
  - (b) leave CI red and report it.
  - (c) revert that page's fact fixes. This is barred by standing answer 5.

**M6** (correctness). Location: A0 step 1, :293-294.

- **Defect:** `pgrep -f worktrees/acceptance` always matches its own `bash -c` wrapper. Probed:
  `pgrep -af 'worktrees/zzznotthere-q'` returned the wrapper shell. It also substring-matches
  `worktrees/acceptance-plan` and `-pages`. A literal "finds nothing" never holds.
- **Fold:** `pgrep -af '[w]orktrees/acceptance(-pages)?([ /]|$)'`, which printed nothing in a probe.

**M7** (correctness). Location: A3 step 2, :517-518 ("a whole-tree component red stops the line");
A0 step 2, :300 ("a red baseline stops the line").

- **Defect:** neither stop has the traced-cause standing answer.
- **Fold:** a red traced to this branch's commits (C1's check changes, or `blueprints/` now scanned
  by leaks) is fixed forward on the branch under answer 4. Only a red from `origin/main` that the
  branch can't fix stops. The A0 gate is re-issued on exit 75, as Close 1 says.

**M8** (correctness). Location: R4 :611 vs :629, R2 :593, R5 :636-644; R1 check, :570-571.

- **Defect:** only R3 says "Only pages whose blueprint accepted in R1 are in the call". The R1 check
  (lock `accepted` == `HEAD:<blueprint>`) passes without proving anything for a blueprint whose read
  blocked on a facts-only change, since a blocked change read writes nothing (bar.go:85-90).
  `skipRead` would then draft past the blocked read.
- **Fold:** take R1 acceptance from each page's read summary status, and put the "R1-accepted only"
  line in R2, R4 and R5.

## Minor

- **m1** (correctness). A3 step 3, :521-525. The lock edit must be committed. `scopeFromLock` reads
  `committedLock(…, head)` (draftscope.go:80), and `requireClean` runs on dry runs too
  (start.go:128). The stub also must return the `anthropic-workspace-id` header, or
  `CheckWorkspace` fails (client.go:81-104). Fold: restore B3c's wording ("commit one lock edit",
  `{"input_tokens": 1000}`, the header).
- **m2** (correctness). Findings 4/5, A1 small-kind classification. The structured-output docs say
  enum casing is not guaranteed: "Structured outputs don't guarantee the capitalization of string
  enum … values… Compare enum values case-insensitively"
  (platform.claude.com/docs/en/build-with-claude/structured-outputs). Fold: compare kinds with
  `strings.EqualFold`, and add a test row ("Link" is small).
- **m3** (correctness). Finding 5 / A1, :344-346. The empty state is unnamed. A round-2 seat answers
  `fix` with zero blocking findings, so "all small" holds vacuously and opens an empty exchange.
  Fold: such a fix escalates as today, plus a test row.
- **m4** (correctness). C1 and C2/C3 commits, :423-424, :496-498. They run concurrently in one cairn
  worktree, so "`git status --porcelain` names only them" can't hold while the other is in flight.
  This is also outside pass-core "Pairs" (isolated worktrees) and the one-executor rule. Fold: commit
  with explicit pathspecs, check `git status --porcelain` against the union of the in-flight file
  sets, and state why sharing the worktree is safe.
- **m5** (correctness). C1 acceptance probe, :449-451. "At least one match where there were 0" is
  weak. Fold: require the match to be the line 50 shape only, and no match on check:snippets'
  `  docs/…md:NN  <reason>` lines. Those name this page, and matching them would make the section own
  again.
- **m6** (correctness). C1 #15, :434-435. The tokenizer `/[\w./@-]+/g` (check-symbols.mjs:314)
  never includes `#`, so no token "opens with #". Fold: test the character before `m.index`.
- **m7** (correctness). R1 fix subagent, :562-563. `ACC check <its blueprint>` skips the facts-store
  pointer check ("With no blueprint named it also verifies the facts store", `check --help`). Fold: a
  fact fix runs `ACC check` with no argument, plus `npm run check:facts` through `cairn-run-gate`.
- **m8** (correctness). Pre-flight, :36-47. It never names the host, yet C1's probe reads a log that
  exists only on pavilion's state dir, and the ledger is per machine. Cycle headroom is also
  unchecked: `drafter spend --json` shows 100.71 + 0.997 against `cycle_ceiling = 160`, leaving
  $58.3 today. Spend between planning and A0 shrinks that below $50 with no standing answer. Fold:
  add "Host line is `pavilion`" and "cycle total + open.worst ≤ 110".
- **m9** (correctness). Executor models, :211. A1 on Opus at `high` departs from pass-core "Models"
  ("All other Opus work … runs at `medium`") with no measured gain cited. Fold: run A1 at `medium`,
  or cite evidence for `high`.
- **m10** (correctness). A1, :334. Whether `AnswerReader2` (which shares `readSchema`, schema.go:19)
  gains `kind` is unstated. Fold: state it, and its `TestSchemaShapes` row.
- **m11** (optional). C4, :537-546. It is a 20-minute, single-deliverable, conditional task. Fold:
  fold it into A3's tail.
- **m12** (optional). A3 grep, :530-531. It lists only "declaration not found". `missing` and
  `untracked` excerpts (excerpt.go:57-82) also starve the fact seat. Fold: grep "no excerpt:".
- **m13** (optional). A2 golden row, :416, and A1's "A2 runs the second", :375-376. In A2's isolated
  worktree, without A1's change, that check proves nothing. Fold: say the binding check is A3's
  post-merge `make check`.

## OWNER FORKs (minor, optional)

- **F1: finding 2's reading.** The design says the page "accepts if they pass". The plan sends a
  round-2 small fix to the final reader instead, which adds a seat that can escalate and lowers the
  odds against the 5-of-7 bar.
  - (a) The plan's reading, the reader still runs. **Recommended:** every page passes the reader.
  - (b) Accept at once, as the design's text literally says.
- **F2: snippets for the review seats.** Per the design, only the draft seat gets the snippet files.
  The fact and structure seats then check a quoted code block from memory, and a `code` finding is
  not small.
  - (a) Draft seat only, as the design says.
  - (b) Also the fact seat, which is a one-line change to the `draftingBlocks` seat switch.
    **Recommended**, for claude-code's acceptance.
