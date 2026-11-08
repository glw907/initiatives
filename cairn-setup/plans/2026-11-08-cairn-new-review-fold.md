Initiative: cairn-setup

# cairn new: review fold record

Fold agent (Opus 5.5), 2026-11-08, over `2026-11-08-cairn-new-review-mechanics.md` (mech),
`-review-contract.md` (con), and `-review-integrity.md` (int). Targets revised in place: the plan and
`../specs/2026-11-08-cairn-new-spec.md`. The design was not edited. Each finding was checked against
cairn-cms `d27ea60b0`, cairn-pub `85c97cc`, or the cited doc before its disposition. `optional`
findings are dropped unless another finding folds the same root. Mechanics minors carry no tag;
each was judged on whether it touches correctness.

Counts: 114 findings (mech 36, con 49, int 29). Folded 96 (six with a part refused: mech M5,
con M11, M12, M14, int M6, M9), refused 2, dropped as optional 11, owner forks 5 (mech M1,
M15, M16, int M13, con M18; mech M12, con M11, and con m16 fork in part), which make Decides 5 to
10; Decides 1 to 4 are revised. Convergent roots are folded once and cross-referenced.

## Probes and sources the fold relied on

- `publish.yml:116-130,196,239,322`: every pack and publish runs `--ignore-scripts`; the
  wizard's `template/` is baked explicitly at `:128`.
- `emit-template-dir.mjs:82-86`: only `composeTemplate` applies the `template-repo` overlay; the
  wizard's scaffold applies none (grep). `templates/waymark` serves the Deploy button (`:6-9`).
- npm `package.json` docs, `files`: an ignore file "at the root of your package ... will not
  override the 'files' field, but in subdirectories it will".
- `keyring.go:21-26` (swappable package vars), `:59-62` (abandoned goroutine);
  `keyring_test.go:308-345`; go-keyring v0.2.8 `keyring_windows.go:28-30` (2,560-byte limit).
- pflag v1.0.10 probe (scratchpad `pflag/`): string `--plan --json` sets plan `"--json"`;
  with `NoOptDefVal`, `--plan plan.json` sets `"-"` and leaves `plan.json` positional.
- git-config(1) ENVIRONMENT on `GIT_CONFIG_COUNT` (quoted in spec 7).
- `go help buildconstraint`; `go doc path/filepath.IsLocal`.
- GitHub docs "Registering a GitHub App": name "cannot be longer than 34 characters", "must be
  unique across GitHub".
- `auth-routes.ts:271-293` (cooldown rebind), `:341-347`, `:366-370,379-385`; `store.ts:93,104-113,159,208`;
  `crypto.ts:68,74,115`; `bootstrap.mjs:87-106` (three statements, hex hash).
- `record_test.go:133-169` (names only); `record.go:46-48` (`Extra`); `adopt.go:178`; `step_test.go:80-108`;
  `logx.go:1-5,32-33,46-59`; `check_deploy.go:189-193`; `create-site.yml:81-95`; `templates/waymark/wrangler.jsonc`
  (no `account_id`); `tool.yml:17,33`; `gate-table.json:68`; `coverage_test.go:47`; `messages.go:197`;
  `copylist/main.go:26-28`; `purity_test.go:184`.
- `npm view @glw907/cairn-cms dist-tags`: `latest` 0.98.0, `next` 0.99.0-rc.4.
- `~/.local/secrets` holds the four `GITHUB_TEST_*` names (count only).

## Mechanics and feasibility

