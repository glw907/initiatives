# Mechanics review: approval-queue comments plan (2026-10-21)

The `plan-reviewer` agent (opus, medium) read the plan and both launch prompts on 2026-10-21, before
they were committed. It checked them against approval-queue `3ade397` (PR #4's head) through `git
show`, the SvelteKit 3.0.1 and @codemirror/view 6.43.15 source, the installed command, and the
live pre-flight paths and ports. It found 26 gaps: 0 blockers, 13 major, and 13 minor. None is an
owner fork. The fold record is at the end.

## Major

1. **The per-item order call 2 relies on doesn't exist** (correctness).
   - `queued()` (`src/lib/server/blueprint.ts:48-56`) is keyed per file by `join(worktree, file)`.
   - A change item has no worktree.
   - The blueprint and page reject, and the change approve and reject (`+page.server.ts:280-318`),
     don't run inside `queued`, so a comment write can interleave with a decision that reads
     `comments.json`.
   - Fold: a per-item queue keyed by the item directory, nesting `queued(worktree, file)` for
     blueprint and page.
2. **A change doc's comment can't be anchored as specified** (correctness). `add` names no doc,
   and the change doc's `DocReview` is built with `blob: ''` (`ItemPanel.svelte:254`). Fold: `add`
   posts `file`, mapped through `docs.json` to `docs/<k>/new.md`; no blob check on a change;
   `anchor.commit` is `meta.head`.
3. **New comment ids collide with thread ids on a re-queue** (correctness). Each queue run is a new
   item, so new comments restart at `C1`, which round 1's threads already use. Fold: number after
   the highest id in `replies.json` and after the highest already used.
4. **Throwaway instances can run the wrong code or the wrong port's build** (correctness).
   - The `approval-queue` on PATH is a symlink into the main checkout.
   - The command builds only when `build/index.js` is missing.
   - The port is baked in at build time, and `hooks.server.ts` returns 403 for any other `Host`.
   - Fold: the worktree's command by absolute path, an explicit build per port, and A2's start line
     written out.
5. **A1's curl acceptance gets a 403** (correctness). SvelteKit's CSRF check
   (`runtime/server/csrf.js`) forbids a form POST whose `Origin` doesn't match. Fold: send
   `-H 'Origin: http://127.0.0.1:7961'` and `-H 'x-sveltekit-action: true'`.
6. **Undo loses everything except doc calls and triage rows** (correctness).
   - `desk.drafts` holds triage rows only. `noteText`, `answers`, `verdicts`, and `picks` are
     panel-local (`ItemPanel.svelte:63, 94, 110-124`).
   - Under call 6 the panel unmounts, so a packet's asks come back blank.
   - Fold: the remounted panel seeds that state from the held form data. Add a packet Undo
     acceptance.
7. **The old `desk.held` gate would freeze the next item** (correctness).
   - `frozen` (`ItemPanel.svelte:271`), the approve early returns, and `keyAction`'s `held` gate
     (`keys.ts:48-77`) all read it.
   - `nextItem` and j/k can pick the held item.
   - Fold: A2 owns every reader and `keys.ts`, excludes held ids, and names the queue order.
8. **Ctrl+Enter in the comment box approves** (correctness). `keyAction` maps Ctrl+Enter to
   approve from any text field (`keys.ts:58-64`), and nothing owns fixed-copy's "Save or cancel
   the comment you have open first". Fold: A3 adds a comment-box context and the comment keys to
   `keys.ts`, plus the decision refusal.
9. **The end-to-end check can pass vacuously** (correctness). It needs two comments (one moved
   past its offsets, one removed), a reply that `threads` asserts, every call answered, a
   sequenced Undo, and a named builder for the `--replies` file.
10. **No standing answer for a red end-to-end check, and standing answer 5 contradicts CT**
    (correctness). Fold: loop only on traced causes, escalate a returning cause, and make a red
    end-to-end check a forced ask while R still runs.
11. **Live commands aren't written out in full** (optional). `cairn-run-gate` keys on the command
    and its directory, and call 11 uses placeholders.
12. **The `--replies` check and the comment ops miss states** (correctness).
    - The check doesn't say how it answers an empty array, duplicate ids, or a change thread whose
      `file` names no doc.
    - The ops have no `reopen`, and nothing says what an empty reply does.
    - Nothing covers an absent `comments.json` or a `missing` file.
13. **The live-restart wait has no standing answer** (correctness). conductor-drafter can't see
    Geoff's tab, and the wait has no timeout. Fold: the conductor checks the live state root
    itself and restarts after a bounded wait.

## Minor

14. Build anchors from LF-normalized text, as `readBlueprint` and `readChange` do (`items.ts:262,
    286`) (correctness).
15. The background post takes over the success cleanup (`ItemPanel.svelte:620-626`: drafts, the
    `desk.calls.<id>` keys, the refresh) and posts to the absolute `action.href` (correctness).
16. Escalating call 6 needs a stated fallback: keep today's in-page hold (correctness).
17. No task owns the send-back toast's comment count (correctness).
18. A2's render acceptance has no grader. Keep only the 320 no-scroll probe (optional).
19. AM1 and R are single-deliverable tasks, so fold each into a neighbor (optional).
20. The model choices carry no reasons, and A2 holds a subtle hold on Sonnet (optional).
21. Tasks carry no risk class (optional).
22. The pre-flight doesn't prove the live server runs #4's build, so check `build/index.js`'s
    mtime (correctness).
23. Geoff's open tab keeps the old client after the restart, so the packet should say to reload
    it (optional).
24. The render script must launch headless-shell 1248 through `executablePath`, with network for
    jsdelivr and a wait for the editor to mount (optional).
25. Ids are reused after a delete, so number after the highest used (correctness; folds with 3).
26. Name `ChangeDoc.kind` as the source of the gone copy's kind word (correctness).

Checked and fine:

- Enhance's `FormData(form, submitter)`, its absolute `action`, and `cancel()` make the capture
  feasible.
- A read-only CodeMirror editor still tracks a selection.
- The ignore rule lives in `.git/info/exclude`.
- The `pgrep` pattern matches nothing today.
- All reviewers and skills resolve, the ports are free, and PR #4 is open at `3ade397`.
- The packet decision's jq program is unaffected.
- Per-host coverage is in place.

## Fold record

The planning session folded the review itself, departing from `spec-plan-review`'s separate fold
agent. It held the code map and the plan's reasoning, and a fresh agent would have had to rebuild
both. Each finding was checked against the code map from `3ade397` before folding.

| # | Disposition | Where |
| --- | --- | --- |
| 1 | Folded | Call 2 |
| 2 | Folded | Calls 1 and 2 |
| 3, 25 | Folded | Call 2 (ids) |
| 4 | Folded | Call 11 and each task's commands |
| 5 | Folded | A1's acceptance |
| 6 | Folded | Call 6, A2's acceptance |
| 7 | Folded | Call 6, A2's files |
| 8 | Folded | Call 9, A3's files |
| 9 | Folded | "Outcome", CT |
| 10 | Folded | Standing answers 5 and 6 |
| 11 | Folded | "Commands" |
| 12 | Folded | Calls 2 and 4 |
| 13 | Folded | "Merge order" step 1 |
| 14 | Folded | Call 2 |
| 15 | Folded | Call 6 |
| 16 | Folded | Standing answer 4 |
| 17 | Folded | A3 |
| 18 | Folded | A2's acceptance |
| 19 | Folded | AM1 into A3, R into CT |
| 20 | Folded | "Models" (A2 moved to opus) |
| 21 | Folded | Each task's risk line |
| 22 | Folded | "Pre-flight" |
| 23 | Folded | "Close" |
| 24 | Folded | Call 13 |
| 26 | Folded | Call 4 |
