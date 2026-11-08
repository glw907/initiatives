# cairn new: pre-flight record (2026-11-08)

1. OAuth client: id `ce28682c41a8ab2de6412a80ea9d0167` in `research/cloudflare-oauth-client-id.txt`; the 32-hex check prints 1. Domain TXT on the cairn.pub apex resolves at 1.1.1.1. The client stays private.
2. Grant: `grep -c '"cairn-setup-passes' ~/.claude/settings.json` prints 2 after `claude-tooling-sync apply`; recorded by glw907/workstation#213 (merged).
3. Rulings: 12 `Ruled:` lines (packets 20261108T133837-352510, 20261108T134511-358747, 20261108T135640-373803).
4. S1: agreed; `GITHUB_TEST_*` names count 4.
5. Backlog and ROADMAP: cairn-cms `2e6283b0d` on main.
6. Conductor checks: main checkout on main, 0 behind origin, `.claude/worktrees/` ignored, no `cairn-new-*` session.
8. Probe: screenshot, held-file edit with commit and revert, `npm publish --dry-run`, and worktree cleanup ran in `cairn-cms-cairn-setup-probe`. `claude plugin validate` was refused only for a compound shell form, then ran as a plain command in `cairn-cms-cairn-setup-probe-2`. Executors run it as a plain command.
9. Planning-miss PR: glw907/standards#11, merged.
