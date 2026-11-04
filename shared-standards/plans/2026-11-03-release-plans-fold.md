# Fold record: release plans A and B, three-lens review

Fold agent (standards:spec-plan-review "The fold"), 2026-11-03. Inputs: the three review files
beside this record (mechanics, contract, integrity), plans A and B with their prompts at
initiatives `ed6fd0c`, the spec at `d880b9e` (not edited), and cairn-cms `main` `bb3c8d3a2` (read
only). Each finding was checked against the code or a probe before it was folded. Every `optional`
finding is dropped. Convergent findings fold once, at the root, and the others point there.

Counts: 71 findings. 61 folded, 2 refused, 8 dropped as optional. No owner fork remains: the
planning session ruled the four filed forks (below), each with one answer inside what Geoff
approved.

## Rulings applied (planning session, 2026-11-03)

1. **Contract 1, the escalation list.** Plan B returns to the spec's standing answers, which name
   three escalatable items, all pass A's. Nothing in pass B escalates. B7 and B8's "not
   reproduced" is a recorded result, not an escalation. Folded: plan B "Escalation" paragraph,
   Spend row, P-WT row, B7 acceptance, B prompt.
2. **Contract 9, the grant scope.** The pre-flight grant matches
   `~/.local/state/cairn-agent-first/apply-release-process-grant.sh`: the pass worktree
   `.claude/worktrees/release-process-b` only, never an `agent-*` pair worktree, plus the one
   dotfiles file for B8. Pair subagents never write `.claude/`; they hand the content back and the
   executor applies it in the pass worktree (about 10 minutes). Folded: plan B pre-flight item 1,
   "Permissions checked", "Handback" under "First act", B5 to B7 Files, the refused-write row, the
   path's tail, B prompt.
3. **Mechanics 3, STATUS and BACKLOG after `rc.4`.** Option (a), by ruling 17's own principle:
   `check-stable-source` ignores the inert unshipped paths `docs/STATUS.md`, `BACKLOG.md`,
   `ROADMAP.md`, and `docs/internal/**`. `.github/**`, `scripts/build/**`, and `package.json` stay
   checked. `check-stable-source.test.ts:123` flips. Verified: the root `files` list ships
   `docs/admin`, `docs/editors`, `docs/why-cairn.md`, and `docs/architecture.md`, none of the four.
   Folded: plan B B1. Owed erratum E2.
4. **Integrity I8, the first live `publish.yml` run on a permanent tag.** No dry-run input. (i) The
   `release-tags` ruleset leaves pre-flight and is posted right after `rc.4`'s publish run
   succeeds, before the gate and promotion; the `main` ruleset stays at pre-flight. A workflow
   defect found before any package publishes is fixed on `main`, and the unpublished release and
   tag are deleted (`gh release delete v0.99.0-rc.4 --cleanup-tag --yes`; `gh release delete
   --help`: "--cleanup-tag Delete the specified tag in addition to its release") and recut. (ii) B3
   adds pinned actionlint over the workflows to its test. Folded: plan B pre-flight item 2, B3, the
   `rc.4` run sheet steps 6 and 6a, B9's brief line. This departs from the spec's pre-flight step 4
   timing: owed erratum E1, named for the packet's brief.

## New mechanisms, each probed or quoted

- **Hook fails closed** (B5). code.claude.com/docs/en/hooks, read 2026-11-03: "Exit code 1 without
  valid JSON output is a non-blocking error unless the hook is one whose failure blocks the action
  ... If your hook is meant to enforce a policy, use `exit 2`"; `onFailure`: "Whether the action
  that triggered the hook goes ahead when the hook fails: `"continue"` or `"block"`", requiring
  Claude Code v2.1.295 or later (`claude --version` here: 2.1.318); `if`: "The hook command only
  runs if the tool call matches the pattern", with "Because the `if` filter is best-effort, use the
  permission system rather than a hook to enforce a hard allow or deny."
- **`-p` short flag** (B5). `gh release create --help`: "-p, --prerelease Mark the release as a
  prerelease".
- **Sparse checkout** (B3). actions/checkout README: `sparse-checkout-cone-mode` "Default: true";
  its single-file example sets `sparse-checkout-cone-mode: false`.
