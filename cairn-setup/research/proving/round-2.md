# Proving round 2

Run `2611100743` (naive), 2026-11-10 UTC, on the engine `0.99.0-dev.1` and the launcher `2.0.0-dev.2`,
cairn-cms `2822e5ebe` (round one's fixes merged). The watcher ended it at 9.8 minutes as
`stopped:cost-unknown`, about $0.36 on the subscription token, before setup created anything. All four
end-state checks failed because no site exists. The record is `run-record.md` in the run directory.

## What happened

The agent read the docs, ran the dry run, and again stopped to ask the owner to choose between running
setup in the owner's terminal and allowing unsandboxed commands. After the owner asked it to try, it ran
`npx create-cairn-site --plan` with no option before the name, outside the sandbox, and setup reported
`credential: token`: the round-one fix worked, and no Cloudflare approval was needed. The agent said it had
not set the token and asked the owner to confirm it, which the owner did. It edited the plan's zone and ran
`--apply`. Setup stopped at its Cloudflare checks because the bare address, `carin-test.org`, has DNS
records, and the agent offered three options. The owner chose a subdomain, `gate.carin-test.org`, and the
watcher ended the run before the agent answered.

## Friction the agent met

1. The agent again asked the owner which way to run setup before it tried the command. Still open as
   cairn-cms #427 (glw907/cairn-cms#218 filed it; the round-one fold merged it); the stop cost one owner turn
   this time and not two.
2. The agent hesitated at a Cloudflare token it did not set and asked the owner to confirm it. Filed as
   #431 (glw907/cairn-cms#220), for round three if it recurs.
3. Setup refused the bare address because carin-test.org's apex holds an MX and an SPF TXT. The check counts
   a record of any type, and both docs pages describe that refusal. Filed as #430 (glw907/cairn-cms#220),
   open as Geoff's call for the morning packet: keep the rule and name a subdomain on the owner card, or
   count only A, AAAA, and CNAME records.

## Flailing

- A question about the docs put to the owner: yes, the first item above.
- A command repeated after it failed: no.
- A file or page read three times: not judged yet; the grader's note for this run reads none.
- Three or more permission prompts: no. The agent met none.

## Harness items

1. The watcher stopped the run as `cost-unknown` because Claude Code's statusline did not refresh for two
   minutes while a background `--apply` kept the transcript advancing, though the transcript already priced
   the session. Fixed in glw907/workstation#218, which touches `cleanroom`'s stop code and is held for Geoff:
   the run now stops as `cost-unknown` only when the transcript has no priced turn, and the dollar and time
   caps are unchanged. Its review accepted it and noted two cheap follow-ups: clamp negative token counts in
   `usage_cost`, and unit-test `verdict()` directly. Both go to the workstation backlog with #432.
2. The probe list hard-codes `2.0.0-dev.1`, so the next probe rerun fails now that `gate` serves
   `2.0.0-dev.2`. Filed as #432 (glw907/cairn-cms#220).

## Reading against the three candidate speed fixes

No reading again: the run stopped before any deploy or HTTPS step, so the first two fixes have no data. The
agent's path to the first `--plan` took about ten tool calls, with the sandbox question as the only stop, and
the round-one docs fix removed the second stop (`--yes`). Not taken.

## Time against the last run

| Step | This run | Last run | Change |
| --- | --- | --- | --- |
| Goal prompt to the stop | 9.8 minutes (watcher stop) | 10.1 minutes (conductor ended it) | none worth reading |
| First approval | none: the token replaced it | the Cloudflare approval, unreachable | removed |
| First deploy | not reached | not reached | none |
| HTTPS wait | not reached | not reached | none |
| Goal prompt to signed in | not reached | not reached | none |

## Budget

Two naive runs of ten, about $0.58 together. The ledger is `/var/tmp/cleanroom/ledger.jsonl`.