| Id | Disposition | Where, or why |
| --- | --- | --- |
| mech B1 | folded (root, with con B1) | spec 2 "The pack"; plan T1.2 (runner, script run by `publish.yml` and `check:package` before `npm pack --ignore-scripts`; bake not moved in P1, so its callers stay; root `/template/`); T6.4 moves the bake |
| mech B2 | folded | spec 5 "Tests" (package-var seam; test build tag file store); plan T1.5, T2.1, Permissions line |
| mech B3 | folded | plan T6.4 explicit file list, moves for `site-config-path.json` and the transcript corpus, scoped grep |
| mech B4 | folded (root, with con M13, mech m1) | plan "Each task block" paragraph (skip plus `// WATCH:`, requires with first importer, test-first commit order); T2.1/T2.3 goldens moved; T3.1 harness self-test; T6.1 merged with its fix; T1.4 handles `step_test.go` |
| mech B5 | folded | plan Decide 4 and T7.4 (pin to `0.99.0-rc.4` in the same PR); spec 14 |
| mech M1 | owner fork, Decide 5 | the template half is taken without a ruling (setup overlay, spec 2), since `templates/waymark` also serves the Deploy button; whether mid-initiative releases must stay possible is a priority call |
| mech M2 | folded | P5 reclassed `runner` (pass-core "Lifecycle": skills and agents are `runner`), with a packet; T4.3 moved into P5 T5.6; grant text now true; item 8 probes a held-file write |
| mech M3 | folded (root, with int m2) | spec 7 "Push" (append after the inherited count, git-config quote), spec 13; T2.1 self-test |
| mech M4 | folded | spec 11 `--dry-run --json`; owed erratum E2 |
| mech M5 | folded in part (with con M14, int M10, M11) | absolute path, staging dir, executor import, local-fake tests, `--cleanup`, unrecordable list, latency (spec 12; plan item 4, T1.0, standing answers). Refused: a real Actions deploy in S1, since the deploy key's scope is today's `cairn-build` scope and the release's real-account leg proves the path; refused: S1 before launch, since the recorder is P1's output and the spike client is deleted |
| mech M6 | folded | every miscited line recited in spec 2, 3, 6, 9, 10; Decide 2's premise restated against `rebindToken` |
| mech M7 | folded (root, with con M10c) | T1.1 runner, `tool.yml`, `gate-table.json`, widened grep |
| mech M8 | folded | T2.2 (`coverage_test.go`, `copylist`), T2.4 (`agentsPage` in `messages.go`), T2.3 `flags.json` |
| mech M9 | folded | requires land with first importer (T3.1, T3.2, T3.5); T3.5 owns Fang's module lines and `cmd/mangen`; T3.3 touches no module file |
| mech M10 | folded | spec 8 (`$BROWSER` set skips the no-display stop), spec 13 (node stub, serial cases, address faked); T2.1 adds `tool.yml` |
| mech M11 | folded | P5 tasks gain files and checks; T5.1 transcripts; T5.3 declares dropped transcripts unconsumed; one declared fact-checker deferral; T5.3 owns the README entries |
| mech M12 | folded in part; owner fork Decide 8 | App name cut to 34 (spec 3); `git init -b` and the `deploy.yml` branch row (spec 7, 9); 422 reruns Cloudflare checks (spec 3); `account_id` inserted (spec 9). The taken-name answer is Decide 8 |
| mech M13 | folded | spec 2 "Tests"; T1.9 rewrites to `file:` tarballs |
| mech M14 | folded | T6.1 installs into a temp dir and runs `node_modules/.bin/create-cairn-site` with `--dry-run --json`, which needs no Go harness |
| mech M15 | owner fork, Decide 10 (with con M18) | T6.6 on yes |
| mech M16 | owner fork, Decide 6 | only Geoff raises a class. The `live-account` part refused: cairn's path map has no such class. The admin smoke part refused: Decide 1 rests on the unbound-row confirm documented at `auth-routes.ts:379-385`, and setup changes no engine auth path |
| mech M17 | dropped (optional) | T1.0's estimate rose anyway (75 to 150) from the scope the fold added |
| mech m1 | folded | in B4 |
| mech m2 | folded | "Each accepted-task report names the CI verdict on its head commit" |
| mech m3 | folded | T5.8 reruns the docs gate; T6.5 changes no page |
| mech m4 | folded | the overlay's `.claude/settings.json` (T5.6) sits outside the showcase emit and the guidance tree |
| mech m5 | folded | T1.0 adds its tests to `tool.yml` |
| mech m6 | folded | absolute prototype paths in T1.8 and P3 |
| mech m7 | folded | item 4: S1 never runs during a release-gate run; run-id names (spec 12) |
| mech m8 | refused | the port is fixed (spec 4), so RFC 8252's any-port question is moot |
| mech m9 | folded | owed erratum E3 |
| mech m10 | folded | item 1's check states S1 proves the redirect and scopes |
| mech m11 | refused | pass-core "Lifecycle" step 1's path ceiling and escalation rules already answer it |
| mech m12 | folded | item 8 probes `npm publish --dry-run` |
| mech m13 | folded (with con m9) | T4.2 and T5.6 checks |
| mech m14 | folded | "The design's estimate" relabelled planner-set; 3,685 kept |

## Contract and criteria

