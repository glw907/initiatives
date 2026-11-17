
## Addendum from the `engine` pass: rulings the engine and harness comments cited

The `engine` pass removed the process tags from the comments under `internal/engine`, `internal/harness`,
`cmd/harness`, and `internal/config`. Each line below records one ruling those comments cited that had no
record in this file, a frozen spec, or the corpus ledger. The text states what was decided. The source names
where the decision was first written, as that file stood at commit `e03e574`.

- **matcher, 3a contract 1.** The string_dist pipeline is lower, then transliterate, then lower. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:462`.
- **matcher, 3a contract 3.** The strong threshold compares with a strict < and the medium threshold with <=. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:478`.
- **matcher, 3a contract 5.** The normalizer's denominator counts only penalties that were added. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:497`.
- **matcher, 3a contract 6.** The adders carry their exact semantics, as the plan states them for beets/autotag/distance.py. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:510`.
- **matcher, 3a contract 6a.** AddEquality and AddPriority wrap a scalar option into a one-element list (fold M-e). Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:524`.
- **matcher, 3a contract 7.** Regex OPTIONS anchor; SD_PATTERNS never do. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:536`.
- **matcher, 3a contract 8.** Component order is load-bearing, not stylistic. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:559`.
- **matcher, 3a contract 9.** The evaluation date is an explicit input, never a clock read. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:571`.
- **matcher, 3a contract 10.** Item fields project through beets' typed defaults. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:576`.
- **matcher, 3a contract 11.** plurality is Counter.most_common(1): ties break by first-seen insertion order. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:597`.
- **matcher, 3a contract 12.** Bit-identity is the target; 1e-12 relative is the comparison. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:603`.
- **matcher, 3a fold m6 (data_source is the one exception).** data_source is the one exception to the typed-default projection: it lives in Item._types, not Item._fields. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:586`.
- **matcher, 3a fold m2 (twenty weight keys).** distance_weights is twenty keys; the mechanics study's Q4 figure of nineteen is the losing sentence. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:295`.
- **conform, 3a fold M-e (compiled-regex option object).** A compiled-regex option is encoded as an object {regex, ignorecase} and the decoder recognizes it wherever add_equality or add_priority takes an option. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:1320`.
- **matcher, 3d fold M-d (two action vocabularies).** One four-value ParseAction would bless quiet_fallback: apply, which beets refuses; the two options carry different legal sets. Source: `docs/plans/2026-09-05-rung-3d-verdicts-gate.md:2999`.
- **musicbrainz, 3c R2 (the limiter's clock and shape).** The plan's R2 rules the limiter's clock and its shape. Source: `docs/plans/2026-09-04-rung-3c-client-limiter.md:800`.
- **musicbrainz, 3c fold m10 (clock walk).** Fold m10, cited with R2: the clock walk covers _test.go too. Source: `docs/plans/2026-09-04-rung-3c-client-limiter.md:815`.
- **musicbrainz, 3b R2 (no per-track Media field).** matcher.TrackInfo does not gain a Media field; translate.go keeps an internal per-track record and computes AlbumInfo.Media from it. Source: `docs/plans/2026-09-04-rung-3b-translation.md:829`.
- **musicbrainz, 3b R6 (ledger keying and field scope).** One ledger row per release lookup, keyed by (case_id, release_mbid), with the graded set exactly the fourteen AlbumInfo and eight TrackInfo fields. Source: `docs/plans/2026-09-04-rung-3b-translation.md:906`.
- **musicbrainz, 3b fold M-i (credits drop SortName).** credits.SortName is dropped: a struct field nothing reads, with a false stated rationale. Source: `docs/research/2026-09-04-rung-3b-plan-review.md:466`.
- **tag, 3d R18 (public entry point).** A third small package, internal/engine/tag, one file plus its test, holds beets' tag_album and nothing else. Source: `docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1544`.
- **tagio, 8a contract C1.** The tag set is tagio's own vocabulary: a named exported type carrying the 69 writable fields with Go-native types. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:413`.
- **tagio, 8a contract C2.** Four input states, chosen by the type: a value, an empty string, an empty list, and absent. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:429`.
- **tagio, 8a contract C3.** The write order is part of the contract; the three colliding pairs resolve as sorted_fields() resolves them, with the plural winning. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:441`.
- **tagio, 8a contract C4.** A set writes every applicable style; a read takes the first truthy one. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:448`.
- **tagio, 8a contract C5.** Read-back takes the last applicable style when nothing is truthy. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:457`.
- **tagio, 8a contract C6.** The reader is the exported 69-key projection. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:467`.
- **tagio, 8a contract C7.** The reader parses the metadata blocks and refuses what it does not fully understand. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:475`.
- **tagio, 8a contract C7a.** The parse reads the metadata region only. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:513`.
- **tagio, 8a contract C8.** The writer replaces only the keys the tag set owns. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:522`.
- **tagio, 8a contract C9.** The vendor string is part of the block and part of the type. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:539`.
- **tagio, 8a contract C9a.** A freshly created VORBIS_COMMENT block is written immediately after STREAMINFO. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:547`.
- **tagio, 8a contract C10.** Every block the writer does not own survives. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:557`.
- **tagio, 8a contract C11.** The last-block flag is the writer's responsibility. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:566`.
- **tagio, 8a contract C12.** The audio is untouched. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:573`.
- **tagio, 8a contract C13.** A tag write is atomic or it does not happen, and it preserves the target's mode. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:578`.
- **tagio, 8a contract C14.** Refusals are sentinels where a caller branches. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:588`.
- **tagio, 8a contract C15.** The frame region is the content hash's extent. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:593`.
- **tagio, 8a contract C16.** The mapping's citations live in the code. Source: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:598`.
- **tagio, 8b P8 (a picture store replaces the whole set).** A picture store replaces the whole set; a delete clears it; preservation is the caller's. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:528`.
- **tagio, rung 8 spec :401-410 and inventory surprise 4 (colliding keys).** Three writable fields collide on a Vorbis key and sort order decides the winner: the plural sorts last and wins. Source: `docs/research/2026-09-07-rung-8-spec-inventory.md:1165`.
- **mechanics study Q5 (the HTTP seam).** The study's section on the HTTP seam, cited for beets' request include set and fetch behavior. Source: `docs/research/2026-09-02-beets-matcher-mechanics.md:476`.
- **mechanics study Q2 (distance and penalty pipeline).** The study's section on the distance and penalty pipeline. Source: `docs/research/2026-09-02-beets-matcher-mechanics.md:137`.
- **mechanics study Q4 (tunable surface).** The study's tunable-surface section, whose nineteen-key count the 3a plan's m2 corrects to twenty. Source: `docs/research/2026-09-02-beets-matcher-mechanics.md:395`.
- **mechanics study Q1.4 (purity).** The study's purity section; the comment cites its item 1.4. Source: `docs/research/2026-09-02-beets-matcher-mechanics.md:31`.
- **mechanics study, epsilon-regime finding.** The study's section on threats to the frozen-corpus design and the epsilon regime. Source: `docs/research/2026-09-02-beets-matcher-mechanics.md:561`.
- **3d R1 (two of four oracle-wrong classes get a compat switch).** matcher.Compat carries exactly two fields, FtPattern and RemixParenthetical, both defaulting off; the other two oracle-wrong hypotheses ship no switch. Source: `docs/plans/2026-09-05-rung-3d-verdicts-gate.md:876`.
- **3d R9 (ModeDefault verdict moves).** A ModeDefault verdict move is reported as a count and a case list, fails nothing, and is handed to Geoff as one adjudication batch. Source: `docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1252`.
- **3d R15 (runner reports a pending divergence).** GradeCases never writes into corpus/; a tier-2 disagreement with no adjudication row fails the gate and prints the row a human pastes. Source: `docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1453`.
- **rung 2c plan review B1 (seed-items tool).** A real-catalog case's Input.Items cannot be authored under the plan's no-read constraint and no tool closes the gap; the plan adds harness seed-items. Source: `docs/research/2026-09-02-greenfield-spec-reviews/rung-2c-plan-review.md:20`.
- **tagio, 8b P1.** The picture is its own exported type. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:445`.
- **tagio, 8b P2.** Container carries the pictures it parsed, in on-disk order. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:457`.
- **tagio, 8b P3.** Every declared length in a PICTURE block is bounds-checked before it is trusted. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:464`.
- **tagio, 8b P4.** The picture type index is the ID3v2 APIC enumeration, 0 through 20, with out-of-range values degrading to 0 on read. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:494`.
- **tagio, 8b P5.** Front-cover selection is a query over a parsed picture set, so a lone back cover is the cover. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:501`.
- **tagio, 8b P6.** A write emits zero for width, height, colour depth and colour count. Source: `docs/plans/2026-09-08-rung-8b-picture-conformance.md:508`.
- **config, rung 1b O5 class 1 (duplicate within a family).** A key declared twice within one declaration family is a collision the gate catches. Source: `docs/plans/2026-09-07-rung-1b-config-registry.md:405`.
- **config, rung 1b O5 class 2 (duplicate across families).** A key declared in one family and also in another is a collision the gate catches. Source: `docs/plans/2026-09-07-rung-1b-config-registry.md:406`.
- **config, rung 1b O5 class 3 (missing DUBPLATE_ prefix).** A declared key without the DUBPLATE_ prefix is a collision the gate catches. Source: `docs/plans/2026-09-07-rung-1b-config-registry.md:409`.
- **config, rung 1b O5 class 6 (wall row neither key nor status row).** A wall row that is neither a prefixed key nor a status row carrying Pending text is a collision the gate catches. Source: `docs/plans/2026-09-07-rung-1b-config-registry.md:418`.
- **conform, 3a fold B1 (decoder dispatches on method).** The decoder dispatches on method, and inside method add on the argument shape: eleven methods, twelve shapes. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:1221`.
- **conform, 3a fold B2 (weights is an override).** A row's weights map is an override on Tunables.DistanceWeights, not a complete weight table. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:1275`.
- **conform, 3a fold B3 (get_penalty two-plugin stub).** get_penalty and the two-plugin stub are modeled explicitly. Source: `docs/plans/2026-09-04-rung-3a-scoring-core.md:1294`.
- **musicbrainz, 3b fold B5 (null format is not a sentinel route).** A single medium whose format is null is not a sentinel route: the sentinel has two routes, not three. Source: `docs/plans/2026-09-04-rung-3b-translation.md:523`.
- **conform, 3b R11 as cited for the nullability policy.** The nullability policy covers every scalar field of `matcher.AlbumInfo` and `matcher.TrackInfo`: 21 rows in three regimes (3 `nullStrict`, 9 `nullNeverExpected`, 9 `nullEqualsZero`), with one reason for each row. The comment cited the policy as R11. This file records the policy itself at line 10258, without the id, and `docs/plans/2026-09-04-rung-3b-translation.md:818` names "Resolution R11's table".
- **tagio, 8a ruling of 2026-09-08, m6 (Parse bypasses the registry).** `tagio.Parse` never consults the format registry in `seam.go`. It is the FLAC entry point and always returns a FLAC `Container`, and a registry row for another format would have nothing to hand it. No document recorded this before the addendum: three comments were its only record. The `engine` pass replaces the registry with plain functions.
