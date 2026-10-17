# Thinkpad checks (T1)

Host thinkpad-x1, 2026-10-14 to 2026-10-17. Tools ran from `initiatives` at `d85b27f`.

## Results

| Check | Result |
|---|---|
| 1 refs | FAIL: 0 broken (baseline had 20), 7 live-tie hits on `ROADMAP.md` |
| 2 session start | ok |
| 3 queue | ok |
| 4 realpaths | FAIL: `~/.dotfiles` dirty, Geoff's restored `bash/.bashrc` edit; the `docs-page-chain.js` and `cairn-docs-outline` realpaths are under `~/Projects/drafter` |
| 5 retirement | ok after the two refused directories were archived and removed |
| 6 roadmap and descriptions | FAIL: see Found, not done |

## Steps

- Step 0: cloned `approval-queue`. The approved dry-run blob at `37ebb4e` hashes to the logged `doc_sha256` (`63f771e8...`). `aksailingclub-legacy` is present on this machine.
- Step 1: baseline recorded before any pull.
- Step 2: `thinkpad-cleanup` removed `displaywidth`, `personal-styles`, `healthy-diet`, `pings`, and `ecxc-ski-agent-memory`. It refused `aksailingclub-sveltekit` and `cairn-scratch` (found 7794 and 19222 files against 1153 and 158 expected). Geoff ruled on 2026-10-14 to archive both into the thinkpad tar under R0's rules and remove them. The refusal came from the file count: leaving out `node_modules`, `.git`, and `.svelte-kit`, they hold 1151 files (1153 expected) and 158 (158 expected). The tar (`retired-repos-2026-10-14-thinkpad-x1.tar`, no-clobber, `tar -d` clean, then `sync`) holds 9422 and 20645 members, matching `find` just before. Both directories were then removed.
- Step 3: `batched-docs-tool-initiative.md` was absent: recorded as lost, no fold into `docs-system/README.md`. Its `MEMORY.md` index line is removed, and the count is 0.
- Step 4: `secrets/` was clean. Pulls fast-forwarded in 12 repos (after Geoff set aside his uncommitted `bash/.bashrc` edit for `~/.dotfiles`). `cairn-themes` (ahead 26, behind 3) and `phonebook` (on `pass-1-probe`, no upstream) are stale and untouched. The restow and the drafter and approval-queue installs ran outside this session (the links are dated 2026-10-14 22:13); I verified the three realpaths. `secret-set.sh --sync` regenerated `~/.local/secrets` (48 secrets).
- Step 5: stopped the demo server on port 7907 (Geoff approved) and removed `~/.dotfiles/approval-queue/`. `refs apply` over the memory directories found no memory file to rewrite, so no tar was written. The tool needs `--root ~/.claude/projects` here.
- Step 6: `e2e-check --host thinkpad-x1`, output above.

## Tool output

```
e2e-check d85b27f81a1a3389173f2b410acee2b07dab93f4
FAIL 1 refs: refs check exit 1, 7 new broken or live-tie path(s)
ok   2 session-start: drafter, ~/.dotfiles, and a worktree print their records
ok   3 queue: item served by the build under approval-queue, then withdrawn
FAIL 4 realpaths: ~/.dotfiles is dirty
ok   5 retirement: 11 cloudflare ids and 5 repos gone, no retired directory
FAIL 6 roadmap-descriptions: aksailingclub-org: no approved description in the manifest; cairn-themes: local ROADMAP.md exists; cairn-themes: no approved description in the manifest; dubplate: no approved description in the manifest; ecxc-ski: no approved description in the manifest; phonebook: local ROADMAP.md exists; xcathletes-org: no approved description in the manifest
```
