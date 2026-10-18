# drafter skill-rules pass plan: teach the skill what the read checks, then measure a rate

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-18-drafter-skill-rules-design.md`, approved
by Geoff on 2026-10-18 (glw907/initiatives#22). It follows his ruling on the change-read packet
("Teach the skill first") and the change-read pass (glw907/drafter#48). Facts below are quoted at
drafter `main` `0a7a30b` (the #48 merge) and cairn-cms `50dc211d9`, and were probed on 2026-10-18 in
a scratch clone of cairn (never cairn's checkout). The format-test protocol is change-read's
(`plans/2026-10-18-drafter-change-read-plan.md`, resolution 8 and CR.3), which builds on B2's
(`plans/2026-10-18-drafter-b2-blueprint-skill-plan.md`, resolution 9 and B2.4).

## Outcome

The format page gains "Check what you add", the seven checks the read applies to an item a change
adds or alters, each linked to its published source. The skill's "Check" step sends the agent
through it. A change read records a conflict that names no fact and no page as an "Unplaced:"
warning instead of blocking. The base conflicts a prompt can touch are settled on the test branch:
each bullet cairn's code proves wrong is corrected there, and a scope difference is recorded as no
defect. The format test then runs as a rate: seven prompts, three runs each, against a bar of 17 of
21.

- Risk class `runner` (the skill, the format page, and the consistency rule in
  `internal/pipeline/blueprint.go`). `live-account`: API credit, budget $20.
- Executor: `drafter-skill-rules`, `sonnet` at `medium`. Pair subagents run on `sonnet` at `medium`,
  `description` `skill-rules task SR.<n>`.
- Path estimate: 160 minutes. SR.3 (40) run by the session beside SR.1 (35) paired with SR.2 (30),
  then SR.4 (90), then Close (30). SR.3 is the longest of the three, so it sets the first leg. The
  design's estimate is 150; 160 is over it by the pair check and the positive controls, and inside
  the standing answer's 300. The task sum is 225.
- Clock file: `pass-task-clock` in the drafter worktree's git dir, except SR.3 and SR.4, which run
  with the session's cwd in the cairn worktree and write it in that worktree's git dir
  (`git rev-parse --absolute-git-dir` from there). A wait on Geoff removes it first.

### Standing answers

From the design ("Standing answers"; Geoff, 2026-10-18):

1. A plan up to 300 path minutes proceeds.
2. A format test below 17 of 21 closes the pass with the result.
3. A read that blocks on an untouched item, or an escalation from backlog #6, is recorded and
   doesn't stop the test. It is a miss in the raw count.
4. Live spend, as change-read's plan meters it, against $20. The baseline is `drafter spend --since
   2026-10-18 --json`'s `total` read at launch (it read $5.47 at planning). This pass's spend is
   that report's `total` plus its `open.worst` (a reserved intent not yet closed, which
   `ledger.go` sums apart from `total`), minus the baseline, plus each headless session's
   `total_cost_usd` from its stream's `result` event. A session whose stream has no `result` event
   is charged $0.90, noted on its row. Before each dispatch, that sum plus $0.90 (the worst session
   plus read #48 saw was $0.81) must fit under $20. Each live read sets `DRAFTER_PAGE_CAP` to the
   smaller of 2 and 20 minus the sum; a cap under $1 stops for Geoff after `notify-send -u normal`.
   Exit 3 with `cycle cap` or `spend limit`, or a page escalated on rule `cap`, stops for Geoff the
   same way. Any other exit 3 gets one `drafter read --resume <run-id>` with the same blueprint
   argument, without `--since`, and with the worktree binary and `DRAFTER_PROMPTS` the run started
   with. The resume runs before the next reset, since `checkPosition` (`resume.go:94-110`) needs
   HEAD at or after the run's head; no reset happens while a stopped read is outstanding. A second
   exit 3 stops for Geoff, with the skill link restored. The projection is about $17.3 of $20:
   21 sessions near $0.375 (#48's five averaged $0.375), 26 reads near $0.34 (21 graded, 2
   controls, 2 positive controls, row 0) plus row 0's one possible revision read, and the probe near
   $0.20. A cap under $1 stops once the sum passes $19.00, so the room before that stop is about
   $1.7, roughly two infrastructure reruns at about $0.72 each; the stop is a pause for Geoff, not a
   lost result.

For `conductor-drafter`: Geoff ruled on the design's packet that F1 launches when this pass merges,
whatever it scores. That replaces the design's "F1 then starts as the packet's ask decides". The
packet carries no F1 ask.

### Departures from the design

The packet lists each:

- Outcome 4's "the base moved by that one bullet" reads "N bullets": SR.3 corrects each reachable
  bullet cairn's code proves wrong (resolution 3).
- The path is 160 minutes against the design's 150 estimate, inside the standing 300.
- Outcome 5's "same harness": the sessions run with auto memory off and under `timeout`; the flags
  are #48's (resolution 7).
- Outcome 5's bar of 17 of 21 scales when a positive control drops a prompt; a prompt is dropped,
  never rewritten (resolution 7).
- Outcome 1's "each linked to its source": `blueprintPrompt` is named, not linked, two clauses cite
  drafter's own format rule, and the task-section line says "steps" (resolution 4).
- Three grading rules, the planning session's method calls, each narrowing or widening the
  design's "17 of 21 runs accepted on the first try, by the raw count":
  - an accepted read with an introduced "Unplaced:" warning is a miss;
  - a protocol breach is a miss even when the read accepts;
  - a run that fails on infrastructure gets one marked rerun.

### Depends on, checked at launch

- One executor per worktree: `pgrep -f` on `~/Projects/drafter/.claude/worktrees/skill-rules` and
  `~/Projects/cairn-cms/.claude/worktrees/format-test` finds nothing; `claude agents --json` shows
  no session in drafter or cairn-cms other than the launching conductor's own; both main checkouts
  are clean and on `main`; no worktree or branch named `skill-rules`, `worktree-skill-rules`, or
  `format-test` exists in either repo. The locked `change-read` worktree in drafter (`ec95398`) is
  the change-read pass's leftover, not this pass's; it doesn't block, and the executor leaves it
  alone. The other existing worktrees (`agent-*`, `b1-blueprint-format`, `repo-organization`,
  cairn's `blueprint-pilot`) don't block either.
- drafter `origin/main` at or after `0a7a30b` (holds #48: `internal/pipeline/blueprint.go` has
  `func (p *page) untouched`).
- `DRAFTER_API_KEY` in `~/.local/secrets`, checked by name only (`grep -c '^export
  DRAFTER_API_KEY=' ~/.local/secrets` prints 1); the value is never printed. `drafter spend --json`
  shows `open.count` 0.
