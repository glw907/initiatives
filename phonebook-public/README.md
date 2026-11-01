# Public phonebook

## Summary

This initiative would publish the household phonebook as a public repo that someone else can learn from and adapt. The repo would carry a README that explains the setup and what the build taught. It starts after the quiet maintenance setup for production projects is running.

## Motivation

Geoff is happy to share the work. The phonebook is not a releasable package, but the setup and its lessons could help someone building a similar system for their own phones.

A read-only check on 2026-11-01 found that the private repo isn't ready to switch to public as it stands. Its files and git history match patterns for the voip.ms account number, MAC addresses, phone numbers, `907.life` addresses, and private IPs. Those counts weren't checked for placeholders. The backlog's "Won't do" list and the design docs also describe risks accepted for a private system. gitleaks flagged 14 items, all in test files, and each still needs a check by hand.

## Goals

- A new public repo holds a scrubbed copy of the phonebook with fresh git history. The current private repo stays as the archive.
- No household details or credentials appear in the public repo's files or history. Each of the 14 gitleaks items is confirmed by hand as a test value or removed.
- Household details move into private config, so the code can still run the real system.
- The public repo's README explains the setup and passes on the lessons learned during the build, written for someone planning a similar project.

## Non-goals

- A releasable package, with versioning, support, or an install path for other households.
- Accepting outside contributions.
- Switching the existing private repo to public, which would expose its history.
- Changing how the phonebook deploys or is maintained, unless the scrub requires it.

## Where the work lives

- `phonebook`: the source of the scrubbed copy, and the home of its backlog items, tagged `#initiative:phonebook-public`.
- The new public repo, not yet named or created.

## Records

- Status: proposed (2026-11-01), follows the quiet maintenance setup for production projects.
