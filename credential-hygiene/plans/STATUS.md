# Credential and mail hygiene: STATUS

Design: [specs/2026-11-03-remaining-work-design.md](../specs/2026-11-03-remaining-work-design.md), approved by Geoff on 2026-11-03 (Approval Queue item 20261103T202632-2969677, all three asks on the recommended choice). Decisions: [specs/2026-11-03-decisions.md](../specs/2026-11-03-decisions.md).

Plans, each reviewed by `standards:plan-reviewer` with every finding folded:

| Pass | Plan | Class | Path (ceiling) | Conductor | Executor |
|---|---|---|---|---|---|
| A, the workstation | [2026-11-03-pass-a-workstation-plan.md](2026-11-03-pass-a-workstation-plan.md) | `auth-data` | 330 (600) | `conductor-dotfiles` | `dotfiles-credential-hygiene-a` |
| B, ward's technical mailbox | [2026-11-03-pass-b-tech-mailbox-plan.md](2026-11-03-pass-b-tech-mailbox-plan.md) | `auth-data` | 445 (720) | `conductor-servers` | `servers-credential-hygiene-b` |
| C, cleanup and cross-repo edits | [2026-11-03-pass-c-cleanup-plan.md](2026-11-03-pass-c-cleanup-plan.md) | `auth-data` | 130 (240) | `conductor-initiatives` | `initiatives-credential-hygiene-c` |

Pass C's design class was `ordinary`; its plan review raised it, since two of its tasks edit `auth-data` paths in their repos. Each pass's prompt and conductor prompt sit beside its plan.

## Current state

The approval steps from the design packet, 2026-11-03:

- Done: workstation#200 merged (`34bd9eb`); initiatives#172 merged (`d454491`); the servers restore screen and registry point at `Infrastructure` (servers `ca8432f`); the operator runbook plan carries a 2026-11-03 amendment (initiatives `2cbbe82`); the backlog verdicts landed (workstation `cba4388`, servers `d89e09c`); the revoke script is written and its dry run passed; the three plans are reviewed and committed.
- Done with Geoff: the six flags were answered in chat and applied on 2026-11-03 (`open-flags.md`). The revoke is done (2026-11-04): `revoke.sh` passed Geoff's share ids and changed nothing, then `revoke2.sh`, using pavilion-claude's own share ids, ended its grants on the four personal vaults. `claude-pass vault list` shows only ASC, Age key, Infrastructure, Projects, and Test accounts. pavilion-scripts' leftover item grant in Infrastructure remains, for pass A's grant check. Geoff confirmed the second operator still shares `Infrastructure` (2026-11-04).
- Waiting on Geoff, from the packet: step 2, pull thinkpad-x1 and upgrade `pass-cli` there.
- Pass A launched 2026-11-03 by `conductor-dotfiles` (session `784b801f`): executor `dotfiles-credential-hygiene-a`, session `52e17415-bd90-492a-b58a-c14bdf7371ca`, branch `credential-hygiene-a`. Entry and Pre-flight checks passed, with one exception: `claude-pass vault list` still shows `Private`, `Cathy & Geoff`, `Family`, and `Parents`, so the revoke hasn't run. That holds only pass A's After merge 4, which waits for the revoke.
- Pass A merged 2026-11-07 as glw907/workstation#201 (`3d550ae`), with Geoff's approval (Approval Queue item 20261107T052545-2115623, "Merge now" on the hook ask). The hook's shell-word rewrite is workstation BACKLOG #51 (`755420b`).
- Pass A's After merge, run by `conductor-dotfiles`: 1, pavilion pulled; 2, `stow -R bin`, `stow -R claude`, and `claude-tooling-sync apply` all ran with no refusal; 3, `claude-tooling-sync verify` passed, and the stub proof passed (the pinned path printed `stub ok`, `permission_denials` listed only the `..` path), with the stub directory removed; 4, `check-drift` on pavilion showed "grants match the map for pavilion" and no leftover `pavilion-scripts` item row, so no revoke step is owed. The drift it found predates pass A and is outside it: four Brewfile formulas (yq, rsync, mise, baresip), the `io.github.janbar.noson` Flatpak, and `standards` (1 uncommitted file, 21 commits behind).
- Owed by Geoff, from pass A: After merge 5, pull thinkpad-x1 (`git -C ~/.dotfiles pull --ff-only && stow -d ~/.dotfiles -R bin claude`, then `ws-pass-key --status` prints `path=proton`); After merge 8, add the `token` and `recovery codes` hidden fields to "GitHub (glw907-test)" in `Test accounts` in Proton web. After merge 6 (the age key rename to "Age key (workstation)") waits on 5, and the session confirms 8's field names.
- For pass C (After merge 7): its pre-flight checks that After merge 5, 6, and 8 are done; it runs `check-drift` on thinkpad-x1 and removes `ws-pass-key`'s old age key title.
- Pass B is with `conductor-servers` (session `18fc4904-6c29-452c-8ea5-12deff862daa`, launched 2026-11-07 by `conductor-dotfiles`). It is held until servers#34 merges and deploys, since that PR edits the same Stalwart files. Pass B's conductor starts `conductor-initiatives` for pass C when B merges.

