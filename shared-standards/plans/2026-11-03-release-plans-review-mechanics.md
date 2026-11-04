# Mechanics review (standards:plan-reviewer), plans at initiatives ed6fd0c

Saved by the planning session from the reviewer's reply. Read against cairn-cms main bb3c8d3a2, the
spec at d880b9e with its fold verification, both pre-flight scripts, and the live
`~/.claude/settings.json`, `~/.local/secrets` (names only), and `~/.local/state/cairn-gate/`. Three
probes run: `npm pack` destination, `pgrep -f` self-match, the actions/checkout README.

Holds: pairs and passes file-disjoint, generated outputs included (`scripts/release/` falls in the
`scripts` bucket, `.claude/` in `harness`; neither pass writes `guidance-hashes.json`, api-surface,
or a template file). Citations hold except finding 21. The rehearsal prompt count works
(`driver.mjs:126` appends, `:189` logs `answered "<match>"`). `--leg` reruns tear down (run-gate.sh
EXIT trap `:50-56`). The check-version / check-consumers-must import cycle is safe (function
declarations, no init call). The grant line covers every `.claude` file B writes plus B8's dotfiles
worktree. Paths: A 425+65+280 = 770 (task sum 1,030); B 50+130+115+100+160 = 555 (work sum 635).

## Blocker

1. **Probe script never registers PS twice** (correctness; `preflight-token-probes.py:100-114`; A:32, A:156-161; spec :294). The duplicate-name row stays pending, P1's stale branch cannot be chosen, the A prompt stops at launch on a pending row, and the script deletes `tmp-token-setup` (:136), so a refill needs a second sitting. Fold: register twice, print both, delete both by uuid, final read prints every registration name for PF6. *(Planning session: done in the script, with the integrity lens's I1/I2/I11/I25; stub-tested.)*

## Major

