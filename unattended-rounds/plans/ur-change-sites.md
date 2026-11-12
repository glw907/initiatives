# Change-site leads for the overhaul's planners

A read-only Sonnet agent wrote this on 2026-11-11 from the three repos at approval-queue
`0bd4828`, workstation `7a62abe`, and standards `896f819`. Every line is a lead. A planner
verifies each one against the code as the earlier passes left it, and line numbers have moved.

## approval-queue (`~/Projects/approval-queue`)

- Gate: `bash scripts/gate.sh` (svelte-check, vitest, every `tests/*.test.sh`); needs `npm ci --prefix approval-queue`. No CI. `BACKLOG.md` at root, open items #49, #41, #38.
- CLI: `bin/.local/bin/approval-queue`, 864-line bash. `refuse()` at 131. `snapshot` 200-232 (reads `headRefOid`, no base branch). `merge` 283-338 (never checks `.kind`, so a stop packet with `heads.json` passes; `view_pr` at 320 reads `state,headRefOid,body`, no `baseRefName`). `digest_line` 340-345 writes `{time, ref, head, claim, lane}` to `digest.jsonl`. `land` 346-374 (view fields at 362, digest line at 372). `queue_packet` 549-683 (writes `item.json` about 650-680, no `round` field). `append_log`/`packet_decision` 772-810 write `decisions.jsonl`. `withdraw` 53-96, `pending` 97-130, `reply` 259-282, `collect` 393-405.
- `approval-queue/src/lib/facts.ts`: `Facts` 48-63 (no `round`), `UNFORCED_CAP = 3` at 112, `TITLE_MAX=80` at 115, `PR_REF` 117, `parseFacts` 215-312 (kind 225, stop reason 230-233, stop needs steps 291), `parseText` 397-519, `SECTIONS` 390.
- Board: `src/routes/+page.server.ts:8-41` (`toRow`, group key at 20), `src/lib/board.ts:40` `boardGroups`, `PACKET_WORD` at 90, `+page.svelte` 248 lines.
- Items: `src/lib/server/items.ts` (`ItemMeta` 18, `readMeta` 183, `listWaiting` 204, `listDecided` 224, `readItem` 250). `KINDS` are design, triage, packet only; no report item kind.
- Packet page: `src/routes/item/[id=id]/+page.server.ts`, `src/lib/server/packet-facts.ts:24`, `packet-decision.ts:54`, `src/lib/packet-view.ts:25-30` `LEAD` (`LEAD.stop` "Pass paused until you decide."), `statusLine` 38-45, `PacketPage.svelte` (310 lines, Approve about 300).
- History: `src/routes/history/`, `src/lib/server/history.ts`. Digest: `src/routes/digest/`, `src/lib/server/digest.ts:57` `readDigest` (groups by repo).
- Tests: `src/lib/facts.test.ts`, fixtures `src/lib/fixtures/{design,close,stop}-*`, `board.test.ts`, `packet-view.test.ts`, `items.test.ts`, page server tests; shell `tests/packet.test.sh`, `merge.test.sh`, `lifecycle.test.sh`, `approval-queue.test.sh`.

## workstation (`~/.dotfiles`)

- Caps in `bin/.local/bin/claude-context-budget`: `CLAUDE_MD_LINE_CAP=120` (line 24), `SKILL_CAPS` (28-33). Current: `pass-core/SKILL.md` 1496 of 1500 words; `references/conductor.md` 555 of 560; `executor.md` 793 of 900; `planner.md` 925 of 940; `planning-samples.md` 229 uncapped; `CLAUDE.md` 120 of 120 lines. A new reference needs a `SKILL_CAPS` entry or goes uncapped.
- `approval-packet/SKILL.md` 908 words, uncapped. Step 2 (line 24) lists fact keys; step 8 (57, Approve at 61-68) has no stop case.
- Adapters: `claude/.claude/skills/cairn-pass/SKILL.md` (426 words), `site-pass` (840), and `.claude/skills/dotfiles-pass/SKILL.md` (453, project skill, risk map at 42-49).
- Risk map: `claude-worktree-busy` and `claude-context-budget` are `runner`; `claude-launch-guard` is unnamed, so `ordinary`; skills, settings, `scripts/**`, `tests/**` are `runner`.
- `pass-core/SKILL.md`: design step 18-32, Conductor 105-109, Models about 66-70. `references/planner.md`: Design 6-33, Stops 34, Pre-flight 47, Launch 70. `conductor.md`: Hand-off 8, Run 27, End 54.
- `CLAUDE.md` pass section at lines 9-15.
- `bin/.local/bin/claude-launch-guard` (Python, 179 lines): `PLAN_PATH` 32, `named_plan` 102, `plan_for` 107-126, `missing` 129, `main` 148; tests `tests/test_claude_launch_guard.py`. Backlog #72 at `BACKLOG.md:14-15`.
- `bin/.local/bin/claude-worktree-busy` (Python, 106 lines): `process_hit` 30-47, `session_hit` 54-67 (no state filter), `edit_hit` 69-90; tests `tests/claude-worktree-busy.test.sh`.
- `claude/.claude/docs/unattended-work-guards.md` (201 lines): `/goal` section 113-136; no usage or weekly section exists.
- Gate: `bash scripts/gate.sh`, which runs `scripts/check.sh` (legs `skill-caps`, `claude-md-budget`, `context-budget-test`, `worktree-busy`, `pass-loads`, `pytest`).
- No home yet for the miss class tag.

## standards (`~/Projects/standards`)

- `plugins/standards/skills/brainstorming/SKILL.md` (228 lines, 1778 words): description at line 3, "Offer recon" 85-88, "The Written Design" 147-197 (cover list 150-157, builder check 162-191).
- No version field in `plugin.json` or `marketplace.json`. No local gate; CI `.github/workflows/validate.yml` runs plugin validate, `scripts/scan.sh`, `scripts/check-skill-lines.sh` (500-line cap, `WORD_CAPS` names three other skills), `scripts/check-references.mjs`. Changes land by pull request.
- Attribution: `THIRD-PARTY-NOTICES:126-130`.
