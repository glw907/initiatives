# Architecture read of the `cairn` tool, 2026-11-13

Four `standards:go-architecture-reader` reads at cairn-cms `b3d0c2062`, one package each, with no
plan in view. Each item has an id the `tui-language` design cites. "Neutral" means no command's
output changes. `internal/setup` and `internal/ui/newview` were not read, because setup-tooling
pass 3 was editing them; the installer round reads them.

Verdicts: `health` sound with nits, `doctor` sound with nits, `render` workmanlike, `cmd/cairn`
workmanlike. Comment density against a stdlib package: `health` 0.49 (go/doc 0.31), `render` 0.44
(go/doc/comment 0.32), `cmd/cairn` 0.33 (cmd/gofmt 0.30), `doctor` 0.32 (level).

## `internal/render` (pass 1)

- R1. `Role` and its eight constants, `Glyphs`, `GlyphSet`, `Theme.GlyphSet`, `Theme.Style`, and
  `Theme.Sized` have no caller outside the package but tests (`palette.go:11-26,118,170`,
  `glyph.go:7,35`). They were exported for a HUD that does not exist. The shared package exports
  only what a caller uses. Neutral.
- R2. `Width80` (`width.go:20`) is read only as a default width at `cmd/cairn/root.go:142`, which
  repeats `render.go:57` `defaultWidth`. Keep one. `widthFloor` (`width.go:16`) has no reader
  outside tests. Neutral.
- R3. `ambiguousRunes` (`glyph.go:79`) and `groundHex` (`palette.go:59`) are read only by tests.
  Move them to test files. Neutral.
- R4. `Frame.Header`, `Body`, `Footer` are never read outside the package (`render.go:151-159`);
  every caller calls `Lines()`. The `Verdict` alias (`render.go:27`) has no outside user. Neutral.
- R5. `authCheckPermission` and `AuthCheckPermission` are one struct twice (`json.go:462,471`).
  Neutral.
- R6. `fixGroup` repeats `blockedGroup` (`body_plain.go:156-175`, `body_many.go:593`).
  `hangingAt` and `hangingAtNoOrphan` differ only in the wrapper (`layout.go:404`,
  `body_many.go:759`). `palette.go:145,162,170` repeat one sizing idiom. Neutral.
- R7. `forTier` (`palette.go:89`) fixes the tier, yet every call threads `in.ASCII` back through
  `glyphs(ascii)` and `rule(ascii)`. Store the chosen glyphs on the theme. Neutral.
- R8. Tests that pin speculative names or cannot fail: `purity_test.go:232`,
  `palette_test.go:141,157`, `width_test.go:10`, `profile_test.go:179`.
- R9. Comments that cite process: `purity_test.go:226`, `status.go:12,116`, `body_many.go:166`,
  `glyph.go:36`, `profile_windows.go`, `body_single.go:25-27`, `render.go:148-150`,
  `palette.go:75-77`.
- R10. `json.go` (wire payloads) shares nothing with the text bodies but `fixURL` and `instant`.
  A candidate for its own package after the theme move. Not scheduled.

Duplicated between `render` and `newview`, the merge list for the shared package:

| Thing | `render` | `newview` | Note |
| --- | --- | --- | --- |
| Role enum | `palette.go:11-26` | `theme.go:13-25` | |
| Ink table | `palette.go:34-54` | `theme.go:30-47` | value for value |
| `color()` | `palette.go:102-111` | `theme.go:88-97` | same body |
| Style, strong, link | `palette.go:118-156` | `theme.go:101-128` | They differ. `newview`'s link goes plain at no colour, `render` leaves that to its callers. Pick one. |
| Profile | `profile.go:14-41,150` | takes `colorprofile.Profile` | Using `colorprofile.Profile` everywhere deletes about 40 lines. |
| Glyphs | `glyph.go:46-69` | `theme.go:131-143` | `newview` Pending equals `render` Held |
| Wrap | `layout.go:324-386` | `grid.go:63-84` | Two answers to the hyphen break. Keep one. |
| Width measure | `width.go:56-62` | `grid.go:169`, `footer.go:27` | They disagree on Ambiguous runes. Share `render`'s. |

