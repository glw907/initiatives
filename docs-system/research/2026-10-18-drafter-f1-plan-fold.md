# F1 plan fold: the mechanics review

Fold of `research/2026-10-18-drafter-f1-plan-review-mechanics.md` into
`plans/2026-10-18-drafter-f1-setup-checks-plan.md`, 2026-10-18. Code re-read at drafter `main`
`0a7a30b` (change-read merged) and cairn-cms `50dc211d9`. Each finding was checked against source
or a probe before folding; probes ran in the session scratchpad
(`/tmp/claude-1000/-var-home-glw907-Projects-drafter/a7e821e2-a175-410c-9c7b-041a4377406e/scratchpad`).

Rulings applied: G1 is option (a); finding 3 is a method call, folded as (a); the skill-rules pass
now sits between change-read and F1 (Geoff, 2026-10-18), written as a "skill-rules merged"
dependency and nothing more.

## Dispositions

1. **Folded** (resolution 6, a new line-count bullet and the table's `path:lines` row; F1.2
   acceptance rows "the line after a file's trailing newline" passes and "a line two past the last
   newline" fails). Verified: `validatePointer` splits on `'\n'` (`check-facts.mjs:697`), and
   `wc -l` gives 303, 23, and 126 for the three files cited one line past.
2. **Folded** (resolution 5: the `RootINI` check, JSON decode failure, stderr's first line; F1.3:
   `t.Setenv` of `HOME` and `XDG_CONFIG_HOME`, and preflight rows with a global config present).
   Probed: with `~/.config/vale/.vale.ini` and no project file, `ls-config` exits 0 with `RootINI`
   empty; E100 goes to stderr with exit 2. New from probing: `RootINI` carries the logical
   working-directory path while git returns the resolved one (through a symlinked directory), so
   the comparison runs `filepath.EvalSymlinks` on both. Also new: `Paths` lists the global style
   directories, and this workstation's `~/.config/vale/styles` holds `Google`, so a lint with the
   project's package missing exited 0 here and exited 2 with E201 only under a clean `HOME`. The
   preflight's style test now requires the directory under a `Paths` entry inside the root, with
   an F1.3 row for a style present only globally.
3. **Folded** (resolution 8, a `.vale/styles/.gitignore` bullet; F1.4 acceptance; F1.6 step 3's
   `git status --porcelain` check; F1.4 45 to 50 min; the "Later" `.gitignore` item dropped).
   Verified `requireClean` refuses untracked files (`internal/pipeline/start.go`). Probed: a
   commit holding `/Google/` in that file, then a real `vale sync` of the v0.7.1 URL, leaves
   `git status --porcelain` empty and the `.gitignore` in place.
4. **Folded** (resolution 6: `verify.go` walks the spans itself, never through `Fact.Sources`;
   F1.2 row for a slashless `name.go:3` reaching a unique basename). Verified: `isSource` returns
   false for a slashless span that doesn't stat. A rough grep over cairn's five fact files finds 34
   slashless `:line` or `#name` pointers missing at the root; the plan says "about 30".
5. **Folded** (Merge order step 1 now greps `state.json` for `"stopped"`). Verified:
   `Open.Count` counts open ledger intents (`internal/ledger/ledger.go`), and `State.Stopped` is
   `json:"stopped,omitempty"` (`internal/run/state.go`). The state files live at
   `~/.local/state/drafter/runs/<repo>/<run>/state.json` on this machine.
6. **Folded** (F1.1 files gain `cmd/drafter/read_test.go`). Verified:
   `TestSummaryCountsDemotedAndAlreadyPresent` calls both writers.
7. **Folded**, as the first of the review's two options (resolution 2: the text line is `prices:
   <date> (<layer>)`, JSON adds `prices_date_source`; `docs/configuration.md` says an overriding
   layer sets the date and names the user and local layers; F1.1 acceptance). Verified: `apply`
   merges `prices` key by key, and `allowedIn` lets both `user` and `local` set `prices`. The
   refusal option was not taken: seven test files set `prices.models` with no `date`
   (`cmd/drafter/read_test.go:451` among them), and naming the date's
   layer removes the mislabel at a fraction of that churn.
8. **Folded** (resolution 5: `drafter page`'s preflight runs `exec.LookPath("drafter")`; F1.3
   row). The gate line runs through `/bin/sh` with the inherited `PATH`, per the plan's own
   resolution 3.
9. **Folded** (F1.6 step 2 appends `prompts`, with the reason).
10. **Folded** (resolution 4 for `gate`, resolution 8 for `init`, and F1.3 and F1.4's test notes).
    Verified: `check` declares `--root` in `newCheckCmd`.
11. **Folded** (F1.2 `drafter check` row asserts the fixture's pointer count; the cairn row asserts
    a nonzero count; F1.4 and F1.6 assert `1` and `2`). The facts README is not a facts file
    (`factsFiles` skips `README.md`), so `init`'s store holds exactly one pointer.
12. **Folded**, each state: Vale exit 2 maps to gate exit 2 (resolution 4, F1.3 row; probed E201
    exits 2); undecodable `ls-config` JSON exits 2 (resolution 5); an unreadable cited file is an
    error on its bullet (resolution 6); a duplicated id under an `ids` filter selects and flags
    both bullets (resolution 6, F1.2 row); `seed` on a non-blueprint path refuses with `is not a
    blueprint` when `PagePath` (`internal/blueprint/lock.go`) reports false (resolution 9, F1.5
    row); `init` runs `os.MkdirAll` first, since `atomicfile.WriteFile` creates its temp file in
    the target's directory, and "writes nothing" is scoped to refusals (resolution 8).
13. **Folded** (resolution 6: substring containment over the joined window, citing `:713` and the
    symbol form's `:527`; F1.2 row for a token found inside a longer word).
14. **Folded** (header re-dated to `0a7a30b`; `writeReadSummary`, `recordAccepted`, and
    `completeBlueprintRead` cited by symbol; `page.go`'s `runPage` cited by symbol). One citation
    was wrong before change-read too: "a page not drafted yet" is `LockEntry`'s comment in
    `internal/blueprint/blueprint.go`, not `internal/pipeline/blueprint.go:172-173`; fixed in
    resolution 9 and F1.5. Resolution 9 also notes `recordAccepted` now keeps the earlier entry on
    a scoped read. The change-read diff touched no other file the plan cites by line.
15. **Folded** (F1.3 files: `README.md`'s Develop section lists Vale beside `node`). F1.3 is the
    first task whose tests need Vale.
16. **Folded** ("Held for Geoff" replaced by "Rulings" with the reason; the dependency line, the
    table's row, F1.2's G1 rule, the comparison bar, and Merge order step 3 collapsed to the
    ruling).
17. **Folded**, free: one sentence on the pair line asks new helpers in package `main` or `e2e`
    to carry their task's subject.
18. **Folded** (F1.2 dispatched at `high`; 5 minutes added for the two inter-pair merges).
19. **Refused**: `drafter read`'s `recordAccepted` is the only writer of `accepted` in drafter,
    and `seed` already requires the value to equal the blueprint's `HEAD` blob with both files
    committed; a hand-edited lock is the owner's own assertion and shows in review, so a channel
    rule costs more than the risk it removes.

Counts: 19 findings; 18 folded (all 14 correctness, 15 through 18); 1 refused (19).

## Order change

"Depends on, checked at launch" now requires the skill-rules pass merged to drafter `main` (its PR
merge in `git log --merges`, its worktree gone), naming its two files and that F1's
`docs/blueprint-format.md` edits are other sections. Standing answer 1 notes the order change.
Whether F1 waits on that pass's score is Geoff's pending answer; the plan says only "merged". The
change-read worktree was still present at the fold, so that line says so.

## Estimate

Path 290 to 300 minutes: F1.3 90 to 95 (the `RootINI` and global-style checks, `LookPath`, the
Vale exit-2 mapping, the README line), F1.4 45 to 50 (the `.gitignore` and its acceptance), and 5
for the two inter-pair merges. 300 is 1.25x the design's 240, inside the 480 line.

## Against the approved design

Nothing reaches standing answer 3. G1 (a) narrows the design's "a source that resolves as `path`"
to a warning for an unresolved bare path, which Geoff ruled. The `.gitignore` is a second file
`init` writes beyond the design's bullet, as `.vale.ini` already was, and it serves the design's
outcome (a new repo runs). Requiring the style directory inside the project tightens "confirms
Vale and the package"; it doesn't change it.
