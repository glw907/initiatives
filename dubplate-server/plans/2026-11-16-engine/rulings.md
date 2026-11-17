## Rulings and their records

Read in a clone of `dubplate` at `c42bb85`, and checked again at `e03e574` with `check-rulings.py` (149 rows, 149 pass). Every Search cell runs from the repo root and prints exactly the Record line. Paths in Cited at are relative to `internal/` unless they begin `cmd/`. Records are located by content; the line numbers the comments cite (`spec:688-690`, `docs/HISTORY.md:265-272`, the rung 3 spec `:141`, `:288`, `:292`, `:295`) are stale and are listed as their own rows. The same id means different things per package: each row names the package and the pass whose plan or HISTORY entry holds it.

| Ruling | Cited at | What it decided | Record | Search |
|---|---|---|---|---|
| config, rung 1b R2 | 1 lines: internal/config/registry.go:197 | The two class shapes, ReservedClass and IntegrationClass, stay distinct. | docs/HISTORY.md:7925 | ``grep -n -E '^- \*\*R2\*\* \(the two class shapes' docs/HISTORY.md`` |
| config, rung 1b R5 | 2 lines: internal/config/config.go:123, internal/config/config.go:465 | Load's class.Name == "shadow" branch retires; the two class shapes are re-expressed as a pairing exemption. | docs/HISTORY.md:7934 | ``grep -n -E '^- \*\*R5\*\* \(.Load... .class\.Name' docs/HISTORY.md`` |
| config, rung 1b R8 | 1 lines: internal/config/registry.go:500 | The superseded map is 1b's by necessity. | docs/HISTORY.md:7947 | ``grep -n -E '^- \*\*R8\*\* \(the superseded map' docs/HISTORY.md`` |
| config, rung 1b R11 | 2 lines: internal/config/registry.go:248, internal/config/registry.go:267 | KindInt stays the zero value; an unnamed or mis-defaulted kind is a registration error. | docs/HISTORY.md:7954 | ``grep -n -E '^- \*\*R11\*\* \(.KindInt. stays' docs/HISTORY.md`` |
| config, rung 1b R15 | 1 lines: internal/config/registry.go:190 | Declaration order is preserved; the registry never sorts. | docs/HISTORY.md:7965 | ``grep -n -E '^- \*\*R15\*\* \(declaration order' docs/HISTORY.md`` |
| config, rung 1b R16 | 1 lines: internal/config/registry.go:102 | Every declared key carries the DUBPLATE_ prefix; the pending row is not a key. | docs/HISTORY.md:7967 | ``grep -n -E '^- \*\*R16\*\* \(every declared key' docs/HISTORY.md`` |
| config, rung 5b R-5b4 | 1 lines: internal/config/config.go:441 | Load requires every owned-now wall row generically, not by naming rung 5's selector. | docs/HISTORY.md:5458 | ``grep -n -E '^. R-5b4 . .Load. requires' docs/HISTORY.md`` |
| config, rung 5b R-5b5 | 1 lines: internal/config/registry.go:308 | The per-source correlated set is a registry declaration family, not a widened integration class or a hard-coded switch. | docs/HISTORY.md:5459 | ``grep -n -E '^. R-5b5 . The per-source correlated set' docs/HISTORY.md`` |
| matcher, 3a contract 1 | 1 lines: internal/engine/matcher/strdist.go:21 | The string_dist pipeline is lower, then transliterate, then lower. | docs/plans/2026-09-04-rung-3a-scoring-core.md:462 (plan only) | ``grep -n -E '^\*\*1\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 3 | 3 lines: internal/engine/matcher/tunables.go:64, internal/engine/matcher/tunables.go:70, internal/engine/matcher/tunables.go:76 | The strong threshold compares with a strict < and the medium threshold with <=. | docs/plans/2026-09-04-rung-3a-scoring-core.md:478 (plan only) | ``grep -n -E '^\*\*3\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 5 | 4 lines: internal/engine/matcher/penalty.go:18, internal/engine/matcher/penalty.go:67, internal/engine/matcher/penalty.go:78 | The normalizer's denominator counts only penalties that were added. | docs/plans/2026-09-04-rung-3a-scoring-core.md:497 (plan only) | ``grep -n -E '^\*\*5\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 6 | 3 lines: internal/engine/matcher/album_data_source.go:7, internal/engine/matcher/album_mediums.go:9, internal/engine/matcher/track_data_source.go:5 | The adders carry their exact semantics, as the plan states them for beets/autotag/distance.py. | docs/plans/2026-09-04-rung-3a-scoring-core.md:510 (plan only) | ``grep -n -E '^\*\*6\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 6a | 1 lines: internal/harness/conform/component.go:352 | AddEquality and AddPriority wrap a scalar option into a one-element list (fold M-e). | docs/plans/2026-09-04-rung-3a-scoring-core.md:524 (plan only) | ``grep -n -E '^\*\*6a\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 7 | 6 lines: internal/engine/matcher/album_country.go:17, internal/engine/matcher/album_media.go:18, internal/engine/matcher/penalty.go:359 | Regex OPTIONS anchor; SD_PATTERNS never do. | docs/plans/2026-09-04-rung-3a-scoring-core.md:536 (plan only) | ``grep -n -E '^\*\*7\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 8 | 6 lines: internal/engine/matcher/album_artist.go:11, internal/engine/matcher/album_extras.go:18, internal/engine/matcher/info.go:21 | Component order is load-bearing, not stylistic. | docs/plans/2026-09-04-rung-3a-scoring-core.md:559 (plan only) | ``grep -n -E '^\*\*8\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 9 | 4 lines: internal/engine/matcher/album_year.go:7, internal/engine/matcher/score.go:55, internal/engine/musicbrainz/translate.go:24 | The evaluation date is an explicit input, never a clock read. | docs/plans/2026-09-04-rung-3a-scoring-core.md:571 (plan only) | ``grep -n -E '^\*\*9\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 10 | 2 lines: internal/engine/matcher/info.go:118, internal/engine/matcher/info.go:222 | Item fields project through beets' typed defaults. | docs/plans/2026-09-04-rung-3a-scoring-core.md:576 (plan only) | ``grep -n -E '^\*\*10\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 11 | 2 lines: internal/engine/matcher/likelies.go:9, internal/engine/matcher/likelies.go:97 | plurality is Counter.most_common(1): ties break by first-seen insertion order. | docs/plans/2026-09-04-rung-3a-scoring-core.md:597 (plan only) | ``grep -n -E '^\*\*11\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a contract 12 | 5 lines: internal/harness/conform/component.go:49, internal/harness/conform/component.go:53, internal/harness/conform/component.go:68 | Bit-identity is the target; 1e-12 relative is the comparison. | docs/plans/2026-09-04-rung-3a-scoring-core.md:603 (plan only) | ``grep -n -E '^\*\*12\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a fold m6 (data_source is the one exception) | 1 lines: internal/engine/matcher/info.go:118 | data_source is the one exception to the typed-default projection: it lives in Item._types, not Item._fields. | docs/plans/2026-09-04-rung-3a-scoring-core.md:586 (plan only) | ``grep -n -E 'data_source. is the one exception, and it is not a counterexample' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| matcher, 3a fold m2 (twenty weight keys) | 1 lines: internal/engine/matcher/tunables.go:92 | distance_weights is twenty keys; the mechanics study's Q4 figure of nineteen is the losing sentence. | docs/plans/2026-09-04-rung-3a-scoring-core.md:295 (plan only) | ``grep -n -E '^### m2: .distance_weights. is twenty keys' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| conform, 3a fold M-e (compiled-regex option object) | 1 lines: internal/harness/conform/component.go:379 | A compiled-regex option is encoded as an object {regex, ignorecase} and the decoder recognizes it wherever add_equality or add_priority takes an option. | docs/plans/2026-09-04-rung-3a-scoring-core.md:1320 (plan only) | ``grep -n -E '^- \*\*A compiled-regex option is encoded as an object\*\* \(fold, M-e\)' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| rung 3 spec, Ruling D (defaults) | 3 lines: internal/engine/matcher/tunables.go:32, internal/engine/matcher/tunables.go:198, internal/engine/musicbrainz/alias.go:16 | Every default equals pinned beets' shipped value at launch, languages included, with alias-language selection logged as a post-launch candidate (accepted as recommended by Geoff, 2026-09-03, spec line 3). | docs/specs/2026-09-03-rung-3-go-matcher.md:111 | ``grep -n -E '^### Ruling D: the defaults themselves' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| matcher, 3d fold M-d (two action vocabularies) | 2 lines: internal/engine/matcher/tunables.go:475, internal/engine/matcher/verdict.go:76 | One four-value ParseAction would bless quiet_fallback: apply, which beets refuses; the two options carry different legal sets. | docs/plans/2026-09-05-rung-3d-verdicts-gate.md:2999 (plan only) | ``grep -n -E '^  \(revision 2, fold M-d\)\. beets resolves .quiet_fallback' docs/plans/2026-09-05-rung-3d-verdicts-gate.md`` |
| matcher, 3d R6 (match.required has no is-None analogue) | 1 lines: internal/engine/matcher/candidate.go:49 | match.required tests the Go zero value, a declared coverage gap (gap 3, R6). | docs/HISTORY.md:9287 | ``grep -n -E '^. V9 .match\.required. tests Go zero value' docs/HISTORY.md`` |
| 3c R15 (3a's dataSourcePenalty carry, closed in 3c) | 3 lines: internal/engine/matcher/penalty.go:414, internal/engine/matcher/tunables.go:167, internal/engine/matcher/tunables.go:327 | 3a's dataSourcePenalty carry is closed (R15), with both conform compensations removed and 72/72 tier-0 rows re-verified. | docs/HISTORY.md:9875 | ``grep -n -E '^11\. \*\*3a.s .dataSourcePenalty. carry is CLOSED' docs/HISTORY.md`` |
| 3b guard 2 (absent source field is the string zero value) | 1 lines: internal/engine/matcher/candidate.go:64 | An absent source field becomes the plain-string zero value, never a nil-bearing vocabulary. | docs/HISTORY.md:10243 | ``grep -n -E '^2\. \*\*3a.s R1 carry is closed, and this is its resolution' docs/HISTORY.md`` |
| musicbrainz, 3c contract C3 | 1 lines: internal/engine/musicbrainz/client.go:178 | A release lookup carries the sixteen-element RELEASE_INCLUDES as one inc= value. | docs/HISTORY.md:9737 | ``grep -n -E '^. C3 sixteen-element' docs/HISTORY.md`` |
| musicbrainz, 3c contract C4 | 1 lines: internal/engine/musicbrainz/client.go:190 | A search carries no inc. | docs/HISTORY.md:9738 | ``grep -n -E '^. C4 a search carries' docs/HISTORY.md`` |
| musicbrainz, 3c contract C12 | 3 lines: internal/engine/musicbrainz/client.go:44, internal/engine/musicbrainz/client.go:393, internal/engine/musicbrainz/client.go:411 | The transport policy: retry count, backoff schedule, timeout, and Retry-After. | docs/HISTORY.md:9746 | ``grep -n -E '^. C12 the transport' docs/HISTORY.md`` |
| musicbrainz, 3c contract C13 | 1 lines: internal/engine/musicbrainz/client.go:287 | album_for_id is fetch, translate, and a conditional second fetch. | docs/HISTORY.md:9747 | ``grep -n -E '^. C13 fetch, translate' docs/HISTORY.md`` |
| musicbrainz, 3c contract C15 | 1 lines: internal/engine/musicbrainz/client.go:287 | A 404 drops a lookup candidate silently and propagates from a search as an empty list. | docs/HISTORY.md:9749 | ``grep -n -E '^. C15 a 404' docs/HISTORY.md`` |
| musicbrainz, 3c contract C18 | 1 lines: internal/engine/musicbrainz/client.go:180 | Go's net/url reproduces the canonical request form byte for byte. | docs/HISTORY.md:9752 | ``grep -n -E '^. C18 .net/url. reproduces' docs/HISTORY.md`` |
| musicbrainz, 3c contract C19 | 1 lines: internal/engine/musicbrainz/client.go:240 | A search response is an object, with the ids under releases. | docs/HISTORY.md:9753 | ``grep -n -E '^. C19 a search response' docs/HISTORY.md`` |
| musicbrainz, 3c contract C20 | 1 lines: internal/engine/musicbrainz/limiter.go:53 | The wire pace is 1 per second, not 4 per second. | docs/HISTORY.md:9754 | ``grep -n -E '^. C20 the wire pace' docs/HISTORY.md`` |
| musicbrainz, 3c R13 (retry semantics) | 3 lines: internal/engine/musicbrainz/client.go:34, internal/engine/musicbrainz/client.go:100, internal/engine/musicbrainz/client.go:395 | Three deliberate transport divergences: a 30s timeout rather than beets' 10s; a limiter token per attempt rather than per call; Retry-After honored in delta-seconds form only. | docs/HISTORY.md:9843 | ``grep -n -E '^7\. \*\*The client.s three deliberate transport divergences\*\* \(R13\)' docs/HISTORY.md`` |
| musicbrainz, 3c R14 (regime divergences) | 1 lines: internal/engine/musicbrainz/client.go:63 | Three regime divergences travel together: the \b regime, full-case versus simple-case lowering on the query path, and _extract_id's \w. | docs/HISTORY.md:9866 | ``grep -n -E '^9\. \*\*Three regime divergences now travel together\*\* \(R14\)' docs/HISTORY.md`` |
| musicbrainz, 3c R2 (the limiter's clock and shape) | 1 lines: internal/engine/musicbrainz/client.go:115 | The plan's R2 rules the limiter's clock and its shape. | docs/plans/2026-09-04-rung-3c-client-limiter.md:800 (plan only) | ``grep -n -E '^### R2: the limiter.s clock, and its shape' docs/plans/2026-09-04-rung-3c-client-limiter.md`` |
| musicbrainz, 3c fold m10 (clock walk) | 1 lines: internal/engine/musicbrainz/client.go:115 | Fold m10, cited with R2: the clock walk covers _test.go too. | docs/plans/2026-09-04-rung-3c-client-limiter.md:815 (plan only) | ``grep -n -E '^\*\*The walk covers .*fold m10' docs/plans/2026-09-04-rung-3c-client-limiter.md`` |
| 3b guard 11 (the \b regime) | 1 lines: internal/engine/musicbrainz/client.go:63 | SDPatternsWordBoundary's \b is Unicode-aware in Python re and ASCII-only in Go RE2, so 3d's compat switch and the defect_free derivation can differ on non-ASCII input. | docs/HISTORY.md:10315 | ``grep -n -E '^11\. \*\*The .\\b. regime divergence' docs/HISTORY.md`` |
| 3b carry (MergePseudoRelease aliasing), closed by 3c | 2 lines: internal/engine/musicbrainz/client.go:291, internal/engine/musicbrainz/client.go:293 | AlbumForID closes 3b's MergePseudoRelease aliasing carry by construction; the hazard changes owner to 3d and rung 9. | docs/HISTORY.md:9871 | ``grep -n -E '^10\. \*\*.AlbumForID. closes 3b.s .MergePseudoRelease. aliasing carry' docs/HISTORY.md`` |
| musicbrainz, 3b R1 (absent field maps to the zero value) | 2 lines: internal/engine/musicbrainz/tracks.go:129, internal/harness/conform/translate.go:58 | The translation maps an absent source field to the type's zero value; the plan's R1 resolves 3a's first carried item. | docs/HISTORY.md:10243 | ``grep -n -E '^2\. \*\*3a.s R1 carry is closed, and this is its resolution' docs/HISTORY.md`` |
| musicbrainz, 3b R2 (no per-track Media field) | 1 lines: internal/engine/musicbrainz/tracks.go:18 | matcher.TrackInfo does not gain a Media field; translate.go keeps an internal per-track record and computes AlbumInfo.Media from it. | docs/plans/2026-09-04-rung-3b-translation.md:829 (plan only) | ``grep -n -E '^### R2: per-track .Media.' docs/plans/2026-09-04-rung-3b-translation.md`` |
| musicbrainz, 3b R6 (ledger keying and field scope) | 1 lines: internal/engine/musicbrainz/credit.go:18 | One ledger row per release lookup, keyed by (case_id, release_mbid), with the graded set exactly the fourteen AlbumInfo and eight TrackInfo fields. | docs/plans/2026-09-04-rung-3b-translation.md:906 (plan only) | ``grep -n -E '^### R6: the ledger.s keying and its field scope' docs/plans/2026-09-04-rung-3b-translation.md`` |
| musicbrainz, 3b R8 (VAName landed, AliasesAsCredits did not) | 1 lines: internal/engine/musicbrainz/credit.go:25 | Tunables.VAName landed and AliasesAsCredits did not; the exclusion is deliberate per R8. | docs/HISTORY.md:10346 | ``grep -n -E '^15\. \*\*.Tunables\.VAName. landed and .AliasesAsCredits. did not' docs/HISTORY.md`` |
| musicbrainz, 3b fold M-i (credits drop SortName) | 1 lines: internal/engine/musicbrainz/credit.go:21 | credits.SortName is dropped: a struct field nothing reads, with a false stated rationale. | docs/research/2026-09-04-rung-3b-plan-review.md:466 | ``grep -n -E '^### M-i\. .credits\.SortName. is a struct field nothing reads' docs/research/2026-09-04-rung-3b-plan-review.md`` |
| 3c R1 (request construction, not the request set) | 1 lines: internal/harness/conform/request.go:194 | 3c grades request construction, not the request set; 3d owns the ID-match early return, _recommendation, and _add_candidate. | docs/HISTORY.md:9826 | ``grep -n -E '^3\. \*\*3c grades request construction, not the request set' docs/HISTORY.md`` |
| tag, 3d R18 (public entry point) | 1 lines: internal/engine/tag/doc.go:6 | A third small package, internal/engine/tag, one file plus its test, holds beets' tag_album and nothing else. | docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1544 (plan only) | ``grep -n -E '^### R18: the public entry point lives in' docs/plans/2026-09-05-rung-3d-verdicts-gate.md`` |
| tag, 3c carry 13c (vaLikely stays unexported) | 1 lines: internal/engine/tag/tag.go:122 | vaLikely is unexported at rung 3 and 3d exports it the day match_by_id's no-consensus branch needs it. | docs/HISTORY.md:9892 | ``grep -n -E '^13c\. \*\*.vaLikely. is unexported at rung 3' docs/HISTORY.md`` |
| tag, 3c non-ports (3c's close) | 1 lines: internal/engine/tag/tag.go:36 | Four surfaces are non-ports, recorded with their reasons rather than as gaps. | docs/HISTORY.md:9764 | ``grep -n -E '^\*\*Four surfaces are non-ports, recorded with their reasons' docs/HISTORY.md`` |
| tagio, 8a contract C1 | 2 lines: internal/engine/tagio/tagset.go:12, internal/engine/tagio/tagset.go:91 | The tag set is tagio's own vocabulary: a named exported type carrying the 69 writable fields with Go-native types. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:413 (plan only) | ``grep -n -E '^\*\*C1\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C2 | 9 lines: internal/engine/tagio/deviations.go:55, internal/engine/tagio/encode.go:27, internal/engine/tagio/encode.go:230 | Four input states, chosen by the type: a value, an empty string, an empty list, and absent. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:429 (plan only) | ``grep -n -E '^\*\*C2\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C3 | 5 lines: internal/engine/tagio/encode.go:19, internal/engine/tagio/tagset.go:239, internal/engine/tagio/tagset.go:329 | The write order is part of the contract; the three colliding pairs resolve as sorted_fields() resolves them, with the plural winning. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:441 (plan only) | ``grep -n -E '^\*\*C3\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C4 | 3 lines: internal/engine/tagio/encode.go:201, internal/engine/tagio/encode.go:213, internal/engine/tagio/encode.go:230 | A set writes every applicable style; a read takes the first truthy one. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:448 (plan only) | ``grep -n -E '^\*\*C4\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C5 | 1 lines: internal/engine/tagio/read.go:61 | Read-back takes the last applicable style when nothing is truthy. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:457 (plan only) | ``grep -n -E '^\*\*C5\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C6 | 1 lines: internal/engine/tagio/read.go:51 | The reader is the exported 69-key projection. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:467 (plan only) | ``grep -n -E '^\*\*C6\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C7 | 5 lines: internal/engine/tagio/container.go:125, internal/engine/tagio/container.go:228, internal/engine/tagio/container.go:335 | The reader parses the metadata blocks and refuses what it does not fully understand. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:475 (plan only) | ``grep -n -E '^\*\*C7\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C7a | 1 lines: internal/engine/tagio/container.go:122 | The parse reads the metadata region only. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:513 (plan only) | ``grep -n -E '^\*\*C7a\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C8 | 3 lines: internal/engine/tagio/read.go:247, internal/engine/tagio/write.go:53, internal/engine/tagio/write.go:102 | The writer replaces only the keys the tag set owns. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:522 (plan only) | ``grep -n -E '^\*\*C8\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C9 | 1 lines: internal/engine/tagio/write.go:25 | The vendor string is part of the block and part of the type. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:539 (plan only) | ``grep -n -E '^\*\*C9\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C9a | 1 lines: internal/engine/tagio/write.go:105 | A freshly created VORBIS_COMMENT block is written immediately after STREAMINFO. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:547 (plan only) | ``grep -n -E '^\*\*C9a\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C10 | 3 lines: internal/engine/tagio/container.go:18, internal/engine/tagio/container.go:51, internal/engine/tagio/write.go:65 | Every block the writer does not own survives. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:557 (plan only) | ``grep -n -E '^\*\*C10\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C11 | 2 lines: internal/engine/tagio/write.go:65, internal/engine/tagio/write.go:249 | The last-block flag is the writer's responsibility. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:566 (plan only) | ``grep -n -E '^\*\*C11\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C12 | 1 lines: internal/engine/tagio/write.go:305 | The audio is untouched. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:573 (plan only) | ``grep -n -E '^\*\*C12\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C13 | 2 lines: internal/engine/tagio/write.go:68, internal/engine/tagio/write.go:306 | A tag write is atomic or it does not happen, and it preserves the target's mode. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:578 (plan only) | ``grep -n -E '^\*\*C13\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C14 | 4 lines: internal/engine/tagio/container.go:46, internal/engine/tagio/picture.go:171, internal/engine/tagio/read.go:15 | Refusals are sentinels where a caller branches. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:588 (plan only) | ``grep -n -E '^\*\*C14\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C15 | 1 lines: internal/engine/tagio/container.go:101 | The frame region is the content hash's extent. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:593 (plan only) | ``grep -n -E '^\*\*C15\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a contract C16 | 1 lines: internal/engine/tagio/tagset.go:231 | The mapping's citations live in the code. | docs/plans/2026-09-07-rung-8a-tagio-writer.md:598 (plan only) | ``grep -n -E '^\*\*C16\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md`` |
| tagio, 8a R9 (fresh vendor) | 3 lines: internal/engine/tagio/deviations.go:70, internal/engine/tagio/write.go:25, internal/engine/tagio/write.go:238 | The fresh vendor is asserted by its "dubplate " prefix, with the version from the build. | docs/HISTORY.md:7563 | ``grep -n -E '^- \*\*R9\*\* \(the fresh vendor asserted by prefix' docs/HISTORY.md`` |
| tagio, 8b R1 (three picture caller states) | 4 lines: internal/engine/tagio/picture.go:234, internal/engine/tagio/write.go:53, internal/engine/tagio/write.go:103 | Three caller states: nil leaves pictures untouched, non-nil empty strips, non-empty replaces. | docs/HISTORY.md:7091 | ``grep -n -E '^- \*\*R1\*\* \(three caller states' docs/HISTORY.md`` |
| tagio, 8b R2 (six-row recognized set) | 4 lines: internal/engine/tagio/deviations.go:104, internal/engine/tagio/picture.go:145, internal/engine/tagio/picture.go:167 | The six-row recognized set reproduces filetype's whole test, and a CR2-prefixed blob is refused. | docs/HISTORY.md:7094 | ``grep -n -E '^- \*\*R2\*\* \(the six-row recognized set' docs/HISTORY.md`` |
| tagio, 8b R3 (APNG not reproduced) | 1 lines: internal/engine/tagio/deviations.go:94 | APNG discrimination is not reproduced; PNG's signature alone decides. | docs/HISTORY.md:7100 | ``grep -n -E '^- \*\*R3\*\* \(APNG discrimination not reproduced' docs/HISTORY.md`` |
| tagio, 8b R11 (JSON tags) | 1 lines: internal/engine/tagio/tagset.go:117 | JSON tags name the ledger's own field names, with no omitempty, tied two ways. | docs/HISTORY.md:7128 | ``grep -n -E '^- \*\*R11\*\* \(JSON tags naming the ledger' docs/HISTORY.md`` |
| tagio, 8b R12 (Read stays tag-only) | 1 lines: internal/engine/tagio/doc.go:22 | Read stays tag-only; the picture read reaches through Parse's Container.Pictures; the double parse is a stated deviation. | docs/HISTORY.md:7132 | ``grep -n -E '^- \*\*R12\*\* \(.Read. stays tag-only' docs/HISTORY.md`` |
| tagio, 8b P7 (sniffed media type) | 3 lines: internal/engine/tagio/picture.go:145, internal/engine/tagio/picture.go:202, internal/engine/tagio/write.go:58 | P7: the sniffed media type overrides the declared one on write. | docs/HISTORY.md:6975 | ``grep -n -E 'a non-empty slice replaces\), P7.s sniff-overrides-declared media type' docs/HISTORY.md`` |
| tagio, 8b P8 (a picture store replaces the whole set) | 3 lines: internal/engine/tagio/write.go:103, internal/engine/tagio/write.go:56, internal/engine/tagio/write.go:118 | A picture store replaces the whole set; a delete clears it; preservation is the caller's. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:528 (plan only) | ``grep -n -E '^\*\*P8\. A picture store replaces the whole set' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| harness analysis, 8b R7 (AppliedField schema addition) | 3 lines: internal/harness/analysis/adjudication.go:66, internal/harness/analysis/adjudication.go:71, internal/harness/analysis/adjudication.go:88 | The schema addition on AdjudicationEntry: the instrument's own emitter over a local struct, the conductor's hand-fold as the route, a committed example as the anchor. | docs/HISTORY.md:7112 | ``grep -n -E '^- \*\*R7\*\* \(the schema addition on .AdjudicationEntry.' docs/HISTORY.md`` |
| tagio, rung 8 owner ruling 3 (no consumer type in tagio) | 1 lines: internal/engine/tagio/tagset.go:91 | tagio does not import internal/engine/matcher (ruling 3). | docs/specs/2026-09-07-rung-8-tag-io.md:783 | ``grep -n -E '^- .tagio. does not import .internal/engine/matcher. \(ruling 3\)' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 spec :688-690 (stale line cite) | 1 lines: internal/engine/tagio/container.go:92 | Repeating a field name is legal in a Vorbis comment block (located by content; the cited line numbers are stale). | docs/specs/2026-09-07-rung-8-tag-io.md:557 | ``grep -n -E 'Repeating a field name is legal' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 spec :401-410 and inventory surprise 4 (colliding keys) | 1 lines: internal/engine/tagio/tagset.go:250 | Three writable fields collide on a Vorbis key and sort order decides the winner: the plural sorts last and wins. | docs/research/2026-09-07-rung-8-spec-inventory.md:1165 | ``grep -n -E '^4\. \*\*Three writable fields collide on a Vorbis key' docs/research/2026-09-07-rung-8-spec-inventory.md`` |
| mechanics study Q5 (the HTTP seam) | 5 lines: cmd/harness/capture.go:39, cmd/harness/capture.go:138, cmd/harness/capture.go:308, cmd/harness/capture.go:139, internal/harness/oracle/oracle.go:230 | The study's section on the HTTP seam, cited for beets' request include set and fetch behavior. | docs/research/2026-09-02-beets-matcher-mechanics.md:476 | ``grep -n -E '^## Q5\. The HTTP seam' docs/research/2026-09-02-beets-matcher-mechanics.md`` |
| mechanics study Q2 (distance and penalty pipeline) | 1 lines: internal/harness/analysis/claims.go:85 | The study's section on the distance and penalty pipeline. | docs/research/2026-09-02-beets-matcher-mechanics.md:137 | ``grep -n -E '^## Q2\. The distance and penalty pipeline' docs/research/2026-09-02-beets-matcher-mechanics.md`` |
| mechanics study Q4 (tunable surface) | 1 lines: internal/engine/matcher/tunables.go:90 | The study's tunable-surface section, whose nineteen-key count the 3a plan's m2 corrects to twenty. | docs/research/2026-09-02-beets-matcher-mechanics.md:395 | ``grep -n -E '^## Q4\. The tunable surface, verified complete' docs/research/2026-09-02-beets-matcher-mechanics.md`` |
| mechanics study Q1.4 (purity) | 1 lines: internal/harness/oracle/reconcile.go:18 | The study's purity section; the comment cites its item 1.4. | docs/research/2026-09-02-beets-matcher-mechanics.md:31 | ``grep -n -E '^## Q1\. Purity' docs/research/2026-09-02-beets-matcher-mechanics.md`` |
| mechanics study, epsilon-regime finding | 1 lines: internal/harness/analysis/proximity.go:19 | The study's section on threats to the frozen-corpus design and the epsilon regime. | docs/research/2026-09-02-beets-matcher-mechanics.md:561 | ``grep -n -E '^## Threats to the frozen-corpus design and the epsilon regime' docs/research/2026-09-02-beets-matcher-mechanics.md`` |
| rung 3 spec, ties-excluded ceiling (cited :292) | 1 lines: internal/harness/conform/case.go:80 | The excluded count is reported at every run and may not grow without an owner ruling. | docs/specs/2026-09-03-rung-3-go-matcher.md:297 | ``grep -n -E '^. .ties. excluded ' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, 1e-12 near-miss tolerance (cited :141) | 1 lines: internal/harness/conform/case.go:86 | Distance agreement at the bit-identical target, compared at 1e-12 relative, with the proximity flag guarding the boundaries. | docs/specs/2026-09-03-rung-3-go-matcher.md:143 | ``grep -n -E '^\*\*Evaluated at rung 3, reported forward\.\*\*' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, flagged proximity is bit-identical (cited :288) | 1 lines: internal/harness/conform/case.go:848 | A flagged case's distance must be bit-identical; no epsilon, no adjudication. | docs/specs/2026-09-03-rung-3-go-matcher.md:293 | ``grep -n -E '^. .proximity. flagged ' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, oracle-wrong verdict from the adjudication row (cited :295) | 1 lines: internal/harness/conform/case.go:875 | Each probe case must produce the corrected verdict on its own adjudications.json row, resolved by subject.case_id. | docs/specs/2026-09-03-rung-3-go-matcher.md:300 | ``grep -n -E '^. .oracle_bugs. disposition .oracle-wrong. ' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, disposition table (cited :285-299) | 1 lines: internal/harness/conform/case.go:880 | The table of how each ledger disposition is graded at the gate. | docs/specs/2026-09-03-rung-3-go-matcher.md:288 | ``grep -n -E '^### What the corpus.s own dispositions mean at this gate' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, fold M7 (tier 2 pending state; cited :311) | 1 lines: internal/harness/conform/case.go:458 | Tier 2 gets the ledgers' own pending state, so a corpus case the matcher diverges on does not hard-red master. | docs/specs/2026-09-03-rung-3-go-matcher.md:311 | ``grep -n -E '^Tier 2 gets the ledgers. own pending state \(fold, M7\)' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, fold B2 (Case.Extra, cited :265) | 3 lines: internal/harness/cassette/cassette.go:52, internal/harness/stub/stub.go:59, internal/harness/stub/stub.go:204 | Case.Extra files are recall-extension fixtures: the Go run need not consume one, consuming one is not a failure, and every consumption is reported. | docs/specs/2026-09-03-rung-3-go-matcher.md:266 | ``grep -n -E '^\*\*.Case\.Extra. and the replay channel it does not have yet \(fold, B2\)' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, fold M1 (tier 1 configuration) | 3 lines: internal/harness/conform/defaults.go:63, internal/engine/matcher/tunables.go:230, internal/harness/conform/defaults.go:16 | The run's Weights and Thresholds come from the case's own echoed record; everything else is Tunables' beets defaults merged with the case's profile. | docs/specs/2026-09-03-rung-3-go-matcher.md:282 | ``grep -n -E '^\*\*How a tier 1 run is configured \(fold, M1\)' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, Ruling F (tie-mirroring escalation) and its M4 fold | 9 lines: internal/harness/analysis/ties.go:74, internal/harness/conform/case.go:95, internal/harness/analysis/ties.go:75, internal/harness/conform/case.go:30, internal/harness/conform/case.go:35, internal/harness/conform/case.go:89, internal/harness/conform/case.go:96, internal/harness/conform/case.go:127, internal/harness/conform/case.go:1001 | Pre-authorize the escalation shape: two failed mirroring attempts stop the task and produce a written finding, and Geoff rules the disposition. The M4 fold lands the owner-only mechanism on excluded rows. | docs/specs/2026-09-03-rung-3-go-matcher.md:127 | ``grep -n -E '^### Ruling F: the tie-mirroring escalation' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| 3d R1 (two of four oracle-wrong classes get a compat switch) | 4 lines: internal/harness/conform/case.go:307, internal/harness/conform/case.go:549, internal/harness/conform/case.go:644 | matcher.Compat carries exactly two fields, FtPattern and RemixParenthetical, both defaulting off; the other two oracle-wrong hypotheses ship no switch. | docs/plans/2026-09-05-rung-3d-verdicts-gate.md:876 (plan only) | ``grep -n -E '^### R1: only two of the four .oracle-wrong. classes' docs/plans/2026-09-05-rung-3d-verdicts-gate.md`` |
| 3d R2 (fourth SD_PATTERNS table) | 1 lines: internal/harness/conform/case.go:531 | 3d builds a fourth table, SDPatternsGuardedNoBracketDiscount, and both compat hypotheses default off. | docs/HISTORY.md:9595 | ``grep -n -E '^  Resolution R2\): both hypotheses default off' docs/HISTORY.md`` |
| 3d R9 (ModeDefault verdict moves) | 4 lines: internal/harness/conform/case.go:531, internal/harness/conform/case.go:551, internal/harness/conform/case.go:552 | A ModeDefault verdict move is reported as a count and a case list, fails nothing, and is handed to Geoff as one adjudication batch. | docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1252 (plan only) | ``grep -n -E '^### R9: what .ModeDefault. does when a non-probe case' docs/plans/2026-09-05-rung-3d-verdicts-gate.md`` |
| 3d R15 (runner reports a pending divergence) | 1 lines: internal/harness/conform/case.go:458 | GradeCases never writes into corpus/; a tier-2 disagreement with no adjudication row fails the gate and prints the row a human pastes. | docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1453 (plan only) | ``grep -n -E '^### R15: the runner reports a pending divergence' docs/plans/2026-09-05-rung-3d-verdicts-gate.md`` |
| 3d fold B2 (ModeDefault re-scores, ModeCompat-only request-set rule) | 2 lines: internal/harness/conform/case.go:160, internal/harness/conform/case.go:531 | ModeDefault re-scores each case's committed candidate set under the corrected table and issues no search; the request-set rule is ModeCompat-only (conductor, revision 2.1, 2026-09-05). | docs/specs/2026-09-05-rung-4-shadow.md:63 | ``grep -n -E 'which the conductor ruled at 3d.s plan fold' docs/specs/2026-09-05-rung-4-shadow.md`` |
| rung 2c plan review B1 (seed-items tool) | 1 lines: cmd/harness/seeditems.go:19 | A real-catalog case's Input.Items cannot be authored under the plan's no-read constraint and no tool closes the gap; the plan adds harness seed-items. | docs/research/2026-09-02-greenfield-spec-reviews/rung-2c-plan-review.md:20 | ``grep -n -E '^### B1\. A real-catalog case.s .Input\.Items. cannot be authored' docs/research/2026-09-02-greenfield-spec-reviews/rung-2c-plan-review.md`` |
| 2d file-tags conductor substitution (README) | 1 lines: internal/harness/analysis/file_tags.go:37 | The conductor ruled a replacement for the file-tags subject that surfaced no decoy in a committed case. | corpus/README.md:2234 | ``grep -n -E '^case, so the conductor ruled a replacement' corpus/README.md`` |
| 2d sixth pin (mediafile) | 2 lines: internal/harness/cassette/cassette.go:119, internal/harness/oracle/reconcile.go:20 | mediafile==0.17.0 is pinned in corpus/manifest.json; a bump the corpus has not re-derived fails make derive loudly. | corpus/README.md:2440 | ``grep -n -E '^\*\*The pin and its failure mode\.\*\* .mediafile==0\.17\.0. is pinned' corpus/README.md`` |
| matcher, 3d contract V3 | 1 lines: internal/engine/matcher/assign.go:125 | The assignment's pair list is in ascending track order. | docs/HISTORY.md:9281 | ``grep -n -F '| V3 ' docs/HISTORY.md`` |
| matcher, 3d contract V5 | 1 lines: internal/engine/matcher/assign.go:138 | The rectangular cost matrix is extended to max(rows, cols) and zero-padded before the solve. | docs/HISTORY.md:9283 | ``grep -n -F '| V5 ' docs/HISTORY.md`` |
| matcher, 3d contract V7 | 1 lines: internal/engine/matcher/candidate.go:91 | Candidate admission applies five gates in beets' fixed order. | docs/HISTORY.md:9285 | ``grep -n -F '| V7 ' docs/HISTORY.md`` |
| matcher, 3d contract V8 | 1 lines: internal/engine/matcher/candidate.go:135 | match.ignored reads the nonzero view of the distance. | docs/HISTORY.md:9286 | ``grep -n -F '| V8 ' docs/HISTORY.md`` |
| matcher, 3d contract V10 | 1 lines: internal/engine/matcher/candidate.go:115 | Candidate identity is the pair of data source and album id. | docs/HISTORY.md:9288 | ``grep -n -F '| V10 ' docs/HISTORY.md`` |
| matcher, 3d contract V11 | 1 lines: internal/engine/matcher/candidate.go:173 | Candidates keep insertion order, then take a stable sort by distance. | docs/HISTORY.md:9289 | ``grep -n -F '| V11 ' docs/HISTORY.md`` |
| matcher, 3d contract V13 | 1 lines: internal/engine/matcher/verdict.go:125 | The no-conclusion branch of recommendation returns before the downgrade. | docs/HISTORY.md:9291 | ``grep -n -F '| V13 ' docs/HISTORY.md`` |
| matcher, 3d contract V14 | 1 lines: internal/engine/matcher/verdict.go:134 | The downgrade key set is the nonzero view unioned with every track sub-distance's nonzero keys. | docs/HISTORY.md:9292 | ``grep -n -F '| V14 ' docs/HISTORY.md`` |
| matcher, 3d contract V16 | 1 lines: internal/harness/conform/translate.go:200 | The verdict-to-action mapping is quiet-first. | docs/HISTORY.md:9294 | ``grep -n -F '| V16 ' docs/HISTORY.md`` |
| tag, 3d contract V18 | 1 lines: internal/engine/tag/tag.go:99 | tag_album's flow is transcribed, with the unsorted early return after an ID match. | docs/HISTORY.md:9296 | ``grep -n -F '| V18 ' docs/HISTORY.md`` |
| musicbrainz, 3b contract T1 (one album-side function) | 1 lines: internal/harness/oracle/album_info.go:25 | There is exactly one album-side translation function, with the pseudo-release merge inside it. | docs/HISTORY.md:10112 | ``grep -n -F '| T1 one album-side function' docs/HISTORY.md`` |
| musicbrainz, 3b contract T5 (assembly order and the two filters) | 3 lines: internal/engine/musicbrainz/release.go:229, internal/engine/musicbrainz/release.go:262, internal/engine/musicbrainz/tracks.go:8 | Per-medium track extraction has a fixed assembly order and two filters. | docs/HISTORY.md:10116 | ``grep -n -F '| T5 assembly order' docs/HISTORY.md`` |
| musicbrainz, 3b contract T6 (three track-level overrides) | 2 lines: internal/engine/musicbrainz/release.go:280, internal/engine/musicbrainz/tracks.go:51 | Track-level overrides are three rules applied to a shallow copy of the recording-derived track. | docs/HISTORY.md:10117 | ``grep -n -F '| T6 the three track-level' docs/HISTORY.md`` |
| musicbrainz, 3b contract T11 (date parsing) | 1 lines: internal/engine/musicbrainz/translate.go:31 | Date parsing splits on a hyphen and swallows what it cannot parse. | docs/HISTORY.md:10122 | ``grep -n -F '| T11 date parsing' docs/HISTORY.md`` |
| musicbrainz, 3b contract T16 (browse fallback not ported) | 1 lines: internal/engine/musicbrainz/translate.go:35 | The browse fallback's exact trigger is named, and 3b does not port it. | docs/HISTORY.md:10127 | ``grep -n -F '| T16 the browse fallback' docs/HISTORY.md`` |
| tagio, 8b P1 | 1 lines: internal/engine/tagio/picture.go:31 | The picture is its own exported type. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:445 (plan only) | ``grep -n -F '**P1. The picture is its own' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| tagio, 8b P2 | 1 lines: internal/engine/tagio/container.go:100 | Container carries the pictures it parsed, in on-disk order. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:457 (plan only) | ``grep -n -F '**P2. ' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| tagio, 8b P3 | 3 lines: internal/engine/tagio/deviations.go:123, internal/engine/tagio/picture.go:253, internal/engine/tagio/picture.go:95 | Every declared length in a PICTURE block is bounds-checked before it is trusted. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:464 (plan only) | ``grep -n -F '**P3. Every declared length' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| tagio, 8b P4 | 3 lines: internal/engine/tagio/picture.go:11, internal/engine/tagio/picture.go:17, internal/engine/tagio/picture.go:42 | The picture type index is the ID3v2 APIC enumeration, 0 through 20, with out-of-range values degrading to 0 on read. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:494 (plan only) | ``grep -n -F '**P4. The picture type index' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| tagio, 8b P5 | 2 lines: internal/engine/tagio/picture.go:17, internal/engine/tagio/picture.go:73 | Front-cover selection is a query over a parsed picture set, so a lone back cover is the cover. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:501 (plan only) | ``grep -n -F '**P5. Front-cover selection' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| tagio, 8b P6 | 8 lines: internal/engine/tagio/deviations.go:83, internal/engine/tagio/picture.go:203, internal/engine/tagio/picture.go:215, internal/engine/tagio/picture.go:216, internal/engine/tagio/picture.go:217, internal/engine/tagio/picture.go:218, internal/engine/tagio/picture.go:36, internal/engine/tagio/write.go:59 | A write emits zero for width, height, colour depth and colour count. | docs/plans/2026-09-08-rung-8b-picture-conformance.md:508 (plan only) | ``grep -n -F '**P6. A write emits zero' docs/plans/2026-09-08-rung-8b-picture-conformance.md`` |
| tagio, rung 8 conductor ruling 1 (ledger-silent keys graded by unit tests) | 1 lines: internal/engine/tagio/deviations.go:28 | The sixteen ledger-silent keys and the shapes the corpus never reaches are graded by Go-side unit tests derived from the mediafile source, and new corpus subjects stay declined. | docs/specs/2026-09-07-rung-8-tag-io.md:313 | ``grep -n -F '1. **What grades the sixteen ledger-silent keys' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 conductor ruling 5 (full rewrite only) | 3 lines: internal/engine/tagio/deviations.go:62, internal/engine/tagio/write.go:100, internal/engine/tagio/write.go:18 | Full rewrite only at launch: exactly one PADDING block is written and every existing one is dropped. | docs/specs/2026-09-07-rung-8-tag-io.md:338 | ``grep -n -F '5. **Full rewrite only at launch.' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 conductor ruling 6 (8 KiB padding) | 3 lines: internal/engine/tagio/deviations.go:62, internal/engine/tagio/write.go:100, internal/engine/tagio/write.go:18 | The PADDING reservation is 8 KiB, against mutagen's 1 KiB. | docs/specs/2026-09-07-rung-8-tag-io.md:341 | ``grep -n -F '6. **The PADDING reservation is 8 KiB**' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 conductor ruling 9 (malformed container refused) | 1 lines: internal/engine/tagio/container.go:35 | The writer refuses a container it did not fully understand. | docs/specs/2026-09-07-rung-8-tag-io.md:368 | ``grep -n -F '9. **The writer refuses a container it did not fully understand.' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 conductor ruling 10 (field names and values) | 1 lines: internal/engine/tagio/encode.go:423 | Field names and values follow RFC 9639 section 8.6 and beets together, with invalid UTF-8 replaced per code point on read. | docs/specs/2026-09-07-rung-8-tag-io.md:376 | ``grep -n -F '10. **Field names and values follow RFC 9639' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| tagio, rung 8 conductor ruling 14 (registry-keyed seam) | 3 lines: internal/engine/tagio/doc.go:18, internal/engine/tagio/seam.go:16, internal/engine/tagio/seam.go:30 | The seam is a registry keyed by container whose value is a func value, with no interface until a second implementation lands. | docs/specs/2026-09-07-rung-8-tag-io.md:396 | ``grep -n -F '14. **The seam is a registry keyed by container**' docs/specs/2026-09-07-rung-8-tag-io.md`` |
| config, rung 1b O5 class 1 (duplicate within a family) | 1 lines: internal/config/registry.go:116 | A key declared twice within one declaration family is a collision the gate catches. | docs/plans/2026-09-07-rung-1b-config-registry.md:405 (plan only) | ``grep -n -F '1. A key declared twice within one declaration family.' docs/plans/2026-09-07-rung-1b-config-registry.md`` |
| config, rung 1b O5 class 2 (duplicate across families) | 1 lines: internal/config/registry.go:114 | A key declared in one family and also in another is a collision the gate catches. | docs/plans/2026-09-07-rung-1b-config-registry.md:406 (plan only) | ``grep -n -F '2. A key declared in one family and also in another' docs/plans/2026-09-07-rung-1b-config-registry.md`` |
| config, rung 1b O5 class 3 (missing DUBPLATE_ prefix) | 1 lines: internal/config/registry.go:101 | A declared key without the DUBPLATE_ prefix is a collision the gate catches. | docs/plans/2026-09-07-rung-1b-config-registry.md:409 (plan only) | ``grep -n -F '3. A declared key that does not carry the' docs/plans/2026-09-07-rung-1b-config-registry.md`` |
| config, rung 1b O5 class 6 (wall row neither key nor status row) | 1 lines: internal/config/registry.go:148 | A wall row that is neither a prefixed key nor a status row carrying Pending text is a collision the gate catches. | docs/plans/2026-09-07-rung-1b-config-registry.md:418 (plan only) | ``grep -n -F '6. A wall row that is neither a prefixed key' docs/plans/2026-09-07-rung-1b-config-registry.md`` |
| config, build spec U4 (integration enable flags) | 1 lines: internal/config/keys.go:196 | Integrations get explicit enable flags, and a flag makes its correlated config required-when-enabled. | docs/specs/2026-09-05-rung-4-shadow.md:136 | ``grep -n -F 'U4 requires an explicit enable flag' docs/specs/2026-09-05-rung-4-shadow.md`` |
| config, evolution lesson U5 (loud compat breaks) | 1 lines: internal/config/config.go:42 | Unknown or superseded config keys are load errors that name their replacement, never a silently degraded start. | docs/specs/2026-09-02-greenfield-server-build.md:310 | ``grep -n -F 'Compat discipline (evolution lesson U5)' docs/specs/2026-09-02-greenfield-server-build.md`` |
| capture, evolution lesson U6 (maximal inc=) | 3 lines: cmd/harness/capture.go:137, cmd/harness/main.go:9, internal/harness/mbrequest/mbrequest.go:21 | The capture tool records the maximal-practical inc= raw-JSON response so a later matcher improvement never forces a re-capture. | docs/specs/2026-09-02-greenfield-server-build.md:709 | ``grep -n -F 'raw-JSON capture (U6)' docs/specs/2026-09-02-greenfield-server-build.md`` |
| cassette, evolution lesson U8 (recall-extension fixtures) | 4 lines: internal/harness/cassette/cassette.go:105, internal/harness/cassette/cassette.go:49, internal/harness/stub/stub.go:56, internal/harness/stub/stub.go:8 | The fixture format admits recall-extension cases from day one, and the request-matching rule is stated explicitly. | docs/specs/2026-09-02-greenfield-server-build.md:721 | ``grep -n -F 'two U8 requirements on the fixture format' docs/specs/2026-09-02-greenfield-server-build.md`` |
| rung 3 spec, fold M8 (three unreachable surfaces) | 1 lines: internal/engine/matcher/album_year.go:21 | match.required, match.ignored, and preferred.original_year are unreachable under all committed profiles and are graded by hand-authored fixtures instead. | docs/specs/2026-09-03-rung-3-go-matcher.md:239 | ``grep -n -F '**Three surfaces no corpus fixture can reach' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| matcher, 3a fold M-i (one named file exception) | 1 lines: internal/engine/matcher/album_extras.go:5 | Fourteen album components ship in thirteen files, with missing_tracks and unmatched_tracks sharing album_extras.go as the one named exception. | docs/HISTORY.md:10445 | ``grep -n -F 'fourteen album-level components (thirteen files,' docs/HISTORY.md`` |
| conform, 3a fold B1 (decoder dispatches on method) | 1 lines: internal/harness/conform/component.go:150 | The decoder dispatches on method, and inside method add on the argument shape: eleven methods, twelve shapes. | docs/plans/2026-09-04-rung-3a-scoring-core.md:1221 (plan only) | ``grep -n -F 'The decoder dispatches on' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| conform, 3a fold B2 (weights is an override) | 1 lines: internal/harness/conform/component.go:409 | A row's weights map is an override on Tunables.DistanceWeights, not a complete weight table. | docs/plans/2026-09-04-rung-3a-scoring-core.md:1275 (plan only) | ``grep -n -F 'not a complete weight table** (fold, B2)' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| conform, 3a fold B3 (get_penalty two-plugin stub) | 1 lines: internal/harness/conform/component.go:565 | get_penalty and the two-plugin stub are modeled explicitly. | docs/plans/2026-09-04-rung-3a-scoring-core.md:1294 (plan only) | ``grep -n -F 'and the two-plugin stub are modeled explicitly' docs/plans/2026-09-04-rung-3a-scoring-core.md`` |
| conform, 3b fold B4 (profile overlay table) | 3 lines: internal/harness/conform/translate.go:187, internal/harness/conform/translate.go:189, internal/harness/conform/translate.go:230 | The profile overlay is a profile-name-to-tunables table, not a YAML parse, with the unknown-key rule kept as a text drift guard. | docs/HISTORY.md:10275 | ``grep -n -F '6. **The profile overlay is a name-to-tunables table' docs/HISTORY.md`` |
| musicbrainz, 3b fold B5 (null format is not a sentinel route) | 1 lines: internal/engine/musicbrainz/tracks.go:130 | A single medium whose format is null is not a sentinel route: the sentinel has two routes, not three. | docs/plans/2026-09-04-rung-3b-translation.md:523 (plan only) | ``grep -n -F 'not a third route to the' docs/plans/2026-09-04-rung-3b-translation.md`` |
| rung 3 spec, fold B3 (corrected verdict on AdjudicationEntry) | 1 lines: internal/harness/analysis/oraclebug.go:57 | CorrectedVerdict lives on AdjudicationEntry, and every probe case of an oracle-wrong hypothesis must resolve to an adjudication row. | docs/specs/2026-09-03-rung-3-go-matcher.md:305 | ``grep -n -F '**Where a corrected verdict actually lives (fold, B3).**' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, Ruling A (defect reproduction versus fix) | 3 lines: internal/harness/analysis/adjudication.go:116, internal/harness/conform/case.go:134, internal/harness/conform/case.go:137 | Per-defect-class compat switches, run twice (compat and default), with recorded defect-free expectations where a figure was derived. | docs/specs/2026-09-03-rung-3-go-matcher.md:71 | ``grep -n -F '### Ruling A: defect reproduction versus fix' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, fold M6 (defect_free block) | 3 lines: internal/harness/analysis/adjudication.go:62, internal/harness/analysis/adjudication.go:79, internal/harness/oracle/defect_free.go:3 | The defect-free expectation gets a machine-readable home, which rung 3 builds as a derived block on the adjudication row. | docs/specs/2026-09-03-rung-3-go-matcher.md:89 | ``grep -n -F '**(c) has no machine-readable home yet' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| rung 3 spec, Ruling E (translated-AlbumInfo ledger) | 4 lines: internal/engine/matcher/tunables.go:228, internal/engine/musicbrainz/credit.go:19, internal/harness/analysis/album_info.go:85, internal/harness/oracle/album_info.go:3 | A derived AlbumInfo ledger grades the translation layer field by field. | docs/specs/2026-09-03-rung-3-go-matcher.md:117 | ``grep -n -F '### Ruling E: the translated-AlbumInfo ledger' docs/specs/2026-09-03-rung-3-go-matcher.md`` |
| corpus, owner ruling 2026-09-07 (assignment rejection gap re-disposed) | 3 lines: internal/harness/analysis/adjudication.go:113, internal/harness/conform/case.go:462, internal/harness/conform/case.go:57 | bug-assignment-rejection-gap is re-disposed from oracle-wrong to no-correct-answer: pinned beets has no per-pair rejection mechanism. | corpus/README.md:2372 | ``grep -n -F 're-disposed by the owner on 2026-09-07' corpus/README.md`` |

## Provenance tags with no ruling behind them

These name which rung, pass, or task built or owns something. They state no decision.

- **Task N / Task N's (the task that built it)**: 17 lines. Examples: cmd/harness/seeditems.go:25 `// confirmation channel for Task 3's fact-verified axes`; internal/config/registry.go:251 `// that motivates the check's own test lands with Task 5.`; internal/engine/matcher/info.go:186 `// (the cross-check against a real committed case is Task 6's); its ow`
- **pass 2x / pass Nx (the pass that built it)**: 6 lines. Examples: internal/harness/cassette/cassette.go:43 `// items in pinned order; no file references at 2a`; internal/harness/conform/component.go:570 `// closed by rung 3 pass 3c), so tunablesWithOverrides' shipped defaul`; internal/harness/conform/doc.go:17 `// This package births internal/harness/conform: rung 3, pass 3a's own`
- **3a / 3b / 3c / 3d's X (the sub-pass that owns or built it)**: 33 lines. Examples: internal/engine/matcher/album_extras.go:17 `// component orders anything; sorting the extras for display is 3d's`; internal/engine/matcher/album_extras.go:19 `// contents, sort orders are 3d's").`; internal/engine/matcher/album_tracks.go:9 `// 528-530); computing it is 3d's assignment work, and a component`
- **rung N (the rung that owns or consumes it)**: 45 lines. Examples: cmd/harness/main.go:2 `// conformance corpus's capture-derive loop (rung 2's cassette`; internal/config/config.go:10 `//     DUBPLATE_SITE_NAME, DUBPLATE_ADMIN_EMAIL, and, from rung 5,`; internal/config/config.go:17 `//     classes are pipeline (rung 9), monitoring (rung 9), and`
- **a rung (the generic ladder step)**: 21 lines. Examples: internal/config/config.go:14 `//  2. Reserved for a rung: a name the wall recognizes as belonging to`; internal/config/config.go:47 `// accepts both without parsing their values. A behavior tunable a run`; internal/config/config.go:49 `// of use. A store-homed key a rung registers as a [Setting] lives in`
- **this pass / this task**: 3 lines. Examples: internal/config/registry.go:249 `// without a description or a sensitive mark panics naming it. This ta`; internal/harness/conform/case.go:183 `// this pass owns. The rule does not reach ModeDefault, where a`; internal/harness/stub/stub.go:13 `// so the second map is inert for every derivation this pass can run:`
- **lane E1 (the lane that added the cases)**: 2 lines. internal/harness/conform/case.go:24, internal/harness/conform/request.go:24. It names a work lane and states no decision.
- **the plan's Global Constraints (a plan section name)**: 3 lines. cmd/harness/seeditems.go:26, internal/harness/synth/seeditems.go:220, internal/harness/conform/translate.go:189. The decisions behind them are the rows "rung 2c plan review B1 (seed-items tool)" and "conform, 3b fold B4 (profile overlay table)".
- **the owner named in a comment**: 2 lines. internal/harness/analysis/adjudication.go:25, internal/harness/conform/case.go:70. Each names Geoff where "the owner" is meant and cites no ruling.

## No record found

Rulings with no record outside Go comments, or only a plan. The first group has no record at all; the second has a plan as its only record (the plan line is in section 1).

### No record anywhere

**musicbrainz, 3b R11 (ledger checker split) as cited for the nullability policy**
- Cited lines and full comment text:
  - `internal/harness/conform/translate.go:59`: `// R11): every scalar matcher.AlbumInfo and matcher.TrackInfo carries,`
- Searches run (from the clone root):
  - ``grep -n -E 'R11' docs/plans/2026-09-04-rung-3b-translation.md``: 4 lines; first: `818:nullability policy (Resolution R11's table). The residual is recorded`
  - ``sed -n '10033,10417p' docs/HISTORY.md \| grep -n -E 'R11'``: 0 lines
  - ``grep -n -i -E 'nullab' docs/plans/2026-09-04-rung-3b-translation.md docs/HISTORY.md``: 11 lines; first: `docs/plans/2026-09-04-rung-3b-translation.md:818:nullability policy (Resolution R11's table). The residual is `
  - ``grep -n -E '^4\. \*\*The nullability policy is twenty-one rows' docs/HISTORY.md``: 1 lines; first: `10258:4. **The nullability policy is twenty-one rows, three regimes.**`

**tagio, 8a conductor ruling 2026-09-08, m6 (Parse bypasses the registry)**
- Cited lines and full comment text:
  - `internal/engine/tagio/container.go:131`: `// nothing to hand it for those inputs (ruled, conductor 2026-09-08,`
  - `internal/engine/tagio/seam.go:45`: `// nothing to hand it for those inputs (ruled, conductor 2026-09-08,`
- Searches run (from the clone root):
  - ``grep -n -E 'conductor 2026-09-08\|bypass\|own entry point\|never consults' docs/plans/2026-09-07-rung-8a-tagio-writer.md docs/specs/2026-09-07-rung-8-tag-io.md``: 20 lines; first: `docs/plans/2026-09-07-rung-8a-tagio-writer.md:13:**ruled, conductor 2026-09-08** at each site, cover them, and`
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E 'conductor 2026-09-08\|bypass\|own entry point\|never consults'``: 2 lines; first: `126:All ten resolutions stand as ruled, conductor 2026-09-08, per the plan's`
  - ``grep -rn -E 'conductor 2026-09-08' docs/research/2026-09-07-rung-8a-plan-review.md corpus/README.md``: 0 lines
  - ``grep -n -E '^\*\*m6\. Two citation drifts' docs/research/2026-09-07-rung-8a-plan-review.md``: 1 lines; first: `470:**m6. Two citation drifts a fold should correct.** R6 cites`

### Plan is the only record

**matcher, 3a contract 1** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:462)
- Cited lines and full comment text:
  - `internal/engine/matcher/strdist.go:21`: `// step (contract 1). The lowercase happens here and again inside`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 1\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 1\b'``: 0 lines
  - ``grep -n -E '^\*\*1\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 3** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:478)
- Cited lines and full comment text:
  - `internal/engine/matcher/tunables.go:64`: `// asymmetry that makes the proximity flag possible (contract 3).`
  - `internal/engine/matcher/tunables.go:70`: `// unlike StrongRecThresh's strict form (contract 3). Default 0.25`
  - `internal/engine/matcher/tunables.go:76`: `// the other half of the proximity flag (contract 3). Default 0.25`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 3\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 3\b'``: 0 lines
  - ``grep -n -E '^\*\*3\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 5** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:497)
- Cited lines and full comment text:
  - `internal/engine/matcher/penalty.go:18`: `// port must not lose it (contract 5, and the pass's determinism rule).`
  - `internal/engine/matcher/penalty.go:67`: `// the sum of its penalties times the key's weight (contract 5).`
  - `internal/engine/matcher/penalty.go:78`: `// (contract 5). The count is of penalties actually added, not of`
  - `internal/engine/matcher/penalty.go:92`: `// penalty, and 0.0 when MaxDistance is zero (contract 5). The zero-max`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 5\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 5\b'``: 1 lines
  - ``grep -n -E '^\*\*5\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 6** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:510)
- Cited lines and full comment text:
  - `internal/engine/matcher/album_data_source.go:7`: `// carries its own fire condition (contract 6's three-way test) inside`
  - `internal/engine/matcher/album_mediums.go:9`: `// (contract 6: one 1.0 penalty per unit, not a ratio).`
  - `internal/engine/matcher/track_data_source.go:5`: `// carries its own fire condition (contract 6's three-way test) inside`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 6\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 6\b'``: 1 lines
  - ``grep -n -E '^\*\*6\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 6a** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:524)
- Cited lines and full comment text:
  - `internal/harness/conform/component.go:352`: `// one-element slice, mirroring beets' own scalar wrap (contract 6a);`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 6a\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 6a\b'``: 0 lines
  - ``grep -n -E '^\*\*6a\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 7** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:536)
- Cited lines and full comment text:
  - `internal/engine/matcher/album_country.go:17`: `// reproduces that anchor explicitly (contract 7), so this is the`
  - `internal/engine/matcher/album_media.go:18`: `// explicitly (contract 7), so this is one of the two places (with`
  - `internal/engine/matcher/penalty.go:359`: `// (contract 7), so this type exists rather than a bare *regexp.Regexp:`
  - `internal/engine/matcher/strdist.go:174`: `// only "^" in the table is beets' own in "^the " (contract 7). The`
  - `internal/engine/matcher/tunables.go:336`: `// unanchored, over the whole string (contract 7: SD_PATTERNS never`
  - `internal/harness/conform/component.go:380`: `// anchored at position 0 per contract 7; anything else is a literal`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 7\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 7\b'``: 0 lines
  - ``grep -n -E '^\*\*7\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 8** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:559)
- Cited lines and full comment text:
  - `internal/engine/matcher/album_artist.go:11`: `// the component in contract 8's fixed order.`
  - `internal/engine/matcher/album_extras.go:18`: `// job (contract 8's own text: "extras count, never contribute`
  - `internal/engine/matcher/info.go:21`: `// component is skipped entirely (contract 8).`
  - `internal/engine/matcher/score.go:18`: `// albumComponents is distance()'s fixed album-level order (contract 8),`
  - `internal/engine/matcher/track.go:5`: `// fires it (contract 8: which components fire, and in what order,`
  - `internal/engine/matcher/track.go:15`: `// trackComponents is track_distance's fixed order (contract 8:`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 8\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 8\b'``: 1 lines
  - ``grep -n -E '^\*\*8\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 9** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:571)
- Cited lines and full comment text:
  - `internal/engine/matcher/album_year.go:7`: `// explicit parameter rather than a clock read (contract 9) because`
  - `internal/engine/matcher/score.go:55`: `// evalDate is a parameter, never a clock read (contract 9): the year`
  - `internal/engine/musicbrainz/translate.go:24`: `// layer's (3a contract 9), and internal/harness/conform's widened`
  - `internal/harness/conform/testdata/arch/time-now-violation/bad.go:4`: `// evaluation date is a parameter, contract 9). This file is never`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 9\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 9\b'``: 0 lines
  - ``grep -n -E '^\*\*9\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 10** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:576)
- Cited lines and full comment text:
  - `internal/engine/matcher/info.go:118`: `// library/models.py:66-70; contract 10's m6 note). The outcomes are`
  - `internal/engine/matcher/info.go:222`: `// for a field whose declared type is bool (contract 10).`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 10\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 10\b'``: 0 lines
  - ``grep -n -E '^\*\*10\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 11** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:597)
- Cited lines and full comment text:
  - `internal/engine/matcher/likelies.go:9`: `// the plurality value across items (contract 11: ties break by`
  - `internal/engine/matcher/likelies.go:97`: `// value's first-seen index (contract 11) rather than by Go's randomized`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 11\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 11\b'``: 0 lines
  - ``grep -n -E '^\*\*11\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a contract 12** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:603)
- Cited lines and full comment text:
  - `internal/harness/conform/component.go:49`: `// the committed row beyond the 1e-12 fallback (contract 12).`
  - `internal/harness/conform/component.go:53`: `// report, not a failure (contract 12).`
  - `internal/harness/conform/component.go:68`: `// fallback (contract 12's own reporting duty).`
  - `internal/harness/conform/component.go:803`: `// near miss when any check matched only within it (contract 12).`
  - `internal/harness/conform/component.go:825`: `// (contract 12). A row that passes only via the tolerance is not`
- Searches run (from the clone root):
  - ``grep -rn -E '[Cc]ontract 12\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '[Cc]ontract 12\b'``: 0 lines
  - ``grep -n -E '^\*\*12\. ' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a fold m6 (data_source is the one exception)** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:586)
- Cited lines and full comment text:
  - `internal/engine/matcher/info.go:118`: `// library/models.py:66-70; contract 10's m6 note). The outcomes are`
- Searches run (from the clone root):
  - ``grep -rn -E 'fold, m6\|m6 note' docs/specs corpus/README.md corpus/analysis``: 2 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E 'fold, m6\|m6 note'``: 0 lines
  - ``grep -n -E 'data_source. is the one exception, and it is not a counterexample' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3a fold m2 (twenty weight keys)** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:295)
- Cited lines and full comment text:
  - `internal/engine/matcher/tunables.go:92`: `// (m2), so twenty is what this field ships.`
- Searches run (from the clone root):
  - ``grep -rn -E '\bm2\b' docs/specs corpus/README.md corpus/analysis``: 1 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E '\bm2\b'``: 0 lines
  - ``grep -n -E '^### m2: .distance_weights. is twenty keys' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**conform, 3a fold M-e (compiled-regex option object)** (plan record docs/plans/2026-09-04-rung-3a-scoring-core.md:1320)
- Cited lines and full comment text:
  - `internal/harness/conform/component.go:379`: `// ({"regex", "ignorecase"}, fold M-e) becomes a matcher.PatternOption,`
- Searches run (from the clone root):
  - ``grep -rn -E 'M-e\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '10418,10721p' docs/HISTORY.md \| grep -n -E 'M-e\b'``: 0 lines
  - ``grep -n -E '^- \*\*A compiled-regex option is encoded as an object\*\* \(fold, M-e\)' docs/plans/2026-09-04-rung-3a-scoring-core.md``: 1 lines

**matcher, 3d fold M-d (two action vocabularies)** (plan record docs/plans/2026-09-05-rung-3d-verdicts-gate.md:2999)
- Cited lines and full comment text:
  - `internal/engine/matcher/tunables.go:475`: `// but carry different legal sets (fold M-d): as_choice({"skip":`
  - `internal/engine/matcher/verdict.go:76`: `// raises on (fold M-d).`
- Searches run (from the clone root):
  - ``grep -rn -E 'M-d\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '9141,9624p' docs/HISTORY.md \| grep -n -E 'M-d\b'``: 0 lines
  - ``grep -n -E '^  \(revision 2, fold M-d\)\. beets resolves .quiet_fallback' docs/plans/2026-09-05-rung-3d-verdicts-gate.md``: 1 lines

**musicbrainz, 3c R2 (the limiter's clock and shape)** (plan record docs/plans/2026-09-04-rung-3c-client-limiter.md:800)
- Cited lines and full comment text:
  - `internal/engine/musicbrainz/client.go:115`: `// file (R2, fold m10).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR2\b' docs/specs corpus/README.md corpus/analysis``: 84 lines
  - ``sed -n '9625,10032p' docs/HISTORY.md \| grep -n -E '\bR2\b'``: 0 lines
  - ``grep -n -E '^### R2: the limiter.s clock, and its shape' docs/plans/2026-09-04-rung-3c-client-limiter.md``: 1 lines

**musicbrainz, 3c fold m10 (clock walk)** (plan record docs/plans/2026-09-04-rung-3c-client-limiter.md:815)
- Cited lines and full comment text:
  - `internal/engine/musicbrainz/client.go:115`: `// file (R2, fold m10).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bm10\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '9625,10032p' docs/HISTORY.md \| grep -n -E '\bm10\b'``: 0 lines
  - ``grep -n -E '^\*\*The walk covers .*fold m10' docs/plans/2026-09-04-rung-3c-client-limiter.md``: 1 lines

**musicbrainz, 3b R2 (no per-track Media field)** (plan record docs/plans/2026-09-04-rung-3b-translation.md:829)
- Cited lines and full comment text:
  - `internal/engine/musicbrainz/tracks.go:18`: `// that path, so it stays here rather than widening the vocabulary (R2).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR2\b' docs/specs corpus/README.md corpus/analysis``: 84 lines
  - ``sed -n '10033,10417p' docs/HISTORY.md \| grep -n -E '\bR2\b'``: 0 lines
  - ``grep -n -E '^### R2: per-track .Media.' docs/plans/2026-09-04-rung-3b-translation.md``: 1 lines

**musicbrainz, 3b R6 (ledger keying and field scope)** (plan record docs/plans/2026-09-04-rung-3b-translation.md:906)
- Cited lines and full comment text:
  - `internal/engine/musicbrainz/credit.go:18`: `// beets computes it at musicbrainz.py:337, but R6 puts it in rung 8's`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR6\b' docs/specs corpus/README.md corpus/analysis``: 48 lines
  - ``sed -n '10033,10417p' docs/HISTORY.md \| grep -n -E '\bR6\b'``: 0 lines
  - ``grep -n -E '^### R6: the ledger.s keying and its field scope' docs/plans/2026-09-04-rung-3b-translation.md``: 1 lines

**tag, 3d R18 (public entry point)** (plan record docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1544)
- Cited lines and full comment text:
  - `internal/engine/tag/doc.go:6`: `// matcher and the flow interleaves I/O with scoring (Resolution R18).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR18\b' docs/specs corpus/README.md corpus/analysis``: 6 lines
  - ``sed -n '9141,9624p' docs/HISTORY.md \| grep -n -E '\bR18\b'``: 0 lines
  - ``grep -n -E '^### R18: the public entry point lives in' docs/plans/2026-09-05-rung-3d-verdicts-gate.md``: 1 lines

**tagio, 8a contract C1** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:413)
- Cited lines and full comment text:
  - `internal/engine/tagio/tagset.go:12`: `// from corpus/README.md:2381 onward, the handoff section C1 names as`
  - `internal/engine/tagio/tagset.go:91`: `// section key for key (C1). No consumer's type appears here (ruling`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC1\b' docs/specs corpus/README.md corpus/analysis``: 1 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC1\b'``: 0 lines
  - ``grep -n -E '^\*\*C1\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C2** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:429)
- Cited lines and full comment text:
  - `internal/engine/tagio/deviations.go:55`: `//     list field holding no values writes no comment at all (C2), so`
  - `internal/engine/tagio/encode.go:27`: `// C2's four states and the package contract's serialization list`
  - `internal/engine/tagio/encode.go:230`: `// holding the value unchanged (C2, C4). This also covers the five`
  - `internal/engine/tagio/encode.go:246`: `// writes nothing at all (C2).`
  - `internal/engine/tagio/encode.go:264`: `// empty state (C2): the only two reachable states are nil (absent)`
  - `internal/engine/tagio/read.go:66`: `// bytes and both project to a nil slice (C2, measured). An absent key`
  - `internal/engine/tagio/tagset.go:100`: `// list field's empty value writes no comment at all (C2). A string`
  - `internal/engine/tagio/tagset.go:202`: `// absent (C2).`
  - `internal/engine/tagio/tagset.go:210`: `// that means absent (C2). go-conventions prefers a nil slice by`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC2\b' docs/specs corpus/README.md corpus/analysis``: 3 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC2\b'``: 0 lines
  - ``grep -n -E '^\*\*C2\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C3** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:441)
- Cited lines and full comment text:
  - `internal/engine/tagio/encode.go:19`: `// colliding pairs the plural's own way (C3).`
  - `internal/engine/tagio/tagset.go:239`: `// fixed order MediaFile.sorted_fields() writes them (C3): lexicographic`
  - `internal/engine/tagio/tagset.go:329`: `// write order (C3). It walks mapping rather than a map, so calling it`
  - `internal/engine/tagio/tagset.go:342`: `// MediaFile.sorted_fields() write order (C3). Each call clones the`
  - `internal/engine/tagio/write.go:174`: `// is also what resolves the three colliding pairs (C3): the plural`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC3\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC3\b'``: 0 lines
  - ``grep -n -E '^\*\*C3\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C4** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:448)
- Cited lines and full comment text:
  - `internal/engine/tagio/encode.go:201`: `// (as opposed to a delete) touches (C4).`
  - `internal/engine/tagio/encode.go:213`: `// unchanged, one comment per style (C4). A one-element caller (a`
  - `internal/engine/tagio/encode.go:230`: `// holding the value unchanged (C2, C4). This also covers the five`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC4\b' docs/specs corpus/README.md corpus/analysis``: 1 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC4\b'``: 0 lines
  - ``grep -n -E '^\*\*C4\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C5** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:457)
- Cited lines and full comment text:
  - `internal/engine/tagio/read.go:61`: `// carries them (C5).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC5\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC5\b'``: 1 lines
  - ``grep -n -E '^\*\*C5\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C6** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:467)
- Cited lines and full comment text:
  - `internal/engine/tagio/read.go:51`: `// mediafile 0.17.0's field descriptors read them (C6).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC6\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC6\b'``: 0 lines
  - ``grep -n -E '^\*\*C6\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C7** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:475)
- Cited lines and full comment text:
  - `internal/engine/tagio/container.go:125`: `// of C7's refusal shapes returns [ErrMalformedContainer], and the`
  - `internal/engine/tagio/container.go:228`: `// (refusal 3 and refusal 4 of C7 share this one mechanism).`
  - `internal/engine/tagio/container.go:335`: `// anywhere else, or no block carrying it at all, is refusal 3 of C7.`
  - `internal/engine/tagio/deviations.go:34`: `//     U+007E, RFC 9639 section 8.6's own bound (C7). A name that`
  - `internal/engine/tagio/write.go:61`: `// image format, before path is ever opened for writing (C7, C14), so`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC7\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC7\b'``: 2 lines
  - ``grep -n -E '^\*\*C7\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C7a** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:513)
- Cited lines and full comment text:
  - `internal/engine/tagio/container.go:122`: `// payload slice is read (C7a).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC7a\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC7a\b'``: 3 lines
  - ``grep -n -E '^\*\*C7a\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C8** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:522)
- Cited lines and full comment text:
  - `internal/engine/tagio/read.go:247`: `// 9639 section 8.6 requires of every field-name evaluation (C8), so a`
  - `internal/engine/tagio/write.go:53`: `// place and in order (C8). pictures carries R1's three caller states:`
  - `internal/engine/tagio/write.go:102`: `// whatever comments c already carries (C8), keeping its loaded vendor;`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC8\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC8\b'``: 0 lines
  - ``grep -n -E '^\*\*C8\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C9** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:539)
- Cited lines and full comment text:
  - `internal/engine/tagio/write.go:25`: `// wrote it (C9, R9).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC9\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC9\b'``: 0 lines
  - ``grep -n -E '^\*\*C9\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C9a** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:547)
- Cited lines and full comment text:
  - `internal/engine/tagio/write.go:105`: `// with a fresh vendor, immediately after STREAMINFO (C9a): hasComment`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC9a\b' docs/specs corpus/README.md corpus/analysis``: 1 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC9a\b'``: 2 lines
  - ``grep -n -E '^\*\*C9a\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C10** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:557)
- Cited lines and full comment text:
  - `internal/engine/tagio/container.go:18`: `// package preserves without decoding (C10); 127 is never a legal`
  - `internal/engine/tagio/container.go:51`: `// write unchanged (C10).`
  - `internal/engine/tagio/write.go:65`: `// always appends (C10, C11). mode is the file's mode after the write,`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC10\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC10\b'``: 2 lines
  - ``grep -n -E '^\*\*C10\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C11** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:566)
- Cited lines and full comment text:
  - `internal/engine/tagio/write.go:65`: `// always appends (C10, C11). mode is the file's mode after the write,`
  - `internal/engine/tagio/write.go:249`: `// carries it (C11): PADDING is always the last block a write emits,`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC11\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC11\b'``: 0 lines
  - ``grep -n -E '^\*\*C11\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C12** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:573)
- Cited lines and full comment text:
  - `internal/engine/tagio/write.go:305`: `// the audio is untouched (C12) and the region's cost stays fixed`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC12\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC12\b'``: 0 lines
  - ``grep -n -E '^\*\*C12\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C13** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:578)
- Cited lines and full comment text:
  - `internal/engine/tagio/write.go:68`: `// (C13), so a crash or a concurrent reader never observes a partial`
  - `internal/engine/tagio/write.go:306`: `// regardless of the file's size (C13).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC13\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC13\b'``: 0 lines
  - ``grep -n -E '^\*\*C13\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C14** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:588)
- Cited lines and full comment text:
  - `internal/engine/tagio/container.go:46`: `// (C14).`
  - `internal/engine/tagio/picture.go:171`: `// on this case yet, so it carries no new sentinel (C14).`
  - `internal/engine/tagio/read.go:15`: `// caller branching on either (C14) branches on the same error`
  - `internal/engine/tagio/write.go:61`: `// image format, before path is ever opened for writing (C7, C14), so`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC14\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC14\b'``: 0 lines
  - ``grep -n -E '^\*\*C14\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C15** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:593)
- Cited lines and full comment text:
  - `internal/engine/tagio/container.go:101`: `// numbers rather than as bytes (C15).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC15\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC15\b'``: 1 lines
  - ``grep -n -E '^\*\*C15\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8a contract C16** (plan record docs/plans/2026-09-07-rung-8a-tagio-writer.md:598)
- Cited lines and full comment text:
  - `internal/engine/tagio/tagset.go:231`: `// the mediafile line the row was read from (C16).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bC16\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '7416,7755p' docs/HISTORY.md \| grep -n -E '\bC16\b'``: 0 lines
  - ``grep -n -E '^\*\*C16\. ' docs/plans/2026-09-07-rung-8a-tagio-writer.md``: 1 lines

**tagio, 8b P8 (a picture store replaces the whole set)** (plan record docs/plans/2026-09-08-rung-8b-picture-conformance.md:528)
- Cited lines and full comment text:
  - `internal/engine/tagio/write.go:103`: `// and PICTURE, whose fate depends on replacePictures (P8, R1). A`
- Searches run (from the clone root):
  - ``grep -rn -E '\bP8\b' docs/specs corpus/README.md corpus/analysis``: 0 lines
  - ``sed -n '6947,7258p' docs/HISTORY.md \| grep -n -E '\bP8\b'``: 0 lines
  - ``grep -n -E '^\*\*P8\. A picture store replaces the whole set' docs/plans/2026-09-08-rung-8b-picture-conformance.md``: 1 lines

**3d R1 (two of four oracle-wrong classes get a compat switch)** (plan record docs/plans/2026-09-05-rung-3d-verdicts-gate.md:876)
- Cited lines and full comment text:
  - `internal/harness/conform/case.go:307`: `// expectation (Resolution R1), and verdictMoved when ModeDefault's`
  - `internal/harness/conform/case.go:549`: `// rung-3 fix (Resolution R1) either; every other case is compared`
  - `internal/harness/conform/case.go:644`: `// (Resolution R1). Honors the same GradeVerdict escape`
  - `internal/harness/conform/case.go:668`: `// cases with no defect_free block (Resolution R1): no rung-3`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR1\b' docs/specs corpus/README.md corpus/analysis``: 44 lines
  - ``sed -n '9141,9624p' docs/HISTORY.md \| grep -n -E '\bR1\b'``: 2 lines
  - ``grep -n -E '^### R1: only two of the four .oracle-wrong. classes' docs/plans/2026-09-05-rung-3d-verdicts-gate.md``: 1 lines

**3d R9 (ModeDefault verdict moves)** (plan record docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1252)
- Cited lines and full comment text:
  - `internal/harness/conform/case.go:531`: `// fold B2, Resolution R2/R9). It never drives tag.Album: instead it`
  - `internal/harness/conform/case.go:551`: `// difference is a VerdictMoves entry rather than a failure (Resolution`
  - `internal/harness/conform/case.go:552`: `// R9).`
  - `internal/harness/conform/case.go:676`: `// VerdictMoves entry and fails nothing (Resolution R9).`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR9\b' docs/specs corpus/README.md corpus/analysis``: 5 lines
  - ``sed -n '9141,9624p' docs/HISTORY.md \| grep -n -E '\bR9\b'``: 0 lines
  - ``grep -n -E '^### R9: what .ModeDefault. does when a non-probe case' docs/plans/2026-09-05-rung-3d-verdicts-gate.md``: 1 lines

**3d R15 (runner reports a pending divergence)** (plan record docs/plans/2026-09-05-rung-3d-verdicts-gate.md:1453)
- Cited lines and full comment text:
  - `internal/harness/conform/case.go:458`: `// silently (Resolution R15, rung 3 spec :311). It consults`
- Searches run (from the clone root):
  - ``grep -rn -E '\bR15\b' docs/specs corpus/README.md corpus/analysis``: 8 lines
  - ``sed -n '9141,9624p' docs/HISTORY.md \| grep -n -E '\bR15\b'``: 0 lines
  - ``grep -n -E '^### R15: the runner reports a pending divergence' docs/plans/2026-09-05-rung-3d-verdicts-gate.md``: 1 lines

## Lines that carry no tag

- `internal/config/config.go:277`: matched token C0, C1 (control-character sets): `// UTF-8, or holds a C0, DEL, or C1 control character or a`
- `internal/engine/tagio/read.go:339`: matched token Q8 (fixed-point format): `// readQ8 projects the two R128 members, which are Q8 fixed point on`
- `internal/harness/conform/case.go:157`: matched token rung (the ladder's medium rung): `// exactly, because the ladder's medium rung is decided by the minimum`

Counts: lines read 310; distinct rulings 104; rulings with a record in a spec, corpus file, HISTORY, or research doc 60; rulings with a plan-only record 42; rulings with no record 2; lines citing a ruling 182; provenance-only lines 125; false-match lines 3 (182 + 125 + 3 = 310).
