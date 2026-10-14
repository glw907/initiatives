# Workstation secrets

## Summary

This proposed initiative would give Geoff a better way of tracking the age secrets across workstations (Geoff, 2026-10-14). The goal is that a secret stored on one machine is recorded, committed, and known to the other.

## Motivation

On 2026-10-13, `DRAFTER_API_KEY` was stored on pavilion through `secret-receive`. It then sat uncommitted, with no entry in `secrets/registry.md`, until workstation#69 committed it. Nothing told the thinkpad.

## Goals

- Detect a store change that isn't committed, on either machine.
- Tell the other machine when the store or the registry changes.
- Keep `secrets/registry.md` and the store in step.

## Non-goals

- Replacing age or 1Password as the store.
- Handling secrets that belong to a Cloudflare Worker. Those stay in Workers secrets.

## Where the work lives

- `workstation`: `secrets/`, `scripts/secrets/`, and the `check-drift` script.

## Records

- Evidence: workstation#69, which committed the `DRAFTER_API_KEY` entry and the store change.