| Id | Disposition | Where, or why |
| --- | --- | --- |
| con B1 | folded (root mech B1) | part 2 (overlay missing from the bake) folded through the composed tree plus setup overlay; listing test extended in T1.9, T5.6; matrix asserts files |
| con B2 | folded | item 3: `grep -cE '^Ruled: (yes\|no)\b'` prints `10` |
| con M1 | folded | T1.10 opening-check table with zero writes; T3.8 copy task; anchors as messages-table fields resolved by T5.2's Go test (revised after V-B1; spec 8) |
| con M2 | folded | T1.10 (scope re-consent, failed delete, foreign-App list, kills), T1.8 (clock), T1.7 (read-back picks our App) |
| con M3 | folded (with int M3) | T1.12 kills after each watch step with create counts; differing id refused |
| con M4 | folded (with int M2) | T1.4 value test; spec 4 |
| con M5 | folded (with int M1) | T2.3 grep of every surface; T3.6 frame grep |
| con M6 | folded (with int M8) | spec 11; T2.3 cases; T1.12 address recheck |
| con M7 | folded | T1.12 end and stop cases; T5.3 credentials page; owed erratum E6 |
| con M8 | folded | (a) spec 10 format, vector and column tests in T1.12; (b) `/next` route (spec 10, T1.8); (c) Decide 2 sends on consumption or expiry; (d) Decide 1 carries the alternate line |
| con M9 | folded | spec 9 workflow test and actionlint; T1.9 |
| con M10 | folded | (a) `setup-matrix.yml` with its own paths; (b) T5.5 paths and `toolInputs`; (c) with mech M7 |
| con M11 | folded in part; owner fork Decide 8 | 34-character cut folded; the unauthenticated `GET /apps/<slug>` pre-check refused, since a private App need not show to it, so it cannot prove a name free |
| con M12 | folded in part | T2.3 explicit kind, order, and sentence assertions. Refused: the copy-deck extraction test, new machinery with no named defect; the close review reads the copy golden's diff against the deck (T3.7) |
| con M13 | folded (root mech B4) | |
| con M14 | folded in part (root mech M5) | (a) staging and import; (b) route list follows the ruled Decides (T1.6, T1.7). Refused: the corpus coverage test, since each route's decode case in T1.6 and T1.7 already fails on a missing body |
| con M15 | folded | spec 12 guards; T1.0 cases |
| con M16 | folded | T1.1 moves the hygiene test; T6.4's test checks one reads the corpus |
| con M17 | folded | `/deploys` lands with the pin bump (spec 14, T7.3) |
| con M18 | owner fork, Decide 10 (root mech M15) | |
| con M19 | folded | Decide 3 names the only Workers Paid signal; generic copy in T3.8 |
| con m1 | folded | T1.10 conditional questions; T3.3 goldens |
| con m2 | folded | T1.3 expected outputs; T3.8 slug line |
| con m3 | folded | T1.9 cases (pin, `--tag`, email); non-empty folder in T1.10; background install in spec 9 |
| con m4 | folded | T1.8 detection table; the title wording goes to T3.8's register pass |
| con m5 | dropped (optional) | |
| con m6 | folded | T3.2 edge goldens |
| con m7 | folded | T5.6 exact-set test |
| con m8 | folded | T4.2 route and directive tests |
| con m9 | folded | T4.4, T5.7, T5.6 checks |
| con m10 | folded | T5.3 widened grep; declared deferral; T5.1 transcripts |
| con m11 | folded | T6.1 `os`/`cpu` and missing-package cases |
| con m12 | folded | T6.4 destinations and widened grep |
| con m13 | folded | item 5 check |
| con m14 | folded | item 4 check (names only, run by Geoff) |
| con m15 | folded into Decide 5 | |
| con m16 | (a), (b) folded; (c) owner fork Decide 7 | the prototype is the tiebreaker (P3 outcome); the summary's theme row is two binding documents in conflict |
| con m17 | folded | the `Reviewed:` line names the reviews, this record, and the verification read the planning session runs next |
| con m18 | folded (with mech m14) | |
| con m19 | folded | tagged optional, but the global rule requires every dispatch to name an effort: `model: opus` dispatches set `effort: high` |
| con m20 | folded | `claude/CLAUDE.md` added to the grant; the plan-reviewer line is a PR the planning session opens on `~/Projects/standards`, not an executor write |
| con m21 | folded | T1.12 HTTPS fake clock |
| con m22 | folded | T2.3 status case |
| con m23 | folded | spec 6 hosts per client; T1.6 |
| con m24 | dropped (optional) | carried as erratum E3 through mech m9 |
| con m25 | folded | T1.4 store visibility |
| con m26 | taken, not a fork | (b): T6.5's packet links P3's captures manifest. It adds no stop and puts the look before Geoff before anything ships, so there is one clearly better answer |
| con m27 | folded | spec 5 captured child output; T1.12 stub-child case |
| con m28 | dropped (optional) | |

## Data integrity and failure risk