`widthNarrow`/`widthCap` (60/120) and `MinWidth`/`MaxMeasure` (50/76) are per-view policy and stay
in each view.

## `internal/doctor` (pass 2)

- D1. `wireCheck` (`json.go:106`) and `checkVerdict` (`result.go:90`) each switch on `Status`.
  One table should feed both. Neutral.
- D2. `Result.ID` and `Result.Severity` copy values the check already holds (`result.go:45,51`,
  `check.go:163,182`). Neutral.
- D3. The same wrangler opening is pasted into `check_bindings.go:33`, `check_observability.go:20`,
  `check_migrations.go:47`, `check_media.go:43`, and the same site-facts opening into
  `check_media.go:33`, `check_roles.go:109`, `check_posture.go:288`. One wrapper each. Neutral.
- D4. `readUnder` and `listUnder` share a 12-line containment opening (`fileread.go:25,52`).
  Neutral.
- D5. `Status` and its constants, `Result`, `Check` and its fields, `OriginSource`, and
  `OriginAbsent` have no reader outside the package. Decide the surface when the renderer lands.
- D6. False comments: `report.go:8-11` (says a `render` import would invert the dependency, but
  `json.go:7` imports it), `check.go:143`, `check_siteconfig.go:21`, `check_mount.go:10`. Process
  citations: `siteconfigpath.go:17,33`, `fileread.go:23,94`.
- D7. File homes: `joinOr` (`report.go:61`) belongs with the checks, `siteconfigpath.go` in
  `siteconfig.go`, `jsonc.go` in `wrangler.go`, `robotsURL` in `fetchrobots.go`. Neutral.
- D8. For the report move: `doctor` imports `render` for `DoctorSchemaVersion` (`json.go:90`), so
  `render` cannot import `doctor`. Move the constant first. Dead once `Format` goes: `label`
  (`check.go:127`), `lineTitle` (`check.go:133`), the counts line. The renderer needs, per check,
  the id, the status-specific title, the five-way status, the detail, and the condition.

## `cmd/cairn` (pass 3)

- C1. `noCredentialsError`, `networkDownError`, `rateLimitedError`, `crashedCheckError` and their
  constants are called only from a test (`messages.go:628-678`). Runtime neutral; the copy-list
  golden changes.
- C2. `probe_cloudflare.go:15-50` and `probe_github.go:17-29` switch on label strings that
  `permissions.go:34-44` holds. Put the probe in the row. Neutral.
- C3. `adopt.go:73-79` and `177-186` repeat the client build, the check, `loadEnv`, and
  `adopt.Discover`. `probe_token.go:107-114` restates the gating. Neutral.
- C4. `detectTerminal` (`health.go:208`) and `resolvePublicOrigin` (`doctor.go:140`) resolve three
  credentials to read `NO_COLOR`, `TERM`, and `PUBLIC_ORIGIN`. Read `d.env` directly and delete
  `env.go:121-141`. Neutral.
- C5. The render loop is written three times (`health.go:167`, `logs.go:123`, `sites.go:117`), the
  width fallback twice (`root.go:137-143`, `health.go:188-191`), the list-error loop twice
  (`sites.go:94`, `health_sweep.go:186`). Neutral.
- C6. `sites.go:112,155` inline `quietSuppressesFrame`. `health.Options` is built twice.
  `environMap(os.Environ())` is called at `new_agent.go:223`, `new_terminal.go:65`,
  `new_wire.go:63`, past the `d.env` chokepoint. Neutral.
- C7. Over-built: the one-member `nonSecretVar` enum (`env.go:143-176`), `credentialNames`
  (`env.go:90-99`), `defaultRegistrySource` (`registry.go:23-32`). Neutral.
