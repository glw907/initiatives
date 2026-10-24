# Docs friction plan: mechanics review

Reviewer: `plan-reviewer` (claude-opus-5-5, medium), 2026-10-24. Target:
`approval-queue/plans/2026-10-24-docs-friction.md` at `81179cc`, checked against approval-queue
`967be66`, drafter `f2ad05e`, cairn-cms, and dotfiles `31db050`. Probes ran in the planning job's
temp directory. Nothing touched port 7907 or wrote under `~/.local/state/approval-queue`.

Verdict: no blockers, 9 majors, 12 minors, 2 over-ceremony findings, 1 owner fork. The fold is
`2026-10-24-docs-friction-fold.md`.

## What checked out

- **Trap and wait loop.** Bash holds the TERM trap until the foreground `sleep 1` ends. In a probe
  of the command's trap pair, `item.json` was gone 0.52 s after TERM and `wait` reported 143.
- **Liveness test.** `/proc/<pid>/cmdline` for the command reads `bash\0<path>/approval-queue\0…`.
  A killed, unreaped process (a zombie) has a 0-byte cmdline and reads as not running.
- **SvelteKit cookie.** `cookie.js:78` is quoted correctly for kit 3.0.1. `maxAge` 34560000 is 400
  days.
- **CodeMirror view.** `@codemirror/view` 6.43.15 `dist/index.js:6504` and the
  `defaultView || window` walk are quoted correctly.
- **`@codemirror/merge`.** The newest release is 6.12.3. The `.d.ts` quotes, `mergeControls`,
  `collapseUnchanged` (default margin 3, minSize 4), and the `uncollapseUnchanged` export match.
- **github-slugger.** 2.0.0 is the newest release and gives `set-a-sections-starting-state`, then
  `-1` on a repeat. Raw Markdown must be stripped first: it gives `use-foo_bar-_x_` and
  `a-linkhttpx`. `notes.ts` runs under plain `node 24`, so `anchors.ts` is feasible.
- **Quote placement.** `place()` with `from = to = 0` behaves as call 7 says.
- **#28 reading.** `buildSentBackCalls` gives every part a `{ref, verdict}` call, ask-bound parts
  included.
- **jq log-once.** `jq -R -n -e 'any(inputs|fromjson?|objects; .packet == $id)'` answers right on a
  garbage line and on empty input, in about 5 ms on a copy of the 435-line log.
- **Drafter gate query.** It runs and prints `[]`.
- **Pre-flight.** Every path in the list exists.

## Major (all correctness)

1. **Call 1, the pid test.** A reused pid that lands on another process with an argument named
   `approval-queue` (another queue command, a `collect`, an `npm --prefix …/approval-queue`) reads
   as the waiter, so `withdraw` would TERM another session's command. Fold: record `pidStart`
   (`/proc/$$/stat` field 22) in `item.json`; a pid is running only when `/proc/<pid>/stat`'s field
   22 equals it. In bash: `read -r s </proc/$$/stat; s=${s##*) }; set -- $s; echo ${20}` (probed;
   matches `awk '{print $22}'`).
2. **Call 4, `collect` on a change.** A change's `item.json` has `repo`, `number`, and `head` but
   no `pr`; `head_unmoved` reads `$pr`, `$pr_repo`, and `$number`. Fold: for a change, set
   `pr="$repo#$number"` and `pr_repo=$repo`, and test `collect` on a change.
3. **Call 4, how `collect` is wired.** The decision functions are defined at command lines 724-900,
   after the queue `case` and the server and tab block, so an early dispatch cannot call them, and
   the line-88 EXIT trap would remove `item.json`. Fold: `collect` loads `item.json`, skips the
   queue and start and tab code, sets its own EXIT trap, then runs the shared wait loop and `case`.
4. **Call 16, a third live-log check.** `tests/page-change.test.sh:25-26,330` carries the same
   check. Fold: add it to call 16, T1's files, and the BACKLOG #29 note.
5. **The pair prompts lack answer 10.** T2's worktree predates T1's #29 fix, so its gate still has
   the size checks. Fold: quote answer 10's first bullet in the T1 and T2 prompts.
