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
- Pass A is with `conductor-dotfiles`. It hands pass B to `conductor-servers` when it merges, and pass B's conductor starts `conductor-initiatives` for pass C when B merges.

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