## Next action

Pass A runs under `conductor-dotfiles`, and its two stops wait on Geoff's rulings through that conductor. The revoke is done, so pass A's After merge 4 can run. Geoff still owes the thinkpad pull and `pass-cli` upgrade (packet step 2).

## Working files

Private state on pavilion, mode 700, never committed: `~/.local/state/credential-hygiene/`. It holds the triage export (metadata only), the decisions, the apply scripts and results, `lint.py`, `mask-catalog.md`, and the open flags in `open-flags.md`. Delete the exports when the initiative closes.

## Constraints that carry forward

- Claude reaches Proton Pass only through `claude-pass`. Bulk work runs as a script under Geoff's login, one sign-in.
- Secret values go to files or pipes, never the transcript or a screenshot. `Proton recovery` gets no agent grant.
- Account details stay in the private state folder, never in this repo.
- Leave the cairn gate's age-store names alone; the cairn-cms conductor owns them.
- Keep `ws-pass-key` and `sync.sh --local` working through every rename.

## Stop

Pass A, T6 registry tie-out (2026-11-03, `dotfiles-credential-hygiene-a`). The plan has T6 add each technical item's vault and title to its registry entry, from the private `notes-tech.json`. The workstation repo is public, and auto mode refused the second run of that edit as a sensitive-source copy (item titles from the private state folder into a tracked file). I reverted the registry edit; nothing landed. Waiting on `conductor-dotfiles` for one ruling: (a) the registry names the vault and the store variable only, with no item title; (b) the titles go in anyway, with Geoff's approval in the packet; or (c) the tie-out moves to a private file beside the registry. I recommend (a). All other work continues.

