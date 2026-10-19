# Edit-quality plan review: mechanics and feasibility

Reviewer: `plan-reviewer`, on `plans/2026-10-19-drafter-edit-quality-plan.md` (uncommitted), drafter
`41939c3`, cairn `50dc211d9` (probes in a scratch clone). Saved by the planning session from the
agent's reply. The three Departures are mechanically sound as method calls.

## Findings

1. **Major: the cache prefix is not stable across reads** (plan:72-79, :257-261, EQ.5). The change
   read's prompt ends with `These sections changed: ${scope}` (`blueprintPrompt`), and `Build` puts
   the prompt before the register, so a fix touching another section changes the prefix. The facts
   block lists only placed or cited facts (`placedFacts(view)`, `internal/assemble/blueprint.go:17`),
   so a new citation also misses. Fold: move the scope sentence (both forms) out of the prompt into
   the second block (stageBlueprintRead prepends it to the change text); update
   `TestRealModuleRendersTheBlueprintSeat`'s want; add a second breakpoint after the inlined
   register (the API allows four).
2. **Major: the live cache proof can pass vacuously** (plan:368-372, :284). It runs only if the probe
   reads twice; `saveRequest` writes the `batch.Request` struct, not the wire (`money.go:169-181`).
   Fold: run `read.sh` twice back to back on one fixed commit (ref6, ~$0.60); assert the first
   settlement has `CacheWrite5m > 0` and the second `CacheRead > 0`; the new `batch.Message` field
   is exported and JSON-tagged so `requests/*.json` and `state.json` carry it.
3. **Major: the skill's Read step names only three outcomes** (plan:199-207). Unnamed: exit 1 from a
   consistency escalation; exit 2 for a dirty tree, an unresolved `--since`, or config; exit 3 (cycle
   cap, spend limit, transport, page cap); exit 0 with verdict "ok" and a blocking finding
   (`completeBlueprintRead` accepts on verdict). Fold: a short table in the Read section, one row per
   state with the action and what the report says; the harness classifies the same way.
4. **Major: the cairn blueprint fires warnings the plan does not predict** (plan:246-251, :340-352).
   `cited` fires on three lead-ins (`bb-lead`, `push-lead`, `ver-lead`, `mode: claim`, no facts);
   `handler` fires on `x-check-threw`, `x-third-verify`, and `x-logs-empty`→`rec-logs-observability`.
   EQ.6's fix list (items named in three or more reads) cannot meet its "no warning" acceptance.
   Fold: the fix list is the tally plus every warning EQ.2 keeps; state now that `cited` likely drops
   on lead-ins under the design's own rule. Owner fork if kept: (a) drop it, recommended; (b) a new
   lead-in rule.
5. **Minor: the `Worst` change reaches every reservation** (EQ.5). `money.go` passes no cached flag,
   so every seat's reservation prices input at the write rate. Six ledger test rows change
   (`TestWorstFunc` sync, batch, tier, at_the_threshold; `TestWorstThroughReserve` two rows); docs go
   stale (`docs/setup.md:90`, `docs/configuration.md:309`, `price.go:49`); "the higher of the two"
   misses a 1-hour write. Fold: list them in EQ.5; define `Worst` as the highest of input and both
   write rates; the packet says this touches the money path's pricing while `money.go` is untouched.
6. **Minor: the Departures header says items 1-3 need Geoff's ruling** (plan:55-56). Fold: method
   calls, listed in the packet.
7. **Minor: the `handler` rule names no anchor source** (plan:236-238). No cairn section sets
   `anchor:`; `slugOf` is unexported (`internal/plan/slug.go:64`). Fold: name the source; add
   `slug.go` to EQ.2 if exported.
8. **Minor: `drafter check --help` goes stale** (`cmd/drafter/check.go:26-34`). Fold: EQ.2 adds two
   clauses.
9. **Minor: two measures undefined** (plan:407, :410-412). "Minutes waiting" is first reserve to last
   settle per run id; judge agreement takes all first-read blocks up to three, with the count.
10. **Minor: the env-file channel can collect hook exports** (plan:126-133, :374). Fold: a fresh copy
    per session, saved after; the no-key probe asserts via `drafter config` that the key comes from
    `key_env`.
11. **Optional: library facts stated, not quoted** (prefix identity, 512-token minimum, TTL, rates,
    `CLAUDE_ENV_FILE`).
12. **Optional: EQ.1's "six lines" means six bullets** (`docs/blueprint-format.md:442-453`).
