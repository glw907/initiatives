---
kind: report
---

# Round cleanup: pass 1 has landed, pass 2 waits on your ruling

Geoff approved starting the round on 2026-11-16 (document `20261116-042624-28c2c2`). Pass 1 (`cleanup-ci`, PR #12) landed as `73bae3b`. Pass 2 (`cleanup-gate`, draft PR #13) is parked at planning: acceptance item 3, the rendered-pages leg, can't be met as written, and the pass touches a test file whose class the design and the adapter state differently. One `decide` document asks Geoff both, and passes 3 to 5 wait behind it. Nothing has deployed and the box is unchanged.
Resume from: /var/home/glw907/Projects/initiatives/dubplate-server/plans/2026-11-15-cleanup-conductor-prompt.txt

## What waits for Geoff

Decide document `20261116-080113-a56d02`: how the rendered leg is sped up and how item 3 reads (three options), and whether the rendered test file makes pass 2 `auth-data`, which decides if it lands alone. The close packet will come after pass 5's review and will hold passes 3, 4, and 5.

## What behaves differently now

Every pull request to dubplate runs `scripts/check.sh` as a check on GitHub, with all ten legs, a read-only token, and every action pinned by commit id. Two throwaway commits showed it goes red. Dependencies moved to their newest minors and patches. BACKLOG, `CLAUDE.md`, the standing rules, and the `dubplate-pass` adapter describe rounds, with 23 kept items stamped as swept.

## What went wrong

Pass 2: `[design-gap]` item 3 asked for a zero-tolerance match and a time under 130 s, and the probes show two base runs already differ in 6 of 95 files and 78 s of the leg sits before the captures. Pass 1 planning misses: one `[stale-fact]`, BACKLOG #26's identity comment item, which the code had already fixed. Flagged choices: `modernc.org/sqlite` held at v1.60.1 because v1.61 breaks a store deadline test, and two major bumps held for Geoff. The Go proof of a failing check took three tries because two breaks stopped at `gofmt`.

## What it cost

Planned: 600 path minutes across five passes. Pass 1 planned 182 and took about 80. Weekly usage: 50 percent before the first launch, 53 percent before pass 2.

## What is left for later

Filed by pass 1: the held `sqlite` bump (#129), the held TypeScript 7 and `@types/node` 26 majors (#130, #131), the held PyPI pins (#132), a timing-dependent `TestBusyTimeout` failure on the runner (#133), and stale wording in `scripts/check.sh` (#134). Round `engine` is next and has no design yet.
