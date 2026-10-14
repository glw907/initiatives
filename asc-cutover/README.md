# ASC cutover

## Summary

The club's site is moving from the legacy site to `aksailingclub-org`. This initiative takes `aksailingclub-org` live in place of the legacy site. It is done when the apex cutover is made, MW is retired, and `aksailingclub-legacy` is archived.

## Motivation

`aksailingclub-legacy` still serves the live club site, runs the club's daily Workspace sync, and holds the club's secret store. Until the cutover, it can't be archived and a fix to the live site can't ship from the new repo.

## Goals

- Make the apex cutover, so the club's domain serves `aksailingclub-org`.
- Retire MW.
- Archive `aksailingclub-legacy`.
- Clear the named blockers first: the CSRF and Referrer-Policy defect, and the payments hardening and live smoke.

## Non-goals

- Member waivers.
- The member directory.
- QuickBooks.
- Club notifications.
- Season rollover.
- Class management.

## Where the work lives

- `aksailingclub-org`: the rebuilt site. Its ROADMAP entries #1, #10, and #11 stay deferred, and their `BACKLOG.md` lines carry `#initiative:asc-cutover`.
- `aksailingclub-legacy`: the live site until the cutover, and the repo this initiative archives.
- MW: the club's current system. It isn't a repo.

## Records

- The repo-organization pass leaves `aksailingclub-legacy` alone and keeps its archive step for this initiative (Geoff, 2026-10-14).
