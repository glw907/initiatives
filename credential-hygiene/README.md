# Credential and mail hygiene

## Summary

This initiative reorganizes Geoff's Proton Pass vaults so that each vault holds one level of access, and gives every Claude session one documented way in. It also moves technical mail off Geoff's personal mailbox. A second mailbox on ward takes alerts, vendor mail, and the report aliases, and Claude reads it with a separate, scoped password. A public technical identity is published as an alias into that mailbox. Success means the personal mailbox carries personal mail only, every credential sits in the vault its readers imply, and the kids can reach the household's accounts if both parents are gone.

## Motivation

On 2026-11-03 the vaults had drifted. `Workstation` was meant to hold the age key alone and held 13 items. `Household IT` mixed server keys with personal logins, and the docs named a grant (`Servers emergency`) that Claude didn't have. Technical mail reached Geoff's personal mailbox through three addresses, and the largest stream was GitHub Actions failures. Fastmail can't close until 168 masked addresses move, and some of them belong to technical accounts.

## Goals

- Proton Pass holds the vaults in [the decisions](specs/2026-11-03-decisions.md), each item in the vault its readers imply, under one naming scheme and one note template.
- The setup is built into the workstation and every project, not left in this record (Geoff). A rule that must hold lives in a hook or a `check-drift` check, per Anthropic's Claude Code best practices. `check-drift` compares each agent's visible vaults to a committed grant map, so a forgotten temporary grant fails it. It also warns before an agent token expires, and lints item titles against the naming scheme. One vault-map doc is the reference, and the secrets registry names each secret's vault item. Each project's docs name its `Projects` folder and test accounts.
- Everything ends tidy (Geoff): no duplicate items, no logins for dead services, no stray addresses or aliases, and no doc that names a vault, grant, or address that no longer exists.
- Every agent grant matches the docs, and `list-access` is the audit.
- A technical mailbox on ward receives alerts from the technical accounts, the report aliases (`dmarc-reports@`, `tls-reports@`, `postmaster@`, `abuse@`, `security@`), and vendor mail. Claude reads it with a scoped app password.
- A public technical identity is an alias into that mailbox, and the mailbox's login name is never published.
- Every Fastmail mask is cataloged with its item and a destination: the technical identity, a Proton alias on `m.907.life`, or closing.
- Geoff and Cathy each name the kids as Proton Emergency Access contacts, and a letter with the estate documents explains it.

## Non-goals

- Proton's recovery material. It stays out of every agent's reach, and Proton's recovery address stays on the personal mailbox.
- Keeping the age store in step across hosts, which stays with `workstation-secrets`.
- The cairn release gate's test accounts and mailbox, which the cairn-cms conductor owns.
- Moving each mask at its site. Geoff does that from the catalog.

## Where the work lives

- `workstation`: `claude-pass`, `ws-pass-key`, `pass-count`, `bluefin-admin.md`, `test-accounts.md`, and `secrets/registry.md`.
- `servers`: the technical mailbox, its aliases, the app password, and the Sieve rules, with `docs/addresses.md` and the runbook.
- Proton Pass and Proton's web dashboard, which only Geoff can change for vaults, grants, and Emergency Access.

## Records

- Decisions: [specs/2026-11-03-decisions.md](specs/2026-11-03-decisions.md).
- Status and launch prompt: [plans/STATUS.md](plans/STATUS.md).

Status: active (2026-11-03), the vault layout is approved and in place; item triage is under way.

Status: active (2026-11-03), the vault work is done; the rest of the initiative is planned next in a fresh session ([plans/STATUS.md](plans/STATUS.md)).
