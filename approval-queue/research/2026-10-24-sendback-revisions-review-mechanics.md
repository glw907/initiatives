# Send-back revisions plan: mechanics and feasibility review

Reviewer: `plan-reviewer` (claude-opus-5-5, medium), 2026-10-24. Target:
`approval-queue/plans/2026-10-24-sendback-revisions.md` and its two prompts at initiatives
`660d33a`, checked against approval-queue `c8018fd`, dotfiles `3bfdcd5`, drafter `a1fc918`, PR #5,
and pass-core. Saved by the planning session; the reply follows as returned.

No finding changes the approved design. Every fold below fits inside it. There are no blockers: 7
major findings and 14 minor ones.

## Major

**1. A packet waiting at restart that Geoff sends back loses its decision.** major, correctness.
Plan:591-596 (Merge order step 1), plan:154-158 (call 1).
- A packet queued before the merge is waited on by a bash process that has already loaded the old
  `decision_program`. A `git pull` swaps the file to a new inode, so the running process keeps the
  old text.
- The old program accepts a reject only when `($dec | keys) == ["decision", "note"]`
  (`bin/.local/bin/approval-queue:660`). Anything else fails with "decision.json does not match
  the packet; nothing was logged", exit 1.
- After the restart, the new server writes `{decision, note, calls}`. So a waiting packet that
  Geoff sends back loses its logged decision, and the session that queued it gets exit 1.
- Call 1's "restart window" note covers only the other direction (an old server with the new
  command). Step 1 waits only on `blueprint`, `page`, and `change` items, never on `packet` items.
- Fold: add `packet` to step 1's waiting check. For the "restart anyway after 60 minutes" branch,
  have the hand-over name each waiting packet's id and say its send-back must be read from that
  item's `decision.json` by hand.

**2. The throwaway instance's queue line is not written out, and it leaves out
`APPROVAL_QUEUE_PORT`.** major, correctness. Plan:233-251 (call 12), plan:544-547 (CT step 2), T2
at plan:460, T3 at plan:492.
- The command takes its port from `APPROVAL_QUEUE_PORT` and defaults to 7907
  (`approval-queue:80`).
- Call 12 sets the port only on the build. Without it on the command, `curl -sf 127.0.0.1:7907/`
  reaches the live server, so no instance starts. The `$base/item/$id` check then fails with exit
  1.
- If `XDG_STATE_HOME` were also dropped on a repeat, the item would land on Geoff's live board.
- PR #5's plan had a "Commands" block that wrote every line in full. This plan dropped it.
- The CT `gh` stub has no stated path or author either. `tests/packet.test.sh` defines its stub
  inline, so nothing exists to reuse, and T0 writes only `xdg-open`.
- Fold: restore a Commands block, written out at each step that uses it (build with
  `APPROVAL_QUEUE_PORT`, queue with `PATH`, `APPROVAL_QUEUE_PORT`, and `XDG_STATE_HOME`, stop as in
  call 12, seed with `seed-packet.ts` and `seed-blueprint.ts`). Name the CT gh stub's path, have T0
  write it, and say it answers `pr view`, `pr diff`, and `api .../compare/...` with and without the
  diff Accept header.

**3. The new `calls` type breaks svelte-check in T2's file, and the pair has no merge-conflict
answer.** major, correctness. Plan:153, plan:396-404.
- `Decision`'s reject already has `calls?: Array<{id, choice}>` for the doc kinds (`items.ts`).
- `ItemPanel.svelte` `answeredCalls` (around line 244) runs `for (const call of decision.calls ??
  []) ... call.id` after narrowing only on `decision.decision`.
