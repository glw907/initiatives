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
- Probe book reconcile (servers plan Part B, T6, 2026-10-25): ok, run by `servers-ward-address-book` (`950a6700`) at 03:03 UTC with `scripts/ward/probe-run.sh` from phonebook `origin/main` at `c2955cd`. It ended with `ward_sync` at `ok`: 6 cards expected and 6 in the "Ward probe" book, each read back with 200, then 0 left after the deletes. No 412 and no script defect, so Stalwart's parser accepts the Worker's real output.
- The household book (servers plan Part B, T5, 2026-10-25): `https://mail.907.life/dav/card/phonebook%40ward.907.life/default/`, named "Global Address Book", owned by the contacts-only `phonebook@ward.907.life` login, 0 cards. `stalwart-apply` grants it read-only to 2 members (geoff, `a-operator2`) and read the grant back on the apply and on a "nothing changed" rerun. The login's mail submission is refused 550 5.7.1 at AUTH (tested over smtps 465, since 587 admits only orpheus). RCPT answers 250 for the address while an unknown ward address gets 550, so the design's fallback stands: `docs/addresses.md` records it as accepted at RCPT. Ward runs servers branch `ward-address-book` (`1c2f09d`) until it merges.
- The servers half merged on 2026-10-26 (glw907/workstation#151, glw907/servers#22 and #23, merge `fe3a364`). Ward runs `main`, the hold is cleared, and `STALWART_PASSWORD_PHONEBOOK` is in `~/.local/secrets`, so phonebook Pass 3's cutover sitting may start. conductor-servers runs the cutover's `probe2` grant check when asked.
- The cutover's end-to-end grant check (servers plan, "At the phonebook cutover", 2026-10-26): passed. With `probe2` flipped into the household for one apply, the grant named three members; `probe2` read 187 of 187 cards in the household book, its session listed `phonebook`, and create, update, and delete each got 403 with ETags unchanged. Ward was then applied from `main`: the grant names two members, its read-back passed, and `probe2` no longer lists the book.
- Pass 3, the web app and cutover, merged on 2026-10-26 (glw907/phonebook#12, glw907/servers#24). Phase 1 is live: both phones take their config and directory from the Worker at `phonebook.907.life`, the ward writer is on, and the household book matches D1. Geoff deferred the rest of the exit checks and the old book's move to an automation and testing pass, which runs next in a fresh session, before Pass 4. The office phone has no line until Pass 4, since Geoff closed the Callcentric account.

## Records

- Spec: `docs/specs/2026-10-07-phonebook-design.md` in `phonebook`.