- **`filter=latest`** (B3). GitHub REST reference, list check runs for a Git reference: "latest
  returns the most recent check runs", default `latest`.
- **actionlint** (B3). `go run github.com/rhysd/actionlint/cmd/actionlint@v1.7.12` (latest release
  tag v1.7.12) at cairn-cms `main`: builds in about 5 s, `publish.yml` alone exits 0, the full set
  fails on one finding, `create-site.yml:230` SC2034. The npm package `actionlint` is a third-party
  wasm wrapper (maintainer `hops-release`), so it is not used. The Ubuntu 24.04 runner readme lists
  Go only under cached tools (1.24 to 1.26) and shellcheck 0.9.0, so `test.yml` gains a sha-pinned
  `actions/setup-go` step, as `tool.yml:67-76` already uses.
- **Lock held by children** (T6). `flock --help` lists no option that reports a holder. Local
  probe: a script holding `flock -n 9` and starting a `setsid` child, killed with `SIGKILL`; without
  `9>&-` the child kept the lock, with it the lock was free at once.
- **npx and a re-packed tarball** (I4). Local probe, npm 11.20.0: two different tarballs packed in
  turn to one path at one version each printed their own marker through `npx --yes file:<path>`.
- **Registration bearer** (T7). `gate.mjs:171,245-253` at `main`: the smoke registers through
  `makeApi` on the gate token; the PF2 script registers with `CF_WS_CAIRN_GATE_TOKEN`.

## Dispositions: mechanics (standards:plan-reviewer)

| # | Sev | Disposition | Where |
|---|---|---|---|
| 1 | blocker | Folded outside the plans: the planning session rewrote `preflight-token-probes.py` (two PS registrations, field names only, `finally` cleanup and prefix sweep, `tmp-token-setup` kept on failure, final read lines). The plan now points at its exact lines. | A PF2, PF6, "Probe readings" |
| 2 | major | Folded. Verified `record.mjs:146-147` refuses an empty body. | A T6 acceptance |
| 3 | major, fork | Folded per ruling 3. | B B1 |
| 4 | major | Folded: both spec regexes verbatim, the probe command as a test case. | B B5 |
| 5 | major | Folded: `pgrep -f '[s]cripts/gate/gate.mjs'`, `pgrep -f '[r]elease-process-b'`. | A PF6, B pre-flight 4 |
| 6 | major | Folded. | A "Rules for every task", B "First act", both prompts |
| 7 | major | Folded at the root with contract 7. | A Close step 8 `## rc.4 inputs`; B "After merge: the rc.4 run sheet" |
| 8 | major | Folded with contract 6: T5 import test; cone mode false and a pinned `setup-node` in `verdict`. | A T5, B B3 |
| 9 | major | Folded as PF7: `--teardown-stale` from main, then archive. Verified run dir `20261103T164910` still holds two state records, so archiving alone would orphan live resources; teardown goes first. | A PF7 |
| 10 | minor | Folded. | A R1 step 1 |
| 11 | minor | Folded; `:105` phrase added to the grep, corrected hits verified (`README.md:326,352`, `own-your-domain.md:7`). | A P3 |
| 12 | minor | Folded: round path recomputed; pass B's line is 1,035. | B Path, Spend, Clock stop |
| 13 | minor | Folded. Verified `record.mjs:99` drops wrong-cell rows. | A T5 |
| 14 | minor | Folded. | A P2 |
| 15 | minor, optional | Dropped. | |
| 16 | minor, optional | Dropped (contract 8 carries the correctness half). | |
| 17 | minor | Folded: source is `listBuildsForWorker` (`api.mjs:633`) through T7's log; "absent" leaves #336's residue open. | A T7, R2 |
| 18 | minor | Folded as PF8. | A PF8 |
| 19 | minor, optional | Dropped. | |
| 20 | minor | Folded with contract 15. | B B6 |
| 21 | minor, optional | Dropped. | |
| 22 | minor | Folded with integrity I6. | A T6 |
| 23 | minor | Folded. Verified `alertWaitMs = 60_000` at `browser.mjs:358`. | A T1 |