- Widening `calls` makes that line a type error. Probed with the repo's own tsc: `TS2339: Property
  'id' does not exist on type 'PacketCall | { id: string; choice: string; }'`.
- `ItemPanel.svelte` belongs to T2. So T1 either ends with a red gate or edits T2's file.
  pass-core "Pairs" says "A merge conflict stops the line", and the plan has no standing answer.
- Fold: give T1 the one narrowing edit in `answeredCalls`. Add a standing answer: a pair merge
  conflict in a file one task owns is resolved by keeping both sides, and the run goes on.

**4. The blueprint and page "Revision N" badge has no proof, and where its lookup runs is
unstated.** major, correctness. Plan:58, plan:268-270, plan:418-446, plan:74-90.
- Call 15 says the doc kinds "use call 2's lookup on their own log ref" but doesn't say whether the
  command or the server's `load` does it.
- No T1 case and no end-to-end step queues a blueprint twice.
- Fold: the command does the lookup in the `blueprint | page` branch on `<repo>:<file>` and writes
  `revises: {item, revision}`; add a `tests/blueprint.test.sh` case (queue, send back, requeue,
  revision 2) and a route-test seed.

**5. The #24 test can pass before the fix.** major, correctness. Plan:227-232, plan:469-471.
- `prefill()` already maps only `openCalls`, which leaves out decided calls. So "answer a call, then
  open the note" likely passes on today's code.
- The record points to a different order: `openNote` keeps an existing `noteText`, and line 442
  reopens the note on undo.
- Fold: the test reproduces T2's traced sequence and fails on `c8018fd` before the fix; record the
  red run in STATUS.

**6. The drafter gate has no answer for a batch-friction PR that never merges.** major,
correctness. Plan:336-343, conductor prompt line 21.
- `gh pr list -R glw907/drafter --head worktree-batch-friction --state all` returns `[]` today.
- If that PR closes unmerged, is opened from another branch, or is never opened, the conductor's
  Monitor waits forever.
- Fold: when the PR is closed unmerged, or the batch-friction session has ended without one, the
  conductor checks with `conductor-drafter` once; T5 then cuts from `origin/main` and goes in the
  second packet.

**7. The drafter gate command is wrong.** major, correctness. Plan:105-106, T5, executor prompt.
- drafter's gate is `scripts/drafter-gate.sh`, which wraps `make -C <dir> check` in
  `cairn-run-gate --fresh` on the light lane, because the isolation guard refuses `cairn-run-gate
  '<string>'`.
- Fold: `DRAFTER_DIR=<worktree> bash <worktree>/scripts/drafter-gate.sh`, re-issued on exit 75.

## Minor

8. **The since diff can block a whole queue.** `gh api .../compare/<bogus>...<sha> --jq .status`
   exits 1 and prints the error JSON on stdout. A 406 (too large) is "any other failure", exit 1,
   which refuses the packet for a nice-to-have section. A merge from main makes an `ahead` diff
   carry main's changes. Fold: read status only on exit 0; 406 writes no since file; note the
   merge effect.
9. **Unnamed states.** `decisions.jsonl` absent (jq on a missing file exits 2, the refusal code);
   the earlier item's `decision.json` missing at load; a `--description` path that doesn't exist.
10. **Nobody owns T3's revising-packet seed.** Fold: T1 extends `seed-packet.ts` and
    `seed-blueprint.ts`.
11. **Pre-flight checks the wrong thing for the plan path.** The prompts read the plan from the
    initiatives main checkout, at `34510ae` without it. Fold: `test -f` on all three files there
    after a pull.
12. **Auto mode may block T5's skill edits** (optional). No `autoMode.allow` line names drafter
    skill files in a drafter worktree. Fold: confirm or add a pre-flight rule.
13. **The other-workstation step is under-specified.** Fold: write out the pkill, say the next
    call starts the server, and skip a repo the host lacks.
14. **Docs batch sessions break when the approval-queue PR merges** (optional). The extend
    blueprints batch handoff queues without `--description`. Fold: step 5 also messages that
    session.
15. **End-to-end step 1 departs from the design's wording** (optional): the design says "set to
    reject"; the closest routine verdict is `send-back`, not `hold`.
16. **The `pgrep` pattern is too loose** (optional): `'[w]orktrees/sendback'` matches
    `sendback-plan` and `sendback-revisions`.
17. **Over-ceremony** (optional): T3 and CT render the same set; T0's dotfiles baseline repeats
    T4's gate; one `diff-reviewer` could read both small branches.
18. **Nothing measures the 420-minute ceiling at runtime** (optional).
19. **Unestimated work** (optional): T1's task-scope read and fix sit between the pairs with no
    minutes.
20. **T2's ownership of `frame/` reads as narrower than it is** (optional).
21. **Revision count can run high** (optional): rejects from before a ref's last approve count.

## Verified, no finding

- `worktree.baseRef: "head"` is in `~/.claude/settings.json`; inside a linked worktree "head"
  resolves to that worktree's HEAD.
- The compare API's `ahead`, `behind`, and 404, and the diff Accept header, behave as stated.
- jq `keys` sorts, so `[calls, decision, note]` is right.
- The packet send-back already posts `part:<ref>` and `ask:<n>` (`PacketSeg`, `PacketAsks` use
  `form="decision-form"`).
- The live parser refuses an unknown `## What changed`, so the conductor's packet through the old
  command needs none.
- The register is a symlink into the dotfiles survey skill.
- The curl stubs exit 0, and `scripts/gate.sh` never builds.
- The live server's command line matches the merge-order pkill pattern exactly.
- Pre-flight holds: the playwright paths, the 585-line blueprint, free ports 7962, 7972, and 7992,
  `.claude/worktrees/` ignored in all three repos, and free `sendback*` branch names.
- Path arithmetic is right (305 path, 440 sum) and inside 420.
- The risk class `runner` fits, and the executor runs on sonnet at medium.
