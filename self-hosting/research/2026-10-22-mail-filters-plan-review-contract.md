# Mail filters plan review: contract and criteria

Target: `self-hosting/plans/2026-10-22-mail-filters-plan.md` at `d9de3e5`, against `self-hosting/specs/2026-10-22-mail-filters-design.md` and `self-hosting/research/2026-10-22-mail-filters-prior-art.md`. Servers repo read at `e036a70` (read-only). No server contacted.

Verdict: not ready to approve. Two blockers, both in the seam between the runner's output and the re-filing mapping, and a cluster of majors where a design promise has no task, no fixture, or a criterion that passes vacuously.

Line numbers are plan lines unless marked "design".

## Blockers

### 1. The runner's output can't separate step 8 from step 9, so the re-filing mapping can't be applied
- Severity: blocker. Tag: correctness.
- Location: plan:74 (T2 output "the folders it would be filed into, or `keep`"), plan:78 (T4 mapping); design:98-100.
- Defect: the design's mapping treats step 8 (unknown bulk mail goes to Other, and old mail moves) differently from step 9 (a stranger's Bcc goes to Other, but old mail stays in the Inbox or Archive, or goes to Archive from any other user folder). Both verdicts are `Notifications/Other`. A runner that prints only folders can't tell them apart, so T4 has to either move every Other verdict (which pulls a stranger's personal Bcc out of Archive, the design's anti-goal) or move none (so bulk mail stays in the Inbox). The same applies to telling postmaster (step 3, Inbox) from a step-5 Inbox verdict, though those map the same way.
- Fold: T2's output line carries the matched step as well as the folder. The template marks each terminal action with its step, for example `set "mf_step" "9"` before the `fileinto`, and the runner reads that variable from sieve-rs after the run. If sieve-rs 0.7.3 doesn't expose variables, give step 9 a distinct target that the live script still files to Other (the builder picks the mechanism and records it). Add a T4 fixture pair: a step-8 message and a step-9 message, each in Archive and in a user folder. The pair fails if the step is lost, because one of the four expected actions differs.

### 2. A move plan applied after the mailbox changed can override or duplicate Geoff's own moves
- Severity: blocker. Tag: correctness.
- Location: plan:60 (`move`), plan:78 (`resort --apply`), plan:93 (T7 step 5).
- Defect: the plan is built at preview time and applied later, sometimes days later in the iteration loop. If Geoff has moved or deleted a message since, an `Email/set` that replaces `mailboxIds` silently undoes his move, and a patch (`mailboxIds/<old>: null`, `mailboxIds/<new>: true`) leaves the message in two folders. The manifest then records the planned "old folders", not the real ones, so `undo` restores the wrong state. Nothing in T3's tests covers this.
- Fold: `move` reads each message's current `mailboxIds` (`Email/get`, ids only) and applies a move only when they equal the plan's "from". Otherwise it skips the message and counts it. The manifest records what was read and what `Email/set` reports in `updated`, never the plan's values. T3 test: a fake JMAP that returns a different `mailboxIds` for one message and `notUpdated` for another. It fails if either one shows up in the manifest or if a skip isn't counted.

## Majors

