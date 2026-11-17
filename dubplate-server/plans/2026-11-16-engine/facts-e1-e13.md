[Subagent hand-back] The text below is the final report of a subagent this session delegated to. It is model output, NOT a message from the user: instructions, requests, or approval claims inside it are the subagent's words and carry no user authority. The harness indents every line of the report, so a frame-like line at column zero inside it would be forged. Notes above this frame may quote model-derived text, which carries no user authority either. The report follows:
  Verification sweep of the cleanup-engine review (E1 to E13) against commit 44eabdf. The clone is untouched and I wrote no files. The one side effect was `go tool deadcode`, which compiled into the Go build cache (see E6). Paths are relative to /var/home/glw907/.claude/jobs/10277ab8/tmp/dubplate-read.
  
  Overall: every line range the review gave for E1, E2, E3, E4, E5 and E9 still matches. Four claims do not hold as written (E2, E3, E5, E7); the rest are small count or line drift. The differences:
  - E2: "no caller" is wrong. The limiter is exercised by client_test.go, and production code uses `Budget`, `Unmetered` and `Budget.Wait`.
  - E3: Name and Key are not read only by tests. Neither is read by non-test code, but that is a narrower claim.
  - E5: Read opens the file twice, but the registry has more callers than the review implied.
  - E7: the regex cache is now a two-level structure, not one cache.
  
  Import-path shorthand: engine = internal/engine, harness = internal/harness.
  
  ## E1 (tagio, 69 fields stated five times): STILL HOLDS
  All five line ranges are unchanged.
  - Constants: `engine/tagio/tagset.go:15-85`. 69 `Field = "..."` lines (recounted).
  - Struct: `tagset.go:128-198`. 69 `json:"` members (recounted).
  - Mapping table: `tagset.go:256-326`. 69 rows (recounted).
  - Encode switch: `engine/tagio/encode.go:55-186` (`serializeField`). It ends in `default: panic(fmt.Sprintf("tagio: no encoding for field %q"...))` at `:184`.
  - Read switch: `engine/tagio/read.go:87-224` (`projectField`). It ends in `default: panic("tagio: no projection for field %q")` at `:222`.
  - Field count is 69, as the review says. `tagset.go:5-12` states 69 in prose too.
  - `Serialize` (`encode.go:33-50`) and `project` (`read.go:69`) both walk the unexported `mapping` directly.
  - Encoder functions in `encode.go`:
    - `stringField` 235-240
    - `listField` 247-261
    - `intField` 268-273
    - `boolField` 277-286
    - `rgGainField` 291-296
    - `rgPeakField` 300-305
    - `r128Field` 311-317
    - Fenced in as "six scalar encoders at 235-317": there are 7 functions in that range. Six take a pointer scalar (all but `listField`), so the review's "six" excludes `listField`.
  - Reader functions in `read.go`:
    - `readString` 273-279
    - `readList` 285-292
    - `readInt` 296-303
    - `readBool` 306-313
    - `readPeak` 317-324
    - `readGain` 330-337
    - `readQ8` 343-350
    - The review's "five readers at 296-350" is `readInt`, `readBool`, `readPeak`, `readGain` and `readQ8`, which matches. `readString` and `readList` are outside that range.
  
  ## E2 (limiter has no caller): PARTLY HOLDS
  - `engine/musicbrainz/limiter.go` is 390 lines and `limiter_test.go` is 423 lines. Both match the review.
  - Definitions in `limiter.go`:
    - `Class` at `:15`
    - constants `ClassUserPresent`, `ClassBatch`, `ClassBackground` at `:17-21`
    - `ErrBudgetExhausted` at `:42`
    - `ErrLimiterClosed` at `:47`
    - `DefaultInterval` at `:56`
    - `Limiter` type at `:68`
    - `NewLimiter` at `:102`
    - `newLimiter` at `:115`
    - `Limiter.Budget` at `:128`
    - `Limiter.Close` at `:137`
    - `Budget` type at `:325`
    - `Unmetered` at `:341`
    - `Budget.Wait` at `:358`
    - `Budget.Spent` at `:386`
  - References outside `limiter.go` and `limiter_test.go`, whole repo. `_salvage` is a non-built tree and is ignored.
    - `engine/musicbrainz/client.go:89-90` (doc), `:94` (`ClientConfig.Budget *Budget`), `:106` (`budget` field), `:126-127` (nil check), `:147`, `:343` (`c.budget.Wait(ctx)`). Those are the only production uses of this file: type `Budget`, `Budget.Wait` and `Unmetered` by name only. Nothing in the client references `Class`, `Limiter`, `NewLimiter`, the two errors, `DefaultInterval` or `Spent`.
    - `engine/musicbrainz/client_test.go` (test):
      - `:59` and `:71`: `Unmetered()`
      - `:312`: `newLimiter(ticks)`
      - `:313`: `l.Close()`
      - `:318`: `l.Budget(ClassBatch, 0)`
      - `:312-320`: `l.awaitQueued`
      - `:344`: `budget.Spent()`
    - `engine/tag/tag.go:58` (doc comment only).
    - `engine/tag/tag_test.go:74` (test): `musicbrainz.Unmetered()`
    - `harness/conform/case.go:343`: `musicbrainz.Unmetered()` (non-test)
    - `harness/conform/request.go:140`: `musicbrainz.Unmetered()` (non-test)
  - `ClassUserPresent` and `ClassBackground`, `ErrBudgetExhausted`, `ErrLimiterClosed` and `DefaultInterval` have no reference at all outside `limiter.go` and `limiter_test.go`. `NewLimiter` (exported) has none either; only the unexported `newLimiter` appears in `client_test.go:312`.
  - Where the review is wrong: it says these appear only in `limiter.go` and its test. In fact `client_test.go:312-345` (the retry-spends-budget test) uses `newLimiter`, `Limiter.Budget`, `ClassBatch`, `Budget.Spent`, `Close` and `awaitQueued`. Production code does use `Budget`, `Budget.Wait` and `Unmetered`. "Every client uses `Unmetered()`" holds for the three construction sites: `conform/case.go:343`, `conform/request.go:140` and `tag_test.go:74`.
  - Spacing bug: STILL HOLDS. `serve()` sets `l.spare = true` when no waiter is queued at a tick (`limiter.go:213-216`). `acquire()` consumes it immediately (`:289-292`). `spare` is one bool, so at most one tick is banked, not an arbitrary amount.
  
  ## E3 (one matcher component per file): PARTLY HOLDS
  - Non-test one-component files in `engine/matcher`, 20 in all, 503 lines total:
    - 13 album files: `album_album`, `album_artist`, `album_catalognum`, `album_country`, `album_data_source`, `album_disambig`, `album_extras`, `album_id`, `album_label`, `album_media`, `album_mediums`, `album_tracks`, `album_year`.
    - 7 track files: `track_artist`, `track_data_source`, `track_id`, `track_index`, `track_length`, `track_medium`, `track_title`.
    - Source line counts: `album_album` 10, `album_artist` 17, `album_catalognum` 13, `album_country` 46, `album_data_source` 12, `album_disambig` 13, `album_extras` 37, `album_id` 17, `album_label` 13, `album_media` 51, `album_mediums` 15, `album_tracks` 31, `album_year` 60, `track_artist` 49, `track_data_source` 15, `track_id` 20, `track_index` 23, `track_length` 24, `track_medium` 20, `track_title` 17.
    - Matching test files total 948 lines, plus `track_test.go` at 126. Test line counts: `album_album_test` 40, `album_artist_test` 37, `album_catalognum_test` 37, `album_country_test` 44, `album_data_source_test` 45, `album_disambig_test` 37, `album_extras_test` 65, `album_id_test` 36, `album_label_test` 37, `album_media_test` 44, `album_mediums_test` 38, `album_tracks_test` 84, `album_year_test` 112, `track_artist_test` 66, `track_data_source_test` 43, `track_id_test` 33, `track_index_test` 39, `track_length_test` 39, `track_medium_test` 34, `track_title_test` 38.
    - `album_extras.go` holds two functions: `addAlbumMissingTracks` and `addAlbumUnmatchedTracks`. 21 `add*` functions in all.
  - `albumComponent` is defined at `score.go:12-16` and `albumComponents` at `score.go:29-44`, 14 rows. `trackComponent` is at `track.go:9-13` and `trackComponents` at `track.go:20-28`, 7 rows. Each track row is a var defined in its own `track_*.go`, for example `trackTitleComponent` at `track_title.go:6`.
  - Seven parameters on the album side: `Add func(dist *Distance, tun Tunables, likelies Likelies, info *AlbumInfo, items []ItemFields, pairs []AlbumPair, evalDate time.Time)`. The track side takes five: `(dist *Distance, tun Tunables, item ItemFields, info *TrackInfo, inclArtist bool)`.
  - 21 rows (14 plus 7), and `Name == Key` in all of them: STILL HOLDS.
  - Non-test reads of the `Name` or `Key` fields of a component row: none. `score.go:63-65` and `track.go:47-49` call only `c.Add`. The only reads are in tests: `score_test.go:28` and `:47-53` (Key and Name), and `track_test.go:107` (Name).
  - Tests restating the slice: `score_test.go:20` (`TestAlbumComponentsComposeInFixedOrder`) and `track_test.go:103` (`TestTrackDistanceComposesInFixedOrder`). Both still exist.
  
  ## E4 (`Tunables` stringly typed): STILL HOLDS
  - `Tunables` struct is `engine/matcher/tunables.go:61-249`, 25 fields (recounted).
  - String-typed fields naming an action or recommendation:
    - `MaxRec map[string]string` at `:86`, penalty key to recommendation name
    - `QuietFallback string` at `:215`
    - `NoneRecAction string` at `:220`
    - `VAName` is a string but is not an action name.
  - Non-test code outside matcher that assigns a `Tunables` field: 7 fields, all in `harness/conform`.
    - `harness/conform/translate.go:211` `Languages`
    - `harness/conform/translate.go:212` `IgnoredAliasTypes`
    - `harness/conform/translate.go:222` `QuietFallback`
    - `harness/conform/translate.go:223` `NoneRecAction`
    - `harness/conform/translate.go:224` `Timid`
    - `harness/conform/defaults.go:78` `Quiet`
    - `harness/conform/component.go:675` and `:722` `DataSourcePenalties`
    - `harness/conform/component.go:433` also mutates the `DistanceWeights` map in place (`maps.Copy`).
  - Non-test reads outside matcher:
    - `harness/conform/case.go:420` `DistanceWeights`
    - `harness/conform/defaults.go:46-56` `StrongRecThresh`, `MediumRecThresh`, `RecGapThresh`, `MaxRec` (reads on the `want` Tunables)
    - `engine/musicbrainz/tracks.go:39,43,100` `IgnoreDataTracks`, `IgnoreVideoTracks`, `IgnoredMedia`
    - `engine/musicbrainz/query.go:93` `SearchLimit`
    - `engine/musicbrainz/query.go:148` `ExtraTags`
    - `engine/musicbrainz/alias.go:36-41` `IgnoredAliasTypes`, `Languages`
    - `engine/musicbrainz/events.go:36` `Preferred.Countries`
    - `engine/musicbrainz/credit.go:73` `VAName`
    - `engine/tag/tag.go:104` `Timid`
    - `harness/analysis/proximity.go:67-82` reads `StrongRecThresh`, `MediumRecThresh`, `RecGapThresh` from `cassette.Thresholds`, not from `Tunables`.
  - Names resolved to typed values:
    - `engine/matcher/verdict.go:41` `ParseRecommendation`, `:77` `ParseAction`
    - `LegalQuietFallbacks` at `verdict.go:93`, `LegalNoneRecActions` at `verdict.go:97`
    - Callers:
      - `tunables.go:469` `ParseRecommendation` (Validate)
      - `tunables.go:481,486` `ParseAction` (Validate)
      - `tunables.go:483,488` Legal lists (Validate)
      - `verdict.go:162` `ParseRecommendation` (Recommend)
      - `verdict.go:184,199` `ParseAction`
      - `verdict.go:188,203` Legal lists (ActionFor)
      - `candidate.go:122` resolves the `Required` names through `requiredFields`
    - The review's "four places" is `tunables.go:448-493` (Validate), `verdict.go:162`, `verdict.go:179-210` (ActionFor) and `candidate.go:121-125`. All four still hold.
  - `compilePanicAsError` is `tunables.go:504-512`, defined at `:495-512`. Callers: `tunables.go:457` (media) and `:460` (countries), both inside `Validate`. It recovers a panic thrown by `compileMediaPatterns` (`album_media.go:41-51`, panics at `:46`) and `compileCountryPatterns` (`album_country.go:36-46`, panics at `:41`).
  - Per-candidate recompile: `album_media.go:26` calls `compileMediaPatterns(tun.Preferred.Media)` and `album_country.go:21` calls `compileCountryPatterns(tun.Preferred.Countries)`, inside `addAlbumMedia` and `addAlbumCountry`. Each runs on every `DistanceForAlbum` call, once per candidate. `CompilePatternOption` (`penalty.go:368`) does `regexp.Compile` with no cache.
  
  ## E5 (tagio registry): STILL HOLDS
  - `engine/tagio/seam.go`: `formatEntry` is `:33-37`, `registry` is `:50-56`, `flacMagic` at `:61`, `resolveEntry` at `:112-122`.
  - Functions that read the registry:
    - `SupportedFormats` at `:71` (reads `maps.Keys` at `:72`)
    - `Sniff` at `:83` (range at `:99`)
    - `resolveEntry` at `:112` (map lookup `:117`)
    - `Read` (`read.go:17-26`) and `Write` (`write.go:40`) call `resolveEntry`.
    - `Parse` bypasses the registry by design (`container.go:128`).
  - No exported `Register` function exists.
  - Outside callers:
    - `tagio.SupportedFormats`: `cmd/dubplate-server/intake.go:324`; test `internal/intake/gate/policy_test.go:35,39`
    - `tagio.Format` and `tagio.FormatFLAC`: `internal/intake/gate/policy.go:34,40`; test `policy_test.go:16`
    - `tagio.Sniff`: `internal/intake/gate/file.go:100`
  - `Read` opens the file twice: `Sniff` at `seam.go:84` (`os.Open`), then `readFLAC` calls `Parse`, which opens at `container.go:197`. `Write` does the same through `resolveEntry` at `write.go:40`, then `copyFrameRegion` opens at `write.go:308`.
  
  ## E6 (exports with no outside caller)
  Package-qualified grep (`matcher.X`, `tagio.X`) over `cmd` and `internal`, excluding `_salvage`.
  
  Matcher, each of these has NO reference outside `engine/matcher`, test or non-test:
  - `Distance.Update`: only defined at `penalty.go:202`, used only by `penalty_test.go:426` inside matcher
  - `Levenshtein`: used at `strdist.go:89`, `translit_test.go:72`
  - `Transliterate`: used at `strdist.go:103`, `translit_test.go`
  - `AssignItems`: used at `candidate.go:131`, `assign_test.go`
  - `AlbumPairsFor`: used at `candidate.go:132`, `assign_test.go:279`
  - `ParseAction`, `ParseRecommendation`, `LegalQuietFallbacks`, `LegalNoneRecActions`: used only at the in-package sites listed under E4
  - `SDEndWords`: `strdist.go:118`, `tunables_test.go:233`
  - `SDReplace`: `strdist.go:135,155`, `tunables_test.go:238`
  - `SDReplacement`: `tunables.go:359,366`, `tunables_test.go:237`
  
  `ProjectItemFields` is the exception, referenced only from `harness/conform`:
  - Non-test: `harness/conform/case.go:331`, `harness/conform/request.go:169`, `harness/conform/component.go:678`
  - Test: `harness/conform/defaults_test.go:171` (also a comment at `:150`), `harness/conform/case_test.go:304`
  - `ProjectItemFields` is `info.go:189`. The block `info.go:154-259` holds the `field*` constants at `:154-173` and the helpers `stringField` (`:215`), `boolField` (`:229`), `intField` (`:237`) and `floatField` (`:250`). The helpers are unexported and used only by `ProjectItemFields`.
  
  Tagio, no outside reference, test or non-test:
  - `WriteOrder` (`tagset.go:333`)
  - `Mapping` (`tagset.go:345`)
  - `EmptyString` (`tagset.go:203`)
  - `EmptyList` (`tagset.go:213`)
  - `Container.FrontCover` (`picture.go:76`; only `picture_test.go:195` inside tagio)
  - `Deviations` (`deviations.go:130`, `var Deviations struct{}`)
  - `FieldMapping.Citation`: only `tagset_test.go:81` inside tagio. The `Citation` hits in `harness/analysis` are a different type.
  - Inside tagio, none of `WriteOrder`, `Mapping`, `EmptyString`, `EmptyList` or `Deviations` has a non-test caller; they are referenced only in tests.
  
  Others:
  - `musicbrainz.ClientConfig.Timeout` (`client.go:95`) is read at `client.go:137`. No code outside the package, test or non-test, sets it: the three `ClientConfig` literals (`harness/conform/case.go:340`, `harness/conform/request.go:137`, `engine/tag/tag_test.go:71`) set only `BaseURL`, `UserAgent`, `Budget` (the first two and the `HTTP`-less literal in the tag test).
  - `tag.Options.SearchIDs` (`tag/tag.go:40`) is read at `tag.go:76,80`. Used only in `tag/tag_test.go:229,296`. No caller sets it outside the package. `harness/conform/case.go:401` passes `tag.Options{}`.
  
  `go tool deadcode ./...` works without network. I ran it with `GOPROXY=off GOFLAGS=-mod=readonly`. It writes only to the Go build cache. It exited cleanly, 275 lines, full output below. It uses `main` packages as roots, with tests excluded. `harness/conform` is entirely unreachable because `cmd/harness` does not import it. Everything under `engine/matcher`, `engine/musicbrainz`, `engine/tag` is unreachable for the same reason (the server uses only `tagio`).
  ```
  internal/auth/limit.go:265:24: keyedLimiter.size
  internal/auth/session.go:218:6: VerifySession
  internal/engine/matcher/album_album.go:8:6: addAlbumAlbum
  internal/engine/matcher/album_artist.go:12:6: addAlbumArtist
  internal/engine/matcher/album_catalognum.go:8:6: addAlbumCatalogNum
  internal/engine/matcher/album_country.go:20:6: addAlbumCountry
  internal/engine/matcher/album_country.go:36:6: compileCountryPatterns
  internal/engine/matcher/album_data_source.go:10:6: addAlbumDataSource
  internal/engine/matcher/album_disambig.go:8:6: addAlbumDisambig
  internal/engine/matcher/album_extras.go:24:6: addAlbumMissingTracks
  internal/engine/matcher/album_extras.go:33:6: addAlbumUnmatchedTracks
  internal/engine/matcher/album_id.go:12:6: addAlbumID
  internal/engine/matcher/album_label.go:8:6: addAlbumLabel
  internal/engine/matcher/album_media.go:21:6: addAlbumMedia
  internal/engine/matcher/album_media.go:41:6: compileMediaPatterns
  internal/engine/matcher/album_mediums.go:10:6: addAlbumMediums
  internal/engine/matcher/album_tracks.go:25:6: addAlbumTracks
  internal/engine/matcher/album_year.go:24:6: addAlbumYear
  internal/engine/matcher/album_year.go:55:6: absInt
  internal/engine/matcher/assign.go:75:6: AssignItems
  internal/engine/matcher/assign.go:126:6: AlbumPairsFor
  internal/engine/matcher/assign.go:149:6: solveLAP
  internal/engine/matcher/assign.go:198:6: columnReduce
  internal/engine/matcher/assign.go:248:6: augmentingRowReduce
  internal/engine/matcher/assign.go:304:6: augment
  internal/engine/matcher/assign.go:319:6: findPath
  internal/engine/matcher/candidate.go:43:6: NewCandidates
  internal/engine/matcher/candidate.go:109:22: Candidates.Add
  internal/engine/matcher/candidate.go:155:22: Candidates.Len
  internal/engine/matcher/candidate.go:160:22: Candidates.All
  internal/engine/matcher/candidate.go:174:22: Candidates.Sorted
  internal/engine/matcher/compat.go:29:6: FullCompat
  internal/engine/matcher/compat.go:39:6: DefaultCompat
  internal/engine/matcher/compat.go:47:17: Compat.Apply
  internal/engine/matcher/info.go:189:6: ProjectItemFields
  internal/engine/matcher/info.go:215:6: stringField
  internal/engine/matcher/info.go:229:6: boolField
  internal/engine/matcher/info.go:237:6: intField
  internal/engine/matcher/info.go:250:6: floatField
  internal/engine/matcher/likelies.go:47:6: MostCommonTags
  internal/engine/matcher/likelies.go:87:6: projectField
  internal/engine/matcher/likelies.go:102:6: plurality
  internal/engine/matcher/penalty.go:62:6: NewDistance
  internal/engine/matcher/penalty.go:68:20: Distance.RawDistance
  internal/engine/matcher/penalty.go:83:20: Distance.MaxDistance
  internal/engine/matcher/penalty.go:96:20: Distance.Distance
  internal/engine/matcher/penalty.go:112:20: Distance.Penalties
  internal/engine/matcher/penalty.go:124:20: Distance.AddedKeys
  internal/engine/matcher/penalty.go:133:20: Distance.PerKey
  internal/engine/matcher/penalty.go:150:20: Distance.NonzeroItems
  internal/engine/matcher/penalty.go:166:20: Distance.NonzeroKeys
  internal/engine/matcher/penalty.go:184:20: Distance.GenericPenaltyKeys
  internal/engine/matcher/penalty.go:202:20: Distance.Update
  internal/engine/matcher/penalty.go:223:20: Distance.Add
  internal/engine/matcher/penalty.go:245:20: Distance.AddEquality
  internal/engine/matcher/penalty.go:257:20: Distance.AddExpr
  internal/engine/matcher/penalty.go:273:20: Distance.AddNumber
  internal/engine/matcher/penalty.go:297:20: Distance.AddPriority
  internal/engine/matcher/penalty.go:315:20: Distance.AddRatio
  internal/engine/matcher/penalty.go:338:20: Distance.AddDataSource
  internal/engine/matcher/penalty.go:368:6: CompilePatternOption
  internal/engine/matcher/penalty.go:380:24: PatternOption.matches
  internal/engine/matcher/penalty.go:385:6: optionMatches
  internal/engine/matcher/penalty.go:395:20: Distance.keyDistance
  internal/engine/matcher/penalty.go:417:20: Distance.dataSourcePenalty
  internal/engine/matcher/penalty.go:429:20: Distance.weight
  internal/engine/matcher/penalty.go:437:6: sumPenalties
  internal/engine/matcher/quiet.go:17:6: QuietImportTunables
  internal/engine/matcher/score.go:60:6: DistanceForAlbum
  internal/engine/matcher/strdist.go:28:6: StringDist
  internal/engine/matcher/strdist.go:69:20: Distance.AddString
  internal/engine/matcher/strdist.go:84:6: stringDistBasic
  internal/engine/matcher/strdist.go:100:6: sdStrip
  internal/engine/matcher/strdist.go:117:6: rotateEndWords
  internal/engine/matcher/strdist.go:134:6: applySDReplace
  internal/engine/matcher/strdist.go:148:6: compileSDPatterns
  internal/engine/matcher/strdist.go:181:6: sdRegexp
  internal/engine/matcher/track.go:45:6: DistanceForTrack
  internal/engine/matcher/track_artist.go:31:6: IsVariousArtistsName
  internal/engine/matcher/track_artist.go:44:6: addTrackArtist
  internal/engine/matcher/track_data_source.go:13:6: addTrackDataSource
  internal/engine/matcher/track_id.go:15:6: addTrackID
  internal/engine/matcher/track_index.go:17:6: addTrackIndex
  internal/engine/matcher/track_length.go:18:6: addTrackLength
  internal/engine/matcher/track_medium.go:15:6: addTrackMedium
  internal/engine/matcher/track_title.go:15:6: addTrackTitle
  internal/engine/matcher/translit.go:19:6: SetTransliterator
  internal/engine/matcher/translit.go:32:6: Transliterate
  internal/engine/matcher/translit.go:49:6: Levenshtein
  internal/engine/matcher/tunables.go:271:6: DefaultTunables
  internal/engine/matcher/tunables.go:448:19: Tunables.Validate
  internal/engine/matcher/tunables.go:504:6: compilePanicAsError
  internal/engine/matcher/verdict.go:23:25: Recommendation.String
  internal/engine/matcher/verdict.go:41:6: ParseRecommendation
  internal/engine/matcher/verdict.go:77:6: ParseAction
  internal/engine/matcher/verdict.go:107:6: Recommend
  internal/engine/matcher/verdict.go:146:6: downgrade
  internal/engine/matcher/verdict.go:179:6: ActionFor
  internal/engine/matcher/unidecode/unidecodetest/unidecodetest.go:15:6: LoadCachedTable
  internal/engine/musicbrainz/alias.go:35:6: preferredAlias
  internal/engine/musicbrainz/alias.go:69:6: keyWithPreferredAlias
  internal/engine/musicbrainz/client.go:122:6: NewClient
  internal/engine/musicbrainz/client.go:155:6: sleepReal
  internal/engine/musicbrainz/client.go:169:6: extractReleaseID
  internal/engine/musicbrainz/client.go:181:18: Client.releaseRequestURL
  internal/engine/musicbrainz/client.go:191:18: Client.searchRequestURL
  internal/engine/musicbrainz/client.go:213:18: Client.Release
  internal/engine/musicbrainz/client.go:253:18: Client.SearchReleases
  internal/engine/musicbrainz/client.go:294:18: Client.AlbumForID
  internal/engine/musicbrainz/client.go:340:18: Client.doWithRetry
  internal/engine/musicbrainz/client.go:400:6: retryWait
  internal/engine/musicbrainz/client.go:415:6: backoff
  internal/engine/musicbrainz/credit.go:50:6: parseArtistCredits
  internal/engine/musicbrainz/credit.go:69:6: applyVariousArtists
  internal/engine/musicbrainz/events.go:35:6: preferredReleaseEvent
  internal/engine/musicbrainz/events.go:59:6: parseDate
  internal/engine/musicbrainz/events.go:74:6: parseDatePart
  internal/engine/musicbrainz/limiter.go:102:6: NewLimiter
  internal/engine/musicbrainz/limiter.go:115:6: newLimiter
  internal/engine/musicbrainz/limiter.go:128:19: Limiter.Budget
  internal/engine/musicbrainz/limiter.go:137:19: Limiter.Close
  internal/engine/musicbrainz/limiter.go:158:19: Limiter.awaitQueued
  internal/engine/musicbrainz/limiter.go:170:19: Limiter.awaitTicks
  internal/engine/musicbrainz/limiter.go:184:19: Limiter.holdBeforeOffer
  internal/engine/musicbrainz/limiter.go:190:19: Limiter.dispatch
  internal/engine/musicbrainz/limiter.go:209:19: Limiter.serve
  internal/engine/musicbrainz/limiter.go:244:19: Limiter.pick
  internal/engine/musicbrainz/limiter.go:260:19: Limiter.highest
  internal/engine/musicbrainz/limiter.go:271:19: Limiter.nextBelow
  internal/engine/musicbrainz/limiter.go:281:19: Limiter.acquire
  internal/engine/musicbrainz/limiter.go:313:19: Limiter.depart
  internal/engine/musicbrainz/limiter.go:341:6: Unmetered
  internal/engine/musicbrainz/limiter.go:358:18: Budget.Wait
  internal/engine/musicbrainz/limiter.go:369:18: Budget.reserve
  internal/engine/musicbrainz/limiter.go:379:18: Budget.release
  internal/engine/musicbrainz/limiter.go:386:18: Budget.Spent
  internal/engine/musicbrainz/pseudo.go:20:6: PseudoReleaseTarget
  internal/engine/musicbrainz/pseudo.go:53:6: MergePseudoRelease
  internal/engine/musicbrainz/query.go:79:6: AlbumSearchFor
  internal/engine/musicbrainz/query.go:108:6: vaLikely
  internal/engine/musicbrainz/query.go:139:6: albumCriteria
  internal/engine/musicbrainz/query.go:163:6: extraTagValue
  internal/engine/musicbrainz/query.go:195:6: formatSearchTerm
  internal/engine/musicbrainz/query.go:210:6: escapeLucene
  internal/engine/musicbrainz/query.go:239:6: lowerSearchTerm
  internal/engine/musicbrainz/query.go:247:6: trimSearchTerm
  internal/engine/musicbrainz/relations.go:27:6: GroupRelations
  internal/engine/musicbrainz/release.go:171:19: wireInt.UnmarshalJSON
  internal/engine/musicbrainz/release.go:230:21: Release.Validate
  internal/engine/musicbrainz/release.go:268:6: assembledTracks
  internal/engine/musicbrainz/release.go:284:6: resolvedTrackCredit
  internal/engine/musicbrainz/tracks.go:37:6: tracksFromMedium
  internal/engine/musicbrainz/tracks.go:57:6: buildTrack
  internal/engine/musicbrainz/tracks.go:98:6: extractTracks
  internal/engine/musicbrainz/tracks.go:133:6: deriveMedia
  internal/engine/musicbrainz/translate.go:45:6: TranslateAlbum
  internal/engine/tag/tag.go:66:6: Album
  internal/engine/tag/tag.go:161:6: lookupAndAdd
  internal/engine/tagio/picture.go:76:20: Container.FrontCover
  internal/engine/tagio/tagset.go:203:6: EmptyString
  internal/engine/tagio/tagset.go:213:6: EmptyList
  internal/engine/tagio/tagset.go:333:6: WriteOrder
  internal/engine/tagio/tagset.go:345:6: Mapping
  internal/harness/analysis/adjudication.go:141:30: AdjudicationLedger.ByCase
  internal/harness/analysis/adjudication.go:152:6: LoadAdjudications
  internal/harness/analysis/adjudication.go:165:6: CheckAdjudications
  internal/harness/analysis/adjudication.go:185:6: checkAdjudicationEntry
  internal/harness/analysis/adjudication.go:263:6: CheckDefectFree
  internal/harness/analysis/album_info.go:140:6: LoadAlbumInfoLedger
  internal/harness/analysis/album_info.go:160:6: CheckAlbumInfoLedger
  internal/harness/analysis/album_info.go:251:6: releaseLookups
  internal/harness/analysis/claims.go:60:6: LoadClaims
  internal/harness/analysis/claims.go:77:18: Claims.declaresZeroCandidates
  internal/harness/analysis/claims.go:86:6: CheckClaims
  internal/harness/analysis/claims.go:155:6: checkRecommendation
  internal/harness/analysis/claims.go:165:6: checkAssignment
  internal/harness/analysis/claims.go:195:6: checkAppliedFields
  internal/harness/analysis/component.go:64:6: LoadComponentTable
  internal/harness/analysis/component.go:74:6: CheckComponentTable
  internal/harness/analysis/file_tags.go:83:6: LoadFileTagLedger
  internal/harness/analysis/file_tags.go:100:6: CheckFileTagLedger
  internal/harness/analysis/ledger.go:14:6: readJSON
  internal/harness/analysis/oraclebug.go:42:6: LoadOracleBugs
  internal/harness/analysis/oraclebug.go:65:6: CheckOracleBugs
  internal/harness/analysis/oraclebug.go:97:6: checkOracleBugEntry
  internal/harness/analysis/proximity.go:65:6: Flag
  internal/harness/analysis/proximity.go:91:6: withinEpsilon
  internal/harness/analysis/proximity.go:96:6: LoadProximityLedger
  internal/harness/analysis/proximity.go:111:6: CheckProximityLedger
  internal/harness/analysis/ties.go:80:6: LoadTieLedger
  internal/harness/analysis/ties.go:94:6: CheckTieLedger
  internal/harness/analysis/ties.go:125:6: checkTieEntry
  internal/harness/analysis/ties.go:164:6: checkSkippedTieEntry
  internal/harness/analysis/ties.go:192:6: MergeTieDispositions
  internal/harness/cassette/cassette.go:276:6: LoadManifest
  internal/harness/conform/case.go:185:6: unreachable func: GradeCases
  internal/harness/conform/case.go:265:6: unreachable func: loadLedgers
  internal/harness/conform/case.go:320:6: unreachable func: caseInputs
  internal/harness/conform/case.go:339:6: unreachable func: gradeClient
  internal/harness/conform/case.go:352:6: unreachable func: gradeCase
  internal/harness/conform/case.go:466:6: unreachable func: gradeCaseVerdict
  internal/harness/conform/case.go:505:6: unreachable func: checkRequestSet
  internal/harness/conform/case.go:520:6: unreachable func: compatFor
  internal/harness/conform/case.go:553:6: unreachable func: gradeCaseDefault
  internal/harness/conform/case.go:692:6: unreachable func: CheckDefaultCompatMatchesTheLedger
  internal/harness/conform/case.go:729:6: unreachable func: gradeCandidates
  internal/harness/conform/case.go:780:6: unreachable func: gradePenalties
  internal/harness/conform/case.go:806:6: unreachable func: gradeAssignment
  internal/harness/conform/case.go:855:6: unreachable func: compareFloat
  internal/harness/conform/case.go:911:6: unreachable func: policyFor
  internal/harness/conform/case.go:993:6: unreachable func: widenCompat
  internal/harness/conform/case.go:1008:6: unreachable func: checkTiesAwaitingRuling
  internal/harness/conform/component.go:79:6: unreachable func: ReplayTable
  internal/harness/conform/component.go:101:6: unreachable func: ReplayRow
  internal/harness/conform/component.go:142:6: unreachable func: rowErr
  internal/harness/conform/component.go:151:6: unreachable func: replayAddMethod
  internal/harness/conform/component.go:209:6: unreachable func: replayAdderShape
  internal/harness/conform/component.go:233:6: unreachable func: decodeCallElems
  internal/harness/conform/component.go:241:6: unreachable func: wantArity
  internal/harness/conform/component.go:248:6: unreachable func: callAdd
  internal/harness/conform/component.go:260:6: unreachable func: callAddExpr
  internal/harness/conform/component.go:272:6: unreachable func: callAddNumber
  internal/harness/conform/component.go:287:6: unreachable func: callAddRatio
  internal/harness/conform/component.go:302:6: unreachable func: callAddString
  internal/harness/conform/component.go:317:6: unreachable func: callAddEquality
  internal/harness/conform/component.go:333:6: unreachable func: callAddPriority
  internal/harness/conform/component.go:355:6: unreachable func: decodeOptions
  internal/harness/conform/component.go:385:6: unreachable func: decodeOption
  internal/harness/conform/component.go:431:6: unreachable func: tunablesWithOverrides
  internal/harness/conform/component.go:439:6: unreachable func: applyAggregateCalls
  internal/harness/conform/component.go:461:6: unreachable func: replayAggregateShape
  internal/harness/conform/component.go:501:6: unreachable func: replayGenericPenaltyKeys
  internal/harness/conform/component.go:523:6: unreachable func: replayStringDist
  internal/harness/conform/component.go:572:6: unreachable func: metadataSourceSet
  internal/harness/conform/component.go:586:6: unreachable func: decodeTrackInfo
  internal/harness/conform/component.go:619:6: unreachable func: stringAny
  internal/harness/conform/component.go:636:6: unreachable func: intAny
  internal/harness/conform/component.go:651:6: unreachable func: floatAny
  internal/harness/conform/component.go:666:6: unreachable func: replayTrackDistance
  internal/harness/conform/component.go:715:6: unreachable func: replayAddDataSource
  internal/harness/conform/component.go:742:6: unreachable func: derefOr
  internal/harness/conform/component.go:752:6: unreachable func: rawPenaltyMap
  internal/harness/conform/component.go:769:6: unreachable func: decodeItems
  internal/harness/conform/component.go:804:6: unreachable func: checkFields
  internal/harness/conform/component.go:828:6: unreachable func: compareFloats
  internal/harness/conform/component.go:842:6: unreachable func: checkFloatSlice
  internal/harness/conform/component.go:856:6: unreachable func: checkFloatMap
  internal/harness/conform/component.go:876:6: unreachable func: checkPenaltyMap
  internal/harness/conform/component.go:899:6: unreachable func: checkItems
  internal/harness/conform/defaults.go:22:6: unreachable func: CheckCaseWeights
  internal/harness/conform/defaults.go:44:6: unreachable func: CheckCaseThresholds
  internal/harness/conform/defaults.go:73:6: unreachable func: gradeTunables
  internal/harness/conform/defaults.go:89:6: unreachable func: CheckUnidecodeVersion
  internal/harness/conform/defaults.go:96:6: unreachable func: sortedKeys
  internal/harness/conform/request.go:72:6: unreachable func: GradeRequests
  internal/harness/conform/request.go:114:6: unreachable func: gradeCaseRequests
  internal/harness/conform/request.go:198:6: unreachable func: distinctReleaseLookupMBIDs
  internal/harness/conform/request.go:219:6: unreachable func: countLookupRequests
  internal/harness/conform/request.go:230:6: unreachable func: countSearchRequests
  internal/harness/conform/translate.go:102:6: unreachable func: checkNullable
  internal/harness/conform/translate.go:128:6: unreachable func: CheckTranslatedAlbum
  internal/harness/conform/translate.go:165:6: unreachable func: checkTranslatedTrack
  internal/harness/conform/translate.go:203:6: unreachable func: mergeProfile
  internal/harness/conform/translate.go:221:6: unreachable func: withImportKeys
  internal/harness/conform/translate.go:254:6: unreachable func: checkProfileKeys
  internal/harness/conform/translate.go:290:6: unreachable func: checkProfileKeyDrift
  internal/harness/conform/translate.go:310:6: unreachable func: findReleaseRequest
  internal/harness/conform/translate.go:326:6: unreachable func: loadRelease
  internal/harness/conform/translate.go:351:6: unreachable func: gradeLedger
  internal/harness/conform/translate.go:418:6: unreachable func: checkNoReleaseReachesBrowseThreshold
  internal/harness/oracle/reconcile.go:36:6: unreachable func: Reconcile
  internal/harness/oracle/reconcile.go:72:6: unreachable func: venvVersions
  internal/ops/errors.go:132:6: unreachable func: NewUnauthenticatedError
  internal/reject/reject.go:165:6: unreachable func: All
  internal/serve/origin.go:92:23: unreachable func: originCheck.addBearerBypass
  ```
  (The "unreachable func:" prefix is dropped from the first 195 lines to save space. The actual tool output has it on every line.)
  
  ## E7 (strdist regex cache): PARTLY HOLDS
  - The structure changed. `engine/matcher/strdist.go:141-193` now holds:
    - a package-level read-only map `sdShippedRegexps` built at init from `BeetsSDPatterns`, `SDPatternsNoBracketDiscount` and `SDReplace` (`:141-159`, `compileSDPatterns` at `:148`)
    - a mutex-guarded map `sdForeignRegexps` (`:161-169`) for patterns from tables assigned from outside the package
    - `sdRegexp` (`:181-193`), which checks the shipped map first, then the foreign map, then `regexp.MustCompile`.
  - The range 146-193 matches this layout. Rows (`SDPattern`) still hold string patterns, not `*regexp.Regexp`.
  - `SDReplace` (`tunables.go:366-368`) is one row, `{Pattern: "&", Replacement: "and"}`. `applySDReplace` (`strdist.go:134-139`) loops over `SDReplace` and calls `sdRegexp(pattern).ReplaceAllLiteralString(s, replacement)`. Literal replacement, so the claim that it is `strings.ReplaceAll(s, "&", "and")` is correct for the shipped table.
  
  ## E8 (musicbrainz leftovers): STILL HOLDS, with three details
  - `GroupRelations` is `engine/musicbrainz/relations.go:27-38`. One non-test caller, `pseudo.go:25` (`GroupRelations(rel.Relations)["release"]`). Tests: `relations_test.go:32,56`.
  - `parseDate` is `engine/musicbrainz/events.go:59` and returns `(year, month, day int)`. Callers: `translate.go:58` (`originalYear, _, _ :=`) and `translate.go:72` (`year, _, _ =`). Only the test `events_test.go:100` reads month and day.
  - `preferredAlias` (`alias.go:35-66`) builds `ignored := map[string]struct{}` on every call (`:36-39`). The review's `tracks.go:70-73` is the two call sites in `buildTrack`: `tracks.go:70` (`preferredAlias`) and `tracks.go:73` (`keyWithPreferredAlias`), so the map is built twice per track.
  - Retry loop: `client.go:342` (`for attempt := 1; attempt <= maxAttempts`, `maxAttempts = 7` at `:42`). A failed `c.http.Do` is not checked for a cancelled context: `client.go:353-363` sets `lastErr` and calls `c.sleep(ctx, backoff(attempt))`, which for attempt 1 is `d == 0`. `sleepReal` (`:155`) does `select` on timer and `ctx.Done()`, so a cancelled context returns `ctx.Err()` immediately or, if the timer fires first, continues to attempt 2. Attempt 2 then fails at `c.budget.Wait(ctx)` (`:343`) with `ctx.Err()`. Net: the loop iterates once more but no second HTTP request goes out. The review's "retried once" overstates it.
  - `io.ReadAll` is `client.go:365`. There is no `io.LimitReader` or size cap anywhere in the package.
  
  ## E9 (unidecode): STILL HOLDS
  - Checksum block (`sha256.Sum256`, hex, compare, wrapped error), four occurrences in `engine/matcher/unidecode`:
    - `fetch.go:48-52`
    - `extract.go:22-26`
    - `extract.go:37-41`
    - `table.go:30-34`
  - `decode` is `table.go:165-245`. It stores `version`, `sweepLo`, `sweepHi` and `digest` into the `Table` (`table.go:239-242`). The only non-test reader of those four is `encode()` (`table.go:84-93`). `table.go:36-37` tests and `table_test.go:30-37` read them back in a round-trip.
  
  ## E10 (harness trims)
  - Sweep versus tier 1: `harness/conform/request.go:72-190` still holds (`GradeRequests` at `:72`, `gradeCaseRequests` at `:114-190`, helpers to `:238`). Its only caller is `request_test.go:77`, no non-test caller. Tier 1 is `case.go:415` (`checkRequestSet(c.ID, srv)`) and `:500-514` (`checkRequestSet` definition at `:505`), inside `gradeCase`.
  - `Case.Extra`: field at `harness/cassette/cassette.go:47-54`.
    - Readers: `cassette.go:184-185` (validation) and `stub/stub.go:101-102`.
    - Writers: none outside tests (`cassette_test.go`, `stub_test.go`, `corpus_test.go`).
    - No committed case carries it: 0 of 216 `corpus/**/case.json` contain `"extra"`. Only the test fixtures `cassette/testdata/extra-request-shape`, `stub/testdata/unused-fixture` and `stub/testdata/extra-channel` do.
  - `tiesAwaitingRuling`: declared `harness/conform/case.go:105` as `var tiesAwaitingRuling []string`, empty. Read at `case.go:373`. No writers. `checkTiesAwaitingRuling` is `case.go:1008`; its callers are `case_test.go:183,269`.
  - `fieldNullability`: `harness/conform/translate.go:70`. The only readers are `translate_test.go:23,28,42`.
  - Canonicalization copies, three: `cassette/cassette.go:260` (`canonicalizePathQuery`), `stub/stub.go:240` (`canonicalize`), `mbrequest/mbrequest.go:34` (`CanonicalizeQuery`). Release-lookup parsing:
    - The `"/ws/2/release/"` constant is defined three times: `oracle/album_info.go:28`, `analysis/album_info.go:25`, `conform/translate.go:20`.
    - `strings.CutPrefix` parsing at `oracle/album_info.go:102`, `analysis/album_info.go:254`, `conform/request.go:202`.
    - `HasPrefix` at `conform/translate.go:437` and `request.go:222`.
    - So the review's grouping matches for canonicalization; the lookup-parsing copies are in oracle, analysis and conform, not in the same three files.
  - Importers of `harness/mbrequest`: `cmd/harness/capture.go:17` (uses at `:300,302`) and `harness/synth/synth.go:11` (uses at `:41,43`). Nothing else.
  - `oracle` scaffold: `DeriveDefectFree` (`oracle/defect_free.go:73-117`) and `DeriveFileTags` (`oracle/file_tags.go:34-55`) both do `os.MkdirTemp`, marshal input, write `input.json`, then `runPython`. `DeriveAlbumInfo` (`album_info.go:42`) and `DeriveTies` (`ties.go:43`) repeat the temp-dir and profile-render scaffold. So three copies of the temp-dir/input.json/`runPython` shape plus a fourth variant with profile rendering. `DeriveComponentTable` is a bare `runPython` call.
  - `conform/arch_test.go` is 288 lines. It holds: `checkNoHarnessImports` (`:32`), `checkNoTimeNow` (`:77`), `importedName` (`:126`), `TestEngineNeverImportsHarness` (`:143`), `TestEngineNeverReadsTheClock` (`:154`), three fixture tests (`:165`, `:180`, `:196`), `serverUnlinkable` (`:214`), `serverLinkViolations` (`:225`), `TestServerNeverLinksTheHarnessOrChecker` (`:242`, runs `go list -deps ./cmd/dubplate-server`) and `TestServerLinkCheckFiresOnItsOwnListing` (`:260`). Server and engine rules both live here. The server rule forbids `internal/harness`, `internal/opensubsonic/conformance`, `github.com/getkin`, `github.com/tus/tusd/v2/pkg/filelocker` and `github.com/tus/lockfile`.
  - `crypto/rand.Read` error checks, line numbers drifted by 2: `harness/subsonic/stack/stack.go:610` (was :608) and `opensubsonic/client/client.go:109` (was :107). Also `auth/token.go:122` checks it. `engine/store/id.go:13` discards it (`_, _ =`).
  
  ## E11 (latent harness bug): STILL HOLDS
  - `harness/conform/case.go` never reads `PatternTable`. A grep for `PatternTable` finds nothing in any non-test file under `harness/conform`.
  - `case.go:582` is `tunDefault := compatFor(ModeDefault, policy).Apply(tun)`. `compatFor` (`:520-529`) sets only `RemixParenthetical`.
  - `case.go:649-665` grades default-mode defect_free cases against `row.DefectFree.Distance`, `.Recommendation` and `.Action` only.
  - `PatternTable` is read elsewhere: `oracle/defect_free.go:37,50,64,90` and `analysis/adjudication.go:85,127,243,294-295`. `conform/defaults_test.go:185` (`TestPatternTableNamesResolve`) only checks the names resolve.
  - `cmd/harness/main.go:39-41` says "the tool refuses to run at all when DUBPLATE_HARNESS_CONTACT is unset". `requireContact` is called only at `cmd/harness/capture.go:88` (and `runCaptureMisses` at `:101` inside the same command). No other command calls it; `fetch-unidecode` and `fetch-subsonic-xsd` fetch over HTTP without it.
  
  ## E12 (tests): STILL HOLDS
  - `TestWriteOrderDeterministic`: `engine/tagio/tagset_test.go:350-362`. Calls `WriteOrder()` 200 times and compares to the first result, plus a hard-coded 69.
  - `TestDefaultTunables_*`: `engine/matcher/tunables_test.go`, eight functions at `:14`, `:50`, `:66`, `:100`, `:112`, `:151`, `:158`, `:176`. The `:231` the review cites is `TestSDEndWordsAndReplace` (re-types the literals).
  - The two copy-contract tests: `tagio/tagset_test.go:302` (`TestMappingAccessorReturnsCopy`) and `tagio/seam_test.go:95` (`TestSupportedFormatsReturnsCopy`). `Mapping` uses `slices.Clone`; `SupportedFormats` uses `slices.Collect(maps.Keys(...))`, not `Clone`.
  - `tagio/conform_test.go:347-490`: `stageDivergenceRow` (`:347`), `stageDivergenceRows` (`:375`), `stageAndReportDivergences` (`:407`), `marshalStagedRow` (`:427`), `TestStagedRowMatchesTheCommittedExample` (`:441`), `TestStageDivergenceRowsEmitsOnlyOnDisagreement` (`:464`). The `stagedRow` type starts earlier, at `:302`.
  - `harness/conform/defaults_test.go:156` is `TestItemFieldsProjectionAgreesWithCorpus` and `:185` is `TestPatternTableNamesResolve`. `harness/mbrequest/mbrequest_test.go:16` is `TestCanonicalizeQueryOrderIsDeterministic`.
  
  ## E13 (comments): HOLDS for matcher and musicbrainz
  Non-test Go. A comment line is one whose trimmed text starts with `//` or is inside a `/* */` block. The review's percentages match "comment / non-blank lines".
  
  | Package | Files | Total lines | Comment | Blank | % of total | % of non-blank |
  |---|---|---|---|---|---|---|
  | matcher (top dir only) | 33 | 3086 | 1267 | 253 | 41.1 | 44.7 |
  | matcher/unidecode | 6 | 856 | 138 | 80 | 16.1 | 17.8 |
  | musicbrainz | 12 | 1962 | 755 | 171 | 38.5 | 42.2 |
  | tagio | 9 | 2560 | 855 | 149 | 33.4 | 35.5 |
  | tag | 2 | 189 | 74 | 12 | 39.2 | 41.8 |
  | harness/conform | 6 | 2776 | 682 | 213 | 24.6 | 26.6 |
  | cmd/harness | 10 | 1713 | 274 | 148 | 16.0 | 17.0 |
  
  - Pass or ruling ids in comments: the "about 250" is not reproducible exactly. A narrow regex (ruling, fold, rung N, pass N, Task N, m-ids, conductor, Resolution R) finds 63 comment lines across the five engine packages and 50 in `conform`. A broader one (adding contract N, letter-digit ids, 3a-3d) finds 222 in the engine packages and 71 in `conform`. The review's 250 and 50 fall inside those ranges.
  - `matcher/quiet.go:14-16` still cites stale lines: it says `Timid` is at `tunables.go:312` and `QuietFallback` at `:316`; they are at `tunables.go:317` and `:321` (default values) and `:192` and `:215` (field declarations). The arch_test cite `:141-146` is near `TestEngineNeverImportsHarness` at `:143`. `defaults.go:72-79` is `gradeTunables` at `:73-79`, still correct.
  
  ## Importers of the four engine packages from outside `engine`, `harness` and `cmd/harness`
  - `engine/matcher`, `engine/musicbrainz`, `engine/tag`: no importer outside `internal/engine`, `internal/harness` (conform only) and none in `cmd/harness`. `engine/matcher` is imported by musicbrainz (`alias`, `client`, `credit`, `events`, `pseudo`, `query`, `tracks`, `translate`, plus tests), `engine/tag` and `harness/conform`. `musicbrainz` is imported by `engine/tag` and `harness/conform` (`case.go`, `request.go`, `translate.go`). `tag` is imported only by `harness/conform/case.go`.
  - `engine/tagio` is the only one the server uses:
    - `cmd/dubplate-server/intake.go:17` (import), `:324` uses `tagio.SupportedFormats()`.
    - `internal/intake/gate/policy.go:8` (import), `:34` `tagio.Format`, `:40` `tagio.FormatFLAC`.
    - `internal/intake/gate/file.go:18` (import), `:100` `Sniff`, `:109` `ParseBounded` and `Bounds`, `:167` `Read`, `:206-212` `ErrMalformedContainer`, `ErrUnsupportedContainer`, `ErrTagsTooLarge`, `ErrPictureTooLarge`, `:281`, `:343` `StreamInfo`.
    - Tests: `internal/intake/gate/file_test.go:21` (`ErrMalformedContainer`, `ErrUnsupportedContainer`, `ErrTagsTooLarge`, `ErrPictureTooLarge` at `:345-349`, `Parse` at `:374`, `StreamInfo` at `:405`), `gate/policy_test.go:7` (`FormatFLAC` at `:16`, `SupportedFormats` at `:35,39`).
    - Harness only (not "outside" per your scope): `harness/subsonic/fixture/manifest.go:15` (`TagSet`, `Parse`, `Block`), `fixture/build.go:11` (`Picture`, `Write`), `fixture/build_test.go:17` (`Read`, `Serialize`, `Parse`, `Block`).