- C8. Wrappers to inline: `adoptListRouteOnlyNotice` (`messages.go:395`), `fallbackError`
  (`messages.go:686`), `processStdout` (`main.go:24`). `newExitFor` builds a fake
  `setup.Failure` (`new_terminal.go:80,233`). `new_dryrun.go:37`, `probe_token.go:247`. Neutral.
- C9. Test-only seams: `terminalLane.run` (`new_terminal.go:33`), `d.checks` (`deps.go:75`), the
  nil-guards at `auth.go:224`, `new_wire.go:59`, `new.go:187`, `root.go:157`, and
  `gitConfigPairs` (`new_wire.go:22-30`). Neutral.
- C10. Files at the 300-line bound: `root.go` 298, `new_terminal.go` 298, `health.go` 291. Move
  `completeSiteIDs` to `args.go`; rename `probe_token.go` to `auth_check.go` and fold the
  permission and probe files into it; merge `agent_page.go` into `help_agents.go`. Neutral.
- C11. Comments: orphans at `env.go:215-216`, `ack.go:174-177`; dated provenance at
  `messages.go:380-391,402`; `root_test.go:465`; the "New to this table" tags; the split headers
  at `health_json.go:1-3`, `health_sweep.go:1-3`.
- C12. Left alone: the `timeoutSet`/`widthSet` copy (`root.go:196-201`), and the hidden
  `auth probe` twin, whose move to `Aliases` would change help.

The `new_*.go` items in C6, C8, C9, and C10 touch the installer's command files and wait for the
installer round.

## `internal/health`, `logs`, `adopt` (pass 4)

- H1. `failSeverity` (`severity.go:16`) repeats all nine check ids from `health.go:73`, eight at
  the zero value. Neutral.
- H2. About 30 functions in `messages.go:22-291` return a fixed literal, and `Catalogue`
  (`messages.go:357-398`) lists each again. Constants and one slice. Neutral.
- H3. `cmd/cairn/health.go:233-234` restates `needsClient` (`health.go:89`). Export
  `Tier.UsesCF` and `UsesGH`. Neutral.
- H4. `check_delegation.go:84` and `adopt/adopt.go:213` both spell the `"nameServers"` key. A
  typed accessor on `record.Cloudflare`. Neutral.
- H5. `check_delegation.go:41-50,63-70` run the same zone lookup twice. Neutral.
- H6. `Options.Validate` (`options.go:29`) and `logs.RetentionClamp` (`logs/logs.go:171`) have no
  outside caller. Neutral.
- H7. `verboseField` (`outcome.go:30`) is called only from a test. Test-only seams at
  `check_serving.go:40,149`. Neutral.
- H8. `ActorProviderConsole` (`fixes.go:22`) is produced by no table, yet named in help
  (`cmd/cairn/messages.go:240`). Removing it changes help text.
- H9. Nits: `check_deploy.go:49`, `fixes.go:212-221`, `logs/events.go:92`. Neutral.
- H10. Comments cite retired Node files (`check_delegation.go:79,97,113`,
  `check_serving.go:36,58,81,130`), dated incidents (`check_errors.go:19`, `messages.go:225`,
  `logs.go:155-162,178,223,243`), and process (`fixes.go:29`).
- H11. Left alone: the four error templates at `messages.go:238-260`, whose merge would change
  the copy list for no reader's gain.

## Worth keeping

The readers named these as the package's best work, and a cleanup must not flatten them:
`health.go:168-178` (a panic records its type, never its value), `check_deploy.go:219-225`,
`render/width.go:35-40` (the width table is a value on the theme), `render/rank.go:42-45`,
`render/json.go:234-238`, `cmd/cairn/fang.go:57-77` (`ttyWriter` exposes only what the probe
needs, so nothing writes past the scrubber), `main.go:106-112`, `auth.go:29-56`,
`doctor/jsonc.go:26-35`, `fetchrobots.go:14-30`, `jssource.go:11`.
