# Polish plan review: mechanics and feasibility

Reviewer: `plan-reviewer` (Opus, medium), on `plans/2026-10-24-polish.md` at `bfbbf24`, checked
against approval-queue `dbe553b`. Saved by the planning session from the agent's reply.

## Verdict

The plan is sound in shape: the path arithmetic, the risk class, the Orca mechanism, the marked
and decoder claims, and call 13's fields all hold. Call 3's decision-path mechanics have two real
defects, and several fixture and setup steps are missing. Five major findings need folding before
launch; the rest are minor. No owner forks.

## What holds (verified)

- Path: 15 + 145 + 15 + 120 + 80 = 375; task sum 535; 1.56x of 240.
- Call 1: holds against pass-core "Lifecycle". `approval-queue approved` gates only a skill step
  (drafter `blueprint/SKILL.md:65`), not a gate tool, and the command makes no merge or account
  call.
- Call 5: matches the code (`approval-queue:848` tab wait, `lifecycle.test.sh:55-56`
  `queue_design`, `:66` `finish`). The racing-collect case (`:187-194`) has the same exposure and
  the same fix.
- Call 6: probed marked 18.1.0 (`Q &amp; A` slugs `q-amp-a`; `&#38;` decoded; codespan and escape
  unaffected). decode-named-character-reference 1.3.0 is newest, `browser` export
  `./index.dom.js`.
- Call 7: the base gives `setup.p2` to `setup.p4` to the second section, so the test fails on base.
- Call 9: `toRow` parses `packet.json` each poll.
- Call 10: daisyUI 5.7.47 `.btn:checked` sets `--btn-color` and `--btn-fg` to primary; the
  prototype has `k === 'b'`, `moveList`'s scope, and `handlers.pick` (`site/dist/app.js:148,180,315`).
- Call 13: PR totals and `docHtml: render(withoutBrief(content.doc))` match the route (225, 247).
- Call 22: key `enable` in `org.gnome.Orca.Speech` at `/org/gnome/orca/<profile>/speech/`;
  `check_speech_setting` shuts the server down and `_speak` logs `SPEECH OUTPUT:` with no server
  (`speech.py:128-131`); `--debug-file` sets `debugLevel = LEVEL_ALL` (`/usr/bin/orca:168-169,318-321`).
- Pre-flight: references, skills, agents, browsers exist; ports free; `.claude/worktrees/`
  ignored; `worktree.baseRef: "head"` set.

## Findings, ranked

1. **Major, correctness.** Call 3's EXIT trap `[ -e "$item/deferred.json" ] || retire_item "$item"`
   drops today's `decision.json` guard (`approval-queue:158`). On every decided exit `retire_item`
   renames, sees the decision, renames back, and fails; under `set -euo pipefail` a failing last
   command in an EXIT trap aborts the trap and changes the exit status (probed: rc=1, cleanup
   skipped). Fold: keep the decision guard, add `|| true`, run cleanup unconditionally; define
   `retire_item` beside `proc_running`, above the `withdraw` branch.
2. **Major, correctness.** In the TERM path `withdraw` polls `[ -e item.json ] || exit 0`
   (`approval-queue:56-58`); `retire_item`'s rename makes `item.json` vanish briefly, so
   `withdraw` can exit 0 while the waiter restores `item.json` beside a decision no live command
   logs. Fold: after TERM wait for the waiter to exit (`proc_running` false), then decide by the
   files (no `item.json`: 0; `decision.json`: "decided while withdrawing; run collect", 1;
   `deferred.json`: retire it, 0; else "still queued", 1). R1's read names this window.
3. **Major, correctness.** R1 never reinstalls after merging T1's new dependency, so R1's gate and
   T4's build fail with module not found. Fold: `npm ci` in the pass worktree after both merges;
   CT reruns it if T3 touched the lockfile.
4. **Major, correctness.** CT has no recipe for its blueprint fixtures or the amend review
   (`check_blueprint` needs a committed, clean file and a description that passes the brief
   check; an amend needs a logged approve with a blob, `amend_of` at `approval-queue:289-295`).
   T3's sample blueprint has no recipe either. Fold: a fixture block in call 19 used by T3, T4,
   and CT, with the amend chain written out.
5. **Major, correctness.** Replacing `PartFiles` with `FilesDiff` drops "Changes since you sent it
   back" (`since`); `DesignView` hard-codes `id="design"` and an h2, so two design parts duplicate
   ids; each `FilesDiff` registers the single `focus-filter` key. Fold: keep `PartFiles`' since
   block; give `DesignView` an embedded form or render `.desk-read` directly; say what `/` does on
   a packet.