Pass A, T5 `settings.json` (2026-11-03). Auto mode refused three Edits to `claude/.claude/settings.json` in the worktree: the whole `permissions.allow` batch (claude-pass verbs, `pass-access`, pass B's probe rule), the same batch without the probe rule, and the `autoMode.environment` line 399 rewrite. Reasons given: `[Self-Modification]` twice and "judged dangerous" once. The planning probe on 2026-11-03 had passed this class of edit in a scratch worktree. I did not work around it. Everything else in T5 is done or proceeding. Waiting on `conductor-dotfiles`: either Geoff grants the narrow permission, or the edit moves to a `[you: apply the settings edit]` step with the exact patch in the packet.

Ruling on the T6 stop (Geoff, 2026-11-04, asked by `conductor-dotfiles`): option (a). The public registry names each technical item's vault and store variable, with no item title.

Ruling on the T5 stop (Geoff, 2026-11-04): he applies `settings-passA.patch` to `credential-hygiene-a` himself in Ptyxis. Both rulings are in the plan's "Rulings during the run". Owed by Geoff: that Ptyxis line. The executor (`52e17415`) has exited with the branch clean at `23e2e55`. `conductor-dotfiles` relaunches it once Geoff's commit lands. The revoke is done (initiatives-62, 2026-11-04), so After merge 4 is no longer held.

Update (2026-11-07, `conductor-dotfiles`): Geoff's settings commit `8664519` is on `credential-hygiene-a`. The executor `dotfiles-credential-hygiene-a` was relaunched with the same line as session `529f06d2-285c-4bb3-860c-b9d9c79b56a9`, and the exited session `52e17415` was stopped. Next: its PR-ready message, then the packet for glw907/workstation#201.

Update (2026-11-07, `conductor-dotfiles`): glw907/workstation#201 is PR-ready at `4c951ef`, and its packet is in the Approval Queue. It carries one `gate-failed` ask: two hook review rounds found 11 kinds of bypass, all folded and tested, and a third round's probes never ran because a safety classifier stopped the reviewer. The recommendation is to merge and file a backlog item for a shell-word parser. Waiting on Geoff's decision.

Update (2026-11-07, `conductor-servers`, session `18fc4904`): pass A merged as glw907/workstation#201 (`3d550ae`), and `~/.dotfiles` is on `main`, level with `origin`. Pass B's pre-flight passed. P1's rule is in `~/.claude/settings.json`. In a `dontAsk` session the stub at the pinned path ran (`STUB-ARGS: create probe`), the `..` path was denied, and the stub is removed. `STALWART_PASSWORD_TEST` and `STALWART_PASSWORD_TEST2` are in `~/.local/secrets` by name. Pass B is not launched. Entry fails on "one servers pass at a time": session `servers-af` (`83d0173b`) has glw907/servers#34 open on branch `app-passwords`, with its packet about to go out. That PR edits `roles/stalwart/build-plan`, `stalwart-apply`, and `tests/stalwart.test.sh`, the same files as pass B's T2 and T3, and its After merge deploys ward. It also fixes the app-password drop that pass B's T2 targets, so T1's readback should read `kept` and T2 shrinks to its regression test under the standing answer. Next: once #34 merges and `servers-af` reports ward deployed, re-run Entry against the new `main` and launch `servers-credential-hygiene-b`.

Pass A close (2026-11-07, `conductor-dotfiles`): the conductor has ended, with After merge 5, 6, and 8 still owed. Once Geoff reports After merge 5 done, any credential-hygiene session (pass C's conductor at the latest) runs After merge 6. It renames the `Age key` vault's age key item to "Age key (workstation)" with `claude-pass item update`, then runs `CACHE=$XDG_RUNTIME_DIR/ch-a-key ws-pass-key`, checks the file is non-empty, and removes it. On a refusal, it writes `~/.local/state/credential-hygiene/rename-held.jsonl` and gives Geoff the `pass-sitting` step, per the plan's held-rename standing answer. Once Geoff reports After merge 8 done, the same session runs `claude-pass item view` on "GitHub (glw907-test)" in `Test accounts`, through `jq` printing field names only, and checks that `token` and `recovery codes` both appear.

Update (2026-11-07, `conductor-servers`): servers#34 merged as `c85cfec` and was deployed to ward at about 18:20 UTC (`ship-pr-after-ci`; BACKLOG #60 record at `26a5209`). Entry re-ran clean against servers `26a5209` and `~/.dotfiles` at `main`. Pass B launched at 18:22 UTC from the servers main checkout: executor `servers-credential-hygiene-b`, session `12a84a8c-6a8b-424c-87e5-e707a18173ac`, branch `credential-hygiene-b` in both repos. Path ceiling 720 minutes from launch. Note for the executor's close gate: the servers gate's gitleaks leg fails in the main checkout because it scans `.claude/worktrees` copies (servers BACKLOG #61); it passes in a worktree. Next: the executor's hold line before T1's first live step, then its PR-ready message.

Update (2026-11-07, `conductor-servers`): the executor sent its hold line, "ward runs branch `credential-hygiene-b` until it merges". It is recorded as item 1i in the self-hosting STATUS. Its worktrees are cut at servers `26a5209` and workstation `755420b`, and T1 is under way with no live step yet.

Update (2026-11-07, `conductor-servers`): pass B's T1 is done, with local commits only. The Fact 3 permission list reads mailboxes, headers, and a body. It is refused a JMAP send (forbidden), an SMTP send (550), and a delete (forbidden), and it needed no extra permission. A ward apply from the branch left the probe's app password in place (`readback` reads `kept`), so T2 takes its standing answer, a regression test on #34's `KEEP.json` path. The Sieve redirect reached `probe2`, with no copy left in `probe`. A second cleanup found nothing. No probe-script call was denied. Two calls the plan didn't specify: the admin read uses JMAP `x:Account/get`, since `stalwart-cli` isn't on the workstation, and the SMTP check uses smtps on 465, since 587 is closed to the workstation (orpheus only). Both go in the servers PR's `## Decisions`.

## Stop

Pass B, T9 `settings.json` (2026-11-07, `servers-credential-hygiene-b`). Auto mode refused a session edit to `claude/.claude/settings.json` in the workstation worktree: a Python script that adds the reader's four `permissions.allow` rules (`scripts/tech-mail.sh` and its absolute forms), drops the now-spent pinned probe rule, and adds one `autoMode.environment` line naming the technical mailbox as untrusted input and `TECH_MAIL_APP_PASSWORD` as sensitive. Reason given: `[Self-Modification]`. I did not work around it. The patch is ready and passes `git apply --check`: `~/.local/state/credential-hygiene/settings-passB.patch`. Everything else in T9 is committed (CLAUDE.md Email line, `mail-tend`, registry). Waiting on `conductor-servers`: either Geoff applies the patch himself on `credential-hygiene-b` in the workstation worktree (`git -C ~/.dotfiles/.claude/worktrees/credential-hygiene-b apply ~/.local/state/credential-hygiene/settings-passB.patch`, then commit and push, as for pass A), or the packet carries it as a `[you]` step. All other work continues.

## Stop

Pass B, T9 `settings.json` (2026-11-07, `servers-credential-hygiene-b`). Auto mode refused the edit (`[Self-Modification]`). Ruling (Geoff, 2026-11-07): he applies `settings-passB.patch` to the workstation branch himself in Ptyxis, before the packet. It is recorded in the plan's "Rulings during the run". Owed by Geoff: that Ptyxis line. State at the stop: glw907/servers#35 is a draft at `2147761` (T1 to T8), and glw907/workstation#205 is a draft at `f97312e`. The executor continues T10 work that doesn't depend on the settings commit.

Update (2026-11-07, `conductor-servers`): Geoff's settings commit `da9f980` is on `origin/credential-hygiene-b` in the workstation repo, so the T9 stop is cleared. The executor reruns T9's checks and includes the commit in the whole-branch review.

After merge 8 done (2026-11-07, `conductor-dotfiles`, with Geoff's go-ahead): the item already held the token and recovery codes in visible lowercase Text fields, plus the TOTP twice as Text. The session rebuilt "GitHub (glw907-test)" from a template on stdin, with hidden "Token" and "Recovery codes" and the TOTP in the login's 2FA slot. It checked the result with booleans only and trashed the old item. The `proton-pass` skill now names custom fields in sentence case and adds secret fields through a template (workstation `d6232fd`). The doc corrections are glw907/workstation#206, sent as a packet. Still owed: After merge 5 (the thinkpad pull) and then 6 (the age key rename).
