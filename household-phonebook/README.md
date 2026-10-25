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

## Status

- Pass 2, the phase 1 backend, merged on 2026-10-25 (glw907/phonebook#9). The Worker is live at `phonebook.907.life`, empty, with the ward writer off until cutover. Pass 3, the web app and cutover, waits on the servers ward plan's Part B. Operator docs for the phonebook go in `servers` beside its runbook (Geoff, 2026-10-25).
- Ward probes (servers plan Part A, T2, 2026-10-25): all four pass, run by `servers-ward-probes` (`fba7a225`) on ward's probe domain. A per-user read grant reaches the sharee: its home set lists "Ward probe", a multiget returns 2 of 2, and its session lists the owner's account with contacts. A read-only member gets 403 on create, update, and delete, with ETags unchanged. The account id `stalwart-cli` gives the sharee matches the id the share used. If-None-Match on create returns 201, then 412. The "Ward probe" book is `https://mail.907.life/dav/card/probe%40probe.907.life/j9bMA3QGoc/`, empty after teardown and kept for T6. Stalwart lists a shared book in the sharee's home as well as the owner's, and the owner's path works for the sharee.

## Records

- Spec: `docs/specs/2026-10-07-phonebook-design.md` in `phonebook`.
