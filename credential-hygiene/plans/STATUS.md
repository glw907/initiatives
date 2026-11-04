# Credential and mail hygiene: STATUS

Design: [specs/2026-11-03-decisions.md](../specs/2026-11-03-decisions.md). No plan yet; the next session writes it.

## Current state

The vault work is done (2026-11-03). Every vault in the decisions exists with its grants. Geoff triaged every item in one review, and two scripts under his login applied it. Afterwards each vault matched the plan. The technical items carry template notes, and the naming lint is clean apart from two titles held for the infrastructure PR. The public identity is decided and recorded.

1Password is reconciled from a metadata listing. Its logins all have a Proton Pass copy or were trashed by Geoff's choice. The Fastmail masks with no vault item are decided: most are disabled, and the ones for live accounts are on the move list.

workstation#200 (`age-key-vault`) holds the `Age key` vault change and the doc updates for the new layout, with its gate passed. initiatives#172 holds this record. Neither has gone to Geoff as a packet yet.

## Next action

A fresh planning session for the rest of the initiative. Launch prompt:

> Plan the rest of the credential-hygiene initiative. Read `~/Projects/initiatives/credential-hygiene/` (README, the decisions spec, and plans/STATUS.md) first. The vault work is done. Plan the remaining work below as passes through `pass-core`, one approval for the set. Send workstation#200 and initiatives#172 to Geoff through `approval-packet` before or with the plan, since the infrastructure PR builds on #200. Account-level detail (open flags, the mask catalog) is in the private state folder this STATUS names, never in a committed file.

## Remaining work

1. **Workstation infrastructure PR**, after #200 merges:
   - A `proton-pass` skill with the vault map, the naming scheme and note template, `claude-pass` use, and the sign-in throttle.
   - A committed grant map with each agent token's expiry. `check-drift` compares it to `list-access`, warns before a token expires, and runs the title lint.
   - A `pass-sitting` helper for bulk work under Geoff's login, generalizing the apply scripts.
   - The `claude-block-pass` pattern 4 false positives.
   - Renames of the two held items, in step with `ws-pass-key`, its test, `test-accounts.md`, and the registry, and the test account's remaining note fields.
   - A CLAUDE.md pointer to the skill, the `bluefin-admin.md` Secrets rework, and registry entries that name their vault items.
   - Stale vault names in `servers/docs/runbook.md`, and the ASC repos' docs that still point to 1Password for their age key.
2. **Servers mailbox pass**: the technical mailbox on ward, the public identity and the role aliases into it, a scoped app password for Claude, Sieve rules for alert subjects, and a provider-side checklist for Geoff. Commits move to GitHub's noreply address.
3. **Cleanup**:
   - Revoke the temporary grants Claude holds on the personal vaults, and a leftover scripts-agent item grant. Geoff runs the revoke; Claude verifies with `list-access`.
   - One folder per project in `Projects`.
   - The open flags in the private state folder.
   - thinkpad-x1: the pass-cli upgrade and a pull once #200 merges.
4. **Geoff's tasks**: Proton Emergency Access and the estate letter, moving each mask at its site from the catalog, and closing 1Password when he chooses.

## Working files

Private state on pavilion, mode 700, never committed: `~/.local/state/credential-hygiene/`. It holds the triage export (metadata only), the decisions, the apply scripts and results, `lint.py`, `mask-catalog.md`, and the open flags in `open-flags.md`. Delete the exports when the initiative closes.

## Constraints that carry forward

- Claude reaches Proton Pass only through `claude-pass`. Bulk work runs as a script under Geoff's login, one sign-in.
- Secret values go to files or pipes, never the transcript or a screenshot. `Proton recovery` gets no agent grant.
- Account details stay in the private state folder, never in this repo.
- Leave the cairn gate's age-store names alone; the cairn-cms conductor owns them.
- Keep `ws-pass-key` and `sync.sh --local` working through every rename.