## Dispositions: contract and criteria

| # | Sev | Disposition | Where |
|---|---|---|---|
| 1 | major, fork | Folded per ruling 1. | B "Escalation", Spend, P-WT row, B7 |
| 2 | major | Folded with integrity I7: `onFailure: "block"`, a deny on any internal error, `if` filter, passing stable gets no decision. | B B5 |
| 3 | major | Folded: `ci-green`'s script and `build`'s ref check run under stubs. | B B3 |
| 4 | major | Folded. | A T6 |
| 5 | major | Folded: one log line per Builds leg, a visible failure line, exactly one uuid each in the deciding run. | A T7, R1 step 5, B run sheet step 7 |
| 6 | major | Folded at mechanics 8, plus the run from a temp dir holding only the two files. | A T5 |
| 7 | major | Folded at the root: the `rc.4` run sheet maps steps 0 to 9 to their checks, the End-to-end bullets, the CI and Promotion standing answers, and the `--all` rerun rule. | B run sheet |
| 8 | major | Folded: R2 lands before the deciding run, with one group A rerun (55 min) when the first `--all` already passed; S5 covers later teardown, `evaluateLeg`, and prompt-table changes; floor (c) in the run sheet. | A R2, R1 step 4, S5, D5; B run sheet step 7 |
| 9 | major, fork | Folded per ruling 2. | B pre-flight 1, "Handback" |
| 10 | major | Folded: `--tag`, defaulting to `gate` for a prerelease. | B B4 |
| 11 | major | Folded: positive greps. | A P3 |
| 12 | major | Folded. | A T1 |
| 13 | minor | Folded. | A T1 |
| 14 | minor | Folded. | A T1 |
| 15 | minor | Folded: a distinct-name count with `grep -o`, `sort -u`, and `wc -l`, and pass A's flags checked on merged `main`. | B B6, run sheet step 0 |
| 16 | minor | Folded: `cairn-cms-dev`'s rc.2 and rc.3 tarballs (30 files, 129,632 bytes unpacked) as fixtures through an injected fetch. | B B4 |
| 17 | minor | Folded. | B B5 |
| 18 | minor | Folded. | B B5 |
| 19 | minor | Folded: `git ls-remote origin refs/heads/main`. | B B2 |
| 20 | minor | Folded. | B B2 |
| 21 | minor, optional | Dropped. | |
| 22 | minor, optional | Dropped. | |
| 23 | minor | Folded. | A R1 step 5 |

## Dispositions: data integrity and failure risk

| # | Sev | Disposition | Where |
|---|---|---|---|
| I1 | blocker | Folded outside the plans (probe script, as mechanics 1). | A PF2, "Probe readings" |
| I2 | major | Folded outside the plans: `call` returns status 0 on `OSError` and `ValueError`; `finally` deletes what the run made and sweeps the prefix; `tmp-token-setup` and its scratch files are kept on failure and removed on success. | A PF2 |
| I3 | major | Folded. | A T4 |
| I4 | major | Refused: probed, npx ran the new tarball at the same path and version (npm 11.20.0), so the rename buys nothing. | A R1 step 1 records the probe |
| I5 | major | Folded: a `--leg` run calls `teardownStale` as `--all` does (`gate.mjs:378`), with a test; PF7 clears the pre-pass dirs. | A T6, R1 step 4, PF7 |
| I6 | major | Folded: holder file, `9>&-` on every child (probed), `timeout 20m` on the trap's teardown, Monitor ends on `exit` or a free lock. | A T6, R1 step 3, S14, D7 |
| I7 | major | Folded at contract 2, plus malformed stdin and `\s+` matching. | B B5 |
| I8 | major, fork | Folded per ruling 4. | B pre-flight 2, B3, run sheet 6 and 6a |
| I9 | minor | Folded. | A T7 |
| I10 | minor | Folded: probe-prefix count in the info line, required 0. | A T7, R1 step 5, B run sheet step 7 |
| I11 | minor | Folded outside the plans: the final read prints both prefixes and `unknown` when the list fails. | A PF6 |
| I12 | minor | Folded into S9's text, with no new script. | A S9 |
| I13 | minor | Folded: commands go to the conductor by message, secrets as `$NAME`. | A rules, S7, "Permissions checked", A prompt |
| I14 | minor, optional | Dropped. | |
| I15 | minor | Folded in part: T1's thrown text is host, path, and at most 200 characters. The record-cell scrub is refused: the spec puts failure-text scrubbing in "Later" (M12), and the truncation bounds the exposure. | A T1 |
| I16 | minor | Folded: R2's dispatch names only the controls and `driver.log` files; the retention rule is a drafted backlog item. | A R2, Close step 6 |
| I17 | minor | Folded: `runs.txt`. | A R1 steps 2 to 5, A prompt |
| I18 | minor | Refused: a typo writes `pending` rows, never a pass, to a release that is never promoted, and every R1 command is written with `--cli`. | |
| I19 | minor | Folded. | A rules |
| I20 | minor | Folded in part: plan B pre-flight 1 requires a clean, pushed `~/.dotfiles` before the grant runs. The script's EXIT trap and rerun guard are not folded: the script is outside this fold's write scope (owed to the planning session). | B pre-flight 1 |
| I21 | minor, optional | Dropped. | |
| I22 | minor | Folded. | B B2 |
| I23 | minor | Folded. | B B3 |
| I24 | minor | Folded. | B B6, run sheet step 7 |
| I25 | minor, optional | Folded outside the plans: the script prints field names and non-secret changed fields only. | |