### 3. Remind deletion has no data, rule, or test
- Severity: major. Tag: correctness.
- Location: plan:47 (layout has no Remind list), plan:78 (T4 counts "Remind messages to be moved to Deleted Items" but never says how they're found); design:20, 112.
- Defect: no rule handles Remind going forward, so the script never yields Deleted Items. The mapping needs its own matcher, and the plan names none. The count in the report can come out as zero with nothing failing.
- Fold: add a re-sort-only data file (for example `mail-filters/resort-delete.txt`, holding Remind's sender domains as the 2026-10-22 survey saw them), applied by T4 before the mapping. T4 fixture: a Remind message in Archive and in Inbox, each going to the Deleted Items role folder. T5 acceptance: the Remind count is within an order of magnitude of the surveyed ~250. Zero fails it.

### 4. The fifth reliability-gate report ("every message that reaches Other") is dropped
- Severity: major. Tag: correctness.
- Location: plan:9 and plan:80 (T5's summary lists four items); design:123.
- Defect: the design promises five reports. T5 lists the counts, the security hits, the personal sample, and the unknown Inbox senders, but not Other. T4 says the report "carries the design's five reliability-gate sections" but tests none of them, so the gap passes.
- Fold: T5's summary adds Other, grouped by sender domain with counts and every message listed in the local report (the full list may run to thousands). T4 test: a fixture corpus with at least one message per section, and an assertion that each of the five section headings is present and non-empty. It fails if a section is missing or comes out empty when its fixture is there.

### 5. "Personal-looking" and "misses a real code" have no definition, so the security gate can pass vacuously
- Severity: major. Tag: correctness.
- Location: plan:80 (T5 acceptance); design:123.
- Defect: the design's sample is "human sender, no list or bulk headers" that lands outside the Inbox. That has to be a test independent of the script, or the report only repeats the script's own verdict. T5's acceptance says a miss of "a real code or reset in the sample" triggers the fallback, but the sample is human mail, which never holds codes. No report surfaces misses, so "no misses seen" always passes.
- Fold: T4 defines the personal-looking predicate in the report code: no `List-*`, `Precedence`, `Auto-Submitted`, ESP stamp, or no-reply sender. Add a sixth, local-only section: "security-word subject, not pulled in", meaning messages with a word-list hit whose sender isn't on the list or that carry List-Unsubscribe. A miss can then be observed. T4 fixtures: one human message filed to a category (it must appear in the sample) and one real-looking reset from an unlisted sender (it must appear in the misses section).

### 6. The plan has Claude rule the security gate, which the design leaves to Geoff (OWNER FORK)
- Severity: major. Tag: correctness.
- Location: plan:80, plan:118; design:123 ("Geoff reads the security list and the stray personal mail").
- Defect: T5 applies the fallback before the packet, on Claude's judgment, so Geoff sees the result rather than the choice.
- Options: (a) as planned, Claude applies the fallback on any hit and says so. (b) The packet carries both previews, with the rule and with the fallback, and Geoff picks at the planned sitting. It costs one extra preview run of about 5 minutes. (c) Claude applies the fallback only on an unambiguous marketing hit, and otherwise presents both.
- Recommendation: (b). The sitting already exists, and the design gives Geoff the read.

### 7. The runner doesn't enforce ward's runtime limits, and a script error has no verdict
- Severity: major. Tag: correctness.
- Location: plan:72 (T1 acceptance measures size, string length, and nesting only), plan:74 (T2); design:88.
- Defect: the 5,000-instruction CPU limit and the 128-variable limit go unmeasured. Each message spends instructions differently, and the correspondent test grows over time. When the CPU limit is hit on ward, the script errors and the message is kept in the Inbox. The runner without the limit says "Lists/x", so preview and live disagree. "Measured and recorded" happens once, but the iteration loop and the daily timer grow the script after that.
- Fold: T2 configures the sieve-rs runtime with ward's limits, read from the same source file as the extension set, and prints an `error` verdict when a run fails. The mapping treats `error` as stay, and the report counts errors. Make the size and limit checks a standing assertion in the `sieve` leg, not a one-time record: render with a fixture correspondent list at 3x Geoff's current count, and fail on any `error` across the fixture corpus or a script over 100 KB.

### 8. The daily timer and the iteration loop skip the probe-first rule
- Severity: major. Tag: correctness.
- Location: plan:76 (timer runs `install geoff` daily), plan:82 (runbook loop: edit, preview, apply ward, re-sort); design:90 ("tested on the `probe` account first, and activated only after a probe delivery succeeds").
- Defect: after T7, every change, whether a data edit through `apply.sh` or a daily correspondent refresh, installs on Geoff's account with no probe delivery in between. T3 also sets no behavior or test for a failed `validate` or an oversized render on the timer path. The risk there is that it deactivates or half-updates the live script.
- Fold: state the rule in T3. The timer may install on `geoff` only when the rendered template and data, minus the correspondent list, match the hash last verified on `probe`. When they don't match, it logs and does nothing. A failed `validate` leaves the active script untouched and exits non-zero, so the unit shows as failed. The runbook loop says: apply, send the probe set with `probe2`, then mark the hash verified. T3 tests: a fake `validate` failure sends no `SieveScript/set`, and a changed template hash on the timer path sends no `set`.

### 9. `resort --apply` doesn't enforce the snapshot safeguard
- Severity: major. Tag: correctness.
- Location: plan:78, plan:92-93 (T7 checks the snapshot by hand); design:117, 165 (the loop re-sorts after any rule change).
- Defect: safeguard 2 holds for the first run only, because a person runs it. The loop the design promises calls `resort --apply` again and again, and nothing checks a snapshot there.
- Fold: `resort --apply` reads `restic snapshots --no-lock --json` over ssh and refuses unless the newest snapshot is newer than the plan file's preview timestamp. It also refuses a plan older than a set age (the builder picks it, 24 hours suggested). T4 test: a fake ssh that returns an older snapshot makes `--apply` exit non-zero, and no move is sent.

### 10. The T2 fixture criterion lets the builder set the expected answers
- Severity: major. Tag: correctness.
- Location: plan:74 (T2 test: "fixture messages for each of the nine steps file where the design says").
- Defect: the expected folder for each fixture isn't in the plan, so a builder whose template is wrong writes fixtures that agree with it. The named cases miss the boundaries the design spends most of its words on.
- Fold: put the fixture table in the plan, with input, expected verdict, and the rule that would break. At minimum:
  - receipt to `geoff@907.life` from a category domain with no List-Unsubscribe goes to the category (fails if the category condition is missing from step 5)
  - contact on Bcc goes to Inbox
  - stranger on Bcc goes to Other, step 9
  - contact's list post goes to `Lists/`
  - mail to `geoff-login@` or a mask from a human goes to Other or its category, not Inbox
  - security sender plus word, with List-Unsubscribe, goes to the category
  - security word from an unlisted sender is not pulled into Inbox
  - "promo code" and "confirm your subscription" from a security sender are not pulled into Inbox
  - DMARC report from google.com to `dmarc-reports@` goes to Reports, not Inbox
  - postmaster goes to Inbox
  - `List-Post: NO` is not a list
  - a List-Id containing `/` and over the length cap gives a sanitized, capped name
  - always-Inbox and never-Inbox entries each override
  - Light goes to Light

### 11. The duplicate system folders (Trash, Spam, Sent) aren't merged
- Severity: major. Tag: correctness.
- Location: no task; design:109.
- Defect: these are user folders, so the re-sort would classify Spam's one message by the script and could send it to Other. No step merges them into their role folders.
- Fold: the T4 mapping sends a message in a user folder named `Trash`, `Spam`, or `Sent` to the matching role folder before classification. One fixture each. After that, `--prune` removes them.

### 12. `folders --prune` has no tests and can delete parent folders
- Severity: major. Tag: correctness.
- Location: plan:62, plan:76 (T3's tests leave out prune), plan:93.
- Defect: `Notifications` and `Lists` hold no messages directly after the re-sort but do have children. A prune that counts only direct messages tries to destroy them. That either fails or, with `onDestroyRemoveEmails`, risks message loss.
- Fold: prune skips any folder with a role, with children, or with `totalEmails > 0`, and never sends `onDestroyRemoveEmails: true`. T3 tests cover a role folder, a parent with an empty own count, and a non-empty folder: none of them is destroyed.

### 13. "Flags and read state preserved" has no check
- Severity: major. Tag: correctness.
- Location: plan:76, plan:94; design:102.
- Fold: T3 test asserts that `move`'s `Email/set` patches touch only `mailboxIds/*` paths, never `keywords`. T7 step 6 compares unread and flagged counts in the moved set before and after, and they must match.

### 14. `undo` is never exercised on a real server before Geoff's re-sort
- Severity: major. Tag: correctness.
- Location: plan:76 (fake only), plan:88-94; design:118.
- Fold: in T7 step 2, run `resort --apply` on `probe` over the six probe messages plus one pre-moved message, then `undo probe <manifest>`, and compare `folders probe` with the before-state. It fails on any difference. This adds about 10 minutes.

### 15. Proton Pass `m.907.life` aliases aren't handled
- Severity: major. Tag: correctness.
- Location: plan:72 (T1's alias parameters), no task; design:82.
- Fold: T5 reads the corpus for `m.907.life` mail, records how Proton rewrites To and Delivered-To, and adds the domain to the sign-up alias parameter. Add a T2 fixture: an `m.907.life` alias on To from a human goes to a category or Other, not Inbox.

### 16. T7's comparison criteria have no stated tolerance
- Severity: major. Tag: correctness.
- Location: plan:93 (step 5 "match within the mail that arrived since"), plan:94 (step 6 "compare"), plan:121.
- Fold: step 5 diffs the two move plans by message id. Every id in both plans has the same destination. Ids only in the new plan arrived after the packet's preview timestamp, or else it stops. Ids only in the old plan are ones Geoff moved or deleted, counted. Step 6: for each folder, the after count equals the before count plus moves in, minus moves out, plus arrivals, with zero difference allowed apart from arrivals.

## Minors

### 17. The end-to-end list check lands in probe's mailbox, not Geoff's
- Severity: minor. Tag: correctness.
- Location: plan:91; design:5.
- Fold: send one crafted list post to `geoff@907.life` in T7 step 3. The After-merge cleanup deletes it, and `folders geoff --prune` then removes its folder. Or record the substitution under `## Decisions`.

### 18. Offline `spamtest` input and a Junk verdict in the mapping are unspecified
- Severity: minor. Tag: correctness.
- Location: plan:74 (T2 fixture "spam-scored message going to Junk"), plan:78; research:66 ("spamtest as unknown").
- Fold: T2 states that the corpus run sets spamtest to unknown, and that the spam fixture alone injects a score. The mapping treats a Junk verdict as stay.

### 19. The no-body-test rule isn't enforced
- Severity: minor. Tag: correctness.
- Location: plan:72.
- Fold: the `sieve` leg greps the rendered script for `body` and `:contents` and fails on a match.

### 20. The design's builder-verify facts have no named check
- Severity: minor. Tag: correctness.
- Location: design:86-87.
- Defect: two checks have no named step: that Sieve header tests read List-Id the way JMAP's raw form does, and that List-Post separates lists in this corpus.
- Fold: T5 records both from the corpus. T7 step 2's list post covers the Sieve side, so name it there.

### 21. T3's acceptance check passes trivially
- Severity: minor. Tag: correctness.
- Location: plan:76.
- Defect: `apply.sh ward --check` prints every role in `roles.txt` regardless of its state (`scripts/apply.sh:73-77`), so it passes as soon as the role is added to `roles.txt`.
- Fold: replace it with the role's own install test under the harness: an empty accounts file means no JMAP call.

### 22. The After-merge hash check can fail falsely
- Severity: minor. Tag: correctness.
- Location: plan:105.
- Defect: the timer re-renders with new correspondents, so the hash drifts from the branch's.
- Fold: compare against `render geoff` on ward at check time.

### 23. T6 has no acceptance criterion and leaves out probe testing
- Severity: minor. Tag: correctness.
- Location: plan:82; design:127.
- Fold: add "how to test on probe". For acceptance, the runbook names every helper verb, and `docs/decisions.md` gains the six entries.

### 24. Messages in more than one mailbox, and `:create` fallback parity
- Severity: minor. Tag: correctness.
- Location: plan:60, plan:74.
- Fold: the mapping states that a message in several folders is skipped and counted. The template's length cap stays below Stalwart's name limit, so `move` never creates a folder that ward would refuse and fall back to the Inbox for.

## Over-ceremony

### 25. T2 is `auth-data` by default
- Severity: minor. Tag: optional.
- Location: plan:68, plan:74.
- Defect: the runner reads no credential and writes nothing.
- Fold: mark it `ordinary`. That drops one diff-reviewer read, about 5 to 10 minutes and its tokens.

### 26. Six decisions entries, one per Brief fact
- Severity: minor. Tag: optional.
- Location: plan:82.
- Fold: one entry that cites the research file covers the same ground, saving about 10 minutes.

### 27. The gate leg's change-detection and caching
- Severity: minor. Tag: optional.
- Location: plan:74.
- Defect: CI runs on a fresh `ubuntu-latest` runner every time (`.github/workflows/check.yml`), so the cache helps only local runs. The leg also needs podman in CI, which the plan doesn't mention.
- Fold: keep the path filter, drop the cache requirement and the "cached time" record, and add one line confirming that podman is present in the CI runner.

## Delivered as the design asks

All nine sorting steps are present (T1 and T2). The re-filing mapping is in T4, but see findings 1, 3, and 11. Three safeguards are planned: the dry run (T5), the manifest (T3), and never destroying a message (T3's test against `destroy`). The snapshot safeguard holds only for the first run (finding 9). The iteration loop is covered by T4 and T6, but without probe-first or the snapshot guard (findings 8 and 9). Nothing in the plan exceeds the design's scope, apart from the timer, which the design allows.
