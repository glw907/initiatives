# Setup tooling pass 3 at the budget stop

Pass 3 runs the polish loop: a naive agent sets up a cairn site in the clean room, and each round fixes what it trips on. Overnight it ran six naive runs, merged eleven round PRs, and published four test builds to `gate` only. The loop stops at ten naive runs or $100, and the plan sends that stop to you. Round seven was refused at $100.69.

The $100 is a list-price estimate, and almost none of it is the clean room. Six naive runs cost $1.88 and the ledger about $9.90. The executor's session counts too, at $98.35. Both the executor and the clean room run on your subscription, so no dollars were spent. The session recommends counting only the clean room against the $100 and keeping the ten-run cap, which leaves four runs.

Two product calls are also open. Setup refuses an apex that holds only mail records, and the session recommends counting only A, AAAA, and CNAME. It recommends leaving the sandbox exclusion narrow, since `cairn new` now stops in a sandbox with one line to fix. Approving merges the STATUS PR. The session then lands your rulings and runs round seven, the first to test the subdomain fix.

## If you approve
1. [session] Merge glw907/cairn-cms#226 once its CI is green.
2. [session] Apply the budget ruling in `scripts/gate/run-gate.sh` through a reviewed round PR, then run round seven.
3. [session] Build the apex ruling as a round fix with its tests and docs, or keep the rule.

## Not checked
Three fixes have unit tests but no live run yet: the stand-in's install button, the sandbox stop, and the subdomain opening check. Round seven is the first to exercise them.

## Ask: How should the $100 budget line count spend?
Rule: owner-call
Part: none
Recommended: 1
Reason: The clean room's spend is $9.90 of $100, and neither session costs real money on your subscription.
Summary: The stop counts the executor's session at $98.35 list price. The clean room spent $9.90, $1.88 of it on naive runs.

Background: The plan prices every ledger row plus the executor's transcript with `cleanroom cost`, and refuses a run below a $5 remainder. S-3 was reversed at the sitting, so the clean room uses a subscription token, not a funded API key.

Facts: The executor's transcript is nearly the whole $100.
- The refusal reads "$100.69 spent leaves $-0.69 of $100, under the $5 floor" (`scripts/gate/run-gate.sh:189`)
- The plan counts "`cleanroom cost` of the executor's transcript" (`plans/2026-11-09-setup-tooling-plan.md:704`)
- S-3 reversed: the Console org held $1.13 (`research/2026-11-09-conductor-end-packet-notes.md:30`)
- Six naive runs cost $1.88 (`research/proving/round-6.md`)

Choices:
- Count the clean room only: keep $100 and ten runs; four runs remain
- Raise the line to $200, counting both: about one more night of rounds
- End the loop here: go on to the scripted leg, the dependency sweep, and the runbook with what is merged

## Ask: Should setup accept an apex that holds only mail records?
Rule: owner-call
Part: none
Recommended: 1
Reason: Most owners' domains carry mail on the apex, so today's rule refuses a first-time owner on a domain they already use.
Summary: `cairn new` refuses an address with DNS records of any type. carin-test.org's apex holds only MX and SPF TXT.

Background: The rule protects existing site records from being overwritten. Mail records sit beside a site's records and do not clash with them.

Facts: The refusal counts every record type.
- `checkAddress` refuses on any record (`tool/internal/setup/opening.go:326`)
- The apex holds MX and TXT only, with no A, AAAA, CNAME, or www (`dig carin-test.org`)
- The gate's sweep already counts only A, AAAA, and CNAME (`scripts/gate/sweep.mjs:24`)
- Filed as #430 (`glw907/cairn-cms:BACKLOG.md`)

Choices:
- Count only A, AAAA, and CNAME: a mail-only apex works; docs and tests change
- Keep the rule: owners use a subdomain, and the card names one

## Ask: Should the sandbox exclusion list widen?
Rule: owner-call
Part: none
Recommended: 1
Reason: The new sandbox stop turns a silent stall into one line, so the narrow list costs an agent one retry.
Summary: Four of six runs fell out of the exclusion through `-y`, a tag, a pipe, or `cd`. `cairn new` now refuses inside a sandbox with one actionable line.

Background: S-2 keeps the excluded patterns narrow, because an excluded command runs with full access. Widening would cover forms like `cd <dir> && npx create-cairn-site`.

Facts: The stop rests on a marker Anthropic's sandbox sets itself.
- `SANDBOX_RUNTIME=1` is set on every wrapped command (`anthropics/sandbox-runtime src/sandbox/sandbox-utils.ts`)
- The stop merged with its tests (`glw907/cairn-cms#224`)

Choices:
- Keep it narrow: rely on the stop and the docs, and revisit after round seven
- Widen now: add the `cd` form under S-5, with a probe rerun

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/cairn-cms#226 | approve | It changes `docs/STATUS.md` only, recording the stop, both lists, and the open rows. | It is the run's record. |
| step:1 | session | A merge can be reverted. | It records the state. |
| step:2 | session | The change follows your ruling and gets a review. | The harness enforces the line. |
| step:3 | session | It lands only on your ruling, with a review. | It fixes the apex refusal. |