6. **Major, correctness.** `live_leak` returns early when the temp log is absent
   (`packet.test.sh:25`, `blueprint.test.sh:26`, `page-change.test.sh:30`), so a live-only write
   still passes, and nothing proves the new failure. Fold: guard only on the live log, read
   `$root/ids` plus the temp log's ids, and record one proof run showing the FAIL line.
7. **Minor, correctness.** The gone answer cannot reuse `gone(request)`: every caller has read the
   body before `decide` runs, so a second read gives null and every post answers 404. Fold:
   `decide` and `decideOnce` take the form or a packet flag and return `fail(410, ...)`; a route
   test covers it.
8. **Minor, correctness.** The `retire_item` shell test passes on base. Fold: label it a
   regression guard; the proofs that fail on base are the collect exit, the `items.test.ts` gone
   case, and a `withdraw` on a deferred item with a `decision.json` exiting 1.
9. **Minor, correctness.** The collect test covers only the deferred case and an unbounded wait
   would hang the gate. Fold: add a non-deferred case (dead pid, collect, withdraw, exit 1); bound
   both waits as `finish()` does.
10. **Minor, correctness.** T2's files miss `Margin.svelte` (`.drawer-x` at :117) and ItemPanel's
    `div.sendback` (:1054); T3's list omits `DecisionBar.svelte`, `FilesDiff.svelte`,
    `EmptyState.svelte`, and `PrView`'s kbd. Fold: add both to T2; let T3 touch any file T2
    touched.
11. **Minor, correctness.** Call 9's cache has no named file; `items.ts` is T1's. Fold: a new
    T2-owned `src/lib/server/packet-facts.ts` with its test.
12. **Minor, correctness.** Call 18's `PageData` depends on T2's layout shape. Fold: derive the
    type, or reconcile at R1.
13. **Minor, correctness.** The 7931 reference server is never stopped. Fold: `--directory`,
    `run_in_background`, `pkill -f 'http.server 7931'` after the shots, 7931 in pre-flight, and an
    answer for jsdelivr unreachable.
14. **Minor, correctness.** The live restart runs even on a stale checkout; the conductor
    exception to pass-core's pull rule is unstated; "re-checks every 10 minutes" has no mechanism;
    deferred items count as waiting. Fold: restart only after a pull; state the exception; a
    Monitor until-loop; exclude `deferred.json` items.
15. **Minor, correctness.** #35's cookie behavior is in neither escalation list. Fold: not
    allowed.
16. **Minor, correctness.** T3 must be dispatched with `run_in_background: true` for T4 to run
    beside it.
17. **Minor, correctness.** End-to-end steps 5 and 7 name no wait. Fold: step 7 polls 3 seconds
    for the line's rect; step 5 rests its timing on the lifecycle test and CT checks exit 1 and the
    message through `aq-detach`.
18. **Minor, correctness.** Orca's `_speak_list` starts a new `SPEECH OUTPUT` line on a voice
    change (`speech.py:200-229`), so label and role can land on adjacent lines; on Wayland a window
    without an activation token may not take focus; Orca's first run may write more dconf keys.
    Fold: accept label and role within one utterance group; name the focus cause under answer 3;
    `dconf dump /org/gnome/orca/` before and after, reset new keys.
19. **Minor, correctness.** T4's commands are prose. Fold: a "T4 commands" block.
20. **Minor, correctness.** "12 render pairs" does not fit two packet references. Fold: name the
    pairing, or grade against both (16 pairs).
21. **Minor, correctness.** Call 18's "closes #3's other half" is backwards. Fold: reword.
22. **Minor, correctness.** Line 29 cites research files that do not exist yet, and the prompt is
    untracked. Fold: commit both with the plan PR.
23. **Minor, correctness.** The new dependency brings `character-entities`. Fold: name both.
24. **Minor, optional.** T0 15, R1 15, and CT 80 look tight. Fold: T0 25, R1 25, CT 100 (path 415).
25. **Minor, optional.** Call 9's cache should be escalation-allowed, keeping the shared facts
    function and the layout fields.
26. **Minor, optional.** #33's eight reruns are partly redundant, and "another worktree" is
    unclear. Fold: prove it deterministically (fresh `tab.seen` over 5 seconds on base, under 1.5
    on the fix), then 3 solo and 2 beside T1's own `npm test`.
27. **Minor, optional.** A stop on a not-allowed item halts unrelated work. Fold: it holds the
    merge, not the line.
28. **Minor, optional.** A second register-test red has no answer. Fold: trace it, file it, and
    hold the merge.