## Owed spec errata (the spec is not edited)

- **E1** (ruling 4). Spec "Your steps" 4 posts the `release-tags` ruleset at pre-flight, and "The
  rc.4 sequence" step 4 says "the tag ruleset makes a tag on a red commit permanent". The plans
  post it at `rc.4` step 6a, after the publish run succeeds and before the gate and promotion, so
  a pre-publish workflow defect is recut, not burned. The packet's brief names this departure.
- **E2** (ruling 3). Spec "Checks", `check-stable-source.mjs` bullet: the ignore set adds
  `docs/STATUS.md`, `BACKLOG.md`, `ROADMAP.md`, and `docs/internal/**`.
- **E3** (ruling 2). Spec "Your steps" 5 names "pass B's worktree"; the grant also covers the one
  dotfiles file for B8, because the dotfiles rule clears a skill edit only on approval in the
  current session.
- **E4** (ruling 4 (ii)). Spec "Pass B", Files: `.github/workflows/test.yml` (a pinned
  `setup-go` step) and `.github/workflows/create-site.yml` (the SC2034 rename) join for actionlint.
- **E5** (contract 2). Spec "Claude infra", Hook tests: "a passing stable is allowed" becomes "gets
  no decision", and the entry carries `onFailure: "block"` and `if`.
- **E6** (mechanics 7, contract 7). Spec "The rc.4 sequence" step 7 reads registrations with a
  sourced-secret `curl`; the plans read them through `run-gate.sh --smoke`'s info line (plan A
  seed D4), and a candidate's gate failure reruns `--all`.
- **E7** (path). Spec "Estimate" and the Brief ("about 900 minutes"): the round's path is now
  1,105.

## Path figures

| Unit | Drafted | Folded |
|---|---|---|
| Pass A | 770 | 900 |
| Pass B (beside A) | 555 | 610 |
| `rc.4` | 200 | 205 (step 6a) |
| **Round** (A + `rc.4`) | 970 | **1,105** |

The ceiling is 1,240 path minutes (ruling 13), so the margin is 135. Each pass's own line is
1,035 (1,240 less `rc.4`'s 205). Pass A's fold adds 130: named tests on T1, T4 to T7, P2, P3, and
R1, the lock's holder file and fd rule, and R2's live group A rerun (55). Pass B's adds 55: the
widened ignore set, `ci-green`'s executable tests and actionlint, `verify`'s tag and tarball
cases, the hook's fail-closed cases, and the handback applies (10).

## Not folded

- Integrity I20's EXIT trap and rerun guard in `apply-release-process-grant.sh`: outside this
  fold's write scope. Owed to the planning session before the sitting.
- Integrity I15's record-cell scrub and I18's guard: refused above.
