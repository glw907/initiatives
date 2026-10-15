# Mechanics and feasibility review: approval packets design

Target: `approval-packets/specs/2026-10-14-approval-packets-design.md` at `c72785d` (branch `approval-packets-design`). Line numbers refer to that commit. Checked against `approval-queue` main `8fbe952`, `~/.dotfiles`, the prototype at `~/.local/share/approval-packets/prototype-2026-10-14/`, and the research files. Reviewer: `plan-reviewer` (Opus, medium).

Verdict: direction sound, numbers match the prototype (12 packets, 7 asks), not buildable as written: two blockers, eleven majors, nine minors.

## Blockers

### B1. The exemplar extractor cuts every packet exemplar at its Evidence fence (blocker, correctness)
spec:100-103, spec:213; `tests/approval-queue.test.sh:218-221`. The register test extracts exemplars with awk that closes a block at the first bare triple-backtick line. The packet contract nests a `text` fence inside every ask's Evidence, so the exemplar is cut at the inner fence's close (probed: output stopped at the excerpt, losing `## Routine`). Fold: packet exemplars use a four-backtick `packet` fence closed by four backticks; the extractor matches fence width and routes `packet` to the packet check; add a nested-fence test.

### B2. The decision JSON's privileged fields name no channel, and an ask is never tied to a part (blocker, correctness)
spec:84-98, 125, 142-153, 241. Today the server rebuilds cards from the stored body and checks a fingerprint (`src/routes/item/[id=id]/+page.server.ts:140-145`), and the command stamps `head` from its own fetch (`bin/.local/bin/approval-queue:110-111`). The spec states no equivalent: (1) verdict can come from the preselected routine verdict, an override, or an ask choice's tag, and the spec never says the server rebuilds parts from the stored packet and accepts only kind-legal overrides; (2) `head` must come from the command's fetch, never from `decision.json`; (3) `asks[]` has no `part`, and a PR named by an ask cannot be in the routine table, so whether it appears in `parts[]` is undefined; (4) a design-part ask has no verdict rule; (5) `Part: none` has no ref for the log. Fold: a "Channels" paragraph (verdict = stored routine verdict, validated override, or the chosen choice's tag; head = command fetch only; every ask with a Part emits that part into `parts[]` and `asks[]` gains `part`; design-part asks need tags too; `Part: none` logs `ref: "ask:<n>"`), with decision-builder tests per channel including a tampered post.

## Major

### M1. `step` parts have two conflicting identities (major, correctness)
spec:77-79, 110, 127, 149. Routine step rows are free text, but the JSON refs `step:2`, a plan-step number. What `me` makes the session do is unstated; against pass-core Close ("I'll run it myself" means the session does not merge; `claude-merge-guard` needs `PREMERGE_DONE=<n>`), a `me` step plus an approved PR would merge anyway. Fold: steps are routine rows only, ref `step:<row>`; a step row names the PR it gates or none; a PR gated by a `me` or `skip` step does not merge and the session reports it; plan steps stay prose.

### M2. Board-as-home conflicts with redirect, auto-advance, auto-close, and tab hand-over (major, correctness)
spec:170, 138. `/` redirects to the oldest item (`src/routes/+page.server.ts`); the empty page `goto`s an arriving item (`+page.svelte:60-63`) and `window.close()`s after 30 s, which works because every navigation replaces its entry; after a decision `ItemPanel.svelte:214-215` goes to `next ?? '/'`. Unstated: whether `/` still redirects, where a decision sends the tab, whether an open board picks up new packets, what an empty board does with auto-close, whether board links use `replace`. Fold: one paragraph covering all five, tests in `routes/page.server.test.ts`.

### M3. The monthly review cannot report refusals, and the log is per host (major, correctness; OWNER FORK on hosts)
spec:155-162, 234-235. A refusal exits 2 before any item exists (`approval-queue:28-40`), and only decided parts reach `decisions.jsonl`, so refused packets and refused repeat decisions have no source. State is per host (`~/.local/state` on thinkpad-x1 and pavilion), and a stowed timer fires on both. Fold: the command appends refusals to `refusals.jsonl`, or drop the bullet. Fork: (a) review on one named host, (b) also pull the other host's log over ssh, (c) per-host reviews. Recommend (a).

### M4. The repeat-decision rule blocks legitimate re-sends, and misses the `pr` kind (major, correctness)
spec:129, 251. Refusing any earlier decision at the same head blocks re-sending a held PR. Whether a reject logs parts is unstated. Only packets write the log, so a PR approved through the `pr` kind is invisible. Fold: refuse only a prior `approve` at the same head; a reject logs no parts; have the `pr` kind's approve append too, or scope the rule to packets.

### M5. The lead repo and repo count are undefined for design and step parts (major, correctness)
spec:132, 170. A design path and a step text carry no repo; the prototype used frontmatter `repo:` and a `Repo` column, which the contract dropped. Fold: a `Repo` column in the routine table and a `Repo:` field on asks (or a repo argument); design paths resolve against that repo's checkout; convert the prototype exemplars.

### M6. The check-state table misses states the code distinguishes (major, correctness)
spec:113-130. `pr-summary.ts:77-82` sorts checks into pass, pending, fail; some repos have no CI. Missing: pending or no checks; a PR that does not exist, is closed, or is merged (today `gh pr view` fails, exit 1 under `set -e`); `Recommended:` non-numeric or out of range; fewer than two choices; `Facts:` with no bullet; a choice label containing `: `; `## Routine` absent or prose; unknown `Kind`; `[you]` with no text. Fold: add rows; pending or none becomes Not-checked content the UI shows; refuse only closed or merged.

### M7. `log-issue` blocks in 5 of 16 repos (major, correctness; OWNER FORK)
spec:62, 220. `approval-queue`, `cairn-cms`, `drafter`, `fishwright`, `initiatives` have no `BACKLOG.md` or `.claude/project-tracking.json`, where log-issue asks the user first-run questions, impossible for an unattended session; `"backlog": false` repos stop. Today's "now" disposition loses its decider. Fork: (a) a plan task seeds backlogs, (b) with no backlog, follow-ups go to the initiative record, (c) ask in the packet. Recommend (a) plus (b) as fallback; the session decides "now" itself and lists those items in the PR body.

### M8. The end-to-end check cannot run on the current harness; two proofs are vacuous (major, correctness)
spec:245-252; `tests/approval-queue.test.sh:1-3, 32-38`. The harness never starts the app; it writes `decision.json` itself. Checks 1, 2, 3 through the UI, and 6 need a browser-driven app, and `package.json` has no Playwright. The `gh` stub returns `number: 42, headRefOid: abc123` for every PR, so "the other approved at its head" is vacuous. Fold: shell test for 4, 5, and JSON shape; a vitest server-action test (the `page.server.test.ts` pattern) for 2 and 3 with a crafted post; a named browser check for 1, 2, 6 (Chromium plus `visual-verifier`); a `gh` stub keyed by PR number with distinct heads asserted.

### M9. Cross-repo landing order breaks one gate either way (major, correctness)
spec:204-213, 164; `scripts/gate.sh:3-4`, `tests/approval-queue.test.sh:209-222`. The gate reads the installed register and requires at least three `brief` exemplars. If the register's exemplars all become packets, the `pr` and `design` kinds and PR-body briefs still need brief exemplars. Fold: the register keeps the brief exemplars and adds packet ones; the approval-queue branch gate runs with `REGISTER=` pointing at the workstation branch file; the plan states the merge order (workstation first).

### M10. The design omits its path-minute estimate and standing answers (major, correctness)
pass-core step 1/4 requires a path-minute estimate and standing answers for foreseeable stops (an estimate ceiling). Fold: add an estimate from recent pass scores and a ceiling question in the approval batch.

### M11. The risk class understates the merge-authorization path (major, correctness; OWNER FORK)
spec:241. `runner` fits the skill and gate changes, but the decision builder and server action mint merge authorization. approval-queue has no adapter path map (no `CLAUDE.md`; no `dotfiles-pass` skill exists). Fork: (a) keep `runner`; (b) raise only the decision-builder and server-action task to `auth-data`. Recommend (b). Separately, name the adapter that governs approval-queue.

## Minor

- m1 (correctness). pass-core sites beyond Close also change: `SKILL.md:28` (design hand-over), `186-190` (conductor "puts each PR or design"), `225-236` (triage shape and `choices`). List every section.
- m2 (optional; OWNER FORK). The self-merge rule's basis changes: under the spec, a pass with filed follow-ups sends a packet that may hold nothing about them. (a) keep, (b) self-merge once follow-ups are filed. Recommend (a) and have the monthly review measure routine-only packets from `ordinary` passes.
- m3 (correctness). Name who appends `decisions.jsonl` (the app's `decide()` or the command) and when relative to Undo; the command copies the packet file into the item directory so the word-target bullet has input.
- m4 (correctness). `hold.ts` has only `cancel` and `flush`; pause needs `pause()`/`resume()` and tests. Mod+Enter must respect the ask lock (`keys.ts:51` commits regardless today).
- m5 (correctness). A sort remembered in `localStorage` reorders on hydrate; use a cookie read in `load`.
- m6 (correctness). Initiative validation needs `^[a-z0-9-]+$`, an `initiative.yaml` check, an `INITIATIVES_DIR` override for tests; the command writes the record's `title` into `item.json`.
- m7 (correctness). "As the current drawer does" is false: today's drawer is flat (`+layout.svelte:175-199`); cite the prototype.
- m8 (optional). `model-review-notify` runs two unattended `claude -p` sessions; it is not a reminder. The new script shares only the timer shape.
- m9 (optional). The packet parser must stay dependency-free and erasable-syntax-only like `brief.ts`; cross-repo merges need `gh pr merge <n> -R <owner/repo> --merge --match-head-commit <head>` (both flags confirmed).

## Over-ceremony

- O1 (optional; OWNER FORK). The monthly review adds a timer, service, notify script, prompt, and log while the model review already runs monthly. (a) separate reminder, (b) add a section to `docs/model-review/prompt.txt`. Recommend (b), which runs unattended and so needs its proposals to land as a packet.
- O2 (optional). The spec runs several pages against pass-core's page limit; acceptable at spec depth.

## Claims verified

`gh pr merge --match-head-commit` and `-R` exist; the prototype holds 12 packets and 7 asks with the rules as cited; the DORA quote is at `research/2026-10-14-agentic-dev-practice.md:302`; the spec's "principles 1, 2, 6" should point at the ranked-principles list, which differs from the section numbers. The research's advice against running tallies sits uneasily with the "Later" per-class rates, a note for later.