6. **Call 8, the slug alias.** `<slug>.p<n>` and `<slug>.p<n>.<part>` derive from the section slug
   (`notes.ts:112-129`), so aliasing only `.heading` drops old `.p<n>` notes under an apostrophe
   heading to the top. Fold: alias every key derived from the old section slug, with a `.p0` test.
7. **The `anchors` dispatch has no owner.** T1 owns the command but not call 8; T2 owns
   `anchors.ts` but not the command. Fold: R1 adds the dispatch and usage line beside its test.
8. **CT cannot read the queuing command's exit code.** `setsid -f`'s parent exits 0 at once
   (probed). Fold: for steps 1 and 2, run the queue line without `setsid -f` through the Bash
   tool's `run_in_background: true`, and write that variant in "Commands".
9. **The #28 test can pass vacuously.** `since_diff` returns early on an unmoved head (command line
   222). Fold: move both parts' heads on the resend; assert the approve-marked part has no
   `since.patch` and that its head moved.

## Minor

10. **Call 2, regex in bash (correctness).** Bash `=~` has no `\d`. Fold: `^[0-9]{8}T[0-9]{6}-[0-9]+$`.
11. **Call 4, log-once on an absent log (correctness).** Fold: say an absent log means not logged;
    one first-decision test case.
12. **Call 2, withdraw on a deferred item (correctness).** In the first second after a defer the
    waiter is alive, the TERM path runs, the EXIT trap keeps `item.json`, and `withdraw` exits 1.
    Fold: check `deferred.json` before the pid and remove `item.json` directly; the exit-1 message
    says "decided while withdrawing; run collect".
13. **The withdraw, collect, and anchors line (correctness).** It omits `APPROVAL_QUEUE_PROJECTS`
    (a design part's hash) and, in CT, `ct-bin`. Fold: add both.
14. **CT commands not written out (correctness).** Fold: write each CT command in full with `ct`
    and `7993`.
15. **CT fixtures (correctness).** Step 2's approved blueprint, reused in step 5, becomes an amend
    review whose collapsed runs can hide the note. Step 5 never asserts the `p<n>` note moved.
    Fold: one file per step, and assert the `p<n>` card moved one line.
16. **Uncollapse position (optional).** `uncollapseUnchanged.of(pos)` matches the collapsed
    range's exact start (`from != e.value`, merge `index.js:1037`). Fold: find the start from the
    decorations or rebuild it from `getChunks`.
17. **The slugger seed (optional).** drafter's `HeadingSlugs` (`internal/plan/slug.go:65`) slugs
    the front-matter `page` first; cairn's `pipeline.ts` runs plain `rehypeSlug` with no seed.
    Fold: state the seed and how `anchors` tells a blueprint from a page.
18. **cwd in subagents (optional).** Agent threads reset cwd between Bash calls. Fold: subagents
    use absolute paths, as `bash <wt>/scripts/gate.sh`, which does its own `cd`.
19. **T0's long-blueprint note (correctness).** T2's worktree lacks the quote shape check, so the
    note must be a string anchor under a heading the two slug rules spell alike.
20. **#19's browser fallback (optional).** Fold: cite the end-to-end check's wait rule.
21. **Other workstation (correctness).** The step skips merge-order step 1's waiting-item check.
22. **Pre-flight files (optional).** The two prompt files are untracked at `81179cc`. Fold: commit
    them in the planning PR.

## Over-ceremony (optional)

23. **The CT `gh` stub.** Every CT step can queue a blueprint, which never calls `gh`. Fold: drop
    the stub.
24. **The #29 self-test.** Pointing `HOME` at a temp directory also moves the register path. Fold:
    drop it, or check the assertion on two temp files inline.

## Owner fork

25. **Call 15, #28.** The plan applies "only sent-back parts count as revised" to the since diff
    only, so a resend of only approve-marked parts still needs `## What changed`. Options: (a) the
    plan's reading; (b) a ref counts toward revision status only when not `sentBack: false`, and a
    note-only send-back keeps today's reading. The reviewer recommended (a) and asking once.