2. **`--record-file` meets an absent or empty file; main's writer refuses an empty body** (correctness; T6 A:123-135; `record.mjs:146-147`). Every row write throws, T4's `finally` logs it, a 60-110 minute run ends with no rows. The `--all` pending writer has the same gap. Fold: T6 cases for an absent file (created 0600 with the section), an empty file, the four pending rows under `--cli --all`, and a missing parent dir failing before any leg.
3. **OWNER FORK as filed: any STATUS or BACKLOG commit after rc.4 blocks the stable** (correctness; B1 B:90-107 "A change to `src/lib/` or `docs/STATUS.md` still fails"; spec rc.4 step 9; A and B Close 6; `check-stable-source.mjs:123-125`; `cairn-releasing:157`). Ruling 17 says paths that ship in no package are ignored; STATUS and BACKLOG ship in none. Options: (a) widen the ignore set to inert unshipped paths (`docs/STATUS.md`, `BACKLOG.md`, `ROADMAP.md`, `docs/internal/**`), flipping `check-stable-source.test.ts:123`, keeping `.github/**`, `scripts/build/**`, `package.json` checked; (b) freeze main from rc.4 to stable. Recommend (a).
4. **B5's "-rc tag" wording differs from the spec's hook regex; the post-merge probe depends on the spec's** (correctness; B:275-277; spec Hook `^v\d+\.\d+\.\d+-`; B:506-508). The probe tag `v9.9.9-hookprobe` is denied only under the any-hyphen regex. Fold: quote both spec regexes verbatim in B5; a hook test feeding the exact probe command expects deny.
5. **`pgrep -f` pre-flight checks match their own wrapper** (correctness; A PF6 A:24; B pre-flight 4 B:46). Observed: `pgrep -af 'scripts/gate/gate.mjs'` returns the `bash -c` wrapper. Fold: `pgrep -f '[s]cripts/gate/gate.mjs'`, `pgrep -f '[r]elease-process-b'`; after A merges, `flock -n ~/.local/state/cairn-gate/lock true`.
6. **Neither executor prompt asks for the CI verdict per accepted head** (correctness; A-prompt:12-18; B-prompt:8-12). Fold: "Each accepted-task report names the CI verdict on that head (`ci-green <sha> --pr <n>`), or 'pending' with the run id."
7. **Nothing hands the conductor the rc.4 changes the plans introduced** (correctness; spec rc.4 steps 7-8; A seed D4; A S11; B Close "After merge"). Step 7 still reads registrations with a sourced-secret curl (A replaced it with T7's smoke info line); the rehearsal's `cairn-build` uuid has no named home; S11's `--headed` switch has no carrier; the Monitor-on-exit-file pattern (D3) is not in step 7; the conductor predates the merge, so the new allow rule may need a fresh session. Fold: an "rc.4 inputs" section in A's Close (PR body: uuid, headed or headless, smoke line to require: count 1, token-id match); the conductor's packet restates steps 7-8 with `bash scripts/gate/run-gate.sh --smoke`, the background-and-Monitor pattern, and "start a fresh conductor session after both pulls".
8. **The CI `verdict` job's sparse checkout is unguarded and its mode unspecified** (correctness; T5 A:115; B3 B:193-195, :223-225). Nothing tests that `verdict.mjs` and `record.mjs` import only `node:` built-ins; actions/checkout's single-file example sets `sparse-checkout-cone-mode: false` (cone mode is the default and treats patterns as directories); no `setup-node`. Fold: a T5 import test (`node:*` or `./record.mjs` only); B3 requires `sparse-checkout-cone-mode: false`, asserted in `workflow-yaml.test.ts`; a sha-pinned `setup-node` (node 24) in `verdict`.
9. **Five old run dirs feed `teardown left:` lines into every rehearsal run** (correctness; R1 steps 3-4 A:217-218; `gate.mjs:378`; `teardown.mjs:125-128`). `teardownStale` sweeps them on the first `--all`; under "every 7003 is a failure" they may print on every run, R1 step 4 reruns `--teardown-stale` with no stop, and their captures lack T3's `failed` marker so they are deleted. Fold: pre-flight moves them to `~/.local/state/cairn-gate/runs-archive/`; standing answer: a `teardown left:` line from a pre-pass dir is recorded, not rerun.

## Minor

10. `npm pack --pack-destination <missing dir>` fails ENOENT (probed, npm 11.20.0). R1 step 1: `mkdir -p -m 0700 ~/.local/state/cairn-gate/rehearsal` first (correctness; A:215).
11. P3's grep hits on main are `README.md:326,352` and `own-your-domain.md:7`; `own-your-domain.md:105` ("a second token that reaches every Cloudflare account and zone") matches no pattern yet must be rewritten. Correct the hits; add the phrase or name `:105-118` as a required rewrite (correctness; A:195).
12. B says the round stays at 900; it is 770 + 200 = 970. B has no per-pass line; give it A's 1,040 (correctness; B:429-430, B clock-stop row).
13. `parseRows` drops wrong-cell-count rows (`record.mjs:99`), so the rc.3 body exits 1 only as "missing rows" (vacuous), and four good rows plus one malformed row pass. `verdict.mjs` fails on any unparsable row inside `## Gate`, naming the reason; the rc.3-body test asserts it (correctness; T5).
14. P2's local HTTPS test names no certificate source; use `openssl req` into a temp dir in `beforeAll`, pass `ca` through the `pinnedProbe` seam only, assert production keeps verification (correctness; A:185).
15. `verify`'s stable branch has no tarball-path to `RULES` map (`package/...`, pins in `package/template/package.json`); state the map and test a temp copy bumped rc.4→0.99.0, or escalate it now (optional; B:239-243, :257-262).
16. R2 edits `teardown.mjs` after R1, against #349's live-run rule and ruling 10's carve-out; state that the rc.4 gate is that run (optional; A:236, :310).
17. R2's `build_trigger_uuid` check names no source file and no fallback; name it or add to S12's escalation list (correctness; A:230).
18. Nothing commits the filled "Probe readings" to initiatives main before launch; add PF7 (planning session commits; conductor checks `grep -c '<pending' <plan>` = 0) (correctness; A:26-34; A-prompt:3, :8).
19. Over-ceremony: B's launch waits on the environment/rulesets and the npm sitting, which no B task needs; move both to a pre-cut check before rc.4 step 1 (optional; B:37-42).
20. B6's `grep -c` counts lines; use `grep -o 'node scripts/release/[a-z]*' … | sort -u | wc -l` = 7 (correctness; B:349).
21. Citations: spec A15's `legs.mjs:357` is `:382`; `isActionable` is `check-consumers-must.mjs:33-39`; `makeSession` ends `gate.mjs:316` (optional).
22. `flock -n` cannot name the holder; specify lock fd 9 then write `$$`, and test with `run-gate.sh` twice, the first held by a stub `gate.mjs` (correctness; A:125, :132).
23. T1's publish `waitForURL` names no timeout; reuse `alertWaitMs` (60 s) (correctness; T1, spec A1).

## Credentials and auto mode

Each task's credential or write is covered by pre-flight or an allow rule, except the known S9 uuid
delete and S7 mailbox query fallbacks, which carry `[you]` steps.
