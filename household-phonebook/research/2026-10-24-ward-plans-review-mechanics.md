# Mechanics and feasibility review: the ward plans

Targets: P, `phonebook` `docs/plans/2026-10-07-phonebook-phases-0-2.md` at `5005006` (branch
`ward-plan`); S, `household-phonebook/plans/2026-10-24-ward-servers-plan.md` at `f441968`.
Reviewer: `plan-reviewer`, 2026-10-24. Saved by the planning session from the agent's reply.
Cross-repo order holds (Part A before Pass 2, Pass 2 before Part B, Part B before the cutover),
and the design's "Owed to the plan" list is fully answered.

## Blocker

**B1** (correctness; P:1121-1124 Task 2.11, P:1057 the fake). A depth-1 PROPFIND returns the
collection's own href (RFC 4918), and the owner may DELETE a collection (`card/delete.rs:76-99`).
A reconcile that deletes every href D1 lacks deletes the whole book; a fake without the self
response passes. Fold: `planReconcile` keeps only child hrefs directly under `WARD_BOOK_URL`
ending in `.vcf`, after percent-decoding; the client refuses a DELETE whose URL equals the book
URL; the fake's PROPFIND includes the self response, with a unit case that it is ignored;
`move-book.ts copy` (P:1479) takes the same rule.

## Major

- **M1** (P:1044-1046, P:1305, probe fold P:604-620). The phones send the group as `Blocklist`
  (`pass-1-probe:docs/research/2026-10-24-probe-recovery-notes.md:66-67`). Fold: key Task 2.9's
  predicate and Task 3.2's refusals on `Blocklist` now; add both to the probe fold's list.
- **M2** (P:604-620, P:57). The probe fold's ward items exist only on `ward-plan`; Pass 1 reads its
  copy under `docs/superpowers/plans/`. Fold: `ward-plan` merges to `main` first, the probe branch
  is reconciled onto it, and the fold agent runs on `main`'s plan.
- **M3** (P:1499-1502). Cutover step 1 deploys with no remote migration of `0002`. Fold: apply
  migrations remotely, then deploy.
- **M4** (P:1155-1157, S:296-300). `probe-run.sh` in a fresh worktree has no build for
  `wrangler dev`. Fold: `npx svelte-kit sync && npx vite build` first, apply migrations, run with
  `--persist-to "$(mktemp -d)"` so stale local D1 can't join the cutover reconcile.
- **M5** (P:1486, P:1541). The owner path is `/dav/card/geoff%40907.life/` (backup `global.xml`,
  pavilion's GOA `CardDavUri`). Fold: that prefix, compared after decoding; record the known href
  and have `list` confirm it; a test with the `%40` form.
- **M6** (P:1085-1087, P:1116-1120, P:751-752). The stop hashes `WARD_PASSWORD` only; a mistyped
  `WARD_USER` holds it 24 hours. Fold: hash `WARD_USER + ":" + WARD_PASSWORD`, unit case.
- **M7** (S:256-259, S:267). `AddressBook/get` returns all four rights per sharee
  (`crates/jmap/src/api/acl.rs:188-201`, `jmap-proto/src/object/addressbook.rs:304-309`). Fold:
  "`mayRead` true and every other right false"; the fake returns the four-key shape.
- **M8** (P:1493-1557). No standing answers for the cutover's ward steps (step 5 412, step 6 not
  `ok` or compare differs, a 401 stop at step 6, step 7's `probe2` check, step 9's ward checks,
  step 11's count). Fold: a table; step 10's delete only after steps 6, 7, and 9 pass; if the ward
  bar is out of reach, unset the three secrets, finish the phone cutover, skip 10 and 11, report.
  Pass 3 pre-steps read T6's result.
- **M9** (P:1525-1527, P:1536-1538). EDS refreshes every 60 minutes by default
  (`e-source-refresh.c`, `interval-minutes` 60). Fold: prove the 15-minute bound server side;
  check GNOME after a manual refresh; name the by-URL fallback (a second GOA WebDAV account over
  D-Bus with the password from the store, as `cutover-log.md` did).
- **M10** (privacy). The design names the second operator in the public repo; squash or rewrite
  before the push and run the privacy check over the branch history.

## Minor

1. (P:44-49) Ceilings sit below their basis: Pass 2 9.8 to 10.6M against 9.5M, Pass 3 7.6 to 8.4M
   against 7.5M. Raise to 10.5M and 8.5M.
2. (S:249-251) `ensure_household_book` names no report for zero books (`gcache.rs:333` creates a
   default only when `default_addressbook_name` is set). Fail on zero or create it.
3. (S:123-127, S:153) Probe 1's `grep -c` needs a unique `example.com` email on the first card.
4. (P:1182) Restrict `probe-run.sh` to `/dav/card/probe%40probe.907.life/`.
5. (P:1511-1513, P:1523-1524) Write cutover step 5's `probe-run.sh` and step 6's `check-book.ts
   compare` with every flag; name step 6's wait for the cron tick.
6. (P:1536-1538) Name the target book for "a write from GNOME Contacts gets an error".
7. (P:616-618) The one-way list misses step 9's handset check and Task 3.5's restore procedure.
8. (P:1151, :1158, :1455) Name the runner for the `.ts` scripts (Node 24 strips types only with
   relative `.ts` imports and no `$lib`).
9. (P:277-278) Settle at pre-flight whether thinkpad-x1 has a GOA account.
10. (optional) Pair Task 3.6 with 3.1.
11. (optional) The `vale sync` step changes nothing: v1.3.0's overlay is byte-identical.
12. (optional) T1 is nearer 45 minutes.
13. (optional) Also disable the file permission families on the Worker's credential.
14. (optional) Run the `probe2` flip after step 12.
15. (optional) Task 3.7's files should list `test/helpers/fake-carddav.ts`.
16. (optional) CLAUDE.md's pass-class line omits the ward writer.
17. (optional) `docs/STATUS.md` still says Pass 3 waits on Survey S1.
18. (optional) Say where `WARD_*` joins `Env`.
19. (optional) The push lacks the reconcile's first-timeout rule.

## Owner fork as raised

**F1** (S:18-26, :164-168, :376). Two packets for Parts A and B, or Part B stacked on
`ward-probes` with one packet. Recommendation: one packet. (The planning session takes the
recommendation as the clearly correct answer; see the fold record.)

## Verified as stated

The 90 permission names, `permissions`/`Merge`/`disabledPermissions`; the Cloudflare quotes
(`/cdn-cgi/local/scheduled`, `CLOUDFLARE_INCLUDE_PROCESS_ENV`, `secrets.required`, `waitUntil`,
`createScheduledController`); the Stalwart citations; the Survey line numbers, tag `21194176`,
the release asset, the Fontsource packages, the specimen at `c19e7ac`; the four Stalwart secrets
in the store; `apply.sh` rendering and `stalwart-apply`'s three exits; the path arithmetic.
