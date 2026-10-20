# Household phonebook

## Summary

One Worker at `phonebook.907.life` serves a shared phonebook to the household's Yealink T54W phones and a web app to the household. The work has three phases: a throwaway probe, contact sync, and phone configuration.

## Motivation

The household's phones each hold their own contacts. A single phonebook that the phones sync from, and that the household edits on the web, keeps them in step.

## Goals

- Phase 0, probe: a throwaway Worker confirms the phone's real sync behavior.
- Phase 1, contact sync: the web app, the provisioning endpoint, a two-way merge, and the cutover.
- Phase 2, phone configuration: full config files, SIP secrets from the age store, and a factory-reset test.

## Non-goals

- Remote voicemail through the voip.ms API. It needs its own design, because the API accepts only whitelisted IPs and a Worker's outbound address isn't fixed.

## Where the work lives

- `phonebook`: the Worker, the web app, and the provisioning endpoint. Its design is the 2026-10-07 phonebook spec.
- `cairn-themes`: Survey. The phonebook's UI waits on Survey S1 in `cairn-themes`.

## Records

- Spec: `docs/specs/2026-10-07-phonebook-design.md` in `phonebook`.
