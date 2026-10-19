# drafter pass B3c plan: cairn's pilot pages

Initiative: docs-system

Path estimate: 795 minutes against the design's 400 (1.99x), inside the 800-minute standing
answer by 5 minutes. The arithmetic is under "Outcome". The plan review's fold is
`docs-system/research/2026-10-19-drafter-b3c-plan-fold.md`.

Design: `~/Projects/initiatives/docs-system/specs/2026-10-19-drafter-b3c-cairn-pilot-design.md`,
approved by Geoff on 2026-10-19 (glw907/initiatives#39). It carries his ruling on drafter backlog
#13 from chat on 2026-10-19 ("That works"). He ruled both asks as recommended:

- **Budget $80.** The pass may spend $80 of live API money, with the existing $10 page cap.
- **All eight pages.** Every non-figure stage 2b page drafts, smallest first, behind the rotate
  probe. A probe that escalates for a cause this plan can't fix stops the line.

The B3 rulings carry over: `internal/pipeline/money.go` and `internal/pipeline/fingerprint.go` are
never edited, and an edit to `internal/pipeline/resume.go` is written test-first, with a task-scope
`diff-reviewer` read, auth-data bar included, on each commit touching it before the next task
starts.

Code: facts are quoted at drafter `3c2c5cb` (branch `worktree-b3-drafting`, PR glw907/drafter#53,
open) and cairn-cms `main` `11104274e`. B3c launches only after Geoff merges #53 and the main
checkout runs `make install` (B3's merge order). Lines move; the executor finds each quoted symbol by
name. The factsheet is `docs-system/research/2026-10-19-drafter-b3c-factsheet.md`; B3's two
factsheets (`…-b3-factsheet-pipeline.md`, `…-b3-factsheet-provenance.md`) still hold for the
pipeline's internals. Planning probes ran on 2026-10-19 in
`/tmp/claude-1000/-var-home-glw907-Projects-drafter/98272137-e879-4cd3-b816-037dd2bfda73/scratchpad/b3c-probes/`,
against a binary built from `3c2c5cb` and a shared clone of cairn, with no API call.

## Findings for the planning session

None of these changes the approved design. Each is decided below; the ones marked "contestable"
are method calls a reviewer may want to argue.

1. **The chain can't draft a blueprint page today, so its fix is most of the module work.** The
   design's item 4 says the chain "gains the `coherence` seat". The probe shows more. Rendered with
   a blueprint page's context and no chain args, the chain's `draft` and `editor` seats throw
   ("unknown track", then `GATE.replaceAll` on `undefined`), and `structure`, `editor`, and `fact`
   name "the worktree undefined", the v1 plan, and the framing record (factsheet, "The prompts
   module cairn loads"). drafter inlines any tracked file a prompt names, so a seat naming the v1
   plan would also be sent that stale plan beside the blueprint. B3c.3 gives every back-half seat
   a blueprint mode, keeps handoff mode byte-identical, and adds `coherence`. This sits inside the
   design's "cairn's module drafts" and its call that cairn keeps the chain. It's the second-largest
   task on the path.
2. **Conversion leaves 524 `drafter check` errors, and one plan doesn't convert.** Probed on a
   clone: the seven converted blueprints fail with 173 sections missing a `why`, 345 `use` fields
   that don't open with Only or Omit, 3 blueprints with no `framing.introPlan`, and 3 id errors.
   security-model's framing record uses two headings the converter doesn't know. The design treats
   conversion as mechanical; rotate's own conversion needed the same reshape by hand (its commit
   `80b7a9079`). B3c.4 runs the reshape with one subagent per page in the pair's shadow, so it adds
   no path minutes, and converts security-model from a scratch copy with the two headings renamed.
   The design also says only claude-code lacks a framing record. debug-your-site and
   restrict-admin-access lack one too; their intro plans are written from their v1 plans'
   `introduction` blocks.
3. **claude-code drafts against the extend track, and its arm stays unregistered.** The page has
   no file, no framing record, no register track section, no arm index, and no gate registration
   (factsheet, "claude-code"). The plan's own friction note says it "takes the extend track's
   reader profile as the baseline, per the outline's `job`", and that the arm's gate registration
   is needed "before the page can ship". The design keeps stage 2b's close work out of scope, and
   B3c ships nothing. So the chain's blueprint mode reads the extend track's register sections for
   a `docs/claude-code/` page, and the arm registration and the register's claude-code entry stay
   with stage 2b's close (Later). cairn's docs gate doesn't refuse the page; it checks it only in
   part. `check-leaks`, `check-snippets`, `check-symbols`, `check-visuals`, `transcript-blocks`,
   and `check-arm-indexes` walk fixed arm lists that leave out `docs/claude-code`
   (`check-leaks.mjs:473-492`, `check-snippets.mjs:60`, `check-symbols.mjs:68`,
   `check-visuals.mjs:37`, `check-arm-indexes.mjs:41`, `ARM_DIRS` at `arm-state.mjs:28`). Only
   Vale and tellgrader on `--page`, provenance on `--brief`, and the link walk read it. The page
   drafts as planned, and the cairn PR's acceptance table names each gate component that skipped
   `docs/claude-code` (settled by the planning session, 2026-10-19). The alternatives
   were to add the registration and a register entry to B3c's cairn PR (code in cairn's
   `scripts/checks` and register prose, both outside the design), or to drop the page (against
   Geoff's "all eight").
4. **The bar lives in `drafted.lock` (contestable).** The #13 rule needs the blocked read's commit
   and findings to survive between reads. The lock is committed, travels to either workstation,
   and is where `accepted` already lives, so an entry gains an optional `blocked` field (resolution
   1). The lock decodes with `KnownFields` (`lock.go:60`), so a pre-B3c `drafter read` or `drafter
   check` refuses a lock that holds one. A pre-B3c `drafter page` doesn't: `scopeFromLock` treats a
   lock that fails to decode as empty (`draftscope.go:69-75`), so it drafts whole and fails only at
   the lock write. The guard that stops every pre-B3c command is the config: `brief_path` fails
   the strict decode (`file.go:98-106`; probed, "unknown key blueprints.brief_path", exit 2). The
   drafter PR therefore merges and installs before the cairn PR merges (Merge order), and this
   pass's binary refuses a lock that fails to decode on the page path too (resolution 1). The
   alternative, a file in drafter's state directory, would lose the bar on the other workstation
   and break the onboarding rule.
5. **Check 1 may move off rotate.** Rotate's blueprint was edited after its last API read
   (`dca26f670`: "This commit has not been read through the API"), and it may accept on its first
   whole read. Then no second read is needed on rotate, and Check 1's row (a whole read blocks, a
   fix, a bar read accepts) is taken from the first of the other seven whose first read blocks.
   The offline test proves the mechanism either way. When no page blocks and then accepts, the
   cairn PR reports Check 1 as "mechanism proven offline (the e2e test's name), not observed live",
   and #13 stays open with that note.
6. **The seven's first read runs with the probe's read (contestable).** The design orders "the
   probe, then the other seven". The plan keeps that order for drafting, but reads all eight
   blueprints in the probe's first `drafter read` call, so the seven's first fixes run in the shadow
   of the probe's draft. A read costs about $0.19 (factsheet, "Money"), so a probe that stops the
   line wastes about $3 of reads. Reading the seven after the probe would add about 45 path minutes
   and put the plan over 800.
7. **The order is by blueprint length (contestable).** The design ranked pages by their current
   line counts, and claude-code has no page. The plan ranks by converted blueprint length, which is
   what each draft reads and the best proxy for its cost: claude-code 626, debug-your-site 1145,
   restrict-admin-access 1312, scaffolded-site-files 1452, security-model 1612,
   add-a-second-sign-in-group 2246, add-cairn-to-a-sveltekit-app 2871. Wave 1 drafts the first
   four, wave 2 the last three.
8. **The budget is held per call.** A multi-page call can spend a page cap on each page, so each
   live call sets `DRAFTER_PAGE_CAP` to the lesser of $10 and the budget left divided by the pages
   in the call. That is the design's rule for a one-page call and stricter for a wave. The meter
   follows B3's formula, so the $1 B3 left reserved by a cancelled batch counts against B3c, which
   errs safe by $1 (resolution 7).
9. **A fault escalation gets one rerun.** B3 found about one reader call in four stopping at its
   token ceiling at about $1.2 (drafter backlog #18, Geoff's open ruling in B3's packet). cairn's
   reader runs on the chain's prompt at `medium`, so the rate here is unknown. A page that escalates
   on a fault (a seat answer cut at `max_tokens`, an answer that doesn't parse, an API failure) is
   rerun once, alone, after wave 2, inside the budget. That is the "retry each" the budget packet
   priced. A verdict escalation isn't rerun.
10. **The probe runs `--sync`, the waves run batch.** The run mode is in the config fingerprint
    (`fingerprint.go:18`), so a stopped run can't switch. Sync costs twice as much and returns in
    minutes; the probe's path time matters more than its cost. The waves batch several pages at
    half price. B3 met a batch stuck for 110 minutes; resolution 8 gives the rule. The page cap is
    checked against the page's settled spend plus each new reservation at its worst case
    (`ledger.go:125`), so a sync probe late in its run can reach the $10 cap before its actual
    spend does. A probe that escalates on `cap` therefore reruns once, as a fresh batch run at half
    the price (resolution 8).

## Outcome

cairn's eight non-figure stage 2b pages each end accepted or escalated with a recorded finding and
stop rule. Each accepted page has an accepted blueprint, a whole draft through the chain's review
seats and cairn's docs gate, and a lock entry. drafter gains three things:

- A whole read that blocks records its commit and blocking findings in the lock. The next read of
  that blueprint runs as a change read since that commit, with those findings as its bar, and an
  accept writes `accepted`. This holds for `drafter read` and for the read that starts `drafter
  page`.
- `drafter page --whole` drafts a page whole on purpose.
- A `blueprints.brief_path` setting carries cairn's legacy brief path.

The chain drafts blueprint pages and defines `coherence`.

- Risk class `runner`: the chain is a workflow module, and the pass changes drafter's read loop.
  It's `live-account` for API spend only. No GitHub, Cloudflare, or npm account is touched beyond
  pushing two branches and opening two PRs.
- Repos: `glw907/drafter` (resolutions 1 to 4) and `glw907/cairn-cms` (blueprints, `drafter.toml`'s
  brief path, drafted pages, briefs, and `drafted.lock`, on one branch).
- `internal/pipeline/money.go` and `internal/pipeline/fingerprint.go` are never edited; a need to
  edit either stops the line. No `resume.go` edit is expected: the new `work` fields are `omitempty`,
  and `resume.go` has no switch on step names (B3 factsheet, "Step machinery").
- Path estimate: 795 minutes, against the design's 400 (1.99x), inside the 800-minute standing
  answer. The path is the longest chain of tasks run in sequence, a pair counting once at its
  larger estimate (pass-core, "Plan"). The chain:
  - B3c.0: 30.
  - B3c.1: 40.
  - Pair A: 215. B3c.2 (215) runs beside B3c.3 (175), and the session runs B3c.4 (125, cairn
    conversion and reshape) in the pair's shadow, so the segment is max(215, 175, 125) = 215.
  - B3c.5, merge, named-test check, build, cairn setup, and the real-context render check: 50.
  - B3c.6, the probe: 115.
  - B3c.7, the seven's read loop after the probe: 90.
  - B3c.8, wave 1: 90.
  - B3c.9, wave 2: 100.
  - Close: 65.

  The sum is 30 + 40 + 215 + 50 + 115 + 90 + 90 + 100 + 65 = 795. The design's 400 priced the
  coherence seat, not the chain's blueprint mode (finding 1), and priced conversion as mechanical
  (finding 2, kept off the path by the shadow). Batch waits and the blueprint fixes between reads
  are most of B3c.6 to B3c.9. cairn's docs gate runs inside each draft; Check 2 reruns it once, at
  close, on one package build (resolution 9). A fault rerun (finding 9), a cap rerun, and a stall
  are contingent and not on the path; one 60-minute stall would pass 800, and the PR's score names
  it if it happens.
- Clock file: `pass-task-clock` in the session worktree's git dir (`git rev-parse
  --absolute-git-dir` run in `.claude/worktrees/b3c-pilot`). During the pair it holds the task the
  session runs in the shadow. When the pair returns, the session checks each pair task against
  twice its estimate, then runs `go test -run '<the task's named tests>' -v` on the task's
  packages and confirms each named test shows `PASS` and none `SKIP`. The chain's Node tests use
  their own `check(name, fn)` harness, which `go test -run` doesn't reach; B3c.3's acceptance
  says how those rows are confirmed.
- Executor session name `drafter-b3c-pilot`, launched on `claude-opus-5-5` at `medium`, not
  pass-core's Sonnet default: the session fixes the probe's blueprint, judges each live escalation
  against the stop rules, and spends live money. Worktree name `b3c-pilot` (branch
  `worktree-b3c-pilot`). Each pair subagent's `description` is `b3c-pilot task <n>`, and each cairn
  subagent's is `b3c-pilot <page slug> <reshape|fix r<n>>`. Models:
  - B3c.2 runs on `opus` at `high`: it changes the read loop's contract, the lock format, and the
    pipeline's read scope, and it may touch `resume.go`.
  - B3c.3 runs on `opus` at `high`: the probe shows every back-half seat breaks on a blueprint
    page, and the live drafts depend on these prompts.
  - The reshape and fix subagents (B3c.4, B3c.6, B3c.7) run `general-purpose` on `opus` at
    `medium`: each writes blueprint judgment (a section's why, a scope-only use, a read finding's
    fix) that a paid read then grades.
- Standing answers (design, "Standing answers"; Geoff, 2026-10-19):
  1. A plan within 800 path minutes launches unattended once B3 merges.
  2. Live spend up to $80 for this pass runs without asking, as a hard ceiling (resolution 7).
  3. An escalated page is reported and the run continues. An escalated probe stops the line
     unless resolution 8's probe fixes apply.
  4. A finding that changes the design, or spend past $80, stops and asks Geoff: STATUS carries
     one question, and `notify-send -u normal` tells him.
- Depends on, checked at launch:
  - B3 is merged to drafter `main` (PR #53) and installed: `drafter page --help` lists blueprint
    arguments, and `ls -la ~/.claude/workflows/docs-page-chain.js` points into the main checkout.
    B3's worktree is gone.
  - One executor per worktree: `pgrep -f .claude/worktrees/b3c-pilot` and `pgrep -f
    worktrees/b3c-pilot-pages` find nothing; `claude agents --json` shows no session working in
    drafter other than the launching conductor's; `git -C ~/Projects/cairn-cms worktree list` shows
    no `b3c-` worktree. The `repo-organization` worktree belongs to another session and is never
    touched.
  - Clean main checkouts: `~/Projects/drafter` and `~/Projects/cairn-cms` each print nothing for
    `git status --porcelain`, each is on `main`, and `git rev-list --count HEAD..origin/main`
    prints 0 after `git fetch origin`.
  - Tools: `go version`, `node --version`, `vale --version` (3.x), `yq --version` (4.x),
    `cairn-run-gate`, `ci-green`, and `cairn-docs-outline` resolve. `DRAFTER_API_KEY` is set in the executor's environment (check
    that it's set; never print it). `drafter config` in cairn's main checkout resolves `page_cap =
    10` and `cycle_ceiling = 160` from the user layer. `~/.config/drafter/cairn-cms.local.toml`
    exists.

## Design resolutions

These are the method calls the design leaves to the planner. Each is decided here, and the executor
doesn't reopen one without stopping the line.

### 1. The read bar (drafter backlog #13)

**The lock field.** `LockEntry` (`internal/blueprint/blueprint.go:185-195`) gains `Blocked
*Blocked` (`yaml:"blocked,omitempty"`), after `sections`. `Blocked` holds `commit` (the full sha
the blocked read read) and `findings`, a list of `{location, text}`. The lock's version stays 1.
`LockIntroducedAt` compares only `page`, `blueprint`, and `sections` (`drafted.go:64`), so the walk
ignores the new field, and a test pins that. `docs/blueprint-format.md`, "drafted.lock", documents
the field.

**Recording.** A read that judged the whole blueprint and returned `fix` records a bar. "Judged the
whole blueprint" means the page's read was not a change read (`changeRead()` false). The pipeline
says so in the summary. `work` gains `whole_blocked` (`omitempty`, like `bar` and `bar_from`), set
in `completeBlueprintRead` when the verdict is `fix` and the read wasn't a change read, and
`PageResult` gains `WholeBlocked bool` (`json:"whole_blocked,omitempty"`), which `summary()` copies
from `work` (`pipeline.go:233-250` builds each result from `p.w`). Keeping it in `work` lets a
resume rebuild it. It's set before the consistency branch, so a page escalated on a conflict whose
blueprint verdict was also `fix` still records its findings. The command layer writes the bar after
`pipeline.Run` returns, through one lock helper that `drafter read` and `drafter page` share. The
helper replaces `recordAccepted`'s loop and runs before `recordDrafted`'s entries, under the same
worktree lock, in one write. Like `recordAccepted`, it does nothing on a dry run or a stopped run.
`drafter read`'s lock-write error takes `pagebp.go:96-107`'s shape: the summary prints first, then
the error with the resume line (today `read.go:154-156` returns before the summary, so a failed
write would lose the findings). A resume of that finished run writes the bar and makes no API
call, as B3's `TestDraftFailedLockWriteIsWrittenByTheResume` (`e2e/draft_rows_test.go:237`) shows
for `drafter page`.

- The bar's `commit` is the run's start commit. Its `findings` are the page's blocking
  `PageResult.Findings`, in order.
- A bar read that blocks leaves the bar as it was. The bar stays fixed at the first blocked whole
  read, and each later read judges the change since that commit against those findings, so a
  defect an earlier fix added is still in the diff it judges.
- A whole read that blocks on a page that already holds a bar replaces it. This happens only when
  `--since` or a `Compare` fallback made the read whole.
- A `fix` verdict with no blocking finding records no bar, since there's nothing to hold the next
  read to; that read is whole.
- A page with no lock entry (claude-code) gets an entry holding only `blocked`. A later accept
  leaves only `accepted`, and a draft writes a full entry with no `blocked`. `LockEntry`'s comment
  (`blueprint.go:185-195`) names the bar-only shape. `drafter check`'s `lockEntries`
  (`internal/blueprint/check.go:360-385`) gives a bar-only entry for a page the outline doesn't
  list the same error it gives an accepted-only one.

**Clearing.** An accept that writes `accepted` clears `blocked`. Two accepts do: one on a read that
wasn't scoped, as today, and one on a bar read. `scopedAccept` (`read.go:360-362`) returns false for
a result with `BarFrom` set (below), and it tests the read's scope, not the draft's:
`PageResult.Scope` is `p.w.Scope`, the draft scope (`pipeline.go:237`), so in `drafter page` a bar
read that fell back to whole beside a scoped draft would otherwise count as a scoped accept and
write nothing. `PageResult` gains `ReadScope` (`omitempty`), filled from the read accessor below,
and `scopedAccept` reads it when set. That lets `recordAccepted`'s rule and `recordDrafted`'s rule
(`pagebp.go:211-214`) both write `accepted` after a bar accept. A drafted page's entry carries no
bar, because `DraftedEntry` builds a fresh entry (`drafted.go:15-39`).

**Applying it in `drafter read`.** With no `--since`, and when the lock as committed at the start
commit holds a bar for the page, the page's read is the bar's change read:

- `scopePages`' comparison runs for that page with `since` set to the bar's commit, so each page
  gets its own `since`. The change block is built as today.
- `Compare` gives `ScopeUnchanged`: the page isn't read. It reports the line "unchanged since the
  blocked read at <short sha>; fix its <n> findings and commit" with its own status, `held`, not
  `statusUnchanged`, since `exitCodeFor` maps `statusUnchanged` to 0 (`page.go:65-72`). `drafter
  read` and `drafter page` exit 1 when any page is `held`, since that blueprint isn't accepted.
  `drafter read`'s early return when no page is left to read (`read.go:131-142`) skips
  `exitCodeFor` today, so it must map `held` to 1 as well.
- `Compare` gives `ScopeWhole` (the bar's commit is gone, or the blueprint didn't decode there): the
  read is an ordinary whole read, with no bar. When the commit is gone, drafter prints "the blocked
  read's commit <short> is not in this repository; reading whole", so a bar lost to a squash or
  rebase merge is visible.
- `Compare` gives `ScopeScoped`: the read is a change read, and its `findings` carry the bar.
- `--since` given: no bar applies, and the read is exactly today's.
- A resume reads everything from state, as today.

`pipeline.Options` gains `Bars map[string]string` (the rendered bar, keyed by page path) and
`BarFrom map[string]string` (the bar's commit). `addPages` copies both into `work` as `bar` and
`bar_from` (`omitempty`), beside `Since`, `Scope`, and `Change` (`start.go:276-278`). `PageResult`
gains `BarFrom string` (`json:"bar_from,omitempty"`). The rendered bar is one line per finding,
`<n>. [<location>] <text>`, numbered from 1.

**Applying it in `drafter page`.** A page whose committed lock entry holds a bar, and whose read
isn't skipped, reads with the bar's change read. Its draft scope stays what `scopeFromLock` or
`--whole` decided. So the read's scope is kept apart from the draft's:

- `Options` gains `ReadScopes map[string]blueprint.Scope` and `ReadChanges map[string]string`.
  `addPages` copies them into `work` as `read_scope` and `read_change` (`omitempty`).
- Two accessors return the read fields when set and `Scope` and `Change` otherwise. `changeRead()`
  (`blueprint.go:61-63`), `stageBlueprintRead`'s scope and `Extra` (`blueprint.go:145-153`), and
  `untouched` (`blueprint.go:191-215`) read through them.
- `changedSections`, `bound`, `sectionScope`, and `draftingBlocks` keep reading the draft scope.
- `drafter read` never sets the read fields, so its scope is `Scope`, as today.
- A bar page whose comparison gives `ScopeUnchanged` isn't run, with the line above, and `drafter
  page` exits 1.
- `SkipRead` wins. When `accepted` equals the blueprint blob, no read runs and the bar is ignored.
  An accept clears the bar, so the two meet only after a hand edit.

**The prompt.** The blueprint seat gets the bar as the context's `findings`, set only on a bar read
(`stageBlueprintRead` sets `c.Findings = p.w.Bar`). Both modules gain one paragraph under the
change-read text, rendered only when `findings` isn't empty:

- The change answers the earlier findings listed, which are quoted in full.
- For each finding, the read judges whether the change fixed it. One the change didn't fix is a
  blocking finding at its location, and its text starts "Still open:".
- A defect the change adds or causes blocks, as the change-read rule already says. Any other defect
  stays non-blocking and starts "Already present:".
- A listed finding the change didn't fix blocks whatever its class. This overrides the change
  read's Nit rule, which makes order, pace, heading form, field placement, and a restating `use`
  non-blocking and says "A Nit never makes the verdict fix" (`stock/prompts.js:164-169`, the
  chain's copy at about `:2365-2370`); without it, a bar read could accept with a blocking
  whole-read finding of those classes unfixed.

With `findings` empty, every rendering is byte-identical to today. F2's six stock goldens, the
chain's blueprint goldens, and B3.0's two read-request goldens pass unedited. `check-prompts`'
containment check already requires a prompt to hold its context's `findings` whole
(`checkprompts.go`, "containment"), so both modules quote the bar in the prompt.
`docs/prompts-module.md`, "The context object", says what `findings` means for the blueprint seat.

Before this pass, a read with a bar couldn't happen. A bar is written only by this pass's binary,
so an older state or lock holds none. A lock that fails to decode is refused, naming the file, by
both the bar lookup and `scopeFromLock`. Today `scopeFromLock` treats it as empty
(`draftscope.go:69-75`), which would drop every bar, `SkipRead`, and entry without a word and fail
only at `recordDrafted`'s `ReadLock` after the spend.

### 2. `drafter page --whole`

`pageFlags` (`page.go:22`) gains `whole`, registered as `--whole` with the usage "draft each page
whole, whatever its lock entry says".

- With it, `scopeFromLock` gives every page argument `ScopeWhole` with `Why` "drafted whole on
  request (--whole)", and no page is "up to date". `SkipRead` and the bar apply as they do without
  the flag.
- `--whole` with `--resume`, with handoff files, or with `--workflow-run` is a usage error. A
  resume reads the scope from state.
- `drafter page --help`'s `Long` gains one sentence. `docs/blueprint-format.md`, "What `drafter
  page` does with a blueprint", gains a paragraph that says this is how a converted page is first
  drafted.

### 3. The brief path setting

`blueprints.brief_path` (project and local layers, as `blueprints.root`) is a template for a page's
brief path, relative to the project root.

- `{dir}` is the base name of the page's directory, and `{name}` is the page's file name without
  `.md`.
- Unset, the brief sits beside the blueprint, as today.
- The template must contain `{name}`, so pages can't share a brief, and must stay inside the
  project, as `blueprints.root` must. Otherwise the configuration is refused, naming the key.
- cairn's `drafter.toml` gains `[blueprints]` with `brief_path =
  "docs/internal/briefs/{dir}/{name}.json"`. That maps `docs/extend/x.md` to
  `docs/internal/briefs/extend/x.json` and `docs/claude-code/x.md` to
  `docs/internal/briefs/claude-code/x.json`, the paths `check-provenance.mjs` accepts (factsheet,
  "The brief path").
- `blueprint.BriefPath` takes the template. `blueprint.Project` gains `BriefPath`, which
  `projectFor` fills. Both callers pass it: `blueprintHandoffs` (`read.go:406`, which sets
  `handoff.Page.Brief` and `entryJSON`'s `brief`) and `gateProvenance` (`gate.go:159`). `pageScopeFor`
  already reads `h.Page.Brief`.
- `docs/configuration.md`, "Blueprints", gains the row and one paragraph naming architecture call 13:
  the setting carries a legacy path until a project moves to the convention.
- drafter's tests use a synthetic template, never cairn's path.

### 4. The chain's blueprint mode and its `coherence` seat

The module is in **blueprint mode** when it is loaded under `DRAFTER_HOST` with no
`args.worktree`, which is how drafter loads it for a blueprint page (factsheet: `start.go:342-343`
and the chain's header at `:321`). Handoff mode is byte-identical to today: B3c.0 captures the
renders of `tests/fixtures/drafter/matrix.json` from the unedited chain, and a test compares them.

In blueprint mode, every back-half seat does the following:

- It names no worktree, no gate, no index-link command, no commit, and no command to run. drafter
  writes the files and runs cairn's gate.
- It reads the blueprint, which drafter inlines after the facts block, as the page plan. The
  blueprint's `framing` block replaces the framing record, and its items replace the claim
  inventory. It never names a `.plan.yaml`, `.plan.md`, or `.framing.md` path.
- It reads the register sections of the track its page's path names: the directory under `docs/`
  (`extend`, `admin`, `editors`, `reference`). A `docs/claude-code/` page reads the extend track's
  sections (finding 3), and an unknown directory throws, as `registerSectionsFor` does today.
- It names the brief at `page.brief`. The draft states the brief schema cairn's provenance check
  requires: `page` (the page path), `sentences` of `{text, id}` with the id rules the handoff
  draft prompt already states, and optional `cuts` and `local`.
- It names each exemplar as the file cairn-docs-outline's `exemplarFile` rule gives:
  `~/.local/share/cairn/exemplars/<source>page.md`, or the source itself when it ends `.md`. The
  sources come from `inputs.exemplarSources`, and the take lines from the blueprint block. The
  exemplar root is under `inline_files` in cairn's local layer, so drafter inlines each file.
- The `draft` and `editor` renders carry one sentence that overrides the agent definition drafter
  sends as their system prompt. cairn's local layer sets `seat.draft.agent` to
  `cairn-docs-drafter.md` and `seat.editor.agent` to `cairn-register-editor.md`, and `assemble.go`
  sends each body as the system prompt (`Build` and `systemPrompt`, `:70-85` and `:184`). The
  drafter agent says to run the docs gate as its last act, to take `<track>` from the dispatch,
  and to mirror the plan's cut dispositions in `cuts`; the editor agent says to run `tellgrader`.
  No API seat can run a command. So the draft render says that drafter writes the files and runs
  the gate, that the blueprint's `cut` items stand in for the plan's cut dispositions, and that the
  track is the page path's directory. The editor render says no command runs and Vale's output
  arrives as an input.

The seats:

- **`draft`.** Round 1 whole; a section redraft at round 1 with `findings` and `scope` set, which
  changes only the sections `scope` names; the round-2 redraft; and the final redraft, as today.
- **`structure`, `editor`, `fact`.** The handoff prompt's method, with the blueprint in place of the
  plan and the framing record. `scope` and `narrow` work as today.
- **`reader`.** Drops "in <worktree>".
- **`blueprint`.** Gains resolution 1's bar paragraph.
- **`coherence`.** New, in `DRAFTER_SEATS`. It reads the whole page against the register's
  drafting brief for its track. It reads the sections `scope` names against their neighbors for
  transitions, repetition, and the argument's flow, and it may raise findings anywhere. At round 2
  it's the retest, as B3's stock seat renders it.

`DRAFTER_SEATS` then defines the seven seats B3's stock module defines. The header comment
documents blueprint mode beside the existing `DRAFTER_SEATS` contract.

### 5. Conversion and the reshape

In the cairn branch, the session converts the seven plans with the installed B3 binary, one
`drafter convert plan` call each, `--outline docs/internal/outlines/extend.json` (or
`claude-code.json`), and `--framing` where a record exists. security-model converts from a copy of
its record in the session's scratchpad, with "Who arrives, from where, why" and "Background the page
rests on (the old intro skipped it)" renamed to the converter's two headings (probed; factsheet,
"How conversion seeds a lock entry"). The cairn record itself is left alone. Conversion seeds the
six pages that exist; claude-code gets no entry.

One commit holds the seven blueprints, the lock's seeded entries, and each conversion's friction
lines, filed in `docs/internal/docs-friction-log.md` in the shape its header sets, as rotate's
conversion did. The commit message carries each framing preamble and each departures section the
converter printed, page by page.

The reshape follows rotate's recipe (`80b7a9079`'s message):

- Give each section a `why`.
- Cut `orderReason` to the order as a whole.
- Rewrite each `use` to name scope only, opening with Only or Omit.
- Replace each heading reference the converter's hints name with `[[section-id]]`.
- Move planning history out of the durable fields.

debug-your-site, restrict-admin-access, and claude-code also get a `framing.introPlan`, written
from the plan's `introduction` block. claude-code's also follows its friction note on the extend
reader.

Each page's reshape is one subagent in its own cairn worktree,
`~/Projects/cairn-cms/.claude/worktrees/b3c-reshape-<slug>`, on branch `b3c-reshape-<slug>` from
the conversion commit. It edits only its blueprint, runs `drafter check <its blueprint path>` until
it reports 0 errors, commits, and never pushes. The check is scoped because each worktree holds all
seven unreshaped blueprints: unscoped, it reports 524 errors, against 42 for debug-your-site alone
(mechanics review probe). The session merges each branch. The files are disjoint, so a conflict
stops the line, per pass-core "Pairs". The session then runs `drafter check` (0 errors) and removes
the worktrees.

Before each merge, the session compares the ids in the reshaped blueprint with those in the
converted one at the conversion commit:

```
ids() { git show "$1:$BP" | yq '[.. | select(has("id")) | .id] | sort | .[]'; }
diff <(ids <conversion commit>) <(ids <reshape branch>)
```

Any id the diff shows removed or renamed must be listed in the reshape commit message with its
reason; an unlisted one stops the merge. A reshape could otherwise clear the 524 errors by deleting
items, and the later paid read judges the blueprint, not its fidelity to the converted plan.

A reshape prompt names everything the subagent reads, since it starts with no context:

- the blueprint skill (`~/.claude/skills/blueprint/SKILL.md`) and `docs/blueprint-format.md` at
  drafter `main`;
- rotate's reshaped blueprint as the worked example, and the recipe above;
- the converter's "needs judgment" lines for its page;
- the page's v1 plan and framing record.

### 6. The live runs

- **The binary.** The live runs use `<drafter worktree>/drafter`, built by `make build` at the
  merged pair-A head in B3c.5. Call its absolute path `$B3C_DRAFTER`. It's rebuilt after any fix,
  and the PR body names the commit each live call ran. The installed `~/.local/bin/drafter` (B3's)
  is never replaced during the pass. `make install` from a worktree would point the chain and skill
  symlinks into it (`Makefile:39-53`).
- **Every `drafter` call in the cairn worktree after B3c.5 uses `$B3C_DRAFTER`**, offline calls
  included, the session's own and every subagent's. Once B3c.5 commits `brief_path`, the installed
  binary exits 2 on the config ("unknown key blueprints.brief_path", probed), and once P1 commits
  `blocked`, `drafter check` would refuse the lock too (`lock.go:58-69`). A fix subagent that ran
  the installed `drafter check` could never reach 0 errors and might "fix" `drafter.toml` or the
  lock, dropping the bars. So every fix prompt names `$B3C_DRAFTER check <its blueprint path>` by
  absolute path, says the installed `drafter` is pre-B3c and must not be run, and says: "Edit only
  `<blueprint path>`. Never edit `drafter.toml`, `drafted.lock`, facts, or outlines." Before the
  session merges or commits a fix, `git diff --name-only` (or `git status --porcelain`) must name
  only that blueprint; anything else stops the merge.
- **The module.** The cairn worktree's `drafter.local.toml` is a copy of
  `~/.config/drafter/cairn-cms.local.toml`, as cairn's STATUS says, with `prompts` set to the drafter
  worktree's `claude/.claude/workflows/docs-page-chain.js` by absolute path. The file is ignored and
  never committed. The main checkout's chain, which `~/.claude/workflows/docs-page-chain.js` links
  to, stays B3's until the drafter PR merges.
- **The cairn worktree.** It is `~/Projects/cairn-cms/.claude/worktrees/b3c-pilot-pages`, on
  branch `b3c-pilot-pages`, from `origin/main` after `git -C ~/Projects/cairn-cms fetch origin`.
  The cairn-pass setup command runs there: `npm ci && npm ci --prefix examples/showcase && (cd
  examples/showcase && npx svelte-kit sync)`. Every drafter command for cairn runs from it.
- **The gate.** A run calls cairn's gate through `gate.command` (`drafter.toml:9-11`), the same
  `check:docs-gate --page --brief` command on the light lane, so each accepted page passed it
  inside its run. Check 2 reruns it once at close on the close head (resolution 9). Its full-suite
  home is cairn CI on the draft PR. `scripts/drafter-gate.sh:3-4` records that a worktree-isolated
  session's Bash guard refuses `cairn-run-gate '<string>'`; if it refuses here, the session writes
  the command into a no-argument wrapper script in its scratchpad and runs that.
- **The tree.** A run needs a clean tree at its start (`start.go:88`), and drafter restores an
  escalated page's page and brief (`page.go:317-320`). The session commits before each live call
  and never edits the cairn worktree while a run is live. A drafted page or brief is never edited by
  hand afterward, since that breaks its lock entry (Check 3).
- **Recovery.** Each STATUS row for a live call is written before the call, then gets the run id
  once printed, and an "after" cell when the call returns. A session that finds a row with no
  "after" cell doesn't restore or commit the tree first. A row whose "after" cell reads
  "abandoned (stall rule)" is skipped. The session resumes that run with `--resume <id>`
  in the same mode, on a fresh meter reading. A dirty tree that holds only `blueprints/drafted.lock`,
  after a run whose summary shows it finished, is committed as is. Any other dirty state stops the
  line.

### 7. The budget and the meter

At launch, B3c.0 records `drafter spend --since 2026-10-19 --json` into STATUS and into the B3c.0
commit body. Before every live call:

- `used = total − baseline.total + open.worst`, read fresh, and `left = 80 − used`. After B3c.5
  the read is `$B3C_DRAFTER spend --since 2026-10-19 --json`, since `drafter spend` loads the
  project config and the installed binary refuses `brief_path`. Both binaries read the same
  user-layer state directory.
- At `left <= 0` the call doesn't start, and the pass stops and asks Geoff (standing answer 4).
- Otherwise the call runs with `DRAFTER_PAGE_CAP` set to `min(10, left / N)`, where N is the
  number of blueprints or pages the call takes.

The formula is B3's. B3's cancelled batch holds `open.worst` 0.99695 (factsheet, "Money"), so B3c
counts that dollar too. STATUS keeps one row per live call: the command, N, the cap, the readings
before and after, and the run id. The ledger is per machine, so another session's spend on this
machine counts against the $80.

The estimate below comes from the ledger and the spike, and it isn't a cap:

| Item | Estimate |
|---|---|
| Probe reads, `--sync`, 8 blueprints in read 1 plus up to 3 rotate rereads | $4 |
| The seven's later read rounds, batch, about 2 more each | $5 |
| Probe draft, `--sync` | $6 to $9 |
| Wave 1, batch, 4 pages | $14 to $22 |
| Wave 2, batch, 3 pages including the two largest | $15 to $25 |
| Fault reruns (finding 9) | the rest |

A read costs about $0.19 at rotate's size and grows with the blueprint's length. The spike drafted
a page whole for $3 to $4.50.

### 8. The run order, the read loop, and the stops

**P1, the first reads.** One `$B3C_DRAFTER read --sync --json` call takes all eight blueprints:
rotate and the seven, after B3c.5. Each blocked whole read leaves a bar, and the session commits the
lock at once ("Record the first blueprint reads").

**The probe's read loop.** When rotate blocks, the session fixes its blueprint against the
findings, with the blueprint skill, until `$B3C_DRAFTER check <rotate's blueprint>` reports 0
errors. It commits the fix, runs B3c.5 step 4's stub check on rotate's bar read (the body holds
every bar finding and "Still open"), and reads rotate again, `--sync`. That second read is a bar
read, and it should accept. Rotate gets at most five reads (Geoff, 2026-10-19, at the B3c.6 stop: rotate's read 4 blocked only on a gap its read-3 fix opened, so the cap rose from four to five).

- When rotate's read 5 still blocks, the line stops: the #13 rule hasn't converged on the probe.
- The one exception is a mechanical fault in the bar machinery, such as a bar read that wasn't
  scoped or a prompt missing the findings. The session fixes it in the drafter worktree with a
  test, runs `make check`, rebuilds, and reads again.

**The probe draft.** Before it, the session runs `$B3C_DRAFTER page --whole --dry-run --sync
--json docs/extend/rotate-the-github-app-key.md` with the real key (token counting spends nothing,
and a dry run writes no ledger line, `dry.go`) and records the first stage's worst case in STATUS.
Then `$B3C_DRAFTER page --whole --sync --json docs/extend/rotate-the-github-app-key.md` runs in
the background. While it runs, the session dispatches one fix subagent per page of the seven that
blocked in P1. Each works in its own worktree (`b3c-fix-<slug>-r1`) from the P1 lock commit, as
resolution 5's reshape agents do, under resolution 6's binary rule: it fixes the findings, gets 0
errors from `$B3C_DRAFTER check <its blueprint>`, and commits. Nothing merges into the pass worktree
while the probe runs. When the probe ends:

- **Accepted.** Commit rotate's page, brief, any index file the index-link command changed, and the
  lock in one commit; B3's commit rule is that nothing sits between the run's start and its lock
  commit. Then run Check 3 on that commit (resolution 9).
- **Escalated.** Three fixes may apply, and then the probe reruns:
  - On a fault (finding 9), rerun it once.
  - On `cap`, rerun it once as a fresh batch run, `--whole` without `--sync`, at half the price
    (finding 10). A resume can't switch modes, so it's a new run.
  - On a mechanical cause in drafter or in the chain's blueprint mode, fix it in the drafter
    worktree with a test, run `make check`, rebuild, and rerun. Examples: a prompt names a missing
    file, the brief misses the schema the same way on every turn, or a step errors. At most two
    such cycles.

  Any other escalation stops the line: review seats still blocking after the redrafts, the final
  reader, a gate red the fix exchanges can't clear, or `cap` again on the batch rerun. STATUS
  carries the run id, the record excerpt, and one question, and `notify-send -u normal` tells
  Geoff.

**The seven's read loop (B3c.7).** The session merges the round-1 fix branches (each after
resolution 6's file check), removes the `b3c-fix-*` worktrees and branches, commits, and runs one
batch `$B3C_DRAFTER read --json` over the seven pages not yet accepted. Later rounds need no
isolation, since no live call runs while they work: each blocked page gets a fix subagent that
edits its one blueprint in the pass's cairn worktree without committing, under resolution 6's
binary rule. When they return, `git status --porcelain` must name only those blueprints, and the
session commits the round once and runs the next.

- A page gets at most five reads (Geoff, 2026-10-19). A page whose fifth read blocks escalates with its bar committed
  in the lock and stays out of the waves.
- A read that escalates on a consistency conflict between two facts escalates the page: B3c never
  edits cairn's facts store. A conflict the blueprint causes is fixed like a finding.
- **The stall rule.** When a batch shows no result after 60 minutes, the session runs these steps
  in order:
  1. Cancel the batch through the API: the `batch_id` on the run state's intents
     (`internal/run/state.go:77`), sent to `POST /v1/messages/batches/<id>/cancel` with the key
     from the environment, never printed. drafter, still polling, reads the canceled results and
     resubmits them once (`batch/classify.go:11`, `ActionResubmitThenStop`); cancel that batch
     too. The second cancel halts the run with `StopInfrastructure` (`pipeline/handle.go:146-149`):
     it exits 3, saves its state as stopped, and releases the worktree lock. Confirm with `pgrep`
     that the process has exited. Never kill it: drafter has no signal handling, so a killed run
     stays `running`, with its batch live and its reservations open.
  2. Write the run's "after" cell in STATUS as "abandoned (stall rule)", with its `open.worst`.
     That figure keeps counting against the budget and errs safe, and Recovery skips the row.
  3. For a `drafter page` run, print `git status --porcelain` and `git clean -n` to STATUS as the
     dry run, then restore the tree to HEAD, since a stopped run restores nothing.
  4. Rerun the remaining pages as a new `--sync` run, on a fresh meter reading. A stalled cap
     rerun stops the line instead, since `--sync` brings back the full-price worst case that
     tripped the cap.

  A `--sync` call needs no hang rule: each streamed call is bounded by the client's stream timeout
  (`batch/calls.go:177`), and a timeout stops the run, resumable.

**The waves (B3c.8 and B3c.9).**

- Wave 1 is `$B3C_DRAFTER page --whole --json` over the pages of claude-code, debug-your-site,
  restrict-admin-access, and scaffolded-site-files whose blueprints accepted.
- Wave 2 does the same for security-model, add-a-second-sign-in-group, and
  add-cairn-to-a-sveltekit-app.
- Before wave 2, the session runs `$B3C_DRAFTER page --whole --dry-run --json
  docs/extend/add-cairn-to-a-sveltekit-app.md` with the real key and records the first stage's
  worst case against wave 2's cap in STATUS, so a predicted cap escalation is reported as
  predicted.
- Each wave is one batch call with resolution 7's cap. The stall rule above applies, with the
  affected pages rerun `--sync`.
- After each wave, the accepted pages and their index edits are committed together in one commit
  with the lock, and then pass Check 3.
- An escalated page is reported and the run continues (standing answer 3).
- When a wave-1 page escalated on a mechanical cause, the session fixes it (test, `make check`,
  rebuild) before wave 2 starts and records the commit, so wave 2 doesn't spend on the same cause.
- After wave 2, each page that escalated on a fault, or on a mechanical cause the session fixed with
  a test, reruns once, alone, with `--whole`, inside the budget.

### 9. The checks

Each row maps to the design's "Check".

- **Check 1.** Rotate's read 1 summary has no `scope` (`PageResult.Scope` is nil and omitted for a
  whole read, `pipeline.go:97-99`) and has `whole_blocked: true`, and the P1 lock commit holds
  rotate's `blocked` with that run's start commit. Read 2's summary shows `kind: scoped`,
  `bar_from` equal to that commit, and `accepted`. After it, the lock's `accepted` equals `git
  rev-parse HEAD:blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml`, and `blocked`
  is gone. When rotate accepts at read 1, the row comes from the first page of the seven that
  blocks and then accepts (finding 5). The PR names which. When no page does, the row reads
  "mechanism proven offline (the e2e test's name), not observed live".
- **Check 2.** Each of the eight pages ends `accepted`, or `escalated` with its rule, the finding
  or detail, and the run id. For a page that never reached a draft, the cairn PR carries its last
  read's blocking findings, from that read's summary as recorded in STATUS; its committed `blocked`
  holds the first blocked whole read's commit and findings. Each accepted page passed cairn's gate
  inside its run. At close, on the close head, the session runs `npm run package` once, then for
  each accepted page `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:docs-gate -- --prebuilt
  --page <page> --brief docs/internal/briefs/<dir>/<name>.json'` (`--prebuilt` skips the build,
  `docs-gate.mjs:7,14`), exit 0. The rerun catches a whole-tree component a later wave's pages or
  index edits turned red. The cairn PR reports that result as Check 2, with claude-code's row
  naming the components that skip `docs/claude-code` (finding 3), and states how many pages reached
  `accepted` against the pilot's three-page bar (settled by the planning session).
- **Check 3.** Run at `HEAD` after each accepted page's commit, and again at close (Close 3). Each
  accepted page's entry matches:
  - `page` equals `git hash-object <page>`, which also proves `sections`, since `DraftedEntry`
    hashes both from the same page bytes (`drafted.go:15-39`);
  - `blueprint` equals `git rev-parse HEAD:<blueprint>`;
  - `accepted` equals `blueprint`;
  - no `blocked`;
  - `$B3C_DRAFTER page --dry-run --json <page>` prints "up to date with drafted.lock". The dry run
    takes the same `scopeFromLock` path and returns before any request when nothing is left
    (`pagebp.go:61-71`), so a mismatch costs nothing.

## Tasks

### B3c.0: launch, baseline, worktrees, and the render goldens (30 min), by the session

Outcome: everything the pass builds on.

1. Run the "Depends on" checks. Record the meter baseline in STATUS (resolution 7).
2. `EnterWorktree` named `b3c-pilot` in drafter. Arm the API-drop wake-up and the guards
   `~/.claude/docs/unattended-work-guards.md` names.
3. Create the cairn worktree and run its setup (resolution 6). Copy the local layer with the
   `prompts` override, and confirm the cairn worktree's `git status --porcelain` is empty.
4. Before any chain edit, render `tests/fixtures/drafter/matrix.json` with `node
   tests/drafter-render-prompts.mjs`. Commit the output as
   `tests/fixtures/drafter/handoff-renders.golden.json`, so B3c.3's byte-identity row compares with
   the old chain. The commit body quotes the baseline JSON.
5. In the same commit, render the unedited chain's `blueprint` seat for a whole read and a change
   read, with the context shape `TestRealModuleRendersTheBlueprintSeat` uses
   (`cmd/drafter/read_test.go:190-235`: args `{}`, no scope, then `Scope: "intro,steps"`), as
   `tests/fixtures/drafter/blueprint-seat-renders.golden.json`. Only the whole read has a golden
   today (`cmd/drafter/testdata/blueprint-prompt.golden.txt`), and the live bar reads are change
   reads. Commit the matrix it rendered from as
   `tests/fixtures/drafter/blueprint-seat-baseline.matrix.json`, so B3c.3 renders the same input.

- Files: `tests/fixtures/drafter/handoff-renders.golden.json`,
  `tests/fixtures/drafter/blueprint-seat-renders.golden.json`,
  `tests/fixtures/drafter/blueprint-seat-baseline.matrix.json`.
- Risk class `runner`.
- Acceptance: `make check` green. `drafter config`, run in the cairn worktree, shows `prompts` from
  the local layer at the drafter worktree's chain path, and `page_cap = 10`.

### B3c.1: the brief path setting (40 min), by the session

Outcome: resolution 3.

- Files:
  - `internal/config/{config.go,file.go,apply.go}`, the file that refuses a bad path setting, and
    their tests;
  - `internal/blueprint/{brief.go,project.go}` and tests;
  - `cmd/drafter/{read.go,gate.go,check.go}`: the `read.go:406` call, `gateProvenance`, and
    `projectFor`, and tests;
  - `docs/configuration.md` ("Blueprints");
  - `docs/blueprint-format.md`'s one sentence in "The brief" on where the brief sits.
- Risk class `runner`.
- Tests:
  - Unset, every brief path equals today's (regression).
  - A synthetic template with `{dir}` and `{name}` maps two pages in two directories.
  - A template without `{name}` is refused, and so is one escaping the project.
  - `blueprintHandoffs` sets `Page.Brief` and `entryJSON`'s `brief` from the template.
  - `drafter gate --page` finds a brief at the template path and prints its `provenance:` count
    line.
  - `drafter config` prints the setting and its layer.
- Acceptance: `make check` green; each row by test name shows `PASS`. The session commits before
  pair A starts.

### B3c.2: the read bar and `--whole` (215 min), paired with B3c.3, `opus` at `high`

Outcome: resolutions 1 and 2.

- Files:
  - `internal/blueprint/blueprint.go` (`LockEntry.Blocked` and its comment),
    `internal/blueprint/check.go` (`lockEntries`), and their tests.
  - `internal/pipeline/{pipeline.go,work.go,start.go,blueprint.go}`, and the file that builds
    `PageResult`, with new pipeline tests.
  - `cmd/drafter/{read.go,pagebp.go,draftscope.go,page.go}`; a new `cmd/drafter/bar.go` if the shared
    lock helper and the bar lookup outgrow those files; tests beside each.
  - `stock/prompts.js`, with new goldens under `stock/testdata/` for a change read with a bar, and
    `stock/stock_test.go`.
  - `docs/blueprint-format.md` ("drafted.lock", "What `drafter read` does with a blueprint", "What
    `drafter page` does with a blueprint") and `docs/prompts-module.md` ("The context object").
  - `e2e/`: a new offline test file and its canned answers under `e2e/testdata/`.
  - Not the chain or `tests/`, which B3c.3 owns, so the pair's files are disjoint.
- Never `money.go` or `fingerprint.go`. `resume.go` only per the B3 ruling.
- Risk class `runner`.
- Tests, table-driven, on the scripted `fakeAPI` and the blueprint harness, then through the built
  binary:
  - The lock: an entry with `blocked` round-trips. An entry without it encodes byte-identically to
    today (regression). `LockIntroducedAt` ignores a `blocked` change.
  - Recording: a whole read that returns `fix` sets `whole_blocked`, and the helper writes `blocked`
    with the run's start commit and the blocking findings in order, leaving the non-blocking ones
    out. A change read that blocks sets no `whole_blocked`. A bar read that blocks leaves the bar
    unchanged. A `fix` read escalated on a consistency conflict still records. A `fix` with no
    blocking finding records no bar. A dry run and a stopped run write nothing.
  - A finished `drafter read` whose bar write failed prints its summary, then the error with the
    resume line; the resume writes the bar and sends no request.
  - The bar-only entry: a page with no entry that blocks gets an entry holding only `blocked`; a
    later accept leaves only `accepted`; a draft writes a full entry with no `blocked`. `drafter
    check` reports a bar-only entry for a page the outline doesn't list.
  - A lock that fails to decode: `drafter read`'s bar lookup and `drafter page`'s `scopeFromLock`
    each refuse, naming the file, and send no request.
  - Clearing: an unscoped accept and a bar accept each write `accepted` and drop `blocked`. A scoped
    accept with no bar keeps the old `accepted` (regression). In `drafter page`, a read that fell
    back to whole beside a scoped draft scope writes `accepted` (`scopedAccept` reads `ReadScope`).
  - `drafter read` with a bar:
    - the read's `since` is the bar's commit;
    - its blueprint request's prompt holds every bar finding, and its `Extra` holds the change block
      since that commit;
    - an unchanged blueprint prints the "unchanged since the blocked read" line with status `held`,
      sends no request, and exits 1, in `drafter read` and in `drafter page`;
    - a `Compare` that gives whole sends a whole read with no findings, and when the bar's commit
      is gone it prints the "not in this repository; reading whole" line;
    - `--since` ignores the bar.
  - Two pages with bars from different commits each get their own `since`.
  - `drafter page` with a bar and a scoped draft scope: the read uses the bar's scope and change,
    and the draft is a section redraft on the draft scope. With `--whole`, the draft is whole.
    `SkipRead` sends no read and ignores the bar.
  - The request bytes: with no bar, `drafter read`'s dry-run request and the stage-1 request equal
    B3.0's goldens (regression), and F2's six stock goldens are unchanged (regression).
  - The stock module: a change read with `findings` holds the bar paragraph, every finding, and
    the sentence that an unfixed listed finding blocks whatever its class. One golden per new case.
  - `--whole`:
    - a converted page whose blueprint is unchanged since conversion drafts whole instead of "up to
      date";
    - a seeded page whose blueprint changed drafts whole instead of a section redraft, with `Why`
      naming the flag;
    - with `--resume`, a handoff file, or `--workflow-run`, it's a usage error.
  - A state saved by B3's binary, with no `bar`, `bar_from`, `whole_blocked`, `read_scope`, or
    `read_change`, decodes
    and resumes as before (regression). A run stopped at the bar read resumes and sends the same
    bytes.
  - Offline end to end: in a new e2e file, on a git copy of the `tally` fixture, the built binary
    and a stub answer by schema, as B3's `e2e/draft_test.go` does.
    1. `drafter read`, with the stub answering `fix`, writes `blocked`.
    2. Commit a blueprint edit. `drafter read` again: the stub asserts the request's prompt holds
       the bar and answers `ok`. The lock gets `accepted`, with no `blocked`.
    3. `drafter page --whole` skips the read and drafts.
    4. The page-mode bar path: a fresh copy reads and blocks inside `drafter page`, which writes
       the bar. After a fix commit, `drafter page` reads with the bar, accepts, drafts, and writes
       the entry with `accepted`.
- Acceptance: `make check` green in the pair worktree. Each row above, by test name, shows `PASS`
  under `go test -run '<names>' -v`. The commit message names the tests and lists every pipeline
  function that now reads the read accessors.

### B3c.3: the chain's blueprint mode and `coherence` (175 min), paired with B3c.2, `opus` at `high`

Outcome: resolution 4, and the chain half of resolution 1's prompt.

- Files:
  - `claude/.claude/workflows/docs-page-chain.js`;
  - `tests/fixtures/drafter/blueprint-matrix.json`, synthetic, with no workstation path or account,
    and a page entry shaped as `entryJSON` builds it;
  - `tests/drafter-prompts-parity.sh`, run on both matrices (`tests/drafter-render-prompts.mjs`
    already takes the matrix path as `argv[2]`, `:18`);
  - `tests/docs-page-chain-handoff.test.mjs`, whose `DRAFTER_HOST` check deep-equals six seat
    names (`:337-339`) and now gets seven;
  - a new `tests/docs-page-chain-blueprint.test.mjs`;
  - the `Makefile`'s `chain-test` line.
- Risk class `runner`.
- Load `writing-voice` first for the prompt prose: the chain's prompts are read by seats as rules.
- The blueprint matrix holds host args `{}` and one case per seat and shape:
  - `blueprint`: whole, change, and change with a bar;
  - `draft`: whole round 1, section round 1, the round-2 redraft, and the final redraft;
  - `structure`, `editor`, and `fact`: round 1 whole, round 1 scoped, round 2 narrow, and round
    `final` scoped for `editor` and `fact`;
  - `reader`: turns 1 and 2;
  - `coherence`: the read and the retest;
  - a draft case for a `docs/claude-code/` page and one for a `docs/admin/` page.
- Tests:
  - Parity: Node and goja render both matrices byte for byte. `drafter check-prompts` on the
    blueprint matrix exits 0, containment included.
  - Handoff mode equals B3c.0's golden, every case (regression).
  - No blueprint-mode render contains `.plan.yaml`, `.plan.md`, `.framing.md`, `undefined`,
    `worktree`, `cairn-run-gate`, or `check:docs-gate`. One row per string.
  - Each draft render names `page.brief` and states the brief's `page`, `sentences`, `cuts`, and
    `local` fields. It names the register sections of its page's track, and the claude-code page
    names the extend track's.
  - Each draft render names each exemplar file by resolution 4's rule.
  - The draft render carries resolution 4's agent-override sentence (drafter writes the files and
    runs the gate; `cut` items stand in for cut dispositions; the track is the path's directory),
    and the editor render says no command runs.
  - The section draft says to change only the sections in `scope`.
  - The coherence read names the changed sections and says findings may lie anywhere. The retest
    says it is the retest.
  - The blueprint seat with empty `findings`, rendered from B3c.0's
    `blueprint-seat-baseline.matrix.json` against the edited chain, equals B3c.0's whole-read and
    change-read goldens (regression; never regenerate the golden), and `go test ./cmd/drafter -run TestRealModuleRendersTheBlueprintSeat` passes in
    the pair worktree, so a break shows before the B3c.5 merge. With a bar it holds the bar
    paragraph, every finding, and the sentence that an unfixed listed finding blocks whatever its
    class.
  - `DRAFTER_SEATS` defines exactly the seven seats.
- Acceptance: `make check` green (its `chain-test` and `prompts-parity` run the new tests). The new
  blueprint test prints `PASS <name>` for each check as well as the harness's `ALL PASS`, and the
  session greps `make chain-test`'s output for each row's name.

### B3c.4: conversion and the reshape (125 min), by the session in pair A's shadow, cairn branch

Outcome: resolution 5. The seven blueprints pass `drafter check`, ready for their first reads.

- Files (cairn): `blueprints/docs/extend/{debug-your-site,restrict-admin-access,scaffolded-site-files,security-model,add-a-second-sign-in-group,add-cairn-to-a-sveltekit-app}.blueprint.yaml`,
  `blueprints/docs/claude-code/using-claude-code-with-cairn.blueprint.yaml`,
  `blueprints/drafted.lock`, and `docs/internal/docs-friction-log.md`.
- Risk class `runner`, the pass's class. Nothing here runs a model through the API.
- Uses the installed B3 binary. `drafter check` needs neither the brief path nor the chain.
- Acceptance:
  - In the cairn worktree, `drafter check` reports 0 errors, with any new warnings listed in the
    commit.
  - Each seeded entry's `page` equals `git hash-object` of that page at the conversion commit, and
    claude-code has no entry.
  - The conversion commit message carries each framing preamble and departures section.
  - For each page, resolution 5's id comparison shows no removed or renamed id that its reshape
    commit message doesn't list with a reason.
  - Every reshape worktree is removed.

### B3c.5: merge the pair, build, and set up the cairn runs (50 min), by the session

1. Merge B3c.2 and B3c.3. Run the named-test check (see "Clock file"), then `make check`, then `make
   build`. Record the binary's absolute path and commit in STATUS. Shell state doesn't persist
   between Bash calls and a subagent starts with an empty environment, so `$B3C_DRAFTER` is a
   name in this plan, never a shell variable: every command and fix prompt writes the absolute
   path out literally.
2. In the cairn worktree:
   - Commit `drafter.toml`'s `brief_path` (resolution 3).
   - `$B3C_DRAFTER config` shows `blueprints.brief_path` from `drafter.toml` and `prompts` from the
     local layer.
   - `$B3C_DRAFTER check` reports 0 errors.
   - `$B3C_DRAFTER check-prompts --matrix <drafter worktree>/tests/fixtures/drafter/blueprint-matrix.json`
     exits 0, rendering the configured module.
3. Run cairn's docs gate once, offline, on rotate's current page and brief:
   `CAIRN_GATE_LANE=light cairn-run-gate 'npm run check:docs-gate -- --page
   docs/extend/rotate-the-github-app-key.md --brief
   docs/internal/briefs/extend/rotate-the-github-app-key.json'`.
   - Green: the gate works in this worktree.
   - Red on a whole-tree component: the line stops, since no draft could pass. STATUS gets the
     failing check and one question.
   - Then `git status --porcelain` prints nothing, since a run's `requireClean` counts untracked
     files (`start.go:88`).
4. The real-context render check, which spends nothing. B3c.3's rows run on a synthetic matrix;
   this renders every seat drafter will send first, from cairn's real blueprints, outlines, and
   local layer, before any paid call.
   - In the scratchpad, make a shared clone of the cairn worktree's head (`git clone --shared`),
     copy the cairn worktree's `drafter.local.toml` into it, and commit one lock edit there that
     sets each of the eight pages' entries to `accepted: <its blueprint blob>`, so `SkipRead`
     holds and the first stage is the draft.
   - Start a local stub that records each request body and answers `/v1/messages/count_tokens`
     with `{"input_tokens": 1000}` and the models list with the configured
     `anthropic-workspace-id` header (`batch/client.go:81-106`). Point drafter at it with
     `DRAFTER_API_BASE_URL` and a dummy `DRAFTER_API_KEY`.
   - In the clone, run `$B3C_DRAFTER read --dry-run --json` over the eight blueprints and
     `$B3C_DRAFTER page --whole --dry-run --json` over the eight pages. Each exits 0, which rules
     out a render throw at the real context.
   - Grep the recorded bodies: none holds `undefined`, `.plan.yaml`, `.plan.md`, `.framing.md`, or
     `worktree`; each draft body holds the agent-override sentence beside the agent's system
     prompt; and every exemplar path a draft body names exists under
     `~/.local/share/cairn/exemplars`.
   - Planning's fold probe ran this on B3's binary and chain against the planning clone: the read
     dry run on rotate recorded 187 KB of bodies, and the page dry run reproduced finding 1's
     throw ("unknown track \"undefined\"") from the real context, at no cost.
   - Delete the clone and stop the stub. Later, after rotate's fix commit, make a fresh shared
     clone of the head with no lock edit, copy in the local layer, point it at the stub, run
     `$B3C_DRAFTER read --dry-run --json` on rotate there, and grep the body for "Still open",
     which proves the bar reached the chain's prompt before the paid read. The lock edit above
     would drop rotate's `blocked`, so this check never makes it.

- Risk class `runner`.
- Acceptance: each step's output as stated, recorded in STATUS.

### B3c.6: the probe (115 min), by the session

Outcome: resolution 8's P1, the probe's read loop, and the probe draft. Check 1 on rotate, or
finding 5's fallback.

- Live, `live-account` (API spend). Each call follows resolution 7.
- Files: cairn's `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml`,
  `blueprints/drafted.lock`, `docs/extend/rotate-the-github-app-key.md`, and
  `docs/internal/briefs/extend/rotate-the-github-app-key.json`. Also any file the index-link command
  changes, and the seven blueprints only through the round-1 fix branches, merged after the probe
  ends. In drafter, only a mechanical fix under resolution 8, each with its test.
- Acceptance: Check 1's row (or its fallback, noted), rotate's Check 3 row, and its gate result
  from inside the run (Check 2's rerun is at close). Every round-1 fix branch is committed and
  left unmerged for B3c.7's first step. Otherwise the line stops with STATUS and `notify-send` as
  resolution 8 says.

### B3c.7: the seven's read loop (90 min), by the session with fix subagents

Outcome: each of the seven blueprints accepted, or escalated at its fifth read with its bar
committed.

- Live. Batch reads under resolution 7's cap.
- Files (cairn): the seven blueprints and the lock.
- Acceptance: each page's last read is in STATUS with its run id. Each round's commit touches only
  that round's blueprints (`git show --name-only`). When Check 1 moved here (finding 5), its row is
  met.

### B3c.8: wave 1 (90 min), by the session

Outcome: claude-code, debug-your-site, restrict-admin-access, and scaffolded-site-files drafted,
each accepted or escalated.

- Live, batch. Files (cairn): the pages, their briefs, the index files the index-link command
  changes, and the lock.
- Acceptance: Check 3 for each accepted page, and its gate result from inside the run. Each
  escalated page is in STATUS with its
  rule, finding, and run id, and its tree is clean (drafter restored it).

### B3c.9: wave 2 and the reruns (100 min), by the session

Outcome: security-model, add-a-second-sign-in-group, and add-cairn-to-a-sveltekit-app drafted, then
finding 9's reruns inside the budget.

- Live, batch; reruns as resolution 8 says. Files as B3c.8.
- Acceptance: as B3c.8, for these pages and every rerun.

## Close (65 min)

1. drafter: the gate on the close head, from the worktree, `DRAFTER_DIR="$PWD" bash
   scripts/drafter-gate.sh`, through `cairn-run-gate`, re-issued on exit 75. drafter has no CI, so
   this is its full-suite home.
2. One whole-branch `diff-reviewer` read of the drafter branch against this plan and the design. If
   any commit touched `resume.go`, the read confirms its task-scope read happened.
   `prose-voice-reviewer` reads the changed `docs/` pages: `blueprint-format.md`,
   `prompts-module.md`, and `configuration.md`. One batched fix chain follows, then the gate again; a
   second review runs only on a blocker. A fix dispatch quotes each finding verbatim as its
   acceptance. The fix chain leaves the lock's schema alone, since cairn's lock already holds
   entries pair A's binary wrote; a fix that would change it stops the line.
3. cairn, before the push, with `$B3C_DRAFTER` rebuilt from the drafter close head:
   - `$B3C_DRAFTER check` reports 0 errors, and `$B3C_DRAFTER page --dry-run --json` over all
     eight pages prints "up to date with drafted.lock" for each accepted page. Both results go in
     the cairn PR.
   - Check 2's gate rerun (resolution 9).
   - `git diff origin/main...HEAD`, grepped for `/home/`, `/var/home/`, `thinkpad-x1`, and
     `pavilion`, prints nothing: `check-leaks` doesn't scan `blueprints/` (`SCAN_ROOTS`,
     `check-leaks.mjs:473-492`), and the bars and eight blueprints land in a public repo.
4. cairn: push `b3c-pilot-pages` to `glw907/cairn-cms` and open a draft PR. cairn CI fires on
   `pull_request` (cairn-pass, "CI watch"). Run `ci-green <sha> --pr <n> --wait` in the background.
   A red caused by this branch's files is fixed on the branch, except a red on a drafted page or
   brief: it is reported, or the page reruns with `--whole` inside the budget, never hand-edited
   (Check 3). A red elsewhere is reported.
5. drafter: push `worktree-b3c-pilot` to `glw907/drafter` and open its PR.
6. Each PR body opens with `## Brief`, per `~/.claude/docs/voice/approval-brief.md`.
   - The drafter PR carries:
     - what landed;
     - the acceptance table, one row per offline check;
     - the live spend and the meter readings;
     - every abandoned run id from the stall rule, with its `open.worst`;
     - every departure from this plan;
     - any `resume.go` verdicts;
     - the score per pass-core "Score", with Work and review naming 795 path minutes beside the
       actual.
   - The cairn PR carries:
     - the eight-page table: status, rule, finding, run id, cost, read count, and gate coverage per
       page, with claude-code's row naming the gate components that skip `docs/claude-code`;
     - the number of pages that reached `accepted`, against the pilot's three-page bar;
     - Check 1's row and which page carried it;
     - Check 2's gate rerun and Check 3's lock checks;
     - the drafter commit each live call ran;
     - the conversion and reshape summary;
     - the claude-code note of finding 3.
   - Each PR links the other and states the merge order below.
7. Each "Found, not done" item worth doing goes to drafter's `BACKLOG.md` through `log-issue`,
   tagged `#initiative:docs-system`, and is listed in the drafter PR body with its number. Close #13
   with the evidence from Check 1; when Check 1 was proven offline only, #13 stays open with that
   note. Findings 3 and 9 go in unless the planning session filed them. A cairn backlog item adds
   `blueprints` to `check-leaks`' `SCAN_ROOTS`.
8. Stop at PR-ready for both PRs. The executor never runs `approval-queue`; conductor-drafter hands
   the packet to Geoff.

## Merge order

1. glw907/drafter's B3c PR first, with `--match-head-commit` from the decision. Then pull
   `~/Projects/drafter`. Check that no drafter run is stopped and resumable (B3's merge order:
   `grep -l '"stopped"' <state_dir>/runs/*/*/state.json` prints nothing beyond the abandoned run
   ids the drafter PR lists). Then run `make install`
   from the main checkout, so the installed binary reads the lock's `blocked` field and
   `blueprints.brief_path`, and `~/.claude/workflows/docs-page-chain.js` links to the main checkout's
   chain with blueprint mode. The other workstation pulls and runs `make install` before it runs
   drafter on cairn.
2. glw907/cairn-cms's B3c PR second, after Geoff reads the pages. Its `drafter.toml` carries
   `blueprints.brief_path`, which a pre-B3c binary refuses as an unknown key (`file.go:98-106`), and
   its lock may carry `blocked`, which a pre-B3c `drafter read` or `drafter check` refuses to decode
   (`lock.go:60`). So it merges only after step 1's install. It merges with a merge commit, never
   squash or rebase (the repo allows both), and the session never rebases `b3c-pilot-pages`: every
   bar names a branch commit, and a bar whose commit is gone falls back to a whole read.

## Later

Kept out of B3c and never built here:

- The three figure pages (add a custom admin screen, architecture, replace magic links), once
  drafter takes figures.
- Stage 2b's close: relinks, `LEGACY_PATH_MAP`, the arm index, the boundary test, the claude-code
  arm's gate registration, and its register track entry (finding 3). Also retiring the v1
  `.plan.md` and `.plan.yaml` files, the framing records, and the JSON outlines.
- B5: cairn moves to the convention and drops `blueprints.brief_path`, and cairn moves onto
  drafter's stock prompts after the register split.
- A live section redraft on a cairn page, the first that runs the chain's `coherence` seat. Every
  B3c draft is whole.
- Retrying a reader read that stops at `max_tokens` (drafter backlog #18, Geoff's ruling in B3's
  packet).
- The converter taking the framing heading variants security-model uses.
- A command that clears a bar on purpose, for a blueprint rewritten past its findings.
- A durable home for a change read's "Already present:" findings (drafter backlog #7).
- The consistency read when the read is skipped (drafter backlog #20).
- The nightly run (B4).