- `readlink -f ~/.claude/skills/blueprint` is
  `/var/home/glw907/Projects/drafter/claude/.claude/skills/blueprint` (probed at planning), recorded
  as the link to restore.
- #48's harness at `~/.claude/jobs/e63b19d8/tmp/ft/` (`tweak.sh`, `read.sh`, `control.sh`,
  `control.py`, `spend.py`, `analyze.py`, `findings.py`, `base.sh`, `c1.patch`, `c2.patch`,
  `p1.txt` to `p5.txt`), checked file by file. The executor's first act after `EnterWorktree`
  copies those files, and no evidence file, into the pass's job directory
  `~/.claude/jobs/drafter-skill-rules/ft/` (on `/var/home`, not tmpfs; `<job>` below), never the
  scratchpad, and names `<job>` in the STATUS note. #48's directory is never written. A missing
  script is rebuilt from change-read's resolution 8, a missing `p*.txt` is taken from #48's PR
  body, and a missing `c*.patch` is re-seeded through `control.py` and its row marked
  "re-seeded". Then the copy is edited:
  - `OUT` in every script and the hardcoded paths in `analyze.py`, `findings.py`, and `spend.py`
    point at `<job>`; `DWT` at this pass's drafter worktree; every `50dc211d9` at `<base'>` once
    SR.3 records it; `spend.py`'s `BASE` at the launch baseline, its sum adds `open.worst`, and
    `<job>/sessions.txt` starts empty.
  - `tweak.sh` gains the before-run and after-run checks of resolution 7, runs the session as
    `timeout -k 30 900 env CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude -p …` with #48's flags
    unchanged, records `ls -l --time-style=full-iso` of cairn's auto-memory directory
    (`~/.claude/projects/-var-home-glw907-Projects-cairn-cms/memory/`) before and after the session,
    and ends, after every post-check and its `drafter check`, by writing `<name>.done`. Its
    `<name>.exit` reading 124 or 137 is the timeout signature.
  - `read.sh` takes `RESUME=<run-id>`: it then runs `drafter read --resume <run-id>` without
    `--since` and writes `<name>.resume.json` and `<name>.resume.exit`.
  - `analyze.py` prints each Read's `offset` and `limit` (the streams carry them, as #48's
    `"offset":530,"limit":200` shows), and any Grep or Bash command naming `check-what-you-add` or
    the heading.
  - `control.sh` applies `c<N>.patch` with `git apply`, falling back to `control.py` only to
    re-seed.
  - Gate: `grep -n 'e63b19d8\|change-read\|50dc211d9\|3\.1758' <job>/*.sh <job>/*.py` prints
    nothing.
  A resumed session reads `<job>/sessions.txt` and the rows table before any dispatch.

## Design resolutions

1. **The empty-conflict rule (Outcome 3).** In `completeBlueprintRead`, a conflict is unplaced when
   its `facts` is empty and its `with` is the empty string. Only a change read (`p.changeRead()`
   true) treats it as unplaced. It never blocks: it goes to the record as a warning starting
   "Unplaced: " followed by the conflict's `conflict` text, and it counts as neither touched nor
   untouched. The rest of the rule is today's:
   - Any other conflict goes through `untouched` unchanged. An empty `facts` with a non-empty
     `with`, and a named fact with an empty `with`, still fail closed and block.
   - When any conflict in the answer is touched, the page escalates on `consistency` listing every
     conflict, the unplaced ones included, as today.
   - When none is touched, each untouched conflict becomes its "Already present:" warning and each
     unplaced one its "Unplaced:" warning. The consistency verdict is `demoted`, and `Demoted`
     counts both kinds, since both went to a warning. The doc comments on `PageResult.Demoted`
     (`pipeline.go:93`) and `work.Demoted` (`work.go:129`) say so. The summary line and `--json`
     don't change shape.
   - A whole read, and a scoped state from before `Scope.Facts` (nil), escalate on an unplaced
     conflict as today. The consistency prompt doesn't change.
   - The evidence for the rule is #48's tweak 4 answer (run `20261018T210143Z-593b4ba9`): one
     conflict, `"facts":[]`, `"with":""`, whose prose ends "scope difference, not reported".
2. **The conflicting fact pairs.** The main pair is `f:sszb7b` and `f:vg42j3` in cairn's
   `docs/internal/facts/extend.md` at `50dc211d9` (lines 682 and 1130). The run records under
   `~/.local/state/drafter/runs/cairn-cms/` name it in B2's reads `20261018T183844Z-52d21787` and
   `20261018T184651Z-982b32e8` and in change-read's tweak 3 (`20261018T210012Z-22cbc302`, demoted)
   and tweak 5 (`20261018T210311Z-fd33b039`, escalated, since the tweak cited `f:vg42j3`). Tweak 4's
   unplaced answer describes the same pair. The same records name other pairs, and the ones a
   prompt can touch are reachable through `Compare` (`internal/blueprint/since.go:50-53`), which
   puts every fact of a new, removed, or differing item into `Scope.Facts`: prompt 7's removal of
   `ver-live-wait` touches `f:1pb077`, and a prompt that cites `f:vg42j3` (as tweak 5 did) touches
   every `f:vg42j3` pair. The reachable pairs are `f:sszb7b`/`f:vg42j3`, `f:ejuoh6`/`f:vg42j3`
   (B2's `52d21787` names `f:86h9o6` and `f:sszb7b` against it; control 1's
   `20261018T210429Z-592c0739` names `f:ejuoh6` against it), `f:86h9o6`/`f:vg42j3`, and
   `f:ejuoh6`/`f:1pb077` (control 1's read). `f:72yc97` (in `admin.md`) against `f:olofdb` is
   unreachable: no prompt's correct edit changes an item that places or cites either (they sit in
   `before-you-begin`, `push-the-new-key-to-the-worker`'s encoding item, and
   `roll-back-to-the-old-key`, where #48's five tweaks never landed). `f:sszb7b` says a re-push of
   the old key "restores signing with it immediately", and cites only GitHub's and Cloudflare's
   pages. `f:vg42j3` is tagged `[verified]` against `src/lib/github/signing.ts#createInstallationTokenCache`: the token
   cache is keyed on the installation id alone, lives 55 minutes, and a secret change doesn't clear
   it. The planning read is that `f:sszb7b` is the wrong bullet: a re-push changes the key the next
   mint signs with at once, but a warm isolate keeps its cached token until the entry expires. SR.3
   decides each pair from cairn's code, not from this read.
3. **The bullets' correction (Outcome 4).** Each bullet SR.3 proves wrong changes, on the
   `format-test` branch only, as one commit; its SHA is `<base'>`, and every run resets to it and
   reads `--since <base'>`. A pair whose sides differ only in scope is recorded as no defect and
   left alone. The blueprint doesn't change. The roll-back section's `opens` line repeats
   "immediately"; it stays as it is, and any finding on it is a base defect. cairn's main checkout
   is never touched. The PR body names each defect in drafter's own words, with the fact id and the
   code reference, and quotes no bullet text; it notes that the design's "the base moved by that
   one bullet" reads "N bullets" with N the count corrected. `conductor-drafter` files each in
   cairn's backlog after merge.
4. **"Check what you add" (Outcome 1).** A new `## Check what you add` in `docs/blueprint-format.md`,
   between "The edit catalog" and "What `drafter read` does with a blueprint" (anchor
   `#check-what-you-add`). It opens with one sentence: the blueprint read checks each item a change
   adds or alters against these lines, and a change read blocks on a defect in one. Then the
   design's seven lines as a list, one rule per line, each ending in the link to its source.
   The caution line reads "A caution about something that can go wrong is a `failure` item with a
   handler, never a `sentence`", matching `SKILL.md:17`, so it doesn't contradict the catalog's
   "Add a caveat" row, whose caveat bounds a claim. The task-section line reads "In a task section,
   the steps (the actions the reader takes) come before the explanation": the design's "checks" is
   the rotation page's word for its steps, and the meaning is unchanged. The sources each line
   links, quoted at planning:
   - The read's own checklist. The format page names `blueprintPrompt` with no link to its file,
     since a session's read of `docs-page-chain.js` is a protocol breach (resolution 7), and links
     the in-page summary `#what-drafter-read-does-with-a-blueprint`. Lines at `0a7a30b`: 2267-2271
     (the facts it places sit in the facts block), 2281-2284 (a `failure` names its step in `from`
     and its handler in
     `handledBy`; an `example` is a worked example), 2312-2315 (each failure a reader could meet
     has a `failure` item), 2322-2327 (a recovery route before the diagnosis that tells the reader
     which failure they have blocks), and 2329-2332 (a `use` that restates its fact blocks).
     For the agreement line, the consistency read, `ConsistencyPrompt` in
     `../internal/assemble/consistency.go`, line 25: "Report a conflict only when both sides
     cannot be true together; a difference of scope is not one."
   - drafter's own format rule, for the two clauses no published source states: "never invents
     output" rests on [Items](#items) (an `example`'s `facts` names what it rests on), and "its
     symptom differs from every existing row" on the catalog's "Add a failure case" row. The page
     marks both as drafter's rule.
   - The Red Hat peer review guide's Structure checklist
     (<https://redhat-documentation.github.io/peer-review/#_structure>, "Table 4. Structure
     checklist"): "Module types are not mixed, for example, concept and procedure information is
     separate." "Information is presented in the most logical order and location." "Tasks reflect
     the intended goal of the user." "Troubleshooting and error recognition steps are included
     where appropriate."
   - Google's developer documentation style guide, "Headings and titles"
     (<https://developers.google.com/style/headings>): "Use descriptive headings and titles because
     they help a reader navigate their browser and the page." "Write section headings based on the
     type of content that's in the section." A task-based heading starts with a bare infinitive.

   Line to source:

   | Line | Sources |
   |---|---|
   | `example` only from a recorded fact | read 2267-2271, 2284; the page's [Items](#items) (`facts` names what the example rests on; "never invents output" is drafter's rule) |
   | `failure` after its diagnosis, handler a next action, symptom distinct | read 2281-2283, 2322-2327; Red Hat logical order, troubleshooting; the "Add a failure case" row ("symptom distinct" is drafter's rule) |
   | A caution is a `failure` with a handler | read 2312-2315; Red Hat troubleshooting; the catalog's "Add a failure case" row |
   | `heading` names what the section delivers | Google headings |
   | `use` scopes, never restates | read 2329-2332; the page's [Say what a placement carries](#say-what-a-placement-carries) |
   | Steps before explanation in a task section | Red Hat "Module types are not mixed", logical order |
   | A new item agrees with its section's facts | `ConsistencyPrompt` line 25 |

   No line copies cairn's register, and no workstation path enters the page. The page's
   "What `drafter read` does with a blueprint" paragraph gains one sentence for resolution 1: in a
   change read, a conflict that names no fact and no page is recorded as a warning starting
   "Unplaced:" and never blocks.
5. **The skill's "Check" step (Outcome 2).** `SKILL.md`'s "Check" section gains one sentence before
   its `drafter check` sentence: for each item the edit adds or changes, walk [Check what you
   add](format.md#check-what-you-add) before `drafter check` and the commit. The diff adds no rule
   text; the caution sentence already at `SKILL.md:17` is change-read's and stays.
6. **The two new prompts.** The edit catalog's rows the five don't exercise are "Add a link",
   "Remove a claim", "Add or move a section" (move), "Start a new page", and "Follow a rename the
   gate demands". The new prompts take the first two: each is a one-item edit like the five, while
   a move redrafts the whole page, a new page is a different procedure, and a rename needs a code
   change. Each names behavior in a developer's words, with no section id, item id, fact id, item
   kind, field name, or drafter command, and is sent as "Use the blueprint skill. " plus the
   prompt plus " Commit the change.", as the five are.
   - **Prompt 6, add a link:** "On the rotation page's verification part, the reason a publish
     proves nothing for the first 55 minutes rests partly on Cloudflare reusing Worker instances
     that are already running when a secret changes. Cloudflare explains that behavior on its own
     page about bindings, and the page never sends the reader there. Point the reader to
     Cloudflare's explanation where the page gives that reason."
     A correct edit adds one `link` item to `verify-the-new-key`, beside `ver-cache` and
     `ver-cache-claim`, whose target is
     `https://developers.cloudflare.com/workers/runtime-apis/bindings/#making-changes-to-bindings`
     (the anchor of Cloudflare's "Making changes to bindings", fetched 2026-10-18; the page with no
     anchor also counts). Nothing else changes: no new fact bullet, since `f:vg42j3` already cites
     that page; no item restating Cloudflare's behavior; no `see-also` link in place of the
     section's. Probed: `drafter check` reports 0 errors on that edit at `50dc211d9`.
   - **Prompt 7, remove a claim:** "The rotation page's verification steps already tell the reader
     to wait at least a minute between live checks, in the step itself, and already say why, where
     they describe the result. A separate statement right after that says the same thing again.
     Remove it."
     A correct edit removes `ver-live-wait` (a `sentence` citing `f:1pb077`) from
     `verify-the-new-key`, and nothing else: `s-live` keeps "at least a minute after any earlier
     live response", `ver-live-result` keeps the 60-second settled result, and `f:1pb077` stays
     placed by `ver-live-bypass`, `ver-live-result`, and `rec-live-details`, so no `dispositions`
     entry is needed. Probed: `drafter check` reports 0 errors.
   - Each correct edit above is that prompt's reference edit. `drafter check` is the gate, not the
     grade, so each also runs once through the graded read at `<base'>` as a positive control
     before the 21 (resolution 7).
7. **The rate protocol (Outcome 5).** Change-read's resolution 8, with these differences:
   - The cairn worktree is `~/Projects/cairn-cms/.claude/worktrees/format-test`, branch
     `format-test` cut at `50dc211d9`, carrying SR.3's one commit, `<base'>`. Never pushed.
   - The harness is #48's, copied into `<job>` and edited as "Depends on" says. The session flags
     are #48's exactly: `claude -p --model sonnet --effort medium --permission-mode acceptEdits
     --output-format stream-json --verbose --add-dir <drafter wt>/docs --add-dir
     ~/.claude/skills/blueprint --allowedTools "Bash(git *) Bash(drafter *)" --disallowedTools
     "Bash(drafter read *) Bash(drafter page *) Bash(drafter convert *) Bash(git push *)"`, prompt
     on stdin. `drafter-page-hook` is live and runs in every session. Two differences from #48, both
     outside the flags: the session runs under `timeout -k 30 900`, and with
     `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, the documented switch ("To disable auto memory via
     environment variable, set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`", code.claude.com/docs/en/memory),
     since auto memory is "Per repository, shared across worktrees" and `autoMemoryEnabled` is on in
     user settings, so without it one run could write memory a later run loads. The docs don't say
     whether the variable outranks `autoMemoryEnabled`, so the probe and every run compare the
     memory directory's listing before and after; a change there is a protocol breach. Each script
     runs with `run_in_background`; the next step waits for `<name>.done` from `tweak.sh` (or the
     background completion notice) and for `<name>.read.exit` from `read.sh`. A read that leaves no
     exit file is resumed as exit 3 is, through `read.sh`'s `RESUME` mode, from the newest run
     directory under `~/.local/state/drafter/runs/cairn-cms/` whose `state.json` `head` is the
     run's commit; when no run directory matches, the read died before starting, and that is an
     infrastructure failure under the first-try rule.
   - Seven prompts, three runs each, named `t<prompt><run>` (`t1a` to `t7c`). They run in rounds:
     prompts 1 to 7 for run a, then b, then c, so a stop partway leaves an even sample. Each run is
     a fresh session. Control 1 runs after the probe and the positive controls, before round a;
     control 2 runs after round c.
   - Before each run: `git reset --hard -q <base'>`, then `git clean -fdq` without `-x`, so the
     ignored `drafter.local.toml` survives. `git status --porcelain` is empty, `git status
     --porcelain --ignored` matches the record taken when the worktree was made (an extra path is
     removed by name), and `git rev-parse HEAD` is `<base'>`. Record the cairn and drafter main
     checkouts' status, branch, and `rev-parse HEAD`, and the drafter worktree's HEAD.
   - After each run: exactly one new commit whose parent (`git rev-parse HEAD^`) is `<base'>`, no
     upstream, `git ls-remote --heads origin format-test` empty, an empty `git status --porcelain`,
     both main checkouts' status, branch, and HEAD unchanged, the drafter worktree's HEAD unchanged
     and `git -C <drafter wt> status --porcelain` empty on the whole tree (the built `/drafter` is
     ignored, so a build leaves it empty), cairn's memory directory unchanged, a `Skill` call naming
     `blueprint` in the stream, and no read under `~/Projects/initiatives` or of
     `docs-page-chain.js`. Anything else is a protocol breach and a miss, even when the read
     accepts. A dirty drafter worktree is restored with `git -C <drafter wt> checkout -- . && git -C
     <drafter wt> clean -fd docs claude` before the next run, and the breach is noted on the row.
   - Grade: `drafter check` on the commit, then, only when it passes, `<drafter wt>/drafter read
     --sync --json --since <base'> <blueprint>` with `DRAFTER_PROMPTS=<drafter
     wt>/claude/.claude/workflows/docs-page-chain.js`. A run passes when `drafter check` is green,
     the read exits 0, no finding has `blocking: true`, no "Already present:" finding sits on the
     change, and no "Unplaced:" warning is introduced. Every consistency escalation, on any seat,
     is a miss, because the read exits 1 (`cmd/drafter/read.go:59`); each escalated conflict is
     still classified, for the record only, and the classification never changes the count. Each
     "Already present:" finding and each "Unplaced:" warning (copied from the run's
     `record.json` by `findings.py`) is classified against `git show <base'>:<blueprint>` as present
     at base (the base lines quoted) or introduced (on a diff line, or caused by the diff). An
     introduced one is a miss.
   - First try. A run's first dispatched session is its try. A run that fails on infrastructure,
     not on the agent's edit (an API error, a harness error, a timeout, a session that dies), gets
     one rerun from a fresh reset, marked "rerun (infra)" with the failed attempt kept on the row; a
     second infrastructure failure is a miss. A read resumed under standing answer 4 counts as the
     first try when the agent's commit is unchanged. Any other failure is a miss.
   - The bar: 17 of 21 by the raw first-try count, and control 1 draws its blocking finding at the
     seeded step. A control-1 miss means the bar is not met, whatever the 21 score. A run not
     dispatched is reported as not run; the bar is met only with every run made, and a partial
     sample reports its count of runs made.
   - Positive controls, before the 21: each of prompts 6 and 7's reference edits (resolution 6) is
     committed by the executor on a fresh `<base'>`, no session, and run once through the graded
     read, as rows `ref6` and `ref7`. A reference edit that can't pass drops its prompt; the
     executor never rewrites a prompt. With N runs left, the bar scales to `ceil(17 × N / 21)` of N:
     15 of 18 with one prompt dropped, 13 of 15 with both. The PR names a dropped prompt and its
     reference read's blocking finding. A reachable base pair that `ref6`, `ref7`, or control 1
     newly names is judged as SR.3 step 6 says, recorded on the row, and sent to `log-issue`; it
     doesn't move `<base'>`.
   - Controls, once each, outside the 21: #48's `c1.patch` (B2's `s-interval` step, `requires`
     silent) and `c2.patch` (the generate step no longer yields the PEM file but still declares
     `new-key-file`), each applied with `git apply` to a fresh `<base'>` and committed by the
     executor, no session. A patch that doesn't apply is re-seeded with `control.py` and its row
     marked "re-seeded". Control 2's miss is recorded and filed through `log-issue`; it doesn't
     change the bar.
   - The skill link is never removed. For SR.4 it points at `<drafter
     wt>/claude/.claude/skills/blueprint`, set with `ln -sfn` and confirmed with `readlink -f`, and
     the STATUS note records "skill link swapped to <drafter wt>" when it happens. It is restored to
     `/var/home/glw907/Projects/drafter/claude/.claude/skills/blueprint` at SR.4's end and on every
     stop path, confirmed again with `readlink -f`, and re-swapped and confirmed before any run
     after a stop. A session that resumes the pass, and `conductor-drafter` before it removes the
     drafter worktree, runs `readlink -f` and restores the link if it still names the worktree.
   - Patches, streams, read JSON, session costs, and rows live in `<job>`, outside the public repo
     and every worktree's git dir. Rows name paths relative to the worktree or by role, never
     absolute.

## Tasks

### SR.1: the empty-conflict rule (35 min), paired with SR.2

- Risk class: `runner`.
- Outcome: resolution 1.
- Files: `internal/pipeline/blueprint.go` (`completeBlueprintRead`, its doc comment),
  `internal/pipeline/blueprint_change_test.go` (`TestChangeReadConsistency`),
  `internal/pipeline/pipeline.go` and `internal/pipeline/work.go` (the two `Demoted` doc comments
  only).
- Acceptance. Fixture: `TestChangeReadConsistency`'s harness (`newBlueprintHarness`,
  `withPages("a")`, facts `lumen-key-ttl` and `lumen-grace`), with the table gaining the warning
  prefix and demoted count it expects, and a two-conflict answer builder beside `conflict` that
  takes a distinct conflict text per conflict (today's builder gives every conflict "they
  disagree", so a `Contains` check would match either). Rows:
  - A change read whose one conflict has empty `facts` and `with` accepts; this row sends
    `"facts":[]` literally, as run `20261018T210143Z-593b4ba9` did, where today's builder sends
    `null` for a nil slice. The record's last
    warning starts "Unplaced: " and holds the conflict text, the consistency verdict is `demoted`,
    and the summary's `Demoted` is 1. Fails today: `untouched` returns false for an empty `facts`,
    so the page escalates on `consistency`.
  - An unplaced conflict beside an untouched one accepts, with `Demoted` 2 and one "Already
    present: " and one "Unplaced: " warning. Fails today for the same reason.
  - An unplaced conflict beside a touched one escalates on `consistency`, and the escalation detail
    names both conflicts' texts. An unplaced conflict in a whole read escalates, and so does one in a
    scoped state with no `Facts`. A named fact with an empty `with` escalates. These pass today
    and pin the rule's edges; the existing row "an empty facts list blocks" stays.
  - An unplaced conflict with a blueprint `fix` escalates on `blueprint`. Fails today: it
    escalates on `consistency`.
- Test: `make check`. `git diff --stat 0a7a30b -- internal/pipeline/money.go
  internal/pipeline/resume.go` is empty; a need to edit either stops the line.

### SR.2: "Check what you add" and the skill's "Check" step (30 min), paired with SR.1

- Risk class: `runner`.
- Outcome: resolutions 4 and 5.
- Files: `docs/blueprint-format.md` (the new section, and one sentence in "What `drafter read`
  does with a blueprint"), `claude/.claude/skills/blueprint/SKILL.md` ("Check" only).
- Acceptance. Fixture: the two files themselves. Fails today: `grep -n '^## Check what you add$'
  docs/blueprint-format.md` and `grep -n 'format.md#check-what-you-add'
  claude/.claude/skills/blueprint/SKILL.md` both find nothing.
  - The heading sits between "## The edit catalog" and "## What `drafter read` does with a
    blueprint"; its list has seven lines, one per design rule in the design's order, the caution
    line worded as resolution 4 says; each line carries at least one link from resolution 4's
    table, and the Red Hat and Google URLs are those quoted there.
  - The read paragraph holds the "Unplaced:" sentence.
  - `SKILL.md`'s diff is the one sentence of resolution 5 and adds no rule text; every
    `format.md#` anchor in `SKILL.md` names an existing heading of `docs/blueprint-format.md`
    (grep, as B2.2 checked).
  - No workstation path and no cairn register text in either file (`grep -n
    '/var/home\|~/Projects\|docs-register'` on both prints nothing), and no link to
    `docs-page-chain.js` (`grep -n 'docs-page-chain.js)' docs/blueprint-format.md` prints nothing).
  - `vale --config ~/Projects/cairn-cms/.vale.ini docs/blueprint-format.md` reports no error on an
    added or changed line. Its baseline at `0a7a30b` is 3 `Google.Quotes` errors (311:9, 311:62,
    370:8); the count may fall, never rise. `SKILL.md` matches no glob in that config and is
    unlinted.
- Test: `make check` (`TestReferenceNamesEverySchemaField` and `TestEditCatalog` still pass).

### SR.3: the corrected bullets and the test base (40 min), run by the session beside the pair

- Risk class: `runner`, `live-account` (one read, about $0.35, and at most one more).
- Outcome: resolutions 2 and 3, and the format-test worktree ready.
- Files: none in drafter. In cairn, the `format-test` branch only:
  `docs/internal/facts/extend.md`, one line per corrected bullet.
- Procedure:
  1. Read the spend baseline. Create the worktree (`git -C ~/Projects/cairn-cms worktree add -b
     format-test <path> 50dc211d9`), copy `~/.config/drafter/cairn-cms.local.toml` to
     `<cairn wt>/drafter.local.toml`, and confirm `git -C <cairn wt> check-ignore
     drafter.local.toml`. Record `git -C <cairn wt> status --porcelain --ignored` in `<job>`.
     Write the clock file there.
  2. At `50dc211d9`, for each reachable pair of resolution 2 (`f:sszb7b`/`f:vg42j3`,
     `f:ejuoh6`/`f:vg42j3`, `f:86h9o6`/`f:vg42j3`, `f:ejuoh6`/`f:1pb077`), read both bullets, the
     code and pages each cites, and `drafter refs <id>` for each side, run in the cairn worktree.
     The code at hand: for `f:vg42j3`, `src/lib/github/signing.ts` (`createInstallationTokenCache`,
     `cachedInstallationToken`) and `src/lib/github/backend.ts` (`createGithubApp`), with
     Cloudflare's "Making changes to bindings"; for `f:1pb077` and `f:ejuoh6`,
     `src/lib/sveltekit/health.ts` (`VERDICT_TTL_MS = 60_000` at line 58, `createLiveTokenCheck`,
     and lines 85-93 and 208-215, which `f:ejuoh6` cites). Record `f:72yc97`/`f:olofdb` as
     unreachable, unread.
  3. For each pair, decide whether cairn's code, or a bullet's own cited source, proves one bullet's
     claim wrong. If so, that bullet is corrected; if the sides differ only in scope, the pair is
     recorded as no defect with the reason. The planning read names `f:sszb7b` for the main pair;
     a reading that points at another bullet corrects that one and gives the reason in the PR body.
  4. Correct each such bullet in place with the Edit tool: same id, the claim scoped so both
     bullets can be true together, its `Source:` gaining the code reference that bounds it, and its
     tag a citable kind (`verified`, `external`, or `vendor`, `internal/plan/facts.go:32`) whose
     parenthetical is updated to match the new `Source:` (`f:sszb7b`'s "neither half is cairn
     source" would turn false). Nothing else changes in the file or the blueprint.
  5. `drafter check` reports 0 errors; commit on `format-test` as one commit; record `<base'>`;
     save `git show <base'>` and `git format-patch -1 <base'>` in `<job>`.
  6. Row 0: one whole read at `<base'>` with the installed binary (`drafter read --sync --json
     <blueprint>`, `DRAFTER_PAGE_CAP` per standing answer 4). Record its consistency answer. If it
     still names a corrected pair, revise that bullet against the conflict's text. If it names a
     pair resolution 2 didn't list, judge it by resolution 2's reach test: a reachable pair gets
     steps 2 to 4 under the same rule (correct only what cairn's code proves wrong; a scope
     difference is no defect), and an unreachable one goes to Later beside
     `f:72yc97`/`f:olofdb`. All such changes share one amend of the commit (`<base'>` moves, and
     both saved files are rewritten) and one more read; then proceed whatever it says (standing
     answer 3). Reset the worktree afterwards, since a whole accept writes `drafted.lock`.
- Acceptance: `git -C <cairn wt> diff --stat 50dc211d9 <base'>` shows `docs/internal/facts/extend.md`
  only, one changed line per corrected bullet, each bullet named in `<job>`; each reachable pair
  has a recorded verdict (corrected, with the bullet, or no defect, with the reason);
  `git -C ~/Projects/cairn-cms status --porcelain` is empty; row 0 is in the `<job>` table with its
  cost; the PR-body paragraph for cairn's backlog is drafted, one entry per corrected bullet (fact
  id, what the bullet claimed wrongly, the code reference, the correction's sense).

### SR.4: the format test, as a rate (90 min), after SR.1, SR.2, and SR.3

- Risk class: `runner`, `live-account`.
- Outcome: resolution 7, run live from the worktree binary by path.
- Before it: `make -C <drafter wt> build`; confirm `<drafter wt>/drafter config --json` run in the
  cairn worktree exits 0 and shows `prompts`; swap the skill link to the worktree and confirm it
  with `readlink -f`; write `p6.txt` and `p7.txt` from resolution 6 verbatim, and confirm `p1.txt`
  to `p5.txt` match #48's PR body; finish the harness edits in "Depends on" now that `<base'>` is
  known, and run its grep gate; run one probe session (about $0.20, #48's cost $0.19) with the
  exact flags that invokes the skill and reads `format.md#check-what-you-add`, and confirm its
  stream shows the `Skill` call, a read of the format page, and no read of `docs-page-chain.js`.
  Then the positive controls `ref6` and `ref7`, then control 1 (resolution 7). Check the meter
  before every dispatch.
- Acceptance: the rows, each appended to the `<job>` table as it is recorded, headed by the note
  that the base is `50dc211d9` plus the corrected bullets, ids listed (`<base'>`). Each run row
  holds change-read's
  CR.3 fields (the verbatim prompt, whether the skill fired, files read outside the worktree and
  the skill, files the commit touched, `drafter check`'s result, the scope, the read's verdict,
  blocking count, and cost, every finding classified, the consistency outcome with each escalated
  conflict classified against `<base'>`, the demoted-conflict count), plus: whether the session
  read "Check what you add" (a Read of `format.md` or `blueprint-format.md` whose range takes in
  the heading's line), each "Unplaced:" warning classified as resolution 7 says, any protocol
  breach, any "rerun (infra)" mark, and for each blocking finding on the change, the new rule it
  falls under (or "none"). Each control row shows its blocking finding at its expected location,
  and each positive-control row its verdict. Then:
  - the raw count against the bar (17 of 21, or the scaled bar of resolution 7), and each
    prompt's count of 3;
  - on their own lines, prompts 1 to 5 together, of 15, and prompts 6 and 7 together, of 6;
  - sessions that read the section, of 21;
  - the session plus meter spend against $20.
  Afterwards `readlink -f ~/.claude/skills/blueprint` is the main checkout's skill directory again,
  `git -C <cairn wt> ls-remote --heads origin format-test` prints nothing, the format-test
  worktree is removed (`git worktree remove`), and `git -C ~/Projects/cairn-cms branch -D
  format-test` runs (the correction survives as `<job>`'s format-patch); `git -C
  ~/Projects/cairn-cms status --porcelain` is empty.

### Close (30 min)

- The drafter gate on the close head is the full-suite home: `DRAFTER_DIR="$PWD" bash
  scripts/drafter-gate.sh`, re-issued on exit 75. drafter has no CI.
- Whole-branch `diff-reviewer`, told two rules: every format rule in the skill is a link by heading,
  never a copy; every rule in "Check what you add" cites a published source, or drafter's own code
  or format rule marked as such (resolution 4 sources two clauses and the agreement line that way
  on purpose), and copies nothing from cairn's register. One fix chain, then the gate again.
- `BACKLOG.md` through `log-issue`: #6 stays open, its text narrowed to the second case (a re-cited
  fact in a base conflict), with one line saying the first case closed in this PR, on evidence:
  SR.1's unplaced rows passing on the close head, plus any SR.4 run that recorded an "Unplaced:"
  warning, named by run id. The entry also notes that `--json`'s `demoted` counts unplaced and
  already-present conflicts together, so only `record.json` tells them apart. #1 closes if the bar
  is met, or stays open with the result. Each other
  follow-up, such as a base conflict outside SR.3's pairs, goes through `log-issue`.
- The PR body opens with `## Brief` and carries the rate table, the classified findings, the
  `<base'>` note with the count of bullets moved (resolution 3's "N bullets" note), a "For cairn's
  backlog" section with one entry per corrected bullet and each no-defect pair (resolution 3), a
  line that prompt 7 exercises only the catalog's "the item goes" branch of "Remove a claim", and
  the score with live spend. The rate section names the three grading rules from "Departures
  from the design". Before it opens, `grep -n '/var/home\|\.local/\|jobs/'` on the body
  prints nothing. The executor stops at PR-ready, and `conductor-drafter` sends the packet.

## Merge order

`conductor-drafter` runs these rows.

1. glw907/drafter, then `git -C ~/Projects/drafter pull --ff-only && make -C ~/Projects/drafter
   install`, then `readlink -f ~/.claude/skills/blueprint` names the main checkout's skill
   directory. Remove the drafter worktree only after this.
2. File each of the PR's "For cairn's backlog" items in cairn-cms's `BACKLOG.md` through
   `log-issue`, tagged `#initiative:docs-system`, pointing at the format-patch in
   `~/.claude/jobs/drafter-skill-rules/ft/`.
3. Launch F1, per Geoff's ruling, whatever the format test scored.

## Later

- Correcting the bullets on cairn's `main`, and the roll-back section's `opens` line with them
  (cairn's backlog, from merge row 2).
- The unreachable base conflict, if it recurs: `f:72yc97` against `f:olofdb`.
- Backlog #6's second case: a base conflict that escalates because a change re-cites one of its
  facts.