| Id | Disposition | Where, or why |
| --- | --- | --- |
| int B1 | folded | spec 4 discriminator; T1.4 19-step and adopted-record case |
| int B2 | folded | spec 7 "Over-grant on every exit" (sweep by App JWT `GET /app/installations`, recon GH 28,89); T1.10 kill cases |
| int M1 | folded | spec 5 logx registration and PEM by line; T1.10 files `logx`; typed-field rendering |
| int M2 | folded (root con M4) | |
| int M3 | folded | spec 3 intents and adopt-if-empty; spec 6 deploy key named with the run id, deleted and reminted on resume; T1.12 |
| int M4 | folded | spec 5 keyring probe, persist-before-advance, delete by recorded names (no prefix sweep: go-keyring lists nothing). Its `keyring.go:325-336,450-458` citations are wrong (the file has 167 lines); the mechanism is at `:59-62` |
| int M5 | folded | spec 5 refresh and re-consent; T1.5, T1.12; owed erratum E5 |
| int M6 | folded, lock file refused | every run holds port 49152 for its whole life (spec 4), which serializes runs with no new machinery; a pid lock file has no measured defect to answer beyond what the port covers |
| int M7 | folded | spec 6 address check reads custom domains and routes; step 7 and step 4 rechecks; T1.10 case |
| int M8 | folded (root con M6) | spec 11 run id, 0600, open fields only |
| int M9 | folded in part | the `issueToken`-mirroring batch and the column test (spec 10, T1.12). Refused: the version-range and `d1_migrations` refusal, since its failure mode is a rejected sign-in row the ordinary sign-in page recovers, and tool and engine share a repo, so the column test runs against current migrations on every tool change |
| int M10 | folded | spec 12 write guard, run-id names, one-hour token, ledger, `--cleanup`, dummy sealed value; the custom-domain and Email Sending writes leave S1 (pending), so no certificate or sending subdomain is created; item 4's revoke line |
| int M11 | folded | T1.0 reviews before S1; `env -i` allowlist; value scrub; staging; test-only PEM (spec 12) |
| int M12 | folded | spec 2 and 4 (version, integrity, folder, commit, remote ref) |
| int M13 | owner fork, Decide 9 | |
| int m1 | dropped (optional) | |
| int m2 | folded (root mech M3) | proxy refuses unfaked `CONNECT` (spec 13, T2.1) |
| int m3 | folded | `/next` one-shot and cookie-bound (spec 10, T1.8); install-callback `state` recorded at S1 (spec 7) |
| int m4 | folded | agent lane step 8 relies on the email (spec 10), consistent with the design's walked-away case |
| int m5 | dropped (optional) | Decide 2 states the unbound row as part of mech M6's restated premise |
| int m6 | folded | spec 4 first-save id check; T1.4 |
| int m7 | folded | spec 2 `filepath.IsLocal` and type checks; T1.9 |
| int m8 | folded | spec 4 schema version; T1.4 |
| int m9 | folded | spec 5 entry names and the 2,560-byte limit; T1.5 |
| int m10, m11, m12 | dropped (optional) | m11's MIGRATION-NOTES line was cheap and is in T6.5 |
| int O1 | dropped (optional) | its root folded through mech M5's unrecordable list |
| int O2 | dropped (optional) | its root folded through int M6's fixed port |

## Owner forks

Decides 5 to 10 in the plan's "Rulings before launch". Decides 1 to 4 stay, revised: Decide 1 gains
the alternate done line; Decide 2's premise is corrected (the emailed link is not unusable but dead
for an owner reading mail later, through `rebindToken`), and it sends on consumption or expiry;
Decide 3 gains the Workers Paid signal rule; Decide 4 moves the pin to `0.99.0-rc.4` and defers
`/deploys`.

## Owed errata (the ratified design is unedited)

| Id | Design text | Revision | Ruling needed |
| --- | --- | --- | --- |
| E1 | "Waymark's template lives in the engine package today" | it does not; the plan puts it there (spec 2) | no |
| E2 | "a `--plan --json` dry run" | `--dry-run --json`; the literal cannot parse beside `--plan <file>` | no |
| E3 | "Setup mints short-lived, narrow Cloudflare tokens ... wrangler takes them" | none minted; the deploy key is the only minted token | no |
| E4 | "every pull request runs `cairn new` from the built binary" | the e2e binary is built with a test build tag for its keyring file store | no |
| E5 | "named waiting states for the four approvals" | plus one for a resume's Cloudflare re-consent | no |
| E6 | OAuth tokens live in the keyring "only while setup runs" | read as the run across its resumes: a stopped run keeps its entries until it finishes | no (Decide 9 covers stale runs) |
| E7 | the redirect "signed in" at once; done.html's footer | one Sign in click | Decide 1 |
| E8 | setup "asks the live site to send its ordinary sign-in email" | setup sends the email itself | Decide 2 |
| E9 | "the App asks for no Actions permission"; the Workers Paid copy as the fallback | `actions: read`; Workers Paid copy only on a positive signal | Decide 3 |
| E10 | the summary's theme row | per Decide 7 | Decide 7 |
| E11 | "With one unfinished run, `cairn new` resumes it" | the choice includes "Start a new site" | Decide 9 |

## Path minutes after the fold

After the verification read: P1 1,170; P2 510; P3 765; P4 300; P5 540; P6 480; P7 195 or 375.
Critical chain (P1, P2, P3, P5, P6): 3,465, against the planner-set estimate of 3,685 and the twice
line of 7,370.

## Not verified

- Whether `npm pack` keeps `template/waymark/.dev.vars.example` under the root `.gitignore`'s
  `.dev.vars.*` rule; T1.2's listing test asserts it.
- Cloudflare's `GET /zones/{id}/workers/routes` shape and the emptiness reads for adopt (spec 3,
  6): the builder quotes each reference.
- Whether GitHub returns `state` on the install callbacks: S1 records it.

## Verification read

Dispositions on `2026-11-08-cairn-new-fold-verification.md` (V-), each checked against the code
first. All folded; no new fork, no new erratum.

| Id | Disposition | Where |
| --- | --- | --- |
| V-B1 | folded | verified `check-readiness.mjs:27,146-166`. Plan T3.8 (anchors as messages-table fields, no `shipped-anchors.json` entry; P3 stays `ordinary`), T5.2 (`tool/internal/setup/anchors_test.go` against `before-you-start.md`'s headings), T5.3 acceptance (anchor clause struck), "Before the first release" (check-readiness learns a second page); spec 8 |
| V-M1 | folded | T6.4 removes `test/**` except `launcher.test.mjs`; its acceptance runs `npm test -w packages/create-cairn-site` |
| V-M2 | folded, pair kept | T6.3 owns every `tool.yml` and `publish.yml` edit, including removing `publish.yml:125-130`, with a workflow grep; T6.4 drops `tool.yml`. Disjoint, so P6 stays 480 rather than serializing to 660 |
| V-M3 | folded | stacked branch from P5's approved head, rebase and CI before merge ("Passes"); item 6 check |
| V-M4 | folded | T5.4 owns its README entries and inbound links; each page task links only existing pages |
| V-M5 | folded | T6.6 moved to P2 as T2.6, paired with T2.4 (P2 stays 510); Decide 10 and the backlog line repointed |
| V-M6 | folded | spec 5 (mutex-guarded registration; the view writes the raw terminal, `main.go:50-56`, `logx.go:27-30`); T3.1 ADR-0004; T1.10 `-race` case |
| V-M7 | folded | T3.3 adds `newview` to `copylist` (180 min); T2.4, T3.4, T3.8 list `copy.golden.md` |
| V-M8 | folded | T1.12 three fake-clock send cases on a yes to Decide 2 |
| V-m1 | folded | T1.1 Files and grep exclusion |
| V-m2 | folded | T1.1 and T1.0 Node steps on the Linux leg after `setup-node` and `npm ci`; lazy `browser.mjs` import |
| V-m3 | folded | spec 2 cites `bake-template.mjs:324-330` and the rename order; T1.2's dead assertion replaced |
| V-m4 | folded | "Main stays releasable" wording |
| V-m5 | folded | T5.2: each page task declares its own dropped transcripts |
| V-m6 | folded | T5.4 adds `tool.yml` path and `toolInputs` |
| V-m7 | folded | spec 12: the send joins the pending list; Worker dropped from the cleanup list |
| V-m8 | folded | item 4 names the `--cleanup` command |
| V-m9 | folded | item 8: worktree under `.claude/worktrees/`, cites T5.7, adds `claude plugin validate` |
| V-m10 | folded | grant text "P1, P5, and P6" |
| V-m11 | folded | Decide 2's No names the agent lane |
| V-m12 | folded | T7.4 names `standards:dependency-upgrade` |
| V-m13 | folded | spec 10 guard (`bootstrap.mjs:105-107`); T1.12 case |
| V-m14 | folded | T6.4 acceptance runs the unit suite including `gate-main.test.ts` |
| V-m15 | folded | pre-flight item 9 with a `gh pr view` check |
| V-m16 | folded | T1.10 defines the provider interfaces T1.6 and T1.7 satisfy |
| V-m17 | folded (trivial, optional) | spec 4 cites `record.go:1-4` |
